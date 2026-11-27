# DEC-U-VISION-AUDIT — complete donor sid→vision table (2026-11-26)

- id: DEC-U-VISION-AUDIT
- worker: DEC-U-VISION-AUDIT (subagent, full 1:1 donor port)
- date: 2026-11-26
- scope: READ-ONLY decomp. Donor binary never executed/copied. Donor text read as text only. No code/asset/config/Godot/git edits. Exactly one repo file written (this report).
- pin: `t_87f0f3c130b0` = `C:\Games\Cossacks 3\cossacks.exe`, PE32, 5,768,048 B, sha256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`
- upstream: `DEC_U_fog_camera_hud.md` §§1.1–1.4 (vision law `floor(20+4*vision)`, 7 re-read rows, F1-GRID probe); `IMPL-FOG-PATCHES` (`data.gd` 7-row mirror); `variant3d/scripts/world3d_fog.gd` (`donor_unit_vision`, default-0 load)
- labels: `[O]` verbatim donor text · `[D]` deterministic reading · `[I]` inference · `[U]` UNVERIFIED (settling probe given, never substituted)
- parity: NO PARITY CLAIM. No donor binary executed, no engine trace. Closed items rest on donor text `[O]` with file:line. Engine-side items (record zero-init, FOW grid units) stay `[U]`.

## 0. Pass ledger (all native/binary pins reuse `t_87f0f3c130b0`; all text passes read-only)

| # | Pass | Result |
|---|---|---|
| P0 | Binary pin re-verified (hash + size, no execution) | `t_87f0f3c130b0`, same bytes as DEC-U-FOG-CAMERA-HUD §0 |
| P1 | Reuse binary evidence for engine entry points | `ev_ae7d0836…` (`FOWEnable`, file-off `0x1d9daa` VA `0x5da9aa` + `0x2a74b5/0x2a74dd`), `ev_4f7e8d64…` (`GetFOWLOSData` at `0x2a7812`/VA `0x6a8412`), `ev_a6f63aeb…` (`RecordCustomBegin` 6 hits `0x281736…`) — all CODE, from DEC-U-FOG-CAMERA-HUD P8/P10/P12 |
| P2 | Donor-text grep `vision` over `C:\Games\Cossacks 3\data\scripts\**` (recurse, read-only) | 136 hits total; writers confined to ONE file (`lib/unit.script`); schema `lib/classes.script:3612`; consumer `lib/player.script:475`; law `lib/unit.script:11563-11614` |
| P3 | `SetObjBaseSearchBuildVisionScore` call-site census | 118 hits = 1 definition (`unit.script:571`) + **117 call sites** (`:636`–`:2082`), ALL in `lib/unit.script`, none in any other script dir |
| P4 | Direct-assignment census `objprop.vision :=` | **7 rows**: `:2069, :2167, :2236, :2550, :2560, :2569, :2581` — the rows prior work cited by line number are direct writes, NOT `Set…` calls |
| P5 | Case-header map (`_unit_InitBase`, `unit.script:600-2095`) | 113 `'…' : begin` headers dumped with indent; outer (ind 9, sid groups) vs inner (ind 15, `nation` or sid sub-branches) separated |
| P6 | Per-site attribution (nearest enclosing outer + inner header) | 117/117 call sites attributed; switch kind (`case nation of` vs `case objprop.sid of` vs `if bmercenary` vs `if sid=`) verified by re-read at every ambiguous site |
| P7 | Conditional-scope verification of the 7 direct rows + brace rows | `:2067-2075` (misflagman override), `:2156-2172` (`commonpor` gate), `:2223-2240` (tow unconditional), `:2539-2586` (mis* building block); braces `5{8}`/ `4{8}`/ `1{8}` active-vs-dead split confirmed |

## 1. Vision law recap (unchanged, cited for table use)

- `[O]` `unit.script:11567-11571`: `cBaseVal = 20`, `cModVal = 4`; `:11568-11569` commented `18/3.6/3.75` are DEAD alternates, never ported. Normal path `unit.script:11598`: `res := floor(cBaseVal + cModVal * vision)`.
- `[O]` Schema: `vision: Integer` is `TObjProp` (`classes.script:3612`). Writer: `SetObjBaseSearchBuildVisionScore(..., vision, ...)` (`unit.script:571-581`); `if (vision<>-1) then objprop.vision := vision`, and `const default = -1` (`:593`) = keep prior value.
- `[D]` Integer `res` table (floor is load-bearing): 0→20, 1→24, 2→28, 3→32, 4→36, 5→40, 6→44, 7→48, 8→52.
- `[U]` Unit of `res` (FOW cells vs world units) is engine-defined — F1-GRID probe territory, not revisited here.

## 2. Method (so the table is mechanically checkable)

1. Each sid group enters `_unit_InitBase` (`unit.script:600-2093` for units; `:2103-2588` for buildings) with a base `Set…` row (explicit vision) or, for buildings, usually NO row at all.
2. `default` (=-1) in the vision slot = keep whatever was written before (base row or earlier sub-branch). Only a numeric literal changes vision.
3. Inner sub-branches are three shapes: `case nation of` (suffix-derived nation, `unit.script:621-623`), `case objprop.sid of` (exact sid), `if (bmercenary)` (true ONLY for the 8 dip sids at `:613`: `roundshierdip, lightinfantrydip, archerdip, grenadierdip, cossacksichdip, dragoon18dip, archerturdip, lightcavalrydip`), and `if (objprop.sid='…')` chains (priests, yacht, bagpiper/drummer18).
4. `{…}` braces are Pascal comments (dead alternates/c1 notes), consistent across the file (e.g. buildtimes `128{144}`, `25*32{624}`). The value OUTSIDE the brace is active `[O]`; the braced value is a dead comment `[D]`, never ported.
5. Effective vision per sid = last numeric vision write on its path; `default` rows never change it.

## 3. Complete UNITS table (sid → vision → res; file:line is the LAST vision-deciding row on that sid's path)

Base rows marked (B); overrides marked (N=nation, S=sid, M=mercenary-only, D=direct write).

| sid(s) | vision | res | deciding row |
|---|---|---|---|
| `pikeman, pikemanpol, pikemantur, pikemanrus, pikemanpor, pikemanspa, pikemanswi` | 1 | 24 | (B) `unit.script:636` (`:647/:654/:661/:675/:682/:689` all `default` = keep) |
| `pikemansco` | 2 | 28 | (N) `unit.script:668` |
| `pikeman18` | 2 | 28 | (B) `unit.script:698` |
| `pikeman18swe` | 1 | 24 | (N) `unit.script:708` (`case nation of`, `:703`) |
| `lightinfantry` | 2 | 28 | (B) `unit.script:717` |
| `lightinfantrydip` (mercenary hire) | 1 | 24 | (M) `unit.script:726` (`if bmercenary`, `:721`) |
| `roundshier` | 1 | 24 | (B) `unit.script:741` |
| `roundshierdip` (mercenary hire) | 1 | 24 | (M) `unit.script:761` (`default` = keep base 1; nation `dip` matches no `nation` arm) |
| `swordsmansco` | 2 | 28 | (N) `unit.script:752` (`case nation of 'sco'`, `:745-746`) |
| `musketeer, musketeernet, pandur, serdiuk, musketeersco` | 2 | 28 | (B) `unit.script:782` (`:802/:811/:840/:858` all `default` = keep; `case objprop.sid of`, `:788`) |
| `musketeerpol, highlander, jannisary, jagerpor` | 1 | 24 | (S) `unit.script:795/:829/:849/:884` |
| `chasseur, jagerswi` | 4 | 36 | (S) `unit.script:820/:893` |
| `gauduk` | 2 | 28 | (S) `unit.script:867` (explicit 2) |
| `pandurhun` | 3 | 32 | (S) `unit.script:875` |
| `musketeerspa, musketeeraus, strelet` | 1 | 24 | (B) `unit.script:908` (`:920/:929/:937` all `default` = keep) |
| `musketeer18, musketeer18pru, musketeer18bav, musketeer18sax` | 2 | 28 | (B) `unit.script:954` (`:967/:975/:984` `default` = keep) |
| `musketeer18den` | 2 | 28 | (S) `unit.script:993` (explicit 2) |
| `archer` | 2 | 28 | (B) `unit.script:1015` |
| `archersco` | 2 | 28 | (N) `unit.script:1037` (`default` = keep base 2; `case nation of`, `:1020`) |
| `archertur` | 1 | 24 | (N) `unit.script:1027` |
| `archerdip, archerturdip` (mercenary hires) | 1 | 24 | (M) `unit.script:1050` (`if bmercenary`, `:1041`) |
| `archerscodip` | 2 | 28 | NOT mercenary-eligible (`:613` list omits it) → keeps sco-branch 2; no M row fires |
| `officer` | 2 | 28 | (B) `unit.script:1068` |
| `officerrus` | 1 | 24 | (N) `unit.script:1081` |
| `officertur` | 3 | 32 | (N) `unit.script:1087` |
| `officersco` | 2 | 28 | (N) `unit.script:1095` (explicit 2) |
| `officer18` | 4 | 36 | (B) `unit.script:1105` |
| `drummer, drummerrus*, drummertur*` | 6 / *5 / *7 | 44/40/48 | (B) `unit.script:1118` = 6; (N) `:1142` rus = 5; (N) `:1147` tur = 7 (`case nation of`, `:1138`; chain order `:1124-1149`) |
| `bagpiper` | 5 | 40 | (S) `unit.script:1128` (`if sid='bagpiper'`, `:1124`) |
| `drummer18` | 8 | 52 | (S) `unit.script:1135` (`else if sid='drummer18'`, `:1131`) |
| `priest, pope, mullah, padre` | 1 | 24 | (B)+3×(S) `unit.script:1157/:1169/:1177/:1186` — all numeric 1 (`if sid=` chain `:1164/:1172/:1181`) |
| `peaaus, peatur, peapol, peaspa, peaeng` (+`alg/tur` food-only arm, no vision row) | 1 | 24 | (B) `unit.script:1196` |
| `pearus` | 3 | 32 | (N) `unit.script:1208` |
| `peaukr` | 4 | 36 | (N) `unit.script:1213` |
| `peasco` | 1 | 24 | (N) `unit.script:1218` (explicit 1) |
| `grenadier, grenadierden, grenadierpru, grenadierbav, grenadiersax` | 2 | 28 | (B) `unit.script:1243` (`:1258/:1266/:1276/:1287` `default` = keep; `case objprop.sid of`, `:1249`) |
| `grenadierhun` | 2 | 28 | (S) `unit.script:1297` (explicit 2) |
| `grenadierdip` (mercenary hire) | 1 | 24 | (M) `unit.script:1309` (`if bmercenary`, `:1300`) |
| `hussar` | 3 | 32 | (B) `unit.script:1327` (`:1350` `default` = keep; `case objprop.sid of`, `:1330`) |
| `croat` | 2 | 28 | (S) `unit.script:1335` |
| `hackapell` | 3 | 32 | (S) `unit.script:1343` (explicit 3) |
| `hussarpru` | 5 | 40 | (S) `unit.script:1358` active `5`; `{8}` dead comment `[D]` |
| `wingedhussar` | 2 | 28 | (S) `unit.script:1367` |
| `cossacksich` | 3 | 32 | (S) `unit.script:1375` |
| `cossacksichdip` non-merc / mercenary hire | 3 / 1 | 32 / 24 | (S) `:1375` non-merc; (M) `:1383` `if bmercenary` (`:1377`) |
| `raidersco` | 2 | 28 | (S) `unit.script:1396` |
| `hussarhun` | 3 | 32 | (S) `unit.script:1404` |
| `hussarswi` | 4 | 36 | (S) `unit.script:1412` active `4`; `{8}` dead comment `[D]` |
| `reiter` | 1 | 24 | (B) `unit.script:1426` (sid arm `:1432-1438` writes no vision = keep) |
| `cuirassier, cossackdon, cossackregister, spakh, mameluke` | 3 | 32 | (S) `unit.script:1443/:1485/:1502/:1511/:1520` |
| `reiterswe, vityaz, lancersco, sipahi` | 2 | 28 | (S) `unit.script:1450/:1494/:1529/:1538` |
| `reiterpol` | 3 | 32 | (S) `unit.script:1466` |
| `hetman` | 7 | 48 | (S) `unit.script:1475` |
| `guardcavalrysax` | 3 | 32 | (S) `unit.script:1458` |
| `dragoon` | 3 | 32 | (B) `unit.script:1556` (sid arm `:1563-1565` writes no vision = keep) |
| `dragoonpol, dragoon18fra, lightcavalry` | 2 | 28 | (S) `unit.script:1572/:1593/:1630` |
| `kingmusketeer` | 4 | 36 | (S) `unit.script:1580` |
| `dragoon18net` | 3 | 32 | (S) `unit.script:1606` (explicit 3) |
| `dragoon18pie` | 5 | 40 | (S) `unit.script:1618` |
| `dragoon18` (standing unit) | 3 | 32 | (S) `unit.script:1642` (`default` = keep base 3) |
| `dragoon18dip, lightcavalrydip` (mercenary hires) | 1 | 24 | (M) `unit.script:1652` (`if bmercenary`, `:1645`) |
| `tatar` | 4 | 36 | (B) `unit.script:1681` |
| `cannon` | 1 | 24 | (B) `unit.script:1717` active `1`; `{8}` dead comment `[D]` |
| `howitzer, mortar, multicannon, framegun, fishboat, ferry, unitbox` | 1 | 24 | (B) `unit.script:1748/:1781/:1808/:1839/:1864/:2042/:2054` |
| `yacht` | 3 | 32 | (B) `unit.script:1888` |
| `yachttur` | 3 | 32 | (S) `unit.script:1918` (`default,default,3`; `if sid='yachttur'`, `:1903`) |
| `galley` | 2 | 28 | (B) `unit.script:1945` |
| `frigate, xebec` | 8 | 52 | (B) `unit.script:1974`; (S) `:1995` `default` = keep 8 |
| `battleship` | 8 | 52 | (S) `unit.script:2007` (explicit 8) |
| `chaika` | 4 | 36 | (S) `unit.script:2023` |
| `misdonkey, mistrader` | 1 | 24 | (B) `unit.script:2060` (sub-arms `:2064/:2072` write no vision = keep) |
| `misflagman` | 8 | 52 | (D) `unit.script:2069` (`objprop.vision := 8` overrides base 1; `case sid`, `:2067`) |
| `misgeneral` | 1 | 24 | (B) `unit.script:2082` |

Mercenary/`dip` rule `[D]`: an M row fires only when `bmercenary` is true, which the donor sets ONLY for the 8 sids at `unit.script:613-614`. `archerscodip` is absent from that list, so it never takes an M row. Nation arms keyed on the 3-letter suffix (`:621-623`); dip sids carry suffix `dip`, matching no nation arm.

## 4. Complete BUILDINGS table

Donor building sids are literal concatenations `commonsid + suffix` with `commonsid ∈ {eur,rus,tur,spa,ukr,por}` (loop `unit.script:2111-2139`; `spa` iteration additionally sets `commonpor`, `ukr` iteration sets `commonrus`). No `Set…Vision` call exists in ANY building branch — vision comes only from the 6 direct writes below, else `[I]` record default 0 (see §5).

| sid(s) | vision | res | deciding row + scope |
|---|---|---|---|
| `eurtow, rustow, turtow, spatow, ukrtow, portow` | 3 | 32 | `[O]` (D) `unit.script:2236` — unconditional inside `commonsid+'tow'` (`:2223-2240`); nation arms `:2241-2256` write no vision |
| `spapor, porpor` | 3 | 32 | `[O]` (D) `unit.script:2167` — inside `if (commonpor)` (`:2156-2172`), true only for the `spa` (i=3) and `por` (i=5) loop iterations (`:2126-2138`) |
| `eurpor, ruspor, turpor, ukrpor` | [I] 0 | [I] 20 | NO vision write on their loop iterations (`commonpor` false) — see §5 |
| `eurmil, rusmil, turmil, spamil, ukrmil, pormil` (mills) | [I] 0 | [I] 20 | no vision write (`:2141-2151`) |
| `eurmar, rusmar, turmar, spamar, ukrmar, pormar` (markets) | [I] 0 | [I] 20 | no vision write (`:2189-2203`) |
| `eursto, russto, tursto, spasto, ukrsto, porsto` (storage) | [I] 0 | [I] 20 | no vision write (`:2204-2222`) |
| `eurswa/eur sga …` (stone walls/gates ×6), `ukrwwa, ukrwga` (wood walls/gates) | [I] 0 | [I] 20 | no vision write (`:2258-2310`) |
| `eurgol…porcoa` mines (18 sids: `gol/iro/coa` × 6 prefixes) | [I] 0 | [I] 20 | no vision write (`:2311-2322+`) |
| `misblg, misblg2` | 3 | 32 | `[O]` (D) `unit.script:2550` (blockhouse, `case sid`, `:2539`) |
| `misyurt` | 2 | 28 | `[O]` (D) `unit.script:2560` |
| `miscommandcenter` | 2 | 28 | `[O]` (D) `unit.script:2569` |
| any other `mis*` building | 0 | 20 | `[O]` (D) `unit.script:2581` (`else` + `StrPos(csid,sid)=1` guard, `:2572-2583`) — the donor's explicit 0 row; NOT a keep |

## 5. Default-0 and `[U]` items (never invented)

1. `[I]` All building sids in §4 marked `[I] 0` have NO vision write anywhere: full-corpus grep (P2) proves no other file writes `.vision`, and the building branches contain no `Set…` call. Static `[I]`: the donor record default is engine zero-init (no init text sets `vision`; `TObjProp` is a plain `Integer` field, `classes.script:3612`). The port's current `world3d_fog.gd` default-0 load (`donor_unit_vision` fallback → `floor(20)` = 20) MATCHES this inference but is not donor-verified — keep labelled until the probe passes.
2. `[U]` Record zero-init itself: no readable text proves the engine zeroes `TObjProp`; a nonzero garbage default is theoretically possible. Probe P-VIS-PROBE closes it.
3. `[O]` Explicit donor 0 exists only for `mis*`-other (`:2581`). Do not conflate with the `[I]` building defaults.
4. `[D]` Dead-brace values `{8}` at `:1358/:1412/:1717`, `{144}`-family buildtimes, and `:11568-11569` law alternates are comments, never ported.
5. `[U]` Unchanged from prior work: `res` unit (cells vs metres), FOW cell size, multi-viewer combine, LOS occlusion, explored persistence — F1-GRID/F1-MINI probes (`DEC_U_fog_camera_hud.md` §§1.4/5.2).

## 6. Nation / mercenary override summary

- Nation (`case nation of`, suffix-derived): pikemansco→2; pikeman18swe→1; archertur→1; officerrus→1 / officertur→3 / officersco→2; drummerrus→5 / drummertur→7; pearus→3 / peaukr→4 / peasco→1; musketeer18 pru/bav/sax/den→keep 2. All other nation arms carry `default` = keep base.
- Mercenary (`if bmercenary`, only the 8 `:613` dip sids): lightinfantrydip→1 (`:726`), archerdip/archerturdip→1 (`:1050`), grenadierdip→1 (`:1309`), cossacksichdip→1 (`:1383`), dragoon18dip/lightcavalrydip→1 (`:1652`); roundshierdip keeps 1 (`:761`).
- Sid-shaped arms (`case objprop.sid of` / `if sid=`): musketeer, grenadier, hussar, reiter, dragoon families; priests; yacht; bagpiper/drummer18; misflagman. Full per-sid resolution is §3 (no arm omitted).

## 7. Gap in the current port (`IMPL-FOG-PATCHES` → `data.gd`)

- `[O]` `variant3d/scripts/data.gd:146-155` (`DEC_U_DONOR_VISION`) holds only the 7 re-read rows, keyed as `"commonsid+'por'"`, `"commonsid+'tow'"`, `"misblg"`, `"misblg2"`, `"misyurt"`, `"miscommandcenter"` (+ `misflagman: 8` at `:147`).
- Two defects, both additive-fixable: (a) the `commonsid+'…'` keys are donor loop EXPRESSIONS, not literal sids — no port entity will ever carry the sid string `"commonsid+'por'"`, so the port/tower entries can never hit; (b) all §3 unit rows and the §4 literal building sids are absent, so `dec_u_donor_vision()` returns 0 (→20) for every real unit sid instead of its donor value.
- `world3d_fog.gd:461-477` is correctly shaped for the fix: numeric `vision` → `floor(20+4·vision)`; absent key → 0. Only the table content is incomplete — no logic change needed.

## 8. Exact ADDITIVE patch recommendation for `data.gd` (NOT applied by this worker)

Replace the expression-keyed entries with literal donor sid keys and add every §3/§4 resolved row. Additive only: keep `dec_u_donor_vision()`'s default-0 shape (which now correctly expresses the donor `mis*`-else 0 at `:2581` and the §5 `[I]` building defaults). Vision integers below are all `[O]` except the `[I]`-marked building defaults, which the probe (§9) must confirm before anyone re-labels them. `res = floor(20+4·vision)` shown for driver convenience only.

```gdscript
# [O] Full per-sid donor vision, resolved pass P2-P7 (unit.script:636-2581).
# Keys are LITERAL donor sid strings (buildings: commonsid ∈ {eur,rus,tur,spa,ukr,por}).
# [I] rows (unwritten buildings → presumed 0) are listed explicitly so the
# default-0 load is auditable, and stay [I] until P-VIS-PROBE passes.
const DEC_U_DONOR_VISION := {
    # ── infantry / officers / drummers / priests / peasants ──
    "pikeman": 1, "pikemanpol": 1, "pikemantur": 1, "pikemanrus": 1,
    "pikemansco": 2, "pikemanpor": 1, "pikemanspa": 1, "pikemanswi": 1, # :636/:668
    "pikeman18": 2, "pikeman18swe": 1,                                 # :698/:708
    "lightinfantry": 2, "lightinfantrydip": 1,                         # :717/:726(M)
    "roundshier": 1, "roundshierdip": 1, "swordsmansco": 2,            # :741/:761(M)/:752
    "musketeer": 2, "musketeerpol": 1, "musketeernet": 2, "pandur": 2,
    "chasseur": 4, "highlander": 1, "serdiuk": 2, "jannisary": 1,
    "musketeersco": 2, "gauduk": 2, "pandurhun": 3, "jagerpor": 1,
    "jagerswi": 4,                                                     # :782-:893
    "musketeerspa": 1, "musketeeraus": 1, "strelet": 1,                # :908
    "musketeer18": 2, "musketeer18pru": 2, "musketeer18bav": 2,
    "musketeer18den": 2, "musketeer18sax": 2,                          # :954-:993
    "archer": 2, "archerdip": 1, "archertur": 1, "archerturdip": 1,
    "archersco": 2, "archerscodip": 2,                                 # :1015-:1050
    "officer": 2, "officerrus": 1, "officertur": 3, "officersco": 2,
    "officer18": 4,                                                   # :1068-:1105
    "drummer": 6, "drummerrus": 5, "drummertur": 7,
    "bagpiper": 5, "drummer18": 8,                                     # :1118-:1147
    "priest": 1, "pope": 1, "mullah": 1, "padre": 1,                   # :1157-:1186
    "peaaus": 1, "peatur": 1, "pearus": 3, "peapol": 1, "peaspa": 1,
    "peaeng": 1, "peaukr": 4, "peasco": 1,                             # :1196-:1218
    "grenadier": 2, "grenadierdip": 1, "grenadierden": 2,
    "grenadierpru": 2, "grenadierbav": 2, "grenadiersax": 2,
    "grenadierhun": 2,                                                 # :1243-:1309
    # ── cavalry ──
    "croat": 2, "hussar": 3, "hussarpru": 5, "wingedhussar": 2,        # :1327-:1367
    "cossacksich": 3, "cossacksichdip": 1,                             # :1375/:1383(M)
    "hackapell": 3, "raidersco": 2, "hussarhun": 3, "hussarswi": 4,    # :1343/:1396/:1404/:1412
    "reiter": 1, "cuirassier": 3, "reiterswe": 2, "reiterpol": 3,
    "hetman": 7, "cossackdon": 3, "vityaz": 2, "cossackregister": 3,
    "spakh": 3, "mameluke": 3, "guardcavalrysax": 3, "lancersco": 2,
    "sipahi": 2,                                                       # :1426-:1538
    "dragoon": 3, "kingmusketeer": 4, "dragoon18fra": 2,
    "dragoonpol": 2, "dragoon18net": 3, "dragoon18pie": 5,
    "lightcavalry": 2, "dragoon18": 3, "dragoon18dip": 1,
    "lightcavalrydip": 1,                                              # :1556-:1652
    "tatar": 4,                                                        # :1681
    # ── artillery / ships / mission units ──
    "cannon": 1, "howitzer": 1, "mortar": 1, "multicannon": 1,
    "framegun": 1, "fishboat": 1, "ferry": 1, "unitbox": 1,            # :1717-:2054
    "yacht": 3, "yachttur": 3, "galley": 2,                            # :1888/:1918/:1945
    "frigate": 8, "xebec": 8, "battleship": 8, "chaika": 4,            # :1974-:2023
    "misdonkey": 1, "mistrader": 1, "misflagman": 8, "misgeneral": 1,  # :2060/:2069(D)/:2082
    # ── buildings: literal sids ──
    "eurtow": 3, "rustow": 3, "turtow": 3,                             # :2236
    "spatow": 3, "ukrtow": 3, "portow": 3,                             # :2236
    "spapor": 3, "porpor": 3,                                          # :2167 (commonpor gate)
    "misblg": 3, "misblg2": 3, "misyurt": 2, "miscommandcenter": 2,    # :2550/:2560/:2569
    # ── [I] unwritten buildings → presumed 0 (probe §9; helper default covers mis*-other :2581) ──
    "eurpor": 0, "ruspor": 0, "turpor": 0, "ukrpor": 0,                # no write (commonpor false)
}
```

Notes for the applier (COORD/owner): (1) keep `dec_u_donor_vision()`'s `.get(sid, 0)` default — it IS the donor `mis*`-else 0 (`:2581`) and the §5 `[I]` default; (2) delete the old `"commonsid+'por'"` / `"commonsid+'tow'"` expression keys — they never match; (3) unwritten-building `0` entries may be left to the helper default instead of stored literally, but listing the four `*por` zeros above is the auditable choice since they are the trap case (armed port vs unarmed port); (4) all other unwritten buildings (mills/markets/storage/walls/mines) fall to the helper default and need no keys; (5) `res` values (20/24/28/32/36/40/44/48/52) belong in `world3d_fog.gd`'s existing `floor()` call, never as stored constants.

## 9. Runtime probes (all `[U]` items; fixed-camera reveal-radius transect)

- P-VIS-PROBE (validates §5 `[I]` zero default + table spot-checks; owner-authorised, donor binary never executed — uses the PORT build with the §8 table applied): skirmish, FOW on, fixed camera (any legal `camera.cfg` gameplay pose). For one sid per vision value (0: `eurmil` or `mis*`-other; 1: peasant; 2: `officer`; 3: `eurtow`; 4: `officer18`; 5: `bagpiper`; 6: `drummer`; 7: `hetman`; 8: `misflagman`): place single viewer, `FOWBuildFull`/step, dump `GetFOWLOSData` on a transect through the unit at 1.0-cell steps, fit reveal radius vs `floor(20+4·vision)` (20/24/28/32/36/40/44/48/52). Acceptance per sid: observed radius matches predicted `res` within grid quantisation, else the sid keeps `[U]` and the table row is re-audited. Minimum: the four trap cases (`spapor`=32 vs `eurpor`=20; `misflagman`=52; `hetman`=48; `eurmil`=20).
- F1-GRID / F1-MINI (unchanged, owned by DEC-U-FOG-CAMERA-HUD): cell size, max-vs-sum combine, occlusion, explored persistence. This audit adds no new engine claim and re-proves none.

## 10. Explicit non-claims + file discipline

- No parity claimed. No donor binary executed, no GPU frame captured, no port capture compared. Closed rows rest on donor text `[O]` with file:line; engine-side items stay `[U]`/`[I]` with probes above.
- No approximation substituted: the 7-row `data.gd` mirror is extended only with resolved donor integers (§8); nothing is invented for any sid.
- Read-only compliance: exactly one repo file written (this report). Binary pin `t_87f0f3c130b0` reused with prior evidence ids + VAs/file-offs (§0 P1); donor text passes P2–P7 are new read-only reads with file:line cites; shared Craft Anything investigation memory was read, never written; no target opened/selected/closed by this worker.

*End of DEC-U-VISION-AUDIT.*
