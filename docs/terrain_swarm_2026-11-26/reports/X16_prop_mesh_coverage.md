---
id: X16
ticket: "TERRAIN-SWARM-2026-11-26 / X16 — donor BaseName → converted mesh coverage ledger"
title: "Implementation-ready mesh-coverage ledger for F08's forest / stone / mine families and relief props"
date: 2026-11-26
status: DELIVERED__READ_ONLY__NO_GODOT_JOB__NO_CODE_OR_ASSET_EDIT__DONOR_READ_ONLY
owner: "worker X16 (reports to COORD)"
labels: [O, D, I, U, "PORT APPROXIMATION", "NO_PARITY_CLAIM"]
scope: "Exactly one repo file: docs/terrain_swarm_2026-11-26/reports/X16_prop_mesh_coverage.md. Donor read READ-ONLY at C:\\Games\\Cossacks 3; no donor binary run, copied or committed; no Godot runner job; no git, source, asset, config or test edit. Throwaway probes live in %TEMP%\\opencode\\x16_*.py."
inputs_read_first: [CHARTER.md, SWARM_BOARD.md, reports/F08_flora_minerals.md, reports/P02_asset_inventory.md, spec/08_FIELDS_AND_PROPS.md, reports/X05_pattern_lib_validation.md, IMPLEMENTATION_PLAN.md]
parity_guard: "No donor GPU A/B frame was produced or examined. 'Converted' means a derived OBJ/PNG exists on disk with a manifest provenance entry; it does NOT mean the rendered result matches the donor. All visual statements are UNVERIFIED."
---

# X16 — donor BaseName → converted mesh coverage ledger (for I09 / I02 / I03)

## 0. Conventions and method

- **[O]** = observed on disk or in a cited file/line this pass. **[D]** = deterministic
  arithmetic or set operation over observed data. **[I]** = plausible reading without
  runtime proof. **[U]** = UNVERIFIED. **PORT APPROXIMATION** = explicit port substitute,
  not donor behaviour. No donor-parity claim anywhere in this report.
- Path shorthands: **`D:`** = `C:\Games\Cossacks 3\data\` (READ-ONLY); **`R:`** = workspace
  root `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3`; mesh paths shown
  without prefix are under `R:variant3d/assets/models/obj/`; albedo paths under
  `R:variant3d/assets/models/tex/`. `res://assets/...` is the Godot-side spelling;
  the physical path is `R:variant3d/assets/...` after the nation-bucket migration (P02 §2/R5).
- Family membership and per-pattern object counts come from **F08 §3** (the donor
  object census); the BaseName list below was re-derived from `D:pattern\pattern.lib`
  using X05's validated 680-record line index at
  `%TEMP%\opencode\patternlib_validate\patternlib_index.json` (derived data, not donor
  bytes copied into the repo). Family members that have no `pattern.lib` section are
  marked UNRESOLVED, following F08 E16.
- Prop → actor → mesh resolution: `D:objects\env\<name>.prop`
  (`mainproperty.BaseName`, `actorproperty.LODActorName`, `DefaultMeshName`,
  `DefaultMaterialName`, `UseableWinterMaterials`) → `D:actors\actors.lib`
  (`LODActorFileName`) → `D:actors\env\<actor>.actor`
  (`ActorList.Items[n].MeshObjects.LoadFromFile`). This is the F08 E12 chain,
  re-derived here for **all 141 BaseNames** rather than only the worked examples.
- Converted-asset facts: `R:variant3d/assets/models/manifest.json` (299 `models`
  entries, 110 terrain-relevant sids per P02), `Get-ChildItem -Recurse` over
  `models/obj/**` (299 OBJ, 0 GLB/GLTF), and Pillow 12.1.1 header reads of every
  albedo PNG referenced by the matched sids. No image or mesh was modified.
- Transform availability was tested both by JSON parse and literal grep of
  `R:variant3d/assets/terrain/mountain_props.json`.

## 1. Executive summary

1. **[O/D]** The F08 census resolves to **30 families / 213 named members / 196
   `pattern.lib` sections / 9,938 donor `Objects` records / 141 unique BaseNames**.
   The 17 unresolved members are exactly `n_desert_frt_big_1..17` of
   `desert_forests_big` (F08 E16 name mismatch); no BaseName can be assigned to that
   family (F19). All other 29 families resolve 100% of their members.
2. **[O]** **75/141 BaseNames (53.2%) have an exact converted OBJ** for their
   `DefaultMeshName` variant; **3/141** (`oak.2`, `oak.3`, `oak.4`) have only a
   same-actor fallback (`tree_oak.obj`, built from `oak1.osm`); **63/141 (44.7%)**
   have no converted OBJ and no GLB/GLTF anywhere under `models/obj/**` — verified
   twice (Python walk + `Get-ChildItem`, both 299 OBJ / 0 GLB).
3. **[O]** **No forest, stone or mine `Objects` transform is exported in
   `mountain_props.json`.** Literal greps for `minegold`, `pine1`, `stones`,
   `palm`, `leaftree`, `grassforest`, `drytree`, `smallstones`, `frt_`, `stn_`,
   `mng_`, `mni_`, `mnc_`, `d_stn`, `e_frt` each returned **0 hits**; the file's
   `base_name_census` contains only the 8 relief names. Every one of the 141 rows
   therefore needs a **new I03 export** of `pattern.lib` `Objects[]`
   (`BaseName`, `Position`, `Direction`, `Up`, `Scaling`).
4. **[O]** A **2048² albedo exists for only 6/141 BaseNames**: `minegold`,
   `minegolds`, `mineiron`, `mineirons`, `minecoal`, `minecoals`
   (`shared/buildings/mine_{gold,iron,coal}.png`, 2048² RGB). All other converted
   families are 256²/512²/1024² (trees, bushes, ferns, flowers, plantain, stones,
   small stones, shore stones). Non-2048² does not mean "no texture": it means the
   literal 2048² gate fails; exact dimensions are in the ledger.
5. **[O]** **19/141 BaseNames with a converted mesh use a different donor material
   than the converted sid**: 15 desert stones (`stonesdesert*`, `smallstonesdesert*`
   → `stones.dds` / `smallstones.dds`), 3 desert ores (`minegolds/irons/coals`
   → `minegold/iron/coal.dds`) and `plantainyellow` (→ `plantsatlas.dds`).
   None of the 141 has a converted **winter** albedo; `prop_winter_materials.json`
   is data-only and unwired (P02 §4).
6. **[D]** With gates = (exact converted mesh) ∧ (donor material variant converted)
   ∧ (2048² albedo) ∧ (transforms exported), **COMPLETE = 0 / 141** for forest,
   stone and mine BaseNames; **PARTIAL = 78**, **MISSING = 63**. The four relief
   props `terrainmesh1..4` pass all four gates and are the only COMPLETE entries in
   this ledger. `terrainmeshdesert1..4` have 23 exported records but no desert
   material conversion → PARTIAL. This is a coverage statement only; **no parity
   claim**.
7. **[O/U]** `mountain_props.json` also carries 11 `i_mnt_*` sections whose relief
   names are absent from `donor_patterns.json`; their prop records exist but I02's
   float-window export does not. This is a concrete, cited gap for I02.

## 2. Evidence table

| # | Claim | Evidence (path / line / file) | Label | Caveat |
|---|---|---|---|---|
| E1 | 19 forest / 5 stone / 6 mine families, 213 named members, 196 resolvable sections, 9,938 `Objects` records | F08 §3 tables (`reports/F08_flora_minerals.md:125-198`); `D:pattern\pattern.lib` via X05 `patternlib_index.json` (680 records) | [O]/[D] | 17 `n_desert_frt_big_*` unresolved (F08 E16) |
| E2 | `BaseName` chain to `.prop` / `.actor` / `.osm` / material, all 141 resolved | `D:objects\env\*.prop`; `D:actors\actors.lib:1248,1517,1577`; `D:actors\env\*.actor` (`MeshObjects.LoadFromFile`) | [O] | Suffix `.N` → mesh index is engine-side [U] (F08 R4) |
| E3 | 299 OBJ / 0 GLB/GLTF in `models/obj/**` | PowerShell `Get-ChildItem -Recurse -File` + Python `os.walk`, counts agree 299/299 | [O] | Two instruments, same result |
| E4 | Manifest has 299 `models`; terrain sid mesh paths cite `D:actors\env\*.osm`, but physical files are bucketed | `variant3d/assets/models/manifest.json` (`models[]`, `assets.obj`); P02 §2/R5 | [O] | Legacy flat `obj`/`texture_png` absolute paths are provenance metadata only |
| E5 | 141 unique BaseNames; 75 exact OBJ, 3 fallback-only, 63 none | `%TEMP%\opencode\x16_exact.tsv` built from E2+E4; re-checked with `Get-ChildItem` per missing stem and manifest `Contains()` | [O]/[D] | "None" means no OBJ/GLB with that stem, not no donor art |
| E6 | No forest/stone/mine transforms in `mountain_props.json` | `variant3d/assets/terrain/mountain_props.json`: `by_pattern`/`props`/`pattern_meta` 30 relief sections; 15 literal greps = 0; `derived_stats.base_name_census` = 8 relief names | [O] | Two instruments (json parse + grep) |
| E7 | 2048² albedo only for 6 ore BaseNames | `models/tex/shared/buildings/mine_{gold,iron,coal}.png` = 2048² RGB, 5,306,512/5,270,454/5,329,010 B; all matched `shared/terrain/*.png` ≤ 2048 with only `rock_sea*`/`terrainmesh*` at 2048 (not used by these families) | [O] | Pillow 12.1.1 IHDR reads |
| E8 | 19 material-variant mismatches | donor `DefaultMaterialName` vs manifest `texture` stem; e.g. `D:objects\env\stonesdesert10.prop` → `stonesdesert` vs `rock_stones10` → `stones.dds` | [O]/[D] | Winter aliases exist in donor props but no converted winter PNG |
| E9 | Relief props and their transforms | `models/obj/shared/terrain/terrainmesh1..4.obj`; `models/tex/shared/terrain/terrainmesh1..4.png` 2048²; `mountain_props.json` 112 records, `bbox_m` 7.38/8.06/9.54/6.92 | [O] | `bbox_m` and sid selection are PORT APPROXIMATION (P02 U6) |
| E10 | 23 desert-relief records with no converted art | `mountain_props.json` `base_name_census.terrainmeshdesert1..4` = 2/5/7/9; no `*desert*` in `models/obj/**` or `models/tex/**`; 0 manifest matches, 0 `prop_winter_materials.json` matches | [O] | Donor `terrainmeshdesertN.prop` reuses `terrainmesh1..4.actor` with a different material |
| E11 | `i_mnt_*` records exist without `.pattern` export | `mountain_props.json` has 5 `i_mnt_big_*` + 5 `i_mnt_long_*`; `variant3d/assets/terrain/patterns/donor_patterns.json` has `g_mnt_*`/`desert_mnt_*` but no `i_mnt_*` | [O] | 43 families / 282 patterns total in `donor_patterns.json` (F08 E18) |
| E12 | Port currently synthesises forest/stone nodes, does not stamp donor objects | F08 §6 (`game.gd:740-869`, `pattern_gen.gd:369-427`); P02 §4 (`donor_patterns.json` wired, `mountain_props.json` via relief module only) | [O] repo / PORT APPROXIMATION | No donor parity implied |

