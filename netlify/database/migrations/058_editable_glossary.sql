-- MOSTIK 5.3.38: editable per-user glossary
CREATE TABLE IF NOT EXISTS glossary_terms (
  id text PRIMARY KEY,
  user_id text NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  term text NOT NULL,
  abbreviation text NOT NULL DEFAULT '',
  description text NOT NULL DEFAULT '',
  category text NOT NULL DEFAULT 'Общее',
  source text NOT NULL DEFAULT '',
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS glossary_terms_user_term_unique ON glossary_terms(user_id, lower(term));
CREATE INDEX IF NOT EXISTS glossary_terms_user_active_idx ON glossary_terms(user_id, active, lower(term));
