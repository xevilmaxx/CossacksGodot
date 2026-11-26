---
id: F03
wave: F (donor data formats)
title: "F03 — Exhaustive decode of donor terrain-generation text configs"
date: 2026-11-26
status: LANDED
labels: [O, D, I, U, "PORT APPROXIMATION"]
scope: read-only donor text; no donor binary executed; no donor file copied into repo; no code/Godot/git edits
donor_root: "C:\\Games\\Cossacks 3"
---

# F03 — Donor generation-config constants (`data/gen/*.cfg`, `data/game/var/{generator,startingsettings}.cfg`)

## 0. Method, labels, citation convention

All paths below are under `C:\Games\Cossacks 3`. Short forms:

| Short form | Full donor path |
|---|---|
| `gen\X.cfg:N` | `C:\Games\Cossacks 3\data\gen\X.cfg`, 1-based line `N` |
| `var\generator.cfg:N` | `C:\Games\Cossacks 3\data\game\var\generator.cfg` |
| `var\startingsettings.cfg:N` | `C:\Games\Cossacks 3\data\game\var\startingsettings.cfg` |
| `scripts\common.inc\smoothtiles.inc:N` | `C:\Games\Cossacks 3\data\scripts\common.inc\smoothtiles.inc` |

Tools used: PowerShell `[IO.File]::ReadAllLines`, Python 3.14 (`latin-1` decode), regex/struct parsers run **in memory only**. All seven files were hashed (§2). No donor executable was run; no donor binary copied; Craft Anything was **not** used (text parsing was sufficient), so no global target was changed.

Labels: **`[O]` observed** = literal bytes/line read; **`[D]` derived** = arithmetic/structural consequence of observed lines; **`[I]` inferred** = plausible reading with caveat; **`[U]` UNVERIFIED** = no consumer found in the read evidence; **`PORT APPROXIMATION`** = what the port may do, explicitly not a parity claim. Stage names follow the charter: seed / mask / relief / smoothing / water / patterns / mines / forests / starts.

**No donor visual-parity claim is made anywhere in this report.**

---

## 1. Executive summary

1. **`[O]`** The five `data/gen` files are tiny (537–64,017 B) OSW-style `section.begin` / `struct.begin` configs; `var\generator.cfg` (70,074 B, 2,367 lines) and `var\startingsettings.cfg` (116,920 B, 3,424 lines) add the pattern-family and start-preset tables. Full inventory + hashes in §2.
2. **`[O]`** `gen\globalparams.cfg` contains exactly **20 flat generation knobs** (`globalparams.cfg:2-20`); `gen\localparams.cfg` exactly **1 record × 13 keys** (`:3-16`); `gen\mapcover.cfg` **1 climatic zone / 1 height zone / 1 tile entry** with **all four seasonal tile names empty** (`:2-37`).
3. **`[O]`** `gen\tilesmooth.cfg` is **8 sections × 3–4 plain tile names** = **30 `TileName` entries, no probabilities** (`:1-129`; supersedes the "10 sections" prior claim). `gen\tilesmooth_scripts.cfg` is the real weighted table: **22 chains, 130 `TileNames` groups (118 active), 310 `TileName` entries (282 active), 86 distinct names, ΣProb = 174.0168**.
4. **`[D]`** Two apparent contradictions are real and must be preserved, not "fixed": `globalparams.cfg:9` says `TileSmoothPasses = 6` while the skirmish script hard-codes `SmoothTileMap(...,3)` (`smoothtiles.inc:237`); `globalparams.cfg:10` points `TileSmoothListFileName` at `tilesmooth.cfg` while the script loads `tilesmooth_scripts.cfg` (`smoothtiles.inc:5`). Prior art independently records both (`docs/audit/TERRAIN_BLEND_DONOR_PLAN.md:105-127`, `docs/coord_swarm_2026-11-25/decomp/DEC_05_terrain_formats.md:451-456`).
5. **`[O]`** `var\generator.cfg` defines **6 base + 9 DLC5 terrain-mask types** (`:2-66`) and **64 pattern-family records with 493 `Pattern`/`Freq` pairs** (`:67-2366`); `var\startingsettings.cfg` defines **19 start presets, 61 country groups, 61 ASCII placement masks, 276 legend entries** (`:87-3423`).
6. **`[I]`** No config found here contains a seed, RNG algorithm, explicit height formula, water level, or mine-count constant. Those live in scripts/binary (other workers: D02, D05–D07, F01/F08, F09). Do not mine these files for constants that are not there.

---

## 2. Evidence table (file inventory, all `[O]`)

| Donor path | Bytes | Lines | SHA-256 | Structure |
|---|---:|---:|---|---|
| `gen\globalparams.cfg` | 537 | 22 | `15a8dc64a91dc4e72f45a997d6f6a5b770b2b77786518f48a75e04ab95727a51` | 1 section, 20 flat keys (`:1-21`) |
| `gen\localparams.cfg` | 508 | 20 | `8d174830c47388e28ed80ad434ad591943a7d69616fb89697e68175b0934a12d` | `LocalTerrainParams` → 1 record, 13 keys |
| `gen\mapcover.cfg` | 1,196 | 40 | `ff0a7bf43314af53c93dd14f992fa4e6b866cd5acf07b95abdb2404ed9fa43f2` | `ClimaticZones` → `HeightTileZones` → `Tiles` + `PatternCovers` / `LocalPresets` / `LightPatterns` |
| `gen\tilesmooth.cfg` | 2,796 | 129 | `1753533e7984c2319c3c5fdbc519728e0937905c4cc5117846432ce008b89c7d` | 8 consecutive `section.begin` blocks, 30 plain tile names |
| `gen\tilesmooth_scripts.cfg` | 64,017 | 1,863 | `b82c88844160c0451696951466a72bcd1dff64079388c0ad0b3b0a07a531b433` | 1 section, `TileSmoothLists` → 22 chains, 130 groups, 310 entries |
| `var\generator.cfg` | 70,074 | 2,367 | `f8a5cd2e08952565290adf4da888017467097c9b6e7666a45cf141827a974cc3` | `generator` → `TerrainTypes`, `TerrainTypesDLC5`, `Patterns` (64 records, 493 entries) |
| `var\startingsettings.cfg` | 116,920 | 3,424 | `17d4aeddaf4496594bda74e5f1fcc4f8ff0e149a5b2a53211c8f1eba200c111f` | `startingsettings` → 19 presets, 61 `countries[]`, 61 `mask`, 61 `legends`, 276 legend entries |

All files are CRLF; hashes are of the untouched donor bytes. No other `generator.cfg`/`startingsettings.cfg` exists under `data/` or `dlcs/` (recursive search `[O]`); DLC terrain masks are referenced from `var\generator.cfg:29-66`, not from DLC-local configs.

Prior art reconciled before parsing: `docs/coord_swarm_2026-11-25/decomp/DEC_03_configs.md:60-72,705-709`; `docs/coord_swarm_2026-11-25/decomp/DEC_05_terrain_formats.md:401-411,483-503`; `docs/research/T6_S03_smooth_chains.md:39-216`; `docs/audit/TERRAIN_BLEND_DONOR_PLAN.md:88-127`; `docs/research/T6_S01_camera.md:60-75,190-192`; `docs/guides/GUIDE4.md:2046,2143`; `docs/t6/TERRAIN_LANE.md:125,217`. This report re-parses from donor bytes rather than trusting any prior count.

---

## 3. Exact source text of key sections (`[O]`, line numbers preserved)

### 3.1 `gen\globalparams.cfg:1-22` — complete file

```
   1: section.begin
   2:    Size = 512
   3:    Sharpness = 0.6
   4:    TileChangeFactor = 0.3
   5:    FrequencyFactor = 0.000013
   6:    CellsResolution = 1
   7:    FailStandCount = 16
   8:    DefaultMapSize = 256
   9:    TileSmoothPasses = 6
  10:    TileSmoothListFileName = .\data\gen\tilesmooth.cfg
  11:    CastlesFileName = 
  12:    PatternPlayerName = pattern
  13:    PatternPlayerRace = 
  14:    CastlePlayerName = 
  15:    CastlePlayerRace = 
  16:    CastlePatternsPlayerName = 
  17:    CastlePatternsPlayerRace = 
  18:    AddCastles = False
  19:    CastlePlateauFactor = 5
  20:    CastleType = 
  21: section.end
  22: (empty trailing line)
```

### 3.2 `gen\localparams.cfg:1-20` — complete file

