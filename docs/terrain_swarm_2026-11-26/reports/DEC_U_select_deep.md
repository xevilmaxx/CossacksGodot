---
id: DEC-U-SELECT-DEEP-STATIC-2026-11-26
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER SELECT-DEEP — read-only static decompilation of donor selection / screen-to-world projection"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_select_deep.md
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_GODOT_GIT_EXEC
created: 2026-11-26
labels: [D, U, NO_PARITY_CLAIM, NO_APPROXIMATION, READ_ONLY]
parity: UNVERIFIED
chain: 0/6
result: NOT GOOD
donor_pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE x86, 5768048 B, sha256 87F0F3C130B027E7C4E72DC217EAe9D592982370D112E0D224897BC92AF4E16C"
scope_guard: "Exactly one repo file written (this report). No code/Godot/git/donor-execution or copying. Donor read READ-ONLY; donor executable never executed; no donor bytes copied. No .bind unpacking. No port behaviour wired. No parity claim."
tooling_constraint: "MUST NOT call any tools.craftanything.native_* except tools.craftanything.native_function_study (summary then complete). Used only: core_target_open / core_session_show / core_overview_show / core_feature_find / core_evidence_browse / native_function_study / report tools."
---

# DEC_U_select_deep — read-only static decompilation: selection / screen-to-world projection

> READ-ONLY. Parity UNVERIFIED. No approximations. No parity claim.
> `[D]` = byte-proven deterministic reading over cited `[O]` with evidence id + address. `[U]` = ambiguous or runtime-dependent, left unresolved.
> `ev_*` = Craft Anything evidence ids from NEW passes in **this** session, all pinned to `t_87f0f3c130b0` unless stated. Address = donor VA `0x…`; slot = `.idata` VA `0x…`.

## 0. Donor pin verification — before any finding [D]

