---
id: PORT1TO1-DETERMINISM-AUDIT
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: WORKER AUDIT-DETERMINISM — read-only audit of every fixed-seed replay / donor-comparison divergence in variant3d
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_determinism_audit.md
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_GODOT_GIT_DONOR_EXECUTION
created: 2026-11-26
labels: [OBSERVED, DERIVED, UNVERIFIED, "PORT APPROXIMATION", "PRESERVE-ONLY"]
parity_status: UNVERIFIED
parity_claim: false
scope_guard: "Exactly one repo file written (this report). No source, shader, asset, config, test, fixture, result JSON, git state, Godot process or donor binary touched. No capture was produced by this worker. All line numbers are from the current on-disk tree read directly."
governing_sources:
  - docs/terrain_swarm_2026-11-26/PORT1TO1_PLAN.md (task list; §Preserve-only user mods)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_acceptance_plan.md (§2 capture protocol, SHA/determinism gates)
  - variant3d/scripts/{main,menu,config,game,audio,ai,asset_paths}.gd
  - variant3d/scripts/{terrain_donor_mesh,terrain_donor_gen,terrain_donor_inputs,water3d,world,world3d_fx}.gd
  - variant3d/{config.json,config_donor_capture.json}
  - variant3d/assets/models/manifest.json
  - variant3d/tools/acceptance/capture_sequence.py
---

# PORT1TO1 — determinism / divergence audit (fixed seed 20261113)

> **Verdict required verbatim:** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. This audit identifies replay hazards and preserve-only divergences; it certifies neither donor fidelity nor a gate pass.

> **Owner acceptance is snapshot/video-driven** (`PORT1TO1_acceptance_plan.md` §0/§2). Every claim below is a static code/config observation `[O]` or a derived inference `[D]`; no experiment was executed by this worker, and no donor GPU A/B frame exists under the read-only rule.

## 0. Classification used in this report

| Class | Meaning | Effect on fixed-seed replay |
|---|---|---|
| **N** | True nondeterminism (wall clock, process-start RNG, frame pacing, async timing) | **Breaks port-vs-port zero-mismatch replay** until neutralized; these are the P0 items. |
| **D** | Deliberate, deterministic user-modified divergence (config/asset/opt-in) | Replay is stable **if the same config/asset bytes are pinned**, but port-vs-donor comparison is invalid unless documented. **Preserve-only — document, do not remove.** |
| **U-INJ** | `[U]` value injected into live sim or render state without donor proof | Deterministic in port-vs-port, but an **undocumented donor divergence**; each keeps its stated fixed-seed/zero-mismatch experiment. |

A fixed-seed replay is admissible only when: seed is the literal `20261113` (never `random`), the config file SHA-256 is recorded and identical, no Class-N path is active, and runner stderr contains no `watchdog:` / `cli: wall-clock limit reached` line.

---

## 1. Class N — nondeterminism that breaks port-vs-port replay

### N1 — Process-start wall-clock seed via `--seed random`  `[O]`

- **Exact site:** `variant3d/scripts/main.gd:1377-1380` parses `--seed random` → `seed_random = true`; `variant3d/scripts/main.gd:192-193` applies `Data.RANDOM_SEED = int(randi())`. `randi()` here is the **global Godot RNG**, which is auto-seeded at process start (no `.seed`/`seed()` call anywhere in `variant3d/scripts` targets it — see the full seed-site census in §6). It is therefore wall-clock/process-dependent.
- **Gating config:** **no config key**; CLI flag `--seed random` only. The harness records `deterministic=false` for this value (`variant3d/tools/acceptance/capture_sequence.py:282-284`) and warns on stderr.
- **Effect:** all seeded streams (`game.gd:375,378,389,600-601`, `main.gd:294-296`, `pattern_gen.gd:91,318`, `mapgen.gd:60`, `game.gd:1946,2530,3046`) start from a different key → entire map/sim diverges.
- **Exact fixed-seed experiment:** never pass `--seed random`; use `python variant3d/tools/acceptance/capture_sequence.py --seed 20261113 …` (plan §2.3). Assert in the produced `manifest.json` that `deterministic == true` and `seed == "20261113"`. Run the same capture twice with the same config SHA and compare `sha256_pixels` per frame — any mismatch with `deterministic=true` is a separate Class-N defect, not this one. **Document** the `random` path as a user feature; do not remove it.