```
   1: section.begin
   2:    LocalTerrainParams : struct.begin
   3:       [*] : struct.begin
   4:          Name = 0
   5:          HillPointsDensity = 0.00008
   6:          MaxHillsHeight = 0
   7:          HillsHeightFactor = 0.001
   8:          GlobalMixFactor = 1
   9:          LocalMixFactor = 1
  10:          OffsetRadius = 0
  11:          SmoothLevel = 0.008
  12:          SmoothPasses = 1
  13:          SmoothFactor = 0.15
  14:          MinHeight = 0
  15:          MaxHeight = 0.0001
  16:          CriticalPointsDist = 0
  17:       struct.end
  18:    struct.end
  19: section.end
  20: (empty trailing line)
```

### 3.3 `gen\mapcover.cfg:1-40` — complete file

```
   1: section.begin
   2:    ClimaticZones : struct.begin
   3:       [*] : struct.begin
   4:          Name = Default
   5:          HeightTileZones[*] : struct.begin
   6:             Name = HeightZone0
   7:             MinHeight = 0
   8:             MaxHeight = 100
   9:             Tiles : struct.begin
  10:                [*] : struct.begin
  11:                   Frequency = 1.0
  12:                   SummerTileName = 
  13:                   AutumnTileName = 
  14:                   WinterTileName = 
  15:                   SpringTileName = 
  16:                struct.end
  17:             struct.end
  18:          struct.end
  19:          PatternCovers : struct.begin
  20:          struct.end
  21:          LocalPresets : struct.begin
  22:             [*] : struct.begin
  23:                Name = Default
  24:                LocalParams : struct.begin
  25:                   [*] : struct.begin
  26:                      ItemName = 0
  27:                      MapFrequency = 1
  28:                      BorderFrequency = 1
  29:                      OnMap = True
  30:                      OnBorder = True
  31:                   struct.end
  32:                struct.end
  33:             struct.end
  34:          struct.end
  35:          LightPatterns : struct.begin
  36:          struct.end
  37:       struct.end
  38:    struct.end
  39: section.end
  40: (empty trailing line)
```

### 3.4 `gen\tilesmooth.cfg:1-14` — section 1, with the exact grammar (repeats verbatim for sections 2–8)

```
   1: section.begin
   2:    SmoothTiles : struct.begin
   3:       [*] : struct.begin
   4:          TileName = ground1
   5:       struct.end
   6:       [*] : struct.begin
   7:          TileName = test1
   8:       struct.end
   9:       [*] : struct.begin
  10:          TileName = grass1
  11:       struct.end
  12:    struct.end
  13: section.end
  14: (blank)
```

All ten sections are enumerated in §6.1. There is **no `Prob` key anywhere in this file** `[O]`.

### 3.5 `gen\tilesmooth_scripts.cfg:1-96` — chain C00, the full grammar in situ

```
   1: section.begin
   2:    TileSmoothLists : struct.begin
   3:       [*] : struct.begin
   4:          SmoothTiles : struct.begin
   5:             [*] : struct.begin
   6:                TileNames : struct.begin
   7:                   [*] : struct.begin
   8:                      TileName = sandsea1
   9:                      Prob = 1
  10:                   struct.end
  11:                   [*] : struct.begin
  12:                      TileName = sandsea2
  13:                      Prob = 1
  14:                   struct.end
  15:                   [*] : struct.begin
  16:                      TileName = sandsea3
  17:                      Prob = 1
  18:                   struct.end
  19:                   [*] : struct.begin
  20:                      TileName = sandsea4
  21:                      Prob = 1
  22:                   struct.end
  23:                struct.end
  24:             struct.end
  25:             [*] : struct.begin
  26:                TileNames : struct.begin
  27:                   [*] : struct.begin
  28:                      TileName = sandsea5
  29:                      Prob = 0.7
  30:                   struct.end
  31:                   [*] : struct.begin
  32:                      TileName = sandsea6
  33:                      Prob = 0.3
  34:                   struct.end
  35:                struct.end
  36:             struct.end
  37:             //[*] : struct.begin
  38:             //   TileNames : struct.begin
  39:             //      [*] : struct.begin
  40:             //         TileName = sandrock1
  41:             //         Prob = 0.4
  42:             //         //Prob = 0
  43:             //      struct.end
  44:             //      [*] : struct.begin
  45:             //         TileName = sandrock3
  46:             //         Prob = 0.6
  47:             //         //Prob = 0
  48:             //      struct.end
  49:             //   struct.end
  50:             //struct.end
  51:             [*] : struct.begin
  52:                TileNames : struct.begin
  53:                   [*] : struct.begin
  54:                      TileName = rock9
  55:                      Prob = 0.0
  56:                   struct.end
  57:                   [*] : struct.begin
  58:                      TileName = rock8
  59:                      Prob = 0.0
  60:                   struct.end
  61:                   [*] : struct.begin
  62:                      TileName = rock5
  63:                      Prob = 0.0
  64:                   struct.end
  65:                struct.end
  66:             struct.end
  67:             [*] : struct.begin
  68:                TileNames : struct.begin
  69:                   [*] : struct.begin
  70:                      TileName = rock1
  71:                      Prob = 0.16
  72:                   struct.end
  73:                   [*] : struct.begin
  74:                      TileName = rock2
  75:                      Prob = 0.16
  76:                   struct.end
  77:                   [*] : struct.begin
  78:                      TileName = rock3
  79:                      Prob = 0.16
  80:                   struct.end
  81:                   [*] : struct.begin
  82:                      TileName = rock6
  83:                      Prob = 0.16
  84:                   struct.end
  85:                   [*] : struct.begin
  86:                      TileName = rock7
  87:                      Prob = 0.16
  88:                   struct.end
  89:                   [*] : struct.begin
  90:                      TileName = rock4
  91:                      Prob = 0.20
  92:                   struct.end
  93:                struct.end
  94:             struct.end
  95:          struct.end
  96:       struct.end
```

Two other critical excerpts (`[O]`):

```
 447:             [*] : struct.begin
 448:                TileNames : struct.begin
 449:                   [*] : struct.begin
 450:                      TileName = grass_ground1
 451:                      //Prob = 0.36
 452:                      Prob = 0.64
 453:                   struct.end
```
The **active** value is `0.64`; `//Prob = 0.36` is a commented-out alternative `[O]`. Same pattern at `:572/573` and `:681/682` (winter mirrors `:1381/1382`, `:1502/1503`, `:1611/1612`).

```
 881:         SmoothTiles : struct.begin
 882:            //[*] : struct.begin       <- C10 is an ALL-COMMENTED terminator
 ...
 930:         struct.end
 931:      struct.end
 933:      [*] : struct.begin             <- C11 begins at 934
 934:         SmoothTiles : struct.begin
```
```
1860:          struct.end
1861:       struct.end
1862:    struct.end
1863: section.end
```

### 3.6 `var\generator.cfg:1-66` — terrain-mask type table (complete, `[O]`)

```
   1: generator : section.begin
   2:    TerrainTypes : struct.begin
   3:       [*] : struct.begin
   4:          hint = 0.Land
   5:          //path = .\data\gen\terrainmasks\land
   6:          path = .\data\gen\terrainmasks\nowater2
   7:       struct.end
   8:       [*] : struct.begin
   9:          hint = 1.Mediterranean
  10:          path = .\data\gen\terrainmasks\mediterranean
  11:       struct.end
  12:       [*] : struct.begin
  13:          hint = 2.Peninsulas
  14:          path = .\data\gen\terrainmasks\peninsulas
  15:       struct.end
  16:       [*] : struct.begin
  17:          hint = 3.Islands
  18:          path = .\data\gen\terrainmasks\islands
  19:       struct.end
  20:       [*] : struct.begin
  21:          hint = 4.Continents
  22:          path = .\data\gen\terrainmasks\continents
  23:       struct.end
  24:       [*] : struct.begin
  25:          hint = 5.Continent
  26:          path = .\data\gen\terrainmasks\continent
  27:       struct.end
  28:    struct.end
  29:    TerrainTypesDLC5 : struct.begin
  30:       [*] : struct.begin
  31:          hint = 0.Land
  32:          path = .\data\gen\terrainmasks.dlc5\nowater2
  33:       struct.end
  34:       [*] : struct.begin
  35:          hint = 1.Mediterranean
  36:          path = .\data\gen\terrainmasks.dlc5\mediterranean
  37:       struct.end
  38:       [*] : struct.begin
  39:          hint = 2.Peninsulas
  40:          path = .\data\gen\terrainmasks.dlc5\peninsulas
  41:       struct.end
  42:       [*] : struct.begin
  43:          hint = 3.Islands
  44:          path = .\data\gen\terrainmasks.dlc5\islands
  45:       struct.end
  46:       [*] : struct.begin
  47:          hint = 4.Continents
  48:          path = .\data\gen\terrainmasks.dlc5\continents
  49:       struct.end
  50:       [*] : struct.begin
  51:          hint = 5.Continent
  52:          path = .\data\gen\terrainmasks.dlc5\continent
  53:       struct.end
  54:       [*] : struct.begin
  55:          hint = 6.Coastal
  56:          path = .\data\gen\terrainmasks.dlc5\coastal
  57:       struct.end
  58:       [*] : struct.begin
  59:          hint = 7.Lakes
  60:          path = .\data\gen\terrainmasks.dlc5\lakes
  61:       struct.end
  62:       [*] : struct.begin
  63:          hint = 8.Rivers
  64:          path = .\data\gen\terrainmasks.dlc5\rivers
  65:       struct.end
  66:    struct.end
```
`var\generator.cfg:997,1019,1041,1234,1248` carry 5 Russian `Description` strings in CP1251 (decoded: `"Еловый лес из spruce и pine"`, `"Еловый лес из spruce и pine"`, `"Лес на зеленой траве из pine и pinedry"`, `"Лиственный"`, `"Лиственный"`) `[O]`; they annotate forest families only.

