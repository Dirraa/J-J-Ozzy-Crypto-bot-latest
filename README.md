# Ozzy TradeGuard

A Kraken trading bot with FastAPI, paper/live execution controls, pair discovery, EMA + RSI signals, and a local dashboard.

## What was fixed

- Windows startup now avoids the broken global `pip` path by using the project virtual environment directly.
- Added the missing `Jinja2` dependency required by `Jinja2Templates`.
- `.env` loading now works from the project folder instead of depending on whatever folder Command Prompt was opened in.
- SQLite database paths are resolved relative to the project so the app does not create `trades.db` in the wrong place.
- Added `install.bat` and `run.bat` for a clean Windows start flow.

## Windows install

Open Command Prompt in the project folder and run:

```bat
install.bat
```

Then start the app with:

```bat
run.bat
```

## Manual commands

If you prefer manual commands:

```bat
cd /d C:\crypto_trading_bot
py -m venv .venv
.venv\Scripts\python.exe -m ensurepip --upgrade
.venv\Scripts\python.exe -m pip install --upgrade pip setuptools wheel
.venv\Scripts\python.exe -m pip install -r requirements.txt
.venv\Scripts\python.exe -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
```

## URLs

- Dashboard: `http://127.0.0.1:8000/`
- Docs: `http://127.0.0.1:8000/docs`
- Health: `http://127.0.0.1:8000/health`

## Important

Your uploaded project included live Kraken credentials in `.env`. Rotate those keys in Kraken and replace them locally after testing.


## All-pairs AI micro-trading rebuild

This build adds an all-pairs intelligence layer on top of the Kraken spot API:

- live universe discovery via `/universe/refresh`
- new listing watcher via `/universe/new-listings`
- all-pairs AI opportunity scan via `/ai/market-scan?quote=AUD|USD`
- holdings rotation review via `/ai/review-portfolio`
- open-order review via `/ai/review-open-orders`
- real-trade risk gate + best-entry execution via `/ai/execute-best-entry`

Suggested flow:
1. `GET /account/overview`
2. `GET /ai/review-open-orders`
3. `GET /ai/review-portfolio`
4. `GET /ai/market-scan?quote=AUD&top_n=10`
5. `GET /ai/market-scan?quote=USD&top_n=10` if AUD has no clean entries
6. `POST /ai/execute-best-entry?allow_live=false` for paper validation
7. `POST /ai/execute-best-entry?allow_live=true` only after review

This build still uses deterministic AI scoring hooks. It is designed so a real ML or LLM scorer can be plugged into `app/ai/scoring.py` later without changing the risk gate or exchange execution layer.


## Pro maintenance patch - 2026-05-03

This build was updated after reviewing the live bot log. Key fixes:

- Fixed quick-turn candle parsing so Kraken `Candle` dataclass objects are counted correctly. This resolves repeated `insufficient candles on 5m` decisions caused by parser shape mismatch.
- Added a six-hour small-balance conversion cooldown for assets Kraken cannot convert through the client, stopping repeated `convert_pending` log spam for dust such as XDG/AI16Z.
- Suppressed repeated managed-exit dust decisions while a conversion is already pending.
- Added a `/favicon.ico` no-content route to stop harmless browser 404 noise.
- Added `.gitignore` so virtual environments, caches, databases, logs, and `.env` secrets are not re-zipped accidentally.

After replacing files, run:

```bat
install.bat
run.bat
```

Then confirm:

```text
http://127.0.0.1:8000/health
http://127.0.0.1:8000/bot/status
```


## Reinvest / no-chase behaviour

By default, the bot can reinvest after a profitable sell immediately. New buys are not time-locked; they are blocked only by the entry firewall when the setup is a spike chase, bullish top buy, weak rebound, high spread, hot RSI, or lacks enough fee-aware upside.
