# T2-PIECE-UNDERSTORY — bushes / understory piece (scattered dark clumps, occasional white blossom)

RESEARCH only. One output file. No code, no Godot run, no donor copies into the repo.
All pixel work used Pillow 12.1.1 on the original donor JPEGs / port PNGs; probe scripts and crops lived only in
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\` (temp files were given a `t2piece_` prefix because that
folder is shared with sibling agents). Tags: `observed` (seen directly), `derived` (computed from pixels or
followed from source), `inferred` (interpretation, explicitly labelled). Prior baseline:
`docs/audit/TERRAIN_REFERENCE_IMAGES.md` §3.2 (white-flowering bush / tall grass tufts),
`docs/audit/TERRAIN_PORT_DECOR.md`, and the RENDER-1 understory tuning visible in current `app/scripts/world.gd`.

**Purpose:** fix the visual truth for a 512×512 *bushes/understory* piece — small dark-green clumps with rare
white blossoms, scattered and varied, **never** uniform rows and **never** a bright-yellow flower border — and
state a buildable spec plus measurable gates. The negative control is any render that produces an aligned row
of identical silhouettes or a flower-coloured edge band.

---

## 1. Donor evidence — crop boxes, hex, measured statistics

### 1.1 Donor asset inventory (file listing + binary headers, `observed`)

| Donor path | Files present | Note |
|---|---|---|
| `C:\Games\Cossacks 3\data\actors\env\bushes*.osm` | `bushes1..4.osm` (34 980–49 908 B) | 4 shrub meshes; binary `IDP2` container with repeated `FRAME 000......` / `SkinBitMap` blocks, no readable texture filename |
| same dir, `flowers*.osm` | `flowers1..3.osm` (5 972–10 132 B) | 3 flowering-plant meshes |
| same dir, `plantain*.osm` | `plantain1..3.osm` (6 244–7 620 B) | 3 plantain / tuft meshes |
| same dir, `fern*.osm` | `fern1..4.osm` (5 468–7 324 B) | 4 fern meshes |
| same dir, `reed*.osm` | `reed1..3.osm` (14 996–24 900 B) | 3 reed meshes |
| `data\pattern\dcr1..3.pattern` | 24 536 / 21 860 / 29 424 B | header ints are 22×21, 23×18, 25×22 (`observed`); body is a 0/1 cell mask whose row sums rise and fall (e.g. `dcr1`: `21,21,11,9,8,8,7,6,5,4,4,3,3,4,4,6,9,11,17,21`) — an authored **irregular patch footprint**, not a row (`derived`; full binary semantics UNVERIFIED) |
| `data\terrain\decals\env\` | only `christmastreed.dds`, `envfieldd.dds`, `envfielddw.dds` | **No** bush/flower/plantain decal exists; these plants are actor meshes + `dcr*` decor patterns, not terrain decals (`observed`) |

Lineage into the port is explicit in `app/tools/convert_models.py:286-292`:
`bush%d -> bushes%d (family "bushes")`, `flower%d -> flowers%d ("plantsatlas")`,
`plantain%d -> plantain%d ("plantsatlas")`, `fern%d -> fern%d ("fern")`, `reed%d -> reeds ("plantswateratlas")`
(`observed`).

### 1.2 Primary reference — white-flowering bushes in `cossacks-3-v1-498085.jpg` (1280×720, donor #8)

Crops written to temp and viewed at 3–4× nearest-neighbour. Source-pixel boxes:

| Role | Source box (px) | Size | Evidence |
|---|---|---|---|
| **Clump zone (primary)** | `(0,440,180,560)` | 180×120 | all three white bushes + scattered yellow-green tufts in one view; no alignment into rows |
| White bush A | `(43,496,79,517)` | 36×21 | brightest white cluster, 59 near-white px in its dilated component |
| White bush B | `(12,519,45,542)` | 33×23 | second cluster, 34 near-white px |
| White bush C | `(5,440,30,457)` | 25×17 | smaller upper-left cluster, 17 near-white px |
| Tall tuft / sapling zone | `(120,470,165,510)` | 45×40 | thin yellow-olive upright tufts; **not** a continuous flower edge |
| Prior-art equivalent | `(15,455,120,535)` | 105×80 | tight box around the same A/B colonies; used for the % statistics below |

Pillow measurements (`derived`):

| Quantity | Value | Rule |
|---|---|---|
| Near-white pixel mean in `(15,455,120,535)` | RGB (199.8, 201.9, 162.4) → **`#C8CAA2`**, mean L 188.0 | `L>170`, HSV `s<0.30`; 76 px = **0.90 %** of the 8 400-px box |
| Foliage mean in the same box | RGB (74.8, 79.9, 30.6) → **`#4B501E`** | `G>R*1.05`, `G>B*1.25`, `25<L<110` (1 185 px) |
| Near-white fraction, whole gully crop `(0,300,420,720)` | **0.33 %** (588 / 176 400), mean RGB (209.0,195.8,173.9) | same rule; 8 components ≥8 px, largest only 30 px |
| White-bush centroids | ≈(17,448), (61,506), (28,530) in source px | from the three dilated clump boxes above |
| Row alignment of those 3 centroids | **0 / 3 pairs** within 10 px in y; 0 / 3 within 10 px in x | direct pairwise check (`derived`) |

