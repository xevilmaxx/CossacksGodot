---
id: E02
owner: E02 (terrain swarm — final-stage building asset inventory)
ticket: "E02 — inventory final-stage building meshes for the ghost-preview work (Wave E)"
date: 2026-11-25
status: READ_ONLY_INVENTORY__NO_CODE_EDITS__NO_GODOT_JOBS
scope: "Read-only. Explored variant3d/assets/models/obj/ and app/assets/models/obj/, the OBJ conversion tool reports, build-stage modules in variant3d/scripts and assets, and donor naming evidence in DBUILD-01 / BUILD-STAGES-01 / DEC-04. Only this report was written. No source, asset, manifest, config or test change; no Godot/runner job submitted."
labels: [observed, derived, inferred, UNVERIFIED, NO_VISUAL_PARITY]
output: "docs/terrain_swarm_2026-11-25/reports/E02_final_stage_assets.md (exclusive output; the reports/ dir was created by this write)"
governing_rule: "CHARTER.md §3 (observed/inferred/UNVERIFIED separated; one Godot at a time; this ticket = no runner jobs) and §1b.3 (ghost must show the LAST/completed stage, translucent green/red, footprint-honest)."
---

# E02 — Final-stage building meshes: what exists, how it is named, how it is loaded

> [!IMPORTANT]
> **Bottom line (observed):** for **12 of the 19** buildable sim sids the port now has
> a full donor-derived stage family — base + stages `1..4` + stage scaffolds `1a..4a` +
> base scaffold `a` — converted to OBJ and with Godot `.obj.import` sidecars. For
> those 12 the **final-stage mesh is `<sid>4.obj`** and the **completed/base mesh is
> `<sid>.obj`**; both are real on disk and loadable. The other 7 sids (`bar18`,
> `wal`, `gat`, `mine_gold`, `mine_iron`, `mine_coal`, `dock`) have **no stage art at
> all** and only a base OBJ where one exists (`bar18`/`dock` have none).
> **No `_death1`/`_death2` mesh exists anywhere in the port.** The live ghost does
> **not** show stage 4 or the base: it explicitly calls `_stage_mesh_info(sid, "1",
> false)` — stage 0 / suffix `"1"` — with the base mesh only as a fallback. This is
> the concrete blocker for CHARTER §1b.3. Every visual-parity statement stays
> **UNVERIFIED / NO_VISUAL_PARITY** (donor `.osm` never rendered; no A/B capture).

## 1. Sources read (all read-only this pass)

| # | Source | Use | Label |
|---|---|---|---|
| S1 | `docs/terrain_swarm_2026-11-25/CHARTER.md` (full) | Governing rules; §1b.3 ghost requirement | observed |
| S2 | `docs/coord_swarm_2026-11-25/reports/DBUILD_01_building_stages.md` (full) | Donor 7-slot mesh inventory (`engcen.actor:1-28`), `floor(progress*4)` → suffix `1..4` + completion base mesh, death stages, ghost dummy/blink | observed (report) / inherited donor citation |
| S3 | `docs/coord_swarm_2026-11-25/reports/BUILD_STAGES_01.md` (full) | Live selector contract, stage OBJ naming `<sid><s>[a].obj`, initial "0 stage OBJ" state | observed |
| S4 | `docs/coord_swarm_2026-11-25/reports/BUILD_ART_01.md`, `BUILD_ART_CONV_01.md`, `BUILD_ART_BATCH_01.md`, `BUILD_ART_C_01.md` (full) | a→b→c→d ticket chain: 108 donor OSMs, converter config, asset batch (280 OBJs), runtime integration | observed |
| S5 | `docs/coord_swarm_2026-11-25/reports/QA_STAGE_IMPORT_01.md` (full) | Earlier snapshot: stage sidecars 0/108, import queued; **superseded on disk** by this pass (§4.2) | observed / superseded |
| S6 | `docs/coord_swarm_2026-11-25/decomp/DEC_04_anim_formats.md:359-379` | Cross-reference model: `<sid>.actor` → `MeshObjects.LoadFromFile`, `.osm` = static variant / construction stage / LOD; `algcen.osm` 224,412 B static building evidence | observed (report) / inherited donor citation |
| S7 | `docs/coord_swarm_2026-11-25/reports/B_GHOST_DIAG.md`, `B_GHOST_FIX.md` (full) | Current ghost implementation history: `GhostBuildingStage0`, stage-0 resolution | observed |
| S8 | `variant3d/assets/models/obj/**` | Fresh enumeration: 280 `.obj`, 280 `.obj.import`, per-sid suffix sets | observed |
| S9 | `app/assets/models/obj/**` | Fresh enumeration: 116 `.obj` + sidecars; **no** stage/death OBJs | observed |
| S10 | `variant3d/scripts/world3d_entities.gd` (mesh code), `world3d_fx.gd` (ghost code), `world3d.gd:459-500`, `data.gd:1303-1359` | Mesh resolution, ghost resolution, sid set | observed |
| S11 | `variant3d/assets/models/manifest.json` | 280 entries, bbox per stage sid | observed (via S4 + spot-check) |

