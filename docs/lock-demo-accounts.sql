-- Блокирует вход в демо-аккаунты (demo.*@mostik.local, пароль demo123 написан в документации).
-- Данные демо остаются в базе, войти в них нельзя. Ваши аккаунты не затрагиваются.
-- Безопасно запускать повторно. Выполнить один раз в SQL Editor после применения миграций.
WITH locked AS (
  UPDATE users
     SET password_hash = 'LOCKED', recovery_code_hash = NULL
   WHERE lower(email) LIKE 'demo.%@mostik.local'
   RETURNING id
)
DELETE FROM sessions_auth WHERE user_id IN (SELECT id FROM locked);
