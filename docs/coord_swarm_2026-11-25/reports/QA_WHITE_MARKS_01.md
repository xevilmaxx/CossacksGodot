---
id: QA-WHITE-MARKS-01
title: "Independent QA of RELIEF-VISUAL-01: reproduced white-marks fault and its source-level mechanism claims"
agent: "QA-WHITE-MARKS-01 (read-only verification subagent), coord swarm 2026-11-25"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB
scope: "One new file only: this report. No source/asset/config/test/shader/PNG/JSON/stderr/git edit; no Godot submission; no queue mutation."
exclusive_output: "docs/coord_swarm_2026-11-25/reports/QA_WHITE_MARKS_01.md"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "PORT APPROX — internal consistency only. No donor GPU A/B frame exists. No donor parity claim is made anywhere in this report."
concurrency_note: "Source was read before a concurrent BLANK-CHECK-01 edit replaced _is_blank() in variant3d/scripts/main.gd. Verification of :1932-1942 applies to the pre-fix state that produced ticket 532; the post-fix code is out of this QA's scope. RELIEF_LIVE_DIAG_01.md landed during this QA and was read afterwards."
verdict: "AGREE on all reproduced pixel statistics (one label misnomer noted); CONFIRMED on both source-mechanism claims — _is_blank() top-left one-sided comparison and the :1906-1913 PNG gate, scoped to the pre-fix source that produced ticket 532; CONFIRMED that the flag gates only the dump path while live boot calls _shape_stamp_relief(). White marks independently seen; no hills independently seen."
---

# QA WHITE MARKS 01 — independent verification of RELIEF-VISUAL-01

## 0. Mandate and boundary

Read-only QA of `RELIEF_VISUAL_01.md`. I did **not** re-run the capture, submit a
job, edit code, or mutate the queue. I re-read the original raw PNG from disk with
Python 3.14 / Pillow 12.1.1 / numpy 2.4.3, recomputed every published metric, read
the runner stdout/stderr directly, inspected the image visually, and traced the
claim paths in source. Statements are labelled **observed** (artifact bytes, tool
output, direct image read, literal source lines), **derived** (arithmetic or
control-flow consequence), **inferred** (attribution without a pixel-aligned
donor A/B) or **UNVERIFIED**. **No donor parity claim.**

Timing caveat (observed): `variant3d/scripts/main.gd` was read early in this QA
and showed the pre-fix `_is_blank()` at `:1932-1942`. A concurrent worker then
replaced that function (`git diff` shows a `BLANK-CHECK-01` rewrite using lit
fraction, luma range and colour count). My mechanism verdicts therefore describe
the **pre-fix code that ticket 532 actually ran under**; I did not re-run any job
against the new code. `RELIEF_LIVE_DIAG_01.md` also landed during the QA window;
I read it after my initial glob and did not rely on its claims as evidence.

## 1. Sources

| Kind | Source | Use |
|---|---|---|
| Owner report | `docs/coord_swarm_2026-11-25/reports/RELIEF_VISUAL_01.md` (all sections; stats at `:159-174`, tool output at `:180-214`, mechanism at `:111-123`) | Claims under test |
| Owner report | `docs/coord_swarm_2026-11-25/reports/TERRAIN_MARKS_01.md` (`:51-59`, `:99-124`) | Control-frame baseline and ranked hypotheses |
| Owner report | `docs/coord_swarm_2026-11-25/reports/RELIEF_LIVE_DIAG_01.md` | **NOT LANDED at initial read**; landed during this QA and was then read in full (`:85-119`, `:398-429` flag/live-path claims agree with my independent source trace; I used none of its claims as evidence) |
| Source | `variant3d/scripts/main.gd:1880-1942` (raw write `:1884-1885`, gate `:1906-1913`, `_is_blank()` `:1932-1942`) | Mechanism 1 and 2 |
| Source | `variant3d/scripts/main.gd:751-810` (`_dump_map()`; producer `:777-783`, flag `:788-790`, key emit `:802-803`) | Mechanism 3 |
| Source | `variant3d/scripts/config.gd:59` and `:448-449` | Flag default and accessor |
| Source | `variant3d/scripts/game.gd:870` (`_shape_stamp_relief()` definition), `:1088-1092` (unconditional call), `:1093-1104` (clamp) | Mechanism 3 |
| Source | `variant3d/scripts/world3d.gd:224-234` (`_has_height_source`), `:635-639` (`terrain.bind(game)` + `terrain.build()`) | Live boot height source |
| Source | `variant3d/scripts/world3d_terrain.gd:522-524` (dump marker reader), `:1189-1199` (consumer call) | Mechanism 3 boundary |
| Tool source | `variant3d/tools/smallmap_capture.py:21-39` | Exact formulas used by `stats` (Rec.709 luma, `rgb > 8`, dark rows `>90%` of row at luma `<20`) |
| Artifact | `%LOCALAPPDATA%\Temp\opencode\reliefvisual\relief_on.png.raw.png` (2,450,951 B) | Independent pixel re-read |
| Artifact | `variant3d/.godot_queue/results/00000532_reliefvisual01-boot/stdout.txt` (615 B), `stderr.txt` (4,606 B) | Blank message and diag values |
| Artifact | `%LOCALAPPDATA%\Temp\opencode\reliefenabl01_dump.json`, `variant3d/config.json` | Independent check of empty stamp array and flag state |

