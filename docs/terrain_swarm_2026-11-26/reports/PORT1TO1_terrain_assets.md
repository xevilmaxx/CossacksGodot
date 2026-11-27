# PORT1TO1 — Landscape/terrain asset coverage audit (read-only)

- id: PORT1TO1-TERRAIN-ASSETS
- swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
- role: "WORKER TERRAIN-ASSETS — read-only audit of landscape-asset coverage (forests, trees, bushes, grass, fields/farms, stones/rocks, decorative props, AAF/FX, death art, tool/attachment skins, all additional asset tiers)"
- owner_file: `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_terrain_assets.md`
- status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_ASSET_GODOT_GIT_DONOR_EDIT
- created: 2026-11-27
- labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
- parity_guard: "Parity UNVERIFIED. Chain 0/6. Nine P0 OPEN. RESULT IS NOT GOOD while blocking_unverified non-empty. No donor GPU A/B frame exists; no donor binary was executed, no donor file copied, no port byte changed. Every donor statement is a read-only report/spec line citation carried from landed reports; every port statement is a read-only on-disk observation verified this pass unless marked carried. No completeness is declared; no parity is claimed; no approximation is endorsed."
- scope_guard: "Exactly one repo file written (this report). No code, asset, config, shader, test, runner, Godot, git or donor edit. Donor tree read status: `Test-Path C:\\Games\\Cossacks 3` = True this pass, but no donor file was opened by this worker; all donor facts are carried from landed reports with ids cited."
- method: "Read-only: `Get-ChildItem`/`Test-Path`/`Select-String`/`Get-Content`/`python json.load` over `variant3d/assets/**`, `variant3d/scripts/terrain_donor_props.gd`, `variant3d/scripts/world3d_fx.gd`, `variant3d/scripts/anim3d.gd`, `variant3d/scripts/world3d_entities.gd`, `variant3d/tools/*`, derived JSONs under `variant3d/assets/terrain_new/**`, donor-derived inventory in `docs/terrain_swarm_2026-11-26/spec/**` and landed reports. Each count below is tagged [V] = verified on disk this pass, or [C] = carried from a cited report (not re-verified)."
- prior_reports_read:
  - `docs/terrain_swarm_2026-11-26/reports/DEC_U_aaf_art_audit.md` (194+52 AAF, 66-skin census, 8 requested actions at audit time)
  - `docs/terrain_swarm_2026-11-26/reports/DEC_U_tool_attach.md` (56 attach .oss, 8 nations x 7 tools, T-A/T-B open)
  - `docs/terrain_swarm_2026-11-26/reports/DEC_U_death_families.md` (eurmil-only conversion at audit time, 11 families open)
  - `docs/terrain_swarm_2026-11-26/reports/X27_decode_coverage.md` (coverage ceiling: 22.54%/54.7% garbled, 23/34 anchors absent, runtime UNVERIFIED)
  - `docs/terrain_swarm_2026-11-26/reports/X16_prop_mesh_coverage.md` (141 BaseNames: 75 exact OBJ / 3 fallback / 63 missing; COMPLETE 0/141)
  - `docs/terrain_swarm_2026-11-26/reports/V62_asset_completeness.md` (780 files point-in-time; atlas/masks/lib/schema absent then)
  - `docs/terrain_swarm_2026-11-26/reports/V66_asset_gap_final.md` (M01–M10 gap ledger; I09 feed path mismatch V66-F1/F3)
  - `docs/terrain_swarm_2026-11-26/reports/V89_final_asset_seal.md` (5257 files / 364,646,949 B snapshot; I09 feed FAIL still open)
  - `docs/terrain_swarm_2026-11-26/reports/V97_final_counts.md` (162 board IDs, 127 reports, 5,255-file derived-assets freeze)
  - `docs/terrain_swarm_2026-11-26/reports/DEC_DEEP_prop_efficiency.md` (sub_755f30 prop loop anchor; no Random edge in 662 calls)
  - `docs/terrain_swarm_2026-11-26/HANDOFF.md` (class table, blocking_unverified non-empty, RESULT IS NOT GOOD)
  - `docs/terrain_swarm_2026-11-26/spec/08_FIELDS_AND_PROPS.md`, `spec/11_ASSET_CONVERSION.md`, `spec/00_EVIDENCE_INDEX.md`

