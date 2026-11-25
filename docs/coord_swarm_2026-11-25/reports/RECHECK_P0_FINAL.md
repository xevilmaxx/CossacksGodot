---
id: RECHECK-P0-FINAL
title: "Second-agent final re-check of the post-final-formula P0 capture (RECHECK-P0-FINAL-01)"
owner: "Second agent — independent re-checker, not the executing builder"
date: 2026-11-25
status: COMPLETE__READ_ONLY__NO_RUNNER_JOB__NO_CODE_EDIT
scope: "One new file only: docs/coord_swarm_2026-11-25/reports/RECHECK_P0_FINAL.md. No PNG/JSON/stderr/atom/shader/config/fixture/git edit, no Godot submission, no donor access, no ladder advance."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
protocol: "docs/coord_swarm_2026-11-25/CAPTURE_RECHECK.md (§1.2 commands, §2 P0 checklist, §3 image rules, §4 recording)"
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "PORT APPROX — internal consistency only. No donor GPU A/B frame exists; donor parity UNVERIFIED. This re-check never certifies donor parity."
capture_under_review: "ticket 504 / job id p0fresh01-capture; PNG mtime 2026-11-25T10:41:11.360Z; windowed (headless=false, display_server=Windows)"
shader_under_review: "variant3d/shaders/terrain_tileindex.gdshader:292-293, final LIGHT-02 formula normalize(vec3(P.x,P.y,P.z)); mtime 2026-11-25T09:53:34.897Z"
verdict: "P0 CONFIRMED_PASS on the port's own gates; the evidence gap that blocked RECHECK_P0.md is closed. COORD is cleared to decide P1; this worker does not advance the ladder."
---

# RECHECK-P0-FINAL — independent final re-check of the post-final-formula P0 capture

## 0. Mandate and boundary

Second-agent re-check of the **fresh, post-final-LIGHT-02-formula** P0 terrain-only
capture produced by ticket `504` (`p0fresh01-capture`). Task **RECHECK-P0-FINAL-01**
is read-only: no code edit and no runner job. Under `CAPTURE_RECHECK.md:36,82,91,234-240`
the visual reading and the atom's assertions are reported **separately**, no metric
overrides the image, and no donor parity is inferred. Per `:249`, only COORD advances
the ladder; this report records findings only. Everything below is `observed` unless
explicitly labelled `derived`, `inferred` or `UNVERIFIED`.

**Why this frame was the missing one:** `RECHECK_P0.md:12-13,173-177` established that
its only post-fix capture (ticket 441, `terraindarkfix-p0`, PNG mtime 09:52:12 UTC) was
taken under the stage-1 formula and **predated** the final shader edit at 09:53:34 UTC;
it therefore could not certify current code. `P0_FRESH_CAPTURE_01.md` closed that gap
with ticket 504. This report independently verifies that closure.

Sources read: `CAPTURE_RECHECK.md`, `reports/P0_FRESH_CAPTURE_01.md`,
`reports/RECHECK_P0.md`, `reports/P0_GATE_01.md`,
`variant3d/tests/results/t_terrain_only.json`, the PNG named in §1, plus (read-only)
the shader, runner stdout/stderr and `variant3d/tools/smallmap_capture.py` behaviour as
documented in `CAPTURE_RECHECK.md:62-83`. `frames.json` is **N/A** — P0 is not a motion
row (`CAPTURE_RECHECK.md:52`).

## 1. Artifacts opened (four-artifact set, CAPTURE_RECHECK.md §1.1)

