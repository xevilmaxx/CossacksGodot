---
id: TEST-01
title: "Smallest-map isolated/combo test harness for 3D terrain + selection — design only"
owner: TEST-01
date: 2026-11-25
status: DESIGN__READ_ONLY__NO_GODOT_RUNS__NO_CODE_EDITS
scope: "Read-only recon + design. No source, config, manifest, test, gate-file or git edits; no Godot jobs submitted."
owns:
  - "docs/coord_swarm_2026-11-25/reports/TEST_01_smallmap_harness.md"
labels: [SMALLEST_MAP, ISOLATED_FIRST, COMBO_LADDER, RUNNER_SERIALIZED, WINDOWED_CAPTURE]
evidence_labels: [observed, derived, inferred]
matrix: "docs/coord_swarm_2026-11-25/TEST_MATRIX.md:11-33"
---

# TEST-01 — smallest-map isolated/combo harness design

## Goal

Design (not build) the smallest-map harness that can test the wave-7 3D port one
piece at a time — terrain alone, then terrain+trees, terrain+shore, terrain+mines,
then pair/triple/quad combos, then a selection-rectangle case — and only **at the
very end** run the whole variant gate. Every row must sit on the *same* smallest
map so a difference between rows is attributable to the one added piece
(`TEST_MATRIX.md:11-12`). This report gives concrete atom designs, capture paths,
pass/fail criteria, time estimates, blockers, and ownership, all with `path:line`
citations. No Godot was run and no code was changed.

## Sources

| Source | Used for |
|---|---|
| `variant3d/tests/README.md:3-33,67-99` | quit rule, one-feature-per-file convention, result JSON shape, runner command |
| `variant3d/tests/manifest.json:2-11,196-249` | registry fields, existing terrain/pick/render atoms |
| `variant3d/tests/t_terrain3d.gd:18-26,41-46,106-127,161-255` | stub-game + dynamic `load()` atom pattern |
| `variant3d/tests/t_pick3d.gd:12-16,53-71,151-179,181-239` | stub game/camera, no-`cmd_*` assertion pattern |
| `variant3d/tests/t_render_mode.gd:1-10,63-126` | source-inspection atom pattern, `BLOCKED-PENDING-INTEGRATION` result field |
| `variant3d/scripts/testbridge.gd:99-105,277-308` | `shot` / `wait` / `resize`, real viewport PNG readback |
| `variant3d/scripts/terrain3d_sandbox.gd:6-21,50-64,81-83,139-151,227` | old windowed terrain capture precedent (with stale hooks — see Blockers) |
| `variant3d/scripts/heightmap3d_sandbox.gd:1-6` | probe that `Node3D --script` was accepted |
| `docs/coord_swarm_2026-11-24/reports/TERRAIN_SMALL_maps.md:31-41,43-66,72-97,101-121,130-148,192-211` | measured 64² fixture/probe/capture anchors and their limits |
| `docs/coord_swarm_2026-11-24/reports/T03_test_cost_deps.md:12-32,114-149` | startup cost anchors, why subsets are slow |
| `docs/coord_swarm_2026-11-24/reports/T01_selftest_taxonomy.md:148-172` | no-weakening / union-of-steps rules for the final gate |
| `docs/coord_swarm_2026-11-24/reports/W26_test_speed.md:13-32,134-201,229-244` | measured full-gate wall, per-step timing, snapshot limitation |
| `docs/COMMANDS.md:3-61,97-100,103-134,240-242` | runner monopoly, queue rules, screenshot flags, one-heavy-job rule |
| `docs/variant3d/README.md:129-158` | variant runner + `--script res://tests/<atom>.gd` launch form |
| `variant3d/tools/godot_runner.py:46-57,115-129,305-343,349-437,571-576` | FIFO ticket lock, hard timeout, result directories |
| `variant3d/tools/test_all.py:27-30` | registry aggregator (stale `app/` paths) |
| `variant3d/tools/smallmap_capture.py:21-39,50-58` | read-only PNG metrics + stderr `SCRIPT ERROR` scan |
| `variant3d/scripts/config.gd:70-94,226-255,376,405-406` | defaults, overlay merge, window size, min-map clamp |
| `variant3d/scripts/data.gd:23,33-35,61,113-115` | `TILE_M`, map/seed defaults, render mode, window dimensions |
| `variant3d/scripts/main.gd:27,68-71,178-182,230-244,977-996,1034-1110,1156-1193,1202-1209,1278-1307,1319-1321,1662-1672,1789-1870` | arg parsing, test-mode boot, capture viewport, screenshot save |
| `variant3d/scripts/game.gd:94-96,306-315,355-412,983-1022,1145-1178,2314-2330` | generation stages; no per-category disable flags |
| `variant3d/scripts/world3d.gd:126,599-677,795-796` | module bind/build, `sel_rect`, no 3D forest bake |
| `variant3d/scripts/world3d_terrain.gd:624-764,841-844` | one-mesh terrain build + water module |
| `variant3d/scripts/world3d_entities.gd:1269-1315` | res-node → donor sid/mesh mapping |
| `variant3d/scripts/input_controller.gd:207-217,455-468,610-647,1166-1169` | selection write, 3D screen→world, drag-rect logic |
| `variant3d/scripts/camera3d.gd:258-275` | 3D world↔screen mapping used to place a synthetic drag |
| `docs/coord_swarm_2026-11-24/reports/V770_viewport_capture.md:29-35`, `V731_test_terrain3d.md:19-25,60-72` | measured capture mechanics and atom run times |

