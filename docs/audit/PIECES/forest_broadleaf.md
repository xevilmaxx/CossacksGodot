# PIECES/forest_broadleaf.md — visual truth + recipe for a broadleaf / mixed-forest piece

Research-only lane **T2-PIECE-FOREST-BROADLEAF**. Exactly one file written (this report). No code, no Godot run, no
donor asset copied. Hex/RGB and geometry below were measured with Pillow 12.1.1 from lossless crops written to
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\` (never into the repo), from the port's own PNG bytes read in
place, and from the donor `pattern.lib` / `generator.cfg` / `.actor` text read **read-only** in place. Every finding
is tagged `observed`, `derived` or `inferred` per `docs/audit/README.md` / `SWARM_OPS.md` §5b-QUALITY.
Prior lane anchors: `docs/audit/TERRAIN_REFERENCE_IMAGES.md` §2/§3.2/§5 (broadleaf lime `#697630`, yellow/autumn
`#6B6531`, conifer `#30331B`–`#656937`) and `docs/audit/TERRAIN_PORT_DECOR.md` §3–§5.

---

## 1. Donor evidence + crop boxes / hex

### 1.1 Reference crowns — the visual target (`observed`, Pillow)

All hexes are **mean of the named source-pixel box**; "lit" = pixels with per-pixel brightness
`(R+G+B)/3` at or above the box's 65th percentile (the sunlit crown subset), the same sampling rule used in
`TERRAIN_REFERENCE_IMAGES.md` §2/§3.2. Hue/sat/value from `colorsys.rgb_to_hsv` of the lit mean.

| Role | Lit-crown hex (RGB) | Whole-box hex | Source crop (source px) | Hue° / sat / val | Corroborates prior |
|------|--------------------|---------------|--------------------------|------------------|--------------------|
| Lime broadleaf — #7 guardians wallpaper (1916×1080) | `#6C7832` (108,120,50) | `#464D1C` (70,77,28) | `cossacks-3-guardians-of-the-highlands-pc-gioco-steam-wallpaper-3.jpg` `(215,785,395,925)` 180×140 | 70 / 0.59 / 0.47 | **yes**, Δ(3,2,2) vs `#697630` |
| Lime/olive broadleaf — #4 village (2355×1376) | `#6C6D3F` (108,109,63) | `#4E4F2A` (78,79,42) | `Cossacks3AttackingVillage.webp` `(1465,935,1600,1100)` 135×165 | 61 / 0.43 / 0.43 | mid-way between lime and yellow |
| Yellow/autumn deciduous — #8 (1280×720) | `#656038` (101,96,56) | `#484423` (72,68,35) | `cossacks-3-v1-498085.jpg` `(200,200,312,272)` 112×72 | 53 / 0.45 / 0.40 | **yes**, Δ(−6,−5,7) vs `#6B6531` |
| Conifer, shaded crown — #7 | `#51582E` (81,88,46) | `#33381A` (51,56,26) | #7 `(430,560,560,760)` 130×200 | 70 / 0.48 / 0.35 | inside `#30331B`–`#565A2E` |
| Conifer, lit tips — #8 | `#6D6739` (109,103,57) | `#5C572D` (92,87,45) | #8 `(292,286,335,344)` 43×58 | 54 / 0.48 / 0.43 | near prior lit `#656937` |

Notes (`observed`): the three broadleaf boxes are all **muted** (sat 0.43–0.59) and carry a real blue component
**B = 50–63**. This blue floor is what keeps them olive/lime rather than neon chartreuse. Conifer crowns are
darker in whole-box terms (`#33381A`, `#5C572D`), i.e. the species split is mainly **value + saturation**, not a
large hue jump (broadleaf hue 53–70° vs conifer 54–70°).

`derived`: target broadleaf family = **hue 53–70°, sat 0.43–0.59, lit B ≥ 48**, with lit crown value 0.40–0.47.

### 1.2 Morphology seen in the crops (`observed`)

- #7 bottom-left `(0,500,958,1080)` and zoom `(200,780,430,1010)`: crowns are **rounded, lobed clumps** of
  small leaf masses on a visible bare trunk; neighbouring conifers are **narrow, layered, drooping tiers**.
