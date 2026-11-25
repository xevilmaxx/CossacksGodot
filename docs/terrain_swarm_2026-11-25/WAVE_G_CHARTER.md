---
id: TERRAIN-SWARM-WAVE-G
title: "Standing wave — 20 agents for implementation repair, QA, capture, docs and monitoring"
owner: COORD
created: 2026-11-25
status: ACTIVE
---

# WAVE G — standing swarm (minimum 20 agents)

Read `docs/terrain_swarm_2026-11-25/CHARTER.md` first. Guardrails from it remain binding:
observe/derive/infer/UNVERIFIED separation, no test weakening, no synthetic dither/noise,
no donor-parity claim, disjoint file ownership, backups before edits.

## Current state (COORD, at Wave G launch)

Wave A-F (38 agents) all delivered. Six implementation owners landed edits:
- B01 shader: mirror/warp, half-texel inset, `textureGrad`, sentinel-black guard, mask contrast compression, linear mipmap filter.
- B02 atlas loader: real mip chain generated at runtime + `.import` mipmaps=true.
- B03 game.gd: test7/test8 donor re-roll, `tile` stamps as ground1 pre-smoothing, grass_ground1/2/3 -> grass9/test8/test7 redirect.
- B04 world3d_terrain.gd: relief-aware face promotion (PORT APPROX), invariants preserved.
- B05 input_controller.gd: Rect2(position,size) bug fixed, stuck-quad cleanup, event->camera viewport mapping, canvas inverse, D05 low-risk UI fixes. COORD fixed two parse errors after B05 (`:621` typed `dst: Viewport`, `:876` `KEY_CTRL`).
- B06 world3d_fx.gd: ghost resolves finished base mesh first, stage 4 fallback, node renamed GhostBuildingFinished.

COORD also fixed `variant3d/tests/t_select_rect.gd:525` to `Rect2(_p0, _p1 - _p0).abs()`.

**Blocked at gate:** the first selftest (ticket 583) failed on B05's two parse errors; they are fixed now and a re-run is needed. Runner counter was desynced by `unwedge`; COORD reset `now_serving=583`. 2000 bogus `skipped` result JSONs were deleted.

## Standing rules

- **Only G04 submits runner jobs.** All other Wave G agents MUST NOT run Godot or submit runner jobs. This protects the FIFO/one-Godot rule.
- Report root: `docs/terrain_swarm_2026-11-25/reports/`; one file per agent unless stated.
- When your report lands, COORD may send a follow-up via the same session; stay available for that follow-up.

## Assignments

| ID | Scope | Output |
|---|---|---|
| G01 | Author `variant3d/tests/t_select_rect_capture.gd` from D03 proposal (NEW file only) | new file + `G01_select_capture_atom.md` |
| G02 | Author `variant3d/tests/t_ghost_final_stage.gd` from E04 proposal (NEW file only) | new file + `G02_ghost_atom.md` |
| G03 | Re-audit `t_select_rect.gd` for other stale wrong expectations after COORD's :525 fix | `G03_test_audit.md` |
| G04 | **Sole runner owner**: re-run selftest/uitest/t_render_mode + windowed P0 and real-map captures with unique ids | `G04_gate_log.md` |
| G05 | Visual review of the new captures using C04 protocol + C01 metric tool | `G05_visual_review.md` |
| G06 | Evaluate A07 colour correction options against the new frame | `G06_color_eval.md` |
| G07 | A05 Fix #1 feasibility: donor-active relief grids (ravine_big) as a future ticket | `G07_relief_plan.md` |
| G08 | Camera-follows-drag (F03 G1) proposal, disjoint from B05's file | `G08_camera_follow.md` |
| G09 | Ghost footprint honesty: donor `.prop` mask vs radius (F05) proposal | `G09_footprint.md` |
| G10 | Consolidate all 38 reports into a cold-readable swarm README | `README.md` (new) |
| G11 | Read-only monitor: 2D `app/` gates and untouched state | `G11_2d_monitor.md` |
| G12 | Read-only monitor: runner hygiene (locks, bogus results, counter alignment) | `G12_runner_monitor.md` |
| G13 | Read-only audit: all B backups + COORD's test fix; disjoint ownership | `G13_backup_audit.md` |
| G14 | Static shader/GDScript audit of all six edited files (no runner) | `G14_static_audit.md` |
| G15 | Measure new tile histogram from dumps / world stats vs A04 baseline | `G15_tile_measure.md` |
| G16 | Season atlas/manifest consistency after B02 mipmap change | `G16_season_check.md` |
| G17 | Performance budget audit of new shader `textureGrad`/mirror + mip chain | `G17_perf_audit.md` |
| G18 | Donor bug "do not copy" register maintained from F04/D05/F03 | `G18_donor_bugs.md` |
| G19 | UI hotkeys/control-group gaps vs donor guides (D05/F03), proposal only | `G19_hotkeys.md` |
| G20 | Gate failure triage: parse/gate/selftest failure analysis from result JSONs | `G20_triage.md` |

