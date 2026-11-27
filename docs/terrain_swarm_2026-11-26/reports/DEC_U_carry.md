---
id: DEC-U-CARRY
worker: DEC-U-CARRY (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
scope: "READ-ONLY decomp. Donor binary never executed/copied. Donor text read as text only. No code/asset/config/Godot/git edit: this report is the only file written."
labels: "[O] verbatim donor file:line read this ticket · [D] deterministic reading of [O] · [I] inference, flagged · [U] UNVERIFIED with settling experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
upstream: "DEC_U_tool_attach.md (carry anim tokens + attach map) + DEC_U_state_map.md (T8-T13 carry rows, T22, Work/Construct ACL events) + DEC_U_market_tail.md (delivery sites D1-D3, restotal/resonlife, game.gd/data.gd §§5-6) + DEC_ATTACK_WORK_ACTIONS.md (port gather/carry sim shape)"
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker."
---

# DEC-U-CARRY — per-unit carry capacity, gather increment/cadence, drop law, RNG draws

## 0. Pass ledger (multiple passes; every native anchor pinned `t_87f0f3c130b0`)

Donor root read-only: `C:\Games\Cossacks 3\data\`. Port read-only: `variant3d/scripts/game.gd`, `variant3d/scripts/data.gd`. No donor binary executed; no bytes copied into the repo.

| # | Pass | Result |
|---|---|---|
| P1 | grep `resamount` whole `data/scripts` | 7 hits `unit.script` (init `:2687`, clamp `:9658-9661`, drop `:9708-9713`, fisher `:11951-11954/:12037/:12116`), Work event `+1` (`onaclanimationreachedwork.inc:50`), tag mirror (`settagstates.inc:123-134`). Closed surface: no other writer/reader [O] |
| P2 | read `unit.script:9542-9570` + `:9651-9666` + `:9667-9897` | portion table, efficiency credit, full-load check/clamp, full drop path incl. `dstSqr<0.5` re-verified against market-tail D2 [O] |
| P3 | read `onaclanimationreachedwork.inc:1-62` full + `settagstates.inc:123-134` | `+1`/hit law, per-res node-hp decrement, gainres/server gate, resource-tag mirror [O] |
| P4 | read `unit.script:11930-12127` full fisher block + `:1865-1866` base values | capacity/clamp/credit/retarget law + base `fishingspeed/fishingmax` [O] |
| P5 | read `dmscript.global:791-811` + `res.script:346-358` + `unit.script:5531-5552` + `:2756-2808` + `:4043-4062/:4114-4120` | hitsneeded table, `else 10` branch, order-change reset rule, ClearOrder non-touch proof, search RNG gates [O] |
| P6 | read `peasant.acl:2140-2166` + `refspeed.acl` peasant rows + `ondeath.inc` full + `miscext2.script:4205-4267` | Work/ACL cadence shape, no cycle count on work rows, death/drop negative [O] |
| P7 | port grep `game.gd` (`resamount\|GATHER\|DELIVERY\|carry\|_gather_deliver\|_tick_gather\|_fisher_deliver\|_kill`) + `data.gd` (`GATHER\|DELIVERY\|UPKEEP`) + read `game.gd:7254-7536,5743-5786` | current port shape, 6 deltas in §5 [O] |
| P8 | cited prior native/text evidence (not re-run): market-tail P1-P4 negatives, D2/D3 delivery literals, `progresstick:=floor(RandomExt*32)` (`unit.script:2707`) | reused with attribution |

**Strange-read log:** `Select-String -Path <dir>` refuses directories (retry: `Get-ChildItem -Recurse | Select-String`); `head` absent on this host (retry: `Select-Object -First`). No donor binary executed; no donor bytes copied.

"Address" in this report = `path:line` (scripts are text; no binary addresses are read or cited).

## 1. Max `resamount` per unit/sid — RECOVERED, no per-sid table exists

**Donor law [O]:**

- Capacity function (`res.script:346-358`):
  - `food → gc_resource_hitsneeded_food = 22` (`dmscript.global:799`)
  - `wood → 14` (`:800`), `stone → 20` (`:801`), **else → 10** (`res.script:355-356`).
- Enforcement (`unit.script:9653-9665`, `_unit_CheckReturnToStorehouse`): `hitsneeded := _res_GetHitsNeeded(restype)`; `if resamount >= hitsneeded` → return-to-storehouse; **clamp `resamount := hitsneeded`** (`:9661`) before routing.
- Fisher twin (`unit.script:11945-11958`): `if resamount >= _unit_GetFishBoatMaxCapacity(goHnd)` → return-to-port; clamp `resamount := capacity` (`:11954`). Capacity reads live `objbase.fishingmax` (`:11936-11942`); base `fishboat` values `fishingspeed := 50 div 4` (= 12), `fishingmax := 1000` (`unit.script:1865-1866`). Upgrades scale both (`:11933-11934` commented pattern + `player.script:1812-1831` `effectfood/wood/stone` arms for `resefficiency`; fishing upgrades same shape).
- Init (`unit.script:2687-2688`): `resamount := 0`, `restype := none`.

**[D] consequences (load-bearing):**

1. There is **no per-sid/per-unit carry table** — capacity is a pure function of `restype` (field) / `fishingmax` (boat). Any port table keyed by sid invents law. Port `GATHER.hits` (`data.gd:1002-1005`: 22/14/20) already matches the donor triple [O-agreement]; the donor `else → 10` branch has no port counterpart (only reachable for gold/iron/coal field gathering, which the port routes to mines — dead in practice, keep as a documented gap, §4 U-CAP).
2. The clamp truncates overfill: a unit that somehow holds 25 food delivers as 22. Port `_tick_gather` accumulates `e.carry += 1` and delivers at `carry >= full_load` without a clamp, then credits `portion*min(carry,hits)/hits` (`game.gd:7476-7479`) — the `min()` is the port's equivalent of the clamp on the credit path [O-agreement in effect], but the stored `carry` itself is never clamped. Cosmetic only; noted in §5 P-CAP.

## 2. Gather increment + cadence per resource — RECOVERED (increment exact; cadence window-exact, rate [U])

**Increment [O]** (`onaclanimationreachedwork.inc:47-51`): on every `OnAclAnimationReachedWork` event, `restype := node.itype; resamount := resamount+1`. Exactly **+1 per hit for all three field resources** — no per-res portion at this stage. Gate (`:9`): skipped entirely for net clients/replays; on the sim host it additionally requires `orders[0].itype = gainres` (`:9`).

**Node-side decrement [O]** (`:20-46`): same event debits the node: food `resdec = Max(1, floor(100/(1+fieldlife/100)))` (`:24`, `fieldlife` default 0 per `player.script:110`, so base game = 1/hit); wood `hp-1` + death-tag at 0 (`:33-35`); stone `hp-1` (`:42`, no death-tag arm).

**Delivery credit [O]** (`unit.script:9555-9570`): only on a full load at the storehouse: `amount := portion*eff div 100` (`:9560`), `portion` = food 45 / wood 28 / stone 40 / else 20 (`unit.script:9546-9552`; `dmscript.global:804-806` confirms 45/28/40); `eff = resefficiency[cid][restype]` (`:9559`), default 100 (`player.script:109`), i.e. base-game credit = portion exactly. Credit path `_res_AddResToPlayerByIndex` + `stat.restotal[restype] += amount` (`:9567-9569`); fisher twin credits `fishingmax` + `restotal` (`:11993-11998`). Neither touches `resonlife` (market-tail §4).

**Cadence [O-shape, U-rate]:** work rows are bare `AnimationName + ExecuteState` items with **no `NumberCycle`** (`peasant.acl:2140-2166` vs. attack rows' explicit `NumberCycle=1`), i.e. one Work event per animation-cycle completion, re-armed by the `SwitchTo('Nothing')` tail (`work.inc:59`) → next tag evaluation re-selects `extract` while the order holds. Cycle length = the AAF window at 30 fps (headers `fps=30` per tool-attach §2.3; body same timeline):
- `peaukr.aaf` (tool-attach §2.2, re-cited): `workfood 278..299` (22 f ≈ 0.733 s), `workwood 237..254` (18 f = 0.6 s), `workstone 217..234` (18 f = 0.6 s).
- `pearus.aaf`: `workfood 281..304` (**24 f = 0.8 s** — nation-shifted), `workwood/workstone` identical spans to ukr.

**[D]:** cadence is per-(action, nation): food gathering is ~22% slower than wood/stone for ukr, and rus food is ~9% slower than ukr food. The port's single `interval: 1.25` for all three (`data.gd:1003-1005`, self-labelled approximation at `data.gd:354-356`) matches none of these windows. No `SetGameObjectIntervalFactorByHandle` call exists on the work path (interval-factor calls found only on walk/death/attack paths), so factor = default 1 is the working reading, but the engine default is **not** in the read files → stays [U] (capture U-CAD).

**Fisher cadence [O]** (`unit.script:12110-12118`): continuous, not per-hit: `addFish := fishingspeed*deltaTime + orders[0].info.progress` (`:12114`); `addFishInt := Floor(addFish)`; `resamount += addFishInt`; fractional remainder carried in `orders[0].info.progress`. Base rate 12/s (`50 div 4`, `:1865`), upgrade-scaled. No animation event involved.

## 3. Resource drop/transfer law — RECOVERED (full-load-only; death drops; partial load never auto-delivers)

**Field drop golden path [O]** (`unit.script:9707-9713`): on arrival (`dstSqr < 0.5` vs `storehouse.pos + resourcePoint`, `:9702-9705`, market-tail D2) with `resamount >= hitsneeded`: credit full `portion*eff/100`, then `restype := none; resamount := 0` (`:9712-9713`); re-target same/detected node (`:9715-9747`) or clear order (`:9741-9747`).

**Partial load on node depletion [O — never delivered]:** with `resamount < hitsneeded` the unit takes the extract branch (`:9771+`). Each tick re-searches (`:9828`); if nothing found and `standtime > 59` → `targetnotvalid` → `SetSTO(0) + ClearOrders + idle/none tags` (`:9889-9893`). `_unit_ClearOrder` touches **only order slots** (`unit.script:2756-2808`, re-read P5: resets `itype/bexecute/trg/x/y/dx/dy/dir/z/upgradeid/produceid/restype/amount/progress` — never `resamount/restype` on the unit). So the partial load **stays on the unit, uncredited**, with no order. It is only resolved by: (a) a later same-restype `gainres` order (kept load counts toward the next full — `OrderGainResource` resets `resamount := 0` **only when the new restype differs**, `:5541-5545`, i.e. a different restype **discards** the partial load silently, no credit); (b) topping up to full on another node → normal delivery.

**Death [O-negative]:** `ondeath.inc` (full read) only stops walk sounds, removes scenario-list membership, `SwitchTo('Nothing')`, `_unit_DestroyObj`. `_unit_DestroyObj` (`miscext2.script:4205-4267`, full read) touches minimap/behaviour/`insideof`/counters/`bdead`/STO/transport-inside/grid/path/orders/selection — **no `resamount` read or transfer anywhere**. The carried load vanishes with the unit. Port `_kill` (`game.gd:5743-5786`) likewise credits nothing — [O-agreement].

**Fisher drop [O]** (`unit.script:12033-12057`): `dstSqr < 16` vs `GetPortResourcePoint` (`:12027-12033`, market-tail D3) with `resamount >= fishingmax`: credit `fishingmax` + `restotal[food]`, `resamount := 0` (`:12035-12037`), new water target `(0.5+random)*15.0` (`:12039`). Same death rule (load vanishes; fisher `usage` has no death-transfer arm).

**Gather-point (mine) transfer:** field `resamount` law does not apply to gold/iron/coal — peasants enter the mine (`miscext2.script:4629-4632` `_unit_OrderGoInside`) and income accrues to the player while inside (port `game.gd:7602-7626` mine-income block; donor mine tick owned by the economy lane, not re-derived here). No carry events cross that boundary in either implementation.

## 4. RNG draws in the carry law — enumerated, none invented

| # | Draw [O] | Site | Effect on carry law |
|---|---|---|---|
| R1 | `progresstick := floor(RandomExt*32)` | `unit.script:2707` (init) | tick-phase jitter only; does not change amounts |
| R2 | `rmax := food_radiusmaxSqr*random` when walking | `unit.script:9788-9792` | whether an arriving-while-walking peasant counts as in-range this tick (hit start gating, food only) |
| R3 | `if standtime>=9 or random>0.9` → widen re-search radius `r := searchradius*(0.3+standtime/5)`, clamp `2x` | `unit.script:9821-9827` | retarget radius while working a depleting node |
| R4 | search throttle: `if standtime>0.1: if random<waitrnd … else exit` (`waitrnd = gc_obj_res_searchwaitrnd = 0.65`); `bskipcheck := random>0.75`; `rndind := floor(random*count)` start index | `unit.script:4052-4062`, `:4114-4120` | whether/which node a retarget finds (order of candidate scan, randomised start) |
| R5 | `angle := random*360`, up to 20 tries, water+scancell check | `unit.script:11970-11989` (`_unit_GetRandomWaterPosition`) | fisher working/chase positions |
| R6 | `(0.5+random)*15.0` with `gc_fisher_radius_move_change = 15.0` (`:12005`) | `unit.script:12039`, `:12090` | post-delivery and idle re-target radius |
| R7 | `SetGameObjectIntervalFactorByHandle(…, 0.7+random*0.6)` | death path (`ontagstates.inc:599`, via state-map T21) | visual desync only; no amount effect |

**[D]:** no RNG draw touches an amount, portion, capacity, or credit — all quantities are deterministic given the event sequence; randomness only routes *which node / when a tick engages*. Fixed-seed traces must therefore fix the seed AND log the R2–R6 draws to stay bit-exact.

## 5. Concrete port change list (`variant3d/scripts/game.gd`, `data.gd`; no edit made here)

Line numbers as-read 2026-11-26; re-anchor by function/verbatim text (files are concurrently edited). Paths are `variant3d/scripts/…`.

### P-CARRY-1 — `data.gd:1001-1005` `GATHER_BASE`: values stand, comment must cite the clamp + nation cadence (no value change)

Values (`hits` 22/14/20, `carry` 45/28/40) already equal donor `hitsneeded` + `portion` [O-agreement]. Replace the approximation note with: `hits` = `_res_GetHitsNeeded` (`res.script:348-358`, consts `dmscript.global:799-801`, clamp `unit.script:9661`); `carry` = `_unit_GetPeasantResPortion` (`unit.script:9544-9553`, consts `:804-806`); `interval: 1.25` stays PORT APPROXIMATION — donor cadence is per-(action,nation) AAF window at 30 fps (`peaukr.aaf` 22/18/18 f; `pearus.aaf` food 24 f), no `NumberCycle` on work rows (`peasant.acl:2140-2166`), interval factor default unproven (U-CAD).

### P-CARRY-2 — `game.gd:7476-7479` delivery credit: gate on full load (donor's only credit path)

Current `amount = round(portion * min(carry,hits)/hits * mult)` scales partial loads. Donor credits **only** `resamount >= hitsneeded` (clamped to `hitsneeded`, `:9661`) with `amount = portion*eff div 100` (`:9560`). Required shape: deliver (and credit) only when `e.carry >= hits`; credit `int(portion * eff_mult)` with no `carry/hits` ratio. Partial-load delivery on node-empty (`game.gd:7303`, `:7382-7383`) must be removed from the credit path (see P-CARRY-3); the `min()` then becomes dead code — delete it, do not keep it as a "partial bonus".

### P-CARRY-3 — `game.gd:7303-7305`, `:7382-7383`, `:7449-7457`: partial load must be kept, not delivered or deleted

Donor partial-load law (§3): depleted node → wait/retarget (`unit.script:9828-9846`), order cleared at `standtime>59` with the load retained (`:9889-9893` + ClearOrder proof §3), different-restype reorder discards (`:5541-5545`). Required: on node-empty with `0 < carry < hits`, retarget same-res (nearest) and keep `carry/carry_type`; only clear the order (keeping the load) when no same-res node exists; on `cmd_gather` with a different `res`, zero the load explicitly (matches `:5541-5545`) instead of the current unconditional zero (`game.gd:4185-4186` — unconditional is correct only for differing res; same-res reorder must keep the load).

### P-CARRY-4 — `game.gd:4185-4186` `cmd_gather`: conditional reset (see above)

Replace unconditional `e.carry = 0; e.carry_type = ""` with reset-if-different: `if e.carry_type != "" and e.carry_type != res_node.type: e.carry = 0` (donor `unit.script:5541-5545`).

### P-CARRY-5 — fisher accumulation (currently unported): wire `resamount` += floor(rate*dt + progress)

Port `_fisher_deliver` (`game.gd:7513-7536`) credits `e.resamount` but no producer fills it (delivery radii + retarget already match donor `:12027-12050`; the water-ring fallback stays [U]-E1 per market-tail). Required: while fishing (order `fishing`, moving toward/stationary at `fish_target`), `add = floor(fishingspeed*dt + e.progress); e.resamount += add; e.progress = frac` with base `fishingspeed = 12.0` (`50 div 4`, `unit.script:1865`) × player fishing upgrades; capacity `fishingmax = 1000.0` base (`:1866`) gated at `_fisher_port` return (`:11951-11954`). Until wired, tag fisher credit PORT APPROXIMATION.

### P-CARRY-6 — `data.gd:359` + `game.gd` gather comments: no value change; cite efficiency typing

`gather_mult` float-mult at delivery (`game.gd:7478`) is shape-equal to donor `portion*eff div 100` with `eff` an Integer percent default 100 per (cid,restype) (`player.script:109`; upgrade arms `:1812-1831`). Keep the float container but floor the credited amount to Integer (donor `div`) and cite `unit.script:9557-9561`.

## 6. Remaining [U] register with fixed-seed traces (zero-mismatch criteria; never invent a capacity or rate)

| # | Item | Static state after this pass | Settling trace (fixed seed; log R2–R6 draws) |
|---|---|---|---|
| U-CAP | `else → 10` (`res.script:355-356`) reachability; per-(cid) `resefficiency` non-100 paths | Law quoted; no port branch | N/A (dead in practice) — keep documented, no trace required |
| U-CAD | work-cycle seconds per (action, nation); engine default interval factor on work path | Windows quoted (ukr 22/18/18 f, rus food 24 f @30 fps); factor unproven | Trace T-CAD: fixed seed, 1 ukr + 1 rus peasant per res, log `OnAclAnimationReachedWork` event ticks for 30 hits each; oracle `+1`/event, inter-hit gaps = window/30 s ±1 tick. Termination: 90/90 gaps match AND port `interval` replaced by per-action table; until then `1.25` stays labelled |
| U-PART | partial-load wait (`standtime>59`) + same-res top-up + different-res discard | Law quoted §3 | Trace T-PART: fixed seed, deplete node at carry 7/22 food; log order/retarget/`carry` each tick for 90 s sim; oracle: no credit, retarget-or-wait, order cleared only after 59 s standstill with `carry` intact (7), same-res reorder keeps 7, different-res reorder zeroes. Termination: tick-exact match 3/3 runs |
| U-FISH | fisher rate upgrades, `fishingmax` per boat sid, water-ring fallback | Base 12/s + 1000 quoted; upgrades/fallback unread per-sid | Trace T-FISH: fixed seed, 1 fishboat, log `resamount` per tick to full + delivery tick + retarget radius `(0.5+r)*15`; oracle: `floor(12*dt+prog)` accumulation, credit exactly 1000 at `dstSqr<16`, `resamount:=0`. Termination: tick-exact 3/3 runs |
| U-DEATH | load-on-death negative (no transfer) | Proven negative in text (§3) | No trace needed — absence agreement; port `_kill` already matches. Reopen only if a `resamount` write is found in a death path |

## 7. Explicit non-claims + file discipline

- No parity claimed. No donor binary executed, no GPU frame captured, no port capture compared. Closed items rest on donor text [O] with file:line; open items list exact next traces in §6.
- No capacity or rate invented: every number above carries a donor `path:line` (or is labelled [U]/approximation with its settling trace).
- Prior-report deltas: (a) delivery sites D1–D3 unchanged from market-tail (cited, not re-derived); (b) carry-animation tokens T8–T13/T22 unchanged from state-map/tool-attach (cited); (c) this report supersedes the port's partial-delivery and unconditional-reset shapes with verbatim donor branches.
- Read-only compliance: exactly one repo file written (this report). No `.gd`/config/save/asset/git change. Native evidence P8 items are cited prior passes, not new searches by this worker.

*End of DEC-U-CARRY.*
