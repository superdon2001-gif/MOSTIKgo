-- MOSTIK: reinforcement schedules, skill chains, care/desensitization ladders.
-- New entities only; existing skill_steps.reinforcement_schedule is reused.
ALTER TABLE skill_steps ADD COLUMN IF NOT EXISTS reinforcement_schedule text;
UPDATE skill_steps SET reinforcement_schedule='CRF' WHERE reinforcement_schedule='постоянный' OR reinforcement_schedule IS NULL;
UPDATE skill_steps SET reinforcement_schedule='VR' WHERE reinforcement_schedule='переменный';

CREATE TABLE IF NOT EXISTS skill_chains (
  id text PRIMARY KEY,
  animal_id text NOT NULL REFERENCES animals(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text NOT NULL DEFAULT '',
  created_by text REFERENCES users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS skill_chain_steps (
  id text PRIMARY KEY,
  chain_id text NOT NULL REFERENCES skill_chains(id) ON DELETE CASCADE,
  skill_id text NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
  step_no integer NOT NULL,
  repetitions integer NOT NULL DEFAULT 1,
  note text NOT NULL DEFAULT '',
  UNIQUE(chain_id, step_no)
);
CREATE INDEX IF NOT EXISTS idx_skill_chains_animal ON skill_chains(animal_id, updated_at DESC);

CREATE TABLE IF NOT EXISTS desensitization_plans (
  id text PRIMARY KEY,
  animal_id text NOT NULL REFERENCES animals(id) ON DELETE CASCADE,
  name text NOT NULL,
  procedure text NOT NULL DEFAULT '',
  template_id text,
  status text NOT NULL DEFAULT 'active' CHECK(status IN ('draft','active','completed','paused')),
  created_by text REFERENCES users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE IF NOT EXISTS desensitization_steps (
  id text PRIMARY KEY,
  plan_id text NOT NULL REFERENCES desensitization_plans(id) ON DELETE CASCADE,
  step_no integer NOT NULL,
  title text NOT NULL,
  description text NOT NULL DEFAULT '',
  comfort_level integer CHECK(comfort_level BETWEEN 1 AND 5),
  target_comfort integer CHECK(target_comfort BETWEEN 1 AND 5),
  duration_seconds integer,
  criterion text NOT NULL DEFAULT '',
  completed boolean NOT NULL DEFAULT false,
  UNIQUE(plan_id, step_no)
);
CREATE INDEX IF NOT EXISTS idx_desensitization_plans_animal ON desensitization_plans(animal_id, updated_at DESC);

-- Official starter templates for the existing MOSTIK Smart Templates mechanism.
INSERT INTO smart_templates(id,section,name,description,payload,visibility,approved)
VALUES
('official-care-body-check','care','Осмотр тела','Постепенный спокойный осмотр тела с контролем комфорта.', '{"procedure":"Осмотр тела","steps":[{"title":"Показать оборудование","description":"Показать предмет на расстоянии, подкрепить спокойствие","comfort_level":5,"target_comfort":5,"criterion":"Животное остаётся спокойным"},{"title":"Короткое касание","description":"Коснуться нейтральной зоны и сразу отпустить","comfort_level":4,"target_comfort":5,"criterion":"Спокойно принимает касание"},{"title":"Осмотр зоны","description":"Короткий осмотр одной зоны, затем пауза","comfort_level":4,"target_comfort":5,"criterion":"Сохраняет комфорт"}]}' , 'official', true),
('official-care-mouth-head','care','Рот и голова','Десенсибилизация к осмотру головы и рта.', '{"procedure":"Рот и голова","steps":[{"title":"Рука рядом с головой","description":"Приближение без фиксации","comfort_level":5,"target_comfort":5,"criterion":"Нет избегания"},{"title":"Касание головы","description":"Короткое касание и подкрепление","comfort_level":4,"target_comfort":5,"criterion":"Спокойное принятие"},{"title":"Коротко открыть рот","description":"Минимальное открытие без давления","comfort_level":3,"target_comfort":4,"criterion":"Сохраняет контакт"}]}' , 'official', true),
('official-care-blood-one-puncture','care','Анализ крови · один укол','Тренировочная лестница перед забором крови с правилом одного укола.', '{"procedure":"Анализ крови — один укол","steps":[{"title":"Станция и оборудование","description":"Спокойное присутствие станции и оборудования","comfort_level":5,"target_comfort":5,"criterion":"Спокойное ожидание"},{"title":"Прикосновение к месту забора","description":"Короткое касание без прокола","comfort_level":4,"target_comfort":5,"criterion":"Не отводит конечность"},{"title":"Имитация процедуры","description":"Подготовка без иглы","comfort_level":4,"target_comfort":5,"criterion":"Спокойно выдерживает"},{"title":"Один укол","description":"Один запланированный укол; при необходимости остановиться и вернуться на комфортный уровень","comfort_level":3,"target_comfort":4,"criterion":"Один успешный укол"}]}' , 'official', true),
('official-care-transfer','care','Перемещение','Постепенное привыкание к перемещению между зонами.', '{"procedure":"Перемещение","steps":[{"title":"Подойти к переходу","description":"Без требования пройти","comfort_level":5,"target_comfort":5,"criterion":"Спокойный подход"},{"title":"Один шаг","description":"Добровольный шаг через границу","comfort_level":4,"target_comfort":5,"criterion":"Шаг без принуждения"},{"title":"Полный переход","description":"Переход с подкреплением","comfort_level":4,"target_comfort":5,"criterion":"Спокойно проходит"}]}' , 'official', true),
('official-care-station','care','Станция','Формирование спокойного поведения на станции.', '{"procedure":"Станция","steps":[{"title":"Подойти к станции","description":"Заинтересоваться станцией","comfort_level":5,"target_comfort":5,"criterion":"Добровольный подход"},{"title":"Занять станцию","description":"Коротко оставаться на станции","comfort_level":4,"target_comfort":5,"criterion":"Остаётся до сигнала освобождения"},{"title":"Выдержка","description":"Постепенно увеличивать длительность","comfort_level":4,"target_comfort":5,"criterion":"Стабильная выдержка"}]}' , 'official', true),
('official-care-gate','care','Ворота','Десенсибилизация к воротам и проходу через них.', '{"procedure":"Ворота","steps":[{"title":"Ворота рядом","description":"Спокойное присутствие закрытых ворот","comfort_level":5,"target_comfort":5,"criterion":"Нет напряжения"},{"title":"Движение ворот","description":"Медленно открыть/закрыть на малую амплитуду","comfort_level":4,"target_comfort":5,"criterion":"Сохраняет комфорт"},{"title":"Проход","description":"Добровольный проход через ворота","comfort_level":4,"target_comfort":5,"criterion":"Спокойный переход"}]}' , 'official', true)
ON CONFLICT(id) DO NOTHING;
