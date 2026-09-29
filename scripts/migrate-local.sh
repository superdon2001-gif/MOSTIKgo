#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
if [[ -f .env ]]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
fi
URL="${DATABASE_URL:-}"
if [[ -z "$URL" ]]; then
  echo "DATABASE_URL не задан. Создайте .env из .env.example"
  exit 1
fi
if ! command -v psql >/dev/null 2>&1; then
  echo "Нужен клиент psql (PostgreSQL)."
  exit 1
fi
shopt -s nullglob
files=(netlify/database/migrations/*.sql)
if [[ ${#files[@]} -eq 0 ]]; then
  echo "Нет файлов миграций в netlify/database/migrations/"
  exit 1
fi
for f in "${files[@]}"; do
  echo "→ $f"
  psql "$URL" -v ON_ERROR_STOP=1 -f "$f"
done
echo "Миграции применены."
