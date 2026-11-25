---
id: QA-ATOM-RUNS-01
title: "Read-only QA — HUD-layout and load-usability atom results after their single runs"
owner: QA-ATOM-RUNS-01 (read-only subagent)
date: 2026-11-25
status: DONE__REPORT_ONLY__NO_CODE_EDITS__NO_RUNNER_JOBS
scope: "Read-only collection/verification of reports/HUD_LAYOUT_RUN_01.md and reports/LOAD_PROBE_RUN_01.md, their authoring reports, both result JSONs, runner result records/stdout/stderr, one read-only scan-stderr command and the live queue. No Godot job submitted; no code, test, config, manifest, queue state or result JSON edited; only this file written."
owns:
  - "docs/coord_swarm_2026-11-25/reports/QA_ATOM_RUNS_01.md"
labels: [QA, ATOM_RESULTS, HUD_LAYOUT, LOAD_USABILITY, SKIP_CAPTURE, MEASUREMENT_ONLY, READ_ONLY]
evidence_labels: [observed, derived, inferred, UNVERIFIED]
snapshot_queue: "now_serving=534, counter=543, jobs 534-542, godot.lock=534 1795605742.755"
sources_verified_twice: true
parity_claim: NONE
---

# QA-ATOM-RUNS-01 — post-run verification of the two UX atoms

## 0. Label key and method

**[observed]** = read directly from a file/command output; **[derived]** = computed or
cross-referenced from observed values; **[inferred]** = reasoned consequence, not
proven; **[UNVERIFIED]** = cannot be established from available evidence.

Both requested run reports were **absent on the first glob** and landed while this
audit was reading (point-in-time caveat **[observed]**). All sources below were
re-read a second time before the verdict. **No `MEASUREMENT_ONLY` or `SKIP_CAPTURE`
result is promoted to PASS** in this report.

## 1. Sources (all read-only)

| Source | Use |
|---|---|
| `docs/coord_swarm_2026-11-25/reports/HUD_LAYOUT_RUN_01.md` (136 lines) | Single-run log: job id/ticket, argv, runner status/exit, verdict, failure attribution, its own `SCRIPT ERROR` scan |
| `docs/coord_swarm_2026-11-25/reports/LOAD_PROBE_RUN_01.md` (262 lines) | Single-run log: job id/ticket, measurement JSON reading, wall-cap termination, stderr triage |
| `docs/coord_swarm_2026-11-25/reports/HUD_LAYOUT_01.md`, `reports/LOAD_PROBE_01.md` | Authoring declarations (`AUTHORED__NO_GODOT_RUN__NO_PASS_CLAIM`, `MEASUREMENT_ONLY__NO_PASS_CLAIM`), assertion design, limitations |
| `variant3d/tests/results/t_hud_layout.json` (730 lines) | `verdict`, `passed`, `passes`/`fails`/`skipped_or_skip_capture`, `capture_status`, 65 `checks[]`, per-size `measured` |
| `variant3d/tests/results/t_load_usability.json` (115 lines) | `verdict`, `gate_claim`, `pass_claim`, 11 `checks[]`, `measured`, `notes`, `limitations` |
| `variant3d/.godot_queue/results/00000530.json`, `00000531.json` and `status.json` (`history`) | Runner status/exit, wait/run, timeout, argv, ticket-to-job mapping |
| `variant3d/.godot_queue/results/00000530_hudlayoutrun01-atom/{stdout,stderr}.txt`, `00000531_loadprobe01-atom/{stdout,stderr}.txt` | Atom `RESULT:`/`VERDICT:` lines, raw warnings/errors |
| `python variant3d\tools\smallmap_capture.py scan-stderr <both stderr.txt>` (read-only) | Literal `SCRIPT ERROR` count; tool counts lines containing "SCRIPT ERROR" (`smallmap_capture.py:55`) |
| `variant3d/.godot_queue/jobs/*.json` (534–542), `now_serving`, `counter`, `godot.lock` | Check for queued reruns of either atom at snapshot |
| `docs/coord_swarm_2026-11-25/SWARM_BOARD.md:324-325,336` | Batch X task ids/session ids: HUD-LAYOUT-RUN-01 and LOAD-PROBE-RUN-01 both `RUNNING` when read |
| File mtimes (`python os.path.getmtime`) | Freshness of each result JSON vs its atom source |

**Freshness [derived]:** `t_hud_layout.gd` 11:54:20 → JSON 12:18:48; `t_load_usability.gd`
11:51:46 → JSON 12:21:03. Both results post-date their atom source, so neither is
stale by mtime. Mtime proves ordering only, not correctness of the assertions.

