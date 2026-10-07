-- MOSTIK v5.3.17 — corrected herbivore/omnivore catalog
-- Do not edit migration 049: this migration adds/corrects catalog records.

-- Existing catalog entries that are reused by the herbivore/omnivore set.
-- Giraffe is represented by a concrete species rather than a genus-level label.
UPDATE animal_catalog
SET species='Сетчатый жираф',
    scientific_name='Giraffa reticulata',
    subspecies=ARRAY[]::text[]
WHERE id='zoo-giraffe';

-- Gorilla is kept at species level; subspecies are only those belonging to western gorilla.
UPDATE animal_catalog
SET species='Западная горилла',
    scientific_name='Gorilla gorilla',
    subspecies=ARRAY['западная равнинная горилла','кросс-риверская горилла']::text[]
WHERE id='zoo-gorilla';

-- Add the remaining corrected herbivore/omnivore entries.
INSERT INTO animal_catalog(id,category,species,scientific_name,subspecies,sort_order) VALUES
('zoo-african-elephant','zoo','Африканский слон','Loxodonta africana',ARRAY[]::text[],210),
('zoo-plains-zebra','zoo','Равнинная зебра','Equus quagga',ARRAY[]::text[],220),
('zoo-black-rhino','zoo','Чёрный носорог','Diceros bicornis',ARRAY[]::text[],230),
('zoo-hippopotamus','zoo','Бегемот','Hippopotamus amphibius',ARRAY[]::text[],240),
('zoo-okapi','zoo','Окапи','Okapia johnstoni',ARRAY[]::text[],250),
('zoo-blue-wildebeest','zoo','Голубой гну','Connochaetes taurinus',ARRAY[]::text[],260),
('zoo-greater-kudu','zoo','Большой куду','Tragelaphus strepsiceros',ARRAY[]::text[],270),
('zoo-impala','zoo','Импала','Aepyceros melampus',ARRAY[]::text[],280),
('zoo-thomsons-gazelle','zoo','Газель Томсона','Eudorcas thomsonii',ARRAY[]::text[],290),
('zoo-african-buffalo','zoo','Африканский буйвол','Syncerus caffer',ARRAY[]::text[],300),
('zoo-warthog','zoo','Бородавочник','Phacochoerus africanus',ARRAY[]::text[],310),
('zoo-anubis-baboon','zoo','Павиан анубис','Papio anubis',ARRAY[]::text[],330),
('zoo-red-river-hog-omnivore','zoo','Красная речная свинья','Potamochoerus porcus',ARRAY[]::text[],340),
('zoo-bushpig','zoo','Кистеухая свинья','Potamochoerus larvatus',ARRAY[]::text[],350)
ON CONFLICT (id) DO UPDATE SET
  category=EXCLUDED.category,
  species=EXCLUDED.species,
  scientific_name=EXCLUDED.scientific_name,
  subspecies=EXCLUDED.subspecies,
  sort_order=EXCLUDED.sort_order;

-- Keep the original red-river-hog catalog record, but correct its user-facing name.
UPDATE animal_catalog
SET species='Красная речная свинья', scientific_name='Potamochoerus porcus'
WHERE id='zoo-red-river-hog';

-- The original chimpanzee/ostrich records remain valid species-level records.
UPDATE animal_catalog
SET species='Шимпанзе', scientific_name='Pan troglodytes'
WHERE id='zoo-chimpanzee';
UPDATE animal_catalog
SET species='Африканский страус', scientific_name='Struthio camelus'
WHERE id='zoo-ostrich';
