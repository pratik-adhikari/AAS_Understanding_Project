# 08 — Troubleshooting

## Docker exists but the daemon is unavailable

**Symptom:** `permission denied while trying to connect to the Docker API`.

**Cause:** the Docker client exists, but the selected context's socket is not
available to the current process or user.

**Proof:** `docker context show` followed by `docker info`.

**Repair:** start the correct daemon or restore access to its socket. Do not
install BaSyx dependencies on the host as a workaround.

## BuildKit cannot resolve PyPI

**Symptom:** the tooling image build repeatedly reports `NewConnectionError`
and `Try again` while requesting `/simple/basyx-python-sdk/`.

**Cause:** BuildKit's isolated build network cannot reach the configured DNS
resolver even though normal image pulls work.

**Repair used here:** the tooling build explicitly uses the host build network
in `compose.yaml`. Runtime containers still use project-specific networks.

**Prevention:** validate `make build` on every supported Docker setup. In a
locked-down corporate environment, configure an approved Python package mirror
and replace the public index rather than opening arbitrary egress.

## A service is healthy but Curl cannot reach a loopback port

Container health and host connectivity are separate checks. Confirm:

```sh
docker compose ps
curl -v http://127.0.0.1:8081/actuator/health
```

If the first succeeds and the second fails, inspect port publishing, host
firewall policy, and whether the command itself is running in a sandbox that
blocks loopback access.
