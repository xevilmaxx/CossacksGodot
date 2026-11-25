---
id: HUD-CAPTURE-FIX-01
title: "HUD-CAPTURE-FIX-01 — fix the t_hud_layout.gd nonblank PNG guard (3 false failures) without weakening layout checks"
area: coord_swarm_2026-11-25
task_id: HUD-CAPTURE-FIX-01
date: 2026-11-25
owner: test-atom repair worker
status: DELIVERED__GUARD_FIXED__3_FALSE_FAILS_CLEARED__ATOM_STILL_FAIL_ON_4_REAL_LAYOUT_CHECKS__2_SCRIPT_ERRORS_FROM_CONCURRENT_SELFTEST_EDIT
scope: "Exactly two repo files edited/created: variant3d/tests/t_hud_layout.gd (nonblank guard only) and this report. One backup created. No hud.gd, no other atom, no config/fixture/runner, no result JSON by hand, no selftest.gd edit, no retry job."
labels: [ATOM_REPAIR, NONBLANK_GUARD, SAVED_PNG_READBACK, SCRIPT_ERROR_FROM_OTHER_WORKER, NO_ASSERTION_WEAKENED, ATOM_STILL_FAIL, PORT_APPROX]
evidence_in: "docs/coord_swarm_2026-11-25/reports/QA_HUD_REPAIR_01.md:51-52,68 (job 548, 3 capture_nonblank_* FAILs, 0..1-vs-8.0 threshold inferred)"
backup: "inbox/backup/t_hud_layout.gd.bak-HUDCAPTUREFIX (SHA-256 verified identical to pre-edit source before edit)"
runner_job: "hudcapturefix01-run / ticket 554 / windowed / timeout 300 / --max-wait 3600"
parity_guard: "PORT APPROX — the guard is a capture-content check, not donor GPU parity; no visual PASS is claimed."
---

# HUD-CAPTURE-FIX-01 — report

Label key: **[observed]** = read from a file or runner artifact; **[derived]** = computed from observed values; **[inferred]** = reasoned from source semantics; **UNVERIFIED** = no evidence available.

## 0. Scope and ownership

Edited only `variant3d/tests/t_hud_layout.gd` (the nonblank guard) and wrote this report. Created one backup. **No other repo file was edited by this worker** — no `hud.gd`, no other atom, no config/fixture/runner code, no hand-edited result JSON, no queue mutation, no retry job. The result JSON cited below was written by the atom during the runner job. [observed]

The four remaining atom FAILs are deliberately **not** touched: `hud.gd` belongs to the separate MINIMAP-TIP-01 / UI-TOPBAR-01 follow-up owner. The two `SCRIPT ERROR` lines found in this run are a concurrent `selftest.gd` defect (§5); they are outside this ticket's ownership and were not fixed here. [observed]

## 1. Before → after: the nonblank guard (with citations)

### 1.1 Before — unreachable 0..1-luma threshold [observed]

Pre-edit source = `inbox/backup/t_hud_layout.gd.bak-HUDCAPTUREFIX` (verified identical to the live atom before this edit).

- `_image_metrics()` (backup `:527-549`) computed `var l := 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b` from `Image.get_pixel()` floats (0..1), then `if l > 8.0: nonblack += 1` (`:542`). A 0..1 value can never exceed 8.0, so `non_black_fraction` was structurally pinned to 0. [observed] / [derived]
- The gate itself (backup `:594-596`) was `check("capture_nonblank_" + tag, float(metrics["non_black_fraction"]) > 0.0, ...)` — with the metric pinned to 0, this could only FAIL. The detail string printed only `non_black_fraction` and `mean_luma`, hiding the cause. [observed]
- Job 548 (`hudlayoutrepair01-run`) recorded exactly this: three `capture_nonblank_*` FAILs with `non_black_fraction=0.0000`, `mean_luma≈0.12-0.13`, `max_luma≈0.97` in `variant3d/tests/results/t_hud_layout.json` (pre-run snapshot; QA_HUD_REPAIR_01.md:51-52). The QA worker labelled the threshold-unit cause **[inferred]**; this ticket confirms it by source semantics and by the now-working replacement. [observed] / [derived]

**The three PNGs were never blank.** Read-only `smallmap_capture.py stats` on job 548's saved PNGs measured full-frame `non_black_fraction` 0.993922 / 0.996047 / 0.997207, `mean_luma` 32.851 / 32.357 / 31.989, `full_width_dark_rows` 0. An independent grid replay (temporary script in `%LOCALAPPDATA%\Temp\opencode\`, no repo file) of the new criteria on those same PNGs gave `non_black_fraction` 0.990954 / 0.995079 / 0.995466, `luma_range` 0.976696 / 0.986180 / 0.973289, `distinct_colours` 355 / 289 / 304 — all three would pass. The FAILs were false. [observed]