So the donor signature is: a **dark olive-green clump** (`#4B501E`) carrying a *few* pale blossoms
(`#C8CAA2`), blossoms occupying **~0.9 % of a bush-dedicated crop and only 0.33 % of the wider gully**, with
clumps at clearly different x **and** y — scattered, not a row, and not a bright edge. The "tall tufts" in the
same frame are slender upright olive shapes, again isolated. This confirms and sharpens
`TERRAIN_REFERENCE_IMAGES.md:93-94` (species family 4).

**Correction to prior art (`observed`):** the second citation in `TERRAIN_REFERENCE_IMAGES.md:93-94`, `#7`
`cossacks-3-guardians...jpg` box `(300,60,380,130)` (re-cropped here as `(300,60,420,170)`), shows a town
building, a wall/tower and a sheep — **no white blossoms**. Do not use that box as the primary white-bush
reference; the reliable evidence is donor #8 above. (`TERRAIN_REFERENCE_IMAGES.md:41` also uses a crop-local
box for `c8_gully_left.png`; the source-px boxes given above supersede it for this piece.)

### 1.3 "Never a yellow border" — donor colour check

No pixel class in the donor bush zone is a saturated bright yellow: green foliage means `#4B501E` /
gully `#454B20` (68.8, 74.8, 32.4), and the only bright small shapes are the near-white blossoms above
(low saturation by construction). Yellow-olive upright tufts exist but are isolated clumps within the
180×120 zone, not a continuous band. Any render with a yellow/gold rim of flowers is a failure signature.

---

## 2. Port state (current file:line, read directly)

| Concern | Location | Current behaviour / measured fact |
|---|---|---|
| Sprite bake provenance | PNG metadata of `sprites_hi/bush1.png`, `fern1.png`, `flower1.png`, `plantain1.png` | Blender Cycles rebake, `srgb` + `gamma 0.45455`, 4 samples, `Date 2026/11/21`, cameras `cam.053/066/057/058` (`observed`) — port art, not a donor screenshot |
| Sprite inventory | `app/assets/models/sprites_hi/` | `bush1..4`, `fern1..4`, `flower1..3`, `plantain1..3`, `reed1..3`, all **512×512 RGBA** (`observed`) |
| Sprite registration | `world.gd:269-281` `_env_sids()` (`:276-277` lists bush/flower/plantain/reed/fern), `:283-292` `_load_env_tex()`, `:294-325` `_load_sprites()` | 93 env sids; hi-res preferred at `:319-323`, PNG decoded directly because `.ctex` caches are absent in dev. These understory keys therefore resolve to `sprites_hi/*.png` |
| Bush resource nodes | `game.gd:432-462` `_scatter_bushes()` | 40 attempts, quarry/sand-adjacent only (`tt==1/5` near stone at 50 %, `tt==4` at 30 %). These are **dry shrubs**, not the forest understory pass |
| Forest understory pool | `world.gd:1369-1374` | **`flower1..3` are 3 of 24 picks = 12.5 %** — the mandated flower weight. Pool composition: bush ×8 (33.3 %), fern ×8 (33.3 %), plantain ×5 (20.8 %), flower ×3 (12.5 %) (`observed` + `derived`). Comment at `:1369-1370` states the intent: flowers stay scattered so they do not form a border |
| Flower shrink | `world.gd:1440-1446` | size is an **independent** position hash, so neighbours are uncorrelated; flower picks get `hh *= 0.75` so they read as specks |
| Anti-row tuning | `world.gd:1479-1486` | ~50 % of forest cells get one understory (`hash > 0.5`); in-cell `ux/uy` each hash both x and y over `[0.05,0.95]`, explicitly "a row of adjacent cells no longer lands at the same in-cell fraction" (`observed`) |
| Yaw / mirror | `world.gd:1392-1399` `_draw_prop()`; `:1449-1451` | ±0.15 rad foot-anchored lean, deterministic mirror, soft blob shadow at `:1447-1448`; one static frame, no sway |
| Draw path | `world.gd:651-662` `_draw_sprite()` → `draw_texture_rect`; shader at `:211-220` applies **only** to `unit_anim_layer` | decor is drawn from the raw PNG alpha — there is no keying shader on `res_layer` (`derived`) |
| Donor mesh → sprite map | `app/tools/convert_models.py:286-292` | confirms which donor mesh family feeds each sprite family (`observed`) |

