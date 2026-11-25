---
title: COORD SWARM 2026-11-25 — cold-readable entry point
area: coordination / variant3d
owner: COORD
author: DOC-03 (documentation micro-worker)
refreshed_by: README-UPDATE-01 (late-wave facts added; DOC-03 base preserved)
updated: 2026-11-25
status: living — in-day snapshot; RUNNING tickets may land after this file
snapshot: "Late-wave read 2026-11-25 ~11:00 local; board/reports may land after this file"
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
  `TRN-GEOM`, `DECOR-01`, `HUD-01` landed with clean targeted smokes; `TRN-DATA` is now DONE
  (118/118 lists + 282 TileName, determinism 5/5 job 423 — `SWARM_BOARD.md:111`).
  **No donor A/B frame exists, so visual parity stays UNVERIFIED.**
- **Donor decompilation.** `decomp/` lane **CLOSED**: 8 reports `DEC_01…DEC_08` (~440 KB),
  consolidated in `decomp/SUMMARY.md`, evidence ids in `decomp/EVIDENCE_INDEX.md`.
  `CORRECTIONS.md` is the canonical index: **57 rows** (DOC-03 snapshot 50; rows 51–57
  landed since — `CORRECTIONS.md:100-105,159-170`), with the status legend at `:38-41`
  and the 8-value UNVERIFIED section at `:107-129`. Three engine-side
  values are CONFIRMED_INFEASIBLE (`DBIND_01`). Batch I/K/O deep dives resolve the rest
  (alpha grid, relief grids, AAF clips, PFX, environment, formations, `.bind`, atlas
  transport, map sizes, audio, defaults).
- **Defaults (`CFG-01`).** Russia vs Bavaria and fog-off were already defaults; interactive
  defaults changed to **240² (Tiny), `mediterranean`, `low_mountains`/hills**. Gates green
  (selftest 29/29 job 312, uitest 17/17 job 313, CLEAN). **`CFG-02` (no-menu 240² in
  `config.json`) was REVERTED on evidence**: 240² broke 3 selftest steps (26/29) via a
  fixed `_spot()` ring; `MAP-SMALL-01` then landed the code (commit `f9dd8d16`) but never
  landed its report, and all 7 requested defaults now resolve on BOTH interactive and
  menu-skipping paths (`reports/DEFAULTS_VERIFY_01.md:114-118`). The integrated selftest
  artifact is still not green (`:92`).
- **Test status (late-wave measured).** The first ladder attempt stopped at P0 (job 321);
  `ATOM-REPAIR`/`HARNESS-01` fixed parse/cast errors, and `TEST-RUN-02` stopped at P0 again
  (job 404: 20 passes / 1 fail, `full_width_dark_rows=720`, `SCRIPT ERROR 0`). **S1 atom now
  PASS 23/23** (job 414, `reports/S1_INPUT_FIX.md:153-176`) and **CAM-RV-01 20/20**
  (job 381). P0 still fails its replacement luma gates; P1–C4 remain NOT RUN. The
  integrated selftest is 26/29 at HEAD / 28/29 in the worktree
  (`reports/QA_AUDIT_01_implementation_claims.md:47-57`); **the final whole-system gate has
  not been run.**
- **OWNER runtime errors (live windowed game, not a gate).** `PROGRESS.md:104-115` records
  the flat-root morph warning (labelled PORT APPROX), `hud3d_adapter.gd:172-173` inferred-type
  parse errors cascading to `hud.gd:207` (`GDScript.new()`), and repeated
  `mill_rotor.png/.ctex` load errors from `world3d_entities.gd:1430/1458`. Owner-assigned
  fixes: `MINIMAP-QUAD-01` explicit types (`SWARM_BOARD.md:120`, still RUNNING);
  `ASSET-IMPORT-01` cache regeneration (job 444 ok but target ctex still absent —
  `reports/ASSET_IMPORT_01.md:9,141`); `MOTION-ANIM-01` rotor fallback + spin audit
  (`reports/MOTION_ANIM_01.md:191-230`). The `hud.gd` error was a cascade, not a second bug.
