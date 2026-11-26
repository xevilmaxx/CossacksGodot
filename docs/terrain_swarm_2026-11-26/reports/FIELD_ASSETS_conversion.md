# FIELD-ASSETS — donor crop stages and mesh variants converted

Date: 2026-11-26  
Scope: derived `variant3d/assets/models/` assets and manifest only.

## Delivered

- 16 donor crop textures converted to 512×256 RGBA PNG:
  - mature `field` and `field1..7`
  - winter `fieldw` and `field1w..field7w`
- Donor sources are 512×256 DXT5 with 10 mip levels.
- Derived PNGs preserve the decoded RGBA and alpha arrays exactly; no color
  retouch, synthetic gold, or generated detail.
- Two donor mesh variants converted:
  - `field2.obj/.mtl`: 495 vertices, 495 UVs, 496 faces
  - `field3.obj/.mtl`: 546 vertices, 546 UVs, 544 faces
- OBJ round-trip preserves vertices, UVs, faces and UV-face indices using
  17-digit float serialization; both include `usemtl model` and resolving MTL
  texture paths.
- `field.obj` geometry is unchanged. `field.mtl` now references `field1.png` so
  the original field1 mesh keeps its original art.
- `assets/models/manifest.json` records the corrected mature texture provenance
  and 15 extra-asset mappings. Model count remains 299.

Full source/derived hashes and provenance are in:
`variant3d/assets/models/obj/shared/terrain/field_conversion.manifest.json`.

## Remaining integration limits

- New PNG/OBJ assets still require Godot import; no `.import` sidecars were
  created by the static worker.
- PNGs carry only base-level pixels; donor DDS mip chains are not preserved.
- `FIX-FIELD-DONOR` currently renders the field1 mesh for all stages. Donor
  `RandomMeshName=True` selection across field1/2/3 remains separate work.
- Pixel/topology equality is not visual parity. No donor/port A/B frame exists.

No donor binary was executed or copied. No parity claim is made.
