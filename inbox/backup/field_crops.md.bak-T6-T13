# T2-PIECE-FIELD-CROPS — `field_crops` wheat-field piece

RESEARCH only. Exactly one output file. No code, no Godot run, no donor binary copied into the repo.
All pixel work used Pillow 12.1.1 on the original donor `.dds`, the port `.png`, and the two named
reference images; probe scripts and viewing crops lived **only** in
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\`. Tags: `observed` (read in source / seen in image),
`derived` (computed from pixels), `inferred` (interpretation), `UNVERIFIED` (not confirmable in this lane).

Priors: `docs/audit/TERRAIN_REFERENCE_IMAGES.md` §2 palette table, §3.3 ground texture (wheat =
"sharp straight rectangular edges and dense vertical-stalk texture in golden `#8E6F29`–`#B18A33`"),
§5 criterion 8; `docs/audit/TERRAIN_PORT_DECOR.md` G10 (`:141`) and its asset table (`:113-115`).

**Purpose:** define a 512×512 *wheat-field* piece whose visual truth is (a) a contiguous rectangular
golden footprint with a hard edge, (b) a dense vertical-stalk fill, and (c) a summer/winter decal pair.
The port draws each food node as 5–9 procedural sticks with bead heads and has the donor field decals
converted to PNG but unwired (preview tool only). This doc supplies donor evidence with crop boxes/hex,
the current `file:line` gap, the required JSON spec with stalk/edge numbers, measurable gates, and a
claim table.

---

## 1. Donor evidence (crop boxes / hex / alpha)

### 1.1 The two field decals — DXT5 512×512 with an alpha footprint (`observed` + `derived`)

Donor files (`observed`, Pillow header read):
`C:\Games\Cossacks 3\data\terrain\decals\env\envfieldd.dds` and `envfielddw.dds`.
Both are `DDS ` magic, `DXT5` FourCC, **512×512**, decoded by Pillow to RGBA. Converted viewing copies:
temp `donor_envfieldd.png`, `donor_envfielddw.png` (never in repo).

| Property (`derived`, full 512²) | `envfieldd` (summer) | `envfielddw` (winter) |
|---|---|---|
| Alpha min/max/mean | 0 / 255 / 148.1 | 0 / 255 / 148.1 |
| Fully opaque (a>250) / semi (5<a≤250) | 30.7% / 50.4% | 30.7% / 50.4% |
| Alpha bbox a>8 | `(17,19,494,494)` = 477×475 | identical |
| Alpha bbox a>250 | `(22,33,487,480)` = 465×447 | identical |
| Left/right 10–90% alpha ramp at y=256 | **12 px** (x 21→33; x 487→475) | identical |
| Opaque-region mean RGB | (77.2, 68.4, 46.1) = **`#4D442E`** | (116.7, 111.1, 97.1) = **`#756F61`** |
| Dominant 16-step quant buckets | `#403020` 17.1%, `#504030` 12.3%, `#404020` 11.4%, `#303020` 10.7%, `#302010` 7.9% | `#706060` 12.2%, `#606050` 10.8%, `#808070` 10.1%, `#605040` 6.7%, `#505040` 6.5% |
| Vertical vs horizontal gradient | \|dI/dx\|=14.00, \|dI/dy\|=13.54, ratio **1.03** | 19.40 / 19.21, ratio **1.01** |
| Strong vertical-edge columns in interior (457×439) | ~56 → **~12 per 100 px** | ~52 → **~11 per 100 px** |

Visual read of the converted crops (`observed`): an **olive/brown** field of long vertical stalk rows
(`envfieldd`) and the same pattern desaturated to neutral gray (`envfielddw`); the surrounding alpha is
ragged, with stalk tips protruding at top/bottom and a ~12 px soft ramp at the left/right sides. The
decal art itself is **not golden**. The gold in the reference screenshots is a render-time colour
(lit/tinted decal or crop-stage overlay) — inferred, not provable from these DDS bytes.

Key geometric fact (`observed`): the donor decal footprint is a **near-rectangle 477×475 inside
512×512**, i.e. ~93% of the tile in each axis. Its ~12 px alpha ramp is a *decal-atlas* feather, not the
hard gameplay field edge; the hard rectangular field outline seen in-game is the footprint mask, which
is absent from the port (§2).

### 1.2 Material cross-check — correction to the task brief (`observed`)

`envfieldd`/`envfielddw` are registered in
`C:\Games\Cossacks 3\data\terrain\decals\decals.mat` (offsets ~2863 and ~3007):
`Material.Name = envfieldd` → `.\data\terrain\decals\env\envfieldd.dds`, followed by the `envfielddw`
section (total 469 materials, exactly these two contain "field").
**`tiles.mat` has 253 materials and none is field-related** (grass1–10, ground1, rock1–9, sand1–9,
desert1–12, `*_winter`, `test*`, `alpha0*`, `empty*`). So the brief's "tiles.mat" pointer is stale:
field art is a *decal* material, not a ground tile material.

