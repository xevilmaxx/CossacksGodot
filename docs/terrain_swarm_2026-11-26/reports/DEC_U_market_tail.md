---
id: DEC-U-MARKET-TAIL
worker: DEC-U-MARKET-TAIL (subagent, full 1:1 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
scope: "READ-ONLY decomp. Donor binary never executed/copied. Donor text read as text only. No code/asset/config/Godot/git edit: this report is the only file written."
labels: "[O] verbatim donor bytes/text lines read this ticket · [D] deterministic reading of [O] · [I] inference, flagged · [U] UNVERIFIED with settling experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
upstream: "DEC_U_skirmish.md (§2.1-2.2, §2.5, §2.11, §3 M1/C1/E1/G1/O1) + DEC_U_skirmish_impl_patch.md (§§2-3, Patches 2b/3b, §10 U6-tail) + DEC_U_fog_camera_hud.md (§§7-8) + PORT1TO1_skirmish_logic.md §13 [U]"
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker."
network: "OUT OF SCOPE. No multiplayer/netcode law is wired or changed."
---

# DEC-U-MARKET-TAIL — cost-push interpolation, `garr_res_dlt`, delivery split, `resonlife` (2026-11-26)

## 0. Pass ledger (owner rule; every native call pinned `document:"t_87f0f3c130b0"`)

No new native byte-search was executed by this worker; the native anchors below are
**cited prior passes** (reused with attribution, not re-run). All new `[O]` this ticket
are donor-text reads (P5–P16), each with file:line.

| # | Pass | Result |
|---|---|---|
| P1 | cited `DEC_U_fog_camera_hud.md` P7 | **negative** `ev_43eace7f170c26b6df1a6b2271caaca35af5e0269c63e0455ad00495` — 0 matches utf8+utf16le for `resourceDropRadius` (script-side constant, expected) |
| P2 | cited `DEC_U_fog_camera_hud.md` P6 | **negative** `ev_d80780256b6c1c303f408eccf2422426b0d2bf85fe094a27e239b0d20d82870a` — 0 matches for `fogreveal` (script-side basename; engine stores it opaquely) |
| P3 | cited `DEC_U_skirmish.md` P2–P4 | **negative** `ev_c3804981595ae8e32f7250a675c54ac38863fa5625a840905922e4652a93981f4` (`SetRandomKey`), plus `RandomExt`/`bfamine`/`famine`/`victorystate` negatives — all script-side identifiers, as designed |
| P4 | cited `DEC_U_fog_camera_hud.md` P11 | **positive** `ev_88e08a5de6c9f4db8ce8e7ce6d9ad5dc2c1a082041e7ae4d0fe8ce7d923ad5c` — `spmRunTime` at file-off `0x11123d/0x1119c8` (selection write path; proves script/engine split, no market content) |
| P5 | donor-text read `res.script:180-250` | `[O]` market table init + `garr_res_dlt[i]:=0; garr_res_trg[i]:=0` (`:184`); buy/sell triplets `:186-242`; `buyexp/sellexp/buytime/selltime` + init-to-def `:243-248` |
| P6 | donor-text read `res.script:252-309` | `[O]` `_res_CalcDeltaResources` (`:252-268`, gate `:254`); `_res_ProcessEconomy` recovery (`:272-309`); old linear block commented out (`:279-286`); live exponential (`:287-307`); centre aliases `bcd/scd` (`:288-290`); factor `:291` |
| P7 | donor-text read `res.script:311-344` | `[O]` **exact cost-push interpolation law** `:337-342` (rational blend, not linear); trade head `:320-336` |
| P8 | donor-text read `player.script:240-322` | `[O]` income accumulator (`:242-266`, `speed=256/1.024`); consume accumulator (`:270-317`); **`resonlife` surplus handling** (`:290-302`); clearing gates (`:318-321`); gold income-vs-consume test (`:231-238`, `:306`) |
| P9 | donor-text read `player.script:20-27,102-105` + `classes.script:3445-3453` | `[O]` `resonlife` is `Integer` array (`classes.script:3451`), zero-init (`player.script:25`); counters zero-init (`:102-105`) |
| P10 | donor-text read `dmscript.global:165-182,203-220,805-811,1418-1420` | `[O]` conversions (`px/m /26.6666666, m/tile 2, px/tile 53.3333333, frames↔s 32/0.03125 :170-176`); global delivery `resourceDropRadius=3` (`:210`) + `…Sqr=9` (`:220`); `gc_economy_exp=0.00002`, `gc_economy_time=0.0001*gc_time_to_frames` (`:810-811`); **project modes none=0/editor=1/game=2** (`:1418-1420`) |
| P11 | donor-text read `unit.script:9690-9705`, `12000-12050` + `misc.script:4504-4543` | `[O]` storehouse drop (`:9699-9705`, `0.5`-sqr, `resourcePoint` correction `:9702`); fisher drop (`:12027-12035`, `4*4`-sqr, `GetPortResourcePoint` `:12028`); fisher radius literal `gc_fisher_radius_move_change=15.0` (`:12005`), re-target `(0.5+random)*15` (`:12039`); port-point fallback ring `minDist 3..11/precise` (`misc.script:4525-4534`) |
| P12 | donor-text read `unit.script:9555-9570,11991-11998` | `[O]` peasant/fisher add paths credit `restotal` (`:9569`, `:11997`); amounts from portion×efficiency (`:9557-9561`) / boat capacity (`:11995`) — neither touches `resonlife` |
| P13 | donor-text read `progress.inc` + `nothing.inc` | `[O]` global tick calls `_res_ProcessEconomy(deltatime)` (`nothing.inc:84`); per-player slice calls income then consume (`progress.inc:146-147`) |
| P14 | donor-text read `writestats.inc:16-92` + `readstats.inc:27-55` | `[O]` `resonlife/resbuy/ressell/restotal` are statistics records round-tripped via `RecordCustom*` (`write :45-53,64-92`; `read :27-55`) — NOT the sim stock |
| P15 | donor-text grep `garr_res_dlt` whole `data/scripts` | `[O]` only 4 hits, all `res.script` (`:184` init, `:262-263` update, `:291` consume). No other reader/writer. No native counterpart (script-side array, cf. P1 negative) |
| P16 | port read `variant3d/scripts/game.gd` + `data.gd` (read-only, lines in §5) | `[O]` port current shape: `trade()` linear pushes (`game.gd:4748-4761`, self-labelled `[I]`); `tick_market()` hardcoded `rdt=dt*0.025` (`:4781`); upkeep bank exact (`:5415`); **port `else`-branch `resonlife += have`** (`:5449-5454`) with no donor counterpart; unified delivery test (`:6702-6703`) |

## 1. [U]-U6-T CLOSED-AS-RESOLVED: exact cost-push interpolation law

**Prior state.** `DEC_U_skirmish.md` §2.2 recovered direction + `weight=amount*exp` but left the
blend form `[I]`; `DEC_U_skirmish_impl_patch.md` Patch 3b shipped the linear guess
`cur+(bound-cur)*weight` explicitly labelled `[I]` with experiment `§9-U6-T`.

**Donor law `[O]`** (`res.script:320-344`, verbatim operator order):

```pascal
weight := buyamount*gEconomy[buyres].buyexp;                                             // :337
gEconomy[buyres].buycost  := (gEconomy[buyres].buycost  + gEconomy[buyres].buycostmax*weight)/(1+weight);   // :338
gEconomy[buyres].sellcost := (gEconomy[buyres].sellcost + gEconomy[buyres].sellcostmax*weight)/(1+weight);  // :339
weight := sellamount*gEconomy[buyres].sellexp;                                           // :340 ← buyres, not sellres
gEconomy[sellres].sellcost := (gEconomy[sellres].sellcost + gEconomy[sellres].sellcostmin*weight)/(1+weight); // :341
gEconomy[sellres].buycost  := (gEconomy[sellres].buycost  + gEconomy[sellres].buycostmin*weight)/(1+weight);  // :342
```

with head `[O]` (`:322-336`): `sellamount` clamped to current stock
(`if sellamount>not gPlayer[plInd].res[sellres]`, `not` = value-read per DEC_U_skirmish §0 DSL);
`buyamount := floor(sellamount*sellcost[sell]/buycost[buy])` (`_res_MarketCalculateBuyAmount :313-316`);
additions + `stat.resbuy[buyres]+=buyamount`, `stat.ressell[sellres]+=sellamount` (`:335-336`).

**`[D]` consequences (load-bearing for the port patch):**

1. The blend is the **rational (weighted-average) form** `(c + bound*w)/(1+w)`, NOT the linear
   `c+(bound-c)*w`. For small `w` they agree to first order (`w/(1+w) ≈ w`), but for large
   `w` (e.g. AI `MarketTradeResources` calls with amounts 5000–600000 in
   `progresseconomicai.inc:3016-3211`) the linear form overshoots by `1/(1+w)`-relative error
   and can jump past the bound before clamping. The port MUST replace, not retune.
2. **Push order is fixed: buy-side first (toward max), then sell-side (toward min)** (`:337-342`).
   The port currently applies both pushes per-resource in the same `for rn` loop — that matches
   only if the loop body preserves the buy-then-sell order per key (it does today, but see §5.1).
3. **Latent donor quirk `[O]`:** `:340` reads `gEconomy[buyres].sellexp`, not `sellres.sellexp`.
   Numerically inert today because `buyexp=sellexp=gc_economy_exp=0.00002` for every res
   (`:243-246`, `dmscript.global:810`). The port must reproduce the quirk structurally
   (single `MARKET_EXP`) and cite this line; do NOT "fix" it to `sellres`.
4. Per-trade scope: pushes apply to **both costs of the bought res, then both costs of the sold res**
   — four assignments total, not per-resource loops over all six resources. The port's
   `for rn in RES_NAMES` loop over all resources per trade is a **wrong-shape loop**:
   donor touches exactly two rows (`buyres`, `sellres`).

**Fixed-seed capture U6-T (zero-mismatch criterion; never invent a rate):**

- Setup: skirmish, fixed seed, one market, give player 100000 of each res, record
  `market_cost` for all six resources (buy+sell floats, full precision).
- Script: `trade(food→gold, 100)` ×1; `trade(wood→gold, 5000)` ×1; `trade(stone→gold, 100000)` ×1.
  Log all 12 costs after each trade.
- Oracle (from `[O]` only): `w=buyamount*0.00002` / `w=sellamount*0.00002`; rational blend above;
  `buyamount=floor(sell*sellcost/buycost)`; clamp `[min,max]` per triplet (`:186-242`).
- Termination: **zero-mismatch** — all 36 logged floats bit-match the oracle AND the patched
  port's `trade()` on the same script. Until then the `[I]` label stays.

## 2. `garr_res_dlt` in skirmish: prior "0" READS WRONG — live value, law recovered

**Correction `[D]` (supersedes impl-patch Patches 3b/§10 "project-mode-gated ⇒ 0 in skirmish").**
`dmscript.global:1418-1420` `[O]`: `gc_project_mode_none=0, editor=1, game=2`.
`_res_CalcDeltaResources` gate is `if GetProjectModeInt=2` (`res.script:254`) — i.e. **the live
game**, not the editor. Skirmish runs with mode 2, so the updater RUNS in skirmish.

**Full law `[O]` (`res.script:252-268`):**

- Init: `garr_res_dlt[i]:=0; garr_res_trg[i]:=0` for all res (`:184`, inside `_res_InitEconomy`).
- Tick (called every global Progress tick via `nothing.inc:84` → `_res_ProcessEconomy` → `:274`):
  `gflt_res_dlt += deltatime` (`:255`); `if gflt_res_dlt>0` (`:256`; donor comment shows the
  threshold was relaxed from `>1` to `>0`, so **effectively every tick with `deltatime>0`**):
  per res `i`: `r := Σ_j not gPlayer[j].res[i]` (total stock over all `gc_MaxPlayerCount` slots,
  `:260-261`); `garr_res_dlt[i] := round(Lerp(garr_res_dlt[i], ClampInt(r-garr_res_trg[i],1,1000), deltatime))`
  (`:262`); `garr_res_trg[i] := r` (`:263`).
- Consumer: `dt := deltatime*0.025*MaxFloat(1, garr_res_dlt[i]*0.01)` (`:291`); recovery `:292-307`
  pulls `buycost/sellcost` toward **def** (`bcd=buycostdef, scd=sellcostdef`, aliases `:288-290`)
  with `bc-(bc-bcd)*dt` / `bc+(bcd-bc)*dt` branches and `Clamp(…min…max)`.

**`[D]` semantics:** `garr_res_dlt[i]` is a per-resource **economy-activity tracker**
(smoothed per-tick change of total stock, clamped to `[1,1000]`, `Lerp`-smoothed by `deltatime`).
Factor `MaxFloat(1, dlt*0.01)` is therefore `1.0` only while the economy is quiet
(`dlt<100`); an active trading/mining tick drives `dlt` up and **accelerates price recovery**
(up to ×10 at `dlt=1000`). Hardcoding factor `1` (port `tick_market()` today) is a
**quiet-economy special case**, wrong in general. `Lerp`/`ClampInt` engine semantics stay
`[I]` (linear `a+(b-a)*t`, int clamp — standard; confirm by the capture below, never by redefinition).

**Fixed-seed capture DLT (zero-mismatch criterion; never invent a rate):**

- Setup: fixed seed, 2 AI players trading/mining, log per-tick `garr_res_dlt[i]` equivalent
  (patched port state), total stocks `r[i]`, and all 12 costs for 600 ticks.
- Oracle: init 0; each tick `r[i]` = summed stocks; `dlt[i] = round(lerp(dlt[i], clamp(r[i]-trg[i],1,1000), dt))`,
  `trg[i]=r[i]`; recovery with `dt_sim=dt*0.025*max(1,dlt[i]*0.01)` toward def.
- Termination: **zero-mismatch** on the dlt vector AND all 12 costs for the full 600-tick window,
  including one quiet window (factor exactly 1) and one active window (factor >1).
  Until then the dlt path keeps its `[U]` tag in the port.

## 3. Three delivery-radius call sites (units / squared semantics / point corrections)

All three literals are `[O]`; the port must branch per call site, never unify.

| # | Call site | Literal `[O]` | Comparison | Units / squared semantics `[D]` |
|---|---|---|---|---|
| D1 | global default | `gc_gameplay_resourceDropRadius = 3` (`dmscript.global:210`); `…Sqr = 3*3 = 9` (`:220`) | linear 3 vs squared 9 | gameplay length units (≈ metres: `px/m /26.6666666`, `m/tile 2`, `px/tile 53.3333333` per `:170-172`). Only where the global is consumed |
| D2 | peasant storehouse drop | `const gc_gameplay_resourceDropRadiusSqr = 0.5` (`unit.script:9704`); test `if (dstSqr<0.5)` (`:9705`) | **squared** distance `< 0.5` | world-unit², i.e. radius `√0.5 ≈ 0.707` length units. Lexical shadow: the `const` hides the global inside this function — reading the global here is wrong-shape |
| D3 | fisher port drop | `const gc_gameplay_resourceDropRadiusSqr = 4*4` (`unit.script:12032`); test `if (dstSqr<…)` (`:12033`) | **squared** distance `< 16` | world-unit², i.e. radius `4` length units. Same shadowing rule |

**Point corrections `[O]` (what the distance is measured against):**

- D2: peasant position vs **storehouse position + `resourcePoint` offset**:
  `dstSqr = Sqr(px-(stox+resourcePoint.x)) + Sqr(pz-(stoz+resourcePoint.z))`
  (`unit.script:9702`, via `gCustomObjPoints[cid][id].resourcePoint`). The plain
  building-centre form on `:9703` is **commented out** (dead — do not port).
- D3: fisher position vs **`_misc_GetPortResourcePoint(storehouseHnd, resx, resz, True)`**
  (`unit.script:12028`): `bui`-child absolute position when the port building is built
  (`misc.script:4506-4518`); else a water-ring search fallback (`minDist 3 / maxDist 11`,
  precise `3-6=…/72 tries`, `misc.script:4520-4543`). Port `nearest_drop` + centre distance
  matches neither arm.
- Golden paths after a hit `[O]`: D2 → `_unit_PeasantAddResToPlayerByIndex` + re-target
  (`:9707-9738`); D3 → `_unit_FisherAddResToPlayerByIndex(pl,go,food)` + `resamount:=0` +
  new water target `(0.5+random)*gc_fisher_radius_move_change` with
  `gc_fisher_radius_move_change=15.0` (`unit.script:12005,12035-12050`; second site `:12090`).

**Port gap `[O]`** (`game.gd:6688-6712`): single unified test
`d > Data.DELIVERY_RADIUS_M + store.def.radius` (`:6703`, with `DELIVERY_RADIUS_M=3 tiles=6.0 m`
from `data.gd:292`), centre-to-centre, no `resourcePoint`/port-point correction, no fisher branch.
Fisher delivery has no port call site at all (grep §P16: no `GetPortResourcePoint` consumer).

**Fixed-seed capture DELIVERY (zero-mismatch criterion; never invent a radius):**

- D2: peasant with full load walks to a storehouse; log per-tick `dstSqr` (with `resourcePoint`
  offset) and the drop tick. Oracle: drop on first tick with `dstSqr<0.5`.
- D3: laden fisher returns to a port; log per-tick `dstSqr` (vs `GetPortResourcePoint`) and the
  credit tick + re-target radius `(0.5+random)*15.0`. Oracle: credit on first tick with `dstSqr<16`.
- D1: only where the port proves a global-consumer call site in donor text (none found this
  ticket — stays `[U]`; do not wire the global into D2/D3).
- Termination: **zero-mismatch** — drop/credit ticks and post-drop state (carry cleared,
  `restotal` credited, re-target issued) match on 20/20 seeded runs per site.

## 4. `resonlife` surplus handling: NO surplus — lifetime-consumption counter

**Donor law `[O]`** (`player.script:270-322` + types/init):

- `resonlife` is an **`Integer` per-res statistics counter**, sibling of `restotal/resbuy/ressell`
  (`classes.script:3445-3453`), zero-init (`player.script:25`; `restotal :20`, `resbuy :26`,
  `ressell :27`; counters zeroed `:102-105`). It is written ONLY in
  `_player_ProcessResourceConsume` (`:288-312`), inside `if (value<>0)` — **never on zero-value
  ticks, never in the income engine** (income credits `restotal`, `:260`), never in the
  peasant/fisher add paths (those credit `restotal`, `unit.script:9569/11997`).
- Surplus branch (`have >= value`, `:290-297`): `resonlife[i] += value` (`:292`);
  stock `-= value` (`:293`); `bfamine:=False` (food) / `brebellion:=False` (gold) (`:295-296`).
- Shortfall branch (`have < value`, `:299-312`): `resonlife[i] += not res[i]` (`:301`,
  i.e. **the entire remaining stock**, value-read); stock zeroed (`:302`); food → `bfamine:=True`
  (`:304`); gold → `brebellion` iff `consume>income` else `False` (`:305-310`).
- Clearing (`:318-321`): `brebellion:=False` iff `not (res[gold]>=2)` or consume≤0;
  `bfamine:=False` iff `not (res[food]>0)` or consume≤0.
- Persistence: statistics records round-trip via `RecordCustom*`
  (`writestats.inc:45-53,84-92`; `readstats.inc:47-55`) — statistics, not live stock.

**`[D]` (the "surplus detail" answer):** there is NO surplus handling in `resonlife` — the
counter records lifetime consumption (value actually deducted, or the whole remaining stock on
the starving tick). Leftover fractional bank stays in `resconsumeremains`
(`:315`, `floor(bank*mult)`); leftover stock stays in `res[i]`. A port that adds "surplus" to
`resonlife` invents law.

**Port gap `[O]`** (`game.gd:5449-5454`): on `value==0` ticks the port executes
`rl[idx] += have` (whole current stock, every sub-unit tick) — a path with **no donor
counterpart** (donor writes nothing when `value=0`). Additionally the port stores `resonlife`
as float (`new_player()` `:411`) vs donor `Integer`.

**Fixed-seed capture LIFE (zero-mismatch criterion; never invent a rate):**

- Setup: fixed seed; player A with stock 10 food, consume counter `32` (1 food / 19.5 s);
  player B with stock 0 food, same consume. Run 40 s (two consumption quanta).
- Oracle: A: first quantum `resonlife[food]=1`, stock 9; B: starving tick `resonlife[food]+=0`
  (empty stock adds 0), `bfamine=True` until clearing gate (`res[food]>0` or consume≤0).
  `value==0` ticks change NOTHING in `resonlife`.
- Termination: **zero-mismatch** on `resonlife[6]`, `res[6]`, `bfamine/brebellion` for both
  players across the window, plus `Integer`-typed statistics surviving a save round-trip.

## 5. Concrete port change list (owner/COORD applies; this worker wrote no code)

Paths are `variant3d/scripts/…` (verified present). Line numbers are as-read 2026-11-26,
provenance only — re-anchor by function name + verbatim text (files are concurrently edited).

### 5.1 `game.gd` — `trade()` (`:4720-4764`): replace linear pushes with the exact rational law

Replace exactly this text (`:4748-4761`):

```gdscript
	# [I] interpolation form "cur + (bound-cur)*weight" is the minimal reading
	# of "push toward"; confirm verbatim at res.script:313-344 (experiment
	# §9-U6-T). Direction and weight are donor; the exact form is labelled.
	var wbuy: float = float(buyamount) * Data.MARKET_EXP
	var wsell: float = sellamt * Data.MARKET_EXP
	for rn in Data.RES_NAMES:
		var key := str(rn)
		var btrip: Array = Data.market_triplet(key, true)
		var strip: Array = Data.market_triplet(key, false)
		var cb: Dictionary = mc[key]
		cb["buy"] = clampf(float(cb["buy"]) + (float(btrip[2]) - float(cb["buy"])) * wbuy, float(btrip[0]), float(btrip[2]))
		cb["sell"] = clampf(float(cb["sell"]) + (float(strip[2]) - float(cb["sell"])) * wbuy, float(strip[0]), float(strip[2]))
		cb["buy"] = clampf(float(cb["buy"]) + (float(btrip[0]) - float(cb["buy"])) * wsell, float(btrip[0]), float(btrip[2]))
		cb["sell"] = clampf(float(cb["sell"]) + (float(strip[0]) - float(cb["sell"])) * wsell, float(strip[0]), float(strip[2]))
```

with (donor `res.script:337-342`; two rows only; rational blend; `buyres.sellexp` quirk kept):

```gdscript
	# RESOLVED donor cost-push (res.script:337-342). Rational blend, buy-side
	# first toward max, then sell-side toward min. :340 reads buyres.sellexp
	# (quirk; buyexp==sellexp so numerically inert). NO PARITY CLAIM.
	var wbuy: float = float(buyamount) * Data.MARKET_EXP
	var bcb: Dictionary = mc[want]
	var btrip: Array = Data.market_triplet(want, true)
	var bstrip: Array = Data.market_triplet(want, false)
	bcb["buy"] = clampf((float(bcb["buy"]) + float(btrip[2]) * wbuy) / (1.0 + wbuy), float(btrip[0]), float(btrip[2]))
	bcb["sell"] = clampf((float(bcb["sell"]) + float(bstrip[2]) * wbuy) / (1.0 + wbuy), float(bstrip[0]), float(bstrip[2]))
	var wsell: float = sellamt * Data.MARKET_EXP   # donor :340 uses buyres.sellexp == MARKET_EXP
	var scb: Dictionary = mc[give]
	var strip: Array = Data.market_triplet(give, false)
	var sbtrip: Array = Data.market_triplet(give, true)
	scb["sell"] = clampf((float(scb["sell"]) + float(strip[0]) * wsell) / (1.0 + wsell), float(strip[0]), float(strip[2]))
	scb["buy"] = clampf((float(scb["buy"]) + float(sbtrip[0]) * wsell) / (1.0 + wsell), float(sbtrip[0]), float(sbtrip[2]))
```

Keep the head (`:4730-4747`: market-building gate, `floor(amount*sellcost/buycost)`,
sell-clamp) byte-identical — it already matches `:322-336`.

### 5.2 `game.gd` — `tick_market()` (`:4771-4784`): implement the live `garr_res_dlt` factor

Replace `var rdt: float = dt * Data.MARKET_RECOVERY_RATE` (`:4781`) with per-res state.
Add to `new_player()` (`:421`) next to `"market_cost"`: `"market_dlt": [0.0]*6, "market_trg": [0.0]*6`
(sizes follow `Data.RES_NAMES`; init 0 per `res.script:184`). Then per res `i`:

```gdscript
		# RESOLVED dlt tracker (res.script:252-268; game mode = 2, dmscript.global:1420).
		# Lerp/ClampInt engine semantics stay [I] until capture DLT closes.
		var r_total: float = 0.0
		for q in players:
			r_total += float(q.res[ri])
		var dlt: Array = p.get("market_dlt", [0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
		var trg: Array = p.get("market_trg", [0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
		dlt[ri] = roundf(lerpf(float(dlt[ri]), clampf(r_total - float(trg[ri]), 1.0, 1000.0), dt))
		trg[ri] = r_total
		var rdt: float = dt * Data.MARKET_RECOVERY_RATE * maxf(1.0, float(dlt[ri]) * 0.01)
```

Notes: `gflt_res_dlt>0` gate (`:256`) is subsumed (any `dt>0` updates); `r` sums over ALL
player slots per `:261` — the loop above must sum global stocks, not `p` alone; store
`market_dlt/trg` per player is a port container choice, values must equal the global
computation (assert in capture DLT). Recovery branches + `[min,max]` clamps (`:4783-4784`)
stay, with `bcd/def` already the triplet `[1]` (correct per `:288-290`).
`BUYTIME/SELLTIME` (`MARKET_TIME=0.0032`) remain correctly unconsumed (commented-out donor
`:279-286` — do not reintroduce).

### 5.3 `game.gd` — `_gather_deliver()` (`:6688-6712`) + `nearest_drop()` (`:3789-3803`): branch three radii

- D2 (peasant→storehouse): replace the unified `:6702-6703` test on that path with
  squared test `dstSqr < 0.5` where `dstSqr` uses the **storehouse `resourcePoint` offset**
  (`unit.script:9702`). Until the offset is ported, tag the centre-distance form
  `PORT APPROXIMATION [U]-E1` and gate the `0.5`-sqr threshold behind the corrected point —
  never apply the global `3`/`DELIVERY_RADIUS_M` at this site.
- D3 (fisher→port): NEW call site (no port counterpart today). Implement
  `_fisher_deliver()` mirroring `:12027-12050`: squared test `dstSqr < 16.0` vs
  `GetPortResourcePoint` (port-point; fallback ring per `misc.script:4520-4543` stays `[U]`
  until read), credit boat capacity + `restotal` (`:11993-11998`), clear `resamount`,
  re-target `(0.5+random)*15.0` (`:12039`, `gc_fisher_radius_move_change=15.0` at `:12005`).
- D1 (global `3` / `Sqr 9`): do NOT consume at D2/D3. Leave `DELIVERY_RADIUS_M`
  (`data.gd:292`) only where a donor global-consumer is proven (none this ticket — stays `[U]`).

### 5.4 `game.gd` — `_tick_upkeep_for_player()` (`:5405-5455`): delete the invented `resonlife` write

Delete the `else`-branch write (`:5449-5454`):

```gdscript
		else:
			rem[k] = bank * Data.UPKEEP_MULT
			# donor stat.resonlife += value-read res (not res boolean).
			var rl: Array = p.get("resonlife", [0.0, 0.0, 0.0, 0.0, 0.0, 0.0])
			rl[idx] = float(rl[idx]) + have
			p["resonlife"] = rl
```

replacing with `rem[k] = bank * Data.UPKEEP_MULT` only (donor writes nothing when `value=0`,
`player.script:288`). Move the `resonlife` credit explicitly into the two `value>0` arms to
mirror `:292/:301` (add `value` on surplus, add whole `have` on shortfall), and floor/integer
the stored values (donor `Integer`; port float array at `:411` stays as container but must hold
integral values — assert in capture LIFE). Keep the bank math (`:5415-5416`) byte-identical:
`eat=SPEED`-scaled (`totals` at `:5361-5376` with `/UPKEEP_DIVISOR`) is exactly
`resconsume*32` per DEC_U_skirmish_impl_patch §2 consistency check — no new rate.

### 5.5 `data.gd` — comments/labels only (no value changes; values already match `[O]`)

- `:398-400` `MARKET_EXP=0.00002 / MARKET_TIME=0.0032 / MARKET_RECOVERY_RATE=0.025`: append cites
  `dmscript.global:810-811`, `res.script:243-246,291`. No value change.
- `:401-416` triplets: append per-row cites `res.script:186-242`
  (food sell `18.24095*0.8333 ×0.7/×1.3`; stone sell `19.29725*1.08306 ×0.75/×1.25`;
  iron/coal buy `80+20/100+40/120+60`). No value change.
- `:292` `DELIVERY_RADIUS_M`: re-tag `PORT APPROXIMATION at D2/D3 sites` (§3; global `:210` only).
- `:293-300` upkeep/income constants: append `player.script:240-322` (already correct; `625=20000/32`).

## 6. Remaining `[U]` register (this ticket; no values substituted)

| # | Item | Static state after this pass | Settling experiment |
|---|---|---|---|
| U6-T | blend/ordering edge cases | Law recovered §1; `Lerp`/`ClampInt`/`floor` engine semantics standard but engine-defined | Capture U6-T §1 (36 floats, zero-mismatch) |
| DLT | `Lerp(a,b,t)` exact float semantics for `t=deltatime` | Assumed linear; `round`/`ClampInt` assumed standard | Capture DLT §2 (600-tick dlt+costs, zero-mismatch) |
| E1 | D2 `resourcePoint` values per building; D3 `GetPortResourcePoint` fallback ring; D1 global consumers | Offsets/ring unread per-building; no proven D1 consumer | Captures D2/D3 §3 (20/20 runs each, zero-mismatch); text read of `gCustomObjPoints` + `misc.script:4544+` for the ring |
| LIFE | `resonlife` Integer-vs-float container | Law recovered §4; port container float | Capture LIFE §4 + save round-trip asserting integral statistics |
| O1 | global interleave of `_res_ProcessEconomy` vs per-player slice | `nothing.inc:84` (global) vs `progress.inc:146-147` (per-player) both `[O]`; order between them engine-driven | Fixed-seed hash test per DEC_U_fog_camera_hud §7.2 |

## 7. Explicit non-claims + file discipline

- No parity claimed. No donor binary executed, no GPU frame captured, no port capture compared.
  Closed items rest on donor text `[O]` with file:line; open items list exact next reads/captures in §§1–4, 6.
- Corrections disclosed: (a) §2 supersedes the impl-patch "dlt=0 in skirmish" reading with the
  mode-2 (`dmscript.global:1420`) correction; (b) §1 replaces the impl-patch linear `[I]` blend
  with the verbatim rational law; (c) §4 deletes a port `else`-branch write with no donor counterpart.
  No rate or radius was invented in this report.
- Read-only compliance: exactly one repo file written (this report). No `.gd`/config/save/asset/git change.
  Native evidence ids in §0 P1–P4 are cited prior passes, not new searches by this worker.

*End of DEC-U-MARKET-TAIL.*
