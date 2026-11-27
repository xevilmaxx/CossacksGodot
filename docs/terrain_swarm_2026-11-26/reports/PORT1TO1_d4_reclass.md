---
id: PORT1TO1-D4-RECLASS-2026-11-27
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER D4-RECLASS — read-only rigorous assessment of class-D item D4 (market U6-T / DLT float edges); owner reclassification decision, no code and no close"
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_d4_reclass.md
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION
created: 2026-11-27
labels: [O, D, O-PORT, U, NO_APPROXIMATION, PARITY_UNVERIFIED]
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; D4 remains [U] and is NOT CLOSED; no approximations; no parity claim; no donor execution or A/B frame"
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
scope_guard: "Repo/doc/source reads only. No source, shader, asset, config, test, fixture, result JSON, backup, queue file or git state written; no donor binary executed/captured/copied; no Godot process, runner job, gate, harness, replay or port capture run. Exactly one repository file written: this report. No item closed, no value wired, no code changed."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_market_tail.md  (§1 law/capture U6-T; §2 dlt law/capture DLT; §5 port change list; §6 remaining [U])
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_d_cosmetic.md  (§2 D4 row; §3.4; §4 item 1 — D4 "NOT genuinely NB if market prices are in scope")
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_decisions.md  (:15/:32 reviewer line; :39 and :353 verdict form; :351 claim 4 "tails are never promoted")
  - variant3d/scripts/game.gd, variant3d/scripts/data.gd, variant3d/scripts/hud.gd, variant3d/scripts/ai.gd  (current port state, read-only)
---

# PORT1TO1 — Worker D4-RECLASS: rigorous D4 assessment and owner decision (2026-11-27)

> **Required reviewer line, verbatim (`PORT1TO1_owner_decisions.md:15/32`):**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> `parity.claim = NONE`, `parity.status = UNVERIFIED`, `visual_parity_claim = false`. `blocking_unverified` is non-empty, so the verdict is **`RESULT IS NOT GOOD`** unconditionally. No approximation is authorised; no donor binary was executed by this worker; no parity claim is made. D4 stays `[U]`; this report does not close it and does not re-tag it — it states the evidence and the exact owner decision rule.

---

## 0. Question put to this worker

`PORT1TO1_d_cosmetic.md §2` row 4, `§3.4` and `§4` item 1 flagged D4 (market `U6-T`/`DLT`) as **NOT genuinely non-blocking if market prices are in scope**, because the tail governs simulation price words. The owner accepts no approximations. This report answers four questions exactly: (1) the recovered donor law, (2) what the port implements *now*, (3) which `[U]` tails can change displayed/transacted skirmish prices, (4) the owner decision — the explicit out-of-scope condition that keeps D4 a tail, otherwise the exact fixed-seed captures that must pass before it can cease to block.

---

## 1. The exact donor law recovered `[O]`/`[D]`

All donor facts below are carried from `DEC_U_market_tail.md` against pin `t_87f0f3c130b0`; no donor text was re-executed or re-decompiled by this worker.

### 1.1 Cost-push on a trade — `res.script:320-344` (`DEC_U_market_tail.md §1`, lines 48-70)

Verbatim operator order `[O]`:

```pascal
weight := buyamount*gEconomy[buyres].buyexp;                                             // :337
gEconomy[buyres].buycost  := (gEconomy[buyres].buycost  + gEconomy[buyres].buycostmax*weight)/(1+weight);   // :338
gEconomy[buyres].sellcost := (gEconomy[buyres].sellcost + gEconomy[buyres].sellcostmax*weight)/(1+weight);  // :339
weight := sellamount*gEconomy[buyres].sellexp;                                           // :340 ← buyres, not sellres (quirk)
gEconomy[sellres].sellcost := (gEconomy[sellres].sellcost + gEconomy[sellres].sellcostmin*weight)/(1+weight); // :341
gEconomy[sellres].buycost  := (gEconomy[sellres].buycost  + gEconomy[sellres].buycostmin*weight)/(1+weight);  // :342
```

`[D]` consequences:

