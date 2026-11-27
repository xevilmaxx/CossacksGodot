---
id: DEC-U-SAVE-FLOAT
worker: DEC-U-SAVE-FLOAT (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied. Donor text scripts/data read as text or raw bytes only (read-only hexdumps). No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. Net/replay packages (RecordCustom write*/read*) are cited only to exclude them from the save contract (DEC-U-SAVE-CONTRACT §6)."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed; no donor save written by this worker. Byte widths below are static recoveries with paired-save confirmation experiments; nothing is invented."
labels: "[O] verbatim donor literal (file:line or VA bytes) · [D] deterministic derivation from observations · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT EXTENSION = port substitute, not donor law"
---

# DEC-U-SAVE-FLOAT — float bytes, string encoding, outer container, transform placement, victorystate ints (2026-11-26)

Parent: `DEC_U_save_contract.md` left [U]-R1a…g open (Float 4LE-vs-8B, string codepage/encoding, outer `.sav` container header/checksum, engine transform placement, `victorystate` int mapping). `IMPL-SAVE-CONTRACT` (live `game.gd:7058-7430` ledger + `_donor_progress_enc`) documented all of them as [U] without changing the v5 wire format. This worker re-attacks each item statically: native serialisation routines (`TSWriter`/`TSReader` wrappers = script-level `Write*/Read*/Seek*/SizeOf` + engine `SaveStreamTypeBase`/`MergeStreamTypeBase` reflection + `serialized:` emitters), the `.sav`/`.map` container question, shipped save/map files (read-only), and the live `game.gd` v5 surface (read-only inspection).

## 0. Pin + pass ledger (every pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `t_87f0f3c130b0` per shared session: `cossacks.exe`, 5,768,048 B, sha256 `87f0f3c130b0…4e16c`, PE32 x86, Deep mode. No `core_target_open/select`; `document:` pinned on every native call. No binary executed or copied. |
| P2 | `serial.script:21-90` header re-read | EV (fresh, this ticket): `ev_eb5fc51c01ad7f272e58c88350d110d047b0f49594904db87b73128aed1c1a` — `gDataVersion:=92`, `gSerialMode` 0/1/2, `WriteInteger(fs, gDataVersion)` / `ReadInteger(fs, gSerialVersion)`. First stream word = LE Int32 92 [O]. |
| P3 | Script-tree inventory | EV: `ev_535f5e4890334c4c1a87bf7014843ec64e7f618afc077b364398714de82d442d` — `data/scripts` holds 222 files; serial code lives at `lib/serial.script` (sha256 `5b6fb5…`), types at `dmscript.global` / `lib/classes.script`. There is no `TSWriter`/`TSReader`/`WriteFloat`/`serialized` string inside the binary (negative searches P4) because the serial layer is donor *script*, not engine code — the engine only exposes `Write*/Read*/Seek*/SizeOf` + `Save/Load/MergeStreamTypeBase` primitives. |
| P4 | Negative binary string searches (all pinned) | EVs: `ev_956be32139a0de806c7573bb2664c0f5010f3293efd215344c6068077ef882a` (`WriteFloat\|ReadFloat\|WriteString\|WriteInteger\|TSWriter\|TSReader` → 0 hits), `ev_b446e955688359dec6ff7952a326e5ee5d61aefbe9e5ee32c24f1b1c36fbb6dfb` (`WriteBuffer\|ReadBuffer\|TWriter\|TReader` → 0), `ev_5e24d7dc24f5ac5487652acbefc1b16296f535c45a46cacad88d5c35ec09b75f` (`WriteFloat` → 0), `ev_e5521b646ae5374848038301e63eefbe9b280a62287c46e14dfcc0cb3a56` (`SaveGame` → 0), `ev_e8573a2f40a1c439fee23e855f1acf15ef39e2fbb278fae4f1a251fb0ecbe8e0` (`checksum` → 0). `ev_fbb3fd1e95a53d76b7dd7fb1d801b4713c27bc373ed08b460a163526d0cd820c` (`compress` → exactly 1 hit: `unknown compression method` at `0x8f404e`, DATA section — a generic inflate error string, not a save routine). Consequence [D]: no save checksum literal and no container magic exist in the binary's data sections; the script layer likewise has no checksum trailer (only lobby/mod `gc_result_roomchecksum_*` enums, `dmscript.global:982-986`). R1g stays [U] by absence-of-evidence, closed only by the paired-save experiment (§6). |
| P5 | `dmscript.source:331-550` serialized-set re-read | EV: `ev_9a2ff144c30363244a54aa2ecfa53d8f02fdf7b302f20565b37a334c146eda68` — 19-section order + `serialproc` registry (Writer/Reader/Size/Post/Seek per type) + `serialbeforeproc = _serial_BeforeProcWriter`. Confirms contract §1. |
| P6 | `serial.script:656-885` IntegerList/PtrList/Obj procs re-read | EV: `ev_6c74f588229b25f87035ab65540b1d75c5ee5dc5e164253369c3f001921221ee` — `itemsize:I32 + count:I32 + WriteBuffer` framing; handle↔uniqid translation; `TObj` via reflection + `uniqrnd=0 → random` (`:841-842`) + post-load timer jitter (`:868-875`). |
| P7 | `serial.script:1011-1300` SquadList writer/reader/size/seek re-read | EV: `ev_458aaad1041900b98054c637cddb5468f99e5bd0d77f4fdd73844a4589429c` — full per-squad order with version gates; `SizeOf(Float)` counted once per `fDirX/fDirZ/fHoldModeProgress/fTag/fCurX/fCurZ`; `SizeOf(Integer)+StrLength(fGroupName)` for the string. Float *width* is not stated in script — width comes from P9. |
| P8 | `serial.script:506-575` migration tail re-read | EV: `ev_5b74985bdce51d2310136b466412ef812d561cd4c7e2e8fa43bf45f381142122` — `<91` `objbase.speed:=1`, `<92` `res/lanres/setres` triple repair, tail `gSerialMode:=0; gSerialVersion:=gDataVersion; gSerialLoaded:=true`. |
| P9 | Native float-constant bytes (fresh, pinned VAs) | EVs: `ev_59488806cb870b789aea155e81b54dc42d4c63234d3d39fae08d35b14957e796` — 32 B at `0x8f6164`: `00×8` then `00 00 80 3F` ×4 (four IEEE-754 **1.0f** LE singles); `ev_a9e345cdf1368ed2ae75b2a52adc302e1b9967cccf1f62bf43c3d1613dd0bcaf` — 16 B at `0x4cb368`: `00 00 00 00` (0.0f), `00 00 34 43` (180.0f = `0x43340000` LE), `00 00 34 C3` (−180.0f = `0xC3340000` LE), the actor-submit angle-wrap constants. Both prove 4-byte LE single storage inside the donor image. `ev_3f4ad294777ef540a812c3a37fdb48cc2b29d69efe3c5498f9ab7c365ca61135` — 16 B at `0x8fab6c`: first 13 B `00×10 FF 00 00` (13-byte record default head, consistent with prior-session `fnd_5`). |
| P10 | `dmscript.global:1691-1820` TObj + `1678-1691` TOrderInfo re-read | EV: `ev_aa7d55b641c74af08717b67f77fc550829ae3d9074ebdb6e78c99d33e3b38864` — full `TObj` field order (even with 4770 non-UTF-8 byte sequences in the file, the struct block itself decodes cleanly). **TOrderInfo fully recovered [O]**: `trg:I, x,y,dx,dy,dir,z:F, upgradeid,produceid,restype,amount:I, progress:F`. `gc_obj_MaxOrderCount = 12` (`dmscript.global:113` per contract). |
| P11 | `classes.script:3671-3830` TPlayer + `:85-145` TMap/TMapPlayer re-read | EVs: `ev_2cde1960683233fe6a7a76210d0dd39ad3195a881055ae0c6d6ba41a3fc0a4288` (`victorystate: Integer`, `victorystategametime: Float`, res triple, squad list, `artlimit/artcount`, counters/stat/upgstate/lists/adviser); `ev_0de3e784fd869d90cbc65f1932ff1efcb8f06f7e4c14ba5d14a02457bcd5f160` (`TMapPlayer.startx/starty: Float`; `TMap` header + `players[12]:TMapPlayer`). |
| P12 | Victorystate enum grep (donor text, read-only) | `dmscript.global:777-779`: `gc_player_victorystate_none = 0; _win = 1; _lose = 2` [O]; `common.inc/initmapgen.inc:263`: `gPlayer[i].victorystate := gc_player_victorystate_lose` [O]; `common.inc/initmaphistoricalbattle.inc:127-128`: `victorystate := gc_player_victorystate_none; victorystategametime := 0` [O]. Read via repo-independent `grep` on the donor tree (no binary executed). |
| P13 | `writesync.inc:1-110` transform inventory re-read | EV: `ev_1b537927690500055c50ff6704ee4f8e3a679a7e2f6c9cdcd87cdc40bd29f7f3` — engine-side transform getters (`GetGameObjectPositionX/Z`, `GetGameObjectOrientation` upx/y/z+dirx/y/z, `GetGameObjectScaleX`, STO handle→uid, state-target pos, arrow angle, `statestag`) written as `RecordCustomWriteFloat/Integer/String` net fields, followed by a TObj *subset* (`cid,id,pl,hp,bbuilt,bdead,buildprogress,uniqrnd`). Net-only (`_net_IsServer or _net_IsOffline` vs `_net_IsOnline or _net_IsRecord` branches) → excluded from the save contract per §6. |
| P14 | Shipped map/container bytes (read-only `python -c` byte reads; no donor binary executed) | SHELL-OBS-1: `ausmis1.map[0:64]` = `35 00 00 00` + ASCII `OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0.2843]Core.Ver[1] ` → LE Int32 **53** + engine tag [O]. SHELL-OBS-2: offset 97 holds `14 00 00 00` + `GameMapSnapShotBegin`, then `00 00 00 00 12 00 00 00 GameMapSnapShotEnd 12 00 00 00 GameMapRecordBegin …` — length-prefixed-string snapshot envelope [O]. EV: `ev_af9bce4d0315eb741dc545aad13857e10a02a85345ba5acd656edc33bb8a3a7a` (`data/maps` = 68 files, `.map`+`.aix` only). Glob over `C:\Games\Cossacks 3\**` and the workspace: **zero `*.sav` files** [O]. The `.sav` container is therefore statically unobservable. |
| P15 | String codepage evidence | `data/hud/textures/font/` contains exactly four codepage dirs `1250/1251/1252/1254` (shell `ls` [O]) = Windows-1250 (Central European), 1251 (Cyrillic), 1252 (Western), 1254 (Turkish) font atlases. Combined with `ev_aa7d55b…` reporting **4770 invalid UTF-8 sequences** in `dmscript.global` (file stored in ANSI/codepage, not UTF-8) and 1-based `StrLength/SubStr` byte-oriented usage (`init.script:53`, `country.script:141,155,218,224`, `gui.script:109,336`), string semantics are codepage-ANSI [D]. |
| P16 | `onsave.inc` + port `game.gd:7058-7430` read-only inspection | EVs: `ev_4b9f916c648b73dbee6a6195b27b5596d9e0147edddfc25ab53cd8cd4326244b` (`OnSave` body commented out — save path is engine-serial, not script file IO); live `game.gd` `serialize/deserialize` v5 + `_donor_progress_enc` + `§§1-8` ledger comments (no edit; see §7 for line cites). |

DSL note `[D]` (inherited): donor `not X` on a numeric lvalue is the current-value read, not negation.

---

## 1. [U]-R1b CLOSED-as-[D]: Float = 4-byte LE IEEE-754 single

**Static chain (no invention):**

1. **One `SizeOf(Float)` unit per float field [O]** (EV-P7 `ev_458aaad…`): the squad size proc adds exactly one `SizeOf(Float)` for each of `fDirX, fDirZ, fHoldModeProgress, fTag, fCurX, fCurZ`, and the seek proc issues exactly one `SeekFloat` per field. The script layer therefore treats `Float` as a fixed-size atom — but the script never states its byte width.
2. **The atom is 4 bytes [D]** from two independent pinned binary observations (EV-P9):
   - `0x8f6164` (`ev_59488806…`): `00 00 00 00 00 00 00 00 | 00 00 80 3F ×4 | …` — an 8-byte zero head followed by **four consecutive `00 00 80 3F` words**. `0x3F800000` LE is IEEE-754 **1.0f**; four of them back-to-back is only well-formed as 4-byte singles (as 8-byte doubles the same bytes would parse as two denormal garbage values `~1.4e-45`, not a sane default vector). This is the 24-byte terrain-record default (`00×8` + four 1.0f), consistent with the render-override record layout.
   - `0x4cb368` (`ev_a9e345cd…`): `00 00 00 00 | 00 00 34 43 | 00 00 34 C3` = **0.0f / 180.0f / −180.0f** as `0x00000000 / 0x43340000 / 0xC3340000` LE — the actor-submit angle-wrap constants. Again only well-formed as 4-byte singles.
3. **Platform corroboration [D]:** PE32 LE x86 + Delphi-family script (`Integer` header already proven 4 B LE by `35 00 00 00` = 53) makes `Float` = Delphi `Single` (4 B LE IEEE-754); a `Double` would be 8 B and would double every `SizeOf(Float)` accounting, contradicting the one-unit-per-field size/seek symmetry that the loader itself relies on for stream skipping.

**Verdict:** Float serial bytes = **4 B little-endian IEEE-754 single, field order = declaration order**. Status upgraded [U]-R1b → **[D]** (width), pending only the runtime confirmation below — which is retained, not skipped, because the engine `WriteFloat` implementation itself was not decompiled (name absent from binary strings per P4; it is an engine builtin invoked from script).

- **Experiment E-R1b (retained, owner-authorised; donor binary run by owner, never this worker):** save with one unit at known `rallyx=1.0, rallyy=2.0` (rally command). Hexdump the `TObj` record; assert bytes `00 00 80 3F / 00 00 00 40` (4 B singles) and NOT `00 00 00 00 00 00 F0 3F` (8 B doubles). Boolean companion: `fStandGround` true/false pair; assert the differing byte is exactly one byte `01`/`00` (Delphi `Boolean` = 1 B [O] shape; bit pattern was the [U] half of R1b). **Zero-mismatch criterion:** all non-divergent bytes identical across two saves of identical state; exactly one 4 B pattern per float field, exactly one 1 B pattern per boolean field.

**Port consequence:** `game.gd` already stores floats as GDScript `float` (double) at key level — that is correct and unchanged. The [D] above concerns only the *donor byte width* (relevant if a future byte-level exporter is ever written); the v5 JSON contract never claimed byte parity and still does not (§7).

## 2. [U]-R1c CLOSED-as-[D]: String = I32 LE byte-length + ANSI codepage bytes

**Static chain:**

1. **Shape [O]** (EV-P7): `res:=res+SizeOf(Integer)+StrLength(name)` (`serial.script:1185`); `WriteString/ReadString/SeekString` symmetric in squad procs. So: **4 B LE length prefix + `StrLength` raw bytes**, no NUL terminator, no separate capacity word.
2. **Encoding [D] = ANSI codepage (≈ Windows-1251 for RU/UA text, 1250/1252/1254 for the matching locales), NOT UTF-8:**
   - `data/hud/textures/font/{1250,1251,1252,1254}/` exist [O] (P15) — the engine ships one bitmap-font atlas per Windows codepage. A UTF-8 engine would not key fonts by 12xx codepage.
   - `dmscript.global` itself is stored in a non-UTF-8 encoding: the text reader reported **4770 invalid UTF-8 sequences** (`ev_aa7d55b…` limitations) — i.e. the donor tree contains high-byte (≥0x80) characters that are valid codepage bytes but invalid UTF-8.
   - `StrLength`/`SubStr`/`StrPos` are used 1-based and byte-oriented throughout (`init.script:53`, `country.script:141,155,218,224,4011`, `gui.script:109,336`) with constants tuned for single-byte indexing — consistent with SBCS codepage strings where length-in-chars == length-in-bytes.
3. **Length unit [D]:** on SBCS codepage strings `StrLength` returns bytes = chars, so the prefix is unambiguous for every string the donor can actually produce. The only way to observe a divergence would be a multi-byte character, which this encoding cannot emit.

- **Experiment E-R1c (retained for confirmation):** saves with `fGroupName="Test"` vs `"Testé"`/`"Тест"` (non-ASCII). Assert prefix = byte-count under the active codepage (E9 single byte in Latin-1 vs C3 A9 would indicate UTF-8 and would *contradict* the [D] — report either outcome, do not force-fit). **Zero-mismatch criterion:** identical-state re-save is byte-identical; the two names differ in exactly the string record.

**Port consequence:** none — v5 JSON strings are UTF-8 by format definition; the [D] only documents what donor bytes *would* contain. A future byte exporter must transcode UTF-8 → active codepage (default 1251 for RU/UA content); that mapping table is itself still [U] and NOT authorised by this report.

## 3. [U]-R1a outer `.sav` container: still [U] — narrowed statically, closed only by runtime

**What static work closed:**

- `.map` wrapper bytes re-verified read-only [O] (SHELL-OBS-1/2, P14): `LE-Int32 53 | ASCII "OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0.2843]Core.Ver[1] " | I32 len + "UID…" | … | I32(0x14) + "GameMapSnapShotBegin" | I32(0) + I32(0x12) + "GameMapSnapShotEnd" | I32(0x12) + "GameMapRecordBegin" | …`. So shipped maps = **engine tag wrapper + length-prefixed-string snapshot envelope + record stream**. The first Int32 (53) is the *map-writing* build's `gDataVersion`, proving the version word is real and version-gated readers load-bearing.
- `.sav` is **absent**: zero `*.sav` under `C:\Games\Cossacks 3\**` and under the workspace [O] (P14 glob); `data/maps` holds `.map`/`.aix` only (`ev_af9bce4d…`); `OnSave` is commented out (`ev_4b9f916c…`) so no script file-IO reveals the save path; no `SaveGame`/container/checksum literal in the binary (P4 negatives).
- Therefore whether quicksave reuses the `OSWMap13` + `GameMapSnapShotBegin…` envelope or a bare serial stream (version word first, §1) is **statically undecidable — stays [U]-R1a**. No magic invented.

- **Experiment E-R1a (owner-authorised):** in a donor session (binary run by owner), save the same scenario twice with only `gfloat_peacetime` toggled (`dogenerate.inc:2059-2064` shows it is set from map settings at gen time, so drive it via two map-settings presets). Hexdump first 256 B of both saves; assert (a) first Int32 equals current `gDataVersion` (92), (b) wrapper/snapshot tag bytes identical, (c) first divergence offset equals the `gfloat_peacetime` field position (serialized position 16). **Zero-mismatch criterion:** two saves of *identical* state are byte-identical end-to-end (any trailer divergence on identical state = checksum/compress flag → feeds R1g).

## 4. [U]-R1d transform placement: still [U] — placement narrowed, not closed

**What is [O]:**

- Engine transform is **absent from `TObj`** [O] — the full recovered order (`ev_aa7d55b…`, §0-P10) contains position-like gameplay fields (`rallyx/y`, `artx/y`, order `x/y/dx/dy/dir/z`) but no world pos/orientation/scale/STO/statetag.
- The engine owns the transform and exposes it per-handle [O] (EV-P13 `ev_1b537927…`): `GetGameObjectPositionX/Z`, `GetGameObjectOrientation` (upx/y/z, dirx/y/z), `GetGameObjectScaleX`, STO handle→uid, state-target pos, arrow angle, `statestag`. Net spawn (`WriteSync` server branch) ships all of them *plus* a TObj subset — but that is a **net package**, excluded from the save contract (contract §6, P13 branch guards).
- Map starts ARE script-layer floats [O]: `TMapPlayer.startx/starty: Float` (`ev_0de3e784…`, `classes.script:85-114`), inside `gMap` (serialized position 2).

**What stays [U]-R1d:** whether the save stream persists per-object world transform (engine-object layer, outside `TObj` reflection) or recomputes it from orders/grid/starts on load. The `TOrderInfo` recovery (§0-P10: `x,y,dx,dy,dir,z:F` + `progress:F`) gives the search anchor: any saved transform must sit adjacent to these IEEE-754 words.

- **Experiment E-R1d (owner-authorised):** save a unit mid-move at a known pos; hexdump for the adjacent IEEE-754 pos words; re-save with only x changed; assert exactly one 4 B word diverges (and identify its record neighbour: `TObj` tail vs order info vs engine block). **Zero-mismatch criterion:** identical-state re-save byte-identical except documented post-load jitter fields (`:868-875` timers are re-randomised on load — they must diverge by design and are excluded from the comparison).

## 5. [U]-R1e victorystate int mapping: RECOVERED [O] — table closed statically

- `dmscript.global:777-779` [O] (P12 grep, verbatim):
  `gc_player_victorystate_none = 0; gc_player_victorystate_win = 1; gc_player_victorystate_lose = 2;`
- Behavioural anchors [O]: `initmapgen.inc:263` assigns `…_lose` at gen; `initmaphistoricalbattle.inc:127-128` assigns `…_none` + `victorystategametime := 0`; port `_check_player_exists` assigns display `"lose"` + `lose_t` (game.gd.bak-SAVECONTRACT:6936-6945).
- Field type [O]: `TPlayer.victorystate: Integer` (`ev_2cde1960…`), immediately followed by `victorystategametime: Float`.

**Verdict:** R1e value table is **closed — no experiment needed for the mapping itself**. The port's string `"lose"` + `lose_t` is a display mirror (PORT EXTENSION); the additive patch (§7) adds the donor-int key beside it. Residual behavioural [U] (exactly which engine path writes `win` = 1 in a full game-over) is out of scope for a save-format worker and is recorded as such, not experimented here.

## 6. Still-[U] register (nothing invented; each item names its closing experiment)

| # | Byte(s) | Static state after this ticket | Closing experiment (owner-authorised; binary run by owner, never this worker) |
|---|---|---|---|
| R1a | Outer container magic/lengths | `.map` wrapper + snapshot envelope [O] (§3); `.sav` container [U] (no `.sav` shipped, no literal) | E-R1a §3; identical-state re-save must be byte-identical |
| R1b | Float width + Boolean `0/1` pattern | Float 4 B single **[D]** (§1); Boolean 1 B [O] shape, bit pattern [U] | E-R1b §1: known-float + true/false saves; single-field divergence |
| R1c | String encoding + length unit | I32 len + bytes [O]; ANSI codepage **[D]** (§2) | E-R1c §2: ASCII vs non-ASCII group-name saves; confirm byte-count + codepage byte |
| R1d | Engine transform placement (pos/orient/scale/STO/statetag) | Absent from `TObj` [O]; engine-owned [O]; placement in save [U] | E-R1d §4: mid-move unit, vary x only, single-word divergence |
| R1e | `victorystate` int table | **CLOSED [O]: none=0/win=1/lose=2** (§5) | None (mapping). Win-write path behavioural [U] out of scope |
| R1f | `TWallSystem/Cluster/Cell`, `TGridList/TResGridList`, `TInterface`, `TScenario` tails, `gMap` terrain tiles, path lists, `TProj`/`TAiData`/`TPlayerLists` tails | Type names + 19-order [O]; per-word layout [U] (TOrderInfo order recovered [O] §0-P10; TProj uid semantics [O] per contract) | E-R1f: one wall cell / one trigger / one grid mark / one projectile per save; vary one word; single-divergence assert |
| R1g | Checksum/compression/trailer | No literal in script or binary data sections [O-absence] (P4); generic `unknown compression method` string only | Paired identical-state saves bit-compared; any trailer diff → checksum/compress flag, else declare none. E-R1a doubles as the R1g run |

## 7. Patch recommendation for `game.gd` serialize/deserialize — additive on v5, no wire change

Constraints (verified read-only against live `game.gd:7058-7430`, P16): **additive keys only; no existing v5 key removed/renamed/reordered; no version bump (stay `version:5`); old saves (3/4/early-5) load with defaults; `deserialize` `in [3,4,5]` gate kept; network untouched; no parity claim.**

1. **Keep** every existing v5 key verbatim in `serialize()` (`game.gd:7217-7244`: `version,seed,time_s,winner,next_id,next_squad,battle_mode,terrain,blocked,height,map_w,map_h,entities,res_nodes,players,squads,deposits,stats,objectives,rng_state,gen_rng_state,tileblock,mine_mask,relief_donor_mask,relief_stamp_mask,pattern_stamps,projectiles,map_starts,map_meta,cluster_zones,nav_version,donor_progress`) and the `deserialize()` gate/flow (`:7247-7256`, `:7313`, `:7345-7346`). Do not reorder the literal; `IMPL-SAVE-CONTRACT` telemetry comments stay.
2. **Add** (new keys only, all defaulted on load; each line cites this report + `[U]`/`[D]`/`[O]` tag):
   - per player `donor_progress[].players[]` row (`_donor_progress_enc`, `game.gd:7058-7070`): `victorystate_int: int` (**[O]** mapping §5: mirror of display `victorystate`; populate from `"lose"→2`, `"win"→1`, else `0`; never assert beyond the table), `victorystategametime: float` (**[O]** field exists; value port-unknown → default `0.0`), `setres: Array[7]` + `lanres: Array[7]` (**[O]** fields exist; default = copy of `res` row per the `<92` triple-repair semantics, `ev_5b74985b…`), `fieldlife: int` (**[O]**; default `0`), `difficulty: int` (**[O]**; default current), `myplmask/enemyplmask/team: int` (**[O]**; defaults current).
   - per entity dict (inside `serialize()` ents loop, `game.gd:7179-7184`): `uniqrnd: float` (**[O]** field; default `0.0`, documented `[U]-G1` source — engine draws `random` when 0 per `serial.script:841-842`, port keeps stored value), `artdistfactor/sndwalkdst/lasttime*: float` + `trghnd/arthnd/prevstouid: int` (**[O]** TObj order §0-P10; defaults current behaviour), `orders12: Array` full 12-slot `TOrderInfo` order `trg:I,x,y,dx,dy,dir,z:F,upgradeid,produceid,restype,amount:I,progress:F` (**[O]** §0-P10; default = current order contents padded, never truncated).
   - per squad dict: already covered by `IMPL-SAVE-CONTRACT`; no new ask here except wiring `fBaseCount/fStandGround` first (contract §4 order) — unchanged by this report.
   - top level: `save_donor_version: 92` (**[O]** `gDataVersion`), `save_framing: "serialized-set §1 order, JSON keys (NOT byte-parity)"`, `save_contract: "PORT EXTENSION [D]-float-4LE/[D]-ansi/[O]-victorystate-table; [U]-R1a,d,f,g"`.
3. **Post-load** (`deserialize`, additive after existing restores): clamp `next_squad := max(next_squad, max squad fUID+1)` (covers `[ver>=37]` fUID + `[>=40]` resequence as effects, not bytes); default `uniqrnd=0` kept stored (document `[U]-G1`, do NOT draw RNG — deterministic round-trip beats donor jitter emulation); res/nav invalidation already present — keep.
4. **Do not**: mirror `RecordCustom*` net order into saves (contract §6); change display `victorystate` string to int in place (add `victorystate_int` beside it); bump version; drop `cap_check_t/market_rate/morale/routing` compat keys; invent Single-vs-Double (now [D] — cite §1, still emit no float bytes), string bytes, checksum, or container magic. Every added line carries `file:line` cite + status tag.
5. **Tests** (no test weakened): full-state round-trip (save → load → re-save → JSON-stable except documented post-load jitter `lasttimecheckcapture/lasttimeidlegrid/…` which donor itself re-randomises per `:870-875`); old v3/v4/early-v5 fixtures load; user-mod save with extra keys passes through.

## 8. Explicit non-claims + file discipline

- NO PARITY CLAIM. Byte widths beyond Integer(4LE)/Byte(1)/list-framing/string-prefix/float-4LE-single/ANSI-codepage/victorystate-table remain either derived [D] ( §§1-2, runtime-confirmed later) or [U] (§6 register); the port contract is **key-order parity + round-trip determinism**, never byte parity.
- No number invented: every order above cites `file:line` or pinned VA bytes; every unrecovered value is a named [U] with a paired-save experiment and zero-mismatch criterion, not a placeholder.
- Read-only compliance: exactly one repo file written (this report). All donor evidence is text reads + read-only byte dumps + pinned VA reads; donor binary never executed, never copied; no source/asset/config/test/runner/Godot/git state changed.
- Network out of scope: §0-P13 net-package inventory exists solely to exclude it from the save contract.

*End of DEC-U-SAVE-FLOAT.*
