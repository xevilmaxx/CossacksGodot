---
title: Piece audit — rocky shore / cliff (shore_rock)
owner: T2-PIECE-SHORE-ROCK (research only)
decision: terrain beauty / donor visual fidelity
updated: 2026-11-21
status: FINAL — read-only; no Godot run, no code edit, no donor asset copied
protocol: SWARM_OPS.md §5b-QUALITY (every claim cites file:line or evidence id; observed / derived / inferred / UNVERIFIED)
prior: docs/audit/TERRAIN_DONOR_PIPELINE.md §3.3; docs/audit/TERRAIN_REFERENCE_IMAGES.md §2/§3.1/§5
---

# shore_rock — visual truth + build recipe

> [!IMPORTANT]
> This is the **only file written by this agent**. Nothing in `app/`, `assets/`, or
> any other `docs/` file was created or modified. Donor `.dds` files were read
> **read-only** at `C:\Games\Cossacks 3\data\terrain\tiles\textures\` under the
> private-use rule; no donor binary or texture was copied into the repo. Reference
> JPEGs were read read-only. All colour/luminance numbers were sampled with
> Pillow 12.1.1 into `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\`
> (crop names `sr_*`), never into the repository. No Godot process was started.
> All donor line numbers are 1-based and refer to the install as read on
> 2026-11-21 (sizes recorded so a later reader can detect a changed install).

---

## 1. Donor palette / striation evidence

### 1.1 Donor rock tile blocks (`rock*.dds`, 1024×1024 RGBA, 699,192 B each)

Sampled with Pillow. Hex = mean of the stated box in **source-texture pixels**.
"Anisotropy" = stddev of fine (4-px-sampled) column-mean luminance ÷ stddev of
row-mean luminance; **>1 means vertical striations dominate** (colour changes
left→right, continuous top→bottom), which is the orientation a cliff face needs.

| Tile | Whole-tile mean hex (RGB) | Luma | Col SD / Row SD | Anisotropy | Box evidence (hex @ box) | Role (donor) |
|------|---------------------------|------|-----------------|------------|--------------------------|--------------|
| `rock1` | `#4D4335` (77,67,53) | 68.7 | 8.01 / 5.69 | **1.41** — strongest vertical striation | TL `(0,0,256,256)`=`#504535`; BL `(0,512,256,768)`=`#5A4F3F` (L80.2); TR `(512,0,768,256)`=`#3D372C` (L55.9) | bB sector cliff (`texturemap.inc:580`) |
| `rock4` | `#473D32` (71,61,50) | 63.0 | 2.72 / 4.74 | 0.57 — horizontal-dominant | TL=`#40372E`; BR `(512,512,768,768)`=`#4F4437` | bR/bT/bRB cliff + `>2.4` override (`:583,:590-591,:598`) |
| `rock7` | `#4C4335` (76,67,53) | 68.4 | 4.23 / 3.98 | 1.06 — neutral | TL=`#473F32`; BL=`#605443` (L85.9); BR=`#494032` | bLB cliff (`:578`) |
| `rock8` | `#494226` (73,66,38) | 64.7 | 1.85 / 2.04 | 0.91 — most uniform, yellowest (B=38) | TL=`#494226`; CTR `(384,384,640,640)`=`#453E25` | `abs(h)>2.7` high-mountain override (`:595`) |
| `rock9` | `#4C4723` (76,71,35) | 67.4 | 1.74 / 2.36 | 0.74 — olive, pebbly | TL=`#4B4723`; CTR=`#484620` | forest-border tile deco only (`smoothforestborders.inc`, prior C22) |

`derived`: `rock1` is the most vertically striated donor block (1.41×), which is
why a stretched repeating `rock1` can *look* faintly striated — but its palette is
a warm brown ground tile (`#4D4335`) and its internal lit/shadow range is only
80.2/55.9 ≈ **1.43**, far below the cliff-face ratio in §1.3. `rock8` is the
donor's high-face tile and is notably **yellower/olive and near-uniform**, i.e. it
is a *face fill*, not a striation-bearing cliff skin.

### 1.2 Donor orientation + height logic (`texturemap.inc`, read-only)

- 8 sectors of `cAngle = 45°`; `vecangle := vecangle+180`; booleans
  `bR, bRB, bB, bLB, bL, bLT, bT, bRT` — donor lines **474–501** (`observed`).
