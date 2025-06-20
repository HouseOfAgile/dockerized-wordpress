#!/bin/sh

set -e

echo "Generating nginx config..."
envsubst '${APP_MAIN_DOMAIN} ${PROJECT_NAME}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

if [ ! -s /etc/nginx/conf.d/default.conf ]; then
  echo "ERROR: default.conf was not generated!" >&2
  exit 1
fi

exec "$@"
