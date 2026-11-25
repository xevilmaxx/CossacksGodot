---
title: COORD SWARM 2026-11-25 — cold-readable entry point
area: coordination / variant3d
owner: COORD
author: DOC-03 (documentation micro-worker)
updated: 2026-11-25
status: living — in-day snapshot; RUNNING tickets may land after this file
authority: CHARTER.md → CORRECTIONS.md → GAPS.md → SWARM_BOARD.md → PROGRESS.md
parent: docs/coord_swarm_2026-11-24/
charter: skirmish-first, donor-is-truth
---

# 🐝 Coord swarm — 2026-11-25 (cold start here)

This is the entry point for the 2026-11-25 coordination swarm. It does **not** re-derive
facts: every claim below points at a living doc or a report path in this folder. All paths
are relative to `docs/coord_swarm_2026-11-25/` unless prefixed otherwise.

## 0. TL;DR — what this swarm did today

Owner directive (`CHARTER.md` §0): fix the two named 3D faults — **selection rectangle does
not work** and **terrain quality is bad even without trees** — with the **donor as primary
truth**, small features/tests, many tiny workers, piece-before-whole, and one final gate at
the end. Singleplayer skirmish only (D-12); missions/campaigns/DLC/network deferred.

- **3D selection rectangle.** Root cause: the box was never drawn — `world3d.gd:126-127`
  declares `sel_rect`/`sel_active` with no 3D consumer, while the selection ring exists at
  `world3d_fx.gd:379-435`. Governance: arbitration **S-25-06 rejected** V3D-01's
  screen-space `select_in_rect()` as 2D-derived; the donor world-ground rect stays.
  `SEL-01` (`input_controller.gd`) now draws the **yellow 1 px solid marquee**, uses the
  donor **0.005 m world epsilon** (0.25 in attack/guard mode), **Shift = add** and a
  **0.5 s double-click**. A separate camera/viewport-rect shift was fixed (`CAM-01/02`) and
  **runtime-confirmed 20/20** (`CAM-RV-01`, job 381). See `GAPS.md` §1, `PROGRESS.md`
  decisions S-25-06/07.
- **Terrain fidelity.** Donor truth: discrete TileBlock id per cell + 3-pass weighted
  smoothing + 8×4×64 alpha-atlas patches, `gc_meters_to_tile=2` → port `TILE_M=2.0` is
  donor-grounded; **no** normal map, foam image, synthetic luminance/dither/noise field or
  anisotropy claim. The port's tile-index plumbing is already correct; ranked remaining
  causes are tile diversity (top-5 = 73% of cells), neutral eye-plane UVs (now world-ground
  XZ texgen, labelled PORT APPROX), unshaded headlight (donor sun now bound), alpha
  sub-rect sampling and water bands. Batch H builders `TRN-SHADER`, `TRN-WATER`,
  `TRN-GEOM`, `DECOR-01`, `HUD-01` landed with clean targeted smokes; `TRN-DATA` still
  RUNNING. **No donor A/B frame exists, so visual parity stays UNVERIFIED.**
- **Donor decompilation.** `decomp/` lane **CLOSED**: 8 reports `DEC_01…DEC_08` (~440 KB),
  consolidated in `decomp/SUMMARY.md`, evidence ids in `decomp/EVIDENCE_INDEX.md`.
  `CORRECTIONS.md` is the canonical index: **50 rows (32 RESOLVED / 12 PARTIAL / 1
  UNVERIFIED / 1 INFEASIBLE + 4 caveats)**; three engine-side values are
  CONFIRMED_INFEASIBLE (`DBIND_01`). Batch I/K deep dives resolve the rest (alpha grid,
  relief grids, AAF clips, PFX, environment, formations, `.bind`).
