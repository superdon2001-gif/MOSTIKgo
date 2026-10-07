-- MOSTIK v5.3.16 — animal catalog and keeper subspecies
ALTER TABLE animals ADD COLUMN IF NOT EXISTS subspecies text;

CREATE TABLE IF NOT EXISTS animal_catalog (
  id text PRIMARY KEY,
  category text NOT NULL CHECK (category IN ('zoo','domestic')),
  species text NOT NULL,
  scientific_name text,
  subspecies text[] NOT NULL DEFAULT '{}',
  sort_order integer NOT NULL DEFAULT 100
);

CREATE INDEX IF NOT EXISTS animal_catalog_category_idx ON animal_catalog(category, sort_order, species);
CREATE INDEX IF NOT EXISTS animal_catalog_species_idx ON animal_catalog(species);

INSERT INTO animal_catalog(id,category,species,scientific_name,subspecies,sort_order) VALUES
('zoo-meerkat','zoo','Сурикат','Suricata suricatta',ARRAY[]::text[],10),
('zoo-ring-tailed-lemur','zoo','Лемур кошачий','Lemur catta',ARRAY[]::text[],20),
('zoo-red-panda','zoo','Малая панда','Ailurus fulgens',ARRAY[]::text[],30),
('zoo-asian-elephant','zoo','Слон азиатский','Elephas maximus',ARRAY['индийский слон','шри-ланкийский слон','суматранский слон']::text[],40),
('zoo-lion','zoo','Лев','Panthera leo',ARRAY['азиатский лев','северный лев','южный лев']::text[],50),
('zoo-tiger','zoo','Тигр','Panthera tigris',ARRAY['амурский тигр','бенгальский тигр','индо-китайский тигр','малайский тигр','суматранский тигр']::text[],60),
('zoo-capybara','zoo','Капибара','Hydrochoerus hydrochaeris',ARRAY[]::text[],70),
('zoo-small-clawed-otter','zoo','Выдра восточная бескоготная','Amblonyx cinereus',ARRAY[]::text[],80),
('zoo-gorilla','zoo','Горилла','Gorilla gorilla',ARRAY['западная равнинная горилла','восточная равнинная горилла','горная горилла']::text[],90),
('zoo-two-toed-sloth','zoo','Двупалый ленивец','Choloepus didactylus',ARRAY[]::text[],100),
('zoo-white-rhino','zoo','Белый носорог','Ceratotherium simum',ARRAY['южный белый носорог','северный белый носорог']::text[],110),
('zoo-bactrian-camel','zoo','Верблюд двугорбый','Camelus bactrianus',ARRAY['домашний двугорбый верблюд','дикий двугорбый верблюд']::text[],120),
('zoo-california-sea-lion','zoo','Калифорнийский морской лев','Zalophus californianus',ARRAY[]::text[],130),
('zoo-humboldt-penguin','zoo','Пингвин Гумбольдта','Spheniscus humboldti',ARRAY[]::text[],140),
('zoo-giraffe','zoo','Жираф','Giraffa camelopardalis',ARRAY['нубийский жираф','сетчатый жираф','масайский жираф','кордофанский жираф','южный жираф']::text[],150),
('zoo-african-penguin','zoo','Африканский пингвин','Spheniscus demersus',ARRAY[]::text[],160),
('zoo-chimpanzee','zoo','Шимпанзе','Pan troglodytes',ARRAY['западный шимпанзе','центральноафриканский шимпанзе','нигеро-камерунский шимпанзе','восточный шимпанзе']::text[],170),
('zoo-ostrich','zoo','Страус африканский','Struthio camelus',ARRAY['североафриканский страус','масайский страус','южный страус','сомалийский страус']::text[],180),
('zoo-prairie-dog','zoo','Луговая собачка чернохвостая','Cynomys ludovicianus',ARRAY[]::text[],190),
('zoo-red-river-hog','zoo','Кистеухая свинья','Potamochoerus porcus',ARRAY[]::text[],200),
('domestic-dog','domestic','Собака','Canis lupus familiaris',ARRAY[]::text[],10),
('domestic-cat','domestic','Кошка','Felis catus',ARRAY[]::text[],20),
('domestic-rabbit','domestic','Кролик','Oryctolagus cuniculus domesticus',ARRAY[]::text[],30),
('domestic-guinea-pig','domestic','Морская свинка','Cavia porcellus',ARRAY[]::text[],40),
('domestic-hamster','domestic','Хомяк','Cricetinae',ARRAY[]::text[],50),
('domestic-horse','domestic','Лошадь','Equus caballus',ARRAY[]::text[],60),
('domestic-chicken','domestic','Курица домашняя','Gallus gallus domesticus',ARRAY[]::text[],70),
('domestic-budgerigar','domestic','Волнистый попугай','Melopsittacus undulatus',ARRAY[]::text[],80),
('domestic-parrot','domestic','Попугай','Psittaciformes',ARRAY[]::text[],90),
('domestic-tortoise','domestic','Черепаха домашняя','Testudines',ARRAY[]::text[],100)
ON CONFLICT (id) DO UPDATE SET
  category=EXCLUDED.category,
  species=EXCLUDED.species,
  scientific_name=EXCLUDED.scientific_name,
  subspecies=EXCLUDED.subspecies,
  sort_order=EXCLUDED.sort_order;
