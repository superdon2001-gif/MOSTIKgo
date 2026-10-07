-- MOSTIK: multiple roles per user
CREATE TABLE IF NOT EXISTS user_roles (
  user_id text NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role text NOT NULL CHECK(role IN ('admin','owner','trainer','keeper','vet')),
  PRIMARY KEY(user_id, role)
);
INSERT INTO user_roles(user_id,role) SELECT id,role FROM users ON CONFLICT DO NOTHING;
ALTER TABLE sessions_auth ADD COLUMN IF NOT EXISTS active_role text;
CREATE INDEX IF NOT EXISTS user_roles_user_idx ON user_roles(user_id);
