---
id: F05
ticket: TERRAIN-SWARM-2026-11-26/F05
title: "Donor tile-id -> texture-block mapping (reftile.mat / terrain.presets / tiles.lib / tiles.mat -> port block PNGs and 124-cell atlas)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_GODOT_JOB__NO_DONOR_BINARY_RUN
donor_root: "C:\\Games\\Cossacks 3 (READ-ONLY; latin-1 text and DDS/BMP byte headers only)"
port_root: "variant3d/assets/terrain/{blocks,atlas,structs}; variant3d/tools/build_tile_index_atlas.py; variant3d/scripts/world3d_terrain.gd"
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION"]
visual_parity_claim: false
owner_file: "reports/F05_tile_mapping.md (only file written)"
---

# F05 — Donor tile-id → texture-block mapping (exact recovery)

## 0. Scope, method, evidence discipline

Charter and swarm board read in full first. Donor was opened **read-only**; no donor
executable was run, no donor binary was copied or committed, no Godot job was
submitted, no source/asset/config/test/git file was edited. Tools used: `read`
(plaintext with line numbers), `grep`, PowerShell listing and `python` for
byte/header/hash reads, plus the shipped JSON metadata. Craft Anything was not
needed: every mapping fact is recoverable from donor text and DDS headers.

Files actually read (all paths under `C:\Games\Cossacks 3` unless marked PORT):

| Donor / port path | Lines / size observed here |
|---|---|
| `data\terrain\ref\reftile.lib` | 13 lines, 262 B (full read) |
| `data\terrain\ref\reftile.mat` | 170 lines, 4206 B (full read) |
| `data\terrain\ref\reftilealpha.mat` | 8765 B (header + alpha binding read) |
| `data\terrain\tiles\terrain.presets` | 263 lines, 8707 B (full read) |
| `data\terrain\tiles\terrain.lib` | 18 lines, 314 B (full read) |
| `data\terrain\tiles\tiles.season` | 4 lines, 70 B (full read) |
| `data\terrain\tiles\tiles.lib` | 909 lines, 26947 B (full read) |
| `data\terrain\tiles\tiles.mat` | 1019 lines, 47343 B (parsed all 253 `Material.Name` / `Material.Texture.image` pairs) |
| `data\scripts\common.inc\texturemap.inc` | 48954 B (constants + selection blocks read with line numbers) |
| `data\terrain\cliffs\*`, `data\terrain\covers\*` | four files, all **0 bytes** |
| `data\terrain\tiles\textures\*.dds` | 112 DDS files; DXT1; headers read for dimensions |
| PORT `variant3d/assets/terrain/blocks/*.png` | 112 PNGs (224 dir entries incl. `.import`) |
| PORT `variant3d/assets/terrain/atlas/tile_index_atlas.manifest.json` | 124 `layout` entries parsed |
| PORT `variant3d/assets/terrain/atlas/tile_index_atlas_winter.manifest.json`, `winter_aliases.json`, `desert_remap.json` | headers + sample entries parsed |
| PORT `variant3d/tools/build_tile_index_atlas.py` | 377 lines (full read) |
| PORT `variant3d/scripts/world3d_terrain.gd` | tile-dictionary / atlas cross-references grepped |

Labels follow the charter: **[O]** observed literal byte/text, **[D]** derived by
computation over observed data, **[I]** inferred, **[U]** unverified, and
**PORT APPROXIMATION** for any port-side deviation from donor structure.
Per charter §3, **no donor visual parity is claimed**: no donor GPU A/B frame exists.

---

## 1. Executive summary

1. **[O] The donor has 124 tile ids per season, not 112.** The Summer preset lists
   exactly 124 `[*].TileBlock` entries at `terrain.presets:6–129` (id 0 = `grass1`,
   id 123 = `alpha0c`); the Winter preset lists another 124 at `:138–261`. Total
   `terrain.presets` TileBlock lines = 248. `DefaultIndex = 0` at `:4` / `:136`.
   `terrain.lib:12–15` maps Summer/Autumn/Spring → `Summer`, Winter → `Winter`.
2. **[O] The id → picture resolution is a three-file chain**, not a single list:
   `terrain.presets` fixes the *index order*, `tiles.lib` fixes per-block *geometry
   overrides* (245 sections, `tiles.lib:1–909`), and `tiles.mat` fixes the *bitmap*
   (253 sections, 253 `Material.Name` / `Material.Texture.image` pairs, 108
   distinct image paths). Example: `rock1vf` (id 53) binds `rock1.dds`
   (`tiles.mat:144–145`), not a separate face file. All 108 referenced DDS paths
   exist; four DDS (`winter18/23/24/26.dds`) are unreferenced **[D]**.
3. **[D] There are 112 DXT1 DDS files** in `data\terrain\tiles\textures` plus three
   alpha BMPs (`alpha.bmp`, `alphanull.bmp`, `alphavert.bmp`). `tiles.mat` references
   **108 distinct DDS paths, all of which exist on disk**; the four unreferenced DDS
   are `winter18/23/24/26.dds`. The port's `blocks/*.png` contains **exactly 112
   PNGs with the same stems as the 112 donor DDS files — zero donor-only, zero
   port-only**. Block PNGs are named after donor DDS basenames; their *atlas order*
   is donor preset-index order, not alphabetical order.
4. **[O] The port atlas is a 16×8 uniform grid of 1024² cells = 128 slots, 124
   named, 121 filled, 3 empty** (`tile_index_atlas.manifest.json:13–46`, tool
   `:84–88`). Cell for id *i* is `(i % 16, i // 16)`. The 3 empty cells are the
   alpha sentinels `alpha0a/b/c` (ids 86, 110, 123).
5. **[O] The biggest incompleteness is the 36 face/variant ids** (ids 35–52 sand
   slope faces, ids 53–70 rock vertical faces). Donor gives them 25° `AngleX/AngleZ`
   overrides and a different alpha projection (`verticalfront`/`verticalside`,
   `alphavert`, eye-linear S/T) while reusing the base DDS; the port packs them as
   **identity copies of the base PNG** (`FACE_BASE_REUSE`). The rotation and face
   alpha are **not present** in the port atlas — PORT APPROXIMATION.
