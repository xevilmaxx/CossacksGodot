---
owner: V7-52
date: 2026-11-24
mode: atomic integration builder (screen/world adapter swap ONLY)
scope: "SINGLEPLAYER SKIRMISH ONLY (D-12) — 3D picking seam in variant3d/scripts/input_controller.gd; no campaign/mission/network path, no donor binaries, no full gate"
governing_rule: "docs/coord_swarm_2026-11-24/V73_ATOMIC_CONTRACT.md:22 (replace ONLY _screen_to_world/_pick/_pick_res internals with picking3d.gd; all game.cmd_* calls untouched); :3 tabs; :4 donor path:line or UNVERIFIED"
deliverable: "variant3d/scripts/input_controller.gd (EDITED, owned) + this report ONLY"
backup: "inbox/backup/input_controller.gd.bak-V752 — Copy-Item of the pre-edit file; 42925 bytes; SHA-256 E6339592030B532D0AE84D3E47C80575E718EF74CFAA6A3478E46CAA8C9EE477 (identical to source at backup time)"
donor: "C:\Games\Cossacks 3 (private use, read-only latin-1 bytes; no donor binary run or copy). Pick itself is engine-side — UNVERIFIED per V712_picking3d.md:73-74."
toolchain: "python 3.14; Godot 4.7.2.stable via variant3d/tools/godot_runner.py (own spool variant3d/.godot_queue)"
code_edits: "1 owned file edited: 4 seam insertions, 1 public handoff method, 1 signature-relaxation, 3 explicit type guards. Zero cmd_*/hotkey/group/build-ghost/order edits."
godot_runs: "4 jobs (§4): parse FAIL (type inference — fixed), parse PASS x2, inherited uitest BLOCKED by an external main.gd parse error (no verdict obtained)."
---

# V7-52 — `input_controller.gd`: 3D picking integration seam

**Status:** implemented and parse-clean. The 3D path is dormant until V7-50's
`main.gd` calls the exposed `bind_3d(cam)` handoff (§5); with the default
`render_mode = "2d"` the inherited 2D behaviour is byte-identical. The inherited
uitest could **not** be scored: `main.gd` currently fails to parse at
`main.gd:1344` (outside my ownership) — see §4 and §7.

## 1. Method

Only the three screen↔world internals were given a 3D branch; each new branch is
guarded by `render_mode == "3d" and picking != null` and falls through to the
original 2D body line-for-line. The `picking3d` instance is created lazily by a
new public `bind_3d(cam)` and loaded dynamically (`load()`, no `class_name`),
per `V712_picking3d.md:123`.

Because every *inherited* call site computes `pw := _screen_to_world(screen)`
and then passes **`pw`** (sim metres) to `_pick`/`_pick_res`, while `picking3d`
takes **screen pixels**, the source pixel is recorded in `_pick_screen` inside
`_screen_to_world` and consumed by the two pick internals. This keeps all call
sites, signatures and command semantics untouched. All four `_pick` call sites
(`input_controller.gd:434/492/585/1089` pre-edit) and both `_pick_res` sites
(`:588/:1107`) call `_screen_to_world(screen)` immediately beforehand, so the
cached pixel is always the correct one (see §7, Q2).

## 2. Exact seam diff (`variant3d/scripts/input_controller.gd`, post-edit lines)

| # | file:line | Change | 2D impact |
|---|---|---|---|
| 1 | `:13`, `:15` | `var world: C3World` → `var world = null`; `var camera: C3Camera` → `var camera = null` — relaxed static annotations so a Node3D world / `Camera3D` can be bound (the typed-seam fix prescribed by `V71_mechanics_inventory.md:197` and `V73_ATOMIC_CONTRACT.md:21`). | none; a C3World/C3Camera still assigns and behaves identically |
| 2 | `:16-27` (new) | `render_mode: String = "2d"` (default), `picking = null`, `_pick_screen: Vector2 = Vector2.INF` + rationale comments. | none — default path is the original 2D code |
| 3 | `:66` | `bind(g: C3Game, w: C3World, h: C3HUD, cam: C3Camera)` → `bind(g: C3Game, w, h: C3HUD, cam)`. | none — same body, same assignments |
| 4 | `:106-123` (new) | Public `bind_3d(cam)`: dynamic `load("res://scripts/picking3d.gd")`, `add_child`, `picking.bind(game, cam)`, `camera = cam`, `render_mode = "3d"`; guarded `push_error` + 2D fallback if the module is missing. **This is the V7-50 handoff.** | never called in 2D |
| 5 | `:359-365`, `:548-549` | `var a`, `var b`, `var vp` changed from `:=` to explicit `: Vector2` / `: Rect2` — required because relaxed `world` members are `Variant` and Godot 4.7 refuses `:=` inference (`V71_mechanics_inventory.md:197` "guarded access"). | none — same values, same `world_to_px`/`view_rect` calls |
| 6 | `:373-380` | `_screen_to_world(p)`: new 3D branch `_pick_screen = p; return picking.ground_point(p)`. | original 2D body at `:381-386` unchanged |
| 7 | `:388-396` | `_pick(pw, players_only)`: new 3D branch `return picking.pick(_pick_screen)` (INF-guard returns `{}`). | original single-pass 2D scan unchanged from `:397` |
| 8 | `:718-725` | `_pick_res(pw)`: new 3D branch `return picking.pick_res(_pick_screen)` (INF-guard returns `{}`). | original `_pick_res_grid_ensure()` + brute-force-hash 2D body unchanged from `:726` |

