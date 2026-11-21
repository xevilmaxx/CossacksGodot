# Diagnosis of the five "pre-existing" selftest failures

**Ticket:** T5-SELFTEST-DIAG (read-only). **Date:** 2026-11-21.
**Scope:** `wall`, `shell`, `flee`, `peasant_capture`, `farm_cap` as named in
`SWARM_BOARD.md:477-480` (24/29 control run). No code, no Godot runs.
**Bottom line:** all five are **test-harness fragility / coupling, not gameplay
defects**. The underlying mechanics are implemented and have been observed green
on the same code paths. No fix to `game.gd` is warranted.

---

## 0. Evidence base and an important discrepancy

| Artifact | Observed state | Relevance |
|---|---|---|
| `app/selftest.json` (mtime 21:08 local) | `"passed": true`, **29/29**, all five named steps green (`wall` "stone wall built"; `shell` "wall ok, rally set, objectives 2"; `flee` "3.0 -> 3.9 m"; `peasant_capture` "player 0"; `farm_cap` "500 -> 525 -> 500") | The current on-disk file **contradicts** the board's 24/29 claim. The failures are intermittent, not a stable red. |
| `app/report.json` (06:33) | `"passed": false`, **24/29**. Red: `build`, `wall` ("stone wall missing"), `shell` ("wall missing, rally set, objectives 2"), `peasant_capture` ("player 1"), `farm_cap` ("475 -> 475 -> 475"). `flee` is **green** here (3.0 -> 4.5 m). | Only stored failing full report. Its red set is *not* the board's set: `build` instead of `flee`. |
| `app/selftest_patterns.json` (05:34) | 28/29; only `farm_cap` red ("500 -> 500 -> 500"); `wall`, `shell`, `flee`, `peasant_capture` green | Shows the same steps flipping across runs. |
| `inbox/relief1_selftest_seed7.json` | 28/29; only `farm_cap` red ("500 -> 500 -> 500") | Same. |
| `inbox/relief1_selftest_ridge7.json` | 29/29 including `farm_cap` 500 -> 525 -> 500 | Same test, different map layout → green. |
| `app/app_selftest.json`, `inbox/relief1_v2_selftest*.json`, `inbox/relief1_selftest_default.json`, `..._gentle7`, `..._noheight7`, `..._ravineonly7`, `..._final_selftest.json` | all 29/29 green | 12+ stored runs where all five named steps pass. |
| `SWARM_BOARD.md:473-480` | T5-AI-FIX → 23/29 (5 pre-existing + fragile `resow`); T5-TESTFIX → 24/29; "remaining 5 pre-existing failures (wall, shell, flee, peasant_capture, farm_cap) reproduced in control with original ai.gd; no assertion weakened" | Board's canonical statement of the five. |
| `SWARM_BOARD.md:41-44` | P-01 (`wall`), P-02 (`shell`), P-03 (`peasant_capture`), P-04 (`farm_cap`) marked DONE, "resolved by A-01 work; R-01 selftest confirms pass" | These exact steps were green after the earlier wave, then regressed without a game-mechanic change. |
| `QA_REPORT.md:10,19-23` / `:182` / `:217` / `:271` / `:325` | `farm_cap` 500->500->500 red at ticket 13; green 29/29 at O5, O6, O7, O8 | Long history of the same step flipping. |
| Cross-run detail drift | Mine deposit reported **73 m** away in `app/report.json` vs **19–36 m** in every other full report; `formation_bonus` detail "+9" in old reports vs "+7" now (donor P-30 changed the constant and the test expectation) | Map layout and test expectations change between runs; these steps read local map state. |

**Consequence:** any verdict of "the game is broken" is contradicted by repeated
green runs of the very same assertions on the same mechanics. The failures are
environment/order dependent.

---

## 1. Per-step diagnosis

