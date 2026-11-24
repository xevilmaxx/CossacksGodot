---
id: V7-73
owner: V7-73
date: 2026-11-24
scope: "variant3d/scripts/world3d_fx.gd ONLY — fix P0 G9 (FX world_offset never assigned) against the centred terrain/entity origin; this report"
status: "COMPLETE — 7/7 probe checks, 13/13 existing FX regression, parse clean; NO visual parity claim"
governing_rule: "AUDIT3D_CHARTER.md:6-15 — path:line evidence, OBS vs INFERENCE, UNVERIFIED labelled, smallest grounded fix, no git operations."
owns: ["variant3d/scripts/world3d_fx.gd", "docs/coord_swarm_2026-11-24/reports/V773_fx_world_offset.md"]
godot_runs: "variant3d runner tickets 133 (parse), 134 (temporary probe, 7/7), 135 (t_fx3d.gd regression, 13/13)"
---

# V7-73 — FX world-origin fix (AUDIT3D-06 P0-1 / G9)

## 1. Scope discipline

- Edited **only** `variant3d/scripts/world3d_fx.gd` and this report. No edit to
  `world3d.gd` (V7-62), entities, terrain, main, input, app, tests, config,
  data or JSON. No git command was run.
- The current file state was read first: V7-65's donor key-colour work
  (`PLAYER_COLORS`, `_load_player_colors`, `_player_color`, donor PFX citations,
  `_kind_color`) is **preserved unchanged**. This is an additive edit.
- The temporary probe `variant3d/tests/v773_fx_world_offset_probe.gd` and its
  result `variant3d/tests/results/v773_fx_world_offset.json` were **deleted**
  after measurement (both `Test-Path` = False). No `.uid` was generated.
- **No visual parity claim** is made: no screenshot, no donor art, no 2D bake,
  no RNG. Only coordinate arithmetic was measured.

## 2. Origin-convention evidence (all OBSERVATION, `path:line`)

| Fact | Evidence |
|---|---|
| FX declared `world_offset` but never assigned it; `world_pos()` subtracts it | `AUDIT3D_06_fx_anim_audio.md:47,102`; pre-edit `variant3d/scripts/world3d_fx.gd:90,227-236` (= current `:110,367-376`) |
| Entities centre sim point positions with `p - MAP_W/H*0.5*TILE_M` | `variant3d/scripts/world3d_entities.gd:63-65` (comment), `:541` (`return Vector3(p.x - w*0.5*TILE_M, y, p.y - h*0.5*TILE_M)`) |
| Terrain centres vertices on the same origin, with a cell-centre `+0.5` term | `variant3d/scripts/world3d_terrain.gd:307-314` (`(float(x)+0.5-cx)*TILE_M`, `cx = w*0.5`) |
| `TILE_M` is 2.0 m | `variant3d/scripts/data.gd:23`, `game.gd:16`; FX module const at `world3d_fx.gd:37-38` |
| Default 320×320 tiles → half extent (320, 320) m | `variant3d/config.json:39-40`; `game.gd:35-36` supplies `MAP_W`/`MAP_H` |
| `world3d.gd` calls only `fx.bind(game)` | `variant3d/scripts/world3d.gd:364-367` |

The `+0.5` in the terrain vertex formula is a cell-**centre** correction;
FX/entity `pos` values are **points** in the same sim-metre space
(`game.gd:1893-1907 height_at`, entity comment at `world3d_entities.gd:63-64`).
FX therefore deliberately follows the **entity point transform** (`:541`),
which is what the audit asks for. The residual 1 m cell-centre term is
terrain-vertex geometry, not an FX placement error.

## 3. Exact diff (only `variant3d/scripts/world3d_fx.gd`)

Current line numbers shown; `+` = added, unchanged lines shown as context only.

