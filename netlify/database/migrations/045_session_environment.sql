-- Session environment context (weather / microclimate)
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS env_place text;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS env_temp text;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS env_humidity text;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS env_pressure text;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS env_wind text;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS env_light text;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS env_conditions text;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS env_note text;
ALTER TABLE sessions ADD COLUMN IF NOT EXISTS env_source text;
