---
owner: V7-14
date: 2026-11-24
files_owned:
  - variant3d/scripts/world3d_entities.gd
  - docs/coord_swarm_2026-11-24/reports/V714_world3d_entities.md
scope: "SINGLEPLAYER SKIRMISH ONLY (D-12): static 3D entity meshes for units, buildings, trees, rocks, mines and fields; no campaign/mission/cutscene/network assets (WAVE7_3D_VARIANT_CHARTER.md:37-38)"
governing_rule: "Leverage existing DONOR code/data; every 3D decision cites donor path:line or an evidence id; UNVERIFIED where unreadable (WAVE7_3D_VARIANT_CHARTER.md:29-36)"
godot_runs: 11 (all via variant3d/tools/godot_runner.py; tickets 16, 27, 30, 32, 34, 35, 36, 38, 41, 42, 45)
code_edits: "one new module only; no app/** or other variant3d/** file touched"
donor: "not read directly this pass; donor path:line and evidence ids are quoted from V7-1/V7-2 reports; no donor binary copied or run"
status: "IMPLEMENTED — parse MEASURED pass, runtime API smoke MEASURED pass, OBJ mesh load MEASURED, visual/animation parity UNVERIFIED"
---

# V7-14 — `world3d_entities.gd`: static 3D entity meshes + MultiMesh armies

## 1. Exact API (implemented)

File: `variant3d/scripts/world3d_entities.gd` (572 lines, tabs only, no spaces used
for indentation, no RNG). `extends Node3D`; no `class_name` — loaded dynamically
via `load("res://scripts/world3d_entities.gd")` as the atomic contract requires.

| Method | Line | Behaviour |
|---|---:|---|
| `bind(game)` | 93 | Reads `assets/models/manifest.json` bboxes, measures OBJ/GLB availability into `stats`, emits the animation-label warning. No sim mutation. |
| `sync(dt)` | 537 | Rewrites every batched instance transform and building transform from sim `e.pos` / `e.face`; hides dead/hidden/exhausted entities at `0.0001` scale; refreshes `stats`; advances a clock for anim3d. No morph (see §5). |
| `add_unit(e)` | 434 | `MultiMeshInstance3D` batch keyed `unit|<sid>`, O(1) slot acquire, instance transform set immediately. |
| `add_building(e)` | 455 | One `MeshInstance3D` per building (tagged `anim_status` + `mesh_source`). |
| `add_resource(n)` | 501 | `MultiMeshInstance3D` batch keyed `res|<sid>`; `n.type` → donor sid mapping (`wood`→trees, `stone`→rocks, `gold/iron/coal`→`mine_*`, `food`→`field`, `bush`, `stump`). |
| `remove(id)` | 525 | O(1) swap-remove from the dense batch arrays (CPU transform mirror), or frees a building node; erases the sim reference. |

Public read-only state used by integrators/tests: `stats` (asset counts, mesh
sources actually loaded, batch counts, axis/scale/animation labels) and
`anim_handoff`. The six required methods are the full callable API; everything
else is `_`-prefixed internals.

Node layout after `sync`: one `MultiMeshInstance3D` per `(class, sid)` plus one
`MeshInstance3D` per building. Batch capacity = 4096 instances per sid
(`visible_instance_count` = live count), so thousands of same-sid units need
one draw call each. Each node carries `set_meta("anim_status", ...)`.

## 2. Mesh / scale decisions and donor citations

