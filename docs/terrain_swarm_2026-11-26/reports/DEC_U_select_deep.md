---
id: DEC-U-SELECT-DEEP
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-SELECT-DEEP — deep static probe: FOV/sensor law, projection args, drag-anchor struct, marquee inside-test"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_select_deep.md
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_ASSET_CONFIG_GODOT_GIT_EDIT
created: 2026-11-26
labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
parity_guard: "NO DONOR PARITY IS CLAIMED. No same-camera donor/port A/B frame was produced or examined. Every donor statement is a read-only byte/line observation with VA/file-off or path:line. No FOV/sensor/near/far/anchor value is written as donor fact."
scope_guard: "Exactly one repo file written (this report). No source, shader, config, asset, fixture, test, runner, GodOT, git or user-mod edit. Donor binary and donor data tree read READ-ONLY; donor executable never run, no donor bytes copied. Singleplayer skirmish only."
donor_pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE x86, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c, Deep mode. Every native call passed document=t_87f0f3c130b0 explicitly."
prior_reports_read:
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_gl_perspective.md (custom glFrustum/glOrtho via sub_4cd334, gluPerspective thunk 0x907b84 0 refs, GetCameraFieldOfView @0x5fece6 string-table blob)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_selection.md (pick gate/priority order recovered; V1-SENSOR/V2-PROJ/DRAG/BOX left [U])
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_blend_deep.md (method reference: raw CODE byte search over data-section index limits)
---

# DEC-U-SELECT-DEEP — FOV law, projection args, drag-anchor, marquee inside-test (donor 1:1)

> READ-ONLY. No parity claim. No approximation endorsed.
> `[O]` = observed donor bytes/lines, verified by a second read in this ticket. `[D]` = deterministic reading over cited `[O]`. `[I]` = reading without runtime proof. `[U]` = unresolved after the passes here.
> `ev_*` = Craft Anything evidence ids from NEW passes in **this** session, all pinned `document=t_87f0f3c130b0` unless the subject is a donor text path. "Address" = donor VA `0x…`; file-off = `0x…` file offset.

## 0. Method, labels, pass ledger (multiple NEW passes on the pin)

`native_bytes_find` searches file bytes as stored (packed `.bind` + runtime-built data invisible — 0 hits is never proof of absence); `native_strings_find` searches data sections only (CODE-embedded tables invisible to it — same limit exploited in DEC_U_blend_deep). `native_xrefs_list` is static-references-only (computed-pointer/script-VM dispatch invisible). All three limits are printed on every evidence record and are cited, never worked around.

