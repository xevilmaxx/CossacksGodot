---
id: QA-HUD-REPAIR-01
title: "QA-HUD-REPAIR-01 — read-only verification of HUD-LAYOUT-REPAIR-01's atom fix after landing"
area: coord_swarm_2026-11-25
task_id: QA-HUD-REPAIR-01
date: 2026-11-25
owner: read-only QA subagent
status: STATIC_FIX_VERIFIED__POST_FIX_RUN_RECORDED__ATOM_FAIL__VISUAL_UNVERIFIED__NO_SOURCE_EDIT
scope: "Read-only. No code/test/config/queue/result-JSON edits and no runner jobs submitted by this QA worker."
labels: [READ_ONLY_QA, TOOLTIP_FIX_CONFIRMED, TEST_ONLY_RESIZE_OVERRIDE, THREE_SIZES_EXERCISED, RUNNER_JOB_EVIDENCE, ATOM_FAIL, NONBLANK_GUARD_FAIL, NO_PASS_CLAIM]
job_id_checked: hudlayoutrepair01-run
ticket: 548
atom_verdict: FAIL
repair_report: ABSENT
---

# QA-HUD-REPAIR-01 — verification of the HUD atom repair

Label key: **[observed]** = read directly from a file or runner artifact; **[derived]** = computed from observed values (diff/hash/count); **[inferred]** = reasoned from source semantics without runtime proof; **UNVERIFIED** = no evidence available or claim not made.

## 1. Sources

| Source | What it supplied | Label |
|---|---|---|
| `docs/coord_swarm_2026-11-25/reports/HUD_LAYOUT_RUN_01.md` (136 lines) | Pre-fix baseline: atom FAIL 42/11/12, `hud_ui_vp=[1280,720]` at all sizes, 3 tooltip drifts, 8 headless-resize cascade FAILs, `SKIP_CAPTURE`, open questions #2/#3 | [observed] |
| `docs/coord_swarm_2026-11-25/reports/HUD_LAYOUT_REPAIR_01.md` | **Absent** — glob over the whole root found no such file; SWARM_BOARD.md:347 still reads RUNNING | UNVERIFIED |
| `variant3d/tests/t_hud_layout.gd` (597 lines; mtime 12:38:56) | Repaired atom: tooltip constants :63-73, resize mechanism :254-292, unchanged assertion block :352-517, verdict logic :92-156, capture guard :527-549 | [observed] |
| `inbox/backup/t_hud_layout.gd.bak-HUDLAYOUTREPAIR` (577 lines; mtime 11:54:20) | Pre-repair snapshot; `git diff --no-index` against the live atom | [observed] |
| `variant3d/scripts/hud.gd:124-131,228-239,273-275` | Canonical six tooltip literals; `_calc_us()` reads `get_viewport().get_visible_rect().size`; `_on_vp_resize()` calls `_calc_us()` + `_apply_scale()` | [observed] |
| `variant3d/project.godot:15-19` | 1280×720 base, `canvas_items` stretch, `expand` aspect — why `root.size` alone left the visible rect at 1280×720 | [observed] |
| `variant3d/.godot_queue/results/00000548.json` | Runner record for `hudlayoutrepair01-run`: ticket 548, wait 303.29 s, run 82.86 s, `exit=1`, `status=failed`, argv includes all three `--png-*` paths | [observed] |
| `variant3d/.godot_queue/results/00000548_hudlayoutrepair01-run/stdout.txt` (71 lines), `stderr.txt` (67 lines) | 62 evaluated rows + result-JSON path; 0 `SCRIPT ERROR` lines | [observed] |
| `variant3d/tests/results/t_hud_layout.json` (mtime 12:48:43; `unix_ms=1795607323948`) | Atom-written post-fix result: FAIL, 55/7/3, `headless=false`, `capture_status=PASS`, `hud_ui_vp` per size | [observed] |
| `git status --short` | Live atom is modified; backup is untracked; no report file from this QA worker | [observed] |

## 2. Verification table

