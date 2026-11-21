# TDR-3 — Donor terrain visual asset inventory (read-only audit)

**Lane:** RESEARCH / DEEP-DIVE. **Scope:** donor-only asset census + port gap analysis.
**No donor binaries were copied or written into the repository. No Godot runs were performed. No source files were edited.**

---

## 1. Sources / method

### Donor sources (all under `C:\Games\Cossacks 3`, private-use only — never redistribute)
- `data\gen\terrainmasks\` — post-processed ("gauss") random-map masks.
- `data\gen\terrainmasks.src\` — pre-process source masks (256×256).
- `data\gen\terrainmasks.dlc5\` — DLC5 mask set (adds coastal/lakes/rivers).
- `data\gen\bitmap\` — mission bitmaps and height-source bitmaps.
- `data\gen\globalparams.cfg`, `localparams.cfg`, `mapcover.cfg`, `tilesmooth.cfg`, `tilesmooth_scripts.cfg`.
- `data\terrain\tiles\` (textures, `tiles.mat`, `tiles.lib`, `terrain.lib`, `terrain.presets`, `tiles.season`), `data\terrain\decals\`, `data\terrain\covers\`, `data\terrain\cliffs\`, `data\terrain\ref\`.
- `data\env\` (`clouds`, `colors`, `flares`, `lights`, `pfx`, `skydome`), `data\water\`, `data\materials\env\`, `data\materials\pfx\`, `data\pfx\textures\`.
- `data\game\var\generator.cfg`, `data\game\var\envscales.cfg`.

### Port sources (read-only listing + code grep)
- `app\assets\terrain\**` — `blocks/` (112 PNG), `masks/` (7 families × 8 PNG), `water_png/` (8), `decals_png/` (462), `decals_dds/` (462), `deco_png/` (7), `dmask/` (24), `structs/` (6), `patterns/donor_patterns.json`, plus 20 root-level PNGs.
- `app\scripts\world.gd`, `game.gd`, `mapgen.gd`, `data.gd`, `menu.gd`, `pattern_gen.gd` — read only to establish wired/unwired status.
- Existing audits (`docs/audit/TERRAIN_PORT_ASSETS.md`, `TERRAIN_PORT_DECOR.md`, `TERRAIN_GEN_RESEARCH.md`) were **not** used as evidence; all findings below were re-derived.

### Method (observed)
- Python 3.14.3 + Pillow 12.1.1: `os.listdir` / `os.walk` for exact file counts; `Image.open().size/.mode/.format` for dimensions and pixel modes; `ImageChops.difference` for pixel-identity checks.
- PowerShell `Get-ChildItem` for cross-checking recursive totals.
- Text configs decoded with `utf-8`/`cp1251`/`cp1252`/`latin-1` fallback; `generator.cfg` decoded as **cp1251** (70,074 bytes, 2,368 lines), `envscales.cfg` as **utf-8** (25,612 bytes, 870 lines).
- Labels used below: `observed` = directly measured; `derived` = arithmetic/cross-reference of observed counts; `inferred` = interpretation with a stated caveat; `UNVERIFIED` = not confirmed by this audit.

---

## 2. Mask inventory

### 2.1 Headline totals (observed)

| Root | Files (recursive) | TGA | Other | Per-family dimensions | Pixel mode |
|---|---|---|---|---|---|
| `gen\terrainmasks` | 1,336 | 1,331 | 4 `.removed`, 1 `moddersread.txt` | 320×320 (all 1,331) | RGB |
| `gen\terrainmasks.src` | 1,281 | 1,279 | 1 `convert_rle.bat`, 1 `moddersread.txt` | 256×256 (all 1,279) | RGB |
| `gen\terrainmasks.dlc5` | 1,861 | 1,856 | 4 `.removed`, 1 `moddersread.txt` | 320×320 (all 1,856) | RGB |

**Grand total donor mask TGAs: 1,331 + 1,279 + 1,856 = 4,466** (`derived`). All are uncompressed 24-bit RGB TGA (`observed`).

`moddersread.txt` (all three roots, identical text, `observed`): "`Xpl_*_gauss.tga (X - corresponds on how many starting points are in water map mask)`"; "`All folders should have at least one map with 7pl_*`"; "`_gauss` … postprocess … prepare flat land/water texture … smooth with noised water borders"; "`post process files is resized to proper default map size 320x320px, while source files was 256x256`".

### 2.2 Mask inventory table — per shape family, per root, per player count

Player-count splits are from filename prefix `(\d+)pl_` (`observed`, all sampled white-marker counts match the prefix — see §2.3).

| Family | `terrainmasks` count (player split) | `terrainmasks.src` count (player split) | `terrainmasks.dlc5` count (player split) | Format / dims | Port status |
|---|---|---|---|---|---|
| continent | 121 (4pl 100, 7pl 20, 8pl 1) | 120 (4pl 100, 7pl 20) | 167 (2pl 32, 4pl 100, 7pl 20, 8pl 15) | RGB TGA 320×320 / 256×256 src | 8/121 converted + wired as manifest type `continent` |
| continents | 187 (2pl 40, 3pl 29, 4pl 97, 7pl 20, 8pl 1) | 186 (2pl 40, 3pl 29, 4pl 97, 7pl 20) | 196 (2pl 40, 3pl 29, 4pl 97, 7pl 20, 8pl 10) | RGB TGA 320×320 / 256×256 src | 8/187 converted + wired (`continents`) |
| islands | 320 (2pl 100, 3pl 99, 4pl 100, 7pl 20, 8pl 1) | 319 (2pl 100, 3pl 99, 4pl 100, 7pl 20) | 330 (2pl 100, 3pl 99, 4pl 100, 7pl 20, 8pl 11) | RGB TGA 320×320 / 256×256 src | 8/320 converted + wired (`islands`) |
| land | 230 (4pl 209, 5pl 4, 6pl 12, 7pl 4, 8pl 1) | 221 (4pl 209, 5pl 4, 6pl 4, 7pl 4) | 230 (same split as main) | RGB TGA 320×320 / 256×256 src | 8/230 converted + wired (`land`) — see caveat below |
| mediterranean | 118 (4pl 97, 7pl 20, 8pl 1) **+ 4 `.removed`** | 121 (4pl 101, 7pl 20) | 207 (2pl 57, 4pl 98, 7pl 20, 8pl 32) **+ 4 `.removed`** | RGB TGA 320×320 / 256×256 src | 8/118 converted + wired (`mediterranean`) |
| nowater | 42 (4pl 21, 5pl 4, 6pl 12, 7pl 4, 8pl 1) | 33 (4pl 21, 5pl 4, 6pl 4, 7pl 4) | 42 (same split as main) | RGB TGA 320×320 / 256×256 src | **MISSING** (0 converted) |
| nowater2 | 33 (4pl 12, 5pl 4, 6pl 12, 7pl 4, 8pl 1) | — (no such folder) | 33 (same split as main) | RGB TGA 320×320 | 8/33 converted + wired (`nowater2`, the donor's active "Land" type) |
| peninsulas | 280 (2pl 75, 3pl 99, 4pl 85, 7pl 20, 8pl 1) | 279 (same split minus 8pl) | 286 (2pl 75, 3pl 99, 4pl 85, 7pl 20, 8pl 7) | RGB TGA 320×320 / 256×256 src | 8/280 converted + wired (`peninsulas`) |
| coastal | — (no folder) | — | 57 (2pl 17, 3pl 8, 4pl 10, 6pl 13, 8pl 9) | RGB TGA 320×320 | **MISSING** (DLC5 type 6) |
| lakes | — | — | 151 (2pl 31, 3pl 18, 4pl 27, 5pl 15, 6pl 19, 7pl 15, 8pl 26) | RGB TGA 320×320 | **MISSING** (DLC5 type 7) |
| rivers | — | — | 157 (2pl 32, 3pl 17, 4pl 25, 5pl 17, 6pl 17, 7pl 17, 8pl 32) | RGB TGA 320×320 | **MISSING** (DLC5 type 8) |
| **TOTAL** | **1,331 TGA** | **1,279 TGA** | **1,856 TGA** | — | **56 PNG converted (7 families × 8), 4,410 not converted** |

Caveat (`observed`): the port manifest type `land` points at files from the donor `land` folder, but `generator.cfg` has `path = ...\terrainmasks\land` **commented out** and uses `nowater2` for `0.Land`. The port therefore exposes a family the shipped donor config does not use by default.

Port mask files (`observed`): `app\assets\terrain\masks\<family>\` contains exactly 8 `.png` + 8 `.png.import` per family for the 7 families; `manifest.json` has `"source": "C:/Games/Cossacks 3/data/gen/terrainmasks"`, 7 type keys, 56 mask records, and precomputed `starts` (normalised) + `water` fraction.

### 2.3 Channel meaning and white start markers

**Channel observation (`observed`, exhaustive over all 1,331 main `_gauss` masks):**
- Every mask has exactly **2 distinct R values** and **2 distinct G values** (`{0, 255}`), and B has up to 256 distinct values.
- For **every** one of the 1,331 masks: `count(R==255) == count(G==255) == count((255,255,255))`.
- The pure-white count equals the player-count prefix for **every family and player count** measured (2pl→2, 3pl→3, 4pl→4, 5pl→5, 6pl→6, 7pl→7, 8pl→8 — full matrix measured across all 8 main families and all 11 DLC5 families). Example splits: `continent` 4pl→4 white, 7pl→7 white, 8pl→8 white; `lakes` 2pl→2 … 8pl→26 files each with 8 white.
- B channel is the actual land/water field: e.g. `4pl_mask_continent_0_gauss.tga`: B0=28,854, B255=66,647, B-mid=6,899; `4pl_mask_land_0_gauss.tga`: B0=99,783, B255=1,363, B-mid=1,250; `nowater*` masks have only 2 unique colours total (black field + 4 white markers).
- Identical channel behaviour observed in `.src` (e.g. `4pl_mask_continent_0.tga`: Runiq=2, Guniq=2, Buniq=2) and `.dlc5` samples (e.g. `2pl_mask_coastal_0_gauss.tga`: Runiq=2, Guniq=2, Buniq=238).

**Pixel-identity check (`observed`):** sampled port PNGs are **pixel-identical** to their donor TGA sources (320×320, identical sizes and `ImageChops.difference` bbox `None`): `land/4pl_mask_land_0_gauss`, `mediterranean/4pl_mask_mediterranean_0_gauss`, `nowater2/4pl_mask_nowater_170_gauss`, `islands/2pl_mask_islands_0_gauss`.

**Correction (`observed` → contradicting port code):** the port `masks/manifest.json` note says `RGB terrain masks: R=relief, G=forest/stone, B=water, white=start`, and `mapgen.gd:3` says `R = relief (255 plateau, 96 hill, 48 ravine), G = forest/stone`. The shipped masks contain **no** 96/48 relief values in R and no forest/stone values in G. `mapgen.gd:51-61 relief(v)` reads the R channel of these masks; for all non-marker pixels R=0, so it returns 0. `UNVERIFIED`: whether an internal/non-shipped donor bitmap supplies relief/forest to `generatemap.inc` (the port comment cites that script); no such bitmap was found in the paths audited.

---

## 3. Terrain bitmap / texture inventory

### 3.1 `data\gen\bitmap\` (observed)

- 86 top-level files = **85 `.bmp` + 1 `postpatterns.cfg`**; one subdir `ext\` with **2 `.bmp`**.
- Top-level BMP dimensions: 79 × 320×320, 3 × 384×384, 3 × 512×512. All RGB.
- Family prefixes (count): `scemis` 12, `battle` 8, `ausmis` 5, `engmis` 5, `framis` 5, `netmis` 5, `polmis` 5, `prumis` 5, `rusmis` 5, `scomis` 5, `spamis` 5, `swemis` 5, `turmis` 5, `ukrmis` 5, `celmis` 2, `bitmapsrc` 1, `bonmis` 1, `tutmis` 1. **These are mission/scenario bitmaps, not ground tile families.**
- `ext\`: `tile_highground.bmp`, `tile_lowground.bmp` — both 320×320 RGB. Port status: **converted + wired** as `app\assets\terrain\structs\tile_highground.png` / `tile_lowground.png` (loaded at `game.gd:979-980`).

### 3.2 Real terrain tile art: `data\terrain\tiles\textures\` (observed)

- **115 files = 112 `.dds` + 3 `.bmp`.**
- DDS: 110 × **1024×1024**, `sand1.dds` + `sand2.dds` × **256×256**; all **RGBA**.
- BMPs: `alpha.bmp` 512×256 (palettised `P`), `alphanull.bmp` 512×256 (`L`), `alphavert.bmp` 1024×512 (`RGB`).
- Family counts (112 DDS) vs port `blocks/` (112 PNG):

| Family | Donor DDS | Port PNG | Donor dims | Port status |
|---|---|---|---|---|
| desert | 12 | 12 | 1024×1024 | converted; **unwired by name** (desert biome is a tint in `data.gd:194`) |
| grass | 10 | 10 | 1024×1024 | converted + wired (`grass1` base block, `game.gd:1028`) |
| grass_ground | 3 | 3 | 1024×1024 | converted + wired (`game.gd:1044-1048`) |
| grass_rock | 1 | 1 | 1024×1024 | converted (wiring UNVERIFIED) |
| grass_sand | 2 | 2 | 1024×1024 | converted (wiring UNVERIFIED) |
| ground | 1 | 1 | 1024×1024 | converted + wired (`game.gd:1037`) |
| rock | 9 | 9 | 1024×1024 | converted + wired (`game.gd:1055-1065`) |
| sand | 9 | 9 | 7×1024² + sand1/sand2 256² | converted + wired (`game.gd:1052`) |
| sandrock | 6 | 6 | 1024×1024 | converted (shore-table wiring UNVERIFIED) |
| sandsea | 6 | 6 | 1024×1024 | converted + wired (`game.gd:1082+ _shore_tile_for`) — this is the donor's shoreline treatment |
| test | 26 | 26 | 1024×1024 | converted + wired for `test2`/`test3` (`game.gd:1039-1041`); others unwired |
| winter | 27 | 27 | 1024×1024 | converted; **unwired by name** (winter is a flat tint `Color(0.86,0.91,1.0,1.0)` at `data.gd:193`) |
| **TOTAL** | **112** | **112** | 110×1024² + 2×256² | exact family/count match |

- `observed`: port PNGs are RGB (112/112); donor DDS are RGBA (112/112) — **alpha was dropped** in conversion.
- `data\terrain\tiles\tiles.mat` (`observed`): 253 material→image pairs; 124 winter-alias materials (`*_winter`) map to 35 unique textures — 23 distinct `winter*.dds` + all 12 `desert*.dds` reused. Examples: `grass1_winter → winter10.dds`, `grass2_winter → winter9.dds`, `grass3_winter → winter2.dds`.
- `terrain.presets` (`observed`): Summer set = 124 `TileBlock` entries, `WaterSet = Summer`; Winter set = 124 entries, `WaterSet = Winter`.
- `terrain.lib` (`observed`): `TextureScale X=Y=Z=W=1`; `seasons.Summer=Summer`, `seasons.Autumn=Summer`, `seasons.Winter=Winter`, `seasons.Spring=Summer`; `CoverDisabled=true`.
- `tiles.season` (`observed`): `TexName=grass1`, `Summer=grass1`.
- Port equivalent (`observed`): `structs/presets_summer.json` (1,443 B), `structs/smooth_summer.json` (4,951 B), `structs/tileblocks.json` (26,557 B), `structs/water.json` (114 B); **no winter presets**.

### 3.3 Water (`observed`)

| Donor file | Dims | Mode | Port counterpart |
|---|---|---|---|
| `data\water\textures\diffusewaves0.bmp` | 256×256 | RGB | `water_png/diffusewaves0.png` 256×256 RGB |
| `diffusewaves1.bmp` | 256×256 | RGB | `diffusewaves1.png` 256×256 RGB |
| `diffusewaves2.bmp` … `diffusewaves7.bmp` (6 files) | 512×512 | RGB | `diffusewaves2.png` … `diffusewaves7.png` 512×512 RGB |
| `heightmapwaves0.tga` | 256×256 | RGBA | **MISSING** from port `water_png/` |

`water.mat` (`observed`): active `DiffuseWaves0` (`tfLuminance`) and `DiffuseWaves2` (used as **NormalMapLibMaterialName**); the entire `HeightMapWaves0` material block (`tfNormalMap`) and DiffuseWaves1/3/4/5/6/7 blocks are **commented out**. `water.lib` constants (`observed`): `MaxDepth=1`, `MinDepth=0`, `MaxAlpha=1.1`, `MinAlpha=0`, `DeepColor=(0,0,0.1255,0.5)`, `ShallowColor=(0,0,0,0.5)`, `TexScaleS=0.1`, `TexScaleT=0.01` (commented 0.115/0.015), `WaveDir0=(-1,0)`, `WaveDir1=(-0.7,0.7)`, `Speed=1.0`, `Offset=0.495`, `LayerCount=1`, `WaveFreq=0`, `WaveAmp=0`, `DistFactor=1`, `BumpFactor=1`, `HeightMapEnable=true`, `ShadowMapEnable=true`.

**Foam: `observed` — a full recursive filename search of `C:\Games\Cossacks 3\data\` for `foam|surf|shore|coastline|beach` returned ZERO image files.** The donor's shoreline look is produced by `sandsea1-6` tile blocks, the water shader, and (DLC5) `coastal`/`lakes`/`rivers` masks — not by a foam texture family.

---

## 4. Env / decal / sky inventory

| Donor path | Files (observed) | Dims / mode | Port status |
|---|---|---|---|
| `terrain\decals\buildings\` | 470 = 462 `.dds` + 4 `.lib` + 4 `.mat` | 454×1024², 8×128², 8 unreadable by Pillow (`UNVERIFIED`: likely DX10/BC7-style header); all RGBA. 226 filenames end in `w` (winter), 236 summer | **Converted + wired**: `decals_dds/` (462) + `decals_png/` (462) exact count match; loaded at `world.gd:537` |
| `terrain\decals\env\` | 3 `.dds`: `christmastreed` 1024×1024, `envfieldd` 512×512, `envfielddw` 512×512 | RGBA | Converted into `deco_png/`; **unwired at runtime** (only tooling/docs reference it) |
| `terrain\decals\pfx\` | 4 `.dds`: `groundexp0..3` 512×512 | RGBA | Converted into `deco_png/`; **unwired at runtime** |
| `terrain\covers\`, `terrain\cliffs\` | `covers.lib`/`covers.mat`, `cliffs.lib`/`cliffs.mat` — all **0 bytes** | — | No cover/cliff textures shipped at these paths; nothing to convert |
| `terrain\ref\` | `reftile.lib`, `reftile.mat`, `reftilealpha.mat` | — | Material refs only |
| `env\clouds\textures\` | 12 `.dds`: `dark1-3`, `soft1-3`, `storm1-3`, `volume1-3` | all 256×256 RGBA | **MISSING** (no sky/cloud assets anywhere in `app/assets/`) |
| `env\skydome\textures\menu.dds` | 1 `.dds` | 2048×512 RGBA | **MISSING** (menu sky only) |
| `env\flares\textures\` | 46 = 43 `.tga` + 3 `.bmp` | 29×256², 15×128², 1×64², 1×139×141; RGBA/RGB | **MISSING** |
| `env\pfx\textures\` | 4 `.bmp` (`snow1..4`) | 32×32 RGB | **MISSING** (snow particles) |
| `env\colors\` | 12 `.palette` (`0..11`) + 1 `.lib` | text/palette | **MISSING** — port uses 3 hardcoded tints in `data.gd:193-194` |
| `env\clouds\*`, `env\lights\*` | `.cfg/.mat/.presets/.weather/.ref` only | — | Config-level, out of scope for this asset audit |
| `materials\env\` | **171 images** (`.dds/.tga/.bmp`), **77** with `w` winter suffix | 55×512², 54×1024², 29×2048², 20×512×256, 6×512×1024, 2×256², 2×256×512, 2×904×836, 1×1024×512 | **MISSING**; includes shore rocks `rocksea1-3[w]`, `smallstonessea[w]`, `stonessea[w]`, `plantswateratlas[w]` |
| `materials\pfx\`, `pfx\textures\` | 6 `impwater*` `.dds` (22,000 B each), `waterblast.dds` (5,592,560 B) | not measured (`UNVERIFIED` dims) | **MISSING** |
| Port `deco_png/` | 7 PNG (3 from `decals/env` + 4 from `decals/pfx`) | 1×1024², 6×512² RGB | converted, **unwired** |
| Port `dmask/` | 24 PNG | all 64×64 RGBA | converted, referenced in `world.gd` (`_build_masks` now legacy/no draw code — effective status UNVERIFIED) |

`decals.lib` (`observed`, 63,831 B): each decal defines `SummerLibMaterialName` and `WinterLibMaterialName` (e.g. `polartd → polartdw`, `envfieldd → envfielddw`, `christmastreed` winter entry) plus `width=4`, `height=4`, `texscale=1`, `texrollangle=0`, `epsilon=0.01`. Port implements only the summer/winter building dirt plates via `decals_png`; the seed/overlay decal catalogue is not converted as a system.

---

## 5. Config extract: TerrainType mappings and scale constants

### `data\game\var\generator.cfg` — `TerrainTypes` (observed, lines 1-28)
| Index | `hint` | Mask path |
|---|---|---|
| 0 | `0.Land` | `.\data\gen\terrainmasks\nowater2` (`//path = ...\land` commented out) |
| 1 | `1.Mediterranean` | `.\data\gen\terrainmasks\mediterranean` |
| 2 | `2.Peninsulas` | `.\data\gen\terrainmasks\peninsulas` |
| 3 | `3.Islands` | `.\data\gen\terrainmasks\islands` |
| 4 | `4.Continents` | `.\data\gen\terrainmasks\continents` |
| 5 | `5.Continent` | `.\data\gen\terrainmasks\continent` |