### 3.7 `var\startingsettings.cfg:87-180` — example preset + enum comments (exact)

```
  87:    [*] : struct.begin
  88:       // example
  89:       startid = -1
  90:       addresources : struct.begin
  91:          food = 0
  92:          wood = 0
  93:          stone = 0
  94:          gold = 0
  95:          iron = 0
  96:          coal = 0
  97:       struct.end
  98:       countries : struct.begin
  99:          [*] : struct.begin
 100:             allowedcountries : struct.begin
 101:                [*] = aus
 ...
 121:                [*] = swi
 122:             struct.end
 123:             addresources : struct.begin
 124:                food = 0
 ...
 130:             struct.end
 131:             legends : struct.begin
 132:                [*] : struct.begin
 133:                   key = X
 134:                   role = 1
 135:                   countrysid = 
 136:                   basename =
 137:                struct.end
 ...
 168:             struct.end
 169:             mask : struct.begin
 170:                [*] = ...........O..B............O..B..........
 171:                [*] = ..........PPPPPP..XXXXXX..PPPPPP.........
 172:                [*] = ..........PPPPPP..XXXXXX..PPPPPP.........
 173:                [*] = .Q........PPPPPP..XXXXXX..PPPPPP.......W.
 174:                [*] = ..........PPPPPP..XXXXXX..PPPPPP.........
 175:                [*] = ..........PPPPPP..XXXXXX..PPPPPP.........
 176:                [*] = ..........PPPPPP..........PPPPPP.........
 177:             struct.end
 178:          struct.end
 179:       struct.end
 180:    struct.end
```
Lines `2-11` enumerate `startid` values 0–9 with `gc_mapsettings_startingunits_*` names; lines `14-68` enumerate 54 `gc_ai_unit_*` roles (peasant=1, boat=2, center=3, mill=4, minegold=18, mineiron=19, minecoal=20, tower=13, etc.) `[O]`; lines `70-85` map country ids 0–14 to `aus/fra/eng/spa/rus/ukr/pol/swe/pru/ven/tur/alg/mis/net/den` `[O]`.

---

## 4. Full parameter tables — `globalparams.cfg` (`[O]` values, `[I]` meanings)

| Line | Parameter | Literal value | Units / domain | Meaning (label) | Generation stage (label) |
|---:|---|---|---|---|---|
| 2 | `Size` | `512` | integer, cells | global heightmap/grid extent `[U]` — no script consumer found; prior audit `T6_S01_camera.md:190-192` also leaves it UNVERIFIED | relief/mask `[I]` |
| 3 | `Sharpness` | `0.6` | float 0..1 `[I]` | relief sharpening / edge contrast factor `[I]` | relief `[I]` |
| 4 | `TileChangeFactor` | `0.3` | float 0..1 `[I]` | probability/weight of tile-class change during generation `[I]` | patterns / tile selection `[I]` |
| 5 | `FrequencyFactor` | `0.000013` | float, inverse length `[I]` | frequency scale of height/noise feature generation `[I]` | relief / mask `[I]` |
| 6 | `CellsResolution` | `1` | integer `[U]` | grid subdivision/resolution `[U]`, no consumer found | relief `[I]` |
| 7 | `FailStandCount` | `16` | integer, attempts | retry budget for failed stand/start placement `[I]` | starts `[I]` |
| 8 | `DefaultMapSize` | `256` | integer, cells | default map side length `[I]`; skirmish enum uses 320/480/640/256 (`T6_S01_camera.md:70`) | seed / map init `[I]` |
| 9 | `TileSmoothPasses` | `6` | integer, passes | editor-facing smoothing pass count `[D]`; script path uses **3** (`smoothtiles.inc:237`) | smoothing `[O]` literal / `[D]` conflict |
| 10 | `TileSmoothListFileName` | `.\data\gen\tilesmooth.cfg` | path string | editor list of plain compatible tile names `[O]`; runtime loads `tilesmooth_scripts.cfg` (`smoothtiles.inc:5`) | smoothing `[D]` |
| 11 | `CastlesFileName` | *empty* | path string | castle pattern file override `[U]` | patterns/castles `[U]` |
| 12 | `PatternPlayerName` | `pattern` | token string | player start-pattern name/token `[I]` | patterns / starts `[I]` |
| 13 | `PatternPlayerRace` | *empty* | race string | race filter for player pattern `[U]` | patterns `[U]` |
| 14 | `CastlePlayerName` | *empty* | token string | castle owner/player token `[U]` | castles `[U]` |
| 15 | `CastlePlayerRace` | *empty* | race string | castle race filter `[U]` | castles `[U]` |
| 16 | `CastlePatternsPlayerName` | *empty* | token string | castle-pattern player token `[U]` | patterns `[U]` |
| 17 | `CastlePatternsPlayerRace` | *empty* | race string | castle-pattern race filter `[U]` | patterns `[U]` |
| 18 | `AddCastles` | `False` | boolean | enable/disable castle generation `[I]` | patterns / starts `[I]` |
| 19 | `CastlePlateauFactor` | `5` | integer/factor `[U]` | plateau flattening/weight around castles `[I]` | relief / castles `[I]` |
| 20 | `CastleType` | *empty* | enum string | castle variant selector `[U]` | patterns `[U]` |

`[D]` 20 keys = 10 numeric/boolean + 3 non-empty strings + 7 empty strings (`:2-9`, `:18`, `:12`, and `:11,13-17,20` respectively). Every "meaning" column marked `[I]`/`[U]` is a reading of the key name plus prior art, **not** a recovered implementation.

---

## 5. Full parameter tables — `localparams.cfg` and `mapcover.cfg`

### 5.1 `localparams.cfg` — `LocalTerrainParams[0]` (all `[O]` values)

| Line | Parameter | Literal | Units / domain | Meaning (label) | Stage (label) |
|---:|---|---|---|---|---|
| 4 | `Name` | `0` | integer id | record id; matches `mapcover.cfg:26` `ItemName = 0` `[D]` linkage plausible, consumer `[U]` | mask/patterns `[I]` |
| 5 | `HillPointsDensity` | `0.00008` | float, points/cell `[U]` | density of hill seed points `[I]` | relief `[I]` |
| 6 | `MaxHillsHeight` | `0` | float, height units | upper clamp for hills; 0 = unused/default `[I]` | relief `[I]` |
| 7 | `HillsHeightFactor` | `0.001` | float multiplier | hill height scale `[I]` | relief `[I]` |
| 8 | `GlobalMixFactor` | `1` | float weight | global height-field mixing weight `[I]` | relief `[I]` |
| 9 | `LocalMixFactor` | `1` | float weight | local height-field mixing weight `[I]` | relief `[I]` |
| 10 | `OffsetRadius` | `0` | float, cells | radial offset/flatten radius `[I]` | relief `[I]` |
| 11 | `SmoothLevel` | `0.008` | float | local height smoothing threshold `[I]` | smoothing `[I]` |
| 12 | `SmoothPasses` | `1` | integer, passes | local smoothing iterations `[I]` (distinct from `globalparams:9`) | smoothing `[I]` |
| 13 | `SmoothFactor` | `0.15` | float weight | local smoothing blend factor `[I]` | smoothing `[I]` |
| 14 | `MinHeight` | `0` | float, height units | lower clamp `[I]` | water/relief `[I]` |
| 15 | `MaxHeight` | `0.0001` | float, height units | upper clamp `[I]`; prior art flags these as **editor-only**, not skirmish height scale (`DEC_05:496`) | water/relief `[U]` |
| 16 | `CriticalPointsDist` | `0` | float, cells | min separation of critical hill points `[I]` | relief `[I]` |

