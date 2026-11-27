---
id: DEC-U-D4-FLOATS-2026-11-27
worker: DEC-U-D4-FLOATS (subagent, full 1:1 Cossacks 3 donor port)
date: 2026-11-27
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
scope: "READ-ONLY static donor-text sweep over C:\\Games\\Cossacks 3\\data\\scripts\\** plus repo reports. No donor binary executed/copied. No code/Godot/git edits: this report is the only file written."
pin: "t_87f0f3c130b0 (carried from DEC_U_market_tail.md; not re-verified by this worker — no native execution)"
labels: [O, D, U, NO_APPROXIMATION, PARITY_UNVERIFIED, NO_PARITY_CLAIM]
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified non-empty; D4 remains [U]/blocking unless explicitly excluded; chain 0/6"
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_d4_reclass.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_register2.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_market_tail.md
tooling: "read-only shell only (Get-ChildItem / Select-String / Get-FileHash) over donor text. No donor execution/copying. Native craftanything not used (pin t_87f0f3c130b0 therefore not re-verified here)."
---

# DEC-U-D4-FLOATS — static donor-text sweep: dlt transfer / market price computation, 36-float table (2026-11-27)

## 0. Method and negative scope

Read-only `Select-String` / `Get-FileHash` passes only. Every `[O]` below is a
verbatim donor-text line with `path:line` as returned by `Select-String`.
`[D]` is a deterministic reading of that text. `[U]` is everything requiring
live execution. No price value is invented; no static literal is promoted to
live port behaviour.

Swept donor roots (all reads 2026-11-27):

- `C:\Games\Cossacks 3\data\scripts\lib\res.script`
- `C:\Games\Cossacks 3\data\scripts\dmscript.global`
- `C:\Games\Cossacks 3\data\scripts\lib\country.script`
- `C:\Games\Cossacks 3\data\scripts\lib\player.script`
- `C:\Games\Cossacks 3\data\gui\menu.inc\donewgame.inc`
- `C:\Games\Cossacks 3\data\game\var\startingsettings.cfg`
- `C:\Games\Cossacks 3\data\scripts\units\global.inc\progresseconomicai.inc` (AI call-site amounts only)

Byte identity (read-only `Get-FileHash`, SHA256, path truncated by shell):

| File | SHA256 |
|---|---|
| `...\data\scripts\lib\res.script` | `3F96F486F4ED94798619F6A4944678798D25461DD6F4113AA720E2B7B22DED18` |
| `...\data\scripts\dmscript.global` | `65DDD3860C4BCD28BB1742892D10259121EBF19700650E9FE2DF18206AB29590` |
| `...\data\scripts\lib\country.script` | `96156485571558506037A3CB85E496A1D1D978600E81D8CA2DA94AB230F953CA` |
| `...\data\scripts\lib\player.script` | `9C83789F83A1F6661B9D757E9777A53C9271939C4B39B4D47D3C4FB4ABB28FB5` |
| `...\data\gui\menu.inc\donewgame.inc` | `F51A786976D3FD8B3726872073670A97CA9291D68D0E6D9E9F02EE8C79FE1908` |
| `...\data\game\var\startingsettings.cfg` | `17D4AEDDAF4496594BDA74E5F1FCC4F8FF0E149A5B2A53211C8F1EBA200C111F` |

`donewgame.inc` / `startingsettings.cfg` are NOT under `data\scripts\**`;
resolved via `Get-ChildItem 'C:\Games\Cossacks 3\data' -Recurse`.
Both contain no price law (see §5).

## 1. Price-computation text: complete literal + consumer map `[O]`

### 1.1 Type declarations (float-vs-int recoverable statically) `[O]`

`C:\Games\Cossacks 3\data\scripts\dmscript.global:1923-1936` (`Select-String 'TEconomy' -Context 0,14`):

```pascal
TEconomy : struct.begin            // :1923
  buycostmin = Float              // :1924
  buycostdef = Float              // :1925
  buycostmax = Float              // :1926
  buyexp = Float                  // :1927
  buytime = Float                 // :1928
  sellcostmin = Float             // :1929
  sellcostdef = Float             // :1930
  sellcostmax = Float             // :1931
  sellexp = Float                 // :1932
  selltime = Float                // :1933
  buycost = Float                 // :1934
  sellcost = Float                // :1935
struct.end                        // :1936
```

