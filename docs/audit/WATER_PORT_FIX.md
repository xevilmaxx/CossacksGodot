# T2-WATER-2 — Port Water Visual Failure Diagnosis (Cossacks 3 → Godot)

**Lane:** RESEARCH only. No code edits, no Godot runs, no donor assets copied. Exactly one file written (`docs/audit/WATER_PORT_FIX.md`).
**Date:** 2026-11-21. **Owner complaint:** "water effects are also not ok".
**Predecessor:** `docs/audit/TERRAIN_DONOR_WATER.md` (TDR-4). This report continues that ticket with **pixel measurements** of the current shader-overlay build.

---

## 0. Method and reproducibility

| Item | Detail |
|---|---|
| Tools | Pillow 12.1.1 + NumPy (no scipy). Rec.709 luminance `L = 0.2126R + 0.7152G + 0.0722B` on 8-bit sRGB values. |
| Temp workspace | `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\water2\` — crop PNGs (`PORT_DEEP_TL.png`, `PORT_DEEP_B.png`, `REF_DARK_RIVER.png`, `REF_PALE_SHALLOW.png`, `DONOR_WAVES2.png`, `*_glintmask.png`), scripts (`measure_water.py`, `measure_water2.py`, `shore.py`) and result JSON (`water_measurements.json`, `water_measurements2.json`, `shore.json`). |
| Glint definition | Connected bright pixels, 8-connectivity, per-crop threshold (documented per row). Components counted by BFS; size histogram reported. |
| Ripple metric | Row-wise mean-removed 1-D autocorrelation (ACF) of `L`, lags 1–20 px; plus a 4× block-averaged ACF for coarse swell scale. Mean adjacent-pixel `|ΔL|` reported as "roughness". |
| Shore hardness | 5-px median-filtered luminance transect; max gradient; 10–90 % transition width between plateaus sampled 8–20 px either side. |
| Labels | `observed` = read/measured directly; `derived` = arithmetic on observations; `inferred` = plausible interpretation; `UNVERIFIED` = no evidence. |

**Reference-crop caveat (`observed`):** the supplied reference images are gameplay screenshots with trees, units and UI over the water. Boxes were chosen on the cleanest water-only strips available (verified visually via the saved temp crops). The pale-water crop is the cleanest and carries the most weight for ripple/foam metrics; the dark-river crop is 114×12 px and its glint component sizes are inflated by tree edges, so it is used mainly for mean RGB and coarse ACF.

---

## 1. Measurement table — port vs reference (exact boxes)

### 1a. Source files and crop boxes

| ID | Source file | Box (x0,y0,x1,y1) | Size | What it is |
|---|---|---|---|---|
| PORT_DEEP_TL | `app/shots/terrain_sample_128.png` | (40,40,300,250) | 260×210 | open deep water, far from shore |
| PORT_DEEP_TR | `app/shots/terrain_sample_128.png` | (660,30,980,190) | 320×160 | second deep-water patch |
| PORT_DEEP_B | `app/shots/terrain_sample_128.png` | (320,450,880,660) | 560×210 | large deep-water patch |
| PORT_SHORE | `app/shots/terrain_sample_128.png` | transects y=90,120,200,300,470,620 | — | water→land boundaries |
| REF_DARK_RIVER | `...\Downloads\c3\articolo-787.jpg` | (846,0,960,12) | 114×12 | dark river strip, far-right open water |
| REF_PALE_SHALLOW | `...\Downloads\c3\maxresdefault_1.jpg` | (402,162,470,200) | 68×38 | pale shallow water + foam, right of castle |
| REF_PALE_SHORE | `maxresdefault_1.jpg` | vertical x=415, y=150–235 | 85 px | pale water → sand gradient |
| DONOR_WAVES2 | `app/assets/terrain/water_png/diffusewaves2.png` | (60,60,460,460) | 400×400 | the noise sheet the shader actually samples |

### 1b. Colour, luminance, glints, roughness

| Region | mean RGB | mean L | std L | var L | L p05/p50/p95 | glint threshold | glint fraction | glint n (median / max px) | glint pixels in ≤4 px comps |
|---|---|---|---|---|---|---|---|---|---|
| PORT_DEEP_TL | (30.6, 53.3, 61.8) | 49.1 | 28.8 | 827 | 20.6 / 43.2 / 86.2 | L≥125 | **1.81 %** | 885 (1 / 4) | **100 %** |
| PORT_DEEP_TR | (49.1, 70.6, 72.8) | 66.2 | 28.4 | 809 | 26.1 / 67.2 / 108.3 | L≥137 | **1.08 %** | 507 (1 / 3) | **100 %** |
| PORT_DEEP_B | (33.1, 51.2, 57.1) | 47.8 | 29.5 | 868 | 19.5 / 40.8 / 96.5 | L≥125 | **1.54 %** | 1674 (1 / 3) | **100 %** |
| REF_DARK_RIVER | (40.9, 50.6, 51.4) | 48.6 | **7.4** | **54** | 38.6 / 47.9 / 61.0 | L≥62 | 4.2 %* | 12 (1.5 / 22*) | ~60 %* (tree-edge contaminated) |
| REF_PALE_SHALLOW | (178.4, 186.6, 177.3) | 184.2 | 26.5 | 700 | 132.8 / 188.6 / 217.0 | L≥210 | 10.9 % | 33 (1 / 105) | **18 %** (82 % in ≥9 px blobs) |
| DONOR_WAVES2 | (198.8, 198.8, 198.8) | 198.8 | 58.5 | 3425 | 91 / 214 / 255 | — | — | — | white noise, ACF lag1 ≈ −0.004 |

\* REF_DARK_RIVER glint components are dominated by 2 tree-edge pixels; the 22-px component is not water. Do not use as a glint-size target.

**Derived:** port deep-water luminance std is **3.9–4.0×** the dark-river reference (28.4–29.5 vs 7.4) while its *mean* L is almost identical (48–66 vs 48.6). The port has the right average darkness but all of its contrast is pixel-scale speckle instead of wave shading.

### 1c. Glint size distribution (component counts)

| Region | 1 px | 2 px | 3–4 px | 5–8 px | 9–16 px | >16 px |
|---|---|---|---|---|---|---|
| PORT_DEEP_TL | 800 | 71 | 14 | 0 | 0 | 0 |
| PORT_DEEP_B | 1549 | 115 | 10 | 0 | 0 | 0 |
| REF_DARK_RIVER* | 6 | 2 | 1 | 1 | 1 | 1 |
| REF_PALE_SHALLOW | 19 | 7 | 2 | 0 | 1 | 4 |

**Port glints are 100 % single-to-4-pixel dots; there is not one coherent ≥5 px highlight anywhere in the three deep-water boxes.** Reference bright features are coherent 9–105 px foam/ripple patches.

### 1d. Ripple scale / roughness / ACF

| Region | mean \|ΔL\| per px | ACF lag 1 | lag 2 | lag 3 | lag 5 | lag 10 | dominant scale |
|---|---|---|---|---|---|---|---|
| PORT_DEEP_TL | **18.17** | **0.275** | 0.263 | 0.257 | 0.265 | 0.255 | 1 px (flat ACF after lag 1 = aliased noise) |
| PORT_DEEP_TR | 13.05 | **0.470** | 0.460 | 0.455 | 0.455 | 0.446 | 1 px |
| PORT_DEEP_B | 16.32 | **0.321** | 0.318 | 0.311 | 0.305 | 0.303 | 1 px |
| REF_DARK_RIVER | 2.54 | **0.801** | 0.552 | 0.421 | 0.349 | 0.328 | ~24–32 px swell (4× block ACF crosses 0 at ~32 px) |
| REF_PALE_SHALLOW | 6.21 | **0.730** | 0.549 | 0.462 | 0.249 | 0.066 | ~6–8 px ripple coherence; bright lines ~8–14 px apart |
| DONOR_WAVES2 | 64.31 | ≈0.000 | ≈0.000 | ≈0.000 | ≈0.000 | ≈0.000 | 1 px source noise (donor filters it into fBm; port does not) |

**Derived:** port water loses 53–73 % of its luminance correlation in a single pixel; the pale reference loses 27 %. Port per-pixel roughness is 2.1–2.9× the pale reference and 5–7× the dark river.

### 1e. Shore hardness and foam presence

| Transect | Plateau L (water → land) | max smoothed gradient | 10–90 % width | Note |
|---|---|---|---|---|
| PORT y=470, x=170–300 | 72.7 → 100.5 | 14.1 L/px | **3 px** | water side x=170–218 is a **perfectly flat plateau**: L 70.9–72.9, σ≈0.7 over 49 px ≈ 3 m |
| PORT y=90, x=240–460 | 64.1 → 62.0 | 34.0 L/px | 9 px | glint-contaminated |
| PORT y=200, x=240–460 | 32.7 → 69.9 | 31.2 L/px | 13 px | staircase, speckled water |
| PORT y=120, x=300–500 | 55.8 → 60.7 | 156 L/px | **1 px** | single-pixel glint at the edge (L=197) |
| REF_PALE x=415, y=150–235 | 41 → 153 | 27.6 L/px | 6 px (tree shadow → sand); 36–40 px where water → dark UI at x=440/455 | broad smooth gradient, no flat plateau |

| Foam proxy | L mean | frac L>140 | frac L>180 | frac bright & low-saturation |
|---|---|---|---|---|
| PORT shore strip (330,120)–(380,300) | 72.9 | **0.0051** | **0.0027** | 0.0051 |
| REF_PALE_SHALLOW (402,162)–(470,200) | 184.2 | **0.9377** | **0.6885** | 0.9342 |

**Derived:** the port's near-shore water contains ~1/140th the bright foam coverage of the reference (0.27 % vs 69 % at L>180). The visible shoreline feature is a flat teal ring, not foam.

---

## 2. Ranked visual defects (with file:line evidence)

### D1 — CRITICAL: every wave/foam texture fetch is minified 3.8–35× with **no mipmaps** → aliased white noise instead of swells
`app/shaders/water_overlay.gdshader:15-19` declares all four samplers `filter_linear` (no mipmap hint). `app/assets/terrain/water_png/diffusewaves2.png.import:26` (and `diffusewaves0.png.import:26`) set `mipmaps/generate=false`. The donor uses `MinFilter = miLinearMipmapLinear` (`water.mat base`, TDR-4 §3b). With `view_scale = 16 px/m` (`app/scripts/data.gd:113`) and a 1024² sheet (`world.gd:713-732,769-775`), the sampling rates in `water_overlay.gdshader:39-41,81-82` give:

| Sample | Shader line | UV rate | Texels per screen pixel |
|---|---|---|---|
| wave0 `fract(p/7.0 + s1)` | :39 | 1/7 per m | **9.1 : 1** |
| wave1 `fract(p/11.0 + s2)` | :40 | 1/11 per m | **5.8 : 1** |
| wave2 `fract(p/17.0 + s3)` | :41 | 1/17 per m | **3.8 : 1** |
| foam f1 `fract(p*0.16 + …)` | :81 | 0.16 per m | **10.2 : 1** |
| foam f2 `fract(p*0.55 + …)` | :82 | 0.55 per m | **35.2 : 1** |

`observed` texture stats: `diffusewaves2.png` has ACF lag1 ≈ 0 and 64.3 mean |ΔL|/px — it is white noise, so minifying it without mipmaps produces a fresh random value per screen pixel. `derived`: this single defect explains D2 (1-px glints), D3 (no coherent ripple), D4 (no foam structure) simultaneously. The donor's `noise()` reads the same class of texture through mipmapped linear filtering and then shapes it with a 3+9-octave fBm, a rotation matrix `m = mat2(0.72,-1.60,1.60,0.72)` and `sin()` (TDR-4 §4.3); the port's `field()` (`:35-43`) is a plain weighted sum of 3 raw texture lookups with no rotation, no sin shaping and no smoothing.

### D2 — HIGH: glint gain/corona are mis-ported → salt-and-pepper saturation
`water_overlay.gdshader:71-75`. Donor (TDR-4 §4.7): `specular = pow(grad,170)` with **no ×8**, soft term scaled by **×0.25**, corona used as a **divisor** `/= (1.0 + specular1*1.25)`, plus `watershade*specular2*water_specularcolor`. Port: `spec = pow(grad,170)*8`, `spec2 = pow(grad,120)*4`, corona used as a **multiplier** `(0.20+0.80*corona)`, plus an extra broad sheen `pow(grad,24)*0.35`. Effects: (a) 8–32× over-gain, (b) corona sign inverted from suppression to amplification, (c) normal `n = normalize(vec3(vec2(hx-h,hy-h)*1.2, 0.15))` (`:56-60`) uses a 0.7 m finite difference on a field decorrelating every pixel, so `grad≈1` occurs only at isolated 1-px flat spots. Measured: 1.08–1.81 % glint fraction (target 0.3–0.8 %), 100 % of glint components ≤4 px, max 4 px (target median 4–10 px).

### D3 — HIGH: no coherent wave body; luminance variance is speckle, not swell
`water_overlay.gdshader:55,63-64`: `h = field(p)`, `col *= 0.80 + 0.40*h` — a ±20 % modulation of an already-aliased noise field. No refraction, no screen reflection (donor `wavejitter`/`reflectionMap`, TDR-4 §4.4/§4.6) and no `intensity = dot(rescolor, Rec.709)` coupling to the underlying terrain. Measured ACF lag1 0.27–0.47 with a flat tail (no swell peak) vs 0.73–0.80 in references; mean |ΔL| 13–18 vs 2.5–6.2.

### D4 — HIGH: shoreline is a flat teal ring with a hard step; foam is absent/mis-shaped
- `world.gd:894-895` bakes `ter_blue = Color(0.16,0.36,0.44)` as a flat image; `world.gd:1129-1130` uses it as the water substrate.
- `water_overlay.gdshader:88`: `alpha = coverage * mix(0.35, 1.0, coastfade2)` → shallow alpha 0.35, so 65 % of that flat substrate shows through: measured 49-px (≈3 m) constant-L plateau at y=470.
- `water_overlay.gdshader:80-85`: `band = coastfade*(1.0-coastfade2)` is zero exactly at the water's edge and peaks at mid-depth; foam noise `f1/f2` comes from the aliased sheet at 10:1 and 35:1; `nautic = pow(1-f1,5)` (one octave, no ×18 scale), `particles = pow(f2,7)*1.5` (one octave, donor uses ×30). Measured near-shore bright fraction 0.27 % vs 69 % reference.
- `world.gd:831-845`: coverage is a one-tile binary grid (2 m = 32 px) with LINEAR filter only — no sub-tile depth/foam ramp; measured 1–13 px steps.

### D5 — MEDIUM: tint is too cyan and never brightens toward the pale reference
`water_overlay.gdshader:27-28,63` uses donor `-dev` constants `WATERCOLOR=(0.10,0.24,0.24)`, `WATERCOLOR2=(0,0.025,0.05)` and a pure depth mix; no refraction-luminance `intensity`, no `watercolor *= 2.2 + watershade`. Measured port mean B−G = +2.2…+8.4 (cyan) vs dark river +0.9 (neutral) and pale shallow −9.2; port shallow L≈73 vs pale reference L≈184. The retail reference water tone is much more neutral and, in shallow water, far brighter.

### D6 — MEDIUM: three incommensurate scrolls read as boiling, not flowing
`water_overlay.gdshader:36-38`: `s1=(0.125,0.090)t`, `s2=(0.140,-0.100)t`, `s3=(-0.080,0.065)t`. At the current UV scales this is ~14 / 25 / 22 px/s on screen in three directions; the donor uses two coherent scrolls (`shift1`, `shift2`, TDR-4 §3c). Combined with D1 the motion reads as flickering static. Also `world.gd:713-732` mirror-tiles the sheets, imposing a mirrored repeat every half texture period.

### D7 — LOW / informational: missing donor features
No reflection (`hint_screen_texture`/`wavejitter`), no shadow, no foam texture (donor also has none — foam is procedural), no heightmap (TDR-4 §2). These are secondary to D1–D4 and should not block the next visual gate.

---

## 3. Concrete parameter changes (recommendations only — no edits made)

All values are proposed; target metrics are measured with the §0 method.

| # | Change (file:line) | Current | Proposed | Target measured value |
|---|---|---|---|---|
| P1 | Anti-alias the wave fetch: `diffusewaves*.png.import:26` `mipmaps/generate=true`; `water_overlay.gdshader:15-19` use mipmapped filter hint / explicit LOD bias ≥3. **Alternative if asset flags cannot change:** divide UV rates by ~6 (`p/40`, `p/60`, `p/90`; foam `p*0.03`, `p*0.10`) and prefilter sheets to 128 px in `world.gd:769-775`. | 3.8–35 texels/px, no mipmaps | ≤1.2 texels/px (or prefiltered) | ACF lag1 ≥0.65; mean \|ΔL\| ≤6 L/px; coherent ACF peak at lag 6–14 px |
| P2 | Glint gain `:71-72` | `pow(g,170)*8`, `pow(g,120)*4` | `pow(g,170)*1.5`, `pow(g,120)*0.9` (keep exponents — they match donor) | glint fraction 0.3–0.8 %; ≥60 % of glint pixels in components ≥4 px; no component >40 px |
| P3 | Corona `:73-74` | multiply by `(0.20+0.80*corona)` | donor form: divide by `(1.0+1.25*corona)` and apply soft term `0.25*(((g-1)*0.5)+spec)` | broad sheen fraction (L>+25 % of local mean) ≤5 % |
| P4 | Broad sheen `:75` | `pow(g,24)*0.35` | `pow(g,24)*0.12` | as P3 |
| P5 | Normal slope `:56-60` | diff 0.7 m, gain 1.2, z=0.15 | diff 0.35 m, gain 0.55–0.70, z=0.35–0.50 (donor's z=0.15 assumes a smooth field; port's must be more vertical) | grad distribution gives P2 glint rate on wave crests, not every pixel |
| P6 | Wave amplitude/body `:64` | `0.80 + 0.40*h` | `0.72 + 0.75*h` after P1 (body-only std ≥12 L with glints masked) | crest-to-trough ≥24 L at 8–16 px scale |
| P7 | Scroll `:36-38` | (0.125,0.090)/(0.140,−0.100)/(−0.080,0.065) | at p/40 scale: s1=(0.010,0.007), s2=(0.011,−0.008), drop or slow s3=(−0.006,0.005) | 6–10 px/s on screen; one crest crosses a 32-px tile in 3–5 s; no 1 s repeat |
| P8 | Tint `:27-28,63` | shallow (0.10,0.24,0.24), deep (0,0.025,0.05) | shallow (0.22,0.34,0.36) rising to (0.43,0.60,0.66) in the foam band; deep (0.02,0.035,0.045) | deep mean RGB (41,51,51) ±12 with B−G ≤10; shallow/foam RGB (178,187,177) ±25 |
| P9 | Shallow alpha / substrate `:88`, `world.gd:894-895,1129-1130` | floor 0.35 over flat `ter_blue` | alpha floor 0.75–0.85 and make the baked substrate a depth-tinted gradient (or rely solely on overlay) | no constant-L run >8 px inside water; any 16-px water window σ_L ≥3 |
| P10 | Foam band `:80-85` | `band = coastfade*(1-coastfade2)`, 1 octave each, gain 0.9/1.5 | `band = (1-smoothstep(0,0.55,coastfade2))*smoothstep(0.02,0.18,coastfade)`; 2 octaves at p*0.03/p*0.10; nautic gain 1.4, particles gain 8–12 | shore strip frac L>140 ≥0.25 and frac L>180 ≥0.15; band width 8–20 px (0.5–1.25 m); zero foam at depth >1.07 m |
| P11 | Shore feather `world.gd:831-845` | 1-tile binary grid | sub-tile coverage ramp + foam rim inside the coverage gradient | 10–90 % shore transition ≥12 px with no single-pixel step |

**Perf note (`derived`):** all changes are shader-side or import-flag changes; N-07's 250 ms gate and the 2-chunk/frame cap (`world.gd:934-939`) remain untouched. Two extra texture fetches for foam octaves are acceptable, but re-baking water chunks per frame is not.

---

## 4. Acceptance criteria — measurable on the NEXT images

### 4a. From the next **water piece PNG, 512×512** (water only, no units/UI, deep + shallow variants each)

| Metric | Fail (current) | Pass target |
|---|---|---|
| ACF lag1 of luminance | 0.27–0.47 | **≥0.65** (deep) / ≥0.60 (shallow) |
| Mean \|ΔL\| per px | 13.0–18.2 | **≤6.0** |
| Glint fraction (relative threshold mean+2.5σ, ≥+18 L) | 1.08–1.81 % | **0.30–0.80 %** |
| Median glint component size | 1 px | **4–10 px** |
| Glint pixels in ≥4 px components | 0 % | **≥60 %** |
| Glint components ≥5 px | 0 | **≥20** in 512² |
| Coherent ACF peak lag | none (flat after lag 1) | **6–14 px** |
| Luminance std (glints masked) | dominated by speckle | **12–22 L**, crest-trough ≥24 L |
| Mean RGB — deep piece | (30–49, 51–71, 57–73) | **(41,51,51) ±12**, B−G ≤10 |
| Mean RGB — shallow/foam piece | ≈(49,71,73) | **(178,187,177) ±25** |
| Mipmap/texel footprint | 3.8–35 texels/px | **≤1.2 texels/px** (or documented prefilter) |

### 4b. From a **water-only crop of a sample** (e.g. same boxes as §1a, or the river in the next full sample)

| Metric | Fail (current) | Pass target |
|---|---|---|
| Shore 10–90 % transition width | 1–13 px, includes 1-px steps | **≥12 px**, no step >0.25× plateau delta |
| Longest constant-L run inside water | 49 px (≈3 m) | **≤8 px** (no flat teal ring) |
| Foam: frac L>140 in a 20-px shore strip | 0.51 % | **≥25 %** |
| Foam: frac L>180 in shore strip | 0.27 % | **≥15 %** |
| Foam band width | not detectable | **8–20 px**, contiguous along ≥70 % of shoreline length |
| Foam beyond depth 1.07 m | — | **0 bright-foam pixels** |
| Motion: two frames 0.5 s apart on same deep pixel | boiling (uncorrelated) | coherent crest displacement 3–5 px; pixel L change ≥0.08 in <10 % of pixels, not 100 % |
| Ripple directionality | 3 crossing scrolls | visible dominant flow direction; ACF anisotropy ≥1.5 along vs across flow |

---

## 5. Claim table

| # | Claim | Evidence | Method | Label | Verdict / correction |
|---|---|---|---|---|---|
| C1 | Owner: "water effects are also not ok" | `terrain_sample_128.png` visual + §1 measurements | observed | **Confirmed** | Water is flat teal + 1-px white salt-and-pepper; no coherent waves or foam. |
| C2 | The overlay shader is live and advances time per frame | `world.gd:170,1226-1230`; `water_overlay.gdshader:21` | read | observed | **Confirmed** | Unlike the TDR-4-era baked water, `time` is now set in `sync()` every frame. |
| C3 | Donor constants (tints, 170/120 exponents, 0.57/1.07 fades, 0.4 spec colour) are correctly carried over | `water_overlay.gdshader:26-31,71-73` vs TDR-4 §3c | read | observed | **Accurate** | Values match; the failure is in *how* they are applied (gains, corona sign, sampling), not the constants. |
| C4 | Glint over-gain and inverted corona cause the salt-and-pepper | `:71-74` vs TDR-4 §4.7 + §1b/c measured | read + measured | **inferred (high confidence)** | Strongly supported: 8× gain, corona multiplier instead of divisor, 100 % ≤4 px glints. |
| C5 | Unmipmapped 3.8–35:1 minification is the dominant root cause | `.import:26`, shader `:15-19,39-41,81-82`, data.gd:113, measured ACF/ΔL | read + derived | **inferred (high confidence)** | Explains D1–D4 with one mechanism; donor uses `miLinearMipmapLinear`. Runtime confirmation of the effective filter hint is `UNVERIFIED`. |
| C6 | Glint density matches the donor | port 1.1–1.8 % vs dark ref 4.2 % (contaminated) | measured | observed | **Not supported** | Fractions are not directly comparable across crops; the *size distribution* is: port 100 % ≤4 px vs reference coherent 9–105 px. |
| C7 | The flat teal band is the baked substrate showing through α=0.35 | `world.gd:894-895,1129-1130`; shader `:88`; y=470 flat plateau | read + measured | **inferred** | Consistent with the measured 49-px σ≈0.7 plateau; no runtime channel dump to prove it (`UNVERIFIED`). |
| C8 | Foam is absent because the band is zero at the shore and uses aliased 1-octave noise | shader `:80-85`; foam proxy 0.27 % vs 69 % | read + measured | observed | **Confirmed** |
| C9 | Water motion is per-frame and therefore correct | `world.gd:1226-1230` | read | observed | **Code-accurate, visually failing** | Clock advances, but aliased noise makes it read as boiling static (D1/D6). |
| C10 | Donor has a foam texture to convert | TDR-4 §3d/§2 (`water/textures/` has no foam file) | read | observed | **False** | Foam is procedural (`nautic()`+`particles()`); no asset to port. |
| C11 | Reflection/shadow are required for the next visual gate | TDR-4 §4.6/§4.7, §7 W-5 | read | inferred | **Deferred** | Secondary to D1–D4; W-5 is explicitly optional in TDR-4. |
| C12 | Port wave sheets are the donor art and dimensionally correct | `water_png/*.png` 256/512²; `.import:26`; measured DONOR_WAVES2 | observed | observed | **Accurate** | Source art is unmodified white noise; it needs filtering, not replacement. |
| C13 | Reference pale crop B−G is negative (−9.2), port is positive (+2.2…+8.4) | §1b measured | measured | observed | **Confirmed** | Port tint is too cyan; P8 addresses it. |

---

## 6. Bottom line (`inferred`)

The port finally has a live GPU water shader with the **correct donor constants**, but it samples **unfiltered white-noise sheets at 3.8–35 texels per screen pixel**. That one aliasing defect turns every would-be swell into per-pixel noise; the mis-ported glint gain (×8/×4) and corona sign then amplify that noise into ~1.5 % single-pixel white specks, while the flat α=0.35 band over a solid baked substrate removes the shoreline and the 1-octave aliased foam removes the last donor signature. Fix **P1 (mipmaps/prefilter) first**, then **P2–P5 (glint/normal)**, then **P9–P10 (shore/foam)** and **P8 (tint)**; verify against §4 before adding reflection.
