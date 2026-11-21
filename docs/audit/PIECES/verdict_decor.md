# T2-VERIFY-DECOR — rendered-piece acceptance verdicts

Date 2026-11-21. Verification lane over seven research specs. No Godot run, no donor asset copied into the
repo, no source/asset file modified. All probes, comparison renders and the montage live in
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\` (never in the repository). Images are the deterministic
output of `app/tools/terrain_piece_render.py` (Pillow 12.1.1, numpy 2.4.3 for the metric probes); mask-based
metrics subtract a block-only render of the same seed so sprite ink can be segmented from the ground tile.

## Owned artifacts

| Piece | Spec | Render PNG | Comparison tile | Manifest |
|---|---|---|---|---|
| forest_broadleaf | `app/tools/piece_specs/forest_broadleaf.json` | `app/shots/pieces/forest_broadleaf.png` | `forest_broadleaf_compare.png` | `forest_broadleaf.manifest.json` |
| desert_variant | `app/tools/piece_specs/desert_variant.json` | `app/shots/pieces/desert_variant.png` | `desert_variant_compare.png` | `desert_variant.manifest.json` |
| mines_display | `app/tools/piece_specs/mines_display.json` | `app/shots/pieces/mines_display.png` | `mines_display_compare.png` | `mines_display.manifest.json` |
| forest_conifer | `app/tools/piece_specs/forest_conifer.json` | `app/shots/pieces/forest_conifer.png` | `forest_conifer_compare.png` | `forest_conifer.manifest.json` |
| stones_rocks | `app/tools/piece_specs/stones_rocks.json` | `app/shots/pieces/stones_rocks.png` | `stones_rocks_compare.png` | `stones_rocks.manifest.json` |
| field_crops | `app/tools/piece_specs/field_crops.json` | `app/shots/pieces/field_crops.png` | `field_crops_compare.png` | `field_crops.manifest.json` |
| bushes_understory | `app/tools/piece_specs/bushes_understory.json` | `app/shots/pieces/bushes_understory.png` | `bushes_understory_compare.png` | `bushes_understory.manifest.json` |

All 7 PNGs + 7 `_compare.png` tiles + 7 manifests were confirmed on disk. Renderer SHA-256 prefixes:
broadleaf `00df83e365b4`, desert `9ffbfa55ab79`, mines `6085a5598262`, conifer `6cb85cc84ef8`,
stones `63c78c5c334b`, field `5c087d89f94d`, bushes `dfe7dcc0978a`.

## Schema adaptations and deviations (all deliberate, all recorded)

| Piece | Source-doc mandate | What was rendered | Why |
|---|---|---|---|
| desert_variant | sprite `rock_landstone1` | **`rock_sea1`** | Measured `rock_landstone1` lit RGB (88,93,52), G>R, hue 68°, 50% green-dominant pixels — a mossy boulder. `rock_sea1` lit (113,101,80), hue 38.8°, 0% green-dominant, nearest available R>G>B dry tone to desert light-sand `#7B7253` (123,114,83). |
| mines_display | sprite `mine_gold` | `mine_gold` with **`source: "low"`** | `mine_gold` is the *correct* sprite (doc §2.1.6/§6.2 — the port bug is drawing `rock.png`). No `sprites_hi/mine_gold.png` exists, so the renderer's `hi` fallback would resolve `sprites/` anyway; `low` makes it explicit. The baked olive disc is retained and measured (A5). |
| mines_display | no donor mine screenshot | ground/rock proxy crop `[880,130,1180,330]` of `cossacks-3-v1-498085.jpg` | Gives the renderer a labelled comparison tile. `reference.status = "UNVERIFIED"` and `reference_role` state it is **not** a mine reference; all anchors remain donor geometry. |
| forest_conifer | `scale = 1.0` means 96 px tall | renderer scale `0.1875` (= 96/512) for spruce2, `0.13125` for pinesmall1 | Renderer scales the 512 px source directly. Visible alpha ink is ~0.76× nominal (74 px / 51 px measured). |
| forest_conifer | reference crop `[150,20,638,397]` of `large_1.webp` | bottom clamped to `377` | `large_1.webp` is 788×377; the doc box ran 20 px past the image edge and the renderer rejected it. |
| stones_rocks | literal 2-sprite base recipe | **4 sprites** (adds `rock_stones6`, `rock_landstone1` per doc §3) | The base recipe cannot pass C1 (≥4 distinct silhouettes). Literal base was rendered to temp: 2 keys, 6 components → C1 fail. |
| field_crops | sprite `envfieldd`, `source: deco` | `envfieldd`, `source: deco`, **`anchor: center`** | A 512 px full-canvas decal with `foot` anchor at `[0.5,0.5]` hangs half off the top. Alpha is 255 on every pixel, so the footprint is still a full-tile olive square — the documented failure signature. |
| bushes_understory | literal 2-sprite stack; scale range `[0.55,0.95]` | **10 sprites**, renderer scales ×`0.28` (0.124–0.247) | Doc §3 itself requires `density.sprites_total = 10` for C3. Native 0.55–0.95 scales make one 57%-of-tile merged blob; ×0.28 gives separable 30–60 px clumps. Base stack rendered to temp: 2 components → C3 fail. Flower keeps 0.75× shrink. |

