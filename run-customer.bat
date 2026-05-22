@echo off
cd /d "%~dp0"
set "APP_MODE=customer"
set "APP_ENV=customer"
set "JJOZZY_CUSTOMER_BUILD=true"
set "HOST=127.0.0.1"
set "PORT=8000"
start "JJOzzy Crypto Bot" "%~dp0JJOzzyCryptoBot.exe"
echo Waiting for local server http://127.0.0.1:8000 ...
for /L %%i in (1,1,40) do (
  powershell -NoProfile -ExecutionPolicy Bypass -Command "try { $r = Invoke-WebRequest -UseBasicParsing -Uri 'http://127.0.0.1:8000/health' -TimeoutSec 1; if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 500) { exit 0 } } catch { exit 1 }" >nul 2>nul
  if not errorlevel 1 goto OPEN_DASHBOARD
  timeout /t 1 /nobreak >nul
)
:OPEN_DASHBOARD
start "" "http://127.0.0.1:8000"
pause