### 5.2 `mapcover.cfg` — one zone, all defaults (`[O]` values)

| Line | Parameter | Literal | Units / domain | Meaning (label) | Stage (label) |
|---:|---|---|---|---|---|
| 4 | `ClimaticZones[*].Name` | `Default` | string | climatic zone id `[I]` | mask / patterns `[I]` |
| 6 | `HeightTileZones[*].Name` | `HeightZone0` | string | height-band id `[I]` | tile selection `[I]` |
| 7 | `MinHeight` | `0` | float, height units | band lower bound `[I]` | tile selection `[I]` |
| 8 | `MaxHeight` | `100` | float, height units | band upper bound `[I]` | tile selection `[I]` |
| 11 | `Tiles[*].Frequency` | `1.0` | float weight | per-tile pick weight `[I]` | tile selection `[I]` |
| 12 | `SummerTileName` | *empty* | tile-block name | no summer tile bound in this file `[O]`; `[D]` config contributes **no art name** | tile selection `[D]` |
| 13 | `AutumnTileName` | *empty* | tile-block name | same `[O]` | tile selection `[D]` |
| 14 | `WinterTileName` | *empty* | tile-block name | same `[O]` | tile selection `[D]` |
| 15 | `SpringTileName` | *empty* | tile-block name | same `[O]` | tile selection `[D]` |
| 23 | `LocalPresets[*].Name` | `Default` | string | local-feature preset id `[I]` | forests/mines `[I]` |
| 26 | `LocalParams[*].ItemName` | `0` | integer id | references `localparams.cfg:4` `[D]` plausible | patterns `[I]` |
| 27 | `MapFrequency` | `1` | float weight | on-map placement frequency `[I]` | forests/mines `[I]` |
| 28 | `BorderFrequency` | `1` | float weight | border placement frequency `[I]` | forests/mines `[I]` |
| 29 | `OnMap` | `True` | boolean | enable on-map placement `[O]` literal | forests/mines `[I]` |
| 30 | `OnBorder` | `True` | boolean | enable border placement `[O]` literal | forests/mines `[I]` |

`PatternCovers` (`:19-20`) and `LightPatterns` (`:35-36`) are **empty structs** `[O]` — no pattern-cover or lighting constants here. Prior art agrees: `docs/coord_swarm_2026-11-25/reports/DENV_01_environment.md:396` ("climatic zones are EMPTY by default").

---

## 6. Full rule grammar and enumeration

### 6.1 `tilesmooth.cfg` — grammar + all 8 sections (`[O]`)

Grammar (OSW config, `[O]`):

```
section.begin
   SmoothTiles : struct.begin
      [*] : struct.begin
         TileName = <tile-block-name>
      struct.end
      ... repeat [*] ...
   struct.end
section.end
```

`[*]` = repeated record; `SmoothTiles` = one compatibility list; no `Prob`, no conditions, no comments in the file. Names are tile-block names from `terrain\tiles\terrain.presets` `[D]` (the lookup function `MapGetTileIndexByTileBlock` is used for the *scripts* table at `smoothtiles.inc:51`; the consumer of this editor table was **not found** `[U]`).

| Section | Lines | `#` entries | `TileName` list (order preserved) | Family `[I]` |
|---:|---|---:|---|---|
| 1 | 1–13 | 3 | `ground1`, `test1`, `grass1` | road/test/plain |
| 2 | 15–27 | 3 | `ground1`, `test1`, `grass2` | road/test/plain |
| 3 | 29–44 | 4 | `rock1`, `rock9`, `grass_ground1`, `grass1` | rock→grass transition |
| 4 | 46–61 | 4 | `rock2`, `rock9`, `grass_ground1`, `grass1` | rock→grass transition |
| 5 | 63–78 | 4 | `rock3`, `rock9`, `grass_ground1`, `grass1` | rock→grass transition |
| 6 | 80–95 | 4 | `rock4`, `rock9`, `grass_ground1`, `grass1` | rock→grass transition |
| 7 | 97–112 | 4 | `rock6`, `rock9`, `grass_ground1`, `grass1` | rock→grass transition |
| 8 | 114–129 | 4 | `rock7`, `rock9`, `grass_ground1`, `grass1` | rock→grass transition |

**Correction to prior art:** direct re-read gives **8 `section.begin` blocks at lines 1, 15, 29, 46, 63, 80, 97, 114**, not the 10 claimed at `DEC_03_configs.md:71`; the prior "130 lines" at `DEC_05:410` is off by one. `[O]` line count is 129, `section.begin` occurs 8 times, `TileName` occurs 30 times (3+3+4×6). This report uses the re-read: **8 sections, 30 entries**. `[D]` 8 lists × ≤4 names matches the 24-slot array bound in `smoothtiles.inc:23` only loosely; no consumer found `[U]`.

### 6.2 `tilesmooth_scripts.cfg` — grammar (`[O]` + consumer read)

```
section.begin
   TileSmoothLists : struct.begin
      [*] : struct.begin                       // Item / chain (0..63 array bound)
         SmoothTiles : struct.begin
            [*] : struct.begin                 // group j (0..23 array bound)
               TileNames : struct.begin
                  [*] : struct.begin           // candidate tile k (0..15 array bound)
                     TileName = <tile-block-name>
                     Prob = <float>
                  struct.end
               struct.end
            struct.end
         struct.end
      struct.end
   struct.end
section.end
```

Array bounds `[O]` from `smoothtiles.inc:18,23,26` (`SmoothTile[0..15]`, `SmoothTiles[0..23]`, `Items[0..63]`); all three are upper bounds, not counts. Comments use `//` at any indentation; a commented group is a *dead rule*, a commented `Prob` inside an active entry is a *dead alternative value*; double comments `//Prob = 0` are inert annotations `[O]`.

**Consumer semantics** (all lines `;`-prefixed in `smoothtiles.inc` = donor intent, not proven live `[U]`; prior art `docs/coord_swarm_2026-11-25/GAPS.md:31` records the same caveat):
- load + resolve names + accumulate `SumProb`: `smoothtiles.inc:4-60`;
- roulette `rnd := RandomExt * SumProb`, walk entries, pick first `prob>0`: `:63-80`;
- a name's **group index** is what matters: `ind1/ind2` from the containing group, with `prob==0` flags recorded `:108-125`;
- choose the chain with minimal `abs(ind1-ind2)`, `ind1≠ind2`, both ≥0 `:126-136`;
- distance 1 → compatible/no change if at least one endpoint has `prob>0`; distance 2 → replace the farther tile with a roulette pick from the intermediary group; distance >2 → step inward from the farther tile; no shared chain → unchanged `:139-186` (cross-checked `docs/audit/TERRAIN_BLEND_DONOR_PLAN.md:120-123`);
- snapshot tile map, horizontal sweep then vertical sweep per pass, `SmoothTileMap(0,0,W,H,3)`, write back `:27-32,191-242`.

### 6.3 Structural census of all 22 chains (`[O]`, independently re-parsed)

| Chain | First line | Groups (active/dead) | Active entries | ΣProb | Prob=0 names | Season `[I]` |
|---:|---:|---:|---:|---:|---|---|
| C00 | 4 | 4 / 1 | 15 | 6.0000 | rock9, rock8, rock5 | Summer |
| C01 | 98 | 6 / 0 | 17 | 11.0000 | — | Summer |
| C02 | 194 | 6 / 0 | 16 | 13.0000 | — | Summer |
| C03 | 286 | 9 / 0 | 18 | 14.0000 | — | Summer |
| C04 | 398 | 9 / 0 | 20 | 11.0028 | — | Summer |
| C05 | 519 | 8 / 0 | 18 | 10.0028 | — | Summer |
| C06 | 628 | 6 / 0 | 19 | 8.0028 | — | Summer |
| C07 | 733 | 3 / 1 | 4 | 3.0000 | test8 | Summer |
| C08 | 781 | 3 / 0 | 5 | 3.0000 | — | Summer |
| C09 | 817 | 5 / 0 | 9 | 8.0000 | — | Summer |
| C10 | 881 | 0 / 4 | 0 | 0 | — | empty terminator |
| C11 | 934 | 4 / 1 | 15 | 6.0000 | rock9_winter, rock8_winter, rock5_winter | Winter |
| C12 | 1028 | 6 / 0 | 17 | 11.0000 | — | Winter |
| C13 | 1124 | 6 / 0 | 16 | 13.0000 | — | Winter |
| C14 | 1216 | 9 / 0 | 18 | 14.0000 | — | Winter |
| C15 | 1328 | 9 / 0 | 20 | 11.0028 | — | Winter |
| C16 | 1449 | 8 / 0 | 18 | 10.0028 | — | Winter |
| C17 | 1558 | 6 / 0 | 19 | 8.0028 | — | Winter |
| C18 | 1663 | 3 / 1 | 4 | 3.0000 | test8_winter | Winter |
| C19 | 1711 | 3 / 0 | 5 | 3.0000 | — | Winter |
| C20 | 1747 | 5 / 0 | 9 | 8.0000 | — | Winter |
| C21 | 1811 | 0 / 4 | 0 | 0 | — | empty terminator |

