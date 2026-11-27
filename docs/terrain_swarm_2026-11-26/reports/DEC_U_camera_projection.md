# DEC-U-CAMERA-PROJECTION — FOV/sensor, projection matrix, drag anchor, marquee inside-test, minimap scale/frustum (2026-11-26)

- id: DEC-U-CAMERA-PROJECTION
- worker: DEC-U-CAMERA-PROJ (subagent, full 1:1 donor port)
- date: 2026-11-26
- scope: READ-ONLY decomp. Donor binary never executed/copied. Donor text read as text only. No code/asset/config/Godot/git edit. Exactly one repo file written (this report).
- pin: `t_87f0f3c130b0` = `C:\Games\Cossacks 3\cossacks.exe`, PE32, 5,768,048 B, sha256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`, Deep mode
- upstream: `DEC_U_fog_camera_hud.md` (camera 58/−32/400, DynFog, pick priority, minimap mapping; left V1-SENSOR / V2-PROJ / V2-BOX / V2-MINI as [U]; port 17.27° is PORT APPROXIMATION)
- labels: `[O]` verbatim donor bytes/text · `[D]` deterministic reading · `[I]` inference · `[U]` UNVERIFIED (settling experiment given, never substituted) · `PORT APPROXIMATION` = port-authored substitute
- parity: NO PARITY CLAIM. No donor GPU A/B frame. No donor binary executed by this worker. Closed items rest on donor text `[O]` with file:line or on pinned native evidence ids; engine-side items stay `[U]`.
- donor read-only compliance: donor `.cfg`/`.script`/`.inc` read as text only (python `open(...,'rb')`/Get-Content, never run); native calls are `native_strings_find`/`native_bytes_find`/`native_function_find`/`core_session_show` only, all pinned `document:"t_87f0f3c130b0"`.

## 0. Pass ledger (all native passes pinned `document:"t_87f0f3c130b0"`)

| # | Pass | Result |
|---|---|---|
| P1 | `core_session_show` | active `t_87f0f3c130b0` (Deep), 608 evidence records; `editor.exe t_68474ddde43f` present, untouched |
| P2 | `native_strings_find "gluPerspective"` | **positive** `ev_dac74593036252dbada28de14fc63eb229a26a25864a8ebf21d0b807c1deb3f0` — 1 hit: VA `0x90a6b8`, `.idata`, text `gluPerspective` |
| P3 | `native_strings_find "glFrustum"` | **positive** `ev_8beb18a03e1fde6fe2f34c1bffb5edd474e61c0acc6eb217aa2476edf9ac632e` — 1 hit: VA `0x90aaf4`, `.idata` |
| P4 | `native_strings_find "glOrtho"` | **positive** `ev_9482f2e6e61f034ad3db0e2b99e3308bade2470a0e2ebb20057738a7fac6178ba` — 1 hit: VA `0x90a9c6`, `.idata` |
| P5 | `native_strings_find "GetCameraFieldOfViewByFocalLength"` | negative `ev_87773322eaf9efa85d07166b8a3ecc51682aee5afa52d1718c9f8141a25dfa69` — 0 hits (import/script-name form not resident as string; the shorter stem IS resident, see P16) |
| P6 | `native_strings_find "FieldOfView"` | negative `ev_bbf06461fe567f20ce74cff3b7a3bc3f0795287f07d05a1e3de0ce1c456` — 0 hits (data-sections only; absence is not proof) |
| P7 | `native_strings_find "FocalLength"` | negative `ev_417198f186443b42a7aa6e147b5e12dfe6e7adc68606ae339e6` — 0 hits as stored string table; the byte-level form IS resident (see P9) — engine stores these names as CODE bytes, not `.rdata` strings |
| P8 | `native_strings_find "Projection"` | negative `ev_b009500c72d64892cbd2e56d738ee2492cbb07a5cb8acfba2492d236` — 0 hits (same scope note) |
| P9 | `native_bytes_find text "FocalLength"` | **positive** `ev_1b3522c0ad523fa7284413cbf7b7a9dfac8cd29af7502e540ad8bb3b907e5d7` — 16 matches; first page file-offs `0xc791e` (VA `0x4c851e`), `0x18b54b` (VA `0x58c14b`), `0x18d5ac` (VA `0x58e1ac`), `0x1d5154` (VA `0x5d5d54`), `0x1fd59e`/`0x1fd5da`/`0x1fde67`/`0x1fded3` (VAs `0x5fe19e`/`0x5fe1da`/`0x5fea67`/`0x5fead3`), all CODE |
| P10 | `native_bytes_find text "MinFocalLength"` | **positive** `ev_3ca11397d233be425f2f2f3d42ba72b5ff7eff7a0b5c5cff4e0d97a5e42bb5b7` — 1 match: file-off `0x3ab368` (VA `0x7abf68`, CODE). Same VA as DEC-U-FOG `ev_d5c83e0d…`; independent re-find, same bytes `4d696e466f63616c4c656e677468` |
| P11 | `native_bytes_find text "DepthOfView"` | **positive** `ev_6263a9ddcd27df29df2aef8b5dfc245404f3b250daf33aaf6d0ab07fe1536188` — 8 matches (partial page of 5 shown): `0xc78cc` (VA `0x4c84cc`), `0xc78f8` (VA `0x4c84f8`), `0x1fd6b0`/`0x1fd701`/`0x1fd753` (VAs `0x5fe2b0`/`0x5fe301`/`0x5fe353`), all CODE — the `default.cameras` `DepthOfView` key is consumed in CODE |
| P12 | `native_bytes_find text "GetCameraAbsolutePosition"` | **positive** `ev_8cac6d2006e0844a50fe5cd63dc332ee2f72b45357dba2f6ea8b93edfaab9a37` — 1 match: file-off `0x1fbfaa` (VA `0x5fcbaa`, CODE). Sits inside `sub_5fc2d0` (+`0x8da`) per P22 |
| P13 | `native_bytes_find text "GetCurrentMouseWorldCoord"` | **positive** `ev_dd0d33b8310377e1ed004abcf0f317e9f4928f54495b3c566c4c3bd770a379d9` — 1 match: file-off `0x26cea2` (VA `0x66daa2`, CODE) |
| P14 | `native_bytes_find text "ScreenToWorld"` | **positive** `ev_f5797e38b4b2772f2625ca26b1a93b17c93b7cb050dff94a17468cb82240fa49` — 1 match: file-off `0x29d85a` (VA `0x69e45a`, CODE) |
| P15 | `native_bytes_find text "ArcTan"` | **positive** `ev_794ab3544c4700bdd1436fd94dbb3b96026f61919c14dd237640710627017a41` — 1 match: file-off `0x209cc6` (VA `0x60a8c6`, CODE) |
| P16 | `native_bytes_find text "GetCameraFieldOfView"` | **positive** `ev_df1bbc754fa0d6ed456c191b5394f8a5fc7d17fb6b7848a4e7569f64e7f3fafb` — 1 match: file-off `0x1fe0e6` (VA `0x5fece6`, CODE). The FOV-by-focal entry point EXISTS as a CODE string; its full script name (`…ByFocalLength`) is not resident (P5 negative is a naming-form effect, not proof of absence) |
| P17 | `native_bytes_find text "GameManagerBeginSelection"` | **positive** `ev_a1ce04b8b81c0f4cf9eab1f041e716ab5606a20bc7ac2770c45418d8a90ef2a` — 1 match: file-off `0x29f7fa` (VA `0x6a03fa`, CODE) |
| P18 | `native_bytes_find text "GetCountGameManagerPickedObjects"` | **positive** `ev_e9140e005b4f498e0d95f4f503ebdc86d0562ddc151808bfd4f83ad8baca3595` — 1 match: file-off `0x2a70da` (VA `0x6a7cda`, CODE) |
| P19 | `native_bytes_find text "GetGameObjectRayCastAABBByHandle"` | **positive** `ev_250e545907ec1fed53ab8b508e70eccd4a7ff2dcb57304e77a3b1901a277397f` — 1 match: file-off `0x23093e` (VA `0x63153e`, CODE) |
| P20 | `native_bytes_find text "GameObjectRayCastMouseRay"` | **positive** `ev_a177b7635d60dfe8b88d5cbbbec19be8834fe8d68f1167abd748847ee4843b8` — 1 match: file-off `0x29d822` (VA `0x69e422`, CODE) |
| P21 | `native_bytes_find text "GetGUIMinimapUnderMouse"` | **positive** `ev_afba27cd6e1c801e68f69bbac5b9e9a57c3bd88979fbeb43184f086eea74175f` — 1 match: file-off `0x26cf22` (VA `0x66db22`, CODE) |
| P22 | `native_function_find 0x5fcbaa` | `ev_4dcd493a08dc37906265e6603eac67ba57e9f8dab64b721546bc9bac4805a3b5` — `0x5fcbaa` inside `sub_5fc2d0` (+`0x8da`); P13/P14/P17 hits report "not inside any discovered function" (`ev_6a3151fe…`, `ev_1cdde3c7…`, `ev_a674a2b3…`) — i.e. these binding names live in a dispatch/blob region the engine did not lift as functions. Disassembly of `sub_5fc2d0` (`ev_6c96da89…`) decodes as string bytes, confirming CODE-string-table placement, not callable GL setup |
| P23 | `native_bytes_find text "glMatrixMode"/"glLoadIdentity"/"glViewport"/"gluUnProject"` | positives `ev_1daf8b7f…` (VA `0x90aa1a` `.idata`), `ev_9dbfb2c3…` (VA `0x90aa62`), `ev_1313fd2c…` (3 CODE call sites `0x4b8688/9c/b0` + `.idata` `0x90ac18`), `ev_c4c68b1a…` (VA `0x90a67e`) — GL fixed-function entry points are IMPORTED; no static projection-parameter literal is recoverable from the import names alone |
| P24 | `native_bytes_find text "glGetDoublev"` | negative `ev_0a9461d19b3a67aecc065dff4f911cf54d533113aaa690ad6984022066aca8c7` — 0 hits (import-form effect; P23 shows the surrounding GL imports exist) |
| P25 | `native_bytes_find text "spmAdd"/"spmRunTime"/"spmFrame"/"GameManagerIsSelectionMode"` | `spmAdd` positive `ev_9a43f627…` (2 hits `0x511e48`/`0x5125dc`); `spmRunTime` positive `ev_b0f45dde…` (2 hits `0x511e3d`/`0x5125c8`); `spmFrame` negative `ev_92247f53…` (0 hits — the "updates while held" claim is script-side `GameManagerIsSelectionMode` polling, not an `spmFrame` mode string); `GameManagerIsSelectionMode` positive `ev_cfee3355…` (`0x6a03c2`) |
| P26–P34 | ~9 donor-text read passes (outside Craft Anything, `C:\Games\Cossacks 3\data\…`, read-only) | all `[O]` in §§1–5 with file:line |

Engine-string verdict `[D]`: gameplay/script-bound names that ARE engine entry points (`MinFocalLength`, `DepthOfView`, `GetCameraFieldOfView`, `GetCameraAbsolutePosition`, `GetCurrentMouseWorldCoord`, `ScreenToWorld`, `ArcTan`, `GameManager*`, `GameObjectRayCast*`, `GetGUIMinimapUnderMouse`, GL imports) leave byte traces (P2–P4, P9–P21, P23, P25). Pure script identifiers (`FocalLength` as `.rdata` string, `FieldOfView`, `Projection`, `InitMinimap`, `cameradebug`, `GameManagerStartSelection`, `spmFrame`) do not (P5–P8, P26 `ev_592eb73f…` 0 hits, `ev_3ff56000…` 0 hits, `ev_0a0ca881…` 0 hits) — consistent with script-side law + engine-side projection/selection-box. Negatives are expected, not proof of absence (data-sections-only / file-bytes-only limits on every evidence record).

## 1. Exact FOV derivation from focal 400 + sensor width — still [U] (V1-SENSOR)

### 1.1 RECOVERED — every camera input is pinned `[O]`

`data\cameras\camera.cfg:1-65` (gameplay camera), verbatim (re-read this worker, P26):

- `[O]` `RestrictInfo: HeightTarget=1, HeightTargetMin=5, SphereHeight=SphereLength=58 (:6,9), Min 20 (:7,10)`.
- `[O]` `FreeRotationInfo`: all four pitch angles **−32°** (`:32-35`), `AngleLerpPower=1`, `Min/MaxDistToTargetObject=1/10`, `MaxHeightLerpFactor=0.15`.
- `[O]` `MinFocalLength=MaxFocalLength=400 (:44-45)`, `FocalLengthPower=1.0` — zoom fixed; `ElasticInfo` velocities/raycast steps (`:13-28`); `Bounded=True, DistToGroups=15`; DOF block (`:51-57`); `DynFogStart=0.25, End=0.025, Density=2.0, Power=0.85, Offset=0, Depth=False (:59-64)` — visual only, gameplay FOV-independent.
- `[O]` native anchor: `MinFocalLength` resident at VA `0x7abf68` (`ev_3ca11397…`, P10); `FocalLength` 16-hit CODE family (`ev_1b3522c0…`, P9, e.g. `0x5fe19e/0x5fe1da/0x5fea67/0x5fead3`); `DepthOfView` 8-hit CODE family (`ev_6263a9dd…`, P11); `GetCameraFieldOfView` at `0x5fece6` (`ev_df1bbc75…`, P16) — the focal→FOV entry point exists, its numeric law does not live in readable text.
- `[O]` siblings (never mix into gameplay): `default.cameras:1-96` (`Camera0/@Camera0`: Focal 400, DepthOfView 1200, Target 0/49/78.42125, Pos 0/0.0530/0.0848, Dir −Z, Up +Y; `@CameraDebug`: Focal 100, DepthOfView 50, Target 0/19/18); `cameradebug.cfg` (Sphere 19/5, pitch −30/−48, Focal 86–100); `camerascreenshot.cfg` (Sphere 13/0.75–0.6, pitch −90…+20, Focal 95, `DynFogDepth=True`).

### 1.2 Still-[U] — sensor width → FOV (the only missing derivation)

Thin-lens relation (pinhole, square pixels, no distortion) `[D]`:

> `FOV_v = 2·atan(sensor_h / (2·f))`, `FOV_h = 2·atan(sensor_w / (2·f))`, `f = 400` (focal units = sensor units). Aspect `a = w/h` couples them: `FOV_v = 2·atan(tan(FOV_h/2)/a)`.

`[U]`: no readable file defines sensor width/height, viewport mapping, film-gate, or pitch→FOV coupling. Port `FOV 17.27°` stays `PORT APPROXIMATION`: as a check, 17.27° vertical implies `sensor_h ≈ 2·400·tan(8.635°) ≈ 121.4` focal units — that number is **derived from the port claim, not donor**, and must never be written back as donor fact. 17.27° is the 16:9 VERTICAL of a 216 mm-wide sensor (`H = 2·atan(216/800) ≈ 30.22°`, `V = 2·atan(tan(H/2)/(16/9)) ≈ 17.27°`); the 36 mm-wide alternative gives ≈2.90° vertical. Neither width (216 / 36 / other) nor the choice of H-vs-V is in donor text or bytes — P5–P8 negatives + P9/P10/P16 positives prove the key and the entry point are consumed in CODE, not their numeric law. No FOV or sensor width is invented below.

- Experiment V1-SENSOR (fixed-camera projection capture, owner-authorised, zero-mismatch criterion): fixed map seed, fixed camera target, FOW off, place two surveyed markers at known world separation perpendicular to the view axis at target depth; capture frame; measure pixel separation + full frame size; solve `sensor = f·(px_sep/frame)·(world_sep/depth)`-family per the actual projection (bracket pinhole vs engine fit-mode by repeating at two depths); cross-check vertical vs horizontal. Then repeat with the focal-100 debug camera as a second equation. **Termination:** predicted pixel positions of ≥5 surveyed ground points agree with captured positions to **0 px mismatch** (integer pixels, same viewport, same 58/−32/400 rig) before any sensor/FOV literal is written as donor fact; until then every angle stays `PORT APPROXIMATION`.

## 2. Projection matrix: near/far/aspect — still [U] (V2-PROJ)

### 2.1 RECOVERED `[O]`

- GL fixed-function imports exist: `gluPerspective` (`0x90a6b8`), `glFrustum` (`0x90aaf4`), `glOrtho` (`0x90a9c6`), `glMatrixMode` (`0x90aa1a`), `glLoadIdentity` (`0x90aa62`), `glViewport` (CODE call sites `0x4b8688/0x4b869c/0x4b86b0` + `.idata` `0x90ac18`), `gluUnProject` (`0x90a67e`) — P2–P4, P23. These are `.idata` import names; they prove the engine CAN set up perspective/frustum/ortho projections and unproject, not which call the gameplay camera uses nor with which (fovy, aspect, near, far).
- `DepthOfView` (far-plane candidate) is consumed in CODE (P11, 8 hits) and declared per-camera in text (`1200` gameplay, `50` debug) — but no readable line binds `DepthOfView` to the GL `far` parameter; that binding is engine-side.
- No `near` literal exists anywhere in `data\cameras\*` (re-read: `camera.cfg`, `default.cameras`, `cameradebug.cfg`, `camerascreenshot.cfg` — zero near/aspect/viewport keys) `[O]`. Port `NEAR_M=0.1 / FAR_M=4096` are therefore port frustum-safety values, explicitly NOT donor numbers.
- Script-side world anchors ARE recovered: `GetCameraAbsolutePosition(cPos)` + `GetCurrentMouseWorldCoord(mPos)` + `GameObjectRayCastMouseRay → SortList → RayCastAABB(cPos→mPos)` (`control.script:156-184`, re-verified §4) — the pick ray, not the projection matrix.

### 2.2 Still-[U] — matrix + aspect + clip

No static literal for (fovy, aspect, near, far, principal point, pitch application order, `HeightTarget` handling) is recoverable from imports or text. A GL trace is required; Ghidra follow-up only if the trace under-constrains (same audit Q-4 gate as DEC-U-FOG §3).

- Experiment V2-PROJ (GL trace + runtime, owner-authorised, zero-mismatch criterion): instrumented frame with surveyed camera target + 58/−32/400 rig; log `GetCameraAbsolutePosition` + `GetCurrentMouseWorldCoord` for surveyed ground points; fit projection (focal, principal point, pitch order, HeightTarget handling); cross-check `DepthOfView=1200` as far-plane hypothesis by pushing a marker to 1199/1201 and observing clip vs render. **Termination:** fitted matrix re-projects ≥5 surveyed world points to captured pixels with **0 px mismatch** AND predicts the clip boundary (near + far) exactly before any (near, far, aspect) literal is written as donor fact.

## 3. Screen→world drag anchor — parent (§2 context) + script predicate RECOVERED, geometric anchor still [U] (V2-PROJ tail)

### 3.1 RECOVERED — drag state machine is script-side `[O]`

`data\gui\menu.inc\onmousemove.inc` (re-read, P27; `[*] = ;` lines are the live script body in this title's `.inc` convention):

- `[O]` epsilon: `var epsilon : Float = 0.005;` (`:32`), `if attackpoint/guard then epsilon := 0.25;` (`:33-34`).
- `[O]` world read per move: `GetCurrentMouseWorldCoord(x, y, z);` (`:69`).
- `[O]` two-phase start: `if not isselectionstarted then { isselectionstarted := true; prevselmousex := x; prevselmousez := z; }` (`:141-147`, exact lines `145-146` `gfloat_gui_prevselmousex := x; gfloat_gui_prevselmousez := z;`).
- `[O]` axis-wise epsilon compare: `if (Abs(x − prevselmousex) > epsilon) or (Abs(z − prevselmousez) > epsilon) then` (`:152`), then `GameManagerBeginSelection;` (`:154`) + Shift? `spmAdd` (`:157`) else `spmRunTime` (`:162`, commented `spmRemove` `:160-161` is dead).
- `[O]` release: `onmousedown.inc` `'LButtonUp'`: `isselectionstarted := false;` + `if GameManagerIsSelectionMode then GameManagerCancelSelection;` (+ unitcontrol/rally/cursor/sound flags) — drag end is engine-cancel + script-flag clear, not a script inside-test.

`[D]`: the donor freezes the WORLD-ground anchor on the FIRST LMB-held move (prevsel*), and compares axis-wise X/Z deltas — exactly what the port mirrors with `_sel_ground_start` (first-move) vs `_rect_ground_anchor` (press-frozen). The port's press-vs-first-move DUAL model is therefore a faithful reading of `:141-152`, but which of the two the engine uses GEOMETRICALLY (rect corner source) is still engine-side → [U].

### 3.2 Still-[U] — geometric anchor

- Experiment V2-PROJ-DRAG (runtime, owner-authorised, zero-mismatch criterion): fixed rig 58/−32/400; scripted LMB press at surveyed pixel, hold, move 1–3 px steps across the epsilon boundary in each axis; log `GetCurrentMouseWorldCoord` at press vs first-move vs each step + `GameManagerIsSelectionMode` onset frame. **Termination:** onset frame + frozen rect corner match ONE of (press-point, first-move-point) with **0 px / 0.0 m mismatch** on all four drag directions before the port collapses the dual model.

## 4. Marquee inside-test — script side RECOVERED (negative), predicate still [U] (V2-BOX)

### 4.1 RECOVERED — the inside predicate is engine-side (negative result is the finding) `[O/D]`

- `[O]` no readable predicate: `GameManagerStartSelection` 0 hits (`ev_0a0ca881…`), `spmFrame` 0 hits (`ev_92247f53…`), `InitMinimap` 0 hits (`ev_592eb73f…`) — the GameManager marquee modes live behind `Begin/Start(spmAdd|spmRunTime)/Cancel/IsSelectionMode/Clear/PickedObjects` engine calls (P17/P18/P25 positives: `Begin` `0x6a03fa`, `IsSelectionMode` `0x6a03c2`, `PickedObjects` `0x6a7cda`, `spmAdd` `0x511e48/0x5125dc`, `spmRunTime` `0x511e3d/0x5125c8`).
- `[O]` single-click law (the resolved neighbour, for contrast): `control.script:156-274` re-verified — minimap-under-mouse early-out (`:161`); ray `MouseRay → SortList` (`:164-165`); triple gate `Playable ∧ Visible ∧ CollisionDetection` (`:181`) + `RayCastAABB(cPos→mPos)` (`:184`); priority table `dmscript.global` (`gc_gui_cursorprio_my=1, wood=2, food=3, stone=4, goinside=5, build=6, enemy=7`); food only if `brised` else 0; building branches (unbuilt+can-build→6; absorbable/mine+peasant→5); enemy requires `enemyMask ∧ SelectedUnitsCanAttack`; winner `relativeDst := (1+dist)/prio`, min wins (`:260-266`); XZ distance `_misc_GetDistancePos(mpos,pos,False)`; FOW veto `bVisible := (not GetFOWEnable) or (LOS>0)`, else `nearestHnd := 0` (`:270-273`).
- `[O]` selection visuals + write protocol (unchanged): `brushes\selection.cfg` yellow RGBA(1,1,0,1), 1 px, solid, `LineStep=1`; `Begin → Start('spmRunTime') → Picked* → Cancel-once` (`control.script:28-32, 63/71, 108-112, 139/149, 426-427, 475/483`); hotkeys `hotkeys.cfg:1-243` (243 lines).
- `[D]` the drag rectangle's world mapping + inside rule (centroid-in vs AABB-overlap vs containment fraction, edge inclusion, squad-grouping side effects) cannot be read statically — every native name that would name it is either engine-opaque (`IsSelectionMode`) or absent (`spmFrame`). Port `Rect2.has_point` centroid-in + four-corner ground AABB stays `PORT APPROXIMATION`.

### 4.2 Still-[U] — inside predicate + projection→box mapping

- Experiment V2-BOX (runtime, FOW off, owner-authorised, zero-mismatch criterion): grid of idle peasants at known spacing; scripted drag rects inset/outset by 1–3 px around known units, both drag directions; log `GetCountGameManagerPickedObjects` membership per rect. Fit inside rule (centroid vs AABB vs fraction, edge inclusion, squad side effects) combined with the §2 projection solve for world mapping. **Termination:** fitted rule predicts membership of ALL probed rects (including 1-px edge cases and both drag directions) with **zero membership mismatches** before any rule is written as donor fact; `SelectionRectPainter` keeps its `PORT APPROXIMATION` tag until then.

## 5. Minimap scale + frustum quad — panel/refresh RECOVERED, mapping still [U] (V2-MINI)

### 5.1 RECOVERED — what is statically known `[O]`

- `[O]` panel: `data\gui\minimap.cfg` — `ImageWidth/Height=240, Width/Height=240, VAlign=valBottom, HAlign=halLeft, Position=(0,0,0,1), Visible=True`; `FrustumLineStyle` 1 px white pattern 65535, `Visible=False`; `FrustumVisible=True`; primitive `lens.0` 40×40 UV (0.5,0.5)-(1,1); remainder is the `pl2x2.*` (3 px) / `pl3x3.*` (4 px) + `.sel` sprite atlas, NOT mapping law (re-read full file this worker).
- `[O]` mapping law (per-unit sprite select, not scale): `misc.script:1137-1172` visible → building ? `pl3x3.<color>` : `pl2x2.<color>` (or `.sel` when selected); invisible → remove primitive; color index = `gMap.players[pl].color`.
- `[O]` refresh: `gui.script:3472` per-HUD-pass `_misc_UnitUpdateMiniMapPrimitive(goHnd,bPicked)`; `player.script:769` ownership/progress path.
- `[O]` init path is COMMENTED-OUT script (strong engine-side signal): `data\gui\menu.inc\initminimap.inc:1-50` — every line is `;`-prefixed (`cMinimapSize=240, cMinimapOffsetX/Y=−8, halParentRightWidth/valParentBottomHeight` parent, `SetGUIMiniMapWidth/Height(cMinimapSize*scale)`, `SetGUIMiniMapPosition(GetViewerWidth−size*scale+offsetX, offsetY, 0)`, `SetGUIMinimapZoom(1)`, `SetGUIMiniMapLayer(3)`, `SetMiniMapFrustumVisible(true)`, `SetGUIEventStateOnPressMiniMap('EventMinimap')`, `SetGUIMiniMapVisible(True)`). The scale/zoom/layer/frustum calls are ENGINE calls; their numeric behaviour is not defined in text.
- `[O]` click/drag jump: `onmousedown.inc` `'LButton'` → `if GetGUIMinimapUnderMouse then { double? _control_MoveCameraToPosition :116-131 else elastic-target-0 + _control_GetMoveCameraToPositionOffset + SetMainCameraRotateToTargetDir(false) + SetMainCameraMoveToTargetXZ(newx,newy) }`; donor offset helper `control.script:585-612` (`CameraInfoSaveFromCurrentView/ReadProperties → angleZ=−Lerp(−32,−32,Clamp((h−20)/38,0,1))=+32 (:595)`; `dx:=cx−tx (:596)`; `dz:=0.1 → VectorRotateX(dx,dy,dz,angleZ) (:598-599)`; `offZ:=ArcTan(angleZ)*height (:602)` — `ArcTan` resident at `0x60a8c6` (P15); `angleX:=VectorAngle(0,0,1,dx,0,dz)`, `dx<0 → −angleX`, `VectorRotateY(offX,tmp,offZ,angleX)`, `newX:=dstX+offX+dx; newZ:=dstZ+offZ+dz (:605-612)`).

### 5.2 Still-[U] — world→minimap affine + frustum quad projection

World→minimap scale/offset math and the frustum `lens` quad projection are engine-side (P8/P26 negatives: `Projection`, `InitMinimap` unresident; only `_XMiniMap` `0x958d01` `.rsrc` + panel keys exist).

- Experiment V2-MINI (GPU + runtime, owner-authorised, zero-mismatch criterion): FOW off, full-map screenshot + minimap capture at known camera; fit world→minimap affine (scale/offset, 240² panel vs non-square maps, DPI `AbsScaleByDPI` factor from `initminimap.inc:16`); move camera, fit frustum `lens` quad vs §2 projection; FOW on: sample never-seen / seen-now / explored-not-visible cells. **Termination:** fitted affine maps ≥5 surveyed world corners to minimap pixels with **0 px mismatch** AND the frustum quad matches the projected view rect with **0 px mismatch** before any scale/frustum number is written as donor fact. Static head-start (no binary needed): finish reading the `gui.script` minimap/HUD block around `:3472` + `DoUpdateSelection`/`_misc_UpdateMiniMapPrimitives` state.

## 6. Port change list (COORD/owner applies; this worker wrote no code)

Paths are `variant3d/scripts/…` (verified present by glob this worker). Line numbers are current-file anchors — re-verify at apply time.

1. `camera3d.gd:58-60,76-82,97-113` (`config.gd:72-76,109-121` mirror): KEEP `DONOR_HEIGHT_MAX/MIN=58/20`, `DONOR_FOCAL=400`, `DONOR_PITCH_DEG=−32`, `DONOR_DYNFOG_*` + `DEPTH=False` exactly as cited (`camera.cfg:6-10,32-35,44-45,59-64`); KEEP `FOV_DEG_ASSUMED=17.27` (`:109`), `NEAR_M=0.1/FAR_M=4096` (`:112-113`), `fov` wiring via `feature_camera_fov_deg()` (`:200-229`) tagged `PORT APPROXIMATION / UNVERIFIED` with V1-SENSOR pointer. Do NOT write any sensor width (216/36/121.4) or near/far/aspect literal as donor fact. After V1-SENSOR/V2-PROJ terminate at zero mismatch, replace (a) the constant + getter default and (b) `NEAR_M/FAR_M` with the fitted values in the SAME two files (`camera3d.gd` + `config.gd:FEATURES_DEFAULTS["camera"]["fov_deg"]`), keeping the `PORT APPROXIMATION` comment until that moment.
2. `camera.gd:10-20,92-96` (2D mirror): KEEP `donor_camera_pins_mirror()` 58/20/−32/400 and the §10-17 V1-SENSOR `PORT APPROXIMATION` banner; no FOV/sensor edit here — the 2D camera consumes only height pins via `Data.CAMERA_*` in `bind()`. Any V2-PROJ matrix result lands in `camera3d.gd` only.
3. `input_controller.gd:35-71,271-288,645-705,850-903` + `picking3d.gd` (3D candidate source): (a) KEEP the §6-20 header + `DONOR_PICK_*=1..7` (`:25-31`), `DONOR_SELECTION_MODE='spmRunTime'` (`:33`), priority/score/veto helpers `donor_pick_priority/score` + `_donor_los_ok` (`:771-816`) and the `Begin→Start→Picked→Cancel-once` shims (`:819-847`) — all `[O]` per §4.1; (b) KEEP `_rect_ground_anchor` + `_sel_ground_start` dual model (`:57-71`), `_drag_world_rect()` four-corner AABB (`:693-705`), `_apply_rect_selection()` `has_point` (`:711-742`) and the `PORT APPROXIMATION` banners (`:61-70, 684-692`) UNTIL V2-BOX terminates — then collapse to the single winning anchor and swap the inside rule for the fitted predicate in `_drag_world_rect`/`_apply_rect_selection` only; (c) KEEP press-freeze (`:1019-1021`), first-move epsilon (`:1139-1154`, `onmousemove.inc:141-152`), `spmAdd` Shift union (`:717-732`, `onmousemove.inc:156-157`), LButtonUp teardown (`:1107, 253-269`) — no change except the V2-BOX winning rule.
4. `config.gd:46-88,461-464,508-517` (incl. `FEATURES_DEFAULTS["camera"]["fov_deg"]=17.27` at `:75` + `feature_camera_fov_deg()` at `:461-464` + `Data.CAMERA_PITCH/MIN_HEIGHT/MAX_HEIGHT/FOCAL` at `:509-512`): KEEP all four camera pins + the `:73-74` + `:462-463` V1-SENSOR `PORT APPROXIMATION` banners; KEEP `features.hud.minimap_*` (`:78-80`, from `initminimap.inc:5-7`) and `features.selection.*` (`:48-53`, from `onmousemove.inc:32-34`, `selection.cfg:3-14`, `menu.cfg:33`) untouched by this ticket. After V1-SENSOR terminates, update ONLY the `:75` default + `:464` fallback + `apply()`-time documentation, never the selection/hud keys.
5. Explicit non-changes: `world3d`/`hud` minimap-box code takes NO static edit — V2-MINI needs the runtime affine first; `game.gd` save/tick, `ai.gd`, FOW grid/combine take NO edit from this ticket.

## 7. Explicit non-claims + file discipline

- No parity claimed. No donor binary executed, no GPU frame captured, no port capture compared. Closed items rest on donor text `[O]` with file:line or pinned native evidence ids + VAs/file-offs in §0; open items list exact captures with zero-mismatch termination in §§1–5.
- No approximation substituted: 17.27° (and its 216 mm / 121.4-unit shadows), 0.1/4096 clip, press-vs-first-move anchor choice, centroid-in rule, minimap affine/frustum quad all remain labelled `[U]`/`PORT APPROXIMATION` with a settling experiment each. Sensor width, FOV, near/far/aspect, drag geometric anchor, marquee inside-test are NEVER invented in this report.
- Read-only compliance: exactly one repo file written (this report). Native passes pinned to `t_87f0f3c130b0` (§0 with evidence ids + VAs/file-offs); shared Craft Anything investigation memory was read, never written; no target opened/selected/closed by this worker.

*End of DEC-U-CAMERA-PROJECTION.*
