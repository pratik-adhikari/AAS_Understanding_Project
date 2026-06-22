from pathlib import Path

from basyx.aas import model
from basyx.aas.adapter import aasx
from basyx.aas.adapter.json import read_aas_json_file

from tooling.generate import build_environment, load_source, write_outputs


SOURCE = Path("data/products/learning-gripper.yaml")
SHELL_ID = "https://example.org/aas/learning-gripper/001"
SUBMODEL_ID = "https://example.org/submodels/nameplate/learning-gripper/001"


def test_source_builds_connected_shell_and_submodel() -> None:
    store, shell_id = build_environment(load_source(SOURCE))

    assert shell_id == SHELL_ID
    shell = store.get_identifiable(SHELL_ID)
    submodel = store.get_identifiable(SUBMODEL_ID)

    assert isinstance(shell, model.AssetAdministrationShell)
    assert isinstance(submodel, model.Submodel)
    assert len(shell.submodel) == 1
    assert len(submodel.submodel_element) == 4


def test_semantic_references_and_concepts_are_present() -> None:
    store, _ = build_environment(load_source(SOURCE))
    submodel = store.get_identifiable(SUBMODEL_ID)

    assert isinstance(submodel, model.Submodel)
    max_force = submodel.submodel_element.get_object_by_attribute(
        "id_short", "MaxGripForce"
    )
    assert isinstance(max_force, model.Property)
    assert max_force.value == 450.0
    assert max_force.semantic_id is not None
    assert isinstance(
        store.get_identifiable("https://example.org/concepts/MaxGripForce"),
        model.ConceptDescription,
    )


def test_json_and_aasx_roundtrip(tmp_path: Path) -> None:
    store, shell_id = build_environment(load_source(SOURCE))
    json_path = tmp_path / "environment.json"
    aasx_path = tmp_path / "environment.aasx"

    write_outputs(store, shell_id, json_path, aasx_path)

    strict_json_store = read_aas_json_file(json_path, failsafe=False)
    assert strict_json_store.get_identifiable(SHELL_ID) is not None

    aasx_store: model.DictObjectStore[model.Identifiable] = (
        model.DictObjectStore()
    )
    files = aasx.DictSupplementaryFileContainer()
    with aasx.AASXReader(aasx_path) as reader:
        reader.read_into(aasx_store, files)

    assert aasx_store.get_identifiable(SHELL_ID) is not None
    assert aasx_store.get_identifiable(SUBMODEL_ID) is not None


def test_generation_is_byte_reproducible(tmp_path: Path) -> None:
    store, shell_id = build_environment(load_source(SOURCE))
    first_json = tmp_path / "first.json"
    first_aasx = tmp_path / "first.aasx"
    second_json = tmp_path / "second.json"
    second_aasx = tmp_path / "second.aasx"

    write_outputs(store, shell_id, first_json, first_aasx)
    write_outputs(store, shell_id, second_json, second_aasx)

    assert first_json.read_bytes() == second_json.read_bytes()
    assert first_aasx.read_bytes() == second_aasx.read_bytes()


def test_rejects_unknown_source_version(tmp_path: Path) -> None:
    source = tmp_path / "invalid.yaml"
    source.write_text("schema_version: 99\n", encoding="utf-8")

    try:
        load_source(source)
    except ValueError as error:
        assert "schema_version" in str(error)
    else:
        raise AssertionError("invalid source version was accepted")
