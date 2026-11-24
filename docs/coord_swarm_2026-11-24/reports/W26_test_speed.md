---
owner: W2-6
date: 2026-11-24
directive: test-speed / T3 Scenario B + per-step timing + CLI frame budget
scope: app/scripts/main.gd, app/scripts/selftest.gd, this report only
status: PARTIAL — mechanism implemented and measured; <30 s standalone subset NOT achieved
---

# W26 — subset speed instrumentation, baseline snapshot, CLI frame budget

## 0. Headline

- **FIXED (MEASURED):** every one of the 29 steps now carries a per-step `wall_ms`
  field (bracketed with `Time.get_ticks_msec()`); T3's per-step ESTIMATEs are now
  MEASURED in the reports. Full gate re-run: 29/29 PASS, 99.31 s runner wall,
  37,149 ms summed step time, all 29 `wall_ms` fields present.
- **FIXED (MEASURED):** a post-setup `game.serialize()` snapshot is taken once in
  `_setup_full_game()` and restored before subset `run_only()` calls, with explicit
  restore of the state `serialize()` does NOT cover (`Data.AI_ENABLED`, `sow_t`, RNG
  stream state, transient events/projectiles/corpses/rubble). The peasant anchor is
  rebound after restore. Serialize/deserialize parity was printed on every restore.
- **FIXED (CODE, unmeasured end-to-end):** `--cli-frame-ms` / `--cli-ticks-per-frame`
  replace the hard-coded 40 ms / 1500 ticks in `_run_cli_incremental()`. Defaults are
  unchanged; fixed tick size `1.0 / Data.FPS` and tick order are untouched.
- **NOT ACHIEVED:** a standalone `--self-only <group>` process is still dominated by
  per-process map-gen startup. MEASURED baseline subset **115.33 s** wall (runner
  1258) and MEASURED post-change subset **123.05 s** (runner 1269) — the <30 s
  target is **NOT met**; the post-change job is actually ~7 s slower, consistent
  with the added `deserialize()` + parity check. The snapshot is a single-process
  facility: it removes cross-group state coupling, not the startup paid by a new
  Godot process. One-process multi-group mode (`run_groups`, selected by a comma
  in `--self-only`) exists but was not benchmarked in this ticket.

## 1. VERIFIED-ALREADY / FIXED / NOT-DONE

| Item | Status | Evidence |
|---|---|---|
| 8 `--self-only` groups, 29 steps, canonical gate 29/29 | VERIFIED-ALREADY | `reports/I04_test_split.md`; job 1249 |
| `--self-test` is output-only | VERIFIED-ALREADY | `main.gd:813-815,1510` (pre-edit) |
| Per-step cost was UNKNOWN | FIXED | 29 `wall_ms` fields, reports below |
| Single-process baseline snapshot + restore | FIXED | `main.gd:67,688-695`; `selftest.gd:46-115,178-183` |
| Parity proof for res_nodes hits / stats / blocked / squads / objectives / AI_ENABLED | FIXED (CODE + stdout) | §4 |
| `ticks_per_frame` / frame-ms CLI flag | FIXED (CODE) | `main.gd:85-86,867-874,1614,1624` |
| Standalone subset <30 s wall | NOT-DONE | MEASURED 115.33 s baseline / 123.05 s post-change, §6 |
| Multi-group one-process speedup measured | NOT-DONE | `run_groups` added but not benchmarked |
| Canonical `app/selftest.json` untouched | VERIFIED | §7 |

## 2. Backups (taken before first edit, hashes matched at copy time)

```
inbox/backup/main.gd.bak-W26      sha256 EC72C21504508A8CD7DEC5FA23805D2905E515B1FC2F0A7D01F716CDF4EC99F0
inbox/backup/selftest.gd.bak-W26  sha256 B51F2963655BC30451D2BF43503C0683B257CF65DC5D80B0EB08A0B5A7BE3141
```

## 3. Exact diffs

### 3.1 `app/scripts/main.gd`

