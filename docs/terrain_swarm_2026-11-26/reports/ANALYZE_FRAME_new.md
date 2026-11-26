---
id: ANALYZE-FRAME
wave: DONOR-TERRAIN VISUAL WAVE (2026-11-26)
role: WORKER ANALYZE-FRAME — SECONDARY image analysis of the NEW post-fix capture
owner_file: docs/terrain_swarm_2026-11-26/reports/ANALYZE_FRAME_new.md
reports_written: [docs/terrain_swarm_2026-11-26/reports/ANALYZE_FRAME_new.md]
files_edited: []
date: 2026-11-26
status: DELIVERED__ONE_REPORT_ONLY__NO_CODE_GODOT_GIT__NO_DONOR_EXECUTION
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_claim: false
parity_status: UNVERIFIED
parity_guard: "No donor GPU A/B frame exists. Stills are third-party, unknown build/camera/compression and are used for direction bands only. Nothing here certifies donor fidelity or a gate pass."
scope_guard: "Read-only on all images, capture.json and governing reports. No source/shader/asset/config/test/gate edit; no Godot job; no donor binary executed; no git operation. Exactly one repository file written: this report. Metric scripts and crops were written only to %TEMP%\\opencode."
---

# ANALYZE-FRAME — the NEW frame after height/props/shader fixes

> **PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED.** No donor
> GPU A/B frame exists. Every "direction" statement below is a within-candidate read
> against a third-party still band, never a match score, never a gate verdict.

## 0. Executive result

1. **[O] The three new images are admissible nonblank 1280×720 captures.** Exact
   `main.gd:1941-1977` blank check: `frame_0000` lit `.9981` / Y-range `.5767` / 431
   colours; `frame_0012` `.9998 / .5753 / 395`; `cap_donor_240f` `.9962 / .6279 / 451`.
   The motion runner reports 17/17 checks passed, 24/24 distinct nonblank GPU frames,
   no CPU/root fallback, `parity.claim=NONE`, `parity.status=UNVERIFIED`
   (`video/donor_240/capture.json`).
2. **[D] The height and prop/shader fixes are real and measurable.** Runtime telemetry
   records a **240×240 grid (57,600 cells)** instead of W03's selected 320² mask grid,
   `height_max_m=+3.613412` (relief stamps now applied; matches W03's corrected `plt2`
   max 3.6134), `props_applied=true`, 32/32 stamp conversions, and cell-centre UV
   (`((x+0.5)/w,(z+0.5)/h)`) instead of the old eye-plane `fract` default. In the images:
   a textured building at `[745,5,1080,325]` in 240f, textured boulder clusters at
   `[50,185,320,395]` in frame_0000, and a large relief body at `[180,0,1000,560]`.
3. **[D] The dominant remaining defect is GEOMETRY, not alpha.** The height histogram is
   effectively **bimodal**: decile boundaries `[-1.099326, 0×9, +3.613412]` with counts
   `[52,298, 0×8, 5,302]` — 90.8% of cells sit at the basin minimum, 9.2% at the
   plateau maximum. The visible result is a **hard-edged stepped mesa with near-black
   flat faces and chevron stripes**, not organic hills. Relief-core Y is bimodal
   (p10=p25=`26.4`, p75=`72.2`), with 14–65 hard dark/light transitions per 820-px row.
4. **[I] Quantitatively the new frame is better than old 240c but still not donor-like.**
   In the clean relief ROI, max row-mean jump falls `16.97 → 5.22` and dark
   (`max(RGB)≤32`) fraction falls `45.8% → 17.8%`; those now sit nearer donor A5/A7
   (`5.71/3.17` row jump, `1.25%/4.22%` dark32). But gradient p95 falls to
   `18.32` — **below** both donor bands (`34.67/27.15`) and old 240c (`29.68`): the new
   relief is smooth hard plates, not mottled ground. FFT anisotropy stays high
   (`.660` vs A5 `.236`, A7 `.614`). Flat lowlands remain at gradient p95 `4.4–6.3`.
5. **[O] Props are no longer uniformly pure-black, but three prop defects remain:**
   near-black units (`240f [700,230,1090,355]`, dark16 `4.66%`), black crop stalks
   (`frame_0000 [20,535,125,720)`, `5.64%` pure black), and three **pale/white conifers
   in a `season=summer` map** (`frame_0012` near `(1155,120)`, `(1235,91)`, `(1105,205)`;
   RGB ≈ `(156,150,132)`, the same palette as the mine disc).

**No parity claim. Parity stays UNVERIFIED.**

## 1. Scope, inputs and method

### 1.1 Governing documents read first

`VISUAL_WAVE_CHARTER.md`; reports `W01_capture_visual_diff.md`,
`W03_terrace_root_cause.md`, `W08_visual_acceptance_criteria.md`.

### 1.2 Images inspected