- #8 `(180,200,340,340)`: yellow-green clumpy crowns sit on the grass directly beside slim dark conifers —
  the "mixed forest" read is species **interleaving at tree scale**, not separate monoculture blocks.
- #4 `(900,600,1600,1100)`: one bright lime broadleaf at the bottom-right against three dark conifers — same
  contrast, higher resolution.
- `inferred`: a convincing piece needs broadleaf crowns that are roughly as wide as they are tall, with a
  serrated/clumpy edge, plus 1–2 clearly narrower conifer silhouettes and a light understory.

### 1.3 Donor forest families (read-only text evidence)

`generator.cfg` declares the families verbatim (all `Freq = 1`):
`forests_mixed_big = e_frt_big_1/2/4` (`generator.cfg:1190-1206`),
`forests_mixed_medium = e_frt_mid_1..5` (`:1207-1231`),
`forests_leaf_big = g_frt_big_1/2` (`:1232-1245`),
`forests_leaf_medium = g_frt_mid_1/2` (`:1246-1259`),
`forests_leaf_small = g_frt_small_1..6` (`:1260-1288`; the leaf `Description` fields are mojibake in the file).

Port-side mapping is already recorded in `app/assets/terrain/patterns/donor_patterns.json:1`: leaf = `g_frt_*`,
mixed = `e_frt_*`. That JSON's header states **cells are centred `(dx,dy)` donor-map-cell offsets scaled by
`map_tiles/160`** (`donor_units: 160.0`) — the conversion key for any recipe that wants donor footprints.

`pattern.lib` text sections (name → first line): `e_frt_big_1` `:209292`, `e_frt_big_2` `:218098`,
`e_frt_mid_1` `:233484`, `e_frt_mid_2` `:237082`, `e_frt_mid_3` `:239756`, `e_frt_mid_4` `:242934`,
`e_frt_mid_5` `:247344`, `e_frt_big_3` `:253938`, `e_frt_big_4` `:263724`, `g_frt_mid_1` `:317050`,
`g_frt_mid_2` `:320172`, `g_frt_big_1` `:323714`, `g_frt_small_1` `:328432`, `g_frt_small_2` `:329874`,
`g_frt_small_3` `:330280`, `g_frt_small_4` `:331190`, `g_frt_small_5` `:331820`, `g_frt_small_6` `:332898`,
`g_frt_big_2` `:333640`. Each section's `Objects` list was counted by `BaseName` (Pillow-era inline Python,
read-only); `Width`/`Height` are donor map cells.

| Donor family | Members | Avg footprint (cells) | Objects (all) | Broadleaf trees | Conifer trees | Dry trees | Broadleaf share of trees |
|--------------|---------|----------------------|---------------|-----------------|---------------|-----------|--------------------------|
| `forests_leaf_big` | `g_frt_big_1` (47×45, 167 obj, 66 broad/40 conif/10 dry), `g_frt_big_2` (39×41, 135 obj, 59/24/8) | 43×43 | 302 | 125 | 64 | 18 | **66%** |
| `forests_leaf_medium` | `g_frt_mid_1` (35×44, 44/26/0), `g_frt_mid_2` (41×34, 47/58/0) | 38×39 | 235 | 91 | 84 | 0 | **52%** |
| `forests_leaf_small` | `g_frt_small_1..6` (19–29×16–34; 5–16 broad each) | 23×25 | 177 | 70 | 45 | 10 | **61%** |
| `forests_mixed_big` | `e_frt_big_1` (69×61, 96 broad/131 conif), `e_frt_big_2` (86×92, 91/259), `e_frt_big_4` (59×70, 35/173) | 71×74 | 1159 | 222 | 563 | 32 | **28%** |
| `forests_mixed_medium` | `e_frt_mid_1..5` (39–55×43–54) | 44×48 | 723 | 214 | 272 | 27 | **44%** |

`derived` — these are **never pure broadleaf**: even the `g_frt_*` "leaf" families carry 24–58 conifers each and
10–18 dry trees in the big patterns. Total tree counts per pattern: leaf_big **91–116**, leaf_medium **70–105**,
leaf_small **10–33**, mixed_big **219–376**, mixed_medium **75–173**. Species mesh banks are explicit:
`oak.actor:1-16` (oak1–4), `burch.actor:1-24` (burch1–6), `leaftree.actor:1-16` (leaftree1–4),
`fir.actor:1-16`, `spruce.actor`, `pine.actor` — all four broadleaf/conifer banks reference `reftree.actor`.

