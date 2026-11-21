# water_shallow — visual truth + exact recipe

**Lane:** T2-PIECE-WATER-SHALLOW (RESEARCH only).
**Status:** FINAL — exactly one file written (`docs/audit/PIECES/water_shallow.md`); no Godot run, no code or asset edited, no donor binary copied into the repo. All Pillow crops/samples were written only under `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\`.
**Protocol:** `SWARM_OPS.md §5b-QUALITY`. Verdict labels: `observed` (literal file/pixel read), `derived` (arithmetic or code-path consequence), `inferred` (attribution with caveat), `UNVERIFIED` (no evidence). A claim is never promoted because it is convenient.
**Date:** 2026-11-21.

---

## 0. Sources and method

### 0.1 Donor (private-use, read-only)
- `C:\Games\Cossacks 3\data\shaders\water\water.dev.frag` — **active** fragment shader per `water.lib` (`FragmentProgramFileName = .\data\shaders\water\water.dev.frag`). Constants at `:34–47`, `nautic()` `:106–116`, `particles()` `:119–126`, coast/depth `:167–175,187–201`, glints `:215–226`, foam `:227`, composite `:229–230`.
- `C:\Games\Cossacks 3\data\shaders\water\water.frag` — non-`.dev` **alternate** build (different constants, `:3,21,24,26,28–30,112–132,185–232`). Reported only as a contrast case; `water.lib` does not select it.
- `C:\Games\Cossacks 3\data\water\water.lib` / `water.mat` — active texture bindings: `DiffuseMapLibMaterialName = DiffuseWaves0`, `NormalMapLibMaterialName = DiffuseWaves2`, `TexScaleS=0.1`, `TexScaleT=0.01`, `Speed=1.0`, `MinDepth/MaxDepth=0/1`, `DeepColor=(0,0,0.1255,0.5)`, `ShallowColor=(0,0,0,0.5)`.
- `data\water\textures\diffusewaves0.bmp` (256² RGB), `diffusewaves2.bmp` (512² RGB), `heightmapwaves0.tga` (256² RGBA) — Pillow 12.1.1 full-image stats and temp PNG renders (derived images, never copied into the repo).

### 0.2 Reference images (read-only)
- `C:\Users\Maxym.Oboyshev\Downloads\c3\maxresdefault_1.jpg` 512×288 — image #12 of `TERRAIN_REFERENCE_IMAGES.md`; the only lit pale-shallow-water/shore frame. All boxes below are **source-image px**.
- `C:\Users\Maxym.Oboyshev\Downloads\c3\articolo-787.jpg` 960×540 — image #6; dark river used as the deep-water contrast anchor.

### 0.3 Port (read-only)
- `app\shaders\water_overlay.gdshader` — constants `:27–31`, wave field `:35–43`, depth tint `:62–64`, glints `:66–75`, foam `:77–85`, alpha `:87–89`.
- `app\scripts\world.gd` — overlay setup `:803–848` (wave sheets `:781–783`, shader params `:820–827`, RGBA mask `:829–838`, LINEAR feather `:845`), per-frame `time` `:1226–1230`.
- `app\assets\terrain\water_png\diffusewaves0..2.png` — donor-derived sheets already converted (per `TERRAIN_DONOR_WATER.md §2`).

### 0.4 Prior docs used for grounding (not new evidence)
`docs/audit/TERRAIN_DONOR_WATER.md §2–§4,§7` (shader constants, W-1..W-4), `docs/audit/TERRAIN_REFERENCE_IMAGES.md §3.4, §5 rank 8` (shore palette, 3-band rule), `docs/audit/PIECES/shore_sand.md §1.3, §3` (profile, `opacity: 0.35`, band widths).

---

## 1. Donor visual truth — palette, crop boxes, shader constants, morphology

### 1.1 Reference palette (measured, lit frame)

All rows are Pillow mean RGB over the stated **source px** box of `maxresdefault_1.jpg`; `Lstd` is Rec.709 luminance standard deviation; `S` is mean HSV saturation. Temp crops: `ws_maxres_BR_zoom.png` (src `(300,150,512,288)` ×3), `ws_water_clean_zoom.png` (src `(384,168,448,240)` ×8), `ws_shore_profile_zoom.png` (src `(320,190,440,220)` ×8).

| Role | Exact source box | Mean RGB | Hex | Lstd | S | Label |
|---|---|---|---|---|---|---|
| Sand (prior-doc box reproduced) | `(340,210,380,250)` | (167.7,157.8,126.7) | `#A89E7F` | 10.5 | 0.246 | observed |
| Sand, clean A | `(336,200,368,224)` | (170.7,160.7,130.0) | `#ABA182` | 5.7 | 0.239 | observed |
| Sand, clean B | `(352,214,384,238)` | (174.5,165.7,136.6) | `#AEA689` | 8.5 | 0.218 | observed |
| Wash band | `(372,196,396,224)` | (188.7,189.0,168.7) | `#BDBDA9` | 12.7 | 0.117 | observed |
| Shallow water, clean A | `(398,182,420,212)` | (195.3,209.0,202.3) | `#C3D1CA` | 11.6 | 0.068 | observed |
| Shallow water, clean B | `(400,200,422,228)` | (189.0,199.6,192.9) | `#BDC8C1` | 15.5 | 0.061 | observed |
| Shallow water, rippled | `(390,176,422,214)` | (194.4,204.7,194.5) | `#C2CDC3` | 13.6 | 0.077 | observed |
| Ripple trough (20th L pct) | low-luma pixels of `(396,178,422,214)` | (174.9,186.8,179.9) | `#AFBBB4` | — | — | derived |
| Ripple crest (90th L pct) | high-luma pixels of `(396,178,422,214)` | (215.9,229.7,221.7) | `#D8E6DE` | — | — | derived |
| **Prior "#696B65" anchor reproduced** | `(410,190,457,237)` | (104.5,106.4,100.6) | `#696A65` | **70.8** | 0.266 | observed, **contaminated** |
| Dark river (contrast) | `articolo-787.jpg` `(750,0,900,25)` | (58,66,70) | `#3A4246` | — | — | observed |