| Role | Path | Px | Bytes | SHA-256 (first 12) |
|---|---|---:|---:|---|
| NEW motion, start | `%TEMP%\opencode\v42\video\donor_240\frame_0000.png` | 1280×720 | 789,312 | `8103ace7a1d9` |
| NEW motion, frame 12 | `%TEMP%\opencode\v42\video\donor_240\frame_0012.png` | 1280×720 | 705,840 | `fecf92eaedb4` |
| NEW still | `%TEMP%\opencode\v42\cap_donor_240f.png` | 1280×720 | 530,622 | `7e4f9440e901` |
| OLD baseline | `%TEMP%\opencode\v42\cap_donor_240c.png` | 1280×720 | 1,109,975 | `27a2952ca0b4` |
| Earlier flat baseline | `%TEMP%\opencode\v42\cap_donor_240b.png` | 1280×720 | 1,087,023 | `1d4729ea28b5` |
| Intermediate stills | `cap_donor_240d/e.png` | 1280×720 | — | viewed only |
| Donor direction band | `C:\Users\Maxym.Oboyshev\Downloads\c3\articolo-787.jpg` (A5) | 960×540 | 154,026 | `a44b6b82a889` |
| Donor direction band | `C:\Users\Maxym.Oboyshev\Downloads\c3\cossacks-3-v1-498085.jpg` (A7) | 1280×720 | 296,007 | `7b8dad2c34c7` |

All 12 donor stills were available read-only; A5/A7 are reused because W01/W08 identify
them as the usable rolling-relief / ravine-lip bands. **They are direction bands only**
(unknown build, camera, zoom, area, JPEG/WEBP compression). Frames 1–11 and 13–23 were
not individually eyeballed; the runner manifest confirms 24 distinct nonblank hashes,
and the pan endpoints used here are frame 0000 and 0012.

### 1.3 Metric definitions

System **Pillow 12.1.1 + NumPy 2.4.3**. Luminance `Y=.2126R+.7152G+.0722B` on 8-bit RGB.

- **Nonblank:** exact `main.gd:1941-1977` implementation — `step_x=1280/64=20`,
  `step_y=720/64=11`, 64×66 = 4,224 samples; lit if `Y/255 > .02`; reject if lit `<.02`,
  `lmax-lmin ≤ .02`, or `<4` colours.
- **Gradient:** central differences, `g=hypot(dx,dy)/2`; mean, p95, max.
- **Edge anisotropy:** 12 bins of 15° modulo 180°, weighted by
  `max(g - median(g),0)`; `(max-min)/(max+min)`.
- **FFT anisotropy:** Hann-windowed 2-D FFT of `Y - GaussianBlur(3)`, radial band
  `0.025..0.45 cyc/px`, power-weighted 12 angular bins modulo 180°, same ratio.
- **Saturation:** `(max(RGB)-min(RGB))/max(RGB)`. **Colorfulness:** Hasler–Süsstrunk.
- **Row-mean jump:** `max |diff(mean(Y,axis=1))|`, 1-based y of the maximum recorded.
- **Mottle:** σ and p95−p5 of `GaussianBlur(16)` luminance. **Mixed energy:** mean
  `|Y(x+1,y+1)-Y(x+1,y)-Y(x,y+1)+Y(x,y)|`.
- **Dark fractions:** `max(RGB)=0` (pure black), `≤16`, `≤32`, and `Y<12`.
- **Luminance bands:** `[0,32),[32,64),[64,96),[96,128),[128,256)`; raw fractions.

**Multiple-pass / anomaly ledger**

| Pass | Instrument | Result |
|---|---|---|
| P1 | `read` on frame_0000, frame_0012, 240f, 240d/e, 240c, 240b | New frames show a localized dark stepped relief + textured building/props; no shore band. |
| P2 | Full Pillow/NumPy metrics on all 8 images | Nonblank, colour, gradient, FFT, row jump, dark fractions computed. |
| P3 | First anisotropy implementation reused W01's prose but mixed half/full gradient scaling | **Rejected**; recomputed with consistent median-subtracted gradient. W01's *absolute* anisotropy numbers are not reproduced by this implementation (see §8 caveat); only within-run comparisons are used. |
| P4 | First luminance-band loop emitted band0 as `1.0` (bug) | **Rejected**; corrected to proper `[0,32)` fractions before publishing. |
| P5 | Zoomed crops (2×/3× NEAREST) of relief, boulders, mine, crops, building, trees, white trees, A5/A7, 240c | Confirmed hard stair edges, chevron stripes, textured boulders/building, black stalks/units, pale trees. |
| P6 | Pale-oval centroid registration between frames | Centroid `(925,362) → (645,362)`, Δx = −280 px at constant y: world-locked pan, not a screen overlay. |
| P7 | `capture.json` telemetry read | Grid 240², bimodal height, cell-centre UV, props applied, sun/lighting rig, ROI marked ground-only UNVERIFIED. |

## 2. Capture admissibility and what the fixes actually changed

### 2.1 Runner evidence [O]