## 2. Independent measurements

All values below were recomputed from the original PNG, not copied from the
report. Luma is `0.2126R + 0.7152G + 0.0722B` on 0–1 channel values, matching
`smallmap_capture.py:25`; "near-white" is `min(R,G,B) > 180` on 0–255 bytes.

| Metric | Owner value | Independent re-read | Agreement |
|---|---:|---:|---|
| Image / pixel count | 1280×720 / 921,600 | 1280×720 / 921,600 | **AGREE** (observed) |
| File bytes | 2,450,951 | 2,450,951 | **AGREE** (observed) |
| Near-white pixels, `min(R,G,B)>180` | 44,381 | 44,381 | **AGREE** (observed) |
| Near-white fraction | 4.8156 % | 0.04815647 → 4.8156 % | **AGREE** (observed) |
| Near-white bbox | (0,0)–(1279,719) | (0,0)–(1279,719) | **AGREE** (observed) |
| Pixels with luma > 180 | 122,932 | 122,932 (Rec.709) | **AGREE** (observed). Rec.601 gives 119,879 — the owner used the tool's Rec.709 formula, as claimed |
| Luma min / max / mean | 0.0 / 253.845 / 115.039 | 0.0 / 253.845 / 115.039 | **AGREE** (observed) |
| `non_black_fraction` | 0.999145 | 0.999145 | **AGREE** (observed) |
| `mean_rgb` | [112.43, 119.612, 77.204] | [112.43, 119.612, 77.204] | **AGREE** (observed) |
| `full_width_dark_rows` | 0 | 0 | **AGREE** (observed) |
| `p00` (diag) | (0.7137, 0.9137, 1.0, 1.0), "≈0.88 luminance" | PNG (0,0) = (182,233,255)/255; Rec.709 luma 0.877435 | **AGREE** (observed) |
| `pcenter` (diag) | (0.3451, 0.3608, 0.1137, 1.0) | PNG (640,360) = (88,92,29)/255 | **AGREE** (observed) |
| Near-white quadrant counts | `[6390,4039,3787,3797]` / `[1753,1162,2216,4051]` / `[47,0,2995,2289]` / `[3650,2967,1770,3468]` | Exactly these 16 numbers | **PARTIAL** — values agree exactly, but they are a **4-column × 4-row** grid (16 cells), while `RELIEF_VISUAL_01.md:167` labels them "4×3". A true 4×3 grid yields `[7443,4579,4597,4888] / [700,622,3536,4385] / [3697,2967,2635,4332]`. Label defect only; no numeric error |
| Blank message in stderr | `stderr.txt:60` | Line 60: `screenshot: windowed 3D capture is blank; no CPU fallback (visual parity UNVERIFIED)` | **AGREE** (observed) |
| `SCRIPT ERROR` count | 0 | 0 across all 68 stderr lines (direct read) | **AGREE** (observed) |
| Requested final PNG absent; only raw sidecar present | yes | Directory listing contains only `relief_on.png.raw.png` | **AGREE** (observed) |

Visual re-read (observed, my own direct image read): olive, flat-looking ground
with pale stepped/concentric grid-aligned bands over the left/top/right/bottom
edges, a cyan sky strip at the very top, water patches, conifer cluster and
buildings at top-right. **No rounded hill silhouette, ridge or elevation
self-shadowing appears.** This independently matches the owner's
`RELIEF_VISUAL_01.md §3.1`; the *cause* of the marks is not established by my
visual read (see §3.4).

Baseline cross-check (derived, from `TERRAIN_MARKS_01.md:55-59`): the P0 control
had zero pixels above Rec.601 luma 160 and mean 88.447; this frame has 122,932
above Rec.709 luma 180 and mean 115.039. The two reports use different luma
formulas, so only the order-of-magnitude contrast is sound, not an exact delta.

## 3. Mechanism verification

### 3.1 `_is_blank()` sky-blue comparison — CONFIRMED

