---
id: V7-85
task: TERRAIN2-06 / A1 — donor-indexed tile atlas + runtime alpha masks
title: "A1 delivered: 124-cell donor-indexed 1024² tile atlas and two converted donor masks"
owner: V7-85 (TERRAIN2-06 task A1)
scope: "ASSET + TOOL ONLY. One NEW tool, generated atlas/mask assets under atlas/, one report. No .gd, no existing splat tool, no app/, config, tests or git operations."
date: 2026-11-24
status: DELIVERED__MEASURED__NO_VISUAL_PARITY_CLAIM
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor: "C:\\Games\\Cossacks 3 (READ-ONLY private use; latin-1 text, BMP headers and decoded BMP pixels only; nothing copied verbatim or executed)"
governing_rule: "docs/coord_swarm_2026-11-24/TERRAIN2_CHARTER.md:6-15; docs/coord_swarm_2026-11-24/V73_ATOMIC_CONTRACT.md:3-4,6-16,26-37"
tool: "variant3d/tools/build_tile_index_atlas.py"
outputs:
  - "variant3d/assets/terrain/atlas/tile_index_atlas.png"
  - "variant3d/assets/terrain/atlas/tile_index_atlas.manifest.json"
  - "variant3d/assets/terrain/atlas/alpha.png"
  - "variant3d/assets/terrain/atlas/alphavert.png"
labels: [DONOR_INDEX, DONOR_ART, APPROX_ATLAS_PACKING, APPROX_SAND_UPSCALE, APPROX_ALPHA_INTENSITY_FORMULA, UNVERIFIED_EMPTY_CELLS, UNVERIFIED_ALPHA_SUBRECT_MAPPING]
---

# V7-85 — A1: donor-indexed tile atlas and runtime alpha masks

## 0. Scope and labels

- Read first, as instructed: `TERRAIN2_06_tileindex_architecture.md`, `TERRAIN2_01_donor_pipeline.md`.
- **OBS** = literal donor text / byte header; **SHIPPED** = file already in `variant3d/assets` or `app/assets`; **MEASURED** = produced by this tool or an independent read-only probe; **APPROX** = port-side substitution not claimed as donor; **UNVERIFIED** = not provable from readable data.
- No visual parity is claimed. No GPU A/B was run. No donor file was written or executed. No repo file outside the three owned paths was created or changed. No git command was run.
- Path deviation from the design sketch: A1 in `TERRAIN2-06:103` sketched `variant3d/assets/terrain/generated/`; the dispatch instruction owns **`variant3d/assets/terrain/atlas/`** instead. This report follows the dispatch instruction.

## 1. Donor evidence (read-only `path:line`)

