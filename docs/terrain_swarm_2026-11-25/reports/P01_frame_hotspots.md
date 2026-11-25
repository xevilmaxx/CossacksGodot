---
id: TERRAIN-SWARM-WAVE-P-P01
title: "P01 — code-level per-frame FPS hotspot inventory (READ-ONLY)"
owner: P01
created: 2026-11-25
status: COMPLETE
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "No Godot run, no runner job, no capture and no frame-time measurement was made (only G04 runs Godot). No code was edited. Every cost below is an OBSERVED source fact plus a DERIVED/INFERRED cost reading; no FPS or millisecond claim is made. Measured FPS claims are UNVERIFIED without a capture (WAVE_G_CHARTER.md Wave P). No donor-parity claim is made."
---

# P01 — per-frame work inventory across `variant3d/scripts`

## 0. Method and scope

Read-only static audit of every `*.gd` under `variant3d/scripts/` (32 files). Searched for
`func _process`, `_physics_process`, `_draw`, `_notification`, `_unhandled_input`, signal
callbacks, `update`/`queue_redraw`, `get_node`/`find_node`/`get_child(ren)`, `for` loops over
`entities`/`res_nodes`/`_slot`/`_nodes`/`_batches`, and per-frame allocations (`Dictionary`,
`Array`, `String`/`%` formatting, `Rect2`/`Vector4i`/`Transform3D` construction).
Followed every callee that runs on the rendered-frame path from `main.gd:_process`.

**There is no `_physics_process` anywhere in `variant3d/scripts`.** The sim is stepped inside
`main.gd:_process` (`:1621-1631`) at `Data.FPS = 32.0` (`data.gd:32`).

Default mode is **3D** (`variant3d/config.json:74` `"render_mode": "3d"`; the `"2d"` literal at
`main.gd:124` is overridden by config at `main.gd:185`). The 2D `world.gd` path is therefore
*not* the shipped hot path, but its sync is listed for completeness (row 2 of §2).

### Evidence labels

| Label | Meaning |
|---|---|
| `[O]` OBSERVED | Exact code/line exists in the current tree; quoted literally. |
| `[D]` DERIVED | Cost class derived mechanically from observed code (loop bounds, allocation count, call cadence). No timing. |
| `[I]` INFERRED | Relative ranking / likely dominance argument from structure. May be wrong. |
| `[U]` UNVERIFIED | Needs a real capture, profiler or GPU call; explicitly not claimed here. |

---

## 1. The per-frame call graph (all nodes reached from `main.gd:1587`)

```
main.gd:1587 _process(dt)                         [O] every rendered frame
 ├─ :1593-1594 test_bridge.poll()                 [O] cheap when no peer (testbridge.gd:24-53)
 ├─ :1616-1631 while acc>=step, steps<64:          [O] 0..64 sim steps/frame (32 Hz accumulator)
 │    ├─ game.tick(step)                           [O] game.gd:4281
 │    │    ├─ _grid_rebuild()                      [O] game.gd:261  — clears + rebuilds grid over ALL entities
 │    │    ├─ for e in entities ... _tick_unit     [O] game.gd:4309-4315 — full-array scan
 │    │    ├─ _separate_units()                    [O] game.gd:4353 — new hash + 9-cell×2 passes
 │    │    ├─ _tick_upkeep / _tick_cleanup          [O] game.gd:4455 / :4529 — full scans
 │    │    └─ _tick_fields, tick_market, _check_victory [O] game.gd:2648 / :3936
 │    └─ for brain in ais: brain.tick(step)        [O] ai.gd:67 — early-out after :74 until 1 s think tick
 ├─ :1640-1652 PERF print every 120 frames         [O] I/O, amortised
 ├─ :1669-1672 world.sync(dt)                      [O] EVERY frame (no paused gate)
 │    ├─ world3d.gd:682 sync
 │    │  ├─ _update_view_rect()       :247         [O] 4 camera raycasts + Array/Vector2 alloc
 │    │  ├─ _sync_selection()         :297         [O] game.get_selected():2979 = full entity scan
 │    │  ├─ _sync_selection_aura()    :535         [O] builds fresh Array of Dictionaries
 │    │  ├─ _sync_build_ghost()       :463         [O] idle = one draw_ghost("") call
 │    │  ├─ _sync_rally()             :505         [O] FULL game.entities scan, every frame
 │    │  ├─ _reconcile_entities()     :329         [O] FULL game.entities scan; res half gated :380-389
 │    │  ├─ entities.sync(dt)         :2014        [O] TWO full _slot passes + morph/stage/field/rotor/stats
 │    │  ├─ fx.sync(dt)               :509         [O] loop all fx_items, Array alloc, rally/ghost/selection
 │    │  └─ fog.sync(dt)              :116         [O] timer gate + FOG_OF_WAR=false early-out (config:47)
 │    └─ (2D port: world.gd:2072 sync — queue_redraw + chunk bake, NOT default)
 ├─ :1673-1712 journey camera block               [O] journey_mode only
 ├─ :1713 _consume_events()                        [O] :1745-1795, bounded by game.events per frame
 ├─ :1714-1721 walk-sound entity scan              [O] every 1.25 s, breaks on first hit
 └─ :1722 frame += 1

independent per-frame callbacks:
 hud.gd:1437 _process            camera3d.gd:589 _process     camera.gd:139 _process (2D)
 input_controller.gd:1484 _process  water3d.gd:111 _process   audio.gd:150 _process (0.4 s gate)
 terrain3d_sandbox.gd:127 _process (capture tool only, not gameplay)
 hud3d_adapter / anim3d / world3d_terrain / picking3d / menu.gd: no _process
```

