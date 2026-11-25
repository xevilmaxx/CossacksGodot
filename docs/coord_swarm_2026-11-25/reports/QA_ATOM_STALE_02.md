---
id: QA-ATOM-STALE-02
title: "Read-only QA — which atom result JSONs were invalidated by DARKROW-ALL-01's edits"
owner: QA-ATOM-STALE-02 (read-only subagent)
date: 2026-11-25
status: DONE__REPORT_ONLY__NO_CODE_EDITS__NO_RUNNER_JOBS
scope: "Read-only comparison of atom source mtimes vs variant3d/tests/results/*.json, the darkrowall-* queue jobs and their stdout/stderr, the seven .bak-DARKROWALL backups, SWARM_BOARD.md and three prior reports. No Godot job was submitted; no file other than this report was written."
owns:
  - "docs/coord_swarm_2026-11-25/reports/QA_ATOM_STALE_02.md"
labels: [QA, STALENESS, DARKROW, RESULT_JSON, FALSE_GREEN, READ_ONLY]
evidence_labels: [observed, derived, inferred, UNVERIFIED]
snapshot_local_time: "2026-11-25 11:38:39 (re-measure; worktree is live — see §2 note)"
sources_verified_twice: true
---

# QA-ATOM-STALE-02 — atom result JSONs invalidated by DARKROW-ALL-01

## 1. Sources (all read-only)

| Requested / discovered source | Use | Label |
|---|---|---|
| `reports/QA_ATOM_RESULTS_01.md` (the actual path is `docs/coord_swarm_2026-11-25/reports/QA_ATOM_RESULTS_01.md`) | prior staleness baseline, false-green H1, ranked findings | observed |
| `reports/DARKROW_ALL_01.md` | **ABSENT** — not on disk in `docs/coord_swarm_2026-11-25/reports/`; SWARM_BOARD.md:285 still lists DARKROW-ALL-01 as RUNNING. Inferred provenance comes from backups/diffs only. | observed (absence), inferred (scope) |
| `reports/ATOM_REPAIR_report.md` (same reports dir) | provenance of the 10:00–10:08 headless result JSONs | observed |
| `variant3d/tests/{12 atoms}.gd`, `variant3d/tests/fixtures/_smallmap_harness.gd` | source mtimes; diffed against DARKROWALL backups | observed |
| `variant3d/tests/results/*.json` (65 entries) | result JSON mtimes, `passed`, `headless`, `status`, `checks[]` | observed |
| `inbox/backup/*.gd.bak-DARKROWALL` (7 files) | identifies exactly which atoms DARKROW-ALL-01 edited | observed |
| `variant3d/.godot_queue/results/0000046{9..9}*.json`, `00000486.json`, `00000493.json`, `00000497.json` + job folders | darkrowall-* job status, stdout/stderr, exit codes | observed |
| `docs/coord_swarm_2026-11-25/SWARM_BOARD.md:206-207,238-245,284-285` | task states, ladder/recheck rows, DARKROW-ALL-01 still RUNNING | observed |
| `python os.path.getmtime` (Python 3.14), formatted with `datetime.fromtimestamp` | all timestamps below | derived |
| `difflib.unified_diff` of backup vs current source | DARKROW-ALL-01's actual semantic changes | derived |

**Label key:** **observed** = read directly from file/command output; **derived** = computed from observed values; **inferred** = reasoned consequence, not directly stated; **UNVERIFIED** = cannot be established from available evidence.

## 2. Mtime table — atom `.gd` vs its result JSON

Local timestamps, `os.path.getmtime` → `datetime.fromtimestamp`, formatted `%Y-%m-%d %H:%M:%S`; epoch seconds in parentheses. `STALE` = source newer than result (result cannot describe current source). Snapshot at **11:38:39**; sources verified twice.

