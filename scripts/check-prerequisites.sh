#!/usr/bin/env sh
set -eu

missing=0
for command in docker git curl make; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "missing required command: $command" >&2
    missing=1
  fi
done

if [ "$missing" -ne 0 ]; then
  exit 1
fi

docker compose version
if ! docker info >/dev/null 2>&1; then
  echo "Docker is installed, but the daemon is unavailable to this user." >&2
  echo "Start Docker or fix access to the configured Docker context." >&2
  exit 1
fi

echo "Host prerequisites passed"