| Step | Exact assertion / detail (`app/scripts/selftest.gd`) | Gameplay code exercised | Verdict | Evidence | Minimal fix (target file:line) | Acceptance |
|---|---|---|---|---|---|---|
| **wall** | `:262` `var wall_ok := not wall.is_empty()`; `:265` `wall_ok = wall.finished or wall.progress > 0.0`; `:266-267` `"passed": wall_ok`, `"detail": "stone wall %s" % ("built" if wall_ok else "missing")`. Placement at `:260-261` via `_spot("wal", peasant.pos)` → `game.place_building(...)`. | `can_place` `game.gd:3069-3123`; `place_building` `game.gd:3125-3176`; def `data.gd:999` (`wal` cost wood 10 / stone 20). Test tops up wood+stone at `:258-259`. | **(b) TEST fragile** — exact root cause UNVERIFIED (see claim C6). | "stone wall missing" means `place_building` returned `{}` — either `_spot` (`:23-33`) found no legal tile in its fixed rings ≤24 m, or `can_place` rejected the site. Green runs prove the mechanic works. By this late stage the run has spawned ~40 entities (cannon, mills, squads, towers, halls), so the fixed ring around `peasant.pos` is congested; relief/rim terrain changes (`game.gd:711+`, T5-GEN) alter legality between runs. | `selftest.gd:23-33` — replace/extend `_spot` with a deterministic clear-patch scan (same technique already used by `nav_detour` at `:453-490`: find an open 14×14 tile block, then place at its centre). At `:260-267`, if no spot is found, make the detail report `_spot` = INF explicitly instead of collapsing to "missing". Do **not** relax `wall_ok`. | Step green in 10 consecutive fresh headless runs across default/relief/richness configs; detail names the reason on failure; `game.gd` unchanged. |
| **shell** | `:274` `"passed": wall_ok and rally_ok and obj_ok`; `:275` `"detail": "wall %s, rally %s, objectives %d"`. | Rally `game.set_rally` (`:268-270`), objectives (`:271-273`). **No shell/cannonball damage is exercised at all** — the real shot assertion is `attack_ground` at `:394-401`. The name is a legacy misnomer. | **(b) TEST fragile + mislabelled**, pure cascade. | `app/report.json:99-101`: `"wall missing, rally set, objectives 2"` — rally and objectives both passed; the only red input is `wall_ok`. Green runs with wall green (all 12+ reports) pass. | `selftest.gd:274-275` — drop `wall_ok` from this step's predicate (wall stays asserted in the `wall` step) and **strengthen** it: add a real cannonball check (spawn cannon, `cmd_attack` a cluster, assert `stats.shots` grew and a target lost HP, or a `cannonball` projectile event exists). Keep name `shell`, keep 29 steps. | Step passes while `wall` is artificially forced red; step fails if rally, objectives **or** cannonball damage regresses. Net assertion strength increases. |
| **flee** | `:315-316` `if fleer.order.type == "move": fled = true`; `:318` `"passed": fled and d1 > d0`; `:319` detail `"serdiuk fell back from pikes: %s (%.1f -> %.1f m)"`. | `game.gd:3919-3951`, specifically `:3941-3946`: 17c shooters (`no_melee`) under min range convert the attack order to a 4 m "move" away. `data.gd:517-522`: serdiuk `no_melee=true`, bullet `min = 400*PX_TO_M ≈ 15 m`; 3 m start is far inside it. Pikeman speed 1.2 m/s (`data.gd:501-503`), serdiuk 1.2 m/s. | **(b) TEST fragile**; game mechanic verified correct by code. Exact failing detail **UNVERIFIED** (no stored red report). | Every one of 12+ stored reports shows `flee` green with a razor-thin **3.0 -> 3.9 m** margin in 1.5 s (6×0.25 s ticks). `d1 > d0` competes with a pikeman closing at the same speed and with blocked retreat terrain; a 0.9 m margin flips easily. `fled` (order-type) is robust; the distance term is not. Also: AI brains tick only in `main.gd:1002-1004`, **not** inside the selftest's direct `game.tick()` loop, so "AI interference" is not the live mechanism (board phrasing is imprecise). | `selftest.gd:306-319` — keep `fled`, replace `d1 > d0` with a deterministic measure: freeze the chaser (no attack/move order, assert `chaser.order.type != "move"`) and assert the fleer moved **≥0.5 m away from the chaser's original position** over 12 ticks (3 s), plus an explicit fail if `fleer.dead`. This preserves "falls back from pikes" without a moving reference. | Deterministic pass with a stationary chaser; fails under mutation when the `no_melee` fallback at `game.gd:3941-3946` is removed. |
| **peasant_capture** | `:344-347` spawn `efoe` at `epos`, `epike` at `epos + Vector2(1, 0)`, `cmd_attack`, `_sim(5.0)`; `:348` `"passed": int(efoe.player) == 0`, detail `"peasant captured: player %d"`. | `game.gd:4292-4305` `_apply_hit` flips `t.player` on a hit by a non-peasant enemy when `Data.CAPTURE_ENABLED` (`data.gd:57`, true). Pikeman pike `min = 35*PX_TO_M ≈ 1.31 m`, `max ≈ 3.75 m` (`data.gd:501-503`). | **(b) TEST fragile**; game mechanic verified correct. | `app/report.json:124-126` red ("player 1"); all other stored reports green ("player 0"). The test spawns the pikeman **1.0 m from the target — inside the pike's 1.31 m minimum range**, so the "too close, step back" branch (`game.gd:3947-3951`) fires first; if terrain blocks the back-step, no hit ever lands in 5 s. `epos` is chosen by a walkability scan (`:338-343`) that can still land next to a footprint; no reachability assertion exists. | `selftest.gd:344-348` — spawn `epike` at `epos + Vector2(2.5, 0)` (between min 1.31 and max 3.75 m); assert both spawn points are `not game.is_blocked(...)`; extend `_sim(5.0)` → `_sim(10.0)`; enrich detail with `efoe.hp`, distance and `epike.order.type`. Keep `efoe.player == 0` unchanged. | Green in 10 fresh runs across map configs; fails under mutation when `CAPTURE_ENABLED=false` or the capture branch at `game.gd:4292-4305` is removed. |
| **farm_cap** | `:434` `cap0`; `:437-446` place `hou` at `_spot("hou", ...)`, wait up to 240 ticks for `finished`; `:447-450` `cap1`, `cmd_delete`, `cap2`; `:451` `"passed": cap1 == cap0 + 25 and cap2 == cap0`, detail `"farm %d -> %d -> %d"`. | `_on_building_finished` `game.gd:1784-1787` adds `def.farm`; `_kill` `game.gd:3508-3509` subtracts only for **finished** buildings; `cmd_delete` `game.gd:3570-3576`. `data.gd:969`: `hou` farm = **25** — the `+25` constant is current, not stale. | **(b) TEST fragile**; game mechanic verified correct by code + green runs. | Red detail is always flat — "500 -> 500 -> 500" (`app/selftest_patterns.json`, `inbox/relief1_selftest_seed7.json`), "475 -> 475 -> 475" (`app/report.json`), "500 -> 500 -> 500" (`QA_REPORT.md:22`). A flat triple means the test house **never finished** (so `cmd_delete` on an unfinished site changed nothing) or `_spot` returned INF. Note `cap0` itself drifts 500→475 between runs — cumulative state from earlier steps / mapgen. Green runs show the exact expected 500 -> 525 -> 500. | `selftest.gd:433-451` — reuse the deterministic clear-patch helper from the `wall` fix; explicitly pick a live peasant and assert `order.type == "build"`; on timeout, report `houtest.progress`, builder id and distance instead of a bare triple. Keep `cap1 == cap0 + 25 and cap2 == cap0`. | Green in 10 fresh runs; fails under mutation when the farm increment/decrement at `game.gd:1787` / `:3509` is removed. |

