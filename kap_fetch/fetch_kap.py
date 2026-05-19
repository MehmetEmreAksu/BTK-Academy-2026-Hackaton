"""
KAP (Kamuyu Aydinlatma Platformu) bildirim cekme scripti.

Tweet/haber ceken Python pipeline'i ile AYNI mantik:
  fetch -> kap_disclosures tablosuna yaz (is_processed=false).
n8n W1 agent bu tabloyu okuyup tweet/haber ile karsilastirir (credibility).

Calistirmadan once 2 ortam degiskeni ayarla:
  KAP_BASE_URL : swagger sayfasinin en ustundeki base URL (orn. https://.../api)
  DATABASE_URL : Supabase Postgres baglanti string'i
                 (postgresql://postgres.<ref>:<sifre>@<pooler-host>:6543/postgres)

Cron ile periyodik calistir (tweet/haber fetcher gibi). Tekrar calismasi
sorun degil: ON CONFLICT (disclosure_index) DO NOTHING ile cift kayit olmaz.

Kurulum:  pip install -r requirements.txt
Calistir: python fetch_kap.py
"""

import os
import re
import sys
import base64
import requests
import psycopg2
import psycopg2.extras


def _load_env():
    """Yan klasordeki .env dosyasini os.environ'a yukler (varsa)."""
    path = os.path.join(os.path.dirname(__file__), ".env")
    if not os.path.exists(path):
        return
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            k, v = line.split("=", 1)
            os.environ.setdefault(k.strip(), v.strip())


_load_env()

KAP_BASE_URL = os.environ.get(
    "KAP_BASE_URL", "https://apigwdev.mkk.com.tr/api/vyk"
).rstrip("/")
DATABASE_URL = os.environ.get("DATABASE_URL", "")

TIMEOUT = 30

# KAP API auth. Swagger'daki "Authorize" butonu ne istiyorsa ona gore doldur:
#  - Bearer token ise:  KAP_TOKEN ortam degiskenine token'i ver
#  - API key header ise: KAP_API_KEY + KAP_API_KEY_HEADER (orn. "X-API-KEY")
KAP_TOKEN = os.environ.get("KAP_TOKEN", "")
KAP_API_KEY = os.environ.get("KAP_API_KEY", "")
KAP_API_KEY_HEADER = os.environ.get(
    "KAP_API_KEY_HEADER", "Ocp-Apim-Subscription-Key"
)


# Apinizer gateway Basic auth istiyor. Application'in client id/secret'i:
KAP_CLIENT_ID = os.environ.get("KAP_CLIENT_ID", "")
KAP_CLIENT_SECRET = os.environ.get("KAP_CLIENT_SECRET", "")


def auth_headers():
    h = {"Accept": "application/json"}
    if KAP_TOKEN:
        h["Authorization"] = f"Bearer {KAP_TOKEN}"
    elif KAP_CLIENT_SECRET:
        raw = f"{KAP_CLIENT_ID}:{KAP_CLIENT_SECRET}".encode()
        h["Authorization"] = "Basic " + base64.b64encode(raw).decode()
    if KAP_API_KEY:
        h[KAP_API_KEY_HEADER] = KAP_API_KEY
    return h


def get_json(path):
    url = f"{KAP_BASE_URL}{path}"
    resp = requests.get(url, timeout=TIMEOUT, headers=auth_headers())
    if resp.status_code == 401:
        sys.exit(
            "HATA: KAP API 401 Unauthorized. KAP_CLIENT_ID / KAP_CLIENT_SECRET "
            "dogru mu kontrol et (Basic auth)."
        )
    resp.raise_for_status()
    resp.encoding = "utf-8"
    return resp.json()


def clean(s):
    """Bozuk byte'lari (KAP test ortami) at; metni okunur birak.
    Sadece U+FFFD ve C1 kontrol araligini siler -> prod Turkce'ye zarar vermez."""
    if not s:
        return ""
    out = []
    for ch in str(s):
        o = ord(ch)
        if o == 0xFFFD or 0x80 <= o <= 0x9F:
            continue
        if ch >= " " or ch in "\n\t":
            out.append(ch)
    return "".join(out).strip()


