---
id: A07
ticket: TERRAIN-SWARM-2026-11-25 / A07
title: "Colour & lighting — why the current ground is olive and the donor ground is green"
owner: A07 (read-only diagnosis)
status: DONE
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROX]
godot_jobs_run: 0
code_files_edited: 0
---

# A07 — Colour / lighting quantification and render-math attribution

## 0. Scope, inputs, method, label legend

**Scope (as dispatched).** Quantify the current frame and three donor JPGs with Pillow
(whole-frame and ground-region mean/median RGB, luma, saturation, histogram spread,
spatial variance at several block sizes); trace `terrain_tileindex.gdshader:150-158`,
`:294-306`, `:427` plus `world3d_terrain.gd` sun/uniform binding and every
`WorldEnvironment`; decide numerically whether the olive-vs-green gap comes from
atlas albedo, light energy, gamma, or mask attenuation; give three concrete correction
options with exact constants/locations. **Read-only: no code edits and no Godot jobs.**

**Inputs (all opened read-only):**

| Role | Path |
|---|---|
| Current frame | `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p0fresh01\p0_final_formula.png` (1280×720 RGBA) |
| Donor A (charter sample A) | `C:\Users\Maxym.Oboyshev\Downloads\c3\cossacks-3-v1-498085.jpg` (1280×720) |
| Donor B (charter sample B) | `C:\Users\Maxym.Oboyshev\Downloads\c3\articolo-787.jpg` (960×540) |
| Donor C (in-game HUD frame, third JPG) | `C:\Users\Maxym.Oboyshev\Downloads\c3\899956545_preview_20170411195032_1.jpg` (1366×768) |
| Atlas / masks | `variant3d/assets/terrain/atlas/tile_index_atlas.png`, `alpha.png`, `tile_index_atlas.manifest.json` |
| Shader / module / capture JSON | `variant3d/shaders/terrain_tileindex.gdshader`, `variant3d/scripts/world3d_terrain.gd`, `variant3d/tests/results/t_terrain_only.json` |

**Method [PORT APPROX — measurement conventions, not donor values].** Pillow 12.1.1 +
numpy 2.4.3; scripts live only in session temp (`a07_analyze.py`, `a07_math2.py`,
`a07_math3.py`), JSON results in `a07_results.json`; nothing was written into the repo
except this report. `Y' = 0.2126R+0.7152G+0.0722B` on 8-bit sRGB bytes; saturation
`S=(max-min)/max` (HSV); Lab `a*`/`b*` via the standard sRGB→XYZ(D65)→Lab transform;
block variance = std of non-overlapping block-mean `Y'` at B∈{8,16,32,64,128} px,
paired with the mean within-block `Y'` std. Ground ROIs were chosen by eye to be
grass-only (coordinates below are **[PORT APPROX]**):

- A: `(540,500,760,660)`, `(300,60,520,200)` — pooled 66,000 px; first ROI 220×160.
- B: `(540,100,720,200)`, `(380,360,560,460)` — pooled 36,000 px; first ROI 180×100.
- C: `(520,90,740,210)`, `(280,280,500,400)`, `(1180,90,1360,210)` — pooled 74,400 px; first ROI 220×120.
- P0: the entire frame is ground (no sky/geometry), so whole-frame == ground.

**Labels.** `[O]` observed from files/pixels; `[D]` derived arithmetic; `[I]` inferred;
`[U]` UNVERIFIED (no donor GPU A/B exists — charter §3). Every number introduced by
this report that is **not** explicitly tagged `[DONOR]` with a donor path:line is
**PORT APPROX**, including all ROI boxes, block sizes, Rec.709/Lab coefficients,
exposure/energy compensation, and all proposed constants. Donor-cited literals are
tagged `[DONOR]` in §2. Cross-check: A11 (`A11_reference_metrics.md:96`) measured P0
mean RGB `(93.73,96.76,31.62)`, `Y'` std `10.6`, S `0.675` — this report reproduces
the same frame to ±0.02 byte, confirming the sampling pipeline.

---

## 1. Pixel quantification