## 0. Headline counts (all [V] this pass unless noted)

| Metric | This pass [V] | Landed-report value [C] | Delta / note |
|---|---|---|---|
| `variant3d/assets/terrain_new/**` files | 5339 files / 383,192,189 B | V89: 5257 / 364,646,949; V62: 780 / 242,316,351; V97: 5,255 / 302,411,732 | Pack keeps growing; point-in-time only |
| `props/families/*.json` | 77 | V62/V75: 64; X16-era: 29 families resolving | +13 family files since V62 [V] |
| `props/props_index.json` | record_count 39783, distinct_basenames 235, family_count 77, section_count 668 | F02/X05: 39,780 object records, 235 BaseName, 680 sections | Basenames match (235); sections 668 vs 680 = 12 sections unaccounted in index |
| `skin/index.json` | count 66, entries 66, skipped 7, actions list 40 names | DEC_U_aaf_art_audit: count 66, actions_requested 8, 7 skipped | Actions list grew 8 -> 40 [V]; supersedes audit A1 census |
| `skin/attach/*.json` tool skins | 63 files | "63 tool skins" task figure | Confirmed 63 = 9 peasant sids x 7 tools [V]; 57/66 entries attach=None |
| `anim3d.gd` T-table | T1–T26 present | T22 note carries DEC_U_tool_attach refutation | T1–T26 are animation-state families, not terrain tiers |
| `assets/terrain/blocks/` | 224 entries (112 PNG + 112 .import) | terrain_donor_props.gd:65 cites "112 PNGs (V07 E08)" | 112 PNGs confirmed [V] |
| `assets/terrain/deco_png/` | 14 entries (7 PNG + 7 .import) | FIELD_OBJ + envfieldd/envfielddw cited in props script :67-70 | Field decals present [V] |
| `assets/terrain/grass*.png + ground + rock` | grass1-10, grasssand1-2, ground1-3, rock1-3, rockgrass1, dirt1 (each + .import) | — | Present [V]; donor-grounding unwired |
| `BLD_DEATH_STEMS` | 12 families (mil/cen/hou/bar/sta/bla/aca/art/dip/sto/mar/tow) | DEC_U_death_families: 1 stem (mil only) | Expanded 1 -> 12 [V] |
| `assets/terrain_new` tier dirs | atlas/ PRESENT, cfg/ 3, lib/ 1, masks/ 4467, props/ 78, schemas/ PRESENT, manifest.json PRESENT | V62: atlas/masks/lib/schemas/manifest all ABSENT | All V62-absent tiers now present [V] |

## 1. Per-class ledger

### 1.1 Forests / trees (conifer, mixed, deciduous)

- (a) IMPLEMENTED [V]: `variant3d/assets/terrain_new/props/families/` carries forest families on disk: `d_frt_big/mid/small.json`, `d_frt_spr_big/mid.json`, `d_frt_pinedry_big.json`, `e_frt_big/mid.json`, `frt_b_p/frt_m_p/frt_s_p.json`, `g_frt_big/mid/small.json`, `n_small_frt.json`, `n_small_frt_lite.json`, `n_desert_frt_big/m/s.json`, `desert_frt_big/m/s/un.json`, `f1_from_big.json`, `fb.json` (53 entries), `str.json`, `str_new.json`, `b_frt_b_p.json`; `props_index.json` record_count 39783 / 235 basenames / 668 sections [V].
- (b) REPORTED-ONLY or STUB [C]: F08 catalogues 19 forest families with footprints up to 86x92 and Freq roulette damped x0.2 (`misc.script:3588-3629`, pass rates 0.0009/0.0009/0.00054 per spec/08 A7); X16: only 75/141 BaseNames have exact converted OBJ, 3 oak fallback, 63/141 missing; COMPLETE 0/141 with all four gates [C, X16 A1-A6].
- (c) ABSENT or DEGRADED: 63/141 BaseNames have no converted OBJ and no GLB/GLTF under `models/obj/**` [C, X16 A1]; no forest OBJ transform export existed in `mountain_props.json` (0 hits for pine1/stones/palm/leaftree/grassforest/drytree/smallstones/frt_/stn_/mng_/mni_/mnc_/d_stn/e_frt) [C, X16 A3]; winter albedo for all 141: no converted winter texture, `prop_winter_materials.json` data-only and unwired [C, X16 A5].