| # | Check | Evidence | Result | Label |
|---|---|---|---|---|
| 1 | Repair report landed? | No `HUD_LAYOUT_REPAIR_01.md` anywhere under root at final check; board row :347 still RUNNING | **ABSENT** — the fix and its run landed, the ticket report did not | [observed] |
| 2 | Three tooltip literals now match `hud.gd:128-130` | `git diff`: `produced by gold/iron/coal mines` → `produced at ...`; programmatic parse of both arrays: 6/6 exact, per-index `[T,T,T,T,T,T]` | **CONFIRMED**. Gold/Iron/Coal changed; Food/Wood/Stone unchanged; source untouched by this repair | [observed] / [derived] |
| 3 | Tooltip fix works at runtime | stdout:12,33,54 `six_resource_entries_*` PASS at all sizes, `icons_with_hint=6`; JSON `resource_hints_found=6` at all three sizes (was 3) | **CONFIRMED** (was 3 of 6 pre-fix) | [observed] |
| 4 | Resize mechanism genuinely exercises 3 sizes | `original_scale=root.content_scale_size` (:255); per size: optional `DisplayServer.window_set_size(want)` (:270-271), `root.size=want` (:272), `root.content_scale_size=want` with `# test-only logical viewport override` (:273), two settled frames (:274-275), HUD hook (:278-279), restore (:290-291). Documented in the header :25-26 and inline :260-269. `project.godot:18-19` cited as the reason | **PRESENT and DOCUMENTED** as a test-only harness override; windowed mode also resizes the real window | [observed] |
| 5 | Override actually changes the HUD's layout size at runtime | JSON `hud_ui_vp`: `[1024,576]`, `[1280,720]`, `[1920,1080]`; `hud_scale_viewport_*` PASS at all three (stdout:7,28,49); viewport_* PASS; minimap render size 194/242/362 px and top-panel width 1120/1290/1896 px differ per size; root texture sizes 1024/1280/1920 wide | **CONFIRMED** — three distinct laid-out sizes, not one layout measured thrice. Mechanism attribution (content-scale override drives `get_visible_rect()`) is [derived]/[inferred] from `hud.gd:234-239` + `project.godot:18-19`; the effect is observed | [observed] / [derived] |
| 6 | Containment / minimap / top-panel assertions preserved | `git diff --no-index` touches only header comments, `RES_TOOLTIPS_EXPECTED`, `_run_async`. `_check_size` block byte-identical (7726 bytes, SHA `771b5516332eecc5…` on both sides), 18 `check(` calls and all assertion names identical | **NO RELAXATION, NO DELETION** — every pre-fix assertion retained verbatim | [derived] |
| 7 | No hardcoded PASS | `check()` still derives status from `cond == true` / `== false` (:92-99); `_verdict()` FAILs unless `_ok` and 3 captures (:102-105); JSON `passed` derives from verdict (:126); no `check(..., true, ...)` or forced `"PASS"` status anywhere (grep: only verdict/comment lines) | **CONFIRMED** | [observed] / [derived] |
| 8 | Result JSON for `hudlayoutrepair01-run` present | Runner record ticket 548, `id=hudlayoutrepair01-run`; stdout:69-70 `RESULT_JSON: .../t_hud_layout.json` and `FAIL 55/62 evaluated, 3 skipped`; JSON `verdict=FAIL`, `passed=false`, `structural_ok=false`, `passes=55`, `fails=7`, `skipped_or_skip_capture=3`, `headless=false`, `capture_status=PASS` | **PRESENT**, `status=failed`/exit 1 (atom's own deferred quit, not a timeout) | [observed] |
| 9 | `hud_ui_vp` values per size (required) | 1024×576 → `[1024.0,576.0]`; 1280×720 → `[1280.0,720.0]`; 1920×1080 → `[1920.0,1080.0]` | **CORRECT at all three** (pre-fix: `[1280,720]` everywhere) | [observed] |
| 10 | `SCRIPT ERROR` scan | Direct read scan of the 67-line job stderr: `SCRIPT ERROR` lines = **0**. Present instead: warnings about image imports and `world3d_entities`, plus exit-time RID/ObjectDB/resource leak errors (stderr:60-67) and one `ERROR:` line at stdout:71 | **0 SCRIPT ERROR**; exit diagnostics not attributed to this atom | [observed] |
| 11 | Top-bar / containment outcome after fix | FAIL `top_panel_right_in_viewport_1024x576` (`x=[6.4,1126.4]` vs vp 1024) and `_1280x720` (`x=[8,1298]` vs vp 1280); FAIL `no_unclipped_control_outside_viewport_*` at those same two sizes (3 offenders each: top panel, HBox, Label). At 1920×1080 both PASS (0 offenders). `top_panel_clip_*` PASS at all sizes; `clipped_overflow_children_*` remain `RECORDED_NOT_GATE` (3 skips) | **R1 (never overflows) still NOT PASSED at 1024/1280**. These are unrelaxed assertions now reporting real geometry, not the old stale-`ui_vp` cascade | [observed] |
| 12 | Visual PASS from capture? | Three PNGs exist and `capture_image_*` / `capture_saved_*` PASS, but all three `capture_nonblank_*` **FAIL**: `non_black_fraction=0.0000`, `mean_luma≈0.12-0.13`, `max_luma≈0.97`. `finish()` increments `_captures_ok` at the end of `_capture_async` even when the nonblank check fails, so `capture_status=PASS` means only "3 PNGs saved" | **NO VISUAL PASS**. Verdict is FAIL. `capture_status=PASS` must not be quoted as visual verification | [observed] / [derived] |
| 13 | Likely cause of the three nonblank FAILs | `_image_metrics` (:527-549) computes luma from `Image.get_pixel()` floats (0..1) but tests `l > 8.0` (0..255 scale), so `non_black_fraction` is unreachable; observed `max_luma≈0.97` with `non_black_fraction=0.0` is consistent | [inferred] threshold unit mismatch; PNG content itself **UNVERIFIED** (no visual review in this ticket) | [derived] / [inferred] |

## 3. Verdict

- **Static repair: landed and verified.** The three tooltip literals now match `hud.gd:128-130` exactly (6/6 array equality, [observed]/[derived]), and the resize mechanism adds a documented test-only `content_scale_size` override plus an optional real window resize ([observed]). No assertion was weakened or deleted; `_check_size` is byte-identical to the backup ([derived]). No hardcoded PASS ([observed]).
- **Three-size sweep: genuinely exercised.** Post-fix runtime `hud_ui_vp` is `[1024,576]`, `[1280,720]`, `[1920,1080]`, with distinct HUD geometry per size ([observed]). The pre-fix "one layout measured three times" defect is removed.
- **Atom verdict: FAIL, not PASS.** Job `hudlayoutrepair01-run` (ticket 548) ran 82.86 s after a 303.29 s queue wait, `status=failed`/exit 1; atom result 55 passes / 7 fails / 3 recorded skips ([observed]). The seven FAILs are 2 top-panel containment, 2 whole-HUD containment, 3 `capture_nonblank_*` ([observed]).
- **Owner requirement R2 (one speed dropdown): verified at runtime at all three sizes** — one `OptionButton`, items `["II","1x","2x","4x"]`, metadata `[0,1,2,4]` s, zero legacy buttons (stdout:13-16,34-37,55-58; carried forward from HUD_LAYOUT_RUN_01.md). [observed]
- **Owner requirement R1 (bar never overflows): NOT PASSED** — two genuine containment FAILs remain at 1024×576 and 1280×720 after the corrected resize; 1920×1080 passes. [observed]
- **Visual: UNVERIFIED.** Three PNGs were saved with correct dimensions, but every nonblank guard failed and no donor A/B frame or human visual review exists. `capture_status=PASS` is a save-count field, not a visual PASS. [observed] / [derived]
- **Repair ticket report: UNVERIFIED/ABSENT.** `HUD_LAYOUT_REPAIR_01.md` has not landed; the code and the run have.
- **This QA worker: no edits, no jobs.** Only this report was written; no source, config, queue, manifest or result JSON was touched, and no runner job was submitted.

## 4. Open questions

1. When will `HUD_LAYOUT_REPAIR_01.md` land, and will it claim R1 PASS? The current run does not support an R1 PASS at 1024/1280. [observed]
2. Is `capture_nonblank_*`'s `l > 8.0` threshold a 0..255/0..1 unit bug ([inferred])? If so, who owns the guard fix, and are the three PNGs actually nonblank? Re-scoring the PNGs or a visual read is needed; none was done here. UNVERIFIED
3. Is `capture_status=PASS` semantic (save count) acceptable, or should the JSON field reflect the nonblank result? [derived] from `finish()` and `_capture_async()`.
4. Are the two top-panel/containment FAILs a real `hud.gd` layout defect at the two smaller sizes, or an expectation problem in the atom? Now that the sweep is correct, this can no longer be dismissed as a headless artifact; owner decision required. [observed] / UNVERIFIED
5. Is the `content_scale_size` override acceptable as the canonical test mechanism, or must acceptance require only real window resizes? It is documented test-only and the windowed run also called `DisplayServer.window_set_size`. [observed] / UNVERIFIED
6. Are the exit-time `RID allocations leaked`, `3 ObjectDB instances leaked`, `1 resources still in use at exit` diagnostics (stderr:60-67, stdout:71) pre-existing or introduced by recent uncommitted edits? One run cannot attribute them. UNVERIFIED
7. Early in this QA pass, `t_hud_layout.json` still held the stale pre-fix result (FAIL 42/11/12, `SKIP_CAPTURE`); it was overwritten by job 548 during the check. Consumers must quote the 55/7/3 post-fix artifact with `unix_ms=1795607323948`, not the earlier snapshot. [observed]

## 5. Summary

- Verified the repair **statically**: three tooltip literals now equal `hud.gd:128-130`; resize adds a documented test-only `content_scale_size` override (plus windowed `window_set_size`); `_check_size` is unchanged byte-for-byte; no forced PASS. [observed] / [derived]
- Verified the repair **at runtime** from job `hudlayoutrepair01-run` (ticket 548): `hud_ui_vp` is correct at 1024×576 / 1280×720 / 1920×1080, all six resource hints are found at every size, and the speed dropdown checks pass. The three-size sweep is real. [observed]
- The atom is still **FAIL (55/7/3)**: two top-panel/containment FAILs at 1024 and 1280 remain, plus three `capture_nonblank_*` FAILs whose guard appears to mix luma scales ([inferred]). `SCRIPT ERROR` count is 0. [observed]
- **No visual PASS** and **no R1 PASS** are claimed; R2 alone remains positively evidenced. The repair report itself is still absent. [observed] / UNVERIFIED
