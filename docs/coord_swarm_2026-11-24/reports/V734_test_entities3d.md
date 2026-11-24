---
owner: V7-34
date: 2026-11-24
role: atomic test writer — world3d_entities API test atom
lane: Wave 7 phase 2 (variant3d test atoms)
output: docs/coord_swarm_2026-11-24/reports/V734_test_entities3d.md
status: BLOCKED-PENDING-MODULE
module: variant3d/scripts/world3d_entities.gd (ABSENT at verification time)
runner_job: ticket 9 (id `v734-entities3d`), status `failed`, exit 1 (expected: MODULE_MISSING)
code_edits: 2 new files only (test + this report); no manifest edit (V7-38 owns registration)
---

# V7-34 — `t_entities3d.gd`: deterministic `world3d_entities` API test atom

## 1. Scope and ownership

Exactly two new files, no other edits:

- `variant3d/tests/t_entities3d.gd` — tabs, `extends SceneTree`, self-exiting
  through `call_deferred("quit", 0 if _ok else 1)`; writes
  `variant3d/tests/results/v734_entities3d.json`.
- This report.

`variant3d/tests/manifest.json` was **not** touched: the contract assigns
registration to the manifest owner, LAST (`V73_ATOMIC_CONTRACT.md:30`).

Contract lines honoured: `:13` (module API), `:26-30` (test atom loads
`res://scripts/<module>.gd` dynamically, no `class_name`), `:37` (every Godot
launch through `variant3d/tools/godot_runner.py`). V7-2 feasibility is respected:
no bake, no donor binary execution; static meshes only, no sprite sheets.

## 2. Test design

The test resolves `res://scripts/world3d_entities.gd` at runtime:

1. `ResourceLoader.exists()` guard. If false → one check `MODULE_MISSING`
   (`passed: false`), result JSON `status: "BLOCKED"`, `reason: "MODULE_MISSING"`,
   deferred `quit(1)`. A missing module can never be misread as a pass; assertions
   are not weakened. A present-but-unloadable script takes the same path.
2. On success: `load()` must yield a `GDScript`; `script.new()` must be a `Node`
   (contract: `extends Node3D`); require exactly the API surface
   `bind`, `sync`, `add_unit`, `add_building`, `add_resource`, `remove`.
3. Bind a deterministic `StubGame` (inner `RefCounted`) whose `entities`,
   `res_nodes` and `by_id` hold three unit/building dictionaries
   (`ids 9001, 9002, 9003`; sids `peasant`, `archer`, `hou`) and two resource
   dictionaries (`ids 9004, 9005`; types `wood`, `stone`). All positions, ids and
   `dt = 0.016` are fixed literals; no randomness and no map generation.
4. Call every method through `Object.call()` (no static coupling to the module).
   Count nodes recursively before and after `add_* + sync`, then after `remove`
   of all five ids; assert growth, shrinkage, and a return to baseline.
5. Sprite-sheet check — **METHOD LABEL: structural source scan + runtime node
   scan**. GDScript cannot intercept the global `load()` / `ResourceLoader`, so
   a runtime ResourceLoader spy is NOT feasible here. Instead the module source
   is read with `FileAccess`, comments are stripped, and the code is scanned for
   `res://assets/models/anim`, `models/anim/`, `sprites_hi`, `models/sprites`,
   `Sprite2D`, `AnimatedSprite2D`, `SpriteFrames`, `AtlasTexture`,
   `AnimatedSprite3D`. The live instance subtree is also scanned for sprite
   nodes. Mesh textures under `assets/models/tex/` remain permitted (they are
   donor mesh textures, not sheets). The detail string in the result JSON
   carries this method label.

### Checks (all skipped in this run except the first)

| Check | Assertion |
|---|---|
| `MODULE_MISSING` | terminal FAIL when `res://scripts/world3d_entities.gd` is absent |
| `module_loads` | `load(MODULE_PATH)` is a non-null `GDScript` |
| `instantiates` | `script.new()` is a `Node` and is attached to the tree root |
| `api_surface` | all six contract methods exist (`has_method`) |
| `node_count_grows` | recursive node count after `add_*` + `sync` > baseline |
| `node_count_shrinks` | recursive node count after five `remove` calls < peak |
| `remove_below_baseline` | count after remove ≤ baseline |
| `no_sprite_sheet_loads` | no forbidden source pattern and no sprite node in subtree (method labelled above) |
| `no_internal_errors` | zero missing-method / guard failures recorded by the test |
| per-call `api_<method>` | dynamic calls guarded; each missing method is its own FAIL |

`quit` is always deferred (`call_deferred("quit", code)`); a result JSON is
written before quitting on every path.

## 3. Verification run (only legal launch path)

Command (from the project root):

```
python variant3d\tools\godot_runner.py run --id v734-entities3d --timeout 90 -- --headless --path variant3d --script res://tests/t_entities3d.gd
```

Runner telemetry (`variant3d/.godot_queue/results/00000009.json`):

| Field | Value |
|---|---|
| job id | **ticket 9**, id `v734-entities3d` |
| status / exit | `failed`, exit `1` (expected for `MODULE_MISSING`) |
| wait / run | 2.45 s / 4.23 s (90 s hard timeout, not reached) |
| stdout | `variant3d/.godot_queue/results/00000009_v734-entities3d/stdout.txt` |
| stderr | `variant3d/.godot_queue/results/00000009_v734-entities3d/stderr.txt` |

Stdout (complete test output):

```
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org

CHECK FAIL MODULE_MISSING :: res://scripts/world3d_entities.gd not found under --path variant3d
```

`stderr.txt` is **0 lines** → 0 Godot `ERROR:` / `SCRIPT ERROR:` lines in this
run. Result JSON (`variant3d/tests/results/v734_entities3d.json`):

```
{"id":"v734_entities3d","passed":false,"status":"BLOCKED",
 "reason":"MODULE_MISSING","internal_errors":0,
 "checks":[{"name":"MODULE_MISSING","passed":false,
            "detail":"res://scripts/world3d_entities.gd not found under --path variant3d"}]}
```

### PASS / FAIL summary

| Check | Result |
|---|---|
| `MODULE_MISSING` | **FAIL** (module absent — terminal, per task instruction) |
| all other checks | **NOT RUN** (short-circuit; assertions retained in code) |
| test harness errors | **PASS** — 0 stderr lines, clean deferred exit, result JSON written |
| overall | **BLOCKED** — test authored and verified, module not yet landed |

## 4. What unblocks and how to confirm

When the module owner lands `variant3d/scripts/world3d_entities.gd`, rerun the
identical runner command (a new ticket is expected). A real pass requires:

- `passed: true` in `v734_entities3d.json` and runner `status: ok`, exit `0`;
- node-count detail showing `before < peak` and `after ≤ before`;
- `no_sprite_sheet_loads` PASS with the method label intact;
- stderr still free of `SCRIPT ERROR` / `ERROR:` lines.

If the landed module expects additional stub fields, extend **only** `StubGame`
in `t_entities3d.gd` with deterministic values; never relax a check.

## 5. Files touched

- NEW `variant3d/tests/t_entities3d.gd`
- NEW this report
- No other file created, modified or deleted; no manifest entry added; no donor
  asset read or executed at runtime.
