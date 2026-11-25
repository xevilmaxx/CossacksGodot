---
id: DALPHA-01
task: "Resolve the donor cell→alpha sub-rect mapping (last UNVERIFIED terrain-shader blocker)"
date: 2026-11-25
status: DELIVERED__AUDIT_ONLY__NO_DONOR_EXECUTED__NO_DONOR_COPIED
scope: "One report file only. No code, asset, config, test, git or runner change. Donor inspected READ-ONLY with Python bytes/latin-1, struct, Pillow/numpy and Craft Anything read-only native_bytes_find."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor: "C:\\Games\\Cossacks 3 (READ-ONLY. No donor binary executed, copied or modified.)"
output: "docs/coord_swarm_2026-11-25/reports/DALPHA_01_alpha_subrect.md"
labels: [observed, derived, inferred, UNVERIFIED]
verdicts:
  atlas_grid_geometry: RESOLVED
  full_tile_override_inventory: RESOLVED
  complement_pair_structure: PARTIAL
  boundary_direction_to_row: PARTIAL
  tile_id_and_boundary_to_patch_index_rule: CONFIRMED_UNVERIFIED
independent_passes: 3
double_verified: [atlas_grid, override_inventory, complement_search, byte_absence]
visual_parity_claim: false
---

# DALPHA-01 — Donor cell→alpha sub-rect mapping

## 0. Goal

Resolve, or prove unresolvable, the donor rule that maps a terrain cell (tile id) plus a
boundary direction to an alpha-atlas patch in `data\terrain\tiles\textures\alpha.bmp`.
`RV-TRN-01` confirmed the 8×4 grid of 64² organic masks but left the **tile→patch index
rule UNVERIFIED**; `DTRN-01` M4 called the port mapping "invented". `TRN-SHADER` is
implementing a deterministic approximation and needs either donor truth or explicit
APPROX guidance.

Three independent passes were required and performed:

1. **Pass A — config semantics.** Custom section parser over **all 909 lines** of
   `tiles.lib` and **all 1,019 lines** of `tiles.mat`, plus `reftile.lib`, `reftile.mat`,
   `reftilealpha.mat`, `terrain.presets`, and the ground vertex/fragment shaders.
2. **Pass B — pixel forensics.** Two independent BMP decoders (a hand-written
   BITMAPINFOHEADER/palette decoder and Pillow 12.1.1 + NumPy 2.4.3) over `alpha.bmp`,
   `alphavert.bmp`, `alphanull.bmp`: all 32 patch rectangles, seam deltas, edge profiles,
   complement search in **both intensity and raw palette-index space**, transform search
   (h/v/hv/transpose).
3. **Pass C — byte evidence.** Python `bytes.find()` over raw ASCII + UTF-16LE + UTF-16BE
   in 11 donor binaries and a recursive case-insensitive scan of 17,237 files (4,506
   text files), cross-checked with Craft Anything **raw-byte** `native_bytes_find`
   (not its string indexer — see RV-TRN-01 §2 warning).

Every number below is tagged **observed** (literal byte/pixel), **derived** (arithmetic
or measurement on observed bytes), **inferred** (interpretation with caveat), or
**UNVERIFIED**. Key claims were verified twice with different implementations.

---

## 1. Sources

### Prior reports read
| Report | What was taken from it |
|---|---|
| `DTRN_01_donor_terrain_pipeline.md` C7, C17, M4, §9 Q4 | atlas defaults, `bmTransparency`/`Texture2Name=alpha`, M4 "invented sub-rect" |
| `RV_TRN_01_texgen_mask_reverify.md` §3–§8 | 8×4 grid already empirically confirmed; verdict B = PARTIAL; Craft Anything string-index caveat; `alphanull` all-zero |
| `DTRN_06_donor_grass_decals.md` C13–C16, §3.4, M3, Q3 | complement-pair claim, mask binding, port `fract(v_st)` gap |
| `DEC_05_terrain_formats.md` §4.4, §5.5, N5/N10 | BMP headers, atlas layout, alpha atlas conversion note |
| `V785_tile_atlas.md` E6–E10, §4 | whole-atlas PNG conversion, no cell mapping invented |

### Donor files opened (read-only)
`data\terrain\ref\reftile.lib` (262 B), `reftile.mat` (4,206 B), `reftilealpha.mat`
(8,765 B); `data\terrain\tiles\tiles.lib` (26,947 B, 909 lines, **245 sections**),
`tiles.mat` (47,343 B, 1,019 lines, **253 sections**), `terrain.presets` (Summer 124 +
Winter 124); `data\terrain\tiles\textures\alpha.bmp` (132,142 B), `alphavert.bmp`,
`alphanull.bmp`; `data\shaders\obj\hf.pvl.sm.vert`, `hf.pvl.smx3.frag`; binaries
`cossacks.exe`, `cossacks.cdx`, `codex.dll`, `config.exe`, `editor.exe`, `modman.exe`,
`steam_api.dll`, `steamwrap.dll`, `steamclient.dll`, `d3d9.dll`, `dbghelp.dll`.

---

## 2. Pass A — full override inventory (RESOLVED)

### 2.1 `reftile.lib` — the only file with alpha-atlas fields

