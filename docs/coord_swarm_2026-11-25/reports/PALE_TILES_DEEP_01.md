---
id: PALE-TILES-DEEP-01
title: "Donor tile families / albedo art that could produce pale stepped grid marks on flat land — read-only deep dive"
agent: "Donor deep-dive worker (3 passes), coord swarm 2026-11-25"
date: 2026-11-25
status: DELIVERED__DONOR_READ_ONLY__NO_CODE_EDIT__NO_DONOR_COPY__NO_RUNNER_JOB
scope: "ONE new file only: this report. No source/asset/config/test/shader/git edit, no donor copy, no queue mutation, no runner job. Donor inspected READ-ONLY (Python 3.14 bytes/struct + Pillow 12.1.1 + NumPy 2.4.3). Temp probe scripts/previews live only in %LOCALAPPDATA%\\Temp\\opencode\\."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor: "C:\\Games\\Cossacks 3 (READ-ONLY; nothing copied, executed or rendered)"
exclusive_output: "docs/coord_swarm_2026-11-25/reports/PALE_TILES_DEEP_01.md"
labels: [observed, derived, inferred, UNVERIFIED]
verification_passes: 3
visual_parity_claim: false
parity_guard: "PORT APPROX — internal consistency only. No donor GPU A/B frame exists; no donor parity is claimed anywhere in this report."
verdict: "NO summer donor albedo family is pale enough to produce broad near-white bands. The only near-white family is winter* (L 199-253, 98-100% near-white) and it is absent from the observed summer frame. The observed bands are sky/water colour bleeding through semi-transparent ground (Rec.601 B-R ~= 74, dominant exact pixel (181,234,255) = the capture's sky corner), i.e. the alpha/framebuffer path, not albedo. Port's APPROX tile-id -> alpha-patch mapping assigns 0/56.5 mean alpha to flat-land test7/test9 ids, which is a concrete code-free mechanism for the stepped bands."
---

# PALE TILES DEEP 01 — pale stepped grid marks: donor albedo vs alpha atlas

## 0. Mandate and boundary

Read-only deep dive on the donor tile art and its transition rules to decide which tile
families could produce the pale, stepped, grid-aligned bands seen on flat land, and to
test the alpha-atlas seam-mask hypothesis with independent raw bytes and pixel statistics.

Every statement is labelled **observed** (literal bytes, header fields, pixel statistics
or tool output), **derived** (arithmetic/control-flow consequence of observed data),
**inferred** (attribution without a pixel-aligned donor A/B), or **UNVERIFIED**.
No donor binary was executed; no donor file was copied; no code was edited; no runner job
was submitted. **No donor parity claim.**

---

## 1. Sources

### 1.1 Reports read (task list)

| # | Path | Status / what was taken |
|---|---|---|
| R1 | `reports/WHITE_MARKS_PIX_01.md` | **UNVERIFIED / NOT PRESENT.** Recursive search of the whole workspace found no file with this name. No facts taken from it. |
| R2 | `reports/QA_WHITE_MARKS_01.md` | **UNVERIFIED / NOT PRESENT.** Same search. No facts taken from it. |
| R3 | `reports/RELIEF_VISUAL_01.md` | Read in full. Supplied the observed raw GPU frame `relief_on.png.raw.png` (ticket 532), the visual description of the stepped bands, the 44,381 "near-white" count and the sky-corner pixel `(0.7137,0.9137,1.0)`. |
| R4 | `reports/TERRAIN_MARKS_01.md` | Read in full. Ranked hypotheses (tile-id colour vs relief vs alpha), P0 flat control stats, and the read-only A/B proposal. |
| R5 | `reports/DTRN_06_donor_grass_decals.md` | Read §1–§5. C04–C17 (tile families, alpha atlas, M1/M3/M5 port defects), L2/L3/L4 constants. |
| R6 | `reports/DALPHA_01_alpha_subrect.md` | Read §0–§9. 8×4×64 patch geometry, 4 constant sentinels, `tile→patch` rule `CONFIRMED_UNVERIFIED`, port guidance. |
| R7 | `decomp/DEC_05_terrain_formats.md` | **Path correction:** the file lives under `docs/coord_swarm_2026-11-25/decomp/`, not `reports/`. Read §3–§5: 112 DDS inventory, `.map`, preset ids, blend rule. |

### 1.2 Donor files opened read-only (`C:\Games\Cossacks 3\data\`)

- `terrain\tiles\textures\*.dds` — all **112** files (headers + native-resolution pixel decode).
- `terrain\tiles\textures\alpha.bmp`, `alphavert.bmp`, `alphanull.bmp` (raw header/palette/pixel bytes).
- `terrain\tiles\tiles.mat`, `terrain.presets`, `tiles.lib`, `terrain.lib`.
- `scripts\common.inc\texturemap.inc` (lines 415–646 and 648–963),
  `scripts\common.inc\smoothtiles.inc`, `scripts\common.inc\loadtextureterrainfrombitmap.inc`,
  `gen\tilesmooth_scripts.cfg` (all 1,863 lines), `gen\bitmap\ext\tile_low/highground.bmp`
  (via prior reports), `ref\reftile.mat`, `ref\reftilealpha.mat`.

### 1.3 Port files read only

- `variant3d\shaders\terrain_tileindex.gdshader` (`:27-29,43,66,91,214,222,235,308-314,330-335,338-376,390,410-418,467-469`).
- `variant3d\scripts\game.gd` (`:47-59,1549-1580,1725-1742,1895-1935,1933-2037,2039-2116,2118-2188`),
  `variant3d\scripts\data.gd:230,258-259`, `variant3d\scripts\main.gd:71,184,1119-1136`,
  `variant3d\scripts\world3d_terrain.gd:708,1481`.
