---
id: INVENTORY-01
title: Independent re-count of donor inventories claimed by the decomp lane
area: read-only verification (donor inventory)
owner: INVENTORY-01 verification worker
date: 2026-11-25
status: COMPLETE — read-only; donor never executed or copied; no repo file edited other than this report
labels: observed | derived | inferred | UNVERIFIED
counts_verified: 76
mismatches: 3
donor: "C:\\Games\\Cossacks 3 (READ-ONLY)"
output: docs/coord_swarm_2026-11-25/reports/INVENTORY_01_counts.md
---

# INVENTORY-01 — independent donor inventory re-count

## 1. Sources

**Donor (read-only, never executed/copied):** `C:\Games\Cossacks 3` — root and all
17,237 files beneath it, enumerated with `pathlib.Path.iterdir()` and
`pathlib.Path.rglob("*")`.

**Reports whose claimed counts were collected (summary/inventory sections read in full):**

| Report | Path |
|---|---|
| DEC-01 | `docs/coord_swarm_2026-11-25/decomp/DEC_01_binaries_rtti.md` |
| DEC-02 | `docs/coord_swarm_2026-11-25/decomp/DEC_02_scripts.md` |
| DEC-03 | `docs/coord_swarm_2026-11-25/decomp/DEC_03_configs.md` |
| DEC-04 | `docs/coord_swarm_2026-11-25/decomp/DEC_04_anim_formats.md` |
| DEC-05 | `docs/coord_swarm_2026-11-25/decomp/DEC_05_terrain_formats.md` |
| DEC-06 | `docs/coord_swarm_2026-11-25/decomp/DEC_06_map_formats.md` |
| DEC-07 | `docs/coord_swarm_2026-11-25/decomp/DEC_07_cameras_shaders.md` |
| DEC-08 | `docs/coord_swarm_2026-11-25/decomp/DEC_08_ui_strings.md` |

