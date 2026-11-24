---
id: DEEPDEC-10
scope: "Cross-cutting function/string catalog of donor cossacks.exe (target t_87f0f3c130b0) + ranked unknowns + next targets"
date: 2026-11-24
status: AUDIT_COMPLETE__RUNTIME_PARITY_UNVERIFIED
charter: "docs/coord_swarm_2026-11-24/DEEPDEC_CHARTER.md"
target: "C:\\Games\\Cossacks 3\\cossacks.exe (sha256 87f0f3c1…, PE x86, 18,918 functions, 12,073 strings, 746 imports)"
read_only: true
notes: "Shared target; no open/select, no Frida/runtime/unpacking, no source/asset/git edits. Exactly one report written."
---

# DEEPDEC-10 — cross-cutting function/string catalog and highest-value unknowns

## 0. Method and tool usage

Tools used, all read-only through `tools.craftanything.*` with `document:"t_87f0f3c130b0"`:

- `core_session_show`, `core_overview_show`, `core_investigation_show`, `core_unknowns_show`
- `native_functions_list` (paged; sampled offsets 0, 2000, 6000, 10000, 14000, 18000 — not just page 1)
- `native_functions_search` (case-sensitive regex, subsystem patterns) for counts/address ranges
- `native_api_show` (render + config + hub functions), `native_function_study(detail:"summary")`, `native_function_show`, `native_function_pseudocode`, `native_call_graph_show` (forward/backward)
- `native_bytes_find` (whole-file, encoding "both") on 46 distinctive donor tokens; `native_strings_find` as the data-section control
- `native_data_show(type:"cstring"/"pointer")`, `native_bytes_show`, `native_xrefs_list`, `native_address_show`, `native_function_find`
- Local report corpus read via `read`/`grep` (DECOMP_01–06, TERRAIN2_01–06, AUDIT3D_01–09). **No DEEPDEC_01–09 report existed at read time** (glob `reports/DEEPDEC_*.md` → 0 files), so those could not be mined; peers were not polled or awaited.

**OBSERVATION** = literal tool output. **INFERENCE** = my reading of it. Nothing here claims donor parity and no constant is invented where donor data is absent.

Key session-level limitation (OBS, `ev_60b49743…`): function discovery stopped at 6,000,000 instructions, 1,238 indirect jumps unresolved, 18,439/18,918 function names generated, stripped. Absence from the function list is not proof of absence of code.

---

## 1. Function catalog by subsystem

Counts below are for *named* functions/import thunks matching the given regex, plus the discovered implementation functions I studied. All are address-sorted; the thunk clusters are the PE import-boundary functions, not the game implementations.

| Group | Thunk range | Thunk fns / imports | Representative discovered functions (address) | Evidence ids |
|---|---|---|---|---|
| **Rendering / OpenGL** | `0x4afb0c–0x4aff84` | `^gl[A-Z]`: **82 fns / 118 imports** (`ev_0da96de0…`); `^glu[A-Z]`: 5 / 16 (`ev_ad8fce8c…`); `^wgl`: 4 / 10 (`ev_77db4f28…`); D3D9: **0 fns / 1 import** `Direct3DCreate9@0x907e3c` (`ev_790a646f…`) | `sub_4ff680` (`0x4ff680`, client arrays + immediate mode), `sub_501420` (`0x501420`, display-list path), `sub_88f8a8` (`0x88f8a8`, cached `glBindTexture` wrapper), `sub_5d2234` (`0x5d2234`, 26 GL calls + 36 internal calls), `sub_854398` (`0x854398–0x854773`, water uniform binder) | `ev_bf807206…`, `ev_7b42caf6…`, `ev_33d70482…`, `ev_257da0f2…`, `ev_ead8e728…` |
| **Config / serialization** | `0x4012f0–0x408cec` | file/registry pattern: **28 fns / 34 imports** (`ev_65dec274…`) — `CreateFileA@0x4012f0`, `ReadFile@0x401318`, `SetFilePointer@0x401330`, `WriteFile@0x401340`, `RegOpenKeyExA@0x4013f8` | `sub_7ab704` (`0x7ab704`, 60+ config-key lookups), `sub_896bac` (`0x896bac–0x896c2b`, **528 callers**, named property set/lookup), `sub_896b1c` (`0x896b1c`, **474 callers**), `sub_739d3c` (`0x739d3c`, 17 blocks / 230 instructions, map-section parser, `TerrainMapBegin` xref), `sub_854398` (water schema → `f*` uniforms) | `ev_8632ea91…`, `ev_007a4dcf…`, `ev_3250e0ac…`, `ev_2fbfb239…`, `ev_1022335a…` |
| **Memory / string helpers** | `0x401320–0x4087fc` | **13 fns / 15 imports** (`ev_fadaad12…`) — `RtlUnwind@0x401320`, `CharNextA@0x401348`, `lstrcpynA@0x4013d8`, `lstrlenA@0x4013e0`, `MultiByteToWideChar@0x401408`, `SysAllocStringLen@0x401418`, `LocalAlloc@0x401484`/`0x407cdc` | `sub_405454` (`0x405454`, Delphi ref-counted string assign, **1,390 callers** — highest-degree hub found), `sub_4058b0`, `sub_40580c`, `sub_405400` (string compare/clone/clear used by `sub_896bac`) | `ev_bf13fe20…`, `ev_102567b8…`, `ev_52dc17e6…`, `ev_007a4dcf…` |
| **Input / UI** | `0x401368–0x40900c` | user32 pattern: **22 fns / 32 imports** (`ev_f00ad2a7…`) — `MessageBoxA@0x401368`, `GetAsyncKeyState@0x408994`, `GetCursor@0x4089dc`, `GetCursorPos@0x4089e4`, `GetKeyState@0x408a3c`, `CreateWindowExA@0x40900c` | `sub_8c58e4` (`0x8c58e4`, only static caller of `GetAsyncKeyState@thunk`), script APIs registered in `sub_69a70c`: `GetPickPosition→0x6ac65c`, `GameObjectRayCastMouseRay→0x6aab30`, `GameManagerStartSelection→0x6ae538`, `ImportCameras→0x6af9c0` | `ev_f60231d5…`, `ev_017a5a35…`, `ev_2371b573…`, `ev_10baa52f…` |
| **Sound** | `0x512978–0x512988` | winmm: **3 fns / 5 imports** (`ev_4e2aa297…`) — `waveOutOpen@0x512978`, `waveOutPrepareHeader@0x512980`, `waveOutWrite@0x512988`; `PlaySoundA` import only | `sub_6b8eb4` (`0x6b8eb4–0x6b9572`, **101 sound-API registrations**), `sub_6bb7d0` (`SndGetOrCreateSound` impl), `sub_512f0c` (only static caller of `waveOutWrite`), `SndGetOrCreateSound` signature string at `0x6ba04a`, `SetSndSoundRadius` at `0x6ba5ca` | `ev_6efbfd55…`, `ev_5cce37a7…`, `ev_b7aa3449…`, `ev_9e2e5c61…`, `ev_d39b8665…` |
| **AI / gameplay** | no dedicated import cluster; implementations span roughly `0x6a903c–0x6b3300` and beyond | `sub_69a70c` (`0x69a70c–0x69d184`, 10,872 B, **3,202 instructions, 639 calls out**) registers **639 script API names → implementation addresses** (`ev_2371b573…`, `ev_e218fe6b…`); config-lookup callers span `0x4ed970–0x72b110` (`ev_c23768ce…`) | `sub_6a9288` (`SetAIRegionManager` impl), `0x6aef4c` (`SetAIRegionNameByHandle`), `0x6af084`, `0x6af1b4`, `0x6ac904` (`PlayerSwitchToByHandle`), `0x6b3300` (`SetHeightData`), `0x6b09a4` (`GetMapMinMaxHeight`) | `ev_2371b573…`, `ev_209d3f4b…`, `ev_c23768ce…`, `ev_2bf19694…` |