- `variant3d\tests\fixtures\small_map_64.json`, `variant3d\config.json`,
  `variant3d\assets\terrain\atlas\tile_index_atlas.manifest.json`.
- Existing same-seed dump `app\shots\t6t90_dumps\dump_20261113_a.json` (seed 20261113, 320²).
- Existing capture artifact `%LOCALAPPDATA%\Temp\opencode\reliefvisual\relief_on.png.raw.png`.

### 1.4 Three-pass protocol (observed)

- **P1 — headers + downsampled pixels.** `struct.unpack_from` on each DDS header at `@12/@16/@28/@84/@108`; Pillow decode, 64×64 LANCZOS sample, Rec.601 luminance, channel maxima, near-white fractions.
- **P2 — native-resolution full-pixel decode.** Independent NumPy pass over all 1,048,576 (or 65,536) pixels per DDS; no downsampling; `min(R,G,B)>180/210`, `L>180/200`, neutral-pale fraction. Also independent hand-written BMP palette decoder for `alpha.bmp`, cross-checked against Pillow (max difference 0.0).
- **P3 — byte/geometry cross-checks.** DDS size closure, BMP file-size closure (`132,142 B`, data `@1070`, `131,072` pixel bytes = 512×256), palette index→intensity mapping verified from raw bytes, and an independent replay of the port's `alpha_patch_uv()` arithmetic on all tile ids.

---

## 2. Albedo luminance table

### 2.1 Inventory (observed, P1)

| Property | Count / value |
|---|---:|
| Total `terrain\tiles\textures\*.dds` | **112** |
| 1024×1024, DXT1, 11 mips | **110** |
| 256×256, DXT1, 9 mips | **2** (`sand1.dds`, `sand2.dds`) |
| Non-DDS in same folder | 3 BMP (`alpha.bmp`, `alphavert.bmp`, `alphanull.bmp`) |
| Files named `alpha0*` | **0** (see §2.4) |

### 2.2 Family aggregate (observed, P1 — 64² LANCZOS sample, Rec.601 `L`)

`maxL_file` = largest per-file sample mean; `maxL_px` = brightest sampled pixel;
`maxch` = largest per-channel value across the family; `NW180` = max fraction of sampled
pixels with `min(R,G,B)>180`.

| Family | n | mean L | maxL_file | maxL_px | maxch (R,G,B) | NW180 |
|---|---:|---:|---:|---:|---|---:|
| `winter*` | 27 | **177.17** | **252.77** | **255.00** | (255,255,255) | **100.00%** |
| `sandsea*` | 6 | 116.98 | 118.52 | 133.70 | (144,135,102) | 0.00% |
| `sandrock*` | 6 | 94.54 | 113.03 | 128.63 | (138,130,101) | 0.00% |
| `sand*` | 9 | 92.86 | 115.17 | 156.94 | (165,160,125) | 0.00% |
| `ground*` | 1 | 90.63 | 90.63 | 112.95 | (122,113,89) | 0.00% |
| `test*` | 26 | 79.47 | 113.48 | 136.52 | (146,138,104) | 0.00% |
| `grass_ground*` | 3 | 76.51 | 78.74 | 154.83 | (162,156,130) | 0.00% |
| `grass_sand*` | 2 | 70.78 | 73.91 | 124.08 | (129,128,91) | 0.00% |
| `desert*` | 12 | 100.03 | 114.32 | 129.81 | (140,131,100) | 0.00% |
| `rock*` (incl. `rock8`) | 9 | 67.03 | 68.72 | 139.81 | (157,138,107) | 0.00% |
| `grass*` | 10 | 66.98 | 74.59 | 88.08 | (95,96,46) | 0.00% |
| `grass_rock*` | 1 | 65.99 | 65.99 | 89.40 | (101,89,65) | 0.00% |

**Derived:** every **summer** family has sample mean `L ≤ 118.52` and **zero** near-white
pixels at 64² scale. Only `winter*` is pale/near-white. This **refutes** the task's
suggestion that `sand*`, `sandrock*`, `rock8`, `alpha0*` or `test*` are near-white albedo
families: they are mid-tone olive/tan at block scale.

### 2.3 Notable individual files (observed, P1 + P2)

| File | 64² mean L | max sampled L | native max RGB | native `minRGB>180` | native neutral-pale |
|---|---:|---:|---|---:|---:|
| `winter21.dds` | 252.77 | 255.00 | (255,255,255) | **99.999%** | 99.9997% |
| `winter18.dds` | 251.17 | 255.00 | (255,255,255) | 99.740% | 99.854% |
| `winter0.dds` | 247.12 | 255.00 | (255,255,255) | 98.204% | 98.745% |
| `winter16.dds` | 191.44 | 255.00 | (255,255,255) | 61.733% | 67.877% |
| `winter11.dds` | 152.32 | 231.26 | (255,255,255) | 27.545% | 38.682% |
| `sandsea3/4.dds` | 118.52 | 133.70 | (239,227,189) | 0.0003% | 0.0036% |
| `sand3/4.dds` | 115.17 | 137.22 | (239,231,189) | 0.0001% | 0.0009% |
| `sandrock1.dds` | 113.03 | 128.63 | (214,207,189) | 0.0012% | 0.0309% |
| `test20.dds` | 113.48 | 136.52 | (222,207,165) | 0.0000% | 0.0001% |
| `test2.dds` | 85.69 | 113.56 | **(255,255,222)** | **0.0643%** | 0.1519% |
| `test3.dds` | 79.78 | 114.08 | (255,255,222) | 0.0534% | 0.1179% |
| `test4.dds` | 77.12 | 110.10 | (255,255,222) | 0.0124% | 0.0459% |
| `test8.dds` | 70.73 | 82.08 | (222,231,148) | 0.0000% | 0.0000% |
| `rock4.dds` | 62.96 | 95.05 | (255,239,189) | 0.0002% | 0.0001% |
| `rock8.dds` | **64.68** | 92.07 | (231,211,165) | **0.0000%** | **0.0000%** |
| `grass1.dds` | 74.59 | 85.30 | (87,94,36) | 0.0000% | 0.0000% |

