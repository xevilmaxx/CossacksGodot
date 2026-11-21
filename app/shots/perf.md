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

## Swarm QA-1 — TR-6 chunk-bake hitch (N-07) — 2026-11-21

**Verdict: UNVERIFIED. No max single-frame chunk-bake number exists to record.**
The N-07 target (`SWARM_BACKLOG.md:44`, `TERRAIN_PORT_RENDER.md:72,114,132,154-157`)
is **max single-frame chunk-bake time < 250 ms on the LOW preset over 120 frames,
with `built >= 2` chunks/frame and LRU 24**. Rows :92-93 above stay `not
measured`; there is no honest number to replace them with yet.

### Exact blocker (all four are source-verified)

1. **No bake-timing instrumentation exists.** `world.gd::_build_chunk`
   (`world.gd:950-1061`) and `_sync_terrain_chunks` (`world.gd:1063-1088`) contain
   no `Time.get_ticks_*` or `print` call. Repo-wide grep of every `.gd` file finds
   no per-bake timing emitter; the only print in `world.gd` is the one-time
   `sprites: N sets loaded` at `:256`. No runner log in
   `app/.godot_queue/results/` contains a chunk-bake time.
2. **QA-1 cannot add the instrumentation.** All `.gd` files are read-only for this
   worker; `world.gd` is owned by RENDER-1, `main.gd` by BUILDER-MAIN
   (`AGENT_PROTOCOL.md §0`). TR-1's acceptance (`TERRAIN_PORT_RENDER.md:132`)
   already assigns "instrument `_build_chunk`" to world.gd's owner.
3. **`--bench` cannot observe bakes.** `main.gd:1000` explicitly skips
   `world.sync()` when `bench_mode and is_headless`, so headless `--bench` never
   calls `_sync_terrain_chunks`. Its report (`main.gd:989`) carries only
   `fps`/`sim_ms_per_tick`, not bake time.
4. **The only emitted timing is not the metric.** `main.gd:971-973` prints
   `PERF ... sync_ms=X` — the **mean of TOTAL `world.sync()` over 120 frames**
   (all entity/decor/fog drawing, not just bakes), not a per-frame maximum. It
   is logged below as **context only** and is never used to pass N-07.

### What was run (all through `app/tools/godot_runner.py run`; no direct `godot`)

| purpose | runner job id | ticket | result | note |
|---|---|---|---|---|
| LOW-preset 120-frame bench | `qa1-bench-2` | 626 | `ok`, exit 0; run 12.96 s, queue wait 35.66 s | clean run: 0 stderr errors, 116 sprite sets loaded |
| confirm effective settings | `qa1-bench-config2` | 623 | `ok`, exit 0; run 1.59 s | `--dump-config` output confirms low preset (below) |
| failed setup (discarded) | `qa1-bench-1` / `qa1-bench-config` | 620 / 621 | `ok` but **wrong preset** | relative `--config app/shots/perf_low.json` was not resolved by `config.gd::_candidate_paths`; stderr: `settings: extra settings file not found: app/shots/perf_low.json`. It ran on `quality: high` — **do not use its 59.79 ms figure**. Fixed by passing an absolute config path. |

Harness: `app/tools/bake_bench.py` (new, owned by QA-1) drives the runner and
parses stdout. Overlay: `app/shots/perf_low.json` (new, owned by QA-1). Command
for the valid run, from the project root:

```
python app/tools/bake_bench.py --id qa1-bench-2 --timeout 240 --max-wait 3600 --frames 120
# wraps: python app\tools\godot_runner.py run --id qa1-bench-2 --timeout 240 --max-wait 3600 -- \
#   --headless --path app -- --config <abs>/app/shots/perf_low.json \
#   --screenshot <temp>/qa1_bake_bench.png --screenshot-frames 120 --timeout 210
```

### Settings in force during `qa1-bench-2` (verified, not assumed)

- Overlay `app/shots/perf_low.json` passed by **absolute path** (a relative path
  silently fails — see failed setup row). `--dump-config` (ticket 623) reports
  `quality: low`, `terrain_px: 8`, `sprite_cell: 64`, `fx_cap: 60`,
  `fog_interval: 1`, `minimap_interval: 0.5`.
- 2-chunks/frame cap — `world.gd:1078-1079` (`if built >= 2: return`).
- LRU 24 — `world.gd:1083-1088` (`while terrain_order.size() > 24`).
- `TERRAIN_PX = 8` (low preset). Source-read by QA-1; **no `.gd` file was edited**.

### Observed context (NOT the gate metric)

- `qa1-bench-2` stdout: `PERF tick_ms=1.23 ai_ms=0.55 sync_ms=17.37
  steps_per_frame=0.3 redraws r/b/u/f=5/5/120/120`.
- `sync_ms=17.37` is the **mean of total headless `world.sync()`** across 120
  frames on the low preset. It is neither a maximum nor bake-only, and a
  headless CPU-render run says nothing about GPU/windowed FPS. **It is not a
  PASS of N-07 and must not be quoted as one.**

### How to close TR-6

1. RENDER-1 (world.gd owner) adds instrumentation inside
   `_sync_terrain_chunks`/`_build_chunk`: time each bake with
   `Time.get_ticks_usec()`, keep the max over the first 120 frames, and print a
   single parseable line, e.g.
   `BAKE_BENCH preset=low px=8 chunks=120 max_ms=<n> mean_ms=<m>`.
