---
title: T2 PIECE — forest_conifer (visual truth + recipe)
owner: T2-PIECE-FOREST-CONIFER
date: 2026-11-21
scope: research-only — visual truth, sprite audit, reproducible piece spec; no code edits
status: DONE (research)
---

# T2 PIECE — `forest_conifer`

Target: a 512×512 "conifer forest piece" — layered dark-green conifers on forest-floor
grass, with three size buckets, dense clustering and lower-left contact shadows.
All pixel numbers below were measured with Pillow 12.1.1 from temporary crops under
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\` (never written into the repo).
No donor file was copied into the project. Tags: `observed`, `derived`, `inferred`.

---

## 1. Donor evidence

### 1.1 Meshes / actors (`observed`)
| Family | Donor files | Variants | `envscales.cfg` scale (minscale/maxscale) |
|---|---|---|---|
| Spruce | `data/actors/env/spruce.actor` → `spruce1..4.osm` (48–60 kB each) | 4 | `group = spruce1`, `scale = 0.5`, min 0.85 / max 1.15 (all 5 entries, `:368-400`) |
| Small pine | `data/actors/env/pinesmall.actor` → `pinesmall1..4.osm` | 4 | `group = pinesmall1`, scale **0.5 / 0.535 / 0.56 / 0.61 / 0.5**, min 0.85 / max 1.15 (`:263-295`) |
| Small fir | `data/actors/env/firsmall.actor` → `firsmall1..4.osm` | 4 | `group = firsmall`, `scale = 0.5`, min 0.85 / max 1.15 (`:193-225`) |
| Dry pine | `data/actors/env/pinedry.actor` → `pinedry1..4.osm` | 4 | `group = pinedry1`, scale **0.65 / 0.618 / 0.706 / 0.76 / 0.5**, min 0.85 / max 1.15 (`:403-435`) |

`derived`: donor jitter is ±15 %; relative size ladder is dry pine (0.62–0.76) > small
pine (0.50–0.61) ≈ spruce ≈ small fir (0.50). The four variants per family explain why a
single "spruce" silhouette repeats in-game — the donor also repeats 4 authored meshes.

### 1.2 Forest patterns (`observed`)
`data/pattern/` contains **no** `forests_spruce_*` file. The spruce families are
`d_frt_spr_big_1..4.pattern` (65–73 kB) and `d_frt_spr_mid_1..4.pattern` (46–71 kB),
plus `d_frt_pinedry_big_1..4.pattern` — 8 spruce patterns in total, matching
`TERRAIN_DONOR_PATTERNS.md` §4 (`d_frt_spr_*`, 8 families, "spruce*"). Patterns are binary
index data with no embedded actor-name strings (`observed`; byte scan for
`spruce|pine|fir` in `d_frt_spr_big_1.pattern` returned none), so species assignment comes
from the cfg family name, not from the file bytes. Per-cell detail comes from
`n_small_frt_*` (`texturemap.inc:215,317-319,830`) and forest-edge clumps from `fb_1..fb_53`
(`smoothforestborders.inc:110-123`, chosen when `forestType=cForestTypePineFirSpruce`).

### 1.3 Visual truth from reference crops (`observed` + `derived`)
| Source | Crop / view | What it shows | Measured crown colour (Pillow) |
|---|---|---|---|
| `large_1.webp` (788×377) | dense-forest crop `(150,20,638,397)` upscaled 2× with 100 px grid | dark layered spruces + bright yellow-green spruce tips, ~120–180 trees in 488×377 src px | dark crown box `(455,55,510,105)` → lit35 `#3A3E23` (58,62,35), all `#2E311A` (46,49,26), hue **68.7°**; lit tips `(492,190,538,280)` → lit35 `#4B4A25` (75,74,37), hue 58.6° |
| `cossacks-3-guardians-...-wallpaper-3.jpg` (1916×1080) | forest/town view `(0,500,700,1080)` | large dark spruce with whorled branches, small lime saplings, broadleaf lime tree, one bare tree; shadow pooled at tree base to lower-left | dark spruce `(545,545,635,690)` → lit35 `#525927` (82,89,40), hue 69.2°; sapling tips `(370,960,445,1065)` → `#4E5424` (78,84,36), hue 67.4° |
| `cossacks-3-v1-498085.jpg` (1280×720) | gully-rim band `(0,180,560,560)` at 2× + 100 px grid | conifers line gully rims, not gully floors; clear 3-tier size hierarchy; dark shadows under canopy | dark conifer `(450,250,490,330)` → lit35 `#5D5E31` (93,95,49), hue 61.8°; yellow conifer `(112,425,148,490)` → `#575429` (87,84,41) |