- **Defaults (`CFG-01`).** Russia vs Bavaria and fog-off were already defaults; interactive
  defaults changed to **240² (Tiny), `mediterranean`, `low_mountains`/hills**. Gates green
  (selftest 29/29 job 312, uitest 17/17 job 313, CLEAN). **`CFG-02` (no-menu 240² in
  `config.json`) was REVERTED on evidence**: 240² broke 3 selftest steps (26/29) via a
  fixed `_spot()` ring; `MAP-SMALL-01` is RUNNING to scale the harness geometry instead of
  gaming the test.
- **Test status.** All 10 test atoms + shared harness are **authored, not passed**. The
  first ladder attempt **stopped at P0** (job 321: parse errors in an embedded
  `LocalStubGame extends C3Game` fallback); no assertion was weakened and no rerun was
  submitted. `ATOM-REPAIR` + `HARNESS-01` repaired the systemic parse/cast errors;
  `TEST-RUN-02` is RUNNING to restart the ladder. The **final whole-system gate has not
  been run.**

## 1. How to resume (authoritative read order)

1. `CHARTER.md` — governing rules, goals, gates, ownership, scope guard.
2. `CORRECTIONS.md` — the 50-row donor corrections index; cite the authority row, never the
   superseded claim; keep `PORT APPROXIMATION` labels.
3. `GAPS.md` — exists / missing / how-to-fix, plus the 12-item prior-failure watchlist.
4. `SWARM_BOARD.md` — ticket table (scope, owner, state, evidence). **Only COORD edits the
   State column**; this is the freshest per-ticket status.
5. `PROGRESS.md` — coordinator log, decisions S-25-01…S-25-14, gate-status snapshot.

Then follow a topic through the pointer index (§6). `TEST_MATRIX.md`,
`PLAN_IMPLEMENTATION.md`, `VIDEO_QA_PROTOCOL.md` and `decomp/README.md` define the
execution, implementation and capture protocols.

**Snapshot caveat.** Every living doc has frontmatter `updated: 2026-11-25` with **no clock
time**; `CHARTER.md`/`CORRECTIONS.md`/`VIDEO_QA_PROTOCOL.md` are `status: living`,
`GAPS.md`/`TEST_MATRIX.md`/`PLAN_IMPLEMENTATION.md` are `status: draft`, and
`decomp/SUMMARY.md` is `status: lane closed`. `PROGRESS.md` §"Gates status" is explicitly a
**stale prior-doc snapshot** ("not re-measured this session") and is overtaken by the
ticket results in its own log. Re-read `SWARM_BOARD.md`/`PROGRESS.md` before acting; this
README is a point-in-time snapshot and RUNNING tickets will land later.

## 2. Folder map

| Path | One-line description |
|---|---|
| `CHARTER.md` | Rules, owner directive, gates, ownership and scope guard. |
| `PROGRESS.md` | Living coordinator log, decisions S-25-01…S-25-14, gate snapshot. |
| `SWARM_BOARD.md` | Per-ticket state/scope/owner/evidence table (Batches A–K). |
| `GAPS.md` | Aggregated exists/missing/how-to-fix + 12 prior-failure anti-patterns. |
| `TEST_MATRIX.md` | P0→P3→C1→C4→S1→FINAL ladder, 64² fixture, sequential protocol. |
| `PLAN_IMPLEMENTATION.md` | Atomic one-file-per-builder implementation tickets and gating. |
| `CORRECTIONS.md` | Canonical 50-row donor corrections index; status legend. |
| `VIDEO_QA_PROTOCOL.md` | Frame-sequence/MP4 capture & muse-spark analysis protocol. |
| `README.md` | This file — cold-readable entry point. |
| `decomp/README.md` | Donor decompilation lane charter; DEC-01…DEC-08 all DONE. |
| `decomp/SUMMARY.md` | Consolidated donor findings, 14 prior-doc corrections, ranked port implications. |
| `decomp/EVIDENCE_INDEX.md` | Evidence ids / `path:offset` index for all decomp lanes. |
| `decomp/DEC_0x_*.md` | One deep donor decompilation record per aspect (8 files). |
| `reports/<TICKET>.md` | One cold-readable report per analysis/implementation/test worker (53 on disk). |

