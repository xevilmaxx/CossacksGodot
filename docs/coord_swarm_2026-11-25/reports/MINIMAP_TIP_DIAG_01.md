---
id: MINIMAP-TIP-DIAG-01
title: "MINIMAP-TIP-DIAG-01 — donor minimap click: viewport-center vs cursor-arrow-tip (read-only diagnosis)"
owner: MINIMAP-TIP-DIAG-01 (donor-primary diagnosis worker)
date: 2026-11-25
status: DIAGNOSED__DONOR_TEXT_DERIVED__ENGINE_SIDE_UNVERIFIED__NO_AB
scope: "Diagnosis only. Donor READ-ONLY (private-use copy, Python bytes + latin-1, never executed/copied). No code edit, no config/test edit, no runner job, no gate, no ladder. One new file: this report."
labels: [observed, derived, inferred, UNVERIFIED, PORT_APPROXIMATION]
verdict: "DONOR TEXT: camera target = clicked GUI point + boom offset (NOT the clicked point); the clicked arrow-tip point is deliberately displaced from the viewport center. PORT: plain jump_to_world() and the 2D branch center the clicked point; the 3D primary click already applies a labelled PORT APPROXIMATION of the donor offset. Exact screen landing of the donor point is engine-side UNVERIFIED — no donor A/B, no parity claim."
---

# MINIMAP-TIP-DIAG-01 — donor minimap click: center vs arrow tip

## 0. Question and boundaries

Owner report (verbatim): *"click on minimap is not on point of the arrow; it is in center. We need it on tip of the arrow cursor."*

Task: decide whether a **donor** minimap click lands the clicked world point at the viewport center or at the tip of the on-screen arrow cursor, and identify where the port centers vs offsets.

Boundaries held: donor files opened only as raw bytes decoded latin-1 (`python` 3.14, private-use copy at `C:\Games\Cossacks 3`); no donor execution, copy or unpack. No repository source/config/test edited. No Godot process, no runner job. Labels: **observed** (literal file bytes/lines), **derived** (arithmetic/control-flow consequence of observed lines), **inferred** (plausible reading with caveat), **UNVERIFIED** (needs donor run or binary RE). **No donor parity is claimed anywhere in this report.**

## 1. Sources read (all read-only)

### 1.1 Reports / audits (repo)

| Source | Use |
|---|---|
| `docs/coord_swarm_2026-11-25/reports/MMJUMP_01_minimap_jump.md` `:1-133` | Conflict history; donor transcription; "two explicit APIs" recommendation; `ArcTan` UNVERIFIED |
| `docs/coord_swarm_2026-11-25/reports/MMJUMP_02_minimap_jump.md` `:1-204` | Current implementation state: separate `jump_to_world_donor_offset()` API; `jump_to_world()` byte-identical; no donor A/B |
| `docs/coord_swarm_2026-11-25/reports/DSEL_02_donor_pick_math.md` §F `:209-222`, divergences `:247`, Q1/Q5 | Canonical helper transcription; `78.42125/49 = 1.60043` vs `cot(32°) = 1.60033` |
| `docs/coord_swarm_2026-11-25/decomp/DEC_07_cameras_shaders.md` §5.5 `:725-737`, §5.4 `:704-723`, §6 `:765-795`, §8 `:827-845` | Helper is **active** (corrects DEEPDEC-01 E26); `ArcTan`/`VectorRotate*` UNVERIFIED; bookmark is an offset encoding |
| `docs/coord_swarm_2026-11-25/reports/CAM_RV_01_view_rect_runtime.md` `:15-90` | Confirmed job 381 = 20/20; `jump_to_world(Vector2(64,64))` setup — the dependency protected by keeping that method unchanged |
| `docs/coord_swarm_2026-11-25/reports/HUD_01_minimap.md` `:1-126` | 240×240 bottom-right HUD geometry; jump explicitly left open; `ArcTan` UNVERIFIED (Q5) |
| `docs/coord_swarm_2026-11-24/reports/G31_donor_3d_truth.md` `:1-60`, `:225-263` | Donor 3D truth: perspective focal 400, tilt −32°, yaw UNVERIFIED, no ortho branch |
| `docs/audit/RENDER_ARCH_CAMERA.md` `:79-108`, `:126-167`, `:195-245` | Bookmark/target semantics; perspective; 2D→3D minimap seam |
| `docs/coord_swarm_2026-11-24/reports/DEEPDEC_08_ui_minimap.md` §2 `:88-155` | Click chain; "port centres / donor keeps offset"; `movearrow` X/Y usage |
| `docs/coord_swarm_2026-11-25/SWARM_BOARD.md` `:411-420` | Ticket boundary; parallel MINIMAP-TIP-01 owns the actual cursor-tip mapping fix |

