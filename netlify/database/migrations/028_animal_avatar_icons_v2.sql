-- MOSTIK v5.2.5 — new animal avatar icon set (12 icons)
-- Re-normalize any out-of-range avatar_icon values to 1..12.
UPDATE animals
SET avatar_icon = (1 + (get_byte(decode(substr(md5(id),1,2),'hex'),0) % 12))::text
WHERE avatar_icon IS NULL
   OR avatar_icon NOT IN ('1','2','3','4','5','6','7','8','9','10','11','12');
