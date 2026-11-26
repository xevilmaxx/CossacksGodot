---
id: W01
wave: DONOR-TERRAIN VISUAL WAVE
role: ANALYSIS / READ-ONLY — live capture visual diff
owner_file: docs/terrain_swarm_2026-11-26/reports/W01_capture_visual_diff.md
date: 2026-11-26
status: DELIVERED__ONE_REPORT_ONLY__NO_CODE_GODOT_GIT_EDIT__NO_DONOR_EXECUTION
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_claim: false
---

# W01 — live donor-backend capture visual diff

> **PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.**

## 0. Executive result

1. **[O] Both files are admissible nonblank live captures, not blank/CPU substitutes.**
   `cap_donor_240b.png` and `cap_donor_240c.png` are both **1280×720 RGBA**. Each is
   byte-identical to its `.raw.png` companion. The capture path explicitly uses a
   real GPU `SubViewport` and always writes the unfiltered image
   (`variant3d/scripts/main.gd:1244-1262,1870-1894`). Both pass the project's own
   nonblank tests (§2).
2. **[O/D] 240b is visually and numerically flat olive.** Clean foreground ROI `LC`
   is `Y=79.33±3.97`, gradient p95 `5.25`, and 100% of pixels fall in one
   32-level luminance band. The field has no readable relief; buildings, units,
   trees and three flat black ellipses are silhouettes.
3. **[O/D] 240c has a genuinely different, high-frequency stepped surface.** In
   terrace ROI `T`, gradient p95 rises `3.48 → 29.68` (**8.52×**), maximum row-mean
   luminance jump rises `3.03 → 16.97` (**5.59×**), FFT anisotropy is `0.596`, and
   luminance occupies four bands instead of one. The visible result is a large
   blocky/diagonal terrace field, not soft organic hills.
4. **[I] The visible defect is layered, not one cause.**
   - Broad treads/contour steps: **GEOMETRY + SHADING/NORMAL** are plausible.
   - Diagonal crosshatch and irregular light/dark “checker” patches:
     **ALPHA + TILE ART**, with eye-plane projection a strong port-side suspect.
   - Pure-black buildings/units/trees: **LIGHTING applied to PROP meshes**, not
     terrain geometry and not PNG transparency.
   - The exact contribution of each layer remains **[U]** because the capture
     folder has no height, tile-id, normal, mask-UVA or draw-pass dump.
5. **[D/I] Donor stills point in the opposite direction on softness.** The two best
   relief stills, A5/A7, have gradient p95 `34.67/27.15` but row-mean jumps only
   `5.72/3.17`; 240c `T` has gradient p95 `29.68` and row jump `16.97`. This is
   direction-only evidence for “too hard/banded,” never a parity score.

## 1. Scope, inputs and method

### 1.1 Inputs

- Live captures, read-only:
  - `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\cap_donor_240b.png`
  - `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\cap_donor_240c.png`