| # | Evidence | Observation | Label |
|---:|---|---|---|
| E1 | `data\terrain\tiles\terrain.presets:2-6` | `SetName = Summer`; `DefaultIndex = 0`; first `TileBlock = grass1` | OBS |
| E2 | `variant3d/assets/terrain/structs/presets_summer.json:2-125` | 124 names; array element *i* is donor preset index *i*; `:2` = `grass1`, `:55-56` = `rock1vf`/`rock1vs`, `:95-100` = `sandsea1..6`, `:125` = `alpha0c`. Mirror of E1. | SHIPPED |
| E3 | `data\terrain\tiles\tiles.mat:142-148` | `rock1vf` and `rock1vs` both bind `rock1.dds` (refkeys `verticalfront` / `verticalside`) | OBS |
| E4 | `data\terrain\tiles\tiles.mat:206-220` | `rock9vf`/`rock9vs` → `rock9.dds`; `sand1f`/`sand1s` → `sand1.dds` | OBS |
| E5 | `data\terrain\tiles\tiles.lib:53-63` (reported `TERRAIN2-06:43`, E15) | `sand1/sand2 TileSize=64 Rows=2 Cols=2`; shipped PNGs are 256² while all other blocks are 1024² | OBS + SHIPPED |
| E6 | `data\terrain\ref\reftilealpha.mat:30-37` | `image = .\data\terrain\tiles\textures\alpha.bmp`; `imagealpha = tiaAlphaFromIntensity`; `magfilter = maNearest`; `minfilter = miNearest`; `textureformat = tfAlpha`; `texturewrap = twBoth` | OBS |
| E7 | `data\terrain\ref\reftilealpha.mat:139-146` | same settings for `.\data\terrain\tiles\textures\alphavert.bmp` | OBS |
| E8 | `data\terrain\ref\reftile.mat:120-143`, `:146-169` | face refkeys bind `alphavert`, `TextureScale = 0.125`, `mappingmode = tmmEyeLinear`; verticalfront S←X / T←Z, verticalside S←Y / T←Z | OBS |
| E9 | `data\terrain\ref\reftile.lib:3-12` | `TileScheme=tsDouble`, `TileType=ttExtended`; sub-atlas values are commented out → atlas grid/cell packing is engine-side | OBS + UNVERIFIED |
| E10 | `app\tools\copy_assets.py:220-223` | notes `terrain/structs/*.json` generated from donor libs and `dmask/d_*.png` from `alpha.bmp` + `alphavert.bmp`; no shipped standalone mask PNG and no cell↔tile loader | SHIPPED + UNVERIFIED |
| E11 | `app\shots\g32_dump.json:1` (key `tileblock`) | base64 uint8[320×320] = 102,400 bytes; 31 distinct ids, range 0..85; all < 124 | SHIPPED + MEASURED |

Bit-exact donor atlas packing is **UNVERIFIED** (E9). The mapping used here is index = E2 array position; face base-art reuse is E3/E4; both are donor data, not invented.

## 2. Outputs (all under `variant3d/assets/terrain/atlas/`)

| File | Bytes | sha256 | Format |
|---|---:|---|---|
| `tile_index_atlas.png` | 179,912,941 | `a1f123a1072e07eb28f416a9d8541aae5ffd23891a1836904b3cb05eb84dcfbd` | PNG RGBA 16,384×8,192, 16×8 grid of 1,024² cells |
| `tile_index_atlas.manifest.json` | 60,677 | — | UTF-8 JSON: full 124-row layout, source sha256 list, masks, shipped-id check |
| `alpha.png` | 55,242 | `dfaf78d0c285920cd2009f74476a8d4647f3666efb7c6dcf0bfd1b44487b8ef7` | PNG L 512×256 |
| `alphavert.png` | 167,954 | `c916ea98ddb7f8ccc9a4898f324540335d4d74ee5250f4774b9769c762afd245` | PNG L 1,024×512 |

The tool writes **exactly these four files** and nothing else (`only_4_output_files` check). No `splat_albedo.png`, sprite sheet, 2D bake, `.gd`, config or test output is produced. The two pre-existing `splat_albedo.png` files in `app/assets/...` and `variant3d/assets/...` have mtimes 2026-11-24T14:53:39+01:00, before this run, and were not touched.

## 3. Atlas layout — index → donor name → PNG

Index = `presets_summer.json` array element = (line − 2). Cell `(col,row)` = `(i % 16, i // 16)`; cell origin = `(col·1024, row·1024)`. `FACE_BASE_REUSE` means donor `tiles.mat` binds that face name to the base block's DDS (E3/E4); no new art is invented. `EMPTY` means no shipped PNG exists for that preset name; the cell is transparent black.

