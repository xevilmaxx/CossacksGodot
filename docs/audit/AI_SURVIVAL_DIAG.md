---
title: AI_SURVIVAL_DIAG — why a skirmish AI can die on its own
area: ai-squads-teams
owner: T5-AI-DIAG
updated: 2026-11-21
status: diagnosis
charter: read-only, exactly one artefact
---

# AI_SURVIVAL_DIAG — why the AI can die on its own

> [!IMPORTANT]
> Read-only diagnosis for the owner report: *"check enemy ai, i started a random
> match built some things and got victory probably because ai died, ensure ai
> doesnt auto die like of starvation or things like that, some resources are
> prioritarian even for ai."*
> No code was edited, no Godot was run. The sole artefact is this file. Every
> factual claim below is cited to `file:line` or a named evidence file. Claims
> are split into **Observed** (read from source/data), **Derived** (arithmetic on
> observed values) and **Inferred** (best explanation, not proven by a fresh
> run).

---

## 1. Sources

| Source | What it gave |
|---|---|
| `app/scripts/ai.gd:1-503` | Full AI brain: tick order, economy quota, build order, training, famine override, waves. |
| `app/scripts/game.gd:222-233` | Player dict: `farm_cap`, `famine`, `famine_t`, `starving`. |
| `app/scripts/game.gd:1784`, `:1803`, `:1813-1845`, `:1860-1880` | `farm_cap` accrual; mill finishes sow fields; AI-only field regrowth. |
| `app/scripts/game.gd:2084-2096` | Start: one `cen` + `START_PEASANTS` (8) peasants, zero military. |
| `app/scripts/game.gd:2169-2183`, `:2384-2390`, `:3858-3877` | Drop-off points, `cmd_resow`, resow costs 20 food. |
| `app/scripts/game.gd:3118-3150`, `:3210-3219` | `place_building` cost/`can_place` gate; `train_unit` pop/food gates. |
| `app/scripts/game.gd:3291-3295` | Per-tick order: cleanup → upkeep → victory. |
| `app/scripts/game.gd:3375-3428` | Upkeep `/UPKEEP_DIVISOR`, famine flag, grace, HP drain, gold-famine morale. |
| `app/scripts/game.gd:3437-3459`, `:4288-4362`, `:4364-4397` | Death handling, gather loop, delivery amount. |
| `app/scripts/game.gd:4553-4600` | Victory / elimination rule. |
| `app/scripts/data.gd:46`, `:52`, `:66`, `:68-75`, `:96-97`, `:464-472` | Tunables: 8 peasants, destroy_all, divisor 625, AI constants, famine grace/drain, gather carries. |
| `app/scripts/data.gd:489-498`, `:964-1018` | Unit `eat` values; building costs/`farm`/`stores`. |
| `app/config.json:40-47`, `:104-105`, `:108-116` | Live start resources (food 800), famine values, `ai.attack_force = 120`. |
| `app/scripts/config.gd:389-393`, `:421`, `:430-431`, `:446-456` | Config → `Data` overrides; difficulty multiplier on attack force. |
| `app/mechanics.json:502-506`, `:715-728` | Documented upkeep rate and famine grace/drain. |
| `app/cli.json`, `app/shots/cli180.json`, `app/shots/cli*.json` | 60 s / 180 s headless match snapshots. |
| `app/selftest.json:1-44`, `app/selftest.gd` | 400.7 s selftest; no famine/upkeep step exists. |
| `app/tests/t_hud_fidelity.gd:163-168` | Only famine-related test: manually sets the HUD flag. |
| `app/.godot_queue/results/*/stdout.txt` (grep) | No `Famine!`, no `wins!` in any stored stdout. |

---

## 2. Claim table — observed / derived / inferred