6. **[O] `reftile.mat` is a 4-section material template**, not an id table: `normal`,
   `normalside`, `verticalfront`, `verticalside`; exact fields enumerated in §5.
   No `*.ref` file exists under `data\terrain\ref` — only `reftile.lib`,
   `reftile.mat`, `reftilealpha.mat`. The `*.ref` files on this installation are
   elsewhere (`data\env\lights\light.ref`, `data\pfx\material.ref`, `data\pfx\source.ref`,
   `data\shaders\shaders.ref`) and have no tile-id role.
7. **[O] `data\terrain\cliffs` and `data\terrain\covers` contain only four 0-byte
   stubs** (`cliffs.lib`, `cliffs.mat`, `covers.lib`, `covers.mat`). There is no
   separate cliff/cover texture set: cliff appearance is produced by rock-face tile
   ids 53–70 plus `reftile.mat` face materials.
8. **[O] Water has no tile id.** The shore ids are 93–98 `sandsea1..6`; water body
   is a separate shader/surface (A08 §1, DTRN-01 C21/C23). Mill "fields" are
   `envfieldd` **decals**, not tile ids (A08 §1 item 2; `decals\env\envfieldd.dds`);
   the tile-family stand-ins for ground/aprons are `ground1`, `desert*`, and
   `test*`.

---

## 2. Evidence table

| ID | Label | Evidence (donor path:line or port path:line) |
|---|---|---|
| E01 | **[O]** | `terrain.presets:6–129` = 124 Summer `TileBlock` lines; `:138–261` = 124 Winter; `DefaultIndex=0` at `:4`,`:136`; file has 248 TileBlock lines total. |
| E02 | **[O]** | `terrain.lib:12–15` season switch; `:17` `CoverDisabled=true`; `tiles.season:2–3` `TexName=grass1 / Summer=grass1`. |
| E03 | **[O]** | `tiles.lib` has 245 `section.begin {refurl=.\data\terrain\ref\reftile.lib}` blocks; face overrides `rock1vf` `AngleX=0, AngleZ=25` at `:119–121`, `rock1vs` `AngleX=25, AngleZ=0` at `:123–126` (repeated through `:207`); sand faces `:208–297`; `test10` `TileSize=128/Rows=16/Cols=16` at `:328–333`; `test11` `128/32/32` at `:334–339`; `sand1..4` `TileSize=64/Rows=2/Cols=2` at `:53–75`. |
| E04 | **[O]** | `tiles.mat:2–5` binds `grass1` → `.\data\terrain\tiles\textures\grass1.dds`; `:144–145` `rock1vf` → `rock1.dds`; `:216–217` `sand1f` → `sand1.dds`; `:348–349` `alpha0a` → `grass1.dds` + `Texture2Name=alphanull` (likewise `alpha0b` `:351–354`, `alpha0c` `:356–359`). Parsed all 253 images: 108 distinct paths. |
| E05 | **[O]** | `reftile.lib:2–12`: `TileBlockName`, `TileScheme=tsDouble`, `TileType=ttExtended`, `TileXOffset=0.1`, `TileYOffset=0.2`, commented `TileSize/Rows/Cols/AlphaRows=8/AlphaCols=4/AlphaTileSize=64`. |
| E06 | **[O]** | `reftile.mat:1–108` `normal` section fields (§5); `:110–118` `normalside {refkey=normal}`; `:120–144` `verticalfront {refkey=normal}` `Texture2Name=alphavert, TextureScale=0.125, mappingmode=tmmEyeLinear`, S=(1,0,0,0) T=(0,0,1,0); `:146–170` `verticalside` S=(0,1,0,0) T=(0,0,1,0). |
| E07 | **[O]** | `reftilealpha.mat:30–37` binds `alpha.bmp`, `imagealpha=tiaAlphaFromIntensity`, `textureformat=tfAlpha`, `maNearest`/`miNearest`, `twBoth`; `:139–146` the `alphavert` binding (header read; full file 8765 B). |
| E08 | **[O]** | `texturemap.inc:29–31` constants `cMaxHeight=2.96`, `cWaterHeight=-0.25`, `cWaterShoreHeight=-0.1`; `:474` `cAngle=45`; `:479–511` 8×45° sector → `sandsea1/5/6`; `:594–601` `abs(h)>2.7→rock8`, `>2.4→rock4`, `<0.1→none`; `:578–591` non-water cliff faces `rock1/3/4/7`; `:627–636` roads `ground1`/`test2`/`test3`; `:525–526,605–606` `_winter` suffix when `GetSeasonType=2`. **All these lines are `;`-commented** (authoritative intent; runtime activity UNVERIFIED per A08 §8.7). |
| E09 | **[O]** | `C:\Games\Cossacks 3\data\terrain\cliffs\{cliffs.lib,cliffs.mat}` and `covers\{covers.lib,covers.mat}` are all 0 bytes. No `*.ref` under `data\terrain\ref`. |
| E10 | **[D]** | DDS headers (first 128 bytes, little-endian): `grass1.dds` 1024×1024 DXT1, `sand1.dds` and `sand2.dds` **256×256 DXT1**, `sand3.dds` 1024×1024, `winter0.dds` 1024×1024, `desert1.dds` 1024×1024. |
| E11 | **[D]** | SHA-256 over all 112 donor DDS files: 105 distinct hashes. Byte-identical groups: `{grass1, test10, test11}`, `{grass8, test0}`, `{test19, winter23, winter24, winter25, winter26}`. |
| E12 | **[O]** | PORT `build_tile_index_atlas.py:84–88` `CELL=1024, COLS=16, ROWS=8, SLOTS=128, EXPECTED_NAMES=124`; `:130–133` `FACE_RE=^(rock|sand)(\d+)(vf|vs|f|s)$`; `:148–176` resolves presets by name, face names to base PNG, else `EMPTY`; `:181–208` pastes each source into `(i%16, i//16)` cell; `:193–197` NEAREST upscale to 1024. |
| E13 | **[O]** | PORT `tile_index_atlas.manifest.json:13–46` atlas 16384×8192, 124 named / 121 filled / 3 empty, index dictionary `presets_summer.json:2–125`; `layout` has 124 entries; ids 86/110/123 `kind=EMPTY`, `source_png=null`; ids 35–52 and 53–70 `kind=FACE_BASE_REUSE`; ids 26/27 and their face copies `upscaled=true, source=[256,256]`. |
| E14 | **[O]** | PORT `blocks/` PNG stems == donor DDS stems (112 = 112, zero set difference). PORT `tile_index_atlas_winter.manifest.json`: 124 named / 121 filled / 3 empty, index-preserving with `winter_aliases.json`; `winter_aliases.json` `rules.index_preserving=true`, `alpha_tiles_shared_in_preset=[alpha0a,alpha0b,alpha0c]`, `desert_reuse=desertN_winter→desertN.dds`. |
| E15 | **[O]** | PORT `manifest.shipped_tileblock` (`app/shots/g32_dump.json`): 102400 bytes, 31 distinct ids, min 0, max 85, `unresolved_ids=[]`, top ids 14/0/16/79/78. `world3d_terrain.gd:1357–1358,1592` notes `sandsea1=93, sandsea5=97, sandsea6=98`, matching the manifest layout. |
| E16 | **[O]/[D]** | Prior art A03 `docs/terrain_swarm_2026-11-25/reports/A03_atlas_cells.md:19–23,40–50`: audited atlas cells are pixel-identical to block PNGs; 36 face cells are identity copies (no 25° baked in); `grass_ground3` is an exact horizontal mirror of `grass_ground1`. |