### 1.2 After — content-based metrics on the saved PNG [observed]

New live source `variant3d/tests/t_hud_layout.gd:527-568` (`_image_metrics`) and `:607-632` (`_capture_async`):

1. **Reads the actual PNG.** After `save_png()` succeeds, the guard calls `Image.load_from_file(abs_png)` and scores the reloaded file (`:610-616`), not the pre-save GPU texture. `metrics["source"] = "saved_png"` is recorded in the JSON. If the PNG cannot be reloaded, the guard emits a `false` check (`:611-614`) — a new strict failure path, never a silent skip and never a CPU-map substitution (main.gd:1875-1882, CAPTURE_RECHECK.md:57-60). [observed]
2. **Non-black fraction** — per sampled pixel, `c.r * 255.0 > 8.0 or c.g * 255.0 > 8.0 or c.b * 255.0 > 8.0` (`:552`), i.e. the `np.any(rgb > 8.0, axis=2).mean()` definition from `variant3d/tools/smallmap_capture.py:26` while `Image.get_pixel()` supplies 0..1 floats. Luma itself remains normalised 0..1 (`0.2126R+0.7152G+0.0722B`, `smallmap_capture.py:25`). [observed]
3. **Luma variance** — `luma_min`/`luma_max` tracked with explicit float comparisons (`:554-557`) and reported as `luma_range = lmax - lmin` (`:566`). This is BLANK-CHECK-01's criterion 3 (`BLANK_CHECK_01.md:216-219`); explicit comparisons are used because `mini()`/`maxi()` are integer-only (`BLANK_CHECK_01.md:114-122`). [observed]
4. **Distinct colours** — count of distinct `"r_g_b"` integer triples over the sample grid (`:558`, `:567`), BLANK-CHECK-01's criterion 4 (`BLANK_CHECK_01.md:220-221`). [observed]
5. **Gate** (`:622-630`): `non_black_fraction >= 0.02 and luma_range > 0.02 and distinct_colours >= 4`, all three required. The status still comes from `check()`'s `cond == true` logic (`:92-99`); no literal PASS, no forced verdict. [observed] / [derived]

Same sampling stride as the old guard (`step = maxi(1, int(min(w,h)/64.0))`, `:539`), so no resolution-dependent weakening. The check name `capture_nonblank_*` is unchanged, as is its count (one per size). [observed]

## 2. Backup

| Item | Value |
|---|---|
| Path | `inbox/backup/t_hud_layout.gd.bak-HUDCAPTUREFIX` |
| Created | before the first edit, by byte copy from `variant3d/tests/t_hud_layout.gd` |
| SHA-256 pre-edit source = backup | `0E38F277F90E6A53FA0A5EAFC12F75FD3FBA6B3502DE4F7D13DD16F2AD064527` |
| SHA-256 after fix | `586E8DC0C234377ADD17FB52386527F8840A606BAF7F310F40E8FCEA5F4FACDF` |
| Size | 24,888 B (backup) → 632 lines final / 597 lines backup |
| `git diff --no-index` | 41 insertions / 6 deletions, confined to `_image_metrics` and the `capture_nonblank_*` block | [observed] |

## 3. Validation — ONE runner job, no retries

```bat
python variant3d\tools\godot_runner.py run --id hudcapturefix01-run --timeout 300 --max-wait 3600 -- --path variant3d --script res://tests/t_hud_layout.gd -- --config "C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\tests\fixtures\small_map_64.json" --screenshot "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\hudcapturefix\hud_layout_unused.png" --png-1024x576 "...\hudcapturefix\hud_1024x576.png" --png-1280x720 "...\hudcapturefix\hud_1280x720.png" --png-1920x1080 "...\hudcapturefix\hud_1920x1080.png"
```

Windowed (no `--headless`), fresh output directory so job 548's PNGs were preserved. No direct `godot`, no `reset`/`ack`/`unwedge`, no queue mutation, no other job. [observed]

| Field | Value |
|---|---|
| Runner record | `variant3d/.godot_queue/results/00000554.json` |
| Job id / ticket | `hudcapturefix01-run` / **554** |
| Wait / run | 0.0015 s / **88.91 s** |
| `--timeout` / `--max-wait` | 300 s / 3600 s |
| Status / exit | `failed` / **exit 1** — the atom's own `quit(0 if _ok else 1)`, not a timeout (4 real layout FAILs remain) |
| Output dir | `variant3d/.godot_queue/results/00000554_hudcapturefix01-run/` (`stdout.txt` 10,732 B, `stderr.txt` 5,247 B) |
| Atom result JSON | `variant3d/tests/results/t_hud_layout.json`, `unix_ms=1795607923016.0` |
| Verdict / counts | **FAIL**, `passed=false`, `structural_ok=false`, **58 passes / 4 fails / 3 skips** (`RESULT: FAIL 58/62 evaluated, 3 skipped`) |
| Capture | `capture_status=PASS`, `headless=false`, 9 capture PASS incl. **all three `capture_nonblank_*`** |
| Skips | 3 × `RECORDED_NOT_GATE` (`clipped_overflow_children_*`); no `SKIP_CAPTURE` |