| # | Claim | Class | Evidence |
|---|---|---|---|
| C1 | AI ticks every 1.0 s; if it has no *finished* building it does nothing at all. | Observed | `ai.gd:24`, `ai.gd:44-45`. |
| C2 | Worker quota is food 35 % / wood 25 % / stone 15 %, with mines taking the remainder via leftovers; `int()` truncation applies. | Observed | `ai.gd:67-68`, `:90-127`. |
| C3 | Miners are counted but never pulled out by the famine override (`inside_of != 0` skipped). | Observed | `ai.gd:73-75`, `:129-134`. |
| C4 | `AI_FOOD_THRESHOLD`, `AI_WOOD_THRESHOLD`, `AI_STONE_THRESHOLD` are configured but **never read by `ai.gd`** — dead "prioritarian resource" knobs. | Observed | `data.gd:70-72`, `config.gd:446-448`, `config.json:111-113`; grep of `ai.gd` = 0 hits. |
| C5 | AI build order priority: house → 3 mines → 3 barracks → storehouse → blacksmith → **mill** → market → academy → stable → … | Observed | `ai.gd:164`, `:169-190`. There is **no dedicated farm construction at all** in `ai.gd` (grep `farm` = only `p.farm_cap` at `:164,:167`). |
| C6 | Mill build gate checks `wood ≥ 200 && stone ≥ 100`, but the mill actually costs `wood 30, stone 150`. Attempts at 100–149 stone silently fail. | Observed | `ai.gd:179-180` vs `data.gd:991`. Failure path: `game.gd:3148-3150`. |
| C7 | Three barracks (`150` stone each) are queued *before* the mill; starting stone is 400 and three mines already spend 300. | Observed/Derived | `ai.gd:169-180`, `config.json:43`. After 3 mines only 100 stone remains, below the barracks gate (150) and below the mill's true cost (150). |
| C8 | Construction is serialised: `unfin ≥ 3` blocks all new sites (house exception), and `_resume` assigns at most `max(2, peasants/3)` builders total. | Observed | `ai.gd:158-166`, `:225-251` (`:235`). |
| C9 | Peasant training is food-gated (`res.food ≥ 100`); **military training has no food reserve check at all** — it only stops at `force ≥ 2 × AI_ATTACK_FORCE`. | Observed | `ai.gd:304` vs `:324-356` (`:336`). |
| C10 | With `config.json:114` `attack_force = 120`, the military production cap is force ≈ 240 (config.gd:449 writes `Data.AI_ATTACK_FORCE`). | Derived | `config.json:114`, `config.gd:449`, `ai.gd:336`. |
| C11 | Upkeep = `eat[k] / 625` per unit per second; 8 starting peasants eat 0.410 food/s, 40 peasants eat 2.048 food/s; a pikeman adds 0.048, a cossack 0.096 food/s. | Derived | `game.gd:3388-3398`, `data.gd:66`, `data.gd:493` (32), `:501` (30), `:539` (60). |
| C12 | Food cannot go negative: on shortfall it is clamped to 0; after `FAMINE_GRACE_S = 120 s`, every living unit loses `0.3 hp/s`. A 75 hp peasant dies after a further 250 s of famine (~370 s from food = 0). | Derived | `game.gd:3404-3422`, `data.gd:96-97`, `:491`. |
| C13 | Full food load = 45 food per 22 hits at 1.25 s/hit (27.5 s work plus travel), i.e. ≈ 1 food/s per dedicated food peasant before travel. | Derived | `data.gd:465`, `game.gd:4342-4362`, `:4391-4397`. |
| C14 | Field regrowth is AI-only and requires a finished mill or a `mill` flag on the node; without a mill the only renewal is `cmd_resow` at **20 food** per field. | Observed | `game.gd:1871-1880`, `:1813-1845`, `:3873`. |
| C15 | Victory check eliminates a player when `buildings_of(pi).is_empty()` **OR** `units_of(pi).is_empty()` (the `continue` requires both non-empty). Upkeep runs on the same tick immediately before this check. | Observed | `game.gd:4590`, `:3293-3295`. |
| C16 | Therefore: once the AI's last unit dies (including a famine death, or a wave wiped in the field), the human wins with no attack on the town hall required. | Inferred (high confidence) | C12 + C15. Matches owner symptom. |
| C17 | No stored stdout contains `Famine!` or `wins!`; selftest has no famine/upkeep step and only a HUD flag test. | Observed | grep of `app/.godot_queue/results`, `app/selftest.json`, `app/tests/t_hud_fidelity.gd:163-168`. |
| C18 | Current 60 s CLI snapshot: food gathered 135, both sides 12 units, winner -1. Older 180 s snapshot: 1 finished building and 10–11 units per side, winner -1. No observed population collapse or negative food. | Observed | `app/cli.json`, `app/shots/cli180.json` (snapshots dated 11/17, config dated 11/21 — stale). |
| C19 | Live start resources are generous (food 800), so famine in the first minutes requires a real food-sink, not just idle upkeep. | Derived | `config.json:40-47`, C11. |