| Pass | Operation (read-only, `document=t_87f0f3c130b0`) | Evidence | Result |
|---|---|---|---|
| P1 | `native_bytes_find` `GetCameraFieldOfView` | `ev_3598d0fb…` | 1 hit: VA `0x5fece6`, file-off `0x1fe0e6`, CODE (re-find of prior `ev_5273d228…`, same VA) |
| P2 | `native_bytes_find` `MinFocalLength` | `ev_f46cce1e…` | 1 hit: VA `0x7abf68`, file-off `0x3ab368`, CODE (same VA as prior `ev_3ca11397…`) |
| P3 | `native_bytes_find` `ScreenToWorld` | `ev_59c0e2dc…` **NEW** | 1 hit: VA `0x69e45a`, file-off `0x29d85a`, CODE |
| P4 | `native_bytes_find` `GetCurrentMouseWorldCoord` | `ev_3f19d659…` **NEW** | 1 hit: VA `0x66daa2`, file-off `0x26cea2`, CODE |
| P5 | `native_bytes_find` `FOVSensor` | `ev_70ca60bd…` **NEW** | 0 hits (file-bytes-only limit; absence is not proof) |
| P6 | `native_bytes_find` `ProjectionMatrix` | `ev_834975ec…` **NEW** | 1 hit: VA `0x85511c`, file-off `0x45451c`, CODE |
| P7 | `native_bytes_find` `Projection` | `ev_e73b06e4…` | 1 hit: same VA `0x85511c` (overlap; confirms single occurrence) |
| P8 | `native_bytes_find` `FocalLength` | `ev_7a8cf1b5…` **NEW re-find** | 16 hits, all CODE (`0x4c851e/0x58c14b/0x58e1ac/0x5d5d54/0x5fe19e/0x5fe1da/0x5fea67/0x5fead3/0x5fecfc/0x5fed5b/0x7aadb0/0x7ab32c/0x7abf6b/0x7abf83/0x7abf98/0x7e99db`) — same 16-set as prior `ev_99e2a779…` |
| P9 | `native_bytes_show` `0x5fece6` +128 / +512 | `ev_b17e889d…` / `ev_bec18fb4…` **NEW windows** | Full signatures: `GetCameraFieldOfViewByFocalLength(const focallength, viewportdimension : Float) : Float` + inverse `GetCameraFocalLengthByFieldOfView(const fieldofview, viewportdimension : Float) : Float` (§1) |
| P10 | `native_bytes_show` `0x69e45a` +256; `0x69e433` +256 | `ev_fa82ce48…` / `ev_c9172eb6…` **NEW** | `ScreenToWorldRayCast(ascreenx, ascreeny: Integer; var arayx, arayy, arayz: Float)` + `MouseRay: Integer` neighbour + `GameObjectSortRayCastList` (§4) |
| P11 | `native_bytes_show` `0x66daa2` +256/+512 | `ev_ff81038f…` / `ev_14745506…` **NEW** | `GetCurrentMouseWorldCoord(var arayx, arayy, arayz: Float)` + GUI neighbours (no numeric law) |
| P12 | `native_bytes_show` `0x85511c` +256 | `ev_3002bd99…` **NEW** | `ProjectionMatrix*P;` GLSL fog-shader text (`fogFragCoord = abs(gl_Position.z)` / `length(gl_Position)` ATI branches), NOT a script API |
| P13 | `native_bytes_show` `0x7abf68` +256 | `ev_ea91c02e…` **NEW window** | `MinFocalLength … MaxFocalLength … FocalLengthPower … FreeRotationMode … ElasticTargetRaycastMode … ElasticCameraRaycastMode … PowerDOF … MinLengthDOF … MaxLengthDOF … MinNearDOF …` property run |
| P14 | `native_bytes_find` `ByFocalLength` | `ev_86a5c6f4…` | 1 hit `0x5fecfa` (+`0x14` past P1; tail of the P9 signature) |
| P15 | `native_bytes_find` `GetCameraFocalLengthByFieldOfView` | `ev_cc24f391…` **NEW** | 1 hit VA `0x5fed52`, file-off `0x1fe152`, CODE (the inverse entry) |
| P16 | `native_bytes_find` `NearPlane` | `ev_d881a79f…` | 2 hits CODE `0x4c8590/0x4c85be` (same as prior P22) |
| P17 | `native_bytes_show` `0x4c8590` +256 | `ev_68cdbf61…` **NEW window** | `NearPlaneBias … DirectNearPlaneBias … TargetObject … CameraStyle … OnCustomPerspective … OnCustomApply … Positio…` (bias property block, no values) |
| P18 | `native_bytes_find` `FarPlane` | `ev_1716e536…` **NEW** | 0 hits (same limit as P5) |
| P19 | `native_bytes_find` `DepthOfView` | `ev_b139c84c…` **NEW re-find** | 8 hits CODE (`0x4c84cc/0x4c84f8/0x5fe2b0/0x5fe301/0x5fe353/0x5fe387/0x7aadc4/0x7ab340`) |
| P20 | `native_bytes_show` `0x4c84cc` +256 | `ev_4fb3dcd0…` **NEW window** | `DepthOfView … DirectDepthOfView … FocalLength … SceneScaleX … SceneScaleY … NearPlaneBias … DirectNearPlaneBias …` (camera property block) |
| P21 | `native_bytes_find` `GetViewerWidth` | `ev_22c4a016…` **NEW** | 1 hit VA `0x69dd5e`, CODE |
| P22 | `native_bytes_show` `0x69dd5e` +256 | `ev_e93fc7d4…` **NEW** | `GetViewerWidth(): Integer … GetViewerHeight(): Integer … GetProjectMode(): String … GetProjectModeInt … SetProjectMode …` |
| P23 | `native_bytes_find` `Aspect` | `ev_aa704dba…` **NEW re-find** | 9 hits CODE (`0x50ce30/0x50d47c/0x5a4c71/0x5a5564/0x6db810/0x6db868/0x87436c/0x874933/0x88878f`) |
| P24 | `native_bytes_show` `0x50ce30` +128 | `ev_b9352bd3…` **NEW** | `AspectRatio … Rotation … Friction … BlendingMode …` (particle/material props, not camera) |
| P25 | `native_bytes_show` `0x87436c` +256 | `ev_c17f6a02…` **NEW** | `Aspect … lnaInvisible/lnaAxes/lnaCube … TLineSplineMode … lsmLines/lsmCubicSpline/…` (spline/object props, not camera) |
| P26 | `native_bytes_find` `Sensor` | `ev_361934c5…` **NEW** | 0 hits (same limit) |
| P27 | `native_bytes_show` `0x4cd780` +32 | `ev_07143cf6…` **NEW window** | `00 00 C8 42 (=100.0f) | 00 00 00 40 (=2.0f) | 33 33 33 33 33…` table head (same floats as prior P35) |
| P28 | `native_data_show` `0x8f4dec` | `ev_50092d6f…` | `0x38d1b717` = `0.0001f`, DATA, 2 refs (observed only, §2) |
| P29 | `native_function_pseudocode sub_4cd334` | `ev_030dff8c…` | 114-line Ghidra `FUN_004cd334(p1,p2,w,focalArg,p5,h)`; mode byte `*(p1+200)`; bounds via `max(w,h)` + `focalScale`; `glFrustum/glOrtho/glMultMatrixf/gluOrtho2D` (§2) |
| P30 | `native_function_callees_list sub_4cd334` | `ev_db494e86…` | 5 calls (1 unresolved indirect): `gluOrtho2D@0x4cd38c`, indirect `@0x4cd3bf`, `glMultMatrixf@0x4cd723`, `glOrtho@0x4cd771`, `glFrustum@0x4cd626` |
| P31 | `native_function_pseudocode sub_5d1c60` | `ev_6a85f244…` | 72-line `FUN_005d1c60`: `glClear → glViewport → glMatrixMode → glPushMatrix → glLoadIdentity → sub_4cd334(… w … focal … 0x60 … h) → glMatrixMode`, `w=*(p1+0x44) h=*(p1+0x48)`, refresh only when `param_2[0xf]/[0x10]` change (§2) |
| P32 | `native_function_pseudocode sub_777c80` | `ev_0f24561c…` **NEW** | 23-line wrapper: `FUN_00777cd0(param_1,param_2,param_3,0x60,iVar2)` then `FUN_004cd334(*( *param_2+0x4c),&local,local_14,(float)ST0,0x60,iVar2)` — second caller also passes `p5=0x60` (§2) |
| P33 | `native_xrefs_list 0x4cd334` | `ev_90877626…` | 2 callers: `sub_5d1c60 @ 0x5d1ddb`, `sub_777c80 @ 0x777cc1` |
| P34 | `native_xrefs_list 0x5fece6 / 0x69e45a / 0x66daa2 / 0x85511c` | `ev_4a019653…` / `ev_72852ae3…` / `ev_49bb2069…` / `ev_ecaf885e…` **NEW** | 0 static refs each (computed-pointer/script-VM limit; never read as "uncalled") |
| P35 | `native_xrefs_list 0x7abf68` | `ev_4f07a0b1…` | 1 static data ref: `0x7aba11` in `sub_7ab704` (same as prior `ev_6b9e9436…`) |
| P36 | `native_bytes_find` `glFrustum` + `native_name_xrefs_list glFrustum@thunk` | `ev_c22aad85…` + `ev_7b9c6ee2…` **NEW** | `.idata` name slot `0x90aaf4` + thunk `0x4afd04` with exactly 1 caller `sub_4cd334 @ 0x4cd626` (no other static caller) |
| P37 | `native_bytes_find` `prevselmousex / prevs / isselectionstarted` | `ev_6eafe381…` / `ev_2b7104b4…` / `ev_f731c284…` **NEW** | 0 hits each — script globals live in script state, not exe bytes (expected; §3) |
| P38 | `native_bytes_find` `GameManagerBeginSelection` | `ev_f5bcd413…` | 1 hit `0x6a03fa` CODE (re-find) |
| P39 | `native_bytes_show` `0x6a03c2` +256 | `ev_aa0dddd5…` **NEW window** | `GameManagerIsSelectionMode:Boolean … BeginSelection … EndSelection … GetGameManagerPickingMode: String … GetGameManagerRestrictSelection(): boolean …` (§4) |
| P40 | `native_bytes_find` `MouseRay` / `MouseRayX` | `ev_6375113d…` / `ev_464c8268…` **NEW** | `MouseRay` 5 hits (`0x69e433/0x69e5be/0x70f64f/0x70f673/0x70f697`); `MouseRayX` 1 hit `0x70f64f` |
| P41 | `native_bytes_show` `0x69e433` +256 | `ev_c9172eb6…` **NEW** | `MouseRay: Integer … ScreenToWorldRayCast(…) … GameObjectSortRayCastList … GetGameObjectRayCastByIndex …` (§4) |
| P42 | `native_bytes_show` `0x70f64f` +256/+512 | `ev_9718bfe4…` / `ev_ae7a8d7f…` **NEW** | `MouseRayX … MouseRayY … MouseRayZ … CameraTrackList … CameraList … CameraL1 … SoundVolumes … AmbientSound … SoundManager … WasMouseDown … WasMouseUp … NeededMap …` (§3: property block, no anchor pair) |
| P43 | `native_bytes_find` `GetRayCastIntersectGameObject` | `ev_e836f957…` **NEW** | 2 hits `0x69e59d/0x69e5e5` CODE |
| P44 | `native_bytes_show` `0x69e57a` +256 | `ev_e95410af…` **NEW** | `PickedObjects() … GetRayCastIntersectGameObjectFromMouseRay(): Integer … GetRayCastIntersectGameObject(start_x…end_x…var int_x…): Integer …` (§4: full ray signatures) |
| P45 | `native_bytes_find` `GetGameObjectRayCastAABBByHandle` | `ev_b0325b2d…` | 1 hit `0x63153e` CODE (re-find) |
| P46 | `native_bytes_show` `0x63153e` +256 | `ev_a111e992…` **NEW window** | `GetGameObjectRayCastAABBByHandle(const gohnd: Integer; x1,y1,z1,x2,y2,z2: Float): Boolean` + 12-float `…CustAABBByHandle(…minx…maxz: Float): Boolean` (§4) |
| P47 | `native_bytes_find` `OctreeRayCast` | `ev_4685a40a…` | 2 hits `0x62e84a/0x62e8fa` CODE (re-find) |
| P48 | `native_bytes_show` `0x62e84a` +256 | `ev_83078fe1…` **NEW window** | `OctreeRayCastIntersect(gohandle; rs_x,rs_y,rs_z; dir_x,dir_y,dir_z; var p_x,p_y,p_z; var n_x,n_y,n_z): Boolean` + `…Children(…)` (§4) |
| P49 | `native_bytes_find` `GameObjectSortRayCastList / GameObjectRayCastCount / spmRunTime / spmAdd / Picked` | `ev_2bf9d42c…` / `ev_d833f886…` / `ev_0edab27d…` / `ev_29a985f9…` / `ev_85968a92…` | 1 (`0x69e4be`) / 1 (`0x69e535`) / 2 (`0x511e3d/0x5125c8`) / 2 (`0x511e48/0x5125dc`) / 25 hits — binding-table placement, no callers lifted |
| P50 | `native_bytes_find` `spmFrame / SelectionRect` | `ev_259ecb0a…` / `ev_3cd5a2fe…` **NEW** | 0 hits each (same file-bytes limit; §4 negative is the finding) |
| P51 | `native_bytes_find` `GameManagerIsSelectionMode` | `ev_1a0549b0…` | 1 hit `0x6a03c2` (same VA as P39 window) |
| P52 | `native_bytes_find` `GetCameraAbsolutePosition / HeightTarget / GetViewerWidth-neighbours` | `ev_30b6fc42…` / `ev_bfd77b8a…` | `GetCameraAbsolutePosition(var x,y,z: Float)` 1 hit `0x5fcbaa`; `HeightTarget: Float` 3 hits (`0x5fe02a/0x7abc14/0x7abc2c`) |
| P53 | `native_bytes_show` `0x5fcbaa` +256; `0x5fe02a` +256 | `ev_92b76b7c…` / `ev_a328c903…` **NEW** | `GetCameraAbsolutePosition / GetCameraPosition / GetCameraTargetPosition (var x,y,z: Float)` triple + `HeightTarget: Float … SetCameraPropertiesFromFile …` |
| P54 | donor text `data/gui/menu.inc/onmousemove.inc:32-34,66-70,141-167` + `onmousedown.inc:364-379` + `doupdateselection.inc:1-22` | local reads | epsilon law, world-read, two-phase anchor freeze, LButtonUp teardown, highlight-only `DoUpdateSelection` (§3) [O] |
| P55 | donor text `data/scripts/lib/control.script:170-184,288-300` | local re-read | AABB call shape `cPos→mPos` on both pick and list paths (§4) [O] |

