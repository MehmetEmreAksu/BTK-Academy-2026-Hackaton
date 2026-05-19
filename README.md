# Aizanoi — Financial AI Market Tracker 📈🤖

BTK Academy 2026 Hackathon projesi. 5 kişilik bilgisayar mühendisliği öğrenci
takımı tarafından geliştirildi.

Aizanoi; finansal tweet ve haberleri toplayıp yapay zeka ile **risk** ve
**güvenilirlik (credibility)** skoru üreten, bunları resmi **KAP** açıklamalarıyla
çapraz kontrol eden ve bir Flutter uygulamasında kullanıcının portföyüne göre
sunan uçtan uca bir sistemdir.

---

## Mimari

Sistem 4 ana bileşene ayrılmıştır:

| Bileşen | Teknoloji | Görev |
|---|---|---|
| **Veri Toplama** | Python | Tweet (Apify/X), haber (RSS), borsa fiyatı (yfinance), KAP resmi bildirimleri |
| **Veritabanı** | Supabase (PostgreSQL + pgvector) | Ham veri, risk skorları, portföy, vektör deposu |
| **AI Agent** | n8n + Google Gemini 2.5-flash | Risk + credibility analizi, RAG sohbet, günlük mail |
| **Arayüz** | Flutter / Dart | Dashboard, portföy, uyarılar, AI sohbet |

### Veri akışı

```
Python fetcher'lar → Supabase tabloları (is_processed=false kuyruğu)
        │
        ▼
n8n W1 (agent_workflow_v2): tweet/haber oku → o şirketin son KAP açıklamalarını
       SQL JOIN ile ekle → Gemini tek çağrıda risk_score + credibility_score üret
        │
        ▼
risk_scores tablosu → Flutter Alerts (kullanıcının portföyüne göre filtreli)
                    → n8n W2 (her sabah 09:00 günlük risk maili)

financial_news/tweets → n8n RAG pipeline → market_vectors (embedding)
                      → n8n Chat (webhook) → uygulama içi AI asistan
```

---

## Klasör Yapısı

```
flutter_side/      Flutter uygulaması (Aizanoi)
python_backend/    Tweet / haber / fiyat toplayıcılar + requirements.txt
kap_fetch/         KAP resmi bildirim toplayıcı (MKK API, Basic auth)
workflow/          n8n workflow JSON'ları + kap_schema.sql
```

### n8n Workflow'ları (`workflow/`)

| Dosya | Açıklama |
|---|---|
| `agent_workflow_v2.json` | **W1** — Tweet/haber risk + KAP credibility analizi (Gemini 2.5-flash) |
| `agent_workflow_W2_dailymail.json` | **W2** — Her sabah 09:00 kullanıcıya portföy risk maili |
| `Aizonai's Chat.json` | Uygulama içi RAG sohbet (webhook `/webhook/ai-chat`) |
| `Aizonai's_RAG_3_version.json` | Tweet/haber → vektör (market_vectors) gömme pipeline'ı |
| `kap_schema.sql` | `kap_disclosures` tablosu + `risk_scores.credibility_score` |

---

## Supabase Şeması (ana tablolar)

| Tablo | İçerik |
|---|---|
| `financial_tweets` | Çekilen tweetler (`is_processed` kuyruğu) |
| `financial_news` | Çekilen haberler |
| `kap_disclosures` | Resmi KAP açıklamaları (gerçeklik kaynağı) |
| `market_stocks` | BIST şirket listesi (symbol, company_name, sector) |
| `stocks` | Canlı fiyatlar (current_price, previous_close) |
| `risk_scores` | AI çıktısı: risk_score, credibility_score, level, reason |
| `user_portfolios` | Kullanıcı takip listesi (user_id = Supabase Auth UUID) |
| `users` | user_id, email, full_name |
| `market_vectors` | RAG vektör deposu (pgvector) |

---

## Kurulum

### 1. Veritabanı (Supabase)
- pgvector extension'ı aç
- `workflow/kap_schema.sql`'i SQL Editor'da çalıştır
- İlgili tablolarda RLS'i kapat (Flutter erişimi için)

### 2. Python toplayıcılar
```bash
pip install -r python_backend/requirements.txt
pip install -r kap_fetch/requirements.txt
```
`python_backend/.env` ve `kap_fetch/.env` dosyalarını oluştur (DATABASE_URL,
API anahtarları). `.env` dosyaları repoya **dahil değildir** (`.gitignore`).

```bash
python python_backend/news_fetcher.py
python python_backend/tweets_fetcher.py
python python_backend/borsa_fiyat_guncelleme.py
python kap_fetch/fetch_kap.py
```

### 3. n8n
- `workflow/` altındaki JSON'ları import et
- Supabase (service_role key) ve Google Gemini credential'larını node'lara bağla
- W1'i tetikle, W2'yi schedule'la, Chat workflow'unu **Active** yap

### 4. Flutter
```bash
cd flutter_side
flutter pub get
flutter run
```
`flutter_side/.env` içine `SUPABASE_URL` ve `SUPABASE_ANON_KEY` yaz.

---

## Öne Çıkan Özellik: Risk + Güvenilirlik

Sistemin ayırt edici değeri, bir tweet/haberi yalnızca riske göre değil,
**resmi KAP açıklamalarıyla tutarlılığa** göre de puanlamasıdır:

- `risk_score` (0-100): İçerik şirket için ne kadar olumsuz/tehdit edici?
- `credibility_score` (0-100): İddia resmi KAP kaynağıyla ne kadar örtüşüyor?

Yüksek risk + düşük güvenilirlik = olası **manipülasyon / asılsız söylenti** uyarısı.

---

## Teknolojiler

Flutter · Dart · Supabase · PostgreSQL · pgvector · n8n · Google Gemini 2.5-flash ·
Python · yfinance · Apify · KAP (MKK) API

> Eğitim amaçlı hackathon projesidir. Yatırım tavsiyesi içermez.