---

## 3. Exact id → donor bitmap → port PNG → role table (Summer, ids 0–123)

All donor bitmap paths share the prefix `.\data\terrain\tiles\textures\` (shown in
full in column 3). Port PNGs live in `variant3d/assets/terrain/blocks/`. `cell` is
`(x,y)` in the 16×8 port atlas. `kind` is the port manifest classification.
**Role** is **[D]/[I]** from the block name plus the donor selection intent in
`texturemap.inc:474–511,578–601,627–636` — the script is commented out, so role
is authored intent, not proven runtime behaviour.

| id | summer name | donor bitmap | port PNG | cell | kind | role |
|---:|---|---|---|---|---|---|
| 0 | grass1 | .\data\terrain\tiles\textures\grass1.dds | grass1.png | 0,0 | DIRECT | grass |
| 1 | grass2 | .\data\terrain\tiles\textures\grass2.dds | grass2.png | 1,0 | DIRECT | grass |
| 2 | grass3 | .\data\terrain\tiles\textures\grass3.dds | grass3.png | 2,0 | DIRECT | grass |
| 3 | grass4 | .\data\terrain\tiles\textures\grass4.dds | grass4.png | 3,0 | DIRECT | grass |
| 4 | grass5 | .\data\terrain\tiles\textures\grass5.dds | grass5.png | 4,0 | DIRECT | grass |
| 5 | grass6 | .\data\terrain\tiles\textures\grass6.dds | grass6.png | 5,0 | DIRECT | grass |
| 6 | grass7 | .\data\terrain\tiles\textures\grass7.dds | grass7.png | 6,0 | DIRECT | grass |
| 7 | grass8 | .\data\terrain\tiles\textures\grass8.dds | grass8.png | 7,0 | DIRECT | grass |
| 8 | grass9 | .\data\terrain\tiles\textures\grass9.dds | grass9.png | 8,0 | DIRECT | grass |
| 9 | grass10 | .\data\terrain\tiles\textures\grass10.dds | grass10.png | 9,0 | DIRECT | grass |
| 10 | ground1 | .\data\terrain\tiles\textures\ground1.dds | ground1.png | 10,0 | DIRECT | field/dirt (road) |
| 11 | grass_sand1 | .\data\terrain\tiles\textures\grass_sand1.dds | grass_sand1.png | 11,0 | DIRECT | grass-sand transition |
| 12 | grass_sand2 | .\data\terrain\tiles\textures\grass_sand2.dds | grass_sand2.png | 12,0 | DIRECT | grass-sand transition |
| 13 | grass_rock1 | .\data\terrain\tiles\textures\grass_rock1.dds | grass_rock1.png | 13,0 | DIRECT | grass-rock transition |
| 14 | grass_ground1 | .\data\terrain\tiles\textures\grass_ground1.dds | grass_ground1.png | 14,0 | DIRECT | grass-dirt transition |
| 15 | grass_ground2 | .\data\terrain\tiles\textures\grass_ground2.dds | grass_ground2.png | 15,0 | DIRECT | grass-dirt transition |
| 16 | grass_ground3 | .\data\terrain\tiles\textures\grass_ground3.dds | grass_ground3.png | 0,1 | DIRECT | grass-dirt transition (mirror of 14) |
| 17 | rock1 | .\data\terrain\tiles\textures\rock1.dds | rock1.png | 1,1 | DIRECT | rock |
| 18 | rock2 | .\data\terrain\tiles\textures\rock2.dds | rock2.png | 2,1 | DIRECT | rock |
| 19 | rock3 | .\data\terrain\tiles\textures\rock3.dds | rock3.png | 3,1 | DIRECT | rock |
| 20 | rock4 | .\data\terrain\tiles\textures\rock4.dds | rock4.png | 4,1 | DIRECT | rock |
| 21 | rock5 | .\data\terrain\tiles\textures\rock5.dds | rock5.png | 5,1 | DIRECT | rock |
| 22 | rock6 | .\data\terrain\tiles\textures\rock6.dds | rock6.png | 6,1 | DIRECT | rock |
| 23 | rock7 | .\data\terrain\tiles\textures\rock7.dds | rock7.png | 7,1 | DIRECT | rock |
| 24 | rock8 | .\data\terrain\tiles\textures\rock8.dds | rock8.png | 8,1 | DIRECT | rock (height>2.7 override) |
| 25 | rock9 | .\data\terrain\tiles\textures\rock9.dds | rock9.png | 9,1 | DIRECT | rock |
| 26 | sand1 | .\data\terrain\tiles\textures\sand1.dds | sand1.png | 10,1 | DIRECT (upscaled) | sand |
| 27 | sand2 | .\data\terrain\tiles\textures\sand2.dds | sand2.png | 11,1 | DIRECT (upscaled) | sand |
| 28 | sand3 | .\data\terrain\tiles\textures\sand3.dds | sand3.png | 12,1 | DIRECT | sand |
| 29 | sand4 | .\data\terrain\tiles\textures\sand4.dds | sand4.png | 13,1 | DIRECT | sand |
| 30 | sand5 | .\data\terrain\tiles\textures\sand5.dds | sand5.png | 14,1 | DIRECT | sand |
| 31 | sand6 | .\data\terrain\tiles\textures\sand6.dds | sand6.png | 15,1 | DIRECT | sand |
| 32 | sand7 | .\data\terrain\tiles\textures\sand7.dds | sand7.png | 0,2 | DIRECT | sand |
| 33 | sand8 | .\data\terrain\tiles\textures\sand8.dds | sand8.png | 1,2 | DIRECT | sand |
| 34 | sand9 | .\data\terrain\tiles\textures\sand9.dds | sand9.png | 2,2 | DIRECT | sand |
| 35 | sand1f | .\data\terrain\tiles\textures\sand1.dds | sand1.png | 3,2 | FACE_BASE_REUSE | sand slope face |
| 36 | sand1s | .\data\terrain\tiles\textures\sand1.dds | sand1.png | 4,2 | FACE_BASE_REUSE | sand slope face |
| 37 | sand2f | .\data\terrain\tiles\textures\sand2.dds | sand2.png | 5,2 | FACE_BASE_REUSE | sand slope face |
| 38 | sand2s | .\data\terrain\tiles\textures\sand2.dds | sand2.png | 6,2 | FACE_BASE_REUSE | sand slope face |
| 39 | sand3f | .\data\terrain\tiles\textures\sand3.dds | sand3.png | 7,2 | FACE_BASE_REUSE | sand slope face |
| 40 | sand3s | .\data\terrain\tiles\textures\sand3.dds | sand3.png | 8,2 | FACE_BASE_REUSE | sand slope face |
| 41 | sand4f | .\data\terrain\tiles\textures\sand4.dds | sand4.png | 9,2 | FACE_BASE_REUSE | sand slope face |
| 42 | sand4s | .\data\terrain\tiles\textures\sand4.dds | sand4.png | 10,2 | FACE_BASE_REUSE | sand slope face |
| 43 | sand5f | .\data\terrain\tiles\textures\sand5.dds | sand5.png | 11,2 | FACE_BASE_REUSE | sand slope face |
| 44 | sand5s | .\data\terrain\tiles\textures\sand5.dds | sand5.png | 12,2 | FACE_BASE_REUSE | sand slope face |
| 45 | sand6f | .\data\terrain\tiles\textures\sand6.dds | sand6.png | 13,2 | FACE_BASE_REUSE | sand slope face |
| 46 | sand6s | .\data\terrain\tiles\textures\sand6.dds | sand6.png | 14,2 | FACE_BASE_REUSE | sand slope face |
| 47 | sand7f | .\data\terrain\tiles\textures\sand7.dds | sand7.png | 15,2 | FACE_BASE_REUSE | sand slope face |
| 48 | sand7s | .\data\terrain\tiles\textures\sand7.dds | sand7.png | 0,3 | FACE_BASE_REUSE | sand slope face |
| 49 | sand8f | .\data\terrain\tiles\textures\sand8.dds | sand8.png | 1,3 | FACE_BASE_REUSE | sand slope face |
| 50 | sand8s | .\data\terrain\tiles\textures\sand8.dds | sand8.png | 2,3 | FACE_BASE_REUSE | sand slope face |
| 51 | sand9f | .\data\terrain\tiles\textures\sand9.dds | sand9.png | 3,3 | FACE_BASE_REUSE | sand slope face |
| 52 | sand9s | .\data\terrain\tiles\textures\sand9.dds | sand9.png | 4,3 | FACE_BASE_REUSE | sand slope face |
| 53 | rock1vf | .\data\terrain\tiles\textures\rock1.dds | rock1.png | 5,3 | FACE_BASE_REUSE | cliff face (front, 25°) |
| 54 | rock1vs | .\data\terrain\tiles\textures\rock1.dds | rock1.png | 6,3 | FACE_BASE_REUSE | cliff face (side, 25°) |
| 55 | rock2vf | .\data\terrain\tiles\textures\rock2.dds | rock2.png | 7,3 | FACE_BASE_REUSE | cliff face (front, 25°) |
| 56 | rock2vs | .\data\terrain\tiles\textures\rock2.dds | rock2.png | 8,3 | FACE_BASE_REUSE | cliff face (side, 25°) |
| 57 | rock3vf | .\data\terrain\tiles\textures\rock3.dds | rock3.png | 9,3 | FACE_BASE_REUSE | cliff face (front, 25°) |
| 58 | rock3vs | .\data\terrain\tiles\textures\rock3.dds | rock3.png | 10,3 | FACE_BASE_REUSE | cliff face (side, 25°) |
| 59 | rock4vf | .\data\terrain\tiles\textures\rock4.dds | rock4.png | 11,3 | FACE_BASE_REUSE | cliff face (front, 25°) |
| 60 | rock4vs | .\data\terrain\tiles\textures\rock4.dds | rock4.png | 12,3 | FACE_BASE_REUSE | cliff face (side, 25°) |
| 61 | rock5vf | .\data\terrain\tiles\textures\rock5.dds | rock5.png | 13,3 | FACE_BASE_REUSE | cliff face (front, 25°) |
| 62 | rock5vs | .\data\terrain\tiles\textures\rock5.dds | rock5.png | 14,3 | FACE_BASE_REUSE | cliff face (side, 25°) |
| 63 | rock6vf | .\data\terrain\tiles\textures\rock6.dds | rock6.png | 15,3 | FACE_BASE_REUSE | cliff face (front, 25°) |
| 64 | rock6vs | .\data\terrain\tiles\textures\rock6.dds | rock6.png | 0,4 | FACE_BASE_REUSE | cliff face (side, 25°) |
| 65 | rock7vf | .\data\terrain\tiles\textures\rock7.dds | rock7.png | 1,4 | FACE_BASE_REUSE | cliff face (front, 25°) |
| 66 | rock7vs | .\data\terrain\tiles\textures\rock7.dds | rock7.png | 2,4 | FACE_BASE_REUSE | cliff face (side, 25°) |
| 67 | rock8vf | .\data\terrain\tiles\textures\rock8.dds | rock8.png | 3,4 | FACE_BASE_REUSE | cliff face (front, 25°) |
| 68 | rock8vs | .\data\terrain\tiles\textures\rock8.dds | rock8.png | 4,4 | FACE_BASE_REUSE | cliff face (side, 25°) |
| 69 | rock9vf | .\data\terrain\tiles\textures\rock9.dds | rock9.png | 5,4 | FACE_BASE_REUSE | cliff face (front, 25°) |
| 70 | rock9vs | .\data\terrain\tiles\textures\rock9.dds | rock9.png | 6,4 | FACE_BASE_REUSE | cliff face (side, 25°) |
| 71 | test0 | .\data\terrain\tiles\textures\test0.dds | test0.png | 7,4 | DIRECT | detail variant (= grass8 art) |
| 72 | test1 | .\data\terrain\tiles\textures\test1.dds | test1.png | 8,4 | DIRECT | detail variant |
| 73 | test2 | .\data\terrain\tiles\textures\test2.dds | test2.png | 9,4 | DIRECT | detail variant (road) |
| 74 | test3 | .\data\terrain\tiles\textures\test3.dds | test3.png | 10,4 | DIRECT | detail variant (road) |
| 75 | test4 | .\data\terrain\tiles\textures\test4.dds | test4.png | 11,4 | DIRECT | detail variant |
| 76 | test5 | .\data\terrain\tiles\textures\test5.dds | test5.png | 12,4 | DIRECT | detail variant |
| 77 | test6 | .\data\terrain\tiles\textures\test6.dds | test6.png | 13,4 | DIRECT | detail variant |
| 78 | test7 | .\data\terrain\tiles\textures\test7.dds | test7.png | 14,4 | DIRECT | detail variant |
| 79 | test8 | .\data\terrain\tiles\textures\test8.dds | test8.png | 15,4 | DIRECT | detail variant |
| 80 | test9 | .\data\terrain\tiles\textures\test9.dds | test9.png | 0,5 | DIRECT | detail variant |
| 81 | test10 | .\data\terrain\tiles\textures\test10.dds | test10.png | 1,5 | DIRECT | detail variant (= grass1 art; 16×16 subtile) |
| 82 | test11 | .\data\terrain\tiles\textures\test11.dds | test11.png | 2,5 | DIRECT | detail variant (= grass1 art; 32×32 subtile) |
| 83 | test12 | .\data\terrain\tiles\textures\test12.dds | test12.png | 3,5 | DIRECT | detail variant |
| 84 | test13 | .\data\terrain\tiles\textures\test13.dds | test13.png | 4,5 | DIRECT | detail variant |
| 85 | test14 | .\data\terrain\tiles\textures\test14.dds | test14.png | 5,5 | DIRECT | detail variant |
| 86 | alpha0a | .\data\terrain\tiles\textures\grass1.dds + `alphanull` | (none) EMPTY | 6,5 | EMPTY | alpha sentinel (grass art, no fade) |
| 87 | sandrock1 | .\data\terrain\tiles\textures\sandrock1.dds | sandrock1.png | 7,5 | DIRECT | sand-rock transition |
| 88 | sandrock2 | .\data\terrain\tiles\textures\sandrock2.dds | sandrock2.png | 8,5 | DIRECT | sand-rock transition |
| 89 | sandrock3 | .\data\terrain\tiles\textures\sandrock3.dds | sandrock3.png | 9,5 | DIRECT | sand-rock transition |
| 90 | sandrock4 | .\data\terrain\tiles\textures\sandrock4.dds | sandrock4.png | 10,5 | DIRECT | sand-rock transition |
| 91 | sandrock5 | .\data\terrain\tiles\textures\sandrock5.dds | sandrock5.png | 11,5 | DIRECT | sand-rock transition |
| 92 | sandrock6 | .\data\terrain\tiles\textures\sandrock6.dds | sandrock6.png | 12,5 | DIRECT | sand-rock transition |
| 93 | sandsea1 | .\data\terrain\tiles\textures\sandsea1.dds | sandsea1.png | 13,5 | DIRECT | shore/sand (water edge) |
| 94 | sandsea2 | .\data\terrain\tiles\textures\sandsea2.dds | sandsea2.png | 14,5 | DIRECT | shore/sand |
| 95 | sandsea3 | .\data\terrain\tiles\textures\sandsea3.dds | sandsea3.png | 15,5 | DIRECT | shore/sand |
| 96 | sandsea4 | .\data\terrain\tiles\textures\sandsea4.dds | sandsea4.png | 0,6 | DIRECT | shore/sand |
| 97 | sandsea5 | .\data\terrain\tiles\textures\sandsea5.dds | sandsea5.png | 1,6 | DIRECT | shore/sand |
| 98 | sandsea6 | .\data\terrain\tiles\textures\sandsea6.dds | sandsea6.png | 2,6 | DIRECT | shore/sand |
| 99 | test15 | .\data\terrain\tiles\textures\test15.dds | test15.png | 3,6 | DIRECT | detail variant |
| 100 | test16 | .\data\terrain\tiles\textures\test16.dds | test16.png | 4,6 | DIRECT | detail variant |
| 101 | test17 | .\data\terrain\tiles\textures\test17.dds | test17.png | 5,6 | DIRECT | detail variant |
| 102 | test18 | .\data\terrain\tiles\textures\test18.dds | test18.png | 6,6 | DIRECT | detail variant |
| 103 | test19 | .\data\terrain\tiles\textures\test19.dds | test19.png | 7,6 | DIRECT | detail variant (= winter23/24/25/26 art) |
| 104 | test20 | .\data\terrain\tiles\textures\test20.dds | test20.png | 8,6 | DIRECT | detail variant |
| 105 | test21 | .\data\terrain\tiles\textures\test21.dds | test21.png | 9,6 | DIRECT | detail variant |
| 106 | test22 | .\data\terrain\tiles\textures\test22.dds | test22.png | 10,6 | DIRECT | detail variant |
| 107 | test23 | .\data\terrain\tiles\textures\test23.dds | test23.png | 11,6 | DIRECT | detail variant |
| 108 | test24 | .\data\terrain\tiles\textures\test24.dds | test24.png | 12,6 | DIRECT | detail variant |
| 109 | test25 | .\data\terrain\tiles\textures\test25.dds | test25.png | 13,6 | DIRECT | detail variant |
| 110 | alpha0b | .\data\terrain\tiles\textures\grass1.dds + `alphanull` | (none) EMPTY | 14,6 | EMPTY | alpha sentinel (grass art, no fade) |
| 111 | desert1 | .\data\terrain\tiles\textures\desert1.dds | desert1.png | 15,6 | DIRECT | desert field |
| 112 | desert2 | .\data\terrain\tiles\textures\desert2.dds | desert2.png | 0,7 | DIRECT | desert field |
| 113 | desert3 | .\data\terrain\tiles\textures\desert3.dds | desert3.png | 1,7 | DIRECT | desert field |
| 114 | desert4 | .\data\terrain\tiles\textures\desert4.dds | desert4.png | 2,7 | DIRECT | desert field |
| 115 | desert5 | .\data\terrain\tiles\textures\desert5.dds | desert5.png | 3,7 | DIRECT | desert field |
| 116 | desert6 | .\data\terrain\tiles\textures\desert6.dds | desert6.png | 4,7 | DIRECT | desert field |
| 117 | desert7 | .\data\terrain\tiles\textures\desert7.dds | desert7.png | 5,7 | DIRECT | desert field |
| 118 | desert8 | .\data\terrain\tiles\textures\desert8.dds | desert8.png | 6,7 | DIRECT | desert field |
| 119 | desert9 | .\data\terrain\tiles\textures\desert9.dds | desert9.png | 7,7 | DIRECT | desert field |
| 120 | desert10 | .\data\terrain\tiles\textures\desert10.dds | desert10.png | 8,7 | DIRECT | desert field |
| 121 | desert11 | .\data\terrain\tiles\textures\desert11.dds | desert11.png | 9,7 | DIRECT | desert field |
| 122 | desert12 | .\data\terrain\tiles\textures\desert12.dds | desert12.png | 10,7 | DIRECT | desert field |
| 123 | alpha0c | .\data\terrain\tiles\textures\grass1.dds + `alphanull` | (none) EMPTY | 11,7 | EMPTY | alpha sentinel (grass art, no fade) |

**Role family counts [D]:** grass 0–9 (10) + transitions 11–16 (6) + detail
`test*` 71–85,99–109 (31) + rock base 17–25 (9) + rock cliff faces 53–70 (18) +
sand base 26–34 (9) + sand slope faces 35–52 (18) + sand-rock 87–92 (6) +
shore 93–98 (6) + desert 111–122 (12) + dirt/road 10 (1) + alpha sentinels 86/110/123 (3).
**Water has no id**; shore is ids 93–98. **Mill fields are decals**, not tile ids.

---

## 4. How the 124-cell port atlas maps back to donor ids, and where it is incomplete

### 4.1 Mapping rule [O]/[D]

`presets_summer.json` (124 names) is a verbatim mirror of `terrain.presets:6–129`;
array element *i* is donor preset index *i*. `build_tile_index_atlas.py:151–176`
iterates those names in order and sets `cell_xy = [i % 16, i // 16]`, `cell_px =
[x*1024, y*1024, 1024, 1024]` (`manifest.json:47–120` etc.). Shader-side lookup uses
the same integer id (`world3d_terrain.gd:1275`, `:873`, `:1347–1378`), so:

> **donor tile id *i* → atlas cell `(i%16, i//16)` → PNG named by the donor board
> at `tiles.mat` for that preset name** (with the face/sentinel exceptions below).

Four trailing slots (124–127) are unused. The Winter atlas reuses the *same* index
layout (`tile_index_atlas_winter.manifest.json.index_dictionary`), resolving each
index through `winter_aliases.json` to a `winterN.png` (or `desertN.png` for the
desert indices), preserving id equality across seasons.

### 4.2 Known incompleteness / deviation register

| # | Gap | Evidence | Label |
|---:|---|---|---|
| G1 | 3 alpha-sentinel cells (86/110/123) are transparent EMPTY; the donor resolves them to `grass1.dds` + `Texture2Name=alphanull`, i.e. real grass art with a no-transition alpha. | `tiles.mat:347–359`; `manifest.json` layout ids 86/110/123 `source_png=null` | **[O]** donor, PORT APPROXIMATION port |
| G2 | 36 face cells (35–52, 53–70) are identity copies of base PNGs. Donor `tiles.lib` sets `AngleX/AngleZ=25` and `reftile.mat` switches to `alphavert`+eye-linear face projection. The 25° tilt and face alpha are absent from the port atlas. | `tiles.lib:119–297`; `reftile.mat:120–169`; A03 `:49`; build tool `:130–170` | **[O]** + PORT APPROXIMATION |
| G3 | `sand1/sand2` are 256² DXT1 but port upsamples them (and their 4 face cells) to 1024² with NEAREST. | DDS header E10; `tiles.lib:53–63`; tool `:193–197`; manifest `upscaled_sources` | **[D]** + PORT APPROXIMATION |
| G4 | Uniform 16×8 cell packing; donor `TileScheme=tsDouble`, `TileType=ttExtended`, commented `TileSize/Rows/Cols` and `AlphaRows/Cols/TileSize` imply engine-side sub-tiling that the port does not reproduce. | `reftile.lib:3–12`; A03 `:43–44` (`test10` 16×16, `test11` 32×32 unused) | **[U]** engine-side + PORT APPROXIMATION |
| G5 | 27 `winterN.png` blocks ship but have no Summer preset index (intentionally, by season); the Summer atlas cannot display Winter art. | manifest `unused_shipped_blocks` (27) and `unused_note` | **[O]** |
| G6 | Exact art duplicates are counted as distinct ids in the port (0/81/82 same pixels; 7/71 same; 103 ≙ winter23–26), so "124 ids" overstates distinct art: 105 distinct DDS hashes over 112 files. | E11; A03 `:42` | **[D]** |
| G7 | Runtime dump uses only 31 distinct ids (0–85); ids 86–123 are never sampled in that capture, so atlas gaps above may be invisible in current QA. | E15 | **[O]** |
| G8 | Cliff/cover directories are empty stubs; there is no separate cliff/cover art to import — cliffs must be expressed through ids 53–70 + face material. | E09 | **[O]** |
| G9 | `texturemap.inc` selection code is `;`-commented; the documented id rules are authored intent, not proven active runtime. | E08 | **[U]** |

---

## 5. Exact metadata fields in `reftile.mat` (all four sections)

**[O] `normal` (`:1–108`)** — `Material : struct.begin` containing:
`Name` (empty), `Tag = -1`, `Shader = [nil]`, `Texture2Name = alpha`,
`TextureOffset{X,Y,Z}=0`, `TextureScale{X,Y,Z}=1`,
`BlendingMode = bmTransparency`, `FaceCulling = fcCull`,
`MaterialOptions{moIgnoreFog=False, moNoLighting=False}`, `LibTextureName` (empty),
`Texture{imagebrightness=1, ImageGamma=1, disabled=False, Compression=tcHighSpeed,
filteringquality=tfIsotropic, image=(empty), imagealpha=tiaDefault, magfilter=maNearest,
minfilter=miNearestMipmapLinear, mappingmode=tmmUser, textureformat=tfDefault,
texturemode=tmModulate, texturewrap=twBoth, mappingscoordinates{X=1,Y=0,Z=0,W=0},
mappingtcoordinates{X=1,Y=0,Z=0,W=0}}`,
`BackProperties`/`FrontProperties` each `{Ambient RGB=0.15686 A=1, Diffuse RGB=0.78125 A=1,
Emission RGB=0 A=1, Specular RGB=0 A=1, Shininess=16, PolygonMode=pmFill}`.

**[O] `normalside` (`:110–118`)** — `{refkey=normal}` override only `TextureScale{1,1,1}`.

**[O] `verticalfront` (`:120–144`)** — `{refkey=normal}` overrides
`Texture2Name=alphavert`, `TextureScale{0.125,0.125,0.125}`,
`Texture{mappingmode=tmmEyeLinear, mappingscoordinates{X=1,Y=0,Z=0,W=0},
mappingtcoordinates{X=0,Y=0,Z=1,W=0}}`.

**[O] `verticalside` (`:146–170`)** — same as `verticalfront` except
`mappingscoordinates{X=0,Y=1,Z=0,W=0}`.

`reftile.lib:2–12` fields: `TileBlockName`, `TileScheme=tsDouble`,
`TileType=ttExtended`, `TileXOffset=0.1`, `TileYOffset=0.2`, and **commented**
`TileSize=64`, `Rows=16`, `Cols=16`, `AlphaRows=8`, `AlphaCols=4`, `AlphaTileSize=64`.

---

## 6. Findings

### F01 — The index dictionary is donor literal, the bitmap resolution is donor literal, the atlas grid is port-authored. [O]/[D]
`terrain.presets:6–129` + `tiles.mat` + `tiles.lib` give an exact, fully recoverable
124-id chain. Only the *packing* into 16×8 cells is port-invented
(`build_tile_index_atlas.py:84–88,151–176`, labelled `APPROX_ATLAS_PACKING` at
manifest `:39`). No parity claim is made for the grid itself.

### F02 — "112 blocks" is an artefact of distinct bitmaps; the donor addressing space is 124 per season. [O]/[D]
112 PNG stems == 112 DDS stems, but `tiles.mat` has 253 material sections and
`tiles.lib` 245 tile-block sections because of season aliases and face variants.
Treating 112 as the id count would drop all 36 faces and the 3 alpha sentinels.

### F03 — Faces are *material/geometry variants of the same bitmap*, not different art. [O]
`rock1vf`/`rock1vs` → `rock1.dds` (`tiles.mat:144–148`) with `AngleX/AngleZ=25`
(`tiles.lib:119–126`) and `alphavert`/eye-linear projection (`reftile.mat:120–169`).
The port's `FACE_BASE_REUSE` cell is therefore correct about the *source pixels* but
drops the *orientation and mask* that distinguish the ids. This is a plausible
contributor to "flat relief / no readable cliffs" in the charter §1 complaint —
**[I]**, not proven without a GPU A/B.

### F04 — Alpha sentinels have real donor art and a real no-fade mask; the port has holes. [O]
`alpha0a/b/c` bind `grass1.dds` + `alphanull` (`tiles.mat:347–359`), where
`alphanull.bmp` is the all-zero mask (A08 §2). Port cells 86/110/123 are transparent
because no PNG with that stem ships. This is a faithful "no art fabricated" choice
but a semantic mismatch if those ids are ever sampled (current dump does not: E15).

### F05 — Winter is an index-preserving alias set, not new ids. [O]
`terrain.presets:138–261` is a 1-for-1 `_winter` rename of the 124 Summer names;
`tiles.mat:455–809` resolves them to `winter0..26.dds`, many-to-one (e.g. both
`grass9_winter` and `grass10_winter` → `winter0.dds` at `:487–491`). `alpha0a/b/c`
stay shared in the preset (`:224,248,261`) although `tiles.mat:799–809` carries
winter forms — the port records both facts in `winter_aliases.json`. Desert winter
ids reuse summer desert DDS (`tiles.mat:954–998`). Winter port atlas keeps the same
124 indices — **[O]** index identity verified in both manifests.

### F06 — Some "variety" is byte-identical art. [D]/[O]
SHA-256 groups (E11) prove `grass1 = test10 = test11`, `grass8 = test0`, and
`test19 = winter23 = winter24 = winter25 = winter26`. `tiles.lib:328–339` declares
different sub-tiling for `test10`/`test11` (16×16 / 32×32 at `TileSize=128`), so the
*semantic* difference is engine-side and not in the DDS bytes. Port gives those ids
separate cells with the same pixels — consistent with the donor bitmaps but not
with the donor sub-tiling intent. [U] for how the engine uses those rows/cols.

### F07 — Shore/rock selection is documented but the script is inert text. [O]/[U]
`texturemap.inc:474–511` (8×45° shore sectors) and `:578–601` (cliff faces +
`rock8`/`rock4` height overrides) are the donor's authored rules; every line is
`;`-commented, and A08 §8.7 classifies runtime activity as UNVERIFIED. Roles in §3
are therefore **[I]** where they depend on those rules, not observed runtime truth.

### F08 — No water tile id and no field tile id. [O]/[I]
There is no `water*.dds` in `tiles\textures`, no water name in `terrain.presets`;
water body is shader-driven (A08 §1). Mill fields are `decals\env\envfieldd.dds`,
not tiles. If the spec needs a "field" tile role, the honest candidates are
`ground1` (road/dirt at `texturemap.inc:627–636`) and `desert1..12`; calling any id
"the mill field tile" would be an invention.

---

## 7. Implications for the swarm / spec

1. **A01/A02 (data model / algorithm):** the stable key is the integer preset id
   0–123, resolved through a per-season name array; never through PNG filenames.
   Preserve `FACE_BASE_REUSE` ids as *distinct* ids even though pixels repeat.
2. **D04/D08 / A03 (conversion):** any decoder should reproduce the three-file
   chain (`presets → tiles.lib geometry → tiles.mat bitmap`) rather than hard-code
   112 names; it must carry `AngleX/AngleZ`, `Texture2Name`, and
   `refkey=normal/verticalfront/verticalside` as metadata even if the port cannot
   render them yet.
3. **A04 (landscape props):** cliffs must be implemented through ids 53–70 + face
   alpha or explicitly declared PORT APPROXIMATION; `data\terrain\cliffs` offers no
   alternative art.
4. **A03/A06:** if alpha sentinels are ever sampled, fill cells 86/110/123 with
   `grass1` art and `alphanull` semantics, or keep EMPTY but document the semantic
   hole. Do not fabricate new art and call it donor-faithful.
5. **QA (A05):** the current dump's 31 ids (0–85) do not exercise ids 86–123; a
   tile-histogram gate should force coverage of shore 93–98 and cliff 53–70 before
   any shore/cliff visual verdict.

---

## 8. Risks

| Risk | Evidence / label | Mitigation |
|---|---|---|
| Treating 112 PNGs as the donor id space loses faces and sentinels. | E01/E03/F02 **[D]** | Keep index dictionary at 124; use kind flags for reuse/empty. |
| Claiming visual parity from correct *ids* while orientation/mask differ. | F03 **[I]** | Label PORT APPROXIMATION; no parity claim without donor GPU A/B (charter §3). |
| Silent mismatch at ids 86/110/123 if a future generator paints them. | F04 **[O]** | Add a sentinel-aware branch or an explicit test. |
| Face ids look "solved" because pixels match, hiding 25° + alphavert difference. | E10/A03 `:49` | Record AngleX/AngleZ and projection in the spec as UNVERIFIED engine behaviour. |
| Commented `texturemap.inc` mistaken for active runtime code. | F07 **[U]** | Cite as "authored intent"; do not assert activity. |
| DDS hash duplicates inflate apparent variety. | F06 **[D]** | Report distinct-art count (105) alongside id count (124). |

---

## 9. UNVERIFIED register (do not promote)

1. **[U]** Runtime activity of the whole `texturemap.inc` id-selection script (fully
   `;`-commented); `reftile.lib` geometry fields `tsDouble/ttExtended/0.1/0.2` and
   commented sub-tiling — engine-side.
2. **[U]** How `AngleX/AngleZ=25` is actually applied to `vf/vs/f/s` ids (geometry
   tilt vs texgen vs atlas rotation), and the rule that promotes a base tile to a
   face id beyond the authored `texturemap.inc:557–611` text.
3. **[U]** Exact `AlphaRows=8/AlphaCols=4/AlphaTileSize=64` sub-rect selection per
   tile/boundary and the `tiaAlphaFromIntensity` formula; port intensity PNG is an
   approximation (manifest labels, A08 §8.3).
4. **[U]** Whether the donor ever samples `alpha0a/b/c` at runtime and what visual
   role the `alphanull` mask produces in a live frame.
5. **[U]** Whether `test10`/`test11` `Rows/Cols` sub-tiling is used by the engine
   (all port GDScript ignores those fields; A03 E04).
6. **[U]** Any non-GDScript consumer of the atlas metadata beyond
   `world3d_terrain.gd`/`tile_atlas_loader` paths; no runtime trace was run here.
7. **[U]** **Visual parity — none.** No donor GPU A/B frame exists; every visual
   statement in this report is structural or CPU-side only.

---

## 10. Open questions

1. Should the port distinguish `rockNvf` vs `rockNvs` by rotating the cell UV in the
   shader at 25°, or by authoring new art? Both depart from observed donor pixels;
   which is closer to donor *behaviour* needs a donor frame, not just DDS bytes.
2. Can COORD's D08 worker recover the face-promotion rule from `cossacks.exe`
   (RTTI/`XPattern`/shader path), given `texturemap.inc` is inert?
3. Should the 3 EMPTY sentinel cells be filled with `grass1.png` + an explicit
   `alphanull` flag in the manifest, or remain transparent with a runtime guard?
4. Are the 27 unused `winterN.png` blocks needed for a Winter A/B, or should the
   Winter atlas remain a separate season asset only?
5. Does any shipped `.map` / `g32_dump.json` sample ids ≥ 86 (the current capture
   does not: max id 85)? If so, the EMPTY faces would be visible and need repair.

---

## 11. Bottom line

The donor mapping is **exactly recoverable** and has been recovered: 124 ids per
season, ordered by `terrain.presets`, resolved to 108 DDS bitmaps through
`tiles.mat`, with 245 `tiles.lib` override sections controlling sub-tiling and 25°
face variants; 112 DDS files ship and the port's 112 block PNGs have identical
stems. The port's 124-cell atlas is a faithful *index dictionary* and a faithful
*pixel copy* for direct cells, but it is **PORT APPROXIMATION** for atlas packing,
for the 36 face cells (no 25°, no `alphavert` face projection), for the 3 alpha
sentinel cells (transparent holes), and for the 256→1024 sand upscale. Cliff/rock,
shore/sand, grass/detail, desert-field and alpha-sentinel id ranges are enumerated
above with donor line citations; water and mill fields have **no tile id**. No
donor visual parity is claimed.

*End of F05. One report written; no donor file executed or copied; no code, asset,
config, test, git or Godot-runner state changed.*
