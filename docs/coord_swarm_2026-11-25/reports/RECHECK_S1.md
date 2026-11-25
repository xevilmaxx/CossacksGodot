---
id: RECHECK-S1
title: "Second-agent capture re-check - S1 drag-selection atom (t_select_rect.gd)"
area: coordination / testing (variant3d)
owner: RECHECK-S1 (second agent; never the executing builder)
date: 2026-11-25
status: DONE__REPORT_ONLY__READ_ONLY__NO_RUNNER_JOB__NO_CODE_EDIT__NO_LADDER_ADVANCE
scope: "One new file only: docs/coord_swarm_2026-11-25/reports/RECHECK_S1.md. No .gd/.gdshader/config/fixture/result-JSON/PNG edit, no Godot submission, no donor access, no row declared PASS, no ladder advance."
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "PORT APPROXIMATION - internal consistency only; no donor GPU A/B frame exists (TEST_MATRIX.md:32-34,73-74). This re-check verifies capture integrity and the atom's own stated criteria; it never certifies donor parity."
protocol: "docs/coord_swarm_2026-11-25/CAPTURE_RECHECK.md - S1 exception (1.1), S1 checklist (2), image rules (3), recording/ownership (4), attribution (5)"
row: S1
---

# RECHECK-S1 - independent second-agent re-check of the S1 drag-selection atom

## 0. Purpose and boundary

This report is the missing second-agent role required by `CAPTURE_RECHECK.md:0,4,34`. It re-checks the S1 atom's captured artifacts **against the atom's own assertions**. It does **not** run Godot, submit a queue job, edit any artifact, declare the row PASS, advance the ladder, or make any donor-parity claim. All findings are `PORT APPROXIMATION - internal consistency only`; donor GPU A/B is `UNVERIFIED` throughout.

Label key: **observed** = read directly from a file/command output; **derived** = arithmetic/control-flow consequence; **inferred** = reasoned but not directly stated; **UNVERIFIED** = cannot be established from the available material.

---

## 1. Artifacts opened (verbatim paths)

| # | Artifact | Path | State |
|---:|---|---|---|
| 1 | Protocol | `docs/coord_swarm_2026-11-25/CAPTURE_RECHECK.md` | read, sections 0-6 |
| 2 | Implementation report | `docs/coord_swarm_2026-11-25/reports/SEL_01_implementation.md` | read |
| 3 | Input-fix report | `docs/coord_swarm_2026-11-25/reports/S1_INPUT_FIX.md` | read |
| 4 | Atom authoring report | `docs/coord_swarm_2026-11-25/reports/TEST_S1_report.md` | read |
| 5 | QA audit | `docs/coord_swarm_2026-11-25/reports/QA_ATOM_RESULTS_01.md` | read |
| 6 | Result JSON | `variant3d/tests/results/t_select_rect.json` | read twice; **overwritten between reads** - see section 7 |
| 7 | Atom source (assertions) | `variant3d/tests/t_select_rect.gd` | read (lines 178-188, 224-236, 260-276, 287-288, 524-539, 553-571, 591-612) |
| 8 | Job 414 envelope | `variant3d/.godot_queue/results/00000414.json` | read; `status: ok`, `exit: 0`, no `--headless` in argv |
| 9 | Job 414 stdout | `variant3d/.godot_queue/results/00000414_s1inputfix-run2/stdout.txt` | read; `T_SELECT_RECT RESULT: PASS 23/23` |
| 10 | Job 414 stderr | `variant3d/.godot_queue/results/00000414_s1inputfix-run2/stderr.txt` | read + scanned; `script_error_lines: 0` |
| 11 | Cross-check jobs 438 / 495 | `variant3d/.godot_queue/results/00000438{,_configwires-drag}`, `00000495{,_audiosel02-drag}` | read; both `ok`/exit 0, `PASS 23/23`, `script_error_lines: 0` |
| 12 | PNG of the real drag | `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\s1inputfix_smallmap64.png` and five other candidate names | **ABSENT** - see section 5 |

Note on artifact 12: `TEST_MATRIX.md:26` lists "PNG + selection list" for S1, but `CAPTURE_RECHECK.md:1.1 S1 exception` and `S1_INPUT_FIX.md:222-224` state the atom asserts no PNG and that JSON/stdout is the authoritative surface. The protocol explicitly forbids manufacturing a visual PASS from a missing file.

---

## 2. Command outputs (verbatim, Windows `python`, read-only)

Protocol commands from `CAPTURE_RECHECK.md:1.2`:

