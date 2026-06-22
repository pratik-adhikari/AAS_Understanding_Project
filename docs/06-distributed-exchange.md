# 06 — Distributed AAS Exchange

## What “independent” means here

The primary and partner deployments have:

- separate AAS Environment processes;
- separate AAS and Submodel Registries;
- separate Discovery services;
- separate MongoDB processes and named volumes;
- separate Docker application and data networks;
- separate host ports and web UIs.

They share image versions and project source code, but they do not share runtime
databases.

## Start both sides

```sh
make exchange-config
make exchange-up
```

Primary UI: <http://127.0.0.1:3000>

Partner UI: <http://127.0.0.1:3100>

Before exchange, the partner starts with no bootstrap AAS.

## Exchange through interfaces

```sh
make exchange-test
```

The containerized client:

1. reads shells, submodels, and Concept Descriptions from the primary API;
2. posts semantic objects and submodels to the partner;
3. posts shells after their referenced submodels exist;
4. accepts `409 Conflict` as an idempotent repeated-run result;
5. waits for the partner AAS Registry to contain descriptors;
6. compares source and target shell identifiers;
7. writes evidence to `data/generated/exchange-evidence.json`.

No MongoDB collection is copied. Database copying would couple the workflow to
BaSyx implementation details and bypass registry integration.

## What has and has not happened

The target now has an independent copy of the exchanged representation. This is
not automatic synchronization. Later source updates do not magically appear on
the partner. A production exchange protocol must define ownership, versions,
conflicts, signatures, retries, revocation, and update frequency.

## Checkpoint

1. Why does copying MongoDB records fail the interoperability goal?
2. Why are submodels created before the shell?
3. Why is HTTP 409 acceptable on a repeated exchange?
4. Does this workflow create synchronization or a point-in-time copy?
