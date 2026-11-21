# T2-PIECE-WATER-DEEP — visual truth + exact render recipe (Cossacks 3 → Godot)

**Lane:** RESEARCH only. Read-only donor/reference/port; no Godot run, no code edit, no donor asset copied into the repo.
**Date:** 2026-11-21. **Deliverable:** exactly one file — this document.
**Scope:** the *deep-water body* piece (open water away from the shore), 512×512. Shore foam/ripple arcs are owned by `water_shallow.md` and `shore_water_transition.md`; isolated glint classification is owned by `water_glints.md`. This doc restates only the parts needed to gate a deep-water tile.
**Labels:** `observed` = literal file/pixel read (Pillow 12.1.1, NumPy); `derived` = arithmetic or code-path consequence; `inferred` = plausible interpretation with caveat; `UNVERIFIED` = no evidence found.

---

## 0. Sources and method

### 0.1 Donor (private-use, read-only; nothing copied)
- `C:\Games\Cossacks 3\data\water\water.lib` — active bindings: `TexScaleS=0.1` (`:32`), `TexScaleT=0.01` (`:33`), `Speed=1.0` (`:42`), `NormalMapLibMaterialName=DiffuseWaves2` (`:43`), `DiffuseMapLibMaterialName=DiffuseWaves0` (`:44`), `DeepColor=(0,0,0.1255,0.5)` (`:9–14`), `ShallowColor=(0,0,0,0.5)` (`:15–20`).
- `C:\Games\Cossacks 3\data\shaders\water\water.dev.frag` — **active** fragment program per `water.lib:68`; constants `:37–47`, noise `:65–67`, scroll `:88–89`, fBm `:92–103`, depth/tint `:168,186–201`, glints `:215–226`, foam `:227`, composite `:229–230`. `water.frag` (non-`.dev`) is an alternate build with materially different constants; it is **not** used here.
- `C:\Games\Cossacks 3\data\shaders\water\water.dev.vert:22` — sun vector axis swap (`lightVector = vec3(pos.x/4, pos.z/2, pos.y/1)`).
- `C:\Games\Cossacks 3\data\water\textures\diffusewaves0.bmp` (256²), `diffusewaves2.bmp` (512²) — full-image Pillow statistics and *derived* temp PNG views only.

### 0.2 Reference stills (read-only)
- `C:\Users\Maxym.Oboyshev\Downloads\c3\articolo-787.jpg` (960×540) — the only deep-water frame. Spec box `(600,0,960,160)`; cleaner sub-boxes measured below. All coordinates are **source-image px**.
- `C:\Users\Maxym.Oboyshev\Downloads\c3\cossacks-3-v1-498085.jpg` (1280×720) — **negative control**: full-frame scan finds **no water body**; 1.15 % of pixels pass a loose "blue-gray" test and they are the blue uniform blocks (visually confirmed). Do not mine this frame for water palette.

### 0.3 Port (read-only)
- `app\shaders\water_overlay.gdshader` — samplers `:15–19`, constants `:26–31`, field `:35–43`, fragment `:45–89`.
- `app\scripts\world.gd` — `WATER_LEVEL = -0.25` (`:73`); three sheets loaded (`:781–783`); uniforms (`:820–827`); RGBA mask bake (`:829–838`); overlay sprite scale/linear filter (`:844–845`); per-frame `time` (`:1226,1230`).
- `app\assets\terrain\water_png\diffusewaves0..2.png` — donor-derived, already in repo; pixel statistics are identical to the donor BMPs (verified, §1.2).

### 0.4 Prior docs used for grounding (not new evidence)
`docs/audit/TERRAIN_DONOR_WATER.md` §2–§4, `docs/audit/TERRAIN_REFERENCE_IMAGES.md` §3.4/§5, `docs/audit/TERRAIN_PORT_RENDER.md` §2–§3 (note: its "no shader / one baked sheet" description is **superseded** — the GPU overlay now exists), `docs/audit/PIECES/water_glints.md` §2–§5, `docs/audit/PIECES/water_shallow.md` §1–§4.