## Current harness facts (observed, with citations)

1. **Observed — one atom = one file, one verdict.** The small-test convention is
   "copy `_template_test.gd` to `t_<feature>.gd`", one assertion group per file,
   result at `res://tests/results/<id>.json`, exit with
   `call_deferred("quit", 0 if passed else 1)`
   (`variant3d/tests/README.md:67-80`; template at
   `variant3d/tests/_template_test.gd:1-38`). Atoms are `extends SceneTree`:
   `--script` needs a `MainLoop`, and a bare `quit()` from `_initialize()` hangs
   Godot 4.7 (`variant3d/tests/README.md:3-33`; `t_terrain3d.gd:12-14`).
2. **Observed — registration is a JSON entry.** Each entry carries `id`, `path`,
   `feature`, `status`, `timeout`, optional `owner` and `windowed`
   (`variant3d/tests/manifest.json:6-11,42-49,187-193`). Existing terrain/pick/
   render atoms are registered at `manifest.json:196-249`.
3. **Observed — launch form.** `python variant3d\tools\godot_runner.py run --id
   <ticket>-<row> --timeout <s> -- --headless --path variant3d --script
   res://tests/<atom>.gd` (`docs/variant3d/README.md:146-153`;
   `variant3d/tests/README.md:82-86`). User args go after a second `--`, e.g.
   `-- --config <abs fixture> --screenshot <abs png>` (`TERRAIN_SMALL_maps.md:57-66`;
   `t_smallmap_terrain.gd:14-16`). Windows `python`, never `python3` (`TEST_MATRIX.md:31`).
4. **Observed — the runner is a strict FIFO with a hard kill.** One Godot at a
   time, tickets increase monotonically, lock is `O_EXCL`, jobs are killed by
   `taskkill /T /F` at `--timeout`, each job has its own stdout/stderr directory
   (`variant3d/tools/godot_runner.py:46-57,115-129,305-343,349-437`;
   `docs/COMMANDS.md:11-41`). Therefore the ladder is necessarily **sequential**;
   no two rows may be launched concurrently, and each atom must self-exit.
5. **Observed — result collection is split.** Atom JSON goes to
   `res://tests/results` (`_template_test.gd:6,17-31`), while runner logs go to
   `variant3d/.godot_queue/results/<ticket>_<id>/`
   (`godot_runner.py:357-374`). GDScript cannot read stderr, so `SCRIPT ERROR`
   absence is checked externally with `python variant3d\tools\smallmap_capture.py
   scan-stderr <stderr.txt>` (`smallmap_capture.py:50-58`;
   `TERRAIN_SMALL_maps.md:94-97`).
