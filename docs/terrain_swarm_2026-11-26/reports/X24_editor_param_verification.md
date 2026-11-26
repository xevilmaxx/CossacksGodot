---
id: X24
ticket: "TERRAIN-SWARM-2026-11-26 / X24 — READ-ONLY verification of D09 editor→cfg parameter mapping"
task: "Independently re-derive the TFormMapGen VMT→method-table→handler anchor, the 0x87b7ec orchestrator, handler→cfg-key assignments, cfg key cross-check, and 12 stage flags"
date: 2026-11-26
status: DELIVERED__READ_ONLY__NO_DONOR_EXECUTION__NO_REPO_EDITS_EXCEPT_THIS_REPORT
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION"]
target: "C:\\Games\\Cossacks 3\\editor.exe — 7,874,416 B, SHA-256 68474ddde43fe4aa084613f01946734a7eea6d511fb98dd81326e8be2ed250ab"
craft_anything_target_id: t_68474ddde43f
active_target_at_start: t_87f0f3c130b0 (cossacks.exe)
active_target_at_end: t_87f0f3c130b0 (restored and re-verified after shared-session churn)
donor_parity_claim: false
scope: "Exactly one repo file written: this report. No donor binary executed/copied; no source, shader, config, asset, test, git or Godot-runner change."
---

# X24 — independent verification of D09's editor→cfg parameter map

## Executive summary

1. **[O] The anchor chain is confirmed from raw bytes, not just from D09's prose.** `TFormMapGen` VMT `0x73ebb8` stores field table `0x73ecac` (98 fields), method table `0x73f6c0` (39 methods) and a shortstring `TFormMapGen` at `0x73fb60`. Method-table entry #2 is `ButtonApplyGlobalParamsClick = 0x73fe50`; entry #3 is `ButtonGenerateClick = 0x7400d0`. `TGlobalMapForm` VMT `0x7449dc` stores field table `0x744ad0` (141 fields), method table `0x7459de` (30 methods), class name `TGlobalMapForm` at `0x745db7`, with `ButtonGenerateClick = 0x746754` and `ButtonApplyClick = 0x7467dc`. Evidence: `ev_b84e5217…`, `ev_16b0cdcf…`, `ev_87185b2c…`, `ev_8d5631b2…`, `ev_76982e76…`, `ev_6fa43455…`.
2. **[O] The orchestrator anchor is independently confirmed at instruction level.** `0x7467b4` inside `TGlobalMapForm.ButtonGenerateClick` is `e8 33 50 13 00` → `call 0x87b7ec`; Craft Anything's own decoder reports the same target (`ev_5dba1d4a…`). The four progress strings are loaded from `0x87ba30 / 0x87ba54 / 0x87ba74 / 0x87ba90` and their literal bytes were re-read (`ev_cf724abc…`, `ev_0c532cda…`).
3. **[O] Eleven handler→cfg-key assignments were verified instruction by instruction in `ButtonApplyGlobalParamsClick` (requirement was ≥3).** All eleven D09 §5.3/§7 field writes are present at the cited addresses; one D09 pseudocode label is wrong (§5.2 correction C1 below) and one cited converter address is not used by this handler (C2).
4. **[O] Cross-check of UI control names vs F03 §3 literal cfg keys: 24/24 `TFormMapGen` controls and 13/13 `localparams.cfg` controls cited by D09 exist verbatim at the cited slots.** All 20 global + 13 local literal keys were re-read from donor text (hashes match F03). Three mappings are *semantic, not literal* (`AddCastles`↔`CheckBoxIsAddCastles`, `CastleType`↔`EditCastleTypeName`, local `Name`↔`EditLocalParamsItemName`). Four global keys (`CastlePlayer*`, `CastlePatternsPlayer*`) are **omitted from D09 §7** but exist as `TXGlobalParams` RTTI properties; D09's [U] about `MapFrequency`/`BorderFrequency`/`OnMap`/`OnBorder` is **resolved** — they are literal keys in `mapcover.cfg:26-30`.
5. **[O] All 12 stage flags and their checkbox sources were verified at instruction level**, and the orchestrator's conditional call order matches D09 §5.1. **[O/D] The editor binary proves an editor-side orchestration order only.** `cossacks.exe` contains a *different* generator routine (`sub_721850`, strings `Updating horizon texture...` / `Generation finished`, different flag offsets and logger `0x8ce498`), so the editor's 12-flag order must **not** be promoted to skirmish truth; skirmish order stays `[U]` (text-only `dogenerate.inc`/`generatemap.inc` evidence per F09).
6. **[O] No donor-parity claim.** No donor GPU A/B frame exists; every port consequence below is `PORT APPROXIMATION`.

