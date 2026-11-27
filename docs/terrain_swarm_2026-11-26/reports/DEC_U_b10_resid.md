---
id: DEC-U-B10-RESID
worker: DEC-U-B10-RESID (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-27
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 (carried; no native tool used this ticket, no binary executed/copied)"
donor: "READ ONLY. Donor binary never executed/copied. Donor scripts/data read as text only via read-only shell (Get-Content/Select-String). No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. No LAN/multiplayer/lobby/score surface wired or changed."
parity: "NO PARITY CLAIM. Parity UNVERIFIED. No donor GPU A/B frame; no donor binary executed; no port capture compared."
context: "PORT1TO1_u_classify.md B10 angle (S-SKIRM tables): STATIC audits of unit.script SetObjBase*, weapon.script _weapon_AddWeapon, player.script producers, startingsettings.cfg:183-720+, write*.inc/read*.inc field order; zero-fill omissions. Prior DEC_U_b10_skirmish_tables.md promoted byte-proven static literals [D] only, all live behaviour [U]. DEC_U_skirmish_impl_patch.md carries the ported laws."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading of [O] · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
---

# DEC-U-B10-RESID — residual static re-read of the B10 donor tables (2026-11-27)

## 0. Pass ledger (donor read-only; no native tool; no execution)

| # | Pass (read-only shell only) | Result / evidence |
|---|---|---|
| P1 | Donor path probe | `C:\Games\Cossacks 3\data\scripts\lib\unit.script`, `lib\weapon.script`, `lib\player.script`, `data\game\var\startingsettings.cfg`, `data\scripts\units\global.inc\write*.inc` / `read*.inc` all present as text. Binary never executed/copied. No `native_*` tool used, so no `native_function_study` pin check was due (tooling rule: pin check only if native tools used). |
| P2 | `SetObjBaseProtection` re-count | 33 hits = 1 definition (`unit.script:510`) + 32 calls (`:634-:1537`). Prior `DEC_U_skirmish_tables.md` §1.2 tabulated all 32 + the wall single-slot overwrite (`:1821`) — **no residual; explicitly none found** (§1). |
| P3 | `_weapon_AddWeapon(` re-count | 78 hits in `weapon.script` (definition at `:39` + `ToList` helper at `:186` excluded by the `(` filter; 78 = live prototype rows). Prior §1.1 transcribed all 78 — **no residual; explicitly none found** (§1). |
| P4 | `SetObjBuildingBaseSettings` re-read | 12 call rows (`unit.script:2142-:2576`) with per-branch score/usage literals — **NEVER tabulated per-row before** (prior recorded arity only). Transcribed §2 as the `[O]` residual. |
| P5 | `startingsettings.cfg` startid sweep | `startid` at lines 89/183/187/314/503/720/862/989/1178/1396/1540/1701/1826/1989/2178/2350/2526/2830/2973. Prior covered 0–4 only. Startids 5–13 resource sextuples — **NEVER tabulated before**. Transcribed §3 as the `[O]` residual. |
| P6 | `SetObjBaseWeapon(` re-count | 138 hits = 1 definition (`:520`) + 137 calls (`:632-:2543`). Prior §1.3 sampled core-infantry/cavalry only (~15 branches). Residual scope (~120 untabulated calls) is **real but NOT transcribed this ticket** — stays T1-tail `[U]` (§4). No row invented. |
| P7 | `player.script` producer sweep | All `_player_*` definitions enumerated (§5). No train/research timing producer with per-value rows beyond `CreateConstructionDummy` / `ProcessResourceIncome/Consume` / `ApplyUpgrade` anchors — **no new producer row; Q1 stays `[U]`**. |
| P8 | write/read symmetry spot-check | `writesquadnew`/`readsquadnew`, `writeorder`/`readorder`, `writeproduce`/`readproduce` field order compared verbatim (§6). `writeplayer`/`readplayer` are trivial stubs. Symmetry holds for checked pairs; byte framing stays `[U]`-R1. |

DSL note `[D]` (inherited): donor `not X` on a numeric lvalue is the current-value read, not negation.

---

## 1. Re-reads with explicitly NO residual (closed tables, counts match)

### 1.1 `SetObjBaseProtection` — complete, no new row `[O]`

- Definition `[O]` (`unit.script:510`): `procedure SetObjBaseProtection(var objbase : TObjBase; pike, sword, bullet, cannister, arrow, cannonball : Integer);`
- 32 calls at `:634, :646, :653, :660, :667, :674, :681, :688, :739, :750, :762, :919, :928, :1066, :1080, :1086, :1094, :1366, :1424, :1436, :1442, :1449, :1457, :1465, :1474, :1484, :1493, :1501, :1510, :1519, :1528, :1537` — each matches one row of prior §1.2 rows 1–32 verbatim (spot-verified `:634 → (3,2,4,210,{7}6,40)`, `:762 → (5,3,8,225,{19}17,80)`, `:1493 → (2,4,{c1 was 9}3,{c1 was 255}160,{c1 was 5}17,40)`).
- Single-slot overwrite `[O]` (`unit.script:1821`): `objbase.protection[gc_obj_weapon_kind_cannister] := 500;` — prior row 33, carried.
- **Verdict: no untabulated `SetObjBaseProtection` row exists. None recorded.**
- Zero-fill law (carried, re-confirmed `[O]`): only 6 kind slots are ever written (`unit.script:512-517` map `protection[pike/sword/bullet/cannister/arrow/cannonball]`); kinds `firearrow=6, mortarball=8, heal=9` are NEVER written by this proc → always 0 at base `[D]`. Sids with no call site inherit the base-case value (often all-zero) — absence is donor law; do not back-fill `[D]`.

### 1.2 `_weapon_AddWeapon` prototype rows — complete, no new row `[O]`

- Definition `[O]` (`weapon.script:39`): `procedure _weapon_AddWeapon(var ind : Integer; const weaponsid, fx, projbasename : String; damage : Integer; radius, gravity : Float; propagation : Integer; physvalue, time : Float);` with `physvalue→speed/angle/gravity` dispatch (`:59-62`) and `brotate`/`bcollisiondetection` rules (`:54-55`) — all carried from prior §1.1 header.
- 78 `_weapon_AddWeapon(` call rows — count matches the prior COMPLETE table (§1.1, `(none)` through `POINTOTVZRIVFRAME`) exactly.
- **Verdict: no untabulated weapon-prototype row exists. None recorded.**

---

## 2. `[O]` RESIDUAL — `SetObjBuildingBaseSettings` per-branch rows (never tabulated before)

Definition `[O]` (`unit.script:461`): `procedure SetObjBuildingBaseSettings(var objprop : TObjProp; bcapture : Boolean; score, usage : Integer);`
Passthrough `[O]` (`unit.script:505`): `SetObjBuildingBaseSettings(objprop, bcapture, score, usage);` (forwarder inside `SetObjBuildingProperties`; not a value row).

All 12 value rows verbatim, with enclosing branch context (common-prefix branches `commonsid := 'eur|rus|tur|spa|ukr|por'` per `unit.script:2115-2136` `[O]`):

| # | unit.script line | Enclosing branch | Verbatim call `[O]` |
|---|---|---|---|
| B1 | 2142 | `commonsid+'mil'` (mill; `i`-loop over 6 common prefixes) | `SetObjBuildingBaseSettings(objprop, bCapture, 20, gc_obj_usage_mill);` |
| B2 | 2153 | `commonsid+'por'` (port) | `SetObjBuildingBaseSettings(objprop, False, 500, gc_obj_usage_port);` |
| B3 | 2190 | `commonsid+'mar'` (market; sets `objprop.bmarket := True`) | `SetObjBuildingBaseSettings(objprop, bCapture, 500, 0);` |
| B4 | 2205 | `commonsid+'sto'` (storage) | `SetObjBuildingBaseSettings(objprop, True, 30, gc_obj_usage_storage);` |
| B5 | 2224 | `commonsid+'tow'` (tower) | `SetObjBuildingBaseSettings(objprop, False, 500, gc_obj_usage_tower);` |
| B6 | 2259 | `commonsid+'swa', commonsid+'sga'` (stone wall / gate) | `SetObjBuildingBaseSettings(objprop, False, 1, gc_obj_usage_none);` |
| B7 | 2286 | `'ukrwwa', 'ukrwga'` (wood wall / gate) | `SetObjBuildingBaseSettings(objprop, False, 1, gc_obj_usage_none);` |
| B8 | 2312 | `commonsid+'gol', commonsid+'iro', commonsid+'coa'` (mines; `produce[gold/iron/coal] := 13`) | `SetObjBuildingBaseSettings(objprop, True, 500, gc_obj_usage_mine);` |
| B9 | 2540 | `'misblg', 'misblg2'` (mission blockhouse; `weaponsid := 'SHOTBLOCKHOUSE'`) | `SetObjBuildingBaseSettings(objprop, False, 500, gc_obj_usage_tower);` |
| B10 | 2555 | `'misyurt'` | `SetObjBuildingBaseSettings(objprop, False, 0, gc_obj_usage_none);` |
| B11 | 2564 | `'miscommandcenter'` | `SetObjBuildingBaseSettings(objprop, False, 0, gc_obj_usage_none);` |
| B12 | 2576 | `StrPos(csid, objprop.sid)=1` fallback (`csid='mis'`) | `SetObjBuildingBaseSettings(objprop, False, 0, gc_obj_usage_none);` |

Notes `[D]`:
- `bCapture` (B1, B3) is the enclosing-procedure parameter, not a literal — the *score/usage* pair is the `[O]` literal; the capture flag resolves per call path and stays `[U]` where the caller is not traced.
- Score extremes are literal: walls score `1`, mission-decor score `0`, ports/towers/market/mine score `500`, mill `20`, storage `30`.
- Companion per-branch literals on the same lines (price, HP, weapon) are NOT promoted here — they belong to the T1-tail mechanical audit; only the `SetObjBuildingBaseSettings` 4-tuples above are claimed `[O]`-residual.

---

## 3. `[O]` RESIDUAL — `startingsettings.cfg` startids 5–13 top-level `addresources` (never tabulated before)

Prior `DEC_U_skirmish_tables.md` §4 covered startids −1/0/1/2/3/4 only. The file's enum header `[O]` (`startingsettings.cfg:3-12`) names all 14 ids (`default=0 … union=13`), and live blocks for 5–13 follow the old-version section with **no `dataversionmin/max` gate** (unlike 1–4 which carry `60–1000`, and unlike the inert `0–59` duplicates at `:862-:1537`). Top-level sextuples verbatim:

| startid (mapsettings key) | cfg line | food | wood | stone | gold | iron | coal |
|---|---|---|---|---|---|---|---|
| 5 `differentnations` (`:1539`) | 1541 | 5000 | 5000 | 5000 | 5000 | 5000 | 5000 |
| 6 `towers` (`:1700`) | 1701 | 20000 | 0 | 0 | 0 | 6000 | 9000 |
| 7 `cannons` (`:1825`) | 1827 | 20000 | 0 | 0 | 1000 | 6000 | 9000 |
| 8 `cannonsandhowitzers` (`:1988`) | 1990 | 20000 | 0 | 0 | 1000 | 6000 | 9000 |
| 9 `barrack18` (`:2177`) | 2179 | 65000 | 2000 | 2000 | 15000 | 6000 | 9000 |
| 10 `barrack17` (`:2349`) | 2351 | 5000 | 1000 | 1000 | 2500 | 3000 | 3000 |
| 11 `village` (`:2525`) | 2527 | 1000 | 1000 | 1000 | 1000 | 2500 | 2500 |
| 12 `logcabins` (`:2829`) | 2831 | 0 | 0 | 0 | 0 | 2500 | 2500 |
| 13 `union` (`:2972`) | 2974 | 1000 | 0 | 0 | 0 | 0 | 0 |

Caveats `[D]/[U]`:
- Double-add policy (`dogenerate.inc:255-292`, prior §4.1) applies to matched players for these blocks exactly as for 1–4 `[D]` — the table above is the single-block literal; the live grant is 2× on match. Country-override `addresources` sub-blocks (e.g. startid 6+ per-country stanzas at `:1766/:1802/:1900/:1945/:2072/:2126`) are cited as present but NOT transcribed per-value this ticket — stays S-tail `[U]` with the same experiment as prior §9-S.
- Legend/mask families for 5–13 (e.g. startid 5 per-nation `key→role/countrysid/basename` legends + `mask` rows at `:1546-:1699`; startid 13 `aus+hun`-gated block at `:2978+`) are observed present with line anchors but per-mask unit counts are NOT derived here — stays S-tail `[U]` (mechanical count + `dogenerate.inc:293-377` dispatch already cited in prior §4.2; no binary needed).
- Liveness (which startid a shipped map selects, whether the no-dataversion blocks apply to current data) is runtime/data-driven and stays `[U]` with zero-mismatch termination (§7 S-battery).

---

## 4. Known residual NOT transcribed (explicit scope statement, no invention)

- `SetObjBaseWeapon`: 138 hits = 1 definition (`unit.script:520`) + **137 calls** (`:632-:2543`). Prior §1.3 transcribed core-infantry/cavalry samples only. The remaining ~120 call sites (ships, artillery, buildings, walls, 18c variants, nation overrides, `default`-pin rows) are **not transcribed in this ticket**. They remain T1-tail `[U]` with the prior §9-T1 experiment (mechanical `case objprop.sid of` audit, `unit.script:627-~2600` + `classes.script`, cite-or-tag per row, zero-fill where absent). Stating the count narrows structure only; no value is promoted `[D]`.
- `SetObjBasePrice` / `SetObjBaseSearchBuildVisionScore` / `SetObjBaseMaterialCanKill`: 271 combined hits; prior sampled core rows only. Remainder stays T1-tail `[U]` with the same experiment. No value promoted.
- `objprop.weapon[n].weaponsid` pins (`SHOTMUSKET/STRELA/OSTRELA/NUCLGRE/PPOINTT*/SHOTBLOCKHOUSE/DIMMORT*` at `:775, :901, :947, :1000, :1006, :1230, :1236, :1549, :1669, :1674, :1704, :1711, :1740, :1772, :1801, :1831, :1881, :1914, :1931, :1936, :1967, :2159, :2228, :2544`) re-confirm the §1.3 weapon→prototype linkage shape `[O]`; per-sid damage/pause/radius rows stay T1-tail `[U]`.

---

## 5. `player.script` producers — anchors re-confirmed, no new per-value row `[O]`

Full `_player_*` definition census (all `[O]` with `player.script:line`): `GetTPlayerArgs :5`, `ClearPlayerStatistics :14`, `ClearUpgradeState :43`, `Init :58`, `ReInitAllPlayersBaseObj :149`, `InitAllPlayers :168`, `ResetAllPlayers :183`, `CreateConstructionDummyBySID :202`, `CreateConstructionDummy :222`, `GoldIncomeLessThanConsume :233`, `ProcessResourceIncome :242`, `ProcessResourceConsume :270`, `CheckAccessControlRequirements :326` (incl. `artlimit` gate `:375-376`), `UpdateFOW :453`, `WriteSquadNew :890`, `CreateSquad :910`, `OrderUnitsToBuild :1099`, `ConstructBuildingList :1478`, `ConstructGates :1585`, `ApplyUpgrade :1649` (incl. protection `+= round(value)` at `:1790-1798`, carried), `SetupTeams :2141`, `CalcSquadsMoveCount :2593`, `ApplyMapSettings :2611`.
**No train/research queue-timing producer with per-value literals was found beyond these anchors.** Q1 (queue caps/batch, batch-5/100 provenance) stays `[U]` with the prior §9-Q1 experiment. **No producer row recorded this ticket.**

---

## 6. write/read field-order symmetry + zero-fill omissions `[O-shape]` / `[U-bytes]`

Method: verbatim `RecordCustomWrite*` vs `RecordCustomRead*` order comparison on three pairs (all `[*]` engine-bound lines — static text only, no execution).

- `writesquadnew.inc:102-116` → `readsquadnew.inc:13-22,48` `[O]`: write order `serverflag(Boolean), pl, sid(String), formind, offuid, drmuid, bposition(Bool), binsquad(Bool), squid, count, uid…` == read order `bFromServer, pl, sid, formind, offuid, drmuid, bposition, binsquad, squid, count, uid…` — **symmetric, no omission** `[D]`.
- `writeorder.inc:31-47` → `readorder.inc:8-18,33,46` `[O]`: `ordtyp, taruid, clrord(Bool), locktrg(Bool), number, posx/z(Float, conditional), hnduid/uid…` both sides in the same order (commented `//hnduid` head line mirrored on both sides) — **symmetric, no omission** `[D]`.
- `writeproduce.inc:28-38` → `readproduce.inc:8-18` `[O]`: `proid, prcid, amoun, state(Bool), count, hnduid…` both sides in the same order — **symmetric, no omission** `[D]`.
- `writeplayer.inc:15-23` / `readplayer.inc:7-19` `[O]`: trivial stubs (`uid, cap` only) — symmetric but content-free; full player-state framing lives in the `serial.script` `WriteBuffer/ReadBuffer(SizeOf(...))` block calls (prior §6, carried).
- Full 40-pair inventory (prior §6) re-confirmed present by filename glob this ticket (34 `write*` + matching `read*` under `units/global.inc/`, plus `writelansyncdata/writeres/writescenario/writestats` under `progress/`) `[O-shape]`.
- **Stays `[U]`-R1**: byte framing of every `[*]` line, `SizeOf`/skip arithmetic, and any field the engine writes outside these text lines. Port save stays PORT EXTENSION with the prior §9-R1 round-trip test (never a byte-parity claim).

Zero-fill omissions (donor law, carried `[D]`): any `protection`/price/score/weapon field with no writer at a sid's branch keeps the base-case (often zero) value; `SetObjBaseWeapon(..., default, ...)` (`-1`=`default`) keeps the prior value (`unit.script:520-546`); `round()` bankers caveat on PUSSTRELA time rows (prior §1.1) is not re-derived here.

---

## 7. Still-`[U]` register (no promotion; zero-mismatch termination for each)

| # | Tail | Static state after this ticket | Exact terminating experiment (owner-authorised; 0 mismatches) |
|---|---|---|---|
| T1-tail | Remaining per-sid rows (137 `SetObjBaseWeapon` calls, price/search/score/material rows, shield values) | Counts + §2 building-score residual `[O]`; rest uncited | Mechanical grep `case objprop.sid of` (`unit.script:627-~2600`) + `classes.script` defaults; every row cite-or-tag vs port `UNITS_BASE`; zero-fill where absent. No binary needed. |
| D1 | Dispersion/height bonus | No term in `_misc_DoDamage` (prior §2 carried) | `dispertion/height/hill` grep + fixed-range volley σ + height-differential pairs; port ×1.25 stays APPROXIMATION until then. |
| Q1 | Train/research timing + queue caps | No producer rows found (§5) | `player.script` producer read + runtime queue-length sweep; batch-5/100 provenance (likely PORT EXTENSION — delete if absent). |
| G1-tail | `round()` bankers + draw order | Literals kept verbatim | X21 20-vector fixture + per-site draw-count test; Delphi `round()` semantics asserted per call site. |
| A1-tail | AI build order / cheat / recall | Unchanged | `progresswarai.inc` continuation + build-order read; rest labelled PORT-AI. |
| R1 | Save byte framing | Field order symmetric on 3 checked pairs (§6); bytes open | Full `write*.inc/read*.inc` field-order enumeration + PORT EXTENSION round-trip determinism test (RNG, queues, cooldowns, projectiles, corpses, stamps). |
| S-tail | Startids 5–13 masks/legends/overrides; live startid selection | Sextuples `[O]` §3; masks/legends line-anchored only | Per-block mask transcription + nation→member resolution at runtime; double-add asserted in-game. |
| V1/V2/F1/E1 | FOV/selection/fog/delivery | Unchanged from skirmish reports | Per-report experiments (sensor-width solve, Ghidra+GL trace, `fogreveal` grep, call-site split). |
| O1-tail | Engine plInd iteration | Unchanged | Progress-state driver recovery + fixed-seed hash battery. |
| C1/T2/S-head | — | CLOSED by prior tickets (no tail) | None. Port implements verbatim; `capture_t` retired to `lasttimecheckcapture`. |

Port discipline until termination: `resbalance` stays hard-zero + dormant; no mercy branch; score-victory stays behind the non-1:1 flag; trigger actions write `myplind` only; §2–§3 literals above are static text ripe for porting with `file:line` cites, but **this worker ports nothing and claims no live behaviour**.

---

## 8. Claim register and verdict

| # | Claim | Label |
|---|---|---|
| 1 | Donor read as text only via read-only shell; binary never executed/copied; no native tool used; exactly one repo file written | `[O]` §0 + scope |
| 2 | `SetObjBaseProtection` 33 hits and `_weapon_AddWeapon(` 78 hits re-counted; both match prior COMPLETE tables — explicitly no residual row | `[O]` §1 |
| 3 | 12 `SetObjBuildingBaseSettings` branch rows (`unit.script:2142-:2576`) transcribed — never tabulated before | `[O]` §2 |
| 4 | 9 `startingsettings.cfg` startid 5–13 sextuples transcribed — never tabulated before; masks/legends line-anchored, counts `[U]` | `[O]`/`[U]` §3 |
| 5 | `SetObjBaseWeapon` 137 calls / price rows: residual scope stated, nothing transcribed, T1-tail stays `[U]`; no `player.script` producer row found, Q1 stays `[U]` | `[O]` count + `[U]` §§4–5 |
| 6 | write/read field order symmetric on 3 checked pairs; full inventory re-confirmed; byte framing stays `[U]`-R1 | `[O]`-shape + `[U]` §6 |
| 7 | `parity.claim = NONE`, `parity.status = UNVERIFIED`, `visual_parity_claim = false`; chain 0/6 CLOSED; no live behaviour closed by static means | `[D]` verdict |

> **Verdict (governing form):** `port=UNVERIFIED`; `parity.claim = NONE`; `parity.status = "UNVERIFIED"`; `visual_parity_claim = false`; `blocking_unverified` non-empty (P0-1…P0-8 plus T1-tail/Q1/G1-tail/A1-tail/R1/S-tail/V1/V2/F1/E1/O1-tail); six-condition chain 0/6 CLOSED. **`RESULT IS NOT GOOD`.** No donor GPU A/B frame exists; no approximation is authorised; no parity claim is made.

*End of DEC-U-B10-RESID. Read-only; exactly one repository file written; no source/asset/config/test/runner/Godot/git/donor-execution; parity UNVERIFIED; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty.*
