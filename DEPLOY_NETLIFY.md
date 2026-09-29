# MOSTIK — деплой на Netlify

## Быстрый старт (GitHub + Netlify)

1. Распакуйте архив. В корне должны лежать `netlify.toml`, `package.json`, папки `public/` и `netlify/`.
2. Создайте репозиторий на GitHub и загрузите **содержимое** этой папки в корень (не саму папку M-main).
3. В Netlify: **Add new site → Import an existing project** → выберите репозиторий и ветку `main`.
4. Настройки сборки уже в `netlify.toml`:
   - **Publish directory**: `public`
   - **Build command**: `npm run build`
   - **Functions directory**: `netlify/functions`
   - Node 20
5. Нажмите Deploy. После первого деплоя сайт будет доступен.

## База данных (обязательно)

Проект использует **Netlify Database** (Neon Postgres).

1. В панели Netlify откройте сайт → **Database** (или Project configuration → Database).
2. Создайте / подключите базу (кнопка Enable / Create database).
3. Примените миграции. Варианты:
   - **Через Netlify CLI** (рекомендуется локально):
     ```bash
     npm i -g netlify-cli
     netlify login
     netlify link          # выберите сайт
     # затем примените SQL-файлы из netlify/database/migrations/ по порядку (001 → 042)
     ```
   - Или откройте SQL Editor в Netlify/Neon и выполните файлы `001_init.sql` … `042_audit_logs.sql` последовательно.
4. Демо-данные (пользователи `demo.*@mostik.local` / пароль `demo123`) находятся в `004_demo_seed.sql`.  
   После применения миграций демо-аккаунты появятся автоматически (скрипт идемпотентный).

> Не удаляйте и не переименовывайте уже применённые миграции.

## Переменные окружения

**Project configuration → Environment variables**:

| Переменная          | Зачем                                      | Обязательно |
|---------------------|--------------------------------------------|-------------|
| `RESEND_API_KEY`    | Отправка писем восстановления пароля       | Нет (только если нужен reset) |
| `RESEND_FROM_EMAIL` | Адрес отправителя (например `noreply@...`) | Нет         |

`DATABASE_URL` **не нужна** — Netlify Database подключается автоматически через `@netlify/database`.

После добавления переменных сделайте **Trigger deploy**.

## Проверка после деплоя

- Откройте `/api/health` — должен вернуть `{ "ok": true, ... }`
- Логин: `demo.owner@mostik.local` / `demo123` (и остальные demo.* роли)
- Если животных нет — убедитесь, что миграция `004_demo_seed.sql` применена.

## Локальная разработка

```bash
npm install
npx netlify dev
```

`run.bat` (Windows) делает то же самое и может применять миграции.

## Важно

- Не коммитьте `.env`, `.netlify/`, `node_modules/`.
- Не коммитьте реальные секреты.
- SPA-редирект (`/* → /index.html`) и API (`/api/* → functions`) уже настроены.
- После изменений в `netlify/functions/` или миграциях всегда делайте новый deploy.

## Версия

Текущий код: **5.3.11** (unified workspace + multi-role + observations + calendar + diet).


## Продакшен-чеклист (v5.3.12+)

1. **Миграции** — применить все SQL из `netlify/database/migrations/` включая `042_audit_logs.sql`.
2. **Health** — `GET /api/health` должен вернуть `"db":"up"`.
3. **Сессии** — cookie `mostik_session` уже HttpOnly + Secure + SameSite=Lax.
4. **Rate limit** — логин ограничен (~12 попыток / 15 мин на IP, in-memory).
5. **Audit** — входы, выходы, выдачи препаратов, экспорт пишутся в `audit_logs`.
6. **Бэкап** — на карточке животного кнопка «↓ Экспорт» (JSON) для owner/admin.
7. **Секреты** — не коммитить `.env`; Netlify Database credentials только в UI Netlify.
8. **Демо-пароли** — сменить или отключить demo-пользователей перед публичным запуском.
9. **Домен** — привязать custom domain + HTTPS (Netlify по умолчанию).
10. **Мониторинг** — периодически дергать `/api/health`; смотреть `admin/audit` (роль admin).

### Полезные API

| Метод | Путь | Кто | Назначение |
|-------|------|-----|------------|
| GET | `/api/health` | все | Статус приложения + БД |
| GET | `/api/admin/export?animal_id=` | owner/admin | JSON-бэкап животного |
| GET | `/api/admin/audit?limit=50` | admin | Журнал аудита |


## Устранение: ошибка базы данных

Если на сайте «Ошибка базы данных» / `DATABASE_ERROR` / 502–503:

1. **Netlify → Project → Database** — база должна быть **Enabled** (Neon Postgres).
2. Откройте SQL Editor (Neon или Netlify Database) и выполните файлы по порядку:
   `netlify/database/migrations/001_*.sql` … `042_audit_logs.sql`.
3. Проверьте демо-seed: `004_demo_seed.sql` (пользователи `demo.*@mostik.local` / `demo123`).
4. Откройте `https://ВАШ_САЙТ/api/health` — должно быть `"db":"up"` (или в API-health счётчик users).
5. Сделайте **Clear cache and deploy site** после применения миграций.
6. В логах Functions (Netlify → Functions → api) смотрите текст `MOSTIK API error` / `ensureSchema`.

Частые причины:
- БД не подключена к сайту
- миграции не применены (нет таблицы `users` / `sessions_auth`)
- применили только часть файлов