## 2. Atom table — one result per atom

| Atom / ticket | Job id | Runner status / exit | Result verdict | Pass / fail counts | Capture status | `SCRIPT ERROR` (scan-stderr) | Requirement outcome (short) |
|---|---|---|---|---|---|---|---|
| **HUD-LAYOUT-RUN-01** / **530** ([observed] run report:11-12,49; runner JSON) | `hudlayoutrun01-atom` | **`failed` / exit 1** ([observed]); wait 301.62 s, run 45.94 s, timeout 300 s, no skip/timeout | **FAIL** ([observed] JSON `verdict`, `passed:false`, `structural_ok:false`) | **42 passes / 11 fails / 12 skipped** ([observed] JSON fields; stdout `FAIL 42/53 evaluated, 12 skipped`; 9 `SKIP_CAPTURE` + 3 `RECORDED_NOT_GATE`) | **`SKIP_CAPTURE`** ([observed] `capture_status`, `headless:true`, 9 null capture rows, `png_user_args` empty; no PNG) | **0** ([observed] scan output `script_error_lines:0`); raw stderr has warnings + one exit-time `ERROR: 1 resources still in use at exit`, no GDScript runtime error | Speed dropdown **verified structurally**; top-bar fit **FAIL as measured** but **UNVERIFIED as real layout** (headless resize did not reach HUD); no visual claim |
| **LOAD-PROBE-RUN-01** / **531** ([observed] run report:51-64; runner JSON) | `loadprobe01-atom` | **`ok` / exit 0** ([observed]); wait 347.26 s, run 134.34 s, timeout 300 s not reached | **`MEASUREMENT_ONLY__NO_PASS_CLAIM`** ([observed] JSON; `gate_claim:NONE`, `pass_claim:false`) | No `passes`/`fails` fields **[observed]**; 11 checks = 3 `OBSERVED`/met `true`, 1 `OBSERVED`/met `false` (`c_camera_response`), 7 `UNVERIFIED` (6 `null`, 1 met `false` for `staged_overlay_observed`) **[derived]** | **No capture rows / no `capture_status` field** ([observed]) — headless probe, no PNG; capture **N/A**, no visual claim | **0** ([observed] `script_error_lines:0`), **but** one raw GDScript runtime `ERROR: String formatting error: not all arguments converted during string formatting` at `_finish` (`t_load_usability.gd:518`) + exit-time resource error **[observed]** | All five owner properties (a)–(e) **UNVERIFIED**; one measured non-response (camera), wall-cap at frame 1742 |

**Notes on the table [observed/derived]:**

- Runner `failed`/`exit 1` for 530 is the atom's own `quit(0 if _ok else 1)` on
  `structural_ok=false`, not a harness/queue failure (`HUD_LAYOUT_RUN_01.md:53,60`).
- Runner `ok`/`exit 0` for 531 means only "Godot exited and the runner released the
  lock"; it is explicitly **not** a PASS or gate result (`LOAD_PROBE_RUN_01.md:73-75`).
- The `script_error_lines == 0` counts are literal-match counts. The scan tool does
  **not** classify a GDScript `ERROR:` line that lacks the text `SCRIPT ERROR`
  (`smallmap_capture.py:55`). Therefore "0" is reported as the tool's count, and the
  probe-side formatting ERROR is reported separately; no "clean stderr" claim is made.
- Both jobs completed. At snapshot `now_serving=534`, `counter=543`, queued jobs
  534–542 contain **no** rerun of either atom **[observed]**. The live queue is
  perishable: any later job is **UNVERIFIED** here.

## 3. Requirement matrix

Rows use the atom's own status labels; "raw atom outcome" is **observed**, the
"honest QA outcome" column is **derived** unless noted.

