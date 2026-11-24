---
id: PLAY2-01
scope: "READ-ONLY current-source trace of every map/minimap navigation input in variant3d after V7-67 / V7-81 / V7-90 / V7-75 / CAM-SEAM; donor comparison against DEEPDEC_08 §2"
date: 2026-11-24
status: STATIC_TRACE_COMPLETE__RUNTIME_UNVERIFIED
rules_kept: "no source/asset/config/test/git edits; no Godot launch; one report only (PLAYABILITY2_CHARTER.md:12-18)"
visual_parity_claim: false
---

# PLAY2-01 — minimap / map navigation end-to-end

## 0. Method

Read-only `read`/`grep` over current `variant3d/scripts/*`, `variant3d/tests/*`,
`docs/coord_swarm_2026-11-24/reports/{DEEPDEC_08_ui_minimap,CAMSEAM_double_subtract}.md`,
and the donor text `C:\Games\Cossacks 3\data\scripts\lib\control.script` +
`data\gui\menu.inc\onmousedown.inc`. No runner job, no Godot process, no edit.
Every claim below has a current `path:line`. Prior claims were treated as UNDONE
until re-read in current source (PLAYABILITY2_CHARTER.md:18).

**Frames used throughout (PROVEN):**

| Frame | Meaning | Evidence |
|---|---|---|
| SIM | top-left map origin, metres, `[0..MAP_W*TILE_M] × [0..MAP_H*TILE_M]` | `camera3d.gd:46-48,135-136`; `main.gd:1636-1639` |
| centred | origin-centred world3d mesh, `±MAP_W*TILE_M/2`; equals `SIM − half` | `camera3d.gd:222-229,239-247`; `CAMSEAM_double_subtract.md:49-57` |
| minimap tile | `MAP_W × MAP_H` image pixels, one pixel per tile | `hud.gd:1356-1372,1514-1526,1541` |

`Data.TILE_M = 2.0`, `Data.MAP_W = MAP_H = 160` tiles (`data.gd:23,33`),
`game.MAP_W = game.MAP_H = 160` (`game.gd:35-36,357-358`); map span 320 m,
`half = (160,160) m` (`camera3d.gd:222-229`).

---

## 1. Evidence table