### Catalog notes (OBS vs INF)

- **OBS:** the four render functions and the GL thunk cluster are statically resolvable; `sub_4ff680`'s API boundary is 6×`glEnable/DisableClientState`, `glVertexPointer`, `glNormalPointer`, `glDrawArrays`, `glDrawElements`, `glBegin/glEnd`, `glVertex3fv` (`ev_bf807206…`).
- **OBS:** `sub_501420` (display-list path) and `sub_4ff680` both have **0 static callers** (`DECOMP_03`; `ev_bd6b1c62…`, `ev_d359dc5d…`); they are reached via function pointers.
- **INF:** the thunk clusters are the import boundary; generated `sub_` functions are the implementations. The *only* durable way to name the game implementations is the script-API registration tables (`sub_69a70c`, `sub_6b8eb4`) — see §2.
- **OBS:** `native_functions_list` sampling at offsets 2000/6000/10000/14000/18000 returns addresses `0x43a83c`, `0x544fe4`, `0x680664`, `0x78a26f`, `0x8a678f` respectively (`ev_0ff7bead…`, `ev_14f147ff…`, `ev_39a73df7…`, `ev_c3ab526e…`, `ev_76c723bc…`); the function list is dense, generated-name dominated, and not a useful semantic index by itself.

---

## 2. Call-graph hubs (`native_api_show` / `native_call_graph_show`)

### 2.1 `sub_4ff680` — render API boundary (OBS)
`ev_bf8072069eab7c5dadb6b53adb98b15e96ba650c541853bdaeb4f8a40d90391d`
- API calls: `glEnableClientState`×3, `glDisableClientState`×3, `glVertexPointer`×2, `glNormalPointer`, `glDrawArrays`, `glDrawElements`, `glBegin`, `glEnd`, `glNormal3fv`, `glVertex3fv`×2.
- 13 internal calls (incl. `sub_509074`, `sub_4a95b4`×5, `sub_4f8404`, `sub_4f7cc8`); **8 unresolved indirect calls** at `0x4ffaa9…0x4ffbf1`.
- INF: this is the proven fixed-function geometry submitter; the unresolved calls are the abstraction boundary that hides shader/material state.

### 2.2 `sub_5d2234` — OpenGL-heavy draw hub (OBS)
`ev_33d7048279a9db6b54866a0e516b9a365ab484f299b0d5c04e65186f03d23e67`
- 26 GL API calls (`glMatrixMode`, `glPushMatrix`, `glLoadIdentity`, `glScalef`, `glEnable`×4, `glBegin`, `glVertex2f`×4, `glEnd`, `glDisable`×4, `glPopMatrix`×2 …), 36 internal calls, 27 unresolved indirect calls.
- Backward graph from `glBindTexture@thunk` (`ev_caa2b756…`): level 1 `sub_88f8a8`; level 2 `sub_4ec794`, `sub_4ecbd8`, `sub_5d2234`, `sub_5d27dc`, `sub_5d2ad4`, `sub_5d2b9c`, `sub_5d2c68`; level 3 16 more (`sub_4ee480`, `sub_4ef810`, `sub_582700`, `sub_77c264`, …). **OBS:** `sub_88f8a8` itself is a one-call wrapper (`glBindTexture@thunk`, 0 internal calls, `ev_7b42caf6…`) — a cached bind helper, not the decision point.
- INF: texture binding is centralized through one wrapper; recovering its cache key is the shortest path to donor texture/material semantics.