### 1.2 Bushes / grass / ground cover

- (a) IMPLEMENTED [V]: ground-cover PNGs on disk under `variant3d/assets/terrain/`: `grass1..grass10.png`, `grasssand1-2.png`, `ground1-3.png`, `rockgrass1.png`, `dirt1.png` (each + `.png.import`) [V]; family JSONs include grass/plantain records (e.g. `g_frt_big.json` sections carry `plantain.2`, `grass.4` with Position/Direction/Up/Scaling) [V].
- (b) REPORTED-ONLY or STUB [C]: HANDOFF A4 swamp/lake fringe (reed/bush/fern, no water plane) is tier-1-prepared but tier-2-unobserved [C].
- (c) ABSENT or DEGRADED: no evidence on disk that grass/plantain PNGs are wired to the donor `grass.4`/`plantain.*` BaseName records — no mapping file found (`grep prop_winter_materials.json` covers only relief names; no grass material manifest found) [V-gap, see A6 NEW-3].

### 1.3 Fields / farms (mill fields, envfield decals, field.obj)

- (a) IMPLEMENTED [V]: `variant3d/assets/models/obj/shared/terrain/field.obj` path constant FIELD_OBJ (`terrain_donor_props.gd:66`) [V]; `variant3d/assets/terrain/deco_png/envfieldd.png`, `envfielddw.png` (+ .import) PRESENT [V]; X22 verbatim `_unit_DoSeedWheat` translation carried [C].
- (b) REPORTED-ONLY or STUB [C]: spec/08 A4 — mill fields are decals not tile ids; placement PORT APPROXIMATION until F07/F08/D07 land; HANDOFF A4 — golden L/parcels with windmill footprint, tier-2 unobserved [C].
- (c) ABSENT or DEGRADED: field/mine placement runtime (`StandPatternWithAngle` yaw/units, `_unit_DoSeedWheat` activation) has no QA atom result [C, HANDOFF A3]; `SetupStartingResources` carries no food rects (fields mill-seeded) [C, HANDOFF A4].

### 1.4 Stones / rocks / quarries

- (a) IMPLEMENTED [V]: `d_stn.json`, `desert_stn.json`, `k_rock.json`, `k_ravine_big_stone.json`, `k_ravine*.json`, `big_hill.json`, `k_small_plain.json` family files PRESENT [V]; rock PNGs `rock1-3.png`, `rockgrass1.png` PRESENT [V].
- (b) REPORTED-ONLY or STUB [C]: F08 5 stone families; `stn1=0.00016/stn2=0.00012`, scale 0.329 +/-15% (A04 E20/E23/E26); HANDOFF: "No donor asset named `quarr` (0 hits)" — quarry-to-`stones` mapping is [D]/[I] [C].
- (c) ABSENT or DEGRADED: 15 desert-stone BaseNames use a different donor material than converted (`stonesdesert*` -> `stones.dds`, `desert ores` -> base ore DDS) [C, X16 A5]; `desert_frt_un.json` (unresolved-forest spillover) present on disk but its BaseName resolution is UNRESOLVED per F08 E16 pattern [V-present/C-unresolved].

### 1.5 Gold / iron / coal mines (+ pump/decor)