`video/donor_240/capture.json`: `id=cap-video-terrain-motion`, `seed=20261113`,
`map_size=[240,240]`, `tile_m=2.0`, `map_type=land`, `season=summer`, `shot=wide`,
`capture_source=Screenshot3DViewport`, `cpu_fallback_used=false`, `root_viewport_used=false`,
`script_error_lines` check delegated to COORD's stderr scan, 17/17 checks passed,
`frames_nonblank`, `frames_distinct=24/24`, `terrain_and_props_not_cleared=true`,
`parity.claim=NONE`, `parity.status=UNVERIFIED`.

Camera path: deterministic smoothstep pan x `228→252` sim m at y=`240`, height `58 m`,
pitch `−32°`, yaw `0°`, fov `17.27°`, zoom `0.3448`; sim clock frozen (`speed=0`,
`ais=0`). Declared ROI `[0.12,0.22,0.88,0.88]` → px `[153,158,1127,634]` with
`ground_only_status=UNVERIFIED_PENDING_VISUAL_REVIEW`. **[O] That ROI is not clean
ground:** it contains the dark plateau and several props (§4), so it cannot serve as a
terrain-quality control.

`cap_donor_240f` shows a **~7 px black top bar** (row means y0–y6 ≈ `26.9`, y7 = `71.87`).
This inflates its full-frame max row jump to `45.31`; the largest *terrain* row jump is
`5.32` at y=300. All 240f row-jump statements below exclude y≤7. **[O] capture framing,
not terrain; do not gate on the raw full-frame number.**

### 2.2 Fix effects visible in telemetry [O/D]

| Defect in W03 / W01 | New runtime evidence | Visual consequence |
|---|---|---|
| Wrong 320² mask / grid overwrite | `mesh_stats.grid = 240×240`, 57,600 vertices, 114,242 triangles | Correct cell scale; pan locks to world features. |
| No relief-family stamping | `height_max_m=+3.613412`, 5,302 cells in the top decile; `stamp_conversion 32/32`; `pattern_stamps=93` at boot | A relief body finally exists at `[180,0,1000,560]`. |
| Eye-plane `uv_repeat=0.5` + fragment `fract` | `uv="cell-centre ((x+0.5)/w,(z+0.5)/h) over the full map"`, `uv2=(tile id,face)` | W03(f) is **demoted** as the leading cause; stripes are world-locked (Δx −280 px). Mechanism still **[U]**. |
| Black prop silhouettes | `props_applied=true`; lighting rig present (`sun_energy=1.7`, ambient 1.1, diffuse ≈.81/.78/.69); `modules.sun=true`, `environment=true` | Building and boulders have readable albedo; units/crops/bare trees still dark. |
| No light rig / no shadows | `shadows_enabled=false`; `terrain_shader="manual Blinn-Phong unchanged; unshaded terrain does not consume this scene rig"` | The rig fixed props but **not** terrain; steep faces remain near-black. |

### 2.3 Critical new finding — bimodal height [O/D]

`height_hist_deciles.boundaries = [-1.0993263721, 0,0,0,0,0,0,0,0,0, 3.6134116650]`,
`counts = [52298, 0,0,0,0,0,0,0,0, 5302]`; `52,298 + 5,302 = 57,600` exactly. The
height field is therefore effectively **two-valued**: basin `−1.0993 m` (90.8%) and
plateau `+3.6134 m` (9.2%), with a step of ≈4.71 m across one 2 m cell. `face_hist =
{0:56500, 1:405, 2:695}` promotes 1,100 cells (1.9%) to non-default faces;
`z04_guard.relief_mask_cells_no_face_promotion=0`. This is a direct, image-independent
explanation for the flat dark plateaus, the vertical stair perimeter and the
near-zero-diffuse faces. **[U]** whether the 5,302 upper cells are all exactly equal or
merely all `>0` cannot be resolved from decile counts alone.

## 3. Quantitative results

### 3.1 Full-frame

| Image | Y mean±std | Sat | CF | Grad mean/p95 | Edge an | FFT an | Max row jump | Black% | dark16% | dark32% |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| NEW frame_0000 | 66.21±15.57 | .675 | 29.8 | 3.01 / 11.65 | .630 | .628 | 3.15 | 0.20 | 0.34 | 9.43 |
| NEW frame_0012 | 67.01±15.21 | .681 | 29.3 | 2.78 / 8.46 | .666 | .639 | 3.16 | 0.06 | 0.11 | 8.96 |
| NEW 240f | 69.83±11.21 | .712 | 26.2 | 2.97 / 7.88 | .415 | .509 | 45.31* / 5.32† | 0.21 | 0.84 | 2.43 |
| OLD 240c | 30.56±21.76 | .361 | 17.2 | 4.75 / 23.29 | .785 | .561 | 10.96 | 10.27 | 20.52 | 75.58 |
| OLD 240b | 68.75±23.57 | .617 | 31.4 | 3.19 / 5.41 | .802 | .614 | 4.37 | 10.24 | 10.24 | 10.24 |

