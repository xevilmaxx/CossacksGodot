# TERRAIN_CHECKERBOARD_TRIAGE.md — T4-REGRESSION

Read-only audit. No code edits, no Godot runs. Date 2026-11-21.

## 0. Verdict (TL;DR — actionable)

The checkerboard ground was introduced by **one code change**, applied in two stages:

1. **Coarse blotch/grid** — commit `89f1fd3` (2026-11-21 16:45 +0100), the
   T2-BUILD-RENDER change #3 "Terrain-driven grass gain" documented at
   `docs/audit/T2RENDER_REPORT.md:18`. It replaced the dead 80×80 gain map with a
   signed ±luminance field (`_gain_at`, 128-tile mirror fold) and added
   `_grass_gain()` to composite olive light/dark patches over every land tile.
2. **Fine "total checkerboard mess"** — commit `a405246` (HEAD, 2026-11-21
   17:51 +0100), the T3-FIX-WORLD hard-grain layer: `GRASS_HARD_LEVELS/DITHER/
   SPT/TILES`, `grass_hard_tex`, `_build_grass_hard_tex()`, and a NEAREST-upscaled
   quantised crop inside `_grass_gain()`. This is the current file.

**Minimal revert target:** keep the entire file, delete ONLY the gain call sites
and the gain block in `app/scripts/world.gd`. Concretely:
- remove lines **1601–1604** (winter guard + `_grass_gain(...)` call) — keep 1605
  `_face_collar(...)`;
- remove line **1037** (`_build_grass_hard_tex()`);
- remove lines **595–701** (`gain_map`, GRASS_* constants, `_gain_at`,
  `_build_grass_hard_tex`, `_grass_gain`), keeping `var decal_tex` at 594 and
  `var blob_tex` at 703.

That restores the ground to the clean `terrain_land_frame2.png` state while
keeping water shader, mine sprite, field decal, winter tiles and the no-hole
fallback. **Do not `git revert` commits `89f1fd3` or `a405246`** — each contains
good fixes in the same diff (mine+field in `89f1fd3`, fallback+winter in
`a405246`); a whole-commit revert loses them.

If a file-level restore is demanded instead, the last backup with **no** patch
gain is `inbox/backup/world.gd.bak-T2RENDER` (14:24, 115,743 B) — but restoring
it wholesale loses mine sprite, field decal, winter tiles and the no-hole
fallback. Surgical removal above is the correct target.

---

## 1. Sources

| Ref | Path | Use |
|---|---|---|
| S1 | `app/scripts/world.gd` (141,466 B, mtime 17:31; HEAD `a405246`) | current gain implementation + all call sites |
| S2 | `inbox/backup/world.gd.bak-*` (11 backups, table §2) | change chronology |
| S3 | `docs/audit/T2RENDER_REPORT.md` (written 16:07) | **names change #3 and its exact lines** |
| S4 | `app/shots/t2render_land.png`, `t3world_land.png`, `terrain_land.png`, `terrain_land_frame2.png`, `terrain_sample_clean.png` | visual evidence |
| S5 | `docs/audit/TERRAIN_DONOR_PIPELINE.md` (§5g, §10, §6 Q4) | donor SmoothTiles / `tilesmooth_scripts.cfg` evidence |
| S6 | `app/scripts/game.gd:1323–1417, 1294, 1556–1589, 1113–1121` | per-cell TileBlock data the port already has |
| S7 | `git log -S` pickaxe on `app/scripts/world.gd` | exact introducing commits |
| S8 | in-memory Pillow/numpy L-statistics on S4 (no files written) | quantitative backing |

---

## 2. Chronological backup table

All `gain_map` entries below are the **old dead 80×80 map** (`0.085 * _wnoise(x*0.44)`,
never called by any draw path) unless stated otherwise. `gain_map` itself is
therefore *not* the regression — it predates everything and is inert.