Totals `[O]`: **22 chains / 130 groups (118 active, 12 commented) / 310 entries (282 active, 28 commented) / 86 distinct active names / ΣProb = 174.0168**. Group counts for C00–C09 = `[4,6,6,9,9,8,6,3,3,5]` = 59 active groups; 141 active Summer entries. `[D]` C11–C20 equal C00–C09 under `_winter` suffix with identical probabilities and group boundaries (verified with prior parser in `docs/research/T6_S03_smooth_chains.md:211-216`, and re-verified here by row comparison).

### 6.4 Complete enumeration of ALL 118 active rules (`[O]`)

Notation: `Cxx` chain, groups in source order, `{name=Prob, …}`; `Σ` per chain.

- **C00 (line 4)** `{sandsea1=1, sandsea2=1, sandsea3=1, sandsea4=1}` ; `{sandsea5=0.7, sandsea6=0.3}` ; `{rock9=0, rock8=0, rock5=0}` ; `{rock1=0.16, rock2=0.16, rock3=0.16, rock6=0.16, rock7=0.16, rock4=0.20}`
- **C01 (98)** `{sandsea1=1, sandsea2=1, sandsea3=1, sandsea4=1}` ; `{sandsea5=0.7, sandsea6=0.3}` ; `{sandrock1=0.4, sandrock3=0.6}` ; `{sandrock4=0.6, sandrock2=0.4}` ; `{grass1=1, grass2=1, test8=1}` ; `{grass7=0.25, test12=0.25, test13=0.25, test14=0.25}`
- **C02 (194)** `{sandsea1=1, sandsea2=1, sandsea3=1, sandsea4=1}` ; `{sandsea5=0.7, sandsea6=0.3}` ; `{sandrock1=0.4, sandrock3=0.6}` ; `{sandrock4=0.6, sandrock2=0.4}` ; `{grass1=1, grass2=1, test8=1}` ; `{test7=1, grass8=1, test6=1}`
- **C03 (286)** `{sandsea1=1, sandsea2=1, sandsea3=1, sandsea4=1}` ; `{sandsea5=0.7, sandsea6=0.3}` ; `{sandrock1=0.4, sandrock3=0.6}` ; `{sandrock4=0.6, sandrock2=0.4}` ; `{grass1=1, grass2=1, test8=1}` ; `{grass9=1}` ; `{test9=1}` ; `{grass3=1}` ; `{grass4=0.9, grass10=0.1}`
- **C04 (398)** `{rock1=0.16, rock2=0.16, rock3=0.16, rock6=0.16, rock7=0.16, rock4=0.20}` ; `{rock8=0.5, rock5=0.5}` ; `{rock9=1}` ; `{grass_ground1=0.64, grass_ground2=0.0028, grass_ground3=0.36}` ; `{grass1=1, grass2=1, test8=1}` ; `{grass9=1}` ; `{test9=1}` ; `{grass3=1}` ; `{grass4=0.9, grass10=0.1}`
- **C05 (519)** `{rock1=0.16, rock2=0.16, rock3=0.16, rock6=0.16, rock7=0.16, rock4=0.20}` ; `{rock8=0.5, rock5=0.5}` ; `{rock9=1}` ; `{grass_ground1=0.64, grass_ground2=0.0028, grass_ground3=0.36}` ; `{grass1=1, grass2=1, test8=1}` ; `{test7=1}` ; `{grass8=1}` ; `{test6=1}`
- **C06 (628)** `{rock1=0.16, rock2=0.16, rock3=0.16, rock6=0.16, rock7=0.16, rock4=0.20}` ; `{rock8=0.5, rock5=0.5}` ; `{rock9=1}` ; `{grass_ground1=0.64, grass_ground2=0.0028, grass_ground3=0.36}` ; `{grass1=1, grass2=1, test8=1}` ; `{grass7=0.25, test12=0.25, test13=0.25, test14=0.25}`
- **C07 (733)** `{rock9=1, test8=0}` ; `{grass5=1}` ; `{grass6=1}`
- **C08 (781)** `{rock9=1}` ; `{grass5=1}` ; `{grass_ground1=0.36, grass_ground2=0.28, grass_ground3=0.36}`
- **C09 (817)** `{ground1=1}` ; `{test2=1}` ; `{test1=1, test3=1}` ; `{test8=0.4, test7=0.6}` ; `{grass1=1, grass2=1, test8=1}`
- **C10 (881)** *no active groups* (4 commented groups at `:882,890,902,914`)
- **C11 (934)** Summer C00 with `_winter` suffix on every name, identical probs
- **C12 (1028)** Summer C01 with `_winter` suffix, identical probs
- **C13 (1124)** Summer C02 with `_winter` suffix, identical probs
- **C14 (1216)** Summer C03 with `_winter` suffix, identical probs
- **C15 (1328)** Summer C04 with `_winter` suffix, identical probs (incl. `grass_ground2_winter=0.0028`)
- **C16 (1449)** Summer C05 with `_winter` suffix, identical probs
- **C17 (1558)** Summer C06 with `_winter` suffix, identical probs
- **C18 (1663)** Summer C07 with `_winter` suffix (`rock9_winter=1, test8_winter=0` ; `grass5_winter=1` ; `grass6_winter=1`)
- **C19 (1711)** Summer C08 with `_winter` suffix (`grass_ground1_winter=0.36, grass_ground2_winter=0.28, grass_ground3_winter=0.36`)
- **C20 (1747)** Summer C09 with `_winter` suffix (`ground1_winter=1` ; `test2_winter=1` ; `{test1_winter=1, test3_winter=1}` ; `{test8_winter=0.4, test7_winter=0.6}` ; `{grass1_winter=1, grass2_winter=1, test8_winter=1}`)
- **C21 (1811)** *no active groups* (4 commented groups at `:1812,1820,1832,1844`)

Winter mirrors are stated structurally `[D]`; the Summer lines above are the literal transcription `[O]`. Exact Winter text is at `tilesmooth_scripts.cfg:934-1810`.

### 6.5 Categorisation of the 86 names (`[I]` from name families + prior-art tile semantics; not runtime-declared)

| Category (`[I]`) | Names | Role implied by chain structure (`[I]`) |
|---|---|---|
| Shore / sand-sea | `sandsea1..6`, `+_winter` | C00–C03: `1..4` uniform, `5:0.7 / 6:0.3` — weighted shoreline blend (`DEC_05:479-481`) |
| Sand-rock transition | `sandrock1..4`, `+_winter` | C01–C03 active `0.4/0.6`, `0.6/0.4`; C00 version commented dead (`:37-50`) |
| Rock faces / stone | `rock1..9`, `+_winter` | `rock1/2/3/6/7=0.16`, `rock4=0.20`, `rock8/5=0.5`, `rock9=1` or `0` endpoint |
| Plateau/grass transition | `grass_ground1/2/3`, `+_winter` | `0.64 / 0.0028 / 0.36` (Σ=1.0028 anomaly) and `0.36 / 0.28 / 0.36` (Σ=1) |
| Grass plains | `grass1..10`, `+_winter` | `grass1/2/test8=1` common group; `grass4=0.9/grass10=0.1`; singletons `grass3/5/6/9` |
| Road/test | `ground1`, `test1/2/3/6/7/8/9/12/13/14`, `+_winter` | C09 roads `ground1=1`, `test2=1`, `{test1=1,test3=1}`, `{test8=0.4,test7=0.6}`; road weights in `texturemap.inc:622-636` are a **different** table (`DEC_05:476`) |

`Prob = 0` names (`rock9`, `rock8`, `rock5`, `test8`, winter forms) are **legal endpoints but never roulette picks** (`smoothtiles.inc:112-121`; prior art `T6_S03_smooth_chains.md:301-303`). Do not "fix" them.

### 6.6 All commented/dead rules (`[O]`, 12 commented groups, 28 commented entries)