2. Re-run `python app/tools/bake_bench.py --id qa1-bench-3 ...` (same overlay and
   absolute path). The tool parses `BAKE_BENCH ... max_ms=` and emits
   **PASS** if `< 250`, **FAIL** otherwise; with no such line it stays
   **UNVERIFIED** and never invents a value.
3. Replace this section's verdict with the measured number and job id.

**Scope:** headless, CPU-only, sim + `world.sync()`. No general FPS or GPU claim
is made from these runs.

### Result update (2026-11-21, follow-up) — instrumentation now present — **FAIL**

The UNVERIFIED verdict above is **superseded**: RENDER-1 added a one-shot
`BAKE_BENCH` print to `world.gd::_sync_terrain_chunks` (`:100-108`, `:1162-1174`,
`:110-115` exit flush). A real number was recorded.

| measure | runner job id | ticket | `max_ms` | `mean_ms` | vs 250 ms |
|---|---|---|---|---|---|
| perf gate, AFTER import-cache fix (final) | `qa1-bench-4` | 639 | **645.24** | 526.63 | **FAIL** (2.58× over) |
| perf gate, BEFORE import-cache fix | `qa1-bench-3` | 637 | 629.17 | 565.32 | FAIL (2.52× over) |
| effective preset verification | `qa1-bench3-config` | 636 | — | — | low confirmed |

**Gate verdict: FAIL.** Measured max single-frame chunk-bake time on the LOW
preset is **645.24 ms**, above the N-07 target of < 250 ms. This is a measured
engine-emitted value, not an inference from `sync_ms`. Both runs agree, and
regenerating the import cache did not change the outcome, so the cost is in
`_build_chunk` itself rather than the missing-`.ctex` raw-PNG fallback.

Contract and settings actually in force for the final run:
- 120 frames (`--screenshot-frames 120`); low preset overlay by **absolute path**;
  `--dump-config` in ticket 636 confirmed `quality: low`, `terrain_px: 8`,
  `sprite_cell: 64`, `fx_cap: 60`, `fog_interval: 1`, `minimap_interval: 0.5`.
- 2-chunks/frame cap (`world.gd:1160-1161`) and LRU 24 (`world.gd:1177-1182`),
  unchanged by QA-1.
- Engine line: `BAKE_BENCH preset=low px=8 chunks=120 max_ms=645.24 mean_ms=526.63`.

**Explicit caveats (required for an honest reading):**
- The `preset=low`, `px=8` and `chunks=120` fields are **hardcoded contract labels**
  in `world.gd`, not measurements. The preset was verified independently (ticket
  636); the *actual bake count is not emitted*. With a 12.45 s process run and a
  526.63 ms mean, only ~12-20 bakes occurred — the line was flushed at exit,
  **not** on the 120th bake. `chunks=120` refers to the 120-frame bench contract.
- The max is **cold-cache dominated**: a static camera bakes only the first few
  chunks, so one-time image/cache warm-up is included. It is a real single-frame
  bake time, but not a steady-state figure. Per the task instruction this is
  stated explicitly and **no pass is claimed** — and the measured verdict is
  FAIL in any case.
- `qa1-bench-4` stdout: `PERF tick_ms=0.80 ai_ms=0.56 sync_ms=17.59
  steps_per_frame=0.3 redraws r/b/u/f=5/5/120/120`; 0 stderr errors;
  `sprites: 116 sets loaded`. `sync_ms=17.59` remains context only.

**Remaining blocker for N-07:** the gate is red. `_build_chunk` in `world.gd`
(RENDER-1's file) needs optimisation, or the 250 ms target needs revisiting with
the owner. QA-1 cannot edit `.gd` files, so no fix was attempted here.

### Import-cache blocker resolved (runner job `qa1-import`, ticket 638)

- Command (never direct `godot`):
  `python app\tools\godot_runner.py run --id qa1-import --timeout 240 --max-wait 3600 -- --headless --path app --editor --import`
- Result: `ok`, exit 0, run 34.08 s, **0 stderr lines** (1235 stdout lines).
- Verification (read-only Python, no `.import` or `.gd` file edited):
  - `bush1.png-8a8cdc339a9d4240673a4e01414c48e4.ctex` — 130,622 B
  - `tree_spruce1.png-ca46988f8ef4241e7498364e2378246e.ctex` — 73,216 B
  - `rock_stones1.png-0d0b8decf034aff0721ff0be30b5d84f.ctex` — 108,062 B
  - Each hash equals `md5("res://assets/models/sprites_hi/<name>.png")`, i.e. the
    exact filename referenced by that sprite's `.import` `[remap] path=`.
  - All **385** `.import` files under `assets/models/sprites`,
    `assets/models/sprites_hi` and `assets/models/tex` now have their referenced
    `.ctex` under `app/.godot/imported/` — **0 missing** (was 87 missing).
- Conclusion: the normal Godot `load()` remap path now resolves these sprites;
  exported builds no longer depend on the dev-only `Image.load_from_file`
  fallback. Verification method was `.ctex` existence + matching MD5 path hashes
  (no temporary `.gd` script was added, per the no-`.gd`-edit constraint).

**Files changed this follow-up:** `app/shots/perf.md`, `app/tools/bake_bench.py`
(updated honesty caveats), regenerated `app/.godot/imported/**` cache files.
No `.gd` or `.import` file was edited.