6. **Observed — a real-game tiny-map probe already exists.**
   `t_smallmap_terrain.gd` boots `res://scenes/main.tscn`, reads `--config`, skips
   the menu with `--screenshot`, inspects on the first `_process()` (not
   `_initialize()`), and checks 21 structural terrain facts at 64²
   (`t_smallmap_terrain.gd:9-16,174-231,234-416`; `TERRAIN_SMALL_maps.md:31-41,
   72-97,101-121`). Its stderr guard is `call_deferred("quit", ...)` (`:85`).
7. **Observed — 3D PNG capture is windowed-only.** `--screenshot` sets a flag
   (`main.gd:1202-1205`), skips the menu (`:230-244`); in headless mode the
   screenshot branch draws an 800×600 **CPU map**, not 3D (`:1790-1800`), and
   `_setup_screenshot_window()` returns immediately (`:1156-1158`). In windowed
   3D mode a dedicated `Screenshot3DViewport` SubViewport at
   `Data.WINDOW_WIDTH×Data.WINDOW_HEIGHT` is created, world+camera are reparented
   into it, and `UPDATE_ONCE` + `frame_post_draw` is read back (`:1180-1193`,
   `:1804-1862`). A blank 3D capture is a loud failure, never a CPU fallback
   (`:1846-1853`). Confirmed by the measured V7-70 capture
   (`V770_viewport_capture.md:29-35`) and the 64² capture
   (`TERRAIN_SMALL_maps.md:130-148`).
8. **Observed — `--screenshot` hides the HUD** (`main.gd:1096-1097`) and main
   itself saves the PNG + `.raw.png` and quits at `frame >= screenshot_frames`
   (`:1662-1672`, `:1821-1825`, `:1319-1321`). `--screenshot-frames` is clamped
   to ≥10 (`:1206-1209`).
9. **Observed — generation has no per-category off switch.**
   `game.setup()` always runs `_gen_base → _gen_patterns → _gen_forests →
   _gen_resources → _gen_finish → _assign_tileblocks → setup_spawns`
   (`game.gd:306-315`), with staged RNG (`:94-96`, `:209-211`). Forests, mines,
   shore and starts are all stamped in those passes (`:983-1022`, `:1145-1178`,
   `:2314-2330`). There is no `no_trees` / `no_water` / `no_mines` config key in
   the gameplay defaults (`config.gd:70-94`). Isolation must therefore come from
   a purpose-built fixture/stub or from post-setup pruning — not from a flag.
10. **Observed — 3D selection is structural, not a drawn marquee.** Left-drag
    over 6 px converts a screen rect to world metres and selects all
    `player == 0 && kind == "unit"` entities whose `pos` lies in it
    (`input_controller.gd:610-647`, `:662-663`); the rect is written to
    `world.sel_rect` (`:1166-1169`, `world3d.gd:126`). `world3d_fx.gd` has **no**
    `sel_rect`/`sel_active` consumer (grep: 0 hits), so a PNG cannot be expected
    to contain the marquee itself — only the selected-unit aura from the FX
    selection sync (`world3d.gd:685-686`). The 3D screen↔world mapping is
    `camera3d.gd:258-275`; `_screen_to_world` routes to picking3d in 3D
    (`input_controller.gd:455-468`). The existing `select_box` UI scene only
    calls `_set_selection()` directly (`uitest.gd:115-122`), so it is **not** a
    drag-rectangle test.
11. **Observed — the registry aggregator is stale for variant3d.**
    `manifest.json:4` says `"result_dir": "app/tests/results"`, and
    `variant3d/tools/test_all.py:27-30` hard-codes `ROOT/app/...` for manifest,
    results and runner. Running it from this project would drive the **2D**
    project/queue, not the 3D variant. Registration/launch must be done by hand
    through `variant3d/tools/godot_runner.py` until an integration ticket fixes
    those paths.

## Smallest-map determination

- **Observed — hard floor is 16×16 tiles.** `config.gd:405-406` applies
  `maxi(16, …)` to both `gameplay.map_width_tiles` and `map_height_tiles`;
  canonical is 320² (`config.gd:72-73`), defaults in `data.gd:33-34` are 160².
  `TILE_M = 2.0` (`data.gd:23`), so the floor is 32 m × 32 m.
