#!/usr/bin/env sh
set -eu

case "${1:-}" in
  generate)
    exec python -m tooling.generate \
      --source data/products/learning-gripper.yaml \
      --json-output data/generated/learning-gripper.json \
      --aasx-output data/generated/learning-gripper.aasx
    ;;
  test)
    exec pytest -q -p no:cacheprovider tests
    ;;
  exchange)
    exec python -m tooling.exchange \
      --source http://aas-environment:8081 \
      --target http://partner-aas-environment:8081 \
      --target-registry http://partner-aas-registry:8080 \
      --evidence data/generated/exchange-evidence.json
    ;;
  shell)
    exec /bin/sh
    ;;
  *)
    echo "usage: entrypoint.sh {generate|test|exchange|shell}" >&2
    exit 2
    ;;
esac