### N2 — Menu "Random" seed button  `[O]`

- **Exact site:** `variant3d/scripts/menu.gd:905-908` creates `RandomNumberGenerator`, calls `rng.randomize()`, returns `rng.randi_range(0, 99999999)`; `:915-917` and `:943-944` write it to `seed_val` and `Data.RANDOM_SEED`. `main.gd:294-296,389-390` then propagates it into the game config (`cfg["seed"]`).
- **Gating config:** interactive menu only; the Random button, or typing the literal string `random` into the seed field (`menu.gd:915`). Not reachable in test/capture modes, which bypass the menu (`main.gd:238-253`).
- **Exact fixed-seed experiment:** drive captures through the bypass (`--screenshot`, `--seq`, `--bench`, `--cli`, `--selftest`, `--battle`, `--journey`) and type `20261113` if the menu is unavoidable; assert the emitted cfg contains `seed = 20261113` and that `Data.RANDOM_SEED` equals `20261113` in the run log. Never use the Random button in an acceptance capture. Preserve-only UI feature — document, do not remove.

### N3 — Unseeded global `randf()` injected into live sim (fisher target)  `[O]` — **P0 sim hazard**

- **Exact site:** `variant3d/scripts/game.gd:8127-8128`: `var rr: float = (0.5 + randf()) * FISHER_RADIUS_MOVE_CHANGE` and `var ang: float = randf() * TAU`, feeding `e["fish_target"]` and `e.order` at `:8129-8130`. These are **global** `randf()` calls, not `rng`/`sim_rng`/`brng`; no `.seed` site covers them. `FISHER_RADIUS_MOVE_CHANGE = 15` is donor-grounded text (`game.gd:7991`), but the **draw source is not**.
- **Gating config:** no flag; executes whenever a fisher completes a delivery (`_step_fisher`, around `game.gd:8108-8130`). Any scenario with a mine/fisher and enough elapsed sim time can hit it.
- **Effect:** two identical-seed runs produce different fisher targets → different positions, collision/nav results, delivery timing and all downstream state. This **alone invalidates a fixed-seed port-vs-port replay** of any scenario containing a fishing delivery.
- **Exact fixed-seed experiment:** seed `20261113`, one identical config copy, one fisher with a known delivery; run `N=3` CLI captures to the same `game.time_s`; dump `fish_target` (x,y) and `e.order` at the delivery tick plus a full state hash at that tick. Termination: all three draws and hashes byte-identical. Neutralization (owner-side, not performed here): route both draws through the seeded `sim_rng` in the same order, or freeze the fisher target; until then every capture containing a fishing delivery is inadmissible as a zero-mismatch replay. **Do not change code under this read-only audit; document as an open P0.**

### N4 — Unseeded global RNG in audio (clip pick + pitch)  `[O]`

- **Exact site:** `variant3d/scripts/audio.gd:360` `names[randi() % names.size()]`; `:368` `p.pitch_scale = randf_range(0.92, 1.08)`. Global RNG, never seeded.
- **Gating config:** `audio.enabled` (`config.json:162`, applied `config.gd:702`), non-empty `players`, and `can_play = not is_headless` (`main.gd:671-674`). Also guarded by a wall-clock dedup window at `audio.gd:334-337` (`Time.get_ticks_msec() / 1000.0`, 0.09 s) — frame-time dependent.
- **Effect:** no sim state is consumed, but audio clip choice, playback pitch and event timing differ between runs; an audio-inclusive replay cannot be zero-mismatch. The global RNG state is not shared with the seeded sim streams (§6), so it does not corrupt N3-type determinism, but it is its own divergence.
- **Exact fixed-seed experiment:** for pixel captures use a temp config copy with `audio.enabled=false` and confirm three identical `sha256_pixels`; for audio captures record the WAV and hash it — expect mismatch until the two draws are seeded. Preserve-only audio behaviour — document, do not remove.

### N5 — Wall-clock watchdog / deadline truncates ticks  `[O]`