## 3. Coverage ledger

**Gap codes** (each appears in the last column of C.1):

- **G1** = no converted mesh at all for the donor `DefaultMeshName` (no OBJ, no GLB).
- **G2** = exact donor mesh variant not converted; a same-actor OBJ exists but maps to
  a different `.osm` (`oak.2/.3/.4` → `tree_oak.obj` from `oak1.osm`).
- **G3** = donor material variant not converted (converted sid uses a different
  donor `.dds`); winter variants also unconverted for every row.
- **G4** = no `pattern.lib` `Objects[]` transform export for this pattern family
  (Position / Direction / Up / Scaling all require new I03 export).
- **G5** = no 2048² albedo (a lower-resolution converted albedo may exist; see column).

**Status rule**: `MISSING` iff G1; otherwise `PARTIAL`. `COMPLETE` requires all four
gates to pass; it is achieved only by `terrainmesh1..4` in C.3. Family codes in C.1
are defined by C.2 (F01–F19 forest, S01–S05 stone, M01–M06 mine).

### C.1 Unified BaseName ledger (141 BaseNames)

| # | BaseName | Families | Donor prop → actor → DefaultMeshName | Material (winter) | Converted mesh (`res://assets/models/obj/...`) | 2048² albedo | Transform source | Status / gap |
|---:|---|---|---|---|---|---|---|---|
| 1 | `burdock` | F13 F11 F12 F01 S03 | `D:objects/env/burdock.prop` → `D:actors/env/burdock.actor` → `burdock1.mesh` | `plantsatlas` / `plantsatlasw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 2 | `burdock.1` | S03 | `D:objects/env/burdock1.prop` → `D:actors/env/burdock.actor` → `burdock1.mesh` | `plantsatlas` / `plantsatlasw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 3 | `burdock.2` | M03 S01 S02 S03 | `D:objects/env/burdock2.prop` → `D:actors/env/burdock.actor` → `burdock2.mesh` | `plantsatlas` / `plantsatlasw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 4 | `burdock.3` | S01 S02 S03 | `D:objects/env/burdock3.prop` → `D:actors/env/burdock.actor` → `burdock3.mesh` | `plantsatlas` / `plantsatlasw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 5 | `bushes` | M03 M01 M02 | `D:objects/env/bushes.prop` → `D:actors/env/bushes.actor` → `bushes1.mesh` | `bushes` / `bushesw` | `shared/terrain/bush1.obj` 81,332 | NO (512x256) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 6 | `chamomile` | F11 F02 | `D:objects/env/chamomile.prop` → `D:actors/env/chamomile.actor` → `chamomile1.mesh` | `plantsatlas` / `plantsatlasw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 7 | `chamomile.1` | F11 F12 F09 F05 M03 M02 | `D:objects/env/chamomile1.prop` → `D:actors/env/chamomile.actor` → `chamomile2.mesh` | `plantsatlas` / `plantsatlasw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 8 | `chamomile.2` | F09 F10 F01 S02 S03 | `D:objects/env/chamomile2.prop` → `D:actors/env/chamomile.actor` → `chamomile3.mesh` | `plantsatlas` / `plantsatlasw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 9 | `desert1` | F16 F17 F18 M04 M05 S04 S05 | `D:objects/env/desert1.prop` → `D:actors/env/desert1.actor` → `desert1.1.mesh` | `desert1` / `desert1w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 10 | `desert3` | F16 F17 F18 | `D:objects/env/desert3.prop` → `D:actors/env/desert3.actor` → `desert3.1.mesh` | `desert3` / `desert3w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 11 | `desert3.1` | S04 S05 | `D:objects/env/desert3.1.prop` → `D:actors/env/desert3.actor` → `desert3.1.mesh` | `desert3` / `desert3w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 12 | `desert3.3` | S04 S05 | `D:objects/env/desert3.3.prop` → `D:actors/env/desert3.actor` → `desert3.3.mesh` | `desert3` / `desert3w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 13 | `desert4` | F16 F17 M06 | `D:objects/env/desert4.prop` → `D:actors/env/desert4.actor` → `desert4.1.mesh` | `desert4` / `desert4w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 14 | `desert5` | F16 F17 M06 M04 M05 | `D:objects/env/desert5.prop` → `D:actors/env/desert5.actor` → `desert5.1.mesh` | `desert5` / `desert5w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 15 | `drybushes` | F08 S02 | `D:objects/env/drybushes.prop` → `D:actors/env/drybushes.actor` → `drybushes1.mesh` | `drybushes` / `drybushesw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 16 | `drybushes.1` | F08 | `D:objects/env/drybushes1.prop` → `D:actors/env/drybushes.actor` → `drybushes1.mesh` | `drybushes` / `drybushesw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 17 | `drytree` | F13 F15 F11 F12 F01 | `D:objects/env/drytree.prop` → `D:actors/env/drytree.actor` → `drytree1.mesh` | `drytree1` / `drytree1w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 18 | `drytree1.1` | F11 F12 | `D:objects/env/drytree1.prop` → `D:actors/env/drytree.actor` → `drytree1.mesh` | `drytree1` / `drytree1w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 19 | `drytree3.3` | F11 F12 S01 | `D:objects/env/drytree3.prop` → `D:actors/env/drytree.actor` → `drytree3.mesh` | `drytree1` / `drytree1w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 20 | `drytree4.4` | S01 | `D:objects/env/drytree4.prop` → `D:actors/env/drytree.actor` → `drytree4.mesh` | `drytree1` / `drytree1w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 21 | `fern` | F14 F11 F12 F09 F10 F08 F07 F06 F01 F02 F03 M03 M01 M02 | `D:objects/env/fern.prop` → `D:actors/env/fern.actor` → `fern1.mesh` | `fern` / `fernw` | `shared/terrain/fern1.obj` 11,199 | NO (256x256) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 22 | `fern.1` | F01 M03 S01 S02 S03 | `D:objects/env/fern1.prop` → `D:actors/env/fern.actor` → `fern1.mesh` | `fern` / `fernw` | `shared/terrain/fern1.obj` 11,199 | NO (256x256) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 23 | `fir` | F13 F14 F15 F11 F12 F09 F10 F08 F01 F02 F03 S01 S02 | `D:objects/env/fir.prop` → `D:actors/env/fir.actor` → `fir1.mesh` | `fir1` / `—` | `shared/terrain/tree_fir.obj` 63,481 | NO (1024x1024) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 24 | `fir1.1` | F11 M02 | `D:objects/env/fir1.prop` → `D:actors/env/fir.actor` → `fir1.mesh` | `fir1` / `—` | `shared/terrain/tree_fir.obj` 63,481 | NO (1024x1024) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 25 | `firsmall1` | F13 F14 F15 F11 F12 F09 F10 F07 F01 F02 F03 M03 M01 M02 S01 S03 | `D:objects/env/firsmall.prop` → `D:actors/env/firsmall.actor` → `firsmall1.mesh` | `firsmall1` / `firsmall1w` | `shared/terrain/tree_firsmall1.obj` 48,272 | NO (1024x1024) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 26 | `firsmall1.1` | S01 S02 | `D:objects/env/firsmall1.prop` → `D:actors/env/firsmall.actor` → `firsmall1.mesh` | `firsmall1` / `firsmall1w` | `shared/terrain/tree_firsmall1.obj` 48,272 | NO (1024x1024) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 27 | `firsmall4.4` | S03 | `D:objects/env/firsmall4.prop` → `D:actors/env/firsmall.actor` → `firsmall4.mesh` | `firsmall1` / `firsmall1w` | `shared/terrain/tree_firsmall4.obj` 48,804 | NO (1024x1024) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 28 | `flowers` | F11 F12 F09 F01 | `D:objects/env/flowers.prop` → `D:actors/env/flowers.actor` → `flowers1.mesh` | `plantsatlas` / `plantsatlasw` | `shared/terrain/flower1.obj` 7,364 | NO (1024x1024) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 29 | `flowers.1` | F11 F12 M01 S03 | `D:objects/env/flowers1.prop` → `D:actors/env/flowers.actor` → `flowers1.mesh` | `plantsatlas` / `plantsatlasw` | `shared/terrain/flower1.obj` 7,364 | NO (1024x1024) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 30 | `flowers.2` | S03 | `D:objects/env/flowers2.prop` → `D:actors/env/flowers.actor` → `flowers2.mesh` | `plantsatlas` / `plantsatlasw` | `shared/terrain/flower2.obj` 12,860 | NO (1024x1024) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 31 | `flowers.3` | M01 S03 | `D:objects/env/flowers3.prop` → `D:actors/env/flowers.actor` → `flowers3.mesh` | `plantsatlas` / `plantsatlasw` | `shared/terrain/flower3.obj` 10,055 | NO (1024x1024) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 32 | `grass` | F09 | `D:objects/env/grass.prop` → `D:actors/env/grass.actor` → `grass1.mesh` | `plantsatlas` / `plantsatlasw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 33 | `grass.1` | F13 F15 F09 S02 | `D:objects/env/grass1.prop` → `D:actors/env/grass.actor` → `grass1.mesh` | `plantsatlas` / `plantsatlasw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 34 | `grass.2` | F13 F14 F15 F09 F04 F05 S01 S02 | `D:objects/env/grass2.prop` → `D:actors/env/grass.actor` → `grass2.mesh` | `plantsatlas` / `plantsatlasw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 35 | `grass.3` | F11 F09 F04 F05 S01 S02 | `D:objects/env/grass3.prop` → `D:actors/env/grass.actor` → `grass3.mesh` | `plantsatlas` / `plantsatlasw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 36 | `grass.4` | F13 F15 F11 F12 F01 M03 M01 S03 | `D:objects/env/grass4.prop` → `D:actors/env/grass.actor` → `grass4.mesh` | `plantsatlas` / `plantsatlasw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 37 | `grass.5` | F13 F15 F11 F12 F01 S03 | `D:objects/env/grass5.prop` → `D:actors/env/grass.actor` → `grass5.mesh` | `plantsatlas` / `plantsatlasw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 38 | `grasschamomile` | F11 F12 F09 F02 S03 | `D:objects/env/grasschamomile.prop` → `D:actors/env/grasschamomile.actor` → `grasschamomile1.mesh` | `plantsatlas` / `—` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 39 | `grassdesert.4` | F17 S04 S05 | `D:objects/env/grassdesert4.prop` → `D:actors/env/grass.actor` → `grass4.mesh` | `plantsyellowatlas` / `plantsyellowatlasw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 40 | `grassdesert.5` | F17 | `D:objects/env/grassdesert5.prop` → `D:actors/env/grass.actor` → `grass5.mesh` | `plantsyellowatlas` / `plantsyellowatlasw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 41 | `grassforest` | F11 F01 | `D:objects/env/grassforest.prop` → `D:actors/env/grassforest.actor` → `grassforest1.mesh` | `grassforest` / `grassforestw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 42 | `grassforest.1` | F13 F11 F12 F09 F10 F08 F06 F01 F02 F04 F05 S01 S02 | `D:objects/env/grassforest1.prop` → `D:actors/env/grassforest.actor` → `grassforest1.mesh` | `grassforest` / `grassforestw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 43 | `grassforest.2` | F14 F11 F12 F08 F07 F06 F01 F02 F03 F04 F05 S01 S02 | `D:objects/env/grassforest2.prop` → `D:actors/env/grassforest.actor` → `grassforest2.mesh` | `grassforest` / `grassforestw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 44 | `grassforest.3` | F11 F12 F09 F10 F06 F01 F02 F03 F04 F05 | `D:objects/env/grassforest3.prop` → `D:actors/env/grassforest.actor` → `grassforest3.mesh` | `grassforest` / `grassforestw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 45 | `grassforest.4` | S01 | `D:objects/env/grassforest4.prop` → `D:actors/env/grassforest.actor` → `grassforest4.mesh` | `grassforest` / `grassforestw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 46 | `grassforest.5` | S01 | `D:objects/env/grassforest5.prop` → `D:actors/env/grassforest.actor` → `grassforest5.mesh` | `grassforest` / `grassforestw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 47 | `grassleafforest` | F11 F12 F01 | `D:objects/env/grassleafforest.prop` → `D:actors/env/grassleafforest.actor` → `grassleafforest1.mesh` | `grassleafforest` / `grassleafforestw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 48 | `grassleafforest.1` | F13 F14 F15 F11 F12 | `D:objects/env/grassleafforest1.prop` → `D:actors/env/grassleafforest.actor` → `grassleafforest1.mesh` | `grassleafforest` / `grassleafforestw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 49 | `grassleafforest.2` | F13 F14 F15 F11 F12 F01 | `D:objects/env/grassleafforest2.prop` → `D:actors/env/grassleafforest.actor` → `grassleafforest2.mesh` | `grassleafforest` / `grassleafforestw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 50 | `grassleafforest.3` | F13 F14 F11 F12 | `D:objects/env/grassleafforest3.prop` → `D:actors/env/grassleafforest.actor` → `grassleafforest3.mesh` | `grassleafforest` / `grassleafforestw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 51 | `horseradish` | F13 F11 F12 F09 F10 F01 F02 F03 M01 M02 S01 S02 S03 | `D:objects/env/horseradish.prop` → `D:actors/env/horseradish.actor` → `horseradish1.mesh` | `plantsatlas` / `plantsatlasw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 52 | `horseradish.1` | F07 F01 S03 | `D:objects/env/horseradish1.prop` → `D:actors/env/horseradish.actor` → `horseradish1.mesh` | `plantsatlas` / `plantsatlasw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 53 | `leaftree` | F11 F12 S01 S02 | `D:objects/env/leaftree.prop` → `D:actors/env/leaftree.actor` → `leaftree1.mesh` | `leaftree1` / `leaftree1w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 54 | `leaftree.1` | F11 | `D:objects/env/leaftree1.prop` → `D:actors/env/leaftree.actor` → `leaftree1.mesh` | `leaftree1` / `leaftree1w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 55 | `leaftree.2` | F09 | `D:objects/env/leaftree2.prop` → `D:actors/env/leaftree.actor` → `leaftree2.mesh` | `leaftree1` / `leaftree1w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 56 | `leaftree.3` | F09 | `D:objects/env/leaftree3.prop` → `D:actors/env/leaftree.actor` → `leaftree3.mesh` | `leaftree1` / `leaftree1w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 57 | `leaftree.4` | F09 | `D:objects/env/leaftree4.prop` → `D:actors/env/leaftree.actor` → `leaftree4.mesh` | `leaftree1` / `leaftree1w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 58 | `minecoal` | M03 | `D:objects/env/minecoal.prop` → `D:actors/env/minecoal.actor` → `minecoal.mesh` | `minecoal` / `—` | `shared/buildings/mine_coal.obj` 91,920 | YES 2048² (`shared/buildings/mine_coal.png`) | NEW EXPORT | **PARTIAL** — G4 |
| 59 | `minecoals` | M06 | `D:objects/env/minecoals.prop` → `D:actors/env/minecoal.actor` → `minecoal.mesh` | `minecoals` / `—` | `shared/buildings/mine_coal.obj` 91,920 | YES 2048² (`shared/buildings/mine_coal.png`) | NEW EXPORT | **PARTIAL** — G3, G4 |
| 60 | `minegold` | M01 | `D:objects/env/minegold.prop` → `D:actors/env/minegold.actor` → `minegold.mesh` | `minegold` / `—` | `shared/buildings/mine_gold.obj` 91,920 | YES 2048² (`shared/buildings/mine_gold.png`) | NEW EXPORT | **PARTIAL** — G4 |
| 61 | `minegolds` | M04 | `D:objects/env/minegolds.prop` → `D:actors/env/minegold.actor` → `minegold.mesh` | `minegolds` / `—` | `shared/buildings/mine_gold.obj` 91,920 | YES 2048² (`shared/buildings/mine_gold.png`) | NEW EXPORT | **PARTIAL** — G3, G4 |
| 62 | `mineiron` | M02 | `D:objects/env/mineiron.prop` → `D:actors/env/mineiron.actor` → `mineiron.mesh` | `mineiron` / `—` | `shared/buildings/mine_iron.obj` 91,920 | YES 2048² (`shared/buildings/mine_iron.png`) | NEW EXPORT | **PARTIAL** — G4 |
| 63 | `mineirons` | M05 | `D:objects/env/mineirons.prop` → `D:actors/env/mineiron.actor` → `mineiron.mesh` | `mineirons` / `—` | `shared/buildings/mine_iron.obj` 91,920 | YES 2048² (`shared/buildings/mine_iron.png`) | NEW EXPORT | **PARTIAL** — G3, G4 |
| 64 | `oak` | F11 F12 S01 | `D:objects/env/oak.prop` → `D:actors/env/oak.actor` → `oak1.mesh` | `oak1` / `oak1w` | `shared/terrain/tree_oak.obj` 159,600 | NO (1024x1024) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 65 | `oak.1` | F13 F14 F15 F11 F12 S01 | `D:objects/env/oak1.prop` → `D:actors/env/oak.actor` → `oak1.mesh` | `oak1` / `oak1w` | `shared/terrain/tree_oak.obj` 159,600 | NO (1024x1024) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 66 | `oak.2` | F13 F14 F15 F11 F12 | `D:objects/env/oak2.prop` → `D:actors/env/oak.actor` → `oak2.mesh` | `oak1` / `oak1w` | **no exact variant**; fallback `shared/terrain/tree_oak.obj` 159,600 | NO (1024x1024) | NEW EXPORT | **PARTIAL** — G2, G4, G5 |
| 67 | `oak.3` | F13 F14 F15 F11 F12 | `D:objects/env/oak3.prop` → `D:actors/env/oak.actor` → `oak3.mesh` | `oak1` / `oak1w` | **no exact variant**; fallback `shared/terrain/tree_oak.obj` 159,600 | NO (1024x1024) | NEW EXPORT | **PARTIAL** — G2, G4, G5 |
| 68 | `oak.4` | F13 F14 F15 S01 | `D:objects/env/oak4.prop` → `D:actors/env/oak.actor` → `oak4.mesh` | `oak1` / `oak1w` | **no exact variant**; fallback `shared/terrain/tree_oak.obj` 159,600 | NO (1024x1024) | NEW EXPORT | **PARTIAL** — G2, G4, G5 |
| 69 | `palm` | F16 F17 F18 M06 M04 M05 S04 S05 | `D:objects/env/palm.prop` → `D:actors/env/palm.actor` → `palm1.mesh` | `palm1` / `palm1w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 70 | `palmsmall` | F16 F17 F18 M04 S04 S05 | `D:objects/env/palmsmall.prop` → `D:actors/env/palmsmall.actor` → `palmsmall1.mesh` | `palm1` / `palm1w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 71 | `palmsmall1.1` | M06 M04 M05 | `D:objects/env/palmsmall1.prop` → `D:actors/env/palmsmall.actor` → `palmsmall1.mesh` | `palm1` / `palm1w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 72 | `palmsmall3.3` | M06 M04 M05 | `D:objects/env/palmsmall3.prop` → `D:actors/env/palmsmall.actor` → `palmsmall3.mesh` | `palm1` / `palm1w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 73 | `pine1` | F14 F15 F11 F12 F09 F10 F08 F07 F06 F01 F02 F03 F04 F05 M03 M01 S01 S02 | `D:objects/env/pine.prop` → `D:actors/env/pine.actor` → `pine1.mesh` | `pine1` / `pine1w` | `shared/terrain/tree_pine.obj` 110,441 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 74 | `pine1.1` | F08 F01 | `D:objects/env/pine1.prop` → `D:actors/env/pine.actor` → `pine1.mesh` | `pine1` / `pine1w` | `shared/terrain/tree_pine.obj` 110,441 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 75 | `pinebroken1` | F11 F12 F09 F08 F06 F01 F02 S01 S02 | `D:objects/env/pinebroken.prop` → `D:actors/env/pinebroken.actor` → `pinebroken1.mesh` | `pinebroken1` / `pinebroken1w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 76 | `pinebroken1.1` | F06 F02 S01 S02 | `D:objects/env/pinebroken1.prop` → `D:actors/env/pinebroken.actor` → `pinebroken1.mesh` | `pinebroken1` / `pinebroken1w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 77 | `pinebroken2.2` | F01 F02 | `D:objects/env/pinebroken2.prop` → `D:actors/env/pinebroken.actor` → `pinebroken2.mesh` | `pinebroken1` / `pinebroken1w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 78 | `pinebroken3.3` | F01 | `D:objects/env/pinebroken3.prop` → `D:actors/env/pinebroken.actor` → `pinebroken3.mesh` | `pinebroken1` / `pinebroken1w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 79 | `pinebroken4.4` | F09 F10 F02 | `D:objects/env/pinebroken4.prop` → `D:actors/env/pinebroken.actor` → `pinebroken4.mesh` | `pinebroken1` / `pinebroken1w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 80 | `pinebrokenmoss1` | F11 F12 F09 F06 | `D:objects/env/pinebrokenmoss.prop` → `D:actors/env/pinebrokenmoss.actor` → `pinebrokenmoss1.mesh` | `pinebrokenmoss1` / `pinebrokenmoss1w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 81 | `pinebrokenmoss1.1` | F11 F09 F10 F01 S01 S02 | `D:objects/env/pinebrokenmoss1.prop` → `D:actors/env/pinebrokenmoss.actor` → `pinebrokenmoss1.mesh` | `pinebrokenmoss1` / `pinebrokenmoss1w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 82 | `pinebrokenmoss2.2` | F11 F09 F10 F01 S01 S02 | `D:objects/env/pinebrokenmoss2.prop` → `D:actors/env/pinebrokenmoss.actor` → `pinebrokenmoss2.mesh` | `pinebrokenmoss1` / `pinebrokenmoss1w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 83 | `pinebrokenmoss3.3` | F11 F09 F01 S01 S02 | `D:objects/env/pinebrokenmoss3.prop` → `D:actors/env/pinebrokenmoss.actor` → `pinebrokenmoss3.mesh` | `pinebrokenmoss1` / `pinebrokenmoss1w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 84 | `pinebrokenmoss4.4` | F11 F09 F01 S01 S02 | `D:objects/env/pinebrokenmoss4.prop` → `D:actors/env/pinebrokenmoss.actor` → `pinebrokenmoss4.mesh` | `pinebrokenmoss1` / `pinebrokenmoss1w` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 85 | `pinedry1` | F09 F10 F08 F06 F01 F05 S01 S02 | `D:objects/env/pinedry.prop` → `D:actors/env/pinedry.actor` → `pinedry1.mesh` | `pinedry1` / `pinedry1w` | `shared/terrain/tree_pinedry1.obj` 67,868 | NO (512x1024) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 86 | `pinesmall1` | F14 F15 F11 F12 F09 F10 F08 F07 F06 F01 F02 F03 F04 F05 M03 M01 M02 S01 S02 | `D:objects/env/pinesmall.prop` → `D:actors/env/pinesmall.actor` → `pinesmall1.mesh` | `pinesmall1` / `pinesmall1w` | `shared/terrain/tree_pinesmall1.obj` 52,481 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 87 | `pinesmall1.1` | F08 S03 | `D:objects/env/pinesmall1.prop` → `D:actors/env/pinesmall.actor` → `pinesmall1.mesh` | `pinesmall1` / `pinesmall1w` | `shared/terrain/tree_pinesmall1.obj` 52,481 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 88 | `pinesmall2.2` | S03 | `D:objects/env/pinesmall2.prop` → `D:actors/env/pinesmall.actor` → `pinesmall2.mesh` | `pinesmall1` / `pinesmall1w` | `shared/terrain/tree_pinesmall2.obj` 31,169 | NO (512x512) | NEW EXPORT | **PARTIAL** — G3, G4, G5 |
| 89 | `pinesmall4.4` | S03 | `D:objects/env/pinesmall4.prop` → `D:actors/env/pinesmall.actor` → `pinesmall4.mesh` | `pinesmall1` / `pinesmall1w` | `shared/terrain/tree_pinesmall4.obj` 37,010 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 90 | `pinestump.1` | F09 | `D:objects/env/pinestump1.prop` → `D:actors/env/pinestump.actor` → `pinestump1.mesh` | `pinestump` / `pinestumpw` | `shared/terrain/tree_stump1.obj` 1,880 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 91 | `plant` | M03 M01 M02 S01 | `D:objects/env/plant.prop` → `D:actors/env/plant.actor` → `plant1.mesh` | `plantsatlas` / `plantsatlasw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 92 | `plant.5` | M01 | `D:objects/env/plant5.prop` → `D:actors/env/plant.actor` → `plant5.mesh` | `plantsatlas` / `plantsatlasw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 93 | `plantain` | F13 F14 F11 F12 F09 F01 F02 F03 S01 S03 | `D:objects/env/plantain.prop` → `D:actors/env/plantain.actor` → `plantain1.mesh` | `plantsatlas` / `plantsatlasw` | `shared/terrain/plantain1.obj` 9,231 | NO (1024x1024) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 94 | `plantain.1` | F13 F15 F11 F12 F07 F01 F03 F05 M03 M01 M02 S03 | `D:objects/env/plantain1.prop` → `D:actors/env/plantain.actor` → `plantain1.mesh` | `plantsatlas` / `plantsatlasw` | `shared/terrain/plantain1.obj` 9,231 | NO (1024x1024) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 95 | `plantain.2` | F13 F15 F11 F12 F09 F01 S03 | `D:objects/env/plantain2.prop` → `D:actors/env/plantain.actor` → `plantain2.mesh` | `plantsatlas` / `plantsatlasw` | `shared/terrain/plantain2.obj` 9,947 | NO (1024x1024) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 96 | `plantain.3` | F11 F12 F01 F05 M03 M01 M02 S03 | `D:objects/env/plantain3.prop` → `D:actors/env/plantain.actor` → `plantain3.mesh` | `plantsatlas` / `plantsatlasw` | `shared/terrain/plantain3.obj` 8,234 | NO (1024x1024) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 97 | `plantainyellow` | F16 F18 M06 M04 M05 | `D:objects/env/plantainyellow.prop` → `D:actors/env/plantain.actor` → `plantain1.mesh` | `plantsyellowatlas` / `plantsyellowatlasw` | `shared/terrain/plantain1.obj` 9,231 | NO (1024x1024) | NEW EXPORT | **PARTIAL** — G3, G4, G5 |
| 98 | `plantyellow` | F16 F17 F18 M06 M04 M05 | `D:objects/env/plantyellow.prop` → `D:actors/env/plant.actor` → `plant1.mesh` | `plantsyellowatlas` / `plantsyellowatlasw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 99 | `plantyellow.1` | S04 S05 | `D:objects/env/plantyellow1.prop` → `D:actors/env/plant.actor` → `plant1.mesh` | `plantsyellowatlas` / `plantsyellowatlasw` | **NONE** | NO (none) | NEW EXPORT | **MISSING** — G1, G4, G5 |
| 100 | `smallstones` | S01 S02 | `D:objects/env/smallstones.prop` → `D:actors/env/smallstones.actor` → `smallstones1.mesh` | `smallstones` / `—` | `shared/terrain/rock_smallstones1.obj` 16,663 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 101 | `smallstones.1` | S01 S02 S03 | `D:objects/env/smallstones1.prop` → `D:actors/env/smallstones.actor` → `smallstones1.mesh` | `smallstones` / `—` | `shared/terrain/rock_smallstones1.obj` 16,663 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 102 | `smallstones.2` | S03 | `D:objects/env/smallstones2.prop` → `D:actors/env/smallstones.actor` → `smallstones2.mesh` | `smallstones` / `—` | `shared/terrain/rock_smallstones2.obj` 20,949 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 103 | `smallstones.3` | S03 | `D:objects/env/smallstones3.prop` → `D:actors/env/smallstones.actor` → `smallstones3.mesh` | `smallstones` / `—` | `shared/terrain/rock_smallstones3.obj` 21,202 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 104 | `smallstones.4` | S03 | `D:objects/env/smallstones4.prop` → `D:actors/env/smallstones.actor` → `smallstones4.mesh` | `smallstones` / `—` | `shared/terrain/rock_smallstones4.obj` 15,396 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 105 | `smallstones.5` | S01 S02 S03 | `D:objects/env/smallstones5.prop` → `D:actors/env/smallstones.actor` → `smallstones5.mesh` | `smallstones` / `—` | `shared/terrain/rock_smallstones5.obj` 24,025 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 106 | `smallstones.6` | S01 S02 S03 | `D:objects/env/smallstones6.prop` → `D:actors/env/smallstones.actor` → `smallstones6.mesh` | `smallstones` / `—` | `shared/terrain/rock_smallstones6.obj` 19,530 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 107 | `smallstonesdesert` | S04 S05 | `D:objects/env/smallstonesdesert.prop` → `D:actors/env/smallstones.actor` → `smallstones1.mesh` | `smallstonesdesert` / `—` | `shared/terrain/rock_smallstones1.obj` 16,663 | NO (512x512) | NEW EXPORT | **PARTIAL** — G3, G4, G5 |
| 108 | `smallstonesdesert.1` | S04 S05 | `D:objects/env/smallstonesdesert1.prop` → `D:actors/env/smallstones.actor` → `smallstones1.mesh` | `smallstonesdesert` / `—` | `shared/terrain/rock_smallstones1.obj` 16,663 | NO (512x512) | NEW EXPORT | **PARTIAL** — G3, G4, G5 |
| 109 | `smallstonesdesert.2` | S04 S05 | `D:objects/env/smallstonesdesert2.prop` → `D:actors/env/smallstones.actor` → `smallstones2.mesh` | `smallstonesdesert` / `—` | `shared/terrain/rock_smallstones2.obj` 20,949 | NO (512x512) | NEW EXPORT | **PARTIAL** — G3, G4, G5 |
| 110 | `smallstonesdesert.3` | S04 S05 | `D:objects/env/smallstonesdesert3.prop` → `D:actors/env/smallstones.actor` → `smallstones3.mesh` | `smallstonesdesert` / `—` | `shared/terrain/rock_smallstones3.obj` 21,202 | NO (512x512) | NEW EXPORT | **PARTIAL** — G3, G4, G5 |
| 111 | `smallstonesdesert.4` | S04 S05 | `D:objects/env/smallstonesdesert4.prop` → `D:actors/env/smallstones.actor` → `smallstones4.mesh` | `smallstonesdesert` / `—` | `shared/terrain/rock_smallstones4.obj` 15,396 | NO (512x512) | NEW EXPORT | **PARTIAL** — G3, G4, G5 |
| 112 | `smallstonesdesert.5` | S04 S05 | `D:objects/env/smallstonesdesert5.prop` → `D:actors/env/smallstones.actor` → `smallstones5.mesh` | `smallstonesdesert` / `—` | `shared/terrain/rock_smallstones5.obj` 24,025 | NO (512x512) | NEW EXPORT | **PARTIAL** — G3, G4, G5 |
| 113 | `smallstonesdesert.6` | S04 S05 | `D:objects/env/smallstonesdesert6.prop` → `D:actors/env/smallstones.actor` → `smallstones6.mesh` | `smallstonesdesert` / `—` | `shared/terrain/rock_smallstones6.obj` 19,530 | NO (512x512) | NEW EXPORT | **PARTIAL** — G3, G4, G5 |
| 114 | `smallstonessea` | F18 | `D:objects/env/smallstonessea.prop` → `D:actors/env/smallstonessea.actor` → `smallstonessea1.mesh` | `smallstonessea` / `—` | `shared/terrain/rock_smallstonesea1.obj` 16,665 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 115 | `smallstonessea.2` | F17 | `D:objects/env/smallstonessea2.prop` → `D:actors/env/smallstonessea.actor` → `smallstonessea2.mesh` | `smallstonessea` / `—` | `shared/terrain/rock_smallstonesea2.obj` 20,951 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 116 | `smallstonessea.3` | F16 F17 | `D:objects/env/smallstonessea3.prop` → `D:actors/env/smallstonessea.actor` → `smallstonessea3.mesh` | `smallstonessea` / `—` | `shared/terrain/rock_smallstonesea3.obj` 21,204 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 117 | `smallstonessea.5` | F16 | `D:objects/env/smallstonessea5.prop` → `D:actors/env/smallstonessea.actor` → `smallstonessea5.mesh` | `smallstonessea` / `—` | `shared/terrain/rock_smallstonesea5.obj` 24,027 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 118 | `smallstonessea.6` | F16 F17 | `D:objects/env/smallstonessea6.prop` → `D:actors/env/smallstonessea.actor` → `smallstonessea6.mesh` | `smallstonessea` / `—` | `shared/terrain/rock_smallstonesea6.obj` 19,532 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 119 | `spruce1` | F13 F15 F11 F12 F09 F10 F08 F07 F04 F05 S01 S02 | `D:objects/env/spruce.prop` → `D:actors/env/spruce.actor` → `spruce1.mesh` | `spruce1` / `spruce1w` | `shared/terrain/tree_spruce1.obj` 74,387 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 120 | `spruce1.1` | F11 | `D:objects/env/spruce1.prop` → `D:actors/env/spruce.actor` → `spruce1.mesh` | `spruce1` / `spruce1w` | `shared/terrain/tree_spruce1.obj` 74,387 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 121 | `spruce2.2` | S02 | `D:objects/env/spruce2.prop` → `D:actors/env/spruce.actor` → `spruce2.mesh` | `spruce1` / `spruce1w` | `shared/terrain/tree_spruce2.obj` 73,959 | NO (512x512) | NEW EXPORT | **PARTIAL** — G3, G4, G5 |
| 122 | `spruce4.4` | F04 F05 | `D:objects/env/spruce4.prop` → `D:actors/env/spruce.actor` → `spruce4.mesh` | `spruce1` / `spruce1w` | `shared/terrain/tree_spruce4.obj` 62,511 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 123 | `stones` | S01 S02 | `D:objects/env/stones.prop` → `D:actors/env/stones.actor` → `stones1.mesh` | `stones` / `—` | `shared/terrain/stone.obj` 14,185; `shared/terrain/rock_stones1.obj` 14,192 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 124 | `stones1` | S01 S02 | `D:objects/env/stones1.prop` → `D:actors/env/stones.actor` → `stones1.mesh` | `stones` / `—` | `shared/terrain/stone.obj` 14,185; `shared/terrain/rock_stones1.obj` 14,192 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 125 | `stones10` | S01 S02 S03 | `D:objects/env/stones10.prop` → `D:actors/env/stones.actor` → `stones10.mesh` | `stones` / `—` | `shared/terrain/rock_stones10.obj` 5,617 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 126 | `stones2` | S01 S02 S03 | `D:objects/env/stones2.prop` → `D:actors/env/stones.actor` → `stones2.mesh` | `stones` / `—` | `shared/terrain/rock_stones2.obj` 10,844 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 127 | `stones3` | S01 S02 S03 | `D:objects/env/stones3.prop` → `D:actors/env/stones.actor` → `stones3.mesh` | `stones` / `—` | `shared/terrain/rock_stones3.obj` 3,856 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 128 | `stones4` | S01 S02 S03 | `D:objects/env/stones4.prop` → `D:actors/env/stones.actor` → `stones4.mesh` | `stones` / `—` | `shared/terrain/rock_stones4.obj` 10,660 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 129 | `stones5` | S01 S02 S03 | `D:objects/env/stones5.prop` → `D:actors/env/stones.actor` → `stones5.mesh` | `stones` / `—` | `shared/terrain/rock_stones5.obj` 15,261 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 130 | `stones6` | S01 S02 S03 | `D:objects/env/stones6.prop` → `D:actors/env/stones.actor` → `stones6.mesh` | `stones` / `—` | `shared/terrain/rock_stones6.obj` 6,135 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 131 | `stones7` | S02 S03 | `D:objects/env/stones7.prop` → `D:actors/env/stones.actor` → `stones7.mesh` | `stones` / `—` | `shared/terrain/rock_stones7.obj` 20,743 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 132 | `stones8` | S01 S02 S03 | `D:objects/env/stones8.prop` → `D:actors/env/stones.actor` → `stones8.mesh` | `stones` / `—` | `shared/terrain/rock_stones8.obj` 17,949 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 133 | `stones9` | S01 S02 S03 | `D:objects/env/stones9.prop` → `D:actors/env/stones.actor` → `stones9.mesh` | `stones` / `—` | `shared/terrain/rock_stones9.obj` 11,996 | NO (512x512) | NEW EXPORT | **PARTIAL** — G4, G5 |
| 134 | `stonesdesert1` | S04 S05 | `D:objects/env/stonesdesert1.prop` → `D:actors/env/stones.actor` → `stones1.mesh` | `stonesdesert` / `—` | `shared/terrain/stone.obj` 14,185; `shared/terrain/rock_stones1.obj` 14,192 | NO (512x512) | NEW EXPORT | **PARTIAL** — G3, G4, G5 |
| 135 | `stonesdesert10` | S04 S05 | `D:objects/env/stonesdesert10.prop` → `D:actors/env/stones.actor` → `stones10.mesh` | `stonesdesert` / `—` | `shared/terrain/rock_stones10.obj` 5,617 | NO (512x512) | NEW EXPORT | **PARTIAL** — G3, G4, G5 |
| 136 | `stonesdesert2` | S04 S05 | `D:objects/env/stonesdesert2.prop` → `D:actors/env/stones.actor` → `stones2.mesh` | `stonesdesert` / `—` | `shared/terrain/rock_stones2.obj` 10,844 | NO (512x512) | NEW EXPORT | **PARTIAL** — G3, G4, G5 |
| 137 | `stonesdesert4` | S04 S05 | `D:objects/env/stonesdesert4.prop` → `D:actors/env/stones.actor` → `stones4.mesh` | `stonesdesert` / `—` | `shared/terrain/rock_stones4.obj` 10,660 | NO (512x512) | NEW EXPORT | **PARTIAL** — G3, G4, G5 |
| 138 | `stonesdesert5` | S04 S05 | `D:objects/env/stonesdesert5.prop` → `D:actors/env/stones.actor` → `stones5.mesh` | `stonesdesert` / `—` | `shared/terrain/rock_stones5.obj` 15,261 | NO (512x512) | NEW EXPORT | **PARTIAL** — G3, G4, G5 |
| 139 | `stonesdesert7` | S05 | `D:objects/env/stonesdesert7.prop` → `D:actors/env/stones.actor` → `stones7.mesh` | `stonesdesert` / `—` | `shared/terrain/rock_stones7.obj` 20,743 | NO (512x512) | NEW EXPORT | **PARTIAL** — G3, G4, G5 |
| 140 | `stonesdesert8` | S04 S05 | `D:objects/env/stonesdesert8.prop` → `D:actors/env/stones.actor` → `stones8.mesh` | `stonesdesert` / `—` | `shared/terrain/rock_stones8.obj` 17,949 | NO (512x512) | NEW EXPORT | **PARTIAL** — G3, G4, G5 |
| 141 | `stonesdesert9` | S04 S05 | `D:objects/env/stonesdesert9.prop` → `D:actors/env/stones.actor` → `stones9.mesh` | `stonesdesert` / `—` | `shared/terrain/rock_stones9.obj` 11,996 | NO (512x512) | NEW EXPORT | **PARTIAL** — G3, G4, G5 |