### 1.2 Donor files — fresh byte read this session (latin-1, never executed)

| Donor path | Lines read | Result |
|---|---|---|
| `data\scripts\lib\control.script` | `570-670`, `405-425`, `667-760` | Active helper at `:574-613`; `_control_MoveCameraToPosition` `:618-665`; `_control_CreateMoveArrow` `:409-418`; `_control_MoveCameraToUnitsListCenter` `:669-686` |
| `data\gui\menu.inc\onmousedown.inc` | `100-140`, `600-640` | Minimap branch `:116-131`; `movearrow` X/Y assignment `:617-624` |
| `data\gui\menu.inc\eventminimap.inc` | full `1-66` | Tag 10/20/30, X/Y read, `ExecuteState('OnMouseDown')` |
| `data\gui\menu.inc\initminimap.inc` | full `1-62` | 240×240, bottom-right −8/−8, zoom 1, frustum on, `SetGUIEventStateOnPressMiniMap('EventMinimap')` |
| `data\cursors\cursors.lib` | full `1-297` | `UseIconCursors = True`; per-cursor `SpotX/SpotY` hotspots |
| `data\gui\menu.inc\doupdatecursor.inc` | full `1-110` | Cursor selection over GUI vs world |
| `data\gui\common.inc\onmousewheel.inc` | `30-75`, `296-303` | Independent zoom use of the same `ArcTan`/boom math (cross-check) |
| `data\scripts\dmscript.global`, `data\animations\acl\acl.lib`, `data\actors\misc\movearrow.actor`, `data\materials\misc\misc.mat` | targeted grep | `movearrow` is an in-world 3D actor/mesh/material, not a 2D HUD sprite |

### 1.3 Port files — read only

| Port path | Lines |
|---|---|
| `variant3d/scripts/camera3d.gd` | `1-80`, `240-309`, `420-594` |
| `variant3d/scripts/hud.gd` | `205-229`, `1580-1669` |
| `variant3d/scripts/hud3d_adapter.gd` | `1-230` |
| `variant3d/scripts/input_controller.gd` | `355-389`, grep of call sites |

## 2. Donor derivation

### 2.1 The active helper — exact body (`control.script:574-613`)

The procedure is **not** prefixed `[*] = ;` — it is active donor-authored text (**observed**; agrees with `DEC_07` §8.2 correction and `MMJUMP-02` §2):

```
574 procedure _control_GetMoveCameraToPositionOffset(dstX, dstZ : Float; var newX, newZ : Float);
...
581   ParserLoadFromFileByHandle(pCamera, '.\data\cameras\camera.cfg');
584   minHeight := RestrictInfo.SphereLengthMin          (= 20, camera.cfg:10)
585   maxHeight := RestrictInfo.SphereLength             (= 58, camera.cfg:9)
586-589  four FreeRotationInfo angle slots               (= -32 each, camera.cfg:32-35)
591-593  CameraInfoSaveFromCurrentView('@movecamera');
         CameraInfoReadProperties('@movecamera', tx, height, tz, cx, cy, cz);
595   angleZ := -Lerp(-32,-32, Clamp((height-20)/(58-20),0,1)) = +32
596   dx := cx - tx            // "vector rotate doesnt change this value, cause of RotateX"
597   dy  (uninitialised local, filled by :599)
598-599  dz := 0.1; VectorRotateX(dx, dy, dz, angleZ)
601-602  offX (uninitialised); offZ := ArcTan(angleZ) * height
605-607  angleX := VectorAngle(0,0,1, dx,0,dz); if dx<0 then angleX := -angleX
608-609  tmp; VectorRotateY(offX, tmp, offZ, angleX)
611-612  newX := dstX + offX + dx;  newZ := dstZ + offZ + dz
```

