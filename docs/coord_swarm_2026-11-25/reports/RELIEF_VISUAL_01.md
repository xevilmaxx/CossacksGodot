---
id: RELIEF-VISUAL-01
title: "Real generated 64² windowed capture with relief stamps ON — white marks reproduced, no visible hill relief; job failed on a blank-detector false positive"
agent: "RELIEF-VISUAL-01 (capture worker / read-only on code), coord swarm 2026-11-25"
date: 2026-11-25
status: DELIVERED__JOB_FAILED__RAW_GPU_FRAME_INSPECTED__NO_CODE_EDIT
scope: "One new file only: this report. No source/asset/config/test/shader/git edit; no queue mutation; exactly ONE variant-runner job submitted (unique id). Temp capture artifacts under %LOCALAPPDATA%\\Temp\\opencode\\reliefvisual\\ only."
exclusive_output: "docs/coord_swarm_2026-11-25/reports/RELIEF_VISUAL_01.md"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
job:
  id: reliefvisual01-boot
  ticket: 532
  status: failed
  exit: 1
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROX]
parity_guard: "PORT APPROX — internal consistency only. No donor GPU A/B frame exists. No donor parity is claimed anywhere in this report."
verdict: "STILL FLAT / RELIEF NOT VISIBLE; the owner's white-marks symptom IS REPRODUCED in a real generated 64² map. Donor-grid relief path UNVERIFIED for this seed (RELIEF-ENABLE-01 ticket 527: dump marker key present but array empty). Job marked failed by a blank-detector false positive; final PNG absent, raw GPU sidecar inspected."
---

# RELIEF VISUAL 01 — real 64² capture with relief stamps ON

## 0. Mandate and boundary

One windowed capture of a **real generated 64×64 map** with the relief opt-in on,
then a direct image read and the read-only tooling (`smallmap_capture.py stats`,
`scan-stderr`) to compare the result with the white-marks symptom. Every statement
below is labelled **observed** (literal artifact bytes, tool output or direct
image read), **derived** (control-flow / arithmetic consequence), **inferred**
(attribution without a pixel-aligned donor A/B) or **UNVERIFIED**. No donor frame
exists; **no donor parity claim** is made. Code was read only; nothing was edited
and the queue was not mutated (no reset/ack/cancel; only my own single job).

Sources read: `reports/TERRAIN_MARKS_01.md`, `reports/RELIEF_ENABLE_01.md`,
`reports/QA_RELIEF_DUMP_01.md`, `reports/QA_RELIEF_ON_01.md`,
`variant3d/tests/fixtures/small_map_64.json`, `variant3d/config.json`,
`variant3d/scripts/main.gd` (`--screenshot`/`--config`/`--timeout` parsing at
`:1257-1341`, capture code at `:1849-1942`), `variant3d/scripts/world3d.gd`
(`:224-234`), `variant3d/scripts/game.gd` (`:870-914`, `:1092`),
`docs/coord_swarm_2026-11-25/TEST_MATRIX.md` and `RUN_GUIDE.md`, and
`docs/coord_swarm_2026-11-24/reports/TERRAIN_SMALL_maps.md` for the exact proven
capture-argument form.

---

## 1. Config flag check (observed)

`variant3d/config.json` carries `features.terrain.relief_stamps` = JSON `true`.
At submission it was at `:16-20`; at report time the same key is at `:29`, inside
a larger committed `features` block written by other workers (three `step`
commits touch this file; `git diff -- variant3d/config.json` is now empty). The
flag remained `true` before, during and after this job. **No config edit was made
by this worker.** `config.gd:448-449` resolves the typed getter to that value
instead of the `false` default (`config.gd:59`), so the flag-on condition is
met. `RELIEF_ENABLE_01.md` describes it as one additive key at its write time and
records `QA_RELIEF_ON_01.md` as config-level PASS; `QA_RELIEF_DUMP_01.md` is
already stale on two points (it calls the owner report absent and the dump
absent), while `RELIEF_ENABLE_01.md` ticket 527 later produced the dump.

**Critical scope limit (derived, from source):** the flag gates only the
`--dump-map` marker (`main.gd:788-803`: `if relief_enabled: dump["relief_stamps"]
= relief_stamps`). A normal boot builds terrain from the live `game.height`
(`world3d.gd:224-234`), shaped by `game.gd:_shape_stamp_relief()` called
unconditionally at `game.gd:1092`. This capture therefore shows the **live port
terrain**, not a dump fed with donor-grid stamps, even though the flag is on.

