#!/usr/bin/env sh
set -eu

AUTH_URL=http://auth.aas.localhost:9090/realms/aas-learning/protocol/openid-connect/token
API_URL=http://127.0.0.1:8081
mkdir -p artifacts

token_for_user() {
  username=$1
  password=$2
  curl --noproxy '*' --fail --silent --show-error \
    --data-urlencode grant_type=password \
    --data-urlencode client_id=aas-cli \
    --data-urlencode "username=$username" \
    --data-urlencode "password=$password" \
    "$AUTH_URL" | sed -n 's/.*"access_token":"\([^"]*\)".*/\1/p'
}

expect_status() {
  expected=$1
  shift
  actual=$(curl --noproxy '*' --silent --output /dev/null --write-out '%{http_code}' "$@")
  if [ "$actual" != "$expected" ]; then
    echo "expected HTTP $expected, got $actual: $*" >&2
    exit 1
  fi
}

reader_token=$(token_for_user reader reader-password)
editor_token=$(token_for_user editor editor-password)

expect_status 401 "$API_URL/shells"
expect_status 200 -H "Authorization: Bearer $reader_token" "$API_URL/shells"

concept='{"id":"https://example.org/concepts/security-test","idShort":"SecurityTest","modelType":"ConceptDescription"}'
expect_status 403 \
  -X POST \
  -H "Authorization: Bearer $reader_token" \
  -H "Content-Type: application/json" \
  --data "$concept" \
  "$API_URL/concept-descriptions"

create_status=$(curl --noproxy '*' --silent --output artifacts/security-create.json \
  --write-out '%{http_code}' \
  -X POST \
  -H "Authorization: Bearer $editor_token" \
  -H "Content-Type: application/json" \
  --data "$concept" \
  "$API_URL/concept-descriptions")

if [ "$create_status" != 201 ] && [ "$create_status" != 409 ]; then
  echo "editor create expected HTTP 201 or idempotent 409, got $create_status" >&2
  exit 1
fi

service_token=$(curl --noproxy '*' --fail --silent --show-error \
  --data-urlencode grant_type=client_credentials \
  --data-urlencode client_id=aas-service \
  --data-urlencode client_secret=aas_service_dev_secret \
  "$AUTH_URL" | sed -n 's/.*"access_token":"\([^"]*\)".*/\1/p')
expect_status 200 -H "Authorization: Bearer $service_token" "$API_URL/shells"

printf '%s\n' \
  "unauthenticated read: denied (401)" \
  "reader read: allowed (200)" \
  "reader create: denied (403)" \
  "editor create: allowed ($create_status)" \
  "service client read: allowed (200)" \
  | tee artifacts/security-summary.txt
