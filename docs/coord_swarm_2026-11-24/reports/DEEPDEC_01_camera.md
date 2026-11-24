---
id: DEEPDEC-01
scope: "DONOR CAMERA SUBSYSTEM — cossacks.exe config consumer sub_7ab704, focal/height/tilt/pan/zoom/minimap-jump math from read-only donor text"
owner: DEEPDEC-01
date: 2026-11-24
status: AUDIT_COMPLETE__RUNTIME_PARITY_UNVERIFIED
target: "t_87f0f3c130b0 (cossacks.exe, sha256 87f0f3c1…), shared, never opened/selected"
verdict: "sub_7ab704 is a pure config loader: 49 typed keys → 49 camera-object fields. Zoom height is clamped to SphereLength/SphereLengthMin (58/20 shipped), tilt is a constant -32° for all four angle keys, wheel delta and pan/middle-drag are additive profile-scaled formulas (not multiplicative zoom), and the default.cameras target (49, 78.42125) implies back-offset ≈ height·cot(32°). FOV/sensor, ArcTan semantics and the elastic update loop remain UNVERIFIED. No source/git/runtime edit made; no donor parity claim."
---

# DEEPDEC-01 — donor camera subsystem (deep decompilation)

## 0. Method and tools (all read-only)

Craft Anything via `execute` / `tools.craftanything.*`, shared target `t_87f0f3c130b0`
(Deep mode, 431 pre-existing evidence records). Toolsets: `enable_toolset({toolset:"native"})`.
Tools actually used: `native_function_study(detail:"complete"|"summary")`,
`native_function_pseudocode`, `core_evidence_browse` (parts `pseudocode`, `pseudo_code`,
`summary`), `native_api_show`, `native_bytes_find` (whole-file, UTF-8 + UTF-16LE),
`native_bytes_show` (VA windows), `native_function_find`, `native_function_study`,
`core_feature_find`, `core_text_read`, `core_brief_write`, `core_finding_record`.

Constraints honoured: no `core_target_open`/`core_target_select`, no Frida/runtime,
no donor unpacking or execution, no source/asset/config/test/git edit, exactly this one
report file. Donor text read only through `core_text_read` and Python `bytes`/latin-1.

**Key methodological result (finding 6 below):** `core_feature_find` returns 0 strings,
0 functions and 0 imports for every probed camera token (e.g. `FocalLength`,
`MinHeightMaxAngle`, `SetMainCameraMoveToTargetXZ`, `GetCameraRestrictInfo`,
`ScreenToWorldRayCast`), because it indexes only data-section strings. The same tokens
are present in **CODE** when searched with whole-file `native_bytes_find`. The earlier
DECOMP-04 observation is confirmed and extended here to the whole camera vocabulary.

## 1. Evidence table

