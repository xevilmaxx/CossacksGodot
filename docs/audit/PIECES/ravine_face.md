# ravine_face.md — visual truth + recipe for a ravine rock-face piece

Scope: RESEARCH only. One file written. No Godot, no generator code, no donor assets copied.
All image measurements below were made with Pillow into temp files only
(`%TEMP%\opencode\ravine_analyze*.py`, crop previews `rav_cropA*.png`, `rav_cropB.png`,
`donor_rock8.png`). Donor paths were read in place, never written.

Prior art: `docs/audit/TERRAIN_REFERENCE_IMAGES.md` §3.1 / §5 (rock 8–18% area, apparent
75–85°, face height 8–12% of frame, vertical striations, hard ≤3 px rim, lit `#6C614B` /
shadow `#393424`), `docs/audit/TERRAIN_BEAUTY_TRIAGE.md:77` (port rock 2.3–3.7%, deferred
for walkability).

---

## 1. Donor morphology + palette (primary crop evidence)

**Primary image** `C:\Users\Maxym.Oboyshev\Downloads\c3\cossacks-3-v1-498085.jpg` (1280×720).
Crops used: **A = (560,150,1000,560)** = 440×410 (the §6 primary morphology crop),
**B = (0,300,420,720)** = 420×420 (left gully). Both viewed at 1× and 2×.

### 1.1 Morphology (observed in crops A and B)

- A branching network of narrow winding gullies cut into a near-planar grass plateau; the
  plateau top is smooth and flat between cuts.
- Faces are **near-vertical**: wall top-to-bottom drift is ~10–20% of height → apparent slope
  **75–85°** from horizontal. Face height ≈ 60–90 px of the 720 px source = **8–12% of frame**;
  gully mouth width ≈ 30–100 px. Confirms §3.1.
- Faces carry **fine vertical/wavy erosion flutes** running straight down the wall (clear in
  the 2× view of crop A, pale strips on the right-hand wall and top-left wall, and the dark
  striated pit centre-left). Measured anisotropy **dx/dy = 1.69** on the lit wall and **1.37**
  on the shadowed pit (GaussianBlur(1) on luminance; vertical flutes ⇒ horizontal gradient
  dominates). This is *rendered* anisotropy — the geometry + intrinsic shading amplify the
  texture's own dx/dy ≈ 1.24.
- **Grass meets rock abruptly**: rim is a hard 1–3 px transition with grass tufts overhanging
  the edge; no soft grass→dirt gradient. Confirms §3.1 / §5 rank 6.
- **Shadow is intrinsic**: lit flutes catch light as pale strips, recesses read as dark slits;
  north/attic-facing walls ~2× darker. Top-decile pale strips measured **#8B7D67** (139,126,104);
  bulk lit wall **#564E39** (86,78,58); deep gully shadow **#383423** (57,52,36).

### 1.2 Palette anchors (Pillow means, 1× crop-A coordinates)

| Sample | Box (in crop A) | Mean hex | Comment |
|--------|-----------------|----------|---------|
| Pale striation strips (top decile) | (350,220,435,305) top 10% L | `#8B7D67` | sunlit flute crests |
| Bulk lit/striated wall | (350,220,435,305) | `#564E39` | flutes + shadowed grooves averaged |
| Lit face, second patch | (40,20,85,55) | `#564F35` | consistent with above |
| Deep gully shadow | (260,165,320,215) | `#383423` | matches prior `#393424` exactly |
| Plateau grass (contrast) | (150,300,300,400) | `#5F5F2C` | olive, hue ~60°, sat 0.53 |
| Olive grass (contrast) | (60,120,120,170) | `#616031` | olive, hue ~59°, sat 0.49 |

Canonical §3.1 anchors retained as targets: **lit `#6C614B` (108,97,75), mid `#4B4430`
(75,68,48), shadow `#393424` (57,52,36)**. My independent deep-shadow sample `#383423`
corroborates the shadow anchor to within 1 RGB/channel; my bulk-lit `#564E39` and pale-flute
`#8B7D67` bracket the lit anchor — the spread is the flute crest/groove modulation the prior
doc describes, not a contradiction.

### 1.3 Rock area — strict threshold corroborates the 8–18% target

Strict classifier (`g>=r` and olive hue 35–95° and sat>0.20 ⇒ grass; otherwise
`r>=g*0.95`, `g>=b*0.95`, sat<0.45, value<0.62 ⇒ rock; sampled every 2 px):