**Strange-decomp log (required):** P34 binding-table VAs return 0 static refs under the engine's own "computed pointers at run time are not seen" limitation — localized as data, never as "dead code". `native_function_find` on `0x69e45a/0x66daa2/0x85511c/0x70f64f` reports "not inside any discovered function" (same CODE-string-table placement as prior P28) — no caller, polarity, or register law is guessed from it. `sub_5fc2d0`-region lifter output remains string-bytes garbage (prior P34, not re-litigated). `.bind` entropy `7.96` exec (prior P1) bounds every 0-hit verdict.

---

## 1. V1-SENSOR — exact FOV law inputs recovered as NATIVE SIGNATURES `[O]`; sensor width still `[U]`

### 1.1 RECOVERED — the focal↔FOV entries take TWO floats, one is the viewport dimension `[O]`

- `[O]` P9 (`ev_bec18fb4…`, 512-B window at `0x5fece6`): the entry is byte-identically
  `GetCameraFieldOfViewByFocalLength(const focallength, viewportdimension : Float) : Float`,
  immediately followed by its inverse
  `GetCameraFocalLengthByFieldOfView(const fieldofview, viewportdimension : Float) : Float`
  (P15: `ev_cc24f391…`, VA `0x5fed52`, +`0x6c` past P1). The LONG form `ByFocalLength` (P14) is the tail of the first signature, not a separate symbol family.