> [!NOTE]
> "Farm" in the owner/task vocabulary corresponds in this port to **mill + food
> fields** (`mil`, `cmd_resow`, `_tick_field_growth`); `data.gd` has no `farm`
> building. `p.farm_cap` is the *population* cap, not food production.

---

## 3. Root-cause ranking

Ranked by contribution to **"AI dies on its own"**, with separate note on the
**victory trigger** that turns a recoverable wipe into an instant human win.

| Rank | Cause | Verdict | Numbers / lines |
|---|---|---|---|
| **1** | **(e) AI keeps training units past the food budget** | **Primary death driver.** Peasant path is food-gated; military path is not. With attack_force 120 the AI pushes force to ~240, paying 20–130 food *per unit up front* plus 0.032–0.096 food/s each, with no check that income covers it. A wave wipe then leaves a food-starved, unit-poor AI. | `ai.gd:304` vs `:324-356`, `:336`; `config.json:114`; `data.gd:492,501,539` |
| **2** | **(a) AI never builds the mill early enough** | **Primary sustainability driver.** Mill is 6th in build order behind 3 mines + 3 barracks + storehouse + blacksmith; gate understates stone by 50 (100 vs 150); `unfin≥3` + 2-builder budget serialise everything. Without a finished mill there is no free field regrowth; every depleted field costs 20 food to resow. | `ai.gd:158-166,169-180,235`; `data.gd:991`; `game.gd:1871-1880,3873` |
| **3** | **(b) Too many peasants pulled to wood/gold** | **Contributing.** Quota sends only 35 % to food; mines absorb all leftovers, and the famine override cannot recall miners (`inside_of != 0`). `int()` truncation under-allocates food for small n (n=8 → only 2 food gatherers ≈ 2 food/s against a growing army). | `ai.gd:67-68,73-75,99-134`; `data.gd:465` |
| **4** | **(c) Unit upkeep outpaces food income** | **Downstream consequence of 1–3**, not an independent bug. Upkeep is exact (`consume/625`); with ~40 peasants + 200 military it is ~11 food/s while one food gatherer yields ~1 food/s. | `game.gd:3388-3398`; `data.gd:66,465`; C11–C13 |
| **5** | **(f) Victory fires on an empty-but-not-dead AI** | **Symptom mechanism (sim-side, not AI-owned).** Eliminates on `no buildings OR no units`. A famine- or combat-wiped army alone ends the match, which is exactly the owner's "I got victory because AI died". | `game.gd:4590`, `:3293-3295`, `:4553-4566` |
| **6** | **(d) House cap stalls growth** | **Not lethal; protective.** AI does build houses when `unit_count + queue + 3 ≥ farm_cap` and wood ≥ 120; a cap merely stops training, which *reduces* food burn. Only relevant if wood is starved by the build order. | `ai.gd:164,167`; `data.gd:966,969`; `game.gd:3212-3214` |

