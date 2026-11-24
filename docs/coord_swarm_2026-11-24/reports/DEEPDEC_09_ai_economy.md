---
id: DEEPDEC-09
scope: Donor AI / economy / training / building / capture rules — audit only; focused on the open AI force/wave failure
date: 2026-11-24
status: REPORTED (audit only; no source/config/test/git edits; no target open/select; no runtime instrumentation)
target: t_87f0f3c130b0 (shared, cossacks.exe, sha256 87f0f3c1...)
charter: docs/coord_swarm_2026-11-24/DEEPDEC_CHARTER.md
inputs_read: DEEPDEC_CHARTER.md, GAPS.md, reports/W51_ai_force_wave.md
---

# DEEPDEC-09 — donor AI/economy/training/building/capture truth vs the port's wave stall

## 0. Method and honesty notes

Tools used (all read-only): Craft Anything `enable_toolset(native)`, `core_overview_show`,
`native_bytes_find` (whole-file, UTF-8+UTF-16LE), `core_feature_find`, `native_strings_find`,
`native_function_find`, `native_function_study(detail:"summary")`, `native_bytes_show`;
Python `open(...,'rb').decode('latin-1')` for donor text (helper scripts written to
`%TEMP%\opencode\dg.py` / `dr.py`, **outside** the repo), and the repo `read`/`grep` tools for port code.

- Donor binary was **never executed, unpacked or instrumented**. No `core_target_open`,
  no `core_target_select`, no consent-gated tool.
- Donor `.inc` files store script source as comment lines prefixed `[*] = ;`; all `path:line`
  citations below are physical file lines in those files.
- **Evidence ids** are Craft Anything `ev_…` values; donor text citations are exact `path:line`.
- W51's measured facts (job 1316: force max 84, `wave=0`, gold bottoms at 2, `mine_gold`
  never built, effective threshold 120) are treated as INPUT, not re-proved here.

Path abbreviations used below (full paths stated once):
- `PE` = `C:\Games\Cossacks 3\data\scripts\units\global.inc\progresseconomicai.inc`
- `PW` = `C:\Games\Cossacks 3\data\scripts\units\global.inc\progresswarai.inc`
- `US` = `C:\Games\Cossacks 3\data\scripts\lib\unit.script`
- `MS` = `C:\Games\Cossacks 3\data\scripts\lib\misc.script`
- `MX` = `C:\Games\Cossacks 3\data\scripts\lib\miscext.script`
- `PS` = `C:\Games\Cossacks 3\data\scripts\lib\player.script`
- `AI` = `C:\Games\Cossacks 3\data\scripts\lib\ai.script`
- `CL` = `C:\Games\Cossacks 3\data\scripts\lib\classes.script`
- `DG` = `C:\Games\Cossacks 3\data\scripts\dmscript.global`
- `BI` = `C:\Games\Cossacks 3\data\scripts\units\building.inc\nothing.inc`
- `UI` = `C:\Games\Cossacks 3\data\scripts\units\unit.inc\nothing.inc`

---

## 1. EXE findings (Craft Anything) — the AI is NOT native code