- **Observed (P2):** 57 of 112 DDS contain at least one `minRGB>180` pixel and 87 contain at
  least one `L>180` pixel — but outside `winter*` the largest near-white fraction is
  **0.0643%** (`test2.dds`). Those are sparse bright speckles, not contiguous bands.
- **Derived:** to obtain the observed 4.8156% near-white coverage from summer tile albedo
  alone would require ~75× the densest summer speckle field, and the speckles are scattered
  inside a dark-olive block, not grid-aligned contiguous bands.
- **Observed:** `rock8.dds` is one of the *darkest* tiles (sample L 64.68, no near-white
  pixels at all), despite being named as a pale "cliff" candidate in the task prompt.

### 2.4 `alpha0*` is not an albedo family (observed)

`terrain\tiles\tiles.mat:347-360`:
```
347: Material.Name = alpha0a
348: Material.Texture.image = .\data\terrain\tiles\textures\grass1.dds
349: Material.Texture2Name = alphanull
352: Material.Name = alpha0b
353: Material.Texture.image = .\data\terrain\tiles\textures\grass1.dds
354: Material.Texture2Name = alphanull
357: Material.Name = alpha0c
358: Material.Texture.image = .\data\terrain\tiles\textures\grass1.dds
359: Material.Texture2Name = alphanull
```
**Derived:** `alpha0a/b/c` (Summer preset ids 86/110/123; `terrain.presets:92,116,129`)
reuse `grass1.dds` (L 74.59) and override the second sampler to `alphanull.bmp` (all-zero
mask). They are **dark olive + opaque-zero-mask** aliases, not pale art. No `alpha0*.dds`
exists. This refutes `alpha0*` as a pale albedo source.

### 2.5 Season binding in the observed capture (observed / derived)

- `variant3d\scripts\data.gd:230` `static var BIOME := "summer"`; no BIOME override in
  `variant3d\config.json` or `variant3d\tests\fixtures\small_map_64.json`.
- `variant3d\scripts\game.gd:2033-2037` populates winter art **only** when `BIOME == "winter"`.
- **Derived:** the capture of `RELIEF_VISUAL_01` is a summer map. The only near-white donor
  family (`winter*`) is therefore not on the GPU in that frame.

---

## 3. Assignment rules — when could a pale family land on flat land?

### 3.1 Donor `texturemap.inc:415-646` (observed text; **active runtime UNVERIFIED**)

Every line in this range is prefixed `;` (commented script source), so the shipped text is
an authoring recipe, not proof of live execution. Exact rules:

| `path:line` | Rule | Flat-land consequence |
|---|---|---|
| `texturemap.inc:426` | `height := GetHeightData(realx,realy)`; `lh/rh/th/bh/rbh` from ±1 neighbours (`:433-437`); `len>0.01` gate (`:442`) | On genuinely flat land `len≈0`, so **no sector override fires at all**. This is a hard gate: the entire aspect-driven assignment needs a gradient. |
| `:463-471` | `gMapMask[ix,iy].b>0` and `height<cWaterHeight` / `<cWaterShoreHeight` → water / shore | Requires a **water mask**; flat dry land excluded. |
| `:479-511` | `vecangle+180`, eight 45° sectors → `sandsea5/6/1` (`:504-511`) | Shoreline only; `sandsea*` (the palest summer family, L≈118) cannot appear on flat dry land. |
| `:514-521` | `rock8`/`rock4` overrides inside a comment-while-comment block | Disabled even in the authored text. |
| `:557-591` | map edge or `GetMapCollisionTagInRadius(...)>0` → `rock7/1/3/4` by aspect | Edge/collision only. |
| `:594-601` | `abs(h)>2.7 → rock8`; `>2.4 → rock4`; `abs(h)<0.1 → newtile:=''` | **Derived:** `rock8` requires real height magnitude >2.7 m. On flat land with `h≈const` and `|h|<0.1`, the rule explicitly *clears* the tile. `rock8` cannot explain flat-land marks — and in any case its albedo is dark (§2.3). |
| `:617-646` | `cPlaceRoads` and `gMapMask[x,y].broad` → `ground1` p=0.5, `test2` p=0.25, `test3` p=0.25 | Road-mask only. `test2/3` are the brightest summer speckle tiles, but they are **road** art and are not produced on plain grass. |
| `:652` | `exit;` at the start of the stage-3 block | **Derived:** even if the file were uncommented, the whole `:650-959` stage is short-circuited. Confirms "text only". |
| `:936-954` | `sand1`/`sand2` for water cells | Inside `{...}` comment block; disabled. |

**Conclusion (derived):** in the shipped donor text, **no rule assigns `sand*`, `sandrock*`,
`alpha0*`, `rock8` or even `sandsea*` to a flat, dry, gradient-free cell.** The only
flat-land art assignment is the detail-bitmap pass below, which selects grass/test tiles.

