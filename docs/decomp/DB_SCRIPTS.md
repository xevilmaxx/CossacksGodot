# DB — Donor text-script / config truth and the port's gaps

**Lane:** §5a Decompilation (agent DB). **Donor:** `C:\Games\Cossacks 3` (PRIVATE USE ONLY — never copy donor files into the repo, never run donor executables). **Method:** read-only `core_text_read` in bounded pages plus read-only directory listings; the port (`docs/guides/GUIDE4.md`, `app/scripts/data.gd`, `app/scripts/game.gd`) was read only. No Godot, game code, donor file or other repo file was changed by this agent.

Findings recorded in the shared session: **fnd_12, fnd_22, fnd_23, fnd_24, fnd_25, fnd_26**.

## 1. File table

Paths are relative to `C:\Games\Cossacks 3\data\`. "Lines read" is `core_text_read` offset range; "total" is the file's reported `total_lines`.

| path | role | lines read (of total) | evidence id(s) |
|---|---|---|---|
| `game/var/generator.cfg` | `TerrainTypes` + `TerrainTypesDLC5` + 70 weighted `Patterns` families | 0–2366 (2367, complete) | `ev_a2c1ea36d1b9ae6291daebfece8116360ce70a7c5d4e497bbfae9406993fd17f`, `ev_56bf069fe35f727f42879e6286a64ce2b58936369f6818baffd8a1c7cc6d3b8a`, `ev_039ade7462bea574789ce4617a465d5350a546d9cc768c64197f3fb0bcc5682f`, `ev_9d5c3373b6536dfd8a3ea220137ad3d2e2c5cd70eeb6ed1bfddcd99bbf564f82`, `ev_ab4e90a4b48d41eb1e70bf16cd08b09c0a5064a51dd9122ef2abb6ad3fd29745`, `ev_dc829d28cac0bfe05fca12630f1b55821dd06a610387c59831407969264a6200`, `ev_ee0d5f4fbaa45f269796f84c489e5969b66a791d5c6a792517d20dcb612da9d8` |
| `game/var/hotkeys.cfg` | key → action bindings, 243 lines | 0–242 (243, complete) | `ev_e350e5343dc29b1559a50058fc03717713697e925c727d517757b8db70056cf1` |
| `game/var/random.cfg` | RNG field | 0–2 (3, complete) | `ev_f490ebb991f41f348483c8ec7e67fa12b58f19a37c21f6cd28807d2c879a94bd` |
| `game/var/units.cfg` | unit id / hint / icon records | 0–13 (14, complete) | `ev_f832c2f29caefdac099894abd9c0404928841daa81025def793991eb6441f118` |
| `game/var/formations.cfg` | 149 formations: masks + symmetry + bonus fields | 0–299, 808–877 (2307 total) | `ev_2f2f15d9978753481d7bc5524ba311bcedd404b14be13db732763876a120975c`, `ev_24a1cc1aed9646c2f96f6b4840f8a65eea72844486f61b443aeb6b5be2de8cd4` |
| `game/var/envscales.cfg` | per-object `scale` / `minscale` / `maxscale` | 0–199 (869 total) | `ev_2c4d3cf46caa79adf1fc5e5ddb90965f809cf3f6a7093d617d27bcc85fb3495c` |
| `game/var/startingsettings.cfg` | `startid` 0–9, `addresources`, country masks/legends | 0–119 (3424 total) | `ev_6b77a40231bc73767eb113d8fb47091d24bf21c87dfb6e1bf24bf044c73928c3` |
| `scripts/common.inc/dogenerate.inc` | map-generation stages, constants, version gates | 0–799, 960–1219, 1290–1739, 1900–2102 (2103 total) | `ev_0639ec88adf0b10706411c1dcd965a5e6c56f531fca20f0c10a37e13e8ed8b01`, `ev_98f8c05d5a2c73580d1257b416a5fec048f16f9fa2f0bd1f02d94eb7c7c80d7f`, `ev_c7d983f3b81252b8bf4f816d1d14293c1d3cc838f5eb7a9c0170ba8ddbce85e7`, `ev_e72294ce3edb761f849f5e900d32a0951d094917eec607fcfa254f99da452471`, `ev_f7f8bad9ab99d48bfa7e78c66e92965444423072af19486d5f85c3df22f9569e`, `ev_16e3cc42cc5ba9a0e0d3497312ec0397728e4757317053dab036befae593f79f`, `ev_bb8041b65d295d042902dab88f937cc45a997e7aebc2efbb8b5406095263c3fd` |
| `scripts/common.inc/initmapgen.inc` | init → ExecuteState('DoGenerate'), topology | 0–288 (289, complete) | `ev_e00fea8c4b9b68117bca04a9d8aa229b6a9bd4dbed632882b730ee97ab55d170` |
| `scripts/common.inc/dogeneratemissionmap.inc` | mission-map stub (BoolRegister0/ExecuteState) | 0–8 (9, complete) | `ev_81649d69eca1820766da26af85dcb2bef5972439e97e23dfefa2d0f84ff50cc4` |
| `scripts/common.inc/oninit.inc` | init stub | 0–4 (5, complete) | `ev_e952748499247e9267b24575f6dc5c25bc00d8d156a9f65d36acd7717c232c68` |
| `locale/<lang>/*.txt,.lng` | 12 language dirs (`cs,de,en,es,fr,it,pl,po,ru,tu,uk,needloc`), mission text | directory listing only (not read here) | see `DC_FORMATS.md` / `DD_MAPS.md` and fnd_21 |
| `data/objects`, `data/actors` | `.prop`/`.actor`/`.osm`/`.oss` prop families | directory listing only (not read here) | `DC_FORMATS.md` |

Also present but not read in this pass: `generatemap.inc` (51,794 B), `texturemap.inc` (48,954 B), `postprocess.inc`, `generatemap.inc` family, `scripts/lib/*.script` (29 files, up to 560 KB). Their key constants are already quoted in `GUIDE4.md` L2115–2147.

## 2. Donor truth (quoted)

### 2.1 `generator.cfg` — terrain types and weighted patterns

```
TerrainTypes: 0.Land  .\data\gen\terrainmasks\nowater2
              1.Mediterranean   2.Peninsulas   3.Islands
              4.Continents      5.Continent
TerrainTypesDLC5: 0..5 as above + 6.Coastal 7.Lakes 8.Rivers
                  (paths under .\data\gen\terrainmasks.dlc5\)
Patterns: mng { mng4 Freq=0; mng_1..mng_5 Freq=1 }
          plain_small { k_small_plain_18 Freq=0.25; _24/_25/_26/_29/_30 Freq=0.5625; ... =1 }
          plain_medium { _37/_38 Freq=6.25; _40/_44 Freq=5.0625; ... =1 }
          desert_tiles { d_tls_1 Freq=1000; d_tls_2 Freq=0; d_tls_3 Freq=1000; d_tls_4 Freq=100 }
```
~70 named families cover `plateau*`, `mountains`, `hills_dark/light`, `ravine*`, `stoneforests(_old)`, `stones`, `forests_pinefir/spruce/pine/mixed/leaf_*`, `swamp_*`, `lake_*`, `pump`, `christmas`, `decor(_big)`, `tiles`, and the whole `desert_*` set. **Freq is a per-pattern selection weight, not a probability.**

### 2.2 `dogenerate.inc` — stage order and constants

Stage order (from the main body, lines 400–2102):

1. `ClearMapMaskAndObjects` — `const cMapSize = 640`, `ResetPatternMap`, destroy all player objects.
2. `SetupTiledPatterns('tiles'|'desert_tiles')` — `const cSize = 25` grid of tile cracks (`tls_1..4`).
3. `SetRandomKey(gMap.settings.gen.randkey1)` → `ExecuteState('GenerateMap')` with the `TerrainTypes[terraintype].path` (`BoolRegister0:=True; StringRegister0:=path`).
4. Shore mask: `const cWaterShoreHeight = -0.1`; any cell with `GetHeightData < -0.1` is added to `gPatternMask`.
5. Start positions: `const cstartoffset = 60; cstartoffsetrnd = 25`; `arrStartPos[0..7]`; three keep-clear ellipses `cCircle1Mask 5x7`, `cCircle2Mask 12x15`, `cCircle3Mask 22x18`; `_misc_FillPatternMaskMapBorder(3)`.
6. `RandomStartingPoints(spcount, minesdensity)` with three elliptical resource rings.
7. Relief table `relieftype 0..4`:

   | relieftype | plt | mnt | hil |
   |---|---|---|---|
   | 0 | 0.000010 | 0.000020 | 0.000075 |
   | 1 | 0.000020 | 0.000002 | 0.000125 |
   | 2 | 0.000075 | 0.000075 | 0.000030 |
   | 3 | 0.000055 | 0.000120 | 0.000050 |
   | 4 | 0.000090 | 0.000035 | 0.000035 |

8. Global pattern passes: `frs_big=0.0009`, `frs_mid=0.0009`, `frs_small=0.00054`, `dcr=0.0005`, `stn1=0.00016`, `stn2=0.00012`; `plain=0.0001/2`, `pln_small=plain*6*probsmall`, `pln_mid=plain*2*probmid`, `pln_large=plain*problarge`, `pln_huge=plain*probhuge`; size modifier `640/((mapW+mapH)/2)` when map != 640. Chosen families: `mountains`, `plateau_big`, `plain_huge`, `ravine_big`, `plateau(_small)`, `hills_dark/light`, `forests_pinefir/spruce/pine/mixed/leaf_*`, `stones`, `swamp_*`, `lake_*`, `pump`, `christmas`, `plain_small` (all `desert_*` equivalents when `season=3`).
9. `SetupMines` — `minesdensity 0/1/2 -> rounds 3/4/5`, `trycount=256`, resource strings `mng/mni/mnc` (or `desert_*`), distances by `gRecordGeneratorVersion` (<70, <75, <77, <80, <90) e.g. `14+RandomExt*8`, `32+RandomExt*10`, `70+RandomExt*12`, `22+RandomExt*16`.
10. `SetupStartingResources` — `stoneforests` + `stones` in the `cCircle2` ring.
11. Units, preload, teams, peace mode, `FillOwnerMap`, border objects, shore collision, color tables (`winter` index 6/PHDR 1; `season=3` index 7; else 0/PHDR 0).

**Determinism:** `SetRandomKey(gMap.settings.gen.randkey1)` is re-issued at lines 1100, 1161, 1177, 1213, 1538, 1616, 1772, 1909, 1927 — once *before each stage*, so each stage consumes its own fresh stream. Version gates `gRecordGeneratorVersion < 53/61/63/68/70/75/77/80/89/91` alter behaviour throughout `dogenerate.inc` and `initmapgen.inc`.

### 2.3 `initmapgen.inc` + `startingsettings.cfg`

```
case gMap.settings.gen.resourcestart of
  0: _res_SetResToPlayerByIndex(i, j, 1000);
  1: ... 4000;  2: ... 5000;  else: ... 1000000;   // for j := 0 to gc_ResCount-1

startid 0..9: default, armysmall, armymedium, armylarge, peasantslot(4),
              differentnations(5), towers(6), cannons(7),
              cannonsandhowitzers(8), barrack18(9)
addresources { food, wood, stone, gold, iron, coal }
dataversionmin/max; countries[].allowedcountries[];
legends[].{key, role, countrysid, basename}; mask[] rows
  role>0 -> _country_GetMemberIDByAIRole(countryid, role)
  else   -> _unit_ConvertObjSIDToID(countryid, basename)
```
`CreateUniqueStartingUnits` (dogenerate.inc L270+) parses these masks with a 16-slot legend (`arrLegendKeyIndexes[0..15]`) and `_misc_FillPatternMaskCircle(x,z,r)` with `r=5` for buildings, `r=1` for units.

### 2.4 `formations.cfg`

149 entries; 137 have `symmetry = 1`. Example families: `LINE3`–`LINE10` (`*..*..*`), `LINE3PUS`–`LINE19PUS`, `LINE15/36/72/120/196/400`, `SQUARE*`, `KARE*`, `TRI*`, `PRUS*`, `SHER*`, `none`. **43 entries carry non-zero bonuses:**

```
id = LINE15          (same for LINE36, LINE72, LINE120, LINE196,
                       SQUARE15/36/72/120/196/400, KARE15/36/72/120/196/400,
                       TRI*, PRUS*, SHER*)
   symmetry = 1
   bonusdamage = 2
   bonusshield = 2
   bonusdamagehold = 7
   bonusshieldhold = 7
```

This directly contradicts `GUIDE4.md` A04 ("bonusdamage 0 (masks only; port bonuses wiki)").

### 2.5 `hotkeys.cfg`

```
build: C=cent, H=hou, L=bla, B=bar, E=aca, S=sta, R=art, D=dip, K=ba2,
       J=tem, I=mil, O=sto, M=mar, N=gol/iro/coa, P=por, T=tow
unit:  A=attack, S=standground, C=nostandground, F=squad|fill,
       G=guard/cancelguard, E/D=enable|disableattack, R=attackpoint,
       J/K/L=squad|rank/column/square, Ctrl+S=stop, U=unloadall
interface: Alt+M=minimap, Q=viewcollision,
       Ctrl+Alt+A=militaryunits (AlternativeKey Ctrl+Shift+A),
       Ctrl+A=allunits, Ctrl+Q=allships, Ctrl+B=allbuildings,
       Ctrl+P=idlepeasants (AlternativeKey `), Ctrl+`=allpeasants,
       Ctrl+M=idlemines, Z/Shift+Z/Ctrl+Shift+Z/Ctrl+Z=same-type selects
main menu: C=bcampaign, R=brandommap, S=bsettings, E=beditor,
       L=bloadgame, X=bexit, M=bmultiplayer (all Up=True)
```

`random.cfg` is only `field = fax`; `units.cfg` is a 2-record stub (`ID=0 None`, `ID=1 Pikeman 17th century`).

### 2.6 `envscales.cfg`

`field scale=0.033`, mines `minecoal/minegold/mineiron scale=0.3152`, `stones scale=0.329 minscale=0.85 maxscale=1.15`, `smallstones 0.25`, `fir 0.5` (all `0.85–1.15`). This is the source of the per-object scale jitter applied in dogenerate.inc's "fix environment object scales" loop.

## 3. Gap table vs the port

| # | donor truth | port today | severity | evidence / port ref |
|---|---|---|---|---|
| G1 | `formations.cfg` 43 entries with `bonusdamage=2`, `bonusshield=2`, `bonusdamagehold=7`, `bonusshieldhold=7`; exact 149 formation IDs + masks | `Data.FORMATIONS` has 5 shapes (cols/rows multipliers only); `game.gd` `_formation_atk/_def` use wiki values (hold melee 5/9, def hold 4/9, normal 1/2/3). `GUIDE4` A04 asserts "bonusdamage 0". | **High** — combat math diverges from donor | `ev_2f2f15d9…`, `ev_24a1cc1a…`; `data.gd` L213–221, `game.gd` L1716–1763, `GUIDE4.md` L1106 |
| G2 | `hotkeys.cfg` 243 lines of concrete bindings | `Data.HOTKEYS = {}` (empty); no `InputEventKey` / key handling found in `app/**/*.gd` | **High** — no keyboard parity | `ev_e350e534…`; `data.gd` L163 |
| G3 | `SetRandomKey(randkey1)` before **every** generation stage + version gates 53..91 | one `rng.seed = Data.RANDOM_SEED` at setup (`game.gd` L114/L213), `brng.seed` +7 (L885), `C3MapGen` `r.seed = seed^type.hash()+104729`; no stage reseed, no generator version | **High** — stage streams coupled; replay/old-map fidelity impossible | `ev_c7d983f3…`, `ev_f7f8bad9…`, `ev_16e3cc42…`, `ev_e00fea8c…`; `game.gd` L114, L213, L536, L885, `mapgen.gd` L48 |
| G4 | `generator.cfg` 6 base **paths** + 9 DLC5 types + ~70 `Freq` weights | `Data.MAP_TYPES` 6 names with hand-set `water_frac` 0.5–2.2, no path, no DLC5 entries, no weights | **Medium** — mask choice approximate; DLC5 maps unreachable | `ev_a2c1ea36…`, `ev_ee0d5f4f…`; `data.gd` L191–200, `GUIDE4.md` L1119, L737–757 |
| G5 | `startingsettings.cfg` startid 0–9, 6-resource `addresources`, country masks with role/basename legends + version gates | `Data.START_OPTIONS` 6 entries with invented `army_mult/food/towers/cannons`; missing peasantslot(4), differentnations(5), cannonsandhowitzers(8), barrack18(9), wood/stone/gold/iron/coal, country masks | **Medium** — starting army/resource setup only approximate | `ev_e00fea8c…`, `ev_6b77a402…`; `data.gd` L202–211, `game.gd` L536 |
| G6 | `envscales.cfg` per-object scales/jitter, 869 lines | port has generic prop scales; no per-donor-object table | **Low** — visual fidelity only | `ev_2c4d3cf4…`; `GUIDE4.md` L1103 |
| G7 | `relief table`, `frs/stn/dcr`, 25×25 tile cracks, 640 map, shore -0.1 | already quoted in `GUIDE4.md` L2124–2135 and partly wired in `C3MapGen`; port still uses `MAP_W/H=160` and synthesized blobs at that size | **Low / tracked** — no new ticket; verify at 512+ | `ev_98f8c05d…`, `ev_f7f8bad9…`; `game.gd` L520–537 |

## 4. Worker-ticket estimate

| ticket | gap | scope | estimate |
|---|---|---|---|
| DB-01 | G1 | Import 149 formation IDs + masks as data; replace `_formation_atk/_def` with `bonusdamage/bonusshield/bonusdamagehold/bonusshieldhold` lookup; correct GUIDE4 A04; self-test 43 nonzero cases | **M — 6–8 h** |
| DB-02 | G2 | Parse `hotkeys.cfg` into `Data.HOTKEYS` (action→key, AlternativeKey, Up/Repeat), wire `InputEventKey` to existing build/select/unit actions; preserve ctrl/alt/shift combos | **M — 8–12 h** |
| DB-03 | G3 | Add `generator_version` setting; reseed `rng` with `randkey1` before terrain/starts/relief/patterns/units/finish; implement version gates for start placement and terrain table; replay fixture | **L — 16–24 h** |
| DB-04 | G4 | Extend `MAP_TYPES` with donor paths + 9 DLC5 types; port Freq-weighted pattern selection into `C3PatternGen` (weights not probabilities) | **M — 8–12 h** |
| DB-05 | G5 | Port full `startingsettings.cfg` startid 0–9 with 6-resource `addresources`, dataversion gates and country-mask legend parsing into starting-unit setup | **M — 8–12 h** |
| DB-06 | G6 | Import `envscales.cfg` table and apply scale/min/max to generated env objects | **S — 4–6 h** |

**Total ≈ 50–74 h** of worker time (2 tickets M can run in parallel; DB-03 is the critical path for replay fidelity). G7 is already covered by the existing L3/L6 work and needs no ticket.

## 5. Verification limits / unknowns

- `dogenerate.inc` lines 800–959 and 1220–1289 were not paged; the grep index shows they contain `CreateStartPoint` tail, `GetRandom`, `GenerateTeamStartingPoints`, `SetupCollisionInertiaObjects` and `FillOwnerMap` — all covered by the surrounding pages.
- `data/game/var/battles.cfg`, `campaigns.cfg`, `objcustom.cfg` (1.5 MB), `wallcustom.cfg` were located but not read; they belong to other lanes (missions/props).
- Donor `data/locale` and `data/objects`/`data/actors` were only enumerated, not parsed; string-table semantics are not established here.
- All conclusions about the port are read-only observations of files as they exist today; no port code was executed.