| # | Evidence id | Address / offset / path:line | Finding (OBS = observed, INF = inferred) |
|---|---|---|---|
| E1 | `ev_e57a21ab1a1b4ae13f6775983d70523a06ef7467b29e22e6eabfe59e551bb196` | `sub_7ab704` @ `0x7ab704` | OBS — 9 blocks, 335 instructions, 57 internal calls, 1 caller, 0 system/library APIs, 0 unresolved indirect calls. |
| E2 | `ev_49ae2873aecd311823324663755f67a6d6bbd884f6b51ddf2d48962e11aefe2f` | full pseudo-C part (8,423 UTF-16 units, one page) | OBS — every config key read, default float literal and destination field offset of `sub_7ab704` (decoded in §2). |
| E3 | `ev_fd4311b1dfd4767f2a15f34e3dae6fc7413e6c62754401c272918fe9250f3a51`, `ev_acad42c1706118176db3a00ab4cf524fcd835db55ff8928950dda150d9d77551` | Ghidra pseudo-C, `FUN_007ab704`, 194 lines | OBS — independent confirmation of key names, typed fields and defaults; int/bool readers shown with explicit defaults (500, 0, 1). |
| E4 | `ev_1b05e16d915d70d366b896e887b1e15f2128001c2ba11d58b96f2878300a54dc` | CODE `0x7abbfc..0x7ac11c`, file offset `0x3aa1bc` | OBS — Delphi AnsiString key table: 49 keys + 3 section headers, each `[refcount -1][len][chars][NUL/pad]`; addresses in the lifter's `edx=` immediates resolve exactly to the key names. |
| E5 | `ev_8632ea91987627f3e0c53891e75261801cf204cc31b4e4297501b0938a54e4b6` | `0x7ab704` API boundary | OBS — 0 API calls; 57 internal calls: `sub_8959f8` (section lookup ×3), `sub_896b1c` (float ×43), `sub_896a8c` (int ×1), `sub_8967b4` (bool ×5), and 5 mode/finalizer calls (`sub_7ac1f4`, `sub_7ae9d0`, `sub_7ae994`, `sub_4a6e64`, `sub_4ce8bc`). |
| E6 | `ev_923812f5dd2bbc0a746f2d3f59b80e271eec7cf402b57e2fc17b7e8e7e3dc9d7` | caller `sub_7aea0c` @ `0x7aea0c` | OBS — `uVar2=FUN_008986c0(...); if (FUN_008990cc(uVar2,param_2)) { uVar3=FUN_008990a4(uVar2,0); FUN_007ab704(param_1,uVar3); } FUN_00404574(uVar2);` — caller opens the config parser, selects section 0 and passes it to the loader. |
| E7 | `ev_48d111f8dc566ba7d884c137a4818ad43d523bd6adcaab64f175fc82c0add330`, `ev_3a2eae69ea20c4c2673ef63c1b90b0da12fa3b223ee67d2fc8eeb3e1280fcfad`, `ev_2e9376e4f13e313e68fcd7cd6bfd0814465587665c0e3940a9182c1aed8b5ffe` | `sub_896b1c`, `sub_8967b4`, `sub_896a8c` | OBS — typed readers parse via `FUN_0089bc2c` (float), `FUN_0089bcbc` (bool), `FUN_0089bb80` (int); on absent key they return the caller-supplied default. Call counts 474 / 325 / 239 respectively. |
| E8 | `ev_f24c1aa180d3edb2fc77234ea714c83d494917a6173b16c0f9c877a5a80c25e7` | `C:\Games\Cossacks 3\data\cameras\camera.cfg:1-65` | OBS — the shipped camera config; all 49 keys with concrete values (table §2). |
| E9 | `ev_ea5be18a0d5d3d01a8fbe0638796eb4eb87b4d5b6277038119eee9dfce9fc77c` | `data\cameras\default.cameras:5-18`, `:36-49`, `:67-80` | OBS — Camera0 target `(0,49,78.42125)`, pos `(0,0.0529899597167969,0.084808349609375)`, `DirZ=-1`, `UpY=1`, `FocalLength=400`, `DepthOfView=1200`; CameraDebug `FocalLength=100`, `DepthOfView=50`; `SmoothingTime=3000`. |
| E10 | `ev_0212f2f7f73ba49ed7931603b29f0edf1926645940314bf15826f7e1dfbda16e` | `data\gui\common.inc\onmousewheel.inc:29-47,56-78,82-104,296-337` | OBS — full wheel-zoom and minimap-camera formulas (§3.1–3.3). |
| E11 | `ev_da1e62c846f5346dc9a1ae9bb8ba330aa50b7ecd2ecf0b748e19a559bce3f250` | `data\gui\menu.inc\oncamera.inc:10-29,37-76` | OBS — key/mouse scroll = profile ×4, arrow keys → camera absolute directions, corner tags 20–27 and 30. |
| E12 | `ev_6695a6f63ec146bce3319473073ecf52cb642870717b61eae07b1fd5546705d0` | `data\gui\menu.inc\cameracontrol.inc:20-35` | OBS — edge bands `cMargin=8`, `cCornerMargin=24`, tags 20–27. |
| E13 | `ev_1d437772c6938702a140321685ba5cec2fdff070596afdf705b17d07cb6b607f` | `data\gui\menu.inc\eventminimap.inc:8-35` | OBS — minimap LMB down/repeat/up → `ExecuteState('OnMouseDown')` with tags 10/20/30; RButton up → order + `GameManagerCancelBrush`. |
| E14 | path:line (Python latin-1 read) | `data\gui\menu.inc\onmousedown.inc:116-131` | OBS — minimap LMB: `SetCameraElasticTargetObject(0)`, `_control_GetMoveCameraToPositionOffset(x,y,newx,newy)`, `SetMainCameraRotateToTargetDir(false)`, `SetMainCameraMoveToTargetXZ(newx,newy)`; double-click instead `_control_MoveCameraToPosition(x,y,0,False)`. |
| E15 | `ev_0cc3781c31ff337dd7d837505094a985d5595f49071d033a9a7d5d845acbfc27` | `data\gui\menu.inc\dombtncameracontrol.inc:19-20,23-50` | OBS — middle-drag `deltaX=((prevX-curX)/60)*(0.5+middlemousescrollspeed)`, `deltaY=((prevY-curY)/45)*(0.5+…)`; X clamped by `GetCameraElasticRestrict(lx,lt,rx,by)`, Z clamp commented out. |
| E16 | `ev_992ea3e21ae383e5aa2622fdb78af11fe3e60911ffd5bbbb70177efc1e5e2886` | `data\scripts\lib\profile.script:17-20`, `:513-516` | OBS — defaults `keyscrollspeed=mousescrollspeed=middlemousescrollspeed=wheelspeed=0.5`; all clamped to `[0,1]`. (`data\resources\config.res:789-792,1112-1115` repeats 0.5.) |
| E17 | `ev_7a8cf1b52a79e47833f192f25219c982a8b4e523cef4b0a545c7bc7b0a9707c7` | 16 CODE hits (list §4) | OBS — whole-file `native_bytes_find` finds all `FocalLength` occurrences; data-section `native_strings_find`/`core_feature_find` miss them. |
| E18 | `ev_31962e76ce96da56013a3b17083d6c17d24fc6b023e774086d831707de9e923e`, `ev_1166f626e19791523e001112d83ee940e8c04bf8a0ab68b750d5073e6acca70c` | CODE `0x7abe78`, `0x7abe94` | OBS — `MinHeightMaxAngle` and `MaxHeightMinAngle` each occur **once** in the whole file; both are keys read by `sub_7ab704`. |
| E19 | `ev_524d29c8297ccffe51c1fed436a93a6860edc9a23bc5d13d25b0477cc89cb40b`, `ev_1e10212ea5282f78e8fa6f209ed395fef2a80dd045cdbc58a999bcda8a5d4718`, `ev_61b994dea06957bb53aacb3450796c20ea3d3265abdad5da9c7e68ce4b5d3592` | whole `cossacks.exe` | OBS — `keyscrollspeed`, `mousescrollspeed`, `ZoomCamera`: **0 hits** in the binary. They exist only in donor text, so no native function can be statically tied to them. |
| E20 | `ev_167f66d8abedd56cbeecc0444b2551554e23de39326cb554c9229631435cb5a0`, `ev_cb8bd0f4120e06270f6849668956a8e0d35f5d0d8254c12c4d9c6561119e5f78` | CODE `0x5fc902`, `0x5fc8d0` window | OBS — `SetMainCameraMoveToTargetXZ(x: Float; z: Float)` exists as a script-API signature string inside `sub_5fc2d0` (a 2,698-block API registration table), not as a symbol. |
| E21 | `ev_0eb1f63858f1df62b11abe33c764967b0f6e77a24c015a9bf0eab8e528981258`, `ev_604761c12e2b6bd31ca1aab2036acea16e6e9eff48d2a766467be10b0fc1ad8a`, `ev_89815fa21b31d62c1f6fd78b0ddb63d69b143a66d32b11260ee278f16c3eef01`, `ev_3f5b5514025492812556fdbd622594ed43da7a3a1d09400b7bdd73effd4294a3` | `core_feature_find` | OBS — 0 matching strings / functions / imports for `FocalLength`, `SetMainCameraMoveToTargetXZ`, `GetCameraRestrictInfo`, `ScreenToWorldRayCast`, `MinHeightMaxAngle`, `SetCameraFocalLengthInfo`. Tool limitation, not absence. |
| E22 | `ev_2ab20e9cc7fe027e0ca59e9db1c45253da67752b1e89d61b41119e3395b4afa2`, `ev_f8dc2a21e8bb7e183f5cbbf9afccd28dc7d8a5a8fb100c1817621971c238235e`, `ev_f00f0c29560bada0bd285bdaf72301a1e8c1b9fdf1ec33a71c73c7b1ba9597a4`, `ev_1e1829b4ffc8fafb32ca404006b6e4f100fb612c42a4d73d9e352b3077c0454d`, `ev_b7382ccaf21d2051425bf145e275ec1cd5eebfce516b0b0665c9e474dd57bf54` | `0x7aadb0`, `0x7ab32c` | OBS — the FocalLength hits at these two "function entries" are false positives: the bytes are `default.cameras` schema keys (`UpX/UpY/UpZ/FocalLength/DepthOfView/MoveSpeedToMark/…`); the lifter output is 14–15 `__asm(...)` garbage instructions, confirming misidentified data. |
| E23 | `ev_6d27ae38cc46e0bedb206caed394f4b0c226182f474d1335eedcb1da60a6a6bb`, `ev_cb8bd0f4120e06270f6849668956a8e0d35f5d0d8254c12c4d9c6561119e5f78`, `ev_c46645f1e1a0cdc2f162dd1265c7a77655709b6819bca4edd946d04965eab3f6`, `ev_2d7758151fc63f202369f262756a04273e0cce05ba28fa36de7adeac35da214d`, `ev_0e44c5b91d259081b0f666d41c3526108647e7f70c5c16ece4ed5b658e09ecce`, `ev_6ce85ce98d71e12b390f0ed9725012c65ad0617eacb4e2ec40e42395c60b65e0`, `ev_c24ed60008cd50cd18afbe70d146b749a8069548136982cc08bfacf5e9e725ba`, `ev_c86cdc01aa0fe99d67ce07f70d8b9a9d52d233f8844fdcc57fa4a310745b4c4d`, `ev_f5a43bfd8d674bd8e1266c8b4446886a26739036b7a868782ed70bd420ccadb5`, `ev_57d77c3340e28252b8ea5b7b5f88fdc4a72fff4a6935ee8f4df4307ab1ad9c37`, `ev_ffb3584a889d387c61daaed2c605085f8f87c13cf6d7586eb61901d66015935b` | CODE `0x5fc40e`, `0x5fc902`, `0x673a06`, `0x5fe772`, `0x5fe956`, `0x5fdafe`, `0x5fea5e`, `0x5fe18e`, `0x5fe37e`, `0x5fca32`, `0x5fccda` | OBS — camera/wheel script-API declarations are compiled into CODE (signature strings), e.g. `GetCameraDynamicFocalLength() : Boolean`, `GetCameraRestrictInfo`, `GetCameraFreeRotationInfo`, `CameraInfoReadProperties`, `SetCameraFocalLengthInfo`, `SetCameraControlMouseWheelDistance`, `GetGUIEventMouseWheelDelta`, `GetCameraAbsoluteLeftDirection`, `SetCameraElasticMoveDirection`, `SetCameraDepthOfView`. |
| E24 | `ev_eeb139c2b9afd4293fd8e9be2ccb733d994b191e4ba1591d4cf3af6209958209`, `ev_23439e7c19c85f08f9bc87bd81eb4d68ce5ccd57713cd53abf1abf5d0c7f39eb`, `ev_e138f6a8fbdcac8304fc1f48460c09b275a4c39d950a6a6ea990b4402f3b6440` | `sub_7ac1f4`, `sub_7ae9d0`, `sub_7ae994` | OBS — `FreeRotationMode` is stored at object+`0x31f` and gates a large init routine; the two raycast modes set/clear single bits in the flags word at object+`0x29c`. |
| E25 | `ev_711c348b3d6db3896a74aff720d40f0bfb6250a8cf6dbfb6b523dd48957192b0`, `ev_6be6c465fcb15d7627f2a048944dd3aa3f72fa3b7e73a433a9177b9a0345e8e4` | `sub_4a6e64`, `sub_4ce8bc` | OBS — final two calls of `sub_7ab704`: `sub_4a6e64(MaxFocalLength, MinFocalLength, field_0xa0)` then `sub_4ce8bc(object, <float result>)`. `sub_4ce8bc` writes a clamped float to `param_1[0x28]` (= `0xa0`) and invokes a virtual method. INF: this is the focal/projection update, but exact semantics are UNVERIFIED. |
| E26 | `ev_b3ce43e7600490e375a257b90a074099cf259f95793a400266562f7b9d90249e`, `ev_4b50f7546b32cd330823b27f84d71c28fdfab0ec4c5609f8fa328b9c6ff4731b` | whole binary | OBS — `_control_GetMoveCameraToPositionOffset` and `MoveCameraToPosition`: 0 hits; `GetGUIMinimapUnderMouse` at CODE `0x66db22`, `GetCurrentMouseWorldCoord` at `0x66daa2`. The minimap-jump offset helper is text/script-side and its body was NOT located. |