### `TerrainTypesDLC5` (observed, lines 29-66)
Same 0-5 paths under `terrainmasks.dlc5\`, plus **6.Coastal → `coastal`**, **7.Lakes → `lakes`**, **8.Rivers → `rivers`**.

`generator.cfg` also contains a large `Patterns` struct (`observed`, 2,368 lines total; `Patterns` begins line 67) listing pattern families (`mng`, `mni`, `mnc`, `desert_mng/mni/mnc`, hill/ravine/stone/forest/tile groups). The port has a derived `patterns/donor_patterns.json` with `donor_units: 160.0` and per-family pattern lists (`observed`).

### `data\game\var\envscales.cfg` (observed)
870 lines, `EnvGroups` with per-object `scale`, `minscale`, `maxscale`. Examples: `field scale=0.033`, `minecoal/minegold/mineiron scale=0.3152`, most scenery `scale` between 0.209 and 1.02 with `minscale=0.85`, `maxscale=1.15`. **No TerrainType→texture/mask mapping and no terrain texture scale constants** are present in this file — that task-item premise is corrected here.

### Terrain constants in sibling configs (observed)
- `gen\globalparams.cfg`: `Size=512`, `TileChangeFactor=0.3`, `CellsResolution=1`, `DefaultMapSize=256`, `TileSmoothPasses=6`, `TileSmoothListFileName=.\data\gen\tilesmooth.cfg`.
- `gen\localparams.cfg`: `HillPointsDensity=0.00008`, `MaxHillsHeight=0`, `HillsHeightFactor=0.001`, `MinHeight=0`, `MaxHeight=0.0001`.
- `gen\mapcover.cfg`: `HeightZone0 MinHeight=0 MaxHeight=100`, `Frequency=1.0`, `MapFrequency=1`, `BorderFrequency=1`; `SummerTileName/AutumnTileName/WinterTileName/SpringTileName` all **empty**.
- `terrain\tiles\terrain.lib`: `TextureScale` X/Y/Z/W all `1`; season aliases as in §3.2.
- Port `mapgen.gd:13-18` (`observed`, comments attribute to donor scripts): `C_WATER=-1.1`, `C_PLATEAU=2.964`, `C_HILL=2.964/2.25`, `C_RAVINE=-2.964`, `WATER_DEEP=-0.25`, `WATER_SHORE=-0.1`.

---

## 6. Claim table

| # | Claim | Evidence | Method | Verdict | Correction |
|---|---|---|---|---|---|
| C1 | "Donor has a shore-foam texture family the port lacks." | Recursive filename search for `foam|surf|shore|coastline|beach` across all of `data\` → **0 image files**. Shoreline art is `sandsea1-6.dds` (6×1024²) | observed | **REFUTED** | No foam family exists. Shore look = sandsea tiles + water shader + DLC5 coastal/lakes/rivers masks. |
| C2 | "Winter terrain blocks are missing from the port." | `blocks/winter0.png … winter26.png` = **27 files**, matching donor 27 `winter*.dds` | observed | **CORRECTED** | Converted but **unwired**: no `winter*` block name in `game.gd`/`world.gd`; season is a flat tint. |
| C3 | "Port masks carry R=relief, G=forest/stone as documented." | All 1,331 main masks: R unique=2, G unique=2, `R255==G255==white count`; port PNGs pixel-identical to donor | observed + derived | **REFUTED** | R/G are binary and non-zero **only at white player-start markers**. `mapgen.gd.relief()` reads R=0 everywhere → no relief. |
| C4 | "The port has the donor water normal/height map." | Donor `heightmapwaves0.tga` 256×256 RGBA exists; `water_png/` has only `diffusewaves0-7.png` (8) | observed | **REFUTED (low impact)** | Convert it if desired, but donor `water.mat` has the `HeightMapWaves0` material commented out; active normal map is `DiffuseWaves2`. |
| C5 | "`deco_png/` is wired into the game." | `grep` over `app/scripts/*.gd`: **0** hits for `deco_png`, `christmastreed`, `envfieldd`, `envfielddw`, `groundexp`; hits exist only in tools/docs | observed | **REFUTED** | Converted but unwired. |
| C6 | "`data/gen/bitmap/` holds terrain ground/grass/rock families." | 85 top-level BMPs are `*_mis`/`battle*` scenario bitmaps; `ext/` holds only 2 height bitmaps. Terrain art is in `data/terrain/tiles/textures/` | observed | **CORRECTED** | Two distinct directories; see §3.1 and §3.2. |
| C7 | "DLC5 mask families (coastal/lakes/rivers) were converted." | Port `masks/` has 7 dirs only; no `coastal`, `lakes`, `rivers`, no `nowater` | observed | **REFUTED** | 57 + 151 + 157 + 42 donor masks missing. |
| C8 | "Port block PNGs preserve donor alpha." | Donor 112 DDS all mode `RGBA`; port 112 PNG all mode `RGB` | observed | **REFUTED** | Alpha dropped; reconvert to RGBA if blending depends on it. |
| C9 | "Gauss masks are 320×320 derived from 256×256 sources." | All 1,331 main masks 320×320; all 1,279 `.src` masks 256×256; `moddersread.txt` states resizing | observed | **CONFIRMED** | — |
| C10 | "`envscales.cfg` contains TerrainType→texture mappings." | 870 lines of `EnvGroups` object scales only; no mask/texture paths | observed | **REFUTED** | Mappings live in `generator.cfg`; terrain constants in `globalparams.cfg`/`mapcover.cfg`. |
| C11 | "Port supports the donor's 8-player masks." | Donor has 8pl in most families (e.g. 8pl in 8/11 DLC5 families); port manifest max prefix is **7pl** | observed + derived | **UNVERIFIED** (design decision) | No 8pl masks converted; confirm whether 8p is in port scope. |
| C12 | "The 8 unreadable building-decal DDS are corrupt." | Pillow failed on 8 of 462; all other 454 read as 1024² RGBA | observed + `UNVERIFIED` interpretation | Do not claim corruption; inspect DDS headers with a DX10-capable tool before drawing conclusions. |

---

## 7. Recommendations (conversion / wiring, with acceptance criteria)

> Reminder: convert **pixels only** into `app/assets/terrain/**`. Never copy donor binaries into the repo.

### P0 — Fix mask semantics (correctness, biggest beauty impact)
1. **Stop reading relief/forest from R/G of `_gauss` masks.** Either (a) remove `mapgen.gd:51-61 relief()` reliance on R and drive relief from height data (`structs/tile_*ground.png` + `localparams.cfg` constants), or (b) if the donor truly has R=relief bitmaps, locate that source in another lane first (`UNVERIFIED`).
   - **Acceptance:** `mapgen.gd` no longer treats R of an `_gauss` PNG as 96/48 relief; a diagnostic dump of 4 sampled masks shows `R255 == G255 == white count`; two maps with identical seed render with non-zero height variance.

### P0 — Wire the converted seasonal blocks
2. **Wire winter blocks**: add `structs/presets_winter.json` + `structs/smooth_winter.json` derived from `terrain.presets` Winter section (124 `TileBlock` entries; 27 `winter*.dds` + 12 reused `desert*.dds`), and select `winterN` block names in `game.gd:_assign_tileblocks()` when `Data.BIOME == "winter"` instead of the flat tint at `data.gd:193`.
   - **Target:** `app/assets/terrain/structs/presets_winter.json`, `smooth_winter.json`; selection in `app/scripts/game.gd`.
   - **Acceptance:** JSON parses with **124** entries; **27** distinct `blocks/winter*.png` referenced in at least one map; same seed rendered in summer vs winter yields a measurable pixel difference (not just uniform tint); all 27 PNGs are 1024×1024 (2 exceptions none for winter).
3. **Wire desert blocks** similarly (12 `desert*.png`) for `Data.BIOME == "desert"`.
   - **Acceptance:** 12/12 referenced by name; no desert map draws a grass base block where donor preset says desert.

### P1 — Convert missing mask families
4. **DLC5 masks** → `app/assets/terrain/masks/{coastal,lakes,rivers}/`.
   - **Acceptance:** exact file counts **57 / 151 / 157**, all RGB 320×320 PNG, pixel-identical to donor TGA for 4 sampled files per family; `manifest.json` gains 3 type keys, white-marker count per file equals `(\d+)pl_` prefix, and `mapgen.pick()` can select each type.
5. **`nowater` family** (42 masks) → `app/assets/terrain/masks/nowater/`.
   - **Acceptance:** 42 RGB 320×320 PNG, pixel-identical on 4 samples, manifest type added with `water≈0`.
6. **Optional: `.src` 256×256 sources** (1,279 files) — **low priority**; they are pre-Gaussian and visually inferior. Convert only if an editor UI needs them; acceptance would be 256×256, exact per-family counts from §2.2.

### P1 — Wire converted deco / detail assets
7. **`deco_png` (7 files)**: use `envfieldd/envfielddw` for field decals and `groundexp0-3` for ground-impact overlays in `world.gd`.
   - **Acceptance:** runtime loads **7/7** (no missing-resource warnings); screenshot shows at least one deco overlay; grep `app/scripts/*.gd` returns ≥1 hit per family.
8. **Seasonal palettes**: convert `env\colors\0.palette … 11.palette` (12 files) into a documented JSON under `app/assets/terrain/structs/season_palettes.json` and use them instead of the 3 hardcoded colours in `data.gd`.
   - **Acceptance:** 12 palette entries parsed; season selection changes terrain tint from palette data, not literals.

### P2 — Nice-to-have / cross-lane
9. **Water normal map**: convert `heightmapwaves0.tga` → `app/assets/terrain/water_png/heightmapwaves0.png` (256×256 RGBA, pixel-identical). Only wire it if enabling normal mapping; donor default has it disabled.
10. **Env/shore rocks**: 171 `materials\env\` images (77 winter) incl. `rocksea1-3[w]`, `stonessea[w]`, `plantswateratlas[w]` — highest un-converted visual-beauty mass after masks. Target a new `app/assets/terrain/env_png/` (or hand to an env-asset lane). Acceptance: counts per filename family, dimensions per §4 table, pixel-identical samples.
11. **Sky/clouds** (12 cloud DDS, 1 menu sky, 46 flares, 4 snow BMP): no port equivalent exists; flag to an ENV/SKY lane rather than `terrain/**`.
12. **Alpha**: if terrain blending needs donor alpha, reconvert the 112 DDS→PNG preserving RGBA and verify 112/112 mode=`RGBA`.
13. **8-player support**: decide scope; if yes, convert the 8pl masks (1 per main family + up to 32 in DLC5 families) and extend `manifest.json` starts arrays to 8 points.

---

## 8. Open questions

1. **Where do R=relief / G=forest values actually live in the donor?** All shipped mask TGAs are binary in R/G. `UNVERIFIED`: inspect `data\scripts\generatemap.inc`, `dogenerate.inc`, `texturemap.inc`, `editor.aix` post-process script in a separate code lane (this lane is asset-only).
2. **Why are `land` and `nowater` commented out / unused in `generator.cfg` while the port wires `land` anyway?** Historical or DLC-related? `UNVERIFIED`.
3. **Why exactly 4 `.removed` files in `mediterranean`** in both `terrainmasks` and `.dlc5`? Contents/deletion reason `UNVERIFIED`.
4. **Which 4 of the 27 `winter*.dds` are unused** by `tiles.mat` (23 winter textures are referenced)? Likely leftovers; `UNVERIFIED`.
5. **The 8 building-decal DDS Pillow cannot open** — confirm header variant with a DX10-capable DDS reader before any conversion; no corruption claim made.
6. **Does port scope include 8-player maps?** Donor has substantial 8pl coverage; port manifest tops out at 7pl. Design decision required.
7. **Are `dmask/` (24×64×64 RGBA) actually drawn?** `world.gd:_build_masks()` comments say the ramp array is legacy and no draw code reads it, but the final effective state is `UNVERIFIED` without a Godot run (out of scope for this lane).
8. **Do cloud/sky/flare assets belong to this port's scope at all?** They are donor `data\env\` assets with no port directory; needs owner decision, not an asset-inventory answer.

---

*End of TDR-3 donor terrain asset inventory. All counts measured read-only on 2026-11-21; no donor binaries were added to the repository.*