---

## Evidence table

| id / citation | Establishes | Class |
|---|---|---|
| `ev_b84e5217…` (`native_bytes_show 0x73eb80`, 96 B) | VMT dwords: `0x73ecac` field table, `0x73f6c0` method table, `0x73fb60` class-name shortstring, instance size `0x48c` | [O] |
| `ev_9167f1d4…` | bytes at `0x73fb60` = `\x0b` + `"TFormMapGen"` | [O] |
| `ev_16b0cdcf…` (`0x73f6c0`, 64 B) | method-table count 39; entries begin `ButtonLoadGlobalParamsClick=0x73fd40`, `ButtonSaveGlobalParamsClick=0x73fdd4` | [O] |
| parsed from `ev_16b0cdcf…` (1280 B re-read) | entry #2 `ButtonApplyGlobalParamsClick=0x73fe50`, #3 `ButtonGenerateClick=0x7400d0` | [O]+[D] |
| `ev_5457720f…`, `ev_6fa43455…` (`0x73ecac`, 8192 B) | field-table count 98; all 24 mapped controls and slots verified (e.g. `EditSharpness +0x310`, `ButtonTileSmoothListFileName +0x468`) | [O] |
| `ev_87185b2c…` (`0x7449a8`), `ev_566ccc39…` (`0x745db7`) | `TGlobalMapForm` method table `0x7459de`, field table `0x744ad0`, class name `\x0e` + `"TGlobalMapForm"` | [O] |
| `ev_8d5631b2…`, parsed | method-table count 30; `ButtonGenerateClick=0x746754`, `ButtonApplyClick=0x7467dc` | [O]+[D] |
| `ev_76982e76…` (`0x744ad0`, 5120 B) | field-table count 141; all 12 checkbox names at slots `+0x384/0x3a8/0x3b4/0x3b8/0x3bc/0x3d0/0x3dc/0x418/0x44c/0x47c/0x490/0x494` | [O] |
| `ev_911d6d96…` (`0x746754`, 144 B), `ev_5dba1d4a…` | `call 0x87b7ec` at `0x7467b4` | [O] |
| `ev_b9e76ecf…` (`0x73fe50`, 1536 B); `ev_e6bec578…`, `ev_a355728e…`, `ev_ffd59078…`, `ev_46fc00de…`, `ev_0bbae189…` | 11 instruction-level handler→key assignments | [O] |
| `ev_409fdb59…` (`0x7467dc`, 1536 B); `ev_9e61d2f2…` (`0x746bff`) | 12 checkbox→flag byte writes | [O] |
| `ev_cf724abc…` (`0x87b7ec`, 1024 B) | flag tests `+0x90..+0x9b`, call order, four string pointers | [O] |
| `ev_0c532cda…` (`0x87ba28`, 128 B) | literal `Pattern library loading ...` (len 27), `Generating terrain...` (21), `Updating horizon...` (19), `Generation finished` (19) | [O] |
| `ev_810c764dfdb1f…`, `ev_ae07060d…`, `ev_8345eacf…` | verbatim donor `globalparams.cfg` (537 B, sha `15a8dc64…`), `localparams.cfg` (508 B, `8d174830…`), `mapcover.cfg` (1196 B, `ff0a7bf4…`) — match F03 §3 | [O] |
| `ev_f6c29f3e4…` (`0x884fd7`, 1536 B) | `TXGlobalParams` RTTI property names, including all 20 cfg keys (modulo `IsAddCastles`, `CastleTypeName`) | [O] |
| `ev_14ce3b9f3…`, `ev_65c36158…` (`0x73e0cc`) | `TLocalParamsItemForm` field table: `EditMapFrequency +0x300`, `CheckBoxOnMap +0x30c`, `CheckBoxOnBorder +0x310`, `EditBorderFrequency +0x318` | [O] |
| `ev_bf08e2fc…` (`cossacks.exe 0x721bc4`), `ev_5efdc61f…`, `ev_05156eab…`, `ev_db0c7fc4…` | cossacks.exe has `Generation finished` in CODE, referenced from `sub_721850`; adjacent string `Updating horizon texture...` at `0x721ba0` | [O] |
| `ev_de4a36c2…`, `ev_d706041d…` | `native_strings_find` (data sections only) reports 0 for "finished"; `native_bytes_find` reports 1 in CODE — tool-scope artifact, not absence | [O] |
| `ev_910e85da…`, `ev_48272556…` | first-pass mis-decode of VMT data as `pushad` / `shl dh,0x73` — superseded by `ev_b84e5217…` | [O] anomaly |
| D09 `ev_cf5741da…`, `ev_447f029e…`, `ev_eb276585…`, `fnd_27`, `fnd_28` | D09's prior string/anomaly evidence, used only as a cross-reference, never as the source of this verification | [O]/[D] |