- Donor still corpus, read-only: all **12** files in
  `C:\Users\Maxym.Oboyshev\Downloads\c3\`.
- Governing documents read first: `VISUAL_WAVE_CHARTER.md`, `CHARTER.md`,
  `SWARM_BOARD.md`.
- Capture config: `%TEMP%\opencode\v42\map_donor_240.json` — donor backend at
  lines 29-32, 1280×720 window at 57-60, seed `20261113`, 240² request,
  `map_type=land` at 67-83 and 111-114.

**[O]** The `read` tool was used on both captures, all 12 stills, the selected
height mask, both alpha atlases and the 2048×1024 tile atlas. Quantitative work used
system **Pillow 12.1.1 + NumPy 2.4.3**. No donor binary was run; no Godot, git,
source, shader, config, asset or test command was issued. This report is the only
file written.

### 1.2 Metric definitions

All image statistics use Rec.709 luminance
`Y = .2126R + .7152G + .0722B` on 8-bit RGB.

- **Gradient:** central differences, `g = hypot(dx,dy)/2`; mean, p95 and max.
- **Edge orientation:** gradient-weighted 12-bin histogram modulo 180° after
  subtracting the median gradient. Anisotropy is
  `(max(bin)-min(bin))/(max(bin)+min(bin))`. Axis bands are ±7.5° around H/V/±45°.
- **FFT anisotropy:** Hann-windowed 2-D FFT of `Y - GaussianBlur(3)`, radial band
  `0.025..0.45 cyc/px`, same 12 angular bins and anisotropy formula.
- **Colorfulness:** Hasler–Süsstrunk metric
  `sqrt(var(R-G)+var(.5(R+G)-B)) + .3*sqrt(mean(R-G)^2+mean(.5(R+G)-B)^2)`.
  Saturation is `(max(RGB)-min(RGB))/max(RGB)`.
- **Large-scale mottling:** standard deviation and p95−p5 range of
  `GaussianBlur(16)` luminance. This is a texture/relief proxy, not world height.
- **Height-band proxy:** fractions in fixed luminance bands
  `[0,32), [32,64), [64,96), [96,128), …`. It is explicitly **not a heightmap**.
- **Seam energy:** mean `|dY|` on rows/columns with a given stride divided by
  overall mean `|dY|`; best stride over 2..64. A first-pass lag-difference metric
  was rejected because it trivially favoured the largest lag (§1.3).
- **Checker energy:** mean absolute mixed second difference
  `|Y(x+1,y+1)-Y(x+1,y)-Y(x,y+1)+Y(x,y)|`; also best absolute correlation of
  coarse block means with a checkerboard over block sizes 4..32 and four phases.
- **Nonblank:** exact implementation of `main.gd:1941-1977` on the full RGBA image
  (66×64 sampled grid because integer `720/64=11`).

### 1.3 Multiple-pass / anomaly ledger

| Pass | Instrument | Result / accepted reading |
|---|---|---|
| 1 | `read` on all 14 images | 240b flat olive + black silhouettes; 240c hard stepped/diagonal field; donor stills contain textured props and softer relief. |
| 2 | Full-frame Pillow/NumPy metrics | Nonblank, dimensions, alpha, colour, gradient, mottling and fixed luminance bands computed. |
| 3 | Central-difference edge histogram + high-pass FFT | Crossed diagonal energy confirmed in 240c `UL/T`. First FFT angle print omitted modulo 180 and produced impossible values such as `429.7°`; **rejected**. Pass 4 folded angles to `0..180°`; accepted 240c `T` peak `52.5°`, `UL` edge peak `142.5°`. |
| 4 | Modulo-stride seams + phased block-checker correlations | Initial “best lag” always selected lag 32 because lag differences grow monotonically; **rejected as periodic evidence**. Final clean `UL` has weak aligned block checker (`|r|=.0036`), so the visible checker is not a simple pixel/block parity lattice. |
| 5 | Row profiles, exact pixel probes, black connected components, b↔c regression | Hard row jumps and exact colour samples recorded. Props move 1–6 px between captures, so b↔c is not pixel-registered. A simple `c = alpha*b + background` fit has `R²≤.142` in `LC`; **alpha-fade attribution from regression alone rejected**. |
| 6 | Alpha/tile asset inspection + current source/spec read | Alpha atlas contains large zero/grade regions; shader can expose them through `blend_mix`; tile art has independently measured diagonal anisotropy. These support ALPHA/TILE ART hypotheses but do not prove capture-time causation. |
| 7 | Donor ground-ROI metrics + X07/X36 recheck | All 12 stills retained. Snow/HUD/building-edge and tiny-thumbnail ROIs are marked confounded. Stills used for direction only. |

## 2. Capture identity and nonblank statistics

### 2.1 File identity

| Capture | Bytes | SHA-256 | Raw companion |
|---|---:|---|---|
| 240b | 1,087,023 | `1d4729ea28b52e1e5e4cd6d001817b1f5c09effc401e6b71d173f307c4516ad7` | byte-identical; max pixel diff 0 |
| 240c | 1,109,975 | `27a2952ca0b4177e3338d39e558dab6684510c2b80b5653f6ea53b5807fe3ac6` | byte-identical; max pixel diff 0 |

### 2.2 Full-frame statistics

| Statistic | 240b flat olive | 240c terraced/stepped |
|---|---:|---:|
| Dimensions / mode | **1280×720 RGBA** | **1280×720 RGBA** |
| Alpha min/max; nonopaque; zero | 255/255; **0**; **0** | 255/255; **0**; **0** |
| Unique RGB / RGBA | 2,276 / 2,276 | 13,915 / 13,915 |
| RGB min | `(0,0,0)` | `(0,0,0)` |
| RGB max | `(102,102,47)` | `(144,129,82)` |
| RGB mean | `(70.657,72.808,22.879)` | `(31.410,31.421,19.479)` |
| RGB std | `(24.233,24.948,8.189)` | `(24.134,22.161,12.496)` |
| Nonblack RGB mean | `(78.720,81.117,25.490)` | `(35.005,35.017,21.708)` |
| Pure black `max(RGB)=0` | **94,403 (10.243%)** | **94,638 (10.269%)** |
| Dark `max(RGB)≤16` | 94,403 (10.243%) | **189,161 (20.525%)** |
| Y min / max | 0 / 96.810 | 0 / 128.796 |
| Y mean / std | 68.746 / 23.567 | 30.557 / 21.757 |
| Y p50 / p95 | 75.604 / 83.956 | 27.777 / 77.175 |
| Saturation mean / p95 | .6165 / .7162 | .3608 / .5341 |
| Colorfulness | 31.392 | 17.224 |
| Gradient mean / p95 / max | 3.191 / 5.407 / 65.858 | 4.745 / 23.291 / 81.656 |
| Edge / FFT anisotropy | .414 / .412 | .464 / .381 |
| Mottle σ16 / p95−p5 | 16.658 / 53 | 15.694 / 59 |
| Mixed-difference energy | 3.592 | 6.065 |
| Max row-mean jump | 4.373 | 10.956 |
| Exact blank-check sample | 66×64; lit .8961; Y range .3629; 551 colours | 66×64; lit .8904; Y range .4692; 995 colours |
| Blank verdict | **NONBLANK** | **NONBLANK** |

**[O] Important alpha distinction:** the PNG files are fully opaque. Any ALPHA
artifact classified below is **in-shader/framebuffer alpha**, not transparent PNG
pixels.

## 3. Per-ROI measurements

Pixel boxes are `[x0,y0,x1,y1)`, origin top-left.

| ROI | Box | Purpose |
|---|---|---|
| F | `[0,0,1280,720)` | full frame |
| T | `[0,0,900,260)` | main terrace field, mostly prop-free |
| UL | `[0,0,480,220)` | clean upper-left diagonal/terrace detail |
| UR | `[900,0,1240,230)` | right terrace + forest edge; prop-contaminated |
| MID | `[430,210,850,450)` | central buildings/units; localization only |
| LL | `[0,500,440,720)` | lower-left trees + ground; prop-contaminated |
| LC | `[350,520,1000,720)` | clean lower foreground ground |

### 3.1 240b — flat olive

| ROI | Y mean/std | grad mean/p95 | edge/FFT anis | sat / colorfulness | σ16/range | mixed | row jump | black% |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| F | 68.75/23.57 | 3.19/5.41 | .414/.412 | .616/31.4 | 16.66/53 | 3.592 | 4.373 | 10.243 |
| T | 69.21/19.78 | 1.88/3.48 | .416/.476 | .646/29.4 | 15.50/48 | 1.806 | 3.034 | 7.407 |
| UL | 72.83/13.01 | 1.81/3.42 | .464/.619 | .675/25.3 | 8.17/18 | 1.767 | 5.766 | 2.958 |
| UR | 60.89/27.47 | 6.69/38.12 | .582/.369 | .590/33.7 | 11.83/35 | 7.315 | 4.907 | 16.794 |
| MID | 44.39/37.54 | 2.64/4.74 | .569/.483 | .403/36.4 | 29.41/76 | 2.158 | 12.780 | 41.600 |
| LL | 72.63/25.95 | 4.72/39.27 | .506/.287 | .582/32.4 | 12.23/37 | 5.672 | 4.195 | 11.126 |
| LC | 79.33/3.97 | 2.56/5.25 | .119/.090 | .669/19.4 | 1.48/4 | 3.372 | 2.425 | 0.000 |

### 3.2 240c — terraced/stepped

| ROI | Y mean/std | grad mean/p95 | edge/FFT anis | sat / colorfulness | σ16/range | mixed | row jump | black% |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| F | 30.56/21.76 | 4.74/23.29 | .464/.381 | .361/17.2 | 15.69/59 | 6.065 | 10.956 | 10.269 |
| T | 42.10/30.25 | 7.91/29.68 | .478/.596 | .341/24.8 | 21.55/64 | 9.728 | 16.971 | 7.331 |
| UL | 51.68/29.78 | 8.64/32.68 | .532/.610 | .403/29.3 | 19.50/53 | 10.198 | 22.931 | 2.976 |
| UR | 41.42/31.75 | 13.47/41.72 | .553/.272 | .336/26.4 | 16.60/50 | 19.023 | 10.546 | 16.632 |
| MID | 14.57/13.96 | 2.11/13.43 | .410/.429 | .227/8.0 | 9.52/26 | 2.317 | 6.896 | 41.637 |
| LL | 25.62/9.23 | 1.68/13.92 | .559/.335 | .377/7.4 | 4.34/13 | 2.026 | .992 | 11.299 |
| LC | 28.21/1.41 | .92/1.90 | .227/.158 | .444/5.0 | .61/1 | 1.226 | .757 | 0.000 |

`UR/MID/LL` contain props and are not clean terrain-quality samples. `LC` is the
cleanest flat-ground control; `T/UL` are the primary artifact samples.

### 3.3 Luminance height-band proxy

Fractions of pixels in `[0,32), [32,64), [64,96), [96,128)`; remaining bands are
zero in every listed ROI.

| ROI | 240b B0/B1/B2/B3 | 240c B0/B1/B2/B3 |
|---|---|---|
| F | .102/.001/.897/.000 | .766/.129/.087/.018 |
| T | .074/.000/.926/.000 | .467/.251/.228/.055 |
| UL | .030/.000/.970/.000 | .361/.206/.369/.064 |
| UR | .168/.001/.831/.000 | .526/.156/.267/.051 |
| MID | .416/.000/.584/.000 | .927/.072/.000/.000 |
| LL | .111/.000/.889/.000 | .995/.005/.000/.000 |
| LC | .000/.000/1.000/.000 | .998/.002/.000/.000 |

### 3.4 Seam / checker detail

`H/V` entries are `best stride : seam ratio`. Block checker is the maximum
absolute coarse-block correlation over 4..32 px and four phases.

| ROI | 240b H/V | 240c H/V | 240b block checker | 240c block checker |
|---|---|---|---:|---:|
| F | 62:1.109 / 61:1.054 | 40:1.105 / 64:1.039 | .0021 | .0021 |
| T | 55:1.145 / 57:1.074 | 47:1.345 / 64:1.092 | .0159 | .0060 |
| UL | 34:1.294 / 40:1.058 | 55:1.625 / 63:1.064 | .0073 | .0036 |
| UR | 53:1.205 / 40:1.210 | 62:1.198 / 63:1.120 | .0208 | .0688 |
| MID | 56:1.843 / 48:1.533 | 32:1.203 / 38:1.209 | .0124 | .0262 |
| LL | 59:1.198 / 59:1.297 | 59:1.169 / 59:1.203 | .0059 | .0310 |
| LC | 42:1.113 / 49:1.035 | 49:1.151 / 49:1.041 | .0148 | .0130 |

**[D]** There is no single clean global grid period. In the clean `UL`, the large
visual “checker” has weak aligned block parity, while mixed-difference energy is
**5.77×** 240b. The pattern is therefore better described as **diagonal,
irregular mask/art structure** than as a literal 2×2 mesh checkerboard.

## 4. Labelled 32×18 colour/luminance grids

Each character is one **40×40 px** cell. X cells run `0-39,40-79,…,1240-1279`.
Legend: `#` ≥20% pure-black cell; `b` dark blue/grey (`B>R`); `k` Y<12;
`d` Y<25; `o` Y<40; `O` Y<60; `g` Y<80; `G` Y<105; `w` Y≥105.

