---
owner: T1
directive: test-split
date: 2026-11-24
lane: T (test-split recon, read-only)
sources:
  - app/selftest.json (29 steps; passed:false — 2 failures)
  - app/scripts/selftest.gd (C3SelfTest.run(), lines 35-511)
  - app/scripts/main.gd:811-814 (--self-test path is the RESULT output path)
  - docs/coord_swarm_2026-11-24/CHARTER.md:60-68 (lane T scope)
---

# T1 — Selftest step taxonomy & coherent subset proposal

**Scope:** read-only recon. No code/config edits, no Godot runs. Evidence below is
`file:line` in `app/scripts/selftest.gd` (abbrev. `gd:NN`) and/or the verbatim
`detail` string in `app/selftest.json` (abbrev. `json:NN`).

---

## 1. Taxonomy of all 29 steps

Dependency legend: `IND` = ORDER-INDEPENDENT (works in a fresh game with only its
own spawns/placements); `DEP` = DEPENDS-ON other steps (see §2).

| # | step id | Subsystem | One-line (measured behaviour / detail) | Evidence | Dep |
|---|---------|-----------|------------------------------------------|----------|-----|
| 1 | `move` | movement / pathfinding | Walked 5.3 m forward at 1.5 m/s; `cmd_move` + 8 s sim. | gd:38-47; json:13 | IND |
| 2 | `act` | gathering / economy | Gathered 84 wood from a tree (order `gather`, node hits 18); 80 s sim. | gd:49-62; json:18 | IND |
| 3 | `fight` | combat (melee) | Pikeman dealt 75 dmg (8 per 1.25 s), enemy peasant dead; 30 s sim. | gd:64-71; json:23 | IND |
| 4 | `build` | buildings | House built in 3.1 s build time, cost 120 wood; 25 s sim. | gd:73-82; json:28 | IND |
| 5 | `train` | buildings / training (economy) | Peasant trained, 100 food, 12.5 s; 16 s sim. Needs a player-0 `cen`. | gd:84-99; json:33 | IND |
| 6 | `mine` | gathering / economy (gold) | Mine produced 49.9 gold in 30 s (worker inside, deposit 19 m); 60+30 s sim. | gd:101-144; json:38 | IND |
| 7 | `hud` | UI / audio (HUD drawing) | Resource bar, minimap, selection panel, status text drawn. | gd:146-151; json:43 | IND |
| 8 | `no_overlap` | movement / collision separation | Min gap 0.20 m vs bodies (tolerance -0.25). Reads all live units. | gd:153-170; json:48 | IND* |
| 9 | `volley` | combat (ranged / video pass) | Serdiuk fired 2 shots, smoke missing, target hp 74. | gd:172-188; json:53 | IND |
| 10 | `heal` | combat support (priest) | Priest healed pikeman 30 -> 70 hp. | gd:190-198; json:58 | IND |
| 11 | `morale` | morale (officer aura) | Morale 70 near officer, routing false. | gd:200-208; json:63 | IND |
| 12 | `upgrade` | economy / tech (blacksmith) | `bla_sword1` researched: yes. | gd:210-219,224; json:68 | IND |
| 13 | `market` | economy / trade | Traded 100 wood for 65 gold at 63 % rate. | gd:220-227; json:73 | IND |
| 14 | `capture` | capture (building capture) | 3 peasants captured the enemy hall; 30 s sim. | gd:229-240; json:78 | IND |
| 15 | `squad` | formations / squads | Squad formed with 2 soldiers, line targets 2. | gd:242-250; json:83 | IND |
| 16 | `formation` | formations / squads | Column set, then disbanded (squads left 0). | gd:251-255; json:88 | **DEP: squad** |
| 17 | `wall` | buildings (defence) | Stone wall built; 30 s sim. | gd:257-267; json:93 | IND |
| 18 | `shell` | buildings / mission-shell UI | Wall ok, rally set, objectives 2. Reads `wall_ok` local. | gd:268-275; json:98 | **DEP: wall** |
| 19 | `formation_bonus` | formations / squads (combat bonus) | Formed bonus +2 (hold +7), lone +0; uses 17-unit `fsq`. | gd:277-296; json:103 | IND (creates `fsq`) |
| 20 | `replenish` | formations / squads (reinforcement) | 2 losses refilled from nearby troops; uses `fsq`/`f_off`/`f_men`. | gd:297-305; json:108 | **DEP: formation_bonus** |
| 21 | `flee` | combat AI (17c min-range fallback) | Serdiuk fell back from pikes (3.0 -> 3.9 m); 1.5 s sim. Co-located with 19/20 but self-spawns. | gd:306-319; json:113 | IND |
| 22 | `garrison` | buildings (tower garrison) | Garrison 3 hid, unload restored; 2 s sim. | gd:321-333; json:118 | IND |
| 23 | `peasant_capture` | capture (unit conversion) | "peasant captured: player 1" — **passed:false today**. Toggles `Data.AI_ENABLED`. | gd:335-358; json:123 | IND |
| 24 | `resow` | gathering / economy (mill cycle) | "wild food nodes=0; depleted mill field re-sown: no; mill auto=24 restored=1 gold=3321" — **passed:false today**; 30 s sim. | gd:360-405; json:128 | IND |
| 25 | `attack_ground` | combat (artillery) | Cannon shells ground: shots 55 -> 56; 5 s sim. | gd:407-414; json:133 | IND |
| 26 | `save_load` | generator / state (serialization) | Serialize 67 ents round-trip: ok. | gd:416-423; json:138 | IND* |
| 27 | `grid_equiv` | generator / scan (grid query) | Grid vs brute force agreed on 10 points. Assertion is inert (see §5). | gd:425-444; json:143 | IND |
| 28 | `farm_cap` | buildings / economy (farm cap) | Farm 500 -> 525 -> 500; builds+deletes a house, waits up to 60 s. | gd:446-464; json:148 | IND |
| 29 | `nav_detour` | movement / pathfinding | Walked around a 24 m wall (dist 1.2 m); map scan + 30 s sim, mutates/restores blocked tiles. | gd:466-503; json:153 | IND |

