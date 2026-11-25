---
id: TEST-P3
title: "Author isolated terrain + mines 64² atom (ONE new test file) — design/authoring report"
owner: TEST-P3
date: 2026-11-25
status: AUTHORED__NO_RUNNER__NO_GODOT__NO_PASS_CLAIM
scope: "Authoring only. Owns variant3d/tests/t_terrain_mines.gd and this report. No Godot launch, no runner job, no manifest/config/source/test edit."
owns:
  - "variant3d/tests/t_terrain_mines.gd (new)"
  - "docs/coord_swarm_2026-11-25/reports/TEST_P3_report.md (new)"
evidence_labels: [observed, derived, inferred, unverified]
---

# TEST-P3 — isolated terrain + mines 64² atom (authored, not run)

## Goal

Author exactly one new `extends SceneTree` atom that exercises **row P3** of the
small-map ladder: the same 64×64 P0 baseline (all-grass tileblock, mild positive
height, zero water cells, no trees) with **only** gold/iron/coal mine resource
nodes added, injected through the real `world3d_entities.add_resource()` path
(`TEST_01_smallmap_harness.md:215`; `TEST_MATRIX.md:21,43`;
`V3D_02_terrain_render_audit.md:147`). The atom must assert category purity and
exact per-type counts, sid resolution, mine Y vs terrain, unchanged P0 mesh
invariants, no water cells, and a windowed PNG A/B for ground stability — while
keeping donor parity and visual review honestly UNVERIFIED.

No Godot was launched, no runner ticket was created, and **no PASS is claimed**.

## Sources read (all read-only)

| Source | Used for |
|---|---|
| `docs/coord_swarm_2026-11-25/reports/TEST_01_smallmap_harness.md:60-141,183-226,247-255` | P3 row, stub-vs-real-boot rule, windowed capture pattern, shared-helper ownership, headless guard, result JSON, deferred quit |
| `docs/coord_swarm_2026-11-25/TEST_MATRIX.md:11-12,21,29-46,53-58` | same-map ladder rule, P3 measures, T3 extra assertion, "metrics never override visual A/B" |
| `docs/coord_swarm_2026-11-25/reports/V3D_02_terrain_render_audit.md:77,134-153` | T3 row: mine sid resolves, Y matches terrain, ground unchanged outside bbox, no z-fighting |
| `docs/audit/PIECES/mines_display.md:21-49,52-68,235,307-308` | donor mine asset chain, `ENV_SCALE.mine=0.3152`, min=max=1 (no jitter), ~4.7×5.0×0.6 m footprint, no donor mine screenshot (reference UNVERIFIED). **DTRN_05 has not landed**, so this is the required fallback |
| `variant3d/scripts/world3d_entities.gd:102-118,1269-1315,1060-1079,1082-1091` | `ENV_SCALE`, `POOL_TREE/ROCK/STUMP`, `_resource_sid()` → `mine_<ty>`, `add_resource()`, `_world_pos()` half-map centring, permanent-ore visibility |
| `variant3d/scripts/game.gd:19,2685-2702,306-315` | `MINE_SITE_RADIUS=4.0`, `resolve_mine_sid()` logic, no per-category generator switch |
| `variant3d/scripts/world3d_terrain.gd:93-95,109-118,360-382,408-445,624-874,883-903` | `WATER_LEVEL`, donor slope thresholds, dump schema, mesh/stats contract, `height_at_world()` bilinear recipe |
| `variant3d/scripts/terrain3d_sandbox.gd:23-36,139-151` | fixed PORT-APPROX camera (216 mm sensor, 40 m height, −32° tilt) and `frame_post_draw` readback |
| `variant3d/scripts/testbridge.gd:277-308` | viewport texture → `Image` → `save_png()` readback pattern |
| `variant3d/tests/t_terrain3d.gd:12-14,41-46,106-127,130-151,161-255` | SceneTree atom, dynamic `load()`, stub shape, largest-mesh finder, deferred quit |
| `variant3d/tests/t_pick3d.gd:53-71` | stub `cmd_*` counter pattern |
| `variant3d/tests/README.md:3-33,67-86` and `_template_test.gd:1-38` | one atom/file, result JSON, quit rule |
| `variant3d/tests/fixtures/_smallmap_harness.gd:1-161` | shared helper (landed by another owner during authoring) |
| `variant3d/tests/t_terrain_only.gd:269-295` | precedent for dynamic-load + embedded fallback of that helper |

## What was authored

**Only** `variant3d/tests/t_terrain_mines.gd` (new) plus this report.

- `extends SceneTree`; module and helper scripts are loaded with dynamic `load()`
  — no `class_name` dependency (`t_terrain3d.gd:12-13`, TEST-01 Blocker 10).