**Count delta 55/7/3 → 58/4/3: exactly the three `capture_nonblank_*` FAILs became PASS; no other check changed status.** [observed] / [derived]

The four remaining FAILs are the same unrelaxed layout failures as job 548 (separate owner):

- `top_panel_right_in_viewport_1024x576` — `x=[6.4,1126.4]` vs viewport width 1024.
- `no_unclipped_control_outside_viewport_1024x576` — 3 offenders (top panel, HBoxContainer, Label).
- `top_panel_right_in_viewport_1280x720` — `x=[8,1298]` vs viewport width 1280.
- `no_unclipped_control_outside_viewport_1280x720` — the same 3 offenders.

At 1920×1080 both containment checks PASS (0 offenders). These are accepted as unresolved here; no retry loop was started. [observed]

### 3.1 Exact nonblank stats

From the atom's `measured[*].png_metrics` (grid-sampled, `source=saved_png`), with an independent full-frame read-only `python variant3d\tools\smallmap_capture.py stats` alongside: [observed]

| Size | samples | non_black_fraction (atom) | luma_range | distinct_colours | mean_luma | max_luma | bytes | `smallmap_capture.py` non_black_fraction / mean_luma / dark rows |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| 1024×576 | 7,296 | **0.990954** | **0.976696** | **355** | 0.129024 | 0.976696 | 79,804 | 0.993922 / 32.851 / 0 |
| 1280×720 | 7,722 | **0.995079** | **0.986180** | **290** | 0.123118 | 0.986180 | 101,469 | 0.996075 / 32.352 / 0 |
| 1920×1080 | 8,160 | **0.995466** | **0.973289** | **303** | 0.124492 | 0.973289 | 171,364 | 0.997222 / 31.984 / 0 |

Details recorded in stdout, e.g. `capture_nonblank_1280x720 :: non_black_fraction=0.9951(>=0.02) luma_range=0.9862(>0.02) distinct_colours=290(>=4) mean_luma=0.1231 max_luma=0.9862 samples=7722 source=saved_png`. Every gate clears its threshold by a wide margin, and the two independent readers agree. Slight differences from the job-548 replay (289/304 distinct colours) reflect a freshly rendered frame, not a changed criterion. [observed] / [derived]

## 4. No-weakening statement

- `_check_size` is **byte-identical** to the backup: 7,726 bytes, SHA-256 `771b5516332eecc51dff5ccd8f8aa8fcdb55937e1e572002035b3ce4c6705908` on both sides; all 18 `check(` calls inside it are unchanged. [derived]
- The 18 containment / top-panel / minimap / speed / tooltip assertions, the resize mechanism (`:254-292`), `RES_TOOLTIPS_EXPECTED` (`:66-73`), the 3 `_skip_capture_*` statuses and `check()`/`_verdict()`/`finish()` are untouched. No threshold in those checks was lowered or made conditional. [observed] / [derived]
- The old guard could only fail (`non_black_fraction` pinned to 0 by a unit bug). The new guard requires **three simultaneous** conditions, so it is strictly harder to satisfy than a correct single-condition guard: an all-black frame fails `non_black_fraction`, a flat/uniform frame fails `luma_range`, and a one-/two-tone frame fails `distinct_colours`. A failed PNG reload also fails the check. [derived]
- No hardcoded PASS: `check()` still sets status from `cond`; `_verdict()` still requires `_ok` and 3 captures; the job still exited 1 because of the 4 real layout FAILs. [observed]
- No game code, config, harness or result JSON was edited to manufacture a green capture. [observed]

## 5. `SCRIPT ERROR` — 2 lines, attributed to a concurrent edit (honest report)

`python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\00000554_hudcapturefix01-run\stderr.txt` returned **`script_error_lines: 2`**, not 0: [observed]

```
SCRIPT ERROR: Parse Error: Identifier "slot" not declared in the current scope.
   at: GDScript::reload (res://scripts/selftest.gd:170)
SCRIPT ERROR: Compile Error: Failed to compile depended scripts.
   at: GDScript::reload (res://scripts/main.gd:0)
```

Followed by `ERROR: Failed to load script "res://scripts/main.gd" with error "Compilation failed."` [observed]

