-- MOSTIK v5.2.12 — schema repair: avatar_icon + animal_access uniqueness
-- Safe to re-run. Fixes "database error" when 026–028 were not applied.

ALTER TABLE animals ADD COLUMN IF NOT EXISTS avatar_icon text;
ALTER TABLE animals ALTER COLUMN avatar_icon SET DEFAULT '1';

UPDATE animals
SET avatar_icon = COALESCE(NULLIF(btrim(avatar_icon), ''), '1')
WHERE avatar_icon IS NULL OR btrim(avatar_icon) = '';

-- Keep icons in supported range 1..12 (unknown values get a stable hash bucket)
UPDATE animals
SET avatar_icon = (1 + (get_byte(decode(substr(md5(id),1,2),'hex'),0) % 12))::text
WHERE avatar_icon NOT IN ('1','2','3','4','5','6','7','8','9','10','11','12');

CREATE UNIQUE INDEX IF NOT EXISTS animal_access_user_animal_unique
ON animal_access(user_id, animal_id);
