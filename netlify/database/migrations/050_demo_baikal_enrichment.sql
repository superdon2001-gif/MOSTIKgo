-- MOSTIK v5.4.0 demo enrichment for Байкал.
-- Idempotent and limited to the existing demo animal. Safe for real user data.
-- Adds a visible nutrition plan and more varied nutrition records so the Journal,
-- Diet and Analytics screens are useful immediately after demo login.

INSERT INTO diets(id,animal_id,name,description,active,target_calories,created_by)
VALUES (
  'demo-diet-baikal',
  'demo-animal-baikal',
  'Базовый рацион Байкала',
  'Сбалансированный демонстрационный план: два основных приёма пищи и небольшой дневной перекус. Количество можно корректировать по фактическому аппетиту и активности.',
  true, 1350, 'demo-owner'
)
ON CONFLICT (id) DO UPDATE SET
  name=EXCLUDED.name,
  description=EXCLUDED.description,
  active=EXCLUDED.active,
  target_calories=EXCLUDED.target_calories,
  updated_at=now();

INSERT INTO diet_periods(id,diet_id,animal_id,start_date,end_date)
VALUES ('demo-diet-period-baikal','demo-diet-baikal','demo-animal-baikal',current_date-30,NULL)
ON CONFLICT (id) DO NOTHING;

INSERT INTO diet_meals(id,diet_id,day_offset,time_of_day,title,sort_order)
VALUES
 ('demo-diet-meal-baikal-am','demo-diet-baikal',0,'08:00','Утренний приём пищи',1),
 ('demo-diet-meal-baikal-pm','demo-diet-baikal',0,'18:30','Вечерний приём пищи',2),
 ('demo-diet-meal-baikal-snack','demo-diet-baikal',0,'14:00','Небольшой перекус',3)
ON CONFLICT (id) DO NOTHING;

INSERT INTO diet_meal_products(id,meal_id,name,quantity,calories,sort_order)
VALUES
 ('demo-diet-prod-baikal-am-food','demo-diet-meal-baikal-am','Полнорационный корм для собак','180 г',720,1),
 ('demo-diet-prod-baikal-am-veg','demo-diet-meal-baikal-am','Овощи','50 г',25,2),
 ('demo-diet-prod-baikal-pm-food','demo-diet-meal-baikal-pm','Полнорационный корм для собак','150 г',600,1),
 ('demo-diet-prod-baikal-pm-veg','demo-diet-meal-baikal-pm','Овощи','30 г',15,2),
 ('demo-diet-prod-baikal-snack','demo-diet-meal-baikal-snack','Небольшое лакомство','до 20 г',60,1)
ON CONFLICT (id) DO NOTHING;

-- Link recent demo food logs to planned meals and give them realistic products.
UPDATE food_logs
SET diet_meal_id=CASE WHEN EXTRACT(HOUR FROM logged_at)<14 THEN 'demo-diet-meal-baikal-am' ELSE 'demo-diet-meal-baikal-pm' END,
    planned=true,
    products=CASE WHEN EXTRACT(HOUR FROM logged_at)<14
      THEN '[{"name":"Полнорационный корм для собак","quantity":"180 г","calories":720},{"name":"Овощи","quantity":"50 г","calories":25}]'::jsonb
      ELSE '[{"name":"Полнорационный корм для собак","quantity":"150 г","calories":600},{"name":"Овощи","quantity":"30 г","calories":15}]'::jsonb
    END,
    offered=CASE WHEN EXTRACT(HOUR FROM logged_at)<14 THEN 'Корм 180 г + овощи 50 г' ELSE 'Корм 150 г + овощи 30 г' END,
    note='Демо-запись: фактическое потребление сопоставлено с планом питания.'
WHERE animal_id='demo-animal-baikal'
  AND id LIKE 'demo-food-%';

-- A few dated observations dedicated to Байкал make trends readable in Analytics.
INSERT INTO observations(id,animal_id,author_id,observed_at,behavior_note,health_note,arousal,stress,concentration,appetite,pain,sleep,note)
VALUES
 ('demo-baikal-obs-31','demo-animal-baikal','demo-owner',now()-interval '18 days','Спокоен на прогулке, быстро переключается на проводника.','Без заметных изменений.',3,2,4,4,1,4,'Демо: после умеренной прогулки.'),
 ('demo-baikal-obs-32','demo-animal-baikal','demo-keeper',now()-interval '11 days','Интересуется новыми предметами, охотно исследует обогащение среды.','Аппетит и общее состояние обычные.',3,1,4,5,1,4,'Демо: хорошо включается в исследовательскую активность.'),
 ('demo-baikal-obs-33','demo-animal-baikal','demo-trainer',now()-interval '4 days','Уверенно выполняет знакомые сигналы, выдержка стала стабильнее.','Без заметных изменений.',2,1,5,4,1,5,'Демо: прогресс по навыкам «Сидеть» и «Место».')
ON CONFLICT (id) DO NOTHING;

-- One more completed training session for a visible recent trend.
INSERT INTO sessions(id,animal_id,trainer_id,started_at,ended_at,duration_minutes,ending_type,ending_other,success_score,external_stimulus,external_reason,internal_stimulus,internal_reason,concentration,arousal)
VALUES
 ('demo-baikal-session-13','demo-animal-baikal','demo-trainer',now()-interval '4 days',now()-interval '4 days'+interval '24 minutes',24,'джекпот','',9,'низкий','Домашняя спокойная обстановка','низкий','Хорошая мотивация',5,2)
ON CONFLICT (id) DO NOTHING;

INSERT INTO session_skills(session_id,skill_id,repetitions)
VALUES ('demo-baikal-session-13','demo-skill-baikal-sit',8),
       ('demo-baikal-session-13','demo-skill-baikal-place',6)
ON CONFLICT DO NOTHING;
