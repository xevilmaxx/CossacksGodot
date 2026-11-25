---
id: TEST-P2
title: "Author the ISOLATED terrain + shore 64² atom (ONE new test file)"
date: 2026-11-25
owner: TEST-P2
status: AUTHORED__NOT_RUN__NO_GODOT_JOBS__NO_RUNNER_TICKET
scope: "Authoring only. Exactly two files touched: the new atom and this report. No source/shader/asset/config/manifest/fixture/gate/git edit."
owns:
  - "variant3d/tests/t_terrain_shore.gd (new)"
  - "docs/coord_swarm_2026-11-25/reports/TEST_P2_report.md"
labels: [ISOLATED, TERRAIN_SHORE, 64x64, STUB_GAME, WINDOWED_PNG, DONOR_TRUTH, EXPECTED_PRE_FIX_FAILURE]
evidence_labels: [observed, derived, inferred, UNVERIFIED]
parity_claim: false
---

# TEST-P2 report — isolated terrain + shore atom

## 1. Goal

Author **one** `extends SceneTree` atom, `variant3d/tests/t_terrain_shore.gd`, that
tests the P2/T2 shore piece on the same deterministic 64² map as the P0 atom:
P0 baseline geometry + a bounded water basin and sand/rock collar, **no trees and
no mines**. It must assert basin size, a single height-aware water plane, the
4,096-vertex mesh invariant, shore tile ids in the UV2 histogram, a local (not
full-width) PNG band, water alpha confined to water cells, a 1 s water-only
pixel delta when feasible, donor literal readback, and donor-truth failures that
are expected before the DTRN-03 fixes land. This report records the design,
citations, expected pre-fix result and open questions. **The atom was not run;
no PASS is claimed.**

## 2. Sources read (observed)

| Source | Used for |
|---|---|
| `docs/coord_swarm_2026-11-25/reports/TEST_01_smallmap_harness.md:210-214,228-255,269-290` | P2 row design, same-map rule, shared-helper contract, deferred quit, windowed stub-owned capture |
| `docs/coord_swarm_2026-11-25/TEST_MATRIX.md:16-27,29-46,53-58` | P2 row contents, T2 extra assertions, runner/second-agent rules, no parity before F0 |
| `docs/coord_swarm_2026-11-25/reports/DTRN_03_donor_shore_water.md:98-134,159-207,393-401,418-433,459-494` | donor literals, coastfade depths, W1/W2/W3 defects, F1/F2/F3 fix recipe, shore-piece S1–S5 / M1–M9 criteria |
| `docs/coord_swarm_2026-11-25/reports/V3D_02_terrain_render_audit.md:134-148` | T0/T2 baselines: 4,096 verts / 7,938 tris / 4,096 UV2 / atlas (16,8) / one water plane, no full-width dark rows |
| `reports/RV_TRN_03_water_bindings.md` | **ABSENT at authoring time** (recursive glob: 0 hits); binding reachability was read directly from shipped code instead |
| `variant3d/scripts/water3d.gd:19-29,138-168,181-204,207-264` | literal constants, material uniforms, flat plane, `bind_height_grid()`, `waveheight` and stats readback |
| `variant3d/shaders/water3d.gdshader:147-235` | `height > level` discard, `coastfade`/`coastfade2`, `shore_prox` PORT ART block, `time` animation |
| `variant3d/scripts/world3d_terrain.gd:493-545,624-708,728-848` | water module integration, one plane, UV2.x=tile id / UV2.y=face, BLK_WATER clamp, stats shape |
| `variant3d/scripts/game.gd:52,1055-1073,1711-1737` | `BLK_WATER=255`, land-side sandsea rule, donor 8×45° sector table |
| `variant3d/tests/t_terrain3d.gd:12-14,41-46,106-127,161-204` | dynamic `load()`, stub shape, deferred `quit`, result JSON pattern |
| `variant3d/tests/t_pick3d.gd:48-71` | empty `res_nodes`/`cmd_*` stub surface |
| `variant3d/tests/t_terrain_only.gd:88-106,268-295,319-382,418-482,597-643` (READ-ONLY, parallel P0 owner) | local fallback stub, SubViewport capture, fixed `camera3d.gd` framing, PNG metric mirror |
| `variant3d/tests/fixtures/_smallmap_harness.gd:11-24,118-128` (READ-ONLY, parallel harness owner) | shared `make_stub_game(w,h,height,res_nodes,tileblock)` factory and dump shape used by the dynamic `load()` path |
| `variant3d/tests/_template_test.gd:1-38`, `variant3d/tests/README.md:3-33,67-80` | one file / one verdict, `res://tests/results/<id>.json`, deferred quit |
| `variant3d/scripts/testbridge.gd:277-308`, `variant3d/scripts/terrain3d_sandbox.gd:139-151`, `variant3d/scripts/main.gd:1156-1158,1790-1800` | windowed PNG readback; headless has no 3D PNG |
| `variant3d/tools/smallmap_capture.py:21-39` | non-black >8 and "full-width dark row" = >90% of row with luma<20 |
| `variant3d/assets/terrain/structs/tileblocks.json` + `variant3d/assets/terrain/atlas/tile_index_atlas.manifest.json:13-30,2282-2305` | tile ids: sandsea1=93, sandsea5=97, sandsea6=98; sandrock1..6=87..92; rock4/7/8=29/32/33; `named_cells=124` |

