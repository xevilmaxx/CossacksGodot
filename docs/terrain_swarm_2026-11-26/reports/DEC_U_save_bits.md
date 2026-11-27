---
id: DEC-U-SAVE-BITS
worker: DEC-U-SAVE-BITS (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b0…4e16c"
donor: "READ ONLY. Donor binary never executed/copied. Donor text scripts/data read as text or read-only byte dumps. No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. Net/replay packages (RecordCustom write*/read*) are cited only to exclude them from the save contract."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed; no donor save written by this worker. Nothing invented."
labels: "[O] verbatim donor literal (file:line or observed bytes) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT EXTENSION = port substitute, not donor law"
parent: "docs/terrain_swarm_2026-11-26/reports/DEC_U_save_contract.md + DEC_U_save_float.md"
---

# DEC-U-SAVE-BITS — Boolean wire form, outer container, transform placement, checksum (2026-11-26)

Parents left [U]-R1a (outer `.sav` container), [U]-R1b-half (Boolean `0/1` bit pattern),
[U]-R1d (engine transform placement), [U]-R1g (checksum/compression), while closing
Integer-4LE [O], Float-4LE-single [D], String I32-LE+ANSI [D], 19-section order,
victorystate 0/1/2 [O]. Zero `*.sav` files exist in the donor tree or workspace [O].
This worker re-attacks every still-[U] byte statically: native `serialized:` emitters,
the `Write*/Read*/Seek*/SizeOf` + `Save/Merge/SeekStreamTypeBase` builtin set
(there are no `TSWriter`/`TSReader` classes — see §0-P4), the map snapshot envelope
from a shipped `.map`, and the live `game.gd` v5 surface (read-only).

## 0. Pin + pass ledger (every pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `t_87f0f3c130b0` per shared session: `cossacks.exe`, 5,768,048 B, sha256 `87f0f3c130b0…4e16c`, PE32 x86. No binary executed or copied. |
| P2 | `serial.script:27-58` header re-read | `gDataVersion:=92` (`:27`), `WriteInteger(fs, gDataVersion)` (`:37`), `ReadInteger(fs, gSerialVersion)` (`:58`). Stream opens with one LE Int32 version word [O]. |
| P3 | `dmscript.source:337-357` serialized-set re-read | 19-section order `gEconomy … gbool_recordwascleared` [O]; `serialproc` registry binds each composite type to Writer/Reader/Size/Post/Seek (`:358-547`). |
| P4 | Writer/reader primitive inventory (`serial.script` full grep) | Boolean atoms are ALWAYS `WriteBoolean/ReadBoolean/SeekBoolean/SizeOf(Boolean)` — one call per field, never batched, never masked (§1). No `TSWriter`/`TSReader`/`TWriter`/`TReader` identifier exists in any script; `SaveGame`/`checksum`/compress literals return 0 hits in script (P7) and the prior ticket's binary-string negatives stand. The serial layer is donor *script* calling engine builtins `Write*/Read*/Seek*/SizeOf` + `SaveStreamTypeBase/MergeStreamTypeBase/SeekStreamTypeBase/GetStreamSizeTypeBase` (`serial.script:591-603,819-840,900-943,961-1006,1317-1358`). There is no script-visible Boolean packer to decompile — the wire form is fully determined by call cardinality (§1 [D]). |
| P5 | Squad Boolean trio re-read (`serial.script:1036-1038,1107-1109,1179-1181,1247-1249`) | Three CONSECUTIVE `WriteBoolean` calls (`fStandGround,fSearchVictim,fSelected`), mirrored by three `ReadBoolean`, three `SizeOf(Boolean)`, three `SeekBoolean`. A bitfield would be one Byte + masks; this is three atoms (§1). |
| P6 | `dmscript.global:1674-1777` TObj + `:1678-1702` TOrderInfo/TOrder re-read | Full TObj order [O]; 9 Boolean fields + 3-Boolean `individual`/order tails; TOrderInfo has ZERO Booleans (all Integer/Float) — fixes where Boolean bytes can occur in entity records (§1). |
| P7 | Negative stream-op + container grep (script tree, read-only) | `compress\|checksum\|crc\|md5\|sha\|encrypt\|zip\|pack` in `serial.script` → 0 hits [O-absence]. `\.sav\|quicksave\|SaveGame\|autosave` → only `gbool_gui_quicksave` flag (`dmscript.global:2166`, `dmscript.source:207`), `autosave: Integer` map-gen setting (`classes.script:68`), and `_misc_SaveMap` autosave rotation (`misc.script:3129-3192`) — all `.map` paths, never `.sav`. `TSWriter\|TSReader\|TWriter\|TReader` in scripts → 0 hits. |
| P8 | Bit-op grep (`serial.script`: `Bit\|Pack\|Mask\|shr\|shl\|SeekBuffer…`) | Only `shl`/`or` in the file is gameplay logic `enemyplmask or (1 shl j)` (`:89,:170` version-repair) — never stream packing. Stream skips are whole-unit `SeekBuffer(fs, SizeOf(Integer)*n)` (`:1239,1244`) and per-field `SeekBoolean/SeekInteger/…`. No bit-offset seek exists anywhere [O-absence]. |
| P9 | Save-path recovery (`misc.script:3129-3192`, `scenario.script:3097-3108`, `onsave.inc`) | `_misc_SaveMap` rotates `*.autosave.N.map`, then calls engine builtin `UserProfileSaveMap(filename)` (`:3181`) + `UserProfileRefreshSavesList` (`:3182`). `OnSave` body is commented out (`onsave.inc:5-23`). So the save file IS a `.map` file written by the engine — there is no separate `.sav` format (§2). |
| P10 | Shipped `.map` envelope dump (read-only bytes, `ausmis1.map` 43,950,027 B) | `35 00 00 00` + `OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0.2843]Core.Ver[1] ` [O]; at offset 97: `14 00 00 00 + "GameMapSnapShotBegin" + 00 00 00 00 + 12 00 00 00 + "GameMapSnapShotEnd" + 12 00 00 00 + "GameMapRecordBegin" …`; tail `… 45-58-54-2E-30 | 0A + "GameMapEnd"`. `GameMapRecordEnd` at index 12116555 of ~44 MB. Full envelope [O] (§2). |
| P11 | `.sav`/`.map` glob | Zero `*.sav` under `C:\Games\Cossacks 3\**` and workspace [O]; `data/maps` holds `.map`/`.aix` only; `.aix` is ASCII `section.begin` trigger text (`ausmis1.aix` head `73-65-63-74…` = `section.begin`), not binary. |
| P12 | Transform inventory | `TObj` (P6) contains NO world pos/orientation/scale/STO/statetag [O]; `TMapPlayer.startx/starty: Float` (`classes.script:103-104`) and `TProj.px/py/pz/dx/dy/dz: Float` (`classes.script:4354-4361`) ARE script floats [O]; net `WriteSync` ships engine transform per handle but is branch-guarded net-only (contract §6, excluded). `_serial_ObjWriter` persists TObj via typedescriptor reflection `SaveStreamTypeBase(fs, typ, addr, nam, sm, false)` (`serial.script:817-819`) — reflection emits exactly the declared struct fields, so undeclared engine transform cannot ride inside the TObj byte range (§3). |
| P13 | Port `game.gd:7187-7435` read-only inspection | v5 surface already carries `_donor_progress_enc` (`victorystate_int` [O] table, setres/lanres, `save_donor_version:92`), per-entity `uniqrnd` + `orders12` (12-slot TOrderInfo [O]), full §§1-8 ledger comments. Additive-only patch (§5) must preserve all of it. |

DSL note [D] (inherited): donor `not X` on a numeric lvalue is the current-value read, not negation.

---

## 1. Boolean wire representation: 1 byte `0/1`, sequential, never bit-packed — [D] (closes R1b fully)

**Static chain (no invention):**

1. **One stream call per Boolean field, in all four procs [O]** (P4–P5). Squad:
   writer `WriteBoolean(fs, TSquad(p).fStandGround)` / `fSearchVictim` / `fSelected`
   (`serial.script:1036-1038`), reader `ReadBoolean` ×3 (`:1107-1109`),
   size `SizeOf(Boolean)` ×3 (`:1179-1181`), seek `SeekBoolean` ×3 (`:1247-1249`).
   Same 1:1:1:1 cardinality for `fHoldMode` (`:1043/:1114/:1186/:1254`),
   `fAgressive` (`:1053/:1131/:1196/:1270`), `fAttackMode` (`:1054/:1136/:1197/:1275`),
   `fNeedRebuild` (`:1056/:1145/:1199/:1285`), `TArmy.fSpecialOrder/fActive/fOnEnemyLand`
   (`:1389/:1450`, `:1413/:1484`, `:1419/:1494`), `TAiData.centerfound/defenceStage/bFlags[i]`
   (`:1705/:1741/:1744`).
2. **A bitfield encoding is structurally impossible here [D].** Bit-packing three
   flags into one byte requires ONE write call + mask/shift ops and bit-offset
   seeks. Observed: THREE write calls, THREE read calls, THREE size units, THREE
   seeks — and zero mask/shift/bit-seek primitives anywhere in the serial layer
   (P8: the only `shl`/`or` is `enemyplmask` gameplay logic `:89`; the only skips
   are whole-unit `SeekBuffer`). Each `SeekBoolean` advances the stream past exactly
   one Boolean atom; a packed form could not be skipped one flag at a time.
3. **The atom is 1 byte [O-shape], value `0/1` [D].** `SizeOf(Boolean)` is counted
   once per field exactly like `SizeOf(Byte)`-class atoms, and Delphi `Boolean`
   (the script language family: `Integer` already proven 4 B LE by `35 00 00 00` = 53)
   is 1 byte holding `0/1`. The consecutive-trio layout (`1036-1038`) additionally
   proves no alignment padding is inserted between adjacent Booleans — padding would
   appear as extra `SizeOf` units or explicit skip calls, of which there are none.
4. **Where Booleans can occur in entity records is fixed [O]** (P6):
   `TObj` holds `bdead,bbuilt,bstandground,bsearchenemy,brally,bpathrequested,bleaverequested,bhiderequested,inbattle,sndwalkproc` + `individual.benabled` + per-order `bexecute,bremove,static` (×12);
   `TOrderInfo` holds ZERO Booleans (`trg:I,x,y,dx,dy,dir,z:F,upgradeid,produceid,restype,amount:I,progress:F` — `dmscript.global:1678-1691`).
   `TPlayer` holds `bexists,bgeology,bballoon,bfamine,brebellion,bai,bneutral` (`classes.script:3692-3698`).

**Verdict:** Boolean serial bytes = **one byte per field, `0x00`/`0x01`, declaration order,
no packing, no padding**. Status: [U]-R1b(Boolean half) → **[D]**.
The retained runtime confirmation (E-R1b below) checks the bit pattern only; the
structural conclusion (1 byte, sequential) no longer depends on it.

- **Experiment E-R1b (retained, owner-authorised; donor binary run by owner, never this worker):**
  save with one squad with `fStandGround=true/false` pair, all else identical.
  Hexdump the squad record; assert the differing byte is exactly one byte `01`/`00`
  at the `fStandGround` position (7th field group after `fBaseCount`), with the two
  following bytes (`fSearchVictim/fSelected`) unchanged. Float companion:
  `rallyx=1.0/rallyy=2.0` → `00 00 80 3F / 00 00 00 40` ([D] per parent ticket).
  **Zero-mismatch criterion:** all non-divergent bytes identical across the two saves;
  exactly one 1 B divergence per toggled Boolean; no multi-byte or shifted-bit residue.

---

## 2. Outer `.sav` container: there is none — saves are `.map` files — [D] (closes R1a as non-existent)

**Static chain:**

1. **The save path writes `.map` via engine builtin [O]** (P9):
   `_misc_SaveMap(var filename; bautosave)` (`misc.script:3129-3192`) rotates
   `saveMapFileName.autosave.N.map` (`:3133,3164,3168`), then `UserProfileSaveMap(filename)`
   (`:3181`). Scenario editor autosave is `name+'.autosave.1.map'` (`scenario.script:3108`).
   No branch writes any other extension; no format flag selects a wrapper.
2. **Zero `.sav` files exist [O]** (P11): glob over `C:\Games\Cossacks 3\**` and the
   workspace returns none; `data/maps` holds `.map`/`.aix` only.
3. **The `.map` envelope is fully recovered bytes [O]** (P10), `ausmis1.map` (43,950,027 B):
   `35 00 00 00` (= LE Int32 **53**, the map-writing build's `gDataVersion`) +
   ASCII `OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0.2843]Core.Ver[1] ` +
   `I32(0x11) + "UID108733367369411" + I32(0) + I32(0x14) + "GameMapSnapShotBegin" +
   I32(0) + I32(0x12) + "GameMapSnapShotEnd" + I32(0x12) + "GameMapRecordBegin" + …` +
   record stream + `GameMapRecordEnd` (index 12116555) + … + `I32(0x0A) + "GameMapEnd"`.
   Every tag is an `I32-LE-length + ASCII` framed string — the same `String` shape as §1.
   The `.aix` sidecar is ASCII trigger text, not binary (`section.begin … Name = ausmis1`).
4. **Consequence [D]:** "outer `.sav` container/wrapper" (R1a) is a non-question. A donor
   save IS the engine snapshot stream (`gDataVersion` word first per `serial.script:37`,
   then the 19-section `serialized:` body) wrapped in the `OSWMap13` + `GameMapSnapShot…/
   GameMapRecord…` envelope observed above. Any future byte-level exporter targets THIS
   envelope, not a hypothetical `.sav` magic.

- **Experiment E-R1a (owner-authorised; reframes as envelope confirmation):**
  in a donor session (binary run by owner), save the same scenario twice with only
  `gfloat_peacetime` changed (serialized position 16). Hexdump both files; assert
  (a) byte 0–3 = current `gDataVersion` (92, `5C 00 00 00`),
  (b) `OSWMap13…` tag + `GameMapSnapShotBegin/End`, `GameMapRecordBegin` tag bytes identical,
  (c) first divergence offset sits inside the record stream at the `gfloat_peacetime` field,
  (d) `GameMapRecordEnd`/`GameMapEnd` trailers present in both.
  **Zero-mismatch criterion:** two saves of *identical* state are byte-identical end-to-end
  (any trailer divergence on identical state = checksum/compress flag → feeds R1g, §4).

---

## 3. Transform placement (R1d): narrowed to [D]-boundary + one [U] remainder

**What is [O] (P12):**

- `TObj` (`dmscript.global:1712-1777`) contains NO world position, orientation, scale,
  STO handle, or statetag. Its only position-like fields are gameplay data:
  `rallyx/rallyy/rallytmpx/rallytmpy`, `artx/arty`, and per-order `x/y/dx/dy/dir/z`.
- `_serial_ObjWriter` persists entities by type-descriptor reflection —
  `SaveStreamTypeBase(fs, typ, addr, nam, sm, false)` (`serial.script:817-819`) —
  so the emitted TObj byte range contains EXACTLY the declared struct fields, in order.
  Undeclared engine transform cannot hide inside it.
- Script-side positions DO exist elsewhere: `TMapPlayer.startx/starty: Float`
  (`classes.script:103-104`, inside `gMap`, serialized position 2) and
  `TProj.px/py/pz/dx/dy/dz: Float` (`classes.script:4351-4367`).
- The engine owns live transform per handle (net `WriteSync` ships pos/orientation/scale/STO
  per object) but that package is branch-guarded net-only and excluded from the save
  contract (parent contract §6).

**What stays [U]-R1d:** whether the engine appends a per-object transform block for the
live objects OUTSIDE the reflected structs (e.g. between the `gPlayer` section and
`gEnemyInfoList`, or keyed by uid inside an engine-owned section such as
`gGOPathList/gWaterPathList/gScanGrid`), or recomputes placement from
orders/grids/starts on load. Script text cannot answer this — the engine side of
`SaveStreamTypeBase` for `TGameObject`-rooted sections is opaque statically.

- **Experiment E-R1d (owner-authorised):** save with one unit mid-move at a known map
  position; hexdump the record stream for the adjacent IEEE-754 words of that position;
  re-save with only x changed by a known delta; assert exactly one 4 B word diverges by
  the exact single-precision delta encoding, and record its neighbours (which section /
  which record it sits in). Control: repeat with a unit at rest — rest position must be
  stable. **Zero-mismatch criterion:** identical-state re-save is byte-identical EXCEPT
  the documented post-load jitter fields (`serial.script:868-875`
  `lasttimecheckcapture/lasttimeidlegrid/lasttimescangrid/lasttimetopology/lasttimebestposition/lastsearchenemy`
  are re-randomised on load and must diverge by design — excluded from comparison).

---

## 4. Checksum / compression / trailer (R1g): [U] with absence-of-evidence bound + single closing run

**Static bound:**

- No checksum/crc/compress literal in `serial.script` (P7: 0 hits) and no container
  magic beyond the §2 envelope; the prior ticket's binary-string negatives
  (`SaveGame` 0, `checksum` 0, `compress` 1 generic `unknown compression method` error
  string) stand.
- The shipped `.map` opens with a raw version word + ASCII tag (not a magic/compression
  header) and is ~44 MB for one mission map — consistent with an uncompressed stream,
  though size alone proves nothing [I].
- The snapshot envelope's own framing (`I32 length + bytes` per tag, §2) plus the
  `serialized:` 19-section positional framing and per-type Size/Seek procs give the
  loader everything needed to skip without a checksum — checksums are not
  load-bearing for this design [D-form, I-content].

- **Experiment E-R1g (owner-authorised; piggybacks E-R1a at zero extra cost):**
  paired identical-state saves bit-compared. If byte-identical end-to-end (including
  `GameMapRecordEnd`/`GameMapEnd` trailers) → declare **no checksum/compression** [D].
  Any trailing-word divergence on identical state → isolate, length-prefix-decode, and
  report as the checksum/compress flag (do NOT force-fit). **Zero-mismatch criterion:**
  identical-state pair must be 100% identical to close; the single-field-divergent pair
  (E-R1a) must differ ONLY at the expected field + nothing else.

---

## 5. Still-[U] register (nothing invented; each item names its closing experiment)

| # | Byte(s) | Static state after this ticket | Closing experiment |
|---|---|---|---|
| R1a | Outer container | CLOSED-as-[D]: no `.sav` exists; saves are `.map` (`OSWMap13` + snapshot/record envelope, §2) | E-R1a §2: paired saves, header/tag/divergence asserts |
| R1b | Boolean pattern | CLOSED-as-[D]: 1 B `0/1`, sequential (§1); Float 4 B single [D] (parent) | E-R1b §1: true/false squad pair, single-byte divergence (confirmation only) |
| R1c | String encoding | [D] ANSI codepage (parent ticket; untouched by this worker) | E-R1c per parent (confirmation only) |
| R1d | Engine transform placement | Boundary [D] (absent from TObj, reflection-bounded); placement [U] (§3) | E-R1d §3: mid-move unit, vary x, single-word divergence + neighbour ID |
| R1e | `victorystate` table | CLOSED [O]: none=0/win=1/lose=2 (`dmscript.global:777-779`; parent) | None (mapping). Win-write path behavioural [U] out of scope |
| R1f | `TWallSystem/Cluster/Cell`, `TGridList/TResGridList`, `TInterface`, `TScenario` tails, `gMap` terrain tiles, path lists, `TAiData/TPlayerLists` tails | Type names + 19-order [O]; per-word layout [U]. `TProj` order recovered [O] this ticket (`classes.script:4351-4367`: `baseid,weaponid,owner,trg:I,px,py,pz,dx,dy,dz:F,ownerpl,owner cid,ownerid,ownerweaponind:I,uniqrnd:F`) — note projectiles DO carry script-side kinematics, unlike units | E-R1f: one wall cell / one trigger / one grid mark / one projectile per save; vary one word; single-divergence assert |
| R1g | Checksum/compression/trailer | No literal in script or binary data sections [O-absence]; uncompressed-consistent size [I] | E-R1g §4: identical-state pair bit-compare; doubles as E-R1a run |

---

## 6. Additive-only patch recommendation for `game.gd` (preserves v3/v4/v5 loads; no invented bytes)

Constraints (verified read-only against live `game.gd:7187-7435`, P13):
**additive keys only; no existing v5 key removed/renamed/reordered; no version bump
(stay `version:5`); old saves (3/4/early-5) load with defaults; `deserialize`
`in [3,4,5]` gate kept; network untouched; no parity claim.**

1. **Keep** every existing v5 key verbatim (`version,seed,time_s,winner,next_id,next_squad,
   battle_mode,terrain,blocked,height,map_w,map_h,entities,res_nodes,players,squads,deposits,
   stats,objectives,rng_state,gen_rng_state,tileblock,mine_mask,relief_donor_mask,relief_stamp_mask,
   pattern_stamps,projectiles,map_starts,map_meta,cluster_zones,nav_version,donor_progress`)
   plus the additive layer already landed (`save_donor_version:92`, `victorystate_int`,
   `setres/lanres`, `uniqrnd`, `orders12`, §§1-8 ledger comments). Do not reorder.
2. **Add** (new keys only, each line cites `file:line` + status tag):
   - per entity: the remaining TObj Boolean mirrors ALREADY have port counterparts —
     wire them explicitly in the `serialize()` ents loop beside `uniqrnd`
     (`game.gd:7361-7364`): `bdead,bbuilt,bstandground,bsearchenemy,brally,
     bpathrequested,bleaverequested,bhiderequested,inbattle,sndwalkproc`
     (**[D]** §1: emit GDScript `bool`, 1 B `0/1` on any future byte export; JSON keeps bool).
     `individual` (`benabled,upglevel,attackrate,addpeasantabsorber,addtransport`)
     and per-order `bexecute,bremove,static` ride inside the existing `orders12`
     12-slot shape — extend slot dicts with the three Booleans defaulting to current
     behaviour when absent (**[O]** `dmscript.global:1693-1710`).
   - per squad: no new ask — `IMPL-SAVE-CONTRACT` + `DEC_U_save_float` coverage stands;
     ensure the three consecutive Booleans stay three separate bool keys
     (never a bitmask int) with a `[D]-§1` comment citing `serial.script:1036-1038`.
   - top level: `save_envelope: "OSWMap13/GameMapSnapShotBegin/GameMapRecordBegin (no .sav; [D] §2)"`
     and extend `save_contract` telemetry with `R1b-[D]-bool-1B-sequential`.
3. **Post-load** (`deserialize`, additive): unchanged — `next_squad` clamp,
   `uniqrnd=0` kept stored (no RNG draw, documented `[U]-G1`), nav/res invalidation kept.
4. **Do not**: invent a `.sav` magic or container header; invent checksum/compression bytes;
   pack Booleans into a bitmask int; mirror `RecordCustom*` net order into saves;
   change display `victorystate` string in place; bump version; drop compat keys;
   claim the R1d engine-transform placement (stay silent where §3 is [U]).
5. **Tests** (none weakened): full-state round-trip (save → load → re-save → JSON-stable
   except documented post-load jitter `lasttimecheckcapture/…` re-randomised per
   `serial.script:870-875`); old v3/v4/early-v5 fixtures load; user-mod saves with extra
   keys pass through; new Boolean keys default correctly when absent
   (all-false squad vs `fStandGround`-only squad fixtures differ in exactly one key).

---

## 7. Explicit non-claims + file discipline

- NO PARITY CLAIM. The port contract is **key-order parity + round-trip determinism**,
  never byte parity. R1b-Boolean is now [D] structurally (§1) with runtime confirmation
  retained; R1a resolved as non-existent [D] (§2); R1d placement and R1g remain [U] with
  paired-save experiments and zero-mismatch criteria — not placeholders, not guesses.
- No number invented: every order cites `file:line`; every unrecovered value is a named
  [U] with an experiment, never a filler constant.
- Read-only compliance: exactly one repo file written (this report). All donor evidence
  is text reads + read-only byte dumps; donor binary never executed, never copied; no
  source/asset/config/test/runner/Godot/git state changed.
- Network out of scope: net-package inventory exists solely to exclude it from the save contract.

*End of DEC-U-SAVE-BITS.*
