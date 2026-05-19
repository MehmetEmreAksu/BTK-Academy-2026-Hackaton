import os
from dotenv import load_dotenv
from apify_client import ApifyClient
import psycopg2

load_dotenv()

DATABASE_URL = os.environ.get("DATABASE_URL")
APIFY_TOKEN = os.environ.get("APIFY_TOKEN")
ACTOR_ID = os.environ.get("ACTOR_ID", "kaitoeasyapi/twitter-x-data-tweet-scraper-pay-per-result-cheapest")

accounts = [
    "ForeksTurkey", "BloombergHT", "matrikstrader", "borsaistanbul",
    "MertBasaran_inv", "YKYatirim", "borsambogasi", "ziraatyatirim", "garantibbvaytrm", "blackrock",
    "bondvigilantes", "BBVAResearch"
]

search_query = " OR ".join([f"from:{acc}" for acc in accounts])

def get_tweets_and_save():
    if not DATABASE_URL or not APIFY_TOKEN:
        print("HATA: .env dosyasında eksik bilgi var!")
        return

    client = ApifyClient(APIFY_TOKEN)
    
    run_input = {"searchTerms": [search_query], "maxItems": 50}

    print(f"Apify'a istek atılıyor...")
    
    try:
        run = client.actor(ACTOR_ID).call(run_input=run_input)
        
        conn = psycopg2.connect(DATABASE_URL)
        cur = conn.cursor()
        print("Veritabanı bağlantısı başarılı!")
        
        cur.execute("SELECT symbol, company_name FROM market_stocks;")
        all_market_stocks = cur.fetchall()
        print(f"🎯 BIST Sözlüğü Yüklendi: Metinler {len(all_market_stocks)} şirket verisine göre taranacak.")
        
        saved_count = 0
        
        for item in client.dataset(run["defaultDatasetId"]).iterate_items():
            tweet_id = str(item.get("id") or item.get("tweet_id") or "")
            text = item.get("text") or item.get("full_text") or item.get("tweet_text") or ""
            created_at = item.get("createdAt") or item.get("created_at")

            account = "Bilinmiyor"
            if "author" in item and isinstance(item["author"], dict):
                account = item["author"].get("userName") or item["author"].get("name")
            elif "user" in item and isinstance(item["user"], dict):
                account = item["user"].get("screen_name") or item["user"].get("name")
            elif "username" in item:
                account = item["username"]

            if not tweet_id or not text:
                continue

            matched_symbol = "GENEL" 
            text_upper = text.upper()
            
            for sym, company_name in all_market_stocks:
                symbol_match = sym.upper() in text_upper
                
                name_match = False
                if company_name:
                    name_match = company_name.upper() in text_upper
                
                if symbol_match or name_match:
                    matched_symbol = sym
                    break 

            query = """
                INSERT INTO financial_tweets (tweet_id, account_name, tweet_text, published_at, symbol)
                VALUES (%s, %s, %s, %s, %s)
                ON CONFLICT (tweet_id) DO NOTHING;
            """
            cur.execute(query, (tweet_id, account, text, created_at, matched_symbol))
            
            if cur.rowcount > 0:
                saved_count += 1
                print(f"  ✅ YENİ TWEET [{matched_symbol}]: {text[:50]}...")
        
        conn.commit()
        cur.close()
        conn.close()
        
        print("\n" + "-" * 50)
        print(f"🚀 İşlem tamam! En güncel akıştan {saved_count} yeni tweet etiketlenip Supabase'e eklendi.")
        print("-" * 50)

    except Exception as e:
        print(f"Bir hata oluştu: {e}")

if __name__ == "__main__":
    get_tweets_and_save()