### 1.3 Port-converted PNGs — flattened and unwired (`observed` + `derived`)

`app/assets/terrain/deco_png/envfieldd.png` and `envfielddw.png` are 512×512 RGBA but **alpha is 255 at
every pixel** — the donor alpha footprint was flattened away in conversion. Their means track the donor
opaque means almost exactly (`envfieldd` (75.6,67.5,45.2) vs donor (77.2,68.4,46.1);
`envfielddw` (115.9,110.9,97.0) vs (116.7,111.1,97.1)), confirming they are the donor stalk texture
flattened onto full opacity, not byte-identical copies (max channel diff 255, mean diff 26.7). The only
consumer is `app/tools/gen_variant_maps.py:188`, which picks `envfieldd.png` (summer) or `envfielddw.png`
(winter) for the generated preview map — no `world.gd` draw call references either file.

### 1.4 Reference images — hard gold rectangles, dense vertical stalks (`observed` + `derived`)

Crops were written to temp only: `wheat_crop_523.png`, `wheat_edge_zoom_523.png`,
`wheat_crop_village.png`. All boxes are **source-image pixels**.

| Image | Crop box (src px) | Golden fraction (HSV/R−G−B mask) | Golden mean RGB / hex | Golden HSV (H°, S, V) |
|---|---|---:|---|---|
| `523480776.jpg` (720×405) | `(200,0,720,300)` — big mill field | 46.0% | (148,118,46) = **`#94762E`** | **42.1°** (σ2.8), 0.708, 0.582 |
| `Cossacks3AttackingVillage.webp` (2355×1376) | `(1300,0,2355,600)` — largest mill field | 31.8% | (146,112,37) = **`#927025`** | **41.2°** (σ2.4), 0.755, 0.574 |

Dominant 12-step quant colours: `#906C24` (3.9%), `#9C7830` (3.8%), `#846018` (3.7%) in #2;
`#9C7824` (7.0%), `#906C18` (6.6%), `#846018` (6.1%) in #4. These sit inside the prior palette range
`#8E6F29`–`#B18A33` (`observed` means are ~2–5 RGB below the range top). Comparison grass in
`523480776.jpg` box `(0,300,200,405)`: H **62.6°**, S 0.609, V 0.276 — i.e. the field is ~20° yellower
and ~2× brighter than surrounding grass, which is what makes the boundary read as hard.

Edge geometry (`derived`, `measure_edge.py` on `523480776.jpg`): a gold-score `R−(G+B)/2` 10–90% ramp
measured perpendicular to the field's lower-left diagonal gave **1–15 px, median 6.7 px, mean 7.9 px**
across 15 rows; four clean horizontal crossings gave 1–4 px and vertical scans across the top edge gave
5–18 px. Outliers come from ragged protruding stalk tips, the mill shadow and JPEG ringing. Verdict:
the footprint is a **hard edge of order 2–8 px at 720p**, not a 20–40 px gradient. The field is a single
**rotated rectangle** (parallelogram in the isometric view) with a square dirt clearing cut out for the
mill and a second smaller field in the lower-left of `523480776.jpg` (`observed` in
`wheat_crop_523.png`).

Stalk fill (`derived`): interior box `(300,40,560,180)` of `523480776.jpg` has \|dI/dx\|=21.18 vs
\|dI/dy\|=16.23 (ratio **1.30**) and column-autocorrelation period ~3 px → **~33 stalks per 100 px**.
The high-resolution #4 crop `(1300,100,1700,450)` shows period ~2 px → ~50 stalks/100 px but ratio only
1.03 (finer detail, less regular striping at that scale). Stalks are near-vertical in screen space with
irregular golden heads — `observed` in `wheat_edge_zoom_523.png`.

---

## 2. Port gap — current `file:line`

The prior doc's `world.gd:1073-1115` crop offsets are **stale** (those lines are now terrain block
compositing); current HEAD locations are below.