Label convention: **observed** = literal file/line read this pass; **derived** = arithmetic/control-flow consequence; **inferred** = strong but indirect; **UNVERIFIED** = no readable evidence or no runtime/visual capture. No donor file was opened, copied or rendered by this ticket; all donor facts are inherited citations from S2/S3/S4/S6.

## 2. What "final stage" means in the donor, and therefore in this port

Donor truth (DBUILD-01 §2.1–2.2, S2 lines 59–87; corroborated by S6 `:372`):

- A building actor lists **7 mesh slots**: base `<bld>.osm` (finished), stages `<bld>1/2/3/4.osm`, death `<bld>_death1/_death2.osm`; scaffold auto-child meshes `<bld>a`, `<bld>1a..4a`, `<bld>_death1a/_death2a`.
- Build progress `hp/maxhp`; `stage = floor(progress*4)` → visual tag 0..3 → mesh suffix **1..4** (`ontagstates.inc:240-251`). **Completion** (essential tag `none`) selects the **base** `<bld>.mesh` plus a `detail` scaffold (`ontagstates.inc:92-126`). The port's equivalent of "the finished structure" is therefore the **base mesh**, while the last discrete *construction* mesh is **stage 4**.
- Walls fold `stage := 1 + stage div 3` → only 2 stage meshes, no death mesh (`ontagstates.inc:247-248`).

Port naming (S3/S4 and S8): the converter emits `res://assets/models/obj/<sid>1.obj` … `<sid>4.obj`, scaffold `<sid>1a.obj` … `<sid>4a.obj`, base scaffold `<sid>a.obj`, base `<sid>.obj`; manifest sids match the file stems (`cen1`, `cen2a`, `cena`, …). All stage files reuse the base building texture except the `a` family, which uses `tex/scaffold.png` (S4).

## 3. Sid inventory — does a completed/final mesh exist?

Sim buildable sids taken from `variant3d/scripts/data.gd:1304-1359` (`BUILDINGS_BASE`): **19** sids. Fresh on-disk enumeration of `variant3d/assets/models/obj/` (S8) gives 280 `.obj`; suffix sets per sid below.

| sim sid | buildable kind | base `<sid>.obj` (finished) | last stage `<sid>4.obj` | all 4 stages | stage scaffolds `1a..4a` | base scaffold `<sid>a` | final-stage mesh usable as ghost? |
|---|---|---|---|---|---|---|---|
| `cen` | town hall | YES | YES | YES | YES | YES | **YES** — `cen4.obj` (last stage) or `cen.obj` (completed) |
| `hou` | house | YES | YES | YES | YES | YES | **YES** |
| `bar` | barracks | YES | YES | YES | YES | YES | **YES** |
| `sta` | stable | YES | YES | YES | YES | YES | **YES** |
| `bla` | blacksmith | YES | YES | YES | YES | YES | **YES** |
| `aca` | academy | YES | YES | YES | YES | YES | **YES** |
| `art` | artillery | YES | YES | YES | YES | YES | **YES** |
| `dip` | diplomatic | YES | YES | YES | YES | YES | **YES** |
| `sto` | storehouse | YES | YES | YES | YES | YES | **YES** |
| `mil` | mill | YES | YES | YES | YES | YES | **YES** |
| `mar` | market | YES | YES | YES | YES | YES | **YES** |
| `tow` | tower | YES | YES | YES | YES | YES | **YES** |
| `wal` | wall segment | YES | **NO** | NO (0) | NO | NO | **BLOCKED** — base only |
| `gat` | gate | YES | **NO** | NO (0) | NO | NO | **BLOCKED** — base only |
| `mine_gold` | mine | YES | **NO** | NO (0) | NO | NO | **BLOCKED** — base only |
| `mine_iron` | mine | YES | **NO** | NO (0) | NO | NO | **BLOCKED** — base only |
| `mine_coal` | mine | YES | **NO** | NO (0) | NO | NO | **BLOCKED** — base only |
| `bar18` | 18c barracks | **NO** | **NO** | NO | NO | NO | **BLOCKED — no mesh at all** (2D bake only) |
| `dock` | shipyard | **NO** | **NO** | NO | NO | NO | **BLOCKED — no mesh at all** (ships exist, dock does not) |