### 0.5 Temp artefacts
All scratch scripts and crops lived only in `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\` (`wd_crops.py`, `wd_scan2.py`, `wd_thin.py`, `wd_ref_metrics.py`, `wd_waves.py`, `wd_sim.py`, `wd_sim_color.py`, `wd_recipe.py`, `wd_samples\*.png`). Nothing from that work entered the repo.

---

## 1. Donor visual truth

### 1.1 Palette and exact crop evidence

| Role | Image + exact source box | Mean RGB | Hex | Rec.709 L (mean ± σ) | Label |
|---|---|---|---|---|---|
| **Deep water, cleanest** | `articolo-787.jpg` `(872,0,960,16)` | (43.8, 52.5, 53.7) | `#2B3536` | 50.7 ± 8.9 | observed |
| Deep water, wider clean band | `articolo-787.jpg` `(840,0,960,22)` | (49.3, 58.3, 59.4) | `#313A3B` | 56.5 ± 12.9 | observed |
| Water-like pixels inside the wide top band | `articolo-787.jpg` `(600,0,960,50)` | (59.8, 68.5, 75.7) | `#3B444C` | 67.2 ± 18.1 | observed (masked) |
| **Water-like pixels inside the SPEC box** | `articolo-787.jpg` `(600,0,960,160)` | (58.8, 67.4, 72.6) | `#3B4349` | 65.9 ± 19.8 | observed (masked) |
| Dark river anchor (independent prior crop) | `articolo-787.jpg` `(750,0,900,25)` | (58, 66, 70) | `#3A4246` | — | observed (`water_shallow.md §1.1`) |

**Box reconciliation (`observed`).** The SPEC box `(600,0,960,160)` is **not clean water**: only 29.6 % of its pixels pass a neutral-blue water classifier (`B ≥ R−4, G ≥ R−4, R<110, G<120, B<130`); the rest is smoke, ship hull, conifers and bank. Over the *water-like subset* it yields `(59,67,73)` ≈ `#3B4349`, consistent with the independent `#3A4246` anchor. The cleanest contiguous water is a thin top strip, 12–22 px tall. Use `#2B3536`–`#3A4246` as the deep palette; never sample the full SPEC box raw.

**Channel ratios (`derived`, cleanest box):** `G−R = 8.7`, `B−R = 9.9`, `B−G = 1.2` → a near-neutral **slate blue-gray**, not the saturated teal of the port's shallow tint. Saturation is low (~0.10–0.15 HSV).

**Donor shader tints are NOT final pixel colours (`observed` + `inferred`).** `water.dev.frag:45–47` gives `watercolor = (0.10,0.24,0.24)` (shallow), `watercolor2 = (0,0.025,0.05)` (deep), `water_specularcolor = (0.4,0.4,0.4)`. These are *linear pre-composite* inputs: `:200` multiplies by refracted-terrain luminance, `:201` mixes by depth, `:209–213` adds projected reflection, `:223` multiplies by `2.2+watershade`, `:224–226` adds/damps specular, `:229–230` mixes by `coastfade`. Using `(0,0.025,0.05)` as the final piece colour is a category error; the measured still is the gate.

### 1.2 Wave sheets — physical scale and where glints come from

Pillow full-image stats (`observed`); port PNGs are pixel-identical to the donor BMPs.

| Sheet | Size | Mean L | σ L | p50 / p90 / p95 / p99 | fr ≥200 | fr ≥235 | fr ≥250 | Dominant cell λ | Role |
|---|---|---|---|---|---|---|---|---|---|
| `diffusewaves0.bmp` | 256² | 63.3 | 48.0 | 44 / 134 / 177 / 240 | 3.23 % | **1.30 %** | 0.42 % | **≈16–17 px** | active **diffuse/noise** map (`water.lib:44`); sampled by `noise()` at `p/256` (`water.dev.frag:65–67`) |
| `diffusewaves2.bmp` | 512² | 198.8 | 58.5 | 214 / 255 / 255 / 255 | 54.96 % | **43.13 %** | **38.53 %** | **≈4 px** | **normal-map slot** (`water.lib:43`); pure gray (R=G=B for 100 % of pixels), fine additive dither |
| `diffusewaves3.bmp` | 512² | 192.3 | 52.5 | 199 / 255 / 255 / 255 | 49.36 % | 30.67 % | 22.25 % | ≈4 px | unused variant |

`observed` visual form: `diffusewaves0` is a dark **cellular/caustic field with thin bright veins** (cell ~16 px at 256², veins 1–3 px); `diffusewaves2` is a near-white fine **dither/noise** field. `derived`: the donor's sparse highlight structure comes from the *cellular* sheet through smooth fBm normals + `pow(grad,170/120)` — **not** from the bright pixels of `diffusewaves2`. The port binds `diffusewaves2` as both `wave2` and `foam_tex` (`world.gd:825–826`), so its 43 % bright fraction directly inflates glint/foam density.