- `[D]` The law therefore binds THREE quantities, not two: `focal`, `viewportdimension`, and the returned angle. The second argument is **named** `viewportdimension` in the binary — it is not labelled width, height, `max(w,h)`, diagonal, or sensor. Any of those readings is `[I]` until the V1-SENSOR capture (§1.2) decides it.
- `[O]` Neighbour context (same window): `GetCameraHandle`, `GetCameraTargetHandle`, `GetCameraMouseDistanceSpeed/Set…`, `GetCameraMouseRotateFactor/Set…` — camera-handle/mouse-speed API family, no numeric law.
- `[O]` P13 (`ev_ea91c02e…`): `MinFocalLength` sits in a camera property run with `MaxFocalLength`, `FocalLengthPower`, `FreeRotationMode`, `ElasticTargetRaycastMode`, `ElasticCameraRaycastMode`, `PowerDOF`, `Min/MaxLengthDOF`, `MinNearDOF…`. Numeric 400 lives in `camera.cfg` text (upstream), never as a recovered float literal here. The single static data ref `0x7aba11` in `sub_7ab704` (P35) is a binding-table pointer, not a value read.
- `[O]` Negatives with the stated tool limit: `FOVSensor` 0 hits (P5), `Sensor` 0 hits (P26), `FarPlane` 0 hits (P18). `Aspect` 9 CODE hits (P23) are particle/spline object properties (`AspectRatio` P24, spline `Aspect` P25) — no camera aspect literal exists anywhere. `ProjectionMatrix` (P6/P12) is GLSL fog-shader text (`ProjectionMatrix*P; … fogFragCoord …`), not a script/camera API — explicitly excluded from the projection setup to prevent misuse.
- `[D]` Consequence: the thin-lens relation stays the ONLY law (upstream, `[D]`): `FOV = 2·atan(k·viewportdimension / focal)` up to an unknown scale `k` and an unknown choice of which viewport dimension feeds the second argument. Port `17.27°` (and every 216/36/121.4-unit shadow) stays `PORT APPROXIMATION`. `gluPerspective` plays no role (P36: single static caller of the thunk is `sub_4cd334`; `__imp_gluPerspective` itself has 0 static refs per prior P7, re-cited not re-derived).