| idx | donor name (JSON line) | source PNG | kind | cell (col,row) | upscaled |
|---:|---|---|---|---|---|
| 0 | grass1 (:2) | grass1.png | DIRECT | (0,0) | no |
| 1 | grass2 (:3) | grass2.png | DIRECT | (1,0) | no |
| 2 | grass3 (:4) | grass3.png | DIRECT | (2,0) | no |
| 3 | grass4 (:5) | grass4.png | DIRECT | (3,0) | no |
| 4 | grass5 (:6) | grass5.png | DIRECT | (4,0) | no |
| 5 | grass6 (:7) | grass6.png | DIRECT | (5,0) | no |
| 6 | grass7 (:8) | grass7.png | DIRECT | (6,0) | no |
| 7 | grass8 (:9) | grass8.png | DIRECT | (7,0) | no |
| 8 | grass9 (:10) | grass9.png | DIRECT | (8,0) | no |
| 9 | grass10 (:11) | grass10.png | DIRECT | (9,0) | no |
| 10 | ground1 (:12) | ground1.png | DIRECT | (10,0) | no |
| 11 | grass_sand1 (:13) | grass_sand1.png | DIRECT | (11,0) | no |
| 12 | grass_sand2 (:14) | grass_sand2.png | DIRECT | (12,0) | no |
| 13 | grass_rock1 (:15) | grass_rock1.png | DIRECT | (13,0) | no |
| 14 | grass_ground1 (:16) | grass_ground1.png | DIRECT | (14,0) | no |
| 15 | grass_ground2 (:17) | grass_ground2.png | DIRECT | (15,0) | no |
| 16 | grass_ground3 (:18) | grass_ground3.png | DIRECT | (0,1) | no |
| 17 | rock1 (:19) | rock1.png | DIRECT | (1,1) | no |
| 18 | rock2 (:20) | rock2.png | DIRECT | (2,1) | no |
| 19 | rock3 (:21) | rock3.png | DIRECT | (3,1) | no |
| 20 | rock4 (:22) | rock4.png | DIRECT | (4,1) | no |
| 21 | rock5 (:23) | rock5.png | DIRECT | (5,1) | no |
| 22 | rock6 (:24) | rock6.png | DIRECT | (6,1) | no |
| 23 | rock7 (:25) | rock7.png | DIRECT | (7,1) | no |
| 24 | rock8 (:26) | rock8.png | DIRECT | (8,1) | no |
| 25 | rock9 (:27) | rock9.png | DIRECT | (9,1) | no |
| 26 | sand1 (:28) | sand1.png | DIRECT | (10,1) | **YES** |
| 27 | sand2 (:29) | sand2.png | DIRECT | (11,1) | **YES** |
| 28 | sand3 (:30) | sand3.png | DIRECT | (12,1) | no |
| 29 | sand4 (:31) | sand4.png | DIRECT | (13,1) | no |
| 30 | sand5 (:32) | sand5.png | DIRECT | (14,1) | no |
| 31 | sand6 (:33) | sand6.png | DIRECT | (15,1) | no |
| 32 | sand7 (:34) | sand7.png | DIRECT | (0,2) | no |
| 33 | sand8 (:35) | sand8.png | DIRECT | (1,2) | no |
| 34 | sand9 (:36) | sand9.png | DIRECT | (2,2) | no |
| 35 | sand1f (:37) | sand1.png | FACE_BASE_REUSE | (3,2) | **YES** |
| 36 | sand1s (:38) | sand1.png | FACE_BASE_REUSE | (4,2) | **YES** |
| 37 | sand2f (:39) | sand2.png | FACE_BASE_REUSE | (5,2) | **YES** |
| 38 | sand2s (:40) | sand2.png | FACE_BASE_REUSE | (6,2) | **YES** |
| 39 | sand3f (:41) | sand3.png | FACE_BASE_REUSE | (7,2) | no |
| 40 | sand3s (:42) | sand3.png | FACE_BASE_REUSE | (8,2) | no |
| 41 | sand4f (:43) | sand4.png | FACE_BASE_REUSE | (9,2) | no |
| 42 | sand4s (:44) | sand4.png | FACE_BASE_REUSE | (10,2) | no |
| 43 | sand5f (:45) | sand5.png | FACE_BASE_REUSE | (11,2) | no |
| 44 | sand5s (:46) | sand5.png | FACE_BASE_REUSE | (12,2) | no |
| 45 | sand6f (:47) | sand6.png | FACE_BASE_REUSE | (13,2) | no |
| 46 | sand6s (:48) | sand6.png | FACE_BASE_REUSE | (14,2) | no |
| 47 | sand7f (:49) | sand7.png | FACE_BASE_REUSE | (15,2) | no |
| 48 | sand7s (:50) | sand7.png | FACE_BASE_REUSE | (0,3) | no |
| 49 | sand8f (:51) | sand8.png | FACE_BASE_REUSE | (1,3) | no |
| 50 | sand8s (:52) | sand8.png | FACE_BASE_REUSE | (2,3) | no |
| 51 | sand9f (:53) | sand9.png | FACE_BASE_REUSE | (3,3) | no |
| 52 | sand9s (:54) | sand9.png | FACE_BASE_REUSE | (4,3) | no |
| 53 | rock1vf (:55) | rock1.png | FACE_BASE_REUSE | (5,3) | no |
| 54 | rock1vs (:56) | rock1.png | FACE_BASE_REUSE | (6,3) | no |
| 55 | rock2vf (:57) | rock2.png | FACE_BASE_REUSE | (7,3) | no |
| 56 | rock2vs (:58) | rock2.png | FACE_BASE_REUSE | (8,3) | no |
| 57 | rock3vf (:59) | rock3.png | FACE_BASE_REUSE | (9,3) | no |
| 58 | rock3vs (:60) | rock3.png | FACE_BASE_REUSE | (10,3) | no |
| 59 | rock4vf (:61) | rock4.png | FACE_BASE_REUSE | (11,3) | no |
| 60 | rock4vs (:62) | rock4.png | FACE_BASE_REUSE | (12,3) | no |
| 61 | rock5vf (:63) | rock5.png | FACE_BASE_REUSE | (13,3) | no |
| 62 | rock5vs (:64) | rock5.png | FACE_BASE_REUSE | (14,3) | no |
| 63 | rock6vf (:65) | rock6.png | FACE_BASE_REUSE | (15,3) | no |
| 64 | rock6vs (:66) | rock6.png | FACE_BASE_REUSE | (0,4) | no |
| 65 | rock7vf (:67) | rock7.png | FACE_BASE_REUSE | (1,4) | no |
| 66 | rock7vs (:68) | rock7.png | FACE_BASE_REUSE | (2,4) | no |
| 67 | rock8vf (:69) | rock8.png | FACE_BASE_REUSE | (3,4) | no |
| 68 | rock8vs (:70) | rock8.png | FACE_BASE_REUSE | (4,4) | no |
| 69 | rock9vf (:71) | rock9.png | FACE_BASE_REUSE | (5,4) | no |
| 70 | rock9vs (:72) | rock9.png | FACE_BASE_REUSE | (6,4) | no |
| 71 | test0 (:73) | test0.png | DIRECT | (7,4) | no |
| 72 | test1 (:74) | test1.png | DIRECT | (8,4) | no |
| 73 | test2 (:75) | test2.png | DIRECT | (9,4) | no |
| 74 | test3 (:76) | test3.png | DIRECT | (10,4) | no |
| 75 | test4 (:77) | test4.png | DIRECT | (11,4) | no |
| 76 | test5 (:78) | test5.png | DIRECT | (12,4) | no |
| 77 | test6 (:79) | test6.png | DIRECT | (13,4) | no |
| 78 | test7 (:80) | test7.png | DIRECT | (14,4) | no |
| 79 | test8 (:81) | test8.png | DIRECT | (15,4) | no |
| 80 | test9 (:82) | test9.png | DIRECT | (0,5) | no |
| 81 | test10 (:83) | test10.png | DIRECT | (1,5) | no |
| 82 | test11 (:84) | test11.png | DIRECT | (2,5) | no |
| 83 | test12 (:85) | test12.png | DIRECT | (3,5) | no |
| 84 | test13 (:86) | test13.png | DIRECT | (4,5) | no |
| 85 | test14 (:87) | test14.png | DIRECT | (5,5) | no |
| 86 | alpha0a (:88) | — EMPTY — | EMPTY | (6,5) | no |
| 87 | sandrock1 (:89) | sandrock1.png | DIRECT | (7,5) | no |
| 88 | sandrock2 (:90) | sandrock2.png | DIRECT | (8,5) | no |
| 89 | sandrock3 (:91) | sandrock3.png | DIRECT | (9,5) | no |
| 90 | sandrock4 (:92) | sandrock4.png | DIRECT | (10,5) | no |
| 91 | sandrock5 (:93) | sandrock5.png | DIRECT | (11,5) | no |
| 92 | sandrock6 (:94) | sandrock6.png | DIRECT | (12,5) | no |
| 93 | sandsea1 (:95) | sandsea1.png | DIRECT | (13,5) | no |
| 94 | sandsea2 (:96) | sandsea2.png | DIRECT | (14,5) | no |
| 95 | sandsea3 (:97) | sandsea3.png | DIRECT | (15,5) | no |
| 96 | sandsea4 (:98) | sandsea4.png | DIRECT | (0,6) | no |
| 97 | sandsea5 (:99) | sandsea5.png | DIRECT | (1,6) | no |
| 98 | sandsea6 (:100) | sandsea6.png | DIRECT | (2,6) | no |
| 99 | test15 (:101) | test15.png | DIRECT | (3,6) | no |
| 100 | test16 (:102) | test16.png | DIRECT | (4,6) | no |
| 101 | test17 (:103) | test17.png | DIRECT | (5,6) | no |
| 102 | test18 (:104) | test18.png | DIRECT | (6,6) | no |
| 103 | test19 (:105) | test19.png | DIRECT | (7,6) | no |
| 104 | test20 (:106) | test20.png | DIRECT | (8,6) | no |
| 105 | test21 (:107) | test21.png | DIRECT | (9,6) | no |
| 106 | test22 (:108) | test22.png | DIRECT | (10,6) | no |
| 107 | test23 (:109) | test23.png | DIRECT | (11,6) | no |
| 108 | test24 (:110) | test24.png | DIRECT | (12,6) | no |
| 109 | test25 (:111) | test25.png | DIRECT | (13,6) | no |
| 110 | alpha0b (:112) | — EMPTY — | EMPTY | (14,6) | no |
| 111 | desert1 (:113) | desert1.png | DIRECT | (15,6) | no |
| 112 | desert2 (:114) | desert2.png | DIRECT | (0,7) | no |
| 113 | desert3 (:115) | desert3.png | DIRECT | (1,7) | no |
| 114 | desert4 (:116) | desert4.png | DIRECT | (2,7) | no |
| 115 | desert5 (:117) | desert5.png | DIRECT | (3,7) | no |
| 116 | desert6 (:118) | desert6.png | DIRECT | (4,7) | no |
| 117 | desert7 (:119) | desert7.png | DIRECT | (5,7) | no |
| 118 | desert8 (:120) | desert8.png | DIRECT | (6,7) | no |
| 119 | desert9 (:121) | desert9.png | DIRECT | (7,7) | no |
| 120 | desert10 (:122) | desert10.png | DIRECT | (8,7) | no |
| 121 | desert11 (:123) | desert11.png | DIRECT | (9,7) | no |
| 122 | desert12 (:124) | desert12.png | DIRECT | (10,7) | no |
| 123 | alpha0c (:125) | — EMPTY — | EMPTY | (11,7) | no |