## 3. Fixture (derived, deterministic, in memory)

`variant3d/tests/t_terrain_shore.gd:311-348` builds a 64×64 / 4,096-cell height
grid centred on cell (31.5,31.5):

- `r < 3.0` cells: height `-0.55` m, tileblock `BLK_WATER=255` (≈28 cells, **<1 %**
  of the grid, satisfying >0 and <10 %).
- `3.0 ≤ r < 3.8`: height `-0.18` m (wet band between the donor `-0.25` and
  `-0.1` literals), tileblock `sandsea1/5/6` (93/97/98) picked by the donor
  8×45° sector table mirrored from `game.gd:1735`.
- `3.8 ≤ r < 4.7`: height `0.02` m, tileblock `sandrock1..6` (87..92).
- `4.7 ≤ r < 5.4` in sector 0: height `0.08` m, tileblock `rock4` (29).
- Remaining cells: dry grass (`0` ≈0.55 m). Height steps are ≪ `cDiff1=0.5`
  (`world3d_terrain.gd:117-118`), so face promotion is not a confounder.

`res_nodes = []`, no entities, no units, no FX, no fog overlay. The shared helper
`variant3d/tests/fixtures/_smallmap_harness.gd` is attempted by dynamic `load()`
(`:353-364`). It was **absent at the first read** of this task but **landed from
the parallel harness owner before authoring finished**; its
`make_stub_game(w,h,height,res_nodes,tileblock)` signature and the required
`MAP_W/MAP_H`, `height`, `tileblock`, `res_nodes`, `dump` fields were verified by
a read-only inspection (`_smallmap_harness.gd:11-24,118-128`). The atom therefore
takes the `shared:` path in a current checkout, with the embedded `LocalStubGame`
(`:108-160`, same shape as P0 and `t_terrain3d.gd`) retained as the fallback for
a fresh checkout and `harness_source` recorded in the result JSON. The helper is
never referenced by `class_name` (TEST-01 Blocker 10) and was not edited. The stub game
is bound **only** to `world3d_terrain.gd` and a fixed `camera3d.gd` (`:730-785`);
no `main.tscn` boot and no generator-category flags are assumed (TEST-01 Blocker 1).

## 4. Exact assertions (atom location → source / expected)