## forest_broadleaf — criterion | target | measured | verdict

| # | Criterion | Target | Measured from PNG | Verdict |
|---|---|---|---|---|
| 1 | Broadleaf colour family | hue 53–70°, sat 0.43–0.59, lit B ≥ 48, lit hex within `#656038`–`#6C7832` ±12 | lit (83.9, 82.6, **11.1**) = `#53520B`, hue 58.9°, sat **0.868**, V 0.329 | **FAIL** (hue only; blue missing, ~1.5× oversaturated) |
| 2 | Crown roundness / clumpiness | aspect ≤1.35, wide_frac ≥0.40 | rendered bbox (81,0)-(336,255) is clipped → aspect **2.190**, wide_frac 0.767; unclipped sprite 1.256 / 0.587 | **FAIL** (rendered clipping; sprite-level silhouette passes) |
| 3 | Species mix | 30–50% broadleaf | 1/1 detected trees = **100%** broadleaf, 0 conifer | **FAIL** |
| 4 | Tree count | 60–140 (hard 45–255) | **1** tree (area 29,792 px) | **FAIL** |
| 5 | Height variety | ≥3 separated buckets (15–30 / 40–60 / 70–100 px) | **1** bucket, height 255 px (clipped) | **FAIL** |
| 6 | Mix geometry | ≥50% of broadleaf crowns have a conifer within one crown-width | 0/1 | **FAIL** |
| 7 | Ground continuity | no visible seam; grass within `#3B3F1B`–`#6B6732` | wrap col 7.68 vs interior 5.71 (1.34×), row 5.99 vs 5.84 (1.03×); block mean (78,79,30) | **PASS** |
| 8 | Shadow consistency | lower-left, length 1–2× height | neutral dark fraction in bottom 12% of sprite = **0.000** — no shadow component | **FAIL** |
| G | Global gate | sat 0.30–0.55, val 0.25–0.45 | sat **0.670**, val 0.304 | **FAIL** |

**Verdict: 1 PASS / 7 FAIL (+ global gate FAIL).** The mandated token spec is a single clipped oak: correct
silhouette family, wrong palette and no forest density.

## desert_variant — criterion | target | measured | verdict

| # | Criterion | Target | Measured from PNG | Verdict |
|---|---|---|---|---|
| C1 | Base palette | raw mean ±8 of (123,114,83); final median R105–128 G96–118 B68–90, L100–118 | raw (122.7,113.9,82.5) ✓; rendered block (122.3,112.5,77.3) ✓; final mean (107.1,97.2,**67.9**), median (120,110,75), L **96.8** | **FAIL** (B and L marginally low because the sprite darkens the frame) |
| C2 | Hue order | R>G>B for ≥95% | **100.0%** | **PASS** |
| C3 | Tile variety | 12 unique hashes, 4 tonal families, ≥1 light + ≥1 dark family in the render | 12/12 hashes, 4 families in assets (L 79.4/81.8/100–101/110–114); ground-only dark L<90 = **0.78%** vs ≥5% | **FAIL** (dark family never wired) |
| C4 | Relief tonal spread | no L<60; patched L ≥75 and ≤118; dark patches present | ground-only L mean 111.4, std 6.1, L<90 0.78% — flat light sand, no cracked patches | **FAIL** |
| C5 | Grain / hi-freq | base 2.0–5.5, cracked 8–9, final 3–9 | base render 3.668 ✓, final **6.684** (>5.5, sprite edges inflate it), cracked-family grain absent | **FAIL** |
| C6 | Sparse scatter | exactly 1 accent, ≤3% of 512² | 1 accent ✓ but **30.91%** of frame. Temp scale-0.31 variant: 3.28% (still marginally over) | **FAIL** |
| C7 | Source faithfulness | 12/12 port PNG ≡ donor DDS RGB | **12/12** MD5 matches | **PASS** |
| C8 | Budget | ≤3 block composites | 1 block, 1 sprite | **PASS** |

**Verdict: 3 PASS / 5 FAIL.** The dry sprite correction removed the green cast (R>G>B = 100%) but the spec is
internally inconsistent: a 512 px sprite at `scale: 1.0` cannot also be ≤3% of the frame.

## mines_display — criterion | target | measured | verdict

