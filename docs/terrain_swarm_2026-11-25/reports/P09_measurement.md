---
id: P09-MEASUREMENT-PLAN
title: "P09 — concrete windowed FPS/per-frame/startup measurement plan for this MX130 / OpenGL 3.3 Compatibility machine (design only; commands handed to COORD/G04)"
ticket: P09 (TERRAIN-SWARM-WAVE-G / Wave P performance)
owner: P09 read-only analysis subagent
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDITS__NO_RUNNER_JOBS
scope: "Exactly one new file written: this report. No .gd/.gdshader/config/test/fixture/tool/result file created or edited; no Godot process launched; no runner job submitted/cancelled/acked/reset; no process killed. All commands below are a SPECIFICATION for COORD/G04, not work done here."
labels: [observed, derived, inferred, UNVERIFIED]
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
operator_rule: "Only G04 submits runner jobs (WAVE_G_CHARTER.md:31,67-70). P09 submits ZERO jobs."
parity_guard: "No donor GPU A/B frame exists. Every expected FPS/frame-time number in this report is UNVERIFIED until a real capture lands; no donor parity and no GPU-timer claim is made."
---

# P09 — FPS / performance measurement plan

## 0. Boundary, labels, and the short answer

**Observed** = direct read of the named file/line. **Derived** = arithmetic/control-flow consequence. **Inferred** = plausible reading with caveat. **UNVERIFIED** = cannot be proven without a run; all target/expectation numbers below carry this label. No number in this report is a measured FPS result.

**Deliverables (all inside this report):** (1) exact, unique runner job ids and copy-pasteable **windowed** commands for fixed-seed 64² and real-map boots; (2) the exact Godot telemetry APIs to sample and a concrete atom specification for per-frame times (no atom is created here); (3) a startup-stage timing method with exact `main.gd` stage strings and sites; (4) a results JSON schema; (5) the confound register; (6) the minimum run count for a credible before/after.

**Authority:** `WAVE_G_CHARTER.md:31,67-70` reserves all Godot/runner work to G04. P09 only designs. **COORD/G04 must not treat any planned value as a PASS line** — the atom verdict stays `MEASUREMENT_ONLY__NO_PASS_CLAIM` (precedent: `LOAD_PROBE_REPAIR_01.md:35-36,110-111`).

---

## 1. What can actually be measured on this machine — inventory (observed)

| Source | What it emits | Label / verdict |
|---|---|---|
| `variant3d/scripts/main.gd:1724-1729` (`--stats`) | `frames N fps F units U entities E` once per ~1 s to **stdout** | Windowed/runnable now; 1 Hz, not per-frame. **Observed** hook. |
| `main.gd:1640-1647` PERF line | `tick_ms`, `ai_ms`, `sync_ms` = means over 120 frames, `steps_per_frame`, cumulative `r/b/u/f` redraws | Windowed/runnable now; **CPU** (`world.sync`) only, no GPU, no FPS. **Observed** hook. |
| `main.gd:1653-1667` `--bench` | `fps`, `sim_ms_per_tick` in `shots/bench.json` | Excludes `world.sync` when headless (`main.gd:1638,1669`); wrong instrument for windowed FPS. **Observed**. |
| `scripts/testbridge.gd:243-250` (`--test-api <port>`) | `fps`, `frame`, `perf.process_ms/physics_ms/draw_calls/prims`, game/HUD state | Instantaneous snapshot over TCP; requires an external polling client (`tools/test_drive.py:8-27` shows the RPC shape). Polling adds overhead and samples at client cadence. **Observed** hook; windowed polling UNVERIFIED. |
| `tests/t_terrain_trees.gd:244-259,277-284,372-377` | `draw_calls_avg/last`, `process_time_ms_avg`, `frame_delta_ms_avg`, checks `draw_calls_recorded` / `frame_time_recorded` | **Per-sample telemetry exists**, but in a stub atom, not the real game boot; headless result JSON has `draw_calls_avg = 0.0` (`t_terrain_trees.json:220-224`) = `SKIP_CAPTURE`, not a measurement (`PERF_3D_01.md:48`). Windowed atom use: runnable, but scenario is terrain-only. |
| `tests/t_combo_all.gd:964-968,992-993,1016-1017` | per-frame `RENDER_TOTAL_DRAW_CALLS_IN_FRAME` samples after `frame_post_draw`, mean + count | Same caveat: stub atom, not full game. **Observed**. |
| `tests/t_mass_army.gd:19-23,123-128,156-158` | `sim_ms` for 400+4×38 = **552** units, headless sim only | Army-scale **sim** cost, not FPS. **Observed**. |
| `tests/t_load_usability.gd:299-354,536-542` | `stage_log[{stage,frame,us,bar}]`, `max_stage_to_stage_us`, `overlay_lifetime_us`, `max_gap_loading_us` | Proven stage-transition proxy, but the atom **refuses non-headless** (`:208-216`) and its `(a)` literal stall stays UNVERIFIED (`LOAD_PROBE_REPAIR_01.md:149`). |
| `scripts/main.gd:657-676` | `load_ready`, final `frame_post_draw` hold, overlay hide | Readiness sequence; no duration emitter. **Observed**. |
| GPU context | `OpenGL API 3.3.0 NVIDIA 571.96 - Compatibility ... NVIDIA GeForce MX130` | **Observed** in `AUDIT3D_09_runtime_proof.md:27` as quoted by `G17_perf_audit.md:75-77`. Engine banner must be recaptured per run; exact board clocks/VRAM **UNVERIFIED** (`G17:213-223`). |

