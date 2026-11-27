---
id: DEC-U-SAVE-DEEP
worker: SAVE-DEEP (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-27
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87F0F3C130B027E7C4E72DC217EAE9D592982370D112E0D224897BC92AF4E16C"
donor: "READ ONLY. Donor binary never executed/copied/patched. Static decomp only via craftanything clean-room engine. No repo code/asset/config/Godot/git edit: this report is the only file written."
parity: "NO PARITY CLAIM. Parity UNVERIFIED, chain 0/6, RESULT IS NOT GOOD while blocking_unverified non-empty. No donor save produced, compared, or byte-asserted by this worker."
labels: "[D] byte-proven static fact (function VA + evidence id) · [U] UNVERIFIED with owner-only zero-mismatch save-roundtrip termination · [I] inference, flagged · PORT EXTENSION = port substitute, never donor law"
parent: "docs/terrain_swarm_2026-11-26/reports/DEC_U_save_contract.md + DEC_U_save_float.md + DEC_U_save_bits.md + DEC_U_save_tobj.md + PORT1TO1_u_classify.md"
scope: "Native save/load container + transform path only. Prior work (19-section serialized order, Integer-4LE/Byte-1B/String I32+ANSI/Float-4LE-single/Boolean-1B, v5 additive keys) untouched. This ticket is the native save-format dossier: literal search + thunk/edge study. No .bind unpacking, no port value wired."
tooling: "Complied: no tools.craftanything.native_* except native_function_study (summary then complete). Used core_target_open/session_show already open, core_overview_show, core_feature_find, native_function_study, core_evidence_browse only. Donor never executed."
---

# DEC-U-SAVE-DEEP — native save container / transform path (static only, 2026-11-27)

## 0. Pin + session (verified before any finding)

- [D] Active target `t_87f0f3c130b0` = `C:\Games\Cossacks 3\cossacks.exe`, `5768048 B`, `sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c` — `core_session_open` state (`open:true`, `targets[0].bytes=5768048`, `sha256` match). Donor never executed/copied. Matches required pin `t_87f0f3c130b0` / SHA256 `87F0F3C130B027E7C4E72DC217EAE9D592982370D112E0D224897BC92AF4E16C`.
- [D] `core_overview_show summary` (`ev_60b497434aa3e6cb68b019fd0a3b016ec0415ef6ec1a3189726faa8d3752f4c4`): PE x86, `18918 functions, 12073 strings, 746 imports, 18 libraries, 10 segments`. Limitations: discovery stopped after 6M instructions (incomplete), 1238 indirect jumps unresolved, stripped (generated `sub_*` names), static-only. Absence is not proof.

## 1. `core_feature_find` sweep — save/load/serialization literals

All queries case-insensitive, whole-target, engine `builtin 0.6.1`. Verbatim summaries:

| # | Query | Result | Evidence |
|---|---|---|---|
| F1 | `UserSaveProfile` | **0 strings, 0 functions, 0 imports** [D-absence] | `ev_e6d77458d121f998e208f5bdce85066300654b6fbfb866126287f9a6cf6e43ef` |
| F2 | `SaveStreamTypeBase` | **0 / 0 / 0** [D-absence] | `ev_0fa14161cb34a06ef695455f093839db2c3b4a3c741af830b8c1c4ed409c07c1` |
| F3 | `GameMapSnapShotBegin` | **0 / 0 / 0** [D-absence] | `ev_71011ee7e4528ac061f753caa84e0d843e89faa4db55175eddec367b85fc1642` |
| F4 | `GameMap` | **0 / 0 / 0** [D-absence] | `ev_15743afdce924f19ec5d244860f57e5aed1cc541e5a16fb04851b30743bde1ff` |
| F5 | `SaveMap` | **0 / 0 / 0** [D-absence] | `ev_cd41429768de4f7363366bd2f149aa57d3d00f5ccbaf6ed464be208ed110cdf8` |
| F6 | `WriteInteger` | **0 / 0 / 0** [D-absence] | `ev_f9e340d791fe0be6c11d8dfb99fe8cd9f42b04664fee79feaad6cd253c38fa52` |
| F7 | `WriteBoolean` | **0 / 0 / 0** [D-absence] | `ev_5eb0351c4c1cbfcbca181576676023a69b85857108435462419da75f912ab89e` |
| F8 | `WriteFloat` | **0 / 0 / 0** [D-absence] | `ev_8e52010e6e40f39294574afe32e92098b90be24580579a3c1cd98cd2f45ed5b2` |
| F9 | `WriteString` | **0 / 0 / 0** [D-absence] | `ev_ce559dbca50231b13885de22b01ee3330410462f6dd4da472275517193de05c7` |
| F10 | `TWriter` | **0 / 0 / 0** [D-absence] | `ev_60537beab46112797c1f775e822f01679e9db3608b12e5e1a4a41621a0674cc8` |
| F11 | `THandleStream` | **0 / 0 / 0** [D-absence] | `ev_d6b373077abc3787d9e71357eaf10514dd5fcb0f8243a5167e6d6bb01be324d0` |
| F12 | `checksum` | **0 / 0 / 0** [D-absence] | `ev_10ae0ad6c28a623c1548cc3303bd7a17419588bbcbed333429f68ff306973202` |
| F13 | `SaveGame` | **0 / 0 / 0** [D-absence] | `ev_19b1b159d6af82dde1e4c7e3a840a89e86acee48b564cb580988427825d76bc3` |
| F14 | `gamename` | **0 / 0 / 0** [D-absence] | `ev_1b2e17148afca8b9b6b450d9faedabec26e73300a9716b4cfed813907ae19298` |
| F15 | `.sav` | **0 / 0 / 0** [D-absence] | `ev_2d73ae68d74faae72f52282f211ef0901e4b71bb1c99070a93595a44fa46f7b1` |
| F16 | `StateMachineGlobalVariablesSaveToStack` | **0 / 0 / 0** [D-absence] | `ev_ae4a607a57795769e0b2f3a08f20aae13379a8c2d75d2ce1f3eec0d467b255b7` |
| F17 | `GetAppSaveDirectoryPath` | **0 / 0 / 0** [D-absence] | `ev_3d0020de94f9ebfba442981c976c0651af85ec6ac8b6103cffe684b3bd8812f4` |
| F18 | `serialize` | **1 string, 0 functions**: `OSWSerializer @0x958679` [D] | `ev_0d07054cd178f9aafc344e5eeba42183f280715738e42500fa5553a67e593d5f` |
| F19 | `OSW` | **79 strings, 0 functions** incl `OSWSerializer @0x958679`, `OSWFileStream @0x95886a`, `OSWPersistentClasses @0x958696`, `OSWConversions @0x9586be`, `gOSWApplicationFileIO @0x9583fd`, `vOSWZipFile @0x958414` [D] | `ev_9b1bdf76dde5e6aaf230ed0f2fa8158824268056cc825b5cd46c259b2bb141bf` |
| F20 | `save` | **34 strings, 1 function, 2 imports**: `SaveDC@thunk @0x4086d4`, imports `SaveDC slot 0x90756c`, `GetSaveFileNameA slot 0x907b48`; strings are UI/dialog (`TSaveDialog`, `SaveMenuItem`, `ACSave*`, `Save script`, `PopupSaveItem`) — no container verb [D] | `ev_6e16941521d8ee051da8d8483681adc3892085a1cebbd1fcc47f7e5b13ce4694` |
| F21 | `load` | **26 strings, 10 functions, 13 imports**: all `LoadLibrary/LoadString/LoadCursor/LoadResource/glLoadIdentity/glLoadMatrixf` thunks (`0x4013c8,0x4013d0,0x40836c,0x408374,0x408c1c,0x408c24,0x408c2c,0x408c3c,0x4afd4c,0x4afd54`) + editor `Load script` strings — no save-load verb [D] | `ev_ba656f3d8f05f1fd07bf6498bf002f0973fe021db289cdd297b8259c077d76bf` |
| F22 | `section` | **9 strings, 8 functions**: all `CriticalSection/DIBSection` thunks (`0x4014a4,0x4014ac,0x4014b4,0x40817c,0x40818c,0x40835c,0x408364,0x4084f4`) — no save-section label [D] | `ev_8770dc590e423815274fc8d7f78abffadf6f893c574578dbd8c044f1400d3c30` |
| F23 | `version` | **14 strings, 3 functions, 5 imports**: `GetVersion@thunk @0x4082fc`, `GetFileVersionInfoA @0x408494`, `GetFileVersionInfoSizeA @0x40849c`; strings `VS_VERSION_INFO @0x96b10a`, `FileVersion`, `ProductVersion`, `unknown archive version` — no save-version word [D] | `ev_2b1220e2a363a33dc94ebf0453e8b38031ed611cc34a95b1b75e4c4c93036f26` |
| F24 | `WriteFile` | **2 strings, 2 thunks, 2 imports**: `WriteFile@thunk @0x401340` (slot `0x9072b8`, string `WriteFile @0x9080c0`), `WriteFile@thunk @0x40847c` (slot `0x907360`, string `@0x908352`), both `kernel32.dll` [D] | `ev_7ee01206b204ddfd8c73d8ab1f1af207863bdc41aad2ed6fd7745df886e5a1cb` |

[D-grouping]: all Delphi script-level save verbs (`UserSaveProfile*`, `SaveStreamTypeBase`, `WriteInteger/Boolean/Float/String`, `TWriter/THandleStream`, `GameMapSnapShot*`, `StateMachine*`, `GetAppSaveDirectoryPath`) are absent from the PE decoded string/function/import tables. They live in the script/packed layer (cf. prior ASCII-offset scans), not as linkable native symbols. The native image exposes only generic OS/file/UI vocabulary (`OSWSerializer`, `OSWFileStream`, `SaveDC`, `GetSaveFileNameA`, `WriteFile`, `VS_VERSION_INFO`). No section count/label, no field width, no key, no `.sav` suffix is recoverable from this layer — nothing invented.

## 2. `native_function_study` (summary then complete) + `core_evidence_browse` paging — transform / file-write edges

- [D] `WriteFile@thunk @0x401340`: 1 block / 1 insn `jmp dword ptr [0x9072b8]`, 1 callee (`WriteFile` import), 3 callers. Summary + complete: `ev_bc2f9b7538cdc499f9c9e98b18ce15e19bd62ea5c0c63bd0b42342b6f549a01d`. Browse page confirms callers (`ev_d3c4b91ee2ab007e0b3d008d2546f42a6db648b2def08b722ee42dabf0010546`, 3/3 rows): `sub_403568 @0x403587`, `sub_4051d8 @0x405217`, `sub_4051d8 @0x405232`.
- [D] `WriteFile@thunk @0x40847c`: 1 block / 1 insn, 1 callee, 2 callers. Summary: `ev_9d6ba181b6615fadc5319a3b7c8030eeab4138b2c5deaba34249fbc0c173b6c6`.
- [D] `SaveDC@thunk @0x4086d4`: 1 block / 1 insn, calls `SaveDC` (GDI), 4 callers — display-context save, not game-save. Summary: `ev_343109ce144b74f4b68442ecf1cfe1fddcb272f523f90b7ecb7e36432b7bca92`.
- [D] `sub_4051d8 @0x4051d8` (complete, `ev_b63d23681a17a8263a48bc1158151fd2f3fb49b6c234ac1e4b89ae807453a01d`): 8 blocks / 38 insns. Callees: `GetStdHandle@thunk @0x401308` ×2, `WriteFile@thunk @0x401340` ×2 (`0x405217`, `0x405232`), `MessageBoxA@thunk @0x401368`, +1 unresolved indirect `call [0x8fd238]`. Referenced strings: `Runtime error     at 00000000 @0x8f2084`, `Error @0x8f207c`. Both `WriteFile` sites push `0xfffffff5` (= `STD_ERROR_HANDLE`/`-11`) via `GetStdHandle` — i.e. console error-report path, with `push 0x1e` / `push 2` lengths and `sub_405260 @0x405260` data ref. Caller: `sub_405260 @0x40529d`. This terminates the only fully-resolved `WriteFile` edge in this dossier: **runtime-error reporter, not save container writer**.
- [D] `sub_403568 @0x403568` (summary, `ev_2bac1ca114753eca441266ff29d0d8567fa36e8a626010b2e23a42eb39683da5`): 7 blocks / 29 insns, 2 callees, 0 callers in table (entry/root). No save string, no transform constant in dossier facet.
- [D] Browse `summary` re-read of `ev_bc2f9b7538cdc499f9c9e98b18ce15e19bd62ea5c0c63bd0b42342b6f549a01d` (`ev_35f100a5863df10a6679871f1631cc488fc29992b4c60353135322d782638731`, all-in-view) confirms no hidden facet: 1 asm / 1 block / 1 callee / 3 callers / 0 strings.

[D-boundary]: no static call edge connects any save literal (all §1 F1–F17 zero-hit) to either `WriteFile` thunk, to `SaveDC`, or to `glLoadMatrixf/Identity` transform thunks (§1 F21). Transform getters (`GetGameObjectPosition*` family) are script-level names with zero native hits here; no native transform-write edge is claimed. Field widths (Integer/Float/String/Boolean byte sizes), section counts/labels, key transforms, checksum placement are **not** in this native layer — they remain script-layer facts from parents, cited not re-proven here.

## 3. Still-[U] register (nothing invented; each item names its closing experiment)

| # | Byte(s) | Static state after THIS ticket | Closing experiment (owner-authorised; donor binary run by owner, never this worker) |
|---|---|---|---|
| R1a | Outer container magic/lengths | [D-absence] in native tables (§1 F3–F5/F15: `GameMapSnapShotBegin/GameMap/SaveMap/.sav` all 0 hits); envelope known only from script/shipped-`.map` parents, untouched here | E-A §4 prior: paired saves differing only in `gfloat_peacetime`; hexdump 0–256 B; assert word0=`5C 00 00 00`, tag-identity, first-divergence at peacetime field, `GameMapRecordEnd/GameMapEnd` present. Zero-mismatch: identical-state re-save byte-identical end-to-end (any trailer divergence feeds R1g). 3 repeats. |
| R1b | Float/Bool patterns | [D] from parents (not re-proven natively; native `WriteFloat/WriteBoolean` 0 hits §1 F7–F8) | E-R1b retained: `rallyx=1.0`→`00 00 80 3F`, `fStandGround`→single `01/00`. Zero-mismatch: exactly one 1 B divergence per toggled Boolean. |
| R1c | String codepage | [D] ANSI per parent; native layer silent | E-R1c retained: `Test` vs `Testé` length-prefix/encoding assert. |
| R1d | Engine transform placement + width | [D-boundary]: absent from native string/function tables (§1–§2: no edge from any save verb to `WriteFile`/GL-matrix thunks; `WriteFile` edge terminates at STD_ERROR reporter `sub_4051d8`) ; placement/width [U] | E-D: one unit mid-move at known (x,z); hexdump for adjacent IEEE-754 words near `uid` anchor; re-save with x+=delta; assert exactly one 4 B word diverges by exact single-precision delta; record neighbours (TObj tail vs TOrderInfo vs engine block vs TMapPlayer). Control at rest. Zero-mismatch: identical-state re-save identical except six documented jitter floats (`serial.script:870-875` + `uniqrnd=0→random`). |
| R1e | `victorystate` table | CLOSED [O] `none=0/win=1/lose=2` per parent; native layer has no vote | None (mapping). Win-write path behavioural [U], out of scope. |
| R1f | `TWallSystem/Cluster/Cell`, grids, `TInterface`, `TScenario`, path lists, `TProj` tails | Type names + 19-order [O] per parent; per-word layout [U]; native `OSW*` strings (§1 F19) are class-library names, not field layouts | E-T1..T5 per tobj-ticket: vary one wall cell / trigger / grid mark / projectile; single-divergence assert. |
| R1g | Checksum/compression/trailer | [D-absence] natively: `checksum`=0, `SaveGame`=0 replicate (§1 F12–F13); only file-write import is `WriteFile` ×2 whose resolved edge is error-reporting (§2), not container I/O | E-G: identical-state pair bit-compared INCLUDING trailers; byte-identical ⇒ declare no checksum/compression [D]; any trailing-word divergence ⇒ isolate, length-prefix-decode, report as flag, never force-fit. |
| R1h | Profile-store file identity/encoding/flush | Verbs absent natively (§1 F1/F16–F17); store not in donor tree per parent; file name/encoding/timing [U] | E-A+E-B: store snapshots across boot/Accept/Start; file-monitor pairing of OS write target to `UserProfileSaveMap` vs `UserSaveProfileExt`. Zero-mismatch per §3 header. |

Common harness (all E-runs): pin `t_87f0f3c130b0`; fixed map/seed/preset; two saves differing in exactly ONE named field + third identical-state re-save. **Zero-mismatch criterion: all non-divergent bytes identical across the pair AND the re-save, except the six documented jitter floats.** Any OTHER divergence = FAIL, no tolerance. Three repeats per case. Owner-only; this worker never runs the donor.

## 4. Explicit non-claims + file discipline

- NO PARITY CLAIM. `parity.claim = NONE`, `parity.status = UNVERIFIED`, `visual_parity_claim = false`. Six-condition chain 0/6 CLOSED. `blocking_unverified` non-empty (P0-1…P0-8 plus save/transform tails per `PORT1TO1_u_classify.md`). Verdict: **RESULT IS NOT GOOD**.
- No number invented: no section count/label, no field width, no key, no transform, no checksum/compress value is asserted from this native layer. Every unrecovered byte is a named [U] above with an owner-only paired-save experiment and zero-mismatch criterion — never a filler constant.
- No `.bind` unpacking; no port value wired; no `game.gd`/config/test/gate touched.
- Read-only compliance: exactly one repo file written (this report). Donor reads were `core_feature_find` / `native_function_study` / `core_evidence_browse` / `core_overview_show` over the pinned read-only target; donor binary never executed, never copied; no disassembly bytes quoted as instructions beyond thunk `jmp` + caller/callee/string refs above.
- Network out of scope: `RecordCustom*` excluded per parents; no net claim here.

*End of DEC-U-SAVE-DEEP.*