- The blend is the **rational weighted-average form `(c + bound*w)/(1+w)`**, never the linear `c+(bound-c)*w`. Linear and rational agree to first order for small `w`; for large `w` (donor AI `MarketTradeResources` amounts `5000–600000`, `progresseconomicai.inc:3016-3211`) linear overshoots by a relative `1/(1+w)` and can jump past the bound before clamping.
- **Push order is fixed: buy side toward max first, then sell side toward min** (`:337-342`). Exactly two rows are touched per trade (`buyres`, `sellres`) — four assignments, not a loop over all six resources.
- `:340` reads `gEconomy[buyres].sellexp`, not `sellres.sellexp`; numerically inert because `buyexp=sellexp=gc_economy_exp=0.00002` (`res.script:243-246`, `dmscript.global:810`). The quirk must be reproduced structurally (single `MARKET_EXP`), not "fixed".
- Head `[O]` (`:322-336`, `_res_MarketCalculateBuyAmount :313-316`): `sellamount` clamped to current stock; `buyamount := floor(sellamount*sellcost[sell]/buycost[buy])`; `stat.resbuy/ressell` incremented.

### 1.2 Live `garr_res_dlt` economy tracker — `res.script:252-268` (`DEC_U_market_tail.md §2`, lines 94-130)

`[O]`: project-mode gate is `GetProjectModeInt=2` = **game** (`dmscript.global:1418-1420`), so the updater **runs in skirmish** (supersedes the earlier "dlt=0 in skirmish" reading). Init `garr_res_dlt[i]:=0; garr_res_trg[i]:=0` (`:184`). Each global Progress tick (`:255-263`):

```
gflt_res_dlt += deltatime;                       // threshold relaxed >1 → >0 :256
r := Σ_j not gPlayer[j].res[i];                  // total stock over ALL player slots :260-261
garr_res_dlt[i] := round(Lerp(garr_res_dlt[i], ClampInt(r - garr_res_trg[i], 1, 1000), deltatime));  // :262
garr_res_trg[i] := r;                            // :263
```

Consumer (`:291`, recovery `:292-307`): `dt := deltatime*0.025*MaxFloat(1, garr_res_dlt[i]*0.01)`; costs are pulled toward **def** (`bcd=buycostdef`, `scd=sellcostdef`, aliases `:288-290`) by `bc-(bc-bcd)*dt` / `bc+(bcd-bc)*dt` with `Clamp(…min…max)`.

`[D]`: the factor is exactly `1.0` only while the economy is quiet (`dlt<100`); an active trading/mining tick raises `dlt` and accelerates recovery up to `×10` at `dlt=1000`. Hardcoding factor `1` is a quiet-economy special case, wrong in general.

### 1.3 What remains `[U]` (`DEC_U_market_tail.md §6`, lines 339-345)

| Id | Open piece | Settling capture |
|---|---|---|
| **U6-T** | `Lerp`/`ClampInt`/`floor` engine-defined float semantics at the blend/ordering edges; law form itself recovered §1 | **U6-T**: 36 floats, zero-mismatch (§1 lines 83-92) |
| **DLT** | exact `Lerp(a,b,t)` float semantics at `t=deltatime`; `round` and `ClampInt` assumed standard, unverified | **DLT**: 600-tick dlt + 12 costs, quiet + active windows, zero-mismatch (§2 lines 122-130) |
| O1 | global interleave of `_res_ProcessEconomy` vs per-player slice (`nothing.inc:84` vs `progress.inc:146-147`) | fixed-seed hash test (coupled input to DLT, separate id) |

---

## 2. Exactly what the port implements now `[O-PORT]`

Read-only reads of the current working tree (line numbers as read 2026-11-27; provenance only).

