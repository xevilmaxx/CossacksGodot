---
id: P07
owner: P07
wave: P
swarm: terrain_swarm_2026-11-25
date: 2026-11-25
scope: READ-ONLY scene/node-count audit — no runner, no Godot, no code edits
status: REPORT_ONLY
output: docs/terrain_swarm_2026-11-25/reports/P07_node_count.md
fps_claims: NONE — every performance/FPS/draw-call statement is UNVERIFIED until G04 captures
---

# P07 — scene-tree / node-count audit (variant3d startup)

## 0. Compliance and labels

- Read before auditing: `docs/terrain_swarm_2026-11-25/CHARTER.md`, `docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md` (Wave G + Wave P rows).
- **No runner job, no Godot process, no code edit, no backup created.** G04 remains sole runner owner (WAVE_G_CHARTER.md:31, :67-70).
- Files read (read-only): `variant3d/scripts/world3d.gd`, `world3d_entities.gd`, `world3d_fx.gd`, `main.gd`; supporting reads: `world3d_terrain.gd`, `world3d_fog.gd`, `water3d.gd`, `camera3d.gd`, `anim3d.gd`, `data.gd`, `scenes/main.tscn`, `project.godot`, and telemetry under `variant3d/tests/results/`.
- Labels: `[O]` observed source/telemetry, `[D]` derived from code shape, `[E]` estimate, **UNVERIFIED** = no windowed capture or profiler. **No FPS, frame-time or draw-call reduction is claimed anywhere in this report** (G04 has not captured).
- Ownership note: P11 holds exclusive implementation rights to `world3d_entities.gd` (`WAVE_G_CHARTER.md:84`, `reports/P11_entities_fix_proposal.md:20-21`). Reductions below that target that file are **proposals for COORD to reconcile with P11**, not edits. `world3d_fx.gd` / `world3d.gd` / `main.gd` have no P-implementation owner.

## 1. Startup composition — what actually builds the tree `[O]`

`scenes/main.tscn:5` is a bare `Node` with `main.gd`; every runtime node is created in GDScript.

Two startup paths build the same 3D tree:

- Async (interactive): `main.gd:586-589` `make_world3d()` → `world.bind(game)` → `add_child(world)`; `main.gd:596-599` `make_camera3d()` → `add_child(camera)` → `camera.bind(game, world.view_scale)`; HUD/input/audio at `:622-651`; one extra `world.sync(0.0)` behind the overlay at `:661-662`.
- Sync (`--screenshot`, selftest, bench): `main.gd:1103-1176`, same order.

`world3d.gd:599-623` `bind()` instantiates **five module nodes once** (`terrain`, `entities`, `fx`, `fog`, `anim`) via `_instantiate()` (`:208-221`, `add_child` at `:220`) plus one `FogVisibilityProxy3D` Node3D (`:620-622`). `fx_layer` is an alias of the FX node (`:610-611`); the fallback holder at `:613-616` only fires if FX failed to load — not the normal path. `_modules_ready` (`:603`, `:623`) prevents duplication on rebind. **No duplicate module instances found** `[O]`.

Module child counts at bind (all `[O]` from source, confirmed by telemetry where noted):

| Owner | Nodes created on bind | Evidence |
|---|---|---|
| `world3d.gd` | 5 modules + 1 proxy = **6 direct children** | `:603-623` |
| `world3d_terrain.gd` | 1 `HeightmapTerrain` MeshInstance3D + 1 water surface (module node with its own MeshInstance3D child, **or** fallback `WaterPlane`) + 1 `WorldEnvironment` + 1 `DonorSun` DirectionalLight3D ≈ **5-6 nodes** | `:1547-1556`, `:1559-1564`, `:1194-1246`; tree confirmed by `tests/results/v760_light_probe.json:121-127` |
| `world3d_fog.gd` | 1 overlay MeshInstance3D | `:206-214` |
| `anim3d.gd` | 0 (`extends Node`, no children) | `anim3d.gd:55`, `:133` |
| `world3d_fx.gd` | **11 nodes** in `_ensure_roots()` (see §3) | `:893-940`, `:973-1005` |
| `world3d_entities.gd` | 0 at bind; all entity nodes are added lazily by the feed at first `world.sync(0.0)` / first real sync | `world3d.gd:329-410`, `:642`, `:689` |

## 2. Node count per entity type `[O]` / `[D]`