All 13 lines; values **observed**:

```
1  section.begin
2     TileBlockName =
3     TileScheme = tsDouble          <- ACTIVE
4     TileType = ttExtended          <- ACTIVE
5     TileXOffset = 0.1              <- ACTIVE
6     TileYOffset = 0.2              <- ACTIVE
7     //TileSize = 64                <- COMMENTED (intended default)
8     //Rows = 16                    <- COMMENTED
9     //Cols = 16                    <- COMMENTED
10    //AlphaRows = 8                <- COMMENTED
11    //AlphaCols = 4                <- COMMENTED
12    //AlphaTileSize = 64           <- COMMENTED
13 section.end
```

`TileBlockName` is empty, so every section in `tiles.lib` inherits these via
`section.begin {refurl=...\reftile.lib}`. **No other donor file sets `AlphaRows`,
`AlphaCols` or `AlphaTileSize`** (recursive scan: 1 file each, this one only).

### 2.2 `tiles.lib` — every one of 245 sections

Regex parse (Pass A, verified twice by independent grep of the raw text) found exactly
**30 geometry lines = 10 sections × 3 keys**. No `AlphaRows`/`AlphaCols`/
`AlphaTileSize`/`tsDouble`/`ttExtended`/`TileXOffset`/`TileYOffset` override occurs
anywhere in this file, active or commented.

| Family (tiles.lib lines) | TileSize / Rows / Cols | Preset ids affected | Alpha geometry |
|---|---|---|---|
| `sand1`,`sand2`,`sand3`,`sand4` (:52,:58,:64,:70) | **64 / 2 / 2** | Summer **26–29** | 8 / 4 / 64 (inherited) |
| `sand1_winter`…`sand4_winter` (:475,:481,:487,:493) | **64 / 2 / 2** | Winter **26–29** | 8 / 4 / 64 (inherited) |
| `test10` (:328) | **128 / 16 / 16** | Summer **81** | 8 / 4 / 64 (inherited) |
| `test11` (:334) | **128 / 32 / 32** | Summer **82** | 8 / 4 / 64 (inherited) |
| **all other 235 sections** | **64 / 16 / 16 (default)** | every other id, both seasons | 8 / 4 / 64 (inherited) |

**New asymmetry (observed, not previously reported):** `test10_winter` (:751) and
`test11_winter` (:754) do **not** carry the 128 overrides — they inherit 64/16/16.
The 128/16/16 and 128/32/32 geometry is Summer-only.

Face blocks: 72 sections carry `AngleX`/`AngleZ` — 36 `vf` with `AngleX=0, AngleZ=25`
and 36 `vs` with `AngleX=25, AngleZ=0` (Summer ids 53–70, Winter ids 53–70).

**Complete 245-section table** (lib idx = section order, *not* preset id; preset ids given
above for the override families):