- **P0 dark terrain — root cause and new gate.** `reports/TERRAIN_DARK_01.md` measured a
  near-black P0 frame (mean luma 13.271); `reports/LIGHT_02_light_space.md:212-246`
  re-derived donor `light.cfg Position` as a **Y-up world direction** and showed the old
  `(x/4, z/2, y)` mapping put donor Z into Godot Y → flat-ground `dot=0`. `TERRAIN-DARK-FIX`'s
  axis swap is CORRECT (keep), `/4,/2` is PORT APPROX, and `world3d_terrain.gd:138`
  `SUN_LIGHTVEC` remains un-swapped (SP-6 follow-up, `:267-275`). `P0_GATE_01` replaced the
  water-only dark-row assertion with strict `ground_mean_luma>=40` / `ground_max_luma>=100`
  (PORT APPROX); job 421 failed as designed (20 passes / 2 gate fails, `SCRIPT ERROR 0`,
  `reports/P0_GATE_01.md:134-174`).
- **Muse-spark motion findings and routed fixes.** Per `VIDEO_QA_PROTOCOL.md:11-15,30-46`,
  `VID-CAP-01` captured 16 distinct windowed frames (job 408, `PASS 10/10`);
  `reports/VID_AN_01_motion_analysis.md:101-125` reports translation FAIL (~14 m stall),
  squad FAIL (1/4 moves), pose FAIL at data level (visual pop UNDETERMINED), direction FAIL
  (91°/166° snaps), contact PASS (coarse), uniqueness PASS — donor parity UNVERIFIED.
  `MOTION-ANIM-01` landed the presentation-side speed gate, yaw clamp and frozen-pose refresh
  plus the rotor fallback (`reports/MOTION_ANIM_01.md:20-35,191-230`, parse-only job 435);
  SIM stall and squad propagation are routed to a `game.gd` ticket (`:138-147`).
- **Config pipeline (not "all features configurable").** `CONFIG_PIPELINE.md:63-104,321-324`
  counts 21 `features.*` getters: **7 WIRED / 2 READER_ONLY / 2 UI_ONLY / 10 PENDING** at its
  snapshot; plan remainder headline 34 (strictly 39 no-getter + 4 partial rows, `:118-129`).
  Menu exposes 6 options and **Snow is PORT-UI-ONLY** — the driver is never called (`:223,306-307`);
  `config.json` has no `features` section (`:286,298-301`) and smokes are parse-only (`:287,302-305`).
- **Winter atlas + LFS plan.** `reports/SP_04_winter_atlas.md:101-144` built an index-preserving
  124,463,306-B winter PNG + 79,837-B manifest (16/16 self-check, 8/8 pixel spot-check, Summer
  hashes unchanged); `reports/LFS_PLAN_01.md:162-190` recommends owner-run LFS option (a)
  (new oid `5d0dd8f…`), with **no git action taken**. Open: renderer/test constants use
  `tile_index_winter_atlas.*` while artifacts are `tile_index_atlas_winter.*`
  (`SP_04 §7.2`, `LFS_PLAN_01:152-160`); a failed Winter single-load silently falls back to
  Summer (`:188`). Runtime swap is UNVERIFIED: SP-4 and SP-6 are RUNNING, SP-8's atom is
  authored but `PENDING_DEP` (`SWARM_BOARD.md:173-175`).
- **Donor map-size mismatch.** `reports/DMAPGEN_01_skirmish_options.md:59-75` gives donor
  Tiny 256 / Normal 320 / Large 480 / Huge 640 with Normal as default; the port dropdown is
  240/320/400/480 (`menu.gd:726`), so port Tiny 240 is an accepted approximation, not donor
  literal (`reports/DEFAULTS_VERIFY_01.md:94`). All 7 requested defaults resolve, but the raw
  `map_type: land` key is a latent documentation trap (`:91-93`).

## 1. How to resume (authoritative read order)

1. `CHARTER.md` — governing rules, goals, gates, ownership, scope guard.
2. `CORRECTIONS.md` — the **57-row** donor corrections index (`:100-105,159-170`); cite the
   authority row, never the superseded claim; keep `PORT APPROXIMATION` labels.
3. `GAPS.md` — exists / missing / how-to-fix, plus the 12-item prior-failure watchlist;
   its §2 lighting and P0-dark rows now carry the LIGHT-02 / TERRAIN-DARK-FIX findings
   (`GAPS.md:35,42`).