### 1.4 Crop boxes used (all in `C:\Users\Maxym.Oboyshev\Downloads\c3\`)

`[215,785,395,925]` guardians lime · `[1465,935,1600,1100]` village lime · `[200,200,312,272]` #8 yellow ·
`[292,286,335,344]` #8 conifer · `[430,560,560,760]` guardians conifer · `[180,200,340,340]` #8 overview ·
`[900,600,1600,1100]` village overview · `[0,500,958,1080]` guardians forest-floor context.

---

## 2. Port state (current file:line, read directly)

| Item | Evidence | Observed state |
|------|----------|----------------|
| Broadleaf sprite asset | `app/assets/models/sprites_hi/tree_oak.png` (512×512 RGBA), plus `sprites/` 160² and `tex/` 1024² copies | **The only broadleaf tree PNG in `app/assets`.** No `tree_burch`, `tree_leaftree` or `tree_decortree` sprite exists (glob over `sprites_hi/*.png` → 0 hits). Donor's 4 oak + 6 birch + 4 leaftree mesh variants collapse to **1 image**. |
| Sprite bake provenance | PNG metadata of `tree_oak.png`: `cycles` 16 samples, `srgb`, `gamma 0.45455`, dated `2026/11/21` | It is a Blender Cycles rebake of the donor mesh, not a donor frame; raw values are sRGB-encoded. |
| Sprite registration | `world.gd:269-281` `_env_sids()`; `:294-335` `_load_sprites()` | Whitelist is 6 original + 87 generated variants (93). Hi-res preferred at `:319-323` and decoded directly (`:283-292`). `tree_oak` is in the base six (`:270`). |
| Resource-node tree pick | `world.gd:1345-1350` `TREE_TALL_POOL` / `TREE_SMALL_POOL` | `tree_oak` appears **once in an 11-entry tall pool**; the small pool is **all conifers** (pinesmall/firsmall). |
| Forest detail pools | `world.gd:1363-1368` | `FOREST_CONIFER_POOL` has 15 sids; **`FOREST_BROAD_POOL := ["tree_oak"]`** — one broadleaf sid. |
| Broadleaf probability | `world.gd:1410` | `pool = FOREST_BROAD_POOL if h > 0.86 else FOREST_CONIFER_POOL` → **14% broadleaf / 86% conifer** by position hash. |
| Forest detail density | `world.gd:1453-1506` `_draw_forest_detail()` | 1–3 detail trees per terrain-2 cell (`count = 1 + bucket(...,3)`), ~50% chance of one understory per cell, sparse edge singles when `hash > 0.62`. Called from `_draw_resources()` at `:1552-1556`. |
| Size buckets | `world.gd:1376` `FOREST_TREE_H := [1.6, 4.0, 6.8]` m; `:1414-1422` bucket rule | 3 apparent sizes: bucket 0–6 (70%) small, 7–8 (20%) mid, 9 (10%) large; `size_var = 0.88..1.12`; edges ×0.8. Matches prior TS-1 size buckets (15–30 / 40–60 / 70–100 px @720p) in intent. |
| Tint / orientation | `world.gd:1392-1399` `_draw_prop`, `:1425-1427` | Forest tree tint `Color(1.12, 1.2, 1.02)`, yaw ±0.13 rad, deterministic mirror, soft blob shadow at `:1423-1424` — no sway, one static frame. |
| Pattern stamps | `pattern_gen.gd:263-267` near-starts: `forests_pine_small` ×2 + `forests_mixed_medium` ×1; `:271-289` global `recipes` | Only `forests_pine_small` is stamped globally. **`forests_leaf_*` and every `*_big` family are never stamped** (P-46 comment `:274-278`). `donor_patterns.json:1` lists them, but the recipe never reaches them. |
| Ground block for the spec | `app/assets/terrain/blocks/grass_ground2.png`, `tileblocks.json:99`, `presets_summer.json:17` | Exists and is tileable. `grass_plain.md:59` notes it carries pale rock/sand streaks — acceptable as forest-floor litter, not as clean meadow. |

### 2.1 Measured `tree_oak` sprite geometry vs conifers (Pillow, `observed`)