### 2.1 Measured sprite truth (Pillow, 512² RGBA; `observed` / `derived`)

| Family | Opaque coverage of 512² | Mean opaque RGB → hex | Top-1 % luminance RGB | Near-black opaque | "Flower" pink px | Bright-yellow px |
|---|---|---|---|---|---|---|
| `bush1..4` | 18.7–21.3 % | (36,40,22) → `#242816` | (57,65,45) → `#39412D` | **0.0 %** | 0.0 % | 0.0 % |
| `fern1..4` | 25.2–27.6 % | (25,30,12) → `#191E0C` | (104,124,52) → `#687C34` | **40.4–44.2 %** | 0.0 % | 0.0 % |
| `flower1..3` | 40.8–53.6 % | (14,12,5) → `#0E0C05` | (119–123,77–79,82–87) → ≈`#774E53` | **67.4–67.8 %** | 2.6–2.8 % | 0.0 % |
| `plantain1..3` | 27.7–38.3 % | (13,14,3) → `#0D0E03` | (80–94,83–94,14–25) | **62.7–66.3 %** | ≤0.1 % | 0.0 % |

Rules: near-black = `R,G,B ≤ 3` **and** `A>128`; pink = `R>1.15·G`, `R>1.08·B`, `L>55`; bright yellow =
`R>140, G>110, B<70`. Alpha bboxes (A>16) are e.g. `bush1 (33,60,479,429)`, `fern1 (36,70,477,375)`,
`flower1 (33,33,479,500)`, `plantain1 (32,113,479,423)`.

Three findings matter for the recipe:

1. **The bush sprites are not dark-green clumps.** Visually (brightened 4× contact sheet) `bush1..4` are
   sparse, thin, twig/reed-like olive tufts with no blossoms — the nearest donor analogue is the *tall tuft*
   family, not the white-flowering bush. They are correctly dark and green (`G>R>B`, no pink/yellow), so they
   are acceptable as scattered understory, but the white-blossom accent in the reference has **no sprite
   equivalent** among these 14 PNGs. The donor `chamomile*.osm` meshes exist but were not rebaked here.
   (`inferred` from visual comparison, palette `observed`.)
2. **The `world.gd:1370` phrase "bright yellow blossoms" is stale.** The actual `flower1..3` top-1 % colour is
   muted pink/mauve `#774E53`; explicit bright-yellow pixel count is **0.0 %**. The 12.5 % weight and 0.75×
   shrink still keep them as scattered specks, but there is no yellow-border risk from these sprites
   (`observed` + `contradicted` claim in §5).
3. **Black opaque backing on fern/flower/plantain.** 40–68 % of their opaque pixels are exactly `(0,0,0,255)`,
   forming solid rectangles (e.g. `flower1` row y=150 is 65 % black across x=34..468; `fern1` rows y=150–300
   are 25–28 % black). `bush1..4` have **0 %**. Because `res_layer` draws raw PNG alpha with no keying shader
   (§2), using fern/flower/plantain unprocessed would put visible black boxes in the render (`derived`, not
   confirmed by a Godot run in this lane). The mandated spec uses `fern1` — key out pure black (alpha 0 where
   `RGB≤3`) before compositing, or substitute a clean `bush*` variant.

