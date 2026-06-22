# 10 — Limitations, Versions, and Sources

## Known limitations

This project is a complete learning and demonstration environment, not a
production reference architecture.

- The Digital Nameplate is deliberately small and does not implement every
  element of the current IDTA template.
- The semantic identifiers under `example.org` are teaching identifiers, not
  governed industrial dictionary entries.
- Distributed exchange is a point-in-time API copy, not synchronization or a
  dataspace protocol.
- Keycloak runs in development mode over HTTP.
- MongoDB is single-node and has no replica set.
- RBAC uses broad wildcard rules to make role behavior visible.
- The BaSyx Java server line used here is still published as milestone 2.0.0
  releases.
- The BaSyx GUI does not publish a semantic stable tag; this project pins an
  immutable commit tag.

These constraints are acceptable only because the project states and tests its
learning goals explicitly.

## Pinned versions

As checked on June 22, 2026:

- Eclipse BaSyx Java server SDK: `2.0.0-milestone-11`;
- Eclipse BaSyx Python SDK: `2.0.1`;
- Keycloak: `26.6.3`;
- MongoDB image: `8.0.12`;
- Mosquitto: `2.0.22`;
- BaSyx GUI commit image: `8c601af`.

Update versions intentionally. Run the full verification after every change.

## Upstream Schunk reference

The original project supplies a Schunk `EGU_50_IL_M_B.aasx`. It is not copied
into this repository by default. Fetch and checksum it with:

```sh
make fetch-reference
```

The result is stored under ignored `data/reference/`. Keeping it separate makes
the distinction between an external reference artifact and this project's
reproducible teaching model explicit.

## Primary sources

- [Original LEVEL3 project brief](https://github.com/arkadiahn/LEVEL3-projects/tree/main/aas-digital-twin-infrastructure)
- [Eclipse BaSyx Java server SDK](https://github.com/eclipse-basyx/basyx-java-server-sdk)
- [BaSyx minimal Compose example](https://github.com/eclipse-basyx/basyx-java-server-sdk/tree/main/examples/BaSyxMinimal)
- [BaSyx secured example](https://github.com/eclipse-basyx/basyx-java-server-sdk/tree/main/examples/BaSyxSecured)
- [Eclipse BaSyx Python SDK](https://github.com/eclipse-basyx/basyx-python-sdk)
- [IDTA specifications](https://industrialdigitaltwin.org/en/content-hub/aasspecifications)
- [IDTA submodel template repository](https://smt-repo.admin-shell-io.com/)
- [Keycloak documentation](https://www.keycloak.org/documentation)

When prose in this repository conflicts with a normative specification, the
normative specification wins. Open an issue and correct the teaching material.
