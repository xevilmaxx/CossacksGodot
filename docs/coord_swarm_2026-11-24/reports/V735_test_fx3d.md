# V7-35 — Atomic test `t_fx3d.gd` (2026-11-24)

status: **PASS — 13/13 checks, runner ticket 44 (`v735-fx3d-verified`), status `ok`, 2.56 s, stderr empty**

## Owned files (exactly two — no other edits)
- `variant3d/tests/t_fx3d.gd` (new)
- `docs/coord_swarm_2026-11-24/reports/V735_test_fx3d.md` (this report)

No module, manifest, result-JSON or 2D file was touched. `variant3d/tests/manifest.json`
stays owned by V7-38 (registration is LAST, once atomic test files exist on disk).

## Contract reference
`docs/coord_swarm_2026-11-24/V73_ATOMIC_CONTRACT.md:14,26-30,37`:
- `world3d_fx.gd` (extends Node3D) MUST expose `bind(game)`, `sync(dt)`,
  `add_fx(pos, kind, life)`, `draw_ghost(sid, pos, ok)`, `draw_rally(pos, player)`;
  event stream sim-agnostic; no 2D sprite sheets.
- Test atoms load their module dynamically via `load("res://scripts/<module>.gd")`
  (no `class_name` needed) and assert the API.
- ALL launches via `python variant3d\tools\godot_runner.py run ...`; spool
  `variant3d/.godot_queue`.

## Test design (deterministic, headless, self-exiting)
`extends SceneTree` script, TABS per contract. No random input, no wall-clock
dependence; fixed lifecycle `life=0.10 s`, `sync(0.01)` then `6 x sync(0.05)`
(`elapsed=0.31 s > life`). A minimal `MockGame extends Node` stub is bound;
`projectiles` is deliberately absent so the module's sim-agnostic trail path
must guard it. `quit()` is only ever called via `call_deferred`.

Checks, each printed as `PASS <name> - <detail>` / `FAIL <name> - <detail>`:

| # | check | final result |
|---|---|---|
| 1 | `MODULE_LOADS` | PASS — `load()` -> `GDScript` |
| 2 | `MODULE_IS_NODE3D` | PASS — instance class `Node3D` |
| 3 | `CALLABLE_BIND` | PASS — `has_method("bind")` |
| 4 | `CALLABLE_SYNC` | PASS |
| 5 | `CALLABLE_ADD_FX` | PASS |
| 6 | `CALLABLE_DRAW_GHOST` | PASS |
| 7 | `CALLABLE_DRAW_RALLY` | PASS |
| 8 | `API_SURFACE` | PASS — all 5 contract methods present |
| 9 | `FX_ADDS_NODES` | PASS — descendants 4 -> 7 at `pos=(12,34)`, `kind=smoke` |
| 10 | `FX_LIFETIME_EXPIRY_REMOVES_NODES` | PASS — `fx_items=0`, `expired 0->1`, holder queued/freed |
| 11 | `GHOST_RALLY_CALLS` | PASS — ghost + rally invoked with fixed args |
| 12 | `NO_2D_SPRITE_SHEET_LOADS` | PASS — no sheet paths / 2D nodes in source or FX tree |
| 13 | `NO_ERRORS` | PASS — no API error signals; runner stderr empty |

### MODULE_MISSING / BLOCKED behaviour
Before any instantiation the test probes `ResourceLoader.exists()` /
`FileAccess.file_exists()`, then `load() == null`, then
`Script.can_instantiate()`. Any of these prints
`FAIL MODULE_MISSING - <path> (<why>)`, then
`STATUS BLOCKED-PENDING-MODULE — world3d_fx.gd is missing/unusable; assertions NOT weakened`,
then `T_FX3D FAIL 0/1 checks`, and deferred-quits. No assertion is skipped
silently. An optional harness-only env var `T_FX3D_SIMULATE_MISSING=1`
exercises this branch without touching the module file owned by V7-15.