- (a) IMPLEMENTED [V]: `mng.json`, `mni.json`, `mnc.json`, `desert_mng/mnc/mni_1/2/3_a.json`, `k_pump.json` PRESENT [V]; `MINE_MESH_PATHS` constants for `mine_gold/iron/coal.obj` under `models/obj/shared/buildings/` (`terrain_donor_props.gd:71-75`) [V]; mine scale 0.3152 + 5x5 dirt plate carried [C, HANDOFF]; `BLOCK_PNG_DIR` 112 PNGs [V].
- (b) REPORTED-ONLY or STUB [C]: nested minegold/mineiron/minecoal objects in mng/mni/mnc (`pattern.lib:713410/715244/716910`), 6 cfg records each, ring+ore+256 tries [C, HANDOFF]; meshes byte-identical, ore differentiated by material only (PORT APPROX) [C].
- (c) ABSENT or DEGRADED: A0 gold mine is [I] from icon/text; no identifiable iron/coal reference stills (X07 U4/U8) [C]; no finite deposit capacity [C, HANDOFF]; 3 desert ores use base-ore DDS not desert variants [C, X16 A5].

### 1.6 Decorative props (christmas/new-year, gift, dcr, towers/windmill/village/camp)

- (a) IMPLEMENTED [V]: `new_year.json`, `gift.json`, `dcr.json`, `k_pump.json` PRESENT [V]; `deco_png/christmastreed.png` (+ .import) PRESENT [V]; `groundexp0-3.png` PRESENT [V].
- (b) REPORTED-ONLY or STUB [C]: HANDOFF decor row — A7 watchtowers, A1 windmill, A6 stone structures; silhouettes only, no terrain-class claim; donor pixel identity unresolved (third-party build/camera unknown, X07 A6) [C].
- (c) ABSENT or DEGRADED: no dedicated decor family spec exists [C, HANDOFF]; no donor stills for towers/windmill interiors beyond [D] direction cues [C].

### 1.7 Swamps / lakes / water-adjacent vegetation

- (a) IMPLEMENTED [V]: `m_swamp.json`, `m_swamp_small.json`, `m_swamp_12_old.json`, `k_swamp.json`, `k_lake.json`, `l_lake_big/small.json`, `desert_lake.json`, `desert_plain.json`, `desert_plt.json` PRESENT [V]; `masks/` tier now PRESENT: `mask_index.json` + 4466 `.height.png` (4467 files) [V].
- (b) REPORTED-ONLY or STUB [C]: `m_swamp_small_1` 16x13 zero height field with bushes/fern, `ReplaceForWater=False`; global pass `dogenerate.inc:1774-1906`; donor tile ids only, no water plane [C, HANDOFF]; `m_swamp_12_old` 17x20 vs binary 18x23 quarantined, never "fix" [C].
- (c) ABSENT or DEGRADED: no river/swamp reference still (X07 U5) [C]; `lake_big := plain*2*0` must not be repaired (carried defect guard) [C].

### 1.8 Relief / mountain / hill / plateau props (terrainmeshN)

- (a) IMPLEMENTED [V]: relief families `g_mnt.json`, `g_hil.json`, `hil.json`, `i_mnt_big/long.json`, `j_big_plt.json`, `f_plt_big/mid.json`, `d_plt.json`, `plt.json`, `plt4_fixed.json`, `k_plain/mid.json`, `desert_mnt.json`, `desert_plain.json` PRESENT [V]; `mountain_props.json` (66,519 B) fallback PRESENT at `assets/terrain/` [V]; `terrainmesh1..4` converted models carried [C, spec/08 A3].
- (b) REPORTED-ONLY or STUB [C]: `g_mnt_*` grids are zero-height; silhouette carried by `terrainmesh4` (`pattern.lib:337491-337492, :338480-338507`); 112 prop records / 30 sections; MultiMesh consumer Z08 never QA-run [C, spec/08 A3].
- (c) ABSENT or DEGRADED: `mountain_props.json` `base_name_census` holds only the 8 relief names — every forest/stone/mine row needs a new I03 export [C, X16 A3]; runtime chooser among `terrainmeshN`, yaw sign, metres-per-unit all [U] [C, HANDOFF].

### 1.9 AAF / actor art (unit + building + naval)