`observed`: conifer silhouette = narrow, tiered triangular crown with a visible thin
trunk and whorled branch fans; bright-tipped ("lime") and dark ("dusk") crowns coexist
in the same frame. `derived`: reference conifer hue spans **58–69°**, lit crown `B/G ≈
0.42–0.55`, luminance 46–95 (8-bit). This independently reproduces
`TERRAIN_REFERENCE_IMAGES.md` §3.2/§5 (`#30331B`–`#656937`, 650–1000 trees/MP dense,
small 15–30 / mid 40–60 / large 70–100 px at 720p) — the new crops land inside those
bands. `observed`: sun from upper-right, shadows lower-left; prior measured lit/shadow
luma ratio 1.7–1.9, length 1–2× tree height (`TERRAIN_REFERENCE_IMAGES.md` §3.5).

---

## 2. Port state

### 2.1 New sprites (all 512×512 RGBA; Pillow `observed`)
| Sprite | Alpha bbox (px) | bbox H/W | Crown mean / lit35 (hex) | Crown hue | Crown lum | Opaque % |
|---|---|---:|---|---:|---:|---:|
| `tree_spruce1` | (144,56)-(368,450) | **1.76** | `#171404` / `#302C09` | 51.6° | 19.8 | 14.5 |
| `tree_spruce2` | (177,58)-(335,449) | **2.47** | `#231E02` / `#423B03` | 51.2° | 29.0 | 10.1 |
| `tree_spruce3` | (171,58)-(342,452) | **2.30** | `#100A01` / `#221702` | 37.6° | 10.7 | 11.2 |
| `tree_spruce4` | (128,62)-(383,456) | **1.55** | `#161303` / `#2E2A07` | 50.1° | 18.7 | 17.2 |
| `tree_pinesmall1` | (169,64)-(344,451) | 2.21 | `#0F0F05` / `#1C1C0A` | 59.6° | 14.3 | 13.2 |
| `tree_pinesmall2` | (139,59)-(373,447) | 1.66 | `#131502` / `#252A04` | 67.0° | 19.3 | 16.2 |
| `tree_pinesmall3` | (103,91)-(409,456) | **1.19** | `#0A0D04` / `#161D09` | 80.4° | 11.3 | 18.1 |
| `tree_pinesmall4` | (155,61)-(357,448) | 1.92 | `#0F0F05` / `#1D1D0A` | 59.8° | 14.3 | 12.1 |
| `tree_firsmall1` | (127,54)-(385,462) | 1.58 | `#292505` / `#5B540B` | 54.5° | 35.7 | 19.5 |
| `tree_firsmall2` | (145,63)-(367,458) | 1.78 | `#262707` / `#545610` | 62.5° | 36.4 | 15.5 |
| `tree_firsmall3` | (114,62)-(400,463) | **1.40** | `#252204` / `#544E09` | 54.1° | 32.7 | 21.7 |
| `tree_firsmall4` | (145,63)-(367,458) | 1.78 | `#282505` / `#5A530A` | 54.7° | 35.2 | 15.5 |
| `tree_pinedry1..4` | ~139×384, 82×381, 118×393, 143×388 | 2.7–4.7 | `#241B0D`…`#261E0F` / `#2D2311`…`#322715` | 37–38° | 28–31 | **2.1–3.1** |
| (legacy) `tree_fir` | 240×390 | 1.62 | `#2A2509` / `#514811` | 51.5° | 35.9 | 17.6 |
| (legacy) `tree_pine` | 184×392 | 2.13 | `#101007` / `#1E1E0D` | 59.2° | 15.4 | 9.2 |
| (legacy) `tree_oak` | 287×403 | 1.40 | `#2F3001` / `#555602` | 61.1° | 44.0 | 20.2 |

`observed` (visual contact sheet, sprites composited on olive ground): spruce1–4 are
tall narrow tiered triangles (spruce4 broadest); pinesmall1/2/4 are narrow needle tufts,
but **pinesmall3 is a broad fan/shrub silhouette (H/W 1.19)**; firsmall1–4 are classic
bright-lit triangular firs; pinedry1–4 are bare trunks with stub branches (≤3 % coverage,
i.e. dead trees, not live conifers); `tree_oak` is the only broadleaf (round lime crown).
`derived`: three live-conifer colour families exist — **near-black spruce** (lum 11–29),
**mid-lit firsmall** (lum 33–36, lit35 ≈ `#5B540B`), **dark pinesmall** (lum 11–19) —
plus a fourth **dry/brown** family (pinedry, hue 37°).