- **Observed — smallest actually *proven* representation is 64×64.** The
  committed fixtures are 64² and 128² (`tests/fixtures/small_map_64.json:10-15`,
  `small_map_128.json:10-15`); the 64² probe measured 4,096 vertices, 7,938
  triangles, 4,096 UV2 entries, one surface, atlas `(16,8)`, shadow OFF and one
  water plane, 21/21 PASS, 15.35 s (`TERRAIN_SMALL_maps.md:101-121`); its windowed
  capture was 1,280×720, 1,705,282 B, 21.29 s (`:130-148`). 128² is
  `READY_NOT_RUN` (`:123-128`).
- **Derived — the probe's 16-tile acceptance is a harness restriction, not an
  engine limit.** `t_smallmap_terrain.gd:202-211` rejects `_want < 16` and then
  checks `_want == 64 or _want == 128`; a 16² or 32² fixture would be accepted by
  `config.gd` but failed by this probe, so a new atom is required to explore it.
- **Inferred — 16²/32² are likely degenerate for the *full* generator**, even
  though terrain geometry is well-defined at any `w,h ≥ 2`. The generator keeps
  fixed metre-scale clearances: 7-tile start keep-clear (`game.gd:734-739`),
  14–22-tile forest cores (`:717-723`), 16-tile final start keep-clear
  (`:331-339`), 18-tile minimum separation between starts (`:2323-2329`), and a
  provision ring out to 24 tiles (`:2365`). On a 32 m × 32 m (16²) map those
  radii cover the whole map, so trees/ores/starts would be suppressed or
  clipped. 64² (128 m × 128 m) is the smallest size with room for at least two
  separated starts and non-degenerate stamping, and it is the only size with a
  measured end-to-end capture.
- **Recommendation (derived):** use **64×64 / 4,096 cells** as the single ladder
  map (`tests/fixtures/small_map_64.json`, inherited seed `20261113`,
  `render_mode=3d`, everything else canonical). Optionally author a *new*
  `small_map_32.json` as an exploratory `READY_NOT_RUN` fixture, but never mix
  map sizes within one ladder — `TEST_MATRIX.md:12` requires a common map.
- **Observed — screenshot resolution has no CLI flag.** Window size comes from
  `display.window_width/height` via `config.gd:376` → `data.gd:113-115`
  (1,280×720), and the 3D SubViewport copies those values (`main.gd:1184`).
  `--screenshot-frames` only changes the frame count (`:1206-1209`). The only
  other resize mechanisms are the test bridge `resize` command
  (`testbridge.gd:103-105`) — explicitly unsafe mid-run (`COMMANDS.md:123-124`) —
  or an atom setting `get_window().size` before boot (`terrain3d_sandbox.gd:51`).
  Headless always yields an 800×600 CPU map (`main.gd:1792`), never a 3D PNG.

## Test ladder (one new atom per row, same 64² map)

Common capture path prefix (absolute, outside repo):
`C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/test01_smallmap/`.
All rows use the form
`python variant3d\tools\godot_runner.py run --id TEST-01-<row> --timeout <T> -- --path variant3d [--headless] --script res://tests/<atom>.gd -- <user args...>`
(the double-`--` user-arg form is proven in `TERRAIN_SMALL_maps.md:57-66`).
**Derived — two capture variants must not be mixed:**

- **P0–C4 (stub rows):** `--script` does *not* load `main.tscn` for us; the atom
  constructs the stub game/terrain/camera itself. Therefore main's `--screenshot`
  saver is unavailable: the atom must create its own windowed `SubViewport`,
  `await RenderingServer.frame_post_draw`, read `get_texture().get_image()` and
  `save_png()` (`terrain3d_sandbox.gd:139-151`, `testbridge.gd:277-308`). Launch
  these **windowed** (no `--headless`) and pass the PNG path as a user arg.
- **S1 (real-boot row):** the atom instantiates `res://scenes/main.tscn`
  (`t_smallmap_terrain.gd:214-219`) and passes `--config <abs>\small_map_64.json
  --screenshot <abs>\smallmap64_select_rect.png --screenshot-frames 10`; main
  then creates `Screenshot3DViewport` and saves/quits itself
  (`main.gd:230-244,1180-1193,1662-1672,1821-1825`).

