@echo off
setlocal EnableExtensions
cd /d "%~dp0\.."

if not exist ".env" (
  echo [!] Нет файла .env
  echo     Скопируйте .env.example в .env и укажите DATABASE_URL
  pause
  exit /b 1
)

rem Load DATABASE_URL from .env (simple parser)
for /f "usebackq tokens=1,* delims==" %%A in (".env") do (
  if /I "%%A"=="DATABASE_URL" set "DATABASE_URL=%%B"
)

if "%DATABASE_URL%"=="" (
  echo [!] DATABASE_URL пустой в .env
  pause
  exit /b 1
)

where psql >nul 2>nul
if errorlevel 1 (
  echo [!] psql не найден.
  echo     Вариант 1: установите PostgreSQL и добавьте bin в PATH
  echo     Вариант 2: Docker Desktop — см. LOCAL_DEV.md
  echo     Вариант 3: выполните SQL из netlify\database\migrations в pgAdmin
  pause
  exit /b 1
)

echo Применение миграций...
for %%F in ("netlify\database\migrations\*.sql") do (
  echo --^> %%~nxF
  psql "%DATABASE_URL%" -v ON_ERROR_STOP=1 -f "%%F"
  if errorlevel 1 (
    echo [!] Ошибка на %%~nxF
    pause
    exit /b 1
  )
)
echo.
echo Готово.
pause
