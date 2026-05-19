import os
import psycopg2
import feedparser
import urllib.parse
import calendar
from newspaper import Article, Config
from dotenv import load_dotenv
from datetime import datetime
import time

load_dotenv()
DATABASE_URL = os.environ.get("DATABASE_URL")

def extract_article_text(url):
    """Doğrudan hedef haber linkine gidip makale metnini çıkarır."""
    try:
        config = Config()
        config.browser_user_agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        config.request_timeout = 15
        
        article = Article(url, language='tr', config=config)
        article.download()
        article.parse()
        
        if len(article.text) > 150: 
            return article.text
        else:
            print("      [!] Metin çok kısa (<150 karakter) veya bot engeli.")
            return None
    except Exception as e:
        print(f"      [!] Site okunamadı ({type(e).__name__}).")
        return None

def fetch_and_save_news():
    if not DATABASE_URL:
        print("HATA: .env dosyasında DATABASE_URL eksik!")
        return

    try:
        print("Veritabanına bağlanılıyor...")
        conn = psycopg2.connect(DATABASE_URL)
        cur = conn.cursor()

        cur.execute("SELECT DISTINCT symbol FROM user_portfolios;")
        symbols = [row[0] for row in cur.fetchall()]
        
        search_queries = {"GENEL": "Borsa İstanbul ekonomi"}
        for sym in symbols:
            search_queries[sym] = f"{sym} hisse"

        print(f"Toplam {len(search_queries)} farklı konu için haberler taranacak...\n")
        total_saved_news = 0 

        for symbol, query in search_queries.items():
            print(f"\n👉 [{symbol}] için BING NEWS taranıyor...")
            
            encoded_query = query.replace(" ", "+")
            rss_url = f"https://www.bing.com/news/search?q={encoded_query}&format=rss&cc=tr"
            
            feed = feedparser.parse(rss_url)
            
            if not feed.entries:
                print("   ❌ Bing News bu arama için sonuç döndürmedi.")
                continue
                
            print(f"   ✅ RSS'ten {len(feed.entries)} adet haber bulundu. Son 12 saat filtreleniyor...")

            for entry in feed.entries:
                headline = entry.title
                raw_link = entry.link 
                
                # 1. ADIM: Zaman Kontrolü
                try:
                    if 'published_parsed' in entry and entry.published_parsed:
                        gmt_epoch = calendar.timegm(entry.published_parsed)
                        pub_date = datetime.fromtimestamp(gmt_epoch)
                    else:
                        pub_date = datetime.strptime(entry.published, "%a, %d %b %Y %H:%M:%S %Z")
                except:
                    pub_date = datetime.now()

                time_delta = datetime.now() - pub_date
                
                if time_delta.total_seconds() > 7200:
                    # Haber 2 saatten eskiyse atla
                    saat_farki = int(time_delta.total_seconds() / 3600)
                    print(f"      ⏩ Haber çok eski ({saat_farki} saat önce). Atlanıyor...")
                    continue

                # 2. ADIM: Bing Linkinden Gerçek Linki Cımbızlama
                try:
                    parsed_url = urllib.parse.urlparse(raw_link)
                    query_params = urllib.parse.parse_qs(parsed_url.query)
                    if 'url' in query_params:
                        real_link = query_params['url'][0] 
                    else:
                        real_link = raw_link
                except:
                    real_link = raw_link

                domain = urllib.parse.urlparse(real_link).netloc
                print(f"   ➤ Deneniyor [{domain}]: {headline[:40]}...")
                
                # 3. ADIM: Sadece taze haberlerin içeriğini kazıma
                content = extract_article_text(real_link)
                
                if content:
                    sql = """
                        INSERT INTO financial_news (symbol, headline, source_link, content, published_at)
                        VALUES (%s, %s, %s, %s, %s)
                        ON CONFLICT (source_link) DO NOTHING;
                    """
                    cur.execute(sql, (symbol, headline, real_link, content, pub_date))
                    
                    if cur.rowcount > 0:
                        total_saved_news += 1
                        print(f"      ✅ YENİ EKLENDİ!")
                    else:
                        print(f"      ⏩ ZATEN VAR (Atlandı).")
                else:
                    print("      ❌ Veritabanına YAZILMADI.")
            
            time.sleep(1) 

        conn.commit()
        cur.close()
        conn.close()
        
        print("\n" + "-" * 50)
        print(f"İşlem tamam! Son 12 saate ait toplam {total_saved_news} YENİ haber Supabase'e kaydedildi.")
        print("-" * 50)

    except Exception as e:
        print(f"Kritik Hata oluştu: {e}")

if __name__ == "__main__":
    fetch_and_save_news()