**Analysis scripts (outside the repo, not committed):**
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\INVENTORY_01_count.py`,
`INVENTORY_01_targeted.py`, `INVENTORY_01_final.py`.

## 2. Method

- Windows `python` 3.14 only (never `python3`). Donor opened strictly read-only.
- **Observed** counts come from `Path.rglob("*.ext")` / `Path.iterdir()` with
  `p.is_file()`, plus `p.stat().st_size` for sizes. Counts for subtree-scoped
  families used a *boundary-safe* prefix (`relpath.startswith(d + "/")`), because a
  bare prefix on `data/gen/terrainmasks` also swallows `.src` and `.dlc5` (this was
  caught and corrected mid-pass).
- **Header checks** read raw bytes with `open(p,"rb").read(n)` and
  `struct.unpack_from`; magic byte strings were compared as `bytes`, never via
  string indexing. DDS `0x54` FourCC, Ogg `OggS` + first packet `01 76 6f 72 62 69 73`
  at byte 28, AAF `AAF`, OSM `IDP2` + version int at `0x4`, BMP `BM`, PE `MZ`/`PE\0\0`
  at `e_lfanew`, TGA imagetype at byte 2 / pixeldepth at byte 16, `.oss` `<6i` header.
- **Text counts** used `bytes.splitlines()` and **line-anchored** byte prefixes
  (`line.lstrip().startswith(b"Key = ")`). This matters: the substring `Key = `
  also matches `AlternativeKey = ` (hence raw 57 vs true 55 in `hotkeys.cfg`), and
  `Name = ` also matches `UsedFileName = ` (284 vs true 142 in `menu.aix`).
- Line-count conventions were checked explicitly: `splitlines()` vs
  `split(b"\r\n")` differ by one when a file ends with an extra CRLF
  (`menu.aix`: 984 vs 985; `tilesmooth_scripts.cfg`: 1,863 vs 1,864). Both reports'
  numbers are correct under their own convention; these are recorded as MATCH.
- All map headers were located by scanning for the length-prefixed `TerrainMapBegin`
  token in 2–4 MiB overlapping chunks; the first 9 misses were re-scanned over the
  entire file (markers lie up to byte 124,017,847 in `netmis1.map`).
- No donor file was written, run, or copied; no repo file was edited other than
  this report. No runner jobs were queued.

## 3. Count table

`Match` = YES unless noted. `L` = evidence label for the independent count.

### 3.1 Root, PE and script inventories

| # | Claim (count) | Report / locator | Claimed | Independent | Match | Explanation / label |
|---:|---|---|---:|---:|---|---|
| 1 | Donor root plain-file count | DEC-01 D1E01 | 22 | **24** | **NO** | `Path.iterdir()` returns 24 regular files, all with `st_file_attributes=32` (Archive; none hidden/system). DEC-01's §3 table lists only 16; 8 installer/audio/steam files are omitted from both numbers. See Correction C1. **observed** |
| 2 | DEC-01 §3 table rows | DEC-01 §3 | 16 | 16 listed / 24 exist | scope | Curated PE+INI table, not a full inventory. **observed** |
| 3 | PE files total | DEC-06 §3.1 | 19 | 19 | YES | 5 `.exe` (incl. `unins000.exe`) + 5 `.cdx` + 9 `.dll`. **observed** |
| 4 | `.exe` files | DEC-06 §3.1 | 5 | 5 | YES | config, cossacks, editor, modman, unins000. **observed** |
| 5 | `.cdx` files | DEC-06 §3.1 | 5 | 5 | YES | config, cossacks, editor, modman, steam_api. **observed** |
| 6 | `.dll` files | DEC-06 §3.1 | 9 | 9 | YES | GameOverlayRenderer, codex, ogg, openal32, steam_api, steamclient, steamwrap, vorbis, vorbisfile. **observed** |
| 7 | `data\scripts` file count | DEC-02 §3 | 222 | 222 | YES | `rglob` under `data/scripts`. **observed** |
| 8 | `data\scripts` total bytes | DEC-02 §3 | 4,373,442 | 4,373,442 | YES | sum of `stat().st_size`. **observed** |
| 9 | scripts with high (CP1251) bytes | DEC-02 §3 | 19 | 19 | YES | any byte ≥ 0x80. **observed** |
| 10 | scripts with NUL / BOM | DEC-02 §3 | 0 / 0 | 0 / 0 | YES | **observed** |
| 11 | `.aix` under `data\scripts` | DEC-02 §3.3 | 13 | 13 | YES | **observed** |
| 12 | `.inc` under `data\scripts` | DEC-08 §3 | 177 | 177 | YES | **observed** |

### 3.2 Configs (DEC-03)

| # | Claim (count) | Report / locator | Claimed | Independent | Match | Explanation / label |
|---:|---|---|---:|---:|---|---|
| 13 | `.cfg` + `.ini` files | DEC-03 §3 | 77 | 77 | YES | 74 `.cfg` + 3 `.ini`. **observed** |
| 14 | 0-byte config files | DEC-03 §3 | 2 | 2 | YES | `data/hud/bar.load.menu.cfg`, `data/hud/bar.save.game.cfg`. **observed** |
| 15 | `hotkeys.cfg` lines | DEC-03 §4.7 | 243 | 243 | YES | **observed** |
| 16 | `hotkeys.cfg` bindings | DEC-03 §4.7 | 55 | 55 | YES | Line-anchored `Key = `; raw substring count 57 includes 2 `AlternativeKey`. **observed** |
| 17 | hotkeys Repeat / Alt / Up / empty | DEC-03 §4.7 | 9 / 2 / 7 / 3 | 9 / 2 / 7 / 3 | YES | **observed** |
| 18 | `formations.cfg` records | DEC-03 §4.9 | 149 | 149 | YES | anchored `id = `. **observed** |
| 19 | formations symmetry 1 / 0 | DEC-03 §4.9 | 137 / 12 | 137 / 12 | YES | **observed** |
| 20 | formations `struct.begin` | DEC-03 §3 / §4.9 | 298 | 298 | YES | **observed** |
| 21 | `formations.cfg` lines | DEC-03 §3 | 2,307 | 2,307 | YES | **observed** |
| 22 | `envscales.cfg` named objects | DEC-03 §4.8 | 122 | 122 | YES | anchored `name = `. **observed** |
| 23 | `envscales.cfg` lines | DEC-03 §3 | 869 | 869 | YES | **observed** |
| 24 | `generator.cfg` `Freq` / lines | DEC-03 §3 | 493 / 2,367 | 493 / 2,367 | YES | **observed** |
| 25 | `startingsettings.cfg` `startid` values | DEC-03 §3 | 19 | 19 | YES | 20 lines contain `startid`, minus 1 comment `//startid` at line 2. **observed** |
| 26 | `startingsettings.cfg` lines | DEC-03 §3 | 3,424 | 3,424 | YES | **observed** |