### 4.1 240b

```text
y=000-039 gggggggggggggggggggggggggggggggg
y=040-079 ggggggggggggggggggggggggggg#gggg
y=080-119 ggggggggggggggggggggg##gggg##gOg
y=120-159 gggggggg##ggggggg#ggggggO####gg#
y=160-199 gggggggg##gggggg##gggg#g#####g##
y=200-239 ggggggggggggggg####gggg##g##gggO
y=240-279 ggggggggggggggg#####gggg#ggggggg
y=280-319 gggggggggggggg######gggggggggggg
y=320-359 ggggggggggggg########gggggOggggg
y=360-399 ggggggggggggg##gggg###ggg###gggg
y=400-439 #ggggggg##ggg##gggg###gggg#ggggg
y=440-479 ggggggg###gggg#gggg#gggggggggggg
y=480-519 #ggggggggggggggggggggggggggggggg
y=520-559 g#g#ggGgGGgggggggggggggggggggggg
y=560-599 GgGgg#GGGGGggggggggggggggggggggg
y=600-639 g#GGggGGGGGGggGGgggggggggggggggg
y=640-679 ######GGGGGGGGGGgggggggggggggggg
y=680-719 #gGg##GGGGGGGGGGGGGGgggggggggggg
```

### 4.2 240c

