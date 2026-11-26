---
id: X02-EDITOR-CORPUS
title: "X02 — bulk pseudo-C decompilation corpus of editor.exe (terrain-term sweep)"
owner: X02 (worker, DONOR-FIRST terrain swarm 2026-11-26)
created: 2026-11-26
status: LANDED
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
target: "C:\\Games\\Cossacks 3\\editor.exe"
target_sha256: 68474ddde43fe4aa084613f01946734a7eea6d511fb98dd81326e8be2ed250ab
target_id: t_68474ddde43f
corpus_path: "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\editor_decomp"
report_scope: "bulk corpus only; targeted terrain-form analysis is D09 and is not duplicated here"
---

# X02 — Bulk pseudo-C decompilation corpus of `editor.exe`

## 1. Executive summary

- **[O]** A complete clean-room pseudo-C corpus of `editor.exe` was written: **22,384 / 22,384 discovered functions**, **22,384 `.c` files**, **312,158,176 bytes** (~298 MiB), plus one resumable state file (`craft-pseudocode-export.json`, 3,233,812 B). Corpus lives **outside the repo** at `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\editor_decomp\`.
- **[O]** The corpus is **register-level pseudo-C with generated `sub_` names and no string literals**. A case-insensitive sweep of all 312 MB for the 24 assigned terrain terms found **exactly one term with hits: `mask` (9 files)**, and every one of those hits is a Windows/OpenGL API thunk (`MaskBlt`, `glColorMask`, `glDepthMask`) — **not** a terrain mask. All other terms (`terrain`, `relief`, `water`, `pattern`, `field`, `forest`, `mine`, `generator`, `plateau`, `normalize`, `collision`, `hill`, `mountain`, `shore`, `river`, `swamp`, `tile`, `height`, `seed`, `smooth`, `blur`, `gauss`) returned **0 files**.
- **[O]** By contrast, the binary's resource/RTTI strings are rich in terrain vocabulary (104 `terrain`, 107 `water`, 103 `pattern`, 104 `field`, 35 `forest`, 22 `plateau`, 16 `generator`, 146 `smooth`, 13 `hill`, 5 `mountain`, 43 `river` …). **Every one of those strings has 0 code xrefs** in the engine's static model and `core_feature_find` reported **0 functions involved**. [D] Therefore the corpus alone **cannot** anchor a terrain string to a generation function; no function in this corpus can be honestly labelled "the terrain generator".
- **[O]** A large fraction of the corpus is **garbled**: 12,254 functions (54.7%) contain at least one garble marker; 559 functions contain ≥1,000 markers. Two extreme clusters are demonstrably **data misread as code** (0x5d8cac–0x5e36b0 and 0x849098+). Per owner directive these were **not silently skipped** — see §6 `GARBLED / MULTI-PASS`.
- **[I]** The editor is a **UI/authoring tool**, not the generator runtime itself: its recoverable terrain surface is DFM control labels (`Terrain Generator`, `Global Terrain Params`, `AutoNormalizeTerrain`, `Water Smooth Passes`, `Forest Patterns File`, `Auto Plateau Terrain Radius`, …). The actual generation maths likely lives in `cossacks.exe` (D01–D08 target) or in a packed/overlay region this engine cannot lift.
- **[U] No donor visual parity claim is made.** Nothing here has been compared to a donor GPU frame; no `variant3d/` file was touched.

## 2. Evidence table

| Evidence id / path | Label | Observation |
|---|---|---|
| `ev_024226b828a30a9d14070533e0b71798e6626d51b51c0e96c3c4ea5ec4c18711` | [O] | `native_functions_list(document=t_68474ddde43f)`: **22,384** functions; limitations `instruction_limit` (6,000,000 instr), `indirect_jumps_unresolved` (682), `stripped_binary`, `static_analysis_only`. |
| `ev_a4b2215f02e1e80a613b4fe2b177ab324b96c3173dc7d67014ada42359522e52` | [O] | `native_source_folder_write` run 1: 6,000 files, sha256 confirmed, `pseudo_code_inferred` + `discovery_capped`. |
| (runs 2–3: `functions_done` 16,000 → 22,384; `remaining` 0; `finished: true`) | [O] | Corpus complete; 3 resumed calls (6,000 + 10,000 + 6,384). |
| `ev_447f029ed1d516fbf1cec297ee7687352488798fed7afa1a974514e7f030a815` | [O] | `core_overview_show`: PE x86, **62,898 strings**, **770 imports / 19 libraries**, 10 segments, same 4 discovery limitations. |
| `docs/.../reports/X02_editor_corpus.md` §4, files `editor_decomp_idx\matches_all.txt`, `garble_counts.txt`, `api_callers2.txt`, `api_roles.txt` | [O] | Shell/ripgrep sweep results and derived counts (reproducible; scripts/results in approved temp folder). |
| `ev_bbf536e3a7039b9791e2b0cceb7262059475323747231c7018cb7728911bf3ae` | [O] | `core_feature_find("terrain")`: **104** strings, 0 function names, 0 imports, **0 functions involved**. |
| `ev_b4df8ded18a56d6fbc27d56fe5f52dbe4cef2abfec25909f28b161a33659f79e` | [O] | `core_feature_find("water")`: **107** strings, 0 functions. |
| `ev_16078101aa69fffc061a48cd1a6ef2a50e5aaad849e37b91097033b45b32b381` | [O] | `core_feature_find("pattern")`: **103** strings, 0 functions. |
| `ev_536d092c4a5b7e67a5c4f147f7927dd5919ad9fa48e0ad10938952e731779515` | [O] | `core_feature_find("field")`: **104** strings, 0 functions. |
| `ev_e01695880370a4f4133ac8e75be43fe255a6e18693515beff1a0c797054cbe3b` | [O] | `core_feature_find("forest")`: **35** strings, 0 functions. |
| `ev_500f48ed25b67a7b14317996d83e5eb4fc0532dbdcdcf4dd828943a3d60a6d52` | [O] | `core_feature_find("plateau")`: **22** strings, 0 functions. |
| `ev_cb7560c3dd2160f049f9ae508039bf153a972cde4852846792c0a0c45a542ebf` | [O] | `core_feature_find("normalize")`: **7** strings, 0 functions. |
| `ev_1241e508a5accb1c38b657eea89ce67d6599cf966646e1db848cd1349b9604ff` | [O] | `core_feature_find("collision")`: large set of UI strings, 0 functions. |
| `ev_41f2f874714c5c7747c13ab984659aef3d858fa509d94d9eb2a80c6db2828306` | [O] | `core_feature_find("relief")`: **0** strings — the editor never uses the word "relief"; it uses "height field"/"terrain". |
| `ev_5f1cd0d11ac6bb3af4ad2b0046741a813462262828004a8980cab09add14e8fd` | [O] | `core_feature_find("generator")`: **16** strings incl. `XMapGenerator` @0xaa1d09, `XCastleGenerator` @0xaa1ee6. |
| `ev_f0fea523ba295aa357528dcf4c08cdf85d982010c003ba95f84946b58fe088d5` | [O] | `core_feature_find("smooth")`: **146** strings incl. `XTileSmooth` @0xaa1e8e, water/height smooth controls. |
| `ev_5ae2734e4e24fc2876c9af000714b6c568e3000c37360c885caad3083b0e825d` | [O] | `core_feature_find("height")`: 6,125 strings (mostly VCL `ClientHeight` noise); `HXHeightField` @0xaa1995. |
| `ev_dddafcabaff2370497f22045784c67fa54f3a920cd4f08f746258e347fa7aa68` | [O] | `core_feature_find("river")`: 43 strings incl. `River Plateau Factor` @0xb3ef20, `River Depth Factor` @0xb3ef7c. |
| `ev_a7a7114c88922ec9d932ecb01a3ed246006f1258e40a00c3ca9cbce123d93b7b` | [O] | `core_feature_find("hill")`: 13 strings incl. `Hill Points Density` @0xaf8667, `Max Hills Height` @0xaf86bf. |
| `ev_55f4f332523799ea4a17d346d1ba26bbdf1aa3320fe7aebaf66e8134351e903d` | [O] | `core_feature_find("mountain")`: 5 strings incl. `seMountains` @0xb2f361. |
| `ev_0c4193fb965223ef4bc2d9423cbd5ae34d21d5436b5301997a6283a2f9ba7595` | [O] | `core_feature_find("stone")`: 2 strings `seStoneroom`, `seStoneCorridor`. |
| `ev_e5adb1c8858968f040560ae4eb77ec67ef13a6e12f9209a7e450797e7c9ae9ed` | [O] | `core_feature_find("quarry")`: 1 string `seQuarry` @0xb2f36e. |
| `ev_ca8a90fc4b253d34544a3c029d7e6ad85411b28c98800d4b51d46093fc54f6c0` | [O] | `native_function_study(0x401000)`: 37 blocks, 224 instr, 32 `__asm`, 4 gotos, 0 strings, 0 callers/callees. |
| `ev_4e292814219104ba121981022791be390ef559b1c3bba3d684f6688278b19f2e` | [O] | `native_function_study(0x595eec)`: 39 blocks, 376 instr, 58 callees, 80 `__asm`, 0 strings. |
| `ev_853d1e9a2b3778a794ed0c55aa6a572441de246f2974848ef80f615e3a2808ea` | [O] | `native_function_study(0x5d8cac)`: **19,308 blocks**, 10,476 `__asm`, 9,297 gotos, 28 unresolved indirect calls. |
| `ev_1f55389f277a4d4efd05c6708ff6411b0d6ca036eb97fd703888ddc8f0a0b5f9` | [O] | `native_function_study(0x849098)`: 6,178 blocks, 3,185 `__asm`, 3,000 gotos, 395 callees. |
| `ev_b163ae3c99d0f8be05d51e988793f0cb86e3472169d6dd42d48d8aaa64e7eef0` | [O] | `native_function_study(0xa259b8 entry)`: 18 blocks, 164 instr, 34 callees, structured. |
| `native_data_show` @0xaa16b6, 0xaa1d50, 0xaa1dd0 | [O] | `XTerrainDataLite`, `XPattern`, `XWater` strings are in **`.rsrc`** with `references_to = 0`. |

## 3. Method

1. **Target handling (shared session discipline).** `core_target_open` on `C:\Games\Cossacks 3\editor.exe` returned target id **`t_68474ddde43f`**, sha256 `68474dd…50ab`, bytes 7,874,416. Active target was immediately restored with `core_target_select({target_id:"t_87f0f3c130b0"})`; every native call below passed `document:"t_68474ddde43f"` explicitly. No other worker's target was left active.
2. **Corpus build.** `native_source_folder_write(document, folder, max_functions, max_seconds)` called 3 times against the same fresh folder; the tool resumed from `craft-pseudocode-export.json`, verified the target sha256 each time, and finished with `finished:true, remaining:0`. No repo file was written by the tool.
3. **Term sweep.** Case-insensitive `rg` over all 22,384 `.c` files for the 24 assigned terms, plus `rg -c` for garble markers (`__asm(`, `arg_`, `/* Eq|Gt|Below|Above|BelowOrEqual */`, 8+-digit hex constants) and `rg -l` for `@thunk` API callers. Results stored in `editor_decomp_idx\*.txt`.
4. **Semantic cross-check.** Because the pseudo-C has no string literals, `core_feature_find`, `native_strings_browse` (via `native_data_show`) and `native_xrefs_list` were used on the editor target to recover the terrain vocabulary and to test whether any of it anchors to code. All tested string addresses returned **0 xrefs**.
5. **Multi-pass protocol (owner directive).** Any function that looked strange was re-examined with `native_function_study` (dossier: assembly counts, block counts, `__asm`/goto counts, callers/callees, strings) and `native_function_disassemble` (raw bytes). Every pass is logged in §6; unresolved cases are `[U]`.
6. **Labels.** `[O]` = directly observed tool/file output; `[D]` = derived from those observations; `[I]` = inference; `[U]` = UNVERIFIED. Pseudo-C itself is `[I]`-grade (`pseudo_code_inferred`, `register_level`) by construction.

## 4. Coverage numbers

| Metric | Value | Source / label |
|---|---|---|
| Discovered functions in editor.exe | 22,384 | `native_functions_list` [O] |
| Functions written to corpus | **22,384 (100%)** | `native_source_folder_write` final run [O] |
| Corpus `.c` files on disk | 22,384 | shell `Get-ChildItem` [O] |
| Corpus bytes | 312,158,176 B (~298 MiB) | shell `Measure-Object` [O] |
| State file | 1 × `craft-pseudocode-export.json`, 3,233,812 B | shell [O] |
| Write runs | 3 (6,000 + 10,000 + 6,384) | tool results [O] |
| Discovery caveat | list incomplete: 6,000,000-instruction cap; 682 unresolved indirect jumps; stripped; static-only | engine limitations [O] |
| Term sweep: `mask` | **9 files** (all API thunks) | `matches_all.txt` [O] |
| Term sweep: other 23 terms | **0 files** | 25-term `rg` sweep [O] |
| Garble markers: ≥1 | 12,254 files (54.7%) | `garble_counts.txt` [O] |
| Garble markers: ≥5 / ≥20 / ≥100 / ≥1000 | 7,314 / 3,462 / 1,389 / 559 files | derived [D] |
| Total garble-marker lines | 2,163,045 | derived [D] |
| External-API caller/thunk files | 40 (15 thunk definitions + 25 real callers) | `api_callers2.txt` [O]/[D] |
| Deep dossiers taken for comparison | 5 (0x401000, 0x595eec, 0x5d8cac, 0x849098, 0xa259b8) | §6 [O] |

**Coverage honest reading [D]:** 100% of *discovered* functions were exported, but discovery itself is capped and the lifter is register-level; "100% corpus" ≠ "100% recoverable terrain semantics".

## 5. Categorised function index

Addresses are corpus filenames / function entries; roles are one-line, evidence-graded. **No terrain-generation function can be identified from the corpus — see §5.3.**

### 5.1 The only terrain-term hit: `mask` (all API thunks)

| Address | Corpus file | One-line role | Label |
|---|---|---|---|
| 0x408694 | `0000000000408694_MaskBlt_thunk.c` | `MaskBlt` import thunk, tail call (GDI masked bitblt) | [O] |
| 0x4339e0 | `00000000004339e0_sub_4339e0.c` | Calls `MaskBlt@thunk()` — GDI masked paint path, **not** a terrain mask | [O] |
| 0x4c0df8 | `00000000004c0df8_glColorMask_thunk.c` | `glColorMask` import thunk | [O] |
| 0x4c0e28 | `00000000004c0e28_glDepthMask_thunk.c` | `glDepthMask` import thunk | [O] |
| 0x4e1b0c | `00000000004e1b0c_sub_4e1b0c.c` | Toggles `glColorMask` all-on/all-off — render-state wrapper | [O] |
| 0x595eec | `0000000000595eec_sub_595eec.c` | `gluProject` + color-mask toggles — 3D project/pick routine | [O] |
| 0x597614 | `0000000000597614_sub_597614.c` | `gluProject` + color-mask toggles — sibling project/pick routine | [O] |
| 0x5f56cc | `00000000005f56cc_sub_5f56cc.c` | Color-mask toggle wrapper | [O] |
| 0xa114e4 | `0000000000a114e4_sub_a114e4.c` | Calls `glDepthMask@thunk` — depth-write toggle | [O] |

### 5.2 External-API interaction functions (candidate loaders / config / render)

| Category | Addresses (one-line role) | Label |
|---|---|---|
| File loaders | 0x4034f8 `ReadFile` wrapper; 0x4035a4 `CreateFileA`+`ReadFile` (0x80-byte reads); 0x403538 `WriteFile`; 0x4051a8 `WriteFile`×2 + `MessageBoxA` (write-failure path); 0x40cf98, 0x40cff0 `CreateFileA` callers | [O] |
| Registry / config | 0x4043b0 (`RegOpenKeyExA` HKLM + `RegQueryValueExA`); 0x40716c, 0x407180 (HKCU/HKLM query chains); 0x44ed0c, 0x44ee2c, 0x44ee30, 0x44f118, 0x44f2b4, 0x48b388, 0x6ac5a8 (registry query wrappers) | [O] |
| Memory / exec | 0x42fb6c `VirtualAlloc(0,0x1000,0x1000,0x40)` — RWX page allocation **[I] possible unpack/overlay staging** | [O]/[I] |
| GDI paint | 0x4339e0 `MaskBlt` caller (see §5.1) | [O] |
| OpenGL render | 0x4e1b0c, 0x595eec, 0x597614, 0x5f56cc, 0xa114e4 (color/depth mask, projection) | [O] |
| Process / UI | 0xa259b8 `entry`: mutex/SEH/version checks, `MessageBoxA`, `WinExec`; 0x48d904 `MessageBoxA` caller | [O] |
| Import thunks | 0x4012c0, 0x408104 (`CreateFileA`); 0x4012e8 (`ReadFile`); 0x401310 (`WriteFile`); 0x401338, 0x408ca4 (`MessageBoxA`); 0x4013c8, 0x4080b4 (`RegOpenKeyExA`); 0x4013d0, 0x4080c4 (`RegQueryValueExA`); 0x40841c (`VirtualAlloc`); 0x408694 (`MaskBlt`); 0x4c0df8, 0x4c0e28, 0x4c11b0, 0xa114e4 (GL) | [O] |

**Terrain relevance [I]/[U]:** the file loaders are the only plausible *pattern/map/terrainmask readers*, but **no string or call chain in the corpus names a file or format**; assigning any of them to `.pattern`/`terrainmask` would be **[U] UNVERIFIED**.

### 5.3 Terrain string/resource index — vocabulary present, function anchors absent

These are `.rsrc` strings (DFM/RTTI), each with **0 code xrefs** and **0 functions involved** in `core_feature_find`. Addresses are *string addresses*, not function addresses; this is stated explicitly to avoid a false anchor.

| Category | Addresses → one-line role | Evidence / label |
|---|---|---|
| Generator classes / UI | 0xaa1d09 `XMapGenerator` (RTTI class); 0xaa1ee6 `XCastleGenerator`; 0xaf791a `"Terrain Generator"`; 0xaf7b48 `"Global Terrain Params"`; 0xaf85f6 `"Local Terrain Params Collection"`; 0xb400fc/0xb4013e `CheckBoxIsGenerateTerrain` / `"Generate Terrain"`; 0xb40443 `"Update Terrain"` | ev_5f1cd…, ev_bbf5… [O] |
| Terrain data / RTTI | 0xaa1686 `EXTerrain`; 0xaa16b6 `XTerrainDataLite`; 0xaa1a68 `sXTerrainData`; 0xaa1e3d `<XTerrainBorders`; 0xa949ee `TFORMTERRAINBORDERS`; 0xaf9d58 `"Set Terrain Preset"`; 0xb5d797 `"Terrains gallery:"`; 0xb5da7a `TrackBarTerrainRaisingFactor` | ev_bbf5… [O] |
| Height field | 0xaa1995 `HXHeightField`; 0xa94fc8 `TRESETHEIGHTFIELDDLG`; 0xb5a5ea `"Random height field"`; 0xb62b64/0xb62bb9 `HeightFieldMin/Max:`; 0xb62c6e `HeightFieldMaxValue:`; 0xb63124 `HeightFieldStand`; 0xb631f7 `HeightFieldReplace`; 0xb632db `HeightFieldSmooth`; 0xb6336e/0xb63492 smooth radius/factor; 0xb63bb4 `HeightFieldReplaceForWater` | ev_536d…, ev_5ae2… [O] |
| Water / shore | 0xaa1dd0 `XWater`; 0xaa1af3 `XWaterShader`; 0xaa1d5a `fXWaterField`; 0xaa9516c `TWATERFIELDSFORM`; 0xb16c44 `CheckBoxCollisionMaskLayerOptionsCloWater`; 0xb37751 `"Water amount"`; 0xb3eca7 `Water Blocks`; 0xb3ecf7 `Water Offset`; 0xb3ed4d `Water Smooth Passes`; 0xb3edaa `Water Smooth Factor`; 0xb3ee07 `Water Smooth Radius`; 0xb3eec3 `Water Collision Tag`; 0xb6de5e `"Water Field List"` | ev_b4df… [O] |
| Pattern / mask | 0xaa1d18 `DXPatternMask`; 0xaa1d50 `XPattern`; 0xaa1e66 `XXPatternFreqs`; 0xaf9873 `Pattern Covers`; 0xb3f169 `Forest Patterns File`; 0xb401fd `"Add Patterns"`; 0xb413a1 `"Load Patterns"`; 0xb4e492 `Pattern Mask`; 0xb5e9c3 `TrackBarPatternMaskRadius`; 0xb5ea43 `CheckBoxPatternMaskRound`; 0xb6328c `PatternMaskStand`; 0xb63598 `PatternMaskReverceStand` | ev_1607… [O] |
| Forest / stone / mines | 0xb3f1ad `Forest Patterns File`; 0xb3f26b `Forest Map File`; 0xb3f32d `Forest Tile Change`; 0xb40dbd `"Add Forest"`; 0xadf9c7 `Forest`; 0xae147e `ForestSteppe`; 0xb2f2d2 `seStoneroom`; 0xb2f335 `seStoneCorridor`; 0xb2f36e `seQuarry`; 0xb2f361 `seMountains` | ev_e016…, ev_0c41…, ev_e5ad…, ev_55f4… [O] |
| Hills / plateau / normalize | 0xae1024 `Plateau`; 0xae0d7a `Hills`; 0xaf7ec8 `Castle Plateau Factor`; 0xaf8667 `Hill Points Density`; 0xaf86bf `Max Hills Height`; 0xb1dc71 `Auto Plateau Terrain Radius`; 0xb1e05c `Auto Plateau Terrain`; 0xb1e26f `AutoNormalizeTerrain`; 0xb3330f `"Normalize Height"`; 0xb3ef20 `River Plateau Factor`; 0xb3f09b `Min Plateau Radius` | ev_500f…, ev_cb75…, ev_a7a7…, ev_ddda… [O] |
| Tile / smooth / collision / season | 0xaa18f8 `XTile`; 0xaa1e2f `dXTileSeason`; 0xaa1e8e `XTileSmooth`; 0xb16b6c `CheckBoxCollisionMaskLayerOptionsCloTerrain`; 0xb16108 `LabelCollisionMaskScaleFactor`; 0xaa18d6 `XCollisionMask`; 0xaa1922 `XCollisionTags`; 0xaa1dd9 `XSeason`; 0xaa1dec `XSeasonType` | ev_a716…, ev_442d…, ev_1241…, ev_f0fe… [O] |
| Absent from editor | `relief` (0), `shore` (0), `swamp` (0), `gold` (0), `coal` (0), `pump` (0), `sand` (0), `terrainmask` (0), `reliefmap` (0) | ev_41f2…, ev_a6b3…, ev_2fc0…, ev_006b…, ev_9205…, ev_0743…, ev_f214…, ev_0d3b…, ev_9650… [O] |

### 5.4 Extreme garbled cluster (functions, addresses)

| Address range | Marker count | One-line role | Label |
|---|---|---|---|
| 0x5d8cac, 0x5d8db0, 0x5d8eb4, 0x5d8fb8, 0x5d90bc, 0x5d9318, 0x5d9988, 0x5d9d50, 0x5da950, 0x5db184, 0x5dc0b0, 0x5ddb7c, 0x5df920, 0x5e05c4, 0x5e167c, 0x5e248c, 0x5e36b0 | 16,999 → 5,554 | Data/as-code pseudo-functions; 0x5d8cac `.c` is 1,374,056 B for a ~0x104-byte entry span | [U] |
| 0x849098, 0x8490a8, 0x8490bc, 0x8490d4, 0x8490ec, 0x849140, 0x8491a0, 0x84910c … | ~4,990 → 4,912 | Second data/as-code cluster (overlay/packed region) | [U] |
| 0x401000 | 251 markers in 250 lines | Data string table misread as x86 code (bytes spell `Fals`, `itro`, `ru`) | [U] |

## 6. GARBLED / MULTI-PASS section (owner directive — no silent skips)

| Function | Pass 1 — corpus (clean-room pseudo-C) | Pass 2 — `native_function_study` dossier | Pass 3 — assembly/bytes / xrefs | Verdict |
|---|---|---|---|---|
| **0x401000** | `sub_401000.c`: nonsense `__asm("outsd dx,[esi]")`, `__asm("arpl …")`, `__asm("aam 0xc2")`, bogus constants `0xac004047`, `0xffc08b00`; no calls. [O] | 37 blocks / 224 instr; **32 `__asm`**, 4 gotos, 0 strings, 0 callers, 0 callees; `referenced_names` show only nearby imports (`__imp_CloseHandle`, `__imp_SetFilePointer`, …). `ev_ca8a90…` [O] | `native_function_disassemble`: bytes `04 10 40 00 03 00 07 42 6f 6f 6c …`, ASCII fragments `46 61 6c 73` ("Fals"), `69 74 72 6f` ("itro"), `72 75` ("ru"); privileged `outsd`/`insb`/`popad` on data. [O] | **[U] data misclassified as code**; pseudo-C unusable. Excluded from semantic claims. |
| **0x5d8cac** | `.c` = 1,374,056 B / ~17k garbled lines; `__asm`, `arg_3d`, bogus `*(uint32_t*)0xa0d7b0a`. [O] | 19,308 blocks, 10,476 `__asm`, 9,297 gotos, 28 unresolved indirect calls, `not_structured`, 0 strings, 0 callers. `ev_853d1e…` [O] | Function entry span ~0x104 B (0x5d8cac→0x5d8db0) yet lifter traversed 36,493 instructions ⇒ control flow ran through data. [D] | **[U] data-as-code / runaway CFG**; not a real function body. |
| **0x849098** | `.c` ≈ 4,990 garbled markers. [O] | 6,178 blocks, 3,185 `__asm`, 3,000 gotos, 395 callees, 0 strings, 0 callers, `not_structured`. `ev_1f5538…` [O] | Cluster 0x849098–0x8491a0 shares identical shape; lies in second garbled band. [O]/[D] | **[U] data-as-code / packed overlay**; unresolved. |
| **0x595eec** | Structured pseudo-C: `gluProject@thunk(...)`, FPU `fld/fstp`, `sub_4b*` calls, `arg_*` slots. [O] | 39 blocks / 376 instr; 58 callees; 1 caller; 80 `__asm` (mostly FPU); 3 gotos; 0 strings. `ev_4e2928…` [O] | No contradictory evidence; calls resolve to import thunks. [O] | **[O] usable lifter output** (register-level, approximate); role = 3D projection/pick. |
| **0xa259b8 (entry)** | Structured pseudo-C: SEH setup, `GetLastError`, `MessageBoxA`, `ReleaseMutex`, `CloseHandle`, `WinExec`; error strings at 0xa25c20/0xa25c28/0xa25d10. [O] | 18 blocks / 164 instr, 34 callees, 0 callers, 0 strings, structured. `ev_b163ae…` [O] | Mirrors expected PE startup; no garble markers. [O] | **[O] usable**; confirms corpus can be clean where code is real. |

**Pass accounting:** each listed function got ≥2 passes (corpus + dossier); the three unresolved ones got a third byte-level pass. 559 corpus functions carry ≥1,000 garble markers and remain **[U] UNVERIFIED — not individually multi-passed** (see UNVERIFIED register). No garbled function was used as terrain evidence.

## 7. Implications

1. **[D] `editor.exe` is a poor place to recover the generation algorithm.** Its recoverable terrain surface is UI/DFM configuration; the pseudo-C carries zero terrain vocabulary. The charter's D01–D08 (`cossacks.exe`) remain the correct primary binary for the generator maths; this corpus is a *negative control* and a UI-parameter inventory.
2. **[I] Parameter names recovered here are donor-grounded knobs worth carrying into a spec** (all `[O]` strings, but their runtime *values* are `[U]`): terrain raising factor, terrain scale, `HeightFieldMin/Max/Offset/Scale/SmoothRadius/SmoothFactor`, `HeightFieldStand/Replace/Random/UseRndScale`, water blocks/offset/smooth passes/factor/radius/collision tag, road-water factor, castle/river plateau factors, min plateau radius, hill point density, max hills height, forest patterns/map file, forest frequency, auto-normalize, auto-plateau radius. These are candidates for F03 (gen cfg constants) and A02 (algorithm) to confirm against `data/gen/*.cfg` — **not** verified constants.
3. **[D] Class names anchor the subsystem taxonomy** (`XMapGenerator`, `XTerrainDataLite`, `XTileSmooth`, `XPattern`, `DXPatternMask`, `XWater`, `XCollisionMask`, `XSeason`, `XCastleGenerator`) but, being in `.rsrc` with zero xrefs, they cannot be tied to concrete functions by this engine. D01 (RTTI→function anchors) should use vtable/DFM-stream analysis, not string xrefs.
4. **[D] The packed/garbled bands (0x5d8cac–0x5e36b0, 0x849098+) are a hard limit of the built-in lifter.** Any terrain code hidden there is beyond this corpus; `native_function_study` uses the same clean-room lifter here (its limitations also list `pseudo_code_inferred`/`register_level`/`inline_asm`), so a Deep Ghidra re-lift would be needed to make progress.
5. **[I] No parity claim.** This corpus cannot support visual comparison; it supplies names/parameter vocabulary only.

## 8. Risks

- **False anchoring risk:** a reader may treat the 9 `mask` corpus hits as terrain-mask logic. They are GDI/GL API calls — explicitly refuted in §5.1.
- **Over-reading garbled output:** 54.7% of files carry garble markers; the extreme ones are data, not code. Treating them as functions would fabricate "evidence".
- **String=xref trap:** 0 xrefs means the engine did not model the reference; it does **not** prove the strings are unused. Absence is not proof (engine limitation explicitly states this).
- **Shared-session risk:** this run briefly opened editor.exe; active target was restored to `t_87f0f3c130b0` immediately and all calls used `document=`. Concurrent D09/Coord work should re-check the active target before issuing default-target calls.
- **Incomplete discovery:** 682 unresolved indirect jumps + 6M-instruction cap mean some real functions are missing entirely from the corpus.
- **Disk/temp risk:** 312 MB corpus is outside the repo in approved temp; it is not a durable deliverable. Only this report is in-repo.

## 9. UNVERIFIED register

| Item | Status | Passes attempted / why unresolved |
|---|---|---|
| Any corpus function = terrain/relief/water/pattern/forest/mine generator | **[U]** | Term sweep 0 hits; string xrefs 0; no call-chain evidence. |
| Which function reads `.pattern` / `terrainmask` / `.map` in editor.exe | **[U]** | File-I/O wrappers exist (0x4035a4, 0x4034f8, 0x40cf98, 0x40cff0) but no filename strings in pseudo-C. |
| Numeric values of any terrain parameter (smooth radius, plateau factor, plateau radius, hill height… ) | **[U]** | Only control *labels* in `.rsrc`; no constants tied to them; must be read from `data/gen/*.cfg` (F03). |
| 0x401000, 0x5d8cac, 0x849098 (+ ~556 other ≥1,000-marker functions) | **[U]** | 2–3 passes each for the three named; byte-level and dossier evidence says data-as-code; remainder not individually multi-passed. |
| `gold`, `coal`, `pump`, `swamp`, `shore`, `sand`, `terrainmask`, `reliefmap` in editor.exe | **[U]/absent** | 0 strings in editor; may be present only in `cossacks.exe` or data files — absence here is not proof of absence in the donor. |
| `ore` result (1 function, 4 imports) | **[U] false positive** | Matches inside `RestoreDC`, `glPixelStorei` etc.; not mineral ore. |
| Meaning of `XWaterShader` / `fXWaterField` beyond names | **[U]** | RTTI/DFM strings only, 0 xrefs. |
| Runtime behaviour of 0x42fb6c `VirtualAlloc(RWX)` | **[U]/[I]** | Likely unpack staging; no downstream evidence. |

## 10. Open questions

1. Can a Deep-mode Ghidra lift (not the built-in lifter) resolve the 0x5d8cac / 0x849098 bands, or are they pure data? (Needs a tool/mode change; I did not attempt it.)
2. Where are the DFM resource streams that consume the terrain control strings, and can a TReader-style index map them to form classes? (D01/F09 territory.)
3. Is the actual generation logic in `cossacks.exe`, in an unpacked overlay of `editor.exe`, or in DScript data? (D02–D08 / F09.)
4. Why are `relief`, `shore`, `swamp`, `terrainmask` absent from editor strings — different vocabulary in the runtime binary?
5. Should the 559 high-garble functions be excluded from any future bulk semantic search to prevent false positives? (Recommendation: yes, flag-and-quarantine.)

## 11. Five-line summary (for COORD)

1. Built complete bulk pseudo-C corpus of `editor.exe`: 22,384/22,384 functions, 312 MB, 3 resumed `native_source_folder_write` runs, outside repo.
2. Swept all 312 MB for 24 terrain terms: only `mask` hit (9 files, all `MaskBlt`/`glColorMask`/`glDepthMask` API thunks); all other 23 terms = 0.
3. Terrain vocabulary is abundant in `.rsrc` strings (104 terrain / 107 water / 103 pattern / 104 field / 35 forest …) but every one has 0 code xrefs → no function can be anchored; no generator identified.
4. 12,254 functions (54.7%) carry garble markers; extreme data-as-code clusters at 0x5d8cac–0x5e36b0 and 0x849098+; 5 dossier multi-passes logged, unresolved flagged `[U]`.
5. Implication: editor.exe is a UI/parameter source, not the generator maths; D01–D08 on `cossacks.exe` remain primary; no parity claim, no repo source edits.

*End of X02 report.*