### 2.3 `sub_896b1c` / `sub_896bac` / `sub_405454` — config/string mega-hubs (OBS)
- `sub_896b1c` (`0x896b1c`, 6 blocks/40 instructions): **474 callers** (`ev_3250e0ac…`); `native_api_show` shows 5 internal calls, no imports (`ev_1a16c985…`): `sub_4058b0`, `sub_40580c`, `sub_8959f8`, `sub_89bc2c`, `sub_405400`.
- `sub_896bac` (`0x896bac–0x896c2b`, 47 instructions): **528 callers** (`ev_897587ef…`); pseudo-C (`ev_007a4dcf…`) does `FUN_004058b0(name)` → `FUN_0040580c(name, const)` → `FUN_008959f8(owner,name)` → `FUN_0089bb4c(...)` → `FUN_00405454(dst,src)`; i.e. a **named-property get/set** primitive used for both config keys and shader uniforms.
- `sub_405454` (`0x405454`, Delphi ref-counted string assign): **1,390 callers** (`ev_bf13fe20…`); `native_xrefs_list` returned all 1,390 edges (`ev_52dc17e6…`).
- Backward graph from `sub_896b1c` (`ev_c23768ce…`, depth 2, 30 nodes) shows callers spread across `0x4ed970`, `0x544548`, `0x5766f8`, `0x5a1cd0`, `0x5d570c`, `0x6142e4`, `0x626620`, `0x6caa00`, `0x6d0208`, `0x6eaaa0`, `0x71a72c`, `0x72b110` … — i.e. the config-name lookup is genuinely cross-cutting, not a single subsystem.
- INF: any claim "token X is unused" must account for the fact that lookup is by *name string*, so direct xrefs from token to consumer are usually 0 (see §3).

### 2.4 The script-API registration bridge — the single most important hub (NEW, OBS)
- `sub_69a70c` at `0x69a70c–0x69d184`: 3,202 instructions, **639 calls out**, 1 caller (`ev_e218fe6b…`). Pseudo-C (`ev_2371b573…`) is a flat sequence of 639 calls of the form
  `(**(**)(*param_1+0x30))(param_1, " function|procedure Name(...)", &LAB_006a…/FUN_006a…);`
  My parser extracted **639 name→impl pairs**. Examples: `GetMapWidth→0x6a9228`, `GetMapHeight→0x6a9248`, `MapWorldUpdateTerrainData→0x6aa5cc`, `GetViewerHeight→0x6aa3cc`, `LoadMapNeeded→0x6ab810`, `GenerateMapNeeded→0x6ab83c`, `GetPickPosition→0x6ac65c`, `SetShadowMapSize→0x6ac468`, `RayCastWater→0x6afe80`, `GetWater→0x6b1df8`, `SetHeightData→0x6b3300`, `PlayerSwitchToByHandle→0x6ac904`, `SetAIRegionManager→0x6a9288`, `AIRegionDoUpdateObject→0x6af1b4`.
- `sub_6b8eb4` at `0x6b8eb4–0x6b9572`: 512 instructions, **101 calls out** (`ev_134bd61a…`); pseudo-C (`ev_6efbfd55…`) contains **101 name→impl pairs** for the sound subsystem: `SndGetOrCreateSound→FUN_006bb7d0 (=0x6bb7d0)`, `SetSndSoundRadius→FUN_006bbaec (=0x6bbaec, not a discovered function)`, `SetSndSoundRadiuses→0x6bbb24`, `GetSndSoundRadius→0x6bbb4c`, `SndGetOrCreateAmbientThread→0x6bb324`, `SetSndAmbientThreadSetPlaying→0x6bb3c0`, `SetFullAmbientSoundVolume→0x6bcb54`.
- The signature *strings* themselves sit just past each routine's end (e.g. `SndGetOrCreateSound(emittertag: Integer; const libraryname: String; owner: Integer): Integer` at `0x6ba04a`, `ev_9e2e5c61…`/`ev_d39b8665…`; `SetDateTimeManagerEnabled(enabled: Boolean)` at `0x6a21da`, `ev_0acf351d…`), which is why `native_function_find` reports "not inside any discovered function" for them (`ev_083f4ed9…`, `ev_3a2d8ced…`) and why `native_strings_find` returns 0.
- `sub_6bb7d0` (`SndGetOrCreateSound` impl, pseudo-C `ev_5cce37a7…`) resolves the emitter library through `FUN_00705944`, `FUN_00862030` and `FUN_005149b0`, then calls `FUN_0051535c(emitter+0x18, lib+0xc)`; **no `8000`/`80` literal** appears in this impl, so the donor-script comment "80 for 3D sound, 8000 for isometric" remains UNVERIFIED at binary level.
- INF: the "no code reference" observations in DECOMP-02/04 for class/script names are an artefact of name-based dispatch. The registration routines *are* the code references; the `wst*` water table and `f*` uniform names confirm the same pattern for shader state.

---

## 3. Whole-file token PRESENT/ABSENT table (correcting DECOMP-04)

`native_bytes_find` searches the whole file (UTF-8 + UTF-16LE); `native_strings_find` searches only strings the engine extracted (effectively data sections). All rows below were run this session with `document:"t_87f0f3c130b0"`. "Addresses" are VAs; `.rsrc` entries have no code role proven.

