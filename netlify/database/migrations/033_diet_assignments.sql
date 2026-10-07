-- MOSTIK: explicit target calories on diet plans
ALTER TABLE diets ADD COLUMN IF NOT EXISTS target_calories numeric;