### Why this is not a game bug (per step)

- **wall / farm_cap / shell:** `place_building`, `can_place`, `_on_building_finished`
  and `_kill` are single-source-of-truth functions with no branching on RNG;
  identical inputs produce identical results. The differing inputs are the test's
  chosen coordinates and the accumulated map state. No player action can make a
  wall unbuildable that `can_place` would wrongly reject — a wall is even exempt
  from the `is_blocked` rule (`game.gd:3121`).
- **flee:** the fallback is explicit and deterministic given `d < w.min`; the
  serdiuk starts at 3 m against a 15 m minimum. The mechanic is verified.
- **peasant_capture:** capture is an unconditional branch in `_apply_hit`; the
  only question is whether a hit lands, which is a test setup/spawn-distance issue.

---

## 2. Ranking by leverage, risk and effort

| Rank | Item | Root cause | Player-visible risk of fix | Effort | Note |
|---|---|---|---|---|---|
| 1 | **wall + farm_cap** (and transitively **shell**) | Shared: `_spot` (`:23-33`) cannot guarantee a legal build tile on the late-game / relief map; test reports only a binary "missing" / flat triple | **None** (test-only) | Low — one shared helper + two call-site detail improvements | Highest leverage: one fix clears three of five reds. |
| 2 | **shell** | Predicate couples to `wall_ok` and tests no shell damage | **None**; assertion gets stronger | Low — one predicate line + optional cannonball check | Do after rank 1 so the cascade source is green; decoupling also prevents future false reds. |
| 3 | **peasant_capture** | Spawn at 1.0 m is inside the pike's 1.31 m min range; 5 s window; no reachability assert | **None** | Low — spawn offset + window + detail | Isolated, easy mutation-testable. |
| 4 | **flee** | `d1 > d0` measures against a moving same-speed reference over 1.5 s | **None** | Medium — must redesign the distance check without weakening semantics | Lowest urgency: green in all stored reports; failure detail not on disk. |

