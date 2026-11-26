---
id: A04
ticket: "TERRAIN-SWARM-2026-11-26 / Wave A04 — landscape prop rendering design for EVERY owner-listed landscape class"
agent: "A04 (design-only subagent; DONOR-FIRST swarm)"
created: 2026-11-26
status: DELIVERED__DESIGN_ONLY__ONE_REPORT__NO_CODE_EDIT__NO_GODOT__NO_RUNNER_JOB
scope: "This report is the ONLY repo file written. No .gd/.gdshader/.json/.png/asset/test/fixture/config/manifest/git edit; no Godot process, no runner job, no donor binary executed or copied. Donor at C:\\Games\\Cossacks 3 read in place (latin-1/cp1251 text, read-only filesystem scans)."
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_guard: "No donor GPU A/B frame exists (CHARTER.md:57-58, :122-130). All visual expectations are INFERRED or UNVERIFIED. NO DONOR PARITY CLAIM is made anywhere in this report."
priors_read:
  - docs/terrain_swarm_2026-11-26/CHARTER.md
  - docs/terrain_swarm_2026-11-26/SWARM_BOARD.md
  - docs/terrain_swarm_2026-11-25/reports/Z03_donor_relief_props.md
  - docs/terrain_swarm_2026-11-25/reports/Z05_relief_prop_conversion.md
  - docs/terrain_swarm_2026-11-25/reports/Z06_prop_placement.md
  - docs/terrain_swarm_2026-11-25/reports/Z07_relief_props_qa.md
  - docs/terrain_swarm_2026-11-25/reports/Z08_impl.md
  - docs/terrain_swarm_2026-11-25/reports/L01_spot_grass.md
  - docs/terrain_swarm_2026-11-25/reports/F2_01_mill_fields_audit.md
  - docs/terrain_swarm_2026-11-25/reports/F2_02_donor_fields_mines.md
  - docs/terrain_swarm_2026-11-25/reports/F2_03_fields_fix.md
  - docs/terrain_swarm_2026-11-25/reports/F2_04_mine_snap.md
  - docs/terrain_swarm_2026-11-25/reports/M01_mill_rotor_audit.md
  - docs/terrain_swarm_2026-11-25/reports/M02_donor_mill.md
  - docs/terrain_swarm_2026-11-25/reports/M04_mill_qa.md
  - docs/terrain_swarm_2026-11-25/reports/N01_nation_building_audit.md
  - docs/terrain_swarm_2026-11-25/reports/FOLD_05_all_folders.md
  - docs/terrain_swarm_2026-11-25/reports/FOLD_07_impl.md
  - docs/terrain_swarm_2026-11-25/reports/G26_water_shore.md
  - docs/coord_swarm_2026-11-25/reports/DPATTERN_01_relief_grids.md
  - docs/coord_swarm_2026-11-25/reports/DTRN_02_donor_terrain_geometry.md
  - docs/coord_swarm_2026-11-25/reports/DTRN_03_donor_shore_water.md
  - docs/coord_swarm_2026-11-25/reports/DTRN_04_donor_trees.md
  - docs/coord_swarm_2026-11-25/reports/DTRN_05_donor_mines.md
verdict: "DONOR RENDERS LANDSCAPE IN THREE COUPLED CHANNELS — (H) authored float32 height windows stamped from .pattern, (P) hand-authored 3D props (terrainmeshN, trees/rocks/mines/field) carried by pattern Objects lists, (T) tile/decal/shader art selected by aspect/height/material. PORT STATE 2026-11-26: H is only partially exported (w/h/cells, no float windows); P is converted for terrainmesh1..4 with a MultiMesh consumer already landed (Z08) but NEVER QA-run; field/mine/stone/forest exist as res-node MultiMeshes with PORT APPROX placement; T is largely landed (shore ids, water shader, smoother). A flat height field alone cannot supply mountain silhouettes — donor mountain grids are all-zero and the 6.93-9.55-unit terrainmeshN props must be instanced. DESIGN IS STAGED, ADDITIVE AND UNVERIFIED VISUALLY."
---

# A04 — landscape prop rendering design (donor-first, every class)