| Artifact | Path | Observed state |
|---|---|---|
| Captured PNG (under re-check) | `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p0fresh01\p0_final_formula.png` | **2,129,263 B**, mtime **2026-11-25 10:41:11.360 UTC**, 1280×720; opened directly as an image (§4). Bytes/path match JSON `measured.png_metrics.bytes` / `png_path` / `png_path`. |
| Result JSON | `variant3d\tests\results\t_terrain_only.json` | **5,658 B**, mtime **2026-11-25 10:41:12.264 UTC**; `unix_ms=1795603272261.0` → 10:41:12.261 UTC (3 ms from file mtime, consistent). `verdict=PASS`, `passed=true`, `passes=22`, `fails=0`, `skipped_or_skip_capture=1`, `structural_ok=true`, `capture_status=PASS`, `headless=false`, `display_server=Windows`. |
| Runner stderr | `variant3d\.godot_queue\results\00000504_p0fresh01-capture\stderr.txt` | Exists; `script_error_lines: 0`, `lines: []` (§2). Non-`SCRIPT ERROR` diagnostics are recorded in §6. |
| Runner stdout | `variant3d\.godot_queue\results\00000504_p0fresh01-capture\stdout.txt` | Ends `T_TERRAIN_ONLY RESULT: PASS 22/22 evaluated, 1 skipped`; `RESULT_JSON` points at the JSON above. |
| Shader (timing/formula proof) | `variant3d\shaders\terrain_tileindex.gdshader` | mtime **2026-11-25 09:53:34.897 UTC**; lines 292-293 carry the final LIGHT-02 formula (§3.2). |

Capture-integrity prerequisites (`CAPTURE_RECHECK.md:56-60`): windowed run with
`--screenshot`/`--png` user args (JSON `headless=false`, `display_server=Windows`,
stdout 1280×720 SubViewport capture), PNG present and non-blank
(`capture_image`/`capture_saved` PASS, `save_png(...) err=0`), `SCRIPT ERROR == 0`,
and the fixed 64² shared harness (`harness_source=shared:res://tests/fixtures/_smallmap_harness.gd`).
All four are MET.

## 2. Command outputs (verbatim, read-only, Windows `python`)

Per `CAPTURE_RECHECK.md:62-83`, run from the repo root; **no runner job** was submitted.

```
python variant3d\tools\smallmap_capture.py stats "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p0fresh01\p0_final_formula.png"
```

```json
[
  {
    "path": "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\p0fresh01\\p0_final_formula.png",
    "bytes": 2129263,
    "width": 1280,
    "height": 720,
    "non_black_fraction": 1.0,
    "mean_rgb": [
      93.749,
      96.783,
      31.643
    ],
    "mean_luma": 91.432,
    "full_width_dark_rows": 0,
    "full_width_dark_row_fraction": 0.0
  }
]
NOTE: qualitative comparison only. No donor parity is claimed.
```

```
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\00000504_p0fresh01-capture\stderr.txt
```

```json
[
  {
    "path": "variant3d\\.godot_queue\\results\\00000504_p0fresh01-capture\\stderr.txt",
    "exists": true,
    "script_error_lines": 0,
    "lines": []
  }
]
```

`max_luma` is not printed by `stats`; it is taken from JSON
`measured.png_metrics.max_luma = 155.163005127713` (check detail prints `155.163`).
`mean_luma` full precision from JSON is `91.4320785333257`.

## 3. Measured values and independent checks

### 3.1 Exact metrics (all values reproduced by this re-check)

| Metric | Exact value | Gate / source |
|---|---:|---|
| `mean_luma` | **91.432** (JSON **91.4320785333257**) | `stats` + JSON; `ground_mean_luma >= 40` PASS |
| `max_luma` | **155.163** (JSON **155.163005127713**) | JSON only (`stats` omits it); `ground_max_luma >= 100` PASS |
| `non_black_fraction` | **1.0** | `stats` + JSON; `> 0.9` PASS |
| `full_width_dark_rows` | **0** (fraction **0.0**) | `stats` + JSON; `RECORDED_NOT_APPLICABLE`, `passed: null` — **N/A as gate**, no pass/fail contribution (`P0_GATE_01.md:74-77`) |
| `mean_rgb` | (93.749, 96.783, 31.643) | `stats` |
| PNG geometry / bytes | 1280×720 / 2,129,263 B | `stats` + JSON + filesystem |
| `SCRIPT ERROR` count | **0** (`lines: []`) | `scan-stderr` on ticket 504 stderr |

**Structural values from JSON (all `passed: true`):** `surface_count=1`,
`vertex_count=4096`, `triangle_count=7938`, `uv2_count=4096`,
`uv2_y_hist={"0":4096}` (only face mode 0, within {0,1,2}),
`flat_grid_promoted_cells=0`, `res_nodes_count=0`, `cells_below_water_level=0`,
`water_tileblock_cells=0`, `atlas_grid=[16.0,8.0]` = shader `(16.0, 8.0)`, 3 atlas
samplers bound, `shader_shadow_enabled="0.0"`, `water_plane_count=1` with
`water_3d_node_count=1` (hidden, not deleted). No assertion was weakened or bypassed:
the luma gates remain the strict `>=40` / `>=100` installed by `P0_GATE_01.md:81-90`,
and `full_width_dark_rows` remains a recorded diagnostic rather than a pass.

