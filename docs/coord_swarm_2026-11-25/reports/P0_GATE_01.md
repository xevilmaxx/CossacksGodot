---
id: P0-GATE-01
title: "Replace P0's inapplicable dark-row predicate with an equally strict, applicable ground-visibility gate"
owner: P0-GATE-01 (atom-repair micro-builder)
date: 2026-11-25
status: DELIVERED__ONE_VALIDATION_JOB__GATE_EXPECTED_TO_FAIL
scope: "Hand-edited only variant3d/tests/t_terrain_only.gd and this report; plus one backup copy. No harness, other atom, game code, shader, config, fixture, app/**, runner code or other report was touched. The validation job itself regenerated variant3d/tests/results/t_terrain_only.json and the temp PNG as runtime outputs (not hand edits)."
owns:
  - "variant3d/tests/t_terrain_only.gd"
  - "docs/coord_swarm_2026-11-25/reports/P0_GATE_01.md"
backup: "inbox/backup/t_terrain_only.gd.bak-P0GATE01 (copy of the pre-edit atom, 25913 bytes)"
labels: [observed, derived, PORT_APPROX, UNVERIFIED]
parity_guard: "PORT APPROX — no donor GPU A/B exists (V3D_02 parity_guard). No donor parity is claimed."
validation: "windowed runner job 421 / id p0gate01-run — END failed, exit 1 (expected)"
---

# P0-GATE-01 — strict, applicable replacement for the P0 dark-row gate

## 0. Question

Two independent reviewers examined the same 1280×720 P0 PNG and reached
different verdicts. This ticket does **not** pick one and discard the other;
it reconciles them by fixing the *instrument*, not the *observation*.

- Keep the recorded evidence: the frame is genuinely near-black.
- Correct the criterion: `full_width_dark_rows == 0` was built to detect water
  bands, which P0 deliberately cannot contain.
- Do not weaken anything (`docs/coord_swarm_2026-11-25/TEST_MATRIX.md:67-68`):
  add a strict, applicable ground-visibility gate that still fails this frame.

## 1. Reconciliation of the two verdicts (with citations)

| Reviewer | Verdict | What it actually establishes |
|---|---|---|
| `PIXEL-01_p0_capture_review.md:11,73-83` | **GENUINE_VISUAL_DEFECT** | The pixels are genuinely unusable: 99.734% below luma 20, 0 pixels at/above luma 30, brightest single pixel 28.4, no tiles/horizon/structure (`:37`, `:54-56`). Re-measure reproduces `mean_luma=13.271`, `mean_rgb=[14.045,14.381,0.001]`, `full_width_dark_rows=720` (`:19`). |
| `METRIC_01_dark_rows.md:13,228-268` | **METRIC_ARTIFACT** | The *specific predicate* is inapplicable: `smallmap_capture.py:27-28` counts rows where >90% of pixels have `luma<20`; it was authored for water bands (`V3D_02` P6/F6 `:91,129`, `DTRN_03` W2/M5 `:131,396,484`), while P0 hides its only `WaterPlane` and has 0 water cells (`:114-119`) and the code-specified camera makes every ray land on ground (`:129-152`). |

**Both are true and they are not in conflict.** They answer different
questions:

- METRIC-01 is right about **applicability**: a row-wise near-black census has
  no water-presence clause, so "720/720 rows dark" is the geometrically
  expected topology of a water-free, ground-only frame whose ground is dim.
  PIXEL-01 itself records no row-level contrast and no bright band
  (`PIXEL-01:30,45,186-188 of METRIC-01`), so no water band is being detected.
- PIXEL-01 is right about **the symptom**: the frame really is a globally
  near-black olive field. METRIC-01 explicitly does **not** claim visual PASS
  (`METRIC_01:264-267`) and its own §3 reproduces the same numbers
  (`METRIC_01:170-199`).

The pre-fix atom asserted `int(ms["full_width_dark_rows"]) == 0` with detail
`"expected 0; smallmap_capture.py:27-28"`
(`t_terrain_only.gd:666-667` before this edit; `TEST_P0_report.md:98`;
`TEST_RUN_02_ladder_log.md:204-217`). That is the wrong instrument for a
water-free frame: it fails for a reason unrelated to what it was designed to
catch, yet the underlying defect it happened to expose is real. The correct
response is neither "delete the check" nor "declare a false positive" — it is
to **replace it with a strict criterion that is actually applicable** to a
ground-only frame.

## 2. Before → after assertion

### Before (pre-edit, atom lines 363-391 metric mirror and 664-667 assertions)

```gdscript
# metric: non_black_fraction, mean_luma, full_width_dark_rows
check("non_black_fraction", float(ms["non_black_fraction"]) > 0.9, ...)
check("full_width_dark_rows", int(ms["full_width_dark_rows"]) == 0,
    "full_width_dark_rows=%d (expected 0; smallmap_capture.py:27-28)" % ...)
```

### After (this edit)

