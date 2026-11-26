---
id: V07
ticket: "TERRAIN-SWARM-2026-11-26 / V07 — asset readiness ledger for fresh-module landscape props"
agent: "V07 (DONOR-FIRST terrain swarm, read-only verification worker)"
created: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_CODE_OR_ASSET_EDIT__NO_GODOT_JOB
owner_file: docs/terrain_swarm_2026-11-26/reports/V07_relief_asset_readiness.md
labels: [O, D, I, U, "PORT APPROXIMATION"]
donor: "C:\\Games\\Cossacks 3 read in place only (data/pattern/pattern.lib text scan); no donor binary executed, copied or committed"
scope: "On-disk verification of A04's claims; asset inventory cross-check against P02; static grep of variant3d Godot consumers and QA artefacts. No runner job, no capture, no source/asset/test/config/git edit."
priors_read:
  - docs/terrain_swarm_2026-11-26/CHARTER.md
  - docs/terrain_swarm_2026-11-26/SWARM_BOARD.md
  - docs/terrain_swarm_2026-11-26/IMPLEMENTATION_PLAN.md
  - docs/terrain_swarm_2026-11-26/reports/A04_landscape_props.md
  - docs/terrain_swarm_2026-11-26/reports/P02_asset_inventory.md
  - docs/terrain_swarm_2026-11-26/spec/11_ASSET_CONVERSION.md
  - docs/terrain_swarm_2026-11-26/reports/P03_gates_capture.md
  - docs/terrain_swarm_2026-11-26/reports/F02_pattern_lib.md
  - docs/terrain_swarm_2026-11-26/reports/D05_relief_stamp.md
parity_guard: "No donor GPU A/B frame exists (CHARTER.md:57-58,122-130). Nothing here is a donor-parity verdict; every visual claim is INFERRED or UNVERIFIED."
---

# V07 — relief / landscape-prop asset readiness ledger

> [!IMPORTANT]
> `[O]` literal file/byte/line observed this pass · `[D]` deterministic arithmetic or set
> difference from observed data · `[I]` best reading without an engine run · `[U]`
> UNVERIFIED · `PORT APPROXIMATION` = explicit port substitute, never donor truth.
> Paths are repo-root relative unless prefixed with the donor root. **No donor binary
> was run/copied; no Godot job was submitted; only this report was written.**

---

## 1. Executive summary

1. **[O] A04's central claim is confirmed on disk.** `terrainmesh1..4` are converted,
   registered in `variant3d/assets/models/manifest.json` as exactly four `kind="relief"`
   entries, linked by `variant3d/assets/terrain/mountain_props.json`, and consumed by a
   wired `world3d_relief.gd` MultiMesh module composed at `world3d.gd:614,650`. The old
   terrain module still calls them `"mountain terrainmesh props"` / `"full 26-grid
   float32 tables"` `not_done` (`world3d_terrain.gd:1515`; P02 §0.4, §4).
2. **[O] "Never QA-run" is also confirmed.** `variant3d/tests/t_relief_props_qa.gd`
   exists (35,522 B) but `variant3d/tests/results/t_relief_props_qa.json` does not; the
   Z07 capture directory `…\Temp\opencode\z07_relief_props` does not exist; and the QA
   atom's `PROP_MANIFEST` (`terrainmesh_props.json`, `t_relief_props_qa.gd:30`) is a
   stale path — the live table is `mountain_props.json` (`world3d_relief.gd:42`). The
   atom also expects one `MeshInstance3D` per stamp at scale 1 (`:82, :317, :347, :42`)
   while the landed consumer builds `MultiMeshInstance3D` batches with authored scale
   0.3539–0.6562 (`world3d_relief.gd:188,206-246`). No mountain fixture exists
   (`tests/fixtures/` only has `small_map_64.json`); the atom's required
   `small_map_64_mountains.json` is named at `:25,760` but absent. **[U]** runtime
   placement and silhouette are therefore unproven.
3. **[O] Relief float windows are not exported.** `export_donor_patterns.py:139-155`
   writes only `{"w","h","cells"}`; `donor_patterns.json` (982,264 B, 43 families,
   282 patterns) has no `f32` grid, no sculpt flags, no `Objects` list, and **zero**
   swamp/lake names. `variant3d/assets/terrain_new/` — the spec's fresh compiler root
   (`11_ASSET_CONVERSION.md:40-50`) — is **ABSENT**. Hills/plateaus/ravines and
   lakes cannot be donor-shaped from current port assets.
4. **[D] Contradiction resolved by multiple passes (§8):** A04's "26 decoded windows"
   is a *bit-verified subset*, not the donor total. A fresh read of `pattern.lib` finds
   680 sections, 582 with `HeightFieldStand=True`, 382 all-zero min/max, and **200
   with nonzero min/max**; of the 282 patterns already exported, **86** have nonzero
   `HeightFieldMin/Max`. Only ~26 were bit-cross-checked by `DPATTERN_01` (A04 E02).
   `D05_relief_stamp.md:85` further conflicts with A04 on grid sample count: the
   native loader allocates `(w+1)×(h+1)` floats, not `w×h`, and the stamp uses
   `HeightFieldMin` as pivot with `HeightFieldMax` never read (`:17,23`). I02 must
   resolve the byte boundary against donor bytes; **no constant may be guessed**.
