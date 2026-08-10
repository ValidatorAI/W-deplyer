#!/usr/bin/env bash
set -euo pipefail

APP_DIR="${APP_DIR:-/opt/w-app}"
SECRET_FILE="${SECRET_FILE:-$APP_DIR/.secret_key}"
APP_START_COMMAND="${APP_START_COMMAND:-echo \"No app start command configured\"}"

mkdir -p "$APP_DIR"

if [[ ! -s "$SECRET_FILE" ]]; then
  # Generate a 64-byte random secret and store as hex.
  openssl rand -hex 64 > "$SECRET_FILE"
  chmod 600 "$SECRET_FILE"
  echo "Secret generated at $SECRET_FILE"
else
  echo "Secret already exists at $SECRET_FILE"
fi

export APP_SECRET_KEY="$(cat "$SECRET_FILE")"

cd "$APP_DIR"
echo "Running app start command in $APP_DIR"
bash -lc "$APP_START_COMMAND"