| location | change |
|---|---|
| `:7-13` | header help: added `--self-only`, `--cli-frame-ms`, `--cli-ticks-per-frame` lines. |
| `:67` | `var selftest_baseline: Dictionary = {}` next to `selftest_only`. |
| `:85-86` | `var cli_frame_ms := 40.0`, `var cli_ticks_cap := 1500` (historical defaults). |
| `:688-695` | in `_setup_full_game()`, right after `game.setup()` and the `game_over` connect: `if selftest_path != "": selftest_baseline = game.serialize()`. |
| `:867-874` | argparse arms for `--cli-frame-ms` (clamp 1..60000) and `--cli-ticks-per-frame` (clamp 1..100000). |
| `:1529-1541` | `_run_selftest()`: fixed stale "about 1 s" comment; `st.set_baseline(selftest_baseline)`; `run()` for empty flag, `run_groups()` for a comma list, `run_only()` for a single group. `_write_text(selftest_path, …)` untouched. |
| `:1614` | `ticks_this_frame < 1500` → `< cli_ticks_cap`. |
| `:1624` | `> 40` → `> cli_frame_ms`, with comment that only the budget changes, not step size/order/semantics. |

### 3.2 `app/scripts/selftest.gd`

| location | change |
|---|---|
| `:33-38` | new fields: `baseline_snapshot`, `baseline_ai_enabled`, `baseline_sow_t`, `baseline_rng_state`, `baseline_gen_rng_state`, `_restore_count`. |
| `:46-53` | `set_baseline(d)`: deep-copies snapshot and captures AI_ENABLED, `sow_t`, and both RNG `state` values (via `Object.get`, not in `serialize()`). |
| `:55-59` | `_find_peasant()`: the old anchor loop, extracted. |
| `:61-80` | `_restore_baseline()`: `game.deserialize(baseline_snapshot.duplicate(true))`, then explicit restore of AI_ENABLED, sow_t, RNG states, and clearing events/projectiles/corpses/rubble. |
| `:82-98` | `_parity_print()`: stdout-only diagnostic comparing the six required fields after restore. No report-shape or assertion change. |
| `:100-115` | `run_groups(groups)`: loops `run_only(g)` (each restores baseline), concatenates steps, ANDs `passed`. |
| `:178-183` | in `run_only()`: restore before a named group, then rebind `peasant` **after** restore (deserialize swaps entity dicts). Canonical `run()` → `run_only("")` never restores. |
| 25 guards | one `var _t0 := Time.get_ticks_msec()` per top-level step guard. |
| 29 step dicts | `"wall_ms": Time.get_ticks_msec() - _t0,` added. The 4 compound blocks (upgrade/market, squad/formation, wall/shell, formation_bonus/replenish) rebase `_t0` before the second step so each step gets its own interval. |
| `:169` | the unknown-group step intentionally has **no** `wall_ms` (no timer in scope; early-return path). |

No assertion predicate, `detail` string, step name, or called symbol was changed. The
`TMCORE` diagnostic prints in `peasant_capture` were left verbatim.

## 4. Snapshot parity evidence

`game.serialize()` (`game.gd:5418-5453`) includes, verbatim:

- `"blocked": Marshalls.raw_to_base64(blocked)` (`:5447`)
- `"res_nodes": nodes` where each node copies **every** key, including `hits` and
  `mill` (`:5431-5436,5450`)
- `"squads": squads.duplicate(true)` (`:5451`)
- `"stats": stats.duplicate(true)` (`:5452`) — includes `shots`, `hits`, `kills`,
  `gathered` (`game.gd:199`)
- `"objectives": objectives.duplicate(true)` (`:5452`)
- also `players`, `entities`, `next_id`, `next_squad`, `time_s`, terrain, height, seed.

`game.deserialize()` (`game.gd:5455-5515`) restores each: `blocked` (`:5460`),
`res_nodes` incl. `hits` (`:5482-5486`), `squads` (`:5490`), `stats` (`:5492`),
`objectives` (`:5493`), plus `_grid_rebuild()` (`:5498`) and cache invalidations
(`:5499-5509`). Entity identity (`by_id`) and `next_id` are restored, so spawned ids
restart deterministically.