| Atom / source | Source mtime | Result JSON | JSON mtime | Verdict | Delta |
|---|---|---|---|---|---|
| **P0** `t_terrain_only.gd` | 10:33:57 (1795599237) | yes | **11:34:11** (1795602851) | **CURRENT** | JSON +3614 s |
| **P1** `t_terrain_trees.gd` | 11:05:08 (1795601108) | yes | 10:08:38 (1795597718) | **STALE** | src +3390 s |
| **P2** `t_terrain_shore.gd` | 11:06:28 (1795601188) | yes | 10:00:45 (1795597245) | **STALE** | src +3943 s |
| **P3** `t_terrain_mines.gd` | **11:36:50** (1795603010) | yes | 10:00:59 (1795597259) | **STALE** | src +5751 s |
| **C1** `t_combo_trees_shore.gd` | 11:08:06 (1795601286) | yes | 10:01:16 (1795597276) | **STALE** | src +4010 s |
| **C2** `t_combo_trees_mines.gd` | 11:13:01 (1795601581) | yes | 10:01:35 (1795597295) | **STALE** | src +4286 s |
| **C3** `t_combo_shore_mines.gd` | 11:10:03 (1795601403) | yes | 10:02:43 (1795597363) | **STALE** | src +4040 s |
| **C4** `t_combo_all.gd` | 11:11:11 (1795601471) | yes | 10:03:15 (1795597395) | **STALE** | src +4077 s |
| **S1** `t_select_rect.gd` | 10:27:33 (1795598853) | yes | **11:33:36** (1795602816) | **CURRENT** | JSON +3963 s |
| `t_view_rect_rv.gd` | 10:06:04 (1795597564) | **MISSING** | n/a | **NO_COMPARE** | n/a |
| `t_motion_capture.gd` | 10:22:47 (1795598567) | yes | 10:26:29 (1795598789) | **CURRENT** | JSON +222 s |
| `t_season_overlay.gd` | **11:34:56** (1795602896) | **MISSING** | n/a | **NO_COMPARE** | n/a |
| harness `fixtures/_smallmap_harness.gd` | 10:07:28 (1795597648) | none (fixture) | n/a | **NO_COMPARE** | n/a |

**Derived counts:** 7 STALE, 3 CURRENT, 2 NO_COMPARE (missing JSON), 1 fixture with no JSON. The 7 stale atoms are exactly P1–C4.

**Observed — worktree is live during this audit:** between the first and second mtime pass, `t_terrain_mines.gd` moved **11:06:57 → 11:36:50** and `t_season_overlay.gd` moved **11:33:29 → 11:34:56**. DARKROW-ALL-01 was still RUNNING at the 11:38:39 snapshot (board :285). Any mtime delta below is a point-in-time observation, not a final state.

### 2.1 Attribution: which edits are DARKROW-ALL-01's

**Observed:** exactly seven `.bak-DARKROWALL` backups exist — one each for `t_terrain_trees.gd`, `t_terrain_shore.gd`, `t_terrain_mines.gd`, `t_combo_trees_shore.gd`, `t_combo_trees_mines.gd`, `t_combo_shore_mines.gd`, `t_combo_all.gd`. There is **no** DARKROWALL backup for `t_terrain_only.gd`, `t_select_rect.gd`, `t_view_rect_rv.gd`, `t_motion_capture.gd`, `t_season_overlay.gd` or the harness.

**Observed:** backup mtimes are 09:25:56–09:47:18 (state of the source when copied), while current sources are 11:05:08–11:13:01. **Derived:** the 11:05–11:13 rewrites are DARKROW-ALL-01's edits (the backups were taken immediately before them); they are the same seven atoms whose JSONs are 10:00–10:08. **Inferred:** DARKROW-ALL-01 is the direct cause of all seven staleness findings — the results certify the pre-edit source, not the post-edit source.

