---
id: PORT1TO1-SELECTION-OWNER-PROTOCOL-2026-11-26
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER SELECTION-OWNER-PROTOCOL — exact owner-only experiment packet for P0-8 selection/projection"
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_selection_owner_protocol.md
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION
created: 2026-11-26
labels: [OBSERVED, DERIVED, UNVERIFIED, "PORT APPROXIMATION", PARITY_UNVERIFIED, NO_APPROXIMATION]
parity_status: UNVERIFIED
parity_claim: false
parity_claim_code: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — P0-8 remains open; this packet authorises owner-only runs, closes nothing by itself"
scope_guard: "Repo/doc reads read-only. No source, shader, asset, config, test, fixture, result JSON, git state, Godot process, runner job, gate, capture or ROI metric created, modified or executed. Exactly one repository file written: this report. Donor install (C:\\Games\\Cossacks 3) was never executed or captured by any worker; all donor facts below are carried [O]/[D] from cited landed reports. Donor GPU/runtime session is OWNER-AUTHORISED ONLY and FORBIDDEN TO WORKERS."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_register_update.md  (P0-8 row, §1)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_selection.md  (§§1-5, E-U13-pick, V2-BOX, V2-PROJ-DRAG)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_camera_projection.md  (§§1-5, V1-SENSOR, V2-PROJ, V2-BOX, V2-MINI)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_gl_perspective.md  (§§1-4, sub_4cd334, import VAs, FOV-by-focal cluster)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_minimap_tail.md  (§§1-4, V2-MINI-SCALE, V2-MINI-QUAD)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_collision_full.md  (§§1/6/7, radius/AABB/LOS context)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_fog_camera_hud.md  (camera 58/−32/400 pins, IMPL-COLLISION-CALLERS/IMPL-FOG-PATCHES ownership)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_decisions.md  (§8, P0-8)
---

# PORT1TO1 — selection / projection owner-only experiment packet (P0-8)

> **Required reviewer line, verbatim:**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> **P0-8 remains open.** Pick distance units, `SortRayCastList` order, engine AABB, FOW veto, sensor→FOV, near/far/aspect, drag geometric anchor, marquee inside-test, minimap affine + frustum quad are all `[U]`. Port `FOV 17.27°`, `NEAR_M=0.1 / FAR_M=4096`, screen-UV bias, `cull_disabled`, nearest-single, depth tie-break and press-vs-first-move dual model are all retained as **PORT APPROXIMATION / scaffolding** and camera match is **unasserted**. This packet invents **no** FOV, near, far, sensor width, marker coordinate, or projection number. All numeric literals below are carried `[O]` from the cited DEC reports, never derived here.

> **Donor runtime forbidden for workers.** Every `RUNTIME-GPU` step in §§1-7 runs only in an owner-authorised donor GPU/GL-trace/debugger session (or not at all). Workers perform no donor execution, no GPU capture, no gate, no port comparison. `parity.claim = NONE`, `parity.status = UNVERIFIED`, `visual_parity_claim = false`.

---

## 0. What this packet settles and what it does not

1. This packet is an **ordered owner-only run-book** for P0-8 (`PORT1TO1_u_register_update.md:67`). It closes nothing by itself; each sub-experiment closes only when its §8 zero-mismatch criterion is met with **0 mismatches** on the stated repeats.
2. Static facts used as setup (camera pins, script chain, native VAs, priority integers, `(1+dist)/prio` shape, panel defaults) are `[O]`/`[D]` with file:line or VA + evidence id. Every numeric behaviour (sensor, FOV, near/far/aspect, units, order key, AABB rule, anchor, inside-test, affine, quad) stays `[U]` until its capture terminates.
3. **No FOV/near/far/marker invented.** Where the task brief or prior reports quote port-side numbers (`17.27°`, `0.1/4096`, `216/36/121.4`, `0.0001f @ 0x8f4dec`, `100.0f/2.0f/1.0f`), they are labelled here exactly as there: port derivation / observed table constant, never donor fact. Surveyed marker coordinates are **owner-placed at run time**; no coordinates are asserted in this packet.

---

## 1. Fixed rig (common to E-U13, V1-SENSOR, V2-PROJ, V2-DRAG, V2-BOX, V2-MINI)