**Reconciliation of the `~#696B65` target (important).** `observed`: the box that produces the prior audit's `#696B65` has luminance std **70.8** and straddles the dark-bordered minimap at source `x≳423, y≳198`; it is a *mixed* crop (pale water + UI shadow), not clean water. `derived`: the clean shallow-water plateau is **#C2CDC3–#C3D1CA** (≈190–209/channel) with troughs `#AFBBB4` and crests `#D8E6DE`. `inferred`: the ticket's `~#696B65` is nevertheless a defensible **design target** for a self-contained piece because (a) it is the inherited anchor in `TERRAIN_REFERENCE_IMAGES.md §3.4`, `shore_sand.md §1.3/§3`, (b) the active donor shallow tint `(0.10,0.24,0.24) ≈ (26,61,61)` scaled by the donor's `2.2+watershade` gain (`water.dev.frag:223`) and desaturated by the sand wash/fog lands in the same dark gray-cyan neighbourhood, and (c) a standalone piece without the bright JPEG surface crests or UI bleed reads darker. §4 therefore states **both** the anchor target and the observed clean-water value; do not silently drop either.

### 1.2 Shore profile — 3 bands (observed)

Horizontal classifier scan of `maxresdefault_1.jpg` at `y=204`, `x=330..422` (S = warm sand `R−G>10, G−B>8, sat>0.15`; W = cool/neutral water `G≥R−3, B≥R−8, sat<0.15`; w = wash transition):

```
S[330-353]  w[354-357]  S[358-362]  w[363-393]  W[394-422]
# A89D7F -> #BAB69D -> #C4CBB9 -> #BDC3B5 -> #C1CBC0 -> #D2DBD6
```

Other scanlines agree: `y=196` S→w(352–381)→W(382+); `y=200` S→w(349–359)→(S 360–362)→w(363–386)→W(387+); `y=212` S[330-354]→w[355-398]→W[399-422]. `derived`: band widths at source scale are **sand ≈24–40 px, wash ≈30–46 px, water = remainder**; ratios ≈26:44:30. These match `shore_sand.md §3` (`sand [26,51]`, `wash [30,50]`) — reuse those numbers for the 512² piece. Foam: **no white foam band is visible** in any scanline; the wash is a desaturation/brightening ramp only. `inferred`: foam is weak/absent in the shallow reference.