**Palette gap (`derived`):** sprite crown blue is 2–11/255, while donor crown blue is
27–55 (§1.3). Relative lit-tip delta ≈ sprite `#5B540B` (91,84,11) → donor `#656937`
(101,105,55), i.e. roughly **(+10,+21,+44)** in RGB; dark crown `#302C09` (48,44,9) →
`#30331B` (48,51,27) ≈ **(0,+7,+18)**. Sprite hue also skews yellow (37–52° for spruce)
where donor conifers are green (59–69°). `world.gd:1425` tints trees
`Color(1.12, 1.2, 1.02)`, which lifts green but leaves the blue deficit essentially
untouched. Exact corrective tint is **UNVERIFIED** pending a rendered comparison.

**Shadows (`observed`):** no baked ground-shadow ellipse exists in any sprite's alpha —
the bottom 12 % of opaque pixels are brown trunk (`#2D251D`, `#342410`, `#251F15`…),
not a neutral dark ellipse. `world.gd:1423-1424` adds a separate `_blob_rect` at
`p+(0,2)`, size `(7+1.6·h) × (3.5+0.8·h)`, alpha 0.14; it is foot-centred and does not
scale with sun direction (port-state gap, matches `TERRAIN_PORT_DECOR.md` G11).

### 2.2 Placement / density in `world.gd` (`observed`, read at `:1356-1506`)
- Pool: `FOREST_CONIFER_POOL` = 4 spruce + 4 pinesmall + 4 firsmall + 4 pinedry (16);
  broadleaf oak only when `_hash(fp.x,fp.y) > 0.86` (~14 %).
- `TREE_SIZE_BUCKETS = [0.9,1.0,1.12]`; detail buckets
  `FOREST_TREE_H = [1.6, 4.0, 6.8]` m with `_prop_bucket(fp,17,10)`: bucket 7–8 → 4.0,
  bucket 9 → 6.8, buckets 0–6 → 1.6 ⇒ **70 % / 20 % / 10 %** small/mid/large.
- At `view_scale = 16 px/m` (`world.gd:16`, `data.gd:23 TILE_M=2.0` ⇒ 32 px per tile):
  `hh × size_var (0.88–1.12)` gives **22.5–28.7 px / 56.3–71.7 px / 95.7–121.9 px**
  (edge singles ×0.8 ⇒ 18–23 / 45–57 / 77–98 px). This matches donor's 15–30 / 40–60 /
  70–100 px buckets at 720p except the large bucket runs ~9–22 % tall.
- Count: `count = 1 + _prop_bucket(...,3)` ⇒ **1–3 trees per forest tile**; plus ~0.5
  understory/tile and sparse hash-gated (>0.62) singles on neighbouring non-forest cells.
  `derived`: 1–3 trees / 32×32 px = **976–2929 trees/MP (mean ≈1953)** inside solid
  forest, i.e. **~2–3× donor dense-forest 650–1000/MP**. Understory ≈488/MP.
- Placement is deterministic per fractional tile (no RNG state), with yaw ±0.13 rad and
  a 50 % horizontal mirror (`world.gd:1425-1427`) — silhouette variety exists without
  new textures. No sway; no per-tree real shadow.

### 2.3 Ground block
`app/assets/terrain/blocks/grass_ground2.png` = **1024×1024 RGB**, mean `#535428`
(83,84,40) — the port forest-floor role tile (`world.gd:841`, terrain type 2). It is
~1.4× brighter than donor forest floor `#3B3F1B` (59,63,27) and should be tinted down
≈0.72–0.78 when used as the conifer-piece base.

---

## 3. Spec — `forest_conifer` (512×512, seed 7)

Core recipe, as commissioned (the `reference` object carries the measured donor targets):