Owner sets once, holds for the whole session; any camera/map change voids the frame set.

- Map: flat area, fixed seed (owner records seed; seed value itself is run metadata, not donor fact).
- Camera: gameplay rig `58 / −32° / focal 400` (`data\cameras\camera.cfg:6-10,32-35,44-45` via `DEC_U_camera_projection.md:52-54`); `Min/MaxFocalLength=400`, `FocalLengthPower=1.0` (zoom fixed); FOW **off** except where the probe says on; singleplayer skirmish; no camera move between probes within a battery.
- Viewport: fixed window size for the whole session; owner logs `GetViewerWidth/Height` per capture (DPI arm `scale=2 iff ViewerHeight>1535 else 1` per `DEC_U_minimap_tail.md:49` stays `[O]` law, applied at analysis).
- Markers: owner-surveyed world markers (units / ground points) with known separations along one view ray; **no coordinates are pinned by this packet** — the owner logs `GetGameObjectPos` / `GetCurrentMouseWorldCoord` per handle per probe.
- Logging per probe: `GetCameraAbsolutePosition` (cPos), `GetCurrentMouseWorldCoord` (mPos), `GetGameObjectRayCastCount` + order after `SortRayCastList`, per-handle `prio` branch taken, computed `(1+dist)/prio`, returned handle, `GetCountGameManagerPickedObjects` membership (drag), `GameManagerIsSelectionMode` onset frame (drag), panel screenshot + `GetGUIMiniMapPosition/Width/Height` (minimap).
- Port stays untouched during the session: `FOV_DEG_ASSUMED=17.27`, `NEAR_M=0.1/FAR_M=4096`, depth tie-break, `Rect2.has_point` centroid-in, dual-anchor model all keep their `PORT APPROXIMATION` tags until §8 closes.

---

## 2. Projection matrix dump — `gluUnProject` VA `0x907b74`, `sub_4cd334`, `GetCameraFieldOfView @0x5fece6` (V2-PROJ + V1-SENSOR)

### 2.1 Carried static facts `[O]` (setup only, no numeric law)

- GL imports resident: `gluPerspective @ 0x90a6b8` (`.idata`; listing-scope twin `0x907b84`), `glFrustum @ 0x90aaf4` (twin `__imp @ 0x907c98` + thunk `@ 0x4afd04`), `glOrtho @ 0x90a9c6` (twin `0x907c48` + thunk `@ 0x4afda4`), `glViewport` (CODE sites `0x4b8688/9c/b0` + `.idata 0x90ac18`; twin `0x907cec` + thunk `@ 0x4afc5c`), `glMatrixMode @ 0x90aa1a`, `glLoadIdentity @ 0x90aa62`, **`gluUnProject @ 0x90a67e` (`.idata`; twin `0x907b74`)**, `glMultMatrixf @ 0x907c5c`, `gluOrtho2D @ 0x907b88`, `glGetFloatv` thunk `@ 0x4afbbc` (`DEC_U_camera_projection.md:72`; `DEC_U_gl_perspective.md:18-24`).
- Statically **uncalled**: `__imp_gluPerspective` 0 refs, `__imp_gluUnProject` 0 refs (`DEC_U_gl_perspective.md:24-25`). The gameplay projection is **not** `gluPerspective(fovy,…)` with a literal `fovy`; the pick ray does its own unprojection (`ScreenToWorld @ 0x69e45a`, `GameObjectRayCastMouseRay @ 0x69e422`).
- Actual setup call: **`sub_4cd334`** (`FUN_004cd334(p1,p2,w,focalArg,p5,h)`), 114-line Ghidra pseudo-C (`ev_030dff8c…`); mode byte `*(p1+200)`: `0x02→gluOrtho2D (@0x4cd38c)`, `0x03→script callback`, `0x00→glFrustum (@0x4cd626)`, `0x01→glOrtho (@0x4cd771)`, `0x04→glMultMatrixf-custom (@0x4cd723)`; frustum bounds from `w/h`, struct floats, `100.0f @ 0x4cd780`, `2.0f @ 0x4cd784`, `1.0f @ 0x4cd794`, `0.0001f @ 0x8f4dec` (DATA, custom-matrix path only — **not** a near plane); `m=max(w,h)` normalisation, per-axis focal scale via `*(p1+0xcc)` vs `*(p1+0xd0)` (`DEC_U_gl_perspective.md:80-82,92`).
- Viewport caller: `sub_5d1c60` (`glClear→glViewport→glMatrixMode→glPushMatrix→glLoadIdentity→sub_4cd334→glMatrixMode`; `w=*(p1+0x44)`, `h=*(p1+0x48)`, refreshed on window-size change); exactly 2 callers of `sub_4cd334`: `sub_5d1c60 @ 0x5d1ddb`, `sub_777c80 @ 0x777cc1` (`DEC_U_gl_perspective.md:92`).
- FOV-by-focal cluster: `GetCameraFieldOfView @ 0x5fece6` + `ByFocalLength @ 0x5fecfa (+0x14)` + `FieldOfView` tails `@ 0x5fecef/0x5fed68`, all inside `sub_5fc2d0` (dispatch/blob region; lifter output is string-bytes, not control flow); `MinFocalLength @ 0x7abf68` (1 data ref `0x7aba11` in `sub_7ab704`); `FocalLength` 16-hit CODE family; `DepthOfView` 8-hit CODE family (gameplay `1200`, debug `50` in text); `NearPlane` CODE bytes `@ 0x4c8590/0x4c85be` (no value); `FarPlane` 0 hits; `Sensor/SensorWidth/FilmGate` 0 hits; `Aspect` 9 CODE name hits, no literal (`DEC_U_gl_perspective.md:63-66,86-87`).
- Thin-lens relation (only law, `[D]`): `FOV_v = 2·atan(sensor_h/(2·f))`, `f=400`, `FOV_v = 2·atan(tan(FOV_h/2)/a)`. Port `17.27°` is the 16:9 vertical of a 216 mm-wide sensor and stays **PORT APPROXIMATION**; `121.4`, `36 mm / ≈2.90°`, `0.1/4096` are likewise never donor facts (`DEC_U_camera_projection.md:64`).