### 1.1 Whole frame and ground region — mean / median colour, luma, saturation (OBSERVED)

All RGB values are 8-bit sRGB means; `a*`/`b*` use D65 Lab **[PORT APPROX]**.

| Image | Region | mean RGB | median RGB | Y' mean / med | S mean | Lab a* / b* | R/G | B/G |
|---|---|---|---|---|---|---|---|---|
| P0 final formula | whole = ground | **93.75, 96.78, 31.64** | 93, 97, 32 | **91.43 / 91.17** | **0.674** | **−10.64 / 35.44** | 0.970 | **0.326** |
| A cossacks-3-v1 | whole | 81.91, 77.89, 45.07 | 84, 79, 41 | 76.38 / 77.81 | 0.486 | −3.47 / 19.62 | 1.138 | 0.571 |
| A cossacks-3-v1 | ground (pooled 2 ROIs) | 96.69, 96.88, 51.55 | 100, 102, 48 | 93.56 / 97.60 | 0.494 | −7.20 / 25.50 | 1.017 | 0.532 |
| B articolo-787 | whole | 75.89, 73.10, 50.58 | 71, 71, 39 | 72.06 / 69.18 | 0.443 | −2.40 / 13.82 | 1.091 | 0.674 |
| B articolo-787 | ground (pooled 2 ROIs) | 67.27, 66.29, 41.84 | 62, 62, 34 | 64.73 / 59.90 | 0.457 | −3.69 / 14.88 | 1.041 | 0.615 |
| C preview | whole | 69.11, 69.80, 35.47 | 75, 79, 32 | 67.17 / 74.40 | 0.543 | −5.65 / 19.84 | 1.146 | 0.483 |
| C preview | ground (pooled 3 ROIs) | 78.18, 82.14, 34.27 | 78, 83, 33 | 77.84 / 78.54 | 0.591 | −9.36 / 27.06 | 0.951 | 0.410 |

**A07-E1 [O].** P0's **luma is not too dark**: 91.43 sits inside the donor ground
range 64.7–93.6 and essentially equals donor A's ground luma 93.56. The defect is
**chromatic and textural, not exposure-level**.

**A07-E2 [O].** P0's `B/G = 0.326` is **below every donor ground ROI** (0.410–0.615),
and its Lab `b* = 35.44` is above every donor (`14.88–27.06`). In Lab terms P0 is
*more* green on the a* axis (−10.64 vs −3.69…−9.36) but far more **yellow** on b*:
the "olive" is a **blue-deficient / yellow-biased** palette, not a lack of green.
P0's saturation 0.674 is also the highest in the set (donors 0.457–0.591), agreeing
with A11 (`A11_reference_metrics.md:98-101`).

### 1.2 Histogram spread (OBSERVED, luma percentiles, sRGB bytes)

| Image / region | p1 | p5 | p25 | p50 | p75 | p95 | p99 | p5–p95 | std |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| P0 whole/ground | 65.7 | 74.9 | 84.7 | 91.2 | 98.2 | 108.9 | 117.3 | **34.0** | **10.60** |
| A ground ROI 1 | 24.1 | 45.4 | 81.8 | 96.7 | 102.8 | 115.3 | 153.1 | 69.8 | 23.28 |
| A ground pooled | 30.8 | 52.2 | 90.0 | 97.6 | 102.9 | 114.3 | 150.4 | 62.1 | 20.23 |
| B ground ROI 1 | 24.2 | 32.9 | 47.3 | 57.8 | 72.1 | 97.0 | 177.7 | 64.1 | 25.41 |
| B ground pooled | 18.3 | 30.1 | 47.0 | 59.9 | 78.0 | 114.9 | 176.8 | 84.7 | 28.37 |
| C ground ROI 1 | 41.1 | 51.1 | 74.4 | 80.8 | 86.6 | 98.3 | 115.0 | 47.2 | 14.23 |
| C ground pooled | 45.3 | 58.9 | 72.3 | 78.5 | 83.8 | 93.7 | 108.4 | 34.8 | 11.59 |

