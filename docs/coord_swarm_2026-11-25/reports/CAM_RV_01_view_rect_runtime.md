---
id: CAM-RV-01
title: "CAM-RV-01 — runtime re-verification of the world3d.view_rect half-map fix (double-click select-all-of-type)"
owner: CAM-RV-01 (verification micro-worker, coordinated swarm)
date: 2026-11-25
status: CONFIRMED__LIVE_64_3D_SCENE__20_OF_20__REAL_INPUT__SCRIPT_ERROR_0
scope: "Exactly two NEW files authored: variant3d/tests/t_view_rect_rv.gd and this report. No existing file edited — not world3d.gd, camera3d.gd, hud3d_adapter.gd, input_controller.gd, manifest.json, any fixture/scene/shader, or any of ATOM-REPAIR's 9 atoms. No direct `godot`; variant runner only. No full gates, no terrain ladder."
labels: [observed, derived, VERIFIED_RUNTIME, REAL_INPUT, VARIANT3D]
evidence_labels: [observed, derived, UNVERIFIED]
verdict: CONFIRMED
runner_jobs: [373, 378, 381]
final_job: 381 (camrv01-smoke3)
---

# CAM-RV-01 — runtime re-verify of the `world3d.view_rect` half-map fix

## Goal

Re-verify **at runtime, in a live 64² `render_mode=3d` scene** the claim that
CAM-02's four-line change at `world3d.gd:270-274`
(`xy = (c as Vector2) + Vector2(ox, oz)`) makes `world.view_rect` correct and
makes double-click select-all-of-type choose exactly the same-type player-0
units inside the view. CAM-01 and CAM-02 both stopped at **MEDIUM-HIGH
derived** confidence and explicitly asked for this live re-measurement; CAM-02's
smoke (ticket 356) only proved the edited script parses and takes the
out-of-tree full-map fallback, with **no** `view_rect` parity assertion.

Three checks were required and all three are now measured, not inferred:

1. `world.view_rect` is non-degenerate and equals an **independently computed**
   centred→SIM rectangle (raw `camera3d.get_viewport_corners()` +
   `Vector2(mw,mh)*TILE_M*0.5`, × `view_scale`).
2. A synthesised double-click selects **all** same-type units inside the view
   and **no** same-type unit outside it.
3. `hud3d_adapter.get_minimap_box()` is consistent with `world.view_rect`.

## Sources (all read before authoring; none edited)

