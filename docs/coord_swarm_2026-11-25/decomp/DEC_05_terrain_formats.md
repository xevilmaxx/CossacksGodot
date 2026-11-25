---
id: DEC-05
title: "Donor terrain formats: terrainmesh*.osm, height rasters, DDS albedo/mask/height, tile-index and blend/splat blobs"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_DONOR_COPY__NO_CODE_EDIT
donor: "C:\\Games\\Cossacks 3 (READ-ONLY private use; Python 3.14 bytes/latin-1/struct + Pillow headers/pixels; no donor file copied, modified or executed)"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
output: "docs/coord_swarm_2026-11-25/decomp/DEC_05_terrain_formats.md"
labels: [observed, derived, inferred, UNVERIFIED]
verification_passes: 2
visual_parity_claim: false
---

# DEC-05 — Donor terrain binary formats, deeply documented

## 0. Goal

Document every donor terrain-related **binary** format that can feed the 3D terrain
fix: `terrainmesh*.osm`, height/bitmap rasters, `.dds` albedo / mask / alleged
normal-or-height images, and any tile-index / blend / splat blob; give magic,
version, header offsets, record layout, dimensions, data type and world-coordinate
mapping; establish the ground-rendering truth (tile-id → texture, blend rule,
terrain-type count, tile size, height quantisation, near-water exceptions); and
feed the result into today's terrain-quality work.

**No donor file was copied into the repo. No `app/`, `variant3d/`, asset, config or
test file was edited. This report is the only repository file written.**

---

## 1. Prior documents read (all in full unless noted)

| # | Document | What it contributed / where it was checked |
|---|---|---|
| P1 | `docs/audit/TERRAIN_DONOR_PIPELINE.md` | generator constants, R/G/B mask codes, smoothing, stage order |
| P2 | `docs/audit/TERRAIN_DONOR_ASSETS.md` | mask/TGA/DDS inventory, water images, config extract |
| P3 | `docs/audit/TERRAIN_DONOR_PATTERNS.md` | `.pattern` format (not a height/tile format), 710-file census |
| P4 | `docs/audit/TERRAIN_DONOR_WATER.md` | water shader constants, `heightmapwaves0.tga` role |
| P5 | `docs/coord_swarm_2026-11-24/reports/TERRAIN2_01_donor_pipeline.md` | E01–E74, OSM header decode E52, tile/shader chain |
| P6 | `docs/coord_swarm_2026-11-24/reports/TERRAIN2_02_donor_textures.md` | DDS/BMP header facts D18/D19, "no splat" claim, 3D flattening P8–P12 |
| P7 | `docs/coord_swarm_2026-11-24/reports/TERRAIN2_06_tileindex_architecture.md` | tile-index representation, A1–A5 atomic design, blocked items |
| P8 | `docs/coord_swarm_2026-11-24/reports/G32_heightmap_world.md` | full-grid mesh, dump schema, `TILE_M=2.0` port constant |
| P9 | `docs/coord_swarm_2026-11-24/reports/G33_heightmap_capture.md` | donor JPG capture baseline, A/B caveat |
| P10 | `docs/coord_swarm_2026-11-24/reports/G34_heightmap_splat.md` | one-mean-RGB-per-cell splat mechanism, manifest schema |
| P11 | `docs/coord_swarm_2026-11-24/reports/DEEPDEC_02_terrain_render.md` | shader equations, HeightField RTTI, evidence ids, `sub_501420` UNVERIFIED |
| P12 | `docs/decomp/DC_FORMATS.md` | extension census, `.osm` 17-int32 layout, `.map` "closed binary" verdict |
| P13 | `investigation.cany/investigation/findings.md` | `fnd_1`: 26.6666666 px/m, 53.3333333 px/tile (evidence `ev_0d087bb7…`, `ev_b526c882…`) |
| P14 | `docs/coord_swarm_2026-11-25/reports/DTRN_01_donor_terrain_pipeline.md` | today's render-truth report; C1–C28, M1–M11, fix recipe |
| P15 | `docs/coord_swarm_2026-11-25/reports/DTRN_03_donor_shore_water.md`, `DTRN_04_donor_trees.md` | checked for overlap; shore/tree scope, not relied on for binary claims |

`DTRN-02` and `DTRN-06` did **not** exist at the time of writing; they are not cited
as evidence. P14 is cited instead.

---

## 2. Method, evidence discipline, verification