---

## 2. Command and job data

Exact command (repo root, Windows `python`, variant runner only, unique id):

```bat
python variant3d\tools\godot_runner.py run --id reliefvisual01-boot --timeout 300 -- ^
  --path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/reliefvisual/relief_on.png" ^
  --screenshot-frames 10 ^
  --config "C:/Users/Maxym.Oboyshev/Documents/Craft Anything/cossacks-3-3/variant3d/tests/fixtures/small_map_64.json" ^
  --timeout 120
```

Argument form follows `TERRAIN_SMALL_maps.md:63-66` (ticket 308, the proven
64² windowed capture): no `--headless`, `--screenshot` as a user arg after the
second `--`, `--screenshot-frames 10`, absolute fixture path, main's own
`--timeout 120` watchdog (`main.gd:1334-1337`). The fixture overrides only
map dimensions to 64×64; seed 20261113 and `render_mode=3d` are inherited
(`small_map_64.json:10-15`; `TERRAIN_SMALL_maps.md §1-2`).

Runner metadata — `variant3d/.godot_queue/results/00000532.json` (observed):

| Field | Value |
|---|---|
| Ticket / id | **532** / `reliefvisual01-boot` |
| Status / exit | **failed** / **1** |
| Wait / run | **482.622 s** / **56.269 s** |
| Runner timeout | 300 s (main watchdog arg 120 s) |
| stdout | `00000532_reliefvisual01-boot/stdout.txt`, 615 B |
| stderr | `00000532_reliefvisual01-boot/stderr.txt`, 4,606 B |
| Queue at submission | `now_serving=524`, `next_ticket=529`, 4 pending, lock held ~143 s |
| Requested PNG | `.../reliefvisual/relief_on.png` — **NOT written** |
| Sidecar written | `.../reliefvisual/relief_on.png.raw.png`, 2,450,951 B, 11/25/2026 12:22:01 PM |

`stdout` (observed, notable lines):

```
screenshot raw capture: C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/reliefvisual/relief_on.png.raw.png
screenshot capture diag: viewport=Screenshot3DViewport image=1280x720 p00=(0.7137, 0.9137, 1.0, 1.0) pcenter=(0.3451, 0.3608, 0.1137, 1.0) camera_current=true world_parent=Screenshot3DViewport camera_pos=(21.98215, 58.0, 70.25505) target=(85.98215, 41.43565)
```

`stderr` line 60 (observed): `screenshot: windowed 3D capture is blank; no CPU
fallback (visual parity UNVERIFIED)`.

**Derived cause of the `failed` status — blank-detector false positive, not a
queue race:** `_is_blank()` (`main.gd:1932-1942`) samples pixels and compares each
luminance only to the **top-left** pixel's luminance, with a one-sided
`> 0.02` threshold. Here `p00` is bright sky-blue (`≈0.88` luminance) while the
ground is olive (`pcenter≈(0.345,0.361,0.114)`), so no sampled pixel is *brighter*
than `p00` and the non-blank frame is classified as blank; `main.gd:1906-1913`
then refuses to write the final PNG and calls `_quit(1)`. The raw sidecar is
written first (`:1884-1885`) and survives. The remaining stderr lines are the
already-documented benign class: `T-MINES-FIX: no open coal site near start
(5,60)` (`pattern_gen.gd:676`), three "Loaded resource as image file" warnings
(atlas/alpha/alphavert), the flat-root morph PORT APPROX warning, a
`mill_rotor.png` image-load warning, and exit-time RID/ObjectDB/resource leak
messages (`RUN_GUIDE.md §4`). **No retry was submitted.**

---

## 3. Image observations — raw GPU frame (`relief_on.png.raw.png`)

Artifact opened with the `read` tool: 1280×720, real GPU frame from
`Screenshot3DViewport` (diag above confirms `camera_current=true`,
`world_parent=Screenshot3DViewport`). This is a **real generated map**, not the
deliberately flat P0 harness control of `TERRAIN_MARKS_01.md`.

### 3.1 Direct visual read (observed)

