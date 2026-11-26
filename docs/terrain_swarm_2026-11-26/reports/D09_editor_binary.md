---
id: D09
ticket: "TERRAIN-SWARM-2026-11-26 / D09"
task: "Read-only donor analysis of C:\\Games\\Cossacks 3\\editor.exe — form/control surface, terrain-generation handlers, file formats, cfg mapping"
date: 2026-11-26
status: DELIVERED__READ_ONLY__NO_DONOR_EXECUTION__NO_REPO_EDITS
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION"]
target: "C:\\Games\\Cossacks 3\\editor.exe — 7,874,416 B, PE32 x86, SHA-256 68474ddde43fe4aa084613f01946734a7eea6d511fb98dd81326e8be2ed250ab"
craft_anything_target_id: t_68474ddde43f
active_target_note: "Started on t_87f0f3c130b0 (cossacks.exe); drifted to t_68474ddde43f during the cursor/instruction pass; explicitly restored to t_87f0f3c130b0 at end of task and re-verified."
donor_parity_claim: false
scope: "Exactly one report written. No donor binary executed, copied or committed; no source/shader/config/asset/test/git edit; no Godot runner job."
---

# D09 — editor.exe: the terrain authoring UI as an anchor for generator truth

## Executive summary

1. **[O] `editor.exe` is much more informative than `cossacks.exe` for the *parameter surface and stage order* of terrain generation**, but not because of plain string xrefs. Its `.rsrc` contains **uncompressed binary Delphi DFM resources** (e.g. `TFormMapGenerator` at VA `0xafa5a1`, file offset `0x6ea7a1`) and its `CODE` section contains **Delphi VMTs with published field and method tables**. Those tables give a direct, byte-verified map `control name → form slot`, `event handler name → code address`, which plain string references cannot (all 104 terrain strings from COORD's triage have `references: []`).
2. **[D] A VMT scanner recovered 145 form VMTs.** The terrain-central ones are `TFormMapGen` (`VMT 0x73ebb8`, `off 0x33dfb8`), `TGlobalMapForm` (`0x7449dc`), `TLocalParamsItemForm` (`0x73dfd8`), `TFormTerrainBorders` (`0x7386b4`), `TFormProperties` (`0x6719e8`), `TNewMapDlg` (`0x6fe500`) and `TFormCollisionMask` (`0x66a3bc`). Method-table entries yield concrete handler entries such as `TFormMapGen.ButtonGenerateClick = 0x7400d0`, `ButtonApplyGlobalParamsClick = 0x73fe50`, `TGlobalMapForm.ButtonApplyClick = 0x7467dc`, `ButtonGenerateClick = 0x746754`.
3. **[O] The generation orchestrator was found at `VA 0x87b7ec` (`off 0x47abec`)** via `TGlobalMapForm.ButtonGenerateClick` → `call 0x87b7ec`. It emits four progress strings (`Pattern library loading ...`, `Generating terrain...`, `Updating horizon...`, `Generation finished`) and gates 12 stages on booleans at generator-object offsets `+0x90..+0x9b`. `TGlobalMapForm.ButtonApplyClick` (`0x7467dc`) shows exactly which checkbox writes each flag — **this is the donor's authoritative UI-stage map**.
4. **[O] The `globalparams.cfg` / `localparams.cfg` keys are exposed as literal control names in `TFormMapGen`'s field table and as RTTI property names in `TXGlobalParams` (`0x884fd7`)**. Nearly every config key has a same-named `Edit*` control; the apply handler shows the object-field writes and conversion calls (`StrToFloat`/`StrToInt` equivalents at `0x40f0f8`, `0x40cc14`, `0x40f134`).
5. **[O] Terrain map export uses literal ASCII markers `TerrainMapBegin` (`0x8a5bfc`) / `TerrainMapEnd` (`0x8a5c14`) around a stream of raw 4/1-byte writes** (`0x8a5af0`); map settings load uses a keyed text format with 50+ field-name keys (`0x876870..`) read through `0xa18a40`. `TGlobalMapForm.Save/Load` delegate to `0x877114` / `0x875f04` → `0x875f64`.
6. **[O] Cross-check:** `native_bytes_find` for `Generating terrain...` and `TFormMapGen` finds them **only in editor.exe**, while `TileCoverFileName` exists in both binaries. So the generator core is shared, the authoring parameter/stage surface is editor-only.
7. **[U] No donor-parity claim.** No donor GPU A/B frame exists; the stage-to-algorithm semantics of the individual subroutines (`0x879e3c`, `0x87a0a4`, …) were not recovered to source level, and the byte payload after `TerrainMapBegin` remains unverified.

---

## 1. Evidence table

| id / citation | What it establishes | Class |
|---|---|---|
| `ev_0ce462bd2393c7305b3b6a60247b6d562e0d3dbfcd9937869d932a4ba32b64e4` (COORD triage) | 104 `terrain` strings in `.rsrc` | [O] |
| `ev_c48723aea4991ea0a5f0b4096aa4a76ecd244e41680a530132ff7aa356d47521` | Re-run of `native_strings_find "terrain"` on `t_68474ddde43f`: **104 matches, all `.rsrc`, all `references: []`** | [O] |
| `ev_447f029ed1d516fbf1cec297ee7687352488798fed7afa1a974514e7f030a815` | `editor.exe` overview: 22,384 functions / 62,898 strings / 770 imports; 6,000,000-instruction limit, 682 unresolved indirect jumps | [O] |
| `ev_bec08277a9328c60f3b505f6fc6bb052911335be39c01ccd1e23c92f2923aa4d` | 16 `Generator` strings including `TFORMMAPGENERATOR` @ `0xa94526` and `TFormMapGenerator` @ `0xafa5a1` | [O] |
| `ev_6795a6d213757aa48408b0f0a2561a530a4ac76171efda29c65431d9c9fb3ab9` | `LabelTerrainLocalPresetName`, `EditTerrainLocalPresetNameChange`, `ButtonSetTerrainLocalPresetClick`, … | [O] |
| `ev_af01bda26fe50d776b1f3419dec11fec3dc13e7495bd3c46b0d3309e65bbd7cf` | 134 `Mask` strings; collision-mask layer options `cloTerrain`, `cloWater`, `cloSky` and their `*Click` handlers | [O] |
| `ev_cf5741dae2f241771732880da03346e86685182c8ac5775d6856ff762d80eae6` | `Generating terrain...` @ `0x87ba54` (`off 0x47ae54`, `CODE`) | [O] |
| `ev_1b045d391c21140c80c4e12ee6b742a5f4ca8577047da6f766a9120a05be0a58` | `TileCoverFileName` ×7 in editor CODE | [O] |
| `ev_5c74116efb0adf8980940182ae2e0835c72514d4cae7cc6c3bc0f3ebdcefb498` | `TileCoverFileName` ×2 in cossacks.exe CODE (`0x718d18`, `0x71b038`) | [O] |
| `ev_6b832a6a244f3186622f13de1414359e89e840debe39eb0b0b560f0eccf2892b` | Deep study of `sub_73fd40` = `ButtonLoadGlobalParamsClick`: `OpenDialog.Execute`, `0x441214` filename, `0x885c54` global-params load, `0x886c18`, `0x741208` | [O/D] |
| `ev_0e2fb69823c4f143f0fd158502595fec9919adabae089ce57ded9cb3755643fb` | `sub_885c54` (global-params file reader): 48 instructions, 6 callees, 2 callers | [O] |
| `ev_0f4e51a03ce6f8a1295b37ee2d58cb87304c46fa3dd81883257a4ced985b80b6` | `sub_886c18`: 196 instructions, 26 callees, 3 callers | [O] |
| `ev_eb2765856b3cf4e06a390cc3abaa05c623ea675d9910961b48a9115d80544990` (+ 5 siblings) | `native_function_find` says **not inside any discovered function** for all six hand-anchored handler entries | [O] |
| `ev_bf08f1542bd49ac9af47beaa9b8cabb3d9202bd118d2063b832031deab10dc74` | Instruction-level read at `0x7400d0` succeeds (`push ebp`) although no function exists in the engine's list | [O] |
| `ev_40677a65f79d48361f14cf1926c68cf8937d473fa0cd9b46ef295b0ecc67cf59` | `native_xrefs_list` at `0x7400d0`: 0 references | [O] |
| `fnd_27`, `fnd_28` | Findings appended to the shared investigation memory (DFM/VMT anchor; orchestrator/stage flags) | [D] |
| `C:\Games\Cossacks 3\editor.exe:0x33dfb8` (`VA 0x73ebb8`) | `TFormMapGen` VMT; method table `0x73f6c0` (`off 0x33eac0`), field table `0x73ecac` (`off 0x33e0ac`) | [O/D] |
| `…editor.exe:0x47abec` (`VA 0x87b7ec`) | Generator stage orchestrator (full assembly recovered) | [O] |
| `…editor.exe:0x345bdc` (`VA 0x7467dc`) | `TGlobalMapForm.ButtonApplyClick` → checkbox→flag map | [O] |
| `…editor.exe:0x475c70` (`VA 0x876870`) → `0x476ef0` | Keyed settings loader field-name table | [O] |
| `…editor.exe:0x4a4ef0`, `0x4a4ffc`, `0x4a5014` | `TerrainMapBegin` / `TerrainMapEnd` writers | [O] |
| `C:\Games\Cossacks 3\data\gen\globalparams.cfg:2-20`, `localparams.cfg:2-18` | Config keys compared against editor control names | [O] |

---

## 2. Method and the anomaly multi-pass log

### 2.1 Method (passes that produced accepted results)

1. **Target isolation.** `core_session_show` found `editor.exe` already open as `t_68474ddde43f`; the session started with `cossacks.exe` (`t_87f0f3c130b0`) active. Every native analysis call used `document: "t_68474ddde43f"`. **[O] Anomaly:** a later session check showed the *global active target had drifted to editor.exe* (most likely during the cursor/instruction pass, whose result did not echo the document parameter). It was explicitly restored with `core_target_select({target_id:"t_87f0f3c130b0"})` and re-verified active at task end. No other worker's target choice was left altered.
2. **Plain strings pass.** `native_strings_find` (data sections only) reproduced COORD's 104 terrain strings; all report `references: []`. Accepted as [O] *surface inventory only*, rejected as an anchor.
3. **PE/resource byte pass (Python, read-only).** Parsed PE headers (`entry RVA 0x6259b8`, image base `0x400000`, sections `CODE 0x401000/0x624d34`, `DATA`, `.rsrc RVA 0x691000/0xdd800`, `.bind 0x76f000/0x23d70`). Confirmed `.rsrc` holds **plain ANSI binary DFM** (`TFormMapGenerator` resource body at `0xafa5a1`) and UTF-16 RCDATA resource names (`TFORMMAPGENERATOR` at `0xa94526`).
4. **VMT scanner pass.** For every 4-byte-aligned dword in `CODE`/`DATA` pointing at a printable shortstring beginning `T`/`F`/`X`, tested modern-Delphi VMT offsets:
   `vmtTypeInfo=-0x3c`, `vmtFieldTable=-0x38`, `vmtMethodTable=-0x34`, `vmtDynamicTable=-0x30`, `vmtClassName=-0x2c`, `vmtInstanceSize=-0x28`, `vmtParent=-0x24`. Calibrated on `TFormTerrainBorders` (`vmt 0x7386b4`, class name @ `0x738b4b`, instance size `0x368`, method table `0x738981`, field table `0x7387a8`); then 145 VMTs found. Method-table entry format: `word index; dword code pointer; byte len; short name`. Field-table format: `word count; dword type-info pointer; {dword slot; word tag; byte len; short name}`. Accepted: [O] bytes + [D] structural decode, cross-checked on multiple forms and against DFM control names.
5. **Handler decompilation pass.** Since the engine's function discovery omitted these handlers, used a read-only Python + `capstone` disassembler over the exact byte range from method-table code pointers until `ret`; validated prologues (`push ebp; mov ebp,esp; … push fs:[0]`) and cross-checked individual instructions with `native_instruction_show`. Accepted as [O] assembly / [D] pseudocode.
6. **Callee study pass.** Where a callee *was* discovered (`0x73fd40`, `0x885c54`, `0x886c18`), used `native_function_study` for assembly/CFG/callers. Accepted [O] for assembly, [D] for pseudo-C.
7. **Cross-binary pass.** `native_bytes_find` on both targets for orchestration strings and shared keys. Accepted [O].

### 2.2 Anomaly: handler addresses are absent from Craft Anything's function list

| Pass | Tool / input | Result | Verdict |
|---|---|---|---|
| 1 | `native_strings_find "terrain"` | 104 hits, `references: []` | Expected — names are DFM/RTTI data, no code xrefs |
| 2 | `native_functions_list` (all 22,384 entries) + `native_function_find` on `0x7400d0`, `0x73fe50`, `0x7408e0`, `0x746754`, `0x6ff524`, `0x739c00` | All six: **"not inside any discovered function"** | Anomaly — engine found `0x73fd40` etc. but skipped most VMT-only entries |
| 3 | `native_cursor_goto(0x7400d0)` + `native_instruction_show` + `native_xrefs_list` + `native_address_show` | Instruction `push ebp` at the address is real; `function: null`, `xrefs_to: 0` | Confirms bytes exist; engine simply has no CFG there |
| 4 | `native_function_pseudocode` / `native_function_study` on `0x7400d0` | `bad_input: function_not_found` | Rejected for this address |
| 5 | `native_objdump_run` on editor.exe `disassemble 0x7400d0..0x7401e0` | `engine_missing` (no objdump installed) | Rejected (environment) |
| 6 | Python `capstone` raw-byte disassembly from `va2off()` | Full 64-instruction handler ending in `ret`, with Delphi SEH prologue; call targets resolved | **Accepted** — independently corroborated by pass 3 at the same address |
| 7 | Cross-check against VMT method-table pointer and DFM event name | `ButtonGenerateClick` @ `0x7400d0` appears in both | **Accepted** |

**Why accepted:** the address came from a *data structure* (VMT method table), not from a guess; the bytes at that address are a valid Delphi method prologue; instruction-level tool output agrees with raw-byte disassembly. No anomaly was silently skipped. Remaining uncertainty about high-level semantics is registered as [U] in §9.

---

## 3. Form classes, controls and properties

### 3.1 `TFormMapGen` — the "Terrain Generator" dialog (VMT `0x73ebb8`, `off 0x33dfb8`; DFM resource `TFormMapGenerator` @ `VA 0xafa5a1` / `off 0x6ea7a1`)

All entries below are read from the VMT field table at `0x73ecac` (`off 0x33e0ac`); `slot` is the form-object offset used by the handlers.

| slot | control | slot | control |
|---:|---|---:|---|
| +0x300 | `ButtonGenerate` | +0x304 | `GroupBoxGlobalTerrainParams` |
| +0x308 | `LabelSharpness` | +0x30c | `LabelRandomKey` |
| +0x310 | `EditSharpness` | +0x314 | `EditRandomKey` |
| +0x318 | `GroupBoxLocalTerrainParams` | +0x31c | `ListBoxParamsCollection` |
| +0x320 | `ButtonApplyLocalParams` | +0x324 | `ButtonAddLocalParamsItem` |
| +0x328 | `ButtonDeleteLocalParamsItem` | +0x32c | `ButtonSaveLocalParams` |
| +0x330 | `EditHillPointsDensity` | +0x334 | `EditHillsHeightFactor` |
| +0x338 | `EditMaxHillsHeight` | +0x33c | `LabelHillPointsDensity` |
| +0x348 | `ButtonLoadGlobalParams` | +0x34c | `ButtonSaveGlobalParams` |
| +0x350 | `ButtonApplyGlobalParams` | +0x354 | `EditCellsResolution` |
| +0x360 | `ButtonLoadTileCoversParameters` | +0x364 | `ButtonSaveTileCoversParameters` |
| +0x368 | `ButtonLoadLocalParams` | +0x370 | `StringGridParams` |
| +0x37c | `EditTileChangeFactor` | +0x3cc | `LabelFrequencyFactor` |
| +0x3d0 | `EditFrequencyFactor` | +0x3dc | `EditLocalMixFactor` |
| +0x3e4 | `EditGlobalMixFactor` | +0x3ec | `EditOffsetRadius` |
| +0x3f4 | `EditLocalParamsItemName` | +0x400 | `EditSmoothLevel` |
| +0x404 | `EditMinHeight` | +0x410 | `EditMaxHeight` |
| +0x414 | `ButtonGenerateCellsInfo` | +0x418 | `EditFailStandCount` |
| +0x424 | `EditSmoothPasses` | +0x428 | `EditTerrainLocalPresetName` |
| +0x430 | `EditCurrentTerrainLocalPreset` | +0x438 | `ButtonSetTerrainLocalPreset` |
| +0x43c | `EditDefaultMapSize` | +0x444 | `LabelPatternCount` |
| +0x448 | `EditSmoothFactor` | +0x450 | `EditCriticalPointsDist` |
| +0x458 | `EditTileSmoothPasses` | +0x464 | `EditTileSmoothListFileName` |
| +0x46c | `CheckBoxIsAddCastles` | +0x470 | `EditCastlePlateauFactor` |
| +0x478 | `EditCastleTypeName` | | |

**[O]** Captions observed in DFM: `Terrain Generator` (`0xaf791a`), `Global Terrain Params` (`0xaf7b48`), `Local Terrain Params Collection` (`0xaf85f6`), `Current Terrain Preset` (`0xaf946b`), `Set Terrain Preset` (`0xaf9d58`).

### 3.2 `TGlobalMapForm` — global-map generation dialog (VMT `0x7449dc`, `off 0x744ad0`-adjacent)

The field table contains **all** generator toggles and numeric parameters relevant to terrain/water/rivers/forests. Key entries:

| slot | control (selected) | slot | control (selected) |
|---:|---|---:|---|
| +0x318 / +0x320 | `EditMinHeight` / `EditMaxHeight` | +0x358 / +0x360 | `EditSharpFactor` / `EditSmoothPasses` |
| +0x368 / +0x370 | `EditTileSmoothPasses` / `EditTileSmoothListFileName` | +0x37c | `EditMaxDepth` |
| +0x384 | `CheckBoxAddWater` | +0x388 | `EditTownFailCount` |
| +0x3a8 | `CheckBoxIsGenerateTerrain` | +0x3ac | `EditTownRoadName` |
| +0x3b4 | `CheckBoxIsAddPatterns` | +0x3b8 | `CheckBoxIsAddTowns` |
| +0x3bc | `CheckBoxIsAddRoads` | +0x3c0 | `EditVillageRoadName` |
| +0x3c8 | `EditRandomKey` | +0x3d0 | `CheckBoxNoIntersect` |
| +0x3d4 | `EditRoadFactor` | +0x3dc | `CheckBoxUpdateTerrain` |
| +0x3ec / +0x3f4 / +0x3fc / +0x404 / +0x40c | `EditWaterBlocks` / `EditWaterOffset` / `EditWaterSmoothPasses` / `EditWaterSmoothFactor` / `EditWaterSmoothRadius` | +0x418 | `CheckBoxIsAddRivers` |
| +0x41c | `EditRiverPointsDistance` | +0x424 | `EditWaterCollisionTag` |
| +0x42c / +0x438 / +0x43c / +0x444 | `EditRiverPlateauFactor` / `EditRiverDepthFactor` / `EditRiverSmRadiusFactor` / `EditRiverSmPassesFactor` | +0x44c | `CheckBoxIsResetHeightField` |
| +0x450 | `EditRiverMinPlateauRadius` | +0x45c / +0x468 | `EditGlobalCoverFileName` / `EditRiverMapFileName` |
| +0x474 / +0x47c | `EditForestPatternsFileName` / `CheckBoxIsAddForest` | +0x484 | `EditTileChallengeFactor` |
| +0x490 / +0x494 | `CheckBoxGetRiverPoints` / `CheckBoxLoadRivers` | +0x498 | `EditForestMapFileName` |
| +0x4b4 | `EditForestTileChallengeFileName` | +0x4c8 | `ButtonLoadPatterns` |
| +0x4cc..+0x4e0 | `EditTownSmooth*` / `EditTownSmoothRadiusFactor` | +0x4e8 | `EditStraightRoadDistance` |
| +0x4f4 / +0x4fc / +0x504 / +0x50c / +0x514 / +0x51c | bridge/road parameters | +0x524 | `ButtonLoadData` |

### 3.3 Other terrain-bearing forms (VMT field/method table scans)

| Form | VMT | Terrain controls | Handlers (address) |
|---|---:|---|---|
| `TLocalParamsItemForm` | `0x73dfd8` | `ComboBoxLocalParamsItem`, `EditMapFrequency`, `EditBorderFrequency`, `CheckBoxOnMap`, `CheckBoxOnBorder` | `ButtonApplyClick 0x73e460`, `EditMapFrequencyChange 0x73e590`, `EditBorderFrequencyChange 0x73e5ac` |
| `TFormTerrainBorders` | `0x7386b4` | `EditWidth/Step/Min/Max/PX/PY`, 8 direction buttons, `CheckBoxDL/Enabled/Visible/Export/Tiles` | `ButtonApplyClick 0x738d34`, `ButtonSmoothClick 0x7398b8`, `ButtonNormalizeHeightDataClick 0x739c00`, `ButtonScaleHMToMinMaxClick 0x739d84` |
| `TFormProperties` | `0x6719e8` | `CheckBoxSelectionTerrainCollide` (+0x63c), `CheckBoxCmdNeedTargetTerrain` (+0x6c8), `CheckBoxAutoPlateauTerrain` (+0x814), `EditAutoPlateauTerrainRadius` (+0x840), `CheckBoxAutoNormalizeTerrain` (+0xa5c) | `0x682268`, `0x682c60`, `0x684ad4`, `0x684db8`, `0x687538` |
| `TFormResource` | `0x6faedc` | `EditTerrainSetlibraryFileName` (+0x34c), `ButtonTerrainSetlibraryFileName` (+0x3ac) | `EditTerrainSetlibraryFileNameChange 0x6fcb2c`, `ButtonTerrainSetlibraryFileNameClick 0x6fcbe8` |
| `TPatternForm` | `0x7004b8` | `EditTerrainScale` (+0x380) | `EditTerrainScaleChange 0x701968` |
| `TPaletteForm` | `0x706638` | `TrackBarTerrainRaisingFactor` (+0x3b4) | `TrackBarTerrainRaisingFactorChange 0x709920` |
| `TNewMapDlg` | `0x6fe500` | `CheckBoxRandomHeightField`, `ComboBoxMapWidth/Height`, `ComboBoxInitialTerrainSet`, `ComboBoxInitialTerrainBlock`, `CheckBoxChooseTerrainBlock` | `ButtonExportClick 0x6ff524`, `ButtonImportClick 0x6ff5f4` |
| `TFormCollisionMask` | `0x66a3bc` | `StringGridCollisionMask`, width/height edits; layer options `cloTerrain` / `cloWater` / `cloSky` (strings `0xb16b6c..0xb16db3`) | `UpDownCollisionMaskWidthClick 0x66a81c`, `StringGridCollisionMaskSelectCell 0x66a884` |

**[D] Important correction to a possible misreading:** `CheckBoxIsGenerateTerrain` and `CheckBoxUpdateTerrain` are *fields of `TGlobalMapForm`, not event-handler methods* — they do not appear in its method table; they are only read by `ButtonApplyClick` (`0x7467dc`). Likewise the auto-plateau/normalize controls belong to object-property editing (`TFormProperties`), not to the map generator.

---

## 4. Anchored event handlers and their code

| Handler | Address | File offset | Role (from recovered assembly) |
|---|---:|---:|---|
| `TFormMapGen.ButtonGenerateClick` | `0x7400d0` | `0x33f4d0` | Builds a `PatternCount: A + B` status string (`0x7401b8`, `0x7401d0`, `0x7401dc`) into a label; **does not itself call the generator** |
| `TFormMapGen.ButtonApplyGlobalParamsClick` | `0x73fe50` | `0x33f250` | Copies 20+ UI values into generator/global-param objects; rescales two fields when `Size` changes |
| `TFormMapGen.ButtonLoadGlobalParamsClick` | `0x73fd40` | `0x33f140` | `OpenDialog` → filename → `0x885c54` → `0x886c18` → `0x741208` (engine study `ev_6b832a…`) |
| `TFormMapGen.ButtonSaveGlobalParamsClick` | `0x73fdd4` | `0x33f1d4` | Mirror of load (not in engine function list; capstone pass) |
| `TFormMapGen.ButtonApplyLocalParamsClick` | `0x7408e0` | `0x33fce0` | Applies local-terrain params into the selected collection item |
| `TFormMapGen.EditTerrainLocalPresetNameChange` | `0x74470c` | `0x34370c` | Preset name edit |
| `TFormMapGen.ButtonSetTerrainLocalPresetClick` | `0x744820` | `0x343c20` | Applies current terrain preset |
| `TGlobalMapForm.ButtonGenerateClick` | `0x746754` | `0x345b54` | Shows `PatternCount` and calls **`0x87b7ec`** (the orchestrator) |
| `TGlobalMapForm.ButtonApplyClick` | `0x7467dc` | `0x345bdc` | Writes all generator numeric params + the 12 boolean flags |
| `TGlobalMapForm.ButtonSaveClick` / `ButtonLoadClick` | `0x746660` / `0x74667c` | `0x345a60` / `0x345a7c` | `0x877114` / `0x875f04` (map settings I/O) |
| `TNewMapDlg.ButtonExportClick` / `ButtonImportClick` | `0x6ff524` / `0x6ff5f4` | `0x2fe924` / `0x2fef94` | File export/import of a new map object |
| `TFormTerrainBorders.ButtonNormalizeHeightDataClick` | `0x739c00` | `0x338c00` | Calls `0x8fb06c` on the height data object |
| `TFormProperties.CheckBoxAutoPlateauTerrainClick` | `0x684ad4` | `0x283ed4` | Writes selected object+`0x50` byte `+0x1b` |
| `TFormProperties.EditAutoPlateauTerrainRadiusChange` | `0x684db8` | `0x2841b8` | Parses float, writes object+`0x50` float `+0x1c` |
| `TFormProperties.CheckBoxAutoNormalizeTerrainClick` | `0x687538` | `0x286938` | Writes object+`0x50` byte `+0x20` |
| `TFormResource.ButtonTerrainSetlibraryFileNameClick` | `0x6fcbe8` | `0x2fcbe8` | Opens terrain-set library file, calls `0x8bca34`, displays `+0x54` |

All addresses are **[O] from VMT method tables**; roles are **[D] from assembly**.

---

## 5. Generation call sequence and constants

### 5.1 The orchestrator at `0x87b7ec` (file offset `0x47abec`)

Prologue → `call 0x878878` (init) → `0xa2274c` writes progress string at `0x87ba30`:
`Pattern library loading ...` (len 27, `0x87ba30`), then flags/stages in this **observed order**:

| Generator object flag | UI control that sets it (from `ButtonApplyClick`) | Calls made when true |
|---|---|---|
| `+0x92` `IsAddPatterns` (or `+0x93` towns / `+0x97` forest) | `CheckBoxIsAddPatterns` / `IsAddTowns` / `IsAddForest` | `0x8cdd64` with `cl=1, dl=1`, args from nested object `+0x50.+0x168` — pattern library load |
| `+0x91` `IsGenerateTerrain` (and not `+0x96`, `+0x97`) | `CheckBoxIsGenerateTerrain` | `0x879e3c`, `0x879ac0`, `0x87a0a4(ecx=1, edx=&obj+0x114)`, `0x87a4a8`, `0x879fac` — after `Generating terrain...` string at `0x87ba54` |
| `+0x90` `AddWater` | `CheckBoxAddWater` | `0x87db60`, `0x8810cc`, `0x87e44c` |
| `+0x96` `IsResetHeightField` | `CheckBoxIsResetHeightField` | `0x87ab1c`, `0x87a778` |
| `+0x95` `IsAddRivers` | `CheckBoxIsAddRivers` | `0x880a4c` |
| unconditional | — | `0x87aad4`, `0x879ac0` |
| `+0x93` `IsAddTowns` | `CheckBoxIsAddTowns` | `0x87cff8`, `0x87d36c` |
| `+0x94` `IsAddRoads` | `CheckBoxIsAddRoads` | `0x882da0`, `0x8827ac` |
| `+0x92` `IsAddPatterns` | `CheckBoxIsAddPatterns` | `0x87d7e4` |
| unconditional | — | `0x87e524` |
| `+0x97` `IsAddForest` | `CheckBoxIsAddForest` | `0x87aba8` |
| `+0x91` `IsGenerateTerrain` | `CheckBoxIsGenerateTerrain` | `0x87b488`, `0x87a778` |
| conditional on `+0x91 or +0x90 or +0x96` | — | `0x87a724` |
| unconditional | — | `0x87b764`, `0x87dd78`, `0x87dea4`, `0x883380` |
| `+0x99` `UpdateTerrain` | `CheckBoxUpdateTerrain` | `0x875ee4`, `0x9886d8`, `0x86a280`, `0x8e9e74` — after `Updating horizon...` string at `0x87ba74` |
| unconditional | — | `Generation finished` (`0x87ba90`) |

**[O] flag map from `TGlobalMapForm.ButtonApplyClick` (`0x7467dc`):**
`+0x90 ← CheckBoxAddWater`, `+0x91 ← IsGenerateTerrain`, `+0x92 ← IsAddPatterns`, `+0x93 ← IsAddTowns`, `+0x94 ← IsAddRoads`, `+0x95 ← IsAddRivers`, `+0x96 ← IsResetHeightField`, `+0x97 ← IsAddForest`, `+0x98 ← NoIntersect`, `+0x99 ← UpdateTerrain`, `+0x9a ← LoadRivers`, `+0x9b ← GetRiverPoints`.

**[D] Pseudocode (behavioural, not source):**
```
Generate(self):
  log("Pattern library loading ...")
  Init(self)                                  # 0x878878
  if patterns|towns|forest: LoadPatternLibrary(...)   # 0x8cdd64
  if terrain and not resetHill and not forest:
      log("Generating terrain...")
      GenerateTerrainStageA(self)             # 0x879e3c
      Common(self)                            # 0x879ac0
      Stamp(self, 1, @self+0x114)             # 0x87a0a4
      GenerateTerrainStageB(self)             # 0x87a4a8
      FinalizeTerrain(self)                   # 0x879fac
  if addWater: WaterStage(...)                # 0x87db60/0x8810cc/0x87e44c
  if resetHeight: ResetHeightField(...)       # 0x87ab1c/0x87a778
  if rivers: RiversStage(...)                 # 0x880a4c
  Common(self); ... towns/roads/patterns/forest ...
  if updateTerrain:
      log("Updating horizon...")
      UpdateHorizon(self)                     # 0x875ee4/0x9886d8/0x86a280/0x8e9e74
  log("Generation finished")
```
**[U]** The semantic names of the numbered subroutines are inferred from call order and progress strings; no source-level identifiers exist in this stripped binary. Do not present them as donor method names.

### 5.2 Constants recovered

| Constant | Address | Meaning | Label |
|---|---|---|---|
| `0x7401b8` = `"PatternCount: "`, `0x7401d0` = `" = "`, `0x7401dc` = `" + "` | CODE | status-line construction in both generate buttons | [O] |
| `0x87ba30`/`0x87ba54`/`0x87ba74`/`0x87ba90` | CODE | four progress strings (len 27/21/19/19) | [O] |
| `0x7f7fc99e` = `+3.4e38`, `0xff7fc99e` = `−3.4e38` | `0x739c28`, `0x739c31` | sentinel min/max initialisation in the terrain-border normalize helper | [O] |
| `ecx = 1` passed to `0x87a0a4`, `edx = &generator+0x114` | `0x87b877..0x87b884` | a count/pass argument and an output buffer for a terrain stage | [O] |
| `cl=1, dl=1` | `0x87b841` | boolean args to `0x8cdd64` pattern-library load | [O] |
| `dx=0xffff, ecx=0` | `0x6ff587`, `0x6ff585` | file-open mode for `0x4d46a0` in `ButtonExportClick` | [O] |
| `dx=0x20, ecx=0` | `0x875f27`, `0x875f29` | file-open mode for map settings load (`0x4d46a0`) | [O] |

No numeric height/threshold constants were recovered from the generation stages themselves in this pass — **[U]**, see §9.

### 5.3 Global-params apply handler `0x73fe50` (`off 0x33f250`)

Observed conversion chain (each UI value → `TControl.GetText` `0x49cb0c` → converter → object field):

```
randomKey(int64, EditRandomKey @+0x314)  -> generator +0x18 / +0x1c
global.Sharpness (float, EditSharpness @+0x310)      -> B +0x10   [A+0x14]
global.TileChangeFactor (float, EditTileChangeFactor @+0x37c) -> B +0x14 [A+0x18]
global.FrequencyFactor (float, EditFrequencyFactor @+0x3d0)   -> B +0x18 [A+0x1c]
global.FailStandCount (int, EditFailStandCount @+0x418)       -> B +0x20
global.DefaultMapSize (int, EditDefaultMapSize @+0x43c)       -> B +0x24
global.TileSmoothPasses (int, EditTileSmoothPasses @+0x458)   -> B +0x28
global.TileSmoothListFileName (string, @+0x464)               -> B +0x2c
global.CastlePlateauFactor (float, @+0x470)                   -> B +0x50
global.AddCastles (bool, @+0x46c)                             -> B +0x4c
global.CastleType (string, @+0x478)                           -> B +0x54
if newFailStandCount != oldSize:
  [form+0x484] = [form+0x484] / oldSize * newCount
  [form+0x488] = [form+0x488] / oldSize * newCount
  resize helpers 0x608ba0, 0x608f30 on StringGrid @+0x370
  generator refresh 0x886c18 / 0x886eb8
then 0x7421cc and 0x741464
```
`[D]` `B = [generator+4]`; offsets into `B` are 4 less than the RTTI property offsets of `TXGlobalParams` (whose RTTI table at `0x884fd7` lists, in order, `Parent 0x08`, `Size 0x0c`, `StartRange 0x10`, `Sharpness 0x14`, `TileChangeFactor 0x18`, `FrequencyFactor 0x1c`, `CellsResolution 0x20`, `FailStandCount 0x24`, `DefaultMapSize 0x28`, `TileSmoothPasses 0x2c`, `TileSmoothListFileName 0x30`, `CastlesFileName 0x34`, `PatternPlayerName 0x38`, …). **[U]** the exact reason for the constant −4 displacement (object header vs field-area pointer) is not proven; the *ordering and names* are exact.

---

## 6. Terrain-file / settings read-write and the exposed format

### 6.1 Map settings (keyed text format)

`TGlobalMapForm.ButtonSaveClick → 0x877114`, `ButtonLoadClick → 0x875f04` → opens the file via `0x4d46a0(mode 0x20)` → `0x875f64(stream)`.

`0x875f64` repeatedly calls `0xa18a40(reader, key, ecx=0, out)` with key strings at `0x876870+`. **[O] recovered key list** (all literal ASCII, `FF FF FF FF <len32> <chars>` storage convention verified at `0x876870`):

```
TileCoverFileName, HeightDataFileName, SurfaceFileName, DepthDataFileName,
TileSmoothListFileName, TownTypesFileName, FractionsFileName,
GlobalCoverFileName, DecalPositionsFileName, UnpreparedRiversFileName,
RiverMapFileName, ForestPatternsFileName, ForestMapFileName,
TileChallengeFileName, ForestTileChallengeFileName, RiverKeyPointsFileName,
OutputDataFileName,
MinHeight, MaxHeight, MaxDepth, MapWidth, MapHeight, SharpFactor,
SmoothPasses, TileSmoothPasses, TownFailCount,
TownPlayerName, TownPlayerRace, ForestPlayerName, ForestPlayerRace,
BridgePlayerName, BridgePlayerRace, TownRoadName, VillageRoadName,
IsAddWater, IsGenerateTerrain, IsAddPatterns, IsAddTowns, IsAddRoads,
IsAddRivers, IsResetHeightField, IsAddForest, NoIntersect, UpdateTerrain,
LoadRivers, GetRiverPoints,
RoadFactor, WaterBlocks, WaterOffset, WaterSmoothPasses, WaterSmoothFactor,
WaterSmoothRadius, RiverPointsDistance, WaterCollisionTag,
RiverMinPlateauRadius, RiverPlateauFactor, RiverDepthFactor,
RiverSmRadiusFactor, RiverSmPassesFactor, TileChallengeFactor,
FieldsRedColor, TownSmoothRadiusFactor, TownSmoothFactor, TownSmoothPasses,
StraightRoadDistance, MinBridgeDistance, RoadFailCount,
BridgeCollapseDist, MinBridgeAngle, RiverDecalCurve, RoadWaterFactor
```
**[D]** These names mirror the `TGlobalMapForm` control names almost 1:1, so the UI is an editor for exactly this keyed settings file. **[I]** Layout is consistent with the donor's `section.begin/…/section.end` cfg family used by `globalparams.cfg`, but the reader implementation (`0xa18a40`) was not decompiled to source level → **[U]** exact grammar (section names, quoting, encoding) is not proven.

### 6.2 Terrain map export

`TNewMapDlg.ButtonExportClick` (`0x6ff524`) obtains the path from `SaveDialog`, validates/normalises it (`0x9c2c74`), opens it (`0x4d46a0`, `dx=0xffff`), then calls `0x8a5af0(object, stream)`.

`0x8a5af0` (`off 0x4a4ef0`) writes, in order:
1. literal `TerrainMapBegin` (`0x8a5bfc`, off `0x4a4ffc`) via `0x9c2d58`;
2. four raw writes with sizes **4, 4, 1, 4** from object fields `+8`, `+0xc`, `+0x14`, `+0x1c` (virtual `Write` at vtable slot `+0x10`);
3. nested loops: outer count from `[obj+4]+8`, inner count from `[obj+4]+4`, writing the dword at each nested item's `+0x1c` — **an integer grid/array of 32-bit values**;
4. further sub-object writes at `+0x18`, `+0x20`, `+0x28` via `0x58b95c`, `0x9880ec`, `0x9ce45c` and a helper `0x8a4fa4`;
5. literal `TerrainMapEnd` (`0x8a5c14`, off `0x4a5014`) and close.

**[O]** markers and write widths; **[D]** the array-of-dwords interpretation; **[U]** the meaning of each field, endianness beyond little-endian x86, and whether this is the shipping `.map` byte layout (the editor may use a private serialisation).

### 6.3 Terrain set library

`TFormResource.ButtonTerrainSetlibraryFileNameClick` (`0x6fcbe8`) reads the filename from `EditTerrainSetlibraryFileName` (+0x34c), combines it with the global resource path via `0x48de34`/`0x9c2b38`, calls `0x8bca34` on the loaded object, then writes the resolved name into a display field at `+0x54`. **[U]** internal terrain-set library format was not recovered.

### 6.4 Search for `.terrain` files

`native_bytes_find` / string scans found no literal `.terrain` filename in `editor.exe`; terrain reads appear under the `TileCoverFileName`/`HeightDataFileName`/`SurfaceFileName` keys and the `TerrainMapBegin/End` stream markers. **[U]** A separate `.terrain` file format is not evidenced by this binary.

---

## 7. UI control → config key mapping (`data/gen/globalparams.cfg`, `localparams.cfg`)

**[O] `globalparams.cfg` keys ↔ editor surface** (cfg lines cited; editor strings/field names verified):

| cfg key (line) | editor control / evidence | handler mapping |
|---|---|---|
| `Size` (:2) | RTTI `TXGlobalParams.Size` @ `0x885052`; no same-named edit control in `TFormMapGen` field table | [I] derived from map size, not directly edited here |
| `Sharpness` (:3) | `EditSharpness` (+0x310) / `LabelSharpness` | `0x73fe97..0x73fea2` float → B+0x10 |
| `TileChangeFactor` (:4) | `EditTileChangeFactor` (+0x37c) | `0x73fecb..0x73fee1` float → B+0x14 |
| `FrequencyFactor` (:5) | `EditFrequencyFactor` (+0x3d0) | `0x73fee5..0x73fefb` float → B+0x18 |
| `CellsResolution` (:6) | `EditCellsResolution` (+0x354) | RTTI property at `0x885118` |
| `FailStandCount` (:7) | `EditFailStandCount` (+0x418) | `0x73ff0d..0x73ff15` int → B+0x20 |
| `DefaultMapSize` (:8) | `EditDefaultMapSize` (+0x43c) | `0x73ff1b..0x73ff2e` int → B+0x24 |
| `TileSmoothPasses` (:9) | `EditTileSmoothPasses` (+0x458) | `0x73ff34..0x73ff47` int → B+0x28 |
| `TileSmoothListFileName` (:10) | `EditTileSmoothListFileName` (+0x464), `ButtonTileSmoothListFileName` (+0x468) | `0x73ff4a..0x73ff5e` string → B+0x2c; handler `0x7448c0` |
| `CastlesFileName` (:11) | no same-named control found in `TFormMapGen` field table | [U] |
| `PatternPlayerName` / `PatternPlayerRace` (:12-13) | RTTI properties at `0x88521c` / `0x885249`; no direct edit control in this form | [U] |
| `AddCastles` (:18) | `CheckBoxIsAddCastles` (+0x46c) | `0x73ff9c` virtual `GetCheck` → B+0x4c |
| `CastlePlateauFactor` (:19) | `EditCastlePlateauFactor` (+0x470) | `0x73ffe3..0x73fffb` float → B+0x50 |
| `CastleType` (:20) | `EditCastleTypeName` (+0x478) | `0x73ffd8..0x73ffde` string → B+0x54 |

**[O] `localparams.cfg` keys ↔ `TFormMapGen` / `TLocalParamsItemForm` controls** (cfg lines 4-16; field table slots from §3.1):

| cfg key | control | slot |
|---|---|---:|
| `Name` | `EditLocalParamsItemName` | +0x3f4 |
| `HillPointsDensity` | `EditHillPointsDensity` | +0x330 |
| `MaxHillsHeight` | `EditMaxHillsHeight` | +0x338 |
| `HillsHeightFactor` | `EditHillsHeightFactor` | +0x334 |
| `GlobalMixFactor` | `EditGlobalMixFactor` | +0x3e4 |
| `LocalMixFactor` | `EditLocalMixFactor` | +0x3dc |
| `OffsetRadius` | `EditOffsetRadius` | +0x3ec |
| `SmoothLevel` | `EditSmoothLevel` | +0x400 |
| `SmoothPasses` | `EditSmoothPasses` | +0x424 |
| `SmoothFactor` | `EditSmoothFactor` | +0x448 |
| `MinHeight` | `EditMinHeight` | +0x404 |
| `MaxHeight` | `EditMaxHeight` | +0x410 |
| `CriticalPointsDist` | `EditCriticalPointsDist` | +0x450 |

**[D]** `EditMapFrequency` / `EditBorderFrequency` on `TLocalParamsItemForm` are extra per-climatic-zone settings not present in the shipped `localparams.cfg` sample (whose sole record has `Name = 0`). **[U]** whether those keys exist in a fuller config on disk was not checked here.

---

## 8. Comparison: editor.exe CODE vs cossacks.exe for the generator

| Probe | editor.exe | cossacks.exe | Evidence |
|---|---|---|---|
| `Generating terrain...` | **1 match**, CODE `0x87ba54` (off `0x47ae54`) | **0 matches** | `ev_cf5741dae2f…`; `native_bytes_find` |
| `TFormMapGen` / `TFORMMAPGENERATOR` | CODE `0x73fb61` + `.rsrc` `0xa94526` / `0xafa5a1` | **0 matches** | `native_bytes_find` |
| `TileCoverFileName` | **7** CODE matches (`0x744ae1`, `0x744afe`, `0x873310`, `0x876870`, `0x877938`, …) | **2** CODE matches (`0x718d18`, `0x71b038`) | `ev_1b045d39…`, `ev_5c74116e…` |
| VMT/DFM tables | 145 form VMTs with full control + handler names | RTTI `X*` class names only (per `docs/decomp/DA_PE.md`), no DFM forms | this report + `DA_PE.md` |
| Function discovery | 22,384 functions, but VMT-only handlers missing | 18,918 functions, same class of limitation | `ev_447f029e…`, `DA_PE.md` |

**[D] Verdict:** editor.exe's `CODE` is **strictly more informative for *which controls/parameters exist* and *in which order stages run***, because it carries the DFM + VMT published-method/field tables and the progress strings. cossacks.exe carries the same core generator keys (`TileCoverFileName`) and therefore presumably the same calculation routines, but lacks the UI metadata that makes anchoring possible. For stage *internals* (height arithmetic, mask decode), neither binary was fully decompiled in this pass; use the shared generator code with D03/D05 rather than assuming editor-only truth.

---

## 9. Implications for the port (all PORT APPROXIMATION unless cited as [O]/[D] above)

1. **A donor-grounded stage list now exists** (§5.1). A fresh Godot pipeline should expose the same 12 enable flags and execute stages in the observed order rather than a single monolithic height pass. This is a *behavioural template*, not parity.
2. **The parameter surface is authoritative**: `globalparams.cfg` + `localparams.cfg` keys are mirrored by named editor controls. Any new parameter schema should keep these key names verbatim; do not invent new thresholds.
3. **Water/rivers/forest/towns/roads are separate optional stages** gated by named checkboxes; the port's current single terrain path is not donor-shaped. Keep them separately switchable.
4. **`TerrainMapBegin` / `TerrainMapEnd` markers and the keyed settings keys give a concrete serialisation target** for a donor-derived decoder/compiler; no donor binary needs to be copied.
5. **The auto-plateau / normalize controls are per-object properties** (`TFormProperties`), not generator controls — do not wire them into the global generator path.
6. **Anchoring technique is reusable for D01/D04**: RTTI class-name string → VMT (`vmtClassName=-0x2c`) → method table (`-0x34`) → code pointer; this works where string xrefs do not.

## 10. Risks

- **Risk: over-trusting pseudo-C.** The engine's "Deep study" output is explicitly register-level/inferred (`pseudo_code_inferred`, `conditions_from_flags`); capstone output is raw assembly. All pseudocode in §5 is marked [D].
- **Risk: VMT offset calibration.** Offsets were calibrated on one form and cross-checked on 144 others; a future Delphi version could shift them. Verify `vmtClassName` before reusing.
- **Risk: editor-only serialisation.** `TerrainMapBegin/End` may be an editor-private format, not the shipping `.map` layout. Treat as [U] until D04 confirms against real donor maps.
- **Risk: stage subroutine semantics.** Names such as "GenerateTerrainStageA" are labels invented for this report, not donor identifiers.
- **Risk: shared session.** All native calls used `document: t_68474ddde43f`; the global active target nevertheless drifted to editor.exe mid-task and was explicitly restored to `t_87f0f3c130b0` and verified at the end. No other worker's brief/plan was modified; only two new findings (`fnd_27`, `fnd_28`) were appended. Future workers should re-check `core_session_show()` after any cursor/navigation call.

## 11. UNVERIFIED register (do not promote without new evidence)

1. **[U] Exact semantics of each stage subroutine** (`0x879e3c`, `0x87a0a4`, `0x87a4a8`, `0x879fac`, `0x87db60`, `0x8810cc`, `0x87e44c`, `0x87ab1c`, `0x880a4c`, `0x87cff8`, `0x87d36c`, `0x882da0`, `0x8827ac`, `0x87d7e4`, `0x87b488`, `0x87a724`, `0x87b764`, `0x87dd78`, `0x87dea4`, `0x883380`, `0x875ee4`, `0x9886d8`, `0x8e9e74`). Passes attempted: strings → VMT anchor → engine study (function_not_found) → cursor/instruction → capstone bytes → caller/callee cross-check. Only call order and flags are accepted.
2. **[U] Numeric height/threshold constants inside those stages.** No float literal extraction was completed. Do not invent values.
3. **[U] Exact `.map` / `.terrain` binary layout after `TerrainMapBegin`.** Field meanings and grid interpretation need D04 correlation with real donor maps.
4. **[U] Keyed settings-file grammar** (sections, delimiters, encoding) read by `0xa18a40`.
5. **[U] Terrain-set library internal format** (`0x8bca34`).
6. **[U] Why `TXGlobalParams` RTTI offsets are +4 relative to the handler's object pointer.**
7. **[U] Which control writes cfg key `Size`; `CastlesFileName`, `PatternPlayer*` keys have no same-named control in `TFormMapGen`.**
8. **[U] Any donor visual parity.** No donor GPU A/B frame exists; nothing in this report is a parity claim.
9. **[U] Whether the editor's generator stages execute identically in the shipping game** — shared `TileCoverFileName` strings suggest shared core, not proof of identical defaults.

## 12. Open questions for COORD / sibling workers

- D04: do the `TerrainMapBegin/End` payload field widths (4,4,1,4 + dword grid) match real `.map` files in `C:\Games\Cossacks 3`?
- D01: can the same VMT method-table scanner be run over `cossacks.exe` to anchor engine-side equivalents of `0x87b7ec`?
- D03/D05: can the stage subroutine at `0x879e3c` be matched to mask decode / relief stamp constants recovered from scripts?
- F03: do the 60+ keyed settings keys correspond to a shipped cfg/section not sampled here?
- Owner: should the port expose the 12 donor flags as user-facing toggles (behavioural fidelity) or keep a fixed pipeline (simpler)? Recommendation: expose, labelled PORT APPROXIMATION.

*End of D09. One report written. No donor executable run; no donor file copied into the repository; no source, shader, config, asset, test, git or Godot-runner state changed.*
