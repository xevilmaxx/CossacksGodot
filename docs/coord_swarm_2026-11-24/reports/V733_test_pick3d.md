---
agent: V7-33
role: atomic test writer (Wave 7 phase 2, t_pick3d)
date: 2026-11-24
status: BLOCKED-PENDING-MODULE
owns: "variant3d/tests/t_pick3d.gd (new) + this report only"
runner_job_id: v733-t-pick3d
runner_ticket: 15
runner_status: failed (exit 1) — EXPECTED: FAIL MODULE_MISSING
---

# V7-33 — `t_pick3d.gd` (picking3d API contract test)

## 1. Deliverable

New file: `variant3d/tests/t_pick3d.gd`. No other files touched.

The test loads `res://scripts/picking3d.gd` **dynamically** (`load()`, no
`class_name`), instantiates it, binds it to a stub game and a stub camera, and
asserts the contract from `V73_ATOMIC_CONTRACT.md` line 11:

| Check | Assertion |
|---|---|
| `module loads` | `res://scripts/picking3d.gd` exists and `load()` returns a `Script` |
| `instantiates` | `script.new()` returns a `Node`; added to `root` |
| `ground_point finite` | `ground_point(Vector2(640, 360))` is a finite `Vector2` |
| `pick returns Dictionary` | `pick(screen)` returns a `Dictionary` (may be empty) |
| `pick_res returns Dictionary` | `pick_res(screen)` returns a `Dictionary` (may be empty) |
| `no cmd_* calls` | stub game's `cmd_*` counter is zero |

The stub game defines **all 24 `cmd_*` methods** present in `variant3d/scripts/game.gd`
(`cmd_sow` … `cmd_delete`) and increments a per-method counter, so "no side
effects" is measured at runtime rather than assumed from source text.
The stub camera implements the `camera3d.gd` contract API
(`bind/view_scale/world_to_px/screen_to_world/clamp_pos/get_view_rect/get_viewport_corners/zoom_step/set_zoom_target`),
with a finite, identity `screen_to_world` so a correct `ground_point()` is
measurable in headless mode.

`extend SceneTree`; entry in `_initialize()`; writes
`res://tests/results/t_pick3d.json`; exits only via
`call_deferred("quit", 0 if _ok else 1)` — never a direct `quit()`.

## 2. Run evidence

Command (variant3d runner only):

```
python variant3d\tools\godot_runner.py run --id v733-t-pick3d --timeout 120 -- --headless --path variant3d --script res://tests/t_pick3d.gd
```

- Runner **job id**: `v733-t-pick3d`
- Runner **ticket**: `15`
- Runner result: `status=failed`, `exit=1`, `run=7.99s`, `wait=38.38s`
  (`variant3d/.godot_queue/results/00000015.json`)
- stdout/stderr: Godot 4.7.2 banner only, **zero stderr lines** — the test script
  parsed and executed cleanly; exit 1 is the intended FAIL result.
- `variant3d/tests/results/t_pick3d.json`: `passed=false`, 6 checks all false.

## 3. Blocking cause

`res://scripts/picking3d.gd` does **not exist** in the workspace at run time
(verified by directory listing: scripts present are `camera.gd`, `game.gd`,
`world3d*.gd`, etc., but no `picking3d.gd`). Per the assignment, the test
therefore emitted:

```
{"name": "module loads", "passed": false, "detail": "MODULE_MISSING"}
```

and the five remaining checks are explicitly recorded as
`NOT_RUN: MODULE_MISSING` (not silently dropped, not marked pass). The contract
assertions themselves are unchanged and will execute as soon as the owning
agent lands the module.

## 4. Status

**BLOCKED-PENDING-MODULE.** No assertion was weakened; no other agent's file
was edited. Re-run the same job id after `variant3d/scripts/picking3d.gd`
lands to convert this to a real PASS/FAIL verdict.