- The frame is a top-down/steep-oblique view of an olive-green grass field with
  fine grain; the whole map is filled (no black void). A blue/cyan sky strip runs
  along the very top edge (y≈0–15), and cyan water patches appear at the right
  (≈x1050–1280, y≈420–470), bottom-right (≈x850–1280, y≈610–720) and bottom-left
  (≈x0–95, y≈560–600).
- **The white-marks symptom is present, prominently.** Bright, almost-white and
  pale-tan **stepped, grid-aligned bands with concentric/nested outlines** cover:
  - top-left ≈x0–440, y0–330 (dense stepped maze pattern);
  - right half ≈x700–1280, y0–500, with the largest concentric patch
    ≈x1000–1280, y≈230–320 and an isolated pale hexagonal ring ≈x1080–1180,
    y≈240–290; another isolated ring ≈x250–330, y≈20–80;
  - bottom-left ≈x200–470, y≈540–720 and bottom-right ≈x850–1280, y≈530–720.
- Between those bands, large olive areas remain: centre-left ≈x0–700, y≈300–540
  with slightly darker mottling ≈x430–670, y≈300–520; a dark conifer cluster
  ≈x450–670, y≈140–280 and sparse trees ≈x1150–1200, y≈390–470.
- Buildings are visible top-right ≈x830–1100, y≈0–170 (a dark-roof town hall and
  two thatched huts), plus a small reddish cluster ≈x880–940, y≈245–280.
- **No hills are visible.** There is no rounded elevation silhouette, ridge,
  slope shading or self-shadowing anywhere. The bright patches are flat-looking,
  repeatable tile/step patterns (transition art), not terrain relief. The
  camera is at height 58 m looking toward ≈(86,41), yet the ground reads as a
  flat board with art bands and water fields.

### 3.2 Quantitative read-only pixel scan (observed; inline PIL/numpy, no file written)

| Metric | Value |
|---|---:|
| Near-white pixels (min(R,G,B) > 180) | **44,381** = **4.8156 %** of 921,600 |
| Near-white bbox | (0, 0)–(1279, 719) — frame-wide, not a single isolated patch |
| Pixels with luma > 180 | **122,932** |
| Luma min / max / mean | **0.0 / 253.845 / 115.039** |
| 4×3 quadrant near-white counts (row-major) | `[6390, 4039, 3787, 3797]` / `[1753, 1162, 2216, 4051]` / `[47, 0, 2995, 2289]` / `[3650, 2967, 1770, 3468]` |

The quadrant distribution matches the visual read: heaviest white in the
top-left and right/bottom-right, almost none in the middle-left (row 3 columns
1–2). Compare `TERRAIN_MARKS_01.md:55-59`: its flat P0 control had **zero**
pixels above luma 160 and mean luma 88.447 — the present frame has 122,932
pixels above 180 and mean luma 115.039. **The owner's symptom is reproduced in a
real generated 64² map, and is absent from the flat P0 control.**

---

## 4. Tool results (exact)

`python variant3d\tools\smallmap_capture.py stats
"C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/reliefvisual/relief_on.png.raw.png"`
(observed output, reformatted only by wrapping the JSON):

```json
[
  {
    "path": "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\reliefvisual\\relief_on.png.raw.png",
    "bytes": 2450951,
    "width": 1280,
    "height": 720,
    "non_black_fraction": 0.999145,
    "mean_rgb": [112.43, 119.612, 77.204],
    "mean_luma": 115.039,
    "full_width_dark_rows": 0,
    "full_width_dark_row_fraction": 0.0
  }
]
```
`NOTE: qualitative comparison only. No donor parity is claimed.`

`python variant3d\tools\smallmap_capture.py scan-stderr
"variant3d/.godot_queue/results/00000532_reliefvisual01-boot/stderr.txt"`
(observed output):

```json
[
  {
    "path": "variant3d\\.godot_queue\\results\\00000532_reliefvisual01-boot\\stderr.txt",
    "exists": true,
    "script_error_lines": 0,
    "lines": []
  }
]
```

**`SCRIPT ERROR` count = 0.** No `relief_grid` stats were obtainable from this
capture: `stats["relief_grid"]` is produced by `world3d_terrain.build()`
(`world3d_terrain.gd:1441-1458`) and is not in the screenshot stdout/stderr, and
the flag-on dump (`RELIEF_ENABLE_01.md:126-149`) has an **empty** `relief_stamps`
array for seed 20261113. `stats.relief_grid.applied` remains UNMEASURED.