- `[D]` `core_session_show` confirms active target `t_87f0f3c130b0`, path `C:\Games\Cossacks 3\cossacks.exe`, kind `pe`, bytes `5768048`, sha256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`. Expected pin `t_87f0f3c130b0` matches. Expected SHA256 `87F0F3C130B027E7C4E72DC217EAe9D592982370D112E0D224897BC92AF4E16C` matches (case-insensitive). No donor execution performed.
- `[D]` `core_overview_show` summary `ev_60b497434aa3e6cb68b019fd0a3b016ec0415ef6eec1a3189726faa8d3752f4c4`: PE x86, `18918` functions, `12073` strings, `746` imports, `18` libraries, `10` segments, `2` toolchain hints. Limitations carried on the record: function discovery stopped after `6000000` instructions so the function list is incomplete; `1238` indirect jumps unresolved; stripped binary (most names `sub_…`); static-analysis-only — functions reached only through computed pointers or at run time may be missing; absence is not proof.
- Context per task brief: `PORT1TO1_u_classify` lists selection/projection as owner-gated runtime `[U]`; prior camera work recovered the start→camera wire but not projection math; prior B8 LOS census proved the 12-float `OctreeRayCastIntersect` call shape. This ticket does NOT re-derive that shape and does NOT lift new projection math — it records only what the nine listed literal passes plus thunk/call-edge studies byte-prove.

## 1. Method — pass ledger (read-only, `document=t_87f0f3c130b0`)

| Pass | Operation | Evidence | Result summary |
|---|---|---|---|
| P0 | `core_session_show` | (session record, no ev) | pin + SHA verified above |
| P1 | `core_overview_show` detail=summary | `ev_60b497434aa3e6cb68b019fd0a3b016ec0415ef6eec1a3189726faa8d3752f4c4` | counts + incompleteness limits |
| P2 | `core_feature_find` `select` | `ev_40b0648ec25a0dbf5c248f2fb5f4e791f969f4beff0e8a5c00fa905b556ac6` | §2 |
| P3 | `core_feature_find` `selection` | `ev_cc459bb14cf49ca3b301ff9d4a423a240760bf3dd9e7783344b0f7209e08d2df` | §2 |
| P4 | `core_feature_find` `ray` | `ev_e5a90fcbfe0fde1558394cb58840d749031ed200e268d062453ad04ca9be5940` | §2 |
| P5 | `core_feature_find` `pick` | `ev_50d03d1594617ebc000bf5fb8362f1877d4ad3b1f73589f86671de8b172e9c25` | §2 |
| P6 | `core_feature_find` `screen` | `ev_0002bdd6d862b968ee770f5a6b347fa49bab140b41e5c63a326dd442ed68f601` | §2 |
| P7 | `core_feature_find` `project` | `ev_b8682413b00674a271d57e4bb873dce308c830e9cfa06e73311f32f46f5a672d` | §2 |
| P8 | `core_feature_find` `octree` | `ev_1f9395d35de6e07826dc3159ad1ca580f207ca053bff8d49242a7e4f323e72a6` | §2 |
| P9 | `core_feature_find` `raycast` | `ev_383505a5e507a2f2c3889afb9d5179656b4d5f83fb986afe02140ddd37c507fd` | §2, zero hits |
| P10 | `core_feature_find` `GetCursor` | `ev_4b163911375bf1abf63a463d878a5af25be3e50d768d71f2f5e20325fe3db5c5` | §2 |
| P11 | `native_function_study` detail=summary `0x4afeec`, `0x408d14`, `0x4089e4`, `0x4089dc` | `ev_7f07da25eab2c18a528b804a7d2f19f62dccf83fe362dfaca9e790eda8ca32ab`, `ev_c63c1c39473defe06749b9ed574136dcf38733e3575e482e713361daee8184ae`, `ev_5d44c3f3eacc1ca58a88471f29008c239d60eceee5520656246591f5f6293a12`, `ev_e446ffeb84009b88843ee58cd7fd6f393bf2bb68566af5f53d44d91cbcc0c721` | §3, thunks 1 block / 1 insn each |
| P12 | `core_evidence_browse` callers of above | `ev_220578aa17a7ec75d7b558d36e086d5e787031488f50e955e16228dea00d598f`, `ev_9cec28a09c6b3cf4e7efac182ded59448d1150c30cb183450c8c9f657d8d6e2`, `ev_f8d7c4bee21c2752ed7d43925ef95d6200c3e98a3d79348710828d0a64fd332`, `ev_0cb058d51b8f4fd6ff71a543d0c76b664af5f53d44d91cbcc0c721` | §3 call edges |
| P13 | `native_function_study` detail=summary `0x5811ec`, `0x582914`, `0x492634` | `ev_c05d9c9c3a0e0a165e57e04eb7e96a71ba40f9f1706de0ce201e12d85a69e4e2`, `ev_e95bd4a16cad53d8805d6efa164a552d5492762138dc35badae7dffa4182a1a8`, `ev_510e0be0962b24061a584a4e5fb87cdf5c0693406cc72d74e11399da9f4c6013` | §3 caller sizes |
| P14 | `core_evidence_browse` callees of above | `ev_68be647731ac792c5f3976d1d75e8c3bba68354bf224cfb36e94a3d712ddcc6c`, `ev_f3e86e2410e307afaa1cb2795aab0748a2d0d085668ef3891b2177d1477f29d1`, `ev_2c0d34321bf6c120ac87efaf29346323b5da7ad516eea9b77ff01c16f423bcc4` | §3 callee edges |
| P15 | `native_function_study` detail=complete `0x4afeec`, `0x4089e4`, `0x408d14` | same ev ids as P11 (complete dossier returned inline) | §3 assembly + import slots |

No other `native_*` was called. No `.bind` unpacking. No donor execution. No port behaviour wired.

## 2. Literal census [D] — exact counts, VAs, slots

Incomplete-discovery rule applies to every row: the finder searches an index over data sections/imports; CODE-embedded tables, packed bytes, runtime-built text, and computed-pointer refs are invisible to it. **Zero hits are index-vs-CODE, not disproof.** No absence is read as non-existence.

### 2.1 `select` — `ev_40b0648ec25a0dbf5c248f2fb5f4e791f969f4beff0e8a5c00fa905b556ac6` [D]

- `[D]` 21 matching strings, 4 matching function names, 5 matching imports, 4 functions involved.
- `[D]` Function VAs: `SelectClipRgn@thunk @ 0x4086dc`, `SelectObject@thunk @ 0x4086e4`, `SelectPalette@thunk @ 0x4086ec`, `WSAAsyncSelect@thunk @ 0x5a2ff0`. Each `why: name matches + calls <same>`.
- `[D]` Import slots: `SelectPalette @ 0x907560` used_by `0x4086ec`; `SelectObject @ 0x907564` used_by `0x4086e4`; `SelectClipRgn @ 0x907568` used_by `0x4086dc`; `WSAAsyncSelect @ 0x907dd0` used_by `0x5a2ff0`; `select (wsock32) @ 0x907dec` used_by `[]` (zero static users observed — index-vs-CODE, not disproof).
- `[D]` String VAs include `SelectPalette @ 0x908c2c`, `SelectObject @ 0x908c3c`, `SelectClipRgn @ 0x908c4c`, `WSAAsyncSelect @ 0x90afac`, `select @ 0x90b00c`, plus UI/script-table strings `EXSelectionBrush @ 0x958d55`, `goRowSelect @ 0x959f0b`, `Select a state to edit... @ 0x95ac2a`, `MultiSelect\t @ 0x95b9c0`, `SelectAllMenuItem @ 0x95bf5a`, `\nSelect All @ 0x95bf74`, `SelectAllMenuItemClick @ 0x95bf95`, `RemoveBPSelectedStateMenuItem @ 0x95c48b`, `"RemoveBPSelectedStateMenuItemClick @ 0x95c4d4`, `TabSheetSelectProfile @ 0x96193c`, `TabSheetSelectProfile\nTabVisible @ 0x96195b`, `PanelSelectProfile @ 0x961b12`, `BevelSelectProfile @ 0x961b8d`, `ButtonSelectProfile @ 0x961be8`, `ButtonSelectProfileClick @ 0x961ccd`, `#Remove selected variable from stack\tOnExecute @ 0x965535`. References arrays are empty in this index view. None is a proven selection-ray function name — all four code hits are GDI/socket thunks.