Alpha bbox = pixels with `A>16`. "Crown aspect" = widest opaque row in the top 70% of the bbox divided by the
height spanned by rows at ≥50% of that max width. "wide_frac" = share of crown rows at ≥70% of max width — the
**clumpiness/roundness discriminator** (a round crown stays wide over many rows; a conifer tapers quickly).

| Sprite | Alpha bbox (px) | Crown max width / crown height | Aspect | wide_frac | Lit-crown hex (sRGB) | Hue / sat |
|--------|-----------------|--------------------------------|--------|-----------|----------------------|-----------|
| **`tree_oak`** | `(113,51)-(399,453)` = 286×402 | 279 / 222 | **1.26** | **0.46** | `#545503`–`#676704` (84,85,3 … 103,103,4) | 60° / **0.97** |
| `tree_fir` | `(136,67)-(376,455)` = 240×388 | 228 / 146 | 1.56 | 0.30 | `#514811`–`#695C16` | 51° / 0.79 |
| `tree_spruce1` | `(144,56)-(368,450)` = 224×394 | 224 / 144 | 1.56 | 0.24 | `#302D08`–`#605911` | 52–55° / 0.82 |
| `tree_firsmall1` | `(127,54)-(385,462)` = 258×408 | 222 / 175 | 1.27 | 0.26 | `#5A530B`–`#736B0E` | 55° / 0.88 |
| `tree_pinesmall1` | — | — | — | — | `#1C1C0A` (very dark; no lit pixels ≥62) | 60° / 0.63 |

`derived`: the oak silhouette **is** genuinely rounder than the conifers (wide_frac 0.46 vs 0.18–0.30), but its
colour is the wrong family: **B ≈ 0–4, saturation ≈ 0.97** versus the reference **B ≈ 50–63, sat 0.43–0.59**.
The in-render tint `(1.12, 1.2, 1.02)` cannot restore the missing blue. This is the single largest measurable
gap for this piece (the silhouette recipe is largely right; the palette is not).

---

## 3. Piece spec + species mix / size numbers

Mandated layer stack is preserved verbatim; the `reference` object carries the measured donor/reference numbers.

```json
{
  "name": "forest_broadleaf",
  "size_px": [512, 512],
  "seed": 7,
  "layers": [
    {"type": "block", "name": "grass_ground2", "tile": true},
    {"type": "sprite", "name": "tree_oak", "pos": [0.4, 0.5], "scale": 1.1}
  ],
  "reference": {
    "images": [
      "cossacks-3-guardians-of-the-highlands-pc-gioco-steam-wallpaper-3.jpg",
      "Cossacks3AttackingVillage.webp",
      "cossacks-3-v1-498085.jpg"
    ],
    "crops_source_px": {
      "lime_broadleaf": [215, 785, 395, 925],
      "village_broadleaf": [1465, 935, 1600, 1100],
      "yellow_deciduous": [200, 200, 312, 272],
      "conifer_dark": [430, 560, 560, 760]
    },
    "hex_lime": "#6C7832",
    "hex_yellow": "#656038",
    "hex_conifer_dark": "#51582E",
    "hex_range": ["#464D1C", "#6C6D3F"],
    "hue_deg_range": [53, 70],
    "sat_range": [0.43, 0.59],
    "lit_blue_min": 48,
    "crown_aspect_max": 1.35,
    "crown_wide_frac_min": 0.40,
    "conifer_aspect_min": 1.40,
    "conifer_wide_frac_max": 0.30,
    "species_mix_donor_broadleaf_pct": {
      "forests_leaf_big": 66,
      "forests_leaf_medium": 52,
      "forests_leaf_small": 61,
      "forests_mixed_big": 28,
      "forests_mixed_medium": 44
    },
    "broadleaf_share_port_pct": 14,
    "broadleaf_share_target_pct": [30, 50],
    "trees_per_donor_pattern": {
      "leaf_big": [91, 116],
      "leaf_medium": [70, 105],
      "leaf_small": [10, 33],
      "mixed_big": [219, 376],
      "mixed_medium": [75, 173]
    },
    "trees_per_512px_piece": {
      "gully_rim_equiv": [45, 60],
      "dense_forest_equiv": [170, 255],
      "recommended_mixed": [60, 140]
    },
    "size_px_buckets_720p": {"small": [15, 30], "medium": [40, 60], "large": [70, 100]},
    "port_height_buckets_m": [1.6, 4.0, 6.8],
    "port_broadleaf_sprite": "sprites_hi/tree_oak.png",
    "port_broadleaf_sprite_hex": "#545503",
    "port_broadleaf_sprite_sat": 0.97
  }
}
```