Tool instruments: Craft Anything `native_bytes_show`, `native_bytes_find`, `native_instruction_show`, `native_address_show`, `native_xrefs_list`, `native_function_find`, `core_text_read(path=)`, `core_session_show`, `core_target_select`; plus in-memory `capstone` 5.0.7 decoding of **the exact bytes returned by `native_bytes_show`** (file offsets echoed by that tool: `0x73fe50→3404368`, `0x7467dc→3431388`, `0x87b7ec→4697068`). No tool was used to alter a target's contents.

---

## Method and multi-pass log

**Pass 1 — target/session isolation [O].** `core_session_show`: editor.exe open as `t_68474ddde43f`, sha matches D09; active `t_87f0f3c130b0` (cossacks.exe). Every native call was pinned with `document:"t_68474ddde43f"`; cfg reads used `path=` exclusively.

**Pass 2 — VMT bytes [O].** `native_bytes_show` at `0x73eb80`/`0x7449a8`. Accepted dword reads; see anomaly A1.

**Pass 3 — structural table decode [O]+[D].** Parsed Delphi method table as `word count; {word index; dword code; byte len; chars}` and field table as `word count; dword typeinfo; {dword slot; word tag; byte len; chars}`; calibrated on the known shortstrings and cross-checked on three forms.

**Pass 4 — instruction-level anchor [O].** `native_instruction_show` at `0x73fe50`, `0x87b7ec`, `0x7467b4`, `0x73fe9f`, `0x73fee1`, `0x73ff15`, `0x73ff47`, `0x73ffa4`, `0x746bff` — decoder agrees with the capstone listing of the same addresses.

**Pass 5 — capstone full-handler decode [O]/[D].** Engine function discovery and external disassemblers were unavailable (A2), so bytes from pass 2 were decoded in memory to `ret`, then spot-checked with pass 4.

**Pass 6 — donor text [O].** `core_text_read(path=…)`; no target switch. Hashes match F03 §2.

**Pass 7 — cross-binary [O].** `native_bytes_find` pinned per target; cossacks.exe routine inspected with a file-path-only capstone pass after the target was closed externally (A4).

### Anomaly log (every contradiction re-run, none silently skipped)

| # | Anomaly | Passes | Accepted reading |
|---|---|---|---|
| A1 | `native_instruction_show` on VMT data reported `0x73eb8c: pushad`, `0x73eb84: shl dh,0x73` (`ev_910e85…`, `ev_482725…`) — looked like D09's offsets were wrong | 1 instruction decoder → 2 `native_bytes_show` (`ev_b84e5217…`: `60 fb 73 00` = `0x73fb60`; `c0 f6 73 00` = `0x73f6c0`) → 3 class-name shortstring `TFormMapGen` at `0x73fb60` (`ev_9167f1d4…`) | Data was mis-decoded as code by pass 1; **D09's offsets are correct** |
| A2 | `native_function_disassemble` / `native_function_find` say `function_not_found` for `0x746754`, `0x87b7ec`, `0x73fe50`; `native_objdump_run` and `native_rizin_command_run` both `engine_missing` | 1 engine study → 2 objdump → 3 rizin → 4 `native_bytes_show` + capstone → 5 `native_instruction_show` spot-check | Capstone on Craft Anything bytes accepted; same limitation as D09 §2.2, independently reproduced |
| A3 | `native_strings_find "finished"` on cossacks.exe → 0 (`ev_de4a36c2…`) while `native_bytes_find "Generation finished"` → 1 in CODE at `0x721bc4` (`ev_bf08e2fc…`) | 1 data-section strings tool → 2 whole-file bytes tool → 3 `native_xrefs_list` → 4 file-path capstone on `sub_721850` | Strings tool is data-sections-only; the CODE string is real. Not a contradiction to D09, but a **new** fact D09 did not list |
| A4 | Shared-session churn: active drifted to editor.exe after native calls; mid-task another worker closed `t_87f0f3c130b0` and opened `cossacks.cdx` (`t_1a88936e8319`); later cossacks.exe reappeared | 1 restore `core_target_select(t_87f0f3c130b0)` during the VMT pass → 2 record closure and continue with `path=`/file-only instruments → 3 final `core_target_select(t_87f0f3c130b0)`, verified active | Final active target restored per task; no other worker's target was opened or closed by X24 |
| A5 | D09 §5.3 says the resize trigger is `newFailStandCount != oldSize` | 1 read D09 → 2 capstone `0x73ffe6..0x740058` | **Correction C1:** the compared edit is `EditCellsResolution` (`[ebx+0x354]`) vs `[esi+0x1c]`, not `FailStandCount` |
| A6 | D09 §2 lists converter `0x40f134` among the apply-handler conversions | 1 read D09 → 2 full capstone listing of `0x73fe50..0x740084` → 3 `native_address_show` (`0x40f134` is `sub_40f134`, 105 xrefs elsewhere) | **Correction C2:** this handler uses `0x40f0f8` (float), `0x40cc14` (int64), `0x40cba0` (int32); `0x40f134` is not called here |

