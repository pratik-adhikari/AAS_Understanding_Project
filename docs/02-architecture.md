# 02 — System Architecture

## Begin with responsibilities

AAS is an information model and a family of interfaces. It does not require all
information to live in one process. This project separates components so their
responsibilities remain observable.

| Component | Owns | Does not own |
| --- | --- | --- |
| AAS Environment | Shells, submodels, Concept Descriptions and serialization endpoints | User identities |
| AAS Registry | Descriptors telling clients where shells can be reached | The shells themselves |
| Submodel Registry | Descriptors telling clients where submodels can be reached | Submodel content |
| AAS Discovery | Mappings from asset identifiers to shell identifiers | Repository endpoint details |
| MongoDB | Persistent implementation data for BaSyx services | AAS semantics |
| Web UI | Human navigation and editing experience | Authoritative data |
| MQTT broker | Change-event transport | Repository state |

## Data path

```text
Browser
  |
  +--> Web UI :3000
          |
          +--> AAS Environment :8081 --> MongoDB
          +--> AAS Registry    :8082 --> MongoDB
          +--> SM Registry     :8083 --> MongoDB
          +--> AAS Discovery   :8084 --> MongoDB

AAS Environment --> Registry integration
                --> Discovery integration
                --> MQTT change events
```

Only loopback ports are published. MongoDB and MQTT remain reachable through
Docker networks but are not exposed to the host.

## Registry versus discovery

These are easy to confuse.

- Discovery answers: “Given this asset identifier, which AAS identifiers
  represent it?”
- The AAS Registry answers: “Given this AAS identifier, at which endpoint can I
  access it?”

The two-step lookup avoids hard-coding a repository URL into every client.

## Persistence boundary

The JSON file under `data/aas/` is bootstrap input. MongoDB is runtime storage.
After startup, deleting a container must not delete the model because container
filesystems are disposable and the database uses a named volume.

Later tests will prove this distinction by changing repository data, recreating
the service container, and verifying the change remains.

## Failure predictions

- If the UI fails, REST access should still work.
- If a registry fails, known direct repository URLs should still work, but
  dynamic endpoint lookup fails.
- If discovery fails, clients cannot map an asset identifier to its shell.
- If MongoDB fails, persistent services cannot read or write their state.
- If MQTT fails, the baseline configuration prevents the AAS Environment from
  becoming ready because event publication is enabled.

These predictions become useful only when verified. The integration suite will
turn each important statement into a check.

## Checkpoint

1. Why does a registry store descriptors rather than shell content?
2. Which component maps an asset identifier to an AAS identifier?
3. Why is a named volume different from a bind-mounted bootstrap file?
4. What remains usable if only the web UI is unavailable?
