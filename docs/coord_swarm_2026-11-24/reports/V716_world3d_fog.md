---
owner: V7-16
date: 2026-11-24
role: atomic builder — per-tile 3D fog-of-war shading module
lane: Wave 7 phase 2 — 3D variant (singleplayer skirmish only, D-12)
output: docs/coord_swarm_2026-11-24/reports/V716_world3d_fog.md
owned_file: variant3d/scripts/world3d_fog.gd
contract: docs/coord_swarm_2026-11-24/V73_ATOMIC_CONTRACT.md:15
governing_rule: translate readable port/donor evidence; mark the rest UNVERIFIED; no invented fog rule
status: DONE — parse/test verification recorded in §5
---

# V7-16 — `world3d_fog.gd` (per-tile fog shading)

## 0. Scope / ownership

Exactly one new file: `variant3d/scripts/world3d_fog.gd` (extends `Node3D`).
This report is the only other file written. No `app/**` file, no other
`variant3d/**` module and no test was edited. The 2D path (`app/scripts/world.gd`)
was read-only, as required.

## 1. Exact API delivered

| Member | Signature / type | Implementation |
|---|---|---|
| `bind(game)` | `func bind(g) -> void` | Stores `game`; sizes `fog_explored` / `fog_vis` / `fog_counts` to `MAP_W*MAP_H`; mirrors game-owned arrays when present and correctly sized (stub-safe); builds one transparent `ArrayMesh` of per-tile quads plus its `ShaderMaterial`; seeds per-tile alpha; calls `_update_fog()`. |
| `sync(dt)` | `func sync(dt: float) -> void` | `FOG_INTERVAL`-gated accumulator (2D cadence), then `_update_fog()`; `dt` stays sim-agnostic. |
| `fog_explored` | `PackedByteArray` (public) | HUD minimap can read it; per-tile, flat `y*MAP_W+x` index. |
| `fog_vis` | `PackedByteArray` (public) | Same; 1 = currently visible, 0 = not. |

No `class_name` (loaded dynamically via `load()` per `V73_ATOMIC_CONTRACT.md:26-30`).
No extra public methods were added. Private helpers: `_alpha_for`,
`_set_tile_color`, `_make_fog_material`, `_build_overlay`, `_refresh_mesh`,
`_update_fog`.

## 2. Port evidence — 2D fog semantics preserved (all read-only this session)

| 2D source (`:line`) | What was translated |
|---|---|
| `app/scripts/world.gd:27-28` | `fog_explored` / `fog_vis` are `PackedByteArray` — same types exposed. |
| `app/scripts/world.gd:333-335` | Arrays sized to `MAP_W*MAP_H` in `bind()`. |
| `app/scripts/world.gd:2186-2256` | Full `_update_fog()` structure: 6-tick forced recount + movement gate (`:2191-2211`), reveal-request consumption (`:2218-2227`), `fog_counts` from player-0 entity `search` / `radius*6` (`:2228-2239`), explored latch and visibility transition (`:2240-2247`). |
| `app/scripts/world.gd:2250-2255` | Alpha ladder: visible `(0,0,0,0)`, explored-but-not-visible `(0,0,0,0.30)`, unexplored `(0,0,0,0.78)` — used verbatim as `ALPHA_VISIBLE` / `ALPHA_EXPLORED` / `ALPHA_UNEXPLORED`. |
| `app/scripts/world.gd:2225`, `:2237` | Tile-centre arithmetic `tx*TILE_M + TILE_M/2` (2D hard-codes `2`, i.e. `TILE_M=2`); written as `(tx+0.5)*Data.TILE_M` — numerically identical, no new constant. |
| `app/scripts/game.gd:2834-2836` | `reveal_requests` / `game_reveal(pos, r)` — consumed and cleared, never produced. |
| `variant3d/scripts/game.gd:2834-2836, :3456-3461` | Same sim API in the 3D project; includes the `game_reveal(Vector2(MAP_W,MAP_H), 1e9)` whole-map reveal (handled by the same loop with no special case). |
| `variant3d/scripts/game.gd:44, :357-365` | `game.height` is a `PackedFloat32Array` sized `MAP_W*MAP_H`; sampled for overlay quad height (with a flat-y fallback when absent). |
| `variant3d/scripts/world3d.gd:215-224` | Centred tile-corner → world quad mapping copied for mesh placement. |
| `variant3d/tests/t_fog3d.gd:37-48, 150-184` | Stub game shape (`MAP_W/H` + only the two arrays) and the "no Sprite2D" structural gate drove the defensive `game.get(...)` access and the mesh-only overlay. |

## 3. Donor evidence and honest UNVERIFIED markers

