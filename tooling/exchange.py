"""Copy AAS objects between independent repositories through standardized APIs."""

from __future__ import annotations

import argparse
import json
import time
import urllib.error
import urllib.request
from pathlib import Path
from typing import Any


def request_json(
    method: str,
    url: str,
    payload: dict[str, Any] | None = None,
) -> tuple[int, dict[str, Any]]:
    body = None
    headers = {"Accept": "application/json"}
    if payload is not None:
        body = json.dumps(payload).encode()
        headers["Content-Type"] = "application/json"

    request = urllib.request.Request(url, data=body, headers=headers, method=method)
    try:
        with urllib.request.urlopen(request, timeout=15) as response:
            content = response.read()
            return response.status, json.loads(content) if content else {}
    except urllib.error.HTTPError as error:
        content = error.read()
        parsed = json.loads(content) if content else {}
        return error.code, parsed


def list_results(base_url: str, resource: str) -> list[dict[str, Any]]:
    status, response = request_json("GET", f"{base_url}/{resource}")
    if status != 200:
        raise RuntimeError(f"GET {resource} failed with HTTP {status}: {response}")
    return response.get("result", [])


def create_idempotently(base_url: str, resource: str, obj: dict[str, Any]) -> int:
    status, response = request_json("POST", f"{base_url}/{resource}", obj)
    if status not in (201, 409):
        raise RuntimeError(
            f"POST {resource} failed with HTTP {status}: {response}"
        )
    return status


def exchange(
    source: str,
    target: str,
    target_registry: str,
) -> dict[str, Any]:
    shells = list_results(source, "shells")
    submodels = list_results(source, "submodels")
    concepts = list_results(source, "concept-descriptions")

    if not shells or not submodels:
        raise RuntimeError("source must contain at least one shell and submodel")

    statuses = {
        "concept_descriptions": [
            create_idempotently(target, "concept-descriptions", concept)
            for concept in concepts
        ],
        "submodels": [
            create_idempotently(target, "submodels", submodel)
            for submodel in submodels
        ],
        "shells": [
            create_idempotently(target, "shells", shell) for shell in shells
        ],
    }

    for _ in range(20):
        target_shells = list_results(target, "shells")
        descriptors = list_results(target_registry, "shell-descriptors")
        if len(target_shells) >= len(shells) and len(descriptors) >= len(shells):
            break
        time.sleep(1)
    else:
        raise RuntimeError("target repository or registry did not converge")

    source_ids = sorted(shell["id"] for shell in shells)
    target_ids = sorted(shell["id"] for shell in target_shells)
    if not set(source_ids).issubset(target_ids):
        raise RuntimeError("target is missing one or more source shell IDs")

    return {
        "source_shell_ids": source_ids,
        "target_shell_ids": target_ids,
        "target_descriptor_count": len(descriptors),
        "post_statuses": statuses,
        "transport": "AAS HTTP APIs",
        "database_copy_used": False,
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", required=True)
    parser.add_argument("--target", required=True)
    parser.add_argument("--target-registry", required=True)
    parser.add_argument("--evidence", type=Path, required=True)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    evidence = exchange(args.source, args.target, args.target_registry)
    args.evidence.parent.mkdir(parents=True, exist_ok=True)
    args.evidence.write_text(
        json.dumps(evidence, indent=2) + "\n",
        encoding="utf-8",
    )
    print(json.dumps(evidence, indent=2))


if __name__ == "__main__":
    main()