### 3.3 Animation / audio formats (DEC-04)

| # | Claim (count) | Report / locator | Claimed | Independent | Match | Explanation / label |
|---:|---|---|---:|---:|---|---|
| 27 | `.oss` files | DEC-04 §2 | 335 | 335 | YES | **observed** |
| 28 | `.osm` files | DEC-04 §2 | 3,897 | 3,897 | YES | **observed** |
| 29 | `.aaf` files | DEC-04 §2 | 246 | 246 | YES | **observed** |
| 30 | `.acl` files | DEC-04 §2 | 30 | 30 | YES | **observed** |
| 31 | `.ogg` files | DEC-04 §2 | 325 | 325 | YES | **observed** |
| 32 | `.snd` / `.slc` files | DEC-04 §2 | 3 / 1 | 3 / 1 | YES | **observed** |
| 33 | Ogg `OggS` + Vorbis first packet | DEC-04 §3 | 325/325 | 325/325 | YES | bytes 0–3 `OggS`, byte 26 = 1, bytes 28–34 `01vorbis`. **observed** |
| 34 | OSM `IDP2` magic | DEC-04 §3 | 3,897/3,897 | 3,897/3,897 | YES | **observed** |
| 35 | OSM version 8 | DEC-04 §4.2 | 3,897/3,897 | 3,897/3,897 | YES | int32 @`0x4`. **observed** |
| 36 | AAF `AAF` magic | DEC-04 §3 | 246/246 | 246/246 | YES | **observed** |
| 37 | AAF total action rows | DEC-04 §4.3 / §11 | 1,434 | 1,434 | YES | sum of line-2 decimal counts over all 246 files. **observed** |
| 38 | `.oss` fps = 30 | DEC-04 §4.1 | 335/335 | 335/335 | YES | int32 @`0x4`. **observed** |
| 39 | `.oss` bone distribution | DEC-04 §4.1 | b∈{1..42}, 124 at b=1 | identical histogram | YES | all 22 buckets reproduced. **observed** |
| 40 | `.oss` `k` range | DEC-04 §4.1 | 24…755 | 24…755 | YES | int32 @`0x0`. **observed** |
| 41 | OSM `nf=1` / `nf>1` | DEC-04 §4.2 | 3,868 / 29 | 3,868 / 29 | YES | int32 @`0x28`; max `nf`=307 also reproduced. **observed** |
| 42 | `.snd` `Path` lines (units/interface/ambient) | DEC-04 §8.2 | 248 / 52 / 27 | 248 / 52 / 27 | YES | non-empty 247 / 51 / 27 as claimed. **observed** |

### 3.4 Terrain and map families (DEC-05, DEC-06)