| Crop | Rock area | Source |
|------|-----------|--------|
| A (560,150,1000,560) | **17.9%** | this doc, Pillow |
| B (0,300,420,720) | **17.3%** | this doc, Pillow |
| prior estimate #8 | 10–18% | `TERRAIN_REFERENCE_IMAGES.md:84,150` (visual, UNVERIFIED there) |

A looser threshold that also absorbs dark tree/shadow pixels gives 31–33%; that is an
over-count (it swallows conifers and deep slits). The **strict 17.3–17.9%** figure lands at
the top of, and independently supports, the 8–18% acceptance band.

### 1.4 Donor constants + pattern family (context, not copied)

`data/scripts/common.inc/generatemap.inc` relief constants read in place:
`cPlateauHeight = 2.964`, `cHillHeight = cPlateauHeight/2.25 = 1.317`,
`cRavineHeight = -2.964`, `cWaterHeight = -1.1`, `cRHill = 2`. Donor rock-tile rule
(`TERRAIN_DONOR_PIPELINE.md:132`, donor D4:594–601): aspect picks the face tile;
`abs(height)>2.7 → rock8`, `>2.4 → rock4`.

Ravine **pattern family = 18 patterns**: `k_ravine_1..9` (129–280 KB), `k_ravine_big_1`
(518 KB), `k_ravine_big_stone_1..8` (212–477 KB). Binaries are compressed/opaque — no
plaintext strings could be extracted. `TERRAIN_DONOR_PATTERNS.md:216,247` records their
content roles (`terrainmesh`, `rocks`, `smallstones`) and that the family is **MISSING** from
the port. These are the donor's face *geometry*; the port has no equivalent extrusion.

---

## 2. Port gap — file:line, measured numbers, root cause

### 2.1 Measured gap

| Image | Rock area (same strict classifier) | Provenance |
|-------|------------------------------------|------------|
| `app/shots/terrain_relief.png` (1280×720, seed 20261113, relief `hills`) | **3.7%** | this doc, Pillow |
| canonical port range across seeds | **2.3–3.7%** | `TERRAIN_BEAUTY_TRIAGE.md:77` |
| donor crop A | 17.9% | §1.3 |

Gap ≈ **4.8×** (17.9 / 3.7). Visual result in `terrain_relief.png`: sparse, scattered
**rectangular** rock patches with visible flat top-down flutes and hard square tile borders —
"blocky, repeating", exactly the reported failure. No vertical faces, no overhang rim, no
lit/shadow face strips.

### 2.2 How port rock tiles are selected (inspection)

1. **Rock cells are born in the collision pass**, not in relief painting —
   `app/scripts/game.gd:822–843`: a cell becomes `terrain = 5` **and** `blocked = 1` only if a
   cardinal `|dh| > 0.5` or diagonal `|dh| > 0.55` (lines 829–840). Steep cells are therefore
   few and *unbuildable by construction*. `TERRAIN_PORT_HILLS.md:83–84` confirms domes are
   smooth paraboloids Ø14–26 tiles, so few cells ever cross 0.5.
2. **Tile choice** — `app/scripts/game.gd:_assign_tileblocks` (`:1124–1193`): terrain 5 base
   rolls among `rock1/2/3/6/7/4` (`:1166–1178`). `_apply_shore_cliffs` (`:1263–1274`) then
   calls `_cliff_tile_for` (`:1228–1261`) to reassign by height-gradient aspect, with
   `abs(h0) > 2.7 → "rock8"` (`:1255–1256`) and `> 2.4 → "rock4"`.
3. **Height changes orientation only, not whether a hill reads rocky** —
   `TERRAIN_PORT_HILLS.md:72`. `_cliff_tile_for` cannot create rock area; it only relabels
   cells already in `terrain = 5`. So the sparse rock-cell count from step 1 is the hard cap.
4. **Render caps flatten the look** — `app/scripts/world.gd:58–59`
   (`BLOCKS_PER_CHUNK = 3`, `BLOCKS_PER_ROLE = 2`), `_rank_blocks` (`:958–966`),
   `_composite_blocks` (`:998–1046`): per-cell alpha grids are bilinearly cross-faded over one
   tile; the rock role pass is `:1095–1107`. Rare rock names fall back to grass (B1a, `:955–957`),
   and the bilinear mask + flat `draw_texture_rect` mapping (`:850–872`, `_block_img`) produce
   soft rectangular patches instead of a hard-rimmed vertical face.
5. **Walkability is why it was deferred** — `TERRAIN_BEAUTY_TRIAGE.md:77` explicitly records
   "rock% below 8–18% target deferred for walkability".

### 2.3 Does the striation art exist in `blocks/rock*.png`? — YES

