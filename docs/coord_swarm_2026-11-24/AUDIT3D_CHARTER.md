# AUDIT3D_CHARTER — variant3d parity audit swarm (2026-11-24)

Purpose: establish an evidence-based gap list between `variant3d/` (3D port),
`app/` (shipping 2D port) and the private-use donor at `C:\Games\Cossacks 3`.

## Hard rules for every audit agent
- Donor is READ-ONLY, private use. Never copy donor binaries.
- AUDIT ONLY for this wave: do NOT edit any source file, asset, config or test.
- Do NOT run git commands (the user owns all commits).
- Write EXACTLY ONE report file, the one assigned to you, under
  `docs/coord_swarm_2026-11-24/reports/`. No other file edits.
- Every finding needs `path:line` evidence. Label anything unreadable or
  inferred as `UNVERIFIED`. Separate OBSERVATION from INFERENCE.
- Rate each gap P0 (blocks acceptance), P1 (visible/functional mismatch),
  P2 (polish). Give the smallest concrete fix that uses donor data rather than
  inventing new art/values.
- Facts already established: donor main view is real 3D perspective; the
  `render_mode` key is a PORT EXTENSION, not donor; 2D remains default in
  `app/`, `variant3d/config.json` now defaults to `"3d"`; 3D modules are
  API/parse/composition verified but visual parity is UNVERIFIED.

## Report template
frontmatter (id, owner, scope, date, status) -> scope/method -> evidence table
-> ranked gap list -> smallest donor-grounded fix -> open questions.

## Assignment map
- AUDIT3D-01 `AUDIT3D_01_models.md` — units/buildings: real 3D donor models vs placeholders
- AUDIT3D-02 `AUDIT3D_02_colors.md` — nation colours / materials / team tint
- AUDIT3D-03 `AUDIT3D_03_terrain.md` — heightmap, splatmap, water, environment textures
- AUDIT3D-04 `AUDIT3D_04_sim_parity.md` — variant3d/scripts vs app/scripts gameplay parity
- AUDIT3D-05 `AUDIT3D_05_camera_hud_pick.md` — camera/picking/HUD seam parity
- AUDIT3D-06 `AUDIT3D_06_fx_anim_audio.md` — FX, animation, audio
- AUDIT3D-07 `AUDIT3D_07_resources.md` — project.godot, .import, hardlinks, broken res:// paths
- AUDIT3D-08 `AUDIT3D_08_donor_coverage.md` — donor data actually consumed vs available/unreadable
- AUDIT3D-09 `AUDIT3D_09_runtime_proof.md` — headless 3D boot/skirmish smoke + actual render evidence
