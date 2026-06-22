# 04 — Guided End-to-End Tour

Do not begin by clicking through the UI. Follow the information as it changes
representation.

## 1. Inspect the source facts

Open `data/products/learning-gripper.yaml`.

Identify:

- the asset ID;
- the shell ID;
- the submodel ID;
- one property value;
- that property's semantic ID.

Prediction: which identifiers should remain visible after JSON generation?

## 2. Generate exchange artifacts

```sh
make generate
diff -u data/aas/learning-gripper.json data/generated/learning-gripper.json
unzip -l data/generated/learning-gripper.aasx
```

Expected: the tracked bootstrap JSON and generated JSON are identical, and the
AASX contains an OPC package with AAS data.

## 3. Start the baseline

```sh
make up
make smoke
```

Open `artifacts/aas-shells.json`. Locate the same shell ID from step 1.

## 4. Compare repository and registry

```sh
curl -s http://127.0.0.1:8081/shells
curl -s http://127.0.0.1:8082/shell-descriptors
```

The first response contains the shell's information model. The second contains
a descriptor with endpoints. They are related but not interchangeable.

## 5. Inspect through the UI

Open <http://127.0.0.1:3000>.

Navigate from `LearningGripper` to `DigitalNameplate`, then find
`MaxGripForce`. Confirm that the UI did not invent a new value: it visualizes
the repository representation you already inspected.

## 6. Prove persistence

```sh
make persistence-test
```

The test creates a marker through the API, recreates the AAS Environment
container, and proves the marker remains. The container was disposable; the
MongoDB volume was not.

## 7. Add security

```sh
make secure-up
make security-test
```

Compare 401 and 403 results using `docs/05-security.md`.

## 8. Exchange with an independent partner

```sh
make exchange-up
make exchange-test
```

Open the partner UI at <http://127.0.0.1:3100> and confirm the copied shell.

## Review questions

1. At which step did product facts become AAS model objects?
2. Which representation is authoritative for API clients?
3. Why did data survive container recreation?
4. What extra information did the registry provide?
5. What evidence proves the partner did not share the primary database?
