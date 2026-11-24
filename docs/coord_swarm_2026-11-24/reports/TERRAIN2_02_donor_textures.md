---
id: TERRAIN2-02
scope: "Inventory of DONOR terrain texture assets (names, formats, dimensions, semantic roles, blend/tiling semantics) and what the 2D port loads vs what the 3D port currently uses; rank reusable donor textures for variant3d"
date: 2026-11-24
status: AUDIT ONLY — read-only donor research; no source/asset/config/test/git edits; no donor binary copied
owner: TERRAIN2-02
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor: "C:\\Games\\Cossacks 3 (READ-ONLY, private use)"
method_note: "OBS = direct donor/port text read or binary header byte read (dimensions only); INF = inference from cited text; UNV = unverified/ambiguous. Every fact cites donor path:line or port path:line; binary header reads cite path + byte offset. No donor pixel payload was decoded, viewed or copied; no donor binary was executed."
---

# TERRAIN2-02 — Donor terrain textures: what exists, how it is meant to be used, and what 3D should reuse

## 0. Method and guards

- Donor config/script/shader text was read as text, read-only. Donor image **headers only** were read as bytes (DDS `dwHeight @12`, `dwWidth @16`, `dwMipMapCount @28`, `ddspf.dwFourCC @84`; BMP `width @18`, `height @22`, `bpp @28`, or `@12/@14/@24` for BITMAPCOREHEADER). No donor texture was decoded to pixels or copied into the repo.
- Port files under `app/` and `variant3d/` were read only; no edits. The single written artifact is this report.
- Per charter (`docs/coord_swarm_2026-11-24/TERRAIN2_CHARTER.md:6-14`), no visual-parity claim: no GPU A/B performed.
- Water/weather assets (`diffusewaves*`, `heightmapwaves0.tga`, `hmapTex`, fog, clouds) are owned by TERRAIN2-03 (`docs/coord_swarm_2026-11-24/reports/TERRAIN2_03_water_weather.md:28-37,164-178`); this report cites them only to classify them as **not** terrain albedo.

---

## 1. Evidence table

