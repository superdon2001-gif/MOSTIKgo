-- MOSTIK: structured observation / ethogram fields
ALTER TABLE observations ADD COLUMN IF NOT EXISTS behavior_category text;
ALTER TABLE observations ADD COLUMN IF NOT EXISTS behavior_action text;
ALTER TABLE observations ADD COLUMN IF NOT EXISTS state_signs text;
ALTER TABLE observations ADD COLUMN IF NOT EXISTS interaction_target text;