`derived` scale bridge: donor `TexScaleS = 0.1` (`water.lib:32`) → one 256-texel repeat per ~10 world m → cell ≈ 0.6 m; at the port's 16 px/m (`TERRAIN_PORT_RENDER.md §2`) that is **≈10 px per ripple cell on a 512² piece**. Adopt **12 px nominal, acceptance 8–20 px**. `UNVERIFIED`: the donor camera projection is not known exactly, so the metre bridge is an inference, not a measurement.

### 1.3 Ripple appearance in the reference
`observed` in the cleanest 12–22 px strip: flat grey-blue body with **faint near-horizontal tonal bands**; no discrete ring/caustic structure at this resolution. A 22-row vertical profile rises monotonically 42.2 → 69.4 luminance — dominated by distance haze / bank lighting, with banding below the JPEG noise floor. `derived`: reference ripple contrast is **≤ ~10 luminance levels** (σ 8.9–12.9 for the whole clean band). `UNVERIFIED`: crest-to-crest spacing cannot be resolved from a 22-px-tall strip; the shallow-water doc's 6 px arcs belong to a different frame and are **not** imported here.

### 1.4 Motion speed
- Donor: `Speed = 1.0` (`water.lib:42`); animation is a GPU `time` uniform. Two scroll vectors: `shift1 = 0.001*(t*160*2, t*120*2)`, `shift2 = 0.001*(t*190*2, −t*130*2)` (`water.dev.frag:88–89`) → direction ratios **+4:3** and **−1.46:1**. Vertex UV scroll `time*0.02` (TDR-4 §3c).
- Port (derived from code): `phase = int(anim_t*12.0)` was the old bake rate → **12 px/s at 1×**; the current shader uses UV speeds `s1=(0.125,0.090)`, `s2=(0.140,−0.100)`, `s3=(−0.080,0.065)` (`water_overlay.gdshader:36–38`) whose direction ratios (1.39, −1.40) are close to the donor's — the **directions are donor-faithful, the magnitudes are arbitrary**.
- Reference stills cannot measure speed. Target for the piece: slow drift, **~0.15–0.25 m/s** on a 12 px cell (≈2–4 px/s at 16 px/m), preserving the donor's two opposing directions. `inferred`.