**A07-E3 [O].** P0's histogram is narrow and symmetric (`p5–p95 = 34`, all pixels
65–117); donor grounds have dark tails (`p1` 18–45) and bright mottling (`p95` 93–115,
`p99` 108–177). C's pooled p5–p95 (34.8) is similar to P0, but C still has real
multi-scale patches (below) while P0 does not.

### 1.3 Spatial variance at multiple block sizes (OBSERVED / DERIVED)

`B` = block side in px **[PORT APPROX]**; "between" = std of block-mean `Y'`;
"within" = mean of per-block `Y'` std; ratio = between/within. Larger "between"
means large-scale organic mottling; larger "within" means fine grain.

| Image / region | B=8 | B=16 | B=32 | B=64 | B=128 |
|---|---|---|---|---|---|
| P0 (between / within / ratio) | 4.02 / 9.70 / **0.41** | 3.65 / 9.91 / 0.37 | 3.28 / 10.04 / 0.33 | 3.06 / 10.12 / 0.30 | 2.64 / 10.15 / **0.26** |
| A ground ROI (between / within / ratio) | 15.14 / 12.49 / **1.21** | 14.28 / 14.05 / 1.02 | 13.59 / 15.70 / 0.87 | 13.71 / 15.66 / 0.88 | n/a (ROI too small) |
| B ground ROI (between / within / ratio) | 17.58 / 11.21 / **1.57** | 14.58 / 14.14 / 1.03 | 11.61 / 17.79 / 0.65 | n/a | n/a |
| C ground ROI (between / within / ratio) | 9.09 / 9.05 / **1.00** | 8.14 / 10.21 / 0.80 | 6.98 / 11.73 / 0.60 | n/a | n/a |

**A07-E4 [O]+[D].** P0's between-block luma std *decreases* with block size
(4.02→2.64) and is always **smaller** than the within-block grain (ratio ≤0.41):
there is essentially **no large-scale colour field**, only fine grain plus faint
smears. Every donor ground ROI has between-block std **≥** within-block grain at
small blocks (ratio 1.0–1.57) — that is the "lush varied" mottling. A11's
resolution-normalised block variance reaches 23–69× P0 (`A11_reference_metrics.md:140`).

---

## 2. Render-math trace (what actually produces P0's colour)

### 2.1 Shader constants and equations (SOURCE OBSERVED)

`variant3d/shaders/terrain_tileindex.gdshader`:

- `:43` `render_mode blend_mix, unshaded, cull_disabled` — the terrain is **unshaded**;
  Godot's `DirectionalLight3D`/ambient light in §2.3 cannot shade ALBEDO. Only the
  shader's own embedded Blinn-Phong and the WorldEnvironment tonemap/exposure can.
- `:150-158` donor light constants: `donor_sun_position = (-0.344731152057648,
  0.938701450824738, 0)` `[DONOR light.cfg:26-31]`; `ambient_rgb = (0.196078434586525,
  0.184313729405403, 0.129411771893501)` `[DONOR light.cfg:2-7]`;
  `diffuse_rgb = (0.811764717102051, 0.780392169952393, 0.694117665290833)`
  `[DONOR light.cfg:9-14]`; `:160` `specular_rgb = vec3(0)` `[DONOR material
  reftile.mat:98-102/:70-74]`; `:165` `shininess = 16` `[DONOR reftile.mat:76]`.
- `:294-306` Blinn-Phong: `sun_world = normalize(donor_sun_position)` (lsParallel,
  no `realpos` subtraction); `l = normalize(VIEW*sun_world)`,
  `e = normalize(-realpos)`, `h = normalize(l+e)`, `n = normalize(VIEW*MODEL*NORMAL)`;
  `v_packed = ambient_rgb + max(dot(l,n),0)*diffuse_rgb`;
  `v_specular = pow(max(dot(h,n),0), shininess)*specular_rgb`.
- `:332-338` + `:392` `rgb = tile_rgb(v_tile, fract(v_st*uv_repeat))`: the RGB comes
  from one donor atlas cell (`atlas_grid=(16,8)` `[DONOR/V7-85]`), repeated every
  `uv_repeat=0.5` → 2 m `[DONOR gc_meters_to_tile=2, dmscript.global:171]`.
