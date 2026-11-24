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

## GOVERNING RULE (owner, added 2026-11-24)
**Leverage existing DONOR code — do not invent.** Donor is a full 3D game; its
`data\scripts`, `data\cameras`, `data\shaders`, `.osm`/`.oss`/`.aaf`, `light.cfg`,
`env.cfg`, `terrainmesh*.osm` are the source of truth for the 3D variant. Every
3D decision must cite donor path:line or an evidence id; translate donor
algorithms/constants into Godot instead of designing new ones. Read donor
read-only (Python bytes+latin-1); never run donor or copy donor binaries.
UNVERIFIED where unreadable — no invented values.
**Scope: SINGLEPLAYER skirmish only** (D-12): no missions/campaigns/DLC
mission maps/cutscenes/network. Everything else stays documented as deferred.

## NO 2D BAKE PIPELINE IN THE 3D VARIANT (owner, added 2026-11-24)
Owner: "in 3d variant you need models anim pngs? I dont really think so — if its
3d why even need making baking." CORRECT. The 2D port bakes donor meshes into
8-azimuth sprite sheets + per-frame PNG atlases ONLY because it renders with
CanvasItem. A real 3D variant renders MESHES directly:
- **KEEP / NEED**: donor-derived 3D geometry (`.obj` → `.glb`), material/texture
  albedo PNGs (DDS-derived, e.g. `models/tex/**`, `terrain/blocks/**`), texture
  UV data, and ANIMATION data (`.oss` skin payload + `.aaf` action ranges →
  Godot skeletal clips or sampled pose meshes).
- **DEAD WEIGHT — DO NOT PORT/USE**: baked sprite sheets (`anim/**` PNGs,
  `sprites/**`, `sprites_hi/**`), `anim/index.json` sprite metrics,
  `buildings.json` sprite keys, `bake_sprites.py`/`compute_ortho.py` bake outputs.
  Mark those dirs `.gdignore` inside `variant3d/` so Godot never imports them.
- Geometry is resolution-free (V7-2 §3: "baked at 512 px" is N/A for meshes).
- Where donor rig semantics are unreadable (bone parent hierarchy, ACL), V7-2
  marks DONOR-FAITHFUL skinned conversion BLOCKED; the sampled-pose fallback is
  explicitly "PORT APPROXIMATION — NOT DONOR PARITY". Never present it as ported
  donor animation.

## Phase 1 — launch NOW (no dependency on variant3d existing)
| ID | Owned files | Scope |
|---|---|---|
| V7-0 | `variant3d/**` scaffold (new) + `reports/V70_scaffold.md` | Copy project, hardlink assets, own runner, baseline selftest 29/29 |
| V7-1 | `reports/V71_mechanics_inventory.md` only (read-only) | Enumerate EVERY 2D mechanic/test, map to SHARE / ADAPT / NEW for 3D |
| V7-2 | `reports/V72_mesh_conversion_feasibility.md` only (read-only) | 116 converted sids, .oss animation frames, .glb conversion path for 3D units |

## Phase 2 (OPEN — V7-0 landed 29/29 baseline) — disjoint file owners in variant3d
V7-3 main.gd/config.gd/data.gd · V7-4 world3d_full.gd · V7-5 camera3d.gd+input_controller.gd ·
V7-6 hud.gd · V7-7 tests/** · V7-8 meshes/anim3d · V7-9 scenes/shaders/env.

### PHASE-2 ORDER / DEPENDENCIES
- V7-3 first: render_mode seam + relaxed world/camera typing + donor camera.cfg
  constants in config/data. Other phase-2 workers code to the contract V7-3 defines.
- V7-4 and V7-5 in parallel once V7-3's contract is in the report.
- V7-6 (hud minimap box) after V7-5's camera3d API.
- V7-8 (meshes) uses V7-2's verified plan; V7-9 (scene/env) uses donor light.cfg/env.cfg.
- V7-7 last: adapt tests to the 3D world contract, keep SHARE tests verbatim.
- ALL use `python variant3d\tools\godot_runner.py` (own queue). Backups in
  `inbox/backup/` with `-V7xx` suffix. Re-verify all seam line numbers (V7-1 §0
  flagged drift). Donor path:line citations required for every 3D constant.

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

## PHASE 2 ATOMIC SPLIT (owner directive: smallest possible tasks, maximum agents)
Contract: `V73_ATOMIC_CONTRACT.md` (one exact API per new file, no collisions).
Launched in 4 batches, 18 agents total, each owning ONE new file + ONE report:
- V7-11 camera3d · V7-12 picking3d · V7-13 world3d_terrain · V7-14 world3d_entities · V7-15 world3d_fx
- V7-16 world3d_fog · V7-17 hud3d_adapter · V7-18 anim3d
- V7-31..V7-37 atomic tests (terrain/camera/pick/entities/fx/fog/render_mode)
- V7-38 manifest registration · V7-40 docs atoms · V7-41 independent read-only supervision
Integration seams (main.gd / input_controller.gd / hud.gd / world3d.gd) remain for a
FOLLOW-UP batch after module APIs land — one owner per existing file, never parallel.

## PHASE 2 INTEGRATION BATCH (launched after all atomic modules/tests landed)
Four agents, each owning exactly ONE existing variant3d file (no collisions):
- V7-50 main.gd + config.json + data.gd: render_mode default "2d" + make_world3d()/make_camera3d() factories + both construction branches (keeps 2D byte-identical)
- V7-51 world3d.gd: REPLACE legacy M0 world with composition of the 5 landed world3d_* modules + full 2D world contract
- V7-52 input_controller.gd: route screen↔world/pick/pick_res through picking3d.gd only in 3D; cmd_* untouched
- V7-53 hud.gd: minimap box via hud3d_adapter.get_minimap_box() only in 3D
After these land: run variant final gate (29/29 + 17/17 + clean) + t_render_mode (was SEAM_MISSING).

Reports: `reports/V7*.md`. Phase 1 agents launched in parallel; phase 2 waits for V7-0 scaffold.
