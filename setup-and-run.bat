@echo off
setlocal EnableExtensions
cd /d "%~dp0"

echo ========================================
echo   MOSTIK — локальный запуск (Windows)
echo ========================================
echo.

where node >nul 2>nul
if errorlevel 1 (
  echo [1/4] Установите Node.js LTS: https://nodejs.org/
  echo       После установки закройте и снова откройте это окно.
  start https://nodejs.org/
  pause
  exit /b 1
)
echo [ok] Node: 
node --version

if not exist ".env" (
  copy /Y ".env.example" ".env" >nul
  echo.
  echo Создан файл .env
  echo Откроется блокнот — проверьте строку:
  echo   DATABASE_URL=postgresql://postgres:postgres@127.0.0.1:5432/mostik
  echo Сохраните и закройте блокнот, затем нажмите любую клавишу здесь.
  notepad .env
  pause
)

echo.
echo [2/4] npm install...
call npm install
if errorlevel 1 (
  echo Ошибка npm install
  pause
  exit /b 1
)

echo.
echo [3/4] Миграции БД (если Postgres уже запущен)...
if exist "scripts\migrate-local.bat" (
  call scripts\migrate-local.bat
) else (
  echo Скрипт migrate-local.bat не найден — примените SQL вручную.
)

echo.
echo [4/4] Запуск сервера http://127.0.0.1:8787
echo       Окно не закрывайте, пока работаете с MOSTIK.
echo.
node server.mjs
pause
