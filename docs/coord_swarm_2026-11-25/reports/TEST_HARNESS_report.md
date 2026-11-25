---
id: TEST-HARNESS
title: "Shared 64² stub-game helper — authoring report"
owner: TEST-HARNESS
date: 2026-11-25
status: AUTHORED__NO_GODOT_RUNS__NO_RUNNER_JOBS__NO_TESTS_CLAIMED
scope: "One new file only: variant3d/tests/fixtures/_smallmap_harness.gd. No source, config, manifest, test_all.py, existing script or other agent's file touched."
owns:
  - "variant3d/tests/fixtures/_smallmap_harness.gd"
  - "docs/coord_swarm_2026-11-25/reports/TEST_HARNESS_report.md"
labels: [SHARED_HELPER, STUB_GAME, 64_SQUARE, DYNAMIC_LOAD]
evidence_labels: [observed, derived]
matrix: "docs/coord_swarm_2026-11-25/TEST_MATRIX.md:16-27"
---

# TEST-HARNESS — shared small-map stub helper

## Goal

Author the single shared helper requested in
`reports/TEST_01_smallmap_harness.md:228-239` ("Scaffolding needed" item 1) so
each ladder atom (P0–C4, and the picker part of S1) can construct the *same*
64² stub surface without duplicating ~40 lines of fixture code. The helper is
**data/fixture-only**: it returns a bound-able stub game and writes result JSON.
It does not boot Godot, does not render, and does not load `main.tscn`.

## Sources read (read-only)

| Source | Used for |
|---|---|
| `reports/TEST_01_smallmap_harness.md:228-239,269-305,307-324` | required API, ownership rule, blockers 10 (dynamic `load()`), recommended slot TEST-00 |
| `TEST_MATRIX.md:11-27,29-51,53-58` | common-map rule, P0–C4/S1 row contents, no-new-harness refinement |
| `variant3d/tests/t_terrain3d.gd:41-46,106-127` | `StubGame extends C3Game`; `MAP_W/MAP_H`, `map_w/map_h`, `height`, `height_b64`, `dump` shape |
| `variant3d/tests/t_pick3d.gd:53-71,73-145,151-179,234-236` | `StubGame extends Node`; `entities/res_nodes/res_dirty`, `pick_radius()=1.0`, all 24 `cmd_*` counters, `total_cmd_calls()`, camera stub |
| `variant3d/tests/_template_test.gd:6,17-31` | result JSON shape and `res://tests/results` directory |
| `variant3d/scripts/world3d_terrain.gd:95,402-445,448-488,886-903` | `dump` keys (`map_w/map_h/height/tileblock`), `WATER_LEVEL=-0.25`, `height_at_world` recipe (mirrored) |
| `variant3d/scripts/world3d_entities.gd:1060-1079,1269-1315` | resource-node dict keys (`type/pos/id`), `game.call("height_at", p)` with `p: Vector2`, category→sid mapping (`wood/stone/gold/iron/coal/food/bush/stump`) |
| `variant3d/scripts/game.gd:16,19,453-460,1555-1560,1893-1907,2685-2702` | `TILE=2.0`, `MINE_SITE_RADIUS=4.0`, `_t(x,y)=y*MAP_W+x`, `pick_radius`, bilinear `height_at`, `resolve_mine_sid` |
| `variant3d/scripts/main.gd:737-741,1144` | `terrain`/`tileblock`/`height` are byte grids; `terrain[idx]==3` is water |
| `variant3d/scripts/water3d.gd:19`, `camera3d.gd:111-113,225-226,288-303` | water level literal and which `game` methods camera probes |
| GDScript reference (`docs.godotengine.org`, "Functions") | confirmed `func f(): return x` one-line bodies are valid |

## File authored

`variant3d/tests/fixtures/_smallmap_harness.gd` — 153 lines, `extends RefCounted`,
**no `class_name`**, intended to be loaded with
`var H = load("res://tests/fixtures/_smallmap_harness.gd")` (or a `const`
`preload` if the atom prefers) and called as `H.<static_func>(...)`. It contains
one inner class `StubGame extends Node` plus static factories.

### API documented