```
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\00000414_s1inputfix-run2\stderr.txt
```

Output:

```
[
  {
    "path": "variant3d\\.godot_queue\\results\\00000414_s1inputfix-run2\\stderr.txt",
    "exists": true,
    "script_error_lines": 0,
    "lines": []
  }
]
```

Cross-check runs of the same command on the two later jobs that also wrote the canonical JSON:

```
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\00000438_configwires-drag\stderr.txt
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\00000495_audiosel02-drag\stderr.txt
```

Both returned `"script_error_lines": 0` with `"lines": []`.

No `stats` command was run: there is no PNG to measure, and `stats` is a qualitative inspector only (`smallmap_capture.py:42-48`). Job 414's stdout was read directly instead.

---

## 3. Capture-integrity prerequisites (`CAPTURE_RECHECK.md:1.1`)

| Prerequisite | Verdict | Evidence |
|---|:--:|---|
| Windowed launch, no `--headless` | **PASS** | `00000414.json.argv` = `--path variant3d --script res://tests/t_select_rect.gd -- --config <abs small_map_64.json> --screenshot <Temp>\s1inputfix_smallmap64_r2.png`; no headless flag. JSON `measured.headless=false`, `run_mode=windowed_real_input`. |
| Atom deliberately rejects headless as a fake PASS | **PASS** | `t_select_rect.gd:272-276`: headless -> `_run_mode="headless_skip"`, `_abort("SKIP_CAPTURE ... No fake PASS.")`; `S1_INPUT_FIX.md:222-238`. |
| `SCRIPT ERROR == 0` | **PASS** | `scan-stderr` = 0 for jobs 414, 438 and 495 (section 2). |
| Runner job envelope successful | **PASS** | job 414 `status: ok`, `exit: 0`, `wait 268.16 s`, `run 46.72 s`; stdout `RESULT: PASS 23/23`. |
| Fixed 64x64 harness / seed / fixture / 1280x720 reused | **PASS** | JSON `measured.config` = `...\variant3d\tests\fixtures\small_map_64.json`; `render_mode=3d MAP=64x64`; `viewport_px`, `root_viewport_px`, `projection_viewport_px` all `[1280,720]`; `event_coord_scale=[1,1]`; no new harness authored by S1-INPUT-FIX (`S1_INPUT_FIX.md:scope`). |
| PNG exists / non-blank | **N/A** | No PNG exists; atom asserts no PNG (section 5). Per protocol this is UNVERIFIED visual evidence, **not** a FAIL of an asserted criterion. |
| No weakening of assertions or markers | **PASS** | Source audit: `check(` = 24, `expected_pre_fix_failure` = 4, `EXPECTED_FAILURE_PRE_FIX` literal = 1, two `_assert_overlay` call sites at `:611-612` plus its definition at `:524`; matches `S1_INPUT_FIX.md` no-weakening statement. `t_select_rect.gd:538` passes `true` as the 4th arg to `check()` for both overlay checks, so the marker is retained, not cleared. |

Non-`SCRIPT ERROR` runtime messages in job 414 stderr are recorded as observations, not suppressed: a `T-MINES-FIX: no open coal site near start (5,60)` warning; a `world3d_entities` `DONOR-SAMPLED FLAT-ROOT MORPH - PORT APPROXIMATION` warning; three `mill_rotor.png` / `.ctex` load errors from `world3d_entities.gd:1349-1377`; a GLES3 texture RID leak (5460 bytes); `11 ObjectDB instances were leaked at exit`; `3 resources still in use at exit`. Per `CAPTURE_RECHECK.md:5.2` these belong to asset-import/harness owners, not to the S1 selection/overlay assertion, and none is a `SCRIPT ERROR`.

---

## 4. Criterion table (mirrors `CAPTURE_RECHECK.md:2`, S1 row)

Legend: exactly one of PASS / FAIL / N/A. "PASS" means the atom's assertion is satisfied in the captured artifacts and no available evidence contradicts it. For S1 the JSON/stdout is the authoritative surface (section 1, artifact 12).

