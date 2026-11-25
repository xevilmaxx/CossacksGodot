---
id: INT-REGISTRY
title: "Register the 9 smallmap ladder atoms; point the registry aggregator at variant3d"
owner: INT-REGISTRY
date: 2026-11-25
status: IMPLEMENTED__REGISTRY_CHECK_ONLY__NO_GODOT_RUNS__NO_LADDER_OR_GATES
scope: "Exactly two code/config files edited (variant3d/tests/manifest.json, variant3d/tools/test_all.py) plus this report. No atom .gd, game code, harness helper, fixture or gate file touched."
owns:
  - "variant3d/tests/manifest.json"
  - "variant3d/tools/test_all.py"
  - "docs/coord_swarm_2026-11-25/reports/INT_REGISTRY_implementation.md"
labels: [REGISTRY, ADDITIVE_ONLY, VARIANT_AWARE_ROOTS, WINDOWED_ROWS, PENDING_STATUS]
evidence_labels: [observed, derived]
sources_read:
  - "docs/coord_swarm_2026-11-25/reports/TEST_01_smallmap_harness.md:134-140,210-220,257-267,307-324"
  - "docs/coord_swarm_2026-11-25/reports/TEST_HARNESS_report.md:43-64"
  - "docs/coord_swarm_2026-11-25/TEST_MATRIX.md:16-27,53-75"
  - "variant3d/tests/manifest.json (pre-edit, 252 lines / 31 entries)"
  - "variant3d/tools/test_all.py (pre-edit, 113 lines)"
  - "docs/coord_swarm_2026-11-25/SWARM_BOARD.md:66-96,112 (ATOM-REPAIR RUNNING; ladder STOPPED_AT_P0)"
---

# INT-REGISTRY — implementation report

## Goal

Register the smallmap ladder atoms produced by TEST-HARNESS / TEST-P0…P3 /
TEST-C1…C4 / TEST-S1 in the 3D variant registry, and stop the variant's
aggregator from driving the 2D `app/` project and queue
(`TEST_01_smallmap_harness.md:134-140,257-267`). Additive registry entries only;
no weakening or removal of any existing entry.

## Backups (taken before any edit)

| Original | Backup | Result |
|---|---|---|
| `variant3d/tests/manifest.json` | `inbox/backup/manifest.json.bak-INTREG` | created, 7,073 B |
| `variant3d/tools/test_all.py` | `inbox/backup/test_all.py.bak-INTREG` | created, 4,090 B |

Both verified present with `Get-Item`. No existing backup was overwritten
(these were new, uniquely suffixed files).

## Change 1 — `variant3d/tests/manifest.json`

### Before → after (counts and top-level field)

| Item | Before | After |
|---|---|---|
| `result_dir` | `app/tests/results` (line 4) | `variant3d/tests/results` |
| `tests[]` entries | 31 | 40 (31 original + 9 additive) |
| duplicate ids | none | none |
| `_smallmap_harness.gd` | absent | still absent (deliberate — see below) |

**Every one of the 31 original entries is byte-for-byte unchanged as parsed
JSON** — verified with `json.loads` and list equality against the backup:
`all original entries unchanged: True`. Only the trailing array element gained
a comma; no existing object was edited.

### Additive entries (all 9)

Each has the schema fields `id`, `path`, `feature`, `status`, `timeout`,
`owner` and `"windowed": true` (`manifest.json:6-11,187-193` pre-edit). `path`
values point only at the ATOM-REPAIR-owned files; none of those files was
opened for write.

| # | id | path | feature (short) | status | owner | timeout | windowed |
|---|---|---|---|---|---|---|---|
| 1 | `t_terrain_only` | `res://tests/t_terrain_only.gd` | 64² isolated terrain-only, no trees/shore/mines | pending | TEST-P0 | 120 | true |
| 2 | `t_terrain_trees` | `res://tests/t_terrain_trees.gd` | 64² terrain + donor trees | pending | TEST-P1 | 120 | true |
| 3 | `t_terrain_shore` | `res://tests/t_terrain_shore.gd` | 64² terrain + shore/water | pending | TEST-P2 | 120 | true |
| 4 | `t_terrain_mines` | `res://tests/t_terrain_mines.gd` | 64² terrain + mine nodes | pending | TEST-P3 | 120 | true |
| 5 | `t_combo_trees_shore` | `res://tests/t_combo_trees_shore.gd` | 64² trees + shore | pending | TEST-C1 | 120 | true |
| 6 | `t_combo_trees_mines` | `res://tests/t_combo_trees_mines.gd` | 64² trees + mines | pending | TEST-C2 | 120 | true |
| 7 | `t_combo_shore_mines` | `res://tests/t_combo_shore_mines.gd` | 64² shore + mines | pending | TEST-C3 | 120 | true |
| 8 | `t_combo_all` | `res://tests/t_combo_all.gd` | 64² trees + shore + mines (last combo) | pending | TEST-C4 | 120 | true |
| 9 | `t_select_rect` | `res://tests/t_select_rect.gd` | 64² selection rect, real game boot | pending | TEST-S1 | 120 | true |