### 1.3 Ripple arcs (observed + derived)

`observed` in `ws_water_clean_zoom.png` (`src (384,168,448,240)` ×8): thin near-white **curved/arcuate crests** over a pale gray-cyan body, decreasing in contrast toward the wash. Vertical luminance profiles through clean water (source x = 396, 402, 408, 414; y = 172..213) give local crest rows:

- `x=396`: 187, 192, 195, 200, 203, 208 → gaps 5,3,5,3,5 px
- `x=402`: 182, 186, 188, 194, 198, 206, 208, 210 → gaps 4,2,6,4,8,2,2 px
- `x=408`: 178, 180, 183, 187, 193, 196, 200, 202, 204, 209 → gaps 2,3,4,6,3,4,2,2,5 px

`derived`: crest-to-crest spacing **2–8 px, median ≈4 px** at source scale; adopt nominal **6 px** for a 512² piece with acceptance window **3–12 px**. `derived` crest/trough luminance contrast ≈ 220 vs 187 ≈ **33 levels**.

`observed` (Pillow render of donor textures into temp): `diffusewaves0.bmp` is a dark **cellular/caustic** field with thin bright veins (min 7, max 255, mean 63.3, std 48.0), **not** concentric rings; `diffusewaves2.bmp` is a brighter variant (mean 198.8, std 58.5). `heightmapwaves0.tga` is a fine wavy **normal map** (R 111–220, G 167–255, B 58–178, std ≈13/channel) with **alpha constant 255** — a correction to `TERRAIN_DONOR_WATER.md §2`'s "alpha carries height" inference. `derived`: the concentric arcs are **not present in any donor wave sheet**; the recipe must synthesize them (radial sine term) over the `diffusewaves0` field. `observed`: the file is disabled in `water.mat` (commented `HeightMapWaves0` section) and `water.lib` (`//NormalMapLibMaterialName = HeightMapWaves0`), so it is not part of the active water pipeline.

### 1.4 Donor shader constants that define shallow water (active `.dev` build)

`observed` (`water.dev.frag`), with line numbers:

| Constant | Value | Line | Role for the shallow piece |
|---|---|---|---|
| `coast2water_fadedepth` | `0.57` | `:37` | shore fade distance; `coastfade = clamp(depth/0.57,0,1)` `:198` |
| `deepwater_fadedepth` | `0.5+0.57 = 1.07` | `:168` | `coastfade2 = clamp(depth/1.07,0,1)` `:199` |
| `watercolor` (shallow) | `(0.10,0.24,0.24)` | `:45` | shallow tint, `mix(...)` at `:201` |
| `watercolor2` (deep) | `(0.00,0.025,0.05)` | `:46` | deep end of `:201` |
| shallow gain | `watercolor *= 2.2+watershade` | `:223` | brightens shallow body (watershade ≤ ~1.3 with `shadowColor` boost) |
| `intensity` | Rec.709 luma of refracted terrain | `:200` | multiplies shallow tint before deep mix |
| `WATER_LEVEL` | `gl_TexCoord[1].z` (engine-supplied) | `:167` | alternate non-dev build hardcodes `1.5` (`water.frag:182`) |
| `large_waveheight/size` | `0.50 / 2.0` | `:38–39` | coarse crossing swell `:95` |
| `small_waveheight/size` | `0.5 / 0.5` | `:40–41` | 9-octave small waves `:96–101` |
| `normwater` z | `0.15` | `:192` | wave normal from finite differences `:187–191` |
| `wavejitter` | `normwater.xy * texScaleT * (level-height)` | `:193` | `texScaleT=0.01` (`water.lib`) |
| `water_softlight/glossylight_fact` | `170 / 120` | `:42–43` | glint exponents `:218–219` |
| `water_specularcolor` | `(0.4,0.4,0.4)` | `:47` | glint colour `:226` |
| `nautic()` | `pow(1-f,5)`, 3 octaves ×18 | `:106–116` | foam component 1 |
| `particles()` | `pow(f*0.35,7)*particle_amount`, 3 octaves ×200 | `:119–126` | foam component 2 |
| `particle_amount` | `30` | `:44` | foam sparkle gain |
| foam term | `watershade*coastfade*(1-coastfade2)*(vec3(.5,.6,.7)*nautic + vec3(1)*particles)` | `:227` | foam confined to coast band |
| composite | `rescolor = mix(rescolor, watercolor, coastfade)`, `resalpha = coastfade2` | `:229–230` | final shallow coverage/alpha |

