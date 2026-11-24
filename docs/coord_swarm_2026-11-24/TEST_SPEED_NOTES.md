# Test speed: are we running at x1 game speed? (owner question, 2026-11-24)

**Short answer: no. Both running test modes are already accelerated beyond x1, and
`--speed 10` would have NO effect on them.** Evidence below.

## 1. CLI soak (I6's 300 s AI test) — already flat-out

- `main.gd:1121-1122`: in `cli_mode`, `_process()` calls `_run_cli_incremental()`
  and **returns before** the speed accumulator at `:1132` (`acc += dt * speed`).
  So `--speed` / `--fast` (`main.gd:868-871`) only affect windowed/normal play.
- `main.gd:1575-1593`: `_run_cli_incremental()` loops `while cli_ticks_left > 0`
  doing `game.tick(step)` + `brain.tick(step)` up to **1500 ticks per frame** with
  a 40 ms frame budget — it runs as fast as the CPU allows, never waiting for
  real time.
- `main.gd:631`: `cli_ticks_left = int(cli_seconds * Data.FPS)`;
  `data.gd:32` `FPS := 32.0`, so 300 sim-seconds = **9,600 fixed ticks** executed
  back-to-back, not 300 real seconds.
- Conclusion: adding `--speed 10` would not shorten this soak. The only safe
  levers are (a) fewer sim-seconds (weakens the acceptance soak — not allowed),
  or (b) raise the 40 ms/1500-tick per-frame budget (headless-only tooling change,
  no change to step size/order — a possible follow-up, not currently assigned).

## 2. Selftest (I4's 29-step gate) — also accelerated, and dt is capped

- `selftest.gd:38-41`: `_sim(seconds)` calls `game.tick(0.25)` — **4 ticks per
  sim-second**, i.e. already 8× fewer ticks than the 32 FPS real-time rate.
- `game.gd:37` `TICK_MAX := 0.25` and `game.gd:3820` `dt = minf(dt, TICK_MAX)`:
  **dt cannot be raised above 0.25**, so an x10-style larger step is impossible
  without changing simulation semantics (AI cadence, upkeep, cooldowns, RNG
  draw order) and breaking determinism/byte-identical dumps.
- T3 measured 88.82 s wall for the full 29-step run; ~43.6 s is fixed startup
  (map-gen), only ~45 s is the ~1,566 ticks. The startup, not x1 waiting, is the
  bottleneck. T3 Scenario B (single-process baseline snapshot restore) is the
  real route to faster subsets; deferred with a state-parity proof required.

## 3. Decision

- Do NOT add `--speed 10` to these runner commands — it is a no-op in CLI mode
  and impossible in selftest (dt clamp).
- Do NOT shorten `_sim` windows or `cli-seconds` to fake speed — that weakens
  assertions (D-SPLIT-1 / PERFORMANCE_SWARM §5).
- Recorded possible follow-up: optional headless-only CLI frame-budget flag
  (40 ms → e.g. 200 ms, 1500 → 4000 ticks/frame), which preserves step size and
  order, plus T3 Scenario B for selftest startup. Neither changes game code.
