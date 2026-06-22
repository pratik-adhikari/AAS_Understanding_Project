#!/usr/bin/env sh
set -eu

for forbidden in '.env' '*.pyc' '__pycache__' 'artifacts'; do
  if git ls-files "$forbidden" | grep . >/dev/null 2>&1; then
    echo "forbidden generated or secret path is tracked: $forbidden" >&2
    exit 1
  fi
done

carriage_return=$(printf '\r')
if grep -RIl "$carriage_return" --exclude-dir=.git . >/dev/null 2>&1; then
  echo "CRLF line endings detected" >&2
  exit 1
fi

echo "Repository policy checks passed"