### 2.2 Owner run V2-PROJ (+V1-SENSOR, V2-PROJ-NF, V2-PROJ-ASPECT)

1. Hook/log (owner-authorised GL trace + debugger): break `sub_4cd334` entry/exit — dump mode byte `*(p1+200)`, `(w,h)`, `focalArg`, `p5`, struct floats `+0xac/+0xa0/+0xcc/+0xd0`, computed frustum bounds, and which of the 5 paths fires (`glFrustum`/`glOrtho`/`gluOrtho2D`/`glMultMatrixf`/callback). Break `GetCameraFieldOfView[@0x5fece6]`/`ByFocalLength` — dump input focal + returned value (law recovery, not literal adoption). History the whole-frame `glViewport/glMatrixMode/glLoadIdentity/glPushMatrix/glMultMatrixf` sequence from `sub_5d1c60`.
2. Re-project battery: re-project ≥5 surveyed ground points through the fitted matrix; compare with captured integer pixels (same viewport, same 58/−32/400 rig).
3. Clip battery: push a marker to either side of the `DepthOfView=1200` hypothesis (owner-chosen either-side pair bracketing 1200; exact distances are run metadata) and observe clip-vs-render; bracket near by pushing geometry toward the eye until clip.
4. Aspect battery: same surveyed scene at ≥3 viewport aspect ratios (identical height); fit per-axis focal scale + principal point.
5. **Termination:** §8 rows V1-SENSOR / V2-PROJ-NF / V2-PROJ-ASPECT (all 0 px + exact clip prediction). No sensor/FOV/near/far/aspect literal is written as donor fact before then.

---

## 3. Screen→world drag anchor (V2-PROJ-DRAG)

### 3.1 Carried script facts `[O]`

`data\gui\menu.inc\onmousemove.inc:32-34` (epsilon `0.005`, `0.25` in attack-point/guard), `:69` (`GetCurrentMouseWorldCoord` per move), `:141-152` (two-phase: first LMB-held move freezes `prevselmousex/z`; axis-wise `|x−prevx|>eps or |z−prevz|>eps` gates `GameManagerBeginSelection` + Shift? `spmAdd` else `spmRunTime`), `onmousedown.inc LButtonUp` (`isselectionstarted:=false` + `if IsSelectionMode then CancelSelection`) (`DEC_U_selection.md:113-120`; `DEC_U_camera_projection.md:87-95`).

