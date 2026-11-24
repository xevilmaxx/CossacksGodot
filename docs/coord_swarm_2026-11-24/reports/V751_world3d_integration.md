---
owner: V7-51
role: integration builder — compose the five landed world3d_* atoms into one world3d.gd
date: 2026-11-24
governing_rule: "WAVE7 charter :29-38 — translate donor, cite path:line, UNVERIFIED where no readable source; no donor binaries"
scope: "SINGLEPLAYER SKIRMISH ONLY (D-12); FULL 2D world contract; no sprite sheets, no chunking, no RNG"
owned_files:
  - variant3d/scripts/world3d.gd
  - docs/coord_swarm_2026-11-24/reports/V751_world3d_integration.md
backup: inbox/backup/world3d.gd.bak-V751 (legacy M0 terrain-only world, 20,542 bytes)
status: "DELIVERED — parse MEASURED clean; 11/11 composition assertions MEASURED PASS (headless); visual/integration runtime UNVERIFIED"
verification_jobs: [v751-parse, v751-parse-final, v751-composition-probe, v751-composition-probe2, v751-prop-probe]
honest_limits:
  - "No full gate (coordinator-owned)."
  - "main.gd / input_controller.gd / hud.gd render_mode seams had NOT landed at authoring time: integration runtime UNVERIFIED."
  - "world3d_fog.gd:211 assigns a non-existent Godot 4.7 property render_priority; fog overlay fails to attach (module bug, NOT edited by me)."
---

# V7-51 — `world3d.gd`: five-module integration composition

## 1. What landed

`variant3d/scripts/world3d.gd` now **replaces** the legacy M0 terrain-only world
(backup below). It is 331 lines, tabs only (0 space-indented lines), no RNG, no
sprite sheets, no chunking, no `class_name` (loaded dynamically per V73 :26-30).
It `extends Node3D` and **composes** — it does not re-implement — terrain,
entities, FX, fog or animation. Every module script is `load()`ed, instantiated
once, added as a child of the world, and bound in dependency order.

The only other file written is this report. No `world3d_*` module, `main.gd`,
`input_controller.gd`, `hud.gd`, `anim3d.gd` or test was touched.

## 2. Backup

```
Copy-Item variant3d\scripts\world3d.gd inbox\backup\world3d.gd.bak-V751
```

Verified: `inbox/backup/world3d.gd.bak-V751`, 20,542 bytes, taken **before** the
edit. `git status --short` shows only `M variant3d/scripts/world3d.gd` and the new
untracked backup + report for this atom.

## 3. Exact composition map — which module owns which contract member

Full contract source: `V71_mechanics_inventory.md:180-199` (§3 table);
integration duty: `V73_ATOMIC_CONTRACT.md:19-24`.

| Contract member (V71 §3) | Owner after composition | What the composition does |
|---|---|---|
| `bind(game)` | **world3d.gd** (this file) | Stores `game`/optional `hud`; `view_scale = Data.PIXELS_PER_METER` (world.gd:240); instantiates all five modules once; binds terrain → entities → fx → fog → anim; calls `terrain.build()` once only when a height source exists; aliases fog arrays **after** `fog.bind()`; sets `fx.consume_events = false`. No sim mutation. |
| `sync(dt)` | **world3d.gd** orchestrates; real work delegated | Derives `view_rect` from the active `Camera3D` ground frustum, mirrors selection, then calls `entities.sync(dt)`, `fx.sync(dt)`, `fog.sync(dt)`. Terrain is static (one mesh, no per-frame chunk work). `dt` stays sim-agnostic, matching world.gd:2072-2081. |
| `view_scale` (data) | **world3d.gd** | `float(Data.PIXELS_PER_METER)` = 16.0 (data.gd:113, world.gd:22/240). Port scalar, metres→canvas px; meaning unchanged for shared callers (V71 §3 :188). |
| `view_rect` (data) | **world3d.gd** | `Camera3D.get_viewport_corners()` → axis-aligned X/Z AABB in ground metres, re-centred from the map-centred 3D scene to map-origin metres (`+ half extent`) and multiplied by `view_scale` → canvas px. Fallback = full-map rect when no camera/inside-tree (headless-safe). Axis-aligned under yaw is a **PORT APPROXIMATION** (V71 §6 Q5, study open Q9). |
| `fx_layer` (node) | **world3d.gd** aliases `world3d_fx` | Points at the composed FX `Node3D` (fallback fresh `Node3D` if the module is missing) so input's route-overlay `add_child` has a valid host (V71 §3 :190). |
| `world_to_px(p)` (data) | **world3d.gd** | `p * view_scale` (world.gd:350-351). Pure data fn, canvas px; not camera-projected, so minimap/patrol callers keep 2D semantics (V71 §6 Q2 left open). |
| `fog_explored`, `fog_vis` | **world3d_fog** arrays, aliased | `fog_explored = fog.fog_explored`, `fog_vis = fog.fog_vis` **after** `fog.bind()` (that method reassigns both). `main.gd:1234-1235 fill(0)` and HUD minimap reads (hud.gd:1474/1508/1700) therefore hit the fog module's live arrays. Verified by probe (`PASS fog_alias`). |
| `add_fx(kind, pos)` | **world3d.gd** adapter → `world3d_fx.add_fx(pos, kind, life)` | 2D order is `(kind, pos)` (world.gd:3563, main.gd:1521-1553); module order is `(pos, kind, life)` (V73 :14). The adapter swaps, tolerates either order, returns the spawned item (benign superset). `fx.consume_events = false` so main's explicit forwarding cannot double-spawn (V7-15 §6 Q1). |
| `has_chunk_or_fallback(k?)` | **world3d_terrain** | Delegates to `terrain.has_chunk_or_fallback()` — trivially true (ONE full-grid mesh, no chunks; V713 §2/§4, V71 §3 :194). Optional arg accepted for 2D test-hook compatibility. |
| `selected` state | **world3d.gd** mirrors; input owns authority | Exposes `sel_rect`, `sel_active` (input writes at input_controller.gd:1017-1020), `selected_ids` and a `selected` id→entity cache. `sync()` mirrors `game.get_selected()` when present. It never writes `e["selected"]` (input_controller.gd:148-158 keeps it). Dictionary-safe guard added. |
| anim3d handoff | **world3d.gd** loads `anim3d.gd` | `anim = load(ANIM_SCRIPT).new()`, `anim.bind(game, entities)`; `play_anim(e, action, t)` delegates to `anim.play`. Module's `PORT_LABEL = "PORT APPROXIMATION — NOT DONOR PARITY"` and blocked-rig label are preserved verbatim (V7-18). |