`derived`: for the shallow piece the operating depth interval is **0–0.57 m** → `coastfade` 0→1 and `coastfade2` 0→0.53; `band = coastfade*(1-coastfade2)` peaks near depth ≈0.35 m. Alternate build (`water.frag`) would give `coast2water_fadedepth=0.10`, `watercolor=(0.43,0.60,0.66)`, `particle_amount=70`, and **stubs `nautic()` to `1.0`** (`:112–120`) — a materially different shallow look; not used here because `water.lib` selects `.dev` (`UNVERIFIED` which builds in the retail binary — a prior open question).

---

## 2. Current port gap — file:line

The port now has a per-frame GPU overlay (unlike the older CPU-baked description in `TERRAIN_DONOR_WATER.md §5`); the gap is a **recipe mismatch**, not a missing shader.

| # | Defect vs shallow truth | Port evidence | Donor / reference anchor | Verdict |
|---|---|---|---|---|
| G1 | Shallow body renders **dark saturated teal**, not pale gray-cyan. `WATERCOLOR=(0.10,0.24,0.24)` ≈ (26,61,61); at `coastfade2≈0`, `col = WATERCOLOR*(0.80+0.40*h)` ≈ (21–31,49–73,49–73). The donor's compensating `2.2+watershade` gain (`:223`), reflection (`:209–213`) and sand bleed are absent. | `water_overlay.gdshader:27, :63–64` | reference clean water `#C2CDC3`; ticket anchor `#696B65` | derived |
| G2 | **No concentric arc ripples.** `field()` is three scrolled linear noise sheets (`diffusewaves0/1/2`) with weights `0.42/0.32/0.26`; it reproduces the donor's cellular/directional texture, not radial rings. | `water_overlay.gdshader:35–43`, `world.gd:781–783,823–826` | reference arcs, 3–12 px spacing (§1.3) | observed |
| G3 | **Foam too strong / wrong source.** `nautic = pow(1-f1,5)` with `f1` from `diffusewaves2` bright veins gives ~0.86 at vein pixels; `particles = pow(f2,7)*1.5`. Reference shallow band has weak/absent foam. | `water_overlay.gdshader:81–85` | §1.2 (no white band), donor `:227` gated by `band` | derived |
| G4 | **3-band sand→wash→water not rendered by the piece.** Overlay coverage is the type-3 grid with `LINEAR` feather over one tile; the sand collar is `terrain=4`, so `coverage=0` there and the shader discards — no sand/wash under the water layer. | `world.gd:829–838,845`, `water_overlay.gdshader:46–48`; `shore_sand.md §2 D2/D8` | §1.2 (`#A89E7F`→`#BDBDA9`→water) | derived |
| G5 | Shallow alpha is correct in isolation (`mix(0.35,1.0,coastfade2)` → 0.35 at shore) but applied to the too-dark G1 colour, so the wash reads as a dark blue film rather than a pale glaze. | `water_overlay.gdshader:88` | `shore_sand.md §1.3` (`opacity 0.35`) | derived |
| G6 | Depth proxies are baked from `game.height_at()` at **one pixel per tile** (`MAP_W×MAP_H` mask), so `coastfade/coastfade2` are tile-resolution steps → band edges stair-step instead of the reference's smooth wash. | `world.gd:831–838,844–845` | §1.2 profile bands 24–46 px at 512×288 | derived |

---

## 3. Machine-readable spec