## 2. `sub_7ab704` fully reconstructed — every key, default and typed field

All facts below are OBSERVED from E2/E3/E4/E5. Float constants were decoded from the
lifter's 32-bit hex literals (e.g. `0x41200000` = 10.0f, `0xc1a00000` = -20.0f,
`0x3d4ccccd` = 0.05f, `0x43800000` = 256.0f). `sub_896b1c` = float with default,
`sub_896a8c` = **int** with default, `sub_8967b4` = **bool** with default (E7).
`+off` is the byte offset in the destination camera object (`param_1`, i.e. `ebx`).

| Group | Key (address) | Binary default | Type | Field | `camera.cfg` value (E8) |
|---|---|---:|---|---|---|
| RestrictInfo | `HeightTarget` `0x7abc14` | 0.1 | f32 | `+0x298` | 1 |
| RestrictInfo | `HeightTargetMin` `0x7abc2c` | 0.1 | f32 | `+0x200` | 5 |
| RestrictInfo | `SphereHeight` `0x7abc44` | 10.0 | f32 | `+0x204` | 58 |
| RestrictInfo | `SphereHeightMin` `0x7abc5c` | 0.5 | f32 | `+0x208` | 20 |
| RestrictInfo | `SphereLength` `0x7abc74` | 10.0 | f32 | `+0x20c` | 58 |
| RestrictInfo | `SphereLengthMin` `0x7abc8c` | 1.0 | f32 | `+0x210` | 20 |
| ElasticInfo | `MoveVelocity` `0x7abcb8` | 1.0 | f32 | `+0x218` | 0.125 |
| ElasticInfo | `HeightVelocityFactor` `0x7abcd0` | 0.0 | f32 | `+0x214` | 0.05 |
| ElasticInfo | `RotationVelocity` `0x7abcf0` | 0.2 | f32 | `+0x21c` | 0.05 |
| ElasticInfo | `TargetOffset` `0x7abd0c` | -0.2 | f32 | `+0x220` | 0 |
| ElasticInfo | `CameraOffset` `0x7abd24` | 2.0 | f32 | `+0x224` | 0 |
| ElasticInfo | `IntervalTime` `0x7abd3c` | 500 | **int32** | `+0x228` | 10 |
| ElasticInfo | `StepTimeMove` `0x7abd54` | 0.05 | f32 | `+0x22c` | 0.00001 |
| ElasticInfo | `StepTimeMoveDirection` `0x7abd6c` | 0.05 | f32 | `+0x230` | 1 |
| ElasticInfo | `StepTimeMoveAccel` `0x7abd8c` | 0.05 | f32 | `+0x234` | 0.00001 |
| ElasticInfo | `StepTimeMoveDecel` `0x7abda8` | 0.05 | f32 | `+0x238` | 0.00001 |
| ElasticInfo | `StepTimeRotation` `0x7abdc4` | 0.05 | f32 | `+0x23c` | 0.00001 |
| ElasticInfo | `StepTimeTargetRaycast` `0x7abde0` | 0.05 | f32 | `+0x240` | 0.05 |
| ElasticInfo | `StepTimeCameraRaycast` `0x7abe00` | 0.05 | f32 | `+0x244` | 0.05 |
| ElasticInfo | `StepTimeCameraDistance` `0x7abe20` | 0.05 | f32 | `+0x248` | 0.005 |
| FreeRotationInfo | `MinHeightMinAngle` `0x7abe5c` | -20.0 | f32 | `+0x24c` | -32 |
| FreeRotationInfo | `MinHeightMaxAngle` `0x7abe78` | 80.0 | f32 | `+0x250` | -32 |
| FreeRotationInfo | `MaxHeightMinAngle` `0x7abe94` | -60.0 | f32 | `+0x254` | -32 |
| FreeRotationInfo | `MaxHeightMaxAngle` `0x7abeb0` | 40.0 | f32 | `+0x258` | -32 |
| FreeRotationInfo | `AngleLerpPower` `0x7abecc` | 0.3 | f32 | `+0x25c` | 1 |
| FreeRotationInfo | `MinDistToTargetObject` `0x7abee4` | 4.0 | f32 | `+0x260` | 1 |
| FreeRotationInfo | `MaxDistToTargetObject` `0x7abf04` | 10.0 | f32 | `+0x264` | 10 |
| FreeRotationInfo | `MaxHeightLerpFactor` `0x7abf24` | 0.1 | f32 | `+0x268` | 0.15 |
| (top) | `Bounded` `0x7abf40` | false (ecx=0) | **bool** | `+0x31c` | True |
| (top) | `DistToGroups` `0x7abf50` | 10.0 | f32 | `+0x338` | 15 |
| (top) | `MinFocalLength` `0x7abf68` | 30.0 | f32 | `+0x350` | 400 |
| (top) | `MaxFocalLength` `0x7abf80` | 50.0 | f32 | `+0x354` | 400 |
| (top) | `FocalLengthPower` `0x7abf98` | 0.5 | f32 | `+0x360` | 1.0 |
| (top) | `FreeRotationMode` `0x7abfb4` | false (ecx=0) | **bool** | `→sub_7ac1f4`, flag at `+0x31f` | True |
| (top) | `ElasticTargetRaycastMode` `0x7abfd0` | **true** (cl=1) | **bool** | `→sub_7ae9d0`, bit at `+0x29c` | false |
| (top) | `ElasticCameraRaycastMode` `0x7abff4` | **true** (cl=1) | **bool** | `→sub_7ae994`, bit at `+0x29c` | false |
| (top) | `PowerDOF` `0x7ac018` | 0.5 | f32 | `+0x368` | 0.5 |
| (top) | `MinLengthDOF` `0x7ac02c` | 128.0 | f32 | `+0x370` | 128.0 |
| (top) | `MaxLengthDOF` `0x7ac044` | 128.0 | f32 | `+0x374` | 128.0 |
| (top) | `MinNearDOF` `0x7ac05c` | 256.0 | f32 | `+0x384` | 256.0 |
| (top) | `MaxNearDOF` `0x7ac070` | 256.0 | f32 | `+0x388` | 256.0 |
| (top) | `MinFarDOF` `0x7ac084` | 256.0 | f32 | `+0x398` | 256.0 |
| (top) | `MaxFarDOF` `0x7ac098` | 256.0 | f32 | `+0x39c` | 256.0 |
| (top) | `DynFogDepth` `0x7ac0ac` | false (ecx=0) | **bool** | `+0x3bc` | False |
| (top) | `DynFogStart` `0x7ac0c0` | 1.0 | f32 | `+0x3c0` | 0.25 |
| (top) | `DynFogEnd` `0x7ac0d4` | 1.0 | f32 | `+0x3c4` | 0.025 |
| (top) | `DynFogDensity` `0x7ac0e8` | 1.0 | f32 | `+0x3c8` | 2.0 |
| (top) | `DynFogPower` `0x7ac100` | 0.5 | f32 | `+0x3cc` | 0.85 |
| (top) | `DynFogOffset` `0x7ac114` | 0.0 | f32 | `+0x3d0` | 0 |