### 2.2 `selection` — `ev_cc459bb14cf49ca3b301ff9d4a423a240760bf3dd9e7783344b0f7209e08d2df` [D]

- `[D]` 1 matching string, 0 matching function names, 0 matching imports, 0 functions involved.
- `[D]` Sole string: `EXSelectionBrush @ 0x958d55` (same VA as in §2.1 row). No code edge.
- `[D]` Limitation on the record: `no_match` — text may be built at run time, encrypted, or come from a resource file; absence is not proof. Recorded here as index-vs-CODE, not as disproof of selection logic.

### 2.3 `ray` — `ev_e5a90fcbfe0fde1558394cb58840d749031ed200e268d062453ad04ca9be5940` [D]

- `[D]` 17 matching strings, 1 matching function name, 6 matching imports, 1 function involved.
- `[D]` Function VA: `glDrawArrays@thunk @ 0x4afb74` (substring hit on `ray`; calls `glDrawArrays`, slot `0x907d60`).
- `[D]` Imports: `SafeArrayPtrOfIndex @ 0x907a24`, `SafeArrayGetUBound @ 0x907a28`, `SafeArrayGetLBound @ 0x907a2c`, `SafeArrayCreate @ 0x907a30`, `glInterleavedArrays @ 0x907c8c`, `glDrawArrays @ 0x907d60` (only the last has a static user `0x4afb74`; others used_by `[]`).
- `[D]` String VAs include `SafeArray* @ 0x90a044/0x90a05a/0x90a070/0x90a086`, `glInterleavedArrays @ 0x90aabe`, `glDrawArrays @ 0x90addc`, colour/table strings `Medium Gray\rActive Border @ 0x955452`, `Default\tGray Text @ 0x95556e`, `Gray @ 0x955654`, safe-array error texts `@ 0x957926/0x9579d0`, `dsTypeArray @ 0x958f70`, `clGray @ 0x95ab6a/0x95aeb8/0x95b0ee/0x968c9d`, `\tTCheckBox\rCheckBoxArray @ 0x969a28`. No `RayCast`/`MouseRay` literal appears on this pass — those live on §§2.5/2.7-adjacent prior work, not re-claimed here.

### 2.4 `pick` — `ev_50d03d1594617ebc000bf5fb8362f1877d4ad3b1f73589f86671de8b172e9c25` [D]

- `[D]` 2 matching strings, 0 matching function names, 1 matching import, 0 functions involved.
- `[D]` Strings: `gluPickMatrix @ 0x90a6a8`, `XPicked @ 0x9590fd`.
- `[D]` Import: `gluPickMatrix (GLU32.dll) @ slot 0x907b80`, used_by `[]` — imported but zero static call edges observed in this index view (index-vs-CODE, not disproof of use; computed-pointer dispatch is explicitly invisible per P1 limits).
- `[D]` Limitation `no_match` on code names carried on the record.