`C:\Games\Cossacks 3\data\scripts\dmscript.global:2058`:

```pascal
gEconomy = TEconomy[gc_ResCount]  // :2058, with gc_ResCount = 7 (:3)
```

`C:\Games\Cossacks 3\data\scripts\dmscript.global:2343-2345`:

```pascal
gflt_res_dlt = Float              // :2343
garr_res_dlt = Integer[gc_ResCount] // :2344
garr_res_trg = Integer[gc_ResCount] // :2345
```

`[D]`: all 12 live costs + 4 bound/def floats per resource + both `exp` +
both `time` are `Float`. The dlt tracker state `garr_res_dlt/trg` is
`Integer` per resource; only the accumulator `gflt_res_dlt` is `Float`.
Any `Integer * Float` promotion (e.g. `garr_res_dlt[i]*0.01`) and any
`Float -> Integer` narrowing (`round`, `floor`, `ClampInt`) is a text-visible
type crossing whose *runtime* semantics (width, rounding mode) are NOT in
donor text — see §4 `[U]`.

### 1.2 Economy constants `[O]`

| Literal | `path:line` |
|---|---|
| `gc_economy_exp = 0.00002;` | `C:\Games\Cossacks 3\data\scripts\dmscript.global:810` |
| `gc_economy_time = 0.0001*gc_time_to_frames;` | `C:\Games\Cossacks 3\data\scripts\dmscript.global:811` (`gc_time_to_frames = 32` at `:175`, so text-evaluable to `0.0032`, but the product form is the `[O]` literal) |
| `gc_project_mode_none = 0;` / `editor = 1;` / `game = 2;` | `C:\Games\Cossacks 3\data\scripts\dmscript.global:1418/1419/1420` |
| `gc_MaxPlayerCount = 12;` | `C:\Games\Cossacks 3\data\scripts\dmscript.global:97` |

Consumers: `res.script:243-246` bind both `buyexp/sellexp := gc_economy_exp`
and both `buytime/selltime := gc_economy_time`; `res.script:254` gates on
`GetProjectModeInt=2` (= game, live in skirmish).

### 1.3 Cost-triplet init — every float literal `[O]`

`C:\Games\Cossacks 3\data\scripts\lib\res.script:184-248`
(`Select-String 'gEconomy.*:='` full hit list):

- `:184` `garr_res_dlt[i]:=0; garr_res_trg[i]:=0;` (inside `_res_InitEconomy`, `:178`)
- `:187-189` food buy `20 / 25 / 40` (min/def/max)
- `:190-192` commented-out food sell `5 / 15 / 20` (brace comment — dead, do not port)
- `:193` food sell def `18.24095;`, then `:195` overwritten by `18.24095*0.8333;`
- `:196-197` food sell min/max `sellcostdef*0.7` / `sellcostdef*1.3`
- `:200-202` wood buy `40 / 50 / 60`; `:203-205` wood sell `20 / 30 / 40`
- `:208-210` stone buy `40 / 50 / 60`; `:211` stone sell def `19.29725;` (comment `//14.0235`), then `:213` overwritten by `19.29725*1.08306;`
- `:214-215` stone sell min/max `sellcostdef*0.75` / `sellcostdef*1.25`
- `:218-220` gold buy `140 / 190 / 240`; `:221-223` gold sell `80 / 110 / 140`
- `:226-228` iron buy `80+20 / 100+40 / 120+60` (i.e. text literals `80+20` etc., NOT pre-added `100/140/180`)
- `:229-231` iron sell `40 / 60 / 80`
- `:235-237` coal buy `40 / 50 / 60`; `:238-240` coal sell `20 / 30 / 40`
- `:243` `buyexp := gc_economy_exp;` `:244` `buytime := gc_economy_time;`
- `:245` `sellexp := gc_economy_exp;` `:246` `selltime := gc_economy_time;`
- `:247-248` live `buycost := buycostdef; sellcost := sellcostdef;`

`[D]`: the sell-def overwrites (`:193→:195`, `:211→:213`) mean only the
second assignment is live; the first is dead text. The only non-trivial float
products in the whole table are `18.24095*0.8333`, `*0.7`, `*1.3`,
`19.29725*1.08306`, `*0.75`, `*1.25`. No other float literal exists in
`res.script` init (`Select-String '36|0.00002|0.025|0.01|0.7|1.3|0.75|1.25|0.8333|1.08306|18.24095|19.29725'`
returns exactly `:193,:195-197,:211,:213-215,:291`).