```text
y=000-039 ggggggggggggggGGgOOOOOggOOgOgggg
y=040-079 gggggggggggggGggOOOOOOOOOOO#Oggg
y=080-119 gggGgOOOOOOOOOOOOoooo##oOOO##OOg
y=120-159 OOOOOoOO##ooooooo#oooddod####Og#
y=160-199 oooooooo##oooooo##oood#d#####OO#
y=200-239 ooooooooooddodd####ddod#####oOoo
y=240-279 odooddddoddoddd#####dodd#oooodoo
y=280-319 dddddddddddddd######ddoooodooooo
y=320-359 dddddddddddoo########ddddddooooo
y=360-399 doooooooooood##dood###odd###ddoo
y=400-439 #ooooood##ooo##oooo###oood#ddddo
y=440-479 doooooo###oooo#ddodddooooooooddd
y=480-519 #ooooood#ooooooooooooooooooooood
y=520-559 o#o#dooooooooooooooooooooooooooo
y=560-599 ooooo#oooooooooooooooooooooooooo
y=600-639 o#oooooooooooooooooooooooooooooo
y=640-679 ######oooooooooooooooooooooooooo
y=680-719 #doo##oooooooooooooooooooooooooo
```

## 5. Visible-artifact classification register

### A1 — 240b flat olive ground

- **Pixels:** clean `LC`, e.g. `(100,600)=RGB(83,86,30)`,
  `(400,600)=(72,74,26)`, `(640,600)=(86,89,29)`.
- **Observation [O]:** `LC` has `Y=79.33±3.97`, p95 gradient `5.25`, FFT
  anisotropy `.090`, and one luminance band. No relief silhouette is readable.
- **Class:** **TILE ART + SHADING/NORMAL** for the visible olive surface;
  **GEOMETRY absent** in the image. Root cause of the absent height is **[U]**.
- **Code/spec evidence:** mesh Y is exactly `height[]*1.0`
  (`terrain_donor_mesh.gd:41-42,743-749`); normals are forward differences of that
  same height (`:313-329`); the shader forms `ambient + max(dot(l,n),0)*diffuse`
  (`terrain_donor_shader.gdshader:213-226`). A zero/flat height field therefore
  gives uniform normals and no geometric relief. The observed b-state is also
  described in `VISUAL_WAVE_CHARTER.md:13-14`.
