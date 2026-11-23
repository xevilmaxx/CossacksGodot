# Stones / Rocks scatter piece — visual truth + recipe

Scope: research only. No Godot code, no donor binary and no generated PNG was
written into the project. All Pillow work lived in
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\` (throwaway scripts and
crops). Labels follow the audit convention: **observed** = read from bytes /
pixels / source, **derived** = computed from observed values, **inferred** =
visual judgement.

Prior context: `docs/audit/TERRAIN_PORT_DECOR.md` §3 recorded only the two
160×160 `rock`/`stone` sprites; `docs/audit/TERRAIN_DONOR_PATTERNS.md` T2/T6
called for converting `stones*`, `smallstones*`, `landstone*`, `rocksea*` and
for ≥4 distinct rock silhouettes in one screenshot. Both are now partly
satisfied in assets (§2).

---

## 1. Donor evidence (reference images + donor files)

### 1.1 Reference crop boxes

Both reference images were opened with Pillow at full resolution, downscaled
for an overview, then re-cropped. Coordinates below are **original-image
pixels, (left, top, right, bottom)**. Crops were viewed, not just measured.

| ID | Image (original size) | Crop box (px) | What the crop shows | Tag |
|---|---|---|---|---|
| R1 | `Cossacks3AttackingVillage.webp` (2355×1376) | `(899,385,1670,899)` | Central dirt clearing; hundreds of small grey stone chips scattered between units and houses. Irregular clumps, no rows. | observed |
| R1a | same | `(899,385,1149,540)` (2× view) | Tight pebble field: individual chips are ragged, ~1.5–4 px across at donor zoom, light-grey top face with a dark lower-left contact shadow. Mixed sizes within one patch. | observed (visual) |
| R1b | same | `(1230,560,1480,760)` (2× view) | Pebbles thin out near the building; density gradient, bare ground gaps between clusters. | observed (visual) |
| R2 | same | `(500,700,1300,1120)` | Lower-left clearing: same pebble scatter continuing under the houses; confirms scatter is a ground-layer treatment, not an object-only prop. | observed |
| R3 | `cossacks-3-v1-498085.jpg` (1280×720) | `(880,130,1180,330)` | Striated grey cliff face — vertical folds, dark recesses; the large-rock end of the reference spectrum. | observed (visual) |
| R4 | same | `(300,330,700,600)` | Cliff bases against grass; rock meets ground with a soft dark contact band, not a hard cut. | observed (visual) |

### 1.2 Visual truth for the piece

- **Ground pebbles** (R1/R1a/R2): small, irregular, angular chips, several size
  classes inside one patch, grey-brown and desaturated; each chip carries a tiny
  dark contact shadow to its lower-left. Distribution is **clumped with bare
  gaps**, not a lattice. **observed** (pixels), density gradient **inferred**.
- **Large rocks** (R3/R4): single boulder / outcrop silhouettes with faceted
  tops and a dark base where they seat into the ground. Vertical striation is a
  cliff-texture feature, not present on the scatter boulders. **observed**.
- Two scales are required in one piece: a sparse field of pebble chips plus one
  or two larger boulders. **inferred** from R1 vs R3 co-occurring in the game's
  ground presentation.

### 1.3 Donor files (read-only)

| Donor path | Observed content | Tag |
|---|---|---|
| `C:\Games\Cossacks 3\data\actors\env\stones.actor`, `stones1.osm` … `stones10.osm` | 10 land-stone actor meshes; `stones1.osm` is 9,500 B, header bytes `49 44 50 32` = `IDP2` (binary container, not text). | observed |
| `…\env\stonessea.actor`, `stonessea1.osm` … `stonessea10.osm` | 10 sea-stone meshes, 3,308–11,764 B. | observed |
| `…\env\smallstones*.osm` (incl. `smallstones.1` … `.6`) | 6 small-pebble cluster meshes. | observed |
| `…\env\landstone*`, `…\env\rocksea*` | Land-moss and sea-rock mesh families; converted sprites exist in the port (§2), donor actor files are the source. | observed (file presence) |
| `C:\Games\Cossacks 3\data\pattern\d_stn_1.pattern` … `d_stn_7.pattern` | 7 stone-scatter patterns, 13,124–23,314 B. `d_stn_1` = 20×18 cells, 125/360 mask cells (34.7%), 323 records, 18,890 B (from `TERRAIN_DONOR_PATTERNS.md:293`). Clump authoring is in the pattern mask, not in a sprite. | observed / prior-doc |
| `C:\Games\Cossacks 3\data\game\var\envscales.cfg` | `group = stones`: `stones` **0.329**, `stones1` 0.329, `stones10` 0.25, `stones2` 0.37, `stones3` 0.40, `stones4` 0.324, `stones5` 0.313, `stones6` 0.328, `stones7/8/9/10` 0.25. `group = smallstones`: 0.209–0.25. All `minscale = 0.85`, `maxscale = 1.15`. **No** `landstone`/`rocksea` group exists — those families inherit no donor scale value. | observed |

Derived: donor stone sizes span **0.25–0.40** (factor 1.6) and pebbles
**0.209–0.25** (factor 1.2); the two groups overlap only at 0.25, so the donor
already encodes a boulder/pebble size split. The port currently collapses all
of them onto one `stone 0.329` base (§2).

---

## 2. Port state (file:line)

| Item | file:line | Observed state | Tag |
|---|---|---|---|
| Sprite files | `app/assets/models/sprites_hi/rock_*.png` | **42** PNGs, all 512×512 RGBA: `rock_stones1..10` (10), `rock_stonessea1..10` (10), `rock_smallstones1..6` (6), `rock_smallstonesea1..6` (6), `rock_landstone1..4` (4), `rock_sea1..6` (6). The prior "36 variants" figure excludes the 6 `rock_sea*`. | observed |
| Registration | `app/scripts/world.gd:269-281` `_env_sids()` | All 42 rock keys are explicitly registered (loop groups at `:274-275`), plus legacy `rock`/`stone`. | observed |
| Loading | `app/scripts/world.gd:294-325`, `:319-323` | Hi-res `sprites_hi/<key>.png` preferred for every env sid; `_load_env_tex` (`:283-292`) decodes the PNG directly because `.ctex` caches are absent. `rock`/`stone` fall back to `sprites/*.png` 160×160. | observed |
| Pick | `app/scripts/world.gd:1378-1385` `_prop_tex()` | Position-hash pick from a name array; stable across chunk rebuilds. | observed |
| **ROCK_POOL** | `app/scripts/world.gd:1353-1355` | 12 keys: `rock`, `stone`, `rock_stones1..6`, `rock_smallstones1`, `rock_smallstones2`, `rock_landstone1`, `rock_landstone2`. | observed |
| Pool coverage | derived from above | 10 of 42 hi-res sprites wired; **32 unwired**: `rock_stones7..10` (4), `rock_smallstones3..6` (4), `rock_landstone3..4` (2), `rock_smallstonesea1..6` (6), `rock_sea1..6` (6), `rock_stonessea1..10` (10). T6's "≥4 silhouettes" is met by the pool but most variety stays dormant. | derived |
| Stone draw | `app/scripts/world.gd:1640-1652` | `:1643` `_prop_tex(ROCK_POOL, n.pos)`; `:1645` `_blob_rect(..., 14+h*6, 7+h*3, Color(0,0,0,0.2))` contact shadow; `:1646` `_draw_sprite(..., _env_sprite_h(2.8, "stone", n.pos))`; `:1648-1652` procedural 4-circle fallback if no sprite. Comment at `:1641-1642` already promises "≥4 distinct silhouettes". | observed |
| Scale / jitter | `app/scripts/world.gd:150-158` `_env_sprite_h()` | `ENV_SCALE["stone"] = 0.329` × deterministic 0.85–1.15 hash jitter. Donor per-variant scales (0.209–0.40) are **not** used; all 12 pool keys share one base. | observed / derived |
| Shadow | `app/scripts/world.gd:615-619` `_blob_rect`, `:660-661` | Runtime ellipse is drawn unconditionally for stones (`:1645`); the second circle in `_draw_sprite` is debug-gated by `Data.SHOW_CENTROIDS`, so it is not the production shadow. Sprites also have baked shadows (§4.2). | observed |

No code was changed. The gap versus donor is **placement and scale
differentiation**, not asset availability: 42 converted meshes exist, 10 are
reachable from a stone resource node.

---

## 3. Spec — `stones_rocks`

Base 512×512 recipe, exactly the requested shape, with measured counts/sizes in
`reference`:

```json
{
  "name": "stones_rocks",
  "size_px": [512, 512],
  "seed": 7,
  "layers": [
    {"type": "block", "name": "ground1", "tile": true},
    {"type": "sprite", "name": "rock_stones3", "pos": [0.35, 0.5], "scale": 1.0},
    {"type": "sprite", "name": "rock_smallstones2", "pos": [0.7, 0.6], "scale": 0.6}
  ],
  "reference": {
    "source_images": [
      "Cossacks3AttackingVillage.webp#crop(899,385,1670,899)",
      "cossacks-3-v1-498085.jpg#crop(880,130,1180,330)"
    ],
    "crop_boxes_px": {
      "village_pebbles": [899, 385, 1670, 899],
      "village_pebbles_tight": [899, 385, 1149, 540],
      "battle_cliff": [880, 130, 1180, 330]
    },
    "counts": {
      "rock_sprites_total": 42,
      "rock_sprites_wired_in_ROCK_POOL": 10,
      "distinct_silhouettes_total": 32,
      "distinct_silhouettes_wired": 10,
      "pebbles_per_smallstones_clump_range": [2, 9]
    },
    "sizes_px": {
      "sprite_canvas": [512, 512],
      "boulder_visible_height_median": 293,
      "boulder_visible_height_range": [258, 365],
      "pebble_clump_visible_height_median": 222,
      "pebble_clump_visible_height_range": [147, 260],
      "large_to_small_ratio": 1.32
    },
    "donor_scale": {
      "envscales_stones": 0.329,
      "envscales_stones_range": [0.25, 0.40],
      "envscales_smallstones_range": [0.209, 0.25],
      "jitter": [0.85, 1.15]
    }
  }
}
```

Notes on the numbers (**derived** from §4 and §1.3): visible height is the
alpha bbox height, not the 512 canvas. `rock_stones3` (the large layer) is 446×325
visible; `rock_smallstones2` (the pebble layer) is 446×216 visible with 9
separate pebble components at scale 1.0, so at `scale: 0.6` it reads as ~9 chips
of ~130 px canvas spacing. Layer positions `[0.35,0.5]` and `[0.7,0.6]` are
deliberately non-lattice offsets (see C3).

For a whole scatter **field** rather than one tile, extend the sprite layers so
that ≥4 distinct `rock_*` keys appear in one screenshot, e.g. add
`rock_stones6` at `[0.18,0.72]` scale 0.85 and `rock_landstone1` at
`[0.55,0.32]` scale 0.5. Keeps `seed: 7` deterministic; uses only sprites
already registered at `world.gd:274-275`.

---

## 4. Measurable criteria (from PNG bytes)

All values below were computed with Pillow on the 42 `sprites_hi/rock_*.png`
files. Each criterion states a concrete threshold so it can be re-run as a
gate.

### 4.1 C1 — ≥4 distinct silhouettes — **PASS at pool level**

Method: threshold the alpha channel at 128, resize to 16×16, encode as a
256-bit signature; count unique signatures (and pairwise Hamming distance ≥8).
Measured: **32 distinct signatures out of 42 sprites**. Duplicates are exactly
the same meshes with different tint: `rock_landstone1..4`, `rock_smallstones1..4`
and `rock_smallstonesea1..4` share alpha (`alpha_diff = None`) while their RGB
differs (e.g. `rock_landstone1` vs `rock_smallstones1` RGB diff bbox
`(109,145,402,402)`). `rock_stones3` vs `rock_stonessea3` are genuinely
different (`alpha_diff = (33,88,479,453)`).

Threshold: a scatter field must place ≥4 sprites whose signatures are distinct;
`ROCK_POOL` currently exposes 10 distinct hi-res silhouettes + 2 legacy, so the
literal 2-layer base recipe needs the extended layer list in §3 to pass on a
single tile. **observed** counts, **derived** gate.

### 4.2 C2 — shadow presence — **PASS**

Method: (a) compute alpha-bbox bottom `core_ymax` (α≥200) and `soft_ymax`
(0<α<200); (b) soft-alpha fraction in the bottom 18% of the visible bbox.
Measured: `soft_ymax > core_ymax` in 38/42 sprites (the 4 exceptions are the
`…1` smallstone/landstone set where they are equal by 1 px). Soft fraction for
the two named layers: `rock_stones3` **0.357**, `rock_smallstones2` **0.143**;
family ranges 0.14–0.36. Montage inspection confirms a dark baked contact band
at the base of every boulder and beneath each pebble cluster. Runtime adds a
second `Color(0,0,0,0.2)` ellipse (`world.gd:1645`).

Threshold: soft fraction ≥0.10 **or** bottom-18% dark-pixel fraction (mean
RGB<90) ≥0.12. All 42 pass. **observed**.

### 4.3 C3 — no uniform grid — **PASS**

Method: connected components of α≥160; keep components ≥4% of the largest
area; take centroids; compute the coefficient of variation (CV) of
nearest-neighbour distances. A perfect lattice gives CV≈0.

Measured on the pebble clusters:

| Sprite | components (big) | NN-distance CV |
|---|---|---|
| `rock_smallstones2` | 9 | **0.114** |
| `rock_landstone1` | 5 | **0.436** |
| `rock_landstone2` | 9 | **0.114** |
| `rock_landstone3` | 6 | **0.338** |
| `rock_smallstones6` | 4 | **0.275** |

Threshold: CV ≥0.10 when ≥3 components are present. Also check the composed
piece's own layer offsets: `[0.35,0.5]` and `[0.7,0.6]` have Δx=0.35, Δy=0.10 —
not a repeated row/column step. Degenerate 2-component sprites
(`rock_smallstones5`, `rock_landstone4`) are excluded from this test. **derived**.

### 4.4 C4 — size distribution / counts — **PASS**

Visible-height stats (alpha bbox height, px):

| Family | n | min | median | mean | max |
|---|---|---|---|---|---|
| `rock_stones` | 10 | 273 | 293 | 301.4 | 346 |
| `rock_stonessea` | 10 | 258 | 281 | 290.9 | 365 |
| `rock_sea` | 6 | 239 | 296 | 292.7 | 356 |
| `rock_smallstones` | 6 | 147 | 222 | 214.5 | 260 |
| `rock_landstone` | 4 | 147 | 236 | 220.0 | 260 |
| `rock_smallstonesea` | 6 | 147 | 222 | 214.5 | 260 |

Bimodal: large families median 281–296 px, small families median 220–236 px;
large:small median ratio **293/222 ≈ 1.32** (means 301.4/214.5 ≈ 1.41), which
brackets the donor's 0.329/0.25 = 1.32 scale ratio. Pebbles per clump range
**2–9** components. Threshold: a piece must contain at least one ≥250 px-height
boulder layer and one pebble cluster with ≥3 components across ≥2 size classes.
**observed** measurements, **derived** threshold.

---

## 5. Claim table

| # | Claim | Tag | Evidence | Status |
|---|---|---|---|---|
| 1 | Reference ground is covered with small irregular grey pebbles in clumps with bare gaps and tiny contact shadows. | observed | R1/R1a/R2 crops (§1.1) | supported |
| 2 | Reference large rocks are faceted outcrops seated into the ground with a dark contact band. | observed | R3/R4 crops | supported |
| 3 | Donor encodes two stone size groups (0.209–0.25 smallstones, 0.25–0.40 stones) with ±15% jitter. | observed | `envscales.cfg` groups `stones`, `smallstones` | supported |
| 4 | Donor stone scatter is authored as pattern masks (`d_stn_1..7`), e.g. `d_stn_1` 125/360 cells. | observed / prior-doc | `data/pattern/d_stn_*.pattern`; `TERRAIN_DONOR_PATTERNS.md:293` | supported |
| 5 | 42 rock sprites, all 512×512 RGBA, exist in `sprites_hi`; prior doc's "36" excluded `rock_sea*`. | observed | file glob + Pillow dimensions | supported |
| 6 | All 42 are registered for loading, but only 10 hi-res keys are reachable from `ROCK_POOL`. | observed / derived | `world.gd:269-281`, `:1353-1355`, `:1643` | supported |
| 7 | All stone variants share one `stone 0.329` scale with ±15% jitter; donor per-variant scales and landstone/rocksea (no cfg group) are not used. | observed / derived | `world.gd:150-158`, `:1646`; `envscales.cfg` | supported |
| 8 | Sprites carry baked contact shadows; a runtime 0.2-alpha ellipse is added at draw time. | observed | §4.2; `world.gd:1645`, `:615-619` | supported |
| 9 | 32 of 42 sprites are distinct silhouettes; the 10 duplicates are tint variants sharing identical alpha. | observed | §4.1 signature + `ImageChops` alpha diff | supported |
| 10 | Pebble clusters are non-grid (CV 0.114–0.436) and span 2–9 rocks across two size classes (~222 vs ~293 px median). | observed / derived | §4.3, §4.4 | supported |
| 11 | The literal 3-layer base spec places only 2 distinct sprite keys, so the ≥4-silhouette gate requires the extended field layer list. | derived | §3 spec vs §4.1 threshold | supported (open choice: field vs single tile) |
| 12 | Clump density gradients in the reference are reproduced by the port's pattern placement. | inferred | R1b gradient + `pattern_gen.gd` stone family (prior doc `:241,256`) | **not verified** — no runtime screenshot inspected in this lane |
| 13 | `landstone`/`rocksea` have no donor `envscales.cfg` entry, so their port size is an approximation. | observed / inferred | cfg grep + `world.gd:156` default lookup | supported / impact inferred |

Open question: whether to wire the 32 dormant rock keys into `ROCK_POOL` (T6
follow-up) or keep the pool small and let the piece recipe reference sprites
directly — this research does not decide implementation.

End.

---

## 6. T6-T11 — headless mini-baker rebuild and re-verification (2026-11-23)

Scope: one deterministic headless baker, `app/tools/pieces/t6_stones_rocks.py`
(module `T6T11-STONES-ROCKS-R1-20261123`). No Godot, no donor asset copied into
the repo, no shared file edited. Full claim table, hashes and open questions in
`docs/t6/reports/T6-T11.md`. Backup of this audit file before append:
`inbox\backup\stones_rocks.md.bak-T6-T11` (SHA-256 `DC081D72…D56C4D8`).

### 6.1 Why the T2 render was rebuilt

The T2 spec render (`sha 63c78c5c334b`) passed C1–C4 numerically but read as
diagram art: two ~325 px centred boulders, a row of icon-sized pebbles, green
cube-like `rock_landstone1` clumps, and an **invalid** donor panel — the
`(899,385,1670,899)` village crop contains soldiers, yellow selection rings,
a horse and houses. A systematic scan of the whole dirt clearing found no fully
unit-free, building-free 200×200 pebble crop, so the binding donor-crop rule was
met via the explicit composite route (T15 precedent): the new compare panel is
a labelled composite of genuine donor `ground1.dds` centre crop
`(256,256,768,768)` plus four donor-mesh rock sprites. No UI/minimap/units.

### 6.2 Donor truth re-measured (temp probes; see report claim table)

- **observed / derived**: chips are 1.5–4 px (median 2, p75 3) angular grey
  chips, ≈136 per 100×100 source px, chip RGB p10/50/90
  `(78,78,72)/(108,103,90)/(131,125,112)`, each with a tiny lower-left contact
  shadow (sun upper-right).
- **observed**: dirt ground ≈`(101,93,68)`; donor `ground1.dds` centre and the
  port `ground1.png` block both measure `(99.8,90.7,66.3)` — an exact anchor.
- **observed**: donor rock sprites have 257–325 px visible height and baked
  dark contact bands (bottom-18% dark fraction 0.28–0.65).

### 6.3 Implemented recipe

1. `ground1` mirror tile, contrast 1.12.
2. Seeded clumped micro-chip field (2-octave value noise, 6 px sites ±4 px
   jitter), 2–7 px chips sampled from the donor chip palette, 1 px dark
   lower-left shadow + lit upper-right facet. 3 202 chips ≈122/100²px.
3. 14 donor-mesh rock sprites at 0.058–0.255 scale (12–76 px visible), each
   with a soft directional contact shadow; 6 distinct silhouette keys.
4. One `rock_stones3` outcrop at scale 0.78 (253.5 px layer height) anchored to
   the top-left edge with a stronger shadow.

### 6.4 Re-verification result — 10 PASS / 0 FAIL

| Group | Criteria | Result |
|---|---|---|
| Regression (T2, unchanged thresholds) | C1 silhouettes / C2 shadow / C3 no-grid / C4 bimodal | **4 PASS / 0 FAIL** (6 keys Hamming 13–86; dark bottom-18 0.172–0.654; NN CV 0.308; boulder 253.5 px + 10 medium + 4 chips classes) |
| TB-V1 density/size | T1 hi-freq / T2 speckle px / T3 density / T4 buckets / T5 clumping / T6 grade | **6 PASS / 0 FAIL** (hi-freq 9.56 in 3–12; 2–7 px; 122.1 vs 136.3 donor; all 4 buckets present; CV 0.308; mean RGB within 1–2.5 of donor panel) |

Final hashes: render `7e3d037612ef980c5ea86c9d81cca4542fbfcd1fdfef9171b10dce76a62f92ca`,
compare sheet `486492b3758cdb2a2b64382f9618e8aeee0ffa41996a4e08994b223b4a8a2004`.
Determinism: two independent re-renders byte-identical. Both final PNGs were
opened and visually reviewed: organic gravel scatter, varied donor-mesh stones
with contact shadows, no hard outlines / stencil icons / lattice / kaleidoscope.
Honest residuals (denser chip field than the bare donor tile, tighter donor
stone clusters, slightly higher donor contrast) are recorded in T6-T11 §2 and
transferred to combo/owner review — not hidden.

Open questions retained from §5 and this rebuild: exact in-engine `d_stn_*`
placement density (Q1), camera-scale read of the ≥250 px boulder (Q2), no
unit-free screenshot crop so the donor panel is necessarily a composite (Q4),
and the 32 dormant `ROCK_POOL` silhouettes still unwired in `world.gd` (Q5,
T90 scope). No engine file was changed by this worker.