**Not** in the blob: `Data.AI_ENABLED` (static), `game.sow_t` (`game.gd:152`), the
`rng`/`gen_rng` stream positions (`game.gd:89,94`), and transient arrays (`events`,
`projectiles`, `corpses`, `rubble`). All are handled explicitly in
`selftest.gd:61-80`. `Peasant` is rebound at `selftest.gd:183`.

Runtime parity print (verbatim from runner ticket 1269 / `w26-subset` stdout):

```
SELFTEST baseline restore #1 parity: res_nodes=OK, stats=OK, blocked=OK, squads=OK, objectives=OK, ai=OK
```

Interpretation: res_nodes hits / stats / blocked / squads / objectives all compare
byte-equal between the restored game and the snapshot; `ai=OK` proves the static
global was restored by hand.

## 5. CLI frame budget — semantics note

`_run_cli_incremental()` still uses `var step := 1.0 / Data.FPS` and the exact order
`game.tick(step)` then `for brain in ais: brain.tick(step)` for every tick
(`main.gd:1611-1618`). The two new values only bound **how many** of those identical
ticks run before returning to `_process()`. With no flags, `cli_frame_ms = 40.0` and
`cli_ticks_cap = 1500` reproduce the old code exactly. Raising them does not change
dt, AI cadence, upkeep cadence, RNG draw order or any assertion; the headless
watchdog (`main.gd:1105-1108`) and the in-loop deadline break remain in force.
`--speed` remains a no-op in CLI mode (`main.gd:1121-1123` returns before the speed
accumulator) — unchanged.

## 6. Runner jobs and measured wall times

All jobs launched via `python app/tools/godot_runner.py run --id … --timeout … -- …`;
no direct `godot` invocation.

| ticket | id | command | runner `run` (s) | label |
|---|---|---|---|---|
| 1258 | `w26-baseline-subset` | pre-change formations_morale subset | **115.33** | MEASURED baseline |
| 1264 | `w26-parse-check` | `--check-only --script res://scripts/selftest.gd` | 17.36 | MEASURED parse OK, exit 0 |
| 1267 | `w26-full` | full selftest → `selftest_w26_full.json` | **11.90** | MEASURED, exit 1, no report — transient concurrent-edit failure, see §6.1 |
| 1269 | `w26-subset` | formations_morale → `selftest_w26_formations.json` | **123.05** | MEASURED, exit 0, 5/5 PASS |
| **1271** | **`w26-full-retry`** | full selftest → `selftest_w26_full.json` | **99.31** | MEASURED, exit 0, **29/29 PASS** |

Per-step `wall_ms` from `selftest_w26_formations.json` (MEASURED, sum ≈ **317 ms**):

| step | wall_ms | passed |
|---|---|---|
| morale | 315 | true |
| squad | 0 | true |
| formation | 0 | true |
| formation_bonus | 2 | true |
| replenish | 0 | true |

`sim_seconds` in that report is 10.0 (vs 10.375 in the pre-change baseline 1258) —
the baseline restore rewinds the few pre-selftest frames' ticks, as designed.

Full gate report 1271 (`selftest_w26_full.json`): `passed:true`, **29 steps**,
0 failures, `sim_seconds: 366.5625`, `shots_fired: 73`. Sum of all 29 `wall_ms`
= **37,149 ms**; runner wall 99.31 s ⇒ ≈62 s of startup/asset load on this
contended machine. Slowest MEASURED steps:

| step | wall_ms |
|---|---|
| save_load | 28,142 (outlier; see §9 item 5) |
| mine | 2,007 |
| act | 1,741 |
| nav_detour | 1,034 |
| farm_cap | 885 |
| wall | 758 |
| fight | 505 |
| build | 439 |
| train | 228 |
| peasant_capture | 189 |

This replaces T3's ESTIMATE ranking with MEASURED data: the two big soaks
(`act` 1.7 s, `mine` 2.0 s) are indeed the largest *simulation* steps, but the
`save_load` step (a fresh `C3Game` + `deserialize`) dominated this particular run.
The canonical gate printed **no** parity line, confirming `run()` → `run_only("")`
never restores.

