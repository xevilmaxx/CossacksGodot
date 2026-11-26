---
id: V01
ticket: TERRAIN-SWARM-2026-11-26 / voter V01 (DONOR-FIRST terrain swarm)
title: "Resolution of A02 §8's 16 UNVERIFIED items — donor text, decompiled stamps and landed co-reports"
agent: "V01 (research/verification subagent)"
created: 2026-11-26
status: DELIVERED__ONE_REPORT__READ_ONLY__NO_DONOR_BINARY_RUN__NO_CODE_EDIT
owner_file: docs/terrain_swarm_2026-11-26/reports/V01_unverified_resolution.md
scope: "Exactly one repo file written: this report. No source, shader, config, asset, test, JSON, PNG, donor, queue or git edit; no Godot process/runner job; no donor executable executed; no donor bytes copied into the repo."
donor_root_read_only: "C:\\Games\\Cossacks 3"
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_guard: "No donor GPU A/B frame exists. Every downstream visual expectation remains INFERRED/UNVERIFIED. No donor parity claim is made."
---

# V01 — Resolving A02's 16 UNVERIFIED items

## 0. Mandate, method and pass register

A02 §8 (`docs/terrain_swarm_2026-11-26/reports/A02_algorithm.md:778-797`) lists 16
`[U]` items to be resolved before implementation begins. This report examines each
one against: donor plaintext (`dogenerate.inc`, `generatemap.inc`, `initmapgen.inc`,
`texturemap.inc`, `smoothtiles.inc`, `postprocess.inc`, `generator.cfg`, plus
`serial.script`, `dmscript.global`, `donewgame.inc`, `pattern.lib`, `decals.lib`,
`misc.script`, `unit.script`, `readnewp.inc`, `writenewp.inc`, `terrain.presets`,
`tiles.mat`); landed prior reports (`TERRAIN_DONOR_PIPELINE.md`, `GUIDE4.md`,
`DPATTERN_01_relief_grids.md`, `DEC_05_terrain_formats.md`, `DMAPGEN_01_skirmish_options.md`,
`A04_landscape_props.md`); and reports that landed **during** this ticket
(`F02`, `F03`, `F05`, `D05`, `D06`, `D07`, `X03`).

**Line numbering.** All donor `path:line` citations are 1-based as returned by
PowerShell `Get-Content` and the `read` tool; they agree with the prior reports'
line claims (e.g. D2:4 is donor `generatemap.inc` line 4). Each file has one
trailing newline, so `Get-Content | Measure-Object -Line` reports +1 vs the
prior "Lines" column in `TERRAIN_DONOR_PIPELINE.md §1`; this is a terminator
artefact, not a shifted citation. **GUIDE4 caveat:** the file's printed row
labels are offset by −30 from physical file lines (printed `2029` = file line
`2059`); both forms are given below.

**Labels:** `[O]` observed literal donor line, byte or file inventory; `[D]`
derived arithmetic/control-flow consequence of `[O]`; `[I]` inference; `[U]`
UNVERIFIED; `PORT APPROXIMATION` for any port-side substitute. **No parity
claim.**

### 0.1 Pass register (owner directive: anomalous lines get multiple passes)

| Pass | Instrument / section | Anomaly investigated | Outcome |
|---|---|---|---|
| P1 | `read` full `initmapgen.inc` (289 lines) | Does a stage re-seed derive a new key? | Both calls are verbatim `SetRandomKey(gMap.settings.gen.randkey1)` (D3:99, :146). No derivation in this file. |
| P2 | PowerShell recursive grep of all `data\scripts\*.inc/*.script` for `SetRandomKey|SetRandomExtKey64|gDataVersion|randkey` | 11 + 3 reseed sites; is there a hidden derived key? | All 11 `SetRandomKey` sites pass `randkey1` verbatim; the 3 `SetRandomExtKey64` sites use `randkey0/1` read verbatim at D2:142-143. Cross-checked with landed `X03_dscript_corpus.md:44` (11 sites). |
| P3 | `read` `serial.script:20-31` **and** a second PowerShell slice of the same range | D07 §6 U4 says `gDataVersion` "not in script text" | **Contradiction resolved:** `C:\Games\Cossacks 3\data\scripts\lib\serial.script:27` is literally `gDataVersion:=92;`. D07 searched `common.inc`/cfg, not `lib\serial.script`. |
| P4 | `read` `dogenerate.inc:559-723` twice (whole `SetupMines`) + `donewgame.inc:42-49` + prior `D07_resources_bin.md:185-219` | A02 says "small map ≤4 players" has round 2 unassigned and "large map" has round 2 `70+12r`; the donor comment says `mapsize>2 // tiny` | **Reversal found.** `mapsize>2` maps to **256** (the smallest map) at `donewgame.inc:46`, so A02's small/large labels are swapped. D07's §3.4 320-cell example (`:217-218`) is inconsistent with its own gating condition. Accepted the enum, not the comment/example. |
| P5 | `Get-ChildItem` file inventory of `data\gen\terrainmasks\*` and `.dlc5\*` | A02 U1 counts "med 122" from almanac | Direct count: `mediterranean` has **118 `.tga` + 4 `.removed` = 122 files**. Selector glob is `*.tga` (D2:174) → only 118 selectable. All other seven counts match exactly. |
| P6 | `read` `DPATTERN_01_relief_grids.md:348-382` + `pattern.lib:549559-549584` + `pattern.lib:337470-337493` + `D05_relief_stamp.md:92-211` | Blend flags look like a clamp formula in A02 but DPATTERN says "no consumer" | **Superseded by landed D05.** DPATTERN's negative scan was correct for text files but not for `cossacks.exe` CODE. D05 P1–P10 re-derived the blend from raw x87 opcodes and `editor.exe` cross-check; accepted D05. |
| P7 | `read` `decals.lib:30-51`, `misc.script:4278-4306`, `readnewp.inc:30-52`, `writenewp.inc:12-34`, `unit.script:6470-6570` + A04 E11/E12/E13 | Does a standalone generation "mill-field" stage exist? | No generator-stage call. The decal is attached to each `field` game object at object (de)serialisation, with roll 45/225 and `texscalefix=1.3`. Confirmed in two independent scripts (read/write). |
| P8 | Recursive grep of all donor `.inc/.script/.cfg/.txt/.aix` for `furrow|passage width|R1-R6|ReliefGen|GenerateRelief`; second grep over all `docs/coord_swarm_2026-11-25/decomp/*.md`; `GUIDE4.md:653-654` | Are there numeric R1–R6 ranges anywhere? | Zero donor-text hits, zero decomp-report hits. GUIDE4 only names the six editor-manual parameters, with no numbers. Stays `[U]`. |
| P9 | Recursive grep for `startoffset` (case-insensitive) over all donor text; second pass over `dogenerate.inc` only | Are `cstartoffset/cstartoffsetrnd` consumed? | Only the two declarations at D1:484-485. The `cStartOffset` at `misc.script:5280` is a different, unrelated constant (`1.07*cScale`). Vestigial confirmed. |
| P10 | `read` `generatemap.inc:218-245, 580-610` + recursive grep for `procedure SmoothTerrain` | Does the script expose `SmoothTerrain`'s power/lerp? | `SmoothTerrain` occurs exactly once in the whole donor script tree (D2:591) — it is a native. Only the separate `_misc_SmoothTerrainCustom` helper has literal `power=4, lerp=0.5`. Native internals stay `[U]`. |

