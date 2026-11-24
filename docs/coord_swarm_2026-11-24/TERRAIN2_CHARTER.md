# TERRAIN2_CHARTER — understand donor terrain properly (2026-11-24)

Goal: replace "we made a heightfield" with an evidence-based understanding of
how the donor renders terrain, then rank concrete improvements for `variant3d/`.

## Hard rules
- Donor `C:\Games\Cossacks 3` is READ-ONLY private use. Never copy binaries.
- AUDIT/RESEARCH ONLY this wave: no source, config, asset, test or git edits.
- Write EXACTLY ONE report file under `docs/coord_swarm_2026-11-24/reports/`,
  the one assigned to you.
- Every fact needs donor `path:line` (or port `path:line`) evidence. Separate
  OBSERVATION from INFERENCE. Mark unreadable/ambiguous data `UNVERIFIED`.
- Translate donor data; never invent terrain colours, heights, textures or
  constants. If a donor source cannot be parsed, say so and stop.
- Do not claim visual parity. Comparative screenshots require GPU A/B.

## Known current state (do not re-claim as new)
- `variant3d/scripts/world3d_terrain.gd`: ONE full-grid ArrayMesh, 320x320
  cells, 102,400 verts / 203,522 tris, central-difference normals, 0..1
  cell-centre UVs, runtime `Image.load` splat PNG, constant water quad at
  `WATER_LEVEL = -0.25`, donor sun rig from `light.cfg:3-16,26-29`.
- Splat provenance: SHA-256 matches `g32_dump.json`, identical in app/ and
  variant3d/; baked at 1 texel/cell from seed 20261113.
- AUDIT3D-03 gaps: static albedo from ONE dump with no seed/size consistency
  check; flat water quad vs 2D animated `diffusewaves0-2`; no donor fog depth.
- AUDIT3D-08: readable but unused donor sources include `.map` relief marked
  unreadable, `light.cfg`, `colors.lib`, clouds/weather, `terrainmesh1..4.osm`,
  shader text, `hmapTex` UNVERIFIED.

## Assignment map (one report each)
- TERRAIN2-01 `TERRAIN2_01_donor_pipeline.md` — how donor actually builds/renders terrain: map data -> height -> mesh -> textures -> shading; exact files/lines.
- TERRAIN2-02 `TERRAIN2_02_donor_textures.md` — donor terrain texture assets: names, formats, sizes, blend/tiling semantics, what 2D app uses; what can be reused in 3D.
- TERRAIN2-03 `TERRAIN2_03_water_weather.md` — donor water, waves, fog/weather, sky/clouds; contrast with current 3D quad.
- TERRAIN2-04 `TERRAIN2_04_gap_recipe.md` — compare current variant3d terrain against TERRAIN2-01/02/03 findings; ranked P0/P1/P2 donor-grounded recipe with exact source paths.
- TERRAIN2-05 `TERRAIN2_05_leftovers.md` — sweep all session docs/reports/triage for unresolved leftovers and open questions; produce one prioritised to-do list with owners/evidence, excluding items already closed.

## Report template
frontmatter (id, scope, date, status) -> method -> evidence table (path:line)
-> findings -> ranked recommendations -> open questions/UNVERIFIED list.