### 3.2 Owner run (geometric anchor still `[U]`)

Fixed rig §1. LMB press at surveyed pixel, hold, step 1–3 px across the epsilon boundary in each axis (four drag directions). Log `GetCurrentMouseWorldCoord` at press vs first-move vs each step + `GameManagerIsSelectionMode` onset frame + frozen rect corner. Requires V1-SENSOR/V2-PROJ solved first (world mapping prerequisite).
**Termination:** §8 row V2-PROJ-DRAG — onset frame + frozen corner match exactly one of (press-point, first-move-point) at `0 px / 0.0 m` on all four directions. Port keeps the dual model (`_sel_ground_start` + `_rect_ground_anchor`) until then.

---

## 4. Marquee inside predicate transects (V2-BOX)

### 4.1 Carried negative result `[O]` (the finding is that the predicate is engine-side)

No readable predicate: `GameManagerStartSelection` 0 hits, `spmFrame` 0 hits, `InitMinimap` 0 hits; marquee lives behind `Begin/Start(spmAdd|spmRunTime)/Cancel/IsSelectionMode/Clear/PickedObjects` (`Begin 0x6a03fa`, `IsSelectionMode 0x6a03c2`, `PickedCount 0x6a7cda`, `spmAdd 0x511e48/0x5125dc`, `spmRunTime 0x511e3d/0x5125c8` — all CODE-resident, function-orphaned binding-table placement). The drag path has **no** script-side per-candidate loop (contrast §5 single-click law vs `PrepareUnitUnderCursorList` collision+AABB membership only). Port `Rect2.has_point` centroid-in + four-corner ground AABB stays **PORT APPROXIMATION** (`DEC_U_selection.md:132-138`; `DEC_U_camera_projection.md:105-112`).

### 4.2 Owner run (predicate + world mapping still `[U]`)

FOW off, fixed rig §1. Grid of idle peasants at known spacing (owner-surveyed; counts/spacings are run metadata). Scripted drag rects inset/outset by 1–3 px around known units, both drag directions, all four corners; include 1-px edge cases and both drag directions. Log `GetCountGameManagerPickedObjects` membership per rect. Fit inside rule jointly with the §2 projection solve: centroid-in vs AABB-overlap vs containment fraction, edge inclusion (in vs out on the exact edge pixel), building vs unit vs res-node membership, squad-grouping side effects.
**Termination:** §8 row V2-BOX — fitted rule predicts membership of **all** probed rects including 1-px edges and both drag directions with **zero membership mismatches**.

---

## 5. `(1+dist)/prio` distance-units solve + one-pixel marker test, tie-break / `SortRayCastList` order (E-U13-pick)

### 5.1 Carried single-click law `[O]`

`control.script:156-274`: `Minimap-exit → MouseRay (0x69e422) → SortList (0x69e4be) → playable∧visible∧collisionDetection ∧ ownership ∧ RayCastAABB(cPos→mPos) (0x63153e) → per-arm prio → min (1+dist)/prio wins (strict <) → winner-only FOW veto (LOS>0)`. Priority integers `my=1/wood=2/food=3/stone=4/goinside=5/build=6/enemy=7` (`dmscript.global:227-233`); live seed `prio=0.5` survives when `pres=nil` / `pobj=nil` / mine-without-peasant-selected; food needs `brised`; buildings need can-build/absorb (+peasant for mine); enemies need `enemyMask ∧ SelectedUnitsCanAttack`. `dist=_misc_GetDistancePos(mpos,pos,False)` = **XZ-plane `VectorDistance`** (`misc.script:663-669`); `(1+dist)/prio` shape, min-wins, strict `<`, first-eligible installs (`nearestHnd=0` short-circuit) are `[O]`; `OctreeRayCast 0x62e84a/0x62e8fa` proves the octree-ray name family resident (both hits function-orphaned) (`DEC_U_selection.md:59-86`).

### 5.2 What is `[U]` (this battery settles it)