| Token | Class | Result | First addresses (section) | Whole-file evidence id | `native_strings_find` control |
|---|---|---|---|---|---|
| `SphereHeight` | config key | **PRESENT** (2) | `0x7abc44`, `0x7abc5c` [CODE] | `ev_ef958abd…` | — |
| `SphereHeightMin` | config key | **PRESENT** (1) | `0x7abc5c` [CODE] | `ev_2c8de7fa…` | — |
| `MinHeightMinAngle` | config key | **PRESENT** (1) | `0x7abe5c` [CODE] | `ev_1ee5027d…` | — |
| `FocalLength` | camera config | **PRESENT** (16) | `0x4c851e`, `0x58c14b`, `0x58e1ac`, `0x5d5d54`, `0x5fe19e` [CODE] | `ev_57e43e14…` | — |
| `DynFogDepth` | fog config | **PRESENT** (3) | `0x5fe437`, `0x5fe46b`, `0x7ac0ac` [CODE] | `ev_63237c3d…` | — |
| `DynFogStart` | fog config | **PRESENT** (3) | `0x5fe4a7`, `0x5fe4db`, `0x7ac0c0` [CODE] | `ev_54e5fbcc…` | — |
| `DateTimeEnable` | env config | **PRESENT** (2) | `0x7e6630`, `0x7e9aac` [CODE] | `ev_0a4f0542…` | — |
| `Weather` | env config | **PRESENT** (32) | `0x58f6b6`, `0x58f6db`, `0x5946a8` [CODE] | `ev_eac96617…` | — |
| `hmapTex` | water schema | **PRESENT** (1) | `0x853e0c` [CODE] | `ev_3951d3f4…` | — |
| `waterAmount` | water schema | **PRESENT** (3) | `0x853d04`, `0x855317`, `0x85581a` [CODE] | `ev_13095961…` | — |
| `fresnelPower` | water schema | **PRESENT** (3) | `0x853d18`, `0x855333`, `0x85557e` [CODE] | `ev_fd9e5eb8…` | — |
| `waveFreq` | water schema | **PRESENT** (4) | `0x853d5c`, `0x854b3e`, `0x854d5b`, `0x854dd7` [CODE] | `ev_87e92016…` | — |
| `reflectionMap` | water schema | **PRESENT** (5) | `0x853c70`, `0x855266`, `0x855297`, `0x855680`, `0x85572d` [CODE] | `ev_2c212f36…` | — |
| `shadowMap` | water schema | **PRESENT** (1) | `0x853e70` [CODE] | `ev_61d4e26b…` | — |
| `cameraModel` | water schema | **PRESENT** (1) | `0x853eac` [CODE] | `ev_129e84a5…` | — |
| `XTerrainBorders` | RTTI class | **PRESENT** (4) | `0x7783b6`, `0x7783cf`, `0x7783e9` [CODE], `0x9593b4` [.rsrc] | `ev_92d12e29…` | — |
| `ColorTable` | RTTI/config | **PRESENT** (32) | `0x4b4592`, `0x4b45a2`, `0x4b45ba` [CODE] | `ev_2645cbf4…` | — |
| `HeightField` | RTTI/config | **PRESENT** (48) | `0x54198b`, `0x541a07`, `0x541a97` [CODE] | `ev_7edfa7df…` | — |
| `XSkyDome` | RTTI class | **PRESENT** (7) | `0x58bc96`, `0x58bcab`, `0x58bcc2` [CODE] | `ev_ba84cd7f…` | — |
| `XWaterShader` | RTTI class | **PRESENT** (4) | `0x8537f4`, `0x853807`, `0x85381e` [CODE], `0x958c11` [.rsrc] | `ev_c04470de…` | — |
| `source.pfx` | PFX data file name | **ABSENT** (0) | — | `ev_c6f5b8ce…` | — |
| `PixelRatio` | PFX key | **PRESENT** (5) | `0x7ec14c`, `0x7f2984`, `0x7f4418`, `0x7f65c8`, `0x7f79d4` [CODE] | `ev_6d98854c…` | **0** (`ev_908d2c86…`) |
| `AlphaTime` | PFX key | **PRESENT** (10) | `0x7ec719`, `0x7f31b4`, `0x7f4c8c` [CODE] | `ev_7f91b3a9…` | — |
| `EndFrame` | PFX key | **PRESENT** (59) | `0x5509b7`, `0x550c94`, `0x550ce8` [CODE] | `ev_b90408d9…` | — |
| `FrameRate` | PFX key | **PRESENT** (8) | `0x7ebd28`, `0x7ec1d8`, `0x7f3044` [CODE] | `ev_d5d845b6…` | — |
| `TimeLimit` | PFX key | **PRESENT** (5) | `0x801ae3`, `0x803d8c`, `0x804340` [CODE] | `ev_d941c0c4…` | — |
| `MarkWidth` | PFX key | **PRESENT** (5) | `0x801bdd`, `0x803dd4`, `0x804388` [CODE] | `ev_45b8b4e1…` | — |
| `OnEndFrameHide` | PFX key | **PRESENT** (4) | `0x7f235c`, `0x7f3e08`, `0x7f6950`, `0x7f7d5c` [CODE] | `ev_f546e83f…` | — |
| `musketflash` | PFX section | **ABSENT** (0) | — | `ev_7eabb5b6…` | — |
| `cannonsmoke` | PFX section | **ABSENT** (0) | — | `ev_ca4e26fb…` | — |
| `diffusewaves1` | texture name | **ABSENT** (0) | — | `ev_9c0ef1c1…` | — |
| `heightmapwaves0` | texture name | **ABSENT** (0) | — | `ev_b537c6e1…` | — |
| `alphavert` | terrain mask | **ABSENT** (0) | — | `ev_6d26950c…` | — |
| `reftile` | material name | **ABSENT** (0) | — | `ev_081ddb39…` | — |
| `cWaterHeight` | script literal | **ABSENT** (0) | — | `ev_eab5aabc…` | — |
| `cPlaceRoads` | script literal | **ABSENT** (0) | — | `ev_c7fcf7c3…` | — |
| `grass1` | texture name | **ABSENT** (0) | — | `ev_4587d32e…` | — |
| `rockNvf` | texture name | **ABSENT** (0) | — | `ev_a4aa4f05…` | — |
| `cMaxHeight` | script literal | **ABSENT** (0) | — | `ev_97e5b900…` | — |
| `SetDateTimeManagerEnabled` | script API | **PRESENT** (1) | `0x6a21da` [CODE] = `"SetDateTimeManagerEnabled(enabled: Boolean)"`, 0 data xrefs | `ev_ec685044…`, `ev_0acf351d…` | — |
| `SndGetOrCreateSound` | script API | **PRESENT** (1) | `0x6ba04a` [CODE] = full Pascal signature, 0 data xrefs | `ev_9e2e5c61…`, `ev_d39b8665…` | **0** (`ev_ee3f1175…`) |
| `SetSndSoundRadius` | script API | **PRESENT** (2) | `0x6ba5ca`, `0x6ba65a` [CODE] = `"SetSndSoundRadius(value: Float; sound: Integer)"` | `ev_c3a02c5f…`, `ev_3a595e82…` | — |
| `SndGetOrCreateAmbientThread` | script API | **PRESENT** (2) | `0x6b957d`, `0x6ba041` [CODE] | `ev_9e60dc45…`, `ev_258e7dd…` | — |
| `TerrainMapBegin` | .map marker | **PRESENT** (2) | `0x73a028`, `0x73a6b4` [CODE]; `0x73a028` has **1 data xref from `0x739d56` in `sub_739d3c`** | `ev_256c242b…`, `ev_e4382212…`, `ev_d767df70…` | **0** (`ev_4397a7ba…`) |
| `wstHMapTex` | water state enum | **PRESENT** (via pointer table at `0x8fabb0`) | `0x8539fc` [CODE] | `ev_a799b41c…`, `ev_6e2dac03…` | **0** (`ev_faef0256…`) |
| `SetAIRegionManager` | script API | **PRESENT** (20 `procedure SetAI` hits) | `0x69d448` = `"procedure SetAIRegionManager(enabled: Boolean)"`; 1 xref from `0x69a825` in `sub_69a70c` | `ev_f62d0cf0…`, `ev_209d3f4b…`, `ev_5df37544…` | **0** (`ev_50a7aa94…`) |
| `function GetPlayer` | script API family | **PRESENT** (106) | `0x68cc71` = `"function GetPlayerEnabled(const playername: String): Boolean"` | `ev_fceec1ac…`, `ev_3207900a…` | — |
| `function GetAI` | script API family | **PRESENT** (43) | `0x69d411` = `"function GetAIRegionManagerEnabled(): Boolean"` | `ev_aa51f7b0…`, `ev_2bf19694…` | — |
| `function GetMap` | script API family | **PRESENT** (28) | `0x60af71` = `"function GetMapVersion: String"` | `ev_e20ecc9c…`, `ev_5c8a6bc0…` | — |
| `function GetTerrain` | script API family | **PRESENT** (6) | `0x6a2005` = `"function GetTerrainBordersStep: Float"` | `ev_ffc0d0c2…`, `ev_0c53378d…` | — |
| `GetCurrentMouseWorldCoord` | input script API | **PRESENT** (1) | `0x66daa2` [CODE] = `"GetCurrentMouseWorldCoord(var arayx, arayy, arayz: Float)"` | `ev_801325d6…`, `ev_10baa52f…` | — |
| `aspriteblank` | PFX manager | **ABSENT** (0) | — | `ev_77bc6b17…` | — |