`world3d.gd`, `world3d_entities.gd`, `world3d_fx.gd`, `world3d_fog.gd`, `hud3d_adapter.gd`,
`anim3d.gd` and `picking3d.gd` have **no** `_process`: they are driven from `main.gd` /
`world3d.sync`. Every one of their `sync()` functions is therefore still per-frame work.

---

## 2. Full inventory (every per-frame site found)

| # | File:line | Cadence | Work done | Allocations / lookups | Label |
|---|---|---|---|---|---|
| 1 | `main.gd:1587`, `:1616-1631` | every frame | up to 64 `game.tick` + `ai.tick` steps, accumulator + `Time.get_ticks_usec()` ×3/step | none besides loop locals | `[O]` 0–64 steps `[D]` |
| 2 | `main.gd:1671` → `world3d.gd:682` | every frame | 7 sync sub-calls (see graph) | fresh Dictionaries/Arrays downstream | `[O]` |
| 3 | `world3d.gd:247-293` `_update_view_rect` | every frame | `get_viewport_corners()` → 4 ray origin+normal computations (`camera3d.gd:397-404`), 4-corner min/max | `Array`, up to 4 `Vector2`, `Rect2` | `[O]` 4 raycasts/frame `[D]` |
| 4 | `world3d.gd:297-319` `_sync_selection` | every frame | `game.get_selected()` full scan of `entities` (`game.gd:2979-2984`), clear + rebuild two mirrors | `Array out`, per-item `_int_prop` | `[O]` O(N_entities) `[D]` |
| 5 | `world3d.gd:535-559` `_sync_selection_aura` | every frame | for each selected id: lookup, `_entity_by_id` fallback scan (`world3d.gd:565-576`), `_selection_radius` | **fresh `Dictionary` per selected entry**, fresh Array | `[O]` |
| 6 | `world3d.gd:463-498` `_sync_build_ghost` | every frame | idle: `fx.draw_ghost("")`; build mode: `in_bounds`, `resolve_mine_sid`, `can_place`, `Data.BUILDINGS.has` | none material | `[O]` gated by ghost active |
| 7 | `world3d.gd:505-523` `_sync_rally` | every frame | **full scan of `game.entities`** (all units + buildings), `_prop` lookups per entity | none, but O(N) | `[O]` O(N_entities)/frame `[D]` |
| 8 | `world3d.gd:329-410` `_reconcile_entities` | every frame | full `entities` scan + full `_feed_entity_ids` key scan; res half scans all `res_nodes` only when `res_dirty`/size changed | `live_ents` Dictionary, `live_res` Dictionary on rebuild | `[O]` entity half ungated `:332-358`; res gated `:380-389` |
| 9 | `world3d_entities.gd:2014-2299` `sync` | every frame | Pass 1 `:2044-2127` over all unit slots; Pass 2 `:2129-2142` over **all** slots; `_sync_building_stages` `:2151`; rotor billboard `:2163-2184`; field states `:2196-2248`; stats `:2249-2295` | many Dictionaries/Arrays/Transform3D — see §3 #1 | `[O]` O(N_slots)×2 `[D]` |
| 10 | `world3d_entities.gd:1226-1237` `_measure_speed` | every unit, every frame | speed from pos delta; `{"pos":…,"t":…}` written per unit | **1 fresh Dictionary per unit per frame** | `[O]` |
| 11 | `world3d_entities.gd:1551-1593` `_xf` | every slot, every frame | `Basis().rotated().scaled()` + `Transform3D`, `_face_smooth`/`_slot` lookups, jitter hash | 1 `Basis` + 1 `Transform3D` per instance | `[O]` |
| 12 | `world3d_entities.gd:1308-1397` `_morph_mesh` | per new `(sid,action,frame)` | builds ArrayMesh, `corner_map` Dictionary keyed by `str(vi)+","+str(ui)`, face-normal loop, material lookup | `Packed*` ×4, `Dictionary`, `Array dst[ARRAY_MAX]`, `ArrayMesh` | `[O]` cached by key `:1310-1312`; frame advances ~sim rate `[D]` |
| 13 | `world3d_entities.gd:1851-1936` `_sync_building_stages` | every frame | loops all `_nodes`; `_mesh_info` (cached), 5× `set_meta`, scaffold lifecycle, stage histogram | `stage_hist` Dictionary, metadata writes | `[O]` O(N_buildings) `[D]` |
| 14 | `world3d_fx.gd:509-519`, `:1356-1418` `_update_fx` | every frame | age all `fx_items`, `match str(kind)`, material/light updates | **fresh `keep: Array` every frame**, `str()` per item | `[O]` O(N_fx) `[D]` |
| 15 | `world3d_fx.gd:1476-1488` `_update_rally`, `:1491-1501` `_update_ghost` | every frame | expire rally markers; pulse ghost material (`sin`) | `stale: Array`, `Color` | `[O]` |
| 16 | `world3d_fx.gd:732-...` `sync_selection` | every frame | rebuild `want` Dictionary of selection entries, create/remove ring markers | fresh Dictionary; fresh nodes on change | `[O]` |
| 17 | `world3d_fog.gd:116-125` `sync` | every frame | timer gate `FOG_INTERVAL`; `_update_fog` `:231-318` full entity scan + per-unit tile-circle expansion + full-map pass | `_fog_last_pos` Dictionary of positions | `[O]` fog off at start (`config.json:47`) → early-out `[D]` |
| 18 | `hud.gd:1437-1523` `_process` | every frame | fps EMA, 6-resource string loop `:1454-1480`, status/hint labels, `mm_timer`, viewport box, `sel_timer` | `str()`/`%` ×~12/frame, `Color` on change, `Vector4i` | `[O]` |
| 19 | `hud.gd:1666-1704` `_draw_minimap_viewport_box` | every frame | gets camera 2D, adapter box → **`camera3d.get_viewport_corners()` again (4 raycasts)**, border repaint, `minimap_tex.update()` on change | `Rect2`, `Vector4i`, image upload on change | `[O]` |
| 20 | `hud.gd:1968-2035` `_update_minimap` | every `MINIMAP_INTERVAL` = 0.25 s (default `data.gd:154`) | duplicate 240×240 image ×2–3, mine markers, all `res_nodes`, building/unit blips, full `live_units` scan `:1835-1892` | 2–3 `Image.duplicate()` of 57,600 px, many Arrays/Dicts | `[O]` throttled `[D]` |
| 21 | `hud.gd:1289-1340` `_update_dynamic` | every 0.75 s | `game.get_selected()` full scan, `cur.filter(lambda)`, per-button affordability | `Array ids`, filtered Arrays, label strings | `[O]` throttled `[D]` |
| 22 | `hud.gd:1363-1435` `_recompute_eco` | every 0.5 s | full `live_units` + `live_blds` scans, per-resource dicts | `counts`, `consume_raw`, `uw`, per-eat `Dictionary` | `[O]` throttled `[D]` |
| 23 | `input_controller.gd:1484-1554` `_process` | every frame | drag rect via `_drag_world_rect`, ghost handoff, marquee draw, patrol route, hint chain, cursor | `Rect2` ×2, hint strings via `%` **built every frame** before `show_hint` no-ops | `[O]` |
| 24 | `input_controller.gd:1513-1515` ghost handoff | every frame in build mode | `_screen_to_world(mouse)` = camera ray/plane intersect | `Vector2` | `[O]` |
| 25 | `input_controller.gd:1534-1535` → `:671-702` `_apply_rect_selection` | every frame **while dragging** | full `game.entities` scan, optional Shift-merge via `get_selected()`, id sort + duplicate | `Array arr`, `Dictionary seen`, 2 sorted id Arrays | `[O]` drag only `[D]` |
| 26 | `input_controller.gd:1566-1639` `_update_cursor` | throttled (mouse >3 px or >80 ms, `:1589-1594`) | `_pick` (`picking3d.pick` in 3D) + `_pick_res`; full selection scan | `_selected` loop, `Vector2` | `[O]` |
| 27 | `camera3d.gd:589-686` `_process` | every frame | smooth zoom, mouse edge/dwell/arrow polls, `Input.is_*` ×6, `clamp_pos()` | `Vector2` ×several | `[O]` cheap `[I]` |
| 28 | `camera.gd:139-...` `_process` | every frame (2D only) | same class of work as #27 | `Vector2` | `[O]` not shipped default |
| 29 | `water3d.gd:111-115` `_process` | every frame | `_material.set_shader_parameter("time", _time)` | none | `[O]` trivial CPU `[D]`; GPU cost is P05 |
| 30 | `audio.gd:150-...` `_process` | every 0.4 s | scan `game.live_blds` for mill/town, water-cell window | `Vector2` | `[O]` throttled `[D]` |
| 31 | `main.gd:1745-1795` `_consume_events` | every frame | `for ev in game.events`, spawn FX/audio, clear | `Array` literals per event | `[O]` bounded by spawned events `[D]` |
| 32 | `game.gd:261-286` `_grid_rebuild` | every sim step (32 Hz) | `grid.clear()`, 3 live lists cleared, full `entities` scan, `Vector2i` cell key per entity, `Array` per occupied cell | **1 `Vector2i` + 1 per-cell Array per entity per step** | `[O]` O(N)×32/s `[D]` |
| 33 | `game.gd:4353-4440` `_separate_units` | every sim step | new `lgrid` Dictionary + `units` Array, 2× 9-cell neighbour passes, building-query pass | Dictionary + Arrays + `Vector2` per pair | `[O]` O(N)×2×32/s `[D]` |
| 34 | `terrain3d_sandbox.gd:127-136` `_process` | capture tool only | `Performance.get_monitor` counters from frame 5 | none | `[O]` not gameplay |
| 35 | `menu.gd:108`, `input_controller.gd:762` `_unhandled_input` | input-driven | menu/order handling; `size_changed`/`resized` connected handlers | — | `[O]` not per frame |