| Member | Contract / provenance |
|---|---|
| `make_stub_game(w, h, height: PackedFloat32Array, res_nodes: Array, tileblock: PackedByteArray) -> Object` | Returns a `Node`-derived stub so atoms can `root.add_child()` it (`t_pick3d.gd:212-217`). Supplies `MAP_W/MAP_H` (+ `map_w/map_h` fallbacks), `height`, `tileblock`, `terrain` (zeros = no water), `dump`, `res_nodes`, `res_dirty=0`, `entities`, `cmd_calls`, and the methods below. `dump` is built with the exact `main.gd:737-741` base64 recipe so `world3d_terrain.gd:411-445` reads tile indices rather than the splat fallback. |
| `height_at(a, b = null) -> float` | **Dual signature.** `a is Vector2` → sim map-origin metres, exact bilinear recipe of `game.gd:1893-1907` (this is what `world3d_entities.gd:1078` and `camera3d.gd:292` call). Two numbers → direct grid cell `height[z*MAP_W+x]` (`game.gd:453-454`). Out-of-range/short grid → `0.0`. |
| `resolve_mine_sid(sid: String, pos: Vector2) -> String` | `game.gd:2685-2702`: non-"mine" passes through; otherwise nearest `gold/iron/coal` node with `max_hits == 0` inside `MINE_SITE_RADIUS=4.0`, else `"mine_gold"`. Reads dict *or* object res-node entries. |
| `pick_radius(e) -> float` | constant `1.0` (`t_pick3d.gd:64-65`). |
| `total_cmd_calls() -> int` / `cmd_calls: Dictionary` | All 24 `cmd_*` of `game.gd` bump the counter (`t_pick3d.gd:73-145`); `0` means no side effects. `cmd_sow`/`cmd_replenish` return `int`. |
| `count_categories(res_nodes: Array) -> Dictionary` | `{"wood":n,"stone":n,"mine":n,"food":n}`; `gold/iron/coal` fold into `mine` per `world3d_entities.gd:1269-1278`. Accepts dict or object nodes. |
| `make_height(w, h, fn: Callable = Callable()) -> PackedFloat32Array` | Row-major `z*w+x`; calls `fn.call(x,z)`, or fills `0.0` when `fn` is invalid. |
| `make_tileblock(w, h, id: int) -> PackedByteArray` | `w*h` bytes filled with the caller's tile id (harness invents no atlas id). |
| `write_result(path, id, checks: Array, passed: bool) -> void` | Writes `<res:// dir>/<id>.json` with `{"id","passed","checks","unix_ms"}`, exactly `_template_test.gd:6,17-31`. `path` is the results **directory**, e.g. `"res://tests/results"`. |

### Explicit non-goals (atoms still own these)

- Windowed `SubViewport` + `await RenderingServer.frame_post_draw` + `save_png()`
  (`TEST_01:247-253`); camera stub (`t_pick3d.gd:151-179`) and the real-world
  `camera3d` bind; donor asset/atlas ids; selecting sand/rock tile ids; the
  `res_dirty` bump when an atom mutates `res_nodes`.
- Attaching the stub to a tree, calling `bind()`, `build()`, `add_resource()`
  and `call_deferred("quit", ...)` — those stay in each atom.

## How each atom should consume it

Common prelude (derived from `TEST_01:230-239`, blocker 10 at `:299-301`):

```
var H = load("res://tests/fixtures/_smallmap_harness.gd")
var height := H.make_height(64, 64, fn)      # fn(x,z) -> float; flat for P0
var tiles := H.make_tileblock(64, 64, grass_id)  # id from donor atlas, not invented
var g := H.make_stub_game(64, 64, height, [], tiles)
```

