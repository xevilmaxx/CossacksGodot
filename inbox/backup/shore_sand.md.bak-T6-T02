# shore_sand — visual truth + exact recipe

**Lane:** T2-PIECE-SHORE-SAND (RESEARCH only).
**Status:** FINAL — one file written (`docs/audit/PIECES/shore_sand.md`); no Godot run, no donor binary copied, no code or asset touched. Pillow crops/samples were written only under `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\`.
**Protocol:** `SWARM_OPS.md §5b-QUALITY`. Verdict labels: `observed` (literal file/pixel read), `derived` (arithmetic or code-path consequence), `inferred` (attribution with caveat), `UNVERIFIED` (not confirmed). A claim is never promoted because it is convenient.
**Date:** 2026-11-21.

---

## 0. Sources and method

### 0.1 Donor (private-use, read-only)
- `C:\Games\Cossacks 3\data\scripts\common.inc\texturemap.inc` — `TextureMap` shore logic: constants at :29–31, gradient at :426–447, water/shore gate at :463–472, 8-sector table at :474–501, tile choice at :503–511, set/winter at :512–529.
- `C:\Games\Cossacks 3\data\terrain\tiles\textures\sandsea1..6.dds`, `sand1..9.dds`, `sandrock1/3.dds` — 1024² RGBA (except `sand1/2` 256²), Pillow 12.1.1 means / std / edge-strip means / 8-band vertical profile.
- `data\water\water.lib` constants and `data\water\water.mat` as reported in `docs/audit/TERRAIN_DONOR_ASSETS.md:3.3` (cross-check only, not re-read here).

### 0.2 Reference images (read-only)
- `C:\Users\Maxym.Oboyshev\Downloads\c3\maxresdefault_1.jpg` 512×288 — the only lit shallow-water/shore frame (image #12 of the prior reference audit). Prior 3×-zoom boxes were converted back to source px by `(300 + x/3, 150 + y/3)`.
- `C:\Users\Maxym.Oboyshev\Downloads\c3\articolo-787.jpg` 960×540 — dark-water overview (#6).

### 0.3 Port (read-only)
- `app\scripts\game.gd` — `_assign_tileblocks()` :1124–1193, `_shore_tile_for()` :1195–1226, `_apply_shore_cliffs()` :1263–1274, role/threshold pass :766–813.
- `app\scripts\world.gd` — `_alpha_mask()` :909–916, `_composite_blocks()` :998–1046, `_build_chunk()` :1048–1135, water mask :829–848.
- `app\shaders\water_overlay.gdshader` — depth fade :62–64, foam band :77–85, alpha :87–89.
- `app\assets\terrain\blocks\sandsea1..6.png`, `sand1..9.png` — dimensions/mode/means; donor↔port pixel-identity via `ImageChops.difference`.
- `app\scripts\data.gd:23` (`TILE_M = 2.0`), `:33–34` (`MAP_W = MAP_H = 160`).

### 0.4 Prior docs used for grounding (not new evidence)
`docs/audit/TERRAIN_DONOR_PIPELINE.md §3.3` (shore set: "8 sectors, cAngle=45°, tiles sandsea1/5/6 by aspect", D4:474–529), `docs/audit/TERRAIN_DONOR_ASSETS.md §3.2` (112 DDS ↔ 112 PNG exact family match; 6 sandsea), `docs/audit/TERRAIN_REFERENCE_IMAGES.md §3.4` (sand `#A89E7F`, shore ~5–10% near water, shading §5 rank 8 "sand→wash→water 3 bands").

---

## 1. Donor visual truth — palette and sector/tile mapping

### 1.1 Palette (measured, texture space = unlit)