﻿| lib idx | lib line | TileBlockName | TileSize/Rows/Cols | alpha geometry | refkey (tiles.mat) |
|---:|---:|---|---|---|---|
| 0 | 1 | grass1 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 1 | 4 | grass2 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 2 | 7 | grass3 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 3 | 10 | grass4 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 4 | 13 | grass5 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 5 | 16 | grass6 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 6 | 19 | grass7 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 7 | 22 | grass8 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 8 | 25 | grass9 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 9 | 28 | grass10 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 10 | 31 | ground1 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 11 | 34 | grass_ground1 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 12 | 37 | grass_ground2 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 13 | 40 | grass_ground3 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 14 | 43 | grass_rock1 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 15 | 46 | grass_sand1 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 16 | 49 | grass_sand2 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 17 | 52 | sand1 | 64/2/2 | 8/4/64 (shared; no Alpha* override) | normal |
| 18 | 58 | sand2 | 64/2/2 | 8/4/64 (shared; no Alpha* override) | normal |
| 19 | 64 | sand3 | 64/2/2 | 8/4/64 (shared; no Alpha* override) | normal |
| 20 | 70 | sand4 | 64/2/2 | 8/4/64 (shared; no Alpha* override) | normal |
| 21 | 76 | sand5 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 22 | 79 | sand6 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 23 | 82 | sand7 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 24 | 85 | sand8 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 25 | 88 | sand9 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 26 | 91 | rock1 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 27 | 94 | rock2 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 28 | 97 | rock3 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 29 | 100 | rock4 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 30 | 103 | rock5 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 31 | 106 | rock6 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 32 | 109 | rock7 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 33 | 112 | rock8 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 34 | 115 | rock9 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 35 | 118 | rock1vf | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalfront |
| 36 | 123 | rock1vs | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalside |
| 37 | 128 | rock2vf | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalfront |
| 38 | 133 | rock2vs | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalside |
| 39 | 138 | rock3vf | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalfront |
| 40 | 143 | rock3vs | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalside |
| 41 | 148 | rock4vf | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalfront |
| 42 | 153 | rock4vs | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalside |
| 43 | 158 | rock5vf | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalfront |
| 44 | 163 | rock5vs | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalside |
| 45 | 168 | rock6vf | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalfront |
| 46 | 173 | rock6vs | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalside |
| 47 | 178 | rock7vf | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalfront |
| 48 | 183 | rock7vs | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalside |
| 49 | 188 | rock8vf | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalfront |
| 50 | 193 | rock8vs | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalside |
| 51 | 198 | rock9vf | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalfront |
| 52 | 203 | rock9vs | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalside |
| 53 | 208 | sand1f | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 54 | 213 | sand1s | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normalside |
| 55 | 218 | sand2f | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 56 | 223 | sand2s | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normalside |
| 57 | 228 | sand3f | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 58 | 233 | sand3s | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normalside |
| 59 | 238 | sand4f | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 60 | 243 | sand4s | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normalside |
| 61 | 248 | sand5f | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 62 | 253 | sand5s | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normalside |
| 63 | 258 | sand6f | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 64 | 263 | sand6s | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normalside |
| 65 | 268 | sand7f | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 66 | 273 | sand7s | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normalside |
| 67 | 278 | sand8f | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 68 | 283 | sand8s | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normalside |
| 69 | 288 | sand9f | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 70 | 293 | sand9s | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normalside |
| 71 | 298 | test0 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 72 | 301 | test1 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 73 | 304 | test2 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 74 | 307 | test3 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 75 | 310 | test4 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 76 | 313 | test5 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 77 | 316 | test6 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 78 | 319 | test7 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 79 | 322 | test8 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 80 | 325 | test9 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 81 | 328 | test10 | 128/16/16 | 8/4/64 (shared; no Alpha* override) | normal |
| 82 | 334 | test11 | 128/32/32 | 8/4/64 (shared; no Alpha* override) | normal |
| 83 | 340 | test12 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 84 | 343 | test13 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 85 | 346 | test14 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 86 | 349 | alpha0a | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 87 | 352 | sandrock1 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 88 | 355 | sandrock2 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 89 | 358 | sandrock3 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 90 | 361 | sandrock4 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 91 | 364 | sandrock5 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 92 | 367 | sandrock6 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 93 | 370 | sandsea1 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 94 | 373 | sandsea2 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 95 | 376 | sandsea3 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 96 | 379 | sandsea4 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 97 | 382 | sandsea5 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 98 | 385 | sandsea6 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 99 | 388 | test15 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 100 | 391 | test16 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 101 | 394 | test17 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 102 | 397 | test18 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 103 | 400 | test19 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 104 | 403 | test20 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 105 | 406 | test21 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 106 | 409 | test22 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 107 | 412 | test23 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 108 | 415 | test24 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 109 | 418 | test25 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 110 | 421 | alpha0b | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 111 | 424 | grass1_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 112 | 427 | grass2_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 113 | 430 | grass3_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 114 | 433 | grass4_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 115 | 436 | grass5_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 116 | 439 | grass6_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 117 | 442 | grass7_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 118 | 445 | grass8_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 119 | 448 | grass9_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 120 | 451 | grass10_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 121 | 454 | ground1_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 122 | 457 | grass_ground1_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 123 | 460 | grass_ground2_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 124 | 463 | grass_ground3_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 125 | 466 | grass_rock1_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 126 | 469 | grass_sand1_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 127 | 472 | grass_sand2_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 128 | 475 | sand1_winter | 64/2/2 | 8/4/64 (shared; no Alpha* override) | normal |
| 129 | 481 | sand2_winter | 64/2/2 | 8/4/64 (shared; no Alpha* override) | normal |
| 130 | 487 | sand3_winter | 64/2/2 | 8/4/64 (shared; no Alpha* override) | normal |
| 131 | 493 | sand4_winter | 64/2/2 | 8/4/64 (shared; no Alpha* override) | normal |
| 132 | 499 | sand5_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 133 | 502 | sand6_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 134 | 505 | sand7_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 135 | 508 | sand8_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 136 | 511 | sand9_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 137 | 514 | rock1_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 138 | 517 | rock2_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 139 | 520 | rock3_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 140 | 523 | rock4_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 141 | 526 | rock5_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 142 | 529 | rock6_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 143 | 532 | rock7_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 144 | 535 | rock8_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 145 | 538 | rock9_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 146 | 541 | rock1vf_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalfront |
| 147 | 546 | rock1vs_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalside |
| 148 | 551 | rock2vf_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalfront |
| 149 | 556 | rock2vs_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalside |
| 150 | 561 | rock3vf_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalfront |
| 151 | 566 | rock3vs_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalside |
| 152 | 571 | rock4vf_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalfront |
| 153 | 576 | rock4vs_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalside |
| 154 | 581 | rock5vf_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalfront |
| 155 | 586 | rock5vs_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalside |
| 156 | 591 | rock6vf_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalfront |
| 157 | 596 | rock6vs_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalside |
| 158 | 601 | rock7vf_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalfront |
| 159 | 606 | rock7vs_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalside |
| 160 | 611 | rock8vf_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalfront |
| 161 | 616 | rock8vs_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalside |
| 162 | 621 | rock9vf_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalfront |
| 163 | 626 | rock9vs_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | verticalside |
| 164 | 631 | sand1f_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 165 | 636 | sand1s_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normalside |
| 166 | 641 | sand2f_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 167 | 646 | sand2s_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normalside |
| 168 | 651 | sand3f_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 169 | 656 | sand3s_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normalside |
| 170 | 661 | sand4f_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 171 | 666 | sand4s_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normalside |
| 172 | 671 | sand5f_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 173 | 676 | sand5s_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normalside |
| 174 | 681 | sand6f_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 175 | 686 | sand6s_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normalside |
| 176 | 691 | sand7f_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 177 | 696 | sand7s_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normalside |
| 178 | 701 | sand8f_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 179 | 706 | sand8s_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normalside |
| 180 | 711 | sand9f_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 181 | 716 | sand9s_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normalside |
| 182 | 721 | test0_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 183 | 724 | test1_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 184 | 727 | test2_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 185 | 730 | test3_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 186 | 733 | test4_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 187 | 736 | test5_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 188 | 739 | test6_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 189 | 742 | test7_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 190 | 745 | test8_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 191 | 748 | test9_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 192 | 751 | test10_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 193 | 754 | test11_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 194 | 757 | test12_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 195 | 760 | test13_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 196 | 763 | test14_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 197 | 766 | sandrock1_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 198 | 769 | sandrock2_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 199 | 772 | sandrock3_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 200 | 775 | sandrock4_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 201 | 778 | sandrock5_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 202 | 781 | sandrock6_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 203 | 784 | sandsea1_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 204 | 787 | sandsea2_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 205 | 790 | sandsea3_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 206 | 793 | sandsea4_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 207 | 796 | sandsea5_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 208 | 799 | sandsea6_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 209 | 802 | test15_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 210 | 805 | test16_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 211 | 808 | test17_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 212 | 811 | test18_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 213 | 814 | test19_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 214 | 817 | test20_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 215 | 820 | test21_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 216 | 823 | test22_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 217 | 826 | test23_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 218 | 829 | test24_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 219 | 832 | test25_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 220 | 835 | desert1 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 221 | 838 | desert2 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 222 | 841 | desert3 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 223 | 844 | desert4 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 224 | 847 | desert5 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 225 | 850 | desert6 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 226 | 853 | desert7 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 227 | 856 | desert8 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 228 | 859 | desert9 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 229 | 862 | desert10 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 230 | 865 | desert11 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 231 | 868 | desert12 | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 232 | 871 | desert1_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 233 | 874 | desert2_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 234 | 877 | desert3_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 235 | 880 | desert4_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 236 | 883 | desert5_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 237 | 886 | desert6_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 238 | 889 | desert7_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 239 | 892 | desert8_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 240 | 895 | desert9_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 241 | 898 | desert10_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 242 | 901 | desert11_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 243 | 904 | desert12_winter | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |
| 244 | 907 | alpha0c | 64/16/16 (default) | 8/4/64 (shared; no Alpha* override) | normal |

