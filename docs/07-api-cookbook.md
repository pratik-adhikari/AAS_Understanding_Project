# 07 — API Cookbook

## List resources

```sh
curl -s http://127.0.0.1:8081/shells
curl -s http://127.0.0.1:8081/submodels
curl -s http://127.0.0.1:8081/concept-descriptions
```

Collection responses use a `result` array and may include paging metadata.

## Registry descriptors

```sh
curl -s http://127.0.0.1:8082/shell-descriptors
curl -s http://127.0.0.1:8083/submodel-descriptors
```

Descriptors contain endpoint information. They are not copies of repository
objects.

## Encode an identifier for an API path

Individual-resource paths use Base64 URL encoding without padding:

```sh
id='https://example.org/aas/learning-gripper/001'
encoded=$(printf '%s' "$id" | base64 -w 0 | tr '+/' '-_' | tr -d '=')
curl -s "http://127.0.0.1:8081/shells/$encoded"
```

## Create a Concept Description

```sh
curl -i -X POST \
  -H 'Content-Type: application/json' \
  --data '{
    "id": "https://example.org/concepts/api-example",
    "idShort": "ApiExample",
    "modelType": "ConceptDescription"
  }' \
  http://127.0.0.1:8081/concept-descriptions
```

Expected first result: HTTP 201. Repeating the same create normally returns
HTTP 409 because global identifiers must remain unique.

## Obtain a development access token

After `make secure-up`:

```sh
token=$(curl --noproxy '*' -s \
  --data-urlencode grant_type=password \
  --data-urlencode client_id=aas-cli \
  --data-urlencode username=reader \
  --data-urlencode password=reader-password \
  http://auth.aas.localhost:9090/realms/aas-learning/protocol/openid-connect/token \
  | sed -n 's/.*"access_token":"\([^"]*\)".*/\1/p')

curl -H "Authorization: Bearer $token" \
  http://127.0.0.1:8081/shells
```

## API status interpretation

| Status | Meaning in these exercises |
| --- | --- |
| 200 | Read succeeded |
| 201 | Resource created |
| 204 | Update or deletion succeeded without a response body |
| 400 | Request does not satisfy the API contract |
| 401 | Authentication missing or invalid |
| 403 | Authenticated identity lacks permission |
| 404 | Identified resource does not exist |
| 409 | Identifier already exists or state conflicts |
