---
owner: I6
date: 2026-11-24
ticket: R06 rank-1 / claim C4 (metal-mine starvation)
area: app/scripts/ai.gd
backup: inbox/backup/ai.gd.bak-I6-METAL
charter: exclusive ownership of ai.gd + this report only; no direct Godot, runner only
---

# I06 — metal-mine starvation fix (R06 rank 1, claim C4)

## Backup

`Copy-Item app\scripts\ai.gd inbox\backup\ai.gd.bak-I6-METAL` — confirmed present (`BACKUP OK`) before any edit.

## What was changed (exact diff, final line numbers)

All edits are in `app/scripts/ai.gd`; tabs match the surrounding file. No other source file was edited by me. `git diff -- app/scripts/ai.gd` hunks:

1. **`app/scripts/ai.gd:168-205`** — `C3_AI_TRACE` row extended (env-gated, diagnostic only, no sim effect). Added: local `force` sum over `military`; `jobs` histogram of peasant orders (incl. `stone`, `mine`, `build`, `idle`); `stone_d` = distance from home to nearest live stone node; row keys `gold/iron/coal`, `mines_fin.gold/iron/coal`, `force`, `wave`, `jobs`, `stone_d`, `blds`. Exact new row keys:
   ```
   "gold": snappedf(res.gold, 1.0), "iron": snappedf(res.iron, 1.0), "coal": snappedf(res.coal, 1.0),
   "mines_fin": {"gold": int(fin.get("mine_gold", 0)), "iron": int(fin.get("mine_iron", 0)), "coal": int(fin.get("mine_coal", 0))},
   "force": snappedf(force, 1.0), "wave": wave,
   "jobs": jobs, "stone_d": stone_d, "blds": counts,
   ```
   Reason: R6's existing trace (`ai.gd:157-178`) printed food/wood/stone/mills only; without this, mine/force/wave could not be observed at all. The `OS.get_environment("C3_AI_TRACE") == ""` early return is unchanged, so selftest/uitest stdout is unaffected.

2. **`app/scripts/ai.gd:231-239,261,271`** — `_economy`: while either metal mine is missing and `stone < 100`, stone quota is floored (`3` when `n<16`, else `5`) and stone is served **first** in both idle-assignment and surplus loops:
   ```
   var metal_pending: bool = int(counts.get("mine_iron", 0)) == 0 or int(counts.get("mine_coal", 0)) == 0
   var stone_first: bool = metal_pending and float(res.stone) < 100.0
   if stone_first:
       want["stone"] = maxi(want["stone"], 3 if n < 16 else 5)
   var kinds: Array = ["stone", "food", "wood"] if stone_first else ["food", "wood", "stone"]
   ...
   for kind in kinds:   # both loops (was ["food","wood","stone"])
   ```
   Reason found by soak: flat 0.15 quota left 0-3 stone workers; 80 stone in 300 s total, so `mine_coal` never reached its 100-stone cost. No threshold/config change; `want` food/wood shares untouched.

3. **`app/scripts/ai.gd:380-397`** — `_build` mine order and extra-barracks reserve:
   ```
   - for k in ["gold", "iron", "coal"]:
   + for k in ["iron", "coal", "gold"]:
   ...
   + var metal_ready := int(counts.get("mine_iron", 0)) > 0 and int(counts.get("mine_coal", 0)) > 0
   + var bar_stone := 150.0 if metal_ready else 300.0
   - if int(counts.get("bar", 0)) < 3 and res.wood >= 150 and res.stone >= 150:
   + if int(counts.get("bar", 0)) < 3 and res.wood >= 150 and res.stone >= bar_stone:
   ```
   Mill-first block (`:329-332` → final `:369-372`) and the first 150-stone barracks (`:338-339` → final `:378-379`) are byte-identical. Mine cost gates (`wood>=100`, `stone>=100`) and `_build_mine()` are untouched.

4. **`app/scripts/ai.gd:394-402,421-422`** — discretionary stone sinks (`sto`, `bla`, `wal`, `tow`) are wrapped in `if metal_ready:` / `and metal_ready`; they no longer eat the trickle that funds `mine_coal`. `bar18`, `sta`, `aca`, `cen`, market are unchanged (their own high gates already defer them).

Not touched: `game.gd` resource cheat, `config.json`, `Data.AI_ATTACK_FORCE`, `_waves` cadence, difficulty tiers, RNG calls. No `random`; `_find_spot` still uses seeded `game.rng` only.