| # | Status | Finding | Current source |
|---|---|---|---|
| E1 | PROVEN | HUD minimap LMB/motion converts UV → SIM metres with `world_pos = (u*MAP_W, v*MAP_H)*TILE_M`; 3D branch is entered only when `_render_mode_3d` | `hud.gd:1402-1409` |
| E2 | PROVEN | `_minimap_jump_3d` calls `_cam3d_jump` which dynamically calls `jump_to_world(world_pos)`; press is swallowed, **motion is deliberately not swallowed** | `hud.gd:1433-1454` |
| E3 | PROVEN | `jump_to_world` sets SIM `_target`, applies transform, then `mark_external_transform()` + `clamp_pos()` — **transform BEFORE clamp** | `camera3d.gd:403-411` |
| E4 | PROVEN | `_apply_transform()` subtracts `_map_half()` **unconditionally**, no memo/signature; SIM→centred happens exactly once | `camera3d.gd:234-252`; contract `:11-16,70-75` |
| E5 | PROVEN | `screen_to_world()` and `get_viewport_corners()` return **centred** metres; `clamp_pos()` itself adds `_map_half()` back to get SIM (`centre + half`) | `camera3d.gd:266-275,354-363,435-438` |
| E6 | PROVEN | `hud3d_adapter.get_minimap_box()` takes those centred corners and divides by `TILE_M` **without adding the half-map**; `clampi(...,0,mw-1)` then clips negatives to 0 | `hud3d_adapter.gd:37-76` |
| E7 | PROVEN | Minimap image/blips are indexed by `game.tile_of(pos)` where `pos` is SIM metres — so the box must be in SIM tile space | `hud.gd:1356-1372,1514-1526,1541,1598,1656,1796` |
| E8 | PROVEN | `hud.gd` box painter trusts the adapter's inclusive/exclusive conversion and repaints on the same input event | `hud.gd:1462-1500`; immediate redraws `:1417,1437,1441` |
| E9 | PROVEN | CAM-SEAM's `apply_external_target()` is used **only** by `main.gd` startup/screenshot (`:605,1058`); journey and Shift+group use `jump_to_world` (`:1642`, `input_controller.gd:917`). No minimap call site uses `apply_external_target`. | repo grep; `camera3d.gd:451-475` |
| E10 | PROVEN | `apply_external_target()` runs `clamp_pos()` **before** the new transform and then `_apply_transform()`; `clamp_pos()` measures viewport corners of the *old* camera and freezes `_last_clamp_target/_last_clamp_zoom` to the *new, unclamped* `_target` | `camera3d.gd:470-475` vs `:417-448` |
| E11 | PROVEN | `clamp_pos()` early-returns when `_target == _last_clamp_target and zoom == _last_clamp_zoom`, so a memo frozen before the final transform suppresses the next frame's clamp | `camera3d.gd:420-421,446-448` |
| E12 | PROVEN | No double subtraction remains on the minimap/journey/startup handoff: `jump_to_world` and `apply_external_target` both keep `_target` in SIM; v1 signature guard deleted | `camera3d.gd:403-411,470-475`; `CAMSEAM_double_subtract.md:100-152` |
| E13 | PROVEN | Middle drag: `_target -= (md.x/60, md.y/45)*(0.5+speed)` — matches donor `(prev−cur)` sign, zoom-independent | `camera3d.gd:490-499`; `DEEPDEC_08:37,172` |
| E14 | PROVEN | Edge/arrow pan: additive SIM-metre deltas, key speed `keyscrollspeed*4`, mouse speed `mousescrollspeed*4`, no `/zoom`, depth/dwell mouse-only | `camera3d.gd:501-575`; `DEEPDEC_08:E7/E8` |
| E15 | PROVEN | Wheel: input_controller emits `sign*notches` + `ev.position`; camera converts to donor additive height delta `-(Δ/60)*(speed*0.5+0.25)*2`, clamps 20..58 m, anchors at cursor | `input_controller.gd:511-526`; `camera3d.gd:578-592,618-656` |
| E16 | PROVEN (static) | Zoom anchor is frame-invariant: `anchor_world` and `after` are both centred, `_target += anchor_world − after` is a translation delta; `anchor_h` frozen at old height; anchor cleared on termination | `camera3d.gd:626-655` |
| E17 | PROVEN | Minimap motion is handled twice: HUD jumps without swallowing (`hud.gd:1439-1442`), then input_controller's `_unhandled_input` also jumps via `_minimap_reposition` (`input_controller.gd:650-661,247-260`). Same point → idempotent duplicate, not a visual offset. | `hud.gd:1432,1439-1442`; `input_controller.gd:650-661` |
| E18 | PROVEN | Donor minimap LMB uses `_control_GetMoveCameraToPositionOffset` + `SetMainCameraMoveToTargetXZ`, double-click uses `_control_MoveCameraToPosition(...,0,False)` | donor `onmousedown.inc:116-131` (verified direct read); `DEEPDEC_08:E2` |
| E19 | PROVEN | Donor offset/heading math (`dx=cx-tx`, `dz=0.1`, `VectorRotateX`, `offZ=ArcTan(angleZ)*height`, `VectorAngle`/`VectorRotateY`, `newX/newZ`) and the instant-jump variant are **absent** from current port | donor `control.script:574-613,618-665`; `camera3d.gd:391-402`; repo grep finds no `double_click` in `variant3d/scripts` |
| E20 | PROVEN | CAM-SEAM job list is still "planned, not submitted"; no camseam result artifact exists in repo | `CAMSEAM_double_subtract.md:8,233-251`; repo grep for `camseam-parse/selftest/probe` finds only that report |
| E21 | PROVEN | Committed tests cover camera API/tilt/roundtrip/zoom monotone but **not** `get_minimap_box()`, `apply_external_target()`, `jump_to_world()` frame, or edge/arrow pan | `tests/t_camera3d.gd:131-139,158-184,218-232`; `tests/t_nav_smoke.gd:30-54` (2D only) |