### 3.2 Detail bitmap — the *actual* flat-land selector (observed text; runtime UNVERIFIED)

`scripts\common.inc\loadtextureterrainfrombitmap.inc:4-9,18-42`:
- `:4` `cLowHeight = 0.1`; `:8-9` load `tile_lowground.bmp` / `tile_highground.bmp`.
- `:25-29` `h < 0.1` → low bitmap, else high bitmap.
- `:33` `r := floor(fr*255)`; `:36` `tex := r div 2`.
- `:37-41` **only cells whose current index is 0** are overwritten.

From `DTRN_06` C07/C08 (independent prior measurement, corroborated by this read):
`tile_lowground.bmp` R∈[0,170] yields ids `0 grass1`, `1 grass2`, `79 test8`, `78 test7`,
`83 test12`, `85 test14`; `tile_highground.bmp` yields `78/79/80/85` and `7 grass8`.
Patch width median 1–2 cells, p90 3–6 cells.

**Derived:** on flat land (`h≈const`, either side of 0.1) the donor can place only dark-olive
`test7/8/9/12/14` and grass ids — all with sample L ≈ 70–79 and **zero** near-white
coverage (§2.3). No pale family enters this path. This is the L2 "mottling" of DTRN_06 §3.2.

### 3.3 `tilesmooth_scripts.cfg` transition rules (observed, three passes)

Structure confirmed from `smoothtiles.inc:35-60,63-80,84-187,191-237`: each top-level
`[*]` item is a compatibility chain; each `SmoothTiles` sub-list is a weighted replacement
group; `FindRandomTileIndex` roulette-selects from `SumProb`; `SmoothTileMap(...,3)` runs
horizontal then vertical sweeps (`:237`), writes back all cells (`:240-242`). All script
lines are `;`-commented — active runtime UNVERIFIED.

Active (non-commented) rules relevant to pale families:

| `path:line` | Group | Weights | Meaning for flat land |
|---|---|---|---|
| `tilesmooth_scripts.cfg:8-21` | `sandsea1..4` | 1 each | shore only |
| `:28-33` | `sandsea5/6` | 0.7 / 0.3 | shore only |
| **`:37-50`** | `sandrock1/3` | 0.4 / 0.6 | **commented out** — no active rule assigns `sandrock*` in Item 0 |
| `:54-63` | `rock9/rock8/rock5` | **0.0 / 0.0 / 0.0** | `rock8` is a zero-probability sentinel: roulette (`smoothtiles.inc:74`) can never pick it |
| `:70-91` | `rock1/2/3/6/7/4` | 0.16×5, 0.20 | cliff family only |
| `:134-151`, `:230-247`, `:322-339` | `sandrock1/3`, `sandrock4/2` | 0.4/0.6, 0.6/0.4 | Items 1/2/3 chains; can be a *midpoint replacement* only if a `sandrock*` tile is already present at one end — flat grass has none |
| `:158-167`, `:254-263` | `grass1`, `grass2`, `test8` | 1 / 1 / 1 | **grass/test8 compatibility group** — replacement by dark-olive art only |
| `:174-187` | `grass7`, `test12/13/14` | 0.25 each | dark-olive transitions |
| `:270-279` | `test7`, `grass8`, `test6` | 1 each | dark-olive transitions |
| `:362-372`, `:487-493` | `grass9`, `test9` | 1 each | dark-olive transitions |
| `:970-975`, `:1300`, `:1421` | winter variants of the above | — | season aliases only |

**Observed:** no active `TileName = sand1..sand9`, `TileName = alpha0*`, or
`TileName = rock8` with nonzero probability exists anywhere in the 1,863-line file.
**Derived:** smoothing cannot introduce a pale family onto flat land; it only reconciles
already-present dark grass/test tiles.

### 3.4 Port implementation of the same rules (observed, read-only)

| `path:line` | Fact |
|---|---|
| `game.gd:47-51` | port claims donor tile pipeline: base → TextureMap → 3-pass SmoothTileMap → detail |
| `game.gd:1895-1928` | `_apply_detail_pass()` mirrors `h<0.1`, `tex = int(R*255)/2`, only index 0 |
| `game.gd:1549-1580` | `DONOR_SMOOTH_RULES` embeds 118 active cfg lists, including `rock8` at `SumProb=0` (`:1553`) and `test8` at `:1561/:1569/:1577` |
| `game.gd:1933-2028` | `_assign_tileblocks()`: base grass1 (`:1958`), road ground1/test2/test3 (`:1966-1971`), sand1/2/7 for terrain 4 (`:1988`), rock family for terrain 5 (`:1990-2001`), shore/cliffs (`:2009`), detail (`:2015`), smoothing (`:2019`) |
| `game.gd:2101-2102` | `absf(h0)<0.1 → return ""` — no cliff tile on flat land, same as donor `:600` |
| `game.gd:2033-2037` | winter art only when `BIOME=="winter"` |

### 3.5 Same-seed dump — what actually lands on flat cells (observed, P3)

`app\shots\t6t90_dumps\dump_20261113_a.json` (seed **20261113**, 320²; base64
`tileblock`/`height` decoded read-only):

| Metric | Value |
|---|---:|
| `height` min / max / mean / std | −2.964 / +2.964 / 0.5664 / 1.1911 |
| flat cells `|h − median| < 0.01` | **66,252 / 102,400** |
| Top ids overall | `14:28,558`, `0:16,075`, `16:15,929`, `79:7,657`, `78:6,694`, `25:4,130`, `1:2,842`, `24:2,339`, `80:2,233`, `85:2,186` |
| Top ids on flat cells | `14:19,335`, `0:15,291`, `16:10,929`, `79:5,807`, `78:3,413`, `1:2,414`, `25:1,426`, `80:786` |
| Water id 255 | 0 |