`app/assets/terrain/blocks/rock8.png` is 1024×1024 and is a pixel/converted copy of donor
`data/terrain/tiles/textures/rock8.dds` (also 1024×1024, RGBA) — visually identical vertical
fluted, moss-flecked rock. Both have dx/dy ≈ 1.24–1.28 (baked vertical flutes). Per-tile
anisotropy (1024², GaussianBlur(1)):

| tile | dx/dy | face-suitable? |
|------|-------|----------------|
| rock8 | 1.28 | **yes** — the high-cliff tile, used by `_cliff_tile_for` at `|h|>2.7` |
| rock1 | 1.98 | yes — strongest vertical flutes |
| rock4 | 1.25 | yes |
| rock6 / rock7 | 1.00 | neutral (isotropic) |
| rock2 / rock3 | 0.52 | **no** — striations run horizontally; wrong direction for a face |

**Conclusion:** the art is present and correct. The gap is (a) too few rock cells, (b) flat
top-down mapping instead of a vertical face, (c) missing hard rim and intrinsic lit/shadow
strips — *not* missing source art.

### 2.4 Minimum rendering change to close 2–4% → 8–18% without breaking buildability

Rejected tempting fix: lowering the collision threshold (0.5 → 0.25) in `game.gd:829–840`
would convert more cells to `terrain = 5` **and set `blocked = 1`**, shrinking buildable land —
this is precisely the deferral reason. Do not touch collision.

**Proposed minimum (render-only, M1):** add a *visual-only face-collar pass* in `world.gd`
that decouples "looks like rock face" from "is impassable rock":

- For every **land** cell (`terrain != 3/4`) adjacent to a height step above a **visual**
  threshold (~0.25, deliberately lower than the 0.5 collision threshold), paint a narrow
  striated band using the already-cached `_block_img("rock8")` (`:850–872`). Mask by the
  height gradient, **not** by `terrain == 5` → blocked array untouched, buildability identical.
- Stretch the rock8 crop vertically ~2× and apply a two-tone shade ramp keyed to gradient
  direction (lit `#6C614B` on the sun-facing side, recess `#393424` on the lee) to convert
  flat flutes into apparent vertical face + intrinsic shadow.
- Draw the grass boundary with a **binary 1–3 px alpha** edge (no bilinear feather) plus one
  overhanging grass-tuft row from `grass1`; this yields the ≤3 px hard rim.
- Vary the crop offset per face segment (hash of cell x,y rather than the current constant
  `abs(hash(nm)) % 512` at `:1044`) to break the repeating look. Rock needs only **one** name,
  so `BLOCKS_PER_ROLE = 2` and `BLK_CACHE = 32` stay within budget — no perf/cache regression.

Because no `terrain[]` or `blocked[]` cell changes, selftest/uitest determinism and byte-identical
map dumps are preserved. This is the smallest diff that raises *visible* rock to the 8–18% band
while leaving the 2.3–3.7% blocked-cell footprint as-is. (M2, only if M1 underfills: widen the
visual threshold to 0.18 and allow rock1 as a second face name — still render-only.)

---

## 3. Piece spec

```json
{
  "name": "ravine_face",
  "size_px": [512, 512],
  "seed": 7,
  "layers": [
    {"type": "block", "name": "rock8", "tile": true},
    {"type": "block", "name": "grass1", "opacity": 0.82}
  ],
  "reference": {
    "primary": "cossacks-3-v1-498085.jpg",
    "crop": [560, 150, 1000, 560],
    "secondary_crop": [0, 300, 420, 720],
    "art": "app/assets/terrain/blocks/rock8.png",
    "donor_art": "data/terrain/tiles/textures/rock8.dds",
    "palette": {
      "lit": "#6C614B", "mid": "#4B4430", "shadow": "#393424",
      "pale_flute": "#8B7D67", "grass": "#616727"
    }
  },
  "face_geometry": {
    "apparent_angle_deg": [75, 85],
    "max_edge_drift_frac_of_height": 0.20,
    "face_height_frac_of_frame": [0.08, 0.12],
    "mouth_width_px": [30, 100],
    "rim_width_px": 3,
    "flute_anisotropy_dx_over_dy": [1.3, 1.7],
    "vertical_stretch": 2.0,
    "lit_shadow_luma_ratio": 1.9,
    "rock_area_frac": [0.08, 0.18]
  }
}
```

Notes on the recipe: `rock8` is `tile:true` (mirror-tiled, matching `world.gd:_block_img`);
`grass1` at opacity 0.82 is the overhanging rim cap, masked to a ≤3 px hard edge rather than a
soft alpha. Seed 7 matches the seedscan family already present in `app/shots/`. The face
geometry values are the §3.1 / §5 targets restated as compositable parameters; the vertical
stretch of 2.0 is the minimal transform that brings the texture's dx/dy ≈ 1.28 up to the
rendered 1.4–1.7 seen in donor crops.