Notes (observed / derived):

- 12 sids × 9 suffixes = **108** stage-family OBJs, exactly matching the asset batch (S4 `BUILD_ART_BATCH_01.md:90-104`).
- 10 base-scaffold `<sid>a.obj` files are the donor's 660-byte 8-vert/12-face **minimal IDP2** cases (`cena, houa, bara, staa, blaa, acaa, arta, dipa, mara, tow1a`); they convert to ~801 B OBJs. They are valid data but their visual role is **UNVERIFIED** (S4 `BUILD_ART_BATCH_01.md:127-144`).
- All 12 final-stage parent OBJs (e.g. `cen4.obj`) are **non-degenerate** in the batch log (e.g. `tow4` = 1,711 verts / 1,360 faces, S4 `:76-77`); they are the natural ghost source where available.
- `wal`/`gat`: no stage art was converted because the donor mapping is ambiguous (`wal` base = `commoneur\eurswa` but `eurswa.prop:9` names `eurswa_v1.actor`; `eurswa_gate1/2.osm` are real but unreferenced). Carry as **UNVERIFIED**, do not fabricate (S4 `BUILD_ART_01.md §3.2`).
- `bar18`, `dock` have no OBJ in either tree (`data.gd` sim sids only; 2D bake path exists for `bar18` but that is a sprite, not a mesh). No asset to load — a ghost for these needs a PORT APPROXIMATION choice, not a name change.

### 3.1 `app/assets/models/obj/` (S9, observed)

116 `.obj` files, **only base meshes** — no `<sid>1..4`, no `<sid>a`, no `_death*`. Covers `aca, art, bar, bla, cen, hou, mar, mil, sta, sto, tow` plus mines and env/units; lacks `dip`, `wal`, `gat`, `bar18`, `dock`. This is the older 2D-port tree; the 3D port loads from `variant3d/assets/models/obj/` (manifest path strings were normalised to the variant3d tree in S4 `BUILD_ART_BATCH_01.md:125`). **Not a source of final-stage art.**

## 4. How the mesh is named and loaded in the live port

### 4.1 `world3d_entities.gd` resolution (S10, observed)

Constants: `OBJ_DIR = "res://assets/models/obj/"`, `GLB_DIR`, `TEX_DIR`, `MANIFEST_PATH = "res://assets/models/manifest.json"` (`:84-87`). `bind()` reads the manifest into `_bbox[sid]` and measures availability with `ResourceLoader.exists()` (`:406-431`).

Two distinct loaders:

1. **Base / finished mesh** — `_mesh_info(sid, "building")` (`:1110-1160`):
   - cached by `"building|<sid>"`; bbox from `_bbox[sid]`;
   - prefers GLB (`GLB_DIR + sid + ".glb"`) → then OBJ `OBJ_DIR + sid + ".obj"` (`load(...) as Mesh`, source `"obj_zup_bbox_normalised"`) → then a raw bbox proxy;
   - bakes Z-up→Y-up through `_bake_mesh()`; stores source/sid/kind; per-player tint applied by the caller (`add_building()` at `:1645-1686`, `_apply_tint()` at `:984-1001`).
   - `add_building()` binds `mesh = info["mesh"]` to `MeshInstance3D` named `Building_<sid>_<id>_STATIC_POSE`; `mil` additionally gets the rotor child.

2. **Stage / scaffold mesh** — `_stage_mesh_info(sid, suffix, scaffold)` (`:1819-1844`):
   - path = `OBJ_DIR + sid + suffix + ("a.obj" if scaffold else ".obj")`;
   - `ResourceLoader.exists(path)` then `load(path) as Mesh`;
   - bbox = `_bbox[sid + suffix + ("a" if scaffold else "")]` with **base-sid fallback**; `bbox_sid`/`bbox_note` recorded; source = `"obj_stage_zup_bbox_normalised"` (or `obj_scaffold_zup_bbox_normalised`);
   - empty `{}` means "no art" → caller keeps the base mesh with an explicit `PORT APPROXIMATION` label.