---

## 2. End-to-end trace (current source)

### 2.1 Minimap LMB click and drag

```
hud.gd:1402-1404   UV -> SIM metres
hud.gd:1409        if _render_mode_3d -> _minimap_jump_3d
hud.gd:1434-1437   LMB press -> _cam3d_jump -> set_input_as_handled -> redraw box
hud.gd:1439-1442   LMB motion -> _cam3d_jump -> redraw box (NOT handled)
hud.gd:1445-1454   cam.call("jump_to_world", world_pos)
camera3d.gd:404    cancel zoom anchor
camera3d.gd:405    _target = world_pos          (SIM)
camera3d.gd:406    _apply_transform()           (ONE SIM->centred subtraction, :247)
camera3d.gd:410    mark_external_transform()    (CAM-SEAM v2 public API)
camera3d.gd:411    clamp_pos()                  (corners now from NEW transform -> SIM clamp)
hud.gd:1462-1500   adapter box -> white border painted same frame
```

**Verdict on the requested stale-handoff question:** there is **no stale handoff on
the minimap path**. `jump_to_world()` was migrated to `mark_external_transform()`
(`camera3d.gd:410`), `_target` is canonical SIM, and `_apply_transform()` has no
signature guard (`camera3d.gd:239-247`). CAM-SEAM's new `apply_external_target()`
is **not** used here (E9) — correctly, because `jump_to_world()` already does the
right sequence. The remaining handoff defect is in `apply_external_target()`
itself (§5, RC2), not in minimap click/drag.

Coordinate frames are correct end-to-end on this path: minimap UV → SIM metres →
SIM `_target` → one subtraction → centred camera. No `view_scale` factor is
applied (correct: `world.view_scale` is a 2D px/m concept, `camera3d.gd:78-80`).

### 2.2 Edge scroll / arrow keys / middle drag / wheel

- Arrow keys and edge bands both add to `dir` in SIM metres; `speed` is
  `keyscrollspeed*4` when a key is down else `mousescrollspeed*4*mouse_mult`
  (`camera3d.gd:551-575`). No `/zoom`, matching donor E7. `mouse_mult` is
  unintentionally ignored when a key is also held (port-only mixed-input case,
  low severity).
- Middle drag is additive and zoom-independent (`camera3d.gd:490-499`), sign
  matches donor `(prev−cur)` (`DEEPDEC_08:37`).
- Wheel: `input_controller.gd:511-526` → `camera3d.gd:586-592` →
  `set_zoom_target(..., anchor)` `:600-608` → `_smooth_zoom` `:618-656`.
  Donor height delta, clamp and cursor anchor are present. No sign flip, no
  second SIM↔centred conversion on this path; the anchor correction is a
  centred-space *delta*, which is frame-invariant (E16). No static proof of
  anchor drift; runtime A/B remains UNVERIFIED.
- Duplicate minimap motion jump (E17) is redundant but idempotent.

### 2.3 Minimap viewport box

The box chain is where the frames break:

```
camera3d.gd:266-275  screen_to_world -> CENTRED metres
camera3d.gd:354-363  get_viewport_corners -> those CENTRED corners
hud3d_adapter.gd:53-65   cx = int(p.x / TILE_M)   <-- treats CENTRED as SIM
hud.gd:1476-1480    box copied into inclusive Vector4i
hud.gd:1492-1500    white border painted on minimap_view_img (SIM tile indexed)
```