- P0 fixture built at 64² (`GRID_W=GRID_H=64`, 4,096 cells): mild analytic
  height `1.0 + 0.25·sin(x·0.05) + 0.20·cos(z·0.04)` → min ≈0.55 m > −0.25 m
  water level, max per-cell delta ≈0.013 ≪ donor `cDiff1=0.5`, so face mode
  stays 0; all tile ids 0 (grass1).
- Shared harness helper `fixtures/_smallmap_harness.gd` is dynamically loaded and
  its static `make_height`, `make_tileblock`, `make_stub_game` and
  `count_categories` are used (`_smallmap_harness.gd:108-144`). An embedded
  minimal stub is retained as a **labelled fallback** if the helper is absent or
  unloadable, and the chosen source is written to the result JSON
  (`harness_helper.status`). This satisfies the "embed minimal stub if absent,
  note it" instruction; today the shared helper is present and used.
- Six permanent ore nodes (`max_hits=0`) at known sim-metre positions:
  gold `(32,32)`, `(96,96)`; iron `(32,96)`, `(96,32)`; coal `(48,64)`, `(80,64)`.
  They are fed through `world3d_entities.add_resource()` (`:1294-1315`).
- `resolve_mine_sid()` is implemented in the stub with the verbatim logic of
  `game.gd:2685-2702` and `MINE_SITE_RADIUS=4.0` (`game.gd:19`).
- Result JSON: `res://tests/results/t_terrain_mines.json`; PNG default:
  `res://tests/results/t_terrain_mines.png` (overridable with user args
  `--png <path>` / `--png=<path>`). Every exit is
  `call_deferred("quit", 0 if _ok else 1)` — never a direct quit from
  `_initialize()`.
- Headless guard: `DisplayServer.get_name() == "headless"` runs structural
  assertions only and marks every capture-dependent item `HEADLESS_SKIP` /
  `UNVERIFIED`; it never reports a windowed capture as passing.
- Windowed capture: own 1280×720 `SubViewport`, fixed camera,
  `await RenderingServer.frame_post_draw`, `get_texture().get_image()`,
  `save_png()` (`t_terrain_mines.gd:459-609`). Two frames are grabbed: entities
  hidden (P0 baseline) and entities visible (P3), so the ground luma/variance
  comparison outside the mine screen bbox is a real A/B, not an invented number.

## Exact assertions (with citations)

| # | Check name in atom | Assertion | Citation |
|---|---|---|---|
| 0 | `module_load_and_api` / `build_ok` | Both modules `load()` cleanly; `world3d_terrain.build()` returns true | `t_terrain_mines.gd:643,675`; `t_terrain3d.gd:161-204` |
| 1 | `p0_mesh_invariants` | `mesh_surfaces=1`, `vertices=4096`, `triangles=7938`, `tile_index_cells=4096`, UV2 count 4096 with all `(0,0)`, tile histogram `{0:4096}`, face histogram `{0:4096}`, atlas grid `(16,8)`, shader uniform `shadow_enabled=0`, no shadow-casting sun, terrain `cast_shadow=OFF` | `t_terrain_mines.gd:685-737`; `world3d_terrain.gd:664-747,785-826`; `V3D_02:144`; `TEST_MATRIX.md:33-34` |
| 2 | `no_water_cells` | `stats.height_min_m > -0.25` and tile id `255` (`BLK_WATER`) absent from histogram | `t_terrain_mines.gd:739-744`; `world3d_terrain.gd:95,697-702`; `TEST_01:212` |
| 3 | `ore_instance_counts` | For each of gold/iron/coal, rendered instances == `N_PER_TYPE=2`, derived from the real `_batches["res\|mine_<ty>"]["ids"]` arrays (not just the input list) | `t_terrain_mines.gd:343-363,746-756`; `world3d_entities.gd:1269-1276,1294-1315` |
| 4 | `category_purity` | Rendered `wood=0`, `stone=0`, `food=0` (sid prefix mapping `tree*`/`rock*`/`stone`/`field`), and helper source-category counts also zero | `t_terrain_mines.gd:331-340,757-768`; `world3d_entities.gd:114-118,1269-1283`; `_smallmap_harness.gd:133-144`; `TEST_01:215` |
| 5 | `mine_sid_resolution` | For all six positions, `game.resolve_mine_sid("mine",pos) == "mine_"+type` and `_resource_sid(type,pos)` agrees; all sids non-empty; unrelated sid `"hou"` unchanged | `t_terrain_mines.gd:770-787`; `game.gd:2685-2702`; `world3d_entities.gd:1269-1283`; `V3D_02:147` |
| 6 | `mine_y_matches_terrain` | Each instance transform origin `y` equals `terrain.height_at_world(origin.xz)` within 1e-3 m (six samples recorded) | `t_terrain_mines.gd:789-820`; `world3d_entities.gd:1060-1079,1094-1119`; `world3d_terrain.gd:883-903`; `V3D_02:147` |
| 7 | `env_scale_mine_from_code` | `ENV_SCALE.mine` read from the module's script constant map (source-text fallback) equals `0.3152`. Result JSON records **read value**, `donor_parity_claimed:false` | `t_terrain_mines.gd:820-841`; `world3d_entities.gd:113`; `mines_display.md:36-45,235` |
| 8 | `png_capture_windowed` | PNG saved from windowed SubViewport; non-black fraction > 0.9 (luma > 8/255); measured image size recorded | `t_terrain_mines.gd:565-590`; `TEST_01:190-198,247-253`; `V3D_02:151` |
| 9 | `ground_luma_variance_outside_mine_bbox` | If both readbacks and the projected mine screen bbox exist: mean luma delta ≤2/255 and variance delta ≤5 outside that bbox, with numbers in JSON. Otherwise status `UNVERIFIED` and **no numeric pass claim** | `t_terrain_mines.gd:496-541,589-604`; `V3D_02:147`; `TEST_MATRIX.md:43` |
| 10 | `no_z_fighting_seam_visual` | Explicitly a **visual review criterion**; JSON status `UNVERIFIED__VISUAL_REVIEW_REQUIRED`, detail points at the PNG. No fake numeric proxy is asserted | `t_terrain_mines.gd:605-608`; `TEST_MATRIX.md:43,58`; `V3D_02:147` |