5. **[O] Most other prop families are converted but only partly wired.** 299 manifest
   models include env×93, relief×4; 23 tree meshes + PNG albedos, 44 rock/stone sids,
   4 bush, 4 fern, 3 reed, 3 plantain, 3 mine deposits + 3 mine buildings + six
   `eur*` dirt plates, `field` + 2 mill-field decals, 8 wave sheets. But `POOL_TREE`
   exposes only 18 trees (`world3d_entities.gd:178-181`), `POOL_ROCK` only 5 (`:182`),
   fern/reed/plantain have **no sim placement consumer** (P02 §4), the field decal is
   recorded as availability stats only with 3D UV `UNVERIFIED` (`:313-315,446-449`),
   and the mine dirt decals are 2D-only (`world.gd:767,775`).
6. **[O] F02 (landed) closes *knowledge*, not *assets*.** F02 proves `pattern.lib` is
   plaintext (680 sections, 37-field prologue, 39,780 object records, 235 distinct
   `BaseName`) and that family membership lives in `generator.cfg` (64 groups, 493
   refs), with mine props embedded inside `mng/mni/mnc` sections
   (`F02_pattern_lib.md:17-53, E18`). F01/F07/F08 were still **not landed** at the
   final pass of this report (§6). I02/I03/I05 are the only tickets that *emit* the
   missing derived assets; F-reports alone cannot make a class usable.
7. **[U] No donor parity claim is made.** Every "ready" verdict below means
   *converted + loadable/static consumer*, never visually donor-correct.

---

## 2. Evidence table

