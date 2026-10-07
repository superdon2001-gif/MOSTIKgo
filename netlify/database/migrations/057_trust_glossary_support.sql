-- MOSTIK 5.3.36: trust/contact data for training sessions
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS contact_type text DEFAULT 'protected';
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS trust_score integer;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='sessions_trust_score_check') THEN
    ALTER TABLE sessions ADD CONSTRAINT sessions_trust_score_check CHECK (trust_score IS NULL OR trust_score BETWEEN 1 AND 5);
  END IF;
END $$;
COMMENT ON COLUMN sessions.contact_type IS 'protected | free';
COMMENT ON COLUMN sessions.trust_score IS 'Trainer assessment of trust/contact quality for this session, 1-5';