4. `SWARM_BOARD.md` — ticket table (scope, owner, state, evidence). **Only COORD edits the
   State column**; this is the freshest per-ticket status. Note Batches M/O contain late
   rows (config, atlas, LFS) that post-date DOC-03's original index.
5. `PROGRESS.md` — coordinator log, decisions S-25-01…S-25-15, gate-status snapshot and
   the OWNER RUNTIME REPORT (`:104-115`).
6. `CONFIG_PIPELINE.md` — status freeze for the 21 `features.*` getters, unwired remainder
   and menu subset; read before quoting any "global config" claim (`:296-315`).

Then follow a topic through the pointer index (§6). `TEST_MATRIX.md`,
`PLAN_IMPLEMENTATION.md`, `VIDEO_QA_PROTOCOL.md` and `decomp/README.md` define the
execution, implementation and capture protocols. `decomp/SUMMARY.md` is the closed
decompilation lane's consolidated record (8 `DEC_0x_*.md` reports; `status: lane closed`,
`:1-15`), with evidence ids in `decomp/EVIDENCE_INDEX.md`.

**Snapshot caveat.** Every living doc has frontmatter `updated: 2026-11-25` with **no clock
time**; `CHARTER.md`/`CORRECTIONS.md`/`VIDEO_QA_PROTOCOL.md` are `status: living`,
`GAPS.md`/`TEST_MATRIX.md`/`PLAN_IMPLEMENTATION.md` are `status: draft`,
`CONFIG_PIPELINE.md` is a status freeze of its own working-tree read (`:11`), and
`decomp/SUMMARY.md` is `status: lane closed`. `PROGRESS.md` §"Gates status" was flagged stale
by DOC-03 and is now **explicitly contradicted** by QA-AUDIT-01 for the integrated selftest
(`PROGRESS.md:188` claims 29/29 repeatedly; `reports/QA_AUDIT_01_implementation_claims.md:47-57`
measures 26/29 HEAD / 28/29 worktree). `VIDEO_QA_PROTOCOL.md:54-56` "Current queue" is also
stale — both VID-CAP-01 and VID-AN-01 have landed. Likewise `SWARM_BOARD.md` marks
CONFIG-UI-01 / CONFIG-WIRE-SEL RUNNING although their reports exist
(`CONFIG_PIPELINE.md:213-214,308-311`). Re-read `SWARM_BOARD.md`/`PROGRESS.md` before acting;
this README is a point-in-time snapshot and RUNNING tickets will land later.

**Post-snapshot landings (observed during this edit, not promoted to PASS):** `SP-06`
renderer hook delivered with no gates (`reports/SP_06_renderer_hook.md` frontmatter),
`WEATHER-DRIVER-01` at `PENDING_SMOKE_RESULT` (`reports/WEATHER_DRIVER_01.md`),
`AUDIO-SEL-02` at `PENDING_VALIDATION` (`reports/AUDIO_SEL_02.md`), and read-only
`QA-WINTER-01` / `GDIGNORE-01` audits (`reports/QA_WINTER_01.md`, `reports/GDIGNORE_01.md`).
These post-date the §0/§3 tables; their own status labels must be re-read before use, and
none changes the gate verdicts above.

## 2. Folder map

