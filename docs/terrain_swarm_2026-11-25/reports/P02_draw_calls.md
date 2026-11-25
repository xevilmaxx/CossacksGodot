---
id: P02
ticket: "Wave P / P02 — rendering & draw-call audit"
title: "variant3d rendering cost: batching, instance counts, transparency overdraw, shadow flags"
owner: "P02 (read-only analysis subagent)"
created: 2026-11-25
status: DONE
labels: [observed, derived, inferred, UNVERIFIED]
---

# P02 — Rendering / draw-call audit

## 0. Scope and method

- **READ-ONLY.** No runner job, no Godot launch, no code edits, no backups. One output file only.
- Sources: `variant3d/scripts/*.gd`, `variant3d/shaders/*.gdshader`, `variant3d/project.godot`,
  existing telemetry under `variant3d/tests/results/*.json`. All line numbers below are the current tree.
- **No windowed GPU capture was run by this agent, and none of the existing JSON contains usable
  FPS/draw-call numbers (§2). Every FPS or frame-time claim in this report is UNVERIFIED.**
- Ranking is by *likely* cost on the owner's MX130-class GPU under the GL Compatibility renderer;
  it is INFERRED from structure, not measured.

## 1. Rendering topology (OBSERVED)

| Subsystem | Draw model | Evidence |
|---|---|---|
| Renderer | `gl_compatibility` (both desktop and mobile), 1280×720 | `variant3d/project.godot:15-16,21-26` |
| Terrain | **ONE** indexed `ArrayMesh`, **ONE** surface, **ONE** `MeshInstance3D`; `nverts = w*h`, `ntris = (w-1)*(h-1)*2`; `cast_shadow = OFF` | `world3d_terrain.gd:11-12,1367-1380,1520-1556` (`cast_shadow` at `:1555`) |
| Water | **ONE** 4-vertex / 2-triangle plane spanning the whole map, `material_override` = `blend_mix` shader | `water3d.gd:212-237`; `shaders/water3d.gdshader:21` |
| Fog-of-war | **ONE** transparent `ArrayMesh` of per-tile quads (one quad per map cell), `depth_draw_never` | `world3d_fog.gd:33-34,147-165,168-215` |
| Units / resources | `MultiMeshInstance3D` batches; key = `unit|sid|p{player}` / `unit|sid|p#|a#|f#` (morph) / `res|sid` | `world3d_entities.gd:37-39,1401-1438,1597-1642,1964-1985` |
| Buildings | **ONE individual `MeshInstance3D` per building**, `cast_shadow = ON` | `world3d_entities.gd:1645-1682` (`:1679`) |
| Mill rotor | 1 alpha-scissor billboard quad per mill | `world3d_entities.gd:1725-1762,1765-1782` |
| Ghost | 2 nodes (footprint BoxMesh + finished-building mesh), shared transparent material, `depth_draw_disabled`, cast_shadow OFF | `world3d_fx.gd:898-925` |
| Selection rings | **3 `MeshInstance3D` + 3 new materials + 3 new meshes per selected entity** | `world3d_fx.gd:1254-1288`; feed at `world3d.gd:535-559` |
| FX | Per-item MeshInstance3D(s) + optional OmniLight3D; 4 GPUParticles3D snow emitters (100/100/100/200) | `world3d_fx.gd:1008-1061,1100-1196,973-1004` |
| WorldEnvironment | `BG_SKY` + `ProceduralSkyMaterial`, linear tonemap, ambient colour, **no glow / fog / SSAO / SSR / DOF**; one `DirectionalLight3D` with `shadow_enabled = false` | `world3d_terrain.gd:1189-1246` (`:1240`) |

**Shadow note (OBSERVED).** The only sun in the wired scene has shadows disabled
(`world3d_terrain.gd:1240`), so the `cast_shadow = ON` on buildings
(`world3d_entities.gd:1679`) and the default cast flags on the water/fog planes are
**currently inert** — no shadow map is rendered. The shadow-enabled sun at
`heightmap_world3d.gd:141` is an *unwired reference* file (the wired terrain script is
`world3d.gd:108` → `world3d_terrain.gd`), so there is no double-sun / double-shadow cost.
If shadows are ever re-enabled, building cast flags and the full-map water plane become a real cost.

## 2. Telemetry: what exists, and what it proves

- `tests/results/t_terrain_trees.json:185-195,220-226`: `draw_calls_avg = 0.0`,
  `draw_calls_last = 0.0`, `process_time_ms_avg = 0.0`, `frame_delta_ms_avg = 0.0`,
  `headless: true`, `display_server: "headless"`. The check `draw_calls_recorded` only asserts
  `samples > 0`, and its own detail says *"(windowed GPU if >0)"*
  (`tests/t_terrain_trees.gd:279-281`). **These zeros are not measurement; all FPS claims from
  this file are UNVERIFIED.**