| Decision in code | Donor-backed source (read-only) |
|---|---|
| 116 `.obj` bind-pose meshes are the geometry source; 0 `.glb` at this date | V7-2 report §2.1 **[MEASURE]**: 116 OBJ / 116 MTL / 0 GLB / 0 GLTF / 0 DAE; manifest 9 unit / 14 building / 93 env. `variant3d/assets/models/manifest.json:3-22` sample peasant bbox. |
| OBJ holds donor bind-pose verts + UVs, normals absent, winding already swapped | `app/tools/convert_models.py:43-66,69-94,109-125,160-183`; V7-2 §2.3 (`vn` 0/116, `vt` 116/116, `f` 128,435). |
| Z-up → Y-up baked as `(x,y,z) → (x,z,-y)` into vertices/normals/tangents | Donor Z-up confirmed by `peasant.obj` vertex 0 `(0.062326,-0.057036,0.384664)` and manifest Z-height bboxes (V7-2 §2.3); mapping is the determinant-preserving `export_yup` rotation in V7-2 §4.1 (one conversion only, no double swap). Code: `_bake_mesh` line 215. |
| Bbox centring + foot at Y=0 | V7-2 §4.1: `t = (-(x0+x1)/2, -(y0+y1)/2, -z0)`; mandatory for mounted `cossack` (X 1.466..2.871) and `dragoon` (X 1.317..2.710). |
| Units/buildings `s = 1.0` (donor metres ≈1.9–3.5 m) | V7-2 §4.1: "`H_target = z1-z0`, `s=1.0` is the sane first pass". |
| Env props scale from bbox × donor `envscales.cfg` values: mine `0.3152`, stone `0.329`, tree `0.5` | `data/game/var/envscales.cfg:25-28` (minegold), `:43-46` (stones), `:231-234` (pine1), `:371-374` (spruce1), via V7-2 §1.1 ledger and Table A row "Per-instance env scale". |
| `field` / food ground patch: no height normalisation | V7-2 §2.3 caveat: `field` bbox `[58.519, 51.925, 20.453]`; normalising every prop by Z would be wrong. |
| Resource type → sid families and depletion rule | `variant3d/scripts/world.gd:2706-2824` (live 2D `_draw_resources` type switch), `:2712-2713` (permanent ore nodes `max_hits == 0` stay visible), `:222` (port `ENV_SCALE`, donor values re-cited above). |
| World placement `Vector3(p.x - W/2*2, height_at(p), p.y - H/2*2)` | `variant3d/scripts/heightmap_world3d.gd:200-202` (terrain vertices), `game.gd:1893-1907` (`height_at`), `data.gd:23` and `game.gd:16` (`TILE_M`/`TILE = 2.0`), `game.gd:35-36` (`MAP_W/H` default 160). |
| MultiMesh batching for mass armies | V7-3 atomic contract line 13 (`MeshInstance3D/MultiMeshInstance3D`); V7-1 §2.4 mass-army row (study `RENDER_ARCH_PORT_FEASIBILITY.md:204-207`, "Batch by sid/facing with MultiMesh — measure, do not assert a donor draw-call target"). |
| No sprite sheets, no 2D bake pipeline | `WAVE7_3D_VARIANT_CHARTER.md:40-53` ("DEAD WEIGHT — DO NOT PORT/USE"); V7-3 contract line 13 ("No 2D sprite sheets"). Only `assets/models/tex/**` (DDS-derived albedo) is read when the OBJ importer returns a null material; `anim/**`, `sprites/**`, `sprites_hi/**`, `buildings.json` are never touched. |
| Cut-out on env foliage is a labelled approximation | Donor env PNGs are RGBA 93/93 (V7-2 §2.3); donor/GLB `alphaMode` is UNVERIFIED (V7-2 Table B1), so `TRANSPARENCY_ALPHA_SCISSOR` is port-side, not claimed donor parity. |
| Yaw = `-face` | PORT APPROXIMATION: donor yaw has no file citation; zero turn/rotate actions in 246 `.aaf` (V7-2 §3.3.3; V7-1 C4). |

## 3. Mesh-count / asset availability (MEASURED)

All jobs used `python variant3d\tools\godot_runner.py run --id ...` with
`--headless --path variant3d`, per V7-3 contract line 37.

| Ticket / id | What it proved | Result |
|---|---|---|
| 30 / `v714-parse` | Godot 4.7.2 `--check-only` parse | ok (2.86 s) |
| 42 / `v714-parse-final` | parse after CPU-mirror fix | **ok (2.75 s)** |
| 27 / `v714-meshprobe` | runtime `load()` of 4 OBJ paths | **MEASURED: 4/4 loaded**, `surfaces=1`, `mats=["null"]`; AABBs peasant `(1.4345, 0.5119, 1.9886)`, `hou` `(10.782, 8.174, 5.529)`, `tree_spruce1` `(3.133, 3.495, 6.930)`, `field` `(58.519, 51.925, 20.453)` — all Z-height, confirming Z-up. |
| 32 / `v714-runtime` | first full API smoke | found and fixed one typed-Dictionary bug in `_acquire` (`Nil` assigned to `Dictionary`). |
| 41 / `v714-runtime-final` | full API smoke after fix | **ok (3.15 s)**. `stats`: `bbox_sids=116`, `obj_available=116`, `glb_available=0`, `mesh_sources_loaded={"obj_zup_bbox_normalised":6}`, 5 batches, 2 units, 3 resources, 1 building; after `remove()` of all IDs: units 1 (the untouched second unit), resources 0, buildings 0. No script errors; only the intentional `push_warning` label. |
| 35 / `v714-geom` | baked mesh AABBs | **MEASURED Y-up**: peasant `(1.4345, 1.9886, 0.5119)` with `y_min=0`; `hou` Y-height `5.529` grounded at 0; `tree_spruce2` Y-height `3.340` (= native 6.680 × donor 0.5); `field` Y-height `20.453` unchanged (exempt). Mesh meta `obj_zup_bbox_normalised` on every batch. |
| 45 / `v714-mirror` | CPU transform mirror | **MEASURED** batch `unit|peasant` ids `[1,2]`, instance-0 origin `(-150, 1, -150)`, scale `(1,1,1)` = `p - W/2*TILE_M` with stub height 1. |
| 36 / `v714-mm`, 38 / `v714-mm2` | headless MultiMesh readback | **MEASURED harness caveat**: `MultiMesh.get_instance_transform()` and `get_aabb()` return identity/zero after `set_instance_transform()` under the headless dummy `RenderingServer`, even in a minimal isolated script. Mitigated with a CPU-side `xforms` mirror (used by swap-remove and headless verification). |