| Path | One-line description |
|---|---|
| `CHARTER.md` | Rules, owner directive, gates, ownership and scope guard. |
| `PROGRESS.md` | Living coordinator log, decisions S-25-01…S-25-15, gate snapshot, OWNER RUNTIME REPORT (`:104-115`). |
| `SWARM_BOARD.md` | Per-ticket state/scope/owner/evidence table (Batches A–O, incl. M/Late-wave rows). |
| `GAPS.md` | Aggregated exists/missing/how-to-fix + 12 prior-failure anti-patterns. |
| `TEST_MATRIX.md` | P0→P3→C1→C4→S1→FINAL ladder, 64² fixture, sequential protocol. |
| `PLAN_IMPLEMENTATION.md` | Atomic one-file-per-builder implementation tickets and gating. |
| `CORRECTIONS.md` | Canonical **57-row** donor corrections index; status legend (`:38-41,159-170`). |
| `CONFIG_PIPELINE.md` | CONFIG-DOC-01 status freeze: 21 getters, 34/43 unwired remainder, menu subset (`:296-340`). |
| `VIDEO_QA_PROTOCOL.md` | Frame-sequence/MP4 capture & muse-spark analysis protocol (queue at `:54-56` stale). |
| `README.md` | This file — cold-readable entry point (DOC-03 base + README-UPDATE-01 refresh). |
| `decomp/README.md` | Donor decompilation lane charter; DEC-01…DEC-08 all DONE. |
| `decomp/SUMMARY.md` | Consolidated donor findings, 14 prior-doc corrections, ranked port implications. |
| `decomp/EVIDENCE_INDEX.md` | Evidence ids / `path:offset` index for all decomp lanes. |
| `decomp/DEC_0x_*.md` | One deep donor decompilation record per aspect (8 files). |
| `reports/<TICKET>.md` | One cold-readable report per analysis/implementation/test worker (**99 at this README edit**, including `README_UPDATE_01.md`; count drifts as RUNNING tickets land). |

## 3. Current state — green gates vs pending rows

### Green / recorded (from `PROGRESS.md` log, `SWARM_BOARD.md` and landed reports)

| Item | Evidence |
|---|---|
| variant selftest **29/29** (per-job, not integrated) | tickets 312 (`CFG-01`), 337 (`SEL-01`); 320² control 322 — valid only for those job artifacts (`QA_AUDIT_01:47-57`) |
| variant uitest **17/17** | tickets 313 (`CFG-01`), 318 (`SEL-01`), 325 (240²), 366 (`UITEST-ANCHOR`), 440 (`CONFIG-WIRE-HUD`, `SWARM_BOARD.md:190`) |
| CLEAN history | `CLEAN-01` DONE — **NOT CLEAN** verdict honestly recorded; `CLEAN-02` fixed `assert_clean.py:34` to read variant spool; gate signing deferred to COORD after drain (`SWARM_BOARD.md:156-157`) |
| `SEL-01` real-drag probe **12/12** | job 329 — ids `[10,11]`, building excluded, short click `[10]`, Shift-add `[10,11,12]`, marquee shown then hidden |
| `CAM-RV-01` runtime view-rect **20/20** | job 381 — byte-identical half-map shift; no-shift/double-shift counterfactuals refuted (`reports/CAM_RV_01_view_rect_runtime.md:179-197`) |
| **S1 selection atom 23/23** | job 414 windowed real input, `SCRIPT ERROR 0`, all 24 `check()` calls and 4 `expected_pre_fix_failure` markers retained (`reports/S1_INPUT_FIX.md:153-176,193-206`) — atom-level only, not the full ladder |
| VID-CAP-01 **10/10**, VID-AN-01 delivered | job 408, 16 distinct GPU frames + contact sheet + MP4 (`SWARM_BOARD.md:115`); analysis verdicts at `reports/VID_AN_01_motion_analysis.md:101-125` |
| `ATOM-REPAIR` / harness / Batch H / FX smokes | atoms load jobs 364–375, cast fix 384, `SCRIPT ERROR 0`; 342/343/358/361, CAM 339/356, DALPHA-02 382 (6/6), `t_fx3d` 13/13 job 434 (`SWARM_BOARD.md:96-97,118`) |
| Winter atlas build checks | self-check 16/16 + re-check 16/16 + 8/8 pixel spot-check, Summer hashes unchanged (`reports/SP_04_winter_atlas.md:119-144`) — structural, not a GPU A/B |
| Donor decomp lane **CLOSED** | 8 `DEC_0x_*.md` reports + `decomp/SUMMARY.md` (`status: lane closed`, `:1-15`) |
| `CORRECTIONS.md` published | **57** indexed corrections, duplicate chains merged (`:100-105,159-170`) |

### Pending / NOT passed