| Criterion (atom check) | PASS | FAIL | N/A | Notes / evidence |
|---|:--:|:--:|:--:|---|
| `boot_real_64_3d_game`, `hud_visible` | X | | | JSON detail `render_mode=3d MAP=64x64`; `hud.visible restored after --screenshot boot` (`t_select_rect.gd:353,361`). |
| `test_entities_exact == [10,11,12,13]`, `cmd_spy_installed`, `picking3d_bound` | X | | | JSON detail `ids=[10, 11, 12, 13] (3 friendly units + 1 non-unit building)`; `input_ctl.game is CmdSpy subclass of C3Game`; `bind_3d() must create the picking3d adapter` (`:401-425`). |
| `projected_pixels_in_viewport`, `unproject_matches_world_to_px`, `ground_endpoints_finite` | X | | | `p0=(395.262,273.539)`, `p1=(917.084,457.888)`, `click=(512.029,337.395)` inside `vp=(1280,720)`; unproject == world_to_px exactly at printed precision; ground endpoints `(51.810,54.407)` / `(76.111,71.214)` finite (`:440-454`). |
| `drag_crosses_port_6px_threshold`, `drag_crosses_donor_0.005m_epsilon` | X | | | `553.43 px > 6.0 px` and `24.3009 m > 0.005 m`; drag crosses **both** thresholds, so a green result cannot exploit only the weaker port gate (`:450,465`). |
| Overlay `_assert_overlay` labels: node found / has API / visible + `Rect2` ~= expected during drag; hidden or empty after release | X | | | During drag: `node=SelectionRectOverlay api=true visible=true rect=[P:(395.262,273.539), S:(917.084,457.888)]` == expected `Rect2(_p0,_p1).abs()`. After: `visible=false rect=[(0,0),(0,0)]`. Both pass while carrying `expected_pre_fix_failure: true` (`:524-539`, `:611-612`). |
| Selection: `selected_ids_exact == [10,11]`, `unit10_selected`, `unit11_selected`, `unit12_not_selected`, `building_not_selected`, `building_inside_rect_but_excluded_by_kind` | X | | | JSON `selected=[10, 11] expected=[10,11]`; unit10/11 `selected=true`, unit12 `false`; building id 13 `kind=building player=0 selected=false` and `pos=(64.0, 64.0)` lies **inside** measured ground rect `(51.810,54.407)-(76.111,71.214)` - exclusion is by kind, not geometry (`:553-564`). |
| `cmd_counter_zero_after_drag`, `short_click_selects_single_unit == [10]`, `cmd_counter_zero_after_click` | X | | | Both `cmd_calls={  }`; short click `selected=[10] expected=[10] (no click-pick regression)` (`:564,569,571`). No `cmd_*` call was added or removed (`SEL_01_implementation.md` acceptance criterion e). |
| Real-event path: `drag_start_from_real_event`, `world_sel_active_during_drag` | X | | | `input_ctl.drag_start=(395.262,273.539) p0=(395.262,273.539)`; `world.sel_rect` SIM mirror set during drag and cleared after (`:591,602`; JSON `world_sel_active_during=true`, `world_sel_active_after=false`). |
| `SCRIPT ERROR == 0` and windowed (`run_mode: windowed_real_input`) | X | | | `scan-stderr` = 0 for all three jobs; JSON `run_mode=windowed_real_input`, `measured.headless=false`; job 414 `argv` has no `--headless`. |
| No assertion weakening / markers retained | X | | | Source counts in section 3; 24 `check()` calls and 4 `expected_pre_fix_failure` occurrences preserved. |
| PNG of overlay / selection | | | X | No PNG exists for the real drag. `N/A` per the S1 exception; visual state is **UNVERIFIED**, never a visual PASS (section 5). |
| Canonical JSON provenance (job attribution) | | | X | Not an atom criterion; recorded as an integrity/open question in sections 7 and 9. The 23/23 content itself is reproduced by three independent windowed jobs. |

No criterion is marked FAIL. No criterion was left blank.

---

## 5. Image inspection / region description (`CAPTURE_RECHECK.md:3`)

**There is no PNG for the real drag.** Six candidate paths were checked with `Test-Path` and all are `ABSENT`:

```
ABSENT: ...\Temp\opencode\s1inputfix_smallmap64.png        (S1_INPUT_FIX.md command form)
ABSENT: ...\Temp\opencode\s1inputfix_smallmap64_r2.png     (job 414 argv)
ABSENT: ...\Temp\opencode\configwires_smallmap64.png       (job 438 argv; JSON first read)
ABSENT: ...\Temp\opencode\audiosel02_smallmap64.png        (job 495 argv; JSON second read)
ABSENT: ...\Temp\opencode\smallmap64_select_rect.png       (TEST_S1_report.md launch form)
ABSENT: ...\Temp\opencode\sel01_select_rect.png            (job 320 argv)
```

