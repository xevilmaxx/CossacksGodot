---
agent: V7-17
role: atomic builder — 3D-aware minimap viewport-box adapter
date: 2026-11-24
status: DONE (parse-verified; runtime box not measured in this atom)
gate: variant runner `--check-only` PASS — ticket 13 `v717-hud3d-parse`, exit ok, stderr empty
owns: "variant3d/scripts/hud3d_adapter.gd (new) + this report only; no other edits"
runner_jobs: ["v717-hud3d-parse"]
scope: "SINGLEPLAYER SKIRMISH (D-12); no RNG; TABS; no donor binaries run or copied"
---

# V7-17 — `variant3d/scripts/hud3d_adapter.gd`

## 1. What was built

One new file, `variant3d/scripts/hud3d_adapter.gd` (extends `Node`), with EXACTLY
the three methods from `V73_ATOMIC_CONTRACT.md:16`:

| API | Signature | Behavior |
|---|---|---|
| bind | `func bind(p_cam, p_hud) -> void` | Stores the V7-5 `camera3d` and the CanvasItem HUD (`C3HUD`) as duck-typed `Object`s. No static `C3Camera`/`C3World` types. |
| get_minimap_box | `func get_minimap_box() -> Rect2` | Calls `cam.get_viewport_corners()` (4 ground corners), maps each world-metre corner to minimap pixel (tile) space using the 2D HUD's mapping, clamps to map bounds, returns the bounding `Rect2`. |
| screen_to_world | `func screen_to_world(screen) -> Vector2` | Forwards to `cam.screen_to_world(screen)` (single source of truth in V7-5). Returns `Vector2.ZERO` if unbound/no method. Accepts `Vector3` result via `(x,z)`. |

The CanvasItem HUD, `_mm_paint_box`, minimap image, minimap data and minimap
click handler were **not** edited (read-only reference: `app/scripts/hud.gd`).

## 2. Exact formula (port-derived, not invented)

2D box source, read-only: `app/scripts/hud.gd:1394-1412`.

```
pxm       = Data.TILE_M * world.view_scale          # hud.gd:1404
canvas_px = world_m * world.view_scale              # hud.gd:1375
x_mm      = int(canvas_px / pxm)                     # hud.gd:1409-1412
          = int(world_m * view_scale / (TILE_M * view_scale))
          = int(world_m / Data.TILE_M)               # view_scale cancels
```

So each ground corner `p` (metres) maps to minimap pixel (tile) coordinates
`Vector2(int(p.x / 2.0), int(p.y / 2.0))` (`Data.TILE_M := 2.0`,
`app/scripts/data.gd:23`; same as `game.TILE` at `app/scripts/game.gd:16` and
`tile_of()` at `app/scripts/game.gd:459-460`). `int()` truncation toward zero is
kept identical to the 2D HUD; `mini/maxi` over the four corners gives
`x0,y0,x1,y1`, each clamped to `[0, MAP_W-1] / [0, MAP_H-1]`, exactly as at
`hud.gd:1409-1412`.

Return convention (important for the integration agent):

```
Rect2.position = (x0, y0)                       # INCLUSIVE min pixel
Rect2.size     = (x1 - x0 + 1, y1 - y0 + 1)     # end = EXCLUSIVE
```

`hud.gd:1423-1433` (`_mm_paint_box`) takes an inclusive `Vector4i`, so convert:
`Vector4i(int(b.position.x), int(b.position.y), int(b.end.x)-1, int(b.end.y)-1)`.

Fallbacks (no crash, no invented state): unbound adapter, missing camera method,
null/empty corners or non-finite corners ⇒ full-map box `Rect2(0, 0, MAP_W,
MAP_H)`, matching the 2D `hud.gd:1397-1400` default. `MAP_W/MAP_H` come from
`hud.game` when bound, otherwise `Data.MAP_W/Data.MAP_H`. Corner elements accept
`Vector2` (metres), `Vector3` (uses `(x,z)`, see `variant3d/scripts/world3d.gd:215-216`
for game `(x,y)` → world `(x,z)`) or a 2-element numeric `Array`.

## 3. Donor / port evidence and honesty limits

| Claim | Evidence | Status |
|---|---|---|
| `pxm = TILE_M * view_scale`; box = canvas rect / pxm | `app/scripts/hud.gd:1404-1412` (port file, read-only) | VERIFIED |
| `canvas_px = world_m * view_scale` | `app/scripts/hud.gd:1375` | VERIFIED |
| `TILE_M = 2.0`, `TILE = 2.0`, `tile_of = int(p/TILE)` | `app/scripts/data.gd:23`, `app/scripts/game.gd:16`, `:459-460` | VERIFIED |
| `_mm_paint_box` bounds are inclusive | `app/scripts/hud.gd:1423-1433` | VERIFIED |
| Ground-corner projection belongs to `camera3d.gd`, not this file | `V73_ATOMIC_CONTRACT.md:10` | CONTRACT |
| Donor path:line for the 3D minimap viewport box itself | none re-read in this atom; `V71_mechanics_inventory.md:160` and `:212` mark it **UNVERIFIED** | UNVERIFIED — no substitute donor constant invented |
| Donor minimap rotates with yaw / ground quad vs axis-aligned | `V71:160`, study open Q9 at `V71:265` | UNVERIFIED (open question below) |

