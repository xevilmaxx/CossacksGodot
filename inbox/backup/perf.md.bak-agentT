# Perf (GUIDE 3 G8/G15.3)

Machine: container headless, Godot 4.7.2 debug (GDScript interpreted, no
release export). Headless bench = sim-only (`--bench` skips `world.sync`;
minimap/fog intervals pinned). Numbers are wall-measured in this environment.

## CLI growth (boosted start, headless debug)

| sim_seconds | p0 units | p1 units | p0 bldgs | p1 bldgs | gathered (food/gold/stone/wood) | shots | squads |
|---|---|---|---|---|---|---|---|
| 60 (plain) | 8 | 8 | 1 | 1 | none | 0 | 0 |
| 120 | 17 | 17 | 5 | 5 | 114/0/6/162 | 0 | 0 |
| 300 | 31 | 34 | 12 | 5 | 238/0/22/330 | 0 | 0 |
| 300 (mine-rotation fix) | 31 | 34 | 12 | 5 | 238/0/22/330 | 0 | 0 |
| 600 (pre-failover) | 31 | 0 | 12 | 5 | 238/3396/22/330 | 0 | 0 |
| 450 (failover+wide walls) | 40 | 34 | 14 | 5 | 1646/3537/80/584 (+trade 189) | 0 | 0 |
| 600 (failover+wide walls) | 44 | 0 | 16 | 5 | 2432/5034/136/760 (+trade 598, iron 358) | 0 | 0 |

Notes:
- Growth compounds (8→17→31→40→44 units, mines staffed, gold/iron income
  online, pikemen training, market trade) but slowly in debug headless;
  no errors on any run.
- P1 collapses to 0 units by ~600s on this map seed (famine spiral,
  known issue); P0 keeps growing. Waves/shots not observed within 600
  sim-s (force ~50-100 vs gate 120; squads need academy officers first).
- Guide G11 acceptance (>120 units/side at 120s, squads>0) is not met in
  this environment: training throughput is ~1 peasant/12.5s per town hall
  and debug-headless sim runs ~200ms/tick at 600 entities.
- `attack_force` lowered 260→120 (config.json, boost.json) toward livelier
  waves; DEFAULT stays 60 with easy ×0.7 / hard ×1.3 scaling.

## Journey recordings (headless timelapse; windowed journey needs a display)

- `app/shots/j3/`: 27 frames (800×450 CPU map renders, ~2 sim-s cadence over
  60 sim-s boosted CLI), `contact.png` storyboard, `journey.mp4` (h264,
  800×450, 2.7s @10fps, ffprobe-verified). Headless frames are the
  letterboxed sim timelapse per the guide; the windowed `--journey` camera
  follow + battle zoom (G13) is implemented in main.gd but can only be
  visually verified on a machine with a display.
- `app/shots/g3_final.png`: headless CPU map render (terrain/roads/lakes/
  resources/town dots). Real-viewport screenshots need a display.

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