Worked example (160-tile map, §0): click minimap centre → SIM `(160,160)` →
centred `(0,0)`. A view of roughly ±20 m x ±45 m yields centred corners about
`x∈[−20,20]`, `y∈[−50,40]`. The adapter divides by `TILE_M=2` and clamps
negatives to 0, so it paints roughly tiles `x∈[0,10], y∈[0,20]` — the minimap's
**top-left corner** — while the camera is looking at tile `(80,80)`. After any
jump the box therefore stays near the top-left and does **not** reflect camera
position; it is offset by exactly `−(MAP_W/2, MAP_H/2)` tiles before clamping
(E5/E6/E7). This is a static proof, not a runtime observation.

---

## 3. Donor comparison — behaviours still absent (DEEPDEC_08 §2 / E18/E19)

| Donor behaviour | Current port | Status |
|---|---|---|
| Minimap LMB preserves pre-click camera offset/heading: `dx=cx-tx`, `dz=0.1`, `VectorRotateX`, `offZ=ArcTan(angleZ)*height`, `VectorAngle`/`VectorRotateY`, `newX=dstX+offX+dx`, `newZ=dstZ+offZ+dz` (`control.script:574-613`) | port centres the clicked sim point (`camera3d.gd:403-406`) | **ABSENT** (`camera3d.gd:391-402` admits OPEN) |
| Double-click instant jump `SetCameraInfoSmoothingTime(0)` + `CameraInfoSaveWithProperties/LoadToCurrentView` (`control.script:618-665`; `onmousedown.inc:121-122`) | no `double_click` detection anywhere in `variant3d/scripts` | **ABSENT** |
| `SetCameraElasticTargetObject(0)`, `SetMainCameraRotateToTargetDir(false)` (`onmousedown.inc:126,129`) | no elastic target/rotation API in `camera3d.gd` | ABSENT (port uses fixed tilt + direct transform) |
| Minimap RMB drag/group orders (`DEEPDEC_08:E16`, `onmousedown.inc:788-801`) | only single RMB order `hud.gd:1418-1422` → `input_controller.gd:267-279` | UNVERIFIED/absent |
| Donor corner edge-scroll tags 24-27 with full corner bands (`DEEPDEC_08:E8`) | port corner x test exists but top/bottom use `edge_margin` only (`camera3d.gd:504-507`) | PARTIAL, minor |
| Donor `Shift+N` add-to-group, `N` double-click recentre, group 0 (`DEEPDEC_08:E13, §5.2`) | `Shift+N` recentres via `jump_to_world`, groups 1-9 only (`input_controller.gd:908-919`) | DIVERGENT (V7-75) |
| Donor wheel height clamp + `MoveToTargetXZ` (`DEEPDEC_08:E9`) | height clamp `:591`, cursor anchor `:618-656` | PRESENT (parity at code level) |
| Donor middle-drag factors (`DEEPDEC_08:E15`) | `camera3d.gd:490-499` | PRESENT |

The donor offset/heading is a **framing difference, not a proven defect**
(`DEEPDEC_08:154-155`): `ArcTan` units are UNVERIFIED (`:131-133`), so no numeric
offset may be invented.

---

## 4. TOP 3 root causes of "navigation still not OK"

### RC1 — Minimap viewport box is drawn in the wrong coordinate frame (PROVEN, highest confidence)

The box source consumes **centred** camera corners as if they were **SIM** tile
metres (`hud3d_adapter.gd:45-65`); the camera deliberately returns centred
metres (`camera3d.gd:266-275,354-363`) and the minimap image is SIM-tile indexed
(`hud.gd:1541,1598,1656,1796`). Negative centred coordinates are clamped to 0
(`:60-61`), so the box collapses toward the top-left and never follows a jump.
`hud.gd` repaints immediately (`hud.gd:1437,1441,1462-1500`), which makes the
wrong box appear *instantly* on click/drag — exactly the user-visible symptom.
No committed test covers this (E21).

### RC2 — CAM-SEAM `apply_external_target()` clamps the OLD view and freezes the memo before the NEW transform (PROVEN static)

