#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# QuickInfo deploy. Run on the server, from the back-end repo root:
#   ./deploy/deploy.sh
#
# Assumes the two repos sit side by side:
#   ~/quickinfo/quickinfo-back-end
#   ~/quickinfo/quickinfo-front-end
#
# Pulls both repos, installs, migrates, builds the website, publishes it and
# reloads the API. Safe to run again.
# ---------------------------------------------------------------------------
set -euo pipefail

API_BASE="${API_BASE:-https://api.quickinfo.in}"
SITE_ROOT="${SITE_ROOT:-/var/www/quickinfo-site}"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SITE_SRC="$(dirname "$HERE")/quickinfo-front-end"

[ -d "$SITE_SRC" ] || { echo "missing repo: $SITE_SRC"; exit 1; }
[ -f "$HERE/.env" ] || { echo "missing $HERE/.env (copy .env.example and fill it in)"; exit 1; }

# The website decrypts API responses with the same key the API encrypts with.
# Reading it from the back end's .env keeps the two from ever drifting apart.
SECRET_KEY="$(grep -E '^SECRET_KEY=' "$HERE/.env" | head -1 | cut -d= -f2-)"
[ -n "$SECRET_KEY" ] || { echo "SECRET_KEY is empty in $HERE/.env"; exit 1; }

echo "==> pulling latest code"
git -C "$HERE" pull --ff-only
git -C "$SITE_SRC" pull --ff-only

echo "==> back-end dependencies"
cd "$HERE"
npm ci --omit=dev

# Schema first: the code reloaded below assumes these tables exist.
echo "==> database schema"
node scripts/migrate.js

echo "==> website build  (VITE_API_BASE=$API_BASE/api)"
cd "$SITE_SRC"
npm ci
VITE_API_BASE="$API_BASE/api" VITE_SECRET_KEY="$SECRET_KEY" npm run build

# Publish only after the build succeeded, so a broken build never goes live.
echo "==> publishing website to $SITE_ROOT"
sudo mkdir -p "$SITE_ROOT"
sudo rsync -a --delete "$SITE_SRC/dist/" "$SITE_ROOT/"

echo "==> reloading API"
cd "$HERE"
mkdir -p logs
pm2 reload quickinfo-api --update-env 2>/dev/null || pm2 start ecosystem.config.cjs
pm2 save

echo "==> verifying"
sleep 3
curl -fsS --max-time 10 "$API_BASE/" >/dev/null && echo "API is up at $API_BASE"
echo "done: https://quickinfo.in  ·  $API_BASE"