```json
{
  "name": "water_shallow",
  "size_px": [512, 512],
  "seed": 7,
  "layers": [
    {
      "type": "water",
      "sheet": "diffusewaves0",
      "mode": "shallow",
      "opacity": 0.35,
      "sheets_used": ["diffusewaves0.png", "diffusewaves1.png", "diffusewaves2.png"],
      "octave_weights": [0.42, 0.32, 0.26],
      "scroll_uv_per_s": [[0.125, 0.090], [0.140, -0.100], [-0.080, 0.065]],
      "normal_z": 0.15,
      "depth_tint": "mix(shallow*intensity, deep, smoothstep(0,1,coastfade2))"
    },
    {
      "type": "ripple_arc",
      "mode": "radial_sine",
      "center_px": [430, 470],
      "wavelength_px": 6,
      "amplitude_luma": 33,
      "crest_hex": "#D8E6DE",
      "trough_hex": "#AFBBB4",
      "falloff_px": 320
    },
    {"type": "sand_band", "width_px": [26, 51], "hex": "#A89E7F"},
    {"type": "wash_band", "width_px": [30, 50], "hex": "#BDBDA9"},
    {
      "type": "foam",
      "mode": "nautic",
      "band": "coastfade*(1-coastfade2)",
      "nautic_gain": 0.15,
      "particle_amount": 0,
      "note": "weak/absent in reference; donor .dev particle_amount=30"
    }
  ],
  "depth": {
    "water_level_source": "water.dev.frag:167 gl_TexCoord[1].z (alternate build: 1.5)",
    "coast2water_fadedepth_m": 0.57,
    "deepwater_fadedepth_m": 1.07,
    "piece_depth_range_m": [0.0, 0.57],
    "coastfade": "clamp(depth / 0.57, 0, 1)",
    "coastfade2": "clamp(depth / 1.07, 0, 1)",
    "shallow_color_lin": [0.10, 0.24, 0.24],
    "deep_color_lin": [0.00, 0.025, 0.05],
    "shallow_gain": 2.2,
    "shallow_alpha": 0.35,
    "tex_scale_s": 0.1,
    "tex_scale_t": 0.01
  },
  "foam": {
    "donor_particle_amount": 30,
    "piece_particle_amount": 0,
    "nautic_octaves": 3,
    "nautic_scale": 18,
    "nautic_power": 5,
    "particle_octaves": 3,
    "particle_scale": 200,
    "particle_power": 7,
    "piece_nautic_gain": 0.15,
    "band_peak_depth_m": 0.35
  },
  "ripple": {
    "source_spacing_px": [2, 8],
    "source_median_px": 4,
    "piece_nominal_px": 6,
    "acceptance_px": [3, 12],
    "crest_luma": 220,
    "trough_luma": 187,
    "contrast_levels": 33
  },
  "reference": {
    "donor_shader": "C:/Games/Cossacks 3/data/shaders/water/water.dev.frag:37,106-126,167-230",
    "donor_lib": "C:/Games/Cossacks 3/data/water/water.lib",
    "images": [
      {"file": "maxresdefault_1.jpg", "src_px": [300,150,512,288],
       "sand_box": [340,210,380,250], "wash_box": [372,196,396,224],
       "water_box": [398,182,420,212], "profile_y": 204, "profile_x": [330,422]},
      {"file": "articolo-787.jpg", "src_px": [600,0,960,160], "dark_box": [750,0,900,25]}
    ],
    "palette": {
      "sand_lit": "#A89E7F",
      "wash_lit": "#BDBDA9",
      "water_shallow_clean_lit": "#C3D1CA",
      "water_ripple_trough": "#AFBBB4",
      "water_ripple_crest": "#D8E6DE",
      "water_shallow_ticket_anchor": "#696B65",
      "water_dark_lit": "#3A4246"
    },
    "prior": [
      "docs/audit/TERRAIN_DONOR_WATER.md:2-4,7",
      "docs/audit/TERRAIN_REFERENCE_IMAGES.md:3.4,5",
      "docs/audit/PIECES/shore_sand.md:1.3,3"
    ]
  }
}
```

`observed` caveat: `opacity: 0.35` is the shallow end of `water_overlay.gdshader:88` and matches `shore_sand.md §3`; band widths `26–51 / 30–50 px` are inherited from that spec and agree with this piece's §1.2 profile. `derived`: `amplitude_luma: 33`, `wavelength_px: 6`, `particle_amount: 0`, `nautic_gain: 0.15` come from §1.3/§1.2. `inferred`: the ripple center `(430,470)` and falloff `320 px` are placement choices reproducing "arcs converging off the lower-right corner"; they are not measurable from the low-res reference. All numbers are recipe inputs; no 512² piece was rendered (no Godot run in this lane).