### 3.2 Capture postdates the final shader edit (the blocking gap)

Independently measured by filesystem mtime (UTC):

| File | mtime (UTC) |
|---|---|
| `variant3d/shaders/terrain_tileindex.gdshader` | 09:53:34.897 |
| PNG `p0_final_formula.png` | 10:41:11.360 |
| Result JSON | 10:41:12.264 |

`derived`: PNG − shader = **2,856.5 s ≈ 47 min 36.5 s** (the ~47 min 37 s claimed in
`P0_FRESH_CAPTURE_01.md:12,71-73`); JSON − shader = 2,857.4 s. The capture therefore
postdates the edit. The on-disk shader at lines 292-293 reads
`sun_world = normalize(vec3(donor_sun_position.x, donor_sun_position.y, donor_sun_position.z))`
with the LIGHT-02 §3.4/§5.4 "no /4, /2 compression" comment — the **final formula**,
not the stage-1 `vec3(x/4, y, z/2)`. The `RECHECK_P0.md:173-177` blocker (stage-1 frame
only; no final-formula capture) is **closed** for this ticket.

### 3.3 stdout / stderr identity

stdout confirms 28 check lines: 22 PASS lines plus the
`RECORDED_NOT_APPLICABLE` line for `full_width_dark_rows`, ending
`RESULT: PASS 22/22 evaluated, 1 skipped`; `ground_mean_luma=91.432` and
`ground_max_luma=155.163` both PASS. stderr contains no `SCRIPT ERROR` line; the
non-script messages are listed in §6 and are unchanged in kind from those recorded in
`RECHECK_P0.md:178` / `P0_FRESH_CAPTURE_01.md:168-172`.

## 4. Visual observation — independent of metrics (CAPTURE_RECHECK.md §3)

**observed (from opening the PNG, not from `stats`):** the entire 1280×720 frame, all
four corners included, is filled by a non-blank olive / yellow-green grass field with
fine, fairly even grain. No sky, horizon, water band, shoreline, tile grid,
checkerboard, seam or full-width dark band is visible; no tree, mine, unit or building
appears. Faint low-contrast darker mottling / streaking is discernible in the
centre-left and lower-middle areas, but it is diffuse, not grid-aligned and not a
structured object. The frame has visible tonal range and is plainly a ground-only
composition.

**derived:** the visual reading agrees with the numbers — a uniformly lit ground field
is consistent with `full_width_dark_rows=0`, `non_black_fraction=1.0`, hidden water
plane and empty `res_nodes`. Metrics and image corroborate each other; neither is
used as a substitute for the other.

**inferred / UNVERIFIED:** the faint mottling may be atlas grain or eye-plane texgen
artefact; no causal A/B was run here. Whether the olive hue, grain scale or tonal
distribution resembles a donor 64² terrain-only frame is **UNVERIFIED** — no donor
GPU A/B frame exists.

**Separation of fields:** §3 judges the atom's assertions; §4 reports what the pixels
show. The image shows **no visual defect that contradicts** P0's own gates, and the
earlier genuine near-black defect described by PIXEL-01 / `P0_GATE_01.md:35` is **not**
present in this frame (its 91.432 / 155.163 luma values clear the gates that the
13.271 / 27.413 defect frame failed). This is an observation about this capture only;
it is not a donor-parity statement.

## 5. P0 criterion checklist (CAPTURE_RECHECK.md §2, current atom assertions)

Exactly one of PASS / FAIL / N/A per criterion; all values refer to ticket 504.