`path:line`: `variant3d/scripts/main.gd:1932-1942`.
- `:1937` `var first := img.get_pixel(0, 0)` — the reference is the **top-left**
  pixel only; no other reference pixel or global max is used.
- `:1938-1939` the sampling lattice is `step_x = 1280/64 = 20`, `step_y = 720/64 = 11`
  (64×64 cap at `:1935-1936`), i.e. 4,224 samples.
- `:1940` `if img.get_pixel(x,y).get_luminance() - first.get_luminance() > 0.02: return false` —
  a **one-sided** test: a sample must be *brighter* than the corner; darker pixels
  are treated as identical to blank.

Independent arithmetic (observed + derived):
- `first` luma (Rec.709, 0–1) = **0.877435**; sky-blue corner is near the top of
  the possible range.
- On the exact 4,224-sample lattice, **0 pixels** exceed `first + 0.02`; largest
  sampled excess is only **0.003942** at (20,0), pixel (180,235,255). The check is
  robust to formula choice: Rec.601, plain channel average and sRGB→linear Rec.709
  also give 0 hits.
- Over the **whole frame** only **36 / 921,600** pixels exceed `first + 0.02`
  (global max luma 0.99547, excess 0.118035). Those few pixels are not on the
  20×11 lattice, which is why the detector returns `true`.

Methodological note (derived): the `0.02` threshold is in Godot `Color` 0–1
units. Comparing 0–255 luma values against `0.02` (a scaling mistake) would
spuriously report 136 "brighter" samples; with correct units the count is 0.

Verdict: **CONFIRMED (pre-fix source state)** — the source structure and the
image-dependent arithmetic both hold: a bright sky-blue top-left pixel plus a
one-sided threshold makes this non-blank frame classify as blank. This is the
state that produced ticket 532. A concurrent `BLANK-CHECK-01` edit replaced
`_is_blank()` after my read (observed in `git diff`); the new function is not
covered by this QA and no claim is made about whether it would accept the frame.

### 3.2 PNG write gate — CONFIRMED

`path:line`: `variant3d/scripts/main.gd:1906-1913`.
- `:1906` condition `if img == null or img.is_empty() or (render_mode == "3d" and _is_blank(img)):`
- `:1910-1911` printerr with the exact text found at `stderr.txt:60`.
- `:1912` `_quit(1)`; `:1913` `return`.
- The final write `out2 := _write_bytes(screenshot_path, img)` is at **`:1916`**,
  i.e. strictly after and unreachable from the blank branch.
- The raw sidecar is written earlier at `:1884-1885`, which explains why
  `relief_on.png.raw.png` survives while `relief_on.png` is absent (observed).

Verdict: **CONFIRMED (pre-fix source state)** — the gate blocks final PNG writing
and forces exit 1. The concurrent `BLANK-CHECK-01` edit changed only
`_is_blank()`'s body, not this `:1906-1913` gate, as seen in `git diff`.

### 3.3 "Flag gates only dump path; live boot uses `_shape_stamp_relief()`" — CONFIRMED

`path:line` evidence, traced from source rather than accepted from a report:
- `variant3d/scripts/config.gd:59` default `false`; `:448-449` accessor
  `flag("features.terrain.relief_stamps", false)`.
- `variant3d/scripts/main.gd:751` `_dump_map()`; `:788-790` is the **only**
  runtime read of the accessor, inside that function; `:802-803` adds
  `dump["relief_stamps"]` only when enabled. Repo-wide grep of `*.gd` found no
  other use of the accessor or `relief_enabled`.
- `variant3d/scripts/world3d_terrain.gd:524` `dump.get("relief_stamps", null)` and
  `:1193` `_apply_relief_stamps_from_dump(dump, height, w, h)` — the only consumer,
  reached from the dump path.
- `variant3d/scripts/game.gd:870` defines `_shape_stamp_relief()`; `:1092` calls it
  unconditionally in `_gen_base()` (no enclosing flag check at `:1088-1092`;
  stderr backtrace independently shows `_gen_base` at `game.gd:1090`). The
  function body contains no `relief_stamps` flag reference (repo-wide grep).
- `variant3d/scripts/world3d.gd:224-234` accepts a live `PackedFloat32Array
  g.height` as a height source; `:637-639` `terrain.bind(game)` then
  `terrain.build()`. Thus a live boot's terrain is shaped by `game.height`,
  which was produced by `_shape_stamp_relief()`, not by the dump marker.

Independent artifact check: `reliefenabl01_dump.json` (flag-on job) has
`seed=20261113`, `map_w=map_h=64`, key `relief_stamps` present with `[]`
(length 0), and `variant3d/config.json` currently has
`features.terrain.relief_stamps: true` — agreeing with the owner's
`RELIEF_VISUAL_01.md:236` "empty stamp array" statement. This is a separate
dump job, not the capture.

