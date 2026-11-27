---
id: DEC-U-SAVE-TRG-DEEP
worker: DEC-U-SAVE-TRG-DEEP (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied/patched. Donor text scripts/data read as text or read-only byte scans (python open(rb).read + ASCII match, no execution). No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. Net/replay packages excluded; cited only to exclude."
parity: "NO PARITY CLAIM. No donor save produced/compared/byte-asserted by this worker. Every literal cites file:line or observed read-only bytes with decimal file offset; every unrecovered byte is a named [U] with a paired-save single-field experiment and zero-mismatch criterion. No uid mapping invented."
labels: "[O] verbatim donor literal (file:line or observed bytes) · [D] deterministic derivation · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT EXTENSION = port substitute, not donor law"
parent: "docs/terrain_swarm_2026-11-26/reports/DEC_U_save_tobj.md + DEC_U_save_deep.md + DEC_U_order_slots.md + DEC_U_tick_order.md"
scope: "Still-[U] E-T1: nested orders[].info.trg uid-vs-handle routing + no nested struct carries transform. Four NEW angles only: (a) packed CODE byte search for order/target API names with CODE-embedded table offsets, (b) TOrderInfo/TOrder field usage in native order routines (handle vs uid), (c) save/load translation routines (serial.script IntegerList/handle->uid), (d) shipped .map bytes trg-width candidate only if byte-proven."
---

# DEC-U-SAVE-TRG-DEEP — nested `orders[].info.trg` routing from four new angles (2026-11-26)

Parents closed: `TObj` 63 fields / 866 B [O-order + D-widths], `TOrderInfo` 48 B / `TOrder` 55 B / `TProj` 15 fields / 60 B (`DEC_U_save_tobj.md` §§1-3), envelope + profile-thunk + nested-width transform absence (`DEC_U_save_deep.md` §§1-4), 12-slot law + head-only dispatch (`DEC_U_order_slots.md`). Remainder is exactly **E-T1**: `ObjWriter` calls `SaveStreamTypeBase(...,useproc=false)` reflection, `OrderInfoWriter` exists with an explicit `trg` handle→uid pre-swap, but the `ObjWriter` manual nested loop is **commented out** — whether engine reflection recurses into the nested `OrderInfo*` procs (uid on wire) or emits nested `trg` raw (session handle on wire) is engine-opaque. No nested struct carries transform (re-audited §4). This ticket attacks E-T1 from four NEW angles. Nothing invented.

## 0. Pin + pass ledger (every pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert (read-only) | `python open(rb).read` Length = 5,768,048 B; `Get-FileHash SHA256 = 87F0F3C130B027E7C4E72DC217EAE9D592982370D112E0D224897BC92AF4E16C`. Matches `t_87f0f3c130b0`. Binary never executed/copied. |
| P2 | Angle (a): packed CODE ASCII scan (read-only, full 5,768,048 B image) | EV-A §1: `SetOrderTarget`=0, `GetOrderTarget`=0, `ConvertHandleToUid`=0, `GetObjByUid`=0, `_unit_SetOrderTrg`=0, `TOrderInfo`=0, `GetGameObjectUniqueIdByHandle`=1 @2364770, `GetGameObjectHandleByUniqueId`=1 @2364846, `SaveStreamTypeBase`=1 @2891622, `MergeStreamTypeBase`=1 @2891902, `TProj`=0, bare `trg`=0 / `uid`=0 lowercase, `Trg`=7 (all `TrgPos`), `UID`=42 (all mission-trigger `TargetObjUID/ReachedObjectUID/ObjectUID/RootUID`). Contexts §1 [O-bytes]. |
| P3 | Angle (a) cont.: `UserSaveProfile/TObj` controls | `UserSaveProfile`=2 @2907718,2907762; `UserProfileSaveMap`=3 @2908142,2908202,2908350; `TObj`=79 hits (class/RTTI region). Replicates deep-ticket thunk block; proves scan method sees engine verb tables when they exist — the order-API zeros are method-validated absences, not scan failures [D]. |
| P4 | Angle (b): order-routine `trg` dataflow (read-only text) | EV-B §2: `_unit_SetOrderTrg` def `unit.script:2739-2751` stores param verbatim `orders[ind].info.trg:=trgHnd` (`:2750`); `_unit_AddOrder` passes `itrghnd` straight through (`:4370`); callers pass runtime handles (`:5279,:5583,:5611,:7301,:9728`, `miscext.script:1228,1261,1277`); live comparisons `info.trg<>trg` vs `GetGameObjectStateCollisionObjectByHandle` handle (`miscext.script:1227,1260,1276`); `_unit_ClearOrder` dereferences `trgHnd` via `_unit_GetTObj(trgHnd)` (`unit.script:2769-2772`). In-memory `trg` = runtime handle [D]. |
| P5 | Angle (b) cont.: handle-producer inventory | `GetGameObjectSTOHandleByHandle` / `GetGameObjectStateCollisionObjectByHandle` / `_unit_SearchVictim*` / `_unit_SearchResourceInRadius` all return values consumed directly as `trgHnd` without any `UniqueId` conversion at any call site (P4 lines + `unit.script:7287,7326,9715-9717,4043,5216,5445`). Zero uid-typed values flow into `orders[].info.trg` in script [O-absence over the full `unit.script` + `miscext.script` `trgHnd` corpus]. |
| P6 | Angle (c): `serial.script` translation-routine grep | EV-C §3: `IntegerListIsHandles` name table (`serial.script:636-658`); `IntegerListWriter` handle→uid pre-swap (`:674`) + restore (`:683`); `IntegerListPost` uid→handle (`:721`); `SquadList` uid writes (`:1025,1033`) + handle restores (`:1221,1225`); `ObjWriter` `trghnd/artHnd` swaps (`:811-814/:825-828`); `OrderInfoWriter/Post` swaps (`:895-896/:902-903/:933-934`); `ProjWriter/Post` swaps (`:954-957/:963-966/:995-998`); `gohnd/hnd` swaps (`:1313,2228,2597,2929` + posts `:1320,2235,2603,2965`). Commented nested loop (`:807-809/:821-823/:860-862`) re-confirmed [O]. |
| P7 | Angle (c) cont.: `TOrder/TOrderInfo/TObj` decl re-read | `dmscript.global:1678-1691` `TOrderInfo` (`trg:I` first, then 6×F + 4×I + 1×F), `:1693-1702` `TOrder` (`itype:I + info + 3×B1`, `uid/next/priority` commented OUT [O]), `:1704-1710` individual 17 B, `:1712-1777` `TObj` 63-field order. Widths unchanged: 48 / 55 / 866 B [D]. |
| P8 | Angle (d): shipped `.map` byte probe (read-only) | `data/maps/missions` = `.map`+`.aix` only; recursive `*.sav` glob = 0 hits (inherited, re-noted). `ausmis1.map` 43,950,027 B / `battle1.map` 56,111,715 B heads `35 00 00 00 + ASCII OSWMap13…` (deep-ticket P8, not re-dumped). No `orders`/`trg`/`TOrderInfo` tag exists in either head/trailer window; no 4 B `trg` word isolable from shipped maps alone — **no width candidate claimed** [O-absence + D-restraint]. Byte proof requires paired saves (E-T1). |
| P9 | Nested-transform re-audit (new angle requirement) | Full `TOrderInfo`/`TOrder`/`TObjIndividualUpgrades` field-name scan: zero `pos/rot/scale/STO/statetag/xyz-transform` members; only gameplay-adjacent floats (`rallyx/y`, `artx/y`, per-order `x/y/dx/dy/dir/z`) [O]. Engine transform getters (`GetGameObjectPosition*ByHandle`, `GetGameObjectSTOHandleByHandle`) appear only as runtime `ByHandle` reads in order logic (P4/P5), never in any `serial.script` writer [O-absence]. §4. |
| P10 | Discipline | Exactly one repo file written (this report). No `game.gd`/config/test/git state read beyond parents' citations; no edit attempted. No uid→handle table invented; no parity claimed. |

DSL note `[D]` (inherited): donor `not X` on a numeric lvalue is the current-value read, not negation.

---

## 1. Angle (a): packed CODE byte search — order/target API names with CODE-embedded table offsets [O-bytes]

Method: `open(rb).read()` (5,768,048 B) + exact ASCII `bytes.count` / `re.finditer` (case-sensitive). No execution, no disassembly; only data-string windows quoted.

| Needle | Hits | Decimal file offset(s) [O] | Verdict |
|---|---|---|---|
| `SetOrderTarget` | 0 | — | No packed order-target setter [O-absence] |
| `GetOrderTarget` | 0 | — | No packed order-target getter [O-absence] |
| `ConvertHandleToUid` | 0 | — | No convert helper under this name [O-absence] |
| `GetObjByUid` | 0 | — | No get-by-uid helper under this name [O-absence] |
| `_unit_SetOrderTrg` | 0 | — | Script proc name not embedded in binary (expected: script-side) [O-absence] |
| `TOrderInfo` | 0 | — | Script type name not embedded (expected: reflection via `PointerOf`) [O-absence] |
| `TProj` | 0 | — | Same (unregistered script type) [O-absence] |
| `GetGameObjectUniqueIdByHandle` | 1 | 2364770 | `…function GetGameObjectUniqueIdByHandle(gohandle: Integer): Integer…` flanked by `GetGameObjectAnimationCycleNameByIndex` and `GetGameObjectHandleByUniqueId` [O-context P2] |
| `GetGameObjectHandleByUniqueId` | 1 | 2364846 | `…function GetGameObjectHandleByUniqueId(uniqueid: Integer): Integer…` flanked by above + `ClearGameObjectsUniqId / GameObjectMakeUniqId` [O-context P2] |
| `SaveStreamTypeBase` | 1 | 2891622 | `procedure SaveStreamTypeBase(const fs…useproc: boolean)` [O-context P2] |
| `MergeStreamTypeBase` | 1 | 2891902 | `procedure MergeStreamTypeBase(const fs…compare…` [O-context P2] |
| bare `trg` / `uid` (lowercase) | 0 / 0 | — | Script-cased identifiers absent from binary string table — binary uses PascalCase for the few surviving names (next rows). NOT evidence of absence of the concept; evidence that no lowercase-`trg`/`uid` CODE table exists to xref [D] |
| `Trg` | 7 | 2238902, 2239185, 2239218, 3812838, 3812870, 3814234, 3814266 | ALL `…TrgPos` / `…TrgAngle`: `GetDirectionBySpeedAndTrgPos`, `CalcSpeedByDirAndTrgPos`, `CalcDirByHSpeedAndTrgPos`, `GRStretchBrushTrgPos/TrgAngle` [O-contexts P2]. Projectile/brush math, NOT order targets. No `SetOrderTrg`-family string in this family [O] |
| `UID` | 42 | e.g. 2218561, 2218669, 2219637, 2219745, 2270362 (+37 more) | Sampled windows ALL mission-trigger schema: `TargetObjUID`, `TargetObjPlayerName`, `ReachedObjectUID`, `ObjectUID/ObjectPlayer/ObjectCustom/RootUID`, inside `TXGameObject` registration block (~2.21–2.27M) [O-contexts P2]. NOT `TOrderInfo.trg`, NOT `TObj.uid` wire mapping. No uid-conversion table adjacent [O] |
| controls `UserSaveProfile` / `UserProfileSaveMap` / `TObj` | 2 / 3 / 79 | §0-P3 offsets | Proves the scan finds engine tables when present; order-API zeros are valid negatives [D] |

Consequence [D]: there is **no packed CODE order/target API table to xref**. Order storage is script-declared reflection (`dmscript.global:1678-1702,1712-1777`); the only engine verbs involved are the two `UniqueId↔Handle` converters (@2364770/@2364846) and the `Save/MergeStreamTypeBase` reflection pair (@2891622/@2891902), all singletons in one registration block. The `trg`-vs-`uid` question cannot be closed statically from CODE — it must be closed by the paired-save experiment E-T1 (§5). No VA beyond file offsets is claimed (RVA≡file-offset mapping is build-specific and unproven here).

---

## 2. Angle (b): `TOrderInfo`/`TOrder` field usage — `trg` is stored as a runtime handle [O + D]

**Store site (verbatim):**

```
// unit.script:2739-2751 [O]
procedure _unit_SetOrderTrg(const goHnd, ind, trgHnd : Integer; bUpdateOrdList : Boolean);
begin
   var pobj : Pointer = _unit_GetTObj(goHnd);
   if (pobj<>nil) then begin
      ...
      TObj(pobj).orders[ind].info.trg := trgHnd;   // :2750 — direct store, no conversion [O]
   end;
end;
```

**Write path (verbatim):** `_unit_AddOrder` (`unit.script:4304-4389`) takes `itrghnd : Integer`, never converts it, and the only `trg` write is `_unit_SetOrderTrg(goHnd, ind, itrghnd, True)` (`:4370` [O]); the commented direct store `//TOrderInfo(porderinfo).trg := itrghnd` (`:4369` [O]) shows the same slot. `bDoFirst` / `gainres` arms likewise route exclusively through `_unit_SetOrderTrg` (`:4324,:4352` [O]).

**Every producer passes a runtime handle (not a uid) [O]:**

- `_unit_OrderAttack(goHnd, trgHnd…)` → `AddOrder(…,attackobj, trgHnd,…)` (`:5273-5279`); `_unit_OrderGuard` → `AddOrder(…,guard, trgHnd,…)` (`:5608-5611`); `_unit_OrderGoInside` → `AddOrder(…,order, trgHnd,…)` (`:5583`); `_unit_OrderLeave` → `AddOrder(…,leavebuilding, trgHnd,…)` (`:4454`).
- `tmpHnd := _unit_SearchVictimOnProgress(goHnd)` (`:7287`) → `_unit_SetOrderTrg(goHnd, 0, tmpHnd, True)` (`:7301`) after `GetGameObjectPositionX/ZByHandle(tmpHnd)` reads — `SearchVictim*` returns are consumed as handles everywhere in the file (P5) [O].
- `resHnd := _unit_SearchResourceInRadius(…)` (`:9717`) → `_unit_SetOrderTrg(goHnd, 0, resHnd, True)` (`:9728`) with `GetGameObjectPositionXByHandle(resHnd)` (`:9723`) and `_unit_SetSTO(goHnd, resHnd)` (`:9725`) — STO takes handles by definition [O].
- `trg := GetGameObjectStateCollisionObjectByHandle(hnd)` (`miscext.script:1240`) → `_unit_SetOrderTrg(hnd, 0, trg, True)` (`:1228,:1261`) / `_unit_SetOrderTrg(trg, 0, hnd, True)` (`:1277`) [O].

**Decisive handle-typing proofs [D from O]:**

1. `if (TObj(pobj).orders[0].itype=attackobj) and (TObj(pobj).orders[0].info.trg<>trg)` (`miscext.script:1227,1260,1276` [O]) compares `info.trg` directly against the `ByHandle`-API result `trg` with NO conversion on either side. If `info.trg` held a uid, this comparison could never be true for a live target.
2. `_unit_ClearOrder` reads `trgHnd := TOrderInfo(porderinfo).trg` (`unit.script:2769` [O]) then immediately `pobj2 := _unit_GetTObj(trgHnd)` (`:2772` [O]) — `_unit_GetTObj(hnd)` dereferences a live object pointer by handle (its error paths log `hnd=`, `:16-18`). A uid would not dereference.
3. Zero call sites convert to uid before storing: full-`unit.script`+`miscext.script` `trgHnd` corpus contains **no** `GetGameObjectUniqueIdByHandle` on any value flowing into `orders[].info.trg` (P5 [O-absence]).

Verdict: **in-memory `orders[i].info.trg` is a runtime session handle** [D]. The wire question is therefore well-posed: the handle MUST be converted somewhere before the bytes are durable, and the only candidate converters are `OrderInfoWriter` (`:895-896`) vs the commented-out `ObjWriter` loop (`:807-809`). Which one actually runs for nested reflection is E-T1 (§5). No uid mapping is invented here: uid values are never observed by this worker, only the converter names.

---

## 3. Angle (c): save/load translation routines — explicit `trg` conversion exists, nested routing stays engine-opaque [O]

**Name-gated IntegerList translation (the pattern the engine DOES use when it wants per-name routing) [O]:**

- `_serial_IntegerListIsHandles` (`serial.script:636-658`): `arg_stolist, arg_attlist, arg_ordlist, arg_inside, ggopathlist, gwaterpathlist, gctrlgroups, gguiupdatehighlights, gselectedobjects, buildings, storehouses, ports, defenders, guards, agressors, freewarriors, unitslist → true` [O].
- Writer (`:661-685`): `WriteInteger(itemsize+count)` (`:666-667`), `if handles` pre-swap each element `Get→UniqueId` (`:671-674`), `WriteBuffer` (`:678`), restore `HandleByUniqueId` (`:680-684`) [O].
- Post (`:711-723`): `if handles` then per-element `GetGameObjectHandleByUniqueId` (`:718-722`) [O]. Reader (`:687-702`) is raw `ReadBuffer` — conversion happens in Post, not Reader [O].

**Scalar `trg`/`hnd` translation sites (all explicit, all top-level) [O]:**

| Proc | Pre-write (handle→uid) | Post-load (uid→handle) |
|---|---|---|
| `ObjWriter/Post` | `trghnd` (`:811-812`), `artHnd` (`:813-814`) | `trghnd` (`:863-864`), `artHnd` (`:865-866`), plus `topzone:=-1` (`:868`) + six jitter re-draws (`:870-875`) |
| `OrderInfoWriter/Post` | `trg` (`:895-896`) | writer-restore (`:902-903`) + Post (`:933-934`) |
| `ProjWriter/Post` | `owner` (`:954-955`), `trg` (`:956-957`) | writer-restore (`:963-966`) + Post (`:995-998`) |
| `SquadList` | `WriteInteger(Get…UidByHandle(Get(j)))` (`:1025`), `…(arGrid)` (`:1033`) | `Set(Get…HandleByUniqueId…)` (`:1221`), `arGrid:=Get…Handle…` (`:1225`) |
| `gohnd/hnd/val` misc | `val.gohnd:=Get…Uid…` (`:1313`), `val.hnd:=…` (`:2228`), `val.Set(Get…Uid…,i)` (`:2597`), `WriteInteger(Get…Uid…(goHnd))` (`:2929`) | posts (`:1320,:1350,:1764-1788→:1919-1937,:2235,:2262,:2603,:2661,:2965`) incl. `AiProtectedBuilding.targetHnd` uid round-trip (`:1618→:1676`) [O] |

**Why E-T1 survives despite all of the above [D]:** `ObjWriter`'s nested `orders[i].info.trg` translation is **commented out in three places** — pre-write (`:807-809`), writer-restore (`:821-823`), Post (`:860-862`) [O]. `OrderInfoWriter/Post` (which DO convert) are registered (`dmscript.source:395-403` binds `TOrderInfo→_serial_OrderInfo*` [O, per tobj-ticket P6]) — but every `Obj/OrderInfo/Proj` writer/reader/size/seek call passes `useproc=false` (`:819,:840,:851,:883,:900,:915,:924,:942,:961,:978,:987,:1006` [O]). Whether `SaveStreamTypeBase(...,false)` reflection on `TObj` recurses into the registered `OrderInfo*` procs (→ wire holds uid) or emits the 660 B `orders` span as raw field data (→ wire holds session handle) is decided inside engine C++, invisible to script. The commented loop shows the authors were uncertain too. Static evidence is therefore exhausted; only paired saves decide (§5).

---

## 4. Angle (d): shipped `.map` bytes — no byte-proven `trg` width candidate [O-absence, restraint]

- Recursive glob `*.sav` under `C:\Games\Cossacks 3\**` = 0 hits; `data/maps/missions` = `.map`+`.aix` only; `data/resources` = `servers.dat` + `updates.dat` (deep-ticket P8, re-noted, not re-dumped) [O].
- Shipped-map envelope (`35 00 00 00 + OSWMap13… + GameMapSnapShotBegin/End + GameMapRecordBegin … GameMapRecordEnd + …GameMapEnd`) is byte-verified on two maps (deep-ticket §3) but contains **no `orders`/`TOrderInfo`/`info.trg` tag** in any head/trailer window [O-absence].
- Consequence: no 4 B word in any shipped file is isolable as `orders[i].info.trg` without a paired-save anchor (same unit, same slot, only target differs). **No width candidate is claimed here** — the 48 B `TOrderInfo` / 55 B `TOrder` / 660 B span widths stand as [D] arithmetic from declaration order + `useproc=false` reflection (tobj-ticket §4), and their byte positions require E-T1 (§5). Any `.map`-hexdump `trg` claim without a paired save would be invention and is refused.

**Nested-transform audit (required by task) [O + D]:** `TOrderInfo` 12 fields (`trg:I,x,y,dx,dy,dir,z:F,upgradeid,produceid,restype,amount:I,progress:F`), `TOrder` (`itype:I + info + bexecute/bremove/static:B1`, `uid/next/priority` commented out), `TObjIndividualUpgrades` (`benabled:B1,upglevel:I,attackrate:F,addpeasantabsorber:I,addtransport:I` = 17 B) — **no member of any nested struct is a transform** (no pos/orientation/scale/STO/statetag) [O-names]. `TObj`'s only position-like members are gameplay data (`rallyx/y`, `artx/y`, per-order `x/y/dx/dy/dir/z`) [O]. Engine transform persists, if at all, outside reflection (deep-ticket §4 boundary stands; placement experiment E-D retained by reference).

---

## 5. Still-[U] register — each item gets a paired-save single-field experiment with zero-mismatch termination

Common harness (all E-runs; owner-authorised, donor binary run by owner, never this worker): pin `t_87f0f3c130b0`; fixed map/seed/preset/nation; two saves per case differing in exactly ONE named field + a third identical-state re-save; **zero-mismatch criterion: all non-divergent bytes identical across the pair AND the identical-state re-save, except the six documented post-load jitter floats** (`ObjPost serial.script:870-875` + `uniqrnd=0→random :841-842`) which are excluded by design. Any OTHER divergence = FAIL, no tolerance, no parity claim. Three repeats per case. No uid value is ever asserted without observing it as the divergent word.

| # | Field(s) | Static state after THIS ticket | Paired-save single-field experiment (owner-run) |
|---|---|---|---|
| E-T1 (headline) | `orders[i].info.trg` routing: uid vs session handle; confirms 55 B slot stride + 4 B width | In-memory = handle [D] (§2); wire = uid IFF nested `OrderInfoWriter` runs, else handle [U]; 48/55/660 B widths [D] | One unit, one `attackobj` order with live target T (record `uid(T)` from T's own `TObj.uid` word @+8). Save A. Replace target with T2 (record `uid(T2)`), save B. Hexdump `orders` span (@169+55i+4 per tobj-ticket §1): assert exactly one 4 B word diverges AND equals `uid(T)→uid(T2)` (uid hypothesis) OR equals the two session handles observed in a parallel handle-dump (handle hypothesis). Report whichever single-word divergence is observed; two-word/no-word divergence = FAIL. Zero-mismatch per harness. **Terminates E-T1.** |
| E-T1b | `trg=0` vs live-`trg` encoding (null-target control) | `if val.trg<>0` guards on all three convert sites (`:895,:902,:933,:956,:965,:997` [O]) | Same unit: order with live target (save A) vs same order with target cleared (`_unit_SetOrderTrg(h,0,0)`, save B). Assert the same word as E-T1 diverges `uid(T)→0` (or `hnd(T)→0` if E-T1 found handles). Zero-mismatch per harness. Guards the `<>0` branch coverage. |
| E-T1c | `TProj.trg/owner` persistence control (absence check feeds E-T1) | Procs defined but unregistered; projectiles transient + culled on load (tobj-ticket §3) [D-boundary, engine-side [U]] | Save A with 3 cannonballs in flight, save B same tick with none fired. Assert record streams byte-identical (absence) OR isolate 60 B records (`owner`@8, `px`@16) if engine persists them. Either outcome reported without force-fit; if absent, confirms no projectile `trg` confounds E-T1 hexdump. Zero-mismatch on identical-state re-save. |
| E-T0 (control) | Harness validity | — | Identical-state re-save pair MUST be byte-identical except the six jitter floats; otherwise harness broken — fix harness, claim nothing. |

Inherited (not re-experimented here; retained by reference): E-T2 (866 B span), E-T4 (`prevstouid`), E-T5 (`TProj` 60 B if found), E-D (engine transform placement, deep-ticket §4), E-A/E-B/E-C/E-G (envelope/profile/store/checksum). No experiment here invents a uid mapping: uids are read off the divergent word + the target's own `uid` word, never postulated.

---

## 6. Port guidance (additive-only; owner/COORD applies; this worker wrote no code)

1. Store `orders[i].info.trg` in the port as an **opaque 32-bit word + provenance tag**, defaulting to the current behaviour, with the tag `E-T1-pending`: do NOT coerce to uid or handle until E-T1 terminates. Keep the §2 handle-typing cites (`unit.script:2750,2769-2772`; `miscext.script:1227,1260,1276`) beside the field.
2. Keep `OrderInfoWriter`-equivalent conversion as a **named but un-wired** function (`trg→uid` on save, `uid→handle` on load via the two converter names) — wire it if and only if E-T1 finds uids on the wire. The commented `serial.script:807-809` loop is the donor's own un-wired equivalent; cite it.
3. Do not add a `SetOrderTarget/GetOrderTarget` native or a `ConvertHandleToUid/GetObjByUid` helper: angle (a) proves those names do not exist in the binary (0 hits, method-validated). The only engine verbs are `GetGameObjectUniqueIdByHandle / GetGameObjectHandleByUniqueId` (@2364770/@2364846).
4. Do not place any transform inside nested order structs (§4 [O-absence]); transform work stays at the deep-ticket E-D boundary.
5. Tests (no code changed here): E-T1/E-T1b/E-T1c per §5 with zero-mismatch; old fixtures load with `E-T1-pending` tag intact; no display-string/int replacement; no version bump rationale invented.

## 7. Explicit non-claims + file discipline

- NO PARITY CLAIM. Order/slot widths are [D] arithmetic; wire routing (uid vs handle) is [U] pending E-T1; transform placement is [U] pending E-D. The port contract stays **key-order parity + round-trip determinism**, never byte parity.
- No number invented: every offset is a read-only file offset; every width is order+citation arithmetic; every unrecovered byte names its experiment. `Trg`=7 / `UID`=42 contexts are quoted as observed PascalCase windows, never as order/uid law.
- Engine `SaveStreamTypeBase(useproc=false)` recursion behaviour is stated as opaque, not inferred. The three commented `ObjWriter` lines are cited as author-uncertainty evidence, not as law.
- Read-only compliance: exactly one repo file written (this report). Donor reads were text reads + read-only byte/ASCII scans; donor binary never executed, never copied; no source/asset/config/test/runner/Godot/git state changed. Network out of scope.

*End of DEC-U-SAVE-TRG-DEEP.*