| Row | State | Why |
|---|---|---|
| **P0** terrain only | NOT PASS | Two stops: job 321 parse errors, then job 404 (`TEST_RUN_02`: 20 passes / 1 fail, `full_width_dark_rows=720`). Axis-correct `TERRAIN-DARK-FIX` landed (`reports/LIGHT_02_light_space.md:239-246`); strict new gates still fail `mean_luma=13.271` / `max_luma=27.413` (job 421, `reports/P0_GATE_01.md:134-174`). No rerun. |
| **P1–C4** trees / shore / mines / combos | NOT RUN | Protocol: stop at first failing row; no rerun hoping for green. Author atoms are not PASS claims. |
| **S1** selection atom | **PASS 23/23** (atom only) | Job 414 (`reports/S1_INPUT_FIX.md:153-176`); still not a ladder row — per `TEST_MATRIX.md:58` a second agent must re-check any capture, and Shift=add remains a declared divergence (`:220-224` of the report). `TEST_RUN_02_selection_log.md` not landed. |
| **Integrated selftest** | NOT GREEN | HEAD 26/29 (`wall`/`shell`/`farm_cap`), worktree 28/29 (`build`); `reports/QA_AUDIT_01_implementation_claims.md:47-57`, `reports/DEFAULTS_VERIFY_01.md:92`. `QA-PARITY-01` RUNNING; ordered plan at `reports/FINAL_GATE_PLAN_01.md:53-90`. |
| **F0** donor A/B baseline | NOT ESTABLISHED | Blocks every parity claim; metrics never override visual review (`CORRECTIONS.md:122`). |
| **FINAL** (29/29 + 17/17 + clean + owner visual) | PENDING / RESERVED | COORD only, last, once; 2D `app/**` gates must stay untouched and green. Prerequisites in `reports/FINAL_GATE_PLAN_01.md:53-105`. |
| `CFG-02` / MAP-SMALL-01 | CODE LANDED, REPORT MISSING | 240² committed via `f9dd8d16`, report absent; defaults resolve but integrated selftest non-green (`reports/DEFAULTS_VERIFY_01.md:92,97-104`). |
| `TRN-DATA` (`game.gd`) | DONE (per report) | 118/118 lists + 282 TileName embedded, determinism 5/5 job 423; selftest 28/29 on concurrent rotor `.ctex` race (`SWARM_BOARD.md:111`). |
| OWNER runtime errors | PARTLY ADDRESSED | Minimap parse/quad owner `MINIMAP-QUAD-01` RUNNING (`SWARM_BOARD.md:120`); rotor target ctex still absent after job 444 (`reports/ASSET_IMPORT_01.md:141`); `MOTION-ANIM-01` fallback is parse-only (job 435, `reports/MOTION_ANIM_01.md:107-122`). |
| Config pipeline | INCOMPLETE | 21 getters but only 7 WIRED; `config.json` has no `features` key; Snow menu row PORT-UI-ONLY with uncalled driver (`CONFIG_PIPELINE.md:102-104,223,286,306-307`). |
| Winter atlas / LFS | BUILT, NOT WIRED | SP-4 artifact built; SP-6/SP-7 open, path-name mismatch and silent Summer fallback unresolved (`reports/SP_04_winter_atlas.md:146-166`; `reports/LFS_PLAN_01.md:152-160,188`). No git action taken. |
| Late-wave RUNNING tickets | RUNNING (board snapshot) | `SEASON-PLAN-01`, `SP-1`, `SP-4`, `SP-6`, `CONFIG-WIRE-RELIEF`, `WEATHER-DRIVER-01`, `MAPSIZE-01`, `AUDIO-SEL-02`, `QA-PARITY-01`, `PERF-3D-01`, `MINIMAP-QUAD-01` (`SWARM_BOARD.md:117-119,169-176,184-192,217-229`). Board-stale: `CONFIG-UI-01`, `CONFIG-WIRE-SEL`, `MOTION-ANIM-01`, `FINAL-GATE-PLAN-01` have reports on disk (`CONFIG_PIPELINE.md:213-214,308-311`; `reports/` listing). |

