---
id: DEC-06
title: "DEC-06 — Donor MAP / EDITOR formats deeply documented: .map, .aix, .cdx + skirmish-generation data"
area: donor / file formats / map generator / terrain piece tests
owner: DEC-06
date: 2026-11-25
status: RESEARCH_COMPLETE
scope: "AUDIT ONLY. Donor C:\\Games\\Cossacks 3 opened READ-ONLY. No donor file copied, converted or committed; no donor executable run; no Godot/app/test/git edit."
tools: "Craft Anything 0.6.1 (core + native + formats toolsets, Deep mode) for evidence-ids; read-only Python 3.14 + mmap for full-file structural walks and histograms."
labels: "OBSERVED = bytes/text read directly; DERIVED = arithmetic/count over observations; INFERRED = labelled interpretation; UNVERIFIED = not proven."
---

# DEC-06 — Donor MAP / EDITOR formats deeply documented

## 1. Goal

Deep-document the donor's **`.map`** (mission/skirmish map save), **`.aix`**
(script sidecar / editor script bundle) and **`.cdx`** (protected executable
variant) formats, plus editor/scenario data that determines **skirmish random-map
seed and parameters**, so the Godot port's map generator can learn real tile,
mine, tree and shoreline distributions for today's terrain-piece tests.

Mission/trigger/objective *execution semantics* are **DEFERRED (D-12)**: the
schemas, field names and storage locations are documented below as donor truth,
but no trigger-language translation is attempted here.

Deliverable is this report only. No code was edited.

---

## 2. Prior docs read (and what was re-tested)

| Doc | Contribution | Action in this pass |
|---|---|---|
| `docs/decomp/DD_MAPS.md` | 49 DLC `.map` + 18 DLC `.aix` inventory; first 173 B TLV header; "numeric grid opaque/CLOSED"; `.aix` = text not AI blobs | Header hexdump re-read; **"CLOSED" refuted** by §6.1; `.aix` scope broadened from DLC-only to all 65 files |
| `docs/decomp/DC_FORMATS.md` | Family census; `.map` 87 / `.aix` 65; `.pattern` = w,h + mask; T-7 "full decode won't fix" | Counts re-confirmed (87/65); **T-7 is now partially superseded** (height/tile/entity grids readable) |
| `docs/decomp/DA_PE.md` | PE triage; `cossacks.cdx` entry `0x96c310`; "six donor PE files"; `.bind` entropy 7.96 | **PE count refuted** (19 PEs); `editor.exe/.cdx` and `modman` added; entry value clarified as VA vs RVA |
| `docs/audit/DECOMP.md` | Independent audit: `.aix` = 7-bit ASCII CRLF (18 DLC); DD binary layout not re-audited | Sharpened to all 65 `.aix` = 7-bit ASCII CRLF; `.map` binary re-audited here |
| `docs/coord_swarm_2026-11-24/reports/DECOMP_06_map_format.md` | `TerrainMapBegin/End`, raw f32 320² grid ±2.964, 37-B record grid, named records | Re-derived on 3 maps + added **87-map** dimension survey; **±2.964 universal claim corrected** (384 map max +2.3712) |
| `.../V783_donor_map_importer.md` | Read-only importer; W/H generalisation; tile hist; `TScenarioa` byte noted; correction of `TerrainMapEnd` prefix 13 | Re-confirmed variable-length named records; tile-grid anchor re-derived (off-by-one in *detection*, see §6.3) |
| `.../DEEPDEC_05_map_serialization.md` | 22 delimiters; 37-B tile record; RTTI-like schema; `gScenario`; `GameObject` entities | Schema fields extracted in full for `TMapSettingsGen`/`TScenario*`; **4th header field "tile size 64" refuted** (25920 in 27 maps) |
| `investigation.cany/investigation/{findings,hypotheses}.md`, `brief.md` | fnd_1 constants (26.666 px/m, 53.333 px/tile); fnd_4 packed entry `0x8f1a08`; editor.exe listed as a target | fnd_4 is the `.exe` entry (RVA `0x4f1a08`, VA `0x8f1a08`); `.cdx` redirects into `.bind` stub; scale question kept UNVERIFIED |

---

## 3. File inventory (OBSERVED)

### 3.1 Formats relevant to this ticket

| Family | Count | Size range | Kind | Readability |
|---|---:|---|---|---|
| `.map` | **87** (38 base `data/maps/missions`, 49 DLC across 7 families) | 23,447,543 B (`bonmis1`) – 142,754,495 B (`netmis1`) | flat Delphi/OSW serialized stream, **not an archive** | header, RTTI-like schema, height grid, tile grid, entities readable; no container |
| `.aix` | **65** (30 base mission sidecars, 18 DLC mission sidecars, 14 `data/scripts`+GUI, 3 root `scripts/`) | 258 B (`scripts/user/user.aix`) – 124,060 B (`scripts/editor.aix`) | plain 7-bit ASCII text, CRLF, no BOM | fully readable; Pascal-like statements stored verbatim |
| `.cdx` | **5** (`config`, `cossacks`, `editor`, `modman`, `steam_api`) | 213,072 – 7,874,416 B | PE32 with redirected entry | not a data format — byte-identical PE build to the matching `.exe`/`.dll` apart from entry point (and one import-name swap) |
| PE files total | **19** | — | 5 `.exe` + 5 `.cdx` + 9 `.dll` | DA_PE's "6 PE files" is wrong for the current install |

