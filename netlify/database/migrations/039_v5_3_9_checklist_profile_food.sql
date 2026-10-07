-- MOSTIK v5.3.9 checklist patch: animal profile fields and food units.
ALTER TABLE animals ADD COLUMN IF NOT EXISTS sex text;
ALTER TABLE animals ADD COLUMN IF NOT EXISTS birth_date date;
ALTER TABLE animals ADD COLUMN IF NOT EXISTS weight_kg numeric;
ALTER TABLE animals ADD COLUMN IF NOT EXISTS height_cm numeric;
ALTER TABLE animals ADD COLUMN IF NOT EXISTS description text;
ALTER TABLE food_logs ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();
