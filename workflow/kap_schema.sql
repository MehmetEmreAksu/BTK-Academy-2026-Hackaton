-- ============================================================
-- KAP (Kamuyu Aydinlatma Platformu) entegrasyonu icin sema
-- ============================================================

-- Resmi KAP bildirimleri burada saklanir (gercek kaynagi).
-- W1 agent bunu tweet/haber ile karsilastirip credibility uretir.
CREATE TABLE IF NOT EXISTS kap_disclosures (
  id              BIGSERIAL PRIMARY KEY,
  disclosure_index VARCHAR(50) UNIQUE,   -- KAP'in kendi bildirim id'si (tekrar cekmeyi onler)
  symbol          VARCHAR(20),
  headline        TEXT,
  content         TEXT,
  published_at    TIMESTAMPTZ,
  is_processed    BOOLEAN NOT NULL DEFAULT false,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_kap_symbol ON kap_disclosures (symbol);
CREATE INDEX IF NOT EXISTS idx_kap_unprocessed
  ON kap_disclosures (is_processed) WHERE is_processed = false;

-- risk_scores'a gerceklik (credibility) skoru ekle.
-- 0-100: tweet/haber resmi KAP aciklamalariyla ne kadar ortusuyor.
ALTER TABLE risk_scores
  ADD COLUMN IF NOT EXISTS credibility_score INT;

-- Flutter okuyabilsin diye RLS kapali
ALTER TABLE kap_disclosures DISABLE ROW LEVEL SECURITY;