### 2.2 Caller chain (donor text; liveness of `.inc` UNVERIFIED)

- `eventminimap.inc:4-7` reads `X`/`Y` from the GUI event; `:8-18` (press), `:26-34` (repeat/drag), `:37-44` (release) set `Tag = 10/20/30` and `ExecuteState('OnMouseDown')` (**observed**, all lines commented `[*] = ;`).
- `onmousedown.inc:116-131`: `if (GetGUIMinimapUnderMouse)` → `x := GetIntValueByName('X')`, `y := GetIntValueByName('Y')`; `if bDouble` → `_control_MoveCameraToPosition(x,y,0,False)` (`:121-122`); **else** `SetCameraElasticTargetObject(0)` (`:126`), `_control_GetMoveCameraToPositionOffset(x,y,newx,newy)` (`:128`), `SetMainCameraRotateToTargetDir(false)` (`:129`), `SetMainCameraMoveToTargetXZ(newx,newy)` (`:130`) (**observed**, commented).
- `initminimap.inc:5-7,29-39`: 240×240 minimap, right/bottom −8, `SetGUIMinimapZoom(1)`, `SetMiniMapFrustumVisible(true)`, `SetGUIEventStateOnPressMiniMap('EventMinimap')` (**observed**, commented).
- The single-click/double-click split and the `ArcTan`-based offset are therefore donor-authored but only the `control.script:574-613` helper is uncommented. **Runtime liveness of the `.inc` caller chain is UNVERIFIED** (`DEC_07` §8.1; `MMJUMP-02` §8).

### 2.3 The exact world point written by the helper — **derived**

With all four tilt slots equal to −32 (`camera.cfg:32-35`), the `Lerp/Clamp` at `:595` is a constant, so `angleZ = +32` **for every height in [20,58]** (**derived** from observed literals; no runtime evaluation). At port yaw 0 the heading rotation is the identity, so:

```
dx      = cx - tx                       (current eye/target X offset)
dz      = 0.1 * cos(32°)                ≈ 0.0848 m
offZ    = ArcTan(32°) * height          ≈ cot(32°) * height = height / tan(32°)
target  = dst + (offX + dx, offZ + dz)  ≈ (clickX, clickZ + 1.60033·h + 0.0848)
```

**Label on `ArcTan`: UNVERIFIED.** No donor script defines it; the EXE only declares `function ArcTan(const val: Float): Float` (DEEPDEC-08 `:130-133`, `DEC_07` §5.5). The donor bookmark `default.cameras:5-10` (`TargetZ = 78.42125`, `TargetY = 49`) yields `78.42125/49 = 1.60043` — 0.0062 % from `cot(32°) = 1.60033`. Treating `ArcTan` as cotangent is a **PORT APPROXIMATION / UNVERIFIED**, never a donor literal (`DSEL_02` Q1; `DEC_07` §10 Q1).

Numerics (**derived**, using the PA):

| height h | `offZ = h/tan32` | `+ dz` | total forward displacement |
|---:|---:|---:|---:|
| 20 m (min) | 32.00 m | 0.0848 | ≈ 32.09 m |
| `sqrt(20·58) = 34.06 m` (seeded mid) | 54.50 m | 0.0848 | ≈ **54.59 m** |
| 58 m (max) | 92.82 m | 0.0848 | ≈ 92.91 m |

The double-click twin `_control_MoveCameraToPosition` (`:618-665`) writes the same construction explicitly at `:662`: `CameraInfoSaveWithProperties(name, dstX+offX, height, dstZ+offZ, dstX+offX+dx, height+dy, dstZ+offZ+dz)` — i.e. first triple = "target", second triple = "camera" = target + `(dx,dy,dz)` with `|(dx,dy,dz)| ≈ 0.1` (**observed**; the bookmark `PosY/PosZ ≈ (0.1 sin32, 0.1 cos32)` corroborates, `DEC_07` §6). Engine-side interpretation of which triple is the eye and which is the look-at focus is **UNVERIFIED**.

**Crucial derived consequence:** the helper does **not** write the clicked GUI point into the camera target. It adds a displacement whose dominant term is the camera's boom length `cot32·h`. Therefore, at script level, **the donor does not centre the clicked point**; the clicked point and the camera target differ by ~32–93 m depending on zoom.

### 2.4 Which point is the "arrow tip"?

