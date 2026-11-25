---
id: QA-ATOM-RESULTS-01
title: "Read-only QA audit — test-atom result JSONs, manifest entries, staleness and PASS claims"
owner: QA-ATOM-RESULTS-01 (read-only worker)
date: 2026-11-25
status: DONE__REPORT_ONLY__NO_CODE_EDITS__NO_RUNNER_JOBS
scope: "Read-only audit of variant3d/tests/results/*.json, variant3d/tests/manifest.json, the 13 authored atom/fixture files, SWARM_BOARD.md and the atoms' own reports. One read-only command executed: python variant3d\\tools\\test_all.py --list. No Godot runner job submitted; no source/config/test/report other than this file edited."
owns:
  - "docs/coord_swarm_2026-11-25/reports/QA_ATOM_RESULTS_01.md"
labels: [QA, RESULT_JSON, MANIFEST, STALENESS, FALSE_GREEN, READ_ONLY]
evidence_labels: [observed, derived, inferred, UNVERIFIED]
sources_verified_twice: true
---

# QA-ATOM-RESULTS-01 — atom result JSON / manifest audit

## 0. Sources (all read-only)

| Source | Use |
|---|---|
| `variant3d/tests/results/*.json` (65 files; 10 relevant) | `passed`, `verdict`, `capture_status`, check counts, `unix_ms`, measured capture state |
| `variant3d/tests/manifest.json` (`result_dir` at line 4; 40 entries) | id/path/status cross-check |
| `variant3d/tools/test_all.py:28-31,42-51,71,76,90-100` | variant roots, result dir, runner, `--list` |
| `python variant3d\tools\test_all.py --list` (read-only, exit 0) | 40 entries, 30 `ready` / 10 `pending`, no `app/**` access |
| `docs/coord_swarm_2026-11-25/SWARM_BOARD.md` (lines 72-81, 95-98, 115, 124, 148, 154-155, 173, 193, 249) | atom/ticket/PASS claims |
| `docs/coord_swarm_2026-11-25/TEST_MATRIX.md:16-27,53-75` | ladder rules, headless ≠ PASS, second-agent rule |
| Atom authoring reports `TEST_{HARNESS,P0,P1,P2,P3,C1,C2,C3,C4,S1}_report.md`, `CAM_RV_01_view_rect_runtime.md`, `VID_CAP_01_capture.md`, `SP_08_season_test.md` | own claims and runner-job records |
| `reports/ATOM_REPAIR_report.md:65-79`, `HARNESS_01_cast_fix.md`, `P0_GATE_01.md`, `TERRAIN_DARK_FIX.md:13-15,140-148`, `S1_INPUT_FIX.md`, `TEST_RUN_{01,02}_ladder_log.md` | job/ticket provenance for the result JSONs |
| `variant3d/.godot_queue/results/00000381_camrv01-smoke3/stdout.txt` (`CAMRV01_JSON:` line), `00000381.json`, `00000408.json` | stdout-only PASS evidence for `t_view_rect_rv` |
| `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\vidqa\frames.json` | independent distinct-frame recount |
| `CAPTURE_RECHECK.md:30-57,89-110` | second-agent protocol scope |
| File `LastWriteTime` (ms) of each atom and result JSON | staleness comparison |

**Label key (applied per finding):** **observed** = read directly from a file/command output; **derived** = computed from observed values; **inferred** = reasoned consequence, not directly stated; **UNVERIFIED** = cannot be established from available evidence.

## 1. Atoms authored today — per-atom table

13 authored units: shared harness + P0–P3 + C1–C4 + S1 + `view_rect_rv` + `motion_capture` + `season_overlay`.
Check columns are **observed** counts of `checks[].passed == true / false / null`; `passes`/`fails` are the JSON's own fields where present. All timestamps are local (2026-11-25).