- The offending `slot` is declared at `variant3d/scripts/selftest.gd:166` **inside** `if not builder.is_empty():` but referenced at `:170` outside that block. `git diff -- variant3d/scripts/selftest.gd` shows 17 added `SELFTESTALLFIXDIAG` lines from another worker (backup `inbox/backup/selftest.gd.bak-SELFTESTALLFIX`, also untracked in `git status`). This is a concurrent edit, not this ticket's work. [observed] / [derived]
- This atom contains no `slot` identifier; its edit is confined to `_image_metrics` and `capture_nonblank_*`. The parse error was emitted while `t_hud_layout.gd:198` loaded `main.tscn` / `main.gd`, i.e. at dependency compile time, not from the guard. [derived]
- Despite the diagnostics, the atom completed all 62 evaluated checks and wrote its result JSON; no capture check was skipped. The error is reported, not suppressed and not fixed here (outside exclusive ownership). Job 548 had `SCRIPT ERROR == 0`; this run does not, and no PASS claim is made on that basis. [observed]
- Remaining stderr lines are the documented benign class (T-MINES warning, atlas/alphavert/mill-rotor image-load warnings, flat-root PORT APPROXIMATION warning, exit-time RID/ObjectDB/resource leaks) plus the compile errors above. [observed]

## 6. Open questions (UNVERIFIED — do not guess)

1. The 4 top-panel/containment FAILs at 1024×576 and 1280×720 remain real and are owned by the `hud.gd` follow-up; this atom only reports them. [observed]
2. `capture_status=PASS` is still a **save-count** field (`_captures_ok == VIEWPORTS.size()`), not a visual verdict. The atom keeps `parity_guard: PORT APPROX — internal layout consistency only`; no donor A/B or human visual review is claimed by this ticket. [derived]
3. Who owns the `selftest.gd:166/170` `slot` scope fix? Until it lands, runner `SCRIPT ERROR` counts will be non-zero for jobs booting `main.tscn`, including this one. No edit made here. [observed] / UNVERIFIED
4. Are the thresholds `0.02 / 0.02 / 4` appropriate for a legitimately near-black scene? They are inherited from BLANK-CHECK-01 (`BLANK_CHECK_01.md:210-228`) and are PORT APPROX, not donor-calibrated; a valid night/night-map frame with <2% lit pixels would be rejected. Not exercised by this fixture. [derived] / UNVERIFIED
5. The atom scores a 64-step sampled grid while `smallmap_capture.py stats` scores every pixel; observed `non_black_fraction` differs by ~0.002-0.003. With margins near 0.99 vs a 0.02 floor this is immaterial here, but a future near-threshold frame would need a second look. [derived]
6. Whether the exit-time RID/ObjectDB/resource diagnostics are new is unchanged from prior tickets' open question; one run cannot attribute them. UNVERIFIED

## 7. Summary

- **Before:** `t_hud_layout.gd:527-549` computed 0..1 luma and tested `l > 8.0`, pinning `non_black_fraction=0`; three `capture_nonblank_*` checks in job 548 FAILed on PNGs independently measured as ~99% non-black (QA_HUD_REPAIR_01.md:51-52,68). [observed] / [derived]
- **After:** the guard reloads the saved PNG, applies the proven `smallmap_capture.py:26` non-black definition plus BLANK-CHECK-01's symmetric luma-range and distinct-colour criteria, and requires all three. Backup `inbox/backup/t_hud_layout.gd.bak-HUDCAPTUREFIX` taken first (SHA-256 verified). [observed]
- **Validated once:** windowed job `hudcapturefix01-run` / ticket 554, timeout 300, `--max-wait 3600` — wait 0.0015 s, run 88.91 s, exit 1. Atom result **FAIL 58/4/3** (was 55/7/3); all three nonblank checks now PASS with `non_black_fraction` 0.990954 / 0.995079 / 0.995466, `luma_range` 0.976696 / 0.986180 / 0.973289 and 355 / 290 / 303 distinct colours. The only status changes are those three FAIL→PASS. [observed]
- **No weakening:** `_check_size` byte-identical; 18 assertions, resize mechanism and tooltip literals untouched; no hardcoded PASS; a black/flat/monochrome frame still fails loudly. [derived]
- **Honest residuals:** four real layout FAILs at 1024/1280 remain for the `hud.gd` owner; `SCRIPT ERROR` is **2**, from a concurrent `selftest.gd:170` edit outside this ownership, not from this fix. No visual PASS, no R1 PASS, no retry, no full gate. [observed]
- **Only `variant3d/tests/t_hud_layout.gd` and this report were edited by this worker** (plus the mandated backup); concurrent edits by other workers appear in `git status` and are not from this ticket. [observed]

---

*End of HUD-CAPTURE-FIX-01. One runner job. Capture-mechanics fix only; no donor parity claim, no layout assertion relaxed.*
