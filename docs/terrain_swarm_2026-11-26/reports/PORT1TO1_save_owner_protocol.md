---
id: PORT1TO1-SAVE-OWNER-PROTOCOL
worker: SAVE-OWNER-PROTOCOL (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
role: "WORKER SAVE-OWNER-PROTOCOL — exact owner-only paired-save protocol for P0-6 / S-SAVE-R1a…g"
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION__NO_PARITY_CLAIM
created: 2026-11-26
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied/patched by this worker. All donor facts below are carried [O]/[D] from cited landed reports. No donor save exists in this worker's hands; no donor bytes were produced here."
network: "OUT OF SCOPE. RecordCustom write*/read* net/replay packages are cited only to exclude them from the save contract."
labels: "[O] verbatim donor literal (file:line or observed bytes) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact zero-mismatch experiment · PORT EXTENSION = port substitute, not donor law"
scope_guard: "Repo/doc file reads only. No source, shader, asset, config, test, fixture, result JSON, git state, Godot process, gate, capture, ROI metric or donor binary was created, modified or executed. Exactly one repository file written: this report. Donor runtime (C:\\Games\\Cossacks 3) forbidden to this worker."
parity_status: UNVERIFIED
parity_claim: false
parity_claim_code: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — P0-6 remains open; paired-save parity UNVERIFIED; no donor save produced or compared by this worker; no byte/default invented; v5 wire unchanged."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_register_update.md (§1 P0-6, §3 C15, §5)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_decisions.md (§5 P0-6, §0 owner rule)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_acceptance_plan.md (§6 P0-6, §7 preserve-only)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_save_contract.md (§§0-9; E-R1a…g)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_save_float.md (§§0-7; E-R1a/b/c/d/e)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_save_bits.md (§§0-5; E-R1a/b/d/g)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_save_tobj.md (§§0-6; E-T0/T1/T2/T3/T4/T5)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_settings_persist.md (§3.3/§4/§6 U-SP5, §1 directory suffix)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_famine_profile.md (§3.2 W2, §5 FP-1)
---

# PORT1TO1 — exact owner-only paired-save protocol (2026-11-26)

> **Required reviewer line, verbatim (`PORT1TO1_owner_decisions.md:15/32`, `PORT1TO1_u_register_update.md:31-32`):**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> **This is a protocol, not a result.** P0-6 / S-SAVE-R1a…g is still open. No donor `*.sav` file exists and no donor save was produced by any worker; saves are `.map` files written by the engine user-profile/native store (`DEC_U_save_bits.md §2`, `DEC_U_settings_persist.md §4`). This document consolidates the landed save-law reports into **one owner-runnable, known-state, one-field-at-a-time paired-save battery** with byte-level diff/hexdump procedure, native profile-store capture points, outcome→port-change rules and zero-mismatch termination. It introduces **no approximation, no invented byte, no invented default, no weakened gate and no parity claim**. `parity.claim = NONE`, `parity.status = UNVERIFIED`.

> **Byte provenance discipline:** every byte pattern named below (e.g. `00 00 80 3F`, version word `5C 00 00 00`, envelope tag strings) is carried `[O]`/`[D]` from the cited landed reports as the **expected value for the experiment**. It is **not** an observed byte from any save produced by this worker — none exists. The protocol says what to assert, not what was measured. Any divergence is reported field-by-field, never force-fit.

---

## 0. Authority boundaries — owner-only, workers forbidden

| Lane | Allowed under the 2026-11-26 owner rule | Forbidden to workers |
|---|---|---|
| **A — donor-runtime / profile-store (owner only)** | DONOR binary launched **by the owner only**; fixed-seed known-state setup; two `.map` saves per case; native user-profile store file snapshots (`UserSaveProfile`/`UserSaveProfileExt`, `UserProfileSaveMap`, `ParserSelectUser`, `StateMachineGlobalVariables*`); read-only hexdump of the produced `.map` files | Any worker execution/copy/patch of `C:\Games\Cossacks 3\cossacks.exe`; any worker-produced donor save or donor byte; any worker claim promoted from a paired save. Workers cite text `[O]` only. |
| **B — static/port read-only** | Text/byte re-reads of donor scripts and shipped `.map` files; negative greps; field-order/offset arithmetic; file:line verification; writing this report | Any source/asset/config/test/git/Godot mutation by an analysis worker. |

**Settle class:** the entire P0-6 battery is `RUNTIME-HARNESS` (owner paired-save runs; **forbidden to workers to promote**). Static work already closed (§C15 of `PORT1TO1_u_register_update.md`): 19-section `serialized:` order, primitive widths/shape, full `TObj`/`TOrderInfo`/`TProj` field order, Boolean 1 B sequential, `.sav`-is-`.map`, `victorystate` 0/1/2 table, no `TSWriter` wrapper — **none of these is byte-parity**. What remains open is exactly the byte-level confirmation the battery below provides. A passing battery still does not promote any P0 row; `blocking_unverified` stays non-empty ⇒ `RESULT IS NOT GOOD`.

---

## 1. Known-state scenario — pin every value before any save

All scenario values below are the experiment inputs **already specified in the cited landed reports**. None is a donor-asserted default and none is newly invented here.

1. **Donor pin (text authority only):** `t_87f0f3c130b0`, sha256 `87f0f3c130b0…4e16c`, 5,768,048 B, PE32 x86. Re-hash read-only; the owner runs the binary, this worker never does.
2. **Seed:** fixed literal `S = 20261113` (acceptance pin; endgame protocol §1.2). Never `--seed random` (Class-N1) and never the menu Random button (N2). No `load_save` (Class-N9 seed rewrite).
3. **Base state (one canonical scenario, held identical across a pair):** a single skirmish on a fixed map/seed/preset, with **one** instrumented unit, **one** squad, **one** player roster; all other units/orders/resources frozen. The shipped `ausmis1.map` (43,950,027 B) is the read-only wrapper/tag oracle (`DEC_U_save_bits.md §0-P10`): bytes `35 00 00 00` (LE Int32 **53**, the map-writing build's `gDataVersion`) + ASCII `OSWMap13.Map.Ver[0.0]Build.Ver[2.0.0.2843]Core.Ver[1] ` and, at offset 97, `14 00 00 00 + "GameMapSnapShotBegin" + … + "GameMapSnapShotEnd" + "GameMapRecordBegin" + … + "GameMapRecordEnd" + "GameMapEnd"`.
4. **Expected fresh-save version word:** current `gDataVersion = 92` (`serial.script:27-28,37`), i.e. `[D]` bytes `5C 00 00 00` at offset 0 of a fresh save (`DEC_U_save_bits.md E-R1a §2`). The shipped map's `53` only proves the word is real and version-gated readers load-bearing; it is not the fresh-save value.
5. **Jitter exception (fixed by donor design):** `ObjPost` re-randomises six fields on load (`serial.script:870-875`): `lasttimecheckcapture`, `lasttimeidlegrid`, `lasttimescangrid`, `lasttimetopology`, `lasttimebestposition`, `lastsearchenemy`; also `uniqrnd=0 → random` (`:841-842`). These are **excluded from every byte comparison** (they must diverge by design). Any *other* divergence is FAIL.
6. **Profile-store setup:** fixed seed S, fresh user profile (owner backs up and renames the existing user-profile dir aside first), headless boot with no Start pressed; snapshot the native store bytes; then run the known-state setup; snapshot again. Owner alone handles the native store (`DEC_U_famine_profile.md §5 FP-1`; `DEC_U_settings_persist.md §6 U-SP5`).

---

## 2. Paired-save matrix — two `.map` files differing in exactly ONE field at a time

**Universal harness rule:** for every row, save **A** and save **B** differ in exactly one named field, all else byte-frozen; add a **third identical-state re-save** as the control (§5). Then hexdump/locate the field and assert a **single-field divergence** at the predicted offset with all other bytes identical (jitter fields excepted). Record the full divergent dump, not an average.

### 2.1 Float width / Boolean byte (E-R1b)

| Item | Save A | Save B (one field changed) | Predicted bytes `[D]` from cited reports | Assert |
|---|---|---|---|---|
| Float | one unit at `rallyx=1.0, rallyy=2.0` (rally command) | same unit, `rallyx` only (or record position only) | 4 B LE singles `00 00 80 3F` (`rallyx=1.0`), `00 00 00 40` (`rallyy=2.0`) at TObj offsets 57/61 (`DEC_U_save_tobj.md §1`) — **not** 8 B doubles `00 00 00 00 00 00 F0 3F` (`DEC_U_save_float.md §1`) | exactly one 4 B pattern per float field; the changed float diverges in exactly one 4 B word |
| Boolean | one squad `fStandGround=false` | same squad `fStandGround=true` | one byte `00`→`01` at the `fStandGround` position (7th field group after `fBaseCount`, `serial.script:1036`), with the two following bytes `fSearchVictim/fSelected` unchanged (`DEC_U_save_bits.md §1`) | exactly one 1 B divergence, no multi-byte or shifted-bit residue |

### 2.2 String codepage (E-R1c)

| Item | Save A | Save B | Predicted bytes `[D]` | Assert |
|---|---|---|---|---|
| `fGroupName` | `"Test"` (ASCII) | `"Testé"` (non-ASCII) — same squad | `I32-LE byte-length prefix + raw bytes`, no NUL (`serial.script:1185`); under codepage-ANSI (`data/hud/textures/font/{1250,1251,1252,1254}` exist; `dmscript.global` has 4770 invalid-UTF-8 sequences) `é` = single byte `E9`; UTF-8 would be `C3 A9` (`DEC_U_save_float.md §2`) | prefix = byte-count under active codepage (not char-count from a multibyte encoding); only the string record diverges; report either outcome — `C3 A9` would *contradict* the `[D]` and is reported, not force-fit |

### 2.3 TObj field order / width (E-T2)

| Item | Save A | Save B | Predicted layout `[D]` | Assert |
|---|---|---|---|---|
| `TObj` record | one unit on empty map; locate via adjacent `uid` word | vary `hp` only | total span **866 B**, declaration order, no padding (`DEC_U_save_tobj.md §1`); spot-check offsets `hp`@20, `trghnd`@120, `uniqrnd`@148, `orders[0].itype`@169, `sndwalkproc`@829, `lasttimebestposition`@862 | span 866 B; `hp` diverges in exactly one 4 B word @20; all other bytes identical (jitter excepted). Any padding/offset shift ⇒ FAIL |

### 2.4 Engine transform placement (E-R1d)

| Item | Save A | Save B | Predicted bytes `[O]/[U]` | Assert |
|---|---|---|---|---|
| per-object world transform | one unit mid-move at a **known** map position | same unit, only world **x** changed by a known delta | transform is **absent from `TObj`** `[O]` (`dmscript.global:1712-1777`, reflection `SaveStreamTypeBase(..., false)`, `serial.script:817-819`); engine-owned per handle (`GetGameObjectPositionX/Z`, `GetGameObjectOrientation`, `GetGameObjectScaleX`, STO, `statetag`, net-only `WriteSync`); any IEEE-754 pos words must sit **outside** the reflected `TObj` span, adjacent to `TOrderInfo.x/y/dx/dy/dir/z` or `TMapPlayer.startx/starty` (`DEC_U_save_bits.md §3`, `DEC_U_save_float.md §4`) | exactly one 4 B word diverges by the exact single-precision delta encoding, and its record neighbour is identified (which section/record). Control: unit at rest → rest position stable. Placement stays `[U]-R1d` until this terminates. |

### 2.5 victorystate int (E-R1e)

| Item | Save A | Save B / cases | Predicted value `[O]` | Assert |
|---|---|---|---|---|
| `TPlayer.victorystate: Integer`, followed by `victorystategametime: Float` | fresh game | (i) fresh, (ii) one player eliminated (`_check_player_exists`), (iii) battle-mode win | `dmscript.global:777-779`: `none=0`, `win=1`, `lose=2` | 3 distinct ints with stable mapping `0/1/2`; all other player words identical between (i) and a re-save of (i). Mapping is **already CLOSED `[O]`**; the behavioural win-write path stays out of scope, not experimented here. |

### 2.6 `orders[].info.trg` routing (E-T1)

| Item | Save A | Save B | Predicted bytes `[O]/[U]` | Assert |
|---|---|---|---|---|
| one unit, one order with a **live target** | target `T`, record `uid(T)` | target `T2`, record `uid(T2)` | `orders` span starts @169, **55 B per slot** (`TOrder`: `itype:I`+`TOrderInfo` 48 B+3 B flags; `TOrderInfo.trg:I` then x,y,dx,dy,dir,z:F…, `dmscript.global:1678-1702`); live translation at `OrderInfoWriter :895-903` (`if trg<>0 then trg:=GetGameObjectUniqueIdByHandle`), manual path at `:807-809` is **commented out**; engine `SaveStreamTypeBase(..., false)` routing is opaque `[U]` (`DEC_U_save_tobj.md §2`) | exactly one 4 B word diverges inside `orders` @169+55·i+4 and equals `uid(T)`→`uid(T2)` (**not** session handles); confirms both uid-vs-handle and the 55 B stride. Any other divergence ⇒ FAIL. |

### 2.7 Envelope / trailer / projectiles (companion cases)

| Case | Save A | Save B | Predicted `[O]/[D]` | Assert |
|---|---|---|---|---|
| **E-R1a envelope** (container) | scenario with one map setting | same scenario with only `gfloat_peacetime` toggled (serialized position 16; drive via two map-settings presets) | bytes 0–3 = current `gDataVersion` 92 (`5C 00 00 00`); `OSWMap13…`/`GameMapSnapShotBegin/End`/`GameMapRecordBegin` tag bytes identical; first divergence inside record stream at the `gfloat_peacetime` field; `GameMapRecordEnd`/`GameMapEnd` trailers present in both | (a)–(d) as stated; identical-state re-save byte-identical end-to-end (`DEC_U_save_bits.md §2`, `DEC_U_save_float.md §3`) |
| **E-R1g trailer/checksum** | identical state | identical state re-save | no checksum/compress literal in script or binary data sections `[O-absence]`; only a generic `unknown compression method` string at `0x8f404e`; snapshot envelope + 19-section positional framing leaves no checksum load-bearing `[D]` | 100% byte-identical including trailers ⇒ declare **no checksum/compression** `[D]`; any trailing-word divergence ⇒ isolate, length-prefix-decode, report as flag (never force-fit) |
| **E-T3 projectile absence** | 3 cannonballs in flight, same tick | none fired | `TProj` procs exist but are **unregistered** (no `serialproc` entry, no `serialized:` list, `useproc=false`); projectiles are transient state-machine args culled on load (`DEC_U_save_tobj.md §3`) | record streams byte-identical (projectiles leave no trace) **or** isolate the 60 B records (`owner`@8, `px/py/pz`@16/20/24) if the engine persists them opaquely — report either, do not force-fit |
| **E-T4 `prevstouid`** | unit with STO history | fresh unit | differing word @838 equals a `uid` (matches the STO object's `uid` @8 in its own record) | single-word divergence, zero-mismatch per harness |
| **E-T5 TProj layout** (only if E-T3 finds records) | in-flight projectile | only `px` changed by a known delta | 15 fields / 60 B: `4×I`@0/4/8/12, `6×F`@16/20/24/28/32/36, `4×I`@40/44/48/52, `1×F`@56 (`classes.script:4351-4367`) | single 4 B divergence @16 with exact single-precision delta; `owner`@8 stable |

---

## 3. Byte-level diff / hexdump procedure (owner-run; read-only on the saved files)

1. **Capture** both `.map` files from the native store (§4), copy them to an owner-controlled temp directory outside the repo; record file size + SHA-256 of each.
2. **Hexdump the first 256 B** of A and B. Assert byte 0–3 = `5C 00 00 00` (fresh-save `gDataVersion` 92) and that the `OSWMap13…` / snapshot / record tag bytes are identical (they are `I32-LE-length + ASCII` framed strings — the same `String` shape as §2.2).
3. **Locate the field** by its predicted offset (§2), using the `[D]` offsets as *search predictions*, not as observed addresses. For `TObj`, find the record via an adjacent `uid` word; confirm the 866 B span before asserting any offset.
4. **Byte-diff A vs B** at that offset/record: expect exactly one field's worth of bytes to differ (1 B Boolean; 4 B float/int/uid; I32-prefix + bytes for string); the changed float/int word must equal the *predicted encoding* from §2.
5. **Byte-diff A vs identical-state re-save** end-to-end: expect 100% identity except the six jitter fields (§1.5). This is the harness control (E-T0, §5).
6. **Report the divergent dump verbatim** with offsets and neighbouring field names for every case. If more than one field diverges, or a divergence lands at an unpredicted offset, record FAIL and keep the item `[U]` — do not trim the dump to make it fit.
7. **Tool discipline:** read-only byte reads / hexdump / byte-compare only. No donor binary execution by workers, no port/Godot/gate run, no file under `variant3d/` written, no result JSON fabricated.

---

## 4. Native profile-store capture points (owner-only; workers forbidden)

The save file is written by **engine natives**, not by readable script (script `OnSave` is commented out, `onsave.inc:5-23`). The following are the owner's capture points; byte format and flush timing are `[U]` and must be learned from the snapshots, not assumed.

| Capture point | Script authority `[O]` | What the owner snapshots | Status |
|---|---|---|---|
| **Save-path write** | `_misc_SaveMap` rotates `*.autosave.N.map` then calls `UserProfileSaveMap(filename)` (`misc.script:3129-3192`, `:3181`); scenario autosave `name+'.autosave.1.map'` (`scenario.script:3108`). No other extension branch. | The produced `.map` file(s) for save A / save B / re-save; the autosave-rotation slot used. | `.map` envelope `[D]`; native flush timing `[U]`. |
| **`UserSaveProfile` / `UserSaveProfileExt`** | Options Accept → `_profile_SaveUserProfile` → `StateMachineGlobalVariablesSaveToStack(GetUserProfileStateMachineHandle,'gProfile','')` + `UserSaveProfile` (`profile.script:617-623`); Skirmish Start → `_profile_SaveStructToUserProfileParser('gProfileUserStruct')` → `ParserSelectUser` + `StateMachineGlobalVariablesSaveToParser(...,False,False)` + `UserSaveProfileExt(false,true)` (`profile.script:269-281`) | Native store file bytes before/after Start and before/after Accept; struct keys `'gProfile'`, `'gProfileUserStruct'`. | Script contract `[O]`; physical file/encoding/flush `[U]` (`DEC_U_settings_persist.md §4/§6 U-SP5`). |
| **`StateMachineGlobalVariablesSaveToStack` / `LoadFromStack`** | `gProfile` persistence + boot-load (`profile.script:621,633,649`, `:642`); struct key `'gProfileUserStruct'` (`:273,287,546-552`). | Script-visible `gProfile.bFamine` read + store bytes on fresh boot (3 repeats), then no-change Accept (3 repeats) (`DEC_U_famine_profile.md §5 FP-1`). | Default `true` `[O]`; store bytes `[U]`. |
| **`GetAppSaveDirectoryPath` + `GameSaveDirectoryPath=cossacks`** | `cossacks.ini:2`; `resource.lib` consumers (`profile.script:111,125,141,161,206`); hotkeys `hotkeys\hotkeys.cfg` (`eventsettings.inc:727-730`). | Directory suffix used to locate the native user-profile store; the file that physically holds `custommap`/profile. | Path suffix `[O]`; file bytes `[U]` (native, zero script definitions — zero-definition grep `DEC_U_settings_persist.md §0-P8`). |
| **`custommap` snapshot** (Start-only trigger) | All `gen.*` + `additional.*` (incl. peacetime index) + roster snapshot into `gProfileUserStruct.custommap`, `randkey0/1` zeroed; written only on Start (`DEC_U_settings_persist.md §3.3`, §6 U-SP4) | Store bytes before Start vs after Start; B-state with six enum-legal changed ints (`mapsize=2, season=2, startingunits=5, peacetime=4, limit=7, gamespeed=2`) vs A all-zero lobby. | Snapshot law `[O]`; live bytes `[U]`. |

**Negative boundary `[O-absence]`:** `UserSaveProfile`, `UserSaveProfileExt`, `GetUserProfileStateMachineHandle`, `GetAppSaveDirectoryPath`, `ParserSelectUser`, `StateMachineGlobalVariables*` have **zero** script definitions under `data/scripts` — they are engine natives. No `.sav` file exists anywhere under `C:\Games\Cossacks 3\**` or the workspace; `data/maps` holds `.map`/`.aix` only. Therefore "the outer `.sav` container" is a non-question: the target is the `.map` envelope of §1.3 (`DEC_U_save_bits.md §2`).

---

## 5. Zero-mismatch termination criteria

1. **Control (E-T0 — harness validity):** an identical-state re-save pair **must** be byte-identical except the six documented jitter fields (§1.5). If it is not, the **harness is broken** — fix the harness and claim nothing. No case is admissible until E-T0 passes.
2. **Single-field divergence:** for each §2 case, exactly the named field's bytes diverge at the predicted offset; every other byte (outside the six jitter fields) is identical. One mismatch in an unpredicted location ⇒ FAIL, item stays `[U]`.
3. **Predicted encoding match:** float/int/int-table/uid bytes must equal the cited `[O]`/`[D]` expectation (4 B LE single `00 00 80 3F`, `5C 00 00 00`, `0/1/2`, `uid` not handle, one-byte `00/01`). A different well-formed encoding is **reported, not force-fit** (e.g. 8 B doubles, `C3 A9`, a handle instead of a uid).
4. **Repeats:** 3 identical-seed repeats per case; all dumps must agree. Any repeat divergence ⇒ item stays `[U]`.
5. **Completeness:** a missing dump, a missing trailer, or a masked/averaged diff is FAIL. "Close", a metric, a still, or a port fallback never counts.
6. **No promotion:** passing a case confirms only that single byte-level question. It never promotes P0-6, never establishes donor save/state parity, and never changes `parity.claim`/`parity.status`. v5 wire unchanged; network untouched.

---

## 6. Outcome → exact port change (additive-only; conditional on the corresponding zero-mismatch result)

Every change below is **conditional** on its own row terminating per §5. Until then the current labelling stands. All edits are **additive keys only** in `game.gd` serialize/deserialize: no existing v5 key removed/renamed/reordered, **no version bump** (stay `version:5`; `deserialize` `in [3,4,5]` gate kept), old saves (3/4/early-5) load with defaults, network untouched, no parity claim. Entity/player dicts already pass unknown keys through (`for k in e/p` loops) so additive keys survive without loader changes.

| Outcome (row of §2 terminates) | Exact port change — what bytes/order to emit or record | What stays additive-only / unchanged |
|---|---|---|
| **E-R1b float = 4 B** (`00 00 80 3F`/`00 00 00 40`) | Record donor float width as 4 B LE IEEE-754 single via a telemetry key; a **future** byte-level exporter would emit one 4 B single per float field in declaration order. If 8 B doubles observed instead, record that width — never emit invented bytes. | GDScript `float` (double) key-level storage unchanged; **no float bytes emitted from JSON**; v5 keys/order unchanged. |
| **E-R1b Boolean = 1 B `00/01`** | Wire the TObj Boolean mirrors explicitly (`bdead,bbuilt,bstandground,bsearchenemy,brally,bpathrequested,bleaverequested,bhiderequested,inbattle,sndwalkproc`) as separate bool keys; document 1 B `0/1`, sequential, no bitmask. Order-tail Booleans (`bexecute,bremove,static` ×12) ride in `orders12` slots. | Never pack into a bitmask int; JSON keeps `bool`; squad `fStandGround/fSearchVictim/fSelected` stay three separate bool keys (`serial.script:1036-1038`). |
| **E-R1c string codepage** | Document the observed prefix (I32-LE byte-length) + codepage bytes; a future exporter would transcode UTF-8 → active codepage (default 1251 for RU/UA content is `[D]`, not yet authorised as a mapping). | v5 JSON strings stay UTF-8 by format definition; no byte transcoding performed now; mapping table stays `[U]`. |
| **E-T2 TObj 866 B / offsets** | Record the verified TObj order/spans (63 fields, 12×55 B `orders`, 866 B total) as donor-order metadata; any future emitter uses exactly that order/width, no padding. | JSON key names/order unchanged; `orders12` stays up-to-12 slots padded never truncated; no byte export. |
| **E-R1d transform placement** | Record the observed transform block's section/record neighbour and its 4 B LE words; wire a donor-placement telemetry key naming where the engine stores `pos/orientation/scale/STO/statetag`. | `TObj` stays free of transform keys; no invented transform constants (`±2.96`, `_grid_w/_grid_h`, `height_tex` remain labelled `[U3]` substitutes, not donor values); no recompute-on-load asserted. |
| **E-R1e victorystate int** | Populate `victorystate_int` beside the display string from the **already-closed** table `none=0/win=1/lose=2`; never replace the display string in place. | `victorystate` string stays a display mirror (PORT EXTENSION); no value invented beyond the table; win-write behavioural path stays out of scope. |
| **E-T1 `orders[].info.trg` = uid** | Record that `orders12[].trg` stores a stable `uid` (not a session handle) and the 55 B slot stride; keep existing id-valued `trghnd/arthnd/prevstouid/orders[].trg` as-is, documenting uid semantics. | No handle↔uid conversion added to port; `uniqrnd=0` stays stored (no RNG draw — deterministic round-trip beats donor jitter emulation, `[U]-G1` documented). |
| **E-R1a envelope** | Add `save_envelope: "OSWMap13/GameMapSnapShotBegin/GameMapRecordBegin (no .sav; [D] §2)"`; confirm version word 92 / tag bytes as recorded facts. | No `.sav` magic invented; no container bytes emitted; v5 wire unchanged. |
| **E-R1g trailer** | If byte-identical → record "no checksum/compression" `[D]`; if a trailer flag found → record its isolated bytes as a fact. | No checksum/compression bytes invented; no compression added. |
| **E-T3/T5 TProj** | If absence confirmed → record "projectiles not persisted at script layer"; keep `projectiles` (where present) explicitly a PORT EXTENSION. Only if records found and E-T5 terminates → record the 15-field/60 B order. | Do **not** add a donor-shaped projectile key; an optional `projectiles_pred: []` stays PORT EXTENSION for prediction smoothing, never cited as donor order. |

**Common additive telemetry already landed (keep verbatim, no reorder):** `save_donor_version:92`, `save_framing:"serialized-set §1 order, JSON keys (NOT byte-parity)"`, `save_contract:"PORT EXTENSION, no byte-parity claim [U]-R1a..g"`, `victorystate_int`, `setres/lanres`, `uniqrnd`, `orders12`, §§1-8 ledger comments. Post-load stays additive: clamp `next_squad := max(next_squad, max squad fUID+1)`; keep `uniqrnd=0` stored; keep res/nav invalidation. Tests: full-state round-trip (JSON-stable except the six jitter fields), old v3/v4/early-v5 fixtures load, user-mod saves with extra keys pass through, new keys default correctly when absent — **no test weakened**.

---

## 7. Explicit non-claims / file discipline

- **P0-6 stays open; parity UNVERIFIED.** `parity.claim = NONE`; no donor save was produced, compared or claimed by this worker. No donor GPU A/B frame; no gate pass.
- **No bytes or defaults invented.** Every byte pattern here is carried `[O]`/`[D]` from a cited report as an *expected value for a future owner run*; none is asserted as an observed save byte. Values not recovered stay named `[U]` with an experiment, never a filler constant.
- **Donor runtime forbidden to workers.** All §2/§3/§4 acts are owner-only; this worker did not launch, capture, patch or execute the donor binary, and did not run Godot, a gate, a capture or any test.
- **Structural closure is not a value closure.** Field *order* was closed statically (C15); widths, codepage, trailer, transform placement and uid-vs-handle routing require the paired-save results above. A passing battery confirms only its single byte question.
- **Read-only compliance:** exactly one repository file written (this report). No source/asset/config/test/fixture/result-JSON/git/Godot/capture state changed. Network out of scope.

*End of PORT1TO1_save_owner_protocol. Read-only; exactly one repository file written; no code/Godot/git/donor-execution; no bytes/defaults invented; parity UNVERIFIED; `RESULT IS NOT GOOD` while P0-6 remains open.*