**49 keys total** (6 + 14 + 8 + 21 = 43 floats + 1 int + 5 bools). Counts match the
57-call breakdown in E5 exactly (3 section lookups + 43 float reads + 1 int + 5 bool +
5 mode/finalizer calls).
Notable: the shipped config overrides **every** binary default where it is present;
the binary defaults (e.g. `SphereHeight=10`, all focal 30/50, elastic step times 0.05)
are fallbacks, not gameplay values.

**Finalizer (E25):** after all keys are read, `sub_7ab704` calls
`sub_4a6e64(MaxFocalLength@+0x354, MinFocalLength@+0x350, field@+0xa0)` and then
`sub_4ce8bc(object, <float result>)`, which clamps the float and writes it back to
`+0xa0` via a virtual call. INF: focal→projection/field-of-view update; no source-level
proof, and no sensor constant was found anywhere in `data/**`.

## 3. Donor camera math (exact formulas with `path:line`)

### 3.1 Zoom (wheel) — PROVEN

`data\gui\common.inc\onmousewheel.inc` (E10):

```
:29-30  GetCameraRestrictInfo(lx, rx, fy, by, htm, sh, shm, maxHeight, minHeight);
:33     GetCameraFreeRotationInfo(minHeightMinAngle, minHeightMaxAngle,
                                   maxHeightMinAngle, maxHeightMaxAngle, ...);
:37     CameraInfoReadProperties('@movecamera', tx, height, tz, cx, cy, cz);
:39-41  oldHeight := height;  height := height + deltaheight;
        height := Clamp(height, minHeight, maxHeight);
:43-46  if minHeightMaxAngle>0 then minHeightMaxAngle := -32;
        if maxHeightMaxAngle>0 then maxHeightMaxAngle := -32;
:47     angleZ := -Lerp(minHeightMaxAngle, maxHeightMaxAngle,
                        Clamp((height-minHeight)/(maxHeight-minHeight), 0, 1));
:51-52  dz := 0.1; VectorRotateX(dx, dy, dz, angleZ);
:54-57  angleX := VectorAngle(0,0,1, dx,0,dz);
        dstX := tx; dstZ := tz + ArcTan(-angleZ)*oldHeight;
        VectorRotateY(dstX, tmp, dstZ, angleX);
:60,64  offZ := ArcTan(angleZ)*height; VectorRotateY(offX, tmp, offZ, angleX);
:66-67  newx := dstX + offX + dx;  newy := dstZ + offZ + dz;
:68-78  if VectorDistance(cx,cy,cz, newx,height+dy,newy) > 0.1 then
          CameraInfoSaveWithProperties(...); CameraInfoLoadToCurrentView(...);
          SetCameraDepthOfView(dov);
:296    wheelDelta := -(GetGUIEventMouseWheelDelta/60)*(gProfile.wheelspeed*0.5+0.25)*2;
:298-302 ZoomCamera(0,wheelDelta,newx,newy,True);
          SetCameraElasticTargetObject(0);
          SetMainCameraRotateToTargetDir(false);
          SetMainCameraMoveToTargetXZ(newx, newy);
```