| Location | Current port state |
|---|---|
| `game.gd:546-548` (`new_player`) | `"market_rate": Data.MARKET_RATE` (display-only mirror), `"market_cost": {}`, `"market_dlt":[0.0]*6`, `"market_trg":[0.0]*6`. Comments at `:539-545` tag `market_rate` a display mirror, `market_dlt/trg` init 0 and LIVE in skirmish, and `[U]-DLT` awaiting capture. |
| `game.gd:5118-5128` (`_ensure_market_cost`) | Lazy per-resource `{buy, sell}` init to triplet `[1]` (def) per `res.script:247-248`. |
| `game.gd:5133-5183` (`trade`) | Market-building gate; `buyamount = int(floorf(amount*sellcost/buycost))` (`:5155`); `sellamt = minf(amount, res)` (`:5158`); stock deltas (`:5159-5160`). Push block `:5169-5180` implements the **rational blend** `(c+bound*w)/(1+w)` with `clampf(...,min,max)`: buy side toward `btrip[2]`/`bstrip[2]` (max) on `mc[want]` **first**, then sell side toward `strip[0]`/`sbtrip[0]` (min) on `mc[give]`; exactly two rows; both weights use the single `Data.MARKET_EXP` (`:340` quirk preserved). Self-labelled `[U]-U6-T` at `:5167-5168`: "floor/Lerp float semantics await fixed-seed capture U6-T (36 floats, zero-mismatch). NO PARITY CLAIM." |
| `game.gd:5196-5200` (`_ensure_market_dlt`) | Re-creates per-player `market_dlt`/`market_trg` arrays if missing or wrong size. |
| `game.gd:5202-5228` (`tick_market`) | Per player, per resource: `r_total` = sum of `q.res[ri]` over **all** players (`:5215-5218`); if `dt>0`, `dlt[ri] = roundf(lerpf(dlt[ri], clampf(r_total-trg[ri],1.0,1000.0), dt))` and `trg[ri] = r_total` (`:5219-5221`); `rdt = dt*Data.MARKET_RECOVERY_RATE*maxf(1.0, dlt[ri]*0.01)` (`:5223`); recovery `clampf(cb - (cb-def)*rdt, min, max)` for buy and sell (`:5227-5228`). Self-labelled `[U]-DLT` at `:5193-5194`. |
| `game.gd:5822-5823` | `tick_market(dt)` called once per global tick with `dt`, after `_tick_players_slice(dt)`; comment tags the interleave `[U]-O1`. |
| `data.gd:484-486,503-506` | `MARKET_EXP=0.00002`, `MARKET_TIME=0.0001*32.0=0.0032` (unconsumed per donor `:279-286`), `MARKET_RECOVERY_RATE=0.025`; triplet `[min, def, max]`. |
| `hud.gd:1095-1117`, `data.gd:477-481` | The rendered market rate label is the static `market_rate` mirror (`Data.MARKET_RATE=0.65`), explicitly labelled DEPRECATED/display-only; it is **not** driven by `market_cost`, `market_dlt` or `trade()`. |
| `ai.gd:621-624` | Current port AI calls `trade(rich, k, 100.0)` — small `w` in the port's own AI loop; the large-`w` stress cases belong to the donor AI amounts cited in §1.1 and to capture U6-T's script. |

**Net `[O-PORT]` finding:** the two superseded approximations named in the D4 flag — the linear push `c+(bound-c)*w` and the hardcoded recovery factor `1` — are **no longer present**. The port now carries the recovered rational law, buy-then-sell order, two-row scope, `MARKET_EXP` quirk, and the live `round(Lerp(ClampInt(...)))`/`maxf(1, dlt*0.01)` tracker. What remains is precisely the engine float-semantics `[U]` tail (U6-T, DLT) plus the coupled interleave `[U]` O1. This refines, but does not close, the earlier "linear-market remnants where still present" description: the residual is real but is now a bit-level/edge-semantics question, not a wrong-form question. No port-internal match is offered as donor parity.

---

## 3. Which `[U]` tails can change displayed or transacted skirmish prices

| `[U]` | Mechanism reaching prices | Effect in a skirmish |
|---|---|---|
| **U6-T** | `floorf(amount*sellcost/buycost)` (`:5155`) and the float evaluation/clamp ordering of `(c+bound*w)/(1+w)` (`:5173-5180`) | **Transacted prices:** the `buyamount` actually credited, and all 12 `market_cost` floats after each trade, can differ under large `w` (donor AI 5000–600000; capture scripts 100 / 5000 / 100000) or under any float32-vs-float64/half-way difference. This is a simulation-word divergence, not a UI-only effect. |
| **DLT** | `roundf(lerpf(dlt, clampf(r-trg,1,1000), dt))` + `trg=r` (`:5220-5221`) and `maxf(1.0, dlt*0.01)` (`:5223`) | **Transacted prices:** `r` changes with any production/mining/trade tick, so `dlt` and the recovery factor can diverge; once `dlt≥100` the factor exceeds 1 (up to ×10 at 1000), moving both costs faster toward def across the 600-tick window. Even a "quiet" window depends on `round`/`Lerp` semantics keeping `dlt<100`. |
| **O1** (coupled, separate id) | Order of `_res_ProcessEconomy` vs per-player slice (`:5822-5823`) | Changes the `r` input to `dlt` and the tick at which costs are sampled; must be held fixed by the same fixed seed for DLT to be meaningful. Not closed by D4. |
| E1 / LIFE (adjacent, separate ids) | Delivery stock changes feed `r_total`; `resonlife` container typing | Can perturb the `r` input to `dlt`; tracked under their own ids, not settled here. |