Recipe interpretation (`derived`): the mandated stack gives **one** `tree_oak` at `(0.4,0.5)`, scale 1.1 over a
tileable `grass_ground2` floor. That is a **token seed of the palette**, not a finished forest: donor leaf
patterns contain **10–116 trees** and the reference gully-rim/dense-forest densities rescale to **45–255 trees
per 512²**. A production piece should repeat the sprite at several positions/scales, add 1–2 conifer sids from
`FOREST_CONIFER_POOL`, and desaturate the oak toward `#6C7832` before compositing. Keep `seed=7` so all offsets
are deterministic.

---

## 4. Measurable acceptance criteria (from the final 512² PNG)

Measure on the rendered piece PNG with Pillow; all thresholds are derived from §1–§2.

| # | Criterion | Metric | Target | How to measure from a PNG |
|---|-----------|--------|--------|---------------------------|
| 1 | **Broadleaf colour family** | Mean of upper-65%-brightness pixels in a crown mask | hue **53–70°**, sat **0.43–0.59**, mean blue **≥48**, lit hex within `#656038`–`#6C7832` (±12 RGB) | Segment green components; sample each crown's top-35%-brightest opaque pixels; average; compare to §1.1 anchors. **The current `tree_oak` (B≈3, sat 0.97) FAILS this.** |
| 2 | **Crown roundness / clumpiness** | Max row width ÷ crown height, plus wide_frac | broadleaf aspect **≤1.35**, wide_frac **≥0.40**; any conifer present aspect **≥1.40**, wide_frac **≤0.30** | Alpha/luma mask per tree; compute row-width profile over the top 70% of its bbox (method of §2.1). Oak already passes (1.26 / 0.46). |
| 3 | **Species mix** | Broadleaf share of detected trees | **30–50%** broadleaf, remainder conifer (+ optional ≤5% dry) | Classify components by criterion 2; count. Port's 14% (`world.gd:1410`) is below target; donor leaf families 52–66%, mixed 28–44%. |
| 4 | **Tree count / density** | Trees in the 512² tile | **60–140** for a mixed piece; hard band **45–255** | Connected-component count of crown masks; cross-check against §3 reference densities rescaled to 512². |
| 5 | **Height variety** | Distinct crown-height buckets | **≥3** buckets with heights roughly 15–30 / 40–60 / 70–100 px at 720p-equivalent scale; largest ≈2–4× smallest | Measure each component bbox height; verify ≥3 separated modes. Port `FOREST_TREE_H` `[1.6,4.0,6.8]` m already encodes this. |
| 6 | **Mix geometry** | Nearest-neighbour species alternation | ≥1 conifer within one crown-width of ≥50% of broadleaf crowns | Dilate each broadleaf crown by its own width and test for a conifer centroid; reproduces the interleaving seen in #8/#4. |
| 7 | **Ground continuity** | Tiled floor seam + forest-floor tone | No visible seam at the mirror/crop boundary; grass hex within the prior `#3B3F1B`–`#6B6732` band | Sample a 1-px profile across the tile edge; compare block mean to `TERRAIN_REFERENCE_IMAGES.md` §2 grass/forest-floor anchors. `grass_ground2` is brightest grass block (L≈79, `grass_plain.md:59`) — acceptable under canopy. |
| 8 | **Shadow consistency** | Tree shadow direction | shadows toward **lower-left**, length ≈1–2× tree height | Prior §3.5 `observed`; **UNVERIFIED in this lane** (not re-measured). Keep for QA sign-off only. |

Global gate: piece mean HSV sat **0.30–0.55**, value **0.25–0.45** (temperate, non-winter), from `TERRAIN_REFERENCE_IMAGES.md` §5.

---

## 5. Claim table