### 3.1 Correction to DECOMP-04 (OBSERVATION)

DECOMP-04 established that `SphereHeight`, `hmapTex`, `DynFogDepth`, etc. are CODE-resident and that `native_strings_find` gives false negatives for them. This session **generalises and strengthens** that correction:

1. The entire donor script-level vocabulary — PFX keys (`PixelRatio`, `AlphaTime`, `EndFrame`, `FrameRate`, `TimeLimit`, `MarkWidth`, `OnEndFrameHide`), script API declarations (`SndGetOrCreateSound`, `SetDateTimeManagerEnabled`, `SetAIRegionManager`, `GetCurrentMouseWorldCoord`), map section markers (`TerrainMapBegin`) and water shader state names (`wstHMapTex`) — is **PRESENT in CODE**, and all five sampled tokens return **0** from `native_strings_find` (`ev_908d2c86…`, `ev_ee3f1175…`, `ev_4397a7ba…`, `ev_faef0256…`, `ev_50a7aa94…`).
2. Therefore DECOMP-02/04's "0 matching functions / 0 imports / 0 code refs" for RTTI classes and script tokens must be read as *"no direct static xref"*, not *"unused"*. The bridge is name-based registration (§2.4).
3. The ABSENT rows above are still only statements **about file bytes**. Texture/section names like `grass1`, `musketflash`, `alphavert`, `source.pfx` live in external `data/**` files; absence in the EXE is expected (DECOMP-04 fnd_7/fnd_8) and does not mark a feature unused.
4. **INF:** the distinction that matters for the port is: *schema/API vocabulary compiled in* vs *concrete values and art in external text*. Cross-cutting catalog work must use whole-file `native_bytes_find` everywhere `native_strings_find` was previously used.

### 3.2 NEW: canvas of the water shader state table (OBS)

The pointer array at `0x8fabb0` (`ev_6e2dac03…`, 1 xref) holds pointers to CODE-resident `wst*` strings. `sub_854398` (`ev_257da0f2…`) binds the descriptor fields to `f*` uniform names through `sub_896bac`. Recovered name pairs (all `ev_` ids below are from `native_data_show`):