- **[U] discriminating test:** dump the capture-time `height[]`, mesh vertex Y and
  normals. All-zero/flat height confirms GEOMETRY; nonzero height with a flat image
  moves the investigation to camera, normals or art.

### A2 — 240b faint diagonal field texture

- **Pixels:** clean `UL`, broad field away from props.
- **Observation [O/D]:** despite flatness, `UL` FFT anisotropy is `.619`, with
  diagonal axis energy `.212/.212`; `LC` is only `.090`. Directional texture is
  present independently of relief.
- **Class:** **TILE ART** **[I]**; eye-plane repeat may amplify it.
- **Code/spec evidence:** tile RGB is sampled from `fract(v_st*uv_repeat)` with
  default `uv_repeat=.5` and default eye planes
  (`terrain_donor_shader.gdshader:103-118,199-211,266-269`). X06 independently
  measured intrinsic diagonal anisotropy in grass and rock cells
  (`reports/X06_atlas_visual_audit.md:38-47,150-174`).
- **[U] discriminating test:** render a constant atlas/constant tile id at the
  same camera. If the diagonals vanish, they are TILE ART; if they remain, inspect
  UV/eye-plane or post-processing.

### A3 — 240c broad treads and hard contour steps

- **Pixels/rows:** strongest clean row-mean jumps in `T` occur at
  `y=111 (16.05), 142 (16.18), 174 (16.97), 207 (13.64), 242 (13.34), 280 (12.78)`.
  Early spacing is about 31–35 px. Representative colours:
  `(720,20)=(111,100,62)`, `(720,160)=(26,25,21)`,
  `(100,400)=(28,29,15)`.
- **Observation [O]:** `T` gradient p95 `29.68`, row jump `16.97`, and four
  occupied luminance bands. The eye reads discrete horizontal/diagonal treads.
- **Class:** **GEOMETRY + SHADING/NORMAL** **[I]**; exact split **[U]**.
- **Code/spec evidence:** I17 supplies mask/pattern inputs
  (`terrain_donor_inputs.gd:238-289,475-522,613-629`); the composer calls I07 then
  I08 (`terrain_donor_world.gd:219-260`); stamping writes integer-rounded grid
  samples into `height[]` (`terrain_donor_gen.gd:1741-1827`); I08 turns those values
  directly into vertex Y and normals (`terrain_donor_mesh.gd:313-329,743-766`).
- **[U] discriminating test:** same-camera height/normal/tile-id overlays. If step
  boundaries coincide with height discontinuities and normals, GEOMETRY is
  confirmed. If height is smooth/flat while bands remain, reclassify toward
  ALPHA/TILE ART. Camera translation separates world-locked contours from
  screen-locked art.

### A4 — 240c diagonal crosshatch / irregular checker patches

- **Pixels:** along `y=80`: `x120=(23,28,20)`, `x160=(117,103,65)`,
  `x240=(40,42,26)`, `x280=(93,89,45)`, `x320=(92,87,45)`,
  `x360=(92,87,45)`, `x480=(106,97,62)`.
- **Observation [O/D]:** `UL` edge anisotropy `.532`, FFT `.610`, FFT peak
  `52.5°`, edge peak `142.5°`; both ±45° families are strong. Mixed energy is
  `10.198` vs `1.767` in 240b.
- **Class:** **ALPHA + TILE ART** **[I]**, with **eye-plane projection** as the
  leading port-side mechanism; a pure GEOMETRY checker is not supported by the
  weak aligned block parity.
- **Code/spec evidence:**
  - The alpha atlas has 32 patches of 64²; **22.86%** of all pixels are exactly
    zero, no pixel is 255, and patch means span `0..255`. Patch `(3,3)` and `(7,3)`
    are 100% zero. This asset can create large hard dark/light regions.
  - The shader derives mask UV from eye-space `st`, defaults to identity texture
    matrix and `uv_repeat=.5`, selects a patch from tile-id bits, then writes
    `ALPHA=a` (`terrain_donor_shader.gdshader:103-125,204-211,251-264,270-306`).
  - `blend_mix` is enabled (`:50`). The tile-id→mask-patch rule is explicitly a
    PORT APPROXIMATION (`:247-250`; `reports/F06_alpha_masks.md:334-361,369-387`).
  - Rock/grass atlas cells have independently measured diagonal art anisotropy
    (X06 E09/E11).
- **[U] discriminating test:** hold geometry, camera, tile RGB and normals fixed;
  render the alpha mask as greyscale, then force `ALPHA=1`. If the checker/bands
  vanish or track the mask, ALPHA is confirmed. Rotate/translate the camera:
  screen-locked motion implicates eye-plane UV; world-locked motion implicates
  geometry/UV0.

### A5 — 240c dark blue-grey holes / swaths

- **Pixels:** `(10,240)=(9,11,14)`, `(240,240)=(10,12,15)`,
  `(480,240)=(8,10,14)`; similar values extend across the upper-middle field.
