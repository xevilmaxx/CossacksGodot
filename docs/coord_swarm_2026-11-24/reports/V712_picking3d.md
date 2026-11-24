---
owner: V7-12
date: 2026-11-24
mode: atomic builder (new code)
scope: "SINGLEPLAYER SKIRMISH ONLY (D-12) — 3D picking adapter for the variant3d ortho branch; no campaign/mission/network paths, no donor binaries"
governing_rule: "docs/coord_swarm_2026-11-24/V73_ATOMIC_CONTRACT.md:11 (exact API, single file per agent); every 3D constant cites donor path:line or UNVERIFIED"
deliverable: "variant3d/scripts/picking3d.gd (NEW) + this report only"
backup: "n/a — new file, nothing overwritten"
donor: "C:\\Games\\Cossacks 3 (private use, read-only latin-1 bytes; no donor binary run or copy)"
toolchain: "python 3.14; Godot 4.x via variant3d/tools/godot_runner.py (own spool)"
code_edits: "1 new file (picking3d.gd)"
godot_runs: "1 x --check-only parse (job v7-12-picking3d-parse) — see §Verification"
---

# V7-12 — `picking3d.gd`: 3D picking / ground unprojection adapter

**Status:** implemented, single new file; parse verification PASS (§4). Runtime
picking behaviour awaits the separate `t_pick3d.gd` atom. No `game.cmd_*` call
exists in the module. The 2D path is untouched.

## 1. Method

`picking3d.gd` extends `Node`, stores `game` + a `Camera3D` from `bind(game, cam)`,
and exposes only the contract API. It reads sim data (`game.entities`,
`game.res_nodes`, `game.pick_radius()`, `game.height_at()`, `MAP_W/MAP_H/TILE`)
and returns dictionaries or a `Vector2`; it never issues orders.

- **`ground_point(screen)`** — `cam.project_ray_origin(screen)` +
  `cam.project_ray_normal(screen)`; marches the ray in 1 m steps against the
  bilinear height field (`game.height_at`, `game.gd:1893-1907`), refines the
  first crossing with 20 bisection steps, and returns the hit's sim-metre
  `(x, y)` (`Vector2(world.x, world.z) + world_offset`). Falls back to the
  `Y = 0` plane for rays parallel to, or pointing away from, the ground; with no
  camera bound it mirrors the 2D `p / 16.0` fallback (`input_controller.gd:341`).
- **`pick(screen)`** — screen-space hit test over live entities. Each entity is
  projected from its ground position (plus a small body-centre lift) via the
  camera transform; the hit radius is `game.pick_radius(e) * px_per_metre`.
  Player-0 entities inside their radius win; closer-to-cursor wins, with camera
  depth resolving near-ties (occlusion ordering). The 2 m any-entity fallback
  from `input_controller.gd:363-365` is preserved so enemies remain selectable
  for info/attack. Returns the entity `Dictionary` or `{}`.
- **`pick_res(screen)`** — same projection for `game.res_nodes`, with the donor
  port's exact filters: skip `stump`/`bush`, skip depleted nodes except `food`,
  reach `2.5 + radius`, strict `<`, lowest `id` on a tie
  (`input_controller.gd:666-690`). Returns the resource `Dictionary` or `{}`.
- **World ↔ sim transform** — default is the heightmap cell-centre convention
  (`heightmap_world3d.gd:200-202` places cell `(x,z)` at
  `((x+0.5-w/2)*TILE_M, h, (z+0.5-h/2)*TILE_M)` while `game.gd:1897` samples
  height at `p/TILE - 0.5`, hence sim `p` ↔ world `(p.x - MAP_W*TILE/2, h,
  p.y - MAP_H*TILE/2)`): `_world_to_sim = (MAP_W*TILE/2, MAP_H*TILE/2)`.
  When the bound camera exposes `screen_to_world()` (camera3d.gd contract),
  `bind` calibrates the offset against it using a **flat Y=0** ray hit at the
  viewport centre (no height sampling, so no circular dependency); implausible
  offsets are rejected and the default is kept.
- **Pixels per metre** — Godot 4 `Camera3D.size` is the diameter of width or
  height selected by `keep_aspect` (KEEP_HEIGHT default): `vp.y / size` (or
  `vp.x / size` for KEEP_WIDTH); perspective uses FOV at the point's camera
  depth. World→screen uses the matching analytic projection, so it is
  self-consistent even when the camera is not yet in a viewport.

No RNG. Indentation is tabs throughout, matching `V73_ATOMIC_CONTRACT.md:3`.

## 2. Donor / reference evidence