**Bottom line (Inferred, high confidence):** the AI does not "auto-die" from an
external death timer. It can *starve itself* because (1) it produces military
with no food reserve, (2) it delays its only food-sustainability building (mill)
behind stone-consuming mines/barracks using a wrong cost gate, and (3) it keeps
only ~35 % of peasants on food while locking miners out of famine response. The
human's instant victory is then granted by the sim's OR-based elimination rule.
No stored log proves a famine actually fired; the current 60 s CLI run is clean
(C17/C18). This is a code-path diagnosis, not a reproduced failure.

---

## 4. Fix plan — `app/scripts/ai.gd` only

Owner boundary: **only `ai.gd` may be edited**; `game.gd` is owned by another
worker. Line numbers are from the current file and will shift after edits.

### F1 — Make mill an early, correct-cost priority (addresses rank 2)
**Target:** `ai.gd:169-180` (build order), `:179-180` (mill gate).
- Move the mill check **above** the mine/barracks loops, or immediately after the house check at `:167`.
- Change the gate to the real cost: `res.wood >= 30 and res.stone >= 150` (use `Data.BUILDINGS["mil"].cost` rather than hard-coded numbers so escalation/cost changes cannot drift again).
- Keep the `unfin >= 3` guard at `:158-166` but exempt the mill from it, so a mill site is never blocked by the initial mine/barracks batch.
- Raise the builder budget at `:235` from `maxi(2, peasants.size()/3)` to `maxi(3, peasants.size()/2)` while any unfinished mill exists, so the food building finishes first.

### F2 — Food reserve gate on *all* training (addresses rank 1)
**Target:** `ai.gd:303-308` (peasant gate) and `:324-356` (military gate).
- Introduce one helper `_food_reserve(p, res)` at ≈`:302` returning a reserve from `Data.AI_FOOD_THRESHOLD` (currently dead — C4), e.g. `maxf(Data.AI_FOOD_THRESHOLD, projected_upkeep_30s + train_cost + 100)`.
- At `:304`, raise the peasant gate from `res.food >= 100` to `res.food >= reserve + 100`.
- At `:336`, apply the same gate **before** the `force >= AI_ATTACK_FORCE*2` check: `if res.food < reserve: continue` for every training building. This is the single most important line-level change.
- Recompute `res.food` snapshot each tick (already done at `:26-28`), so the gate reacts within one think tick (1 s).

### F3 — Food-first economy with a real mining ceiling (addresses rank 3)
**Target:** `ai.gd:67-68`, `:99-117`, `:128-134`.
- Replace fixed quota with a floor: `want.food = maxi(int(n*0.35), ceil(n*0.5))` while `res.food < Data.AI_FOOD_THRESHOLD` or `p.famine` is true; cap mine assignments at `int(n*0.15)` so wood/gold never starve food.
- At `:99-117`, do not move a gatherer off food while `on.food <= want.food`.
- At `:129-134`, extend the famine override to recall miners: send a `cmd_gather` to food for miners as well, and use `cmd_resow` on depleted fields (the resow path is already handled at `:78-82`).

### F4 — Predictive throttle instead of reactive famine
**Target:** `ai.gd:50-60` (tick) and new helper near `:136`.
- Compute `net_food = income_estimate - upkeep_estimate` from the snapshot (upkeep per unit = `m.def.eat.food / Data.UPKEEP_DIVISOR`, `data.gd:66`).
- If `res.food / maxf(0.1, -net_food) < 60.0` (under 60 s to empty), suppress military training (F2) and divert all idle peasants to food until `res.food > Data.AI_FOOD_THRESHOLD`.
- Emit a debug line once per state change (guarded by `Data.debug`) so a CLI soak can assert the invariant without a new sim API.

### F5 — House cap sanity (rank 6, cheap)
**Target:** `ai.gd:164`, `:167`.
- Keep, but also build a house when `fin.get("cen", 0) == 0` is false and `farm_cap - (unit_count + queue_count) < 10`; this avoids a late cap stall without changing food behaviour.

