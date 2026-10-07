-- MOSTIK: optional microchip number. It is intentionally NOT unique.
ALTER TABLE animals ADD COLUMN IF NOT EXISTS microchip text;
