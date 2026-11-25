---
title: PROGRESS — 2026-11-25 coord swarm
area: coordination
owner: COORD
updated: 2026-11-25
status: living
---

# 📈 Progress — 2026-11-25

## Session goal
Fix the two named 3D faults (selection rectangle; terrain quality) **with donor truth as
primary evidence**, using a large swarm of tiny read-only analysis tickets first, then
isolated tiny piece tests (terrain → +trees → +shore → +mines → combos), then disjoint
implementation tickets, then one final whole-system gate.

## Log

### 2026-11-25 — Batch A launch (14 micro-workers)
- [x] Created `docs/coord_swarm_2026-11-25/` with `CHARTER.md`, `SWARM_BOARD.md`,
      `PROGRESS.md`, `TEST_MATRIX.md` and `reports/`.
- [x] Read orientation docs: `docs/RESUME.md`, `docs/SWARM_OPS.md`, `docs/variant3d/README.md`,
      `docs/variant3d/STATUS_WAVE7_PHASE2.md` (the last states: functional gates green,
      **donor visual parity UNVERIFIED**, donor-sampled animation is an approximation,
      terrain was reworked to donor-representation tile-index on 2026-11-24 via V7-92).
- [x] Confirmed on disk: variant3d has 41 scripts incl. `picking3d.gd`, `camera3d.gd`,
      `world3d_terrain.gd`, `water3d.gd`, `world3d_entities.gd`, `tile_atlas_loader.gd`,
      `terrain3d_sandbox.gd`; donor at `C:\Games\Cossacks 3\data`.
- [x] Dispatched 14 analysis micro-agents (8 donor, 2 current-3D, 2 2D-secondary,
      1 test-harness, 1 all-docs synthesis). All write ONE report, no code edits, no
      runner jobs. Session ids recorded in `SWARM_BOARD.md`.
- [x] Owner added directive: **deeply document donor decompilation findings**. Created
      `docs/coord_swarm_2026-11-25/decomp/` with `README.md` lane charter and dispatched
      8 more documentation micro-agents (DEC-01…DEC-08) covering binaries/RTTI, scripts,
      configs, anim/sound formats, terrain formats, map formats, cameras/shaders and
      UI/strings. Total live swarm: **22** agents. All DEC agents write one report only,
      with `path:offset` evidence and `observed`/`derived`/`inferred`/`UNVERIFIED` labels.
- [x] **Runner maintenance (COORD only):** job 311 from 2026-11-24 left a stale `godot.lock`
      (pid 2420 confirmed dead, no Godot processes alive). Ran variant `doctor` (0 orphans)
      and `unwedge`; the latter advanced 2000 empty tickets (side-effect: 2000 bogus
      `skipped` result JSONs, all deleted after verification). Restored `now_serving` to 312
      to match `next_ticket`. Final state: `now_serving=312`, `next_ticket=312`, `pending=0`,
      `godot.lock=free`, 311 real result files. The 2D runner/queue was never touched.
- [x] **4 of 22 reports landed and were integrated into `GAPS.md`:**
  - `V3D_01` — selection rectangle: functional path exists, **visual box never drawn**;
    untested; proposed smallest fix + 3-unit probe.
  - `V2D_01` — 2D logical selection features (secondary) confirm the box/ground-space
    design and the same test hole.
  - `V3D_02` — terrain: plumbing correct, 15 active causes ranked; 12 "already correct"
    items to protect; T0–T5 piece ladder on the existing 64² harness.
  - `DTRN_01` — donor terrain truth with 2 independent passes; discrete TileBlock +
    3-pass smoothing + alpha atlas, no normal map / foam / anisotropy / noise field.
- [x] **14 of 28 tickets have landed reports** (analysis: V3D-01/02, V2D-01/02, TEST-01,
      DOC-01, DSEL-01/02, DTRN-01/03/04, DEC-01/03/07; DTRN-03's final citation check also
      passed). All were integrated into `GAPS.md`, `TEST_MATRIX.md`, `PLAN_IMPLEMENTATION.md`.
- [x] **Two donor conflicts escalated to dedicated third/fourth passes:** `RV-SEL-01`
      (`.inc` live-string-literal vs commented source; 0.005 m threshold; yellow 1 px
      selection brush) and `RV-CAM-01` (FOV 17.27° vs 5.15°/30.22° vs runtime API). Both are
      RUNNING with follow-up context already delivered.
- [x] **Authoring phase started (Batch E):** 6 tiny new-file-only test atoms dispatched
      (harness helper, P0 terrain-only, P1 +trees, P2 +shore, P3 +mines, S1 selection).
      They do NOT run Godot and do NOT edit shared code. Execution remains gated and
      strictly sequential (P0→P1→P2→P3→C1→C2→C3→C4→S1→FINAL).
- [x] **All 10 test atoms + the shared harness are authored** (harness, P0–P3, C1–C4, S1).
      None has been run; all reports explicitly refuse PASS claims. `TEST_MATRIX.md` now has
      the sequential execution protocol (second-agent capture re-check, stop at first failure).
