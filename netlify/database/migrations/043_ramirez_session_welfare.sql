-- Ramirez Ch.1–4 high priority: session welfare goal, plan/summary, bridge & reinforcement used
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS welfare_goal text;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS plan_note text;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS summary_note text;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS bridge_used text;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS primary_reinforcement text;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS secondary_reinforcement text;
-- Optional clarity flag on skill step criterion ("black and white")
ALTER TABLE skill_steps ADD COLUMN IF NOT EXISTS criterion_met boolean;
COMMENT ON COLUMN sessions.welfare_goal IS 'physical | mental | cooperation — primary welfare reason for the session';
COMMENT ON COLUMN sessions.plan_note IS 'Trainer plan before session start';
COMMENT ON COLUMN sessions.summary_note IS 'Session debrief / next step';
COMMENT ON COLUMN sessions.bridge_used IS 'Intermediate stimulus used (clicker, whistle, word, touch)';
COMMENT ON COLUMN sessions.primary_reinforcement IS 'Primary reinforcer used';
COMMENT ON COLUMN sessions.secondary_reinforcement IS 'Secondary reinforcer used';