| Source | What it supplied |
|---|---|
| `docs/coord_swarm_2026-11-25/reports/CAM_01_view_rect.md` `:106-135,183-216` | Why `camera3d.get_viewport_corners()` must **not** be shifted (double-shift of `camera3d.gd:438` and `hud3d_adapter.gd:62`); the exact change request to `world3d.gd:268-274`; effect path = double-click, not drag box; MEDIUM-HIGH derived confidence |
| `.../CAM_02_view_rect_shift.md` `:74-102,135-166` | Exact before/after lines at `world3d.gd:270-274`; `ox/oz` at `:252-253`; Vector3 branch `:275-279` already shifted; smoke ticket 356 = parse/fallback only; runtime parity UNVERIFIED, re-verify ticket requested |
| `.../V3D_01_selection_rectangle_audit.md` row 5 (`:252`) and `:172-174,220-224,312-315` | Break-point classification and the correction target: `world3d._update_view_rect()` omits the half-map shift that `hud3d_adapter.gd:62` adds; impacts double-click select-all-of-type, **not** the drag box |
| `docs/coord_swarm_2026-11-24/reports/PLAY2FIX_navbox.md` `:14-29,69-83` | Independent measurement that corners are CENTRED (camera subtracts half map in `_apply_transform()`), and the adapter's `p += Vector2(mw,mh)*TILE_M*0.5` at `hud3d_adapter.gd:62` is the correct second consumer; AABB asymmetry is perspective, not a frame error |
| `variant3d/scripts/world3d.gd:240-300` (read-only) | `_update_view_rect()` full body: `ox/oz` (`:252-253`), Vector2 branch (`:270-274`, now shifted), Vector3 branch (`:275-279`), finiteness guard, min/max accumulation, `view_scale` AABB (`:289-292`), `view_rect = rect` (`:293`); `sync()` calls it at `:684` |
| `variant3d/scripts/hud3d_adapter.gd:50-119` (read-only) | `get_minimap_box()` inclusive/exclusive tile Rect2 (`:55-76`); `get_minimap_corners()` adds the half-map offset at `:104-109` and maps `u=p.x/extent.x*mw` at `:110-118` |
| `variant3d/scripts/camera3d.gd:255-284,288-382,435-509` (read-only) | `screen_to_world()` returns CENTRED metres (`:275-284`); `get_viewport_corners()` fills TL/TR/BR/BL from it (`:376-383`); `clamp_pos()` adds `_map_half()` (`:458`); `jump_to_world()` sets a known SIM pose (`:423-431`); `_process` edge-scroll can pan the target (`:527-548`) — neutralised in the atom |
| `variant3d/scripts/input_controller.gd:620-763` (read-only) | **Citation drift disclosed:** SEL-01 shifted the double-click branch from the ticket's `:632-635` to the live `:733-743`; it tests `vp.has_point(u.pos * world.view_scale)` for same-sid player-0 units; `_set_selection()` at `:285-295`; `_pick()`/`_screen_to_world()` seam at `:533-558` |
| `variant3d/tests/t_pick3d.gd:12-16,181-239`, `t_select_rect.gd:1-46,261-283,424-440`, `TEST_S1_report.md:46-121` | Atom pattern: `extends SceneTree`, dynamic `load()`, staged `_process` (never `_initialize()`), call_deferred quit, real `main.tscn` boot with `--config` + `--screenshot` menu-skip, `Input.parse_input_event` event shape |
| `variant3d/scripts/main.gd:206,230-244,1096-1103,1156-1193,1609-1612` | Menu skip, HUD hide after `--screenshot`, `Screenshot3DViewport` (windowed only), `world.sync(dt)` each frame |
| `variant3d/scripts/data.gd:23,113-114`, `variant3d/tests/fixtures/small_map_64.json:10-15` | `TILE_M=2.0`, viewport 1280×720, fixture MAP 64×64 / render_mode 3d |
| `variant3d/tools/godot_runner.py:349-437` | Single legal Godot door; FIFO tickets, stdout/stderr spool isolation |

## Atom design (`variant3d/tests/t_view_rect_rv.gd`)

- `extends SceneTree`; dynamic `load()` for `data.gd`, `main.tscn` and
  `hud3d_adapter.gd`; all work deferred into a staged `_process()` machine;
  **`quit()` only via `call_deferred`**, never from `_initialize()`.
- Boots the real fixture: `main.tscn` instantiated with user args
  `--config <abs small_map_64.json>` and `--screenshot <temp.png>` used **only**
  as the menu-skip flag; HUD re-shown, savers/AI frozen, `speed=0`.
- Sets a known camera pose via `camera.jump_to_world(Vector2(64,64))` SIM metres
  (MAP 64² × `TILE_M` 2 m → half map = `(64,64)` m) and zeroes
  `edge_margin`/`corner_margin` so headless edge-scroll cannot drift the target.
- Clears generator entities and spawns six known units through the real
  `game.spawn()`: four peasants (one clicked at `(64,64)`, two more inside, two
  far outside) plus a pikeman inside view to exercise the sid filter.
- **Independent expectation**: reads `_cam.get_viewport_corners()` (raw CENTRED
  metres), adds exactly `Vector2(mw,mh)*TILE_M*0.5` (mirroring
  `hud3d_adapter.gd:62`), builds the AABB, multiplies by `view_scale`, and only
  then compares against `_world.view_rect` after forcing
  `_world.call("_update_view_rect")`. The expected set of "inside" units is
  derived from **this** rect, never from the consumer's answer (no circular
  assertion).
- **Input path**: `--drive input` uses `Input.parse_input_event` with two LMB
  press/release pairs at the projected pixel of unit 10, 0.064 s apart (< the
  donor's 0.5 s `KeyDoubleDelay`, `SEL-01`/`RV-SEL-01`). **No spy and no direct
  `_set_selection()` call** — the real `input_controller.gd:733-743` branch is
  exercised. A `--drive direct` fallback (calling `_unhandled_input` directly)
  exists in the atom but was **not used** in the reported jobs.
- Reads the HUD's own `hud._hud3d_adapter` (dynamically loading and binding one
  only if absent) and compares `get_minimap_box()` with a box derived from
  `world.view_rect` using the adapter's own `u=(x+halfW)/mapW` / `int()` / clamp
  / exclusive-end rules.