### 2.5 `screen` — `ev_0002bdd6d862b968ee770f5a6b347fa49bab140b41e5c63a326dd442ed68f601` [D]

- `[D]` 13 matching strings, 1 matching function name, 3 matching imports, 1 function involved.
- `[D]` Function VA: `ScreenToClient@thunk @ 0x408d14` (calls `ScreenToClient`).
- `[D]` Imports: `GetConsoleScreenBufferInfo @ 0x90747c` used_by `[]`; `ScreenToClient @ 0x907778` used_by `0x408d14`; `ClientToScreen @ 0x9079d0` used_by `[]`.
- `[D]` Strings: `GetConsoleScreenBufferInfo @ 0x908836`, `ScreenToClient @ 0x909516`, `ClientToScreen @ 0x909ed8`, `TFORMHELLOSCREEN @ 0x94d120`, `LOSWFullScreenViewer @ 0x959481`, `HOSWScreen @ 0x9594a9`, `frmHelloScreen @ 0x959ae7`, `poScreenCenter @ 0x9617af/0x9643a1`, `TformHelloScreen @ 0x9688e5`, `formHelloScreen @ 0x9688f6/0x968943`, `poScreenCenter @ 0x968b86`.

### 2.6 `project` — `ev_b8682413b00674a271d57e4bb873dce308c830e9cfa06e73311f32f46f5a672d` [D]

- `[D]` 4 matching strings, 1 matching function name, 2 matching imports, 1 function involved.
- `[D]` Function VA: `gluProject@thunk @ 0x4afeec` (calls `gluProject`).
- `[D]` Imports: `gluUnProject @ slot 0x907b74` used_by `[]`; `gluProject @ slot 0x907b78` used_by `0x4afeec`.
- `[D]` Strings: `gluUnProject @ 0x90a67e`, `gluProject @ 0x90a68e`, `XProject @ 0x958c36`, `XDScriptProject @ 0x959353`.

### 2.7 `octree` — `ev_1f9395d35de6e07826dc3159ad1ca580f207ca053bff8d49242a7e4f323e72a6` [D]

- `[D]` 1 matching string, 0 matching function names, 0 matching imports, 0 functions involved.
- `[D]` Sole string: `POSWOctree @ 0x958bfa`.
- `[D]` Limitation `no_match` on code names carried on the record. The prior B8 12-float `OctreeRayCastIntersect` call shape is cited as prior context only, NOT re-proven here (no new bytes lifted for it in this ticket).

### 2.8 `raycast` — `ev_383505a5e507a2f2c3889afb9d5179656b4d5f83fb986afe02140ddd37c507fd` [D]

- `[D]` 0 matching strings, 0 matching function names, 0 matching imports, 0 functions involved. This is a negative index observation only.
- `[D]` Must be read as index-vs-CODE (case-insensitive literal `raycast` absent from the searched index; CODE-embedded/packed/runtime-built forms invisible). It is NOT disproof of raycast logic — §§2.4/2.6 import slots plus prior `OctreeRayCast*` / `GetGameObjectRayCast*` VAs (prior-ticket context) already show the feature family exists elsewhere.

### 2.9 `GetCursor` — `ev_4b163911375bf1abf63a463d878a5af25be3e50d768d71f2f5e20325fe3db5c5` [D]

- `[D]` 2 matching strings, 2 matching function names, 2 matching imports, 2 functions involved.
- `[D]` Function VAs: `GetCursor@thunk @ 0x4089dc` (calls `GetCursor`), `GetCursorPos@thunk @ 0x4089e4` (calls `GetCursorPos`).
- `[D]` Imports: `GetCursorPos @ slot 0x907900` used_by `0x4089e4`; `GetCursor @ slot 0x907904` used_by `0x4089dc`.
- `[D]` Strings: `GetCursorPos @ 0x909b94`, `GetCursor @ 0x909ba4`.

## 3. Function dossiers [D] — thunks (summary then complete) + caller/call-edge paging

All dossiers carry limitations: register-level (machine registers/stack slots; types not recovered), assumed x86 calling convention, flag-rebuilt branch conditions, inferred pseudo-C as reading aid. No types, field offsets, or numeric laws are taken from pseudo-C.

### 3.1 Thunk bodies — 1 block / 1 instruction each [D]