| Atom / source file | Result JSON | `passed` | `verdict` / `capture_status` (or `status`) | Checks T/F/null; `passes`/`fails` | Job / ticket recorded | `expected_pre_fix_failure` in source | Manifest id/path/status | Atom last edit vs JSON |
|---|---|---|---|---|---|---|---|---|
| **harness** `fixtures/_smallmap_harness.gd` | none (fixture, not a test) — expected (**observed**) | n/a | n/a | n/a | smoke 384 `harness01-smoke` (`HARNESS_01_cast_fix.md:72`) | 0 | **absent** (deliberately unregistered; `SWARM_BOARD.md:193`) | 10:07:28; no JSON to compare |
| **P0** `t_terrain_only.gd` | yes | **true** | `PASS` / `PASS` | 22/0/1 (1 `RECORDED_NOT_APPLICABLE`); 22/0 | **441** `terraindarkfix-p0` windowed (`TERRAIN_DARK_FIX.md:15`) | 0 | present, `res://tests/t_terrain_only.gd`, **pending** | 10:33:57 < 10:52:13 → **fresh** |
| **P1** `t_terrain_trees.gd` | yes | false | `FAIL` / `SKIP_CAPTURE` | 21/1/10; 21/1 | 365 `atomrepair-final-terrain_trees` headless; 384 smoke | 0 | present, **pending** | 11:05:08 > 10:08:38 → **STALE** |
| **P2** `t_terrain_shore.gd` | yes | false | `UNVERIFIED`; no `capture_status` field | 16/10/0; 16/10 (3 `EXPECTED_PRE_FIX_FAILURE`, 7 headless `UNVERIFIED`) | 367 `atomrepair-final-terrain_shore` headless | **6** (`:199,227,236` logic + `:858,924,936` call sites) | present, **pending** | 11:06:28 > 10:00:45 → **STALE** |
| **P3** `t_terrain_mines.gd` | yes | **true** ⚠ | no `verdict`; `status=HEADLESS_STRUCTURAL_ONLY__PNG_UNVERIFIED` | 13/0/0; 13 passes, no `fails` field | 368 `atomrepair-final-terrain_mines` headless | 0 | present, **pending** | 11:06:57 > 10:00:59 → **STALE** |
| **C1** `t_combo_trees_shore.gd` | yes | false | `FAIL` / `SKIP_CAPTURE` | 22/2/4; 22/2 | 369 `atomrepair-final-combo_trees_shore` headless | 0 | present, **pending** | 11:08:06 > 10:01:16 → **STALE** |
| **C2** `t_combo_trees_mines.gd` | yes | false | `FAIL` / `SKIP_CAPTURE` | 25/3/0; 25/3 | 370 `atomrepair-final-combo_trees_mines` headless | 0 | present, **pending** | 11:13:01 > 10:01:35 → **STALE** |
| **C3** `t_combo_shore_mines.gd` | yes | false | `SKIP_CAPTURE` / `SKIP_CAPTURE` (12/12 checks pass; gate is the capture) | 12/0/0; 12 passes, no `fails` field | 372 `atomrepair-final-combo_shore_mines` headless | 0 | present, **pending** | 11:10:03 > 10:02:43 → **STALE** |
| **C4** `t_combo_all.gd` | yes | false | no `verdict`; `status=SKIPPED_HEADLESS` | 0/1/0; 0 passes, `total=1` | 374 `atomrepair-final-combo_all` headless | 0 | present, **pending** | 11:11:11 > 10:03:15 → **STALE** |
| **S1** `t_select_rect.gd` | yes | **true** | no `verdict`; `run_mode=windowed_real_input` (no PNG assertion) | 23/0/0; 23/23 | 375 parse check (FAIL 0/1) → **414 `s1inputfix-run` windowed PASS** (`runner_declaration` in JSON; board line 148) | 2 flagged rows (`overlay_rect_during_drag`, `overlay_hidden_after_release`); source passes `true` via `_assert_overlay` at `:539`, called `:611-612` | present, **pending** | 10:27:33 < 10:46:01 → **fresh** |
| **view_rect_rv** `t_view_rect_rv.gd` | **MISSING** in results dir | PASS claimed 20/20 (stdout JSON `passed:true`) | `CAMRV01_RESULT: PASS 20/20` | stdout JSON: 20 true / 0 false | 373 headless, 378, **381 `camrv01-smoke3` windowed** | 0 | **absent** | source 10:06:04; no JSON to compare |
| **motion_capture** `t_motion_capture.gd` | yes | **true** | no `verdict`; `status=CAPTURE_OK` | 10/0/0; 10/10 | **408 `vidcap01-frames`** windowed (failed 380/383/386/388/391/394/401 retained) | 0 | **absent** | 10:22:47 < 10:26:29 → **fresh** |
| **season_overlay** `t_season_overlay.gd` | **MISSING** (expected: `PENDING_DEP`, authoring only — `SP_08_season_test.md`) | n/a | `PENDING_DEP` in report | n/a | none | 0 | **absent** | source 11:06:50; no JSON to compare |