| # | Criterion | Target | Measured from PNG | Verdict |
|---|---|---|---|---|
| A1 | Correct prop silhouette | one component, aspect 0.85–1.15, area 0.8–3.0% | bbox (189,181)-(322,256) = 133×75, aspect **1.773**, area **3.072%** (marginal) | **FAIL** (wide olive disc drives both) |
| A2 | No `test*` tiles in footprint | 0% patch-hash match | **0/188** exact 8×8 hashes (0.00%). Weak MAD<8 colour match gives 186 false positives — all role-1 dirt shares a palette; hash is the specified metric. | **PASS** |
| A3 | Ore-type colour | ≥1% of component pixels in gold band | **20.08%** in H 40–62°, S>0.15 | **PASS** |
| A4 | Ground ring / scar | annulus L lower by ≥8 vs outer | inner L 82.4 / sat 0.480, outer L 86.4 / sat 0.394 → ΔL **4.0** | **FAIL** |
| A5 | No baked green disc | olive oval bbox <25% of component bbox | olive (H65–95°, S0.25–0.7) bbox = **43.8%** of component bbox | **FAIL** (disc present) |
| A6 | Scale sanity | ≈2.4–2.5 tiles | 75 px / 32 px-per-tile = **2.34** tiles (marginal) | **FAIL** |
| A7 | Determinism | byte-identical re-render | sha256 `6085a559…` identical in both out-dirs | **PASS** |

**Verdict: 3 PASS / 4 FAIL.** A2 proves the spec's `ground1` choice eliminates `test*` in the *render*; the
four one-file fix tickets in `mines_display.md` §6 are still needed to make the *engine* do the same and to
remove the disc/wrong marker.

## forest_conifer — criterion | target | measured | verdict

| # | Criterion | Target | Measured from PNG | Verdict |
|---|---|---|---|---|
| 1 | Crown colour families | ≥2 live families with B/G 0.42–0.55, hue 58–69°, lum 46–95 | spruce lit (65,60,21) B/G **0.358** hue 52.6°; pine lit (38,39,14) B/G **0.348** hue 62.2° → **0** families meet all | **FAIL** |
| 2 | Blue-lift gate | B/G ≥0.40 | 0.358 / 0.348; dense variant 0.300 | **FAIL** |
| 3 | Tree count / density | 39–66 rim, 170–262 dense per 512² | canonical **2** trees; dense temp spec 200 layers (762/MP ✓) but only 81 merged rendered components (309/MP) | **FAIL** (canonical); dense PASS at spec-count level only |
| 4 | Size buckets | ≥3: 24–34 / 43–62 / 77–101 px | canonical 2 buckets (74, 51 px); dense 19/10/3 components + 49 outside bands | **FAIL** |
| 5 | Silhouette hierarchy | spruce H/W 1.55–2.47, pinesmall 1.19–2.21 | 30×74 = 2.47 ✓; 23×51 = 2.22 (marginal) | **PASS** |
| 6 | Shadow presence & direction | lit/shadow luma ratio ≥1.5, lower-left | foot/lit ratios **1.24** and **1.01**; near-foot neutral dark 3.45% | **FAIL** |
| 7 | Ground base | `#3B3F1B` after ×0.72–0.78 tint | block mean (78.3,78.8,29.6) — untinted, ~1.3× too bright | **FAIL** |
| 8 | Species mix | conifers ≥90% | 2/2 = 100% | **PASS** |

**Verdict: 2 PASS / 6 FAIL.** Dense variant confirms the blue deficit survives at 200 trees (B/G 0.300), so
the palette gap is a sprite-bake issue, not a density artefact.

## stones_rocks — criterion | target | measured | verdict

| # | Criterion | Target | Measured from PNG / layer assets | Verdict |
|---|---|---|---|---|
| C1 | ≥4 distinct silhouettes | ≥4 sprites with distinct 16×16 alpha signatures, Hamming ≥8 | 4/4 unique keys; pairwise Hamming 26–86. Literal base: **2** keys → fail | **PASS** |
| C2 | Shadow presence | soft bottom-18% ≥0.10 or dark bottom-18% ≥0.12 | dark bottom-18% = 0.654 / 0.285 / 0.552 / 0.298 (all ≥0.12); soft_ymax>core_ymax in 3/4 | **PASS** |
| C3 | No uniform grid | NN-centroid CV ≥0.10 with ≥3 components | 3 pebble components, CV **0.268**; layer offsets Δx 0.35 / Δy 0.10 non-repeating | **PASS** |
| C4 | Bimodal size | ≥1 boulder ≥250 px + pebble cluster ≥3 components in ≥2 classes | rendered heights 369 / 43 / 41 / 30 / 24 / 22; scaled layer heights 325, 241 (boulders) vs 130, 128 (pebbles) | **PASS** |

**Verdict: 4 PASS / 0 FAIL.** C1 only passes because the canonical spec adopted the doc's own extended field
layer list; the literal 2-layer spec fails it.

## field_crops — criterion | target | measured | verdict