### 1.2 Still-`[U]` — sensor/viewport binding (the one missing derivation)

No readable line or float literal binds focal 400 to an angle. The second signature argument could be height, width, `max(w,h)` (cf. `sub_4cd334` §2 `local_34`), or a pre-scaled sensor width — bytes do not decide.

- Capture V1-SENSOR (fixed-camera projection capture, owner-authorised, zero-mismatch criterion): fixed map seed, fixed camera target, FOW off; two surveyed markers at known world separation perpendicular to the view axis at target depth; capture frame; measure pixel separation + full frame size; solve per candidate second-argument reading (height vs width vs `max(w,h)` vs scaled width) at two depths (bracket pinhole vs engine fit-mode); cross-check vertical vs horizontal; repeat with the focal-100 debug camera as a second equation; log `GetCameraAbsolutePosition` + `GetCurrentMouseWorldCoord` for surveyed ground points as independent scale witnesses. **Termination:** predicted pixel positions of ≥5 surveyed ground points agree with captured positions to **0 px mismatch** (integer pixels, same viewport, same 58/−32/400 rig) under exactly ONE second-argument reading before any sensor/FOV literal is written as donor fact. Until then every angle stays `PORT APPROXIMATION`.

---

## 2. V2-PROJ — custom frustum in `sub_4cd334`; aspect divisor byte-proven, near/far still `[U]`

### 2.1 RECOVERED — call sites, constants, and what is NOT near/far `[O]`