`*` IND with reduced coverage when isolated (see §2 note on population-sensitive checks).

---

## 2. State dependencies (exact)

Three steps are genuinely order-bound inside `C3SelfTest.run()`; the rest spawn their
own actors via `game.spawn(...)` and anchor on the first player-0 peasant captured at
`gd:38-42`, which every fresh game supplies, so they run standalone.

1. **`formation` DEPENDS-ON `squad`.** It lives inside `if squad_ok:` (`gd:251-255`)
   and is **conditionally appended**. If `squad` is skipped or fails, `formation` is
   *absent from the result entirely* (not just `passed:false`) — a subset gate that
   counts steps would silently see a different step count. Any split must co-locate
   `squad` + `formation`.
2. **`shell` DEPENDS-ON `wall`.** `shell`'s pass condition includes `wall_ok`
   (`gd:274`), the local computed by the `wall` block (`gd:262-265`). Without `wall`,
   that variable is undefined (crash) and the rally/objective assertions are mixed
   with the wall assertion. Co-locate `wall` + `shell`, or keep the boolean but keep
   both in one subset.
3. **`replenish` DEPENDS-ON `formation_bonus`.** `replenish` uses `fsq`, `f_off`,
   `f_men` created in the preceding block (`gd:283`, consumed at `gd:297-305`).
   It kills two `f_men` and calls `cmd_replenish(f_off)`. Co-locate them.

**Implicit / soft couplings (not hard deps, but note for split design):**
- The `peasant` anchor (`gd:38-42`) is used positionally by almost every step. It is
  re-read as `peasant.pos` at each step's execution time, so earlier movement of that
  peasant (e.g. `act` gathering, `build` building) does **not** break later steps —
  they follow it. No step consumes another step's numeric *result*.
- `no_overlap` (`gd:153-170`) and `grid_equiv` (`gd:425-444`) scan the live entity
  set. In isolation they still pass but exercise a sparser world; `save_load`
  (`gd:416-423`) likewise round-trips fewer entities. Coverage, not correctness.
- `peasant_capture` flips `Data.AI_ENABLED = false` then restores it (`gd:349,357`).
  Keep it responsible for its own cleanup; it does not depend on other steps.
- `farm_cap` and `build` both call `_spot("hou", peasant.pos)` (`gd:75,450`), so they
  compete for a placeable spot if forced into the same fresh game — harmless when
  run in separate subsets (each has its own placement ring).

---

## 3. Proposed coherent subsets (partition of all 29)