Also exposes two small non-contract conveniences: `height_at_world(p)` → terrain
bilinear sample, and `stats` (module load flags, view_scale, contract citation).

## 4. Donor / port evidence carried in the composition

| Item | Evidence | Verdict |
|---|---|---|
| Full contract member list | V71 report §3 `:180-199`; V73 contract `:19-24` | SHARE (read-only) |
| `view_scale` scalar 16 px/m | variant3d/scripts/data.gd:113, world.gd:22/240 | PORT value; donor px/metre **UNVERIFIED** |
| `world_to_px` = `p * view_scale` | world.gd:350-351 | PORT precedent, unchanged |
| `fx_layer` / `add_fx` forwarding | world.gd:126,310-316,3563-3579; main.gd:1521-1553 | PORT precedent (sim-agnostic event stream, game.gd:2823) |
| fog array types / reset | world.gd:27-28,333-347,2251-2255; main.gd:1234-1235 | PORT state encoding; donor fog↔explored binding **UNVERIFIED** (V716 §3) |
| `has_chunk_or_fallback` | world.gd:1746-1747 | PORT test hook; 3D trivially true (V713) |
| terrain module | V713 §4: generatemap.inc:537-577, mapgen.gd:29, data.gd:23 | donor height source cited; absolute cell size / water literal **UNVERIFIED** |
| entities module | V714 §2: 116 donor `.obj`, envscales.cfg:25-28/43-46/371-374 | `.oss` bone parents unreadable → static bind pose, labelled |
| fx module | V715 §4: PFX literal keys (SEMANTICS UNVERIFIED); lifetimes from world.gd:3563-3579 | port lifetimes, no donor parity claim |
| anim module | anim3d.gd:41, V718 | `PORT APPROXIMATION — NOT DONOR PARITY`; rig BLOCKED |

## 5. Verification — job ids and results

All Godot launches went through `variant3d/tools/godot_runner.py` (V73 :37).
No full gate was run (coordinator-owned).

| Job id | Ticket | Command (abridged) | Result |
|---|---|---|---|
| `v751-parse` | 54 | `--headless --path variant3d --check-only --script res://scripts/world3d.gd` | **END ok**, 4.52 s, stderr 0 bytes — parse clean |
| `v751-parse-final` | 59 | same, after the dictionary-safety edit | **END ok**, 3.77 s — parse clean |
| `v751-composition-probe` | 57 | scratch probe, Dictionary stub game | END ok, 3.81 s; **11/11 PASS**, `RESULT ok=true`. Stub-specific errors only (Dictionary has no `has_method`) — led to the guard fix below. |
| `v751-composition-probe2` | 60 | scratch probe, Object (`RefCounted`) stub game | END ok, 3.58 s; **11/11 PASS**: `view_scale`, `fx_layer`, `fog_array_sizes`, `fog_alias`, `world_to_px`, `has_chunk_or_fallback`, `add_fx_forward`, `sync_callable`, `anim_handoff`, `height_passthrough`, `all_modules_loaded`; `RESULT ok=true` |
| `v751-prop-probe` | 61 | scratch Godot 4.7 property probe | END ok, 2.30 s; `MESH_PROPS ["process_priority","process_physics_priority","sorting_offset","sorting_use_aabb_center"]` — **no `render_priority`** (see Q1) |