| Owner requirement | Atom evidence (raw) | Honest QA outcome | Why |
|---|---|---|---|
| **Top bar fits at 1024×576** | `top_panel_right_in_viewport_1024x576` **FAIL** (`top_panel x=[8,1298]`, `vp.width=1024`); `no_unclipped_control_outside_viewport_1024x576` **FAIL** (14 offenders); `hud_scale_viewport_1024x576` **FAIL** (`hud_ui_vp=[1280,720]`); `top_panel_clip` PASS | **UNVERIFIED** (raw rows FAIL, not a proven UI defect) | `viewport_1024x576` PASS but `ui_vp` stayed 1280×720 in headless; the sweep never laid out a real 1024-wide HUD. Run report §4B attributes 8 cascade FAILs to this harness limitation. Capture is `SKIP_CAPTURE`, so no visual fit proof exists. |
| **Top bar fits at 1280×720** | `top_panel_right_in_viewport_1280x720` **FAIL** (`right=1298 > 1280`); `no_unclipped_control_outside_viewport_1280x720` **FAIL** (3 offenders); `hud_scale_viewport_1280x720` PASS; `top_panel_clip` PASS | **UNVERIFIED** (raw rows FAIL) | Same stale-geometry cause: `hud_ui_vp=[1280,720]` is the *default*, so PASS on `hud_scale_viewport` here does not prove a resize event was exercised. No windowed PNG. |
| **Top bar fits at 1920×1080** | `top_panel_right_in_viewport_1920x1080` **PASS**; `no_unclipped_control_outside_viewport_1920x1080` **PASS** (0 offenders); `hud_scale_viewport_1920x1080` **FAIL** (`ui_vp=[1280,720]`); `six_resource_entries_1920x1080` **FAIL** | **UNVERIFIED** (raw rows partly PASS, atom verdict FAIL) | A 1290-wide bar is inside a 1920-wide expected rect only because the HUD stayed at 1280 layout (`HUD_LAYOUT_RUN_01.md:107`). The atom's overall verdict is FAIL; capture `SKIP_CAPTURE`. Do not read the two PASS rows as a 1920 layout proof. |
| **Speed is a dropdown** | `single_speed_widget`, `speed_options` (`["II","1x","2x","4x"]`), `speed_option_metadata` (`[0,1,2,4]` s), `no_legacy_speed_buttons`: **PASS at all three sizes** [observed] | **PASS (structural, headless) / click reachability UNVERIFIED** | Four rows × 3 sizes green confirm one `OptionButton`, donor-style option set and no legacy `Button`s. `SKIP_CAPTURE` means no click/visual proof. The labels are port strings; **no donor parity claim** (`SPEED_PLAN_01.md:44,138`, JSON `parity_label: PORT APPROX`). |
| **Window movable during load** | No atom row; `LOAD_PROBE_RUN_01.md:209-210` states headless cannot test it; `LOAD_PROBE_01.md:160-166` limitation 3 | **UNVERIFIED** | No windowed drag, no Start click (forced `Object.call` proxy), no paint/movability sampling. |
| **Overlay hides when ready** | `staged_overlay_observed` **UNVERIFIED** (met `false`): `overlay_frames=0`, 15 stage texts, last `<none>`; `b_bindings_before_overlay_hide` **UNVERIFIED** (no hide transition) | **UNVERIFIED** | Atom hit its 120 s wall-cap at frame 1742; no hide snapshot fields in `measured`. The `<none>` stage is only **[inferred]** evidence that `_hide_loading()` ran (`LOAD_PROBE_RUN_01.md:198-208`); cause of `overlay_frames=0` is UNVERIFIED. |
| **No post-load blocking / usable after overlay** | `d_no_deferred_heavy_stage` **UNVERIFIED** (detail retains literal `%d` placeholders); `c_input_response`/`c_order_response` **UNVERIFIED** (no live unit); `c_camera_response` **OBSERVED / met `false`** (`frame -1`, probe never issued); `no_pass_claim` **OBSERVED / true** | **UNVERIFIED** (with one measured non-response) | Stability phase never entered; no violation/gap numbers exist. `frame -1` is a negative observation from a probe that was never called, not a passed response and not a proven user-facing block. |

**Cross-cutting [observed]:** the HUD JSON itself declares
`parity_label: "PORT APPROX — internal layout consistency only; no donor GPU A/B frame"`;
the load JSON has no donor comparison. **No parity claim is made anywhere in this report.**

## 4. Verdict

1. **Both requested sources landed and both single runs are accounted for.**
   Ticket **530** (`hudlayoutrun01-atom`) → `t_hud_layout.json` **FAIL**, 42/11/12,
   `capture_status=SKIP_CAPTURE`, scan-stderr `SCRIPT ERROR` = 0. Ticket **531**
   (`loadprobe01-atom`) → `t_load_usability.json` **`MEASUREMENT_ONLY__NO_PASS_CLAIM`**,
   `gate_claim:NONE`, `pass_claim:false`, no capture surface, scan-stderr
   `SCRIPT ERROR` = 0 plus one probe-side runtime formatting ERROR **[observed]**.