`core_packed_files_list` on `bonmis1.map` was **rejected** (`not_supported`: "This
file doesn't carry files in any way we recognise") — re-confirms DD/DECOMP-06: one
flat stream, no ZIP/PCK/etc. inside.

### 3.2 Editor / generator data (all read-only)

| Path (relative to `C:\Games\Cossacks 3`) | Size | Why it matters |
|---|---:|---|
| `editor.ini` | 451 | `AutoRunState = OnAutoRunEditor`, `ConstLODFactor=1.0`, `GameSaveDirectoryPath=cossacks` |
| `cossacks.ini` | 161 | save-directory/log settings only; **no seed** |
| `data/projects/project.main.prj` | 325 | `BuildVersion=2.2.3`, `SVNVersion=6008`, `Resource.LoadFromFile=.\data\resources\resource.lib` (`ev_6c7e26a7…`) |
| `scripts/editor.aix` | 124,060 | 174 `section.begin`, 173 `Name =`, 173 `UsedFileName =`; state→`scripts/editor.inc/*.inc` registry (`ev_a75ae138…`) |
| `scripts/editor.inc/*.inc` | ~30 files | `generatemap.inc`, `generatemapfrombitmap.inc`, `loadgeneratedmapfromfile.inc`, `savegeneratedmaptofile.inc`, `createstartpatterns.inc`, `plateaugenerator1..3.inc`, `load/savemapterraindata.inc`, scenario load/save |
| `data/game/var/generator.cfg` | 70,074 | `TerrainTypes` (mask dirs), `Patterns` (`mng/mni/mnc`, `stoneforests`, forest families) with `Pattern=`/`Freq=` (`ev_533c083d…`; 64 bytes are non-UTF-8 → latin-1/cp1252) |
| `data/game/var/random.cfg` | 51 | exactly `random : section.begin / field = fax / section.end` — **not** the map seed (`ev_d3109970…`) |
| `data/game/var/startingsettings.cfg` | 116,920 | starting-setting surface (not decoded here) |
| `data/gen/mapcover.cfg` | 1,196 | height-zone tile frequencies, local presets |
| `data/scripts/common.inc/generatemap.inc` | 51,794 | seed intake, constants, 320–640 map sizes |
| `data/scripts/common.inc/dogenerate.inc` | 109,219 | `SetupMines`, `SetupStartingResources`, forest placement |
| `data/scripts/common.inc/{texturemap,initmapgen,initmap}.inc` | 48,954 / 13,193 / 4,003 | shoreline/rock/forest tile choice; seed reseeding; defaults |
| `data/scripts/lib/{map,scenario,scenarioeditor,classes}.script` | 12,169 / 208,321 / 10,511 / — | `_map_ResetMapSettings`, `TScenario*`, trigger constants |
| `data/gui/menu.inc/{donewgame,initmapsettings}.inc` | — | **skirmish seed pipeline** (§7.1) |
| `data/scripts/progress/progress.inc/{read,write}scenario.inc` | 4,341 / 7,393 | network trigger/flag/counter sync, not map storage |

---

## 4. Per-format binary layout

### 4.1 `.map` — header, framing, compression, encoding

`C:\Games\Cossacks 3\data\maps\missions\bonmis1.map:0x0000` (OBSERVED, hexdump
re-derived twice — Python + Craft Anything `native_bytes_find` anchors):

```
00000000  35 00 00 00 4f 53 57 4d 61 70 31 33 2e 4d 61 70  5...OSWMap13.Map
00000010  2e 56 65 72 5b 30 2e 30 5d 42 75 69 6c 64 2e 56  .Ver[0.0]Build.V
00000020  65 72 5b 32 2e 30 2e 30 2e 32 38 34 33 5d 43 6f  er[2.0.0.2843]Co
00000030  72 65 2e 56 65 72 5b 31 5d 20 00 00 00 11 55 49  re.Ver[1] ...UID
00000040  44 34 32 33 36 33 30 34 32 32 38 31 36 38 35 30  D423630422816850
00000050  00 00 00 00 00 00 00 00 00 00 00 00 00 14 00 00  ...UID pad.......
00000060  00 47 61 6d 65 4d 61 70 53 6e 61 70 53 68 6f 74  .GameMapSnapShot
00000070  42 65 67 69 6e 00 00 00 00 12 00 00 00 47 61 6d  Begin........Gam
00000080  65 4d 61 70 53 6e 61 70 53 68 6f 74 45 6e 64 12  eMapSnapShotEnd.
00000090  00 00 00 47 61 6d 65 4d 61 70 52 65 63 6f 72 64  ...GameMapRecord
000000a0  42 65 67 69 6e 00 00 00 00 00 01 00 00 00 00 00  Begin...........
```

* `u32 LE length` + exactly that many 7-bit ASCII bytes is the file's primitive.
  Header: 53 B version string at `0x0004`, then a 32-B UID block at `0x0039`
  (first byte `0x11`, then `UID423630422816850`, zero-padded), then 20/18-B
  section markers. Numeric sub-header begins at `0x00ad`/`0x00b1` (256 B), as DD
  described; TLV walking breaks there (DERIVED, matches DD).
* 22 unique `…Begin/…End` delimiters in one fixed order across maps
  (DEEPDEC-05 §2, re-used; anchors re-confirmed at `bonmis1.map:0x8d8a7d`
  `TerrainMapBegin`, `ev_e1dd42c0…`).
* **Compression: none.** Full-file byte scan of `bonmis1.map` and `scemis8.map`:
  gzip `1F 8B 08` = 0, ZIP `PK\x03\x04` = 0, zstd = 0, bzip2 = 0, xz = 0
  (OBSERVED, DERIVED). Sparse/zero areas are unwritten arrays, not packed data.
* **String encoding:** 7-bit ASCII for length-prefixed names; no UTF-16 in the
  map body. Type-schema strings use the same `lp()` primitive.
* Trailer `bonmis1.map:0x165c7d8`:
  `05 00 00 00 EXT.0 01 00 00 00 00 00 00 00 0a 00 00 00 GameMapEnd`
  → `GameMapEnd` prefix is **10**, matching V7-83's correction pattern for
  `TerrainMapEnd` (13), not DECOMP-06's quoted 16.

### 4.1.1 The RTTI-like type schema inside `GameMapRecord` (new detail)

At `bonmis1.map:0x182640` (`ev_1756c8df…`, `ev_ef6329ee…`) the stream stores
a type header `lp(typeName) u32 1 u32 0` followed by repeated field
declarations `lp(fieldName) lp(typeName) u32 0`:

Abbreviated view (the leading decimal is the `lp()` length, not a hex byte):

```
0018263c  15 TMapSettingsGen  01 00 00 00 00 00 00 00
00182658  08 randkey0   07 integer  00 00 00 00
00182673  08 randkey1   07 integer  00 00 00 00
0018268e  07 mapsize    07 integer  00 00 00 00
001826a8  11 terraintype 07 integer 00 00 00 00
001826c6  10 relieftype  07 integer 00 00 00 00
001826e3  13 resourcestart 07 integer ...
00182703  13 resourcemines 07 integer ...
```

Full field lists recovered from the same schema block (OBSERVED, byte offsets
in `bonmis1.map`):

| Type (schema @ offset) | Fields (in stored order) |
|---|---|
| `TMapSettingsGen` (`0x182640`) | `randkey0:integer, randkey1:integer, mapsize:integer, terraintype:integer, relieftype:integer, resourcestart:integer, resourcemines:integer` |
| `TMapSettingsAdditional` (`0x182723`) | `activeoption, startingunits, balloon, cannons, peacetime, century18, capture, autosave, gamespeed` (all integer) |
| `TMapPlayer[8]` (`0x182a67`) | `id, cid:integer, csid:string, name:string, team, color, lanid:integer, startx:float, starty:float, aidifficulty, bexists, bai, bhuman, bclosed, bready, bloaded, bleave:boolean` |
| `TMap` (`0x182a7c`) | `name:string, gamestage:integer, settings:TMapSettings, players:TMapPlayer[8]` |
| `TScenarioSettings` (`0x184f1f`) | `filename, preview, langfilename, langtable, name, description` (all string). The adjacent `TInterface` block (`0x184e…`) separately holds `gamemode:integer, settings:integer, bhideobjectives:boolean, showobjectivestimer:float, bupdateobjectivestext:boolean` |
| `TScenarioTriggerCondition[8]` (`0x185240`) | `id, triggerid, flagid, counterid, timerid, groupid, zoneid, resultid, bactive, bstate, usecounterid, busecounterasamount, busecounterastime, player, difficulty, resource, amount, sign:integer; time:float; executestate:string; stringregister:string` |
| `TScenarioTriggerAction[16]` (`0x1855c0`) | `id, triggerid, flagid, counterid, timerid, groupid, groupidtrg, zoneid, objectiveid, queryid, bactive, bstate, usecounterid, busecounterasamount, busecounterastime, player, playertrg, resource, amount, countryid, unitid, upgradeid, formationid, marker:integer; time, radius, direction:float; executestate, stringregister:string` |
| `TScenarioTrigger` (`0x185600`) | `name:string; bactive, bexists, btriggertreeopen, bconditionstreeopen, bactionstreeopen:boolean; conditions:TScenarioTriggerCondition[8]; actions:TScenarioTriggerAction[16]; activetime:float` |

Source-side cardinalities (OBSERVED, `data/scripts/lib/classes.script:6206-6221`):
512 triggers, 32 objectives, 256 flags, 256 counters, 32 timers, 255 groups,
256 zones, 256 queries, 256 results, 64 result-triggers; 8 conditions and 16
actions per trigger. `TScenarioObjective` =
`name/langtable/langkey:string, gametime:float, bvisible, bdone:boolean`
(`classes.script:6697`). **D-12 DEFERRED** beyond these declarations.

### 4.1.2 Global-variable blobs: `gMap` and `gScenario`

`bonmis1.map:0x18c0c2` (`ev_61d0e055…`):

```
0018c0c2  04 00 00 00 67 4d 61 70 04 00 00 00 54 4d 61 70   ...gMap...TMap
0018c0d2  0d 00 00 00 c8 01 00 00 ce 01 00 00 07 00 00 00   ................
0018c0e2  62 6f 6e 6d 69 73 31 00 00 00 00 00 00 00 00 f9  bonmis1.........
0018c0f2  08 a1 44 00 00 00 00 00 00 00 00 03 00 00 00 02  ..D.............
0018c102  00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00  ................
```

`bonmis1.map:0x5321f2` (`ev_42e1d914…`):

```
005321f2  09 00 00 00 67 53 63 65 6e 61 72 69 6f 09 00 00  ...gScenario...
00532202  00 54 53 63 65 6e 61 72 69 6f 61 00 00 00 d0 a1  .TScenarioa.....
00532212  14 00 a2 e0 14 00 00 01 00 00 00 00 00 00 00 00  ................
00532222  00 00 00 00 0b 00 00 00 62 6f 6e 6d 69 73 31 2e  ........bonmis1.
00532232  6d 61 70 04 00 00 00 2e 62 6d 70 04 00 00 00 2e  map.....bmp.....
00532242  6c 6e 67 07 00 00 00 62 6f 6e 6d 69 73 31 0c 00  lng....bonmis1..
00532252  00 00 62 6f 6e 6d 69 73 31 2e 6e 61 6d 65 13 00  ..bonmis1.name..
```

* `lp("gMap") lp("TMap")` then **3 u32**: `version/sizeA/sizeB` =
  `13 / 456 / 462` for bonmis1; then `lp(name)` and scalar payload.
* `lp("gScenario") lp("TScenario")`, then a **1-byte class tag** (`0x61` for
  bonmis1/engmis4/battle1, `0x5f` for `scemis8`) and 2 u32 that look like
  buffer-size markers (`0x14a1d0 / 0x14e0a2` for bonmis1); then `lp` strings
  `bonmis1.map`, `.bmp`, `.lng`, `bonmis1`, `bonmis1.name`,
  `bonmis1.description`, `VERY_HARD`, … . **The 1-byte tag and the u32 pair are
  OBSERVED but their semantics are UNVERIFIED.**
* Note the apparent off-by-one: prefix says 9 but the bytes after it read
  `TScenarioa` (10 chars). Do not write a parser that trusts the prefix without
  checking; V7-83 observed the same byte.

### 4.2 `.aix` — plain text grammar

OBSERVED across **all 65** files: 7-bit ASCII (0 bytes >127, 0 NUL), CRLF, no BOM
(Python census + audit §3.2 for the DLC subset; Craft Anything `core_text_read`
on `engmis4.aix`, `ev_f8c01c09…`). No compression, no header, no binary section.

Grammar (mission sidecar):

```
section.begin
   Name = Initial | <state/procedure name> | ach
   UsedFileName =            (optional; editor.aix uses .\scripts\editor.inc\…)
   Code : struct.begin
      [*] = ;<Pascal-like statement, stored verbatim as text>
   struct.end        (or single-line `Code[*] = ;…`)
section.end
...
section.begin
   CurrentState =
   SaveVariables = False
section.end
```

* The `[*] = ;…` prefix is the OSW script serialization of a source line; the
  game's own statements are readable (e.g. `engmis4.aix:5-27` defines player
  constants, unit build times and farm amounts; `tutmis1.aix:34-52` sets a
  general's 1500 HP; `ausmis1.aix:25-37` sets 20000 wall HP).
* `scripts/editor.aix` is the same dialect but a **registry**: 173
  `Name =` + `UsedFileName =` pairs pointing at `scripts/editor.inc/*`, e.g.
  `OnAutoRunEditor → .\scripts\editor.inc\onautoruneditor.inc`,
  `GenerateMap → .\scripts\editor.inc\generatemap.inc`.
* Binding to a map is **by basename** (`bonmis1.map` ↔ `bonmis1.aix`); only
  48 of 87 maps have a mission sidecar (30 base + 18 DLC). `.aix` carries
  *state/procedure scripts*, **not** the objective arrays — those live in the
  `.map` `gScenario` blob (§4.1.2). D-12 DEFERRED for translation.

### 4.3 `.cdx` — protected PE variant, not a map/editor data format

OBSERVED (PE headers parsed with Python; Craft Anything triage of `editor.cdx`,
`ev_44180771…`, calls it `pe`/`executable`/x86/32/Delphi-or-C++Builder,
`.bind` entropy 7.96, stripped):

| Pair | File size | `e_lfanew` | `.exe`/`.dll` entry RVA | `.cdx` entry RVA | `.bind` VA |
|---|---:|---:|---:|---:|---:|
| `cossacks.exe` / `.cdx` | 5,768,048 | 0x100 | `0x004f1a08` | `0x0056c310` | `0x0056c000` |
| `editor.exe` / `.cdx` | 7,874,416 | 0x100 | `0x006259b8` | `0x0076f310` | `0x0076f000` |
| `config.exe` / `.cdx` | 4,645,744 | 0x100 | `0x003ed85c` | `0x00458310` | `0x00458000` |
| `modman.exe` / `.cdx` | 4,463,984 | 0x100 | `0x003c5648` | `0x0042c310` | `0x0042c000` |
| `steam_api.dll` / `.cdx` | 213,072 | 0x108 | `0x0000b68d` | `0x0000b68d` | — (5 sections) |

Full-file byte diff of each pair (DERIVED, verified twice):

* 4 game tools: **exactly 3 differing bytes**, all at `0x0128..0x012a` — the
  low 3 bytes of `AddressOfEntryPoint` in the PE optional header. All section
  tables, sections, imports and resources are byte-identical; no overlay in any
  of them. `cossacks.exe:0x128` = `08 1a 4f 00` (`ev_00fea748…`),
  `cossacks.cdx:0x128` = `10 c3 56 00` (`ev_555104b9…`),
  `editor.cdx:0x128` = `10 f3 76 00` (`ev_8058d32e…`).
* Every `.cdx` entry is `.bind VA + 0x310`; the packed stub is already present
  in the `.exe`. `.cdx` = same binary with entry redirected into the stub
  (INFERRED: copy-protection / bound build). No data tables of interest live in
  `.cdx` — use the matching `.exe`/text config for donor truth.
* `steam_api.cdx` differs in **11 bytes** at `0x2d6a4`: ASCII import name
  `CODEX` → `SHELL32.dll` (`ev_29bf422a…` / `ev_2ae3ea41…`), same length:
  ```
  steam_api.dll:2d6a4  43 4f 44 45 58                 CODEX
  steam_api.cdx:2d6a4  53 48 45 4c 4c 33 32 2e 64 6c 6c  SHELL32.dll
  ```
* **Do not run or unpack any of these PEs** (standing constraint). The stub is
  static-only here; its runtime behaviour is UNVERIFIED.

---

## 5. Grid / tile semantics

### 5.1 Dimensions and block header (OBSERVED, all 87 maps)

`TerrainMapBegin` is stored as `int32 15 | "TerrainMapBegin"`. The four u32
immediately after the 15-byte name are, at
`C:\Games\Cossacks 3\data\maps\missions\bonmis1.map:0x8d8a8c`:

```
008d8a8c  40 01 00 00 40 01 00 00 04 00 00 00 40 00 00 00
           W=320         H=320         subTiles=4    opaque=64
```

| Observed `(W,H)` | Maps | Examples |
|---|---:|---|
| 320×320 | 80 | bonmis1, engmis4, 31 base maps and all 49 DLC maps (no DLC map exceeds 320²) |
| 384×384 | 3 | battle1, battle3, battle8 |
| 512×512 | 3 | battle2, battle4, battle5 |
| 640×640 | 1 | battle7 |

Field 3 is **4 in all 87 maps** (supports "4 sub-tiles per cell", INFERRED).
Field 4 is either `64` (53 maps) or `25920` (27 maps) with no correlation to
the 7/13 schema version (DERIVED cross-tab: 7/64 ×37, 7/25920 ×23, 13/64 ×18,
13/25920 ×9) → **DEEPDEC's "tile size in px" reading is refuted as universal**;
treat as opaque.

### 5.2 Height grid (OBSERVED)

Anchor: after `TerrainMapBegin`, find the **second** `u32 W,u32 W` pair, read
`f32[W*H]` from `+8` (`bonmis1:0xa68acd`, `engmis4:0xa3353c`,
`battle1:0x1f21d1e`). Re-derived by our own reader (independent of V7-83):

| Map | W×H | min / max (m) | dominant values | cells < −0.5 | cells > 2.5 |
|---|---|---|---|---:|---:|
| bonmis1 | 320² | −2.964 / +2.964 | 0 ×30,723; −1.1 ×18,794; +2.964 ×3,202 | 36,742 | 8,314 |
| engmis4 | 320² | −2.964 / +2.964 | 0 ×64,205; +2.964 ×8,628 | 10,278 | 11,000 |
| battle1 | 384² | **−1.100 / +2.3712** | 0 ×56,015; −1.1 ×23,856; +2.371 ×913 | 38,670 | **0** |

`−1.1` is donor `cWaterHeight` (`texturemap.inc`), `+2.964` is
`cPlateauHeight`; the battle map's different clamp shows ±2.964 is **not**
universal (correction to DECOMP-06). Row orientation and metres-per-cell remain
UNVERIFIED (do not change `TILE_M` on this evidence).

### 5.3 The 37-byte tile/attribute record (OBSERVED layout; INFERRED labels)

`bonmis1.map:0xacd4c9`, 102,400 records × 37 B (same as DEEPDEC-05/V7-83):

```
00 00 00 00 00 FF FF 00 61 61 5D 5D 89 00 00 00
00 00 80 3F ×4   00 00 00 00 00
└0-4┘ └5-6┘7 └8-11 tile ids┘12 └13-15┘ └16-31 1.0f×4┘ └32-36┘
```

Counts/histograms for **sub-tile position 0** (byte 8) from our reader:

| Map | distinct ids | top ids (`id:name:count`) |
|---|---:|---|
| bonmis1 (320²) | 43 | `0 grass1:25029`, `79 test8:12187`, `78 test7:9864`, `25 sand9:7305`, `98 sandsea6:5135`, `93 sandsea1:3738` |
| engmis4 (320²) | 50 | `0 grass1:19606`, `79 test8:9243`, `78 test7:9032`, `25 sand9:8133`, `10 ground1:6226`, `93 sandsea1:5512` |
| battle1 (384²) | 15 | `97 sandsea5:62850`, `121 ground1_winter:40377`, `116 grass6_winter:7984`, `98 sandsea6:7812`, `107 test23:7396`, `93 sandsea1:7217` |

(These are ~¼ of V7-83's all-four-position counts, as expected; names are
ordinals into donor `tiles.lib` mirrored by repo
`variant3d/assets/terrain/structs/tileblocks.json` — OBSERVED mapping.)

**Methodological self-correction:** a naive cross-tab of byte-8 tile id against
`height[i]` gives weak correlation (e.g. grass1 has 11,382/25,029 water cells
in bonmis1). That is expected — one 37-B record covers a 2×2 sub-tile block, so
tile id and height cell are **not** 1:1. Do **not** derive shoreline rules from
that cross-tab.

### 5.4 Shore / rock / forest tile choice — donor rule (OBSERVED source)

`data/scripts/common.inc/texturemap.inc` (`ev_008f0a57…` from DEEPDEC-05;
re-read here):

* `cWaterShoreHeight = -0.1` (`:31`); cells below it are water, neighbours are
  shore.
* `:426-445`: `dirX = lh-rh`, `dirY = th-bh`, normalise, `VectorAngle`, sign
  flip for `dirY<0`.
* `:474-511`: fold the aspect into **8 × 45° sectors** and select
  `sandsea1 / sandsea5 / sandsea6`.
* `:557-608`: cliff cells select `rockN`.
* Branch ends call `MapGetTileIndexByTileBlock(newtile)` → `SetTileIndex(x,y,newtex)`
  — the stored 4 u8 ids are this pipeline's output (INFERRED, well grounded).
* Forest masks: `cGColorForest=255`, `cGColorGenForest=64`, `cGColorForestStone=192`;
  placement uses `b_frt_b_p_*`, `frt_b_p_*`, `frt_m_p_*`, `frt_s_p_*` and
  `forestType ∈ {pine/fir/spruce, mixed, leaf}`.

### 5.5 Mines / trees / starting resources in donor maps

**Encoded in `.map` (OBSERVED).** GameObject categories from our parse of
`lp("GameObjectBegin")` + following `lp(category)`:

| Map | objects | env | units | buildings | misc |
|---|---:|---:|---:|---:|---:|
| bonmis1 | 7,742 | 7,306 | 396 | 39 | 1 |
| engmis4 | 12,711 | 10,864 | 1,688 | 158 | 1 |
| battle1 | 10,118 | 4,295 | 5,821 | 0 | 2 |

Top `env` types (counts, first type after `GameObjectBegin`):

* bonmis1: `pine1` 926, `firsmall1` 898, `pinesmall1` 781, `plantain` 719,
  `fern` 614, `spruce1` 332, `chamomile.1` 263, `fir` 234, `pinedry1` 233.
* engmis4: `pine1` 1447, `plantain` 1158, `firsmall1` 1054, `pinesmall1` 864,
  `spruce1` 659, `fern` 630, `oak` 445.
* battle1: `spruce1` 625, `firsmall1` 510, `pinesmall1` 460, `pine1` 449,
  `pinedry1` 332, `fern` 287, `smallstonessea` 233.

So **trees are individual `env` objects**, not just tile ids, and their mix is
season-dependent. DEEPDEC-05's `minegold`/`smallstones*` strings are present as
lp strings in the file but our category parse did not surface a standalone
`mines` category — actual resource objects appear to be generated by patterns
rather than a separate GameObject category (UNVERIFIED classification).

**Generator-side placement rule (OBSERVED source, `dogenerate.inc`):**

* `SetupMines(pointx,pointy,minround,maxround,minesdensity,spcount)` (`:522-717`):
  `minesdensity 0/1/2 → rounds 3/4/5`; for each round and each of `mng` (gold),
  `mni` (iron), `mnc` (coal) — prefixed `desert_` in desert — choose a pattern
  from `generator.cfg`'s list and place with `trycount = 256`, random angle
  `RandomExt*360`, radius per round/version (current build example for ≤4
  players on a normal map: `14+8r, 32+10r, 70+12r, 22+16r`, ring 5 skipped;
  older versions use 36/50/88/24… variants). Larger ring 2 mines may be moved
  to the map corner quadrant (`±maphW∓24, ±maphH∓24`) for ≥`gRecordGeneratorVersion 90`.
* `SetupStartingResources` (`:720+`): one `stoneforests`/`desert_forests_big`
  pattern at `min(cCircle1MaskX,cCircle1MaskY)=5` + jitter, then one
  `stones`/`desert_stones` pattern outside an ellipse
  `cCircle2MaskX/Y = 12`; 128 tries, 3 inner tries, `CheckStandPatternExt`
  validates placement, `PatternIncreaseFreq` updates weights.
* Forest families in `generator.cfg`: `forests_pinefir_big|medium|small`,
  `forests_spruce_big|medium`, `forests_pine_*`, `forests_mixed_*`,
  `forests_leaf_*`, `desert_forests_*`, `stoneforests(_old)` — each with
  `Pattern=… / Freq=…` entries. This is directly reusable as a weighted
  forest-piece table.

---

## 6. Corrections to prior docs (explicit refutations)

1. **DD "numeric grid opaque / exact geometry CLOSED" — REFUTED.** Height
   grid, 37-B tile records, named coordinate array and entity records are all
   decodable from on-disk bytes (DECOMP-06, V7-83, DEEPDEC-05, re-derived here
   on 3 independent maps). Remaining opacity is the ~1.6 MB pre-grid region and
   the post-grid gaps, not the terrain itself.
2. **DECOMP-06 "±2.964 m in all maps" — CORRECTED.** `battle1.map` (384²) has
   max +2.3712 m and no >2.5 m cells; its water sentinel is still −1.1.
3. **DECOMP-06 "8,777 records × fixed 31 B" — REFUTED** (already by V7-83):
   record size is `24 + nameLen` (28–32 B); declared counts match parsed
   counts in all three sampled maps.
4. **DEEPDEC-05 "field 4 probably tile size 64 px" — REFUTED as universal.**
   27 of 87 maps store `25920` there; field is opaque.
5. **Our own first tile-grid detector started one record late**
   (`bonmis1:0xacd4ee` because record 0 lacks the `FF FF` marker); true start is
   `0xacd4c9` (= detector hit − 37). Histograms in §5.3 are for position 0 of
   record 1 onward; difference is one cell out of 102,400. V7-83's anchors
   (`0xacd4c9`, `0xa97f38`, `0x1fb291a`) are correct.
6. **DA_PE "six donor PE files" — REFUTED.** Full recursive MZ/PE check finds
   **19** PEs, including `editor.exe`/`editor.cdx` and `modman.exe`/`.cdx`,
   which DA_PE omitted. `editor.*` is the donor's map/scenario editor and is
   explicitly in the investigation brief's target list.
7. **DA_PE "`cossacks.cdx` entry `0x96c310`" — CLARIFICATION, not error.**
   `0x96c310` is the *virtual address* (`imagebase 0x400000 + RVA 0x56c310`);
   the PE field at `0x128` stores the RVA `0x56c310`.
8. **DD/audit "DLC `.aix` are UTF-8" — SHARPENED.** All **65** `.aix` files are
   7-bit ASCII with CRLF (UTF-8 only by subset), sizes 258–124,060 B; the
   393–833 B range describes only the 18 DLC mission sidecars.
9. **`random.cfg` is not the seed.** It contains `field = fax`; the skirmish
   seed lives in `gMap.settings.gen.randkey0/1` (§7.1).

---

## 7. Skirmish-relevant implications

### 7.1 Seed and parameter representation (donor truth)

The chain is entirely in text scripts + `.map` schema (OBSERVED):

* `data/gui/menu.inc/donewgame.inc:16,33-35`: `GenerateMapRandKey(gMap.settings.gen.randkey0, randkey1)`;
  `SetRandomExtKey64(k0,k1)`, `SetMapGeneratorRandomKey(k0,k1)`,
  `SetGlobalMapGeneratorRandomKey(k0,k1)`.
* `donewgame.inc:37`: generated map name
  `'game_v'+IntToStr(gDataVersion)+'k'+IntToStr(GetRandomKey)+'.map'` — the
  key is embedded in the runtime map filename.
* `donewgame.inc:39-47`: `mapsize` enum `0→320, 1→480, 2→640, 3→256` (note:
  shipped maps are 320/384/512/640 — the enum is a *preset selector*, not the
  on-disk W; do not equate them).
* `donewgame.inc:95-123`: `season < 0` means random; choices `0` (summer),
  `2` (winter), `3` (desert), gated by `lastknowndlcs`; if neither winter nor
  desert DLC: `0`.
* `donewgame.inc:166`: `GenerateMapNeededExtBorder(genMapName, 'Default',
  'Default', genMapSize, genMapSize, genCells=1, randkey0, randkey1, 0,
  season, 0, '', …, cGuiCfgPath, '', 'light0', '', cInitState='InitMapGen', false)`.
* `data/scripts/lib/map.script:248-255,322-328`: quickplay/default sets
  `season=0, relieftype=3, resourcestart=2, resourcemines=1, teams=1`,
  peacetime 15 s, capture `nopeasants`, gamespeed 2 (MP) or profile value;
  then reseeds from `randkey0/1`. `initmapgen.inc:99,146` reseeds again before
  and after country selection.
* `initmap.inc:29-31,72-73,86`: same defaults plus `xoff=35, yoff=-14`
  (INFERRED: symmetric start offsets), `_misc_GetMapLeftTopPos`,
  `TopologyBuild`, `_misc_BuildIslandsGrid`.

**Concrete seed-like values in `.map` (OBSERVED bytes, INFERRED identity).** The
`gMap` payload begins with a version tag and two size u32s, then `lp(name)` and
scalar fields. A single large 4-byte value (hundreds of millions to >1e9) is
visible near the start of every map's payload:

| `gMap` version tag | maps | observation | example |
|---:|---:|---|---|
| 13 | 27 | large u32 at **aligned payload word index 2 in all 27** | `bonmis1` = `0x44a108f9` = 1,151,404,281 at `0x18c0f1` |
| 7 | 60 | large value at word indices 3, 4 or 7 by map family, **but alignment varies** | `polmis1` = `0x5a13a403` = 1,511,236,611; `scemis8` = `0x1ec48885` = 516,196,485 at `0xbf840`; `battle1` bytes `61 1d 94 4a` (`0x4a941d61` = 1,251,220,833) sit at payload byte `+30`, i.e. *not* 4-byte aligned |

The version-13 regularity supports reading that word as `randkey1`, and the
values are consistent with `GetRandomKey` being a 32-bit key, but the
**byte-to-field mapping for version-7 maps is UNVERIFIED** (odd alignment shows
the payload contains variable-length fields before the seed). `randkey0` is 0
in the first scalar slots of every sampled map (INFERRED from position). Do not
feed these numbers into a Godot RNG until the mapping is confirmed against a
known generated `game_v…k….map` from the donor (none is shipped).

### 7.2 What the map generator can learn now (for terrain piece tests)

1. **Tile vocabulary is finite and seasonal.** 320² summer maps use 43–50
   distinct tile ids, dominated by `grass1/test8/test7/sand9/sandsea*`; the 384²
   winter battle uses winter ordinals (`ground1_winter`, `grass6_winter`) plus
   `sandsea5`. Use `tileblocks.json` ordinals as the id dictionary; do not
   reuse the 124-name summer atlas for winter ids.
2. **Shoreline is a 8-sector aspect rule, not a random band.** Implement
   `dirX=lh-rh, dirY=th-bh`, 8 sectors, `sandsea1/5/6` for shores, `rockN` for
   cliffs, threshold −0.1 — this is donor-authored and cheap to port.
3. **Forest is two layers:** tile ids for ground cover (`grass_rock*`,
   `test*`) and individual `env` GameObjects for trees (`pine1`, `firsmall1`,
   `pinesmall1`, `spruce1`, `oak`, season-dependent). Piece tests should assert
   both layers, and use `generator.cfg` forest-family `Freq` weights rather
   than uniform random tree species.
4. **Mines are rings around starts, not uniform scatter.** Pattern-lists
   `mng/mni/mnc` (+`desert_`), 256 placement attempts, radii 14–70 m (with
   version gates), three resource types per ring; starting stone/forest at
   radius ~5 and ~12 around each player. A skirmish generator can reproduce
   this deterministically from `(randkey0, randkey1)`.
5. **Grid sizes:** read W/H from the map header (320/384/512/640 shipped);
   4 sub-tiles per cell always. The generator presets 320/480/640/256 are not
   the same set as shipped map sizes.
6. **Height values already fit the port's dump schema** (`heightmap_splat.py`
   base64 LE f32; V7-83 proved schema consumption). Use donor-derived dumps for
   terrain-piece A/B, but do not claim visual parity or change `TILE_M`.