## Wave P — PERFORMANCE (owner directive, same session)

Owner: *"improve performance of the game, FPS are too low even on start; something badly
compromises performance or a combination of many things."* G17 already found: full mip
chain for the 16384×8192 atlas = +171 MiB / +33% VRAM and a synchronous main-thread
mip generation stall during loading. That is one suspect, not the whole answer.

Standing rule unchanged: **only G04 runs Godot/runner jobs** (and only the already
prepared gates). Performance agents must NOT submit jobs; they analyse, propose, and
(disjointly) implement. Every claim needs file:line evidence; measured FPS claims
require a real capture/run and are UNVERIFIED without one.

| ID | Scope | Output / exclusive file |
|---|---|---|
| P01 | Code-level FPS hotspot inventory: `_process`/`_physics_process` loops, per-frame allocations, node traversal across all variant3d scripts | `reports/P01_frame_hotspots.md` |
| P02 | Rendering/draw-call audit: world3d_entities.gd mesh batching, instance counts, transparency overdraw, shadow/cast flags | `reports/P02_draw_calls.md` |
| P03 | Animation/CPU audit: anim3d.gd flat-root morph pose sampling per entity per frame; cache opportunities | `reports/P03_anim_cpu.md` |
| P04 | HUD/minimap audit: hud.gd + hud3d_adapter.gd per-frame redraws, polling, string formatting | `reports/P04_hud_cost.md` |
| P05 | Terrain/water shader cost beyond B01/B02: per-fragment work, overdraw, face branches | `reports/P05_shader_cost.md` |
| P06 | Loading-path audit: main.gd async stages, atlas build/mip generation, blocking work and overlay lifetime (G17/G23) | `reports/P06_loading_path.md` |
| P07 | Scene/node-count audit: world3d.gd + main.gd tree size, hidden-but-present nodes, duplicate rigs | `reports/P07_node_count.md` |
| P08 | Quality/config levers: which existing knobs actually reduce cost without changing art; propose safe defaults for weak GPUs | `reports/P08_quality_knobs.md` |
| P09 | Performance measurement plan: exact capture/telemetry needed to measure real FPS on this MX130 machine, without new GPU claims | `reports/P09_measurement.md` |
| P10 | IMPLEMENT (disjoint): `variant3d/scripts/anim3d.gd` only — pose caching / allocation removal | `anim3d.gd` + `reports/P10_anim_fix.md` |
| P11 | IMPLEMENT (disjoint): `variant3d/scripts/world3d_entities.gd` only — draw-call/instance reduction | `world3d_entities.gd` + `reports/P11_entities_fix.md` |
| P12 | IMPLEMENT (disjoint): `variant3d/scripts/hud.gd` + `hud3d_adapter.gd` only — redraw/poll reduction | those files + `reports/P12_hud_fix.md` |

Backups required before any P10-P12 edit: `inbox/backup/<name>.bak-P1X`. No test weakening.

## Wave M — MILL ROTOR (owner directive, same session)

Owner: *"mill rotor seems maybe on wrong side of the mill or in the middle of it; needs to
be positioned on an appropriate tip, and maybe facing the user view so not viewed from
behind. Maybe you even need to rotate the whole mill."*

| ID | Scope | Output |
|---|---|---|
| M01 | Audit current mill/rotor placement + transform + view logic | `reports/M01_mill_rotor_audit.md` |
| M02 | Donor truth: rotor attach point, axis, whole-mill yaw/camera-facing/wind | `reports/M02_donor_mill.md` |
| M03 | Ready-to-apply fix proposal (NO edit while G04 gates run) | `reports/M03_mill_fix_proposal.md` |
| M04 | Decisive QA atom proposal + windowed capture design | `reports/M04_mill_qa.md` |

`variant3d/scripts/world3d_entities.gd` is shared contest: M03 (mill) and P11 (draw calls)
both propose changes there. COORD grants exclusive ownership AFTER G04 finishes and after
both proposals land; neither agent may edit before that grant.

## Wave H — HEIGHTMAP LAYERS (owner hypothesis, same session)

Owner: *"We need to understand how to use heightmap — one of the terrain layers, the one
that produces strange patterns, should not be visible but used for heightmap only."*

This is a hypothesis, not a fact. It must be tested against donor evidence and our code,
not assumed. Candidate layers to examine: terrainmask TGA R/G/B channels, the donor
`tile_lowground.bmp` / `tile_highground.bmp` detail bitmaps, alpha/alphavert masks, `.map`
height bytes, pattern float32 relief grids, and our `game.height` / `tileblock` arrays.

