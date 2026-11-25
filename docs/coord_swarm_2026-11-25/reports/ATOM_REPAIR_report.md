---
task_id: ATOM-REPAIR
title: Parse-load repair of the nine new 64² test atoms
date: 2026-11-25
owner: repair builder (coordinated swarm)
status: DONE — 9/9 atoms parse and load through the variant runner
scope: variant3d/tests/{9 atom files}.gd + this report only
runner: python variant3d/tools/godot_runner.py (never direct godot; no windowed ladder; no S1/final gates)
backups: inbox/backup/<atom>.gd.bak-ATOMREPAIR (SHA-256 verified before edit)
game_code_edited: false
---

# ATOM-REPAIR — report

## Root cause

The original failure (`variant3d/.godot_queue/results/00000321_TESTRUN01-P0/stderr.txt:1-10`) was a **parse-load** failure of `t_terrain_only.gd`:

- `res_dirty`, `entities`, `res_nodes` — "already exists in parent class C3Game" (backup lines 97, 98, 101);
- `resolve_mine_sid(Dictionary) -> String` — "function signature doesn't match the parent" (backup line 115);
- `ERROR: Failed to load script ... Parse error` — no atom check ran, no result JSON, no PNG.

`C3Game` already declares those members: `res_dirty` (`variant3d/scripts/game.gd:149`), `entities` (`:82`), `res_nodes` (`:61`), and `resolve_mine_sid(sid: String, pos: Vector2) -> String` (`:2685`). The embedded fallback classes `extends C3Game` redeclared them, which GDScript rejects at reload time. The same pattern existed in `t_terrain_shore.gd`, `t_combo_trees_shore.gd`, `t_combo_shore_mines.gd`, `t_combo_all.gd`.

Once the redeclarations were removed, runner diagnostics exposed **independent parse errors** in other atoms that had been masked by their own first error:

| Error | File / backup line | Cause |
|---|---|---|
| `Cannot infer the type of "n"` | `t_terrain_shore.gd:208`, `t_combo_shore_mines.gd:241` | `CHECK_NAMES` is an untyped `Array`; `var n := CHECK_NAMES[i]` has no static type |
| `Inferred from a Variant ... (Warning treated as error)` | `t_terrain_shore.gd:882`, `t_combo_all.gd:305,575` | `_uniform_float()` (`:419`) and `_read_json()` (`:211`) return `Variant` |
| `signature doesn't match parent _process(float) -> bool` | `t_terrain_mines.gd:615` | `SceneTree._process()` returns `bool`; the atom declared `-> void` |
| `Cannot find member is_empty in base Rect2` | `t_select_rect.gd:487` | `Rect2.is_empty()` does not exist in this Godot version |
| `Cannot infer the type of "via_helper"` | `t_select_rect.gd:399` | `world_to_px()` is dynamically dispatched from `_cam` |

All were repaired as **parse/load-only** changes. No assertion, `CHECK_NAMES` entry, verdict rule, or `expected_pre_fix_failure` marker was deleted, skipped, weakened, or reordered.

## Per-file before → after

Line numbers are in the final files unless marked "(before)". All edits are file-local and annotated `ATOM-REPAIR` for audit.