- (a) IMPLEMENTED [V]: `skin/index.json`: count 66, entries 66, skipped 7 (naval: yacht/yachttur/fishboat/frigate/galley/battleship/xebec), `actions` map now lists 40 names: idle/idle0/walk/walk0/death/attack0/attack1/construct/workfood/workwood/workstone/idlefood/idlewood/idlestone/walkfood/walkwood/walkstone/reaction/prepare0/unprepare0/death0/death1/death2/idle1/idle2/walkprepare0/walkunprepare0/trans01/trans10/trans02/trans12/trans20/trans21/prepare1/unprepare1/prepare2/unprepare2/attack2/attack2before/attack2after [V — supersedes DEC_U_aaf_art_audit's 8-name `actions_requested`]; per-entry `donor_oss`/`donor_aaf`/frame lists (e.g. pearus `walk [1,5,9,12,16,20]`, 6 frames/action) [V]; `skin/attach/` 63 tool-skin JSONs [V]; `anim3d.gd` T1–T26 state table with donor cites + `port: yes/partial/no` flags [V]; `ACTION_ALIAS` + `ACTION_ALIAS_STATUS` (no `attack` token in any donor AAF) [V].
- (b) REPORTED-ONLY or STUB [C]: donor needs up to 30 rows/sid (grenadier 30 active + 1 commented); DANIM_01 246-file/62-name catalog, 1,434/1,434 `morph` [C]; loop/one-shot/blend live outside AAF (`showdebuganimations.inc`, `movie.script:648-656`, `unit.script:10808-10852`, min/max blend 6/8) [C]; naval hulls are `.osm` + `.tlf`, not skin tracks [C].
- (c) ABSENT or DEGRADED: grenadier `attack2before/after`, `death0/1/2`, `trans*/prepare*/unprepare*`, `walkprepare0/walkunprepare0` have no sim set-site — orphan/explicit-`anim_action`-only (T23/T24/T25 `orphan: true`, `port: partial`) [V-script/C-report]; 5 non-combat sids had no `death` in shipped skin at audit time (61/66) [C]; port `_frame_at` fposmod loop self-labelled UNVERIFIED (`anim3d.gd:104`, [U] U2) [C]; blend `0,0` vs 6/8 response [U]-B open [C].

### 1.10 Tool / attachment skins (peasant tools)

- (a) IMPLEMENTED [V]: 63 tool-skin JSONs in `variant3d/assets/models/skin/attach/` [V] = 9 peasant sids x 7 tools (peaukr x2 entries + pearus/peapol/peaaus/peaeng/peaspa/peatur/peasco; 57/66 entries `attach: None`) [V]; per-entry `attach` block carries `donor_body_oss`, `donor_tools_actor` (`data/actors/units/attach/<base>_tools.actor`), `aaf_path` [V]; `anim3d.gd:351-367` IMPL-TOOL-WIRING block: `TOOL_SKIN_SUBDIR`, `ATTACH_ACTOR_INDEX` (axe/bag/cart/hammer/hoe/lumber/pick = 0..6), `TOOL_ATTACH_CITE`, `TOOL_ATTACH_STATUS` = PORT APPROXIMATION [V]; T22 documents the refutation of the stale "no .oss" claim with header words (`peaukr_axe.oss` k=483/fps=30/b=1, every tool b=1, k=k_body) [V-script/C-report].
- (b) REPORTED-ONLY or STUB [C]: DEC_U_tool_attach — 56 `pea<nat>_<tool>.oss` (8 nations x 7) + 8 `<base>_tools.actor` under `data/actors/units/attach/`; fixed slot order; shared `peaaustools.dds`; attach prop carries no offset/rotation/scale [C].
- (c) ABSENT or DEGRADED: [U]-T-A (runtime child swap/visibility proof) and [U]-T-B (port 3D pixel proof) remain unresolved — fixed-camera close-up captures required [C, carried]; 3D skin pipeline had no attach handling before IMPL-TOOL-WIRING (only the 2D sprite baker did) — wiring now present in script but render proof still [U] [V-script/C-report].

### 1.11 Death art / building stages / scaffold-debris (death families)

- (a) IMPLEMENTED [V]: `BLD_DEATH_STEMS` now maps 12 families: mil->eurmil, cen->ukrcen, hou->ukrhou, bar->ukrbar, sta->ukrsta, bla->ukrbla, aca->ukraca, art->ukrart, dip->ukrdip, sto->eursto, mar->eurmar, tow->eurtow (`world3d_entities.gd:375`) [V — expands the 1-stem `{"mil": "eurmil"}` recorded in DEC_U_death_families P7]; `_death_mesh_info` resolves via stem+suffix (`:3593`) [V].
- (b) REPORTED-ONLY or STUB [C]: donor ships the same 4-file death set per family (`<base>_death1/2.osm` + `attach/<base>_death1a/2a.osm`, 7-slot actors, `Mesh[5..6]`+`debris` prop pattern, shared selector `ontagstates.inc:264-311` + `settagstates.inc` + `deathstage1/2.inc`, `gc_building_deathtime_0/1 = 30`) [C]; `eurmilanim.aaf` idle 1..249 (mill-sail attach, `.osm` job not skin job) [C].
- (c) ABSENT or DEGRADED: conversion scope at audit time was eurmil-only (6 OBJs); 44 derived OBJs (11 families x 4) + manifest rows + stems were the open scope [C] — stems now 12/12 in script [V], but derived-OBJ presence for the 11 non-eurmil families was NOT verified this pass (no `models/obj` per-family death-OBJ listing performed) — treated as REPORTED-ONLY until re-globbed; `eursto/eurtow _deathNa` are 660 B degenerate IDP2 stubs [C]; `eurmil*a.osm` not found in `commoneur/` in that pass — glob-all-directories follow-up ordered, not closed [C].

### 1.12 AAF-driven FX / pfx / ghost / rally (landscape FX)

- (a) IMPLEMENTED [V]: `variant3d/scripts/world3d_fx.gd` PRESENT — spatial FX / ghost / rally / selection-ring / owner-indicator layer, additive API `bind/sync/add_fx/draw_ghost/draw_rally`, PORT APPROXIMATION label in-file [V]; `variant3d/assets/fx/` tier PRESENT (`models/`, `tex/`, `manifest.json`) [V]; `variant3d/assets/models/skin/index.json`-adjacent ghost/rally donor art carried: `box.osm`/`box.dds`, `rallypoint.osm`/`rallypoint.dds`, `scaffold/debris(.w).dds` all present donor-side [C].
- (b) REPORTED-ONLY or STUB [C]: `constructiondummy.prop` (box mesh/material) + `rallypoint.prop` (`DefaultScale 0.525A3`, `DefaultRollAngle 45`, `ocoTerrainWater`) [C]; 52 `aaf/pfx/*.aaf` counted donor-side [C]; V7-2 PFX semantics UNMAPPED (`data/pfx/source.pfx` LITERAL KEY / SEMANTICS UNVERIFIED) [C].
- (c) ABSENT or DEGRADED: ghost colour/blink + rally TTL/pennant behaviour keys do not exist in either `.prop` — [U]-G / [U]-R open, named captures required [C]; `world3d_fx.gd` FX drift/flicker is deterministic function of (age, spawn index) — no donor RNG mapping, PORT APPROXIMATION by its own label [V-script].

### 1.13 Atlas / masks / lib / schemas / manifest tiers (additional asset tiers)

- (a) IMPLEMENTED [V]: root `manifest.json` PRESENT [V]; `atlas/` PRESENT (`tile_index_atlas.png` + `.manifest.json`, `alpha.png`, `alphavert.png`, `seasons/` with winter atlas + winter/desert aliases) [V]; `cfg/` 3 JSON [V]; `lib/pattern_lib_index.json` PRESENT (55,784,815 B class) [V]; `masks/` PRESENT (`mask_index.json` + 4466 `.height.png`) [V]; `schemas/v1.schema.json` PRESENT [V]; `patterns/` 713 + `families/` 77 [V]. All V62-absent tiers have landed since.
- (b) REPORTED-ONLY or STUB [C]: V89 — root manifest passes X15 visible checks (19 keys, 5256 ordered tuples, `visual_parity_claim:false` 787/787, 0 absolute donor paths); atlas PNGs are compact `--cell 128` derivatives, not legacy 179.9 MB transports; extension census only `.json`+`.png` [C].
- (c) ABSENT or DEGRADED: V89 defects still carried (not re-emulated this pass): I09 reads `patterns/pattern_lib_index.json` but the tool-default output is `lib/pattern_lib_index.json` (V66-F3 path mismatch); `family_index.json` shape unusable by `_try_feed()` (V66-F1, FALSE return) so I09 still lands on legacy `mountain_props.json` with `TRANSFORM_FALLBACK`; schema absent at V89 snapshot (now PRESENT [V] — validator execution still not run); season path shape conflict V66-F2; atlas sub-manifest misses three X15 A2.4 keys [C, V89 A5-A7].

## 2. Count provenance table (verified [V] vs carried [C])

| # | Figure | Value | Provenance |
|---|---|---|---|
| 1 | terrain_new files now | 5339 / 383,192,189 B | [V] dual-listed this pass (`Get-ChildItem -Recurse -File` + group) |
| 2 | families JSONs | 77 | [V] `(Get-ChildItem families -Filter *.json).Count` |
| 3 | props_index records/basenames/sections/families | 39783 / 235 / 668 / 77 | [V] `python json.load` this pass |
| 4 | skin sids / skipped / action names | 66 / 7 / 40 | [V] `python json.load` this pass |
| 5 | tool-skin JSONs | 63 (= 9 x 7) | [V] `(Get-ChildItem skin/attach).Count`; 57/66 `attach: None` [V] |
| 6 | T-table | T1–T26 | [V] `Select-String '"T\d+"'` on `anim3d.gd` |
| 7 | BLD_DEATH_STEMS | 12 | [V] `world3d_entities.gd:375` |
| 8 | blocks PNGs | 112 (+112 .import = 224 entries) | [V] directory listing; "112 PNGs" also [C] props script :65 |
| 9 | field decals / field.obj / mine OBJs / wave sheets | paths cited in `terrain_donor_props.gd:65-84` | [V] constants present; file bytes not hashed |
| 10 | AAF census 194 + 52 pfx | 194 unit/building + 52 pfx | [C] DEC_U_aaf_art_audit P1 |
| 11 | 56 attach .oss (8 x 7) | 56 | [C] DEC_U_tool_attach P1/P8 (donor files not opened this pass) |
| 12 | 141 BaseNames 75/3/63; COMPLETE 0/141 | as stated | [C] X16 A1-A6 |
| 13 | 112 prop records / 30 sections; 4 relief assets | as stated | [C] spec/08 A3, HANDOFF |
| 14 | X27 ceiling (22.54% / 54.7% garbled; 23/34 anchors absent; .bind packed) | as stated | [C] X27 A0-A3 |
| 15 | V89 seal 5257 / 364,646,949; V97 freeze 5,255 / 127 reports / 162 board IDs | as stated | [C] V89 A0-A2, V97 A1 |
| 16 | Donor per-row AAF ranges (peaukr 18 rows, musketeer 17, grenadier 30+1, cannon 4, yacht 4x1..280) | as stated | [C] DEC_U_aaf_art_audit A1.2 |

## 3. NEW gaps found this pass (with exact path/evidence; none invented)

- NEW-1 — `props_index.json` sections = 668 vs donor 680 sections (F02/X05 [C]): 12 sections have no index entry. Evidence: [V] `section_count 668` vs [C] 680-section `pattern.lib` census. Governing: F02/X05 + spec/11 A11.4. Not a parity claim; an index-completeness gap.
- NEW-2 — 12-family `BLD_DEATH_STEMS` in script [V] vs unverified derived death OBJs for the 11 non-eurmil families: stems resolve, but this pass performed no per-family death-OBJ listing under `variant3d/assets/models/obj/**`. Evidence: `world3d_entities.gd:375` [V] vs no listing run. Governing: DEC_U_death_families A5. Missing work: glob `*death1*/`*death2*`/`*1a*` per stem and record PRESENT/ABSENT per family.
- NEW-3 — grass/plantain BaseName-to-PNG wiring unproven: `grass.4`/`plantain.*` records exist in family JSONs [V] and `grass*.png`/`rockgrass1.png` exist in `assets/terrain/` [V], but no manifest maps BaseName -> PNG (only relief census in `mountain_props.json`, only `prop_winter_materials.json` data-only). Evidence: absence after `Select-String` of props script constants + family sample read. Governing: X16 A3-A5 + spec/11. Missing work: per-BaseName mesh+material manifest.
- NEW-4 — skin `actions` map now carries 40 names [V] but port T-table marks T6/T7/T23/T24/T25 `partial`, T18-T20/T22/T26 `no`: the index shape outran the resolver. Evidence: `skin/index.json` 40-key actions [V] vs `anim3d.gd` T-table `port:` flags [V]. Governing: DEC_U_aaf_art_audit A5 + DANIM_01 A3-A5. Missing work: per-sid action-gap matrix (which of the 40 names each of the 66 sids actually ships frames for).
- NEW-5 — `desert_frt_un.json` + `n_desert_frt_big_1..17` resolution: family files PRESENT [V] but F08 E16 name-mismatch is still the governing caveat (17 members unresolvable at audit time) [C]. Missing work: confirm or re-quarantine per V89 hygiene (no silent "fix").

## 4. Prioritized missing-work list (governing report/spec per item; owner-only GPU/runtime items marked)

- P0-1 — I09 object feed end-to-end: land `pattern_lib_index.json` at I09's read path OR repoint `_load_feed()`/`_try_feed()` to `lib/`, and fix the feed shape (V66-F1) so the label is honestly DONOR LITERALS. Governing: V66 A2-A4, V89 A5-A7, spec/11 A11.4. (Static + Godot-load proof; runtime prop render still needs a capture.)
- P0-2 — Per-BaseName mesh+material manifest for all 235 basenames (mesh OBJ PRESENT/ABSENT, albedo PNG PRESENT/ABSENT + dimensions, winter PRESENT/ABSENT). Governing: X16 A1-A6, NEW-3. Closes the "63 missing OBJs" and material-variant defects with file evidence.
- P0-3 — Death-OBJ per-family glob (11 families x 4 files) + manifest rows; confirm stems resolve to bytes. Governing: DEC_U_death_families A3-A5, NEW-2.
- P0-4 — Per-sid 40-action gap matrix (66 sids x 40 names: frames PRESENT/ABSENT) + T6/T7/T23-T25 orphan-capture plan. Governing: DEC_U_aaf_art_audit A5, anim3d.gd T-table, DANIM_01 A3-A5, NEW-4.
- P0-5 — [U]-T-A / [U]-T-B tool-attach captures (fixed-camera close-up, zero-mismatch criterion) + [U]-G / [U]-R ghost/rally captures. Governing: DEC_U_tool_attach A4, DEC_U_aaf_art_audit A4. OWNER-ONLY if capture needs donor GPU frames.
- P0-6 — Atlas/manifest validator run (N7 `validate_terrain_new.py` still absent at V89; `schemas/` now PRESENT [V] but no validation executed) + `pack_id` recomputation from canonical seed. Governing: V89 A3, V66 A3, spec/11.
- P0-7 — Season/desert path reconciliation (V66-F2 shape conflict; `set_season()` has no caller). Governing: V66 A4, V89 A7.
- P0-8 — Grass/bush/fern material wiring (NEW-3) + winter/desert prop swaps (X16 A5, X30 season texture spec).
- P0-9 — Donor GPU A/B frame decision (same camera/seed/map-size) — the only path above V15 tier 2. Governing: V15 A2, HANDOFF A5. OWNER-ONLY runtime item; without it every verdict stays UNVERIFIED.

## 5. Verdict (binding wording)

- Parity UNVERIFIED. Chain 0/6. Nine P0 items OPEN (A4 P0-1..P0-9). RESULT IS NOT GOOD while blocking_unverified is non-empty.
- No completeness declared: 5339 derived files PRESENT [V] with `visual_parity_claim:false` labels is existence evidence only, not correctness, not a gate pass, not donor parity.
- No approximations made and no parity claimed in this report; carried approximations are the port files' own labels, quoted as observed.