### 2.3 `tiles.mat` — no per-tile sub-rect choice

253 sections; the **only** keys present are `Material.Name` (253),
`Material.Texture.image` (253) and `Material.Texture2Name` (6). Zero geometry/alpha keys.
refkey distribution from `section.begin`: `normal` 199, `normalside` 18,
`verticalfront` 18, `verticalside` 18. The six `Texture2Name` overrides are all
`alphanull`: `alpha0a`, `alpha0b`, `alpha0c` (Summer ids 86, 110, 123) and their three
`*_winter` copies. Therefore the material layer never selects an alpha patch; it only
swaps the whole mask texture for face tiles (`alphavert`) or nulls it (`alphanull`).
**Label: observed, verified twice** (parser + key-frequency count).

### 2.4 Why the mapping cannot be in the materials — shader evidence

`hf.pvl.sm.vert:34` is `gl_TexCoord[1] = gl_MultiTexCoord1;` and
`hf.pvl.smx3.frag:14` is `color.a = texture2D(texUnit1, gl_TexCoord[1].xy).a;`.
`reftilealpha.mat:34,43-49` sets `mappingmode = tmmUser` with S/T=(1,0,0,0).
**Derived:** the alpha sub-rect UV is written **per vertex into texture-coordinate
channel 1 by the engine's mesh builder** — it is not computed by a shader, a material
parameter, or a script. This explains why no config key or script function can carry it.

---

## 3. Pass B — pixel analysis (RESOLVED geometry / PARTIAL structure)

### 3.1 Headers (observed, verified twice)

| File | Header | Size | bpp | Pixel offset | Data |
|---|---|---|---|---|---|
| `alpha.bmp` | DIB40 (BI_RGB) | 512×256 | 8 | 1070 | 254 greys + 2 unused transparent entries (256 palette slots) |
| `alphavert.bmp` | DIB40 | 1024×512 | 24 | 54 | projected cliff mask, 256 levels, mean 77.38 |
| `alphanull.bmp` | DIB12 core | 512×256 | 8 | 794 | all pixels index 0 → all L=0 |

Palette quirk (**observed**): 8-bit *index* maps to intensity with an offset —
index 0–3 → 0, index 4 → 1, …, index 253 → **255**, indices 254/255 → 0
(transparent). The highest index present in `alpha.bmp` data is 253. Hence a
"identical" complement is `A+B=255` in **intensity** space but `idxA+idxB=253` in
**raw index** space. Both spaces were searched.

### 3.2 All 32 patch rectangles (observed + derived)