Slots 124–127 in the last row (cells (12,7)…(15,7)) are unused padding.

**Art accounting.** 112 block PNGs ship: 85 are direct preset matches, 27 are `winter0..winter26` (no index in the Summer dictionary → intentionally excluded; they belong to the Winter set). 36 face presets reuse 18 base PNGs (E3/E4). 3 presets (`alpha0a/b/c`) have no PNG. Result: 85 + 36 = **121 filled cells**, 3 empty.

**APPROX_SAND_UPSCALE (explicit flag).** `sand1.png` and `sand2.png` ship at **256×256** while the other 110 blocks are **1024×1024** (E5). They are replicated ×4 to 1024² with `NEAREST` resampling so no interpolated colour value is invented. Six cells carry this upscale: indices 26, 27 (direct) and 35, 36, 37, 38 (`sand1f/s`, `sand2f/s`). This is a port substitution, not donor art; the donor uses a 64²/Rows=2/Cols=2 sub-tile scheme (E5).

## 4. Masks — converted from read-only donor BMPs

| Key | Donor file (read-only) | Header MEASURED | Output | Status |
|---|---|---|---|---|
| alpha | `C:\Games\Cossacks 3\data\terrain\tiles\textures\alpha.bmp` | 512×256, 8 bpp, BI_RGB (DIB 40), pixel offset 1070, 254-entry **grey** palette | `alpha.png` PNG L 512×256 | CONVERTED_FROM_DONOR |
| alphavert | `C:\Games\Cossacks 3\data\terrain\tiles\textures\alphavert.bmp` | 1024×512, 24 bpp, BI_RGB (DIB 40), pixel offset 54 | `alphavert.png` PNG L 1024×512 | CONVERTED_FROM_DONOR |