A recursive `*.png` listing of `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode` returned thousands of PNGs in unrelated folders (`v2_out`, `v763_out\tex`, `vidqa`, `water2`, `wd_samples`, etc.) but none matching any S1 drag-capture name. The `--screenshot` argument is used only as the full-game-boot / menu-skip flag (`main.gd:206,230-244`; `TEST_S1_report.md` "Capture path chosen"), not as an asserted capture.

**Observed:** no image exists, so no region description is possible. **Derived:** no visual reading can either corroborate or contradict the JSON's overlay/selection assertions. **Inferred (caveated):** the atom quits before main's screenshot saver writes a file; this is consistent with `S1_INPUT_FIX.md:222-224` but was not independently proven by reading `main.gd`'s save timing in this re-check. **UNVERIFIED:** the yellow marquee's on-screen rasterisation, the selection aura, and any donor visual comparison.

Per `CAPTURE_RECHECK.md:1.1 S1 exception` and `:5.4`, the absence is recorded explicitly and selection/overlay are judged from the result JSON and stdout only. **No visual PASS is invented.**

---

## 6. Verdicts

- **Atom JSON verdict (observed):** `passed: true`, `passes: 23`, `total: 23`, `run_mode: "windowed_real_input"`. There is no `verdict` or `capture_status` field in this atom's JSON (source audit: 0 occurrences of `"verdict"` / `"capture_status"`), so `passed: true` is the atom's own green claim, corroborated by job 414 stdout `T_SELECT_RECT RESULT: PASS 23/23`.
- **Second-agent image verdict (observed):** `UNVERIFIED - NO PNG`. Not a PASS and not a FAIL; the visual half of the re-check could not be performed.
- **Second-agent artifact verdict:** all S1 criteria that the atom asserts are satisfied in the JSON/stdout: exact selected id set `[10,11]`, building excluded by kind while geometrically inside the ground rect, `cmd_*` counter zero after both drag and short click, short click selecting only `[10]`, overlay `Rect2` exactly `Rect2(p0,p1).abs()` during drag and hidden/empty after release, both `expected_pre_fix_failure` markers retained, real-event drag path active, windowed mode, `SCRIPT ERROR == 0`. No failure attribution to the input/selection owner is warranted by these artifacts (`CAPTURE_RECHECK.md:5.2`).
- **Combined:** `JSON/artifact PASS (23/23) + visual UNVERIFIED (no PNG) + PORT APPROXIMATION - internal consistency only`. Donor parity: **UNVERIFIED**; no donor GPU A/B frame exists and none was consulted.

---

## 7. Provenance / integrity note (important, non-criterion)

The task brief identifies the result JSON as "job 414". The canonical JSON is a shared, repeatedly overwritten file, and its internal provenance markers do **not** identify job 414:

- **First read during this re-check:** `screenshot_arg=...\configwires_smallmap64.png`, `unix_ms=1795599961483.0` = `2026-11-25T09:46:01.483Z`, `world_sel_rect_during=[51.8104,54.4071,6.0962,34.1133]`. This matches job **438** `configwires-drag` (created `09:45:00.477Z`, `ok`, exit 0, run 48.52 s, argv screenshot `configwires_smallmap64.png`).
- **Second read later in this re-check:** `screenshot_arg=...\audiosel02_smallmap64.png`, `unix_ms=1795602816379.0` = `2026-11-25T10:33:36.379Z`, `world_sel_rect_during=[51.8104,54.4071,11.8477,19.8597]`, file mtime `10:33:36.382Z`. This matches job **495** `audiosel02-drag` (created `10:28:54.566Z`, `ok`, exit 0, run 60.27 s).
- `git diff` confirms `HEAD` holds the job-438 version and the working tree holds the job-495 version; the file is modified and uncommitted.
- Job 414's own argv used `s1inputfix_smallmap64_r2.png`. Job 414's **stdout is intact** and records `PASS 23/23` with `p0`, `p1`, `click`, drag distance, ground delta, overlay rects, `selected=[10,11]`, short click `[10]` and `cmd_calls={}` identical to the JSON values.

**Derived:** the canonical JSON cannot, on its own, prove which job wrote it. **Observed:** three independent windowed real-input jobs (414, 438, 495) all returned `PASS 23/23`, exit 0 and `script_error_lines: 0` with the same assertion values; two later jobs (468 skipped, 495 ok) also targeted this atom. This reproduction is *internal consistency*, not donor parity. **Inferred:** later agents reusing the atom overwrote the shared result path; `QA_ATOM_RESULTS_01.md` H2/M4 already flags stale-result and registry-status issues. No artifact was edited by this re-checker.