Two distinct arrow notions exist in donor text; both are reported and neither is asserted as the owner's without caveat:

1. **GUI cursor arrow.** `cursors.lib:2` `UseIconCursors = True`. `crDefault` is a 32×32 icon with **`SpotX = 0`, `SpotY = 0`** (`cursors.lib:5-12`) — the hotspot is the top-left icon pixel, i.e. the arrow's point. Other cursors carry their own hotspots (`crAttack` 2/3 `:121-122`, `crWait` 15/15 `:209-210`, `crCaptureAttack` 2/8 `:236-237`). `doupdatecursor.inc:4,6-12,104-106` starts with `cursor := 'crDefault'` and only switches to attack/guard/etc. when `GetGUIElementUnderMouse = 0`; **over a GUI element such as the minimap the cursor stays `crDefault`** → hotspot (0,0) = arrow tip (**derived**). The GUI event `X/Y` consumed at `onmousedown.inc:119-120` are the cursor position, i.e. the arrow-tip pixel; DEEPDEC-08 `:142-144` states these are already sim metres when used as `dstX/dstZ`. **UNVERIFIED:** the engine's exact GUI-pixel→event-value conversion and any hotspot-to-event offset (`DSEL_02` Q5).
2. **In-world move arrow.** `onmousedown.inc:617-624` sets `gfloat_gui_movearrowx/z := GetIntValueByName('X')/('Y')` when `GetGUIMinimapUnderMouse`, else `GetCurrentMouseWorldCoord(...)`; `:869` calls `_control_CreateMoveArrow(gfloat_gui_movearrowx, gfloat_gui_movearrowz)`; `control.script:409-418` creates a real 3D actor at `(x, RayCastHeight(x,z), z)`. The arrow is a mesh/material (`movearrow.actor`, `misc.mat:32-33`), not a HUD sprite. Whether the owner's "arrow" is this marker or the GUI cursor is an **open question**.

Either way, `dst` in the helper **is** the arrow-tip world point: it is the coordinate under the cursor at click time. The donor then displaces the camera target away from it by `cot32·h`. Whether that displacement places the clicked point at some specific *screen* position ("tip") or at the viewport center depends on `SetMainCameraMoveToTargetXZ` semantics, which are **UNVERIFIED** (no donor run, no binary RE of that API in this ticket).

### 2.5 Independent donor cross-check (wheel zoom)

`onmousewheel.inc:35-67` (commented) uses the same primitives: `dstZ = tz + ArcTan(-angleZ)*oldHeight` (`:56`), `offZ = ArcTan(angleZ)*height` (`:60`), `newx/newy = dst+off+dx/dz` (`:66-67`), and `:68` compares the result against `(cx,cy,cz)`. This confirms the offset is a **boom-length compensation** used consistently by zoom and jump, i.e. a camera-rig quantity rather than a screen-space cursor correction (**derived**). It also means the "offset" cannot be dismissed as a typo in the minimap helper.

## 3. Port mapping trace — where a click is centered vs offset today

