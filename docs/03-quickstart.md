# 03 — Quickstart

## 1. Check the host

```sh
make prerequisites
```

This checks Docker, Compose, Git, Curl, Make, and access to the Docker daemon.

## 2. Create local configuration

```sh
make init
```

This copies `.env.example` to the ignored `.env` file. The supplied credentials
are development-only.

## 3. Validate before starting

```sh
make config
```

The rendered configuration is written to `artifacts/compose.rendered.yaml`.
Inspect it when a variable or port does not behave as expected.

## 4. Start the infrastructure

```sh
make pull
make up
```

Compose waits for container health checks. First startup downloads several
images and takes longer than later starts.

## 5. Observe the same model through multiple interfaces

- Web UI: <http://127.0.0.1:3000>
- AAS Repository: <http://127.0.0.1:8081/shells>
- Submodel Repository: <http://127.0.0.1:8081/submodels>
- AAS Registry: <http://127.0.0.1:8082/shell-descriptors>
- Submodel Registry: <http://127.0.0.1:8083/submodel-descriptors>
- Discovery: <http://127.0.0.1:8084/lookup/shells>

Run the baseline machine check:

```sh
make smoke
```

Responses are preserved under `artifacts/`.

## 6. Stop or erase

Stop containers while keeping database state:

```sh
make down
```

Remove containers, networks, and the project database volume:

```sh
make clean
```

The latter is intentionally destructive to this project's local runtime data.

## Troubleshooting first startup

Use:

```sh
make ps
docker compose logs --tail=200 SERVICE_NAME
```

If `make prerequisites` says the Docker daemon is unavailable, fix Docker
access first. Installing more application packages will not help because all
application dependencies are containerized.