---

## Verification results

### 1. Anchor chain (all addresses [O]; structure [D])

```
TFormMapGen VMT 0x73ebb8
  -0x38 -> 0x73ecac  field table   (98 entries)   ev_b84e5217…, ev_6fa43455…
  -0x34 -> 0x73f6c0  method table  (39 entries)   ev_16b0cdcf…
  -0x2c -> 0x73fb60  "\x0b TFormMapGen"           ev_9167f1d4…
  -0x28 -> 0x000048c instance size
method table 0x73f6c0:
  #2  index 0x23  0x73fe50  ButtonApplyGlobalParamsClick
  #3  index 0x1a  0x7400d0  ButtonGenerateClick
TGlobalMapForm VMT 0x7449dc            ev_87185b2c…
  -0x38 -> 0x744ad0 field table (141)  ev_76982e76…
  -0x34 -> 0x7459de method table (30)  ev_8d5631b2…
  -0x2c -> 0x745db7 "\x0e TGlobalMapForm" ev_566ccc39…
  method #5  0x746754 ButtonGenerateClick
  method #6  0x7467dc ButtonApplyClick
orchestrator: 0x7467b4 e8 33 50 13 00 -> call 0x87b7ec   ev_5dba1d4a…
```

**Verdict: D09's anchor chain is correct.** One presentation nuance: the method table *starts with a 2-byte count*, so `0x73f6c0` itself is the count word (`0x27`=39), not an entry; D09's headline address is the table base, which is the correct pointer stored in the VMT.

### 2. Handler→cfg-key assignments, instruction level (`ButtonApplyGlobalParamsClick` 0x73fe50)

`ebx` = form; `esi = [[ebx+0x480]+4]` = `TXGlobalParams` field-area object ("B" in D09); `GetText = 0x49cb0c`; `StrToFloat = 0x40f0f8`; `StrToInt = 0x40cba0`; `StrToInt64 = 0x40cc14`; `AssignStr = 0x405424`. Source bytes `ev_b9e76ecf…`.

| cfg key (F03 line) | control slot | instruction(s) | target | label |
|---|---|---|---|---|
| `Sharpness` (:3) | `EditSharpness +0x310` | `0x73fe8c` GetText → `0x73fe9a` float → **`0x73fe9f fstp [esi+0x10]`** | B+0x10 | [O] |
| `RandomKey` (generator field, not a cfg line) | `EditRandomKey +0x314` | `0x73fea6` → `0x73feb4` int64 → `0x73fec5/0x73fec8` | `[[ebx+0x480]+0x1a8]+0x18/+0x1c` | [O] |
| `TileChangeFactor` (:4) | `+0x37c` | `0x73fece` → `0x73fedc` → **`0x73fee1 fstp [esi+0x14]`** | B+0x14 | [O] |
| `FrequencyFactor` (:5) | `+0x3d0` | `0x73fee8` → `0x73fef6` → **`0x73fefb fstp [esi+0x18]`** | B+0x18 | [O] |
| `FailStandCount` (:7) | `+0x418` | `0x73ff02` → `0x73ff10` int → **`0x73ff15 mov [esi+0x20],eax`** | B+0x20 | [O] |
| `DefaultMapSize` (:8) | `+0x43c` | `0x73ff1b` → `0x73ff29` → `0x73ff2e mov [esi+0x24],eax` | B+0x24 | [O] |
| `TileSmoothPasses` (:9) | `+0x458` | `0x73ff34` → `0x73ff42` → **`0x73ff47 mov [esi+0x28],eax`** | B+0x28 | [O] |
| `TileSmoothListFileName` (:10) | `+0x464` | `0x73ff4d` → **`0x73ff5e call 0x405424`** with `eax=&[esi+0x2c]` | B+0x2c | [O] |
| `CastlePlateauFactor` (:19) | `+0x470` | `0x73ff66` → `0x73ff74` → `0x73ff79 fstp [esi+0x50]` | B+0x50 | [O] |
| `CastleType` (:20) | `+0x478` | `0x73ff80` → `0x73ff91 call 0x405424` | B+0x54 | [O] |
| `AddCastles` (:18) | `CheckBoxIsAddCastles +0x46c` | `0x73ff9c` vtable `+0xc8` GetCheck → **`0x73ffa4 mov [esi+0x4c],al`** | B+0x4c | [O] |
| `CellsResolution` (:6) | `+0x354` | `0x73ffe6` GetText → `0x73fff9 cmp eax,[esi+0x1c]` → `0x740005` re-read → `0x740026/0x740038` rescale `form+0x484/+0x488`, `0x740058 mov [esi+0x1c],edi` | conditional resize, not an unconditional B write | [O] |

