#!/bin/bash
# Builds & runs the app with local secrets from .env.
# Usage: ./run.sh [device-id] [extra flutter args...]
# Example: ./run.sh RZGYB1E58CV --release
set -euo pipefail

if [ ! -f .env ]; then
  echo "Missing .env — create it with OPEN_WEATHER_MAP_API_KEY=..." >&2
  exit 1
fi

DEFINES=()
while IFS='=' read -r key value; do
  [[ "$key" =~ ^#.*$ || -z "$key" || -z "$value" ]] && continue
  [[ "$value" == "PASTE_YOUR_KEY_HERE" ]] && { echo "Replace PASTE_YOUR_KEY_HERE in .env first" >&2; exit 1; }
  DEFINES+=("--dart-define=$key=$value")
done < <(grep -v '^$' .env)

DEVICE="${1:-}"
shift || true
if [ -n "$DEVICE" ]; then
  exec flutter run -d "$DEVICE" "${DEFINES[@]}" "$@"
else
  exec flutter run "${DEFINES[@]}" "$@"
fi