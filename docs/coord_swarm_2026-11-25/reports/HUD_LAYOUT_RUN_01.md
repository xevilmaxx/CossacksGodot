---
id: HUD-LAYOUT-RUN-01
title: "HUD-LAYOUT-RUN-01 — one headless execution of t_hud_layout.gd (verdict FAIL, capture SKIP_CAPTURE)"
area: coord_swarm_2026-11-25
task_id: HUD-LAYOUT-RUN-01
date: 2026-11-25
owner: test-execution worker (read-only on code)
status: EXECUTED_ONCE__ATOM_FAIL__NO_PASS_CLAIM__VISUAL_UNVERIFIED__NO_SOURCE_EDIT
scope: "Exactly one variant-runner atom job; no code/test/config/manifest/queue/result-JSON hand edit; no full gate or ladder; no retry."
labels: [RUNNER_JOB, HEADLESS, SKIP_CAPTURE, ATOM_FAIL, STRING_DRIFT, HEADLESS_RESIZE_LIMITATION, NO_SOURCE_EDIT]
job_id: hudlayoutrun01-atom
ticket: 530
atom: "variant3d/tests/t_hud_layout.gd"
atom_result_json: "variant3d/tests/results/t_hud_layout.json"
atom_verdict: FAIL
parity: "PORT APPROX — internal layout consistency only; no donor GPU A/B frame; visual UNVERIFIED"
---

# HUD-LAYOUT-RUN-01 — single atom execution log

## 0. What was read before submitting

| File / command | Purpose |
|---|---|
| `docs/coord_swarm_2026-11-25/reports/HUD_LAYOUT_01.md` (231 lines) | Atom authoring status `AUTHORED__NO_GODOT_RUN__NO_PASS_CLAIM`, design, documented launch form, open questions #2 and #3. |
| `variant3d/tests/t_hud_layout.gd` (args section `:33-43`, `_initialize` `:180-203`, `_check_size` `:332-497`, constants `:53-69`) | Required user args `--config`, three `--png-*` flags, headless `SKIP_CAPTURE` path, deferred quit. |
| `docs/coord_swarm_2026-11-25/reports/QA_UI_FIXES_01.md` (302 lines) | R1/R2 landing status, flag-shape drift warning, unique-id convention, "no runner job" prior state. |
| `python variant3d\tools\godot_runner.py status` (pre-submit) | Queue health: `now_serving=524`, `next_ticket=528`, `pending=3 [524,525,527]`, `godot.lock=HELD (age 99.7s)`, `completed=500`. Busy but functional; **no queue mutation**. |

Reported paths in the task (`reports/HUD_LAYOUT_01.md`, `reports/QA_UI_FIXES_01.md`, root-level `godot_runner.py`) did not exist; the actual files are under `docs/coord_swarm_2026-11-25/reports/` and `variant3d/tools/` respectively. This was resolved by glob before submission; no file was created to fill the gap.

## 1. Command (exactly one submission, Windows `python`)

```bat
python variant3d\tools\godot_runner.py run --id hudlayoutrun01-atom --timeout 300 --max-wait 3600 -- --headless --path variant3d --script res://tests/t_hud_layout.gd -- --config "C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\tests\fixtures\small_map_64.json" --screenshot "%TEMP%\opencode\hudlayout\hud_layout_unused.png"
```

- Id `hudlayoutrun01-atom` is fresh and unique (not either `HUDLAYOUT01-*` id quoted in the authoring report).
- `--max-wait 3600` is a runner option (before `--`); `--timeout 300` is the hard per-job timeout.
- Headless per the atom's design; no `--png-*` paths were passed, so capture is `SKIP_CAPTURE` by design (%TEMP%\opencode\hudlayout\ was created for the `--screenshot` arg only). Windowed PNG capture was **not** attempted in this single-atom ticket.
- No direct `godot` invocation, no queue mutation, no re-submission of a slow job.

## 2. Job table