### 6.1 Full-run ticket 1267 — transient, not a W26 regression

Ticket 1267 exited 1 after 11.90 s with only the Godot banner on stdout, empty
stderr and **no report file**. Neighbouring jobs in the same window also failed
(`w24-ai-wave` 1262 exit 1, `w23-hud` 1266 exit 1) while `git status` shows those
workers editing `game.gd`, `data.gd`, `hud.gd`, `ai.gd` concurrently. My own
`--check-only` at 1264 passed, and the very next job (1269) loaded the same
`main.gd`/`selftest.gd` and produced a clean 5/5 PASS with the parity print. A
clean full re-run (`w26-full-retry`) was therefore submitted and is reported below.

Comparison / conclusion: **MEASURED** standalone subset wall 123.05 s vs ~0.317 s
of actual step work ⇒ >99.7 % of the job is per-process startup (map-gen + asset
load + Godot boot). The baseline snapshot cannot remove that startup: it is taken
*after* setup, inside the same process. D-SPLIT-1's <30 s target is therefore
**NOT met** by any standalone `--self-only` invocation. The mechanism is still
useful for state isolation and for the one-process multi-group path, but a
disk-backed pre-baked snapshot loaded *instead of* `game.setup()` would be needed
for genuinely fast standalone subsets (§9).

## 7. Canonical artifact unchanged

Before runs: `app/selftest.json` mtime `2026-11-24T08:41:10.2854071Z`, size 3840,
sha256 `A864443C1BF6C5D25EDA76774AE296F3E6D3B7FA8A6BD2C7A3736F2CA09C8C57`,
`passed:true`, 29 steps.

After all runs (1267, 1269, 1271): mtime **unchanged**
`2026-11-24T08:41:10.2854071Z`, size **3840**, sha256 **unchanged**
`A864443C1BF6C5D25EDA76774AE296F3E6D3B7FA8A6BD2C7A3736F2CA09C8C57`,
`passed:true`, 29 steps. Both verification reports were written exclusively to
`app/tests/results/selftest_w26_full.json` and `…_formations.json`, as required.

## 8. Determinism note

All edits are test/tooling-only. No production file, map generation, seed, entity id
order, serialization order, assertion or `_sim` window was changed. The canonical
gate still calls `run()` → `run_only("")`, which never restores, so its step sequence
and pass predicates are unchanged (except the additive `wall_ms` report field).
Subset restores swap in a deep copy of the post-setup snapshot; RNG stream state is
explicitly restored so repeated groups see the same draw positions. The only known
determinism gap is the set of caches held by `world`/`hud` that still point at the
pre-restore entity dictionaries; headless selftest does not read those cached refs,
but a visual/windowed run of a restored subset is NOT VERIFIED.

## 9. Open questions

1. A standalone subset still pays full map-gen startup. Meeting <30 s requires a
   disk-backed pre-baked snapshot loaded **instead of** `game.setup()`, or a runner
   mode that produces all 8 subset reports from one process. Neither was in scope.
2. `run_groups()` (comma-separated `--self-only`) implements the one-process path but
   has no wall measurement; benchmark before claiming an aggregate win.
3. `world`/`hud` cached entity references after restore — verify visually if subsets
   are ever run in a windowed context.
4. The `capture` subset's order-sensitive `peasant_capture` FAIL/I4 §6 is unaffected:
   restoring before a group makes it cleaner, but this ticket did not change its
   predicate or group membership.
5. `deserialize()` re-runs `_assign_tileblocks()` (`game.gd:5514`), so a restore is
   not free. In full run 1271 the `save_load` step (fresh game + `deserialize`)
   measured 28,142 ms — a large outlier that may be OS contention from the
   concurrent swarm, but it means the multi-group `run_groups()` path's per-group
   restore cost is **UNVERIFIED** and must be measured before claiming an
   aggregate win. Add a `wall_ms` around `_restore_baseline()` to settle this.
