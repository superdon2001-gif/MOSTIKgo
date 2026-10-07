-- MOSTIK v5.3.11: observation management and analytics support.
ALTER TABLE observations ADD COLUMN IF NOT EXISTS activity integer;
CREATE INDEX IF NOT EXISTS observations_animal_observed_idx ON observations(animal_id, observed_at DESC);
CREATE INDEX IF NOT EXISTS observations_behavior_category_idx ON observations(animal_id, behavior_category);