- **Exact sites:** `main.gd:174` `started_ms = Time.get_ticks_msec()`; `:214-220` `deadline_ms = started_ms + hard_limit*1000` for any capture/test/bench/cli/seq mode; `:1610-1613` forced exit at deadline; `:1654-1655` breaks the tick loop within 500 ms of deadline; `:2187-2189` CLI break within 200 ms; `:2205` `cli_done` on deadline; `:1678` bench wall_seconds. `--timeout` parsed at `main.gd:1355-1357`; the harness passes `--timeout = max(5, ns.timeout-30)` (`capture_sequence.py:157-158`, recorded at `:329-330`).
- **Gating config:** CLI `--timeout`, harness `--timeout`/`--max-wait`. `hard_limit = limit_s if limit_s > 0 else 120.0` (`main.gd:214`).
- **Effect:** the number of sim ticks actually executed before capture/exit depends on wall time and machine speed. Two runs of the same seed can capture different `game.time_s` / `cli_t`, or one can be killed mid-sequence.
- **Exact fixed-seed experiment:** run the identical `--seq-seconds`/`--cli-seconds` capture twice with two different timeouts (e.g. 240 s and 600 s). Require `seq_index.json.sim_seconds` identical, per-frame `sha256_pixels` identical, and neither runner log containing `watchdog:` or `cli: wall-clock limit reached`. Pin the timeout value in the run notes; use a timeout comfortably above expected runtime for final captures. Preserve-only watchdog — document, do not remove.

### N6 — Frame-rate-driven sim stepping / frame-count screenshots  `[O]`

- **Exact sites:** `main.gd:1636-1642` `dt = minf(dt, 0.25); acc += dt*speed; step = 1/Data.FPS; while acc >= step and steps < 64`; `:1751-1753` single screenshot fires on render-frame count `frame >= screenshot_frames` (default 120 at `:69`, CLI override at `:1288`); speed changes at `:1371-1375` (`--fast` → 8.0, `--speed`). VSync at `config.json:60` (`display.vsync=true`) applied `main.gd:570-571` / `:1101-1102`.
- **Gating config:** `gameplay.render_mode` (`config.json:80`), `display.vsync` (`:60`), `--speed`/`--fast`, `--screenshot-frames`.
- **Effect:** sim time at screenshot frame *N* depends on real frame pacing; a 60 Hz and a 30 Hz run of the same seed capture different world states. The `--seq` path is safer because it triggers on `game.time_s` (`main.gd:1762-1764`), but it still inherits N5.
- **Exact fixed-seed experiment:** use the tick-driven path: `--seq` with fixed `--seq-step`, or CLI mode with a fixed `--cli-ticks` count / MCP `game.tick` to an exact tick. Run `N=3`; require `seq_index.json.sim_seconds` and every frame SHA identical. Any `--screenshot` (frame-count) capture must be labelled non-replay-stable and excluded from zero-mismatch claims. Preserve-only capture modes — document, do not remove.

### N7 — Async load yields let sim ticks run between load stages (interactive only)  `[O]`

- **Exact sites:** `main.gd:552-689` `_do_async_load()` awaits `get_tree().process_frame` at `:562-563,548-549` (via `_loading_tick` `:543-550`) and `RenderingServer.frame_post_draw` at `:687`; `ais` is created at `:666` (`_create_ai_brains`). `_process` at `:1624-1627` returns while `ais.is_empty()`, so ticks cannot start before `:666`, **but** the awaits at `:667`, `:682` and `:687` occur after AI brains exist and before `load_ready = true` (`:694`).
- **Gating config:** interactive menu path, i.e. `is_headless == false` and no capture/test/bench/cli/seq flag (`main.gd:238-255,266-277`). Headless/test path uses synchronous `_setup_full_game()` (`main.gd:1096-...`).
- **Effect:** the number of sim ticks during the last three load frames depends on render pacing → different start-of-match state.
- **Exact fixed-seed experiment:** compare a fixed-seed interactive launch against a same-seed/same-config headless synchronous launch; dump `game.time_s` at the first captured frame. Require zero offset. For acceptance, always use the capture/test modes that bypass the menu (`main.gd:238-253`), which removes this path. Preserve-only staged loader — document, do not remove.

### N8 — Render-frame/GPU fallback in sequence and screenshot capture  `[O]`