| Evidence id | Operation / address | Finding (OBSERVATION) |
|---|---|---|
| `ev_60b497434aa3e6cb68b019fd0a3b016ec0415ef6ec1a3189726faa8d3752f4c4` | `core_overview_show` | PE32 x86, image base `0x400000`, 18 918 functions, 12 073 strings, **stripped**, `.bind` section entropy 7.96. Discovery stopped at 6 000 000 instructions; 1 238 indirect jumps unresolved. Static analysis only; absence is not proof. |
| `ev_756967e4b4793f6850fca26159b179c32f613f900a66e8830dae27b04b0185f2` | `native_strings_find("aix")` | 15 strings in `.rsrc`: `TAIXARGSEDITOR`, `frmAIXEditor`, `frmAIXVarsEditor`, `%AIX (*.aix)`, `AIX Arguments Editor`, … → donor AI is an **external AIX script system** with an in-EXE editor, not a set of named native AI functions. |
| `ev_2d3935520922f7afda562b0491450f361810c01b2e7a2c05c894ac5e5b2966fe` | `core_feature_find("AI")` | 76 strings, 7 function names — **all** Win32 thunks (`RaiseException`, `WaitMessage`, `BeginPaint`, …), no AI gameplay function. |
| `ev_a6eefa8c1d37caf73be56ee5341923081721b526b7e4ba9dc4c57191942c83c9` | `native_bytes_show(0x6447a0, 160)` | ASCII script-VM binding text: `procedure GameObjectPFXMaxExpInitSpeedByHandle(gohandle: Integer; const managername: String; const key: String; const minexpinitspeed: Float)`. The "mine" hits are the parameter `minexpinitspeed`, **not** a gold-mine symbol. |
| `ev_0ecde62ac5aaf9678130aa88340b3ad65accffc63b7b7745183e6ee3ec8adc38` | `native_function_find(0x6447de)` | Address belongs to `sub_6362a4` (+0xe53a). |
| `ev_79aafcd4cf943ede0c93108d2afe6f724df98f60bb2d950f21bf6304cd668cf2` | `native_function_study(sub_6362a4, summary)` | 13 120 blocks / 29 438 instructions / 173 callees / **0 callers** / **0 referenced strings**; above the structuring limit, 7 056 gotos, 11 480 asm-only instructions. **No AI semantics can be derived from this function.** |
| `ev_5dfa6a3239116a986ba8ab90f3ffb8a069f0be2a22124c129fba2fd1eb78d143` | `native_bytes_find("train")` | 51 whole-file matches, e.g. `0x4412aa`, `0x441882`, `0x44223c` (all CODE). |
| `ev_3475f161c9efdbdd5969d71f3326e73627b1f94a27e78f6beb037dbd62734649` | `native_bytes_find("build")` | 15 matches, e.g. `0x47fb32`, `0x645679`, `0x65a220`. |
| `ev_b6da68350aaf7f9580d19201730779b793bdc1938cbfdf56ae915d703bbbbf74` | `native_bytes_find("wave")` | 55 matches; `core_feature_find` (`ev_ea5039af036ca079c7843a7d64decd920aae8194b5cc692782ce373b8c5396b1`) resolves them to `waveOutOpen/PrepareHeader/Write` **audio** thunks, not game waves. |
| `ev_9ef3694d498bc634594af0520b9e233db73513058e12cb3e154cd61eb12d3f51` | `native_bytes_find("resource")` | 28 matches; `core_feature_find` (`ev_befa4193ea8e9c2777b971801d75c2c18205f4cedc5e7506fc6e2175113c3b8c`) resolves to kernel32 `FindResourceA/LoadResource/…` plus Delphi text — no economy logic. |
| `ev_bee7ec07e451ac91a6f2f68eb6be9510146971c752bc59509eef1ceb5837dc0d` | `native_bytes_find("attack")` | 1 match `0x660960`; `core_feature_find` (`ev_3ce3aace…`) = 0 strings/functions → no named attack function. |
| `ev_49b4401cf86e5cdc3b8bff7e85e8114e194fccff9adc74ab8d5cac402a752cc3` | `native_bytes_find("AI")` | 166 matches (e.g. `0x414923`, `0x542b20`); all resolve to thunks/editor strings, not gameplay. |
| `ev_46d95a8149d5246ba96bd7e2b19a91b5ba461af733c25194e00793cca741f939` | `native_bytes_find("gold")` | **0 matches** — CLEAN UNVERIFIED in the EXE (localized/data-driven name). |
| `ev_7320df2f85f1f52b507e00f419cb529090c5fac389d701a842e8cda76682dc0b` | `native_bytes_find("peasant")` | **0 matches** — CLEAN UNVERIFIED in the EXE. |
| `ev_f0f599737656c19fd355aa6a1ef506faef007a2e0634d63f4e4b3bd3a848d8fc` | `native_bytes_find("mine")` | 2 matches (`0x6447de`, `0x644a95`) = `minexpinitspeed` parameter; see `ev_a6eefa…`. |

**INFERENCE (clearly labelled):** the EXE is the script VM + editor; AI/economy truth is in
`data\scripts\lib\*.script`, `data\scripts\units\global.inc\*.inc`, `dmscript.global` and
`data\scripts\units\*.aix`. Native decompilation of the wave failure is therefore a dead end;
whole-file byte search was required because data-section-only string search gives false negatives
(the VM binding text lives in CODE).

---

## 2. Top 10 donor rules (exact numbers, `path:line`)