With the shipped config (E8): `minHeight = SphereLengthMin = 20`,
`maxHeight = SphereLength = 58` (the commented-out block at `:23-29` explicitly reads
`SphereLengthMin`/`SphereLength`, proving which RestrictInfo pair the wheel uses), and
all four angle keys are `-32`, so the `:43-46` guards are no-ops and
`angleZ = -(-32) = +32°` is **constant for every zoom level**. With default
`wheelspeed=0.5` (E16) the wheel factor simplifies to `wheelDelta = -(Δ/60)`, i.e.
2 metres per standard `Δ=120` notch (sign convention of `GetGUIEventMouseWheelDelta`
not read). Focal `±5` at `:326,334` is the `gbool_gui_screenshotcamera` + CTRL
branch only, not main-view zoom.

### 3.2 Camera geometry / tilt — PROVEN data + INFERRED interpretation

`data\cameras\default.cameras:5-18` gives Camera0 target `(TargetY=49, TargetZ=78.42125)`
and `FocalLength=400`, `:11-15` `DirZ=-1, UpY=1`. Ratio
`78.42125 / 49 = 1.60043`, versus `cot(32°) = 1/tan(32°) = 1.60033` (0.006% apart).
That is the same geometry the port already implements in
`variant3d/scripts/camera3d.gd:200-203` (`back = h·cos(pitch)/(-sin(pitch)) =
h/tan(32°)`). INF: the donor's `ArcTan(angleZ)` in `onmousewheel.inc:56,60` is the
script-side height→back-offset operator (numerically consistent with cot/tan for
`angleZ=+32`), but its exact VM implementation is UNVERIFIED; do not rename it.
The camera record's `height=49` matches the **commented** `SphereHeight=49` at
`camera.cfg:5,8`, not the shipped 58 — `default.cameras` is likely an older/default
record, while `camera.cfg` is the live gameplay config (INF).