\* includes the y=7 letterbox step; † excluding y≤7. **[O] The new frames recover the
bright/saturated olive palette of 240b (Y≈66–70, sat≈.68) while keeping a relief
gradient p95 of 8–12 versus 240b's 5.41 — but the whole-frame gradient is *half* 240c's
23.29 because the relief is now localized instead of map-wide.**

### 3.2 Per-ROI, NEW frames

Boxes are `[x0,y0,x1,y1)`, origin top-left. B0–B4 are luminance-band fractions.

| Image / ROI | Box | Y±sd | Grad mean/p95 | Edge/FFT an | Row jump | Mottle σ | Mixed | B0/B1/B2/B3/B4 | Black / d16 / d32 |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| f0 RELIEF | `[180,0,1000,560)` | 62.22±19.82 | 3.47/18.32 | .722/.660 | 5.22 | 13.03 | 3.29 | .182/.085/.721/.001/.011 | .0010/.0018/.1781 |
| f0 RELIEF_CORE | `[380,100,880,540)` | 58.00±19.84 | 3.91/19.91 | .713/.718 | 7.30 | 12.54 | 3.78 | .249/.116/.634/.000/.001 | .0007/.0013/.2437 |
| f0 CLEAN | `[850,430,1280,720)` | 70.11±6.01 | 2.39/4.69 | .306/.582 | 2.50 | 2.84 | 2.73 | .009/.038/.952/.001/.000 | .0000/.0001/.0089 |
| f0 BOULDERS | `[50,185,320,395)` | 58.15±19.27 | 4.62/21.00 | .658/.775 | 8.93 | 8.03 | 4.76 | .190/.206/.604/.000/.000 | .0014/.0041/.1704 |
| f0 MINE disc | `[855,325,995,405)` | 103.14±35.79 | 4.31/34.44 | .834/.565 | 21.68 | 16.93 | 3.12 | .003/.005/.540/.030/.422 | .0000/.0000/.0026 |
| f0 CROP stalks | `[20,535,125,720)` | 62.24±21.92 | 8.99/38.05 | .736/.820 | 7.76 | 8.27 | 9.68 | .120/.063/.817/.000/.000 | .0564/.0947/.1182 |
| f0 TREES | `[128,60,290,220)` | 67.11±14.02 | 3.21/16.42 | .596/.567 | 4.60 | 6.59 | 3.12 | .074/.035/.889/.002/.000 | .0067/.0109/.0718 |
| f12 RELIEF | `[0,0,700,560)` | 61.41±20.76 | 3.46/19.10 | .751/.646 | 5.94 | 13.84 | 3.29 | .206/.080/.701/.001/.012 | .0011/.0019/.2021 |
| f12 RELIEF_CORE | `[180,100,620,550)` | 57.31±21.06 | 3.85/20.23 | .749/.722 | 6.99 | 13.56 | 3.69 | .273/.110/.611/.001/.006 | .0008/.0014/.2682 |
| f12 CLEAN | `[850,180,1280,720)` | 71.16±4.96 | 2.33/4.43 | .282/.595 | 3.10 | 0.83 | 2.61 | .002/.020/.976/.003/.000 | .0004/.0009/.0017 |
| f12 MINE disc | `[575,325,710,405)` | 104.50±36.08 | 4.49/35.29 | .831/.508 | 22.51 | 16.54 | 3.19 | .003/.005/.526/.031/.435 | .0000/.0000/.0031 |
| f12 PALE TREES | `[1070,60,1275,250)` | 74.32±14.56 | 3.04/5.32 | .715/.553 | 4.93 | 4.59 | 2.68 | .002/.005/.947/.010/.036 | .0000/.0000/.0022 |
| 240f BUILDING | `[745,5,1080,325)` | 64.96±24.55 | 6.75/29.02 | .426/.612 | 44.26* | 13.17 | 6.99 | .115/.140/.692/.034/.019 | .0059/.0463/.0961 |
| 240f UNITS | `[700,230,1090,355)` | 68.37±24.09 | 6.42/31.56 | .499/.762 | 17.69 | 9.81 | 6.07 | .095/.072/.765/.042/.026 | .0076/.0466/.0837 |
| 240f TREES | `[150,260,425,535)` | 69.24±11.62 | 3.99/20.80 | .413/.769 | 2.60 | 2.77 | 4.93 | .024/.049/.921/.006/.001 | .0078/.0147/.0213 |
| 240f MINE disc | `[415,320,565,420)` | 74.11±13.03 | 5.66/26.81 | .259/.358 | 7.20 | 2.25 | 8.10 | .011/.044/.911/.025/.008 | .0002/.0009/.0095 |
| 240f CLEAN | `[0,400,400,700)` | 70.14±8.39 | 3.09/6.25 | .396/.246 | 2.90 | 2.46 | 3.59 | .012/.035/.952/.001/.000 | .0042/.0070/.0105 |
| 240f FLATUP | `[0,0,700,260)` | 70.18±7.76 | 1.77/3.22 | .906/.810 | 46.61* | 4.64 | 1.20 | .027/.004/.970/.000/.000 | .0000/.0000/.0269 |