- `scripts/testbridge.gd:243-250` exposes `TIME_FPS`, `RENDER_TOTAL_DRAW_CALLS_IN_FRAME` and
  `RENDER_TOTAL_PRIMITIVES_IN_FRAME`, but **no checked-in result JSON carries a non-zero value**.
  Windowed runs exist (`t_terrain_only.json:158`, `t_hud_layout.json:402`,
  `t_select_rect.json:182,245`, `t_motion_capture.json:3`) but record captures, not FPS/draw calls.
  **Real FPS remains UNVERIFIED.**
- Instance counts from structural telemetry (OBSERVED, not rendering measurements):
  - `tests/results/t_combo_trees_mines.json:189-200`: 29 resources → **15 resource batches**.
  - `tests/results/t_terrain_trees.json:207-219`: 20 resources, terrain `mesh_surfaces = 1`,
    `mesh_vertices = 4096`, `mesh_triangles = 7938` on the 64² harness.
  - `tests/results/t_mass_army.json:37`: **552 units** spawned (sim-only, headless; its
    `sim_ms = 20832.75` is sim CPU time, not FPS — UNVERIFIED as a rendering number).
  - `tests/results/t_perf_scale.json:4-28`: 314 / 1004 / 3000-unit scale rows (move/squad sim ms).
  - Real 320² map dump `tests/results/w52_self_base.json`: `map_w = map_h = 320`,
    `res_nodes` by type — wood **1864**, bush **241**, stone **126**, coal **9**, gold **6**,
    iron **6** (≈2252 resources); 16 units, 2 buildings. Extrapolated terrain grid:
    102,400 vertices / ≈203,000 triangles in **one** draw call (DERIVED from
    `world3d_terrain.gd:1369-1370`).

## 3. Ranked findings — highest likely cost first

Ranking is INFERRED (no GPU capture). "Cost" means added draw calls, fragment work, fill/overdraw,
or per-frame CPU work under GL Compatibility.

### F1 — HIGH GPU: full-map water plane runs a 9-iteration noise loop *before* the discard
- `water3d.gd:212-237` builds one quad covering the entire map (160² grid ⇒ 320×320 m at the
  default `MAP_DEFAULT = 160`, `world3d_entities.gd:114`; 320² dump ⇒ 640×640 m), with `blend_mix`
  transparency (`shaders/water3d.gdshader:21`) and `cull_disabled`.
- `water3d.gdshader:102-107` — `water_map()` contains a **9-iteration** noise loop.
- `:170` calls `water_map()` to build `level`; **only at `:171-173`** is `discard` executed for
  `height > level`. Therefore *every fragment of the full-screen quad*, including all dry land,
  pays 9 noise iterations before being thrown away (OBSERVED code order).
- For surviving water fragments `:189-192` call `water_map()` **four more times** (5 × 9 = 45
  noise iterations per water pixel) and `:239` adds `nautic()` (3 iters, `:117-122`) plus
  `particles()` (3 iters, `:132-137`).
- Net: full-screen alpha-blended overdraw with heavy per-fragment math. On a weak GPU this is the
  single largest plausibly-avoidable fragment cost (INFERRED — UNVERIFIED without capture).

### F2 — HIGH GPU fill when a selection exists: 3 uncapped transparent draw calls per selected entity
- `world3d.gd:535-559` feeds one entry per selected id into `fx.sync_selection(entries)`; there is
  no cap (Ctrl+A / select-same-type can select hundreds).
- `world3d_fx.gd:1254-1288`: each entry creates a `Node3D` holder + **three `MeshInstance3D`**
  (Ring torus, UnderRing torus, OwnerPip cylinder) + **three newly allocated materials**
  (`:1262-1264` via `_material()` at `:1008-1019`, all `TRANSPARENCY_ALPHA`, emission, cull off)
  + three primitive meshes (`:1266-1269`).
- So N selected units ⇒ **3N transparent draw calls**, 3N materials, 3N meshes, 4N nodes, with no
  sharing. `fixselvis_probe.json:88,92` only checks ring *counts* (0 → 2), so a 2-unit probe never
  exposes the scaling.
- INFERRED: at 552 units (`t_mass_army.json:37`) a ctrl-A selection would submit ~1656 transparent
  draws — a plausible CPU (GL compat) and fill-rate spike.

### F3 — MEDIUM GPU fill: fog overlay draws transparent quads over already-visible tiles
- `world3d_fog.gd:168-215` builds one quad for **every** map cell (320² ⇒ 102,400 quads /
  204,800 triangles in one draw call).