| # | Criterion | Target | Measured from PNG | Verdict |
|---|---|---|---|---|
| C1 | Edge gradient width | 2–8 px (median 6.7), <20 px, rectangular | deco alpha = 255 on all pixels → full-tile fill; gold-score row256 mean 19.5, std **4.8** (grain only, no field→grass step) | **FAIL** |
| C2 | Gold hue | H 39–45°, S 0.65–0.80, V 0.50–0.65, hex in `#8E6F29`–`#B18A33` | interior H **44.9°** ✓, S **0.417**, V **0.297**, mean (75.6,67.7,45.4) = `#4B442E` | **FAIL** (hue only; olive, not gold) |
| C3 | Stalk density | 25–50 stalks/100 px, \|dI/dx\|/\|dI/dy\| ≥1.2 | FFT column period 16 px → **6.2** stalks/100 px; ratio **1.034** | **FAIL** |
| C4 | Footprint continuity | one contiguous golden rectangle, 0 clump markers | gold mask **0.89%** → no golden component; full-tile olive square instead | **FAIL** |
| C5 | Growth / season states | ripe gold, depleted stubble, winter neutral | one summer decal only; no stage/season variation renderable | **FAIL** |
| C6 | Decal wiring | no full-tile olive square | full-tile olive square present; the converted decal is preview-only in `world.gd` | **FAIL** |

**Verdict: 0 PASS / 6 FAIL.** This is the largest gap in the set. The doc's own diagnosis is reproduced
exactly: alpha was flattened in conversion and gold is a render-time tint that the port never applies.

## bushes_understory — criterion | target | measured | verdict

| # | Criterion | Target | Measured from PNG | Verdict |
|---|---|---|---|---|
| C1 | No axis-aligned rows | ≤20% of centroid pairs aligned in x or y within 10 px; max 16-px y-bin ≤30% | 0% aligned in y, 0% in x, max y-bin **0.20** | **PASS** |
| C2 | Flower pixel fraction | <2% of decor pixels and of whole tile | pink **0.010%** of decor / 0.000% of tile; bright yellow **0%** | **PASS** |
| C3 | ≥3 silhouettes | ≥3 components ≥800 px; decor ink 8–35%; largest ≤55% | **5** components (14,956 / 4,152 / 3,879 / 3,697 / 2,272 px); ink **11.05%**; largest **51.7%**. Base stack: 2 → fail | **PASS** |
| C4 | Green clump palette | ≥60% G>R and G>B; mean B ≥20; yellow <1% | green **70.6%** ✓; mean B **11.7** ✗; yellow 0% ✓ | **FAIL** (blue deficit) |
| C5 | No black backing | near-black opaque ≤2% of decor pixels | **20.8%** — fern/flower/plantain black rectangles survive the raw-alpha draw path | **FAIL** |
| C6 | Scale / silhouette variety | ≥2 height buckets, max/min ≥1.25, no duplicate aspects | heights 57/84/240, ratio **4.21**; aspects 1.34/0.54/0.81/1.04/1.05 | **PASS** |
| C7 | Never a rock fallback | ≤5% achromatic gray decor pixels | **0.00%** | **PASS** |

**Verdict: 5 PASS / 2 FAIL.** Anti-row placement and sparse blossoms are demonstrably fine; the two failures
are the sprite bake (black backing) and the same blue deficit seen in the tree sprites.

## Verdict counts

| Piece | PASS | FAIL | Notes |
|---|---:|---:|---|
| forest_broadleaf | 1 | 7 | + global gate FAIL |
| desert_variant | 3 | 5 | |
| mines_display | 3 | 4 | |
| forest_conifer | 2 | 6 | dense variant adds 1 spec-level PASS, still blue FAIL |
| stones_rocks | 4 | 0 | only with the extended field spec |
| field_crops | 0 | 6 | worst piece |
| bushes_understory | 5 | 2 | |
| **TOTAL** | **18** | **30** | 48 measured criteria; 7 comparison tiles produced |

## Ranked concrete fixes

Ranked by (visual impact × evidence confidence), cheapest/highest-confidence first.

1. **Mines — kill `test*` in the apron (doc ticket §6.1).** `app/scripts/game.gd:593` paints role `1`;
   `app/scripts/game.gd:1143-1154` maps role 1 to `test2` 37.5% / `test3` 12.5%. Paint a distinct
   `6 = mine_worked` role and add a matching branch at `game.gd:1143-1179` emitting `ground1` with zero
   `test*` names (or branch on a parallel `mine_mask`). A2 is already 0% in the render; this makes the engine
   agree. Keep `test2/3` for roads; do not edit `tileblocks.json`. **Acceptance: A2 = 0%, selftest green.**