| Step | File:line | Behaviour | Label |
|---|---|---|---|
| Minimap UV → world | `hud.gd:1605-1606` | `mp = minimap_rect.get_local_mouse_position()/size`; `world_pos = Vector2(mp.x*MAP_W, mp.y*MAP_H)*TILE_M` → SIM metres | observed (port) |
| 3D branch dispatch | `hud.gd:1611`, `1635-1645` | `_minimap_jump_3d` consumes LMB press/drag; `set_input_as_handled()` only on success | observed |
| Primary 3D jump | `hud.gd:1647-1658`, call at `:1657` | `_cam3d_jump` calls **`jump_to_world_donor_offset(world_pos)`** (guard at `:1649-1650`) | observed |
| Plain centre API | `camera3d.gd:444-452` | `_target = world_pos` → `_apply_transform()` → `mark_external_transform()` → `clamp_pos()`. **Screen centre = `_target` ground point** because `_apply_transform` does `look_at(base)` with `base = _target − map_half` (`:264-282`) | observed + derived |
| Donor-offset API | `camera3d.gd:560-586` | `off_z = h/tan(32°)` (`:572`), `dz = 0.1 cos32` (`:570`), `angle_x = atan2(dx,dz)` with dx<0 flip (`:575-577`), `new_target = world_point + (off_x+dx, off_z+dz)` (`:581`), then `:583-586` | observed |
| Result of the primary 3D click | `camera3d.gd:581,583` + `:277-282` | Screen centre becomes `world_point + ≈(0, 54.59 m)` at seeded height; **the clicked point is `off_z` toward the camera from the screen centre** — not centered. At port FOV this displacement is large; whether it is visible/on-screen needs runtime measurement (UNVERIFIED) | derived |
| Fallback 3D reposition | `input_controller.gd:355-362`, `:367-385`, call at `:377` | `_minimap_world` maps screen→SIM identically; 3D branch calls **plain `jump_to_world(wp)`** → clicked point **centered** | observed |
| 2D branch | `hud.gd:1616-1619`, `:1625-1628` | `cam.global_position = world_pos * view_scale` → clicked point **centered** | observed |
| World→minimap | `hud3d_adapter.gd:103-137` (`get_minimap_corners`), half-map shift `:122-127`; box `:73-94` | Four ground corners → minimap image pixels; AABB for the painter | observed |
| Screen→world | `hud3d_adapter.gd:210-219` → `camera3d.gd:296-305` | Forward-only screen px → ground metre; no separate minimap→world helper (that mapping lives in `hud.gd:1605-1606` and `input_controller.gd:360-362`) | observed |

**Hashes (fresh, this session):** `camera3d.gd:444-452` `jump_to_world()` = **701 bytes**, SHA-256 `565fdca189f7b2e8f22720617644a44e2804edfc0b6636b958432283ddb8db3d` in both the live file and `inbox/backup/camera3d.gd.bak-MMJUMP02` — byte-identical, so CAM-RV-01's 20/20 setup (`CAM_RV_01` `:62`; `t_view_rect_rv.gd:232,377-385,420-423`) is undisturbed.

**Citation drift note:** concurrent swarm edits landed in `hud.gd` during this diagnosis (the file is modified in the working tree by other owners). All `hud.gd` line numbers below are the **current** ones re-verified at the end of the session; they were +6 lower when first read (e.g. `_on_minimap_input` was `:1598`, now `:1604`). `camera3d.gd` line numbers and the `jump_to_world()` hash are unchanged.

**Interpretation of the owner's "it is in center":** the centering paths still present in the tree are the fallback `input_controller.gd:377` and the 2D branch `hud.gd:1617`. The primary 3D click path (`hud.gd:1657`) is **already** routed to the offset API. So either the owner tested a build/path that used plain `jump_to_world`, or the offset API is not being reached (e.g. `_bound_cam3d` unset → `_cam3d_jump` returns false at `:1649-1650`, `hud.gd:58,219`). Both are **inferred**; no runtime capture was run in this ticket.

## 4. Verdict — center vs tip, and donor truth

| Question | Answer | Label |
|---|---|---|
| Does the donor helper write the clicked GUI point as the camera target? | **No.** It writes `dst + (offX+dx, offZ+dz)` with `offZ ≈ cot32·h` (32–93 m) | **derived** from `control.script:595-612` + `camera.cfg:9-10,32-35` |
| Is the donor click point therefore the viewport center? | **Not at script level.** The target is displaced from it by the boom length. Whether the engine's `SetMainCameraMoveToTargetXZ` re-derives the look-at point so that `dst` *becomes* the center is **UNVERIFIED** (engine-side) | derived + UNVERIFIED |
| Is `dst` the arrow-tip world point? | **Yes in the sense that GUI `X/Y` is the cursor hotspot position** and the default minimap cursor `crDefault` has hotspot `(0,0)` = arrow tip (`cursors.lib:5-12`; `doupdatecursor.inc:4,6-12`) | derived; hotspot→GUI-value conversion UNVERIFIED |
| Does the donor put the point at the arrow tip on screen? | Consistent with the script-level offset and with the owner's report, but **not proven** — requires a donor A/B with the cursor at a known pixel. No such A/B was run | inferred + UNVERIFIED |
| Where is the port centering today? | Plain `jump_to_world()` (`camera3d.gd:444-452`) and 2D `hud.gd:1617`; fallback `input_controller.gd:377` calls the plain API. The primary 3D click already uses the offset API | observed |
| Parity claim? | **None.** The port offset is a labelled PORT APPROXIMATION (`ArcTan`/`VectorRotate*` semantics UNVERIFIED; `MMJUMP-02` §8) | — |

