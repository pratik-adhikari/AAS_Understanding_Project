#!/usr/bin/env sh
set -eu

set -a
. ./.env
set +a

mkdir -p data/backups
timestamp=$(date -u +%Y%m%dT%H%M%SZ)
output="data/backups/aas-learning-$timestamp.archive"

docker compose exec -T mongo mongodump \
  --username "$MONGO_ROOT_USERNAME" \
  --password "$MONGO_ROOT_PASSWORD" \
  --authenticationDatabase admin \
  --archive >"$output"

test -s "$output"
echo "$output"

