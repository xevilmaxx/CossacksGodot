---
owner: D1
date: 2026-11-24
scope: READ-ONLY micro-recon; one failing selftest step (`resow`)
status: diagnosis complete; fix proposed, not applied
---

# D1 — `resow` selftest FAIL: root cause and minimal truth fix

## Claim table

| # | claim | evidence (path:line + literal) | method | verdict | action |
|---|---|---|---|---|---|
| 1 | Fresh runner job 1232 produced exactly one FAIL: `resow`; `peasant_capture` now passes | `app/selftest.json:128-131` `"detail": "wild food nodes=0; depleted mill field re-sown: no; mill: auto=18 restored=1 gold=3353"`, `"passed": false`, `"step": "resow"`; `:122-125` `peasant_capture` passed | read runner artifact | observed | focus `resow` only |
| 2 | `wild_food == 0` is the intended T-FOOD-1 design, not a defect | `app/scripts/selftest.gd:364-367` counts food nodes with no `mill`; `game.gd:2624-2629` `if type == "food" and not n.has("mill"): continue`; `:2866-2869` `_say_human("Build a mill first…")`; `:5035-5038` drops wild-food gather order; `R01_farming_production.md:43` claim 18 CONFIRMED | literal read | observed | keep assertion; no change |
| 3 | `mill_ok` is TRUE; the FAIL is entirely `resow_ok` | `selftest.gd:402-403` `mill_ok = mill_fields.size() > 0 and manual > 0 and restored`; detail `auto=18 restored=1 gold=3353` ⇒ size=18>0, `manual=cmd_sow` return=1>0, and `cmd_sow` (`game.gd:2147-2155`) returns >0 only after `_restore_field`/`_sow_field_ring` create `hits>0`, hence scan `:398-401` sets `restored=true`; `:404` `passed = wild_food == 0 and resow_ok and mill_ok` | derived from code + detail | derived | no change to `mill_ok` |
| 4 | `restored=1` in the detail string is NOT the `restored` boolean; it is `manual` | `selftest.gd:403` `mill_detail = "auto=%d restored=%d gold=%.0f" % [mill_fields.size(), manual, game.players[0].res[3]]` (literal argument order: size, **manual**, gold) | literal read | observed | explains apparent contradiction |
| 5 | `resow_ok` measures terminal hits after 30 s, not the restoration event | `selftest.gd:383-389` `fnode.hits = 0` → `cmd_resow(rp, fnode)` → `_sim(30.0)` → `resow_ok = int(fnode.hits) > 0`; `_sim` at `:18-21` is `int(seconds/0.25)` = 120 × `game.tick(0.25)` | literal read | observed | root cause locus |
| 6 | A successful resow immediately puts the same peasant back to harvesting that same field | `game.gd:4599-4605` after 2.0 s work and `pay_cost(...,{"food":20})`: `_restore_field(fn)` then `e.order = {"type": "gather", "node": fn.id, "res": "food"}`; `_restore_field` at `:2159-2166` sets `node.hits = int(node.max_hits)` | literal read | observed | evidence that terminal hits decay |
| 7 | Field harvest consumes hits and can fully deplete the restored field inside a 30 s window | `game.gd:5081-5083` `if node.hits > 0: node.hits -= 1`; `:5077-5079` one hit per `Data.GATHER[res].interval`; `data.gd:553` `"food": {"hits": 22, "carry": 45, "interval": 1.25}`; `data.gd:560` `{"food": 3, ...}` workers; `game.gd:2138` `_add_res("food", p, 50, 0.6)` and `:508-510` `max_hits = hits` ⇒ 50 hits; 3 workers need ≥ ceil(50/3)×1.25 = 21.25 s to zero it | literal read + arithmetic | derived | quantifies window |
| 8 | Restore path itself is correct (independent PASS) | `app/tests/results/t_mill_logic.json:24-26` `{"detail": "paid resow hits 0 -> 21", "name": "resow_restores_field", "passed": true}`; `app/tests/mill_logic_test.gd:74-83` uses the same `int(resow_field.hits) > 0` assertion after 160×0.25 = 40 s with `Data.AI_ENABLED = false` | read artifact + source | observed | rules out CODE bug in `_restore_field` |
| 9 | Free 60 s regrow also restores depleted mill fields | `game.gd:3837-3840` `sow_t += dt; if sow_t >= 60.0: _tick_field_growth()`; `:2276-2286` restores every depleted food node with `_field_mill_id(n) != 0` | literal read | observed | noted as false-positive risk for peak-sampling fix |
| 10 | T-FOOD-1 probes exist as source but have no result JSON on disk | `app/tests/t_food1_repro.gd:53-78`, `app/tests/t_food1_reach.gd:25-41` both assert `hits > 0` after a fixed sim; `app/tests/results/` contains no `t_food1_*.json` | glob + read | observed | no runtime trace available this pass |

## Root cause

**Verdict: TEST bug (observation-window / terminal-state assertion), with flaky amplitude. Not a CODE bug.**