```json
{
  "name": "forest_conifer",
  "size_px": [512, 512],
  "seed": 7,
  "layers": [
    {"type": "block", "name": "grass_ground2", "tile": true},
    {"type": "sprite", "name": "tree_spruce2",   "pos": [0.3, 0.6], "scale": 1.0},
    {"type": "sprite", "name": "tree_pinesmall1", "pos": [0.6, 0.4], "scale": 0.7}
  ],
  "reference": {
    "images": [
      {"file": "large_1.webp",
       "crop_src_px": [150, 20, 638, 397],
       "role": "dense conifer cluster + dark/lit crown sampling"},
      {"file": "cossacks-3-guardians-of-the-highlands-pc-gioco-steam-wallpaper-3.jpg",
       "crop_src_px": [0, 500, 700, 1080],
       "role": "spruce morphology, size hierarchy, base shadows"},
      {"file": "cossacks-3-v1-498085.jpg",
       "crop_src_px": [0, 180, 560, 560],
       "role": "gully-rim conifers and density"}
    ],
    "donor_assets": [
      "data/actors/env/spruce1..4.osm", "data/actors/env/pinesmall1..4.osm",
      "data/actors/env/firsmall1..4.osm", "data/actors/env/pinedry1..4.osm",
      "data/pattern/d_frt_spr_big_1..4.pattern",
      "data/pattern/d_frt_spr_mid_1..4.pattern",
      "data/game/var/envscales.cfg"
    ],
    "crown_hex_dark": ["#30331B", "#2E311A", "#3A3E23"],
    "crown_hex_lit": ["#656937", "#4B4A25", "#525927"],
    "crown_hue_deg": [58, 69],
    "density_per_MP": {"dense_forest": [650, 1000], "gully_rim": [150, 250]},
    "size_buckets_px_at_720p": {"small": [15, 30], "medium": [40, 60], "large": [70, 100]},
    "shadows": {"direction": "lower-left", "length_x_height": [1, 2],
                "lit_to_shadow_luma_min": 1.5}
  }
}
```

### Scale convention (`derived`, needed to make `scale` reproducible)
`scale = 1.0` means a **96 px tall** conifer on the 512² canvas (= donor large bucket
70–100 px); the sprite's 512 px source is downscaled accordingly.
- small bucket: scale **0.25–0.35** → 24–34 px (60 % of trees)
- mid bucket:   scale **0.45–0.65** → 43–62 px (30 %)
- large bucket: scale **0.80–1.05** → 77–101 px (10 %)
The two core sprites therefore read as large spruce (scale 1.0) and mid small-pine
(scale 0.7 → 67 px, just above the 60 px mid ceiling — use 0.6 for strict mid).

### Dense-fill extension (measured density, for the builder)
The two-tree core is a *seed demo*, not a dense forest. For the actual dense piece,
expand `layers` to **170–262 conifers** in 512² (= 650–1000 trees/MP) with seed 7:
- species weights: spruce **0.40**, pinesmall **0.30**, firsmall **0.20**, pinedry **0.10**
  (pinedry = dead-tree accent, ≤10 %; port currently uses 4/16 = 25 % — too high);
- size weights: small 0.60 / mid 0.30 / large 0.10, matching `FOREST_TREE_H` bucket odds
  (70/20/10) within tolerance;
- positions: `pos = [hash(7, 2i), hash(7, 2i+1)]` mapped into `[0.04,0.96]`, then a
  Poisson-style rejection if crown bboxes overlap >60 % (clumped, not gridded);
- per-tree contact blob: width ≈ `0.45·rendered_h`, height ≈ `0.18·rendered_h`,
  offset `[0, +2 px]`, alpha 0.14, direction lower-left, length 1–2× height.

---

## 4. Measurable criteria from a rendered PNG

| # | Criterion | Target (measured from donor + sprites) | How to measure from the 512² PNG |
|---|---|---|---|
| 1 | Crown colour families | ≥2 live conifer families: dark `B/G 0.42–0.55`, hue 58–69°, lum 46–95 (`#2E311A`…`#656937`); dry accent hue 37–38° ≤10 % | Mask non-grass pixels, take upper-65 %-luminance crown pixels, report median hex + hue; require median `B ≥ 0.4·G` |
| 2 | Blue-lift gate | sprite-derived crowns currently `B/G ≈ 0.1–0.35`;PASS requires `B/G ≥ 0.40` | Compare per-family median RGB with §1.3 boxes; flag if B < 20 for dark crown |
| 3 | Tree count / density | dense 170–262 trees per 512² (650–1000/MP); rim variant 39–66 (150–250/MP) | 100 px grid overlay + manual crown count (same method as `TERRAIN_REFERENCE_IMAGES.md` §5 rank 4) |
| 4 | Size buckets | ≥3 buckets: 24–34 px (≈60 %), 43–62 px (≈30 %), 77–101 px (≈10 %) | Connected-component bbox heights on segmented crowns; histogram into those bins |
| 5 | Silhouette hierarchy | H/W: spruce 1.55–2.47, pinesmall 1.19–2.21, firsmall 1.40–1.78, dry 2.7–4.7 | Measure alpha/component bbox; flag `pinesmall3` (1.19) as shrub-shaped, not a tree |
| 6 | Shadow presence & direction | one dark ellipse per tree, centroid lower-left of foot, length 1–2× height, lit/shadow luma ratio ≥1.5 | Sample paired lit/shadow grass pixels under a tree; compute luma ratio and shadow-centroid offset |
| 7 | Ground base | forest-floor olive ≈ `#3B3F1B`; port `grass_ground2` `#535428` must be tinted ×0.72–0.78 | Mean RGB of block-only region; compare to donor forest floor |
| 8 | Species mix | conifers ≥90 % of crowns, oak ≤10 %, dry ≤10 % | Classify by crown hue + component width; count fractions |