| Lines | Chain | Dead content |
|---|---|---|
| 37–50 | C00 | commented group: `sandrock1=0.4`, `sandrock3=0.6` (+ inert `//Prob = 0`) |
| 451, 572, 681 | C04,C05,C06 | commented alternative `//Prob = 0.36` on active `grass_ground1=0.64` |
| 746–758 | C07 | commented group `grass_ground1=0.36`, `grass_ground2=0.28`, `grass_ground3=0.36` |
| 856–859 | C09 | commented entry `grass2=1` |
| 882–929 | C10 | 4 commented groups: `{test2=1}` ; `{test1=0.7, test3=0.3}` ; `{test6=1, grass2=1}` ; `{grass1=1, grass2=1, test8=1}` |
| 967–980 | C11 | winter mirror of C00 commented group |
| 1381, 1502, 1611 | C15–C17 | winter `//Prob = 0.36` alternatives |
| 1676–1688 | C18 | winter mirror of C07 commented group |
| 1786–1789 | C20 | winter commented entry `grass2_winter=1` |
| 1812–1859 | C21 | 4 winter commented groups (mirror of C10) |

`[D]` 28 = 2 (C00) + 3 (C07) + 1 (C09) + 8 (C10) + 2 (C11) + 3 (C18) + 1 (C20) + 8 (C21). All are excluded from the 282 active entries.

---

## 7. `var\generator.cfg` — terrain types and all 493 pattern weights

### 7.1 Terrain-type constants (`[O]`)

| Section | Lines | Entries | `hint` ids | Mask path root |
|---|---:|---:|---|---|
| `TerrainTypes` | 2–28 | 6 | 0 Land (`nowater2`, `:5-6` — `land` path commented), 1 Mediterranean, 2 Peninsulas, 3 Islands, 4 Continents, 5 Continent | `.\data\gen\terrainmasks\` |
| `TerrainTypesDLC5` | 29–66 | 9 | 0 Land, 1 Mediterranean, 2 Peninsulas, 3 Islands, 4 Continents, 5 Continent, 6 Coastal, 7 Lakes, 8 Rivers | `.\data\gen\terrainmasks.dlc5\` |

Stage: **mask** `[I]` (paths point at mask directories; F04 decodes the channel semantics). Units: directory path / enum id.

### 7.2 `Patterns` — grammar and global facts (`[O]`/`[D]`)

```
  67:    Patterns : struct.begin
  68:       [*] : struct.begin
  69:          Name = mng
  70:          PatternList : struct.begin
  71:             [*] : struct.begin
  72:                Pattern = mng4
  73:                Freq = 0
  74:             struct.end
  ...
2366:    struct.end
2367: section.end
```
64 records, 493 `Pattern`/`Freq` pairs (`[O]`), 60 **distinct** `Name` values — four names are duplicated (`desert_mng` `:156` & `:1658`; `desert_mni` `:173` & `:1683`; `desert_mnc` `:190` & `:1708`; `plain_medium` `:288` & `:1762`) `[O]`. A naive `Name→list` map **loses data** `[D]`.

`Freq` distribution `[O]`: `0`×4, `0.25`×5, `0.5`×4, `0.5625`×5, `1`×441, `1.5625`×5, `2`×2, `2.25`×13, `3`×3, `4`×2, `5.0625`×2, `6.25`×2, `100`×1, `1000`×4. Units: relative weight (roulette-style) `[I]` — the consumer is a binary/script not in this report `[U]`. Anomalies: `desert_tiles` at `:1629-1657` has `d_tls_1=1000` twice, `d_tls_2=0`, `d_tls_3=1000` twice, `d_tls_4=100` `[O]`; `mng/mni/mnc` each start with a `Freq=0` base variant (`mng4=0` `:73`, `mni4=0` `:102`, `mnc4=0`) `[O]`.

### 7.3 Complete `Patterns` table (`[O]`)

`Name (first line)` → `#` → `Pattern=Freq` in source order. Stage for all: **patterns / relief stamp / mines / forests / water** `[I]`; `Freq` is a relative weight `[I]`.

| Name (line) | # | Pattern=Freq pairs |
|---|---:|---|
| mng (69) | 6 | mng4=0, mng_1=1, mng_2=1, mng_3=1, mng_4=1, mng_5=1 |
| mni (98) | 6 | mni4=0, mni_1=1, mni_2=1, mni_3=1, mni_4=1, mni_5=1 |
| mnc (127) | 6 | mnc4=0, mnc_1=1, mnc_2=1, mnc_3=1, mnc_4=1, mnc_5=1 |
| desert_mng (156) | 3 | desert_mng_1_a=1, desert_mng_2_a=1, desert_mng_3_a=1 |
| desert_mni (173) | 3 | desert_mni_1_a=1, desert_mni_2_a=1, desert_mni_3_a=1 |
| desert_mnc (190) | 3 | desert_mnc_1_a=1, desert_mnc_2_a=1, desert_mnc_3_a=1 |
| plain_small (207) | 19 | k_small_plain_1=1, _2=1, _3=1, _4=1, _5=1, _6=1, _14=1, _15=1, _18=0.25, _22=1, _24=0.5625, _25=0.5625, _26=0.5625, _27=0.25, _29=0.5625, _30=0.5625, _31=0.25, _32=0.25, _33=0.25 |
| plain_medium (288) | 24 | k_small_plain_7=2.25, _8=2.25, _9=2.25, _10=2.25, _11=2.25, _12=1.5625, _13=1.5625, _16=2.25, _17=2.25, _19=2.25, _20=1.5625, _21=1.5625, _23=2.25, _28=2.25, _34=2.25, _35=2.25, _36=2.25, _37=6.25, _38=6.25, _39=4, _40=5.0625, _41=4, _43=1.5625, _44=5.0625 |
| plain_big (389) | 13 | k_plain_mid_1..12a=1 (12 entries), k_plain_mid_12b=1 — full list: _1=1,_2=1,_3=1,_4=1,_5=1,_6=1,_7=1,_8=1,_9=1,_10=1,_11=1,12a=1,12b=1 |
| plain_huge (446) | 13 | big_hill_1=1, k_plain_1=1, _2=1, _3=1, _4=1, _5=1, _6=1, _7=1, _8=1, _9=1, _10=1, _11=1, _12=1 |
| ravine_big (503) | 8 | k_ravine_big_stone_1..8 = 1 each |
| ravine_medium (540) | 9 | k_ravine_1..9 = 1 each |
| plateau (581) | 5 | plt1=1, plt2=1, plt3=1, plt4_fixed=1, plt5=1 |
| plateau_small (606) | 6 | d_plt1..6 = 1 each |
| plateau_big (635) | 5 | f_plt_big_1=3, f_plt_big_2=3, f_plt_big_3=3, f_plt_mid_1=2, f_plt_mid_2=2 |
| mountains (660) | 7 | g_mnt_1..7 = 1 each |
| hills_dark (693) | 4 | hil1=1, hil2=1, hil3=1, hil4=1 |
| hills_light (714) | 9 | g_hil1..9 = 1 each |
| decor (755) | 3 | dcr1=1, dcr2=1, dcr3=1 |
| decor_big (772) | 1 | big_hill_1=1 |
| tiles (781) | 4 | d_tls_1=1, d_tls_2=1, d_tls_3=1, d_tls_4=1 |
| stoneforests (802) | 8 | str_new_1..8 = 1 each |
| stoneforests_old (839) | 8 | str_1=1, str_2=1, b_str_3=1, str_4=1, str_5=1, str_6=1, b_str_7=1, str_8=1 |
| stones (876) | 7 | d_stn_1..7 = 1 each |
| forests_pinefir_big (909) | 6 | d_frt_big_1..5=1, e_frt_big_3=1 |
| forests_pinefir_medium (938) | 6 | d_frt_mid_1..6 = 1 each |
| forests_pinefir_small (967) | 6 | d_frt_small_1..6 = 1 each |
| forests_spruce_big (996) | 4 | d_frt_spr_big_1..4 = 1 each |
| forests_spruce_medium (1018) | 4 | d_frt_spr_mid_1..4 = 1 each |
| forests_pinedrygreen_small (1040) | 4 | d_frt_pinedry_big_1..4 = 1 each |
| forests_pine_small (1062) | 6 | frt_s_p_1..6 = 1 each |
| forests_pine_medium (1091) | 10 | frt_m_p_1..10 = 1 each |
| forests_pine_big (1136) | 8 | frt_b_p_1..7=1, f1_from_big3=1 |
| forests_pine_big_2 (1174) | 3 | b_frt_b_p_1..3 = 1 each |
| forests_mixed_big (1191) | 3 | e_frt_big_1=1, e_frt_big_2=1, e_frt_big_4=1 |
| forests_mixed_medium (1208) | 5 | e_frt_mid_1..5 = 1 each |
| forests_leaf_big (1233) | 2 | g_frt_big_1=1, g_frt_big_2=1 |
| forests_leaf_medium (1247) | 2 | g_frt_mid_1=1, g_frt_mid_2=1 |
| forests_leaf_small (1261) | 6 | g_frt_small_1..6 = 1 each |
| swamp_small (1290) | 11 | m_swamp_small_1..11 = 1 each |
| swamp_big (1339) | 2 | k_swamp_1=1, k_swamp_2=1 |
| swamp_medium (1352) | 20 | m_swamp_1..20 = 1 each |
| lake_small (1437) | 12 | l_lake_small_1..12 = 1 each |
| lake_big (1490) | 11 | l_lake_big_1..11 = 1 each |
| pump (1539) | 15 | k_pump_1..15 = 1 each |
| christmas (1604) | 5 | new_year6=1, new_year7=1, new_year8=1, new_year9=1, new_year10=1 |
| desert_tiles (1629) | 6 | d_tls_1=1000, d_tls_1=1000, d_tls_2=0, d_tls_3=1000, d_tls_3=1000, d_tls_4=100 |
| desert_mng (1658) | 5 | mng_1=1, mng_2=1, mng_3=1, mng_4=1, mng_5=1 |
| desert_mni (1683) | 5 | mni_1=1, mni_2=1, mni_3=1, mni_4=1, mni_5=1 |
| desert_mnc (1708) | 5 | mnc_1=1, mnc_2=1, mnc_3=1, mnc_4=1, mnc_5=1 |
| desert_plain_small (1733) | 6 | desert_plain_6=1, _7=1, _8=1, _9=1, _12=1, _13=1 |
| plain_medium (1762) | 7 | desert_plain_3=1, _4=1, _5=1, _10=1, _11=1, _14=1, _15=1 |
| desert_plain_big (1795) | 2 | desert_plain_1=1, desert_plain_2=1 |
| desert_plateau (1808) | 4 | desert_plt2=1, desert_plt3=1, desert_plt9=1, desert_plt10=1 |
| desert_plateau_small (1829) | 4 | desert_plt6=1, desert_plt7=1, desert_plt8=1, desert_plt11=1 |
| desert_plateau_big (1850) | 3 | desert_plt1=1, desert_plt4=1, desert_plt5=1 |
| desert_mountains (1867) | 15 | desert_mnt_1..15 = 1 each |
| desert_stoneforests (1932) | 4 | desert_stn_5=1, _7=1, _8=1, _12=1 |
| desert_stones (1953) | 12 | desert_stn_1=1, _2=1, _3=1, _4=1, _5=0.5, _6=1, _7=0.5, _8=0.5, _9=1, _10=1, _11=1, _12=0.5 |
| desert_forests_big (2006) | 17 | n_desert_frt_big1..17 = 1 each |
| desert_forests_medium (2079) | 23 | n_desert_frt_m_1..23 = 1 each |
| desert_forests_small (2176) | 20 | n_desert_frt_s_1..20 = 1 each |
| desert_forests_unique (2261) | 12 | desert_frt_un_1..12 = 1 each |
| desert_lake (2314) | 12 | desert_lake_1..12 = 1 each |