- `[D]` `gluProject@thunk @ 0x4afeec`, body range `0x4afeec–0x4afef2`, size `6` (`ev_7f07da25eab2c18a528b804a7d2f19f62dccf83fe362dfaca9e790eda8ca32ab`, summary then complete): assembly `jmp dword ptr [0x907b78]`; callees `1` (`gluProject`, import, tail call); signature `void gluProject@thunk()`; thunk_of `gluProject`; outgoing ref `0x4afeec → 0x907b78 (__imp_gluProject)`.
- `[D]` `ScreenToClient@thunk @ 0x408d14`, range `0x408d14–0x408d1a`, size `6` (`ev_c63c1c39473defe06749b9ed574136dcf38733e3575e482e713361daee8184ae`, summary then complete): assembly `jmp dword ptr [0x907778]`; callees `1` (`ScreenToClient`); outgoing ref `→ 0x907778`.
- `[D]` `GetCursorPos@thunk @ 0x4089e4`, range `0x4089e4–0x4089ea`, size `6` (`ev_5d44c3f3eacc1ca58a88471f29008c239d60eceee5520656246591f5f6293a12`, summary then complete): assembly `jmp dword ptr [0x907900]`; callees `1` (`GetCursorPos`); `9` callers / `9` incoming refs (see §3.2).
- `[D]` `GetCursor@thunk @ 0x4089dc`, range `0x4089dc–0x4089e2` (6 B), size `6` (`ev_e446ffeb84009b88843ee58cd7fd6f393bf2bb68566af5f53d44d91cbcc0c721`, summary): assembly `jmp dword ptr [0x907904]`; callees `1` (`GetCursor`); `1` caller (§3.2).
- `[D]` Field offsets: none recovered. Thunk dossiers list `0` parameters, `0` referenced strings, `0` unresolved calls, `0` flow parameters. Any struct-field reading from these records would be invention — none is made.

### 3.2 Call edges — byte-proven incoming refs [D]

- `[D]` `gluProject@thunk` has exactly `2` static callers in this view (`ev_220578aa17a7ec75d7b558d36e086d5e787031488f50e955e16228dea00d598f`, page of `ev_7f07da25…` callers): `sub_5811ec @ site 0x5812f1`, `sub_582914 @ site 0x582a1c`. Incoming refs `0x5812f1 → 0x4afeec`, `0x582a1c → 0x4afeec`.
- `[D]` `ScreenToClient@thunk` has exactly `2` static call sites, both inside one function (`ev_9cec28a09c6b3cf4e7efac182ded59448d1150c30cb183450c8c9f657d8d6e2`, page of `ev_c63c1c…`): `sub_492634 @ 0x4926a9` and `sub_492634 @ 0x4926b4`. Incoming refs `0x4926a9 → 0x408d14`, `0x4926b4 → 0x408d14`.
- `[D]` `GetCursorPos@thunk` has `9` static callers (`ev_f8d7c4bee21c2752ed7d43925ef95d6200c3e98a3d79348710828d0a64fd332`, page of `ev_5d44c3…`): `sub_469ed0 @ 0x469f56`, `sub_47d008 @ 0x47d011`, `sub_47d44c @ 0x47d524`, `sub_489e5c @ 0x489f73`, `sub_48c1e4 @ 0x48c248`, `sub_496784 @ 0x4969c4`, `sub_496c34 @ 0x496c38`, `sub_57a980 @ 0x57a981`, `sub_8bc510 @ 0x8bc51b`.
- `[D]` `GetCursor@thunk` has `1` static caller (`ev_0cb058d51b8f4fd6ff71a543d0c76b664af5f53d44d91cbcc0c721`, page of `ev_e446ff…`): `sub_47d610 @ 0x47d62b`.
- `[D]` Zero-static-user imports observed (index-vs-CODE, not disproof): `gluUnProject slot 0x907b74`, `gluPickMatrix slot 0x907b80`, `ClientToScreen slot 0x9079d0`, `select slot 0x907dec`, safe-array/Interleaved slots in §2.3. No uncalled/unused verdict is drawn.

### 3.3 Caller contexts — sizes and callee fans [D]

