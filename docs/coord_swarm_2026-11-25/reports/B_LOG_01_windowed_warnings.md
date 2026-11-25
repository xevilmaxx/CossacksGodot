---
id: B-LOG-01
owner: B-LOG-01
swarm: coord_swarm_2026-11-25
date: 2026-11-25
scope: READ-ONLY log diagnosis; variant3d/ only; no donor; no Godot run; no runner job; no git op
output: docs/coord_swarm_2026-11-25/reports/B_LOG_01_windowed_warnings.md
labels: observed | derived | inferred | UNVERIFIED
evidence_status: owner's windowed DIRECT godot.exe launch (bypasses runner FIFO) — EVIDENCE ONLY, NOT A GATE
visual_parity: NONE CLAIMED
---

# B-LOG-01 — windowed direct-launch warnings + PERF line diagnosis

## 0. Basis and limits

- [observed] The supplied log is a **direct** `godot.exe --path variant3d` launch, not a
  runner-FIFO job; per the task framing it is evidence only, **not a gate**. No warning
  below was reproduced, timed or re-measured by this worker.
- [observed] The log contains **WARNING** lines only for the four warning classes below;
  no `ERROR` / `SCRIPT ERROR` line appears in the quoted window.
- [observed] The PERF line is truncated after `steps_per`:
  `tick_ms=3.22 ai_ms=0.08 sync_ms=114.13 steps_per [truncated]` — so `steps_per_frame`
  and `redraws r/b/u/f` are **UNVERIFIED** for this run.
- [derived] All citations are to `variant3d/` source plus existing docs; no donor file was
  opened. No parity claim is made; quoted honesty labels are cited as text only.

## 1. Warning → source map and classification

| # | Log warning (path in log) | Emitting site (observed source) | Classification |
|---|---|---|---|
| W1 | `res://assets/terrain/atlas/tile_index_atlas.png` | `variant3d/scripts/tile_atlas_loader.gd:325` (`_load_image_at`), reached from `_load_single` `:282` → `TileAtlasLoader.load()` `:188` → `_load_atlas()` `variant3d/scripts/world3d_terrain.gd:619` → `build()` `:1260` → `bind()` `variant3d/scripts/world3d.gd:637-639` → `_do_async_load()` `variant3d/scripts/main.gd:588` | **EXPORT-ONLY warning; NOT a runtime fault** |
| W2 | `res://assets/terrain/atlas_parts/alpha.png` | `variant3d/scripts/tile_atlas_loader.gd:465` (`_load_masks`, `names` at `:461`, `PARTS_DIR` first at `:464`), reached from `:288` / `:262` | **EXPORT-ONLY warning; NOT a runtime fault** |
| W3 | `res://assets/terrain/atlas_parts/alphavert.png` | same as W2 (`_load_masks` `:461-465`) | **EXPORT-ONLY warning; NOT a runtime fault** |
| W4 | `world3d_entities: DONOR-SAMPLED FLAT-ROOT MORPH — PORT APPROXIMATION — NOT DONOR PARITY …` | `variant3d/scripts/world3d_entities.gd:519` (`push_warning` in `bind()`), label from `ANIM_STATUS` `:191`, `PORT_LABEL` `:188` | **EXPECTED-BY-DESIGN honesty label; NOT a fault** |
| W5 | `res://assets/models/tex/mill_rotor.png` | `variant3d/scripts/world3d_entities.gd:1719` (`img.load` in `_rotor_material`), via `_attach_rotor` `:1748` → `add_building` `:1663` → `_reconcile_entities` `variant3d/scripts/world3d.gd:349` → `sync` `:689` → `_process` `variant3d/scripts/main.gd:1671` | **EXPORT-ONLY warning; NOT a runtime fault** |

- [observed] W1–W3/W5 engine-side origin is the log's `at: load (core/io/image.cpp:2770)`;
  the trigger is the `img.load(path)` call at `variant3d/scripts/tile_atlas_loader.gd:325`
  / `:328` and `variant3d/scripts/world3d_entities.gd:1719`.
- [observed] The warning text itself says **"this will not work on export"** — i.e. it is
  an export-packaging concern, not an in-editor/headless load error. Runtime continues
  past every warning: `bind()` reaches `variant3d/scripts/world3d.gd:641-644`, and the
  frame loop reaches `variant3d/scripts/main.gd:1671`.
- [derived] W1–W3 map exactly onto COMP-05's five unimported PNGs:
  `docs/coord_swarm_2026-11-24/reports/COMPLETENESS_05_shipping.md:66`
  (`tile_index_atlas.png`, `alpha.png`, `alphavert.png`, plus `atlas_parts/` copies) —
  `SINGLE_ATLAS` at `variant3d/scripts/tile_atlas_loader.gd:66`, `PARTS_DIR` `:67`,
  `ATLAS_DIR` `:68`, mask names `:461`.

## 2. Does `Image.load` break the `.ctex`/import pipeline?

- [observed] The loader deliberately mirrors `load()` but "no global `load()` is called
  anywhere in this file (textures use Image.load / create_from_image)":
  `variant3d/scripts/tile_atlas_loader.gd:171-173`; implementation `:320-332`,
  `ImageTexture.create_from_image` at `:285` and `:467`.
