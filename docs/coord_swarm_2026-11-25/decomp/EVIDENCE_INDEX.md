---
title: EVIDENCE INDEX — donor decompilation (2026-11-25)
area: donor decompilation
owner: COORD
updated: 2026-11-25
status: draft
---

# 🗂️ Evidence index — donor decompilation lane

COORD maintains this index as DEC reports land. Each row: evidence id or exact
`path:offset`, what it proves, and the report that first recorded it. Workers should
cite the id/path here plus their own report.

## Prior evidence carried forward (from `docs/decomp/*`, `investigation.cany/*`, wave-7 reports)

| Evidence | Proves | Source | Carried into |
|---|---|---|---|
| `ev_392885a6…` | `.oss` layout (skin payload) | `V72_mesh_conversion_feasibility.md` §1.1 | DEC-04 |
| `ev_0bbb20c1…` | `.osm` IDP2 structure | `V72_...md` §1.1 | DEC-04 / DEC-05 |
| `ev_6a6b0380…` | `.aaf` action ranges | `V72_...md` §1.1 | DEC-04 |
| `ev_e5ad6408…` | ACL playback semantics | `V72_...md` §1.1 | DEC-04 |
| `ev_030dff8c…`, `ev_10f78080…`, `ev_cc0ee18b…` | main view perspective projection | `G31_donor_3d_truth.md` §1–2a | DEC-07 / DSEL-02 |
| `fnd_22`, `fnd_23`, `fnd_24`, `fnd_26` (DB lane) | formations 149/46 nonzero; hotkeys 243; stage reseeding; envscales | `docs/decomp/DB_SCRIPTS.md` | DEC-03 |
| `.bind` section entropy 7.96 | packed/stripped 32-bit PE | `docs/decomp/DA_PE.md`, `docs/audit/DECOMP.md` | DEC-01 |

## New evidence from today's reports (COORD index)

| ID / path | Report | Donor path:offset | Claim | Verified by (2nd method/agent) |
|---|---|---|---|---|
| `fnd_1..fnd_6`, 14 evidence ids | `DEC_04_anim_formats.md` | `.oss` 24-B header; `.osm` IDP2 v8; `.aaf` AAF magic | anim/audio binary layouts; frame 0 ≠ bind pose for multi-bone | two-way checks; Craft Anything `fnd_1..fnd_6` |
| `fnd_7..fnd_9` | `RV_TRN_01_texgen_mask_reverify.md` | raw-byte finds in packed CODE; alpha seam deltas | 8×4×64 patch grid confirmed; eye planes UNVERIFIED | raw bytes vs Craft Anything `native_strings_find` (returned 0 — unsafe for packed binary) |
| `0x128` (3 bytes) | `DEC_01_binaries_rtti.md` | every `.cdx` vs `.exe` | `.cdx` = `.exe` with entry redirected into `.bind` (+0x310); `cossacks.exe` entry is in `CODE` | double-verified byte diff |
| `0x1fe0ef`, `0x1fe168` | `DSEL_02_donor_pick_math.md` | `cossacks.exe` | FOV API `GetCameraFieldOfViewByFocalLength(focal, viewportdimension)` + inverse exists | byte census; corrects "no FOV token" |
| `0x29F744`, `0x29F7F0`, `0x29F788`, `0x111248`, `0x11123D` | `DSEL_01_donor_selection_rectangle.md` | `cossacks.exe` | `GameManagerStartSelection` / `BeginSelection` / `CancelSelection`, `spmAdd`/`spmRunTime` enum strings | script + EXE signatures |
| `dmscript.global:171` | `DEC_05_terrain_formats.md` | `gc_meters_to_tile = 2` | port `TILE_M=2.0` IS donor-grounded | DEC-05 2-way; corrects DTRN-01 C6 |
| `.map` `TerrainMapBegin` | `DEC_05_terrain_formats.md` | 37-byte × 102,400 records | donor `.map` contains a per-cell terrain grid | 4 maps; semantics UNVERIFIED |
| `water.mat:86-106` | `RV_TRN_03_water_bindings.md` | all 21 lines commented; 0 binary hits | `heightmapwaves0.tga` is NOT `hmapTex` | line read + byte scans; DEC-05 alpha=255 |
| `0x453F00-0x454E1F` | `RV_TRN_03_water_bindings.md` | `cossacks.exe` | legacy `.bak` water shader has live Fresnel | byte scan |
| `resource.lib:47`, `brushes/selection.cfg:2-14` | `DSEL_01_donor_selection_rectangle.md` | donor text | yellow 1 px solid selection brush | full read + EXE tokens |
| `onmousemove.inc:32-34,152` | `DSEL_01`, `RV-SEL-01` (pending) | donor text | drag epsilon 0.005 world m (0.25 attack/guard) | 4 passes; `.inc` live-code convention under re-verification |