**Counts, verified twice** (**derived** from file parses and from a second independent pass): 13 authored units; 10 result JSONs present; 3 missing (1 by design: harness; 2 atoms: `view_rect_rv`, `season_overlay`); 4 JSONs with `passed:true` (P0, P3, S1, motion_capture); 6 with `passed:false`; 9 manifest entries present / 4 absent; 7 stale results; 1 `passed:true` from a headless skip row.

## 2. Registry check (**observed**, read-only)

* `manifest.json:4` → `"result_dir": "variant3d/tests/results"` — points at the variant spool, not `app/tests/results`.
* `test_all.py:28-31` → `ROOT = parents[2]` (repo root), `MANIFEST = ROOT/variant3d/tests/manifest.json`, `RESULTS = ROOT/variant3d/tests/results`, `RUNNER = ROOT/variant3d/tools/godot_runner.py`; `:45` passes `--path variant3d`; no `app/` path in the execution route (`:8-9` documents the variant copy explicitly).
* `python variant3d\tools\test_all.py --list` → exit 0, **40 entries** (30 `ready`, 10 `pending`), including all 9 ladder atoms. No 2D access; no runner job was started.
* Manifest id/path match for all 9 registered ladder atoms (**observed**). Status is uniformly `pending`; it has not been advanced for P0 (`verdict=PASS`, job 441) or S1 (`passed=true`, job 414) even though their result JSONs are green (**observed**, status-semantics mismatch).
* Not registered: harness (by design), `t_view_rect_rv`, `t_motion_capture`, `t_season_overlay` (three new atoms with no manifest row; `t_motion_capture` has a green `CAPTURE_OK` JSON). **Inferred:** registry is additive-only and lags the post-ladder atoms.
* Corroboration: `SWARM_BOARD.md:193` records INT-REGISTRY's 31→40 expansion and `CLEAN-02` fixing `assert_clean.py:34` to the variant spool.

## 3. Ranked findings (no fixes applied)

### HIGH — H1. False green: P3 `passed:true` is produced by headless skip rows
- **Observed:** `t_terrain_mines.json` has `passed:true`, `passes:13`, `total:13`, but `headless:true`, `status=HEADLESS_STRUCTURAL_ONLY__PNG_UNVERIFIED`, `png.written=false`, `png.size=[0,0]`. Three checks have `passed:true` while carrying non-PASS statuses: `png_capture_windowed` = `HEADLESS_SKIP__PNG_UNVERIFIED`, `ground_luma_variance_outside_mine_bbox` = `UNVERIFIED`, `no_z_fighting_seam_visual` = `UNVERIFIED__VISUAL_REVIEW_REQUIRED`.
- **Observed:** `t_terrain_mines.gd:885-892` literally calls `check(..., true, "headless guard: ...", "<non-PASS status>")`, so the guard rows inflate `passes` and `passed`.
- **Derived:** this is the only `passed:true` JSON whose green comes from a headless `SKIP_CAPTURE`-style row; it must **not** be read as a structural+visual PASS. No PNG exists for second-agent review (`TEST_MATRIX.md:75`).
- **Inferred:** `ATOM_REPAIR_report.md:70` already labelled it `PASS 13/13 (HEADLESS_STRUCTURAL_ONLY__PNG_UNVERIFIED)` — the label was carried into `passed:true` without a capture gate, unlike C3 which sets `passed=false` for the same headless condition.
- **Recommended owner/ticket:** TEST-P3 / COORD — new `P3-HEADLESS-GREEN` (or fold into `TEST-RUN-03`); require a windowed rerun before any P3 PASS claim. **Do not edit the atom to "fix" the count here (out of scope).**

