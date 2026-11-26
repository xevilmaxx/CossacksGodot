---
id: X03
ticket: TERRAIN-SWARM-2026-11-26 / Swarm X / X03 (DONOR-FIRST corpus — one report, no code)
title: "Verbatim, line-cited donor DScript corpus organised by generation stage"
agent: "X03 (worker subagent)"
created: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_DONOR_BINARY__NO_RUNNER_JOB
scope: "Exactly one repo file written: this report. No source/shader/config/asset/test/git edit. Donor accessed read-only; no donor file copied into the repo; no donor executable run."
owner_file: docs/terrain_swarm_2026-11-26/reports/X03_dscript_corpus.md
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "No donor GPU A/B frame exists. Every quoted line is [O] (observed text); every interpretation is [D]/[I]; every implementation choice derived from it is PORT APPROXIMATION. NO DONOR PARITY CLAIM."
read_passes: "Pass 1: full-file read via numbered latin-1 transcripts. Pass 2: direct latin-1 re-read of original donor paths with a separate Python script for all flagged fragments (§6), plus grep cross-check of family names/reseed sites. Pass 3: cross-check against A02_algorithm.md and docs/audit/TERRAIN_DONOR_PIPELINE.md (C1–C28)."
---

# X03 — Verbatim donor DScript corpus by generation stage

## 0. Mandate, method, label key

The task is to give implementation workers **quotable donor text**, not a new design. Every code block below is a verbatim transcript of a read-only installed donor text file, decoded `latin-1`. Each line is prefixed with `D<n>:<original line number>`; the text after that prefix is unmodified donor source (including the DScript `[*] = ;` comment marker, which is how DScript stores inline script code). Ellipses `…` are used **only outside** code blocks to mark omitted ranges; quoted runs are contiguous.

**Path corrections / file inventory.** `spec/10_STAGE_ORDER.md` does not exist at the path given in the ticket; the actual file is `docs/terrain_swarm_2026-11-26/spec/10_STAGE_ORDER.md` (read in full). All eight assigned donor files **were found exactly at the stated paths** — no relocation was necessary:

| Id | Donor path | Bytes / lines (this install) | Pass 1 | Pass 2 |
|---|---|---|---|---|
| D1 | `C:\Games\Cossacks 3\data\scripts\common.inc\dogenerate.inc` | 109,219 / 2,103 (last line blank; audit's 2,102 excludes it) | full | targeted re-read |
| D2 | `C:\Games\Cossacks 3\data\scripts\common.inc\generatemap.inc` | 51,794 / 1,059 (audit 1,058 + trailing blank) | full | targeted re-read |
| D3 | `C:\Games\Cossacks 3\data\scripts\common.inc\initmapgen.inc` | 13,193 / 289 (audit 288 + trailing blank) | full | targeted re-read |
| D4 | `C:\Games\Cossacks 3\data\scripts\common.inc\texturemap.inc` | 48,954 / 963 (audit 962 + trailing blank) | full | targeted re-read |
| D5 | `C:\Games\Cossacks 3\data\scripts\common.inc\smoothtiles.inc` | 10,691 / 246 (audit 245 + trailing blank) | full | targeted re-read |
| D6 | `C:\Games\Cossacks 3\data\scripts\common.inc\smoothforestborders.inc` | 7,791 / 171 (audit 170 + trailing blank) | full | targeted re-read |
| D7 | `C:\Games\Cossacks 3\data\scripts\common.inc\postprocess.inc` | 19,416 / 466 (audit 465 + trailing blank) | full | — |
| D8 | `C:\Games\Cossacks 3\data\game\var\generator.cfg` | 70,074 / 2,367 (audit 2,366 + trailing blank) | full | scripted parse + re-read |
| D9 | `C:\Games\Cossacks 3\data\scripts\lib\misc.script` | 250,432 / **7,013** (audit says 6,765 — see §6 A7); **supplementary, targeted ranges only** | targeted | targeted |

**Label key.** **[O]** = literal donor line quoted here. **[D]** = arithmetic/control-flow consequence of quoted lines. **[I]** = inference without a donor A/B frame. **[U]** = UNVERIFIED with the instruments used. Claims inherited from A02 / the audit that were **not** re-derived in this report are explicitly marked "(inherited, not re-verified here)".

**Stage mapping.** `spec/10_STAGE_ORDER.md §1` numbers **12** call-order items; A02's §4 numbers **11** stages (0–10). §3 below follows the spec's 12 items and gives the A02 cross-reference in each header.

---

## 1. Executive summary

1. **[O] The canonical call order is confirmed verbatim** at D1:1530–2100: tiled patterns → re-seed → settings → `GenerateMap` → shore prefill → starts/keep-clear → relief passes → forest/stone/decor passes → units/scale → owner BFS → peace-mode borders → finalize. This matches spec §1 items 1–12.
2. **[O] Re-seeding is not 5 sites but 11** in the scripts read: D3:99, D3:146, D1:1100, :1161, :1177, :1213, :1538, :1616, :1772, :1909, :1927 (all `SetRandomKey(randkey1)`); plus `SetRandomExtKey64(randkey0,randkey1)` at D2:216, :513, :774. A02's 5-site list is a subset. The key-mixing function itself remains **[U]**.
3. **[O] All numeric constants used by the 12 stages are present in these files** and are quoted verbatim in §3: height amplitudes (D2:4–7), R/G/B codes (D2:21–32), smoothing parameters (D2:606, :612–637), water field size (D2:649–650, :688), keep-clear ellipses (D1:407–416), relief frequency table (D1:1625–1649), global frequency block (D1:1688–1693, :1727–1739), mine radii (D1:559–654), tile grid `cSize=25` (D1:1335), tile-smooth passes `3` (D5:237), scale dead-band `0.05` (D1:1998), forest-border constants (D6:100–113), season tables (D1:2075–2084).
4. **[O/D] Five contradictions between the quoted donor and A02/audit were found and re-verified** (§6 A1–A5). The most consequential for implementation: (a) D4's 16-retry `frt_*` branch is **unreachable** (`for try0:=1 to 1`, D4:222); (b) D6's 1–16 `fb_*` loop **always breaks after one stamp** (D6:151); (c) `lake_big` is hard-zeroed at D1:1735 but **re-assigned `plain*35`** in the desert branch at D1:1812; (d) the explicit layer-by-layer occupancy prefill at D2:818 is **editor-only** (`not bRandomMap`); (e) D1 and D2/D4 use **different scale-clamp formulas**.
5. **[O] Two cfg family-count discrepancies** vs `TERRAIN_DONOR_PIPELINE.md §3.6`: `plain_medium` has **24** members / sum **67.6875** (D8:288–386), not 31 / 74.6875; `D9` has 7,013 physical lines, not 6,765. Quoted line numbers cited by the audit (D9:3384–3521, :3588–3630, :3686–3704, :3896–3941) still match the current install exactly.
6. **[U] No donor GPU A/B frame.** This report is a translation aid only; it makes no visual-parity claim.

---

## 2. Evidence table

| Evidence id | Source | Lines used in this corpus | What it pins |
|---|---|---|---|
| E01 | D3 | 4–19, 57, 99, 146, 232–239 | Stage 1 player setup, version, seed, `ExecuteState('DoGenerate')` |
| E02 | D1 | 1100, 1161, 1177, 1213, 1538, 1616, 1772, 1909, 1927 | All re-seed sites (corrects A02's 5-site list) |
| E03 | D1 | 8–78, 444–481 | Clear + ellipse/circle/rectangle/border occupancy helpers |
| E04 | D1 | 499–519, 1330–1359, 1530–1538, 1593 | Dead `SetupTiles` vs live `SetupTiledPatterns` |
| E05 | D8 | 781–800 | `tiles` family `d_tls_1..4`, Freq 1 each |
| E06 | D1 | 1542–1565; D8 2–66 | Settings branch, TerrainTypes vs TerrainTypesDLC5 |
| E07 | D2 | 139–216 | Mask folder/pick by player count, `floor(RandomExt*count)` |
| E08 | D2 | 4–32, 311–495, 552–578 | Constants, channel decode, height formula |
| E09 | D2 | 580–644 | Three smoothing groups with exact params |
| E10 | D2 | 646–709 | Water-field flag from mask B |
| E11 | D1 | 1568–1581 | Shore occupancy band `height < -0.1` |
| E12 | D1 | 980–988, 1090–1229, 407–416 | Starts, C1 ellipse, border keep-clear, re-seed in point selection |
| E13 | D1 | 1621–1772 | Relief frequency table and family calls |
| E14 | D1 | 1774–1907; D8 family index (§2b) | Forest/stone/decor frequencies and family names |
| E15 | D1 | 1914–2027; D4 180–413; D6 36–148 | Peasants, object scale, forest objects, borders |
| E16 | D1 | 1361–1428, 1430–1527, 2059–2065 | Owner BFS and peace-mode border markers |
| E17 | D1 | 2068–2100; D3 235–239 | Finalize + post-`DoGenerate` topology |
| E18 | D4 | 29–31, 63–64, 474–529, 557–646 | Collision/tile thresholds, shore aspects, roads |
| E19 | D5 | 4–80, 84–187, 191–242 | Tile compatibility tables, 3 passes |
| E20 | D7 | 63–82, 349–442 | Editor-only Gaussian/noise constants and guards (D2:507) |
| E21 | D9 (supplementary) | 3384–3521, 3588–3653, 3686–3704, 3878–3941 | Stand test, Freq damping, weighted pick, attempt budget, free-mask modifiers |

### 2b. Parsed D8 family index (scripted pass, independent of audit §3.6)

64 family blocks, 493 `Pattern` / 493 `Freq` pairs. Count and ΣFreq:

| D8 line | Family | n | ΣFreq | Non-unit Freq (line:value) |
|---|---|---|---|---|
| 69 | mng | 6 | 5 | 73:0 |
| 98 | mni | 6 | 5 | 102:0 |
| 127 | mnc | 6 | 5 | 131:0 |
| 156 / 1658 | desert_mng (dup) | 3 / 5 | 3 / 5 | — |
| 173 / 1683 | desert_mni (dup) | 3 / 5 | 3 / 5 | — |
| 190 / 1708 | desert_mnc (dup) | 3 / 5 | 3 / 5 | — |
| 207 | plain_small | 19 | 13.0625 | 243:0.25, 251/255/259:0.5625, 263/275/279/283:0.25, … |
| 288 / 1762 | plain_medium (dup) | **24** / 7 | **67.6875** / 7 | 292–308:2.25, 312/316:1.5625, 360/364:6.25, 368/376:4, 372/384:5.0625, 380:1.5625 |
| 389 | plain_big | 13 | 13 | — |
| 446 | plain_huge | 13 | 13 | — |
| 503 | ravine_big | 8 | 8 | — |
| 540 | ravine_medium | 9 | 9 | — (never called: D1:1760 commented) |
| 581 | plateau | 5 | 5 | — |
| 606 | plateau_small | 6 | 6 | — |
| 635 | plateau_big | 5 | 13 | 639/643/647:3, 651/655:2 |
| 660 | mountains | 7 (`g_mnt_1..7`) | 7 | — |
| 693 | hills_dark | 4 (`hil1..4`) | 4 | — |
| 714 | hills_light | 9 (`g_hil1..9`) | 9 | — |
| 755 / 772 | decor / decor_big | 3 / 1 | 3 / 1 | — |
| 781 | tiles | 4 (`d_tls_1..4`) | 4 | — |
| 802 | stoneforests | 8 (`str_new_1..8`) | 8 | — |
| 876 | stones | 7 (`d_stn_1..7`) | 7 | — |
| 909/938/967 | forests_pinefir_big/medium/small | 6/6/6 | 6/6/6 | — |
| 996/1018 | forests_spruce_big/medium | 4/4 | 4/4 | — |
| 1062/1091/1136/1174 | forests_pine_small/medium/big/big_2 | 6/10/8/3 | 6/10/8/3 | — |
| 1191/1208 | forests_mixed_big/medium | 3/5 | 3/5 | — |
| 1233/1247/1261 | forests_leaf_big/medium/small | 2/2/6 | 2/2/6 | — |
| 1290/1339/1352 | swamp_small/big/medium | 11/2/20 | 11/2/20 | — |
| 1437/1490 | lake_small/lake_big | 12/11 | 12/11 | — (freqs zeroed at D1:1735–1736) |
| 1539/1604 | pump/christmas | 15/5 | 15/5 | event-gated at D1:1848–1851 |
| 1629 | desert_tiles | 6 | 4,100 | 1633:1000, 1637:1000, 1641:0, 1645:1000, 1649:1000, 1653:100 |
| 1867 | desert_mountains | 15 | 15 | — |
| 1953 | desert_stones | 12 | 10 | 1973/1981/1985/2001:0.5 |
| 2006/2079/2176/2261 | desert_forests_big/medium/small/unique | 17/23/20/12 | same | — |
| 2314 | desert_lake | 12 | 12 | used only in desert branch D1:1813 |

Duplicate names `desert_mng/mni/mnc` and `plain_medium` are **later blocks shadowed** by first-match lookup (audit §6.10, inherited). Implementation must de-duplicate before importing weights.

---

## 3. Per-stage verbatim corpus

### Stage 1 — init / seed  (spec §1 item 1; A02 Stage 0)

| Stage | Donor file:lines | Key literal values | Called functions | Output fields |
|---|---|---|---|---|
| 1 | D3:4–19, :31–47, :57, :72, :99, :146, :232–239; D1:4–6 | `gc_MaxPlayerCount`, `gRecordGeneratorVersion := gDataVersion`, `randkey1`, `bDesert := season=3`, `foreststype` forced 0 | `CreatePlayers`, `_player_AddServicePlayers`, `_misc_ResetGameData`, `SetRandomKey`, `ExecuteState('DoGenerate')`, `MapWorldUpdateTerrainData`, `TopologyBuild`, `_misc_BuildIslandsGrid` | 8 players + env/service players, `gRecordGeneratorVersion`, RNG stream at stage entry, `gInterface.gamemode` |

```
D3:4       [*] = ;procedure CreatePlayers();
D3:5       [*] = ;begin
D3:6       [*] = ;   var i: Integer;
D3:7       [*] = ;   for i:=0 to gc_MaxPlayerCount-1 do begin
D3:8       [*] = ;      if GetPlayerHandleByIndex(i)=0 then
D3:9       [*] = ;      _player_AddGamePlayer
D3:10      [*] = ;      else begin
D3:11      [*] = ;         var hnd: Integer = _player_GetOrCreateGamePlayerByIndex(i);
D3:12      [*] = ;         ClearEnemyPlayersByHandle(hnd);  //TODO: GEC?
D3:13      [*] = ;         ClearFriendPlayersByHandle(hnd); //TODO: GEC?
D3:14      [*] = ;         ClearPlayerGameObjectsByHandle(hnd);
D3:15      [*] = ;      end;
D3:16      [*] = ;   end;
D3:17      [*] = ;   // Create env nature player, with wood, food, stone, mine objects. Player should be neutral.
D3:18      [*] = ;   _player_AddServicePlayers;
D3:19      [*] = ;end;
```

```
D3:55      [*] = ;if (not bGenRecordManager) then
D3:56      [*] = ;begin
D3:57      [*] = ;   gRecordGeneratorVersion := gDataVersion;
D3:58      [*] = ;   gMap.name := ExtractFileName(GetCurrentMapFileName);
...
D3:72      [*] = ;   gRecordGeneratorVersion := ParserGetIntValueByKeyByHandle(pGen, 'ver');
```

```
D3:99      [*] = ;SetRandomKey(gMap.settings.gen.randkey1);
...
D3:146     [*] = ;SetRandomKey(gMap.settings.gen.randkey1);
```

```
D3:232     [*] = ;ExecuteState('DoGenerate');
D3:233     [*] = ;ApplicationProcessMessages;
D3:234     [*] = ;
D3:235     [*] = ;MapWorldUpdateTerrainData(0, 0);
D3:236     [*] = ;ApplicationProcessMessages;
D3:237     [*] = ;TopologyBuild;
D3:238     [*] = ;ApplicationProcessMessages;
D3:239     [*] = ;_misc_BuildIslandsGrid;
```

```
D1:4       [*] = ;var bDesert : Boolean = (gMap.settings.gen.season=3);
D1:5       [*] = ;var foreststype : Integer = floor(RandomExt*3);
D1:6       [*] = ;foreststype := 0;
```

[D] `foreststype` is drawn then overwritten to 0, so cases 1/2 downstream (D1:835–836, :918–919, :1871–1897) are unreachable in vanilla — consistent with audit C7. Starting resources by `resourcestart` are literal 1000/4000/5000/1000000 at D3:166–189. **[U]** the seed→`RandomExt` mixing function is not in these files.

### Stage 2 — clear mask / objects / collision  (spec §1 item 2; A02 Stage 2 pre-state)

| Stage | Donor file:lines | Key literal values | Called functions | Output fields |
|---|---|---|---|---|
| 2 | D1:8–32, :34–50, :67–78, :444–481; D2:261–262 | `cMapSize = 640`, `r := (GetMapHeight div 2)-1`, `MapDrawCollision(...,r*2-2,False)` | `ClearMapMaskAndObjects`, `ResetPatternMap(False)`, `MapDrawCollision`, `GameObjectRequestToDestroyByHandle`, `_misc_FillPatternMask*` | empty `gPatternMask[0..639,0..639]`, cleared objects/collision |

```
D1:8       [*] = ;function IsDotInElipse(x0, y0, x, y, rx, ry : Float) : Boolean;
D1:9       [*] = ;begin
D1:10      [*] = ;   var val : Float = sqr(x-x0)/sqr(rx)+sqr(y-y0)/sqr(ry);
D1:11      [*] = ;   Result := (val<=1);
D1:12      [*] = ;end;
D1:14      [*] = ;procedure _misc_FillPatternMaskElipse(x, y, rx, ry : Float);
D1:15      [*] = ;begin
D1:16      [*] = ;   var mapW : Integer = GetMapWidth;
D1:17      [*] = ;   var mapH : Integer = GetMapHeight;
D1:18      [*] = ;   var i, j : Integer;
D1:20      [*] = ;   for i:=-round(ry) to floor(ry*2)-1 do
D1:21      [*] = ;   for j:=-round(rx) to floor(rx*2)-1 do
D1:23      [*] = ;      var binside : Boolean = IsDotInElipse(0, 0, j, i, rx, ry);
D1:24      [*] = ;      if (binside) then
D1:26      [*] = ;         var indx : Integer = floor(x+(mapW div 2)+j);
D1:27      [*] = ;         var indy : Integer = floor(y+(mapH div 2)+i);
D1:28      [*] = ;         if (indx>=0) and (indx<mapW) and (indy>=0) and (indy<mapH) then
D1:29      [*] = ;         gPatternMask[indx, indy] := True;
```

```
D1:67      [*] = ;procedure _misc_FillPatternMaskMapBorder(r : Integer);
D1:68      [*] = ;begin
D1:72      [*] = ;   for indy:=0 to mapH-1 do
D1:73      [*] = ;   for indx:=0 to mapW-1 do
D1:75      [*] = ;      if (indx<r) or (indx>(mapW-r)) or (indy<r) or (indy>(mapH-r)) then
D1:76      [*] = ;      gPatternMask[indx, indy] := True;
D1:78      [*] = ;end;
```

```
D1:444     [*] = ;procedure ClearMapMaskAndObjects();
D1:445     [*] = ;begin
D1:446     [*] = ;   var i, j : Integer;
D1:447     [*] = ;   const cMapSize = 640;
D1:448     [*] = ;   for i:=0 to cMapSize-1 do
D1:449     [*] = ;   for j:=0 to cMapSize-1 do
D1:450     [*] = ;   gPatternMask[i, j] := False;
D1:451     [*] = ;   ResetPatternMap(False);
D1:453     [*] = ;   for i:=0 to gc_MaxPlayerCount-1 do
D1:455     [*] = ;      var plhnd : Integer = GetPlayerHandleByIndex(i);
D1:456     [*] = ;      for j:=GetPlayerGameObjectsCountByHandle(plHnd)-1 downto 0 do
D1:462     [*] = ;         GameObjectRequestToDestroyByHandle(goHnd);
D1:466     [*] = ;   var r : Integer = (GetMapHeight div 2)-1;
D1:479     [*] = ;   MapDrawCollision(0, 0, 0, r*2-2, False);
D1:480     [*] = ;end;
D1:481     [*] = ;ClearMapMaskAndObjects;
```

**[O]** D1:467–478 (terrain repaint / `BoolRegister5` block) is fully commented out — do not translate it as live code. **[U]** `cstartoffset = 60` / `cstartoffsetrnd = 25` at D1:484–485 have no consumer in these files (audit §6.9).

### Stage 3 — base tiled patterns  (spec §1 item 3; A02 Stage 4a)

| Stage | Donor file:lines | Key literal values | Called functions | Output fields |
|---|---|---|---|---|
| 3 | D1:499–519 (dead), :1330–1359 (live), :1530–1538, :1593; D8:781–800 | `cSize = 25`, `wcount=floor(mapW/25)`, `hcount=floor(mapH/25)`, loops `0..count` **inclusive**, centre `round(x*25+12-W/2-1)`, `trycount = 64` (dead helper), `name<>'tls_3'` | `SetupTiledPatterns`, `_misc_GetPatternNameByParser`, `_misc_CheckStandPattern`, `_misc_PatternIncreaseFreq`, `SetRandomKey` | one base pattern stamp per cell in `objects[]`, occupancy `gPatternMask`, per-pattern Freq damping |

```
D1:499     [*] = ;procedure SetupTiles(freq : Float);
D1:501     [*] = ;   var needed : Integer = floor(mapW*mapH*freq);
D1:502     [*] = ;   var trycount : Integer = 64;
D1:507     [*] = ;      _misc_GetPatternName(name, 'tls_', 4);
D1:514     [*] = ;         if (name<>'tls_3') then // hack
D1:515     [*] = ;         if (_misc_CheckStandPatternExt(envplHnd, name, x, y, True, pRecordManagerPatternList)) then
D1:519     [*] = ;end;
```

```
D1:1330    [*] = ;procedure SetupTiledPatterns(const str : String);
D1:1331    [*] = ;begin
D1:1332    [*] = ;   var pPatternList : Integer = _misc_SelectPatternListParser(pGenerator, str);
D1:1333    [*] = ;   if (pPatternList<>0) then
D1:1335    [*] = ;      const cSize = 25;
D1:1336    [*] = ;      var wcount : Integer = floor(mapW/cSize);
D1:1337    [*] = ;      var hcount : Integer = floor(mapH/cSize);
D1:1339    [*] = ;      for y:=0 to hcount do
D1:1340    [*] = ;      for x:=0 to wcount do
D1:1343    [*] = ;         _misc_GetPatternNameByParser(name, pPatternList);
D1:1344    [*] = ;         var realx : Float = round((x*cSize)+(cSize div 2)-(GetMapWidth div 2)-1);
D1:1345    [*] = ;         var realy : Float = round((y*cSize)+(cSize div 2)-(GetMapHeight div 2)-1);
D1:1349    [*] = ;            _misc_CheckStandPattern(name, envplHnd, realx, realy, 0, True, False, 0);
D1:1351    [*] = ;            _misc_PatternIncreaseFreq(pGenerator, str, name);
D1:1359    [*] = ;end;
```

```
D1:1530    [*] = ;begin
D1:1532    [*] = ;   if (bDesert) then
D1:1533    [*] = ;   SetupTiledPatterns('desert_tiles')
D1:1534    [*] = ;   else
D1:1535    [*] = ;   SetupTiledPatterns('tiles');
D1:1536    [*] = ;end;
D1:1538    [*] = ;SetRandomKey(gMap.settings.gen.randkey1);
D1:1593    [*] = ;//SetupTiles(0.002);
```

```
D8:781     [*] = ;          Name = tiles
D8:784     [*] = ;                Pattern = d_tls_1
D8:785     [*] = ;                Freq = 1
D8:788     [*] = ;                Pattern = d_tls_2
D8:789     [*] = ;                Freq = 1
D8:792     [*] = ;                Pattern = d_tls_3
D8:793     [*] = ;                Freq = 1
D8:796     [*] = ;                Pattern = d_tls_4
D8:797     [*] = ;                Freq = 1
```

[D] At W=320 the inclusive loops give `13×13 = 169` cells; at W=160, `7×7 = 49` (audit C9). **[O]** `SetupTiles()` is **dead**; the `tls_3` skip at D1:514 belongs only to that dead helper, while the live family includes `d_tls_3` with Freq 1.

### Stage 4 — settings branch  (spec §1 item 4; A02 Stage 1 tail)

| Stage | Donor file:lines | Key literal values | Called functions | Output fields |
|---|---|---|---|---|
| 4 | D1:1542–1565, :1586–1590; D8:2–66 | `gRecordGeneratorVersion<91` threshold; `floor(RandomExt*6)` / `*gc_MaxTerrainTypeCount`; `minesdensity>2 → floor(RandomExt*3)` | `ParserSelectByHandleByKey`, `ParserGetValueByKeyByHandle`, `_misc_SetDesert`, `ExecuteState('GenerateMap')` | `relieftype`, `terraintype`, `minesdensity`, `path` → `StringRegister0`, `BoolRegister0 := True` |

```
D1:1542    [*] = ;var relieftype : Integer = gMap.settings.gen.relieftype;
D1:1543    [*] = ;var terraintype : Integer = gMap.settings.gen.terraintype;
D1:1544    [*] = ;var minesdensity : Integer = gMap.settings.gen.resourcemines;
D1:1546    [*] = ;var pTerrainTypes : Integer;
D1:1547    [*] = ;if (gRecordGeneratorVersion<91) then
D1:1549    [*] = ;   pTerrainTypes := ParserSelectByHandleByKey(pGenerator, 'TerrainTypes');
D1:1550    [*] = ;   if (terraintype>gc_MaxTerrainTypeCount-1) then // random
D1:1551    [*] = ;   terraintype := floor(RandomExt*6);
D1:1555    [*] = ;   pTerrainTypes := ParserSelectByHandleByKey(pGenerator, 'TerrainTypesDLC5');
D1:1556    [*] = ;   if (terraintype>gc_MaxTerrainTypeCount-1) then // random
D1:1557    [*] = ;   terraintype := floor(RandomExt*gc_MaxTerrainTypeCount);
D1:1560    [*] = ;var pTerrainType : Integer = ParserSelectByHandleByIndex(pTerrainTypes, terraintype);
D1:1561    [*] = ;var path : String = ParserGetValueByKeyByHandle(pTerrainType, 'path');
D1:1563    [*] = ;BoolRegister0 := True;
D1:1564    [*] = ;StringRegister0 := path;
D1:1565    [*] = ;ExecuteState('GenerateMap');
```

```
D1:1586    [*] = ;if (minesdensity>2) then // random
D1:1587    [*] = ;minesdensity := floor(RandomExt*3);
D1:1589    [*] = ;if (bDesert) then
D1:1590    [*] = ;_misc_SetDesert(False, False);
```

```
D8:2       [*] = ;    TerrainTypes : struct.begin
D8:4       [*] = ;          hint = 0.Land
D8:6       [*] = ;          path = .\data\gen\terrainmasks\nowater2
D8:9       [*] = ;          hint = 1.Mediterranean
D8:10      [*] = ;          path = .\data\gen\terrainmasks\mediterranean
D8:13      [*] = ;          hint = 2.Peninsulas
D8:14      [*] = ;          path = .\data\gen\terrainmasks\peninsulas
D8:17      [*] = ;          hint = 3.Islands
D8:18      [*] = ;          path = .\data\gen\terrainmasks\islands
D8:21      [*] = ;          hint = 4.Continents
D8:22      [*] = ;          path = .\data\gen\terrainmasks\continents
D8:25      [*] = ;          hint = 5.Continent
D8:26      [*] = ;          path = .\data\gen\terrainmasks\continent
D8:29      [*] = ;    TerrainTypesDLC5 : struct.begin
D8:55      [*] = ;          hint = 6.Coastal
D8:56      [*] = ;          path = .\data\gen\terrainmasks.dlc5\coastal
D8:59      [*] = ;          hint = 7.Lakes
D8:60      [*] = ;          path = .\data\gen\terrainmasks.dlc5\lakes
D8:63      [*] = ;          hint = 8.Rivers
D8:64      [*] = ;          path = .\data\gen\terrainmasks.dlc5\rivers
```

**[U]** `gc_MaxTerrainTypeCount` value is not in these files (audit §6.2). **[D]** DLC5 table has 9 entries but the pre-91 table has 6.

### Stage 5 — `GenerateMap`: mask decode, height, smoothing, water, texture, tile-smooth  (spec §1 item 5; A02 Stages 1–6)

| Stage | Donor file:lines | Key literal values | Called functions | Output fields |
|---|---|---|---|---|
| 5 | D2:4–61, :139–216, :311–495, :552–709, :770–798; D4:29–31, :63–64, :474–646; D5:4–242; D7:63–82, :349–442 | heights `2.964 / 1.31733… / -2.964 / -1.1`, R multiplier `3.5`; R codes `255/96/48`, smooth `64/191/112/88`; G `255/64/128/192`, G=127; B `255`; `power/lerp = 4/0.5`, coastal `0.35/0.5` rad 2 ×3; `cWaterFieldSize=2`, `cOffsetY=-0.5`; `cWaterHeight=-0.25`, `cWaterShoreHeight=-0.1`, `cDiff1/2=0.5/0.55`; `SmoothTileMap(...,3)` | `SetRandomExtKey64`, `ResetPatternMap`, `GetBitmapPixel`, `SmoothTerrain`, `_misc_SmoothTerrainCustom`, `WaterFieldAdd`, `ExecuteState('TextureMap'/'SmoothTiles')`, `MapGetTileIndexByTileBlock`, `SetTileIndex` | `gMapMask[]` RGBA+class+flags, `height[]`, `starts[]`, `water[]` mesh flags, `gPatternMask[]`, `tile_id[]`, collision tags, objects from TextureMap |

#### 5a. Constants and mask selection

```
D2:4       [*] = ;const cPlateauHeight = 2.964;
D2:5       [*] = ;const cHillHeight = cPlateauHeight/2.25;
D2:6       [*] = ;const cRavineHeight = -2.964;
D2:7       [*] = ;const cWaterHeight = -1.1;
D2:9       [*] = ;const cRNone = 0;
D2:10      [*] = ;const cRPlateau = 1;
D2:11      [*] = ;const cRHill = 2;
D2:12      [*] = ;const cRRavine = 3;
D2:13      [*] = ;const cGNone = 0;
D2:14      [*] = ;const cGForest = 1;
D2:15      [*] = ;const cGGenForest = 2;
D2:16      [*] = ;const cGStone = 3;
D2:17      [*] = ;const cGForestStone = 4;
D2:18      [*] = ;const cBNone = 0;
D2:19      [*] = ;const cBWater = 1;
D2:21      [*] = ;const cRColorPlateau = 255;
D2:22      [*] = ;const cRColorHill = 96;
D2:23      [*] = ;const cRColorRavine = 48;
D2:24      [*] = ;const cRColorSmooth = 128 div 2;
D2:25      [*] = ;const cRColorPlateauSmooth = ((cRColorPlateau div 2)+cRColorSmooth);
D2:26      [*] = ;const cRColorHillSmooth = ((cRColorHill div 2)+cRColorSmooth);
D2:27      [*] = ;const cRColorRavineSmooth = ((cRColorRavine div 2)+cRColorSmooth);
D2:28      [*] = ;const cGColorForest = 255;
D2:29      [*] = ;const cGColorGenForest = 64;
D2:30      [*] = ;const cGColorStone = 128;
D2:31      [*] = ;const cGColorForestStone = 192;
D2:32      [*] = ;const cBColorWater = 255;
```

[D] `128 div 2 = 64`; `255 div 2 + 64 = 191`; `96 div 2 + 64 = 112`; `48 div 2 + 64 = 88`. All four smooth codes carry relief class; R=64 is "no relief, smooth me".

```
D2:51      [*] = ;const cForestTypePineFirSpruce = 0;
D2:52      [*] = ;const cForestTypeMixed = 1;
D2:53      [*] = ;const cForestTypeLeaf = 2;
D2:54      [*] = ;var forestType : Integer = cForestTypePineFirSpruce;//cForestTypePineFirSpruce;
D2:61      [*] = ;var bRandomMap : Boolean = BoolRegister0;
D2:141     [*] = ;   bTGA := True;
D2:142     [*] = ;   randkey0 := gMap.settings.gen.randkey0;
D2:143     [*] = ;   randkey1 := gMap.settings.gen.randkey1;
D2:171     [*] = ;      folderpath := StringRegister0;
D2:174     [*] = ;      ParserGetFilesInRoot(folderpath+'\*.tga');
D2:175     [*] = ;      var count : Integer = ParserGetCountByHandle(pFileList);
D2:181     [*] = ;         ParserGetFilesInRoot(folderpath+'\'+IntToStr(i)+'pl*.tga');
D2:190     [*] = ;      var rndind : Integer = floor(RandomExt*count);
D2:191     [*] = ;      inputbitmap := ParserGetValueByIndexByHandle(pFileList, rndind);
D2:197     [*] = ;         ParserSetValueByKeyByHandle(pRMGenerator, 'maskpath', folderpath);
D2:198     [*] = ;         ParserSetValueByKeyByHandle(pRMGenerator, 'maskname', inputbitmap);
D2:216     [*] = ;SetRandomExtKey64(randkey0, randkey1);
```

Per-shape mask counts (121/187/320/230/122/42/33/280) in A02 §Stage 1 are **[I]** almanac recon, **not present in D1–D8** — inherited, not re-verified here.

#### 5b. Channel decode + occupancy (random-map branch D2:397–496)

```
D2:413     [*] = ;   if (fr=1) and (fg=1) and (fb=1) then // starting position
D2:415     [*] = ;      if (spInd<gc_MaxPlayerCount) then
D2:417     [*] = ;         if (spInd=0) or (gMap.players[spInd-1].startx<>bitmapx) or (gMap.players[spInd-1].starty<>bitmapy) then
D2:424     [*] = ;               if (gMap.players[i].startx=bitmapx) and (gMap.players[i].starty=bitmapy) then
D2:440     [*] = ;      fr := 0;
D2:441     [*] = ;      fg := 0;
D2:442     [*] = ;      fb := 0;
D2:444     [*] = ;   var ir : Integer = floor(fr*255);
D2:445     [*] = ;   var ig : Integer = floor(fg*255);
D2:446     [*] = ;   var ib : Integer = floor(fb*255);
D2:447     [*] = ;   gMapMask[x,y].r := fr;
D2:448     [*] = ;   gMapMask[x,y].g := fg;
D2:449     [*] = ;   gMapMask[x,y].b := fb;
D2:450     [*] = ;   if (fa>0) then
D2:451     [*] = ;   gMapMask[x,y].broad := True
D2:452     [*] = ;   else
D2:453     [*] = ;   gMapMask[x,y].broad := False;
D2:454     [*] = ;   case ir of
D2:455     [*] = ;      cRColorPlateau, cRColorPlateauSmooth : begin
D2:456     [*] = ;         gMapMask[x,y].bsmooth := (ir=cRColorPlateauSmooth);
D2:457     [*] = ;         gMapMask[x,y].terrain := cRPlateau;
D2:459     [*] = ;      cRColorHill, cRColorHillSmooth : begin
D2:460     [*] = ;         gMapMask[x,y].bsmooth := (ir=cRColorHillSmooth);
D2:461     [*] = ;         gMapMask[x,y].terrain := cRHill;
D2:463     [*] = ;      cRColorRavine, cRColorRavineSmooth : begin
D2:464     [*] = ;         gMapMask[x,y].bsmooth := (ir=cRColorRavineSmooth);
D2:465     [*] = ;         gMapMask[x,y].terrain := cRRavine;
D2:467     [*] = ;      else
D2:469     [*] = ;         gMapMask[x,y].bsmooth := (ir=cRColorSmooth);
D2:470     [*] = ;         gMapMask[x,y].terrain := cRNone;
D2:473     [*] = ;   case ig of
D2:474     [*] = ;      cGColorForest : gMapMask[x,y].forest := cGForest;
D2:475     [*] = ;      (cGColorForest div 2) : begin
D2:476     [*] = ;         case gMapMask[x,y].terrain of
D2:477     [*] = ;            cRPlateau, cRHill, cRRavine : gMapMask[x,y].forest := cGForest;
D2:480     [*] = ;      cGColorGenForest : gMapMask[x,y].forest := cGGenForest;
D2:481     [*] = ;      cGColorStone : gMapMask[x,y].forest := cGStone;
D2:482     [*] = ;      cGColorForestStone : gMapMask[x,y].forest := cGForestStone;
D2:486     [*] = ;   case ib of
D2:487     [*] = ;      cBColorWater : gMapMask[x,y].water := cBWater;
D2:491     [*] = ;   if ((ir=0) and (ig=0) and (ib=0))
D2:492     [*] = ;   or ((ir=255) and (ig=255) and (ib=255)) then
D2:493     [*] = ;   gPatternMask[x,y] := False
D2:494     [*] = ;   else
D2:495     [*] = ;   gPatternMask[x,y] := True;
D2:500     [*] = ;   gMap.players[i].startx := -(GetMapWidth div 2)+(gMap.players[i].startx/srcwidth)*mapwidth;
D2:501     [*] = ;   gMap.players[i].starty := -(GetMapHeight div 2)+(gMap.players[i].starty/srcheight)*mapheight;
```

The editor-size branch D2:315–395 is byte-equivalent aside from duplicate detection (D2:419–435). **[O]** The blanket rule D2:491–495 makes **every non-black/non-white mask pixel occupied** — this is the only generic prefill for random maps (see §6 A4).

#### 5c. Height

```
D2:507     [*] = ;if (not bRandomMap) then
D2:509     [*] = ;   if (cPostProcessBitmapGaussian) then
D2:513     [*] = ;      SetRandomExtKey64(randkey0, randkey1);
D2:514     [*] = ;      ExecuteState('PostProcess');
D2:529     [*] = ;else
D2:531     [*] = ;   trgbitmap := srcbitmap;
```

```
D2:552     [*] = ;if (cLoadHeightDataFromTexture) then
D2:556     [*] = ;   for y:=0 to mapheight do
D2:557     [*] = ;   for x:=0 to mapwidth do
D2:559     [*] = ;      var realx : Integer = floor(lx+x);
D2:560     [*] = ;      var realy : Integer = floor(ty+y);
D2:561     [*] = ;      var ix : Integer = ClampInt(x, 0, mapwidth-1);
D2:562     [*] = ;      var iy : Integer = ClampInt(y, 0, mapheight-1);
D2:563     [*] = ;      var fr : Float = gMapMask[ix,iy].r;
D2:564     [*] = ;      var fb : Float = gMapMask[ix,iy].b;
D2:565     [*] = ;      if (bRandomMap) and (fr=1) and (fb=1) then // starting point
D2:566     [*] = ;      continue;
D2:567     [*] = ;      var hwater : Float = cWaterHeight*(fb*(1+fr*3.5));
D2:569     [*] = ;      case gMapMask[ix,iy].terrain of
D2:570     [*] = ;         cRPlateau : hterrain := cPlateauHeight*fr;
D2:571     [*] = ;         cRHill : hterrain := cHillHeight*fr;//*(255/cRColorHill); - required if color range of height is 0-32 0-96 in trgbitmap
D2:572     [*] = ;         cRRavine : hterrain := cRavineHeight*fr;//*(255/cRColorRavine);
D2:574     [*] = ;      SetHeightData(realx, realy, hwater+hterrain)
```

[D] At R=191 plateau → `+2.220`; R=112 hill → `+0.578`; R=88 ravine → `−1.023`; R=64 → 0 relief. Loops are **inclusive** (`0..mapwidth`), with clamped mask indexing — original line numbers preserved.

#### 5d. Smoothing

```
D2:218     [*] = ;procedure _misc_SmoothTerrainCustom(x, y, times : Integer; power, lerp, minh, maxh : Float);
D2:220     [*] = ;   if (power=0) then
D2:221     [*] = ;   exit;
D2:227     [*] = ;   for i:=0 to times-1 do
D2:228     [*] = ;   if (x>minx) and (x<(mapwidth div 2)) and (y>miny) and (y<(mapwidth div 2)) then
D2:230     [*] = ;      lt := GetHeightData(x-1, y-1);
D2:231     [*] = ;      rt := GetHeightData(x+1, y-1);
D2:232     [*] = ;      lb := GetHeightData(x-1, y+1);
D2:233     [*] = ;      rb := GetHeightData(x+1, y+1);
D2:234     [*] = ;      h := GetHeightData(x, y);
D2:235     [*] = ;      if (h<>lt) or (h<>rt) or (h<>lb) or (h<>rb) then
D2:236     [*] = ;      if h>=minh and h<=maxh then
D2:238     [*] = ;         z1 := (lt+rt)/2;
D2:239     [*] = ;         z2 := (lb+rb)/2;
D2:240     [*] = ;         var res : Float = h+((z1+z2)/2-h)/power;
D2:241     [*] = ;         res := Lerp(h, res, lerp);
D2:242     [*] = ;         SetHeightData(x, y, res);
D2:245     [*] = ;end;
```

```
D2:587     [*] = ;      if (gMapMask[x,y].bsmooth) then
D2:589     [*] = ;         var realx : Integer = floor(lx+x);
D2:590     [*] = ;         var realy : Integer = floor(ty+y);
D2:591     [*] = ;         SmoothTerrain(realx, -realy, False, 3);
D2:606     [*] = ;      _misc_SmoothTerrainCustom(realx, realy, 1, 4, 0.5, 0.01, 100);
D2:607     [*] = ;      //_misc_SmoothTerrainCustom(realx, realy, 1, 4, 0.5, -100, 0.01);
D2:612     [*] = ;   for i:=0 to 2 do
D2:619     [*] = ;         var ix : Integer = ClampInt(x, 0, mapwidth-1);
D2:620     [*] = ;         var iy : Integer = ClampInt(y, 0, mapheight-1);
D2:621     [*] = ;         var bWater : Boolean = (gMapMask[ix,iy].water=cBWater);
D2:625     [*] = ;            const rad = 2;
D2:626     [*] = ;            for [MAIN]ny:=ClampInt(y-rad, 0, mapwidth-1) to ClampInt(y+rad, 0, mapwidth-1) do
D2:627     [*] = ;            for nx:=ClampInt(x-rad, 0, mapwidth-1) to ClampInt(x+rad, 0, mapwidth-1) do
D2:629     [*] = ;               if (gMapMask[nx,ny].water=cBWater) then
D2:636     [*] = ;         if (bWater) then
D2:637     [*] = ;         _misc_SmoothTerrainCustom(realx, realy, 1, 0.35, 0.5, -100, -0.01);
D2:641     [*] = ;   TerrainUpdate(True, False);
D2:644     [*] = ;end;
```

**[U]** `SmoothTerrain`'s internal power/lerp is not in these files (audit C5/A02 U6). **[O]** the coastal call is 3× (`:612`) with `power=0.35, lerp=0.5, minh=-100, maxh=-0.01`, gated by mask B at self-or-neighbour; the height band is enforced inside the helper at D2:236. Note the `mapwidth` bound used for `ny` (§6 A5).

#### 5e. Water fields

```
D2:646     [*] = ;if (cPlaceWater) then
D2:649     [*] = ;   const cWaterFieldSize = 2;
D2:650     [*] = ;   const cWaterMapArrSize = (640 div cWaterFieldSize);
D2:653     [*] = ;   for wmy:=0 to cWaterMapArrSize-1 do
D2:654     [*] = ;   for wmx:=0 to cWaterMapArrSize-1 do
D2:656     [*] = ;      for [CELL]y:=wmy*cWaterFieldSize to Min(((wmy+1)*cWaterFieldSize), mapheight-1) do
D2:657     [*] = ;      for x:=wmx*cWaterFieldSize to Min(((wmx+1)*cWaterFieldSize), mapwidth-1) do
D2:666     [*] = ;         if (gMapMask[x,y].b>0) and ((gMapMask[x,y].r<1) or (gMapMask[x,y].b<1)) then
D2:673     [*] = ;            bWaterMap[wmx, wmy] := True;
D2:674     [*] = ;            break(CELL);
D2:687     [*] = ;   WaterFieldsClear;
D2:688     [*] = ;   const cOffsetY = -0.5;
D2:689     [*] = ;   var mapsizemod : Float = (cWaterMapArrSize/((640/mapheight)*2))*cWaterFieldSize; // var mapsizemod : Float = (cWaterMapArrSize div ((640 div mapheight)*2))*cWaterFieldSize;
D2:698     [*] = ;      if (bWaterMap[wmx, wmy]) then
D2:704     [*] = ;         WaterFieldAdd('x'+IntToStr(wmx)+'y'+IntToStr(wmy), tx, tz, bx, bz, cOffsetY);
```

[D] `cWaterMapArrSize = 320`; the flag is from **mask B**, not from `height < -0.25` (that test is collision/tile art only, D4:68–75, :463–471).

#### 5f. TextureMap entry and D4 thresholds

```
D2:770     [*] = ;if (cTextureTerrain) then
D2:774     [*] = ;   SetRandomExtKey64(randkey0, randkey1);
D2:775     [*] = ;   IntRegister0 := forestType;
D2:776     [*] = ;   ExecuteState('TextureMap');
D2:781     [*] = ;if (cSmoothTile) then
D2:786     [*] = ;   ExecuteState('SmoothTiles');
```

```
D4:29      [*] = ;const cMaxHeight = 2.96;
D4:30      [*] = ;const cWaterHeight = -0.25;
D4:31      [*] = ;const cWaterShoreHeight = -0.1;
D4:63      [*] = ;      const cDiff1 = 0.5;
D4:64      [*] = ;      const cDiff2 = 0.55;
D4:68      [*] = ;      if (gMapMask[ix,iy].b>0) then
D4:70      [*] = ;         if (height<cWaterHeight) then
D4:71      [*] = ;         bWater := True
D4:73      [*] = ;         if (height<cWaterShoreHeight) then
D4:74      [*] = ;         bWaterShore := True;
D4:474     [*] = ;            const cAngle = 45;
D4:504     [*] = ;            if (bLB) then newtile := 'sandsea5';//'sandsea4';
D4:505     [*] = ;            if (bRB) then newtile := 'sandsea6';//'sandsea3';
D4:506     [*] = ;            if (bB) then newtile := 'sandsea1';
D4:509     [*] = ;            if (bT) then newtile := 'sandsea1';
D4:594     [*] = ;               if (Abs(height)>2.7) {or (height<-2.7)} then
D4:595     [*] = ;               newtile := 'rock8'
D4:597     [*] = ;               if (Abs(height)>2.4) {or (height<-2.4)} then
D4:598     [*] = ;               newtile := 'rock4'
D4:600     [*] = ;               if (Abs(height)<0.1) then
D4:601     [*] = ;               newtile := '';
D4:622     [*] = ;      if (gMapMask[x,y].broad) then
D4:627     [*] = ;         if (RandomExt>0.5) then
D4:628     [*] = ;         newtile := 'ground1'
D4:633     [*] = ;         if (RandomExt>0.25) then
D4:634     [*] = ;         newtile := 'test2'
D4:635     [*] = ;         else
D4:636     [*] = ;         newtile := 'test3';
D4:639     [*] = ;            if GetSeasonType=2 then
D4:640     [*] = ;            newtile := newtile+'_winter';
```

**[O]** Two distinct water constants: `-1.1` (height term, D2:7) and `-0.25` / `-0.1` (classification, D4:30–31).

#### 5g. Tile smoothing (D5)

```
D5:4       [*] = ;var pTileSmoothLists : Integer = _parser_ParserTemporary(True);
D5:5       [*] = ;ParserLoadFromFileByHandle(pTileSmoothLists, '.\data\gen\tilesmooth_scripts.cfg');
D5:6       [*] = ;pTileSmoothLists := ParserSelectByHandleByKey(pTileSmoothLists, 'TileSmoothLists');
D5:26      [*] = ;var Items : array [0..63] of TItem;
D5:44      [*] = ;      var pTileLists : Integer = ParserSelectByHandleByKey(pSmoothTileList, 'TileNames');
D5:52      [*] = ;         var prob : Float = ParserGetFloatValueByKeyByHandle(pTileName, 'Prob');
D5:63      [*] = ;function FindRandomTileIndex(i, j : Integer) : Integer;
D5:67      [*] = ;   var rnd : Float = RandomExt*sumProb;
D5:74      [*] = ;      if (prob>0) and (rnd<tmp) then
D5:84      [*] = ;procedure GetNeighbourTiles(tindex1, tindex2 : Integer; var outtile1, outtile2 : Integer);
D5:124     [*] = ;      if ((tilename1='rock5') and (tilename2='rock2')) or ((tilename1='rock2') and (tilename2='rock5')) then
D5:125     [*] = ;      ind2ProbZero := ind2ProbZero;
D5:142     [*] = ;      if (Abs(i1 - i2) = 1) and ((not i1ProbZero) or (not i2ProbZero)) then
D5:159     [*] = ;      if i1 - i2 = 2 then
D5:161     [*] = ;         outtile1 := FindRandomTileIndex(ilist, (i1 + i2) div 2);
D5:191     [*] = ;procedure SmoothTileMap(mini, minj, maxi, maxj, passes : Integer);
D5:197     [*] = ;   for k := 0 to passes-1 do
D5:200     [*] = ;      for i := mini to maxi-1 do
D5:201     [*] = ;      for j := minj to maxj do
D5:207     [*] = ;            GetNeighbourTiles(tind1, tind2, tchange1, tchange2);
D5:218     [*] = ;      for j := minj to maxj-1 do
D5:219     [*] = ;      for i := mini to maxi do
D5:237     [*] = ;SmoothTileMap(0, 0, GetMapWidth, GetMapHeight, 3);
D5:242     [*] = ;SetTileIndex(i, j, atilemap[i, j]);
```

**[U]** `tilesmooth_scripts.cfg` compatibility lists/weights are **not** among the assigned files; only the consumer is quoted (A02 U7, audit §6.4).

#### 5h. Editor-only postprocess (D7) — explicit non-skirmish scope

```
D7:63      [*] = ;const bRandomNoise = True;
D7:65      [*] = ;const cMinDropPower = 1;
D7:66      [*] = ;const cMaxDropPower = 3;
D7:67      [*] = ;const cNoiseProb = 0.5;
D7:71      [*] = ;const cTryNoiseNearestProb = 0.6;
D7:72      [*] = ;const cTryNoiseNearestProbRecursive = 0.99;
D7:73      [*] = ;const cMaxDeep = 10;
D7:75      [*] = ;const cIsPlateauMin = 0.1;
D7:76      [*] = ;const cIsPlateauMax = 0.95;
D7:77      [*] = ;const cMinPower = 0.1;
D7:78      [*] = ;const cPowerMinBreak = 0.1;
D7:79      [*] = ;const cPowerMaxBreak = 0.9;
D7:352     [*] = ;   var rs : Integer = Round(r*2.57+0.5);
D7:369     [*] = ;         var wght : Float = Exp( -dsq / (cDoubleSQRR) ) / (PI*cDoubleSQRR);
D7:437     [*] = ;BitmapGaussBlur(bitmaptrg, width, height, 0.00001, False); // 1
D7:441     [*] = ;BitmapGaussBlur(bitmaptrg, width, height, 0.925, True); // 1
```

[D] `r=0.925 → rs=3`. **Guard:** D2:507 `if (not bRandomMap)` means D7 never runs for skirmish random maps (audit C6). Do **not** port the Gaussian/noise into the skirmish path.

### Stage 6 — shore exclusion mask  (spec §1 item 6; A02 Stage 4d prefill)

| Stage | Donor file:lines | Key literal values | Called functions | Output fields |
|---|---|---|---|---|
| 6 | D1:1568–1581; D4:31 | `cWaterShoreHeight = -0.1`, loops `0..mapW-1 / 0..mapH-1` | `GetHeightData` | `gPatternMask[]` bit set for shore cells (banned from stamping) |

```
D1:1568    [*] = ;var x, y : Integer;
D1:1569    [*] = ;for y:=0 to mapH-1 do
D1:1570    [*] = ;for x:=0 to mapW-1 do
D1:1572    [*] = ;   if (not gPatternMask[x, y]) then
D1:1574    [*] = ;      var realx : Integer = floor(x0+x);
D1:1575    [*] = ;      var realy : Integer = floor(y0+y);
D1:1576    [*] = ;      const cWaterShoreHeight = -0.1;
D1:1577    [*] = ;      var height : Float = GetHeightData(realx, realy);
D1:1578    [*] = ;      if (height<cWaterShoreHeight) then
D1:1579    [*] = ;      gPatternMask[x, y] := True; // bWaterShore := True;
D1:1581    [*] = ;end;
```

[D] This runs **after** `GenerateMap` (which includes Stage 5d smoothing) and **before** starts and relief stamping. It is the one place where the spec's stage boundary matters for determinism (A02 §5.2 invariant 2).

### Stage 7 — starts + border keep-clear  (spec §1 item 7; A02 Stage 7)

| Stage | Donor file:lines | Key literal values | Called functions | Output fields |
|---|---|---|---|---|
| 7 | D1:407–416, :980–988, :1090–1229, :1586–1616 | C1 `5×7`, C2 `12×15`, C3 `22×18`, border `r=3`, `minesdensity>2 → floor(RandomExt*3)`, version gates `<61`, `>77`, `>90` | `_misc_FillPatternMaskElipse`, `_misc_FillPatternMaskMapBorder`, `RandomStartingPoints`, `GenerateTeamStartingPoints`, `SetRandomKey`, `CreateStartPoint`, `SetupMines`, `SetupStartingResources`, `CreateUniqueStartingUnits` | `arrStartPos[0..7]`, `arrStartPosBusy[0..7]`, `spcount`, `gPatternMask` keep-clear, initial mine/resource objects |

```
D1:407     [*] = ;const cCircle1MaskX = 5;
D1:408     [*] = ;const cCircle1MaskY = 7;
D1:410     [*] = ;const cCircle2MaskX = 12;
D1:411     [*] = ;const cCircle2MaskY = 15;
D1:413     [*] = ;const cCircle3MaskX = 22;
D1:414     [*] = ;const cCircle3MaskY = 18;
D1:416     [*] = ;const cBorderObjDist = 1;
```

```
D1:980     [*] = ;procedure CreateStartPoint(plInd : Integer; pointx, pointy : Float; minesdensity, spcount : Integer);
D1:981     [*] = ;begin
D1:982     [*] = ;   if (not bGenRecordManager) then
D1:984     [*] = ;      _misc_FillPatternMaskElipse(pointx, pointy+2, cCircle1MaskX, cCircle1MaskY);
D1:985     [*] = ;      SetupMines(pointx, pointy, 0, 1, minesdensity, spcount);
D1:986     [*] = ;      SetupStartingResources(pointx, pointy);
D1:988     [*] = ;end;
```

```
D1:1090    [*] = ;procedure RandomStartingPoints(plcount, minesdensity : Integer);
D1:1093    [*] = ;   if gRecordGeneratorVersion<61 then // preserve compatibility with old replays
D1:1100    [*] = ;            SetRandomKey(gMap.settings.gen.randkey1);
D1:1104    [*] = ;            var rndind : Integer = floor(RandomExt*(maxind+1));
D1:1114    [*] = ;                  CreateStartPoint(i, arrStartPos[newind].x, arrStartPos[newind].y, minesdensity, plcount);
D1:1124    [*] = ;   else // support spawn allies nearby option
D1:1131    [*] = ;      if (gMap.settings.additional.teams=gc_mapsettings_teams_nearby) then
D1:1137    [*] = ;            if gMap.players[i].team>4 then
D1:1138    [*] = ;            teams[0].Add(i)
D1:1140    [*] = ;            teams[gMap.players[i].team].Add(i);
D1:1161    [*] = ;            SetRandomKey(gMap.settings.gen.randkey1);
D1:1169    [*] = ;            GenerateTeamStartingPoints(teamcount, pointsbusy, points);
D1:1175    [*] = ;               if gRecordGeneratorVersion>77 then
D1:1177    [*] = ;                  SetRandomKey(gMap.settings.gen.randkey1);
D1:1182    [*] = ;               var pointindex : Integer = GetRandom(points.GetCount);
D1:1190    [*] = ;               CreateStartPoint(player, arrStartPos[point].x, arrStartPos[point].y, minesdensity, plcount);
D1:1197    [*] = ;      else //Åñëè èãðîêîâ ðàñêèäûâàåì ïî ðàçíûì òî÷êàì...
D1:1213    [*] = ;         SetRandomKey(gMap.settings.gen.randkey1);
D1:1214    [*] = ;         for j:=0 to i+8 do
D1:1215    [*] = ;         RandomExt;
D1:1223    [*] = ;         CreateStartPoint(player, arrStartPos[point].x, arrStartPos[point].y, minesdensity, plcount);
```

```
D1:1019    [*] = ;   points.Add(pointsremained.Get(GetRandom(pointsremained.GetCount)));//Âûáèðàåì ïåðâóþ ñëó÷àéíóþ òî÷êó
D1:1048    [*] = ;            var d : Float = VectorDistance(x1, y1, 0, x2, y2, 0);
D1:1050    [*] = ;            if (dist = 0) or (dist > d) then
D1:1076    [*] = ;         if (pointcount<pointsnearestcount[i]) then
D1:1082    [*] = ;         if (pointcount=pointsnearestcount[i]) and (pointsnearestdist[pointindex] > pointsnearestdist[i]) then
D1:1086    [*] = ;      points.Add(pointsnearest.Get(pointindex));
```

```
D1:1596    [*] = ;var spcount : Integer;
D1:1599    [*] = ;      if (gMap.players[i].startx>=(-GetMapWidth div 2)) and (gMap.players[i].starty>=(-GetMapHeight div 2)) then
D1:1601    [*] = ;      arrStartPos[i].x := gMap.players[i].startx;
D1:1602    [*] = ;      arrStartPos[i].y := gMap.players[i].starty;
D1:1613    [*] = ;_misc_FillPatternMaskMapBorder(3);
D1:1615    [*] = ;RandomStartingPoints(spcount, minesdensity);
D1:1616    [*] = ;SetRandomKey(gMap.settings.gen.randkey1);
```

**[O]** Cyrillic comments at D1:998, :1027, :1031, :1126, etc. are original latin-1 bytes; they are preserved verbatim above. **[U]** exact start-spacing acceptance (0.7 cm / 1.5–2 cm) is modder changelog, not a donor script literal (A02 U10).

### Stage 8 — relief pattern passes  (spec §1 item 8; A02 Stage 4b)

| Stage | Donor file:lines | Key literal values | Called functions | Output fields |
|---|---|---|---|---|
| 8 | D1:1621–1772; D8:446–753; D9:3686–3704 (supplementary) | relieftype 0–4 table `plt/mnt/hil`; `plain=0.0001/2`; `frs_big/mid/small=0.0009/0.0009/0.00054`; `stn1/2=0.00016/0.00012`; size modifier `640/((W+H)/2)`; `lake_*=0`; `pln_*`, `swamp_*` expressions; `plt/3`, `plt/1.5`, `hil/2`; `minround=1,maxround=0` | `_misc_GetFreePatternMaskModifier`, `_misc_SetupPatternsByType`, `SetupMines`, `SetRandomKey` | stamped height + objects for mountains/plateaus/hills/ravines/plain_huge; per-start mines; occupancy |

```
D1:1621    [*] = ;if (relieftype>4) then // random
D1:1622    [*] = ;relieftype := floor(RandomExt*5);
D1:1624    [*] = ;case relieftype of
D1:1625    [*] = ;   0 : begin
D1:1626    [*] = ;      plt := 0.000010;
D1:1627    [*] = ;      mnt := 0.000020;
D1:1628    [*] = ;      hil := 0.000075;
D1:1630    [*] = ;   1 : begin
D1:1631    [*] = ;      plt := 0.000020;
D1:1632    [*] = ;      mnt := 0.000002;
D1:1633    [*] = ;      hil := 0.000125;
D1:1635    [*] = ;   2 : begin
D1:1636    [*] = ;      plt := 0.000075;
D1:1637    [*] = ;      mnt := 0.000075;
D1:1638    [*] = ;      hil := 0.000030;
D1:1640    [*] = ;   3 : begin
D1:1641    [*] = ;      plt := 0.000055;
D1:1642    [*] = ;      mnt := 0.000120;
D1:1643    [*] = ;      hil := 0.000050;
D1:1645    [*] = ;   4 : begin
D1:1646    [*] = ;      plt := 0.000090;
D1:1647    [*] = ;      mnt := 0.000035;
D1:1648    [*] = ;      hil := 0.000035;
D1:1650    [*] = ;end;
```

```
D1:1688    [*] = ;var frs_big : Float = 0.0009;
D1:1689    [*] = ;var frs_mid : Float = 0.0009;
D1:1690    [*] = ;var frs_small : Float = 0.00054;
D1:1691    [*] = ;var dcr : Float = 0.0005;
D1:1692    [*] = ;var stn1 : Float = 0.00016;
D1:1693    [*] = ;var stn2 : Float = 0.00012;
D1:1715    [*] = ;_misc_GetFreePatternMaskModifier(probsmall, probmid, problarge, probhuge);
D1:1718    [*] = ;if (mapW<>640) or (mapH<>640) then
D1:1720    [*] = ;   var modifier : Float = (640/((mapW+mapH)/2));
D1:1721    [*] = ;   probsmall := probsmall*modifier;
D1:1722    [*] = ;   probmid := probmid*modifier;
D1:1723    [*] = ;   problarge := problarge*modifier;
D1:1724    [*] = ;   probhuge := probhuge*modifier;
D1:1727    [*] = ;plain := 0.0001/2;
D1:1728    [*] = ;pln_small := plain*6*probsmall;
D1:1729    [*] = ;pln_mid := plain*2*probmid;
D1:1730    [*] = ;pln_large := plain*problarge;
D1:1731    [*] = ;pln_huge := plain*probhuge;
D1:1732    [*] = ;swamp_big := plain*problarge;
D1:1733    [*] = ;swamp_medium := plain*2*probmid;
D1:1734    [*] = ;swamp_small := plain*6*probsmall;
D1:1735    [*] = ;lake_big := plain*2*0;
D1:1736    [*] = ;lake_small := plain*0;
D1:1737    [*] = ;mnt := mnt*problarge;
D1:1738    [*] = ;plt := plt*problarge;
D1:1739    [*] = ;hil := hil*problarge;
```

```
D1:1747    [*] = ;   if bDesert then
D1:1749    [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'desert_mountains', mnt);
D1:1750    [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'desert_plateau_big', plt/3);
D1:1751    [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'desert_plain_big', pln_huge);
D1:1752    [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'desert_plateau', plt/3);
D1:1753    [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'desert_plateau_small', plt/3);
D1:1757    [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'mountains', mnt);
D1:1758    [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'plateau_big', plt/3);
D1:1759    [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'plain_huge', pln_huge);
D1:1760    [*] = ;      //_misc_SetupPatternsByType(pGenerator, envplHnd, 'ravine_medium'{'ravine_big'}, plt/3); // sand ravine
D1:1761    [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'ravine_big', plt/1.5);
D1:1762    [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'plateau', plt/3);
D1:1763    [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'plateau_small', plt/3);
D1:1764    [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'hills_dark', hil/2);
D1:1765    [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'hills_light', hil/2);
D1:1769    [*] = ;   for i:=0 to spcount-1 do
D1:1770    [*] = ;   SetupMines(arrStartPos[i].x, arrStartPos[i].y, 1, 0, minesdensity, spcount);
D1:1772    [*] = ;SetRandomKey(gMap.settings.gen.randkey1);
```

**[O]** `SetupMines(..., minround=1, maxround=0, ...)`: `maxround=0` means the clamp at D1:533–534 does not fire; rounds 1..rounds−1 run. **[O]** `ravine_medium` is commented out even though D8:540 defines 9 members — do not stamp it (§6 A11).

Mine radii (D1:559–655) — **indexed by `i` = round**, `j` = resource kind (D1:535, :544, :547–551), `trycount=256` (D1:525), one `mng`/`mni`/`mnc` per round:

```
D1:525     [*] = ;   var trycount : Integer = 256;
D1:528     [*] = ;   case minesdensity of
D1:529     [*] = ;      0 : rounds := 3;
D1:530     [*] = ;      1 : rounds := 4;
D1:531     [*] = ;      2 : rounds := 5;
D1:533     [*] = ;   if (maxround>0) and (rounds>maxround) then
D1:534     [*] = ;   rounds := maxround;
D1:535     [*] = ;   for i:=minround to rounds-1 do // rounds
D1:544     [*] = ;      for j:=0 to 2 do // restypes
D1:548     [*] = ;            0 : str := 'mng';
D1:549     [*] = ;            1 : str := 'mni';
D1:550     [*] = ;            2 : str := 'mnc';
D1:555     [*] = ;         for k:=0 to trycount-1 do // mines
D1:559     [*] = ;            if (gRecordGeneratorVersion<70) then
D1:571     [*] = ;               if (gMap.settings.gen.mapsize>2) then // tiny
D1:594     [*] = ;                  else
D1:595     [*] = ;                  case i of
D1:596     [*] = ;                     0 : dst := 14+RandomExt*8;
D1:597     [*] = ;                     1 : dst := 32+RandomExt*10;
D1:598     [*] = ;                     2 : dst := 70+RandomExt*12;
D1:599     [*] = ;                     3 : dst := 22+RandomExt*16;
D1:600     [*] = ;                     4 : continue;
D1:638     [*] = ;                  else
D1:639     [*] = ;                  case i of
D1:640     [*] = ;                     0 : dst := 14+RandomExt*8;
D1:641     [*] = ;                     1 : dst := 32+RandomExt*10;
D1:642     [*] = ;                     3 : dst := 70+RandomExt*12;
D1:643     [*] = ;                     4 : dst := 22+RandomExt*16;
D1:644     [*] = ;                     5 : continue;
D1:704     [*] = ;            var angle : Float = RandomExt*360;
D1:705     [*] = ;            var px : Float = dst;
D1:708     [*] = ;            VectorRotateY(px, py, pz, angle);
D1:709     [*] = ;            if (_misc_CheckStandPatternExt(envplHnd, name, round(newpointx+px), round(newpointy+pz), True, pRecordManagerPatternList)) then
D1:711     [*] = ;               _misc_PatternIncreaseFreq(pGenerator, str, name);
```

Full radius matrix (verbatim line ranges): legacy `<70` D1:559–568; `mapsize>2` `<77` D1:573–582, `<80` D1:584–593, `≥80` D1:594–601; `spcount<=4` `<75` D1:606–615, `<77` D1:617–626, `<80` D1:628–637, `≥80` D1:638–645; `spcount>4` D1:648–654. The `i=2, spcount<=4, mapsize>2` corner re-targets to a map corner with offset `24` at D1:658–696 (version gate `<90`). **[U]** shipping `gRecordGeneratorVersion` (A02 U8); D3:57 shows it equals `gDataVersion` for fresh maps.

### Stage 9 — forest / stone / decor passes  (spec §1 item 9; A02 Stage 4c)

| Stage | Donor file:lines | Key literal values | Called functions | Output fields |
|---|---|---|---|---|
| 9 | D1:1774–1907; D8:802–908, :909–1540, :1629–2365 | `frs_big/mid/small × prob*`, desert `/2`, `stn1/2 × probsmall`, `pump/christmas` event gates, `lake_*=0`, `plain=0.0001/2` families | `_misc_SetupPatternsByType`, `_misc_GetFreePatternMaskModifier`, `_misc_SetDesert`, `_misc_PatternIncreaseFreq` | forest/stone/decor objects, occupancy, Freq damping |

```
D1:1774    [*] = ;frs_big := frs_big*probsmall;
D1:1775    [*] = ;frs_mid := frs_mid*probmid;
D1:1776    [*] = ;frs_small := frs_small*problarge;
D1:1777    [*] = ;stn1 := stn1*probsmall;
D1:1778    [*] = ;stn2 := stn2*probsmall;
D1:1781    [*] = ;frs_big := frs_big/2;
D1:1783    [*] = ;frs_mid := frs_mid/2;
D1:1785    [*] = ;frs_small := frs_small/2;
D1:1801    [*] = ;   //_misc_SetupPatternsByType(pGenerator, envplHnd, 'plain', plain/3);
D1:1812    [*] = ;      lake_big := plain*35;
D1:1813    [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'desert_lake', lake_big);
D1:1836    [*] = ;      case foreststype of
D1:1838    [*] = ;            _misc_SetupPatternsByType(pGenerator, envplHnd, 'forests_pinefir_big', frs_big/8);
D1:1839    [*] = ;            _misc_SetupPatternsByType(pGenerator, envplHnd, 'forests_spruce_big', frs_big/8);
D1:1840    [*] = ;            _misc_SetupPatternsByType(pGenerator, envplHnd, 'forests_pine_big', frs_big/8);
D1:1841    [*] = ;            _misc_SetupPatternsByType(pGenerator, envplHnd, 'forests_pine_big_2', frs_big/8);
D1:1846    [*] = ;            _misc_SetupPatternsByType(pGenerator, envplHnd, 'stones', stn1);
D1:1848    [*] = ;            if (gc_halloween>0) and (GetSeasonType<>2) then // not winter
D1:1849    [*] = ;            _misc_SetupPatternsByType(pGenerator, envplHnd, 'pump', pln_small*4);
D1:1850    [*] = ;            if gc_christmas>0 then
D1:1851    [*] = ;            _misc_SetupPatternsByType(pGenerator, envplHnd, 'christmas', pln_small*2);
D1:1853    [*] = ;            _misc_SetupPatternsByType(pGenerator, envplHnd, 'plain_big', pln_large);
D1:1854    [*] = ;            _misc_SetupPatternsByType(pGenerator, envplHnd, 'plain_medium', pln_mid);
D1:1855    [*] = ;            _misc_SetupPatternsByType(pGenerator, envplHnd, 'forests_spruce_medium', frs_mid/6);
D1:1856    [*] = ;            _misc_SetupPatternsByType(pGenerator, envplHnd, 'forests_pinefir_medium', frs_mid/6);
D1:1857    [*] = ;            _misc_SetupPatternsByType(pGenerator, envplHnd, 'forests_pine_medium', frs_mid/6);
D1:1862    [*] = ;            _misc_SetupPatternsByType(pGenerator, envplHnd, 'stones', stn2);
D1:1866    [*] = ;            _misc_SetupPatternsByType(pGenerator, envplHnd, 'forests_pinefir_small', frs_small/4);
D1:1867    [*] = ;            _misc_SetupPatternsByType(pGenerator, envplHnd, 'forests_pine_small', frs_small/4);
D1:1899    [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'swamp_big', swamp_big);
D1:1900    [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'swamp_medium', swamp_medium);
D1:1901    [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'swamp_small', swamp_small);
D1:1902    [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'lake_big', lake_big);
D1:1903    [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'lake_small', lake_small);
D1:1906    [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'plain_small', pln_small);
D1:1909    [*] = ;SetRandomKey(gMap.settings.gen.randkey1);
```

**[O]** The `case foreststype` only ever executes branch `0` because of D1:6; branches `1` (leaf, D1:1871–1884) and `2` (mixed, D1:1885–1897) are dead in vanilla. **[O]** Guaranteed starting resources (D1:720–978) are part of Stage 7, with exact 7-step order: stoneforest (D1:743–767), C2 ellipse (D1:769), stones (D1:781–805), 2 forest stamps (D1:807–861), stones at `mindst+4` (D1:863–892), 1 forest (D1:894–945), C3 ellipse keep-clear (D1:947) and **commented-out** C3 placement (D1:949–977). Constants: `trycount=128`, `trycount2=3`, `smalltry=4`, `dst := mindst+RandomExt*3+((i+j)*0.5)` (D1:724–726, :754, :793, :848), `mindst := Min(cCircle2MaskX,cCircle2MaskY)+4` (D1:863).

### Stage 10 — units + prop/asset instancing  (spec §1 item 10; A02 Stage 10)

| Stage | Donor file:lines | Key literal values | Called functions | Output fields |
|---|---|---|---|---|
| 10 | D1:1231–1281, :1914–2027; D4:180–413, :415–646; D6:36–148 | `18` peasants, `cUnitR=0.75`; `rand` scale with 5% dead-band; skip `terrainmesh`/`stones`; winter deletes `leaftree`; `cLiteProb=0.6`; `frt_s_p_2/4/6` skip; `fb_1..fb_53`, `1..16`, rad `1.5`, `p>0.975`; roads `0.5/0.25` | `CreateStartPointPeasants`, `_misc_PreloadTextures`, `SetGameObjectScaleByHandle`, `_misc_CheckStandPattern`, `ExecuteState('SmoothForestBorders')`, `SetTileIndex` | final object list with scale/rotation, season-filtered props, forest-border `fb_*` objects and `grass5`/`rock9` decals |

```
D1:1255    [*] = ;         var count : Integer = 18;
D1:1258    [*] = ;         const cUnitR = 0.75;
D1:1262    [*] = ;            px := pointx+(i div 3)*cUnitR+(0.5-RandomExt)*0.25-(((count div 3)*cUnitR)/2);
D1:1263    [*] = ;            pz := pointy+(i mod 3)*cUnitR+(0.5-RandomExt)*0.25-(((count mod 3)*cUnitR)/2);
```

```
D1:1914    [*] = ;for i:=0 to gc_MaxPlayerCount-1 do
D1:1918    [*] = ;      if (gMap.settings.additional.startingunits>gc_mapsettings_startingunits_default) then
D1:1919    [*] = ;      CreateUniqueStartingUnits(i, False)
D1:1921    [*] = ;      CreateStartPointPeasants(i, gMap.players[i].startx, gMap.players[i].starty);
D1:1925    [*] = ;_misc_PreloadTextures(True, True, True);
D1:1927    [*] = ;SetRandomKey(gMap.settings.gen.randkey1);
```

```
D1:1971    [*] = ;for i:=GetPlayerGameObjectsCountByHandle(envplhnd)-1 downto 0 do
D1:1975    [*] = ;   if (GetSeasonType=2) then // winter
D1:1977    [*] = ;      if StrExists(basename, 'leaftree') then
D1:1979    [*] = ;         GameObjectRequestToDestroyByHandle(goHnd);
D1:1980    [*] = ;         continue;
D1:1984    [*] = ;   if StrExists(basename, 'terrainmesh') or (StrExists(basename, 'stones')) then
D1:1985    [*] = ;   continue;
D1:1990    [*] = ;   GetGameObjectDefScalePropsByHandle(goHnd, x, y, z, rand, minfact, maxfact, deffact);
D1:1992    [*] = ;   if (rand) then
D1:1994    [*] = ;      scaleMin := x*minfact;
D1:1995    [*] = ;      scaleMid := x*((minfact+maxfact)/2);
D1:1996    [*] = ;      scaleMax := x*maxfact;
D1:1998    [*] = ;      if ((Abs(scaleMax-scaleMin))>scaleMid*0.05) then
D1:2000    [*] = ;         if (scale<scaleMin) then
D1:2006    [*] = ;            var newscale : Float = scaleMin+(scaleMid-scaleMin)*random;
D1:2009    [*] = ;            SetGameObjectScaleByHandle(goHnd, newscale, newscale, newscale);
D1:2012    [*] = ;         if (scale>scaleMax) then
D1:2018    [*] = ;            var newscale : Float = scaleMid+(scaleMax-scaleMid)*random;
D1:2021    [*] = ;            SetGameObjectScaleByHandle(goHnd, newscale, newscale, newscale);
```

Forest object pass (D4) and forest-border pass (D6):

```
D4:209     [*] = ;      if (not gPatternMask[x, y]) and ((gMapMask[x,y].forest=cGStone) or (gMapMask[x,y].forest=cGForestStone)) then
D4:215     [*] = ;         // TODO Place stone and forest stone patterns
D4:216     [*] = ;         var pname : String = 'n_small_frt_'+IntToStr(1);
D4:217     [*] = ;         _misc_CheckStandPattern(pname, envPlHnd, realx, realy, 0, True, False, 0);
D4:221     [*] = ;   const cCatergoryCount = 3;
D4:222     [*] = ;   for [MAIN]try0:=1 to 1 do
D4:266     [*] = ;                           0 : arrind := _misc_SwitchInt(0, 1, RandomExt<0.375);
D4:268     [*] = ;                           2 : arrind := _misc_SwitchInt(2, 3, RandomExt<0.5);
D4:270     [*] = ;                        for try3:=0 to 15 do
D4:273     [*] = ;                              0 : pname := 'b_frt_b_p_'+IntToStr(floor(1+3*RandomExt));
D4:274     [*] = ;                              1 : pname := 'frt_b_p_'+IntToStr(floor(1+8*RandomExt));
D4:275     [*] = ;                              2 : pname := 'frt_m_p_'+IntToStr(floor(1+10*RandomExt));
D4:276     [*] = ;                              3 : pname := 'frt_s_p_'+IntToStr(floor(1+6*RandomExt));
D4:280     [*] = ;                           if (pname='frt_s_p_6') or (pname='frt_s_p_4') or (pname='frt_s_p_2') then
D4:298     [*] = ;                           ind := 1+floor(17*RandomExt);
D4:301     [*] = ;                           ind := 18+floor(7*RandomExt);
D4:312     [*] = ;                     const cLiteProb = 0.6;
D4:316     [*] = ;                        if (RandomExt<cLiteProb) then
D4:317     [*] = ;                        pname := 'n_small_frt_lite_'+IntToStr(ind)
D4:319     [*] = ;                        pname := 'n_small_frt_'+IntToStr(ind);
D4:356     [*] = ;      if (cSmoothForestBorders) and (envbitmap<>0) then // requires envbitmap
D4:360     [*] = ;      ExecuteState('SmoothForestBorders');
D4:391     [*] = ;               const cDiffKoefMin = 0.875;
D4:392     [*] = ;               const cDiffKoefMax = 0.95;
D4:402     [*] = ;               const cDiffKoefMin = 1.04;
D4:403     [*] = ;               const cDiffKoefMax = 1.08;
```

```
D6:36      [*] = ;   if ((g=2) or (g=3)) and (r=0) then
D6:65      [*] = ;      if (count=1) then
D6:100      [*] = ;   if (grid[x, y]=2) or ((grid[x, y]=3) and (RandomExt>0.975)) then
D6:104      [*] = ;      var count : Integer = floor(1+RandomExt*16);
D6:108      [*] = ;         const rad = 1.5;
D6:113      [*] = ;            pind := floor(1+RandomExt*53);
D6:114      [*] = ;            pname := 'fb_'+IntToStr(pind);
D6:123      [*] = ;               _misc_CheckStandPattern(pname, envPlHnd, placeX, placeZ, 0, True, False, 0);
D6:127      [*] = ;               var tilecount : Integer = floor(1+RandomExt*3);
D6:134      [*] = ;                     0 : tile := 'grass5';
D6:135      [*] = ;                     1 : tile := 'rock9';
D6:136      [*] = ;                     2 : tile := 'rock9';
D6:138      [*] = ;                  if GetSeasonType=2 then
D6:139      [*] = ;                  tile := tile+'_winter';
D6:151      [*] = ;               break;
```

**[O]** D6:111 restricts `fb_*` to `forestType=0` (pine/fir/spruce), which is the only reachable branch. **[O]** D6's `count` 1–16 loop has an unconditional `break` at :151 after one successful stand (§6 A2).

### Stage 11 — `FillOwnerMap` + border objects  (spec §1 item 11; A02 Stage 8)

| Stage | Donor file:lines | Key literal values | Called functions | Output fields |
|---|---|---|---|---|
| 11 | D1:1361–1428, :1430–1527, :2059–2065 | `fChecked`, `owner=-1`, `dist=-1`, 4 neighbours, `cBorderObjDist=1`, peace-mode guard | `FillOwnerMap`, `CheckOwnerDist`, `_misc_PosToScanGridIndices`, `SetupBorderObjects`, `GetMapCollisionTag`, `CreatePlayerGameObjectHandleByHandle` | `gScanGrid[].owner/dist/fChecked`, `ptborder`/`ptborderwater` markers (peace only) |

```
D1:1361    [*] = ;procedure CheckOwnerDist(i, j, dist, owner : Integer);
D1:1363    [*] = ;   if gScanGrid[i, j].dist < 0 then
D1:1365    [*] = ;      gScanGrid[i, j].dist := dist+1;
D1:1366    [*] = ;      gScanGrid[i, j].owner := owner;
D1:1370    [*] = ;procedure FillOwnerMap(const spCount : Integer);
D1:1376    [*] = ;      gScanGrid[i, j].fChecked := false;
D1:1377    [*] = ;      gScanGrid[i, j].owner := -1;
D1:1378    [*] = ;      gScanGrid[i, j].dist := -1;
D1:1384    [*] = ;      if _misc_PosToScanGridIndices(arrStartPos[i].x, arrStartPos[i].y, gridX, gridY) then
D1:1386    [*] = ;         gScanGrid[gridX, gridY].owner := arrStartPosBusy[i];
D1:1387    [*] = ;         gScanGrid[gridX, gridY].dist := 0;
D1:1395    [*] = ;   while f do
D1:1400    [*] = ;      if (gScanGrid[i, j].dist = dist) and (not gScanGrid[i, j].fChecked) then
D1:1405    [*] = ;         CheckOwnerDist(i-1, j, dist, owner);
D1:1407    [*] = ;         CheckOwnerDist(i+1, j, dist, owner);
D1:1410    [*] = ;         CheckOwnerDist(i, j-1, dist, owner);
D1:1412    [*] = ;         CheckOwnerDist(i, j+1, dist, owner);
D1:1414    [*] = ;         gScanGrid[i, j].fChecked := true;
D1:1418    [*] = ;      dist := dist+1;
```

```
D1:1430    [*] = ;procedure SetupBorderObjects;
D1:1437    [*] = ;      if (i < gc_scangrid_countx-1) and (gScanGrid[i, j].owner <> gScanGrid[i+1, j].owner) then
D1:1443    [*] = ;         var count : Integer = MathCeil(Abs(z1-z0) / cBorderObjDist);
D1:1468    [*] = ;               if GetMapCollisionTag(x, z, false) = gc_collisiontag_water then
D1:1469    [*] = ;               hnd := CreatePlayerGameObjectHandleByHandle(plHnd, gc_racename_misc, gc_basename_ptborderwater, x, 0, z)
D1:1471    [*] = ;               hnd := CreatePlayerGameObjectHandleByHandle(plHnd, gc_racename_misc, gc_basename_ptborder, x, 0, z);
D1:1477    [*] = ;      if (j < gc_scangrid_county-1) and (gScanGrid[i, j].owner <> gScanGrid[i, j+1].owner) then
D1:1518    [*] = ;               if GetMapCollisionTag(x, z, false) = gc_collisiontag_water then
D1:1519    [*] = ;               hnd := CreatePlayerGameObjectHandleByHandle(plHnd, gc_racename_misc, gc_basename_ptborderwater, x, 0, z)
D1:1521    [*] = ;               hnd := CreatePlayerGameObjectHandleByHandle(plHnd, gc_racename_misc, gc_basename_ptborder, x, 0, z);
```

```
D1:2059    [*] = ;gfloat_peacetime := _misc_GetPeaceTime(gMap.settings.additional.peacetime);
D1:2060    [*] = ;gbool_peacemode := (gMap.settings.additional.peacetime<>gc_mapsettings_peacetime_default);
D1:2062    [*] = ;FillOwnerMap(spcount);
D1:2064    [*] = ;if (gbool_peacemode) then
D1:2065    [*] = ;SetupBorderObjects;
```

**[O]** BFS is a **wavefront over `dist`** (not a FIFO queue): it repeatedly scans all cells at the current `dist` and increments `dist` at D1:1418. Border markers are invisible territory markers, never rocks/trees (audit C20). D1:1421–1427 (setting edge owners to `-2`) is commented out.

### Stage 12 — finalize  (spec §1 item 12; A02 Stage 11)

| Stage | Donor file:lines | Key literal values | Called functions | Output fields |
|---|---|---|---|---|
| 12 | D1:2068–2100; D3:235–239; D2:1044–1054 | winter table `6`/PHDR `1`, desert table `7`, default `0`/`0`, `GetSeasonType=2`, `cProgressAITick=16` (:2042) | `_misc_SetShoresCollision`, `_misc_FixCollisionInertiaObjectsInOnePoint`, `SetCurrentColorTableIndex`, `SetCurrentPHDRIndex`, `TimeLog`, `TopologyBuild`, `_misc_BuildIslandsGrid` | final collision fix, colour/PHDR state, AI progress ticks, record manager cleanup, log |

```
D1:2068    [*] = ;_misc_SetShoresCollision;
D1:2070    [*] = ;_misc_FixCollisionInertiaObjectsInOnePoint;
D1:2075    [*] = ;if GetSeasonType=2 then begin
D1:2076    [*] = ;   SetCurrentColorTableIndex(6);
D1:2077    [*] = ;   SetCurrentPHDRIndex(1);
D1:2078    [*] = ;   end else begin
D1:2079    [*] = ;   if (gMap.settings.gen.season=3) then
D1:2080    [*] = ;   SetCurrentColorTableIndex(7)
D1:2081    [*] = ;   else
D1:2082    [*] = ;   SetCurrentColorTableIndex(0);
D1:2083    [*] = ;   SetCurrentPHDRIndex(0);
D1:2084    [*] = ;end;
D1:2100    [*] = ;TimeLog('Generation finished. relieftype='+IntToStr(relieftype)+' minesdensity='+IntToStr(minesdensity));
D1:2101    [*] = ;   struct.end
D1:2102    [*] = ; section.end
```

```
D3:235     [*] = ;MapWorldUpdateTerrainData(0, 0);
D3:237     [*] = ;TopologyBuild;
D3:239     [*] = ;_misc_BuildIslandsGrid;
```

**[O]** D1:2085–2098 (Halloween/random colour-table experiment) is commented out. **[O]** D3:245–254 copies the temporary record manager back after `DoGenerate`.

### 3.13 Shared helper corpus — D9 (supplementary targeted read, not in assigned file list)

These are the function bodies called by D1:1349, :711, :709 etc. They were read **only** in the ranges shown (Pass 2 instrument). All numbers here are [O]; engine behaviour beyond these lines is [U].

```
D9:3384    function _misc_CheckStandPattern(patName : String; plHnd : Integer; standX, standZ, angle : Float; doStand, bWriteToParser : Boolean; pHnd : Integer) : Boolean;
D9:3402    var mWidth : Integer = GetPatternMaskWidth(patName);
D9:3403    var mHeight : Integer = GetPatternMaskHeight(patName);
D9:3404    var offX : Float = GetPatternOffsetX(patName);
D9:3405    var offZ : Float = GetPatternOffsetZ(patName);
D9:3439    if (not doStand) and (angle=0) then
D9:3441       const step = 4;
D9:3461          if (maskValue and maskStand) or ((not maskValue) and maskInvStand) then
D9:3466             if (indI<0) or (indI>=mapH) or (indJ<0) or (indJ>=mapW) or (gPatternMask[indJ, indI]) then
D9:3475    if (Result) then
D9:3497          if doStand then
D9:3499             if (indI>=0) and (indI<mapH) and (indJ>=0) and (indJ<mapW) and (not gPatternMask[indJ, indI]) then
D9:3500             gPatternMask[indJ, indI] := true
D9:3504             if (indI<0) or (indI>=mapH) or (indJ<0) or (indJ>=mapW) or (gPatternMask[indJ, indI]) then
D9:3516    function _misc_CheckStandPatternExt(envplHnd : Integer; patName : String; standX, standZ : Float; bWriteToParser : Boolean; pHnd : Integer) : Boolean;
D9:3518       Result := (envplHnd<>0) and (_misc_CheckStandPattern(patName, envplHnd, standX, standZ, 0, False, False, 0));
D9:3520       _misc_CheckStandPattern(patName, envplHnd, standX, standZ, 0, True, bWriteToParser, pHnd);
```

[D] `Ext` = test with `doStand=False`, then atomic stand with `doStand=True`; fast path samples every 4th cell when `angle=0` (D9:3441). Note the stand branch writes `gPatternMask` **only** for stand-cells; out-of-bounds cells are rejected only in the test branch.

```
D9:3588    function _misc_PatternIncreaseFreq(pGenerator : Integer; const str, name : String) : Integer;
D9:3590       const cMinFreq = 0.0001;
D9:3614          var oldfreq : Float = ParserGetFloatValueByKeyByHandle(pPattern, 'Freq');
D9:3615          var newfreq : Float = oldfreq*0.2;
D9:3616          if newfreq<cMinFreq then
D9:3617          newfreq := cMinFreq;
D9:3621          var sumfreq : Float = ParserGetFloatValueByKeyByHandle(pPatternGroup, 'FreqSum');
D9:3622          ParserSetFloatValueByKeyByHandle(pPatternGroup, 'FreqSum', (sumfreq-oldfreq+newfreq));
D9:3634    procedure _misc_GetPatternNameByParser(var name : String; pPatternList : Integer);
D9:3638       var freqsum : Float = ParserGetFloatValueByKeyByHandle(pPatternGroup, 'FreqSum');
D9:3639       var freqrnd : Float = RandomExt*freqsum;
D9:3645          if (freqrnd<freq) then
D9:3651          freqrnd := freqrnd-freq;
```

```
D9:3686       var mapsizeoptimise : Float = (320*320)/(mapwidth*mapheight);
D9:3687       if (mapsizeoptimise<1) then
D9:3688       mapsizeoptimise := mapsizeoptimise*0.65;
D9:3695          needed := floor(mapwidth*mapheight*freq);
D9:3696          neededround := round(mapwidth*mapheight*freq);
D9:3697          if (needed=0) then
D9:3699             if (freq>0) then
D9:3700             needed := neededround;
D9:3704       var trycount : Integer = floor(256*mapsizeoptimise);
D9:3931    procedure _misc_GetFreePatternMaskModifier(var probsmall, probmid, problarge, probhuge : Float);
D9:3933       const cSmall = 340;
D9:3934       const cMid = 182;
D9:3935       const cLarge = 74;
D9:3936       const cHuge = 55;
D9:3937       probsmall := _misc_GetFreePatternMaskCountModifier(12)/cSmall;
D9:3938       probmid := _misc_GetFreePatternMaskCountModifier(16)/cMid;
D9:3939       problarge := _misc_GetFreePatternMaskCountModifier(24)/cLarge;
D9:3940       probhuge := _misc_GetFreePatternMaskCountModifier(29)/cHuge;
```

**[O]** D9:3896–3897 `trycount1=4`, `trycount2=32000`; D9:3926 `Result := floor(Result/trycount1)`. **[D]** A02's "needed rounds to 1 if freq>0 and floor=0" is an approximation: donor uses `round(...)`, which is 1 only when `W*H*freq >= 0.5`.

---

## 4. Consolidated stage → evidence → key values → calls → outputs table

| # (spec §1) | Donor file:lines | Key literal values | Called functions (principal) | Output fields |
|---|---|---|---|---|
| 1 init/seed | D3:4–19, :57, :99, :146, :232–239; D1:4–6 | `randkey1`, `season=3`, `foreststype := 0` | `SetRandomKey`, `ExecuteState('DoGenerate')` | players, version, RNG entry |
| 2 clear | D1:8–78, :444–481 | `cMapSize=640`, `r=(H div 2)-1` | `ResetPatternMap`, `MapDrawCollision` | empty mask/objects/collision |
| 3 tiled base | D1:499–519(dead), :1330–1359, :1530–1538; D8:781–800 | `cSize=25`, inclusive `0..W/25`, centre `-1`, `trycount=64` dead | `SetupTiledPatterns`, `_misc_CheckStandPattern`, `PatternIncreaseFreq` | base stamps, occupancy |
| 4 settings | D1:1542–1565, :1586–1590; D8:2–66 | version `91`, `floor(RandomExt*6)`/`*gc_MaxTerrainTypeCount`, `minesdensity>2` | `ExecuteState('GenerateMap')` | `relieftype`, `terraintype`, `path` |
| 5 GenerateMap | D2:4–32, :139–216, :311–709, :770–798; D4:29–31, :63–64, :474–646; D5:4–242; D7:63–82 | `2.964/1.31733/-2.964/-1.1`, ×`3.5`, R `255/96/48/64/191/112/88`, G `255/64/128/192`, B `255`, `4/0.5`, `0.35/0.5` rad2×3, water `2`/`320`/`-0.5`, `-0.25/-0.1`, `0.5/0.55`, 3 tile passes | `SetRandomExtKey64`, `SmoothTerrain`, `_misc_SmoothTerrainCustom`, `WaterFieldAdd`, `TextureMap`, `SmoothTiles` | `gMapMask`, `height`, `starts`, `water`, `tile_id`, collision |
| 6 shore prefill | D1:1568–1581 | `−0.1` | `GetHeightData` | `gPatternMask` shore ban |
| 7 starts | D1:407–416, :980–988, :1090–1229, :1586–1616 | C1 `5×7`, C2 `12×15`, C3 `22×18`, border `3`, version `61/77/90` | `RandomStartingPoints`, `CreateStartPoint`, `SetupMines`, `SetupStartingResources` | `arrStartPos`, `arrStartPosBusy`, occupancy |
| 8 relief | D1:1621–1772; D8:446–753 | 5-row `plt/mnt/hil` table, `plain=0.00005`, `frs_*`, `stn1/2`, `plt/3`, `plt/1.5`, `hil/2`, radii `14+8r`… | `_misc_SetupPatternsByType`, `SetupMines`, `SetRandomKey` | stamped height + relief objects |
| 9 forest/stone | D1:1774–1907; D8:802–2365 | `frs_big/mid/small`, `stn1/2`, `lake=0` (desert override), event gates | `_misc_SetupPatternsByType` | forests/stones/swamps/decor objects |
| 10 units/props | D1:1231–1281, :1914–2027; D4:180–413; D6:36–148 | `18`, `cUnitR=0.75`, dead-band `0.05`, `cLiteProb=0.6`, `fb_1..53`, `p=0.025`, rad `1.5` | `CreateStartPointPeasants`, `_misc_CheckStandPattern`, `SmoothForestBorders` | objects + scale/rotation, forest borders |
| 11 owner/borders | D1:1361–1428, :1430–1527, :2059–2065 | 4-neighbour BFS, `owner=-1`, `dist=-1`, `cBorderObjDist=1` | `FillOwnerMap`, `SetupBorderObjects` | `owner[]/dist[]`, peace-only markers |
| 12 finalize | D1:2068–2100; D3:235–239 | colour `6/7/0`, PHDR `1/0`, `cProgressAITick=16` | `_misc_SetShoresCollision`, `TopologyBuild` | final state + log |

---

## 5. Implications for implementation workers

1. **Translate from the quoted lines, not from A02's pseudo-code.** Where A02 and the donor disagree, §6 wins: the donor text is [O], A02 is a design summary.
2. **Stage boundaries are hard**: no height writes after collision (Stage 5 D4:53–176), shore prefill after smoothing (Stage 6), re-seed at D1:1538/:1616/:1772/:1909/:1927. Carry a per-stage stream id ledger; derive keys with a labelled approximation because mixing is **[U]**.
3. **Blend flags** (`HeightField*` etc.) do not occur in these 8 files; they are inherited from `pattern.lib` via DPATTERN_01 (audit C25/A02 E25) and are **[U]** here. Carry them per pattern; do not collapse to one additive formula.
4. **`gPatternMask` semantics differ by path**: random maps get the blanket non-black/non-white ban (D2:491–495), then shore (Stage 6) and border (D1:1613) and C1/C2/C3 (Stage 7) layers; the explicit per-layer prefill at D2:818 is editor-only. Implementation must not "fix" this by copying editor code into skirmish.
5. **Water mesh comes from mask B** (D2:666), never from `height<-0.25`; keep the three water constants distinct.
6. **Tile smoothing needs external data**: `tilesmooth_scripts.cfg` must be parsed by F03/F05 before Stage 5g can be donor-shaped; until then any compatibility table is PORT APPROXIMATION.
7. **D8 weights must be parsed, de-duplicated (first match wins)** and damped by ×0.2 floor 1e-4 (D9:3590/:3615). Do not hand-write pick lists. Correct family sizes: `plain_medium` 24/67.6875 at D8:288; `plateau_big` 5/13 at D8:635; `desert_tiles` 6/4100 at D8:1629.
8. **Do not implement dead code**: dead `SetupTiles` (D1:499–519, call commented :1593), dead `frt_*` 16-retry branch (D4:222), dead leaf/mixed forest cases (D1:6), dead `ravine_medium` (D1:1760), dead debug block after D4:652, dead C3 placement (D1:949–977), editor-only D7/D2 tails.

---

## 6. Contradictions / strange fragments — multi-pass verdicts

Each item below was read twice with different instruments (numbered latin-1 dump, then direct latin-1 re-read of the original path via `verify.py`), then cross-checked against A02 and TERRAIN_DONOR_PIPELINE. None was silently skipped.

| Id | Fragment | Pass 1 | Pass 2 | Cross-check | Final reading / label |
|---|---|---|---|---|---|
| A1 | D4:222 `for [MAIN]try0:=1 to 1 do` with `if (try0=0)` branch at :238–292 and `if (try0=1) then break(MAIN)` at :333–334 | read in full | raw re-read D4:220–225, :296–312, :328–336 | A02 §Stage 10 says "frt_* big/med/small sets with 16 internal retries, skipping frt_s_p_2/4/6 (D4:265–292)" | **[O] A02 overstates: the 16-retry branch is unreachable.** Only `n_small_frt_lite_*`/`n_small_frt_*` at D4:316–319 runs. The skip list at :280 is dead too. |
| A2 | D6:104–151 `count=floor(1+RandomExt*16)` loop but `break;` at :151 inside the unconditional `if (pname<>'')` block | read in full | raw re-read D6:100–155 | audit §3.2 / A02 say "1–16 fb_* objects per cell" | **[O] The loop executes once per eligible cell.** `count` only affects RNG consumption (one `RandomExt` draw is still spent at :104). Translate as 1 stamp/cell, 1..53 index, rad 1.5. |
| A3 | D1:1735–1736 `lake_big := plain*2*0`, but D1:1812 `lake_big := plain*35` | read in full | raw re-read D1:1733–1740, :1801–1814 | A02 §4c / audit C24 say lakes "hard-zeroed" | **[O] Both are true by season:** non-desert `lake_*` = 0; desert stamps `desert_lake` with freq `plain*35`. Do not zero desert lakes. |
| A4 | D2:818 explicit layer prefill guarded `(not bRandomMap)`; D2:491–495 blanket prefill | read in full | raw re-read D2:815–839 + grep all `bRandomMap` sites | A02 §4d / C13 list water/shore/G/R/broad/border as one prefill layer set | **[O] Two different mechanisms.** For random maps: blanket non-black/non-white (D2:491–495) + shore (D1:1568) + border (D1:1613) + ellipses (D1:984/:769/:947). Editor-only: D2:818. Do not merge them. |
| A5 | D2:626 `ny:=ClampInt(y-rad,0,mapwidth-1)` and D2:228 `(y<mapwidth div 2)` — width used as y bound | read in full | raw re-read D2:224–243, :610–640 | A02 §Stage 5 describes mask-B + height band, not the index bug | **[O] Literal donor text preserved.** For square maps (donor `mapwidth=mapheight`) the effect is nil; for non-square ports it changes the coast gate. Mark PORT APPROXIMATION if you "fix" it. |
| A6 | Scale clamp: D1:2006/:2018 uses `scaleMin+(scaleMid-scaleMin)*random`; D2:984–998 and D4:391–405 use `cDiffKoefMin/Max` (0.875/0.95, 1.04/1.08) with those lines **commented out** in D1:2002–2005/:2014–2017 | read in full for D1, D2, D4 | raw re-read D1:1998–2023, D2:980–1002 | A02 §Stage 10 cites "5% dead-band" without distinguishing branches | **[O] Two live variants:** skirmish `DoGenerate` uses the midpoint-lerp form; `TextureMap` and editor post-stand use the koef form. Both share the `0.05` dead-band and `terrainmesh`/`stones` skip. |
| A7 | D9 total 7,013 lines (audit 6,765); D8 `plain_medium` 24 members/67.6875 (audit 31/74.6875) | scripted parse + read | raw re-read D9 via direct path; D8:288–388 via two instruments | audit §1.2 / §3.6 | **[O] Audit numbers wrong; byte size 250,432 matches, so install is the same.** All D9 line ranges cited by audit/A02 still match exactly. Use 24 / 67.6875. |
| A8 | D2:565 skips starts with `(fr=1) and (fb=1)` only, while D2:413/:491 require all three channels | read in full | raw re-read D2:552–578 | A02 §Stage 2 uses "pure white (r,g,b)" | **[O] Height pass ignores G.** A pixel with R=B=1 but G≠1 would be treated as a start in height but not in decode. Preserve literal behaviour; record such cells in trace if encountered. |
| A9 | D4:214 `// TODO Place stone and forest stone patterns` followed by `n_small_frt_1` stamp | read in full | raw re-read D4:206–218 | audit C21 says "stone/foreststone families" | **[O] Comment contradicts code.** Live code stamps one fixed pine pattern for both G=3 and G=4. Do not invent separate stone objects here. |
| A10 | Re-seed count | grep over D1/D2/D3 in Pass 2 | raw re-read of all 14 matches | A02 E02 lists 5 sites | **[O] 11 `SetRandomKey` + 3 `SetRandomExtKey64` sites.** See §1 item 2 / E02. |
| A11 | `ravine_medium` family exists (D8:540–579, 9 members) but call is commented (D1:1760) | read in full | raw re-read D9/D1 + D8 parse | audit C? and A02 §4b say do not add `k_ravine_1` producer | **[O] Dead family.** Do not import/stamp it; `k_ravine_1` at D8:543 is never selected. |
| A12 | D5:124–125 `ind2ProbZero := ind2ProbZero` no-op; `sumProb` never initialised before `:53` | read in full | raw re-read D5:122–130 | audit C23 records compatibility table only | **[O] Strange but literal.** Likely vestigial; do not "repair" in a parity translation; initialisation semantics of DScript locals are **[U]**. |
| A13 | D4:564 `vecangle>=120 and vecangle<=150+20` asymmetric upper bound; D2:689 `mapsizemod` uses float division where a commented variant uses integer div | read in full | raw re-read D4:557–575, D2:687–690 | not covered by A02/audit | **[O] Preserve verbatim.** These are literal donor expressions; a cleaner formulation is PORT APPROXIMATION. |

No item was marked UNVERIFIED solely because of a single failed read; each has two documented passes.

---

## 7. Risks

| # | Risk | Severity | Mitigation |
|---|---|---|---|
| R1 | Workers translate A02 pseudo-code instead of the quoted donor text and inherit A1/A2/A3/A4 errors | high | Treat §6 as binding errata; cite D1–D8 line in every implementation comment |
| R2 | Dead branches reimplemented (extra RNG draws) → seed replay diverges | high | Implement only lines marked live in §3; maintain per-stage RNG trace |
| R3 | Blend-mode math still **[U]** (not in assigned files) | high | Carry flags from DPATTERN_01, label operation PORT APPROXIMATION, unit-test grid min/max |
| R4 | `tilesmooth_scripts.cfg` unread → Stage 5g approximation | medium | F03/F05 must supply parsed tables; record table hash in trace |
| R5 | Non-square maps expose D2:228/:626 width-as-y bugs | medium | Preserve literal and document divergence, or freeze square-map contract |
| R6 | Version-gated mine radii (D1:559–654) chosen from wrong branch | medium | Resolve `gRecordGeneratorVersion` (D3:57) at replay time; record branch in trace |
| R7 | D8 duplicate family names shadow later blocks | medium | De-duplicate first-match before building weight tables |
| R8 | D9 supplementary ranges are outside assigned file set and could shift in another install | low-medium | Re-verify D9 ranges before using them as a parity reference; this install's cited ranges match audit |
| R9 | No donor GPU A/B frame | high (epistemic) | No parity claim; telemetry/histograms only |

---

## 8. UNVERIFIED register

| # | Item | Status | Resolution owner / note |
|---|---|---|---|
| U1 | `RandomExt` / `SetRandomKey` key-mixing algorithm | **[U]** | D02; no plaintext consumer in D1–D8 |
| U2 | Engine height-blend operation for `HeightField*` flags, clamp/scale order, `HeightFieldReplace` target, `HeightFieldSmooth` definition | **[U]** | D05; inherited from DPATTERN_01, not re-read here |
| U3 | `SmoothTerrain` internal power/lerp for the `bsmooth` pass | **[U]** | D03; only the `3` argument is quoted at D2:591 |
| U4 | `tilesmooth_scripts.cfg` `TileNames`/`Prob` contents | **[U]** | F03/F05; only consumer D5:44–57 quoted |
| U5 | `gc_MaxTerrainTypeCount` value | **[U]** | D03/F03; D1:1550/:1557 use it |
| U6 | Per-shape mask counts 121/187/320/230/122/42/33/280 | **[I]** inherited, not re-verified here | F04 |
| U7 | Shipping `gRecordGeneratorVersion` | **[U]** fresh maps take `gDataVersion` (D3:57); shipping value unknown | D07 |
| U8 | Exact start-spacing acceptance (0.7/1.5–2 cm) | **[U]** modder changelog, not in scripts | D07 |
| U9 | R1–R6 relief-generator numeric parameters | **[U]** inherited C27 | editor/binary lane |
| U10 | Standalone mill-field decoration stage / tile rule | **[U]** no donor stage line; only food rects D1:720–978 and `envfieldd` decals (inherited) | F07 |
| U11 | Donor units → port tile scale denominator (160 vs 320) | **[U]** | D04/F03 |
| U12 | `cstartoffset=60` / `cstartoffsetrnd=25` meaning | **[U]** no consumer found (D1:484–485) | D01/D03 |
| U13 | DScript local-variable initialisation semantics (`count`, `sumProb`, `fbcount`, `arrfb`) | **[U]** engine-side | binary lane; affects A12 only |
| U14 | Full `w×h` relief grids and pattern footprint/collision data (`pattern.lib`) | **[U]** inherited | F01/A03 |
| U15 | Winter tile-name availability/mapping beyond the `_winter` suffix rule (D4:525–526/:605–606/:639–640, D6:138–139) | **[U]** | F05/F10 |
| U16 | Whether the D9 ranges are stable across builds | **[U]** this install matches audit line numbers but has a different total line count | D-lane re-check |

---

## 9. Open questions

1. Should the port reproduce D1's **wavefront BFS** (D1:1395–1419) or a FIFO queue? They agree on `dist` but not on visit order within a ring. **[D] → A06/A05.**
2. For non-square maps, do we preserve the literal `mapwidth` y-bound at D2:228/:626, or declare square maps only? **[O] + [U] semantics → COORD.**
3. Does `gPatternMask` from D2:491–495 (blanket) intentionally override the finer editor prefill, or is the editor path the "designed" one? **[I] → D03/D07.**
4. Which mine-radius branch ships (`<80` vs `≥80` vs newer)? D3:57 ties it to `gDataVersion`. **[U] → D07.**
5. Are `HeightField*` blend flags consumed by `StandPatternWithAngle` (D9:3390) inside the engine, and in what order relative to `SetHeightData` (D2:574)? **[U] → D05.**
6. Does the desert `desert_lake` override (D1:1812–1813) apply to random maps with `season=3`, and should the port emit lake props there? **[O] lines / [I] visual result → F08.**
7. Were D8 duplicate family blocks ever intentional (version fallback) or simply stale? First match wins in the current engine (audit §6.10, inherited). **[U] → F03.**
8. Should the unreachable `frt_*` branch (D4:238–292) be ported behind a non-vanilla "legacy forest detail" switch? **[I] → A04/owner.**

---

## 10. Files changed / sign-off

- `docs/terrain_swarm_2026-11-26/reports/X03_dscript_corpus.md` — **new**; this is the only repo file written by X03.
- No donor file copied, modified, or executed. No Godot process or runner job submitted. No gate weakened. No donor parity claim made.

*End of X03 report.*
