---
owner: V7-32
date: 2026-11-24
role: atomic test writer — camera3d API test atom
lane: Wave 7 phase 2 (variant3d test atoms)
output: docs/coord_swarm_2026-11-24/reports/V732_test_camera3d.md
status: BLOCKED-PENDING-MODULE
module: variant3d/scripts/camera3d.gd (ABSENT at verification time)
---

# V7-32 — `t_camera3d.gd`: deterministic camera3d API contract test

## 1. Scope and ownership

Exactly two new files, no other edits:

- `variant3d/tests/t_camera3d.gd` (tabs, `extends SceneTree`, self-exiting via
  `call_deferred("quit", code)`; no result-JSON side file).
- This report.

Contract lines honoured: `V73_ATOMIC_CONTRACT.md:10` (module API),
`:26-30` (test atoms load via `load("res://scripts/<module>.gd")`, no
`class_name` needed), `:37` (all runs through variant3d's runner).

## 2. Test design

The test dynamically resolves `res://scripts/camera3d.gd`:

1. `ResourceLoader.exists()` guard → if false, print
   `FAIL MODULE_MISSING — …`, then `STATUS BLOCKED-PENDING-MODULE — camera3d.gd
   has not landed; assertions NOT weakened`, summary `T_CAMERA3D FAIL 0 checks
   (module missing)`, `quit(1)`. A missing file can never be misread as a pass.
   A present-but-unloadable script (`load()` → null) takes the same path.
2. On success, instantiate via `script.new()`, require `Camera3D`, attach to the
   root with a fixed `1280×720` viewport, add a minimal `MockGame` Node
   (`MAP_W/MAP_H/map_w/map_h=320`, `view_scale=1.0`, empty `height`) and call
   `bind(game, 1.0)` through `call()` so no static typing couples the test to
   the module.

Checks (each prints its own `PASS <name> — detail` / `FAIL <name> — detail`):

| Check | Assertion | Tolerance / method |
|---|---|---|
| `MODULE_IS_CAMERA3D` | `script.new()` yields a `Camera3D` | strict type |
| `API_SURFACE` | `bind`, `world_to_px`, `screen_to_world`, `clamp_pos`, `get_view_rect`, `get_viewport_corners`, `zoom_step`, `set_zoom_target` all present | `has_method` |
| `API_VIEW_SCALE`, `API_ZOOM_TARGET` | properties exist; abort early if `zoom_target` non-numeric | non-null |
| `PROJECTION_PERSPECTIVE` | `projection == Camera3D.PROJECTION_PERSPECTIVE` | exact enum |
| `TILT_NEG32` | signed tilt from `-Z` basis ≈ donor tilt | ±0.5° |
| `ROUNDTRIP_P1..P3` | `world_to_px(screen_to_world(p)) ≈ p` at centre, (0.25W,0.75H), (0.75W,0.85H) | ≤1.0 px/axis, finite values |
| `VIEWPORT_CORNERS_4` | `get_viewport_corners().size() == 4` | exact |
| `VIEW_RECT_NONEMPTY` | `get_view_rect()` is `Rect2` with positive size | >0 |
| `ZOOM_CLAMP_DONOR` | `set_zoom_target(±extreme, true)` clamps to donor-derived zoom `[20/58, 58/20]` | ±1e-3 |
| `BOUNDS_MATCH_DONOR` | `min_zoom/max_zoom` (or `min_height/max_height`) match donor 20/58; if no bound properties exist, accept the behavioural clamp check and say so explicitly in the detail | ±1e-3 |
| `ZOOM_STEP_MONOTONIC` | from mid-band base, 3× `zoom_step(+0.5)` strictly increase, then 3× `zoom_step(-0.5)` strictly decrease | >1e-6 per step |

Exit code is `0` only when `_fail == 0`. No `load()` of the whole selftest, no
map generation, no donor binary execution.

## 3. Donor evidence (read-only, no donor file executed or copied)

From `G31_donor_3d_truth.md` §2a, claim table #1, and a fresh read-only byte
decode of `C:\Games\Cossacks 3\data\cameras\camera.cfg`:

- `camera.cfg:6-10` — `SphereHeight = 58`, `SphereHeightMin = 20`
  (`SphereLength = 58`, `SphereLengthMin = 20`): dolly 20–58 m.
- `camera.cfg:32-35` — `MinHeightMinAngle`, `MinHeightMaxAngle`,
  `MaxHeightMinAngle`, `MaxHeightMaxAngle` all `-32`: tilt −32°.
- `camera.cfg:44-45` — `MinFocalLength`/`MaxFocalLength` both `400`.
- No `OrthoWidth`/`OrthoHeight` key in either cfg; main view is perspective
  (G31 claim 1: **CONFIRMED**, derived strong). Donor absolute sensor/FOV stays
  UNVERIFIED and is deliberately *not* asserted by this test.

Derived zoom clamp bounds (same algebra as the shipping 2D `camera.gd:81-84`):
`z_min = 20/58 = 0.3448276`, `z_max = 58/20 = 2.9`.

The test reads `camera.cfg` at runtime via `FileAccess` when reachable
(`MinHeightMinAngle`, `SphereHeightMin`, `SphereHeight`), and otherwise falls
back to the same G31 constants, printing which source was used. In the run
below the donor read was **not reached** (the module-missing short-circuit
returned first), so runtime donor parsing remains unverified in practice.

## 4. Verification — job id and result

Command (verbatim, variant3d runner only):

```
python variant3d\tools\godot_runner.py run --id v732-camera3d --timeout 90 -- --headless --path variant3d --script res://tests/t_camera3d.gd
```

- **Job id:** `v732-camera3d` — **ticket 7** — runner verdict `failed`, exit 1,
  run 5.76 s, wait 0.00 s (Godot 4.7.2.stable).
- **stdout** (`variant3d/.godot_queue/results/00000007_v732-camera3d/stdout.txt`):
  ```
  T_CAMERA3D start res://scripts/camera3d.gd
  FAIL MODULE_MISSING — res://scripts/camera3d.gd (ResourceLoader.exists() == false)
  STATUS BLOCKED-PENDING-MODULE — camera3d.gd has not landed; assertions NOT weakened
  T_CAMERA3D FAIL 0 checks (module missing)
  ```
- **stderr:** empty (no parse/runtime errors — the guard prevents a spurious
  Godot `load()` error).
- Repo content confirmed: `variant3d/scripts/camera3d.gd` does not exist; only
  the 2D `variant3d/scripts/camera.gd` (`extends Camera2D`, `class_name C3Camera`)
  is present. The other Wave-7 modules are likewise not yet landed.

**Status: BLOCKED-PENDING-MODULE.** The FAIL is intentional and honest: the
contract atom cannot be exercised until its module exists. No tolerance was
loosened and no check was skipped silently to obtain a pass.

## 5. Re-run instruction for the module owner / coordinator

When `variant3d/scripts/camera3d.gd` lands, re-run with a fresh id (e.g.
`v732-camera3d-r2`) using the same command pattern; expect 12+ `PASS` lines and
`T_CAMERA3D PASS n/n`. Register the atom in `variant3d/tests/manifest.json`
last (that file is owned by another agent — not touched here).

## 6. Open questions

1. Exact bound property names on the landed module: `min_zoom/max_zoom`,
   `min_height/max_height`, or none. The test handles all three cases, but
   only a real run will show which branch is taken.
2. Will `bind(game, view_scale)` accept the untyped `MockGame` Node? The
   contract declares `game` untyped; a stricter runtime parameter type would
   make `bind` refuse the mock (a legitimate contract violation to report).
3. Is the 1.0 px round-trip tolerance appropriate once the module's projection
   convention is fixed? It was chosen tight-but-achievable for float math; if
   the module reports screen coordinates in a different space, the failure is
   informative rather than weakened.
4. Is the donor cfg absolute path readable in every runner environment? The
   G31 fallback (`-32°`, 20/58 m) makes the test deterministic either way; the
   runtime-read branch still needs a live run to be exercised.
5. "Clamp bounds" were interpreted as donor zoom/dolly bounds (20–58 m), not
   `clamp_pos()` map-extent clamping (320 tiles × 2 m). If the module owner
   intended the latter, add a separate atom rather than relaxing this one.
6. Donor FOV/sensor remains UNVERIFIED (G31 open question 1); this test asserts
   projection mode and tilt only, never an FOV number.
