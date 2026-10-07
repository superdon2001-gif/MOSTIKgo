-- MOSTIK v5.3.23: demo diet plans for testing GET /api/diets/active
-- Idempotent. Safe on production: only touches demo-* ids.

-- Active diet for Байкал (demo-animal-baikal) — owner + keeper can see
INSERT INTO diets(id, animal_id, name, description, active, target_calories, created_by)
VALUES (
  'demo-diet-baikal',
  'demo-animal-baikal',
  'Базовый рацион Байкала',
  'Демо-план питания для проверки /api/diets/active',
  true,
  1200,
  'demo-keeper'
)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  active = true,
  target_calories = EXCLUDED.target_calories,
  updated_at = now();

-- Deactivate any other active diets for this animal (except our demo)
UPDATE diets SET active = false
WHERE animal_id = 'demo-animal-baikal' AND id <> 'demo-diet-baikal' AND active = true;

-- Period: started 30 days ago, open-ended
INSERT INTO diet_periods(id, diet_id, animal_id, start_date, end_date)
VALUES (
  'demo-diet-period-baikal',
  'demo-diet-baikal',
  'demo-animal-baikal',
  (CURRENT_DATE - 30),
  NULL
)
ON CONFLICT (id) DO UPDATE SET
  start_date = EXCLUDED.start_date,
  end_date = NULL;

-- Day 0 meals (template day)
INSERT INTO diet_meals(id, diet_id, day_offset, time_of_day, title, sort_order) VALUES
('demo-meal-baikal-breakfast', 'demo-diet-baikal', 0, '08:00', 'Завтрак', 0),
('demo-meal-baikal-lunch',     'demo-diet-baikal', 0, '13:00', 'Обед', 1),
('demo-meal-baikal-dinner',    'demo-diet-baikal', 0, '19:00', 'Ужин', 2)
ON CONFLICT (id) DO UPDATE SET
  time_of_day = EXCLUDED.time_of_day,
  title = EXCLUDED.title,
  sort_order = EXCLUDED.sort_order;

-- Products
INSERT INTO diet_meal_products(id, meal_id, name, quantity, calories, sort_order) VALUES
('demo-prod-b1', 'demo-meal-baikal-breakfast', 'Сухой корм премиум', '150 г', 450, 0),
('demo-prod-b2', 'demo-meal-baikal-breakfast', 'Вода', 'свежая', NULL, 1),
('demo-prod-l1', 'demo-meal-baikal-lunch', 'Влажный корм', '100 г', 280, 0),
('demo-prod-d1', 'demo-meal-baikal-dinner', 'Сухой корм премиум', '120 г', 360, 0),
('demo-prod-d2', 'demo-meal-baikal-dinner', 'Лакомство тренировочное', '10 г', 40, 1)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  quantity = EXCLUDED.quantity,
  calories = EXCLUDED.calories,
  sort_order = EXCLUDED.sort_order;

-- Optional: light diet for Дымка (cat) — also active
INSERT INTO diets(id, animal_id, name, description, active, target_calories, created_by)
VALUES (
  'demo-diet-dymka',
  'demo-animal-dymka',
  'Рацион Дымки',
  'Демо-рацион кошки',
  true,
  250,
  'demo-owner2'
)
ON CONFLICT (id) DO UPDATE SET active = true, updated_at = now();

UPDATE diets SET active = false
WHERE animal_id = 'demo-animal-dymka' AND id <> 'demo-diet-dymka' AND active = true;

INSERT INTO diet_periods(id, diet_id, animal_id, start_date, end_date)
VALUES (
  'demo-diet-period-dymka',
  'demo-diet-dymka',
  'demo-animal-dymka',
  (CURRENT_DATE - 7),
  NULL
)
ON CONFLICT (id) DO UPDATE SET start_date = EXCLUDED.start_date, end_date = NULL;

INSERT INTO diet_meals(id, diet_id, day_offset, time_of_day, title, sort_order) VALUES
('demo-meal-dymka-am', 'demo-diet-dymka', 0, '07:30', 'Утро', 0),
('demo-meal-dymka-pm', 'demo-diet-dymka', 0, '18:30', 'Вечер', 1)
ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, time_of_day = EXCLUDED.time_of_day;

INSERT INTO diet_meal_products(id, meal_id, name, quantity, calories, sort_order) VALUES
('demo-prod-da1', 'demo-meal-dymka-am', 'Влажный корм для кошек', '80 г', 90, 0),
('demo-prod-dp1', 'demo-meal-dymka-pm', 'Сухой корм для кошек', '40 г', 120, 0)
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, quantity = EXCLUDED.quantity, calories = EXCLUDED.calories;