**Coverage note `[D]`:** the 64 records are grouped by semantic family `[I]` — relief (`plain*`, `ravine*`, `plateau*`, `mountains`, `hills_*`, `decor*`, `tiles`, `desert_*` relief), mines/stone (`stones`, `stoneforests`, `desert_stones`, `desert_stoneforests`), forests (`forests_*`, `desert_forests_*`), water (`lake_*`, `swamp_*`, `desert_lake`, `pump`), market/start (`mng/mni/mnc` = market/iron/coal? `[U]`). Family labels are `[I]`; the file itself supplies only `Name`, `Pattern`, `Freq`.

---

## 8. `var\startingsettings.cfg` — start presets (`[O]` values, `[I]` meanings)

Grammar `[O]`: `startingsettings : section` → repeated `[*]` preset with `startid`, optional `dataversionmin/max`, global `addresources` (food/wood/stone/gold/iron/coil), repeated `countries[]` → `allowedcountries[]` (21 country ids each), per-country `addresources`, `legends[]` (`key`, `role`, `countrysid`, `basename`), and ASCII `mask[]` rows.

Counts `[O]`: 19 `startid` records; 18 `countries` blocks; 27 `addresources` blocks; 61 `legends` blocks; 61 `mask` blocks; 276 `key`/`role`/`countrysid`/`basename` quadruples; 21 distinct `allowedcountries` ids in all 18 country groups. Roles observed (id→count): `1`×83, `3`×4, `5`×9, `6`×1, `9`×4, `13`×14, `14`×7, `17`×4, `21`×6, `22`×6, `23`×3, `25`×8, `26`×8, `30`×6, `31`×3, `34`×2 `[O]`; enum names at `startingsettings.cfg:14-68` (`[O]`).

| Preset line | `startid` | `dataversionmin..max` | Global addresources (food/wood/stone/gold/iron/coal) | Mask rows × width `[D]` |
|---:|---:|---|---|---|
| 89 | -1 | — | 0/0/0/0/0/0 (example) | 7×41 |
| 183 | 0 | — | *(none)* | — |
| 187 | 1 | 60..1000 | 1000/0/0/0/0/0 | 14×41 |
| 314 | 2 | 60..1000 | 20000/0/0/0/0/0 | 24×41 |
| 503 | 3 | 60..1000 | 20000/0/0/0/6000/9000 | 28×48 |
| 720 | 4 | 60..1000 | 20000/0/0/1000/6000/9000 | 18×41 |
| 862 | 1 | 0..59 | 1000/0/0/0/0/0 | 14×41 |
| 989 | 2 | 0..59 | 20000/0/0/0/0/0 | 24×41 |
| 1178 | 3 | 0..59 | 20000/0/0/0/6000/9000 | 29×48 |
| 1396 | 4 | 0..59 | 20000/0/0/1000/6000/9000 | 20×41 |
| 1540 | 5 | — | 5000/5000/5000/5000/5000/5000 | 34×41 |
| 1701 | 6 | — | 20000/10000/0/1000/6000/9000 | 18×32 |
| 1826 | 7 | — | 20000/10000/0/1000/6000/9000 | 26×32 |
| 1989 | 8 | — | 20000/10000/0/1000/6000/9000 | 34×32 |
| 2178 | 9 | — | 65000/2000/2000/15000/6000/9000 | 41×45 |
| 2350 | 10 | — | 5000/1000/1000/2500/3000/3000 | 27×44 |
| 2526 | 11 | — | 1000/1000/1000/1000/2500/2500 | 44×45 |
| 2830 | 12 | — | 0/0/0/0/2500/2500 | 30×45 |
| 2973 | 13 | — | 1000/0/0/0/0/0 | 66×33 |

Mask characters are legend keys (`X` center, `P`TCenter, `B` drummer17, `O` officer17, `Q/W` market buildings, etc.) `[I]`; exact mask→world placement transform is not in this file `[U]`. Stage: **starts** `[I]`. The `dataversion` bands (0..59 vs 60..1000) are duplicated presets 1–4 with different resource mixes `[O]`; reason `[U]` (legacy data-version compatibility `[I]`).

---

## 9. Findings