| File | Before | After | Why |
|---|---|---|---|
| `t_terrain_only.gd` | `class LocalStubGame extends C3Game` declared `res_dirty`/`entities`/`res_nodes` (before :97,98,101) and `resolve_mine_sid(_res: Dictionary) -> String` (before :115) | Declarations removed; inherited C3Game fields used directly; signature now `resolve_mine_sid(_sid: String, _pos: Vector2) -> String` (`:115-117`, note `:94`) | Matches `game.gd:149,82,61,2685`; smallest change that keeps C3Game inheritance and typed-bind support |
| `t_terrain_trees.gd` | `LocalStubGame extends Node` (`:117`) with correct `resolve_mine_sid(String, Vector2)` (`:144`) | **Unchanged** | Already legal: no C3Game parent, no redeclarations |
| `t_terrain_shore.gd` | Same three redeclarations (before :116,117,120) + `resolve_mine_sid(Dictionary)` (before :134); `var n := CHECK_NAMES[i]` (:208); `var particle := _uniform_float(...)` (:882) | Declarations removed, signature fixed (`:114,134-136`); `var n: String = CHECK_NAMES[i]` (`:208`); `var particle: Variant = _uniform_float(...)` (`:882`) | Parent members inherited; explicit types remove inference errors |
| `t_terrain_mines.gd` | `func _process(_delta: float) -> void:` (before :615), bare `return` | `func _process(_delta: float) -> bool:` with `return false` on every path (`:615-624`) | Matches `SceneTree._process(float) -> bool`; never returns `true`, so no quit-side effect |
| `t_combo_trees_shore.gd` | `var res_dirty: int = 0` (before :133) inside `extends C3Game`; `resolve_mine_sid` already correct (`:148`) | Declaration removed, note at `:132` | `res_dirty` inherited from `game.gd:149` |
| `t_combo_trees_mines.gd` | `LocalStubGame extends C3Game` declares only `dump`; `resolve_mine_sid(String, Vector2)` (`:137`) | **Unchanged** | Already legal |
| `t_combo_shore_mines.gd` | Three redeclarations (before :138,139,142); `var n := CHECK_NAMES[i]` (before :241) | Declarations removed (note `:136`); `var n: String = CHECK_NAMES[i]` (`:241`) | Parent members inherited; explicit type |
| `t_combo_all.gd` | `var res_dirty: int = 0` (before :87); `var parsed := _read_json(...)` (:305); `var manifest := _read_json(...)` (:575) | Declaration removed (note `:86`); both locals annotated `Variant` (`:305,:575`) | Parent member inherited; `_read_json()` returns `Variant` (`:211`) |
| `t_select_rect.gd` | `var via_helper := _cam.world_to_px(...)` (:399); `Rect2.is_empty()` (:487) | `var via_helper: Vector2 = _cam.world_to_px(...)` (`:399`, returns `Vector2` per `camera3d.gd:267`); `not got.has_area()` (`:489`) | `has_area()` is the same replacement SEL-01 applied in `input_controller.gd:89,115`; hidden-overlay branch unchanged otherwise |

Note on the last row: SEL-01 suggested `var via_helper: bool`, but the value is used as a position (`via_helper.distance_to(_p0)` at `:400`) and `world_to_px()` returns `Vector2`, so `Vector2` is the type-preserving annotation. SEL-01's `has_area()` suggestion was adopted verbatim.

## Backups

Taken before any edit; SHA-256 of original and backup matched for all nine files:

`inbox/backup/t_terrain_only.gd.bak-ATOMREPAIR`, `t_terrain_trees.gd.bak-ATOMREPAIR`, `t_terrain_shore.gd.bak-ATOMREPAIR`, `t_terrain_mines.gd.bak-ATOMREPAIR`, `t_combo_trees_shore.gd.bak-ATOMREPAIR`, `t_combo_trees_mines.gd.bak-ATOMREPAIR`, `t_combo_shore_mines.gd.bak-ATOMREPAIR`, `t_combo_all.gd.bak-ATOMREPAIR`, `t_select_rect.gd.bak-ATOMREPAIR`.

## Parse-check job table (headless, via runner only)

Final round (all files in their final state). `SE` = total `SCRIPT ERROR` lines in that job's `stderr.txt`; `Parse` = parse-error/`Failed to load script` lines; `loaded` = script executed and printed a `RESULT` line / wrote a result JSON. Earlier diagnostic rounds: jobs 327-336 (found the first wave of errors) and 341-362 (found the second wave); both are superseded by the final round below.

| Atom | Job id | Ticket | SE | Parse | Loaded | Result / note |
|---|---|---|---:|---:|:---:|---|
| `t_terrain_only.gd` | `atomrepair-final-terrain_only` | 364 | 0 | 0 | Y | `SKIP_CAPTURE 17/17 evaluated`; result JSON written |
| `t_terrain_trees.gd` | `atomrepair-final-terrain_trees` | 365 | 1 | 0 | Y | `FAIL 21/22 evaluated`; runtime harness cast error only |
| `t_terrain_shore.gd` | `atomrepair-final-terrain_shore` | 367 | 0 | 0 | Y | `UNVERIFIED 16/26` (headless capture checks unverified); JSON written |
| `t_terrain_mines.gd` | `atomrepair-final-terrain_mines` | 368 | 1 | 0 | Y | `PASS 13/13 (HEADLESS_STRUCTURAL_ONLY__PNG_UNVERIFIED)`; runtime harness cast error only |
| `t_combo_trees_shore.gd` | `atomrepair-final-combo_trees_shore` | 369 | 1 | 0 | Y | `FAIL 22/24 evaluated`; runtime harness cast error only |
| `t_combo_trees_mines.gd` | `atomrepair-final-combo_trees_mines` | 370 | 1 | 0 | Y | `FAIL 25/28 evaluated`; runtime harness cast error only |
| `t_combo_shore_mines.gd` | `atomrepair-final-combo_shore_mines` | 372 | 0 | 0 | Y | `SKIP_CAPTURE 12/12 evaluated`; JSON written |
| `t_combo_all.gd` | `atomrepair-final-combo_all` | 374 | 0 | 0 | Y | `SKIPPED_HEADLESS FAIL 0/1` (headless abort before capture path); JSON written |
| `t_select_rect.gd` | `atomrepair-final-select_rect` | 375 | 0 | 0 | Y | `FAIL 0/1` (no `--config`/`--screenshot` args in a parse check → boot guard); JSON written |

