#!/usr/bin/env bash
set -e

# 1) Copy example .env if none exists
if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created .env from .env.example – please review and edit it."
  exit 0
fi

# 2) Build & start
docker-compose up -d --build

echo
echo "✅ WordPress is building…"
echo "Access it at http://${APP_MAIN_DOMAIN}:${APP_PORT}"