\* letterbox-dominated; ignore for terrain judging.

### 3.3 Direction bands — NEW relief vs OLD 240c vs donor A5/A7

Same code path on all rows. W01's published gradient/row-jump values are reproduced to
within rounding (A5 row jump 5.71 vs W01 5.72; 240c T 16.97 and A7 3.17 match); its
absolute anisotropy values are not (see §8 caveat), so only the rank order is used.

| ROI | Grad p95 | Max row jump | FFT anis | dark32 | Y mean | B0 (Y<32) |
|---|---:|---:|---:|---:|---:|---:|
| **NEW** frame_0000 RELIEF | 18.32 | 5.22 | .660 | 17.8% | 62.2 | .182 |
| **NEW** frame_0000 RELIEF_CORE | 19.91 | 7.30 | .718 | 24.4% | 58.0 | .249 |
| **NEW** frame_0012 RELIEF_CORE | 20.23 | 6.99 | .722 | 26.8% | 57.3 | .273 |
| **OLD** 240c T | 29.68 | 16.97 | .748 | 45.8% | 42.1 | .467 |
| **OLD** 240c UL | 32.68 | 22.93 | .701 | 35.5% | 51.7 | .361 |
| DONOR A5 ground band | 34.67 | 5.71 | .236 | 1.25% | 71.9 | .025 |
| DONOR A7 ravine-lip band | 27.15 | 3.17 | .614 | 4.22% | 75.2 | .059 |
| NEW clean ground (f0 CLEAN) | 4.69 | 2.50 | .582 | 0.89% | 70.1 | .009 |
| NEW clean ground (f12 CLEAN) | 4.43 | 3.10 | .595 | 0.17% | 71.2 | .002 |

**[D] Reading:** row-jump and dark fraction move strongly toward the donor bands;
gradient p95 moves the *wrong* way (below both bands) because the relief is now a few
smooth plates instead of textured slopes; anisotropy barely improves; the flat clean
ground remains a uniform lower outlier (gradient p95 ≈4.4–4.7, 95%+ in one luminance
band), far below A5/A7. **[I] This is a real improvement in "hard banding" but not a
read of organic relief.**

### 3.4 Motion / world-lock check [O]

Pale disc centroid `(925.0,362.1)` in frame_0000 → `(645.4,362.2)` in frame_0012:
**Δx = −279.6 px, Δy ≈ 0**, matching the documented x-pan `228→252` sim m. The dark
plateau, boulders and trees shift with it. Therefore the chevron/step pattern is
**world-locked to the terrain**, not a fixed screen-space overlay. This weakens a
pure eye-plane/screen-locked cause for the NEW frame; it does not identify the exact
UV or geometry mechanism.

## 4. What is now visibly present — inventory

| Class | Present? | Evidence | Label |
|---|---|---|---|
| **Relief / hills** | A relief body exists but is **not** soft hills. Dark stepped mesa complex at frame_0000 `[180,0,1000,560)`, core `[380,100,880,540)`; pans to frame_0012 `[0,0,700,560)`. | Height max +3.6134 m; hard axis-aligned perimeter; bimodal Y. | `[O]` presence, `[I]` wrong form |
| **Mountain / stone props** | **Yes — textured.** Three brown/grey boulder clusters in frame_0000 near `(70,225)`, `(60,350)`, `(230,375)` (ROI `[50,185,320,395)`); individual rock faces visible, not black. | dark16 only 0.41% in boulder ROI vs 52.8% in old 240c MID. | `[O]` |
| **Forests / trees** | **Partially.** 240f trees `[150,260,425,535)` include textured green/brown conifers and a yellow-green deciduous crown; frame_0000 has scattered thin conifers. But several trees are bare dark trunks, and three pale/white conifers appear in frame_0012. | Tree ROI dark16 1.47%; pale-tree pixels RGB ≈156/150/132; `season=summer`. | `[O]` |
| **Mines / deposits** | **Yes, as pale discs.** frame_0000 `[855,325,995,405)`, frame_0012 `[575,325,710,405)`, 240f `[415,320,565,420)` and `[1000,120,1120,190)`. Discs are flat ellipses, Y≈103–105 vs ground ≈70; tiny dark clump at centre. | Disc Y B4 42–44%; same pale palette as white trees. Identity as "mine" stays `[I]` per W08; ore family `[U]`. | `[O]` disc, `[I]`/`[U]` identity |
| **Buildings / decor** | **Yes, now readable.** 240f `[745,5,1080,325)` shows wood-plank walls, thatch roof panels, a red-trimmed tower, two huts. The 240b/240c pure-black silhouette defect is largely gone for the building. | Building dark16 4.63% vs 240c MID 52.8%. | `[O]` |
| **Units** | Present but **still near-black** at 240f `[700,230,1090,355)`. | dark16 4.66%, dark32 8.37%, sample `(817,230)=(8,3,0)`. | `[O]` |
| **Mill fields / crops** | Two dark stalk clusters at frame_0000 `[20,535,125,720)` — present but **not golden wheat**. | 5.64% pure black; `(88,536)=(0,0,0)`. | `[O]` |
| **Sea / shore** | **No land→beach→foam→water band in any new image.** The beige oval is a deposit disc, not foam; lowlands stay olive despite `surface_y=-0.25` placeholder. | Visual read of three images + telemetry water block. | `[O]` absence in frame; shore identity stays `[U]` |
| **Water node** | One water node bound, `surface_y=-0.25` PORT APPROX placeholder; no visible water surface in the analysed ROIs. | `capture.json mesh_stats.water`. | `[O]` telemetry, `[U]` appearance |