| # | Claim (count) | Report / locator | Claimed | Independent | Match | Explanation / label |
|---:|---|---|---:|---:|---|---|
| 43 | `.map` files total | DEC-06 §3.1 | 87 | 87 | YES | **observed** |
| 44 | `.map` base / DLC split | DEC-06 §3.1 | 38 / 49 | 38 / 49 | YES | DLC: dlc1 10, dlc2 13, dlc3 10, dlc4 9, exp1 5, summer 1, winter 1. **observed** |
| 45 | `.map` min/max size | DEC-05 §3.4 | 23,447,543 – 125,689,207 | same | YES | `bonmis1.map` / `battle7.map`. **observed** |
| 46 | `.aix` files total | DEC-06 §3.1 | 65 | 65 | YES | 30 base + 18 DLC + 14 scripts/GUI + 3 root scripts (= 13 `data/scripts` + 1 `data/gui` + 3 `scripts/`). **observed** |
| 47 | Map dimensions 320²/384²/512²/640² | DEC-06 §5.1 | 80 / 3 / 3 / 1 | 80 / 3 / 3 / 1 | YES | full-file marker scan required for `battle7` and 8 DLC maps. **observed** |
| 48 | Map field-4 value 64 / 25920 | DEC-06 §5.1 prose | 53 / 27 | **55 / 32** | **NO** | prose contradicts its own cross-tab (37+18=55, 23+9=32) and the 87-map census. See Correction C2. **observed** |
| 49 | TGA files total | DEC-05 §3.2 | 4,510 | 4,510 | YES | **observed** |
| 50 | TGA imagetype 10 / 2 | DEC-05 §3.2 | 4,467 / 43 | 4,467 / 43 | YES | byte 2 of header. **observed** |
| 51 | TGA pixeldepth 24 / 32 | DEC-05 §3.2 | 4,479 / 31 | 4,479 / 31 | YES | byte 16. **observed** |
| 52 | DDS files total | DEC-05 §3.3 | 1,469 | 1,469 | YES | **observed** |
| 53 | DDS FourCC DXT5 / DXT1 / DXT3 | DEC-05 §3.3 | 1,284 / 179 / 6 | 1,284 / 179 / 6 | YES | bytes `0x54..0x57`. **observed** |
| 54 | `data\gen\terrainmasks` files / TGA | DEC-05 §3.2 | 1,336 / 1,331 | 1,336 / 1,331 | YES | subtree-scoped; prefix overlap with `.src`/`.dlc5` avoided. **observed** |
| 55 | `terrainmasks.src` files / TGA | DEC-05 §3.2 | 1,281 / 1,279 | 1,281 / 1,279 | YES | **observed** |
| 56 | `terrainmasks.dlc5` files / TGA | DEC-05 §3.2 | 1,861 / 1,856 | 1,861 / 1,856 | YES | **observed** |
| 57 | `gen\bitmap` BMP + `.cfg` | DEC-05 §3.2 | 85 + 1 | 85 + 1 | YES | +2 BMP in `bitmap\ext`. **observed** |
| 58 | `terrain\tiles\textures` files | DEC-05 §3.3 | 115 = 112 DDS + 3 BMP | 115 = 112 + 3 | YES | **observed** |
| 59 | `tilesmooth_scripts.cfg` active groups / pairs | DEC-05 §4.6 | 118 / 282 | 118 / 282 | YES | 130 total `TileNames` blocks, 12 with no `TileName` child. **derived** |
| 60 | `tilesmooth_scripts.cfg` lines | DEC-05 §4.6 | 1,864 | 1,863 / 1,864 | YES | `splitlines()` 1,863; `split(b"\r\n")` 1,864 (trailing CRLF). **observed** |

### 3.5 Cameras, shaders, UI (DEC-07, DEC-08)