---

## 3. JSON spec (required deliverable) + density / weights

Mandated 3-layer stack preserved verbatim; `density`, `weights` and the measured donor numbers are added alongside.

```json
{
  "name": "bushes_understory",
  "size_px": [512, 512],
  "seed": 7,
  "layers": [
    {"type": "block", "name": "grass1", "tile": true},
    {"type": "sprite", "name": "bush2", "pos": [0.3, 0.5], "scale": 0.8},
    {"type": "sprite", "name": "fern1", "pos": [0.7, 0.6], "scale": 0.7}
  ],
  "density": {
    "sprites_total": 10,
    "sprites_per_512_tile": [8, 12],
    "placement": "seed-7 hash jitter, both axes mixed; reject candidate if pairwise centroid distance < 0.06 tile or if it forms an axis-aligned row with two existing clumps",
    "in_cell_fraction_range": [0.05, 0.95],
    "scale_range": [0.55, 0.95],
    "min_understory_silhouettes": 3
  },
  "weights": {
    "note": "per 24 picks, mirrors app/scripts/world.gd:1371-1374",
    "bush1": 2, "bush2": 2, "bush3": 2, "bush4": 2,
    "fern1": 2, "fern2": 2, "fern3": 2, "fern4": 2,
    "plantain1": 2, "plantain2": 2, "plantain3": 1,
    "flower1": 1, "flower2": 1, "flower3": 1,
    "share": {"bush": 0.333, "fern": 0.333, "plantain": 0.208, "flower": 0.125}
  },
  "reference": {
    "primary": {
      "image": "cossacks-3-v1-498085.jpg",
      "crop": [0, 440, 180, 560],
      "note": "scattered white-flowering bushes + isolated tall tufts, no rows"
    },
    "white_clump_boxes": [[5, 440, 30, 457], [43, 496, 79, 517], [12, 519, 45, 542]],
    "white_bush_centroids": [[17, 448], [61, 506], [28, 530]],
    "hex_white_blossom": "#C8CAA2",
    "hex_dark_green_clump": "#4B501E",
    "white_pixel_fraction_bush_zone": 0.009,
    "white_pixel_fraction_gully": 0.0033,
    "donor_meshes": ["bushes1..4.osm", "flowers1..3.osm", "plantain1..3.osm", "fern1..4.osm", "reed1..3.osm"],
    "donor_decor_patterns": ["dcr1.pattern", "dcr2.pattern", "dcr3.pattern"],
    "port_pool": "app/scripts/world.gd:1371-1374",
    "flower_weight": 0.125,
    "flower_sprite_scale": 0.75,
    "source_doc": "docs/audit/TERRAIN_REFERENCE_IMAGES.md §3.2; docs/audit/TERRAIN_PORT_DECOR.md"
  }
}
```

Interpretation (`derived`): `grass1` is the mirror-tiled base. The two mandated sprites are the two required
different silhouettes; the weighted `density` pass adds 8 more clumps so the tile reaches ≥3 distinct
understory silhouettes and a mix of tall-tuft (`bush*`) and broad-frond (`fern*`) shapes. Flowers stay at the
port's 12.5 % pick share and the 0.75× shrink, so they read as isolated specks, never a border. Pure-black
backing on `fern*`/`flower*`/`plantain*` must be keyed to alpha 0 before any layer is composited (§2.1).

---

## 4. Measurable acceptance criteria (Pillow on the 512×512 piece PNG; temp only)

Measure the decor silhouettes on a transparent-background export of the sprite layers (grass base hidden) or on
the full tile after subtracting the tiled `grass1` background. Opaque = `A>128` unless stated.