**Honesty rule:** report files authored ≠ tests passed; "green" above means a recorded
runner result/job id in the living docs, not an inference from a report's existence.
Donor visual parity remains **UNVERIFIED** (no donor GPU A/B, `CORRECTIONS.md:122`), and
the final whole-system gate has **not** been run. A PASS on an atom (S1 23/23, CAM-RV-01
20/20) is scoped to that atom's scenario — it is not a whole-system PASS.

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
`cmd_*` mutually exclusive; donor is 3D perspective, not 2D. Late-wave additions: do not
call `features.*` "globally configurable" while `config.json` has no `features` section
(`CONFIG_PIPELINE.md:286,298-301`); do not call parse-only `--check-only` smokes runtime proof
(`:302-305`); do not claim Winter art loads while the path constants disagree
(`reports/SP_04_winter_atlas.md:158-166`); do not revert TERRAIN-DARK-FIX's correct axis swap
(`reports/LIGHT_02_light_space.md:239-246`).

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
  minimap; `reports/MMJUMP_01_minimap_jump.md` — reverted with evidence;
  `reports/MMJUMP_02_minimap_jump.md` — donor-offset API added, CAM-RV-01 20/20 intact.
- `reports/S1_INPUT_FIX.md` — S1 atom **PASS 23/23** (job 414, windowed real input);
  `reports/TEST_S1_report.md` is the original authored atom (no PASS claim there).
  Owner-error follow-ups: `MINIMAP-QUAD-01` is **RUNNING with no report on disk**
  (`SWARM_BOARD.md:120`), and `reports/ASSET_IMPORT_01.md` records the rotor cache miss
  (target ctex still absent — `ASSET_IMPORT_01.md:141`; `PROGRESS.md:104-115`).

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
- **P0 darkness diagnosis / gate (late wave):** `reports/PIXEL_01_p0_capture_review.md`
  (genuine near-black frame), `reports/METRIC_01_dark_rows.md` (`full_width_dark_rows` is a
  water-band predicate), `reports/TERRAIN_DARK_01.md` (root-cause diagnosis),
  `reports/LIGHT_02_light_space.md:212-246` (Y-up donor sun, axis swap correct, `/4,/2` APPROX,
  `SUN_LIGHTVEC` follow-up), `reports/P0_GATE_01.md:134-224` (replacement luma gates, job 421
  fails as designed). `TERRAIN-DARK-FIX` is **RUNNING with no report on disk**
  (`SWARM_BOARD.md:186`), while LIGHT-02 re-derived the same landed shader edit independently
  (`SWARM_BOARD.md:119`).

### Decomp (`decomp/`)
- `decomp/README.md`, `decomp/SUMMARY.md`, `decomp/EVIDENCE_INDEX.md`,
  `decomp/DEC_01_binaries_rtti.md` … `decomp/DEC_08_ui_strings.md`.
- `reports/DBIND_01_wus_bind.md` — packed `.bind` proof: eye planes / FOV / selection
  predicate CONFIRMED_INFEASIBLE; `reports/DANIM_01_action_ranges.md` — 335/335 frame-0
  bind pose (DEC-04 refuted); `reports/DFORM_01_formations_morale.md` — no numeric morale.

### Tests (atoms authored; only some rows measured)
- `reports/TEST_01_smallmap_harness.md` — 64² harness design; `reports/TEST_HARNESS_report.md`.
- `reports/TEST_P0_report.md` … `TEST_P3_report.md`, `reports/TEST_C1_report.md` …
  `TEST_C4_report.md`, `reports/TEST_S1_report.md` — one atom per ladder row.
- `reports/TEST_RUN_01_ladder_log.md` — stopped at P0 (job 321, parse errors);
  `reports/ATOM_REPAIR_report.md`, `reports/HARNESS_01_cast_fix.md` — repairs;
  `reports/TEST_RUN_02_ladder_log.md` — **DONE, stopped at P0 again** (job 404, 20/1, no rerun);
  `reports/INT_REGISTRY_implementation.md` — manifest/test_all roots fixed.
- `reports/P0_GATE_01.md` — strict applicable luma gates; `reports/S1_INPUT_FIX.md` — S1
  PASS 23/23 (job 414); `reports/CAM_RV_01_view_rect_runtime.md` — 20/20 (job 381).
- `reports/QA_AUDIT_01_implementation_claims.md` — per-ticket diff audit, integrated selftest
  NOT green; `reports/DEFAULTS_VERIFY_01.md` — defaults resolution + MAP-SMALL-01 report gap;
  `reports/FINAL_GATE_PLAN_01.md` — ordered prerequisites for COORD's single final gate.

