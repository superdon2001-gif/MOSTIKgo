-- MOSTIK: optional end date for recurring reminders
ALTER TABLE reminders ADD COLUMN IF NOT EXISTS repeat_until date;
