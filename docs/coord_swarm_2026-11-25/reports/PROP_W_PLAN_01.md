---
id: PROP-W-PLAN-01
task: "Plan the missing donor winter prop-material (`w`) art gap"
date: 2026-11-25
status: DELIVERED__PLAN_ONLY__READ_ONLY_DONOR__NO_CODE_EDIT__NO_ASSET_COPY__NO_RUNNER_JOB
scope: "Read-only planning. This report is the ONLY repository file written. No .gd/.gdshader/.json/.png/.dds/config/test/asset was edited or copied; no donor file was executed, unpacked or copied; no Godot runner job; no test weakened."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor: "C:\\Games\\Cossacks 3 (READ-ONLY; Python 3.14 bytes/latin-1; never executed, unpacked or copied)"
output: "docs/coord_swarm_2026-11-25/reports/PROP_W_PLAN_01.md"
verification_passes: 2
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROXIMATION]
visual_parity_claim: false
---

# PROP-W-PLAN-01 — winter prop-material (`w`) art gap: ordered plan

> **Scope guard.** This is a plan, not an implementation. The donor was opened only with
> `open(path,'rb').read().decode('latin-1')` and raw DDS header reads; port files were read
> only. Temporary Python scripts lived in `%TEMP%\opencode\`, never in the repo. All line
> numbers are 1-based and were re-read this pass. **No visual parity is claimed.**

## 0. Sources

| # | Source | Role / label |
|---|---|---|
| S1 | `docs/coord_swarm_2026-11-25/reports/DSEASON_01_season_visuals.md:98-107,159-182,206-213` | donor `w` prop convention, art examples, gap rank 2, open Q6 (read this pass) |
| S2 | `docs/coord_swarm_2026-11-25/reports/DENV_01_environment.md:474-495,492-494` | `_winter` (tile) vs `w` (prop) suffixes; `miscext.script` swap chain (read this pass) |
| S3 | `docs/coord_swarm_2026-11-25/reports/SEASON_PLAN_01.md:125,178-193,202-217` | SP-7 PROP-W ticket, B1b missing-w-art blocker, B8 co-ownership (read this pass) |
| S4 | `docs/coord_swarm_2026-11-25/decomp/DEC_05_terrain_formats.md:87-102,217-239` | donor `terrainmesh{1..4}.dds`/`[w].dds` DXT5 relief albedo; `.prop` summer→winter names (read this pass) |
| S5 | **Fresh donor read**: `C:\Games\Cossacks 3\data\materials\env\env.mat:815-1551` (whole `// envwinter` block, 1552 lines) | 79 exact `w` material names + image bindings (observed, 2 passes) |
| S6 | **Fresh donor read**: `data\materials\env\*.dds` (171 file names; 128-byte headers on the 72 w-named files) | presence, size/format of winter art (observed, 2 passes) |
| S7 | **Fresh donor read**: `data\objects\env\*.prop` (all 353 files with season lines; `fir.prop:33-43`, `field.prop:58-76`, `terrainmesh1.prop:16-18`) | 321 props reference 74/79 `w` names (observed) |
| S8 | **Fresh port read**: `variant3d/assets/**` (8,210 files) via two independent walkers | exact `w`/winter art census (observed, 2 passes) |
| S9 | **Fresh port read**: `variant3d/assets/models/manifest.json` (172 models), `variant3d/scripts/world3d_entities.gd:86,244-245,311-345,502-515,1514-1528`, `variant3d/scripts/world3d_terrain.gd:267,392-430`, `variant3d/scripts/data.gd:199` | current hook seams and season key (observed) |
| S10 | `reports/DECOR_01_implementation.md:5-9,33-50,118-119`, `reports/MOTION_ANIM_01.md:7-14,66-71`, `PLAN_IMPLEMENTATION.md:34` | `world3d_entities.gd` co-ownership and preserved blocks (read this pass) |
| S11 | `variant3d/tools/` file list (read-only) | existing conversion/build tools named only (`convert_skins.py`, `copy_assets.py`, `build_winter_atlas.py`, `godot_runner.py`); **no tool run** |

**Labels.** `observed` = literal bytes/lines/files read this pass, verified twice where stated;
`derived` = deterministic count/set arithmetic over observed data; `inferred` = best reading with
a caveat; `UNVERIFIED` = not provable from readable data; `PORT APPROXIMATION` = port-chosen
value/transport explicitly not claimed as donor parity.

---

## 1. Donor material truth — exact `w` table

