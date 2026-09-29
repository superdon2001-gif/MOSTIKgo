@echo off
setlocal EnableExtensions
cd /d "%~dp0"

echo ========================================
echo   MOSTIK local start
echo   Docker/PostgreSQL NOT required
echo ========================================
echo.

where node >nul 2>nul
if errorlevel 1 (
  echo ERROR: Node.js not found.
  echo Install Node.js LTS from https://nodejs.org/
  start https://nodejs.org/
  pause
  exit /b 1
)

echo Node version:
node --version
echo.

if exist "node_modules\@electric-sql\pglite\package.json" (
  echo Packages: OK (bundled)
) else (
  echo Packages missing. Trying npm install...
  call npm install --no-fund --no-audit
  if errorlevel 1 (
    echo ERROR: packages not found and npm install failed.
    echo Use the full ZIP that includes node_modules folder.
    pause
    exit /b 1
  )
)

echo.
echo Starting: http://127.0.0.1:8787
echo Keep this window open.
echo.
set MOSTIK_LOCAL=1
set MOSTIK_EMBEDDED=1
node server.mjs
echo.
echo Server stopped.
pause