(a) Units/frame of `dist` (`mpos` engine ground point vs `pos` foot vs centre vs AABB centre; whether the `+1` is 1 m / 1 tile / 1 px bias). (b) Seed-`0.5` arm reachability (whether the AABB gate already excludes nil-handle arms). (c) `SortRayCastList` order key (ray-`t` vs depth vs AABB entry) — exact-equal `relativeDst` keeps the earlier raycast order per strict `<`. (d) `bMyPlayerOnly` pre- vs post-sort point. (e) Engine AABB inside-test (slab vs OBB vs screen-rect, expansion, return convention) — see §6.

### 5.3 Owner run (fixed rig §1, FOW off except veto probes)

Place one own peasant (prio 1), one wood node (2), one own unbuilt building (6) and one attackable enemy (7) at known world separations along one view ray so their screen projections overlap within 1–2 px at the test pixel (owner-surveyed layout; no coordinates pinned here). Per probe log: `mpos`, per-handle `pos`, `RayCastCount` + post-`SortRayCastList` order, per-handle `prio` branch taken, computed `(1+dist)/prio` with `dist` in world metres, returned `nearestHnd`. Include: (i) a constructed exact-tie (two handles at equal `(1+dist)/prio` to 1e-6 — first-in-ray-order must win); (ii) a seed-`0.5` probe (`pres=nil`/`pobj=nil` if constructible, else documented unconstructible); (iii) a **one-pixel marker test**: nudge one marker so its screen projection shifts by exactly 1 px, re-probe, and check the predicted winner flips (or holds) per the fitted distance law; (iv) FOW-on veto probes (winner inside zero-LOS must return 0); repeat every probe with no camera move.
**Termination:** §8 row E-U13 — predicted winner by the `(1+dist)/prio` min-rule with first-in-ray-order tie-break matches the returned handle on **every** probe including the exact tie, the seed-`0.5` probe (or documented unconstructible), the 1-px nudge, with **zero mismatches**, and the FOW-veto probe returns 0. Port keeps screen-px `sd` + depth tie-break labelled PORT APPROXIMATION until then.

---

## 6. Engine AABB / `OctreeRayCast` traces

### 6.1 Carried anchors `[O]`

`GetGameObjectRayCastAABBByHandle(goHnd,cPos→mPos)` call shape (two world points) `[O]` (`control.script:183-184`); native AABB `0x63153e` (CODE, function-orphaned per `DEC_U_selection.md:49`); `OctreeRayCast 0x62e84a/0x62e8fa` (CODE, function-orphaned); 12-arg `OctreeRayCastIntersect(sx,sy,sz,dx,dy,dz,px,py,pz,nx,ny,nz)` is text-only script signature, not the traced path; `PrepareUnitUnderCursorList (:278-304)` is collision+AABB membership only (no playable/visible pair, no FOW veto, no priority); LOS march calls `GetGameObjectRayCastAABBByHandle(goHnd,x1,…,x2,…)` / `CustAABB` with `y<0.05→0.05` clamp (`DEC_U_collision_full.md:41`); per-sid radius census 354/369 + centred origin `[O]`, rotation/LOS rule `[U]` (`PORT1TO1_u_register_update.md:93`).

### 6.2 Owner run

Break `GetGameObjectRayCastAABBByHandle`: dump `(goHnd, cPos, mPos)` inputs + boolean return per candidate on the §5 rig (vary candidate: infantry / cavalry / building / res-node / ship where constructible). Break the `OctreeRayCast` pair: dump ray in/out, hit handle list, and order before vs after `SortRayCastList (0x69e4be)`. Sweep AABB expansion: offset candidates 1-px steps across the ray at two depths; record include/exclude boundary per handle class.
**Termination:** §8 row E-U13-AABB — one fitted inside-test (slab/OBB/screen-rect + expansion + return convention) predicts per-candidate include/exclude on all sweeps with **zero mismatches**, and the logged pre/post-`SortRayCastList` order identifies the sort key with zero residual inversions.

---

## 7. Minimap frustum quad geometry (V2-MINI-SCALE + V2-MINI-QUAD)

### 7.1 Carried panel facts `[O]`