| # | Backup | mtime | Bytes | Gain state | Ground verdict |
|---|---|---|---|---|---|
| 1 | `world.gd.bak-agentAB` | 07:08:54 | 80,843 | dead 80×80 only; no `_grass_gain` | clean (no synthetic gain) |
| 2 | `world.gd.bak-implrender` | 07:27:52 | 81,093 | same | clean |
| 3 | `world.gd.bak-implrender-sco` | 08:48:57 | 83,914 | same | clean |
| 4 | `world.gd.bak-PORT-VIS` | 09:40:47 | 85,128 | same | clean |
| 5 | `world.gd.bak-RENDER-1` | 11:33:20 | 92,727 | same | clean |
| 6 | `world.gd.bak-RENDER-1-water` | 12:07:28 | 96,111 | same | clean — matches `terrain_sample_clean.png` (12:06) |
| 7 | `world.gd.bak-RENDER-1-decor` | 12:14:53 | 99,778 | same | clean |
| 8 | `world.gd.bak-RENDER-1-understory` | 12:53:45 | 113,948 | same | clean |
| 9 | `world.gd.bak-T2W` | 13:31:44 | 114,952 | same | **clean — closest backup to `terrain_land_frame2.png` (13:04)** |
| 10 | `world.gd.bak-T2RENDER` | 14:24:42 | 115,743 | same; S3:9 says taken "immediately before any edit" | last clean backup WITH water shader; no mine/field yet |
| 11 | `world.gd.bak-T3W` | 16:01:41 | 132,744 | **SOFT gain added**: 128×128 mirror-folded field, `_grass_gain` at 629–652, `GRASS_PATCH_HARD_RIM=false`, bilinear, call at 1470 | **first checkerboard state** (= commit `89f1fd3`) |
| — | current `world.gd` / HEAD `a405246` | 17:31:05 | 141,466 | **HARD gain added**: `GRASS_HARD_LEVELS/DITHER/SPT/TILES`, `grass_hard_tex`, NEAREST crop; call 1604, builder call 1037 | **fine checkerboard mess** |

Git pickaxe (S7): `func _grass_gain` first appears in `89f1fd3`; `GRASS_HARD_LEVELS`
first appears in `a405246`; `GRASS_PATCH_HARD_RIM` enters in `89f1fd3` and is
removed in `a405246`. Commit body messages are only "step", so the audit docs +
backups are the primary evidence, not the messages.

---

## 3. Screenshot evidence — GROUND ONLY

Visual descriptions deliberately ignore trees, units, buildings, HUD and water
(the regular blue/white striping in `terrain_sample_clean.png` is the water
shader/bayer overlay, **out of scope**).

| Screenshot | mtime | Ground appearance |
|---|---|---|
| `terrain_sample_clean.png` | 12:06 | Natural olive-green meadow with fine, non-periodic grain and irregular dirt/rock patches. No tile or grid repeat in the grass. |
| `terrain_land_frame2.png` | 13:04 | **Last visually decent ground.** Smooth natural grass, dark green mottling, dirt aprons with stair-step (cell-quantised) edges but **no repeating blotch lattice**. |
| `t2render_land.png` | 15:20 | **Earliest screenshot where the pattern appears.** Large ~100–150 px square patches of alternating light-green/dark-green/light-tan form a coarse, axis-aligned checkerboard across the whole ground, including under the church and fields. This is the T2 soft ±gain field. |
| `terrain_land.png` | 16:33 | Same coarse square-patch lattice as `t2render_land.png`, slightly softer; not a clean "before" despite S3:60 using that filename as the before-capture (timestamp/overwrite inconsistency — flagged, not relied on). |
| `t3world_land.png` | 17:35 | Ground is a dense, high-frequency checkerboard of small (tile-scale) green/yellow/olive squares superimposed on the coarse blotches. This is the T3 hard-grain/quantised layer. "Total checkerboard mess." |

Quantitative backing (S8, ground-only crops, luminance):

| Image | L std | block-mean variance fraction @16 px / @64 px |
|---|---|---|
| `terrain_sample_clean.png` | 5.2 | 0.437 / 0.177 |
| `terrain_land_frame2.png` | 11.1 | 0.722 / 0.413 |
| `t2render_land.png` | 21.5 | 0.506 / 0.154 |
| `terrain_land.png` | 19.7 | 0.749 / 0.261 |
| `t3world_land.png` | 20.2 | 0.760 / 0.230 |

Ground contrast roughly doubles at the regression (11.1 → 19.7–21.5 L std),
consistent with S3:60's full-frame 24.0 → 31.1. `t3world_land.png` has the
highest 16 px block-mean fraction (0.760): energy has moved to the **tile
frequency**, which is exactly the fine checker seen visually. S3:62–63's claim
"No checkerboard: patch field is bilinear and mirror-folded with 128-tile
period" is contradicted by both the image and the numbers.

---

## 4. The exact change

`docs/audit/T2RENDER_REPORT.md:18`, change #3:

> Terrain-driven grass gain: dead `_gain_at()` replaced with a mirror-folded
> signed ±gain field (128-tile period, 20–80 px patches); `_grass_gain()`
> composites olive light/dark patch overlays; `GRASS_PATCH_HARD_RIM` option;
> relief shade ceiling 0.20→0.14 — **final lines 598–657, 1470**.

Those line numbers are the `89f1fd3` / `world.gd.bak-T3W` numbering. In the
current file the same code has shifted to **595–701** and the bake call to
**1604**, with the T3 hard-grain additions intermingled. The accompanying
relief-shade ceiling change is `world.gd:1631` (`clampf(..., 0.0, 0.14)`); it is
a darkening clamp, **not** a pattern source — leave it alone.

The patch grid is *synthetic*: it is not read from `game.tileblock`, the donor
detail bitmaps, or any donor asset. It is a value-noise luminance field invented
in `world.gd` and composited over the already-correct donor tile art.

---

## 5. Minimal revert plan (actionable)

File: `app/scripts/world.gd` (only file to touch).

1. **Bake call** — delete lines **1601–1604**:
   ```
   # T3-FIX-WORLD: winter*.png already carry snow grain; ...
   if not _winter_on():
   	_grass_gain(img, cx, cy, S, N)
   ```
   Keep line 1605 `_face_collar(img, cx, cy, S)` (unrelated ravine fix). Keep the
   format conversion at 1599–1600 if other code needs it, or remove it too — it
   is harmless either way (no gain to blend).
2. **Setup call** — delete line **1037** `_build_grass_hard_tex()` (inside
   `_build_masks`, before `return []`). No other caller.
3. **Dead gain block** — delete lines **595–701** (from `var gain_map:` through
   the end of `_grass_gain`). This removes `GRASS_HARD_LEVELS`,
   `GRASS_HARD_DITHER`, `GRASS_HARD_TILES`, `GRASS_HARD_SPT`, `grass_hard_tex`,
   `GRASS_PATCH_DARK/LIGHT`, `_gain_at`, `_build_grass_hard_tex`, `_grass_gain`.
   Keep 594 `var decal_tex` and 703 `var blob_tex`.

Alternatively, if a reviewer wants a byte-identical "known-good" gain scaffold,
replace 595–701 with the inert stub from `inbox/backup/world.gd.bak-T2W:584–597`
(the 80×80, ±8.5 % map that no draw path calls). Functionally identical to
deleting it.

**Preserved by construction** (all outside 595–701 / 1037 / 1601–1604):
water shader `_setup_water_overlay` (908–964) + `water_overlay.gdshader`; mine
sprite `_draw_mine` (2501) and `mine_sid` path (2242–2247, 2826); field decal
`_field_decal` (2063–2072, 2092); winter tiles `_winter_on`/`_winter_art`
(1096–1128) and `game.winter_tile_names`; no-hole fallback `fallback_tex`/
`fallback_chunks` (31–32, 1654–1666, 1743–1751).

**Verification gate after revert (no run performed here):** re-capture
`terrain_land.json` and confirm ground L std returns toward the 11–14 band and
that no 16 px / 128 px block lattice is visible; confirm the five fixes above
still appear in their own captures.

---

## 6. Mechanism — why a synthetic gain grid becomes a checkerboard

Constants that set the frequency: `CHUNK_T = 32` tiles/chunk (`world.gd:25`),
`terrain_px = 16` px/tile (`:40`), `S = 32*16 = 512` bake px, `N = CHUNK_T+1 = 33`
(`:1515, :1524`).

1. **Tile-frequency sampling / aliasing.** `_gain_at` samples `gain_map` with
   `posmod(int(floor(tx)),128)` — one constant value per whole tile — then
   `_grass_gain` resizes the 33×33 tile grid to 512×512 (`:684–685`). The current
   noise octaves are `1.05` and `2.55` cycles per tile (`:625–626`). Sampling at
   exactly 1 sample/tile is at/below Nyquist for 1.05 c/tile and far beyond it
   for 2.55 c/tile; both alias into a near-alternating sign per tile. Bilinear
   resampling then paints a tile-aligned lattice of bright/dark squares → the
   fine checker in `t3world_land.png`. The T2 version used 0.62/1.60 c/tile
   (T3W backup `:616–617`), which aliases more gently into the coarse ~100 px
   blotches of `t2render_land.png`.