Filenames follow the existing `app/selftest*.json` result convention
(`app/selftest.json`, `app/app_selftest.json`, `app/selftest_patterns.json`, archived
runs `app/shots/selftest_*.json`). The `--self-test <path>` argument is the **output**
path (`main.gd:811-814`), so each name below is a proposed result artifact. Selecting
*which* steps a run executes is the filter mechanism in **T2's lane** and is out of
my scope.

| Subset (proposed result file) | Exact steps (n) | Why coherent | Slow / risky steps |
|---|---|---|---|
| **core_movement** — `app/selftest_core_movement.json` | `move`, `no_overlap`, `nav_detour` (3) | Unit locomotion: straight-line movement, body separation, pathfinding around a wall. All three are locomotion/collision concerns in one game world. | `nav_detour` (map scan + 30 s sim, mutates blocked tiles); `no_overlap` needs a populated world for full coverage. |
| **economy_gather** — `app/selftest_economy_gather.json` | `act`, `mine`, `resow`, `farm_cap` (4) | The resource pipeline: wood gathering, gold mine income, mill/food re-sow, farm-cap growth. All measure resource production or capacity. | **`act` (~80 s sim — biggest single cost)**, `mine` (~90 s sim, deposit-walk flakiness), `farm_cap` (up to 60 s wait; historically flaky: `500->500->500` in `app/selftest_patterns.json:149`), **`resow` currently FAILS — truth issue, must fix not hide**. Slowest subset. |
| **economy_trade_tech** — `app/selftest_economy_trade_tech.json` | `market`, `upgrade`, `train` (3) | Non-gathering economy: barter, blacksmith research, unit training from town hall. Fast, state-light. | `train` 16 s sim; otherwise near-instant. |
| **buildings** — `app/selftest_buildings.json` | `build`, `wall`, `shell`, `garrison` (4) | Construction + building-dependent mechanics (house, wall, mission shell/rally/objectives, tower garrison). Preserves required `wall`→`shell` pairing. | `build` (~25 s), `wall` (~30 s); `shell` shares wall boolean; `garrison` fast (2 s). |
| **combat_ranged** — `app/selftest_combat_ranged.json` | `fight`, `volley`, `heal`, `flee`, `attack_ground` (5) | Damage-dealing & support across weapon classes: melee, musket volley+smoke, priest heal, 17c min-range fallback, cannon attack-ground. | `fight` (30 s sim), `volley`/`heal` (6/10 s); `volley` smoke is cosmetic-only in the assertion; `attack_ground` fast (5 s). |
| **formations_morale** — `app/selftest_formations_morale.json` | `squad`, `formation`, `formation_bonus`, `replenish`, `morale` (5) | Squad lifecycle + combat formation mechanics: form/line targets, column/disband, LINE15 bonus, loss replenishment, officer morale aura. Preserves `squad`→`formation` and `formation_bonus`→`replenish` pairings. | Almost all near-instant; `morale` 10 s sim. Fastest large subset. `formation` must not be silently omitted if `squad` fails. |
| **capture** — `app/selftest_capture.json` | `capture`, `peasant_capture` (2) | The two capture mechanics: building capture by peasants, and unit conversion on first hit. Both are ownership-change tests. | `capture` 30 s sim; **`peasant_capture` currently FAILS — truth issue, must fix not hide**; it toggles `Data.AI_ENABLED`, verify cleanup. |
| **generator_state_ui** — `app/selftest_generator_state_ui.json` | `save_load`, `grid_equiv`, `hud` (3) | Cross-cutting engine/UI checks: serialize round-trip, grid-vs-brute-force query scan, HUD drawing. Fast, no gameplay simulation. | Near-instant. `grid_equiv` assertion is inert (§5); `hud` needs HUD bound. |

**Naval / audio note:** the current 29 contain **no naval step and no dedicated audio
step**. There is nothing to put in a `generator_naval` or `ui_audio` subset; `hud`
covers UI drawing only. If the coordinator wants those families covered, they are new
steps, not a re-partition (out of T1 scope).

---

## 4. Partition verification — union must equal 29/29

Mapping every step id to exactly one subset; count check
`3+4+3+4+5+5+2+3 = 29`. No step lost, no step duplicated.