Path prefix `D:\` = `C:\Games\Cossacks 3\data\`. Every texture below is
`D:\materials\env\<file>` unless the note says otherwise. `env.mat:815` is the single
`// envwinter` marker; the 79 definitions run to `:1551`. All rows **observed** twice.

### 1.1 Frosted conifers and ground cover

| Material | Source texture | `env.mat` line |
|---|---|---:|
| `fir1w` | `fir1w.dds` | `:817-818` |
| `fir2w` | `fir2w.dds` | `:827-828` |
| `fir3w` | `fir3w.dds` | `:837-838` |
| `firsmall1w` | `firsmall1w.dds` | `:1045-1046` |
| `firsmall2w` | `firsmall2w.dds` | `:1049-1050` |
| `firsmall3w` | `firsmall3w.dds` | `:1053-1054` |
| `pine1w` | `pine1w.dds` | `:1057-1058` |
| `pine2w` | `pine2w.dds` | `:1061-1062` |
| `pine3w` | `pine3w.dds` | `:1065-1066` |
| `pinesmall1w` | `pinesmall1w.dds` | `:1069-1070` |
| `pinesmall2w` | `pinesmall2w.dds` | `:1073-1074` |
| `pinesmall3w` | `pinesmall3w.dds` | `:1077-1078` |
| `pinebroken1w` | `pinebroken1w.dds` | `:1081-1082` |
| `pinebrokenmoss1w` | `pinebrokenmoss1w.dds` | `:1085-1086` |
| `spruce1w` | `spruce1w.dds` | `:1089-1090` |
| `spruce2w` | `spruce2w.dds` | `:1093-1094` |
| `spruce3w` | `spruce3w.dds` | `:1097-1098` |
| `pinedry1w` | `pinedry1w.dds` | `:1101-1102` |
| `pinedryswamp1w` | `pinedryswamp1w.dds` | `:1105-1106` |
| `pinestumpw` | `pinestump.dds` (note: no `w` in DDS stem) | `:1253-1254` |
| `fernw` | `fernw.dds` | `:1157-1158` |
| `bushesw` | `bushesw.dds` | `:1161-1162` |
| `drybushesw` | `drybushesw.dds` | `:1189-1190` |
| `ivyw` | `ivyw.dds` | `:1041-1042` |
| `grassforestw` | `grassforestw.dds` | `:1390-1391` |
| `grassleafforestw` | `grassleafforestw.dds` | `:1406-1407` |
| `plantsatlasw` | `plantsatlasw.dds` | `:1349-1350` |
| `plantsyellowatlasw` | `plantsyellowatlasw.dds` | `:1365-1366` |
| `plantswateratlasw` | `plantswateratlasw.dds` | `:1381-1382` |
| `plantswateratlastransparencyw` | **alias** → `plantswateratlasw.dds` | `:1385-1386` |

### 1.2 Broadleaf / palms / dry trees / mines

| Material | Source texture | `env.mat` line |
|---|---|---:|
| `oak1w` | `oak1w.dds` | `:1177-1178` |
| `oak2w` | `oak2w.dds` | `:1181-1182` |
| `oak3w` | `oak3w.dds` | `:1185-1186` |
| `burch1w` | `burch1w.dds` | `:1257-1258` |
| `burch2w` | `burch2w.dds` | `:1277-1278` |
| `burch3w` | `burch3w.dds` | `:1297-1298` |
| `burchstumpw` | `burchstumpw.dds` | `:1317-1318` |
| `leaftree1w` | `leaftree1w.dds` | `:1321-1322` |
| `leaftree2w` | `leaftree2w.dds` | `:1325-1326` |
| `leaftree3w` | `leaftree3w.dds` | `:1329-1330` |
| `drytree1w` | `drytree1w.dds` | `:1109-1110` |
| `drytree2w` | `drytree2w.dds` | `:1125-1126` |
| `drytree3w` | `drytree3w.dds` | `:1141-1142` |
| `palm1w` | `palm1w.dds` | `:1333-1334` |
| `palm2w` | `palm2w.dds` | `:1337-1338` |
| `palm3w` | `palm3w.dds` | `:1341-1342` |
| `minegoldw` | `minegoldw.dds` | `:1193-1194` |
| `mineironw` | `mineironw.dds` | `:1213-1214` |
| `minecoalw` | `minecoalw.dds` | `:1233-1234` |

`leaftree1w..3w` art is defined but donor winter **destroys leaftree objects**
(`dogenerate.inc:1975-1982`; `miscext.script:1568-1576` via S1/S2) — do not add leaftrees to a
winter port scene just because the art exists. **observed + inferred**.