### 1.5 Alpha / depth behaviour
`observed` (`water.dev.frag`):
- `coast2water_fadedepth = 0.57` (`:37`); `deepwater_fadedepth = 0.5 + 0.57 = 1.07` (`:168`).
- `level = WATER_LEVEL + 0.2*water_map(...)` (`:~185`); `coastfade = clamp((level−height)/0.57, 0, 1)` (`:198`); `coastfade2 = clamp((level−height)/1.07, 0, 1)` (`:199`).
- Colour `mix(shallow*intensity, deep, smoothstep(0,1,coastfade2))` (`:201`); final `rescolor = mix(rescolor, watercolor, coastfade)` and **`resalpha = coastfade2`** (`:229–230`).
- `derived`: at the waterline alpha = 0 (transparent), rising linearly to alpha = 1 at 1.07 m depth; **deep water is fully opaque** and uses the deep tint. Shore foam is gated by `coastfade*(1−coastfade2)` (`:227`) and is **zero in deep water** — no foam in this piece.
- The height source is the engine-supplied `hmapTex`; `heightmapwaves0.tga` is disabled in `water.lib:45` and its alpha is constant 255 (`water_shallow.md §1.3`, correcting TDR-4 §2's "alpha-height" inference). Do not sample that TGA for depth.

### 1.6 Glints in deep water (summary; full spec in `water_glints.md`)
- Reference clean river: **0 bright-neutral glint pixels** in `(890,12,960,30)` and `(880,10,960,32)`; this doc's own threshold on `(872,0,960,16)` gives **0 % of pixels ≥ L100**. Deep water in the donor stills does **not** sparkle.
- Donor analytic budget: exponents **170 / 120**, colour `(0.4,0.4,0.4)`, `×8/×4` boosts **absent** (`water.dev.frag:42–43,47,218–219`), per-pixel light ray `rd = normalize(light − r0)` (`:216`), corona **divides** (`:221,225`).
- Port defect is real and measured: 1.46–1.61 % glint pixels, 93 % singleton components (`water_glints.md §3`), reproduced by numeric replay. Keep the inherited acceptance: **≤ 0.30 %** isolated glints, **≤ 400** luminance variance, coherent components.

---

## 2. Current port state — what is wrong (file:line)

The port **does** have a per-frame GPU overlay (`world.gd:803–848`, `water_overlay.gdshader`); the older "one baked sheet, no shader" diagnosis in `TERRAIN_DONOR_WATER.md §5` / `TERRAIN_PORT_RENDER.md §2` is **superseded**. The remaining defects are recipe mismatches:

| # | Defect | Port evidence | Donor / reference contrast | Verdict |
|---|---|---|---|---|
| D1 | **Deep tint is saturated blue-black, not slate.** `WATERCOLOR2 = vec3(0.00,0.025,0.05)` used as the final deep colour. | `water_overlay.gdshader:28,63` | ref `(44,53,54)` ≈ `#2B3536`; donor deep tint is a *linear pre-gain* input (`:46`), not final | derived |
| D2 | **Glint amplitudes invented** — `pow(grad,170)*8`, `pow(grad,120)*4`, plus a broad `pow(grad,24)*0.35` sheen absent from the donor. | `water_overlay.gdshader:71–75` | bare `pow` at `water.dev.frag:218–219`; composite damps by `0.25`/`0.4` at `:224–226`; ref glint fraction 0 % | observed + derived |
| D3 | **Light is a constant near-vertical vector**, not the donor's per-pixel `rd`; corona multiplies instead of dividing. | `water_overlay.gdshader:69–74`, `world.gd:820` | `water.dev.frag:215–216,221,225` | observed |
| D4 | **Noise sheet wrong for glints/foam.** `foam_tex` and `wave2` are `diffusewaves2` — 43 % of its pixels are ≥235 and 38.5 % are clipped at 250 — while the donor's wave noise is `diffusewaves0` (1.30 % ≥235, 16 px cells). | `world.gd:825–826`; `water_overlay.gdshader:41,81–84` | `water.lib:43–44`, `water.dev.frag:65–67` | observed |
| D5 | **Ripple scale too fine / aliased.** Field samples one texture repeat per 7 / 11 / 17 m; with 1024-px mirror-tiled sheets and no mipmaps, ≈60–146 texels/m at 16 px/m (≈4–9 texels per screen pixel). | `water_overlay.gdshader:39–42`; `diffusewaves2.png.import` `mipmaps/generate=false` | donor ~10 m repeat, cell ≈0.6 m ≈10 px | derived |
| D6 | **Normal slope too steep.** Finite differences at 0.7 m with gain 1.2 give mean \|n.xy\| ≈ 0.73, n.z ≈ 0.63 in a numeric replay; donor uses smooth 9-octave fBm at `dif=0.01` with z = 0.15. | `water_overlay.gdshader:55–60`; replay `wd_sim.py` | `water.dev.frag:85–104,186–192` | derived (CPU analogue) |
| D7 | **Alpha floor kills the shore fade.** `alpha = coverage * mix(0.35, 1.0, coastfade2)` → 0.35 at the waterline; donor `resalpha = coastfade2` → 0. Binary per-tile coverage plus `LINEAR` filtering gives a 1-tile (2 m ≈ 32 px) feather — ~3.5× the donor's 0.57 m (≈9 px) band. | `water_overlay.gdshader:88`, `world.gd:837,845` | `water.dev.frag:198,230` | derived |
| D8 | **Depth mask is tile-resolution.** Coverage/depth baked at `MAP_W×MAP_H`, one pixel per 2 m tile; the deep/shallow boundary stair-steps. | `world.gd:831–838,844–845` | donor is per-pixel from `hmapTex` | derived |

**Numeric replay of the current deep path** (`wd_sim_color.py`, repo wave PNGs, 256² tile, `t=3.7`, Godot-style linear→sRGB encode): predicted final sRGB mean **(7.7, 48.6, 67.3)**, luminance mean 41.3 / σ 27.8, p99 = 255, **2.57 % of pixels ≥ L100** — versus reference **(43.8, 52.5, 53.7)**, σ 8.9, **0 % ≥ L100**. `derived`: R ~36 levels too low, B ~14 too high, σ ~3× too large, glint fraction non-zero. The colour-space assumption is `inferred`; the *relative* failures (missing red channel, excess blue, excess variance) hold either way.

---

## 3. Machine-readable spec (headless piece renderer)

Top-level schema is preserved verbatim; all tuning parameters are extra keys.

```json
{
  "name": "water_deep",
  "size_px": [512, 512],
  "seed": 7,
  "layers": [
    {
      "type": "water",
      "sheet": "diffusewaves2",
      "mode": "deep",
      "opacity": 1.0,
      "noise_sheets": ["diffusewaves0.png", "diffusewaves1.png", "diffusewaves2.png"],
      "octave_weights": [0.50, 0.32, 0.18],
      "sheet_note": "schema keeps diffusewaves2 as the primary sheet; visual noise substrate is diffusewaves0 (active donor diffuse map, water.lib:44). diffusewaves2 is the fine normal/dither slot (water.lib:43)."
    }
  ],
  "reference": {
    "image": "articolo-787.jpg",
    "box": [600, 0, 960, 160],
    "clean_box": [872, 0, 960, 16],
    "clean_box_rgb": [43.8, 52.5, 53.7],
    "spec_box_waterlike_rgb": [58.8, 67.4, 72.6],
    "prior_anchor_hex": "#3A4246"
  },
  "palette": {
    "base_rgb8": [44, 53, 55],
    "base_hex": "#2C3537",
    "donor_deep_linear": [0.0, 0.025, 0.05],
    "note": "donor_deep_linear is a pre-gain/pre-reflection input; gate on base_rgb8"
  },
  "ripple": {
    "source_sheet": "diffusewaves0.png",
    "cell_px": 12,
    "cell_accept_px": [8, 20],
    "periods_px": [32, 48, 80],
    "amplitude_luma": 7.0,
    "swell_wavelength_px": 64,
    "swell_amplitude_luma": 2.5,
    "normal_delta_px": 2.0,
    "normal_slope_gain": 0.30,
    "normal_z": 0.35,
    "reference_sigma_luma": [8.9, 12.9]
  },
  "motion": {
    "scroll_uv_per_s": [[0.018, 0.013], [0.021, -0.015], [-0.011, 0.009]],
    "donor_shift1_ratio": 1.333,
    "donor_shift2_ratio": -1.462,
    "speed_m_per_s": [0.15, 0.25],
    "time_seconds": 7.0
  },
  "glints": {
    "exponent": 400.0,
    "gain": 6.0,
    "donor_exponents": [170, 120],
    "specular_color_linear": [0.4, 0.4, 0.4],
    "sun_dir_mapped": [-0.08618, 0.0, 0.9387],
    "isolated_glint_cap_pct": 0.30,
    "max_luma_gain": 8,
    "note": "deep reference shows 0 isolated glints; exponent 400/gain 6 keeps rare sub-8-level crests while preserving the donor's high-exponent character"
  },
  "depth_alpha": {
    "coast2water_fadedepth_m": 0.57,
    "deepwater_fadedepth_m": 1.07,
    "piece_depth_range_m": [1.07, 4.0],
    "coastfade2": 1.0,
    "alpha": 1.0,
    "shore_alpha_floor": 0.0,
    "foam": 0.0
  },
  "edge": {
    "softness_10_90_px": [8, 16],
    "opposite_border_diff_max": 14,
    "mirror_tileable": true
  }
}
```

### Field notes
- `sheet` is kept exactly as required by the schema; `noise_sheets` + `sheet_note` carry the measured correction. A renderer that uses only `sheet` should substitute `diffusewaves0.png` for the ripple modulation.
- `base_rgb8` is the **final 8-bit sRGB** body mean. `donor_deep_linear` is recorded for provenance only.
- `glints.exponent = 400` / `gain = 6` is a *piece-level* retune: the donor's 170/120 exponents combined with the port's `×8`/`×4` boosts (D2) overshoot; the high exponent plus small gain keeps the analytic form while matching the measured 0-glint reference. The donor constants are preserved in `donor_exponents`.
- `depth_alpha.piece_depth_range_m` reflects `mapgen.gd:13,174` (`C_WATER = −1.1`, water heights ≈ −1.1…−4.95 m) against `world.gd:73` (`WATER_LEVEL = −0.25`) → depths ≥ 0.85 m, so `coastfade2` saturates to 1 for genuine deep water. `derived`.

### Validated recipe (CPU analogue, no Godot run)
`wd_recipe.py` rendered the above parameters to a 512×512 PNG in temp (`wd_samples/recipe_water_deep_512.png`) using only repo wave sheets. Measured with Pillow/NumPy:

| Metric | Recipe output | Reference clean box |
|---|---|---|
| Mean RGB | **(45.11, 54.11, 56.11)** | (43.8, 52.5, 53.7) |
| Luminance mean / σ | 52.34 / **7.09** | 50.7 / 8.9 |
| B−R / G−R | 11.0 / 9.0 | 9.9 / 8.7 |
| frac L ≥ 100 | **0.0000 %** | 0.0000 % |
| frac L ≥ 70 / ≥ 80 | 1.50 % / 0.011 % | ~0 % / 0 % |
| Opposite-border mean abs diff | LR 8.7 / TB 12.1 (≈ internal σ → no hard seam) | mirror-tileable source |

`derived`: the recipe meets the palette, variance and glint targets in a CPU analogue. It is **not** a Godot render; the build lane must confirm in-engine.

---

## 4. Acceptance criteria — measurable from one 512×512 PNG

Render `water_deep` with the water mask forced to deep (`coverage = 1`, `coastfade2 = 1`) so shoreline foam cannot contaminate the metrics. All metrics are Rec.709 luminance, 8-bit.

| # | Metric | Target | How to measure | Reference / status |
|---|---|---|---|---|
| M1 | Interior mean RGB (central 384×384) | **(44, 53, 55) ± 8 per channel** | Pillow mean RGB over the central crop | observed ref (43.8,52.5,53.7); recipe (45.1,54.1,56.1) |
| M2 | Channel offsets | `G−R ∈ [6,12]`, `B−R ∈ [7,15]`, `\|B−G\| ≤ 4` | Per-pixel offset means | observed ref 8.7 / 9.9 / 1.2 |
| M3 | Luminance σ of interior | **5–14** (stretch 7–11) | `std` of Rec.709 L | observed 8.9–12.9; current port replay 27.8 → **FAIL** |
| M4 | Glint fraction, L ≥ 100 | **< 0.50 %** (stretch 0.00 %) | Count pixels ≥ 100 | observed 0 %; current port replay 2.57 % → **FAIL**; `water_glints.md` A1 cap 0.30 % |
| M5 | Bright-pixel tail, L ≥ 80 | **≤ 0.10 %** | Count pixels ≥ 80 | recipe 0.011 % |
| M6 | Ripple cell size | median **8–20 px** (nominal 12) | 2-D autocorrelation first peak, or 4 vertical/horizontal profiles with ≥6-level prominence | derived from donor `TexScaleS` + 16 px cells; **UNVERIFIED** in reference still |
| M7 | No foam / caustic rings | **0** near-white runs (`L>235, sat<0.05`) longer than 3 px | Threshold + connected components | donor foam gated to coast band (`water.dev.frag:227`) |
| M8 | Opposite-border seam | mean abs diff **≤ 14** per RGB channel on each axis | Compare row 0 vs row 511 and col 0 vs col 511 | recipe 8.7 / 12.1; mirror-tileable requirement |
| M9 | Edge softness (when composited over land via alpha) | alpha 10→90 % transition **8–16 px** | 1-px profile perpendicular to the mask edge | derived: donor 0.57 m × 16 px/m ≈ 9 px; port today ≈ 32 px → **FAIL** (D7) |
| M10 | Deep alpha | **1.0** interior; shore alpha floor **0.0** (no 0.35 step) | Read layer alpha | donor `resalpha = coastfade2` → 1 at depth ≥ 1.07 m; port floor 0.35 → **FAIL** |

`UNVERIFIED`: M1–M10 have not been run against an in-engine render — this lane does not start Godot. M1–M8 are defined and demonstrated by the CPU analogue; M9–M10 require the compositing build.

---

## 5. Claim table

| Claim | Evidence | Method | observed / derived / inferred | Verdict |
|---|---|---|---|---|
| Clean deep water in `articolo-787.jpg` is neutral slate ≈ `#2B3536`–`#3A4246` | `(872,0,960,16)` → (43.8,52.5,53.7); `(840,0,960,22)` → (49.3,58.3,59.4); prior `(750,0,900,25)` → (58,66,70) | Pillow means, 3 independent boxes | **observed** | Confirmed; adopt palette |
| The SPEC box `[600,0,960,160]` is contaminated | only 29.6 % of pixels pass the water classifier; masked subset (58.8,67.4,72.6); σ of full box 30.3/28.8/38.0 vs clean σ ~9–13 | Pillow classifier + ImageStat | **observed** | Confirmed; use `clean_box` for gating |
| `cossacks-3-v1-498085.jpg` supplies a second water sample | full-frame blue-gray test 1.15 %, bbox whole image; visual check shows blue uniforms only | Pillow + visual | **observed** | **Rejected**: negative control, no water body |
| Donor deep tint `(0,0.025,0.05)` is the final on-screen colour | `water.dev.frag:46` is a linear input; `:200–226` apply luma, reflection, gain, specular | Code read + derivation | **derived** | **Rejected** as a colour target; keep only as provenance |
| Donor wave noise is `diffusewaves0` (16 px cells, 1.30 % ≥235); `diffusewaves2` is the bright fine slot (4 px, 43 % ≥235) | `water.lib:43–44`; `water.dev.frag:65–67`; Pillow stats on both BMPs and both port PNGs | Read + Pillow | **observed** | Confirmed; port binds the wrong sheet for noise/foam (`world.gd:825–826`) |
| Donor deep water is fully opaque; alpha fades from 0 at the waterline over 1.07 m | `coastfade2` at `:199`, `resalpha = coastfade2` at `:230`, fade constants `:37,168` | Code read | **observed** | Confirmed; port alpha floor 0.35 is wrong |
| Donor deep water has no foam | foam term `× coastfade*(1−coastfade2)` at `:227`; reference clean box has no near-white runs | Code read + Pillow | **observed** | Confirmed; `foam = 0` in spec |
| Reference deep-water ripple spacing is 6 px | 22-px-tall strip; vertical profile is a monotonic 42→69 gradient | Pillow profile | **inferred** | **UNVERIFIED — cannot be measured**; spec uses donor-derived 12 px instead |
| Port glints are too dense (1.46–1.61 %, 93 % singletons) | `water_glints.md §3` crops + independent replay `wd_sim.py` (2.6 % spec > 0.5, p99 = 255) | Pillow + numeric replay | **derived** (CPU analogue) | Confirmed as a defect; inherited cap ≤ 0.30 % |
| Port deep colour is ~36 R levels too low and ~14 B too high | replay predicts (7.7,48.6,67.3) vs ref (43.8,52.5,53.7) | Numeric replay + sRGB encode | **derived** | Strong but colour-space assumption is `inferred`; gate on measured PNG |
| Port ripple field is aliased (4–9 texels per screen pixel) | periods 7/11/17 m, 1024-px sheets, no mipmaps, 16 px/m | Code read + arithmetic | **derived** | Confirmed; D5 |
| Port water shader does not exist / water is a baked blue glaze | `TERRAIN_DONOR_WATER.md §5`, `TERRAIN_PORT_RENDER.md §2` | Prior docs | **observed (then)** | **SUPERSEDED**: overlay exists at `world.gd:803–848` and `water_overlay.gdshader` |
| Recipe `[44,53,55] + 12 px cells + exponent 400/gain 6` matches the reference | CPU render measured (45.1,54.1,56.1), σ 7.09, 0 % ≥ L100 | Pillow on temp PNG | **derived** | Passes the CPU analogue; **UNVERIFIED** in-engine |
| Retail binary binds `water.dev.frag` | `water.lib:68` names `.dev`; alternate `.frag` constants differ | Read | **observed** (config) / **UNVERIFIED** (runtime) | Spec pins `.dev` constants; carried open question |

---

## 6. Open questions / unknowns

1. Exact ripple wavelength in the reference — the water strip is 12–22 px tall; donor-derived 12 px nominal is a scale inference, not a measurement.
2. Whether Godot 4 `canvas_item` `COLOR` is treated as linear or sRGB at output — the replay assumed linear→sRGB; relative palette failures hold either way, absolute tint may need a calibration constant.
3. Which shader build ships retail (`.dev` fade 0.57 vs alternate 0.10); would change depth/alpha numbers if the alternate is real.
4. Whether a time-of-day override exists for the donor sun — `env.cfg`/`time.cfg` contain no water keys; only static `light.cfg` was available.
5. Whether the `×8`/`×4` glint boosts can be replaced by a per-pixel `rd` and untouched donor exponents instead of the piece-level exponent-400 retune — needs an in-engine render loop, out of scope here.
6. M9/M10 edge softness depends on the compositing substrate; a standalone opaque 512² PNG cannot measure it without the land layer.
