# DEC_U — grass / horseradish BaseName donor-text sweep (read-only)

- id: DEC_U_GRASS_BASENAME
- swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
- owner_file: `docs/terrain_swarm_2026-11-26/reports/DEC_U_grass_basename.md`
- status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_GODOT_GIT_DONOR_EXEC
- created: 2026-11-27
- labels: [O, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
- parity_guard: "Parity UNVERIFIED. Chain 0/6. RESULT IS NOT GOOD. No donor GPU A/B frame exists; no donor binary was executed, no donor file copied, no port byte changed. Every donor statement below is a byte-proven text citation with exact `path:line` from a read-only sweep of `C:\\Games\\Cossacks 3\\data\\**`. Port facts are carried [C] from `PORT1TO1_asset_gap_b.md` and are not re-verified here. No completeness is declared, no parity is claimed, no approximation is endorsed."
- scope_guard: "Exactly one repo file written (this report). No code, asset, config, shader, test, runner, Godot, git, or donor edit. Donor tree was only read (glob/grep/read). No mesh fabricated, no name invented, no static donor fact promoted to port behaviour."
- prior_report_read: `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_asset_gap_b.md` (§1.1–§1.4, §3 [U]-GRASS, §4 evidence index)

## 0. Verdict up front

- [O] The donor DOES ship standalone grass prop records: `grass`, `grass.1–5`, `grasschamomile`, `grassdesert[.1–5]`, `grassforest[.1–5]`, `grassleafforest[.1–3]`, `horseradish[1–3]` exist as `.prop` files with `BaseName` lines, listed in `env.objects`, backed by `.actor` files naming `<mesh>.mesh` + `.osm` geometry files that exist on disk. Grass is therefore NOT tile-block-only in the donor.
- [O] Tile-block grass (`grass1–10`, `grass_sand*`, `grass_ground*`, `grass_rock1` in `terrain/tiles/terrain.presets` + `terrain/tiles/tiles.mat` + tileblock scripts) is a SEPARATE namespace from prop grass (`plantsatlas` / `grassforest` / `grassleafforest` materials in `materials/env/env.mat`). Conflating them is the error this report prevents.
- [U] Every port-side resolution stays UNRESOLVED here: no `grass*.obj`, no `map_Kd.*grass`, no BaseName→PNG manifest was found or created by this worker. The exact zero-mismatch acceptance condition is in §4. No parity claim.
- Parity UNVERIFIED. Chain 0/6. RESULT IS NOT GOOD while §4 blocking_unverified is non-empty.

## 1. Observed facts [O] — byte-proven, exact `path:line`

### O-1. Donor prop manifest lists grass + horseradish records [O]

`C:\Games\Cossacks 3\data\objects\env\env.objects`:

- `env.objects:140` — `ObjectItems[*].PropertiesFileName=.\data\objects\env\horseradish.prop`
- `env.objects:141` — `...\horseradish1.prop`
- `env.objects:142` — `...\horseradish2.prop`
- `env.objects:143` — `...\horseradish3.prop`
- `env.objects:145` — `...\grass.prop`
- `env.objects:146` — `...\grass1.prop`
- `env.objects:147` — `...\grass2.prop`
- `env.objects:148` — `...\grass3.prop`
- `env.objects:149` — `...\grass4.prop`
- `env.objects:150` — `...\grass5.prop`
- `env.objects:161` — `...\grasschamomile.prop`
- `env.objects:173` — `...\grassforest.prop`
- `env.objects:174` — `...\grassforest1.prop`
- `env.objects:175` — `...\grassforest2.prop`
- `env.objects:176` — `...\grassforest3.prop`
- `env.objects:177` — `...\grassforest4.prop`
- `env.objects:178` — `...\grassforest5.prop`
- `env.objects:179` — `...\grassleafforest.prop`
- `env.objects:180` — `...\grassleafforest1.prop`
- `env.objects:181` — `...\grassleafforest2.prop`
- `env.objects:182` — `...\grassleafforest3.prop`
- `env.objects:361` — `...\grassdesert.prop`
- `env.objects:362` — `...\grassdesert1.prop`
- `env.objects:363` — `...\grassdesert2.prop`
- `env.objects:364` — `...\grassdesert3.prop`
- `env.objects:365` — `...\grassdesert4.prop`
- `env.objects:366` — `...\grassdesert5.prop`

### O-2. Each prop file carries an explicit `BaseName` + mesh + material triple [O]

- `C:\Games\Cossacks 3\data\objects\env\grass.prop:4-5` — `CustomName = grass` / `BaseName = grass`; `:13-14` — `LODActorName = grass` / `DefaultMeshName = grass1.mesh`; `:15-22` — `RandomMeshName = True`, 5 useable meshes; `:31-42` — `DefaultMaterialName = plantsatlas`, summer `plantsatlas`, winter `plantsatlasw` (slots [1]–[4] repeat the triple at `:44-91`).
- `C:\Games\Cossacks 3\data\objects\env\grass1.prop:4-5` — `BaseName = grass.1`; `:13-14` — `LODActorName = grass` / `DefaultMeshName = grass1.mesh`. Same shape observed for `grass2.prop:4-5,13-14` (`grass.2` → `grass2.mesh`), `grass3.prop:4-5,13-14`, `grass4.prop:4-5,13-14`, `grass5.prop:4-5,13-14`.
- `C:\Games\Cossacks 3\data\objects\env\grasschamomile.prop:4-5` — `BaseName = grasschamomile`; `:13-14` — `LODActorName = grasschamomile` / `DefaultMeshName = grasschamomile1.mesh`; `:27-38` — material `plantsatlas` / winter `plantsatlasw` (note `[*]` index spelling here vs `[0]` in `grass.prop`).
- `C:\Games\Cossacks 3\data\objects\env\grassforest.prop:4-5` — `BaseName = grassforest`; `:13-14` — `LODActorName = grassforest` / `DefaultMeshName = grassforest1.mesh`; `:31-42` — material `grassforest` / winter `grassforestw`.
- `C:\Games\Cossacks 3\data\objects\env\grassleafforest.prop:4-5` — `BaseName = grassleafforest`; `:13-14` — `LODActorName = grassleafforest` / `DefaultMeshName = grassleafforest1.mesh`; `:29-40` — material `grassleafforest` / winter `grassleafforestw`.
- `C:\Games\Cossacks 3\data\objects\env\horseradish.prop:4-5` — `BaseName = horseradish`; `:13-14` — `LODActorName = horseradish` / `DefaultMeshName = horseradish1.mesh`; `:15-20` — 3 useable meshes; `:29-40` — material `plantsatlas` / winter `plantsatlasw`.
- Desert variants reuse the meadow actor/mesh: `grassdesert.prop:4-5,13-14` (`BaseName = grassdesert`, `LODActorName = grass`, `DefaultMeshName = grass1.mesh`); `grassdesert1.prop:4-5,13-14` (`grassdesert.1` → `grass1.mesh`); `grassdesert2.prop` (→ `grass2.mesh`); `grassdesert3.prop` (→ `grass3.mesh`); `grassdesert4.prop` (→ `grass4.mesh`); `grassdesert5.prop` (→ `grass5.mesh`) — grep hits `C:\Games\Cossacks 3\data\objects\env\grassdesert*.prop` lines 4–5/13–14.
- Control contrast (same directory, same chain shape — proves grass is not an anomaly): `plantain.prop:4-5` (`BaseName = plantain`), `plantain1.prop:5` (`plantain.1`), `plantain2.prop:5`, `plantain3.prop:5`, `plantainyellow.prop:5`, `plantainyellow1-3.prop:5`, `plantyellow.prop:5`, `plantyellow1-5.prop:5`, `fern.prop:5` + `fern1-4.prop:5`, `flowers.prop:5` + `flowers1-3.prop:5`, `reed.prop:5` + `reed1-3.prop:5`; `plantain.prop:13-14` (`LODActorName = plantain` / `DefaultMeshName = plantain1.mesh`); `plantain.prop:29-40` (material `plantsatlas` / winter `plantsatlasw`). `env.objects` lists the same controls at `:115-119` (fern), `:163-166` (plantain), `:168-171` (flowers), `:275-278` (reed), `:290-292` (plantainyellow).

### O-3. Actor files resolve every grass/horseradish mesh name to a `.osm` geometry file that exists [O]

- `C:\Games\Cossacks 3\data\actors\env\grass.actor:2-3` — `grass1.mesh` → `.\data\actors\env\grass1.osm`; `:5-6` — `grass2.mesh` → `grass2.osm`; `:9-10` — `grass3.mesh` → `grass3.osm`; `:13-14` — `grass4.mesh` → `grass4.osm`; `:17-18` — `grass5.mesh` → `grass5.osm`.
- `C:\Games\Cossacks 3\data\actors\env\horseradish.actor:2-3` — `horseradish1.mesh` → `horseradish1.osm`; `:5-6` — `horseradish2.mesh` → `horseradish2.osm`; `:9-10` — `horseradish3.mesh` → `horseradish3.osm`.
- `C:\Games\Cossacks 3\data\actors\env\grasschamomile.actor:2-3` — `grasschamomile1.mesh` → `grasschamomile1.osm` (grep hit).
- `C:\Games\Cossacks 3\data\actors\env\grassforest.actor:2-3` — `grassforest1.mesh` → `grassforest1.osm`; `:5-6` — `grassforest2.mesh` → `grassforest2.osm`; `:9-10` — `grassforest3.mesh` → `grassforest3.osm`; `:13-14` — `grassforest4.mesh` → `grassforest4.osm`; `:17-18` — `grassforest5.mesh` → `grassforest5.osm`.
- `C:\Games\Cossacks 3\data\actors\env\grassleafforest.actor:2-3` — `grassleafforest1.mesh` → `grassleafforest1.osm`; `:5-6` — `...2.mesh` → `...2.osm`; `:9-10` — `...3.mesh` → `...3.osm`.
- Control: `C:\Games\Cossacks 3\data\actors\env\plantain.actor:2-3,5-6,9-10` — `plantain{1,2,3}.mesh` → `plantain{1,2,3}.osm`.
- Geometry files present on disk (directory glob, not inference): `data\actors\env\grass{1,2,3,4,5}.osm`, `grasschamomile1.osm`, `grassforest{1,2,3,4,5}.osm`, `grassleafforest{1,2,3}.osm`, `horseradish{1,2,3}.osm` — glob `C:\Games\Cossacks 3\data\actors\env\grass*.osm` returned all 14 paths; glob `horseradish*.osm` returned all 3 paths.
- Logical-name format note [O]: donor references `<name>.mesh` inside `.prop`/`.actor` text, but a tree-wide glob `C:\Games\Cossacks 3\data\**\*.mesh` returned NO files found. The shippable geometry observed by this text sweep is the `.osm` file named in each `.actor` `LoadFromFile` line. No converter, exporter, or binary was run to interpret `.osm` bytes.

### O-4. Materials bind prop grass to atlas DDS files — a different namespace from tile grass [O]

`C:\Games\Cossacks 3\data\materials\env\env.mat`:

- `:534-535` — `Material.Name = plantsatlas` / `image = .\data\materials\env\plantsatlas.dds`
- `:550-551` — `Material.Name = plantsyellowatlas` / `...plantsyellowatlas.dds`
- `:575-576` — `Material.Name = grassforest` / `...grassforest.dds`
- `:591-592` — `Material.Name = grassleafforest` / `...grassleafforest.dds`
- `:1349-1350` — `Material.Name = plantsatlasw` / `...plantsatlasw.dds`
- `:1390-1391` — `Material.Name = grassforestw` / `...grassforestw.dds`
- `:1406-1407` — `Material.Name = grassleafforestw` / `...grassleafforestw.dds`
- DDS files present: glob `C:\Games\Cossacks 3\data\materials\env\grass*` returned `grassforest.dds`, `grassforestw.dds`, `grassleafforest.dds`, `grassleafforestw.dds`; glob `plantsatlas*` returned `plantsatlas.dds`, `plantsatlasw.dds`.

### O-5. Tile-block grass is a separate system with its own files and scripts [O]

- `C:\Games\Cossacks 3\data\terrain\tiles\terrain.presets:6-15` — `[*].TileBlock = grass1` … `grass10`; `:17-22` — `grass_sand1/2`, `grass_rock1`, `grass_ground1/2/3` (same block list continues with rock/sand entries at `:23+`).
- `C:\Games\Cossacks 3\data\terrain\tiles\tiles.mat:4` — `Material.Texture.image = .\data\terrain\tiles\textures\grass1.dds` (further `grass1.dds` hits at `:348,353,358`).
- Tileblock-name scripts (no prop BaseName involved): `C:\Games\Cossacks 3\data\scripts\misc\projectile.inc\doexplodecustom.inc:84-85,88`, `doexplode.inc:106-107,110,114` (`gc_obj_explmedia_grass`); `C:\Games\Cossacks 3\data\scripts\common.inc\dogenerate.inc:1953` (`MapGetTileIndexByTileBlock('grass1_winter')`); `loadenvironmentfrombitmap.inc:26,33,36,42,54,57,63` (`tile := 'grass1'/'grass6'`); `smoothforestborders.inc:134` (`tile := 'grass5'`); `C:\Games\Cossacks 3\data\scripts\lib\miscext.script:1448-1452,1462,1468-1471,1495,1497-1498` (`'grass1'/'grass3'/'grass5'/'grass7'/'grass8'/'grass2'/'grass_ground1-3'/'grass10'/'grass6'/'grass9'` desert-remap table); `C:\Games\Cossacks 3\data\scripts\dmscript.global:299` (`gc_obj_explmedia_grass = 4`).
- Pattern/lib places PROP BaseNames, not tiles: `C:\Games\Cossacks 3\data\pattern\pattern.lib` contains `BaseName = grass.3` (`:25436,27004,29020,29216`), `grassforest.1` (`:2154,4366,15174,15762,19514,21306`), `grassforest.2` (`:390,2014,7740,12444,18450`), `grasschamomile` (`:13550,16014,19878`), `horseradish.1` (`:418,1846,3246`), alongside control `plantain.1` / `plantain.3` rows (`:1986,7628,8832,9420,…`). This is the tile-block-vs-prop distinction the port must preserve: tiles come from `terrain.presets`/`tiles.mat`/tileblock scripts; tufts come from `objects/env/*.prop` → `actors/env/*.actor` → `*.osm` placed via `pattern.lib` `Objects` records.

### O-6. No donor BaseName→PNG manifest exists in the swept text [O, bounded]

- Grep `BaseName.*\.png|basename.*manifest|basename.*\.png` over `C:\Games\Cossacks 3\data\**` returned NO matches found.
- This is a bounded text-sweep observation only: no file under `data\**` seen by this worker maps a prop `BaseName` to a PNG/DDS path in a single manifest document. It is NOT a claim that no mapping is derivable — the derivable chain is §O-2→O-4 (`.prop` material name → `env.mat` material → DDS path). It is also not a port fact.

## 2. Answers to the three tasked questions

1. Does the donor ship standalone grass prop meshes at all? YES — as text records [O]: 6 `grass*.prop` + 1 `grasschamomile.prop` + 6 `grassdesert*.prop` + 6 `grassforest*.prop` + 4 `grassleafforest*.prop` + 4 `horseradish*.prop` files in `data/objects/env/` (§O-1), each naming a `<name>.mesh` + `LODActorName` (§O-2), each actor resolving to existing `.osm` geometry (§O-3), each material resolving to an existing atlas/grass DDS (§O-4). The shippable geometry extension observed is `.osm`, not `.mesh` (§O-3 format note).
2. Is grass tile-block-only? NO [O]. Tile blocks (`terrain.presets`, `tiles.mat`, tileblock scripts, §O-5) and prop tufts (`objects/env` + `actors/env` + `env.mat` + `pattern.lib`, §O-1→O-4) coexist as disjoint namespaces sharing only the English word "grass".
3. What name/manifest would resolve the port's skipped BaseNames? ONLY donor-observed names — no name is invented here. The required manifest row per BaseName is defined in §4 [U]; its key columns are the exact donor strings cited above (`BaseName`, `LODActorName`, `DefaultMeshName`, `.osm LoadFromFile`, material summer/winter pair, DDS path). Carried port context [C, not re-verified]: `PORT1TO1_asset_gap_b.md` §1.2 E4d records the port resolver skip (`BASE_UNRESOLVED … no converted sid; skipped (no mesh fabricated)` in `variant3d/scripts/terrain_donor_props.gd`).

## 3. Explicit non-findings (not evidence)

- No `.mesh`-extension file was found by glob (`**/*.mesh` → no files found) [O, bounded to filename sweep]. Whether the engine synthesises `.mesh` handles from `.osm` at load is NOT answered by text and is not claimed.
- No per-variant `.prop` files for `grassforest1-5` / `grassleafforest1-3` / `horseradish1-3` numbered BaseNames beyond the bare + `.1` forms were individually opened beyond the grep census; only the bare-form prop bodies are quoted verbatim above. Numbered `.prop` filenames exist in the `env/` listing (e.g. `horseradish1.prop`, `grassforest1.prop`) but their bodies are NOT cited here and must not be assumed identical.
- `plant*.prop` (`plant.prop`, `plant1-5.prop`) filenames exist in the `env/` directory listing but were not opened; nothing about the `plant` BaseName family is asserted here.
- Whether the port converts or should convert `.osm` → `.obj`, which DDS variant each tuft samples inside its atlas, and any pixel/render behaviour are untouched by this sweep. No port behaviour is asserted.

## 4. Unknowns ledger [U] — exact zero-mismatch / resolution conditions

- [U]-GRASS-MESH — donor proves the RECORD chain (`prop→actor→osm`, §O-1→O-3) but this text sweep proves no converted port mesh. RESOLUTION: one manifest row per skipped port BaseName (`grass`, `grass.1–5`, `grasschamomile`, `grassdesert[.1–5]`, `grassforest[.1–5]`, `grassleafforest[.1–3]`, `horseradish`, `horseradish.1` — exact set taken from the port resolver skip list, never extended here) carrying donor `BaseName` + `LODActorName` + `DefaultMeshName` + `.osm LoadFromFile` + summer/winter material pair + `env.mat` DDS path (all strings quoted verbatim from §O-2→O-4) PLUS port `OBJ PRESENT/ABSENT + bytes` + port `PNG PRESENT/ABSENT + WxH` + `winter PRESENT/ABSENT`. ZERO-MISMATCH: 0 rows with a donor string that does not match the cited `path:line`, and 0 skipped BaseNames without a row.
- [U]-GRASS-MANIFEST — no BaseName→PNG manifest file exists on either side per this sweep + carried `PORT1TO1_asset_gap_b.md` §1.2 E4b/E4c (no `grass*.obj`, no `map_Kd.*grass`). RESOLUTION: the §[U]-GRASS-MESH manifest itself, stored outside converted-asset trees, re-checked with (a) `grass*.obj` glob → 0-or-cited-bytes and (b) `map_Kd.*grass` grep → 0-or-cited-sid. ZERO-MISMATCH: 0 manifest rows pointing at a tile-block PNG (`assets/terrain/grass*.png`) as if it were a prop texture — §O-4 vs §O-5 namespaces must stay disjoint in every row.
- [U]-GRASS-WINTER — donor winter materials (`plantsatlasw`, `grassforestw`, `grassleafforestw`, §O-4; per-mesh `UseableWinterMaterials` blocks, §O-2) have no port wiring per carried gap-B E4e (data-only JSON, no loader). This worker adds only the donor half. RESOLUTION: per-mesh winter bind proof or an explicit labelled ABSENT per BaseName. ZERO-MISMATCH: 0 meshes claiming a winter material without an `env.mat:13xx` cite.
- blocking_unverified: [U]-GRASS-MESH, [U]-GRASS-MANIFEST, [U]-GRASS-WINTER.

## 5. Reproduction (read-only commands used; no writes outside this file)

- `read C:\Games\Cossacks 3\data` (directory) + `read C:\Games\Cossacks 3\data\objects\env` (355 entries) + `read C:\Games\Cossacks 3\data\actors\env` (377 entries).
- `grep grass|horseradish C:\Games\Cossacks 3\data\objects\env` → `env.objects:140-182,361-366` + per-prop `BaseName`/`DefaultMeshName` lines.
- `read` full bodies: `objects\env\grass.prop`, `grassforest.prop`, `grassleafforest.prop`, `horseradish.prop`, `grasschamomile.prop`, `plantain.prop`; partial-line grep for `grass1-5.prop`, `grassdesert*.prop` `:4-5,13-14`.
- `grep grass|horseradish|plantain|plantsatlas C:\Games\Cossacks 3\data\actors\env` → `grass.actor:2-18`, `horseradish.actor:2-11`, `grassforest.actor:2-18`, `grassleafforest.actor:2-10`, `plantain.actor:2-10`; `read actors\env\grass.actor`, `horseradish.actor`.
- `glob actors\env\grass*.osm` → 14 paths; `glob horseradish*.osm` → 3 paths; `glob data\**\*.mesh` → no files found.
- `grep plantsatlas|grassforest|grassleafforest C:\Games\Cossacks 3\data\materials` → `env.mat:534,575,591,1349,1390,1406`; `read env.mat:525-644`, `:1340-1399`; `glob materials\env\grass*` + `plantsatlas*` → DDS lists.
- `grep grass|horseradish|plantain C:\Games\Cossacks 3\data\pattern` → `pattern.lib` BaseName rows; `grep grass|horseradish|plantain C:\Games\Cossacks 3\data\scripts` → tileblock/explmedia hits; `grep grass1|tileblock|TileBlock C:\Games\Cossacks 3\data\terrain` → `terrain.presets:6-22`; `grep grass1\.dds|plantsatlas\.dds terrain` → `tiles.mat:4,348,353,358`; `grep BaseName.*\.png|basename.*manifest data\**` → no matches found.

## 6. Verdict (binding wording)

- Parity UNVERIFIED. Chain 0/6. RESULT IS NOT GOOD: donor text proves standalone grass/horseradish prop records exist (NOT tile-block-only, §O-1→O-5), but every port-side resolution in §4 is [U] with blocking_unverified non-empty.
- No completeness declared: line citations above are existence evidence for the cited records only, not a census of all 21+ grass-family variants, not a geometry/mesh-parity proof, not a render claim.
- No approximations made and no parity claimed in this report. No mesh was fabricated, no name was invented, no static donor fact is stated as port behaviour.
