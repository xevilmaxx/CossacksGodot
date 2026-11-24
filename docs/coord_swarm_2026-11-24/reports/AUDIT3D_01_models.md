---
id: AUDIT3D_01
owner: AUDIT3D-01
scope: "variant3d/ units & buildings: real 3D donor meshes vs placeholders; asset manifest; OBJ loader path; 2D app sprite comparison"
date: 2026-11-24
status: complete
---

# AUDIT3D-01 — Are variant3d units/buildings real 3D donor models?

## Scope / method

Read-only audit. No source edits, no git, no donor writes. One output file (this report).

Method actually used:

1. Enumerated `variant3d/assets/models/**` (file counts by extension) and parsed
   `variant3d/assets/models/manifest.json` (116 entries, kinds, sids, bboxes).
2. Read the mesh load/bake/fallback path in `variant3d/scripts/world3d_entities.gd`
   line by line, plus the full producer `variant3d/tools/convert_models.py`.
3. Compared OBJ vertex/face counts and vertex 0 with the manifest bbox; checked
   `*.obj.import` and imported `.mesh` resources for material/texture content.
4. Counted **every** `Data.UNITS_BASE` / `BUILDINGS_BASE` id against available OBJ
   files, then traced whether `add_unit/add_building/add_resource` are ever
   called in production code (whole-tree grep of `variant3d/`).
5. Read-only donor probes under `C:\Games\Cossacks 3\data\actors` and
   `data\materials`; compared with the 2D port's sprite path
   (`app/scripts/world.gd`, `app/assets/models/anim/*/index.json`).

Labels: **OBS** = directly read/measured; **INF** = inference; **UNVERIFIED** =
no readable evidence found.

## Verdict on the V7-14 claim (independently re-measured)

| Claim (V714 report :73/:76) | Independent result | Verdict |
|---|---|---|
| 116 manifest bboxes | `manifest.json` has 116 `models`, 116 distinct sids | **CONFIRMED** |
| 116 OBJ available | 116 `.obj`, 116 `.mtl`, 116 `.obj.import`; every manifest sid has an OBJ, no orphan OBJ | **CONFIRMED** |
| 0 GLB | no `assets/models/glb/` directory exists at all | **CONFIRMED** |
| 6 real OBJ meshes loaded | True as a *smoke-test count* (ticket 41 bound only 5 stub entities). It is **not** a coverage metric; 110 of the 116 meshes were never exercised by that test | **CONFIRMED BUT MISLEADING** |
| "real donor geometry, not placeholders" | OBJ files are binary-derived donor geometry (`.oss`/`.osm` vertex/UV/face arrays), not boxes/billboards/images | **CONFIRMED for the 116 converted sids** |

**Overall verdict: the 116 OBJ files are genuine static donor geometry, but the
3D variant does not actually render donor models in play.** Two independent
blockers: (1) no production code ever calls the entity module's `add_*` API, so
a real 3D skirmish creates zero 3D unit/building meshes; (2) even if it did, only
23 of 81 unit/building IDs resolve to an OBJ — the other 58 get an invented 1 m
box (not even a donor-bbox-derived box). Units are static bind poses, never
animated.

## Evidence table