| ID | Scope | Output |
|---|---|---|
| H01 | Trace every terrain layer in donor: which is height, which selects tile identity, which is blend alpha; cite path:line | `reports/H01_donor_layers.md` |
| H02 | Trace every terrain layer in our port: where each is loaded, whether it is drawn as albedo or consumed as height/mask | `reports/H02_port_layers.md` |
| H03 | Test the owner's hypothesis: is any pattern-producing layer in our render actually a height/mask source in donor? Prove or refute with evidence | `reports/H03_heightmap_hypothesis.md` |
| H04 | If confirmed: exact ready-to-apply fix proposal (layer -> height input, remove from albedo), with owner files and gates | `reports/H04_heightmap_fix.md` |
| H05 | If refuted: explain the real cause of the patterns and why the heightmap route would not fix them | `reports/H05_refutation.md` |

Read-only only; NO code edits and NO runner jobs (G04 still owns Godot).

## Wave F2 — MILL FIELDS + MINE MAGNETIC SNAP (owner directives, same session)

Owner: *"mill fields, make them bigger so they come in contact with each other"* and
*"mines when placed on correct spot use magnetic snap for correct positioning when
building the mine on it."*

| ID | Scope | Output |
|---|---|---|
| F2-01 | Audit current mill-field/farm placement geometry and why fields do not touch | `reports/F2_01_mill_fields_audit.md` |
| F2-02 | Donor truth: field size, spacing, adjacency around mills; mine deposit footprint + placement snap | `reports/F2_02_donor_fields_mines.md` |
| F2-03 | Mill-field enlargement fix proposal (bigger fields, touching, no overlap with other buildings) | `reports/F2_03_fields_fix.md` |
| F2-04 | Mine magnetic-snap fix proposal: when building a mine, snap the ghost/placement to the deposit centre | `reports/F2_04_mine_snap.md` |
| F2-05 | QA atom proposals for both (one report) with windowed captures and acceptance checks | `reports/F2_05_qa.md` |

All read-only/proposal only while G04 runs gates. COORD grants exclusive file owners after
G04 finishes. No runner jobs, no donor-parity claims.

## Wave S — SPEED OPTIONS (owner directive, same session)

Owner: *"and x8 for ui speeds add x16 speeds and maybe even x32 and x64."* The UI speed
dropdown currently tops out at x8. Add higher multipliers safely.

| ID | Scope | Output |
|---|---|---|
| S01 | Audit speed pipeline: dropdown options in `hud.gd`, config key, main.gd time-scale application, limits/caps, tests | `reports/S01_speed_audit.md` |
| S02 | Ready-to-apply proposal for x16/x32/x64 options, preserving x1..x8 defaults and all tests, with exact file:line hunks | `reports/S02_speed_fix.md` |
| S03 | QA atom proposal + windowed capture for verifying each new speed actually changes sim rate | `reports/S03_speed_qa.md` |

Read-only/proposal only while G04 runs gates. `hud.gd` is also P12's proposed file — COORD
grants one owner after G04 finishes; no cross-touch.

## Wave N — NATION OBJECT ASSOCIATIONS (owner directive, same session)

Owner: *"initial hall object of Russian nation should be different; check association of 3D objects to nations correctness; also peasants are of different form."*

| ID | Scope | Output |
|---|---|---|
| N01 | Audit building sid -> nation mapping in variant3d vs app 2D; find the Russian starting hall's actual mesh | `reports/N01_nation_building_audit.md` |
| N02 | Donor truth: Russian starting hall sid/model, nation-specific peasant mesh/sid, nation object naming | `reports/N02_donor_nation_objects.md` |
| N03 | Audit peasant unit mesh/sid per nation: are different nations using one form? | `reports/N03_peasant_forms.md` |
| N04 | Ready-to-apply fix proposals (no edits until COORD grants) | `reports/N04_nation_fix.md` |
| N05 | QA atom proposal + windowed capture for nation-specific hall and peasants | `reports/N05_nation_qa.md` |

Read-only/proposal only; no runner jobs. 2D `app/` is the secondary reference, donor is primary.

## Wave BLD — MINE FOOTPRINT + BUILDER TRAPPING (owner directives, same session)

Owner: *"when building mine it +- should be same size of mine on the map — now it's about twice; and during building it traps builders inside and they cannot finish it — avoid builders being trapped in the building mesh during build; they can walk only around."*

| ID | Scope | Output |
|---|---|---|
| BLD-01 | Audit mine ghost footprint/`can_place` radius vs the placed mine's actual mesh/collision footprint; find the ~2x mismatch | `reports/BLD_01_mine_footprint.md` |
| BLD-02 | Audit builder work positions during construction: spawn points, pathing, collision mask, why they end up inside the mesh and stall | `reports/BLD_02_builder_trap.md` |
| BLD-03 | Ready-to-apply fix proposals for both (no edits until COORD grants) | `reports/BLD_03_fix.md` |
| BLD-04 | QA atom proposals for footprint size and builder completion | `reports/BLD_04_qa.md` |

Read-only/proposals only; no runner jobs. Donor is primary; label PORT APPROX.

*End of Wave G/P/M/H/F2/S/N/BLD charter.*