**Why `status: "pending"`:** the schema defines `pending` as "feature not
landed yet" (`manifest.json:2`). ATOM-REPAIR is still RUNNING on all nine atoms
(`SWARM_BOARD.md:94`) and the ladder stopped at P0 on a GDScript parse error
before any JSON/PNG was produced (`TEST_RUN_01_ladder_log.md:6,53,73-75`).
Registering them as `ready` would send a default aggregator run straight into
known-broken scripts. `pending` keeps them visible to `--list` and runnable via
`--include-pending`, but out of the default ready-only selection. Flipping to
`ready` is a one-word-per-entry change for the coordinator once repair + ladder
re-run land (open question Q1).

**Why `timeout: 120`:** TEST-01 estimates 10–15 s for P0–C4 and 20–30 s for S1
(`TEST_01_smallmap_harness.md:210-221`); 120 s matches the timeout already used
by TEST-RUN-01 (`TEST_RUN_01_ladder_log.md:58`) and leaves headroom for windowed
SubViewport readback.

**Why `windowed: true` on all nine:** every row captures a PNG — P0–C4 via the
atom's own windowed SubViewport and S1 via main's `--screenshot` path
(`TEST_01_smallmap_harness.md:190-202,247-253`); 3D PNG capture is impossible
headless (`TEST_01:99-109`). `--list` and the registry itself launch nothing.

**Owner ids:** the actual authoring slots recorded in `SWARM_BOARD.md:71-79`
(TEST-P0…C4, TEST-S1), not the earlier proposed TEST-02a…TEST-04 slots in
`TEST_01:312-323`; see Q2.

## Change 2 — `variant3d/tools/test_all.py`

| Lines (pre-edit) | Before | After |
|---|---|---|
| 28 | `MANIFEST = ROOT / "app" / "tests" / "manifest.json"` | `ROOT / "variant3d" / "tests" / "manifest.json"` |
| 29 | `RESULTS = ROOT / "app" / "tests" / "results"` | `ROOT / "variant3d" / "tests" / "results"` |
| 30 | `RUNNER = ROOT / "app" / "tools" / "godot_runner.py"` | `ROOT / "variant3d" / "tools" / "godot_runner.py"` |
| 44 | `argv += ["--path", "app", "--script", ...]` | `["--path", "variant3d", ...]` |
| docstring | `python app/tools/test_all.py ...` | `python variant3d\tools\test_all.py ...` (+ one-line note that this copy drives variant3d) |

`ROOT = Path(__file__).resolve().parents[2]` is unchanged: with the file at
`variant3d/tools/test_all.py`, that still resolves to the project root.

Line 44 was **not** in the literal 27–30 range of the task, but leaving
`--path app` would still boot the 2D project after the roots were fixed — it is
the minimal companion edit needed to actually "point the aggregator at
variant3d". No other behaviour was changed: no new flags, no filtering logic,
no result schema edits. The pre-existing duplicate `--timeout` append for
windowed tests (lines 45–46) was deliberately left untouched (Q4).

## Validation — read-only registry check

Command:

```
python variant3d\tools\test_all.py --list
```

Exit code 0. Full output (40 rows; first 31 are the unchanged originals):

```
t_build_flow           ready    building placement/blocking
t_mill_logic           ready    windmill production
t_mine_unified         ready    mine income/upgrades
t_visual_tuning        ready    visual metrics
t_mill_rotor           ready    windmill rotor render
t_upgrades             ready    skirmish upgrade tree depth
t_roster_scotland      ready    Scotland + nation-unique units
t_squads               ready    squad formation/replenish/disband
t_multi_ai             ready    2+ AI opponents on one map
t_teams                ready    teams/diplomacy on random map
t_smoke_fx             ready    volley smoke/muzzle flash/arrow trails
t_water                ready    animated water/shoreline
t_weather              pending  seasons/weather/day-night
t_hud_fidelity         ready    HUD information fidelity
t_anim_metrics         ready    animation duration/metrics across roster
t_naval                ready    naval yacht sprite + hull composite
t_mass_army            ready    large army performance/corpses
t_map_variety          ready    seed variety + skirmish options
t_capture              ready    building/unit capture rules
t_audio_events         ready    audio event-to-file mapping
t_pick_res             ready    _pick_res spatial-hash harvest lookup
t_forest_dense         ready    packed forest groves (per-stamp fill + tightened scatter)
t_forest_bake          ready    static forest-detail chunk baking (draw-call reduction)
t_forest_bake_render   ready    forest bake GPU viewport readback (windowed)
t_terrain3d            ready    3D full-grid terrain ArrayMesh (normals/UV/height_at_world)
t_camera3d             ready    3D camera perspective/tilt/zoom + world<->screen mapping
t_pick3d               ready    3D pick/pick_res/ground_point with no cmd_* side effects
t_entities3d           ready    3D unit/building/resource static-mesh entities (no 2D sheets)
t_fx3d                 ready    3D FX lifetime + ghost/rally markers (no 2D sheets)
t_fog3d                ready    3D per-tile fog shading arrays for HUD minimap
t_render_mode          ready    render_mode seam: 2D default + make_world3d/make_camera3d
t_terrain_only         pending  smallmap 64x64 isolated terrain-only render (no trees/shore/mines), windowed PNG
t_terrain_trees        pending  smallmap 64x64 terrain + donor trees, windowed PNG
t_terrain_shore        pending  smallmap 64x64 terrain + shore/water transition, windowed PNG
t_terrain_mines        pending  smallmap 64x64 terrain + mine resource nodes, windowed PNG
t_combo_trees_shore    pending  smallmap 64x64 trees + shore combo, windowed PNG
t_combo_trees_mines    pending  smallmap 64x64 trees + mines combo, windowed PNG
t_combo_shore_mines    pending  smallmap 64x64 shore + mines combo, windowed PNG
t_combo_all            pending  smallmap 64x64 trees + shore + mines combo (last combo), windowed PNG
t_select_rect          pending  smallmap 64x64 selection rectangle via real game boot, windowed PNG + selection list
```