- `ALPHA_VISIBLE = 0.0` (`:41`) → `ALPHA_EXPLORED = 0.30`, `ALPHA_UNEXPLORED = 0.78` (`:39-40`).
  Visible tiles therefore rasterise and blend a fully-transparent black quad — pure wasted fill.
- Shader is cheap (`blend_mix, unshaded, cull_disabled, depth_draw_never`, `:147-165`), and the mesh
  is only rebuilt when tile alpha actually changes (`:231-318`), so CPU cost is gated. GPU fill cost
  is proportional to visible screen area, not to the rebuild.

### F4 — MEDIUM CPU/draw-call: building-per-node + per-surface material duplication
- `world3d_entities.gd:1645-1682`: `add_building()` creates a **separate `MeshInstance3D` per
  building** (unlike units/resources, which are batched). Each building is at least one draw call.
- `_apply_tint()` (`:1008-1025`) calls `_tinted_material()` (`:976-996`), which allocates a **new
  `Shader` (`Shader.new()`, `:989-990`) and a new `ShaderMaterial` (`:991`) per surface per
  building**; units get one `material_override` per batch (`:1015-1019`).
- `_default_material()` (`:582-600`) likewise allocates a fresh `StandardMaterial3D` each call and
  uses `CULL_DISABLED` (double-sided shading) plus alpha-scissor for resources (`:593-595`).
- Current dump has only 2 buildings (`w52_self_base.json`), so today's cost is small; a developed
  town scales linearly. Meshes themselves **are** cached by `kind|sid` (`:1110-1160`), so geometry
  is not duplicated — only nodes/materials/draw calls are.

### F5 — MEDIUM CPU + VRAM: batch allocation and batch proliferation
- `BATCH_CAPACITY = 4096` (`:116`); every `MultiMesh` is created with `instance_count = 4096`
  and `visible_instance_count = 0` (`:1417-1418`). With ≈36 distinct resource sids possible
  (19 tree + 5 rock + 4 bush + 4 stump + 3 mine + 1 field; `:173-179`, `:1939-1953`), that is
  ~147k reserved instance slots (transform+colour ≈ 80 B each ⇒ ≈12 MB VRAM, DERIVED) regardless
  of actual count (≈2252 resources in the dump).
- Key design already avoids explosion: units batch by `(sid, player)` in the shipped static path
  (`:1625-1629`); morph path adds `(action, frame)` (`:2094-2104`). Empty **static** batches are
  freed (`:1503-1512`), but empty **morph** batches are deliberately kept alive (`:1505-1507`) —
  bounded by visited frames, but a slow leak of dormant nodes over a long session (INFERRED).
- `t_combo_trees_mines.json:190` confirms 15 batches for 29 resources — batching works.

### F6 — LOW/MEDIUM, bursty: transparent FX billboards and per-item OmniLights
- `_build_visual()` (`world3d_fx.gd:1100-1196`) creates a new material per FX item (`:1104`), 1–3
  `MeshInstance3D` quads/spheres per item (e.g. smoke 2 quads `:1115-1119`, fire 2 quads `:1133-1137`)
  and an `OmniLight3D` for shot/explode/fire (`:1113,1125,1138`). In a forward renderer, extra
  overlapping lights raise per-object shading cost; `_add_light()` sets `shadow_enabled = false`
  (`:1054-1061`), so no shadow cost.
- Snow: 4 `GPUParticles3D` emitters (100/100/100/200 particles) with alpha-billboard quads and no
  depth write (`:973-1004`); only active at Weather ≥ 70 (`:1003`), so not a start-screen cost.
- Ghost is already lean: 2 nodes, shared material, `depth_draw_disabled`, no shadows
  (`:898-925`, `:1491-1501`).

### F7 — LOW: terrain and environment are already near-minimal
- Terrain: one surface, one draw call, `cast_shadow = OFF` (`world3d_terrain.gd:1520-1556`);
  no chunk splitting, no per-tile nodes. Do not "optimise" by chunking — it would add draw calls.
- Environment: sky + linear tonemap + ambient only; no glow/SSAO/SSR/fog (`world3d_terrain.gd:1194-1223`).
  Water fog uniforms are explicitly disabled (`water3d.gd:195-196`). No WorldEnvironment effects
  to trim.
- Mill rotor: one alpha-**scissor** (not blend) quad per mill (`world3d_entities.gd:1725-1762`) —
  cheap, no overdraw penalty beyond the cutout.

## 4. Top 3 actionable reductions (visual-preserving, test-safe)

