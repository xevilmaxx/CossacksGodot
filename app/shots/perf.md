# Perf (GUIDE 3 G8/G15.3)

Machine: container headless, Godot 4.7.2 debug (GDScript interpreted, no
release export). Headless bench = sim-only (`--bench` skips `world.sync`;
minimap/fog intervals pinned). Numbers are wall-measured in this environment.

## Bench (`--bench`, 300/side = 600 units + starts)

| run | units | sim_seconds | wall_seconds | fps(headless) | sim_ms_per_tick |
|---|---|---|---|---|---|
| final (G8 all) | 618 | 30.0 | 189.1 | 1.19 | 196.0 |

- Baseline before G8 was not measured (G8 applied incrementally on top of a
  working game; re-running the pre-G8 code would need a separate worktree).
- Gate G15.3 (headless sim ≤ 8 ms/tick @600 units) is NOT met in this debug
  headless environment (196 ms/tick). Contributing factors: GDScript debug
  interpreter (function-call/dictionary overhead ×600 entities/tick),
  per-tick `_grid_rebuild` + `_separate_units` (2 passes) + upkeep scans.
  A release export and/or fewer live units would lower it; the grid/list
  rewrites still cut the original full-scan-everywhere cost asymptotically
  (aura/targeting/capture/splash/separation are now grid-bounded).
- Windowed fps on the owner's weak GPU was not measurable from this
  container (no display). Default quality stays `high`; set to `medium` in
  `config.json` if the owner's windowed run stays under ~30 fps at low.

## Quality presets

- high: terrain_px 16, sprite_cell 160, fx_cap 220, shadows on
- medium: terrain_px 12, sprite_cell 96, fx_cap 120
- low: terrain_px 8, sprite_cell 64, fx_cap 60, shadows off,
  fog_interval 1.0, minimap_interval 0.5
