-- MOSTIK 5.3.2: add activity score for unified welfare analytics
ALTER TABLE observations ADD COLUMN IF NOT EXISTS activity integer;
