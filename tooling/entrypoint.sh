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
  shell)
    exec /bin/sh
    ;;
  *)
    echo "usage: entrypoint.sh {generate|test|shell}" >&2
    exit 2
    ;;
esac