- `[O]` Both callers pass `p5 = 0x60` (= 96) as a literal: `sub_5d1c60` (`ev_6a85f244…`: `FUN_004cd334(…w…, …focal…, 0x60, …h…)`, `w = *(p1+0x44)`, `h = *(p1+0x48)`, refreshed only when `param_2[0xf]/[0x10]` change = window-size driven) and `sub_777c80` (`ev_0f24561c…` **NEW**: `FUN_00777cd0(…,0x60,…)` then `FUN_004cd334(…,0x60,…)`). Xrefs confirm exactly these 2 callers (P33 `ev_90877626…`: `0x5d1ddb`, `0x777cc1`).
- `[O]` `focalArg` at both sites is a runtime struct float (`*( *( *param_2+0x4c)+0xa4)` at the viewport path; `(float)ST0` at the wrapper) — never a literal. `w/h` are viewport-struct ints. `p2` is a zeroed stack pair (`uStack_18/uStack_14 = 0,0`; `local_1c/local_18 = 0,0`).
- `[O]` Callee law (`ev_030dff8c…`, re-verified): `m = local_34 = max(w,h)` — **the aspect divisor is byte-proven**: every frustum term divides by `(_DAT_004cd784 · m)` with `m = max(w,h)`, and per-axis numerators scale `w`- vs `h`-terms separately (`*(p1+0xcc)` vs `*(p1+0xd0)`). There is no single stored aspect ratio; handling is structural (viewport-driven per-axis scale).
- `[O]` Table floats at the frustum site (P27 `ev_07143cf6…`): `0x4cd780 = 100.0f`, `0x4cd784 = 2.0f` (+ `0x4cd788` continuation, `0x4cd794 = 1.0f` per prior P35). Mode-`0x04` custom-matrix path additionally uses `_DAT_008f4dec = 0.0001f` (P28, DATA, 2 refs).
- `[D]` What `p5 = 96` is NOT: the depth term `local_2c = ((p5 · *(p1+0xa0) · 2.0/(_DAT_004cd788 · m)) · *(p1+0xac) + focalArg)` consumes `p5` multiplicatively with struct floats — it is an integer count/scale input to a runtime expression, not a near or far plane literal. It is recorded as "observed constant 96 at both call sites", never as near/far. Likewise `0.0001f @ 0x8f4dec` is an observed DATA float on the mode-`0x04` custom-matrix path only — NOT the donor near plane. `100.0f/2.0f/1.0f` are observed table constants — NOT sensor/focal facts.
- `[O]` `DepthOfView` (P19/P20: 8 CODE hits; property block `DepthOfView … DirectDepthOfView … FocalLength … SceneScaleX … SceneScaleY … NearPlaneBias …`) is the far-plane candidate consumed in CODE and declared per-camera in text (`1200` gameplay), but no readable line binds it to the GL `far` parameter. `NearPlaneBias / DirectNearPlaneBias` exist as property names (P17); `FarPlane` has 0 hits (P18). No near/far NUMERIC literal is recovered anywhere.

### 2.2 Still-`[U]` — numeric near/far + struct-field bindings

- Capture V2-PROJ-NF (GL trace + runtime, owner-authorised, zero-mismatch criterion): instrumented frame with surveyed camera target + 58/−32/400 rig; fixed viewport; log `GetCameraAbsolutePosition` + `GetCurrentMouseWorldCoord` for surveyed ground points; fit projection (focal scale, principal point, pitch order, `HeightTarget` handling); cross-check `DepthOfView=1200` as far-plane hypothesis by pushing a marker to 1199/1201 and observing clip vs render; bracket near by pushing geometry toward the eye until clip. **Termination:** fitted matrix re-projects ≥5 surveyed world points to captured pixels with **0 px mismatch** AND predicts the clip boundary (near + far) exactly before any (near, far) literal is written as donor fact.
- Capture V2-PROJ-ASPECT (runtime, owner-authorised, zero-mismatch criterion): fixed rig 58/−32/400; SAME surveyed scene at ≥3 viewport aspect ratios (e.g. 4:3, 16:9, 21:9 with identical height); fit per-axis focal scale + principal point from `GetCameraAbsolutePosition`/`GetCurrentMouseWorldCoord` logs. **Termination:** one fitted matrix family re-projects ≥5 surveyed points at EVERY probed aspect with **0 px mismatch** before any aspect/focal-scale literal is written as donor fact.

---

## 3. DRAG — anchor struct hunt `[O]` (negative is the finding); geometric anchor still `[U]`

### 3.1 RECOVERED — there is no native drag-anchor field; the anchor lives in script state `[O]`