| Subset | Step ids |
|---|---|
| core_movement | move, no_overlap, nav_detour |
| economy_gather | act, mine, resow, farm_cap |
| economy_trade_tech | market, upgrade, train |
| buildings | build, wall, shell, garrison |
| combat_ranged | fight, volley, heal, flee, attack_ground |
| formations_morale | squad, formation, formation_bonus, replenish, morale |
| capture | capture, peasant_capture |
| generator_state_ui | save_load, grid_equiv, hud |

Checklist of all 29 (alphabetical, each appears once): act, attack_ground,
build, capture, farm_cap, fight, flee, formation, formation_bonus, garrison, grid_equiv,
heal, hud, mine, morale, move, nav_detour, no_overlap, peasant_capture, replenish, resow,
save_load, shell, squad, train, upgrade, volley, wall, **+ market** = 29. ✓

---

## 5. Non-negotiables (explicit)

- **No assertion may be weakened.** Every step keeps its current `passed` predicate
  verbatim from `gd:38-503`; splitting changes *which* steps run in one process, never
  what a step asserts. In particular keep the donor-derived exact bonuses
  (`fbonus==2 / fhold==7 / lone_bonus==0`, `gd:293-296`) and the farm-cap equality
  (`cap1==cap0+25 and cap2==cap0`, `gd:464`).
- **No step dropped.** Subset union = the full 29-step set (§4); the aggregate gate is
  still `all(steps.passed)` (`gd:505-511`), now AND-ed across all subset results.
  `formation`'s conditional append (`gd:251`) is the one structural leak: the gate must
  assert its *presence*, not just its `passed`, or it can vanish when `squad` fails.
- **Truth, not hiding, for the two current failures** (`app/selftest.json:2` `passed:false`):
  - `peasant_capture` — `"peasant captured: player 1"` (json:123-126). The test currently
    has extra `TMCORE ...` diagnostic prints (`gd:350-356`) from an in-flight diagnosis;
    those should be cleaned up by whoever fixes the underlying capture bug, not by
    suppressing the step. Must end with `passed:true` from a real conversion.
  - `resow` — `"wild food nodes=0; depleted mill field re-sown: no; mill auto=24 restored=1 gold=3321"` (json:128-131). The re-sow returned `no`; fix the mill/resow logic so the field actually restores. Do not relax `resow_ok`/`mill_ok` (`gd:389,402,404`).
- **Observation for coordinator (not a T1 change):** `grid_equiv` sets `geq_ok := true`
  and never assigns it false; the mismatch branch is `pass` (`gd:426-444`). It always
  reports passed. Preserve as-is per "no weakening", but flag as a candidate future
  *strengthening* ticket (a separate assertion rewrite), never as part of the split.
- **`app_selftest.json` / `selftest_patterns.json` are stale baselines** (27 steps, no
  `nav_detour`, different pass/fail sets). The authoritative current gate is
  `app/selftest.json` (29 steps, 2 failures) per `CHARTER.md:87-90`. Do not derive
  subset contents from the stale files.

---

## 6. Open questions for the coordinator

1. **Fresh game per subset, or one shared game?** All steps are structurally
   self-spawning, so a fresh game each is viable and gives isolation; but
   `no_overlap`/`save_load`/`grid_equiv` then lose the populated world the monolith
   gives them. Confirm which trade-off the split should take.
2. **How are subsets selected at runtime?** T2 owns the filter mechanism. My proposal
   assumes `--self-test <path>` stays the result path and a new flag/env selects a
   step-id allowlist. If the intended design is one file per subset *as input spec*
   (like `app/tests/t_*.gd`), the filenames in §3 should be re-labelled and T1 can
   adjust.
3. **Gate aggregation:** should `app/selftest.json` remain as the canonical 29/29
   artifact (e.g. generated by merging subset results), or is each subset file its
   own gate with the monolith retired? This affects whether the 2 failing steps
   block every subset run or only `economy_gather` + `capture`.
4. **`formation` presence check:** confirm the gate should fail if `formation` is
   missing (squad failed) rather than just count passed steps — needed to keep the
   "29/29" promise honest.
5. **Run budget:** should the slow `economy_gather` subset be split further
   (`act+mine` vs `resow+farm_cap`) to meet a per-run timeout? I capped at 8 subsets
   per the directive; splitting it would make 9. T3's per-step cost data should decide.
6. **Ordering inside a subset:** I kept source order (e.g. `squad` before `formation`,
   `wall` before `shell`). If subset execution may shuffle steps, confirm steps are
   pinned to source order to preserve the three hard deps in §2.