| # | Finding | Label | Evidence |
|---:|---|---|---|
| F1 | `globalparams.cfg` has 20 keys; all literals reproduced verbatim in §4 | `[O]` | `globalparams.cfg:2-20` |
| F2 | `Size`, `CellsResolution`, all empty castle/pattern string keys have **no consumer found**; semantics UNVERIFIED | `[U]` | `globalparams.cfg:2,6,11,13-17,20`; `T6_S01_camera.md:190-192` |
| F3 | `TileSmoothPasses=6` is editor-facing; skirmish smoothing uses 3 passes | `[D]` | `globalparams.cfg:9`; `smoothtiles.inc:237`; `TERRAIN_BLEND_DONOR_PLAN.md:125-127` |
| F4 | `TileSmoothListFileName` names `tilesmooth.cfg`; runtime parser loads `tilesmooth_scripts.cfg` | `[D]` | `globalparams.cfg:10`; `smoothtiles.inc:5`; `TERRAIN_BLEND_DONOR_PLAN.md:105-109` |
| F5 | `tilesmooth.cfg` has **8** sections / 30 names, not the previously claimed 10 / 34 | `[O]` | full read `tilesmooth.cfg:1-129`; `DEC_03_configs.md:71` (superseded for this file) |
| F6 | `tilesmooth_scripts.cfg` = 22 chains / 130 groups (118 active) / 310 entries (282 active) / 86 names / Σ=174.0168 | `[O]` | parser + `tilesmooth_scripts.cfg:1-1863`; matches `RV_TRN_02` counts |
| F7 | Winter chains C11–C20 are exact `_winter` mirrors of C00–C09 | `[D]` | `tilesmooth_scripts.cfg:934-1810` vs `:4-880`; `T6_S03_smooth_chains.md:211-216` |
| F8 | `Prob=0` groups are endpoints-only; `grass_ground1` Σ anomaly = 1.0028 is authored, not a typo to fix | `[O]`+`[D]` | `:51-66`, `:449-452`, `:112-121` |
| F9 | `mapcover.cfg` binds **no seasonal tile names** — height-zone entry is a weight-only stub | `[O]`+`[D]` | `mapcover.cfg:11-15`; `DENV_01_environment.md:396` |
| F10 | `localparams.cfg` is a single editor record; its tiny heights (`0.0001`) are not the skirmish height scale | `[O]`+`[I]` | `localparams.cfg:3-16`; `DEC_05:496` |
| F11 | `generator.cfg` supplies 6+9 mask paths and 64 pattern families; 4 family names are duplicated so name-keyed maps lose records | `[O]`+`[D]` | `generator.cfg:2-66,69-2314` |
| F12 | `Freq` anomaly table `desert_tiles` has 1000/0/100 weights; `Freq` is a relative weight, consumer UNVERIFIED | `[O]`+`[U]` | `generator.cfg:1629-1657` |
| F13 | `startingsettings.cfg` = 19 presets (incl. 4 version-banded duplicates), 61 placement masks, 276 legend entries | `[O]` | `startingsettings.cfg:87-3423` |
| F14 | No seed/RNG/water-level/mine-count constant exists in any of the seven files | `[O]`/`[U]` | full reads + prior art (D02/D05–D07 own those) |
| F15 | All `.inc` consumer lines are `;`-prefixed, so the smoothing algorithm is *donor intent*, not proven live code | `[U]` | `smoothtiles.inc:4-242`; `GAPS.md:31` |

---

## 10. Implications for the port (`PORT APPROXIMATION` — not parity claims)

1. **PORT APPROXIMATION — smoothing must use `tilesmooth_scripts.cfg`, 3 passes, not `globalparams.cfg`'s 6 / `tilesmooth.cfg`.** Copy all 118 active groups (or at minimum the 59 Summer groups) verbatim; keep `Prob=0`, keep the `0.64/0.0028/0.36` anomaly, keep commented rules out. Evidence: §6.3–6.6. This is a donor-grounded approximation of *intent*, because the consumer lines are commented `[U]`.
2. **PORT APPROXIMATION — do not implement any constant from §4/§5 as a hard height scale.** `Size=512`, `FrequencyFactor=0.000013`, `HillsHeightFactor=0.001`, `MaxHeight=0.0001` lack recovered semantics; using them literally would invent behaviour (charter §4 "no invention").
3. **PORT APPROXIMATION — mask stage can be driven by `generator.cfg` terrain-type paths (6 base + 9 DLC5)**, with DLC5 adding Coastal/Lakes/Rivers. F04 must supply the TGA channel decoder; this report supplies only the path/name table.
4. **PORT APPROXIMATION — pattern/forest/stone/mine/water selection can use `generator.cfg` `Patterns` weights** as roulette weights, but the spawn rules (counts, radii, collision) are in scripts/binary and are **out of this report's scope** `[U]`. Preserve duplicate family records and extreme `Freq` values verbatim if transcribing.
5. **PORT APPROXIMATION — start placement can use `startingsettings.cfg` 19 presets and ASCII masks**; a port must choose which `dataversion` band it emulates (0..59 vs 60..1000) `[I]`; do not average the two.
6. **PORT APPROXIMATION — `mapcover.cfg` gives no art names**; any tile-name→height mapping in the port comes from scripts (`texturemap.inc`) and `terrain.presets` (F05), not from this config. Do not "complete" the empty seasonal names.

---

## 11. Risks

| Risk | Label | Mitigation |
|---|---|---|
| Treating `TileSmoothPasses=6` as the runtime truth → wrong seam statistics | `[D]` | Use 3 (`smoothtiles.inc:237`), document the 6 as editor-only |
| Feeding `tilesmooth.cfg` (plain lists) to a weighted roulette → no probabilities | `[O]` | Use `tilesmooth_scripts.cfg` for weighted smoothing; keep the other as editor-only |
| Name-keyed `Patterns` map silently drops 4 duplicate families | `[D]` | Key by record index; preserve order of all 64 records |
| "Normalising" `Prob=0` or the 1.0028 group sum | `[O]` | Preserve literal weights; they are endpoints/author anomaly |
| Copying editor-only `localparams.cfg` heights into skirmish height field | `[U]` | Keep editor constants out of the height pipeline until D05 confirms |
| Assuming Winter smoothing chains are selected at runtime | `[U]` | Mirror them verbatim in data; selection logic UNVERIFIED |
| Misreading `_winter` names as the port's `winterN` art aliases | `[I]` | Keep name spaces distinct; alias map is an approximation (`T6_S03:262-270`) |
| Port applying donor `Freq` weights without knowing the sampler | `[U]` | Mark as PORT APPROXIMATION; no visual parity claim |

---

## 12. UNVERIFIED register

| # | Item | Why UNVERIFIED |
|---:|---|---|
| U1 | Semantics/units of `Size=512`, `CellsResolution=1` | no script consumer found; prior audit agrees (`T6_S01_camera.md:190-192`) |
| U2 | Meaning of `Sharpness`, `TileChangeFactor`, `FrequencyFactor` | names only; no consumer in read files |
| U3 | `FailStandCount=16`, `CastlePlateauFactor=5`, all castle/pattern string keys | names only |
| U4 | Consumer of `gen\tilesmooth.cfg` (editor table) | `globalparams.cfg:10` names it; no parser call found; `smoothtiles.inc:5` uses the other file |
| U5 | Whether `smoothtiles.inc` is live code | all its lines are `;`-prefixed (`smoothtiles.inc:4-242`) |
| U6 | Runtime selection of C11–C20 Winter chains | no season switch found |
| U7 | `Freq` sampling algorithm / normalisation in `generator.cfg` | consumer not in these files |
| U8 | Meaning of `mng/mni/mnc` family abbreviations | names only |
| U9 | Mask ASCII→world coordinate transform and collision rules | not in `startingsettings.cfg` |
| U10 | Reason for duplicated `startid 1..4` under two dataversion bands | names only |
| U11 | Whether `localparams.cfg` record is used by skirmish at all | prior art says editor-only (`DEC_05:496`) |
| U12 | Any seed, RNG, water level, mine count, forest radius constant | absent from all seven files |

---

## 13. Open questions (hand-off)

1. **D02/D05:** which binary function consumes `globalparams.cfg:2-8`? Until then `Size`/`CellsResolution` stay `[U]` and must not become port constants.
2. **F09/D03:** does any live script call the plain `tilesmooth.cfg` lists, or is `:10` a stale editor pointer? This decides whether F03's 8-section table is entirely editor-only.
3. **D06:** water/shore thresholds are in `texturemap.inc` (prior art `-0.25`/`-0.1`), not in `mapcover.cfg`; confirm against binary before porting.
4. **F02/F08:** resolve each `generator.cfg` `Pattern` name to a `pattern.lib` record and object list; verify that duplicate `Name` records are intentional.
5. **F09/F10:** locate the code that reads `var\startingsettings.cfg` masks and chooses the dataversion band; determine whether DLC overrides any of the 19 presets.
6. **A02/A05:** decide whether to transcribe all 22 chains (including Winter) into a fresh port data file; maintain literal names and weights if so.
7. **COORD:** reconcile F03's 8-section `tilesmooth.cfg` count against prior claims of 10 in `DEC_03_configs.md:71` and `DEC_05:410` before integrating the spec.

---

## 14. Five-line hand-off summary

1. `[O]` Seven donor configs hashed and fully parsed: 20 global knobs, 13 local knobs, 15 mapcover values, 8 plain + 118 weighted smoothing groups, 64 pattern families/493 weights, 19 start presets.
2. `[D]` Keep both donor conflicts verbatim: `TileSmoothPasses=6` vs script 3; `tilesmooth.cfg` path vs `tilesmooth_scripts.cfg` actually loaded.
3. `[O]` `tilesmooth_scripts.cfg`: 22 chains, 118 active groups, 282 active entries, 86 names, ΣProb=174.0168; full verbatim transcription in §6.4.
4. `[U]` No seed/RNG/water/mine constants here; all semantic readings of `Size`, `CellsResolution`, `Freq`, castle keys are inferred and must not become port constants unlabelled.
5. `PORT APPROXIMATION` only: use donor literals as data, preserve anomalies and Prob=0 endpoints, and make no donor visual-parity claim.