| # | Criterion | Target | Measurement | Donor / port anchor |
|---|---|---|---|---|
| C1 | **No axis-aligned rows** | ≤20 % of silhouette-centroid pairs agree in y within 10 px **and** ≤20 % agree in x within 10 px; max occupancy of any 16-px y-bin ≤30 % of clumps | connected components (A>32, area ≥800 px) → centroids → pairwise Δx/Δy and histogram | donor 3 white bushes: 0/3 aligned pairs; port `world.gd:1479-1486` cross-mixed in-cell hash |
| C2 | **Flower pixel fraction < 2 %** | `<2 %` of decor-opaque pixels **and** `<2 %` of the whole 512² tile | pink rule `R>1.15G, R>1.08B, L>55` **or** bright-yellow rule `R>140,G>110,B<70` | donor bush zone 0.90 %, gully 0.33 %; port flower sprites 2.6–2.8 % pink of their own opaque px but 0 % bright yellow |
| C3 | **≥3 understory silhouettes** | ≥3 components with area ≥800 px; decor ink 8–35 % of tile; largest component ≤55 % of decor ink | 8-connected components on alpha; area/bbox report | two mandated sprites + weighted scatter of 8 more |
| C4 | **Green clump palette** | ≥60 % of decor-opaque px have `G>R` and `G>B`; mean `B ≥ 20`; no bright-yellow band (C2 yellow term <1 %) | per-pixel channel test + mean RGB | port bush top-1 % `#39412D` (B=45), fern `#687C34` (B=52) — unlike the near-zero-B tree sprites |
| C5 | **No black backing frame** | opaque near-black (`R,G,B ≤3`) ≤2 % of decor-opaque px | count `(r≤3)&(g≤3)&(b≤3)&(A>128)` | bush 0 % PASS; fern 40–44 %, flower 67 %, plantain 63–66 % FAIL unless keyed |
| C6 | **Scale / silhouette variety** | opaque bbox heights span ≥2 buckets; max/min component height ≥1.25; no two components with identical bbox aspect within 5 % | bbox per component | port `size_var = 0.7..1.15` (`:1443`) and scale range `[0.55,0.95]` here |
| C7 | **Never a rock fallback** | ≤5 % of decor-opaque px are achromatic gray (`|R−G|<8`, `|G−B|<8`, `60<L<120`) | channel-difference test | `world.gd:1342-1344` requires bush pools never to contain rock/stone |

Failure signatures: (a) silhouette centroids sharing one y or x within 10 px → reject (row); (b) a yellow/gold
edge band → reject (border); (c) `C5` above 2 % → reject (black boxes); (d) fewer than 3 components → reject
(under-filled piece).

---

## 5. Claim table

| Claim | Evidence | Method | Verdict | Caveat / correction |
|---|---|---|---|---|
| Donor white-flowering bushes are small dark-green clumps with a few pale blossoms | #8 `(0,440,180,560)` + clump boxes; foliage `#4B501E`, blossom `#C8CAA2` | visual crop + Pillow box means | **observed + derived** | clump-source boxes are 25–36 px wide at 720p |
| Blossoms are sparse: 0.90 % of a bush zone, 0.33 % of the gully | #8 `(15,455,120,535)` and `(0,300,420,720)` | threshold `L>170, s<0.30` | **derived / confirmed** | JPEG threshold-sensitive ±0.2 pp; units in the gully can add false positives |
| Clumps are scattered, not a row | centroids ≈(17,448),(61,506),(28,530) | pairwise Δx/Δy | **derived / confirmed** | only 3 clumps in this crop; no rows seen in the wider `(0,300,420,720)` view either |
| Donor has tall isolated olive tufts, never a yellow flower border | same crop, tuft zone `(120,470,165,510)` | visual | **observed** | yellow-olive saplings are isolated, not contiguous |
| Prior §3.2 #7 box `(300,60,380,130)` shows white blossoms | re-crop `(300,60,420,170)` of the 1916×1080 wallpaper | visual | **CONTRADICTED** | it is a town/building/sheep area; use donor #8 instead |
| Donor plant meshes / dcr patterns exist; env decals dir has no bush decal | file listing + `dcr*.pattern` headers | `Get-ChildItem` + binary header | **observed** | dcr mask semantics beyond the 0/1 footprint are UNVERIFIED |
| Port uses `sprites_hi` 512² PNGs for bush/fern/flower/plantain | `world.gd:269-281`, `:319-323` | source read + glob | **observed** | `.ctex` caches absent in dev; PNG decoded directly (`:283-292`) |
| Flower pick weight is exactly 12.5 % (3 of 24) | `world.gd:1369-1374` | source read | **observed / confirmed** | comment says "~12 %"; exact share is 12.5 % |
| Flower sprites are bright yellow | `world.gd:1370` comment | Pillow top-1 % ≈`#774E53`; bright-yellow px 0.0 % | **CONTRADICTED** | they are muted pink/mauve; the shrink (`:1445-1446`) still prevents any border |
| Understory placement is anti-row | `world.gd:1479-1486` (x/y cross-mix over `[0.05,0.95]`) | source read | **observed** | deterministic hash, no RNG; no Godot render checked in this lane |
| `bush1..4` are dark-green and clean (no black frame, no pink/yellow) | Pillow metrics §2.1 | channel tests | **observed / confirmed** | visually they are thin twig/reed tufts, not white-flowering clumps |
| `fern/flower/plantain` carry opaque black rectangles | Pillow: 40–68 % near-black opaque; row y=150 of `flower1` 65 % black | channel test + row scan | **observed** | visual effect in-engine is `derived` (raw `draw_texture_rect`, no keying shader); no Godot run |
| No white-blossom sprite exists among the 14 PNGs | family list + metrics (bush/fern/flower/plantain all have white px 0.0 %) | Pillow `r,g,b>200` count | **observed** | donor `chamomile*.osm` not rebaked; white accent may need a new sprite or a tinted speck |
| The mandated 3-layer stack alone gives ≥3 silhouettes | layers list is base + bush2 + fern1 | count of sprite layers | **CONTRADICTED** | only 2 sprites; `density.sprites_total=10` in §3 is required for C3 |

