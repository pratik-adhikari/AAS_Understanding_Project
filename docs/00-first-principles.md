# 00 — Why AAS Exists

## The problem before the acronym

Imagine two companies exchanging information about one industrial gripper.
The manufacturer calls its maximum gripping force `max_grip_force`. The buyer
calls the same fact `F_max`. One value is expressed in newtons, another system
expects kilonewtons, and neither side agrees where the value belongs in a JSON
document.

Both systems can exchange bytes. They still cannot reliably exchange meaning.

This is the first problem AAS addresses: a shared structure for describing an
asset and its information in a machine-readable, semantically identifiable
way.

## Start with the physical asset

An **asset** is the thing of interest. It may be:

- an individual physical gripper;
- a type of gripper sold as a product;
- a machine;
- a software service;
- a document or other non-physical object.

The asset exists independently of AAS. Creating an AAS does not create,
simulate, or control the asset.

## Add the administration shell

An **Asset Administration Shell** is the standardized digital representation
associated with the asset. It gives the asset a globally identifiable entry
point and groups its information into submodels.

The shell is deliberately small. Most useful information belongs in submodels.

## Split information by purpose

A **submodel** groups information for one coherent aspect:

- Digital Nameplate;
- technical data;
- operational measurements;
- maintenance;
- carbon footprint;
- documentation.

This separation matters because different organizations can standardize,
exchange, authorize, and update each aspect independently.

## Give values meaning

A property such as:

```text
value = 450
```

is ambiguous. A useful model needs at least:

- what the value means;
- its datatype;
- its unit;
- its place in the model;
- a stable identifier for its concept.

AAS supplies the structural machinery. Submodel templates and external semantic
repositories supply domain agreements.

## What AAS does not do

AAS does not automatically:

- discover the correct business meaning;
- make bad source data accurate;
- define every industry concept;
- provide a physics simulation;
- synchronize a physical asset;
- secure a deployment by itself;
- guarantee two organizations modeled the same concept consistently.

It creates an interoperability framework. The quality of identifiers, semantics,
templates, governance, and implementation still matters.

## Predict before continuing

If a shell contains every property directly, what becomes difficult when a
supplier wants to share the nameplate but not operational measurements?

Expected reasoning: separating information into submodels permits independent
exchange, lifecycle, endpoints, and authorization.

## Checkpoint

You should now be able to answer:

1. Why is exchanging JSON insufficient for semantic interoperability?
2. What exists first: the asset or its AAS?
3. Why is most information stored in submodels?
4. What important problems remain outside AAS?