`minimap.cfg:1-27`: 240² panel, `halLeft/valBottom Position=(0,0,0,1)` stale default, `FrustumVisible=True`, 1 px white `LinePattern=65535` style (style node `Visible=False` ≠ frustum on), `lens.0` 40×40 UV cell = **alarm** primitive (not frustum), `pl2x2` 3 px / `pl3x3` 4 px atlas, `primitives.bmp` 16,440 B, `tmmUser/moIgnoreFog/moNoLighting/bmTransparency`; live rect is bottom-right (`ViewerW−240·scale−8`, `−8`) per `initminimap.inc` (`cMinimapSize=240`, offsets `−8`, DPI `scale=2 iff ViewerH>1535 else 1`, `SetGUIMiniMapWidth/Height/Position/Zoom(1)/Layer(3)/FrustumVisible(true)/EventMinimap`); per-unit icon law `misc.script:1137-1172` (building? `pl3x3` : `pl2x2`, `.sel` when picked, invisible→remove); resource tint law `gui.script:3488-3491` (`0.5` geology-only else `1.0`, `>0` LOS threshold shared with pick veto) (`DEC_U_minimap_tail.md:36-58,78-85,99-102`).

### 7.2 Owner run (affine + quad still `[U]`)

FOW off, full-map scenario, fixed camera §1, `SetGUIMinimapZoom(1)`. V2-MINI-SCALE: ≥6 surveyed markers spanning both axes (owner-placed); capture panel + `GetGUIMiniMapPosition/Width/Height`; fit `u=sx·x+ox`, `v=sz·z+oz` (separate x/z scales); repeat above/below ViewerHeight 1535 (DPI arm) and on a non-square map. V2-MINI-QUAD: 4 widely separated camera poses; per pose capture panel + log 4 engine corners (via `GetCameraFrustumQuadrangle` where exposed at `classes.script:6013-6050` — sound consumer only, never cited as minimap source — else surveyed ground markers at rendered quad vertices); include a map-edge-clipped pose; needs §2 projection solved first.
**Termination:** §8 rows V2-MINI-SCALE / V2-MINI-QUAD — ≥5 surveyed world corners map to panel pixels at **0 px** (both DPI arms, byte-identical repeat) **and** all 4 stroked frustum edges coincide with the captured white box at **0 px** (×8 audit) in all 4 poses incl. edge clip.

---

## 8. Zero-mismatch termination criteria (all must pass; one failure keeps P0-8 open)

| # | Battery | Pass criterion (zero-mismatch; "close" never counts) | Repeats |
|---|---|---|---|
| T1 | V1-SENSOR | Fitted sensor/projection re-projects **≥5 surveyed ground points to captured integer pixels with 0 px mismatch** (same viewport, same 58/−32/400 rig); vertical vs horizontal cross-checked; focal-100 debug camera as 2nd equation | All points × 2 depths + debug cam |
| T2 | V2-PROJ-NF | Same ≥5 points **0 px** through the fitted matrix **and** the near + far clip boundary predicted exactly (far hypothesis `DepthOfView=1200` bracketed either-side; near bracketed to eye) | ≥5 points + either-side clip pair each end |
| T3 | V2-PROJ-ASPECT | One matrix family re-projects ≥5 surveyed points at **every** probed aspect with **0 px mismatch** | ≥3 aspects |
| T4 | V2-PROJ-DRAG | Onset frame + frozen rect corner match exactly one of (press-point, first-move-point) at **0 px / 0.0 m** on **all four** drag directions (1–3 px epsilon-crossing steps) | 4 directions, no camera move |
| T5 | V2-BOX | Fitted inside rule predicts membership of **all** probed rects incl. **1-px edge cases and both drag directions** with **zero membership mismatches** | Full rect set |
| T6 | E-U13 pick | Predicted `(1+dist)/prio` min-rule winner + first-in-ray-order tie-break matches returned handle on **every** probe incl. constructed exact tie (1e-6), seed-`0.5` probe (or documented unconstructible), **1-px marker nudge**, with **zero mismatches**; FOW-veto probe returns 0 | Every probe; FOW on/off pair |
| T7 | E-U13-AABB | One fitted AABB inside-test predicts per-candidate include/exclude on 1-px sweeps at two depths with **zero mismatches**; pre/post-`SortRayCastList` logs identify the sort key with zero residual inversions | All handle classes × 2 depths |
| T8 | V2-MINI-SCALE | Fitted affine maps ≥5 surveyed corners to panel pixels at **0 px** on both DPI arms + byte-identical repeat | All markers × 2 DPI arms × 2 runs |
| T9 | V2-MINI-QUAD | All 4 stroked frustum edges coincide with the captured box at **0 px** (×8 audit) in all 4 poses incl. map-edge clip | 4 poses |
| T10 | Session integrity | Fixed rig §1 held (no camera/map/viewport change within a battery); every probe logs cPos/mPos/count+order/prio/score/handle/membership per §§1-7; any gap, missing dump, or camera move voids the frame set | Whole session |