- [derived] For W1–W3 **there is no import pipeline to break**: those 5 PNGs have no
  `.import` at all (`docs/coord_swarm_2026-11-24/reports/COMPLETENESS_05_shipping.md:66,70`)
  and are read as raw bytes intentionally (`:70`). `Image.load` is their only transport.
- [observed] For W5 the code explicitly rejects the import-pipeline route: a stale/missing
  `.ctex` previously produced hard engine ERRORs, so `_rotor_material` tries the
  importable `tex/` copy `ROTOR_TEX_IMPORT_PATH` (`variant3d/scripts/world3d_entities.gd:236`)
  first, then the original `anim/` path (`:230`), and decodes via `FileAccess`/`Image`
  (`:1705-1713`). The old ERROR signature is
  `docs/coord_swarm_2026-11-25/reports/ASSET_IMPORT_01.md:22-25`; it is **absent** from this
  log — only the export warning remains. [derived] The graceful-fallback path landed.
- [derived] **Verdict:** `Image.load` is the intended headless-safe path for both families;
  it avoids the `.ctex` failure mode rather than causing it. The residual warning is the
  export-side cost of that choice.
- [UNVERIFIED] Actual PCK inclusion of these raw PNGs: no export was run. Flagged already
  at `docs/coord_swarm_2026-11-24/reports/COMPLETENESS_05_shipping.md:70,164` (F-04) and
  `docs/coord_swarm_2026-11-25/reports/GDIGNORE_01.md:117` (M5). **Not re-litigated here.**

## 3. Is W5 covered by ASSET-IMPORT-01's `.gdignore` root cause?

- [observed] **Yes — same root cause.** `ASSET_IMPORT_01.md:125` infers that
  `variant3d/assets/models/anim/.gdignore` recursively excludes the tree containing
  `assets/models/anim/common/buildings/mill_rotor.png`; the leftover `.import` advertises a
  ctex Godot never generates (`:32-33,141`). `GDIGNORE_01.md:79` derives that **all**
  2,097 stale-import sidecars are inside `.gdignore` trees.
- [observed] The mitigation is owner-coded in `variant3d/scripts/world3d_entities.gd:231-236`
  (importable `tex/` copy of the same shipped PNG, no donor bytes copied) and the
  headless-safe decode at `:1705-1713`; labels at `:244,248` remain non-parity.
- [derived] The log naming `tex/mill_rotor.png` (not `anim/…`) is consistent with the
  first-priority path at `:1714` being used, i.e. the relocated copy is active.

## 4. Is W4 expected-by-design?