---

## 1. Executive summary

1. **[D] 10 of 16 items are fully RESOLVED, 3 are partially resolved and 3 stay
   UNVERIFIED** with the evidence now in hand (table in §3). The largest wins
   are the decompiled stamp math (U3/U4/U5 via landed D05), the shipping
   generator version (U8), the mask inventory (U1), the tile-smooth tables
   (U7), and the field-decal rule (U11).
2. **[O] `gDataVersion:=92`** (`lib\serial.script:27`), and
   `gRecordGeneratorVersion := gDataVersion` (`initmapgen.inc:57`) for new maps;
   replay maps read `ver` from the record (`initmapgen.inc:72`). Therefore the
   shipping branch is `v>=80` (and `v>=90` for the tiny-map corner relocation),
   and the `v>=91` `TerrainTypesDLC5` table. This refutes D07's U4 `[U]`.
3. **[O] There is no donor key-derivation function in the script tree.** All 11
   `SetRandomKey` re-seeds pass `gMap.settings.gen.randkey1` verbatim, and the
   3 `SetRandomExtKey64` calls use `randkey0/1` read verbatim from settings.
   A02's `mix64(randkey1, randkey2, stable_hash(sid))` is therefore a
   `PORT APPROXIMATION` that **diverges** from donor behaviour: the donor
   restarts the *same* stream at each stage, it does not derive independent
   per-stage streams. The engine's key→state/RandomExt internals remain `[U]`
   (D02 / X01).
4. **[O] Mine radii are indexed by round, version, mapsize enum and player
   count**, and `mapsize>2` is the **256-cell tiny** map (`donewgame.inc:46`),
   not "large". A02's §4 small/large labels are reversed, and its "small map"
   row silently inherits an unassigned `dst` for round 2 (a real authoring
   quirk, `[O]` text / `[U]` runtime).
5. **[O] The relief frequency table relieftype 0–4 and the keep-clear ellipses
   C1/C2/C3 are confirmed verbatim** (`dogenerate.inc:1621-1649`, `:407-414`)
   — no correction needed to A02's numbers.
6. **[O] `envfieldd` is not a terrain-generation stage.** It is a 2×2 decal
   bound to `field` game objects when they are created on load/save, with
   scale `60`, angle `45` or `225` by `random>0.5`, and `texscalefix=1.3`; the
   49 nodes come from mill runtime `_unit_DoSeedWheat`. A02 Stage 9's
   "guaranteed food rects in `SetupStartingResources`" is contradicted by
   `D07_resources_bin.md:42-48`.
7. **[O] The three blend branches and the smooth post-pass are now
   donor-derived**, not approximations: `ReplaceForWater`, `Replace`, and the
   default "Smooth" path, with `Min` as a pivot and `Max` **unused** in the
   stamp. `HeightFieldScale=-0.925` inverts the grid around the pivot, not the
   world height. Row-sign (`row_flip`) and the global setter clamp stay `[U]`.
8. **No donor GPU A/B frame exists.** Everything in this report is static
   text, file inventory or decompiled code; visual acceptance stays `[U]`.

---

## 2. Evidence table

| Id | Evidence (donor `path:line` / landed report) | Label | Resolves |
|---|---|---|---|
| EV01 | `C:\Games\Cossacks 3\data\gen\terrainmasks\*` file inventory (8 dirs) + `.dlc5\*` (11 dirs) | `[O]` | U1 |
| EV02 | `data\scripts\common.inc\generatemap.inc:174,179-183,190` (`ParserGetFilesInRoot(folderpath+'\*.tga')`; `floor(RandomExt*count)`) | `[O]` | U1 selection rule |
| EV03 | `data\scripts\lib\serial.script:22-30`, especially `:27 gDataVersion:=92;` | `[O]` | U8 (refutes D07 U4) |
| EV04 | `data\scripts\common.inc\initmapgen.inc:57,72,99,146` | `[O]` | U2, U8 |
| EV05 | `data\scripts\common.inc\dogenerate.inc:1100,1161,1177,1213,1538,1616,1772,1909,1927` (all `SetRandomKey(randkey1)`) | `[O]` | U2; corroborated by `X03_dscript_corpus.md:44` |
| EV06 | `data\scripts\common.inc\generatemap.inc:142-143,216,513,774` | `[O]` | U2 |
| EV07 | `data\scripts\common.inc\dogenerate.inc:522-717` (SetupMines), especially `:525,528-535,544-550,559-655,658-696,704-713` | `[O]` | Mine radii/round table, U8 gates |
| EV08 | `data\gui\menu.inc\donewgame.inc:42-49` (`0→320, 1→480, 2→640, 3→256`) | `[O]` | `mapsize>2` = tiny; corrects A02 labels & D07 §3.4 example |
| EV09 | `data\scripts\common.inc\dogenerate.inc:407-416` (`cCircle1MaskX=5/Y=7`, `cCircle2MaskX=12/Y=15`, `cCircle3MaskX=22/Y=18`, `cBorderObjDist=1`) | `[O]` | Ellipses (priority item) / C1–C3 |
| EV10 | `data\scripts\common.inc\dogenerate.inc:484-485` + recursive `startoffset` grep (P9) | `[O]` | U16 |
| EV11 | `data\scripts\common.inc\dogenerate.inc:1621-1649,1757-1765` | `[O]` | Relief frequency table (priority item) |
| EV12 | `data\scripts\dmscript.global:132-135,166,170-175,236,238` | `[O]` | U9, U15, `gc_MaxReliefTypeCount=5` |
| EV13 | `data\scripts\common.inc\generatemap.inc:218-245,580-610`, flags `:38-39` | `[O]` | U6 (native call, helper params) |
| EV14 | `data\gen\tilesmooth_scripts.cfg:1-96,934-1810` + `reports/F03_gen_config.md:570-626` | `[O]`/`[D]` | U7, U14 |
| EV15 | `data\gen\globalparams.cfg:9-10` vs `smoothtiles.inc:5,237` (`F03_gen_config.md:38`) | `[D]` | U7 contradiction preserved |
| EV16 | `reports/D05_relief_stamp.md:16-25,92-211` (decompiled `sub_755f30`, evidence ids `ev_e65fb8fd…`, `ev_dbc8c87e…`, `ev_44c61fad…`) | `[O]`/`[D]` | U3, U4, U5 |
| EV17 | `data\pattern\pattern.lib:549559-549584` (`k_ravine_1`), `:337470-337493` (`g_mnt_1`) | `[O]` | U3–U5 literals |
| EV18 | `data\terrain\decals\decals.lib:37-43`; `data\scripts\lib\misc.script:4284-4306`; `data\scripts\units\global.inc\readnewp.inc:41-47`; `writenewp.inc:23-29`; `data\scripts\lib\unit.script:6470-6570` | `[O]` | U11 |
| EV19 | `docs\guides\GUIDE4.md:653-654` (printed `0632-0633`, R1–R6 names only) + P8 exhaustive negative | `[O]`/`[U]` | U12 |
| EV20 | `data\terrain\tiles\terrain.presets:2-12,135-146`; `data\terrain\tiles\tiles.mat:485-491`; `reports/F05_tile_mapping.md:361-368` | `[O]` | U14 |
| EV21 | `reports/DPATTERN_01_relief_grids.md:140-178,289-298,450-498`; `reports/F02_pattern_lib.md:471-476,542-543` | `[O]`/`[U]` | U13 (partial) |
| EV22 | `data\scripts\common.inc\dogenerate.inc:1048-1084,1090-1229`; `docs\research\RC_TERRAIN.md:73` (modder changelog) | `[O]` vs `[U]` | U10 |
| EV23 | `data\scripts\common.inc\dogenerate.inc:1-12` (`bDesert`, `foreststype`), `data\scripts\dmscript.global:238` (`gc_MaxReliefTypeCount = 6-1`) | `[O]` | Relief table bounds |
| EV24 | `reports/D07_resources_bin.md:42-48,185-219,417-420` | `[O]`/`[I]` | Cross-check mines/fields; sources of contradictions |