**Derived from `difflib` backup→current diffs (per file):** DARKROW-ALL-01 did **not** make cosmetic changes:
- Added strict whole-frame luma gates `ground_mean_luma >= 40` and `ground_max_luma >= 100` to all seven atoms (new `CHECK_NAMES` entries, new `check()` calls, new headless `SKIP`/`UNVERIFIED` branches).
- Converted the water-band `full_width_dark_rows` assertion from pass/fail to record-only `RECORDED_NOT_APPLICABLE` on water-free atoms **P1, P3, C2**; kept it **strict** on water-bearing atoms **P2, C1, C3, C4**.
- **C2 additionally:** changed `check(name, cond: bool, ...)` to `check(name, cond, detail, status)` with Variant `cond`, added `skipped_or_notes` to the summary and changed pass/fail counting (`c.get("passed") == true/false`) — the emitted pass/fail semantics no longer match its old JSON.
- **P3 additionally:** inserted `_whole_frame_luma()`; a mid-edit version referenced undeclared `_m` at `:618` and **failed to parse** (job 497); the 11:36:50 version replaced it with the declared `_full_width_dark_rows_diag` (`:107,434,621`).
- **C4:** added `max_luma_0_255` to its metrics dict.

**UNVERIFIED:** whether DARKROW-ALL-01's report (when it lands) will list the same seven files and additional later edits.

## 3. Did the `darkrowall-*` jobs produce new result JSONs?

**Observed — no.** Job metadata and artifacts:

| Job | id | status / exit | stdout | New result JSON? |
|---|---|---|---|---|
| 469 | `darkrowall-t_combo_shore_mines` | **skipped** (`ticket 469 was skipped (serving=475)`) | empty dir | No |
| 470 | `darkrowall-t_combo_trees_mines` | **skipped** | empty dir | No |
| 471 | `darkrowall-t_terrain_shore` | **skipped** | empty dir | No |
| 472 | `darkrowall-t_combo_all` | **skipped** | empty dir | No |
| 473 | `darkrowall-t_terrain_trees` | **skipped** | empty dir | No |
| 474 | `darkrowall-t_terrain_mines` | no `00000474.json` metadata at all | empty folder | No |
| 475 | `darkrowall-t_combo_trees_shore` | ok / 0 | **75 B, Godot banner only** | No |
| 486 | `darkrowall-t_terrain_trees-r1` | ok / 0 | **75 B, banner only** | No |
| 493 | `darkrowall-t_terrain_shore-r1` | ok / 0 | **75 B, banner only** | No |
| 497 | `darkrowall-t_terrain_mines-r1` | **failed / 1** | banner only; stderr = `Parse Error: Identifier "_m" not declared ... t_terrain_mines.gd:618` + `Failed to load script` | No |

**Derived:** not one of the ten darkrowall jobs emitted a `RESULT_JSON:` line or wrote a file into `variant3d/tests/results/`. The only result JSONs touched after 11:00 are:
- `t_select_rect.json` 11:33:36 — **job 495 `audiosel02-drag`** (stdout contains `T_SELECT_RECT PASS ...`), a S1 windowed real-input row;
- `t_terrain3d.json` 11:31:28 — job 491 `terraindarkfix2-smoke`;
- `t_terrain_only.json` 11:34:11 — **job 496 `terraindarkfix2-p0-r3`**, a windowed P0 row.

None is a darkrowall job. **Therefore the seven edited atoms still have only their 10:00–10:08 ATOM-REPAIR headless JSONs.**

**Observed (bonus):** job 496's `t_terrain_only.json` contains `ground_mean_luma` = `PASS` (`mean_luma=91.424`) and `ground_max_luma` = `PASS` (`max_luma=154.448`) with `full_width_dark_rows` = `RECORDED_NOT_APPLICABLE`, and `verdict=PASS`, `capture_status=PASS`. **Inferred:** the DARKROW gate pattern has been exercised once, on **P0 only**, by a windowed row — P0 was not among DARKROW-ALL-01's edits, so this does **not** certify P1–C4.

**UNVERIFIED:** why the "ok" darkrowall jobs produced banner-only output. Board `:255` (`QA-RUNNER-ARTIFACTS-01`) and `:238`/`GATE-FAIL-01` ("diagnose banner-only gate startup failures") suggest a known startup problem, but no root cause is established on disk.