Each headless-only variant drops `--screenshot`, uses `--headless`, and writes
state JSON only. Time estimates are **derived** from measured anchors: 8.91 s
stub atom (`V731_test_terrain3d.md:70-72`), 15.35 s 64² headless boot, 21.29 s
64² windowed capture (`TERRAIN_SMALL_maps.md:101,130`); they exclude FIFO wait,
which can be minutes (`V731_test_terrain3d.md:71` records a 228.18 s wait).

| Row / atom | Sets up | Captures | Measures (derived unless noted) | Pass / fail | Est. runner time |
|---|---|---|---|---|---|
| **P0** `t_terrain_only.gd` | Stub game with 64² flat/mild height + all-grass tileblock, **empty** `res_nodes`, no water cells (pattern from `t_terrain3d.gd:106-127`); bind only `world3d_terrain.gd` and camera; windowed, optionally hide `WaterPlane` as in `terrain3d_sandbox.gd:120-124` | `smallmap64_terrain_only.png` (stub-owned viewport; no `.raw.png` unless main boot is used) | surfaces=1, vertices=4,096, tris=7,938, UV2=4,096, UV2.y∈{0,1,2}, flat-grid promoted=0 (`t_smallmap_terrain.gd:284-339`), `res_nodes=0`, zero cells below water level; PNG non-black >0.9 and 0 full-width dark rows (`smallmap_capture.py:21-39`) | All structural checks true **and** second-agent look for no checkerboard/seam/art band. Visual parity is **not** claimed (`TEST_MATRIX.md:34`; `TERRAIN_SMALL_maps.md:24-29`) | 10–15 s |
| **P1** `t_terrain_trees.gd` | Same P0 stub + N=~20 `wood` resource nodes at known positions, fed through `world3d_entities.add_resource()` (`world3d_entities.gd:1269-1315`) | `smallmap64_terrain_trees.png` | P0 mesh invariants unchanged; `Batch_*_res` tree instances == N; no stone/ore/stump categories; PNG differs from P0 outside the ground-only mask | Tree count and category purity exact; P0 mesh counts unchanged; visual density/scale reviewed by second agent | 10–15 s |
| **P2** `t_terrain_shore.gd` | Same P0 stub + a bounded water basin in the height grid (cells below `WATER_LEVEL`, `world3d_terrain.gd:801`) and a sand/rock collar | `smallmap64_terrain_shore.png` | water-cell count >0 and <10 % of grid; one `WaterPlane`; height-aware water true (`t_smallmap_terrain.gd:400-414`); mesh still 4,096 verts; PNG has **0** full-width dark rows (localized band only, `smallmap_capture.py:27-28`) | Water present, mesh invariant, no full-width streak; shore mask reviewed visually | 10–15 s |
| **P3** `t_terrain_mines.gd` | Same P0 stub + gold/iron/coal resource nodes at known positions (`_resource_sid` returns `mine_<ty>`, `world3d_entities.gd:1269-1277`) | `smallmap64_terrain_mines.png` | ore instances per type == N; `wood`/`stone`/`food` counts == 0; no water cells; P0 mesh invariants unchanged | Category purity + exact counts; asset scale/jitter by second agent | 10–15 s |
| **C1** `t_combo_trees_shore.gd` | P1 + P2 union | `smallmap64_combo_trees_shore.png` | tree count, water-cell count, single surface, both P1/P2 invariants simultaneously | No regression vs either parent; trees never below water level | 10–15 s |
| **C2** `t_combo_trees_mines.gd` | P1 + P3 union | `smallmap64_combo_trees_mines.png` | tree + ore counts; no water; check ore/tree separation (generator uses 8.5–10.5 m clear rings, `game.gd:2341-2357`) | Both counts correct; no overlap (derived from stub positions) | 10–15 s |
| **C3** `t_combo_shore_mines.gd` | P2 + P3 union | `smallmap64_combo_shore_mines.png` | water cells + ore counts; every ore position has `height > WATER_LEVEL`; one water plane | Mines not in water; shore masking unchanged | 10–15 s |
| **C4** `t_combo_all.gd` | P1 + P2 + P3 union (still stub-based, still no units/buildings) | `smallmap64_combo_all.png` | all parent invariants at once; this is the *last* combination row | All parent checks pass; this is the only combo that may feed the final visual review | 10–15 s |
| **S1** `t_select_rect.gd` | **Real** 64² game boot via `main.tscn` + fixture (needed for input/HUD); spawn N=8 player-0 units at known positions, synthesize `InputEventMouseButton` press + `InputEventMouseMotion` >6 px + release using `camera3d.world_to_px()` (`testbridge.gd:129-142` event pattern; `input_controller.gd:610-647`) | `smallmap64_select_rect.png` (+ selection list JSON) | `selected_ids` exactly the units inside the synthetic rect; outside units unselected; `cmd_*` call counter == 0 (`t_pick3d.gd:234-236`); no terrain mesh change; re-show `hud.visible = true` after boot because `--screenshot` hides it (`main.gd:1096-1097`). **Inferred:** the marquee rectangle itself is not drawn in 3D (`world3d_fx.gd` has no `sel_rect`), so judge selection via the list/aura, not rectangle pixels | Exact expected ID set, zero `cmd_*` side effects, no click-pick regression; PNG shows selection aura | 20–30 s |
| **FINAL** (last, never early) | Full variant gate: `godot_runner.py run … --headless --path variant3d -- --self-test variant3d/selftest.json`, then `--ui-test variant3d/uitest.json`, then clean-queue check | — | 29/29 + 17/17 + no unacknowledged failures; do not weaken any predicate (`T01_selftest_taxonomy.md:148-164`) | All gates green, queue `status` clean (`docs/COMMANDS.md:33-40`) | 82–100 s each (measured: 82.13 s baseline `variant3d/README.md:34`, 99.31 s `W26_test_speed.md:145`) |