- **Read-only donor access:** `open(path,'rb').read()` on Windows with `python`
  (3.14); text decoded `latin-1`; integer/float fields via `struct.unpack_from`;
  image headers via raw bytes; pixel distributions via Pillow 12.1.1 **read-only**.
  Temporary scripts lived in `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\`,
  never in the repository.
- **Evidence labels:** **observed** = literal byte/line read, cited as `path:offset`
  or `path:line`; **derived** = deterministic arithmetic over observed values;
  **inferred** = best reading with an explicit caveat; **UNVERIFIED** = cannot be
  proven from readable data.
- **Twice-verified rule:** every headline number was confirmed by two independent
  means: (V1) `struct`/regex/Pillow script pass and (V2) a second script using a
  different method (raw-byte histogram, independent full-file scan, or a second
  donor file). Specific cross-checks: DDS headers (sample + 1,469-file census),
  TGA headers (samples + 4,510-file census), BMP R histogram (Pillow + raw
  bottom-up byte parse), OSM headers (four files + size closure + P5 E52), `.map`
  header (38-file scan + full payload decode in four maps), tile smoothing (regex
  count + `smoothtiles.inc` control flow).
- **Craft Anything:** `core_session_show` / `core_targets_list` reported
  `active_target: null`, `targets: []`, 5 unrelated evidence records; no target was
  opened or selected (that would write investigation state). Therefore **no new
  evidence ids were generated**; all citations below are `path:offset` / `path:line`
  hexdumps and, where useful, existing ids from P11/P12. Hexdumps use this
  convention: `C:\Games\Cossacks 3\<relative path>:<hex offset>` — abbreviated in
  tables to `data\…:0x…`.

---

## 3. File inventory (observed)

### 3.1 `terrainmesh*.osm` and companions

All paths relative to `C:\Games\Cossacks 3\`.

| File | Bytes | Role |
|---|---:|---|
| `data\actors\env\terrainmesh1.osm` | 191,356 | static relief mesh 1 |
| `data\actors\env\terrainmesh2.osm` | 163,452 | static relief mesh 2 |
| `data\actors\env\terrainmesh3.osm` | 156,092 | static relief mesh 3 |
| `data\actors\env\terrainmesh4.osm` | 201,604 | static relief mesh 4 |
| `data\actors\env\terrainmesh{1..4}.actor` | 223–237 | one `LODList.Items[0]` mesh binding each |
| `data\objects\env\terrainmesh{1..4}.prop` | 757 | summer=terrainmeshN, winter=terrainmeshNw |
| `data\objects\env\terrainmeshdesert{1..4}.prop` | 787 | desert material variants |
| `data\materials\env\terrainmesh{1..4}[w].dds` | 5,592,560 ×8 | 2048² DXT5, 12 mips |
| `data\materials\env\terrainmeshdesert{1..4}.dds` | 5,592,560 ×4 | desert albedo |

**Correction to the task premise (observed):** there is **no**
`data\terrain\heightmap\**` and **no** `data\terrain\blocks\**` in the donor. Those
are **port-side** directories (`app/assets/terrain/heightmap` 2 files,
`variant3d/assets/terrain/heightmap` 3 files, both `assets/terrain/blocks` 224
entries = 112 PNG + 112 `.import`). The donor equivalents are
`data\gen\bitmap\**`, `data\gen\terrainmasks*\**` and
`data\terrain\tiles\textures\**`.

### 3.2 Height / mask rasters

| Root | Files | Format | Dimensions | Notes |
|---|---:|---|---|---|
| `data\gen\terrainmasks` | 1,336 (1,331 TGA) | TGA **RLE type 10**, 24 bpp | 320×320 | `_gauss` random-map masks |
| `data\gen\terrainmasks.src` | 1,281 (1,279 TGA) | TGA **RLE type 10**, 24 bpp | 256×256 | pre-process sources |
| `data\gen\terrainmasks.dlc5` | 1,861 (1,856 TGA) | TGA **RLE type 10**, 24 bpp | 320×320 | adds coastal/lakes/rivers |
| `data\gen\bitmap` | 85 BMP + `postpatterns.cfg` | BMP 24/32 bpp | 79×320², 3×384², 3×512² | mission/source bitmaps, not tile art |
| `data\gen\bitmap\ext` | 2 BMP | BMP 24 bpp | 320×320 | `tile_lowground.bmp`, `tile_highground.bmp` |
| `data\water\textures\heightmapwaves0.tga` | 1 | TGA **RLE type 10**, 32 bpp | 256×256 | name says height; see §4.4 |

All 4,510 donor TGA headers: **4,467 type 10 (RLE), 43 type 2 (uncompressed)**;
depths 24 bpp ×4,479, 32 bpp ×31 (**observed**, full census). The prior claim
"uncompressed 24-bit RGB TGA" (P2 §2.1) is **refuted** for the shipped masks.

### 3.3 Tile textures / blend assets

- `data\terrain\tiles\textures\**`: **115 files** = 112 `.dds` + 3 `.bmp`.
- DDS: 110 × 1024×1024 DXT1 / 11 mips; `sand1.dds`, `sand2.dds` 256×256 DXT1 / 9 mips (**observed**).
- `alpha.bmp` 512×256 8 bpp, `alphavert.bmp` 1024×512 24 bpp,
  `alphanull.bmp` 512×256 8 bpp **12-byte BITMAPCOREHEADER** (see §4.5).
- Whole-donor DDS census (1,469 files): DXT5 1,284; DXT1 179; DXT3 6.
  The only `norm`-named DDS is `data\materials\units\musketsmokenorm.dds`
  (DXT5, 2048²) — **no terrain normal or height DDS exists** (**observed**).
- `data\terrain\ref\reftile.lib/.mat`, `reftilealpha.mat`;
  `data\terrain\tiles\tiles.lib/.mat/terrain.presets/terrain.lib/tiles.season`;
  `data\gen\tilesmooth.cfg`, `tilesmooth_scripts.cfg` — the "blend/splat" data is
  **text config**, not a binary weight map.

### 3.4 `.map` files — the per-cell terrain blob

38 `.map` files under `data\maps\`, sizes 23,447,543–125,689,207 bytes
(**observed**, full scan). Each contains a length-prefixed ASCII marker pair
`TerrainMapBegin … TerrainMapEnd`; the first 4 int32 after the marker give the
grid. Header shapes across the 38 files: 320×320 (31 files), 384×384 (3 files),
4 files whose marker lies beyond the first 32 MiB (not followed further —
**UNVERIFIED** for those four). Collision field is always **4**; the fourth int32
is 64 or 25,920 (0x6540) — semantics **UNVERIFIED**.

---

## 4. Per-format binary layout

### 4.1 `.osm` — `terrainmesh*.osm` (IDP2 / MD2-style static mesh)

**Magic `IDP2` = `0x32504449` at `0x00`; version `8` at `0x04` (observed).**
68-byte header, 17 little-endian int32:

| Offset | Field | terrainmesh1 | terrainmesh2 | terrainmesh3 | terrainmesh4 |
|---:|---|---:|---:|---:|---:|
| 0x00 | magic `IDP2` | 844121161 | same | same | same |
| 0x04 | version | 8 | 8 | 8 | 8 |
| 0x08 | `sw` skin width | 256 | 256 | 256 | 256 |
| 0x0c | `sh` skin height | 256 | 256 | 256 | 256 |
| 0x10 | `fs` section-size hint | 42,608 | 36,368 | 34,848 | 40,160 |
| 0x14 | `ns` sections | 1 | 1 | 1 | 1 |
| 0x18 | `nv` vertices | 2,662 | 2,272 | 2,177 | 2,509 |
| 0x1c | `nu` UVs | 2,662 | 2,273 | 2,170 | 5,158 |
| 0x20 | `nt` triangles | 5,305 | 4,532 | 4,323 | 5,002 |
| 0x24 | `ng` gl-command count | 0 | 0 | 0 | 0 |
| 0x28 | `nf` frames | 1 | 1 | 1 | 1 |
| 0x2c | `os` section start | 68 | 68 | 68 | 68 |
| 0x30 | `ou` UV offset | 132 | 132 | 132 | 132 |
| 0x34 | `ot` triangle offset | 21,428 | 18,316 | 17,492 | 41,396 |
| 0x38 | `of` vertex-frame offset | 148,748 | 127,084 | 121,244 | 161,444 |
| 0x3c | `og` end-of-geometry | 191,356 | 163,452 | 156,092 | 201,604 |
| 0x40 | `oe` file size | 191,356 | 163,452 | 156,092 | 201,604 |

Section bodies (matches P12 §2.2; **observed**, size-closed on all four files):
UVs `nu × <2f>` from `ou`; triangles `nt × <6i>` (3 vertex idx + 3 UV idx,
winding swap `(0,2,1)`) from `ot`; vertices begin at `of+16` (16-byte
frame/name header) then `nv × <3f I>` (xyz float32 + one uint32 attribute word).
Closure: `ou + nu*8 == ot`, `ot + nt*24 == of`, `of + 16 + nv*16 == oe == filesize`
— true for 4/4 files. The uint32 attribute word is `1` for every vertex in all
four meshes (1 distinct value).

Decoded first-frame bbox (**derived** from vertex floats):

| Mesh | x | y | z |
|---|---|---|---|
| terrainmesh1 | −14.021 … 13.888 | −13.524 … 13.446 | 0.070 … 7.449 |
| terrainmesh2 | −13.227 … 13.092 | −12.666 … 12.954 | −0.025 … 8.035 |
| terrainmesh3 | −12.935 … 12.988 | −12.839 … 12.976 | 0.011 … 9.550 |
| terrainmesh4 | −12.670 … 12.670 | −12.828 … 12.828 | 0.013 … 6.933 |

Short hexdumps:

```
C:\Games\Cossacks 3\data\actors\env\terrainmesh1.osm:0x00
00000000  49 44 50 32 08 00 00 00 00 01 00 00 00 00 01 00 00  IDP2............
00000010  70 a6 00 00 01 00 00 00 66 0a 00 00 66 0a 00 00  p.......f....f...
00000020  b9 14 00 00 00 00 00 00 01 00 00 00 44 00 00 00  ............D...
00000030  84 00 00 00 b4 53 00 00 0c 45 02 00 7c eb 02 00  ...S...E..|...
00000040  7c eb 02 00 53 6b 69 6e 42 69 74 4d 61 70 3a 3a  ...SkinBitMap::
```

**World-coordinate mapping (observed + inferred):** the header/vertex data carry no
world transform. Placement comes from text: `.actor` binds
`LODList.Items[0].MeshObjects.LoadFromFile = .\data\actors\env\terrainmeshN.osm`;
`.prop` sets `LODActorName=terrainmeshN`, summer/winter material swap, no scale/offset
fields. Generator stamps these via pattern families (`generator.cfg` `mountains`,
`plateau*`, `hills_*` — P5 E53/E54), so a mesh instance is placed at a **generator
cell** in centred coordinates (`realx = x − W/2`, `realy = y − H/2`, P5 E21).
The local bbox spans ≈±13 units, i.e. ≈26 m at the donor ground scale (§5.4) —
**inferred**, no donor line states the prop's world scale.

### 4.2 `.dds` — tile albedo / relief albedo

**Magic `DDS ` (0x20534444) at `0x00`; `dwSize=124` at `0x04`** (observed). Standard
header fields: `dwHeight @0x0c`, `dwWidth @0x10`, `dwPitchOrLinearSize @0x14`,
`dwMipMapCount @0x1c`; `DDPIXELFORMAT` starts `0x4c` with `dwSize=32 @0x4c`,
`dwFlags @0x50`, **`dwFourCC @0x54`** (`DXT1`/`DXT3`/`DXT5`), `dwRGBBitCount @0x58`.
Caps at `0x6c`/`0x70` (e.g. `rock1.dds` caps `0x401008`, caps2 `0`).

```
C:\Games\Cossacks 3\data\terrain\tiles\textures\rock1.dds:0x00
00000000  44 44 53 20 7c 00 00 00 07 10 0a 00 00 04 00 00  DDS |...........
00000010  00 04 00 00 00 00 08 00 00 00 00 00 0b 00 00 00  ................
00000020  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000040  00 00 00 00 00 00 00 00 00 00 00 00 20 00 00 00  ............ ...
00000050  04 00 00 00 44 58 54 31 00 00 00 00 00 00 00 00  ....DXT1........
00000060  00 00 00 00 00 00 00 00 00 00 00 00 08 10 40 00  ..............@.
```

Compression/data type: BC1/DXT1 for all 112 ground tiles (opaque RGB), BC3/DXT5
for relief mesh albedo (alpha present). File size closure for DXT1 1024²/11 mips
= 699,192 B; 256²/9 mips = 43,832 B; DXT5 2048²/12 mips = 5,592,560 B
(**derived**, matches on-disk sizes). **No DDS stores terrain height or a terrain
normal vector** (§3.3, V1+V2).

### 4.3 TGA — terrain masks and the "heightmap"

18-byte TGA header: `idlength @0x00`, `colormaptype @0x01`,
**`imagetype @0x02`**, cmap spec `@0x03..0x07`, `xorigin @0x08`, `yorigin @0x0a`,
`width @0x0c`, `height @0x0e`, **`pixeldepth @0x10`**, `imagedescriptor @0x11`.
Pixel data follows immediately (idlength=0). All mask samples:
`00 00 0a 00 …` → imagetype 10 RLE, 24 bpp, descriptor 0x0; `.src` sample
descriptor 0x20 = top-left origin; `_gauss` descriptor 0x0 = bottom-left origin
(**observed**). RLE packets are the standard TGA 1-byte repetition/raw flag; a
decoded packet walk on `heightmapwaves0.tga` starts
`count=51 hdr=0x58` (raw packet) then `count=249 hdr=0xb9` (RLE) etc.

```
C:\Games\Cossacks 3\data\water\textures\heightmapwaves0.tga:0x00
00000000  00 00 0a 00 00 00 00 00 00 00 00 00 00 01 00 01  ................
00000010  20 08 33 58 d1 97 ff 6e e7 ad ff 8b ff c9 ff 91   .3X...n.........
00000020  ff cf ff 7e f7 ba ff 6d e4 a7 ff 66 d8 9c ff 5d  ...~...m...f...]
```

Decoded 256×256 RGBA: R ∈ 111…220 (101 distinct), G ∈ 167…255 (80),
B ∈ 58…178 (110), **A = 255 for all 65,536 pixels (1 distinct value)**
(**observed**, Pillow decode + raw RLE header walk). Consequences:
- Donor `water.dev.frag` reads `h = hmapMin + hmapTex.w*(hmapMax-hmapMin)`;
  a file with constant alpha **cannot carry a varying height field**. The shader
  binding of `hmapTex` remains **UNVERIFIED** (P4/P11 agree); this file is not a
  usable height source as shipped.
- Its RGB distribution (green-dominant, values ≈111–255) is consistent with an
  **encoded normal map**, matching the commented `tfNormalMap` material in
  `water.mat` (**inferred**, not proven).

### 4.4 BMP — height/tile source bitmaps and alpha atlases

`BM` at `0x00`, `bfOffBits @0x0a`; DIB size @0x0e (40 = BITMAPINFOHEADER,
12 = BITMAPCOREHEADER); `width @0x12`, `height @0x16` (int32 for DIB40,
uint16 for DIB12), `planes @0x16/0x1a`, `bpp @0x1a/0x1e`. Rows are bottom-up,
BGR byte order (24 bpp), stride = `((w*3+3)//4)*4`.

```
C:\Games\Cossacks 3\data\gen\bitmap\ext\tile_lowground.bmp:0x00
00000000  42 4d 38 b0 04 00 00 00 00 00 36 00 00 00 28 00  BM8...........(.
00000010  00 00 40 01 00 00 40 01 00 00 01 00 18 00 00 00  ..@...@.........
00000020  00 00 02 b0 04 00 12 0b 00 00 12 0b 00 00 00 00  ................
00000030  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00000040  00 00 00 00 00 00 00 9c 00 00 00 00 00 00 00 00  ................
```

| File | DIB | W×H | bpp | pixel offset |
|---|---:|---|---:|---:|
| `gen\bitmap\ext\tile_lowground.bmp` | 40 | 320×320 | 24 | 54 |
| `gen\bitmap\ext\tile_highground.bmp` | 40 | 320×320 | 24 | 54 |
| `gen\bitmap\bitmapsrc.bmp` | 40 | 320×320 | 32 | 54 |
| `gen\bitmap\ausmis1.bmp` | 40 | 320×320 | 32 | 54 |
| `terrain\tiles\textures\alpha.bmp` | 40 | 512×256 | 8 | 1,070 (256-entry palette) |
| `terrain\tiles\textures\alphavert.bmp` | 40 | 1024×512 | 24 | 54 |
| `terrain\tiles\textures\alphanull.bmp` | **12** | 512×256 | 8 | 794 (256-entry palette) |

`tile_lowground.bmp` red-byte histogram (**observed**, Pillow + independent raw
bottom-up parse, identical results): 12 distinct values —
`0:51,517`, `158:19,787`, `156:10,849`, `2:7,598`, `166:3,531`, `170:3,530`,
`160:2,678`, `168:1,380`, `14:765`, `154:530`, `12:156`, `164:79`.
`tile_highground.bmp`: 10 distinct — `156:34,838`, `158:17,167`, `160:14,619`,
`170:12,975`, `166:8,853`, `14:7,592`, `2:3,766`, `168:2,063`, `18:479`,
`16:48`. Applying the donor decode `r = floor(fr*255); tex = r div 2`
(`loadtextureterrainfrombitmap.inc:33,36`) yields index sets
`{0,1,6,7,77,78,79,80,82,83,84,85}` (low) and
`{1,7,8,9,78,79,80,83,84,85}` (high) — i.e. **even-byte quantisation to 12/10
preset ids**, not a continuous splat. `bitmapsrc.bmp` has R/G/B unique counts
196/248/107 and 2,590 white pixels (R=G=B=255) = start markers
(**observed**); `ausmis1.bmp` has only 5 R values and 2 B values
(`{0:96,956, 255:5,444}`) — the classic mask-code raster.

`alpha.bmp` palette intensities 0…253 (254 distinct; modal 253:39,427 px,
0:23,658 px) = the authored tile-seam alpha atlas; `alphavert.bmp` RGB channels
each have all 256 values, modal 0 ≈295k px and 255 ≈86k px = projected cliff mask;
`alphanull.bmp` is a 512×256 all-zero (L=0) image with a 256-step grayscale palette.
**Correction:** P6 D19 said `alphanull.bmp` is 512×**257**; the raw bytes at
`0x12/0x14` are `00 02 / 00 01` = **512×256** (P14 C24 already agrees).

```
C:\Games\Cossacks 3\data\terrain\tiles\textures\alphanull.bmp:0x00
00000000  42 4d 1c 03 02 00 00 00 00 00 1a 03 00 00 0c 00  BM..............
00000010  00 00 00 02 00 01 01 00 08 00 00 00 00 01 01 01  ................
00000020  02 02 02 03 03 03 04 04 04 05 05 05 06 06 06 07  ................
```

### 4.5 `.map` — the per-cell terrain container (new finding)

File start is a **length-prefixed token stream**, not a raw array:

```
C:\Games\Cossacks 3\data\maps\missions\ausmis1.map:0x00
00000000  35 00 00 00 4f 53 57 4d 61 70 31 33 2e 4d 61 70  5...OSWMap13.Map
00000010  2e 56 65 72 5b 30 2e 30 5d 42 75 69 6c 64 2e 56  .Ver[0.0]Build.V
00000020  65 72 5b 32 2e 30 2e 30 2e 32 38 34 33 5d 43 6f  er[2.0.0.2843]Co
00000030  72 65 2e 56 65 72 5b 31 5d 20 00 00 00 11 55 49  re.Ver[1] ...UI
00000040  44 31 30 38 37 33 33 33 36 37 33 36 39 34 31 31  D108733367369411
...
000000c0  00 47 61 6d 65 4d 61 70 53 6e 61 70 53 68 6f 74  .GameMapSnapShot
000000d0  42 65 67 69 6e 00 00 00 00 12 00 00 00 47 61 6d  Begin........Gam
000000e0  65 4d 61 70 53 6e 61 70 53 68 6f 74 45 6e 64 12  eMapSnapShotEnd.
000000f0  00 00 00 47 61 6d 65 4d 61 70 52 65 63 6f 72 64  ...GameMapRecord
```

`0x00`: int32 **53** = byte length of `OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0.2843]Core.Ver[1] `;
then int32 **32** = length of `UID108733367369411`; then int32-length-prefixed
strings `GameMapSnapShotBegin\0`, `GameMapSnapShotEnd\0`, `GameMapRecordBegin\0`.
Further on, an int32-length-prefixed `TerrainMapBegin` opens the terrain blob:

```
C:\Games\Cossacks 3\data\maps\missions\ausmis1.map:0x012f63ee
012f63ee  54 65 72 72 61 69 6e 4d 61 70 42 65 67 69 6e 40  TerrainMapBegin@
012f63fe  01 00 00 40 01 00 00 04 00 00 00 40 00 00 00 00  ...@.......@....
012f640e  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
```

Header immediately after the 15-byte marker (offset `0x012f63fd`):
**`<4i` = `320, 320, 4, 64`** = width, height, collision-per-axis, unknown flag.
`TerrainMapEnd` is at `0x01897575`; payload length = 6,025,544 B. Corpus scan
(38 files): 320×320/4/64 (21), 320×320/4/25920 (10), 384×384/4/25920 (2),
384×384/4/64 (1), 4 markers not found in first 32 MiB (**observed**).

Inside `ausmis1.map`'s payload, at payload offset 2,050,621 (file offset
**21,933,642**) begins an array of **exactly `w*h = 102,400` records, 37 bytes each**
(3,788,800 B) whose first 16 bytes are four `float32 1.0` values:

```
C:\Games\Cossacks 3\data\maps\missions\ausmis1.map:0x014f4a3d
001f4a3d  00 00 80 3f 00 00 80 3f 00 00 80 3f 00 00 80 3f  ...?...?...?...?
001f4a4d  00 00 00 00 00 00 00 00 00 00 ff ff 00 10 10 19  ................
001f4a5d  19 cb 00 00 00 00 00 80 3f 00 00 80 3f 00 00 80  .........?...?...
```

Record layout (**observed** byte statistics over all 102,400 records):

| Offset in record | Type | Statistics | Reading |
|---:|---|---|---|
| +0…+15 | 4 × float32 | all exactly 1.0f | constant white/colour or weight quad (**semantics UNVERIFIED**) |
| +16…+25 | 10 bytes | all 0x00 | padding / flags |
| +26…+27 | 2 bytes | all 0xff 0xff | constant marker |
| +28 | 1 byte | all 0x00 | padding |
| +29…+32 | 4 bytes | each position 51 distinct values, 0…101; top ids 0, 25, 79, 78, 10, 14, 16, 4, 97, 1, 73, 20, 98, 93, 80 | **inferred** per-cell TileBlock id(s); ids map cleanly into `presets_summer.json` (`grass1`, `rock9`, `test8`, `test7`, `ground1`, `grass_ground1`, `grass_ground3`, `grass5`, `sandsea5/6/1`, …) |
| +33 | 1 byte | all 256 values, near-uniform | per-cell byte field (height quantisation? seed? **UNVERIFIED**) |
| +34…+36 | 3 bytes | all 0 except last record | padding |

