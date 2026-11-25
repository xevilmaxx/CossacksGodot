---
id: PERF-3D-01
owner: PERF-3D-01
wave: perf
swarm: coord_swarm_2026-11-25
date: 2026-11-25
scope: READ-ONLY — no game code/test/config/shader/asset edits; no direct `godot`; runner jobs only via `variant3d/tools/godot_runner.py` with unique ids
output: docs/coord_swarm_2026-11-25/reports/PERF_3D_01.md
status: MEASURED (total `world.sync`) / BLOCKED (per-stage attribution, build ms, draw calls)
method: existing CLI hook (`main.gd:1611` PERF line) via headless `--screenshot --screenshot-frames 120` + existing spool/doc baselines
visual_parity: NONE CLAIMED — PORT APPROXIMATION labels unchanged; visual UNVERIFIED
headline: current 120-frame headless 3D sync_ms = 276.77 / 272.56 (240²), vs prior same-signature window 134.54 → ~2.04x regression (derived); per-stage cause UNVERIFIED
---

# PERF-3D-01 — current 3D sync/render hotpaths vs prior baselines

## 1. Sources read (all read-only)

| Source | Lines / role | Labels used below |
|---|---|---|
| `docs/coord_swarm_2026-11-24/reports/PERF3D_sync_hotpath.md` | `:22-37`, `:76-98`, `:119-125`, `:171-181` — pre-fix per-stage probe (tickets 187/190/192), 320², 200 units | observed (engine output) |
| `docs/coord_swarm_2026-11-24/reports/V779_pose_memo.md` | `:28-33`, `:85-103` — pose memo 8.18–11.91× at 200 units; `pose_for` calls N→6 | observed (engine output) |
| `docs/coord_swarm_2026-11-24/reports/V780_res_dirty_gate.md` | `:115-135` — reconcile 4.179→0.333 ms (12.54×) at 200u+1200res | observed (engine output) |
| `app/shots/perf.md` | `:190-254` — 2D `sync_ms=17.37/17.59`, BAKE_BENCH gate, CLI-hook caveats | observed (context only, 2D) |
| `docs/audit/MAP_NAV_PERF.md` | `:46-79` — 2D chunk-bake/frame-budget analysis | observed/derived (context only, 2D) |
| `docs/coord_swarm_2026-11-24/reports/W53_world_perf_light.md` | `:184-200` — 2D chunk-scheduling call-count test | observed (context only, 2D) |
| `variant3d/scripts/main.gd` | `:1611` PERF print; `:1638-1641` `world.sync(dt)` timing; `:213-215`, `:710-718`, `:1574-1576`, `:2091-2129` CLI mode; `:1622-1637` bench | observed (source) |
| `variant3d/scripts/world3d.gd` | `:329-403` `_reconcile_entities` + V7-80 gate; `:682-700` `sync()`; `:505`, `:297`, `:463`, `:535` secondary syncs | observed (source) |
| `variant3d/scripts/world3d_entities.gd` | `:1570-1695` `sync()` Pass 1; `:957-982` `_unit_action`/`_measure_speed`; `:989-995` `_smooth_face`; `:1296-1338` `_xf`; `:166-176` 19-tree pool; `:1597`, `:1629-1636` pose memo | observed (source) |
| `variant3d/scripts/world3d_terrain.gd` | `:1597-1602` `timing_ms` stats; `:1189`, `:461-551` relief stamps; `:392-407`, `:566-599` season atlas; `:605` atlas load | observed (source) |
| `variant3d/scripts/world3d_fx.gd` | `:495-506` `sync()`; `:287`, `:306`, `:331-344` weather gate; `:500-501` trail gate | observed (source) |
| `variant3d/config.json` | `:40` `render_mode: "3d"`; `:41-42` `240×240` map | observed (source/config) |
| `variant3d/.godot_queue/results/00000395_mapsmall01-diag9-240/stdout.txt` + `00000395.json` | prior 240² PERF windows, `--self-test`, ticket 395 | observed (engine output) |
| `variant3d/.godot_queue/results/00000175_v770-journey2d-probe/stdout.txt` | older `sync_ms=52.61` (2D journey) | observed (context only) |
| `variant3d/tests/manifest.json`, `t_perf_scale.gd`, `t_mass_army.gd`, `t_sim_hotspots.gd`, `t_terrain_trees.gd` + result JSONs | hook inventory | observed (source/results) |
| `docs/coord_swarm_2026-11-25/SWARM_BOARD.md` | `:112`, `:117-118`, `:137`, `:145-146`, `:175`, `:183-193`, `:228` — file owners | observed (board) |