- `[O]` P42 (`ev_9718bfe4…` + `ev_ae7a8d7f…`, 512-B window at `0x70f64f`): `MouseRayX … MouseRayY … MouseRayZ` sit in a global/GUI property block with `CameraTrackList … CameraList … CameraL1 … SoundVolumes … AmbientSound … SoundManager … WasMouseDown … WasMouseUp … NeededMap …`. `WasMouseDown/Up` are adjacent bools — they are press-state flags, never an (x,z) anchor pair. No `prev*`, `anchor*`, `drag*`, `start*`/`press*` coordinate pair exists in the block. `function_find`/`xrefs` on `0x70f64f` report undiscovered-region/0-refs (P42 context) — placement only, no field law guessed.
- `[O]` P37 (`ev_6eafe381…` / `ev_2b7104b4…` / `ev_f731c284…`): `prevselmousex`, `prevs*`, `isselectionstarted` have 0 exe hits — expected: they are script globals, not engine struct fields.
- `[O]` Donor script (P54, re-read this ticket): `onmousemove.inc:32-34` epsilon (`0.005`, `0.25` in attack/guard mode); `:66-70` per-move `GetCurrentMouseWorldCoord(x,y,z)`; `:142-147` two-phase start (`if not gbool_gui_isselectionstarted then { isselectionstarted:=true; gfloat_gui_prevselmousex:=x; gfloat_gui_prevselmousez:=z; }`); `:150-165` axis-wise compare `Abs(x−prevselmousex)>eps or Abs(z−prevselmousez)>eps` → `GameManagerBeginSelection` (`:154`) + Shift?`spmAdd` (`:156-157`) else `spmRunTime` (`:162`) + `DoUpdateSelection` (`:164`); `onmousedown.inc:364-379` LButtonUp teardown (`isselectionstarted:=false`, `if GameManagerIsSelectionMode then GameManagerCancelSelection`). `doupdateselection.inc:1-22` is highlight-only (`gSelectedObjects` → `gGuiUpdateHighlights`, `_gui_ForceShowUnitControl`, `_gui_UpdateHighlights`) — it performs NO rect mapping.
- `[D]` The donor freezes a WORLD-ground anchor on the first LMB-held move and compares axis-wise X/Z deltas. Which of (press-point, first-move-point) the ENGINE uses geometrically as the rect corner is not in text (the script never passes a rect), and no native anchor field exists to decide it → `[U]` below. The port dual-model mirrors `:141-152` faithfully; it is not a donor geometry claim.

### `[U]` V2-PROJ-DRAG-open + capture

Which point the engine freezes as the rect corner (press-point vs first-move point) and whether the frozen corner is re-projected through the live camera on pan/zoom mid-drag. **Capture V2-PROJ-DRAG** (fixed rig, owner-authorised): LMB press at surveyed pixel, hold, step 1–3 px across the epsilon boundary in each axis; log `GetCurrentMouseWorldCoord` at press vs first-move vs each step + `GameManagerIsSelectionMode` onset frame. **Termination:** onset frame + frozen rect corner match ONE of (press-point, first-move-point) with **0 px / 0.0 m mismatch** on all four drag directions before the port collapses the dual model.

---

## 4. BOX — marquee inside-test: world-segment law `[O]`; rect→world mapping still `[U]`

### 4.1 RECOVERED — native call signatures prove the pick path tests WORLD segments against AABBs, not screen rects `[O]`

- `[O]` P46 (`ev_a111e992…`, 256-B window at `0x63153e`): full prototypes —
  `GetGameObjectRayCastAABBByHandle(const gohnd: Integer; x1, y1, z1, x2, y2, z2: Float): Boolean`
  and the 12-float custom form
  `GetGameObjectRayCastCustAABBByHandle(const hnd: Integer; x1…z2, minx…maxz: Float): Boolean`.
  Boolean return, two world points + handle: a segment-vs-volume predicate, not a screen-rect predicate.
- `[O]` Script call shape (P55, re-read): `control.script:184` (pick) and `:300` (list) both call `…AABBByHandle(goHnd, cPos.x,cPos.y,cPos.z, mPos.x,mPos.y,mPos.z)` where P52/P53 pin `cPos := GetCameraAbsolutePosition` (`0x5fcbaa`: `var x,y,z: Float` triple with `GetCameraPosition`/`GetCameraTargetPosition`) and `mpos := GetCurrentMouseWorldCoord` (P11). The tested segment is camera-point → ground-point in world space. The inside-test (slab vs OBB, expansion by selection size, water/bridge handling) remains engine-side, but its DOMAIN (world segment vs world AABB) is byte-proven.
- `[O]` P44 (`ev_e95410af…`): `GetRayCastIntersectGameObjectFromMouseRay(): Integer` (screen→ray entry) + `GetRayCastIntersectGameObject(start_x…end_x…var int_x…): Integer` (world segment → hit handle). P48 (`ev_83078fe1…`): `OctreeRayCastIntersect(gohandle; rs,dir; var p; var n): Boolean` + `…Children(…)` — ray origin + direction + hit-point + normal out-params: the broadphase is a 3-D ray cast, not a 2-D rect test. P41/P49: `MouseRay: Integer` input + `GameObjectSortRayCastList` (procedure) + `GetGameObjectRayCastByIndex/Count` complete the ray-list pipeline.
- `[O]` P39 (`ev_aa0dddd5…`, window at `0x6a03c2`): `GameManagerIsSelectionMode:Boolean … BeginSelection … EndSelection … GetGameManagerPickingMode: String … GetGameManagerRestrictSelection(): boolean …` — the marquee envelope is engine selection-mode state, never a script rect. P50 (`ev_259ecb0a…` / `ev_3cd5a2fe…`): `spmFrame` and `SelectionRect` both 0 hits — no frame/rect polling name exists in the binary (same limit as P5, but combined with the highlight-only `DoUpdateSelection` (P54) the absence of ANY script-side per-candidate loop on the drag path is itself the finding, consistent with DEC_U_selection §4.1).
- `[D]` Verdict on the asked question: the pick/list inside-test is a **world-space** segment-vs-AABB predicate (signatures + call shape byte-proven). A screen-space rectangle test appears nowhere in native signatures or script lines. What is still `[U]` is the MARQUEE rect→world mapping: how the engine converts the drag (two world points? two screen points unprojected? frustum-slab volume?) into the membership test, plus the membership rule (centroid-in vs AABB-overlap vs containment fraction, edge inclusion, building/unit/res-node membership, squad side effects).