| Item | Evidence | Verdict |
|---|---|---|
| Donor view-space fog math (LINEAR / EXP / EXP2 + `mix(fogColor, color, fog)`) | `RENDER_ARCH_SHADERS.md:150` E19 → `pvl.smx3.id0.frag:29-43` (same block in `hf`, `tbn`, `rim`, `dec`, `env`, `gr`, `ppl` fragments) | **READABLE via evidence report** (donor file not re-read this session). Not used as the fog-of-war rule — it is a *distance* effect. |
| Donor fog depth = per-vertex view-space distance | `RENDER_ARCH_SHADERS.md:151` E20 → `def.pvl.sm.vert:38-42` | **READABLE via evidence report**, same caveat. |
| Donor camera fog keys / gameplay state | `RENDER_ARCH_CAMERA.md:59-62` → `camera.cfg:51-64`, `DynFogDepth=False` at `:59` | **READABLE via evidence report**. Depth fog is **off in the gameplay camera**, so it cannot be the 2D fog-of-war mechanic. |
| Fog overlay disposition | `V71_mechanics_inventory.md:166` — PARTIAL; "engine binding to `fog_explored`/`fog_vis` not readable"; "Exact donor fog↔explored-state mapping: UNVERIFIED — do not invent a new fog rule." | **UNVERIFIED**, honoured: no donor fog constant was fabricated; only the 2D port alpha ladder is used and it is labelled as a *port* value. |
| Any donor 3D fog overlay mesh / shader binding | none re-read | **UNVERIFIED** — overlay geometry is a port-side implementation (`transparent ArrayMesh` + `blend_mix, unshaded` spatial shader), not claimed as donor parity. |

## 4. Implementation notes

- One `MeshInstance3D` named `FogOverlay`: one flat quad per map tile, vertex
  colours `Color(0,0,0,alpha)`, `render_priority = 10` (matches 2D
  `fog_sprite.z_index = 10` at `world.gd:346`). There is **no** `Sprite2D`
  and no full-map `ImageTexture`; the `t_fog3d.gd` structural gate checks both
  the live node tree and the literal `Sprite2D.new(`.
- Shader: `render_mode blend_mix, unshaded, cull_disabled, depth_draw_never`,
  `ALBEDO = COLOR.rgb; ALPHA = COLOR.a;`. `cull_disabled` avoids winding
  assumptions; `depth_draw_never` avoids overlay quads occluding each other.
- Recount is skipped when nothing feeds it (forced every 6th interval, or on
  reveal requests / entity movement / player-0 headcount change) — same gate
  as `world.gd:2191-2211`.
- `game.get(...)` is used for every optional field so the minimal stub in
  `t_fog3d.gd` cannot crash `bind()`; `game.has_method("tile_of")` guards the
  full recompute path.
- RNG: none. All tiles use a deterministic flat mapping.

## 5. Verification

- Tabs: `variant3d/scripts/world3d_fog.gd` — 317 lines, **0 space-indented
  lines** (PowerShell scan of every line).
- Parse via variant runner: **PASS** —
  `python variant3d\tools\godot_runner.py run --id v716-parse --timeout 90 -- --headless --path variant3d --check-only --script res://scripts/world3d_fog.gd`
  → `[runner] ticket 20 'v716-parse' END ok (run 6.27s)` (waited 128.96s in the
  shared FIFO). No parse errors; no new `class_name` required.
- `t_fog3d.gd` (owner V7-36, read-only here) via variant runner: **PASS** —
  `python variant3d\tools\godot_runner.py run --id v716-t-fog3d --timeout 90 -- --headless --path variant3d --script res://tests/t_fog3d.gd`
  → `[runner] ticket 28 'v716-t-fog3d' END ok (run 4.11s)`.
  `variant3d/tests/results/t_fog3d.json`: `status: PASS`, `passed: true`,
  `blocked: false`, **9/9 checks passed** — `module_loads`, `instance_created`
  (`Node3D`), `bind_api`, `sync_api`, `sync_callable`, `fog_explored_exposed`
  (`size=12 want=12`), `fog_vis_exposed` (`size=12 want=12`),
  `no_fullmap_sprite2d` (`sprite2d_nodes=0 source_Sprite2D.new=false`),
  `no_new_hangs` (`0.20s`).

**Verification is structural/API only**: the stub has no sim, no mapgen and no
GPU frame, so PASS does **not** prove visual fog parity, donor depth-fog parity,
or correct alignment with `world3d_terrain.gd` heights (open questions 1, 2, 4
and 6 above). No windowed visual gate was run by this agent.

## 6. Open questions

1. **Terrain height alignment (integration).** The overlay samples `game.height` (pattern-generated), while `world3d_terrain.gd` is specified to build its mesh from the base64 dump height (`V73_ATOMIC_CONTRACT.md:12`). If those two arrays differ, per-tile fog quads can sink into or float above the terrain. Needs a joint check by the V7-15 / integrator; `FOG_Y_OFFSET = 0.03` is a port-side anti-z-fighting value with no donor source.
2. **Tile→world centring.** This module copies `world3d.gd:215-220` corner mapping (`tx - MAP_W/2`), whereas a module centred on tile centres would differ by `TILE_M/2`. Integration must confirm the terrain module uses the same convention.
3. **Entity visibility filter.** V71 §3 (`:192`) requires entity culling to read the same arrays; that belongs to `world3d_entities.gd` / `world3d.gd`, not this file. No visibility mutation was done here.
4. **Donor fog ↔ explored binding** remains UNVERIFIED (V71 `:166`). A donor visual A/B of the overlay has no anchor; alpha values are explicitly port-side.
5. **Full-map rebuild cost.** `_refresh_mesh()` re-adds the surface (25,600 quads at the default 160×160) only when a visibility bit flips. On a large map this may need a partial `surface_update_attribute_region` optimisation; not measured here (headless parse/test only).
6. **Depth interaction.** `depth_draw_never` plus per-tile quads can double-blend where relief overlaps in screen space. Visual parity against the 2D `z_index=10` overlay needs a windowed capture by the integration/visual owner.

**End of V7-16 report.**
