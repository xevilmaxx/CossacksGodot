---
id: DEC-U-CAPTURE-VETO-DEEP
worker: DEC-U-CAPTURE-VETO-DEEP (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied/opened as a target. Donor text scripts/data read as text only. No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. All _net_IsClient/_net_IsReplay/_net_IsServer/_net_IsRecord/bProcess/WritePlayer tails are exclusion boundaries."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker. All [O] are donor TEXT with file:line; every number the port needs but the donor text does not give stays [U] with an exact capture."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT RULE = port substitute kept labelled for 1:1"
---

# DEC-U-CAPTURE-VETO-DEEP — protector veto from NEW static angles: packed-CODE census, native-wrapper sources, zero-hit live-gate census, byte-proven order (2026-11-26)

Inherited (not re-proved): capture head predicate 80% (cadences, radii, AI die rolls) per SKIRMISH-TABLES §3; boolean-instant flip + no accumulator per CAPTURE-STATE §1; single-protector veto law `distSqr<protectionradiusSqr → bcapture:=False` (`miscext.script:1041-1072`) + AI-artillery table + blockshot freeze per CAPTURE-STATE §§2-3 / STATE2 §§2-3; port G-09 guard-block kept as labelled PORT RULE after the veto (`variant3d/scripts/game.gd:8625-8644`).

This ticket adds ONLY what the prior tickets did not: (a) packed-CODE byte search for the veto's names, (b) native-wrapper vs script-constant sourcing of the distance comparison, (c) a script-tree-wide zero-hit census for any second live gate, (d) the veto→blockshot→AI-roll→flip order decoded from script-byte order. No new veto, threshold, cooldown, or majority is invented. No parity is claimed.

## 0. Pin + NEW pass ledger (every pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert (read-only) | `(Get-Item cossacks.exe).Length` re-read by this worker = **5,768,048 B** `[O]`. SHA256 not recomputed by this worker (no hash tool invoked); `87f0f3c1…af4e16c` inherited from pin `t_87f0f3c130b0`. Binary never executed, copied, or opened as a target. EV-VETO-PIN |
| P2 | `miscext.script:961-1185` full re-read (this worker) | EV-VETO-ORDER: `_misc_CheckCapture` head, capturer scan, blockshot flag/freeze, protector scan+veto, AI-artillery exit, birth/hide gates, flush, alarm, AI die rolls, `bDie ? death : ChangePlayer` — verbatim order §4 |
| P3 | Radius/cadence/grid constant re-pin `dmscript.global:55-60,174,203-220,1476-1480,1769` | EV-VETO-CONST: scangrid 4 m cells, `frames_to_time=0.03125`, gameplay radii + `Sqr` derivatives, cadences, `lasttimecheckcapture` field §2 |
| P4 | Search-proc re-read `unit.script:4615-4763` (this worker) | EV-VETO-SEARCH: `_unit_SearchProtectors` (`:4617`), `_unit_SearchCapturers` (`:4641`), `_unit_SearchCapturersForWall` (`:4668`), `_unit_CheckCapturersStopProduce` (`:4695`), `_unit_TestCapture` (`:4731`) — filter law §2 |
| P5 | Packed-CODE byte census, read-only (this worker) | EV-VETO-BYTE: ripgrep-literal over `cossacks.exe` file bytes for 7 veto names → **0 hits each**; `DMScript` present (engine strings only). §1. No VA invented |
| P6 | Native-wrapper source probe (script tree) | EV-VETO-WRAP: zero script-side `function Sqr/floor/MaxFloat/GetGameObjectPosition*` definitions; sole script-side wrapper is `_misc_CalcScanCellsMinMax` (`misc.script:2448`). §2. Engine builtins, method-caveated |
| P7 | Zero-hit live-gate census (script tree, this worker) | EV-VETO-CENSUS: `capture_t/capturet/CaptureProgress/capturecool/capturelock` → 0; `majority/threshold/cooldown/immunit/lockout` → 0; guard-order reads inside `:963-1185` → 0; `protectorsCount` reads outside veto+AI table → 0. §3 |
| P8 | Cadence-driver re-pin `building.inc/nothing.inc:293-326`, `unit.inc/nothing.inc:507-535`, `miscext2.script:2757`, `serial.script:870` | EV-VETO-CAD: `lasttimecheckcapture` is the ONLY capture timer; armed in `Nothing`, never written on the capture path. §3 |
| P9 | Port read-only inspection (no edit) `variant3d/scripts/game.gd:8595-8644`, `data.gd:1573-1595` | EV-VETO-PORT: port veto + AI table + G-09 guard-block order matches §§4-5; `bEasy` string mapping stays `[I]` |

DSL note `[D]` (inherited): donor `not X` on a numeric lvalue is the current-value read, not boolean negation.

---

## 1. (a) Packed-CODE byte search for the veto's names — NEW, byte-proven absence [O-absence, method-caveated]

1.1. Method (read-only, no execution). Literal ripgrep over the donor binary file bytes (`C:\Games\Cossacks 3\cossacks.exe`, 5,768,048 B), one pattern per veto name, `literal=true`. The binary was read as data; no entry point was called, no section was mapped as code by this worker. Ripgrep reports wrapped-binary "line" numbers, NOT file offsets or VAs — this worker therefore claims **no VA and no file offset** for any pattern below. Absence is proven only at the literal-byte level for the exact casings searched; Delphi shortstring length-prefixing, UCS-2 storage, or packing could hide a name without leaving its ASCII bytes (caveat kept verbatim, not smoothed over).

1.2. Results — all zero-hit at the ASCII-literal level [O-absence]:

| # | Literal pattern | Hits in `cossacks.exe` | Donor script-text counterpart (for orientation only, not a binary claim) |
|---|---|---|---|
| B1 | `SearchProtectors` | **0** | `unit.script:4617` definition; `miscext.script:1053`, `unit.script:4750` call sites |
| B2 | `_unit_SearchProtectors` | **0** | same as B1 with unit prefix |
| B3 | `bcapture` | **0** | local `miscext.script:978,1020,1066`; prop `unit.script:469,2096-2097`, `miscext.script:1011,1057` |
| B4 | `protectionradius` | **0** | `gc_gameplay_protectionradius` (`dmscript.global:209`), `...Sqr` (`:219`), reads `:977-note/rx1,1041,1064` |
| B5 | `CheckCapture` | **0** | `_misc_CheckCapture` (`miscext.script:963`), call sites `building.inc/nothing.inc:303,317,320`, `unit.inc/nothing.inc:518,521,524,528,532` |
| B6 | `captureradius` | **0** | `gc_gameplay_captureradius` (`dmscript.global:208`), `...Sqr` (`:218`), reads `:977,1018` |
| B7 | `SearchCapturers` | **0** | `unit.script:4641,4668` definitions; `miscext.script:1004,1006` call sites |
| B8 (control) | `bprotector` | **0** | `unit.script:470,2096,4630,4718,4754` |
| B9 (control) | `ChangePlayer` | **0** | `_misc_ChangePlayer` (`miscext.script:894`), capture call `:1178` |
| B10 (positive control) | `DMScript` | **>0** (engine strings, e.g. `TXDMScript`, `XDMScript`, `DMScript`, serial proc/class tables) | engine class/registration strings, NOT DScript identifiers |

1.3. Reading `[D]`. The zero-hit row (B1-B9) against the positive control (B10) is consistent with the already-established packed-binary finding: `craft.json` records PE x86 32-bit, packed `.bind` section entropy 7.96, and **0 hits for `peasant/pikeman/damage/food/wood/gold/mine/cannon`**; D01 records `CODE VA 0x401000 file 0x400 size 0x4f0da8` with stripped Delphi metadata; D02 is the KNOWN exception that proves the tooling rule (DScript `RandomExt` found in CODE at file offsets `0x209a62/0x209ae5/0x209b31`, VA `0x60a662/0x60a6e5/0x60a731`, via `native_bytes_find` — a tool this worker did not invoke and does not re-claim here). Consequence: **no VA is reported for any veto name by this ticket**; a future `native_bytes_find` pass for `SearchProtectors/bcapture/protectionradius/CheckCapture` remains `[U]`-VETO-BYTE (§6) and must cite tool-reported VAs only (cf. D04's rejected naive `file+0x400000` arithmetic — never convert a grep line number to a VA).

1.4. Non-claim. The zero hits do NOT prove the veto is absent from the binary (the veto's script text is `[O]` in §4 and the engine demonstrably runs it). They prove only that the veto's DScript identifiers are not present as plain ASCII bytes at the searched casings — i.e. the CODE-table-style discovery path yields **nothing new to port** for capture, unlike the RandomExt case. No string address, no pointer scan, and no "hidden veto function" is inferred from this absence.

---

## 2. (b) Native wrappers vs script constants — where the distance comparison REALLY comes from [O]

2.1. Radius sources are SCRIPT constants, not engine state [O] (`dmscript.global`):
- `gc_pixels_to_tile = 53.3333333` (`:172`); `gc_frames_to_time = 0.03125` (`:174`).
- `gc_gameplay_captureblockshotradius = 160/gc_pixels_to_tile` (`:207`); `gc_gameplay_captureradius = 214/gc_pixels_to_tile` (`:208`); `gc_gameplay_protectionradius = 426/gc_pixels_to_tile` (`:209`).
- Squared derivatives, computed once at load: `...captureblockshotradiusSqr` (`:217`), `...captureradiusSqr` (`:218`), `...protectionradiusSqr` (`:219`) — each `radius*radius`.
- Tiles→metres is `×2` (`TILE_M=2`, inherited SKIRMISH-TABLES §3): capture 214 px = 4.0125 tiles = 8.025 m; blockshot 160 px = 3.0 tiles = 6.0 m; protection 426 px = 7.9875 tiles = 15.975 m. Port `data.gd:1573` carries `426.0` with the `:217-219` cite — correct sourcing, no change.
- Scan geometry: `gc_scangrid_size = 4` (`:55`), map `640×640` cells (`:56-59`); cadences `TimeCheckCapture = 0.1*19-eps = 1.875 s`, `TimeCheckCaptureArt = 0.1*5-eps = 0.475 s` (`:1476-1480`, eps `0.025`); `lasttimecheckcapture = Float` TObj field (`:1769`).

2.2. Distance-squared computation is an ENGINE builtin called with script operands — no script-side wrapper exists [O-absence over the script tree]:
- Script text writes `distSqr` twice, identically: capturer arm `px := GetGameObjectPositionXByHandle(goHnd); py := GetGameObjectPositionZByHandle(goHnd); tx := …(trgHnd); ty := …; distSqr := Sqr(px-tx)+Sqr(py-ty)` (reads at `:1013-1016` region; comparison `:1018`), protector arm same shape (`:1059-1063` region; comparison `:1064`). Search procs (`unit.script:4978-5009,5090-5127,5151-5194`) repeat the SAME `Sqr(dx)+Sqr(dz)` idiom for guard/attack scans — the capture path uses the shared engine idiom, not a capture-specific distance routine `[D]`.
- `Sqr`, `floor`, `MaxFloat`/`_misc_MaxFloat`, `GetGameObjectPositionXByHandle/ZByHandle` have **zero `function`/`procedure` definitions** in `data/scripts/**` (P6 probe: only `_misc_CalcScanCellsMinMax` hits at `misc.script:2448`). They are engine-registered DScript builtins (same class as `random/RandomExt/floor` used at `:2757` init and `:420,437` headshot draws). This worker makes NO claim about their float precision, `floor()` of negatives, or `MaxFloat(NaN)` behaviour — that is `[U]`-VETO-WRAP (§6).
- The SOLE script-side scan wrapper on the veto path is `_misc_CalcScanCellsMinMax(x, y, rx1, left, top, right, bottom)` (`misc.script:2446-2448` definition; veto call sites `miscext.script:994,1043`; probe call sites `unit.script:4707,4743`) with `rx1 := floor(gameplay_radius/gc_scangrid_size)+1` (`miscext.script:977` capturer arm, `:1041` protector arm). So the cell window is `floor(214px-tile/4)+1 = floor(4.0125/4)+1 = 2` for capturers and `floor(7.9875/4)+1 = 2` for protectors `[D — arithmetic shown, not a new constant]`. No engine table maps radius→cells; the `+1` is script text.

2.3. Filter law inside the wrappers (script-side, byte-proven) [O]:
- `_unit_SearchProtectors` (`unit.script:4617-4637`): first grid member with `bprotector AND NOT bbuilding AND (myplmask-of-that-unit & passed-enemyplmask)=0` wins; random start `floor(random*count)` (`:4625`); NOTE the `Get(newind)` vs `Get(i)` asymmetry against the capturer proc (protector loop indexes `Get(i)`, capturer loop `Get(newind)` — transcribed verbatim, semantic effect `[U]` inherited, never "fixed").
- `_unit_SearchCapturers` (`:4641-4664`): `NOT bbuilding AND bcancapture AND (myplmask & passed-mask)<>0 AND pl<>mercenaryind` (`:4656`, `gc_player_mercenaryind = MaxPlayerCount-1`, `dmscript.global:776`).
- `_unit_SearchCapturersForWall` (`:4668-4691`): drops `bcancapture` (any non-building enemy unit counts vs walls).
- Prop defaults that feed the filters: `SetObjBuildingBaseSettings` sets `bcancapture := not bcapture; bprotector := False` (`unit.script:461-470`); soldier rows set `bprotector := not bcapture; bcancapture := (not bcapture) and (usage<>peasant)` (`:2096-2097`) — i.e. peasants can never be capturers AND a `bcapture`-flagged unit can never protect (the `:1057` skip is then a second net for races whose rows deviate) `[D]`.

---

## 3. (c) Zero-hit census: exactly ONE live capture gate exists [O-absence composed to law, method-caveated to script text]

3.1. Census table (this worker, `Select-String` over `C:\Games\Cossacks 3\data\scripts\**`, text only — native engine fields not probed):

| # | Probe | Hits | Verdict |
|---|---|---|---|
| C1 | `capture_t\|capturet\|CaptureProgress\|captureprogress` | **0** | No accumulator field exists in script text (confirms EV-CS-NOCAP, STATE §1) |
| C2 | `capturecool\|capture_cool\|capturelock\|capture_lock\|capture_tick` | **0** | No cooldown/lock field exists in script text |
| C3 | `majority\|threshold\|cooldown\|immunit\|lockout` (case-insensitive) | **0** | No majority/threshold/cooldown vocabulary anywhere in donor scripts |
| C4 | `protectorsCount` | 5, ALL inside `_misc_CheckCapture`: decl `:982`, veto increment `:1067`, AI-table reads `:1076-1080` (plus commented `:1075`) | Accumulated but NEVER compared in the general path — read ONLY by the AI-artillery exception `[D]` |
| C5 | `capturerCount` | decl + increment (`:981,:1021` region) + AI-table reads (`:1077-1080`) | Same: counted, never thresholded except inside the AI-artillery rows |
| C6 | `guard` reads inside `miscext.script:963-1185` | **0** (`order_type_guard/GuardOrderCount/bOrderGuard` never occur between `:963` and `:1185`) | A live guard order is invisible to the capture predicate `[O-absence]` |
| C7 | `CheckCapture` call sites | `building.inc/nothing.inc:303,317,320` + `unit.inc/nothing.inc:518,521,524,528,532` + def `:963` + init `:2757(serial 870, initial 320/390)` — and NOWHERE else | Single entry proc, cadence-gated only (§3.2) |
| C8 | `_unit_SearchProtectors` call sites | `miscext.script:1053` (veto) + `unit.script:4750` (`_unit_TestCapture` probe) | The probe (`:4731-4763`) is read-only (`Result` only) — not a gate |
| C9 | `_unit_CheckCapturersStopProduce` call sites | def `:4695` + `doprogressorders.inc:237` (AI production-stop only) | Production-stop arm, never a capture gate |

3.2. The single live gate, restated with byte pins [O]:
- After the capturer scan sets `bcapture := True` (`:1020`), exactly ONE statement on the whole path can set it back: `bcapture := False` at `:1066`, guarded by `not bcapture(prop2)` (`:1057`) + `distSqr < gc_gameplay_protectionradiusSqr` (`:1064`), inside the own-mask cell loop (`:1041-1053`). No second `bcapture := False` exists in `:963-1185` (full-range grep: the only other `bcapture` writes are the `:= True` at `:1020` and the `var` decl `:978`).
- Ancillary writes that look like gates but are NOT: blockshot freeze (`attackmaxdelay/attackdelay := MaxFloat(…,100*frames_to_time)`, `:1036-1040`) delays the victim's shooting, never the next capture test; AI-artillery `essential_death + exit` (`:1082-1085`) kills instead of transferring, and only when the veto already fired (`protectorsCount>0` is a conjunct at `:1076`); `essential_death` at birth (`:1093-1099`) and `bDie` at wall/AI-roll (`:1104-1109,:1143-1173`) are death exits, not vetoes. Post-flip, NOTHING writes `lasttimecheckcapture` — the next test is gated solely by the pre-existing `Nothing`-armed value (`building.inc/nothing.inc:302,315`; `unit.inc/nothing.inc:513,515`) `[D]`. Do NOT port any `capture_cooldown/capture_lock/immunity_t` field.

---

## 4. (d) Byte-proven order: veto vs blockshot vs AI die-roll vs ownership flip [O — asserted ONLY where script-byte order proves it]

Scope of "byte-proven": the claim is the ASCENDING-LINE execution order of `miscext.script:963-1185` as written (straight-line with the noted `if/exit` guards). No runtime trace was taken; the order below is the file-byte order, and each step cites its lines. Anything the file does not order (e.g. engine evaluation order inside one expression) is marked `[U]`.

| Step | Lines | What executes | Gate / effect |
|---|---|---|---|
| 0 | `:970-971` | `bneutral` snapshot | Peacetime/owner pre-gate; `capturePlMask` follows (`:985-989`) |
| 1 | `:977-1028` | Capturer cell scan | `rx1=floor(capture/scangrid)+1`; enemy-mask cells; wall→`ForWall` else `SearchCapturers`; skip `bcapture\|water`; `distSqr<captureSqr → bcapture:=True, capturerCount+1, capturerHnd:=trg`; `distSqr<blockshotSqr → bblockshot:=True`. NO transfer, NO veto yet |
| 2 | `:1031` | `bEasy := aidifficulty<veryhard` snapshot | Read by BOTH AI exits (artillery `:1082`, die rolls `:1143-1173`) |
| 3 | `:1032-1033` `if (bcapture)` opens veto region | Everything 4-5 runs ONLY if a capturer was found | If no capturer, jump to step 9 (still `bcapture=False`) |
| 4a | `:1034-1035` wall-hp gate | `if NOT(wall AND hp<maxhp/3)` opens 4b-5 | Walls under 1/3 hp SKIP blockshot-freeze, protector scan, AND AI-artillery table (fall to birth/hide/flush region with `bcapture` still True) |
| 4b | `:1036-1040` blockshot freeze (**before** the protector scan) | non-peasant target + `bblockshot` → `attackmaxdelay/attackdelay := MaxFloat(…,100*gc_frames_to_time = 3.125 s)` | Victim-fire delay ONLY. Proven non-veto: it never writes `bcapture`, `capturerHnd`, or any counter; the scan continues to step 5 regardless `[D]` |
| 5 | `:1041-1072` protector scan + THE veto | `rx1=floor(protection/scangrid)+1`; own-mask cells; `_unit_SearchProtectors`; skip `bcapture` units (`:1057`); `distSqr<protectionSqr → bcapture:=False + protectorsCount+=1` | The ONLY `bcapture:=False` on the path. One in-radius non-`bcapture` protector outvotes ANY `capturerCount` (no comparison here) |
| 6 | `:1073-1088` AI-artillery suicide table (**after** the veto) | ONLY if owner-`bAI` AND target-`bartillery` (and step-4a passed): `(prot=1 AND cap>=prot) OR (prot=2 AND cap>3) OR (prot=3 AND cap>7) OR (prot=4 AND cap>10)` → `if (not bEasy) or (random>0.5) → essential_death, exit` | Death exit, never a transfer; `prot>=5` has NO row (falls through with `bcapture` already False) `[D]` |
| 7 | `:1091-1099` birth gate (`if bcapture` re-tested) | non-building + `essential_birth` + hide-UNSET → `essential_death, exit` | Hidden birth units skip to step 8 (never `ChangePlayer`'d here) |
| 8 | `:1100-1134` hide gate + flush | `visual_hide<>0` on a non-building → `_unit_Stop`, skip to step 9-exit path; buildings/non-`none` run the 12-slot produce/upgrade flush (`:1116-1130`), `ClearOrders` (`:1132`), `SetSTO(0)` (`:1133`) | Flush runs BEFORE `newPlHnd` is read (`:1136`) and BEFORE the swap (`:1178`) — refunds pay the LOSER (FLUSH report owns the semantics) |
| 9 | `:1136-1182` alarm → AI die rolls → flip | `newPlHnd` from `capturerHnd` (`:1136`); IO-party alarm pre-flip (`:1139-1140`); owner-AI building `random>0.25→bDie` else slow-death `1999-floor(RandomExt*300)`; non-building peasant/artillery/peasant rolls (`:1155-1173`); `bDie ? essential_death : _misc_ChangePlayer(go,newPlHnd,True,False,True)` (`:1175-1178`) | Ownership flip is LAST. `ChangePlayer` (explicit `True,False,True` = bCapture,bCustom,blan) performs the strip+swap+insider pipeline (`:894-959`, STATE §§3-4) |

Explicitly NOT ordered by this ticket (byte order exists but execution interleaving is engine-side): the relative evaluation order of `distSqr<…Sqr` vs the `GetGameObjectPosition*` calls within one iteration (single expression chain, no sequence point claimed); the per-cell visit order of the `for i/cellx..cellxmax` loops beyond ascending index text (engine may tile-schedule); which of several in-radius protectors `SearchProtectors` returns first (random-start `floor(random*count)` — outcome-equivalent since ANY hit vetoes, but the RETURNED handle is a die roll) `[U]`-VETO-ORDER-RND (§6).

---

## 5. Port placement (read-only inspection, no edit — owner/COORD applies)

- Veto position is CORRECT in the port: `game.gd:8595-8607` scans same-side non-`bcapture` units within `DONOR_PROTECTION_PX`-derived metres and sets `capturer = -1` (ANY-protector veto), with the `:1041-1072 + :4617-4637` cites and the no-count/no-usage note. No change.
- AI-artillery table is CORRECT as a call shape: `game.gd:8608-8624` via `C3Data.donor_capture_ai_art_suicide` (`data.gd:1591-1595`) + `(not bEasy or random>0.5)` + `_kill` death exit, AFTER the veto. ONLY OPEN GAP stays the `[I]` `bEasy` mapping (donor `aidifficulty<veryhard` 4+-step enum vs port `AI_DIFFICULTY=="easy"` string) — owned by `[U]`-CS-VETO, not redefined here.
- G-09 guard-block stays EXACTLY where it is: `game.gd:8625-8644`, AFTER the donor veto and the AI death exit, with the full `miscext.script:963-1185 never reads order_type_guard / GuardOrderCount` comment + `_unit_OrderGuard (unit.script:5608-5615)` + `_player_OrderUnitsToGuard (player.script:2399-2444, 3 nearest, bcapture-excluded, cap gc_MaxGuardOrderCount=2)` cites. It is labelled `PORT RULE G-09 (RB_MECHANICS S5) … NO DONOR COUNTERPART … NEVER merged into it`. KEEP labelled; never cite a donor line for it; never move it before the veto.
- No port change in this ticket adds, removes, or reorders any capture gate, timer, threshold, or majority. The change list is intentionally EMPTY beyond the standing CS-VETO/CS-LEDGER/CS-GARRISON/CS-HIDE/CS-FOW/CS-RALLY items (STATE/STATE2 §7).

---

## 6. Still-[U] register — each with a fixed-seed capture transect + zero-mismatch termination

Conventions (owner-authorised; binary run by owner, never this worker): fixed seed S, fixed map, fixed nation pair, full stock unless the capture varies cost. Instrumented owner build dumps donor `TObj.{pl,bbuilt,bdead,statetag,insideofuid,STO,scangridx/y,lasttimecheckcapture,attackdelay,attackmaxdelay}` + `orders[0..11].{iType,produceid,upgradeid,amount,progress}` + `gPlayer[loser/winner].{counter.*,scores,res[],resincome[],artlimit,artcount,stat.produced/killed}` + `gScanGrid` membership + `_unit_GetVision` + minimap presence per Nothing tick across the capture tick. Wall-clock IRRELEVANT. Three identical-seed runs; ANY inter-run divergence FAILS the item (quote the divergent dump, do not average). Behavioural items below never override the `[O]` static law above — they confirm the engine executes the byte order in §4.

| # | Item | Static state after this ticket | Exact experiment |
|---|---|---|---|
| U-VETO-BYTE | Packed-CODE name census completeness | ASCII-literal zero hits `[O-absence]` §1; VAs UNCLAIMED | Owner runs `native_bytes_find` (or equivalent) for `SearchProtectors/bcapture/protectionradius/CheckCapture/captureradius` + Delphi-shortstring/case variants. **Zero-mismatch:** report tool-reported VAs-or-absence with evidence ids; if a VA lands, confirm its section is CODE and its xref count (0 vs N) without executing. Until then, no binary-side veto claim. |
| U-VETO-WRAP | Engine float/builtin semantics of the comparison | Operands + `Sqr` idiom + `Sqr`-derivative constants `[O]` §2; `Sqr/floor/MaxFloat/GetGameObjectPosition*` internals `[U]` | Seed S: place capturer/protector pairs at EXACT script-boundary distances (distSqr == radiusSqr within 1e-9, protector at `protectionSqr ± epsilon`, capturer at `captureSqr ± epsilon`, non-peasant at `blockshotSqr ± epsilon`). Dump `distSqr` (owner-build float print, full precision), taken/not-taken branch, `attackdelay/attackmaxdelay` after blockshot arm. **Zero-mismatch:** 3 runs identical; assert strict-`<` (equal does NOT trigger), freeze = exactly `100*0.03125 = 3.125 s` via `MaxFloat`, no `bcapture` write from the freeze arm. |
| U-VETO-CENSUS | No second live gate (engine-side confirmation of §3) | Script-tree zero hits `[O-absence]` §3; engine-side fields `[U]` | Seed S ×3 sub-cases, all with 1 capturer in radius, `default` mode: (a) 0 protectors + live `guard` order on victim → expect FLIP (guard invisible); (b) 1 protector + 5 capturers → expect HOLD (`bcapture=False`, `protectorsCount=1`); (c) post-flip immediate re-test: hold a second enemy unit in radius, dump ticks to re-flip → expect re-test at next pre-armed `lasttimecheckcapture` with NO extra lockout. **Zero-mismatch:** 3 runs identical each; any guard-block, count-comparison, or lockout FAILS. |
| U-VETO-ORDER | Runtime order veto→blockshot→AI-roll→flip + rnd-start equivalence | File-byte order `[O]` §4; loop schedule + rnd-start handle identity `[U]` | Seed S ×2: (a) non-peasant victim + `bblockshot` + 1 in-radius protector → assert BOTH `attackdelay=3.125 s` written AND `bcapture=False` held (freeze does not pre-empt veto, veto does not pre-empt freeze — independent writes, same tick); (b) AI-owned artillery, `prot=2/cap=5`, `not bEasy`: run 3×N ticks, dump which protector handle `SearchProtectors` returned per tick (expect rotation via `floor(random*count)` start) with IDENTICAL veto outcome every tick. **Zero-mismatch:** 3 runs identical per sub-case; quote returned handles to prove outcome-independence of rnd-start. |

Inherited open items (owned by prior tickets, not redefined here): CS-PROGRESS (behaviour), CS-COOLDOWN (behaviour), CS-TRANSFER/CS-LEDGER (values), CS-GARRISON, CS-HIDE(c), CS-FOW (engine), CS-RALLY — see CAPTURE-STATE §6 / STATE2 §6 for their transects. No item in this ticket closes them.

---

## 7. Explicit non-claims and file discipline

- NO PARITY CLAIM. Static law (§§2-4) rests on donor TEXT `[O]` with `file:line`; every engine-internal (float semantics, string-table packing, loop scheduling) and every behavioural confirmation (§6) stays `[U]` until its three runs match with the divergent dump quoted, not averaged.
- No number invented: 214/160/426 px, `Sqr` derivatives, scangrid 4, `0.03125`, `1.875/0.475 s`, `3.125 s`, `1999/300`, `5/3/2/1` scores, `20+4V`, absorber 5 / transport 120, `inside=4`, `MaxOrderCount=12`, `MaxGuardOrderCount=2` — all donor literals with lines. Port `guard-block`, `captured_nations`, tower garrison, `1×` score, `_default_rally` re-arm stay PORT rules, labelled, never donor-cited.
- No new veto, threshold, majority, cooldown, immunity, or lockout is asserted anywhere in this report; §§1/3 positively close those against the donor script text (engine-side fields explicitly excluded from the closure).
- Read-only compliance: exactly one repo file written (this report). All donor evidence is text reads plus read-only literal scans of the binary file bytes (never executed, never copied, never opened as a target); no source/asset/config/test/runner/Godot/git state changed. `progress.inc` was NOT re-read (ACL method-caveat inherited from FLUSH §6; cadence law inherited from STATE/STATE2, not re-audited — no new progress.inc literal claimed).

*End of DEC-U-CAPTURE-VETO-DEEP.*