1. **Training/build affordability = real cost, no horizon.** `PE:1377` uses
   `_unit_CanApplyCostByID(cid,id,plind)` for buildings; `PE:1405` uses
   `_unit_CanApplyCountCostByID(cid,id,plind,count)` for units; both combined with
   `_player_CheckAccessControlRequirements(...)=gc_result_checkaccesscontrolreq_ok`
   (`PE:1378`, `PE:1406`) and `bai or ballowhuman` (`PE:1407`). There is **no food reserve
   horizon** in the donor gate.
2. **AI-specific affordability buffer.** `US:5704-5710`: if `bai`, add **+300 food** when the
   food cost > 0 and **+25 gold** when the gold cost > 0 before the comparison at
   `US:5711-5716`. Upgrades use **+500 food / +25 gold** (`US:5774-5778`). The amount actually
   charged is the unbuffered cost (`US:5734-5740`). (This is the donor's reserve, not a cheat.)
3. **Escalating repeat cost.** `US:5654-5656`, `US:5673-5678`: `costmodifier := pow(costpercent/100, count)`;
   capped at **2** for mercenaries and **20000** otherwise; all six resource prices floored at
   `US:5683-5688`. Default `costpercent=100` (`US:486-489`); some buildings/units use
   `100.5` (`US:1051`, `US:1310`, `US:1380`), `102` (`US:1653`), `105` (`US:1867`, `US:1889`, `US:2018`).
4. **Peasant demand.** `PE:2087` `numpeasants = townhalls * 2`; `PE:2088` request while
   all-faction peasants < **400** or own < **30**; `PE:2094-2097` food-700 switch
   (many peasants vs one); human adviser gate `PE:2090-2091`. Priests `PE:2101`.
5. **Army composition quotas.** `CL:4784-4799` minimum counts: light infantry **36**, shooter
   infantry **16**, fast horse **16**, hard horse **16**, horse shooter **16**, cannon **1**,
   grenadier **16**, peasant **16**, weak unit **25**, supermortar **4**, mortar **1**,
   archer infantry **16**, naval **1** each. `CL:4818-4829` maxima **256** (cannon/mortar **36**,
   naval **1**). Officers = pikemen `div 36` (`PE:2105-2107`), `>9` for upgrades (`PE:2169`,
   `PE:2178`), infantry count thresholds `36*4=144` (`PE:2134`), `36*7+guards` (`PE:2152`), `>40` (`PE:2265`, `PE:2276`, `PE:2290`).
6. **Difficulty tiers.** `PE:2202-2213` `maxLevelAtt/Def` default **7/7**, easy **0/0**, normal **2/3**;
   `PE:2322-2331` divers normal **0**, hard **2**, veryhard **4**, impossible **4** (×10 units);
   `PE:2347` cannon `Clamp(num_depo*6, 6, 30)`; `PE:2349-2355` above easy howitzer
   `Clamp(num_depo*2,2,8)` and mortar `Clamp(num_depo*8,8,40)`, easy cannon halved.
7. **Mine construction.** `PE:1157` gate: count + in-progress + ideas < requested **and**
   `_unit_CanApplyCostByID` **and** `inProgressMines<1`; ore chosen by
   `_ai_GetClosestOrePlaceWithRes` (`PE:1159`); if `dist>30` gather **5** peasants
   (`PE:1175-1177`) + up to **2** free warriors (`PE:1187-1189`) into a `buildmine` army
   (`PE:1194-1201`); else old-style dummy + `_player_CreateConstructionDummyBySID`
   (`PE:1219`), `_misc_CanPlaceBuilding(..., colRad=0, unitRad=0.26, envRad=0, mineRad=-1, precise=True)`
   (`PE:1222`), `minpeasants=5`, `maxpeasants=5` (`PE:1231`, `PE:1235`). Demand:
   `PE:354-355` `onFood>11`, `onWood>0`, `onStone>0`, food140 upgrade, time>10 for millions;
   `PE:2712-2727` gold mine requested **2** early, **2/1** by gold-400 threshold;
   `PE:2865-2914` up to **7 gold / 6 iron / 6 coal** (or **5/4/4**, **3/3/3**, or `rounds-1`).
8. **Gold-shortage fallback = market trade.** `PE:3006-3110` `_ai_DoTrade`: sell surplus
   stone/wood/food **→ gold** (`PE:3041-3048`, `PE:3055-3058`, `PE:3083-3090`,
   `PE:3103-3110`); famine sells wood/stone **→ food** (`PE:3059-3065`); one-off
   coal/gold conversions (`PE:3016-3028`). Income math `PS:242-266` (`speed=256/1.024`,
   `mult=100`), gold insufficiency `PS:233-237` (`income/10` vs `consume*32/100/250`),
   gold<2 clears rebellion `PS:318`. **No numeric resource cap in scripts** (port HUD
   `9999999+` is port-only — G-H1).
9. **Wave/battle evaluation is relative, not an absolute force threshold.**
   `DG:478 gc_ai_BitvaInterval = 8`; `PW:1122` `GetGameTime - fLastBattleTime > 8`;
   force = Σ `aiForce` over squad units (`AI:2249-2267`, cell aggregation `AI:834`,
   max `AI:955-956`); army approved when `fSquadList.GetCount > 3` **and** `fForce > maxArmyForce`
   (`AI:2198`, `PW:2049`); retreat scales own force ×8 (or ×2) against enemy force
   (`PW:2398-2404`). No donor constant equal to 120 or 260 was found (`native_bytes_find`
   "attack": 1 irrelevant byte hit; scripts: no `AI_ATTACK_FORCE`).
10. **Capture is a binary flip, not a percentage.** `MX:963-1185` `_misc_CheckCapture`:
    radius gates `MX:977,1018,1023`; check interval `DG:1479` `0.1*19-epsilon` ≈ **1.9 s**
    (artillery `DG:1480` `0.1*5-epsilon` ≈ **0.5 s**, used at `UI:513-518`); gunfire blocks
    capture (`MX:1036-1040`, `MX:1064-1068`); AI demolition probabilities `MX:1164-1167`
    (supermortar **0.46875×1.25**, cannon **0.3125×1.25**, mortar **0.125×1.125**,
    peasant **0.546875**); ownership flips instantly via `_misc_ChangePlayer` (`MX:1178`).
    Capture modes govern *what* may be captured (`BI:316-324`, `UI:516-532`,
    `PS:2663-2686`); peasants/artillery are excluded from building capture
    (`US:2097`, `US:4656`). **No percentage-per-second formula exists in donor scripts** —
    the port's HUD `/8.0 s` divisor is port-only (G-C2).

Additional placement/cost evidence: `_misc_CanPlaceBuilding` signature `MS:4640-4642`,
implementation `MS:4642-5062`; deterministic neighbourhood probes ±0.5/±1 tiles at
`data\scripts\lib\miscext2.script:981-1017`. Build-time/builder formula `US:9109-9116`
(`btime ≤ 100 → builders/2`, `<1000 → *2/3`). Training gate prerequisites `US:10351-10435`.

---

## 3. Why an AI with gold = 2 cannot build a gold mine (donor terms), and the donor fallback

**OBSERVATION (donor):**
1. Every mine request goes through `_ai_TryUnit` → the mine branch (`PE:1382-1400`) →
   `_ai_TryMine`. `_ai_TryMine` refuses unless `_unit_CanApplyCostByID(cid,id,plind)` is true
   (`PE:1157`). For an AI player that function applies the **+300 food / +25 gold** reserve
   (`US:5704-5710`) to any cost that is non-zero. A gold-costing building therefore needs
   `gold ≥ price_gold + 25`, not merely `≥ price_gold`. With `gold=2`, no gold-costing order
   of any kind can be registered by the donor AI.
2. More importantly for this port's trace, mine *demand* itself is resource-gated:
   `_ai_BuildMines` requires `onFood>11`, `onWood>0`, `onStone>0` (`PE:354-355`), and the
   late-game mine batches require `(onWood+onStone)>25` (`PE:2883`, `PE:2909`). W51's trace
   shows stone 0 at t=60/180 and only 80 at t=120 → donor would not even *request* mines in
   that state. The port's flat `res.stone >= 100` gate (`ai.gd:439`) fails identically.
3. Even with a free ore deposit, the donor builds a mine by sending **5 peasants** to a
   `buildmine` army when the ore is >30 from the centre (`PE:1167-1199`) or by a
   construction dummy with 5/5 peasants when it is ≤30 (`PE:1212-1235`). If no ore handle
   is found at all (`PE:1261-1272`), the **only** fallback is to add the gold mine to the
   *human adviser's* suggestion list (`not bai` at `PE:1264`) — the AI does nothing.

**INFERENCE — what the donor AI does instead (fallback chain):**
- It does **not** invent a cheaper unit on the spot: `_ai_TryUnit` simply omits the unaffordable
  idea (`PE:1405`); `_ai_TryUnitExt` caps the request by producer count (`PE:1421-1427`).
- It front-loads mine demand *before* the army: gold mines requested 2 at `PE:2714`, 2/1 at
  `PE:2722-2727`, up to 7/5/3 at `PE:2871/2877/2885`.
- When gold is short but a surplus resource exists, it **sells the surplus at the market**:
  stone→gold, wood→gold, food→gold (`PE:3041-3048`, `PE:3083-3090`, `PE:3103-3110`).
- Its army core is cheap infantry, so force can grow without gold: pikemen to `36*4`
  (`PE:2134`) before musketeers, with officers on `div 36` (`PE:2105-2107`).

---

## 4. Exact divergences — donor vs `app/scripts/ai.gd` + `game.gd` (no edits made)

| # | Donor rule (`path:line`) | Port code | Divergence / consequence |
|---|---|---|---|
| D1 | Real-cost gate + AI reserve +300 food/+25 gold (`PE:1405`, `US:5704-5710`) | `ai.gd:42` `AI_TRAIN_FOOD_MARGIN=100`; `ai.gd:732` food-only margin; **no gold margin**; W51 removed the reserve horizon from `can_train_military` (`ai.gd:636-637`) | Food margin is 1/3 of donor and gold margin absent. `game.train_unit` (`game.gd:3826-3841`) charges exact cost, so at gold=2 every gold-cost unit is rejected. Donor would not even try (correct), but donor also avoids the state. |
| D2 | Mine demand gated by workers-on-food/wood/stone and built in one batch (`PE:354-355`, `PE:2712-2727`, `PE:2865-2914`) | `ai.gd:437-440` loops `iron, coal, gold`, each `res.wood>=100 and res.stone>=100`; `ai.gd:443-445` `bar_stone = 150 if metal_ready else 300` | Gold mine is **last** in the batch; stone is reserved for iron+coal only. With 400 starting stone (mill 150 + bar 150 + iron 100) gold never gets its 100 → `mine_gold` absent in all 600 trace rows. Donor requests gold **first** and up to 2 immediately. |
| D3 | Market→gold fallback (`PE:3041-3048`, `PE:3083-3090`, `PE:3103-3110`) | `ai.gd:568-584` `_market_balance`: only if some resource **>1500** and target **<800**, trades **100** per think tick | At trace food 338 / stone 0, no resource exceeds 1500 → market never trades gold. Donor's low-gold rule is explicitly time/surplus-driven; port's is a generic "richest resource" heuristic with a 1500 floor. |
| D4 | No absolute attack-force constant; army approved by quota + relative enemy force (`CL:4784-4799`, `AI:2198`, `PW:2398-2404`) | `ai.gd:868` `force < Data.AI_ATTACK_FORCE` (runtime **120**, `config.json:114`; static default 260 at `data.gd:73`) | Port's absolute gate is a port invention. With one barracks and force saturating at 84, `wave` can never increment; donor's relative/quota logic would keep producing and could sortie on force 84 if enemy force were lower. |
| D5 | `gc_ai_BitvaInterval=8` (`DG:478`, `PW:1122`) | `ai.gd:72` + `ai.gd:885-913` 8 s cooldown, consumed only on actual sortie | **At parity** (already correct); only unreachable because D1–D4 block the sortie. |
| D6 | Class quotas 36/16/16/16, officers `div 36`, cap 256 (`CL:4784-4829`, `PE:2105`) | `ai.gd:46-47` `16/36` and `32/36` ratios; `ai.gd:683-686`; `ai.gd:670-675` officers/drummers `1 + bar/2` | Ratios now donor-derived (W51), but officer count `1+bar/2` has no donor basis (donor `pikemanCount div 36`); with few units this is a surplus gold sink at gold=2. |
| D7 | Peasant demand `townhalls*2`, cap 400/30, food-700 switch (`PE:2087-2097`) | `ai.gd:638` one peasant per think tick while `peasants < AI_MAX_PEASANTS` and food ≥ reserve+200 | Port has no 400/30 cap, no food-700 switch, and a 200 food reserve on top of a 260 floor — conservative where donor is aggressive. |
| D8 | Capture binary flip + ~1.9 s check, artillery ~0.5 s (`MX:963-1185`, `DG:1479-1480`); gunfire blocks (`MX:1036-1068`) | `game.gd:2222-2228` field growth (different); HUD capture % divides by 8.0 s (G-C2); `_capture_unit_allowed` `game.gd:2745` still lets peasants capture | Port capture display is port-only; G-C2 already records the real gaps (AI demolition denial, peasant/artillery capture, % divisor). No new defect found. |
| D9 | AI cost escalation `pow(costpercent/100,count)` (`US:5673`) | `game.gd:3734` `build_cost(player,sid,pos)`, `ai.gd:161-169` `_can_afford` reads `Data.BUILDINGS[sid].cost` | Port has escalation; `_can_afford` is exact-cost with no AI reserve buffer — divergence from D1 for buildings too. |
| D10 | Resource income/consume (`PS:233-237`, `PS:242-266`, `PS:270-322`), gold<2 rebellion clearing (`PS:318`) | `game.gd:3899-3904` cheat income (+1.5/+0.8 per tick on hard), `game.gd:4107-4132` upkeep/gold famine | Port cheat is global-difficulty keyed (`W51 §6` note); donor gold-shortage effects are different (rebellion/ship-stop). Already in G-E2; no change proposed here. |

---

## 5. Root cause of the AI-wave failure (donor-grounded answer to the open bug)

**ROOT CAUSE (INFERENCE, strongly constrained by the donor text and W51's measurements):**
It is a **three-link chain, not one bug**:

1. **Income link.** Port AI builds `iron` then `coal` and only then `gold` (`ai.gd:437-440`),
   reserving stone for the two metal mines (`ai.gd:443-445`). Donor front-loads gold mines
   (`PE:2714`, `PE:2722-2727`, `PE:2871`). Result: no `mine_gold`, gold monotonically
   declines to 2 (W51 trace t=180…299).
2. **Spending link.** At gold=2, `game.gd:3831-3836` rejects every unit with any gold cost;
   the pick loop takes the **first** class-matching sid (`ai.gd:702-711`) and has no
   affordability-aware retry. Donor avoids gold starvation via market sales (`PE:3041-3048`)
   and a cheap-infantry core (`PE:2134`), and its AI cost check carries an explicit
   +25 gold reserve (`US:5709`) rather than discovering the shortage at `train_unit`.
3. **Trigger link.** Even after force recovered 46→84, the port's **absolute** gate
   (`ai.gd:868`, effective 120 via `config.json:114`) is unreachable with one barracks;
   donor has no such absolute constant and approves armies by quota + relative enemy force
   (`CL:4784`, `AI:2198`). So `wave=0` is the *expected* consequence of links 1–2 plus D4.

The W51 fixes (real-cost gate, donor class ratios, tier consumer) were correct and removed
the earlier food-reserve stall; they **exposed** links 1–3. There is no donor evidence for
raising `AI_ATTACK_FORCE` itself — changing 120/260 would be a port-only tweak, not translation.

---

## 6. Donor-grounded fix recipe — atomic per file, audit only (NOT applied)

Each item is independent and keeps the default trace silent unless `C3_AI_TRACE=1`. No RNG,
no resource cheat, no new donor constants invented.

**F1 — `app/scripts/ai.gd` (mine ordering).** Treat the three mines as one batch: reserve
`3 * 100` stone until `mine_gold`, `mine_iron`, `mine_coal` all exist (or no deposits exist),
and request `gold` first, matching `PE:2714`/`PE:2722-2727` rather than `ai.gd:437`.
Raise `bar_stone` (`ai.gd:444`) while any of the three is missing.
*Acceptance:* in a 300 s `C3_AI_TRACE=1` soak, `blds.mine_gold >= 1` by t≤120, and `gold`
stops declining by t≤180 (gold ≥ 25 for at least one sampled tick).

**F2 — `app/scripts/ai.gd` (donor AI reserve).** Add `AI_GOLD_RESERVE := 25.0` and
`AI_FOOD_RESERVE_BUFFER := 300.0` (from `US:5707`/`US:5709`), applied in `_train`
(`ai.gd:732`) and `_can_afford` (`ai.gd:161-169`) **only when the corresponding cost > 0**.
Keep the existing food margin logic but make it explicit that it replaces the donor 300.
*Acceptance:* no order is issued that leaves gold < 25 when the chosen unit costs gold;
`game.train_unit` rejection count via trace falls toward zero after F1/F3.

**F3 — `app/scripts/ai.gd` (gold recovery at market).** Extend `_market_balance` (`ai.gd:568-584`)
with a donor-shaped rule (`PE:3041-3048`): if `gold < 25 + cheapest_wanted_gold_cost` and some
other resource exceeds a deterministic surplus threshold and a market exists, trade surplus→gold
in fixed increments. Do not introduce randomness.
*Acceptance:* gold ≥ 28 within 60 s of first dropping below 25 in the trace; total resources
remain non-negative; seeded golden trace changes only in the AI-owned fields.

**F4 — `app/scripts/ai.gd` (affordability-aware sid fallback).** After a `train_unit` failure
(`ai.gd:734`), iterate remaining `b.def.trains` candidates of the wanted class and pick the
cheapest affordable one (deterministic order), instead of idling for the tick.
*Acceptance:* force resumes growing within 60 s after gold recovery; no unit is trained that
violates F2.

**F5 — `app/scripts/ai.gd` (wave trigger, coordinator decision).** Replace the absolute
`AI_ATTACK_FORCE` gate (`ai.gd:868`) with donor-shaped criteria: army contains ≥3 squads and
its force exceeds the strongest observed enemy army (`AI:2198`, `PW:2398-2404`), or, if the
coordinator prefers to keep the simpler gate, lower the *runtime* value explicitly and record
it as a port-only approximation (do **not** claim donor parity). Keep the 8 s cooldown.
*Acceptance:* `wave >= 1` in a 300 s soak once force ≥ 84 and enemy force is lower; successive
wave increments are ≥8 s apart; retreat logic unchanged.

**F6 — `app/config.json` (NOT in this lane — owner only).** `config.json:114 attack_force=120`
is the effective threshold; changing it or `data.gd:73` is a config/data-owner decision. Do not
edit from an AI-only ticket.

**F7 — `app/scripts/game.gd` (NOT needed for F1–F5; recorded only).** `game.gd:3734-3740`
and `game.gd:3826-3841` already charge real costs; no cheat should be added. The donor
+25/+30 buffers belong in the AI decision layer (F2), matching `US:5704-5710`.

**Shared acceptance soak (one clean run, as W51):** `$env:C3_AI_TRACE='1'; python app\tools\godot_runner.py run --id w51-force-soak-next --timeout 400 -- --headless --path app -- --cli app/cli.json --cli-seconds 300 --timeout 360`;
assert exit 0, 600 rows, `stderr` empty, `blds.mine_gold>=1`, `max(gold)>=28` after t=180,
`max(force)>=120` or donor-shaped trigger met, and `wave>=1`.

---

## 7. UNVERIFIED / BLOCKED

- **UNVERIFIED:** EXE contains **no** `gold` or `peasant` string (`ev_46d95a…`, `ev_7320df…`);
  no named AI/attack/wave gameplay function was found (`core_feature_find` results above).
  Native decompilation cannot supply AI constants here; only the script text can.
- **UNVERIFIED:** exact operator precedence of donor `not gPlayer[].res[...]>=cost` in
  `_unit_CanApplyCountCostByID` (`US:5711-5716`) and similar idioms (`PE:2094`, `PE:2719`,
  `PS:290`, `PS:318`). The custom VM's precedence differs from Delphi's and was not executed;
  the **+300/+25 buffer constants are unambiguous** regardless of the predicate reading.
  Do not build a fix on a guessed polarity.
- **UNVERIFIED:** actual numeric gold-mine price in donor `objbase[cid][id].price`
  (data files, not the script text read here). Port `data.gd:1281` says wood 100 / stone 100 /
  no gold; treat that as port data, not donor-derived.
- **BLOCKED (scope):** no source/asset/config/test/git edits; no target open/select; no runtime
  instrumentation. All recommendations in §6 are proposals only.
- **NOT RE-ASSERTED:** W51's tier consumer, food-reserve fix and class ratios are inputs; this
  report adds only new donor evidence and the three-link root cause.

## 8. Next atomic task suggestions

1. Implement F1+F2 in `ai.gd` only, then one clean soak (don't bundle F5).
2. Implement F3+F4 only after F1+F2 show gold recovery but train rejection persists.
3. Coordinator decision on F5 vs `config.json:114` before any wave-trigger edit.
4. Separate ticket: donor `costpercent` escalation values for `mine_gold`/`bar` from country
   data, to replace the port's inferred `build_cost` curve if fidelity is required.