- `:365-378` + `:419` mask patch selection; `:235-246` `mask_to_alpha=1.0`
  **[PORT APPROX]** folds mask intensity into RGB; `:427`
  `rgb = rgb * mix(1.0, a, mask_to_alpha) * v_packed + v_specular`.
- `:472-475` `ALBEDO = rgb; ALPHA = 1.0`; `:456-466` fog is OFF (`fog_mode=0`).

### 2.2 Module binding / WorldEnvironment (SOURCE OBSERVED)

`variant3d/scripts/world3d_terrain.gd`:

- `:137-151` the same donor light colours plus port-side compensations:
  `EXPOSURE = 1.45`, `AMBIENT_ENERGY = 1.10`, `SUN_ENERGY = 1.7` — all
  **[PORT APPROX M0.6]**, explicitly *not* donor values (`:127-128`).
- `:682-721` `_tileindex_material()` binds `tile_atlas`, masks, `atlas_grid`,
  `ambient_rgb` (`:698`), `diffuse_rgb` (`:699`), **`specular_rgb` = DONOR_SPECULAR
  `(0.278431385755539, 0.266666680574417, 0.211764708161354)` `[DONOR light.cfg:20-23]`
  at `:700`**, `donor_sun_position` (`:704`), `shadow_enabled=0` (`:709`),
  `fog_mode=0` (`:711`). `mask_to_alpha` is deliberately **not** bound (`:718-719`).
- `:1114-1143` `_make_environment()` creates the only `WorldEnvironment`:
  `BG_SKY`, donor sky colours, **`tonemap_mode = TONE_MAPPER_LINEAR`,
  `tonemap_exposure = EXPOSURE = 1.45` **[PORT APPROX]** (`:1133-1134`)**,
  `ambient_light_source = COLOR` with donor ambient × `AMBIENT_ENERGY` (`:1135-1139`).
  `:1145-1166` `DirectionalLight3D "DonorSun"` with donor diffuse colour,
  `SUN_ENERGY = 1.7` **[PORT APPROX]** and `shadow_enabled=false`.
- Capture context `variant3d/tests/results/t_terrain_only.json:151,159-161,180-185`:
  `atlas_grid=(16,8)`, `uv2_x_min = uv2_x_max = 0`, `uv2_y_hist={"0":4096}` →
  **all 4,096 vertices sample atlas cell 0 = `grass1`, face mode 0**; mean luma
  `91.4320785333257`, max `155.163` — the exact frame measured in §1.

**A07-E5 [O]+[D].** The whole P0 frame is one atlas cell under one lighting term:
there is no spatial lighting variation to create mottling. The donor light rig,
WorldEnvironment ambient and DirectionalLight are *inert* for this material because
of `unshaded` at shader `:43`; only `tonemap_exposure` can reach the final colour,
and whether the SubViewport readback applies it is a known open question
(`P0_FRESH_CAPTURE_01.md:203-204`) — the numeric check below supports that it does.

### 2.3 Numeric replay of the shader chain ([D]; engine readback path [U])

Measured inputs **[PORT APPROX measurement]**: atlas cell 0 (`grass1`) full-cell mean
sRGB `(76.01, 82.46, 30.39)`, linear `(0.07347, 0.08689, 0.01346)`; alpha patch for
tile 0 (`alpha_patch_uv(0,·)` → `(col,row)=(0,0)`) is **constant 255 → mask `a = 1.000`**.
Flat ground `n = world +Y`; `lsParallel` sun normalised `(-0.344731, 0.938701, 0)`
`[DONOR]` ⇒ `dot(l,n) = 0.938701` (rotation invariant). Therefore

```
v_packed = ambient + 0.938701 × diffuse
         = (0.958083, 0.916869, 0.780981)          [DONOR colours]
           G/R = 0.95698,  B/R = 0.81515           (warm: blue −18.5 % vs red)
```

Predicted final sRGB bytes (linear → ×1.45 exposure → sRGB encode **[PORT APPROX model]**):