The required ≥3 are exceeded: `Sharpness`, `TileChangeFactor`, `FailStandCount`, `TileSmoothPasses`, `AddCastles` were additionally re-verified with `native_instruction_show` (`ev_e6bec578…`, `ev_a355728e…`, `ev_ffd59078…`, `ev_46fc00de…`, `ev_0bbae189…`).

### 3. UI control ↔ literal cfg key cross-check

All key literals below were re-read from donor text, matching F03 §3.1/§3.2 verbatim (`ev_810c764dfdb1f…`, `ev_ae07060d…`, `ev_8345eacf…`).

**`globalparams.cfg` (20 keys):**

| line / key | D09 control (slot) | control exists at slot [O] | literal control-name = key? | verdict |
|---|---|---|---|---|
| :2 `Size` | none | — | — | [U] no control; RTTI name `Size` @ `0x885055` |
| :3 `Sharpness` | `EditSharpness` +0x310 | yes | exact | MATCH |
| :4 `TileChangeFactor` | `EditTileChangeFactor` +0x37c | yes | exact | MATCH |
| :5 `FrequencyFactor` | `EditFrequencyFactor` +0x3d0 | yes | exact | MATCH |
| :6 `CellsResolution` | `EditCellsResolution` +0x354 | yes | exact | MATCH (conditional path) |
| :7 `FailStandCount` | `EditFailStandCount` +0x418 | yes | exact | MATCH |
| :8 `DefaultMapSize` | `EditDefaultMapSize` +0x43c | yes | exact | MATCH |
| :9 `TileSmoothPasses` | `EditTileSmoothPasses` +0x458 | yes | exact | MATCH |
| :10 `TileSmoothListFileName` | `EditTileSmoothListFileName` +0x464, `ButtonTileSmoothListFileName` +0x468 | yes (both) | exact | MATCH |
| :11 `CastlesFileName` | none | — | — | PARTIAL: RTTI @ `0x8851ea`, no `TFormMapGen` control |
| :12 `PatternPlayerName` | none | — | — | PARTIAL: RTTI @ `0x885214` |
| :13 `PatternPlayerRace` | none | — | — | PARTIAL: RTTI @ `0x885240` |
| :14 `CastlePlayerName` | **absent from D09 §7** | RTTI only | — | **GAP in D09**; RTTI @ `0x88526c` |
| :15 `CastlePlayerRace` | **absent from D09 §7** | RTTI only | — | **GAP in D09**; RTTI @ `0x885297` |
| :16 `CastlePatternsPlayerName` | **absent from D09 §7** | RTTI only | — | **GAP in D09**; RTTI @ `0x8852c2` |
| :17 `CastlePatternsPlayerRace` | **absent from D09 §7** | RTTI only | — | **GAP in D09**; RTTI @ `0x8852f5` |
| :18 `AddCastles` | `CheckBoxIsAddCastles` +0x46c | yes | **MISMATCH**: `IsAdd` prefix (RTTI name is `IsAddCastles` @ `0x885328`) | MATCH semantically |
| :19 `CastlePlateauFactor` | `EditCastlePlateauFactor` +0x470 | yes | exact | MATCH |
| :20 `CastleType` | `EditCastleTypeName` +0x478 | yes | **MISMATCH**: `Name` suffix (RTTI name `CastleTypeName` @ `0x88537d`) | MATCH semantically |