Runner-external stderr scan (`python variant3d\tools\smallmap_capture.py scan-stderr
<stderr.txt>`, `smallmap_capture.py:50-58`) remains a **runner-side step**, not
part of this authored atom. No runner job was submitted here.

## Expected pre-fix result (prediction, not a measurement)

- **Structural checks expected to pass if the code is wired as read**: 1–7 above.
  The three mine sids exist in `assets/models/manifest.json:385,404,423` and the
  OBJ/tex files exist; `_resource_sid()` is a literal `"mine_"+ty` mapping;
  `add_resource()` creates one `res|mine_<ty>` batch per type. Mine Y should
  agree because the stub/helper `height_at()` uses the same bilinear recipe as
  `height_at_world()` for the centred world point. Zero water cells and flat
  face histogram follow from the analytic field.
- **Check 8 (windowed PNG)** is **unknown until run**: it depends on the live
  windowed SubViewport and GPU readback; a blank frame would fail it loudly.
- **Check 9 (ground A/B)** is expected to be small because only resource nodes
  are toggled and the terrain mesh/material is untouched — but the numbers must
  come from a real run; nothing is claimed here.
- **Check 10 (z-fighting/seam)** and all donor parity remain **UNVERIFIED** by
  construction: no donor GPU frame or donor mine screenshot exists
  (`mines_display.md:120-126,234`; `V3D_02:14,198-199`; `TEST_MATRIX.md:32-34`).
- The port's mine *scale/jitter visual parity* is explicitly **not** claimed:
  `0.3152` is read from code and the donor `minscale=maxscale=1` value is cited,
  but no jitter or rendered-size comparison is performed by this atom
  (`mines_display.md:36-45, C3/C14`).
- Known fragility to check on first real run: `ShaderMaterial.get_shader_parameter`
  availability, `Script.get_script_constant_map()` availability (source-text
  fallback included), and SubViewport readback under the runner's window mode.

## Open questions

1. Does the runner launch this atom windowed with a real GPU canvas so the
   SubViewport PNG is non-blank? If not, check 8 fails and 9/10 stay UNVERIFIED.
2. Is 1280×720 with the PORT-APPROX 216 mm / 40 m / −32° camera sufficient to
   place all six mines on screen for a meaningful bbox mask? The camera values
   are reused from `terrain3d_sandbox.gd:23-36`, not donor-verified.
3. Two-frame A/B may show small non-mine deltas from water shader animation or
   GPU timing; if so, should the tolerance be tightened with a longer settle or
   a paused water uniform? Not decided here — no weakening was applied.
4. Should the 72 px mine screen margin be derived from the donor footprint
   (~4.7×5.0 m at 0.3152, `mines_display.md:57-67`) via exact projection instead
   of a fixed generous margin? Current value is conservative and labelled.
5. Who performs the mandatory second-agent capture re-check (`TEST_MATRIX.md:58`)
   and supplies any donor mine reference that would upgrade the visual verdict?
6. Does the shared helper need a `write_result` extension so this atom can use
   it without duplicating JSON writing? Its current shape is minimal
   (`_smallmap_harness.gd:146-161`), so this atom keeps a richer result writer.

## No-runner declaration

No Godot process was started; no `godot_runner.py` ticket was requested; no
`--self-test` / `--ui-test` gate was run; no manifest, config, fixture, source,
shader, asset or other test file was edited. Only the two owned paths listed in
the frontmatter were written. **No PASS/FAIL verdict is claimed for this atom.**