| Uniform written by `sub_854398` | Field offset | State name in table | Evidence |
|---|---|---|---|
| `fReflectTex` | `+0x04` | `wstReflectTex` (`0x853834`) | `ev_931b4357…` |
| `fWaveTex` | `+0x08` | `wstWaveTex` (`0x85384c`) | `ev_8debe34f…` |
| `fTime` | `+0x0c` | `wstTime` (`0x853860`) | `ev_8a4dc6c7…` |
| `fEyePos` | `+0x10` | `wstEyePos` (`0x853870`) | `ev_bc2275ad…` |
| `fDeepColor` | `+0x14` | `wstDeepColor` (`0x853884`) | `ev_8421ae1f…` |
| `fShallowColor` | `+0x18` | `wstShallowColor` (`0x85389c`) | `ev_d22444a8…` |
| `fReflectAmount` | `+0x1c` | `wstReflectAmount` (`0x8538b4`) | `ev_2f0ab88e…` |
| `fWaterAmount` | `+0x20` | `wstWaterAmount` (`0x8538d0`) | `ev_54cf2154…` |
| `fFresnelPower` | `+0x24` | `wstFresnelPower` (`0x8538e8`) | `ev_828143c7…` |
| `fFresnelBias` | `+0x28` | `wstFresnelBias` (`0x853900`) | `ev_2b0b8df1…` |
| `fHdrMultiplier` | `+0x2c` | `wstHdrMultiplier` (`0x853918`) | `ev_98ca82f6…` |
| `fWaveFreq` | `+0x30` | `wstWaveFreq` (`0x853934`) | `ev_624bb5f1…` |
| `fWaveAmp` | `+0x34` | `wstWaveAmp` (`0x853948`) | `ev_5d2a386a…` |
| `fDistFactor` | `+0x38` | `wstDistFactor` (`0x85395c`) | `ev_50daa549…` |
| `fBumpFactor` | `+0x3c` | `wstBumpFactor` (`0x853974`) | `ev_bcfd3c09…` |
| `fTexScaleS/T` | `+0x40/+0x44` | `wstTexScaleS` (`0x85398c`), `wstTexScaleT` (`0x8539a4`) | `ev_13d010fe…`, `ev_86317b09…` |
| `fWaveDir0/1` | `+0x48/+0x4c` | `wstWaveDir0` (`0x8539bc`), `wstWaveDir1` (`0x8539d0`) | `ev_80d3bf83…`, `ev_9bd3e678…` |
| `fFogEnabled` | `+0x50` | `wstFogEnabled` (`0x8539e4`) | `ev_8844c6e6…` |
| `fHMapTex` | `+0x54` | `wstHMapTex` (`0x8539fc`) | `ev_a799b41c…` |
| `fHMapWidth/Height/Min/Max` | `+0x58…+0x64` | `wstHMapWidth` (`0x853a10`), `wstHMapHeight` (`0x853a28`), `wstHMapMin` (`0x853a40`), `wstHMapMax` (`0x853a54`) | `ev_353e0d0a…`, `ev_3eed0242…`, `ev_3407dab8…`, `ev_4860d338…` |
| `fShadowed/Tex/Size/Color` | `+0x68…+0x74` | `wstShadowed` (`0x853a68`), `wstShadowTex` (`0x853a7c`), `wstShadowSize` (`0x853a94`), `wstShadowColor` (`0x853aac`) | `ev_c50a9e8a…`, `ev_1d5d5847…`, `ev_895b0a7c…`, `ev_f8f10380…` |
| `fCameraModel` | `+0x78` | `wstCameraModel` (`0x853ac4`) | `ev_0c294a37…` |
| after table | — | `shadowColor` (`0x8587e4`), `eyePos` (`0x8587f8`) | `ev_e682257a…`, `ev_48920c54…` |

`sub_854398` also calls `FUN_00898004(param_2,"fWaterStates",&PTR_s_wstReflectTex_008fabb0)` first — i.e. the whole state table is registered as one named block. **INF:** this closes the DECOMP-04/TERRAIN2-03 gap about `hmapTex` "only a string assignment": the descriptor has a *proven uniform sink* with field offsets `+0x54…`, but which GPU texture is bound to `fHMapTex` is still UNVERIFIED (no shader API imported; the setter is an engine abstraction `sub_896bac`).

---

## 4. Reconstructed logic and port implications (cross-cutting)

1. **Donor is a compiled-script engine, not a conventional stripped C++ game.** Two registration routines (`sub_69a70c`, `sub_6b8eb4`) bind 639 + 101 Pascal-style API names to implementation addresses through a virtual method at `*obj+0x30`. This explains why script tokens have no direct xrefs and why `native_strings_find` misses them. **Port implication:** every readable donor `.script`/`.inc` API call can, in principle, be resolved to a donor function address; this is the correct way to extend the earlier DECOMP/TERRAIN2/AUDIT3D findings rather than re-probing strings.
2. **Rendering is fixed-function GL 1.x with an engine material/uniform layer on top** (`ev_bf807206…`, `ev_257da0f2…`). No `glCreateShader`/`glUseProgram`/`glGenBuffers` and only one unreferenced `Direct3DCreate9` import (`ev_8632ea91…` GL counts, `ev_790a646f…`, DECOMP-03 fnd_3). **Port implication:** Godot's shader pipeline is a *translation*, not a copy; do not claim donor shader parity from data-file equations alone.
3. **Config, water state and script APIs all funnel through name-based lookup primitives** (`sub_896b1c` 474 callers, `sub_896bac` 528, `sub_405454` 1,390). **Port implication:** a single well-chosen donor hub study yields more leverage than many token searches; the 474-caller spread across `0x4ed970–0x72b110` is the game-logic belt.
4. **Water descriptor is a 30-field struct with a proven uniform binder** (`sub_854398`, §3.2). **Port implication:** the port's flat water quad cannot be called donor-faithful; the donor has a full shader-state descriptor, but the actual texture binding and GL program remain UNVERIFIED.
5. **Map section markers are compiled into CODE with a proven consumer** (`TerrainMapBegin@0x73a028` → `sub_739d3c` via `0x739d56`; caller chain `sub_712104→sub_712448→sub_739d3c` and `sub_712768→sub_71278c→sub_739d3c`, `ev_87818338…`). **Port implication:** DECOMP-06's float-grid recovery can be extended to a real section parser study; do not treat the grid as an isolated blob.

---

## 5. Ranked top 15 unknowns (by expected impact on the 3D port)

Sources mined at read time: DECOMP_01–06, TERRAIN2_01–06, AUDIT3D_01–09, TERRAIN2_05 leftovers register. DEEPDEC_01–09 reports did not exist at read time (glob = 0). Ranking is my INFERENCE from the cited reports; P0 = blocks core fidelity, P1 = major visible/mechanical gap, P2 = refinement.