| # | Assertion in the atom | Source / criterion | Pre-fix expectation |
|---|---|---|---|
| A1 | `harness_stub_shape` — shared helper or embedded stub with MAP_W/MAP_H=64, `height`, `tileblock`, `res_nodes` | TEST-01:230-239, `t_terrain3d.gd:41-46`; `:353-379,672-681` | PASS |
| A2 | `terrain_module_api`, `camera_module_api`, `build_ok` — dynamic `load()` APIs and `build()` success | `t_terrain3d.gd:166-204`; `:700-741` | PASS |
| A3 | `water_cell_count`: `0 < below < CELLS/10` (4096 cells) | TEST-01:214, V3D_02 T2; `:769-775` | PASS (~28) |
| A4 | `exactly_one_water_plane`: one node named `WaterPlane` and one `Water3D`, no stacked constant quad | `world3d_terrain.gd:762-764`, DTRN-03 S1/M9, TEST_MATRIX.md:42; `:743-751` | PASS |
| A5 | `height_aware_true`: both `water3d.stats.height_aware` and `terrain.stats.water.height_aware` | `water3d.gd:248-264`, `world3d_terrain.gd:841-844`, DTRN-03 S1; `:753-767` | PASS |
| A6 | `mesh_surface_count=1`, `mesh_vertex_count=4096`, `mesh_triangle_count=7938`, `uv2_count=4096` | TEST_MATRIX.md:33-34, DTRN-03 S4; `:787-808` | PASS |
| A7 | `shore_ids_in_uv2_histogram`: sandsea1/5/6 **and** sandrock*/rock* ids present in UV2.x | DTRN-03 S5/M8, `texturemap.inc:503-511`, `world3d_terrain.gd:691-708`; `:808-827` | PASS |
| A8 | `donor_literals_exact`: −0.25 / −0.1 / 2.96 / 0.57 / 1.07 / 0.1 / 0.01 read from `ShaderMaterial` uniforms or `water3d.stats.donor_literals` | DTRN-03 S2, `water3d.gd:19-29,147-168,214-222`; `:837-869` | PASS |
| A9 | `wave_texture_diffusewaves0` — `wave_noise` bound to shipped `diffusewaves0.png` | DTRN-03 S3, `water3d.gd:77-81`; `:871-875` | PASS |
| A10 | `foam_not_added_by_test` — `particle_amount` remains 30; atom writes no shader parameter | DTRN-03 C22/F3, `water3d.gd:29,158`; `:876-882` | PASS |
| A11 | `no_trees_no_mines` — `res_nodes` and `entities` empty | TEST-01:212-215 (P0 baseline), `game.gd:306-315` has no isolation flag; `:884-890` | PASS |
| A12 | `png_full_width_dark_rows` — 0 rows where >90 % of pixels have luma<20, measured on the water-on PNG | V3D_02 T2, DTRN-03 M5, `smallmap_capture.py:27-28`; `:489-517,596-601` | PASS (band is local by fixture design) |
| A13 | `water_alpha_confined_to_cells` — water-on vs water-off capture: 0 projected land-cell pixels changed (ε=3/255), >0 water-cell pixels changed | donor `water.dev.frag:176-183` discard, DTRN-03 M6, V3D_02 T2; `:609-626` | PASS expected; UNVERIFIED if no water pixel is actually sampled |
| A14 | `water_animation_delta` — two captures 1 s apart, fixed camera, >0 changed water-only samples | `water3d.gd:95-99`, `water3d.gdshader:81-82`, TEST_MATRIX.md:42, DTRN-03 M7; `:628-650` | PASS if measurable; **UNVERIFIED, never faked**, if delta ≤ ε |
| A15 | `donor_coarse_swell_present` — `waveheight > 0` | DTRN-03 C28/W1/F1: surface Y = −0.25 ⇒ `clamp(−0.25*3−1.5,0,1)=0`; `:892-901` | **EXPECTED_PRE_FIX_FAILURE** |
| A16 | `no_port_art_shore_prox` — shipped shader text must not contain `shore_prox` | DTRN-03 C29/W3/F3, `water3d.gdshader:209-217`; `:903-913` | **EXPECTED_PRE_FIX_FAILURE** |
| A17 | `no_water_cell_tile0_clamp` — UV2.x=0 count minus grass cells must be 0 | DTRN-03 W2/F2, `world3d_terrain.gd:697-702` (BLK_WATER→tile 0/grass1); `:828-835` | **EXPECTED_PRE_FIX_FAILURE** |

Additional recorded (non-assertion) metrics: water fraction, full UV2.x
histogram, `waveheight_from_donor_literal`, `tile0_excess_over_grass`,
`shader_has_shore_prox`, water-on/off pixel deltas, 1 s animation max delta, PNG
byte counts and capture path. The atom saves a water-on PNG and a t+1 s PNG to
absolute temp paths (defaults under
`C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/test01_smallmap/`),
overridable with `--png=<abs>` / `--png-t1=<abs>` after the runner's second
`--`. The C (water-off) frame is used only for pixel comparison, not saved.

### Capture / lifecycle mechanics

- `extends SceneTree`; all exits are `call_deferred("quit", ...)` (`:281`); never a
  bare `quit()` from `_initialize()` (`tests/README.md:3-33`).