| Model arm | predicted RGB | Δ vs observed P0 |
|---|---|---|
| albedo × v_packed, **no exposure**, mask=1, spec=0 | (75.01, 79.73, 26.29) | (−18.7, −17.1, −5.4) |
| albedo × v_packed × **exposure 1.45**, mask=1, spec=0 | **(89.92, 95.43, 33.04)** | **(−3.83, −1.35, +1.40)** |
| same + bound donor specular (camera pitch −32° **[PORT APPROX]** ⇒ `dot(h,n)=0.8486`, `pow16=0.0724`, `v_specular=(0.02015,0.01930,0.01532)`) | (101.42, 105.78, 54.44) | (+7.7, +9.0, **+22.8**) |
| albedo × v_packed × mask=0.49 (mean of all 32 mask patches **[PORT APPROX]**) × exposure | (66.19, 70.44, 22.29) | (−27.6, −26.3, −9.4) |

**A07-E6 [D], with [U] qualifier.** The *no-specular, exposure-applied* arm matches
the captured frame within **≤3.8 byte per channel** (luma 89.8 vs 91.43, 1.8 %).
This is strong evidence that (i) the sRGB→linear→exposure→sRGB path is active for the
unshaded material in this build and (ii) **mask attenuation is not active in P0**
(the sampled patch is 1.0). The large blue over-prediction when the donor specular
binding is included is **UNRESOLVED [U]**: it can be reconciled either by
`specular_rgb` being effectively zero at capture time or by the exposure/readback
factor differing from the assumed 1.45 — no GPU A/B was run, so neither is claimed.
Either way the bound specular term is *warm-grey* (`B/R ≈ 0.76`), so it moves colour
**toward grey, not toward olive**, and cannot be the cause of the blue deficit.

### 2.4 Historical caveat [O]

`git log` shows commits `2411a752` (11:23 UTC), `4d487359` (12:39 UTC) and `8e9de1bf`
(13:11 UTC) touched these two source files **after** the 10:41 UTC capture; current
file mtimes are 13:31/13:33 UTC. `git diff 49aa81f7 HEAD` shows the post-capture change
`rgb = rgb*v_packed + v_specular` → `rgb = rgb*mix(1,a,mask_to_alpha)*v_packed +
v_specular` (MASK-ALPHA-FIX-01). So the captured frame used the **old RGB path without
mask modulation**, which is exactly why the "mask=1" arm above is the matching one.
Current tree arithmetic is reported for handoff, but no claim is made that the current
tree has itself been GPU-captured.

---

## 3. Olive vs green — numerical attribution

Requirement: turn P0 `(93.75,96.78,31.64)` / `b*=35.44` into donor-A-like ground
`(96.69,96.88,51.55)` / `b*=25.50` while keeping luma in the 64–94 band.

Inverting the model (mask=1, spec=0, exposure=1.45, v_packed from §2.3) gives the
**required atlas albedo sRGB `(82.5, 84.5, 48.2)`** versus current `grass1`
`(76.0, 82.5, 30.4)`: **blue +17.8 bytes (+58 %)**, green +2, red +6.5. In linear
terms the required albedo `B/G = 0.290` vs current `0.155` — **1.87× more blue
relative to green** (donor C needs ~1.2×; target band 1.2–1.9×).