All three are *proposals only*; no code was changed. P11 owns `world3d_entities.gd`; P05 owns the
shaders; the selection/FX owner must be coordinated. Each keeps the rendered pixels and the telemetry
contracts (`stats["batches"]`, `stats["units"]`, `stats["resources"]`,
`fx.stats["selection_rings"]`, `mesh_surfaces`, selftest 29/29, uitest 17/17).

**A1 — Cheap early-out before the water noise (addresses F1, largest likely GPU win).**
Add a `water_cell` gate at the top of `water3d.gdshader:fragment()` using the **already-computed**
`height_map()` value (`:163`) and the existing classification literal `water_level` (`:182`):
if `height >= water_level` then `alpha = 0` is already guaranteed by `:246`, so `discard` there is
**pixel-identical** and can move ahead of the 9-iteration `water_map()` at `:170` (and all 4
normal calls at `:189-192`, `nautic`/`particles` at `:239`). This skips all heavy math on dry land,
which is most of the frame on a typical land start. No donor constant, colour, or blend changes.
*(Shader file is outside P02/P11 ownership — route to P05 / COORD.)*

**A2 — Batch or cache selection rings (addresses F2, the worst scaling case).**
Convert the three ring layers to **three `MultiMeshInstance3D` batches** (ring/under/pip) with
per-instance transforms and the donor player colour per instance, or at minimum (a) cache the
three primitive meshes and the materials **per player slot** and (b) apply footprint size via the
node's `transform` instead of mutating shared `TorusMesh` radii (`world3d_fx.gd:1293-1307`) and
mutating shared material colours (`:1312-1324`). Geometry, colours, `selection_rings` counts and
pulse (`_update_selection`, `:1342-1351`) stay identical; only allocation/draw-call count falls from
3N to 3 (or from 3N materials to ≤13). Keep `_free_selection_marker` and the synchronous `free()`
semantics (`:1327-1337`) so tests that count nodes in-frame still pass.

**A3 — Omit zero-alpha fog quads from the overlay mesh (addresses F3).**
In `world3d_fog.gd:_refresh_mesh()` (`:218-229`), build indices only for tiles whose
`_tile_alpha[i] > 0.0` (i.e. explored/unexplored), instead of emitting all `w*h` quads at
`:184-203`. A tile with `ALPHA_VISIBLE = 0.0` contributes nothing to the blend, so the result is
pixel-identical; visible-area fill drops sharply as the map is revealed. Keep the vertex/colour
buffers and `_set_tile_color` indexing intact so `t_fog3d.gd` structural checks and the
`fog_revision` bump in `world3d.gd:698-700` still work.

**Honourable mention (smaller, no visual change):** share one `Shader` resource for the tint
material instead of `Shader.new()` per call (`world3d_entities.gd:989-990`), and set
`cast_shadow = OFF` on building `MeshInstance3D`s (`:1679`) to match terrain — inert today, but
removes a latent shadow-pass cost if shadows are re-enabled. Batching buildings into MultiMeshes
would cut draw calls further but changes node counts asserted by `tests/t_entities3d.gd` (peak=6),
so P11 should treat it as test-sensitive.

## 5. Explicitly NOT worth changing (would cost visuals or add risk)

- Terrain single-surface mesh / one draw call — already optimal (`world3d_terrain.gd:1520-1556`).
- `CULL_DISABLED` on entity materials (`:599`) — chosen to avoid donor winding mismatch; removing
  it could drop silhouettes. Same for FX billboards (`world3d_fx.gd:981,1016,1035`).
- Resource batching by `res|sid` (`:1979`) — merging sids would replace distinct donor tree/rock
  art, violating art fidelity.
- Selection radii/colours — donor-derived semantics; only the *allocation* is reducible.

## 6. Unknowns / UNVERIFIED

- **All FPS, frame-time, process-time and `draw_calls_avg` numbers are UNVERIFIED** — headless
  telemetry is zero and windowed captures do not record FPS (§2).
- Actual split of GPU time between water fill, terrain fragment shader, fog fill and selection
  overdraw is UNKNOWN; ranking F1–F7 is structural inference only.
- Whether the 4096-slot `MultiMesh` reservation (`world3d_entities.gd:1417`) is upload-once or
  re-uploaded per frame under GL Compatibility is UNVERIFIED (no renderer trace).
- Visual identity of the proposed early-out/quad-skip optimisations is argued from the shader
  equations, not from an A/B capture — UNVERIFIED until COORD runs a windowed A/B.
- Instance counts for units at game start on a real map are UNVERIFIED; the 16 units in
  `w52_self_base.json` is one saved scenario, and 552/3000-unit rows are headless sim tests.

*End of P02 report.*