- Shore wet-sand mapping: `bLB→sandsea5`, `bRB→sandsea6`, `bB→sandsea1`,
  `bL→sandsea6`, `bR→sandsea6`, `bT→sandsea1`, `bRT→sandsea5`, `bLT→sandsea6` —
  **503–511** (`observed`; see prior §3.3).
- Cliff mapping: `bLB→rock7` (`:578`), `bB→rock1` (`:580`), `bL→rock3` (`:581`),
  `bR→rock4` (`:583`), `bT→rock4` (`:590`), `bRB→rock4` (`:591`); `rock6` (`:579`)
  and `rock2` (`:582`) are **commented out** (`observed`).
- Height overrides: `abs(height)>2.7 → rock8` (`:594-595`);
  `>2.4 → rock4` (`:597-598`); `<0.1 → no tile` (`:600-601`); winter appends
  `_winter` (`:605-606`) (`observed`).
- `derived`: the donor's cliff art is **aspect-selected per cell** and then
  **height-promoted** to `rock8`/`rock4`. The effective high-face set is
  `rock4/rock7/rock8`; `rock1`/`rock3` appear only in two of the eight sectors.

### 1.3 Reference-image face evidence (Pillow, source px)

Primary **#8 `cossacks-3-v1-498085.jpg` (1280×720)**. Zoom crop
`(840,360,1100,480)` → 4× `sr_rightwall.png` (clean striated wall, abrupt rim).

| Role | Crop box (source px) | Hex (mean) | Luma | Col SD | Row SD | Note |
|------|----------------------|-----------|------|--------|--------|------|
| Lit striated face | `(948,385,1012,450)` | `#726651` (114,102,81) | 103.3 | **21.1** | 3.3 | col/row anisotropy **6.4** → vertical striations |
| Mid face | `(925,380,958,445)` | `#464030` (70,64,48) | 64.0 | 5.1 | 6.9 | recess |
| Deep shadow gully | `(880,300,930,370)` | `#312E1B` (49,46,27) | 44.9 | — | — | darkest clean face |
| Grass at rim | `(955,365,985,383)` | `#3F3D24` (63,61,36) | 58.3 | 6.1 | 12.8 | olive, G≈R |
| Rock just below rim | `(955,388,985,404)` | `#6F644C` (111,100,76) | 100.3 | 13.4 | 4.5 | R−G≈9–11 |

- `derived` **rim width**: perpendicular profile at `x=965, y=368…400` gives
  `R−G ≈ 1–4` through `y=383`, then `R−G ≈ 9–13` from `y=385` → the grass→rock
  hue crossing occupies **≈2 px** (≤3 px), with grass tufts overhanging.
- `derived` **lit/shadow ratio**: fresh boxes give 103.3/44.9 = **2.30** (deep
  shadow) and 103.3/64.0 = **1.61** (mid face). Prior TS-1 boxes
  (`docs/audit/TERRAIN_REFERENCE_IMAGES.md` §2/§3.1: lit `#6C614B` L≈97.8 vs
  shadow `#393424` L≈51.6) give **1.90**. Defensible target band **1.7–2.1,
  centre 1.9**.
- `observed` **face geometry**: the wall runs top→bottom with lateral drift
  <20% of its height (apparent ≈75–85°); face height **60–90 px of 720 p**
  (8–12% of frame), corroborating prior §3.1.

Secondary **#6 `articolo-787.jpg` (960×540)** (distant dark ravines / river
bank): `gully_center (400,225,480,285)`=`#4B452C` L68.3 colSD 8.4;
`gully_left (140,445,215,495)`=`#403A25` L57.5;
`river_top (700,0,900,30)`=`#454D55`. `observed`: darker olive-brown gully
faces, same abrupt bank→water read; lower resolution, so only corroborative.

---

## 2. Port gap (file:line)