> [!IMPORTANT]
> **Labels used literally:** `[O]` observed = literal donor line / decoded donor byte /
> direct read-only file listing / literal port source line; `[D]` derived = arithmetic or
> control-flow consequence of observed values; `[I]` inferred = best reading without a
> donor GPU A/B; `[U]` UNVERIFIED = not provable with the files/instruments available;
> `PORT APPROXIMATION` = explicit port substitute, never donor truth. Donor paths are
> under `C:\Games\Cossacks 3\`; local paths under the repo root. No donor binary was run
> or copied. **No donor parity claim** (CHARTER.md:57-58).

---

## 0. Mandate and method

A04 must design how the **fresh** `variant3d` terrain module renders **every** class the
owner listed in `CHARTER.md:20-24`: hills, mountains, mill fields, sea, shore, forests,
stone quarries, gold/iron/coal mines, and remaining landscape (swamps/lakes/decor).
For each class the design must state: donor asset source (path/pattern family), converted
asset status in `variant3d` or conversion needed, exact donor placement rule, 3D
representation, LOD/culling, and an acceptance visual cue. Donor-faithful silhouette is
explicitly prioritised: the port's flat height field alone is insufficient, so the design
must name where `terrainmesh*.osm`-derived relief props (or analogous converted assets)
are instanced. Anything not decoded is marked `[U]`.

Method: (a) read the two governing documents first; (b) read all named priors;
(c) add fresh **read-only** donor probes where priors were thin —
`data/scripts/common.inc/dogenerate.inc:1688-1735,1774-1907`,
`data/game/var/generator.cfg:1290-1533,2314-2361`,
`data/pattern/pattern.lib:807576,819028-819060,913980-914095`,
`data/actors/actors.lib:1200-1229`, `data/actors/ref/refobj.actor:46-49,93-95`,
`data/actors/env/terrainmesh1.actor:1-5`, a negative filename scan for `quarr`;
(d) read the current port tree read-only — `manifest.json` (299 entries),
`assets/terrain/mountain_props.json`, `scripts/world3d_relief.gd`,
`scripts/pattern_gen.gd`, `scripts/game.gd`, `scripts/world3d_entities.gd`,
`assets/terrain/patterns/donor_patterns.json`. No Godot process or runner job was
started (charter §4: analysis workers submit none).

### 0.1 The three donor channels (the central design fact)

| Channel | What it supplies | Donor evidence | Label |
|---|---|---|---|
| **H — height field** | Broad hills, plateau caps, asymmetric ravine floors/lips, lake basins. Relief `.pattern` carries `w*h` float32 windows; values are stamped into `height[]`. | `DPATTERN_01` §2/§3/§4 (`k_ravine_1` min −2.9636/max +3.1398, `plt1` max +3.4967, `hil1` max +3.8613×0.65; `pattern.lib:549585-549586,351-352,33111-33112`); `generatemap.inc:4-7,567-574` | `[O]` grid + config; `[I]` visual attribution |
| **P — hand-authored 3D props** | Mountain/hill silhouettes (6.93–9.55 units), trees, rocks/stone, deposits, field nodes. Carried by `pattern.lib` `Objects` records with `Position/Direction/Up/Scaling`, not by `.pattern` binaries. | `Z03` §1.2; `Z06` §1-§2; `pattern.lib:338480-338507` (112 records / 30 sections); `pattern.lib:337491-337492` (mountain grid all-zero) | `[O]` |
| **T — tile / decal / shader art** | Grey cliff faces (`rock1..9vf/vs`), shore (`sandsea1/5/6`), field decal (`envfieldd/w`), mine dirt plates (`eurcoad/eurgold/eurirod`), procedural water foam. | `texturemap.inc:504-608`; `decals.lib:37-43,142-163`; `water.dev.frag:106-127,227`; `G26` §3-§4 | `[O]` config/shader; `[U]` runtime binding |

**Consequence binding on A04:** a "terrain module" that only displaces a height mesh
reproduces channel H at best. Mountains need channel P: the donor `g_mnt_*` patterns have
zero height grid and exist to carry `terrainmeshN` props (`Z03` §1.2, `Z06` §1). The
fresh module must own a **props stage** after stamp selection and before/parallel to tile
finalisation, with a derived donor-link table keyed by stamp name.

---

## 1. Executive summary

1. **Three channels, not one** (`[O]`/evidence E01–E04). Donor relief = authored float
   height windows + instanced props + tile/shader art. Port has only fragments of each.
2. **Mountains already have a conversion in the legacy port** (`[O]`, E07–E09):
   `manifest.json` now has 299 entries including exactly four `kind="relief"`
   `terrainmesh1..4` entries with donor bboxes; `assets/terrain/mountain_props.json`
   carries 112 donor `Objects` records (30 sections, 20 port-stampable, 45 records);
   `scripts/world3d_relief.gd` builds one static `MultiMeshInstance3D` per sid from
   `game.pattern_stamps`. **This implementation was never QA-run**: no
   `t_relief_props_qa.json` result exists and no props ON/OFF capture exists (`[U]`, E10).
   The fresh module must reproduce this stage, not assume it works.
3. **Hills/plateaus/ravines: conversion still needed** (`[O]` negative, E05). The
   derived `donor_patterns.json` stores only `w/h/cells`; no float32 height window is
   exported (`export_donor_patterns.py:139-155`). The fresh decoder must emit the
   26 decoded windows with exact byte offsets and `HeightFieldScale` from `pattern.lib`
   (`DPATTERN_01` §3/§8), labelled `[O]`, or the hills remain analytic PORT APPROX domes.
4. **Fields, mines, stone, forest: assets converted, placement still PORT APPROX**
   (`[O]`/`[D]`, E11–E17). `field`, `stone`, `rock*`, `mine_gold/iron/coal`, `tree_*`,
   `bush*`, `fern*`, `reed*` are on disk; `world3d_entities.gd:2097-2111` maps resource
   types to sids via position hash. But field sowing uses a 3 m clash that prevents
   donor-style contact (`game.gd:2755`), mines use port richness clustering and an
   11-tile separation instead of donor rings (`DTRN-05` C20), and mine magnetic snap is
   not present in `game.gd` (`[U]` negative).
5. **Sea/shore: structure landed, appearance unverified** (`[O]`/`[I]`, E18–E19).
   Water shader + single plane, correct `sandsea1/5/6` tile ids and 8×45° sector table
   exist (`G26` §3); donor surface Y, reflection FBO and foam width are `[U]`.
6. **Swamps/lakes/decor: donor families exist, port export does not** (`[O]`, E20–E22).
   `generator.cfg:1290-1533` defines `swamp_{small,medium,big}` and
   `lake_{small,big}`; `pattern.lib:913980+` shows swamps have **zero height field**
   and bushes/fern objects; `pattern.lib:819028+` shows lakes carry a real height
   window (−2.132…+0.454) plus `grass.1`/`pinesmall1` objects. `donor_patterns.json`
   has **no** swamp/lake families (`[O]` negative) → conversion needed.
7. **Acceptance is internal, never donor parity** (`[U]`, E10). Use the Z07-style
   props-ON/OFF pixel A/B, geometry silhouette checks and donor-cited histrograms.
   There is no donor GPU frame to compare against.

---

## 2. Evidence table

| ID | Evidence (donor `path:line` or prior evidence id) | Label | Establishes |
|---|---|---|---|
| E01 | `data/scripts/common.inc/generatemap.inc:4-7,567-574` (via `Z03` §1.1, `F01` §2.1) | `[O]` | `cPlateauHeight=2.964`, `cHillHeight=1.31733`, `cRavineHeight=−2.964`, `cWaterHeight=−1.1`; heights from mask R/G/B |
| E02 | `DPATTERN_01` §3/§4; `pattern.lib:337491-337492` (`g_mnt_1` min=max=0); `pattern.lib:549585-549586,351-352,33111-33112` | `[O]` | Decoded relief float windows; mountain grids all-zero; exact min/max literals |
| E03 | `pattern.lib:338480-338507`; `Z06` §1 (112 records / 30 sections); `dogenerate.inc:1984-1985` | `[O]`/`[D]` | Per-prop `Position/Direction/Up/Scaling`; scale uniform 0.3539–0.6562, no random rescale |
| E04 | `data/actors/env/terrainmesh{1..4}.osm` bbox decode (`Z03` §1.2, `Z05` §1); `terrainmesh1.prop:14,17-18` | `[O]` | z spans 6.93–9.55 donor units; own albedo DDS; winter `terrainmeshNw` |
| E05 | `variant3d/tools/export_donor_patterns.py:139-155`; `donor_patterns.json` schema (`version/source/donor_units/families/patterns`, per pattern `w/h/cells`) | `[O]` negative | Only mask cells exported; no float window, no `Objects` prop links |
| E06 | `data/game/var/generator.cfg:446-754` (via `DPATTERN_01` §3); `donor_patterns.json` 43 families | `[O]` | Family names available: `hills_dark/light`, `plateau*`, `ravine_big/medium`, `mountains`, `stones`, `stoneforests`, `decor`, `tiles`, `mng/mni/mnc`, forests |
| E07 | `variant3d/assets/models/manifest.json` (read this ticket): 299 entries, `relief`×4, `env`×93 | `[O]` | Relief OBJ/MTL/PNG + manifest entries already landed; 93 env decor/prop sids |
| E08 | `variant3d/assets/terrain/mountain_props.json`; `Z08_impl.md` §2 (source `pattern.lib`, SHA recorded) | `[O]` | 112 donor records, 30 sections; 20 port-stampable sections / 45 records; desert sids kept but skipped |
| E09 | `variant3d/scripts/world3d_relief.gd:86-253`; `world3d.gd:691` (`stats.relief_props`) | `[O]` | Static per-sid MultiMesh consumer exists; rebuild from stamps; `height_at_world` grounding; PORT APPROX yaw/selection labels |
| E10 | `variant3d/tests/t_relief_props_qa.gd` exists; `variant3d/tests/results/` has **no** relief result; `Z08_impl.md` §6 interface gap | `[O]`/`[U]` | QA atom materialised but not run; visual placement unverified |
| E11 | `data/terrain/decals/decals.lib:37-43`; `data/terrain/decals/env/envfieldd.dds` (`F2-02` F1–F3); `misc.script:4284-4306` | `[O]` | `envfieldd/w` 512² DXT5, 2×2 descriptor, runtime `texscalefix=1.3`, angle 45/225 |
| E12 | `data/scripts/lib/unit.script:6475-6548` (`F2-02` F4/F5) | `[O]` | Mill sows 7×7=49 nodes, `size=1.6981` cells, 45° rotation, 2.4017 snap, 1.528 food clearance |
| E13 | `variant3d/scripts/game.gd:2722-2767`; `world3d_entities.gd:313-315,444-448` | `[O]` | Port sows 7×7 but rejects within `1.5*TILE=3 m` of food; decal PNG paths recorded, 3D UV `[U]` |
| E14 | `data/objects/env/mine{gold,iron,coal}.prop:35-40`; `envscales.cfg:16-36`; `DTRN_05` C2–C7/C9 | `[O]`/`[D]` | One shared deposit mesh; scale 0.3152, no jitter; ≈2.37×2.49 tiles; olive/brown ground disc is donor art |
| E15 | `data/scripts/common.inc/dogenerate.inc:522-717` (`DTRN_05` §4.6, `F2-02` F8) | `[O]` | `SetupMines`: 3/4/5 rings, 256 angle tries, version/size-gated bands in map cells |
| E16 | `data/scripts/dmscript.global:206`; `unit.script:6629-6672`; `miscext2.script:1098-1132`; `menu.inc/onmousedown.inc:209-254` (`F2-02` F11/F12) | `[O]` text; activation `[U]` | Magnetic snap radius 1.5 map cells; mine type chosen from deposit; snapped centre/Y |
| E17 | `variant3d/scripts/pattern_gen.gd:391-426,551-720`; `DTRN_05` C19/C20 | `[O]`/`[D]` | Port mine layout is richness clusters with 11-tile separation — documented divergence; snap absent in `game.gd` |
| E18 | `data/shaders/water/water.dev.frag:45-47,106-127,175-183,198-199,207-227` (via `DTRN_03`, `G26` §4) | `[O]` | Donor water composite: shallow/deep colour, procedural foam, `height>level` coverage, `coastfade2` alpha |
| E19 | `variant3d/shaders/water3d.gdshader`; `variant3d/scripts/water3d.gd`; `G26` §3-§4 | `[O]` port / `[I]` visual | F1–F4 landed; `water_cell` alpha guard is non-donor; reflection off; surface Y `[U]` |
| E20 | `data/scripts/common.inc/dogenerate.inc:1688-1693,1713-1735,1899-1906` (read this ticket, `[*] = ;` text) | `[O]` text; activation `[U]` | `frs_big/mid/small=0.0009/0.0009/0.00054`, `stn1=0.00016`, `stn2=0.00012`; swamp/lake frequencies from `plain=5e-5`; `lake_big := plain*2*0` |
| E21 | `data/game/var/generator.cfg:1290-1533` (read this ticket); `pattern.lib:807576,819028-819060,913980-914095` | `[O]` | Family memberships; swamp `HeightFieldMin=Max=0` + bushes/fern; lake min −2.132/max +0.454 + `grass.1`/`pinesmall1`; both `HeightFieldReplaceForWater=False` |
| E22 | `variant3d/assets/terrain/patterns/donor_patterns.json` (`'swamp' in families == False`, `'lake' == False`, read this ticket) | `[O]` negative | Swamp/lake pattern data not exported; conversion needed |
| E23 | `data/game/var/envscales.cfg:40-46,158-188` (via `DTRN_05` §4.3, `DTRN_04` C3/C4) | `[O]` | Stones scale 0.329, jitter ±0.85–1.15; tree family ladders, same jitter; mines no jitter |
| E24 | `data/actors/ref/refobj.actor:46-49,93-95`; `actors.lib:1200-1229`; `terrainmesh1.actor:1-5` | `[O]` | Donor shader LOD 0..2500, mesh LOD 0..150 (donor units, metres `[U]`); 4 mountain + 4 plateau LOD actors |
| E25 | `data/objects/eurcoa.prop:49-62` + `decals.lib:142-163` (`F2-02` F10, `DTRN_05` C13/C14) | `[O]` | Built mine 5×5 map-cell mask; 5×5 dirt plate decal summer+winter |
| E26 | Read-only filename scan of `C:\Games\Cossacks 3\data` for `quarr` → 0 hits (this ticket) | `[O]` negative | No asset literally named "quarry"; owner term maps to `stones`/`stoneforests` clusters `[D]`/`[I]` |
| E27 | `variant3d/scripts/world3d_entities.gd:189,2097-2111`; `DTRN_04` C17/C18 | `[O]` port | Tree stand decor pass is explicitly OPEN; only six tree sids in `POOL_TREE`; forest visual is res-node based |
| E28 | `docs/terrain_swarm_2026-11-26/CHARTER.md:20-24,113-126` | `[O]` | Owner class list and definition of "good"; no parity claim without GPU A/B |

---

## 3. Per-class design table

Column meaning: **Port asset** = state at 2026-11-26; **repre­sentation** = target in the
fresh module; **LOD/cull** = donor-cited numbers where known, otherwise explicit
`PORT APPROX`; **cue** = internal acceptance visual/g geometric cue (never a donor claim).

| Class | Donor source / pattern family | Port asset state | Placement rule (cited) | 3D representation (fresh module) | LOD / culling | Acceptance cue | Label |
|---|---|---|---|---|---|---|---|
| **Hills / plateaus / ravines** | `hills_dark hil1..4`, `hills_light g_hil1..9`, `plateau plt1..5`, `plateau_big`, `plateau_small`, `ravine_big k_ravine_big_stone_1..8`, `ravine_medium k_ravine_1..9` (`generator.cfg:446-754`; E02/E06) | Families/cells in `donor_patterns.json`; **float windows NOT exported** (E05) → conversion needed | Stamp accepted by `CheckStandPatternExt` mask test; float window stamped with `HeightFieldScale` (plt3 0.8, hil1 0.65); `HeightFieldReplaceForWater=True` on ravines (`DPATTERN_01` §4.1) | Height-field vertex displacement from decoded float32 windows; steep cells get `rockNvf/vs` tile art (T channel), **not** extra mesh | Single height mesh, no per-stamp cull; donor no LOD for height | Broad flat caps ≈3.2–3.5, asymmetric ravine lip +3.14, no radial dome; height histogram inside donor band | `[O]` grid & config; visual `[I]` |
| **Mountains** | `g_mnt_1..7`, `i_mnt_big_1..5`, `i_mnt_long_1..5`, `desert_mnt_1..13`; 112 `Objects` records (`pattern.lib:338480…`; E03/E04) | **Converted**: 4 relief OBJ/MTL/PNG + 4 manifest entries; derived `mountain_props.json`; MultiMesh consumer `world3d_relief.gd` (E07–E09). Not converted: desert props, winter props, plateaus | `stand + Position.X/Z` in centred cell frame; uniform authored `Scaling` 0.3539–0.6562; yaw from `Up`; all N records of a stamped pattern instantiated (`Z06` §3/§5) | Static instanced `MultiMeshInstance3D` per sid, **preferred over one MeshInstance per prop**; ground Y via `height_at_world`; raw donor units, no metre factor | Donor mountain LOD actors `actors.lib:1200-1213`; mesh LOD 0..150 / shader 0..2500 (`refobj.actor:93-95`, `[U]` metres). Port: one batch/sid + frustum cull; region chunking + distance cull only as labelled `PORT APPROX` | Silhouette ≥4 m above centre terrain; props-ON/OFF pixel A/B; two fixed-window PNGs (Z07 §3 checks 10/14/15/16) | `[O]` config/geometry; engine transform `[U]`; placement `PORT APPROX` |
| **Mill fields** | Decals `envfieldd/envfielddw` (`decals.lib:37-43`); `field.prop`; mill seeding `unit.script:6468-6570` (E11/E12) | **Converted**: `field` OBJ + `deco_png/envfieldd.png`/`envfielddw.png`; decal paths only recorded, 3D UV `[U]` (E13) | Mill seeds 7×7=49 nodes, spacing 1.6981 cells, 45° rotation, 2.4017 snap, food clearance 1.528 < spacing ⇒ sibling nodes touch; runtime decal `×1.3`, angle 45/225 | Res-node instanced `field` mesh per node **plus** a ground-aligned decal quad using donor alpha (UV mapping is `PORT APPROX` until decoded); no synthetic noise | Same batching as res nodes; no donor LOD cited for field decals → `PORT APPROX` | One contiguous hard-edged rotated rectangle with a square mill clearing; adjacent field patches touch (2–8 px edge at 720p in reference crop, `F2-02` F7) | `[O]` donor rule; port contact `[D]` failing; visual `[U]` |
| **Sea** | `water.dev.frag/vert`, `water.lib`, mask B channel; DLC5 `lakes`/`rivers` masks (`generator.cfg:57-64`) | Shader + single plane already in port; F1–F4 landed; reflection off, surface Y `−0.25` fallback (E18/E19) | `hwater = −1.1*b*(1+r*3.5)`; coverage `height>level`; foam procedural, peak ≈0.535 m depth (`DTRN_03` §3.3) | One water plane + shader height texture; no new mesh/donor image (foam is procedural, no foam texture exists — `DTRN_01` C15) | Single plane, no LOD; full-map draw is one call | Pale desaturated water body, bright near-white cyan foam band slightly offshore, no hard classification-aligned edge | `[O]` shader; visual `[I]`; surface Y `[U]` |
| **Shore** | `sandsea1/5/6` + aspect/`rockN` sector tables `texturemap.inc:504-608`; wet strip −0.25…−0.1 | Converted tile ids 93/97/98 + 8×45° table; exact donor ids, ~1-cell collar (`G26` §3/G26-5) | Aspect sector picks shore id; `|h|>2.7 → rock8`, `>2.4 → rock4`, `<0.1` clear; sandsea only where `mask.b>0`-equivalent | Tile-atlas cells on the height mesh (T channel), **no separate geometry**; decal-like shader blend only | No LOD; part of height mesh draw | Broad warm beach collar → short bright foam → pale water; no half-shore turned into blocked rock (donor bug `F01` §6.4 must not be copied) | `[O]` tables; gate `PORT APPROX`; visual `[U]` |
| **Forests** | 15 `forest_*` families (`generator.cfg:909-1288`); `fb_1..53`, `n_small_frt_1..24`, `dcr1..3` (`DTRN_04` §4) | 22 tree-ish env sids on disk but `POOL_TREE` only 6; no decor stand pass (`world3d_entities.gd:189`; E27) | `frs_big/mid/small=0.0009/0.0009/0.00054`; `needed=floor(W*H*freq)`, 256 tries, Freq ×0.2 damping; per-object `Scaling` 0.165–0.71; yaw in `Up`; ±15% jitter; edge clumps `fb_*` on 1-neighbour cells; winter deletes `leaftree*` | Instanced MultiMesh per tree sid for **res nodes**, plus a **separate decor stand layer** keyed by stamp name and donor `Objects` records (the missing `TREE_STAND_STATUS` seam); forest floor via tile ids `grass1/grass6/rock9` | Donor mesh LOD 0..150, shader 0..2500 (`refobj.actor:46-49,93-95`, `[U]` metres), imposter off; port batch/sid + region chunk cull, distance cull `PORT APPROX` | Dense groves 650–1000 trees/MP, rim 150–250, organic clusters not a grid; no `leaftree*` in winter; darker tile floor under dense core | `[O]` placement/config; port decor layer `[I]`; visual `[U]` |
| **Stone quarries** | `stones d_stn_1..7` (`generator.cfg:876`), `stoneforests str_new_1..8` (`:802`); `stn1=0.00016`, `stn2=0.00012` (`dogenerate.inc:1692-1693`); `rock*`/`stone` props | **Converted**: `stone`, `rock`, `rock_stones1..10`, `rock_smallstones1..6`, `rock_landstone1..4`, `rock_sea*`; near-start stone stamps exist (`pattern_gen.gd:430`) | `SetupStartingResources` stamps `stones` near starts before distant fill; rest stage repeats `stones` at stn1/stn2; per-object scale 0.329 with 0.85–1.15 jitter (`envscales.cfg:40-46`) | Instanced MultiMesh for `stone` res nodes; decor rock clumps from stamp `Objects` (analogous to relief props) where donor record IDs are decoded; **no quarry asset exists** (E26) → do not invent one | Batch/sid; no donor LOD cited for stones → `PORT APPROX` | Clustered boulder groups inside the stamp footprint, not isolated pebbles or concentric rings | `[O]` config/assets; "quarry" mapping `[I]` |
| **Gold / iron / coal mines** | `mng/mni/mnc` families `mng_1..5` (`generator.cfg:67-205`), 8×10/32-of-80 stamps (`DTRN_05` C9); `minegold/iron/coal(+s).prop`; built `eurgol/euriro/eurcoa` + 5×5 dirt decals | **Converted**: `mine_gold/iron/coal` OBJ/PNG + res nodes; built mine building assets converted; snap not in `game.gd` (E14–E17) | 3/4/5 rings by density, 256 angle tries, bands 14+8R/32+10R/70+12R/22+16R cells (v≥80 big map); 1.5-cell magnetic snap to nearest deposit; built mine at deposit centre; type from deposit | Deposit: instanced MultiMesh per ore sid at 0.3152, **keep donor ground disc** (donor art, `DTRN_05` C7); built mine: existing building mesh + 5×5 dirt plate decal; snap ghost preview is a UI overlay, not a terrain mesh | Batch per ore sid; no donor LOD cited for deposits; decals are ground-aligned quads | Deposit reads as dark rubble pile on a cracked olive disc; built mine centred on it; ghost snaps within 1.5 cells | `[O]`; `.inc` caller activation `[U]`; port layout divergence `[D]` |
| **Swamps / lakes / decor** | `swamp_small/medium/big`, `lake_small/big`, `desert_lake` (`generator.cfg:1290-1533,2314-2361`); swamp zero height + bushes/fern (`pattern.lib:913980+`); lake real height −2.132…+0.454 + `grass.1`/`pinesmall1` (`pattern.lib:819028+`); `dcr1..3`, `big_hill_1`, `d_tls_1..4` | Families **not exported** (`donor_patterns.json` has no swamp/lake, E22); `bush*`, `fern*`, `plantain*`, `reed*` props converted; `tiles`/`decor` families present | Frequencies `swamp_big=plain*problarge`, `swamp_medium=plain*2*probmid`, `swamp_small=plain*6*probsmall`; `lake_big=plain*2*0` (literal zero, `[O]` anomaly) (`dogenerate.inc:1732-1735`); passes at `:1899-1906` | Swamp: tile-id patch + instanced bush/fern/reed props, **no water plane** (zero height field); lake: height-window depression + water plane where `height<level`; decor: `d_tls_*` tile stamps + small prop instances | Batch/sid + region chunk; no donor LOD cited → `PORT APPROX` | Organic soft-edged reed-fringed wet patches; lake basin with shore tiles; decor cracks/mud on 25-cell lattice, no checkerboard | `[O]` donor data; port export needed; visual `[I]`; activation `[U]` |

---

## 4. Design per class (detail)

### 4.1 Hills, plateaus, ravines — channel H, conversion needed

**Donor.** The relief `.pattern` format is `int32 w,h` + `w*h u8` cell grid + `w*h`
float32 height window, with min/max cross-checked exactly against `pattern.lib`
`HeightFieldMin/Max` for 26/26 patterns (`DPATTERN_01` §2/§3, E02). Decoded shapes are
authored, not Gaussian: `plt1/plt2` broad flat caps ≈3.2–3.5 with a slight negative
rim; `k_ravine_1` a wide −2.96 floor with an **asymmetric** +3.14 lip; `hil1` a narrow
crest at +3.8613 with `HeightFieldScale=0.65` (`DPATTERN_01` §4.1–4.5). Nominal
generator amplitudes are ±2.964, but 5/13 decoded mission maps exceed them and pattern
grids reach +4.741 (`Z03` §5).

**Port.** `donor_patterns.json` exposes 43 families including all of these, but the
exporter writes only `{"w","h","cells"}` (`export_donor_patterns.py:139-155`, E05).
`world3d_terrain.gd:91-93,1515` states the float tables are not in the runtime tables
and lists `stats.not_done`. The current hills are analytic domes scaled by
`RELIEF_SCALE={plains:1,hills:1.5,mountains:2.2}` then clamped ±2.964 (`Z03` §5.6)
— a `PORT APPROXIMATION`, not donor truth.

**Fresh-module design.**
- Extend the pattern compiler (owned by A03, consumed here) to emit, per relief pattern:
  `w`, `h`, exact float-window byte offset, `f32[w*h]` values, `HeightFieldScale`,
  `HeightFieldReplace`, `HeightFieldReplaceForWater`, and `CollisionStand`, with
  `DPATTERN_01` §8's ±64 B candidate-scan verification. **No value is invented.**
- Stage order: mask R channel → base height → relief stamp (add/replace per config,
  water replace last) → 3-pass smoother → water/shore → tile ids. Do not run the stamp
  after tile finalisation.
- Cell→world mapping uses the existing centred frame `s = map_w/160`,
  `x = round(px*s)` (`pattern_gen.gd:92,121-122`), marked `PORT APPROX` because the
  file-row sign flip is `[U]` (`DPATTERN_01` §2.2).
- 3D representation: height-mesh vertex displacement only; steep cells receive
  `rockNvf/vs` tile art, not new geometry (`Z03` §1.1, E04).
- LOD/culling: one height mesh per map (no per-stamp culling); if the fresh module
  chunks the mesh for culling, chunk boundaries must be hidden by the donor smoother.
- Acceptance cue: readable plateau caps and one-sided ravine lips in a fixed-camera
  capture; height histogram and max/min inside decoded donor bands; **no concentric
  rings, no diagonal vein lattice** (charter §6.4). Pixel identity stays `[U]`.

### 4.2 Mountains — channel P, conversion already landed, QA missing

**Donor.** Mountain families carry **no height** (`g_mnt_1` `HeightFieldMin=Max=0`,
`pattern.lib:337491-337492`) and instead list `terrainmeshN` props. 112 records across
30 sections, 1–9 props per stamp, base-name census mesh3×29 / mesh4×25 / mesh2×21 /
mesh1×14 plus desert variants (`Z06` §1, E03). Each record has `Position`
(centred, `Y≈0`), `Direction=(0,1,0)`, `Up=(cosθ,0,−sinθ)` (pure yaw, 10° multiples),
uniform `Scaling` 0.3539–0.6562 (`pattern.lib:338480-338507`). The meshes are 6.93–
9.55 units tall and ≈26–28 wide with their own DDS albedo (`Z03` §1.2, `Z05` §1).
The `dogenerate.inc:1984-1985` exemption only skips the *random* rescale; it does not
set scale to 1 (`Z06` §2.1).

**Port (2026-11-26, `[O]`).** Z05's conversion and Z08's consumer are **landed**:
`manifest.json` has exactly four `relief` entries with the full donor bboxes;
`obj/shared/terrain/terrainmesh{1..4}.obj` and `tex/shared/terrain/terrainmeshN.png`
exist and resolve through the manifest bucket map (`FOLD_07_impl.md:221`);
`mountain_props.json` carries 112 donor records with `pattern.lib` line numbers;
`world3d_relief.gd:86-253` groups props by sid into static `MultiMeshInstance3D`
batches, grounds each at `terrain.height_at_world`, applies authored scale and a
Z-up→Y-up basis, and labels every term `PORT APPROX`. `world3d.gd:691` exposes
`stats.relief_props`. **No QA result exists** (E10): the Z07 atom is on disk but was
never run, and the `mountain_props.json` filename differs from the atom's expected
`terrainmesh_props.json` (`Z08_impl.md` §6). Therefore visual placement remains `[U]`.

**Fresh-module design.**
- Own the props stage as a **new sibling module** composed by the fresh terrain module;
  do not patch the contested `world3d_entities.gd` (`Z03` B3). Inputs: stamp list from
  the fresh generator + derived prop table keyed by `st.name`.
- Instantiate **all** donor records of a matched stamp (`Z06` §1 inference), never a
  synthetic "pick one of N" — the engine-side chooser is `[U]` (Z03 B4).
- Placement formula (`PORT APPROX` in every engine-side term):
  `dx=round(px*s)`, `dy=round(pz*s)`, `wx=(st.x+dx+0.5)*TILE`, ground Y from `height[]`,
  scale = authored `sx`, yaw = `deg_to_rad(yaw_deg)` (sign `[U]`). Keep OBJ vertices in
  raw donor units; no metre factor (donor metres/unit `[U]`, DTRN-02 C20).
- Representation: one `MultiMeshInstance3D` per sid (four batches) — donor alpha is
  real, so do not flatten it (`Z05` §1.1). Region chunking is permitted as a
  `PORT APPROX` culling optimisation; do not claim donor LOD parity.
- **Conversion still needed** for full coverage: `terrainmeshdesert1..4`
  (`generator.cfg` `desert_mnt_*`) have no converted sid; winter `terrainmeshNw.dds`
  has no second sid; `terrainplateau1..4` have no albedo/.prop/`BaseName` refs and are
  deliberately deferred (`Z05` §1.3). All are `[U]`/deferred — do not fabricate.
- Acceptance: geometry silhouette checks (top ≥ centre terrain +4 m and ≥ footprint
  max +2 m), props-ON/OFF internal pixel A/B (≥200 changed px and ≥8 px upward rise
  per visible prop, outside-change <1%), two non-blank 1280×720 windowed PNGs
  (`Z07` §3 checks 10/14/15/16). Visual correctness stays `[U]` until G04 runs it.

### 4.3 Mill fields — donor 49-node cluster, port contact defect

**Donor.** `envfieldd/w` are 512² DXT5 decals with a 2×2 descriptor footprint and
byte-identical season alpha; the runtime enlarges by `texscalefix=1.3` and rotates
45°/225° (`F2-02` F1–F3, E11). A finished mill sows `cRow=7`, `cCount=49` field nodes
at `size=1.6981` map cells rotated 45° with a `size2≈2.4017` position snap, rejecting
nodes on collision tags and within 1.528 cells of food/wood/stone or 4.585 of ore
(`unit.script:6475-6548`, E12). Because food clearance (1.528) is **smaller** than the
row spacing (1.6981), sibling field nodes are allowed to sit almost two cells apart,
and the ×1.3 decal footprint overlaps them: the reference crop shows one contiguous
hard-edged rotated rectangle with a square mill clearing (`F2-02` §3.3/F7).

**Port.** `field` mesh and both decal PNGs are converted; `world3d_entities.gd:313-315`
records the decal paths but explicitly labels the 3D UV mapping `[U]`. `game.gd:2722-
2767` still sows 7×7 and rejects candidates within `1.5*TILE = 3 m` of *any* food node
— including earlier sown fields — so fields cannot touch (`F2-01` §2, E13). The
owner-directed four-patch "quad" in `F2_03_fields_fix.md` is a `PORT APPROXIMATION`
override, not donor truth; do not silently substitute it in the fresh module.

**Fresh-module design.** Prefer the donor-grounded rule: 49 nodes, 1.6981 spacing,
45° rotation, 2.4017 snap, 1.3× decal. Keep the mill centre clearing. If COORD chooses
the owner's quad instead, label it `PORT APPROX` in stats and record both numbers in
the result JSON. Representation: instanced `field` mesh per node (existing res-node
batch) + a ground-aligned decal quad using donor alpha; the decal UV/epsilon mapping
remains `PORT APPROX` until the donor decal binding is decoded (`[U]`). No synthetic
stalk speckle or luminance field (charter S-25-09). Acceptance: touching field patches
with a visible square mill clearing; a histogram count of 49 (or 4) nodes per finished
mill; no overlap with buildings/stone/mine sites (F2-03 rejection gate).

### 4.4 Sea — shader plane, donor-cited but unverified appearance

**Donor.** Water height comes from mask B: `hwater = −1.1*b*(1+r*3.5)`
(`generatemap.inc:567-574`, E01). `water.dev.frag` composites shallow/deep linear
colours, procedural `nautic`/`particles` foam, `coastfade` and `coastfade2` alpha, with
coverage `height>level` where level is engine-supplied and `[U]`
(`DTRN_03` §3, E18). No foam texture family exists in the donor (`DTRN_01` C15): the
bright band in `maxresdefault_1.jpg` (foam peak `(224,241,235)`, `G26` §2.2) is
procedural, and its pixel width is `[U]`.

**Port.** `water3d.gd` + `water3d.gdshader` already landed donor-grounded F1–F4
(surface Y decoupled, water cells remapped off `grass1`, `shore_prox` removed, exact
`coastfade2` alpha). Remaining gaps are `G26-1..5`: reflection off, coarse swell zero,
a non-donor `water_cell` alpha cut, ~1-cell shore collar, and `sandsea1` flat-water
fallback (`G26` §4, E19). All are **measured-in-code, not visually verified**.

**Fresh-module design.** Compose the existing water module unchanged (no shader edit
inside A04): water class = one plane over the map with height texture; shore class
requires water cells classified from the same `height[]` used by the height mesh, so
no seam can drift between them. Do not add a foam image or a `FOAM_GAIN` to "match"
the screenshot (`G26-2` explicitly forbids re-importing the 2D glints). Acceptance:
fixed-camera frame shows pale desaturated water and a bright band just offshore;
record foam peak RGB, water-body mean and alpha-at-waterline against the G26b metric
list, with **no pass verdict** and no donor parity claim.

### 4.5 Shore — tile art, not geometry

**Donor.** Aspect sector tables in `texturemap.inc:504-608` select `sandsea1/5/6`;
height overrides force `rock8` above 2.7 and `rock4` above 2.4, clear below 0.1;
`rock9/sand1/sand2` are excluded from the active shore (`F01` §6/C7, E18). The land-side
wet strip in the shipped script is −0.25…−0.1 (`G26` §4/G26-5). The donor's older
one-sided cliff-difference bug must **not** be copied (`F01` §6.4/C11).

**Port.** Ids 93/97/98, an 8×45° sector table and the `BLK_WATER` remap are landed
(`world3d_terrain.gd:1400-1480`, `game.gd:2087-2116`, E19). The substrate gate is a
`PORT APPROX` because donor `mask.b > 0` is unreadable.

**Fresh-module design.** Shore is a **tile/decal pass on the height mesh**, with zero
new meshes. It must run after water classification and before the tile smoother, and
its final authority must match the water shader's coverage test to avoid a hard alpha
edge (`G26-3`). Acceptance: continuous warm beach → cool foam → pale water over a short
soft band; no half-shore converted to blocked rock; live shore-id histogram contains
93/97/98. Any widening of the collar beyond donor literals is `PORT APPROX`.

### 4.6 Forests — res nodes plus a missing decor stand layer

**Donor.** 15 forest families in `generator.cfg:909-1288`, all `Freq=1`; base
frequencies `frs_big=0.0009`, `frs_mid=0.0009`, `frs_small=0.00054`
(`dogenerate.inc:1688-1690`, E20). Stands are placed with `needed=floor(W*H*freq)`,
256 tries, Freq ×0.2 damping after each success, and a mask no-overlap test
(`misc.script:3590,3634-3647,3695,3714-3715`, `DTRN_04` §5). Each `Objects` record
carries authored scale (0.165–0.71 for `e_frt_big_1`) and yaw in `Up`; `envscales.cfg`
adds ±15% jitter per family (`DTRN_04` C3/C4/C10/C11). Per-cell fill `n_small_frt_1..24`
with `cLiteProb=0.6`, fringe clumps `fb_1..53` at ±1.5 cells on 1-neighbour cells, and
winter deletion of `leaftree*` complete the look (`DTRN_04` C7/C8/C15). Mesh LOD is one
frame, `DistanceMin=0/DistanceMax=150`, shader LOD 0..2500, imposter off
(`refobj.actor:46-49,93-95`, E24).

**Port.** Assets exist (22 tree-ish sids) but `POOL_TREE` has only 6 and yaw is always
0; `world3d_entities.gd:189` explicitly marks the decor stand pass as **OPEN** and
`invalidate_forest_bake()` is a no-op (`DTRN_04` C17/C18, E27). Forest visual is
currently harvestable `wood` res nodes only, with position-hashed sid selection
(`world3d_entities.gd:2114-2119`).

**Fresh-module design.** Keep res nodes for gameplay. Add a **second, render-only
decor layer** keyed by forest stamp name, using the same derived-`Objects` pattern as
mountains (new tool: extend prop-table derivation to forest families). This is `[I]`
until donor `StandPatternWithAngle` instantiation is decoded; label it `PORT APPROX`.
Ground coupling: dense core tiles `grass6/rock9`, light `grass1`, fringe `grass5/rock9`
(`loadenvironmentfrombitmap.inc:27-76`, `smoothforestborders.inc:127-148`) — reuse
existing donor ids; do **not** add a synthetic noise field (L01 §2). LOD: batch per sid
and per region; if a distance cull is added, use donor `0..150/0..2500` only as a
`PORT APPROX` cue because the unit-to-metre mapping is `[U]`. Acceptance: grove density
650–1000 trees/MP in dense cores, 150–250 at rims (`DTRN_04` C20), organic boundaries,
no uniform grid, winter leaf removal.

### 4.7 Stone quarries — `stones`/`stoneforests`, not a quarry asset

**Donor.** A read-only filename scan for `quarr` over the donor `data` tree returns
**zero files** (E26): the owner's "stone quarries" map to the `stones` (`d_stn_1..7`,
`generator.cfg:876`) and `stoneforests` (`str_new_1..8`, `:802`) stamp families, plus
their `rock*`/`stone` props — `[D]`/`[I]`, not a literal donor class. Frequencies are
`stn1=0.00016` and `stn2=0.00012` (`dogenerate.inc:1692-1693`), with near-start stamping
in `SetupStartingResources` before distant fill (`dogenerate.inc:1774-1907`, E20), and
per-object scale 0.329 with 0.85–1.15 jitter (`envscales.cfg:40-46`, E23).
`dogenerate.inc:1984-1985` also exempts `stones` from the random rescale — interpret
as "no *extra* generator rescale", exactly as for relief props (`Z06` §2.1).

**Port.** All stone/rock sids are converted and `stone` stamps are placed near starts
(`pattern_gen.gd:430`); `world3d_entities.gd:2101-2102` maps `stone` res nodes into
`POOL_ROCK`. No donor-record-driven decor clump layer exists.

**Fresh-module design.** Add a stone decor clump pass analogous to §4.2, keyed by
`stones`/`stoneforests` stamp names, using derived `Objects` records **only if** the
record-id→prop binding can be decoded (currently `[U]`, `DTRN_05` Q1 for mines; the
same caution applies here). Until then, keep the existing res-node representation and
label clump shape `PORT APPROX`. Acceptance: clustered boulders inside the stamp
footprint, no radial rock rings, no single-rock grid; stone scale histogram centred on
0.329× with ±15% spread.

### 4.8 Gold / iron / coal mines — deposits and built mines

**Donor.** Three ore families only (`mng/mni/mnc`, desert-prefixed on desert maps,
`generator.cfg:67-205`); six env props where full/`s` variants share the same mesh and
scale but different DDS (`env.objects:2-4,337-339`, `DTRN_05` C2/C4). All three meshes
are byte-identical: ore identity is **material only**; scale 0.3152 with `min=max=1`,
so any ±15% wobble on deposits is a port invention (`DTRN_05` C5/C6/C7). The ground
disc in the DDS is donor art sampled by low-Z faces — do not strip it (`DTRN_05` C7).
`SetupMines` stamps 3/4/5 rings by density with 256 angle tries and version-gated
bands (`dogenerate.inc:522-717`, E15). Mine type and snapped position come from the
nearest deposit within `gc_gameplay_findminepositionradius = 1.5` map cells
(`dmscript.global:206`, `unit.script:6629-6672`, E16); normal buildings use a different
0.5-cell normalisation + adjustment search (`miscext2.script:977-1019,1030-1031`).
Built mines are real buildings with a 5×5 map-cell collision mask and a 5×5 dirt plate
(`eurcoa.prop:49-62`, `decals.lib:142-163`, E25).

**Port.** `mine_gold/iron/coal` OBJ/PNG converted and used as res nodes
(`world3d_entities.gd:2103-2104`); built-mine buildings and dirt decal assets are
converted, but the 2D path previously stripped the disc (`DTRN_05` C21). Placement is
port richness clusters with an 11-tile separation (`pattern_gen.gd:391,412-426,593`;
`DTRN_05` C20, E17) — a **documented divergence**. Magnetic snap is not present in
`game.gd` (`[U]` negative; only F2-04's proposal exists).

**Fresh-module design.** Preserve typed deposits with the donor disc visible, instanced
per ore sid at scale 0.3152, no jitter. Migration target (later stage): donor ring model,
`rounds×3` deposits per start with version-gated bands and 256 tries, replacing the
port richness cluster; this changes counts and must be gated by determinism/seed replay
rather than a silent switch. Add a snap-preview overlay at 1.5-cell radius with mine
type derived from the deposit (UI-layer, not terrain geometry). Keep the 5×5 dirt plate
centred on the deposit for built mines. Acceptance: deposit visually sits on its own
olive/beige disc; built mine centred on it; no mine placed without a deposit in range.

### 4.9 Swamps, lakes, rivers, decor — donor families exist, export missing

**Donor.** `generator.cfg:1290-1437` defines `swamp_small` (11 `m_swamp_small_*`),
`swamp_big` (`k_swamp_1/2`), `swamp_medium` (20 `m_swamp_*`); `:1437-1533` defines
`lake_small` (12 `l_lake_small_*`) and `lake_big` (11 `l_lake_big_*`); `:2314-2361`
defines `desert_lake` (12). The generator derives `swamp_big=plain*problarge`,
`swamp_medium=plain*2*probmid`, `swamp_small=plain*6*probsmall`, `lake_big=plain*2*0`,
`lake_small` following (E20); the literal `×0` for `lake_big` is `[O]` and means the
big-lake pass has zero frequency under these lines — do not "fix" it without a donor
binding. Passes are called at `dogenerate.inc:1899-1906` (E20). Swamp pattern
`m_swamp_small_1` has `Width=16, Height=13`, `HeightFieldMin=Max=0`,
`HeightFieldReplaceForWater=False`, and Objects `bushes`/`fern` (`pattern.lib:913980-
914095`, E21). Lake `l_lake_big_1` has `Width=30, Height=28`, height window
−2.1320748…+0.4542617 and Objects `grass.1`/`pinesmall1` (`pattern.lib:819028-819060`,
E21). Decor families `dcr1..3`, `big_hill_1`, `d_tls_1..4` are in `generator.cfg:755-
790` and `donor_patterns.json`.

**Port.** No swamp/lake families in `donor_patterns.json` (E22) → conversion needed.
`bush*`, `fern*`, `plantain*`, `reed*` meshes are already converted; `tiles` and
`decor` families exist, and B03 repaints `tile` stamps with `ground1` (`L01` E04).
There is no DLC5 `lakes`/`rivers` terrainmask port (`generator.cfg:57-64`); treat
rivers as out-of-scope `[U]` unless a separate DLC mask ticket lands.

**Fresh-module design.** Export swamp/lake family masks, float windows and Object lists
with the same compiler as §4.1. Swamp = tile patch + bush/fern/reed instancing, with
**no water plane** (zero height field); lake = height depression stamped from the
decoded window + water plane where `height<level` + shore tiles from §4.5; decor =
`d_tls_*` tile stamps plus small prop instances, with mask-blocking side effect `[U]`
(`F01` Open Question 3). LOD/culling: batch per sid and per region; no donor LOD cited
→ `PORT APPROX`. Acceptance: soft-edged wet patches with reed fringe, organic lake
basins, mud/crack decor on a 25-cell lattice without a checkerboard; no synthetic
noise field.

---

## 5. Implications for the fresh terrain module

1. **Stage order is donor order** (`F01` §1, E28): prepare → tiled patterns → mask/relief
   → shore/water → starts → relief/mines → forests/stone/swamp/lake/decor → finalise.
   Each donor stage reseeds `randkey1` (`F01` C1); the port currently seeds once — a
   documented divergence that must be handled by the seed/RNG worker (D02), not by A04.
2. **Data contract** (A01/A03 boundary): one derived pattern record must carry
   `w/h/cells`, optional `f32 window` + sculpt flags, and `Objects` records
   (`base/sid/px,py,pz/yaw/sx,sy,sz/line`). Without the last field, every prop class in
   §4.2/§4.6/§4.7/§4.9 is impossible. This is the single highest-value compiler gap.
3. **Props are render-only.** No props stage may write `height[]`, `blocked[]`,
   `nav_version`, `pattern_stamps` or any RNG stream (`world3d_relief.gd:5-8`).
   Terrain collision remains the height field's business (`DTRN-04` C13).
4. **Batching and ownership.** One `MultiMeshInstance3D` per sid per region keeps draw
   calls bounded (P02/P11 concern). `world3d_entities.gd` is contested (`Z03` B3); the
   fresh props layer must be a sibling module under the fresh terrain composition root,
   with a `stats` seam mirroring `world3d_relief.gd` (`stats.relief_props`) so A05 can
   assert determinism without pixel claims.
5. **Do not import failed substitutes.** No radial rock rings, no diagonal vein lattice
   (`grass_ground1/2/3` as large fields), no per-cell hash/dither/noise (charter S-25-09,
   L01 §2), no flat-only mountains, no fabricated quarry asset, no synthetic foam image.
6. **Season** is a material swap on the same geometry (`DPATTERN_01` §3: 680/680
   patterns `NativeSeason=Summer`, no winter `.pattern`; `dogenerate.inc:1971-2027`
   removes `leaftree*`). Winter relief/tree sids are not converted yet (`[U]`).
7. **No parity claim** without a real donor GPU A/B frame (E28). Every acceptance cue
   above is an internal structural or pixel-A/B cue, explicitly `PORT APPROX`.

---

## 6. Staged implementation order

Each stage is additive and independently gateable; none weakens selftest 29/29,
uitest 17/17, `t_render_mode`, `assert_clean CLEAN`, or touches `app/` (charter §4/§6).
Only COORD grants file ownership and only G04 submits runner jobs.

| Stage | Deliverable (owner to be assigned by COORD) | Depends on | Gate / acceptance | No-go if |
|---|---|---|---|---|
| **P0 — baseline freeze & QA** | Run the existing Z07 atom against the landed Z08 props; reconcile `mountain_props.json` vs expected `terrainmesh_props.json`; capture props ON/OFF PNGs | none | `skipped_missing_mesh==0`, `prop_count>0` on a mountains fixture, two non-blank PNGs, all Z07 checks that apply; record result | Any vacuous PASS on zero stamps; any donor-parity wording |
| **P1 — derived pattern compiler** | Extend exporter to emit float windows + sculpt flags + `Objects` for relief/forest/stone/mine/swamp/lake families; verify 26/26 min/max against `pattern.lib` (`DPATTERN_01` §8) | P0 (data only) | Hash of derived JSON deterministic; exact min/max equality; no donor binary in repo | Off-by-±64 B window mismatch; invented value |
| **P2 — height channel (hills/plateau/ravine/lake)** | Fresh height-stage consumer: stamp decoded windows, apply `HeightFieldScale`/Replace, smooth, then water/shore | P1 | Height band/histogram; ravine asymmetry visible; lake depression + water; start/path invariants unchanged | Rings, lattice, or height outside decoded bands without labelled PORT APPROX |
| **P3 — mountain props stage** | Fresh sibling props module: derived `mountain_props.json` + per-sid MultiMesh, centred-frame placement, authored scale, ground Y, stats seam | P1, P2 (ground Y) | Z07 geometry checks 4–13 + internal ON/OFF A/B 15–16; determinism for fixed seed | Engine-side selection or yaw sign presented as donor-exact |
| **P4 — resource & decor stages** | Forest stand layer, stone clumps, mine deposits/built plates, field decal quads, swamp/lake/decor props — all keyed by stamp name | P1–P3 | Per-class counts vs donor frequencies (labelled where engine-side); field contact; mine snap; no overlap with starts/buildings; batches bounded | Any res-node sim mutation; any synthetic noise/dither |
| **P5 — water/shore parity pass** | Recompose existing `water3d.gd`/shader with P2's `height[]`; no shader redesign in A04 | P2 | G26b metric recorded (foam peak, water mean, shore ids, alpha at waterline) | "PASS" verdict or new foam image |
| **P6 — QA / A-B harness** (A05) | Seed replay, histogram, frozen cameras, props ON/OFF, class-presence stats, `app/` byte identity | P0–P5 | All gates green; no donor parity claim; honest UNVERIFIED list | Fake A/B, weakened threshold, headless capture called PASS |

**Conversion backlog (explicit, not in the minimal path):** desert relief props
`terrainmeshdesert1..4`, winter relief/tree materials, `terrainplateau1..4` (no albedo),
swamp/lake family masks, mine record-id→prop binding. All are `[U]` and must not be
fabricated.

---

## 7. Risks

| # | Risk | Evidence / label | Mitigation |
|---|---|---|---|
| R1 | Fresh module reimplements the analytic dome and calls it "hills" | `Z03` §5.6; E02/E05 `[O]` | Gate P2 on decoded float windows; height histogram check |
| R2 | Mountain props silently not placed because no stamp matches the derived table | `Z07` §1.2 (64² hills tier places 0 mountains); E08 `[D]` | Use mountains tier fixture; `matched_stamps>0` setup guard; never vacuous PASS |
| R3 | Authored `Scaling` baked into OBJ or replaced by 1 | `Z05` §1.2/R2; E03 `[O]` | Keep raw donor units in OBJ; apply scale in instance transform only; manifest bbox gate |
| R4 | Yaw sign / metres-per-unit invented as "donor" | DTRN-02 C20, `Z06` §7 Q2 `[U]` | Label `PORT APPROX`; record both raw and rounded yaw; no metre factor |
| R5 | Props write into sim state or block paths | `world3d_relief.gd:5-8`; `Z07` checks 11–13 `[O]` | Render-only module; `blocked[]`/`nav_version` assertion |
| R6 | P11 res-node batches + new decor layer double-render trees | E27 `[O]` | Decor layer keyed by different stamp names and group; visual A/B must show single silhouette |
| R7 | Field quad override presented as donor truth | `F2_03` §0; E12/E13 `[O]`/`[D]` | Keep donor 49-node rule as default; any quad explicitly `PORT APPROX` |
| R8 | Mine ring migration changes deterministic output and breaks tests | E17 `[D]` | Gate by seed replay and dedicated `mine_rng`; no threshold lowered |
| R9 | Shore collar widened with invented threshold | `G26-5`; E19 `[I]` | Keep donor literals; any change labelled `PORT APPROX` and measured, not claimed |
| R10 | Swamp/lake imported with fabricated height field | E21/E22 `[O]` | Swamp zero grid is donor truth; lake window byte-verified; no invented water plane over swamp |
| R11 | `lake_big := plain*2*0` read as a bug and "fixed" | E20 `[O]` text, activation `[U]` | Preserve literal; document anomaly; do not add frequency |
| R12 | Draw-call regression from per-prop nodes | P02/P11; E09 `[O]` | Per-sid MultiMesh + region chunking; measure instance/batch counts in stats |
| R13 | Godot import pass changes new assets silently | `Z05` R11 `[U]` | Gate on `.import` generation by G04; never hand-author import files |
| R14 | No donor GPU A/B frame | E28 `[U]` | No parity wording; all visual cues called "internal cue" |

---

## 8. UNVERIFIED register (do not promote)

1. Native `StandPatternWithAngle` transform math and whether **all** `Objects` records are
   instantiated (`Z06` §3/§7 Q1; E03).
2. Runtime selection among multiple `terrainmeshN` in one stamp (`Z03` B4; `[U]`).
3. Donor metres-per-cell / metres-per-unit and yaw sign for props (DTRN-02 C20; E24).
4. Whether Z08's landed props actually render: no QA atom result, no PNG (E10).
5. Winter/desert relief materials and `terrainplateau1..4` authoring (`Z05` §1.3).
6. Exact donor UV/epsilon binding of `envfieldd` decal in 3D (`world3d_entities.gd:315`, E13).
7. Activation of all `[*] = ;`-prefixed `.inc` lines (`dogenerate.inc`, `unit.script`,
   `miscext2.script`, `onmousedown.inc`) — authoritative intent text only (`E15/E16/E20`).
8. Unit of decal `w/h` vs the 2-cell descriptor; exact field overlap ratio (`F2-02` §5.2).
9. Donor water surface Y, reflection FBO target, foam pixel width, and whether port water
   actually reads too dark/crisp (`G26` §6; E18/E19).
10. Runtime binding of `mask.b > 0` shore substrate gate and the 25-cell `d_tls_*`
    mask-blocking side effect (`G26-5`; `F01` Open Question 3).
11. Mine stamp record-id → prop mapping and `minegold`/`minegolds` terrain selection
    (`DTRN_05` Q1/Q2); same class of gap for stone clump records.
12. Whether donor skirmish seeds place swamp/lake stamps in any reference screenshot;
    `lake_big` zero-frequency anomaly cause (E20).
13. River handling: only DLC5 terrainmask folders exist (`generator.cfg:57-64`); no
    skirmish river pattern family decoded.
14. Donor LOD distances in metres and whether they apply to terrainmesh props at all
    (E24).
15. Any donor GPU frame comparison — none exists; every "visual cue" here is internal.

---

## 9. Open questions

1. Should the fresh module inherit Z08's `mountain_props.json` and `world3d_relief.gd`
   verbatim, or re-derive them from P1's unified compiler? (COORD ownership decision.)
2. Which fixture guarantees ≥1 mountain stamp at 64² (`Z07` §1.3) and ≥3 at 320², and
   who creates `small_map_{64,320}_mountains.json`?
3. Does COORD want the donor 49-node field rule or the owner-directed four-patch quad
   in the fresh module? Both need explicit labels if chosen.
4. Should mine ring migration land in this wave or be deferred to a later economy wave?
   It changes deterministic output (`E17`).
5. Are DLC5 `lakes`/`rivers` masks in scope for this port, or explicitly out-of-scope?
6. Who owns the water/shore recomposition (G27/G28 were mutually exclusive proposals in
   `G26` §5) if P5 needs a shader change? A04 designs only; it edits no shader.
7. How should region chunking choose cell size without inventing a donor constant?

---

## 10. Claim register

| # | Claim | Evidence | Label |
|---|---|---|---|
| 1 | Donor landscape = height field + props + tile/shader art | E01–E04 | `[O]` / `[I]` visual |
| 2 | Mountain silhouettes require `terrainmeshN` props; flat height insufficient | `pattern.lib:337491-337492`; E03/E04 | `[O]` config; pixel `[I]` |
| 3 | 4 relief props and 112 prop records are already converted/linked in the legacy port | E07–E09 | `[O]` |
| 4 | No QA result exists for those props | E10 | `[O]`/`[U]` |
| 5 | Relief float windows are not exported; conversion needed | E05 | `[O]` negative |
| 6 | Field/mine/stone/forest assets converted; placement still PORT APPROX | E11–E17, E23, E27 | `[O]`/`[D]` |
| 7 | Mine magnetic snap is donor truth but absent in current `game.gd` | E16/E17 | `[O]` text; port `[U]` negative |
| 8 | Water/shore shader + ids landed; appearance `[U]` | E18/E19 | `[O]` port / `[I]` visual |
| 9 | Swamp/lake families exist in donor but not in port export | E20–E22 | `[O]` |
| 10 | "Stone quarries" maps to `stones`/`stoneforests`; no quarry asset | E26 | `[D]`/`[I]` |
| 11 | Donor LOD numbers 0..150 / 0..2500, metres mapping `[U]` | E24 | `[O]` literals; `[U]` meaning |
| 12 | No donor parity claim; all acceptance cues internal | E28 | `[U]` |

*End of A04. Design only; one report file written; no code, asset, config, test, shader,
fixture, runner-job or git edit; no donor file executed or copied; no donor parity claim.*