**Verification twice:** the same 37-byte stride, same start offset 2,050,621 and
exactly 102,400 records were reproduced in `ausmis1.map`, `ausmis2.map`,
`rusmis1.map`, `bonmis1.map` (all 320×320) — **observed**. Other int32/float arrays
precede this record block (e.g. a float raster with values ≈0.0…1.0 around payload
offset 2,000,000, and long zero runs), but no array could be closed as
`height:Float/tex:Integer/collision[4]`; the internal payload layout outside the
37-byte record block is **UNVERIFIED**. Sub-markers `MergeCameraBegin/End` and
`MergeModulesBegin/End` occur near the end of the payload (file offsets 25,722,438
and 25,723,213).

**Correction to P12 / P14:** P12 T-7 called `.map` "closed binary" and P14 C2
said "no donor file contains a tile-index/splat array". The `.map` container **does**
carry a 320×320 (or 384×384) per-cell record grid with id-like bytes; whether it is
the authoritative `GetTileIndex` buffer (vs. an editor/merge cache) is **UNVERIFIED**.
The "no splat weights" half of P14 C2 stands.

### 4.6 Text formats carrying terrain structure (headers/records)

| Format | Magic/version | Records | Values |
|---|---|---|---|
| `terrain\tiles\terrain.presets` | none (OSW config `section.begin`), no version | 2 sections `SetName=Summer/Winter`, `DefaultIndex=0`, `WaterSet=Summer/Winter` | **124** `Blocks[*].TileBlock` names each; index 0 = `grass1`; Winter names `*_winter`; 0 duplicates (**observed**) |
| `terrain\tiles\tiles.mat` | `{refurl=…\reftilealpha.mat}` first line | **253** `section.begin {refurl=…\reftile.mat; refkey=X}` blocks, **253** `Material.Name`/`Material.Texture.image` pairs | refkeys: normal 199, verticalfront 18, verticalside 18, normalside 18 (**observed**) |
| `terrain\tiles\tiles.lib` | OSW config | 909 lines; `TileBlockName` sections | `TileSize`: 64 ×8, 128 ×2; `AngleZ=25` ×36, `AngleZ=0` ×36 (face pairs) (**observed**) |
| `terrain\ref\reftile.lib` | OSW config | 14 lines | `TileScheme=tsDouble`, `TileType=ttExtended`, `TileXOffset=0.1`, `TileYOffset=0.2`; `TileSize=64/Rows=16/Cols=16/AlphaRows=8/AlphaCols=4/AlphaTileSize=64` are **commented** |
| `gen\tilesmooth_scripts.cfg` | OSW config | 1,864 lines; **118 active** `TileNames` groups, **282** `TileName`+`Prob` pairs, 86 distinct names, ΣProb=174.017 | first rule `sandsea1..4 = 1` each; second `sandsea5=0.7`, `sandsea6=0.3`; a `Prob=0` separator rule exists (**observed**, regex count + `smoothtiles.inc` parse cross-check) |
| `gen\tilesmooth.cfg` | OSW config | 130 lines | 3-tile compatibility lists, no probabilities; editor-side (`globalparams.cfg:10`) |
| `data\scripts\dmscript.global` | OSW config | `:78-81` grid/colours; `:170-173` scale; `:2026-2035` record struct | `TMapTerrainDataTile = {height:Float, tex:Integer, collision:Integer[4]}` on `[640][640]` |