## 5. What remains wrong — artifact classification register

Classes restricted to **GEOMETRY / TILE ART / SHADER UV / ALPHA / LIGHTING / PROP
MATERIAL / PLACEMENT**. Confidence is a worker judgement, not a gate. All coordinates
are in the named 1280×720 image.

### A1 — Binary/stepped relief perimeter and flat plateau tops — **GEOMETRY**, confidence **.90**

- **Pixels:** frame_0000 `[180,0,1000,560)`, core `[380,100,880,540)`; frame_0012 `[0,0,700,560)`. Hard axis-aligned stair edges visible around `(380,180)→(760,540)` and `(200,150)→(620,540)` in the two frames.
- **Evidence [O/D]:** bimodal height telemetry (52,298 / 5,302 cells, Δ≈4.71 m over 2 m); relief-core Y p10=p25=`26.4` vs p75=`72.2`; 14–65 dark/light transitions per 820-px row at y=150/250/350/450/500.
- **Why not ALPHA:** PNG alpha is irrelevant here; the same hard boundaries coincide with world-locked geometry and the height histogram independently predicts them.
- **Discriminating test:** capture per-cell height/tile-id overlay at the pinned camera; if plateau boundaries coincide with the 5,302-cell set, GEOMETRY is confirmed.

### A2 — Chevron / diagonal stripes on the relief — **SHADER UV + TILE ART**, confidence **.62**; secondary **LIGHTING** (normals) **.55**

- **Pixels:** frame_0000 `(500–800, 250–520)`; frame_0012 `(250–500, 250–520)`. Alternating olive highlight / near-black bands forming nested chevrons.
- **Evidence [O]:** FFT anis `.660–.722` vs A5 `.236` / A7 `.614`; edge an `.713–.751`; world-locked under a −280 px pan; telemetry UV is now cell-centre, so the old eye-plane `fract` mechanism is demoted but not excluded.
- **Why not a pure screen lattice:** bands translate with the terrain; no fixed-screen overlay behavior.
- **Discriminating test:** constant-atlas render and constant-normal render at the same camera; force UV0 to world position. No new numeric scale may be invented (W08/W03 hard rule).

### A3 — Near-black plateau faces — **LIGHTING** (terrain normals), confidence **.82**

- **Pixels:** frame_0000 `(580,470)` Y=`54.5`; frame_0012 `(430,340)` RGB `(23,28,20)` Y=`26.4`; many pixels at Y=`26.4` inside RELIEF_CORE (dark32 `24–27%` vs donor `1.25–4.22%`).
- **Evidence [O/D]:** `sun_energy=1.7`, `shadows_enabled=false`, manual Blinn-Phong unchanged, normals from one-cell forward difference on a ≈4.71 m step → `dot(l,n)` near zero, leaving ambient-only colour. The scene light rig fixed props but the terrain shader does not consume it.
- **Why not ALPHA:** the dark pixels are opaque olive-black, not clear-colour; plateau interiors are uniform.
- **Discriminating test:** constant-albedo + normal-only render; then re-run with donor-grounded normal stencil. Do not add emissive or fake AO to hide it.

### A4 — Flat olive lowlands — **GEOMETRY** **.70** + **TILE ART** **.55**

- **Pixels:** frame_0000 `[850,430,1280,720)`, frame_0012 `[850,180,1280,720)`, 240f `[0,0,700,260)`.
- **Evidence [O/D]:** Y sd `5–8`, gradient p95 `3.2–6.3`, >95% in one luminance band; 90.8% of cells at the basin minimum; subtle diagonal ground hatching still visible (FFT `.582–.595`, `.810` in 240f FLATUP).
- **Discriminating test:** dump height quantiles at these ROIs; constant-atlas render to separate absent relief from tile-art uniformity.

### A5 — Black crop stalks — **LIGHTING** **.60** / **PROP MATERIAL** **.60**

- **Pixels:** frame_0000 `[20,535,125,720)`; pure-black `(88,536)=(0,0,0)`; ROI black `5.64%`, dark16 `9.47%`, mixed energy `9.68` (high silhouette density).
- **Evidence [O]:** stalks are thin, leafless and near-black, whereas W08's mill-field class requires golden wheat/stubble with a legible footprint.
- **Discriminating test:** emissive/albedo-only prop diagnostic; isolate field-prop group.

### A6 — Near-black units — **LIGHTING** **.55** / **PROP MATERIAL** **.55**