```diff
@@ header (current :8-23), added after the V73 API list
+# V7-73 — additive, backward-compatible origin surface (no existing call changes):
+#   bind(game, world_offset) — optional 2nd arg (Vector2); default derives from game
+#   set_world_offset(offset) — public setter; shifts already-live FX nodes by the delta
+#
+# ORIGIN CONVENTION (V7-73, fixes AUDIT3D-06 G9; evidence at
+# docs/coord_swarm_2026-11-24/reports/AUDIT3D_06_fx_anim_audio.md:47,102):
+#   Sim positions are map-origin metres; the 3D scene is centred on origin.
+#   world3d_entities.gd:63-65,541 maps p -> (p.x - MAP_W*0.5*TILE_M, y,
+#   p.y - MAP_H*0.5*TILE_M). world3d_terrain.gd:307-314 centres vertices with
+#   (x+0.5-w/2)*TILE_M; its +0.5 is a cell-CENTRE term (terrain vertices sit at
+#   cell centres), whereas FX/entity sim positions are POINTS, so FX follows the
+#   entity point transform. TILE_M = data.gd:23 / game.gd:16 = 2.0. With
+#   config.json:39-40 (320x320 tiles) the half extent is (320, 320) metres.
+#   bind() now derives that offset from game.MAP_W/MAP_H: no edit to world3d.gd
+#   (owned by V7-62) is needed. No donor art or 2D bake involved.

@@ public state (current :108-112)
-# Subtract from map pos to centre the scene
+# Subtract from map-origin sim pos to centre the scene (see ORIGIN CONVENTION).
+# Pre-V7-73 this was never assigned; bind() now derives it from the bound game.
 var world_offset: Vector2 = Vector2.ZERO
+var _offset_pinned: bool = false   # explicit bind arg / setter wins over re-derivation

@@ public API (current :136-222)
-func bind(g) -> void:
+# `world_offset` is optional: bind(game) keeps the V73 contract signature and
+# derives the centred origin from game.MAP_W/MAP_H; bind(game, offset) accepts an
+# explicit Vector2 (V7-73 integration handoff surface).
+func bind(g, world_offset_override = null) -> void:
 	game = g
 	_events_seen = 0
+	_apply_world_offset(world_offset_override)
 	_load_player_colors()
 	stats["donor_key_colors_path"] = KEY_COLORS_PATH
 	... (V7-65 donor-colour stats unchanged) ...
 	_ensure_roots()

+# V7-73 public setter, safe to call after bind(): existing FX/ghost/rally nodes
+# are shifted by the delta so a late integration call cannot leave stale FX.
+# Pass a finite Vector2 in the SAME convention as world3d_entities.gd:541, i.e.
+# Vector2(MAP_W, MAP_H) * 0.5 * TILE_M (map-origin metres, not tiles).
+func set_world_offset(offset: Vector2, shift_existing: bool = true) -> void:
+	... finite guard / push_error ...
+	delta = offset - world_offset; world_offset = offset; _offset_pinned = true
+	stats["world_offset"] / stats["world_offset_source"] = "setter"
+	if shift_existing: _shift_created_nodes(-delta)
+
+func _apply_world_offset(override = null) -> void:
+	# valid Vector2 override -> pin it; pinned -> retain;
+	# else read MAP_W/MAP_H via g.get() -> world_offset = Vector2(w,h) * 0.5 * TILE_M
+	# else keep ZERO and report stats["world_offset_source"] = "unavailable_zero"
+
+func _map_tiles(g, key: String) -> int:      # int/float -> int, else -1 (Object or Dictionary)
+func _shift_created_nodes(shift: Vector2) -> void:  # XZ only on FX, ghost, rally nodes
```

`world_pos()` (current `:367-376`) is **unchanged**: it already subtracts
`world_offset`; the bug was that nothing ever set it. `bind()` now does, so all
three placement paths (`add_fx` `:187`, `draw_ghost` `:221`, `draw_rally` `:237`,
and `_orient_trail` `:592-593`) share the entity origin automatically. Hidden
state: `stats["world_offset"]` = `[x, y]`, `stats["world_offset_source"]` =
`game.MAP_W/MAP_H` in the normal path.

## 4. Verification — variant3d runner (tickets 133/134/135)