### 1.4 DLT transfer law — literals + consumers `[O]`

`C:\Games\Cossacks 3\data\scripts\lib\res.script:252-268`:

- `:252` `procedure _res_CalcDeltaResources(deltatime: Float);`
- `:254` `if GetProjectModeInt=2 then begin` — game-mode gate (`=2` per `dmscript.global:1420`)
- `:255` `gflt_res_dlt:=gflt_res_dlt+deltatime;`
- `:256` `if gflt_res_dlt>0{1} then begin` (donor comment shows relaxed threshold `>1` → `>0`)
- `:257` `gflt_res_dlt:=0;`
- `:258` `var i, j: integer;`
- `:260` `var r: integer=0;`
- `:261` `for j:=0 to gc_MaxPlayerCount-1 do r:=r+not gPlayer[j].res[i];` (sum over ALL slots, `not` = value-read)
- `:262` `garr_res_dlt[i]:=round(Lerp(garr_res_dlt[i], ClampInt(r-garr_res_trg[i], 1, 1000), deltatime));`
- `:263` `garr_res_trg[i]:=r;`
- `:264` commented-out log line (dead)

`C:\Games\Cossacks 3\data\scripts\lib\res.script:272-309` consumer
(`_res_ProcessEconomy`, called with `deltatime`):

- `:274` `_res_CalcDeltaResources(deltatime);`
- `:279-286` old linear `buytime/selltime` recovery block, brace-commented out (dead — do not port)
- `:287-290` aliases `bc/buycost, bcd/buycostdef, sc/sellcost, scd/sellcostdef` (all `Float`)
- `:291` `var dt: Float=deltatime*0.025*MaxFloat(1, garr_res_dlt[i]*0.01);`
- `:292-307` four pull-toward-def branches with `Clamp(bc, min, max)` / `Clamp(sc, min, max)` at `:294,:298,:302,:306`

Float-vs-int at `:262` / `:291` (statically recoverable as text, NOT as semantics):

- `:262`: `r - trg` is `Integer - Integer`; `ClampInt(...,1,1000)` takes/returns `Integer`; `Lerp(Integer, Integer, Float)` takes mixed types and returns engine `Float`; `round(Float)` narrows to `Integer` stored into `Integer` array element. The `Lerp` formula, `Float` width, and `round` half-way rule are NOT defined in donor text (engine-native) → `[U]` §4.
- `:291`: `garr_res_dlt[i]*0.01` is `Integer * Float-literal`; `MaxFloat(1, …)` is engine `Float` max; `deltatime*0.025*…` is `Float` chain into `Float dt`. `0.025` / `0.01` / `1` / `1000` bounds are the only literals; no rounding call here.

`garr_res_dlt` has exactly 4 live references in donor text (whole-`data\scripts`
`Select-String 'garr_res_dlt|gflt_res_dlt|garr_res_trg'` modulo denied directory-nodes): `:184` init, `:262-263` update, `:291` consume, plus dead `:264` log. No other reader/writer exists in swept text.

### 1.5 Market transfer / price computation — literals + consumers `[O]`

`C:\Games\Cossacks 3\data\scripts\lib\res.script:311-344`:

- `:311` comment `// _res_MarketCalculateBuyAmount`
- `:313` `function _res_MarketCalculateBuyAmount(const sellres, buyres, amount : Integer) : Integer;`
- `:315` `Result := floor(amount*gEconomy[sellres].sellcost/gEconomy[buyres].buycost);` — sole `floor` in file; `Integer * Float / Float` narrowed by `floor` to `Integer`
- `:318` comment `// _res_MarketTradeResources`
- `:320` `function _res_MarketTradeResources(const plHnd, sellres, buyres, amount : Integer) : Integer;`
- `:323` `var sellamount : Integer = amount;`
- `:324` `var plInd : Integer = GetPlayerIndexByHandle(plHnd);`
- `:325-326` clamp `if (sellamount>not gPlayer[plInd].res[sellres]) then sellamount := not gPlayer[plInd].res[sellres];`
- `:327` `var buyamount : Integer = _res_MarketCalculateBuyAmount(sellres, buyres, sellamount);`
- `:331-332` stock deltas `_res_AddResToPlayerByIndex(plInd, buyres, buyamount)` / `(plInd, sellres, -sellamount)`
- `:335-336` stats `stat.resbuy[buyres]+=buyamount`, `stat.ressell[sellres]+=sellamount`
- `:337` `var weight : Float = buyamount*gEconomy[buyres].buyexp;` (`Integer * Float`)
- `:338` `gEconomy[buyres].buycost := (gEconomy[buyres].buycost+gEconomy[buyres].buycostmax*weight)/(1+weight);`
- `:339` `gEconomy[buyres].sellcost := (gEconomy[buyres].sellcost+gEconomy[buyres].sellcostmax*weight)/(1+weight);`
- `:340` `weight := sellamount*gEconomy[buyres].sellexp;` — `buyres`, NOT `sellres` (quirk `[O]`)
- `:341` `gEconomy[sellres].sellcost := (gEconomy[sellres].sellcost+gEconomy[sellres].sellcostmin*weight)/(1+weight);`
- `:342` `gEconomy[sellres].buycost := (gEconomy[sellres].buycost+gEconomy[sellres].buycostmin*weight)/(1+weight);`
- `:343` `Result := buyamount;`

`[D]`: rational form `(c + bound*w)/(1+w)` is text-explicit at `:338-342`
(four assignments, two rows: buy-side toward max first, sell-side toward min
second). Division `(1+weight)` is `Float / Float`; no `round`/`trunc` call on
this path — the only narrowing is the upstream `floor` at `:315`.
`Select-String 'floor|round'` over `res.script` returns exactly `:262`
(`round`) and `:315` (`floor`); no `Trunc`/`frac`/`Exp` hit
(`Select-String 'Clamp\(|MaxFloat|MinFloat|Trunc|frac|Exp|Ln'` returns only
`:243,:245,:291,:337,:340` — `exp` hits are `buyexp/sellexp` identifiers, not
exponent calls).

AI large-`w` call sites `[O]` (why U6-T matters):
`C:\Games\Cossacks 3\data\scripts\units\global.inc\progresseconomicai.inc:3016-3211`
(`Select-String 'MarketTrade'`): amounts include `500 / 1000 / 1500 / 2500 /
3000 / 5000 / 10000 / 20000 / 25000 / 30000 / 35000 / 45000 / 50000 / 100000 /
150000 / 200000 / 220000 / 400000 / 600000` (e.g. `:3042` stone→gold `220000`,
`:3088` stone→gold `400000`, `:3202/:3204/:3207/:3209` iron/coal `600000`,
`:3211` stone→gold `400000`). With `exp=0.00002`, `w = amount*0.00002` spans
`0.01` to `12.0` — the regime where rational-vs-linear differ.

## 2. The "36-float table" — static-text finding `[O]`/`[D]`

There is NO 36-element float literal table in swept donor text.

- `Select-String '36'` over `res.script + dmscript.global` returns only
  unrelated constants (`dmscript.global:377,543,589,815-816,1223,1286,1542` —
  unit ids, `gc_MaxInt/MaxFloat`, char-filter list). Zero hits in `res.script`.
- The `gEconomy` table is `TEconomy[gc_ResCount]` with `gc_ResCount = 7`
  (`dmscript.global:3`), not 6, and holds per-resource triplet records — not a
  flat 36-float array.
- `Select-String 'gEconomy.*:='` (full list §1.3) shows only scalar triplet
  assignments; no array-literal constructor with 36 entries exists.

`[D]`: "36 floats" is the U6-T *capture log* count defined by
`DEC_U_market_tail.md §1` (12 costs × 3 trades), not a donor literal table.
It is therefore correct that this sweep finds no such table; the absence is
itself a byte-proven text fact. Any claim of a donor 36-float constant would
be invention — none is recorded here.

## 3. Rounding / truncation / float-vs-int — what is statically recoverable