| # | Unknown | Priority | Evidence / origin | Why it matters for 3D |
|---|---|---|---|---|
| 1 | **Render dispatch chain & indirect-call identity**: `sub_4ff680`/`sub_501420` have 0 static callers; 8 unresolved indirect calls at `0x4ffaa9–0x4ffbf1`; display-list path "terrain or UI?" UNVERIFIED | **P0** | DECOMP_03 §3/6.3/6.4; `ev_bf807206…`, `ev_bd6b1c62…` | Without the caller chain the port cannot know which draw path applies to terrain, water, entities or HUD — blocks any claim of donor draw-order/fidelity. |
| 2 | **Script-name → implementation dispatch for gameplay/AI**: 639 + 101 registrations found, but the mechanism linking `wst*`/`f*` names and script calls to concrete objects is still only inferred from `sub_896bac` pseudo-C | **P0** | NEW §2.4; `ev_2371b573…`, `ev_007a4dcf…` | This is the master index for every other subsystem; resolving it turns 20+ "UNVERIFIED" items into readable implementations. |
| 3 | **Absolute camera FOV / sensor width / yaw** (FocalLength=400): 2.90° vs 17.27° both assumptions; yaw unknown | **P0 / BLOCKED** | AUDIT3D_05 E3/L164-174; TERRAIN2_05 DF-03; `ev_57e43e14…` (FocalLength is CODE-resident) | Framing, minimap viewport box and click-to-move all scale from this; ~2.3× ground-width error already observed. |
| 4 | **Bone-parent table in `.oss`**: 483 frames @30 fps, 20 bones, weights readable, no parent field; donor-faithful skinned GLB BLOCKED | **P0 / BLOCKED** | AUDIT3D_01 E16, AUDIT3D_06 :26/62; TERRAIN2_05 DF-04 | Every 3D entity remains a static bind pose; no animation fidelity possible until resolved. |
| 5 | **Water `hmapTex`/`reflectionMap` sampler→texture binding and GL program**: descriptor + 30 `wst*` uniforms proven, texture identity not | **P0** | TERRAIN2_03 UNV-1/2; DECOMP-04 §8; NEW §3.2 `ev_257da0f2…`, `ev_a799b41c…` | Port's constant-alpha plane cannot be upgraded to donor water without the binding; also blocks reflection FBO. |
| 6 | **No genuine 3D viewport capture**: windowed/headless both fall back to CPU map; visual parity UNVERIFIED | **P0/P1** | AUDIT3D_09 §4/§6; TERRAIN2_05 DF-01 | Blocks A/B verification of every other item; no pixel evidence can close unknowns 1–5. |
| 7 | **Donor view-depth fog vs port fog-of-war overlay binding** (`fog_explored`/`fog_vis`), depth fog disabled in gameplay camera | **P1** | TERRAIN2_03 :118/:168; AUDIT3D_03 :166; TERRAIN2_05 DF-08 | Two different mechanics are conflated in the port; wrong fix would break visibility behaviour. `fFogEnabled`/`wstFogEnabled` now proven (`ev_8844c6e6…`) gives a new handle. |
| 8 | **Terrain tile face-promotion rule + `alphavert`/alpha atlas cell order** (`tsDouble`/`ttExtended`) | **P1** | TERRAIN2_01 :189/228; TERRAIN2_02 :79/161; TERRAIN2_06 E06/E07 | Cliffs and mask sprites cannot be projected faithfully; currently PORT APPROXIMATION. |
| 9 | **World scale: metres-per-cell and height→mesh LOD** — no donor metres-per-cell constant in readable text | **P1** | TERRAIN2_01 :138/228/336, G32; AUDIT3D_05 E3 | All spatial conversions (picking, camera, audio radius, FX size) inherit this scale. |
| 10 | **Scene lighting rig**: donor `light.cfg` ambient/diffuse/specular + `Position=-0.3447,0.9387,0` unused in 3D; no `WorldEnvironment`/`DirectionalLight3D` | **P1** | AUDIT3D_08 item 12; AUDIT3D_03 :88; TERRAIN2_03 UNV-6 | No light means no donor shading; visual consequence still UNVERIFIED. |
| 11 | **PFX section→FX kind mapping and pixel↔metre/second semantics** (`PixelRatio`, `Interval`, `FrameRate`, `AlphaTime/Power`, `MarkWidth`) | **P1/P2** | AUDIT3D_06 :25, DF-07/DF-22; V715 :52-56; NEW §3 (`PixelRatio` PRESENT in CODE, `ev_6d98854c…`) | FX are procedural primitives; three quoted trail literals are the only donor grounding and their unit is unproven. |
| 12 | **`.map` pre-grid ~1.6 MB region and two gaps undecoded; tile-record semantics, −1.1 sentinel, row orientation** | **P1** | DECOMP_06 :112-117/201/228; `TerrainMapBegin` xref now proven (`ev_d767df70…`) | Objects/resources/structures in `.map` are unavailable; only the float height grid is recovered. |
| 13 | **Donor pick radius / overlap depth** engine-side; port uses guessed body lift 0.8 m and px↔m fallbacks | **P2** | AUDIT3D_05 :175-177; TERRAIN2_05 DF-17; `GetPickPosition→0x6ac65c`, `GameObjectRayCastMouseRay→0x6aab30` now have impl addresses | Selection/rally fidelity and "click the right unit" behaviour. |
| 14 | **Economy/victory mechanics**: two-sided market absent, 0.35 price floor invented, `bexists` vs any-building elimination, formations/morale/rout | **P2** | TERRAIN2_05 DF-11/DF-12/DF-20; R07/R02/R12 | Gameplay-rule parity, independent of rendering; lower visual impact but user-visible. |
| 15 | **Team-colour container skins, alpha/>1.0 colour clamping, uniform-0 tint** and ACL playback semantics | **P2/P3** | TERRAIN2_05 DF-06/DF-21; AUDIT3D_02 :185-188; AUDIT3D_08 item 4 | Cosmetic/asset fidelity; do not invent constants here. |