- `[D]` `sub_5811ec @ 0x5811ec` (`ev_c05d9c9c3a0e0a165e57e04eb7e96a71ba40f9f1706de0ce201e12d85a69e4e2`, summary): `39` blocks, `376` instructions, `58` callees, `1` caller, `0` strings. Callee page `ev_68be647731ac792c5f3976d1d75e8c3bba68354bf224cfb36e94a3d712ddcc6c` includes `gluProject@thunk @ site 0x5812f1 → 0x4afeec` plus `glMatrixMode @ 0x581393/0x5813b3/0x581745`, `glPushMatrix @ 0x581398/0x5813b8`, `glLoadMatrixf @ 0x5813a9/0x5813fe/0x58170c`, `glColorMask @ 0x581444/0x5815b1`, `glBegin @ 0x5814cd/0x581680`, `glVertex3f @ 0x5814ec/0x58150b/0x58152a/0x581549`, `glEnd @ 0x58154e/0x5816ff`, `glTranslatef @ 0x581679`, `glVertex2f @ 0x58169d/0x5816f6`, `glPopMatrix @ 0x58173b/0x58174a`, `glDisable @ 0x581589`, `glGetBooleanv @ 0x58159a`, `glReadPixels @ 0x5815f9`, and internal `sub_4a21a0/4a2504/4a2a08/4a3d40/4a2188/4a22f4/4ca428/88f148/88faf8/88fb14/4c05a4/4c06c0/4c08d0/4c08ec/4c0900/4bfa1c/4a6a5c/4e9bec/580a44/581080/580b7c/88f0f0`.
- `[D]` `sub_582914 @ 0x582914` (`ev_e95bd4a16cad53d8805d6efa164a552d5492762138dc35badae7dffa4182a1a8`, summary): `58` blocks, `551` instructions, `77` callees, `2` callers, `0` strings. Callee page `ev_f3e86e2410e307afaa1cb2795aab0748a2d0d085668ef3891b2177d1477f29d1` includes `gluProject@thunk @ site 0x582a1c → 0x4afeec` plus the same GL family (`glMatrixMode/glPushMatrix/glLoadMatrixf/glColorMask/glEnable/glBegin/glVertex3f/glEnd/glTranslatef/glPopMatrix/glGetBooleanv/glReadPixels`) with additional `glTexCoord2f @ 0x582e7b/0x582ebe/0x582f02/0x582f41` and internal `sub_582594/582700/5827f0/58267c/4ec794/4ecb24/403a28/4a35d4`.
- `[D]` `sub_492634 @ 0x492634` (`ev_510e0be0962b24061a584a4e5fb87cdf5c0693406cc72d74e11399da9f4c6013`, summary): `7` blocks, `64` instructions, `8` callees, `1` caller, `0` strings. Callee page `ev_2c0d34321bf6c120ac87efaf29346323b5da7ad516eea9b77ff01c16f423bcc4`: `IsIconic @ 0x492643 → 0x408bd4`, `GetWindowRect @ 0x492679 → 0x408b3c`, `GetWindowPlacement @ 0x492660 → 0x408b34`, `GetWindowLongA @ 0x492687 → 0x408b24`, `GetWindowLongA @ 0x49269c → 0x408b24`, `ScreenToClient @ 0x4926a9 → 0x408d14`, `ScreenToClient @ 0x4926b4 → 0x408d14`, `sub_48b160 @ 0x4926dd → 0x48b160`.
- `[D]` No ray-construction arithmetic, no projection-matrix literal, and no picked-entity identity is byte-proven by these edges. The dossiers prove that a `gluProject` call path and a `ScreenToClient` window-mapping path and a `GetCursorPos` mouse path exist as static code; what values flow through them is runtime-dependent and stays `[U]` (§4).

## 4. Unresolved — owner-gated runtime [U] with exact zero-mismatch termination

Each `[U]` needs owner-authorised live capture. Static bytes alone cannot close them. No value is guessed.

- `[U]` U1 — ray construction (origin + direction from cursor): which `GetCursorPos` caller (`§3.2` nine sites) feeds selection, what client→GL viewport transform applies, and whether `ClientToScreen`/`ScreenToClient` pair at `sub_492634` is on the pick path at all. Static proves the imports and call sites; live mouse state is invisible statically.
  - Termination (owner-only, zero-mismatch): fixed map seed, fixed 58/−32/400-style rig, FOW off; surveyed ground markers; scripted cursor pixels (centre + 4 corners + 1-px edge steps); log `GetCursorPos` client point + `GetCurrentMouseWorldCoord` ground point per pixel on the same frame. **Close only when one fitted client→world ray law re-projects ≥5 surveyed ground points to captured pixels with 0 px mismatch and predicts the 1-px edge steps exactly, on two viewports (e.g. 4:3 + 16:9 same height), before any ray coefficient is written as donor fact.**