| # | Text fact `[O]` | Consumer expression | Static type reading `[D]` | Semantically recoverable? |
|---|---|---|---|---|
| R1 | `floor(...)` at `res.script:315` | `floor(amount*sellcost/buycost)` → `Integer Result` | `Integer*Float/Float` → `floor` → `Integer`. Truncation-toward-`floor` (not toward-zero) is text-named, but engine `floor` on negatives / NaN / float width is undefined in text | NO — engine-defined `[U]` (U6-T edge) |
| R2 | `round(Lerp(...))` at `res.script:262` | `round(Lerp(Integer dlt, ClampInt(Integer,1,1000), Float dt))` → `Integer garr_res_dlt[i]` | Narrowing `Float→Integer` is explicit; `Lerp` formula, `Float` width (32/64), `round` half-way rule (bankers vs half-away) NOT in donor text | NO — engine-defined `[U]` (DLT core) |
| R3 | `ClampInt(r-trg,1,1000)` at `res.script:262` | bounds `1, 1000` Integer literals | Integer clamp is text-explicit; saturation behaviour at exactly `1/1000` is literal, engine edge cases none beyond that | Form YES `[D]`; engine-int width NO `[U]` (coupled to R2) |
| R4 | `MaxFloat(1, dlt*0.01)` at `res.script:291` | `Float dt = deltatime*0.025*MaxFloat(...)` | `Integer*0.01` promotes to `Float`; threshold `dlt<100 ⇔ factor 1.0` is exactly derivable (`dlt*0.01<1`) | Threshold form YES `[D]`; `MaxFloat` NaN/width NO `[U]` (DLT edge) |
| R5 | `(c+bound*w)/(1+w)` at `res.script:338-342` | `Float` costs, `Float weight` | No rounding call on this path; `Float` division ordering `(c+bound*w)/(1+w)` is text-explicit, including `:340` `buyres.sellexp` quirk | Operator order YES `[D]`; float-width/associativity NO `[U]` (U6-T edge) |
| R6 | `r: integer=0` accumulation at `res.script:260-261` | `r:=r+not gPlayer[j].res[i]` over `gc_MaxPlayerCount` slots | Integer summation, exact order `j=0..11` text-explicit | Order YES `[D]`; Integer overflow width NO (practically unreachable, still `[U]`-tagged, not asserted) |

No `Trunc`, `frac`, `Exp`, `Ln`, `MinFloat`, or second `floor`/`round`
exists in `res.script` (negative grep §1.5). No engine definition of
`Lerp`/`ClampInt`/`Clamp`/`MaxFloat`/`floor`/`round` exists in
`dmscript.global` (grep `Lerp|ClampInt|MaxFloat|Clamp|floor|round|Float|Integer`
returns only type declarations and unrelated constants) — they are
engine-native.

## 4. What stays `[U]` and why (no weakening)

| Id | Open piece | Why static text cannot settle it | Zero-mismatch capture termination (exact, carried) |
|---|---|---|---|
| U6-T | `floor` at `:315` + `Float` evaluation/clamp ordering at `:337-342` (buy-then-sell, `:340` quirk) under large `w` (AI 500–600000) and any float32/64 or half-way difference | Engine `floor` + `Float` width/associativity not in donor text; rational form is `[D]` but bit-result is not | **U6-T: 36 floats** — fixed seed, one market, 100000 of each res; `trade(food→gold,100)`, `trade(wood→gold,5000)`, `trade(stone→gold,100000)`; log all 12 costs after EACH trade (36 floats); oracle `w=amount*0.00002`, rational blend buy-then-sell with `:340` quirk, `buyamount=floor(...)`, per-triplet clamp; **zero mismatch** 36/36 vs oracle AND vs port `trade()` |
| DLT | `Lerp(a,b,t)` at `t=deltatime` + `round` + `ClampInt` at `:262`; `MaxFloat(1,dlt*0.01)` factor at `:291` | `Lerp` formula, `round` half-way rule, `Float` width engine-defined; factor crosses 1.0 exactly at `dlt=100`, up to ×10 at `dlt=1000` — live in skirmish (mode 2, `:254` + `dmscript.global:1420`) | **DLT: 600 ticks** — fixed seed, 2 AI players trading/mining, O1 interleave fixed; log per tick dlt vector + total stocks `r[i]` + all 12 costs for **600 ticks**; oracle init 0, `dlt[i]=round(Lerp(dlt,ClampInt(r-trg,1,1000),dt))`, `trg=r`, recovery `dt_sim=dt*0.025*max(1,dlt*0.01)` toward def, clamped; **zero mismatch** on dlt vector AND 12 costs across full window incl. one quiet window (factor exactly 1) and one active window (factor >1) |
| O1 | global `_res_ProcessEconomy` vs per-player slice interleave | order engine-driven; changes `r` input to DLT | fixed-seed hash test (coupled input to DLT, separate id) |