Probes are scratch files under `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\`
(`v751_composition_probe.gd`, `v751_prop_probe.gd`) — **no repo test file was added
or edited**. Spool JSON under `variant3d/.godot_queue/results/` is a tool artifact.

Fix made during verification: `_sync_selection()` now guards `game is Object`
before `has_method("get_selected")`, so dictionary test doubles (as used by
V7-13/V7-14) cannot raise "Nonexistent function 'has_method' in base 'Dictionary'".
The probe2 run confirms the guard works.

### What the probe did NOT measure

Rendered 3D appearance, fog overlay attachment, draw calls, real GPU transforms,
camera integration, minimap box, or any interaction with `main.gd`/`hud.gd`/
`input_controller.gd` (their seams had not landed). Headless exit emits RID/ObjectDB
leak warnings from the dummy `RenderingServer` — the same artifact V7-14 recorded;
it is not attributed to the composition. The intentional `world3d_entities`
`push_warning` (static bind pose label) also appears and is expected.

## 6. Open questions / findings

1. **BLOCKER in a module I do not own — `world3d_fog.gd:211`.** Both probe runs
   logged: `SCRIPT ERROR: Invalid assignment of property or key 'render_priority'
   with value of type 'int' on a base object of type 'MeshInstance3D'`
   (`world3d_fog.gd:211`, called from `:106`, `world3d.gd:246`). Job 61 confirmed
   Godot 4.7.2 exposes `sorting_offset` / `sorting_use_aabb_center`, **not**
   `render_priority`. Because the error aborts `_build_overlay()` before
   `add_child(_overlay)` (:213), `bind()` sets `_built = null` and returns early:
   the fog overlay is never attached and `fog.sync()` no-ops. Fog arrays are still
   correctly sized/aliased (probe PASS), so HUD minimap data survives, but **3D
   fog shading is non-functional until V7-16 changes that line** (e.g.
   `_overlay.sorting_offset = 10.0`). I did not edit the module.
2. **FX event ownership resolved on my side, needs seam confirmation.** I set
   `fx.consume_events = false`; therefore main's `world.add_fx(...)` forwarding is
   the sole FX spawn path. If main's 3D branch is built to rely on the module's
   own event peek instead, FX will not appear — seam owner must keep one path.
3. **Fog–terrain height alignment (V716 Q1/Q2).** Fog overlay samples `game.height`;
   terrain builds from the base64 dump grid. If those differ, quads can sink or
   float; the ports' `world_offset`/`FOG_Y_OFFSET` conventions need a joint visual
   check. Not measurable headlessly.
4. **Entity fog-visibility culling not implemented.** V71 §3 (`:192`) requires
   entity visibility to read `fog_explored`/`fog_vis`. `world3d_entities.sync()`
   only honours `dead`/`hidden`/depletion; adding the fog gate belongs to the
   entities owner, not this composition. No sim entity was mutated here.
5. **`view_rect` under camera yaw** is an axis-aligned ground AABB (V71 §6 Q5,
   study Q9). A projected-quad minimap box is V7-6's adapter duty.
6. **`world_to_px` remains canvas px** (`p * view_scale`). If the 3D input seam
   expects viewport/screen px, that is a deliberate contract-preserving choice
   pending the coordinator's answer to V71 §6 Q2.
7. **Integration seams not landed at authoring time.** `main.gd` still has
   `const C3WorldScript = preload("res://scripts/world.gd")`, `var world: C3World`
   and two `world = C3WorldScript.new()` calls (`:43,:54,:558,:926`); no
   `render_mode` / `make_world3d()` / `make_camera3d()`. `t_render_mode.gd`'s
   `SEAM_MISSING` FAIL is expected until the main/input/hud owners land their
   work. This atom does not make that gate green.
8. **No full gate.** Coordinator-owned; not run by me.

## 7. Honest status

`world3d.gd` is delivered: parse-clean and composition API verified headlessly
(11/11 probe assertions). It is a genuine composition of the five landed atoms,
preserving donor citations and UNVERIFIED labels. **Visual, fog-overlay and
end-to-end integration behaviour remain UNVERIFIED** until the deferred seams
land and the fog-module `render_priority` defect (Q1) is fixed by its owner.

*End of V7-51 report.*
