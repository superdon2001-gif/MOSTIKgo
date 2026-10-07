-- MOSTIK: recurring calendar schedules and occurrence completion history
ALTER TABLE scheduled_items ADD COLUMN IF NOT EXISTS repeat_type text NOT NULL DEFAULT 'once';
ALTER TABLE scheduled_items ADD COLUMN IF NOT EXISTS repeat_every integer NOT NULL DEFAULT 1;
ALTER TABLE scheduled_items ADD COLUMN IF NOT EXISTS repeat_until date;
ALTER TABLE scheduled_items ADD COLUMN IF NOT EXISTS repeat_days text;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname='scheduled_items_repeat_type_check') THEN
    ALTER TABLE scheduled_items ADD CONSTRAINT scheduled_items_repeat_type_check
      CHECK (repeat_type IN ('once','daily','weekly','monthly'));
  END IF;
END $$;
CREATE TABLE IF NOT EXISTS scheduled_completions (
  id text PRIMARY KEY,
  scheduled_item_id text NOT NULL REFERENCES scheduled_items(id) ON DELETE CASCADE,
  occurrence_at timestamptz NOT NULL,
  completed_at timestamptz NOT NULL DEFAULT now(),
  completed_by text REFERENCES users(id),
  UNIQUE(scheduled_item_id, occurrence_at)
);
CREATE INDEX IF NOT EXISTS scheduled_completions_item_idx ON scheduled_completions(scheduled_item_id, occurrence_at);
