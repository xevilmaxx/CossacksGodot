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

## Swarm T-01 telemetry — N-07 / E20 gate (2026-11-21)

Two new jobs, both submitted through `app/tools/godot_runner.py run` from the
project root (no direct `godot` invocation). "Wall (Godot)" is the runner's
`run` field (engine process wall time); "Queue wait" is its `wait` field;
"Total" = wait + run. Sources: `app/.godot_queue/results/00000027.json`,
`00000028.json` and their `stdout.txt`/`stderr.txt`.

| metric | command used | runner job id | value | verdict |
|---|---|---|---|---|
| CLI 30 s soak — wall (Godot) | `python app\tools\godot_runner.py run --id agentT-cli30 --timeout 150 -- --headless --path app -- --cli app/cli.json --cli-seconds 30` | agentT-cli30 (ticket 28) | 10.61 s | PASS — no hang; well under 150 s cap |
| CLI 30 s soak — queue wait | same | agentT-cli30 (ticket 28) | 253.43 s | INFO — bounded FIFO wait; other workers' jobs ahead |
| CLI 30 s soak — total submit→finish | same | agentT-cli30 (ticket 28) | 264.04 s | INFO (253.43 + 10.61) |
| CLI 30 s soak — exit status | same | agentT-cli30 (ticket 28) | 0 / `ok` | PASS |
| CLI 30 s soak — sim time reached | same | agentT-cli30 (ticket 28) | 30.0 s (`sim_seconds` in app/cli.json) | PASS — `--cli-seconds 30` overrides config's 60 s |
| CLI 30 s soak — state at exit | same | agentT-cli30 (ticket 28) | kills 0, shots 0, winner -1, p0/p1 10 units + 1 building each | PASS — clean, no stuck loop |
| CLI 30 s soak — stderr | same | agentT-cli30 (ticket 28) | empty (0 lines) | PASS |
| Self-test — wall (Godot) | `python app\tools\godot_runner.py run --id agentT-selftest --timeout 180 -- --headless --path app -- --self-test app/selftest.json` | agentT-selftest (ticket 27) | 25.88 s | INFO — under 180 s cap |
| Self-test — queue wait | same | agentT-selftest (ticket 27) | 227.62 s | INFO — bounded FIFO wait |
| Self-test — total submit→finish | same | agentT-selftest (ticket 27) | 253.50 s | INFO (227.62 + 25.88) |
| Self-test — exit status | same | agentT-selftest (ticket 27) | 1 / `failed` | **FAIL** — E20 gate red |
| Self-test — steps passed | same | agentT-selftest (ticket 27) | 27/28; only `farm_cap` failed (farm 500 → 500 → 500), see `app/selftest.json` | **FAIL** — matches open ticket P-04; not fixed here (game.gd is A-01's file) |
| Self-test — stderr | same | agentT-selftest (ticket 27) | 9 ObjectDB instances leaked, 2 resources still in use at exit | WARN — non-fatal |
| Headless FPS (these two jobs) | neither command emits an FPS metric | agentT-cli30 / agentT-selftest | not measured | NOT MEASURED — `--bench` was not part of these jobs |
| Windowed FPS / headless parity | no display attached | — | not measured | OPEN — needs a display; see parity note below |
| Runner anti-starvation telemetry | `python app\tools\godot_runner.py status` | n/a (runner status) | after these jobs: completed 31, max wait 256.60 s, mean wait 95.89 s, max run 60.43 s | INFO — bounded waits, FIFO held |

### Windowed / headless parity

- Both jobs used `--headless` as instructed. Headless exercises simulation,
  economy, pathing and combat, but not rendering-dependent work (`world.sync`,
  screenshots, the windowed `--journey` camera follow). Parity of the *picture*
  between headless and windowed is therefore **not proven**.
- This environment has no display, so windowed FPS and the windowed camera
  follow were **not measured**. QA (O-01) must check those on a display-capable
  machine. Do not read the historical 1.19 fps headless `--bench` row above as
  a windowed FPS figure — it is a prior, separate measurement.

### How to reproduce (evidence, not a claim)

1. From the project root run the two `python app\tools\godot_runner.py run ...`
   commands shown in the table verbatim. Never call `godot` directly.
2. The runner prints `ticket N 'id' START (waited Xs)` / `END status (run Ys)`.
3. Read `app/.godot_queue/results/<ticket>_<id>/stdout.txt` and `stderr.txt`,
   plus `app/.godot_queue/results/<ticket>.json` for `wait`, `run`, `exit` and
   `status`. Step-by-step self-test results are in `app/selftest.json`; the CLI
   job overwrites `app/cli.json` with its 30 s snapshot (expected behaviour).
4. Run `python app\tools\godot_runner.py status` for queue wait statistics.
   Every number above was copied from these files. No FPS value was inferred.

### Gate note and export-config cross-reference

- E20 cannot be signed on this evidence alone: self-test is red (27/28,
  `farm_cap`). It should stay blocked until A-01/P-04 closes and a fresh
  `agentT-selftest`-style run reports 28/28.
- Export audit (T-01): three desktop presets exist — Windows Desktop, Linux,
  macOS — with symmetric, platform-appropriate options and no Windows-only
  setting that would break Linux/macOS export. The only edit was replacing the
  macOS placeholder `com.example.cossacks-singleplayer` with
  `com.cossacksgodot.singleplayer`; no new target or SDK was introduced.
  Actual export still requires the matching export templates installed on the
  exporting OS (external dependency, not changed here).
