-- Per-animal reinforcer library (Ramirez: primary / secondary)
CREATE TABLE IF NOT EXISTS animal_reinforcers (
  id text PRIMARY KEY,
  animal_id text NOT NULL REFERENCES animals(id) ON DELETE CASCADE,
  name text NOT NULL,
  kind text NOT NULL DEFAULT 'primary' CHECK (kind IN ('primary','secondary','either')),
  notes text,
  active boolean NOT NULL DEFAULT true,
  sort_order integer NOT NULL DEFAULT 0,
  use_count integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS animal_reinforcers_animal_idx
  ON animal_reinforcers(animal_id, active, sort_order, name);