## 3. Current state — green gates vs pending rows

### Green / recorded (from `PROGRESS.md` log and `SWARM_BOARD.md`)

| Item | Evidence |
|---|---|
| variant selftest **29/29** | tickets 312 (`CFG-01`), 337 (`SEL-01`); 320² control 322 |
| variant uitest **17/17** | tickets 313 (`CFG-01`), 318 (`SEL-01`), 325 (240²), 366 (`UITEST-ANCHOR`, "minimap bottom-right: yes") |
| CLEAN recorded under `CFG-01` | `CLEAN-01` RUNNING for a formal verdict on historical unacked queue failures |
| `SEL-01` real-drag probe **12/12** | job 329 — ids `[10,11]`, building excluded, short click `[10]`, Shift-add `[10,11,12]`, marquee shown then hidden |
| `CAM-RV-01` runtime view-rect **20/20** | job 381 — byte-identical half-map shift; no-shift/double-shift counterfactuals refuted |
| `ATOM-REPAIR` | all 9 atoms load, jobs 364–375, 0 parse errors; `HARNESS-01` cast fix smoke 384, `SCRIPT ERROR 0` |
| Targeted Batch H smokes | 342/343/358/361 `SCRIPT ERROR 0`; CAM 339/356; DALPHA-02 382 ok 6/6 |
| Donor decomp lane **CLOSED** | 8 `DEC_0x_*.md` reports on disk + `decomp/SUMMARY.md` |
| `CORRECTIONS.md` published | 50 indexed corrections, duplicate chains merged |

### Pending / NOT passed