7. **No fog/explored grid was identified**; keep the port's own fog model.

---

## 8. Open questions

1. Exact byte-to-field mapping of `randkey0/randkey1` for version-7 `gMap`
   blobs; meaning of the 1-byte `TScenario` tag (`0x61`/`0x5f`) and the two
   following u32 markers.
2. Meaning of the 1.64 MB sparse pre-grid region and the 2,556/≈13 KB gaps —
   fog/explored, collision, or unwritten arrays? (UNVERIFIED, unchanged.)
3. Height-grid row orientation, and the metres-per-cell question
   (`TILE_M = 2.0` vs ≈1 m inferred from coarse named records) — needs an
   in-engine A/B, not a byte argument.
4. The opaque 4th terrain header field (`64` vs `25920`).
5. Runtime consumer of the variable-length `xNyM` coordinate records
   (`f0/f1/f2 = 2,2,-0.5`; `world = 2*index-(N-1)`).
6. Full `GameObject` field layout past `player0` (rotation/scale/mesh binding),
   and whether resource objects use a distinct serialization in
   `GameMapRecord` rather than `Players`.
7. Whether `editor.cdx`'s `.bind` stub can be statically characterized without
   executing it (currently only entropy/section facts are known).
8. Trigger/objective runtime semantics, condition/action id enums and
   `gScenario` blob decoding — **D-12 DEFERRED**.
