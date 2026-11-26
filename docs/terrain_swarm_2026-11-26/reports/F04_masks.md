---
id: F04
swarm: TERRAIN-SWARM-2026-11-26
wave: F (donor data formats)
title: "Terrainmask inventory, TGA bit decode and channel semantics — donor READ-ONLY"
ticket: F04
owner_file: reports/F04_masks.md
status: LANDED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB
created: 2026-11-26
donor_root: "C:\\Games\\Cossacks 3 (read-only; no donor binary executed, copied or committed)"
labels: [OBSERVED, DERIVED, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "NO donor GPU A/B frame exists. NO donor-parity claim. All port statements are port-internal measurements or PORT APPROXIMATION."
tools: "Python 3.14.3 + Pillow 12.1.1 (site-packages); scripts written only to C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\f04_*.py"
---

# F04 — Terrainmask inventory, TGA bit decode and channel semantics

> Labels follow `docs/terrain_swarm_2026-11-26/CHARTER.md:32-44`: **OBSERVED** =
> literal donor byte / computed pixel statistic that I re-read this ticket;
> **DERIVED** = deterministic arithmetic on observed data; **UNVERIFIED** =
> not provable from the readable donor data (engine runtime, unit conversion,
> native smooth kernel); **PORT APPROXIMATION** = what the port does, explicitly
> not a donor claim. No Godot runner job, no source/asset/config/test/git edit,
> no donor execution, no donor file copied into the repo. All donor paths below
> are relative to `C:\Games\Cossacks 3\`.

## 0. Executive summary

1. **[OBSERVED] Inventory:** 4,466 terrainmask `.tga` files in three sibling
   trees — `data/gen/terrainmasks` 1,331 (8 shape folders, +4 `.removed`, +1
   `moddersread.txt`), `data/gen/terrainmasks.dlc5` 1,856 (11 shape folders,
   +4 `.removed`, +1 txt), `data/gen/terrainmasks.src` 1,279 (7 shape folders,
   +2 misc). The 2026-11-25 "almanac" counts for vanilla (continent 121,
   continents 187, islands 320, land 230, med 122 incl. 4 `.removed`, nowater
   42, nowater2 33, peninsulas 280) are **confirmed byte-for-byte by folder
   count** (`RC_TERRAIN.md:72`, `H01_donor_layers.md:72`).
2. **[OBSERVED] Format:** every `.tga` is an 18-byte-header, unindexed
   **RLE truecolour 24-bit** image (image type `0x0A`, no colour map, BGR byte
   order). Final masks are 320×320, descriptor `0x00` = **bottom-left origin**;
   `.src` masters are 256×256, descriptor `0x20` = **top-left origin**. There is
   **no alpha byte in any of the 4,466 files**, so the `fa` / `broad` road flag
   in `generatemap.inc` cannot be read from these files.
3. **[OBSERVED] Channel semantics — the headline correction:** across all
   1,331 final masks, **R and G take only two values: 0 (136,289,275 px) and 255
   (5,125 px)**, and the 255 pixels are exactly the pure-white start markers
   (R=G=B=255). **No mask contains a relief code (255/191/96/112/48/88/64) or
   a forest/stone code (255/127/64/128/192) anywhere except those white
   pixels.** B has all 256 values (0: 74,903,914 px; 255: 47,429,165 px) with a
   long 1..254 gauss ramp at coasts. The `.src` masters are even simpler: B is
   strictly binary {0,255}, R/G start-only. The documented R=relief /
   G=forest-stone decode exists in `generatemap.inc:454-485` but **the shipped
   data never exercises it**.
4. **[OBSERVED] Yes — B really encodes negative height.** `generatemap.inc:567`
   defines `hwater = -1.1 * fb * (1 + 3.5*fr)`; with `fr=0` on every shipped
   land pixel this reduces to `h = -1.1*(B/255)`, i.e. B=0→0 m, B=255→−1.1 m.
   Measured shoreline transect in med/22: B `0,2,13,49,114,193,251,255` →
   h `0, −0.0086, −0.0561, −0.2114, −0.4918, −0.8325, −1.0827, −1.1` m.
   Water/collision threshold `h<−0.25` corresponds to **B ≥ 58.1**, not B=255.
5. **[OBSERVED] Start markers:** exactly one pure-white pixel per player in
   5,125/5,125 vanilla masks; filename prefix matches the marker count in
   1,325/1,331 (six named exceptions with 1–2 px near-duplicate starts).
   Excluding those six, minimum start separation is **~63 px (p01) / 85 px
   (p05) on 320²**, i.e. ~0.20 / 0.27 of map width; minimum edge distance 6 px
   (p05 19 px); minimum distance to non-start water ~12.6 px (p05 17.5 px).
   The donor script de-duplicates only *identical* source coordinates
   (`generatemap.inc:417-435`); it does **not** enforce a spacing threshold.
6. **[OBSERVED / PORT APPROXIMATION] Port cross-check:** all **56** port PNGs
   under `variant3d/assets/terrain/masks` are **pixel-identical** to their
   donor `_gauss.tga` counterparts (320×320, 100% of 102,400 px per file), all
   56 `manifest.json` start lists match the donor white pixels to ±1 px, and
   `manifest.water` equals the fraction with `h<−0.25` (B≥58). The port decoder
   `mapgen.gd:212-215` reproduces the donor mask-only formula exactly at 320²,
   but the port exposes only 8 masks per shape (56 total = 4.2% of the 1,331
   vanilla masks), has no DLC5 shapes, and averages mask blocks at 240² instead
   of the donor's nearest-pixel sampling. **No parity claim.**

## 1. Evidence table

| # | Evidence (donor path:offset / path:line) | What it establishes | Label |
|---|---|---|---|
| E1 | `data/gen/terrainmasks/moddersread.txt:1-10` | `Xpl_*_gauss.tga` naming = number of starting points; `_gauss` = postprocessed from `.src`; output 320×320, source 256×256; gauss "prepare flat land/water texture ... smooth with noised water borders" | OBSERVED text |
| E2 | `data/game/var/generator.cfg:2-28` | 6 vanilla shapes; `hint=0.Land` has `//path=...\terrainmasks\land` **disabled** and live `path=...\terrainmasks\nowater2`; `:29-66` adds DLC5 coastal/lakes/rivers | OBSERVED text |
| E3 | `data/gen/terrainmasks/nowater2/4pl_mask_nowater_176_gauss.tga:0x00-0x11` | header bytes `00 00 0A 00 00 00 00 00 00 00 00 00 40 01 40 01 18 00`: idlen 0, cmtype 0, itype 10 (RLE truecolour), cmap len 0, origin (0,0), 320×320, depth 24, descriptor 0×00 (bottom-left, no alpha); payload begins `0x12`; SHA256 prefix `05fefad305f46e2f`, 3,908 bytes | OBSERVED bytes |
| E4 | `data/gen/terrainmasks/mediterranean/4pl_mask_mediterranean_22_gauss.tga:0x12` | first RLE packet `ff` = raw run of 128 BGR pixels; bytes `ff 00 00` → R=0,G=0,B=255. 27,969 bytes, SHA `159eb0a78b5132fe` | OBSERVED bytes |
| E5 | `data/gen/terrainmasks.src/mediterranean/4pl_mask_mediterranean_22.tga:0x00-0x11` | source header differs: cmap_depth byte `18`, descriptor `0x20` = top-left origin, 256×256, still itype 10/depth 24; SHA `7ac2e9c812671577` | OBSERVED bytes |
| E6 | `data/scripts/common.inc/generatemap.inc:4-32` | constants `cPlateauHeight=2.964`, `cHillHeight=2.964/2.25`, `cRavineHeight=−2.964`, `cWaterHeight=−1.1`; R colour codes 255/191/96/112/48/88/64, G codes 255/64/128/192/127, B water code 255 | OBSERVED text (`[*] = ;` intent) |
| E7 | `generatemap.inc:285-395` | TGA loaded via `CreateBitmapTGA` + `LoadBitmap(srcbitmap, srcbitmappath)`; white pixel (`fr=fg=fb=1`) recorded as player start then zeroed (`:325-341`/`:413-443`); class decode at `:342-370`/`:454-472`; `fa>0` → `.broad` road flag (`:348-351`) | OBSERVED text; runtime **UNVERIFIED** |
| E8 | `generatemap.inc:537-577` | nearest-pixel source sampling `bitmapx=floor(x/mapwidth*srcwidth)`; `hwater=cWaterHeight*(fb*(1+fr*3.5))`; `hterrain=cPlateauHeight*fr / cHillHeight*fr / cRavineHeight*fr / undefined(0)`; `SetHeightData(hwater+hterrain)` | OBSERVED text |
| E9 | `generatemap.inc:580-596`, `:598-643` | `SmoothTerrain(...,False,3)` on `bsmooth` cells; 3 global coastal passes with radius 2 and asymmetric smoothing | OBSERVED text; native kernels **UNVERIFIED** |
| E10 | `data/scripts/common.inc/texturemap.inc:29-31`, `:63-90` | `cWaterHeight=−0.25`, `cWaterShoreHeight=−0.1`; collision water tag when `gMapMask.b>0` and `h<−0.25`; shore tag `h<−0.1`; cliff tags at `|dh|>0.5/0.55` | OBSERVED text |
| E11 | full Python decode of all 1,331 / 1,856 / 1,279 TGAs | channel histograms, starts, spacing, water fractions reported in §3–§6 | OBSERVED (computed) |
| E12 | `variant3d/assets/terrain/masks/manifest.json`, `variant3d/assets/terrain/masks/**/*.png` | 7 types × 8 PNGs; 56/56 pixel-identical to donor `_gauss.tga`; starts ±1 px; `water` = B≥58 fraction | OBSERVED (port files) |
| E13 | `variant3d/scripts/mapgen.gd:25-30,63-94,145-238` | port decoder constants, exact R-code `relief()`, start handling, block averaging, own 1/2/3 coastal passes | OBSERVED (port code) / PORT APPROXIMATION |

## 2. Method (reproducible, read-only)

1. **Inventory:** `os.walk` over the three roots; for every file read the first
   18 bytes with `struct.unpack_from('<HH', h, 12)` for width/height and count
   extension, shape folder and `Npl` filename prefix. No donor file was opened
   for writing.
2. **Decode:** implemented a TGA reader in
   `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\f04_decode.py`:
   verify `itype in (2,10)`, `cmtype=0`, `depth∈{24,32}`; skip ID field; decode
   RLE packets (packet header bit 7 = RLE, count = `(b&0x7f)+1`); swap BGR→RGB;
   flip rows when descriptor bit `0x20` is clear (bottom-left origin). Cross-
   checked against Pillow 12.1.1 `Image.open(...).convert('RGB')`: **byte-for-
   byte identical**, including vertical orientation, on the sampled files.
3. **Statistics:** `collections.Counter` on `data[0::3]`, `[1::3]`, `[2::3]`;
   min/max/mean/σ/percentiles, distinct counts, top values. Class counts use
   the donor constants from E6. Height per decoded pixel uses E8 exactly;
   white start pixels are excluded from height (donor zeroes them at E7).
4. **Start markers:** exact `(255,255,255)` pixels, 8-connected components,
   centroid, pairwise Euclidean distances, distance to map edge, and nearest
   non-start pixel with B≥250 within a 48-px search window.
5. **Port cross-check:** compare PNG `tobytes()` against decoded donor TGA
   bytes; compare manifest `starts × (320,320)` to white pixels; compare
   `manifest.water` to `count(h<−0.25)/102400`.
6. **Discipline:** analysis scripts live only in the approved temp folder;
   the only repo file written is this report. No donor parity is asserted.

## 3. Inventory (all shapes, all player prefixes) [OBSERVED]

### 3.1 `data/gen/terrainmasks` — vanilla/final (1,331 TGA + 4 `.removed` + 1 txt)

| Shape folder | TGA | `Npl` prefix breakdown | Water B=255 fraction range |
|---|---:|---|---|
| continent | 121 | 4pl 100, 7pl 20, 8pl 1 | 0.352–0.764 |
| continents | 187 | 2pl 40, 3pl 29, 4pl 97, 7pl 20, 8pl 1 | 0.222–0.620 |
| islands | 320 | 2pl 100, 3pl 99, 4pl 100, 7pl 20, 8pl 1 | 0.333–0.764 |
| land | 230 | 4pl 209, 5pl 4, 6pl 12, 7pl 4, 8pl 1 | 0.000–0.240 |
| mediterranean | 118 (+4 `.removed`) | 4pl 97, 7pl 20, 8pl 1 | 0.027–0.326 |
| nowater | 42 | 4pl 21, 5pl 4, 6pl 12, 7pl 4, 8pl 1 | 0.000–0.000 |
| nowater2 | 33 | 4pl 12, 5pl 4, 6pl 12, 7pl 4, 8pl 1 | 0.000–0.000 |
| peninsulas | 280 | 2pl 75, 3pl 99, 4pl 85, 7pl 20, 8pl 1 | 0.167–0.509 |

The four `.removed` files are `mediterranean/4pl_mask_mediterranean_{75,78,95,100}_gauss.removed`.

### 3.2 `data/gen/terrainmasks.dlc5` — expansion (1,856 TGA + 4 `.removed` + 1 txt)

| Shape folder | TGA | `Npl` prefix breakdown |
|---|---:|---|
| coastal | 57 | 2pl 17, 3pl 8, 4pl 10, 6pl 13, 8pl 9 |
| continent | 167 | 2pl 32, 4pl 100, 7pl 20, 8pl 15 |
| continents | 196 | 2pl 40, 3pl 29, 4pl 97, 7pl 20 (+2 with 7 markers), 8pl 10 (−1 marker each) |
| islands | 330 | 2pl 100, 3pl 99, 4pl 100, 7pl 20, 8pl 11 |
| lakes | 151 | 2pl 31, 3pl 18, 4pl 27, 5pl 15, 6pl 19, 7pl 15, 8pl 26 |
| land | 230 | identical prefix set to vanilla `land` |
| mediterranean | 207 (+4 `.removed`) | 2pl 57, 4pl 98, 7pl 20, 8pl 32 |
| nowater | 42 | same as vanilla |
| nowater2 | 33 | same as vanilla |
| peninsulas | 286 | 2pl 75, 3pl 99, 4pl 85, 7pl 20, 8pl 7 |
| rivers | 157 | 2pl 32, 3pl 17, 4pl 25, 5pl 17, 6pl 17, 7pl 17, 8pl 32 |

**DERIVED:** 1,300 of the 1,331 common-shape filenames in `.dlc5` are
byte-identical (SHA-256) to vanilla; 31 differ; none is missing. So DLC5
mostly reuses the vanilla masks and adds coastal/lakes/rivers only.

### 3.3 `data/gen/terrainmasks.src` — 256×256 masters (1,279 TGA + 2 misc)

continent 120 (4pl 100, 7pl 20); continents 186; islands 319; land 221;
mediterranean 121; nowater 33; peninsulas 279. No `nowater2`, no 8pl, no DLC5
shapes. Consistent with `moddersread.txt:5-8` ("all folders should have at
 least one 7pl", source 256², gauss output 320²).

## 4. Exact image format [OBSERVED]

| Property | Final `_gauss` (both roots) | `.src` masters |
|---|---|---|
| Header length | 18 bytes, ID length 0 | 18 bytes, ID length 0 |
| Colour-map type / cmap depth | 0 / 0 | 0 / **24** (unused, cmtype=0) |
| Image type | **10 = RLE truecolour** | **10 = RLE truecolour** |
| Dimensions | 320×320 (`0x0140,0x0140`) | 256×256 (`0x0100,0x0100`) |
| Pixel depth | **24 bits**, BGR byte order | 24 bits, BGR |
| Descriptor | `0x00` = **bottom-left** origin, alpha bits 0 | `0x20` = **top-left** origin, alpha bits 0 |
| Pixel payload | RLE from byte 18; raw runs (`pk&0x80=0`) and repeated runs (`pk&0x80≠0`) | same |
| Alpha channel | **absent in all 4,466 files** | absent |

DERIVED consequences:
- a loader that ignores descriptor bit 0x20 will mirror every final mask
  vertically relative to every source mask. Pillow and my reader both honour
  it, and the port PNGs were exported in the visually-correct (top-down)
  orientation — confirmed by 100% pixel match in §7.
- `generatemap.inc:348-351` (`if (fa>0) then .broad := True`) cannot be driven
  by a byte in these files; the value of `fa` for a 24-bit bitmap is a loader
  default and is **UNVERIFIED**. This is a discrepancy with
  `2026-11-25/reports/H01_donor_layers.md:48` which labels a "same TGA A
  channel"; COORD should reconcile, but no road-mask claim is made here.

## 5. Channel statistics — corpus-wide [OBSERVED]

### 5.1 Final vanilla masks (1,331 files × 102,400 px = 136,294,400 px)

| Channel | Distinct values | Histogram highlights |
|---|---:|---|
| R | **2** | 0: 136,289,275 (99.99624%); 255: 5,125 (0.00376%) |
| G | **2** | 0: 136,289,275; 255: 5,125 |
| B | **256** | 0: 74,903,914 (54.96%); 255: 47,429,165 (34.80%); 1: 1,048,016; 2: 478,964; 254: 377,902; 3: 318,175; … all 1..254 populated |

The 5,125 R=G=B=255 pixels are **exactly** the one marker per mask. Therefore:
- **no relief class code** (255/191 plateau, 96/112 hill, 48/88 ravine, 64
  smooth) occurs anywhere except the white starts;
- **no forest/stone code** (255/127 forest, 64 gen-forest, 128 stone, 192
  forest+stone) occurs anywhere except the white starts;
- **B=255 means water** only on non-start pixels; four of the B=255 pixels per
  4pl mask are start markers, not water.

### 5.2 Source masters (1,279 × 65,536 px = 83,820,544 px)

R: 0 = 83,815,731, 255 = 4,813 (starts). G identical. **B: exactly two
values**, 0 = 49,254,648, 255 = 34,565,896. The gauss postprocess is what
turns B into a 256-value, 1..254 coastal ramp; R/G are not postprocessed into
any new codes.

### 5.3 DLC5 (1,856 × 102,400 px = 190,054,400 px)

R/G: 0 = 190,046,776; 255 = 7,616 (starts); plus **eight anomalous grey
pixels** in two files: `continents/8pl_mask_continents_8_gauss.tga` at
(68,38)=7, (69,38)=5, (67,39)=145, (68,39)=128 and
`continents/8pl_mask_continents_9_gauss.tga` at (280,67)=145, (280,68)=128,
(281,68)=7, (281,69)=5 — in each case R=G=B, i.e. grey, not a valid class
code. Both files have 7 markers although named 8pl. B: all 256 values, 0 =
115,932,222, 255 = 54,462,154.

## 6. Does B encode negative height? — empirical proof [OBSERVED + DERIVED]

**Formula** (`generatemap.inc:4-7,567-574`): with `fr=R/255`, `fb=B/255`,
`h = −1.1·fb·(1+3.5·fr) + hterrain(class, fr)`, where
`hterrain = +2.964·fr` (R=255/191), `+(2.964/2.25)·fr` (R=96/112),
`−2.964·fr` (R=48/88), else 0. Since every shipped non-start pixel has R=0,
`h = −1.1·(B/255)` exactly; range **[−1.1, 0] m**; `h<−0.25` ⇔ **B ≥ 58.1**;
`h<−0.1` (shore) ⇔ B ≥ 23.2.

**Measured transect**, med/22, decoded top-down rows (x, B, h):
- y=120: `(35,0,0.0000)`, `(36,1,−0.0043)`, `(37,7,−0.0302)`,
  `(38,31,−0.1337)`, `(39,97,−0.4184)`, `(40,194,−0.8369)`,
  `(41,246,−1.0612)`, `(42,254,−1.0957)`, `(43,255,−1.1000)`
- y=160: `(112,0,0)`, `(113,2,−0.0086)`, `(114,13,−0.0561)`,
  `(115,49,−0.2114)`, `(116,114,−0.4918)`, `(117,193,−0.8325)`,
  `(118,251,−1.0827)`, `(119,255,−1.1)`

So B is a **signed water-bed field**: monotone negative from shore to deep
water. It is *not* a binary water flag in the final masks; only in `.src`.
The maximum magnitude from the mask alone is 1.1 m, **not** ±2.964 — ±2.964
belongs to pattern relief stamps (`pattern.lib` height windows) and to the
port's clamp (`Z01_height_data.md:75-99`), a different stage.

**Cross-check with the 2026-11-25 height dumps:** `land/4pl_mask_land_176_gauss.tga`
has R=G=B=0 on all 102,396 non-start pixels (B=255 only on the four starts),
so its mask-only height field is *exactly* 0 — consistent with the near-flat
same-mask dump class in `Z01_height_data.md:118-126,201` (std 0.027–0.044 m,
98.6% zeros). The non-flat dumps' ±2.964 m values cannot come from these
masks; they come from the relief-stamp stage. [OBSERVED + DERIVED]

## 7. Three representative masks — channel statistics, starts, ASCII height

Legend for the ASCII maps (64 cols × 22 rows, each cell a 5×15-px block):
`~` majority B≥250 (deep water); `:` mean h in (−0.8,−0.1); `-` mean h in
(−1.6,−0.8); `=` h≤−1.6; `.` h≈0 land; `S` block contains a start marker.

### 7.1 LAND / NOWATER2 — `nowater2/4pl_mask_nowater_176_gauss.tga` (SHA `05fefad3…`, 3,908 B)

| Channel | min/max | mean | σ | distinct | top values |
|---|---:|---:|---:|---:|---|
| R | 0/255 | 0.0100 | 1.5937 | 2 | 0:102,396; 255:4 |
| G | 0/255 | 0.0100 | 1.5937 | 2 | 0:102,396; 255:4 |
| B | 0/255 | 0.0100 | 1.5937 | 2 | 0:102,396; 255:4 (all 4 are starts) |

Height: min=max=mean=σ=0 on 102,396 px; 0% negative, 0% below −0.25.
B255_height = n/a (the only B=255 pixels are white starts, excluded).
White starts (top-down pixel coords): `(41,41)`, `(278,41)`, `(63,256)`,
`(256,256)`; pairwise distances 193.00, 216.12 ×2, 237.00, 304.06 ×2 px;
min edge distance 41 px. No port PNG for this exact index (port ships 170/174/178).

```
................................................................
................................................................
........S..............................................S........
................................................................
................................................................
................................................................
................................................................
................................................................
................................................................
................................................................
................................................................
................................................................
................................................................
................................................................
................................................................
................................................................
................................................................
............S......................................S............
................................................................
................................................................
................................................................
................................................................
```

### 7.2 MED / `mediterranean/4pl_mask_mediterranean_22_gauss.tga` (SHA `159eb0a7…`, 27,969 B)

| Channel | min/max | mean | σ | distinct | top values |
|---|---:|---:|---:|---:|---|
| R | 0/255 | 0.0100 | 1.5937 | 2 | 0:102,396; 255:4 |
| G | 0/255 | 0.0100 | 1.5937 | 2 | 0:102,396; 255:4 |
| B | 0/255 | 52.1031 | 100.5233 | **256** | 0:77,527; 255:17,828; 1:533; 2:244; 254:183; 3:160; 253:159; 252:147; 5:131 |

B percentiles: p25=0, p50=0, p75=0, p95=255, p99=255. B=255 on 17,828 px
(17.41%); B≥58.1 on 21,899 px (21.386% incl. the four white starts; 21,895 of 102,396 non-start px = 21.383%) → water by `h<−0.25`.
Height: min −1.1, max 0, mean −0.2247, σ 0.4336; p25=p50=p75=p95=p99=0;
24.287% negative, 21.383% below −0.25. B255 cells: h=−1.1 exactly, σ=0.
White starts `(39,31)`, `(192,164)`, `(62,262)`, `(289,288)`; pair distances
157.43, 162.80, 202.73, 228.48, 232.14, 358.54 px; min edge distance 30 px.
Port PNG = donor pixels **100.000%** (102,400/102,400).

```
................................................................
................................................................
.......S........................................................
................................................................
................::::::::........................................
........:::::~~~~~~~~~~~~~:.....................................
.......:-~~~~~~~~:~~~~~~~~:....:::::::..........................
.......:~~~~~~~~::::.:-~~~::~~~~~~~~~:..........................
.......:-~~~~~~~~~~~~:~~~~~~~~~~~~~::...........................
.........:::~~~~~~~~~~~~~~~~~~~~~~~~~:..........................
.................::::::~~~~~~~~~~~~~::......:~~::::.............
.......................:~~~~~~~~~~~:..S..:~~~~~~~~~:............
................::.:::::-~~~~~~~~~~~~::::-~~~~~~~~~:............
................:::~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~:...........
....................:::......::~~~~~~~~~~~~~~::::~~~:...........
...............................:~~~~~~~~~~~~~~:::~~~~:..........
.............................::~~~~~~~~~~~~~~~~~~~~~~~:.........
...............................:~~~~~~~:...::::::::::::.........
............S...................................................
.........................................................S......
................................................................
................................................................
```

### 7.3 ISLANDS — `islands/2pl_mask_islands_0_gauss.tga` (SHA `540ef4fb…`, 65,987 B)

| Channel | min/max | mean | σ | distinct | top values |
|---|---:|---:|---:|---:|---|
| R | 0/255 | 0.0050 | 1.1269 | 2 | 0:102,398; 255:2 |
| G | 0/255 | 0.0050 | 1.1269 | 2 | 0:102,398; 255:2 |
| B | 0/255 | 157.3472 | 118.9518 | **256** | 255:55,035; 0:29,294; 1:1,247; 2:573; 254:557; 253:408; 252:399 |

Height: min −1.1, max 0, mean −0.6787, σ 0.5131; p25=p50=−1.1, p75=p95=p99=0;
71.392% negative, 64.216% below −0.25 (matches `manifest.json` water 0.6417).
White starts `(99,68)`, `(189,260)`, spacing 212.05 px, min edge distance 68 px.
Port PNG = donor pixels **100.000%**.

```
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~:::~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~:..:~~~~~~~~~~:::::~::.............:~~~~~~~~::::::~~~~~~~~~~~~~
~~~~~::::.::~~:..........::::....::~~~~~~~~-:......:::::~~~~~~~~
~~~~~-:..................:::~~~~::::::~~~~~~~~::..:~-::::::::~~~
~~~~~~~~~:.........S........::::..:~~~~~~~~~~~~~~:::~::......-~~
~~~~~~~~~~::..........:::::::...:::~~~~~~~~:::::~~~~~~~~::...-~~
~~~~~~~~:::...........:~~:::-:::~~~~~~~~~:......:-~~~~~~~~:...-~
~~~~~::::....................::-~~~~~~~~~~::~~~~~~~~~~~~~~~~~:~~
~~~~~~~~:::::.......:::::...:~~~~~~~-:::-~~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~-:...:~~~~~~~~~~~~~~~~~~~::....::~~~~~~~~~~~~~~~~~~~~~~
~~~~~~~~~~~~:~~~~~~~~~~~~~~~~~~:::~~~:.::~~~~~~~~~~~~~~~~~-::~~~
~~~~~:::~~~~~~~~~~~~~~::~~~~~~~~::~:.::~~~~~~~~~::::::~~~~~~~~~~
~~~~::.-~~~~~~~~::.:::~~~~~~~~~~:~~:-~~~~~:............::~~~~~~~
~~~~~~~~~~~~:::..::~~~~~~~~~~~~~~~~~~:~~~:...............:::~~~~
~~~-:~~~~:......:~~~~~~~~~~~~~~~~~~::......................::~~~
~~~~::~~~::::::~~~~~~~~~~~:~~~~::::.......................::~~~~
~~~~::~~~~~~~~~~~~~~~~~~:...................................:~~~
~~~~-:-~~~~~~~~~~~~~~~~::~~~::.......S..................::::~~~~
~~~~-.:::--~~~~~~~~~~~::~~~~~~:.........................::~~~~~~
~~~~:::.:~~~~~~~~~~~~:..:::::.............::........::...:~~~~~~
~~~~~~~~~~:~~~~~~~~~~~:::::.......:::::::~~~::::::::~~~~~:~~~~~~
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

**Bonus shape** `peninsulas/2pl_mask_peninsulas_0_gauss.tga` (SHA `b342397d…`):
B mean 122.905, σ 125.3798, B255=45,995 (44.92%), height mean −0.5302,
σ 0.5409, 49.263% below −0.25, starts `(149,81)`/`(268,275)` spaced 227.59 px;
port PNG 100% identical. Its ASCII shape (large landmass left, ocean right)
is included as a fourth map in the temp script output but omitted here for
brevity; the numbers above are fully reproducible.

## 8. Start-marker rules [OBSERVED + DERIVED]

**Detection rule** (`generatemap.inc:325-341` and `:413-443`): a pixel is a
start iff `fr=fg=fb=1` (normalised), i.e. byte `(255,255,255)`; after recording
it the sampler writes `fr=fg=fb=0`, so starts never contribute height, forest
or water. The sampler stores pixel coordinates (source bitmap space when
`srcwidth>mapwidth`, then rescaled at `:500-501`) and suppresses *identical*
coordinates only (`:417-435`); it does **not** test spacing.

| Corpus | Starts found | Filename-prefix exceptions | Start-pair spacing (px) | Edge distance (px) | Distance to non-start water (px) |
|---|---:|---|---|---|---|
| vanilla 1,331 | 5,125 | 6 (see below) | min 1; p01 63.25; p05 85.00; p25 141.69; p50 194.62; max 420.02 (8,480 pairs) | min 6; p01 13; p05 19; p25 32; p50 56 | min 12.65; p05 17.46; p25 25.71; p50 31.89 (3,657 of 5,125 starts had water within 48 px) |
| DLC5 1,856 | 7,616 | 8 | min 1; p01 67.19; p05 89.02; p25 137.18; p50 191.42 (14,705 pairs) | min 6; p05 20; p25 32; p50 52 | min 12.65; p05 18.11; p25 26.25; p50 33.0 |
| `.src` 1,279 | 4,813 | 6 | min 1; p01 49.04; p05 67.07; p25 113.86; p50 154.38 (7,664 pairs) | min 5; p05 15; p25 26; p50 46 | min 2.24; p05 12.81; p25 19.72; p50 25.02 |

**DERIVED (normalised to 320 px):** p01 spacing ≈0.198, p05 ≈0.266 of map
width; p05 edge distance ≈0.059 of width; p05 water distance ≈0.055. For
`.src` (256 px) p01 ≈0.192, p05 ≈0.262 — the spacing rule is preserved by the
256→320 resample.

**Six vanilla/DLC5 prefix exceptions** (all have one *extra* marker 1–2 px away
from an existing one, i.e. likely resample duplicates rather than real players):

| File | prefix | white pixels | closest pair (px) |
|---|---:|---:|---:|
| `land/4pl_mask_land_113_gauss.tga` | 4 | 5 | 1.0 (30,291)/(31,291) |
| `land/4pl_mask_land_114_gauss.tga` | 4 | 5 | 1.0 (35,280)/(35,281) |
| `mediterranean/4pl_mask_mediterranean_51_gauss.tga` | 4 | 5 | 1.0 (171,44)/(171,45) |
| `mediterranean/4pl_mask_mediterranean_62_gauss.tga` | 4 | 5 | 2.0 (262,262)/(262,264) |
| `islands/2pl_mask_islands_98_gauss.tga` | 2 | 3 | 2.0 (136,202)/(136,204) |
| `peninsulas/4pl_mask_peninsulas_5_gauss.tga` | 4 | 5 | 1–2 (same pattern as `.src` master) |

The same six exist in `.src`; DLC5 additionally has
`continents/8pl_mask_continents_8_gauss.tga` and `_9_gauss.tga` with 7 starts
and the grey pixels of §5.3. [OBSERVED]

**UNVERIFIED:** the often-quoted "≥0.7 cm to water/edges, ≥1.5–2 cm between
starts" rule (`RC_TERRAIN.md:74`, public EMOM change log) cannot be converted
to pixels because the px→cm scale of a 320² mask is not established by any
readable donor file. Only the pixel/normalised measurements above are claimed.

## 9. Port cross-check [OBSERVED + PORT APPROXIMATION]

| Check | Result |
|---|---|
| 56 port PNGs vs donor `_gauss.tga` | **56/56 pixel-identical**, 320×320, 102,400 px each |
| `manifest.json` start lists vs donor white pixels | **56/56 match** to ±1 px (norm × 320 rounded) |
| `manifest.json` `water` vs mask | equals `count(B/255 > 0.25/1.1)/102400` to <0.0005 (verified all 56; e.g. med/22 B≥58 = 0.2139 vs manifest 0.2136) |
| Mask coverage | 8 per shape × 7 shapes = 56, versus 118–320 final masks per vanilla shape; **no DLC5 coastal/lakes/rivers** |
| `mapgen.gd:212-215` | `hw = -1.1*(cb/255)*(1+(cr/255)*3.5)`, `height = hw + relief(cr)`, `forest = cg/255` — at 320² with R=0 this is exactly `−1.1·B/255`, forest 0; donor-faithful for the shipped data |
| `mapgen.gd:186-205` | at 240² it averages 1–2 mask pixels per cell and skips pure-white pixels → **PORT APPROXIMATION** of donor nearest-pixel sampling (`generatemap.inc:409-411,541-542`) |
| `mapgen.gd:218-235` | 1/2/3 coastal passes with port's own `near` (height<0.8 / neighbour<−0.1) and radius-1 diagonal average — **PORT APPROXIMATION** of donor `SmoothTerrain`+`_misc_SmoothTerrainCustom` (`generatemap.inc:580-643`); port exposes `relief_smooth` but no kernel |
| `mapgen.gd:96-117` | manifest starts → port uses only the **farthest pair** for 2 players; donor assigns all `Npl` starts in scan order |
| `generator.cfg:5` vs port `land` | donor's live Land shape is **nowater2** (zero water); port's `land` type uses 8 masks from `terrainmasks/land` with up to 24% B=255 |

**Reconciliation with prior reports:** `Z01_height_data.md:75-99` attributes
±2.964 m height values to relief R codes / stamps; this report shows the
mask files themselves can only produce 0…−1.1 m. Both can be true only if the
large amplitudes come from the pattern-stamp stage (D05/F01 scope), not from
mask R. `H01_donor_layers.md:45-47` is right that R/B enter `SetHeightData`
and G does not, but the *observed* files have no R/G class data at all — the
semantic table in H01 describes donor **intent**, not shipped pixels.

## 10. Exact conversion recipe (mask pixel → height / water / forest) [OBSERVED formula + DERIVED simplification]

For a decoded, visually-oriented (top-down) mask pixel `(R,G,B)` at map cell
`(x,y)` (all bytes 0..255):

```
1. Start marker:  if R==255 and G==255 and B==255:
                      start.append((x,y));  write h=0, water=false, forest=none;  STOP
                  # donor generatemap.inc:413-443 and :565-566 zero/skip it

2. fr=R/255 ; fg=G/255 ; fb=B/255

3. Relief class (generatemap.inc:454-472):
      ir in {255,191} -> plateau,  bsmooth = (ir==191)
      ir in {96,112}  -> hill,     bsmooth = (ir==112)
      ir in {48,88}   -> ravine,   bsmooth = (ir==88)
      ir == 64        -> none,     bsmooth = true
      else            -> none,     bsmooth = false

4. Forest class (generatemap.inc:473-485):
      ig==255 or ig==127 with relief class -> forest
      ig==64  -> generated forest
      ig==128 -> stone
      ig==192 -> forest+stone
      else    -> none
   # SHIPPED DATA: G is 0 on every non-start pixel -> forest class always none.

5. Water class (generatemap.inc:486-490): ib==255 -> water, else none.
   # note: this is a per-cell class; the continuous water BED is fb.

6. Height (generatemap.inc:567-574):
      hwater   = -1.1 * fb * (1 + 3.5*fr)
      hterrain =  2.964*fr        if plateau
               = (2.964/2.25)*fr  if hill
               = -2.964*fr        if ravine
               = 0                otherwise
      h        = hwater + hterrain
   # SHIPPED DATA (fr=0 on all non-start px): h = -1.1*(B/255), 0..-1.1 m.

7. Water / shore / collision (texturemap.inc:29-31,68-90):
      water cell      = (mask water class) and (h < -0.25)   # B>=58.1 when fr=0
      shore cell      = (mask water class) and (h < -0.10)   # B>=23.2 when fr=0
      cliff/collision = |h - h_neighbour| > 0.5 (cardinal) or > 0.55 (diagonal)

8. Post-process (UNVERIFIED kernels): SmoothTerrain(...,False,3) on bsmooth
   cells; three global coastal passes (generatemap.inc:580-643).
```

**Port equivalent** (`mapgen.gd`) is steps 1–7 with block averaging at non-320
resolution and a substitute coastal smoother; step 3's codes are decoded but
never present in data, step 4 is `forest = G/255` (a continuous field, not the
donor's 5-class enum) — both are **PORT APPROXIMATION** where they diverge.

## 11. Implications for the port

1. **Do not expect hills from mask R.** All shipped masks have R=0 off starts;
   any hills/mountains/plateaus must come from the pattern relief grids / stamps
   (D05, F01 scope). Port `relief()` being "donor-exact" is harmless but inert
   on current assets — this is a concrete, donor-grounded explanation of the
   "flat relief" symptom in the 2026-11-25 wave.
2. **Do not expect forests or mines from mask G.** G=0 off starts; forest and
   stone placement is a pattern/placement stage (`texturemap.inc:180-413`,
   D07/F08 scope). Port `forest[i] = G/255` is therefore a zero field for every
   shipped mask.
3. **Water shape is entirely B**, with a smooth 8-bit coastal ramp. A port
   that thresholds B=255 for water would lose ~4–20 percentage points of water
   area versus the donor's `h<−0.25` rule (med/22: 17.41% vs 21.39%; islands/0:
   53.75% vs 64.22%). Use the formula, not a binary threshold.
4. **Start markers are one pixel each**; use exact `(255,255,255)` detection,
   skip those pixels in height, and either (a) keep all `Npl` starts as the
   donor does, or (b) document the port's 2-player farthest-pair reduction as a
   **PORT APPROXIMATION**. Add a guard for the six near-duplicate masks (merged
   starts 1–2 px apart) rather than placing two armies on the same tile.
5. **Orientation matters:** final masks are bottom-left TGA (`desc=0x00`),
   masters top-left (`desc=0x20`). All 56 port PNGs were exported in the
   visually-correct order; any new converter must honour descriptor bit 0x20.
6. **Asset scope:** port covers 56/1,331 vanilla masks and 0/1,856 DLC5
   masks. Vanilla Land is `nowater2`, not `land` (`generator.cfg:5`); the
   port's `land` category should be reconciled with COORD/F03.
7. **No alpha:** road `broad` flags cannot be derived from these files;
   leave road placement out or label it UNVERIFIED, not donor-faithful.

## 12. Risks

- **Text-vs-runtime risk:** all `.inc` lines are `[*] = ;` intent text. Pixel
  measurements are hard OBSERVED; the *execution* of the quoted formula is
  UNVERIFIED without a native/GPU probe (D03/D05 scope).
- **Unit risk:** height is in donor "metres" only by naming of the constants;
  no px→world-metre conversion was recovered. ASCII maps and distances are in
  mask pixels / fractions, never claimed in cm or m of world space.
- **Sampling risk:** the port's 240² block average smooths the narrow 1–2 px
  gauss ramp differently from the donor's nearest-pixel sample; shore width
  may differ even with identical PNGs.
- **Anomaly risk:** 6 near-duplicate start masks + 2 grey-pixel DLC5 masks are
  genuine source-data defects; a converter that assumes `Npl == marker count`
  or `R,G,B ∈ {0,255}` will mis-handle them.
- **Cross-report risk:** H01/Z01 statements about R relief codes are intent-
  level; this report's pixel-level result must not be read as "the donor
  generator has no relief stage" — it has one, in patterns.

## 13. UNVERIFIED register (do not promote)

1. Runtime activity of `generatemap.inc` / `texturemap.inc` `[*] = ;` text in
   the shipped `cossacks.exe`; no donor binary executed (charter rule).
2. `fa` value for a 24-bit TGA in the donor bitmap loader → road `broad` flag.
3. Native kernels of `SmoothTerrain` and `_misc_SmoothTerrainCustom`; the
   port's coastal smoother is a PORT APPROXIMATION.
4. Pixel→cm scale for the published start-spacing rule; only px/fractions
   were measured.
5. Whether DLC5's 31 differing common-shape TGAs are intentional edits or
   re-exports; content differences were not enumerated file-by-file.
6. Whether the four `.removed` masks are ever loaded by any config; their
   extension suggests exclusion but no loader probe was performed.
7. Whether pattern relief stamps are added before or after the coastal
   smoothing passes in the shipping build (affects ±2.964 interpretation).
8. Any donor GPU A/B frame — **none exists**; no parity claim of any kind.

## 14. Open questions (for COORD / other workers)

- **D03/D05:** confirm the exact stage order (mask B bed → pattern stamps →
  `SmoothTerrain` → coastal passes) and whether the disabled `//*(255/cRColor…)` multipliers were ever live.
- **F03:** does any `generator.cfg`/`globalparams` switch point at `.src`
  masks instead of `_gauss`, and does `bRandomMap` select the postprocess?
- **F10:** enumerate the 31 changed DLC5 masks and the 3 DLC5-only shapes'
  channel statistics (coastal/lakes/rivers) with the same script.
- **A01/A02:** decide whether to carry all `Npl` starts (donor-faithful) or the
  port's farthest pair; decide whether to ingest more than 8 masks per shape.
- **A05:** add a QA gate that checks any newly converted mask PNG is
  byte-identical to its donor TGA pixels and that R/G stay start-only — this
  would catch orientation flips and invented relief data early.

## 15. Five-line summary

- **OBSERVED:** 4,466 TGA terrain masks in 3 trees; every one is RLE truecolour 24-bit, final 320² bottom-left, `.src` 256² top-left, no alpha.
- **OBSERVED:** R/G are 0 on every non-start pixel of all 1,331 vanilla masks (5,125 pure-white starts); B is the only continuous channel (all 256 values).
- **OBSERVED:** B genuinely encodes negative height (`h=−1.1·B/255`, B=0→0 m, B=255→−1.1 m, water at B≥58); no mask alone can produce ±2.964 m.
- **OBSERVED:** start markers are single white pixels; normalised min spacing ≈0.20–0.27 of map width, six masks contain 1–2 px duplicate starts.
- **OBSERVED / PORT APPROXIMATION:** all 56 port PNGs are pixel-identical to donor masks and manifest starts/water agree; port covers 56/1,331 vanilla masks and no DLC5; **no donor parity claim**.

*End of F04. Exactly one report written. No donor binary executed or copied; no repo file other than this report modified; no Godot runner job; no donor visual-parity claim.*