1. `full_width_dark_rows` is retained in `_image_metrics()` and in
   `_m["png_metrics"]`, but its hard assertion becomes a **recorded
   diagnostic**: `check("full_width_dark_rows", null, ..., "RECORDED_NOT_APPLICABLE")`.
   It is therefore reported (value 720) without contributing to pass/fail.
2. `_image_metrics()` now also computes `max_luma` (whole-frame peak), using
   the identical luma formula `0.2126R+0.7152G+0.0722B` from
   `smallmap_capture.py:25`.
3. Two new **hard** checks are added, both applicable to any ground-only frame:

```gdscript
check("ground_mean_luma", float(ms["mean_luma"]) >= 40.0, ...)
check("ground_max_luma",  float(ms["max_luma"])  >= 100.0, ...)
```

4. `CHECK_NAMES` gains `ground_mean_luma` and `ground_max_luma` after the
   existing entries; all 20 structural assertions and the
   `non_black_fraction > 0.9` check are byte-for-byte unchanged.

### Threshold justification (anchored to PIXEL-01's measurements)

| Threshold | Current frame | Must fail? | Healthy reference | Status |
|---|---|---|---|---|
| `mean_luma >= 40.0` | 13.271 | **FAIL** (13.271 < 40) | the earlier recorded 64² capture measured `mean_luma=44.181` (`TERRAIN_SMALL_maps.md:138-142`, cited in `METRIC_01:218-220`), which clears 40 | **PORT APPROX** |
| `max_luma >= 100.0` | 27.413 (atom) / 28.4 (8-bit PNG, `PIXEL-01:37`) | **FAIL** (both far below 100) | no donor peak exists; 100 is a deliberate whole-frame dynamic-range floor, not a donor-derived value | **PORT APPROX** |

- `mean >= 40` is ≈3× the observed 13.271 and sits **below** the only recorded
  port-rendered bright-enough 64² frame (44.181), so it separates the defect
  from a plausible healthy frame rather than fitting the defect.
- `max >= 100` forces real tonal range. PIXEL-01 found 0 pixels at or above
  luma 30, so this gate is unambiguously violated today; it also prevents a
  frame that carries a single bright speck but is otherwise dark from passing
  via the mean alone.
- **PORT APPROX — no donor GPU A/B exists** (`V3D_02 parity_guard`,
  `TEST_MATRIX.md:34,73-74`). The 44.181 figure is a port capture of a
  *different* composition (water/entities/sky present, `METRIC_01:218-222`),
  not a donor ground measurement. It is used only as evidence that the
  threshold is not tailored to the dark frame; it is not donor calibration.
- Neither number was lowered to match the current 13.271 / 28.4. Lowering them
  would be weakening and is forbidden (`TEST_MATRIX.md:67-68`).

## 3. Backup

```
copy variant3d\tests\t_terrain_only.gd inbox\backup\t_terrain_only.gd.bak-P0GATE01
```

Created successfully before any edit:
`inbox/backup/t_terrain_only.gd.bak-P0GATE01`, 25913 bytes. No other backup
file was created or overwritten.

## 4. Validation job (one job, no rerun)

Windowed, same launch args as TEST-RUN-02 P0 (`TEST_RUN_02_ladder_log.md:64-68`),
only the unique id changed to `p0gate01-run`; no `--headless`, no direct
`godot`, no ladder/full gates, no terrain/shader/config edit to force a pass.

```
python variant3d\tools\godot_runner.py run --id p0gate01-run --timeout 180 -- --path variant3d --script res://tests/t_terrain_only.gd -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/test01_ladder2/smallmap64_terrain_only.png" --png "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/test01_ladder2/smallmap64_terrain_only.png"
```

**Honest result — expected failure, not a regression:**

- Runner: ticket **421**, `START (waited 157.30s)`, `END failed (run 14.14s)`, exit 1.
- Result JSON `variant3d/tests/results/t_terrain_only.json` (written by the
  atom): `passed=false`, `verdict=FAIL`, `capture_status=PASS`,
  `passes=20`, `fails=2`, `skipped_or_skip_capture=1`.
- **New gates fail as designed:**
  - `ground_mean_luma` — `mean_luma=13.271` vs strict `>=40` → FAIL.
  - `ground_max_luma` — `max_luma=27.413` (in-GPU) vs strict `>=100` → FAIL.
- **`full_width_dark_rows=720` is now `passed:null`,
  `status=RECORDED_NOT_APPLICABLE`** — the value is still recorded, no longer
  a source of a misleading "water" failure.
- **All 20 checks that previously passed still pass**, including every
  structural assertion: 1 surface, 4096 verts, 7938 tris, 4096 UV2,
  UV2.y hist `{0:4096}`, flat-promoted 0, `res_nodes=0`, below-water 0,
  water-tileblock 0, atlas `[16,8]` + shader `(16,8)`, 3 samplers bound,
  `shadow_enabled=0.0`, WaterPlane hidden, `capture_image`, `capture_saved`,
  `non_black_fraction=0.993736 > 0.9`.