---

## 5. Tile / height truth tables

### 5.1 Tile identifier → texture (observed, 0-based index from `terrain.presets`)

| id | TileBlock | DDS (via `tiles.mat`) | refkey / note |
|---:|---|---|---|
| 0 | `grass1` | `grass1.dds` 1024² DXT1 | normal |
| 1 | `grass2` | `grass2.dds` | normal |
| 4 | `grass5` | `grass5.dds` | normal |
| 10 | `ground1` | `ground1.dds` | normal; road choice p=0.5 |
| 13 | `grass_rock1` | `grass_rock1.dds` | normal |
| 14 | `grass_ground1` | `grass_ground1.dds` | normal |
| 16 | `grass_ground3` | `grass_ground3.dds` | normal |
| 17–25 | `rock1`…`rock9` | `rockN.dds` | normal |
| 26–27 | `sand1`, `sand2` | `sand1.dds`/`sand2.dds` **256²** | normal; 64/2/2 sub-atlas |
| 35–52 | `sandNf/s` | same `sandN.dds` | normal / normalside |
| 53–70 | `rockNvf/vs` | same `rockN.dds` | verticalfront / verticalside, `AngleZ/AngleX=25` |
| 73 | `test2` | `test2.dds` | normal; road p=0.25 |
| 78–80 | `test7/8/9` | `test*.dds` | normal |
| 93–98 | `sandsea1…6` | `sandseaN.dds` | normal; **shoreline** |
| 123 | `alpha0c` | `grass1.dds` | alias material, not a distinct texture |