- [observed] W4 is a literal `push_warning` at `variant3d/scripts/world3d_entities.gd:519`;
  its text is `ANIM_STATUS` `:191`, built from `PORT_LABEL` `:188` ("Exact V7-64 PORT_LABEL
  text … kept verbatim", sourced to `anim3d.gd:55`). Same label is stored as meta at
  `:1401,1641` and in stats at `:443`.
- [observed] `:189-190` state the intent: real donor flat-root morph data is consumed but
  this is not donor-parity skeletal deformation and the result is UNVERIFIED; `:192-193`
  cite `anim3d.gd:96` / `V7-2` Table B1 for `.oss` bone parents being unreadable.
- [derived] **Expected honesty telemetry, not a defect.** No runtime behavior depends on
  this warning. It should be preserved as a status disclosure; only its channel could be
  downgraded (see P2).

## 5. PERF line — which stage dominates?

| Value | Source | Label |
|---|---|---|
| `tick_ms=3.22`, `ai_ms=0.08`, `sync_ms=114.13` | owner's log (windowed direct launch) | observed |
| `sync_ms` = **mean TOTAL `world.sync()` over 120 frames**, not a max and not per-stage | `docs/coord_swarm_2026-11-25/reports/PERF_3D_01.md:42`; emitter `variant3d/scripts/main.gd:1642`, accumulator `:1672`, call `:1671` | observed |
| `sync_ms` ≈ **35× `tick_ms`**, ≈ **1428× `ai_ms`**; sync dominates | 114.13 / 3.22, 114.13 / 0.08 | derived |
| Terrain build is **excluded** from `sync_ms`: it runs at bind, `variant3d/scripts/world3d.gd:637-639`; `sync()` `:682-695` never calls `terrain.sync()` | `PERF_3D_01.md:124` | derived |
| Mill-rotor texture load **is** inside `world.sync()` (`_reconcile_entities` `world3d.gd:689` → `add_building` `:349` → `_attach_rotor` `world3d_entities.gd:1748` → `_rotor_material` `:1719`) | cited lines | observed |
| …but it is **one-time per building**, guarded by `_feed_entity_ids` (`world3d.gd:342-343`) and `_rotors.has(id)` (`world3d_entities.gd:1743-1744`), so it cannot be the recurring 114 ms driver | cited lines | inferred |
| Dominant recurring suspect: per-unit `entities.sync()` Pass 1 (pose/morph/measure work) + V7-80 resource scan | `PERF_3D_01.md:111-121` (Pass 1 historically 90–98% of `world.sync`; gate at `world3d.gd:360-389`) | inferred |
| Exact per-stage split | no emitter remains; `PERF_3D_01.md:101,133` (Q3 BLOCKED) | UNVERIFIED |
| Windowed FPS / GPU upload | `PERF_3D_01.md:104,136` (Q6) | UNVERIFIED |
| Equivalence with PERF-3D headless `276.77/272.56` (`PERF_3D_01.md:12,140`) | different mode (windowed direct vs headless 120-frame screenshot) | UNVERIFIED — do not compare numerically |

- [derived] **Answer:** `sync_ms=114.13` is the **entity-reconcile / per-unit sync path**,
  **not** terrain build. The mill-rotor decode is a one-shot sub-step of that path, so it
  is present in the call tree but not the steady-state driver.
- [derived] User-visible impact of 114 ms mean sync, if representative of windowed frames,
  is input/render latency; **no FPS number is claimed** (UNVERIFIED above).

## 6. Ranked findings — P0/P1/P2

| Rank | Finding (exact file:lines) | Mechanism | User-visible impact | Minimal fix | Disjoint owner |
|---|---|---|---|---|---|
| **P0** | PERF `sync_ms=114.13` dominance — `variant3d/scripts/main.gd:1642,1671-1672`; suspects `variant3d/scripts/world3d_entities.gd:1570-1695` (Pass 1), `variant3d/scripts/world3d.gd:360-389,689` (V7-80 gate). `[inferred]` | Per-frame `world.sync()` total; per-unit pose/morph + resource scan; per-stage split BLOCKED (`PERF_3D_01.md:101,133`) | Windowed stutter/latency inferred; **no FPS claim** | Add a per-stage timing emitter at the existing `sync()` sites (specified `PERF_3D_01.md:101`); **no code edit by this worker** | entities owner (`world3d_entities.gd`) for Pass 1; **V7-80 / `world3d.gd`** owner for the gate — disjoint files |
| **P1** | W1–W3 export warnings — `variant3d/scripts/tile_atlas_loader.gd:66-68,282,325,461-465`; 5 unimported PNGs `docs/coord_swarm_2026-11-24/reports/COMPLETENESS_05_shipping.md:66,70,164` | Raw `Image.load` of PNGs with no `.import`; `all_resources` export may omit them | **None at runtime**; exported terrain atlas/masks potentially missing `[UNVERIFIED]` | Do **not** change runtime transport (it is the intended path). Export `include_filter` for the 5 PNGs — **already tracked as COMP-05 F-04** (`:164`); reference, do not duplicate | loader owner for any loader change; **export/packaging owner (COMP-05 F-04)** for PCK inclusion |
| **P1** | W5 export warning — `variant3d/scripts/world3d_entities.gd:230,236,1705-1719,1748`; root cause `ASSET_IMPORT_01.md:125,141`, `GDIGNORE_01.md:79,117` | `Image.load` of `tex/` copy avoids the `.gdignore` ctex ERROR but still trips the export warning | **None at runtime**; exported rotor texture potentially untextured fallback `:1727-1735` `[UNVERIFIED]` | Keep the fallback (no ERROR regression). If export inclusion is required, use the importable `tex/` copy via the export include list — `GDIGNORE_01.md:117` M5 / COMP-05 F-04; **do not widen `.gdignore`** (`GDIGNORE_01.md:115`) | entities owner (`world3d_entities.gd`); **export/packaging owner** for include list |
| **P2** | W4 honesty label — `variant3d/scripts/world3d_entities.gd:188,191,519` | Intentional `push_warning` of the static `ANIM_STATUS` string during `bind()` | **None** — log noise only; no behavior change | Optional: move the string to meta/stats only (`:443,1401,1641`) and stop emitting it as a warning; preserve wording verbatim | **docs-label / status owner** — do not touch animation behavior |

## 7. Explicitly NOT faults (expected warnings)

- W1, W2, W3, W5: Godot's export-oriented `Image.load` advisory (`core/io/image.cpp:2770`);
  the loads succeed and runtime proceeds (`variant3d/scripts/tile_atlas_loader.gd:325-327`,
  `variant3d/scripts/world3d_entities.gd:1719-1722`). Export inclusion is a separate,
  already-tracked hygiene item (`COMPLETENESS_05_shipping.md:70,164`) — **not a runtime bug**.
- W4: an intentional non-parity disclosure (`variant3d/scripts/world3d_entities.gd:188-191`)
  emitted at `:519`; **no fix required for correctness**.
- The absence of the historical `.ctex` ERROR signature (`ASSET_IMPORT_01.md:22-25`) from
  this log is **evidence the fallback works**, not a new fault.
- **No parity claim** is made anywhere in this report; all quoted "PORT APPROXIMATION /
  NOT DONOR PARITY / UNVERIFIED" strings are cited as source text only.

## 8. Scope compliance

- [observed] No source, config, asset, test, `.import`, `.gdignore`, `.godot` or git change
  was made. No Godot process was launched and no runner job was submitted.
- The only file written by this worker is this report.