| # | Divergence | Port evidence | Donor truth |
|---|-----------|---------------|-------------|
| G1 | Base cliff block is a **uniform random subset**, not aspect-driven. `rock1` is 16% of cells (`r<0.16`). | `app/scripts/game.gd:1166-1178` (rock1/2/3/6/7/4 by `r`) | aspect sectors `texturemap.inc:474-501,577-591` |
| G2 | `_cliff_tile_for()` uses a **6-branch asymmetric angle function**, not the donor's 8×45° sector table; maps bB→rock1 (`:1249`), bL→rock3 (`:1253`) via hard angle bands. Height overrides 2.7/2.4/0.1 are mirrored (`:1255-1260`). | `app/scripts/game.gd:1228-1261` | `texturemap.inc:474-501,557-609`; note donor *does* use rock1(bB)/rock3(bL), so the defect is the **sector math + random base**, not the names alone |
| G3 | One donor block PNG is loaded and **mirror-upscaled/stretched**, then the *same* crop is repeated across the chunk — there is no dedicated near-vertical striated face skin. | `app/scripts/world.gd:857-866` (`_block_img`: `_mirror_tileable(im,1024)`, `adjust_bcs`), `:713-735` (`_mirror_tileable`/`_wrap_crop`), `:1045` (per-block `_wrap_crop` over `S`≤2048) | donor face art selected per sector/height |
| G4 | Rock/grass boundary is **quantized to the 2 m tile grid and feathered over a whole tile**; “differing ones cross-fade over one tile”. N=33 coverage grid bilinearly upscaled; `blend_rect_mask`. This is the stair-step read. | `app/scripts/world.gd:991-997` (`_composite_blocks` comments), `:1016-1046` (N grid + `_alpha_mask`), `:830` (linear filter “feathers the shoreline over one tile”) | rim ≤3 px contour-following (`#8 x=965`) |
| G5 | Cliff role pass feeds the *tileblock names* (including `rock1`/`rock3`) into the atlas; the comment claims only `rock4/7/8`. | `app/scripts/world.gd:1095-1107` (`:1097` comment), `app/scripts/game.gd:1249,1253` | high-face set `rock8`/`rock4` (>2.7/>2.4) |
| G6 | 3-pass tile smoothing operates on axis-aligned cell pairs; it cannot produce a sub-tile, contour-following rim. | `app/scripts/game.gd:1354-1361` (`_smooth_tilemap`), `:1295-1352` (`_tb_smooth_pair`) | donor `SmoothTileMap` 3 passes but art is authored to agree (`prior §3.3`) |
| G7 | Converted donor blocks exist and are warm-brown ground tiles (`rock1.png` etc.), matching §1.1; no rock-stone sprite overlay exists in the cliff layer. | `app/assets/terrain/blocks/rock1.png` … `rock8.png`; `app/scripts/world.gd:173-175` (warm list) | sprite/decor accent needed to break the repeated skin |

`derived` summary: the port has the **names and the height thresholds** but not
the **per-cell aspect selection, the face skin, or the sub-tile rim**. Result:
a stretched repeating `rock1`-family ground tile behind a full-tile, stair-stepped
grass boundary — not a near-vertical striated face meeting grass in ≤3 px.

---

## 3. Machine-readable build spec

Face height / edge width are numeric targets from §1.3 (reference-image px at
1280×720; the 512² piece is the authoring canvas, not the screen projection).