9. Which donor mission (if any) produced `app/shots/g32_dump.json` (still none).

---

## 9. Evidence index

Craft Anything evidence ids from this pass (Deep mode, donor read-only):

| id | Establishes |
|---|---|
| `ev_44180771c0700c4a97383ffbe5bca42a667990158e00799294540f25760bb98e` | `core_target_triage` of `editor.cdx`: PE/x86/Delphi hints, stripped, `.bind` entropy 7.96, entry `0xb6f310` (VA) |
| `ev_929a8fca68b283624d6efe4cfb1e9ffd10cf0ee081c871eed6096ba88f1e56be` | `bonmis1.map` triage: `kind: unknown`, 23,447,543 B (same id DECOMP-06 obtained) |
| `ev_1756c8df88b598b6776981588f041da2c01347a9dcea5113d67765f844db8d84` | `TMapSettingsGen` at `bonmis1.map:0x182640`, `0x182866` |
| `ev_61d0e05568260c5a05411a3359d2fe63805ae174d15b59311023c0bb63a3d642` | `gMap` at `bonmis1.map:0x18c0c6` |
| `ev_42e1d914914d4c061c9fb5d6ba4c17d2e3daee71d62e6e8a97e7761894220761` | `gScenario` ×51, first at `bonmis1.map:0x5321f6` |
| `ev_e1dd42c0ecc8e3e9bd650e895fd5289baaa9848488ba6e971ab62dce051ac272` | `TerrainMapBegin` at `bonmis1.map:0x8d8a7d` |
| `ev_ef6329ee0ebfe4bfa9b04af95cc56e13c195e5b718b4669da5ffeffdc53171be` | `randkey0` schema field at `bonmis1.map:0x18265c` |
| `ev_8ea530aae41946ac85bc0a85479051a9f14fcafae3e015b69ea8c3693359ff6c` | `GameObjectBegin` ×7,742 in `bonmis1.map`, first `0xebd0f0` |
| `ev_00fea74812312b3847fd44bffac20625499bcfabb59db41d29c970319a436e51` | `cossacks.exe:0x128` = `08 1a 4f 00` |
| `ev_555104b97cabfd7425250e5919e18e6017499cec59432f1215220a75548a7f59` | `cossacks.cdx:0x128` = `10 c3 56 00` |
| `ev_8058d32eed7c603558a855c63070d92a888862ad492db4ec161cb621eb7b10ce` | `editor.cdx:0x128` = `10 f3 76 00` |
| `ev_2ae3ea41b035332fa227747995f42abc8e9746a35a9c662a168faffcfbbacb04` | `SHELL32.dll` in `steam_api.cdx:0x2d6a4` |
| `ev_29bf422a500be5015be2b810f55cd31ed59739e70d97b1d17c5b7f5b1fb92495` | `CODEX` in `steam_api.dll:0x2d6a4` |
| `ev_f8c01c09f92567e1f8c9ba87793e570fe14242798791e7d4f029b42ffe079afb` | `engmis4.aix` text (78 lines) |
| `ev_d3109970dffecc3ebac9bfe45c88605f531d20a5632440c1306391fef7ba50ef` | `random.cfg` = `field = fax` |
| `ev_533c083d35d1cf95b7fc5ac4762b4695a7f46ef21912e49bcb992dde7f14ab2e` | `generator.cfg` text, 2,367 lines, 64 non-UTF-8 byte sequences |
| `ev_a75ae1387dbd9d2c8526fff7d2187004e579e2b756240c235db1b9974abca550` | `scripts/editor.aix` text (state registry) |
| `ev_6c7e26a70cef6bfe198db72d67815e4fcb1d8548bb34c8455c1f731c7ee338f6` | `project.main.prj` text (`BuildVersion 2.2.3`, `SVNVersion 6008`) |
| `ev_008f0a5704e55c254bd82c8edd2bd11ac9b563857a4a524d144b7569847b4418` (DEEPDEC-05) | `texturemap.inc` shore/rock/forest rules; `tiles.lib` ordinals |
| `ev_0d087bb72d524b54c2bbd50d6c04ba70b65bd225dce3aa280664acb531288090`, `ev_b526c8821a3fd877bd5bae3ee0021df4f107896543ce9a9ed583887a81fd885e` (investigation fnd_1) | world scale constants 26.666 px/m, 53.333 px/tile (do not reconcile with `.map` scale here) |