3. **Selector** — `_build_progress01()` (`:1795-1799`) = `clamp(progress/build_time)`, `_build_stage_suffix()` (`:1805-1811`) = `floor(p*4)+1`, with wall fold `1+floor(raw/3)` for `sid == "wal"` only, and derived `stage_4` clamp. `_sync_building_stages()` (`:1851-1936`) runs once per `sync()` from the building transform loop: for `finished=false` it picks `_stage_mesh_info(sid, suffix, false)` (real stage art when present), swaps `mi.mesh` and re-applies tint; attaches a stage-synced scaffold child (`Scaffold_<sid>_<id>`) with `<sid><suffix>a` art, visible only when art resolves; for `finished=true` it keeps the **base mesh** and frees the scaffold child. Telemetry: `build_stage_obj_hits`, `build_scaffold_obj_hits`, `build_stage_source` meta, etc.

**Answer to "are stage meshes currently used in construction display?" — YES, for the 12 art-bearing sids.** Under-construction buildings show the real `<sid>1..4.obj` (48 parent meshes) and a visible `<sid>1a..4a.obj` scaffold (48 meshes), with per-stage bbox and re-applied player tint (S4 `BUILD_ART_C_01.md:121-143,145-162`; 14/14 runtime probe checks passed, 280/280 manifest meshes load as `Mesh`). `wal`/`gat`/mines/`bar18`/`dock` still fall back to the base mesh (or proxy) with `base_mesh_port_approximation`. Completion always uses the base mesh; the donor's visible completion scaffold `<sid>a` is **not** applied (owner decision Q1 outstanding).

### 4.2 Godot import sidecars — on-disk state (fresh count, S8)

`variant3d/assets/models/obj/` now holds **280 `.obj` + 280 `.obj.import`**; of the imports, **108 are stage-family sidecars** (regex `^(cen|hou|…|tow)([1-4]a?|a)\.obj\.import$`). This **supersedes** `QA_STAGE_IMPORT_01.md` (S5), which measured 0/108 at ~12:18 while the import job was queued. Generated `.mesh` resources and `scaffold.png` import were not re-verified pixel/resource-by-resource this pass; treat the *runtime* load beyond the batch probe as **UNVERIFIED** (no runner job permitted here). No visual A/B exists.

## 5. Deliverable table — sid → final-stage resource path → loader call

Paths are Godot `res://` paths rooted at the `variant3d` project. "Final-stage" column gives both the last construction mesh and the completed mesh where they differ. Loader calls are the live functions in `world3d_entities.gd` (`:1110`, `:1819`); a ghost integration should reuse them read-only, exactly as the current ghost does.

