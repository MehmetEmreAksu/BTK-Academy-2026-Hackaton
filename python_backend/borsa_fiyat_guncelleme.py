import os
import yfinance as yf
import psycopg2
from dotenv import load_dotenv
from datetime import datetime

# .env dosyasındaki bilgileri yükle
load_dotenv()
DATABASE_URL = os.environ.get("DATABASE_URL")

def update_portfolio_prices():
    if not DATABASE_URL:
        print("HATA: .env dosyasında DATABASE_URL eksik!")
        return

    try:
        print("Veritabanına (Supabase) bağlanılıyor...")
        conn = psycopg2.connect(DATABASE_URL)
        cur = conn.cursor()

        # 1. OPTİMİZASYON: Sadece kullanıcıların portföyüne eklediği "benzersiz" hisseleri bul
        print("Kullanıcıların takip ettiği hisseler tespit ediliyor...")
        cur.execute("SELECT DISTINCT symbol FROM user_portfolios;")
        
        # Gelen veriyi temiz bir listeye çevirirken 'GENEL' isimli makro etiketini hariç tutuyoruz
        target_stocks = [row[0] for row in cur.fetchall() if row[0] != 'GENEL']

        if not target_stocks:
            print("Henüz hiçbir kullanıcı portföyüne gerçek bir hisse eklememiş. İşlem atlanıyor.")
            cur.close()
            conn.close()
            return

        print(f"Sistemde toplam {len(target_stocks)} farklı hisse takip ediliyor: {target_stocks}")
        print("Fiyat verileri Yahoo Finance üzerinden çekiliyor...")

        # 2. Seçilen hisselerin fiyatlarını teker teker çek
        for stock in target_stocks:
            symbol_yf = f"{stock}.IS" 
            
            try:
                ticker = yf.Ticker(symbol_yf)
                hist = ticker.history(period="2d")
                
                if len(hist) >= 1:
                    # En son günün kapanış fiyatı
                    current_price = float(hist['Close'].iloc[-1])
                    # Bir önceki günün kapanışı
                    previous_close = float(hist['Close'].iloc[-2]) if len(hist) > 1 else current_price
                    now = datetime.now()

                    # 3. UPSERT Mantığı ile "stocks" tablosunu güncelle
                    query = """
                        INSERT INTO stocks (symbol, current_price, previous_close, last_updated)
                        VALUES (%s, %s, %s, %s)
                        ON CONFLICT (symbol) DO UPDATE 
                        SET current_price = EXCLUDED.current_price,
                            previous_close = EXCLUDED.previous_close,
                            last_updated = EXCLUDED.last_updated;
                    """
                    cur.execute(query, (stock, current_price, previous_close, now))
                    print(f"✅ {stock} başarıyla güncellendi: {current_price:.2f} TL")
                else:
                    print(f"⚠️ {stock} için Yahoo Finance'te güncel fiyat bulunamadı.")
            
            except Exception as e:
                print(f"❌ {stock} verisi çekilirken hata oluştu: {e}")

        conn.commit()
        cur.close()
        conn.close()
        print("\nİşlem tamam! Kullanıcıların takip ettiği tüm fiyatlar Supabase veritabanında taptaze.")

    except Exception as e:
        print(f"Veritabanı işleminde kritik hata: {e}")

if __name__ == "__main__":
    update_portfolio_prices()