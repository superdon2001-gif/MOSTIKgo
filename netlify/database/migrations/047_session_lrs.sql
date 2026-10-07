-- LRS / error handling on sessions (Ramirez: least reinforcing scenario, not punishment)
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS error_occurred boolean DEFAULT false;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS error_response text; -- none | ignore | lrs | timeout | reset_known
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS error_type text; -- criterion | signal | distraction | refusal | other
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS error_note text;
