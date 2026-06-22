#!/usr/bin/env sh
set -eu

url=https://raw.githubusercontent.com/arkadiahn/LEVEL3-projects/main/aas-digital-twin-infrastructure/data/EGU_50_IL_M_B.aasx
expected=084ded9e189dae55e258b47c89b8f8dd0fa2a2007335fac9bc8b1f8eed51e084
output=data/reference/EGU_50_IL_M_B.aasx

mkdir -p data/reference
curl --fail --location --silent --show-error "$url" -o "$output"

actual=$(sha256sum "$output" | cut -d ' ' -f 1)
if [ "$actual" != "$expected" ]; then
  rm -f "$output"
  echo "reference AASX checksum mismatch" >&2
  exit 1
fi

unzip -t "$output" >/dev/null
echo "$output"