---

## 5. Verdict

**STILL FLAT / RELIEF NOT VISIBLE; WHITE MARKS REPRODUCED.**

- **observed:** a real 64² generated-map GPU frame was obtained (as the raw
  sidecar) with the relief flag set to `true` in the loaded config. It contains
  abundant bright stepped/grid-aligned marks (4.8156 % near-white pixels,
  frame-wide) and **no visible hills, ridges or elevation shading**.
- **observed:** the runner marked the job `failed` (ticket 532, exit 1) because
  `_is_blank()` misclassified the non-blank frame; the requested `relief_on.png`
  was not written. `SCRIPT ERROR == 0`, so this is not a script fault.
- **derived:** the flag does not feed the live boot's height grid; and the
  flag-on dump for this seed carries `relief_stamps = []`
  (`RELIEF_ENABLE_01.md:130-142`). Therefore this frame **cannot** be evidence
  that donor-grid relief fired — any relief present is the port's own analytic
  `_shape_stamp_relief()` path (`game.gd:870-914,1092`).
- **inferred (port-only):** the visual character of the marks — flat, stepped,
  tile-grid-aligned, concentric — favors `TERRAIN_MARKS_01.md`'s rank-2 tile-id
  colour explanation over height-driven cliff art or donor relief. This is an
  attribution without a donor A/B, not a proven mechanism.
- **UNVERIFIED:** donor-grid relief application (`relief_grid.applied > 0`), a
  flag-on/flag-off pixel A/B, and any donor parity of hue, grain, silhouette or
  luma. **No donor parity claim.** No verdict of "relief visible" is supportable.

---

## 6. Open questions (UNVERIFIED — do not guess)

1. Would the marks disappear or change under a flag-off boot with the same seed,
   fixture and camera? Only a controlled A/B (two successful captures) answers
   this; this job produced one frame and no flag-off counterpart.
2. Does any seed/preset place a non-empty `plt2` stamp array, and would a dump
   with such a marker fed into `world3d_terrain.build()` yield
   `relief_grid.applied > 0` and a height-range shift? Ticket 527 says `[]` for
   seed 20261113; the sweep remains open (`RELIEF_ENABLE_01.md` Q2/Q3).
3. Would a `plt2` patch read as a rounded hill or as another flat pale "mark",
   given 8×10 block means and the +2.964 cap (`TERRAIN_MARKS_01.md:101,215`)?
4. Will `_is_blank()` be corrected so a bright-sky corner cannot reject a valid
   frame and write the final PNG? Its current one-sided comparison
   (`main.gd:1932-1942`) is the observed cause of this job's `failed` status.
   No fix was attempted here (read-only mandate).
5. Is `screenshot_focus=relief` (`main.gd:71,182,1115-1116,1131-1132,1187-1203`)
   better suited to frame a relief patch in a future capture? Not used here.
6. Donor parity remains blocked on a donor GPU A/B frame; none exists.

---

## 7. Summary

One unique-id windowed variant-runner job (`reliefvisual01-boot`, ticket **532**)
captured a real generated 64×64 map with `features.terrain.relief_stamps = true`.
After a 482.62 s FIFO wait it ran 56.27 s and exited **1**: `main.gd`'s blank
detector compared sampled pixels against a bright sky-blue corner and refused to
write the final `relief_on.png`, although it had already written a valid raw GPU
sidecar. Direct inspection of that sidecar (1280×720, mean luma 115.039,
non-black 0.999145, 0 dark rows) shows the **white-marks symptom reproduced** —
pale, stepped, grid-aligned concentric bands across the top-left, right and
bottom of the frame (44,381 near-white pixels, 4.8156 %) — and **no visible
hills or relief shading**. `SCRIPT ERROR == 0`; `relief_grid.applied` is not
exposed by this path and remains unmeasured, and the flag-on dump for this seed
has an empty stamp array. Verdict: **still flat / relief not visible; white
marks reproduced; donor-grid relief UNVERIFIED; PORT APPROXIMATION only, no
donor parity claim.** No source file was edited, no queue action other than the
single capture submission was taken, and no retry was submitted.

---

*End of RELIEF VISUAL 01. Read-only on code; one runner job; no donor access, no ladder advancement, no donor parity claim.*