Global gate (from prior TS-1): HSV sat 0.30–0.55, value 0.25–0.45 for temperate shots.

---

## 5. Claim table

| # | Claim | Evidence | Verification method | Verdict | Correction needed |
|---|---|---|---|---|---|
| 1 | Donor has 4 spruce meshes + 4 variants each for pinesmall/firsmall/pinedry | `spruce.actor`, `pinesmall.actor`, `firsmall.actor`, `pinedry.actor`, 16 `.osm` | Read actor files + dir listing | CONFIRMED | none |
| 2 | Env jitter ±15 % and scale ladder dry > small-pine ≈ spruce ≈ fir | `envscales.cfg:158-435` | Read scale/minscale/maxscale fields | CONFIRMED | port uses ±12 % (`size_var 0.88–1.12`), close but not exact |
| 3 | Donor pattern files are named `forests_spruce_*` | Directory scan of `data/pattern/` | `Get-ChildItem -Recurse` | CORRECTED | Files are `d_frt_spr_big_1..4` + `d_frt_spr_mid_1..4` (8) |
| 4 | Donor conifer crown hue 58–69°, dark `#30331B`, lit `#656937` | ref11/ref7/ref8 crops; `TERRAIN_REFERENCE_IMAGES.md` §3.2 | Pillow box means, upper-65 % lit pixels | CONFIRMED | none |
| 5 | Dense forest 650–1000 trees/MP; rim 150–250; 3 size buckets | `t2_ref11_grid.png`, `t2_ref8_grid.png`, TS-1 §5 | 100 px grid count | CONFIRMED | ±25 %, crowns overlap |
| 6 | New sprites are 512×512 with four distinct conifer families | `sprites_hi/tree_*.png` | Pillow size + alpha bbox + HSV | CONFIRMED | `pinesmall3` H/W 1.19 reads as a shrub, not a conifer tree |
| 7 | Sprite crowns have donor-matching blue channel | Sprite lit35 `#5B540B`/`#302C09` vs donor `#656937`/`#30331B` | RGB hex comparison | CONTRADICTED | Blue deficit 18–44; needs blue-lifting tint or re-bake; exact tint UNVERIFIED |
| 8 | Sprites contain baked ground shadows | Alpha-bbox bottom-12 % sampling + contact sheet | Pillow + visual | CONTRADICTED | No baked ellipse; base pixels are brown trunk. Port adds `_blob_rect` (`world.gd:1423`) |
| 9 | Port forest detail density matches donor dense forest | `world.gd:1472-1478`, `data.gd:23`, `world.gd:16` | 1–3 / 32×32 px → 976–2929/MP | CONTRADICTED | Port ≈2–3× denser; reduce to ~1 tree/tile or thin by hash for piece spec |
| 10 | Port bucket heights match donor 15–30/40–60/70–100 px | `FOREST_TREE_H`, `size_var`, 16 px/m | Arithmetic | PARTIAL | large bucket 96–122 px overshoots; edge singles fit |
| 11 | Port colour variety reaches spruce/pinesmall/firsmall/pinedry | `FOREST_CONIFER_POOL` 16 names, sprite existence | Grep + file listing | CONFIRMED | Dry pine is 25 % of pool vs donor-like ≤10 % target |
| 12 | `grass_ground2` is the right forest-floor base | `grass_ground2.png` mean `#535428` vs donor `#3B3F1B` | Pillow mean RGB | PARTIAL | needs ×0.72–0.78 downward tint |
| 13 | Shadows fall lower-left with lit/shadow ratio ≥1.5 | `TERRAIN_REFERENCE_IMAGES.md` §3.5; ref7/ref11 crops | Prior paired-pixel sampling + visual | CONFIRMED | port blob is directionless (not sun-linked) |

**End of research. No code, Godot scene, donor copy or repo asset was modified.**