- **Observation [O]:** these pixels are not pure black and are cooler/darker than
  the olive ground, showing that the artifact is not merely the black prop layer.
- **Class:** **ALPHA** **[I]** or dark **TILE ART** **[U]**; not PNG alpha.
- **Code/spec evidence:** the shader comment says a base opaque layer must already
  exist for masked overlay (`terrain_donor_shader.gdshader:30-40`), but I08 builds
  one mesh/surface (`terrain_donor_mesh.gd:726,786-793`) and the composer adds no
  second opaque terrain pass (`terrain_donor_world.gd:243-260`). Therefore low mask
  alpha can reveal clear colour/whatever is behind the single draw. This is a
  **PORT APPROXIMATION risk**, not proof of the captured pixels.
- **[U] discriminating test:** change only the viewport clear colour, or add an
  opaque base pass without changing the masked pass. If the swaths follow the
  background, ALPHA/compositing is confirmed. A simple b↔c alpha regression was
  inconclusive (`R²≤.142`), so this remains unproven by screenshot arithmetic.

### A6 — 240c uniformly dark foreground

- **Pixels:** `LC`, e.g. `(100,600)=(30,30,17)`, `(640,600)=(29,29,16)`,
  `(900,600)=(27,28,14)`.
- **Observation [O]:** `Y=28.21±1.41`, gradient p95 `1.90`, 99.8% of pixels in
  the darkest luminance band. It is even flatter and darker than 240b `LC`.
- **Class:** **[U] SHADING/NORMAL vs ALPHA vs TILE ART.**
- **Evidence:** no shipped block's flat-lit mean reproduces this colour closely;
  the closest is `grass6` but still substantially brighter. That weakens a simple
  “different grass tile under flat normal” explanation, but does not identify the
  true cause. Low b↔c regression fit prevents a clean alpha-coefficient claim.
- **[U] discriminating test:** normal-only diagnostic (constant albedo), then
  alpha-only diagnostic (constant RGB), then tile-id dump. Exactly one of the three
  should reproduce the dark foreground if the layers are correctly separated.

### A7 — black buildings, units and trees in both captures

- **Pixels/bboxes:** central complex `[517,104,858,494]` in 240b and
  `[519,105,860,495]` in 240c; right tree `[950,106,1040,278]` vs
  `[952,112,1042,279]`; left tree `[50,606,101,703]` vs
  `[51,607,102,704]`. Black-mask IoU is `.806`; about 89% of each mask overlaps.
- **Observation [O]:** bodies are exact `(0,0,0)` silhouettes with no readable
  albedo, while their shapes remain detailed. Small 1–6 px shifts show the camera
  is not pixel-identical between b and c.
- **Class:** **LIGHTING on PROP** **[I]**. The silhouettes themselves are PROP
  geometry; the missing surface shading is LIGHTING.
- **Code/spec evidence:** the donor terrain module creates mesh/water but no
  `WorldEnvironment` or `DirectionalLight3D`
  (`terrain_donor_mesh.gd:567-587,718-798`; `terrain_donor_world.gd:243-275`). The
  legacy terrain module is the one that creates the sun/environment
  (`world3d_terrain.gd:1114-1166`). Entity materials are ordinary lit spatial
  materials/shaders (`world3d_entities.gd:102-106,644-662`), not unshaded terrain.
  The donor props instancer also assigns no emissive/lighting material
  (`terrain_donor_props.gd:750-796`).
- **[U] discriminating test:** add only the donor sun/environment, or render props
  with an emissive diagnostic. If silhouettes gain texture without moving,
  LIGHTING is confirmed. Hide entity/relief/donor-prop groups separately to bind
  each black shape to its owner.

### A8 — three flat black ellipses

- **Pixels/bboxes:** approximately `[284,423,394,489]`,
  `[1008,351,1115,411]`, and a lower-left ellipse near `[136,636,203,715]`.
- **Observation [O]:** large, flat, pure-black oval components persist in both
  captures and are unlike the detailed tree/building silhouettes.
- **Class:** **[U] PROP vs water/start-mask geometry, with LIGHTING likely.**
- **Evidence:** current-tree replay of I17's selector for seed `20261113`, shape
  `land`, requested 240² chooses a **256²** `src/land` mask because no exact 240²
  land mask exists (`terrain_donor_inputs.gd:180-222`). The selected derived mask
  has only values 0/255: 60,348 zero and 5,188 white pixels. The capture-time
  selection is not logged, so this is not proof of the ellipses' identity.
- **[U] discriminating test:** hide water, entities, legacy relief and donor props
  independently; dump water/shore tile ids and start-cell coordinates. Do not
  label these as mines, forests or shadows from the screenshot alone.

## 6. Current-tree source facts that constrain attribution

These are **[O] code/asset observations** about the current repository. The
capture folder has no build hash or runtime stats, so their linkage to the exact
captured binary is **[U]**.