## Runner jobs (all through `python app\tools\godot_runner.py run`; no direct Godot)

| Ticket / id | Command variant | Result | Wall run |
|---|---|---|---|
| 1239 `i6-ai-metal-soak` | task command, `C3_AI_TRACE=1`, 300 sim s requested | **ok** | 122.15 s — app default 120 s wall cap stopped it at `sim_seconds=126.46875` |
| 1242 `i6-ai-metal-soak` | same plus app `--timeout 500` (defeats default 120 s wall cap) | **ok** | 220.69 s — full `sim_seconds=300.0` |
| 1245 `i6-ai-metal-soak` | after adding economy/stone changes | **failed** (parse error, `var stone_first :=` could not infer bool) | 359.98 s — no trace rows; fixed by explicit `: bool` types |
| 1247 `i6-ai-metal-soak` | final code, app `--timeout 500` | **ok** | 90.85 s — full `sim_seconds=300.0` |

Tickets 1239/1242 used the build-order-only version; 1247 used the final build-order + stone-quota + sink-deferral version and completed before the coordinator's stop instruction. No further jobs were queued after that instruction. Reader note: `C3_AI_TRACE=1` is any non-empty value (`ai.gd:158`).

## Soak evidence (verbatim trace rows, player 0 = AI)

**Ticket 1239 (`app/.godot_queue/results/00001239_i6-ai-metal-soak/stdout.txt`)** — first metal mine appears, coal does not:
```
C3AITrace {"coal":150.0,...,"force":20.0,"gold":94.0,"iron":110.0,...,"mills_fin":1,"mines_fin":{"coal":0,"gold":0,"iron":1},"p":0,...,"stone":0.0,"t":43.0,"wave":0,"wood":70.0}
C3AITrace {"coal":150.0,...,"force":20.0,"gold":94.0,"iron":169.0,...,"mills_fin":1,"mines_fin":{"coal":0,"gold":0,"iron":1},"p":0,...,"stone":0.0,"t":126.0,"wave":0,"wood":98.0}
```
CLI report: `"sim_seconds": 126.46875`, `"resources_gathered": {"food":1134,"iron":60.16,"wood":112}` — **no stone key**, and that run was truncated by the app's 120 s wall limit.

**Ticket 1242 (`.../00001242_i6-ai-metal-soak/stdout.txt`)** — full 300 s, build-order-only:
```
C3AITrace {"coal":150.0,...,"force":20.0,"gold":94.0,"iron":110.0,...,"jobs":{"build":2,"food":7,"idle":0,"mine":0,...,"stone":1,"wood":1},...,"mines_fin":{"coal":0,"gold":0,"iron":1},...,"stone":0.0,"stone_d":64.0,"t":43.0,"wave":0,"wood":70.0}
C3AITrace {"coal":150.0,...,"force":20.0,"gold":94.0,"iron":804.0,...,"jobs":{...,"stone":3,"wood":7},...,"mines_fin":{"coal":0,"gold":0,"iron":1},...,"stone":20.0,"stone_d":64.0,"t":299.0,"wave":0,"wood":196.0}
```
CLI report: `"sim_seconds": 300.0`, `"resources_gathered": {"food":4470,"iron":942.08,"stone":80,"wood":444}` — one `mine_iron`, **no `mine_coal`**, stone income only 80 over 300 s. This is the evidence that the ordering fix alone is insufficient: the flat stone quota and cheap stone sinks keep stone at 0.

**Ticket 1247 (`.../00001247_i6-ai-metal-soak/stdout.txt`)** — final code, full 300 s, both metal mines:
```
C3AITrace {"blds":{"bar":1,"cen":1,"mar":1,"mil":1,"mine_iron":1},"coal":150.0,...,"force":0.0,"gold":100.0,"iron":150.0,...,"mines_fin":{"coal":0,"gold":0,"iron":1},"p":0,...,"stone":0.0,"t":42.0,"wave":0,"wood":70.0}
C3AITrace {"blds":{"bar":1,"cen":1,"mar":1,"mil":1,"mine_coal":1,"mine_iron":1,"sto":1},"coal":150.0,...,"force":40.0,"gold":88.0,"iron":385.0,...,"military":4,...,"mines_fin":{"coal":1,"gold":0,"iron":1},...,"stone":80.0,"t":290.0,"wave":0,"wood":68.0}
C3AITrace {"blds":{"bar":1,"cen":1,"mar":1,"mil":1,"mine_coal":1,"mine_iron":1,"sto":1},"coal":150.0,...,"force":40.0,"gold":88.0,"iron":415.0,...,"military":4,...,"mines_fin":{"coal":1,"gold":0,"iron":1},...,"stone":80.0,"t":299.0,"wave":0,"wood":96.0}
```
CLI report: `"sim_seconds": 300.0`, `"winner": -1`, `"player0_buildings": 7`, `"player0_units": 34`, `"resources_gathered": {"food":3194,"iron":1852.5,"stone":360,"wood":768}`.