| ID | Evidence (repo `path:line`, donor `path:line`, or on-disk count) | Label | Establishes |
|---|---|---|---|
| E01 | `variant3d/assets/models/manifest.json` read: 299 models; kinds `building`129/`env`93/`unit`73/`relief`4; relief sid→`C:\Games\Cossacks 3\data\actors\env\terrainmeshN.osm` + `materials\env\terrainmeshN.dds` | `[O]` | Four relief props are registered with donor provenance |
| E02 | `variant3d/assets/models/obj/shared/terrain/terrainmesh{1..4}.obj` = 302,651+256,005+244,123+342,497 B; `.mtl` 4×77 B; `variant3d/assets/models/tex/shared/terrain/terrainmesh{1..4}.png` = 7,758,343+7,780,004+7,853,483+8,005,498 B (31,397,328 B) | `[O]` | Derived geometry + albedo exist (OBJ+MTL 1,145,584 B) |
| E03 | `variant3d/assets/terrain/mountain_props.json` (66,519 B): `version=1`, `source_sha256=f7b421b1…`, `by_pattern`30, `pattern_meta`30, `props`30 keys, **112** records; `derived_stats`: 30 sections, 20 port-stampable, 45 stampable records, scale 0.3538637161–0.6562154889, `plateau_records=0` | `[O]` | Prop table schema/counts match A04 E08 |
| E04 | `world3d_relief.gd:42-43,86-92,149-171,206-246`; `world3d.gd:116,614,650,691`; `asset_paths.gd:15` | `[O]` | Live consumer: per-sid static `MultiMeshInstance3D`, authored scale/yaw, `height_at_world` grounding, stats seam; render-only (`:5-8`) |
| E05 | `t_relief_props_qa.gd:30,42,82,317,347,760`; `tests/results/` listing (no relief JSON); `%TEMP%\opencode\z07_relief_props` absent; `tests/fixtures/` only `small_map_64.json` | `[O]`/`[U]` | QA atom stale on three interfaces and never run; no capture |
| E06 | `export_donor_patterns.py:139-155`; `donor_patterns.json` read: `version/source/note/donor_units/families/patterns`; 43 families, 282 patterns, per-pattern keys exactly `{w,h,cells}`; `swamp|lake` matches = 0 | `[O]` negative | No float grid, sculpt flags, object tail, or swamp/lake families exported |
| E07 | `pattern_gen.gd:56-63` (`load_data()` path); `game.gd:949,987,1245` | `[O]` | `donor_patterns.json` drives sim stamps only |
| E08 | `variant3d/assets/terrain/` = 2,358 files / 2,228,567,934 B (P02 §0.1, §2); `atlas/tile_index_atlas.png` 179,912,941 B, winter 124,463,306 B; `atlas_parts` 180,141,102 B; `decals_png` 462 PNG/901,912,125 B; `decals_dds` 462 DDS/635,045,712 B | `[O]` | Converted surface/decal mass inventoried and mostly dormant for 3D |
| E09 | `world3d_entities.gd:178-184,189-190,2097-2111,2114-2119,313-315,446-449,1498-1519,2351-2417` | `[O]` | sid pools, position-hash selection, field tint/decal availability; `TREE_STAND_STATUS="OPEN"` at `:189` |
| E10 | `game.gd:2729-2767` (7×7 sow, `step=1.6981*TILE*0.5`, clash `< 1.5*TILE` including earlier food); `pattern_gen.gd:391-426,430,484-485` | `[O]` | Port field contact defect and richness-cluster mine/stone placement persist |
| E11 | `water3d.gd:24-36,92,97,176-180,215-221,271-278`; `shaders/water3d.gdshader`; `world3d_terrain.gd:1089-1105,1461` (P02 §4) | `[O]` | Water module wired; `WATER_SURFACE_Y=-0.25` labelled PORT APPROX; reflection/current absent |
| E12 | `world3d_terrain.gd:786-867,1326-1385,1591-1602`; `atlas/tile_index_atlas.manifest.json:2284,2380,2404` (`sandsea1/5/6`); `tile_atlas_loader.gd:70` | `[O]` | Shore ids 93/97/98 and 8×45° sector table landed as tile art |
| E13 | `terrain/deco_png/envfieldd.png` 615,507 B / `envfielddw.png` 659,209 B; `terrain/decals_png/eur{coad,gold,irod}{,w}.png` six plates 2,292,802+2,388,054×3 ≈14.0 MB; `world.gd:767,775`; `winter_field_decal.gd:67-68` unwired | `[O]` | Decal assets exist; 3D UV/surface binding absent (2D branch only) |
| E14 | `tools/piece_specs/*.json` = **21** files / **960,987 B**; keys `name,size_px,seed,background,layers,reference…`; consumed by `tools/terrain_piece_render.py:226,1213-1341` (Python, not Godot); no swamp/lake spec | `[O]` | QA fixture schema, disjoint from runtime asset schemas |
| E15 | `prop_winter_materials.json` 36,024 B, `id=PW-1-MATERIAL-MAP`, 79 winter aliases (P02 :125); no `.gd` consumer | `[O]` negative | Winter material data-only |
| E16 | Fresh `pattern.lib` scan (this pass): 680 sections, 582 `HeightFieldStand=True`, 382 zero min/max, 200 nonzero; 71 section names match `swamp|lake`; `m_swamp_small_1` 16×13 min=max=0; `l_lake_big_1` 30×28 min=−2.13207483291626/max=+0.454261720180511; 86/282 exported patterns have nonzero min/max | `[O]`/`[D]` | Donor swamp/lake families are real; export coverage is incomplete |
| E17 | `D05_relief_stamp.md:17,23,85,139-171,U5`: grid allocated `(w+1)×(h+1)` floats; `h=(g−Min)*Scale+Min`; `Max` not read; `HeightFieldScale=-0.925` inverts grid; byte boundary ±24–160 B `[U]` | `[O]` prior binary evidence | A04's `w*h` window and clamp model are not donor-exact; I02 must cross-check |
| E18 | `F02_pattern_lib.md:17-53,E18`: plaintext DB, 1,172,417 lines, 680 sections, 39,780 object records, 235 BaseNames, 64 `generator.cfg` families/493 refs, 12 bit-exact grid cross-checks | `[O]` prior report | Section/family metadata gap is closed by F02, not the export gap |
| E19 | `IMPLEMENTATION_PLAN.md:9-21` (I02 `decode_donor_pattern.py`, I03 `decode_pattern_lib.py`, I05 `build_terrain_new_atlas.py`, I09 props, I12 QA); `11_ASSET_CONVERSION.md:40-50,57-59`; `Test-Path variant3d/assets/terrain_new` = False | `[O]` | No fresh-root artefacts exist yet; export tools are unwritten |
| E20 | `P03_gates_capture.md:18-26,82-111`: gate commands specified, on-disk JSONs stale, 8 capture tools byte-identical to `app/` and hardcoded `--path app`, no fresh 240²/320² baseline | `[O]` prior report | Capture readiness is a separate gate; V07 ran none |
| E21 | `SWARM_BOARD.md:16,22-23` and final `reports/` listing: F01/F07/F08 absent; F02 landed 2026-11-26 09:07:49; P02 landed 09:18:58 (first V07 read returned FileNotFound, second pass succeeded) | `[O]` | Ticket scope known; report availability is time-sensitive |

---

## 3. Converted-asset / schema ledger

