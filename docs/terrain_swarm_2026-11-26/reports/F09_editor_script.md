---
id: F09
ticket: "TERRAIN-SWARM-2026-11-26 / Wave F / F09"
title: "Donor DScript/editor terrain API — editor.aix, editor.inc/** and data/scripts/** command surface"
agent: "F09 (worker subagent)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_DONOR_BINARY__NO_RUNNER_JOB
owner_file: docs/terrain_swarm_2026-11-26/reports/F09_editor_script.md
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_guard: "No donor GPU A/B frame exists. Every quoted donor line is [O] text; every semantic reading is [D]/[I]; any port consequence is PORT APPROXIMATION. No donor parity claim is made."
scope: "Exactly one repo file written: this report. Donor at C:\Games\Cossacks 3 opened read-only; no donor executable run, no donor binary copied into the repo, no source/shader/config/asset/test/git edit, no Godot runner job."
---

# F09 — Donor editor / DScript terrain API

## 0. Executive summary

1. **[O]** The donor script language is **DScript**: Delphi-like statements stored as passive text. `.aix` files are *state→handler registries*; `.inc` files wrap code as `[*] = ;<line>` entries inside `struct.begin … struct.end`; `.script`/`.global`/`.source` files contain the same statements bare. `editor.aix` has **173 `Name =` records**, `scripts/editor.inc/` has **142 files**, `data/scripts/` has **222 files**; the corpus-wide keyword index covered **367 text files / 109,581 logical lines**.
2. **[O]** The terrain engine API is **not declared in any donor text file** — it is a set of native calls invoked from script. This report recovers the terrain-relevant native call names (grouped into 22 rows in §2.1) and ~20 DScript helper procedures/functions (§2.2) from their call sites, with exact argument order and all literal defaults found. Formal parameter *names*, type signatures and internal kernels are **[U]** (no declaration, no binary study in this lane).
3. **[O]** The skirmish random-map terrain path is a two-file chain: `data/scripts/common.inc/dogenerate.inc` (orchestration, starts, mines, pattern passes) → `data/scripts/common.inc/generatemap.inc` (mask decode, height field, 3 smoothing groups, water fields, tile/texture passes). The editor has **parallel** scripts with the same state names (`editor.aix:763-787`) that are *not* the same code: `scripts/editor.inc/generatemap.inc` is a 9-line stub calling `MapExecuteState('DoGenerateMissionMap')`.
4. **[O/D]** The **UserTerrain BMP import** is fully visible in `scripts/editor.inc/generatemapfrombitmap.inc` (registered as `GenerateMapFromBitmap_OLD`, `editor.aix:710`): 3-channel RGB mask classes `cPlateau=1, cSmooth=2, cPlateauSmooth=3, cWater=4, cForest=5`, fixed **320×320**, `cPlateauHeight=2.964`, `cWaterHeight=-1.1`, then `SmoothTerrain`, water fields, texture, `MapGeneratorSmoothTiles`, topology.
5. **[O]** Brushes named in the editor manual — relief raise/lower, road polygons (`Cubic/Squad/Smooth/Road1..3`), water draw/remove, glints, current arrows, snow tool, mine/farm/campfire placement — have **zero occurrences** in the assigned script corpus. They are native `editor.exe` UI handlers (cross-check D09_editor_binary.md). **[U]** Their parameters cannot be recovered from text; the S2–S4 manual descriptions remain the only source and are not re-verified here.
6. **[O]** Seeding is explicit and repeated: `SetRandomExtKey64(k0,k1)` in `generatemap.inc:216,513,774`; `SetRandomKey(randkey1)` re-issued before each generation stage in `dogenerate.inc` (X03 counts 11 sites). `RandomExt` is the universal generator. A clone must preserve per-stage reseeding; **[U]** the mixing algorithm itself is not in text (D02's lane).
7. **[O]** Gaussian/noise preprocessing is **editor/authored-map only**: `generatemap.inc:507-520` runs `ExecuteState('PostProcess')` only when `not bRandomMap`; the random-map branch at `:529-531` sets `trgbitmap := srcbitmap`. The `_gauss` TGA is pre-baked offline (cross-check D03/F04). A skirmish clone must **not** add an invented runtime gaussian pass.
8. **[I]** Stage order and constants recovered here are sufficient to specify a donor-shaped pipeline, but "the retail binary actually executes these `;`-prefixed lines" remains **[U]** for every quoted line (shared caution with D03/D06/X03). No runtime claim is made.

---

## 1. Evidence table

Line numbers are **physical donor line numbers** after unwrapping `[*] = ;` from `.inc` code lines. Paths are relative to `C:\Games\Cossacks 3\` unless absolute.

| Id | Donor path:line | Observation (quoted / paraphrased) | Label |
|---|---|---|---|
| E01 | `scripts\editor.aix:1-4, :710, :722, :728, :763, :769, :775, :841, :853` | `section.begin` / `Name = OnAutoRunEditor` / `UsedFileName = .\scripts\editor.inc\onautoruneditor.inc`; terrain states resolved to editor `.inc` files | [O] |
| E02 | `scripts\editor.inc\generatemap.inc:2-9` | `Name = GenerateMap` → `MapExecuteState('DoGenerateMissionMap')` — editor stub, not skirmish `GenerateMap` | [O] |
| E03 | `scripts\editor.inc\generatemapfrombitmap.inc:4-7, :21-40, :42, :44-80, :91-105` | UserTerrain form, `randkey0=13`, `randkey1=10`, `.\data\gen\bitmap\bitmapsrc.bmp`, 320×320 guard, `SetRandomExtKey64`, mask class constants, stage flags | [O] |
| E04 | `scripts\editor.inc\generatemapfrombitmap.inc:142-172, :189-236, :242-278, :280-328, :341-364` | RGB channel tests → mask classes; height formula; `SmoothTerrain`; custom smoothing; 2×2 water fields; texture/smooth/topology states | [O] |
| E05 | `scripts\editor.inc\generatewaterfields.inc:4-21, :28-40, :47-70, :100-113` | 128×128 guard, `cWaterHeightVisible=-0.834`, `cBaseWaterSettingsOffset=0.52`, plain flatten band, water fields | [O] |
| E06 | `scripts\editor.inc\scaleplateauterrain.inc:4-9, :22-43` | `cLerpMin=0.5`, `cLerpMax=1.0`, `cMaxHeight=3.2`, `Pow(...,1.25)` | [O] |
| E07 | `scripts\editor.inc\textureterrain.inc:17-33, :50-113, :231-235, :239-342` | 7-stage texture pass, `cMaxHeight=2.96`, `cWaterHeight=-0.25`, `cWaterShoreHeight=-0.1`, cliff tile choice by gradient angle + height | [O] |
| E08 | `scripts\editor.inc\plateaugenerator1.inc:4-23, :119, :247, :293-313` | 17-unit grid plateau auto-tiling with `box_*` patterns, `PlateauTerrain` reset | [O] |
| E09 | `scripts\editor.inc\plateaugenerator3.inc:4-33, :35-47` | `DrawLineWithPattern`, brush patterns `brush_plt_*`, `PlateauTerrain` + `PaintTerrain` reset | [O] |
| E10 | `data\scripts\common.inc\generatemap.inc:4-32, :34-54, :61, :139-143, :171-195, :216, :261-279, :505-534, :567-574, :580-644, :646-707, :711-798` | Skirmish height/color constants, flags, mask folder pick, RGBA decode, height formula, smoothing chain, water fields, tile passes | [O] |
| E11 | `data\scripts\common.inc\dogenerate.inc:14-78, :407-416, :428, :466-481, :499-519, :522-654, :720-783, :980-988, :1330-1359, :1538-1565, :1572-1581, :1613-1650, :1688-1741, :1757-1773, :2075-2100` | Mask helpers, keep-clear ellipses, `SetupMines`, `SetupStartingResources`, relief table, frequencies, pattern passes, season color tables | [O] |
| E12 | `data\scripts\common.inc\texturemap.inc:29-47, :63-128, :426-470, :617-646` | Skirmish tile/collision thresholds, winter suffix, road tile placement via mask alpha | [O] |
| E13 | `data\scripts\common.inc\postprocess.inc:16-83, :349-442` | Gaussian kernel `Exp(-dsq/(2r²))/(PI·2r²)`, radii `0.00001` and `0.925`, noise constants | [O] |
| E14 | `data\scripts\common.inc\loadtextureterrainfrombitmap.inc:4-42` | `cLowHeight=0.1`, `tile_lowground.bmp`/`tile_highground.bmp`, `tex := r div 2`, only fills tile 0 | [O] |
| E15 | `data\scripts\lib\misc.script:3030-3072, :3325, :3384, :3516, :3568, :3634, :3681, :3931` | Border `PaintTerrain(...,86,...)`, pattern placement/check helpers with full signatures, FreqSum roulette | [O] |
| E16 | `data\scripts\common.inc\initmapgen.inc:229-239` | `ExecuteState('DoGenerate')` → `MapWorldUpdateTerrainData`, `TopologyBuild`, `_misc_BuildIslandsGrid` | [O] |
| E17 | `data\gui\menu.inc\donewgame.inc:16, :33-35, :42-49` (adjacent evidence, outside assigned tree) | `GenerateMapRandKey`, three seed setters, `mapsize`→320/480/640/256 | [O] |
| E18 | `docs\research\RC_TERRAIN.md:20-24, :96-100` (S2–S4 manual summary) | Brush/polygon/water/glint/current/snow/campfire tool names; caveat "C1/2/3 shared editor docs, not verified in running C3" | [U] as applied to C3 1.3.x |
| E19 | `docs\terrain_swarm_2026-11-26\reports\D09_editor_binary.md:19-25` | Native `editor.exe` forms/handlers for the generation UI; no DScript brush text | [O/D] cross-check |
| E20 | `scripts\editor.inc\onautoruneditor.inc:4, :23-24, :46-47, :57` | `EditorUnRegisterMenu('Script')`, `EditorRegisterMenu(..., 'GenerateWaterFields', 'F3')`, terrain save/load hotkeys, 320-tile note | [O] |
| E21 | `scripts\editor.inc\addresources.inc:4-19`, `scripts\editor.inc\createstartpatterns.inc:41-70` | Editor-only debug: 1e9 resources; fixed player buildings at start | [O] |

**Method.** Python `bytes` reads decoded `latin-1` (and `cp1251` where high bytes occur); regex unwrap of `^\s*\[\*\]\s*=\s*;`; corpus-wide keyword index; targeted full reads of the terrain subset; no Craft Anything target was opened or changed. Prior art read first: `docs/decomp/DB_SCRIPTS.md`, `docs/research/RC_TERRAIN.md`, `docs/coord_swarm_2026-11-25/decomp/DEC_02_scripts.md`, and landed swarm reports (notably X03, D03, D06, D09) for cross-check only.

### 1.1 Container syntax (exact raw lines)

`scripts\editor.inc\generatemap.inc:1-9` (raw wrapper, before unwrapping):

```
section.begin
   Name = GenerateMap
   Code : struct.begin
      [*] = ;BoolRegister0 := False;
      [*] = ;StringRegister0 := '';
      [*] = ;MapExecuteState('DoGenerateMissionMap');
   struct.end
section.end
```

`scripts\editor.aix:1-6` (raw registry):

```
section.begin
   Name = OnAutoRunEditor
   LanClientExecute = True
   UsedFile = True
   UsedFileName = .\scripts\editor.inc\onautoruneditor.inc
section.end
```

**[O]** DScript constructs observed directly: `var x : Integer = 0;`, `const cX = ...;`, `procedure P(a, b : Integer; c : Float);`, `function F(...) : Boolean;`, `begin … end;`, `if … then begin … end else …`, `case x of 0: … end;`, `for i:=0 to n-1 do`, `for [MAIN]y:=…` (named loop label for `break(MAIN)`), `array [0..N-1] of array [0..M-1] of T`, `class`, `:=` assignment, `not/and/or`, `true/false`, `''` strings, `//` and `{ … }` comments, `Result := ...`, `exit`. Types seen: `Integer, Float, String, Boolean, Byte, Word, Pointer, TColor, TPos2f, TIntegerList, class`. Register conduits: `BoolRegister0`, `StringRegister0`, `IntRegister0` (E10:61, :775; E12:47). **[I]** This is a Delphi dialect compiled/interpreted by the engine; the exact grammar/operator precedence is DEC-02's lane.

---

## 2. Findings — the terrain command catalogue

### 2.1 Native engine calls (no donor declaration exists — arity/order from call sites)

Every row is **[O]** for the literal call; the "meaning" column is **[I]** unless stated. Absence of a local declaration was checked corpus-wide for `SmoothTerrain`, `PlateauTerrain`, `PaintTerrain`, `TerrainUpdate`, `WaterFieldAdd`, `MapGeneratorSmoothTiles`.

| Command | Observed call (donor path:line) | Argument order / observed values | Working meaning | Flags |
|---|---|---|---|---|
| `PlateauTerrain` | `scripts\editor.inc\generatemapfrombitmap.inc:115`; `plateaugenerator3.inc:38`; `plateaugenerator1.inc:247`; `data\scripts\common.inc\generatemap.inc:265` (dead branch) | `(x, y, Bool, radius, Bool)`; radius `((GetMapHeight div 2)-1)` | Full-map plateau/flatten reset centred at (0,0), radius = half map − 1 | [O] call / [I] semantics; booleans **[U]** |
| `PaintTerrain` | `plateaugenerator3.inc:39`; `dogenerate.inc:477` (commented); `lib\misc.script:3057,3061,3067,3071` | **11 args**: `(x, y, tileIndex, -1, -1, False, -1, -1, radius, False, True)`; tile `0` = reset, `86` = border terrain, radius `r` or `24` | Radial tile painting / terrain reset | [O] arity; arg 4-8,10-11 semantics **[U]** |
| `SmoothTerrain` | `generatemapfrombitmap.inc:251`; `generatemap.inc:591` | `(x, -y, False, 3)` — note **y is negated** at both sites | Native neighbour smoothing, pass count `3` | [O] call; kernel/power **[U]** (D03/D06 unresolved) |
| `TerrainUpdate` | `generatemapfrombitmap.inc:276`; `generatemap.inc:641` | `(True, False)` | Commit/rebuild terrain after height edits | [O] call / [I] meaning |
| `GetHeightData` / `SetHeightData` | 51 / 7 call sites, e.g. `generatemap.inc:567-574`, `gmfb:56-68`, `generatewaterfields.inc:34-38` | `(x,y)` / `(x,y,h:Float)`; h range observed `[-3, 3.2]` | Height field read/write, float | [O] |
| `GetTileIndex` / `SetTileIndex` | `loadtextureterrainfrombitmap.inc:37,41`; `textureterrain.inc:33,318`; `generatemap.inc:268` | `(x,y,idx)` | Tile id read/write | [O] |
| `MapGetTileIndexByTileBlock` / `MapGetTileBlockByTileIndex` / `MapReplaceTiles` | `textureterrain.inc:9,317`; `loadtextureterrainfrombitmap.inc:39` | `(name:String)` → idx; `(idx)` → name; `(from,to,Bool)` | Tile-block-name ↔ numeric id mapping | [O] |
| `MapGeneratorSmoothTiles` | `generatemapfrombitmap.inc:350` (live); `generatemap.inc:784` (**commented out**) | no args | Native tile-index smoothing; skirmish uses `ExecuteState('SmoothTiles')` instead (`generatemap.inc:786`) | [O] |
| `WaterFieldsClear` | `generatemapfrombitmap.inc:314`; `generatemap.inc:687`; `generatewaterfields.inc:100` | no args | Clear water-plane registry | [O] |
| `WaterFieldAdd` | `generatemapfrombitmap.inc:325`; `generatemap.inc:704`; `generatewaterfields.inc:110` | `(name:String, x1,z1,x2,z2,h:Float)` — 2×2 cell rect + plane Y | Register one water quad | [O] |
| `MapDrawCollision` | 97 call sites, e.g. `generatemap.inc:280`, `texturemap.inc:83-128`, `generatewaterfields.inc:67` | `(x,z,tag:Integer,radius:Float,bool)`; tags `0` clear, `100` terrain/water, `101` decal, `gc_collisiontag_*` | Paint half-tile collision grid | [O] |
| `GetMapCollisionTag` / `GetMapCollisionTagInRadius` | `textureterrain.inc:124,294`; `dogenerate.inc:1314` | `(x,z,Bool)` / `(x,z,r:Float,Bool)` | Collision read | [O] |
| `StandPattern` / `StandPatternWithAngle` | `plateaugenerator3.inc:21`; `plateaugenerator1.inc:119,140`; `lib\misc.script:3390` | `(plHnd,name:String,x,z,angle:Float)`; extended form `(plHnd,name,x,z,angleRad,?,90)` | Stamp a pattern family member into the world | [O] |
| `ResetPatternMap` / `LoadPatterns` | `generatemap.inc:262,279`; `dogenerate.inc:1286-1288`; `textureterrain.inc:167,171` | `(Bool)` / `(Bool,Bool)` | Clear/reload environment pattern objects | [O] |
| `NewMap` | `generatemap.inc:77` | `(w,h,0)` | Create map of given square size | [O] |
| `SetRandomExtKey64` | `generatemapfrombitmap.inc:42,125`; `generatemap.inc:216,513,774`; `donewgame.inc:33` | `(k0,k1:Integer)` | Seed `RandomExt` with 64-bit key pair | [O] |
| `SetRandomKey` / `GetRandomKey` / `RandomExt` / `random` | `dogenerate.inc:1100,1161,1177,1213,1538,1616,1772,1909,1927`; `donewgame.inc:37` | `SetRandomKey(k1:Integer)` | Per-stage reseed generator / draw | [O] (X03 §1 counts 11 sites) |
| `ExecuteState` / `MapExecuteState` | `generatemapfrombitmap.inc:127,334,343,357,360,364`; `dogenerate.inc:1565`; `editor.inc\generatemap.inc:7` | `(name:String)` | Dispatch DScript state machine | [O] |
| `EditorRegisterMenu` / `EditorUnRegisterMenu` / `EditorFormClear` / `AddEditorFormInput` / `EditorFormExecute` / `GetEditorFormValue` / `EditorExecuteMenu` / `EditorKeyboardType` | `onautoruneditor.inc:4-47`; `generatemapfrombitmap.inc:9-16`; `editor.aix:24-25` | menus `(path,state,hotkey)`; inputs `(key,label,default)` | Editor-only UI plumbing | [O] |
| Bitmap API | `CreateBitmap`, `CreateBitmapTGA`, `LoadBitmap`, `GetBitmapSize`, `GetBitmapPixel(bmp,x,y,var fr,fg,fb,fa)`, `SetBitmapPixel`, `SetBitmapSize`, `SetBitmapFormat`, `SaveBitmap`, `FreeBitmap` | `generatemapfrombitmap.inc:131-142`; `postprocess.inc:33,421,437-445`; `loadtextureterrainfrombitmap.inc:6-32` | Source/derived mask I/O | [O] |
| `GUIMiniMapUpdate`, `RayCastHeight` | `generatemapfrombitmap.inc:372`; `plateaugenerator1.inc:313`; `dogenerate.inc:103` | no args / `(x,z)` | UI refresh, ground Y query | [O] |

**[O]** Naming caution: `MapGeneratorSmoothTiles` (native, editor BMP path) and `ExecuteState('SmoothTiles')` (script state `common.inc\smoothtiles.inc`) are **two different mechanisms** and must not be conflated (E10:784-786, E04:350).

### 2.2 DScript helper procedures/functions (declarations recovered)

| Helper (donor path:line of declaration) | Signature, exact | What it does | Label |
|---|---|---|---|
| `dogenerate.inc:8` `_misc_FillPatternMaskElipse` | `(x,y,rx,ry:Float)` | Mark ellipse cells occupied (start keep-clear) | [O] |
| `dogenerate.inc:34` `_misc_FillPatternMaskCircle` | `(x,y,r:Float)` | Circle occupancy | [O] |
| `dogenerate.inc:52` `_misc_FillPatternMaskRectangle` | `(x,y,w,h:Float)` | Rectangle occupancy | [O] |
| `dogenerate.inc:67` `_misc_FillPatternMaskMapBorder` | `(r:Integer)` | Occupy `r`-cell border | [O] |
| `dogenerate.inc:428` `_misc_GetPatternName` | `(var name:String; prefix:String; count:Integer)` | Pick `prefix+1..count` (tiled patterns) | [O] |
| `dogenerate.inc:522` `SetupMines` | `(pointx,pointy:Float; minround,maxround,minesdensity,spcount:Integer)` | Mine placement rings | [O] |
| `dogenerate.inc:720` `SetupStartingResources` | `(pointx,pointy:Float)` | Stoneforest/stone rings around start | [O] |
| `dogenerate.inc:980` `CreateStartPoint` | `(plInd:Integer; pointx,pointy:Float; minesdensity,spcount:Integer)` | C1 ellipse + mines + resources | [O] |
| `dogenerate.inc:1330` `SetupTiledPatterns` | `(const str:String)`; `const cSize = 25` at :1335 | Strict 25×25 grid stamp | [O] |
| `generatemap.inc:218` / `generatemapfrombitmap.inc:44` `_misc_SmoothTerrainCustom` | `(x,y,times:Integer; power,lerp,minh,maxh:Float)` | 4-diagonal average → `/power` → `Lerp(h,res,lerp)`, height-gated | [O] |
| `postprocess.inc:349` `BitmapGaussBlur` | `(bitmaptrg:Integer; const w,h:Integer; const r:Float; bFinal:Boolean)` | Two-pass gaussian + nearest terrain type fill | [O] |
| `postprocess.inc:53,58,84,95,106,116,260,279,307,330` | `IsPlateau`, `IsWater`, `IsBorderBlack*`, `FindBorderTerrainType`, `FindNearestTerrainType`, `PreprocessNoise`, `PreprocessNoiseWater` | Mask/noise predicates for editor preprocessing | [O] |
| `lib\misc.script:3325` `_misc_StandPatternPlaceMask` | `(patName:String; standX,standZ,angle:Float; var tmpPatternMask:array[0..639] of array[0..639] of Boolean)` | Footprint mask for a pattern | [O] |
| `lib\misc.script:3384` `_misc_CheckStandPattern` | `(patName:String; plHnd:Integer; standX,standZ,angle:Float; doStand,bWriteToParser:Boolean; pHnd:Integer):Boolean` | Rejection test + optional stamp | [O] |
| `lib\misc.script:3516` `_misc_CheckStandPatternExt` | `(envplHnd:Integer; patName:String; standX,standZ:Float; bWriteToParser:Boolean; pHnd:Integer):Boolean` | Wrapper used by generator | [O] |
| `lib\misc.script:3568` `_misc_SelectPatternListParser` | `(pGenerator:Integer; const name:String):Integer` | Select family list by name (`generator.cfg` group) | [O] |
| `lib\misc.script:3634` `_misc_GetPatternNameByParser` | `(var name:String; pPatternList:Integer)` | **FreqSum-weighted roulette**: `freqrnd := RandomExt*FreqSum`, subtract each `Freq` | [O] |
| `lib\misc.script:3681` `_misc_SetupPatternsByType` | `(pGenerator,envplHnd:Integer; const str:String; freq:Float)` | `needed := floor(mapW*mapH*freq)`, `trycount := floor(256*mapsizeoptimise)`, placement loop | [O] |
| `lib\misc.script:3931` `_misc_GetFreePatternMaskModifier` | `(var probsmall,probmid,problarge,probhuge:Float)` | Size-class probability modifiers used by dogenerate | [O] |

**Quoted roulette core** (`lib\misc.script:3634-3652`):

```
procedure _misc_GetPatternNameByParser(var name : String; pPatternList : Integer);
begin
   name := '';
   var pPatternGroup : Integer = ParserGetParent(pPatternList);
   var freqsum : Float = ParserGetFloatValueByKeyByHandle(pPatternGroup, 'FreqSum');
   var freqrnd : Float = RandomExt*freqsum;
   ...
      var freq : Float = ParserGetFloatValueByKeyByHandle(pPattern, 'Freq');
      if (freqrnd<freq) then
      begin
         name := ParserGetValueByKeyByHandle(pPattern, 'Pattern');
```

**[D]** `Freq` is a **weight**, not a probability; `FreqSum` is precomputed in the cfg parser. This matches DB_SCRIPTS.md §2.1 and F03.

### 2.3 Exact constants, defaults and ranges

#### 2.3.1 Skirmish height/color model — `data\scripts\common.inc\generatemap.inc:4-32`

```
const cPlateauHeight = 2.964;
const cHillHeight = cPlateauHeight/2.25;   // = 1.31733…
const cRavineHeight = -2.964;
const cWaterHeight = -1.1;

const cRColorPlateau = 255;
const cRColorHill = 96;
const cRColorRavine = 48;
const cRColorSmooth = 128 div 2;                       // 64
const cRColorPlateauSmooth = ((cRColorPlateau div 2)+cRColorSmooth); // 191
const cRColorHillSmooth = ((cRColorHill div 2)+cRColorSmooth);       // 112
const cRColorRavineSmooth = ((cRColorRavine div 2)+cRColorSmooth);   // 88
const cGColorForest = 255;  const cGColorGenForest = 64;
const cGColorStone = 128;   const cGColorForestStone = 192;
const cBColorWater = 255;
```

Channel decode (`:447-485`, `:352-393` for the >map-size branch): white `(1,1,1)` = start marker, `fa>0` = road (`gMapMask.broad`), R classes 255/96/48 (+ smooth 191/112/88/64), G classes 255/64/128/192 (G=127 special = forest only on relief), B=255 = water.

Height formula (`:567-574`):

```
var hwater : Float = cWaterHeight*(fb*(1+fr*3.5));
...
   cRPlateau : hterrain := cPlateauHeight*fr;
   cRHill : hterrain := cHillHeight*fr;
   cRRavine : hterrain := cRavineHeight*fr;
...
SetHeightData(realx, realy, hwater+hterrain)
```

**[D]** basin depth = `−1.1·b·(1+3.5r)`; relief adds `+2.964·r` (plateau), `+1.3173·r` (hill), `−2.964·r` (ravine).

#### 2.3.2 Stage flags — `generatemap.inc:35-49` (skirmish) and `generatemapfrombitmap.inc:91-105` (editor BMP)

Both sets are `True` except editor `cScalePlateauTerrain = False; // disabled` (`gmfb:98`). Skirmish flags: `cResetTerrainHeight, cPostProcessBitmapGaussian, cLoadHeightDataFromTexture, cSmoothTerrainUsingBitmap, cSmoothAllMapHeight, cPlaceWater, cPlaceForest, cTextureTerrain, cSmoothTile, cLoadTextureFromBitmap, cPlaceFreeForests, cSeedWheat, cBuildTopology, cUpdateMinimap, cPostStandPatterns`. **[D]** Guards are compile-time-like constants, so **[U]** whether a shipped build differs.

#### 2.3.3 Smoothing parameters (identical in both generation paths)

| Pass | Call | Range / gate | Passes |
|---|---|---|---|
| S0 | `SmoothTerrain(realx, -realy, False, 3)` | `gMapMask[x,y].bsmooth` only | once per flagged cell |
| S1 | `_misc_SmoothTerrainCustom(realx, realy, 1, 4, 0.5, 0.01, 100)` | whole map | 1 |
| S2 | `_misc_SmoothTerrainCustom(realx, realy, 1, 0.35, 0.5, -100, -0.01)` | cells with mask-water in clamped 5×5 (`const rad = 2`, `break(MAIN)`) | **3** (`for i:=0 to 2`) |

Citations: `generatemap.inc:584-595`, `:601-610`, `:611-640`, `:641`; `generatemapfrombitmap.inc:245-278`. Effective step coefficient `lerp/power` = `0.125` land, `≈1.4286` coastal **[D]**. Native `SmoothTerrain` internals **[U]**.

#### 2.3.4 Water planes and fields

| Constant | Value | Path:line | Scope |
|---|---|---|---|
| `cWaterHeight` (height formula) | `−1.1` | `generatemap.inc:7` | skirmish + editor |
| `cOffsetY` (water field plane) | `−0.5` | `generatemap.inc:688`, `gmfb:315` | skirmish + editor BMP |
| `cWaterFieldSize` / `cWaterMapArrSize` | `2` / `320÷2=160` (`gmfb:284`) or `640÷2=320` (`generatemap.inc:650`) | as cited | 2×2 cell quads |
| `cWaterHeightVisible` / `cBaseWaterSettingsOffset` / `cWaterFieldOffset` | `−0.834` / `0.52` / `0.0` ⇒ field Y `−0.314` | `generatewaterfields.inc:8-11,110` | editor-only F3 utility |
| `cOffsetHeight` (optional terrain offset) | `−0.2588898` | `generatewaterfields.inc:28` | editor-only, gate `cOffsetTerrain=False` |
| `cSmoothPlainTerrain` band | `height ∈ [−0.1, 0.15] → 0` | `generatewaterfields.inc:37-38` | editor-only |
| `cWaterHeight` (tile classification) | `−0.25`; shore `−0.1` | `textureterrain.inc:18-19`, `texturemap.inc:30-31` | tile/collision rules |

#### 2.3.5 Editor UserTerrain BMP channel classes — `gmfb:73-80, :147-172, :189-236`

```
const cPlateauHeight = 2.964;
const cWaterHeight = -1.1;
const cPlateau = 1; const cSmooth = 2; const cPlateauSmooth = 3;
const cWater = 4;   const cForest = 5;
...
if (fb>0) and (fr>0) and (fg>0) then bHeight := True;
if (fb>0) and (fg=0) then bWater := True;
if (fr>0) and (fg<(fr*0.8)) then bSmooth := True;
if (fg>0) and (fg>fb) then bForest := True;
```

Priority in `mask[x,y]`: `cPlateauSmooth` > `cSmooth` > `cPlateau` > `cWater` > `cForest` (`:159-172`). **[D]** Later height pass uses a stricter water test `(fb>0) and (fg<0.25) and (fb>fg) and (fb>fr)` (`:193`, `:298`), a **different** rule from the mask-analysis pass — do not merge them in a clone.

#### 2.3.6 Gaussian/noise (editor authored maps only)

`postprocess.inc:437,441`: `BitmapGaussBlur(bitmaptrg,width,height,0.00001,False)` then `(…,0.925,True)`; kernel `rs=Round(r*2.57+0.5)`, `wght=Exp(-dsq/(2r²))/(PI·2r²)`, clamp-to-edge, `Round(255*val/wsum)/255`. Noise constants `:63-82`: `bRandomNoise=True`, `cMinDropPower=1`, `cMaxDropPower=3`, `cNoiseProb=0.5`, `cTryNoiseNearestProb=0.6`, `cMaxDeep=10`, `cIsPlateauMin/Max=0.1/0.95`, `cIsWaterMin/Max=0.1/0.95`.

#### 2.3.7 Relief table, weights and mine rings — `dogenerate.inc`

Relief table `relieftype 0..4` (`:1624-1650`):

| type | plt | mnt | hil |
|---|---|---|---|
| 0 | 0.000010 | 0.000020 | 0.000075 |
| 1 | 0.000020 | 0.000002 | 0.000125 |
| 2 | 0.000075 | 0.000075 | 0.000030 |
| 3 | 0.000055 | 0.000120 | 0.000050 |
| 4 | 0.000090 | 0.000035 | 0.000035 |

`relieftype>4 ⇒ floor(RandomExt*5)` (`:1621-1622`). Frequencies `:1688-1693`: `frs_big=0.0009, frs_mid=0.0009, frs_small=0.00054, dcr=0.0005, stn1=0.00016, stn2=0.00012`; plain `0.0001/2` scaled by size-class modifiers (`:1727-1739`); size modifier `640/((mapW+mapH)/2)` for non-640 maps (`:1718-1725`). Mines `:528-535`: density `0/1/2 → rounds 3/4/5`, `trycount=256`; distances by version/size/player count at `:559-654`, e.g. current large-map case `14+RandomExt*8, 32+RandomExt*10, 70+RandomExt*12, 22+RandomExt*16`. Keep-clear ellipses `:407-416`: `5×7`, `12×15`, `22×18`, centred `(pointx, pointy+2)`. Tile grid `cSize=25` (`:1335`). Shore band `cWaterShoreHeight=-0.1` (`:1576-1579`). Season color tables `:2075-2084`: winter (`GetSeasonType=2`) → color table 6 / PHDR 1; season 3 → table 7; else table 0 / PHDR 0.

### 2.4 In-menu random-map generator invocation chain

**[O]** Chain recovered across `data/gui/menu.inc` (adjacent), `data/scripts/common.inc` and `common.aix`:

1. `data\gui\menu.inc\donewgame.inc:16` `GenerateMapRandKey(gMap.settings.gen.randkey0, gMap.settings.gen.randkey1)`; `:33-35` `SetRandomExtKey64`, `SetMapGeneratorRandomKey`, `SetGlobalMapGeneratorRandomKey`; `:42-49` `mapsize` → `0:320, 1:480, 2:640, 3:256`, else 320.
2. `common.aix:51-54` registers `DoGenerate → dogenerate.inc`; `:70-73` `GenerateMap → generatemap.inc`; `:77-80` `PostProcess`; `:84-87` `TextureMap`; `:91-94` `LoadTextureTerrainFromBitmap`.
3. `initmapgen.inc:232` `ExecuteState('DoGenerate')`; then `:235 MapWorldUpdateTerrainData(0,0)`, `:237 TopologyBuild`, `:239 _misc_BuildIslandsGrid`.
4. `dogenerate.inc:1530-1538` tiled patterns then `SetRandomKey(gMap.settings.gen.randkey1)`; `:1542-1564` read `relieftype/terraintype/resourcemines`, resolve `TerrainTypes` or `TerrainTypesDLC5` by `gRecordGeneratorVersion<91`, pick mask folder `path`; `:1563-1565`

```
BoolRegister0 := True;
StringRegister0 := path;
ExecuteState('GenerateMap');
```

5. `generatemap.inc:61 bRandomMap := BoolRegister0`; `:141-143` `bTGA := True` and `randkey0/1 := gMap.settings.gen.randkey*`; `:171 folderpath := StringRegister0`; `:174-194` enumerate `*.tga` in `<folder>\<N>pl*.tga` by player count, `rndind := floor(RandomExt*count)`; `:216 SetRandomExtKey64(randkey0,randkey1)`.
6. `generatemap.inc:261-262 ResetPatternMap(False)` for random maps; `:505-534` gaussian branch is **skipped** because random; `:565-574` height from RGBA; `:591` S0; `:606` S1; `:611-640` S2×3; `:641 TerrainUpdate(True,False)`; `:646-707` mask-B→2×2 water fields; `:774-786` `ExecuteState('TextureMap')` then `ExecuteState('SmoothTiles')`; `:794-798` `ExecuteState('LoadTextureTerrainFromBitmap')`.
7. Back in `dogenerate.inc:1572-1580` shore occupancy `height < -0.1`; `:1613-1615` border occupancy + `RandomStartingPoints`; `:1621-1650` relief table; `:1688-1739` frequencies; `:1757-1768` mountain/plateau/ravine/hill families (or `desert_*`); `:1770 SetupMines` per start; `:1772 SetRandomKey`; `:1803+` forest/stone/decor families; `:2065 SetupBorderObjects`, `:2068 _misc_SetShoresCollision`, `:2075-2084` season color tables.

**[O]** The editor registers the *same state names* to different files (`editor.aix:763 GenerateMap → scripts\editor.inc\generatemap.inc`, `:769 PostProcess`, `:775 TextureMap`, `:781 LoadTextureTerrainFromBitmap`), i.e. the editor and in-menu skirmish generator share the state-machine vocabulary but not the implementation. **[D]** This is the single most important disambiguation for a clone: use `data/scripts/common.inc/*` as the skirmish reference, not `scripts/editor.inc/*`.

### 2.5 Stage→port mapping

| # | Donor stage | Commands / constants (cited) | Skirmish? | Port action (PORT APPROXIMATION) |
|---|---|---|---|---|
| 1 | Seed + map size | `GenerateMapRandKey`, `SetRandomExtKey64`, `SetRandomKey`, `RandomExt` (`donewgame.inc:16,33-35`; `dogenerate:1538`) | YES | Per-stage reseeded RNG; use `randkey0/1`, not one seed |
| 2 | Mask selection | `ParserGetFilesInRoot`, `rndind=floor(RandomExt*count)` (`generatemap.inc:174-194`) | YES | Weighted/seed-stable TGA mask pick by player count |
| 3 | Mask decode | R/G/B/A codes `255/96/48/64/191/112/88`, `255/64/128/192`, `255`, `fa>0` (`generatemap.inc:4-32,352-485`) | YES | Decode 4 channels into relief class/forest/water/road flags |
| 4 | Gaussian/noise | `PostProcess`, `BitmapGaussBlur(…,0.00001)`/`(…,0.925)` (`postprocess.inc:437,441`; `generatemap.inc:507-520`) | **NO** (authored maps only) | Pre-bake `_gauss` assets offline; do not run at runtime |
| 5 | Height field | `h = −1.1·b·(1+3.5r) + {2.964r, 1.3173r, −2.964r}` (`generatemap.inc:567-574`) | YES | Direct formula, no invented noise |
| 6 | Smoothing | S0 `SmoothTerrain(…,3)`, S1 `custom(1,4,0.5,0.01,100)`, S2×3 `custom(1,0.35,0.5,−100,−0.01)` rad 2 (`generatemap.inc:580-641`) | YES | Reproduce S1/S2 math; S0 kernel **[U]** needs binary work |
| 7 | Water fields | 2×2 grid, `WaterFieldsClear`, `WaterFieldAdd(...,−0.5)` (`generatemap.inc:646-707`) | YES | Quad water registry + plane Y −0.5 |
| 8 | Collision / tiles | `MapDrawCollision`, `GetMapCollisionTag`, `SetTileIndex` (`texturemap.inc:63-128`, `:617-646`) | YES | Half-tile tags, road tiles `ground1/test2/test3`, winter suffix |
| 9 | Tile smoothing | `ExecuteState('SmoothTiles')` (`generatemap.inc:786`); `smoothtiles.inc` 3 sweeps | YES | 3 horizontal/vertical passes (D06/F05) |
| 10 | Starts & keep-clear | ellipses `5×7/12×15/22×18`, border 3 (`dogenerate:407-416,1613`) | YES | Occupancy mask before pattern stamping |
| 11 | Relief/mines/forest passes | `SetupTiledPatterns` cSize 25; `_misc_SetupPatternsByType` with Freq weights; `SetupMines` (`dogenerate:1330-1359,1688-1773`) | YES | FreqSum roulette + 256-try placement + rejection |
| 12 | Finalize | `SetupBorderObjects`, `_misc_SetShoresCollision`, season tables (`dogenerate:2065-2084`); `TopologyBuild` (`initmapgen:237`) | YES | Borders, shore collision, color/PHDR tables, topology |

### 2.6 Editor-only vs skirmish-relevant classification

| Item | Evidence | Classification |
|---|---|---|
| `dogenerate.inc`, `generatemap.inc`, `texturemap.inc`, `smoothtiles.inc`, `postprocess.inc` (runtime branch), `lib/misc.script` helpers | `common.aix:51-94` registration; `generatemap.inc:61,507-531` | **Skirmish-relevant** (with the caveat that `;`-prefixed text execution is [U]) |
| `generatemapfrombitmap.inc` (UserTerrain BMP), `postprocessbitmap.inc`, `postprocesssaver.inc`, `textureterrain.inc`, `scaleplateauterrain.inc`, `plateaugenerator1..3.inc`, `generatewaterfields.inc`, `c1watergenmapconverter.inc`, `grass*todesert*.inc`, save/load terrain data | `editor.aix:621-787,841-853`; `onautoruneditor.inc:23-24,46-47` | **Editor-only authoring utilities**; useful as documented algorithms, not part of skirmish pipeline |
| `addresources.inc`, `createstartpatterns.inc`, `positionyup/down.inc`, AABB/test scripts | `editor.aix:175,414` etc. | **Editor/debug only**, no terrain generation role |
| Relief raise/lower brush, ridge/ravine drag, flat-summit, area levelling, smoothing brush, polygon select `Cubic/Squad/Smooth/Road1/2/3`, water draw/remove + glints + current arrows, snow tool, mine/farm/campfire placement | `RC_TERRAIN.md:20-24,96-100` (S2–S4); zero script hits; `D09_editor_binary.md:19-25` native forms | **Editor-only, native**; skirmish relevance **none directly**, but authored maps can carry their output. Parameters **[U]** |
| `particles.snow.cfg` | wide grep, `data\env\pfx\particles.snow.cfg:2,42` | FX snow particles, **not** the editor snow brush; do not conflate |

---

## 3. Implications for the port

1. **[D]** A donor-shaped module must encode the **two-file** skirmish chain, not the editor scripts. The editor scripts are valuable as *independent corroboration* of the same constants (2.964/−1.1, water 2×2 fields, smoothing params) and as the only plaintext spec of UserTerrain.
2. **[D]** Height and color constants are identical in both paths — this is strong (two independent donor sources) evidence for the relief scale. The port's radial-dome relief is a PORT APPROXIMATION that should be replaced by `hwater+hterrain` with the exact `3.5` coupling.
3. **[D]** `Freq` must be treated as a weight with `FreqSum` roulette (E15), not a probability; pattern counts derive from `floor(mapW*mapH*freq)` and placement uses a 256-try rejection budget with elliptical keep-clear zones. Cross-check F01/F02/F03 for pattern bytes/weights.
4. **[D]** Roads in skirmish come from the **alpha channel** of the mask (`gMapMask.broad`, `generatemap.inc:450-453`) and become `ground1/test2/test3` tiles in `texturemap.inc:617-646` — a concrete, implementable rule that replaces "no roads at all". The manual's road *brush* polygons are editor-only and need not be cloned for skirmish parity.
5. **[D]** There are **three distinct water Y values** with different jobs: `−1.1` basin in the height formula, `−0.5` generated water-field plane, `−0.25/−0.1` tile/collision classification. Conflating them will produce a wrong shore. Cross-check D06/X11.
6. **[D]** Because `PostProcess` is gated `not bRandomMap`, a random-map clone that adds a runtime gaussian pass is **inventing behaviour** (charter §4 "no invention"). Pre-baked `_gauss` masks are the correct faithful route.
7. **[D]** The editor BMP path is the only plaintext source that names channel→terrain semantics for hand-authored landscapes; if authored-map import is in scope, port its 320×320 guard and class priority exactly (including the stricter water test in the height pass).
8. **[D]** No donor GPU A/B frame exists; all of the above stage mappings are **PORT APPROXIMATION** until A/B is produced. Nothing here authorizes a parity claim.

---

## 4. Risks

| Risk | Severity | Evidence / mitigation |
|---|---|---|
| Quoted lines are passive DScript strings (`[*] = ;…`); retail execution is not proven | HIGH | All E03–E14 lines; shared with D03/D06/X03. Keep `[U]` on runtime; do not use as "the binary does X" |
| Native kernels (`SmoothTerrain`, `PlateauTerrain`, `PaintTerrain`, `WaterFieldAdd`, tile smoothing) have no source-level definition in text | HIGH | No `procedure SmoothTerrain` anywhere; D03/D06 still list `[U]`. Reproduce only the script-visible wrapper parameters; do not invent internals |
| Two `GenerateMap` states with different bodies | MEDIUM | E01/E02/E10. Implementation workers must use `data/scripts/common.inc/generatemap.inc` for skirmish |
| Two water tests in the editor BMP importer (mask pass vs height pass) | MEDIUM | E04 `gmfb:148-157` vs `:189-194` and `:298`. Keep both if authoring is in scope |
| Different water Y constants across stages | MEDIUM | §2.3.4. Tag each constant with its consumer |
| Manual S2–S4 is C1/2/3-shared documentation, not C3-verified | MEDIUM | E18, `RC_TERRAIN.md:214-218`. Do not present brush parameter names as donor text |
| `cScalePlateauTerrain=False` and many commented-out branches (`cDropWaterPatterns` note) | LOW | E03 `:98,106`, E10 `:607,784`. Do not resurrect dead branches in a clone |
| Version gates (`gRecordGeneratorVersion < 53/61/…/91`) change constants | MEDIUM | `dogenerate.inc:1547-1560,559-654`; F03 lane. A single "current" table is an approximation |

---

## 5. UNVERIFIED register

| Id | Claim | Status | Why / how to resolve |
|---|---|---|---|
| U1 | Native `SmoothTerrain(x,-y,Bool,3)` kernel (power, radius, neighbour topology) | **[U]** | Only one script call site; no declaration; D03/D06 binary lane |
| U2 | `PlateauTerrain(x,y,Bool,radius,Bool)` boolean meanings and exact flatten target | **[U]** | Call sites only; no declaration |
| U3 | `PaintTerrain` 11-argument semantics (args 4,5,7,8,10,11) | **[U]** | All observed calls use `-1/False/True` sentinels |
| U4 | `WaterFieldAdd` plane-Y interpretation and renderer consumption | **[U]** | Text gives Y only; rendering in D06/X11 lane |
| U5 | `SetRandomExtKey64` / `SetRandomKey` mixing algorithm, `RandomExt` distribution | **[U]** | D02 lane; text shows use only |
| U6 | Formal parameter names/types of all native calls in §2.1 | **[U]** | No `.h`, `.inc` declaration or RTTI method table for these in the script corpus; column shows observed order only |
| U7 | Brush tool DScript names/params (relief raise/lower, smoothing, plateau/ravine polygon, road polygons, water draw/remove, glints, currents, snow, mine/farm/campfire) | **[U]** | Zero script hits; manual-only S2–S4; native `editor.exe` forms per D09. Binary/DFM study required |
| U8 | Whether any of the `;`-prefixed lines actually execute in retail skirmish | **[U]** | Text-only evidence; all quotes marked as text |
| U9 | `MapGeneratorSmoothTiles` vs `ExecuteState('SmoothTiles')` equivalence | **[U]** | Both exist, but only one live per path (`generatemap.inc:784` vs `:786`) |
| U10 | `generatewaterfields.inc` 128×128 guard applicability to any shipped map | **[U]** | Editor-only F3 script; no skirmish caller found |
| U11 | Exact `_gauss` mask production settings beyond radii/noise constants | **[U]** | `postprocesssaver.inc` not fully read here (D03/F04 cover it) |
| U12 | `UserTerrain` official menu label / hotkey in C3 1.3.x | **[U]** | Manual S3 name only; not found in text corpus |

---

## 6. Open questions

1. Should the port clone the editor UserTerrain BMP import at all, or only the skirmish path? (Owner scope decision; RC_TERRAIN G10 lists it as lower priority.)
2. Can D01/D02 recover the native `SmoothTerrain` kernel so S0 stops being a PORT APPROXIMATION?
3. Can D09's DFM/VMT anchors be extended to the *brush* tools (raise/lower, road polygons, water glints/currents, snow) to replace manual-only U7 with text/byte evidence?
4. Is `gMapMask[x,y].broad` (mask alpha) present in the exported 320² TGA masks used by the port, or only in the older BMP path? (F04/D03.)
5. Do scenario `.map` files supply water-plane Y different from `−0.5`, making the generated plane irrelevant in retail skirmish? (D06 Q3.)
6. Which generator version (`gRecordGeneratorVersion`) should the clone target — the values in "current" branches are version-gated? (F03.)
7. Does the in-menu random-map generator set `BoolRegister0`/`StringRegister0` exactly as `dogenerate.inc:1563-1564`, or does a native path call `GenerateMap` differently? (Text shows only this call site.)

---

## 7. Files touched / compliance

- **Written:** `docs/terrain_swarm_2026-11-26/reports/F09_editor_script.md` only.
- **Read-only donor:** `scripts\editor.aix`, all 142 files under `scripts\editor.inc\`, all 222 files under `data\scripts\` (keyword index; terrain subset read in full), plus adjacent `data\gui\menu.inc\donewgame.inc` for the invocation chain. No donor binary executed or copied; no Craft Anything target opened/changed; no Godot runner job.
- **Labels:** every claim above is tagged [O]/[D]/[I]/[U] or "PORT APPROXIMATION"; no donor-parity claim is made.