1. **Requested 240² can become 256².** I17 prefers but does not require an exact
   mask size (`terrain_donor_inputs.gd:210-222`), then sets `p.width/p.height` to
   the native mask (`:267-269`); I07 resolves the grid from those values
   (`terrain_donor_gen.gd:466-481`). Current selector replay chooses 256² for this
   seed/shape. Dump the actual mesh `w/h` before interpreting cell-scale bands.
2. **The current relief-family loop does not stamp relief.**
   `_stage_relief` calls `_setup_patterns_by_type` for mountains/plateau/hills
   (`terrain_donor_gen.gd:1975-2023`), but that function only draws a name and
   increments telemetry (`:2026-2039`); it never chooses a position or calls
   `_stamp_pattern`. Therefore the current snapshot cannot attribute broad organic
   hills to those intended relief families. Actual height must come from mask,
   base/mine/resource stamps or pre-existing live height; capture-time code may
   differ.
3. **Interior steep-cell cliff art has a fail-closed gap.** `_collision_pass`
   leaves steep cells at tag 0 when the cliff tag is unknown
   (`terrain_donor_gen.gd:1148-1159`), while `_cliff_triggered` tests `tag>0`
   (`:1244-1250`). Thus interior steep geometry may exist without rock-art
   selection unless an override was supplied.
4. **The alpha path is a single blended draw, not a proven two-layer composite.**
   Shader `:30-40` states the base-layer requirement; mesh `:726,786-793` creates
   one surface. Pass count is an unused telemetry uniform with unset sentinel 0
   (`terrain_donor_shader.gdshader:138-143`).
5. **Eye-plane and texture-matrix runtime values are not recovered.** The shader
   defaults are identity planes/matrix (`:95-118`); donor runtime values are
   explicitly UNVERIFIED. Mask UV and tile UV therefore cannot be assumed
   world-correct merely because the equations resemble donor text.
6. **Lighting omissions are real but secondary to the hard banding.** The donor
   shader has no shadow sampler/PCF or fog (`:42-50`); X35 measured that these
   omissions remove depth cues but do not create olive albedo or veins
   (`reports/X35_lighting_env_spec.md:20-22,133-142`).

## 7. Comparison against all 12 donor stills — direction only

The ROIs below are ground-focused selections from X07, with A3/A4/A7 adjusted to
the named class feature. They are **not** calibrated world-space regions.

| ID / file | Full px | ROI px | grad p95 | σ16 | row jump | FFT anis | sat / CF | Confound / use |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| A0 `3173885360_preview_Turkish battle 19 Light Infantry rush.jpg` | 1920×1080 | `[19,669,364,907]` | 58.38 | 33.66 | 82.14 | .243 | .057/10.1 | snow + stone/HUD; shape only, not green terrain |
| A1 `523480776.jpg` | 720×405 | `[0,243,129,372]` | 10.53 | 10.92 | 33.91 | .491 | .593/23.5 | grass beside mill field; small ROI |
| A2 `899956545_preview_20170411195032_1.jpg` | 1366×768 | `[27,384,273,552]` | 25.67 | 10.16 | 5.10 | .245 | .554/24.3 | uniform-green lower comparator |
| A3 `Cossacks3AttackingVillage.webp` | 2355×1376 | `[894,137,1365,412]` | 20.14 | 15.69 | 2.45 | .228 | .419/23.3 | dirt clearing; units possible |
| A4 `MADVBuilding1.JPG` | 485×486 | `[9,9,67,77]` | 14.83 | 2.74 | 3.18 | .156 | .455/27.6 | sand/dirt; building edge + tiny ROI |
| A5 `articolo-787.jpg` | 960×540 | `[326,86,595,183]` | 34.67 | 8.19 | 5.72 | .144 | .512/28.3 | rolling hill; smoke/pines possible |
| A6 `cossacks-3-guardians-of-the-highlands-pc-gioco-steam-wallpaper-3.jpg` | 1916×1080 | `[574,907,804,1058]` | 59.60 | 14.91 | 8.93 | .303 | .444/33.0 | construction ground/shadow; no mountain |
| A7 `cossacks-3-v1-498085.jpg` | 1280×720 | `[460,115,844,273]` | 27.15 | 16.35 | 3.17 | .484 | .461/27.3 | earthwork/ravine lip; trees at lip |
| A8 `hqdefault.jpg` | 480×360 | `[134,244,220,309]` | 19.51 | 10.70 | 6.15 | .516 | .572/25.6 | low-resolution thumbnail |
| A9 `images.jpg` | 588×340 | `[246,170,305,204]` | 37.35 | 1.88 | 7.65 | .371 | .488/26.3 | tiny low-resolution ground patch |
| A10 `large_1.webp` | 788×377 | `[15,199,94,256]` | 3.81 | 1.40 | 1.55 | .246 | .608/16.9 | intentional uniform-grass low outlier |
| A11 `maxresdefault_1.jpg` | 512×288 | `[25,57,143,120]` | 18.19 | 5.08 | 5.75 | .547 | .440/22.6 | green land; low-resolution shore candidate |