| Concern | Current location | Behaviour (`observed` / `derived`) |
|---|---|---|
| Growth stage | `app/scripts/world.gd:1513-1520` `_field_growth()` | `hits/max_hits` ratio; ripe mill field = `clamp(game.sow_t/60, 0.05, 1)`. Sim numbers are reused; no donor stage texture. |
| Crop draw | `app/scripts/world.gd:1522-1550` `_draw_field()` | Procedural `draw_line` + `draw_circle`: **5+g·4 = 5–9 stalks**, `reach=3+4g`, `tall=4+10g`, `head_r=1+1.6g`; stalk `Color(0.42,0.46,0.2)` = `#6B7533` (immature `#5C8C42`), head `Color(0.88+0.08h,0.74,0.28)` ≈ `#E0BC47`, highlight `#F2D966`. Comment `:1511-1512` states no crop-stage sprite exists. |
| Field anchor | `app/scripts/world.gd:1653-1655` | `_draw_field()` is called only for a `"food"` **resource node** — each node is an isolated clump, not a field rectangle. |
| Sprite registration | `app/scripts/world.gd:270`, `:302-325` | `"field"` is in `_env_sids()` whitelist and loaded via `sprites_hi`/`sprites`, but grep finds **no draw call** using it. `sprites/field.png` is 160×160, RGB mean (2.2,2.4,0.1) — an unlit black sheaf; `tex/field.png` 512×256 mean (10.1,11.5,1.0). |
| Converted decals | `app/tools/gen_variant_maps.py:188-190` | `envfieldd.png`/`envfielddw.png` loaded for the preview map only; alpha lost in conversion (§1.3); no `world.gd` consumer. |
| Prior finding | `docs/audit/TERRAIN_PORT_DECOR.md:141` (G10), `:113-115` | Same gap recorded with old line numbers; G10 says "Crops are procedural lines; donor field decal unwired". |

Net gap (`derived`): a food node presents ≤9 green stems with bright yellow beads over grass — **no
rectangular footprint, no ~33-stalk/100px fill, no `#8E6F29`–`#B18A33` mass, and no hard field edge**.
This is why `docs/audit/RENDER.md` reads the current result as "flat yellow circles" / markers.

---

## 3. JSON spec (required deliverable)

```json
{
  "name": "field_crops",
  "size_px": [512, 512],
  "seed": 7,
  "layers": [
    {"type": "block", "name": "ground1", "tile": true},
    {"type": "sprite", "name": "field", "pos": [0.5, 0.5], "scale": 1.0}
  ],
  "reference": {
    "primary": {"image": "523480776.jpg", "box": [200, 0, 720, 300], "note": "mill wheat field, hard-edged rotated rectangle on green grass"},
    "secondary": {"image": "Cossacks3AttackingVillage.webp", "box": [1300, 0, 2355, 600], "note": "high-res field, same gold + vertical-stalk fill"},
    "donor_decal": {"summer": "data/terrain/decals/env/envfieldd.dds", "winter": "data/terrain/decals/env/envfielddw.dds", "material": "data/terrain/decals/decals.mat", "size_px": [512, 512], "alpha_bbox": [17, 19, 494, 494], "alpha_ramp_px": 12},
    "port_png": {"summer": "app/assets/terrain/deco_png/envfieldd.png", "winter": "app/assets/terrain/deco_png/envfielddw.png", "alpha": "flattened to 255", "status": "converted, unwired (preview tool only)"},
    "gold_hex": "#94762E",
    "gold_range": ["#8E6F29", "#B18A33"],
    "gold_hsv": {"h_deg": 42.1, "s": 0.708, "v": 0.582},
    "stalk_texture": {"period_px": 3, "stalks_per_100px": 33, "vertical_edge_ratio": 1.30, "donor_columns_per_100px": 12},
    "edge": {"type": "hard rectangular footprint", "width_px_10_90": [2, 8], "median_px": 6.7, "no_soft_feather_px": 20}
  }
}
```

`ground1` is the role-1 donor block cited by `game.gd` (`mines_display.md:244-245` uses the same choice);
it supplies worked soil beneath the crop. `sprite.name = "field"` is the existing but undrawn
`app/assets/models/sprites/field.png` sid; the recipe intent is that this layer becomes the decal-backed
field sprite (wired to the converted `envfieldd`/`envfielddw` stalk texture, tinted to gold), with the
procedural sticks retained only as the depleted-field fallback.

---

## 4. Measurable criteria (from a rendered 512² PNG)

| # | Criterion | Metric | Target (source-px equivalents at 720p) | How to measure from a PNG |
|---|---|---|---|---|
| 1 | **Edge gradient width** | 10–90% gold-score ramp across field→grass | **2–8 px** (median ~6.7 px); **<20 px**. Straight axis/isometric rectangle sides; no soft radial feather | Profile `R−(G+B)/2` perpendicular to one field side; count pixels between 10% and 90% of the step. Reject if >20 px or if edge is circular |
| 2 | **Gold hue** | Mean hue / saturation / value of field interior | **H 39–45°** (target 41–42°), **S 0.65–0.80**, **V 0.50–0.65**; mean hex inside `#8E6F29`–`#B18A33`; R−G≈30, G−B≈72 | HSV-convert golden mask (`R>G>B`, R−B>45), take mean H/S/V and quantized dominant hex |
| 3 | **Stalk density** | Vertical stalks per 100 px + edge anisotropy | **25–50 per 100 px** (target ~33 at 720p, ~50 at high-res); \|dI/dx\|/\|dI/dy\| ≥ 1.2 | Column high-pass autocorrelation on a field-interior box → period→100/period; ratio of mean \|Δx\| to \|Δy\| |
| 4 | **Footprint continuity** | Field pixels as one contiguous rectangle vs isolated clumps | One connected golden component per field, aspect ~1:1 in map space (incl. mill clearing hole); **0 bead/clump markers** | Flood-fill golden mask; count components and bbox aspect; visually confirm no "yellow circles" |
| 5 | **Growth/season states** | Depleted vs ripe, summer vs winter | Ripe = gold fill; depleted = bare `#4D442E`-ish stubble; winter decal = neutral `#756F61`, not gold | Sample interior mean hex for each state; check `sow_t` stage still drives growth |
| 6 | **Decal wiring** | Asset actually consumed by render path | `envfieldd`/`envfielddw` referenced from `world.gd` draw path (not only `gen_variant_maps.py:188`); alpha footprint restored or mask applied | Grep draw calls; screenshot must show rectangular footprint, not a full-tile olive square |