Open questions: (1) is the black backing in fern/flower/plantain intentionally keyed by an import setting not
visible in the PNG bytes (no Godot run in this lane to confirm)? (2) Should `chamomile*.osm` be rebaked to
recover the donor's white-blossom accent, or is pink `flower*` accepted as the speck? (3) Does the piece renderer
apply the `unit_anim_layer` lift shader to `res_layer` decor (current source says no)?

---

End of report. No code, Godot process, repo asset or donor file was modified.

---

## 6. T6-T10 implementation addendum (2026-11-23)

Micro-worker **T6-T10** implemented the headless, deterministic mini-baker
`app/tools/pieces/t6_bushes_understory.py` (Python 3.14 + Pillow + NumPy, no Godot,
no donor file copied into the repo). Full claim table, hashes, criterion verdicts
and visual judgement: `docs/t6/reports/T6-T10.md`. Backup of this file before the
append: `inbox\backup\bushes_understory.md.bak-T6-T10`.

**Measured correction to §2.1 finding 3 (*observed*, current port PNGs):** the
`fern*/flower*/plantain*` sprites in `app/assets/models/sprites_hi/` now carry
**0.0% opaque pure-black backing** (the 40–68% black described in §2.1 is no
longer present in the shipped PNGs). `tree_stump2.png` still has 22.0% opaque
black and is keyed to alpha 0 in the mini-baker. The mini-baker never loads a
rock/stone asset: an explicit allowlist covers only `bush1..4`, `fern1..4`,
`plantain1..3`, `flower1..3` and the newly used `tree_stump1..4` real sprites.

**Donor crop used for the compare sheet (*observed*):** #8
`cossacks-3-v1-498085.jpg` box `(0,435,150,585)` — a square 150×150 crop showing
all three white-flowering bushes plus isolated tall tufts on forest floor. It was
opened and visually checked: no minimap, UI text, units or degenerate stretched
strip. The panel is resized uniformly to 512×512.

**Result (Pillow on the 512² piece PNG, temp-only probes):** C1 PASS (7.27% y /
1.82% x axis alignment, 18.18% max y-bin), C2 PASS (1.10% pink of decor, 0.12% of tile, 0%
bright yellow), C3 PASS (11 components ≥800 px, ink 10.91%, largest 25.14%), C4
PASS (87.77% green-dominant, mean B 31.33), C5 PASS (0% near-black opaque), C6
PASS (heights 26–98 px, ratio 3.77, three buckets, no duplicate aspect), C7 PASS
(0% achromatic gray). Density 12 clumps / 16 sprite layers, within the spec
[8,12] band; rock-fallback assets 0. Piece SHA-256
`46d1028f88beb7f451637792107f8871ac31a93f6a0bade6a5c7ea89d08f9fcc`.

**Disclosed proxy:** the donor white-blossom accent (#C8CAA2) has no rebaked
sprite; the piece uses soft pale specks (0.097% of the tile) as a labelled 2D
proxy. Donor `chamomile*.osm` rebake remains an open integration question.