## 2. Available hooks (inventory — nothing authored)

| Hook | Emits | Usable for 3D `sync_ms`? | Reason / verdict |
|---|---|---|---|
| `main.gd:1611` PERF line (full-game modes: headless `--screenshot`, `--self-test`, `--uitest`, `--journey`, windowed) | `tick_ms`, `ai_ms`, `sync_ms` = mean TOTAL `world.sync()` over 120 frames, `steps_per_frame`, cumulative `redraws r/b/u/f` | **YES — used** | Only existing emitter of `sync_ms`. Headless dummy RenderingServer: CPU time only, no GPU upload. Not a max, not per-stage. |
| `--cli ... --cli-seconds` (`main.gd:213-215`, `710-718`, `1574-1576`, `2091-2129`) | sim report only | **NO — rejected** | `_setup_cli_only()` creates no world; `_run_cli_incremental()` returns from `_process()` at `:1576` before `world.sync(dt)` at `:1640`. No PERF line. (Also: variant's file is `variant3d/cli.json`.) |
| headless `--bench` (`main.gd:1622-1637`, `:1638`) | `fps`, `sim_ms_per_tick` in `shots/bench.json` | **NO — rejected** | `main.gd:1638` excludes `world.sync()` when `bench_mode and is_headless`. |
| `world3d_terrain.gd:1597-1602` `stats["timing_ms"]` (`parse_dump`, `decode_heights`, `mesh_build`, `total_build`) | build ms **in memory only** | **BLOCKED** | No registered test/tool or engine line prints it; no result JSON contains `timing_ms`. Needed hook: an existing registered probe that dumps `terrain.stats()["timing_ms"]` once at bind (or a line in `world3d_terrain.gd:build()`). |
| `world.gd:180` `BAKE_BENCH ... max_ms=` | 2D chunk bake max/mean | **N/A** | Lives in 2D `world.gd`; `world3d_terrain.gd` has no BAKE_BENCH emitter. Do not quote 2D bake numbers for 3D. |
| `testbridge.gd:249` `Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME` | draw calls | **BLOCKED** | Needs `--test-api-port` plus a polling client; no simple registered emitter. Headless dummy renderer would report 0 anyway. |
| `t_terrain_trees.gd` / `t_combo_all.gd` draw calls / frame time | `draw_calls_avg`, `frame_time_recorded` | **BLOCKED** | Windowed atoms; headless result JSON has `draw_calls_avg = 0.0` (`t_terrain_trees.json:221`) = `SKIP_CAPTURE`, not a measurement. |
| `t_perf_scale.gd` (unregistered), `t_mass_army.gd` (registered), `t_sim_hotspots.gd` | `move_ms`, `squad_ms`, `sim_ms` | **NO — sim only** | Existing result JSONs read for context; none measures `world.sync` or rendering. |
| Old temporary probes (`t_perf3d_sync_probe_tmp.gd`, `t_v779_*`, `t_v780_*`) | per-stage ms | **GONE** | Deleted by their owning lanes (per their reports). Re-authoring is outside this read-only task. |

## 3. Job table (all launches via `variant3d/tools/godot_runner.py run`; no direct `godot`)

| Ticket | Job id | Command / purpose | wait (s) | run (s) | status / exit | PERF line? |
|---|---|---|---:|---:|---|---|
| **477** | `perf3d01-sync120c` | `--headless --path variant3d -- --screenshot <temp>\perf3d01_sync_c.png --screenshot-frames 120 --timeout 210` | 0.00 | 160.04 | `ok` / 0 | **yes — `sync_ms=276.77`** |
| **500** | `perf3d01-sync120d` | same shape, id `perf3d01-sync120d`, `--timeout 240`, `perf3d01_sync_d.png` | 0.00 | 154.58 | `ok` / 0 | **yes — `sync_ms=272.56`** |
| 490 | `perf3d01-selftestc` | `--headless --path variant3d -- --self-test variant3d/selftest.json` (multi-window comparison to ticket 395) | 295.24 | 24.87 | `failed` / 1 | no — aborted before 120 frames; stdout = banner only, stderr empty |
| 498 | `perf3d01-sync240` | 240-frame screenshot (wanted two PERF windows) | 103.01 | 113.20 | `failed` / 1 | no — aborted; stdout = banner + one atlas warning, stderr otherwise empty |
| 459 / 460 / 463 | `perf3d01-sync120` / `-dumpcfg` / `-selftest` | first submissions | — | — | killed by the harness 600 s background cap **before the runner started them** (spool dirs exist, no result JSON, no stdout) | no — discarded |
| 395 (existing) | `mapsmall01-diag9-240` | `--headless --path variant3d -- --self-test variant3d/selftest.json` (prior 240² baseline, ~66 min before ticket 477) | 5.87 | 129.17 | `failed` / 1 | **yes — 10 windows** |
| 175 (existing) | `v770-journey2d-probe` | older 2D journey probe | — | — | `ok` | `sync_ms=52.61` (2D context only) |

Measured jobs 477 and 500 both bound the 3D modules (stderr shows `world3d_entities.gd:448 bind` via `world3d.gd:641`), so `render_mode: "3d"` was in force; no windowed run was possible (no display).

## 4. Measured numbers vs baselines

### 4.1 Same-signature comparison (primary)

All three rows below have the identical cumulative redraw signature `r/b/u/f = 859/6/16/0` and the same 240×240 map, so this is the closest available comparison.

| State | Job / ticket | `sync_ms` | `tick_ms` | `steps/frame` | label |
|---|---|---:|---:|---:|---|
| Prior (2026-11-25, earlier) | 395, window 1 | **134.54** | 7.08 | 1.4 | observed |
| Current A | **477** | **276.77** | 22.58 | 2.3 | observed |
| Current B | **500** | **272.56** | 13.35 | 1.9 | observed |
| Current mean | 477 + 500 | **274.665** | 17.965 | 2.1 | derived |
| Regression factor | (477+500 mean) / 395 w1 | **2.04×** | 2.54× | 1.5× | derived |

- Current run-to-run spread: 276.77 vs 272.56 = **1.5 %** (observed) — tighter than the ±20 % machine-load caveat in the prior probes.
- The two current jobs used the same 120-frame `--screenshot` hook; ticket 395 used `--self-test`. Same redraw signature, **different mode** — comparison is derived, not an exact A/B (open question Q1).
- `tick_ms` also rose (7.08 → 13.35/22.58), so the machine/run was not identical; however `sync_ms` is stable across both current jobs while `tick_ms` varies by 1.7×, so the sync difference is **not explained by machine load alone** (inferred).

### 4.2 Other baselines (context only — different shape/config)

| Baseline | Value | Comparable to current? | label |
|---|---|---|---|
| Ticket 395, windows 2–10 (steady-state, different game state: `r/b/u/f` mostly `0/0/0/n`) | `sync_ms` 20.25 / 27.97 / 31.92 / 32.88 / 39.12 / 39.19 / 46.75 / 48.49 / 62.60; mean of all 10 = **48.37**, median = **39.16**, windows 2–10 mean = **38.80** | No — later windows have far fewer redraws; quote as context only | observed / derived |
| PERF3D pre-fix probe, 320², 200 units (tickets 187/190/192) | total `world.sync` **127.657–163.176 ms**; pose stage 115.4–160.1 ms (90–98 %) | No — probe shape and map size differ | observed |
| V7-79 post-memo probe, 200 units (tickets 199/200) | **11.175–16.270 ms**; `pose_for` calls N→6, 8.18–11.91× | No — different probe shape; ratio preserved structurally, absolute value not re-measured | observed |
| V7-80 reconcile probe (ticket 197) | **4.179 → 0.333 ms** at 200u+1200res (12.54×) | No — stub-scan probe; gate still present in source (observed) | observed |
| `app/shots/perf.md:192-254`, 2D low preset | `sync_ms=17.37` / `17.59` | No — different project/renderer (2D) | observed (context) |
| Ticket 175, 2D journey | `sync_ms=52.61` | No — 2D | observed (context) |

Derived context (not claims of equivalence): current mean 274.665 ms is ~7.08× ticket-395 steady-state mean 38.80 ms, ~16.9–24.6× the V7-79 200-unit probe, and ~15.6× the 2D `sync_ms=17.59`. Unit count / pose-sample count is **not emitted** by the PERF line, so no per-unit current rate can be computed (open question Q2).

### 4.3 Metrics not available

| Metric | Verdict | Reason |
|---|---|---|
| Per-stage ms (pose sample / morph lookup / transform / reconcile / fx) | **UNVERIFIED — BLOCKED** | No existing per-stage emitter remains; old probes deleted. Needed hook: a registered timing probe (e.g. `t_perf3d_sync_stages.gd`, runnable via `--script`) printing per-stage ms at N units, or a `PERF3D_STAGE` line in `world3d.gd:sync()`. |
| Terrain build ms (`timing_ms.total_build`, `mesh_build`) | **UNVERIFIED — BLOCKED** | `world3d_terrain.gd:1597-1602` fills the dict but no hook prints it. Needed hook: dump `terrain.stats()["timing_ms"]` once from an existing registered test/bind path. Runner `run=160.04 s` is **process wall time** (atlas load + mapgen + sim ticks + 120 syncs), not build ms — do not reuse it. |
| Draw calls | **UNVERIFIED — BLOCKED** | See §2. |
| Windowed frame time / FPS | **UNVERIFIED** | No display; headless dummy renderer. |
| Visual parity | **NONE CLAIMED** | All 3D layers are PORT APPROXIMATION / visual UNVERIFIED; no fixed-seed A/B was run. |

## 5. Regressions ranked, with owners (from `SWARM_BOARD.md`)

Attribution below is **inferred** where the evidence is source shape plus the total-sync delta; no per-stage hook exists to confirm it. No fix was attempted.

1. **Per-unit presentation work added to the historically dominant Pass 1 — highest ranking (inferred).**
   - Owner: `MOTION-ANIM-01` (`world3d_entities.gd`, board `:117`, **RUNNING**).
   - Evidence: `world3d_entities.gd:1570-1695` now performs, for every unit every sync: `_measure_speed()` (`:971-982`, allocates a new `{pos, t}` Dictionary per unit at `:981`), `_smooth_face()` (`:989-995`, `fposmod` wrap + clamp), `_unit_action(ed, speed)` (`:957-964`), writes to `_face_smooth` / `_motion_sample` / `_applied_pose_frame` (`:1622`, `:1690`), plus a frozen-frame fallback that can rebind `mm.mesh` (`:1674-1677`). This is the same pass PERF3D measured at **90–98 % of `world.sync`** before V7-79.
   - The V7-79 pose memo itself is **structurally intact** (`:1597`, `:1629-1636`; `memo_key = sid|action`) — observed. Its key cardinality can now change because `action` is derived from measured displacement instead of the `moving` flag (inferred, UNVERIFIED numerically).
   - Co-owner of the same file: `DECOR-01` (board `:112`, **DONE**) — tree pool 6→19 sids (`:166-176`) and per-resource `_jitter_factor()` in `_xf()` (`:1334-1336`), which adds work inside Pass 2 for every wood resource node.
   - Why ranked first: Pass 1 is the only stage with a measured history of dominating `sync_ms`, and the new work is strictly additive per unit/per resource.

2. **Resource reconcile still scans most frames during a populated/starting map (inferred).**
   - Owner: `V7-80` (`world3d.gd`, prior wave) — gate **observed intact** at `:360-389`; not a today change.
   - Evidence: `dbg_res=859` in both current windows and in ticket-395 window 1, i.e. ~7 resource additions/frame over the window; each addition bumps `res_dirty`, so the V7-80 gate opens and the `res_nodes` walk runs. Prior 2D dirty-bump probe cost 4.179 ms at 1200 res nodes; current per-frame cost is **UNVERIFIED** (no hook).
   - Ranked second because its measured ceiling (~4 ms) is far below the observed ~140 ms delta, so it cannot explain the regression alone (derived).

3. **Build-time / startup changes — not expected in steady-state `sync_ms` (inferred).**
   - `SP-6` season atlas selection (`world3d_terrain.gd:392-407`, `:566-599`, board `:175`, **RUNNING**) and `RELIEF-01`/`RELIEF-02` relief stamps (`:1189`, `:461-551`, board `:145-146`, **DONE**) run in `build()`/`bind()`, not in `world3d.gd:sync()` (which does not call `terrain.sync()`). `CONFIG-CORE-01` getters (board `:183`, **DONE**) are read at bind/setup; `camera3d.gd:195-208` getter calls are in bind. No per-frame sync cost expected; absolute build ms UNVERIFIED (§4.3).

4. **FX additions — low risk (inferred).**
   - `FX-WEATHER-01` snow is gated OFF by default (`world3d_fx.gd:287`, `:306`, `:331-344`; board `:137`, **DONE**); `FX-IMPACT-01` arrow trails are opt-in (`:500-501`; board `:118`, **DONE**). `world3d_fx.gd:sync()` (`:495-506`) still runs the pre-existing `_update_fx/_update_rally/_update_ghost/_update_selection` chain; PERF3D measured FX at 0.017–0.020 ms in steady state. No new per-frame loop observed for the default config.

## 6. Open questions

- **Q1 — mode mismatch.** Ticket 395 is `--self-test`, current jobs are `--screenshot`. The redraw signature and map size match exactly, but the engine state does not. An apples-to-apples fresh `--self-test` was attempted (ticket 490) and aborted before 120 frames with no diagnostic output (UNVERIFIED cause). Re-run needed before treating 2.04× as exact.
- **Q2 — no live-unit / pose telemetry.** The PERF line emits cumulative redraw counts, not live units, `pose_for()` calls, `donor_morph_pose_samples`, `yaw_clamps` or `frozen_refreshes`. Needed hook: emit `entities.stats()` subset in the frame-120 PERF line or a registered stats-dump test.
- **Q3 — per-stage attribution BLOCKED.** No existing probe emits stage timings; authoring one is outside this read-only task. Needed hook is specified in §4.3. Without it, §5 ranking stays inferred.
- **Q4 — build ms and draw calls BLOCKED.** Hooks inventory in §2; no visual-parity claim is possible from headless data.
- **Q5 — failed jobs 490/498.** Both exited 1 after only a banner (498 had one atlas warning), with empty/short stderr. Whether this was a transient queue/file race or a real startup regression is **UNVERIFIED**; two identical 120-frame jobs (477/500) succeeded around them.
- **Q6 — Headless vs windowed.** Dummy `RenderingServer`: GPU upload and windowed frame time are not measured. No FPS number is claimed.

## 7. Summary

- **Measured:** current 3D `sync_ms` = **276.77 ms** (ticket 477) and **272.56 ms** (ticket 500) — mean **274.665 ms** — on the current 240² headless 3D build over 120 frames, via the existing `main.gd:1611` PERF line.
- **Derived:** ≈**2.04×** slower than the closest prior same-signature window (`134.54 ms`, ticket 395, same map and redraw signature). The two current runs agree within 1.5 %.
- **Prior structural wins (V7-79 pose memo, V7-80 res-dirty gate) remain present in source** (observed), but their absolute benefit cannot be re-measured with the surviving hooks; they are **not** claimed to be still delivering 8–12× today.
- **Ranked suspect owners:** `MOTION-ANIM-01` / `DECOR-01` (both `world3d_entities.gd`, per-unit Pass 1 + Pass 2 additions) first, `V7-80` resource scan second (ceiling too small to explain the delta alone); season/relief/config/FX changes are build-time or gated off and are not expected in steady-state sync (all inferred).
- **BLOCKED:** per-stage attribution, terrain build ms, draw calls, windowed frame time — exact needed hooks in §2/§4.3/§6.
- **No code, test, config, shader or asset was edited. No visual-parity claim.**
