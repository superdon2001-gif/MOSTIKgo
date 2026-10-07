-- Human profile: personal/professional data used by the account profile screen.
CREATE TABLE IF NOT EXISTS user_profiles (
  user_id text PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  about text,
  phone text,
  contact_note text,
  avatar_data text,
  trainer_specialization text,
  trainer_qualification text,
  trainer_experience text,
  vet_specialization text,
  vet_qualification text,
  vet_license text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