## 4. Does any `passed:true` headless row still claim a visual PASS?

**Observed — yes, exactly one, and it is stale.** `variant3d/tests/results/t_terrain_mines.json`:

- `passed: true`, `passes: 13`, `total: 13`, `headless: true`;
- `status: HEADLESS_STRUCTURAL_ONLY__PNG_UNVERIFIED`; no `verdict`, no `capture_status`;
- `png.written: false`, `png.size: [0, 0]`;
- three checks carry `passed: true` while their status is **not** PASS:
  - `png_capture_windowed` = `HEADLESS_SKIP__PNG_UNVERIFIED`
  - `ground_luma_variance_outside_mine_bbox` = `UNVERIFIED`
  - `no_z_fighting_seam_visual` = `UNVERIFIED__VISUAL_REVIEW_REQUIRED`

**Derived:** the JSON's green total is inflated by headless guard rows that never ran a capture; it must not be read as a structural **and visual** PASS. This is the H1 finding of `QA_ATOM_RESULTS_01.md` — still present, unfixed and now additionally stale (P3 source changed at 11:36:50, JSON still 10:00:59).

**Observed:** a scan of all 65 result files found no other atom JSON combining `passed:true` with `headless:true` or non-PASS `passed:true` rows. `t_terrain_only.json` is `passed:true` with `verdict=PASS`/`capture_status=PASS` (windowed PNG) and `t_motion_capture.json` is `passed:true` with `status=CAPTURE_OK` — neither is a headless false-green.

**Inferred:** because the darkrowall jobs emitted no JSON, this stale false-green remains the canonical machine-readable P3 result even though DARKROW-ALL-01 added visual checks to the source. A reader of `results/` alone would still see "P3 PASS 13/13".

**UNVERIFIED:** the post-fix (11:36:50) `t_terrain_mines.gd` has had **no** parse or load check — job 497 failed on the earlier `_m` version and no darkrowall re-run followed. Its current parse status is UNVERIFIED.

## 5. Verdict — ranked by severity

### HIGH-1 — P3 `t_terrain_mines`: stale false-green **plus** a broken-then-unverified source
**Observed:** stale by 5751 s; `passed:true` from three headless guard rows; PNG never written; job 497 rejected the source with a parse error at `:618`; the fixed source (11:36:50) has no subsequent job. **Derived:** both the result and the current source are untrustworthy for a PASS claim. **Recommendation:** parse-check the 11:36:50 source, then run a **windowed** P3 ladder row; do not carry `passed:true`/13-of-13 forward, and do not call the visual checks green until a PNG exists and the three rows are genuinely evaluated. Highest priority.

### HIGH-2 — C2 `t_combo_trees_mines`: stale JSON describes obsolete pass/fail semantics
**Observed:** stale by 4286 s; DARKROW-ALL-01 changed `check()`'s signature and the pass/fail counting loop, added two luma gates and a record-only dark-row row. **Derived:** even the *counts* in the old JSON (`passes:25`, `fails:3`) are computed by code that no longer exists; a headless re-run alone would not fix the missing visual gate. **Recommendation:** fresh windowed C2 row before trusting its result; second in priority after P3.

### HIGH-3 — P1, P2, C1, C3, C4: stale JSONs after assertion-semantics edits
**Observed:** stale by 3390–4077 s; each gained two strict luma checks and headless skip branches; P1 also converted `full_width_dark_rows` to record-only. **Derived:** their JSONs cannot certify the added gates; all currently `passed:false`/`UNVERIFIED`/`SKIPPED_HEADLESS` artifacts are pre-edit. **Recommendation:** fresh windowed ladder rows P1→C4, one ticket each, in board order.

### MEDIUM-1 — Darkrowall evidence gap
**Derived:** 5 of 10 darkrowall jobs were skipped, 1 has no metadata, 3 ran but produced banner-only stdout, 1 failed. No replacement artifact exists for any edited atom; QA cannot tell from the queue whether P1–C4 even load post-edit. **UNVERIFIED:** root cause (cf. GATE-FAIL-01 / QA-RUNNER-ARTIFACTS-01, board :238,:255).