| # | Claim (count) | Report / locator | Claimed | Independent | Match | Explanation / label |
|---:|---|---|---:|---:|---|---|
| 61 | `data\shaders` files / bytes | DEC-07 §4.0 | 109 / 272,517 | 109 / 272,517 | YES | **observed** |
| 62 | shader extensions `.frag/.vert/.bak/.lib/.ref` | DEC-07 §4.0 | 58/47/2/1/1 | 58/47/2/1/1 | YES | **observed** |
| 63 | shader dirs obj/tone/water/root | DEC-07 §4.0 | 75/26/6/2 | 75/26/6/2 | YES | **observed** |
| 64 | `data\cameras` files | DEC-07 §3.0 | 4 | 4 | YES | camera.cfg, cameradebug.cfg, camerascreenshot.cfg, default.cameras. **observed** |
| 65 | `shaders.lib` / `shaders.ref` lines | DEC-07 §4.0 | 1,813 / 180 | 1,813 / 180 | YES | **observed** |
| 66 | `shaders.lib` vertex/fragment/name records | DEC-07 §4.0 | 74 / 34 / 84 | 74 / 34 / 84 | YES | anchored; 2 commented vertex, 2 commented fragment, 8 commented name lines exist. **observed** |
| 67 | `locale\en\gui.txt` keys / `gui.lng` records | DEC-08 §3 / §4.1 | 461 / 460 | 461 / 460 | YES | record count = u32 at `gui.lng:0x0`. **observed** |
| 68 | `menu.aix` `Name` / `UsedFileName` | DEC-08 §3 | 142 / 142 | 142 / 142 | YES | anchored. **observed** |
| 69 | `menu.aix` lines | DEC-08 §3 | 985 | 984 / 985 | YES | `splitlines()` vs `split(b"\r\n")`; file ends `\r\n\r\n`. **observed** |
| 70 | `scripts\editor.aix` section/Name/UsedFileName | DEC-06 §3.2 | 174 / 173 / 173 | 174 / 173 / 173 | YES | anchored. **observed** |
| 71 | `.inc` whole donor | DEC-08 C6 | **313** | **455** | **NO** | 313 = `data/` subtree only (133+3+177); +142 files under root `scripts/editor.inc/` = 455. See Correction C3. **observed** |
| 72 | font atlas BMPs | DEC-08 §3 | 92 (23 × 4) | 92 | YES | `data/hud/textures/font/**`. **observed** |
| 73 | `hud\textures\ui\*.bmp` | DEC-08 §3 | 26 | 26 | YES | **observed** |
| 74 | locale `.lng/.txt/.lib/.loc` | DEC-08 §3 / C7 | 1,093 / 1,082 / 11 / 1 | 1,093 / 1,082 / 11 / 1 | YES | `data/locale/**`; whole `data/` has 1,086 `.txt`. **observed** |
| 75 | cursor BMP / CUR | DEC-08 §3 | 14 / 8 | 14 / 8 | YES | **observed** |
| 76 | `selection.*.dds` brushes | DEC-08 §3 | 6 | 6 | YES | **observed** |

**Totals: 76 counts checked; 73 MATCH, 3 NO (all three are inventory/scope claims, not format-layout claims).**

## 4. Corrections for COORD (do not edit original reports)

**C1 — DEC-01 D1E01 root-file count: 22 → 24 (observed).**
`Path.iterdir()` on `C:\Games\Cossacks 3` returns **24** regular files. All have
`st_file_attributes == 32` (Archive); none is hidden or system, so no Windows
filter explains 22. DEC-01's §3 table lists 16 files; the 8 additional root files
are, exactly:
`ogg.dll` (19,968 B), `openal32.dll` (253,952 B), `steamclient.dll` (259,360 B),
`steamwrap.dll` (139,776 B), `unins000.dat` (51,029 B), `unins000.exe` (2,070,111 B),
`vorbis.dll` (46,080 B), `vorbisfile.dll` (9,216 B).
Note DEC-01 §8 *does* cite `ogg.dll`/`vorbis.dll`/`openal32.dll` paths inside `cossacks.exe`,
so the files exist on this snapshot; only the inventory number is short. The origin of
the exact value 22 is **UNVERIFIED** (possible earlier snapshot or manual undercount).

**C2 — DEC-06 §5.1 field-4 prose: "64 (53 maps) or 25920 (27 maps)" → 55 / 32 (observed).**
Full 87-map header scan: `64` in **55** maps, `25920` in **32**. This reproduces
DEC-06's own cross-tab (7/64 ×37 + 13/64 ×18 = 55; 7/25920 ×23 + 13/25920 ×9 = 32)
and the 87-map total. The prose figures 53/27 sum to 80 and are an internal
undercount. The substantive conclusion (field is opaque, not "tile size 64 px")
is unaffected.

