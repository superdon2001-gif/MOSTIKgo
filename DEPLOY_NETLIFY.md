# MOSTIK: деплой на Netlify через GitHub

Версия кода: 5.3.27. Сайт = статика из `public/` + Netlify Functions из `netlify/functions/` + Netlify Database (Postgres).

## 1. GitHub

1. Создайте репозиторий (или откройте существующий) и загрузите **содержимое** этой папки в корень.
2. Не загружайте `.netlify/`, `data/`, `node_modules/`, `.env`. Они в `.gitignore`; если грузите через браузер, не перетаскивайте их.
3. Через git (рекомендуется):
   ```
   git clone https://github.com/<вы>/<репозиторий>.git
   cd <репозиторий>
   git rm -r -q .            # убрать старую версию (она останется в истории)
   # скопируйте сюда содержимое этой папки, включая файл .gitignore
   git add -A
   git commit -m "MOSTIK 5.3.27"
   git push
   ```

## 2. Netlify

1. **Add new site → Import an existing project** → GitHub → ваш репозиторий. Если сайт уже подключён к репозиторию, он соберётся сам после push.
2. Настройки берутся из `netlify.toml`: build `npm run build`, publish `public`, functions `netlify/functions`, Node 22.
3. `npm run build` копирует `app.js`, `app.css`, `sw.js` из корня в `public/` и проверяет, что всё на месте. Ошибка сборки значит, что чего-то не хватает, текст ошибки скажет чего.

## 3. База данных

1. В Netlify: сайт → **Database** → включить (Neon Postgres).
2. Применить миграции (все 53 файла из `netlify/database/migrations/` по порядку). Самый простой способ:
   ```
   npm install
   DATABASE_URL="<строка подключения из Netlify Database>" npm run db:migrate
   ```
   Скрипт ведёт журнал в таблице `_mostik_migrations`, повторный запуск применяет только новые файлы. Либо выполните файлы вручную в SQL Editor, по возрастанию имён.
3. **Демо-аккаунты.** Миграция `004_demo_seed.sql` создаёт `demo.*@mostik.local` с паролем `demo123` (он написан в документации). Для публичного сайта выполните один раз `docs/lock-demo-accounts.sql`: вход в них будет закрыт, ваши аккаунты не затрагиваются.
4. Данные из локальной версии (`data/pglite`) в Netlify сами не переносятся.

## 4. Переменные окружения (необязательно)

`RESEND_API_KEY`, `RESEND_FROM_EMAIL` нужны только для писем восстановления пароля. `DATABASE_URL` не нужна: Netlify Database подключается сам.

## 5. Проверка

- `https://<сайт>/api/health` должен вернуть `"ok": true`.
- Если «Ошибка базы данных»: база не включена или не применены миграции (шаг 3).

## Локально

- Встроенная база (PGlite): `START.bat` / `npm start` (см. `LOCAL_DEV.md`).
- Через Netlify CLI: `npx netlify dev`.