**Invariants verified by diff vs backup:** all 36 inherited `game.cmd_*` call
lines are byte-identical (the only extra grep hit is my explanatory *comment*
at `:18`); no hotkey, control-group, patrol/guard/build-ghost, minimap, rally,
cursor or order block was altered; indentation is TABS throughout (0 lines with
leading spaces). No RNG, no called-symbol renames, no new `class_name`.

## 3. Backup / integrity

- Command: `Copy-Item variant3d\scripts\input_controller.gd inbox\backup\input_controller.gd.bak-V752`.
- Both files were 42925 bytes with identical SHA-256 at backup time (`E633…EE477`).
- Post-edit SHA-256 of the live file: `7413C10885FCE5DC87422673ACEA8CCDBF2A6695F21600DE3924D48764DC01465`.
- A coordinator commit (`0c4af7b3 step`) captured the edited file, which is why
  `git status --short` now shows no local modification. No other file was
  edited by me.

## 4. Verification — jobs and honest results

| Job id | Ticket | Command (via variant runner) | Result |
|---|---|---|---|
| `v7-52-input-integration-parse` | 56 | `--headless --path variant3d --check-only --script res://scripts/input_controller.gd` | **failed**, exit 1, wait 6.63 s, run 4.04 s. Three `Cannot infer the type` errors at `:359/:363/:546` caused by relaxing `world` without type guards (§2 item 5). Fixed, not left open. |
| `v7-52-input-integration-parse2` | 58 | same | **ok**, exit 0, wait 0.00 s, run 3.64 s. stdout = Godot banner only, stderr empty. `00000058.json` |
| `v7-52-input-final-parse` | 66 | same | **ok**, exit 0, run 2.93 s, stdout 75 B (banner only), stderr 0 B. Final tree state. |
| `v7-52-input-uitest` | 62 | `--headless --path variant3d --ui-test <temp>\v752_uitest_report.json` | **timed-out**, exit -9, run 182.06 s / 180 s limit. **No verdict.** Root cause is NOT this module: stderr shows `SCRIPT ERROR: Parse Error: Cannot infer the type of "idx_path" … at GDScript::reload (res://scripts/main.gd:1344)` — `var idx_path := world._anim_dir() + …` after V7-50 relaxed `main.gd`'s `world` to untyped; Godot then failed to load `main.gd` and did not exit, so the runner killed it. No report file was written. |

Notes:
- `--check-only` validates parsing/static analysis only; it does **not** execute
  runtime picking, depth ordering or the 3D scene. No runtime claim is made.
- The uitest output path was redirected to the approved temp directory
  (`…\AppData\Local\Temp\opencode\v752_uitest_report.json`) instead of the
  task-suggested tracked `variant3d/uitest.json`, to honour my exclusive
  file ownership. The tracked file was **not** touched.
- No full gate was run, per task scope.

## 5. Handoff to V7-50 (`main.gd` owner)

`main.gd` already has `render_mode := "2d"` (`:124`) and relaxed `var world` /
`var camera` (`:60-61`), but the call site has not yet been wired. Required
one-line integration after the existing `input_ctl.bind(game, world, hud, cam)`:

```
if render_mode == "3d":            # main.gd:124 (plain var, not config key)
	input_ctl.bind_3d(cam)          # cam = the Camera3D from make_camera3d()
```

- `bind_3d(cam)` accepts the **Camera3D** directly (untyped parameter), so
  V7-50 does not need to change `input_controller.gd` further.
- The 3D world must be the Node3D passed as `world` to `bind()`; it must expose
  the FULL 2D contract (`view_scale`, `view_rect`, `world_to_px`, `fx_layer`, …)
  per `V73_ATOMIC_CONTRACT.md:24`. `view_rect` should be in **sim metres**, not
  canvas px, for the inherited double-click screen test (`:551`).
- `camera` is kept pointed at the 3D cam so the unchanged zoom / minimap /
  control-group code keeps working.
- If `picking3d.gd` is absent, `bind_3d()` logs a `push_error` and leaves
  `render_mode` at `"2d"` (safe degradation, no crash).