| Candidate cause | Verdict | Numbers / reasoning |
|---|---|---|
| **Atlas albedo** | **RANK 1 — primary cause [D]+[O]** | `grass1` albedo itself is yellow-olive: linear `B/G=0.155`, byte `B/G=30.4/82.5=0.368`. Dominant term in the product at `:427`; the required fix is almost entirely a blue lift in the atlas art/tint. |
| **Light energy / colour** | **RANK 2 — amplifier only [D]** | `v_packed` is nearly neutral-warm: `G/R=0.957`, `B/R=0.815`. It makes the albedo blue deficit ~14 % worse but cannot create it; scalar exposure 1.45 sets brightness (P0 luma already in donor range, E1). Donor ambient/diffuse are verbatim light.cfg colours, so changing them breaks the donor citation. |
| **Gamma / tone map** | **NOT a cause [D], engine path [U]** | sRGB decode → linear multiply → sRGB encode reproduces observed RGB within 3.8 byte; no double-gamma signature. Higher exposure slightly *raises* byte `B/G` (0.330→0.346 for 1.0→1.45), so lowering exposure would make the yellow **worse** — do not "fix" this by darkening. |
| **Mask attenuation** | **NOT a hue cause [D]** | Tile 0 selects constant-255 patch (`a=1.000`) and the capture predates mask-in-RGB; where masks are <1 they multiply all channels equally (`:427`) → dim only. Patch means 0.000–0.849 **[PORT APPROX measurement]** explain dark blotches elsewhere, not olive. |
| **Specular binding** | **NOT a hue cause [U]** | Bound donor specular `(0.278,0.267,0.212)` is warm-grey; if active it would *raise* blue by ~22 byte and desaturate toward grey. Contradicts P0's blue deficit; likely near-zero at capture (E6). |

**A07-F1 [O]+[D].** The olive is **atlas albedo first**: a yellow-biased `grass1`
cell (linear blue only 15.5 % of green) sampled identically across the whole frame,
with a mildly warm donor light multiplier and an exposure that is already correct in
brightness. It is **not** a light-energy, gamma, or mask-attenuation defect.

**A07-F2 [O]+[D].** The "varied green" half of the gap is separate: with `UV2.x ≡ 0`
there is no tile variety at all in P0; E4 quantifies the missing multi-scale field.
Fixing hue alone will not produce donor-looking ground without the data/relief work
owned by other tickets (A01/A03/A04/A05).

---

## 4. Three concrete correction options (PROPOSALS ONLY — no code was changed)

All constants below are **[PORT APPROX]** unless tagged `[DONOR]`. Each option names
the exact file/line; any implementation belongs to a Wave-B owner, not A07.

### Option 1 — Raise the atlas/albedo blue channel (root-cause fix; recommended first)

- **Location:** `variant3d/shaders/terrain_tileindex.gdshader:392` — apply a permanent
  albedo tint immediately after `vec3 rgb = tile_rgb(...)`, e.g.
  `rgb *= ALBEDO_TINT;` with a new `uniform vec3 ALBEDO_TINT = vec3(1.0)`;
  bind it beside the other parameters at `world3d_terrain.gd:689-692`.
  Alternatively re-grind `grass1.png` in the atlas build
  (`variant3d/tools/build_tile_index_atlas.py`) — prefer the shader uniform for a
  reversible A/B.
- **Constants [PORT APPROX, calibrated to donor A pooled ground in §3]:**
  linear-space tint `vec3(1.164, 1.032, 2.214)` (= required albedo / current albedo).
  Conservative first step `vec3(1.00, 1.00, 1.50)` moves predicted blue ≈31.6→≈37
  byte, `B/G` 0.326→≈0.39, without changing luma materially.
- **Expected:** donor-A hue direction (b* 35.4→≈29 at full tint) while luma stays
  ≈93 (inside donor band). **Risk:** >2× blue on a dark albedo can look bluish on
  bright sand/rock cells; scope the tint to grass ids (tile ids 0–16) or expose it
  as a uniform and A/B before landing.
- **Verify:** re-measure P0 ground with this report's Pillow method; target `B/G`
  0.41–0.53, `b*` 25–27, S 0.50–0.59.

### Option 2 — Neutralise the warm light-product bias (secondary; donor-tagged colours stay intact)

- **Location:** `variant3d/scripts/world3d_terrain.gd:698-699` bindings (or the shader
  defaults at `terrain_tileindex.gdshader:154,157`). Keep donor colours as the base
  and add a **[PORT APPROX]** neutral blue fill rather than replacing donor literals.
- **Constants [PORT APPROX]:** to equalise `v_packed` `B/R` to its `G/R` (0.95698),
  raise blue by `0.95698−0.78098 = +0.13589`: either ambient blue
  `0.129411771893501 → 0.26530`, or diffuse blue `0.694117665290833 → 0.83891`.
  This is a **port compensation**, not a donor value — label it as such in code.