**Bottom line:** the strongest donor-text finding is unambiguous: *the donor deliberately does not centre the clicked point*; it adds its camera boom length to the target. The owner's observation ("donor at arrow tip, port at center") is compatible with that, but the exact screen destination is an engine-side unknown; the words "arrow tip" should stay attributed to the owner until a discriminating capture lands.

## 5. Smallest fix recipe (for the MINIMAP-TIP-01 owner; not executed here)

Constraints honoured by the recipe: preserve `jump_to_world()` byte-identical (701 B / SHA-256 `565fdca1…`, freshly verified); do not edit or weaken `t_view_rect_rv.gd` or `t_nav_smoke.gd`; do not touch confirmed view-rect fixes (`world3d.gd:270-274`, `hud3d_adapter.gd:122-127`).

1. **Do not change `camera3d.gd:444-452` (`jump_to_world`).** It is the CAM-RV-01 known-pose entry point. Keep the separate-offset-API pattern from MMJUMP-02.
2. **Keep the primary 3D click on `jump_to_world_donor_offset`** (`hud.gd:1657`). If the owner sees centring, first verify at runtime that `_bound_cam3d` is set (`hud.gd:219`) and that `:1657` actually executes for the test click — an unset binding silently falls through (`:1649-1650`), and the 2D branch then has no camera in 3D.
3. **Single smallest code change if the fallback is the culprit:** in `input_controller.gd:376-378`, when `render_mode == "3d"` and `camera.has_method("jump_to_world_donor_offset")`, call the offset API instead of plain `jump_to_world`; leave the 2D branch (`:379-385`) and all other callers byte-identical. This aligns drag/fallback with the primary click and leaves CAM-RV-01's setup untouched. (File is foreign-owned to this diagnosis ticket — hand-off only.)
4. **Do not guess a constant.** Changing `off_z`/`dz` in `camera3d.gd:560-586` (or inventing a hotspot correction from `cursors.lib:11-12`) must wait for the discriminating capture in §6 and a donor A/B. The current `height/tan(32°)` is explicitly a PORT APPROXIMATION, not a measured donor value.
5. **If the owner confirms "arrow" = the in-world `movearrow` actor** rather than the GUI cursor, record that explicitly before any code change: the donor places that actor at `dst` (`control.script:411-417`, `onmousedown.inc:617-624,869`) and the port has no equivalent 3D marker, so a separate feature ticket — not a camera-math tweak — would be needed.
6. Verification after any change: re-check the `jump_to_world()` SHA-256 above, re-run the existing atoms unchanged, and add **no** new assertion that depends on the unverified donor offset until the A/B exists.

## 6. Discriminating capture (recipe — not run in this ticket)

Goal: decide centre vs arrow-tip with one controlled comparison, and give the follow-up owner a numeric target.

Setup: a known map (e.g. `small_map_64.json`, MAP 64×64, `TILE_M = 2` → 128 m extent), `render_mode = 3d`, yaw 0, fixed zoom height recorded (take `h = 20` and `h = 58` as two clean endpoints to avoid the UNVERIFIED mid-height interpolation), cursor explicitly `crDefault` (hotspot 0,0).