| Claim | Evidence | Method | Verdict | Caveat / correction |
|-------|----------|--------|---------|---------------------|
| Broadleaf crowns in the references are rounded/clumpy; conifers are narrow layered tiers | #7 `(0,500,958,1080)`, #8 `(180,200,340,340)`, #4 `(900,600,1600,1100)` | Visual crop inspection | **CONFIRMED** (`observed`) | Morphology only; component-level roundness measured from sprite in §2.1 |
| Reference broadleaf = lime `#697630` / yellow `#6B6531` | §1.1 lit-crown samples `#6C7832` / `#656038` | Pillow upper-65%-brightness means | **CONFIRMED** (`derived`) | Δ ≤7 RGB; sub-box choice moves hue 53–70° |
| The port has a broadleaf sprite family comparable to donor oak/burch/leaftree | `sprites_hi/tree_oak.png` only; 0 `tree_burch`/`tree_leaftree` files; `world.gd:1368` | Glob + source read | **CONTRADICTED** | 14 donor broadleaf mesh variants → **1** sprite; `FOREST_BROAD_POOL` has one sid |
| Port forest detail mixes broadleaf at a donor-like rate | `world.gd:1410` `h > 0.86` → 14%; donor leaf 52–66%, mixed 28–44% (§1.3) | Source read + pattern.lib counts | **CONTRADICTED** | Target 30–50%; port is roughly half the *lowest* donor family |
| The port `tree_oak` colour matches the donor/reference lime-yellow | Sprite lit crown `#545503`–`#676704` (B 0–4, sat 0.97) vs reference B 50–63, sat 0.43–0.59 | Pillow sprite sampling + tint read (`world.gd:1425`) | **CONTRADICTED** | Biggest gap: too saturated, blue channel missing; `Color(1.12,1.2,1.02)` cannot fix it |
| Donor `g_frt_*` "leaf" forests are pure broadleaf | `g_frt_big_1` 40 conifers, `g_frt_big_2` 24, `g_frt_mid_2` 58 (`pattern.lib` sections §1.3) | BaseName counts | **CONTRADICTED** | They are already mixed; "mixed with conifers" is the donor truth, not a port invention |
| All donor leaf/mixed families are reachable in the port generator | `pattern_gen.gd:263-267`, `:271-289` | Source read | **CONTRADICTED** | Only `forests_pine_small` globally; `forests_mixed_medium` ×1/start; leaf families never stamped |
| Trees have three apparent size buckets in the port | `world.gd:1376` `[1.6,4.0,6.8]`, `:1414-1422` | Source read | **CONFIRMED** | Bucket split ~70/20/10%; static, no sway (`_draw_prop` `:1392-1399`) |
| The mandated `grass_ground2` block is a valid tileable forest floor | `tileblocks.json:99`, `presets_summer.json:17`, `grass_plain.md:59` | Asset + prior doc read | **CONFIRMED with caveat** | Brightest grass block and carries pale streaks — good as litter, not as clean meadow |
| Shadow direction is lower-left in this piece's references | Prior `TERRAIN_REFERENCE_IMAGES.md` §3.5 | Not re-measured this lane | **UNVERIFIED** | Carry forward from prior lane; QA to confirm on the sample render |
| `tree_oak` is 512², one frame, no rotation/animation state stored | `sprites_hi/tree_oak.png` 512×512; `world.gd:1397` transform is per-draw only | Pillow + source read | **CONFIRMED** | Yaw/mirror are hashed per draw at `:1426-1427`, not baked into the sprite |

---

## 6. Bottom line

The **silhouette recipe is mostly available**: `tree_oak` is a 512² rounded clumpy crown (aspect 1.26,
wide_frac 0.46) and the port already has three size buckets, per-tree yaw/mirror and a conifer pool. What is
**missing** for visual truth is (a) palette — the oak must be desaturated and blue-lifted from `#545503`
toward `#6C7832`/`#656038`; (b) species breadth — one broadleaf sprite versus donor oak+birch+leaftree, and a
14% broadleaf share versus donor 28–66%; and (c) count — a single seeded sprite versus 45–255 trees at 512².
The mandated JSON is kept as the orchestrator's contract token; §4 tells QA which numbers a passing PNG must hit.

**Files changed:** `docs/audit/PIECES/forest_broadleaf.md` only. No code, script, asset, screenshot, donor copy or
status document was modified.