2. **No PASS is promoted.** A `SKIP_CAPTURE` headless layout result cannot certify
   R1 visually; a `MEASUREMENT_ONLY` probe cannot certify R3/R4/R5, and its own
   design says exit 0 ≠ pass. **[observed/decision]**
3. **Speed dropdown is the only owner requirement with positive runtime evidence**,
   and it is structural only (four rows × three viewports) **[observed]**; no click
   or donor-parity claim **[UNVERIFIED]**.
4. **Top-bar fit at all three widths remains UNVERIFIED despite raw FAIL/PASS rows**,
   because the headless sweep never changed `hud.ui_vp` from 1280×720
   **[observed → derived]**, corroborated by `HUD_LAYOUT_RUN_01.md:104-108`.
5. **Load responsiveness remains UNVERIFIED** end-to-end: no windowed drag, no
   observed overlay-visible frame, no hide snapshot, no post-hide probes or
   stability numbers; the run ended on the atom's own wall-cap **[observed]**.
6. **No jobs were queued for these atoms at snapshot** (jobs 534–542 unrelated);
   therefore nothing is marked UNVERIFIED merely for being queued. Any future
   rerun is outside this snapshot **[UNVERIFIED]**.
7. QA performed no runner job and no edit; this file is the sole output
   **[observed]**.

## 5. Open questions

1. Who reconciles `t_hud_layout.gd:66-68` ("produced **by** ... mines") with
   `hud.gd:128-130` ("produced **at** ... mines") — the three `six_resource_entries`
   FAILs? Atom/source drift, not a proven layout defect (`HUD_LAYOUT_RUN_01.md:98-102`).
2. Can a **windowed** run propagate `root.size` to `hud.ui_vp` and produce real
   1024/1280/1920 layouts plus PNGs? Not attempted in the single headless ticket.
3. Should the HUD atom adopt a headless resize mechanism that actually updates
   `get_viewport().get_visible_rect().size`, or should the three-size sweep be
   windowed-only? Design decision; no assertion was weakened here.
4. Why did `overlay_frames` stay 0 while 15 `loading_stage` transitions were seen?
   Atom `visible` gate vs frame ordering with `_loading_tick`'s `process_frame`
   awaits — cause **UNVERIFIED** (`LOAD_PROBE_RUN_01.md:225-230`).
5. Should the load probe's 120 s `WALL_CAP_US` be raised/restarted later, and its
   `_finish` string-format ERROR fixed, so (b)–(d) produce real numbers? Probe-owned.
6. Is the 23.26 s `max_stage_to_stage_us` proxy a genuine long stage, a frame-pump
   artefact, or both? Literal per-stage stall still needs `main.gd` instrumentation.
7. Are the exit-time `3 ObjectDB instances leaked` / `1 resources still in use at
   exit` diagnostics pre-existing or introduced by the uncommitted `hud.gd`/`main.gd`
   edits? One run cannot attribute them.
8. Which reading of "never overflows" is authoritative: the 3 record-only
   `clipped_overflow_children` rows or `UX_LOADING.md:102` ("no child cut off")?

## 6. Summary

- **[observed]** Two single runner jobs: 530 `failed`/exit 1 (headless HUD atom,
  45.94 s run) and 531 `ok`/exit 0 (headless load probe, 134.34 s run); both wrote
  their own result JSON; both run reports landed during this audit; both result
  JSONs post-date their atom source.
- **[observed]** `t_hud_layout.json`: verdict **FAIL**, 42 passes / 11 fails / 12
  skips, `SKIP_CAPTURE`, scan-stderr `SCRIPT ERROR` = 0. `t_load_usability.json`:
  verdict **`MEASUREMENT_ONLY__NO_PASS_CLAIM`**, 3 observed-true / 1 observed-false
  / 7 unverified checks, no capture field, scan-stderr `SCRIPT ERROR` = 0 but one
  probe-side runtime formatting ERROR.
- **[derived]** Positive requirement evidence is limited to the speed dropdown
  (structural, three sizes). Top-bar fit and all load-responsiveness requirements
  are **UNVERIFIED** from these runs; raw FAIL rows are not promoted to PASS and
  raw PASS rows are not promoted to layout proof.
- **[inferred]** The dominant HUD failures are test-expectation string drift (3)
  and a headless resize limitation (8), per the executing worker's attribution.
- **[UNVERIFIED]** Window movability during load, literal overlay-hide readiness,
  no post-load blocking, windowed/PNG visual fit, real Start-click path, and all
  donor visual parity. **No parity claim.**
- **No code, test, config, manifest, queue state or result JSON was edited; this
  report is the only file written by QA-ATOM-RUNS-01.**
