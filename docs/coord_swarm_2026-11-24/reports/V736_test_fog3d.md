# V7-36 — atomic test `t_fog3d.gd` (world3d_fog)

Agent: atomic test writer V7-36. Date: 2026-11-24.

## Owned files

- `variant3d/tests/t_fog3d.gd` (new)
- `docs/coord_swarm_2026-11-24/reports/V736_test_fog3d.md` (this report)

No other source files were edited. The test itself writes its runtime result
artifact to `variant3d/tests/results/t_fog3d.json`.

## Contract exercised

`V73_ATOMIC_CONTRACT.md:15` — `world3d_fog.gd` (extends Node3D) must provide
`bind(game)`, `sync(dt)`, per-tile fog shading from `game.fog_explored` /
`fog_vis`, and expose those two arrays so the HUD minimap can read them.

The test is deterministic and self-contained: it loads
`res://scripts/world3d_fog.gd` dynamically (no `class_name`), instantiates it,
binds a small in-script `StubGame` (4x3 = 12 fog tiles, pre-filled
`PackedByteArray`s; no mapgen, sim or GPU frame), calls `sync(0.016)`, then
checks the arrays' exposed sizes and performs a structural no-Sprite2D check on
both the live node tree (recursive) and the module source (`Sprite2D.new(`).
Verdicts are printed one per check; `_finish()` writes the JSON and calls
`call_deferred("quit", ...)` (never a direct `quit()` from `_initialize()`).

`MODULE_MISSING` branch: if `ResourceLoader.exists()` is false or `load()` does
not yield a `GDScript`, the test records a single failing `MODULE_MISSING`
check, sets `status = BLOCKED`, and quits 1. This branch is present in the
final file but was **not exercised** — see the run log below.

## Runner log (variant runner only)

| Ticket | Job id | Command | Result |
|---|---|---|---|
| 10 | `v736-t-fog3d` | `python variant3d\tools\godot_runner.py run --id v736-t-fog3d --timeout 90 -- --headless --path variant3d --script res://tests/t_fog3d.gd` | `failed`, exit 1, run 8.67 s — **test-side parse error**, not a module verdict |
| 23 | `v736-t-fog3d-r2` | same with `--id v736-t-fog3d-r2` | **`ok`**, exit 0, run 3.67 s, wait 233.26 s — **PASS 9/9** |

Ticket 10 failed at script parse: four `:=` declarations inferred from untyped
`inst` (`inst.has_method(...)`, `inst.get(...)`), which Godot 4.7 rejects. Fixed
by giving those four locals explicit types (`bool`, `Variant`). Between the two
runs the module owner landed `variant3d/scripts/world3d_fog.gd`, so ticket 23
exercised the real module and the full check set rather than the BLOCKED path.

Stdout: `variant3d\.godot_queue\results\00000023_v736-t-fog3d-r2\stdout.txt`
Result: `variant3d\.godot_queue\results\00000023.json`
Test artifact: `variant3d/tests/results/t_fog3d.json` (`status: PASS`)

## Checks (ticket 23)

| Check | Result | Detail |
|---|---|---|
| `module_loads` | PASS | GDScript loaded from `res://scripts/world3d_fog.gd` |
| `instance_created` | PASS | `new()` returned a Node3D |
| `bind_api` | PASS | `has_method('bind') = true`; stub bound (12 tiles) |
| `sync_api` | PASS | `has_method('sync') = true` |
| `sync_callable` | PASS | `sync(0.016)` returned without aborting the test |
| `fog_explored_exposed` | PASS | size 12 (want 12), first byte 1 |
| `fog_vis_exposed` | PASS | size 12 (want 12), first byte 1 |
| `no_fullmap_sprite2d` | PASS | 0 Sprite2D nodes in tree; no `Sprite2D.new(` in source |
| `no_new_hangs` | PASS | 0.12 s elapsed (90 s hard timeout) |

All checks completed in 0.127 s. Godot printed benign headless shutdown RID-leak
errors for the dummy renderer (material/shader/mesh/instance); process exit code
was 0 and the runner recorded `ok`.

## Status

**PASS / unblocked.** The module satisfies the V7-36 contract surface as of
ticket 23. No edits were made to `world3d_fog.gd` or to any manifest.