2. **Field — wire the decal and restore its alpha + gold tint (field_crops §2, §4 C1/C6).**
   `app/scripts/world.gd:1522-1550` draws 5–9 procedural sticks; `:1653-1655` calls it only for food nodes.
   Consume `app/assets/terrain/deco_png/envfieldd.png` (currently preview-only at
   `app/tools/gen_variant_maps.py:188-190`), restore the donor `(17,19,494,494)` alpha footprint from
   `envfieldd.dds` at bake time, and apply the render-time gold tint `#94762E` (H 42.1°, S 0.708, V 0.582).
   **Acceptance: C1 2–8 px edge, C2 S/V in band, C4 rectangular golden component, C6 no olive square.**
3. **Mines — draw the mine sprite at the deposit, not a boulder (doc ticket §6.2).**
   `app/scripts/world.gd:1656-1688`, especially `:1663` `_prop_tex(["rock"], n.pos)` and `:1670`.
   Map `n.type → "mine_" + n.type`, call `_sprite_for(..., -1)` as `_draw_mine()` does at `:1931`, fold the
   sid into `_env_sids()` (`:269-281`), drop the three ore-vein circles (`:1686-1688`).
   **Acceptance: A1 aspect 0.85–1.15, A3 gold present.**
4. **Tree palette — blue-lift the rebakes (broadleaf §2.1, conifer §2.1, bushes §2.1).**
   `app/assets/models/sprites_hi/tree_oak.png` lit `#545503` (B 0–4, sat 0.97) must reach `#6C7832`
   (B 48+); conifer lit B 2–11 must reach donor B/G ≥0.40; `fern*/flower*/plantain*` mean B 11.7 must reach
   ≥20. The runtime tint `app/scripts/world.gd:1425` `Color(1.12,1.2,1.02)` cannot restore a missing blue
   channel — fix in `app/tools/render_models.py` / `app/tools/bake_sprites.py`, not in `world.gd`.
   **Acceptance: broadleaf #1, conifer #1/#2, bushes C4.**
5. **Mines — rebake without the olive disc and fix scale/jitter (doc ticket §6.3).**
   `app/tools/render_models.py` / `app/tools/bake_sprites.py` (private-use rebake, alpha-clipped background);
   `app/scripts/world.gd:143-158` set mine jitter 1.0/1.0 (donor `envscales.cfg:16-36` says `minscale =
   maxscale = 1`); `app/scripts/world.gd:1670` change `base = 3.5` to ≤3.0 (the `_draw_mine()` value at
   `:1936`). **Acceptance: A5 disc absent, A6 2.4–2.5 tiles.**
6. **Desert — wire `desert1..12` by name and add relief (desert §2/§4).**
   `app/scripts/game.gd:1124-1183` `_assign_tileblocks()` starts every land cell at `grass1` and has no
   `BIOME`/desert branch; use the existing compositor hook at `app/scripts/world.gd:998-1046` /
   `:1080` (top-3 names). Reduce the flat glaze at `app/scripts/world.gd:1141-1151` and
   `app/scripts/data.gd:191-195`. **Acceptance: C3 dark family ≥5% of pixels, C4 patched L 75–118.**
7. **Bushes — key out the opaque black backing (bushes §2.1 finding 3).**
   In the rebake step (`app/tools/render_models.py` / `bake_sprites.py`), set alpha 0 where `RGB ≤ 3` for
   `fern1..4`, `flower1..3`, `plantain1..3` (40–68% of their opaque pixels are pure black). The draw path
   `app/scripts/world.gd:651-662` uses raw PNG alpha with no keying shader (`:211-220` applies only to
   `unit_anim_layer`). Optional: rebake donor `chamomile*.osm` to recover the white `#C8CAA2` accent.
   **Acceptance: bushes C5 ≤2%.**
8. **Conifer — density, size buckets and directional shadow (conifer §2.2/§4).**
   `app/scripts/world.gd:1472-1478` emits 1–3 trees per 32×32 px tile ≈1953/MP, 2–3× donor; thin toward
   ~1/tile. `:1376` / `:1414-1422` large bucket runs 96–122 px vs donor 70–100. `:1423-1424` blob shadow
   is foot-centred, not sun-linked; add lower-left offset with luma ratio ≥1.5.
   **Acceptance: conifer #3/#4/#6.**
9. **Stones — wire the 32 dormant silhouettes and per-variant scales (stones §2).**
   `app/scripts/world.gd:1353-1355` `ROCK_POOL` exposes 10 of 42 hi-res keys; `:150-158` collapses donor
   `0.209–0.40` per-variant scales onto one `stone 0.329`. Wire more keys and use the donor scale ladder;
   keep `:1645` contact ellipse. **Acceptance: ≥4 silhouettes reachable from the runtime pool (C1).**
10. **Mines — documentation hygiene (doc ticket §6.4).** Correct `docs/audit/TERRAIN_PORT_ASSETS.md:79`
    (`test0..25` are real soil textures, misused by role, not blank UV plates). Do **not** edit
    `tileblocks.json` for this bug — it is unwired and has no mine entries.

## Honest caveats

