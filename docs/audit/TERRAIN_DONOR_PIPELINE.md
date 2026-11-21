---
title: Donor terrain pipeline — first-principles read of the plaintext scripts
owner: TDR-1 (research/deep-dive lane)
decision: terrain beauty / donor fidelity
updated: 2026-11-21
status: FINAL — read-only; no Godot run, no code edit, no donor asset copied
protocol: SWARM_OPS.md §5b-QUALITY (no speculative claims; every claim cites a file:line or evidence id; observed / derived / inferred / UNVERIFIED)
---

# Donor terrain pipeline (TDR-1)

> [!IMPORTANT]
> This document is the **only file written by this agent**. Nothing in `app/`,
> `assets/`, or any other `docs/` file was created or modified. The donor was
> accessed **read-only** under the private-use rule; no donor binary, texture,
> mask, `.pattern`, or TGA was copied into the repository. No Godot process was
> started. All line numbers below are 1-based and refer to the donor files as
> installed at `C:\Games\Cossacks 3` on 2026-11-21 (hashes not taken; sizes
> recorded in §1 so a later reader can detect a changed install).

---

## 1. Sources read (paths + sizes)

### 1.1 Primary donor plaintext scripts

| # | Absolute path | Bytes | Lines | Role |
|---|---|---|---|---|
| D1 | `C:\Games\Cossacks 3\data\scripts\common.inc\dogenerate.inc` | 109,219 | 2,102 | Master pipeline, pattern stamping, mines, starts, owner flood fill |
| D2 | `C:\Games\Cossacks 3\data\scripts\common.inc\generatemap.inc` | 51,794 | 1,058 | Mask → height/water/forest; smoothing; water fields |
| D3 | `C:\Games\Cossacks 3\data\scripts\common.inc\initmapgen.inc` | 13,193 | 288 | Players, teams, seed, `DoGenerate` entry point |
| D4 | `C:\Games\Cossacks 3\data\scripts\common.inc\texturemap.inc` | 48,954 | 962 | Shore/height thresholds, collision, tile art, forest objects, roads |
| D5 | `C:\Games\Cossacks 3\data\scripts\common.inc\smoothtiles.inc` | 10,691 | 245 | Tile-compatibility smoothing passes |
| D6 | `C:\Games\Cossacks 3\data\scripts\common.inc\smoothforestborders.inc` | 7,791 | 170 | Forest-edge feathering / `fb_*` stamping |
| D7 | `C:\Games\Cossacks 3\data\scripts\common.inc\postprocess.inc` | 19,416 | 465 | Noise + Gaussian blur of the heightmask (editor path only) |
| D8 | `C:\Games\Cossacks 3\data\game\var\generator.cfg` | 70,074 | 2,366 | TerrainTypes, Pattern families, per-pattern `Freq` weights |

### 1.2 Supporting donor file (helper definitions, read for exact semantics)

| # | Absolute path | Bytes | Lines | Role |
|---|---|---|---|---|
| D9 | `C:\Games\Cossacks 3\data\scripts\lib\misc.script` | 250,432 | 6,765 | `_misc_CheckStandPattern(Ext)`, `GetPatternNameByParser`, `PatternIncreaseFreq`, `SetupPatternsByType`, `GetFreePatternMask*Modifier` |

### 1.3 Project documents read for grounding / cross-check (not new evidence)

- `docs/TERRAIN_GEN_RESEARCH.md` (86 lines) — prior pipeline summary.
- `docs/research/RC_TERRAIN.md` (239 lines) — feature-gap analysis.
- `docs/audit/GEN.md` (423 lines) — generator-quality audit.
- `docs/audit/RENDER.md` (365 lines) — visual-fidelity audit.
- `docs/decomp/DB_SCRIPTS.md` (read lines 48–77) — prior decompile-derived pipeline; used **only** as a cross-check, not as a claim source.

### 1.4 Port files read only to anchor recommendations (no edits)

- `app/scripts/mapgen.gd` (199 lines), `app/scripts/pattern_gen.gd` (267 lines),
  `app/scripts/game.gd` (relevant ranges 485–766, 982–1011, 1250),
  `app/scripts/data.gd` (relevant constants).

---

## 2. Pipeline stage table

Order is the literal call order in `DoGenerate` (D1) with nested `ExecuteState`
calls expanded. Stage numbers are this document's, not donor identifiers.