```json
{
  "name": "shore_rock",
  "size_px": [512, 512],
  "seed": 7,
  "layers": [
    {"type": "block", "name": "rock8", "tile": true},
    {"type": "sprite", "name": "rock_stones1", "pos": [0.7, 0.6], "scale": 1.0}
  ],
  "face_height_px": 75,
  "face_height_range_px": [60, 90],
  "face_height_fraction_of_frame": [0.08, 0.12],
  "face_apparent_slope_deg": [75, 85],
  "rim_edge_width_px": 2,
  "rim_edge_width_max_px": 3,
  "lit_shadow_luma_ratio_target": 1.9,
  "lit_shadow_luma_ratio_range": [1.7, 2.1],
  "reference": {
    "primary": {
      "file": "C:/Users/Maxym.Oboyshev/Downloads/c3/cossacks-3-v1-498085.jpg",
      "size": [1280, 720],
      "zoom_crop": [840, 360, 1100, 480],
      "zoom_factor": 4,
      "lit_face": {"box": [948, 385, 1012, 450], "hex": "#726651", "luma": 103.3, "col_sd": 21.1, "row_sd": 3.3},
      "mid_face": {"box": [925, 380, 958, 445], "hex": "#464030", "luma": 64.0},
      "shadow_face": {"box": [880, 300, 930, 370], "hex": "#312E1B", "luma": 44.9},
      "grass_rim": {"box": [955, 365, 985, 383], "hex": "#3F3D24", "luma": 58.3},
      "rock_below_rim": {"box": [955, 388, 985, 404], "hex": "#6F644C", "luma": 100.3},
      "rim_profile": {"x": 965, "y": [368, 400], "grass_r_minus_g": [1, 4], "rock_r_minus_g": [9, 13], "transition_px": 2},
      "prior_hex_pair": {"lit": "#6C614B", "shadow": "#393424", "ratio": 1.9}
    },
    "secondary": {
      "file": "C:/Users/Maxym.Oboyshev/Downloads/c3/articolo-787.jpg",
      "size": [960, 540],
      "gully_center": {"box": [400, 225, 480, 285], "hex": "#4B452C", "luma": 68.3},
      "gully_left": {"box": [140, 445, 215, 495], "hex": "#403A25", "luma": 57.5}
    },
    "donor_tiles": {
      "dir": "C:/Games/Cossacks 3/data/terrain/tiles/textures",
      "size": [1024, 1024],
      "rock1": {"hex": "#4D4335", "anisotropy": 1.41, "sector": "bB"},
      "rock4": {"hex": "#473D32", "anisotropy": 0.57, "sector": "bR/bT/bRB", "height_override": ">2.4"},
      "rock7": {"hex": "#4C4335", "anisotropy": 1.06, "sector": "bLB"},
      "rock8": {"hex": "#494226", "anisotropy": 0.91, "height_override": ">2.7"}
    },
    "donor_script": {
      "file": "C:/Games/Cossacks 3/data/scripts/common.inc/texturemap.inc",
      "sector_lines": [474, 501],
      "cliff_name_lines": [577, 591],
      "height_override_lines": [594, 601]
    }
  }
}
```

Recipe reading: a `rock8` tiled block supplies the high-face fill (donor
`>2.7`); `rock_stones1` at `[0.7,0.6]` scale `1.0` is the accent that breaks the
repeat and supplies the striation/uniformity contrast; the grass→face rim is
drawn as a **≤3 px contour-following** edge, not a per-tile cross-fade; the face
is near-vertical (75–85°) and 60–90 px tall at the reference scale; the lit and
shadow facets are separated by ~1.9× luminance. When wiring into the port,
select the base block from the **8-sector aspect** of the height gradient with
the `>2.7`/`>2.4` overrides (fix `game.gd:1228-1261` + `:1166-1178`), and replace
the one-tile feather with a sub-tile rim (fix `world.gd:991-1046`).

---

## 4. Measurable acceptance criteria (from a rendered PNG)

Measure on a 512×512 render of the piece (or a matched-resolution crop), with
Pillow; mark the lit face, shadow face and rim by hand once and reuse the boxes.

| ID | Criterion | Metric (Pillow method) | Target | Donor anchor |
|----|-----------|------------------------|--------|--------------|
| **A1** | Striation contrast / direction | On a marked lit-face box: `Image.convert('L')`, per-column mean → `pstdev(cols)` (`colSD`); same for rows (`rowSD`); anisotropy `colSD/rowSD` | `colSD ≥ 12` **and** anisotropy `≥ 3.0` (vertical striations dominate) | lit box colSD 21.1, rowSD 3.3 → 6.4 (§1.3); donor `rock1` texture 1.41 |
| **A2** | Rim transition width | Along a 1-px line perpendicular to the rim, count pixels from grass (`G ≥ R`, olive) to rock (`R−G ≥ 8`) | **≤3 px**, target 2 px | profile at x=965 crosses in ~2 px (§1.3); prior §5 rank 6 |
| **A3** | Lit/shadow luminance ratio | Box-mean luminance `0.299R+0.587G+0.114B` of lit face ÷ shadow face | **1.7–2.1**, target **1.9** | 1.90 prior; 1.61–2.23 fresh (§1.3) |
| **A4** | Face near-vertical | Top/bottom x-offset of the marked face ÷ face height | **<0.20** (≈75–85°) | prior §3.1 / §5 rank 1 |
| **A5** | Face height | Marked face height in the 720p-equivalent projection | **60–90 px** (8–12% of frame) | §1.3 / prior §3.1 |
| **A6** | Palette anchor (supporting) | Mean hex of lit face within ±12 RGB of `#726651`/`#6C614B`; rock fill near donor `rock8` `#494226` | within tolerance | §1.1/§1.3 |