**Derived:** the flat land is dominated by ids `14/0/16/79/78` — `grass_ground1`,
`grass1`, `grass_ground3`, `test8`, `test7` — all dark olive (L 70–79). **`test9` (id 80)
is present on 786 flat cells**, and `test7` (id 78) on 3,413. These are exactly the ids the
port's approximate alpha-patch rule maps to very low/zero alpha (§4.4). No pale family
appears on flat land in this dump.

---

## 4. Alpha atlas seam-mask analysis — independent verification

### 4.1 Raw bytes (observed, P1 + P3, independent hand decoder)

`C:\Games\Cossacks 3\data\terrain\tiles\textures\alpha.bmp`:

| Field | Raw value |
|---|---|
| File size | 132,142 B; `filesize@2` = 132,142 (closure) |
| Signature / DIB | `BM`, 40-byte BITMAPINFOHEADER, compression 0 (BI_RGB) |
| Dimensions | `w@18 = 512`, `h@22 = 256` |
| bpp / planes | 8 / 1; palette used 254 (`@46`), total 254 (`@50`) but 256×4 slots present |
| Pixel data | `@10 = 1070`; 132,142 − 1,070 = **131,072 = 512×256** (exact closure) |
| Palette quirk | indices 0–3 → intensity 0, index 4 → 1, … index **253 → 255**, indices 254/255 → 0 |
| Data index range | 0…253, 254 distinct; intensity mean **139.86** |

Hand-decoded bottom-up pixel array matched Pillow `convert('L')` with **max abs difference
0.0** over all 131,072 pixels, and all 32 patch means matched exactly (P3 pass).

### 4.2 Patch grid and sentinel patches (observed, P1+P2+P3)

Seam jumps occur only at x/y multiples of 64 (independent measurements):
`x=64:126.70, 128:64.33, 192:183.19, 256:184.83, 320:126.94, 384:64.27, 448:183.09`;
`y=64:123.34, 128:121.77, 192:192.56`.
Patch means (row-major, c0…c7), top-left origin:

```
r0: 255.0  52.3  50.5 132.4 | 255.0  77.7  72.7 154.1
r1:  56.5 136.3 157.9 213.5 |  58.3 157.7 180.1 206.4
r2:  45.6 153.5 134.2 210.0 |  82.8 174.5 143.1 199.9
r3: 136.9 210.1 216.4   0.0 | 152.2 196.7 203.3   0.0
```

- Exactly **four constant patches**: `(0,0)` and `(4,0)` = 255; `(3,3)` and `(7,3)` = 0.
- 28 graded patches span 0…255 with 234–251 distinct levels each; mean edge darkness
  gives row roles N / W / E / S (`DALPHA_01 §3.4`, corroborated by these bytes).
- **Confirmed** geometry: 8 columns × 4 rows × 64². **PARTIAL** complement structure:
  only the four constant pairs sum exactly to 255; best graded pair MAD 9.77
  (DALPHA_01 §3.3; my byte pass reproduces the constant-pair fact independently).
- The exact donor `tile-id + boundary direction → patch` rule remains **UNVERIFIED**
  (DALPHA_01 verdict 6; no donor function computes an index).

### 4.3 Port mechanism (observed + derived)

| `path:line` | Fact |
|---|---|
| `terrain_tileindex.gdshader:43` | `render_mode blend_mix, unshaded, cull_disabled` — **one** pass over a background |
| `:27-29`, `:235-240` | `blend_mix` is declared a PORT APPROXIMATION of donor's two-pass `bmTransparency`; `mask_to_alpha = 1.0` is a diagnostic knob that re-applies mask intensity as Godot framebuffer ALPHA |
| `:469` | `ALPHA = mix(1.0, a, mask_to_alpha)` — with shipped default 1.0, **ALPHA == sampled mask `a`** |
| `:66`, `:222`, `:314` | `alpha_atlas` sampler; `alpha_uv_scale = 1.0`; `v_alpha_uv = fract(v_st * uv_repeat) * alpha_uv_scale`, `uv_repeat = 0.5` (`:214`) → one full mask sub-rect per 2 m cell |
| `:363-376` | `alpha_patch_uv()` — PORT APPROX tile-id→patch stand-in: `dir=id%4`, `row=dir`, `variant=(id/4)%4`, `half=(id/16)%2`, `opp=(id/64)%2`, then `row/variant → 3−x` when `opp`; UV = `(cell + t)/vec2(8,4)`, `t` inset to half a texel |
| `:417` | `a = texture(alpha_atlas, alpha_patch_uv(v_tile, v_alpha_uv)).a` |
| `DTRN_06 C27` | port `alpha.png` is byte-identical to donor BMP intensities (MAD 0.0) — mask *data* faithful, *mapping* approximate |

**Derived consequence:** with `ALPHA = a`, a tile whose stand-in patch is `(3,3)` or
`(7,3)` renders **fully transparent**, and a patch with mean 56.5 renders ~78% transparent.
The background sky/water then shows through the ground. This is a *real* mechanism for
pale, cell/2 m-grid-aligned bands — but it is a **port** blend-structure defect, not donor
seam-mask art.

### 4.4 Independent replay of the port patch rule (observed, P3)

Applying `:363-376` to every id 0…123 and reading the measured patch means:

| Tile id | Name (Summer) | → patch (c,r) | mean alpha | alpha fraction |
|---:|---|---:|---:|---:|
| 0 | `grass1` | (0,0) | 255.0 | 1.000 |
| 1 | `grass2` | (0,1) | **56.5** | **0.222** |
| 14 | `grass_ground1` | (3,2) | 210.0 | 0.824 |
| 16 | `grass_ground3` | (4,0) | 255.0 | 1.000 |
| 17 | `rock1` | (4,1) | **58.3** | **0.229** |
| 24 | `rock8` | (6,0) | **72.7** | **0.285** |
| 26 | `sand1` | (6,2) | 143.1 | 0.561 |
| 73 | `test2` | (1,2) | 153.5 | 0.602 |
| 78 | `test7` | (0,1) | **56.5** | **0.222** |
| 79 | `test8` | (0,0) | 255.0 | 1.000 |
| **80** | **`test9`** | **(7,3)** | **0.0** | **0.000** |
| 86 | `alpha0a` | (6,1) | 180.1 | 0.706 |

Constant-zero patches are reached by ids **15, 31, 47, 63, 64, 80, 96, 112**; constant-255
patches by **0, 16, 32, 48, 79, 95, 111**.

**Derived (important):** `test9` (id 80) — placed on **flat land** by the donor detail pass /
port `_apply_detail_pass` — maps to the all-zero mask patch in the port APPROX rule, so
those cells are **fully transparent**. `test7` (id 78) maps to a 56.5-mean patch (~78%
transparent). Because the detail-bitmap patches are 1–6 cells wide (DTRN_06 C08), this
produces **stepped, grid-aligned clusters** of pale bleed-through — matching the observed
band geometry. **Inferred**, not proven: the donor's true patch rule is UNVERIFIED, so this
is a port-side attribution only.

### 4.5 Observed-frame colour forensics (observed, P2/P3 — decisive)

Independent inline PIL/NumPy read of `relief_on.png.raw.png` (1280×720):

| Metric | Value |
|---|---:|
| mean RGB (Rec.601 luma) | `[112.39, 119.65, 77.19]`, L₆₀₁ **112.638** (Rec.709 mean 115.039 from `smallmap_capture.py`) |
| pixels with `min(R,G,B)>180` | 44,381 (4.8156%) — matches `RELIEF_VISUAL_01 §3.2` |
| pixels with `min(R,G,B)>200 / >210 / >230` | **31 / 10 / 1** |
| dominant colour among `minRGB>180` | **(181,234,255)** ×21,750 and **(182,233,255)** ×17,819 |
| median RGB of `minRGB>180` | **(181,233,255)**; mean L₆₀₁ 219.92, p10 219.96, p90 220.55 |
| mean channel spread of those pixels | 72.38 (strongly blue-dominant) |

`(181,233,255)` is the capture's own sky-corner pixel `(0.7137,0.9137,1.0)` from
`RELIEF_VISUAL_01:105`. **Derived:** the "near-white" count is overwhelmingly **sky/water
cyan**, not neutral albedo. There are essentially no `minRGB>200` pixels, so no broad
near-white tile art is present in the frame.

Olive→sky mixture fit (`sky=(181.5,233.5,255)`, `olive=(96,100,35)` measured from the
centre-left grass region), least-squares sky fraction α:

| Region | α mean | α>0.2 | median residual | pixels within 30 Euclid of winter-white (247,247,247) |
|---|---:|---:|---:|---:|
| top-left pale band | **0.306** | 42.27% | 11.03 | **0 / 145,200** |
| right pale band | **0.288** | 41.13% | 15.65 | 3 / 290,000 |
| bottom-left pale band | **0.307** | 42.47% | 13.11 | 0 / 48,600 |
| bottom-right pale band | **0.267** | 37.67% | 13.18 | 0 / 81,700 |
| centre olive control | **0.026** | 1.42% | 9.11 | 0 / 168,000 |

**Derived:** pale-band pixels lie on the line between olive ground and sky cyan (small
residual = authored grain), with ~27–31% sky contribution; the olive control has ~3%.
**Inferred:** the bands are ground made semi-transparent by the mask-as-framebuffer-alpha
path, showing sky/water behind; they are **not** winter albedo and **not** pale summer
albedo. This is the port's M1 defect (`DTRN_06 §4.2`), not a donor albedo family.

### 4.6 Verdict on the alpha-mask hypothesis

- **VERIFIED (observed bytes + pixels):** the atlas is 8×4×64² with four constant sentinels;
  the port binds it with `ALPHA = a`; the port's id→patch stand-in maps flat-land `test9`
  to the constant-0 patch and `test7` to a 56.5-mean patch; the observed frame's pale pixels
  are sky-cyan and fit an olive→sky mixture.
- **REFUTED (derived):** the *donor* seam mask itself is not the source of broad pale bands:
  its graded masks are organic feathers with mean 45–216, and the exact tile→patch rule is
  UNVERIFIED. The pale bands require the **port's** one-pass `blend_mix` + mask-as-alpha
  substitute; without a background to show through (flat P0 control, `TERRAIN_MARKS_01 §1`)
  no marks appear.
- **UNVERIFIED:** donor GPU A/B of `bmTransparency` two-pass vs port one-pass; the true donor
  patch index; whether the donor engine would ever select the constant-0 patches for these
  tile pairs.

---

## 5. Hypothesis table — observed band geometry → candidate mechanisms

Observed geometry (from `RELIEF_VISUAL_01 §3.1-3.2` and §4.5 of this report): pale,
**stepped / concentric**, grid-aligned bands covering top-left, right and bottom quadrants;
**not** free-form hill silhouettes; pale pixels are cyan-dominant `(181,233,255)`; no
neutral-white albedo. The 2 m repeat period is **derived/inferred** from the port's
`uv_repeat=0.5` (`shader:214`) plus the 1–6-cell donor detail-patch scale, not directly
measured in screen space.