- **Pixels:** 240f `[700,230,1090,355)`; `(817,230)=(8,3,0)`; dark16 `4.66%`, dark32 `8.37%`.
- **Evidence [O/D]:** big improvement over old 240c MID (`dark16=52.8%`) but still visually silhouette-like; building in the same frame gained readable albedo, so the cause is unit-specific material/lighting, not terrain.
- **Discriminating test:** compare unit vs building material slots under the same rig.

### A7 — Pale/white conifers in a summer map — **PROP MATERIAL** **.70** / **PLACEMENT** **.70**

- **Pixels:** frame_0012 near `(1155,120)`, `(1235,91)`, `(1105,205)`; brightest `(1235,91)=(157,150,133)`; ROI `[1070,60,1275,250)` has `3.6%` of pixels with Y≥128 and `0%` dark16.
- **Evidence [O]:** their RGB matches the mine-disc palette `(151,145,128)`; `capture.json` says `season=summer`. Two candidate readings: a winter/snow prop material selected in summer, or deposit/disc material misapplied to a tree mesh. Both are prop-level, not terrain.
- **Discriminating test:** dump the mesh/material id for those three tree instances.

### A8 — Bare/leafless dark trees — **PROP MATERIAL** **.55** / **PLACEMENT** **.50**

- **Pixels:** 240f `[150,260,425,535)`, e.g. tall bare trunk near `(200,300)` and thin crowns around `(300–360,380–470)`.
- **Evidence [O]:** mixed with textured green/brown trees in the same stand; looks like a wrong LOD, dead-tree variant, or missing foliage layer rather than a lighting-wide failure (tree ROI dark16 only 1.47%).
- **Discriminating test:** isolate tree prop instances and list model/material ids.

### A9 — Deposit disc form and centredness — **PROP MATERIAL** **.60** / **PLACEMENT** **.55**

- **Pixels:** frame_0000 `[855,325,995,405)` centroid `(925,362)`; frame_0012 `(645,362)`; 240f `[415,320,565,420)`.
- **Evidence [O]:** flat pale ellipse with a hard edge, Y≈103–105 vs ground ≈70, tiny illegible dark clump at centre; no visible 5×5 dirt plate or centred minehead. W08 requires mine centred on deposit; this is not legible **[U]**.
- **Discriminating test:** mine/deposit ON/OFF pair at pinned camera; dump deposit and minehead world coordinates.

### A10 — Hard stair edges at relief/deposit boundaries — **GEOMETRY** **.88**

- **Pixels:** frame_0000 `(380,180)–(760,540)`; frame_0012 `(200,150)–(620,540)`.
- **Evidence [O]:** axis-aligned 2 m cell steps; no gradual beach/foam or talus transition anywhere on the perimeter.
- **Discriminating test:** height wireframe overlay at pinned camera.

### A11 — ~7 px black top bar in 240f — **ALPHA** (framebuffer clear / viewport edge), confidence **.40**, capture-framing note **[O]**

- **Pixels:** `[0,0,1280,7)`, row means ≈`26.9` vs `71.87` at y=7; drives full-frame row jump `45.31`.
- **Evidence [O]:** uniform dark band at the viewport top, not terrain, not a prop. It is outside the terrain artifact taxonomy proper; classified here only to keep the register complete.
- **Discriminating test:** inspect viewport rect/letterbox settings and clear colour. Exclude y≤7 from terrain metrics.

### Not classified — deliberately withheld

- **Shore / foam / water identity:** no band exists in these frames, so there is nothing
  to classify. Stays **[U]**; no reference-derived threshold may be invented (W08 §3).
- **Mountain silhouette / quarry identity / ore family:** no donor A/B frame and no
  identifying still (W08 §3); the boulder clusters are visibly present but their donor
  class assignment stays **[U]**.

## 6. Top 5 next fixes, ranked by visual impact