- [x] **CFG-01 delivered:** Russia vs Bavaria and fog-off were already defaults; changed
      interactive defaults to 240² (Tiny), `mediterranean`, `low_mountains`/hills. Gates green
      (selftest 29/29 ticket 312, uitest 17/17 ticket 313, CLEAN). `selftest.json` diff is
      runtime output only (all steps still `passed:true`), not a weakened test.
      CFG-02 dispatched for the menu-skipping `config.json` 320→240 tail.
- [x] **RV-CAM-01 finalized:** FOV CONFIRMED_UNVERIFIED; 17.27° is the correct 16:9 vertical
      FOV for a 216 mm horizontal sensor at f400 — DEC-07's "correction" was measuring H-FOV.
      Keep 17.27 as labelled PORT APPROX. DEC-07's `.inc` "commented" claim refuted.
- [x] **Donor decompilation lane CLOSED** (owner confirmed 2026-11-25): all 8 `DEC_0x_*.md`
      reports on disk (≈440 KB total). `decomp/README.md` marks them DONE and links
      `decomp/SUMMARY.md` — a consolidated record of findings, 14 prior-doc corrections,
      cross-lane re-verifications and ranked port implications. `EVIDENCE_INDEX.md` holds the
      evidence ids/offsets.
- [x] **SEL-01 landed and is green:** input_controller.gd now draws the donor-style yellow
      1 px marquee, uses the donor 0.005 m world epsilon (0.25 in attack/guard mode), Shift=add,
      and 0.5 s double-click; world ground rect retained per S-25-06. Gates: selftest 29/29
      (337), uitest 17/17 (318), and a 12/12 real-drag probe (329) covering selected ids
      `[10,11]`, building exclusion, short click `[10]`, Shift-add `[10,11,12]`, marquee shown
      during drag and hidden after. `t_select_rect.gd` parse errors (:399 untyped `via_helper`,
      :487 `Rect2.is_empty()` → `has_area()`) routed to ATOM-REPAIR.
- [x] **Batch H nearly complete:** SEL-01, CAM-01, CAM-02, TRN-SHADER, TRN-WATER, TRN-GEOM,
      DECOR-01, HUD-01 and INT-REGISTRY all landed with clean targeted smokes (`SCRIPT ERROR 0`).
      TRN-DATA is still running. Cross-owner handoffs were routed, never edited out of turn.
      Concrete leftovers filed: relief-grid stamping (DPATTERN-01 will supply data), exact vf/vs
      promotion, ground eye planes, mask-B shore gate, winter suffix, `sandrock*` orientation,
      donor double-click minimap jump, 4-edge minimap quad stroke, miner disc asset naming.
- [x] **Video QA protocol added** (`VIDEO_QA_PROTOCOL.md`) per owner directive: frame sequences /
      MP4 for motion cases, analysed by `opencode-go/muse-spark-1.3-contributor` at default
      variant (user: "#default will do fine"). VID-CAP-01 is capturing the first moving-unit
      sequence; muse-spark analysis follows when frames land.
- [ ] Await ATOM-REPAIR, TRN-DATA, MAP-SMALL-01, UITEST-ANCHOR, VID-CAP-01, Batch I deep dives
      and CAM-RV-01. Then restart the piece→combo ladder from P0, run S1, then the final gate once.
- [x] **Batch I (owner directive: keep agent count high):** 6 new read-only donor deep dives
      launched while implementations run — DALPHA-01 (tile→alpha sub-rect), DPATTERN-01
      (relief height grids), DFX-01 (PFX/particles), DANIM-01 (AAF per-unit clips), DBIND-01
      (packed `.bind`/WUS engine constants), DENV-01 (environment/season/weather). They target
      exactly the details the 8 DEC reports left UNVERIFIED; each writes one report and edits
      no code. Active swarm is now ~17 agents.

### 2026-11-25 — first ladder attempt stopped at P0 (evidence, not a rerun)
- `TEST-RUN-01` submitted job **321** (`TESTRUN01-P0`): `END failed`, exit 1, run 6.50 s,
  **no result JSON and no PNG**. `stderr.txt` has 4 `SCRIPT ERROR` lines: the embedded
  `LocalStubGame extends C3Game` fallback in `t_terrain_only.gd:97,98,101` redeclares
  `res_dirty`/`entities`/`res_nodes` already in the parent, and `:115` declares
  `resolve_mine_sid(Dictionary)` while C3Game requires `(String, Vector2) -> String`.
  GDScript parses the whole file at load, so no atom check ran.
- Per the protocol the ladder stopped; P1–C4 were NOT run, no assertion was weakened, and no
  rerun was submitted. `ATOM-REPAIR` now owns all 9 atom files for a minimal parse-load fix
  plus headless parse checks; the windowed ladder restarts after that.
- **Lesson recorded:** stub fallback classes must not `extends C3Game` and redeclare its fields;
  prefer the shared Node-based harness helper (`_smallmap_harness.gd`) which parses cleanly.

## Key synthesis so far (COORD, from landed reports — not yet re-verified at depth)