- Conversion follows E6/E7 (`tiaAlphaFromIntensity`, `textureformat = tfAlpha`): one 8-bit intensity per pixel. `alpha.bmp` is converted through its grey palette (`i → intensity`); `alphavert.bmp` is near-grey RGB (R=G=B on 494,081 of 524,288 pixels; per-channel means all 77.38) and converted with RGB→L. Independent probe confirmed both output PNGs are byte-identical to `Image.open(donor).convert('L')`.
- `alphanull.bmp` was read but is **not** a required mask and was deliberately not emitted.
- No cell↔tile sub-rect mapping was invented: whole donor atlases are exported. E8's eye-linear S/T and 0.125 scale remain shader-side inputs for a later atom; E9's sub-atlas values are commented out.

## 5. Exact commands run (project root = ROOT)

```
python -m py_compile variant3d/tools/build_tile_index_atlas.py
python variant3d/tools/build_tile_index_atlas.py
python variant3d/tools/build_tile_index_atlas.py --check
```
Independent read-only probes were written under `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\` (outside the repo), run, and deleted. They measured BMP headers, block PNG dimensions, the shipped tileblock histogram, cell/source byte equality, NEAREST ×4 replication, empty-cell transparency (RGBA extrema all 0), and mask byte identity. All probe files were removed; the `py_compile` `.pyc` was also removed.

## 6. Measured verification

| Check | Measured | Expected | Result |
|---|---|---|---|
| Named cells | **124** | 124 (`presets_summer.json:2-125`) | PASS |
| Cell size | **1024×1024** | 1024² | PASS |
| Atlas dimensions | **16384×8192 RGBA** | 16×8 × 1024² | PASS |
| Grid slots | 128 (124 used + 4 padding) | — | PASS |
| Filled / empty cells | **121 / 3** | 3 empty = `alpha0a/b/c` | PASS |
| Shipped tileblock | 102,400 bytes; **31 distinct ids**, range 0–85 | 320² uint8 | PASS |
| All shipped ids resolvable | **yes**, `unresolved_ids = []` | 31/31 < 124 | PASS |
| Top ids | `14:28535`, `0:15993`, `16:15962`, `79:7667`, `78:6691` | matches `TERRAIN2-06:31/45` | PASS |
| sand1/sand2 upscaled | **yes**, 256²→1024² NEAREST (6 cells) | explicit APPROX flag | PASS |
| alpha mask | **512×256**, mode L | E6 header | PASS |
| alphavert mask | **1024×512**, mode L | E7 header | PASS |
| Cell byte equality (indices 0, 14, 18, 87, 95 + face reuse 53) | identical to shipped source PNG | no pixel invented | PASS |
| 2D bake / sprite-sheet output | **none**; only 4 declared files in `atlas/` | none | PASS |
| Tool self-check (`--check`) | 12/12 checks true | all true | PASS |

Histogram of all 31 shipped ids (from manifest):
`0:15993, 1:2863, 4:77, 6:42, 7:837, 8:1, 9:43, 10:717, 14:28535, 15:144, 16:15962, 17:1498, 18:282, 19:879, 20:2415, 21:1735, 22:265, 23:1255, 24:2283, 25:4135, 72:267, 73:576, 74:279, 77:162, 78:6691, 79:7667, 80:2229, 82:19, 83:1779, 84:599, 85:2171`.

## 7. UNVERIFIED mask items (do not guess)

1. **Exact `tiaAlphaFromIntensity` formula for 24-bpp `alphavert.bmp`** — the donor engine's intensity operator is not in readable text (E7). The shipped L conversion is the faithful single-channel representation of a near-grey source; the precise formula remains **ENGINE / UNVERIFIED**.
2. **Alpha/alphavert atlas cell↔tile sub-rect mapping** — `reftile.lib:7-11` values are commented out and `tsDouble`/`ttExtended` semantics are engine-side (E9); `copy_assets.py:221-223` notes `dmask/` provenance but defines no loader (E10). Only whole-atlas PNGs are shipped; any cell mapping would be **UNVERIFIED** and was not fabricated.
3. **Face blending / promotion rule** — E8 gives eye-linear S/T and 0.125 scale for face materials, but which cell gets a face and the blend pass structure remain **ENGINE / UNVERIFIED** (`TERRAIN2-01:392-395`). Face cells here contain base rock/sand art (E3/E4), not a verified face projection.
4. **Empty cells `alpha0a/b/c`** — no shipped PNG; left transparent. Their intended art is **UNVERIFIED**, not synthesized.
5. **Donor atlas grid/packing** — 16×8 uniform layout is an **APPROX** (E9); donor packing is not readable.
6. **Visual parity** — no GPU A/B; every visual implication is a prediction. **Not claimed.**

Both required donor masks were readable, so neither was omitted. The tool still omits any unreadable mask at build time with an explicit `UNVERIFIED` manifest entry rather than fabricating it.

## 8. Open questions

- Is a ~180 MB single PNG acceptable for the repo, or should a later atom switch to a GPU texture array / lower cell resolution / tiled streaming? This atom deliberately kept 1024² cells per the dispatch contract.
- Where will the shader obtain `EYE_PLANE_S/T`, repeat period and the 0.125 face scale — A2/A3 territory; no constant was invented here.
- Should a winter atlas be built from the 27 excluded `winterN.png` blocks against a `presets_winter.json` dictionary in a separate task?
- Do the 3 empty `alpha0*` cells ever receive a runtime id? The shipped 31-id dump contains none, so this is currently moot.
- Does the runtime want L-mode mask PNGs directly as a second sampler, or an RGBA repack? This atom exports the donor-grounded single-channel form.

## 9. Bottom line

Delivered the single new tool plus four generated assets. Measured: **124 named 1024² cells in a 16384×8192 RGBA atlas**, **121 filled / 3 empty**, **31/31 shipped tile ids resolvable**, masks **512×256** and **1024×512**, **no 2D bake/sprite-sheet output**, and an explicit **APPROX** flag for the sand1/sand2 256²→1024² upscale. The index dictionary and face base-art reuse come from donor data already shipped/readable; no index mapping or mask cell was invented. All labels, UNVERIFIED items and open questions are recorded above. No visual parity is claimed.

*End of report. V7-85 owned only the tool, the `atlas/` assets and this file; no .gd, existing splat tool, app/, config, test or git state was touched.*