**C3 — DEC-08 C6 / §3 "whole-tree `*.inc` = 313" → 455 (observed).**
Whole-donor `.inc` count is **455**: `data/` subtree **313** (`data/gui/menu.inc` 133,
`data/gui/common.inc` 3, `data/scripts/**` 177) plus root `scripts/editor.inc/**`
**142**. DEC-08's C6 "correction" of DE_AUDIO_UI.md:20's 455 is therefore itself
incorrect: 455 was right for the *whole donor*, and 313 is right only for `data/`.
DEC-08's other sub-counts (133, 3, 177) are all confirmed. Suggested wording:
"`.inc` files: 455 whole donor (313 under `data/`, 142 under `scripts/editor.inc/`)."

**Non-corrections (scope/convention, recorded so COORD need not act):**
- DEC-05's "38 `.map`" vs DEC-06's "87 `.map`" = `data/maps/missions` only vs
  whole donor including DLC. Both correct in scope.
- DEC-08's 985 `menu.aix` lines and DEC-05's 1,864 `tilesmooth_scripts.cfg` lines
  use the `split(b"\r\n")` physical-line convention; `splitlines()` gives 984/1,863.
  No byte-level discrepancy.
- `Path.rglob("data/gen/terrainmasks")` bare-prefix counting also matches
  `terrainmasks.src` and `terrainmasks.dlc5` (4,478/4,466 combined). DEC-05's
  per-directory figures are correct when scoped with a `/` boundary.

## 5. Open questions / UNVERIFIED

- Counts **not** re-derived here because they depend on the report-specific parser
  or on disassembly: DEC-01's curated RTTI token counts (3,730 tokens; 112 `X*`,
  ~886 `T*`, 48 OSW, 8,090 editor-extra), the 778 `steam_api` exports / 27 import
  descriptors / 9 resource ID types, `.bind` entropy, DEC-04's 266 ACL references
  and 62 distinct AAF action names, DEC-06's scenario cardinalities (512 triggers,
  8 conditions, 16 actions) and version-7/13 `gMap` split. These remain as claimed
  by their lanes — not confirmed, not refuted (**UNVERIFIED** by this worker).
- The origin of DEC-01's exact "22" root-file figure is **UNVERIFIED** (see C1).
- Donor build provenance: map headers carry `Build.Ver[2.0.0.2843]` in 78 maps and
  `Build.Ver[2.0.0.2844]` in 9 DLC4 maps (observed, not a claimed count). Whether
  this affects DEC-01's four distinct EXE `FileVersion` values is **UNVERIFIED**.
- No donor process was run, no unpacking attempted, no donor bytes copied; header
  checks were limited to the magic/version fields named in §2.

## 6. Summary

- I independently re-counted **76 distinct inventory/header counts** across all eight
  DEC reports. **72 match exactly**, one is a scope clarification (row 2, DEC-01's
  curated 16-row §3 table), and three do not match: C1 (root files 22→24), C2
  (map field-4 prose 53/27→55/32), and C3 (whole-tree `.inc` 313→455).
- All headline format-family counts are confirmed: 335 `.oss`, 3,897 `.osm`,
  246 `.aaf`, 30 `.acl`, 325 `.ogg`, 3 `.snd`, 1 `.slc`, 87 `.map`, 65 `.aix`,
  1,469 `.dds`, 4,510 `.tga`, 109 shaders / 272,517 B, 4 camera files, 222 scripts /
  4,373,442 B, 77 configs, and the DEC-08 locale/UI asset counts.
- Byte-header checks confirm the claimed magics across the entire donor: DDS
  `DDS ` 1,469/1,469; Ogg `OggS`+Vorbis 325/325; AAF 246/246; OSM `IDP2`+v8
  3,897/3,897; BMP 264/264; PE 19/19; TGA type/depth histograms exact.
- The decomp lane's *format-layout* claims were not contradicted by any inventory
  finding; only three whole-donor enumeration statements need correction.
- **No repository file other than this report was edited.** No code edits, no
  runner jobs, no donor copies, no donor execution.

*INVENTORY-01 · read-only verification · donor never executed or copied.*