**Ordering rule (derived):** run P0→P1→P2→P3→C1→C2→C3→C4→S1→FINAL, one
runner ticket at a time, and stop the ladder at the first failing row. Do not
launch FINAL until every earlier row has a second-agent capture re-check
(`TEST_MATRIX.md:34`).

## Scaffolding needed

1. **New, shared but single-owner helper** `variant3d/tests/fixtures/_smallmap_harness.gd`
   (proposed name): `make_stub_game(w,h,height,res_nodes,tileblock)` plus
   `count_categories()` and `write_result()`. It must supply the stub surface
   the modules actually call: `MAP_W/MAP_H`, `height`, `tileblock`, `terrain`,
   `res_nodes`/`res_dirty`, `entities`, `pick_radius`, `height_at`,
   `resolve_mine_sid`, and empty `cmd_*` counters — see the two proven stub shapes
   (`t_terrain3d.gd:41-46,106-127`; `t_pick3d.gd:53-71`). **Derived:** because
   multiple atoms would load it, exactly one builder owns this file; no atom may
   edit it. Alternative if ownership cannot be granted: duplicate the ~40-line
   helper inside each atom (no shared file, more duplication).
2. **New fixture** (optional) `variant3d/tests/fixtures/small_map_32.json`,
   exact copy of the 64² overlay shape with `32/32` (`small_map_64.json:10-15`),
   marked `READY_NOT_RUN`. Not needed for the ladder itself.
3. **New per-row atom files** — names in the table above; each copies
   `_template_test.gd:1-38`, uses `load()` rather than `class_name`
   (`t_terrain3d.gd:12-13`, `terrain3d_sandbox.gd:71-72`), and writes its own
   `res://tests/results/<id>.json`.
4. **Windowed capture pattern** for every PNG row: headless guard first
   (`t_forest_bake_render.gd:36-41`; `main.gd:1157-1158`). Stub rows (P0–C4)
   read their own `SubViewport` after `await RenderingServer.frame_post_draw`
   and `save_png()` (`terrain3d_sandbox.gd:139-151`, `testbridge.gd:277-308`).
   The real-boot row S1 uses main's own `--screenshot` path, which guarantees
   the `Screenshot3DViewport` readback, the `.raw.png` diagnostic and a loud
   blank-frame failure (`main.gd:1821-1853`; `V770_viewport_capture.md:29-35`).