| Row | State | Why |
|---|---|---|
| **P0** terrain only | NOT PASS | First ladder attempt (job 321, `TEST-RUN-01`) failed at load with 4 `SCRIPT ERROR` lines; `TEST-RUN-02` RUNNING to restart from P0. |
| **P1–C4** trees / shore / mines / combos | NOT RUN | Protocol: stop at first failing row; no rerun hoping for green. Author atoms are not PASS claims. |
| **S1** selection atom | NOT PASS | Authored with deliberate `expected_pre_fix_failure` overlay checks; `S1-INPUT-FIX` RUNNING; `TEST_RUN_02_selection_log.md` RESERVED. (SEL-01's 12/12 probe is separate evidence, not an S1 atom gate.) |
| **F0** donor A/B baseline | NOT ESTABLISHED | Blocks every parity claim; metrics never override visual review. |
| **FINAL** (29/29 + 17/17 + clean + owner visual) | PENDING / RESERVED | COORD only, last, once; 2D `app/**` gates must stay untouched and green. |
| `CFG-02` 240² no-menu default | REVERTED | 26/29 at 240 vs 29/29 at 320; `MAP-SMALL-01` RUNNING. |
| `TRN-DATA` (`game.gd`) | RUNNING | Tile diversity / rule parse tranche not merged. |
| Batch I/K deep dives & fixes | RUNNING | `MMJUMP-01`, `FX-WEATHER-01`, `QA-AUDIT-01`, `RELIEF-01`, `SEASON-PLAN-01`, `S1-INPUT-FIX`, `CLEAN-01`, `DUNIT-01`, `DAUDIO-01`, `DMAPGEN-01`, `DBUILD-01`, `ATLAS-01`, `VID-CAP-01`. |

**Honesty rule:** report files authored ≠ tests passed; "green" above means a recorded
runner result/job id in the living docs, not an inference from a report's existence.
Donor visual parity remains **UNVERIFIED**, and the final whole-system gate has **not**
been run.

## 4. Ownership discipline (binding)

- **One file per builder.** Analysis workers are read-only on code and own exactly one
  report; shared code (`main.gd`, `input_controller.gd`, `world3d*.gd`, `hud.gd`, shaders,
  tests) is READ-ONLY until an integration ticket grants one builder exclusive ownership.
- **Backups before edits:** `inbox\backup\<name>.bak-<TICKET>`.
- **Runner only:** one Godot at a time via
  `python variant3d\tools\godot_runner.py run --id <ticket>-<row> --timeout <s> -- …`.
  Never invoke `godot` directly; no re-submitting while a job is queued. Host is Windows:
  `python` (3.14), not `python3`. Donor is read-only at `C:\Games\Cossacks 3` (Python
  `bytes` + latin-1; never run/copy binaries).
- **Donor is truth; 2D port is secondary.** Every 3D constant cites donor `path:line` or an
  evidence id, else `UNVERIFIED` / `PORT APPROXIMATION`.
- **Piece before whole.** Each atom tested alone on the same smallest (64²) map; a second
  agent re-checks each capture; stop at first failure; never weaken an assertion to get
  green; final whole test once at the end (`SWARM_OPS.md` §7.6).
- **COORD only** edits `SWARM_BOARD.md` State, merges disjoint diffs and runs the full
  gates once after all Batch H merges (decision S-25-12).
- **Evidence labels** `observed` / `derived` / `inferred` / `UNVERIFIED` in every report;
  re-verify important donor findings with a 2nd/3rd pass. 2D shipping gates stay green.

## 5. Failure register — do not repeat (`GAPS.md` §3)

Never claim "donor-like" from metrics/node counts without an A/B frame; never use a
contaminated/off-feature donor crop; metrics never override visual review; never project
SIM metres through `camera3d.world_to_px()` (expects centred); never invent sub-tile
indices, metres-per-cell or eye-plane literals; FIFO runner only, no direct `godot`;
re-verify stale docs/artifacts before acting; never weaken a test; do not "fix" what is
already correct (V3D_02 §"already correct" 1–12, DTRN_01 §6.1); keep drag/click and
`cmd_*` mutually exclusive; donor is 3D perspective, not 2D.

## 6. Report pointer index (by topic)

### Selection
- `reports/DSEL_01_donor_selection_rectangle.md` — donor events/filters/algorithm; 0.005 m
  world epsilon, yellow 1 px brush, `KeyDoubleDelay=0.5`, native predicate UNVERIFIED.
- `reports/DSEL_02_donor_pick_math.md` — screen↔world projection, ray→AABB click pick,
  world-ground drag rect (3 passes).
- `reports/V3D_01_selection_rectangle_audit.md` — 3D code-path audit; box never drawn.
- `reports/V2D_01_2d_selection_logic.md` — SECONDARY 2D logical analogue.
- `reports/RV_SEL_01_selection_reverify.md` — 4th pass: `[*]=;` is live code, conflicts
  confirmed byte-level; `reports/RV_CAM_01_fov_resolution.md` — FOV CONFIRMED_UNVERIFIED,
  17.27° kept as PORT APPROX.
- `reports/SEL_01_implementation.md` — landed fix + gate ids; `reports/CAM_01_view_rect.md`,
  `reports/CAM_02_view_rect_shift.md`, `reports/CAM_RV_01_view_rect_runtime.md` — viewport
  rect fix + 20/20 confirmation.
- `reports/HUD_01_minimap.md`, `reports/UITEST_ANCHOR.md` — donor bottom-right 240×240
  minimap; `reports/TEST_S1_report.md` — selection atom (NOT RUN).

### Terrain
- `reports/DTRN_01_donor_terrain_pipeline.md` — textures/atlas/blend/shaders; no normal map.
- `reports/DTRN_02_donor_terrain_geometry.md` — relief float32 grids, height clamp ±2.964,
  props; `reports/DTRN_03_donor_shore_water.md` — continuous depth ramp + waterline rule.
- `reports/DTRN_04_donor_trees.md`, `reports/DTRN_05_donor_mines.md`,
  `reports/DTRN_06_donor_grass_decals.md` — decor scale/jitter, mine disc, seam alpha.
- `reports/V3D_02_terrain_render_audit.md` — 15 ranked causes, T0–T5 ladder, 12 do-not-redo
  items; `reports/V2D_02_2d_terrain_logic.md` — SECONDARY logical chain.
- `reports/RV_TRN_01_texgen_mask_reverify.md` — 8×4×64 alpha grid confirmed, face planes,
  eye planes UNVERIFIED; `reports/RV_TRN_02_smoothing_rules.md` — 1,864-line full parse,
  road probs 0.5/0.375/0.125; `reports/RV_TRN_03_water_bindings.md` — `hmapTex` negatively
  resolved, `shore_prox` inert.
- `reports/DALPHA_01_alpha_subrect.md` / `DALPHA_02_patch_mapping.md` — alpha grid decoder +
  APPROX tile→patch map; `reports/DPATTERN_01_relief_grids.md` — 26 bit-exact grids;
  `reports/DENV_01_environment.md` — light/sky/fog/season truth.

### Decomp (`decomp/`)
- `decomp/README.md`, `decomp/SUMMARY.md`, `decomp/EVIDENCE_INDEX.md`,
  `decomp/DEC_01_binaries_rtti.md` … `decomp/DEC_08_ui_strings.md`.
- `reports/DBIND_01_wus_bind.md` — packed `.bind` proof: eye planes / FOV / selection
  predicate CONFIRMED_INFEASIBLE; `reports/DANIM_01_action_ranges.md` — 335/335 frame-0
  bind pose (DEC-04 refuted); `reports/DFORM_01_formations_morale.md` — no numeric morale.

### Tests (authored, not passed)
- `reports/TEST_01_smallmap_harness.md` — 64² harness design; `reports/TEST_HARNESS_report.md`.
- `reports/TEST_P0_report.md` … `TEST_P3_report.md`, `reports/TEST_C1_report.md` …
  `TEST_C4_report.md`, `reports/TEST_S1_report.md` — one atom per ladder row.
- `reports/TEST_RUN_01_ladder_log.md` — stopped at P0 (job 321);
  `reports/ATOM_REPAIR_report.md`, `reports/HARNESS_01_cast_fix.md` — repairs;
  `reports/INT_REGISTRY_implementation.md` — manifest/test_all roots fixed.

### Implementations / defaults
- `reports/SEL_01_implementation.md` — selection fix (green).
- `reports/CFG_01_skirmish_defaults.md` — 240²/Mediterranean/hills defaults (green);
  `reports/CFG_02_no_menu_defaults.md` — REVERTED on evidence.
- `reports/TRN_SHADER_implementation.md`, `reports/TRN_WATER_implementation.md`,
  `reports/TRN_GEOM_implementation.md`, `reports/DECOR_01_implementation.md`,
  `reports/HUD_01_minimap.md`, `reports/UITEST_ANCHOR.md` — Batch H disjoint builders;
  `reports/INT_REGISTRY_implementation.md` — registry.

### Deep dives / synthesis
- `reports/DOC_01_all_docs_synthesis.md` — 11-section prior-doc consolidation, 12-item
  failure register, 18 stale-vs-current arbitrations.
- `reports/DFX_01_pfx_effects.md` — PFX ASCII/particles, no construction dust;
  `reports/DENV_01_environment.md` — environment/season/weather;
  `reports/DANIM_01_action_ranges.md`, `reports/DBIND_01_wus_bind.md`,
  `reports/DPATTERN_01_relief_grids.md`, `reports/DALPHA_01_alpha_subrect.md`.

---

**Bottom line for a cold reader:** read the five authority docs in §1, trust
`SWARM_BOARD.md`/`PROGRESS.md` for freshest state, treat every report as evidence **not**
a PASS, and do not run the FINAL gate or claim donor visual parity until F0 A/B and the
restarted P0→C4→S1 ladder are green.