All sizes are bytes from this pass unless attributed to P02. `.import`/`.uid` sidecars are
excluded from the per-file numbers below (P02's family totals include them).

| Artifact / schema | Exact path(s) | Count / size | Schema fields | Godot consumer (file:line) | QA / capture | Label |
|---|---|---|---|---|---|---|
| Relief geometry | `variant3d/assets/models/obj/shared/terrain/terrainmesh{1..4}.obj|.mtl` | 4 OBJ + 4 MTL, 1,145,584 B | OBJ raw donor units, Z-up; `manifest.kind="relief"`, bbox `[xmin,xmax,ymin,ymax,zmin,zmax]` | `world3d_relief.gd:43,51,318-338`; `asset_paths.gd:15` | none for relief props | `[O]` |
| Relief albedo | `variant3d/assets/models/tex/shared/terrain/terrainmesh{1..4}.png` | 4 × 2048² RGBA, 31,397,328 B | donor `terrainmeshN.dds` conversion | `world3d_relief.gd:16-19` via manifest | none | `[O]` |
| Mountain prop table | `variant3d/assets/terrain/mountain_props.json` | 66,519 B; 30 sections, 112 records | `version,source,source_sha256,selection,labels,bbox_m,bbox_m_note,by_pattern,pattern_meta,props,derived_stats`; record: `base,sid,px,py,pz,dx,dy,dz,ux,uy,uz,yaw_deg,yaw_deg_raw,sx,sy,sz,line` | `world3d_relief.gd:42,149-201` | **absent** (E05) | `[O]` |
| Pattern occupancy | `variant3d/assets/terrain/patterns/donor_patterns.json` | 982,264 B; 43 families, 282 patterns | `version,source,note,donor_units,families,patterns`; pattern = `w,h,cells` only | `pattern_gen.gd:56-63` | `t_map_variety.json` (generic, 11/25) | `[O]` |
| Surface atlas | `variant3d/assets/terrain/atlas/tile_index_atlas{,_winter}.png|.manifest.json`, `alpha.png`, `alphavert.png`, `winter_aliases.json`, `desert_remap.json`; split parts in `atlas_parts/` | 304,844,245 B + 180,141,102 B (P02) | 16×8 index grid, 124 named cells, sandsea1=93/5=97/6=98 | `world3d_terrain.gd:273,597-619,649`; `tile_atlas_loader.gd:66,70,80,485` | `t_terrain_shore.json`, `t_season_overlay.json` (stale 11/25) | `[O]` |
| Masks | `variant3d/assets/terrain/masks/**` (56 PNG, 320² RGB); `masks/manifest.json` | 913,631 B (P02) | `R=relief,G=forest/stone,B=water,white=start` | `mapgen.gd:36,162,168`; `game.gd:1174` | `t_map_variety.json` | `[O]`/channel `[I]` |
| Field mesh + decals | `variant3d/assets/models/obj/shared/terrain/field.obj|.mtl`; `tex/shared/terrain/field.png`; `deco_png/envfieldd.png|,envfielddw.png` | OBJ+MTL 44,621 B; field.png 48,365 B; decals 1,274,716 B | donor 512² DXT5 decal → RGBA PNG; 3D UV not decoded | `world3d_entities.gd:313-315,446-449,1498-1519`; `game.gd:2729-2767` | `t_mill_logic.json`, `t_mill_rotor.json` (stale 11/21-23) | `[O]`; UV `[U]` |
| Mine deposits / buildings / plates | `obj/shared/terrain/mine_gold|iron|coal` absent; deposits are `obj/…` env sids + `tex/shared/buildings/mine_{gold,iron,coal}.png` 15,905,976 B; buildings `obj/shared/buildings/mine_{gold,iron,coal}.obj|.mtl` 276,888 B; `decals_png/eur{coad,gold,irod}{,w}.png`, `decals_dds/*.dds` six plates | manifest mine sids=3; six plates ≈14.0 MB | donor disc baked into albedo; no separate apron asset | `world3d_entities.gd:190,2103-2104`; `world.gd:767,775` | `t_mines_place.json`, `t_mine_build.json` (stale) | `[O]` |
| Forest / understory | `obj/shared/terrain/tree_*.obj|.mtl` 46 files/1,265,480 B; `tex/shared/terrain/tree_*.png` 23/13,201,550 B; `tex/shared/terrain/{bush,fern,reed,plantain}*.png` 14 files/4,050,921 B; sprites + sprites_hi companions | 25 tree manifest sids (23 terrain-relevant), 4 bush, 4 fern, 3 reed, 3 plantain | envscales authored scale; no per-object yaw in sim | `world3d_entities.gd:178-184,2099-2111`; `TREE_STAND_STATUS` `:189` | `t_forest_bake_render.png`, `t_terrain_trees.json` (stale) | `[O]` |
| Stone / shore rock | `obj/shared/terrain/{rock,stone,rock_*}.obj|.mtl` 88 files/1,120,880 B; `tex/shared/terrain/*rock*.png` 2048² albedos | manifest rocks/stones 44 sids; only 5 in `POOL_ROCK` | envscales 0.329 ±15% | `world3d_entities.gd:182,609-610,2101-2102`; `pattern_gen.gd:430,484-485` | generic terrain captures only | `[O]` |
| Water | `shaders/water3d.gdshader` 15,809 B; `shaders/water_overlay.gdshader` 15,779 B; `water_png/diffusewaves0..7.png` 8 files/2,743,445 B | wave0 wired in 3D, 1–7 dormant | height texture + shader uniforms; `water_surface_y` placeholder | `water3d.gd:24-36,92,97,176-180,215-221`; `world3d_terrain.gd:1089-1105,1461` | `t_water.json`, `t_shore_smoke.json` (stale) | `[O]`/visual `[U]` |
| Winter aliases | `variant3d/assets/terrain/prop_winter_materials.json` | 36,024 B, 79 aliases | `PW-1-MATERIAL-MAP`, donor `env.mat:815-1551` | **none** | none | `[O]` |
| QA fixtures | `variant3d/tools/piece_specs/*.json` (21: hill_ridge, plateau, ravine_face, shore_*, water_*, field_crops, forest_*, mines_display, bushes_understory, stones_rocks, winter_variant, …) | 960,987 B | `name,size_px,seed,background,layers,reference,native_render…`; *not* a runtime schema | **no Godot**; `tools/terrain_piece_render.py:226,1213-1341` | headless piece PNGs in `%TEMP%`, e.g. `almanac_*`, not acceptance gates | `[O]` |
| Fresh compiler output | `variant3d/assets/terrain_new/**` | **ABSENT** | spec target: `manifest.json,schemas/v1.schema.json,atlas/,patterns/,masks/,cfg/` | none yet | none | `[O]` negative |

---

## 4. Per-class readiness ledger

Status key: **ASSET-READY** = converted + static consumer, visual `[U]`; **PARTIAL** =
assets exist but the donor rule or binding is missing; **DATA-GAP** = derived data not
exported; **NONE** = no literal donor/port asset. No row is a parity claim.

| Class | Converted assets (exact paths, counts/sizes) | Schema | Consumer (file:line) | QA / capture | Status & precise gap blocking use |
|---|---|---|---|---|---|
| **Hills / plateaus / ravines** | `donor_patterns.json` families `hills_dark/light`, `plateau*`, `ravine_*` (cells only, 982,264 B); `blocks/*.png`, atlas; no float window on disk | `{w,h,cells}`; exporter `export_donor_patterns.py:139-155` | `pattern_gen.gd:56-63,571-589`; `world3d_terrain.gd:131,1515` | generic `t_terrain_only.json`; no donor-window histogram | **DATA-GAP.** No `f32` grid / `HeightFieldScale` / `Replace` flags exported; port uses analytic domes `PORT APPROX`. `w*h` vs `(w+1)*(h+1)` (E17) and negative-scale semantics unresolved → I02 after F01; D05 refutes port clamp model (`:17`). |
| **Mountains** | 4 OBJ+MTL (1,145,584 B), 4 albedo PNG (31,397,328 B), `mountain_props.json` 66,519 B / 112 records | `by_pattern`, `props[pattern]=[{base,sid,px,pz,yaw_deg,sx,line,…}]`, `derived_stats` | `world3d_relief.gd:42,149-246`; `world3d.gd:614,650,691` | **none**: no result JSON, no Z07 PNG, no mountain fixture | **ASSET-READY but UNPROVEN.** QA atom stale path (`:30`), node type (`:317`), scale expectation (`:42`) and stamp count (`:347`); only 22 of 45 "port-stampable" records use a converted sid — 23 desert records hit `skipped_unknown_sid` (`world3d_relief.gd:166-167`). Desert/winter/plateau sids absent. Selection/yaw `PORT APPROX`. Fresh module must own a props stage (I09) and be QA'd (I12/COORD). |
| **Mill fields** | `field.obj|.mtl` 44,621 B, `field.png` 48,365 B, `envfieldd/w.png` 1,274,716 B; mill stage OBJs 10× | mesh+PNG; decal PNG has no 3D UV schema | `world3d_entities.gd:313-315,446-449,1498-1519,2351-2417`; `game.gd:2729-2767` | `t_mill_logic.json`, `t_mill_rotor.json`, stale mill crops | **PARTIAL.** 3 m clash at `game.gd:2755` blocks donor-style touching 49-node patches; decal paths recorded in stats only, UV `[U]`; **no `pump` sid in manifest** (verified 0 hits) → F07 catalogue, then I02/I03 if pump family is in scope. |
| **Sea** | `shaders/water3d.gdshader` 15,809 B, `water_overlay.gdshader` 15,779 B, `water_png/diffusewaves0..7.png` 2,743,445 B | shader uniforms + height texture | `water3d.gd:24-36,92,97,176-180,215-221`; `world3d_terrain.gd:1089-1105,1461` | `t_water.json`, `t_shore_smoke.json`, legacy crops; no fresh 240²/320² baseline | **PARTIAL.** Reflection off, swell zero, non-donor `water_cell` alpha cut, `water_surface_y=-0.25` PORT APPROX (`:32-36,271-278`); foam width `[U]`; needs fresh module recomposition (I08/I10) + capture (I13), not new donor art. |
| **Shore** | atlas 179,912,941 B + winter 124,463,306 B + alpha masks; `sandsea1/5/6` ids 93/97/98 at `tile_index_atlas.manifest.json:2284,2380,2404`; `rock_sea*` albedos | 16×8 atlas, 8×45° sector table | `world3d_terrain.gd:786-867,1326-1385,1591-1602`; `tile_atlas_loader.gd:70` | `t_terrain_shore.json`, `t_combo_shore_mines.json` (stale) | **ASSET-READY, appearance `[U]`.** Substrate gate `mask.b>0` equivalent `[U]`, collar widened only as `PORT APPROX`; fresh root `terrain_new/` absent → new module needs I05 atlas tier and shared `height[]` with water, else seam drift. |
| **Forests** | 46 tree OBJ/MTL (1,265,480 B), 23 tree PNG (13,201,550 B), bush/fern/reed/plantain PNG 14 files (4,050,921 B), sprites_hi companions | manifest env sid + bbox; no authored yaw in sim | `world3d_entities.gd:178-184,2097-2111`; `TREE_STAND_STATUS` `:189` | `t_forest_bake_render.png`, `t_terrain_trees.json`, `t_combo_trees_*.json` | **PARTIAL.** Only 18 tree sids in `POOL_TREE`, yaw always 0 (`:188`); no decor stand layer (`:189`); forest `Objects` records not exported → F08 weights/records + I02 object lists + I09 decor layer. Fern/reed/plantain have **no placement consumer**. |
| **Stone quarries** | 44 rock/stone manifest sids; `obj/shared/terrain/{rock,stone,rock_*}` 88 files/1,120,880 B; `tex/shared/terrain/*rock*.png` | env sid + scale 0.329 ±15% | `world3d_entities.gd:182,609-610,2101-2102`; `pattern_gen.gd:430,484-485` | generic terrain captures only | **PARTIAL.** No literal "quarry" donor asset (A04 E26; F06 negative scan); owner term maps to `stones`/`stoneforests` `[D]/[I]`. Only 5 sids wired; no donor-record clump layer; record→prop binding `[U]` → F08 + I03. Do not invent a quarry mesh. |
| **Gold / iron / coal mines** | 3 deposit meshes + `tex/shared/buildings/mine_{gold,iron,coal}.png` 15,905,976 B; 3 mine building OBJ/MTL 276,888 B; 6 `eur*coad/gold/irod{,w}` decal PNG+DDS | manifest sid `mine_*` (kind=building) + baked disc; decal PNG `512² RGBA` | `world3d_entities.gd:190,2103-2104`; `game.gd:1353-1359`; `world.gd:767,775` (2D decal) | `t_mines_fix`, `t_mines_place`, `t_mine_build`, `t_mine_unified`, `t_combo_shore_mines.json` | **PARTIAL.** Placement is richness clusters with 11-tile separation (`pattern_gen.gd:391-426`), not donor 3/4/5 rings; 1.5-cell magnetic snap absent from `game.gd`; disc is baked into albedo (no missing apron, do not strip); record→prop mapping `[U]` → F08/I03, runtime I09. |
| **Swamps** | None in `donor_patterns.json` (0 matches); bush1..4/fern1..4/reed1..3 PNG converted but unplaced; donor `pattern.lib` sections present (71 swamp|lake names) | donor `m_swamp_small_1` 16×13, `HeightFieldMin=Max=0`, Objects `bushes/fern` (E16) | none (no stamp consumer, no QA seam) | none | **DATA-GAP.** Family masks + `Objects` lists absent; swamp must be tile patch + props with **no water plane** (zero donor grid). I02 after F01; no fabricated height/water allowed. |
| **Lakes** | None in `donor_patterns.json`; water shader/plane reusable; donor `l_lake_big_1` 30×28 window −2.1320748…+0.4542617 (E16) | donor float window + `grass.1`/`pinesmall1` objects; `HeightFieldReplaceForWater=False` (A04 E21) | none for lake families; water shader at `water3d.gd:92` | `t_water.json` only (no lake fixture) | **DATA-GAP.** No exported family/window, so no depression + shore seam; `lake_big := plain*2*0` literal zero (A04 E20) is `[O]` anomaly — do not "fix" without donor binding. I02 after F01. |
| **Decor** | `decor`, `decor_big`, `tiles` families in `donor_patterns.json`; `groundexp0..3.png` + `christmastreed.png` (7 PNG, 4,841,580 B, 6 unused); `dmask/d_00..23.png` 24-step alpha ramp unused | `{w,h,cells}` families; dmask RGBA ramp | `world3d_entities.gd:183` (bush pool only); no decor consumer | none | **PARTIAL/DATA-GAP.** No `d_tls_*` object-list export, no `Objects` records, no placement/stats seam; 25-cell mask-blocking side effect `[U]` (A04 E10-10). I02/I03 + I09; reuse existing alpha ramp, do not add noise/dither. |

---

## 5. Gap → ticket mapping

### 5.1 Knowledge gaps addressed by today's F-wave reports

| Gap | Ticket | Status at final V07 pass | What it closes / does **not** close |
|---|---|---|---|
| `.pattern` float-window byte boundary, object tail, relief grid sample count | **F01** | **NOT LANDED** (`reports/` listing; board `SWARM_BOARD.md:16`) | Will resolve `w*h` vs `(w+1)×(h+1)` (E17) and ±24–160 B ambiguity; supplies decoder prototype. Does **not** write `terrain_new/**`. |
| `pattern.lib` records/families/weights, mine object binding | **F02** | **LANDED** 09:07:49 | Closes plaintext layout, 680 sections, 39,780 object records, 64-family/493-ref catalogue, mine props inside `mng/mni/mnc` (`F02:17-53,E18`). Does **not** export any derived asset. |
| Mill / field / pump donor families, decal semantics | **F07** | **NOT LANDED** (`SWARM_BOARD.md:22`) | Will close donor-side pump/field catalogue and clarify the 0-pump-sid port gap; does not fix 3 m clash or 3D UV. |
| Forest / stone / mine families, object contents, weights, record→prop binding | **F08** | **NOT LANDED** (`SWARM_BOARD.md:23`) | Will close the donor-side weight/binding gaps behind forest stands, stone clumps and typed deposits; does not emit JSON. |

### 5.2 Asset-emission gaps requiring implementation tickets

| Gap blocking use | Ticket | File / output |
|---|---|---|
| No float windows, sculpt flags, `Objects` lists for relief/forest/stone/mine/swamp/lake/decor families | **I02** (`IMPLEMENTATION_PLAN.md:10`) | `variant3d/tools/decode_donor_pattern.py` → `assets/terrain_new/patterns/families/*.json` with `relief_float_grid:null`→decoded and `object_list` (`11_ASSET_CONVERSION.md:57-59`). Depends on F01. |
| No family index / weights / blend flags / 112+ record catalogue in fresh root | **I03** (`:11`) | `variant3d/tools/decode_pattern_lib.py` → `terrain_new/patterns/family_index.json`; consumes landed F02 layout. |
| Fresh atlas + alpha + winter aliases unavailable (`terrain_new/` absent) | **I05** (`:13`) | `variant3d/tools/build_terrain_new_atlas.py`; shore/field/mine-decal tile transport and mip fix (`11_ASSET_CONVERSION.md:26,29`). |
| Converted props need a fresh consumer (render-only, stats seam) | **I09** (`:17`) | `variant3d/scripts/terrain_donor_props.gd` — hills/mountains/fields/forests/stones/mines/shore rocks/swamp decor. |
| Water/shore mesh+shader seam, tile selection for fresh height field | **I08/I10** (`:16,18`) | Fresh mesh/shader modules; no new donor art needed for sea/shore. |
| Z07 atom mismatch, lack of fixture and no props ON/OFF capture | **COORD + I12/I13** (`:20-21`) | Reconcile `t_relief_props_qa.gd:30,42,82,317,347`; create `small_map_64_mountains.json`; windowed capture. **No F/I export ticket closes this.** |

**[D] Bottom line:** F01/F07/F08 close *what the donor contains*; I02/I03/I05 close
*what the fresh module can load*. Both halves are required — a landed F-report without
an I-tool leaves `assets/terrain_new/` absent and every DATA-GAP row unchanged.

---

## 6. Risks

| # | Risk | Evidence / label | Mitigation |
|---|---|---|---|
| R1 | Treat 112 prop records as "112 rendered mountains" | E03/E05 `[O]` | Only 45 records are stampable; 23 of those use unconverted desert sids; count `skipped_unknown_sid` (`world3d_relief.gd:167`). |
| R2 | Reconcile QA by weakening it (rename path only, accept scale 1) | E05 `[O]` | Strengthen: reconcile node type to MultiMesh, authored scale, per-stamp N records, and mountain fixture; never vacuous PASS. |
| R3 | I02 hard-codes `w*h` grid length | E06/E17 `[O]` conflict | Cross-check `(w+1)*(h+1)` allocation against donor bytes and F01; mark ±24–160 B `[U]` until bit-exact. |
| R4 | Invent relief values or "fix" `lake_big:=plain*2*0` | A04 E20, `11_ASSET_CONVERSION.md:14-17` | Emit `null`+`UNVERIFIED` for undecodable fields; preserve literal frequency. |
| R5 | Reuse dormant 1.54 GB decals as terrain surface art | P02 §F7, E08/E13 `[O]/[I]` | They are building dirt plates; only field/wave/alpha/dmask families are surface-relevant. |
| R6 | Double-render trees (res nodes + new decor layer) | E09, A04 R6 | Key decor layer by distinct stamp names/group; A/B must show one silhouette. |
| R7 | Fresh shore/water drift because tile classification and shader use different `height[]` | E11/E12, A04 §4.5 `[I]` | Share one grid; record ids 93/97/98 in new stats; no widened collar without label. |
| R8 | Capture tools silently boot `app/` | P03 §3.1, E20 `[O]/[D]` | Use COORD-owned explicit paths; reject mixed-aperture PNGs as fresh evidence. |
| R9 | Report based on stale inventory (P02 landed mid-pass) | E21 `[O]` | V07 re-read after landing; all P02 numbers quoted from the landed file. |
| R10 | Claim parity from "converted" | CHARTER.md:57-58, E20 | No GPU A/B exists; every acceptance cue is internal/`PORT APPROX`. |

---

## 7. UNVERIFIED register (do not promote)

1. Whether the Z07 atom currently fails, and at which check, without running Godot (V07 ran none).
2. Whether the landed MultiMesh props actually produce a visible hill silhouette at any seed (no PNG, no result JSON).
3. Native `StandPatternWithAngle` transform math, runtime choice among multiple `terrainmeshN` per stamp, yaw sign, metres-per-unit (`world3d_relief.gd:21-35`).
4. Exact on-disk float-grid byte boundary / sample count (`w*h` vs `(w+1)*(h+1)`, ±24–160 B).
5. Whether all 200 sections with nonzero lib min/max (86 of them exported) have usable float windows in their `.pattern` files; only ~26 were bit-verified.
6. Winter/desert relief assets and `terrainplateau1..4` authoring (no albedo/.prop/BaseName links).
7. 3D UV/epsilon binding of `envfieldd/w` and `eur*` dirt plates; whether `world.gd:775` executes in 3D mode.
8. Mine stamp record-id → prop mapping; `minegold` vs `minegolds` terrain selection; stone clump record binding.
9. Activation of donor `[*] = ;`-prefixed `.inc` lines (authoritative text only, A04 E15/E16/E20).
10. `lake_big` zero-frequency anomaly cause; whether skirmish seeds ever place swamp/lake stamps.
11. Donor water surface Y, reflection target, foam pixel width; any donor GPU frame.
12. `mask.b>0` shore-substrate binding and the 25-cell `d_tls_*` mask-blocking side effect.
13. Whether the three atlas transports resolve under this machine's Godot; 180 MB single-atlas decode unproven (P02 R2).
14. Whether F01/F07/F08 land before I02/I03 are written; if not, I02 must emit `null`+UNVERIFIED and stop rather than guess.

---

## 8. Multiple-pass register (anomalies re-examined per CHARTER.md:88-93)

| # | Anomaly | Pass 1 | Pass 2 / resolution | Accepted reading |
|---|---|---|---|---|
| M1 | P02 report missing at first read | `read` returned `FileNotFound`; V07 proceeded with direct disk scans | Later `reports/` listing showed `P02_asset_inventory.md` 30,615 B @09:18:58; re-read §0–§6 | `[O]` P02 landed mid-sweep; its numbers supersede ad-hoc folder totals where they include sidecars |
| M2 | "26 decoded float windows" vs donor section counts | A04 E02/§4.1 states 26 windows; direct scan found 582 `HeightFieldStand=True` and 200 nonzero | Second scan restricted to the 282 exported names → 86 nonzero; cross-read D05 `:85` `(w+1)*(h+1)` | `[D]` 26 = bit-verified subset; 86/200 = lib metadata candidates; grid length conflict stays `[U]` for I02/F01 |
| M3 | Mountain QA "never run" vs atom exists | File `t_relief_props_qa.gd` present (35,522 B) | Checked result dir, CAP_DIR, fixture dir, atom constants and consumer node type/scale | `[O]` atom materialised but incompatible/stale; `[U]` runtime outcome |
| M4 | "112 records" vs 45 stampable | `mountain_props.json` `records_total=112` | Per-sid census over the 20 stampable sections: 22 terrainmesh + 23 terrainmeshdesert records | `[D]` only 22/45 can render today; desert records increment `skipped_unknown_sid` (consumer `:166-167`) |
| M5 | Field/mine "assets converted" vs "field/mine missing" in old reports | Manifest + PNG/OBJ present | Static consumer grep: field decal stats-only; mine decal 2D-only; placement rules divergent | `[O]` asset readiness ≠ feature readiness |
| M6 | `terrainmesh_props.json` path in QA vs `mountain_props.json` on disk | `Test-Path` False | Grepped all `.gd`: only atom uses stale name; consumer uses live name | `[O]` interface mismatch, not a missing asset |

---

## 9. Open questions

1. Will COORD re-derive mountain/forest/stone/mine props with I02/I03, or adopt Z08's
   `mountain_props.json` verbatim for the fresh module? (A04 Q1; changes the QA contract.)
2. Which ticket creates `small_map_64_mountains.json` / a 320² mountains fixture, and who
   is allowed to run the windowed Z07 atom? (A04 Q2; only COORD/G04 submits jobs.)
3. Should the donor 49-node field rule replace the 3 m clash in the fresh module, and
   what label accompanies the owner's four-patch quad if it is kept? (A04 Q3.)
4. Does F07 confirm a donor pump family that needs conversion, given 0 `pump` sids on disk?
5. Does F08 supply a record-id→prop binding for stone/mine clumps, or does the fresh
   decor layer remain `PORT APPROX` for this wave?
6. Are DLC5 `lakes`/`rivers` masks in scope? Without a separate mask export, rivers stay
   out-of-scope `[U]` (A04 Q5).
7. How will I05 choose a commit-safe atlas tier without importing the 180 MB single PNG
   into the fresh root (P02 §F6; `11_ASSET_CONVERSION.md:52-55`)?

---

## 10. Claim register

| # | Claim | Evidence | Label |
|---|---|---|---|
| 1 | `terrainmesh1..4` converted, table present, consumer wired, QA absent | E01–E05 | `[O]`/`[U]` |
| 2 | Relief float windows + object lists not exported; `terrain_new/` absent | E06, E19 | `[O]` negative |
| 3 | Swamp/lake donor families real but absent from port export | E16, E06 | `[O]` |
| 4 | Field/stone/mine/tree/rock/water/decal assets converted, rules divergent | E09–E13, E15 | `[O]`/`[D]`/`[U]` |
| 5 | F02 closes metadata; F01/F07/F08 not landed; I02/I03/I05 needed to emit assets | E18, E21, §5 | `[O]` |
| 6 | QA atom is stale on path, node type, scale and fixture | E05, M3/M6 | `[O]` |
| 7 | No donor parity claim; no GPU A/B frame | E20, CHARTER.md:57-58 | `[U]` |

*End of V07. Design/read-only verification only; no source, asset, config, test, shader,
fixture, runner-job or git edit; no donor binary executed or copied; no donor parity claim.*