**Displayed prices — precise scope statement `[D]`/`[I]`:** in the *current* port UI the market rate label is the static `market_rate` mirror (`hud.gd:1095-1117`; `data.gd:477-481`), so U6-T/DLT do **not** change that rendered label; no current port UI reads `market_cost` for display. Therefore no port displayed-price divergence is asserted from the present HUD. The demonstrated exposure is **transacted prices and `market_cost` state**. If the owner's matched-scope includes a donor market cost display, or a port UI later wired to `market_cost`, then both U6-T and DLT also reach displayed prices — that is an owner-scope question, not a finding of this read-only pass. The static mirror itself is a labelled port approximation and is out of D4's U6-T/DLT scope.

---

## 4. Owner decision (concise, no re-tag performed by this worker)

**D4 is not genuinely cosmetic under a general skirmish scope.** It governs simulation words (cost floats and trade payouts). `PORT1TO1_d_cosmetic.md §2/§3.4/§4` already says so; §2/§3 above confirm the residual is now engine-float-semantics only, which can still change those words. The decision rule is binary and must be recorded explicitly by the owner:

### 4.1 Keep as a cosmetic/non-blocking tail ONLY under this explicit out-of-scope condition

All of the following must be stated in the matched-scope record, not assumed:

1. **Market prices are excluded from in-scope observables** — neither the 12 `market_cost` floats nor any trade payout / `buyamount` / resource delta attributable to `trade()` is compared donor-vs-port.
2. **No trade event occurs in the matched window** (no `trade()` call in the capture, human or AI), so U6-T is not exercised.
3. **Only a quiet economy is in scope** — `dlt` stays below 100 throughout, no active trading/mining window, so factor `max(1, dlt*0.01)` is identically 1 and DLT cannot change a cost.
4. The static `market_rate` HUD label is the only displayed market quantity, and it is treated as UI chrome (itself a labelled port approximation, not a donor-fidelity claim).

Under that narrow condition D4 touches no in-scope simulation word or pixel and may remain a documented non-blocking tail — still `[U]`, still NOT CLOSED, never promoted to close a P0 (`PORT1TO1_owner_decisions.md:351` claim 4).

### 4.2 Otherwise reclassify D4 as BLOCKING (simulation price divergence)

If market prices, any trade, or any active `dlt` window is in scope, D4 is a **blocking** item until **both** fixed-seed captures below return zero mismatch against the donor oracle. No approximation, retune, or port-internal self-consistency result substitutes.

**Capture U6-T** (`DEC_U_market_tail.md §1`, lines 83-92) — exact form:

- Setup: skirmish, fixed seed, one market, give player `100000` of each resource; record all six resources' buy+sell floats at full precision.
- Script: `trade(food→gold, 100)` ×1; `trade(wood→gold, 5000)` ×1; `trade(stone→gold, 100000)` ×1. Log all 12 costs after **each** trade (36 floats).
- Oracle from `[O]` only: `w=buyamount*0.00002` / `w=sellamount*0.00002`; rational blend `(c+bound*w)/(1+w)` in buy-then-sell order with the `:340` `buyres.sellexp` quirk; `buyamount=floor(sell*sellcost/buycost)`; per-triplet clamp `[min,max]`.
- Termination: **zero mismatch** — 36/36 logged floats bit-match the oracle AND the current port `trade()` on the same script. Until then `[U]-U6-T` stays.

**Capture DLT** (`DEC_U_market_tail.md §2`, lines 122-130) — exact form:

- Setup: fixed seed; 2 AI players trading/mining; fix the O1 interleave for the run. Log per tick: the dlt vector (patched port state), total stocks `r[i]`, and all 12 costs for **600 ticks**.
- Oracle: init `0`; each tick `r[i]` = summed stocks over all player slots; `dlt[i]=round(Lerp(dlt[i], ClampInt(r[i]-trg[i],1,1000), dt))`, `trg[i]=r[i]`; recovery with `dt_sim=dt*0.025*max(1, dlt[i]*0.01)` toward def, clamped `[min,max]`.
- Termination: **zero mismatch** on the dlt vector AND all 12 costs across the full window, with **one quiet window** (factor exactly 1) **and one active window** (factor >1). Until then `[U]-DLT` stays.

After both captures pass, the owner/COORD may rule on reclassification; this worker neither re-tags nor closes D4, and no donor execution or A/B frame was produced here.

---

## 5. What this report does not do

- No item is marked CLOSED; D4 remains `[U]`. No code, shader, asset, config, test, fixture, result JSON, backup, queue file or git state was written. No value was wired, retuned or approximated; the `[U]` tags in source remain.
- No donor binary was executed, no GPU/GL trace taken, no Godot process, gate, harness, replay, paired-save, port capture or donor A/B frame produced or compared. All donor facts are `[O]`/`[D]`/`[U]` carried from the cited reports pinned at `t_87f0f3c130b0`; all port facts are `[O-PORT]` reads of the working tree.
- No parity claim: `parity.claim = NONE`, `parity.status = UNVERIFIED`, `visual_parity_claim = false`. `blocking_unverified` remains non-empty; six-condition chain remains unclosed. No approximation is endorsed.

---

## 6. Claim register and verdict

| # | Claim | Label |
|---|---|---|
| 1 | Donor cost-push is `(c+bound*w)/(1+w)`, buy-to-max then sell-to-min, two rows, `buyres.sellexp` quirk, `buyamount=floor(sell*sellcost/buycost)` (`res.script:320-344`). | [O]/[D] `DEC_U_market_tail.md §1` |
| 2 | Donor `garr_res_dlt` is live in skirmish: `round(Lerp(dlt,ClampInt(r-trg,1,1000),dt))`, `trg=r`, factor `dt*0.025*Max(1,dlt*0.01)` (`res.script:252-268`; `dmscript.global:1418-1420`). | [O]/[D] `DEC_U_market_tail.md §2` |
| 3 | The port now implements the rational blend, buy-then-sell order, two-row scope, and the live dlt tracker with factor; the old linear push and hardcoded factor `1` are absent. Remaining tags are `[U]-U6-T`, `[U]-DLT`, coupled `[U]-O1`. | [O-PORT] `game.gd:5155,5169-5180,5193-5194,5219-5228`, `game.gd:5822-5823` |
| 4 | U6-T can change transacted amounts and 12 cost floats (large `w` / float semantics); DLT can change both costs via the dlt factor (active windows, round/Lerp semantics). Current HUD rate label is a static mirror and is not driven by these tails. | [D]/[I] `DEC_U_market_tail.md §6`; `game.gd:5155,5173-5180,5220-5228`; `hud.gd:1095-1117` |
| 5 | Owner rule: keep as tail only if market prices, trades and active-dlt windows are all explicitly out of scope; otherwise blocking until Capture U6-T (36 floats) and Capture DLT (600 ticks, quiet + active) both zero-mismatch. | [D] `DEC_U_market_tail.md §1/§2`; `PORT1TO1_d_cosmetic.md §2/§3.4/§4` |
| 6 | No donor executed, no gate/capture/harness run, no approximation adopted, no parity claimed; exactly one repository file written; D4 not closed. | [O] scope guard |

> **Verdict (verbatim governing form):** `port=UNVERIFIED`; `parity.claim = NONE`; `parity.status = "UNVERIFIED"`; `visual_parity_claim = false`; `blocking_unverified` non-empty (P0-1…P0-8 plus the open tails, D4 included); six-condition chain unclosed. **`RESULT IS NOT GOOD`.** No same-camera donor/port A/B frame exists; no approximation is authorised; no parity claim is made.

*End of PORT1TO1_d4_reclass. Read-only; exactly one repository file written; no source/asset/config/test/runner/Godot/git/donor-execution; D4 remains `[U]` and is NOT CLOSED; class-D status is a priority judgement, not a donor-fidelity claim; parity UNVERIFIED; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty.*
