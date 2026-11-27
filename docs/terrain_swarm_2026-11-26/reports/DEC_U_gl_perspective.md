# DEC-U-GL-PERSPECTIVE — native projection setup: FOV-from-focal law, sensor/aspect, near/far, viewport (2026-11-26)

- id: DEC-U-GL-PERSPECTIVE
- worker: DEC-U-GL-PERSPECTIVE (subagent, full 1:1 donor port)
- date: 2026-11-26
- scope: READ-ONLY decomp. Donor binary never executed/copied/run. Donor text read as text only. No code/asset/config/Godot/git edit. Exactly one repo file written (this report).
- pin: `t_87f0f3c130b0` = `C:\Games\Cossacks 3\cossacks.exe`, PE32, 5,768,048 B, sha256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`, Deep mode
- upstream: `DEC_U_camera_projection.md` (camera 58/−32/400, pick law, GL import VAs localized; left V1-SENSOR / V2-PROJ / V2-BOX / V2-MINI as [U]; port 17.27° = PORT APPROXIMATION). This ticket deep-decomps the items V1-SENSOR + V2-PROJ left open there.
- labels: `[O]` verbatim donor bytes/text · `[D]` deterministic reading · `[I]` inference · `[U]` UNVERIFIED (settling experiment given, never substituted) · `PORT APPROXIMATION` = port-authored substitute
- parity: NO PARITY CLAIM. No donor GPU A/B frame. No donor binary executed by this worker. Closed items rest on pinned native evidence ids + VAs/file-offs or donor text file:line; engine-side numerics stay [U].
- donor read-only compliance: native calls are `core_session_show` / `native_functions_search` / `native_name_xrefs_list` / `native_xrefs_list` / `native_bytes_find` / `native_function_find` / `native_function_pseudocode` / `native_function_callees_list` / `native_data_show` only, all pinned `document:"t_87f0f3c130b0"`. Donor `.cfg`/`.script` cited from the upstream re-reads, not re-opened here.

## 0. Pass ledger (all native passes pinned `document:"t_87f0f3c130b0"`)

| # | Pass | Result |
|---|---|---|
| P0 | `core_session_show` | active `t_87f0f3c130b0` (Deep), 710 evidence records; `editor.exe t_68474ddde43f` present, untouched |
| P1 | `native_functions_search "gluPerspective"` | **positive** `ev_2b1b891b…` — 1 import: `gluPerspective @ 0x907b84` (`GLU32.dll`). (Upstream P2 reported `.idata` VA `0x90a6b8` for the same name — listing-scope/base difference, not a contradiction; both are import slots for the same DLL entry.) |
| P2 | `native_functions_search "glFrustum"` | **positive** `ev_bffa88fc…` — thunk `glFrustum@thunk @ 0x4afd04` + import `__imp_glFrustum @ 0x907c98` (`opengl32.dll`) |
| P3 | `native_functions_search "glOrtho"` | **positive** `ev_569f1224…` — thunk `glOrtho@thunk @ 0x4afda4` + import `__imp_glOrtho @ 0x907c48` |
| P4 | `native_functions_search "glViewport"` | **positive** `ev_fb61bd51…` — thunk `glViewport@thunk @ 0x4afc5c` + import `__imp_glViewport @ 0x907cec` |
| P5 | `native_functions_search "gluUnProject"` | **positive** `ev_8e702c77…` — 1 import: `gluUnProject @ 0x907b74` (`GLU32.dll`), no thunk lifted |
| P6 | `native_functions_search "glGetFloatv"` | **positive** `ev_8fa02734…` — thunk `glGetFloatv@thunk @ 0x4afbbc` + import `@ 0x907d3c`. `glGetDoublev` remains name-not-found (`ev_806eed1f…`, P24 of upstream confirmed) |
| P7 | `native_xrefs_list 0x907b84 / name_xrefs gluPerspective` | `ev_e54a97d2…` + `ev_c6949392…` — **0 references** to `__imp_gluPerspective`. Statically uncalled |
| P8 | `native_xrefs_list 0x907b74 / name_xrefs gluUnProject` | `ev_46aa166e…` + `ev_6a0d4ca2…` — **0 references** to `__imp_gluUnProject`. Statically uncalled |
| P9 | `native_xrefs_list glFrustum thunk 0x4afd04` | `ev_a2f8c4b4…` — 1 caller: `sub_4cd334 +0x2f2` at `0x4cd626` → `glFrustum()` |
| P10 | `native_xrefs_list glOrtho thunk 0x4afda4` | `ev_061f9b8a…` — 1 caller: `sub_4cd334 +0x43d` at `0x4cd771` → `glOrtho()` |
| P11 | `native_xrefs_list glViewport thunk 0x4afc5c` | `ev_28ca7f5f…` — **8 callers**: `sub_4d10c8 @ 0x4d1216`, `sub_4d1310 @ 0x4d1372`, `sub_5d1c60 @ 0x5d1daa`, `sub_5d1df0 @ 0x5d1e1d`, `sub_5d1fa4 @ 0x5d2064/0x5d2203`, `sub_77c264 @ 0x77c2f7/0x77ca01` |
| P12 | `native_name_xrefs_list glMatrixMode / glLoadIdentity` | `ev_ba82f314…` — `glMatrixMode @ 0x907c60` (via `0x4afd74`), **87 call sites** incl. `sub_5d1c60 @ 0x5d1db4/0x5d1de5`, `sub_5d2234`, `sub_77c264` · `ev_8f93cf88…` — `glLoadIdentity @ 0x907c74` (via `0x4afd4c`), **22 call sites** incl. `sub_5d1c60 @ 0x5d1dbe` |
| P13 | `native_name_xrefs_list glMultMatrixf / gluOrtho2D` | `ev_482ab542…` — `glMultMatrixf @ 0x907c5c` (via `0x4afd7c`), **24 refs** incl. `sub_4cd334 @ 0x4cd723` · `ev_9974b6a2…` — `gluOrtho2D @ 0x907b88` (via `0x4afecc`), 1 code caller: `sub_4cd334 @ 0x4cd38c` |
| P14 | `native_bytes_find "GetCameraFieldOfView"` | **positive** `ev_5273d228…` — 1 match: VA `0x5fece6`, file-off `0x1fe0e6`, CODE (independent re-find of upstream `ev_df1bbc75…`, same VA) |
| P15 | `native_bytes_find "ByFocalLength"` | **positive NEW** `ev_973a2767…` — 1 match: VA `0x5fecfa`, file-off `0x1fe0fa`, CODE. Full script name `GetCameraFieldOfViewByFocalLength` EXISTS as CODE bytes (+`0x14` past P14). Upstream P5 negative was `native_strings_find` (data-sections only) — corrected: the long form is not resident as a *string-table* entry, but IS resident as CODE bytes |
| P16 | `native_bytes_find "FieldOfView"` | **positive CORRECTION** `ev_74b24057…` — 3 matches, all CODE: `0x5798db`, `0x5fecef` (+`0x9` past P14 — the overlapping tail of `GetCameraFieldOfView`), `0x5fed68`. Upstream P6 negative was the same data-sections scope effect |
| P17 | `native_bytes_find "Projection"` | **positive CORRECTION** `ev_b2d635ba…` — 1 match: VA `0x85511c`, CODE. Upstream P8 negative same scope note |
| P18 | `native_bytes_find "FocalLength"` | **positive** `ev_99a2e779…` — 16 matches, all CODE (same set as upstream `ev_1b3522c0…`: `0x4c851e`, `0x58c14b`, `0x58e1ac`, `0x5d5d54`, `0x5fe19e/0x5fe1da/0x5fea67/0x5fead3/0x5fecfc/0x5fed5b`, `0x7aadb0/0x7ab32c/0x7abf6b/0x7abf83/0x7abf98`, `0x7e99db`) |
| P19 | `native_bytes_find "MinFocalLength"` | **positive** `ev_3ca11397…` (replayed; same bytes/VA as upstream P10) — 1 match: VA `0x7abf68`, file-off `0x3ab368`, CODE. Same VA as DEC-U-FOG `ev_d5c83e0d…`; independent re-find |
| P20 | `native_bytes_find "ArcTan"` | **positive** `ev_794ab354…` (replayed) — 1 match: VA `0x60a8c6`, file-off `0x209cc6`, CODE |
| P21 | `native_bytes_find "DepthOfView"` | **positive** `ev_e47df716…` — 8 matches, all CODE: `0x4c84cc/0x4c84f8`, `0x5fe2b0/0x5fe301/0x5fe353/0x5fe387`, `0x7aadc4/0x7ab340` |
| P22 | `native_bytes_find "NearPlane"` | **positive NEW** `ev_32bcebdff…` — 2 matches, CODE: `0x4c8590`, `0x4c85be` |
| P23 | `native_bytes_find "FarPlane"` | **negative** `ev_647c7a72…` — 0 hits (file-bytes-only limit; absence is not proof) |
| P24 | `native_bytes_find "Sensor"/"SensorWidth"/"FilmGate"` | **negatives** `ev_fdab0b9e…` / `ev_b29e61ab…` / `ev_98f4cd06…` — 0 hits each (same limit) |
| P25 | `native_bytes_find "Aspect"` | **positive** `ev_808ea2b9…` — 9 matches, all CODE (`0x50ce30`, `0x50d47c`, `0x5a4c71`, `0x5a5564`, `0x6db810`, `0x6db868`, `0x87436c`, `0x874933`, `0x88878f`) — no numeric aspect literal recovered; names only |
| P26 | `native_bytes_find "GetViewerWidth"` | **positive** `ev_9221a512…` — 1 match: VA `0x69dd5e`, CODE |
| P27 | `native_function_find 0x5fece6 / 0x5fecfa / 0x5fed68` | `ev_97dc5792…` / `ev_7b28d3b3…` / `ev_ab939f78…` — ALL inside `sub_5fc2d0` (+`0x2a16` / +`0x2a2a` / +`0x2a98`). FOV-by-focal entry cluster lives in one dispatch/blob region |
| P28 | `native_function_find 0x7abf68 / 0x60a8c6 / 0x4c8590 / 0x4c85be` | `ev_0de6f343…` / `ev_d0b81369…` / `ev_4f293efc…` / `ev_fda28150…` — **not inside any discovered function** (engine did not lift these CODE-string-table regions; absence is not proof). `0x7abf68` has 1 data ref: `0x7aba11` in `sub_7ab704` (`ev_6b9e9436…`) |
| P29 | `native_xrefs_list 0x5fece6 / 0x60a8c6` | `ev_420398ac…` / `ev_14148c30…` — 0 static refs each (computed-pointer/script-VM dispatch; same limit as upstream P22) |
| P30 | `native_function_callees_list sub_4cd334` | `ev_db494e86…` — 5 calls (1 unresolved indirect): `gluOrtho2D @ 0x4cd38c`, `glMultMatrixf @ 0x4cd723`, `glOrtho @ 0x4cd771`, `glFrustum @ 0x4cd626`, + 1 indirect at `0x4cd3bf` |
| P31 | `native_function_pseudocode sub_4cd334` (Ghidra) | `ev_030dff8c…` — 114-line `FUN_004cd334(int p1, int *p2, int w, float focalArg, int p5, int h)`; mode byte `*(p1+200)` selects `gluOrtho2D (0x02)` / script callback `(0x03)` / `glFrustum (0x00)` / `glOrtho (0x01)` / `glMultMatrixf-custom (0x04)`; frustum bounds computed from `w/h`, struct floats, constants — see §2 |
| P32 | `native_function_callees_list + pseudocode sub_5d1c60` | `ev_330f8358…` (23 calls) + `ev_6a85f244…` (Ghidra 72-line `FUN_005d1c60`) — viewport setup caller: `glClear → glViewport → glMatrixMode → glPushMatrix → glLoadIdentity → sub_4cd334(…) → glMatrixMode`; args `(w=p1+0x44, h=p1+0x48, focalFloat=(…+0x4c)+0xa4, 0x60, …)` — see §4 |
| P33 | `native_xrefs_list sub_4cd334 @ 0x4cd334` | `ev_0aa32744…` — 2 callers: `sub_5d1c60 @ 0x5d1ddb`, `sub_777c80 @ 0x777cc1` |
| P34 | `native_function_pseudocode sub_5fc2d0` (clean-room lifter) | `ev_d66f22fc…` — 2698-block unstructured output, 1532 gotos, 2079 inline-asm lines; decodes as string bytes, NOT real control flow. Confirms upstream verdict: `sub_5fc2d0` region is a CODE string/dispatch table, not a lifted camera function |
| P35 | `native_data_show constants` | `ev_b817f88a…` `0x4cd780` = `100.0f` · `ev_32cefcfa…` `0x4cd784` = `2.0f` · `ev_2d1ad19e…` `0x4cd788` u32 `0x33333333` (low word of an 8-byte extended/float-table entry — f64 misread `ev_a8ddd71c…` = garbage `-1.8e+54`, recorded to prevent misuse) · `ev_88ae229f…` `0x4cd794` = `1.0f` · `ev_50092d6f…`/`ev_9414feb8…` `0x8f4dec` (DATA) = `0.0001f` (2 refs; observed float, NOT claimed as near plane) · neighbours `ev_cbaee89c…` `0x4cd78c`, `ev_e00686ae…` `0x4cd790` (table continuation) |
| P36 | `native_data_show string bytes` | `ev_f60aa533…` `0x5fecfa`, `ev_ff68428d…` `0x4c8590`, `ev_b6c40f75…` `0x4c85be` — read as `u32`, i.e. ASCII bytes (`By…`/`Near…`), confirming CODE-string placement, not numeric literals |

Engine-string verdict `[D]`: gameplay/script-bound names that ARE engine entry points (`MinFocalLength`, `DepthOfView`, `NearPlane`, `GetCameraFieldOfView[ByFocalLength]`, `GetCameraAbsolutePosition`, `GetCurrentMouseWorldCoord`, `ScreenToWorld`, `ArcTan`, GL imports) leave byte traces (P1–P6, P12–P15, P18–P22, P26). Pure script identifiers consumed as CODE bytes in a dispatch/blob region (`FocalLength` 16-hit CODE family, `FieldOfView` overlap tails, `Projection`, `Aspect`) do not appear in `.rdata`. Negatives (`Sensor`, `SensorWidth`, `FilmGate`, `FarPlane`, `glGetDoublev`, `gluPerspective/gluUnProject` callers) are expected scope effects, not proof of absence (file-bytes-only + static-references-only limits on every evidence record).

## 1. Exact FOV derivation from focal 400 + sensor/aspect — still [U] (V1-SENSOR)

### 1.1 RECOVERED — every camera input pinned `[O]`

Upstream §1.1 stands (camera 58/−32/400, focal power 1, DynFog visual-only). This worker adds:

- `[O]` The focal→FOV entry point EXISTS under its FULL script name: `GetCameraFieldOfView` at `0x5fece6` (P14, `ev_5273d228…`) + `ByFocalLength` at `0x5fecfa` (P15, `ev_973a2767…`, +`0x14`) + `FieldOfView` tails at `0x5fecef`/`0x5fed68` (P16, `ev_74b24057…`) — all inside `sub_5fc2d0` (P27). The numeric law does not live in readable text: P34 lifter output for `sub_5fc2d0` is string-bytes garbage, i.e. the binding names live in a dispatch/blob region the engine did not lift as code.
- `[O]` `MinFocalLength` at `0x7abf68` (P19) has exactly one static data ref: `0x7aba11` in `sub_7ab704` (`ev_6b9e9436…`, P28). Config key consumed in CODE; numeric 400 lives in `camera.cfg:44-45` text, not as a recovered float literal.
- `[O]` The gameplay projection does NOT call `gluPerspective`: `__imp_gluPerspective @ 0x907b84` has 0 static refs (P7, `ev_e54a97d2…` + `ev_c6949392…`). FOV is therefore NOT `gluPerspective(fovy, aspect, near, far)` with a literal `fovy` — it is the custom frustum math in `sub_4cd334` (§2). `gluUnProject` is likewise statically uncalled (P8) — pick-ray code (`ScreenToWorld`, `GameObjectRayCastMouseRay`) does its own unprojection; the `gluUnProject @ 0x907b74` slot is linked, not used by the traced path.
- `[O]` No sensor constant exists in the binary as text: `Sensor` / `SensorWidth` / `FilmGate` all 0 hits (P24, `ev_fdab0b9e…` / `ev_b29e61ab…` / `ev_98f4cd06…`). `Aspect` has 9 CODE name hits (P25) but no numeric literal. Thin-lens relation stays the ONLY law (upstream §1.2, `[D]`): `FOV_v = 2·atan(sensor_h/(2·f))`, `f = 400`.

### 1.2 Still-[U] — sensor width → FOV (the only missing derivation)

No readable line or float literal binds focal 400 to an angle. Port `FOV 17.27°` stays `PORT APPROXIMATION` (216 mm-wide-sensor 16:9 vertical: `H = 2·atan(216/800) ≈ 30.22°`, `V = 2·atan(tan(H/2)/(16/9)) ≈ 17.27°`); the 36 mm alternative (≈2.90° vertical) and every other width are equally unpinned. The numbers 216/36/121.4 are port derivations, never donor facts, and are not written back anywhere in this report as donor.

- Experiment V1-SENSOR (fixed-camera projection capture, owner-authorised, zero-mismatch criterion): fixed map seed, fixed camera target, FOW off; two surveyed markers at known world separation perpendicular to the view axis at target depth; capture frame; measure pixel separation + full frame size; solve `sensor = f·(px_sep/frame)·(world_sep/depth)`-family per the actual projection (bracket pinhole vs engine fit-mode by repeating at two depths); cross-check vertical vs horizontal; repeat with the focal-100 debug camera as a second equation. **Termination:** predicted pixel positions of ≥5 surveyed ground points agree with captured positions to **0 px mismatch** (integer pixels, same viewport, same 58/−32/400 rig) before any sensor/FOV literal is written as donor fact. Until then every angle stays `PORT APPROXIMATION`.

## 2. Projection matrix: custom frustum in `sub_4cd334`, near/far — still [U] (V2-PROJ)

### 2.1 RECOVERED — the actual setup call `[O]`

Ghidra pseudo-C for `sub_4cd334` (`ev_030dff8c…`, P31), signature `FUN_004cd334(int p1, int *p2, int w, float focalArg, int p5, int h)`:

- Mode byte `*(p1+200)`: `0x02` → `gluOrtho2D()` (P13, site `0x4cd38c`); `0x03` → script callback through `*(p1+0xe0)`; else compute frustum bounds, then `0x00` → `glFrustum()` (site `0x4cd626`, P9), `0x01` → `glOrtho()` (site `0x4cd771`, P10), `0x04` → `glMultMatrixf()` custom matrix (site `0x4cd723`, P13/P30).
- Frustum-bound law (verbatim structure, symbols renamed): `m = max(w,h)` (`local_34`); `focalScale = *(p1+0xac)/((float)w · *(p1+0xcc))` for modes 0x00/0x04, else `(100.0 · *(p1+0xac))/((float)w · *(p1+0xa0) · *(p1+0xcc))` with `100.0f` from `_DAT_004cd780` (P35, `ev_b817f88a…`); left/right from `(w·(…p2…−w)·focalScale)/(2·m)` family with `2.0f` from `_DAT_004cd784` (P35, `ev_32cefcfa…`); same in `h` with `*(p1+0xd0)`; depth term `local_2c = ((p5 · *(p1+0xa0) · 2.0/(_DAT_004cd788 · m)) · *(p1+0xac) + focalArg)`; mode-0x04 custom matrix additionally uses `_DAT_008f4dec = 0.0001f` (P35, `ev_50092d6f…`/`ev_9414feb8…`, DATA, 2 refs) and `1.0f` from `_DAT_004cd794` (P35).
- `[D]`: near/far are RUNTIME struct/caller values (`p5`, `focalArg`, `*(p1+…)`, viewport `w/h`), NOT static literals. The `0.0001f` at `0x8f4dec` is an observed DATA float used on the custom-matrix path — it is NOT claimed as the donor near plane. `gluPerspective` plays no role on any path (P7).

### 2.2 Still-[U] — numeric near/far + struct-field bindings

- `[O]` `DepthOfView` (far-plane candidate) is consumed in CODE (P21, 8 hits) and declared per-camera in text (`1200` gameplay, `50` debug per upstream §1.1) — but no readable line binds it to the GL `far` parameter; that binding is engine-side.
- `[O]` `NearPlane` EXISTS as CODE bytes at `0x4c8590`/`0x4c85be` (P22, `ev_32bcebdff…`), in a region the engine did not lift (P28) with no static value attached (`ev_ff68428d…`, `ev_b6c40f75…` read as ASCII). `FarPlane` has 0 hits (P23). No near/far NUMERIC literal is recovered anywhere: port `NEAR_M=0.1 / FAR_M=4096` are frustum-safety values, explicitly NOT donor numbers.
- Experiment V2-PROJ-NF (GL trace + runtime, owner-authorised, zero-mismatch criterion): instrumented frame with surveyed camera target + 58/−32/400 rig; fixed viewport; log `GetCameraAbsolutePosition` + `GetCurrentMouseWorldCoord` for surveyed ground points; fit projection (focal scale, principal point, pitch order, `HeightTarget` handling); cross-check `DepthOfView=1200` as far-plane hypothesis by pushing a marker to 1199/1201 and observing clip vs render; bracket near by pushing geometry toward the eye until clip. **Termination:** fitted matrix re-projects ≥5 surveyed world points to captured pixels with **0 px mismatch** AND predicts the clip boundary (near + far) exactly before any (near, far) literal is written as donor fact.

## 3. Viewport + aspect handling — RECOVERED structure, [U] numbers (V2-PROJ-ASPECT)

`[O]` Viewport setup caller `sub_5d1c60` (`ev_330f8358…` + `ev_6a85f244…`, P32): `glClear → glViewport(0,0,w,h) → glMatrixMode → glPushMatrix → glLoadIdentity → sub_4cd334(…w,h…) → glMatrixMode`, with `w = *(p1+0x44)`, `h = *(p1+0x48)`, refreshed only when `param_2[0xf]/[0x10]` change (window-size driven). `sub_4cd334` is called from exactly 2 sites: `sub_5d1c60 @ 0x5d1ddb` (viewport path) and `sub_777c80 @ 0x777cc1` (P33, `ev_0aa32744…`). Aspect is NOT a single stored ratio: `sub_4cd334` normalises by `m = max(w,h)` and computes separate `w`- and `h`-numerators, i.e. aspect handling is structural (viewport-driven per-axis scale), with `focalScale` differing per axis via `*(p1+0xcc)` vs `*(p1+0xd0)`. No numeric aspect literal exists (P25 names only).

- Experiment V2-PROJ-ASPECT (runtime, owner-authorised, zero-mismatch criterion): fixed rig 58/−32/400; capture the SAME surveyed scene at ≥3 viewport aspect ratios (e.g. 4:3, 16:9, 21:9 with identical height); fit per-axis focal scale + principal point from `GetCameraAbsolutePosition`/`GetCurrentMouseWorldCoord` logs. **Termination:** one fitted matrix family re-projects ≥5 surveyed points at EVERY probed aspect with **0 px mismatch** before any aspect/focal-scale literal is written as donor fact.

## 4. Screen→world drag anchor — parent context, geometric anchor still [U] (V2-PROJ tail)

Upstream §3 verdict stands and is not re-litigated here: the drag state machine is script-side (`onmousemove.inc:32-34` epsilons, `:69` world read, `:141-152` first-move freeze + axis-wise epsilon compare, `:154-162` `Begin→spmAdd/spmRunTime`, `onmousedown.inc LButtonUp` teardown) with the port's press-vs-first-move DUAL model faithfully mirroring `:141-152`; which of the two the engine uses GEOMETRICALLY (rect corner source) is engine-side → [U]. The projection solve in §§1–2 is its prerequisite: the anchor experiment cannot terminate before V1-SENSOR/V2-PROJ do.

- Experiment V2-PROJ-DRAG (runtime, owner-authorised, zero-mismatch criterion): fixed rig 58/−32/400; scripted LMB press at surveyed pixel, hold, move 1–3 px steps across the epsilon boundary in each axis; log `GetCurrentMouseWorldCoord` at press vs first-move vs each step + `GameManagerIsSelectionMode` onset frame. **Termination:** onset frame + frozen rect corner match ONE of (press-point, first-move-point) with **0 px / 0.0 m mismatch** on all four drag directions before the port collapses the dual model.

## 5. Port change list (COORD/owner applies; this worker wrote no code)

Paths are `variant3d/scripts/…` (verified present by glob this ticket's session; upstream verified `variant3d` line numbers, re-verify at apply time). No edit made here.

1. `camera3d.gd:97-113,200-202,286-310` — KEEP `DONOR_HEIGHT_MAX/MIN=58/20`, `DONOR_FOCAL=400`, `DONOR_PITCH_DEG=−32`, `DONOR_DYNFOG_*` + `DEPTH=False` exactly as cited (`camera.cfg:6-10,32-35,44-45,59-64`); KEEP `FOV_DEG_ASSUMED=17.27` (`:109`), `NEAR_M=0.1/FAR_M=4096` (`:112-113`) and `fov/near/far` wiring via `cfg.feature_camera_fov_deg()` (`:200-229`) tagged `PORT APPROXIMATION / UNVERIFIED` with V1-SENSOR pointer. Do NOT write any sensor width (216/36/121.4), near/far literal, or aspect constant as donor fact. `_apply_transform()` (`:288-310`) correctly applies pitch/height only — the donor frustum law (§2: `sub_4cd334` mode byte + per-axis focal scale) has no Godot-side equivalent yet; after V1-SENSOR/V2-PROJ-NF/V2-PROJ-ASPECT terminate at zero mismatch, replace in the SAME file (a) the constant + getter default and (b) `NEAR_M/FAR_M` with the fitted values, keeping the `PORT APPROXIMATION` comment until that moment. `jump_to_world_donor_offset()` (`:609-635`) keeps its ArcTan `cot(32°)` PORT APPROXIMATION — `ArcTan @ 0x60a8c6` (P20/P28/P29: undiscovered region, 0 refs) gives no units/body to transcribe.
2. `config.gd:72-76,109-121,461-464,508-517` (incl. `FEATURES_DEFAULTS["camera"]["fov_deg"]=17.27` at `:75` + `feature_camera_fov_deg()` at `:461-464` + `Data.CAMERA_PITCH/MIN_HEIGHT/MAX_HEIGHT/FOCAL` at `:509-512`): KEEP all four camera pins + the `:73-74` + `:462-463` V1-SENSOR `PORT APPROXIMATION` banners; KEEP `features.hud.minimap_*` and `features.selection.*` untouched by this ticket. After V1-SENSOR terminates, update ONLY the `:75` default + `:464` fallback + `apply()`-time documentation, never the selection/hud keys.
3. `camera.gd:10-27` (2D mirror): KEEP `donor_camera_pins_mirror()` 58/20/−32/400 and the §10-17 V1-SENSOR `PORT APPROXIMATION` banner; no FOV/sensor/near/far edit here — the 2D camera consumes only height pins via `Data.CAMERA_*` in `bind()`. Any V2-PROJ matrix result lands in `camera3d.gd` only.
4. Explicit non-changes: `input_controller`/`picking3d` marquee code, `world3d`/`hud` minimap-box code, `game.gd` save/tick, `ai.gd`, FOW grid/combine take NO edit from this ticket. Drag-anchor collapse and inside-test swap wait for V2-PROJ-DRAG / V2-BOX (upstream §4), not this report.

## 6. Explicit non-claims + file discipline

- No parity claimed. No donor binary executed, no GPU frame captured, no port capture compared. Closed items rest on pinned native evidence ids + VAs/file-offs in §0 or donor text file:line; open items list exact captures with zero-mismatch termination in §§1–4.
- No approximation substituted: 17.27° (and its 216/36/121.4-unit shadows), 0.1/4096 clip, `0.0001f @ 0x8f4dec` (observed DATA float, §2.1 — NOT a near plane), `100.0f/2.0f/1.0f` table constants (observed, §2.1 — NOT sensor/focal facts), press-vs-first-move anchor choice all remain `[U]`/`PORT APPROXIMATION` with a settling experiment each. Sensor width, FOV, near/far/aspect, drag geometric anchor are NEVER invented in this report.
- VA note `[D]`: import-slot VAs in this report (`0x907b84/0x907c98/0x907c48/0x907cec/0x907b74/0x907b88/0x907c60/0x907c74/0x907c5c/0x907d3c`) differ textually from upstream's `.idata` VAs (`0x90a6b8/0x90aaf4/0x90a9c6/0x90ac18/0x90a67e/0x90aa1a/0x90aa62`) for the same DLL entries — engine listing-scope/base difference, same imports, both cited so a re-finder can match either.
- Read-only compliance: exactly one repo file written (this report). Native passes pinned to `t_87f0f3c130b0` (§0 with evidence ids + VAs/file-offs); shared Craft Anything investigation memory was read, never written; no target opened/selected/closed by this worker.

*End of DEC-U-GL-PERSPECTIVE.*