- **Exact sites:** `main.gd:2142-2164` `_save_seq_frame()` awaits `RenderingServer.frame_post_draw` at `:2148`, reads the viewport texture at `:2149-2152`, and **if blank/empty substitutes `_render_headless_image(800,600)` at `:2153-2154`** while still writing `mode="window"` into `seq_index.json` (`:2160`). Single-shot path: `main.gd:1885-1901` sets `SubViewport.UPDATE_ONCE` and awaits `frame_post_draw` at `:1887`, reads `vp.get_texture()` at `:1896-1901`.
- **Gating config:** windowed (not headless) `--seq` or `--screenshot`; `capture_view3d` created by `_setup_screenshot_window` (called at `main.gd:251-252`).
- **Effect:** captured pixels depend on GPU draw completion timing; a silent CPU-map substitution changes resolution and content while the manifest still claims `window`.
- **Exact fixed-seed experiment:** apply the admissibility gate in `PORT1TO1_acceptance_plan.md` §2.3: require `headless=false`, `capture_semantics="windowed seq = real viewport frames (frame_post_draw)"`, `resolution_observed == 1280×720`, `resolution_matches_request == true`; any 800×600 frame is a **failed capture**. Run `N=3` and compare `sha256_pixels`. Preserve-only fallback — document, do not remove; never treat a substituted frame as a replay capture.

### N9 — Save/load seed rewrite  `[O]`

- **Exact sites:** `game.gd:9334-9335` `if d.has("seed"): Data.RANDOM_SEED = int(d.seed)`; `:9361-9370` RNG state restore (`rng`, `gen_rng`, `sim_rng` or seed fallback). `main.gd:969-971` contains a self-snapshot **seed-mismatch refusal** for the `--self-only` path only.
- **Gating config:** a cfg carrying `load_save` (`main.gd:700-705`, menu `menu.gd:894`), or any `deserialize()` call.
- **Effect:** loading a save made under a different seed silently changes the stream key for subsequent tile art and sim draws; a "fixed seed" replay that loads a save is not actually under seed 20261113 after load.
- **Exact fixed-seed experiment:** do not use `load_save` in replay captures; if a save must be used, assert `d.seed == 20261113` and all three restored RNG states match the pre-save values byte-for-byte, then run `N=3` from the same save and compare frame hashes. Preserve-only v5 save state — document, do not remove.

---

## 2. Class D — deliberate divergences (deterministic; preserve-only, document not remove)

Each item below is **stable under a pinned config/asset hash**, so it does not by itself break port-vs-port replay. It *does* break port-vs-donor comparison unless explicitly documented. The plan's §Preserve-only user mods (`PORT1TO1_PLAN.md:172-179`) governs all of them.

### D1 — `features.terrain.demo_mill`  `[O]`

- **Exact sites:** `variant3d/config_donor_capture.json:32` sets `"demo_mill": true`; `config.json` has **no key** and documents absence as normal skirmish at `config.json:17`. Gate: `game.gd:3856-3860` `_demo_mill_enabled()` → `cfg.flag("features.terrain.demo_mill", false)`. Consumers: `game.gd:3851-3852` `_spawn_demo_mill(starts[0])`; `:3862-3892` deterministic ring search and `spawn("mil", …)` with marker `terrain_demo_mill`; `:3247`, `:3379` `_sow_field_ring(..., _demo_mill_enabled())`; `ai.gd:278-287`.
- **Effect:** adds a finished mill + donor-spaced field lattice, changes entity layout, resource nodes and AI sowing. Donor QA fixture, **not donor skirmish law**.
- **Exact experiment:** two fixed-seed captures with identical temp configs except this single key (`--config` copies; harness records `config_sha256_file` at `capture_sequence.py:344`). Diff entity count, mill position and field-ring cells; assert the flag value in the manifest config hash. Document which config was used in every capture note. **Do not remove the flag or the spawn path.**

### D2 — `features.terrain.color_unify`  `[O]`