**`localparams.cfg` (13 keys in one record):** `Name→EditLocalParamsItemName +0x3f4` (**name mismatch**), `HillPointsDensity→+0x330`, `MaxHillsHeight→+0x338`, `HillsHeightFactor→+0x334`, `GlobalMixFactor→+0x3e4`, `LocalMixFactor→+0x3dc`, `OffsetRadius→+0x3ec`, `SmoothLevel→+0x400`, `SmoothPasses→+0x424`, `SmoothFactor→+0x448`, `MinHeight→+0x404`, `MaxHeight→+0x410`, `CriticalPointsDist→+0x450`. **12/13 exact, 1 semantic** [O] (`ev_6fa43455…`).

**Extra controls D09 assigned to `TLocalParamsItemForm` [O]:** `EditMapFrequency +0x300`, `CheckBoxOnMap +0x30c`, `CheckBoxOnBorder +0x310`, `EditBorderFrequency +0x318` (`ev_65c36158…`). D09's [U] ("whether those keys exist in a fuller config on disk was not checked") is **resolved**: they do, in `mapcover.cfg:26-30` as `ItemName`, `MapFrequency`, `BorderFrequency`, `OnMap`, `OnBorder` (`ev_8345eacf…`). Note the id key is `ItemName` there vs `Name` in `localparams.cfg:4` — a real cross-file naming difference, not a typo to "fix".

### 4. Twelve stage flags and `ButtonApplyClick 0x7467dc`

Each block is `mov eax,[ebx+controlSlot] ; mov edx,[eax] ; call [edx+0xc8] (GetCheck) ; mov [esi+flag],al`. Source `ev_409fdb59…`; example write `ev_9e61d2f2…`.

| flag | checkbox (slot) | field-table name [O] | read @ | write @ |
|---:|---|---|---:|---:|
| +0x90 | +0x384 | `CheckBoxAddWater` | 0x746bf1 | 0x746bff |
| +0x91 | +0x3a8 | `CheckBoxIsGenerateTerrain` | 0x746c05 | 0x746c13 |
| +0x92 | +0x3b4 | `CheckBoxIsAddPatterns` | 0x746c19 | 0x746c27 |
| +0x93 | +0x3b8 | `CheckBoxIsAddTowns` | 0x746c2d | 0x746c3b |
| +0x94 | +0x3bc | `CheckBoxIsAddRoads` | 0x746c41 | 0x746c4f |
| +0x95 | +0x418 | `CheckBoxIsAddRivers` | 0x746c55 | 0x746c63 |
| +0x96 | +0x44c | `CheckBoxIsResetHeightField` | 0x746c7d | 0x746c8b |
| +0x97 | +0x47c | `CheckBoxIsAddForest` | 0x746c69 | 0x746c77 |
| +0x98 | +0x3d0 | `CheckBoxNoIntersect` | 0x746c91 | 0x746c9f |
| +0x99 | +0x3dc | `CheckBoxUpdateTerrain` | 0x746ca5 | 0x746cb3 |
| +0x9a | +0x494 | `CheckBoxLoadRivers` | 0x746cb9 | 0x746cc7 |
| +0x9b | +0x490 | `CheckBoxGetRiverPoints` | 0x746ccd | 0x746cdb |

**Verdict: D09's 12-flag map is exact [O].** Nuance: the object written is `esi = [[form+0x52c]+0x1b0]`, i.e. the same generator object the generate button passes to `0x87b7ec`; D09's shorthand "generator-object offsets" is acceptable, but the indirection is now explicit. `NoIntersect`, `LoadRivers`, `GetRiverPoints` (+0x98/+0x9a/+0x9b) are written here yet **never tested by `0x87b7ec`** in the recovered body [O] — they may be consumed elsewhere `[U]`.

Orchestrator order re-derived (`ev_cf724abc…`): init `0x878878` → log `0x87ba30` via `0xa2274c` → gate `0x93/0x97/0x92` → `0x8cdd64` → gate `0x91 && !0x96 && !0x97` → log `0x87ba54` → `0x879e3c,0x879ac0,0x87a0a4,0x87a4a8,0x879fac` → `0x90` → `0x87db60,0x8810cc,0x87e44c` → `0x96` → `0x87ab1c,0x87a778` → `0x95` → `0x880a4c` → unconditional `0x87aad4,0x879ac0` → `0x93` → `0x87cff8` → `0x94` → `0x882da0` → `0x93` → `0x87d36c` → `0x94` → `0x8827ac` → `0x92` → `0x87d7e4` → unconditional `0x87e524` → `0x97` → `0x87aba8` → `0x91` → `0x87b488,0x87a778` → (`0x91|0x90|0x96`) → `0x87a724` → unconditional `0x87b764,0x87dd78,0x87dea4,0x883380` → `0x99` → log `0x87ba74` → `0x875ee4,0x9886d8,0x86a280 (×2),0x8e9e74` → log `0x87ba90`. **Matches D09 §5.1** [O].

