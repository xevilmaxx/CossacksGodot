# PLAYABILITY2_CHARTER — remaining real-play gaps (2026-11-24)

The user reports, after actually playing the 3D variant:
1. map/minimap navigation still not OK;
2. mill has no propeller;
3. unclear whether peasants have good/correct animations;
4. unclear whether the mill generates fields;
5. terrain still has strange artifacts even after shadows were disabled;
6. no phantom/ghost preview when placing a building;
7. "there is so much to do still".

## Hard rules
- READ-ONLY for this wave. No source, asset, config, test or git edits. No Godot
  launches (the runner is busy). Read current source and existing result files.
- One report per agent under `docs/coord_swarm_2026-11-24/reports/`, exactly the
  assigned file.
- Every claim needs current `path:line` evidence or a job id/result. Treat prior
  claims as UNDONE until verified in current source.
- Separate root cause from proposed fix. No visual-parity claims.

## Assignment map
- PLAY2-01 `PLAY2_01_minimap_nav.md` — minimap/map navigation end-to-end.
- PLAY2-02 `PLAY2_02_mill_fields.md` — mill rotor + field generation.
- PLAY2-03 `PLAY2_03_animations.md` — peasant animation data actually consumed/correct.
- PLAY2-04 `PLAY2_04_build_ghost.md` — building placement phantom preview.
- PLAY2-05 `PLAY2_05_terrain_artifacts.md` — non-shadow terrain artifacts.
- PLAY2-06 `PLAY2_06_roadmap.md` — synthesis + dependency-ordered fix waves (read available peer reports once, no polling).

Each report: evidence table, root cause, exact smallest fix with file ownership,
acceptance probe, and UNVERIFIED list.