2. **Hard rim = square quantisation cells.** `_build_grass_hard_tex` resizes the
   128-tile map to `64*4 = 256` px (`:642–644`), i.e. 4 samples/tile, then
   quantises to 7 levels with dither `(x*7+y*11)%5` (`:649–652`) and paints
   olive/dark RGB with `alpha ∝ |q|` (`:653–658`). `_grass_gain` crops a
   `32*4 = 128` px window and **NEAREST**-upscales it 4× to 512 (`:694–699`).
   Nearest replication turns every 1/4-tile sample into a hard 4 px square;
   quantisation makes neighbouring samples share the same level, producing
   large flat square contours rather than organic patches. That is the "hard
   rim" the comment advertises — visually it is a minecraft-style grid.
3. **Mirror folding locks the repeat to the chunk grid.** `gain_map` folds at
   64 in a 128 grid (`:621–622`) → period 128 tiles = **4 chunks**. The hard tex
   is 64 tiles = **2 chunks** wide; `ox = posmod(cx*128, 256)` (`:696`) gives
   `ox = 0` for even chunks and `128` for odd chunks (same for `oy`). Adjacent
   chunks therefore sample mirrored halves of the same field, so their patch
   patterns line up as mirror pairs at every 2-chunk boundary. A 2-chunk period
   plus a 1-tile period is the textbook checkerboard beat.
4. **Per-tile on/off mask.** `on = 1.0 if t not in (3,4,5)` (`:673–676`) is
   itself cell-quantised, so gain starts/stops on tile edges near shore/road —
   hard square boundaries again, independent of the smooth donor alpha masks.
5. **Off-by-one seam.** `N = CHUNK_T+1 = 33` loops `gx = 0..32` while a chunk is
   32 tiles (`:664–671`); the extra row/column is resampled to 512, giving a
   half-tile phase shift at chunk joins and reinforcing the lattice.

**Why the donor does not do this.** The donor never synthesizes luminance
patches. It assigns each cell a **TileBlock** from donor art, resolves
neighbour compatibility, and lets the authored PNG grain supply the mottling.
The port's `_grass_gain` overlays a second, unrelated tonal field on top of art
that already contains the donor's patch spectrum; the two grids (synthetic
noise vs tile/chunk grid) beat against each other. S3:82–85 already admits the
patch endpoints were pushed *outside* the donor hex range
(`#3E411F`–`#6B6732`) to chase a luminance-std target — a numeric fit to a
statistic, not a visual/donor-faithful method.

---

## 7. Donor-faithful replacement spec

### 7.1 Data the port already has (no new generation needed)

- `game.tileblock` — `MAP_W*MAP_H` integer indices into `game.tbl_names`,
  assigned per cell by `_assign_tileblocks()` (`game.gd:1323–1411`): uniform
  `grass1` donor base (like donor `SetTileIndex(x,y,0)`), donor road mix
  `ground1/test2/test3`, oriented shore+cliff blocks (`_apply_shore_cliffs`),
  **3-pass horizontal+vertical compatibility smoothing** (`_smooth_tilemap(brng,3)`
  at `:1395`, implemented `:1582–1589`, with `_tb_smooth_pair` `:1556–1580`),
  donor detail-bitmap variety from `tile_low/highground` (`_apply_detail_pass`
  `:1294`), forest-border stamps (`:1591–1603`) and mine apron override.
- `game.winter_tile_names` (`:1190`, filled `:1415+`) and
  `game.winter_block_for()` (`:1193`) — per-cell winter art names.
- `game.tbl_names` — TileBlock name → art mapping; `game.terrain`, `game.height`,
  `mine_mask`, field/role data for the role passes.
- Renderer side: `_art_name(ti)` (`world.gd:1113–1121`) already resolves a tile
  index to the correct summer or winter block name; `_block_img()` +
  `_wrap_crop()` + the 33×33 feather `_alpha_mask()` already composite each
  distinct block's real PNG into the chunk (`world.gd:1517–1593`).

### 7.2 What a correct renderer consumes

**Only** the per-cell TileBlock name (summer/winter), its converted donor PNG,
and the donor-authored alpha feather/smooth masks. Concretely:
- keep `world.gd:1517–1593` (per-block compositing) and `:1113–1128`
  (name resolution) exactly as-is;
- keep `game.gd:_assign_tileblocks` as the single source of patch variety — the
  donor detail pass plus `SmoothTileMap` is where meadow mottling and neighbour
  compatibility belong;
