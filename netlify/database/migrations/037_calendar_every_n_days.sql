-- MOSTIK: allow every N days for scheduled calendar items
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_constraint WHERE conname='scheduled_items_repeat_type_check') THEN
    ALTER TABLE scheduled_items DROP CONSTRAINT scheduled_items_repeat_type_check;
  END IF;
  ALTER TABLE scheduled_items ADD CONSTRAINT scheduled_items_repeat_type_check
    CHECK (repeat_type IN ('once','daily','weekly','monthly','every_n_days'));
EXCEPTION WHEN duplicate_object THEN
  NULL;
END $$;