### Acceptance criteria (measurable)
In a **5-minute CLI skirmish with default settings** (`--cli app/cli.json --cli-seconds 300`, current `config.json`, both slots AI-driven per `main.gd:483-503`):

1. AI food **never < 0** (sim clamps to 0 — acceptance is: no tick with `famine == true` for the AI player, verified by a per-tick debug trace / sim counter).
2. AI population does **not decrease by > 20 %** from starvation at any 60 s window (sample `unit_count` each tick; no famine-driven `_kill` events).
3. AI builds **at least 1 finished mill before training beyond N = 10 non-peasant units** (assert `fin.get("mil",0) >= 1` at the moment military `unit_count > 10`).
4. The human does **not win without actively attacking** — `winner == -1` after 300 s with no player-issued attack orders (the current `cli.json:18` and `cli180.json:14` already show `winner: -1`; keep that).
5. `AI_FOOD_THRESHOLD` is actually consumed (grep of `ai.gd` returns ≥ 1 hit), and mill gate uses `Data.BUILDINGS.mil.cost` rather than hard-coded `100`.
6. Regression gates unchanged: selftest `passed: true`, 60 s CLI `status: ok`, zero `ERROR`/`SCRIPT ERROR`/`stuck` in stdout.

### Sim-side data to expose — explicit request to the `game.gd` owner (A)
The AI needs read-only visibility; none of these require AI write access:

- `game.food_balance(player) -> {income_s, upkeep_s, net_s, seconds_to_empty, famine_t}` derived from `game.gd:3384-3422`. Required by F2/F4 so training can be throttled *before* food hits 0 rather than after the famine flag.
- `game.food_fields(player) -> {alive_hits, with_mill, depleted}` for food nodes (`game.gd:1878-1880`, `:1813-1845`). Required by F1/F3 to decide mill vs resow.
- `game.building_failure_reason(player, sid, pos)` or a `place_building` return containing the `can_place` reason — currently `_say_human` is guarded for AI at `game.gd:3129-3132`, so the AI cannot tell why a mill placement failed.
- **Fix request:** change `game.gd:4590` from "no buildings **or** no units" to "no buildings **and** no units" (or add an elimination grace timer), so a wiped army does not instantly hand victory to a player who never attacked. This is the sim-side half of acceptance criterion 4 and is the highest-value cross-file change; it is outside this worker's ownership.

---

## 5. Open questions

1. Did the owner's victory actually come from a famine death, or from an army wiped by a wave (`ai.gd:471-503`) combined with the OR-based elimination rule (`game.gd:4590`)? No fresh run was permitted; need a 300 s CLI trace with per-tick `famine_t` and `unit_count` to distinguish.
2. Why do stored CLI snapshots show only 1–2 finished buildings after 60–180 s (`app/cli.json`, `app/shots/cli180.json`) despite 800 wood / 400 stone start? Those snapshots predate the current config (11/17 vs 11/21); re-run with current config before using them as construction evidence.
3. Does `_find_spot` (`ai.gd:253-271`) often fail on the 320-tile maps, leaving sites unplaced? Not measured here.
4. Should the dead `AI_FOOD_THRESHOLD`/`AI_WOOD_THRESHOLD`/`AI_STONE_THRESHOLD` constants be wired up (F2/F3) or deleted? Owner preference affects "some resources are prioritarian even for ai".
5. Is gold famine (`game.gd:3423-3428`, morale drain for officers/cannons) in scope? It does not kill units, so it is excluded from this diagnosis.
6. Who closes the `game.gd:4590` elimination-rule fix (rank 5 / sim-side request)? Needs A's ownership grant.

---

**Related:** `docs/STATUS_AI.md` · `docs/improvements/IMP_AI.md` (IMP-AI-04 economy) ·
`docs/audit/SIM.md` · `app/scripts/ai.gd` · `app/scripts/game.gd` · `app/scripts/data.gd`