`apply_external_target()` (`:470-475`) writes `_target = sim_pos`, clears memos,
then calls `clamp_pos()` **before** `_apply_transform()`. `clamp_pos()` derives
its clamp centre from `get_viewport_corners()` of the camera's *previous*
transform (`:422-433`), then stores `_last_clamp_target = _target`,
`_last_clamp_zoom = zoom` (`:446-448`). The subsequent `_apply_transform()`
(`:475`) shows an unclamped/new focus while the memo says "already clamped";
the next `_process` early-returns at `:420-421`. At startup (`main.gd:600-605`)
and screenshot (`main.gd:1051-1058`) the old view is the map centre, so the
computed delta is ~0 and the actual `focus3` is **never clamped at all**. A
focus near a map corner can leave the visible ground quad off-terrain (black
edges) until the user pans/zooms. By contrast `jump_to_world()` applies the
transform first (`:406`) and clamps second (`:411`) — correct. This is a real
asymmetry introduced by CAM-SEAM, whose verification jobs were never run (E20).

### RC3 — Donor minimap targeting semantics are still absent (PROVEN absence; donor parity gap)

Port centres the clicked point (`camera3d.gd:403-406`); donor preserves the
camera's pre-click offset/heading (`control.script:595-612`) and has an instant
double-click jump (`control.script:618-665`, `onmousedown.inc:121-122`). Current
source has no `double_click` handling (`hud.gd:1433-1454`, repo grep). For a
player expecting donor feel, every minimap click flies to a slightly different
place than the donor and double-click does not snap. DEEPDEC_08 already ranks
this P1 (`DEEPDEC_08:217-220,252-253`). Not a coordinate-frame bug; ranked third
because `ArcTan` units remain UNVERIFIED (`DEEPDEC_08:131-133,238-239`).

---

## 5. Atomic fix tasks (do NOT implement in this wave)

### FIX-P2-01 — box frame conversion
- **Owner:** `variant3d/scripts/hud3d_adapter.gd` **only** (no change to `camera3d.gd`, `hud.gd`, `main.gd`).
- **Smallest change:** in `get_minimap_box()` (`:53-65`), before `int(p.x / TILE_M)`, add the half-map offset in **metres**: `p += Vector2(mw, mh) * Data.TILE_M * 0.5` (mw/mh already read at `:39-40`). Keep `int()` truncation, clamps and exclusive-end contract (`:32-37,75-76`) unchanged. Do not introduce a new constant or a second projection.
- **Acceptance probe (headless SceneTree, new temp file outside owned source):** bind `camera3d.gd` to a stub game with `MAP_W=MAP_H=160, TILE_M=2`, create adapter, call `jump_to_world((160,160))` → assert `get_minimap_box().get_center()` ≈ `(80,80)` within 2 tiles; `jump_to_world((40,40))` → ≈ `(20,20)`; `jump_to_world((280,280))` → ≈ `(140,140)`. Also assert the box centre tracks `_target/TILE_M` after an arrow-key pan step. Probe must fail on current source (centre click gives ≈`(5,10)`).

### FIX-P2-02 — handoff clamp ordering / memo
- **Owner:** `variant3d/scripts/camera3d.gd` **only**.
- **Smallest change:** in `apply_external_target()` (`:470-475`), apply the new SIM focus transform **before** measuring/clamping: `_target = sim_pos; _zoom_anchor_screen = INF; mark_external_transform(); _apply_transform(); clamp_pos();`. Leave `clamp_pos()`/`mark_external_transform()`/`jump_to_world()` bodies untouched (`:417-475`).
- **Acceptance probe:** stub 160×160 map, `bind()` + `set_zoom_target(start,true)`, then `apply_external_target(Vector2(12,12))` (corner focus). Assert (a) final `_target` is inside `[half_extent, limit−half_extent]` derived from `get_view_rect()`, not raw `(12,12)`; (b) a second `clamp_pos()` changes neither `_target` nor `global_position`; (c) `global_position` invariant under 3× `_apply_transform()`; (d) same result when a wheel notch is interleaved and `apply_external_target(same_sim)` is called twice (CAM-SEAM §7:253-265). Probe must fail on current source.

