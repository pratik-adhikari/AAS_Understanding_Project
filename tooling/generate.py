"""Generate a small AAS environment and AASX package from product facts."""

from __future__ import annotations

import argparse
import datetime
from pathlib import Path
from typing import Any

import yaml
from basyx.aas import model
from basyx.aas.adapter import aasx
from basyx.aas.adapter.json import read_aas_json_file, write_aas_json_file
from pyecma376_2 import OPCCoreProperties


VALUE_TYPES = {
    "string": model.datatypes.String,
    "double": model.datatypes.Double,
    "integer": model.datatypes.Integer,
    "boolean": model.datatypes.Boolean,
}


def external_reference(identifier: str) -> model.ExternalReference:
    """Create a semantic reference to a globally identified concept."""
    return model.ExternalReference(
        (
            model.Key(
                type_=model.KeyTypes.GLOBAL_REFERENCE,
                value=identifier,
            ),
        )
    )


def load_source(path: Path) -> dict[str, Any]:
    """Load and minimally validate the human-maintained product source."""
    with path.open(encoding="utf-8") as source_file:
        source = yaml.safe_load(source_file)

    if source.get("schema_version") != 1:
        raise ValueError("unsupported or missing source schema_version")

    for section in ("asset", "aas", "nameplate"):
        if section not in source:
            raise ValueError(f"missing required section: {section}")

    if not source["nameplate"].get("properties"):
        raise ValueError("nameplate.properties must not be empty")

    return source


def build_environment(
    source: dict[str, Any],
) -> tuple[model.DictObjectStore[model.Identifiable], str]:
    """Transform source facts into normative BaSyx model objects."""
    asset = source["asset"]
    shell_source = source["aas"]
    nameplate_source = source["nameplate"]

    properties: set[model.Property] = set()
    concept_descriptions: list[model.ConceptDescription] = []

    for item in nameplate_source["properties"]:
        value_type_name = item["value_type"]
        if value_type_name not in VALUE_TYPES:
            raise ValueError(f"unsupported value_type: {value_type_name}")

        properties.add(
            model.Property(
                id_short=item["id_short"],
                value_type=VALUE_TYPES[value_type_name],
                value=item["value"],
                semantic_id=external_reference(item["semantic_id"]),
            )
        )
        concept_descriptions.append(
                model.ConceptDescription(
                    id_=item["semantic_id"],
                    id_short=item["id_short"],
                    description=model.MultiLanguageTextType(
                        {"en": item["definition"]}
                    ),
                )
        )

    nameplate = model.Submodel(
        id_=nameplate_source["id"],
        id_short=nameplate_source["id_short"],
        kind=model.ModellingKind.INSTANCE,
        semantic_id=external_reference(nameplate_source["semantic_id"]),
        submodel_element=properties,
    )

    shell = model.AssetAdministrationShell(
        id_=shell_source["id"],
        id_short=shell_source["id_short"],
        asset_information=model.AssetInformation(
            asset_kind=model.AssetKind[asset["kind"].upper()],
            global_asset_id=asset["id"],
            asset_type=asset["type"],
        ),
        submodel={model.ModelReference.from_referable(nameplate)},
    )

    object_store: model.DictObjectStore[model.Identifiable] = (
        model.DictObjectStore([shell, nameplate, *concept_descriptions])
    )
    return object_store, shell.id


def write_outputs(
    object_store: model.DictObjectStore[model.Identifiable],
    shell_id: str,
    json_output: Path,
    aasx_output: Path,
) -> None:
    """Write deterministic JSON and an AASX package, then read both back."""
    json_output.parent.mkdir(parents=True, exist_ok=True)
    aasx_output.parent.mkdir(parents=True, exist_ok=True)

    write_aas_json_file(json_output, object_store, indent=2)
    read_aas_json_file(json_output, failsafe=False)

    file_store = aasx.DictSupplementaryFileContainer()
    with aasx.AASXWriter(aasx_output) as writer:
        writer.write_aas(
            aas_ids=[shell_id],
            object_store=object_store,
            file_store=file_store,
        )
        metadata = OPCCoreProperties()
        metadata.creator = "AAS Understanding Project"
        metadata.created = datetime.datetime(
            2026, 1, 1, tzinfo=datetime.timezone.utc
        )
        writer.write_core_properties(metadata)

    roundtrip_store: model.DictObjectStore[model.Identifiable] = (
        model.DictObjectStore()
    )
    roundtrip_files = aasx.DictSupplementaryFileContainer()
    with aasx.AASXReader(aasx_output) as reader:
        reader.read_into(roundtrip_store, roundtrip_files)

    if roundtrip_store.get_identifiable(shell_id) is None:
        raise RuntimeError("AASX roundtrip did not contain the generated shell")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--json-output", type=Path, required=True)
    parser.add_argument("--aasx-output", type=Path, required=True)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    source = load_source(args.source)
    object_store, shell_id = build_environment(source)
    write_outputs(object_store, shell_id, args.json_output, args.aasx_output)
    print(f"generated {args.json_output}")
    print(f"generated {args.aasx_output}")


if __name__ == "__main__":
    main()