**Answer to the verification question:** mesh assets **actually loaded = MEASURED
YES** — 116 OBJ paths available, 4 loaded directly by ticket 27, and 6 distinct
sids loaded by the module itself in ticket 41 (`peasant`, `cossack`, `hou`, a
tree variant, `mine_gold`, `field`), all from `res://assets/models/obj/**`,
all reported as `obj_zup_bbox_normalised`. Zero GLB available; the GLB branch is
compiled but UNVERIFIED at runtime.

**Not measured:** rendered appearance, skinning, draw-call count and instance
transforms on a real GPU — headless dummy server cannot prove those.

## 4. Static-pose label and handoff to `anim3d.gd`

Animation rig is **BLOCKED** per V7-2 §3.3 / §4.3 / Table B1: `data/actors/units/peaukr.oss`
has 20 bones × 483 frames × `<7f>` tracks but **no parent hierarchy** in any
readable donor file (layout `docs/decomp/DC_FORMATS.md:46-64`, evidence
`ev_392885a6...`). Inventing a root-joint tree is forbidden by
`WAVE7_3D_VARIANT_CHARTER.md:29-36`.

Therefore this module renders a **STATIC BIND POSE** and labels it everywhere:

- `const ANIM_STATUS` (line 75) and `anim_handoff` (line 79):
  `STATIC BIND POSE - PORT APPROXIMATION - NOT DONOR PARITY (V7-2 3.3/4.3 Table B1: .oss bone parents unreadable; hand off to anim3d.gd)`.
- `push_warning(...)` in `bind()` (line 142), observed in tickets 32/41 stderr.
- `set_meta("anim_status", ANIM_STATUS)` on every batch and building node;
  `stats["animation"]` and `stats["no_2d_sprite_sheets"] = true`.

**Handoff contract for the anim3d agent (V7-3 contract line 17, `bind(game, entities)`):**
read `entities.stats["animation"]` / `entities.anim_handoff`; walk
`entities.get_children()` for nodes with meta `anim_status`; then replace the
static bind-pose mesh with donor-sampled pose meshes or a donor-backed rig.
The only acceptable pose path today is V7-2 §4.4 Table C
`PORT APPROXIMATION — NOT DONOR PARITY` (CPU-sampled `.oss` poses / AAF ranges
`data/animations/aaf/peaukr.aaf:1-20`). `sync(dt)` deliberately accumulates
`_anim_t` and sets `anim_handoff["applied"] = false` so anim3d can take over
without fighting this module. No sprite-sheet billboard fallback is used here
(charter forbids the bake pipeline in `variant3d/`).

## 5. Open questions / limits

1. **Headless MultiMesh visibility UNVERIFIED.** `set_instance_transform` calls
   succeed without error and the CPU mirror is correct, but the dummy
   `RenderingServer` reports identity transforms/zero AABB. A windowed
   `t_entities3d.gd` gate (owned by V7-7) must confirm non-blank batches and
   measure draw calls at 200/552/thousands of units; do not assert a donor
   budget (V7-1 §2.4 mass-army row).
2. **GLB path UNVERIFIED.** 0 GLB in `variant3d/assets/models`; if V7-8 lands a
   GLB, this module assumes it is already Y-up and bbox-normalised
   (`source="glb_assumed_yup"`, line 302) — that assumption needs T-V72-1.
3. **Material fidelity UNVERIFIED.** OBJ importer returns `mats=["null"]`
   (ticket 27), so `_default_material` attaches `assets/models/tex/<sid>.png`
   when available. Donor alpha cut-out intent is unreadable (V7-2 Table B1);
   the scissor cutoff is explicitly a port approximation.
4. **Yaw convention UNVERIFIED.** `-face` mapping is a port approximation;
   donor yaw has no citation, and baked bind-pose forward axis is unknown
   (mounted-sid X offsets were centred, but forward axis still needs a visual
   A/B against `docs/audit/TERRAIN_REFERENCE_IMAGES.md:23` anchors).
5. **Resource sid selection is deterministic but unfitted.** Trees/rocks are
   chosen from pools by an integer hash of world position (no RNG), not by a
   donor sid table; the sim→skirmish sid subset still needs curating (V7-2
   open question 9).
6. **Construction stages / corpses are out of this atom.** `e["finished"]`,
   `_s1..s4`, `_dead` and per-frame poses belong to anim3d/FX; only
   `dead`/`hidden` visibility is handled here.
7. **`push_warning` at bind is intentional** and will appear in test logs; gates
   must not treat it as an error. The "3 ObjectDB instances leaked at exit"
   warning in the temp probe came from the probe not freeing its stub nodes,
   not from this module.

---

**End of V7-14. One new file plus this report; no donor file read/copied/run,
no other repo file edited, no 2D sprite sheet loaded.**
