@echo off
setlocal EnableExtensions
cd /d "%~dp0"
where node >nul 2>nul
if errorlevel 1 (
  echo Install Node.js LTS: https://nodejs.org/
  pause
  exit /b 1
)
call npm install --no-fund --no-audit
echo Done. Now run START.bat
pause
