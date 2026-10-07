-- MOSTIK v5.3.15 — anonymous-safe client/API error telemetry
CREATE TABLE IF NOT EXISTS error_events (
  id text PRIMARY KEY,
  fingerprint text UNIQUE NOT NULL,
  source text NOT NULL DEFAULT 'client',
  message text NOT NULL,
  stack text,
  url text,
  path text,
  method text,
  status integer,
  screen text,
  user_id text REFERENCES users(id) ON DELETE SET NULL,
  role text,
  user_agent text,
  ip text,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  first_seen timestamptz NOT NULL DEFAULT now(),
  last_seen timestamptz NOT NULL DEFAULT now(),
  count integer NOT NULL DEFAULT 1
);
CREATE INDEX IF NOT EXISTS error_events_last_seen_idx ON error_events(last_seen DESC);
CREATE INDEX IF NOT EXISTS error_events_source_idx ON error_events(source);