| Criterion (atom check) | PASS | FAIL | N/A | Notes / source |
|---|:--:|:--:|:--:|---|
| `harness_stub_shape`, `terrain_module_api`, `camera_module_api`, `build_ok` | **PASS** | | | All four `passed=true` in JSON and PASS in stdout lines 4-7; `harness_source=shared:res://tests/fixtures/_smallmap_harness.gd`; fixed 64² harness reused. |
| Structural counts: `surface_count==1`, `vertex_count==4096`, `triangle_count==7938`, `uv2_count==4096` | **PASS** | | | JSON details `surfaces=1`, `vertices=4096`, `triangles=7938`, `UV2 entries=4096`; `measured` agrees. |
| `uv2_y_face_modes` (histogram recorded; values ∈{0,1,2}) | **PASS** | | | JSON `uv2_y_hist={"0":4096}`; only face mode 0, within {0,1,2}. |
| `flat_grid_promoted == 0` | **PASS** | | | JSON detail `promoted=0`; `measured.flat_grid_promoted_cells=0`. |
| `res_nodes_empty`, `no_water_cells == 0`, `no_water_tileblock == 0` | **PASS** | | | JSON details `res_nodes=0`, `0 cells below -0.25 m`, `BLK_WATER cells=0`. |
| `atlas_grid_manifest [16,8]`, `atlas_material_bound` (3 samplers), `shader_shadow_disabled` | **PASS** | | | JSON `stats.grid=[16.0,8.0]` = shader `(16.0,8.0)`; detail `tile/alpha/alphavert bound=true`; `shader_shadow_enabled="0.0"`. |
| `water_plane_hidden` (water hidden, not deleted) | **PASS** | | | JSON detail `WaterPlane nodes=1 all_hidden=true`; `water_plane_count=1`, `water_3d_node_count=1`. |
| `capture_image`, `capture_saved` | **PASS** | | | JSON `SubViewport texture 1280x720`; `save_png(...p0_final_formula.png) err=0`; PNG exists, 1280×720, 2,129,263 B, matches JSON bytes/path. Windowed (`headless=false`). |
| `non_black_fraction > 0.9` | **PASS** | | | `stats=1.0`; atom detail `non_black_fraction=1.0`. |
| Luma gates: `ground_mean_luma >= 40`, `ground_max_luma >= 100` | **PASS** | | | `mean_luma=91.432 >= 40`; `max_luma=155.163 >= 100`; both JSON `passed=true`. Strict PORT APPROX gates, unchanged since `P0_GATE_01.md`; no donor parity implied. |
| `full_width_dark_rows` = recorded diagnostic (`RECORDED_NOT_APPLICABLE`) | | | **N/A** | JSON `status=RECORDED_NOT_APPLICABLE`, `passed: null`; recorded value **0** (fraction 0.0) in this capture. No pass/fail contribution by design (`P0_GATE_01.md:74-77,143-145`); visual reading in §4. |
| `SCRIPT ERROR == 0`, windowed, JSON `verdict=PASS` | **PASS** | | | `script_error_lines: 0`, `lines: []` on ticket 504 stderr; `headless=false`, `display_server=Windows`; JSON `verdict=PASS`, `passed=true`; stdout `PASS 22/22 evaluated, 1 skipped`. Non-script diagnostics recorded in §6. |

**Counts: 11 PASS, 0 FAIL, 1 N/A (recorded-only).** No blank or `UNVERIFIED`
checklist row. No threshold was lowered, no assertion deleted, no row rerun for green.

## 6. Recorded non-`SCRIPT ERROR` diagnostics (not silently ignored)

Ticket 504 stderr is nonempty but contains **no** `SCRIPT ERROR` line: one cosmetic
`String formatting error` at `t_terrain_only.gd:429`, three image-load export warnings,
two camera bind-time `!is_inside_tree()` / `look_at` errors (`camera3d.gd:281-282`)
during `_initialize`, and one 3-instance ObjectDB leak warning at exit. These are
pre-existing diagnostics of the same kinds recorded in `RECHECK_P0.md:178` and
`P0_FRESH_CAPTURE_01.md:168-172`; none contributes to a P0 gate and none was
suppressed. They remain separate UNVERIFIED harness concerns, not the failing check
(`CAPTURE_RECHECK.md:262`).

## 7. Verdict

- **P0 CONFIRMED_PASS** — on the port's own, strict, applicable gates. All 11
  applicable criteria PASS, 0 FAIL, and `full_width_dark_rows` is correctly N/A /
  recorded-only (value 0). The capture is windowed and post-final-formula; the atom
  JSON is `PASS` (`22/22 evaluated, 1 skipped`, `fails=0`, `structural_ok=true`,
  `capture_status=PASS`), `SCRIPT ERROR == 0`, the exact metrics clear both hard luma
  gates and `non_black_fraction > 0.9`, and the independent image reading shows no
  contradicting visual defect.