- **Expected:** removes the ~14 % extra blue attenuation from the light term;
  moves P0 `B/G` 0.326→≈0.36 and b* down a few units. **Risk:** shifts every
  lighted donor atlas cell (rock/sand too); avoid unless Option 1 proves
  insufficient. Do **not** change `EXPOSURE` (`:149`/`:1134`) — E6 shows it is
  already correct in magnitude and lowering it increases yellowness.

### Option 3 — Align the specular binding and run a two-arm isolation A/B (correctness + measurement)

- **Location:** `variant3d/scripts/world3d_terrain.gd:700`; set
  `mat.set_shader_parameter("specular_rgb", Vector3(0, 0, 0))` to match the shader's
  donor-cited default `vec3(0)` at `terrain_tileindex.gdshader:160-163` and donor
  material specular = 0 `[DONOR reftile.mat:98-102/:70-74]`. Keep the light.cfg
  specular colour in `stats` only (`:1607-1616`), not in the shading path.
- **Constants [PORT APPROX / DONOR]:** arm A = current bound
  `(0.278431..., 0.266667..., 0.211765...)` `[DONOR light.cfg:20-23]`; arm B =
  `(0,0,0)` (donor material specular). Same camera, same tileblock id 0,
  same `EXPOSURE = 1.45` **[PORT APPROX]**.
- **Expected:** arm B predicts `(89.92,95.43,33.04)` vs arm A `(101.42,105.78,54.44)`
  under the §2.3 camera model; the observed P0 `(93.75,96.78,31.64)` is much closer
  to arm B. This A/B resolves open question **A07-E6** (whether the donor specular
  binding is live) and removes an additive warm-grey term that works against green.
  **Risk:** near-zero expected visual change if the term was already inert; value is
  in eliminating an unquantified engine discrepancy before palette tuning.
- **Verification guard:** existing gates must stay green (charter §5: selftest
  29/29, uitest 17/17, `t_render_mode`, `assert_clean` CLEAN); no threshold changes,
  no synthetic dither/noise field (S-25-09).

---

## 5. Evidence index and open questions

| ID | Class | Statement |
|---|---|---|
| A07-E1 | [O] | P0 luma 91.43 is inside donor ground range 64.7–93.6 — brightness is not the defect. |
| A07-E2 | [O] | P0 `B/G=0.326`, `b*=35.44`, S=0.674 vs donor ground `B/G 0.410–0.615`, `b* 14.9–27.1`, S 0.457–0.591 — yellow/blue-deficient, not "not green enough". |
| A07-E3 | [O] | P0 luma p5–p95=34, no dark tail; donors 35–85 with p1 18–45. |
| A07-E4 | [O]+[D] | P0 between/within block variance ≤0.41 and falling with block size; donors ≥1.0 at small blocks. |
| A07-E5 | [O]+[D] | `unshaded` at shader `:43` makes in-scene lights inert; only WorldEnvironment exposure can act. |
| A07-E6 | [D]+[U] | Exposure-applied no-specular arm matches P0 within 3.8 byte; specular/exposure split UNVERIFIED without GPU A/B. |
| A07-F1 | [O]+[D] | Root cause = atlas albedo blue deficit (linear B/G 0.155 vs required 0.290), amplified ~14 % by warm donor light. |
| A07-F2 | [O]+[D] | Uniformity is a fixture/data property (`UV2.x≡0`), separate from hue. |

**Open questions [U].** (1) Does the SubViewport readback apply `tonemap_exposure`
identically to the windowed frame? (2) Is `specular_rgb` bound live at runtime, and
what is the actual camera `dot(h,n)`? (3) Donor ground target values are JPEG-sourced
and include donor lighting/color grading; a donor GPU A/B is still the only parity
proof (charter §3). (4) Current tree is post-capture (§2.4) — no fresh capture was
requested or run by this read-only ticket.

**Handoff.** Options 1–3 are proposals for Wave B; COORD owns sequencing and any
disjoint file assignment. All non-donor constants in this report are **PORT APPROX**.
*End of report.*