| Texture | DDS size / mode | Mean RGB | Hex | Std RGB | Alpha | Evidence |
|---|---|---|---|---|---|---|
| `sandsea1` | 1024² RGBA | (128.5,119.5,85.8) | `#807856` | (13.9,13.9,13.3) | 255 everywhere | donor DDS, Pillow full-image mean |
| `sandsea2` | 1024² RGBA | (128.5,119.5,85.8) | `#807856` | (13.9,13.9,13.3) | 255 | same method |
| `sandsea3` | 1024² RGBA | (128.7,119.7,85.9) | `#817856` | (12.3,12.3,11.8) | 255 | same method |
| `sandsea4` | 1024² RGBA | (128.7,119.7,85.9) | `#817856` | (12.3,12.3,11.8) | 255 | same method |
| `sandsea5` | 1024² RGBA | (122.9,114.0,82.4) | `#7B7252` | (11.3,11.9,11.0) | 255 | same method |
| `sandsea6` | 1024² RGBA | (125.1,115.6,86.2) | `#7D7456` | (13.1,13.3,13.7) | 255 | same method |
| `sand3` (dry beach) | 1024² RGBA | (122.7,116.7,87.3) | `#7B7557` | (15.5,14.4,13.0) | 255 | same method |
| `sand7` (dry beach) | 1024² RGBA | (92.1,89.0,51.2) | `#5C5933` | (23.0,21.8,20.2) | 255 | same method |

`observed`: every sandsea tile is a near-uniform warm olive-tan with low contrast (std ≈ 11–14 levels); the **wet look is NOT painted as a dark/blue band inside the tile**. Edge-strip means differ by ≤3 RGB from the tile mean (e.g. `sandsea1` top `#837A57`, bottom `#827957`, left `#817755`, right `#807755`). The 8-band vertical profile of `sandsea1` stays in `#7D7453`–`#837A58`; `sandsea6` drifts `#7C7355`→`#81775A`→`#7D7457`. `derived`: the directional cue the orientation table selects is **ripple/grain direction and subtle tone**, not a baked water gradient. Any recipe that expects a dark water band inside `sandseaN` is wrong.

`observed`: port `blocks/sandsea1..6.png` are 1024² RGB and **pixel-identical** to the donor DDS RGB on `sandsea1`, `sandsea5`, `sandsea6` (`ImageChops.difference().getbbox() is None`), with the same means/std above. Donor alpha is 255 for every sampled pixel, so the documented "alpha dropped" conversion is harmless for this family. `derived`: **the art itself is not the defect**; placement, band width, orientation and compositing are.

### 1.2 Sector → tile mapping (literal donor code)

`observed` chain:
1. `texturemap.inc:433–439` — four neighbour heights `lh,rh,th,bh` around the cell; `dirX = lh-rh`, `dirY = th-bh`.
2. `texturemap.inc:441–447` — `len = VectorLength(dirX,0,dirY)`; if `len>0.01` normalise and `vecangle := VectorAngle(1,0,0, dirX,0,dirY)`; **if `dirY<0` then `vecangle := -vecangle`**.
3. `texturemap.inc:476` — `vecangle := vecangle + 180`.
4. `texturemap.inc:474` — `const cAngle = 45`; sector `k` is `vecangle ∈ [k*45 − 22.5, (k+1)*45 − 22.5)`, final `else` = `bRT` (:479–501).
5. `texturemap.inc:463–472` — gate: the cell must be mask-B water (`gMapMask[ix,iy].b>0`) **and** `height < -0.25` (`bWater`) or `height < -0.1` (`bWaterShore`). Wet sandsea is therefore painted **on water and wet-shore cells**, not on dry land.
6. `texturemap.inc:503–511` — tile choice: `bLB→sandsea5`, `bRB→sandsea6`, `bB→sandsea1`, `bL→sandsea6`, `bR→sandsea6`, `bT→sandsea1`, `bRT→sandsea5`, `bLT→sandsea6`.
7. `texturemap.inc:525–528` — append `_winter` when `GetSeasonType=2`, then `SetTileIndex(x,y, MapGetTileIndexByTileBlock(newtile))`.

| Sector | Donor flag | Literal angle window (before +180 wrap) | Tile | Evidence |
|---|---|---|---|---|
| k=0 | `bR` | `[-22.5, 22.5)` | `sandsea6` | D4:479–480, :508 |
| k=1 | `bRB` | `[22.5, 67.5)` | `sandsea6` | D4:482–483, :505 |
| k=2 | `bB` | `[67.5, 112.5)` | `sandsea1` | D4:485–486, :506 |
| k=3 | `bLB` | `[112.5, 157.5)` | `sandsea5` | D4:488–489, :504 |
| k=4 | `bL` | `[157.5, 202.5)` | `sandsea6` | D4:491–492, :507 |
| k=5 | `bLT` | `[202.5, 247.5)` | `sandsea6` | D4:494–495, :511 |
| k=6 | `bT` | `[247.5, 292.5)` | `sandsea1` | D4:497–498, :509 |
| k=7 (`else`) | `bRT` | `[292.5, 337.5)` plus the wrapped remainder | `sandsea5` | D4:500–501, :510 |