| # | Candidate mechanism | Donor/port evidence (`path:line`) | Status against observed frame | Label |
|---:|---|---|---|---|
| H1 | **Pale summer albedo family** (`sand*`, `sandrock*`, `rock8`, `test*`) placed on flat land | §2.2/§2.3: all summer families L≤118.5, NW180=0 at block scale, max 0.0643% at native scale; §3.1-3.3: no nonzero rule assigns them to flat gradient-free cells | **REFUTED** — colour is cyan, not olive/tan; no neutral-white pixels; assignment gates require shore/height/road/debug | observed + derived |
| H2 | **Winter albedo** (`winter*.dds`, L 199–253) bound into a summer map | §2.2/§2.5: only near-white family; `data.gd:230` BIOME=summer, `game.gd:2033-2037` | **REFUTED** — 0–3 pixels within 30 of winter-white in ~745k band pixels; winter atlas not bound | observed + derived |
| H3 | **`rock8` / cliff art on flat land** | `texturemap.inc:594-601` requires `abs(h)>2.7`; `game.gd:2101-2102` returns "" if `abs(h0)<0.1`; `rock8.dds` L 64.68, NW180=0 | **REFUTED** — no height gate satisfied and the art is dark | derived |
| H4 | **`plt2` coarse-grid relief stamp read as a flat pale decal** | `TERRAIN_MARKS_01 §2 rank 3`; `RELIEF_VISUAL_01 §1` flag gates only `--dump-map`, seed 20261113 dump stamp array empty | **REFUTED for this frame** — no stamp array, no height change; and a height stamp writes geometry, not colour | derived / UNVERIFIED generally |
| H5 | **Alpha-atlas seam-mask feather exposed as sky bleed (port one-pass `blend_mix`)** | `shader:43,235,469`; `DTRN_06 M1/M3`; §4.4 id→patch replay (`test9`→0.0, `test7`→56.5); §4.5 olive→sky fit α≈0.27–0.31 vs 0.026 control; flat P0 control has no marks (`TERRAIN_MARKS_01`) | **BEST SUPPORTED** — explains cyan hue, cell-grid stepping and absence in the sky-free P0 frame; donor parity UNVERIFIED | observed + derived; attribution **inferred** |
| H6 | **Donor-authored tile→alpha-patch selection itself produces the bands** | `DALPHA_01` verdict: rule `CONFIRMED_UNVERIFIED`; exact complements only sentinel pairs; all `texturemap.inc`/`smoothtiles.inc` lines `;`-commented | **UNVERIFIED** — data geometry confirmed, rule and runtime not; cannot be credited or excluded from donor text alone | UNVERIFIED |
| H7 | **Transparent water plane drawn over ground** rather than sky bleed | §4.5 background colour `(181,233,255)` equals the sky corner; water patches are separate cyan areas described at `RELIEF_VISUAL_01:139-140` | **PARTIALLY SUPPORTED** — background-through-ground confirmed; sky vs water identity UNVERIFIED (no depth buffer in the artifact) | inferred / UNVERIFIED |

**Ranking:** H5 ≫ H7 > H6 ≫ H1 ≈ H2 ≈ H3 ≈ H4. H5 is the only mechanism that explains
all three decisive observations simultaneously: the cyan hue, the 2 m-grid stepping, and
the absence of marks in the flat P0 control.

---

## 6. Discriminating test (code-free, NOT run by this worker)

Goal: separate H5 (alpha bleed) from H1/H2 (albedo) and H4 (relief geometry) **without
editing any code**, using only existing dump/capture paths and read-only pixel analysis.

1. **Existing dump + palette prediction (cheapest, already partly executed in §3.5/§4.4).**
   Run `python variant3d\tools\godot_runner.py run ... -- --dump-map` with the same
   `--config variant3d/tests/fixtures/small_map_64.json` and seed 20261113 (no code edit).
   Decode `tileblock` (base64 `PackedByteArray`), histogram ids on flat cells
   (`|h−median|<0.01`), and apply the §4.4 id→patch table.
   - **H5 prediction:** the pale-band cells are enriched in ids 80 (`test9`, α=0), 78
     (`test7`, α=56.5), 1/17 (α≈56) and depleted in ids 0/79 (α=255).
   - **H1/H2 prediction:** the pale-band cells are enriched in pale-albedo ids (winter
     aliases or `sandsea*`/`test2`); no correlation with the low-α id set.
2. **Existing capture colour test (executable on any already-saved PNG; no new job needed).**
   For the raw frame, compute (a) the exact dominant colour of the pale pixels and (b) the
   least-squares fit of each pale pixel to `olive + α(sky−olive)`.
   - α≈0.25–0.35 with residual ≈ grain ⇒ H5.
   - near-neutral `(≈247,247,247)` with α≈0 ⇒ H2.
   - tan `(≈214,207,189)` with α≈0 ⇒ H1.
   This test was **already executed** on `relief_on.png.raw.png` (§4.5): result H5.
3. **Sky-free control A/B using existing CLI flags only.** Submit two windowed captures with
   the same seed/fixture/camera, one with the default `gameplay.screenshot_focus=start`
   (sky strip visible) and one via a temporary `--config` overlay setting
   `gameplay.screenshot_focus=relief` (`main.gd:71,184,1119-1136`) so the frame is framed
   over flat ground with no sky at the top. Config overlay is **not** a code edit.
   - If the bands vanish or lose their cyan dominance when no background is visible ⇒ H5
     confirmed; if they persist with unchanged hue ⇒ albedo (H1/H2).
   - Guard: `_is_blank()` (`main.gd:1932-1942`) may again mark the frame failed because of a
     bright corner; inspect the `.raw.png` sidecar, as `RELIEF_VISUAL_01` did.