**Effort estimate:** ranks 1–3 are a handful of lines in `selftest.gd` only;
rank 4 needs a considered replacement assertion. Zero lines in `game.gd`.

---

## 3. Claim table

Legend: **Observed** = read directly from a file/line in this repo;
**Derived** = logical consequence of observed code/data;
**Inferred** = best explanation consistent with evidence but not proven by a stored run;
**UNVERIFIED** = no stored evidence, no Godot run permitted.

| ID | Claim | Class | Basis |
|---|---|---|---|
| C1 | The five named steps are green in `app/selftest.json` (29/29) and in 12+ stored reports; red only in some runs. | Observed | `app/selftest.json`; `app/app_selftest.json`; `inbox/relief1_*`; `app/report.json`; `app/selftest_patterns.json` |
| C2 | The only stored failing full report has `build` red instead of `flee`. | Observed | `app/report.json:28-32` vs `:113-116` |
| C3 | `shell` in `app/report.json` failed solely because `wall` failed; rally and objectives passed. | Observed | `app/report.json:99-101` detail "wall missing, rally set, objectives 2"; predicate `selftest.gd:274` |
| C4 | `wall` and `farm_cap` use `_spot`, which tries only 5 fixed radii and returns `Vector2.INF` on exhaustion. | Observed | `selftest.gd:23-33`, `:260-261`, `:437-439` |
| C5 | `hou` farm = 25, so `cap1 == cap0 + 25` matches the current data. | Observed | `data.gd:969`; `game.gd:1787`; `selftest.gd:451` |
| C6 | The exact reason `place_building` returned `{}` in the failing run (no spot vs `can_place` rejection) is not recorded anywhere. | UNVERIFIED | detail string at `selftest.gd:267` discards `_spot`/`can_place` reason |
| C7 | A flat farm triple means the test house never finished (so delete did not subtract). | Derived | `game.gd:1787` (only finished adds), `:3508-3509` (only finished subtracts), `selftest.gd:443-450` |
| C8 | Serdiuk fallback is triggered at 3 m because its min range is ≈15 m and `no_melee=true`. | Derived | `data.gd:22,517-522`; `game.gd:3941-3946` |
| C9 | The flee failure observed in the board's control run was caused by the `d1 > d0` term, not by a missing fallback order. | Inferred | 12+ green runs show `fled` true with only 0.9 m margin; no red detail on disk |
| C10 | The pikeman in `peasant_capture` starts inside its own min range (1.0 m < 1.31 m). | Derived | `selftest.gd:345`; `data.gd:22,501-503` |
| C11 | AI brains do not tick during the selftest's own `game.tick()` loop; they tick only in `main._process`. | Observed | `main.gd:994-1004` vs `main.gd:1360-1366`; `selftest.gd:18-21` |
| C12 | Map layout/defaults differ between failing and green runs. | Inferred | deposit distance 73 m (`app/report.json:39`) vs 19–36 m elsewhere; `cap0` 475 vs 500; T5-GEN map changes `SWARM_BOARD.md:493-494` |
| C13 | None of the five requires a `game.gd` change; all are harness-side. | Derived | C1+C3+C5+C8 + green runs on the same game code |
| C14 | The exact state of the board's 24/29 control run (which step actually failed for `flee`, and why) is not captured in a stored JSON. | UNVERIFIED | only `SWARM_BOARD.md:477-480` prose; stored reports disagree on the red set |