### Acceptance scorecard (honest)

| R6 criterion | Result | Evidence |
|---|---|---|
| ≥1 finished `mine_iron` | **PASS** (from t=42-43 onward) | `mines_fin.iron=1`, `blds.mine_iron=1` in all three soaks |
| ≥1 finished `mine_coal` | **PASS only in final-code soak 1247** (t=290); FAIL in 1239/1242 | `mines_fin.coal=1`, `blds.mine_coal=1` at t=290/299 |
| non-zero iron/coal balance | **IRON PASS** (`iron=415` at t=299; also 804 before final change), **COAL only trivially PASS** (`coal=150.0` unchanged from `config.json` starting 150 — **no coal accumulation observed**) | quoted rows; note `config.json:45-46` starts both at 150 |
| `force >= 120` | **FAIL / NOT MET** — max `force=40.0` at t=299; `military=4` | quoted rows; `_waves` gate `Data.AI_ATTACK_FORCE=120` not reached |
| `wave >= 1` | **FAIL / NOT MET** — `wave=0` at every trace row | quoted rows |
| `mine_gold` | **NOT BUILT** in any soak (deliberately last in the mine loop; never reached 100 stone after the metal mines) | `mines_fin.gold=0` |

Because `force`/`wave` are now exposed by the env-gated trace, these are **measured failures**, not merely "unverified". The harness CLI report itself still does not print force/wave or per-building ids; the quoted values come from `C3AITrace` rows emitted by the trace extension, not from the CLI JSON. The UI test (`i6-ai-metal-uitest`) was **not run**; full selftest was **not run** (coordinator runs the gate).

## Determinism note

No RNG was added and no seed stream was changed. `_find_spot` still draws from the seeded `game.rng`; `_build_mine` still picks the nearest deposit by distance with the same strict `< best_d` rule. The change is a **resource-spend/assignment order** change: mine order `gold,iron,coal` → `iron,coal,gold`, stone served before food/wood while a metal mine is missing, and cheap stone sinks deferred. Therefore **golden CLI traces will change** (different building/resource snapshots at a given tick), but the RNG consumption order/seed sequence is unaffected in kind — no new random calls, only the same calls reached in possibly different tick order. Trace output is gated behind `C3_AI_TRACE`, so default stdout stays clean. No difficulty tier, wave cadence, threshold value or `game.gd` cheat was touched.

## Open questions

1. Why does `force` stall at 40 with `military=4` despite `food=849`, `food_ok=true`, `food_workers=15`, `iron=415` and a finished `bar` at t=299? Likely `_train` gates or `train_unit` cost/queue behaviour, not the mine fix; needs an owner of `_train` behaviour to inspect (not mine to change).
2. `mine_coal` finished only at t=290 (near the end of the 300 s window) — is that "early" enough for the rank-1 acceptance, or should stone priority be stronger earlier? Stronger food trade-off was not attempted to avoid famine regressions.
3. Coal balance is the starting 150 untouched; `mine_coal` is finished but no coal accumulation seen by t=299. Is it staffed (`jobs` shows `mine=2`, no explicit `jobs.coal` for player 0 at the end)? Deposit left / travel distance needs a longer or different soak.
4. The 1245 failure (parse error on `:=` with Dictionary Variant) was fixed; coordinator may want a final full gate to confirm no compile regressions.
5. `ai_starving` real-famine override at `ai.gd:301-314` can still recall stone workers during a real famine; not changed (outside rank-1 scope).
6. Both AI players run this code; player 1 also ends with both mines in soak 1247 but only 13 units — asymmetry from per-player deposit geometry (`stone_d` 82 vs 64) was not investigated.