Verdict: **CONFIRMED** for the source claim. Derived consequence: this capture
cannot be evidence that donor-grid relief fired.

### 3.4 Attribution of the marks — INFERRED / UNVERIFIED by this QA

The tile-id colour explanation (`TERRAIN_MARKS_01.md:100` rank 2) remains a
plausible attribution; my re-read confirms a *visual match* (flat, grid-aligned,
concentric/stepped pale bands) but I ran no dump histogram, no flag-off A/B, and
no donor comparison. I neither confirm nor refute that mechanism here. No parity
claim.

## 4. Verdict

1. **Pixel reproduction: AGREE.** Every owner statistic reproduces exactly from
   the raw PNG with an independent Pillow/numpy read. One cosmetic defect: the
   `RELIEF_VISUAL_01.md:167` "4×3" label describes a 16-value 4×4 grid.
2. **Fault status: CONFIRMED (observed + derived).** Ticket 532 exit 1, stderr
   blank message, missing final PNG, surviving raw sidecar, zero `SCRIPT ERROR`.
3. **Mechanism 1 (`main.gd:1932-1942`, pre-fix): CONFIRMED** — top-left-only,
   one-sided `>0.02` luma comparison; 0/4,224 sampled pixels brighter; only
   36/921,600 in the whole frame, none on the lattice. A concurrent edit replaced
   this function after my read; the post-fix detector is outside this QA.
4. **Mechanism 2 (`main.gd:1906-1913`): CONFIRMED** — blank branch precedes and
   bypasses the final PNG write at `:1916`; unchanged by the concurrent edit.
5. **Mechanism 3 (flag scope): CONFIRMED** — accessor read only in `_dump_map()`;
   live boot calls `_shape_stamp_relief()` at `game.gd:1092` and builds terrain
   from `game.height`.
6. **White marks / no hills: independently observed** in the raw frame.
7. **Relief mechanism, `relief_grid.applied`, flag-off A/B and donor parity:
   UNVERIFIED.** No parity claim is made. Overall: the owner's reproduced fault
   and both structural mechanism claims survive independent verification.

## 5. Open questions

1. `RELIEF_LIVE_DIAG_01.md` landed during this QA; its live-path claims were
   checked against my own source trace, but its tile-art attribution remains
   inferred (it had no report frame at its write time).
2. Would a corrected blank detector (e.g. global-range or two-sided comparison)
   write the final PNG for this same frame? UNVERIFIED — no re-run was permitted.
3. Does `relief_grid.applied > 0` for any seed/preset that actually places a
   `plt2` marker? UNVERIFIED; this QA saw `[]` for seed 20261113 only.
4. Which mechanism literally paints the pale bands? INFERRED (tile-id/colour
   preferred by `TERRAIN_MARKS_01.md`), not independently established here.
5. The "no hills" verdict is from a single fixed-camera frame; no flag-on/off
   pixel A/B and no donor GPU frame exist. No parity of hue, grain, silhouette
   or luma is claimed.

## 6. Summary

Independent re-read of `relief_on.png.raw.png` reproduces the owner's numbers
exactly (44,381 near-white pixels = 4.8156 %; Rec.709 luma mean 115.039, max
253.845; 122,932 pixels above 180; non-black 0.999145; zero full-width dark
rows), with a single mislabel: the 16 quadrant figures in
`RELIEF_VISUAL_01.md:167` are a 4×4 grid, not 4×3. Visual inspection confirms
prominent pale stepped/concentric marks and no visible relief. Source tracing
confirms both mechanism claims with `path:line`, scoped to the **pre-fix source
that ticket 532 ran under**: `main.gd:1932-1942` compared sampled luma only
against the bright top-left pixel with a one-sided `>0.02` test (0 of 4,224
sampled pixels qualified; 36 of 921,600 do, none sampled), and
`main.gd:1906-1913` used that result to reject the frame and exit 1 before the
final PNG write at `:1916`; the raw sidecar at `:1884-1885` survives. A
concurrent `BLANK-CHECK-01` edit replaced `_is_blank()` after my read; no claim
is made here about the new detector. It is also
confirmed from source that `features.terrain.relief_stamps` is read only in
`_dump_map()` (`main.gd:788-803`), while the live boot calls
`_shape_stamp_relief()` unconditionally (`game.gd:1092`) and builds from
`game.height` (`world3d.gd:637-639`). **No source file was edited, no runner job
was submitted, and no donor parity claim is made.**

---

*End of QA WHITE MARKS 01. Read-only verification; one new report file; no code, config, artifact or queue change.*
