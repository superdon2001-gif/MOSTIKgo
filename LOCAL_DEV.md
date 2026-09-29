# MOSTIK — самый простой запуск (Windows)

**Нужен только Node.js.** Docker, PostgreSQL и Netlify **не нужны**.

1. Установите Node.js LTS: https://nodejs.org/
2. Распакуйте архив
3. Дважды нажмите **`START.bat`**
4. Откройте в браузере: **http://127.0.0.1:8787**

Демо-вход (после первого старта, когда накатятся миграции и seed):
- `demo.owner@mostik.local` / `demo123`
- `demo.trainer@mostik.local` / `demo123`
- `demo.keeper@mostik.local` / `demo123`
- `demo.vet@mostik.local` / `demo123`

Данные лежат в папке `data\` рядом с программой.

Остановка: закрыть окно `START.bat`.

---

## Если всё же нужен «настоящий» Postgres

Задайте в `.env` строку `DATABASE_URL=...` и `MOSTIK_LOCAL=0` — тогда используется внешняя БД (Docker/PostgreSQL). См. разделы ниже.

---

# MOSTIK — локально на Windows

Вам **не нужно** знать bash. Достаточно двойных кликов и одной программы Postgres.

## Короткий путь (рекомендуется)

### 0. Что установить один раз
1. **Node.js LTS** — https://nodejs.org/ (кнопка LTS → Next → Next)
2. **PostgreSQL** один из вариантов:
   - **Docker Desktop** (проще, если уже есть): https://www.docker.com/products/docker-desktop/
   - или установщик PostgreSQL: https://www.postgresql.org/download/windows/

### 1. База данных

**Если Docker Desktop:**
1. Откройте PowerShell или «Командную строку»
2. Вставьте одной строкой и Enter:

```text
docker run --name mostik-pg -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=mostik -p 5432:5432 -d postgres:16
```

(команду можно не разбивать на несколько строк)

**Если обычный PostgreSQL:**
- при установке запомните пароль пользователя `postgres`
- создайте базу `mostik` в pgAdmin (правый клик Databases → Create → name: mostik)

### 2. Распакуйте архив MOSTIK_web_local.zip
Например в `C:\MOSTIK\`

### 3. Запуск
Дважды кликните **`setup-and-run.bat`**

Он:
- создаст `.env` (откроется блокнот — сохраните строку DATABASE_URL)
- поставит зависимости (`npm install`)
- попробует применить миграции
- откроет сервер на **http://127.0.0.1:8787**

В браузере откройте этот адрес.

Демо-вход:
- `demo.owner@mostik.local` / `demo123`
- `demo.trainer@mostik.local` / `demo123`
- `demo.keeper@mostik.local` / `demo123`
- `demo.vet@mostik.local` / `demo123`

### Если миграции не прошли
1. Убедитесь, что Postgres запущен (Docker / служба PostgreSQL)
2. Дважды кликните `scripts\migrate-local.bat`
3. Или в **pgAdmin**: Query Tool → открыть по очереди файлы из  
   `netlify\database\migrations\001_....sql` … до последнего → Execute

### Если «Node не найден»
Переустановите Node.js LTS и **перезапустите** командную строку / bat-файл.

---

## Если у вас есть Linux / WSL

Откройте терминал WSL, перейдите в папку проекта (диск C в WSL: `/mnt/c/MOSTIK`):

```bash
cd /mnt/c/MOSTIK   # путь подставьте свой
cp .env.example .env
# в .env: DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:5432/mostik
bash scripts/migrate-local.sh
npm install
npm start
```

Postgres может быть в Docker на Windows — с WSL адрес часто тот же `127.0.0.1:5432`.

---


## Linux / macOS (bash)

# MOSTIK — полностью локально (без Netlify)

Нужны только **Node.js 22+** и **PostgreSQL**. CLI Netlify, аккаунт Netlify и Neon **не обязательны**.

## 1. Postgres

```bash
docker run --name mostik-pg \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=mostik \
  -p 5432:5432 -d postgres:16
```

Или свой установленный PostgreSQL с базой `mostik`.

## 2. Окружение

```bash
cp .env.example .env
```

В `.env`:

```env
DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:5432/mostik
```

## 3. Миграции (один раз)

```bash
# Linux / macOS / Git Bash
bash scripts/migrate-local.sh

# или вручную:
# for f in netlify/database/migrations/*.sql; do psql "$DATABASE_URL" -f "$f"; done
```

Папка `netlify/database/migrations` — просто SQL-файлы; к сервису Netlify это не привязано.

## 4. Запуск

```bash
npm install
npm start
```

Откройте: **http://127.0.0.1:8787**  
Health: **http://127.0.0.1:8787/api/health** → `"db":"up"`

Windows: `run-local.bat`

## 5. Демо-вход (после seed-миграции)

| Логин | Пароль |
|-------|--------|
| demo.owner@mostik.local | demo123 |
| demo.trainer@mostik.local | demo123 |
| demo.keeper@mostik.local | demo123 |
| demo.vet@mostik.local | demo123 |

## Что не нужно

- `npx netlify dev`
- `netlify login` / `netlify link`
- Netlify Database / Neon (если есть свой Postgres)
- RESEND_* (почта восстановления — опционально)

## Если ошибка БД

| Симптом | Действие |
|---------|----------|
| `db":"down"` | Postgres запущен? Верный `DATABASE_URL`? |
| `relation "users" does not exist` | Не применены миграции |
| `ECONNREFUSED 127.0.0.1:5432` | Контейнер/служба Postgres не слушает порт |
| Логин не держится | Смотрите cookie в DevTools; локальный сервер снимает флаг `Secure` |

## Продакшен на Netlify

По-прежнему возможен через `DEPLOY_NETLIFY.md`. Локальная шлифовка — через `server.mjs`.