4. **Flat P0 re-read (zero cost).** The existing P0 control (`TERRAIN_MARKS_01 §1`: all ids 0,
   max luma 149, zero pixels >160) has no sky and no marks. Re-running the §4.5 classifier
   on `p0_final_formula.png` must return α≈0 and zero cyan-dominant pixels; that is the
   negative control for H5.

**Interpretation guard:** all four tests are PORT APPROX. H5's donor parity (whether the
real `bmTransparency` two-pass would show the same bands) stays UNVERIFIED without a donor
GPU A/B frame. No parity claim.

---

## 7. Open questions (UNVERIFIED — do not guess)

1. Where are `WHITE_MARKS_PIX_01.md` and `QA_WHITE_MARKS_01.md`? They are absent from every
   branch/working tree searched; this report used `RELIEF_VISUAL_01` as the pixel source.
2. Do other owner captures (not ticket 532) show pale bands with a **neutral** hue? If so,
   H2/H1 must be re-evaluated per frame; the single analyzed frame is cyan-dominant.
3. What is the donor's true `tile-id + boundary direction → alpha patch` rule? DALPHA-01
   leaves it `CONFIRMED_UNVERIFIED`; the port's `alpha_patch_uv()` is an admitted stand-in.
4. Are ids 80/78 spatially co-located with the observed bands in a **64²** dump of this exact
   seed? The available same-seed dump is 320²; map size changes the detail-bitmap resampling.
5. Does the donor engine ever select the constant-0 sentinel patches `(3,3)/(7,3)`, and with
   what tile pair? No donor function computing a patch index was found.
6. Is the background behind the ground specifically sky or the water plane? No depth buffer
   is available in the raw PNG sidecar; both are equally consistent with the colour fit.
7. Would setting `mask_to_alpha=0.0` (shader `:235`, no config setter exists today) remove
   the bands? This requires a code/shader edit and was **not** done under this read-only
   mandate — it is the strongest future A/B, but out of scope here.
8. Active runtime of `texturemap.inc`, `smoothtiles.inc` and
   `loadtextureterrainfrombitmap.inc`: every line is `;`-commented in the shipped donor
   files. Text rules are **observed**; live execution is UNVERIFIED.
9. Donor parity of hue, grain, band geometry and luma remains blocked: no donor GPU A/B
   terrain frame exists. No parity claim.

---

## 8. Summary

- **observed (albedo):** all **112** donor `terrain\tiles\textures\*.dds` were decoded.
  Every summer family is mid-tone (family means L 65.99–118.52) with **zero** near-white
  pixels at block scale; even at native resolution the densest summer speckle field
  (`test2.dds`) reaches only **0.0643%** `minRGB>180`. `rock8.dds` is dark (L 64.68).
  The only near-white family is `winter*` (L 152–253, up to 100% near-white), and the
  observed capture is a summer map (`data.gd:230`; `game.gd:2033-2037`).
  `alpha0a/b/c` are dark `grass1.dds` aliases with a zero mask (`tiles.mat:347-360`), not
  pale art.
- **observed (rules):** `texturemap.inc:415-646` assigns `rock8` only at `abs(h)>2.7`
  (`:594-601`), `sandsea*` only behind a water mask and a gradient (`:463-511`), roads only
  behind `broad` (`:617-646`); the whole stage is further short-circuited by `exit;` at
  `:652` and all lines are `;`-commented. `tilesmooth_scripts.cfg` has no active nonzero
  rule for `sand1..9` or `alpha0*`, and `rock8` sits at `Prob=0.0` (`:58-59`). Flat-land
  variety comes only from `tile_low/highground` → `grass1/test7/8/9/12/14`
  (`loadtextureterrainfrombitmap.inc:25-41`), all dark olive.
- **observed (alpha):** `alpha.bmp` raw bytes close exactly to 512×256×8 with a 256-slot
  palette; 8×4×64² patches with four constants (255,255,0,0); hand decoder = Pillow
  (MAD 0.0). The port binds it as framebuffer ALPHA (`shader:469`), and its APPROX
  id→patch rule maps flat-land `test9` (id 80) to the constant-0 patch and `test7` (id 78)
  to mean 56.5 — i.e. transparent cells. A same-seed dump confirms both ids occur on flat
  cells (786 and 3,413 respectively).
- **observed (frame forensics):** the 44,381 "near-white" pixels of `RELIEF_VISUAL_01` are
  dominated by exact colour **(181,234,255)** — the capture's sky corner — with only 31
  pixels above `minRGB>200`. Pale-band pixels fit an olive→sky mixture at α≈0.27–0.31
  (control 0.026) and 0 of ~745k match winter-white.
- **derived / inferred:** the stepped bands are **sky/water bleed-through caused by the
  port's one-pass `blend_mix` + mask-as-alpha substitute acting on flat-land `test7/test9`
  tiles**, not donor pale albedo and not relief geometry. Best-supported hypothesis H5;
  donor albedo families H1–H3 are refuted for this frame; the donor's own patch-selection
  rule (H6) is UNVERIFIED.
- **No donor parity claim.** No code, asset, config, test, shader, git or donor file was
  modified; no donor binary was executed or copied; no runner job was submitted.

---

*End of PALE TILES DEEP 01. Read-only donor deep dive, 3 passes. No donor parity claim.*