### HIGH — H2. Seven stale result JSONs: atom edited after its last result
- **Observed:** P1, P2, P3, C1, C2, C3, C4 sources were rewritten 11:05:08–11:13:01, after their JSONs were written 10:00:45–10:08:38 (gaps ≈57–71 min). All seven JSONs came from ATOM-REPAIR's headless parse-check round (`ATOM_REPAIR_report.md:65-79`).
- **Observed:** the shared helper changed at 10:07:28 (HARNESS-01 cast fix), after the four cast-error jobs 365/368/369/370 — so those JSONs also reflect the pre-fix helper.
- **Derived:** none of these seven JSONs can certify the current source; the ladder's "stop at first failure" evidence (P0 FAIL at job 404, then green at 441) covers only P0. Later config-wiring edits left the other atoms' assertions unchanged in intent but the artifacts are stale.
- **Recommended owner/ticket:** COORD / ladder executor — new `TEST-RUN-03` (restart P1→C4 after all edits, one ticket per row, windowed, second-agent re-check). Board's existing `TEST-RUN-02` is already consumed by the P0 restart (line 155).

### MEDIUM — M1. PASS claim with no result JSON in the registry result dir
- **Observed:** `SWARM_BOARD.md:124` and `CAM_RV_01_view_rect_runtime.md:95,151,172,225` claim `t_view_rect_rv` PASS 20/20 (job 381, `camrv01-smoke3`); `variant3d/tests/results/t_view_rect_rv.json` does not exist. The atom deliberately prints `CAMRV01_JSON:` to stdout and "no extra repository file" (`CAM_RV_01...:85,231`); the full 20/20 JSON (`id: t_view_rect_rv`, `passed:true`) is present in the spool stdout and `00000381.json` (**observed**).
- **Derived:** the PASS is evidenced, but outside the canonical result surface used by every other atom and by `CAPTURE_RECHECK.md:50`; automated audits and `test_all.py` cannot see it.
- **Recommended owner/ticket:** CAM-RV-01 / INT-REGISTRY — `REGISTRY-RESULT-PARITY` (either emit the JSON to the result dir on a future run or record the stdout/spool pointer in the board/report).

### MEDIUM — M2. Motion-capture distinct-frame claim contradicts its own artifact
- **Observed:** `VID_CAP_01_capture.md:176,194,246` and `SWARM_BOARD.md:115` state **16/16 distinct** image signatures. `t_motion_capture.json` records `distinct_image_signatures: 10` and the check detail "distinct image signatures=10 of 16". Independent recount of `frames.json` (16 frames) yields **10 distinct `image.signature` arrays** and 11 distinct `mean_luma` values — matching the JSON, not the report (**verified twice**).
- **Derived:** the `frames_distinct` check still passes because the atom's threshold is below 16; the capture is 16 non-blank frames, but only 10 visually distinct signatures. This is a documentation/claim error, not a captured-frame failure.
- **Recommended owner/ticket:** VID-CAP-01 / VID-AN-01 — `VID-CLAIM-CORRECT` (correct the report/board wording to "16 frames, 10 distinct signatures"; keep the raw JSON authoritative).

### MEDIUM — M3. P0's visual PASS has no second-agent re-check report
- **Observed:** `t_terrain_only.json` is `verdict=PASS` with a 2.16 MB windowed PNG (job 441). `CAPTURE_RECHECK.md:34` states the second-agent role had not been performed and supplies only a protocol; there are **0** `reports/RECHECK_*.md` files. `TEST_MATRIX.md:75` requires a second agent before any piece is declared PASS.
- **Inferred:** the P0 gate numbers are green but the ladder row remains un-certified under its own protocol; `QA_DOCS_01` C21 separately notes README's stale P0 numbers (13.271/27.413).
- **Recommended owner/ticket:** COORD — assign a RECHECK-P0 second agent, ticket `RECHECK-P0` (fill a `RECHECK_P0.md` from the CAPTURE_RECHECK template). No code change.