- **Exact sites:** `config.json:31` `"color_unify": true` (README rationale at `:18`); `config_donor_capture.json` omits it → false. Gate: `terrain_donor_mesh.gd:982-989` (`_resolve_color_unify_flag`), key const at `:229`. Calibration constants at `:230-235`; arithmetic at `:1020-1067` (gain ≈ `[1.05972, 1.05376, 1.77340]`); bound at `:1566-1567` and `:1633` as shader uniform `color_unify_gain`; suppresss `light_match` (`:1569-1580`).
- **Effect:** multiplies the packed donor Blinn-Phong term only; visual-only, deterministic. Explicitly **PORT CALIBRATION, not donor parity** (`terrain_donor_mesh.gd:1021,1046`, `config.json:18`).
- **Exact experiment:** fixed seed, two temp configs differing only in this key; compare grass/mine-halo ROIs (`PORT1TO1_acceptance_plan.md` §1.2 D1/D5) and require the telemetry `color_unify.bound_gain` to be `[1,1,1]` in the off run. Record which gain was used. Preserve-only owner calibration — document, do not remove.

### D3 — `features.terrain.array_atlas` / `hires_atlas` / `light_match`  `[O]`

- **Exact sites:** `terrain_donor_mesh.gd:197` (`HIRES_ATLAS_FLAG_PATH`), `:202` (`ARRAY_ATLAS_FLAG_PATH`), `:211` (`LIGHT_MATCH_FLAG_PATH`); resolvers `:948-968`; fallback `:1118-1237`; applied at `:594`, `:1430-1438`, `:2006-2010`, `:1563-1580`. **Neither shipped config sets these keys**, so all three resolve false; opt-in only.
- **Effect:** changes tile binding/atlas tier and light-rig energy binding, visual-only and deterministic. `array_atlas` is explicitly suppressed by `hires_atlas` (`:964,:1125`).
- **Exact experiment:** fixed seed, toggle one flag on a temp config copy; record `_array_atlas` / `atlas_mode` / `light_match` telemetry and compare `sha256_pixels`. Document the active tier in every capture note. Preserve-only opt-ins — document, do not remove.

### D4 — EUR aliases / nation move / field-palm-desert conversions  `[O]`

- **Exact sites:** `variant3d/assets/models/manifest.json` `bucket: "ukr/buildings"` at `:1880,1905,1930,1955,1980,2005,2030,2155` (nation move) and `:4872-5071` (ukr building stages/attachments); `commoneur` meshes aliased into `shared/buildings` at `:2040-2060` (`eursto`), `:2065-2085` (`eurmil`), `:2090-2110` (`eurmar`), `:2115-2135` (`eurtow`), `:2164+` (`eurswa`) — the EUR aliases; conversions preserved by `.backup-CONVERT-PALM-DESERT-20261126/manifest.json`. Consumer: `asset_paths.gd:15-51` (manifest index), `:54-92` (`bucket_for`/`res_for`/`existing` priority).
- **Effect:** 3D geometry/texture/sprite selection only; no sim state. Deterministic given the manifest bytes.
- **Exact experiment:** fixed seed, one capture with the shipped manifest and one with a temp copy of the backup manifest (owner-side); compare building/roof/sprite ROIs (`PORT1TO1_acceptance_plan.md` §1.2 D7), record manifest SHA-256 in the run notes. Preserve-only owner asset migrations (`PORT1TO1_PLAN.md:175`) — document, do not remove.

### D5 — Config numeric overrides (port-vs-donor and config-vs-config)  `[O]`

- **Exact sites / divergent keys:**
  - `config.json:83` `random_seed = 20261113` ↔ `config.gd:134,540` default 20261113 ↔ `game.gd:249` static 20261113.
  - `config.json:88` `start_resources.gold = 200` vs `config_donor_capture.json` `1000` (verified full JSON diff) — **sim divergence**.
  - `config_donor_capture.json` `gameplay.terrain_type = "land"`; `config.json` has none and uses `map_type="land"` (`:113`) while the built-in default is `"mediterranean"` (`config.gd:137-139`, applied `:575`) — **map-generation divergence**.
  - `config.json:93` `build_queue_limit = 10` vs `config.gd:151,553` default 12 (owner override explicitly preserved in plan task 82).
  - `config.json:158-159` `ai.attack_force=120`, `ai.max_peasants=40` vs `config.gd:713-714` defaults 60 / 14.
  - `config.json:117-160` economy/AI scalars applied at `config.gd:680-724` (gather hits/interval, morale, drummer bonus, deploy seconds, market rate, thresholds, difficulty multipliers at `:720-724`).
  - `config.json:42` `camera.fov_deg=17.27` (labelled APPROX in plan task 62), `:76` `start_zoom=0.3448276`, `:67-77` camera block; applied `config.gd:527-535`.
  - `config.json:29-31` terrain backend `donor`, `relief_stamps=true`, `color_unify=true`; `config_donor_capture.json:29-32` backend `donor`, `relief_stamps=true`, `demo_mill=true`.