| Atom | Consumption |
|---|---|
| **P0** `t_terrain_only` | Empty `res_nodes`, flat/mild `height`, all-grass `tileblock`; bind `world3d_terrain.gd` + camera; assert `H.count_categories(g.res_nodes)` is all-zero and no cell below `WATER_LEVEL=-0.25`. Finish with `H.write_result("res://tests/results","t_terrain_only",checks,passed)` + deferred quit. |
| **P1** `t_terrain_trees` | Reuse P0's `height`/`tiles`; `res_nodes` = ~20 dicts `{"id":i,"type":"wood","pos":Vector2(...),"max_hits":0}` at known positions; `H.count_categories(g.res_nodes)["wood"] == N`, other three `0`; pass each node to `world3d_entities.add_resource()`. |
| **P2** `t_terrain_shore` | Reuse P0; make `height` with an `fn` that sinks a bounded basin below `-0.25` (`world3d_terrain.gd:95`); `make_tileblock` with the chosen sand/rock collar ids; `res_nodes=[]`. Assert water-cell count and one water plane in the atom. |
| **P3** `t_terrain_mines` | Reuse P0; `res_nodes` = `gold/iron/coal` dicts; `H.count_categories(...)["mine"] == N`, wood/stone/food `0`; `g.resolve_mine_sid("mine", pos)` returns `mine_<ty>` at each node. |
| **C1** trees+shore | Union of P1 `res_nodes` + P2 `height`/`tiles`; `count_categories` reports `wood=N`, `mine=0`; run both P0 mesh and shore assertions. |
| **C2** trees+mines | Union of P1 + P3 `res_nodes`; `count_categories` reports `wood=N`, `mine=M`; check positional separation in the atom. |
| **C3** shore+mines | P2 `height`/`tiles` + P3 `res_nodes`; assert every ore `height_at(...) > -0.25`. |
| **C4** all | Union of P1+P2+P3; all four category counts and P0 mesh invariants at once; last stub row. |
| **S1** `t_select_rect` | Real 64² boot (`main.tscn`) owns the game, so **do not** pass a harness stub to `main`. Use `H.write_result(...)` for the JSON; if the picker is re-tested against a stub, bind it to `H.make_stub_game(...)` and assert `g.total_cmd_calls() == 0` (`t_pick3d.gd:234-236`). |

## What could not be implemented, and why

1. **No camera stub factory.** Kept per-atom (`t_pick3d.gd:151-179`) because the
   camera contract is row-specific (screen-centre constant, `get_view_rect`)
   and the task's minimum surface names only the game.
2. **No donor-noise fallback in `height_at`.** `game.gd:1895-1896` falls back to
   `_noise2(...)*2.0` when `height.size() != MAP_W*MAP_H`; the harness returns
   `0.0` instead. Importing `_noise2` would mean copying donor code, forbidden
   by "no donor copying"; atoms must pass a full `w*h` grid.
3. **`terrain` is all zeros.** `id=3` means water (`main.gd:1144`), so a flat
   land grid avoids inventing donor terrain ids; shore atoms must set their own
   terrain/water ids if they need them.
4. **`units`/`buildings` fields omitted.** Present in `t_pick3d.gd:56-57` but
   not in the required surface; atoms can still add ad-hoc fields to the
   returned object.
5. **No `height_at_world`, `field_state`, `field_growth01`, `blocked`,
   `mine_mask` stubs.** These are optional probes guarded by `has_method`
   in the modules; adding them would change which branch those modules take.
   Atoms may add them locally if a row needs them.
6. **`class_name` intentionally absent** (task rule / `TEST_01:299-301`); all
   consumers must `load()` the file dynamically.
7. **Line budget:** file is 153 lines, marginally over the "≤ ~150" guidance;
   further cuts would require dropping one of the 24 `cmd_*` counters.

## Open questions

1. Should atoms call `height_at(Vector2)` (metres) exclusively, or rely on the
   extra `height_at(x,z)` cell accessor? Recommendation: Vector2 for modules;
   the numeric form only for row-local assertions.
2. Which donor tile ids to pass to `make_tileblock` for grass/sand/rock? The
   helper deliberately takes an `id` argument; no id was invented.
3. Should S1 bind `picking3d` to the harness stub (clean counter) or assert on
   the real game? `TEST_01:220` asks for a `cmd_*` counter check; the stub is
   the cleaner route but diverges from the "real boot" requirement.
4. Does the returned `dump` dict (which wins at `world3d_terrain.gd:411-414`)
   ever disagree with a later mutation of `g.height`/`g.tileblock`? Atoms must
   rebuild via `make_stub_game` or update `g.dump` themselves.
5. 64² vs exploratory 32² remains unresolved (`TEST_01` open question 2);
   the factories accept arbitrary `w,h`, so either is supported.

## No-runner declaration

**No Godot process was launched, no runner job/ticket was submitted, no
`manifest.json`, `test_all.py`, runner config or pre-existing source/test file
was edited, and no donor asset was copied.** Only the two files listed in
`owns` were written. No test has been executed and **no test result is claimed
to pass**; the helper is authored but unverified at runtime.