1. `selftest.gd:404` fails only because `resow_ok` (`selftest.gd:389`) is false: `int(fnode.hits) > 0` is sampled **after** `_sim(30.0)`.
2. `cmd_resow` is correct and is reached: `game.gd:2875-2886` accepts a mill-owned depleted field and sets `order = {"type":"resow"}`; the tick at `game.gd:4586-4605` walks to the slot, waits 2.0 s, pays 20 food, calls `_restore_field`, which sets `hits = max_hits = 50` (`game.gd:2159-2166`, `:2138`, `:508-510`). `t_mill_logic` proves this path PASSes independently (claim 8).
3. The same line `game.gd:4605` then changes the order to `gather` on **that same field**. `_tick_gather` decrements `node.hits` every 1.25 s (`data.gd:553`, `game.gd:5077-5083`), and up to 3 player-0 peasants may retarget to a ripe mill field (`data.gd:560`, `game.gd:5026-5031`). In the 30 s window the test leaves running **after** the resow, the restored 50 hits can be harvested to 0 (3 workers need only ~21.25 s). The assertion therefore reads a post-harvest steady state, not "was re-sown". This is a field state the design intentionally does not hold.
4. The apparent contradiction `restored=1` vs "re-sown: no" is a string-labelling artifact: `selftest.gd:403` formats `manual` (the `cmd_sow` return count, `game.gd:2147-2155`) under the label `restored=`, while the `resow` verdict uses a different variable, `resow_ok`, from the earlier 30 s resow probe. `cmd_sow` restoring 1 field confirms the shared `_restore_field` path works; it says nothing about the separately measured peasant order.
5. Exact terminal `hits=0` vs `hits>0` depends on how many idle/retargeting player-0 peasants pick `fnode` and on `sow_t` phase (the 60 s `_tick_field_growth` at `game.gd:3837-3840`), so the FAIL's magnitude is order/timing-dependent — but narrowing the window does not hide a broken resow: a resow that never completes leaves `hits=0` in **any** window.

## Minimal-fix section

**Test file, one literal. No production code, no assertion weakening.**

- File: `app/scripts/selftest.gd`
- Line: **388**
- Change: `_sim(30.0)` → `_sim(10.0)`
- Leave line 389 exactly as-is: `resow_ok = int(fnode.hits) > 0`
- Leave lines 402-405 and all `resow_ok`/`mill_ok` conjuncts exactly as-is.

Equivalent diff description:
```
-       _sim(30.0)
+       _sim(10.0)
        resow_ok = int(fnode.hits) > 0
```

Justification of 10 s: resow needs 2.0 s of work (`game.gd:4599`) plus a ~1 m walk to `_work_slot` (`game.gd:4591-4594`); the field starts with 50 hits (`game.gd:2138`) and the fastest possible depletion is 3 workers × 1 hit/1.25 s (`data.gd:553,560`), i.e. ≥21.25 s. A 10 s window preserves the restoration evidence with ~11 s of margin while a genuinely failed resow still yields `hits == 0` and FAILs. Not weakening: stronger timing requirement, identical boolean predicate.

**Invariant that must still hold:** after `cmd_resow` on a depleted, mill-owned `food` node with 20 food available, `node.hits` transitions `0 → >0` within 10 sim-seconds AND remains consistent with `_restore_field` (`hits == max_hits`, `growth == 1.0`, `regrow_t == 0.0`); a failed/non-executed resow must still make `resow_ok == false`. `wild_food == 0`, `manual > 0`, `mill_fields.size() > 0` and `restored` stay strict.

Rejected alternative (recorded, not proposed): replacing line 389 with a per-tick peak sampler `peak = max(peak, fnode.hits)` over 30 s is larger and can be satisfied by the unrelated 60 s `_tick_field_growth` free regrow (`game.gd:2276-2286`), i.e. it would admit a false positive — stricter truth is the shorter window.

## Determinism / gates

- Production code untouched (`game.gd`, `data.gd`, generator unchanged) ⇒ seed dumps must remain **byte-identical**; no new RNG, no change to `res_nodes` order, `next_id`, or serialize order. If a worker instead touches `game.gd`, require byte-identical seed-dump A/B before merge.
- Rerun gate: fresh `coord-baseline-selftest` runner job; require `resow` PASS. Because `fnode = mill_fields[0]` is a first-match in `res_nodes` order, also rerun twice to separate the fixed test fix from the known `peasant_capture` flake; do not count `peasant_capture` for this diagnosis.
- Corroboration gate unchanged: `t_mill_logic` (already 6/6 PASS, `resow_restores_field` PASS) plus the two T-FOOD-1 source probes if result JSONs are produced.

## Open questions

1. No on-disk trace from `t_food1_repro.gd` / `t_food1_reach.gd`; the depletion-after-restore mechanism is derived from code + `t_mill_logic` numbers, not directly observed in the failing selftest run. A one-off instrumented run printing `rp.order`, `fnode.hits` per tick (the probes already do this at `t_food1_repro.gd:73-77`) would convert the derived step to observed.
2. Should `mill_detail`'s second `%d` be relabelled from `restored=` to `cmd_sow=` at `selftest.gd:403`? Purely cosmetic; optional follow-up, not part of the truth fix.
3. If the owner wants donor-faithful partial field regrowth (R01 claim 2 / `G-F4`), the 60 s `_tick_field_growth` could itself restore `fnode` during a longer window; the 10 s fix avoids that confound, but a future regrow change should re-check this step.