1. Put the arrow tip at a known minimap pixel, e.g. minimap-local `uv = (0.25, 0.25)` → GUI click world point `(32, 32) m` SIM. Record the actual GUI event `X/Y` and the resolved `world_pos`.
2. Click LMB once (not double — the donor branches on `bDouble` at `onmousedown.inc:121-122`).
3. Record, on the same frame:
   - **A** = clicked arrow-tip world point (from step 1);
   - **B** = camera target/focus after the jump (`camera3d._target`, SIM; or the engine's target via `CameraInfoReadProperties` on the donor side);
   - **C** = ground point at the viewport centre (`camera3d.screen_to_world(viewport_size/2)`), converted to SIM;
   - **D** = ground point under the arrow-tip GUI pixel (in the 3D view, if the cursor is over the world);
   - **E** = world position of any in-world `movearrow`/destination marker.
4. Decision rule:
   - **Centre behaviour:** `B ≈ A` and `C ≈ A`.
   - **Donor-offset / tip behaviour:** `B ≈ A + (0, cot32·h + 0.1·cos32)` — at `h = 20`, `B ≈ A + (0, ≈32.09 m)`; at `h = 58`, `B ≈ A + (0, ≈92.91 m)` — and `C ≈ B`, so `A` is displaced from the viewport centre by that amount.
5. Take matched-resolution screenshots of donor and port for the same `A`, `h` and cursor pixel; place them side by side. **Do not call it parity until both B and C are measured on the donor**, because `SetMainCameraMoveToTargetXZ`, `ArcTan` and `VectorRotate*` are engine-side UNVERIFIED.

## 7. Open questions

1. **Engine semantics of `SetMainCameraMoveToTargetXZ(newx,newy)`** — does it move the eye/probe or the look-at focus? This is the single fact that flips the answer between "centre" and "offset"; **UNVERIFIED** without donor run / binary RE.
2. **`ArcTan` units and body** (deg vs rad; cotangent identity) — no donor script defines it; EXE only declares the signature (`DEC_07` §5.5/§10 Q1). The `height/tan(32°)` constant stays a PORT APPROXIMATION.
3. **`VectorRotateX/VectorRotateY` sign conventions** — only inferable from `default.cameras:9-10` (`0.1 sin32`, `0.1 cos32`) (`DEC_07` §6.5/Q2).
4. **Donor effective yaw** — port yaw is fixed 0 (`camera3d.gd:262-282`); donor yaw **UNVERIFIED** (`G31:227,244-245`), so the `dx`/`angleX`/`offX` terms are assumed zero in the port.
5. **Owner's "arrow" identity** — GUI cursor hotspot (`cursors.lib:5-12`) vs in-world `movearrow` actor (`control.script:409-418`). Both exist; needs owner confirmation.
6. **GUI event X/Y units and hotspot offset** — donor text uses them as sim metres (`DEEPDEC-08:142-144`) but the engine pixel→metre conversion is **UNVERIFIED** (`DSEL_02` Q5).
7. **Visibility of the offset target** — at port FOV the ≈54.6 m mid-height offset may put the clicked point below the viewport; this is a derived concern that needs the §6 capture before any constant is changed.
8. **Binding reliability** — is `_bound_cam3d` (`hud.gd:58,219`) always set when a 3D minimap click arrives? An unset binding would silently route through the centering 2D branch and reproduce the owner's report.
9. **Single vs double click** — donor branches; port `_minimap_jump_3d` (`hud.gd:1635-1645`) does not distinguish. Whether the owner tested a double click is unknown.

## 8. Summary

- **Donor truth (derived from fresh byte reads):** the active helper `control.script:574-613` writes `newX = clickX + offX + dx`, `newZ = clickZ + offZ + dz`, with `offZ = ArcTan(+32°)·height ≈ cot(32°)·height` and `dz ≈ 0.1 cos32°`. At zoom heights 20/34.06/58 m the forward displacement is ≈32.09/54.59/92.91 m. **The clicked point is not written as the camera target.** (`ArcTan` and the engine-side meaning of "target" remain UNVERIFIED.)
- **Arrow tip:** the GUI event `X/Y` fed to the helper is the cursor position; the minimap cursor is `crDefault` with hotspot `SpotX = SpotY = 0` (`cursors.lib:5-12`), i.e. the arrow's point. So `dst` is the arrow-tip world point, and the donor deliberately offsets the camera target away from it. That is consistent with the owner's report but not a proven screen-space result.
- **Port:** plain `jump_to_world()` centres (`camera3d.gd:444-452`, SHA-256 `565fdca1…` unchanged) and the 2D branch centres (`hud.gd:1617`); the 3D fallback still calls the plain API (`input_controller.gd:377`). The primary 3D click already calls the labelled offset API (`hud.gd:1657` → `camera3d.gd:560-586`). `hud3d_adapter.gd` supplies world→minimap corners and screen→world, not the minimap click mapping.
- **No parity claim:** no donor A/B was run; engine-side target semantics, `ArcTan`, `VectorRotate*` and donor yaw are UNVERIFIED.
- **Files changed by this ticket:** exactly one — this report. No source, config, test, shader, fixture or donor file was edited; no runner job, gate or ladder was run.