**`update()` on Controls:** zero literal `.update()` calls in `variant3d/scripts` (grep: no
matches). All redraws are Godot-4 `queue_redraw()` and only in the **2D** `world.gd`
(`:1965`, `:2104-2124`) and `input_controller.gd:134` (2D painter) / `:563` (3D route node,
patrol mode only). The 3D HUD uses dirty-flagged text (`hud.gd:1465-1480`, `:1482-1495`,
`:1502-1504`, `show_hint` `:1342-1346`) so identical strings don't relayout. `[O]`

**`get_node`/`find_node` in hot paths:** no `find_node` anywhere. `get_node_or_null` appears
only in `terrain3d_sandbox.gd:111/116/122` (`_ready`) and `world3d_terrain.gd:1182` (build-time).
The hot path uses `get_children()` once in `_find_anim()` (`world3d_entities.gd:1174-1182`,
memoised by `_anim_checked`) and `get_viewport()/get_camera_3d()` in `_update_view_rect`.
No per-frame tree search is present. `[O]`

---

## 3. Top-10 table — ranked by estimated per-frame cost (worst first)

Ranking is a **structural estimate** `[I]`: loop multiplicity × work per iteration × cadence.
It is **not** a timing. All absolute ms/FPS values are `[U]`.

| Rank | Hotspot (exact file:line) | Cadence / bound | Why it ranks here | Evidence |
|---|---|---|---|---|
| **1** | `world3d_entities.gd:2014-2142` — `sync()` Pass 1 (`:2044-2127`) + Pass 2 (`:2129-2142`), `_xf()` `:1551-1593`, `mm.set_instance_transform` `:2142` | **every frame**, 2 full passes over `_slot` = all units **+ every fed resource node** (forest/ore/field/bush) | Only place that touches *every* rendered instance twice per frame. Pass 1 allocates a Dictionary per unit (`_measure_speed` `:1236`), does dynamic `anim.call("has_skin",sid)` `:2071-2072`, string memo keys `:2073`; Pass 2 rebuilds `Basis`/`Transform3D` and pushes each to the MultiMesh. On a 240×240 map (`config.json:75-76`) forest stamps add up to 14 wood per mask (`game.gd:826-836`) and bushes at 0.10/cell (`:853-856`); all are fed as MultiMesh instances (`world3d.gd:392-405`). O(N_instances) ×2 ×60/s. | `[O]` code, `[D]` O(N)×2 bound, `[I]` dominant CPU item at start, `[U]` ms |
| **2** | `world3d.gd:682` → `_sync_rally` `:505-523`, `_reconcile_entities` `:329-358`, `_sync_selection` `:297-319` → `game.gd:2979` | **every frame**, each a full scan of `game.entities` (+ `_feed_entity_ids` key scan) | Three independent full-array scans per frame, none dirty-gated on the unit side (the resource half alone is gated at `:380-389`). `get_selected()` itself re-scans all entities. Combined with #1 this is ~5 full traversals of the same collection per rendered frame. | `[O]`, `[D]` O(N)×3/frame, `[I]`, `[U]` |
| **3** | `main.gd:1587,1616-1631` → `game.gd:4281,261,4353,4455,4529` — sim `tick`, `_grid_rebuild`, `_separate_units` | 32 Hz (up to 64 catch-up steps) | `_grid_rebuild()` clears and rebuilds the spatial grid over all entities **every sim step**, allocating a `Vector2i` key and a per-cell Array per entity (`:271-274`); `_separate_units()` builds a fresh hash and does 2×9-cell pair passes (`:4371-4408`). Full `for e in entities` scan at `:4309`. Amortised ~0.53×/frame at 60 fps but each step is O(N) with allocations. | `[O]`, `[D]` O(N)×32/s, `[I]`, `[U]` |
| **4** | `hud.gd:1437-1523` — `_process`, `:1454-1480` 6-resource loop, `:1516` viewport box | **every frame** (box), 0.25 s (minimap) | ~12 string formats + 6 dict lookups + `add_theme_color_override` on change per frame; `_draw_minimap_viewport_box` runs every frame and calls `camera3d.get_viewport_corners()` (4 more raycasts) via `hud3d_adapter.gd:73→103→112`. The HUD is correctly dirty-flagged, so the cost is format/lookup allocation, not relayout. Minimap timer duplicates a 57,600-px image 2–3× every 0.25 s. | `[O]`, `[D]` constant/frame + O(map) per 0.25 s, `[I]`, `[U]` |
| **5** | `world3d_entities.gd:1308-1397` `_morph_mesh` + `anim3d.gd:410-459` `skin_vertices` | per new `(sid,action,frame)`, ~sim rate | Rebuilds an `ArrayMesh` (up to ~719 verts, ~921 faces) with a per-corner `Dictionary` keyed by built strings (`:1348`), a full face-normal loop (`:1372-1384`) and a new material slot. `skin_vertices` allocates `Array[PackedFloat32Array] mats` + `Array[Vector3] poss` and one `PackedFloat32Array` per bone via `_qmat` (`anim3d.gd:593-603`). `pose_memo` (`:2041,2073-2080`) and `_morph_meshes` (`:1310-1312`) cap it to once per unique key per frame, but the donor frame advances at ~30 Hz so a rebuild is common. | `[O]`, `[D]`, `[I]`, `[U]` |
| **6** | `world3d.gd:247-293` `_update_view_rect` + `hud.gd:1666-1704` → `hud3d_adapter.gd:103-132` → `camera3d.gd:397-404` | **every frame**, twice | Eight `project_ray_origin`/`project_ray_normal` pairs per frame (4 per call ×2 callers) plus fresh `Array`/`Vector2`/`Rect2`/`Vector4i`. Camera ray math is C++-side but the 8 call sites and container allocations are GDScript-side. | `[O]`, `[D]` 8 raycasts/frame, `[I]`, `[U]` |
| **7** | `input_controller.gd:1484-1554` `_process` + `:671-702` `_apply_rect_selection` | every frame; heavy branch only while dragging/building | Always: marquee `_show/_hide_selection_rect`, ghost handoff ray (build mode), and **hint strings formatted every frame** at `:1543-1553` before `show_hint()` no-ops. While dragging: full `game.entities` scan + id sort + `Array.duplicate()` every frame. While building: `_screen_to_world` ray every frame. | `[O]`, `[D]`, `[I]` idle cost low, drag cost high, `[U]` |
| **8** | `world3d_fx.gd:509-519,1356-1418,1476-1501,732-...` — `sync`, `_update_fx`, `_update_rally`, `_update_ghost`, `sync_selection` | every frame | `keep: Array` allocated every frame regardless of FX count (`:1357`), full `fx_items` loop with `str(kind)` per item, full rally-marker loop, selection `want` Dictionary rebuild. Small at game start (few FX), grows with combat. | `[O]`, `[D]` O(N_fx)/frame, `[I]`, `[U]` |
| **9** | `world3d_entities.gd:1851-1936` `_sync_building_stages` + `:2163-2184` rotor loop + `:2196-2248` field states | every frame | Per-building `_mesh_info` lookup + 5 `set_meta` writes + stage histogram Dictionary; per-rotor `Basis`/`Transform3D` construction for billboard+spin; per-field `game.call("field_state")`, `game.call("field_growth01")`, `Color` and `_field_visual[fid] = {...}` allocation. | `[O]`, `[D]`, `[I]`, `[U]` |
| **10** | `world3d_fog.gd:116-125,231-318` — `sync`/`_update_fog`; `audio.gd:150-179`; `main.gd:1714-1721` | fog: timer-gated; audio: 0.4 s; sound: 1.25 s | Three throttled full-entity/full-resource scans. Fog's `_update_fog` expands a tile circle per unit (`:289-301`) and walks the whole map (`:304-314`) when active — but `fog_of_war` is **false** in `config.json:47` at start, so it early-outs at `:234`. Audio scans `live_blds`; walk-sound breaks on first hit. | `[O]`, `[D]` gated, `[I]` low at start, `[U]` |

