@echo off
setlocal EnableExtensions
cd /d "%~dp0"

echo ========================================
echo   MOSTIK local (without Netlify)
echo ========================================
echo.

where node >nul 2>nul
if errorlevel 1 (
  echo Node.js not found. Install LTS: https://nodejs.org/
  pause
  exit /b 1
)

if not exist ".env" (
  if exist ".env.example" copy /Y ".env.example" ".env" >nul
  echo Created .env — set DATABASE_URL to local Postgres, then re-run.
  echo Example:
  echo   DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:5432/mostik
  notepad .env
  pause
  exit /b 1
)

echo npm install...
call npm install
if errorlevel 1 (
  echo npm install failed
  pause
  exit /b 1
)

echo.
echo Starting http://127.0.0.1:8787
echo Keep this window open. Apply migrations once via scripts\migrate-local.sh or psql.
echo.
node server.mjs
pause
