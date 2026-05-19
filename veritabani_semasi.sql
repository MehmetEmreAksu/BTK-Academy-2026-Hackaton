
CREATE TABLE public.financial_news (
  id integer NOT NULL DEFAULT nextval('financial_news_id_seq'::regclass),
  symbol character varying,
  headline character varying,
  source_link text UNIQUE,
  content text,
  published_at timestamp without time zone,
  is_processed boolean DEFAULT false,
  is_vektored boolean DEFAULT false,
  CONSTRAINT financial_news_pkey PRIMARY KEY (id)
);

CREATE TABLE public.financial_tweets (
  tweet_id character varying NOT NULL,
  account_name character varying,
  tweet_text text,
  published_at timestamp without time zone,
  is_processed boolean DEFAULT false,
  is_vektored boolean DEFAULT false,
  symbol character varying,
  CONSTRAINT financial_tweets_pkey PRIMARY KEY (tweet_id)
);

CREATE TABLE public.kap_disclosures (
  id bigint NOT NULL DEFAULT nextval('kap_disclosures_id_seq'::regclass),
  disclosure_index character varying UNIQUE,
  symbol character varying,
  headline text,
  content text,
  published_at timestamp with time zone,
  is_processed boolean NOT NULL DEFAULT false,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  is_vektored boolean DEFAULT false,
  CONSTRAINT kap_disclosures_pkey PRIMARY KEY (id)
);

CREATE TABLE public.market_stocks (
  symbol character varying NOT NULL,
  company_name character varying,
  sector character varying,
  CONSTRAINT market_stocks_pkey PRIMARY KEY (symbol)
);

CREATE TABLE public.market_vectors (
  id bigint NOT NULL DEFAULT nextval('market_vectors_id_seq'::regclass),
  content text NOT NULL,
  metadata jsonb,
  embedding USER-DEFINED,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT market_vectors_pkey PRIMARY KEY (id)
);

CREATE TABLE public.risk_scores (
  id bigint NOT NULL DEFAULT nextval('risk_scores_id_seq'::regclass),
  symbol character varying,
  tweet_id character varying,
  news_id integer,
  risk_score integer,
  level text,
  reason text,
  source text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  credibility_score integer,
  kap_id bigint,
  CONSTRAINT risk_scores_pkey PRIMARY KEY (id),
  CONSTRAINT fk_risk_tweet FOREIGN KEY (tweet_id) REFERENCES public.financial_tweets(tweet_id),
  CONSTRAINT fk_risk_news FOREIGN KEY (news_id) REFERENCES public.financial_news(id),
  CONSTRAINT fk_risk_kap FOREIGN KEY (kap_id) REFERENCES public.kap_disclosures(id)
);

CREATE TABLE public.stocks (
  symbol character varying NOT NULL,
  current_price numeric,
  previous_close numeric,
  last_updated timestamp without time zone,
  CONSTRAINT stocks_pkey PRIMARY KEY (symbol),
  CONSTRAINT fk_market_stock FOREIGN KEY (symbol) REFERENCES public.market_stocks(symbol)
);

CREATE TABLE public.user_portfolios (
  id integer NOT NULL DEFAULT nextval('user_portfolios_id_seq'::regclass),
  user_id character varying,
  symbol character varying,
  added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT user_portfolios_pkey PRIMARY KEY (id),
  CONSTRAINT fk_portfolio_stock FOREIGN KEY (symbol) REFERENCES public.market_stocks(symbol),
  CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES public.users(user_id)
);

CREATE TABLE public.users (
  user_id character varying NOT NULL,
  email character varying NOT NULL,
  full_name character varying,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT users_pkey PRIMARY KEY (user_id)
);

DROP TRIGGER IF EXISTS on_portfolio_insert ON public.user_portfolios;
CREATE TRIGGER on_portfolio_insert
  AFTER INSERT ON public.user_portfolios
  FOR EACH ROW EXECUTE FUNCTION public.notify_n8n_new_stock();

CREATE INDEX IF NOT EXISTS idx_tweets_unprocessed 
ON public.financial_tweets(tweet_id) 
WHERE is_vektored = false OR is_processed = false;

CREATE INDEX IF NOT EXISTS idx_news_unprocessed 
ON public.financial_news(id) 
WHERE is_vektored = false OR is_processed = false;

CREATE INDEX IF NOT EXISTS idx_kap_unprocessed 
ON public.kap_disclosures(id) 
WHERE is_vektored = false OR is_processed = false;