### Exact change list (ordered; no code changed by this agent)
1. `water_overlay.gdshader:27` — replace shallow tint `WATERCOLOR=(0.10,0.24,0.24)` with a pale gray-cyan working value so `G1` clears; keep donor deep tint `:28`. Target the §1 palette, not the raw donor linear colour (G1).
2. `water_overlay.gdshader:35–43` — add a radial-sine arc term (center/falloff above, 6 px nominal) over `field()`; keep the three donor sheets as the noise substrate (G2).
3. `water_overlay.gdshader:81–85` — set `particle_amount = 0` and scale `nautic` to `0.15`; verify the coast band shows no white foam (G3).
4. `world.gd:829–838` — bake coverage/depth at sub-tile (pixel) resolution, or lower `TEXTURE_FILTER` smoothing over one tile, so the wash band spans 30–50 px rather than one tile step (G4/G6).
5. `water_overlay.gdshader:63–64` — apply the `2.2+watershade` shallow gain (or a calibrated equivalent) before the deep mix, so shallow water is pale rather than dark teal (G1/G5).

---

## 4. Measurable acceptance criteria from a 512² PNG

All metrics are computable with Pillow on a rendered/synthesised 512×512 shallow-water piece; none require a Godot run to *define*. `target` = acceptance for the build lane; `observed` = measured on donor/reference already. No M-metric has been run against a port render by this lane (`UNVERIFIED`).

| # | Metric | Target | How to measure from the PNG | Status |
|---|---|---|---|---|
| M1 | Water-body mean RGB (water mask only) | **anchor (105,107,101) ±18/channel** *or* clean-reference (195,203,196) ±18 — state which one is being gated (§1.1 reconciliation) | Mask pixels classified `sat<0.15, G≥R−3` in the lower/right 60% of the tile; Pillow mean RGB | target; anchor `inferred`, clean value `observed` |
| M2 | Whole-tile mean RGB (composite) | between sand `#A89E7F` and water anchor; expect ≈(120–185, 125–195, 110–190) | Pillow mean over all 512² px | target |
| M3 | Band count along a shore-normal profile | **exactly 3** distinct bands (sand→wash→water) | 1-px profile perpendicular to the shore; classify S/w/W per §1.2; count stable runs ≥8 px after removing <3 px speckle | observed reference / target port |
| M4 | Sand band width | **26–51 px** (5–10% of 512) | Count S-run length on the profile (§1.2) | observed reference |
| M5 | Wash band width | **30–50 px** | Count w-run length on the profile | observed reference |
| M6 | Ripple arc crest spacing | median **6 px**, acceptance **3–12 px** | Along 4 vertical scanlines in the water mask, find local luminance maxima with ≥6-level prominence; report median gap (§1.3 method) | observed 2–8 px source / target port |
| M7 | Ripple crest↔trough luminance contrast | **≈33 levels** (trough ≈187, crest ≈220) | 20th vs 90th luminance percentile of the water mask | derived |
| M8 | Foam absence | **0** near-white pixels (`L>235, sat<0.05`) in the coast band; no continuous white band | Threshold the `band` strip (depth 0–0.57 m equivalent); count connected white runs >3 px | inferred from §1.2 / target |
| M9 | Shallow alpha at shoreline | **0.35** at `coastfade2≈0`, rising to ≤0.69 at 0.57 m | Read the layer's alpha channel / shader `mix(0.35,1.0,coastfade2)` at band start | derived from shader:88 |
| M10 | Saturation of shallow water | mean HSV **S ≤ 0.12** | `colorsys.rgb_to_hsv` on the water mask | observed (0.061–0.077) |

`UNVERIFIED`: M1–M10 have not been run against a port render — this lane does not start Godot. They are acceptance definitions for the build lane.

---

## 5. Claim table