---

## 3. Item-by-item resolution table

Status key: **RESOLVED** = exact donor path:line + literal recovered;
**PARTIAL** = one half recovered, the other half still `[U]`;
**STILL UNVERIFIED** = no donor value found after the recorded passes.

| # | A02 §8 item | Status | Exact donor evidence / literal / label | Note |
|---|---|---|---|---|
| U1 | Per-shape mask counts (121/187/320/230/122/42/33/280) | **RESOLVED** (with correction) | `[O]` `data\gen\terrainmasks\`: `continent` 121 `.tga`, `continents` 187, `islands` 320, `land` 230, `mediterranean` **118 `.tga` / 122 files** (4 `*.removed`), `nowater` 42, `nowater2` 33, `peninsulas` 280. DLC5 `data\gen\terrainmasks.dlc5\`: coastal 57, lakes 151, rivers 157, mediterranean 207, continent 167, continents 196, islands 330, land 230, nowater 42, nowater2 33, peninsulas 286. Selector `[O]` `generatemap.inc:174,190` uses `*.tga` and `floor(RandomExt*count)`. | "med 122" was an all-files count; only 118 are selectable. |
| U2 | `RandomExt` / key-mix function (seed derivation formula) | **PARTIAL** — script derivation RESOLVED (`identity`); engine RNG STILL UNVERIFIED | `[O]` `initmapgen.inc:99,146` and `dogenerate.inc:1100,1161,1177,1213,1538,1616,1772,1909,1927`: all literally `SetRandomKey(gMap.settings.gen.randkey1)`. `[O]` `generatemap.inc:142-143` `randkey0 := gMap.settings.gen.randkey0; randkey1 := gMap.settings.gen.randkey1;`, `:216/:513/:774` `SetRandomExtKey64(randkey0, randkey1)`. | **No mix64.** The donor restarts the same 64-bit pair at every stage. A02's per-stage *independent* streams are a `PORT APPROXIMATION`. `RandomExt` internals `[U]` → D02/X01. D05 F6 found an engine LCG `x=x*0x8088405+1` at `0x403a28` used by the random-scale path; linking it to `RandomExt` is `[I]` only. |
| U3 | Engine height blend operation, clamp/scale order, `HeightFieldScale=-0.925` sign, `row_flip` | **PARTIAL** — blend/math RESOLVED via D05; `row_flip` STILL UNVERIFIED | `[O]` `reports/D05_relief_stamp.md:17-24,132-172` (decompiled `sub_755f30`, raw opcode pass P6). Formula in §4.4. `HeightFieldMin` is a pivot, `HeightFieldMax` is **never read** in the stamp, no clamp. `-0.925` multiplies the grid (inverts relief around `Min`), never the world height. `[U]` row_flip: D05 U1, DPATTERN §2.2, F02 U-F02-2. | D05's 10-pass register satisfies the owner directive; supersedes A02's `PORT APPROXIMATION ADDITIVE_CLAMP`. |
| U4 | `HeightFieldReplace` replacement target value | **RESOLVED** | `[O]` D05 F4: `ReplaceForWater=true` → `setHeight(c,r, g*Scale + HeightFieldOffset)`; `Replace=true` (never observed on a real pattern, 680/680 false) → `setHeight(c,r, base_h + g + HeightFieldOffset)`. `[O]` literals `pattern.lib:549563 HeightFieldReplace = False`, `:549564 HeightFieldReplaceForWater = True`. | A02's placeholder `HeightFieldMin + 0.0` is **wrong**; the replace target is a computed grid value, not `Min`. |
| U5 | `HeightFieldSmooth` local-smooth definition (radius/factor/offset semantics) | **RESOLVED** | `[O]` D05 F5 (`sub_755f30` VA `0x756eb3`-`0x757286`): only if `HeightFieldStand && HeightFieldSmooth`; interior cells whose own byte and all 8 neighbours are 0; `d = sqrt((x-cx)^2+(z-cz)^2)`, `tx=round(cx+(x-cx)*(Radius-Offset)/d)`, same for `tz`; repeat `Factor` times a 4-neighbour mean `/4.0f` inside `|(u,v)-(tx,tz)|^2 < Radius^2`. `[O]` `pattern.lib:549573-549575` `Radius=2, Factor=4, Offset=0`; `:337479-337481` `3/4/2`. | `[D]` `Factor` is the iteration count, the `4.0` divisor is hardcoded, not the config value. |
| U6 | `SmoothTerrain` internal power/lerp for `bsmooth` pass | **STILL UNVERIFIED** | `[O]` `generatemap.inc:591 SmoothTerrain(realx, -realy, False, 3);` is the only occurrence of that name in the whole script tree (P10) — a native. `[O]` flags `:38 cSmoothTerrainUsingBitmap = True`, `:39 cSmoothAllMapHeight = True`; `[O]` helper `:218 procedure _misc_SmoothTerrainCustom(x,y,times:Integer; power,lerp,minh,maxh:Float)`, call `:606 (...,1,4,0.5,0.01,100)`. | The `power=4, lerp=0.5` values belong to the **global** pass, not to `SmoothTerrain`. D03 (not landed at write time) could settle this via binary study. |
| U7 | `tilesmooth_scripts.cfg` `TileNames`/`Prob` lists | **RESOLVED** (consumer activity still `[U]`) | `[O]` `data\gen\tilesmooth_scripts.cfg:1-1863`: 22 chains, 130 groups (118 active), 310 entries (282 active), 86 names, ΣProb=174.0168; full enumeration in `reports/F03_gen_config.md:599-626`. Verbatim sample in §4.7. `[D]` winter chains C11–C20 are exact `_winter` mirrors of C00–C09. Contradictions preserved: `globalparams.cfg:9 TileSmoothPasses=6` vs `smoothtiles.inc:237 SmoothTileMap(...,3)`; `:10` names `tilesmooth.cfg` vs `smoothtiles.inc:5` loads `tilesmooth_scripts.cfg`. | Every consumer line in `smoothtiles.inc` is `;`-prefixed; runtime activity `[U]` per F03 F15 / D06. |
| U8 | `gRecordGeneratorVersion` shipping value (mine radius branch) | **RESOLVED** (corrects D07 U4) | `[O]` `data\scripts\lib\serial.script:27 gDataVersion:=92;`. `[O]` `initmapgen.inc:57 gRecordGeneratorVersion := gDataVersion;` (new game); `:72 ... := ParserGetIntValueByKeyByHandle(pGen, 'ver')` (replay). | 92 ⇒ `>=80` radii, `>=90` corner rule, `>=91` `TerrainTypesDLC5`. D07's "gDataVersion not in script text" was searched in the wrong directory. |
| U9 | `gc_MaxTerrainTypeCount` value | **RESOLVED** | `[O]` `data\scripts\dmscript.global:236 gc_MaxTerrainTypeCount = 9;` (also `:238 gc_MaxReliefTypeCount = 6-1;` = 5). Consumer `[O]` `dogenerate.inc:1550,1556,1557`. | Cross-check: `generator.cfg:29-66` has exactly 9 DLC5 terrain types (F03 §7.1). |
| U10 | Exact start-spacing rules (0.7 cm / 1.5–2 cm) | **STILL UNVERIFIED** (donor has no numeric threshold) | `[O]` `dogenerate.inc:1048 VectorDistance(...)`, `:1050 if (dist=0) or (dist>d)`, `:1076-1084` closest/farthest ranking; `:1104 floor(RandomExt*(maxind+1))`, `:1182 GetRandom(points.GetCount)`. No `0.7`, `1.5` or `2` cm literal in either start-point function. The numbers come from `docs\research\RC_TERRAIN.md:73` (EMOM modder changelog). | The *ranking rule* is donor-derived `[O]`; the *numeric spacing* remains `[U]`. D07 (landed, §6) did not resolve it either. |
| U11 | Mill-field standalone stage / exact tile rule | **RESOLVED** (and the premise corrected) | `[O]` `units\global.inc\readnewp.inc:41-47` and `writenewp.inc:23-29`: `if (base=gc_basename_field) then begin if (random>0.5) then _misc_PlaceFieldDecal(gohnd, 60, 45) else _misc_PlaceFieldDecal(gohnd, 60, 45+180); end`. `[O]` `lib\misc.script:4286 procedure _misc_PlaceFieldDecal(goHnd:Integer; scale,angle:Float)`, `:4288 const decalname = 'envfieldd'`, `:4298 const texscalefix = 1.3`, `:4299-4304 w/h := scale*goScale*texscalefix; texOff0/1 := -(texscalefix-1)/2`. `[O]` `decals.lib:38-43` `name=envfieldd`, Summer `envfieldd`, Winter `envfielddw`, width 2, height 2. `[O]` `unit.script:6475-6479` `cRow=7; cCount=49; size=1.6981`, `:6494-6499` 45° rotation + `sqrt(2*size^2)` snap. | No standalone generation stage; no food rects in `SetupStartingResources` (`D07:42-48`). It is a runtime object/decal rule. 3D UV binding stays `[U]` (A04 E13). |
| U12 | R1–R6 relief generator numeric parameters | **STILL UNVERIFIED** | `[O]` `docs\guides\GUIDE4.md:653-654` (printed `0632-0633`) names only: "Relief gen params R1-R6 (height, radius, passage width, furrow count/depth/phase)" from the external editor manual. P8: zero `furrow|passage width|R1-R6|ReliefGen|GenerateRelief` hits in all donor `.inc/.script/.cfg/.txt/.aix`, zero in all `coord_swarm_2026-11-25/decomp/*.md`. Prior C27 exhaustive script grep also zero (TERRAIN_DONOR_PIPELINE.md:265). | Editor/binary lane (D09/X02) could look for UI form labels, but no numeric range can be asserted from donor text. Do not invent. |
| U13 | Full `w×h` relief grids for all donor-active ids | **PARTIAL** — 26 grids decoded bit-exact, remainder STILL UNVERIFIED | `[O]` `DPATTERN_01_relief_grids.md:140-178` = 26 patterns with exact offsets and float min/max; `:289-298` 26/26 bit-exact vs `pattern.lib`. `[O]` `reports/F02_pattern_lib.md:471-476` = 12/12 cross-checks, with the ±24–160 B boundary caveat. `[U]` DPATTERN §9 Q1, F02 U-F02-1. | Active relief families name ~50+ members (`generator.cfg:446-754`); only a subset has full grids. Repeatable read-only recipe at DPATTERN §7; F01/A03 can finish. |
| U14 | Winter tile-name mapping for `_winter` suffix | **RESOLVED** | `[O]` `data\terrain\tiles\terrain.presets:2-4` `SetName = Summer`, `:6 [*].TileBlock = grass1`; `:135 WaterSet = Winter`, `:138 [*].TileBlock = grass1_winter`, `:139 grass2_winter`… (124 Summer ids `:6-129`, 124 Winter ids `:138-261`). `[O]` `tiles.mat:485-491` `Material.Name = grass9_winter → winter0.dds`, `grass10_winter → winter0.dds`. `[D]` `F05_tile_mapping.md:361-368`: index-preserving aliases; `alpha0a/b/c` shared; desert winter reuses summer DDS. | Also: `F03_gen_config.md:597,614-624` winter tile-smooth chains C11–C20 mirror summer with `_winter` suffix and identical `Prob`. |
| U15 | Donor units → port tile scale denominator (160 vs 320) | **RESOLVED** (negative finding: no donor 160) | `[O]` `dmscript.global:171 gc_meters_to_tile = 2;`, `:170 gc_pixels_to_meter = 26.6666666;`, `:172 gc_pixels_to_tile = 53.3333333;`, `:132 gc_MaxMapWidth = 640;`. `[O]` `donewgame.inc:42-49` donor map sizes 256/320/480/640. `[O]` `dogenerate.inc:437-438 maphW := mapW div 2` and mine bands are in map cells (`D07:182-183`). Whole-script grep of `\b160\b`: only `dmscript.global:166 gc_formation_maxcount=160`, `:207 captureblockshotradius=160/gc_pixels_to_tile`, `:1223 charfilter` — none map-scale. | Port `variant3d/scripts/pattern_gen.gd:9 const DONOR_UNITS := 160.0` is a `PORT APPROXIMATION` with no donor literal. DEC-05 (SUMMARY §5) confirms `TILE_M=2.0` is donor-grounded. |
| U16 | `cstartoffset=60` / `cstartoffsetrnd=25` meaning | **RESOLVED** (vestigial) | `[O]` `dogenerate.inc:484 const cstartoffset = 60;`, `:485 const cstartoffsetrnd = 25;`. P9 recursive case-insensitive grep over all donor `.inc/.script/.global/.cfg/.aix`: no consumer. Landed `X03_dscript_corpus.md:241` agrees. The `cStartOffset` at `misc.script:5280` is `1.07*cScale` — a different constant. | Do not assign meaning; omit from spec or record as "declared, unused". |

### 3.1 Priority-item cross-checks requested by COORD

| Priority item | Verdict | Evidence |
|---|---|---|
| Per-stage key derivation | RESOLVED as *identity re-seed*; engine RNG `[U]` | EV04–EV06 (§2). 11 + 3 sites, all verbatim keys. |
| `HeightField*` blend-flag math | RESOLVED via D05 (3 branches, pivot Min, Max unused, smooth post-pass) | EV16/EV17; §4.4–4.5 verbatim. |
| R1–R6 relief ranges | STILL UNVERIFIED (names only, no donor numbers) | EV19. |
| Exact mine radii / round table | RESOLVED, with correction of A02's swapped labels and an added `spcount>4` branch | EV07/EV08; §4.3 verbatim. |
| `envfieldd` field-decal rule | RESOLVED (runtime per-field object; 45/225, scale 60, 1.3×, winter material) | EV18; §4.6 verbatim. |
| Relief frequency table relieftype 0–4 | RESOLVED, **no correction** — A02's five triples match the donor exactly | EV11; §4.8 verbatim. |
| Start keep-clear ellipse constants | RESOLVED, **no correction** — `5/7`, `12/15`, `22/18` | EV09; §4.2 verbatim. |

---

## 4. Verbatim donor excerpts

### 4.1 Version and seed (`lib\serial.script`, `initmapgen.inc`, `generatemap.inc`)

```
serial.script:22: global gDataVersion: Integer;
serial.script:27: gDataVersion:=92;
serial.script:28: gSerialVersion:=gDataVersion;

initmapgen.inc:57:    [*] = ;   gRecordGeneratorVersion := gDataVersion;
initmapgen.inc:72:    [*] = ;   gRecordGeneratorVersion := ParserGetIntValueByKeyByHandle(pGen, 'ver');
initmapgen.inc:99:    [*] = ;SetRandomKey(gMap.settings.gen.randkey1);
initmapgen.inc:146:   [*] = ;SetRandomKey(gMap.settings.gen.randkey1);

generatemap.inc:142:  [*] = ;   randkey0 := gMap.settings.gen.randkey0;
generatemap.inc:143:  [*] = ;   randkey1 := gMap.settings.gen.randkey1;
generatemap.inc:216:  [*] = ;SetRandomExtKey64(randkey0, randkey1);
generatemap.inc:513:  [*] = ;      SetRandomExtKey64(randkey0, randkey1);
generatemap.inc:774:  [*] = ;   SetRandomExtKey64(randkey0, randkey1);
```
`[O]`. Source paths: `C:\Games\Cossacks 3\data\scripts\lib\serial.script`,
`...\data\scripts\common.inc\initmapgen.inc`, `...\data\scripts\common.inc\generatemap.inc`.
All nine `dogenerate.inc` reseeds (`:1100,1161,1177,1213,1538,1616,1772,1909,1927`)
are likewise `SetRandomKey(gMap.settings.gen.randkey1);`.

### 4.2 Keep-clear ellipses and vestigial offsets (`dogenerate.inc`)

```
   8:       [*] = ;function IsDotInElipse(x0, y0, x, y, rx, ry : Float) : Boolean;
  10:       [*] = ;   var val : Float = sqr(x-x0)/sqr(rx)+sqr(y-y0)/sqr(ry);
  11:       [*] = ;   Result := (val<=1);
...
 407:       [*] = ;const cCircle1MaskX = 5;
 408:       [*] = ;const cCircle1MaskY = 7;
 410:       [*] = ;const cCircle2MaskX = 12;
 411:       [*] = ;const cCircle2MaskY = 15;
 413:       [*] = ;const cCircle3MaskX = 22;
 414:       [*] = ;const cCircle3MaskY = 18;
 416:       [*] = ;const cBorderObjDist = 1;
...
 484:       [*] = ;const cstartoffset = 60;
 485:       [*] = ;const cstartoffsetrnd = 25;
```
`[O]` for the literals; `[D]` ellipse test is `((x-x0)/rx)^2 + ((y-y0)/ry)^2 <= 1`
from lines 8–11. D07 `:45-47` adds that the three ellipses are centred at
`(start.x, start.y+2)` at `:769/:947/:984`.

### 4.3 Mine radii, rounds and the reversed mapsize label (`dogenerate.inc` + `donewgame.inc`)

```
dogenerate.inc:522:       [*] = ;procedure SetupMines(pointx, pointy : Float; minround, maxround, minesdensity, spcount : Integer);
dogenerate.inc:525:       [*] = ;   var trycount : Integer = 256;
dogenerate.inc:528:       [*] = ;   case minesdensity of
dogenerate.inc:529:       [*] = ;      0 : rounds := 3;
dogenerate.inc:530:       [*] = ;      1 : rounds := 4;
dogenerate.inc:531:       [*] = ;      2 : rounds := 5;
dogenerate.inc:535:       [*] = ;   for i:=minround to rounds-1 do // rounds
dogenerate.inc:544:       [*] = ;      for j:=0 to 2 do // restypes
dogenerate.inc:548:       [*] = ;            0 : str := 'mng';
dogenerate.inc:549:       [*] = ;            1 : str := 'mni';
dogenerate.inc:550:       [*] = ;            2 : str := 'mnc';
dogenerate.inc:555:       [*] = ;         for k:=0 to trycount-1 do // mines
dogenerate.inc:571:       [*] = ;               if (gMap.settings.gen.mapsize>2) then // tiny
...
dogenerate.inc:594:       [*] = ;                  else
dogenerate.inc:595:       [*] = ;                  case i of
dogenerate.inc:596:       [*] = ;                     0 : dst := 14+RandomExt*8;
dogenerate.inc:597:       [*] = ;                     1 : dst := 32+RandomExt*10;
dogenerate.inc:598:       [*] = ;                     2 : dst := 70+RandomExt*12;
dogenerate.inc:599:       [*] = ;                     3 : dst := 22+RandomExt*16;
dogenerate.inc:600:       [*] = ;                     4 : continue;
dogenerate.inc:604:       [*] = ;               if (spcount<=4) then
...
dogenerate.inc:638:       [*] = ;                  else
dogenerate.inc:639:       [*] = ;                  case i of
dogenerate.inc:640:       [*] = ;                     0 : dst := 14+RandomExt*8;
dogenerate.inc:641:       [*] = ;                     1 : dst := 32+RandomExt*10;
dogenerate.inc:642:       [*] = ;                     3 : dst := 70+RandomExt*12;
dogenerate.inc:643:       [*] = ;                     4 : dst := 22+RandomExt*16;
dogenerate.inc:644:       [*] = ;                     5 : continue;
dogenerate.inc:648:       [*] = ;               case i of
dogenerate.inc:649:       [*] = ;                  0 : dst := 14+RandomExt*6;
dogenerate.inc:650:       [*] = ;                  1 : dst := 23+RandomExt*10;
dogenerate.inc:651:       [*] = ;                  2 : dst := 39+RandomExt*9;
dogenerate.inc:652:       [*] = ;                  3 : dst := 33+RandomExt*9;
dogenerate.inc:653:       [*] = ;                  4 : continue;
dogenerate.inc:658:       [*] = ;            if (i=2) and (spcount<=4) and (gMap.settings.gen.mapsize>2) then
dogenerate.inc:660:       [*] = ;               if (gRecordGeneratorVersion<90) then
dogenerate.inc:661:       [*] = ;               begin
dogenerate.inc:663:       [*] = ;                  newpointy := pointy;
dogenerate.inc:665:       [*] = ;               begin
dogenerate.inc:669:       [*] = ;                     newpointx := -maphW+24;
dogenerate.inc:670:       [*] = ;                     newpointy := -maphH+24;
dogenerate.inc:704:       [*] = ;            var angle : Float = RandomExt*360;
dogenerate.inc:708:       [*] = ;            VectorRotateY(px, py, pz, angle);
dogenerate.inc:709:       [*] = ;            if (_misc_CheckStandPatternExt(envplHnd, name, round(newpointx+px), round(newpointy+pz), True, pRecordManagerPatternList)) then

donewgame.inc:42:       [*] = ;case gMap.settings.gen.mapsize of
donewgame.inc:43:       [*] = ;   0 : genMapSize := 320;
donewgame.inc:44:       [*] = ;   1 : genMapSize := 480;
donewgame.inc:45:       [*] = ;   2 : genMapSize := 640;
donewgame.inc:46:       [*] = ;   3 : genMapSize := 256;
```
`[O]` all lines. `[D]` consequences:
- `mapsize>2` ⇒ enum `3` ⇒ **256-cell tiny map** → bands
  `14+8R / 32+10R / 70+12R / 22+16R / continue` (`:595-601`) **plus**
  the `v>=90` corner relocation of round 2 (`:658-688` → `±(maphW-24)`,
  `±(maphH-24)` = ±104 at W=H=256).
- `mapsize<=2` (320/480/640) **and** `spcount<=4` ⇒
  `14+8R / 32+10R / [no case 2] / 70+12R / 22+16R / continue` (`:639-645`).
- `mapsize<=2` **and** `spcount>4` ⇒
  `14+6R / 23+10R / 39+9R / 33+9R / continue` (`:648-654`).
- `SetupMines` is called twice: `:985 (minround=0,maxround=1)` inside
  `SetupStartingResources` (one guaranteed round-0 deposit per start) and
  `:1770 (minround=1,maxround=0)` in the relief pass (remaining rounds).

### 4.4 Relief frequency table and family distribution (`dogenerate.inc`) — no correction

```
1621:       [*] = ;if (relieftype>4) then // random
1622:       [*] = ;relieftype := floor(RandomExt*5);
1624:       [*] = ;case relieftype of
1625:       [*] = ;   0 : begin
1626:       [*] = ;      plt := 0.000010;
1627:       [*] = ;      mnt := 0.000020;
1628:       [*] = ;      hil := 0.000075;
1629:       [*] = ;   end;
1630:       [*] = ;   1 : begin
1631:       [*] = ;      plt := 0.000020;
1632:       [*] = ;      mnt := 0.000002;
1633:       [*] = ;      hil := 0.000125;
1634:       [*] = ;   end;
1635:       [*] = ;   2 : begin
1636:       [*] = ;      plt := 0.000075;
1637:       [*] = ;      mnt := 0.000075;
1638:       [*] = ;      hil := 0.000030;
1639:       [*] = ;   end;
1640:       [*] = ;   3 : begin
1641:       [*] = ;      plt := 0.000055;
1642:       [*] = ;      mnt := 0.000120;
1643:       [*] = ;      hil := 0.000050;
1644:       [*] = ;   end;
1645:       [*] = ;   4 : begin
1646:       [*] = ;      plt := 0.000090;
1647:       [*] = ;      mnt := 0.000035;
1648:       [*] = ;      hil := 0.000035;
1649:       [*] = ;   end;
1757:       [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'mountains', mnt);
1758:       [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'plateau_big', plt/3);
1759:       [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'plain_huge', pln_huge);
1760:       [*] = ;      //_misc_SetupPatternsByType(pGenerator, envplHnd, 'ravine_medium'{'ravine_big'}, plt/3); // sand ravine
1761:       [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'ravine_big', plt/1.5);
1762:       [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'plateau', plt/3);
1763:       [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'plateau_small', plt/3);
1764:       [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'hills_dark', hil/2);
1765:       [*] = ;      _misc_SetupPatternsByType(pGenerator, envplHnd, 'hills_light', hil/2);
```
`[O]`. A02 §4 4b's table and distribution are an exact match. `relieftype`
domain is 0..4, corroborated by `[O]` `dmscript.global:238 gc_MaxReliefTypeCount = 6-1;`.

### 4.5 Decompiled blend branches (quoted from landed `reports/D05_relief_stamp.md:136-185`)

```
if (!p.HeightFieldStand) goto done_height;          // 0x756441: cmp [p+0x39],0

float base_h = bilinear_sample_world_height(world, stamp_centre);  // 0x810498

for (int r = r0; r <= r1; r++)
  for (int c = c0; c <= c1; c++)
  {
     if (occupancy[r][c] != 0) continue;            // 0x756638
     float g = p.heightGrid[r - r0][c - c0];        // pointer +0x28, float stride 4

     if (!p.ReplaceForWater)                        // 0x756601 cmp [p+0x3b],0
         g = (g - p.HeightFieldMin) * scale + p.HeightFieldMin;   // 0x756607..0x756619
     else
         g = g * scale;                             // 0x75661f..0x756625

     if (p.ReplaceForWater) {                       // 0x756645 jne
         setHeight(c, r, g + p.HeightFieldOffset);                        // 0x75664b..0x756664
     } else if (p.Replace) {                        // 0x75666e cmp [p+0x3a],0
         setHeight(c, r, base_h + g + p.HeightFieldOffset);               // 0x756674..0x756690
     } else {                                       // "Smooth" / default
         float h0 = getHeight(c, r);                // 0x7553a0 @0x7566a0
         float t  = (base_h - h0) * p.TerrainScale  // fsubr @0x7566a5, fmul [p+0x68]
                  + g + p.HeightFieldOffset;
         float h1 = getHeight(c, r);                // second read @0x7566c7
         setHeight(c, r, t + h1);                   // faddp @0x7566d2
     }
  }
```
`[O]` (D05 P6 raw assembly, independent of Ghidra's x87 naming). Smooth
post-pass, `[O]` D05 F5: `d=sqrt((x-cx)^2+(z-cz)^2)`;
`tx=round(cx+(x-cx)*(Radius-Offset)/d)`; repeat `Factor` times a 4-neighbour
mean `/4.0f` for cells inside `(u-tx)^2+(v-tz)^2 < Radius^2`. Config literals
`[O]` `pattern.lib:549563-549575`, `:337470-337493` (§3 U4/U5).

### 4.6 `envfieldd` rule (`decals.lib`, `misc.script`, `readnewp.inc`, `unit.script`)

```
decals.lib:37: section.begin {refkey=default}
decals.lib:38:    name = envfieldd
decals.lib:39:    Decal.material.libmaterialname = envfieldd
decals.lib:40:    Decal.SummerLibMaterialName = envfieldd
decals.lib:41:    Decal.WinterLibMaterialName = envfielddw
decals.lib:42:    Decal.width = 2
decals.lib:43:    Decal.height = 2

misc.script:4286: procedure _misc_PlaceFieldDecal(goHnd : Integer; scale, angle : Float);
misc.script:4288:    const decalname = 'envfieldd';
misc.script:4298:    const texscalefix = 1.3;
misc.script:4299:    w := scale*goScale*texscalefix;
misc.script:4300:    h := scale*goScale*texscalefix;
misc.script:4303:    texOff0 := -(texscalefix-1)/2;
misc.script:4304:    texOff1 := -(texscalefix-1)/2;

readnewp.inc:41:       [*] = ;   if (base=gc_basename_field) then
readnewp.inc:43:       [*] = ;      if (random>0.5) then
readnewp.inc:44:       [*] = ;      _misc_PlaceFieldDecal(gohnd, 60, 45)
readnewp.inc:46:       [*] = ;      _misc_PlaceFieldDecal(gohnd, 60, 45+180);
writenewp.inc:23:       [*] = ;   if (base=gc_basename_field) then
writenewp.inc:26:       [*] = ;      _misc_PlaceFieldDecal(gohnd, 60, 45)
writenewp.inc:28:       [*] = ;      _misc_PlaceFieldDecal(gohnd, 60, 45+180);

unit.script:6475:    const cRow = 7;
unit.script:6476:    const cCount = cRow*cRow;
unit.script:6477:    const size = 1.6981;//1.5;//_misc_PixelsToTiles(80); //90, 64
unit.script:6494:       VectorRotateY(dirX, dirY, dirZ, 45);
```
`[O]`; the two independent call sites (read/write) are the multiple-pass
cross-check. `[U]`: the 3D UV binding of the decal quad (A04 E13).

### 4.7 Tile-smooth tables (`tilesmooth_scripts.cfg:1-96`, verbatim sample via F03 §3.5)

```
   1: section.begin
   2:    TileSmoothLists : struct.begin
   6:                TileNames : struct.begin
   8:                      TileName = sandsea1
   9:                      Prob = 1
  28:                      TileName = sandsea5
  29:                      Prob = 0.7
  32:                      TileName = sandsea6
  33:                      Prob = 0.3
  54:                      TileName = rock9
  55:                      Prob = 0.0
  70:                      TileName = rock1
  71:                      Prob = 0.16
  90:                      TileName = rock4
  91:                      Prob = 0.20
```
`[O]`; full 118-active-rule enumeration in `reports/F03_gen_config.md:599-626`.

### 4.8 Winter names / constants / smoothing helper

```
terrain.presets:2:    SetName = Summer
terrain.presets:6:       [*].TileBlock = grass1
terrain.presets:135:    WaterSet = Winter
terrain.presets:138:       [*].TileBlock = grass1_winter
tiles.mat:486:    Material.Name = grass9_winter
tiles.mat:487:    Material.Texture.image = .\data\terrain\tiles\textures\winter0.dds
dmscript.global:236:    gc_MaxTerrainTypeCount = 9;
dmscript.global:238:    gc_MaxReliefTypeCount = 6-1;
dmscript.global:171:    gc_meters_to_tile = 2;
generatemap.inc:38:       [*] = ;const cSmoothTerrainUsingBitmap = True;
generatemap.inc:39:       [*] = ;const cSmoothAllMapHeight = True;
generatemap.inc:591:       [*] = ;         SmoothTerrain(realx, -realy, False, 3);
generatemap.inc:606:       [*] = ;      _misc_SmoothTerrainCustom(realx, realy, 1, 4, 0.5, 0.01, 100);
```
All `[O]`. `docs\guides\GUIDE4.md:653-654` (printed `0632-0633`) is the
R1–R6 name-only reference: "Relief gen params R1-R6 (height, radius, passage
width, furrow count/depth/phase)" — no numeric values. `[O]` for the text,
`[U]` for any numeric range.

---

## 5. Implications for the spec

1. **Stage 0 must be rewritten.** Replace A02's independent `mix64` streams
   with an explicit `[O]` rule: every donor re-seed is
   `SetRandomKey(randkey1)` (identity), with `SetRandomExtKey64(randkey0,randkey1)`
   inside `GenerateMap`, `PostProcess` and `TextureMap`. The per-stage ledger
   may still be recorded for telemetry, but it must be labelled
   `PORT APPROXIMATION` and must not claim donor independence. Engine RNG
   algorithm remains `[U]` → D02/X01.
2. **Stage 4b blend must use D05's three branches**, not A02's additive-clamp
   placeholder. `HeightFieldMax` must be exported as metadata but not applied
   in the stamp; `Min` is a pivot; `ReplaceForWater` dominates `Replace`;
   the smooth post-pass is ordered *after* the per-cell blend. Row-flip stays
   an explicit `UNVERIFIED` flag; the global-setter clamp stays `[U]`.
3. **Stage 7 mine radii must be keyed by `(version=92, mapsize enum,
   player count, round)`.** For the default 320/480/640 map with ≤4 players:
   round 0 `14+8R`, round 1 `32+10R`, round 2 **unassigned** (document the
   stale-`dst` quirk, do not invent a value), round 3 `70+12R`, round 4
   `22+16R`, further rounds skipped. For the 256-cell tiny map: round 2
   `70+12R` with a `v>=90` corner relocation to `±(maphW-24)/±(maphH-24)`.
   For >4 players on 320/480/640: `14+6R/23+10R/39+9R/33+9R`. A02's
   "small/large" labels must be swapped in the spec.
4. **Stage 9 is not a generation stage.** Move mill-field handling to the
   runtime object/decal layer: 49 field nodes, `size=1.6981` cells, 45° grid,
   `2.4017` snap, `envfieldd`/`envfielddw` 2×2 decal, `scale=60`, roll
   45°/225° by `random>0.5`, `texscalefix=1.3`. Do not implement A02's
   "guaranteed food rects in `SetupStartingResources`".
5. **Keep A02's relief table and ellipses unchanged** — both verified exact.
   Add `gc_MaxReliefTypeCount=5` and `gc_MaxTerrainTypeCount=9` as bounds.
6. **Tile smoothing** can consume F03's 118 active chains verbatim. Preserve
   the `6` vs `3` pass contradiction and the `tilesmooth.cfg` vs
   `tilesmooth_scripts.cfg` filename contradiction as documented donor
   quirks; do not "fix" them silently.
7. **Scale**: drop the donor-160 claim. Donor radii are map cells; the only
   donor scale constant is `gc_meters_to_tile=2`. A fresh module should use
   cell units directly and label any normalisation `PORT APPROXIMATION`.
8. **Omit `cstartoffset`/`cstartoffsetrnd`** from the spec (declared, unused).
9. **Do not invent R1–R6 numbers or start-spacing centimetre values.** Both
   remain `[U]` with the passes recorded in §0.1.

---

## 6. Remaining UNVERIFIED register

| # | Item | Status after this report | Why | Worker that can resolve |
|---|---|---|---|---|
| R1 | `SmoothTerrain` native `power`/`lerp` (U6) | `[U]` | Only one script call site (D2:591); no script definition; native internals not in text | D03 (mask/smooth binary study) with `native_function_study` + raw assembly |
| R2 | `RandomExt` / `SetRandomKey` key→state algorithm (U2 engine half) | `[U]` | Script side is identity re-seed; engine RNG body not in text | D02 / X01 (bulk `cossacks.exe` corpus) |
| R3 | Exact start-spacing numbers 0.7 cm / 1.5–2 cm (U10) | `[U]` | Donor uses relative ranking, no numeric literal; numbers are modder changelog | D07 binary/UI follow-up or saved-record analysis; otherwise keep `PORT APPROXIMATION` |
| R4 | R1–R6 numeric ranges (U12) | `[U]` | Exhaustive negative in donor text and decomp reports; only external manual names | D09 / X02 (`editor.exe` forms) or a human reading of the original manual |
| R5 | `row_flip` / file-row→world-y sign (U3 tail) | `[U]` | D05 P6 shows row→z but not file-row→centre sign; DPATTERN §2.2 and F02 U-F02-2 agree | D03/D05 follow-up with a donor-side struct or a replay fixture |
| R6 | Full `w×h` grids for every donor-active relief id (U13 tail) | `[U]` | 26/26 decoded bit-exact; ~50+ active members in `generator.cfg:446-754` | F01/A03 using DPATTERN §7 recipe; min/max bit-exact gate |
| R7 | Global `setHeight` clamp (`sub_0059b934`) and `HeightFieldMax` other consumers | `[U]` | D05 R4/Q3: outside the studied stamp function | D05 follow-up / D04 |
| R8 | `tilesmooth` consumer activity, face promotion, decal UV | `[U]` | All `smoothtiles.inc` lines `;`-prefixed; F05 §9 and A04 E13 | D08 runtime/binary trace; no donor execution allowed in this wave |
| R9 | Any donor GPU visual parity | `[U]` | No donor A/B frame | A05 capture harness + owner verdict |

---

## 7. Open questions

1. **[O] vs [O] contradiction resolved — but confirm intent:** `mapsize>2`
   is the 256-cell map by `donewgame.inc:46`, while the donor comment at
   `dogenerate.inc:571` calls it `// tiny` (consistent) and D07 §3.4's worked
   example uses 320 cells (inconsistent). COORD should adopt the enum and
   record D07's example as a typo before the spec is frozen.
2. **[D]** If the 320/480/640, ≤4-player band's ring-2 `dst` is stale rather
   than zero-initialised, the port must choose and document a policy. This is
   a real authoring quirk at `dogenerate.inc:639-645`, not a decoding error.
3. **[U]** Does `v>=90` corner relocation apply to a 320-cell map at all?
   Literally it requires `mapsize>2`, so no — but D07's example implies the
   opposite. No donor execution was permitted; resolve with a saved replay
   record or a binary trace.
4. **[I]** The engine LCG `x=x*0x8088405+1` found by D05 at `0x403a28` is
   used by the random-scale path. Is it also `RandomExt`? D02 must confirm
   before any numeric replay claim.
5. **[U]** With `HeightFieldMax` unused in the stamp, what explains
   `k_ravine_4` min `−3.06597` being below the baked `−2.964` ceiling?
   Probably the global setter (R7), not the stamp.
6. **[U]** Are `PatternMaskStand` / `PatternMaskReverceStand` consumed for
   any active skirmish pattern? D05 U6 leaves the occupancy-byte inversion
   open; A02's prefill rule assumes a fixed polarity.
7. **[U]** Do the four non-`.tga` `.removed` files in `mediterranean`
   reflect masks withdrawn from rotation by the authors? The selector glob
   excludes them, but their presence is a donor-side fact worth recording in
   the mask manifest.

---

## 8. Closing

**10 RESOLVED, 3 PARTIAL, 3 STILL UNVERIFIED** across A02 §8's 16 items.
The dominant corrections to A02 are: identity re-seeding (no `mix64`),
decompiled three-branch blend math (no additive-clamp placeholder),
`gDataVersion=92`, the swapped mine-band labels with the `mapsize` enum
correction, and the runtime/decal nature of mill fields. The relief frequency
table and the three keep-clear ellipses were re-read verbatim and need no
change. Every remaining `[U]` is registered in §6 with the specific worker
that can settle it. One report written; no code, shader, config, asset, test,
donor, queue or git edit; no donor binary run or copied; **no donor visual
parity claim**.
