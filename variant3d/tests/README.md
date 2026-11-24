# Standalone test scripts (`res://tests/*.gd`)

## The rule: never call `quit()` from `_initialize()` of a `SceneTree` script

These test scripts are launched standalone with:

```
godot --headless --path app --script res://tests/<name>.gd
```

and therefore `extends SceneTree`. In Godot 4.7, calling `quit()` directly from
`_initialize()` (including indirectly, via a helper such as `_finish()` called
from `_initialize()`) does **not** stop the main loop: `_initialize()` runs
before the loop is entered, so the quit flag is lost and the process spins
forever at ~100% CPU. Six such orphaned Godot processes were found on
2026-11-21.

Fix: defer the quit so it runs after the main loop is up:

```gdscript
# BAD  -- hangs in Godot 4.7
quit(0 if ok else 1)

# GOOD -- deferred until after the loop starts
call_deferred("quit", 0 if ok else 1)
```

Equivalent alternative: restructure as a `Node` with `_ready()` and
`get_tree().quit()`.

Never "fix" this with a busy loop, `while true`, or a spin/sleep wait. Always
launch Godot through `python app\tools\godot_runner.py run --id <your-id>-<purpose>
--timeout <sec> -- <args...>` so a hang is killed by a hard timeout.

## Scripts fixed on 2026-11-21 (agentF)

All five standalone scripts in this directory had the hang pattern
(`extends SceneTree` + `quit()` reached from `_initialize()` via `_finish()`).
Each had its final `quit(0 if ok else 1)` changed to
`call_deferred("quit", 0 if ok else 1)`:

- `visual_tuning_test.gd`
- `unified_mine_test.gd`
- `mill_logic_test.gd`
- `mill_visual_test.gd`
- `building_block_test.gd`

`mill_render_test.gd` (a headless/windowed PNG render script that appeared while
this work was in progress) also had `quit()` calls inside `_initialize()`; these
were reached only after `await process_frame` / `await RenderingServer.frame_post_draw`,
so they were lower risk, but were converted to `call_deferred("quit", ...)` as
well for consistency and to eliminate the pattern entirely.

Originals are backed up under `inbox\backup\*.gd.bak-agentF`.

Re-check 2026-11-21 (agentF2): `mill_render_test.gd` was re-reviewed; its two
`quit()` calls at lines 31 and 37 are confirmed corrected to
`call_deferred("quit", 1)` / `call_deferred("quit", 0)` (backup:
`inbox\backup\mill_render_test.gd.bak-agentF2`). Grep confirms zero remaining
direct `quit()` calls under `app/tests/**`.
Also added a headless guard at the top of `_initialize()`: when
`DisplayServer.get_name() == "headless"`, the script prints a skip line and
defers `quit(0)` before creating the world, because `await process_frame` /
`await RenderingServer.frame_post_draw` do not resolve in headless mode. The
windowed PNG render path is unchanged (backup: `...bak-agentF3`).

## Small-test framework (2026-11-21) — one feature per test

The 29-step monolithic `selftest.gd` cannot be parallelised: one worker owns it
and it reports only one verdict. New features therefore get their OWN test file:

- Copy `app/tests/_template_test.gd` to `t_<feature>.gd`.
- One feature per file, one clear assertion group, no "kitchen sink" tests.
- The test writes `app/tests/results/<id>.json` with
  `{"id", "passed", "checks": [{"name","passed","detail"}]}`.
- Exit with `call_deferred("quit", 0 if passed else 1)` — never bare `quit()`.
- Render tests must add the `DisplayServer.get_name() == "headless"` guard and
  set `"windowed": true` in the manifest.
- Register the test in `app/tests/manifest.json` with a unique `id`, `path`,
  `feature`, `timeout`, and `owner`.

Run a test the normal way through the serialized runner:

```
python app\tools\godot_runner.py run --id t-upgrades --timeout 90 -- --headless --path app --script res://tests/t_upgrades.gd
```

Run the whole registry and get an aggregate report:

```
python app\tools\test_all.py --list
python app\tools\test_all.py --only t_upgrades t_squads
python app\tools\test_all.py
```

`test_all.py` writes `app/tests/results/summary.json` and never launches Godot
directly — it delegates to `godot_runner.py` (FIFO lock + hard timeout). Because
each test is a separate file, many agents can author tests at once without
conflicts; pending tests are marked `status: "pending"` until their feature lands.