Seam discontinuities occur **only** at x/y multiples of 64 (independent Pillow/numpy
measurement, identical to RV-TRN-01's table):

```
x=63:0.42  x=64:126.70 x=65:0.35    y=63:0.43  y=64:123.34  y=65:2.12
x=127:0.40 x=128:64.33 x=129:0.42   y=127:0.38 y=128:121.77 y=129:1.15
x=191:0.43 x=192:183.19 x=193:0.39  y=191:0.51 y=192:192.56 y=193:0.00
x=255:0.32 x=256:184.83 x=257:0.30
x=319:0.31 x=320:126.94 x=321:0.24
x=383:0.51 x=384:64.27  x=385:0.33
x=447:0.42 x=448:183.09 x=449:0.34
```

**Derived / double-verified:** `alpha.bmp` = **8 columns × 4 rows of 64×64 patches**,
i.e. patch `(c,r)` occupies `x ∈ [64c,64c+64)`, `y ∈ [64r,64r+64)` in top-left origin
(note the BMP rows are stored bottom-up; both decoders flip them identically). This
matches the commented `AlphaRows=8, AlphaCols=4, AlphaTileSize=64` — the labels are
transposed relative to the pixel layout (8 across, 4 down).

Patch mean intensities (row-major, `c0…c7`):

```
r0: 255.0  52.3  50.5 132.4 | 255.0  77.7  72.7 154.1
r1:  56.5 136.3 157.9 213.5 |  58.3 157.7 180.1 206.4
r2:  45.6 153.5 134.2 210.0 |  82.8 174.5 143.1 199.9
r3: 136.9 210.1 216.4   0.0 | 152.2 196.7 203.3   0.0
```

Exactly four patches are constant: `(0,0)` and `(4,0)` are all 255; `(3,3)` and `(7,3)`
are all 0. The other 28 span 0…255 with 234–251 distinct levels each.

### 3.3 Complement-pair structure (PARTIAL — corrects DTRN-06 C15)

Exhaustive search over all **496 unordered patch pairs**, in intensity space and raw
index space, with identity/h/v/hv/transpose transforms:

- **Exact `A+B=255` pairs (4):** `((0,0),(3,3))`, `((0,0),(7,3))`,
  `((4,0),(3,3))`, `((4,0),(7,3))`. All four are the **constant-255 vs constant-0**
  sentinel pairs. In raw index space these sum to 253 for 4,093/4,096 pixels of
  `(0,0)+(3,3)` — the authored constant is index 253 → intensity 255.
- **No graded pair is an exact complement.** Best graded candidates (MAD from 255):
  `(2,0)+(1,3)` **9.77**, `(3,1)+(0,2)` **9.91**, `(7,1)+(0,2)` **12.21**,
  `(0,1)+(3,2)` **13.83**; the next best are ≥15.8. Raw index space gives the same
  conclusion (e.g. `(1,0)+(2,3)` sums 186…388, not constant).
- **Derived counterpart rule:** the closest graded complements are consistently the
  **180°-rotated partner in the 4×4 quadrant**, `(r,c) ↔ (3−r,3−c)` (left half) or
  `(r,c) ↔ (3−r,7−c)` (right half). For the left half the MADs are
  `(0,0)/(3,3)=0`, `(1,0)/(2,3)=15.81`, `(2,0)/(1,3)=9.77`, `(3,0)/(0,3)=17.64`,
  `(0,1)/(3,2)=13.83`, `(1,1)/(2,2)=17.17`, `(3,1)/(0,2)=9.91`. The right half is
  **much less complementary** (MAD 18–84), so the two halves are best read as two
  organic *variants* of the same four mask roles, not as two complementary tile sets
  (**inferred**).
- **Seam pattern repeats every 4 columns** (126.70/64.33/183.19/184.83 vs
  126.94/64.27/183.09) — **derived** evidence for the two 4-column halves.

**Verdict:** the *existence* of complementary masks is confirmed only for the two
constant sentinel pairs; the graded masks are approximately, not exactly,
complementary. DTRN-06 C15's phrase "exact complementary pairs exist (e.g.
(0,0)+(3,3)=255)" is literally true but **overstates** the graded-mask structure.

### 3.4 Boundary direction ↔ patch row (PARTIAL, derived only)

Mean edge intensity over the 8 patches per row, excluding the two constant rows:

| Patch row | T | R | B | L | Darkest edge | Derived direction |
|---:|---:|---:|---:|---:|---|---|
| 0 | **0.0** | 83.3 | 167.9 | 83.1 | top | **N** |
| 1 | 125.0 | 190.2 | 126.0 | **63.1** | left | **W** |
| 2 | 124.6 | **63.1** | 126.2 | 190.1 | right | **E** |
| 3 | 255.0 | 168.0 | **83.4** | 168.8 | bottom | **S** |

Per-patch dark/bright edge classification (T/R/B/L, `<64` dark, `>192` bright) shows
the four column variants within each row:

| row | c0 | c1 | c2 | c3 | (c4–c7 repeat the same roles with different organic noise) |
|---:|---|---|---|---|---|
| 0 (N) | all bright (255 sentinel) | dark TL = NW corner | dark TR = NE corner | dark T, bright B = full N edge | c4…c7 mirror c0…c3 |
| 1 (W) | dark BL = SW corner | dark L, bright R = full W edge | flat ≈125 all edges | bright TR/BR = NW-ish corner | c4…c7 mirror c0…c3 |
| 2 (E) | dark RB = SE corner | flat ≈125 all edges | dark R, bright L = full E edge | bright BL = NE-ish corner | c4…c7 mirror c0…c3 |
| 3 (S) | dark B, bright T = full S edge | bright TR = SW corner | bright TL = SE corner | all dark (0 sentinel) | c4…c7 mirror c0…c3 |

**Label: derived** from measured edge statistics, **not** a donor-published enum.
It is a plausible interpretation of the authored shapes, not a recovered index rule.

---

## 4. Pass C — byte evidence (proof of absence)

All offsets are **decimal file offsets**; short hex excerpts have `path:offset`.
Python scanned ASCII + UTF-16LE + UTF-16BE; Craft Anything `native_bytes_find` searched
UTF-8 + UTF-16LE independently and agreed on the cited offsets.

| Key | Path:offset | Hex / string excerpt | Label |
|---|---|---|---|
| `AlphaRows` | `cossacks.exe:1323550`, `:1326284` | `0e 00 09 41 6c 70 68 61 52 6f 77 73 9c 10 40 00` = length 9, `AlphaRows`, CODE ptr 0x0040109c | observed (RTTI field) |
| `AlphaCols` | `cossacks.exe:1323586`, `:1326304` | `0f 00 09 41 6c 70 68 61 43 6f 6c 73 84 10 40 00` | observed |
| `AlphaTileSize` | `cossacks.exe:1323622`, `:1326324` | `10 00 0d 41 6c 70 68 61 54 69 6c 65 53 69 7a 65 f8 10 40 00` | observed |
| `TileXOffset` / `TileYOffset` | `cossacks.exe:1326192` / `:1326212` | `0b 00 00 54 69 6c 65 58 4f 66 66 73 65 74` … | observed |
| `TileSize`, `Rows`, `Cols` | `cossacks.exe:1323515`, `:1323453`, `:1323484` | field ids `0d/0b/0c`, struct offsets `0x28/0x24/0x25` | observed |
| `tsDouble` | `cossacks.exe:1322769`, `:1324324` | `08 74 73 53 69 6e 67 6c 65 08 74 73 44 6f 75 62 6c 65 08 74 73 54 72 69 70 6c 65 08 74 73 54 65 74 72 69 73 09 74 73 51 75 69 6e 71 75 65` = `tsSingle`, `tsDouble`, `tsTriple`, `tsTetris`, `tsQuinque` (length-prefixed Pascal strings; `XTile` follows) | observed (enum table) |
| `ttExtended` | `cossacks.exe:1322850`, `:1324548` | `07 74 74 55 73 75 61 6c 0a 74 74 45 78 74 65 6e 64 65 64 05 58 54 69 6c 65` = `ttUsual`, `ttExtended`, `XTile` | observed (enum table) |
| `bmTransparency` | `cossacks.exe:949234`, `:953108`, `:4711020` | `0e 62 6d 54 72 61 6e 73 70 61 72 65 6e 63 79` (enum, 3 copies) | observed |
| `tiaAlphaFromIntensity` | `cossacks.exe:942680`, `:952132` | `15 74 69 61 41 6c 70 68 61 46 72 6f 6d 49 6e 74 65 6e 73 69 74 79` | observed |
| Candidate patch functions | `cossacks.exe` | `PatchIndex`, `GetAlphaPatch`, `AlphaTileIndex` → **0 matches** in both Python and Craft Anything raw-byte finders | observed (absence) |
| Script API names | `config.exe:2214201`, `:2318297` | `MapGetTileBlockByTileIndex(const index : Integer) : String`, `GetTileIndex(const i, j: Integer): Integer`, `SetTileIndex`, `MapGeneratorSmoothTiles` — declarations only, **no alpha/patch function** among 67 matches | observed (absence of mapping fn) |
| All donor text | 17,237 files / 4,506 text files | `AlphaRows`/`AlphaCols`/`AlphaTileSize`/`tsDouble`/`ttExtended`/`TileScheme`/`TileType` = **1 file each**: `reftile.lib` only. `PatchIndex`, `GetAlpha`, `MaskIndex`, `AlphaIndex`, `AlphaOffset` = **0 files** | observed (absence) |
| `codex.dll` | 106,272 B | **0 hits** for every key | observed (absence) |

PE layout (observed): `cossacks.exe` imagebase 0x400000, section **CODE**
VA 0x001000/raw 0x400 size 0x4f0e00; the RTTI/enum tables at file offset ~1.32 MB fall
inside CODE. RV-TRN-01's warning is confirmed: Craft Anything's *string indexer* finds
0 `AlphaRows` strings while its **raw-byte finder** finds both CODE hits. All absence
claims above therefore use raw bytes, never the string index.

**Derived inference:** the fields exist as compiled RTTI (so the engine reads them), but
no readable artifact carries the arithmetic that consumes `TileScheme`/`TileType`/
`TileXOffset`/`TileYOffset` to emit a patch index. The engine's `.bind` section is packed
(RV-TRN-01 measured entropy 7.96 bits/byte), so static disassembly is out of scope
without executing the donor.