5. **Result cross-check** (read-only): `smallmap_capture.py stats <png>` and
   `scan-stderr <runner stderr>` (`smallmap_capture.py:21-39,50-58`).

### Existing files that would need an integration ticket (NOT touched here)

| File | Why | Minimal change |
|---|---|---|
| `variant3d/tests/manifest.json` | register the 9 new atoms with unique `id`, `path`, `timeout`, `owner`, `"windowed": true` for PNG rows (`manifest.json:4,187-193,196-249`) | additive entries only |
| `variant3d/tools/test_all.py` | hard-coded `ROOT/app/...` (`:27-30`) makes registry runs hit the 2D project | variant-aware roots (`variant3d/tests`, `variant3d/tools/godot_runner.py`) |
| `variant3d/tests/manifest.json:4` | `result_dir` points at `app/tests/results` while atoms write `res://tests/results` (`_template_test.gd:6`) | set `variant3d/tests/results` |
| `variant3d/tests/t_smallmap_terrain.gd:202-211` | only accepts 64/128; blocks a 16/32 exploratory atom | widen/parameterise, or leave and use a new atom |
| `variant3d/scripts/terrain3d_sandbox.gd:81,110-124` | calls `build_from_dump(w,x,y,n)` on `world3d.gd`, but that method now lives in `heightmap_world3d.gd:150` with a one-arg signature; `DistantGround` exists only in this file (grep: 1 hit) | retire or re-point; do **not** reuse as-is |
| `variant3d/scripts/main.gd:1096-1097` | `--screenshot` hides HUD, inconvenient for S1 | atom-side `hud.visible = true` is enough; no main.gd edit required |
| `variant3d/scripts/game.gd:306-315` | no category disable flags | not needed if the harness uses stubs; a future `no_*` flag would be a larger integration ticket |

## Blockers

1. **Observed — no config/generator flag to isolate a category** (`game.gd:306-315`,
   `config.gd:70-94`). Isolation must be synthetic or post-hoc; this is the main
   design constraint.
2. **Observed — 3D PNG cannot be captured headless** (`main.gd:1157-1158,
   1790-1800`). Each PNG atom must be a windowed runner job and must add the
   headless-skip guard (`t_forest_bake_render.gd:36-41`).
3. **Observed — no screenshot-resolution flag** (`main.gd:1184`, `data.gd:113-115`);
   all captures are 1,280×720. A different size needs a config overlay or an
   atom-side `get_window().size` before boot — never a mid-run resize
   (`COMMANDS.md:123-124`).
4. **Observed — queue serialization + hard timeout** (`godot_runner.py:305-343,
   349-437`): rows cannot be parallelised, and a hung atom is killed only at
   `--timeout`. Combined with the `_initialize()` quit trap
   (`tests/README.md:3-33`), every new atom must defer its quit.
5. **Observed — the registry aggregator is on 2D paths** (`manifest.json:4`,
   `test_all.py:27-30`), so "register + test_all" does not work for variant3d
   today; manual runner launches are required.
6. **Observed — stale sandbox hooks** (`terrain3d_sandbox.gd:81` vs
   `heightmap_world3d.gd:150`; `DistantGround` only at `terrain3d_sandbox.gd:116`).
   Do not build the new harness on that file.
7. **Observed — selection marquee has no 3D renderer** (`world3d.gd:126`,
   `world3d_fx.gd` 0 hits for `sel_rect`). S1's pass criterion must be the
   selection ID set, not a visible rectangle.
8. **Observed — no donor reference capture at 64²** (`TERRAIN_SMALL_maps.md:24-29,
   204-211`). All visual criteria here are internal consistency + second-agent
   review; donor parity stays UNVERIFIED, as `TEST_MATRIX.md:32-34` requires.
9. **Derived — stderr evidence is external-only** (`smallmap_capture.py:50-58`);
   every row must retain its runner `stderr.txt` until the scan is done.
10. **Derived — class-name cache**: newly authored helper scripts must be loaded
    dynamically (`load()`), not referenced by `class_name`, until an editor
    import refreshes `.godot` (`t_terrain3d.gd:12-13`, `terrain3d_sandbox.gd:71-72`).
