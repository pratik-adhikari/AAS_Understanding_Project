# 09 — Independent Review Checklist

## Automated review

From a clean clone:

```sh
make init
make verify
```

Expected final line:

```text
PASS: full end-to-end verification completed
```

Inspect `artifacts/verification-summary.txt` and the per-topology evidence.

## Manual review

- [ ] The host has no project-specific Java, Python, Node, MongoDB, or Keycloak
      installation.
- [ ] `make generate` produces JSON and AASX.
- [ ] Generated JSON exactly matches tracked bootstrap JSON.
- [ ] The baseline UI shows `LearningGripper`.
- [ ] Repository and registry responses are visibly different.
- [ ] The persistence marker survives AAS Environment recreation.
- [ ] Unauthenticated secured reads return 401.
- [ ] Reader writes return 403.
- [ ] Editor writes succeed.
- [ ] Service-client authentication succeeds.
- [ ] The partner starts with an independent MongoDB container and volume.
- [ ] Exchange creates the shell and descriptor on the partner.
- [ ] Repeated exchange is idempotent.
- [ ] `make clean` removes runtime data when explicitly requested.

## Oral review questions

1. Define asset, AAS, submodel, and submodel element without using circular
   definitions.
2. Explain `id` versus `idShort`.
3. Explain structural type versus semantic ID.
4. Distinguish repository, registry, and discovery.
5. Explain AASX versus REST exchange.
6. Explain serialization versus MongoDB persistence.
7. Explain authentication versus authorization.
8. State what this project does not solve about real industrial integration.

If an answer relies only on memorized wording, use the guided tour to point to
the corresponding observable object or request.
