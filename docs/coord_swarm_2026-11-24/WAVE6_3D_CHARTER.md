# Wave 6 — parallel Godot 3D heightmap variant (owner directive 2026-11-24)

Owner: "in parallel try to develop godot 3d variant, and for terrain generation
instead of reasoning per chunk leverage heightmap concept, maybe donor were full
3d game with just optimized 2d perspective?"

## Context (prior R-ARCH evidence, to be RE-VERIFIED not assumed)
- Donor IS a full 3D OpenGL game: perspective camera (focal 400, tilt −32°,
  height 20–58), lit heightfield, GLSL shaders, skinned meshes (`docs/audit/
  RENDER_ARCH_SYNTHESIS.md`, `RENDER_ARCH_CAM.md`, `RENDER_ARCH_TERRAIN.md`).
- The existing M0 3D sandbox (`app/scripts/terrain3d_sandbox.gd`, `world3d.gd`)
  used a BLOCK-by-block heightfield with per-tile quads + vertical walls and was
  CLOSED on visual FAIL (M0.6): flat blocky mosaic, no organic relief or scene
  content. Its expected dump `app/shots/final_fullmap_dump.json` NO LONGER EXISTS.
- NEW APPROACH (owner): build ONE heightmap mesh from the full `game.height[]`
  grid (320×320 ≈ 102k verts / 204k tris — trivial for a GPU), with donor block
  albedo via texture splat/vertex colour, instead of 100 cached chunk sprites.

## Scope rule
This is a PARALLEL EXPERIMENT. The shipping 2D renderer (`world.gd`) is NOT
touched. All wave-6 files are NEW and disjoint from wave 5 (which owns ai.gd,
main.gd, selftest.gd, world.gd, camera.gd, t_hud_fidelity/uitest, w5 shots).

## Ownership (all new files)
| ID | Owned files | Scope |
|---|---|---|
| G3-1 | `reports/G31_donor_3d_truth.md` only (read-only) | Re-verify donor 3D/perspective/heightfield truth + M0 failure causes; 2D-perspective optimisation question; exact height data source & resolution |
| G3-2 | `app/scripts/heightmap_world3d.gd`, `app/scripts/heightmap3d_sandbox.gd` (new) + report | One full-map ArrayMesh from height[] grid, donor albedo, perspective Camera3D, light; capture 1280×720 through runner |
| G3-3 | `app/tools/heightmap3d_shot.py` (new) + `app/shots/hm3d_*.png` + report | Capture/compare harness for G3-2; honest visual A/B vs donor reference |
| G3-4 | `app/tools/heightmap_splat.py` (new) + `app/assets/terrain/heightmap/**` + report | Build a splat/albedo texture from donor blocks mapped to terrain types for G3-2 |

G3-2 needs a fresh dump: generate with its own runner id (`g32-dump`), e.g.
`python app\tools\godot_runner.py run --id g32-dump --timeout 200 -- --headless --path app -- --dump-map app/shots/g32_dump.json --seed 20261113`.
Runner is shared with wave 5 — expect FIFO waits; do NOT re-submit while pending.

## Session ids
| ID | Session |
|---|---|
| G3-1 | ses_df2e9a530ffeL2zKIt2f17w2VQ |
| G3-2 | ses_df2e9a52cffeXcHf74khlDH5OO |
| G3-3 | ses_df2e93b48ffeb8ou93EfZyWtiX |
| G3-4 | ses_df2e93b44ffegD2caM5jkc6Olb |

Reports: `reports/G3*.md`. No full gate for this experiment; coordinator owns merge decisions. All 4 agents launched in parallel; shared runner is FIFO-contended with wave 5 — unique `g3*-` job ids, no re-submits while pending.
