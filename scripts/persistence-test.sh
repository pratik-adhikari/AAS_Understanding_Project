#!/usr/bin/env sh
set -eu

API_URL=http://127.0.0.1:8081
MARKER=https://example.org/concepts/persistence-proof
payload='{"id":"https://example.org/concepts/persistence-proof","idShort":"PersistenceProof","modelType":"ConceptDescription"}'

status=$(curl --noproxy '*' --silent --output artifacts/persistence-create.json \
  --write-out '%{http_code}' \
  -X POST \
  -H 'Content-Type: application/json' \
  --data "$payload" \
  "$API_URL/concept-descriptions")

if [ "$status" != 201 ] && [ "$status" != 409 ]; then
  echo "could not create persistence marker: HTTP $status" >&2
  exit 1
fi

docker compose up -d --force-recreate --no-deps --wait aas-environment

curl --noproxy '*' --fail --silent --show-error \
  "$API_URL/concept-descriptions" \
  -o artifacts/persistence-after-recreate.json

if ! grep -F "$MARKER" artifacts/persistence-after-recreate.json >/dev/null; then
  echo "persistence marker disappeared after container recreation" >&2
  exit 1
fi

echo "MongoDB persistence survived AAS Environment recreation"