JSON/consistency checks (read-only Python, no Godot, no runner, no 2D access):

```
result_dir: variant3d/tests/results
entry counts before/after: 31 40
all original entries unchanged: True
new ids: ['t_terrain_only', 't_terrain_trees', 't_terrain_shore', 't_terrain_mines', 't_combo_trees_shore', 't_combo_trees_mines', 't_combo_shore_mines', 't_combo_all', 't_select_rect']
all new have required fields+windowed: True
helper registered: False
unique ids: True
```

`--list` only reads the manifest and prints; it does not create result files,
touch `app/`, submit a runner ticket, or launch Godot. **No smoke runner job
was submitted** (optional per task); no ladder and no full gates were run.
`git diff --no-index` against `test_all.py.bak-INTREG` confirms the Python
changes are limited to the docstring and the four path lines quoted above.

## Deliberately left unregistered

| Item | Reason |
|---|---|
| `variant3d/tests/fixtures/_smallmap_harness.gd` | Shared helper, not a test atom — no verdict, no `SceneTree` entry point, no PNG of its own (`TEST_HARNESS_report.md:43-64`). Explicit task rule: do NOT register. |
| `variant3d/tests/fixtures/small_map_32.json` (optional, not authored) | Fixture, not an atom; 64² remains the ladder map (`TEST_01:169-173,240-242`). |
| `FINAL` (selftest 29/29 + uitest 17/17 + clean) | An integration gate, not a small single-feature atom; stays with COORD and runs last (`TEST_MATRIX.md:27,65-66`). |
| Atom `.gd` files themselves | Owned by ATOM-REPAIR; only their paths were referenced, no byte was changed. |

## Open questions

1. **Q1 — status flip.** When ATOM-REPAIR lands and the ladder is re-run green,
   should the coordinator flip these nine from `pending` to `ready`? Until then,
   running them needs `--include-pending` (or `--only <id> --include-pending`),
   because `main()` filters on `status == "ready"` by default.
2. **Q2 — owner labels.** `owner` uses the real authoring slots (TEST-P0…,
   TEST-S1, `SWARM_BOARD.md:71-79`) rather than the earlier proposed TEST-02a…
   TEST-04 slots (`TEST_01:312-323`). Confirm which naming the coordinator wants
   in the long-lived registry.
3. **Q3 — timeout.** 120 s per row follows TEST-RUN-01's P0 launch; retry with
   a different value only if measured windowed captures systematically exceed it.
4. **Q4 — duplicate windowed `--timeout`.** `test_all.py:45-46` appends
   `--timeout` twice for windowed tests (pre-existing code). Left untouched as
   out of scope; flag for a separate aggregator-hardening ticket if it matters.
5. **Q5 — `result_dir` consumer.** `test_all.py` hard-codes `RESULTS` and does
   not read the manifest's `result_dir`; both now agree on
   `variant3d/tests/results`, but a future refactor could make the manifest the
   single source of truth. Not changed here.
6. **Q6 — 2D registry.** `app/tests/manifest.json` and `app/tools/test_all.py`
   were not edited; the 2D project/queue remains untouched and independently
   green before/after this ticket.

## Declaration

No Godot process was launched, no runner ticket/job was submitted (not even the
optional smoke), no ladder row or full gate was run, no donor asset was copied,
and no test result is claimed. **Only two pre-existing files were edited:**
`variant3d/tests/manifest.json` and `variant3d/tools/test_all.py`, plus the
new report file this agent owns. Two uniquely named backups were created in
`inbox/backup/`. No atom `.gd`, harness helper, fixture, game code, gate file,
or file outside the granted ownership set was modified.