- Four of the seven specs needed deliberate deviations to be renderable at all (desert sprite, conifer scale
  and crop, field anchor, stones/bushes density). Those deviations are recorded above, not hidden.
- `field_crops` C5 (growth/winter states) is not measurable from a single PNG; marked FAIL as "not
  renderable", not as a visual mis-measurement.
- The mines `test*` result is a property of the **spec's** `ground1` layer. The engine still selects `test*`
  via `game.gd:1144-1154`; fix ticket 1 is what closes that gap.
- The weak colour-template match for `test*` (186/188 near matches) is a false-positive artefact of all
  role-1 dirt tiles sharing a palette; the criterion specifies patch **hash**, which is 0/188.
- Sprite masks come from a seeded block-only render with identical RNG state; pixels whose composited colour
  lands within 6/255 of the ground are excluded from the ink mask (this is why the fully opaque field decal
  measures 92.21% "diff" rather than 100% — its alpha is verified 255 everywhere).

---

# V2 — re-verification with the upgraded renderer

The renderer gained `native_render`/`resample`/`grain_lift`, block `brightness`, per-layer `opacity_mask`,
`patches`, `glaze`, `face`, shore `bands`, and sprite `stretch`/`tile`/`source:"block"`. Five of the seven specs
were updated to express previously tool-limited criteria; **numeric targets were not changed**. All disclosed
adaptations (`rock_sea1` for desert, `source:"low"` for `mine_gold`, conifer 96 px scale convention and clamped
crop, stones/bushes extended field lists, field `anchor:"center"`) are preserved.

## New hashes (12-hex prefix, canonical `app/shots/pieces/<name>.png`)

| Piece | Before | After | Spec changed? | New renderer keys used |
|---|---|---|---|---|
| forest_broadleaf | `00df83e365b4` | **`f8b2f1231c8b`** | yes | `patches` (crown-gated +B), `glaze` (2% R/G lift); no `native_render` (frame sat gate) |
| desert_variant | `9ffbfa55ab79` | **`f1c674aa3716`** | yes | `brightness 1.09`, `patches` with `name:"desert2"` + binary coverage grid, `glaze` dry grade; native render trialled and **rejected** (base hi-freq 5.98–7.17 above 2.0–5.5 band) |
| mines_display | `6085a5598262` | **`6085a5598262`** | no | `opacity_mask` trialled in temp only and **rejected** — see below |
| forest_conifer | `6cb85cc84ef8` | **`7f51c09687d7`** | yes | two per-tree `patches` (G+B spruce, B pine) |
| stones_rocks | `63c78c5c334b` | **`63c78c5c334b`** | no | all four criteria already passed |
| field_crops | `5c087d89f94d` | **`5e2d4e2fa1d7`** | yes | `opacity_mask` grid from donor alpha bbox `(17,19,494,494)`, `patches` gold tint + column striping |
| bushes_understory | `dfe7dcc0978a` | **`cd72aa075e18`** | yes | `patches` with luminance-gated +B (black pixels excluded) |

All seven PNGs, comparison tiles and manifests were regenerated; mines and stones are byte-identical to v1.

## Before → after criteria

### forest_broadleaf — criterion | target | before | after | PASS/FAIL

| # | Target | Before | After | Verdict |
|---|---|---|---|---|
| 1 | hue 53–70°, sat 0.43–0.59, B≥48 | B 11, sat 0.868 → FAIL | lit (85,84,**48**), hue **57.9°**, sat **0.434** → PASS | **RESOLVED (proxy)** |
| 2 | rendered aspect ≤1.35, wide_frac ≥0.40 | 2.19 (clipped) FAIL | 2.19 (unchanged) FAIL | **FAIL** |
| 3 | 30–50% broadleaf | 100% FAIL | 100% FAIL | **FAIL** |
| 4 | 60–140 trees | 1 FAIL | 1 FAIL | **FAIL** |
| 5 | ≥3 height buckets | 1 FAIL | 1 FAIL | **FAIL** |
| 6 | conifer within one crown-width | 0/1 FAIL | 0/1 FAIL | **FAIL** |
| 7 | no seam; grass in band | seam 1.34×, ground (78,79,30) PASS | seam unchanged PASS | **PASS** |
| 8 | lower-left shadow | 0.000 FAIL | 0.000 FAIL | **FAIL** |
| G | sat 0.30–0.55, val 0.25–0.45 | 0.670 / 0.304 FAIL | **0.578** / 0.312 FAIL | **FAIL** (improved, still over) |

### desert_variant — criterion | target | before | after | PASS/FAIL