### 3.3 Pan / edge scroll — PROVEN

`oncamera.inc` (E11): `keySpeed = keyscrollspeed*4`, `mouseSpeed = mousescrollspeed*4`
(defaults 0.5 → **2.0** both); `Left/Right/Up/Down` via `IsKeyDownByName` (`:18-21`),
`SetCameraElasticMoveFactor(speed)` (`:29`), directions from
`GetCameraAbsolute{Left,Right,Forward,Backward}Direction` summed into
`(fcx,fcy,fcz)` (`:60-65`) and fed to `SetCameraElasticMoveDirection` (`:72`);
`SetCameraElasticMoveTurnOff` on tag 30 with no direction (`:76`). Corner tags 20–27
map to two-direction combinations (`:37-58`). Edge bands `8`/`24` and tags come from
`cameracontrol.inc:20-35` (E12). The speed is **additive and zoom-independent** in
donor text; the port's `/zoom` factor is a 2D-heritage choice, not donor.

Middle drag (E15): `deltaX = ((prevX-curX)/60)*(0.5+middlemousescrollspeed)`,
`deltaY = ((prevY-curY)/45)*(0.5+middlemousescrollspeed)` (defaults: divisor 60/45,
factor 1.0), applied additively to target and camera position, with X clamped to
`GetCameraElasticRestrict` bounds and Z clamp commented out (`:23-50`).

### 3.4 Minimap jump — PROVEN at the call site, helper body UNVERIFIED

`eventminimap.inc:8-35` (E13) routes minimap LMB down/repeat/up into `OnMouseDown`
with tags 10/20/30. `onmousedown.inc:116-131` (E14) then issues:
`SetCameraElasticTargetObject(0)` → `_control_GetMoveCameraToPositionOffset(x,y,newx,newy)`
→ `SetMainCameraRotateToTargetDir(false)` → `SetMainCameraMoveToTargetXZ(newx,newy)`;
double-click uses `_control_MoveCameraToPosition(x,y,0,False)` instead. The offset
helper's body is absent from all read donor text and from the binary (E26), so the
pixel→world conversion is UNVERIFIED. Donor text for `GetCameraPositionExt`
(`onmousewheel.inc:82-104`) does expose an older minimap-camera formula:
`koef=(ty-20)/(49+tarY)` with `tarY:=0`, `offsetZmin=28.565`, `offsetZmax=78.42125`,
`koef:=Lerp(0,1.6897,koef)`, `offsetZ:=Lerp(offsetZmin,offsetZmax,koef)`,
`x:=tx`, `y:=tz-offsetZ` — literal donor constants worth preserving in any port note.

## 4. Functions referencing the camera keys (addresses + what is provable)

| Token / key | Whole-file CODE hits | Containing function / provable role |
|---|---|---|
| `MinHeightMaxAngle` | `0x7abe78` (1 hit, E18) | `sub_7ab704` only: read as f32 default **80.0** → object `+0x250`. |
| `MaxHeightMinAngle` | `0x7abe94` (1 hit, E18) | `sub_7ab704` only: read as f32 default **-60.0** → object `+0x254`. |
| `MinHeightMinAngle` / `MaxHeightMaxAngle` | `0x7abe5c` / `0x7abeb0` | `sub_7ab704`: defaults -20.0 / 40.0 → `+0x24c` / `+0x258`. |
| `SphereHeight` | `0x7abc44` | `sub_7ab704`: default 10.0 → `+0x204` (cfg 58). |
| `SphereHeightMin` | `0x7abc5c` | `sub_7ab704`: default 0.5 → `+0x208` (cfg 20). |
| `FocalLength` (16 hits, E17) | `0x7abf6b`, `0x7abf83`, `0x7abf98` | substrings of `MinFocalLength`, `MaxFocalLength`, `FocalLengthPower` keys inside `sub_7ab704`. |
| `FocalLength` | `0x7aadb0`, `0x7ab32c` | **false functions** (E22): `default.cameras` descriptor schema keys (`UpX/UpY/UpZ/FocalLength/DepthOfView/…`); lifter output is garbage. The surrounding loader is `sub_7aadb0`/its neighbours (uses `sub_8959b0`, `sub_895d5c`, `sub_896b1c`, `sub_8967b4`). |
| `FocalLength` | `0x5fe19e`, `0x5fe1da`, `0x5fea67`, `0x5fead3`, `0x5fecfc`, `0x5fed5b` | all inside `sub_5fc2d0` (2,698 blocks / 5,583 instructions, 7 direct calls, 0 callers): a script-API **signature/registration** table. Neighbours: `GetCameraDynamicFocalLength() : Boolean`, `SetCameraDynamicFocalLength`, `SetCameraFocalLengthInfo`, `CameraInfoReadDepthOfView`. These are declarations, not camera math. |
| `FocalLength` | `0x4c851e`, `0x58c14b`, `0x58e1ac`, `0x5d5d54`, `0x7e99db` | `native_function_find`: "not inside any discovered function" → UNVERIFIED consumers. |
| `keyscrollspeed`, `mousescrollspeed`, `ZoomCamera` | 0 hits (E19) | script-level only; no native function can be tied to them. Their effects are proven from `oncamera.inc:10-11`, `onmousewheel.inc:296`. |
| wheel/move APIs | `0x5fc40e` `SetCameraControlMouseWheelDistance`; `0x673a06` `GetGUIEventMouseWheelDelta`; `0x5fc902` `SetMainCameraMoveToTargetXZ`; `0x5fe772` `GetCameraRestrictInfo`; `0x5fe956` `GetCameraFreeRotationInfo`; `0x5fdafe` `CameraInfoReadProperties`; `0x5fca32` `GetCameraAbsoluteLeftDirection`; `0x5fccda` `SetCameraElasticMoveDirection`; `0x5fe37e` `SetCameraDepthOfView` (E20/E23) | compiled script-API names; consumers are the script VM, not a recoverable native call graph. `core_feature_find` sees none of them (E21). |

