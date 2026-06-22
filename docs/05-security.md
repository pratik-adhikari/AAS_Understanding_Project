# 05 — Authentication and Authorization

## Two separate questions

Authentication asks: **who is making this request?**

Authorization asks: **may that identity perform this action on this target?**

Keycloak authenticates users and machine clients, then issues signed JWT access
tokens. BaSyx validates those tokens and applies rules from the RBAC JSON files.

## Identities in the development realm

| Identity | Password | Intended role |
| --- | --- | --- |
| `reader` | `reader-password` | Read shells, submodels and semantics |
| `editor` | `editor-password` | CRUD model elements |
| `uploader` | `uploader-password` | Upload AAS environments |
| `administrator` | `admin-password` | Full demonstration access |
| `aas-service` | client secret in `.env` | Service-to-service integration |

These are deliberately public demo credentials. They must never be reused in a
shared or production deployment.

## Start the secured deployment

```sh
make secure-config
make secure-up
make security-test
```

Keycloak is available at <http://auth.aas.localhost:9090>. Its development
administration credentials are in `.env`.

## What the automated test proves

The security test requires all of these outcomes:

1. no token, read shells → `401 Unauthorized`;
2. reader token, read shells → `200 OK`;
3. reader token, create Concept Description → `403 Forbidden`;
4. editor token, create Concept Description → `201 Created` or idempotent
   `409 Conflict`;
5. client-credentials token, read shells → `200 OK`.

A 401 and a 403 mean different things. A 401 indicates missing or unacceptable
authentication. A 403 indicates a known identity that lacks permission.

## Trust boundaries

- Passwords go only to Keycloak's token or login endpoints.
- BaSyx services receive bearer tokens, not user passwords.
- Registry integration uses a machine client rather than a human account.
- MongoDB is not published to the host.
- The static Nginx proxy does not mount the Docker socket.

## Development versus production

The secured stack demonstrates the protocol and authorization behavior. It is
not a production deployment because it uses:

- HTTP rather than TLS;
- Keycloak development mode;
- known demo credentials;
- a single-node MongoDB;
- broad wildcard permissions;
- no external secret manager;
- no centralized audit pipeline.

Production work must add TLS, rotated secrets, least-privilege rules, durable
Keycloak storage, MongoDB replication and backups, log retention, rate limits,
image/SBOM scanning, and an incident-response process.

## Checkpoint

1. Why can an authenticated reader still receive HTTP 403?
2. Why should registry integration use client credentials?
3. Which component decides whether `editor` may create a Concept Description?
4. Why does running Keycloak not automatically make the deployment secure?