Winter set uses the same indices with `*_winter` names (e.g. id 0 `grass1_winter →
winter10.dds`; id 17 `rock1_winter → winter16.dds`) — **observed**. Total mapping
space is 124 ids per season (plus port-only water sentinel 255, not a donor id).

### 5.2 Blend / splat rule (observed text, derived consequences)

1. Per-cell **one integer** `tex` (P12 `dmscript.global:2026-2035`) — no splat weights,
   no vertex-colour albedo (`vertexColor` multiplies **diffuse only**, P11 §3.2).
2. Base fill where index still 0: `h<0.1 → tile_lowground.bmp` else
   `tile_highground.bmp`, `tex = floor(fr*255) div 2` (`loadtextureterrainfrombitmap.inc:26-41`).
   The shipped lines are `;`-prefixed like all code in these `.inc` files; whether
   that denotes active code is **UNVERIFIED** (P14 Q9). The format facts are independent of it.
3. Aspect/shore/rock overrides (`texturemap.inc:433-611`) and road overrides
   (`:617-646`) — see §5.3.
4. **Weighted neighbour compatibility:** 118 authored rules × up to 16 tiles;
   `FindRandomTileIndex` = roulette over `SumProb` (`smoothtiles.inc:63-80`);
   `SmoothTileMap(0,0,W,H,3)` = **3 passes**, each horizontal then vertical
   (`:191-237`); distance-2 pairs replace the farther tile with a weighted pick,
   compatible neighbours unchanged (`:126-180`). Editor cfg says 6 passes —
   skirmish script says 3 (**observed**; both values live in different configs).
5. Draw-time modulation: RGB from `texUnit0` (tile DDS), alpha from `texUnit1`
   (`alpha.bmp` / `alphavert.bmp`), `BlendingMode=bmTransparency`, nearest mask
   sampling, `TextureScale=0.125` and eye-linear T=world-up for cliff faces
   (`reftile.mat:6,17,120-169`; `hf.pvl.smx3.frag:10-14`). Engine pass count and
   `gl_EyePlaneS/T[0]` values remain **UNVERIFIED** (P11 §6).

### 5.3 Near-water tiles differ (observed)

| Condition | Source | Tile |
|---|---|---|
| mask B>0 and `h < −0.25` (`cWaterHeight`) | `texturemap.inc:463-471` | water class; collision tag `gc_collisiontag_water`; water shader handles surface |
| mask B>0 and `−0.25 ≤ h < −0.1` (`cWaterShoreHeight`) | same | shore class; aspect-selected `sandsea*` |
| aspect sector R | `:479-480` | `sandsea1` |
| RB / B | `:482-486` | `sandsea6` / `sandsea1` |
| LB / L | `:488-492` | `sandsea5` / `sandsea6` |
| T / RT / LT | `:494-501` | `sandsea1` / `sandsea5` / `sandsea6` |
| winter | `:525-526` | suffix `_winter` |
| edge/collision cell, non-water | `:557-591` | `rock7/1/3/4` by aspect |
| `abs(h)>2.7` / `>2.4` / `<0.1` | `:594-601` | `rock8` / `rock4` / no tile |
| mask alpha (`broad`) road | `:622-636` | `ground1` p=0.5, `test2` p=0.25, `test3` p=0.25 |

The `//if (bWater)…` and `{…}` blocks at `:427-432` are commented; the **active**
water/shore test is `:463-471` (V1 re-read; braces at `:459-462` only comment out an
older copy). Shore transition weights are `sandsea1..4 = 1`, `sandsea5 = 0.7`,
`sandsea6 = 0.3` — so the **art-weighted shore blend is not uniform**.

### 5.4 Height scale / quantisation / world coordinates