### Config pipeline (late wave)
- `reports/CONFIG_PLAN_01.md` — 55-feature inventory + proposed schema/UI subset;
  `reports/CONFIG_CORE_01.md` — 21 defaults + 21 typed getters (smoke 419, parse-only).
- `CONFIG_PIPELINE.md:59-104,211-230,296-340` — the cold-readable status freeze: key table,
  menu subset (**Snow PORT-UI-ONLY**), ownership ladder, 11 risks, honesty constraints.
- `reports/QA_CONFIG_01_getters.md` — getter audit (21 exist; counts reconciled by snapshot);
  `reports/CONFIG_WIRE_SEL.md`, `CONFIG_WIRE_CAM.md`, `CONFIG_WIRE_WATER.md`,
  `CONFIG_WIRE_HUD.md` — leaf consumers; `reports/CONFIG_UI_01.md` — menu rows.
- `reports/DEFAULTS_VERIFY_01.md:91-105` — D1 raw `land` key, D2 MAP-SMALL-01 report gap,
  D4 port Tiny 240 vs donor 256, and REC-GATE-03 (re-run gates after all merges).

### Season, atlas transport and LFS (late wave)
- `reports/SEASON_PLAN_01.md` + `reports/SP_01_season_enum.md` … `SP_08_season_test.md` —
  index-preserving season swap plan and tickets; `SP-1/4/6` still RUNNING per
  `SWARM_BOARD.md:169-176`.
- `reports/SP_02_winter_dictionary.md` — 124-entry winter alias table;
  `reports/SP_03_desert_remap.md` — 11 pairs + height-gated `rock8`;
  `reports/SP_04_winter_atlas.md:101-144` — built atlas + verification; `:146-166` — path
  mismatch and LFS decision ownership; `:203-208` — SP-6/SP-8 remainder.
- `reports/ATLAS_01_transport.md` — split parts concatenate byte-identically; big PNG **is**
  LFS-tracked but ~180 MB of split parts remain ordinary blobs (`:158-193`).
- `reports/LFS_PLAN_01.md:162-190` — recommend owner-run LFS option (a), no git action;
  fresh clone / remote LFS availability **UNVERIFIED**.

### Motion / video QA (late wave)
- `VIDEO_QA_PROTOCOL.md:11-15,30-52` — capture and analysis rules; its "Current queue" at
  `:54-56` is stale (both tickets landed).
- `reports/VID_CAP_01_capture.md` — 16 windowed GPU frames + MP4, job 408 `PASS 10/10`;
  `reports/VID_AN_01_motion_analysis.md:101-125` — frame-numbered verdicts and routed fixes.
- `reports/MOTION_ANIM_01.md:20-35,107-147,191-230` — landed presentation-side fixes and
  rotor fallback (parse-only job 435); SIM stall/squad propagation left to `game.gd`.
- `reports/DANIM_01_action_ranges.md`, `decomp/DEC_04_anim_formats.md` — donor AAF ranges
  and pose payloads; still no donor footage, so motion parity stays UNVERIFIED.

### Map sizes and defaults (late wave)
- `reports/DMAPGEN_01_skirmish_options.md:59-75` — donor sizes 256/320/480/640, default 320;
  `:212-270` — 64-bit seed chain and stage reseeds absent in port.
- `reports/DEFAULTS_VERIFY_01.md:114-118` — all 7 requested defaults resolve on both paths;
  `MAPSIZE-01` is **RUNNING with no report on disk** (`SWARM_BOARD.md:224`).

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

**Bottom line for a cold reader:** read the authority docs in §1 (including
`CONFIG_PIPELINE.md`), trust `SWARM_BOARD.md`/`PROGRESS.md` for freshest ticket state but
`reports/QA_AUDIT_01_implementation_claims.md:47-57` for the integrated selftest, and treat
every report as evidence **not** a whole-system PASS. Measured atom wins (S1 23/23, CAM-RV-01
20/20, VID-CAP 10/10) are scenario-scoped. Do not run the FINAL gate or claim donor visual
parity until F0 A/B, the P0→C4→S1 ladder, the integrated 29/29+17/17+CLEAN re-verification
and the late-wave owner-error fixes are all green (`reports/FINAL_GATE_PLAN_01.md:53-105`).
Donor visual parity stays UNVERIFIED; the final whole-system gate has not been run.