---

## 5. Verdict table

| # | Claim | Verdict | Exact donor value recovered | Citation |
|---|---|---|---|---|
| 1 | `alpha.bmp` = 8×4 grid of 64² patches | **RESOLVED** | patch `(c,r)` = `[64c,64c+64) × [64r,64r+64)`; 32 rectangles; seam deltas only at multiples of 64 | `alpha.bmp` pixel array @1070; `reftile.lib:10-12`; two independent decoders |
| 2 | Complete tile→sub-atlas geometry inventory | **RESOLVED** | 245 `tiles.lib` sections: 8×64/2/2, 2×128 overrides (Summer only), 235 defaults; alpha geometry inherited by **all**; `tiles.mat` adds no geometry | `tiles.lib:52-74,328-338,475-497`; `tiles.mat` key census; §2 table |
| 3 | Exact complement pairs among the 32 patches | **PARTIAL** | only 4 exact pairs, all constant-255 vs constant-0 sentinels; best graded MAD 9.77; `(r,c)↔(3−r,3−c)` counterpart structure derived | §3.3; Pillow/numpy + custom decoder |
| 4 | Boundary direction ↔ patch row | **PARTIAL** | row darkness ranks T/L/R/B → rows 0/1/2/3 = N/W/E/S (derived from measured edge means); column roles derived; no file confirms selection | §3.4; `alpha.bmp` pixels |
| 5 | `tile_id + boundary_direction → patch (u,v,size)` | **CONFIRMED_UNVERIFIED** | **None.** Proof of absence: 17,237-file scan, 11 binaries × 3 encodings, 0 patch-index function names; UV comes from `gl_MultiTexCoord1` written by engine; packed `.bind` | §4 byte table; `hf.pvl.sm.vert:34`; `hf.pvl.smx3.frag:14`; RV-TRN-01 §2 |
| 6 | `tsDouble` / `ttExtended` meaning | **PARTIAL** | enum names recovered (`tsSingle/tsDouble/tsTriple/tsTetris/tsQuinque`, `ttUsual/ttExtended/XTile`) and active values `tsDouble`/`ttExtended`; arithmetic UNVERIFIED | `cossacks.exe:1322769,1322850`; `reftile.lib:3-4` |

**No claim was filled in by guessing.** Item 5 is explicitly `CONFIRMED_UNVERIFIED`,
not "resolved by inspection of the images".

---

## 6. Implementation guidance for TRN-SHADER (APPROX — do not claim donor parity)

The exact donor rule is not recoverable statically, so the shader owner **must keep an
APPROX label**. The following upgrades are donor-grounded where stated and derived
approximations where marked:

1. **[DONOR-GROUNDED] Use the 64² sub-rect grid.** For a chosen patch `(c,r)` and
   in-cell coordinate `(u,v) ∈ [0,1)²`:
   ```
   u_alpha = (c + u) * 64.0 / 512.0    // = (c+u)/8
   v_alpha = (r + v) * 64.0 / 256.0    // = (r+v)/4
   ```
   Do **not** sample the whole atlas with `fract(v_st)` (the current `M3` gap in
   DTRN-06). Texture params: nearest min/mag, `twBoth`, intensity→alpha
   (`reftilealpha.mat:30-37`).
2. **[DERIVED APPROX] Direction→row:** `N→0, W→1, E→2, S→3` from the measured dark-edge
   ranks in §3.4. For a corner case, use the corner variant in that row (c1/c2 for N;
   c0/c3 for W; c0/c3 for E; c1/c2 for S) instead of the full-edge variant c3/c1/c2/c0.
3. **[DERIVED APPROX] Opposite tile:** use the counterpart `(3−c, 3−r)` within the same
   4-column half; the two masks are only *approximately* complementary
   (MAD 9.8–17.6 in the left half), so keep a `mask_to_alpha` diagnostic knob and
   expect a small seam tone step. Never assert exact coverage.
4. **[INFERRED] Sentinels:** patch `(0,0)`/`(4,0)` = constant 255 (no transition),
   `(3,3)`/`(7,3)` = constant 0 (full cut); `alphanull.bmp` = all zero and is the donor's
   explicit "no mask" binding for `alpha0a/b/c` (`tiles.mat:346-360`). Prefer `alphanull`
   for same-tile / no-neighbour cells rather than an arbitrary patch.
5. **[INFERRED] Two halves:** columns 0–3 and 4–7 are two organic variants of the same
   four mask roles (seam pattern repeats every 4 columns). Pick the half from a stable
   hash of the two tile ids if variety is wanted, and document it as port art.
6. **[DONOR-GROUNDED] Sand/test geometry:** cells with preset id Summer 26–29 or
   Winter 26–29 use a 2×2×64 RGB sub-atlas (256² art); Summer 81 uses 16×16×128,
   Summer 82 uses 32×32×128. Winter 81/82 are **default** 64/16/16 (new finding).
   The alpha grid is the same 8×4×64 for all of them.