Also proven: `sub_7ab704` has exactly one caller `sub_7aea0c` (`native_api_show`,
E5; pseudo-C E6), and `sub_7ab704` itself makes **no** system/library API calls — it is
a pure config→object loader, not a per-frame camera updater. The elastic per-frame
update loop (`MoveVelocity`, `StepTime*`, `SphereLength` consumers) was NOT identified.

## 5. PROVEN vs INFERRED reconstruction

**PROVEN (direct read / lifter-confirmed):**
- 49 keys, their addresses, binary defaults, types and destination fields (E2–E4).
- `camera.cfg` shipped values (E8), including 58/20 bounds, -32 tilt, focal 400, DynFogDepth False.
- Wheel height clamp to `[SphereLengthMin, SphereLength]` and constant `angleZ=+32` (E10).
- Wheel delta formula and default profile speeds 0.5 (E10, E16).
- Key/middle-drag pan formulas and edge bands (E11, E12, E15).
- Minimap LMB routing to `SetMainCameraMoveToTargetXZ` (E13, E14).
- Camera0 target/geometry and `DirZ=-1, UpY=1` (E9).
- Script API token locations and the `core_feature_find` blind spot (E17–E23).

**INFERRED (best explanation, not provable from static data):**
- `ArcTan(angleZ)` ≈ height→back-offset operator; numerics agree with `cot(32°)`, VM implementation unknown.
- `default.cameras` Camera0 is an older/default record; `camera.cfg` is the live gameplay config (49 vs 58).
- Final `sub_4a6e64`/`sub_4ce8bc` pair is the focal/projection update.
- Donor main view is perspective (no ortho key); port's `FOV_DEG_ASSUMED`, yaw 0 and near/far planes remain port assumptions (consistent with AUDIT3D-05 §6 Q1/Q2).
- The 5 undiscovered-function FocalLength hits and the RTTI `.rsrc` camera classes have no proven code consumer.

## 6. Implications for `variant3d/scripts/camera3d.gd` (audit only — do NOT implement)

Each item states the current port line(s) and the donor-grounded change that **would**
be justified by the evidence above. No file was edited.

1. **Zoom state should be height, not a 2D zoom scalar.** Current
   `camera3d.gd:163-165` (`height = sqrt(H_MIN*H_MAX/zoom)`) maps the 2D interval onto
   20–58; donor instead stores `height` directly and clamps it (E10). Add an explicit
   height state, clamp to `SphereLengthMin=20 … SphereLength=58` (`camera.cfg:9-10`),
   and derive the 2D zoom only for legacy callers. Use the **Length** pair, not
   `SphereHeight` (they coincide only because both are 58/20 in the shipped cfg).
2. **Wheel step.** Replace `zoom_step_factor^(notches*zoom_notch_gain)` (`:70-71,487`)
   with `delta = -(wheel_event_delta/60)*(wheelspeed*0.5+0.25)*2`, default
   `wheelspeed=0.5` → 2 m per `Δ=120` notch, and clamp (E10 `:296`, E16). Keep the
   sign convention configurable until the VM's delta convention is checked.
3. **Zoom anchor.** In `_smooth_zoom()` (`:504-538`) donor uses `oldHeight` for the
   target-plane shift and `height` for the camera offset (E10 `:56,60`); the current
   code re-hits at a single sampled height. Mirror the old/new-height distinction in
   the anchor correction rather than adding another invented constant.
4. **Tilt is already donor-grounded.** `Data.CAMERA_PITCH=-32` used at `:199-203` is
   correct for the shipped config; document that donor stores -32 in all four angle
   fields and internally negates to `+32°` (E8, E10 `:43-47`). `MinHeightMinAngle`/
   `MaxHeightMinAngle` do not drive wheel tilt and need no port equivalent.
5. **Pan is additive and zoom-independent.** `_process()` at `:474-477` divides by
   `zoom`; donor sets `speed=profile*4` (default 2.0) and moves along camera absolute
   directions with no zoom factor (E11). Remove `/zoom` and, if using world-axis pan,
   derive axes from a fixed -32° tilt rather than the 2D canvas.
6. **Middle-drag divisors.** `:398-405` uses `md/(zoom*view_scale)` with a fixed
   16 px/m. Donor uses `Δx/60` and `Δy/45` times `(0.5+middlemousescrollspeed)`
   (default factor 1.0), with X clamped by `GetCameraElasticRestrict` (E15). Adopt the
   60/45 asymmetric divisors if exact drag feel is in scope; `clamp_pos()` (`:356-387`)
   already supplies the map clamp.
7. **Edge bands / corner tags are correct.** `:89-90` (`8`, `24`) and `:412-455`
   match `cameracontrol.inc:20-35`; no change.
8. **Minimap jump semantics.** `jump_to_world()` (`:341-350`) already sets target +
   transform + memo and cancels the zoom anchor, matching donor
   `SetMainCameraMoveToTargetXZ` direction. Donor additionally clears the elastic
   target and disables rotate-to-target (`onmousedown.inc:126-130`); if the port later
   adds such states, clear them in the same call. Do **not** apply `view_scale` (E14).
9. **Focal / FOV.** Keep `DONOR_FOCAL=400` (`:46`) as a documented config value from
   `camera.cfg:44-45` / `default.cameras:17`, but do **not** derive FOV from it:
   neither sensor nor projection matrix is readable. `FOV_DEG_ASSUMED=17.27` (`:51`)
   remains an assumption. If config parity is wanted, expose `Min/MaxFocalLength` and
   `FocalLengthPower` (binary default 0.5, cfg 1.0) as fields, not a new FOV number.
