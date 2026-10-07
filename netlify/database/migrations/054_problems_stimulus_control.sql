-- MOSTIK: problem solving, aggression, skill stages and stimulus-control signals
ALTER TABLE skills ADD COLUMN IF NOT EXISTS training_stage text NOT NULL DEFAULT 'learning';
ALTER TABLE skills ADD COLUMN IF NOT EXISTS rule_immediate_reinforcement boolean NOT NULL DEFAULT false;
ALTER TABLE skills ADD COLUMN IF NOT EXISTS rule_one_signal_one_behavior boolean NOT NULL DEFAULT false;
ALTER TABLE skills ADD COLUMN IF NOT EXISTS rule_gradual_criteria boolean NOT NULL DEFAULT false;
ALTER TABLE skills ADD COLUMN IF NOT EXISTS rule_generalization boolean NOT NULL DEFAULT false;

CREATE TABLE IF NOT EXISTS behavior_problems (
  id text PRIMARY KEY,
  animal_id text NOT NULL REFERENCES animals(id) ON DELETE CASCADE,
  created_by text REFERENCES users(id) ON DELETE SET NULL,
  title text NOT NULL,
  status text NOT NULL DEFAULT 'active',
  frequency text,
  context text,
  what_happens text,
  cause_type text,
  cause_note text,
  method text,
  plan text,
  start_date date,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS behavior_problems_animal_idx ON behavior_problems(animal_id, status, updated_at DESC);

CREATE TABLE IF NOT EXISTS behavior_problem_weeks (
  id text PRIMARY KEY,
  problem_id text NOT NULL REFERENCES behavior_problems(id) ON DELETE CASCADE,
  week_start date NOT NULL,
  measure text,
  result text,
  note text,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(problem_id, week_start)
);
CREATE INDEX IF NOT EXISTS behavior_problem_weeks_problem_idx ON behavior_problem_weeks(problem_id, week_start);

CREATE TABLE IF NOT EXISTS aggression_profiles (
  problem_id text PRIMARY KEY REFERENCES behavior_problems(id) ON DELETE CASCADE,
  aggression_type text,
  antecedents text,
  warning_signs text,
  extinction_burst_warning boolean NOT NULL DEFAULT true,
  physical_cause boolean NOT NULL DEFAULT false,
  vet_recommended boolean NOT NULL DEFAULT false,
  note text
);

CREATE TABLE IF NOT EXISTS animal_signals (
  id text PRIMARY KEY,
  animal_id text NOT NULL REFERENCES animals(id) ON DELETE CASCADE,
  name text NOT NULL,
  signal_type text NOT NULL DEFAULT 'other',
  meaning text,
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(animal_id, name)
);
CREATE INDEX IF NOT EXISTS animal_signals_animal_idx ON animal_signals(animal_id, active, name);