- Emits one `CAMRV01_JSON:` line to stdout (no extra repository file), plus
  `CAMRV01_SMOKE_OK` on green; exits `call_deferred("quit", 0/1)`.

## Exact expected vs observed values (final job, ticket 381)

Constants: `MAP_W=MAP_H=64`, `TILE_M=2.0 m`, `view_scale=16.0 px/m`,
half-map offset `Vector2(64,64) m`, camera SIM target `(64,64)` (stable before
and after clicks). Windowed 1280×720; click pixel `(640,360)`; minimap screen
rect `(1002,712,240,240)` (click not over minimap).

### 1. `view_rect` parity — PASS, exact

Raw CENTRED corners from the live camera (metres):

| Corner | Observed raw (centred) | + half `(64,64)` → SIM metres |
|---|---|---|
| TL | `(-39.03564, -41.43565)` | `(24.96436, 22.56435)` |
| TR | `(39.03564, -41.43565)` | `(103.03564, 22.56435)` |
| BR | `(23.77170, 25.23325)` | `(87.77170, 89.23325)` |
| BL | `(-23.77170, 25.23325)` | `(40.22830, 89.23325)` |

| Quantity | Expected (computed in atom) | Observed (`world.view_rect`) |
|---|---|---|
| `Rect2(x, y, w, h)` px | `(399.42981, 361.02966, 1249.14038, 1066.70227)` | `(399.42981, 361.02966, 1249.14038, 1066.70227)` |
| Non-degenerate | `w>1, h>1`, finite | PASS |
| Full-map fallback `(0,0,2048,2048)` | must NOT be used | PASS (not used) |