| Item | Evidence | Status |
|---|---|---|
| API surface (`bind`, `pick`, `pick_res`, `ground_point`) | `V73_ATOMIC_CONTRACT.md:11` | OBSERVED (contract) |
| screen→world must go through the camera, not raw pixel division | `app/scripts/input_controller.gd:337-343` | OBSERVED (port) |
| entity pick radius + players-only nearest + 2 m fallback | `app/scripts/input_controller.gd:345-369`; `app/scripts/game.gd:1555-1560` | OBSERVED (port) |
| resource pick filters, 2.5 m reach, strict `<`, id tie-break | `app/scripts/input_controller.gd:643-690` | OBSERVED (port) |
| height field is a plain bilinear metre array | `app/scripts/game.gd:1893-1907`, `:459-460`, `:16` | OBSERVED |
| 3D world cell-centre convention / metres | `app/scripts/heightmap_world3d.gd:200-202`, `:31-33`; `app/scripts/world3d.gd:12-14` | OBSERVED (port) |
| donor selection is engine-side, not script-readable | `misc.script:7-27` (`GetCountGameManagerPickedObjects` / `GetHandleGameManagerPickedObjects`, `GameManager` selection at `:6419-6447`) | OBSERVED (donor bytes) |
| donor pick radius / overlap-depth rule | not exposed in readable donor scripts; `oncamera.inc:1-80` is camera control only | **UNVERIFIED** |
| `BODY_LIFT_M = 0.8` body-centre lift; 1 m ray step; 0.5 px tie epsilon | no donor equivalent; screen-space fallback for an oblique camera | **UNVERIFIED — PORT APPROXIMATION** |
| donor asked for "click unit/building/resource/ground" semantics | preserved by the three methods above | OBSERVED intent / approximate in 3D |

## 3. Exact API (as implemented)

```
extends Node
bind(game, cam) -> void
pick(screen: Vector2) -> Dictionary      # unit/building entity or {}
pick_res(screen: Vector2) -> Dictionary  # resource node or {}
ground_point(screen: Vector2) -> Vector2 # sim metres under the cursor
```

No other public method is required. Private helpers are prefixed `_`.
No `game.cmd_*`, `Input`, signal or scene-tree mutation.

## 4. Verification

**Job:** `python variant3d\tools\godot_runner.py run --id v7-12-picking3d-parse --timeout 90 -- --headless --path variant3d --check-only --script res://scripts/picking3d.gd`

**Result: PASS (parse).** Ticket 26, `exit: 0`, `status: "ok"`, stderr empty;
stdout only Godot's version banner (`Godot Engine v4.7.2.stable...`). Queue
wait 226.46 s, run 6.00 s. Artifacts:
`variant3d/.godot_queue/results/00000026_v7-12-picking3d-parse/{stdout,stderr}.txt`
and `00000026.json`.

`--check-only` validates parsing/static analysis only: it does **not** exercise
runtime picking behaviour or the 3D scene. No `t_pick3d.gd` run was performed
here — that atom belongs to the separate test agent (`V73_ATOMIC_CONTRACT.md:26-30`).
Runtime correctness of the world-offset calibration, hit radii and depth
ordering therefore remains UNVERIFIED until that test lands (see §6).

## 5. Handoff to input integration (`input_controller.gd` owner)

Replace only the three internals `_screen_to_world` / `_pick` / `_pick_res` with
calls to a `picking3d` instance bound as `picking.bind(game, camera)`:

- `ground_point(mb.position)` returns the same sim-metre `pw` the 2D path got
  from the canvas inverse — feed it unchanged to the existing order/`cmd_*`
  code (`input_controller.gd:420`, `:481-482`, `:1015-1016`, `:1078`).
- `pick(mb.position)` replaces `_pick(pw, true)` at `:434`; for the `false`
  (any-entity) call sites at `:492` / `:585`, `pick()` already includes the
  2 m any-entity fallback — do **not** alter the surrounding `cmd_*` calls.
- `pick_res(mb.position)` replaces `_pick_res(pw)` at `:588` / `:1107`.
- The returned dictionaries are the live sim dictionaries (`game.entities` /
  `game.res_nodes` elements), so `_set_selection`, HUD panels and `cmd_*`
  continue to see identical fields.

Do not import a `class_name`; load dynamically as `load("res://scripts/picking3d.gd")`.

## 6. Open questions

1. **World offset** — the flat-plane calibration assumes camera3d.gd's
   `screen_to_world()` unprojects to the `Y=0` plane. If it unprojects to the
   heightfield instead, the offset is shifted by the local height; the
   integration owner can set `picking._world_to_sim` explicitly. Need the
   camera3d module's final convention to confirm (currently UNVERIFIED).
2. **Depth ordering** — screen distance is primary, camera depth only breaks
   near-ties. The donor rule is engine-side (`misc.script:7-27`), so this is a
   port decision; confirm against 50 scripted click→selection cases (M2
   acceptance criterion, `RENDER_ARCH_PORT_FEASIBILITY.md:174`).
3. **Body lift** — `BODY_LIFT_M = 0.8` is a guess at the visual centre of a
   unit/building mesh; re-tune once `world3d_entities.gd` lands and actual mesh
   heights are known.
4. **Performance** — brute-force scan per click (no spatial hash). The 2D
   resource path used a 16 m hash (`input_controller.gd:643-661`); add one here
   only if click latency becomes measurable at 400+ units.
5. **Perspective** — supported analytically but the variant target is
   orthographic; perspective hit radii are calibrated at each entity's depth
   and were not visually verified.