- **Gating config:** every key above; `--config <file>` at `main.gd:1359-1362`. The harness hashes the chosen file (`capture_sequence.py:344`).
- **Effect:** different config bytes → different map, starting stock, queue cap, AI cadence, movement/morale scalars and camera — all deterministic but non-comparable.
- **Exact experiment:** pin a single config SHA-256 for every member of a replay set; for port-vs-port require identical `config_sha256_file` in all manifests; for donor comparison emit a key-by-key diff table (the four divergent keys between the two shipped configs are listed above) and attach it to the capture note. Preserve-only user config — document, do not remove/edit any config key in this audit.

### D6 — Donor-side wall-clock Delphi seeder (donor comparison only)  `[O]/[U]`

- **Exact site:** `terrain_donor_gen.gd:845` records the donor seeder `[O] sub_4033b8: QPC-low dword else GetTickCount`; `:846-847` records `[U] U4` generation-time state with `state_image = 0`, hook NULL → **placeholder, not an invented per-map seed**, with terminating probe at `0x83272f`.
- **Gating config:** none in port; the port never reads a wall clock for this state.
- **Effect:** a donor run restarted with the same nominal seed may still have a different Delphi generation state; port uses image 0. This is a **donor-comparison** hazard, not a port replay hazard.
- **Exact experiment (owner, donor execution forbidden for this worker):** break at `0x83272f`, dump u32 @`0x8f2008` before the call at `0x832727`; terminate U4 only when every byte equals `state >>> 24` and a restart changes the seed. Until then document the placeholder and do not claim donor generation parity.

---

## 3. Class U-INJ — `[U]` values injected into live sim / render

All items here are **deterministic** (fixed literals or fixed config values) and therefore do not break port-vs-port replay when config is pinned, but they are **undocumented donor divergences** and each retains its named zero-mismatch experiment. None may be "closed" by a port fallback or by this audit.