1. **Selection:** the named fault is provably the missing 3D rectangle draw
   (`world3d.gd:126-127` data-only). A second, unmeasured risk is geometric: the drag box is
   a ground-AABB of two screen-corner rays under a −32° perspective camera rather than a
   screen-space test. Donor truth still pending (`DSEL-01/02`, `DEC-07`). No automated test
   drives a real drag — the green gates never covered it.
2. **Terrain:** do not redo tile-index wiring, atlas manifest, mask channel repack, mesh,
   donor water equations, sun rig, shadow-OFF decision, shader compile fixes or camera
   seam fix. The highest-leverage remaining work is (a) world-ground texgen UVs,
   (b) real sun light consumption, (c) tile data diversity from donor transition rules,
   (d) alpha sub-rect + 25° face tilt, (e) water bands. All donor visual parity remains
   **UNVERIFIED** until a GPU A/B baseline exists.
3. **Do-not-do list from donor:** no normal map, no foam image, no synthetic luminance /
   dither grid, no anisotropy claim, no invented metres-per-cell or eye-plane values.

### Runner health observation (COORD, not an agent task)
- `python variant3d\tools\godot_runner.py status` at session start: spool correctly points at
  `variant3d\.godot_queue`; `now_serving=311`, `completed=311`, `pending=1 [311]`,
  `godot.lock HELD (age 54952.8s ≈ 15 h)`. This looks like a **stale lock from the prior
  session**, not an active job. No agent has been authorised to run Godot in Batch A, so
  no test jobs were submitted. Before Batch C, COORD will inspect the job record and, if
  confirmed stale, use the runner's `doctor` command (variant spool only) — never the 2D
  `doctor`, which kills Godot by name.

## Decisions (this session)

| id | Decision | Why |
|---|---|---|
| S-25-01 | Analysis phase is strictly read-only with one report file per worker | Prevents parallel code conflicts before we know the donor truth |
| S-25-02 | Donor evidence outranks 2D port evidence | Owner directive; 2D is secondary helper |
| S-25-03 | Each worker tests its own smallest piece before any combo/final test | `SWARM_OPS.md` §7.6 piece-before-whole |
| S-25-04 | Final whole-system test happens once, at the end of the day | Owner directive |
| S-25-05 | 14 tiny tickets first (swarm size), implementation split later by disjoint files | Owner directive "keep features and tests small" |
| S-25-06 | **Reject V3D-01's screen-space `select_in_rect()` proposal.** Donor (`DSEL_02`, 3 passes) defines the drag rect in **world ground coordinates** with a world-epsilon threshold; keep our world rect, replace the 6-px screen threshold, add Shift=add. | Donor is primary; V3D-01's suggestion was derived from the 2D analogue, which is secondary |
| S-25-07 | 3D selection fix must draw the missing marquee AND adopt donor world-space semantics; do not claim donor parity for FOV or ray internals | DSEL_02 claims 2/7/11, UNVERIFIED list |
| S-25-08 | Defaults change (CFG-01) scoped to `variant3d/` only; `app/**` stays untouched | Today's 3D focus; 2D gates must stay green |
| S-25-09 | No synthetic luminance/dither/noise field in any terrain fix | DTRN-01 M10 + DOC-01 failure register: re-creates the 2D checkerboard regression |
| S-25-10 | Piece→combo→final execution is strictly sequential (authoring can be parallel) | TEST-01: one Godot at a time, FIFO runner, stop at first failing row |
| S-25-11 | Authored `PLAN_IMPLEMENTATION.md`: one file per builder, gated on donor re-verification + piece captures | Owner directive: small features, large swarm, disjoint ownership |
| S-25-12 | **Batch H parallel implementation:** 8 disjoint builders edit simultaneously; each runs one targeted headless smoke check only; COORD runs the full gates ONCE after all merges | Owner asked for more agents/faster edits. Full 29/29+17/17 per builder would serialize 16 long jobs behind the FIFO runner and defeat parallelism; a single final gate still protects release quality. |
| S-25-13 | No relief-grid/`.pattern` stamping in TRN-GEOM; no morale/famine/market changes in TRN-DATA; no locale/pop-cap changes in HUD-01 | Keep each diff minimal and reviewable; those are future tranches |
| S-25-14 | CFG-02 240² change **reverted**: map size itself breaks 3 selftest steps. MAP-SMALL-01 may scale only `_spot()`'s search geometry, never a pass criterion | Evidence-based revert (26/29 at 240 vs 29/29 at 320); owner still wants the smaller default, so fix the harness geometry instead of gaming the seed/test |

## Gates status (snapshot — from prior docs, NOT re-measured this session)

| Gate | Prior result | This session |
|---|---|---|
| variant selftest (3d) | 29/29 (jobs 254, 241, 212) | not re-run yet |
| variant uitest | 17/17 (job 255) | not re-run yet |
| t_render_mode | PASS, seam_missing=false (job 256) | not re-run yet |
| 2D app gates | 29/29 / 17/17 / CLEAN | must remain untouched |
| Donor visual A/B | **UNVERIFIED** (prior docs) | target of this session's piece tests |
