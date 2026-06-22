#!/usr/bin/env sh
set -eu

BASE='docker compose -f compose.yaml'
SECURE='docker compose -f compose.yaml -f compose.secure.yaml'
EXCHANGE='docker compose -f compose.yaml -f compose.exchange.yaml'

mkdir -p artifacts
install -d -m 0777 data/generated
: >artifacts/verification-summary.txt

record() {
  printf '%s\n' "$1" | tee -a artifacts/verification-summary.txt
}

cleanup() {
  $EXCHANGE down --volumes --remove-orphans >/dev/null 2>&1 || true
  $SECURE down --volumes --remove-orphans >/dev/null 2>&1 || true
  $BASE down --volumes --remove-orphans >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

record "1/4 baseline: clean start, APIs, persistence"
cleanup
$BASE up -d --wait
./scripts/smoke.sh
./scripts/persistence-test.sh
$BASE ps --format json >artifacts/baseline-containers.json

record "2/4 security: authentication and RBAC"
$BASE down --volumes --remove-orphans
$SECURE up -d --wait
./scripts/security-test.sh
$SECURE ps --format json >artifacts/secure-containers.json

record "3/4 exchange: independent target and idempotency"
$SECURE down --volumes --remove-orphans
$EXCHANGE up -d --wait
$EXCHANGE --profile tools run --rm aas-tooling exchange \
  >artifacts/exchange-first-run.txt
$EXCHANGE --profile tools run --rm aas-tooling exchange \
  >artifacts/exchange-second-run.txt
$EXCHANGE ps --format json >artifacts/exchange-containers.json

record "4/4 cleanup: remove project runtime state"
cleanup
trap - EXIT INT TERM

if docker ps -a --format '{{.Names}}' | grep '^aas-learning-' >/dev/null; then
  echo "project containers remain after cleanup" >&2
  exit 1
fi

record "PASS: full end-to-end verification completed"