- Windowed-only `SubViewport` GPU readback after `await RenderingServer.frame_post_draw`
  (`:559-589`, P0 precedent), 1280×720, fixed `camera3d.gd` with `_process` disabled,
  capture after ~10 frames (`:690-697,777-785,931-938`).
- Headless guard (`:916-924`): structural checks still run; all seven PNG/pixel
  checks are recorded as `UNVERIFIED`, never as a CPU-fallback PASS
  (`main.gd:1157-1158,1790-1800`).
- Result JSON at `res://tests/results/t_terrain_shore.json` with `verdict` ∈
  `PASS | EXPECTED_PRE_FIX_FAILURE | UNVERIFIED | FAIL`, `passed` true only for
  an unqualified PASS (`:232-281`). Stderr must still be scanned externally with
  `python variant3d\tools\smallmap_capture.py scan-stderr <stderr.txt>`
  (GDScript cannot read stderr; TEST-01 fact 5).

## 5. Expected pre-fix result (do not claim a pass)

Windowed run, before F1/F2/F3 of DTRN-03 land: A1–A14 should pass structurally and
pixel-wise, while **A15–A17 fail** and are tagged `EXPECTED_PRE_FIX_FAILURE`:

1. `waveheight_from_donor_literal = 0` because the classification literal −0.25
   is used as surface Y (DTRN-03 C28/W1, `:174`, shader `:156`) — the donor's
   coarse swell is absent. This atom does **not** add or retune swell.
2. `water3d.gdshader:209-217` still contains the `shore_prox` PORT ART foam
   multiplier (DTRN-03 C29/W3); this atom does **not** edit the shader and does
   **not** add foam (`particle_amount` stays 30).
3. `BLK_WATER=255` cells are clamped to atlas tile 0/`grass1` in UV2.x
   (`world3d_terrain.gd:697-702`), so the UV2.x=0 histogram exceeds the grass-cell
   count (DTRN-03 W2/F2).

Consequently the runner should see `verdict = EXPECTED_PRE_FIX_FAILURE`,
`passed = false`, and exit code 1 — **a truthful failure, not a test bug**.
If A14 has no measurable 1 s delta (sub-pixel framing / sub-threshold noise),
the verdict becomes `UNVERIFIED` for that probe instead of a fabricated PASS.
If any of A1–A13 fails, the verdict is `FAIL`. A second agent must re-check any
capture before this row could be used for a visual statement
(`TEST_MATRIX.md:58`); no donor parity claim is permitted without F0
(`TEST_MATRIX.md:57`).

## 6. Open questions / UNVERIFIED

1. The shared `_smallmap_harness.gd` now exists with the expected
   `make_stub_game(w,h,height,res_nodes,tileblock)` signature, but it is owned by
   another agent and could change. If it changes shape, `_make_stub_game()`
   falls back to the embedded stub; `harness_source` in the result JSON reveals
   which path ran.
2. Will a 1 s `time` step produce a >3/255 pixel delta at the projected water
   samples? `waveheight=0` removes the coarse swell; only the 9-octave ripple
   and wavejitter remain. If not, A14 stays UNVERIFIED.
3. Does the fixed `camera3d.gd` framing (zoom default √(20·58) m, 17.27° FOV,
   −32° tilt) leave enough land-cell centres visible for the A13 differential?
   `_collect_samples()` filters by viewport bounds and records counts; zero
   land samples marks A13 UNVERIFIED.
4. Water-on vs water-off sampling uses projected cell centres, not a full
   depth/mask map; sub-pixel `wavejitter` or water visible behind land at a
   different depth could confound the land-zero expectation. The stored PNG and
   per-sample counts let a second agent re-check.
5. `RV_TRN_03_water_bindings.md` was absent; the `shore_prox` and surface-Y
   findings rest on the shipped shader/source read here plus DTRN-03, not on
   that report.
6. No donor reference frame exists at 64²; the dark-row and alpha-coverage
   criteria are internal consistency checks only.

## 7. No-runner declaration

This agent **authored files only**. No Godot process was launched, no
`godot_runner.py` job was submitted, no ticket was taken, no manifest/config/
fixture/source/shader/asset was edited, and no test was executed. The atom's
expected outcome in §5 is a *prediction from code reading*, not a measurement.
Only the two declared files were written:
`variant3d/tests/t_terrain_shore.gd` and this report.