| sim sid | final-stage (last construction) resource | completed/base resource | loader call that binds it |
|---|---|---|---|
| `cen` | `res://assets/models/obj/cen4.obj` | `res://assets/models/obj/cen.obj` | `_stage_mesh_info("cen","4",false)` / `_mesh_info("cen","building")` |
| `hou` | `res://assets/models/obj/hou4.obj` | `res://assets/models/obj/hou.obj` | `_stage_mesh_info("hou","4",false)` / `_mesh_info("hou","building")` |
| `bar` | `res://assets/models/obj/bar4.obj` | `res://assets/models/obj/bar.obj` | `_stage_mesh_info("bar","4",false)` / `_mesh_info("bar","building")` |
| `sta` | `res://assets/models/obj/sta4.obj` | `res://assets/models/obj/sta.obj` | `_stage_mesh_info("sta","4",false)` / `_mesh_info("sta","building")` |
| `bla` | `res://assets/models/obj/bla4.obj` | `res://assets/models/obj/bla.obj` | `_stage_mesh_info("bla","4",false)` / `_mesh_info("bla","building")` |
| `aca` | `res://assets/models/obj/aca4.obj` | `res://assets/models/obj/aca.obj` | `_stage_mesh_info("aca","4",false)` / `_mesh_info("aca","building")` |
| `art` | `res://assets/models/obj/art4.obj` | `res://assets/models/obj/art.obj` | `_stage_mesh_info("art","4",false)` / `_mesh_info("art","building")` |
| `dip` | `res://assets/models/obj/dip4.obj` | `res://assets/models/obj/dip.obj` | `_stage_mesh_info("dip","4",false)` / `_mesh_info("dip","building")` |
| `sto` | `res://assets/models/obj/sto4.obj` | `res://assets/models/obj/sto.obj` | `_stage_mesh_info("sto","4",false)` / `_mesh_info("sto","building")` |
| `mil` | `res://assets/models/obj/mil4.obj` | `res://assets/models/obj/mil.obj` | `_stage_mesh_info("mil","4",false)` / `_mesh_info("mil","building")` (rotor child added by `add_building`) |
| `mar` | `res://assets/models/obj/mar4.obj` | `res://assets/models/obj/mar.obj` | `_stage_mesh_info("mar","4",false)` / `_mesh_info("mar","building")` |
| `tow` | `res://assets/models/obj/tow4.obj` | `res://assets/models/obj/tow.obj` | `_stage_mesh_info("tow","4",false)` / `_mesh_info("tow","building")` |
| `wal` | **NONE** (no stage OBJ) | `res://assets/models/obj/wal.obj` | `_mesh_info("wal","building")` only; `_stage_mesh_info(...)` returns `{}` → base fallback |
| `gat` | **NONE** | `res://assets/models/obj/gat.obj` | `_mesh_info("gat","building")` only |
| `mine_gold` | **NONE** | `res://assets/models/obj/mine_gold.obj` | `_mesh_info("mine_gold","building")` only |
| `mine_iron` | **NONE** | `res://assets/models/obj/mine_iron.obj` | `_mesh_info("mine_iron","building")` only |
| `mine_coal` | **NONE** | `res://assets/models/obj/mine_coal.obj` | `_mesh_info("mine_coal","building")` only |
| `bar18` | **NONE** | **NONE** | no OBJ in either tree; `_mesh_info` falls through to `donor_bbox_proxy` |
| `dock` | **NONE** | **NONE** | no OBJ in either tree; `_mesh_info` falls through to `donor_bbox_proxy` |

All 12 stage families additionally have `res://assets/models/obj/<sid>1a.obj` … `<sid>4a.obj` (scaffold) and `<sid>a.obj` (base scaffold, 10 degenerate) loaded with `_stage_mesh_info(sid, suffix, true)`. No `<sid>_death1.obj` / `<sid>_death2.obj` exists for any sid (glob `variant3d/assets/models/obj/*death*` = 0; same in `app/`) — death-stage work remains out of scope (DBUILD-01 §3; S4).

## 6. Ghost-preview integration audit (CHARTER §1b.3)

Current implementation (S7/S10, observed):

- `world3d.gd:463-498` `_sync_build_ghost()` resolves sid from `hud.build_ghost_sid`, gates on `_ghost_world_pos()`, `in_bounds`, `resolve_mine_sid`, `Data.BUILDINGS.has(sid)`, `can_place(...).ok` and affordability, then calls `fx.draw_ghost(sid, wp, ok)`.
- `world3d_fx.gd:574-598` `draw_ghost()` keeps a footprint `BoxMesh` as fallback and calls `_ghost_swap_building_mesh(s)`.
- `world3d_fx.gd:634-678` `_ghost_resolve_mesh()` **first** calls `provider.call("_stage_mesh_info", sid, "1", false)` — **stage 0 / the earliest foundation mesh** — then falls back to `_mesh_info(sid, "building")`, then a direct-load fallback of `<sid>1.obj`, `<sid>.obj`, `<sid>.glb`. The mesh is cached in `_ghost_mesh_cache`, set to scale 1, and tinted/pulsed with the shared `_ghost_mat` (green/red via GHOST_OK/GHOST_BAD). The node is named `GhostBuildingStage0` (`:903-907`).

**Verdict (observed / derived):** the owner complaint in CHARTER §1b.3 is confirmed in code: the ghost asks for suffix `"1"`, the *first* construction stage, not stage 4/base. To satisfy "show the LAST (completed) build stage", a future implementation should ask for `_mesh_info(sid, "building")` (the finished base mesh) **or** `_stage_mesh_info(sid, "4", false)` (the last stage), choose one policy explicitly, rename/re-label the node away from `Stage0`, and keep the footprint-honest footprint box + green/red validity. Both resources exist and both loaders are already available read-only; **no new asset conversion is required for the 12 art-bearing sids**. The 7 blocked sids need a documented PORT APPROXIMATION (base mesh or proxy) rather than a fake stage file.