### C.2 Family → BaseName index

| Code | Family | Class | Members resolved | Donor Objects | Unique BaseNames | BaseNames |
|---|---|---|---:|---:|---:|---|
| F01 | `forests_pinefir_big` | forest | 6/6 | 1123 | 33 | `burdock`; `chamomile.2`; `drytree`; `fern`; `fern.1`; `fir`; `firsmall1`; `flowers`; `grass.4`; `grass.5`; `grassforest`; `grassforest.1`; `grassforest.2`; `grassforest.3`; `grassleafforest`; `grassleafforest.2`; `horseradish`; `horseradish.1`; `pine1`; `pine1.1`; `pinebroken1`; `pinebroken2.2`; `pinebroken3.3`; `pinebrokenmoss1.1`; `pinebrokenmoss2.2`; `pinebrokenmoss3.3`; `pinebrokenmoss4.4`; `pinedry1`; `pinesmall1`; `plantain`; `plantain.1`; `plantain.2`; `plantain.3` |
| F02 | `forests_pinefir_medium` | forest | 6/6 | 432 | 16 | `chamomile`; `fern`; `fir`; `firsmall1`; `grasschamomile`; `grassforest.1`; `grassforest.2`; `grassforest.3`; `horseradish`; `pine1`; `pinebroken1`; `pinebroken1.1`; `pinebroken2.2`; `pinebroken4.4`; `pinesmall1`; `plantain` |
| F03 | `forests_pinefir_small` | forest | 6/6 | 214 | 10 | `fern`; `fir`; `firsmall1`; `grassforest.2`; `grassforest.3`; `horseradish`; `pine1`; `pinesmall1`; `plantain`; `plantain.1` |
| F04 | `forests_spruce_big` | forest | 4/4 | 390 | 9 | `grass.2`; `grass.3`; `grassforest.1`; `grassforest.2`; `grassforest.3`; `pine1`; `pinesmall1`; `spruce1`; `spruce4.4` |
| F05 | `forests_spruce_medium` | forest | 4/4 | 369 | 13 | `chamomile.1`; `grass.2`; `grass.3`; `grassforest.1`; `grassforest.2`; `grassforest.3`; `pine1`; `pinedry1`; `pinesmall1`; `plantain.1`; `plantain.3`; `spruce1`; `spruce4.4` |
| F06 | `forests_pinedrygreen_small` | forest | 4/4 | 488 | 10 | `fern`; `grassforest.1`; `grassforest.2`; `grassforest.3`; `pine1`; `pinebroken1`; `pinebroken1.1`; `pinebrokenmoss1`; `pinedry1`; `pinesmall1` |
| F07 | `forests_pine_small` | forest | 6/6 | 56 | 8 | `fern`; `firsmall1`; `grassforest.2`; `horseradish.1`; `pine1`; `pinesmall1`; `plantain.1`; `spruce1` |
| F08 | `forests_pine_medium` | forest | 10/10 | 190 | 13 | `drybushes`; `drybushes.1`; `fern`; `fir`; `grassforest.1`; `grassforest.2`; `pine1`; `pine1.1`; `pinebroken1`; `pinedry1`; `pinesmall1`; `pinesmall1.1`; `spruce1` |
| F09 | `forests_pine_big` | forest | 8/8 | 476 | 31 | `chamomile.1`; `chamomile.2`; `fern`; `fir`; `firsmall1`; `flowers`; `grass`; `grass.1`; `grass.2`; `grass.3`; `grasschamomile`; `grassforest.1`; `grassforest.3`; `horseradish`; `leaftree.2`; `leaftree.3`; `leaftree.4`; `pine1`; `pinebroken1`; `pinebroken4.4`; `pinebrokenmoss1`; `pinebrokenmoss1.1`; `pinebrokenmoss2.2`; `pinebrokenmoss3.3`; `pinebrokenmoss4.4`; `pinedry1`; `pinesmall1`; `pinestump.1`; `plantain`; `plantain.2`; `spruce1` |
| F10 | `forests_pine_big_2` | forest | 3/3 | 168 | 14 | `chamomile.2`; `fern`; `fir`; `firsmall1`; `grassforest.1`; `grassforest.3`; `horseradish`; `pine1`; `pinebroken4.4`; `pinebrokenmoss1.1`; `pinebrokenmoss2.2`; `pinedry1`; `pinesmall1`; `spruce1` |
| F11 | `forests_mixed_big` | forest | 3/3 | 1159 | 45 | `burdock`; `chamomile`; `chamomile.1`; `drytree`; `drytree1.1`; `drytree3.3`; `fern`; `fir`; `fir1.1`; `firsmall1`; `flowers`; `flowers.1`; `grass.3`; `grass.4`; `grass.5`; `grasschamomile`; `grassforest`; `grassforest.1`; `grassforest.2`; `grassforest.3`; `grassleafforest`; `grassleafforest.1`; `grassleafforest.2`; `grassleafforest.3`; `horseradish`; `leaftree`; `leaftree.1`; `oak`; `oak.1`; `oak.2`; `oak.3`; `pine1`; `pinebroken1`; `pinebrokenmoss1`; `pinebrokenmoss1.1`; `pinebrokenmoss2.2`; `pinebrokenmoss3.3`; `pinebrokenmoss4.4`; `pinesmall1`; `plantain`; `plantain.1`; `plantain.2`; `plantain.3`; `spruce1`; `spruce1.1` |
| F12 | `forests_mixed_medium` | forest | 5/5 | 723 | 35 | `burdock`; `chamomile.1`; `drytree`; `drytree1.1`; `drytree3.3`; `fern`; `fir`; `firsmall1`; `flowers`; `flowers.1`; `grass.4`; `grass.5`; `grasschamomile`; `grassforest.1`; `grassforest.2`; `grassforest.3`; `grassleafforest`; `grassleafforest.1`; `grassleafforest.2`; `grassleafforest.3`; `horseradish`; `leaftree`; `oak`; `oak.1`; `oak.2`; `oak.3`; `pine1`; `pinebroken1`; `pinebrokenmoss1`; `pinesmall1`; `plantain`; `plantain.1`; `plantain.2`; `plantain.3`; `spruce1` |
| F13 | `forests_leaf_big` | forest | 2/2 | 302 | 21 | `burdock`; `drytree`; `fir`; `firsmall1`; `grass.1`; `grass.2`; `grass.4`; `grass.5`; `grassforest.1`; `grassleafforest.1`; `grassleafforest.2`; `grassleafforest.3`; `horseradish`; `oak.1`; `oak.2`; `oak.3`; `oak.4`; `plantain`; `plantain.1`; `plantain.2`; `spruce1` |
| F14 | `forests_leaf_medium` | forest | 2/2 | 235 | 15 | `fern`; `fir`; `firsmall1`; `grass.2`; `grassforest.2`; `grassleafforest.1`; `grassleafforest.2`; `grassleafforest.3`; `oak.1`; `oak.2`; `oak.3`; `oak.4`; `pine1`; `pinesmall1`; `plantain` |
| F15 | `forests_leaf_small` | forest | 6/6 | 177 | 18 | `drytree`; `fir`; `firsmall1`; `grass.1`; `grass.2`; `grass.4`; `grass.5`; `grassleafforest.1`; `grassleafforest.2`; `oak.1`; `oak.2`; `oak.3`; `oak.4`; `pine1`; `pinesmall1`; `plantain.1`; `plantain.2`; `spruce1` |
| F16 | `desert_forests_medium` | forest | 23/23 | 815 | 11 | `desert1`; `desert3`; `desert4`; `desert5`; `palm`; `palmsmall`; `plantainyellow`; `plantyellow`; `smallstonessea.3`; `smallstonessea.5`; `smallstonessea.6` |
| F17 | `desert_forests_small` | forest | 20/20 | 493 | 12 | `desert1`; `desert3`; `desert4`; `desert5`; `grassdesert.4`; `grassdesert.5`; `palm`; `palmsmall`; `plantyellow`; `smallstonessea.2`; `smallstonessea.3`; `smallstonessea.6` |
| F18 | `desert_forests_unique` | forest | 12/12 | 586 | 7 | `desert1`; `desert3`; `palm`; `palmsmall`; `plantainyellow`; `plantyellow`; `smallstonessea` |
| F19 | `desert_forests_big` | forest | 0/17 | 0 | 0 | UNRESOLVED — `n_desert_frt_big1,n_desert_frt_big2,n_desert_frt_big3,n_desert_frt_big4,n_desert_frt_big5,n_desert_frt_big6,n_desert_frt_big7,n_desert_frt_big8,n_desert_frt_big9,n_desert_frt_big10,n_desert_frt_big11,n_desert_frt_big12,n_desert_frt_big13,n_desert_frt_big14,n_desert_frt_big15,n_desert_frt_big16,n_desert_frt_big17` |
| S01 | `stoneforests` | stone | 8/8 | 401 | 45 | `burdock.2`; `burdock.3`; `drytree3.3`; `drytree4.4`; `fern.1`; `fir`; `firsmall1`; `firsmall1.1`; `grass.2`; `grass.3`; `grassforest.1`; `grassforest.2`; `grassforest.4`; `grassforest.5`; `horseradish`; `leaftree`; `oak`; `oak.1`; `oak.4`; `pine1`; `pinebroken1`; `pinebroken1.1`; `pinebrokenmoss1.1`; `pinebrokenmoss2.2`; `pinebrokenmoss3.3`; `pinebrokenmoss4.4`; `pinedry1`; `pinesmall1`; `plant`; `plantain`; `smallstones`; `smallstones.1`; `smallstones.5`; `smallstones.6`; `spruce1`; `stones`; `stones1`; `stones10`; `stones2`; `stones3`; `stones4`; `stones5`; `stones6`; `stones8`; `stones9` |
| S02 | `stoneforests_old` | stone | 8/8 | 332 | 40 | `burdock.2`; `burdock.3`; `chamomile.2`; `drybushes`; `fern.1`; `fir`; `firsmall1.1`; `grass.1`; `grass.2`; `grass.3`; `grassforest.1`; `grassforest.2`; `horseradish`; `leaftree`; `pine1`; `pinebroken1`; `pinebroken1.1`; `pinebrokenmoss1.1`; `pinebrokenmoss2.2`; `pinebrokenmoss3.3`; `pinebrokenmoss4.4`; `pinedry1`; `pinesmall1`; `smallstones`; `smallstones.1`; `smallstones.5`; `smallstones.6`; `spruce1`; `spruce2.2`; `stones`; `stones1`; `stones10`; `stones2`; `stones3`; `stones4`; `stones5`; `stones6`; `stones7`; `stones8`; `stones9` |
| S03 | `stones` | stone | 7/7 | 199 | 38 | `burdock`; `burdock.1`; `burdock.2`; `burdock.3`; `chamomile.2`; `fern.1`; `firsmall1`; `firsmall4.4`; `flowers.1`; `flowers.2`; `flowers.3`; `grass.4`; `grass.5`; `grasschamomile`; `horseradish`; `horseradish.1`; `pinesmall1.1`; `pinesmall2.2`; `pinesmall4.4`; `plantain`; `plantain.1`; `plantain.2`; `plantain.3`; `smallstones.1`; `smallstones.2`; `smallstones.3`; `smallstones.4`; `smallstones.5`; `smallstones.6`; `stones10`; `stones2`; `stones3`; `stones4`; `stones5`; `stones6`; `stones7`; `stones8`; `stones9` |
| S04 | `desert_stoneforests` | stone | 4/4 | 78 | 21 | `desert1`; `desert3.1`; `desert3.3`; `grassdesert.4`; `palm`; `palmsmall`; `plantyellow.1`; `smallstonesdesert`; `smallstonesdesert.1`; `smallstonesdesert.2`; `smallstonesdesert.3`; `smallstonesdesert.4`; `smallstonesdesert.5`; `smallstonesdesert.6`; `stonesdesert1`; `stonesdesert10`; `stonesdesert2`; `stonesdesert4`; `stonesdesert5`; `stonesdesert8`; `stonesdesert9` |
| S05 | `desert_stones` | stone | 12/12 | 209 | 22 | `desert1`; `desert3.1`; `desert3.3`; `grassdesert.4`; `palm`; `palmsmall`; `plantyellow.1`; `smallstonesdesert`; `smallstonesdesert.1`; `smallstonesdesert.2`; `smallstonesdesert.3`; `smallstonesdesert.4`; `smallstonesdesert.5`; `smallstonesdesert.6`; `stonesdesert1`; `stonesdesert10`; `stonesdesert2`; `stonesdesert4`; `stonesdesert5`; `stonesdesert7`; `stonesdesert8`; `stonesdesert9` |
| M01 | `mng` | mine | 6/6 | 75 | 14 | `bushes`; `fern`; `firsmall1`; `flowers.1`; `flowers.3`; `grass.4`; `horseradish`; `minegold`; `pine1`; `pinesmall1`; `plant`; `plant.5`; `plantain.1`; `plantain.3` |
| M02 | `mni` | mine | 6/6 | 67 | 11 | `bushes`; `chamomile.1`; `fern`; `fir1.1`; `firsmall1`; `horseradish`; `mineiron`; `pinesmall1`; `plant`; `plantain.1`; `plantain.3` |
| M03 | `mnc` | mine | 6/6 | 69 | 13 | `burdock.2`; `bushes`; `chamomile.1`; `fern`; `fern.1`; `firsmall1`; `grass.4`; `minecoal`; `pine1`; `pinesmall1`; `plant`; `plantain.1`; `plantain.3` |
| M04 | `desert_mng` | mine | 3/3 | 34 | 9 | `desert1`; `desert5`; `minegolds`; `palm`; `palmsmall`; `palmsmall1.1`; `palmsmall3.3`; `plantainyellow`; `plantyellow` |
| M05 | `desert_mni` | mine | 3/3 | 36 | 8 | `desert1`; `desert5`; `mineirons`; `palm`; `palmsmall1.1`; `palmsmall3.3`; `plantainyellow`; `plantyellow` |
| M06 | `desert_mnc` | mine | 3/3 | 42 | 8 | `desert4`; `desert5`; `minecoals`; `palm`; `palmsmall1.1`; `palmsmall3.3`; `plantainyellow`; `plantyellow` |

