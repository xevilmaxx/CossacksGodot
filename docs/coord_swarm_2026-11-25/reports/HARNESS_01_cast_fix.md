---
task_id: HARNESS-01
title: Fix the shared 64² harness helper's runtime cast error in count_categories()
date: 2026-11-25
owner: repair builder (coordinated swarm)
status: DONE — smoke job 384 has SCRIPT ERROR == 0
scope: variant3d/tests/fixtures/_smallmap_harness.gd + this report only
runner: python variant3d/tools/godot_runner.py (never direct godot; no windowed ladder; no S1/final gates)
backup: inbox/backup/_smallmap_harness.gd.bak-HARNESS01 (SHA-256 verified before edit)
atom_or_game_code_edited: false
---

# HARNESS-01 — report

## Root cause

Four of the nine final ATOM-REPAIR jobs (365, 368, 369, 370) reported exactly one **runtime** `SCRIPT ERROR` each:

- `stderr.txt:5-9` of `00000365_atomrepair-final-terrain_trees`: `SCRIPT ERROR: Invalid cast: can't convert a non-object value to an object type.` at `count_categories (res://tests/fixtures/_smallmap_harness.gd:134)`, called from `_initialize (res://tests/t_terrain_trees.gd:737)`.
- `stderr.txt:22-27` of `00000369_atomrepair-final-combo_trees_shore`: the same error at the same helper line, called from `_count_categories (res://tests/t_combo_trees_shore.gd:405)`.

`variant3d/tests/fixtures/_smallmap_harness.gd:134` (before) read:

```gdscript
var d := n as Dictionary; var o := n as Object
var t := str(d.get("type", "")) if d != null else (str(o.get("type")) if o != null else "")
```

The cast `n as Object` runs **unconditionally** for every element. The atoms pass an `Array` of **Dictionaries** as `res_nodes` — e.g. `t_terrain_trees.gd:398-408` builds each node with `var node := { "id": ..., "kind": "res", "type": "wood", ... }` and appends it to `_tree_nodes`, which is handed to `helper.call("count_categories", _tree_nodes)` at `:737`. A Dictionary is a non-object Variant, so `as Object` raises "can't convert a non-object value to an object type" on every iteration. The preceding `n as Dictionary` succeeds but does not prevent the second cast from executing; the expression on `:135` never gets a chance to pick the Dictionary branch.

This is a helper defect, not an atom defect: the atoms supply a valid `Array` of resource Dictionaries, and the helper already uses the correct guarded pattern in `StubGame._rn` at `:38-41` (`if n is Dictionary: ... elif n is Object: ...`) in the same file. ATOM-REPAIR reported this as its open question 1 (`ATOM_REPAIR_report.md:90`).

## Before → after

File: `variant3d/tests/fixtures/_smallmap_harness.gd`, function `count_categories` (`:131-141`). Only the element-inspection lines changed; the accumulator, `match` categories, and all five public APIs (`make_stub_game`, `count_categories`, `write_result`, `make_height`, `make_tileblock`) are untouched.

Before (`:133-135`):

```gdscript
	for n in res_nodes:
		var d := n as Dictionary; var o := n as Object
		var t := str(d.get("type", "")) if d != null else (str(o.get("type")) if o != null else "")
```

After (`:133-139`), with `is` guards mirroring `_rn` at `:38-41`:

```gdscript
	for n in res_nodes:
		# HARNESS-01: `as Object` on a Dictionary (the atoms' res_nodes shape)
		# is an invalid cast at runtime. Guard casts with `is`, as _rn does (:38-41).
		var t := ""
		if n is Dictionary:
			t = str((n as Dictionary).get("type", ""))
		elif n is Object:
			t = str((n as Object).get("type"))
```

Semantics are preserved exactly: Dictionary elements read `get("type", "")` → `str()`, Object elements read `get("type")` → `str()`, every other element type yields `""` (and matches no category). No category rule, count, or signature changed. No assertion in any atom was deleted, skipped, reordered, or weakened.

## Backup

`inbox/backup/_smallmap_harness.gd.bak-HARNESS01` was copied from the original before the edit. SHA-256 of original and backup matched:

`9EBC563D6D073E74155C83B1B08A28BA5638F80821FEC91D6E082F6E462A31EE`

A `git diff --no-index` of backup vs. edited file shows only the `count_categories` hunk above.

## Validation (runner only)

| Job | Ticket | Result | `SCRIPT ERROR` in stderr | `Invalid cast` | Note |
|---|---:|---|---:|---:|---|
| `harness01-smoke` | 384 | `failed` (exit 1, run 18.39 s) | **0** | **0** | Headless parse/smoke run of `res://tests/t_terrain_trees.gd` |

Command (Windows `python`, not `python3`):

```
python variant3d/tools/godot_runner.py run --id harness01-smoke --timeout 180 -- --headless --path variant3d --script res://tests/t_terrain_trees.gd
```

Artifacts:

- `variant3d/.godot_queue/results/00000384_harness01-smoke/stderr.txt`
- `variant3d/.godot_queue/results/00000384_harness01-smoke/stdout.txt`
- `variant3d/.godot_queue/results/00000384.json`

The runner's non-zero exit is the atom's own headless verdict (`RESULT: FAIL 21/22 evaluated, 10 skipped/noted`, same 21/22 as job 365), not a script error. Pre-existing, unrelated stderr lines remain (a string-formatting `ERROR` at `t_terrain_trees.gd:726`, world3d_entities PORT-APPROXIMATION warning, headless camera-not-in-tree `ERROR`s, and a 3-instance ObjectDB leak warning); none is a `SCRIPT ERROR`. No windowed ladder, no S1, no full gates, and no direct `godot` invocation were run.

## Scope statement

**No atom file, no game code, no manifest, and no other report was edited.** The only files written by this task are `variant3d/tests/fixtures/_smallmap_harness.gd` and this report; the backup was created in `inbox/backup/` as instructed. The error was in the shared helper's own cast, not in an atom's call site, so no atom ownership boundary was crossed.

## Open questions / separate tickets

1. The other three atoms that previously showed the same cast error (`t_terrain_mines` job 368, `t_combo_trees_shore` job 369, `t_combo_trees_mines` job 370) were not individually re-smoked here; the fix is generic (all pass `Array`-of-Dictionary `res_nodes`) and the smoke proves the helper no longer casts those elements to `Object`. COORD may re-run them on the ladder.
2. `t_terrain_trees.gd:726` still prints `ERROR: String formatting error: a number is required.` under headless (ATOM-REPAIR open question 4); unrelated to this fix and outside this ownership.
3. Headless verdicts remain non-green by design (`FAIL`/`SKIP_CAPTURE_HEADLESS`/`KNOWN_GAP`/`NOT_ASSERTED`); this smoke is not a visual PASS. COORD should restart the capture ladder separately.

## Summary

- Root cause: unconditional `n as Object` on Dictionary elements in `_smallmap_harness.gd:134`.
- Fix: `is`-guarded Dictionary/Object extraction in `count_categories()`; no API or semantic change.
- Backup created and SHA-256 verified.
- Smoke job `harness01-smoke`, ticket 384: `SCRIPT ERROR == 0`, `Invalid cast == 0`.
- No atom, game file, or manifest was edited.