- `[U]` U2 — projection matrix (modelview/projection/viewport fed to the two `gluProject` sites `0x5812f1`/`0x582a1c`): matrix contents, viewport rect, depth-range handling, and whether `gluUnProject @ 0x907b74` or `gluPickMatrix @ 0x907b80` participates at run time (both zero static users — index-vs-CODE). Prior camera work recovered start→camera wire only; no matrix math is recovered here.
  - Termination (owner-only, zero-mismatch): GL-trace capture on the fixed rig; log matrices + viewport at both `gluProject` sites plus `GetCameraAbsolutePosition` for surveyed points at two depths. **Close only when the traced inputs re-project ≥5 surveyed world points to captured pixels with 0 px mismatch AND the fitted matrix equals the traced matrix element-for-element, before any matrix literal is written as donor fact.**
- `[U]` U3 — picked-entity identity (which handle the engine returns for a click/drag, centroid-vs-AABB-vs-fraction rule, building/unit/resource membership, squad side effects, water/bridge handling). The 12-float `OctreeRayCastIntersect` shape is prior-ticket context, not re-proven here; `POSWOctree @ 0x958bfa`, `XPicked @ 0x9590fd`, `GameObject*RayCast*` names were not lifted in this ticket's nine passes.
  - Termination (owner-only, zero-mismatch): FOW off, grid of idle units at known spacing; scripted click pixels inset/outset 1–3 px around known units + both drag directions; log picked-handle set per rect. **Close only when one fitted membership rule predicts ALL probed rects including 1-px edge cases and both drag directions with zero membership mismatches, before any rule is written as donor fact.**
- `[U]` U4 — live mouse state (`GetCursor @ 0x4089dc` single caller `sub_47d610 @ 0x47d62b`; `GetCursorPos` nine callers): press vs first-move anchor, epsilon handling, mid-drag pan/zoom re-projection. No anchor pair, no drag threshold, and no marquee rect literal was lifted in this ticket.
  - Termination (owner-only, zero-mismatch): LMB press at surveyed pixel, hold, step 1–3 px across the epsilon boundary per axis; log press vs first-move vs per-step world points + selection-mode onset frame. **Close only when onset frame + frozen corner match exactly ONE of (press-point, first-move-point) with 0 px / 0.0 m mismatch on all four drag directions, before any anchor is written as donor fact.**
- `[U]` U5 — sensor/viewport binding, near/far, aspect literal, focal↔FOV numeric law: no `FOVSensor`/`Sensor`/`FarPlane` static hits (§§2.7–2.8 negatives are index-vs-CODE); `Aspect` strings are particle/spline props, not camera; `100.0f/2.0f/1.0f`-style table floats were not lifted in this ticket and are not re-claimed.
  - Termination (owner-only, zero-mismatch): same V1-SENSOR / V2-PROJ-NF / V2-PROJ-ASPECT captures as the prior select-deep ticket (two depths, ≥3 aspects, near/far clip bracketing). **Close only when one fitted family re-projects ≥5 surveyed points at every probed aspect/depth with 0 px mismatch AND predicts both clip boundaries exactly, before any (sensor, near, far, aspect) literal is written as donor fact.**

## 5. Claim register