Across these 12 confounded ROIs the median gradient p95 is `22.91`, median σ16
`10.43`, median row jump `5.74`, median FFT anisotropy `.274`, median saturation
`.475`, and median colorfulness `24.95`. **These are descriptive corpus values,
not acceptance thresholds.**

### 7.1 Directional findings

- **Flat lower bound:** 240b `LC` (gradient p95 `5.25`, σ16 `1.48`, row jump
  `2.43`) is directionally near the intentionally uniform A10 grass patch
  (`3.81/1.40/1.55`). This supports “too uniform,” not donor similarity.
- **Hard versus soft relief:** A5/A7 show that readable relief can have gradient
  p95 `34.67/27.15` without 240c's row jump `16.97`; their row jumps are
  `5.72/3.17`. The 240c problem is therefore not simply “enough gradient”; it is
  the concentration of change into hard, repeated boundaries.
- **Anisotropy:** 240c `T/UL` FFT `.596/.610` exceeds every donor ground ROI here
  (maximum `.547`, itself a 512×288 thumbnail). 240b `UL` `.619` shows that some
  diagonal art exists even without geometry. X06's asset-level anisotropy makes
  TILE ART a credible source, while unknown camera/compression prevents a donor
  numeric comparison.
- **Colour:** 240b full saturation `.616` is at the high end of the donor green
  ROIs; 240c full saturation `.361` is below their median `.475`. 240c `LC` is
  very dark (`Y=28.21`) compared with donor green ground (`Y≈62..81` in A2/A5/A7/
  A9/A10). This is a direction-of-movement warning only.
- **Props:** donor stills show textured masonry, roofs, trees, fields and coloured
  units. Both captures' pure-black silhouettes are a clear visual divergence in
  readability, independent of terrain parity.
- **Class ceiling:** X07/X36 confirm there is no reliable mountain still, no
  certifiable sea/river/swamp, and no identifiable iron/coal mine in this corpus
  (`reports/X07_visual_reference_index.md:30-46,214-232`;
  `reports/X36_mountain_visual_recheck.md:25-55`). The “highlands” filename is
  not mountain evidence. The A11 shore remains `[I]` structure / `[U]` identity.

## 8. What remains UNVERIFIED

| ID | Unknown | Why | Discriminating test |
|---|---|---|---|
| W01-U1 | Capture-time height extrema, grid size and step locations | no runtime dump/build hash | dump `height[]`, mesh `w/h`, vertex Y and height deciles at pinned camera |
| W01-U2 | How much of 240c is GEOMETRY vs SHADING/NORMAL | screenshot conflates silhouette and lighting | constant-albedo normal render + height/normal overlays |
| W01-U3 | How much diagonal checker is ALPHA vs tile RGB | both use eye-plane-like coordinates and directional art | alpha greyscale pass; force alpha 1; constant atlas pass |
| W01-U4 | Whether low alpha reveals clear colour because no base pass exists | architectural risk, but no draw/colour dump | clear-colour A/B and opaque-base A/B |
| W01-U5 | Why 240c foreground is uniformly dark | simple alpha regression and flat-tile comparison are inconclusive | normal-only, alpha-only and tile-id diagnostics |
| W01-U6 | Identity of the three black ellipses | could be prop, water or start-mask geometry | layer isolation + water/tile/start-coordinate dump |
| W01-U7 | Exact capture-time I17 mask/pattern selection | current-tree replay is not a runtime log | record I17 `stats()` and mesh grid with capture |
| W01-U8 | Donor parity | no same-camera donor GPU frame | owner-only admissible A/B under X39; until then parity stays UNVERIFIED |

## 9. COORD handoff — minimum next diagnostics, in order

1. Capture one pinned frame with **height min/max/deciles, tile-id histogram,
   face histogram, normal summary, mesh w/h, alpha-mask histogram and actual
   eye-plane/texture-matrix uniforms**. No visual tuning before this exists.
2. Render four diagnostics from the same frozen camera/seed: normal-only,
   alpha-only, tile-RGB-only, and height-wire/step overlay.
3. Re-capture b/c with the camera transform pinned independently of terrain height;
   current black-component bboxes shift 1–6 px, so the present pair is not a
   pixel-registered A/B.
4. Isolate entity/relief/donor-prop/water groups to identify the black silhouettes
   and ellipses before assigning their class.
5. Only after layer separation, compare direction against A5/A7 (soft relief),
   A2/A10 (uniform lower bound), and A1/A3 (field/decor composition). Do not create
   a donor-match threshold from these third-party stills.

## 10. Final parity statement

**Donor parity is UNVERIFIED.** The two live captures prove only that the donor
backend produced nonblank 1280×720 frames with different terrain appearances.
They do not prove donor-faithful geometry, tile selection, alpha composition,
lighting, props, or landscape composition. The 12 stills remain direction-only
references of unknown build, camera, zoom, world area and compression.

*End of W01. Exactly one report written; no source, shader, config, asset, test,
Godot runner, donor binary or git edit.*
