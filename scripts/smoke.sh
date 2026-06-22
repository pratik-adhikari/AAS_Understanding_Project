#!/usr/bin/env sh
set -eu

mkdir -p artifacts

check_json() {
  name=$1
  url=$2
  output="artifacts/${name}.json"
  echo "checking $name: $url"
  curl --fail --silent --show-error --retry 10 --retry-delay 2 \
    --retry-all-errors \
    "$url" -o "$output"
}

check_json aas-shells http://127.0.0.1:8081/shells
check_json submodels http://127.0.0.1:8081/submodels
check_json aas-registry http://127.0.0.1:8082/shell-descriptors
check_json sm-registry http://127.0.0.1:8083/submodel-descriptors

echo "checking web-ui: http://127.0.0.1:3000/"
curl --fail --silent --show-error --retry 10 --retry-delay 2 \
  --retry-all-errors \
  http://127.0.0.1:3000/ -o artifacts/web-ui.html

echo "Baseline HTTP smoke checks passed"