No donor binary was read or executed here. All numbers in this file are either
port-file citations above or the algebraic cancellation of two cited port
expressions; no new 3D constant was introduced.

## 4. Verification (honest)

- `python variant3d\tools\godot_runner.py run --id v717-hud3d-parse --timeout 120 -- --headless --path variant3d --check-only --script res://scripts/hud3d_adapter.gd`
  → ticket 13, status `ok`, waited 20.66 s, ran 7.36 s. `stdout.txt` contains
  only the Godot 4.7.2 banner; `stderr.txt` empty. **Parse PASS.**
- Indentation check: 103 lines, 92 tab characters, zero space-indented or
  trailing-whitespace lines. No RNG calls anywhere in the file.
- NOT measured here: actual box values with a live `camera3d` (`camera3d.gd`
  was not present in `variant3d/scripts/` at write time — it is V7-5's file),
  runtime pixel output, or a 3D HUD screenshot. Those belong to the V7-6
  integration agent and the V7-31…V7-37 test atoms. No selftest/uitest was run
  by this atom: it adds no new scene, no global class and no test file.

## 5. Handoff — `hud.gd` integration agent (V7-6)

1. Instantiate/bind this adapter once when constructing the 3D path, e.g.
   `var adapter = load("res://scripts/hud3d_adapter.gd").new();
   adapter.bind(cam3d, self)` where `self` is the HUD. Keep it alive for the
   session. No `class_name` was registered, so use `load()` (matches the
   variant's no-global-class pattern).
2. In `_draw_minimap_viewport_box()` (read-only reference
   `app/scripts/hud.gd:1394-1421`), branch ONLY the camera-derived box
   computation on `render_mode == 3d`: replace the block at `:1401-1412`
   (`get_viewport().get_camera_2d()`) with `adapter.get_minimap_box()` plus the
   inclusive-`Vector4i` conversion in §2. Keep `force`, `_mm_box_last`,
   `_mm_paint_box`, `minimap_tex.update()` and all minimap data/image code
   unchanged. Keep the `2d` path byte-identical.
3. `_on_minimap_input()` (`hud.gd:1368-1386`) is unchanged: it already computes
   `world_pos = mp * MAP_W/MAP_H * TILE_M`. In 3D it must move `cam3d` instead
   of `get_camera_2d()` — that is a `hud.gd`-owner decision, not this adapter's.
   `screen_to_world()` here is a forwarder for any future HUD screen-point
   conversion; it does not change minimap clicks.
4. The adapter returns the *axis-aligned bounding box* of the four projected
   ground corners, not a rotated quad — the 2D painter can only draw an
   axis-aligned `Vector4i` box. See open question 2.

## 6. Open questions

1. **Corner contract detail (UNVERIFIED).** `V73_ATOMIC_CONTRACT.md:10`
   specifies `get_viewport_corners()->Array` (4 ground corners) but does not
   fix element type/order or unit. This adapter assumes world metres and
   accepts `Vector2`, `Vector3(x,z)` or `Array[2]`. If V7-5 returns canvas px or
   minimap px instead, the division by `TILE_M` must be removed/changed —
   please confirm at integration time.
2. **Frustum box fidelity (UNVERIFIED).** Whether the donor box rotates with
   camera yaw, or is an axis-aligned approximation, has no re-read donor
   path:line (`V71:160`, `:265`). Four-corner AABB is the port approximation
   until a 3D capture can be compared.
3. **Degenerate corners.** Corners behind the camera / at infinity can produce
   non-finite values; those are skipped. If fewer than one valid corner
   remains, the full-map fallback is returned. Whether to instead project the
   visible ground polygon more carefully is a V7-5/V7-7 decision.
4. **`screen_to_world` basis.** Viewport-px → metres is owned by
   `camera3d.gd`; this file forwards unchanged and returns `Vector2.ZERO` when
   unbound. If the HUD needs minimap-local-px → world, that is a separate API,
   deliberately out of this atom's scope.
5. **Runtime proof pending.** The V7-31…V7-37 test atoms should assert, with a
   stub camera returning known metre corners, that `position/end` match
   `int(corner/TILE_M)` clamped to the map, and that the unbound fallback is the
   full map. Parse-only verification here cannot prove that.

## 7. Files changed

- NEW `variant3d/scripts/hud3d_adapter.gd` (only code file; 103 lines, tabs).
- NEW `docs/coord_swarm_2026-11-24/reports/V717_hud3d_adapter.md` (this report).
- No backups were needed: both files are new. `app/**` untouched.