---

## 4. Measurable acceptance criteria (from PNG)

All measured on a 512×512 piece render downsampled to 400×400 unless noted; Pillow methods.

| # | Criterion | Target | Measurement |
|---|-----------|--------|-------------|
| 1 | Rock area | **8–18%** of terrain pixels | Strict classifier §1.3; donor reference = 17.9%, port baseline = 3.7% |
| 2 | Face slope / size | drift <20% of height; height 8–12% of frame; mouth 30–100 px | Measure 3 face tops vs bottoms on a 2× crop; use §1.1 anchors |
| 3 | Flute anisotropy | dx/dy ≥ **1.3** on a face sub-crop | `ImageChops.difference` of blurred L shifted ±1 px in x and y (§1.1) |
| 4 | Palette | lit ≈ `#6C614B`±10, shadow ≈ `#393424`±10, mid ≈ `#4B4430`±12 | Pillow mean RGB of lit/shadow boxes; luma ratio `108/57 ≈ 1.9`, require ≥1.5 |
| 5 | Rim hard edge | transition ≤ **3 px**, no smooth ramp | 1-px profile perpendicular to a rim; count grass→rock pixels |
| 6 | Face micro-texture | hi-freq (image − 5 px Gaussian) mean **8–14** luma levels; Lstd 20–30 | `ImageStat` on a face crop (donor lit face measured hf 10.84 / Lstd 24.7; mid face hf 12.79) |
| 7 | No flat-tile repeat | ≥3 visually distinct 128px rock windows; seam correlation low | Compare adjacent rock windows; rejects the current single-offset repeat |
| G | Buildability gate (non-PNG) | `blocked[]` array byte-identical to baseline; blocked-cell fraction unchanged | Compare sim dump before/after M1 — proves walkability preserved |

Criterion 1 is the primary gate; 2–6 distinguish a real face from a flat rock tile; G is the
"without breaking buildability" proof required by the task.

---

## 5. Claim table

| Claim | Evidence | Method | Verdict | Caveat |
|-------|----------|--------|---------|--------|
| Donor faces near-vertical 75–85°, height 8–12% frame | crop A 2× | visual wall drift vs height | observed | apparent 2.5D slope, not true 3D |
| Donor faces carry vertical flutes | crop A lit wall + dark pit | dx/dy 1.69 / 1.37 | derived | blur(1) dependent |
| Donor rock area 17.3–17.9% (supports 8–18% target) | crops A, B | strict 2-px threshold | derived | loose threshold over-counts trees → 31–33% |
| Donor deep shadow `#383423` ≈ prior `#393424` | crop A box (260,165,320,215) | Pillow mean | derived | ±10 RGB from JPEG artifacts |
| Donor pale flutes `#8B7D67`, bulk lit `#564E39` | crop A right wall | top-decile / box means | derived | brackets prior `#6C614B`; not a contradiction |
| Grass→rock rim ≤3 px, tufts overhang | crop A/B | visual zoom (1×/2×) | observed | from §3.1; not re-measured profile here |
| Relief constants 2.964 / 1.317 / −2.964 / −1.1 | `generatemap.inc` | read in place | observed | donor plaintext |
| Ravine family = 18 opaque patterns, MISSING in port | donor dir + `TERRAIN_DONOR_PATTERNS.md:216` | file listing + doc | observed | binary strings undecodable |
| Port rock 3.7% (range 2.3–3.7%) | `terrain_relief.png`, `TERRAIN_BEAUTY_TRIAGE.md:77` | strict classifier + prior | derived | seed 20261113 only |
| Rock cells = steep + blocked | `game.gd:822–843` | code read | observed | 0.5/0.55 thresholds |
| Cliff height only orients, can't create rock | `game.gd:1228–1274`, `TERRAIN_PORT_HILLS.md:72` | code read | observed | — |
| Striation art exists in `rock8.png` | `rock8.png` vs `rock8.dds`, dx/dy | visual + Pillow | observed | 1024², identical textures |
| Face anisotropy amplified by geometry (1.24→1.69) | donor texture vs donor render | dx/dy comparison | derived | — |
| Cap/bilinear compositing → blocky repeat | `world.gd:58–59,958–1046,1095–1107` | code read + shot | observed | diagnosis, not proof of single cause |
| Visual-only collar closes gap without buildability loss | §2.4 proposal | design inference | inferred | UNTTESTED; needs render + gate G |

**End.**
