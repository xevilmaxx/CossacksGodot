# Wave 7 — full Godot 3D variant with ALL 2D mechanics (owner directive 2026-11-24)

Owner: "for 3d variant duplicate all game mechanics you invented for 2d world,
just make a 3d variant; it may be a separate project or same with 3d variant
branch and its own tests and so on."

## Architecture decision (coordinator)
**Separate Godot project inside this repo: `variant3d/`.**
- Full copy of `app/` scripts/tests/tools/configs/scenes/shaders (real copies — the
  3D branch must diverge without touching shipping 2D).
- Assets hardlinked from `app/assets/**` (2.31 GiB, 7,846 files — no disk duplication);
  `.import` files copied as REAL files (Godot may rewrite them; must not affect 2D).
- Own `project.godot` (3D renderer), own `tools/godot_runner.py` → own
  `variant3d/.godot_queue/` FIFO, own selftest/uitest JSONs, own docs under
  `docs/variant3d/`. No contention with wave 5/6 runner jobs.
- Reuse the simulation/generator/AI/orders/save-load VERBATIM (R-ARCH
  PORT_FEASIBILITY §"SHARE"); only the renderer/picking/HUD-camera seams change.

## Seams to implement (from RENDER_ARCH_PORT_FEASIBILITY.md, all read + RE-VERIFIED)
1. `main.gd` world/camera construction (:400-430, :553-594) + static `C3World`/`C3Camera` typing (:44-46)
2. `world3d.gd` full world contract: bind/sync/view_scale/world_to_px/fx_layer/view_rect/fog
3. `camera3d.gd` perspective + clamp/zoom-at-cursor in metres
4. `input_controller.gd` screen→world raycast + entity picking (cmd_* calls unchanged)
5. `hud.gd` minimap viewport box from 3D camera (get_camera_2d() null)
6. Terrain heightmap mesh from `game.height[]` (wave 6 G3-2 foundation)
7. Units/buildings/trees 3D meshes + animation (M2/M3 in the study)
8. FX/projectiles/ghosts in 3D; fog shading; water plane

## Phase 1 — launch NOW (no dependency on variant3d existing)
| ID | Owned files | Scope |
|---|---|---|
| V7-0 | `variant3d/**` scaffold (new) + `reports/V70_scaffold.md` | Copy project, hardlink assets, own runner, baseline selftest 29/29 |
| V7-1 | `reports/V71_mechanics_inventory.md` only (read-only) | Enumerate EVERY 2D mechanic/test, map to SHARE / ADAPT / NEW for 3D |
| V7-2 | `reports/V72_mesh_conversion_feasibility.md` only (read-only) | 116 converted sids, .oss animation frames, .glb conversion path for 3D units |

## Phase 2 (after V7-0 lands) — disjoint file owners in variant3d
V7-3 main.gd/config.gd/data.gd · V7-4 world3d_full.gd · V7-5 camera3d.gd+input_controller.gd ·
V7-6 hud.gd · V7-7 tests/** · V7-8 meshes/anim3d · V7-9 scenes/shaders/env.

## Gates
Every phase-2 worker: backup, variant3d runner only, targeted test, one report.
Coordinator final gate in variant3d: selftest 29/29 + uitest 17/17 + clean.
2D gates in app/ remain green (last verified jobs 1289/1290).

## Phase 1 session ids
| ID | Session |
|---|---|
| V7-0 | ses_df2e3adb8ffeql0mmxDCG5BTBv |
| V7-1 | ses_df2e3adb2ffeosBotjEFKc5ynL |
| V7-2 | ses_df2e3adafffeL6vMnrTm0zslC3 |

Reports: `reports/V7*.md`. Phase 1 agents launched in parallel; phase 2 waits for V7-0 scaffold.