### 5. What the editor binary proves about order — and what stays `[U]`

**Proved [O]:** a real native editor generator orchestrator exists, is called from a named UI button, and gates a fixed sequence on 12 named checkbox-written bytes; its progress strings and call addresses are byte-verified in `editor.exe`. The cfg key surface is exposed as `TXGlobalParams` RTTI properties plus named controls, with an apply handler that writes them.

**Not proved — `[U]`:**
- That skirmish generation calls `0x87b7ec` or uses flags `+0x90..+0x9b`. `Generating terrain...`, `Pattern library loading ...`, `Updating horizon...` and `TFormMapGen` occur **only** in editor.exe; cossacks.exe has `TileCoverFileName` ×2 (editor ×7) — D09 §8 plus this pass's cross-binary `native_bytes_find` batch.
- cossacks.exe instead contains a *different* routine `sub_721850` with strings `Updating horizon texture...` (`0x721ba0`) and `Generation finished` (`0x721bc4`, xref from `0x721b5b`), logger `0x8ce498` (not editor's `0xa2274c`), and gates at `[eax+0x4c]`, `[ebx+0x2c]`, `[eax+0x104]` — decoded read-only via file-path capstone after the target was externally closed. **[D]** Different code, not merely different strings; **[U]** no full equivalence mapping was attempted.
- That the `;`-prefixed skirmish DScript lines actually execute in retail (`F09 U8`); the skirmish order (`dogenerate.inc` → `generatemap.inc`: seed/mask → height → S0/S1/S2 smoothing → water fields → texture/tile → smooth tiles → relief/mines/forest per `F09 §2.4`) remains **text-evidence-only [U]**.
- Stage subroutine semantics and numeric constants inside `0x879e3c`, `0x87a0a4`, … (D09 U1/U2), and any donor GPU A/B parity.

---

## Implications for spec §09 (all `PORT APPROXIMATION` unless marked [O])

1. §09 §2/§3 keep the literal cfg keys verbatim — independently re-read and hashed here. **No new constant may be added** from the editor mapping: the mapping proves *where a value is stored*, not *what it means*.
2. §09 §6 ("the editor-parameter mapping (D09) should map UI controls to these keys") is now **validated with instruction-level evidence**, with three caveats: (a) semantic-only mappings `AddCastles`/`IsAddCastles`, `CastleType`/`CastleTypeName`, local `Name`/`EditLocalParamsItemName`; (b) four `Castle*Player*` keys missing from D09 §7 should be added to the coverage table as RTTI-only; (c) `MapFrequency`/`BorderFrequency`/`OnMap`/`OnBorder` are literal `mapcover.cfg:26-30` keys and D09's `[U]` can be retired.
3. §09 §4's two contradictions are **strengthened, not resolved**: the editor really writes `TileSmoothPasses` to B+0x28 (`0x73ff47`) while the skirmish text uses 3 (`smoothtiles.inc:237`, F03 F3). Keep both; follow the script for skirmish.
4. §09 must **not** present the editor's 12-flag order as skirmish stage order. If the port exposes flags for behavioural fidelity, label them `PORT APPROXIMATION` and source the skirmish order from F09 §2.5, not from `0x87b7ec`.
5. `Size`, `CastlesFileName`, `PatternPlayer*` and the castle-player keys stay `[U]`; an RTTI property name is not a consumer. The conditional `CellsResolution` rescale path is editor UI bookkeeping and must not become a terrain constant.

---

## Risks

| Risk | Label | Mitigation / evidence |
|---|---|---|
| Trusting D09 pseudocode over bytes | [O]/[D] | Corrections C1 (`0x73ffe6` = CellsResolution, not FailStandCount) and C2 (`0x40f134` unused); prefer the cited instruction addresses |
| Treating data as code with `native_instruction_show` | [O] | A1; always use `native_bytes_show` for pointers |
| Missing handlers because the engine found no CFG | [O] | A2; raw bytes + capstone + instruction spot-check |
| Assuming editor stage order = skirmish order | [U] | §5; cossacks.exe `sub_721850` is a different routine |
| Shared Craft Anything target churn | [O] | A4; pin `document:` on every call, `path=` for text, final restore verified |
| Over-reading RTTI names as live semantics | [U] | `TXGlobalParams` names are a schema, not a consumer |
| Treating `native_strings_find` 0 as absence | [O] | A3; strings tool is data-sections-only |
| Any parity claim | — | None made; no donor GPU A/B frame exists |

---

## UNVERIFIED register (do not promote without new evidence)

1. **[U]** Exact semantics of editor stage subroutines (`0x879e3c`, `0x87a0a4`, `0x87a4a8`, `0x879fac`, `0x87db60`, `0x8810cc`, `0x87e44c`, `0x87ab1c`, `0x880a4c`, `0x87cff8`, `0x87d36c`, `0x882da0`, `0x8827ac`, `0x87d7e4`, `0x87aba8`, `0x87b488`, `0x87a724`, `0x87b764`, `0x87dd78`, `0x87dea4`, `0x883380`, `0x875ee4`, `0x9886d8`, `0x86a280`, `0x8e9e74`). Passes: VMT anchor → bytes → capstone → instruction spot-check; only call order/flags accepted.
2. **[U]** Whether `cossacks.exe`'s `sub_721850` is the retail skirmish generator, and how its gates map to the editor's 12 flags (partial pass only: strings, one xref, call list; no full dossier because the target was closed externally mid-task).
3. **[U]** Which code writes/uses flags +0x98/+0x9a/+0x9b (written by `ButtonApplyClick`, untested in `0x87b7ec`).
4. **[U]** Which consumer reads `Size`, `CastlesFileName`, `PatternPlayer*`, `CastlePlayer*`, `CastlePatternsPlayer*`; RTTI presence is not consumption.
5. **[U]** Why RTTI property names differ from cfg keys for `AddCastles`/`IsAddCastles` and `CastleType`/`CastleTypeName`; a cfg parser alias is plausible `[I]` but unproven.
6. **[U]** Whether the exact `TXGlobalParams` field offsets are `B+n` or `B+n+4`; D09's −4 displacement remains unexplained (this pass reproduces the byte writes but not the object-header reason).
7. **[U]** Whether the `CellsResolution` rescale (`form+0x484/+0x488`, StringGrid helpers `0x608ba0`/`0x608f30`) has any effect on generated terrain.
8. **[U]** Retail execution of any `;`-prefixed skirmish DScript line (F09 U8) and therefore skirmish stage order as executable truth.
9. **[U]** Any donor visual parity — no donor GPU A/B frame; nothing here is a parity claim.

---

## Open questions

1. **D01/D02:** can the VMT/method-table scanner be run against `cossacks.exe` to anchor `sub_721850`'s equivalent of `0x87b7ec` and prove or refute a shared generator core?
2. **COORD:** accept corrections C1/C2 and the four missing `Castle*Player*` keys into §09's mapping table? Accept retirement of D09's `MapFrequency` `[U]` via `mapcover.cfg:26-30`?
3. **D03/D06:** do the editor's `0x87a0a4`/`0x879fac` stages correspond to mask decode / relief stamp constants in `generatemap.inc`? This is the bridge from editor stage *order* to skirmish stage *semantics*.
4. **F09/X03:** if `;`-prefixed lines are passive, what native path in `cossacks.exe` actually performs the skirmish smoothing/water/tile stages?
5. **Owner:** should the port expose the 12 donor flags as user toggles? Recommendation: expose, labelled `PORT APPROXIMATION`, with skirmish order from F09, not from the editor orchestrator.

---

## Five-line hand-off summary

1. `[O]` Anchor chain re-derived from bytes: VMT `0x73ebb8` → method table `0x73f6c0` → `ButtonApplyGlobalParamsClick 0x73fe50`; `0x7467b4` calls orchestrator `0x87b7ec`.
2. `[O]` 11 handler→cfg-key assignments verified by instruction (≥3 required); D09's resize trigger label and one converter address corrected.
3. `[O]` 24/24 form controls and 13/13 local controls match D09's slots; 4 omitted `Castle*Player*` keys and 3 semantic-only name mismatches recorded; `MapFrequency` `[U]` resolved by `mapcover.cfg`.
4. `[O]` All 12 checkbox→flag writes verified at `0x746bff..0x746cdb`; orchestrator gate/call order matches D09.
5. `[U]` Editor proves editor order only; cossacks.exe has a different generator routine — no parity claim; active target restored to `t_87f0f3c130b0`.

*End of X24. One report written. No donor executable run; no donor file copied into the repo; no source, shader, config, asset, test, git or Godot-runner state changed.*