def parse_dt(t):
    """'31.12.2023 10:12:03' -> ISO; cozemezse None."""
    t = clean(t)
    try:
        from datetime import datetime
        return datetime.strptime(t, "%d.%m.%Y %H:%M:%S").isoformat()
    except Exception:
        return None


# Kac bildirim geriye gidilecek (son N disclosure index)
FETCH_COUNT = int(os.environ.get("KAP_FETCH_COUNT", "60"))


def fetch_detail(idx):
    """disclosureDetail gercek icerigi verir: subject, summary, time, symbol."""
    data = get_json(f"/disclosureDetail/{idx}?fileType=data")
    if isinstance(data, list):
        return data[0] if data else None
    return data if isinstance(data, dict) else None


def tr(field):
    """{'tr': '...', 'en': '...'} yapisindan tr'yi al."""
    if isinstance(field, dict):
        return field.get("tr") or field.get("en") or ""
    return field or ""


def extract_announcement(presentation):
    """presentation XBRL agacindan gercek aciklama metnini (HTML) cikar."""
    vals = []

    def walk(o):
        if isinstance(o, dict):
            v = o.get("value")
            if isinstance(v, str):
                vals.append(v)
            for x in o.values():
                walk(x)
        elif isinstance(o, list):
            for x in o:
                walk(x)

    walk(presentation)
    # HTML iceren deger(ler) = asil duyuru metni
    htmls = [v for v in vals if "<" in v and ">" in v]
    text = " ".join(htmls)
    text = re.sub(r"<[^>]+>", " ", text)        # etiketleri at
    text = text.replace("&nbsp;", " ")
    text = re.sub(r"\s+", " ", text)
    return clean(text)


def main():
    if not KAP_BASE_URL:
        sys.exit("HATA: KAP_BASE_URL bos.")
    if not DATABASE_URL:
        sys.exit("HATA: DATABASE_URL bos.")

    last = get_json("/lastDisclosureIndex")
    last_idx = int(str(last.get("lastDisclosureIndex")).strip())
    start = max(1, last_idx - FETCH_COUNT + 1)
    print(f"Bildirim detaylari cekiliyor: {start} -> {last_idx}")

    rows = []
    for idx in range(last_idx, start - 1, -1):
        try:
            d = fetch_detail(idx)
        except Exception as e:
            print(f"  idx {idx} atlandi: {e}")
            continue
        if not d:
            continue
        codes = d.get("senderExchCodes") or []
        symbol = (codes[0] if codes else "").strip().upper()
        if not symbol:
            continue  # borsa kodu yok (test/DDK kaydi) -> atla
        subject = clean(tr(d.get("subject")))
        summary = clean(tr(d.get("summary")))
        dtype = clean(d.get("disclosureType"))
        body = extract_announcement(d.get("presentation"))
        headline = summary or subject or dtype
        content = f"[{dtype}] {subject}. {summary}. {body}".strip()
        rows.append({
            "disclosure_index": str(d.get("disclosureIndex") or idx),
            "symbol": symbol,
            "headline": headline[:300],
            "content": content[:4000],
            "published_at": parse_dt(d.get("time")),
        })

    print(f"{len(rows)} gecerli bildirim ayiklandi. DB'ye yaziliyor...")

    conn = psycopg2.connect(DATABASE_URL)
    inserted = 0
    try:
        with conn, conn.cursor() as cur:
            for r in rows:
                cur.execute(
                    """
                    INSERT INTO kap_disclosures
                        (disclosure_index, symbol, headline, content,
                         published_at, is_processed)
                    VALUES (%(disclosure_index)s, %(symbol)s, %(headline)s,
                            %(content)s,
                            COALESCE(%(published_at)s::timestamptz, now()),
                            false)
                    ON CONFLICT (disclosure_index) DO NOTHING
                    """,
                    r,
                )
                inserted += cur.rowcount
    finally:
        conn.close()

    print(f"Bitti. {inserted} yeni kayit eklendi "
          f"({len(rows) - inserted} zaten vardi / atlandi).")


if __name__ == "__main__":
    main()
