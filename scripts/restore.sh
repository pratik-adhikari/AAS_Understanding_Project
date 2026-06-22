#!/usr/bin/env sh
set -eu

backup=${1:?backup archive is required}
test -f "$backup"

set -a
. ./.env
set +a

docker compose exec -T mongo mongorestore \
  --username "$MONGO_ROOT_USERNAME" \
  --password "$MONGO_ROOT_PASSWORD" \
  --authenticationDatabase admin \
  --archive \
  --drop <"$backup"

echo "restored $backup"