| Quantity | Value | Source / label |
|---|---|---|
| height storage | **float32 per cell** (`TMapTerrainDataTile.height`) | `dmscript.global:2026-2030` — observed |
| grid max | 640×640 cells; skirmish 256/320/480/640 | `dmscript.global:78-79`; P5 E04/E05 — observed |
| source quantisation | RGBA bytes → floats `fr,fg,fb,fa ∈ [0,1]`; `ir=floor(fr*255)` etc. | `generatemap.inc:400-453` — observed; 8-bit source only |
| height formula | `h = −1.1*fb*(1+3.5*fr) + {2.964*fr \| 1.31733*fr \| −2.964*fr \| 0}` | `generatemap.inc:4-7,567-574` — observed |
| R relief codes | plateau 255/191, hill 96/112, ravine 48/88, none/smooth 64 | `generatemap.inc:21-27,454-472` — observed; smooth halves retain class |
| G/B codes | forest 255/64/128/192; water B=255 | `generatemap.inc:28-32,473-495` — observed |
| world origin | `x − W/2`, `y − H/2`; collision at half-cell offsets | `misc.script:66-72`; `texturemap.inc:133-137` — observed |
| **metres per cell** | **`gc_meters_to_tile = 2`**; `gc_pixels_to_meter=26.6666666`, `gc_pixels_to_tile=53.3333333`, `gc_tiles_to_pixels=0.01875` | `dmscript.global:170-173` — **observed** (new finding); `53.3333/26.6667 = 2` **derived** |
| port `TILE_M = 2.0` | donor-grounded, not merely port-tuned | `variant3d/scripts/world3d_terrain.gd:50`; §5.4 row above — **correction to P8/P14** |
| editor-only params | `HillPointsDensity=0.00008`, `MaxHillsHeight=0`, `MaxHeight=0.0001`, `SmoothLevel=0.008` | `gen\localparams.cfg:5-16` — observed; not the skirmish height scale |

Terrain-type count: **6** non-DLC mask types (`TerrainTypes`, `generator.cfg:2-28`)
and **9** DLC5 types (adds Coastal/Lakes/Rivers, `:29-66`); **4** relief classes
(none/plateau/hill/ravine) with smooth variants; **12** ground texture families
(desert, grass, grass_ground, grass_rock, grass_sand, ground, rock, sand, sandrock,
sandsea, test, winter) plus 36 face-variant blocks (**observed**, derived from
counts in §3.3/§4.6).

---

## 6. Corrections to prior docs

| # | Prior claim | This report | Verdict |
|---:|---|---|---|
| 1 | "No donor metres-per-cell constant; `TILE_M=2.0` port-only" (P8 §3/UNVERIFIED, P14 C6/Q1, P7 §5/UNVERIFIED) | `dmscript.global:171` literally has `gc_meters_to_tile = 2`, with px/m and px/tile at `:170/:172` | **CORRECTED** — port 2 m cell is donor-grounded |
| 2 | "No donor file contains a tile-index/splat array" (P14 C2) | `.map` `TerrainMapBegin` payload has 102,400 × 37-byte records with id-like bytes mapping to preset ids; semantics UNVERIFIED | **PARTIALLY CORRECTED** — a per-cell grid exists; no splat weights still true |
| 3 | "TGA masks are uncompressed 24-bit RGB" (P2 §2.1) | 4,467/4,510 TGAs are imagetype 10 RLE; all sampled masks RLE 24 bpp | **REFUTED** |
| 4 | "`heightmapwaves0.tga` is a height/normal candidate" (P4 §2, P6 D22) | Alpha is 255 for all 65,536 pixels; cannot encode the shader's `hmapTex.w` height | **CORRECTED** — binding still UNVERIFIED; image is normal-like RGB |
| 5 | "`alphanull.bmp` 512×257" (P6 D19) | Raw DIB12 header gives 512×256; all L=0 | **REFUTED** (P14 C24 agrees) |
| 6 | "terrain/heightmap/** and terrain/blocks/** are donor dirs" (task premise) | Absent in donor; port-side only | **CORRECTED** |
| 7 | "Only 10 smoothing rules / first rule only" (P5 E33, P14 C10/Q5) | 118 active groups, 282 `TileName`/`Prob` pairs, 86 distinct names (1,864-line cfg) | **EXTENDED** |
| 8 | "`.pattern` object records may contain terrain ids" (P3 §2.2) | `.pattern` is a stamp footprint; terrain ids live in presets/maps/cfgs, not in these 24-byte records | **UNVERIFIED** for record semantics; do not conflate |

---

## 7. Direct implications for our 3D terrain fix

All items are read-only recommendations; no code was changed here.

1. **Do not add terrain normal maps.** Whole-donor DDS census has no terrain normal
   or height texture; HeightField `tangentSpace=false` uses `gl_Normal` (P11/P14 C18).
   `heightmapwaves0.tga` has constant alpha and is not a usable height source.
2. **Keep the per-cell tile-index representation** (P7 A1–A3, P14 M1/P0-1). The
   donor record struct and the `.map` per-cell grid both confirm discrete ids; a
   1-RGB-per-cell splat is a different representation, not a tuning problem.
3. **Feed the full authored transition table.** Parse all 118 active
   `tilesmooth_scripts.cfg` groups (282 weighted entries) and run 3
   horizontal+vertical compatibility passes before building UV2; do not invent a
   luminance/dither patch field (P14 M10, P7 A4).
4. **2 m per cell is now donor-cited**, so the port's `TILE_M=2.0` and 64 px/cell
   grain target can be defended without a "PORT APPROXIMATION" label; eye-plane
   `gl_EyePlaneS/T[0]` values remain engine-bound and still need an approximation label.
5. **Face/shore art is discrete and oriented.** Use ids 93–98 `sandsea*` for water
   aspect sectors, 53–70 `rockNvf/vs` + `AngleZ/X=25` + `alphavert` projection for
   faces, `rock8/rock4` height overrides, and the 0.7/0.3 shore weights — all in
   P14's remaining gap list M3/M4/M5.
6. **Relief props are meshes, not LOD levels of the ground.** Use the four decoded
   `terrainmesh*.osm` (vertex counts/bboxes in §4.1), summer/winter/desert DXT5
   albedos, and stamp them via generator patterns (P5 E48–E54, P14 C25).
7. **`.map` importer opportunity (new).** The `TerrainMapBegin` header gives grid
   size directly (320/384) and the 37-byte record array gives 102,400/147,456
   per-cell ids. If a future importer uses it, label the +29…+32 field reading as
   **INFERRED** until a donor-side editor experiment proves which field is
   `GetTileIndex`; do not overwrite `game.tileblock` from it blindly.