### MEDIUM — M4. Registry status semantics lag the green atoms
- **Observed:** all 9 manifest entries have `status:"pending"`; P0 and S1 have green result JSONs; `t_motion_capture` has a green JSON but no manifest row at all. `--list` still reports 10 pending.
- **Derived:** `pending` now means "ladder row not yet re-run as a gate" rather than "feature not landed" (`manifest.json:2` definition), so a reader cannot distinguish authored/unrun from green-but-unregistered.
- **Recommended owner/ticket:** INT-REGISTRY — `REGISTRY-SYNC` (decide whether to register `t_view_rect_rv`/`t_motion_capture`/`t_season_overlay` and how to mark green-but-not-ladder rows). Harness remains intentionally unregistered.

### LOW — L1. Board ID collision for `TEST-RUN-02`
- **Observed:** `SWARM_BOARD.md:98` reserves `TEST-RUN-02` for "execute S1 after SEL-01 lands; second-agent capture re-check" with output `reports/TEST_RUN_02_selection_log.md`, while `:155` records `TEST-RUN-02` as the P0→C4 restart with output `reports/TEST_RUN_02_ladder_log.md` (the file that exists). S1 actually landed via `S1-INPUT-FIX` job 414 (`:148`). The selection-log report does not exist.
- **Recommended owner/ticket:** COORD docs — `BOARD-ID-FIX` (rename the reserved row or point it at `S1_INPUT_FIX.md`).

## 4. Open questions (UNVERIFIED)

1. Is there an intended canonical location for the `CAMRV01_JSON:` result (spool only today) so that `test_all.py`/QA can read it? (UNVERIFIED)
2. Should `expected_pre_fix_failure:true` remain on S1's two overlay checks now that SEL-01 landed and both checks PASS? `TEST_MATRIX.md:68` says keep markers until the fix lands; the fix has landed, but no ticket owns marker cleanup. (inferred; no edit recommended here)
3. Will `TEST-RUN-03` re-run windowed rows only, or also re-emit fresh result JSONs for the four headless parse-check rows? Very different evidence quality. (UNVERIFIED)
4. Did the later config-wiring edits to P1–C4 change any assertion semantics, or only constants/paths? Timestamp proves staleness, not behavioural drift. (UNVERIFIED — needs diff review by the owning builder/COORD)
5. Is the current P0 PNG (job 441, `full_width_dark_rows=0` recorded N/A) the same frame PIXEL-01 judged a `GENUINE_VISUAL_DEFECT`, or a post-shader-fix frame? (UNVERIFIED)

## 5. Summary

- **Observed:** 13 authored units; 10 result JSONs; 4 JSONs `passed:true`; 9 manifest entries (all `pending`); `--list` = 40 entries with no 2D access; registry correctly points at `variant3d/tests/results`.
- **Derived:** 1 false green (P3 headless skip rows counted as passes), 7 stale JSONs (atom edited after result), 1 PASS without a canonical result JSON (`view_rect_rv`), 1 claim/artifact numeric contradiction (16 vs 10 distinct motion frames), 1 visual PASS without the required second-agent re-check (P0), 1 registry status lag.
- **Inferred:** the registry and board describe an authoring/parse-check phase, not a completed ladder; only P0 and S1 have green results produced after their final source edits, and neither has a full second-agent ladder certification.
- **No file other than this report was edited.** No Godot runner job was submitted; the only command with side effects on stdout was the read-only `python variant3d\tools\test_all.py --list`. Pre-existing worktree changes (`SWARM_BOARD.md`, `decomp/SUMMARY.md`, `INVENTORY_01_counts.md`, `QA_2D_GATES_01.md`) were present before this audit and were not touched.
