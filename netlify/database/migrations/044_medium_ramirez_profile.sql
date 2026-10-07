-- Medium priority (Ramirez): species/individual profile, step type, observation↔skill
ALTER TABLE animals ADD COLUMN IF NOT EXISTS habitat_note text;
ALTER TABLE animals ADD COLUMN IF NOT EXISTS social_structure text;
ALTER TABLE animals ADD COLUMN IF NOT EXISTS diet_profile text;
ALTER TABLE animals ADD COLUMN IF NOT EXISTS prefers text;
ALTER TABLE animals ADD COLUMN IF NOT EXISTS avoids text;
ALTER TABLE animals ADD COLUMN IF NOT EXISTS human_experience text;

ALTER TABLE skill_steps ADD COLUMN IF NOT EXISTS step_type text; -- target | capture | shaping | model | mimic | other

ALTER TABLE observations ADD COLUMN IF NOT EXISTS skill_id text REFERENCES skills(id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS observations_skill_idx ON observations(skill_id) WHERE skill_id IS NOT NULL;
