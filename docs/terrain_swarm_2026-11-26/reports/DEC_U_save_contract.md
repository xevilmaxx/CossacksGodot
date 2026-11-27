---
id: DEC-U-SAVE-CONTRACT
worker: DEC-U-SAVE-CONTRACT (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied. Donor text scripts/data read as text only. No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. No multiplayer/netcode specified, audited, or changed. Net packages (write*/read*) are cited only to exclude them from the save contract."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed; no donor save written by this worker."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT EXTENSION = port substitute, not donor law"
---

# DEC-U-SAVE-CONTRACT — exact save record framing (2026-11-26)

## 0. Pin + pass ledger (every native/script pass pinned `t_87f0f3c130b0`; donor read-only)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `t_87f0f3c130b0` = `C:\Games\Cossacks 3\cossacks.exe`, 5,768,048 B, sha256 `87f0f3c130b0…4e16c` (EV-PIN: `Get-Item`+`Get-FileHash` this ticket). PE32 x86. No binary executed. |
| P2 | `serial.script:1-60` header read | EV-SAVE-01: `gDataVersion:=92` (`:27`), `gSerialVersion:=gDataVersion` (`:28`), `_serial_BeforeProcWriter: WriteInteger(fs, gDataVersion)` (`:37`), `_serial_BeforeProcReader: ReadInteger(fs, gSerialVersion)` (`:58`). Save stream opens with one LE Int32 version word. |
| P3 | `dmscript.source:337-557` serialized-set read | EV-SAVE-02: `serialized:` block lists the 19 top-level save sections in order §1 (`:337-356`); `serialproc:` registry binds each composite type to Writer/Reader/Size/Post/Seek (`:358-547`). |
| P4 | `dmscript.global:1690-1815` `TObj`/`TOrder` read | EV-SAVE-03: full `TObj` field order §3 (baseid…lasttimebestposition + `orders[12]` + move/sound/timers). |
| P5 | `classes.script:115-130 (TMap), :85-114 (TMapSettings/Player), :3674-3760 (TPlayer), :3573-3596 (TObjBase), :834-935 (TSquad), :4351-4370 (TProj)` reads | EV-SAVE-04: per-player/per-entity/squad/proj declaration order §§2-5. `TPlayer` order: `id, objbase[24][80], cid, csid, res[7], setres[7], lanres[7], …` (`:3674-3720`). |
| P6 | `serial.script:1013-1301` SquadList writer/reader/size/seek | EV-SAVE-05: exact squad record framing with version gates §4 (`WriteInteger(fBaseCount)` `:1035`, `WriteBoolean(fStandGround)` `:1036`; reader `:1106-1107`; size `:1178-1179`; seek `:1246-1247`). |
| P7 | `serial.script:661-884` IntegerList/Obj/OrderInfo/Proj procs | EV-SAVE-06: list framing `itemsize+count+bytes` (`:666-667,692-701,708`); handle↔uniqid translation (`:671-684,722`); `TObj` via reflection + `uniqrnd=0 → random` default (`:841-842`) + post-load timer jitter (`:870-875`). |
| P8 | 40 `write*.inc/read*.inc` token inventory | EV-SAVE-07: full `RecordCustom(Write\|Read)(Byte\|Integer\|Boolean\|Float\|String)` sequences §6. All pairs symmetric once branch/loop structure is accounted for; they are **net packages, not the save file** (each guarded by `_net_IsOnline or _net_IsRecord`, e.g. `writeplayer.inc:6`). |
| P9 | Shipped map header hexdump (read-only) | EV-SAVE-08: `ausmis1.map` bytes `35 00 00 00` = LE Int32 **53**, then ASCII `OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0.2843]Core.Ver[1] ` — engine map wrapper, NOT the raw serial stream. Current script `gDataVersion=92`; map was written by build 2843 at serial version 53. Proves version word is real, version-gated readers are load-bearing, and shipped `.map` files are usable framing oracles. |
| P10 | `serial.script:509-571` version-migration read | EV-SAVE-09: post-load fixups §7 (`objbase.speed:=1` for `<91` `:516`; `res/lanres/setres` triple repair for `<92` `:526-529`; squad `fNextUID` clamp `:494-507`; res-grid clear, handle re-link, `topzone:=-1` `:568`). |
| P11 | Port `game.gd:7040-7230` serialize v5 read-only inspection | EV-SAVE-10: v5 contract (`version:5`, base64 `terrain/blocked/height`, `rng_state/gen_rng_state`, tile/mask/stamps, `projectiles`, `donor_progress`) — additive-only surface the patch §9 must preserve. No edit. |
| P12 | Mismatch triage (`sync/order/upgrade/wall/death/trade`) | EV-SAVE-11: apparent token-count diffs resolve to branch/loop structure, not asymmetry §6 (server/client branches in `writesync.inc`/`readsync.inc`; patrol-only floats in `writeorder.inc`; `bOldVersion` gate `gRecordGeneratorVersion<53` in `readupgrade.inc:12`). |

DSL note `[D]` (inherited): donor `not X` on a numeric lvalue is the current-value read, not negation.

---

## 1. File framing: wrapper vs serial stream [O-shape] + [U] outer container

1. **Serial stream header [O]** (EV-SAVE-01): first 4 bytes = `WriteInteger(gDataVersion)`; current scripts `gDataVersion = 92` (`serial.script:27-28,37`). Reader: `ReadInteger → gSerialVersion` (`:58`), then every subsequent `if gSerialVersion<N` gate applies.
2. **Top-level section order [O]** (EV-SAVE-02, `dmscript.source:337-356`): the save body serializes exactly these in order:
   `gEconomy, gMap, gGOPathList, gWaterPathList, gPlayer, gEnemyInfoList, gCtrlGroups, gSelectedObjects, gScanGrid, gResGrid, gInterface, gScenario, gWallSystem, gIslands, gbool_editor_peacemode, gfloat_peacetime, gbool_peacemode, gWriteNewRequestList, gbool_recordwascleared`.
   No per-section magic strings exist in the script layer — framing is positional + `TIntegerList` count prefixes + type reflection order.
3. **Outer container [U]-R1a**: shipped `.map` files are wrapped: `LE-Int32 version + ASCII engine tag + length-prefixed strings` (EV-SAVE-08: `53 | "OSWMap13…" | 00 00 00 11 | "UID108733367369411" | … | 14 00 00 00 | "GameMapSnapShotBegin" | …`). The `.sav`/quicksave container was **not found** in the donor tree (no `*.sav` shipped; `data/maps` holds `.map`/`.aix` only). Whether `.sav` reuses the `OSWMap13` wrapper or a `GameMapSnapShotBegin…` snapshot envelope is **[U]**.
   - Experiment E-R1a: in a donor session (owner-authorised, binary executed by owner — not this worker), save the same scenario twice (only `gfloat_peacetime` toggled). Hexdump first 256 B of both saves; assert (a) first Int32 equals current `gDataVersion` (92), (b) wrapper tag bytes identical, (c) first divergence offset equals the `gfloat_peacetime` field position. Zero-mismatch criterion: all non-divergent bytes identical across two saves of identical state.

---

## 2. Primitive widths + endian [O-shape] + [U] bytes

| Primitive | Donor evidence [O] | Width / form | Status |
|---|---|---|---|
| `Integer` | `WriteInteger/ReadInteger/SeekInteger/SizeOf(Integer)` everywhere; header `35 00 00 00` = 53 | **4 B, little-endian, two's complement** | `[O]` for width+endian (x86 PE32 + observed LE bytes); signedness `[D]` |
| `Byte` | `RecordCustomReadByte/WriteByte` (`readwall.inc`, `writemove.inc` trailing `WriteByte`, `TObj.scenariogroupid/smokecount/wallvariation: Byte` in `TObj` struct) | **1 B unsigned** | `[O]` |
| `Boolean` | `WriteBoolean/ReadBoolean/SeekBoolean/SizeOf(Boolean)` (`serial.script:1179-1181,1247-1249`) | **1 B** (`0/1`) | `[O]` (Delphi `Boolean` = 1 B; `SizeOf` accounting proves 1-unit, exact bit-pattern `0/1` is `[U]`-R1b) |
| `Float` | `WriteFloat/ReadFloat/SeekFloat/SizeOf(Float)`; fields `rallyx, buildprogress, uniqrnd, fDirX, fHoldModeProgress, victorystategametime …` | **4 B IEEE-754 single, LE** | `[I]`: Delphi `Single` is 4 B LE on x86 and `SizeOf(Float)` is counted once per field, but script never states `Single` vs `Double`. Treat as **[U]-R1b** |
| `String` | `_serial_SquadListSize: res:=…+SizeOf(Integer)+StrLength(name)` (`:1185`); `WriteString/ReadString/SeekString` | **4 B LE length prefix + `StrLength` raw bytes** | `[O]` shape; **encoding [U]-R1c** (ANSI vs UTF-8; length in bytes vs chars for non-ASCII) |
| `TIntegerList` | Writer `:666-667` (`WriteInteger(itemsize); WriteInteger(count)`), then `WriteBuffer(base, DataSize)`; reader `:692-701`; size `:708` (`DataSize+2×SizeOf(Integer)`) | `itemsize:I32 + count:I32 + count×itemsize raw bytes` | `[O]` |
| Handles | Writer translates handle→uniqid before write, restores after (`:671-684`); post pass uniqid→handle (`:713-723`); same for `TObj.trghnd/artHnd` (`:811-828,863-866`), `TProj.owner/trg` (`:954-966,995-998`), squad members+grid (`:1024-1033,1219-1226`) | Stored value = **stable `uid` (Integer)**, never the session handle | `[O]` |

- Experiment E-R1b (float width): donor save with one unit at known `rallyx=1.0, rallyy=2.0` (set via rally command), hexdump `TObj` record; assert bytes `00 00 80 3F / 00 00 00 40` (4 B singles) vs `00 00 00 00 00 00 F0 3F` (8 B doubles). Zero-mismatch: exactly one 4 B (or 8 B) pattern per float field.
- Experiment E-R1c (string/boolean): save with `fGroupName="Test"` vs `"Testé"` (non-ASCII); assert length prefix = byte-count vs char-count and trailing encoding (1 B `é`=E9 vs 2 B C3 A9). Boolean: save with `fStandGround` true/false pair; assert differing byte is `01/00` single byte.

---

## 3. Per-entity record `TObj` — exact field order [O] (widths per §2)

`dmscript.global` `TObj : struct.begin … struct.end` (EV-SAVE-03). Order is the wire order for generic `SaveStreamTypeBase/MergeStreamTypeBase` (reflection follows declaration):

```
baseid:I, id:I, uid:I, pl:I, cid:I, hp:I, kill:I, resamount:I, restype:I,
buildprogress:F, bdead:bool, bbuilt:bool, bstandground:bool, bsearchenemy:bool,
insideofuid:I, insidereserved:I, squad:I, brally:bool,
rallyx:F, rallyy:F, rallytmpx:F, rallytmpy:F, standtime:F,
attackdelay:F, attackmaxdelay:F, exitdelay:F, lastprogresstime:F, progresstick:I,
idlegridx:I, idlegridy:I, scangridx:I, scangridy:I, ctrlgroupmask:I,
bpathrequested:bool, bleaverequested:bool, bhiderequested:bool,
trghnd:I(uid), topzone:I, scenariogroupid:Byte, smokecount:Byte, wallvariation:Byte,
inbattle:bool, artx:F, arty:F, arthnd:I(uid), artdistfactor:F, uniqrnd:F,
individual:{benabled:bool, upglevel:I, attackrate:F, addpeasantabsorber:I, addtransport:I},
orders[12]:{itype:I, info:TOrderInfo, bexecute:bool, bremove:bool, static:bool},
sndwalkproc:bool, sndwalkdst:F, sndwalktype:I, prevstouid:I(uid),
lastsearchenemy:F, lasttimecheckcapture:F, lasttimeidlegrid:F, lasttimescangrid:F,
lasttimetopology:F, lasttimebestposition:F
```

Notes `[O]`: `trghnd/artHnd/orders[].info.trg` stored as uid (`serial.script:811-828,890-904`); `TOrderInfo` itself is generic-serialized (field order = its struct decl; observed net usage `taruid/posx/posz` in `readorder.inc` is consistent). Engine-side transform (pos/orientation/scale/STO) is **not** in `TObj` — it travels in the engine object layer (`ReadSync` carries `posx/posz/scale/orientation/statestag/sto…` for net spawn; EV-SAVE-11). Which of those are also in the save stream vs recomputed is **[U]-R1d** (experiment: save a unit mid-move with known pos; hexdump for the IEEE-754 pos bytes adjacent to the `TObj` record).

---

## 4. Squad record — exact framing [O] (the previously recovered pair, now byte-pinned)

Writer `serial.script:1018-1070`, reader `:1080-1163`, size `:1168-1208`, seek `:1234-1300` (EV-SAVE-05). Per squad, in order:

```
memberCount:I, memberCount×uid:I,
fHeight:I, fWidth:I, (fHeight×fWidth)×gridUid:I,
fFormation:I, fBaseCount:I, fStandGround:bool, fSearchVictim:bool, fSelected:bool,
fIndex:I, fOfficerID:I, fPlIndex:I, fGroupName:String,
fHoldMode:bool, fAddDamage:I, fAddShield:I, fAddDamageHold:I, fAddShieldHold:I,
fDirX:F, fDirZ:F,
[ver>=1]  fArmy:I, fType:I, fWarType:I,
[ver>=7]  fAgressive:bool,
[ver>=8]  fAttackMode:bool,
[ver>=9]  fHoldModeProgress:F,
[ver>=16] fNeedRebuild:bool (else false),
[ver>=19] fMoveCount:I, fAttackCount:I, fTag:F, fCurX:F, fCurZ:F,
[ver>=22] fDelayCount:I,
[ver>=37] fUID:I
```

List header: `WriteInteger(squadCount)` (`:1018`); reader `ReadInteger(c)` (`:1080`); size/skip account every field including version gates (`:1193-1207,1261-1299`). This closes the old `[U]`-R1 squad tail at the **field-order level**; only primitive byte widths (§2) and outer container (§1) remain `[U]`.

---

## 5. Per-player record `TPlayer` — exact field order [O]

`classes.script:3674-…` (EV-SAVE-04), wire order = declaration order:

```
id:I, objbase[24][80]:TObjBase, cid:I, csid:String,
res[7]:I, setres[7]:I, lanres[7]:I, resefficiency[24][7]:I,
fieldlife:I, victorystate:I(!), victorystategametime:F,
unitcount:I, farm:I, myplmask:I, enemyplmask:I, team:I, difficulty:I,
bexists:bool, bgeology:bool, bballoon:bool, bfamine:bool, brebellion:bool, bai:bool, bneutral:bool,
aidata:TAiData, squads:TSquadList(§4),
lastattacktime:F, lastprogresstime:F, lastcheckexists:F, lastcalcsquadsmovecounttime:F,
lastprogressaitime:F, lastseedwheattime:F, progresstick:I,
searchenemyprev:I, searchenemylast:I, searchenemycur:I, searchenemylasttime:F,
artlimit[types]:I, artcount[types]:I, counter:TPlayerCounters, stat:TPlayerStatistics,
upgstate[24][upgcount]:{sid:String, done/enabled/inprogress/grey:bool, timestart:F, timedone:F, bscenariodisabled:bool},
lists:TPlayerLists, playeradviser:TPlayerAdviser
```

Load-bearing corrections for the port: (a) `victorystate` is **`Integer`** in donor, not string — port `"lose"` must map to the donor int at the boundary (value table `[U]`-R1e; `0/1/2` suspected lose/none/win — do NOT invent; experiment below). (b) resources are a **triple** `res/setres/lanres[7]` with migration `res:=not res; lanres:=res; setres:=res` for saves `<92` (`serial.script:526-529`) — port `res[6]` + missing `setres/lanres` diverges here. (c) `objbase[24][80]` (`gc_MaxCountryCount=24`, `gc_country_maxmembers=80`) with `speed:=1` reset for saves `<91` (`:516`).

- Experiment E-R1e: saves with (i) fresh game, (ii) one player eliminated (`_check_player_exists` path), (iii) battle-mode win; hexdump the `victorystate:I` word per player; assert 3 distinct ints and stable mapping. Zero-mismatch: all other player words identical between (i) and a re-save of (i).

---

## 6. The 40 write/read pairs: inventory + why they are NOT the save

Full token sequences recovered statically (EV-SAVE-07; `B=Byte, I=Integer, F=Float, S=String, L=Boolean`):

- `writeplayer/readplayer`: `uid:I,cap:L` — symmetric. Net-only (`_net_IsOnline or _net_IsRecord` gate).
- `writesync/readsync`: server branch `fromServer:L,count:I,(syncuid:I,bexists:L,(race:S,base:S,9×F orientation/pos/scale,statestag:I,sto:I,3×F,4×TObj ints,hp:I,bbuilt:L,bdead:L,buildprogress:F,uniqrnd:F))`; client→server request branch `uid:I` only. Reader mirrors per branch. Apparent 30-vs-31 token diff = branch structure, not asymmetry.
- `writeorder/readorder`: `ordtyp:I,taruid:I,clrord:L,locktrg:L,number:I,[patrol/attackpoint? posx:F,posz:F],number×uid:I` — symmetric (conditional floats explain the 9-vs-10 static count).
- `writemove/readmove`: `x:F,z:F,2×L,3×I,2×F,trail:B` — symmetric.
- `writedeath/readdeath`: `fromServer:L,mode:I,randkey:F,count:I,count×uid:I` — symmetric (loops).
- `writeupgrade/readupgrade`: `fromServer:L,upgid:I,state:L,count:I,count×uid:I` + `bOldVersion=(gRecordGeneratorVersion<53)&replay` gate in reader (`readupgrade.inc:12`) — symmetric modulo the legacy `_unit_MakeUpgrade` path.
- `writetrade/readtrade`: `b:L,sell:B,buy:B,amount:I`; `writetraderesources/readtraderesources`: `b:L,3×B,amount:I` — symmetric.
- `writewall/readwall`: `fromServer:L,usage:B,cid:B,id:B,count:I,count×(sprite:B,px:F,pz:F,gouid:I),num:I,peasantcount:I,peasantcount×uid:I,…` + server/client re-execution branches — variable-length, symmetric per branch.
- Remaining pairs (`construct/produce/gate/leave/leaveorder/stop/stand/rally/search/package/apply/free/freelist/syncunitsparams/proj/projfree/squadnew/squadlistaction/peacetime`) all symmetric per the §P8 token table; every mismatch in naive static counts resolves to a counted loop (`count×uid`), a `bexists`-gated block, or an `ordtyp`/version conditional. Full table in EV-SAVE-07.

**Save-contract consequence [D]**: none of these 40 pairs is the save-file record. They are `RecordCustomBegin('ReadX')` net/replay packages. The save file is the §1 `serialized:` set via `SaveStreamTypeBase/MergeStreamTypeBase` + the §4/§5/§7 custom procs. Port `game.gd` serialize/deserialize must therefore NOT mirror `RecordCustom*` order — it must mirror §§1-5 field order at the *key* level (JSON keys, not bytes).

---

## 7. Post-load fixups that are part of the contract [O]

`_serial_FinalProcReader` (`serial.script:67-571`, EV-SAVE-09) — a conforming loader must reproduce these effects even though they are not bytes:

1. `TObjPost`: `topzone:=-1`; `lasttimecheckcapture:=random×TimeCheckCapture`, `lasttimeidlegrid:=random×TimeIdleGrid`, `lasttimescangrid`, `lasttimetopology`, `lasttimebestposition`, `lastsearchenemy:=random` (`:868-875`); `uniqrnd=0 → random` (`:841-842`).
2. `TSquadListPost`: member/grid uids → handles (`:1216-1226`).
3. Version repairs: `<9` weapon-sid fix; `<15` res-grid reset; `<26` peacetime/scan-grid init; `<28` wall clear; `<36` wall-variation fix; `<40` squad `fUID` resequence + `fNextUID`; `<42/43/47/48/50/53/54` handle/list/counter repairs; `68<ver<72` + `<74` base-obj/upgrade-state re-init; `<88/89` spectator-slot + res-grid resets; `<91` `objbase.speed:=1`; `<92` `res/lanres/setres` triple repair (`:509-531`).
4. Tail: `gSerialMode:=0; gSerialVersion:=gDataVersion; gSerialLoaded:=true`, selection/grid/idle re-registration, `FixPlayersObjBaseBadIndexes`, `FixGameObjectsUnitIDs` (`:533-570`).

---

## 8. Still-[U] byte register (each with a concrete save-file experiment; no invention)

| # | Byte(s) | Static state | Exact experiment (owner-authorised; donor binary run by owner, never by this worker) |
|---|---|---|---|
| R1a | Outer container magic/lengths | Wrapper bytes `[O]` for `.map`; `.sav` container `[U]` | E-R1a §1: paired saves differing in one field; assert header Int32 + tag bytes; zero-mismatch on identical-state re-save |
| R1b | Float width (Single vs Double) + Boolean `0/1` pattern | 1×`SizeOf` per field `[O]`; width `[U]` | E-R1b §2: known-float + true/false saves; assert 4 B single vs 8 B double, `01/00` |
| R1c | String encoding + length unit | `I32 len + bytes` `[O]`; encoding `[U]` | E-R1c §2: ASCII vs non-ASCII group-name saves; assert byte-count vs char-count, E9 vs C3 A9 |
| R1d | Engine transform placement (pos/orient/scale/STO/statetag) | Absent from `TObj` `[O]`; placement in save `[U]` | Save unit mid-move at known pos; hexdump for adjacent IEEE-754 pos words; vary x only, assert single-field divergence |
| R1e | `victorystate` int table, `gRecordGeneratorVersion`, `TOrderInfo` full decl, `TAiData/TPlayerLists/TPlayerStatistics` tails | Field positions `[O]`; value tables `[U]` | E-R1e §5: fresh/eliminated/win saves; assert int mapping; zero-mismatch on re-save |
| R1f | `TWallSystem/TWallCluster/TWallCell`, `TGridList/TResGridList`, `TInterface`, `TScenario` tails, `gMap` terrain tiles (`TMapTerrainDataTile[640][640]`), path lists | Type names + order `[O]` (`dmscript.source:338-356`); per-word layout partially read | Field-by-field: save with one wall cell / one trigger / one grid mark; vary one, hexdump, single-divergence assert |
| R1g | Checksum/compression/trailer | No checksum literal found in script layer | Paired identical-state saves bit-compare; any trailer diff → checksum/compress flag; else declare none |

---

## 9. Exact patch recommendation for `game.gd` serialize/deserialize (preserves v5 + user mods; no invented bytes)

Constraints (from EV-SAVE-10 + prior IMPL-SKIRMISH-ROWS/LAWS active work): **additive keys only; no existing v5 key removed/renamed; no version bump (stay `version:5`); old saves (3/4/early-5) load with defaults; demo-mill/builder-stands/I11 hooks untouched; no parity claim; network untouched.**

1. **Keep** every existing v5 key verbatim (`seed,time_s,winner,next_id,next_squad,battle_mode,terrain,blocked,height,map_w,map_h,entities,res_nodes,players,squads,deposits,stats,objectives,rng_state,gen_rng_state,tileblock,mine_mask,relief_donor_mask,relief_stamp_mask,pattern_stamps,projectiles,map_starts,map_meta,cluster_zones,nav_version,donor_progress`). Do not reorder; `deserialize` keeps the `in [3,4,5]` gate.
2. **Add** (new keys only, all defaulted on load):
   - per entity: `uniqrnd` (Float, default `0.0` → post-load `random` per `:841-842` is engine-side; port keeps stored value, documents `[U]-G1` source), `lasttimecheckcapture` already mirrored — keep both `cap_check_t` (compat) and `lasttimecheckcapture` (donor name); `artHnd/trghnd/orders[].trg` already stored as ids (uid semantics `[O]` — document, do not convert).
   - per squad (extend the `squads` dict values, do not change dict shape): `fBaseCount:I`, `fStandGround:bool`, `fSearchVictim:bool`, `fSelected:bool`, `fIndex:I`, `fOfficerID:I`, `fPlIndex:I`, `fGroupName:String`, `fHoldMode:bool`, `fAddDamage:I`, `fAddShield:I`, `fAddDamageHold:I`, `fAddShieldHold:I`, `fDirX:F`, `fDirZ:F`, `fArmy:I`, `fType:I`, `fWarType:I`, `fAgressive:bool`, `fAttackMode:bool`, `fHoldModeProgress:F`, `fNeedRebuild:bool`, `fMoveCount:I`, `fAttackCount:I`, `fTag:F`, `fCurX:F`, `fCurZ:F`, `fDelayCount:I`, `fUID:I` — each defaulting to current port behaviour when absent (so old v5 + user-mod saves load). Wire the two previously recovered `fBaseCount/fStandGround` first; the rest follow the §4 order.
   - per player (extend `donor_progress.players[]` rows, do not rename): `setres[7]`, `lanres[7]` (alongside existing `res`), `fieldlife`, `victorystate_int` (new int key; keep existing `victorystate` string as display mirror with explicit `[U]-R1e` comment — never assert mapping), `victorystategametime`, `progresstick` (already), `lastprogresstime/lastcheckexists` (already), `searchenemyprev/last/cur/lasttime`, `artlimit/artcount`, plus `objbase_speed_reset:1` marker documenting the `<91` fixup.
   - top level (new keys): `save_donor_version:92` (declares which `gDataVersion` the key map was taken from), `save_framing:"serialized-set §1 order, JSON keys (NOT byte-parity)"`, `save_contract:"PORT EXTENSION, no byte-parity claim [U]-R1a..g"`.
3. **Post-load** (in `deserialize`, additive): after existing restores, (a) clamp squad `fNextUID`-equivalent (`next_squad := max(next_squad, max squad fUID+1)`), (b) default `uniqrnd=0 → rng` draw is **not** emulated (document `[U]-G1`; keep stored 0), (c) res-grid/nav invalidation already present — keep.
4. **Do not**: mirror `RecordCustom*` net order into saves; change `victorystate` string to int in place; bump version; drop `cap_check_t/market_rate/morale/routing` compat keys; touch `battle_mode` semantics; invent `Single`-vs-`Double`, string encoding, checksum, or `victorystate` int values. Every added line carries `file:line` cite + `[U]` tag where applicable.
5. **Tests** (no test weakened): full-state round-trip (save → load → re-save → JSON-stable except documented post-load jitter `lasttimecheckcapture/lasttimeidlegrid/…` which donor itself re-randomizes per `:870-875`); old v3/v4/early-v5 fixtures load; user-mod save with extra keys passes through (`for k in p/e` loops already do this — keep them).

---

## 10. Explicit non-claims + file discipline

- NO PARITY CLAIM. Byte widths beyond Integer(4 LE)/Byte(1)/list-framing/string-prefix remain `[U]` (§8); the port contract is **key-order parity + round-trip determinism**, never byte parity.
- No number invented: every order above cites `file:line`; every value table not recovered is a named `[U]` with a paired-save experiment, not a placeholder.
- Read-only compliance: exactly one repo file written (this report). All donor evidence is text reads + read-only hexdumps; donor binary never executed.
- Network out of scope: §6 net-package inventory exists solely to exclude it from the save contract.

*End of DEC-U-SAVE-CONTRACT.*