No FOV, near, far, aspect, sensor width, marker coordinate, score, order key, AABB rule, anchor, inside-test, affine or quad number is written as donor fact until its row above passes. Port approximations stay tagged until then.

---

## 9. Outcome → port change (owner/COORD applies after §8; this worker writes no code)

Paths are `variant3d/scripts/…`; line numbers are current-file anchors — re-verify at apply time. Each change fires **only** on its stated §8 row; otherwise the port keeps the listed scaffolding.

| # | Port site (current `[O]`, approximation kept) | Fires on | Donor-faithful replacement |
|---|---|---|---|
| C-1 | `camera3d.gd:97-113,200-229,288-310` + `config.gd:72-76,109-121,461-464,508-517` (`FOV_DEG_ASSUMED=17.27`, `NEAR_M=0.1/FAR_M=4096`, `fov_deg=17.27` default) | T1+T2+T3 | Replace the constant + getter default and `NEAR_M/FAR_M` with the fitted values in the **same** files; keep the `PORT APPROXIMATION` comment until that moment. Never write sensor widths (`216/36/121.4`), `0.0001f`, or `100/2/1.0f` table constants as donor facts. `_apply_transform()` gains the fitted frustum law (`sub_4cd334` mode + per-axis focal scale); `jump_to_world_donor_offset()` `cot(32°)` stays APPROXIMATION until the pitch-order probe in T2 closes it. |
| C-2 | `camera.gd` 2D mirror (58/20/−32/400 pins) | T1+T2+T3 | No FOV/sensor/near/far edit (2D consumes height pins only). V2-PROJ matrix result lands in `camera3d.gd` only. |
| C-3 | `picking3d.gd:88-107,358-376,449-463` + `input_controller.gd:771-816` (prio/score/veto) + `game.gd:917-925` eligibility | T6+T7 | Thread the `0.5` seed through `_donor_prio` (`pres=nil`/`pobj=nil`/mine-without-peasant keep `0.5`, not `0`); switch `d` from screen-px to donor XZ metres (mpos ground hit vs entity `pos` foot/centre per verdict); add mine `peasantselected` + `UnitsCanBuild` gatings; keep `BODY_LIFT_M/TIE_PX/FALLBACK` labelled APPROXIMATION until T6; replace 8-corner `has_point` AABB-screen-rect with the fitted slab/OBB/expansion rule on T7; conform per-candidate veto to winner-only iff T6 shows membership changes. |
| C-4 | `game.gd:929-941 dec_u_pick_aabb` + `picking3d.gd:287-305` | T7 | Expand the table beyond `eurmil`/fallback only from per-`.prop` AABB reads (never `block_r`); swap in the fitted inside-test. |
| C-5 | `input_controller.gd:57-71,271-288,645-742,850-903,1019-1021,1107,1139-1154` (dual anchor, `_drag_world_rect`, `_apply_rect_selection`, epsilon/mode/teardown) | T4+T5 | Collapse the dual model to the winning anchor in `_drag_world_rect` only; swap the inside rule in `_apply_rect_selection` only; keep epsilon/mode/teardown and `Begin→Start(spmRunTime)→Picked→Cancel-once` + squad mirror unchanged. `SelectionRectPainter` keeps its tag until T5. |
| C-6 | `hud.gd` minimap box/blips + `hud3d_adapter` quad + `world3d_fog.gd` ladder | T8+T9 | Wire `stroke_minimap_quad` only after T9; forward affine never derived by inverting the click path; resource `0.5/1.0` blend stays resource-icons-only; fog ladder + never-seen dim stay APPROXIMATION until the tint battery (outside P0-8) closes. |
| C-7 | Explicit non-changes | — | `game.gd` save/tick, `ai.gd`, FOW grid/combine, `world3d` water, `config.gd` selection/hud keys take **no** edit from this ticket. |