| # | Target | Before | After | Verdict |
|---|---|---|---|---|
| C1 | mean/median in light-sand band | mean (107,97,**67.9**), L 96.8 FAIL | mean (**111.9,100.3,68.2**), median (127,115,78), L **100.1** PASS | **RESOLVED** |
| C2 | R>G>B ≥95% | 100% PASS | 100% PASS | **PASS** |
| C3 | dark family ≥5%, 12 hashes, 4 families | dark 0.8% FAIL | dark **9.3%**, 12/12 hashes, 4 families PASS | **RESOLVED** |
| C4 | patched L 75–118, relief spread | no patches FAIL | L≥79 dark patches, ground L σ ~14 PASS | **RESOLVED** |
| C5 | base hi-freq 2–5.5; cracked 8–9; final 3–9 | base 3.67 ✓, cracked absent, final 6.68 FAIL | base 3.67 ✓, patched ground 7.17, final **8.99** ✓ | **RESOLVED (marginal on cracked band)** |
| C6 | sprite ≤3% of tile | 30.9% FAIL | visible alpha **15.5%** (scale still 1.0) FAIL | **FAIL** |
| C7 | 12/12 donor hash match | 12/12 PASS | 12/12 PASS | **PASS** |
| C8 | ≤3 block composites | 1 PASS | 2 (block + one patched block) PASS | **PASS** |

### mines_display / stones_rocks — unchanged

Mines A1/A4/A5/A6 still FAIL, A2/A3/A7 PASS (3/4). Stones C1–C4 all PASS (4/0).
The mines `opacity_mask` trial could not clear A5: a canvas-grid mask misses the 160 px sprite because the
renderer samples `opacity_mask` in **sprite-local** space; a corrected sprite-local mask removed the disc's
strict-H/S oval from 43.8% to ~38% of the component bbox (still above the 25% "absent" threshold), and a
tighter mask erased the sprite entirely. Rejected rather than recording a false PASS.

### forest_conifer — criterion | target | before | after | PASS/FAIL

| # | Target | Before | After | Verdict |
|---|---|---|---|---|
| 1 | ≥2 families: B/G 0.42–0.55, hue 58–69°, L 46–95 | 0 families FAIL | spruce hue **61.0°** B/G **0.477** L~66 ✓; pine hue **62.8°** B/G **0.501** L~38 (below 46) → 1 family | **FAIL (partial)** |
| 2 | B/G ≥0.40 | 0.358 / 0.348 FAIL | **0.477 / 0.501** PASS | **RESOLVED (proxy)** |
| 3 | 39–66 rim / 170–262 dense | 2 FAIL | 2 FAIL | **FAIL** |
| 4 | ≥3 size buckets | 2 FAIL | 2 FAIL | **FAIL** |
| 5 | H/W hierarchy | 2.47 / 2.22 PASS | unchanged PASS | **PASS** |
| 6 | shadow luma ratio ≥1.5 | 1.24 / 1.01 FAIL | unchanged FAIL | **FAIL** |
| 7 | ground tinted ×0.72–0.78 | (78,79,30) FAIL | unchanged FAIL | **FAIL** |
| 8 | conifers ≥90% | 100% PASS | unchanged PASS | **PASS** |

### field_crops — criterion | target | before | after | PASS/FAIL

| # | Target | Before | After | Verdict |
|---|---|---|---|---|
| C1 | hard edge 2–8 px, <20 px | no field→grass step FAIL | synthetic footprint bbox (16,15)-(496,496), hard ≤8 px ramp PASS | **RESOLVED (proxy)** |
| C2 | H 39–45°, S 0.65–0.80, V 0.50–0.65 | H 44.9°, S 0.417, V 0.297 FAIL | H **41.7°**, S **0.604**, V **0.656** PASS | **RESOLVED (proxy)** |
| C3 | 25–50 stalks/100 px **and** anisotropy ≥1.2 | 6.2/100, 1.034 FAIL | 4.3/100 FAIL; anisotropy **1.273** PASS | **FAIL** |
| C4 | one contiguous golden rectangle, 0 clumps | gold 0.9%, olive square FAIL | gold bbox **480×481** (donor 477×475) PASS | **RESOLVED (proxy)** |
| C5 | ripe/depleted/winter states | 1 state FAIL | 1 state FAIL | **FAIL** |
| C6 | no full-tile olive square | full-tile square FAIL | footprint restored in the render PASS | **RESOLVED (proxy)** |

### bushes_understory — criterion | target | before | after | PASS/FAIL

| # | Target | Before | After | Verdict |
|---|---|---|---|---|
| C1 | no axis-aligned rows | 0% / 0%, bin 0.20 PASS | unchanged PASS | **PASS** |
| C2 | flower fraction <2% | pink 0.01%, yellow 0% PASS | unchanged PASS | **PASS** |
| C3 | ≥3 silhouettes, ink 8–35%, largest ≤55% | 5 comps, 11.05%, 51.7% PASS | unchanged PASS | **PASS** |
| C4 | G>R&G>B ≥60%, mean B ≥20 | green 70.6%, B **11.7** FAIL | green **70%**, B **22.2** PASS | **RESOLVED (proxy)** |
| C5 | near-black opaque ≤2% | 20.8% FAIL | **20.8% (unchanged — deliberately not masked)** FAIL | **FAIL — genuine** |
| C6 | ≥2 height buckets, varied aspects | 57/84/240, ratio 4.21 PASS | unchanged PASS | **PASS** |
| C7 | achromatic gray ≤5% | 0% PASS | unchanged PASS | **PASS** |