- **delete the synthetic gain path entirely** (§5). Do not replace it with
  another luminance/noise field, another dither/quantiser, or a different
  frequency — any such field is re-introduced grid energy at a frequency that
  will beat against the 32-tile chunk / 16 px tile grid;
- if more tonal variation is genuinely needed, change the *data*: adjust
  `_apply_detail_pass()` selection from `tile_low/highground` or the donor
  `Freq` weights, then re-run the 3 compatibility passes. That keeps seams and
  patch spectrum donor-consistent.

### 7.3 Caveats / open items

- `docs/audit/TERRAIN_DONOR_PIPELINE.md:78, :355` says the port has "no
  equivalent compatibility pass" and targets `game.gd:1011`. That document was
  written 11:54, **before** the current `game.gd` gained `_smooth_tilemap(brng,3)`
  at `:1395`/`:1582`. The doc is stale on this point; the pass exists (derived
  from code, not from the doc).
- The donor's actual `tilesmooth_scripts.cfg` compatibility tables (`TileNames`/
  `Prob`, D5:44–57) were **not read** — `TERRAIN_DONOR_PIPELINE.md:413–416`
  lists this as open question 4. The port's `_tb_smooth_pair` is a proxy; exact
  donor weights remain **unknown**. Do not claim bit-exact donor smoothing.
- No Godot run was performed in this audit; all visual/verdict statements are
  from reading committed screenshots and code.

---

## 8. Claim table

| ID | Claim | Status | Evidence |
|---|---|---|---|
| C1 | Old `gain_map` (80×80, ±8.5 %) is dead code in every backup ≤ `T2RENDER` | observed | grep `_gain_at(` — definition only, zero callers in agentAB…T2RENDER |
| C2 | `_grass_gain` first appears in `world.gd.bak-T3W` / commit `89f1fd3` | observed | backup grep; `git log -S"func _grass_gain"` |
| C3 | Hard-grain layer first appears in HEAD `a405246` | observed | `git log -S"GRASS_HARD_LEVELS"`; `world.gd:603–607, 635–658` |
| C4 | Exact introducing change is T2RENDER change #3 at 598–657/1470 | observed | `docs/audit/T2RENDER_REPORT.md:18` |
| C5 | Cleanest ground is `terrain_land_frame2.png` (13:04) | observed | visual + L std 11.1 |
| C6 | First grid/blotch ground screenshot is `t2render_land.png` (15:20) | observed | visual + L std 21.5; earlier two screenshots clean |
| C7 | Current `t3world_land.png` has tile-frequency checkerboard | observed | visual + highest 16 px block-mean fraction 0.760 |
| C8 | S3:62–63 "No checkerboard" claim is wrong | derived | C6/C7 contradict it |
| C9 | Mirror fold + 4 samples/tile + NEAREST + quantisation cause the beat pattern | derived | `world.gd:621–626, 642–658, 694–699`; geometry in §6 |
| C10 | 1.05/2.55 c/tile sampled at 1 sample/tile aliases | derived | Nyquist argument with `CHUNK_T=32`, `N=33`, `S=512` |
| C11 | Port has per-cell TileBlocks + 3-pass smoothing + winter names | observed | `game.gd:1323–1417, 1582–1589, 1190–1197`; `world.gd:1113–1121` |
| C12 | Doc's "no compatibility pass" statement is stale | derived | doc 11:54 vs code call at `game.gd:1395` |
| C13 | Surgical removal preserves all five good fixes | derived | call sites outside 595–701 / 1037 / 1601–1604 (§5) |
| C14 | Whole-commit revert loses mine/field (89f1fd3) or fallback/winter (a405246) | observed | per-commit marker counts: 89f1fd3 field=4/mine=3; a405246 fallback=7 |
| C15 | `terrain_land.png` is labelled "before" in S3:60 yet shows the grid | observed | timestamp 16:33 + visual; treated as overwrite/inconsistency |
| C16 | Donor `tilesmooth_scripts.cfg` exact weights unknown | observed | `TERRAIN_DONOR_PIPELINE.md:413–416` |
| C17 | Donor uses compatibility smoothing, not luminance gain | observed | `TERRAIN_DONOR_PIPELINE.md:33, 78, 124, 242, 261` (D5/D2 reads) |

**Bottom line:** remove the `_grass_gain` call at `world.gd:1604` (and its setup
call at 1037, and the dead block 595–701). That is the rollback target. Anything
beyond that risks losing good fixes or re-introducing grid energy.