11. **Derived — time budget**: the fixed per-process startup dominates (43.6 s
    proxy in `T03_test_cost_deps.md:25`; >99.7 % of a 123 s subset in
    `W26_test_speed.md:194-201`). A "fast" tiny atom is still ~10–30 s of runner
    time, and queue wait may exceed run time.

## Recommended new atom names + ownership

All under `variant3d/tests/`; one builder owns each file, and no builder edits
another's file (`docs/coord_swarm_2026-11-25/CHARTER.md:44-48`).

| Owner slot (proposed) | New file | Dependency |
|---|---|---|
| TEST-02a | `t_terrain_only.gd` | shared helper owner |
| TEST-02b | `t_terrain_trees.gd` | helper + P0 result as baseline |
| TEST-02c | `t_terrain_shore.gd` | helper + P0 baseline |
| TEST-02d | `t_terrain_mines.gd` | helper + P0 baseline |
| TEST-03a | `t_combo_trees_shore.gd` | P1+P2 |
| TEST-03b | `t_combo_trees_mines.gd` | P1+P3 |
| TEST-03c | `t_combo_shore_mines.gd` | P2+P3 |
| TEST-03d | `t_combo_all.gd` | P1+P2+P3, last combo |
| TEST-04 | `t_select_rect.gd` | real 64² boot + `picking3d`/`camera3d` |
| TEST-00 (harness) | `tests/fixtures/_smallmap_harness.gd` (single owner; or per-atom copy) | none |
| Integration ticket (separate) | `manifest.json`, `test_all.py`, optional `small_map_32.json` | after all rows pass |

## Open questions

1. Should P0–C4 use the stub harness (fast, clean isolation) or a pruned real
   game (real donor tileblock/atlas, but generator artefacts remain in
   `tileblock`)? The matrix asks for donor ground colour/placement bands
   (`TEST_MATRIX.md:18`), which favours the real tileblock; exact isolation
   favours the stub. **Unresolved.** A pragmatic compromise: stub for P0–C4
   structural counts, one real-boot cross-check at C4.
2. Is 64² the coordinator's intended "smallest possible", or should 32² be
   attempted (config floor is 16², `config.gd:405-406`)? Recommend 64² until a
   32² probe is actually run.
3. Which N units for S1, and should the synthetic drag be injected via
   `Input.parse_input_event` (testbridge pattern, `testbridge.gd:129-142`) or by
   calling the drag branch through a stub viewport? Recommend real input events.
4. Does the selection aura render in the windowed 3D capture path? `world3d.gd:685-686`
   syncs it to FX, but no capture of a selection was measured; S1 must report
   this as UNVERIFIED if the PNG does not show it.
5. Who performs the mandatory second-agent capture re-check (`TEST_MATRIX.md:34`),
   and where are donor reference frames for 64² sourced?
6. Should `hud.visible` be restored inside S1, or should the atom avoid
   `--screenshot` and capture the viewport itself (`testbridge.gd:277-308`)?
   The latter avoids main's HUD-hiding branch but duplicates capture logic.

## Summary

- **Observed:** the smallest committed, measured map is **64²** (4,096 cells);
  the config floor is 16²; 128² was never run; 3D PNGs need a windowed runner
  job and a dedicated SubViewport; atoms must defer `quit`; the queue is a
  serialized FIFO; the variant registry/aggregator still points at `app/`.
- **Derived:** a uniform 64² stub-based ladder can isolate terrain, trees,
  shore and mines one at a time and then combine them; a real-boot 64² atom is
  needed only for the N-unit selection rectangle and the final gate. Each row is
  a new single-feature atom; time estimates are 10–15 s stub rows, 20–30 s S1,
  82–100 s for each final gate, excluding queue wait.
- **Inferred:** 16²/32² are degenerate for the full generator because its
  metre-scale keep-clear radii cover such a map; the marquee rectangle is not
  drawn in 3D, so selection must be judged from the selected-ID list/aura; no
  donor visual parity can be claimed from these captures.
- **Blocked until integration:** manifest registration, `test_all.py` roots,
  the stale `terrain3d_sandbox.gd` API, and the absent per-category generator
  flags. None were changed in this report; no Godot job was submitted.
