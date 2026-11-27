---
id: DEC-U-SAVE-TOBJ
worker: DEC-U-SAVE-TOBJ (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied. Donor text scripts read as text only (Get-Content / Select-String). No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. Net/replay packages (RecordCustom write*/read*) are cited only to exclude them from the save contract (DEC_U_save_contract.md sect.6)."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed; no donor save written by this worker. Nothing invented: every field cites file:line; every ungated-by-static byte names a paired-save experiment with a zero-mismatch criterion."
labels: "[O] verbatim donor literal (file:line or observed bytes) · [D] deterministic derivation from observations · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT EXTENSION = port substitute, not donor law"
parent: "docs/terrain_swarm_2026-11-26/reports/DEC_U_save_contract.md + DEC_U_save_float.md + DEC_U_save_bits.md"
scope: "Still-[U] item [U]-R1f: full TObj field order/writer sites (transform placement engine-owned) + TProj (classes.script:4351-4367 previously only partially transcribed)."
---

# DEC-U-SAVE-TOBJ — exact TObj/TProj record order, widths, version gates (2026-11-26)

Parents closed: 19-section order + primitive widths (`DEC_U_save_contract.md`),
Float 4 B single [D] + String I32+ANSI [D] + victorystate table [O]
(`DEC_U_save_float.md`), Boolean 1 B `0/1` sequential [D] + `.sav`-is-`.map` [D]
(`DEC_U_save_bits.md`). This ticket closes the remaining record-level gap:
the complete `serialized:` emitter set for `TObj` and `TProj`, including the
`player.script` writer-site audit and the native `TSWriter` wrapper question.

## 0. Pin + pass ledger (every pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert (read-only, no execution) | `Get-FileHash cossacks.exe` = `87F0F3C130B027E7C4E72DC217EAE9D592982370D112E0D224897BC92AF4E16C`, `Get-Item Length` = 5,768,048 B, PE32 x86. Matches parent EV-PIN and contract `§0-P1`. Binary never executed/copied. |
| P2 | `serial.script:21-58` header re-read | `gDataVersion:=92` (`:26`), `WriteInteger(fs, gDataVersion)` (`:36`), `ReadInteger(fs, gSerialVersion)` (`:57`). Stream opens with one LE Int32 version word [O]. Line numbers 0-based-shifted by one vs contract (`:27-28/:37/:58`); same literals. |
| P3 | TObj emitter block `serial.script:797-884` read | EV-T1: `_serial_ObjWriter` (`:803-829`), `_serial_ObjReader` (`:833-843`), `_serial_ObjSize` (`:847-852`), `_serial_ObjPost` (`:856-876`), `_serial_ObjSeek` (`:880-884`). Full text in §1. |
| P4 | TOrderInfo emitter block `serial.script:886-943` read | EV-T2: Writer (`:892-904`), Reader (`:908-916`), Size (`:920-925`), Post (`:929-935`), Seek (`:939-943`). Full text in §2. |
| P5 | TProj emitter block `serial.script:945-1007` read | EV-T3: Writer (`:951-967`), Reader (`:971-979`), Size (`:983-988`), Post (`:992-999`), Seek (`:1003-1007`). Full text in §3. Zero `gSerialVersion` gates in the whole `:945-1007` range [O-absence]. |
| P6 | `dmscript.source:337-357` + `:358-548` registry re-read | EV-T4: 19-section `serialized:` order unchanged (contract §1). `serialproc` registry binds `TObj`→`_serial_Obj*` (`:386-394`), `TOrderInfo`→`_serial_OrderInfo*` (`:395-403`); there is **NO registry entry for `TProj`** [O-absence] — the 22-entry registry runs `TPlayerArgs…TWriteNewRequest` with no `type = TProj` block. `TPlayer` and `TWriteNewRequest` have empty serproc/unsproc/sizproc/seekproc + `over = False` (`:449-457`, `:539-547`) = generic reflection. |
| P7 | `dmscript.global:1678-1777` struct re-read | EV-T5: `TOrderInfo` (`:1678-1691`), `TOrder` (`:1693-1702`), `TObjIndividualUpgrades` (`:1704-1710`), `TObj` (`:1712-1777`). Verbatim order in §1. `gc_obj_MaxOrderCount = 12` (`dmscript.global:113` per contract; re-confirmed). |
| P8 | `classes.script:4351-4381` TProj re-read (full transcription) | EV-T6: `type TProj = class … end;` (`:4351-4367`) — 15 fields, verbatim in §3. **This completes the partial transcription** cited in the task (`:4351-4367` previously summarised only). Note verbatim quirk [O]: `:4362` reads `ownerpl : Integer` with NO trailing semicolon (all siblings have one). `TProjSimulatePoint` (`:4369-4375`), `TProjSimulatePoints` (`:4377-4381`, `projsim : array [0..gc_MaxProjSimulatePoints-1]`, `gc_MaxProjSimulatePoints = 2048` per `dmscript.global:124`), `gProjSimulatePoints : TProjSimulatePoints` (`classes.script:7669`) = simulation scratch, never serialized [D]. |
| P9 | `classes.script:834-875` TSquad + `:3549-3595` TObjBase/TObjWeapon re-read | EV-T7: declaration order matches the squad wire order (contract §4). `TObjBase` (`:3573-3595`): `sid:String, maxhp:I, shield:I, price[7]:I, buildtime:F, fishingspeed:I, fishingmax:I, speed:F, protection[3]:I, weapon[2]:TObjWeapon, bproduceenabled:bool` (counts: `gc_ResCount = 7` `dmscript.global:3`, `gc_MaxCountryCount = 24`, `gc_country_maxmembers = 80` `dmscript.global:708`). |
| P10 | `player.script` writer-site grep (3517 lines) | EV-T8 [O-absence]: **zero save-stream emitters for TObj/TProj in `player.script`**. Only hits: `TObjBase/TObjProp` type refs (`:151-152,185-186`), `_unit_ConvertObjSIDToID` id mapping (`:214,348,367,393`), `_unit_GetTObj` gameplay reads (`:926-928`), net `Write*` state executions (`WriteMove :531, WriteStop :597, WriteSquadListAction :606,876-882, WriteSquadNew :890-903`), and `_player_ResetSaveLoadStates` (`:614-622`: sets `BeforeSave/AfterLoad` state names to `''`). Persistence path for units is engine BeforeSave/AfterLoad hooks + `serial.script` reflection, NOT `player.script` code. |
| P11 | Stream-primitive call inventory (`serial.script` full grep) | EV-T9: 45 `Save/Merge/Seek/GetStreamSizeTypeBase` call sites. TObj/TOrderInfo/TProj/TTower writers use **`useproc=false`** (`:819,900,961,2232`); readers `false{useproc}` (`:840,915,978,2245`); size/seek likewise (`:851,883,924,942,987,1006,2254,2270`). `useproc=true` appears ONLY in container procs: AiData lists (`:1624,1645,1663,1692,1714,1721-1738,1841-1876,2012-2035,2107-2126`), towers/armyinfos (`:2293,2307,2331,2351,2374,2390,2408,2424`), flist (`:2740,2759,2775,2790`), cornPt/cells (`:2807,2816,2838,2848,2869,2877,2897,2903`). Consequence §4 [D]. |
| P12 | Version-gate grep (`gSerialVersion` in `serial.script`) | EV-T10: 60+ hits; **ZERO inside `:797-1007`** (Obj/OrderInfo/Proj procs) [O-absence]. Gates exist only in SquadList (`>=1/7/8/9/16/19/22/37`, `:1122-1161` reader / `:1261-1298` seek), AiData (`>=3/4/11/14/18/23/34`, `:1455-1483`), AfterProc (`:221-341`) and FinalProc (`:71-531`, incl. `<91 objbase.speed:=1`, `<92 res triple`) migrations. **TObj and TProj have NO version-gated fields at any serial version** [O]. |
| P13 | Projectile lifecycle (`misc\projectile.inc\*.inc`, read-only) | EV-T11: `initial.inc` (`args arg_proj : TProj`; `if (gSerialMode=0)` guard initialises `baseid := gc_baseid_prj` + bounding box, else SKIPPED on load); `oncollide.inc` (damage routing via `arg_proj.owner/ownercid/ownerid/weaponid/dx/dy/dz`, then `SwitchTo('Nothing'/'NothingEmpty')` = despawn); `nothing.inc` references `arg_proj.trg/owner` for tower/wall cases; `onafterload.inc` (`if (not GetGameObjectMyVisible) and (GetGameObjectGrHandleByHandle(myHnd)=0) then FreeToPoolGameObjectHandle(myHnd)` = cull orphaned projectiles on load). Projectiles are transient state-machine args (`gc_argproj_proj = 0`, `dmscript.global:836`), NOT members of any of the 19 `serialized:` globals [D]. |
| P14 | Native `TSWriter` wrapper question | EV-T12: parent negative string searches stand (`WriteFloat|ReadFloat|WriteString|WriteInteger|TSWriter|TSReader` → 0 hits, `SaveGame` → 0, `checksum` → 0; `DEC_U_save_float.md §0-P4`). Corroborated from script side this ticket: NO `TSWriter`/`TSReader`/`TWriter`/`TReader` identifier exists in any `.script`/`.inc` file (bits ticket §0-P7, 0 hits). The serial layer is donor *script* calling engine builtins `Write*/Read*/Seek*/SizeOf + Save/Merge/Seek/GetStreamSizeTypeBase`; there is no script-visible native wrapper to decompile — the wire form is fully determined by declaration order + call cardinality (§4 [D]). No binary disassembly performed (donor read-only, never executed). |
| P15 | Port `game.gd` surface read-only inspection | EV-T13: live `app/scripts/game.gd` `serialize()` (`:5534-5569`) emits `version: 4` with keys `seed,time_s,winner,next_id,next_squad,battle_mode,terrain,blocked,height,map_w,map_h,entities,res_nodes,players,squads,deposits,stats,objectives`; `deserialize()` (`:5571-5631`) gates `int(d.get("version",0)) not in [3,4]` (`:5572`), restores `height` float array (`:5579-5587`), rebuilds grids/nav (`:5610-5630`). **No `projectiles`, no `rng_state`, no `donor_progress`, no `victorystate_int`/`orders12`/`uniqrnd` keys exist in this workspace file** — the v5 + `_donor_progress_enc` surface described in the parent tickets' §7/§9 patch lists is NOT present here (parent ledger work not landed in this checkout). Patch list §6 is therefore written against the ACTUAL v4 surface. No edit made. |

DSL note `[D]` (inherited): donor `not X` on a numeric lvalue is the current-value read, not negation.

---

## 1. `TObj` — exact field order, widths, writer sites [O]

Wire order = declaration order (`dmscript.global:1712-1777`, EV-T5). The writer
(`serial.script:803-829`, EV-T1) performs ONLY handle→uid pre-translation, then
delegates to raw reflection:

```
803: procedure _serial_ObjWriter(const fs, val:TObj, nam, sm, tp)
805-814:  if val.trghnd<>0 then trghnd:=GetGameObjectUniqueIdByHandle(trghnd)   [O]
813-814:  if val.artHnd<>0  then artHnd :=GetGameObjectUniqueIdByHandle(artHnd)  [O]
817-819:  SaveStreamTypeBase(fs, typ, addr, nam, sm, false)                     [O] useproc=false
825-828:  restore uid→handle for trghnd/artHnd                                  [O]
```

`orders[].info.trg` translation inside `ObjWriter` is COMMENTED OUT
(`:807-809, :821-823` [O]); the `ObjPost` member/grid translation is likewise
commented (`:859-862` [O]). Live translation sites: `OrderInfoWriter`
(`:895-896`: `if val.trg<>0 then val.trg:=GetGameObjectUniqueIdByHandle(val.trg)`)
+ `OrderInfoPost` (`:933-934`: uid→handle), and `ObjPost` (`:863-866`: trghnd/artHnd
uid→handle; `:868`: `topzone:=-1`; `:870-875`: timer jitter re-draws).

Reader (`:833-843`): `MergeStreamTypeBase(..., false{useproc}, ..., cmp=1)` +
`if (val.uniqrnd=0) then val.uniqrnd := random` (`:841-842` [O]).
Size (`:847-852`) / Seek (`:880-884`) are pure reflection one-liners — no
per-field code, hence no padding terms anywhere [O].

**Verbatim field table** (`I` = Integer 4 B LE [O]; `F` = Float 4 B LE single [D,
float ticket §1]; `B1` = Boolean 1 B `0/1` [D, bits ticket §1];
`Y` = Byte 1 B [O]; `S` = String I32-LE-len + ANSI bytes [D, float ticket §2]):

| # | Field (donor name) | Type | Width | Offset [D]¹ | Writer-site note |
|---|---|---|---|---|---|
| 1 | `baseid` | I | 4 | 0 | reflection |
| 2 | `id` | I | 4 | 4 | reflection |
| 3 | `uid` | I | 4 | 8 | stable id, stored raw [O] (contract §2) |
| 4 | `pl` | I | 4 | 12 | reflection |
| 5 | `cid` | I | 4 | 16 | reflection |
| 6 | `hp` | I | 4 | 20 | reflection |
| 7 | `kill` | I | 4 | 24 | reflection |
| 8 | `resamount` | I | 4 | 28 | reflection |
| 9 | `restype` | I | 4 | 32 | reflection |
| 10 | `buildprogress` | F | 4 | 36 | reflection |
| 11 | `bdead` | B1 | 1 | 40 | sequential, no pack/pad [D] |
| 12 | `bbuilt` | B1 | 1 | 41 | — |
| 13 | `bstandground` | B1 | 1 | 42 | — |
| 14 | `bsearchenemy` | B1 | 1 | 43 | — |
| 15 | `insideofuid` | I | 4 | 44 | uid semantics [O] |
| 16 | `insidereserved` | I | 4 | 48 | reflection |
| 17 | `squad` | I | 4 | 52 | index, −1 = none |
| 18 | `brally` | B1 | 1 | 56 | — |
| 19 | `rallyx` | F | 4 | 57 | — |
| 20 | `rallyy` | F | 4 | 61 | — |
| 21 | `rallytmpx` | F | 4 | 65 | — |
| 22 | `rallytmpy` | F | 4 | 69 | — |
| 23 | `standtime` | F | 4 | 73 | — |
| 24 | `attackdelay` | F | 4 | 77 | — |
| 25 | `attackmaxdelay` | F | 4 | 81 | — |
| 26 | `exitdelay` | F | 4 | 85 | — |
| 27 | `lastprogresstime` | F | 4 | 89 | — |
| 28 | `progresstick` | I | 4 | 93 | — |
| 29 | `idlegridx` | I | 4 | 97 | — |
| 30 | `idlegridy` | I | 4 | 101 | — |
| 31 | `scangridx` | I | 4 | 105 | — |
| 32 | `scangridy` | I | 4 | 109 | — |
| 33 | `ctrlgroupmask` | I | 4 | 113 | — |
| 34 | `bpathrequested` | B1 | 1 | 117 | — |
| 35 | `bleaverequested` | B1 | 1 | 118 | — |
| 36 | `bhiderequested` | B1 | 1 | 119 | — |
| 37 | `trghnd` | I(uid) | 4 | 120 | handle→uid pre-write `:811-812`, uid→handle post `:863-864` [O] |
| 38 | `topzone` | I | 4 | 124 | post-load forced `−1` (`:868`) [O] |
| 39 | `scenariogroupid` | Y | 1 | 128 | — |
| 40 | `smokecount` | Y | 1 | 129 | — |
| 41 | `wallvariation` | Y | 1 | 130 | — |
| 42 | `inbattle` | B1 | 1 | 131 | — |
| 43 | `artx` | F | 4 | 132 | — |
| 44 | `arty` | F | 4 | 136 | — |
| 45 | `arthnd` | I(uid) | 4 | 140 | handle→uid `:813-814`, back `:865-866` [O] |
| 46 | `artdistfactor` | F | 4 | 144 | — |
| 47 | `uniqrnd` | F | 4 | 148 | `0 → random` on load (`:841-842`) [O] |
| 48 | `individual.benabled` | B1 | 1 | 152 | `TObjIndividualUpgrades :1704-1710` [O] |
| 49 | `individual.upglevel` | I | 4 | 153 | — |
| 50 | `individual.attackrate` | F | 4 | 157 | — |
| 51 | `individual.addpeasantabsorber` | I | 4 | 161 | — |
| 52 | `individual.addtransport` | I | 4 | 165 | — |
| 53 | `orders[0..11]` | 12×TOrder | 55 each = 660 | 169–829 | `gc_obj_MaxOrderCount=12` [O]; per-slot §2 |
| 54 | `sndwalkproc` | B1 | 1 | 829 | — |
| 55 | `sndwalkdst` | F | 4 | 830 | — |
| 56 | `sndwalktype` | I | 4 | 834 | — |
| 57 | `prevstouid` | I(uid) | 4 | 838 | uid semantics (contract §2; translation at callers, no writer pre-swap — stored value is uid [O-shape]) |
| 58 | `lastsearchenemy` | F | 4 | 842 | re-drawn `:= random` on load (`:875`) [O] |
| 59 | `lasttimecheckcapture` | F | 4 | 846 | re-drawn (`:870`) [O] |
| 60 | `lasttimeidlegrid` | F | 4 | 850 | re-drawn (`:871`) [O] |
| 61 | `lasttimescangrid` | F | 4 | 854 | re-drawn (`:872`) [O] |
| 62 | `lasttimetopology` | F | 4 | 858 | re-drawn (`:873`) [O] |
| 63 | `lasttimebestposition` | F | 4 | 862 | re-drawn (`:874`) [O] |

Fixed record size **[D]**: **866 B** (sum of widths above). ¹Offsets are
arithmetic sums of declared units with NO padding terms — justified [D] because
(a) every `Size` proc in the file sums per-field `SizeOf` with no alignment
terms (cf. `SquadListSize`), (b) consecutive-Boolean no-pad proof (bits §1),
(c) `useproc=false` reflection emits declaration order with no descriptor
padding fields. Offsets are predictions for the §5 experiments, not literals.

**No version-gated TObj fields at any serial version** (EV-T10) [O-absence].
Engine transform (pos/orientation/scale/STO/statetag) is absent from `TObj`
[O] — placement stays [U]-R1d per bits ticket §3 (engine-owned, E-R1d retained).

## 2. `TOrder` / `TOrderInfo` — exact order [O]

`dmscript.global:1678-1702` (EV-T5):

```
TOrderInfo: trg:I, x:F, y:F, dx:F, dy:F, dir:F, z:F,
            upgradeid:I, produceid:I, restype:I, amount:I, progress:F   (= 48 B [D])
TOrder:     itype:I, info:TOrderInfo(48 B), bexecute:B1, bremove:B1, static:B1  (= 55 B [D])
```

Writer/reader/size/seek all `useproc=false` reflection (`:900,915,924,942`)
with `trg` handle→uid pre-swap (`:895-896`) and uid→handle post (`:933-934`).
Zero Booleans anywhere except the three `TOrder` tail flags [O] — fixes where
Boolean bytes can occur inside the 660 B `orders` span. **No version gates**
(EV-T10).

[U]-R1f-T1 (nested routing, engine-opaque): `ObjWriter` calls reflection with
`useproc=false`, so whether a nested `orders[i].info.trg` passes through
`OrderInfoWriter` (uid swap, `:895-903`) or is emitted raw (session handle) is
decided inside engine `SaveStreamTypeBase`, not in script. The commented-out
manual translation (`:807-809`) shows the authors were uncertain too. Closing
experiment E-T1 (§5): save with one unit holding an order with a live target;
vary only the target; assert the stored word equals the target's `uid`
(vs session handle) with single-word divergence.

## 3. `TProj` — full transcription [O] + writer sites

Verbatim (`classes.script:4351-4367`, EV-T6):

```
4351: type TProj = class
4352:    baseid : Integer;
4353:    weaponid : Integer;
4354:    owner : Integer;
4355:    trg : Integer;
4356:    px : Float;
4357:    py : Float;
4358:    pz : Float;
4359:    dx : Float;
4360:    dy : Float;
4361:    dz : Float;
4362:    ownerpl : Integer            <- verbatim: no trailing semicolon [O]
4363:    ownercid : Integer;
4364:    ownerid : Integer;
4365:    ownerweaponind : Integer;
4366:    uniqrnd : Float;
4367: end;
```

15 fields, fixed record size **[D] 60 B**:
`4×I @0/4/8/12` (baseid, weaponid, owner(uid), trg(uid)),
`6×F @16/20/24/28/32/36` (px,py,pz,dx,dy,dz),
`4×I @40/44/48/52` (ownerpl, ownercid, ownerid, ownerweaponind — plain snapshot ints, NO translation [O]),
`1×F @56` (uniqrnd). Offsets [D] by the same no-padding argument as §1.

Writer (`:951-967`, EV-T3): handle→uid pre-swap for `owner` (`:954-955`) and
`trg` (`:956-957`) only; then `SaveStreamTypeBase(..., false)` (`:961`).
Reader (`:971-979`): `MergeStreamTypeBase(..., false{useproc}, ..., cmp=1)` —
note NO `uniqrnd=0 → random` default (unlike ObjReader `:841-842`) [O].
Post (`:992-999`): uid→handle for owner/trg. Size/Seek: pure reflection
(`:983-988, :1003-1007`). **No version gates** (EV-T10).

Registration status [O-absence with consequence]:
(a) `serialproc` registry (`dmscript.source:358-548`, EV-T4) contains NO
`type = TProj` entry — `ProjWriter/Reader/Size/Post/Seek` are DEFINED but
never bound to the serial dispatch table;
(b) the 19-entry `serialized:` set (`:337-356`) contains no projectile list —
`gPlayer` carries units/squads/AI, never `TProj`;
(c) no `.script`/`.inc` file references `_serial_Proj*` outside their
definitions (EV-T3 grep);
(d) projectile objects live as transient state-machine args
(`args arg_proj : TProj`, `gc_argproj_proj = 0`), despawn on collide
(`nothing.inc`, `oncollide.inc`), and are culled on load when orphaned
(`onafterload.inc`, EV-T11).

Verdict **[D]**: live projectiles do NOT persist across save/load at the script
layer; `TProj` procs are dispatch-complete but unregistered (legacy or
engine-invoked). The port MUST NOT treat its `projectiles` save key (where
present) as donor bytes — it is a PORT EXTENSION by construction. Closing
experiment E-T3 (§5) confirms absence (in-flight projectile must not perturb
the stream).

`TProjSimulatePoint` (`:4369-4375`: weaponid, owner:I, px, pz, damagetime:F)
and `gProjSimulatePoints` (`:7669`, 2048-entry scratch) are simulation working
memory, never serialized [D] (no registry entry, no writer procs).

## 4. Why reflection order = wire order [D]

1. All three record writers call `SaveStreamTypeBase(fs, typ, addr, nam, sm,
   false)` with the type descriptor of the record itself (`:819,900,961`).
2. All three readers call `MergeStreamTypeBase(..., false{useproc}, ..., cmp=1)`
   (`:840,915,978`) — version-tolerant field merge against the LOADING
   build's descriptors, which is exactly why `TObj`/`TProj` need no
   `gSerialVersion` gates: added/removed fields merge by name/type, while
   `TSquadList`/`TAiData` (hand-written `Write*/Read*` sequences) need explicit
   gates. This structural difference is visible in the code, not inferred.
3. Native wrapper question closed (EV-T12): no `TSWriter`/`TReader` class
   exists in script or in the binary's data-section strings (parent negatives);
   the "wrappers" are the engine builtins themselves. Nothing further to
   decompile without executing the binary, which is forbidden.
4. `player.script` contributes no emitter (EV-T8); unit persistence is
   engine hook + reflection. `player.script` BeforeSave/AfterLoad state names
   are empty strings (`:616-621`), so no per-player script callback perturbs
   the stream [O].

## 5. Still-[U] register — paired-save hexdump experiments (owner-authorised; binary run by owner, never this worker)

Common harness (inherited): pin `t_87f0f3c130b0`; fixed map/seed/preset;
two saves per case differing in exactly ONE named field; a third identical-state
re-save. **Zero-mismatch criterion: all non-divergent bytes identical across
the pair AND across the identical-state re-save, except the six documented
post-load jitter fields** (`ObjPost :870-875`, re-randomised by design and
excluded from comparison). Any OTHER divergence = FAIL, no tolerance.

| # | Field(s) | Static state | Experiment |
|---|---|---|---|
| E-T1 | `orders[i].info.trg` routing | Writer pair exists (`:895-903` vs commented `:807-809`); engine routing opaque [U] | One unit, one order with live target T (record `uid(T)`). Save A. Replace target with T2 (record `uid(T2)`), save B. Hexdump `orders` span (@169+55i+4, §1): assert exactly one 4 B word diverges AND equals `uid(T)`→`uid(T2)` (not session handles). Zero-mismatch per harness. Decides uid-vs-handle AND confirms the 55 B slot stride. |
| E-T2 | `TObj` fixed size 866 B; all §1 offsets | Order [O], widths [D], padding [D] | One unit on empty map; locate record via adjacent `uid` word; assert total span 866 B and spot-check offsets: `hp` @20, `trghnd` @120, `uniqrnd` @148, `orders[0].itype` @169, `sndwalkproc` @829, `lasttimebestposition` @862. Vary `hp` only → single 4 B divergence @20. Zero-mismatch per harness. |
| E-T3 | `TProj` persistence (absence claim) | Unregistered procs + transient lifecycle [D], engine-side opaque [U] | Save A with 3 cannonballs in flight; save B same tick with none fired. Assert record streams byte-identical (projectiles leave NO trace) OR isolate the 60 B records (@§3 layout: `owner` @8, `px/py/pz` @16/20/24) if the engine persists them opaquely — report either outcome, do not force-fit. Zero-mismatch on identical-state re-save. |
| E-T4 | `prevstouid` stored form | No writer pre-swap at own level [O-shape] | Unit with STO history vs fresh unit; assert differing word @838 equals a `uid` (matches the STO object's `uid` seen in its own record @8). Single-word divergence; zero-mismatch per harness. |
| E-T5 | `TProj` 60 B layout (if E-T3 finds records) | Order [O], widths [D] | Vary only `px` of one in-flight projectile by a known delta; assert single 4 B divergence @16 with exact single-precision delta encoding; `owner` @8 stable. Else (no records) E-T3 absence stands. |
| E-T0 (control) | Harness validity | — | Identical-state re-save pair MUST be byte-identical except the six jitter floats; otherwise the harness (not the layout) is broken — fix harness, claim nothing. |

Inherited (not re-experimented here): E-R1b (float/bool bytes), E-R1c (string),
E-R1a/E-R1g (envelope/checksum), E-R1d (engine transform), E-R1e closed [O].

## 6. Additive-only port change list for `game.gd` (actual v4 surface, EV-T13)

Constraints (verified read-only against `app/scripts/game.gd:5534-5631`):
**additive keys only; no existing key removed/renamed/reordered; no version
bump rationale invented — stay `version: 4`; `deserialize` gate `in [3,4]`
(`:5572`) kept; old v3/v4 saves load with defaults; network untouched; no
parity claim.** Entity/player dicts already pass unknown keys through
(`for k in e/p` loops, `:5540-5558`; `_vec_dec` round-trip `:5593-5605`), so
additive keys survive without loader changes.

1. **Keep** every existing v5/v4 key verbatim (`version,seed,time_s,winner,
   next_id,next_squad,battle_mode,terrain,blocked,height,map_w,map_h,entities,
   res_nodes,players,squads,deposits,stats,objectives`). Do not reorder the
   literal (`:5559-5569`).
2. **Add** (new keys only, all defaulted on load via `.get`, each line citing
   this report + status tag):
   - per entity dict (inside the `ents` loop `:5536-5546`): `uniqrnd: float`
     default `0.0` (**[O]** field exists `dmscript.global:1760`; engine draws
     `random` when 0 per `serial.script:841-842` — port keeps stored value,
     documents `[U]-G1` source, does NOT draw RNG to stay deterministic);
     `trghnd, arthnd, prevstouid: int` defaults `0` (**[O]** uid semantics §1;
     document, do not convert); `artdistfactor, sndwalkdst, lastsearchenemy,
     lasttimecheckcapture, lasttimeidlegrid, lasttimescangrid, lasttimetopology,
     lasttimebestposition: float` defaults = current behaviour
     (**[O]** order §1; jitter fields documented as donor-re-randomised);
     `orders12: Array` — up-to-12 slot list with per-slot keys
     `itype,trg,x,y,dx,dy,dir,z,upgradeid,produceid,restype,amount,progress,
     bexecute,bremove,static` (**[O]** §2; default = current `order`/`queue`
     contents padded, never truncated; `E-T1` decides uid-vs-handle for `trg`).
   - per player dict (inside the `pls` loop `:5553-5558`): `victorystate_int:
     int` default `0` (**[O]** table none=0/win=1/lose=2, float ticket §5;
     beside any display string, never replacing it); `victorystategametime:
     float` default `0.0`; `setres, lanres: Array[7]` default = copy of `res`
     (**[O]** triple + `<92` repair semantics, contract §5); `fieldlife,
     myplmask, enemyplmask, team, difficulty, progresstick: int` defaults
     current (**[O]** `classes.script:3674-3720`).
   - top level (in the return literal): `save_donor_version: 92` (**[O]**
     `gDataVersion`), `save_framing: "serialized-set 19-order, JSON keys (NOT
     byte-parity)"`, `save_contract: "PORT EXTENSION [D]-tobj-order
     [D]-tproj-order [U]-E-T1..T5"`.
   - `projectiles`: do NOT add a donor-shaped key — donor does not persist
     live projectiles at script layer (§3 [D]). If desired, an explicitly
     labelled `projectiles_pred: Array` PORT EXTENSION (default `[]`) may be
     added for prediction smoothing; never cite it as donor order.
3. **Post-load** (`deserialize`, additive after `:5630`): clamp
   `next_squad := max(next_squad, max squad fUID+1)` (covers `[ver>=37]` fUID +
   `[>=40]` resequence as effects, not bytes); keep `uniqrnd=0` stored (no RNG
   draw, documented `[U]-G1`); res-grid/nav invalidation already present
   (`:5617-5624`) — keep.
4. **Do not**: mirror `RecordCustom*` net order into saves (contract §6);
   change any display string to int in place; bump version; drop compat keys;
   invent `Single`-vs-`Double` bytes (already [D] — cite, never emit float
   bytes from JSON); invent container magic/checksum; claim R1d transform
   placement or E-T1 routing before its experiment passes.
5. **Tests** (none weakened): full-state round-trip (save → load → re-save →
   JSON-stable except the six documented jitter fields); old v3/v4 fixtures
   load (gate `:5572` untouched); user-mod saves with extra keys pass through;
   new keys default correctly when absent (all-absent vs one-key fixtures
   differ in exactly one key).

## 7. Explicit non-claims + file discipline

- NO PARITY CLAIM. The port contract is **key-order parity + round-trip
  determinism**, never byte parity. §1/§3 offsets are [D] predictions for the
  §5 experiments, not observed bytes.
- No number invented: every order cites `file:line`; the two engine-opaque
  points (E-T1 nested-`trg` routing, E-T3 engine-side projectile persistence)
  are named [U] with experiments, never filler constants.
- `player.script` negative result (EV-T8) and native-wrapper negative result
  (EV-T12) are stated as absence-of-evidence bounds with exact grep scope, not
  as proofs.
- Read-only compliance: exactly one repo file written (this report). Donor
  reads were text reads + read-only hash/size; donor binary never executed,
  never copied; no source/asset/config/test/runner/Godot/git state changed.
- Network out of scope.

*End of DEC-U-SAVE-TOBJ.*