| # | Claim | Label + evidence |
|---|---|---|
| 1 | Donor pin `t_87f0f3c130b0`, `5768048` B PE x86, SHA `87f0…16c` verified before any finding; donor never executed; no bytes copied | [D] §0 |
| 2 | Analysis incompleteness bounds: `18918` fns / `12073` strs / `746` imps; `6000000`-insn cutoff; `1238` unresolved indirect jumps; stripped; computed-pointer invisibility | [D] `ev_60b497434aa3e6cb68b019fd0a3b016ec0415ef6eec1a3189726faa8d3752f4c4` @ overview |
| 3 | `select`: 21 strs / 4 fnames / 5 imps / 4 fns; thunks `0x4086dc/0x4086e4/0x4086ec/0x5a2ff0`; slots `0x907560/0x907564/0x907568/0x907dd0/0x907dec` | [D] `ev_40b0648ec25a0dbf5c248f2fb5f4e791f969f4beff0e8a5c00fa905b556ac6` |
| 4 | `selection`: 1 str (`EXSelectionBrush @ 0x958d55`), 0 fns, 0 imps | [D] `ev_cc459bb14cf49ca3b301ff9d4a423a240760bf3dd9e7783344b0f7209e08d2df` |
| 5 | `ray` (substring): 17 strs / 1 fname / 6 imps / 1 fn; `glDrawArrays@thunk @ 0x4afb74`, slot `0x907d60` | [D] `ev_e5a90fcbfe0fde1558394cb58840d749031ed200e268d062453ad04ca9be5940` |
| 6 | `pick`: 2 strs (`gluPickMatrix @ 0x90a6a8`, `XPicked @ 0x9590fd`); import `gluPickMatrix @ 0x907b80` with 0 static users; 0 fns | [D] `ev_50d03d1594617ebc000bf5fb8362f1877d4ad3b1f73589f86671de8b172e9c25` |
| 7 | `screen`: 13 strs / 1 fname / 3 imps / 1 fn; `ScreenToClient@thunk @ 0x408d14`, slot `0x907778`; `ClientToScreen slot 0x9079d0` 0 users | [D] `ev_0002bdd6d862b968ee770f5a6b347fa49bab140b41e5c63a326dd442ed68f601` |
| 8 | `project`: 4 strs / 1 fname / 2 imps / 1 fn; `gluProject@thunk @ 0x4afeec`, slot `0x907b78`; `gluUnProject slot 0x907b74` 0 users | [D] `ev_b8682413b00674a271d57e4bb873dce308c830e9cfa06e73311f32f46f5a672d` |
| 9 | `octree`: 1 str (`POSWOctree @ 0x958bfa`), 0 fns, 0 imps; prior 12-float shape NOT re-proven here | [D] `ev_1f9395d35de6e07826dc3159ad1ca580f207ca053bff8d49242a7e4f323e72a6` |
| 10 | `raycast`: 0/0/0/0 — index negative only, not disproof | [D] `ev_383505a5e507a2f2c3889afb9d5179656b4d5f83fb986afe02140ddd37c507fd` |
| 11 | `GetCursor`: 2/2/2/2; `GetCursor@thunk @ 0x4089dc` slot `0x907904`; `GetCursorPos@thunk @ 0x4089e4` slot `0x907900`; strings `@ 0x909b94/0x909ba4` | [D] `ev_4b163911375bf1abf63a463d878a5af25be3e50d768d71f2f5e20325fe3db5c5` |
| 12 | Thunk bodies: `jmp dword ptr [slot]` 6 B each; `0x4afeec→0x907b78`, `0x408d14→0x907778`, `0x4089e4→0x907900`, `0x4089dc→0x907904`; 0 params / 0 strings / 0 field offsets | [D] `ev_7f07da25…`, `ev_c63c1c…`, `ev_5d44c3…`, `ev_e446ff…` @ VAs |
| 13 | Call edges: `gluProject` ← `0x5811ec@0x5812f1, 0x582914@0x582a1c`; `ScreenToClient` ← `0x492634@0x4926a9+0x4926b4`; `GetCursorPos` ← 9 sites (§3.2); `GetCursor` ← `0x47d610@0x47d62b` | [D] `ev_220578aa…`, `ev_9cec28a0…`, `ev_f8d7c4be…`, `ev_0cb058d5…` |
| 14 | Caller sizes/fans: `0x5811ec` 39blk/376insn/58 callees; `0x582914` 58blk/551insn/77 callees; `0x492634` 7blk/64insn/8 callees; callee VAs in §3.3 | [D] `ev_c05d9c9c…`, `ev_e95bd4a1…`, `ev_510e0be0…` + `ev_68be6477…`, `ev_f3e86e24…`, `ev_2c0d3432…` |
| 15 | Ray construction, projection matrix, picked-entity identity, live mouse state, sensor/near/far/aspect numerics | [U] U1–U5 §4, owner-only zero-mismatch captures |
| 16 | Any donor↔port behavioural equality | Denied — parity UNVERIFIED, no A/B frame, no gate PASS |

## 6. Scope statement

Exactly one repository file was written by this worker: this report. All donor reads were read-only against pin `t_87f0f3c130b0` (every binary call with `document=` pinned or active-target verified; donor binary never executed; no donor bytes copied; no `.bind` unpacking). No source, shader, config, asset, fixture, test, runner, Godot, git, or user-mod state was changed. No parity, similarity score, threshold, or gate PASS is claimed. Network out of scope.

Chain `0/6`. RESULT IS NOT GOOD.

*End of DEC_U_select_deep (SELECT-DEEP static worker).*