### FIX-P2-03 — donor minimap target math + double-click (two-file atomic pair; sequence A then B)
- **Owner A:** `variant3d/scripts/camera3d.gd` — add optional `b_double := false` parameter to `jump_to_world()` (`:403`), keeping all one-arg callers (`hud.gd:1453`, `input_controller.gd:257,917`, `main.gd:1642`) byte-compatible. For `false`, port `control.script:595-612` offset/heading literally (height from `height`, angles from `Data.CAMERA_PITCH`/`camera.cfg` literals already cited at `:18-27`), with no invented `ArcTan` numeric constant; for `true`, port the instant path `control.script:618-665` (no smoothing, preserve DOV/tilt).
- **Owner B:** `variant3d/scripts/hud.gd` — in `_minimap_jump_3d` (`:1434-1437`), detect `ev is InputEventMouseButton and ev.double_click` and pass the flag through `_cam3d_jump`/`call` (`:1445-1454`), preserving RMB fall-through at `:1418-1422`.
- **Acceptance probe:** one-arg `jump_to_world(sim)` still centres exactly as today; two-arg `jump_to_world(sim,false)` yields donor-derived offset and `jump_to_world(sim,true)` changes `_target` without smoothing; a synthetic `InputEventMouseButton` with `double_click=true` on `minimap_rect` reaches the two-arg branch (observable via a probe-visible flag or the resulting target). Do not assert a numeric donor offset until `ArcTan` units are A/B-verified.

**Order of execution:** FIX-P2-01 (visible box symptom) → FIX-P2-02 (handoff correctness) → FIX-P2-03 (donor parity, gated on ArcTan A/B). They touch disjoint files except `camera3d.gd` (02 vs 03), so 02 and 03 must not be merged into one edit.

---

## 6. Non-findings (checked and correct in current source)

- No double SIM→centred subtraction on minimap, startup or journey paths (E3/E4/E9/E12); CAM-SEAM v2 guard removal is present in code.
- Wheel sign, donor height delta and 20..58 m clamp are correct (E15); no static zoom-anchor drift proof (E16).
- Middle-drag and arrow/edge pan signs and speeds match donor code level (E13/E14).
- `hud.bind_3d()` is actually called in both 3D construction paths (`main.gd:631,1103` → `:1010-1014`; `hud.gd:201-213`), so the adapter is live.
- Minimap RMB order path is reached (`hud.gd:1418-1422` → `input_controller.gd:267-279`).

---

## 7. UNVERIFIED / BLOCKED

- **No runtime evidence:** no Godot launch, no screenshot, no windowed retest; CAM-SEAM jobs remain unsubmitted (E20). All "box offset" and "unclamped focus" results are static deductions from cited code.
- `ArcTan(angleZ)` unit (deg vs rad), donor projection/sensor and exact minimap frustum geometry (`DEEPDEC_08:131-133,238-239`; `camera3d.gd:48-51,62-65`).
- Whether donor offset/heading visibly matters in 3D (DEEPDEC_08:154-155); no A/B capture.
- Runtime zoom-anchor drift on sloped terrain (`camera3d.gd:627-655`) — code looks frame-consistent, but no measurement.
- Whether `clamp_pos()` skipping when fewer than 4 finite corners occur (`camera3d.gd:431-432`) is reachable with the assumed FOV.
- CAM-SEAM idempotence probe (§7 of that report) has never been executed; phrase "idempotent" is a code-level claim only.
- Donor RMB minimap drag/group orders and donor frustum rotation remain UNVERIFIED (`DEEPDEC_08:255,236-237`).

---

*End of report. PLAY2-01 wrote only this file. No Godot process, no source, config, asset, test or git edit.*