---

## 4. Player-visible impact

**None of the five, as diagnosed, changes behaviour a player sees.** Walls build,
cannonballs land with splash and delay, 17c shooters fall back from pikes,
enemy peasants are captured by melee hits, and houses raise/lower the unit cap
correctly — each is implemented at the cited `game.gd` lines and observed green
in stored runs. All proposed fixes live in `app/scripts/selftest.gd` and only
change how the harness sets up world state and measures outcomes.

One nuance: the proposed `shell` fix **adds** a real cannonball-damage assertion
where none existed. That is extra test coverage, not a gameplay change; if it
surfaces a genuine damage regression, that regression would be a *new* finding
handled by the `game.gd` owner, not part of this diagnosis.

---

## 5. Recommendation

**Fix now, in the harness; do not document as permanent known issues, and do not
touch `game.gd`.** Rationale:

1. The board still treats green 29/29 as a release gate
   (`SWARM_BOARD.md:562-567`, `QA_REPORT.md:182,217,271,325`), and the current
   on-disk gate file is already green — so the gate is unreliable rather than
   genuinely blocked. Leaving five flaky steps in place means a future run can
   go red again for purely environmental reasons and waste another wave.
2. The fixes are low-risk, test-only, and strengthen rather than weaken the
   assertions (explicit placement reasons; real shell-damage check;
   mutation-test acceptance for each).
3. Sequence: (a) shared deterministic build-spot helper + `shell` decoupling,
   (b) `peasant_capture` spawn/window, (c) `flee` deterministic distance. Re-run
   the 10× fresh gate sweep after each; require all 29 green with no assertion
   weakened before closing the ticket.

If the coordinator prefers not to spend a wave on harness work, the defensible
fallback is to record these five as **known flaky harness steps** with this doc
as the evidence, and treat a single 24/29 as non-blocking **only** when the red
set is exactly these five and `app/selftest.json` (or a fresh runner report)
shows them green on a settled tree. That is weaker than fixing them and should
be a time-boxed exception, not the default.

**Out of scope here:** the `build`-step red in `app/report.json`, the
`resow`/mill attribution work already landed under T5-TESTFIX, and the
`attack_ground` step's shot-count-only assertion are separate harness concerns
and were not part of this ticket.
