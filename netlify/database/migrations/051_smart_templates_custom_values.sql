-- MOSTIK Smart Templates + flexible user-defined dictionary values.
-- Never edit previous applied migrations.
CREATE TABLE IF NOT EXISTS smart_templates (
  id text PRIMARY KEY,
  section text NOT NULL,
  name text NOT NULL,
  description text NOT NULL DEFAULT '',
  species text,
  payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_by text REFERENCES users(id) ON DELETE SET NULL,
  visibility text NOT NULL DEFAULT 'personal' CHECK (visibility IN ('personal','organization','official')),
  approved boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_smart_templates_section_species ON smart_templates(section, species, visibility, approved);

CREATE TABLE IF NOT EXISTS smart_custom_values (
  id text PRIMARY KEY,
  section text NOT NULL,
  field text NOT NULL,
  value_text text NOT NULL,
  normalized_value text NOT NULL,
  species text,
  subspecies text,
  animal_id text,
  user_id text REFERENCES users(id) ON DELETE SET NULL,
  status text NOT NULL DEFAULT 'unverified' CHECK (status IN ('unverified','suggested','official','rejected')),
  usage_count integer NOT NULL DEFAULT 1,
  first_used_at timestamptz NOT NULL DEFAULT now(),
  last_used_at timestamptz NOT NULL DEFAULT now(),
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  UNIQUE(section,field,normalized_value,user_id)
);
CREATE INDEX IF NOT EXISTS idx_smart_custom_values_lookup ON smart_custom_values(section,field,species,status,usage_count DESC);
CREATE INDEX IF NOT EXISTS idx_smart_custom_values_review ON smart_custom_values(status,last_used_at DESC);