Global gate (supporting): mean HSV saturation 0.30–0.55, value 0.25–0.45, olive
rock/grass — consistent with `TERRAIN_REFERENCE_IMAGES.md` §5.

---

## 5. Claim table (labels per SWARM_OPS.md §5b-QUALITY)

Verdicts: **observed** = literal line/pixel read; **derived** = arithmetic or
code-path consequence; **inferred** = attribution without direct proof;
**UNVERIFIED** = not confirmable from the material read.

| # | Claim | Evidence (file:line / crop) | Verification method | Verdict | Required correction |
|---|-------|-----------------------------|---------------------|---------|---------------------|
| C1 | Donor cliff art is chosen in 8 × 45° aspect sectors by the height-gradient vector | `texturemap.inc:474-501` | Direct read | **observed** | Mirror the 8-sector table in `_cliff_tile_for` (`game.gd:1228-1261`) |
| C2 | Donor high faces promote to `rock8` at `abs(h)>2.7`, `rock4` at `>2.4`, no tile at `<0.1` | `texturemap.inc:594-601`; port mirror `game.gd:1255-1260` | Direct read, both sides | **observed** | Keep thresholds; they are already correct in port |
| C3 | `rock1` is the most vertically striated donor block (anisotropy 1.41); `rock8` is near-uniform/yellow (0.91, `#494226`) | Pillow `rock1.dds`/`rock8.dds`, §1.1 | Column/row luminance stddev | **observed** | Use `rock8` as high-face fill; do not equate "stretched rock1" with a cliff face |
| C4 | Reference rim is ≤3 px (measured ≈2), with grass overhang | #8 crop `(840,360,1100,480)`, profile `x=965` (§1.3) | Pillow R−G crossing profile | **derived** | Replace port one-tile feather (`world.gd:991-997`) with sub-tile rim |
| C5 | Reference lit/shadow luminance ratio ≈1.9 (band 1.61–2.30) | #8 boxes §1.3; prior `TERRAIN_REFERENCE_IMAGES.md` §2/§3.1 | Box-mean luma arithmetic | **derived** | Target 1.7–2.1 in A3; current port has no explicit facet lighting |
| C6 | Reference face height 60–90 px @720p, near-vertical (drift <20%) | #8 `sr_rightwall.png`; prior §3.1 | Visual + crop measurement | **observed** (geometry), **inferred** (exact degrees) | A4/A5; apparent angle is 2.5D, not true 3D slope |
| C7 | Port base cliff block is a random subset, `rock1` at 16% | `game.gd:1166-1178` | Direct read | **observed** | Drive base block from aspect (G1) |
| C8 | Port aspect function is reduced/asymmetric vs donor 8 sectors | `game.gd:1238-1253` vs `texturemap.inc:474-501` | Side-by-side read | **observed** | Implement exact 8-sector thresholds; note `rock1`/`rock3` names are donor-valid for bB/bL |
| C9 | Port renders one mirror-upscaled repeating block across the whole face | `world.gd:857-866`, `:713-735`, `:1045` | Code-path trace | **derived** | Add a dedicated striated face skin / `rock_stones1` accent |
| C10 | Port rock↔grass edge is tile-grid quantized and one tile wide → stair-step | `world.gd:991-997`, `:1016-1046`, `:830` | Code-path trace | **derived** | Sub-tile, contour-following rim (A2) |
| C11 | `articolo-787` gully faces are darker olive (`#4B452C`/`#403A25`), corroborating a dark recess facet | #6 boxes §1.3 | Pillow box means | **observed** | Use only as secondary palette corroboration (low-res) |
| C12 | Exact face height/width as it would render in the current Godot port | none — no render produced | Would require a Godot screenshot | **UNVERIFIED** | Do not claim A1–A5 pass until a PNG is measured |

---

## Open questions

1. Which 512² piece will actually be emitted — a baked single tile, or a
   composite canvas? A1–A5 assume a matched-resolution PNG; the projection
   scale (face px ↔ world tile) must be fixed before A4/A5 are meaningful.
2. `rock_stones1` is specified by the recipe but no such asset was audited here;
   its donor source/availability is **UNVERIFIED**.
3. The port's `rock8.png` is a converted ground tile (1024² donor); whether a
   dedicated cliff-face sprite exists anywhere in `app/assets` was out of scope.

End.