- **Gap closure:** the evidence gap that made `RECHECK_P0.md` withhold ladder
  clearance is closed — the PNG (10:41:11.360 UTC) postdates the final LIGHT-02
  shader edit (09:53:34.897 UTC) by ~47 min 37 s, and the shader on disk carries the
  final `normalize(vec3(x,y,z))` formula.
- **Donor parity:** **UNVERIFIED — no donor parity claim.** All findings are
  `PORT APPROX — internal consistency only`; no donor GPU A/B frame exists
  (`TEST_MATRIX.md:34,73-74`; `P0_GATE_01.md:106-110`). `stats` itself prints
  `qualitative comparison only. No donor parity is claimed.`
- **Ladder:** **COORD may advance to P1 under the protocol** — i.e. the P0 row is
  cleared for COORD to authorise P1 (strict order P0→P1, one ticket per row,
  `TEST_MATRIX.md:57-59`; `CAPTURE_RECHECK.md:249`). This is a clearance finding,
  **not** an advancement: no row was submitted, no runner job launched, no next
  ticket opened, and FINAL remains COORD-only and last (`:250`). No ladder
  advancement was performed by this worker.

## 8. Open questions / UNVERIFIED

1. **Donor parity (F0) remains blocked:** no matched donor GPU A/B terrain frame
   exists; hue/grain/luma fidelity is UNVERIFIED (`P0_FRESH_CAPTURE_01.md:201-202`).
2. **Absolute luma / SubViewport readback:** private readback colour/tonemap behaviour
   remains UNVERIFIED (`P0_FRESH_CAPTURE_01.md:203-204`).
3. **Engine GL light binding:** `W=1` / `lsParallel` submission and `realpos`
   subtraction remain UNVERIFIED (`P0_FRESH_CAPTURE_01.md:205-206`); the final formula
   is confirmed present on disk and applied in this capture, not donor-validated.
4. **Non-script diagnostics:** format-string, camera bind-time and ObjectDB warnings
   persist; recorded, not gate-contributing (§6).
5. **Stale module sun vector:** `world3d_terrain.gd:121-126,138` may still carry the
   water-derived `SUN_LIGHTVEC`; read-only and out of scope here
   (`P0_FRESH_CAPTURE_01.md:209-211`).
6. **Luma gate calibration:** `>=40` / `>=100` remain PORT APPROX, not donor-derived
   (`P0_GATE_01.md:190-192,203-206`); no donor frame can confirm them.
7. **COORD decision:** whether to treat this re-check as the required second-agent
   review and authorise P1 is COORD's alone (`P0_FRESH_CAPTURE_01.md:212-214`;
   `CAPTURE_RECHECK.md:249`). This report does not decide it.

## 9. Summary

Independently re-checked the post-final-formula P0 capture (ticket 504,
`p0fresh01-capture`) from its PNG, result JSON, stdout/stderr and the two read-only
`smallmap_capture.py` commands. Both commands reproduced exactly:
`mean_luma=91.432` (JSON 91.4320785333257), `max_luma=155.163` (JSON
155.163005127713), `full_width_dark_rows=0` (fraction 0.0, recorded-only N/A),
`non_black_fraction=1.0`, `SCRIPT ERROR=0`; JSON `PASS` with `22/22 evaluated,
1 skipped` and all structural counts intact. The PNG (2,129,263 B, 10:41:11.360 UTC)
postdates the final shader edit (09:53:34.897 UTC) by ~47 min 37 s, and the shader
carries the final LIGHT-02 `normalize(vec3(x,y,z))` formula — closing the gap that
blocked the earlier re-check. Direct image inspection shows a non-blank, uniformly
olive fine-grained grass field with no dark band and no defect contradicting P0's
gates. Verdict: **P0 CONFIRMED_PASS** on PORT APPROX gates; donor parity UNVERIFIED;
COORD is cleared to decide P1, but no ladder advancement was made. Only this report
was written — no code, PNG, JSON, stderr, atom, shader, config, fixture, queue
mutation or direct Godot invocation.

---

*End of RECHECK-P0-FINAL. Second-agent record only: no runner job, no code/PNG/JSON/stderr edit, no donor access, no donor-parity claim, no row advancement by this worker.*