| # | Area | Donor path:line / port path:line | What it establishes | Class |
|---|---|---|---|---|
| D1 | Tile registry | `data\terrain\tiles\tiles.lib:2-30` | Named TileBlocks `grass1..grass10` (each `section.begin {refurl=.\data\terrain\ref\reftile.lib}`) | OBS |
| D2 | Semantic families | `data\terrain\tiles\tiles.lib:32-51,53-117,353-387,836-906` | `ground1`, `grass_ground1-3`, `grass_rock1`, `grass_sand1-2`, `sand1-9`, `rock1-9`, `sandrock1-6`, `sandsea1-6`, `desert1-12` plus `_winter` variants | OBS |
| D3 | Sub-tile metadata | `data\terrain\tiles\tiles.lib:53-76,330-339,476-498` | `sand1..sand4` declare `TileSize = 64, Rows = 2, Cols = 2`; `test10` `TileSize=128, Rows=16, Cols=16`; `test11` `128/32/32`; same metadata on `_winter` sand tiles | OBS |
| D4 | Cliff-face orientation | `data\terrain\tiles\tiles.lib:119-207,542-630` | `rockNvf` = `AngleX = 0, AngleZ = 25`; `rockNs` = `AngleX = 25, AngleZ = 0` — vertical front/side variants of the same rock art, repeated for winter | OBS |
| D5 | Tiling defaults | `data\terrain\ref\reftile.lib:1-12` | `TileScheme = tsDouble`, `TileType = ttExtended`, `TileXOffset = 0.1`, `TileYOffset = 0.2`; commented defaults `TileSize=64, Rows=16, Cols=16, AlphaRows=8, AlphaCols=4, AlphaTileSize=64` | OBS |
| D6 | Tile→file binding | `data\terrain\tiles\tiles.mat:1-141` | Every TileBlock maps to `.\data\terrain\tiles\textures\<name>.dds` under `refkey=normal` (grass1 at :3-4, rock1 at :71-72, sand1 at :107-108 …) | OBS |
| D7 | Face reuse | `data\terrain\tiles\tiles.mat:142-157` | `rock1vf`/`rock1vs` both point at `rock1.dds` with `refkey=verticalfront` / `verticalside` | OBS |
| D8 | Blend mask binding | `data\terrain\ref\reftile.mat:1-17,24-49` | `Texture2Name = alpha`, `BlendingMode = bmTransparency`, `texturewrap = twBoth`, `minfilter = miNearestMipmapLinear`, `mappingmode = tmmUser` on normal tiles | OBS |
| D9 | Projected cliff mask | `data\terrain\ref\reftile.mat:120-169` | `verticalfront`/`verticalside` set `Texture2Name = alphavert`, `TextureScale = 0.125`, `mappingmode = tmmEyeLinear`, S along X/Y and T along Z (world-up projection) | OBS |
| D10 | Alpha atlas assets | `data\terrain\ref\reftilealpha.mat:30-37,139-146,248-255` | `alpha.bmp`, `alphavert.bmp`, `alphanull.bmp` declared with `imagealpha = tiaAlphaFromIntensity`, `textureformat = tfAlpha`, `twBoth`, `maNearest`/`miNearest` | OBS |
| D11 | Season/scale policy | `data\terrain\tiles\terrain.lib:5-15` | Global `TextureScale = 1` (X/Y/Z/W); `seasons.Summer/Autumn/Spring = Summer`, `seasons.Winter = Winter`; `CoverDisabled=true` | OBS |
| D12 | Tile-index order | `data\terrain\tiles\terrain.presets:2-130,134-263` | Summer and Winter ordered `Blocks[*].TileBlock` lists — the tile index → name dictionary (index 0 = `grass1`…); used by the port sim | OBS |
| D13 | Season by texture | `data\terrain\tiles\tiles.season:1-4` | `TexName = grass1; Summer = grass1` — per-texture seasonal override | OBS |
| D14 | Authoring thresholds | `data\scripts\common.inc\texturemap.inc:25-31,39,415-448` | `cMaxHeight = 2.96`, `cWaterHeight = -0.25`, `cWaterShoreHeight = -0.1`, `cPlaceRoads = True`; terrain texturing iterates all cells using height and neighbour-slope | OBS |
| D15 | Shore tile choice | `data\scripts\common.inc\texturemap.inc:472-529` | Shore cells pick `sandsea1/5/6` by 8-way slope aspect (`cAngle = 45`), append `_winter` when `GetSeasonType=2`, then `SetTileIndex` | OBS |
| D16 | Bitmap-driven tiles | `data\scripts\common.inc\loadtextureterrainfrombitmap.inc:4-9,25-41` | `cLowHeight = 0.1`; loads `tile_lowground.bmp` / `tile_highground.bmp`, `tex := r div 2`, then `SetTileIndex(x,y,tex)` only where current index is 0 | OBS |
| D17 | Authoring bitmap size | `data\gen\bitmap\ext\tile_lowground.bmp`, `tile_highground.bmp` (BMP header @18/22/28) | Both 320×320, 24 bpp — same grid size as our 320×320 map | OBS |
| D18 | Tile art dimensions (headers) | `data\terrain\tiles\textures\*.dds` (DDS header @12/16/28/84) | 110 DDS are **1024×1024 DXT1, 11 mips**; only `sand1.dds`, `sand2.dds` are **256×256 DXT1, 9 mips** | OBS |
| D19 | Mask dimensions (headers) | `alpha.bmp` @18/22/28; `alphavert.bmp` @18/22/28; `alphanull.bmp` core header @12/14/24 | `alpha.bmp` 512×256 8 bpp; `alphavert.bmp` 1024×512 24 bpp; `alphanull.bmp` 512×257 8 bpp (12-byte BITMAPCOREHEADER) | OBS |
| D20 | Detail/normal candidates | `data\materials\env\env.mat:637-638,26-47,641-646`; header of `detail.dds`, `rocks.dds`, `stones.dds`, `terrainmesh1.dds` | `detail.dds` is a named material (2048² DXT1); `stones`/`smallstones`/`rocks`/`rocksea*` are env materials; `terrainmesh1-4` are 2048² DXT5 | OBS |
| D21 | terrainmesh identity | `data\actors\actors.lib:1200-1213` | `terrainmesh1..4` are `LODActorName` entries pointing at `data\actors\env\terrainmeshN.actor` — mesh/prop albedo, not base terrain tiles | OBS |
| D22 | hmapTex classification | `data\shaders\water\water.frag:8,246-247`; `water.dev.frag:18-21,72-73` | `hmapTex` is a **water depth** sampler decoded via `hmapMin/hmapMax`; not a terrain texture. Binding stays UNVERIFIED (TERRAIN2-03 UNV-1) | OBS + UNV |
| D23 | No road tile | `data\scripts\common.inc\texturemap.inc:39`; no `road*.dds` / `Name = road` under `data\materials\*.mat` | Roads are placed by a script pass (`cPlaceRoads`), not a dedicated terrain tile; where the road art lives is UNVERIFIED | OBS + UNV |
| P1 | 2D art lineage | `app\scripts\world.gd:2-3` | "original grass/dirt/rock PNGs … copied from `data/terrain/tiles/textures/*.dds`" at full detail | OBS |
| P2 | 2D conversion | `app\tools\copy_assets.py:160-179` | DDS→PNG of the full donor tile set into `terrain/blocks/`: grass1-10, ground1, grass_ground1-3, grass_rock1, grass_sand1-2, rock1-9, sand1-9, sandsea1-6, sandrock1-6, test0-25, desert1-12, winter0-26 | OBS |
| P3 | 2D extra copies | `app\tools\copy_assets.py:180-223` | legacy single-file copies; all building DDS decals → `terrain/decals_dds/`; deco DXT5 PNGs; `diffusewaves0/2` → `terrain/water_png/`; dmask note (alpha.bmp/alphavert.bmp) | OBS |
| P4 | 2D runtime load | `app\scripts\world.gd:1012-1034` | `_block_img()` loads `res://assets/terrain/blocks/%s.png` via `ResourceLoader`, mirror-tiles to 1024, `adjust_bcs(1.0, 1.12, 1.0)`; 32-entry LRU | OBS |
| P5 | 2D warm-up | `app\scripts\world.gd:250-252,258-267,1040-1042` | Explicit donor block names pre-warmed; 64 px per 2 m cell preserves donor grass grain | OBS |
| P6 | 2D loader helper | `app\scripts\world.gd:371-380` | `_load_env_tex()` uses `Image.load_from_file(globalize_path(path))` for **sprite** PNGs only (fallback `load(path)`), not terrain blocks | OBS |
| P7 | 2D shore/water | `app\scripts\world.gd:911-925,969-972,1060-1063` | `diffusewaves0/1/2` water sheets; donor `waveMap = diffusewaves0`; `sandsea6` grain builds the pale wash | OBS |
| P8 | 3D current albedo | `variant3d\scripts\world3d_terrain.gd:66-67,90-97,100-103` | `SPLAT_PATH = res://assets/terrain/heightmap/splat_albedo.png`, `FALLBACK_BLOCK = …/blocks/grass1.png`; runtime `Image.load` → `ImageTexture`; assigned to `mat.albedo_texture` | OBS |
| P9 | 3D UV mapping | `variant3d\scripts\world3d_terrain.gd:295-317,334,368-370` | One vertex per cell; UV `((x+0.5)/w,(z+0.5)/h)` 0..1 over the whole map — one splat texel per 320×320 cell | OBS |
| P10 | Splat flattening | `app\tools\heightmap_splat.py:191-208,230-237,305-312` | Each block PNG is LANCZOS-resized to `n×n`; default `n=1` ⇒ **one mean RGB per block per cell**; manifest records `mean_rgb` (grass1 `[76,83,30]`) | OBS |
| P11 | Splat provenance | `variant3d\assets\terrain\heightmap\splat_albedo.manifest.json:7,12-16,19-29,32-42` | 320×320, seed `20261113`, dump sha `79f93c…`; grass1 15993 cells, grass2 2863; RGB = "blended port block albedo (sRGB bytes)" | OBS |
| P12 | 3D assets present | `variant3d\assets\terrain\blocks\` and `app\assets\terrain\blocks\` (directory enumeration) | Both contain **112** donor block PNGs (grass1 PNG 1024×1024, sand1 PNG 256×256, PNG IHDR @16/20); `variant3d/assets/terrain/water_png/` has 0-7 | OBS |
| P13 | 3D mask assets inert | `app\scripts\world.gd:1086-1093`; `app\tools\copy_assets.py:220-223` | `_alpha_mask()` builds masks procedurally from a grid's red channel; no loader for `dmask/d_*.png` found in `app/tools/*` — 24 64×64 PNGs are present but unused | OBS + UNV |

---

## 2. Asset table (donor terrain textures)

All sizes are read from binary headers (OBS, see D18/D19). Format `DXT1` = opaque BC1; `DXT5` = BC3 with alpha. Roles come from the named TileBlock / material (D2, D6, D20), not from pixel inspection.

| Name / donor path | Format | Size | Mips | Semantic role (donor evidence) |
|---|---|---|---|---|
| `data\terrain\tiles\textures\grass1.dds` … `grass10.dds` | DDS DXT1 | 1024×1024 | 11 | grass meadow blocks (`tiles.lib:2-30`, `tiles.mat:2-40`) |
| `…\grass_ground1.dds` … `grass_ground3.dds` | DDS DXT1 | 1024×1024 | 11 | grass→bare-earth transition blocks (`tiles.lib:35-42`) |
| `…\grass_rock1.dds` | DDS DXT1 | 1024×1024 | 11 | grass→rock transition (`tiles.lib:44-45`) |
| `…\grass_sand1.dds`, `grass_sand2.dds` | DDS DXT1 | 1024×1024 | 11 | grass→sand transition (`tiles.lib:47-51`) |
| `…\ground1.dds` | DDS DXT1 | 1024×1024 | 11 | bare ground / dirt block; **no dedicated road tile** (`tiles.lib:32`, `texturemap.inc:39`) |
| `…\rock1.dds` … `rock9.dds` | DDS DXT1 | 1024×1024 | 11 | rock/cliff surface (`tiles.lib:92-117`); also reused by `rockNvf`/`rockNs` (`tiles.mat:142-157`) |
| `…\sand1.dds`, `sand2.dds` | DDS DXT1 | **256×256** | 9 | sand tiles with `TileSize=64, Rows=2, Cols=2` (`tiles.lib:53-63`) |
| `…\sand3.dds` … `sand9.dds` | DDS DXT1 | 1024×1024 | 11 | sand tiles; sand3/4 still declared `64/2/2` — atlas interpretation UNVERIFIED (`tiles.lib:65-91`) |
| `…\sandrock1.dds` … `sandrock6.dds` | DDS DXT1 | 1024×1024 | 11 | sand→rock mixed blocks (`tiles.lib:353-369`) |
| `…\sandsea1.dds` … `sandsea6.dds` | DDS DXT1 | 1024×1024 | 11 | shore/waterline transition blocks (`tiles.lib:371-387`, `texturemap.inc:504-511`) |
| `…\desert1.dds` … `desert12.dds` | DDS DXT1 | 1024×1024 | 11 | desert climate blocks (`tiles.lib:836-869`) |
| `…\test0.dds` … `test25.dds` | DDS DXT1 | 1024×1024 | 11 | test/extra blocks; `test10`=128/16/16, `test11`=128/32/32 (`tiles.lib:299-419`) |
| `…\winter0.dds` … `winter26.dds` | DDS DXT1 | 1024×1024 | 11 | winter-season tile set, selected via `seasons.Winter = Winter` (`terrain.lib:14`, `terrain.presets:134-263`) |
| `…\alpha.bmp` | BMP 8 bpp | 512×256 | — | terrain tile blend alpha atlas; `tiaAlphaFromIntensity`, `tfAlpha` (`reftilealpha.mat:30-37`); nominal 8×4 patches of 64×64 (`reftile.lib:10-12`) |
| `…\alphavert.bmp` | BMP 24 bpp | 1024×512 | — | vertical/cliff-face alpha; `TextureScale 0.125`, eye-linear projection (`reftile.mat:122-141`, `reftilealpha.mat:139-146`) |
| `…\alphanull.bmp` | BMP 8 bpp (core header) | 512×257 | — | named "null" alpha material (`reftilealpha.mat:248-255`); shipped use UNVERIFIED |
| `data\materials\env\detail.dds` / `detailw.dds` | DDS DXT1 | 2048×2048 | 12 | named `detail` material (`env.mat:637-638`, `:1452-1453`); construction-site association (`data\scripts\units\building.inc\ontagstates.inc:119`) — **not proven to be a terrain detail map** (UNV) |
| `data\materials\env\rocks.dds`, `stones.dds`, `smallstones.dds` (+ `w` variants, sea variants) | DDS DXT1 | rocks 1024²; stones/smallstones 512² | 11 / 10 | env prop materials (`env.mat:26-47`), **not** terrain tiles |
| `data\materials\env\terrainmesh1-4.dds`, `terrainmeshdesert1-4.dds` | DDS **DXT5** | 2048×2048 | 12 | actor/LOD mesh albedo (`actors.lib:1200-1213`), not splat material |
| `data\water\textures\diffusewaves0/1.bmp`, `diffusewaves2-7.bmp` | BMP 24 bpp | 256² / 512² | — | water waves; TERRAIN2-03 asset, not terrain albedo (`TERRAIN2_03_water_weather.md:32-37`) |
| `data\water\textures\heightmapwaves0.tga` | TGA 32 bpp RLE | 256×256 | — | commented-out normal-map material (`TERRAIN2_03_water_weather.md:32,170`); do **not** bind as terrain texture |

No donor terrain normal map is assigned to any tile: `tiles.mat` binding sections supply only `Material.Texture.image` (`tiles.mat:2-141`); `refnormal.mat` / `refnormalmap.mat` / `refmountainnormal.mat` exist under `data\materials\ref\` but are not referenced by terrain tiles — terrain-normal semantics UNVERIFIED.

---

## 3. Donor usage semantics (how these are meant to be used)

**OBS — one index per 2 m cell, chosen from height/slope/bitmaps, not per-vertex colour:**
- `texturemap.inc:415-448` loops `for y … for x`, reads `GetHeightData`, computes neighbour gradients `dirX = lh-rh`, `dirY = th-bh`, normalises and takes `VectorAngle` — i.e. tile identity is a per-cell discrete choice driven by terrain geometry.
- `texturemap.inc:472-529` uses the 8-way aspect to choose `sandsea1/5/6` on water/shore cells and appends `_winter`.
- `loadtextureterrainfrombitmap.inc:4-9,25-41` picks between `tile_lowground.bmp` and `tile_highground.bmp` at `cLowHeight = 0.1`, reads red, `tex = r div 2`, and fills only unassigned cells (`GetTileIndex(x,y)=0`).
- `tile_lowground.bmp` / `tile_highground.bmp` are 320×320 (D17) — the donor's authoring grid matches our map dimensions.

**OBS — tiles are tiled textures, not one image stretched over the map:**
- `reftile.lib:3-9` sets `tsDouble`/`ttExtended` and non-zero `TileXOffset = 0.1`, `TileYOffset = 0.2`; default `TileSize = 64` with `Rows/Cols` sub-tile grids (`:7-9`).
- `tiles.lib:53-76` overrides sand1-4 to `64/2/2`; `test10` to `128/16/16`, `test11` to `128/32/32` (`:330-339`).
- `terrain.lib:5-10` global `TextureScale = 1`, so the donor does **not** apply an extra scale multiplier to terrain UVs.

**OBS — blending is an alpha-atlas modulation pass:**
- `reftile.mat:6,17` `Texture2Name = alpha`, `bmTransparency`, `twBoth`, `miNearestMipmapLinear` (`:24-49`) — the second texture modulates the tile.
- `reftilealpha.mat:30-37` that second texture is `alpha.bmp`, 8-bit intensity→alpha, `tfAlpha`, nearest sampling; `alphavert.bmp` at `:139-146`.
- `reftile.mat:120-169` vertical faces use `alphavert` with `TextureScale 0.125` and eye-linear coords where T follows world Z — a projected cliff mask, with dedicated `rockNvf`/`rockNs` orientation blocks (`tiles.lib:119-207`).

**INF (labelled):** the donor renders a *seamless field of repeated 1024² tile textures*, with discrete hard block identity per cell whose seams are softened by an alpha atlas; slope-facing rock faces are separate oriented blocks with a projected mask. That is the opposite of our 3D path, which bakes one mean colour per cell.

---

## 4. What the 2D port already uses

- `app/scripts/world.gd:2-3` declares the terrain art lineage as the donor's `data/terrain/tiles/textures/*.dds`.
- `app/tools/copy_assets.py:163-179` converts the **entire** donor TileBlock set (112 textures) to PNG in `terrain/blocks/`; `:180-200` keeps legacy single-file copies; `:202-207` copies all building ground decals; `:208-219` deco + wave bitmaps.
- `app/scripts/world.gd:1012-1034` `_block_img()` loads `res://assets/terrain/blocks/<name>.png`, mirror-tiles to 1024 px, lifts grain via `adjust_bcs(1.0, 1.12, 1.0)`. `app/scripts/world.gd:250-252,258-267` pre-warms the exact donor names (grass1, grass2, ground1, test7-9, sand1, rock1, grass_ground1, test2, grass5, rock9) and every name used by the map.
- `app/scripts/world.gd:1040-1042`: 64 px per 2 m cell — explicitly chosen to preserve donor grass grain.
- `app/scripts/world.gd:911-925,969-972`: donor `diffusewaves0/1/2` feed the animated water shader; `:1060-1063` uses donor `sandsea6` grain for the shore wash.
- `app/scripts/world.gd:1389-1396`: rock8 is described as "the donor's high-face fill" and rock1 supplies stretched flutes — donor-derived face art already exercised in 2D.
- `_load_env_tex` (`app/scripts/world.gd:371-380`) is the sprite/env PNG loader (`Image.load_from_file` on a globalised `res://` path); it is **not** the terrain path.
- `app/assets/terrain/dmask/d_00..23.png` (24 files, 64×64) and the `copy_assets.py:220-223` note trace back to `alpha.bmp`/`alphavert.bmp`, but no code loads them (`_alpha_mask()` is procedural, `app/scripts/world.gd:1086-1093`) — inert in the shipping 2D path (P13).

**Conclusion (INF):** 2D already solves the exact problem 3D has: it renders donor 1024² tile textures at full resolution, mirror-tiled, with donor-derived transition art. The donor art needed by 3D is already on disk in the port.

---

## 5. What 3D currently uses

- `variant3d/scripts/world3d_terrain.gd:66-67`: only `splat_albedo.png` is the albedo source; `blocks/grass1.png` is a **fallback** if the splat fails.
- `variant3d/scripts/world3d_terrain.gd:90-97,100-103`: runtime `Image.load` of the globalised PNG → `ImageTexture` → `mat.albedo_texture` on a `StandardMaterial3D`.
- `variant3d/scripts/world3d_terrain.gd:295-317,334,368-370`: one vertex per cell, UV 0..1 over the full map — one splat texel per 320×320 cell.
- `variant3d/assets/terrain/heightmap/splat_albedo.png` is 320×320 (PNG IHDR @16/20); manifest `variant3d/assets/terrain/heightmap/splat_albedo.manifest.json:7,12-16` says RGB = "blended port block albedo (sRGB bytes)", seed 20261113, from `app\shots\g32_dump.json`.
- `app/tools/heightmap_splat.py:191-208,230-237`: each block PNG is LANCZOS-downsampled to `n×n`; with default `n=1` a cell gets **one averaged RGB** — e.g. grass1 `[76,83,30]` (manifest `:19-29`), grass2 `[77,80,32]` (`:32-42`). This is the direct mechanism of the "poor quality" report: 99.9% of the 1024² donor grain is discarded and rebuilt as flat patches.
- `variant3d/assets/terrain/blocks/` already contains all 112 donor-derived 1024² block PNGs (P12), but the terrain mesh never binds them; `variant3d/assets/terrain/dmask/`, `deco_png/`, `decals_png/`, `water_png/` are likewise present but not part of the single-grid splat material.
- `variant3d/scripts/world3d_terrain.gd:179-194` water is a constant-colour quad at `WATER_LEVEL = -0.25` (`:52`); see TERRAIN2-03 for the water-specific fix.

---

## 6. Highest-value reusable donor textures for 3D (exact paths)

These are all **already converted and present** in `variant3d/assets/terrain/blocks/` (P12), so reuse needs no new donor copy. Donor path is given for provenance only; do not copy binaries.

| Rank | Donor path (read-only) | 1024² PNG already in 3D | Why highest value |
|---|---|---|---|
| 1 | `C:\Games\Cossacks 3\data\terrain\tiles\textures\grass1.dds` | `variant3d/assets/terrain/blocks/grass1.png` | Dominant summer grass: 15,993 of 320² cells in the current splat (P11:19-29); named TileBlock index 0 (`tiles.mat:2-4`, `terrain.presets:6`) |
| 2 | `C:\Games\Cossacks 3\data\terrain\tiles\textures\grass2.dds` | `variant3d/assets/terrain/blocks/grass2.png` | Second grass block (2,863 cells, P11:32-42); second entry in the Summer set (`terrain.presets:7`) |
| 3 | `C:\Games\Cossacks 3\data\terrain\tiles\textures\rock8.dds` | `variant3d/assets/terrain/blocks/rock8.png` | Donor rock family; 2D's proven "high-face fill" (`world.gd:1394-1396`), used for face collars (`:1476-1479`) — the biggest visible gap vs donor rock coverage |
| 4 | `C:\Games\Cossacks 3\data\terrain\tiles\textures\sandsea6.dds` | `variant3d/assets/terrain/blocks/sandsea6.png` | Shoreline tile selected by donor slope logic (`texturemap.inc:505-511`); also 2D's wash grain (`world.gd:1060-1063`) and the splat's default water-block (manifest `:430`, `heightmap_splat.py:24-26`) |
| 5 | `C:\Games\Cossacks 3\data\terrain\tiles\textures\ground1.dds` | `variant3d/assets/terrain/blocks/ground1.png` | Bare earth/dirt block (`tiles.lib:32`, `terrain.presets:16`), the 2D role block for terrain type 1 (`world.gd:1587`) and nearest thing to a "road/dirt" surface — no road tile exists (D23) |

Supporting (not top-5, but directly donor-grounded):
- `data\terrain\tiles\textures\alpha.bmp` (512×256, 8 bpp) — the actual donor blend atlas (`reftilealpha.mat:30-37`, 8×4×64 nominal patches per `reftile.lib:10-12`); use for tile-to-tile feathering, not a flat opacity guess.
- `data\terrain\tiles\textures\alphavert.bmp` (1024×512, 24 bpp) — projected cliff mask with `TextureScale 0.125` (`reftile.mat:120-169`); needs face separation on the mesh (UNVERIFIED binding).
- `data\terrain\tiles\textures\rock1.dds` + `rock1vf/rock1vs` orientation semantics (`tiles.lib:119-127`, `tiles.mat:142-148`) — donor's own striated cliff face; 2D already uses stretched rock1 flutes (`world.gd:1488-1490`).
- `data\materials\env\detail.dds` (2048² DXT1) — candidate micro-detail overlay, but its role is named `detail` material (`env.mat:637-638`) with construction association (`ontagstates.inc:119`); treated as UNVERIFIED for terrain.

---

## 7. Ranked recommendations (donor-grounded)

- **P0 — Bind the donor block textures the 3D port already owns.** Use `variant3d/assets/terrain/blocks/*.png` (1024²) as real tiled albedo with per-cell UV scaling instead of the 320² splat. Evidence: D6/D18/P12 vs P8/P9/P10. This is the same recipe 2D ships at `world.gd:1012-1034`; no donor binary is copied and no new art is invented. 3D's fallback already points at `grass1.png` (`world3d_terrain.gd:67`), so the loader exists.
- **P1 — Interim: re-bake the splat at N texels/cell with the existing tool** (`app/tools/heightmap_splat.py:230-237,383-384`; `--texels-per-cell`), keeping the donor-derived manifest provenance (`splat_albedo.manifest.json:12-16`). This restores in-cell grain without a shader rewrite; it is explicitly a stopgap vs P0 because it still averages within a cell.
- **P1 — Use `alpha.bmp` as the transition mask** with the donor's `bmTransparency` / `tfAlpha` / `twBoth` semantics (`reftile.mat:6,17,24-49`; `reftilealpha.mat:30-37`), instead of the current flat neighbour blend (`heightmap_splat.py:244-249`). Do not fabricate alpha values; derive from the donor atlas.
- **P2 — Cliff faces:** adopt `rockNvf`/`rockNs` + `alphavert` world-Z projection (`tiles.lib:119-207`, `reftile.mat:120-169`) only when the single full-grid mesh (`world3d_terrain.gd:14-16`) is split by slope or gets a face pass. Binding to today's grid is UNVERIFIED — do not bake `alphavert` into the splat speculatively.
- **P2 — Season/climate sets:** drive Winter/Desert from `terrain.lib:12-15`, `tiles.season:1-4`, `terrain.presets:134-263` using the already-copied `winter0-26` / `desert1-12` PNGs; do not invent seasonal tints.

Direct conflict to avoid: TERRAIN2-04's P1-3 (`TERRAIN2_04_gap_recipe.md:161-167`) already proposes using the dump's `terrain` grid for shore identity; this report's P1 shoreline recommendation is the same change and should be merged, not duplicated.

---

## 8. Open questions / UNVERIFIED

1. **UNV-1 — `hmapTex` binding.** Declared as a water depth sampler (`water.frag:8,246-247`; `water.dev.frag:18-21,72-73`), not a terrain texture. No script binds it; TERRAIN2-03 UNV-1 (`TERRAIN2_03_water_weather.md:170`) remains open. Do **not** substitute `heightmapwaves0.tga`.
2. **UNV-2 — `detail.dds` exact role.** `env.mat:637-638` names it `detail`; `building.inc\ontagstates.inc:119` references material `'detail'`; the pixel-level construction/shader math is unknown. Do not call it a terrain normal or detail map without a GPU A/B or engine read.
3. **UNV-3 — terrain normal maps.** No terrain tile references a normal texture (`tiles.mat:2-141`); `refnormal*.mat` exist but are unbound. Any "terrain normal" slot would be invented.
4. **UNV-4 — `alphanull.bmp`** uses a 12-byte BITMAPCOREHEADER (512×257, 8 bpp); its shipped use is only a named material (`reftilealpha.mat:248-255`) — UNVERIFIED.
5. **UNV-5 — sand atlas metadata.** `sand1`/`sand2` are 256² while `sand3`/`sand4` are 1024², yet all four declare `TileSize=64, Rows=2, Cols=2` (`tiles.lib:53-76`). The sub-tile interpretation is ambiguous.
6. **UNV-6 — road art.** `cPlaceRoads = True` (`texturemap.inc:39`) but no `road*.dds` or `Name = road` material was found; road geometry/material binding UNVERIFIED.
7. **UNV-7 — `dmask/d_*.png` (24 × 64²)** exist in both asset trees (`P12/P13`) but no loader appears in `app/tools/*` or `app/scripts/world.gd:1086-1093`; whether they are consumed by another scene is UNVERIFIED.
8. **UNV-8 — no pixel inspection.** No donor DDS/BMP/TGA payload was decoded or viewed; roles are inferred from file names + config bindings only. All visual-quality claims require GPU A/B (charter `:15`).
9. **UNV-9 — active vs commented donor script lines.** Most `texturemap.inc` / `loadtextureterrainfrombitmap.inc` lines are commented with `;` in the shipped files (e.g. `texturemap.inc:415-448`); they document intended semantics but their runtime activity in this build is UNVERIFIED (see TERRAIN2-03's parallel note at `TERRAIN2_03_water_weather.md:164`).

---

## 9. Bottom line

The donor supplies a rich, fully-tiled terrain texture library — 110 opaque 1024² DXT1 tile textures across grass/dirt/rock/sand/desert/winter families, plus a 512×256 alpha blend atlas and a 1024×512 projected cliff mask. The 2D port already converts and renders all of it at full resolution. The 3D port has **the same 112 PNGs on disk** but binds only a single 320×320 splat whose cells are one averaged RGB per donor block. The top five donor textures to reuse in 3D are `grass1.dds`, `grass2.dds`, `rock8.dds`, `sandsea6.dds`, `ground1.dds` (already present as `variant3d/assets/terrain/blocks/<name>.png`).