### `[U]` V2-BOX-open + capture

Inside rule (centroid vs AABB vs fraction, edge inclusion, building vs unit vs res-node membership, squad side effects) + drag-rect world mapping. **Capture V2-BOX** (FOW off, fixed rig): grid of idle peasants at known spacing; scripted drag rects inset/outset by 1–3 px around known units, both drag directions; log `GetCountGameManagerPickedObjects` (`0x6a7cda`, P49) membership per rect + `GetCurrentMouseWorldCoord` at rect corners. **Termination:** fitted rule predicts membership of ALL probed rects including 1-px edge cases and both drag directions with **zero membership mismatches** before any rule is written as donor fact. `SelectionRectPainter` keeps its `PORT APPROXIMATION` tag until then.

---

## 5. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | `GetCameraFieldOfViewByFocalLength(focallength, viewportdimension): Float` @ `0x5fece6` + inverse `GetCameraFocalLengthByFieldOfView(fieldofview, viewportdimension): Float` @ `0x5fed52`; second arg is named `viewportdimension`, not width/height/sensor | [O] P1/P9/P14/P15 |
| 2 | No `FOVSensor`/`Sensor`/`FarPlane` bytes; `ProjectionMatrix` @ `0x85511c` is GLSL fog-shader text, not a camera API; `Aspect` hits are particle/spline props | [O] P5/P6/P12/P18/P23–P26 |
| 3 | `MinFocalLength` @ `0x7abf68` in camera property run (`MaxFocalLength/FocalLengthPower/FreeRotation/ElasticTarget/CameraRaycast/PowerDOF/Min-MaxLengthDOF/MinNearDOF`), 1 static data ref `0x7aba11`; no numeric value recovered | [O] P2/P13/P35 |
| 4 | `sub_4cd334` mode byte `*(p1+200)` → `gluOrtho2D(02)` / script-callback `(03)` / `glFrustum(00)` / `glOrtho(01)` / `glMultMatrixf-custom(04)`; aspect divisor `m=max(w,h)` byte-proven; both callers pass literal `p5=96`, `w/h` viewport-driven, `focalArg` runtime struct float | [O] P29–P33 |
| 5 | `p5=96`, `0.0001f@0x8f4dec`, `100.0f/2.0f/1.0f` table floats are observed constants, never near/far/sensor facts; near/far numerics unrecovered (`NearPlaneBias` names only, `DepthOfView` unbound to GL `far`) | [O]/[D] P16–P20/P27/P28 |
| 6 | No native drag-anchor (x,z) field: `MouseRayX/Y/Z` block has only `WasMouseDown/Up` bools as neighbours; `prevselmousex/isselectionstarted` script-only; anchor freeze + epsilon + Begin→spmAdd/spmRunTime script-side, geometry engine-side | [O] P37/P40/P42/P54 |
| 7 | Pick/list inside-test is world segment (`cPos→mPos`) vs AABB (`: Boolean` + 12-float Cust form); ray pipeline (`FromMouseRay`, `start…end…var int`, `OctreeRayCastIntersect(rs,dir,p,n): Boolean`, SortList/ByIndex/Count); `spmFrame`/`SelectionRect` absent; `DoUpdateSelection` highlight-only | [O] P39/P41/P43–P51/P54/P55 |
| 8 | Sensor width, FOV angle, near/far, aspect literal, drag geometric anchor, marquee rect→world mapping + membership rule | [U] V1-SENSOR/V2-PROJ-NF/V2-PROJ-ASPECT/V2-PROJ-DRAG/V2-BOX with zero-mismatch captures §§1–4 |
| 9 | Any port visual/selection equals donor behaviour | **Denied** — no same-camera donor/port A/B exists; parity UNVERIFIED |

## 6. Scope statement

Exactly one repository file was written by this worker: this report. All donor reads were read-only against pin `t_87f0f3c130b0` (every binary call with `document=` pinned; donor text tree read-only, donor binary never executed, no bytes copied) and the evidence ids above. No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod state was changed. No parity, similarity score, threshold or gate PASS is claimed. Network is out of scope.

*End of DEC-U-SELECT-DEEP.*
