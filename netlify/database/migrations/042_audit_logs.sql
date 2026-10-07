-- Audit trail for sensitive actions (login, access changes, clinical writes)
CREATE TABLE IF NOT EXISTS audit_logs (
  id text PRIMARY KEY,
  at timestamptz NOT NULL DEFAULT now(),
  actor_id text,
  actor_email text,
  action text NOT NULL,
  entity_type text,
  entity_id text,
  animal_id text,
  ip text,
  meta jsonb DEFAULT '{}'::jsonb
);
CREATE INDEX IF NOT EXISTS audit_logs_at_idx ON audit_logs(at DESC);
CREATE INDEX IF NOT EXISTS audit_logs_actor_idx ON audit_logs(actor_id, at DESC);
CREATE INDEX IF NOT EXISTS audit_logs_animal_idx ON audit_logs(animal_id, at DESC);
