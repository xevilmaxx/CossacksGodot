# PIECES/grass_plain.md — visual truth + recipe for a plain grass piece

Research-only lane T2-PIECE-GRASS-PLAIN. No code, no Godot, no donor copies were written. All pixel numbers
below were measured with Pillow 12.1.1 in `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\` from
lossless crops of the two named reference JPEGs, from the port's `app/assets/terrain/blocks/*.png`, and by
reading the donor `grass*.dds` **in place, read-only**. Luminance is ITU-R 601-2 luma (`Image.convert("L")`:
`0.299R + 0.587G + 0.114B`), matching prior `TERRAIN_REFERENCE_IMAGES.md` §3.3/§5. Histogram = 8 bins × 32
levels. Hi-freq = mean |L − L.filter(GaussianBlur(5))|. Hue = circular mean over pixels with HSV sat > 0.12,
value > 0.1. Area estimates are visual and marked UNVERIFIED for precision.

---

## 1. Donor / reference palette table (crop evidence)

### 1.1 Reference crops (the visual target)

All hex/RGB are **mean of the named source-pixel box**; palette bins are median-cut 16-colour quantisation of
that same crop (top 6 bins by area). "Area" is share of the crop, not of the whole image (UNVERIFIED precision).

| Role | Mean hex (RGB) | Source crop (source px) | Top palette bins (area %) | Area estimate | Stats: L mean / std / hifreq / hue / sat |
|------|----------------|-------------------------|---------------------------|---------------|------------------------------------------|
| Grass — clean field, shaded-mid | `#4E5422` (78,84,34) | #2 `523480776.jpg` `(200,320,340,400)` 140×90 | `#4C531F` 8.2, `#525824` 8.1, `#4D5420` 7.8, `#505724` 7.1, `#4E5521` 7.0, `#555B27` 7.0 | ~90% of this box | 76.5 / 7.72 / 3.17 / 65.9° / 0.59 |
| Grass — clean field, sun-side | `#4E5221` (78,82,33) | #2 `(480,300,650,400)` 170×100 | `#555A26` 12.0, `#4E5522` 8.1, `#515522` 7.2, `#4B5120` 7.2, `#4A501D` 6.7, `#535525` 6.6 | ~90% of this box | 75.4 / 10.28 / 4.00 / 64.5° / 0.60 |
| Grass — field with tree shadow | `#43471D` (67,71,29) | #2 `(20,300,170,390)` 150×90 | (hist bins 0–2 only: 9.7/12.7/77.1) | ~10–25% locally, shadowed | 65.2 / 21.71 / 3.99 / 64.9° / 0.59 |
| Grass — plateau top, sunlit | `#656435` (101,100,53) | #8 `cossacks-3-v1-498085.jpg` `(390,40,530,130)` 140×90 | `#6A683E` 8.8, `#6F6E3F` 8.7, `#656731` 8.5, `#5C5E28` 8.3, `#767448` 7.5, `#61632D` 6.9 | 15–25% of grass area (prior §2) | 95.3 / 10.87 / 4.90 / 58.3° / 0.48 |
| Grass — plateau mid | `#5F6429` (95,100,41) | #8 `(560,330,650,410)` 90×80 | `#5C6225` 9.0, `#63662C` 9.0, `#666C2C` 8.0, `#60632B` 7.8, `#5F6327` 7.3, `#5F6627` 7.2 | 40–55% of grass area (prior §2) | 91.7 / 9.02 / 3.55 / 64.2° / 0.59 |
| Grass — gully shadow floor (not part of plain piece) | `#2F2C1B` (47,44,27) | #8 `(880,160,990,250)` 110×90 | (hist bins 0–1: 27.8/60.1) | <10% locally | 43.2 / 17.32 / 6.15 / 48.5° / 0.43 |

Corroboration of prior §2: our `#656435` vs prior sunlit `#6B6732`, and our `#5F6429` vs prior mid `#616727`
differ by ≤6 RGB — same olive families, different sub-boxes. Two distinct tonal families exist for *plain*
grass: a **field olive** centred `#4E5221`–`#4E5422` (L 75–77) and a **sunlit plateau olive** centred
`#5F6429`–`#656435` (L 92–95). A plain-grass piece should normally sit between them (target L ≈ 82–90).

Noise scale (mean |L(x) − L(x+d)|, sampling stride 3): reference field `d1=2.24, d2=3.22, d5=3.81,
d8=4.03, d12=4.39`; plateau mid `d1=2.90, d2=4.23, d5=5.10, d8=5.78, d12=5.89`. The monotone rise with
offset means the reference is **patch-dominated** (2–12 px mottling), with little pixel-scale grain.
CAVEAT `inferred`: the references are lossy JPEG, so their hi-freq (3.2–4.9) is a lower bound; native donor
grain will be crisper (see §1.2).

### 1.2 Donor block palette — measured from port PNGs, verified identical to donor DDS

`observed` (Pillow `ImageChops.difference`): `blocks/grass1.png` is **pixel-identical** to
`C:\Games\Cossacks 3\data\terrain\tiles\textures\grass1.dds` (bbox `None`, per-channel diff `[0,0,0]` after
RGB conversion). All ten grass PNGs matched their DDS means exactly to 1 decimal. So the table below is the
donor palette, measured through the port copies.

| Block | Mean hex (RGB) | L mean / std | hifreq | Hue / sat | Hist8 bins (%) | Match to `#4E5221` field olive |
|-------|----------------|--------------|--------|-----------|----------------|--------------------------------|
| grass1 | `#4C521E` (76,83,30) | 74.6 / 8.91 | 6.36 | 67.3° / 0.631 | 0, 10.2, 88.1, 1.7, 0… | **best overall**: ΔRGB ≈ (2,0,3), ΔL ≈ 1 |
| grass2 | `#4D5020` (77,80,32) | 73.9 / 13.14 | 9.61 | 63.9° / 0.606 | 0.2, 21.5, 72.2, 6.0, 0.1… | best ΔRGB ≈ (1,2,1); grainier |
| grass3 | `#484716` (73,71,22) | 65.9 / 15.37 | 11.63 | 58.3° / 0.707 | 0.9, 44.6, 51.1, 3.3… | too dark, too yellow |
| grass4 | `#4B4414` (75,68,20) | 64.6 / 10.24 | 7.73 | 52.5° / 0.739 | 0.1, 46.8, 52.6, 0.5… | too brown |
| grass5 | `#413E1F` (65,62,31) | 59.3 / 16.23 | 11.71 | 54.3° / 0.529 | 3.4, 59.4, 35.2, 2.0… | shadow patch only |
| grass6 | `#373019` (55,48,25) | 47.4 / 11.72 | 8.47 | 47.0° / 0.534 | 9.3, 82.0, 8.6, 0… | **too dark** (ΔL ≈ −28), brownish |
| grass7 | `#4B4D1D` (75,77,29) | 70.9 / 11.97 | 8.35 | 62.6° / 0.628 | 0.2, 26.9, 70.5, 2.4… | good tone, visible tuft/streak structure |
| grass8 | `#4A4F18` (74,79,24) | 71.3 / 15.92 | 10.39 | 66.8° / 0.695 | 0.3, 27.7, 66.1, 4.6, 1.2… | close hue, high grain |
| grass9 | `#4D4F1D` (77,79,29) | 73.0 / 15.62 | 11.88 | 62.7° / 0.634 | 0.5, 28.0, 63.1, 8.3, 0.1… | good overlay (adds 4 tonal bins) |
| grass10 | `#4C4A18` (76,74,24) | 69.1 / 13.28 | 9.59 | 58.0° / 0.690 | 0.5, 32.2, 65.0, 2.2… | slightly dark/yellow |
| grass_ground2 | `#545428` (84,84,40) | 78.8 / 20.59 | 12.38 | 59.9° / 0.554 | 0.6, 19.2, 64.5, 12.5, 2.9… | brightest, but carries pale rock/sand streaks — NOT plain grass |

Donor noise scale: grass1 `d1=7.42, d2=8.52, d5=8.81, d12=8.94` (nearly flat vs offset → white-noise grain
dominates); grass9 `d1=14.30, d5=15.05, d12=15.13`. Reference field `d1≈2.2, d12≈4.4`.

### 1.3 Verdicts on block choice

- `derived`: **grass1 is the best single donor block for clean field olive** — mean luminance within 1 level of
  `#4E5221` and hue 67° (inside the 45–75° olive gate). The port's grass1 base is **NOT too dark**.
- `derived`: grass1 is **flat in tonal distribution** (88.1% of pixels in bin 2; only 2 bins ≥3%), but so is the
  reference clean field (93.2% in bin 2). A genuinely plain piece *should* be near-flat; required tonal patches
  come from the overlay/mottling pass, not from a darker base.
- `derived`: grass1 is **grainier than the reference** (hifreq 6.36 vs 3.17–4.90; d1 7.4 vs 2.2–4.6). Part is
  JPEG smoothing of the reference (`inferred`), but `world.gd:866` deliberately lifts contrast ×1.12, which
  amplifies it. Downsample/soften the piece to final 512² and check hifreq ≤ 9.
- `derived`: **no donor grass block reaches the sunlit plateau L≈95** (brightest is grass_ground2 at L≈78.8,
  and it is not plain grass). Reproducing plateau-top brightness needs an exposure/lighting lift of roughly
  +15 to +20 luminance levels in the piece pipeline, not block selection.
- `derived`: the mandated stack `grass6 + grass9@0.3` composites to `#3D391A` (61,57,26), **L 54.7**, std 9.41,
  hifreq 6.96, bins `[0.9, 82.1, 17.0, 0…]`. That is ~21 levels below field olive and ~40 below plateau olive —
  **too dark for a plain grass piece**. Recommended correction (see §3): grass1 base, grass9 overlay 0.25–0.3,
  plus a sun lift to L ≈ 86; keep the mandated spec only as the orchestrator's contract token.

---

## 2. Port asset / code state (current file:line)

| Item | Evidence (file:line) | Observed state |
|------|----------------------|----------------|
| Block assets | `app/assets/terrain/blocks/grass1.png … grass10.png` | 10 files, each **1024×1024 RGB**; pixel-identical to donor `grass1.dds…grass10.dds` (grass1 diff bbox `None`). Port PNGs drop donor alpha (`TERRAIN_DONOR_ASSETS.md:203`) — harmless here. |
| Name→index mapping | `game.gd:988-995` `_load_terrain_structs()` loads `presets_summer.json` into `tbl_names` + `tbl_idx`; `game.gd:1121-1122` `_blk(n)` returns `tbl_idx[n]`. `presets_summer.json` order: `grass1`=0, `grass6`=5, `grass9`=8. | **There is no literal `_block_idx` symbol in the repo** (repo-wide grep: 0 hits). The task's `_block_idx` corresponds to `game.tbl_idx` / `game._blk()` / `game.tbl_names[bi]`. |
| Tileable assembly | `world.gd:713-732` `_mirror_tileable(src,size)` — resize source to `q=size/2`, blit original + flipX + flipY + flipXY into four quadrants; any wrapped crop is seamless. | Mirror-symmetric tile, quadrant period `q`. For a 512² piece, `q=256`. |
| Wrap sampling | `world.gd:734-751` `_wrap_crop(src,ox,oy,s)` modular multi-blit over the tileable image. | Offset is `posmod` into source period; deterministic. |
| Block loader | `world.gd:850-872` `_block_img(nm)` loads `blocks/<nm>.png`, converts to `FORMAT_RGB8`, `_mirror_tileable(im,1024)`, then `im.adjust_bcs(1.0, 1.12, 1.0)` (contrast ×1.12), LRU 32. | One global contrast lift, applied to **every** block including grass1; no brightness/exposure lift. |
| Base surface | `world.gd:1064` `var img := _wrap_crop(_block_img("grass1"), cx*S, cy*S, S)`; `world.gd:1068-1070` `block_at` maps tileblock index → name (`game.tbl_names`) with fallback `"grass1"`. | grass1 is the continuous base; grass6/grass9 are never used as literals in `.gd` (grep: 0 hits). |
| Multi-block compositing | `world.gd:998-1046` `_composite_blocks(...)` builds N×N alpha grids from the 2×2 cell neighbourhood, crops each named block at `coff = abs(hash(nm_s)) % 512`, and `blend_rect_mask`s it. | Established recipe for layering a named donor block at an opacity/alpha over a base — directly reusable by the piece generator (use `seed=7` for a deterministic offset instead of `hash`). |
| Prewarm | `world.gd:173-175` prewarms `grass1, grass2, ground1, test7, test8, test9, sand1, rock1, grass_ground1, test2, grass5, rock9`. | **grass6 and grass9 are not prewarmed** — a piece generator loading them cold pays a 1024² decode; trivial at bake time but note it. |
| Bake scale | `world.gd:877-880` `_bake_px()`: `mini(terrain_px*4, 64)` — 64 px per 2 m cell. | Donor grain kept at game zoom; §1.2 hifreq numbers are at native 1024². |
| Prior audits | `TERRAIN_PORT_ASSETS.md:72`, `TERRAIN_DONOR_ASSETS.md:104`, `TERRAIN_PORT_RENDER.md:63-68`, `TERRAIN_SANDBOX_PLAN.md:124` | Confirm blocks/ grass family = 10×1024², wired via preset index; older line numbers in those docs are stale relative to current `world.gd`. |

---

## 3. Spec + target histogram

### 3.1 Piece spec (as mandated by the orchestrator)

```json
{
  "name": "grass_plain",
  "size_px": [512, 512],
  "seed": 7,
  "layers": [
    {"type": "block", "name": "grass6", "tile": true},
    {"type": "block", "name": "grass9", "opacity": 0.3}
  ],
  "reference": {
    "images": ["523480776.jpg", "cossacks-3-v1-498085.jpg"],
    "crops_source_px": {"field": [200, 320, 340, 400], "plateau": [390, 40, 530, 130]},
    "hex_field": "#4E5422",
    "hex_plateau": "#656435",
    "hex_range": ["#4A501D", "#767448"],
    "luma_mean_range": [75, 95],
    "hue_deg_range": [58, 66],
    "luma_std_range": [8, 11],
    "hifreq_mean_range": [3.2, 4.9]
  }
}
```

`derived` caveat: with no further layers this stack yields **L 54.7 / `#3D391A`** (computed in §1.3), which
fails every luminance target below. To actually hit the reference, either (a) change layer 1 to `grass1`
(and keep `grass9` at 0.25–0.3: composite `#4C511E`, L 73.7, std 7.85, hifreq 5.73), then apply a sun lift
of +8 to +15 L, or (b) keep `grass6` as a *minor dark patch* (≤25% area) under a `grass1`/`grass9` base.

### 3.2 Target luminance histogram (512², 8 bins × 32 levels)

Central target **`[1, 12, 62, 22, 3, 0, 0, 0]` %**; acceptable ranges:

| Bin | Levels | Target % | Allowed % | Basis |
|-----|--------|----------|-----------|-------|
| 0 | 0–31 | 1 | 0–3 | shadow specks only |
| 1 | 32–63 | 12 | 5–20 | plateau/shadow patches (field crop 5.9, plateau 1.2–2.2) |
| 2 | 64–95 | 62 | 45–75 | dominant field olive bin (field 91.8–93.2, plateau mid 71.6) |
| 3 | 96–127 | 22 | 8–35 | sunlit plateau bin (plateau sun 52.8, plateau mid 26.5) |
| 4 | 128–159 | 3 | 0–6 | brightest flecks (plateau sun 0.2, grass_ground2 2.9) |
| 5–7 | 160–255 | 0 | ≤1 each | no bright/white content in plain grass |

Gate: **≥3 bins at ≥3%** and **≥4 readable tonal patches per 200×200** (prior §3.3/§5) — the `[1,12,62,22,3,…]`
shape satisfies both; the near-flat `[0,6,92,2,0,…]` of a single clean field does not, so the piece needs a
mottling pass that raises bins 1 and 3.

---

## 4. Measurable acceptance criteria

Measure on the final 512² piece PNG with Pillow (same helpers as §1).

| # | Criterion | Target | Pass band | How to measure |
|---|-----------|--------|-----------|----------------|
| A1 | Mean luminance | 86 | **78–95** | `ImageStat.Stat(im.convert("L")).mean[0]` |
| A2 | Luminance bins | `[1,12,62,22,3,0,0,0]` | ≥3 bins ≥3%; bin2 45–75%; bin3 8–35% | 8×32 `histogram()` |
| A3 | Luminance std | 10 | **8–14** | `ImageStat.Stat(L).stddev[0]` (field 7.7–10.3, plateau 9.0–10.9) |
| A4 | Hi-freq mean | 5 | **3–9** (hard fail >12) | mean \|L − GaussianBlur(5)\| (ref 3.2–4.9; native donor 6.4–11.9) |
| A5 | Hue | 63° | **58–68°** (global olive gate 45–75°) | circular mean HSV hue, sat>0.12, val>0.1 |
| A6 | Saturation / value | sat 0.55, val 0.35 | sat **0.45–0.65**, val **0.30–0.40** | mean of HSV over same pixels |
| A7 | Palette anchor | top quantised colour within `#4A501D`–`#656735`; ≥1 bin in `#5C5E28`–`#767448` | all top-6 bins within `#4A501D`–`#767448` | median-cut 16 quantisation, top bins by area |
| A8 | Noise scale | d1 3–7, d5 4–9, d12 5–10 | mean\|L(x)−L(x+d)\| within bands; patch scale 2–12 px | shifted-image diff at d=1,2,5,8,12 |
| A9 | Tileability | mirror seam invisible | mean \|L(x,0)−L(x,511)\| and \|L(0,y)−L(511,y)\| ≤ 1.5× interior neighbour mean | edge-profile diff |
| A10 | Dark-base guard | mean L > 70 | **fail** if the piece composites to L < 70 (catches the grass6-only result L 54.7) | same as A1 |

Priority: A1/A2/A10 first (colour/luma correctness — this is where the mandated stack fails), then A3–A7,
then A8–A9.

---

## 5. Claim table (observed / derived / inferred)

| Claim | Evidence | Method | Verdict | Caveat / correction |
|-------|----------|--------|---------|---------------------|
| Port `blocks/grass1.png` is a pixel-exact copy of donor `grass1.dds` (RGB) | `ImageChops.difference` bbox `None`, means `[0,0,0]` | Pillow pixel diff | **observed** | Alpha dropped in conversion (`TERRAIN_DONOR_ASSETS.md:203`). |
| Clean field olive = `#4E5221`–`#4E5422`, L 75–77 | #2 crops `(200,320,340,400)`, `(480,300,650,400)` | Pillow mean RGB of boxes | **derived** | ±5 RGB from JPEG artifacts; boxes exclude units/wheat. |
| Sunlit plateau olive = `#5F6429`–`#656435`, L 92–95 | #8 crops `(390,40,530,130)`, `(560,330,650,410)` | Pillow mean RGB | **derived** | Corroborates prior §2 `#6B6732`/`#616727`. |
| Reference clean grass std ≈8–11, hifreq ≈3.2–4.9 | same four crops | L-std + 5px-blur diff | **derived** | JPEG is lossy → hifreq is a lower bound. |
| Reference grain is patch-dominated (2–12 px), not white noise | d1 2.24→d12 4.39 monotone | shifted-image L-diff | **derived** | JPEG smoothing may suppress d1 specifically. |
| grass1 mean L 74.6 ≈ field olive L 75.4 — not too dark | §1.2 table + §1.3 | Pillow stats + ΔL | **derived** | grass1 hue 67.3° sits at top of olive band; fine. |
| grass1 is flat (88.1% in bin2) and grainy (hifreq 6.36, d1 7.4) | §1.2 table | hist8 + blur-diff + shifted-diff | **derived** | Reference field is also flat (93.2% bin2); grain gap partly JPEG + `world.gd:866` contrast ×1.12. |
| grass6 is the darkest grass block (L 47.4, hue 47°) | §1.2 table | Pillow stats | **observed** | Visually brown-olive in contact sheet, not a plain-grass base. |
| Mandated `grass6 + grass9@0.3` → `#3D391A`, L 54.7 | §1.3 | `Image.blend` at source resolution | **derived** | Fails A1/A2/A10; needs base swap or exposure lift. |
| `grass1 + grass9@0.3` → `#4C511E`, L 73.7 | §1.3 | `Image.blend` | **derived** | Still ~2–18 L below target; add sun lift. |
| No donor grass block reaches plateau L≈95 | §1.2 table (max grass_ground2 L 78.8) | Pillow L means | **derived** | grass_ground2 also has rock/sand streaks (visual contact sheet) → not plain grass. |
| No literal `_block_idx` function exists; index mapping is `game.tbl_idx`/`_blk`/`tbl_names` | repo-wide grep 0 hits; `game.gd:988-995,1121-1122` | source read + grep | **observed** | Task's `_block_idx` is a conceptual name; doc it as such. |
| Port has no brightness lift — only contrast ×1.12 | `world.gd:866` | source read | **observed** | Piece pipeline must supply any exposure change. |
| grass6/grass9 not in the renderer's prewarm list | `world.gd:173-175` | source read | **observed** | Cold load cost only. |
| `≥4 tonal patches per 200²` requires raising histogram bins 1 & 3 | prior §3.3 + §3.2 here | histogram reasoning | **inferred** | Single clean field is genuinely 1–2 bins; patch count depends on mottling implementation. |
| Reference JPEG hue/sat would match the native render after engine lighting | visual + stats gap between donor DDS and reference | comparison | **inferred** | Donor tiles are pre-lighting source art; on-screen grass is brighter. Confirm with an in-engine sample shot. |
| Area estimates in §1.1 are precise | visual crop estimates | — | **inferred** | UNVERIFIED; no hand-labelled mask was produced. |

---

## 6. Bottom line

1. **Palette truth:** plain grass is olive `#4E5221` (field, L≈76) to `#656435` (sunlit plateau, L≈95), hue
   58–66°, std 8–11, hifreq 3–5, patch scale 2–12 px.
2. **Best donor blocks:** grass1 for the clean field base (mean within 1 L), grass2/grass9 as tonal overlays,
   grass7 for tuft structure; grass6 is a dark shadow block and must not be the base of a plain piece.
3. **grass1 verdict:** not too dark — too flat in bins and ~2× too grainy versus the JPEG reference, and the
   port's ×1.12 contrast makes that worse. No donor block alone reaches plateau brightness; an exposure lift
   is required.
4. **Spec warning:** the mandated `grass6 + grass9@0.3` stack measures **L 54.7** and fails A1/A2/A10. Use the
   documented correction (grass1 base + grass9 0.25–0.3 + sun lift to L≈86) unless the orchestrator intends
   grass6 only as a ≤25%-area dark patch.