8. **Alpha atlas conversion matters:** donor `alpha.bmp` 512×256 8-bit and
   `alphavert.bmp` 1024×512 24-bit are real authored masks; `alphanull.bmp` is an
   all-zero null material, not a blend source.
9. **`DTRN-02` / `DTRN-06` were not available** at write time; this report's binary
   facts should be handed to them as corrections (items 1, 3, 4 above) rather than
   duplicated.

---

## 8. Open questions (UNVERIFIED — do not guess)

1. Which field of the 37-byte `.map` record is authoritative `tex` (+29, +30, +31
   or +32), and what +33 (0…255) encodes? No donor reader is in plaintext.
2. What the `.map` fourth header int32 (64 or 25,920) means; what the float rasters
   preceding the 37-byte array store; and where `height:Float` is serialised.
3. Whether the `;`-prefixed `.inc` code lines are active in the shipping binary or
   are vestigial source (P14 Q9). Format facts here do not depend on it.
4. Actual `gl_EyePlaneS/T[0]`, `gl_TextureMatrix[0]`, `bmTransparency` pass count and
   `tsDouble`/`ttExtended` alpha sub-rect mapping — all engine-side (P11 §6, P14 Q2/Q4/Q8).
5. `hmapTex` binding in `water.dev.frag`: shader declares it; no plaintext binds a
   file. `heightmapwaves0.tga` is not a candidate given its constant alpha.
6. Runtime SM20 vs SM30 HeightField profile (3-tap vs 9-tap PCF).
7. World scale of stamped `terrainmesh*` props: local bbox ≈±13 units, but no
   donor prop scale field was found (§4.1).
8. The four `.map` files whose `TerrainMapBegin` lies beyond the first 32 MiB were
   not fully scanned; their grid headers are UNVERIFIED.
9. Whether the donor's winter/desert tile tables are ever regenerated by the
   random-map path, or only loaded from `terrain.presets` at scene load.

---

## 9. Evidence index

### 9.1 New hexdumps / decoded reads (this lane, read-only)

| Ref | `path:offset` or path | What it proves |
|---|---|---|
| N1 | `data\actors\env\terrainmesh1.osm:0x00` | IDP2 magic/version/17-int32 header (§4.1) |
| N2 | `data\terrain\tiles\textures\rock1.dds:0x00` | `DDS `, 1024×1024, 11 mips, `DXT1` @0x54 (§4.2) |
| N3 | `data\water\textures\heightmapwaves0.tga:0x00` | `00 00 0a` RLE, 256×256, 32 bpp, descriptor 0x08 (§4.3) |
| N4 | `data\gen\bitmap\ext\tile_lowground.bmp:0x00` | `BM`, DIB40, 320×320, 24 bpp, offbits 54 (§4.4) |
| N5 | `data\terrain\tiles\textures\alphanull.bmp:0x00` | DIB12 `0c 00 00 00`, 512×256, 8 bpp (§4.4) |
| N6 | `data\maps\missions\ausmis1.map:0x00` | `OSWMap13` length-prefixed token header (§4.5) |
| N7 | `data\maps\missions\ausmis1.map:0x012f63ee` | `TerrainMapBegin` + `<4i 320,320,4,64>` (§4.5) |
| N8 | `data\maps\missions\ausmis1.map:0x014f4a3d` | 37-byte record array, four 1.0f + id-like bytes (§4.5) |
| N9 | full-file scans/censuses | 1,469 DDS, 4,510 TGA, 38 `.map`, 4 OSM, 115 tile-texture files |
| N10 | decoded pixel statistics | tile_low/high R histograms, heightmapwaves0 alpha=255, alpha/alphavert histograms |
| N11 | donor text `path:line` | `dmscript.global:78-81,170-173,2026-2035`; `generatemap.inc:4-7,400-453,567-574`; `texturemap.inc:29-31,433-646`; `loadtextureterrainfrombitmap.inc:26-41`; `smoothtiles.inc:4-80,126-237`; `terrain.presets:2-6,134-138`; `tiles.mat:2-141`; `tilesmooth_scripts.cfg:1-1864`; `generator.cfg:2-66` |

### 9.2 Prior evidence ids (not regenerated)

- `ev_0bbb20c1…` / `ev_79424d3a…` — `.osm` layout and extension census (P12).
- `ev_4e4eeb88…`, `ev_fd99aba9…`, `ev_447c66d2…` — HeightField RTTI, texgen plumbing,
  absence of embedded `gl_EyePlaneS` in EXE (P11).
- `ev_0d087bb7…`, `ev_b526c882…` — px/m and px/tile constants (P13 `fnd_1`),
  independently re-read at `dmscript.global:170-173` here.
- Craft Anything session had **no open target**; no new evidence id was created.

---

## 10. Summary

The donor terrain stack is fully enumerable from read-only bytes and text. Ground
is **not** a splat: one integer `tex` per cell (`TMapTerrainDataTile`), resolved
through a 124-name preset → `tiles.mat` → 1024² DXT1 mapping, overridden by
height/aspect/shore/road rules, then relaxed by 118 authored weighted neighbour
compatibility rules and modulated by two authored alpha atlases. There are 6 (DLC5
9) terrain mask types, 4 relief classes and 12 ground families; cells are **2 m**
(`gc_meters_to_tile=2`, a new donor-grounded correction). Near-water tiles are the
aspect-selected `sandsea1/5/6` set inside the `[-0.25,−0.1)` band, with authored
0.7/0.3 transition weights, not a generic sand wash.

Binary formats decoded here: IDP2 `.osm` relief meshes (17-int32 header, size-closed,
bboxes), DDS (DXT1 ground / DXT5 relief, no terrain normal or height), RLE TGA
masks (including `heightmapwaves0.tga` with **constant alpha**, not a height field),
BMP tile-index source rasters and alpha atlases (12/10 quantised red values → preset
ids), and the `.map` `TerrainMapBegin` container with a verified 102,400-record
per-cell grid. The remaining unknowns are engine-side UV/blend bindings, the exact
`.map` field semantics and the active-vs-commented status of the `.inc` scripts —
all explicitly UNVERIFIED. No donor asset was copied; no code was changed.

*End of DEC-05. One report written; no donor file copied/executed; no Godot run;
no repo source, asset, config, test or git state changed.*
