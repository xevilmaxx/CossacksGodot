# SPEC — donor-faithful terrain (assembly in progress)

This folder will hold the **cited specification** that the fresh variant3d terrain
module implements. It is assembled by COORD from the 31 worker reports, not
written from memory. Every statement must carry a donor path:offset:line or a
Craft Anything evidence id, and a label:

`[O]` observed · `[D]` derived · `[I]` inferred · `[U]` UNVERIFIED · `PORT APPROXIMATION`

No donor-parity claim without a real donor GPU A/B frame.

## Planned sections (fill from landed reports)

| File | Content | Source workers | State |
|---|---|---|---|
| `00_EVIDENCE_INDEX.md` | every evidence id / donor path used, with what it proves | all | PENDING |
| `01_WORLD_DATA_MODEL.md` | per-cell fields, grid sizes, coordinate conventions, dump contract | A01 + D04 | PENDING |
| `02_SEED_AND_RNG.md` | keys, RNG state update, call-order discipline | D02 | PENDING |
| `03_MASK_TO_HEIGHT.md` | TGA decode, channels, blur/smoothing, relief formula, thresholds | D03 + F04 | PENDING |
| `04_PATTERN_STAMPING.md` | `.pattern`/`pattern.lib` records, blend modes, scale/min/max, family selection | D05 + F01 + F02 | PENDING |
| `05_WATER_SHORE.md` | water level, shore smoothing, wave binding, tile selection | D06 + F06 | PENDING |
| `06_TILE_AND_ATLAS.md` | tile ids, smoothing rules, detail pass, block/atlas mapping | D08 + F03 + F05 | PENDING |
| `07_RESOURCES.md` | mines, stone, forests, starting resources, keep-clear zones, owner fill | D07 + F08 | PENDING |
| `08_FIELDS_AND_PROPS.md` | mill fields, pumps, decor, relief prop silhouettes | F07 + A04 | PENDING |
| `09_EDITOR_PARAMETERS.md` | editor UI → cfg parameter map and generation commands | D09 + F09 + F03 | PENDING |
| `10_STAGE_ORDER.md` | the ordered generation pipeline with inputs/outputs and telemetry | A02 | PENDING |
| `11_ASSET_CONVERSION.md` | donor → runtime compiler inputs/outputs, provenance manifest, licence guard | A03 + P02 + P04 | PENDING |
| `12_QA_AND_INTEGRATION.md` | gates, determinism, A/B protocol, backend switch, rollback | A05 + A06 + P03 | PENDING |

## Contradiction register

_maintained by COORD as reports land — do not delete resolved entries_

| # | Conflicting claims | Workers | Resolution | Evidence |
|---|---|---|---|---|
| — | — | — | — | — |

## Out-of-scope register

| Feature | Reason deferred | Source |
|---|---|---|
| Missions / campaigns / network | D-12 singleplayer skirmish only | variant3d charter |
| Spring/Autumn seasons | DLC/mod, not vanilla skirmish (verify in F10) | RC_TERRAIN S8 |
| Donor skinned-rig visual parity | bone parents unreadable (V72) | V72 report |