| # | Finding | Evidence (`path:line`) | Label |
|---|---|---|---|
| 1 | Manifest holds 116 models (9 unit, 14 building, 93 env); each has donor `.oss`/`.osm` source path, bbox, vert/face counts | `variant3d/assets/models/manifest.json:3-22` (first entry), `:1-2` (donor game root); directory enumeration of all 116 entries | OBS |
| 2 | All manifest sids have an OBJ on disk; 116 `.obj` + 116 `.mtl` + 116 `.obj.import`; no `glb/` dir | `variant3d/assets/models/obj/peasant.obj:1-5`, `variant3d/assets/models/obj/peasant.obj.import:2-5` (`importer="wavefront_obj"`, `type="Mesh"`); full enumeration under `variant3d/assets/models/obj/` | OBS |
| 3 | OBJ is real donor geometry: header says converted original mesh; `peasant.obj` v=577/f=921 equals manifest `verts=577/faces=921`; vertex 0 equals manifest bbox-derived source vertex; 116/116 `.obj.import` are `type="Mesh"` | `variant3d/assets/models/obj/peasant.obj:1-5`; `manifest.json:13-21`; `variant3d/assets/models/obj/peasant.obj.import:2-4`; `variant3d/tools/convert_models.py:43-66,97-125,338-356` | OBS |
| 4 | Converter reads donor binary `.oss` (units/cannons) and `.osm` (buildings/env), writes raw vertices/UVs/faces; **discards weights, bones and animation frames**; one material per mesh; unit/building textures forced opaque | `variant3d/tools/convert_models.py:43-66` (read_oss incl. `animation`), `:69-94` (read_osm, first frame only), `:109-133` (write_obj/write_mtl), `:135-153,344-345` (texture policy), `:327-356` (driver) | OBS |
| 5 | Loader prefers GLB, then OBJ, then a **box proxy**. GLB path is dead (no directory). OBJ is loaded as `Mesh`. | `variant3d/scripts/world3d_entities.gd:52-55,293-317` | OBS |
| 6 | Bbox-derived proxy is a `BoxMesh`; when the sid is absent from the manifest the bbox is the **invented** `[-0.5,0.5,-0.5,0.5,0,1]` (1×1×1 m), so every unmapped unit/building is an identical generic cube | `variant3d/scripts/world3d_entities.gd:191-213`, `:224-225`, `:277-282` | OBS |
| 7 | Bake applies `(x,y,z)->(x,z,-y)`, centres X/Z and grounds Y from manifest bbox; plane transform of normals/tangents; donor bbox drives scale (units/buildings `s=1`, env `envscales.cfg`) | `variant3d/scripts/world3d_entities.gd:216-270`, `:283-289`, `:67-73` | OBS |
| 8 | Imported OBJ meshes have a **null material** (binary `.mesh` contains no `Material`/texture name), so the actual albedo comes from the code fallback loading `res://assets/models/tex/<sid>.png` (DDS-derived). `.mtl` uses backslash path `..\tex\...` | `variant3d/.godot/imported/peasant.obj-92469198782e682190a771b0742a26c0.mesh` (binary string scan: no `Material`/`peasant.png`), `variant3d/scripts/world3d_entities.gd:170-188,265-268`, `variant3d/assets/models/obj/peasant.mtl:1-3` | OBS; cause of null material = INF |
| 9 | `stats` counts manifest/OBJ/GLB availability, but `mesh_sources_loaded` only counts sids actually requested | `variant3d/scripts/world3d_entities.gd:94-143`, `:315-316`; `docs/coord_swarm_2026-11-24/reports/V714_world3d_entities.md:73,76,93-95` | OBS |
| 10 | `add_unit/add_building/add_resource` are **never called** by production code: whole-tree grep of `variant3d/` finds only the definitions, the API string in `stats`, and test calls. `bind()` does not scan `game.entities`; `sync()` only updates already-registered slots | `variant3d/scripts/world3d_entities.gd:450-489,517-538,555-590`, `:95-119`; `variant3d/scripts/world3d.gd:214-248,279-288`; `variant3d/scripts/main.gd:573-580,1549-1552`; `variant3d/tests/t_entities3d.gd:196-203` | OBS |
| 11 | 3D mode really instantiates `world3d.gd` (not the 2D sprite world); the 3D world has no Sprite2D/Sprite3D/billboard entity drawing | `variant3d/scripts/main.gd:573-580,1003-1022`; `variant3d/scripts/world3d.gd:71,93,214-248`; `variant3d/scripts/world.gd:3199,3224` (2D sprite path for contrast) | OBS |
| 12 | Sim spawns entities with the raw `Data` sid; nation resolution can produce further sids; nothing maps them to an OBJ alias | `variant3d/scripts/game.gd:1988-1992,3781-3786`; `variant3d/scripts/data.gd:1507-1511`; `variant3d/scripts/ai.gd:703-718` | OBS |
| 13 | 81 unit/building IDs exist in `Data` (62 + 19); only 23 have OBJ; **58 have none** incl. trainable `officer18, drummer, priest, grenadier, musk18, howitzer, mortar, dragoon17, reiter` and buildings `bar18, dip, wal, gat, dock` | `variant3d/scripts/data.gd:581-1246` (UNITS_BASE), `:1247-1302` (BUILDINGS_BASE, e.g. `:1256-1258,1260,1277-1278,1300-1301`); `manifest.json:3-...`; OBJ directory enumeration | OBS |
| 14 | Donor actually contains most missing unit meshes with matching names and textures: `data/actors/units/strelet.oss`, `pope.oss`, `drummer.oss`, `grenadier.oss`, `howitzer.oss`, `mortar.oss`, `wingedhussar.oss`, `jannisary.oss`, `hackapell.oss`, `yacht.osm`, `galley.osm`, `frigate.osm`; matching `data/materials/units/<sid>.dds` present. `musk18` has no exact file; `bar18/dip/wal/gat/dock` have no exact actor file | read-only enumeration of `C:\Games\Cossacks 3\data\actors\**` and `data\materials\units\`; `C:\Games\Cossacks 3\data\actors\actors.lib` (`LODActorName = strelet/pope/drummer/...`) | OBS (exact-name hits); name mapping for missing 5 = UNVERIFIED |
| 15 | 2D port covers most of those same IDs with donor-derived baked sprite sheets; it has an explicit alias table (`musk18->serdiuk`, etc.) and a 54-key land index + naval index. 44/58 of the 3D-missing IDs have a 2D sprite/alias; 14 are missing in 2D too (`sco_*`, `framegun`, `bar18`, `dip`, `wal`, `gat`, `dock`) | `app/scripts/world.gd:212-215,432-436`; `app/assets/models/anim/land_units/index.json` (54 keys), `app/assets/models/anim/naval_units/index.json`; `variant3d/scripts/data.gd:581-1302` | OBS |
| 16 | Every rendered entity is explicitly labelled a static bind pose; donor `.oss` has 483 frames @30 fps / 20 bones but no bone-parent hierarchy, so donor-faithful skinning is BLOCKED | `variant3d/scripts/world3d_entities.gd:41-50,75,81-82,329,484`; `variant3d/scripts/anim3d.gd:14-23,43-44,77-90`; `docs/coord_swarm_2026-11-24/reports/V72_mesh_conversion_feasibility.md:163-165,181-192,267-289,305-330` | OBS + cited prior finding |
| 17 | Env cut-out uses alpha-scissor (port approximation); donor `alphaMode` UNVERIFIED | `variant3d/scripts/world3d_entities.gd:179-183`; `manifest.json` env entries | OBS (approximation label) |
| 18 | The "6 real OBJ loads" figure came from a stub smoke with 5 entities, not a scan of the 116 assets; no visual screenshot evidence for model fidelity | `docs/coord_swarm_2026-11-24/reports/V714_world3d_entities.md:73,76,93-95`; `variant3d/tests/t_entities3d.gd:111-140,196-203`; charter `:20` ("visual parity UNVERIFIED") | OBS |

## Ranked gaps and smallest donor-grounded fixes

### P0-1 — The 3D renderer never receives any entities (blocks acceptance)

`world3d.gd` binds and syncs the entity module but never calls
`add_unit/add_building/add_resource`; `world3d_entities.bind()` does not walk
`game.entities`, and `sync()` only transforms already-registered slots
(evidence #10, #11). A 3D skirmish therefore shows terrain/FOW/FX but **no units,
buildings or resource nodes at all**; the 116 donor meshes are dead assets in
normal play. The only code that ever exercises them is the atomic test
(`t_entities3d.gd:196-203`).

**Smallest fix (no new art):** add a reconciliation pass in
`world3d_entities.bind()`/`sync(dt)` that walks the same live sim collections
the 2D world draws (`game.entities` / `game.by_id`, `game.res_nodes`; see
`variant3d/scripts/world.gd:2200-2229,2837`) and calls the existing
`add_*`/`remove` API on id-set changes. No donor bytes need to be copied; the
existing donor-derived OBJ + PNG assets are consumed as-is.

### P0-2 — 58 of 81 unit/building IDs fall back to an invented 1 m cube

Only 23 IDs have an OBJ (evidence #13). Because their sid is absent from the
manifest, `_bbox.get(sid, [])` is empty and `_proxy_mesh_raw` uses its hardcoded
cube (`world3d_entities.gd:191-213,224-225,277-282`). This affects ordinary
trainable units (`officer18, drummer, priest, grenadier, musk18, howitzer,
mortar, dragoon17, reiter`) and buildings (`bar18, dip, wal, gat, dock`); nation
resolution (`data.gd:1507-1511`) can add more (`strelet, jannisary,
wingedhussar, ...`). The cube is not even donor-bbox-derived, so the code comment
at `:191-192` ("never an invented size") is false for these sids.

**Smallest fix (donor-grounded):** extend the hardcoded table in
`variant3d/tools/convert_models.py:160-221` with the missing sids whose donor
files already exist (verified names at evidence #14), re-run the converter to
emit OBJ/MTL/PNG and append manifest rows; the loader needs no change. Priority
order: trainable units first, then ships, then the 5 buildings whose donor actor
names must be resolved from `data/actors/actors.lib` before mapping (currently
UNVERIFIED — do not guess).

### P1-3 — Units are frozen bind poses, not donor-animated models

The converter discards `.oss` weights/bones/animation and writes only the first
vertex block (`convert_models.py:43-66,109-125`); the renderer states this
explicitly (`world3d_entities.gd:41-50,75`), and `anim3d.gd` only publishes frame
numbers from AAF (`anim3d.gd:1-23,77-90`). The 2D port, by contrast, renders
baked 8-direction action frames (`app/scripts/world.gd:212-215,432-436`). So a
"3D unit" never walks, attacks or dies.

**Smallest fix:** follow the already-documented donor-readable fallback
`V72_mesh_conversion_feasibility.md:305-330`: sample the readable `.oss` bone
tracks at AAF frame ranges (`anim3d.gd:49-75`) with a flat-root joint assumption
and bake a small morph-target set per action/sid; keep every result labelled
"PORT APPROXIMATION — NOT DONOR PARITY" until visual parity is proved. Do **not**
claim donor skinning without finding parent data (BLOCKED, V7-2 Table B1).

### P1-4 — Donor albedo is applied only by a null-material fallback

Imported OBJ meshes contain no material; the donor texture appears via
`_default_material()` reading `assets/models/tex/<sid>.png`
(`world3d_entities.gd:170-188,265-268`). The generated `.mtl` uses a backslash
relative path (`peasant.mtl:3`), which is a plausible cause (INF) of the empty
material on import.

**Smallest fix:** change `write_mtl()` in `convert_models.py:128-133,343` to
emit a forward-slash `../tex/<sid>.png` and reimport; this uses the already
converted donor DDS PNGs and removes reliance on the fallback for opaque
unit/building surfaces. Keep the alpha-scissor label for RGBA env props.

### P2-5 — "6 real OBJ loads" is not a coverage proof

Only 6 distinct sids were loaded in the smoke that produced the quoted stats
(evidence #18). Fidelity of the other 110 meshes has API/geometry evidence but
no visual proof (charter `:20`).

**Smallest fix:** extend the existing headless harness to loop all 116 manifest
sids through `_mesh_info`, asserting `source == "obj_zup_bbox_normalised"`,
non-empty surfaces and AABB height equal to `bbox[5]-bbox[4]`; use the already
recorded bboxes, no new art or values.

### P2-6 — Donor model library coverage is a tiny hardcoded subset

The converter table names 9 units + 14 buildings + 93 env props
(`convert_models.py:160-308`) while the donor has hundreds of `.oss`/`.osm`
actors (read-only enumeration: 241 `.oss` + 137 `.osm` under `data/actors/units`,
3423 `.osm` under `data/actors/buildings`). This is acceptable for the current
port roster only if the 58 gaps in P0-2 are intentional.

**Smallest fix:** when extending P0-2, derive the sid→actor mapping from the
donor's own `data/actors/actors.lib` instead of adding further hand-guessed
names; leave unmapped sids explicitly tagged in stats rather than silently
serving a cube.

## Open questions

1. **Is the missing entity feed intentional?** No production wiring or pending
   handoff for `add_*` was found in `docs/` (only the API contract at
   `docs/coord_swarm_2026-11-24/V73_ATOMIC_CONTRACT.md:13`). Needs owner answer:
   is 3D mode deliberately terrain-only for this wave, or is P0-1 an integration
   defect?
2. **Which of the 58 unresolved sids actually spawn in a normal skirmish?**
   Static analysis shows trainable/nation-resolved paths, but no runtime trace
   of spawned sid frequencies exists (UNVERIFIED).
3. **Donor actor names for `bar18`, `dip`, `wal`, `gat`, `dock`** — no exact
   same-named `.osm` was found; `actors.lib` must be searched read-only for the
   correct 18th-century/dock/wall actor before any mapping is claimed
   (UNVERIFIED).
4. **Can flat-root bone sampling produce usable pose meshes?** V7-2 says per-row
   donor data is readable but the hierarchy is absent and morph paths are only
   "acceptable as approximation" (`:22-25,181-192`); this needs a visual gate,
   not a text claim.
5. **Why does the OBJ importer drop the `.mtl` material?** Binary scan proves the
   material is absent from the imported mesh; the backslash path is an
   inference, not a confirmed Godot behaviour (UNVERIFIED).