**No GPU timestamp query is exposed to GDScript in this project** (no timer-query API is used anywhere in `variant3d/`; grep-confirmed). Therefore "GPU ms" is **UNVERIFIED** for every plan row. The only honest signals are wall frame time, `TIME_PROCESS`, `TIME_PHYSICS_PROCESS`, and draw-call/primitive counters. A large `wall_ms − process_ms` gap is **inferred** to indicate non-CPU (render/driver/compositor) cost; it is not a GPU measurement.

---

## 2. Two measurement paths — and why they are NOT interchangeable

This is the single most important finding of this ticket.

### 2.1 Path S — `--screenshot` boot (runnable now)

`main.gd:233-248` takes the menu-skipping `_setup_full_game()` → `_setup_screenshot_window()` path. That function:

- sets window to 1280×720 and **`DisplayServer.WINDOW_FLAG_NO_FOCUS = true`** (`main.gd:1222-1224`);
- comments that a covered window still draws on Windows (`:1225-1227`);
- forcibly calls `DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)` (`:1233`);
- reparents `world` + `camera` into an `UPDATE_ONCE` `SubViewport` named `Screenshot3DViewport` (`:1240-1253`);
- saves the PNG at `frame >= screenshot_frames` (`:1730-1732`).

**Derived:** a `--screenshot` FPS number is *unfocused, uncapped (vsync forced off), capture-viewport* FPS. It is **not** the FPS of interactive play. Config `display.vsync` is **inert in this path** — do not claim a vsync A/B from it. Also, `--screenshot-frames 10` (A09's default) measures the first-draw/shader-warmup region; use ≥180 frames for a steady-state window.

### 2.2 Path I — interactive staged load (needs one new atom, NOT created by P09)

Normal play goes through `_on_menu_chosen()` → `_do_async_load()` (`main.gd:257-272`), which applies `DisplayServer.window_set_vsync_mode(VSYNC_ENABLED if Data.VSYNC else DISABLED)` from `config.json:54` (`main.gd:549-554`), keeps the window focusable, and runs the 14 labelled stages. To time this windowed without a human click, a `--script` atom must instantiate `res://scenes/main.tscn` and call `_apply_menu_cfg(cfg)` + `_do_async_load(cfg)` by `Object.call()` — the forced path already proven by `t_load_usability.gd:23-36,285-295`, but with its headless guard (`:208-216`) removed and per-frame sampling added. **Spec in §4.2; the file is to be authored by a follow-up ticket, not by P09.**

**Rule for reports:** never mix Path S and Path I numbers in one A/B column; label each row with its path.

---

## 3. Exact runner jobs and commands — hand-off to G04

All commands run from repo root `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3`, Windows `python` (not `python3`), PowerShell uses `;` not `&&` (`CHARTER.md:69`). All ids are reserved, unique, `p09-` prefixed; **none has been submitted by P09**. Preflight `python variant3d\tools\godot_runner.py status` before **every** submission; require lock free, `pending=0`, and zero live Godot processes (`G04_gate_log.md:47-58`; ticket 582's stale job must be cleared by COORD first — `G04_gate_log.md:155-165`). Submit one job at a time; wait for result JSON + PNG + stderr before the next (A09 §5).

### 3.0 One-time setup (G04, outside the repo)

```powershell
New-Item -ItemType Directory -Force -Path "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p09" | Out-Null
'{"gameplay":{"render_mode":"3d","random_seed":20261113,"map_width_tiles":240,"map_height_tiles":240}}' | Out-File -FilePath "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p09\p09_rm240.json" -Encoding ascii -NoNewline
'{"gameplay":{"render_mode":"3d","random_seed":20261113,"map_width_tiles":320,"map_height_tiles":320}}' | Out-File -FilePath "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p09\p09_rm320.json" -Encoding ascii -NoNewline
```

240² is the as-shipped real map (`config.json:75-76`); 320² is the A09 PORT APPROX map-size arm (`A09_capture_plan.md:42,76-89`). Record which one was actually booted from the `settings file:` line in stdout (`main.gd:197-200`). Note `config.gd:297-303` merges `user://options.json` as a third layer — `--dump-config` once per session to record effective values.

### 3.1 Primary before/after pair — Path S, 64² fixed seed (runnable now)

**Before, run 1** (all four tokens in one line; `--` separators are mandatory):

```bat
python variant3d\tools\godot_runner.py run --id p09-p64-before-r1 --timeout 300 --max-wait 3600 -- --path variant3d -- --config res://tests/fixtures/small_map_64.json --seed 20261113 --stats --screenshot-frames 180 --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p09/p64_before_r1.png" --timeout 120
```

**After, run 1** (identical except id/PNG):

```bat
python variant3d\tools\godot_runner.py run --id p09-p64-after-r1 --timeout 300 --max-wait 3600 -- --path variant3d -- --config res://tests/fixtures/small_map_64.json --seed 20261113 --stats --screenshot-frames 180 --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p09/p64_after_r1.png" --timeout 120
```

Why these flags: `small_map_64.json:10-15` pins 64² + seed 20261113 + 3D; `--seed 20261113` is reapplied after config merge (`main.gd:187-190,1356-1362`); `--stats` gives 1 Hz FPS into stdout (`main.gd:1724-1729`); 180 frames > 120 gives at least one full PERF window (`main.gd:1640-1647`); no `--headless` (`TEST_MATRIX.md:62-64`); runner `--timeout 300` + game `--timeout 120` (watchdog `main.gd:1608-1613`).

### 3.2 Primary before/after pair — Path S, real map 240² (runnable now)

**Before, run 1:**

```bat
python variant3d\tools\godot_runner.py run --id p09-rm-before-r1 --timeout 300 --max-wait 3600 -- --path variant3d -- --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p09/p09_rm240.json" --seed 20261113 --stats --screenshot-frames 180 --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p09/rm_before_r1.png" --timeout 120
```

**After, run 1:**

```bat
python variant3d\tools\godot_runner.py run --id p09-rm-after-r1 --timeout 300 --max-wait 3600 -- --path variant3d -- --config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p09/p09_rm240.json" --seed 20261113 --stats --screenshot-frames 180 --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p09/rm_after_r1.png" --timeout 120
```

320² arm: substitute `p09_rm320.json` and ids `p09-rm320-before-r1` / `p09-rm320-after-r1`; label any comparison to 240² as a PORT APPROX map-size arm, never a shader-uniform A/B (`G04_gate_log.md:127-129`).

### 3.3 Repeats, warm-up, and full id registry

For each fixture, submit in **interleaved** order `before-r1 → after-r1 → before-r2 → after-r2 → before-r3 → after-r3`, plus one warm-up `p09-<fixture>-warmup` first per fixture (discarded from statistics). Ids and substitutions:

| Fixture | Warm-up (discard) | Before r1 / r2 / r3 | After r1 / r2 / r3 |
|---|---|---|---|
| 64² | `p09-p64-warmup` | `p09-p64-before-r1/2/3` | `p09-p64-after-r1/2/3` |
| Real 240² | `p09-rm-warmup` | `p09-rm-before-r1/2/3` | `p09-rm-after-r1/2/3` |
| Real 320² (optional) | `p09-rm320-warmup` | `p09-rm320-before-r1/2/3` | `p09-rm320-after-r1/2/3` |
| P0 terrain-only atom (visual anchor) | — | `p09-p0atom-before-r1` | `p09-p0atom-after-r1` |
| Startup/per-frame atom (§4.2, after it exists) | `p09-load64-warmup` | `p09-load64-before-r1/2/3` | `p09-load64-after-r1/2/3` |
| Army-scale sim control | — | `p09-massarmy-before-r1` | `p09-massarmy-after-r1` |

For r2/r3, copy the §3.1/§3.2 command and change **only** the id and PNG filename (`..._before_r2.png`, etc.). Do not reuse an id, do not `reset`/`ack`/`unwedge` (A09 §5).

P0 atom (no perf telemetry — visual anchor only, per `t_terrain_only.gd:407-418`):

```bat
python variant3d\tools\godot_runner.py run --id p09-p0atom-before-r1 --timeout 300 -- --path variant3d --script res://tests/t_terrain_only.gd -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p09/p0_before_r1.png" --png "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p09/p0_before_r1.png"
```

Army-scale control (headless sim only — not an FPS arm):

```bat
python variant3d\tools\godot_runner.py run --id p09-massarmy-before-r1 --timeout 180 -- --headless --path variant3d --script res://tests/t_mass_army.gd
```

### 3.4 Per-job integrity (G04, read-only)

```bat
python variant3d\tools\smallmap_capture.py stats "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p09/<name>.png"
python variant3d\tools\smallmap_capture.py scan-stderr variant3d\.godot_queue\results\<ticket>_<p09-id>\stderr.txt
```

Require runner `status=ok`, exit 0, PNG 1280×720 non-blank, `script_error_lines: 0` (`A09:95-99`; `G04_gate_log.md:139-143`). `stats` is qualitative only ("No donor parity is claimed"). If `_is_blank()` rejects a valid olive frame (`main.gd:1932-1942`, job 532 precedent: `A09:90`), analyse the `.raw.png` sidecar and record an instrument defect — **do not edit the detector**. Parse stdout for the `PERF` and `frames ... fps ...` lines and paste them verbatim into the results JSON (§5).

---

## 4. Per-frame capture and startup-stage capture — instrument specification

### 4.1 What to call, and the traps (observed API facts)

| API | Site / precedent | Honest meaning |
|---|---|---|
| `Performance.get_monitor(Performance.TIME_FPS)` | `testbridge.gd:243`; `main.gd:1728` | Smoothed ~1 s FPS; **not** a per-frame value. |
| `Engine.get_frames_per_second()` | Godot built-in; no in-repo call site (grep-confirmed) | Also a smoothed average; use only as a cross-check, never as `p95`. |
| `Performance.get_monitor(Performance.TIME_PROCESS)` × 1000 | `testbridge.gd:247`; `t_terrain_trees.gd:375` | CPU ms in `_process` last frame; excludes render and physics. |
| `Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)` × 1000 | `testbridge.gd:248` | CPU ms in physics last frame. |
| `Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)` / `RENDER_TOTAL_PRIMITIVES_IN_FRAME` | `testbridge.gd:249-250`; `t_combo_all.gd:965-968`; `t_terrain_trees.gd:374` | Per-frame counters; 0 under headless dummy renderer (`t_terrain_trees.json:221`). |
| `Time.get_ticks_usec()` delta between `await RenderingServer.frame_post_draw` iterations | `t_combo_all.gd:965-968` proves the await pattern; `t_load_usability.gd:234-238` proves wall-gap logging | **Real wall frame time.** This is the primary per-frame metric. `delta` in `_process(delta)` is smoothed in Godot 4 and must not be used as the per-frame sample. |
| `get_window().has_focus()` / `DisplayServer.window_get_vsync_mode()` | No in-repo call site; exact API availability **UNVERIFIED** | Record if callable; otherwise infer from `main.gd:1224,1233` (derived) and label. |

### 4.2 New atom to be authored by a follow-up ticket — `variant3d/tests/t_fps_probe.gd`

**P09 does not create this file.** Owner must be assigned by COORD, disjoint from P10/P11/P12 (`WAVE_G_CHARTER.md:83-85`). Required behaviour:

1. `extends SceneTree`; parse `--config`, `--seed`, `--frames`, `--out`, `--stage-only` from `OS.get_cmdline_user_args()` (precedent: `t_load_usability.gd:208-227`, atom launch forms in `RUN_GUIDE.md:78-90`).
2. Instantiate `res://scenes/main.tscn`, `root.add_child(main)`, then on the first `_process()` tick call `main.call("_apply_menu_cfg", cfg)` and `main.call("_do_async_load", cfg)` — the proven forced path (`t_load_usability.gd:285-295`). **Do not add a `--headless` guard**: this atom exists to run windowed (Path I), unlike `t_load_usability.gd:208-216`.
3. From the first frame, once per `await RenderingServer.frame_post_draw`, append one sample:
   `wall_us` = `Time.get_ticks_usec()` delta; `engine_fps` = `Engine.get_frames_per_second()`; `fps_monitor` = `Performance.TIME_FPS`; `process_ms` / `physics_ms` (×1000); `draw_calls`; `prims`; `units` = `game.unit_count(0)+unit_count(1)`; `entities` = `game.entities.size()`; `stage_text` = current `main.loading_stage.text` if valid. Skip the **first 30 samples** as shader/atlas warm-up (label them `warmup_samples`, retain count, exclude from stats).
4. Sample startup stages independently of step 3 by polling `loading_stage.text` every frame and appending `{stage, frame, us}` when the string changes — byte-for-byte the proven method at `t_load_usability.gd:323-329`, and write `stage_log`, `overlay_lifetime_us`, `max_stage_to_stage_us`, `max_gap_loading_us` as in `:335-350,536-542`. Label these **wall-clock proxies, not isolated main-thread busy time** (`LOAD_PROBE_REPAIR_01.md:149`).
5. Exclude ±2 frames around any PNG readback/save from the summary, and record `excluded_frames`.
6. Write `<TEMP>\opencode\p09\<job-id>.json` (raw samples + summary) and print `T_FPS_PROBE RESULT_JSON: <path>` / `T_FPS_PROBE VERDICT: MEASUREMENT_ONLY__NO_PASS_CLAIM` to stdout (precedent: `LOAD_PROBE_REPAIR_01.md:103-105`). No PASS/gate assertion, no threshold, no config/manifest edit.
7. Launch form (once the file exists):

```bat
python variant3d\tools\godot_runner.py run --id p09-load64-before-r1 --timeout 300 --max-wait 3600 -- --path variant3d --script res://tests/t_fps_probe.gd -- --config res://tests/fixtures/small_map_64.json --seed 20261113 --frames 240 --out "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p09" --timeout 180
```

   For a real-map Path I arm, substitute `--config "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/p09/p09_rm240.json"` and id `p09-loadrm-before-r1`. A `display.vsync=false` arm uses a small override config containing `{"display":{"vsync":false}}` — **only meaningful on Path I** (`main.gd:549-554`); on Path S it is inert (`main.gd:1233`).

### 4.3 Literal per-stage CPU time — blocked, exact hook needed

The atom's `stage_log` deltas include two awaited process frames inside `_loading_tick()` (`main.gd:526-533`) and are wall proxies. Isolated stage CPU time needs an edit to **`main.gd` only** (owner: COORD/LOAD-ASYNC, **not P09**): record `Time.get_ticks_usec()` immediately before and after each synchronous stage body and write a `stage_timings` dictionary alongside `load_ready` (`main.gd:675`). Exact bodies/sites: `game=C3Game.new()` `:559-560`; `setup_begin` `:563`; `_gen_base` `:566`; `_gen_forests` `:569`; `_gen_resources` `:572`; `_gen_finish` `:575`; `_assign_tileblocks` `:578`; `setup_spawns`/`connect`/post-loadsave `:581-583`; **`make_world3d()+bind()+add_child()` `:586-589`** (G17's mip-build suspect: `G17_perf_audit.md:59-71,134-145`); camera+focus `:596-619`; HUD `:622-636`; input+3D hooks+AI `:639-647`; audio `:650-656`; `world.sync(0.0)` `:661-662`; final `frame_post_draw` `:667-670`.

Stage strings to expect (beautiful one-to-one map; `main.gd:544,561,564,567,570,573,576,579,584,594,620,637,648,663`): `Preparing...`, `Starting simulation...`, `Shaping land and water...`, `Growing forests...`, `Placing stone and mines...`, `Raising towns...`, `Painting terrain...`, `Mustering armies...`, `Loading art...`, `Wiring camera...`, `Building interface...`, `Wiring input...`, `Starting audio...`, `Ready!`. Until that hook lands, label every per-stage duration **UNVERIFIED / wall proxy**.

---

## 5. Results schema (one JSON per run; all numbers UNVERIFIED until filled by G04)

Keep raw artifacts in `%LOCALAPPDATA%\Temp\opencode\p09\...`. **Never write captures into the repo** (`VIDEO_QA_PROTOCOL.md:28`). Artifact naming: `<job-id>.json`, `<job-id>.png`; runner outputs at `variant3d\.godot_queue\results\<ticket>_<job-id>\stdout.txt|stderr.txt`.

```jsonc
{
  "schema": "p09_fps_v1",
  "labels": "observed / derived / inferred / UNVERIFIED",
  "run": {
    "job_id": "p09-p64-before-r1", "ticket": "<runner ticket>", "state": "before|after|warmup",
    "path": "S_screenshot|I_staged", "fixture": "64|rm240|rm320|p0atom", "seed": 20261113,
    "utc": "<ISO-8601>", "git_short": "<git rev-parse --short HEAD>",
    "runner_status": "ok", "runner_exit": 0, "runner_wait_s": "<from status.json>",
    "runner_run_s": "<from status.json>", "engine_timeout_s": 120,
    "argv": "<verbatim argv from job JSON>",
    "settings_file": "<stdout 'settings file:' line>", "effective_config": "<--dump-config snapshot>",
    "display_server": "gl_compatibility windowed", "gpu_banner": "<verbatim engine banner>",
    "window_size": [1280, 720], "vsync_mode": "<API value or derived-from-code>",
    "focus": "<observed/UNVERIFIED>", "script_error_lines": 0, "png": "<path>",
    "png_size": [1280, 720], "png_non_blank": true
  },
  "per_frame": {
    "samples": "<count, excluding warm-up and capture window>", "warmup_samples_discarded": 30,
    "excluded_capture_frames": "<count>", "duration_s": "<wall span of kept samples>",
    "wall_ms": { "min": "<n>", "p50": "<n>", "p90": "<n>", "p95": "<n>", "p99": "<n>", "max": "<n>", "mean": "<n>", "stdev": "<n>" },
    "fps_derived_from_wall": { "p50": "<1000/p50>", "p05": "<1000/p95>" },
    "engine_fps_smoothed_mean": "<n>", "performance_time_fps_mean": "<n>",
    "process_cpu_ms": { "p50": "<n>", "p95": "<n>", "max": "<n>" },
    "physics_cpu_ms": { "p50": "<n>", "p95": "<n>", "max": "<n>" },
    "draw_calls": { "p50": "<n>", "p95": "<n>", "max": "<n>" },
    "primitives": { "p50": "<n>", "p95": "<n>", "max": "<n>" },
    "units": { "min": "<n>", "max": "<n>" }, "entities": { "min": "<n>", "max": "<n>" },
    "gpu_ms": "UNVERIFIED — no GPU timer query in this project",
    "unit": "ms unless stated; all values UNVERIFIED until parsed from a real run"
  },
  "engine_lines": {
    "perf_window_last": "<verbatim 'PERF tick_ms=... sync_ms=...' line>",
    "stats_lines": "<all verbatim 'frames N fps F ...' lines>"
  },
  "startup": {
    "stage_log": [ { "stage": "<label>", "frame": "<n>", "us": "<n>", "delta_us": "<n>" } ],
    "overlay_lifetime_us": "<n>", "max_stage_to_stage_us": "<n>", "max_gap_loading_us": "<n>",
    "load_ready_frame": "<n>", "overlay_hidden_frame": "<n>",
    "per_stage_cpu_ms": "UNVERIFIED until main.gd hook lands (§4.3)",
    "note": "stage_log deltas are wall-clock proxies incl. two process-frame awaits"
  },
  "verdict": {
    "atom_verdict": "MEASUREMENT_ONLY__NO_PASS_CLAIM", "gate_claim": "NONE", "pass_claim": false,
    "donor_parity": "UNVERIFIED — no donor GPU A/B frame exists",
    "notes": ["<instrument defects, blank-detector failures, focus/vsync anomalies>"]
  }
}
```

**Comparison rule (derived):** compare medians and p95s of `wall_ms` within the same `path`+`fixture`+`seed`+`vsync_mode`, using the interleaved before/after triplets. A claimed improvement must exceed the **combined run-to-run range**, not just the means. Report `Δp50`, `Δp95`, and `Δdraw_calls` separately; never collapse them into a single "FPS score". Any metric with a blocked hook (`gpu_ms`, literal stage CPU ms) stays `UNVERIFIED` in the scorecard.

---

## 6. Confound register (each item has an evidence tag)

| # | Confound | Evidence / label | Control in this plan |
|---|---|---|---|
| C1 | **Window focus** | Path S deliberately sets `WINDOW_FLAG_NO_FOCUS` and notes a covered window still draws on Windows (`main.gd:1219-1227`); OS/compositor throttling of unfocused or covered windows is **inferred**, not measured here. | Keep the Godot window unobstructed; no mouse/keyboard during samples; record `focus` and any focus switch in the JSON; never compare Path S (unfocused) to Path I (focusable) in one column. |
| C2 | **Vsync / refresh cap** | `config.json:54` `vsync=true`; interactive path applies it (`main.gd:549-554`); Path S forces `VSYNC_DISABLED` (`main.gd:1233`). With vsync on, FPS is quantised to the monitor refresh (rate **UNVERIFIED**), hiding sub-refresh gains. | State path and vsync mode in every row; Path I gets an explicit `display.vsync=false` arm; do **not** claim a vsync A/B from Path S. |
| C3 | **Capture overhead** | `SubViewport(UPDATE_ONCE)` + world/camera reparent (`main.gd:1240-1253`); PNG readback/save at frame N (`:1730-1732`); `--screenshot-frames 10` samples first-draw warmup (A09 §2.1). | Use 180 frames, discard first 30 + ±2 around capture, record excluded counts; treat P0 atom PNGs as visual anchors, not FPS evidence. |
| C4 | **"500k-unit armies" vs start** | No 500k configuration exists in this repo. Shipped start = 8 peasants + ~47 `battle_army` entries (`config.json:86,97-104`); `t_mass_army.gd:19-23` spawns **552** units and measures only headless `sim_ms` (`:123-128,156-158`). Donor "up to ten thousand units marching" is a screenshot caption (`RE_VISUAL.md:39,129`), **not** a benchmark. | Do not extrapolate army-scale cost to "FPS too low even on start". Keep start (Path S/I) and mass-army (headless sim control) as **separate** arms; any 500k/thousands claim stays **UNVERIFIED**. |
| C5 | **Headless contamination** | Headless dummy renderer reports `draw_calls_avg=0.0` (`t_terrain_trees.json:220-224`); no windowed FPS, build-ms, or draw calls available headless (`PERF_3D_01.md:97-105`). | No `--headless` in primary jobs; the one headless job (mass army) is labelled sim-only. |
| C6 | **One Godot / FIFO and machine load** | `WAVE_G_CHARTER.md:31`; runner serialises jobs; long waits are telemetry, not hangs (`RUN_GUIDE.md:101`); headless `sync_ms` varied with `tick_ms` machine load (`PERF_3D_01.md:80-82`). | `status` before each job; one job at a time; record `runner_wait_s`/`runner_run_s`; no other CPU-heavy swarm work during a measurement triplet. |
| C7 | **Config layering / drift** | `config.json` is 240² now (`config.json:75-76`), A09 saw the same; `user://options.json` is a third merge layer (`config.gd:297-303`); `--seed` wins after merge (`main.gd:187-190`). | Pin seed and map via override configs; record `settings file:` + `--dump-config` per session; never call a 240² capture 320². |
| C8 | **Warm/cold caches, first-draw shader compile** | mip build + 683 MiB upload in one main-thread stage (`G17:59-71,105-145`); first-draw work held behind overlay only on Path I (`main.gd:657-670`, absent on Path S). | One warm-up per fixture, discarded; first 30 samples excluded; startup stages timed via Path I only. |
| C9 | **Metric semantics** | `TIME_FPS`/`Engine.get_frames_per_second()` are ~1 s smoothed; `_process(delta)` is smoothed; `TIME_PROCESS` excludes render; no GPU query. | Primary metric = raw `Time.get_ticks_usec()` wall delta at `frame_post_draw`; all other signals labelled by meaning in the schema. |
| C10 | **Stage timing proxy** | `t_load_usability.gd` samples 15 `loading_stage` transitions but `(a)` literal stall is UNVERIFIED (`LOAD_PROBE_REPAIR_01.md:118-138,149`). | Label stage deltas as wall proxies; request the `main.gd` hook in §4.3 for isolated stage CPU time. |

---

## 7. Minimum runs for a credible before/after

**Derived recommendation (not a claim):**

1. **One warm-up per fixture**, discarded (C8).
2. **Three independent `before` + three independent `after` runs per compared fixture** (64² and real map), interleaved `B/A/B/A/B/A`. Rationale: one run is an anecdote; two cannot estimate variance; three give a median and a visible range. This is **12 runs per fixture, 24 for the two primary fixtures**; with the optional 320² arm, +7.
3. If run-to-run `wall_ms.p50` spread > ~5 % or `p95` spread > ~10 %, raise to **five before + five after** per fixture (the prior headless evidence showed 1.5 % agreement in one pair but ±20 % machine-load caveats elsewhere — `PERF_3D_01.md:80-82`). Thresholds are a **measurement-design heuristic, UNVERIFIED**, not gates.
4. Startup-stage and Path I arms: same minimum 3+3 each, because the existing proxy showed ~21 s stage-to-stage wall deltas and high variance (`LOAD_PROBE_REPAIR_01.md:127-128`).
5. A change is credible only when `Δp50` and `Δp95` both move in the same direction beyond the combined ranges of the triplets, in **both** fixtures, with `script_error_lines=0` and unchanged seed/config/path. Otherwise report `NO CHANGE / UNVERIFIED`, never PASS. COORD alone advances any ladder row (`A09:453,491`).

---

## 8. What P09 did not do / open questions (all UNVERIFIED)

**Observed:** only this file was written. No Godot process, no runner job, no code/config/test edit, no process kill, no donor asset accessed beyond paths already named in the charter. No FPS number is claimed.

1. Whether the Path S `--screenshot` numbers will be better or worse than Path I is **UNVERIFIED** until both are run; the focus/vsync differences (C1/C2) are code-derived, not measured.
2. Whether `t_fps_probe.gd` will complete within its wall cap on this MX130 is **UNVERIFIED**; the predecessor atom's 64² headless run took 91.88 s with ~21 s stage proxies (`LOAD_PROBE_REPAIR_01.md:90-91,127-128`) — do not reuse that as an FPS expectation.
3. The monitor refresh rate, GPU clocks/VRAM, and effective cache-hit rate are **UNVERIFIED**; no `nvidia-smi` evidence exists in this audit.
4. Whether a vsync-off arm is safe/meaningful on Path I, and the exact availability of `DisplayServer.window_get_vsync_mode()` / `Window.has_focus()` in this Godot build, are **UNVERIFIED**.
5. Whether the "Loading art..." stage actually dominates startup on this machine is **INFERRED** from `G17:59-71,134-145`; only the §4.3 hook or a measured stage delta can settle it.
6. Donor parity remains **UNVERIFIED** throughout (no donor GPU A/B frame exists: `CHARTER.md:57-58,124-130`; `G04_gate_log.md:145-149`).

**Hand-off:** COORD clears the stale ticket 582 and re-runs `status`; G04 submits the ids in §3 in FIFO order with unique ids, pastes verbatim stdout/stderr/JSON evidence into `G04_gate_log.md`, and a second agent reviews captures per C04/A09 protocol. P09 submits nothing.

*End of P09_measurement.md — design only; all expected numbers UNVERIFIED.*