---

## 8. Ladder advancement

This re-checker does **not** advance the ladder. Per `CAPTURE_RECHECK.md:4`, **COORD alone** authorises the next row in `P0 -> P1 -> ... -> C4 -> S1 -> FINAL`, one ticket per row; FINAL is COORD-only and last.

- No **S1-specific** failure was found in the artifacts: every asserted S1 criterion is satisfied, so nothing in this re-check blocks S1 on selection/overlay or on `cmd_*`/short-click regression.
- S1 must **not** be announced as a visual PASS: no PNG exists, so the image verdict is UNVERIFIED.
- COORD should decide whether to accept the JSON/stdout-only evidence (explicitly permitted by the protocol's S1 exception) and how to treat the shared-JSON overwrite in section 7 before recording a row-level PASS. A fresh, S1-exclusive windowed run would give unambiguous provenance; none was launched here.
- Earlier-row re-check status is outside this ticket's scope. `QA_ATOM_RESULTS_01.md` reports seven stale result JSONs and zero `RECHECK_*.md` files at audit time; strict ladder order remains a COORD decision.

---

## 9. Open questions

1. Should COORD treat job 414's intact stdout as the authoritative S1 evidence, given the canonical JSON now carries job 495's provenance markers? (UNVERIFIED - needs COORD decision; no artifact edited here.)
2. Should a later S1-exclusive windowed job write the canonical JSON so its `screenshot_arg`/`unix_ms` match the S1 ticket, avoiding ambiguity from later reusers of the atom? (inferred.)
3. No PNG exists for the real drag. Should a separate capture ticket produce `s1inputfix_smallmap64*.png` and a second-agent visual review of the marquee, or is the atom's no-PNG design accepted permanently? (UNVERIFIED; `TEST_MATRIX.md:26` vs `S1_INPUT_FIX.md:222-224`.)
4. The two `expected_pre_fix_failure: true` markers are retained by instruction even though the overlay checks now pass. No ticket owns flipping them; who does, and when? (`QA_ATOM_RESULTS_01.md` open question 2; `TEST_MATRIX.md:68`.)
5. Donor-native brush rasterisation and the native inside-box predicate remain UNVERIFIED; no donor GPU A/B frame exists. A windowed donor A/B is out of charter. (UNVERIFIED.)
6. Shift=add remains a declared divergence, not an assertion in this atom (`TEST_S1_report.md:123-130`). It was not re-checked here and was not claimed as passing.
7. The `0.25 m` attack/guard epsilon and the `0.5 s` double-click window have no runtime assertion in the green gates (`SEL_01_implementation.md` "UNVERIFIED / honest limits"). Not re-checked here.

---

## 10. Summary

- **Read:** the five governing reports (`CAPTURE_RECHECK.md`, `SEL_01_implementation.md`, `S1_INPUT_FIX.md`, `TEST_S1_report.md`, `QA_ATOM_RESULTS_01.md`), the S1 atom source, the canonical result JSON, and the job 414 envelope/stdout/stderr, plus cross-check jobs 438 and 495.
- **Re-checked:** windowed mode (`run_mode=windowed_real_input`, no `--headless`), `SCRIPT ERROR == 0` (scan-stderr 0 on 414/438/495), 23/23 checks, exact selection `[10,11]` with the player-0 building excluded by kind while inside the measured ground rect, `cmd_*` counter zero after drag and short click, short click selecting only `[10]`, overlay `Rect2` matching `Rect2(p0,p1).abs()` during drag and hidden/empty after release, retained `expected_pre_fix_failure` markers, and no assertion weakening (24 `check()` calls / 4 markers intact).
- **PNG:** absent. Six candidate paths checked; none exists. Selection and overlay were judged from JSON/stdout only. **No visual PASS was invented.**
- **Verdict:** atom JSON/artifact `PASS 23/23`; second-agent image verdict `UNVERIFIED (NO PNG)`; overall `PORT APPROXIMATION - internal consistency only`, donor parity `UNVERIFIED`. No donor parity claim. No criterion FAIL.
- **Ladder:** S1 is not blocked by any S1-specific re-check failure, but this report does not declare a row PASS and does not advance the ladder; COORD alone decides, with the no-PNG limitation and the shared-JSON provenance ambiguity recorded above.
- **Read-only:** no Godot job, no code/fixture/config/result/PNG edit, no donor access, and no file other than this report was written by this re-checker.

*End of RECHECK-S1.*