| ID | Exact site | Live gate / config | Injected value | Exact fixed-seed experiment |
|---|---|---|---|---|
| U-INJ-1 | `game.gd:5203` | `e.aur_dru` true; `economy.drummer_speed_bonus` (`config.json:145`, `config.gd:691`) | `×1.12` speed, donor grep 0 rows `[U]` U-carry/U-formation | Seed 20261113, one drummer + one peasant, identical config; N=3 runs, log `effective_speed()`/position per tick; require identical traces, then label difference from donor as PORT APPROX. |
| U-INJ-2 | `game.gd:5205` | `e.routing == true` (morale path `game.gd:6909-6913`) | `×1.35` run speed `[U]`, donor runaway has no scalar | Seed + force a rout; N=3, dump `routing_t` and positions per tick; zero mismatch required; divergence documented. |
| U-INJ-3 | `game.gd:6408`, `:6423`, `:6427` | `_step_move()` always; `slope_to`/`height_at` terrain | instant step (no accel) `[U]` U-accel; uphill `esp *= 0.6` `[U]` U-terrain; instant `face` snap `[U]` U-turn | Seed on fixed relief map; one mover on a known slope; N=3, dump pos/face/esp per tick; zero mismatch; keep T-ACCEL/T-TERRAIN/T-TURN open. |
| U-INJ-4 | `game.gd:6882-6914` (rates `6.0`/`3.0` at `:6906`, `+25.0` at `:6913`) | all non-support units; `economy.morale_base`/`morale_rout_threshold` (`config.json:142-143`, `config.gd:688-689`) | entire numeric morale/rout stack `[U]` U10 — donor absent (2,559 files, 0 hits) | Seed, fixed damage schedule; N=3, dump `morale`, `routing`, `routing_t` per tick; zero mismatch; donor comparison must state "donor has no numeric morale". |
| U-INJ-5 | `game.gd:7298-7306` | artillery units; `economy.artillery_deploy_seconds` (`config.json:147`, `config.gd:693`) | `2.0 s` deploy + remaining fire gates `[U]` U9 | Seed, one cannon firing continuously; N=3, dump `deploy_t`/`cooldown`/shot ticks; zero mismatch; U9 stays open. |
| U-INJ-6 | `game.gd:8431,8434` | garrisoned `tow`/`cen` fire/heal | `2×` garrison fire/heal `[U]` CS-GARRISON — donor garrisons only mines/ferry (`game.gd:8162`) | Seed, garrison 3 peasants in a tower vs empty tower; N=3, dump damage/heal per tick; zero mismatch; label port rule, not donor law. |
| U-INJ-7 | `terrain_donor_mesh.gd:1614,1623-1625,1634-1635` | terrain shader build always | `alpha_test_ref=-1.0` `[U] U-6b` (no threshold invented), specular zero, `shininess=16`, `shadow_enabled=0`, `fog_mode=0` | Seed, fixed camera, fixed seed capture; N=3 `sha256_pixels` identical; each value keeps its GL/zero-mismatch probe; no threshold invented to force a match. |
| U-INJ-8 | `world3d_fx.gd:650,1427-1439` (8-float rule at `:1437`) | `pfx_random_stream != null`; default `null` | owner-injected object exposing `randf()` `[U]` U7 — **no value fabricated while null** | Seed, same FX events, run with stream `null` (deterministic) and with a seeded stream; N=3 each; require per-run identical FX transforms; document the stream identity if ever injected. |
| U-INJ-9 | `water3d.gd:309,355,374-384` (shader `water3d.gdshader:78,215-216,245,260,286,311,366-370`) | water built only with U12 FBO/sampler/texture and U4* scalar source (`features.water.*`, `config.json:33-37`) | `_time += delta` accumulator `[U5]` SCAFFOLDING, not a donor value | Seed, freeze `_time = 0` (U5 candidate); N=3 fixed-seed seq, compare water ROI hashes; current hard-fail (no water) is the only deterministic state. Do not invent a writer value. |
| U-INJ-10 | `game.gd:7790-7791` | **inert** — no consumer (`game.gd:7991`) | `GLOBAL_DROP_RADIUS[_SQR] = 3.0/9.0` `[U]-E1` | No capture needed for behaviour; verify with a grep that both constants remain unreferenced before any wiring; do not delete or wire. |
| U-INJ-11 | `ai.gd:15,94` + annex `ai.gd:1383,1419` | AI brain tick gate | `_TICK_AI_S = 2.4` is `[O]` donor literal; the **G-stream free-run from QPC/TickCount** at `:1383` is `[U]-G1` text only (never wired) | Seed, AI-only run; N=3 dump AI decision ticks and stream draws; zero mismatch; keep G/S attribution (`G1-b/G1-g`) open, never assume a stream split. |

Additional `[U]` registers in `game.gd:8148-8171` (capture flush state Q-*), `game.gd:9662-9678` (RNG ledger G1/S*), `terrain_donor_gen.gd:857-888` (placement/relief U-G0…U-MAX) and `data.gd:3727,4392,4858` (termination harnesses) are **telemetry/experiments, not live value injections**; each already states its own fixed-seed zero-mismatch termination. They are not neutralized here and must remain labelled.

---

## 4. Explicit preserve-only list — document, never remove

The following are owner choices carried forward under `PORT1TO1_PLAN.md:172-179` and `config.json:2-19`. This audit **does not modify, gate off, or delete any of them**; each must be recorded in capture notes with its controlling file hash:

1. `variant3d/config.json` — donor backend default, `color_unify=true`, all numeric overrides (§D5), comments.
2. `variant3d/config_donor_capture.json` — `demo_mill=true`, `start_resources.gold=1000`, `terrain_type="land"` (§D1/D5).
3. `variant3d/assets/models/manifest.json` — nation move (`ukr/buildings`), EUR aliases (`shared/buildings`), field/palm/desert conversions, plus `.backup-CONVERT-PALM-DESERT-20261126/` (§D4).
4. `main.gd`/`world3d.gd` I11 seam and `.bak-COORD-I11`.
5. `game.gd` demo-mill/fields/builder-stands/v5 save state and backups `.bak-FIELDS`, `.bak-SPAWN`, `.bak-BUILDERSTANDS`, `.bak-MILLSOW`, `.bak-COLLCALL`.
6. Shader/mesh opt-ins: W04 texgen, tile-map binding, neutral shore alpha, `hires_atlas`, `array_atlas`, `light_match`, `color_unify`, exact `sceneColor = 0.2` (`terrain_donor_mesh.gd:128,1626`).
7. Temporary capture configs under `%TEMP%\opencode\v42\` and `inbox/qa/captures/`.
8. Watchdog, async staged loader, CPU-map screenshot fallback and the audio/Random-seed paths (§N1–N8) — all preserved as owner features and documented as replay hazards.

---

## 5. Exact fixed-seed experiment template (owner-runnable; not run by this worker)

1. Create fresh temp config copies from `variant3d/config_donor_capture.json`; set the literal `gameplay.random_seed = 20261113` and record each file's SHA-256 (plan §2.3).
2. Preflight exactly as in `PORT1TO1_acceptance_plan.md` §2.1: `godot_runner.py status`, `assert_clean.py --json`, `py_compile`, ffmpeg/ffprobe/Pillow present.
3. Capture, one job at a time, through the runner:
   `python variant3d/tools/acceptance/capture_sequence.py --seed 20261113 --frames N --step S --label detaudit --view wide=<temp_config> --mode seq --timeout 240 --max-wait 3600 --out inbox/qa/captures/detaudit_<tag>`
4. For each run assert in `manifest.json`: `deterministic=true`, `seed="20261113"`, `config_sha256_file` equal to the temp copy, `status=ok`, `complete=true`, `resolution_matches_request=true`, `parity=UNVERIFIED`.
5. Repeat the **identical** job `N=3` times into fresh directories. Zero-mismatch gate: per-frame `sha256_file` and `sha256_pixels` identical across all three; `seq_index.json.sim_seconds` identical; runner stdout/stderr free of `watchdog:`, `cli: wall-clock limit reached`, and any fallback/blank substitution.
6. For each Class-N item, additionally vary only its gating condition (timeout value, audio flag, demo_mill/array_atlas/color_unify flag, render path) and record which variation changes pixels — that is the documentation evidence required for the corresponding §1/§2 item.
7. Any mismatch keeps the affected `[U]`/`[O]` item open; no test is weakened and no port fallback may close it. Unit-test gates are **not** the acceptance path (plan §0).

---

## 6. What is NOT a divergence (bounded so the claim above is exact)

All other RNG in `variant3d/scripts` is explicitly seeded from `Data.RANDOM_SEED` and is **not** a wall-clock source: `game.gd:375,378,389,600-601,1946,2530,3046`; `main.gd:294-296`; `pattern_gen.gd:91,318`; `mapgen.gd:60`; `world.gd:837`; `game.gd:9609` (`DonorRandomExt.set_state(0)`). The only unseeded global RNG calls in the whole `scripts/` tree are `main.gd:193`, `game.gd:8127`, `game.gd:8128`, `audio.gd:360`, `audio.gd:368` (verified by full-tree grep). `Time.get_ticks_*` calls not listed in §1 are timing/benchmark telemetry only (`heightmap_world3d.gd:151-263`, `world3d_terrain.gd:1221-1679`, `selftest.gd:235+`, `input_controller.gd:363,1125,1793,1838`, `hud.gd:1207,1217`) and do not feed sim state except where cited.

---

## 7. Verdict

- **Port-vs-port fixed-seed replay:** INCOMPLETE. N3 (unseeded fisher `randf()`) is a confirmed P0 sim hazard; N1/N2/N5/N6/N7/N8/N9 are conditional hazards that must be excluded by the capture protocol in §5 before any zero-mismatch claim.
- **Port-vs-donor comparison:** UNVERIFIED. D1–D6 and U-INJ-1…11 are deterministic but must be documented per capture; §D6 keeps the donor Delphi seeder unresolved.
- **Preserve-only choices:** all items in §4 are documented, not removed.
- **No approximations introduced, no tests weakened, no parity claim.** No donor binary was executed, no Godot process launched, no capture produced and no git state touched by this worker.