| # | Claim | Evidence | Method | Verdict | Required correction / caveat |
|---|---|---|---|---|---|
| C1 | Clean shallow water in the reference is pale gray-cyan ≈`#C3D1CA`/`#C2CDC3`, troughs `#AFBBB4`, crests `#D8E6DE` | boxes `(398,182,420,212)`, `(390,176,422,214)`, 20/90 pct of `(396,178,422,214)` | Pillow mean/percentiles | **observed** | Use for palette; M1's clean option. |
| C2 | The ticket's `~#696B65` anchor is a **mixed crop** (pale water + dark minimap border), not clean water | box `(410,190,457,237)` → `#696A65`, Lstd **70.8** vs clean Lstd 11–16 | Pillow mean + luminance std | **observed** (contamination) / `inferred` (target rationale) | Keep as inherited design target (§1.1), flag LOW confidence as a *measured* water colour. |
| C3 | The shore is a 3-band sand→wash→water transition | `y=204` profile `S[330-353] w[354-393] W[394-422]`; 4 more scanlines agree | Pillow classifier scan | **observed** | Band widths 26–51 / 30–50 px; water = remainder. |
| C4 | Concentric arc ripples are visible in the reference, 2–8 px crest spacing | `ws_water_clean_zoom.png` + 4 luminance profiles | Pillow peak detection | **observed** (arcs) / **derived** (spacing) | M6/M7. |
| C5 | Concentric arcs are **not** in the donor wave sheets; they must be synthesized | `diffusewaves0.bmp` = cellular/caustic veins (std 48), not rings; TGA alpha constant 255 | Pillow render + channel stats | **observed** | Correction to `TERRAIN_DONOR_WATER.md §2`'s alpha-height inference; normal-map TGA is unused. |
| C6 | Active donor constants: `coastfade 0.57`, `deepfade 1.07`, shallow `(0.10,0.24,0.24)`, `particle_amount 30`, `nautic pow(1-f,5)`, foam gated by `coastfade*(1-coastfade2)` | `water.dev.frag:37,44–46,106–126,168,198–199,227` | Literal code read | **observed** | `water.lib` selects `.dev`; alternate `.frag` differs (fade 0.10, pale `(0.43,0.60,0.66)`, nautic stubbed). |
| C7 | Shallow-water opacity to use is **0.35** | `water_overlay.gdshader:88` `alpha = coverage*mix(0.35,1.0,coastfade2)`; `shore_sand.md §3` agrees | Code read | **derived** | M9. |
| C8 | Port shallow body is dark teal, not pale | `water_overlay.gdshader:27,63–64`; G1 arithmetic | Code read + arithmetic | **derived** | Change 1/5. |
| C9 | Port has no radial arc term; foam is stronger than reference | `water_overlay.gdshader:35–43,81–85` | Code read | **derived** | Changes 2/3. |
| C10 | Port depth/coverage is one-pixel-per-tile → stair-step wash | `world.gd:831–838,844–845` | Code read | **derived** | Change 4. |
| C11 | Donor has a foam family/texture | no `foam` image in `water\textures`; foam is procedural only | Prior doc §2/§4 + directory read | **REFUTED** | Do not invent a foam asset; use the shader band. |
| C12 | Alternate `water.frag` ships instead of `.dev` | `water.lib` names `.dev`; different constants in `.frag` | Read | **UNVERIFIED** | Out of scope for read-only lane; do not assume either build without runtime proof. |
| C13 | Rendered port shallow piece matches the donor/reference | — | Would require a Godot render | **UNVERIFIED** | Build lane must run M1–M10 before claiming done. |

---

## 6. Open questions / unknowns

1. Which shallow mean should be the hard gate — the inherited `#696B65` anchor or the measured clean `#C2CDC3`? §4 M1 lists both; owner must pick one (UNVERIFIED).
2. Which shader build ships retail (`.dev` fade 0.57 vs non-dev fade 0.10)? This changes depth/foam numbers materially (C12).
3. What is the world-space radius of the reference arcs? Source is 512×288 JPEG, so the 2–8 px spacing may be projection/zoom dependent; the 6 px piece nominal is an inferred scale choice.
4. Is `hmapTex` actually bound to a terrain height texture (engine-supplied), given `heightmapwaves0.tga` has constant alpha and is disabled? The `v.w` height read in `water.dev.frag:72` has no plaintext binding.
5. Foam `particle_amount` for the piece is set to 0; if the final art direction wants a faint sparkle, a small value (e.g. 3–5) can be restored — needs visual sign-off against M8.