### Building — 1 permanent node each, + optional children
- `add_building()` creates exactly **one `MeshInstance3D`** per building, `cast_shadow = ON`, stored in `_nodes[id]` — `world3d_entities.gd:1645-1682` (`:1661` new, `:1679` cast, `:1680` add_child).
- Mill (`sid == "mil"`) adds **one `MeshInstance3D` rotor child** (`_attach_rotor`, `:1765-1782`; called at `:1685-1686`).
- Unfinished building adds **one scaffold `MeshInstance3D` child** in `_sync_building_stages()` (`:1905-1915`), **freed when `finished`** (`:1900-1903`). It is `visible = false` when no donor `<sid>Na..4a` art resolves (`:1922-1928`).
- `[D]` cost: 1 + (0/1 rotor) + (0/1 scaffold) nodes per building; one draw call per building (already noted in `reports/P11_entities_fix_proposal.md:42`). Sun shadows are OFF (`world3d_terrain.gd:1233-1241`), so `cast_shadow = ON` is currently inert (P11 §1 #7).

### Unit — 0 nodes per unit (already batched)
- `add_unit()` only acquires a slot in a `MultiMeshInstance3D` batch (`:1597-1642`); key `"unit|<sid>[|p<player>]"` for static, `"unit|<sid>|p<player>|a<action>|f<frame>"` for morphed (`:1625-1630`, `:2094-2104`).
- `[O]` No per-unit `Node3D` exists. `[D]` node count grows with **distinct batch keys**, not with unit count.

### Tree / mine / field / stone / bush / stump — 0 nodes per resource
- `add_resource()` acquires one instance in batch `"res|<sid>"` (`:1964-1985`). `_pick_sid()` picks from fixed pools (`:173-179`, `:1957-1961`).
- `[O]` Telemetry: `tests/results/t_terrain_trees.json:230-231` — **14 tree batches for 20 trees**; `t_combo_trees_mines.json:189-200` — **15 batches for 29 resources** (19 tree instances, 3 gold, 3 iron, 3 coal). Each of those batches is one `MultiMeshInstance3D` node. `[D]` node count ≈ distinct donor sids, not res-node count (317 res nodes in `t_pick_res.json:4` still only produce a handful of batch nodes).

### FX item — 2-4 nodes per active effect
- `add_fx()` creates a holder `Node3D` (`:536-539`) then `_build_visual()` adds 1-2 `MeshInstance3D` children (`:1107-1196`; `shot` 1 mesh + 1 OmniLight, `smoke` 2 meshes, `explode` 1 mesh + 1 light, `fire` 2 meshes + 1 light, others 1 mesh). `_add_mesh` / `_add_light` at `:1043-1061`.
- Cap `Data.FX_CAP` = 220 at high quality (`data.gd:152`, `:193`; low/medium 60/120 at `:187`, `:190`); `_enforce_cap()` at `world3d_fx.gd:1506-1514`.
- `[D]` worst case high quality: up to **220 holders + 220-440 MeshInstance3D + up to 220 OmniLight3D** nodes alive simultaneously in a busy battle. Zero at t=0 — this is a hot-path cost, not literal startup bloat.

## 3. Hidden-but-present nodes `[O]`

| # | What | Count | File:line | Notes |
|---|---|---|---|---|
| H1 | Snow weather layer built at **bind** and hidden by default: `WeatherSnow3D` Node3D + 4 `GPUParticles3D` (`Snow1..4`), each with a `QuadMesh` draw pass, `emitting = false`, `amount` 100/100/100/200, lifetime 8 s | **5 nodes** (1 root + 4 emitters) | `world3d_fx.gd:935-939`, `:973-1005`, gate `:954-966` | Default `Weather = 40` < band 70..100 (`:165-169`), so all 5 exist but draw nothing. `[D]` still scene-tree entries + particle resources. |
| H2 | Build ghost: `BuildGhost3D` Node3D (`visible = false`) + `Footprint` MeshInstance3D + `GhostBuildingFinished` MeshInstance3D | **3 nodes** | `world3d_fx.gd:899-925`, `:1491-1501` | Created by `_ensure_roots()` from `bind()` (`:319`); `Footprint` is a fallback only, hidden whenever base/last-stage art resolves (`:621-637`). |
| H3 | Construction scaffold child per unfinished building, `visible = false` when no converted stage art | **1 per unfinished building** | `world3d_entities.gd:1898-1929`, `:1926` | Freed on `finished` (`:1900-1903`). Comment at `:1923-1925` explicitly keeps the node for donor-child lifecycle even when hidden. |
| H4 | Empty **MORPH** batch nodes deliberately kept alive (never freed even with `visible_instance_count = 0`) | **unbounded by visited donor frames** `[D]` | `world3d_entities.gd:1505-1507` (STATIC empties are freed at `:1508-1512`), created at `:1401-1438` | `[D]` each retained node also holds a 4096-slot `MultiMesh` (`:1417`, P11 §1 #2). Magnitude **UNVERIFIED** — no captured `donor_morph_frames` / `_batches.size()` telemetry JSON found. |
| H5 | Hidden resource instances kept in-batch at `HIDDEN_SCALE = 0.0001` instead of removed (dead/hidden/exhausted finite nodes) | 0 nodes, but instances still occupy MultiMesh slots | `world3d_entities.gd:117`, `:1539-1548`, `:1589` | Deliberate: O(1) swap-removal semantics. Not a node-count cost; mentioned for completeness. |
| H6 | Water surface kept hidden when height-driven water module has no visible plane | 1 `MeshInstance3D` | `world3d_terrain.gd:1559-1563`; `t_combo_trees_mines.json:41` ("WaterPlane nodes=1 visible=0 (module-owned, hidden not deleted)"), `:222-223` (`visible_water_planes: 0`, `water_3d_node_count: 1`) | Adjacent to P07 scope; never stacked (`:1560`). |
| H7 | `FogVisibilityProxy3D` Node3D — write-only sink for `world.fog_sprite.visible = on` | 1 | `world3d.gd:617-622`; caller `main.gd:1562` | 3D fog reads `Data.FOG_OF_WAR` directly (`world3d_fog.gd:317`), so the write is visual no-op in 3D. |

**Selection / hover / ghost / footprint nodes** `[O]`: selection = one holder + 3 children (`Ring`, `UnderRing`, `OwnerPip`) per selected id (`world3d_fx.gd:1254-1288`), set-semantics cleanup at `:747-751` / `:1327-1337`; confirmed by `tests/results/fixselvis_probe.json:21-24` (`SelRing_11`, `SelRing_22`) and `:73-80` (count 0 after clear). Rally = one holder + 4 children per rally point (`:1199-1230`), TTL 2 s with deferred `queue_free` (`:1476-1487`). Ghost = H2. **No hover/preview node exists** — grep for `hover|highlight|preview` in `world3d_fx.gd` returns only ghost/rally/selection code; `main.gd` and `world3d.gd` create none.

## 4. Duplicate environment / camera / light rigs — NONE FOUND `[O]`

- `make_world3d()` and `make_camera3d()` (`main.gd:1037-1056`) are each called **once per startup path** (`:587`/`:597` async, `:1104`/`:1108` sync). One `Camera3D` (`camera3d.gd:52`), `make_current()` at `camera3d.gd:226`. No second camera in the normal path.
- Exactly **one `WorldEnvironment` + one `DirectionalLight3D`**, both created inside `world3d_terrain.gd:_make_environment()` (`:1194-1246`), called once per `build()` (`:1564`); `invalidate()` frees all children first (`:1249-1253`) so a rebuild cannot stack rigs. Confirmed by `tests/results/v760_light_probe.json:121-127` (4-child tree: HeightmapTerrain, WaterPlane, WorldEnvironment, DonorSun).
- `heightmap_world3d.gd` (which also has `_make_environment()` at `:114-147`) is **not loaded at runtime** — only referenced in comments (`world3d_terrain.gd:5,27,139`, `picking3d.gd:20`). `terrain3d_sandbox.gd` is a separate scene, not the main scene (`project.godot:8`).
- Screenshot mode creates a `SubViewport` with its own `World3D` (`main.gd:1241-1253`) but **reparents** the existing world and camera into it; it does not duplicate the rigs.
- Extra lights exist only transiently per FX item (`world3d_fx.gd:1054-1061`) — see §2 FX row; not a duplicate sun/environment rig.

## 5. Orphan timers / tweens — NONE FOUND `[O]`

- Grep of all four target files for `Timer`, `create_tween`, `Tween`, `SceneTreeTimer` returns **no matches**. Animation/FX timing is accumulated from `dt` in `world3d.gd:683` (`anim_t`), `world3d_entities.gd:2019` (`_anim_t`), `world3d_fx.gd:510-511` (`_time`), and `anim3d.gd` own clock — no scene-tree timer nodes to orphan.
- Deferred frees: `world3d_fx.gd:787`, `:1484`, `:1520` use `queue_free()`; they leave nodes for at most one frame, and `clear_all()` clears the dictionaries (`:779-799`). Entities intentionally use synchronous `free()` (`world3d_entities.gd:1995-1997`, `:1509-1511`) so no ghost node survives a frame.

## 6. Ranked by likely cost (cost = node count × persistence × per-node work) `[D]` — ALL UNVERIFIED

| Rank | Item | Owner file:line | Why ranked here |
|---|---|---|---|
| 1 | Empty MORPH batches never freed (H4) | `world3d_entities.gd:1505-1507`, `:1401-1438` | Only **unbounded/growing** node source; each carries a 4096-slot MultiMesh. Real magnitude UNVERIFIED (no telemetry). |
| 2 | One MeshInstance3D per building + hidden scaffold + rotor child | `world3d_entities.gd:1661-1682`, `:1765-1782`, `:1898-1929` | Linear in building count, permanent; dominant entity node count on a built-up map. |
| 3 | 4 GPUParticles3D snow emitters + root created at bind, hidden (H1) | `world3d_fx.gd:935-939`, `:973-1005` | Constant 5-node startup cost + particle resources, entirely avoidable at default Weather=40. |
| 4 | Transient FX holders/meshes/lights up to FX_CAP=220 | `world3d_fx.gd:536-539`, `:1043-1061`, `:1107-1196`, `data.gd:152` | Not startup (0 at t=0) but up to ~hundreds of nodes + lights during play; 2-4 nodes per effect. |
| 5 | Selection markers: 4 nodes per selected id | `world3d_fx.gd:1254-1288`, `:747-751` | 1 id selected at startup (`main.gd:646`), but scales with army selection; set semantics bound it. |
| 6 | Ghost 3 nodes always present (H2) | `world3d_fx.gd:899-925` | Constant, hidden, only needed in build mode. |
| 7 | Rally markers: 5 nodes each, TTL 2 s | `world3d_fx.gd:1199-1230`, `:1476-1487` | Only for selected buildings with a `rally` field; deferred free. |
| 8 | world3d.gd 6 direct children incl. proxy (H7) | `world3d.gd:603-623` | Small, fixed; no duplication. |
| 9 | Terrain environment rig + water surface | `world3d_terrain.gd:1194-1246`, `:1559-1564` | Necessary and single; its *rendering* cost is P05's scope, not node count. |
| 10 | Loading overlay (8 nodes) + menu, created and freed during startup | `main.gd:462-507`, `:517-524`, `:250-254`, `:267`, `:541` | Transient; gone before steady-state gameplay. |

## 7. Safe (visible-identical) reductions — proposals, not edits

All reductions below remove nodes that draw nothing or merge nodes whose geometry/transform/materials are preserved. Every one requires G04 windowed A/B before any visual claim.

| # | Change | Exact owner file | Why visible-identical / guardrail |
|---|---|---|---|
| R1 | **Lazy snow layer**: do not call `_build_snow_emitters()` in `_ensure_roots()` when `not _snow_band_ok()`; build on first `set_weather`/`set_weather_month` that enters the 70..100 band. Keep `_apply_snow_gate()` semantics and `stats` keys. | `variant3d/scripts/world3d_fx.gd` — `_ensure_roots():935-940`, `_build_snow_emitters():973-1005`, `set_weather():345-350`, `set_weather_month():352-355` | Default Weather=40 → layer hidden and `emitting=false` today (`:954-966`); removing 5 hidden nodes changes no pixel. Must still build before the first frame where the band turns on. |
| R2 | **Lazy ghost layer**: create `BuildGhost3D` + its two children only on the first `draw_ghost()` with a valid sid, not at `bind()`. `_ensure_roots()` then creates only FX/Rally/Selection roots. | `variant3d/scripts/world3d_fx.gd` — `_ensure_roots():898-925`, `draw_ghost():580-604` | Ghost root is `visible=false` until a build preview begins (`:1491-1494`); no pixel changes. Guard: `_update_ghost()` and `_shift_created_nodes()` must null-check (they already do at `:1492`, `:448`). |
| R3 | **Flatten FX item holder**: make the `MeshInstance3D` itself the item root (apply holder transform to it) instead of `Node3D` holder + mesh child; keep the separate `item["mesh"]` child only for the `arrow_trail` branch that mutates `QuadMesh.size`. | `variant3d/scripts/world3d_fx.gd` — `add_fx():536-539`, `_add_mesh():1043-1051`, `_build_visual():1107-1196`, `_update_fx():1356-1418`, `_orient_trail():1421-1440` | Halves nodes per FX item; transforms and materials identical. Highest-risk of the FX reductions — requires G04 A/B on shot/smoke/explode/trail captures before landing. |
| R4 | **Skip hidden scaffold node until art exists**: in `_sync_building_stages()`, create the scaffold child only inside the `if sc_art` branch; on a later art change create it then. Keep lifecycle (free on `finished`) and metadata identical. | `variant3d/scripts/world3d_entities.gd` — `_sync_building_stages():1898-1929` (POSSIBLE CONFLICT: P11 owns this file; COORD must reconcile) | Hidden node draws nothing (`:1926`); visible art path unchanged. Must preserve donor-child sync semantics documented at `:1923-1925`. |
| R5 | **Free empty MORPH batches** after an idle grace period (e.g. retain only the N most recently used frames) instead of forever; keep STATIC behaviour as-is. | `variant3d/scripts/world3d_entities.gd` — `_release():1505-1512`, `_new_batch():1401-1438` (POSSIBLE CONFLICT: P11 owns this file) | Bounded node growth; no visible change because `visible_instance_count == 0`. Needs `donor_morph_frames` telemetry to size the cap. Coordinate with P11's capacity work (`:1417`). |
| R6 | **Alias the fog proxy** to an existing no-op-safe node or replace with a data field, avoiding `FogVisibilityProxy3D.new()`; keep `main.gd:1562`'s `world.fog_sprite.visible` write legal via an unbranched shim. | `variant3d/scripts/world3d.gd` — `:156`, `:617-622`; caller `main.gd:1562` (2D-shared, do NOT edit) | Saves 1 node. Only safe if the shim keeps the 3D fog behaviour (`world3d_fog.gd:317` reads `Data.FOG_OF_WAR` directly). Lowest priority. |
| R7 | **Combine selection ring + under-ring + pip into one multi-surface `ArrayMesh`** per marker (3 materials kept as surfaces), and rally pole/finial/foot/flag similarly. | `variant3d/scripts/world3d_fx.gd` — `_make_selection_marker():1254-1288`, `_make_rally():1199-1230` | Geometry/colours identical, but surface sorting may differ — **not proven visible-identical**; list as conditional pending G04 A/B, do not land first. |

Explicitly **not** proposed here (already covered elsewhere or NO_WIN): MultiMesh buffer sizing / tint-material caching (`reports/P11_entities_fix_proposal.md:52-60`), building→MultiMesh batching (same report Tier 2, deferred/high risk), shadow-flag flips (inert while sun shadows OFF), resource sid/primitives changes, donor art substitutions.

## 8. Telemetry used `[O]`

| File | Value used |
|---|---|
| `tests/results/v734_entities3d.json:19-27,44-48` | isolated module `before=1 peak=6 after=1` nodes — no leak on add/remove in that probe |
| `tests/results/v760_light_probe.json:121-127` | terrain tree = HeightmapTerrain + WaterPlane + WorldEnvironment + DonorSun (single rig) |
| `tests/results/t_terrain_trees.json:230-231` | 14 tree batches / 20 trees |
| `tests/results/t_combo_trees_mines.json:189-200,222-223` | 15 batches / 29 resources; 1 hidden water node |
| `tests/results/t_pick_res.json:4` | 317 res nodes, illustrating resources do not create per-node nodes |
| `tests/results/fixselvis_probe.json:21-24,73-80` | 2 selection markers created and cleared (4 nodes each per code) |
| `tests/results/t_perf_scale.json:11,19,27` | 314 / 1004 / 3000 units exercised; **no `batches`/`donor_morph_frames` telemetry** captured there |
| `tests/results/t_terrain_trees.json:185-194,220-226` | draw calls / frame time recorded as 0.0 under headless dummy renderer — **not usable for FPS** |

## 9. UNVERIFIED register

| Item | Status |
|---|---|
| Any FPS / frame-time / draw-call improvement from R1-R7 | **UNVERIFIED** — no runner, no windowed capture; G04 must capture before any claim. |
| Number of retained empty MORPH batch nodes in a real game | **UNVERIFIED** — no captured `donor_morph_frames` / `_batches.size()` value in any telemetry JSON. |
| Total scene-tree node count on the real 160×160 map | **UNVERIFIED** — derived estimate only; no `get_tree().get_node_count()` capture exists. |
| Hidden GPU cost of 4 `GPUParticles3D` emitters while `emitting=false` | **UNVERIFIED** — gl_compatibility behaviour needs a windowed probe. |
| Visual identity of R3/R7 | **UNVERIFIED** — require G04 windowed A/B against the current P0/real-map frames. |
| Duplicate rigs / orphan timers | **VERIFIED NEGATIVE from source + telemetry** (§4, §5); still no runtime tree dump of the full game. |
| Donor parity | **NONE CLAIMED** — all port labels remain `PORT APPROXIMATION — NOT DONOR PARITY`; visual UNVERIFIED. |

*End of P07 report. No code was edited and no Godot process was started by P07.*