## 7. Blockers and risks (explicit)

| # | Blocker / risk | Evidence | Label |
|---|---|---|---|
| B1 | Ghost shows **stage 0, not final**. `_ghost_resolve_mesh()` hard-codes suffix `"1"`; node named `GhostBuildingStage0`. | `world3d_fx.gd:634-650`, `:903-907`; S7 | observed |
| B2 | **7 of 19 sids lack final-stage art** (`wal`, `gat`, 3 mines, `bar18`, `dock`); `bar18`/`dock` lack even a base OBJ. | §3 table; S8/S9 | observed |
| B3 | **No death meshes** (`_death1/_death2`) anywhere; if "final" is read as post-destruction there is nothing to load. | glob `variant3d/assets/models/obj/*death*` = 0; DBUILD-01 §3 | observed |
| B4 | **Completion scaffold `<sid>a` not applied** — 10 of 12 base scaffolds are 8-vert degenerate; visual role UNVERIFIED. | S4 `BUILD_ART_C_01.md:153,164-170` | observed / UNVERIFIED |
| B5 | `wal`/`gat` donor actor mapping ambiguous; gate stage OSMs exist but are unreferenced, wall attach OSMs are 660 B placeholders. Do not convert from guesswork. | S4 `BUILD_ART_01.md §3.2`; DEC-04 S6 cross-reference | observed / UNVERIFIED |
| B6 | `gat` not folded to 2 stages (`_build_stage_suffix()` folds only `wal`); if stage art were later added for `gat` it would ask for 4 suffixes. | `world3d_entities.gd:1809-1810`; S4 open Q4 | observed / UNVERIFIED |
| B7 | `world3d_entities.gd` `bind()` availability probe only tests `<sid>1.obj` and `<sid>a.obj`; `scaffold_obj_sids` (61) is a superset of the 12 real base scaffolds. Telemetry shape pre-existing; do not read it as an exact art census. | `world3d_entities.gd:426-431`; S4 `BUILD_ART_C_01.md §9 Q2` | observed / derived |
| B8 | Player tint is applied by surface index using the **base** sid mask; stage meshes have no donor band-mask entry. Re-apply (implemented) but stage-specific masks UNVERIFIED. | `world3d_entities.gd:1884-1890`; S4 open Q5 | observed / UNVERIFIED |
| B9 | No visual A/B / donor GPU capture exists; `.osm` geometry was never rendered. All "final stage looks like donor" claims stay UNVERIFIED. | CHARTER §3/§6; DBUILD-01 §8; S4 no-parity claims | observed / UNVERIFIED |
| B10 | Static/perishability: sidecar counts are a snapshot of this pass (280/280); no runner job allowed here to re-verify `load()`/`.godot/imported` resources. | §4.2; S5 superseded | observed / UNVERIFIED |

## 8. Summary

- **Completed/final meshes exist** for 12 building sids (`cen, hou, bar, sta, bla, aca, art, dip, sto, mil, mar, tow`): `res://assets/models/obj/<sid>4.obj` (last stage) and `<sid>.obj` (base/completed), both with stage-family sidecars and loadable via the existing `_stage_mesh_info()` / `_mesh_info()` helpers.
- **Missing** for `wal`, `gat`, 3 mines, `bar18`, `dock` (base only or nothing); **no death meshes** for any sid.
- **Loader map:** `world3d_entities.gd:84-87` dirs; `:1110-1160` `_mesh_info()` for base; `:1819-1844` `_stage_mesh_info()` for `<sid><s>[a].obj`; `:1851-1936` `_sync_building_stages()` swaps real stage art during construction (YES, currently used for the 12 art-bearing sids).
- **Ghost blocker:** `world3d_fx.gd:645` calls `_stage_mesh_info(sid, "1", false)` — the earliest foundation — instead of the final stage/base. Switching to base or suffix `"4"` is a code decision for a later implementation ticket; no asset work is needed for the 12.
- **Read-only compliance:** no code edits, no asset/manifest writes, no runner job; only this report was created.

*End of E02 report. Read-only inventory; observed/derived/inferred/UNVERIFIED separated; no visual or donor parity claimed.*