## Verdict counts

| Piece | v1 PASS/FAIL | v2 PASS/FAIL | Change |
|---|---:|---:|---|
| forest_broadleaf | 1 / 7 | **2 / 6** | +1 (global gate still FAIL) |
| desert_variant | 3 / 5 | **7 / 1** | +4 |
| mines_display | 3 / 4 | 3 / 4 | — (spec unchanged) |
| forest_conifer | 2 / 6 | **3 / 5** | +1 |
| stones_rocks | 4 / 0 | 4 / 0 | — (spec unchanged) |
| field_crops | 0 / 6 | **4 / 2** | +4 |
| bushes_understory | 5 / 2 | **6 / 1** | +1 |
| **TOTAL** | **18 / 30** | **29 / 19** | **+11 PASS** |

## Former tool limitation — now resolved in the *render proxy*

1. Field decal alpha footprint (C1/C4/C6): synthesised from donor `(17,19,494,494)` via an `opacity_mask`
   grid on a `deco`-source sprite whose PNG alpha is 255 everywhere.
2. Field render-time gold tint (C2): `patches` gain with custom `olive_weights` reproduces `#94762E`-class
   H/S/V; column-striped gain raises anisotropy above 1.2 (C3 anisotropy half only).
3. Desert dark cracked family and relief (C3/C4/C5): `patches` with `name:"desert2"` and an explicit binary
   coverage grid; `brightness` 1.09 brings the frame median into the light-sand band (C1); `glaze` supplies
   the dry grade without forcing white (`white_floor:256`).
4. Sprite blue deficit (broadleaf #1, conifer #2, bushes C4): per-region `patches` blue gain, gated by a grid
   for trees and by luminance for bushes so near-black backing is **not** silently recoloured.
5. Native-grain rendering was found *not* to help desert C5 (base hi-freq left the 2–5.5 band) and was
   deliberately not adopted — a negative result, not a regression.

## Genuine port defect — still requires build work

1. **Sprite blue-lift must be fixed in ASSETS, not in the piece spec.** The `patches` proxies create visible
   rectangular tint halos (broadleaf) and do not change `tree_oak.png` lit `#545503`, conifer B 2–11, or
   `fern/flower/plantain` mean B 11.7. Fix in `app/tools/copy_assets.py` / the Blender sprite rebake chain
   (`render_models.py` / `bake_sprites.py`), then remove the proxy layers. Target files/lines:
   `app/assets/models/sprites_hi/tree_oak.png`, `tree_spruce*.png`, `tree_pinesmall*.png`, `fern*.png`,
   `flower*.png`, `plantain*.png`; runtime tint `app/scripts/world.gd:1425` cannot restore a missing channel.
2. **Field alpha and in-engine wiring.** `app/assets/terrain/deco_png/envfieldd.png` still has alpha flattened
   to 255; restore the donor alpha footprint at conversion time and wire the decal in `world.gd` draw path
   (`app/scripts/world.gd:1522-1550`, `:1653-1655`; currently preview-only at
   `app/tools/gen_variant_maps.py:188-190`). The gold tint must also be applied at render time, not by a piece
   spec. True specular/lighting is in-engine only (`pow(170)/pow(120)` highlights are out of scope here).
3. **Bushes C5 black backing** — `fern*/flower*/plantain*` opaque `(0,0,0)` pixels (40–68%) must be keyed to
   alpha 0 in the sprite rebake; `world.gd:211-220` keys only `unit_anim_layer`, so raw decor alpha keeps the
   black rectangles.
4. **Mines** — all four one-file tickets stand unchanged: `game.gd:593` + `:1143-1154` (role-1 → `test*`),
   `world.gd:1656-1688` (draw `mine_*` not `rock.png`), `render_models.py`/`bake_sprites.py` + `world.gd:143-158,1670`
   (disc, jitter, 3.5 vs 3.0), and `TERRAIN_PORT_ASSETS.md:79` doc hygiene.
5. **Density/geometry/depth** — broadleaf #2–#6, conifer #3/#4/#6/#7 and desert C6 remain genuine build work:
   `world.gd:1410` (14% broadleaf), `:1368`, `:1376`/`:1414-1422` (size buckets), `:1472-1478` (density),
   `:1423-1424` (directionless blob shadow), `game.gd:1124-1183` (desert tile names), and the field stalk-count
   gap (`world.gd:1522-1550`). `face`/`patches` are 2D proxies: no height channel, collision or buildability.

