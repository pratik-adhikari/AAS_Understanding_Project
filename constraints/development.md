# Development Constraints and Definition of Done

This file is the project contract. Every implementation decision and completion
claim must be checked against it.

## 1. Purpose

Build a complete, local AAS learning environment which:

- starts from first principles;
- can be operated by somebody with no prior AAS knowledge;
- demonstrates the practical value of AAS rather than only defining terms;
- is reproducible and inspectable;
- keeps application dependencies off the host;
- supplies enough evidence for an independent reviewer to verify every claim.

## 2. Documentation style

Documentation follows a 42-style learning approach:

- explain the problem before introducing the abstraction;
- define every important term when it first appears;
- make the learner predict outcomes before revealing them;
- use small exercises with explicit expected results;
- distinguish facts, design decisions, and simplifications;
- expose failure modes instead of hiding them;
- provide commands that can be copied and independently verified;
- finish each chapter with questions a reviewer should be able to answer;
- never rely on screenshots as the only proof;
- never call a component “working” without a repeatable validation.

The prose must remain technically precise. Analogies may introduce a concept,
but normative AAS terminology must follow immediately.

## 3. First-principles rule

Each major component must answer:

1. What concrete problem exists without this component?
2. What information does it own?
3. What interface does it expose?
4. What invariants must remain true?
5. What fails when it is unavailable or misconfigured?
6. How can a reviewer prove it works?

## 4. Required architecture

The project must contain:

- Eclipse BaSyx AAS Environment;
- AAS Repository;
- Submodel Repository;
- Concept Description Repository;
- AAS Registry;
- Submodel Registry;
- AAS Discovery service;
- BaSyx web UI;
- MongoDB persistence;
- Keycloak identity provider;
- role-based authorization;
- a reverse proxy without Docker socket access;
- an automation/client container;
- two logically independent AAS environments for exchange;
- a generated Digital Nameplate example;
- the supplied Schunk example where license and format permit.

Compose services must be separated by responsibility. “Everything in one
container” is explicitly rejected.

## 5. Host cleanliness

The host may require only Docker, Compose, Git, Make, Curl, and a browser.

- No host Java, Maven, Python package, Node package, MongoDB, or Keycloak setup.
- Runtime state uses named Docker volumes.
- Generated reviewer evidence is written under `artifacts/`.
- Secrets are loaded from ignored environment files or Docker secrets.
- A documented cleanup command removes containers, networks, and volumes.
- No service mounts `/var/run/docker.sock`.
- Published ports bind to `127.0.0.1` by default.

## 6. Reproducibility

- Container image versions must be pinned; mutable `latest` tags are forbidden.
- Mutable `SNAPSHOT` tags require a documented reason and a lock/update process.
- Configuration must live in version control.
- Startup must use health checks and dependency conditions where practical.
- A fresh clone must be sufficient to reproduce the environment.
- Architecture-specific limitations must be documented.

## 7. Security

The project must demonstrate, not merely describe:

- OpenID Connect login through Keycloak;
- JWT validation by BaSyx services;
- at least `reader`, `editor`, `uploader`, and `admin` roles;
- a denied write using a read-only identity;
- an accepted write using an authorized identity;
- service-to-service client credentials;
- separation between browser-facing and internal service addresses.

Demo credentials may exist only in an explicit development realm and must be
labelled insecure for production. Production-hardening guidance must cover TLS,
secret rotation, database credentials, image scanning, backups, and auditing.

## 8. AAS learning content

The learner must be able to explain:

- asset versus digital representation;
- Asset Administration Shell versus submodel;
- global identifier versus `idShort`;
- semantic identifier and Concept Description;
- AssetInformation and `assetKind`;
- submodel element types;
- why registries and discovery are different;
- AAS repository versus AAS environment;
- AASX packaging;
- serialization versus storage;
- endpoint descriptors;
- interoperability boundaries and what AAS does not solve.

The project must show the same information in:

- source product data;
- generated AAS model;
- AASX package;
- repository REST representation;
- registry descriptor;
- web UI;
- MongoDB-backed persistence.

## 9. Automation and testing

Required checks:

- static configuration validation;
- Compose configuration validation;
- Python lint/type or syntax checks;
- unit tests for model generation and identifier encoding;
- service health checks;
- AASX package structure validation;
- API smoke tests;
- registry and discovery tests;
- persistence test across restart/recreation;
- authentication and authorization tests;
- distributed exchange test;
- idempotency test for repeated bootstrap;
- cleanup test or documented dry run.

The canonical command must be:

```sh
make verify
```

It must produce a human-readable summary and machine-readable evidence under
`artifacts/`.

## 10. Development pipeline

Local pipeline stages:

1. `make format-check`
2. `make lint`
3. `make unit`
4. `make config`
5. `make up`
6. `make integration`
7. `make verify`
8. `make down`

CI must run all checks that do not require privileged or unavailable services,
then run Docker integration tests when the runner supports them.

## 11. Git discipline

- Commit coherent milestones, not arbitrary time slices.
- Use imperative Conventional Commit subjects.
- Do not mix unrelated changes.
- Run the relevant validation before each commit.
- Never commit `.env`, credentials intended for non-demo use, generated
  artifacts, database files, or caches.
- Push each validated milestone so remote history documents the build.
- Tag the first independently reproducible release as `v1.0.0`.

Expected milestone sequence:

1. project contract and learning structure;
2. minimal persistent AAS stack;
3. model generation and AASX tooling;
4. secured stack and RBAC;
5. distributed exchange;
6. end-to-end verification and final documentation.

## 12. Definition of done

The project is done only when:

- every required architecture component exists;
- `make verify` passes from a clean clone;
- the documented guided tour matches actual behavior;
- all acceptance evidence is generated;
- teardown leaves no project containers, networks, or volumes;
- no undocumented manual repair is required;
- the remote repository contains the complete commit history;
- known limitations are explicit;
- a reviewer can answer the chapter questions using observable evidence.

If any item is unverified, report it as incomplete rather than weakening this
definition.