D4 price semantics stays `[U]` per `PORT1TO1_d4_reclass.md §1-4` and
`PORT1TO1_u_register2.md §3 N-5 / §5`: rational cost-push + live dlt ported
`[O-PORT]`, but U6-T/DLT float semantics can change transacted prices.
Blocking status is NOT weakened by this sweep.

## 5. Adjacent files: byte-proven negatives `[O]`

- `country.script`: `Select-String 'Market|gEconomy|buycost|sellcost|dlt|price|costpush'`
  returns ONLY upgrade `price[...]` assignments (`:604-614, :626-631, :765-770`)
  and market *building* names (`commonNameMarket`, `spamar`, `mar`, `:2837-2943, :3412, :3438, :3512, :3669-3829`).
  Zero `gEconomy` / cost-push / dlt hits — no price computation here.
- `player.script`: same-pattern grep returns ONLY `resonlife` stats writes
  (`:25, :292, :301`) and `marketdip` building-gating (`:2741-2763`,
  `nodip/nomarket/noboth/expensivemercs` enable/disable market & dip-center
  buildings). Zero `gEconomy` / `buycost` / `sellcost` / `dlt` hits — no price
  computation here.
- `donewgame.inc`: `Select-String 'market|economy|cost|price|dlt'` returns
  NOTHING (empty result). No price law.
- `startingsettings.cfg`: same grep returns exactly one comment line
  `:27 //gc_ai_unit_market = 12;`. No price law.

## 6. Claim register and verdict

| # | Claim | Label |
|---|---|---|
| 1 | DLT/price literals + consumers mapped: init `:184`; triplet floats `:187-248`; gate `:254`; accumulation `:260-261`; `round(Lerp(ClampInt(...)))` `:262`; `trg=r` `:263`; recovery aliases `:287-290`, factor `:291`, clamps `:294-306`; `floor` `:315`; trade head `:323-327,331-336`; rational push `:337-342` with `:340` quirk; types `TEconomy` `:1923-1936`, `gEconomy` `:2058`, dlt arrays `:2343-2345`; constants `:810-811,1418-1420` | `[O]` this sweep (hashes §0) |
| 2 | No 36-float donor literal table exists in swept text; "36 floats" = U6-T capture log count (12×3), not a donor constant | `[O]`/`[D]` §2 |
| 3 | Statically recoverable: operator order, type crossings, literal bounds, dead-vs-live lines (commented `:190-192,:279-286,:264`), overwrite order (`:193→195,:211→213`), `:340` quirk, Integer accumulation order | `[D]` §1/§3 |
| 4 | NOT recoverable statically: `Lerp` formula/width, `round`/`floor` half-way/negative semantics, `ClampInt`/`Clamp`/`MaxFloat` engine edge semantics, `Float` 32/64 width and division associativity | `[U]` §3 R1-R6, §4 |
| 5 | Adjacent files carry no price law (country upgrade-price/building names only; player `resonlife`+`marketdip` gating only; donewgame empty; startingsettings one comment) | `[O]` §5 |
| 6 | No donor executed/copied, no value wired, no approximation adopted, no parity claimed; exactly one repo file written | `[O]` scope guard |
| 7 | D4 stays `[U]`/blocking unless market prices + all trades + all active-dlt windows are explicitly out of scope; termination is U6-T 36-float + DLT 600-tick zero mismatch | `[D]` per `PORT1TO1_d4_reclass.md §4`, `PORT1TO1_u_register2.md §5` |

> Verdict: `port=UNVERIFIED`; `parity.claim = NONE`; `parity.status = "UNVERIFIED"`;
> `visual_parity_claim = false`; `blocking_unverified` non-empty (P0-1…P0-8
> plus domain tails incl. D4 U6-T/DLT/O1); six-condition chain 0/6 CLOSED.
> **RESULT IS NOT GOOD.** No same-camera donor/port A/B frame exists; no
> approximation is authorised; no parity claim is made.

*End of DEC_U_d4_floats. Read-only; exactly one repository file written;
no source/asset/config/test/runner/Godot/git/donor-execution; D4 remains
`[U]` and is NOT CLOSED; parity UNVERIFIED; `RESULT IS NOT GOOD` while
`blocking_unverified` is non-empty.*