| Stage | Donor function / file:line | What it does | Port implication |
|---|---|---|---|
| 0 | `InitMapGen` D3:4–19, :99, :146, :232–239 | Creates 8 players + env/service players; `SetRandomKey(randkey1)` twice; `ExecuteState('DoGenerate')`; then `MapWorldUpdateTerrainData`, `TopologyBuild`, `BuildIslandsGrid`. | Port has a single seed and a simpler stage order; RNG re-seeding before each stage (D1:1538, :1616, :1772, :1909, :1927) is the donor's determinism contract — mirror it, do not use one continuous RNG stream. |
| 1 | D1:4–6, :407–416 | `bDesert := (season=3)`. `foreststype := floor(RandomExt*3)` **immediately overwritten to 0** (pine/fir/spruce). Keep-clear ellipse constants C1 5×7, C2 12×15, C3 22×18; `cBorderObjDist=1`. | Port already mirrors C1–C3 in `pattern_gen.gd:10–12`. The forced `foreststype=0` is **not** mirrored — the port's mixed/leaf recipes at `pattern_gen.gd:243,255` are non-donor for vanilla. |
| 2 | `ClearMapMaskAndObjects` D1:444–481 | Zeroes `gPatternMask[0..639,0..639]`, `ResetPatternMap(False)`, destroys all player objects, clears collision `MapDrawCollision(0,0,0,r*2-2,False)`. | Occupancy grid must start empty **and** must be pre-filled from mask layers before stamping (see stage 6/8); port `pattern_gen.gd:48–49` starts empty and only marks ellipses. |
| 3 | `SetupTiledPatterns('tiles'` / `'desert_tiles')` D1:1330–1359, called :1530–1536 | `cSize=25` cell grid; `wcount=floor(mapW/25)`, `hcount=floor(mapH/25)`, loops `0..wcount` **inclusive**; centre `round(x*25+12−mapW/2−1)`; weighted pick per cell; one `CheckStandPattern` + `PatternIncreaseFreq` per cell. `SetupTiles(freq)` D1:499–519 (64 attempts, `tls_1..4`, skips `tls_3`) is **commented out** at D1:1593. | Port `pattern_gen.gd:180–201` uses `tile_step = max(6, 60*s)` = 120 at s=2, i.e. ~3× sparser than the donor's 25-unit grid and with a different centring. This is the base "cracked-earth" texture layer; fix the grid before tuning art. |
| 4 | D1:1542–1565 | `relieftype`, `terraintype`, `minesdensity` read from settings. `TerrainTypes` (pre-91) or `TerrainTypesDLC5` (91+) selected; out-of-range → random `floor(RandomExt*6)` / `*gc_MaxTerrainTypeCount`. `path` → `StringRegister0`; `BoolRegister0:=True`; `ExecuteState('GenerateMap')`. | Port `data.gd:184–188` has RELIEF (plains/hills/mountains) but it only scales domes (`game.gd:641–657`); the donor's relieftype is a **stamp-frequency table**, not a height multiplier. |
| 5a | `GenerateMap` D2:216, :139–208, :285–503 | `SetRandomExtKey64(randkey0,randkey1)`. Random mask chosen from `<terrainmasks>/<type>\*.tga` by `floor(RandomExt*count)`; mask path/name written back to record manager. Pure-white pixels (`fr=fg=fb=1`) become `arrStartPos` (deduplicated, transformed to centred coords at :500–502). | Port `mapgen.gd:39–49,63–84` picks the mask and extracts starts, but uses the **farthest pair** of markers rather than the donor's team-aware `RandomStartingPoints`. |
| 5b | D2:311–495 | Mask channel decode: R codes → `terrain` class + `bsmooth` flag; G codes → forest class; B=255 → water; alpha>0 → `broad` (road); pure black/white → pattern-mask stays free. Exact codes in §3. | Port `mapgen.gd:148–176` averages RGB down to three scalars; it does **not** decode the smooth colour variants, `broad`, or `bsmooth`. Consequence quantified in claim C3. |
| 5c | **Height** D2:552–578, formula at :567–574 | `hwater = cWaterHeight*(fb*(1+fr*3.5))` with `cWaterHeight=-1.1`; `hterrain = cPlateauHeight*fr` / `cHillHeight*fr` / `cRavineHeight*fr` selected by the R-decoded class; `SetHeightData(hwater+hterrain)`. Pure-white start pixels skipped (:565–566). | Port `mapgen.gd:174–175` matches the water term exactly; the terrain term uses a threshold approximation (`relief()`), not the donor's class×R formula. See C3. |
| 5d | Smoothing D2:580–596, :598–608, :611–640 | (i) `SmoothTerrain(...,3)` on every `bsmooth` cell. (ii) one global pass `_misc_SmoothTerrainCustom(times=1,power=4,lerp=0.5,minh=0.01,maxh=100)`. (iii) **3 passes** of coastal smoothing, radius 2, applied only to cells whose own or a neighbour's mask-B is water **and** whose height is in `[−100,−0.01]`, with `power=0.35, lerp=0.5`. | Port `mapgen.gd:179–196` does 3 (or 1/2 by quality) passes but uses `height<0.8`/`height<−0.1` instead of mask-B and smooths **all** near-water cells, not just the underwater band. Different coastline profile. |
| 5e | Water fields D2:646–709 | `cWaterFieldSize=2`, grid `640/2`; a 2×2 cell is water if any pixel has `B>0 and (R<1 or B<1)`; `WaterFieldAdd(..., cOffsetY=-0.5)`. | Port derives water from `height<−0.25`; donor's water *mesh* flag comes from mask B, not from the height test (the height test is only for collision/tiles in D4). |
| 5f | `ExecuteState('TextureMap')` D2:770–779; D4 full file | Collision, forest object stamping, env bitmap, tile art, roads. `forestType` passed via `IntRegister0` = `cForestTypePineFirSpruce` (D2:54, :775). Detailed in stages 9–11 below. | Port `game.gd:706–730` implements only slope collision and `game.gd:748–751` only a straight road; the donor's slope-direction tile art and forest object pass are absent. |
| 5g | `ExecuteState('SmoothTiles')` D2:781–789; D5:4–242 | Loads `tilesmooth_scripts.cfg`, builds 64 probability tables, `GetNeighbourTiles` compatibility resolution, `SmoothTileMap(0,0,W,H,3)` — **3 passes** horizontal+vertical. | Port `game.gd:1011 _assign_tileblocks` has no equivalent compatibility pass. This is a visible "tile seams / checker" quality lever. |
| 5h | Editor-only tail D2:711–768, :791–798, :801–893, :1009–1042 | `PostProcess` Gaussian, `LoadTextureTerrainFromBitmap`, free `plain_*` forests, wheat seeding, topology — all guarded by `not bRandomMap`. `PostProcess` is **not** invoked for random maps. | Port should not try to reproduce `postprocess.inc` for skirmish maps; donor random masks are pre-blurred by the author (hence the port's `*_gauss.png`). |
| 6 | D1:1568–1581 | After `GenerateMap`, any cell with `height < cWaterShoreHeight (−0.1)` is added to `gPatternMask` — the shore exclusion band. | Port `pattern_gen.gd:85–95` never marks shore as occupied; only exact `water_id` centre cells are skipped. |
| 7 | D1:1586–1590, :1596–1616 | `minesdensity>2 → floor(RandomExt*3)`; desert → `_misc_SetDesert(False,False)`; collect `arrStartPos`, `_misc_FillPatternMaskMapBorder(3)`, `RandomStartingPoints(spcount,minesdensity)`, `SetRandomKey`. | Port `game.gd:731–747` merely snaps starts off water; no border keep-clear, no team-aware point selection. |
| 8 | `GenerateTeamStartingPoints` D1:999–1088, `RandomStartingPoints` D1:1090–1229 | Legacy (<61) random pick; modern path groups by `gMap.players[i].team`, supports `teams=nearby`, picks a first point then repeatedly the candidate that is nearest to already-chosen points / farthest from busy points (`VectorDistance` comparisons at :1048–1084). | Port is 2-start only; this explains "clustered per side" resources. Team option is a prerequisite for faithful macro layout. |
| 9 | Relief passes D1:1621–1770 | `relieftype>4 → floor(RandomExt*5)`; table → `plt/mnt/hil`; scaled by `problarge`; `plain=0.0001/2`; family setup: `mountains`, `plateau_big`, `plain_huge`, `ravine_big`, `plateau`, `plateau_small`, `hills_dark`, `hills_light` (desert equivalents at :1747–1754); then `SetupMines(...,minround=1,maxround=0,...)` for each start. | Port `game.gd:638–657` uses analytic Gaussian domes. Donor relief is **stamped multi-object patterns** with the exact frequencies in §3 — this is the single biggest fidelity gap for hills/mountains. |
| 10 | Forest/stone/decor passes D1:1774–1907 | `frs_big=0.0009`, `frs_mid=0.0009`, `frs_small=0.00054`, `stn1=0.00016`, `stn2=0.00012`, scaled by `probsmall/mid/large`; foreststype=0 selects `forests_pinefir/spruce/pine_{big,medium,small}`, `forests_pine_big_2`, plus `stones`, `plain_*`, `swamp_*`, `lake_*` (=0), seasonal `pump`/`christmas`. Desert uses `desert_*`. | Port `pattern_gen.gd:247–265` uses an invented 7-recipe list with `area_scale` counts; no `prob*` scaling, no relieftype coupling, no Freq damping, lake disabled. |
| 11 | Units + scale fix D1:1914–2027 | 18 peasants per start on a 3-column grid (`cUnitR=0.75`, :1255–1267); `_misc_PreloadTextures`; per-object random scale clamped to `[minfact,maxfact]` with 5% dead-band; **winter destroys all `leaftree` objects** (:1975–1982). | Port has no winter object deletion and no donor min/max scale jitter; `world.gd` has no season texture swap (confirmed independently in `docs/audit/RENDER.md` §D). |
| 12 | `FillOwnerMap` D1:2062 (impl :1370–1428) | BFS over `gScanGrid` from every start, 4-neighbour, assigning `owner` and `dist`. | Gives per-player territory; used by border placement. Port has no owner grid. |
| 13 | `SetupBorderObjects` D1:2064–2065 (impl :1430–1527) | **Only when `gbool_peacemode`**; walks owner-boundary cell edges and places `gc_basename_ptborder` / `..._ptborderwater` markers at spacing `cBorderObjDist=1`. | These are invisible territory markers, **not** rocks/trees. Prior doc `docs/TERRAIN_GEN_RESEARCH.md:54-57` should be corrected. |
| 14 | Finalize D1:2068–2100 | `_misc_SetShoresCollision`, `_misc_FixCollisionInertiaObjectsInOnePoint`; winter colour table 6 / PHDR 1, desert table 7, else 0 / PHDR 0; `TimeLog('Generation finished...')`. | Port's "snow" is a tint (`data.gd:196–197`), not the donor's table + object swap. |

---

## 3. Constants / thresholds table

All values are literal donor source values. "Derived" columns are arithmetic on
those literals, not new assumptions.

### 3.1 Height, water, shore

| Name | Value | Donor source | Meaning |
|---|---|---|---|
| `cPlateauHeight` | `2.964` | D2:4 | Plateau relief amplitude at R=255 |
| `cHillHeight` | `cPlateauHeight/2.25` = `1.31733…` | D2:5 | Hill relief amplitude at R=96 |
| `cRavineHeight` | `-2.964` | D2:6 | Ravine relief amplitude at R=48 |
| `cWaterHeight` (height gen) | `-1.1` | D2:7 | Water-depth term scale in `hwater` |
| R multiplier | `3.5` | D2:567 | `hwater = -1.1*fb*(1+fr*3.5)` |
| `cWaterHeight` (classification) | `-0.25` | D4:30 | Deep-water/height test used for collision + tile art (distinct constant from D2:7) |
| `cWaterShoreHeight` | `-0.1` | D4:31; also D1:1576 | Wet-sand/shore test, and shore exclusion band in `gPatternMask` |
| `cMaxHeight` | `2.96` | D4:29 | Nominal max terrain height |
| `cRColorPlateau` / `Hill` / `Ravine` | `255` / `96` / `48` | D2:21–23; D4:16–18 | Exact R codes |
| `cRColorSmooth` | `128 div 2 = 64` | D2:24; D4:19 | "no relief but smooth me" code |
| `cRColorPlateauSmooth` / `HillSmooth` / `RavineSmooth` | `(255/2)+64 = 191` / `(96/2)+64 = 112` / `(48/2)+64 = 88` (integer div) | D2:25–27; D4:20–22 | Smoothed variants — still carry their relief class |
| `cGColorForest` / `GenForest` / `Stone` / `ForestStone` | `255` / `64` / `128` / `192` | D2:28–31; D4:23–26 | G channel class codes; G=127 (`255 div 2`) → forest only if R class ≠ none (D2:373–377) |
| `cBColorWater` | `255` | D2:32; D4:27 | B channel water code |
| `cDiff1` / `cDiff2` | `0.5` / `0.55` | D4:63–64 | Cardinal / diagonal height-difference collision gates |

### 3.2 Smoothing

| Pass | Parameters | Donor source |
|---|---|---|
| Bitmap-smooth cells | `SmoothTerrain(realx, -realy, False, 3)` | D2:587–592 |
| Whole map (land) | `times=1, power=4, lerp=0.5, minh=0.01, maxh=100` | D2:606; helper D2:218–245 |
| Coastal **underwater**, 3 passes | radius `rad=2`; `_misc_SmoothTerrainCustom(times=1, power=0.35, lerp=0.5, minh=-100, maxh=-0.01)` | D2:612, :625, :636–637 |
| Helper formula | `res = h + (( (lt+rt)/2 + (lb+rb)/2 )/2 − h)/power; res = Lerp(h,res,lerp)` | D2:238–242 |
| Tile smoothing | `SmoothTileMap(0,0,W,H,3)` | D5:237 |
| Forest-border smoothing | neighbour count `=1` on grid code 2/3 with r=0; `count = floor(1+RandomExt*16)` objects per cell; placement radius `1.5`; `fb_` index `1+floor(RandomExt*53)`; code-3 extra probability `0.025` | D6:36, :65, :100, :104, :108, :113 |
| Gaussian blur (editor only) | final `r=0.925`, `rs=Round(r*2.57+0.5)=3`; weight `Exp(-dsq/(2r²))/(PI*2r²)`; pre-pass r≈0.00001 | D7:349–352, :369, :437, :441 |

### 3.3 Terrain seam and tile art

| Constant | Value | Donor source | Meaning |
|---|---|---|---|
| High mountains | `abs(height)>2.7 → rock8`; `>2.4 → rock4`; `abs(height)<0.1 → no tile` | D4:594–601 | Rock-vs-sand tile selection by slope aspect |
| Shore tile set | 8 sectors, `cAngle=45°`, tiles `sandsea1/5/6` by aspect | D4:474–529 | Spatial orientation of wet-sand art |
| Forest `cLiteProb` | `0.6` | D4:312 | `n_small_frt_lite_*` vs `n_small_frt_*` |
| Roads | `ground1` if `RandomExt>0.5`; `test2` if `>0.25`; else `test3` | D4:627–636 | Applied only where mask alpha (`broad`) set |
| Winter tile suffix | `_winter` appended when `GetSeasonType=2` | D4:525–526, :605–606, :639–640; D6:138–139 | Tile-set swap |

### 3.4 Pattern stamping

| Constant | Value | Donor source | Meaning |
|---|---|---|---|
| Start ellipses C1/C2/C3 | `5×7`, `12×15`, `22×18` | D1:407–414 | Keep-clear zones around each start; C3 filled at :947 but its placement block is fully commented (:949–977) |
| Map border keep-clear | `r=3` | D1:1613 (impl :67–78) | Bans patterns within 3 cells of the edge |
| `SetupTiles` | `needed=floor(W*H*freq)`, `trycount=64`, names `tls_1..4` skipping `tls_3` | D1:499–519 | **Dead**: call commented at D1:1593 |
| `SetupTiledPatterns` | `cSize=25`, loops `0..floor(W/25)` inclusive → `13×13=169` cells at W=320 | D1:1335–1345 | Base tile-crack layer |
| `SetupMines` | `trycount=256`; `rounds = 3/4/5` for density `0/1/2`, clamped by `maxround` | D1:525, :528–534 | Per-start mine rings |
| Mine radii (current, `gRecordGeneratorVersion≥80`) | small map (≤2) & ≤4 players: round0 `14+8r`, round1 `32+10r`, round3 `70+12r`, round4 `22+16r`, round5 `continue` (**round 2 unassigned**); large (>2): round0 `14+8r`, round1 `32+10r`, round2 `70+12r`, round3 `22+16r`, round4 `continue` | D1:594–645 | `r=RandomExt`; radius depends on **round**, not resource kind; see C10 |
| `SetupStartingResources` | `trycount=128`, `trycount2=3`, `smalltry=4`; distance `mindst + RandomExt*3 + ((i+j)*0.5)`; stone ring at `mindst+4` | D1:724–726, :754, :793, :848, :880, :933 | Guaranteed resource clumps |
| `SetupPatternsByType` | `needed=floor(W*H*freq)` (rounds to 1 if freq>0 but floor=0); `trycount=floor(256*mapsizeoptimise)`, `mapsizeoptimise=(320²)/(W*H)`, and if `<1` multiply by `0.65` | D9:3686–3704 | Attempt budget per placement |
| Free-mask availability | `cSmall=340, cMid=182, cLarge=74, cHuge=55`; `prob{small,mid,large,huge}=count(testsize {12,16,24,29})/c{...}`; count samples 32,000 random positions × 4 tries | D9:3896–3897, :3931–3941 | Density scales with how much free space each footprint size can find |
| Size modifier | `640/((W+H)/2)` when W≠640 or H≠640; applied to all four `prob*` | D1:1718–1725 | Map-size calibration |
| `Freq` damping | on each successful placement `newfreq = oldfreq*0.2`, floor `0.0001`; `FreqSum` and `UsedCount/TotalCount` updated | D9:3590, :3615–3624 | Same pattern becomes progressively rarer → variety |
| Rejection test | footprint from the pattern's own mask; fail if any stand-cell is out of bounds or `gPatternMask` already set; fast path samples every 4th cell when angle=0; `Ext` = test-then-stand | D9:3384–3512 (step at :3441; full test :3475–3511), :3516–3521 | Single source of truth for "no overlap" |
| Weighted pick | roulette over `FreqSum` | D9:3634–3653, FreqSum built :3523–3564 | Family member selection |

### 3.5 Relief table (exact, `relieftype = 0..4`)

| relieftype | `plt` | `mnt` | `hil` | Source |
|---|---|---|---|---|
| 0 | 0.000010 | 0.000020 | 0.000075 | D1:1625–1629 |
| 1 | 0.000020 | 0.000002 | 0.000125 | D1:1630–1634 |
| 2 | 0.000075 | 0.000075 | 0.000030 | D1:1635–1639 |
| 3 | 0.000055 | 0.000120 | 0.000050 | D1:1640–1644 |
| 4 | 0.000090 | 0.000035 | 0.000035 | D1:1645–1649 |

Each is multiplied by `problarge` (D1:1737–1739) and then distributed:

| Family | Frequency expression | Source |
|---|---|---|
| `mountains` | `mnt` | D1:1757 |
| `plateau_big` | `plt/3` | D1:1758 |
| `plain_huge` | `pln_huge` | D1:1759 |
| `ravine_big` | `plt/1.5` | D1:1761 |
| `plateau` | `plt/3` | D1:1762 |
| `plateau_small` | `plt/3` | D1:1763 |
| `hills_dark` | `hil/2` | D1:1764 |
| `hills_light` | `hil/2` | D1:1765 |

Global base frequencies D1:1688–1693, :1727–1739:
`frs_big=0.0009`, `frs_mid=0.0009`, `frs_small=0.00054`, `stn1=0.00016`, `stn2=0.00012`;
`plain=0.0001/2`; `pln_small=plain*6*probsmall`; `pln_mid=plain*2*probmid`;
`pln_large=plain*problarge`; `pln_huge=plain*probhuge`;
`swamp_big=plain*problarge`, `swamp_medium=plain*2*probmid`, `swamp_small=plain*6*probsmall`;
`lake_big=plain*2*0=0`, `lake_small=plain*0=0` (**lakes disabled in random maps**).

### 3.6 Selected families and their `generator.cfg` weights (D8)

Pattern counts per family (parsed from D8 `Patterns` blocks; every family below
is referenced from D1 or D4). `Freq` is 1 for every member unless noted.

| Family (D8 line) | Patterns | Sum Freq | Where used |
|---|---|---|---|
| `mng`, `mni`, `mnc` (:69, :98, :127) | 6 each (one `Freq=0` legacy) | 5 each | D1:548–550 mine rounds |
| `plain_small` (:207) | 19 | 13.0625 (0.25/0.5625/1) | D1:1906, D2:835–838 |
| `plain_medium` (:288) | 31 | 74.6875 (1…6.25) | D1:1854 etc. |
| `plain_big` (:389) | 13 | 13 | D1:1853 etc. |
| `plain_huge` (:446) | 13 | 13 | D1:1759 |
| `ravine_big` (:503) | 8 | 8 | D1:1761 |
| `plateau`, `plateau_small`, `plateau_big` (:581, :606, :635) | 5 / 6 / 5 | 5 / 6 / 13 (2 and 3) | D1:1758, :1762–1763 |
| `mountains` (:660) | 7 (`g_mnt_1..7`) | 7 | D1:1757 |
| `hills_dark` (:693) | 4 (`hil1..4`) | 4 | D1:1764 |
| `hills_light` (:714) | 9 (`g_hil1..9`) | 9 | D1:1765 |
| `stones` (:876) | 7 (`d_stn_*`) | 7 | D1:1846, :1862; D4:209–217 |
| `stoneforests` (:802) | 8 (`str_new_*`) | 8 | D1:741 guaranteed near start |
| `forests_pinefir_big/medium/small` (:909, :938, :967) | 6 / 6 / 6 | 6 each | D1:1838, :1856, :1866 |
| `forests_spruce_big/medium` (:996, :1018) | 4 / 4 | 4 each | D1:1839, :1855 |
| `forests_pine_small/medium/big/big_2` (:1062, :1091, :1136, :1174) | 6 / 10 / 8 / 3 | 6 / 10 / 8 / 3 | D1:1860, :1857, :1840–1841 |
| `forests_mixed_big/medium` (:1191, :1208) | 3 / 5 | 3 / 5 | D1:1886, :1890 (case 2, unreachable) |
| `forests_leaf_big/medium/small` (:1233, :1247, :1261) | 2 / 2 / 6 | 2 / 2 / 6 | D1:1872 etc. (case 1, unreachable) |
| `swamp_small/big/medium` (:1290, :1339, :1352) | 11 / 2 / 20 | 11 / 2 / 20 | D1:1899–1901 |
| `lake_small`, `lake_big` (:1437, :1490) | 12 / 11 | 12 / 11 | D1:1902–1903 (frequency 0) |
| `pump`, `christmas` (:1539, :1604) | 15 / 5 | 15 / 5 | D1:1848–1851 (event gated) |
| `tiles` (:781) | 4 (`d_tls_1..4`) | 4 | D1:1535 → D1:1343 |
| `desert_*` families (:1629–2366) | 2–23 each | mostly all-1; `desert_tiles` Freq 1000/1000/0/1000/1000/100 | D1:552–553, :733–738, :1747–1754, :1803–1833 |

### 3.7 Season / misc

| Constant | Value | Source |
|---|---|---|
| Desert season id | `3` | D1:4, D1:2079 |
| Winter colour table / PHDR | `6 / 1` | D1:2075–2077 |
| Desert colour table | `7` | D1:2079–2080 |
| Default colour table / PHDR | `0 / 0` | D1:2082–2083 |
| Starting resources (by `resourcestart`) | `1000 / 4000 / 5000 / 1000000` | D3:166–189 |
| Peace time | `gbool_peacemode := peacetime<>default`; gates border objects | D1:2059–2065 |

---

## 4. Claim table

Verdict vocabulary: **observed** = literal line read; **derived** = arithmetic
or code-path consequence of observed lines; **inferred** = attribution with no
direct proof; **UNVERIFIED** = could not be confirmed from the files read.
"Correction" is what the consumer of this report should change in its model of
the donor or in the port's ticket list.

| # | Claim | Evidence (file:line) | Verification method | Verdict | Required correction |
|---|---|---|---|---|---|
| C1 | Random-map height is `h = -1.1*fb*(1+fr*3.5) + reliefClass*fr`, where `fr,fb∈[0,1]` | D2:567–574; constants D2:4–7 | Direct read of both terms and `SetHeightData` | **observed** | None; port `mapgen.gd:174–175` matches the water term. |
| C2 | Water/shore classification uses `-0.25` / `-0.1`, distinct from the `-1.1` in the height formula | D4:30–31, :68–75; D2:7 | Read both constant blocks | **observed** | Keep the two `cWaterHeight` names distinct in port docs. |
| C3 | Port `relief()` is wrong for every **smooth** R code: smooth plateau/hill get ~0.5× amplitude, smooth ravine gets the **wrong sign** (port +0.511 vs donor −1.023 at R=88); R=64 ("none", smooth) gets a spurious +0.372 bump | Donor class decode D2:352–370, D2:454–472 + amplitude D2:569–573; port `mapgen.gd:51–61`, :174–175 | Compute donor value `cPlateauHeight*(code/255)` etc. and compare to `relief()` branches for codes 191/112/88/64 | **derived** (donor observed, port delta computed) | Replace `relief()` with exact code→class→amplitude mapping; highest-priority beauty fix. |
| C4 | Coastal smoothing is 3 passes, radius 2, but applies **only** to cells with height in `[−100,−0.01]` whose own or a neighbour's mask-B is water; `power=0.35, lerp=0.5` | D2:611–640 (loop :612, rad :625, gate :621–635, call :637); helper D2:238–242 | Direct read | **observed** | Port `mapgen.gd:86–110,179–196` uses height<0.8/<−0.1 and smooths all near-water cells; align with mask-B + height band. |
| C5 | Global land smoothing is one pass with power 4, lerp 0.5 on h∈[0.01,100]; bsmooth cells get `SmoothTerrain(...,3)` | D2:587–592, :606 | Direct read | **observed** | Port has no equivalent global pass; add or document deliberate omission. |
| C6 | `PostProcess` Gaussian/noise runs **only** for editor bitmap maps (`not bRandomMap`); random maps use the mask as-is | Guard D2:509–517 and D2:507 (`if not bRandomMap`); `trgbitmap := srcbitmap` D2:529–534 | Call-site trace | **observed** → **derived** | Do not add Gaussian blur to skirmish generation; treat shipped `*_gauss.png` masks as already post-processed. |
| C7 | `foreststype` is drawn then **forced to 0** in vanilla; TextureMap independently receives `cForestTypePineFirSpruce` | D1:5–6; D2:51–55, :775 | Direct read | **observed** | Port's global mixed/leaf forest recipes (`pattern_gen.gd:243,255`) are non-vanilla; either gate behind a forest-type option or remove. |
| C8 | `SetupTiles()` exists but is **never called** (commented out); the base tile layer comes from `SetupTiledPatterns` only | Implementation D1:499–519; commented call D1:1593; live call D1:1530–1536 | Call-site grep + read | **observed** | Update port commentary `pattern_gen.gd:2-3` which claims SetupTiles is used. |
| C9 | Tiled patterns use a 25-unit grid with **inclusive** bounds → 169 cells at W=320; no rejection beyond footprint-vs-`gPatternMask` | D1:1335–1355 (`cSize` :1335, loops :1339–1340, stand :1349) | Arithmetic on literals | **derived** | Port `pattern_gen.gd:180–201` grid step 120 at s=2 is not donor-faithful. |
| C10 | Mine distance is indexed by **round**, and every round stamps one `mng`, one `mni`, one `mnc`; it is not "gold near / iron mid / coal far" by resource kind | Loop nesting D1:535–551 (`for i` rounds, `for j` restypes), `dst` assigned from `case i` at :559–655, one check per (i,j,k) at :704–713 | Direct read of nesting and `dst` scope | **observed** | Correct `docs/TERRAIN_GEN_RESEARCH.md:43–46` and port `pattern_gen.gd:203–237` (port pairs each kind with its own ring). |
| C11 | Current-version mine radii depend on version gate, map size and player count; e.g. `≥80`, ≤4 players, small map = 14–22 / 32–42 / (round2 unset) / 70–82 / 22–38; large map = 14–22 / 32–42 / 70–82 / 22–38 | D1:571–654 (small branch :603–646, large :571–602, legacy :559–568) | Direct read | **observed** | Port `MINE_RINGS=[[14,22],[32,42],[50,62]]` (`pattern_gen.gd:13`) contains a **pre-77 value** for ring 3; update to 70–82 and add the version/size gates. |
| C12 | A pattern stands iff its own mask's stand-cells are in bounds and all `gPatternMask[...]` are false; `Ext` does test-then-stand atomically | D9:3384–3512 (mask fetch :3402–3405, fast step :3441, full test :3475–3511, stand :3497–3501), :3516–3521 | Direct read | **observed** | Port `can_stand` (`pattern_gen.gd:85–95`) implements the footprint test but the occupancy grid is under-populated (C13). |
| C13 | Before any stamping the donor marks as occupied: mask water B>0, all shore h<−0.1, G forest/stone codes, R smooth codes, `broad` roads, map border 3, C1 ellipse, plus collision tags | D2:311–495; D1:1568–1581, :1613, :984; D4:189–196 | Direct read | **observed** | Port `pattern_gen.gd:48–49,177–178,244–245` marks only C1/C2 (plus centre-water skip at :141); add the missing mask-derived layers. |
| C14 | Each successful placement multiplies that pattern's `Freq` by 0.2 (floor 0.0001), so repeated use self-limits | D9:3588–3630 (`:3590`, `:3615`) | Direct read | **observed** | Port `pick` (`pattern_gen.gd:104–123`) uses static weights; implement damping for family variety. |
| C15 | `needed=floor(W*H*freq)` and `trycount=floor(256*(320²)/(W*H))` with a ×0.65 penalty above 320² | D9:3686–3704 | Arithmetic + direct read | **derived** | Port uses invented integer recipe counts ×`area_scale` (`pattern_gen.gd:247–265`); replace with donor freq×free-mask model. |
| C16 | Free-space modifiers are measured, not fixed: `cSmall=340, cMid=182, cLarge=74, cHuge=55`, from 32,000 random probes ×4 per footprint size | D9:3896–3897, :3931–3941, :3878–3927 | Direct read | **observed** | Port has no analogue; add as a map-density gate before stamping. |
| C17 | `SetupStartingResources` order is: 1 stoneforest (C1 ring), fill C2, 1 stones, 2 medium/big forest family stamps, 1 stones at C2+4, 1 more forest, fill C3 | D1:732–769, :771–805, :807–861, :863–945, :947 | Direct read | **observed** | Port `pattern_gen.gd:239–245` stamps only 2 stones + 2 forests; expand and preserve order for deterministic layouts. |
| C18 | `CIRCLE3` is filled into `gPatternMask` but the follow-up placement block is entirely commented out → it is a keep-clear, not a resource ring | D1:947 vs D1:949–977 | Read of block delimiters | **observed** | Port `pattern_gen.gd:143–147` uses CIRCLE3 as a *placement region limit* for resources — opposite meaning. |
| C19 | `FillOwnerMap` is a 4-neighbour BFS assigning `owner` + `dist` from every start on `gScanGrid` | D1:1370–1428 (seeds :1381–1389, BFS :1395–1419) | Direct read | **observed** | No port equivalent; needed before any border/decor-by-territory work. |
| C20 | `SetupBorderObjects` is called **only in peace mode** and places `ptborder`/`ptborderwater` markers, not rocks or trees | D1:2064–2065 (call), :1430–1527 (impl, object names :1469/:1471/:1519/:1521), guard :2059–2060 | Direct read | **observed** | Correct `docs/TERRAIN_GEN_RESEARCH.md:54–57` ("lines the borders with rocks/trees") — contradicted. |
| C21 | TextureMap forest placement uses distinct pattern families by forestType (`n_small_frt_*` 1–24, lite variants at p=0.6; big/med/small `frt_*` sets with 16 internal retries; skips `frt_s_p_2/4/6`) | D4:209–217, :265–292, :296–327 (`cLiteProb` :312) | Direct read | **observed** | Port has no per-cell small-tree object pass; the visible "tree clumps" come only from stamped patterns. |
| C22 | Forest-border pass detects cells with grid code 2/3 and exactly one coloured neighbour, then stamps `fb_1..fb_53` (1–16 per cell, radius 1.5) plus `grass5`/`rock9` tile deco | D6:36, :65, :100, :104, :108, :113, :127–148 | Direct read | **observed** | Port `game.gd:1250 _stamp_forest_borders` should be checked against this algorithm; currently unverified against donor. |
| C23 | Tile smoothing is 3 passes with probability-weighted compatibility tables from `tilesmooth_scripts.cfg` | D5:4–6, :63–80, :84–187, :191–235, :237 | Direct read | **observed** | Port `_assign_tileblocks` (`game.gd:1011`) has no compatibility pass. |
| C24 | `lake_big`/`lake_small` frequencies are hard-zeroed for random maps; `pump`/`christmas` are event-gated | D1:1735–1736, :1848–1851, :1902–1903 | Direct read | **observed** | Port should not expect lakes from the global pass; lake visuals must come from the mask (D2 B channel) or `desert_lake` only. |
| C25 | Winter changes colour table, deletes all `leaftree` objects, and appends `_winter` to tile names | D1:1975–1982, :2075–2084; D4:525–526, :605–606, :639–640 | Direct read | **observed** | Port has tint only (`data.gd:196–197`); winter PNGs are converted but unwired per `docs/research/RC_TERRAIN.md:117–120`. |
| C26 | `generator.cfg` family weights are mostly uniform (`Freq=1`); non-uniform families are `plain_small`, `plain_medium`, `plateau_big`, `desert_tiles`, and legacy `mng/mni/mnc` members with `Freq=0` | Parsed D8:69–2366; examples D8:207, :288, :635, :1629–1654 | Scripted parse of all `Pattern`/`Freq` pairs | **observed** | Port families should be seeded from actual parsed weights, not the hand-written lists. |
| C27 | No R1–R6 relief-generator parameters (height/radius/passage width/furrow count/depth/phase) appear anywhere in the donor plaintext scripts | Search of all files under `C:\Games\Cossacks 3\data\scripts` for `furrow`, `passage`, `ReliefGen`, `GenerateRelief`, `R1`…`R6` returned only an unrelated formation string in `lib/country.script:2499` | Exhaustive grep of the donor script tree | **UNVERIFIED** (absence of evidence; parameters are plausibly editor-only / binary-side) | Do not write a ticket that asserts exact R1–R6 numeric ranges from these scripts. Route to an editor/UI or binary investigation, or explicitly scope as "port-authored knobs". |
| C28 | Port's `MINE_RINGS`, tile grid, static `pick`, missing mask prefill, and static relief domes are all divergences from C9–C17 | Port reads `pattern_gen.gd:13,104–123,141–147,180–201,247–265`; `game.gd:638–657` | Side-by-side read of donor and port lines | **observed** | Convert each into the build tickets in §5; do not bundle into one "tune beauty" task. |

---

## 5. Concrete recommendations for the port

Each item is a potential build ticket with a target location and a **measurable**
acceptance criterion. No code was changed by this agent.

1. **Exact relief amplitudes, including smooth R codes.**
   Target: `app/scripts/mapgen.gd:51–61` (`relief()`) and its use at `:174–175`.
   Implement the literal D2:352–370 class decode and D2:569–573 amplitude:
   R∈{255,191}→plateau (`+2.964*R/255`), R∈{96,112}→hill (`+1.31733*R/255`),
   R∈{48,88}→ravine (`−2.964*R/255`), R=64→0 relief (but `bsmooth` flag set).
   **Acceptance:** a unit test over R∈{48,64,88,96,112,191,255} reproduces donor
   heights −2.964/−0.000/−1.023/+1.317/+0.578/+2.220/+2.964 (±0.001) with
   `B=0`; specifically the R=88 case is **negative**.

2. **Coastal smoothing by mask-B, not by height threshold.**
   Target: `app/scripts/mapgen.gd:86–110` (`_near_water`) and `:179–196`.
   **Acceptance:** for a fixed mask and seed, the exported height array is
   byte-identical (within float epsilon) to a reference implementation of
   D2:611–640; verify that no cell with height > −0.01 is modified by the
   coastal pass and that exactly 3 passes run at all quality levels (or record
   the reduced-pass quality budget as an explicit, documented divergence).

3. **Populate `gPatternMask` before stamping.**
   Target: `app/scripts/pattern_gen.gd:48–49,85–95,177–178,244–245`.
   Mark occupied: mask water B>0, shore height<−0.1 (D1:1576), G forest/stone
   codes (D2:371–383), R smooth codes (`bsmooth`), alpha/`broad` road cells,
   collision/blocked tiles, map border 3 (D1:1613), C1 ellipse, and C3 as
   keep-clear (not a region limit — remove the CIRCLE3 radius gate at :143–147).
   **Acceptance:** no stamped footprint overlaps any of those layers in a
   20-seed dump; report an overlap count, target 0.

4. **Replace the 120-unit tile grid with the donor 25-unit grid.**
   Target: `app/scripts/pattern_gen.gd:180–201`.
   **Acceptance:** at 320×320 the generator emits 169 tile-pattern cells at
   centres `25x−149` for x=0..12; at 160×160 it emits 7×7 cells at `25x−69`.

5. **Correct mine rings and round semantics.**
   Target: `app/scripts/pattern_gen.gd:13,203–237`.
   Use version≥80 radii: small map round set `14–22, 32–42, (skip), 70–82, 22–38`;
   large map `14–22, 32–42, 70–82, 22–38`; stamped **per round for all three
   deposit kinds**, 256 attempts each. Keep the port's `res` mapping but attach
   it to the pattern family, not to the ring index.
   **Acceptance:** nearest gold/iron/coal nodes to a start all lie in the
   14–22 band for the first round; the port's current 50–62 third ring no
   longer appears; deterministic replay of one seed matches the recorded ring
   list.

6. **Weighted pick with donor Freq damping.**
   Target: `app/scripts/pattern_gen.gd:104–123,130–162`.
   Seed family member weights from a parsed D8 table (the counts/sums in §3.6)
   and apply `freq *= 0.2` (floor 0.0001) after each successful placement.
   **Acceptance:** over 1,000 stamps of `forests_pine_big`, no single member is
   chosen more than 25% of the time; the chosen-name sequence is identical for
   the same seed across two runs.

7. **Replace dome relief with the donor relieftype frequency table.**
   Targets: `app/scripts/data.gd:184–188` (RELIEF) and
   `app/scripts/game.gd:638–657` (dome loop).
   Map `plains/hills/mountains` to a relieftype 0–4 preset and drive
   `mountains / plateau_big / plateau / plateau_small / ravine_big / hills_dark /
   hills_light / plain_huge` stamp counts from §3.5 × free-mask modifiers
   (§3, D9:3931–3941). Retire the analytic `height[ii] += ...*(2.964/2.25)`
   dome bump or gate it behind an explicitly non-donor "legacy" flag.
   **Acceptance:** for each of the 5 presets, a dump reports the per-family
   stamp counts and they match `floor(W*H*freq)` (allowing the documented
   `trycount` rejection shortfall); no height write occurs after the collision
   pass (`game.gd:706–730`) — this also closes the cliff-ordering defect in
   `docs/audit/GEN.md` Branch C.

8. **Full `SetupStartingResources` sequence.**
   Target: `app/scripts/pattern_gen.gd:239–245`.
   Implement the seven-step order from C17, with `mindst` derived from C1/C2
   and the `+4` stone ring. **Acceptance:** per start, dump contains exactly
   1 stoneforest, ≥2 stones, ≥3 forest stamps, with radial distances
   `5–10`, `12–18`, `16–24` tiles (before s-scaling) and zero overlaps.

9. **Forest-border feathering.**
   Target: `app/scripts/game.gd:1250` (`_stamp_forest_borders`).
   Port D6:36/65/100/104/108/113/127–148: grid code 2/3 with r=0 and exactly
   one coloured neighbour; 1–16 `fb_1..fb_53` stamps in radius 1.5; `grass5`/
   `rock9` tile deco; winter suffix. **Acceptance:** edge-cell stamp count and
   `fb_` index distribution over 10 seeds match the donor formulas within
   sampling noise; no `fb_` stamp on an interior forest cell.

10. **Tile compatibility smoothing.**
    Target: `app/scripts/game.gd:1011` (`_assign_tileblocks`).
    Add 3 passes of the D5:84–187 compatibility rule (horizontal then vertical
    per pass) using the already-converted donor tile families.
    **Acceptance:** number of incompatible adjacent tile pairs drops to 0 after
    the passes for a fixed dump, and is unchanged between two identical seeds.

11. **Seasonal object + tile behaviour, not just tint.**
    Targets: `app/scripts/game.gd:753` (`_gen_forests`), `:1975` equivalent
    (or nearest winter cleanup site), `app/scripts/world.gd` tile-pool selection.
    Delete leaf-tree objects in winter (D1:1975–1982), append `_winter` to the
    tile names listed in D4:525/605/639 and D6:138, and select colour table 6
    for winter / 7 for desert / 0 otherwise.
    **Acceptance:** a winter dump has 0 objects whose base name contains
    `leaftree`; a screenshot shows `_winter` block art in ≥95% of grass/rock/
    sand cells; no donor asset is copied at build time (use the already
    converted `winter0..26` PNGs).

12. **Roads from mask alpha, not a straight centre line.**
    Target: `app/scripts/game.gd:748–751` and `:1011`.
    Where the mask `broad` (alpha>0) flag is set, apply D4:627–636:
    `ground1` (p=0.5), `test2` (p=0.25), `test3` (p=0.25), with `_winter`
    suffix when applicable. **Acceptance:** road tile cells coincide with the
    exported mask-alpha cells (Jaccard ≥0.95) instead of following the two
    straight `_draw_road` segments.

13. **Do not port editor-only postprocess into skirmish generation.**
    Target: documentation/QA gate rather than code. Keep `postprocess.inc`
    Gaussian/noise out of the random-map path (C6).
    **Acceptance:** a grep of the random-map generation path contains no call
    to the blur/noise helper; the mask manifest records that `*_gauss.png`
    masks are pre-blurred inputs.

14. **R1–R6 relief knobs — do not ticket against these scripts.**
    Target: none. Mark as UNVERIFIED (C27); if a ticket is opened it must be
    scoped as "port-authored height/radius/furrow parameters, no donor numeric
    source" or routed to an editor/binary investigation.
    **Acceptance:** no acceptance criterion cites a donor line for R1–R6 values
    until such a source is produced.

---

## 6. Open questions / unknowns

1. **`gRecordGeneratorVersion` at shipping build.** The current value is not in
   the scripts read. Mine radii, terrain-table selection (91) and start-point
   stream (78) all branch on it. C11 uses the `≥80` branch as "current" because
   it is the newest literal in D1:594–645; this is **inferred**, not confirmed.
   A build-version read or a recorded replay fixture would settle it.

2. **`gc_MaxTerrainTypeCount`.** D1:1557 uses it for the random DLC5 terrain
   type; the constant's value was not in the files read, so "9 DLC5 types" from
   D8:29–66 is an observed count, not a verified constant.

3. **R1–R6 relief generator parameters.** Explicitly UNVERIFIED (C27). The only
   "relief knobs" observable in these scripts are the five relieftype
   frequency presets and the height constants; no height/radius/passage/furrow
   slider appears in the plaintext script tree.

4. **`tilesmooth_scripts.cfg` contents not read.** D5 only shows the consumer;
   the actual compatibility lists and weights (`TileNames`/`Prob`, D5:44–57)
   are in a separate config that was outside the assigned file list. A future
   lane should read it before implementing recommendation 10.

5. **`.pattern` file internals not read.** D9 uses `GetPatternMaskWidth/Height/
   Value/OffsetX/OffsetZ` from loaded pattern definitions. The port's exported
   `donor_patterns.json` is assumed faithful; that assumption was **not**
   independently verified here (out of scope, and donor binaries were not
   copied).

6. **Donor units vs port tiles.** D1 coordinates are centred "generator units"
   and the port scales by `s = map_w/160` (`pattern_gen.gd:9,47`). Whether 160 is
   the correct donor-unit denominator for a 320-cell map remains `derived` from
   `docs/audit/GEN.md` and `docs/decomp/DB_SCRIPTS.md`, not re-derived from a
   donor binary in this lane. This affects every radius in §5.

7. **Port map size conflict.** `docs/audit/GEN.md:400–404` records 320 as the
   configured size while `data.gd:33` says 160. Acceptance criteria in §5 are
   stated at 320 and 160 where relevant; the coordinator should fix the
   shipping size before these tickets are costed.

8. **Winter tile-name availability.** The donor appends `_winter` to a specific
   set (`sandsea*`, `rock1/4/7/8/9`, `grass5`, `ground1`, `test2/3`). The port
   has `winter0..26` converted; whether a name-mapping table exists was not
   audited here.

9. **`cstartoffset=60` / `cstartoffsetrnd=25` (D1:484–485)** are declared in
   `DoGenerate` but no use was found in the lines read. They may be vestigial
   or consumed by a nested state; mark UNVERIFIED rather than assign meaning.

10. **Duplicate family names in `generator.cfg`.** `desert_mng/mni/mnc` and
    `plain_medium` appear twice (e.g. D8:156 vs :1658, D8:288 vs :1762).
    `_misc_SelectPatternListParser` (D9:3568–3584) returns the **first** match,
    so the later blocks are dead. The counts in §3.6 should be read with that
    caveat; a tooling ticket should de-duplicate the config before importing
    weights.

---

## Files changed

- `docs/audit/TERRAIN_DONOR_PIPELINE.md` — **new** (this document). No other file
  created or modified. No donor asset copied. No Godot run.