| Field | Value |
|---|---|
| Runner | `variant3d/tools/godot_runner.py run` (variant spool `variant3d/.godot_queue`) |
| Job id | `hudlayoutrun01-atom` |
| Ticket | **530** (the pre-submit `next_ticket` was 528; 528/529 were taken by other queued jobs in between — no duplicate submission by this worker) |
| `--timeout` / `--max-wait` | 300.0 s / 3600 s |
| Queue wait | 301.62 s (normal busy-queue wait, no skip) |
| Run time | 45.94 s |
| Runner status / exit | **`failed` / exit 1** (runner convention: non-zero Godot exit; job ran to completion, no timeout, no lock-timeout, no queue-race skip) |
| Runner output dir | `variant3d\.godot_queue\results\00000530_hudlayoutrun01-atom\` |
| Runner record | `variant3d\.godot_queue\results\00000530.json` |
| stdout / stderr | `00000530_hudlayoutrun01-atom\stdout.txt` (69 lines), `...\stderr.txt` (63 lines) |
| Result JSON (written by the atom itself) | `variant3d/tests/results/t_hud_layout.json` (`RESULT_JSON:` at stdout:68) |
| Post-run status | `now_serving=531`, `next_ticket=538`, `pending=7`; lock still held by another ticket — normal, left untouched. |

`exit 1` is the atom's own `call_deferred("quit", 0 if _ok else 1)` (`t_hud_layout.gd:152`) firing because `structural_ok=false`. It is **not** a harness, queue or timeout failure.

## 3. Atom result (from result JSON and stdout)

| Field | Value |
|---|---|
| `id` / `verdict` / `passed` / `structural_ok` | `t_hud_layout` / **FAIL** / `false` / `false` |
| `passes` / `fails` / `skipped_or_skip_capture` | **42 / 11 / 12** |
| Evaluated | `42/53 evaluated, 12 skipped` (stdout:69) |
| Composition of 12 skips | 9 `SKIP_CAPTURE` rows (three per size: `capture_image`, `capture_saved`, `capture_nonblank`) + 3 `RECORDED_NOT_GATE` rows (`clipped_overflow_children_*`, JSON-null, not gates) |
| `capture_status` / `headless` | `SKIP_CAPTURE` / `true` |
| Fixture / config | `64x64`, seed `20261113`, `variant3d/tests/fixtures/small_map_64.json` |
| `parity_label` | `PORT APPROX — internal layout consistency only; no donor GPU A/B frame` |

**Positive runtime evidence (all three sizes):** `real_64_boot`, `hud_bound`, `viewport_*`, `resize_hook_*`, `top_panel_present_*`, `top_panel_clip_*`, `single_speed_widget_*`, `speed_options_*`, `speed_option_metadata_*`, `no_legacy_speed_buttons_*`, `minimap_nodes_present_*`, `minimap_declared_240_*`, `minimap_square_*`, `minimap_no_topbar_overlap_*` all PASS (stdout:3-5,7-8,10,12-18,20; 26-29,31,33-41; 47,49-52,54-60,62). Notably, the one-dropdown requirement (R2) is verified at runtime: exactly one `OptionButton`, items `["II","1x","2x","4x"]`, metadata `[0.0,1.0,2.0,4.0]` seconds, zero legacy speed `Button`s at 1024/1280/1920.

### 3.1 The 11 FAIL rows (line evidence)

| # | Check (stdout line) | Measured detail | Count |
|---|---|---|---|
| 1 | `hud_scale_viewport_1024x576` (stdout:6), `hud_scale_viewport_1920x1080` (stdout:48) | `hud.ui_vp=(1280,720)` vs expected `(1024,576)` / `(1920,1080)`; JSON `hud_ui_vp` is `[1280,720]` for **all three** sizes (JSON:407-410,576-579,657-660) | 2 |
| 2 | `top_panel_right_in_viewport_1024x576` (stdout:9), `_1280x720` (stdout:30) | `top_panel x=[8,1298]` vs `vp.width=1024` / `1280` | 2 |
| 3 | `six_resource_entries_{1024x576,1280x720,1920x1080}` (stdout:11,32,53) | `labels=6 icons_with_hint=3 expected 6/6`; JSON `resource_hints_found: 3` at all sizes (JSON:431,600,681) | 3 |
| 4 | `minimap_bottom_right_1024x576` (stdout:19), `_1920x1080` (stdout:61) | anchors `(1,1,1,1)` but rect `x=[1002,1272] y=[450,712]` vs `vp=(1024,576)` / `(1920,1080)` | 2 |
| 5 | `no_unclipped_control_outside_viewport_1024x576` (stdout:21), `_1280x720` (stdout:42) | `offenders=14` and `offenders=3`, led by `top_panel x=[8,1298]` / `HBoxContainer x=[16,1290]`; zero offenders at 1920×1080 (stdout:63, JSON:705) | 2 |

### 3.2 SCRIPT ERROR scan (required external step)

Command: `python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\00000530_hudlayoutrun01-atom\stderr.txt`

```json
[{"path": "...stderr.txt", "exists": true, "script_error_lines": 0, "lines": []}]
```

**`SCRIPT ERROR`: 0 lines.** Raw stderr contains only warnings and exit-time diagnostics, all reported as-is: `T-MINES-FIX: no open coal site near start (5,60)` (stderr:1); four "Loaded resource as image file ... will not work on export" warnings (stderr:9,20,32,51); the documented `world3d_entities: DONOR-SAMPLED FLAT-ROOT MORPH — PORT APPROXIMATION` warning (stderr:44); `3 ObjectDB instances were leaked at exit` (stderr:60); `ERROR: 1 resources still in use at exit` (stderr:62). The last two are exit-time diagnostics, not `SCRIPT ERROR`, and are not attributed to this atom without a focused investigation.

## 4. Failure attribution by owning file

**A. Test-expectation drift — 3 FAILs (`six_resource_entries_*`)**

- Owning files: `variant3d/tests/t_hud_layout.gd:66-68` (atom, HUD-LAYOUT-01) **vs** `variant3d/scripts/hud.gd:124-130,407-415` (UI-TOPBAR-01).
- A read-only literal comparison of the six strings found 3 exact matches (food, wood, stone) and 3 differences: the atom expects "Gold/Iron/Coal is produced **by** ... mines" while `hud.gd:128-130` sets "produced **at** ... mines". The atom collects `TextureRect.tooltip_text` from `hud.gd:413`, so exactly 3 hints match → `icons_with_hint=3` at every size, independent of viewport.
- **Attribution:** atom's hardcoded expected literals drifted from the live source. This is *not* evidence of a runtime layout defect or of a missing icon — six labels and six icon nodes exist. Do not edit either side in this ticket; an integration owner must decide which literal is canonical and align the atom (or the source), then re-run.

**B. Headless resize does not reach the HUD — 8 FAILs (rows 1, 2, 4, 5 above)**

- Owning files: `variant3d/tests/t_hud_layout.gd:255-260,334-345` (harness uses `root.size = want` per `testbridge.gd:103-105`) plus `variant3d/scripts/hud.gd:228-239,273-275` (`_calc_us()` reads `get_viewport().get_visible_rect().size`; `_on_vp_resize()` calls `_calc_us()` + `_apply_scale()`).
- Evidence: `viewport_*` PASS (`root.size` reads back as the wanted size) but `hud.ui_vp` stays `[1280,720]` at all three sizes. The whole HUD therefore stays laid out at 1280×720 while the atom compares it against 1024×576 / 1280×720 / 1920×1080. The stale geometry explains the top-panel spill (`x=[8,1298]`), the bottom-right minimap mismatch (`x=[1002,1272] y=[450,712]`), and the 14/3 unclipped offenders; at 1920×1080 the same 1290-wide bar is "inside" only because the expected rectangle is wider.
- **Attribution:** a **headless-harness limitation**, not a demonstrated `hud.gd` regression. This settles `HUD_LAYOUT_01.md` open question #2: in `--headless`, changing `root.size` does **not** propagate to the viewport rect that `_calc_us()` reads, so the three-size sweep does not actually exercise three laid-out layouts. The atom fails loudly rather than silently testing the wrong size — correct behavior, but the FAIL verdict cannot be charged to UI-TOPBAR-01. A windowed run is required to test real resizing.

**C. Not attributable here**

- No FAIL row involves `main.gd`, `config.gd`, `data.gd`, the fixture, the manifest or queue state. Boot, HUD binding, config resolution and all speed-widget checks pass. No queue race, skip or timeout occurred.

## 5. Verdict

- **Runner:** `failed` / exit 1 — one job, completed normally in 45.94 s after a 301.62 s queue wait; not a harness failure.
- **Atom:** **FAIL** (`verdict=FAIL`, `passed=false`, `structural_ok=false`, 42/11/12). No PASS is claimed for the atom, for UI-TOPBAR-01 (R1) or for LOAD-ASYNC-01.
- **R1 (bar never overflows / adapts):** **UNVERIFIED** by this run — headless did not deliver three real layouts, and the overflow rows are harness artifacts. R2 (one speed dropdown) **verified at runtime** (all dropdown checks PASS at all three sizes).
- **Visual:** **UNVERIFIED** — headless guard makes capture impossible; all capture rows are `SKIP_CAPTURE` and the verdict is deliberately not PASS. No donor A/B parity claim.
- Per ticket scope: no retry, no assertion weakened, no full gates or ladder run. The FAIL is recorded, not "fixed" or re-submitted.

## 6. Open questions

1. Who reconciles the three tooltip literal drifts (`t_hud_layout.gd:66-68` vs `hud.gd:128-130`), and which string is canonical? Integration/owner decision; nothing edited here.
2. Can a windowed run (PNG paths under `%TEMP%\opencode\hudlayout\`) propagate resize to `hud.ui_vp` and clear the 8 cascade FAILs? Not tested in this single-atom headless ticket; it is the next evidence step, not a reason to relax this result.
3. Should the atom use a headless resize mechanism that actually changes the viewport visible rect, so the sweep tests three real layouts? Atom/COORD design question; no code change made.
4. Are the exit-time `3 ObjectDB instances leaked` / `1 resources still in use at exit` diagnostics pre-existing or introduced by the uncommitted `hud.gd`/`main.gd` edits? One run cannot attribute them; separate investigation needed.
5. `clipped_overflow_children_*` is recorded-only (`RECORDED_NOT_GATE`, count 0 at all sizes here) while `UX_LOADING.md:102` asks that no child be cut off — carried forward from `QA_UI_FIXES_01.md:260-263`; which reading of "never overflows" is authoritative?

## 7. Summary

- Executed exactly one atom job (`hudlayoutrun01-atom`, ticket 530) through the variant FIFO runner, headless, timeout 300, max-wait 3600; waited 301.62 s in the normal queue, ran 45.94 s, finished with runner status `failed` / exit 1.
- Atom wrote `variant3d/tests/results/t_hud_layout.json` itself: verdict **FAIL**, 42 passes / 11 fails / 12 skips, `capture_status=SKIP_CAPTURE`, visual **UNVERIFIED**.
- `smallmap_capture.py scan-stderr` found **0 `SCRIPT ERROR` lines**; only warnings and two exit-time resource diagnostics were present.
- 11 FAILs split into two causes, both attributed without editing: 3 from three "produced by/at ... mines" expected-string drifts between the atom and `hud.gd:128-130`; 8 from headless `root.size` not propagating to `hud.get_viewport().get_visible_rect().size`, leaving `ui_vp` at 1280×720 for all sizes. No failure was charged to `main.gd`, `config.gd`, the fixture or the queue.
- **No source file was edited.** No code, test, config, manifest, queue state or result JSON was changed by hand; the only repository file written by this worker is this report, plus a throwaway read-only comparison script created solely under `%TEMP%\opencode\hudlayout\`. No retry, no weakened assertion, no full gate/ladder.
