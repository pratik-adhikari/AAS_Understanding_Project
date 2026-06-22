# 01 — The AAS Information Model

The source facts live in `data/products/learning-gripper.yaml`. The generator
turns them into AAS model objects. Keeping both layers visible separates
business facts from their standardized representation.

## Identifier versus `idShort`

The shell has:

```yaml
id: https://example.org/aas/learning-gripper/001
id_short: LearningGripper
```

The `id` is globally unique and is used by APIs, references, registries, and
organizations. `idShort` is a short, human-friendly name in its local context.
Changing `idShort` should not change the identity of the shell.

## AssetInformation

The shell states which asset it represents:

- `globalAssetId`: the globally unique asset identifier;
- `assetKind`: whether this represents an individual instance or a type;
- `assetType`: an optional classification string.

The asset identifier and shell identifier differ deliberately. The physical
thing and its digital representation are not the same entity.

## Shell-to-submodel reference

The shell does not embed the entire Digital Nameplate. It contains a model
reference to the submodel's identifier. This allows submodels to have their own
identity, endpoint, lifecycle, and authorization.

## Submodel elements

The example uses `Property`, the simplest element:

- `ManufacturerName` is a string;
- `SerialNumber` is a string;
- `MaxGripForce` is a double.

AAS also supports collections, lists, ranges, files, blobs, references,
relationships, operations, events, entities, and capability descriptions.
Choose an element type based on information semantics, not visual preference.

## Semantic IDs

`MaxGripForce` is structurally a double property. Its semantic ID says which
concept the property means:

```text
https://example.org/concepts/MaxGripForce
```

Without this stable semantic reference, another organization cannot safely
distinguish gripping force from holding force or closing force merely from the
local name.

## Concept Descriptions

The example includes a Concept Description for each property. A Concept
Description is an identifiable semantic object available inside an AAS
environment. Production models often reference externally governed dictionaries
or richer embedded data specifications.

This project keeps the descriptions intentionally small so the relationship is
visible:

```text
Property --semanticId--> Concept Description
```

## Serialization versus storage

JSON and XML are serializations: byte representations used to transfer or save
the information model. MongoDB is an implementation-specific persistence
mechanism used by this BaSyx deployment.

A client should depend on the standardized AAS API and model, not MongoDB's
internal collections.

## AASX

AASX is an OPC package: a ZIP-based container that can hold an AAS environment,
metadata, relationships, and supplementary files. It is useful for exchanging
a self-contained package.

Run:

```sh
make generate
unzip -l data/generated/learning-gripper.aasx
```

The generated JSON and AASX are written under `data/generated/`. The generator
reads both back through the SDK before reporting success. Generated outputs are
ignored by Git because source data plus generator code are the reproducible
inputs.

## Checkpoint

1. Why must the asset ID differ conceptually from the shell ID?
2. Which identifier should external systems persist: `id` or `idShort`?
3. What extra meaning does a semantic ID add to `valueType=double`?
4. Why is MongoDB not part of the interoperable contract?
5. When is AASX more useful than an API response?