**Discriminating power (computed for this report, not an assertion in the
atom):** dropping CAM-02's shift would give a position of
`(-624.570, -662.974)` px; double-applying it would give
`(1423.430, 1386.034)` px. The observed `(399.430, 361.030)` is exactly the
no-shift position **+ `(1024,1024)` px = half-map `(64,64) m × 16 px/m** — one
shift, neither zero nor two. This is the numerical signature of the CAM-02 fix.

### 2. Double-click select-all-of-type — PASS

| Unit | sid | SIM pos (m) | In expected view? | Selected after double-click? |
|---:|---|---|:---:|:---:|
| 10 (clicked) | peasant | `(64, 64)` | yes | **yes** |
| 11 | peasant | `(69, 67)` | yes | **yes** |
| 12 | peasant | `(58, 61)` | yes | **yes** |
| 13 | peasant | `(119, 119)` | no | no |
| 14 | peasant | `(9, 9)` | no | no |
| 15 | pikeman | `(76, 64)` | yes | no (wrong sid) |

Expected selected ids `[10,11,12]`; observed `[10,11,12]` (exact). Multi-select
of three units proves the double-click branch ran (a single click selects only
the clicked unit). Outside units 13/14 and same-view pikeman 15 were not
selected. `last_click_sid_after_first = "peasant"`, `last_click_t = 32.092 s`,
final read `32.156 s` → double-click window `0.064 s < 0.5 s`.

### 3. Minimap box ↔ `view_rect` — PASS, exact

- `hud3d_adapter.get_minimap_box()` = `Rect2(12, 11, 40, 34)` tiles
  (inclusive `(12,11)`, exclusive end `(52,45)`).
- Box derived independently from `world.view_rect` = `Rect2(12, 11, 40, 34)`
  — all four components identical; stable before and after the clicks.

Runner stderr `SCRIPT ERROR` count = **0** for every job below.

## Runner jobs (variant runner only; Windows `python`)

| Ticket | id | Mode / drive | Result | exit | wait / run | Checks | `SCRIPT ERROR` |
|---:|---|---|---|---:|---|---|---:|
| 373 | `camrv01-smoke` | `--headless`, `input` | `failed` | 1 | 24.62 s / 25.51 s | 15/20 | 0 |
| 378 | `camrv01-smoke2` | windowed, `input` | `failed` | 1 | 0.00 s / 32.47 s | 19/20 | 0 |
| 381 | `camrv01-smoke3` | windowed, `input` | **`ok`** | **0** | 25.74 s / 37.12 s | **20/20** | **0** |

Artifacts: `variant3d/.godot_queue/results/000003{73,78,81}.json` and
`.../000003{73,78,81}_camrv01-smoke{,,3}/stdout.txt`, `stderr.txt`.

Iteration notes (no assertion was weakened; only measurement sequencing and
harness setup were corrected):

- **373 (headless)**: all `view_rect`/minimap/substance checks passed, but
  `--headless` leaves the root viewport at **64×64** while
  `unproject_position()` produced a click at `(640,640)`; `Input.parse_input_event`
  therefore delivered nothing to `_unhandled_input` (`last_click_sid` empty),
  and camera edge-scroll at mouse `(0,0)` drifted the target from `(64,64)` to
  `(63.727,63.727)`. This is precisely the "input path requires a real viewport"
  case anticipated by the task → moved to windowed, and neutralised edge-scroll
  in the atom.
- **378 (windowed)**: 19/20 — the only failure was
  `first_click_picked_intended_unit`, read **in the same frame** the release
  event was queued; `Input.parse_input_event` is delivered on the next input
  frame (final `last_click_sid` was already `"peasant"`). The assertion was
  moved to the following frame, unchanged, giving ticket 381.
- **381 (windowed)**: `status=ok`, `exit=0`, `CAMRV01_SMOKE_OK`, 20/20.

stderr in 381 contains non-script diagnostics (a pre-existing missing
`mill_rotor.png` import, plus ObjectDB/RID leaks at exit); none is a
`SCRIPT ERROR` and none is produced by this atom's assertions. No gates or
terrain ladder were run; nobody called `godot` directly.

## Verdict

**CONFIRMED** — for the live-scene, real-input scenario specified by the task:

- `world.view_rect` at a known camera pose equals the independently computed
  centred→SIM rect **exactly** (`(399.42981, 361.02966, 1249.14038,
  1066.70227)` px), is non-degenerate, and is not the full-map fallback. The
  observed value is the no-shift value plus exactly one half-map offset
  `(1024,1024)` px, ruling out both a missing and a doubled shift.
- Double-click select-all-of-type selected exactly `[10,11,12]`: all same-type
  player-0 units inside the view, none of the outside units 13/14, and no
  different-sid unit. It used real `Input.parse_input_event`, not a spy.
- `hud3d_adapter.get_minimap_box()` = `(12,11,40,34)` tiles, exactly matching
  the box derived from `world.view_rect`, before and after the clicks.
- Camera pose stayed fixed; `SCRIPT ERROR` count 0; exit 0; 20/20 checks.

The CAM-02 confidence label can be promoted from **MEDIUM-HIGH derived** to
**CONFIRMED (runtime, this scenario)**. The confirmation is scoped to the
double-click path; the drag box was not changed and was not retested here.

## Open questions

1. The axis-aligned AABB under camera **yaw** remains a **PORT APPROXIMATION**
   (V71 §6 Q5); this probe used zero yaw. A rotated-camera variant would test
   that approximation, not this half-map shift.
2. The probe ran only at one camera pose (map centre) and one viewport size
   (1280×720). The offset arithmetic is pose-independent, but a second focus
   point would add coverage cheaply.
3. Headless input remains unusable for this path because the root viewport is
   64×64 while the projection uses the configured viewport; future real-input
   atoms should run windowed (as this one did) or inject events via
   `_unhandled_input`.
4. Donor parity is still **UNVERIFIED** by construction: the donor was not
   executed (forbidden), and `RV-SEL-01` explicitly leaves the native inside-box
   predicate and double-click producer unread. This ticket confirms the port's
   internal consistency, not donor identity.
5. Whether a future `camera3d.get_viewport_corners_sim()` convenience API
   should replace the manual `+ Vector2(ox, oz)` (CAM-01 open question 2)
   remains a design choice; no API was added.

## Summary

A new `extends SceneTree` atom boots the real 64² 3D fixture, sets a known
camera pose, spawns known same-type units inside and outside the view, sends a
real double-click via `Input.parse_input_event`, and checks the shifted
`world.view_rect`, the selected set and the minimap box. Final runner ticket
**381** (`camrv01-smoke3`) is green: **20/20 checks, exit 0, `SCRIPT ERROR` 0**.
The half-map fix is **runtime-confirmed**; the required additional re-check asked
for by CAM-01/CAM-02 is complete.

**No existing file was edited by this ticket.** Only the two declared new files
were authored: `variant3d/tests/t_view_rect_rv.gd` and this report. No game
code, config, fixture, scene, shader, manifest, result JSON inside the repo, or
ATOM-REPAIR atom was touched; no direct `godot` was launched, and no full gate
or terrain ladder was run. (Concurrent swarm agents' own commits in the shared
working tree are not changes made by CAM-RV-01.)