- **`SCRIPT ERROR == 0` is MET**: `smallmap_capture.py scan-stderr` on
  `variant3d/.godot_queue/results/00000421_p0gate01-run/stderr.txt` returned
  `script_error_lines: 0`, `lines: []`. The stderr still carries the same
  pre-existing non-`SCRIPT ERROR` messages as TEST-RUN-02
  (`TEST_RUN_02_ladder_log.md:163-186`): the cosmetic string-format error,
  two camera bind-time `!is_inside_tree()`/`look_at` errors, and a 3-instance
  ObjectDB leak warning. No new error was introduced by this edit; only the
  GDScript line numbers shifted.
- **PNG re-measured read-only** with `smallmap_capture.py stats`: 987980 bytes,
  1280×720, `mean_rgb=[14.043,14.381,0.001]`, `mean_luma=13.271`,
  `full_width_dark_rows=720`, `non_black_fraction=0.992815` — still the
  near-black frame PIXEL-01 reviewed. (The validation job rewrote this PNG at
  the same path because "same args" was required; the re-measure confirms it
  is unchanged in character.)
- No second job was submitted; the failing row was not rerun. The only files
  written by the job (not hand-edited by me) are the atom's own result JSON and
  the temp PNG; both are runtime artifacts, not source changes. Other files
  showing as modified in `git status` belong to concurrently active builders.

**Interpretation:** FAIL is correct behaviour here. The new gate catches the
genuine visual defect that PIXEL-01 described; P0 cannot advance until the
terrain render brightness is actually fixed by its owning ticket. This atom
repair does **not** make P0 pass and does not claim it passes.

## 5. Explicit no-weakening statement

- No threshold was lowered. `non_black_fraction > 0.9` is unchanged.
- `full_width_dark_rows` was **not deleted**: its value is still computed and
  recorded (`_m["png_metrics"]`, check status `RECORDED_NOT_APPLICABLE`), so
  the 720-row observation remains auditable.
- The change replaces an **inapplicable** assertion with **two stricter,
  applicable** ones (`mean_luma>=40`, `max_luma>=100`), both of which fail the
  current frame. The atom is harder to pass, not easier.
- No terrain/shader/atlas/camera/config/fixture/harness code was touched to
  manufacture a green result. `TEST_MATRIX.md:67-68` is respected.

## 6. Open questions / UNVERIFIED

1. **Donor calibration is absent.** No donor GPU A/B frame exists; `>=40` and
   `>=100` are PORT APPROX. The 44.181 earlier-capture figure is a different
   composition, so it supports "not fitted to the defect" but not donor truth.
2. **Peak luma differs by source**: the atom's in-GPU peak is 27.413 vs
   PIXEL-01's 8-bit PNG peak 28.4. Consistent with float-vs-quantisation
   (cf. the ~0.00094 `non_black_fraction` delta in `METRIC_01:174-180`);
   immaterial to a `>=100` gate.
3. **Root cause of the darkness remains UNVERIFIED**: shader unshaded warm
   lighting + mask-alpha over a stub viewport vs capture exposure
   (`PIXEL-01:66-71`, `METRIC_01:252-255`). Not addressed here; owned by the
   terrain/fix ticket.
4. **Camera bind-time transform errors** remain a separate UNVERIFIED concern
   (`TEST_RUN_02_ladder_log.md:172-183,283-286`); unchanged by this edit.
5. **Whether `max_luma>=100` is too strict for a healthy *sky-free* ground
   frame** is unknowable without a donor/healthy capture; if a future healthy
   ground frame has a peak below 100 but mean≥40, this gate would need a
   separate evidence-backed ticket — it must not be relaxed here.
6. **T2/terrain+shore rows** still need their own water-band gate; the
   record-only treatment here applies to water-free P0 only.

## 7. Summary

- Reconciled: METRIC-01 correctly identifies the `full_width_dark_rows` gate
  as inapplicable to a water-free frame; PIXEL-01 correctly identifies the
  frame itself as a genuine near-black visual defect. Both verdicts stand.
- Edited only `variant3d/tests/t_terrain_only.gd` (backup first) plus this
  report. Structural assertions and `non_black_fraction` are unchanged.
- `full_width_dark_rows` is now a recorded diagnostic; two strict applicable
  gates were added: `ground_mean_luma >= 40` and `ground_max_luma >= 100`,
  both labelled **PORT APPROX — no donor GPU A/B exists**, with thresholds
  chosen to fail 13.271 / 27.413 rather than fit them.
- One windowed validation job (`p0gate01-run`, ticket 421) failed exactly as
  predicted: 20 passes, 2 new-gate failures, 1 recorded-not-applicable;
  `SCRIPT ERROR == 0`; all structural checks still pass; PNG still dark.
- No weakening; no green-washing; no code outside the two owned files edited.

---

*End of P0-GATE-01. One runner job only. No donor access, no donor-parity claim, no full gates or ladder run, no direct Godot invocation.*
