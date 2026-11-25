---
id: FINAL-GATE-PLAN-01
title: "Exact ordered sequence to reach a truthful final whole-system gate"
area: coordination / testing
owner: FINAL-GATE-PLAN-01 (read-only planning worker; session ses_deddede23ffeu28mj7uzC2iIEH)
date: 2026-11-25
status: PLAN_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB
scope: "One new report file only. No .gd/.gdshader/config/test/fixture/git edit; no Godot runner submission; no donor access."
labels: [observed, derived, inferred, UNVERIFIED]
snapshot_caveat: "All statuses below are read from the CURRENT docs (plus two explicitly-labelled read-only live-file checks), not from a fresh runner poll. The queue is a moving target; ticket numbers, PIDs and pending lists are point-in-time only."
sources_read:
  - docs/coord_swarm_2026-11-25/TEST_MATRIX.md
  - docs/coord_swarm_2026-11-25/reports/TEST_RUN_01_ladder_log.md
  - docs/coord_swarm_2026-11-25/reports/TEST_RUN_02_ladder_log.md
  - docs/coord_swarm_2026-11-25/reports/P0_GATE_01.md
  - docs/coord_swarm_2026-11-25/reports/TERRAIN_DARK_01.md
  - docs/coord_swarm_2026-11-25/reports/LIGHT_02_light_space.md
  - docs/coord_swarm_2026-11-25/reports/QA_AUDIT_01_implementation_claims.md
  - docs/coord_swarm_2026-11-25/reports/CLEAN_01_variant_clean.md
  - docs/coord_swarm_2026-11-25/reports/CLEAN_02_variant_gate.md
  - docs/coord_swarm_2026-11-24/FINAL_GATE.md
  - docs/coord_swarm_2026-11-25/SWARM_BOARD.md
  - docs/coord_swarm_2026-11-25/PROGRESS.md
  - docs/variant3d/STATUS_WAVE7_PHASE2.md
  - docs/COMMANDS.md
---

# FINAL-GATE-PLAN-01 — ordered path to a truthful final gate

**Labels:** `observed` = literal doc/code fact read here; `derived` = arithmetic/control-flow
consequence of observed facts; `inferred` = plausible reading with caveat; `UNVERIFIED` =
cannot be proven from the read material (no donor GPU A/B, no fresh runner poll).

Citations are `path:line` in the workspace root. This document is a **plan only**; no
command in it was executed by this worker.

## Goal

Define the exact, ordered conditions under which COORD may run the **one** final
whole-system gate, so that the result is truthful rather than a transient green from a
busy queue or an isolated per-job artifact:

- ladder first, final gate last — owner rule "`test the smallest piece first; only test
  the final result at the end`" (`TEST_MATRIX.md:11`), decision S-25-04
  (`PROGRESS.md:171`) and S-25-12 ("COORD runs the full gates ONCE after all merges",
  `PROGRESS.md:179`);
- **one Godot at a time**, through the FIFO variant runner, Windows `python` (3.14),
  never `python3`, never direct `godot` (`TEST_MATRIX.md:70-72`;
  `TEST_RUN_02_ladder_log.md:46-49`);
- stop at the first failing row, attribute it, never weaken a test (`TEST_MATRIX.md:60-68`);
- donor visual parity remains UNVERIFIED throughout (`TEST_MATRIX.md:73-74`).

## Prerequisites (GATE conditions before any final command)

### P-1 — in-flight tickets that must land first (session ids from `SWARM_BOARD.md`)

| # | Ticket / session id | Board state (observed) | Why it blocks the gate | Landing condition (gate) |
|---|---|---|---|---|
| A | **MAP-SMALL-01** — `ses_dee1ffa4dffeNE1DyOlFaHFllL` | RUNNING (`SWARM_BOARD.md:66`) | Proximate cause of the integrated selftest being red: QA-AUDIT F-01 records HEAD `selftest.json` **26/29** (`wall`/`shell`/`farm_cap`) and worktree **28/29** (`build`), with `config.json` committed at 240² and no `MAP_SMALL_01_report.md` present (`QA_AUDIT_01_implementation_claims.md:47-57`; `PROGRESS.md:100-103`). `MAP_SMALL_01_report.md` is absent on disk (observed). | Report lands; **fresh integrated selftest 29/29** at both map sizes, with `_spot()` ring scaled and **no pass criterion changed** (S-25-14, `PROGRESS.md:181`). |
| B | **TERRAIN-DARK-FIX** — `ses_dedec4474ffee1ghS4x7WOLRug` | RUNNING (`SWARM_BOARD.md:186`); no `TERRAIN_DARK_FIX*.md` report on disk (observed) | Owns the genuine dark-terrain defect that stopped P0 (`TEST_RUN_02_ladder_log.md:202-229`; `P0_GATE_01.md:171-174`). Live read-only check: shader `:292-296` now uses the donor Y-up row-A formula (`normalize(vec3(P.x,P.y,P.z))`) with `/4,/2` dropped and `world3d_terrain.gd:138` `SUN_LIGHTVEC` aligned — labelled "TERRAIN-DARK-FIX2 / LIGHT-02" at `terrain_tileindex.gdshader:287-293` (**observed**, read this session); **but** no landed report and no fresh P0 gate job since that edit. | Report lands (or COORD records the landed code state); **fresh P0 windowed job** green under the strict gates `ground_mean_luma>=40` + `ground_max_luma>=100`, `SCRIPT ERROR == 0` (`P0_GATE_01.md:81-105,134-165`) before the ladder restarts. |
| C | **QA-PARITY-01** — `ses_dede47f21ffeN0cMxpshIcpAOZ` | RUNNING (`SWARM_BOARD.md:221`); `QA_PARITY_01.md` absent on disk (observed) | Re-verifies the integrated selftest/uitest/clean after all edits; its outcome is the evidence that isolated 29/29 jobs are no longer the only 29/29 (`QA_AUDIT_01_implementation_claims.md:47-57,111-112`). | Report lands and states the current integrated result; if it reports red, the named owner ticket must land and re-verify before the final gate. |
| D | **All other RUNNING code builders** (release files or get explicitly deferred by COORD): `CONFIG-UI-01` `ses_deedf5ff02ffeQ59UJJmvCiT7bF` (`SWARM_BOARD.md:184`), `CONFIG-WIRE-SEL` `ses_deded55fcffdeHoLLuv7C1Ha64` (`:188`), `ASSET-IMPORT-01` `ses_dede6d8deffe1OH2VxzryQlnyP` (`:192`), `MOTION-ANIM-01` `ses_dedf02a91ffe4WC7rm8cJUkFU7` (`:117`), `MINIMAP-QUAD-01` `ses_dedf02a90ffdT7nAiMWDUbpMQj` (`:120`), `SP-1` `ses_dedfd74ffffeHTsJ5EnxBF077b` (`:169`), `SP-4` `ses_dedf28b67ffekBGYYokxLXUXeD` (`:174`), `SP-6` `ses_dedf28b63ffeWAnI54lgoZm6sz` (`:175`), `AUDIO-SEL-02` `ses_dede47f36ffeaGALXfX3VRRfEG` (`:217`), `CONFIG-WIRE-RELIEF` `ses_dede47f35ffeJtm9VwqT6yGQNB` (`:218`), `WEATHER-DRIVER-01` `ses_dede47f33ffejvS2MRfuAE33S6` (`:219`), `MAPSIZE-01` `ses_dede3a392ffe6P3B6Ttaon7o44` (`:224`), `DEFAULTS-VERIFY-01` `ses_dede3a38effe0Qb4qFvKwoJxy3` (`:225`), `CONFIG-COUNT-01` `ses_deddede2dffelwKbQHsVHAMSe2` (`:226`), `PERF-3D-01` `ses_deddede28ffePAlAptFGEy4kzn` (`:228`) | RUNNING (same lines) | They own files in the integrated tree (`config.gd`, `menu.gd`, `input_controller.gd`, `world3d_fx.gd`, `hud3d_adapter.gd`, `data.gd`, atlas build, `world3d_terrain.gd`, `audio.gd`, `main.gd`, etc.); a post-gate edit invalidates the gate. Owner runtime errors specifically point at `hud3d_adapter.gd:172-173` and the missing `mill_rotor.png` `.ctex` (`PROGRESS.md:104-115`). | No in-flight edit may touch any file under test after the ladder starts; `ASSET-IMPORT-01` must clear the `.ctex` error (it already made TRN-DATA job 411 fail at `build`, 28/29 — `SWARM_BOARD.md:111`; `TRN_DATA_implementation.md:77`). |

**Note on stale board state (observed/derived):** `LIGHT-02` is marked RUNNING at
`SWARM_BOARD.md:187`, but its report is delivered `DONE` with a full verdict
(`LIGHT_02_light_space.md:1-15,212-246`). Treat the report, not the board cell, as the
evidence. Conversely `TERRAIN-DARK-FIX` has landed *code* but no report and no fresh
gate job — this asymmetry is the reason condition B is not yet satisfied.

### P-2 — jobs that must be green (evidence base)

| Job / result | Current evidence | Verdict |
|---|---|---|
| Per-ticket smokes (SEL-01 337/318/329; CAM-01 339; CAM-02 356; CAM-RV-01 381 20/20; TRN-SHADER 342; TRN-WATER 343; TRN-GEOM 361; DECOR-01 358; HUD-01 340/349/357; UITEST-ANCHOR 366 17/17; ATOM-REPAIR 364-375 parse-only; HARNESS-01 384 SE0; RELIEF-01 402; RELIEF-02 415; MMJUMP-02 413/416/417; FX-IMPACT-01 428/434; FX-WEATHER-01 405; S1-INPUT-FIX 414 23/23; CONFIG-CORE-01 419; CONFIG-WIRE-WATER 433; CONFIG-WIRE-HUD 432/440; CONFIG-WIRE-CAM 429) | `QA_AUDIT_01_implementation_claims.md:29-43,128-131`; `SWARM_BOARD.md:87,108-125,145-148,185-191`; `S1_INPUT_FIX.md:153-162` | GREEN individually (**observed** in docs), but **not sufficient**: QA-AUDIT F-01 shows the integrated state is not green (`QA_AUDIT_01_implementation_claims.md:47-57`). |
| TRN-DATA selftest 411 | 28/29, `build` failed on missing `.ctex` (`SWARM_BOARD.md:111`; `TRN_DATA_implementation.md:77`) | NOT GREEN — must be cleared by P-1/D (ASSET-IMPORT-01) before final selftest. |
| Integrated `variant3d/selftest.json` | HEAD 26/29, worktree 28/29 (`QA_AUDIT_01_implementation_claims.md:47-57`); `PROGRESS.md:188` claims 29/29 repeatedly — **conflict**, the QA-AUDIT measurement is later and more specific (derived) | NOT GREEN — final gate must regenerate it fresh, not reuse job 312/337 artifacts. |
| Integrated `variant3d/uitest.json` | 17/17 at jobs 313/318/366/440 (`QA_AUDIT_01_implementation_claims.md:31,39`; `PROGRESS.md:189`; `CONFIG_WIRE_HUD.md:101`) | GREEN in those artifacts; must be re-proved by the final job. |
| 2D `app/**` gates | "untouched; must remain green" (`PROGRESS.md:191`); `TEST_MATRIX.md:66` | UNVERIFIED in the current tree (not re-run by this plan); do not edit `app/**` (S-25-08, `PROGRESS.md:175`). |

### P-3 — required queue / environment state (all must hold at gate time)

| Condition | Evidence / how to verify |
|---|---|
| `python variant3d\tools\godot_runner.py status` → `pending = 0`, no held lock, bounded max wait | `FINAL_GATE.md:17` (2D pattern), `STATUS_WAVE7_PHASE2.md:246,255`, `CLEAN_GATE.md:100-103` as cited at `CLEAN_02_variant_gate.md:19-22`. |
| Zero live Godot processes; `assert_clean.py --json` returns `clean: true`, `verdict: CLEAN`, exit 0 on the **variant** spool | `CLEAN_01_variant_clean.md:260-283`; `CLEAN_02_variant_gate.md:125-131`. The tool is now spool-aware (`CLEAN_02_variant_gate.md:43-62`, line 34 `SPOOL = ROOT / "variant3d" / ".godot_queue"`), and correctly reports **DIRTY while a job is active** (`CLEAN_02_variant_gate.md:64-123`); this is swarm churn, not a failure. |
| No unacked failure-status (`timed-out`/`error`/`skipped`) jobs on the variant spool; 22 gate-relevant timed-out jobs acked | `CLEAN_01_variant_clean.md:188-191,242-258`; `CLEAN_02_variant_gate.md:113-117`. Tickets 296/300 remain unacked `failed`, excluded by D-13 (`CLEAN_01_variant_clean.md:287-293`). |
| Ladder already complete and green, each row re-checked by a second agent | `TEST_MATRIX.md:57-59,75`. |
| Windows `python` (3.14); repo-root-relative paths; no direct `godot` invocation | `TEST_MATRIX.md:71-72`; `TEST_RUN_01_ladder_log.md:41-47`. |

## Execution sequence (ordered; do not reorder or parallelise rows)

### Step 1 — satisfy P-1/P-2/P-3
Read the landed reports for MAP-SMALL-01, TERRAIN-DARK-FIX, QA-PARITY-01; confirm a fresh
P0 gate job is green; confirm no RUNNING builder still owns a file under test. Poll the
queue with `status` only (read-only). If anything is still in flight, wait — do not
submit a ladder row into churn (`TEST_MATRIX.md:53-56`; `CLEAN_02_variant_gate.md:127-131`).

### Step 2 — piece→combo ladder, strictly sequential

Row order (observed): `P0 → P1 → P2 → P3 → C1 → C2 → C3 → C4 → S1 → FINAL`
(`TEST_MATRIX.md:57`; `TEST_RUN_02_ladder_log.md:12`). Submit the next row **only after**
the previous result JSON exists and its PNG/stderr were re-checked by a **second agent**;
the owner never self-certifies visual review (`TEST_MATRIX.md:58,75`).

| Row | Atom (`res://tests/<atom>.gd`) | Capture / gate (from the matrix) |
|---|---|---|
| P0 | `t_terrain_only.gd` | `<smallmap>_terrain_only.png`; donor ground colour/placement, no checkerboard/seams, correct height (`TEST_MATRIX.md:18`); strict `ground_mean_luma>=40` + `ground_max_luma>=100`, `full_width_dark_rows` recorded N/A (`P0_GATE_01.md:74-90`). |
| P1 | `t_terrain_trees.gd` | `<smallmap>_terrain_trees.png`; tree density/scale, ground visible (`TEST_MATRIX.md:19`); tree Y vs `height_at_world()`, draw calls/frame time (`TEST_MATRIX.md:41`). |
| P2 | `t_terrain_shore.gd` | `<smallmap>_terrain_shore.png`; shore mask width, sand/rock, shallow/deep colour (`TEST_MATRIX.md:20`); exactly one height-aware water plane, **dark rows = 0**, two-frame animation (`TEST_MATRIX.md:42`). |
| P3 | `t_terrain_mines.gd` | `<smallmap>_terrain_mines.png`; mine asset/scale/jitter/placement (`TEST_MATRIX.md:21`), sid + Y + ground A/B (`TEST_MATRIX.md:43`). |
| C1 | `t_combo_trees_shore.gd` | PNG; no interaction regressions (`TEST_MATRIX.md:22`). |
| C2 | `t_combo_trees_mines.gd` | PNG; no overlap/placement bugs (`TEST_MATRIX.md:23`). |
| C3 | `t_combo_shore_mines.gd` | PNG; mines not in water, shore masking correct (`TEST_MATRIX.md:24`). |
| C4 | `t_combo_all.gd` | PNG; all criteria together, layers toggleable, no stacked water planes (`TEST_MATRIX.md:25,44`). |
| S1 | `t_select_rect.gd` | Real 64² boot + main's `--screenshot` path, HUD re-shown by the atom (`TEST_MATRIX.md:26,64`); expected selected ids `[10,11]`, no click-pick regression; 23/23 atom green at job 414 (`S1_INPUT_FIX.md:153-162,164-190`). |

Runner launch form (observed, `TEST_MATRIX.md:71`; `TEST_RUN_02_ladder_log.md:49`):

```
python variant3d\tools\godot_runner.py run --id <ticket>-<row> --timeout <s> -- --path variant3d --script res://tests/<atom>.gd -- <user args>
```

Rules for every row (**derived/observed** from `TEST_MATRIX.md:62-64,70-75`):
- **windowed** — no `--headless`; PNG path passed as a user arg after the second `--`.
  Headless runs produce `SKIP_CAPTURE` / `passed=false` and are **not** PASS.
- P0's proven launch shape (`TEST_RUN_02_ladder_log.md:67`, reused by
  `P0_GATE_01.md:130-132`):
  ```
  python variant3d\tools\godot_runner.py run --id <unique-id> --timeout 180 -- --path variant3d --script res://tests/t_terrain_only.gd -- --screenshot "<TEMP>/smallmap64_terrain_only.png" --png "<TEMP>/smallmap64_terrain_only.png"
  ```
- S1's proven launch shape (`S1_INPUT_FIX.md:146-151`, job 414):
  ```
  python variant3d\tools\godot_runner.py run --id <unique-id> --timeout 300 -- --path variant3d --script res://tests/t_select_rect.gd -- --config <ABS>\variant3d\tests\fixtures\small_map_64.json --screenshot <TEMP>\s1inputfix_smallmap64.png
  ```
- Per-row extra args are owned by each atom's report (e.g. P1's `--p0-png` baseline was
  noted at `TEST_RUN_02_ladder_log.md:239`; C4's per-layer toggles at
  `SWARM_BOARD.md:81`). Do not invent flags.
- After each row: read the atom result JSON (`variant3d/tests/results/<atom>.json`),
  re-run `python variant3d\tools\smallmap_capture.py stats <PNG>` and `scan-stderr <job stderr>`
  exactly as in `TEST_RUN_02_ladder_log.md:112-161`; require `SCRIPT ERROR == 0`
  (`TEST_RUN_02_ladder_log.md:163`) and a **second-agent** capture re-check
  (`TEST_MATRIX.md:58,75`). The same fixed 64² harness, seed 20261113, fixed camera,
  1280×720, capture after ~10 frames is reused — do not build a new harness
  (`TEST_MATRIX.md:29-36`). 2D `app/` tooling (`t_shore_smoke.gd`, `t_water.gd`,
  `visual_tuning_test.gd`, `terrain_piece_render.py`, `tools/pieces/t6_*`) is not a 3D gate
  (`TEST_MATRIX.md:48-51`).

### Step 3 — FINAL, only after every ladder row is green

Exact commands, **variant runner only** (observed from
`STATUS_WAVE7_PHASE2.md:245-249`; corroborated by `TEST_01_smallmap_harness.md:221`,
`TEST_MATRIX.md:65-66`):

```
python variant3d\tools\godot_runner.py status
python variant3d\tools\godot_runner.py run --id coord-final-selftest --timeout 300 -- --headless --path variant3d -- --self-test variant3d/selftest.json
python variant3d\tools\godot_runner.py run --id coord-final-uitest --timeout 240 -- --headless --path variant3d -- --ui-test variant3d/uitest.json
python variant3d\tools\assert_clean.py --json
```

Acceptance (all required, none optional):
- `variant3d/selftest.json` `"passed": true`, **29/29** (`STATUS_WAVE7_PHASE2.md:253`;
  `TEST_MATRIX.md:27`). Per-job 29/29 from jobs 312/337 is **not** enough
  (`QA_AUDIT_01_implementation_claims.md:47-57`).
- `variant3d/uitest.json` `"passed": true`, **17/17** (`STATUS_WAVE7_PHASE2.md:254`).
- `assert_clean.py --json` → `CLEAN`, exit 0: 0 Godot processes, free lock, no unacked
  failure-status jobs (`STATUS_WAVE7_PHASE2.md:255`; `CLEAN_01_variant_clean.md:281-283`).
  A `DIRTY` result while jobs are active is expected and must not be signed
  (`CLEAN_02_variant_gate.md:117-131`).
- `godot_runner.py status` → `pending = 0`, bounded max wait (`FINAL_GATE.md:17`).
- 2D `app/**` gates remain untouched and green (`TEST_MATRIX.md:66`; `PROGRESS.md:191`).
- **Owner visual review** and donor A/B are still a separate, UNVERIFIED caveat
  (`TEST_MATRIX.md:73-74`); a green gate does not claim donor parity.

`docs/coord_swarm_2026-11-24/FINAL_GATE.md:1-17` is the **2D `app/`** gate pattern
(`app\tools\godot_runner.py`, `app/selftest.json`, `app/uitest.json`): use it as the
acceptance template, not as commands to submit for the 3D final gate. Its commands are
out of scope for "variant runner only" and must not overwrite the 3D reports.

## Failure policy

1. **Stop at the first failing row.** The failing row is evidence, not a nuisance. Record
   the exact failed assertion and route it to the owning fix ticket by `SWARM_BOARD.md`
   ownership. Do not submit the next row (`TEST_MATRIX.md:60-61`;
   `TEST_RUN_01_ladder_log.md:71-75`; `TEST_RUN_02_ladder_log.md:195-200,311-312`).
2. **Never rerun hoping for green.** Both ladder attempts stopped at P0 without a rerun
   (`TEST_RUN_01_ladder_log.md:73-75`; `TEST_RUN_02_ladder_log.md:55-56,249`). A rerun is
   allowed only after the owning builder lands an actual fix and COORD re-opens the row.
3. **Never weaken a test.** `expected_pre_fix_failure` markers stay until their fix lands
   (`TEST_MATRIX.md:67-68`); no threshold lowered, no assertion deleted
   (`P0_GATE_01.md:176-186`; `S1_INPUT_FIX.md:193-206`). If a predicate is genuinely
   inapplicable (P0's water-band detector on a water-free frame), replace it with an
   **equally strict or stricter applicable** gate in an evidence-backed ticket, keeping
   the old value recorded — the P0 precedent (`P0_GATE_01.md:31-105`) — never silently
   drop it. Attribute the defect to its owning file: P0's darkness was attributed to the
   terrain shader's donor-sun conversion (`TERRAIN_DARK_01.md:182-197`;
   `LIGHT_02_light_space.md:239-246`), not to camera framing, atlas or mask
   (`TERRAIN_DARK_01.md:130-143`).
4. **No fake PASS from headless.** Headless = `SKIP_CAPTURE` / `passed=false`
   (`TEST_MATRIX.md:63`; `S1_INPUT_FIX.md:43-76`). `SCRIPT ERROR == 0` is a hard
   prerequisite for any row verdict (`TEST_RUN_02_ladder_log.md:163,305-306`).
5. **Second-agent capture re-check** before any row is called PASS; the owner never
   self-certifies visual review (`TEST_MATRIX.md:58,75`; `TEST_RUN_02_ladder_log.md:231-233`;
   `S1_INPUT_FIX.md:222-224` notes S1 asserts no PNG, so the JSON/stdout are the
   re-check surface unless a capture is added).
6. **Do not run FINAL early.** It is reserved for COORD and last
   (`SWARM_BOARD.md:99`; `TEST_MATRIX.md:27`; `PROGRESS.md:171,179`).
7. **Owner visual review / donor A/B caveat (UNVERIFIED).** Metrics never override a
   donor visual comparison (`TEST_MATRIX.md:73-74`); no donor GPU A/B frame exists
   (`TERRAIN_DARK_01.md:14,238`; `LIGHT_02_light_space.md:13,277-289`;
   `P0_GATE_01.md:13,190-192`; `QA_AUDIT_01_implementation_claims.md:118`).
   Every capture is labelled `PORT APPROX — internal consistency only`
   (`TEST_RUN_02_ladder_log.md:99`). The final gate is a truthful *system* gate, **not**
   a donor-parity certificate.

## Current status (from CURRENT docs — snapshot caveat above)

| Item | Status in docs | Evidence |
|---|---|---|
| TEST-RUN-01 ladder | STOPPED at P0, parse errors, no JSON/PNG | `TEST_RUN_01_ladder_log.md:6,53,71-95` |
| TEST-RUN-02 ladder | STOPPED at P0, `verdict=FAIL`, `full_width_dark_rows=720`, `SCRIPT ERROR == 0` | `TEST_RUN_02_ladder_log.md:6,62,100-102,202-229` |
| P0 gate instrument | Strict `ground_mean_luma>=40`/`ground_max_luma>=100`; job 421 exit 1 as expected; dark-row recorded N/A | `P0_GATE_01.md:6,81-105,134-174` |
| P0 dark-terrain fix | Code observed landed (row-A formula + aligned `SUN_LIGHTVEC`); report absent; **no fresh P0 gate job** | read-only `terrain_tileindex.gdshader:287-296`, `world3d_terrain.gd:138` (**observed**); `SWARM_BOARD.md:186`; `LIGHT_02_light_space.md:239-246` |
| P1–C4 rows | Never executed; run-time state UNVERIFIED | `TEST_RUN_02_ladder_log.md:137-143,291-293` |
| S1 atom | 23/23 green, job 414, `SCRIPT ERROR 0` (atom-level); ladder row not yet re-run | `S1_INPUT_FIX.md:6,12,156,164-176,236-238` |
| Integrated selftest | NOT green: HEAD 26/29, worktree 28/29 (`build`); QA-PARITY-01 re-verifying | `QA_AUDIT_01_implementation_claims.md:47-57`; `SWARM_BOARD.md:221`; (conflicting older claim `PROGRESS.md:188`) |
| Integrated uitest | 17/17 in cited artifacts; final job not run | `QA_AUDIT_01_implementation_claims.md:31,39`; `PROGRESS.md:189` |
| Variant CLEAN | History signal clean (0 unacked failure-status); formal signing DEFERRED; tool now variant-aware but DIRTY during churn | `CLEAN_01_variant_clean.md:260-283`; `CLEAN_02_variant_gate.md:125-131` |
| 2D `app/**` gates | Untouched, must remain green; not re-run here → UNVERIFIED | `PROGRESS.md:191`; `TEST_MATRIX.md:66` |
| Donor visual A/B | UNVERIFIED — no donor GPU frame | `TEST_MATRIX.md:73-74`; `PROGRESS.md:192` |
| CAM-RV-01 | 20/20 confirmed (contract anchor, must stay intact) | `SWARM_BOARD.md:124`; `QA_AUDIT_01_implementation_claims.md:33` |

## Open questions

1. **P0 re-run outcome (UNVERIFIED):** will the landed shader fix clear the strict
   `ground_mean_luma>=40` / `ground_max_luma>=100` gates? The pre-fix frame was 13.271 /
   27.413 (`P0_GATE_01.md:141-142`); residual luma factor still UNVERIFIED
   (`TERRAIN_DARK_01.md:123-128`, `LIGHT_02_light_space.md:287-289`).
2. **Row A vs row C donor fidelity (UNVERIFIED):** LIGHT-02 prefers raw `P` (dot 0.938701)
   over `/4,/2` (0.995812); live code now uses row A, but no donor GPU A/B exists
   (`LIGHT_02_light_space.md:179-210,239-246,284-286`).
3. **Inapplicable dark-row gates in sibling atoms (inferred, not observed):** P1
   (`t_terrain_trees.gd:694-695`), C2 (`t_combo_trees_mines.gd:850-851`), C3
   (`t_combo_shore_mines.gd:803-804`), C4 (`t_combo_all.gd:995`) still hard-assert
   `full_width_dark_rows == 0`; P0_GATE_01's record-only treatment applies to P0 only
   (`P0_GATE_01.md:206-208`). If a water-free row fails for this reason, open a separate
   evidence-backed ticket; do not relax it here. P2/C1/C3/C4 with shore have an
   applicable water-band gate per V3D_02 (`TEST_MATRIX.md:42-44`).
4. **QA-AUDIT F-01 vs PROGRESS gate table (observed conflict):** `PROGRESS.md:188` says
   "29/29 repeatedly"; `QA_AUDIT_01_implementation_claims.md:47-57` measured the integrated
   state red. The final job, not either table, decides.
5. **2D gates:** will `app/**` still be green after the swarm's edits? Not audited here
   (`QA_AUDIT_01_implementation_claims.md:118`; `PROGRESS.md:191`).
6. **Queue state** (PIDs, tickets, lock age) is a moving target; every number cited is a
   snapshot only (`CLEAN_02_variant_gate.md:141-143`; `TEST_RUN_02_ladder_log.md:251-268`).
7. **S1 capture re-check surface:** the atom asserts no PNG (`S1_INPUT_FIX.md:222-224`);
   COORD should decide whether a second-agent visual capture is required before the S1
   row is called PASS.
8. **Season tickets SP-1/SP-4/SP-6** are RUNNING (`SWARM_BOARD.md:169,174-175`); a late
   atlas/manifest hook change could invalidate capture parity and must be landed or
   deferred before the ladder (cf. LFS fallback trap `SWARM_BOARD.md:230`).

## Summary

- The truthful final gate is **earned, not scheduled**: first land MAP-SMALL-01
  (`ses_dee1ffa4dffeNE1DyOlFaHFllL`), TERRAIN-DARK-FIX (`ses_dedec4474ffee1ghS4x7WOLRug`)
  and QA-PARITY-01 (`ses_dede47f21ffeN0cMxpshIcpAOZ`), release every other RUNNING builder's
  files, and prove a quiet queue (P-1/P-2/P-3).
- Then execute the ladder **P0→P1→P2→P3→C1→C2→C3→C4→S1** windowed, one job at a time,
  with second-agent capture re-check, stopping at the first failure and attributing it to
  the owning file (`TEST_MATRIX.md:53-75`).
- Only then run the four variant-runner commands in Step 3 and accept only fresh
  `29/29` + `17/17` + `CLEAN`/exit 0 + `pending=0`.
- Never weaken a test, never rerun a failure hoping for green, and keep donor visual
  parity / owner visual review explicitly UNVERIFIED. This document is a plan; no test was
  run and no source file was changed.

---

*End of FINAL-GATE-PLAN-01. Read-only plan; no Godot job, no code edit, no donor access.*