7. **[INFERRED] `TileXOffset=0.1`, `TileYOffset=0.2` are active donor values** but their
   effect on texgen is UNVERIFIED; do not bake them into UV math without a live GL trace.

Acceptance wording: "64² patch grid and override geometry are donor-grounded; the
tile-pair→patch index and the exact complement are APPROX. No donor visual parity
claimed."

---

## 7. Corrections to prior reports

1. **DTRN-06 C15 — complement overstated.** Exact complements exist **only** for the
   four constant sentinel combinations; the graded 28 patches are not exactly
   complementary (best MAD 9.77). The `(0,0)+(3,3)=255` example is a constant-pair
   triviality, not evidence that graded pairs sum to 255.
2. **DTRN-01 C7 / RV-TRN-01 §4.2 — override list incomplete.** The 64/2/2 override
   applies to **8** sections (sand1–4 plus sand1–4_winter), not just the 4 Summer ones;
   and RV-TRN-01 did not note that **test10_winter/test11_winter lack** the Summer
   128 overrides. Full inventory is in §2.2.
3. **DTRN-01 C7 — alpha fields exist as active engine properties.** RV-TRN-01 already
   noted `TileXOffset/TileYOffset` are active; this pass adds that RTTI tables in
   `cossacks.exe` (CODE section) contain `AlphaRows`/`AlphaCols`/`AlphaTileSize` field
   descriptors with ids 14/15/16 and struct offsets 0x2c/0x2d/0x30 — so the engine does
   consume them, even though every shipped value is commented out.
4. **RV-TRN-01 verdict B — unchanged but more specific.** It said "per-cell patch index
   still UNVERIFIED"; this pass proves *why*: `gl_TexCoord[1]=gl_MultiTexCoord1` means
   the engine writes sub-rect UVs into vertex channel 1, and no script/config/material
   contains the rule. Verdict remains PARTIAL for geometry and CONFIRMED_UNVERIFIED for
   the index rule.
5. **DTRN-01 C28 / M4 — still correct.** The port's whole-mask sampling is an invented
   mapping; this pass supplies donor-grounded geometry and derived direction structure
   but **not** donor parity.
6. **V785 E9/E10 — still correct.** Only whole-atlas PNGs were shipped; no cell mapping
   was fabricated; the new §6 recipe should be read as an APPROX upgrade, not V785 data.

---

## 8. Open questions

1. What arithmetic converts `TileScheme=tsDouble`, `TileType=ttExtended`,
   `TileXOffset=0.1`, `TileYOffset=0.2` and the two neighbouring tile ids into a
   `(row,col)` patch and the vertex `MultiTexCoord1` values? Requires donor execution or
   unpacking the packed `.bind` code — both out of scope.
2. Are patches `(1,0)/(2,3)` et al. intended as exact complements at authoring time
   (the 9.77 MAD could be a palette/quantisation artifact we could not model), or simply
   hand-authored organic approximations? Not decidable from the BMP alone.
3. Why is the right 4-column half much less complementary (MAD 18–84) than the left
   (0–17.6)? Two variant sets, or two different schemes? **Inferred** only.
4. Are the constant-255/constant-0 patches truly "no blend"/"full cut" sentinels, or
   unused atlas slack? RV-TRN-01 Q6 remains open.
5. Why do `test10_winter`/`test11_winter` lack the Summer 128 overrides — omission or
   intentional (the Winter DDS may be 1024² rather than the 2048²/4096² virtual atlas)?
6. Does `bmTransparency` composite the two masks in one pass or several, and with what
   blend factors? Still CONFIRMED_UNVERIFIED (RV-TRN-01 item D).

---

## 9. Summary

Three independent passes (full config-section parse, two independent bitmap decoders,
raw-byte scans across 17,237 files and 11 binaries with two tools) resolved the
*geometry* of the donor alpha atlas and proved the *selection rule* is not statically
recoverable.

- **RESOLVED:** the 8 columns × 4 rows × 64² patch grid (seam deltas exactly at
  multiples of 64, twice verified), and the complete override inventory across all 245
  tile sections — 8 families at 64/2/2, two Summer-only 128 overrides, 235 defaults, and
  **no alpha-atlas override anywhere**, so every tile id shares the same 8×4 mask atlas.
- **PARTIAL:** complement structure — exact complements exist only for the four
  constant sentinel combinations; graded masks are approximately complementary with a
  derived `(r,c)↔(3−r,3−c)` counterpart pattern; measured edge darkness ranks rows
  N/W/E/S (0/1/2/3).
- **CONFIRMED_UNVERIFIED:** the exact `tile_id + boundary_direction → patch` rule. All
  field names exist as compiled RTTI in packed CODE, but no script, material, config or
  function name computes a patch index, and the shader takes its alpha UV from
  vertex-supplied `gl_MultiTexCoord1`.

`TRN-SHADER` should adopt §6's 64² sub-rect sampling (donor-grounded geometry and
derived direction rows) while labelling the tile→patch choice APPROX and retaining the
A/B knob. DTRN-06 C15's "exact complementary pairs" claim is narrowed to the sentinel
patches. No donor binary was executed or copied; one report written; no code, asset,
config, test, git or runner state changed; visual parity is not claimed.

*End of DALPHA-01.*
