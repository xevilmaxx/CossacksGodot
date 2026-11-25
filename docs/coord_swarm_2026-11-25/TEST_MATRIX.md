---
title: TEST MATRIX — smallest-map piece → combo → final ladder (2026-11-25)
area: variant3d / testing
owner: COORD (TEST-01 designs details)
updated: 2026-11-25
status: draft
---

# 🧪 Test matrix — 3D terrain & selection

**Rule (owner):** test the smallest piece first; only test the final result at the end.
Every row runs on the **same smallest possible map** so differences are attributable.

## Ladder

| # | Test (one atom each) | Contents | Captures | Measures / pass criteria | State |
|---|---|---|---|---|---|
| P0 | `t_terrain_only` | ground mesh + tile-index atlas + donor shader; **no trees, no shore, no mines** | `<smallmap>_terrain_only.png` | donor ground colour/placement bands, no checkerboard, no seams, correct height | DESIGN BY TEST-01 |
| P1 | `t_terrain_trees` | P0 + donor trees/forest | `<smallmap>_terrain_trees.png` | tree density/scale vs donor; ground still visible between trees | DESIGN BY TEST-01 |
| P2 | `t_terrain_shore` | P0 + shore/water transition | `<smallmap>_terrain_shore.png` | shore mask width, sand/rock selection, shallow/deep colour | DESIGN BY TEST-01 |
| P3 | `t_terrain_mines` | P0 + mines/resource nodes | `<smallmap>_terrain_mines.png` | mine asset, scale/jitter, placement vs donor | DESIGN BY TEST-01 |
| C1 | `t_combo_trees_shore` | P0+trees+shore | PNG | no interaction regressions | DESIGN BY TEST-01 |
| C2 | `t_combo_trees_mines` | P0+trees+mines | PNG | no overlap/placement bugs | DESIGN BY TEST-01 |
| C3 | `t_combo_shore_mines` | P0+shore+mines | PNG | mines not in water; shore masking correct | DESIGN BY TEST-01 |
| C4 | `t_combo_all` | P0+trees+shore+mines | PNG | all criteria together | DESIGN BY TEST-01 |
| S1 | `t_select_rect` | N units on tiny map; synthetic drag | PNG + selection list | expected units selected; no click-pick regression | DESIGN BY TEST-01 |
| F | **FINAL (end only)** | full variant selftest 29/29 + uitest 17/17 + clean + owner visual | — | all gates green | PENDING |

## V3D_02 refinement (landed 2026-11-25) — REUSE EXISTING 64² HARNESS

Do **not** build a new harness. Use `variant3d/tests/fixtures/small_map_64.json`,
`Screenshot3DViewport` capture, fixed seed 20261113, fixed camera, 1280×720, capture after
~10 frames. Baseline from `TERRAIN_SMALL_maps.md:101-121`: 4,096 verts / 7,938 tris /
4,096 UV2 / UV2.x ∈ [0,85] / face_hist `{0:3455,1:311,2:330}` / atlas `(16,8)` /
shadow OFF / 1 water plane. Exact per-row criteria are in
`reports/V3D_02_terrain_render_audit.md` §"Piece-test ladder proposal":

| Row | Extra assertion beyond the table above |
|---|---|
| T0 terrain only | no water/entities/FX/fog overlay; 3 samplers bound; shader `shadow_enabled=0`; non-black >0.9; **no full-width dark rows**; tile-id histogram recorded; flat-fixture regression → 0 promoted faces |
| T1 +trees | only tree meshes; tree Y matches `height_at_world()`; ground texgen unchanged vs T0; draw calls + frame time recorded |
| T2 +shore | exactly ONE height-aware water plane; shore ids in UV2 histogram; water pixel band + alpha coverage; **full-width dark rows = 0**; two frames 1 s apart show water animation; land above water not tinted |
| T3 +mines | mine sid resolves; mine Y matches terrain; ground unchanged outside mine bbox; no z-fighting |
| T4 all combos | all T0–T3 at once, each layer toggleable; no stacked water planes |
| T5 controlled A/B | flip one uniform at a time (`eye_plane_s/t`, `light_position_eye`, `uv_repeat`, `mask_to_alpha`); pixel-aligned changed-pixel count + luma delta; label PORT APPROX until donor frame exists |
| F0 (first!) | repeatable **donor A/B + fixed-camera baseline** — blocks every parity claim |

**Warning from V3D_02:** `t_shore_smoke.gd`, `t_water.gd`, `visual_tuning_test.gd`,
`terrain_piece_render.py` and `tools/pieces/t6_*` are **2D `app/` tooling**, not 3D gates.
Reuse their acceptance ideas (graded shore band, water animation, forest density, mine
display), never their harnesses.

## Execution protocol (COORD, once all atoms have landed)

1. **Wait for disjoint builders to finish** (CFG-01/02, SEL-01) before submitting capture jobs —
   the FIFO runner serializes them anyway, but job ids and queue waits stay readable.
2. **Sequential order, one ticket per row**: `P0 → P1 → P2 → P3 → C1 → C2 → C3 → C4 → S1 → FINAL`.
   Submit the next row only after the previous result JSON exists and its PNG/stderr were
   re-checked by a **second agent** (the owner never self-certifies visual review).
3. **Stop at the first failing row.** A failing row is evidence, not a nuisance: record the exact
   failed assertion and route it to the owning fix ticket. Do not rerun it hoping for green.
4. **Stub rows P0–C4** are windowed (no `--headless`) and pass the PNG path as a user arg after a
   second `--`; headless runs produce `SKIP_CAPTURE` / `passed=false` and are not PASS.
5. **S1** uses the real 64² boot and main's `--screenshot` path (HUD re-shown by the atom).
6. **FINAL** runs last only: variant selftest 29/29 + uitest 17/17 + clean; 2D `app/**` gates
   must remain untouched and green.
7. **Never weaken an assertion** to obtain green; `expected_pre_fix_failure` fields in the atoms
   are deliberate and must stay until the corresponding fix lands.

## Rules for every row
- One Godot at a time: `python variant3d\tools\godot_runner.py run --id <ticket>-<row> --timeout <s> -- ...`
- Repo-root relative paths; Windows `python`, not `python3`.
- Metrics never override visual A/B against donor reference
  (`C:\Users\Maxym.Oboyshev\Downloads\c3\` + donor assets at `C:\Games\Cossacks 3`).
- No piece is declared PASS until a second agent re-checks its capture.