**Honest note:** unknowns 1, 2, 5, 11, 12 are directly advanced by this session's new evidence (registration bridges, water uniform table, PFX keys in CODE, map-marker xref); unknowns 3, 4, 6, 9, 10 remain BLOCKED by absent data/runtime proof and must not be guessed.

---

## 6. Recommended top 5 NEXT decompilation targets (exact tool + query)

All use `document:"t_87f0f3c130b0"`; read-only, no target open/select, no runtime.

1. **Resolve the map section parser (highest leverage for DECOMP-05).**
   `tools.craftanything.native_function_study({document:"t_87f0f3c130b0",function:"0x739d3c",detail:"complete"})` then `tools.craftanything.native_function_pseudocode({document:"t_87f0f3c130b0",function:"0x739d3c"})`.
   Why: `TerrainMapBegin@0x73a028` has its only data xref at `0x739d56` inside this function (`ev_d767df70…`); it has 50 callees, 11 unresolved indirect calls, 2 callers (`sub_712448`, `sub_71278c`). Target the `TerrainMapEnd` marker next with `native_bytes_find({text:"TerrainMapEnd"})` + `native_xrefs_list`.

2. **Recover the render dispatch chain (unblocks unknown #1).**
   `tools.craftanything.native_call_graph_show({document:"t_87f0f3c130b0",address:"0x4ff680",direction:"backward",max_depth:6,max_nodes:200})` and the same for `0x501420`; then `tools.craftanything.native_function_references_list({document:"t_87f0f3c130b0",function:"0x4ff680",direction:"incoming"})` and `native_instruction_show` on `0x4ffaa9`, `0x4ffabc`, `0x4ffadb`, `0x4ffb01`, `0x4ffb0f`, `0x4ffb63`, `0x4ffb90`, `0x4ffbf1`.

3. **Exploit the 639-entry script API bridge (unblocks unknown #2; dispatch by subsystem).**
   `tools.craftanything.native_function_pseudocode({document:"t_87f0f3c130b0",function:"0x69a70c"})` → parse all `name → LAB_/FUN_` pairs; then `tools.craftanything.native_function_pseudocode({document:"t_87f0f3c130b0",function:"0x6b8eb4"})` for the 101 sound APIs (already parsed in §2.4; re-run to page the full text). Recommended first implementations to study: `0x6b3300` (`SetHeightData`), `0x6ac65c` (`GetPickPosition`), `0x6ab83c` (`GenerateMapNeeded`), `0x6b09a4` (`GetMapMinMaxHeight`), `0x6bb7d0` (`SndGetOrCreateSound`).

4. **Finish the water uniform/binding path (unblocks unknown #5).**
   `tools.craftanything.native_api_show({document:"t_87f0f3c130b0",function:"0x854398"})` and `tools.craftanything.native_call_graph_show({document:"t_87f0f3c130b0",address:"0x854398",direction:"backward",max_depth:4,max_nodes:80})`; follow `FUN_00898004` (`0x898004`) and `FUN_0089bb4c` (`0x89bb4c`) with `native_function_pseudocode` to identify where `fHMapTex` becomes a texture unit. Cross-check `native_bytes_find({text:"TerrainMapEnd"})` is not needed here; instead `native_xrefs_list({address:"0x8fabb0"})` for the water-state table's other consumer.

5. **Identify what the 26-GL-call render hub actually draws (terrain vs UI).**
   `tools.craftanything.native_function_study({document:"t_87f0f3c130b0",function:"0x5d2234",detail:"complete"})` + `tools.craftanything.native_function_pseudocode({document:"t_87f0f3c130b0",function:"0x5d2234"})`; then `tools.craftanything.native_call_graph_show({document:"t_87f0f3c130b0",address:"0x5d2234",direction:"backward",max_depth:4,max_nodes:80})`. Why: 27 unresolved indirect calls (`ev_33d70482…`) sit exactly at the abstraction boundary that decides whether this is a world-space or screen-space pass.

---

## 7. UNVERIFIED / BLOCKED register for this report

- **OBS but role UNVERIFIED:** all 11 ABSENT byte tokens in §3 — statement is about file bytes only; external `data/**` files are the authority.
- **OBS but role UNVERIFIED:** `SndGetOrCreateSound@0x6ba04a`, `SetDateTimeManagerEnabled@0x6a21da`, `SetAIRegionManager@0x69d448` — full signatures present, 0/0/1 direct data xrefs; dispatch via registration routines inferred (§2.4).
- **UNVERIFIED:** which GPU texture/uniform unit `fHMapTex`/`reflectionMap` bind to; no shader API imported (`ev_790a646f…`, DECOMP-03 fnd_3).
- **BLOCKED:** absolute camera FOV/yaw; `.oss` bone parents; genuine 3D viewport capture; donor metres-per-cell; any runtime behaviour (charter forbids Frida/runtime).
- **NOT AVAILABLE AT READ TIME:** DEEPDEC_01–09 peer reports; their UNVERIFIED items could not be folded in. No polling was performed.
- **No donor parity claimed.** No invented constants. All addresses are donor VAs (`image_base 0x400000`) or file offsets as labelled.

## 8. Next atomic task suggestions (coordinator)

- Dispatch a "registration table parser" atom that dumps all 740 name→impl pairs from `sub_69a70c` + `sub_6b8eb4` into a cross-reference index for all peer agents (highest multiplicative value).
- Dispatch a `TerrainMapEnd` byte/xref probe paired with the `sub_739d3c` study to complete the `.map` grammar.
- Ask camera/terrain/water peers to re-run their token searches with `native_bytes_find` instead of `native_strings_find` before marking anything ABSENT.
- Keep unknowns 3/4/6/9/10 explicitly BLOCKED in the port docs; do not fill them with guesses.
- No source/asset/git edits were made; this report is the only file written.
