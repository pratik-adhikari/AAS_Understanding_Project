#!/usr/bin/env sh
set -eu

if grep -REn 'image:[[:space:]]+[^#[:space:]]+:(latest|SNAPSHOT)([[:space:]]|$)' \
  --include='compose*.y*ml' .; then
  echo "Mutable image tag found" >&2
  exit 1
fi

echo "Container image tags are pinned"