**Parse errors are 0 for all nine files and `Failed to load script` is 0 for all nine.** Five files have `SCRIPT ERROR == 0` outright. Four have exactly one `SCRIPT ERROR` that is **runtime**, not parse: `Invalid cast: can't convert a non-object value to an object type` at `variant3d/tests/fixtures/_smallmap_harness.gd:134` in `count_categories()`. Those four still loaded and wrote result JSONs. The harness helper is outside my ownership and was not touched.

These headless rows are **parse checks only** — `SKIP_CAPTURE`/`UNVERIFIED`/`FAIL` verdicts above are not visual or S1 results. No windowed capture, P0 ladder restart, S1, or final gate was run by this agent.

## Assertions preserved

- `CHECK_NAMES` / `CAPTURE_CHECK_NAMES` arrays are byte-identical to the backups in every file.
- No `check()` call was deleted, reordered, or given a weaker predicate. The only expression change is `Rect2.is_empty()` → `not got.has_area()` in `t_select_rect.gd:489` (the hidden-overlay branch), which substitutes a method that exists in this Godot version without changing the assertion's meaning.
- `expected_pre_fix_failure` markers unchanged: `t_select_rect.gd` 3 occurrences (the overlay assertion still passes `true` at `:490-491`), `t_terrain_shore.gd` 6, `t_combo_shore_mines.gd` 0 — all equal to their backup counts.
- The `SKIP_CAPTURE` / `UNVERIFIED` / `HEADLESS_SKIP` guards remain intact; no headless run is presented as a visual PASS.

## Open questions / separate tickets

1. **Harness helper cast (blocks `SCRIPT ERROR == 0` in 4 atoms).** `count_categories()` at `variant3d/tests/fixtures/_smallmap_harness.gd:134` does `var o := n as Object` on Dictionary resource nodes, producing one runtime `SCRIPT ERROR`. Fix belongs to the harness owner (not my ownership). Atoms still load and report.
2. **`t_select_rect.gd:262` headless-only guard.** Per SEL-01, it may skip the real-input/capture path needed for S1. I did **not** change it: allowing windowed mode would change the atom's test semantics, and the follow-up forbids semantic changes. Ticket for COORD / atom author.
3. **Stretch scaling of synthetic input.** `variant3d/project.godot:18-19` uses `canvas_items`/`expand`. `Input.parse_input_event()` delivers `ev.position` verbatim (no display stretch transform), so the synthetic pixels should already be in root-viewport coordinates like `unproject_position()` output — but this cannot be confirmed without running the real-input path (out of scope: no S1/windowed ladder). If S1 shows a mismatch, file a separate ticket; I made no speculative scale transform.
4. **Pre-existing formatting ERRORs.** Several atoms print `ERROR: String formatting error: a number is required.` inside `check()` prints under headless (e.g. `t_terrain_only.gd:416`, `t_terrain_trees.gd:726`). Not a parse error, not touched here.
5. **Headless verdicts are expected to be non-green** (`FAIL`/`UNVERIFIED`/`SKIPPED_HEADLESS`); COORD will restart the capture ladder after this repair.

## Summary

- 9/9 atoms parse and load through `variant3d/tools/godot_runner.py`; parse-error count 0 and `Failed to load script` count 0 in every final job (364, 365, 367, 368, 369, 370, 372, 374, 375).
- 7 files changed minimally; `t_terrain_trees.gd` and `t_combo_trees_mines.gd` needed no change (verified by parse check).
- All backups exist and were SHA-256 verified before edit.
- **No game code was edited** — no `variant3d/scripts/**`, no harness helper, no `manifest.json`, no `app/**`, no other report. Only the nine owned atom files and this report were written.