(Items just outside the top 10: `camera3d.gd:589-686` `_process` with 6 `Input.is_*` polls and
`clamp_pos()` every frame; `hud.gd:1968-2035` minimap rebuild with 2–3 full-image duplicates
every 0.25 s; `main.gd:1745-1795` `_consume_events`, bounded by per-tick events.)

---

## 4. Single most likely cause of low start FPS

**Code-level answer (this ticket): the unthrottled O(N_instances) presentation sync chain
`main.gd:1671 → world3d.gd:682 sync → world3d_entities.gd:2014 sync` (top-10 #1 and #2 combined).**

Concretely:

- `world3d_entities.gd:2129-2142` re-derives a `Transform3D` with `_xf()` (`:1551-1593`) and
  calls `mm.set_instance_transform()` for **every registered instance** on **every rendered
  frame**. There is no dirty bit, no visibility cull and no camera-bounds filter on this pass.
- `world3d_entities.gd:2044-2127` re-scans every unit slot first, allocating a fresh
  speed-sample Dictionary per unit (`:1236`) and a string memo key per unit (`:2073`).
- `world3d.gd:505-523` (`_sync_rally`), `:329-358` (`_reconcile_entities`) and `:297-319`
  (`_sync_selection` → `game.gd:2979`) add three more full `game.entities` traversals per frame.
- The shipped map is 240×240 tiles (`config.json:75-76`), and map generation places dense
  forest wood (`game.gd:826-836`, cap 14 per mask at 0.30/cell) plus bushes/stone/ore, all of
  which are fed into MultiMesh batches (`world3d.gd:392-405`). At game start there are only
  ~8 peasants + town halls, so the per-frame work is dominated by **static scenery instances**,
  not army size — exactly matching "FPS are too low even on start".

`[O]` all cited code; `[D]` O(N_instances)×2 + O(N_entities)×3 per frame; `[I]` this is the
largest CPU item that is present at start and independent of army growth; **`[U]` its actual
millisecond cost has not been measured** (no capture/run; only G04 may run Godot).

### Important cross-ticket caveat

A CPU hotspot is not the only explanation. Two GPU-side suspects are *also* present at start and
are explicitly outside P01's scope:

- `reports/P05_shader_cost.md:125-149` counts **68 texture fetches and ~50 `sin`/5 `pow` per
  water fragment** in `water3d.gdshader` — an order of magnitude above the terrain shader;
  `[I]` high confidence in the *relative* ordering from instruction counts, `[U]` measured cost.
- `reports/G17_perf_audit.md` / Wave G charter `:62-65`: the new full mip chain for the
  16384×8192 atlas adds ~171 MiB VRAM (+33%) and a main-thread mip-generation stall at load.

Because "low FPS even at game start" is equally consistent with a static-scene GPU cost that
does not scale with unit count, **CPU vs GPU dominance is `[U]` until P09's capture/telemetry
lands**. This report does not claim that the CPU chain above is the whole answer.

---

## 5. What would reduce the #1 cost (proposals only — no edits made)

All are proposals for the implementation owners; P01 changed no code.

1. Dirty-flag the Pass-2 transform rewrite in `world3d_entities.gd:2129-2142`: only call
   `_xf()`/`set_instance_transform()` for ids whose `pos`/`face`/`hidden` state changed since
   last sync (a per-id hash/version mirror). Static forest/ore instances would then cost zero
   per frame. Keep the morph/rotor/field time-driven paths on their own clocks.
2. Collapse the three full entity scans in `world3d.gd` into one pass per frame
   (`_sync_selection` + `_sync_rally` + `_reconcile_entities`), or drive them off `bld_dirty` /
   `res_dirty` / selection-change bits that `game.gd` already maintains.
3. Remove the per-unit Dictionary allocation in `world3d_entities.gd:1236` by storing two
   parallel packed arrays (`_motion_pos`, `_motion_t`) keyed by int id.
4. Hoist `_draw_minimap_viewport_box` (`hud.gd:1516`) off the per-frame path unless the camera
   transform actually moved; it currently triggers the second pair of 4-ray corner queries.
5. Build the hint string in `input_controller.gd:1543-1553` only when the state changes, rather
   than formatting every frame before `show_hint()` discards it.

None of these changes art, thresholds, donor citations or tests; each would need its own
backed-up implementation ticket with a before/after capture to be credible.

---

## 6. Open questions / UNVERIFIED

| ID | Question | Status |
|---|---|---|
| U-P01-1 | Actual ms/frame of `world3d_entities.sync` Pass 2 on the MX130 machine | `[U]` — needs profiler/capture (P09/G04) |
| U-P01-2 | Number of resource nodes fed to MultiMesh batches on the default seed 20261113 map | `[U]` — static count not run; derived from `game.gd:826-836` density |
| U-P01-3 | Whether CPU (#1) or water GPU shader (P05) dominates wall-clock FPS at start | `[U]` — no measurement |
| U-P01-4 | Whether `mm.set_instance_transform()` on unchanged instances is a real driver cost or cheaply skipped by Godot | `[U]` — engine internals, no source inspected here |
| U-P01-5 | Whether the 8 per-frame corner raycasts are folded/cached by the engine | `[U]` |
| U-P01-6 | 2D-path per-frame cost (`world.gd:2072`) under the shipped 3D default | OBSERVED code only; not the hot path per `config.json:74` |

*End of P01 report.*