| Rank | Fix | Class | Expected visual effect | Owner / note |
|---:|---|---|---|---|
| **1** | Replace the effectively binary height field with a **continuous donor-shaped relief distribution**: apply the already-corrected donor hill/plateau/ravine windows (1.31733 / 2.964 / −2.964 m) with blended transitions instead of a flat −1.0993 basin plus a flat +3.6134 plateau. | GEOMETRY | Removes the single largest defect — the hard mesa, its vertical stair perimeter and the 90.8% dead-flat lowlands. Expect RELIEF_CORE dark32 to drop well below 24% and row jump to approach the A5/A7 band. | COORD / I07. No `HEIGHT_SCALE` fudge, no noise/dither; preserve donor constants. |
| **2** | Fix steep-face shading at its source: recompute terrain normals with a donor-grounded stencil / smoothed height gradient so a 4.7 m step does not collapse `dot(l,n)` to ambient-only. | LIGHTING | Recovers mid-tone detail across 18–27% of the relief ROI (currently Y≈26.4) and restores depth cues. | COORD / I08 + I10. Do **not** add emissive, fake AO, or lowered gates; the scene rig already works for props but the manual terrain shader does not consume it. |
| **3** | Remove the world-locked chevron/diagonal stripes: run the constant-atlas and constant-normal diagnostics at the pinned camera, then bind the donor UV/texgen source instead of any invented repeat scale. | SHADER UV / TILE ART | Clears the "not natural" read across the whole relief; FFT anis `.66–.72` should move toward the A7 band `.614` and the A5 band `.236` without weakening relief. | I10 + COORD. Telemetry already shows cell-centre UV, so first confirm whether stripes follow tile id, face id or normals. |
| **4** | Bring units, crop stalks and bare trees to readable albedo under the same rig that fixed the building/boulders; audit the unit/field/tree material slots and LOD variants. | LIGHTING / PROP MATERIAL | Removes the remaining near-black silhouettes (`240f UNITS dark16 4.66%`, `f0 CROP` 5.64% pure black) and the bare-trunk trees in 240f `[150,260,425,535)`. | COORD / props. Buildings and boulders prove the rig itself is sufficient; this is prop-local. |
| **5** | Correct prop selection/placement: eliminate the three pale/white conifers in the `season=summer` map, and make the mine/deposit disc legible (centred minehead, 5×5 dirt plate, non-flat disc material). | PROP MATERIAL / PLACEMENT | Removes an obvious season/material contradiction and an illegible economy landmark in both camera views. | COORD / props + I17. Dump the instance/material ids for the white trees before changing art. |

**Not in the top 5:** shore, mountains-as-class, quarry identity and ore-family naming —
there is no admissible donor reference or visible candidate band for them in these frames
(W08 §3, X07/X36). Promoting them now would invent evidence.

## 7. Handoff to COORD

1. Capture a pinned-camera diagnostic set with **per-cell height quantiles**, tile-id and
   face-id overlays, a constant-albedo normal render, and a constant-atlas render. The
   bimodal height finding (§2.3) is the load-bearing result; confirm it before any visual
   tuning.
2. Record `script_error_lines` from the runner's `stderr.txt` (the manifest explicitly
   delegates this check); the 17/17 capture checks do not include it.
3. Re-shoot the exact `cap_donor_240c` camera for a candidate self A/B only
   (`compare_shots.py --threshold 0.9999` at pinned camera); do not compare against donor
   stills as pixels.
4. Pin a **clean ground ROI** that excludes the relief and all props. The runner's declared
   ROI `[153,158,1127,634]` is explicitly `ground_only_status=UNVERIFIED` and visually
   contains both; do not treat its statistics as terrain quality.
5. Keep the letterbox rows y≤7 out of any row-jump or gradient gate on 240f-style stills.
6. Maintain `parity.claim=NONE`, `parity.status=UNVERIFIED` on every owner-facing use.

## 8. What remains UNVERIFIED

| ID | Unknown | Why | Settling test |
|---|---|---|---|
| AF-U1 | Whether all 5,302 upper cells are exactly `+3.6134` or merely `>0` | Decile counts only give two occupied bins | full height histogram / deciles with finer boundaries |
| AF-U2 | Which of SHADER UV, TILE ART or normals produces the chevrons | world-lock rules out a screen overlay but does not separate the three | constant-atlas + constant-normal + UV0 A/B at pinned camera |
| AF-U3 | Why three conifers render in the pale mine-disc palette | no per-instance material dump | instance/material id dump for `(1155,120),(1235,91),(1105,205)` |
| AF-U4 | Whether the pale disc is a built mine, a deposit disc, or both | tiny dark centre not legible; no donor legend | mine ON/OFF, deposit/minehead world coordinates |
| AF-U5 | Shore/water appearance | no visible band in any new frame; water surface is a PORT placeholder | shore-camera shot; no foam-width threshold from a still |
| AF-U6 | Donor parity | no same-camera donor GPU A/B frame; stills unknown build/camera/compression | owner-only admissible A/B under X39 |

**Absolute anisotropy caveat:** this worker's power-weighted FFT implementation returns
higher absolute values than W01's published ones for the same files (e.g. 240c T `.748`
vs W01 `.596`, A7 `.614` vs `.484`, A5 `.236` vs `.144`). Gradient p95 and row-jump
values reproduce W01 to within rounding. Therefore only *within-run* anisotropy
comparisons are used here; the rank order (240c > A7 > A5) is preserved in both
implementations.

## 9. Final parity statement

**Donor parity is UNVERIFIED. No parity claim is made.** The three new images prove that
the donor backend produced nonblank 1280×720 frames with a localized relief body,
textured building/boulders, trees, deposit discs and crop props, and that the old
320²-grid / no-stamp / black-silhouette states improved. They do **not** prove
donor-faithful geometry, tile selection, alpha composition, lighting, prop material,
landscape composition or motion. The A5/A7 bands were used for direction only, never as
thresholds or match scores.

*End of ANALYZE-FRAME. Exactly one repository file written; all images and telemetry
read-only; no code/Godot/git/donor-execution action taken.*