## Runner jobs (all via variant3d's own `godot_runner.py`)
Command for the final green run:
```
python variant3d\tools\godot_runner.py run --id v735-fx3d-verified --timeout 30 --max-wait 600 -- ^
  --headless --path variant3d --script res://tests/t_fx3d.gd
```

| ticket | job id | runner status | result |
|---|---|---|---|
| 17 | `v735-fx3d` | `timed-out` | Module landed mid-queue with parse errors; test-side guard called nonexistent `Script.is_valid()` -> runtime error + hang. Test bug, fixed. |
| 29 | `v735-fx3d-r2` | `timed-out` | Same nonexistent `is_valid()` guard. Fixed to `can_instantiate()`. |
| 33 | `v735-fx3d-r3` | `failed` | 12/13 — `FX_LIFETIME_EXPIRY_REMOVES_NODES` failed: node count stayed 7 because the module uses `queue_free()` (physical memdelete waits for a frame flush a `--script` SceneTree does not provide). |
| 37 | `v735-fx3d-final` | `failed` | 14/15 — two deferred hops still did not flush the delete queue. |
| 39 | `v735-fx3d-final2` | `ok` | **13/13 PASS**, stderr empty. Lifetime check switched to deterministic removal signals (`fx_items` empty, `stats.expired` incremented, holder `is_queued_for_deletion()`). |
| 40 | `v735-fx3d-missing` | `failed` | Test-side bug: Godot 4 renamed `OS.has_environment_variable()` to `OS.has_environment()`; fixed. |
| 43 | `v735-fx3d-missing2` | `failed` | **Intentional probe** — `FAIL MODULE_MISSING`, `STATUS BLOCKED-PENDING-MODULE`, `T_FX3D FAIL 0/1` (expected). |
| **44** | **`v735-fx3d-verified`** | **`ok`** | **FINAL: 13/13 PASS, stderr empty, 2.56 s.** |

Final evidence: `variant3d/.godot_queue/results/00000044_v735-fx3d-verified/stdout.txt`
and `/stderr.txt` (stderr is empty). Missing-path evidence:
`variant3d/.godot_queue/results/00000043_v735-fx3d-missing2/stdout.txt`.

## Honest notes / limits
- The module was absent when this agent was spawned; it landed during the first
  queue wait with parse errors (`PointLight3D` / `_fx_items`), which V7-15 fixed
  before ticket 33. The INVALID-SCRIPT branch is implemented and safe, but was
  not exercised by a clean runner after the fix; the explicitly simulated
  MODULE_MISSING branch (ticket 43) was.
- `FX_LIFETIME_EXPIRY_REMOVES_NODES` asserts Godot's documented removal state
  (`is_queued_for_deletion()`) plus logical removal from `fx_items` and the
  `expired` counter. It intentionally does NOT assert the physical node count
  drops inside `_initialize()`, because `queue_free()` deletion is flushed at a
  later frame boundary that this headless `--script` harness does not reach
  before `quit()`. This is a harness limitation, not a weakened assertion: a
  module that never frees its FX node cannot pass.
- `NO_ERRORS` is an in-process signal check (all dynamic calls routed through
  `_call_api`, which records missing methods) corroborated by the runner's
  empty stderr. GDScript offers no global error hook.
- `NO_2D_SPRITE_SHEET_LOADS` combines a static source scan (dead-weight paths
  `models/anim/**`, `sprites/**`, `sprites_hi/**`, and 2D class usage; comments
  skipped) with a runtime node-tree scan for `Sprite2D`/`AnimatedSprite2D`/
  `Node2D`. Albedo PNGs under `models/tex/**` remain allowed per the charter.
- `pos` is passed as `Vector2` map metres, matching the module's own
  `world_pos()` helper (`variant3d/scripts/world3d_fx.gd:224`) and the 2D event
  stream; no donor constant was invented.
