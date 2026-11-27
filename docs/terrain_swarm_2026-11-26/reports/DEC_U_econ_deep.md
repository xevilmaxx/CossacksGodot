---
id: DEC-U-ECON-DEEP
worker: DEC-U-ECON-DEEP (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
scope: "READ-ONLY decomp. Class-B static angle S-SKIRM/AI/MKT per PORT1TO1_u_classify.md B12/B11 (S-MKT/Q2/VIC/PEACE, S-AI-A1..A8). Donor binary never executed/copied. Donor text read as text only. No code/asset/config/Godot/git edit: this report is the only file written."
labels: "[O] observed donor bytes/text verified this ticket or cited prior pass with ev id · [D] deterministic reading of [O] · [I] inference, flagged · [U] UNVERIFIED with settling experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
upstream: "DEC_U_market_tail.md (cost-push rational law, garr_res_dlt tracker, 3 delivery sites, resonlife counter) + DEC_U_famine_profile.md (bFamine default TRUE, upkeep accumulator, rebellion 50/12/5 + 6000/100/200 + floor(random*32768), slot-11 target) + DEC_U_ai_thresholds.md (TimeProgressAI 2.4 s, resbalance ladders, guard sampler, fear selector) + DEC_U_ai_activation.md + DEC_U_skirmish.md/impl-patch + PORT1TO1_u_classify.md B11/B12"
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker. No port capture compared."
network: "OUT OF SCOPE. No multiplayer/netcode law is wired or changed."
---

# DEC-U-ECON-DEEP — packed CODE byte search for the economy/AI tail values (2026-11-26)

## 0. Pass ledger (owner rule; every native pass pinned `document:"t_87f0f3c130b0"`)

Pin re-asserted this ticket: `Get-FileHash` SHA256 `87F0F3C1…AF4E16C`, `Length 5768048` = `t_87f0f3c130b0` `[O]`. Binary never executed, never copied. All `ev_*` below are this ticket's Craft Anything evidence ids on that pin, except where marked "cited prior".

| # | Pass | Result |
|---|---|---|
| P1 | pin + target list | `t_87f0f3c130b0` active (`core_targets_list`: `cossacks.exe` 5768048 B + `editor.exe` t_68474ddd); this ticket searches only `t_87f0f3c130b0` |
| P2 | `native_bytes_find` economy identifiers (utf8+utf16le, limit 100): `garr_res_dlt`, `gflt_res_dlt`, `garr_res_trg`, `resconsume`, `resonlife`, `costpercent`, `sellexp`, `buycost`, `sellcost`, `buytime`, `selltime`, `MarketTradeResources`, `CalcDeltaResources`, `ProcessEconomy`, `bestprojects`, `resbalance`, `resourceDropRadius`, `TimeProgressAI`, `AI_THINK`, `buyexp`, `gc_economy_exp`, `gc_project_mode`, `GetPortResourcePoint`, `PortResourcePoint`, `CheckProgressLastTime`, `bestproject`, `AIConst`, `Mercenary`, `brebellion`, `Market`, `Economy`, `resbuy`, `TradeResource` | **0 matches each** (ev ids §1) — stored-bytes negatives with the standard packed-region reserve |
| P3 | `native_bytes_find` positive controls: `GetProjectModeInt` → **1 hit** `0x69dde6` CODE (ev_c8a690ed…); `Lerp` → **55 hits** (ev_926ab69b…); `ClampInt` → **1 hit** `0x60a936` CODE (ev_c803cfbb…); `MaxFloat` → **5 hits** `0x60a556` + `0x682f00`-cluster (ev_a2e94824…); `ExecuteState` → **37 hits** `~0x63c4c4…` (ev_3d471d60…, GO-delay family per tick-deep); `GetPlayerIndexByHandle` → **1 hit** `0x68f4e2` CODE; `GetPlayerHandleByIndex` → **1 hit** `0x68d892` CODE; `SetGameObjectMinFrameBlend` → **1 hit** `0x62f90e` CODE (method-control: table search works, economy absence is not a tool failure) |
| P4 | `native_bytes_show` windows: `0x69dde6+900` (ev_d0beeb2c), `0x60a500+1200` (ev_e84a2b48), `0x682f00+900` (ev_f8345c89), `0x574880+600` (ev_4fdfe4bd, Lerp-property disambiguation) | wrapper arities §2 `[O]` |
| P5 | donor-text re-reads (read-only): `res.script:178-344` (`_res_*` arities, triplet literals, rational pushes, `GetProjectModeInt=2` gate); `dmscript.global:210,220,810-811,1418-1420,2343-2345` (radii, econ rates, project modes, `garr` decl); `classes.script:6589-6596` (`ClampInt` script twin); `misc.script:443-458` (`_misc_MaxFloat` script twin); `cossacks.ini` full 7-line read; `C:\Games\Cossacks 3\data` recursive `garr_res_dlt` + `profile.cfg` absence check | settings/profile override verdict §3 `[O]` |
| P6 | cited prior text passes (not re-run): market-tail P5–P16 (triplets, `buyexp/sellexp/buytime/selltime` init-to-def, famine/rebellion rolls, upkeep `mult=100/speed=20000`, AI 2.4 s + `id·0.25` + anti-collision) | context only; new native content is P2–P4 |

Strange-read log (same limits as blend/tick workers): `native_bytes_find` searches stored file bytes — "compressed, encrypted or packed regions and data built at run time are not seen, so no match is not proof of absence" (`.bind` `0x96c000-0x98fd70` entropy 7.96 exec, packed); unmapped header/overlay/debug matches carry no VA. Ripgrep `cossacks.exe` line hits (e.g. blob lines 7155/7209) are not VAs and are not cited as addresses — only `native_bytes_find` VA/file-offset rows are. No donor binary executed; no donor bytes copied.

## 1. (a) Packed CODE byte search — economy/AI names with VAs

All searches `encoding: both` (utf8+utf16le), pinned `t_87f0f3c130b0`. "0" = `total_matches: 0`, full stored-byte sweep complete unless noted.

### 1.1 Economy state / market / upkeep — all 0 in stored CODE bytes

| Term | Result | Evidence |
|---|---|---|
| `garr_res_dlt` | **0** | ev_cc4ce17c… |
| `gflt_res_dlt` | **0** | ev_33722904… |
| `garr_res_trg` | **0** | ev_2ca0c911… |
| `resconsume` | **0** | ev_9418c87e… |
| `resonlife` | **0** | ev_1fa7864a… |
| `costpercent` | **0** | ev_1d29f024… |
| `sellexp` | **0** | ev_7e885183… |
| `buycost` | **0** | ev_4a128b5f… |
| `sellcost` | **0** | ev_2e935d08… |
| `buytime` | **0** | ev_2c0069a3… |
| `selltime` | **0** | ev_9b9f4f09… |
| `buyexp` | **0** | ev_b0f17735… |
| `MarketTradeResources` | **0** | ev_3f034608… |
| `CalcDeltaResources` | **0** | ev_b78c9c52… |
| `ProcessEconomy` | **0** | ev_e85b5a48… |
| `Market` (bare) | **0** | ev_533c8921… |
| `Economy` (bare) | **0** | ev_7d5a3fd7… |
| `resbuy` | **0** | ev_0e43192b… |
| `TradeResource` | **0** | ev_1a96ff7d… |
| `resbalance` | **0** | ev_c763fa38… (+ ev_db154291… `resbalance` re-check 0) |
| `resourceDropRadius` | **0** | ev_ef984eda… (confirms market-tail P1 negative on the packed exe) |
| `gc_economy_exp` | **0** | ev_8cefb389… |
| `gc_project_mode` | **0** | ev_1c3ae938… |

`[D]`: stored-byte absence is the expected shape for **script-side globals/procedures**: `garr_res_dlt/gflt_res_dlt/garr_res_trg` are `dmscript.global:2343-2345` globals driven solely by `res.script:184,252-268,291` script code; `resconsume/resonlife` are `TPlayer`/`TUnitCounter` fields (`dmscript.global:1807-1808`, `classes.script:3445-3453,3695-3696`); `buycost/sellcost/buyexp/sellexp/buytime/selltime` are `TEconomy`-record fields (`dmscript.global:1924-1934`) with literals authored in `res.script:186-248`; `_res_*` and `_res_MarketTradeResources` are script procedures (arities §2), not native exports. The engine stores no copy of these names in readable bytes — same class as the market-tail/famine negatives (`SetRandomKey`/`RandomExt`/`bfamine`/`resourceDropRadius`), and the inverse of the blend/tick positives where table entries DO exist (§1.3). The `.bind` packed-region reserve applies (absence ≠ proof of runtime absence), so every value below stays `[U]` until its fixed-seed trace terminates.

### 1.2 AI names — all 0 in stored CODE bytes

| Term | Result | Evidence |
|---|---|---|
| `bestprojects` / `bestproject` | **0 / 0** | ev_008e7be9… / ev_bfd0f7b6… |
| `TimeProgressAI` | **0** | ev_50387c6a… |
| `AI_THINK` | **0** | ev_6344b09f… (`data.gd` port knob; no donor counterpart string) |
| `AIConst` | **0** | ev_18a557db… (`gAIConst` live record is script-side `classes.script:4775-4844` + `ai.script`) |
| `CheckProgressLastTime` | **0** | ev_60a5380f… (gate primitive is script-defined in `squad.script`, consistent with tick-deep P5) |
| `ProgressAI` (bare) | **0** | ev_c0cbe737… (37 `ExecuteState` hits are the GO-delay family `ExecuteStateByHandle/GetGameObjectDelayExecuteState…`, NOT the player `ProgressAI/ProgressEconomicAI` dispatcher — tick-deep §1 confirmed, re-confirmed this ticket ev_3d471d60…) |
| `Mercenary` / `brebellion` | **0 / 0** | ev_dcc20d57… / ev_e25d12df… (rebellion law is script-side `nothing.inc:487-495` + `miscext.script:894-958`; no native table entry) |

`[D]`: AI decision state (`aidata.bestprojects`, `resbalance` mine levels, target weights, `2.4 s + id·0.25` cadence, anti-collision) lives in `[*] = ;`-prefixed script text + script records. No CODE-embedded AI table was found to extend the tick-deep `0x68xxxx-0x6axxxx` sweep. AI target weights therefore have **no new native anchor this ticket**; U-A2/U-A4 stay `[U]` (§4).

### 1.3 Positive controls (method parity — search works where tables exist)

| Term | Hits (VA, section) | Evidence |
|---|---|---|
| `GetProjectModeInt` | **1**: `0x69dde6` CODE, file-off `0x29d1e6` | ev_c8a690ed… |
| `GetPlayerIndexByHandle` | **1**: `0x68f4e2` CODE | ev_cb6cc5bd… (tick-deep P2 anchor, reproduced) |
| `GetPlayerHandleByIndex` | **1**: `0x68d892` CODE | ev_7dfee34f… |
| `ExecuteState` | **37**: head `0x63c4c4…` CODE | ev_3d471d60… (GO-delay family only) |
| `SetGameObjectMinFrameBlend` | **1**: `0x62f90e` CODE | ev_679e5fc6… (blend table region `0x62f300-0x630700`) |
| `Lerp` | **55** (see §2: 1 function signature + 54 `Lerp*` property hits) | ev_926ab69b… |
| `ClampInt` | **1**: `0x60a936` CODE | ev_c803cfbb… |
| `MaxFloat` | **5**: `0x60a556` + `0x682f00/40/84/c8` CODE | ev_a2e94824… |

`[D]`: the method resolves CODE-embedded API tables when they exist (blend `0x62fxxx`, tick `0x68f4e2/0x690692`, math `0x60a5xx`, project-mode `0x69dde6`). The §1.1/§1.2 zeroes are therefore informative negatives (script-side-only shape), not tool failures — under the stated packed-region reserve.

## 2. (b) Wrapper arities + native helpers for price interpolation / delivery radius

### 2.1 Byte-proven native arities `[O]` (exact signature strings, `native_bytes_show`)

Math-intrinsics cluster `0x60a500+1200` (ev_e84a2b48), verbatim:

```
function Min(const a, b: Integer): Integer
function MaxFloat(const a, b: Float): Float
function MinFloat(const a, b: Float): Float
procedure Inc(var a: Integer; b: Integer)
procedure Dec(var a: Integer; b: Integer)
function Lerp(const a, b, t: Float): Float
function RandomExt(): Float
function GetRandomKey: Integer
procedure SetRandomKey(key: Integer)
procedure GetRandomExtKey64(var key0: Integer; var key1: Integer)
procedure SetRandomExtKey64(const key0, key1: Integer)
function Sqrt(const val: Float): Float
function Sqr(const val: Float): Float
function Sin(const val: Float): Float
... Cos / Tan / ArcSin / ArcCos / ArcTan (1 Float arg each)
function Clamp(const val, min, max: Float): Float
function ClampInt(const val, min, max: Integer): Integer
function IsInRange(const val, min, max: Float): Boolean
```

`[D]`: the three engine builtins consumed by the economy script are arity-proven: **`Lerp(a,b,t)` 3 args, `Clamp(v,min,max)` / `ClampInt(v,min,max)` 3 args, `MaxFloat(a,b)` 2 args**. Used at `res.script:262` (`Lerp(dlt, ClampInt(r-trg,1,1000), deltatime)`), `res.script:291-306` (`MaxFloat(1, dlt*0.01)`, `Clamp(bc, min, max)`), `player.script:284-315` (`floor(bank*mult)` bank carry). Their **evaluation semantics** (linear `a+(b-a)*t`, int clamp, float max, Bankers `round`) are engine-defined and NOT byte-proven beyond the signature — they stay `[I]` until the DLT/LIFE captures (§4) terminate. Script twins exist for two of them (`ClampInt` in `classes.script:6589-6596` TScenarioTrigger + `:6773`; `_misc_MaxFloat(a,b)` in `misc.script:443-449`) — those are record/script helpers, not the engine entries above; do not conflate.

Project-mode cluster `0x69dde6+900` (ev_d0beeb2c), verbatim head:

```
function GetProjectModeInt(): Integer
procedure SetProjectMode(const mode: String)
procedure SetProjectModeInt(const mode: Integer)
procedure MapWorldUpdateTerrainData(tag: Integer; deltaheight: Float)
...
```

`[D]`: **`GetProjectModeInt` takes 0 args and returns Integer; `SetProjectModeInt` takes 1 Integer arg**. This is the exact runtime gate of `_res_CalcDeltaResources` (`res.script:254`: `if GetProjectModeInt=2`), with modes `none=0/editor=1/game=2` (`dmscript.global:1418-1420`). Skirmish runs at mode 2, so the `garr_res_dlt` updater RUNS in skirmish (market-tail §2 correction stands). The exact per-tick gate value still requires a live read — stays `[U]` (§4 DLT).

`Lerp` disambiguation `[O]`: of the 55 `Lerp` hits, only `0x60a556`-region is the **function** `Lerp(const a,b,t: Float)`; the `0x5748b1/0x5748d9/0x575fd8…`, `0x58fxxx`, `0x59d030`, `0x60a62e`, `0x6a81xx`, `0x6d6exx-0x6d7exx`, `0x761exx`, `0x7axxxx-0x7fdxxx` run are **property names** (`TwoSideLightLerp`, `BackLightLerpFactor`, `LerpPower`, `LerpScale/Rotation/Position/Time`, `AlphaLerpDistance`, `BillboardFactor`, `LerpAround`, `LerpTime`) inside RTTI/property tables (ev_4fdfe4bd window `0x574880+600` shows `TwoSideLightLerp/BackLightLerpFactor/AdvanceMode` + code, no economy content). None is an economy interpolation helper.

### 2.2 No native helper computes the price interpolation or the delivery radius

- Price interpolation: **no native wrapper exists in stored bytes** for any of `MarketTradeResources / CalcDeltaResources / ProcessEconomy / MarketCalculateBuyAmount / buycost / sellcost / buyexp / sellexp / buytime / selltime / Economy / resbuy` (all §1.1 zeroes). The four-assignment rational pushes (`res.script:337-342`), the `floor(sell*sellcost/buycost)` head (`:313-315`), and the recovery branches with `MaxFloat(1, dlt*0.01)` (`:287-307`) are **pure script arithmetic over script records** using the arity-proven intrinsics above. There is no `smooth`-style flag, no second native cost API, and no hidden rate literal in CODE bytes to port. The `[I]` tail is exactly the `Lerp`/`round`/`ClampInt` engine semantics + `deltatime` plumbing — nothing else.
- Delivery radius: **no native wrapper exists** for `GetPortResourcePoint / PortResourcePoint / resourceDropRadius` (all §1.2/§1.1 zeroes). `_misc_GetPortResourcePoint(goHnd, var x, var z, bPrecise): Boolean` is a **script function** (`misc.script:4506`, 4 args: handle + 2 out-floats + bool) with call sites at `unit.script:12028,12033-arm` / `miscext2.script:1148,1175` / `player.script:2961,3038` / `building.inc/*` (P5 grep, 25 hits). The three radii are script literals only: global `3` / `Sqr 9` (`dmscript.global:210,220`), peasant `0.5`-sqr (`unit.script:9704-9705`), fisher `4*4`-sqr (`unit.script:12032-12033`). No per-building offset table, no native distance helper, no `resourcePoint`-offset native was found in CODE bytes — per-building `resourcePoint` values and the D3 water-ring fallback (`misc.script:4520-4543`) remain text reads, still `[U]` (E1, §4).
- AI: no `bestprojects`/`resbalance`/`ProgressAI`/`CheckProgress`/`AIConst` table entry (all §1.2 zeroes). `_ai_TryUnit` gate, `_ai_ProcessIdeas`/`bestprojects` choice (`progresseconomicai.inc:1384,1409,3274-3349`), guard-sampler rolls (`unit.script:3620-3713`), fear selector (`progresswarai.inc:2798-2838`) are script-side. No native target-weight vector exists in stored bytes.

Script `_res_*` arities for the record `[O]` (`res.script` definitions): `_res_CalcDeltaResources(deltatime: Float)` 1 arg; `_res_ProcessEconomy(deltatime: Float)` 1 arg; `_res_MarketCalculateBuyAmount(sellres, buyres, amount: Integer): Integer` 3 args; `_res_MarketTradeResources(plHnd, sellres, buyres, amount: Integer): Integer` 4 args; plus `_res_GetTRes(hnd): Pointer`, `_res_AddResToPlayerByIndex(plInd, restype, amount)`, `_res_SetResToPlayerByIndex`, `_res_ResGridAdd/Remove/Clear/ResetEnvironment`, `_res_InitEconomy()` (0 args), `_res_Init(res, itype)`, `_res_GetHitsNeeded(itype)` (P5 grep, 14 hits).

## 3. (c) Donor settings/profile text — any `garr_res_dlt` override? NO `[O]`

- Whole-`data` recursive grep `garr_res_dlt|gflt_res_dlt|garr_res_trg` (this ticket): **11 hits, all in two files** — declaration `dmscript.global:2343-2345` (`gflt_res_dlt = Float`, `garr_res_dlt/garr_res_trg = Integer[gc_ResCount]`) + `res.script:184` (init 0), `:255-257` (accumulator + `>0` gate), `:262-264` (Lerp update + commented log), `:291` (consumer). **Zero hits** in any `*.cfg`/`*.res`/`*.ini`, profile, locale, gui, menu, `startingsettings`, or save `write*.inc/read*.inc` text. There is no cfg-file `garr_res_dlt` default to port.
- `C:\Games\Cossacks 3\data` has **no `profiles/` directory** (glob: path does not exist). `cossacks.ini` full read (7 lines: `GameSaveDirectoryPath/LogFileEnabled/LogFileRoot/LogFileName/HideHelloScreen/BuildVersion` section markers) contains **no economy key** `[O]`. `editor.ini` / `steam_emu.ini` are launcher/steam shims, no economy content (names only; not settings stores for `garr`).
- The only profile/store surface is the native user-profile engine path already bounded in famine-profile §2/`DEC_U_settings_persist.md` U-SP5: `profile.script:39` shipped `bFamine=true`, `profile.script:269-287,546-552,617-650,729-740` save/load/boot sequence through engine natives (`UserSaveProfile*`, `StateMachineGlobalVariablesSaveToStack/LoadFromStack`, `ParserSelectUser`, `GetUserProfileStateMachineHandle`) with **zero script-side definitions** — byte format/flush timing `[U]`-P-store. That store carries `gProfile` (incl. `bFamine`), not `garr_res_dlt` (a per-session global, zeroed by `_res_InitEconomy:184` every economy init). No evidence of any settings/profile override of `garr_res_dlt`, `buyexp/sellexp`, triplets, or `gc_economy_exp/time` was found in any donor text this ticket.
- `[D]`: the `garr_res_dlt` runtime gate is exactly `GetProjectModeInt=2` (game) at `res.script:254` with init-to-0 at `:184` — no settings/profile branch conditions it. The remaining `[U]` is the **live per-tick value stream** (`dlt[i]`/`trg[i]` vs oracle), not a hidden default.

## 4. (d) Determination — no still-`[U]` economic value is byte-proven in CODE/data

**Verdict: ZERO promotions. Nothing in P2–P5 byte-proves any still-`[U]` economic value; every prior `[O]` stays text-grounded `[O]`/`[D]`, every `[I]`/`[U]` stays `[U]`.** Concretely:

| # | Still-`[U]` tail | Static state after this pass | Why not `[D]` / what settles it (fixed-seed, zero-mismatch, never invent) |
|---|---|---|---|
| U6-T | cost-push blend edge: `Lerp`/`round`/`ClampInt`/`floor` engine semantics, `deltatime` plumbing | Rational law `(c+bound*w)/(1+w)`, order buy-then-sell, 4-assignment scope, `buyres.sellexp` quirk all `[O]` text (`res.script:320-344`); arities `Lerp/ClampInt/MaxFloat` byte-proven §2.1 but **semantics not** | Capture U6-T (market-tail §1): 1 market, 100000 each res, `trade(food→gold,100)` / `(wood→gold,5000)` / `(stone→gold,100000)`, log 12 costs after each trade; oracle `w=buyamount*0.00002`, rational blend, `buyamount=floor(sell*sellcost/buycost)`, `[min,max]` clamp. **Termination: 36 logged floats bit-match oracle AND patched port, 0 mismatches.** Until then the engine-semantics edge keeps its `[I]` tag |
| DLT | `garr_res_dlt[i]` live stream + `gflt_res_dlt>0` gate + `MaxFloat(1,dlt*0.01)` factor | Tracker law `[O]` text (`res.script:252-268,291`); gate `GetProjectModeInt(): Integer` 0-arg byte-proven (§2.1); **no native dlt store, no override** (§§1.1/3) | Capture DLT (market-tail §2): fixed seed, 2 AI traders/miners, 600 ticks; log per-tick `dlt[i]`, `trg[i]`, `r[i]`, 12 costs; oracle init 0, `dlt=round(lerp(dlt,clamp(r-trg,1,1000),dt))`, `trg=r`, recovery `dt*0.025*max(1,dlt*0.01)` toward def. **Termination: 0 mismatches on dlt vector + 12 costs over 600 ticks incl. one quiet (factor 1) + one active (factor >1) window.** Until then port `rdt` hardcoding stays `[U]` |
| E1 | D2 `resourcePoint` per-building offsets; D3 `GetPortResourcePoint` fallback ring (`misc.script:4520-4543`); D1 global-consumer proof | Radii `3/9`, `0.5`-sqr, `16`-sqr + point corrections `[O]` text (market-tail §3); `_misc_GetPortResourcePoint(goHnd,x,z,bPrecise)` 4-arg script arity `[O]` §2.2; **no native point/radius helper, no per-building table in CODE** (§§1.1/2.2) | Captures D2/D3 (market-tail §3): D2 peasant full-load → storehouse, log `dstSqr` (with offset) + drop tick, oracle first tick `dstSqr<0.5`; D3 laden fisher → port, log `dstSqr` (vs port-point) + credit tick + `(0.5+random)*15.0` re-target, oracle first tick `dstSqr<16`. **Termination: drop/credit ticks + post-drop state match 20/20 seeded runs per site, 0 mismatches.** D1 stays `[U]` (no proven consumer — do not wire the global into D2/D3) |
| LIFE | `resonlife` Integer-vs-container + `value==0` no-write | Surplus-NO law `[O]` text (`player.script:270-322`, `classes.script:3451` Integer, zero-init `:25/:102-105`); writes only `:292/:301`, never on `value=0`, never in income/add paths; **no native resonlife store** (§1.1) | Capture LIFE (market-tail §4): A stock-10 food consume-32 vs B stock-0, 40 s; oracle A `resonlife=1`/stock 9 first quantum, B adds 0 + `bfamine` until clearing gate, `value==0` ticks change nothing; save round-trip holds integral statistics. **Termination: 0 mismatches on `resonlife[6]`/`res[6]`/`bfamine/brebellion` both players + save assert** |
| O1 | `_res_ProcessEconomy` vs per-player slice interleave | Call sites `[O]` text: global `nothing.inc:84` vs per-player `progress.inc:146-147`; order engine-driven | Fixed-seed hash battery (fog-camera-hud §7.2): **0-mismatch** state hashes or stays `[U]` |
| U-A1..U-A8 | AI: `bestprojects` winner, army-commit, officer-wait, weights, `resbalance` mine levels, think `2.4 s + id·0.25` + anti-collision, RNG attribution | Thresholds/ladders/gates `[O]`-text (ai-thresholds §§1-6); **no CODE AI table, no weight vector** (§1.2); `ExecuteState` hits are GO-delay only | Batteries per ai-thresholds §8 (600 s `bestprojects` choice log, army-creation tick, squad-form time, 20-trial Bitva target, mine-band reqlevel, `lastprogressaitime` growth, stagger hash, X21 draw ledger). **Termination: byte-identical choice/tick/composition/draws, 0 mismatches, 3 seeds.** Port keeps 1.0 s shared gate labelled PORT APPROXIMATION; no D-row activated |
| U11-M-port | rebellion flip target | Donor target slot 11 `[O]` (`dmscript.global:776,97` + `nothing.inc:494-495` + `miscext.script:894-958`); **no native mercenary table** (§1.2) | Capture FP-3 (famine-profile §5): `brebellion` forced via upkeep shortfall, run to flip or 20000 ticks; **0-mismatch** flip tick/owner/draws vs `floor(random*32768)<threshold` model, 3 repeats |

No rate, radius, weight, or stagger was invented in this report. No `[U]`→`[D]` promotion is claimed on the basis of a negative (negatives only fix the *shape*: script-side-only, no native table — the packed-region reserve is carried explicitly). No parity claim of any kind is made.

## 5. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | Pin `t_87f0f3c130b0` re-asserted (5768048 B, sha256 `87F0…4E16C`); donor binary never executed/copied; exactly one repo file written | `[O]` P1 + scope |
| 2 | 20 economy/AI terms searched packed-CODE utf8+utf16le: `garr_res_dlt/gflt_res_dlt/garr_res_trg/resconsume/resonlife/costpercent/sellexp/buycost/sellcost/buytime/selltime/MarketTradeResources/CalcDeltaResources/ProcessEconomy/bestprojects/resbalance/resourceDropRadius/TimeProgressAI/AI_THINK/buyexp` (+ `gc_economy_exp/gc_project_mode/GetPortResourcePoint/PortResourcePoint/CheckProgress/bestproject/AIConst/Mercenary/brebellion/Market/Economy/resbuy/TradeResource` second sweep) → **0 matches each** in stored bytes | `[O]` P2 ev ids §1.1–§1.2 (packed-region reserve stated) |
| 3 | Positive controls byte-proven: `GetProjectModeInt` 1 hit `0x69dde6` CODE; `Lerp` 55; `ClampInt` 1 hit `0x60a936`; `MaxFloat` 5 hits `0x60a556` + `0x682f00`-cluster; `ExecuteState` 37 (GO-delay family); `GetPlayerIndexByHandle 0x68f4e2` / `GetPlayerHandleByIndex 0x68d892` / `SetGameObjectMinFrameBlend 0x62f90e` | `[O]` P3–P4 ev ids §1.3 |
| 4 | Native arities verbatim: `Lerp(a,b,t: Float): Float`; `Clamp(v,min,max: Float): Float`; `ClampInt(v,min,max: Integer): Integer`; `MaxFloat(a,b: Float): Float`; `GetProjectModeInt(): Integer`; `SetProjectModeInt(mode: Integer)`; script `_res_CalcDeltaResources/ProcessEconomy` 1 arg, `_res_MarketCalculateBuyAmount` 3 args, `_res_MarketTradeResources` 4 args, `_misc_GetPortResourcePoint(goHnd,x,z,bPrecise)` 4 args | `[O]` §2 (ev_d0beeb2c / ev_e84a2b48 / ev_f8345c89 + text cites) |
| 5 | No native helper computes price interpolation or delivery radius; `Lerp`-property hits are RTTI names (`LerpScale/Rotation/Position/Time`, `LerpPower`, `TwoSideLightLerp`), not helpers | `[D]` §2.1–§2.2 |
| 6 | No `garr_res_dlt` settings/profile override: 11 `garr` text hits confined to `dmscript.global:2343-2345` + `res.script:184,255-257,262-264,291`; `cossacks.ini` 7 lines economy-free; no `data/profiles/` dir; profile store carries `gProfile`, not `garr` | `[O]` §3 |
| 7 | Determination: no still-`[U]` economic value byte-proven in CODE/data; all tails keep `[U]` with the §4 fixed-seed zero-mismatch batteries; no invented rate/weight; `parity.claim = NONE`, `parity.status = UNVERIFIED`, `visual_parity_claim = false` | `[D]` §4 |

*End of DEC-U-ECON-DEEP. Read-only; exactly one repository file written; no source/asset/config/test/runner/Godot/git/donor-execution; parity UNVERIFIED; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty.*