10. **Elastic smoothing / fog.** If elastic camera motion is implemented, the donor
    values are `MoveVelocity=0.125`, `IntervalTime=10`, and
    `StepTimeMove=StepTimeMoveAccel=StepTimeMoveDecel=0.00001`,
    `StepTimeMoveDirection=1`, `StepTimeCameraDistance=0.005` (`camera.cfg:14-27`, E8).
    `DynFogDepth=False` (`camera.cfg:59`, E8) means gameplay fog is not depth-driven;
    do not add donor "depth fog" on the strength of the `DynFog*` keys alone.

## 7. UNVERIFIED / BLOCKED

- Exact `ArcTan()` VM implementation and units (degrees vs radians); the `cot(32°)`
  match is numeric corroboration only.
- Donor projection/sensor/FOV and near/far planes: no key, no readable projection code.
  Port FOV 17.27° and 2.90° are A/B assumptions, not donor literals.
- The elastic per-frame update loop consuming fields `+0x204`…`+0x268` was not found;
  88 of `sub_7ab704`'s instructions are `__asm(...)` in the clean-room lifter.
- 5 of 16 `FocalLength` CODE hits are in undiscovered functions (no consumer proven).
- `_control_GetMoveCameraToPositionOffset` body absent → exact minimap pixel→world
  offset formula UNVERIFIED (E26); the older `GetCameraPositionExt` formula is only a
  hint (§3.4).
- `GetCameraRestrictInfo` outputs `lx,rx,fy,by` are not among the keys `sub_7ab704`
  reads from `camera.cfg`; their source is UNVERIFIED.
- `keyscrollspeed`/`mousescrollspeed`/`wheelspeed` are script/profile fields; no native
  function is statically attributable (E19).
- `core_feature_find` cannot see CODE-resident tokens (E21) — a tool limitation, not
  evidence of absence.
- No runtime/Frida, no donor unpacking and no visual A/B were performed (charter).

## 8. Next atomic tasks (suggestions, not performed)

1. Recover the elastic camera update loop: from `sub_7ac1f4`/`sub_7ae2a4`/
   `sub_7af50c` follow reads of object fields `+0x204`, `+0x20c`, `+0x214`, `+0x218`
   and report how `MoveVelocity`/`StepTime*` drive per-frame motion.
2. Identify the engine function implementing `GetCameraRestrictInfo` by following
   references to its signature at CODE `0x5fe772`; confirms which object fields map to
   `maxHeight/minHeight` and where `lx,rx,fy,by` come from.
3. Locate the `_control_GetMoveCameraToPositionOffset` script body (likely a packed
   script resource, not `data/**/*.inc`) to make the minimap-jump formula provable.
4. A/B calibrate port FOV against `FocalLength=400` with donor screenshots (would
   require explicit consent-gated runtime capture; out of scope for this audit).
5. Extend the 49-key loader table to the other camera sub-descriptors
   (`0x7aadb0` schema) to prove how `default.cameras` records are consumed.

## 9. Top 10 evidence-cited findings

1. **`sub_7ab704` is a pure 49-key config loader**, 9 blocks / 335 instructions / 57
   internal calls / 0 APIs, one caller `sub_7aea0c` — E1 `ev_e57a21ab…`, E5
   `ev_8632ea91…`, E6 `ev_923812f5…`.
2. **All 49 keys, defaults and typed fields decoded**, including 43 float reads,
   1 int (`IntervalTime` 500) and 5 bool reads — E2 `ev_49ae2873…`, E3
   `ev_fd4311b1…`, E4 `ev_1b05e16d…`.
3. **Shipped camera.cfg overrides the binary fallbacks**: 58/20 height bounds, four
   `-32` tilt angles, focal 400, `DynFogDepth=False` — E8 `ev_f24c1aa1…`.
4. **Wheel zoom clamps height to `SphereLength[Min]` 20–58 and tilt is constant**:
   `angleZ=-Lerp(-32,-32,t)=+32` for shipped config — E10 `ev_0212f2f7…`, E8.
5. **Wheel delta is additive**: `-(Δ/60)*(wheelspeed*0.5+0.25)*2`, default 0.5 →
   2 m per 120Δ notch; main-view focal ±5 is screenshot-mode only — E10, E16
   `ev_992ea3e2…`.
6. **Pan speeds are `profile*4` (default 2.0), zoom-independent; middle-drag is
   `Δx/60`, `Δy/45` times `(0.5+middlemousescrollspeed)`** — E11 `ev_da1e62c8…`,
   E15 `ev_0cc3781c…`, E16.
7. **Donor camera geometry matches the port's back-offset formula**: Camera0
   `(49, 78.42125)` → ratio 1.60043 ≈ `cot(32°)=1.60033` — E9 `ev_ea5be18a…`
   (numeric match = INFERRED interpretation).
8. **Minimap LMB ends in `SetMainCameraMoveToTargetXZ`** after clearing elastic target
   and rotate-to-target; helper body not found — E13 `ev_1d437772…`, E14
   `onmousedown.inc:116-131`, E26 `ev_b3ce43e7…`.
9. **`core_feature_find` is blind to CODE-resident camera tokens while whole-file
   `native_bytes_find` finds all 16 `FocalLength` hits and both angle keys** — E17
   `ev_7a8cf1b5…`, E18 `ev_31962e76…`/`ev_1166f626…`, E21 `ev_0eb1f638…`.
10. **Two "functions" at `0x7aadb0`/`0x7ab32c` are false positives** — they are
    `default.cameras` schema-string data; six other `FocalLength` hits are script-API
    signature strings in `sub_5fc2d0`, five are in undiscovered code (UNVERIFIED) —
    E22 `ev_2ab20e9c…`/`ev_f00f0c29…`, E23 `ev_6d27ae38…`.

---

**End of report. No donor binary/text was modified; no repository source, git state or
runtime was touched. Exactly one report file was written.**