---

## 10. Claim register (audit-level; no parity)

| # | Claim | Label |
|---|---|---|
| 1 | P0-8 stays open; port FOV 17.27° is PORT APPROXIMATION and camera match is unasserted | [D] `PORT1TO1_u_register_update.md:67`; `DEC_U_camera_projection.md:64` |
| 2 | Single-click chain, priority integers 1..7, seed 0.5, XZ metric, `(1+dist)/prio` min-wins strict-`<`, winner-only FOW veto, drag two-phase/epsilon/mode strings, panel 240²/alarm-lens/icon laws are script-side `[O]` with file:line | [O] `DEC_U_selection.md:59-90,113-120`; `DEC_U_camera_projection.md:87-107`; `DEC_U_minimap_tail.md:36-58,78-85,99-102` |
| 3 | `gluPerspective/gluUnProject` import slots (`0x90a6b8/0x907b84`, `0x90a67e/0x907b74`), `glFrustum/glOrtho/glViewport/glMatrixMode/glLoadIdentity/glMultMatrixf/gluOrtho2D` imports, `sub_4cd334` 5-path setup, `sub_5d1c60` viewport caller, `GetCameraFieldOfView[@0x5fece6]/ByFocalLength[@0x5fecfa]` cluster, `MinFocalLength@0x7abf68`, `NearPlane` CODE bytes, `FocalLength/DepthOfView/Aspect` CODE families, `Sensor/FilmGate/FarPlane` negatives are native `[O]` with VAs + evidence ids | [O] `DEC_U_camera_projection.md:15-24`; `DEC_U_gl_perspective.md:17-36` |
| 4 | Sensor→FOV, near/far/aspect numerics, `dist` units, seed-arm reachability, `SortRayCastList` key, `bMyPlayerOnly` point, engine AABB test, drag geometric anchor, marquee inside-test, minimap affine + frustum quad are `[U]` with the §8 zero-mismatch batteries above | [U] this packet §§2-7, §8 T1–T9 |
| 5 | `MouseRay 0x69e422 / SortList 0x69e4be / AABB 0x63153e / Begin 0x6a03fa / PickedCount 0x6a7cda / spmRunTime 0x511e3d+0x5125c8 / spmAdd 0x511e48+0x5125dc / OctreeRayCast 0x62e84a+0x62e8fa / GetCameraAbsolutePosition 0x5fcbaa / GetCurrentMouseWorldCoord 0x66daa2 / ScreenToWorld 0x69e45a / ArcTan 0x60a8c6 / GetGUIMinimapUnderMouse 0x66db22` resident in CODE; AABB/Octree/spm/FOV-cluster hits function-orphaned (binding-table placement, never a call graph) | [O] cited DEC §§0 |
| 6 | No FOV, near, far, sensor width, marker coordinate, score, order key, AABB rule, anchor, inside-test, affine or quad number invented in this packet | [O] scope guard + §§0/8 |
| 7 | No donor binary executed, no GPU frame captured, no gate/runner job launched, no port capture compared by this worker; donor runtime forbidden to workers, owner-authorised only | [O] subagent context |
| 8 | `parity.claim = NONE`, `parity.status = UNVERIFIED`, `visual_parity_claim = false`; no metric, still, replay pair or "close" value promotes parity | [D] register §§1/6 |

---

> **Verdict (verbatim governing form):** `port=UNVERIFIED`; `parity.claim = NONE`; `parity.status = "UNVERIFIED"`; `visual_parity_claim = false`; `blocking_unverified` non-empty (P0-8 among P0-1…P0-8 plus §2 tails). **`RESULT IS NOT GOOD`.** No same-camera donor/port A/B frame exists; no approximation is authorised; no parity claim is made.

*End of PORT1TO1_selection_owner_protocol. Read-only; exactly one repository file written; no source/asset/config/test/runner/Godot/git/donor-execution; parity UNVERIFIED; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty.*