`derived`: the active table uses **exactly 3 distinct textures — `sandsea1`, `sandsea5`, `sandsea6`**. `sandsea2/3/4` exist on disk but are not chosen by the live code (they appear only as the commented-out `'sandsea4'/'sandsea3'/'sandsea2'` alternatives at D4:504–511). `observed`: `docs/audit/TERRAIN_DONOR_PIPELINE.md §3.3` records the same 8-sector/45°/1-5-6 finding (D4:474–529).

### 1.3 Band structure: sand → wash → water

`observed` (reference #12, `maxresdefault_1.jpg`, horizontal profile y=210..240, source px; mean of each 20 px column):

| x (px) | Mean hex | Read |
|---|---|---|
| 300 | `#746850` | grass/dirt before the shore |
| 320 | `#9C9176` | outer dry-ish sand |
| 340 | `#A69C7D` | sand (prior doc's `#A89E7F` crop at 340–380 = (167.7,157.8,126.7), std ≈10) |
| 360 | `#ADA486` | inner sand |
| 380 | `#B9BAA7` | pale wash |
| 400 | `#BBC4BB` | pale wash / shallow water edge |
| 420 | `#494235` | dark bank/object (mixed; sample contaminated) |

`derived`: along this profile the sand band spans ≈40–60 source px and the pale wash ≈30–40 source px at 512×288. Prior doc `§3.4` gives the lit shallow-water mean `#696B65` (a mixed crop — my wider box at 410–456 gives `#6A6C66` with std ≈65–77 → **LOW confidence**, do not use as an exact colour target) and `#3A4246` for the dark river in #6.

`observed`: donor has **no foam texture family** (`TERRAIN_DONOR_ASSETS.md:6/C1` — recursive search for `foam|surf|shore|coastline|beach` returned 0 image files). The wash is produced by the water shader plus the sandsea art on wet cells. `water.lib` (`TERRAIN_DONOR_ASSETS.md:3.3`): `DeepColor=(0,0,0.1255,0.5)`, `ShallowColor=(0,0,0,0.5)`, `MaxDepth=1`, `MaxAlpha=1.1`, `MinAlpha=0`, `COAST` fade depth 0.57, deep fade 1.07 = 0.50+0.57. Port shader `water_overlay.gdshader:27–31` mirrors these as `WATERCOLOR=(0.10,0.24,0.24)`, `WATERCOLOR2=(0,0.025,0.05)`, `COAST_FADE=0.57`, `DEEP_FADE=1.07`; `:88` sets `alpha = coverage * mix(0.35, 1.0, coastfade2)` → **shallow-water opacity 0.35** is the donor-derived number to use for the `water` layer.

`derived`: the donor look is a 3-band transition in which (a) the sandsea tile art extends onto water cells (D4:463–472), (b) shallow water is translucent (0.35 alpha) so the grain still reads through, and (c) the foam term is gated to the coast band (`shader:77–85`, `band = coastfade*(1-coastfade2)`). Sand and wash **coexist on the same cells**; they are not mutually exclusive land/water roles.

---

## 2. Current port defect — what is wrong, with file:line

The port already contains a partial mitigation (`world.gd:1081–1083`, comment "TB-B1e … was the wide flat tan ring"), so the failure is **not** that sandsea art is absent — it is that the collar is over-wide, the art is over-attenuated, and the wet/wash band is erased. Findings:

| # | Defect | Evidence (port file:line) | Donor anchor | Measured/derived symptom |
|---|---|---|---|---|
| D1 | Sand band threshold is `-0.05`, not donor `WATER_SHORE=-0.1`. Band `-0.25..-0.05` is 0.20 height units vs donor 0.15 → **+33% width**. | `game.gd:777–782` (`elif hh < -0.05: t = 4`) | `texturemap.inc:30–31` (`-0.25`, `-0.1`) | `derived` |
| D2 | The **entire outer water ring** is flipped to walkable sand: every `terrain==3` cell with any non-water neighbour in its 8-neighbourhood becomes `terrain=4`, `blocked=0`. This paints dry tan on the **water side** of the coastline and removes shallow water exactly where the donor paints wet sandsea. | `game.gd:785–813` (esp. :797–812) | `texturemap.inc:463–472` (sandsea on masked water/wet cells, but water mesh stays water) | `derived` — the wash band has no cells left to render on |
| D3 | Base sand cells use **dry** `sand1/sand2/sand7`, not sandsea: `sand1` mean `#494D20`, `sand7` `#5C5933` — greenish/dark tan, not the wet-sand `#807856`. | `game.gd:1164–1165` | `texturemap.inc:503–511` | `observed` (code + donor means) |
| D4 | `sandsea*` art is **excluded from the chunk-wide base pass** and only composited in the role-4 pass at `max_alpha=0.55`, `falloff=1.7` — gamma 1.7 + 45% alpha ceiling cuts the tile grain (donor std ≈11–14) to roughly 4–7 effective levels → visually flat. | `world.gd:1084–1088`, `world.gd:1099–1103` | donor tiles are full-strength opaque | `derived` (alpha arithmetic); perceptual verdict `inferred` |
| D5 | Sector mapping is not the donor's uniform 8×45° table. Port branch `ang >= 315 or ang < 22.5` gives `bR` a **67.5°** window and leaves `bRT` only **22.5°** (`292.5–315`); donor gives `bR` 22.5° and `bRT` the wrapped remainder. 45° of orientation is assigned to the wrong tile. | `game.gd:1212–1226` (first branch :1212, last :1226) | `texturemap.inc:474`, `:479–501` | `derived` from literal angle inequalities; runtime impact `UNVERIFIED` (no Godot run) |
| D6 | Port omits the donor's `if dirY<0 then vecangle := -vecangle` fold. `_cliff_tile_for` mirrors it (`game.gd:1239–1240`) but `_shore_tile_for` computes `atan2(dy,dx)+180` directly at `game.gd:1210`. Half the shoreline can be mirrored. | `game.gd:1210` vs `game.gd:1239–1240` | `texturemap.inc:445–447` | `derived`; `UNVERIFIED` without a render |
| D7 | Edge is grid-aligned: the coverage grid has `N=CHUNK_T+1=33` nodes over a 32-tile chunk; each node counts a 2×2 cell neighbourhood and is bilinearly upscaled (`_alpha_mask`). The tan→grass/water transition is one **tile** wide (8–64 px depending on preset) and follows tile row/column edges → stair-step, not the donor's ≤3 px abrupt rim. | `world.gd:25`, `:909–916`, `:1016–1040`, `:877–880` | `TERRAIN_REFERENCE_IMAGES.md §3.3` ("abrupt, not a smooth gradient", ≤3 px) | `derived` |
| D8 | Water overlay coverage is `1.0` only where `terrain==3`; after D2 the sand collar has `terrain==4`, so `coverage=0` there and the shader discards (`shader:48`). No wash/foam on the collar. | `world.gd:829–837`, `shader:45–48,77–89` | donor gate paints sandsea on masked water cells | `derived` |

`inferred` summary: D1+D2 set the band width, D3+D4 make it read as one flat tan value, D5+D6 mis-orient the ripple art, D7+D8 remove the fine edge and the wash. Together they produce the reported "wide flat tan ring with a stair-step edge" — a **placement/compositing** defect, not an asset defect (§1.1 pixel identity).

---

## 3. Machine-readable spec

```json
{
  "name": "shore_sand",
  "size_px": [512, 512],
  "seed": 7,
  "layers": [
    {"type": "block", "name": "sandsea3", "tile": true, "role": "wet_sand",
     "sectors": 8, "sector_deg": 45, "angle_offset_deg": 180, "dy_fold": true},
    {"type": "water", "mode": "shallow", "opacity": 0.35,
     "coast_fade": 0.57, "deep_fade": 1.07}
  ],
  "params": {
    "orientation": {
      "sectors": 8,
      "sector_deg": 45,
      "active_tiles": ["sandsea1", "sandsea5", "sandsea6"],
      "sector_tile_map": {
        "bR": "sandsea6", "bRB": "sandsea6", "bB": "sandsea1",
        "bLB": "sandsea5", "bL": "sandsea6", "bLT": "sandsea6",
        "bT": "sandsea1", "bRT": "sandsea5"
      },
      "height_gate": {"mask_b_gt": 0, "water_h": -0.25, "shore_h": -0.1}
    },
    "band_px": {
      "sand": [26, 51],
      "wash": [30, 50],
      "edge_gradient": [3, 8],
      "near_water_fraction": [0.05, 0.10]
    },
    "thresholds": {
      "donor_water": -0.25,
      "donor_wet_sand": -0.1,
      "port_current_sand": -0.05
    },
    "shallow_water_opacity": 0.35,
    "distinct_tiles": 3
  },
  "reference": {
    "donor_texture_dir": "C:/Games/Cossacks 3/data/terrain/tiles/textures",
    "donor_script": "C:/Games/Cossacks 3/data/scripts/common.inc/texturemap.inc:474-529",
    "images": [
      {"file": "maxresdefault_1.jpg", "src_px": [300,150,512,288],
       "sand_profile_px": [320,380], "wash_profile_px": [380,420]},
      {"file": "articolo-787.jpg", "src_px": [600,0,960,50]}
    ],
    "palette": {
      "sand_lit": "#A89E7F",
      "wash_lit": "#B9BAA7",
      "water_shallow_lit": "#696B65",
      "water_dark_lit": "#3A4246",
      "tile_unlit_sandsea1": "#807856",
      "tile_unlit_sandsea5": "#7B7252",
      "tile_unlit_sandsea6": "#7D7456"
    },
    "prior": [
      "docs/audit/TERRAIN_DONOR_PIPELINE.md:3.3",
      "docs/audit/TERRAIN_DONOR_ASSETS.md:3.2",
      "docs/audit/TERRAIN_REFERENCE_IMAGES.md:3.4"
    ]
  }
}
```

`observed` caveat on the spec: `sandsea3` is the requested canonical block name, but the **live donor table never selects `sandsea3`** (§1.2) — a strict-fidelity piece must use `sandsea1/5/6`; `sandsea3` is retained in the spec as the named representative and is donor-identical to `sandsea4` (`#817856`). `derived`: `opacity: 0.35` is the shallow end of `water_overlay.gdshader:88`; band numbers are 5–10% of 512 px (26–51 px) per `TERRAIN_REFERENCE_IMAGES.md §3.4` and rank-8 criterion. Angle/band values are inputs to the recipe, not measured from a rendered piece (that render is out of scope: no Godot run).

### Exact change list (ordered; no code changed by this agent)
1. `game.gd:780–781` — replace `hh < -0.05` with `hh < C3MapGen.WATER_SHORE` (`-0.1`) so the wet-sand band is 0.15 units, not 0.20 (D1).
2. `game.gd:785–813` — stop converting the outer water ring to `terrain=4`. Keep those cells as water (`terrain=3`, leave `blocked` as water) and let `_apply_shore_cliffs()` assign the `sandsea*` **tile block** on them, mirroring donor D4:463–472 (D2/D8). Shallow water then keeps `coverage=1` and the wash renders.
3. `game.gd:1164–1165` — for role 4 use a wet-sand block (`sandsea6` or `sand3`), not `sand1/sand2/sand7` (D3).
4. `game.gd:1210–1226` — implement the donor sector exactly: add the `dirY<0 → ang=-ang` fold (D4:445–447), keep `+180` (D4:476), use `bR = ang < 22.5` only and let the final `else` take `[292.5,360)` as `bRT` (D5/D6).
5. `world.gd:1102–1103` — raise the role-4 sandsea contribution (e.g. `max_alpha ≥ 0.9`, `falloff = 1.0`) so the donor grain (std 11–14) is visible; keep `sandsea*` out of the chunk-wide base only if the role mask fully covers the band (D4).
6. `world.gd:909–916,1016–1040` — make the shore edge sub-tile: sample coverage at pixel resolution from the height/shore field rather than a 33-node 2×2 tile grid; target a 3–8 px tan→wash gradient and ≤4 px boundary drift per 64 px run (D7).

---

## 4. Measurable criteria from a PNG

All metrics below are computable with Pillow on a rendered/synthesised 512×512 shore piece; none require a Godot run to define. `observed` = measured on donor/reference already; `target` = acceptance for the port piece.

| # | Metric | Target | How to measure from the PNG | Status |
|---|---|---|---|---|
| M1 | Sand band width | **26–51 px** (5–10% of 512); reference profile showed 40–60 px at 512×288 | Along a shore-normal profile, count px from dry-grass hue (`R≈G>B`, `#6B6732`-ish) to pale wash (`R≈G≈B`, ≥`#B9BAA7`) | `observed` reference / `target` port |
| M2 | Distinct tile textures | **3** (`sandsea1`, `sandsea5`, `sandsea6`); port must not use 6, and must not use 0 | Cluster mean RGB/std of 32×32 cells in the sand band; donor signatures `#807856`, `#7B7252`, `#7D7456` with std 11–14; count distinct clusters at ΔE>4 | `derived` from D4:503–511 |
| M3 | Edge gradient width (tan→wash) | **3–8 px** (10%–90% luminance transition); no 1-tile (8–64 px) grid ramp | Perpendicular 1-px profile, count px between 10% and 90% of the tan→pale luminance step | `inferred` from donor abrupt-edge rule + reference wash |
| M4 | Stair-step | Boundary x-deviation **≤4 px** per 64 px run | Trace the sand/water boundary along 8 parallel scanlines; max lateral jump between adjacent rows | `derived` for port grid mask (D7) |
| M5 | Wet-sand colour | Mean in `#7B7252`–`#807856` ±8 RGB (unlit texture space); lit frame `#A89E7F` ±12 | Mean of the sand-band mask; compare to §1.1 donor means | `observed` |
| M6 | Grain retained | Sand-band std **≥9 RGB levels** (donor std 11–14) | Std of the sand-band mask; current role-4 alpha 0.55/gamma 1.7 predicts ~4–7 → fail | `derived` |
| M7 | Wash band present | 30–50 px pale band (`#B9BAA7`→`#BBC4BB`) between sand and water | Count px where `|R-G|≤12`, `G≥B`, and luminance > sand luminance +12 | `observed` reference |
| M8 | Shallow water opacity | 0.35 at the shoreline end; foam confined to `band=coastfade*(1-coastfade2)` | Sample overlap strip alpha against `shader:88`; check foam pixels only in coast band | `derived` from shader |

`UNVERIFIED`: M3–M8 have not been run against a port render — this lane does not start Godot. They are acceptance definitions for the build lane.

---

## 5. Claim table

| # | Claim | Evidence | Method | Verdict | Required correction / caveat |
|---|---|---|---|---|---|
| C1 | Donor has 6 sandsea DDS; port has 6 pixel-identical PNG; wet-sand art is fine | `data/.../sandsea1..6.dds`; `blocks/sandsea1..6.png`; `ImageChops.difference` bbox `None` for 1/5/6 | Pillow bytes + diff | **observed** | Do not re-convert or "improve" the sandsea art. Donor alpha is 255; alpha drop is harmless here. |
| C2 | The wet-sand tiles are uniform tan (std 11–14) with no baked water band; orientation selects grain direction | DDS means/std + 8-band vertical profiles (§1.1) | Pillow full/edge/band means | **observed** | Any spec expecting a dark water strip inside `sandseaN` is wrong; the wash comes from the water shader. |
| C3 | The active donor table uses 8×45° sectors and exactly 3 tiles: `sandsea1/5/6` | `texturemap.inc:474`, `:479–511`; `TERRAIN_DONOR_PIPELINE.md §3.3` | Literal code read + cross-check | **observed** | `sandsea2/3/4` are commented-out alternatives. Spec keeps `sandsea3` as named representative (§3 caveat); strict fidelity uses 1/5/6. |
| C4 | Donor gates wet sandsea on mask-B water + height `< -0.25`/`< -0.1` and paints it **on water cells** | `texturemap.inc:463–472`, `:512–529`; constants `:30–31` | Literal code read | **observed** | Port must not turn the wet ring into walkable land (D2). |
| C5 | Port sand band threshold is `-0.05`, 0.20 units wide vs donor 0.15 (+33%) | `game.gd:780–781` vs `texturemap.inc:31` | Code read + arithmetic | **derived** | Change to `WATER_SHORE` (change 1). |
| C6 | Port flips the whole outer 8-neighbour water ring to sand, deleting the shallow-water wash cells | `game.gd:789–813`; `world.gd:829–837`; `shader:45–48` | Code-path trace | **derived** | Keep those cells as water; assign sandsea tile block only (change 2). |
| C7 | Role-4 compositing at `max_alpha=0.55`, `falloff=1.7` suppresses sandsea grain | `world.gd:1084–1088`, `:1102–1103`; donor std §1.1 | Alpha arithmetic vs donor std | **derived** (render effect `inferred`) | Raise alpha to ≥0.9, falloff 1.0 (change 5); verify M6. |
| C8 | Port sector windows are not uniform 45°: `bR=67.5°`, `bRT=22.5°` | `game.gd:1212–1226` | Inequality arithmetic | **derived** (runtime impact `UNVERIFIED`) | Mirror donor sectors; `bR` is only `[0,22.5)` (change 4). |
| C9 | Port omits the donor `dirY<0` angle fold in `_shore_tile_for` (present in `_cliff_tile_for`) | `game.gd:1210` vs `game.gd:1239–1240`; `texturemap.inc:445–447` | Side-by-side code read | **derived** (`UNVERIFIED` render effect) | Add fold (change 4). `_cliff_tile_for` already shows the intended pattern. |
| C10 | Shore edge is a 1-tile grid ramp (8–64 px) → stair-step | `world.gd:25`, `:909–916`, `:1016–1040`, `:877–880` | Grid size / chunk-size arithmetic | **derived** | Sub-tile coverage (change 6); target M3/M4. |
| C11 | Reference shore is sand `#A89E7F` → wash `#B9BAA7` → shallow `#696B65` (~5–10% near water) | `maxresdefault_1.jpg` profile; `TERRAIN_REFERENCE_IMAGES.md:49,58,127` | Pillow 20 px profile + prior crop | **observed** (colour) / `inferred` (area); shallow colour **LOW confidence** | Use band widths 26–51 / 30–50 px; do not treat `#696B65` as exact (mixed crop). |
| C12 | No donor foam texture exists; wash is shader + sandsea | `TERRAIN_DONOR_ASSETS.md:6/C1`; `water.lib` constants | Recursive filename search (prior doc) | **observed** (prior) | Do not invent a foam family; use `shader:77–85` band. |
| C13 | "The wide flat tan ring was already fixed by TB-B1e" | `world.gd:1081–1083` | Code read | **REFUTED / partial** — comment records a mitigation, but D1/D2/D4/D7/D8 remain | Treat the ring as still open; use §4 metrics, not the comment, as the gate. |
| C14 | Port block conversion fidelity for sandsea is not the problem | pixel identity + identical means | `ImageChops` + Pillow means | **observed** | Close any "reconvert sandsea" ticket. |
| C15 | Rendered port shore matches the donor (visual gate passed) | — | Would require a Godot render | **UNVERIFIED** | This lane forbids Godot; build lane must run M1–M8 before claiming done. |

---

## 6. Open questions / unknowns

1. `VectorAngle(1,0,0,dirX,0,dirY)`'s exact return range in the donor scripting language is not in the plaintext; the `+180` at D4:476 and the final `else` imply a wrap handled implicitly (§1.2). The 45° mis-assignment (C8) is derived from the port's explicit inequalities; a donor replay fixture would settle the wrap exactly.
2. Whether the `dirY<0` fold (C9) was a deliberate port simplification or an oversight — `UNVERIFIED` without a renderer; `_cliff_tile_for` suggests oversight.
3. Lit-to-unlit colour gain: donor tile `#807856` vs lit reference `#A89E7F` differ by ~1.3× brightness. No tone-map/camera params were available; use texture-space targets for PNG acceptance, lit colours for visual comparison only.
4. M3–M8 have not been executed on a port frame (no Godot run permitted here). M1's 5–10% is a visual area estimate from the prior doc, not a threshold-classified measurement.
5. The `sandsea3` name in the requested spec conflicts with the donor's active 1/5/6 table (C3). Owner decision needed: strict fidelity → change spec name to `sandsea1`; otherwise document `sandsea3` as a representative swatch.

---

## Files changed

- `docs/audit/PIECES/shore_sand.md` — **new; the only file written by this agent.** No donor asset copied; no Godot process started; no `app/` file modified. Pillow samples live only in `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\`.

*End of T2-PIECE-SHORE-SAND research.*