Rejected with no id: `core_packed_files_list` on `bonmis1.map`
(`not_supported` — flat stream). Three findings were recorded in the shared
Craft Anything investigation with the derived/DERIVED labels used above.

**Python-derived (no evidence id, reproducible):** all byte offsets/histograms
in §§3–7 were computed from read-only `Path.read_bytes()` / `mmap` over donor
paths, with analysis scripts kept outside the repo at
`%TEMP%\opencode\dec06_survey.py` and `dec06_gmap.py` (not committed). Every
numeric claim in §5 was re-run on a second map before being written; the
`.cdx` byte-diff was re-run on all five pairs.

---

## 10. Summary

* `.map` is a flat, **uncompressed**, 7-bit-ASCII length-prefixed Delphi stream.
  Its height grid, tile grid, named coordinates and typed entity records are
  readable; the RTTI-like schema block gives exact field names for the skirmish
  settings (`randkey0/1`, `mapsize`, `terraintype`, `relieftype`,
  `resourcestart`, `resourcemines`, `startx/starty`) and for the 512-trigger /
  8-condition / 16-action scenario model (D-12 deferred).
* `.aix` is plain text in all 65 files; mission sidecars are named scripts
  keyed by basename, while `scripts/editor.aix` is a 173-entry state→`.inc`
  registry. Objectives are **not** in `.aix`.
* `.cdx` is not a document format: five PE32 files byte-identical to their
  `.exe`/`.dll` twins except the redirected entry point (and one import-name
  swap in `steam_api.cdx`). `editor.cdx` exists but carries no extra data.
* The skirmish seed is a 64-bit key pair generated by `GenerateMapRandKey`,
  seeded into three RNG entry points, and passed explicitly to
  `GenerateMapNeededExtBorder` along with size, season, zone and preset;
  shipped maps store concrete large u32 values in the `gMap` payload, with
  their exact field position still UNVERIFIED for version-7 maps.
* For today's terrain-piece tests, the highest-value donor truths are the
  8-sector shoreline rule, finite seasonal tile-id vocabularies, two-layer
  forests (tile + `env` objects), and ring-based mine/resource pattern
  placement — all usable without committing any donor bytes.

**Compliance:** no donor file copied, modified or executed; no repository file
other than this report written; no code, asset, test or git change.