### MEDIUM-2 — DARKROW-ALL-01 report absent
**Observed:** `reports/DARKROW_ALL_01.md` does not exist; board :285 says RUNNING. **Inferred:** owner-authored provenance and the final edited-file list are unavailable; this report's attribution is derived from backups and mtimes only and must be re-checked when the report lands.

### LOW / NOT INVALIDATED — P0, S1, motion_capture
**Observed:** CURRENT by mtime; none has a `.bak-DARKROWALL`. P0 has a post-edit windowed row (job 496, 11:34:11) with the new luma gates PASS; S1 has a post-edit windowed row (job 495, 11:33:36); `motion_capture` is unchanged since 10:22:47. **Derived:** DARKROW-ALL-01 did not invalidate these three.

### OUT OF SCOPE but noted — view_rect_rv, season_overlay
**Observed:** no canonical result JSON for either; `t_season_overlay.gd` was edited at 11:34:56 (`.bak-SEASONPATH`, not DARKROWALL). **Derived:** no DARKROW invalidation, but also no result-dir evidence — unchanged from `QA_ATOM_RESULTS_01.md` M1.

**Consolidated recommendation:** every atom DARKROW-ALL-01 touched (**P1, P2, P3, C1, C2, C3, C4 — all seven**) needs a fresh windowed ladder row before its result JSON can be trusted; P3 needs a parse check first. P0, S1 and motion_capture do not. Per `TEST_MATRIX.md:75` a second-agent capture re-check should follow each windowed row; board rows `RECHECK-P0-01`/`RECHECK-S1-01` (:238-239) show that protocol is already in flight for P0/S1 but not for P1–C4.

## 6. Open questions (UNVERIFIED)

1. Will `reports/DARKROW_ALL_01.md` land with a different final file list than the seven `.bak-DARKROWALL` backups imply, given the source was still changing at 11:36:50?
2. Does the 11:36:50 `t_terrain_mines.gd` now parse cleanly? No job after 497 exercised it.
3. Why did jobs 469–473 get skipped and 475/486/493 emit only a Godot banner while the earlier ATOM-REPAIR `--check-only` jobs wrote full `T_*` output and result JSONs?
4. Will the upcoming TEST-RUN-03 ladder row emit canonical JSONs into `variant3d/tests/results/`, or repeat the darkrowall banner-only pattern?
5. Is the `passed:true` headless guard pattern in `t_terrain_mines.gd:885-892` (counted as passes by `check(...)`) going to be corrected, or only masked by a windowed re-run?
6. Were the luma thresholds (40/100, "PORT APPROX — no donor GPU A/B exists") accepted by an owner, or are they provisional? Not documented in an owner report on disk.

## 7. Summary

- **Observed:** DARKROW_ALL_01.md absent / task RUNNING; 7 `.bak-DARKROWALL` backups identifying P1–C4; 65 result files; 10 darkrowall queue jobs; one still-present headless false-green (`t_terrain_mines.json`).
- **Derived:** 7 of 12 atom results are stale, and all 7 belong to the atoms DARKROW-ALL-01 edited; 3 are current and untouched; 2 have no JSON. Zero new result JSONs came from any darkrowall job. All seven edits changed assertions (new luma gates, record-only dark rows, and in C2 the pass/fail counting itself) — this is behavioural invalidation, not merely a timestamp drift.
- **Inferred:** DARKROW-ALL-01's edits are the direct cause of P1–C4 staleness; the stale P3 JSON is the most dangerous artifact because it claims `passed:true` with no PNG and three non-PASS rows counted as passes.
- **UNVERIFIED:** root cause of the banner-only/skipped darkrowall jobs; parse status of the 11:36:50 P3 source; final edited-file list until DARKROW_ALL_01.md lands.
- **No code, config, test, runner job or other report was modified; this file is the only output.**