### C.3 Relief props (`terrainmesh1..4`) and the desert-relief gap

| BaseName | Donor prop → actor → mesh | Donor material (winter) | Converted mesh (exact bytes) | 2048² albedo | Transforms in `mountain_props.json` | Status / exact gap |
|---|---|---|---|---|---|---|
| `terrainmesh1` | `D:objects/env/terrainmesh1.prop` → `D:actors/env/terrainmesh1.actor` → `terrainmesh1.mesh` | `terrainmesh1` / `terrainmesh1w` | `shared/terrain/terrainmesh1.obj` 302,651 B | YES — `shared/terrain/terrainmesh1.png` 7,758,343 B, 2048² | YES — 14 object records (`props[*].base == terrainmesh1`), px/py/pz, dx/dy/dz, ux/uy/uz, sx/sy/sz, `yaw_deg`, donor `line` | **COMPLETE** on the four gates; engine-side `terrainmeshN` selection still PORT APPROXIMATION |
| `terrainmesh2` | `D:objects/env/terrainmesh2.prop` → `D:actors/env/terrainmesh2.actor` → `terrainmesh2.mesh` | `terrainmesh2` / `terrainmesh2w` | `shared/terrain/terrainmesh2.obj` 256,005 B | YES — `shared/terrain/terrainmesh2.png` 7,780,004 B, 2048² | YES — 21 records | **COMPLETE** on the four gates; selection PORT APPROXIMATION |
| `terrainmesh3` | `D:objects/env/terrainmesh3.prop` → `D:actors/env/terrainmesh3.actor` → `terrainmesh3.mesh` | `terrainmesh3` / `terrainmesh3w` | `shared/terrain/terrainmesh3.obj` 244,123 B | YES — `shared/terrain/terrainmesh3.png` 7,853,483 B, 2048² | YES — 29 records | **COMPLETE** on the four gates; selection PORT APPROXIMATION |
| `terrainmesh4` | `D:objects/env/terrainmesh4.prop` → `D:actors/env/terrainmesh4.actor` → `terrainmesh4.mesh` | `terrainmesh4` / `terrainmesh4w` | `shared/terrain/terrainmesh4.obj` 342,497 B | YES — `shared/terrain/terrainmesh4.png` 8,005,498 B, 2048² | YES — 25 records | **COMPLETE** on the four gates; selection PORT APPROXIMATION |
| `terrainmeshdesert1..4` (extra, **not** in F08's four) | `D:objects/env/terrainmeshdesertN.prop` → `D:actors/env/terrainmesh1..4.actor` → `terrainmesh1..4.mesh` | `terrainmeshdesertN` / `terrainmesh1..4w` | geometry would reuse the four OBJs above, **but no desert-material OBJ/PNG/manifest entry exists** | **NO** — no `*desert*` file in `models/tex/**` | YES — 23 records (`2 + 5 + 7 + 9`) in `desert_mnt_*` sections | **PARTIAL** — gap: no converted `terrainmeshdesertN` albedo/material; manifests have 0 matches; `prop_winter_materials.json` has 0 matches |

`mountain_props.json` has 30 pattern sections / 112 records; `by_pattern` keys are
13 `desert_mnt_*`, 7 `g_mnt_*`, 5 `i_mnt_big_*`, 5 `i_mnt_long_*`. Only the 19
`desert_mnt_*` + `g_mnt_*` sections are listed in `derived_stats.port_stampable_sections`
(45 records); the 11 `i_mnt_*` sections carry terrainmesh transforms but are
**absent from `donor_patterns.json`** (`patterns` has no `i_mnt_*` key) — a
relief-window export gap for I02, not a prop-mesh gap.

## 4. Aggregate coverage counts

### 4.1 By family class (unique BaseNames; a BaseName shared by families is counted once per class)

| Class | Families | Named members | Resolved sections | Donor `Objects` records | Unique BaseNames | Exact OBJ | Fallback-only OBJ | No OBJ | Material mismatch (of meshed) | 2048² albedo | COMPLETE | PARTIAL | MISSING |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Forest | 19 | 147 | 130 | 8,396 | 81 | 28 | 3 | 50 | 1 | 0 | 0 | 31 | 50 |
| Stone | 5 | 39 | 39 | 1,219 | 91 | 55 | 1 | 35 | 15 | 0 | 0 | 56 | 35 |
| Mine | 6 | 27 | 27 | 323 | 32 | 18 | 0 | 14 | 4 | 6 | 0 | 18 | 14 |
| **Total (per-class sum)** | **30** | **213** | **196** | **9,938** | **141** | **75** | **3** | **63** | **20 (19 global unique)** | **6** | **0** | **78** | **63** |
| Relief `terrainmesh1..4` | — | — | 30 sections / 112 records | 89 matching records | 4 | 4 | 0 | 0 | 0 | 4 | 4 | 0 | 0 |
| Relief `terrainmeshdesert1..4` (extra) | — | — | 13 `desert_mnt_*` sections | 23 records | 4 | 0 (geometry reuse only) | 0 | 4 material/albedo | 4 | 0 | 0 | 4 | 0 |

**[D]** 75 + 3 + 63 = 141; the per-class exact column sums to 28 + 55 + 18 = 101,
which exceeds the global 75 exact BaseNames only because a BaseName shared by two
classes (e.g. `pine1` in forest and stone) is counted in each class. The authoritative
global figures are 75 exact / 3 fallback-only / 63 none in §1 and the unified ledger.

### 4.2 Per-family detail

| Code | Family | Members resolved | Donor Objects | Unique BaseNames | MISSING | PARTIAL | Exact-mesh BaseNames | With 2048² |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| F01 | `forests_pinefir_big` | 6/6 | 1,123 | 33 | 20 | 13 | 13 | 0 |
| F02 | `forests_pinefir_medium` | 6/6 | 432 | 16 | 10 | 6 | 6 | 0 |
| F03 | `forests_pinefir_small` | 6/6 | 214 | 10 | 3 | 7 | 7 | 0 |
| F04 | `forests_spruce_big` | 4/4 | 390 | 9 | 5 | 4 | 4 | 0 |
| F05 | `forests_spruce_medium` | 4/4 | 369 | 13 | 6 | 7 | 7 | 0 |
| F06 | `forests_pinedrygreen_small` | 4/4 | 488 | 10 | 6 | 4 | 4 | 0 |
| F07 | `forests_pine_small` | 6/6 | 56 | 8 | 2 | 6 | 6 | 0 |
| F08 | `forests_pine_medium` | 10/10 | 190 | 13 | 5 | 8 | 8 | 0 |
| F09 | `forests_pine_big` | 8/8 | 476 | 31 | 20 | 11 | 11 | 0 |
| F10 | `forests_pine_big_2` | 3/3 | 168 | 14 | 7 | 7 | 7 | 0 |
| F11 | `forests_mixed_big` | 3/3 | 1,159 | 45 | 27 | 18 | 16 | 0 |
| F12 | `forests_mixed_medium` | 5/5 | 723 | 35 | 19 | 16 | 14 | 0 |
| F13 | `forests_leaf_big` | 2/2 | 302 | 21 | 11 | 10 | 7 | 0 |
| F14 | `forests_leaf_medium` | 2/2 | 235 | 15 | 5 | 10 | 7 | 0 |
| F15 | `forests_leaf_small` | 6/6 | 177 | 18 | 7 | 11 | 8 | 0 |
| F16 | `desert_forests_medium` | 23/23 | 815 | 11 | 7 | 4 | 4 | 0 |
| F17 | `desert_forests_small` | 20/20 | 493 | 12 | 9 | 3 | 3 | 0 |
| F18 | `desert_forests_unique` | 12/12 | 586 | 7 | 5 | 2 | 2 | 0 |
| F19 | `desert_forests_big` | **0/17** | 0 | 0 | 0 | 0 | 0 | 0 |
| S01 | `stoneforests` | 8/8 | 401 | 45 | 19 | 26 | 25 | 0 |
| S02 | `stoneforests_old` | 8/8 | 332 | 40 | 17 | 23 | 23 | 0 |
| S03 | `stones` | 7/7 | 199 | 38 | 10 | 28 | 28 | 0 |
| S04 | `desert_stoneforests` | 4/4 | 78 | 21 | 7 | 14 | 14 | 0 |
| S05 | `desert_stones` | 12/12 | 209 | 22 | 7 | 15 | 15 | 0 |
| M01 | `mng` | 6/6 | 75 | 14 | 4 | 10 | 10 | 1 |
| M02 | `mni` | 6/6 | 67 | 11 | 3 | 8 | 8 | 1 |
| M03 | `mnc` | 6/6 | 69 | 13 | 4 | 9 | 9 | 1 |
| M04 | `desert_mng` | 3/3 | 34 | 9 | 7 | 2 | 2 | 1 |
| M05 | `desert_mni` | 3/3 | 36 | 8 | 6 | 2 | 2 | 1 |
| M06 | `desert_mnc` | 3/3 | 42 | 8 | 6 | 2 | 2 | 1 |

**[O]/[D]** F19 has zero BaseNames because all 17 `n_desert_frt_big_*` names have
no `pattern.lib` section; this is a *name-resolution* gap, not a mesh gap. The two
"Exact-mesh BaseNames" columns per family are from the exact `DefaultMeshName`
match; the per-family `PARTIAL` count additionally includes fallback-only rows.

## 5. Priority gap list for I09 / I02 / I03

Ordered by (blocks authored-object stamping first) → (scope) → (cost):

| Priority | Gap (exact) | Count / evidence | Owner | Concrete action |
|---:|---|---|---|---|
| P0 | **G4 — no `pattern.lib` `Objects[]` export for any forest/stone/mine pattern** | 141 BaseNames, 196 resolved sections, 9,938 records (E6) | **I03** (`decode_pattern_lib.py`) | Emit a new derived JSON (e.g. `terrain_new/patterns/pattern_objects.json`) keyed by exact section `Name`, each record `{base, race, x, y, z, dir_x/y/z, up_x/y/z, scale, donor_line}` copied from `pattern.lib` literals; preserve duplicate names by section, not a `Name` dict (F08 R2). This is the single largest fidelity gain: it replaces `game.gd:772-844` synthetic node spawns with authored clump transforms. |
| P0 | **G1 — 63 BaseNames have no converted OBJ/GLB** | per-class 50 forest / 35 stone / 14 mine; **63 unique globally**; examples `palm*`, `leaftree*`, `drytree*`, `plant*`, `grassforest*`, `grassleafforest*`, `burdock*`, `chamomile*`, `horseradish*`, `drybushes*`, `pinebroken*`, `pinebrokenmoss*` | **I09** (bind) + **A03/I03** (convert later) | For I09, do **not** substitute a generic tree: either skip these records with a labelled telemetry counter or map only where donor actor is identical (already done for `stonesdesert*` etc.). Schedule new conversions from donor `.osm` + `.dds` for the high-frequency groups first (`pinebroken*`, `palm*`, `leaftree*`, `drytree*`, `plant*`), with provenance labels; no donor binary copied. |
| P1 | **G3 — 19 material variants unconverted** | 15 desert stones + 3 desert ores + `plantainyellow` (E8) | **I09** + asset conversion | Bind geometry from the shared sid but record `material_variant_unconverted`; do not silently render `minegolds` with `minegold.dds` as if identical. Convert `stonesdesert.dds`, `smallstonesdesert.dds`, `minegolds/irons/coals.dds`, `plantsyellowatlas.dds` only if owner wants desert fidelity. |
| P1 | **G5 — no 2048² albedo for 135/141 BaseNames** | only 6 ore BaseNames have 2048² (E7); trees 256²–1024², stones 512² | **I09** | Treat 2048² as a declared acceptance gate, not an implicit one: use the existing converted albedos at their real resolution and label them; request upscale/re-conversion only if the owner makes 2048² mandatory. Do not invent detail. |
| P1 | **Winter material not converted for any of the 141** | `prop_winter_materials.json` data-only/unwired (P02 §4) | **I09** | Bind `UseableWinterMaterials` names from the props to alias keys and leave winter rendering UNVERIFIED until a material swap is implemented; no fake winter tint. |
| P2 | **G2 — `oak.2/.3/.4` exact variant absent** | only actor-level fallback `tree_oak.obj` (E5) | **I09** | Decide explicit fallback policy: reuse `tree_oak.obj` with `variant_fallback` telemetry or skip; do not claim donor mesh-index parity (F08 R4). |
| P2 | **F19 name mismatch `n_desert_frt_big_*`** | 0/17 resolved (E1, F08 E16) | **I03** | Resolve the cfg↔lib normalisation explicitly (first-match parser semantics, F08 E2); a naive join silently drops the whole family's object list. |
| P2 | **`i_mnt_*` prop records without relief windows** | 11 sections in `mountain_props.json`, 0 in `donor_patterns.json` (E11) | **I02** | Export `.pattern` float windows for `i_mnt_big_1..5` and `i_mnt_long_1..5` (and the authored relief on small forest stamps, e.g. `frt_b_p_1` `HeightFieldMin=-0.28` / `Max=0.45` per F08 §3.1) rather than reusing I07's generic relief. |
| P2 | **Desert relief material gap** | 23 records `terrainmeshdesert1..4`, 0 converted albedo/manifest entries (E10) | **I02** + conversion | Either convert the 4 desert relief materials or mark those 23 records `material_missing` and skip; never render them with summer `terrainmeshN.png` as donor-equivalent. |
| P3 | **Stale relief test path** | `variant3d/tests/t_relief_props_qa.gd:30` → `res://assets/terrain/terrainmesh_props.json` (absent); live file is `mountain_props.json` (P02 F8) | **I09/QA (COORD)** | Fix or retire the constant before claiming the relief module is QA-covered; no Godot job was run here. |

## 6. Implications for spec §08

1. **[O]/[D]** `spec/08_FIELDS_AND_PROPS.md:24-29` currently says "terrainmesh1..4
   models are converted", "`mountain_props.json` holds 112 `pattern.lib` object
   records" and "relief float windows and swamp/lake families still need export".
   All three are consistent with this ledger, but §08 §4's "field and mine placement
   remains PORT APPROXIMATION until F07/F08/D07 land" should now be sharpened: F08 has
   landed, and its mine *deposit stamps* are 8×10-cell / 7–18-object / one-ore-prop
   records whose transforms are **not** in any port JSON (E6). The approximation is
   therefore not a knowledge gap but an **export + binding gap**.
2. **[O]** §08 §1's central finding (props must be instanced, not baked into height)
   is confirmed: 9,938 donor object records exist across the 30 families, of which
   only 112 relief records are exported today. A height-only implementation would
   lose 9,826 authored object instances. **[D]**
3. **[O]** §08 §5's staged order can be made concrete: stage "prop silhouette" maps
   to the 4 COMPLETE relief sids; "forests/stones" maps to 78 PARTIAL + 63 MISSING
   BaseNames; "mines" maps to 18 PARTIAL + 14 MISSING with 6 ore albedos ready.
4. **[I]** Adding a §08 sub-table with the 4 gates (mesh / material / albedo /
   transforms) prevents "file exists" from being read as "feature implemented" —
   P02 §6 implication 3 applies verbatim to props.
5. **[U]** §08's acceptance visual cues stay UNVERIFIED: this report produced no
   donor A/B frame and no Godot run. Any later parity statement needs a real A/B capture.

## 7. Multi-pass verification log (path/count contradictions)

Per `CHARTER.md:92-93`, every count that could contradict prior reports was re-checked
with a second instrument before being called a gap:

| Check | Pass 1 | Pass 2 | Result |
|---|---|---|---|
| OBJ / GLB count | Python `os.walk` → 299 OBJ, 0 GLB/GLTF | PowerShell `Get-ChildItem -Recurse -File` → 299 OBJ, 0 GLB/GLTF | Agree; no GLB route exists |
| No OBJ for `palm1`, `leaftree1`, `drytree1`, `plant1`, `pinebroken1`, `grass1`, `grassforest1`, `horseradish1`, `burdock1`, `chamomile1`, `drybushes1`, `terrainmeshdesert1..4`, `oak2..4` | Filename search over OBJ tree → NONE | Literal `manifest.json.Contains(<stem>.osm)` → NOT_IN_MANIFEST; and Pillow/PowerShell file listings | Gap confirmed twice |
| Transforms absent for props | JSON keys `by_pattern`/`props`/`pattern_meta` = 30 relief sections only | 15 literal `Select-String` greps → 0 hits each | Gap confirmed twice |
| 2048² albedo availability | Pillow IHDR over all matched tex files → only 3 mine sids at 2048² | Direct `Image.open()` + `Get-ChildItem` byte sizes for `mine_*.png` → 2048², 5.3 MB each | Agree |
| 141 BaseNames / 9,938 records | X05 index + line-slice `BaseName` regex | Independent family-member loop over F08 member lists; per-family object totals re-summed | Agree; F19 remains 0/17 |
| `mountain_props.json` 30/112 | JSON parse (`by_pattern` 30, `derived_stats.records_total` 112) | `Select-String` base census `terrainmesh1=14,2=21,3=29,4=25,desert=2/5/7/9` = 112 | Agree |

## 8. Risks

- **R1 [O]** Manifest `mesh`/`texture_png`/`obj` fields contain donor absolute paths
  (`C:\Games\Cossacks 3\data\...`) as provenance; the loadable files are the nation
  buckets under `models/obj/<bucket>/` and `models/tex/<bucket>/` (P02 R5/R6).
  A converter that follows the legacy fields will find nothing.
- **R2 [U]** Exact suffix → mesh/material index binding is engine-side (F08 R4);
  the ledger uses `DefaultMeshName` as the exact variant and treats other actor
  meshes only as labelled fallbacks.
- **R3 [U]** Lower-resolution albedos may be visually adequate, but no donor A/B
  frame exists to judge; G5 is a literal gate, not a quality verdict.
- **R4 [O]** F08 R2 duplication/collision: a `Name`-keyed `pattern.lib` dict collapses
  duplicates; I03 must key by section record (line range), and F08's parser kept
  last-seen sections.
- **R5 [O]** Winter variants exist in donor props (`UseableWinterMaterials`) but
  no converted winter PNG backs them; `prop_winter_materials.json` is unwired (P02).
- **R6 [U]** Desert `n_desert_frt_big_*` name normalisation and the shadowed
  duplicate `desert_mng/mni/mnc` blocks are unresolved (F08 U3/U4); the ledger uses
  F08's first-match reading and does not resolve runtime semantics.
- **R7 [O]** `mountain_props.json` `selection` literally says PORT APPROX — the
  engine-side choice among `terrainmeshN` is UNVERIFIED; COMPLETE here means the
  four asset/transform gates only.
- **R8 [O/U]** `t_relief_props_qa.gd:30` points at a nonexistent
  `terrainmesh_props.json`; whether the test currently fails was not checked (no
  runner job permitted).
- **R9 [U]** No visual parity claim: no donor GPU frame, no Godot capture in this lane.

## 9. UNVERIFIED register (do not promote)

| ID | Claim | Why UNVERIFIED |
|---|---|---|
| U-X16-1 | That any of the 78 meshed BaseNames renders like the donor prop | No donor A/B frame; no Godot run |
| U-X16-2 | Suffix `.1/.2/.3/.4` → concrete mesh/material index at runtime | Engine-side (F08 R4) |
| U-X16-3 | How `Objects[].Up` yaw maps to a world rotation, and whether all records instantiate per stamp | F08 U7 / Z08 §2.3 |
| U-X16-4 | Whether the engine normalises `n_desert_frt_big_*` / `k_pump_*` names or the pick simply fails | F08 E16/U3 |
| U-X16-5 | Which duplicate family block wins at runtime | F08 U4 |
| U-X16-6 | Whether lower-resolution albedos are an acceptable substitute for 2048² | Visual judgement needs A/B |
| U-X16-7 | Whether winter material aliases can be bound to converted meshes without new art | `prop_winter_materials.json` unwired |
| U-X16-8 | Runtime selection rule for `terrainmesh1..4` among the 45 port-stampable relief records | `mountain_props.json` `selection` = PORT APPROX |
| U-X16-9 | Outcome of `t_relief_props_qa.gd` with its stale path | No runner job |
| U-X16-10 | Whether the 24-byte `.pattern` tail carries per-cell prop flags that would add coverage obligations beyond the `pattern.lib` Objects arrays | F08 Q1; tail semantics unknown |

## 10. Open questions

1. **I09 / COORD:** for the 63 G1 BaseNames, prefer skip-with-telemetry or an
   explicitly labelled actor-level fallback? (Skipping is safer for donor fidelity;
   fallback keeps silhouettes but invents a mapping.)
2. **I03:** should `Objects[]` be emitted per section (duplicate names preserved)
   together with `line` citations so a QA test can byte-check against F08's worked
   examples (`mng_1:713408`, `d_frt_big_1:127382`, `d_stn_1:203425`)?
3. **I02:** is the 11-section `i_mnt_*` float-window omission intentional (port only
   wants `g_mnt_*`/`desert_mnt_*` relief) or an oversight?
4. **A03 / owner:** which unconverted high-frequency families justify new donor
   conversions first — `pinebroken*`, `palm*`, `leaftree*`, `drytree*`, or `plant*`?
5. **I09:** is a 2048² albedo a hard acceptance gate, or should the ledger record
   actual converted resolution and label the deviation?
6. **P03 / QA:** fix `t_relief_props_qa.gd:30` or retire it before the relief module
   is claimed QA-covered?

## 11. Attestation

- **One repo file written:** this report. No source, shader, config, asset, manifest,
  test, git state or Godot job was touched. No donor binary was run or copied; all
  donor files were opened READ-ONLY.
- Prior art read first: `CHARTER.md`, `SWARM_BOARD.md`, F08, P02, spec §08, X05 and
  `IMPLEMENTATION_PLAN.md` (I02/I03/I09 definitions).
- **No donor visual parity claim.** All port readings are **PORT APPROXIMATION**;
  every visual consequence is **UNVERIFIED**.

