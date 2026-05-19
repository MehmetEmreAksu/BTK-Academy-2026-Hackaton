import os
import requests
import psycopg2
from dotenv import load_dotenv

load_dotenv()
DATABASE_URL = os.environ.get("DATABASE_URL")

def setup_market_and_portfolios():
    if not DATABASE_URL:
        print("HATA: .env dosyasında DATABASE_URL eksik!")
        return

    # TRADINGVIEW ARKA KAPISI (API Key gerektirmez, limitlere takılmaz)
    url = "https://scanner.tradingview.com/turkey/scan"
    
    # TradingView'dan neleri istediğimizi JSON formatında söylüyoruz
    payload = {
        "columns": ["name", "description", "sector"], # Kod, Uzun Ad, Sektör
        "range": [0, 1500] # İlk 1500 hisseyi getir (BIST'te zaten 600 civarı var, fazlasıyla yeter)
    }
    
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
        "Content-Type": "application/json"
    }

    print("TradingView üzerinden TÜM Borsa İstanbul hisseleri çekiliyor...")
    
    try:
        # GET yerine POST isteği atıyoruz
        response = requests.post(url, json=payload, headers=headers)
        
        if response.status_code != 200:
            print(f"API Hatası: {response.status_code}")
            return
            
        data = response.json()
        stocks_list = data.get("data", [])
        
        print("Veritabanına (Neon) bağlanılıyor...")
        conn = psycopg2.connect(DATABASE_URL)
        cur = conn.cursor()
        
        print("Tüm hisseler veritabanına işleniyor...")
        
        count = 0
        for item in stocks_list:
            # TradingView verisi "d" (data) anahtarı içinde bir liste olarak döner
            # Örn: ["THYAO", "TURK HAVA YOLLARI", "Transportation"]
            stock_data = item.get("d", [])
            
            if len(stock_data) == 3:
                symbol = stock_data[0]
                name = stock_data[1]
                sector = stock_data[2]
                
                # TradingView sektör bulamazsa None döner, onu düzeltelim
                if not sector:
                    sector = "Genel"

                query = """
                    INSERT INTO market_stocks (symbol, company_name, sector)
                    VALUES (%s, %s, %s)
                    ON CONFLICT (symbol) DO UPDATE 
                    SET company_name = EXCLUDED.company_name,
                        sector = EXCLUDED.sector;
                """
                cur.execute(query, (symbol, name, sector))
                count += 1
                
        conn.commit()
        cur.close()
        conn.close()
        print(f"✅ BÜYÜK BAŞARI! BIST'teki tüm güncel {count} hisse senedi veritabanına eklendi.")
        
    except Exception as e:
        print(f"Beklenmeyen bir hata oluştu: {e}")

if __name__ == "__main__":
    setup_market_and_portfolios()