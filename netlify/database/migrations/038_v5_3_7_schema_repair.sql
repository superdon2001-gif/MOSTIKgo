-- MOSTIK v5.3.7: production schema repair for animal profiles and reminders.
-- Safe/idempotent: only creates missing tables/indexes or adds missing columns.

ALTER TABLE animals ADD COLUMN IF NOT EXISTS avatar_icon text;
ALTER TABLE animals ADD COLUMN IF NOT EXISTS microchip text;
ALTER TABLE animals ADD COLUMN IF NOT EXISTS photo_data text;
ALTER TABLE animals ALTER COLUMN avatar_icon SET DEFAULT '1';

CREATE TABLE IF NOT EXISTS animal_attention (
  id text PRIMARY KEY,
  animal_id text NOT NULL REFERENCES animals(id) ON DELETE CASCADE,
  category text NOT NULL DEFAULT 'Другое',
  title text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS animal_attention_animal_title_unique ON animal_attention(animal_id,title);
CREATE INDEX IF NOT EXISTS animal_attention_animal_idx ON animal_attention(animal_id,title);

ALTER TABLE reminders ADD COLUMN IF NOT EXISTS repeat_days text;
ALTER TABLE reminders ADD COLUMN IF NOT EXISTS every_n_days integer;
ALTER TABLE reminders ADD COLUMN IF NOT EXISTS repeat_until date;
ALTER TABLE reminders ADD COLUMN IF NOT EXISTS completed_at timestamptz;
ALTER TABLE reminders ADD COLUMN IF NOT EXISTS source_type text;
ALTER TABLE reminders ADD COLUMN IF NOT EXISTS source_id text;
ALTER TABLE reminders ADD COLUMN IF NOT EXISTS created_at timestamptz NOT NULL DEFAULT now();
ALTER TABLE reminders ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname='reminders_repeat_type_check') THEN
    ALTER TABLE reminders DROP CONSTRAINT reminders_repeat_type_check;
  END IF;
  ALTER TABLE reminders ADD CONSTRAINT reminders_repeat_type_check
    CHECK (repeat_type IN ('once','daily','weekly','monthly','every_n_days'));
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

CREATE INDEX IF NOT EXISTS reminders_enabled_time_idx ON reminders(enabled,remind_at);
