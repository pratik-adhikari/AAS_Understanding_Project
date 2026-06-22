# AAS Understanding Project

A runnable, inspectable learning environment for understanding Asset
Administration Shells (AAS) from first principles.

The project is designed for a reviewer who has not studied AAS beforehand.
It explains why AAS exists, builds a complete local infrastructure, creates a
real AAS, secures it, exchanges it between independent systems, and proves the
result with automated end-to-end checks.

## What “complete” means

The finished project must let you:

1. Start every required service with Docker Compose.
2. Open an AAS in the BaSyx web UI.
3. Query the same shell and its submodels through standardized REST APIs.
4. Generate an AASX package from source data.
5. discover an AAS through registries rather than a hard-coded repository URL.
6. prove MongoDB persistence across container recreation.
7. authenticate through Keycloak and observe role-based authorization.
8. exchange an AAS or submodel between two independent AAS environments.
9. run one automated command that verifies the complete workflow.
10. remove the whole environment without installing application dependencies
    on the host.

Detailed acceptance criteria live in
[`constraints/development.md`](constraints/development.md).

## Documentation route

Read these in order:

1. [`docs/00-first-principles.md`](docs/00-first-principles.md)
2. [`docs/01-aas-model.md`](docs/01-aas-model.md)
3. [`docs/02-architecture.md`](docs/02-architecture.md)
4. [`docs/03-quickstart.md`](docs/03-quickstart.md)
5. [`docs/04-guided-tour.md`](docs/04-guided-tour.md)
6. [`docs/05-security.md`](docs/05-security.md)
7. [`docs/06-distributed-exchange.md`](docs/06-distributed-exchange.md)
8. [`docs/07-api-cookbook.md`](docs/07-api-cookbook.md)
9. [`docs/08-troubleshooting.md`](docs/08-troubleshooting.md)
10. [`docs/09-review-checklist.md`](docs/09-review-checklist.md)
11. [`docs/10-limitations-and-sources.md`](docs/10-limitations-and-sources.md)

## Host requirements

- Linux on x86-64 or ARM64
- Docker Engine with Compose v2
- Git
- `make`, `curl`, and a browser

Java, Python, Node.js, MongoDB, Keycloak, and BaSyx are not installed on the
host. They run in containers.

## One-command verification

```sh
make init
make verify
```

This performs a clean baseline deployment, API checks, persistence recreation,
secured deployment and RBAC proofs, independent partner exchange twice,
evidence collection, and final cleanup.

## Main operating modes

```sh
make up            # baseline learning stack
make secure-up     # Keycloak and RBAC stack
make exchange-up   # primary plus independent partner
```

Each mode has corresponding `*-down`, status, and test targets. Run
`make help` for the complete command list.