### 1.3 Stones / relief / fields / building children / desert aliases

| Material | Source texture | `env.mat` line |
|---|---|---:|
| `stonesw` | `stonesw.dds` | `:841-842` |
| `smallstonesw` | `smallstonesw.dds` | `:851-852` |
| `rocksw` | `rocksw.dds` | `:861-862` |
| `landstonew` | `landstonew.dds` | `:1345-1346` |
| `rocksea1w` | `rocksea1w.dds` | `:1456-1457` |
| `rocksea2w` | `rocksea2w.dds` | `:1460-1461` |
| `rocksea3w` | `rocksea3w.dds` | `:1464-1465` |
| `stonesseaw` | `stonesseaw.dds` | `:1468-1469` |
| `smallstonesseaw` | `smallstonesseaw.dds` | `:1478-1479` |
| `terrainmesh1w` | `terrainmesh1w.dds` | `:1416-1417` |
| `terrainmesh2w` | `terrainmesh2w.dds` | `:1420-1421` |
| `terrainmesh3w` | `terrainmesh3w.dds` | `:1424-1425` |
| `terrainmesh4w` | `terrainmesh4w.dds` | `:1428-1429` |
| `detailw` | `detailw.dds` | `:1452-1453` |
| `fieldw` | `fieldw.dds` | `:865-866` |
| `field1w` | `field1w.dds` | `:887-888` |
| `field2w` | `field2w.dds` | `:909-910` |
| `field3w` | `field3w.dds` | `:931-932` |
| `field4w` | `field4w.dds` | `:953-954` |
| `field5w` | `field5w.dds` | `:975-976` |
| `field6w` | `field6w.dds` | `:997-998` |
| `field7w` | `field7w.dds` | `:1019-1020` |
| `desert1w` | **alias** → `desert1.dds` | `:1510-1511` |
| `desert2w` | **alias** → `desert2.dds` | `:1514-1515` |
| `desert3w` | **alias** → `desert3.dds` | `:1518-1519` |
| `desert4w` | **alias** → `desert4.dds` | `:1522-1523` |
| `desert5w` | **alias** → `desert5.dds` | `:1526-1527` |
| `stonesdesertw` | `stonesdesertw.dds` | `:1530-1531` |
| `smallstonesdesertw` | `smallstonesdesertw.dds` | `:1540-1541` |
| `desertstumpw` | **alias** → `desertstump.dds` | `:1550-1551` |