| Ticket | Job id / command | Result |
|---|---|---|
| **133** | `v773-fx-parse` — `--headless --path variant3d --check-only --script res://scripts/world3d_fx.gd` | **ok**, exit 0, run 2.32 s, stderr 0 bytes (Godot 4.7.2.stable) |
| **134** | `v773-fx-offset-probe` — temp probe, stub `MAP_W=MAP_H=320`, `TILE_M=2.0` | **ok**, exit 0, run 2.31 s, **7/7 PASS** |
| **135** | `v773-fx-regress` — existing `res://tests/t_fx3d.gd` | **ok**, exit 0, run 2.15 s, **13/13 PASS** (contract, lifetime, no-2D, no API errors) |

Probe method: bind a 320×320 `RefCounted` stub with `height_at() -> 0`; expected
scene position computed from the entity formula `p - (320, 320)`; spawn `"shot"`
FX at sim `(100, 240)`; compare the actual `Node3D.position`. The "before" value
is measured on a second instance with the pre-fix behaviour emulated by pinning
`world_offset = Vector2.ZERO` (the old never-assigned state).

### Measured offset error

| Quantity | Before (offset ZERO) | After (bind-derived) |
|---|---|---|
| `world_offset` | `(0, 0)` | `(320, 320)` m, source `game.MAP_W/MAP_H` |
| Rendered FX node at sim `(100, 240)` | `(100, 0, 240)` | `(-220, 0, -80)` |
| Expected (entity transform) | `(-220, 0, -80)` | `(-220, 0, -80)` |
| Per-axis error | `(+320, +320)` m | `(0, 0)` m |
| Error magnitude | **452.548 m** | **0.000 m** |

Additional probe assertions: derived offset equals expected (320,320);
explicit `bind(game, offset)` works; ghost and rally nodes land at exactly
`(-220, 0, -80)` (error 0.000 m); `set_world_offset(expected + (5,7))` shifts a
live FX node by exactly `(-5,-7)` (error 0.000 m). Tolerance 1e-4 m.
Probe and result JSON deleted after the run; numbers above are retained here.

## 5. Integration handoff

**No cross-file change is required.** `world3d.gd:364-367` already calls
`fx.bind(game)`; the module now derives the offset from `game.MAP_W/MAP_H` at
that moment, before any FX is spawned. V7-62 may leave those lines as-is.

If the integration owner prefers to pass the offset explicitly (documented,
`bind(game, world_offset)`-compatible; `Data` is already preloaded at
`world3d.gd:75`, `_int_prop` at `:132`), the exact one-line change in
`world3d.gd.bind()` would be:

```gdscript
		fx.bind(game, Vector2(float(_int_prop(game, "MAP_W", 160)),
			float(_int_prop(game, "MAP_H", 160))) * 0.5 * float(Data.TILE_M))
```

or, after the existing bind call, `fx.set_world_offset(...)` with the same
expression. Both are optional and were **not** applied here (V7-62 owns that
file). A pinned explicit value outranks later re-derivation; the setter also
shifts already-live FX, ghost and rally nodes.

## 6. Open questions / limits

- **Q1** Camera focus is still map-origin metres (`camera3d.gd:148-152`, audit
  Q5) while terrain/entity/FX meshes are centred. This fix aligns FX with the
  emitting entities; whether the camera or the whole world frame should change
  is an owner decision outside this scope.
- **Q2** A bound stub lacking `MAP_W`/`MAP_H` keeps `world_offset = ZERO` and
  reports `world_offset_source = "unavailable_zero"`. The real `game.gd:35-36`
  always provides them; any other host must use the documented setter.
- **Q3** Map dimensions read at `bind()` are not watched for later changes; a
  runtime resize needs a re-`bind` or `set_world_offset`. No such resize was
  observed in scope.
- **Q4** Height placement (`height_bias`, `game.height_at`) is unchanged. Only
  XZ origin centring was in scope; terrain's `HEIGHT_SCALE` vs `height_at`
  vertical agreement was not measured here (audit did not flag it as G9).
- No donor PFX value, sprite, animation or audio behaviour was touched; donor
  citations from V7-65 remain intact. **No visual parity claim.**