## 6. Donor / reference evidence

| Item | Evidence | Status |
|---|---|---|
| Seam definition: replace only the three internals, keep all `game.cmd_*` calls | `V73_ATOMIC_CONTRACT.md:22`; `V712_picking3d.md:107-121` | OBSERVED (contract + handoff spec) |
| `picking3d` API `bind/pick/pick_res/ground_point`; no `cmd_*` in adapter | `variant3d/scripts/picking3d.gd:50,194,208,242`; `V73_ATOMIC_CONTRACT.md:11` | OBSERVED (module source) |
| Screen→world must go through camera; 2D inverse only for `2d` | `app/scripts/input_controller.gd:337-343`; `V712_picking3d.md:28-34` | OBSERVED (port) |
| Click unit/building/resource/ground semantics + radius + 2 m any-entity fallback | `app/scripts/input_controller.gd:345-369, 643-690`; `V712_picking3d.md:35-45,69-76` | OBSERVED intent; depth ordering is a PORT APPROXIMATION |
| Donor selection itself is engine-side | `misc.script:7-27` (`GetCountGameManagerPickedObjects` / `GetHandleGameManagerPickedObjects`) | **UNVERIFIED** per `V712_picking3d.md:73-74` — no script-readable donor pick radius or overlap-depth rule |
| Relaxed `Node` typing + guarded access for `world`/`camera` seams | `V71_mechanics_inventory.md:197,261-262`; `V73_ATOMIC_CONTRACT.md:21` | OBSERVED (design decision) |

No donor binary was run or copied. Every 3D constant remains inside
`picking3d.gd` with its own citation/UNVERIFIED label; this file adds no new
numeric constant.

## 7. Open questions / risks

1. **BLOCKER (external, V7-50):** `variant3d/scripts/main.gd:1344`
   `var idx_path := world._anim_dir() + …` fails parsing because `world` is now
   untyped. This prevents any `--ui-test` / full-scene run until V7-50 adds an
   explicit `var idx_path: String = …` (same class of fix as §2 item 5). I did
   **not** edit main.gd.
2. **Cached `_pick_screen` coupling:** correctness assumes each `_pick`/
   `_pick_res` is preceded by `_screen_to_world(screen)` with the same pixel.
   Verified for all 6 current call sites; a future caller that passes metres
   directly to `_pick` would fall back to `{}` in 3D (INF guard), not a wrong
   pick. Alternative would be deriving screen via `camera.world_to_px(pw)`,
   but that loses heightfield accuracy on relief.
3. **`players_only=false` approximation:** `picking3d.pick()` applies the
   player-0 radius test plus a 2 m any-entity fallback for *all* call sites.
   This follows `V712_picking3d.md:115-117` ("do not alter the surrounding
   `cmd_*` calls"), but enemies beyond ~2 m from the cursor are not picked at
   full entity radius as in 2D. Acceptable because clicks/hovers land on the
   entity; confirm against the 50-case click→selection acceptance set.
4. **World offset / depth ordering:** inherited from `V712_picking3d.md:126-135`
   — flat-plane calibration and screen-distance-primary depth tie-break remain
   UNVERIFIED at runtime; `t_pick3d.gd` (separate atom) owns that verdict.
5. **Uitest re-run:** once Q1 is fixed by V7-50, re-run
   `v7-52-input-uitest` (ideally with `--timeout 300`) to confirm the 2D default
   path still passes end-to-end. No verdict is claimed here.
6. **Patrol overlay / double-click:** `_draw_patrol_route` and the double-click
   screen test still call `world.world_to_px`/`view_rect`; their 3D units must
   be settled by the `world3d.gd` integration owner (`V71:262` flags this as
   already ambiguous in 2D).
7. **Duplicate adapter ownership:** `main.gd:125` declares `var picker3d = null`
   (unused at this snapshot). `bind_3d(cam)` creates its own `picking3d` child,
   so if V7-50 also instantiates `picker3d` there will be two adapters. Harmless
   but wasteful; V7-50 should either leave its `picker3d` unused or tell me to
   add an optional adapter parameter to `bind_3d(cam, adapter = null)` so theirs
   is reused. No duplicate exists today because the 3D branch is not wired yet.

## 8. Files owned / touched

- EDITED: `variant3d/scripts/input_controller.gd` (only).
- CREATED: `docs/coord_swarm_2026-11-24/reports/V752_input_integration.md` (this file).
- CREATED (backup, as instructed): `inbox/backup/input_controller.gd.bak-V752`.
- NOT touched: `variant3d/scripts/main.gd` (V7-50), `picking3d.gd` (V7-12),
  `variant3d/uitest.json` (tracked; report redirected to temp), any test or
  manifest file.