**Counts, verified twice (pass 1 line scanner; pass 2 whole-file regex):**
`79` distinct `Material.Name` values ending in `w`; `72` have a same-named `.dds` in
`D:\materials\env\`; `7` are aliases (6 reuse un-suffixed DDS: `desert1..5`, `desertstump`;
1 reuses `plantswateratlasw.dds`). DDS headers: 72 files, **91,198,648 bytes**; formats
DXT5×59 / DXT1×13 across 11 dimension classes (mostly 1024²×21, 512²×24, 2048²×11) —
**observed**. Derived full RGBA8 decode footprint ≈ **298.6 MiB** if all 72 were converted;
disk PNG size is **UNVERIFIED** (no conversion performed).

**Prop consumption:** `321` of the donor `.prop` files reference `74` of the 79 `w` names;
the 5 never referenced are `field5w`, `field6w`, `field7w`, `rocksea2w`, `rocksea3w`
(**observed**, whole-directory token scan). Representative sites: `fir.prop:33-43`
(`fir1w/fir2w/fir3w`), `field.prop:58-76` (`field1w..4w`, `fieldw`), `grass.prop:36-42`
(`plantsatlasw`), `terrainmesh1.prop:16-18` (`terrainmesh1w`). Material emission also
differs, e.g. `fieldw` emission `(0.9098,0.8549,0.7647)` at `env.mat:873-884` and
`field1w` grey `0.78125` at `:895-906`; raw texture means are therefore **not** screen
colours (**inferred**, S1 §2.2).

---

## 2. Port inventory — what `w`/winter art actually exists

Two independent walkers of `variant3d/assets/**`: **8,210 files** (pass 1) and a second
full walk (pass 2). Counts below agree across both passes unless labelled otherwise.

| Port path | Count | Names / shape | Label |
|---|---:|---|---|
| `terrain/blocks/winter*.png` | **27** | `winter0.png … winter26.png` (no gaps) + 27 `.import` = 54 files | observed ×2 |
| `terrain/atlas/*winter*` | **4** | `winter_aliases.json`, `tile_index_atlas_winter.manifest.json`, `tile_index_atlas_winter.png`, `tile_index_atlas_winter.png.import` | observed ×2 |
| `terrain/blocks/desert*.png` | **12** | `desert1.png … desert12.png` | observed ×2 |
| `terrain/deco_png/envfielddw.png` | **1** | winter field decal (path consumed as stats only at `world3d_entities.gd:245,332`) | observed ×2 |
| `terrain/decals_dds/*_w.dds` | **226** | 226 stems, listed in §2.2; 462 `.dds` files total in that directory | observed ×2 |
| `terrain/decals_png/*_w.png` | **226** | same 226 stems; 462 `.png` total | observed ×2 |
| `models/tex/*.png` | **346** | `tree_fir.png`, `tree_spruce1..4.png`, `tree_pine*.png`, `rock_*.png`, `plantain1..3.png`, `flower1..3.png`, `fern1..4.png`, `bush1..4.png`, `field.png`, `mine_{gold,iron,coal}.png`, … — **summer** donor albedo | observed ×2 |
| `models/tex` stems ending in literal `w` | **0** | the only `*_w`-lookalikes in `models/**` are `tow.png`/`tow.obj`/`tow.mtl` and `alg_tow.png` (tower sprite, not winter) | observed ×2 |
| exact stem == any of the 79 donor `w` names | **0** | also 0 case-insensitive and 0 substring matches anywhere under `variant3d/assets/**` | observed ×2 |

### 2.1 "Present under different names" — what this does and does not buy us

| Case | Port evidence | Reading | Label |
|---|---|---|---|
| 6 base-name files | `terrain/blocks/desert1..5.png`, `models/tex/field.png` | These are the *un-suffixed donor art* already converted for tiles/field. Donor `desert1w..5w` and `desertstumpw` explicitly alias those same un-suffixed DDS (`env.mat:1510-1527,1550-1551`), so no *new donor art* is needed for those 6 materials — but the port files are bound as terrain tiles/field albedo, **not** as prop materials. | observed + inferred |
| 31 donor `w` names ↔ 88 summer sid PNGs | `manifest.json` maps donor `fir1.dds → tree_fir.png`, `stones.dds → stone.png` + `rock_stones1..10.png`, `plantsatlas.dds → plantain1..3.png` / `flower1..3.png`, `field1.dds → field.png`, `minegold.dds → mine_gold.png`, etc. | Real same-art-different-name relatives, confirmed by manifest donor path. They are **SUMMER** albedo (the `w` variants are separate donor files). Counting them as winter art would be false. | observed (manifest) + derived (count) |
| 48 donor `w` names not in manifest | e.g. `fir2w/fir3w`, `field2w..7w`, `burch*w`, `palm*w`, `leaftree*w`, `drytree2w/3w`, `detailw`, `grassforestw` | No converted sid link at all; port has no `burch*`, `palm*`, `leaftree*`, `terrainmesh*` or `detail*` models/tex (`manifest.json` scan). | observed |
| 226 building `*_w` decals | §2.2 list; no `detail`-named decal exists in `decals_dds/` (0 matches) | Building-child winter art only; donor `detailw` (`env.mat:1452`) is not satisfied by these files. | observed |
| Winter tile atlas + field decal | S8 rows 2 and 4 | Ground tiles and one field decal exist; they are a different art channel from prop materials (`_winter` vs `w`, S2 §4). | observed |

### 2.2 Full list of the 226 building `*_w` decal stems (observed ×2)

Each stem exists as both `terrain/decals_dds/<stem>.dds` and
`terrain/decals_png/<stem>.png`:

```
algcendw alghoudw
ausacadw ausartdw ausba2dw ausbardw ausbladw auscendw ausdipdw aushoudw ausstadw austemdw
bavacadw bavartdw bavba2dw bavbardw bavbladw bavcendw bavdipdw bavhoudw bavstadw bavtemdw
denacadw denartdw denba2dw denbardw denbladw dencendw dendipdw denhoudw denstadw dentemdw
engacadw engartdw engba2dw engbardw engbladw engcendw engdipdw enghoudw engstadw engtemdw
eurcoadw eurgoldw eurirodw eurmardw eurmildw eurpordw eursgadw eurstodw eurswadw eurtowdw eurwgadw eurwwadw
fraacadw fraartdw fraba2dw frabardw frabladw fracendw fradipdw frahoudw frastadw fratemdw
hunacadw hunartdw hunba2dw hunbardw hunbladw huncendw hundipdw hunhoudw hunstadw huntemdw
netacadw netartdw netba2dw netbardw netbladw netcendw netdipdw nethoudw netstadw nettemdw
pieacadw pieartdw pieba2dw piebardw piebladw piecendw piedipdw piehoudw piestadw pietemdw
polacadw polartdw polba2dw polbardw polbladw polcendw poldipdw polhoudw polstadw poltemdw
poracadw porartdw porba2dw porbardw porbladw porcendw pordipdw porhoudw porpordw porstadw portemdw
pruacadw pruartdw pruba2dw prubardw prubladw prucendw prudipdw pruhoudw prustadw prutemdw
rusacadw rusartdw rusba2dw rusbardw rusbladw ruscendw rusdipdw rushoudw rusmardw rusmildw ruspordw russtadw russtodw rustemdw rustowdw
saxacadw saxartdw saxba2dw saxbardw saxbladw saxcendw saxdipdw saxhoudw saxstadw saxtemdw
scoacadw scoartdw scoba2dw scobardw scobladw scocendw scodipdw scohoudw scostadw scotemdw
spaacadw spaartdw spaba2dw spabardw spabladw spacendw spadipdw spahoudw spamardw spastadw spastodw spatemdw
sweacadw sweartdw sweba2dw swebardw swebladw swecendw swedipdw swehoudw swestadw swetemdw
swiacadw swiartdw swiba2dw swibardw swibladw swicendw swidipdw swihoudw swistadw switemdw
turacadw turartdw turbardw turbladw turcendw turdipdw turhoudw turmardw turmildw turpordw turstadw turstodw turtemdw turtowdw
ukracadw ukrartdw ukrbardw ukrbladw ukrcendw ukrdipdw ukrhoudw ukrpordw ukrstadw ukrtemdw
venacadw venartdw venba2dw venbardw venbladw vencendw vendipdw venhoudw venstadw ventemdw
```

The **226** count is from the machine scan (DDS and PNG independently), not from a manual
count of this prose block; every stem in the block was copied from that scan.

---

## 3. Gap ranking

| Rank | Gap (visual impact) | Donor evidence | Port evidence | Label |
|---:|---|---|---|---|
| **1** | **79 winter prop materials have zero same-named port art.** 74 are referenced by 321 donor `.prop` files; the 72 distinct w-DDS are brighter/frosted (`fir1w`, `plantsatlasw`, `stonesw`, `field1w` means in S1 §2.2) and some use different emission. Conifers, broadleaf, plants, stones, mines and fields keep summer albedo in a winter scene. | `env.mat:815-1551` (§1); `fir.prop:33-43`, `field.prop:58-76`, `grass.prop:36-42`, `terrainmesh1.prop:16-18` | 0/79 exact stems in 8,210 port asset files (§2, ×2); 0 `w` stems in `models/tex` | **observed both sides**; visual delta **inferred** |
| **2** | **Tree families cannot be swapped at all without new art.** DECOR-01's 19-sid pool is summer albedo only; donor `fir1..3w`, `spruce1..3w`, `pine*`, `pinedry*`, `oak*`, `burch*`, `palm*` etc. have no port counterpart. `leaftree*w` must **not** be added (winter destroys leaftree). | `env.mat:817-838,1045-1110,1177-1192,1257-1342`; `dogenerate.inc:1975-1982` via S1 | `models/tex` 346 PNGs; `manifest.json` 172 models; `tree_fir.png` donor `fir1.dds` (summer); no `burch/palm/leaftree` sids | observed + inferred |
| **3** | **Field crops: 8 `w` materials and a grey decal, none bound.** Donor `fieldw`+`field1..7w`; `envfielddw` grey `#756F61` vs summer `#4D442E`. | `env.mat:865-1020`; `decals.lib:37-44`, `decals.mat:110-115` via S1 §2.3 | `envfielddw.png` exists but is only recorded in `field_visual_decals` stats (`world3d_entities.gd:245,330-332,428-430`); "3D UV mapping UNVERIFIED" comment `:328-329`; field mesh uses `field.png` + per-instance tint | observed both sides; 3D decal mapping UNVERIFIED |
| **4** | **Relief mesh props: no mesh, no art.** Donor `terrainmesh1w..4w` are DXT5 2048² albedos on 4 `.osm` meshes. | `env.mat:1416-1429`; `DEC_05 §3.1/:100-101` | port manifest has **0** terrainmesh sids; `models/tex` has **0** terrainmesh PNGs | observed |
| **5** | **Building child material `detailw` not represented.** 226 building `*_w` decals exist but no `detail`/`detailw` art or child-material swap path. | `env.mat:1452-1453`; `miscext.script:1589-1596` via S1/S2 | `decals_dds/detail*` matches = 0; no `detail` sid in manifest | observed |
| **6** | **SP-7 season prop hook not landed** (planned in S3 `:192`). No `w` resolver; `world3d_entities.gd` has no `winter` branch in `_default_material()` (`:502-515`) or `_resource_sid()` (`:1514-1528`). | donor prop `.prop` season fields above | `Data.BIOME` string exists (`data.gd:199`; terrain hook consumes it at `world3d_terrain.gd:392-430`), but entities do not | observed |

**Not a gap:** the winter *ground tile* atlas/dictionary (`SP-2/4/5/6`) and the 27 winter
tile PNGs are on disk; they are a different channel and must not be re-counted as prop art
(S1 §4; S3 §3). **Not a fix:** inventing winter pixels by tinting summer art would be
`PORT APPROXIMATION` only and would still leave the donor delta unrepresented.

---

## 4. Ordered small-ticket plan (names only; nothing edited)

One owner file per ticket. All tickets obey `PLAN_IMPLEMENTATION.md §3` (backup, minimal
diff, donor citation or explicit UNVERIFIED, unique runner job id, one report). `Data.BIOME`
(`data.gd:199`) is the existing season key; the terrain hook already reads it
(`world3d_terrain.gd:392-430`), so no new season enum ticket is needed for props.

| ID | Owner file (EXCLUSIVE) | Change / scope | Donor citation | Acceptance | Gate |
|---|---|---|---|---|---|
| **PW-1 MATERIAL-MAP** | `variant3d/assets/terrain/structs/prop_winter_materials.json` (NEW) | Author the 79 exact donor `w` names from §1 with: `source_donor_dds`, `port_texture` (`""` until art exists), `alias_of` for the 7 aliases, `referenced_by_props` count, and explicit `UNVERIFIED` labels. No donor copy, no code. | `env.mat:815-1551` (§1, fresh) | 79 keys, 72 distinct DDS, 7 aliases, every key matches a donor line; empty `port_texture` never silently falls back to a fake asset | none |
| **PW-2a ART-CONIFERS** | `variant3d/assets/models/tex/` (asset owner; NEW `<sid>_w.png` files) | Convert authorise-and-convert only the highest-impact conifer set (`fir1..3w`, `firsmall1..3w`, `spruce1..3w`, `pine1..3w`, `pinesmall1..3w`, `pinedry1w`, `pinestumpw`) to the existing sid names. No donor file may be copied without a separate owner decision (availability/copyright **UNVERIFIED**). | `env.mat:817-838,1045-1110,1253-1254` | ≤19 new PNGs, each with donor path recorded; SUMMER PNGs byte-identical; no mesh edit | PW-1 |
| **PW-2b ART-CLUTTER** | `variant3d/assets/models/tex/` (same asset owner, separate ticket) | Plants/stones/mines: `plantsatlasw`, `plantswateratlasw`, `fernw`, `bushesw`, `stonesw`, `smallstonesw`, `rocksw`, `landstonew`, `rocksea*w`, `stonesseaw`, `mine*w`, `field1w`/`fieldw`. Aliases `desert1w..5w`, `desertstumpw`, `plantswateratlastransparencyw` bind to **already-converted** files, no new art. | `env.mat:841-862,865-1020,1157-1190,1213-1234,1345-1386,1456-1479,1510-1551` | Only in-scope PNGs added; alias entries resolve to existing port files; 6 base-name files unchanged | PW-1 |
| **PW-2c FIELD-DECAL** | `variant3d/scripts/world3d_entities.gd` **or a new `variant3d/scripts/field_decal_3d.gd` owned by that builder** | Wire `envfielddw.png` only if a 3D UV rule can be cited; otherwise keep stats-only and label UNVERIFIED. Do not invent UVs. | `decals.lib:37-44`; `env.mat:865-906`; S1 §2.3 | Winter field either shows the donor grey decal with a cited rule, or remains stats-only with an explicit label; no tint invented as a substitute | PW-1; coordinated with the PW-4 seam owner |
| **PW-3 HOOK** | `variant3d/scripts/prop_winter_materials.gd` (NEW — **owning file of the minimal material-variant hook**) | Pure resolver: `resolve(sid_or_material, season) -> texture_path or ""`; reads PW-1 JSON; no scene/node/material creation; emits fallback label `PORT APPROXIMATION — donor runtime UNVERIFIED`; never mutates `Data.BIOME`. | `grass.prop:36-42`, `fir.prop:33-43`, `field.prop:58-76`, `terrainmesh1.prop:16-18` | Summer always returns `""`; winter returns only paths that exist on disk; missing art returns `""` and records a counted fallback | PW-1 |
| **PW-4 SEAM** | `variant3d/scripts/world3d_entities.gd` (single-writer, **co-owned**) | Minimal diff in `_default_material()` (`:502-515`) and, if needed, `_resource_sid()` (`:1514-1528`): call PW-3 for winter, bind returned texture, keep summer path otherwise. Preserve DECOR-01's 43-line tree block and MOTION-ANIM-01's motion block byte-for-byte. Do **not** add leaftrees or invent terrainmesh/detail art. | same as PW-3; `miscext.script:1568-1596` via S1/S2 | Summer fixture byte-identical; winter uses only newly authored art; 0 new leaftree nodes; status keys report resolved/fallback counts | **DECOR-01 + MOTION-ANIM-01 merged; new backup; re-read immediately before edit** |
| **PW-5 VERIFY** | `variant3d/tests/t_prop_w.gd` (NEW) | 64² dump-driven atom: summer unchanged; winter asserts resolver returns 0 missing paths, N resolved paths, `field_visual_decals` winter path recorded, no leaftree, no invented asset; write result JSON, `call_deferred(quit)`, runner job id. No donor A/B, no visual-parity claim. | none (verifies PW-1..PW-4) | passes only after PW-4; fails before; no existing test edited | PW-4, TEST-HARNESS consume-only |

**Ordering rationale:** data first (PW-1) → art subset (PW-2a/2b) → pure resolver (PW-3) →
one coordinated seam (PW-4) → atom (PW-5). PW-2c is optional/parallel and may remain
stats-only. No ticket edits `game.gd`, `main.gd`, `world3d_terrain.gd`, the shader, or the
test harness; no ticket copies a donor file unless a separate asset-owner decision grants it.

### 4.1 Minimal hook shape (design only)

The hook needs exactly three inputs: (a) the 79-name JSON from PW-1; (b) the season string
already available as `Data.BIOME` / `world3d_terrain.gd` `season`; (c) the current sid → PNG
naming convention `TEX_DIR + sid + ".png"` (`world3d_entities.gd:86,504`). It needs one
output: a path that exists on disk, or `""` (fallback). The hook's **owner file is
`variant3d/scripts/prop_winter_materials.gd`**; the only consumer edit is the PW-4 seam in
`variant3d/scripts/world3d_entities.gd`.

### 4.2 File-ownership / conflict proposal

- `variant3d/scripts/world3d_entities.gd` is currently claimed by **both** DECOR-01
  (`PLAN_IMPLEMENTATION.md:34`, `DECOR_01_implementation.md:5-9`) and MOTION-ANIM-01
  (`MOTION_ANIM_01.md:7-14`). Both report DONE; MOTION-ANIM-01 verified DECOR's 43-line
  tree block byte-identical (`:66-71`). **Proposal:** keep PW-3 in a NEW file so the only
  edit to `world3d_entities.gd` is the PW-4 seam, executed by one named builder after both
  earlier tickets are merged, with a fresh backup and a re-read. No parallel writer to that
  file during PW-4.
- DECOR-01's tree pool/scale work (`POOL_TREE` 19 sids, `ENV_TREE_SCALE` 18 entries,
  `ENV_JITTER_BANDS`) must stay byte-identical; PW-4 must only choose an alternate *texture*
  for an existing sid, never change sid selection, scale, jitter, yaw or mesh.
  `leaftree` is not in the pool (0/19), so the donor "destroy leaftree" rule needs no new
  code this ticket.
- `world3d_terrain.gd` (SP-6/TRN-FACE co-owned) and `game.gd`/`main.gd` (TRN-DATA) are
  deliberately untouched: the season key is consumed, not changed.

---

## 5. What must stay UNVERIFIED

1. **No donor GPU A/B** at a matched camera; all port judgements are structural. No
   "looks donor-like" claim (S3 B3; `GAPS.md` watchlist).
2. **Donor runtime activity**: the `[*] = ;` .inc season lines are live *source encoding*
   per S1/A8, but native EXE execution remains UNVERIFIED; `_misc_SetSeason` callers are
   not proven active in the shipped build.
3. **Visual parity of any converted `w` art** — no donor render is compared; conversion
   permission/availability for the 72 DDS is out of scope and **UNVERIFIED**.
4. **Emission → screen colour**: `fieldw`/`field1w` emission values are observed
   (`env.mat:873-884`, `:895-906`), but the donor render-time multiplier is not decoded
   (S1 Q8). Raw DDS means are not screen colours.
5. **Field decal 3D UV mapping** — the port comment at `world3d_entities.gd:328-329`
   says UNVERIFIED; no UV rule was invented here.
6. **`detailw` on building children** — no port `detail` material path or 3D child-material
   swap is proven; the 226 `*_w` decals are a different channel.
7. **Relief props** — donor `terrainmesh*.osm` meshes and their `w` albedos exist; the port
   has zero converted terrainmesh sids, so binding is impossible without a separate mesh
   import ticket.
8. **Desert interaction** — `desert1w..5w` reuse un-suffixed donor art; whether a desert
   scene uses those `w` materials at runtime, and how they interact with the port's
   11/38 desert remap gap (S1 rank 1), is UNVERIFIED and out of this plan.
9. **Lens of season key** — `Data.BIOME` is a port string selector; its equivalence to
   donor `GetSeasonType=2` is a PORT APPROXIMATION, not a proven donor mapping.

---

## 6. Open questions (do not guess)

1. **Q1** Is donor-to-port conversion of the 72 `w` DDS permitted, and who owns it? No
   asset was copied in this task; all PW-2 art tickets are conditional on that decision.
2. **Q2** Which subset ships first if only part of PW-2a/2b is affordable? Ranking suggests
   conifers → field/plants → stones/mines, but no port visual gate exists to justify it.
3. **Q3** What is the 3D equivalent of donor building-child `detail → detailw`
   (`miscext.script:1589-1596`)? No `detail` art or child path exists in port.
4. **Q4** Should `terrainmesh*.osm` + `terrainmesh*w.dds` be imported at all? DEC-05 §4.1
   finds no donor world-scale field, so placement would be inferred.
5. **Q5** Does the grey `envfielddw` decal need its own owner (PW-2c), or does the current
   per-instance field tint plus stats-only decal remain the labelled PORT APPROXIMATION?
6. **Q6** Should the resolver key on the material name (`fir1w`) or on the port sid
   (`tree_fir`)? The manifest gives 31 observed donor↔sid links; 48 names have no link.
7. **Q7** Can the 226 building `*_w` decals be reused for any env prop, or are they
   strictly building decals? No `detail`-named file exists; treat as separate channel.
8. **Q8** What structural threshold proves a winter prop change without a donor A/B?
   Proposed: resolved-path count + fallback count, **not** pixel metrics that could
   override visual review.

---

## 7. Summary

**Donor (fresh, twice-verified):** `env.mat:815-1551` defines **79** winter prop materials
with `w` suffixes; **72** have same-named DDS (91,198,648 B), **7** are aliases reusing
un-suffixed DDS; **321** donor `.prop` files consume **74** of them. The suffix is `w` for
props, distinct from `_winter` for tile aliases (S2 §4).

**Port (fresh, twice-verified):** of 8,210 files under `variant3d/assets/**`, **0** match any
of those 79 names — not even case-insensitively. What exists is different art: 27 winter
tile PNGs + winter atlas + aliases, 12 desert PNGs, one winter field decal, and 226
building `*_w` decals (+226 PNG). Six base-name files and 31 manifest-linked summer sid
families are relatives of donor art, **not** winter variants. No `w` prop texture, no
`burch/palm/leaftree/terrainmesh/detail` model or texture exists.

**Plan:** five small tickets, one owner file each — PW-1 79-name data map, PW-2a/b
conditional art subsets, PW-2c optional field decal, PW-3 pure resolver owning
`variant3d/scripts/prop_winter_materials.gd`, PW-4 single coordinated seam in the co-owned
`variant3d/scripts/world3d_entities.gd`, PW-5 64² verification atom. DECOR-01's tree
pool/scale/jitter and MOTION-ANIM-01's motion state stay byte-identical; no second writer
to that file during PW-4.

**UNVERIFIED throughout:** donor GPU A/B, native execution of donor season scripts, art
conversion permission, emission→screen colour, field decal UVs, building-child `detailw`,
relief-prop placement, desert interaction. No code, asset, config, test or git state changed;
no donor file copied, run or unpacked; no Godot runner job; no visual parity claimed.

*End of PROP-W-PLAN-01. One report written. Two verification passes on every headline count.*