Global gate from prior §5: temperate-frame HSV sat 0.30–0.55 / value 0.25–0.45, but **wheat is the
saturated outlier** (`derived` S≈0.71, V≈0.58 in both references) — exclude field pixels when applying
that gate.

---

## 5. Claim table

| Claim | Evidence (source + crop) | Method | Verdict | Correction / caveat |
|---|---|---|---|---|
| Donor field art is two 512² DXT5 decals with an alpha footprint | `envfieldd.dds`, `envfielddw.dds`; temp `donor_envfield*.png` | Header read + Pillow RGBA stats | **observed** | DXT5 decoded to RGBA; alpha = decal mask |
| Decal footprint is a 477×475 near-rectangle with ~12 px side ramp | alpha bbox `(17,19,494,494)`; y=256 profile x21→33 / x487→475 | Pillow alpha threshold + 10–90% profile | **derived** | The ~12 px ramp is atlas feather, not the hard in-game field edge |
| Donor decal art is olive/brown (summer) and gray (winter), not gold | opaque mean `#4D442E` / `#756F61` | Pillow mean of a>250 pixels | **observed** | Gold colour is added at render time — **inferred** |
| Decals are registered in `decals.mat`, not `tiles.mat` | `decals.mat` offsets ~2863/~3007; `tiles.mat` 253 materials, 0 field | Byte-string scan of both .mat files | **observed** | Corrects the task-brief pointer |
| Port PNGs are donor texture flattened to full alpha | `deco_png/envfield*.png` alpha=255 means match donor opaque means | Pillow mean + array diff | **derived** | Not byte-identical (mean diff 26.7); alpha footprint lost |
| Converted PNGs are preview-only | `gen_variant_maps.py:188-190`; grep of `world.gd` | Source read + grep | **observed** | No render-path consumer |
| Reference wheat is a hard-edged rotated rectangle on grass | `523480776.jpg` `(200,0,720,300)`; `wheat_edge_zoom_523.png` | Visual crop + gold-score profile | **observed** | Mill clearing is a hole, not a soft transition |
| Edge width is ~2–8 px at 720p (median 6.7), not a gradient | 15 diagonal rows + 4 horizontal + 8 vertical scans | 10–90% gold-score ramp | **derived** | Outliers to 15–18 px from ragged stalks/shadow/JPEG |
| Field colour H≈42°, S≈0.71, V≈0.58, `#94762E`/`#927025` | both reference crops | HSV + 12-step quant histogram | **derived** | Inside prior `#8E6F29`–`#B18A33`; both images agree within 1° |
| Stalk fill ~33/100 px with vertical anisotropy 1.30 | `523480776.jpg` box `(300,40,560,180)` | Column autocorrelation + gradient ratio | **derived** | High-res #4 gives ~50/100 px, ratio 1.03 (scale-dependent) |
| Port draws 5–9 sticks/beads per food node, no rectangle | `world.gd:1522-1550`, `:1653-1655` | Source read | **observed** | Prior doc's `1073-1115` line numbers are stale |
| Port field sprite exists but is never drawn; art is unlit black | `world.gd:270`, `:302-325`; `sprites/field.png` mean (2.2,2.4,0.1) | Source read + Pillow | **observed** | `tex/field.png` also unwired |
| Gold comes from a render-time tint, not the donor decal bytes | donor means olive/gray vs reference gold | Cross-comparison | **inferred** | No donor material/shader showing the multiplier was inspected here |
| Winter field is the gray decal `envfielddw` | donor opaque `#756F61`; filename `w` | Byte data + naming | **inferred** | Season wiring itself **UNVERIFIED** in this lane |

---

All analysis artifacts (Pillow scripts, viewing crops, converted DDS previews) were written only to
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\`. No source, asset, Godot project or donor file was
modified or copied into the repository. The only repository file written is this document.

End.
