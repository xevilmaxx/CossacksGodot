---
id: MMJUMP-02
title: "MMJUMP-02 — land the donor minimap camera jump via a SEPARATE camera API (CAM-RV-01 conflict resolved)"
owner: MMJUMP-02 (implementation builder)
date: 2026-11-25
status: IMPLEMENTED__PARSE_SMOKE_CLEAN__NO_GATES
scope: "Exactly two owned sources edited (variant3d/scripts/camera3d.gd, variant3d/scripts/hud.gd) plus this report and the two required backup copies. jump_to_world() kept byte-identical; a NEW donor-offset API is called by the primary 3D minimap click only. No test edited. Donor READ-ONLY. No gates, no ladder, no direct godot invocation."
labels: [observed, derived, UNVERIFIED, PORT_APPROXIMATION]
---

# MMJUMP-02 — donor minimap jump via a separate camera API

## 1. Verdict and how the CAM-RV-01 conflict is resolved

MMJUMP-01 stopped because the primary 3D minimap click lives in `hud.gd` (forbidden to that
ticket) and changing the shared `jump_to_world()` would have broken CAM-RV-01's confirmed
20/20 double-click-select-all test. This ticket was granted the two files needed, and the
conflict is resolved **by separation, not by weakening anything**:

1. `camera3d.jump_to_world()` is **byte-identical** to the pre-ticket backup (701-byte
   function body, SHA-256 `565fdca189f7b2e8…`). It remains the plain centre-focus entry
   point that CAM-RV-01 uses for its known pose (`t_view_rect_rv.gd:232,377-385,420-423`;
   `CAM_RV_01_view_rect_runtime.md` job 381 = 20/20). No signature or semantics changed.
2. A **new, explicitly named** API `camera3d.jump_to_world_donor_offset(world_point: Vector2)`
   carries the donor offset math, with `path:line` donor citations and **PORT APPROXIMATION**
   / **UNVERIFIED** labels inline.
3. `hud.gd:_cam3d_jump` (`:1457-1466`), the single primary 3D minimap click/drag call site,
   now calls that new API. `_on_minimap_input`, the 2D branch, motion handling and HUD-01's
   bottom-right 240×240 geometry are byte-identical.
4. **No test was edited; no assertion was weakened.** `t_view_rect_rv.gd` (CAM-RV-01) and
   `t_nav_smoke.gd` were not touched.

Donor parity is **not** claimed: `ArcTan` VM semantics are UNVERIFIED, and the implementation
is a labelled donor-grounded approximation (`height/tan(32°)` standing in for
`ArcTan(32°)*height`).

## 2. Sources read first (all read-only)

| Source | What it supplied |
|---|---|
| `reports/MMJUMP_01_minimap_jump.md` `:1-133` | Full conflict analysis; donor transcription; the recommended "two explicit public APIs" option (§8 item 2) adopted here |
| `reports/CAM_RV_01_view_rect_runtime.md` `:15-234` | Confirmed 20/20 job 381; exact `jump_to_world(Vector2(64,64))` setup at `:62`, unit layout `:377-385` and `[10,11,12]` assertion `:420-423` — the dependency protected by item 1 above |
| `reports/HUD_01_minimap.md` `:1-126` | HUD geometry done; jump left open (§8 item 1); `ArcTan` units UNVERIFIED (§9 Q5); click path deliberately unchanged by HUD-01 |
| `reports/DSEL_02_donor_pick_math.md` §F `:209-222`, divergences `:247`, Q1 | Exact helper transcription; `78.42125/49 = 1.60043` vs `cot(32°) = 1.60033`; ArcTan semantics UNVERIFIED |
| Donor `data\scripts\lib\control.script:572-613` (fresh read-only byte decode) | Exact active helper body, including `dx = cx-tx`, `dz := 0.1`, `VectorRotateX`, `offZ := ArcTan(angleZ)*height`, `VectorAngle`/`VectorRotateY`, `newX/newZ` |
| Donor `data\gui\menu.inc\onmousedown.inc:116-131` (fresh read-only decode) | Caller sequence: `bDouble` → `_control_MoveCameraToPosition`; else offset helper + `SetMainCameraRotateToTargetDir(false)` + `SetMainCameraMoveToTargetXZ`. The line is a COMMENTED `.inc` (`[*] = ;`), so its liveness is UNVERIFIED; the active `control.script` helper is the authority |
| `variant3d/scripts/camera3d.gd` (owned, read in full) | `jump_to_world` pre-ticket `:423-431` (now `:437-445`); `_target` is SIM top-left metres; `_apply_transform` `:243-261` (yaw 0, eye behind focus); `clamp_pos` `:437-468`; `apply_external_target` `:490-501` |
| `variant3d/scripts/hud.gd:1405-1474` (owned, read in full) | `_on_minimap_input` `:1414-1438`, `_minimap_jump_3d` `:1445-1455`, `_cam3d_jump` pre-ticket `:1457-1466` (now `:1457-1468`); `_bound_cam3d` bound at `:212` |

## 3. Donor math → port mapping (claim table)

Labels: **O** = observed literal at cited donor `path:line`; **D** = derived; **U** =
UNVERIFIED; **PA** = port approximation.

| # | Donor literal / step | Label | Citation | Port implementation |
|---:|---|---|---|---|
| 1 | Helper is present and active; no `[*] = ;` prefix | O | `control.script:574-613` | Implemented in the new API only |
| 2 | `angleZ := -Lerp(-32,-32,Clamp((height-20)/(58-20),0,1)) = +32` | O + D | `control.script:595`; `camera.cfg:21-22,32-35` | `DONOR_JUMP_TILT_DEG = 32.0`, `t = deg_to_rad(32)` |
| 3 | `dx := cx-tx` (RotateX leaves X unchanged); `dz := 0.1; VectorRotateX(dx,dy,dz,angleZ)` → `dz = 0.1·cos 32°` | O + D / U signs | `control.script:596-599`; bookmark `default.cameras:9-10` (`0.1·sin32`, `0.1·cos32`) | `dx = global_position.x - (_target.x - half.x)` (live offset); `dz = DONOR_JUMP_NUDGE_M * cos(t)` |
| 4 | `offZ := ArcTan(angleZ)*height ≈ 1.6004·height` | O + D / **U semantics** | `control.script:602`; `default.cameras:6-7` (49 → 78.42125); `DSEL_02` Q1 | **PA** `off_z = h / tan(t)` (= cot 32° = 1.60033, 0.0062% from 1.60043). Not a claimed donor literal |
| 5 | `angleX := VectorAngle(0,0,1,dx,0,dz)`; `if dx<0 then angleX:=-angleX`; `VectorRotateY(offX,tmp,offZ,angleX)` | O / U convention | `control.script:605-609`; `DEC_07` §6.5/Q2 | `angle_x = atan2(dx,dz)` with the `dx<0` flip; `off_x = off_z·sin(angle_x)`, `off_z *= cos(angle_x)`. Identity at port yaw 0 |
| 6 | `newX := dstX+offX+dx; newZ := dstZ+offZ+dz` | O | `control.script:611-612` | `new_target = Vector2(world_point.x + off_x + dx, world_point.y + off_z + dz)` (SIM metres; offsets are translation-invariant) |
| 7 | Rotate-to-target disabled; target moved by `SetMainCameraMoveToTargetXZ` | O / U liveness | `onmousedown.inc:126-130` (commented); `DEEPDEC-08:127,151-155` | Target written via `_target = new_target` → `_apply_transform()` → `mark_external_transform()` → `clamp_pos()`. No rotate-to-target flag exists in the port; none invented |
| 8 | The clicked point stays ahead of the camera (donor keeps pre-click offset) vs port centres it | O + D | `DEEPDEC-08:151-155` | Consequence of step 6; labelled, not claimed as verified parity |

Numerics at the seeded height `h = sqrt(20·58) = 34.06 m`: `off_z = 34.06 / tan 32° ≈
54.51 m`, `dz = 0.1·cos 32° ≈ 0.0848 m`; with port yaw 0, `dx = off_x = 0`, so the new SIM
target is `world_point + (0, ≈54.60)`. (MMJUMP-01 computed the same 54.505 m for the `offZ`
component.)

## 4. Before → after (exact diffs)

### 4.1 `variant3d/scripts/camera3d.gd`

| Item | Before | After |
|---|---|---|
| Constants near `:61` | `DONOR_HEIGHT_MAX/MIN/FOCAL/FOCAL_STEP` only | + `DONOR_JUMP_TILT_DEG = 32.0`, `DONOR_JUMP_NUDGE_M = 0.1`, each with a `path:line` citation and an ArcTan/VectorRotate UNVERIFIED + PORT APPROX header. Existing constants byte-identical |
| `jump_to_world` (pre-ticket `:423-431`, now `:437-445`) | plain centre focus | **byte-identical** (701 bytes, SHA-256 `565fdca189f7b2e8…`) |
| New API after `apply_external_target` | none | `jump_to_world_donor_offset(world_point: Vector2) -> void` (`:553-580` in the edited file): donor math with inline `control.script:591-612` / `default.cameras:9-10` / `DEEPDEC-08` / `DSEL_02` citations, then `_zoom_anchor_screen = INF`, `_target = new_target`, `_apply_transform()`, `mark_external_transform()`, `clamp_pos()` — the same memo/clamp sequence as `jump_to_world`, without altering it |
| `clamp_pos`, `_apply_transform`, `apply_external_target`, `_process`, zoom methods | as shipped | **byte-identical** (the new method was appended after `apply_external_target`) |

Net: 68 lines added, 0 removed. No existing method's body, signature or semantics changed.

### 4.2 `variant3d/scripts/hud.gd`

| Item | Before | After |
|---|---|---|
| `_cam3d_jump` guard `:1459` | `not cam.has_method("jump_to_world")` | `not cam.has_method("jump_to_world_donor_offset")` |
| `_cam3d_jump` call (was `:1465`, now `:1467`) | `cam.call("jump_to_world", world_pos)` | `cam.call("jump_to_world_donor_offset", world_pos)` |
| `_cam3d_jump` doc comments `:1441,1462-1466` | named `jump_to_world` | name the new API and state why `jump_to_world` stays plain-centre for CAM-RV-01 |
| `_on_minimap_input`, 2D branch, `_minimap_jump_3d` motion branch, minimap geometry (`240×240`, bottom-right), `_draw_minimap_viewport_box` | as shipped | **byte-identical** |

Net: 3 lines changed, 2 comment lines added, inside the single `_cam3d_jump` path only.

## 5. Explicit non-regression statements

- **`jump_to_world` is unchanged.** Its function text was extracted from the backup and the
  edited file and compared byte-for-byte: 701 bytes each, SHA-256
  `565fdca189f7b2e8…` in both. CAM-RV-01's setup call and its 20/20 verdict therefore rest on
  the identical implementation.
- **No test was edited.** `variant3d/tests/t_view_rect_rv.gd` (CAM-RV-01),
  `variant3d/tests/t_nav_smoke.gd`, all other atoms, `input_controller.gd`,
  `hud3d_adapter.gd`, `world3d.gd` and `app/**` were not opened for write. No assertion was
  retuned, skipped or weakened; no test file is in the changed-file list in §10.
- **No existing method signature changed.** The only new symbols are two constants and one
  public method in `camera3d.gd`.

## 6. Backups (taken before the first edit, hash-verified at copy time)

| File | Backup | Bytes | SHA-256 (first 16) |
|---|---|---:|---|
| `variant3d/scripts/camera3d.gd` | `inbox/backup/camera3d.gd.bak-MMJUMP02` | 34,566 | `fd99a21c04519aa3` |
| `variant3d/scripts/hud.gd` | `inbox/backup/hud.gd.bak-MMJUMP02` | 78,586 | `dedc026464d41776` |

## 7. Validation — variant runner only

Launch form (single legal Godot door; no direct `godot`, no extra `--` before the Godot
flags — HUD-01's V782 trap):
`python variant3d/tools/godot_runner.py run --id <job> --timeout 120 -- --headless --path variant3d [--check-only] --script res://<file>.gd`

| Ticket | Job id | Target | Result | exit | wait / run | stderr bytes | `SCRIPT ERROR` |
|---:|---|---|---|---:|---|---:|---:|
| 413 | `mmjump02-camera` | `--check-only res://scripts/camera3d.gd` | `ok` | 0 | 375.72 s / 6.44 s | 0 | **0** |
| 416 | `mmjump02-hud` | `--check-only res://scripts/hud.gd` | `ok` | 0 | 96.76 s / 8.67 s | 0 | **0** |
| 417 | `mmjump02-nav` | `res://tests/t_nav_smoke.gd` | `ok` | 0 | 96.17 s / 45.65 s | 0 | **0** |

Result JSONs: `variant3d/.godot_queue/results/00000413.json`, `00000416.json`,
`00000417.json` (each references its own `<ticket>_<id>/stdout.txt` and `stderr.txt`, both
0 bytes for stderr on all three). Engine: Godot 4.7.2 stable. The long waits are the shared
swarm runner queue (other agents' jobs ahead), not job failures.

`t_nav_smoke.gd` verdict (ticket 417): **6/6 PASS**, exit 0 — `camera_early_priority`,
`camera_jump_immediate`, `camera_mark_dirty`, `minimap_center`, `minimap_drag_clamped`,
`minimap_rect_cached`.

**Honest caveat, identical in substance to MMJUMP-01 §6:** `t_nav_smoke.gd` exercises the
**2D** `camera.gd` jump and the untouched `input_controller.gd:_minimap_world`; it never
instantiates `camera3d.gd` and never calls `jump_to_world_donor_offset`. It is evidence only
that the existing minimap math was not disturbed by the parse-clean patch, **not** evidence
that the donor 3D offset behaves correctly. All three jobs were parse/atom smoke checks:
no donor A/B, no visual parity claim, no camera-offset assertion, no full gate, no ladder.

**Not run, by design:** CAM-RV-01's `t_view_rect_rv.gd` (read-only evidence of no regression
is the byte-identical `jump_to_world()` at §5), full gates, and the terrain ladder. No test
file was edited and no assertion was weakened.

## 8. Explicit UNVERIFIED / PORT APPROXIMATION labels

- **UNVERIFIED — `ArcTan()` VM body and units (deg vs rad).** No donor script defines it; the
  EXE only declares `function ArcTan(const val: Float): Float` (`0x209cc6`). `height/tan(32°)`
  is a **PORT APPROXIMATION** numerically equal to `cot(32°) = 1.60033` and to the donor
  bookmark `78.42125/49 = 1.60043` (0.0062% apart); it is **not** a claimed donor literal
  (`DSEL_02` Q1; `DEC_07` §5.5/§10 Q1; `MMJUMP_01` §7).
- **UNVERIFIED — `VectorRotateX/VectorRotateY` sign/axis conventions.** Only inferable from
  `default.cameras:9-10` (`0.1·sin32`, `0.1·cos32`) (`DEC_07` §6.5/Q2). The port uses
  `dz = 0.1·cos(32°)` and an `atan2`-based XZ rotation as the documented interpretation.
- **UNVERIFIED — donor effective yaw.** Port yaw is fixed 0 (`camera3d.gd:48-49,243-261`),
  so `dx → 0`, `angleX → 0`, `offX → 0`; the general rotation is the identity in this build.
  "Rotate-to-target disabled" has no port counterpart and no flag was invented (`DSEL_02`
  claim 6; `DEEPDEC-08:127`).
- **UNVERIFIED — whether `SetMainCameraMoveToTargetXZ` moves the elastic focus or the eye.**
  `DEEPDEC-08:127` says target; `control.script:611-612` writes the new target with the offset.
  The task-prescribed `(dstX+offX+dx, dstZ+offZ+dz)` target was used.
- **UNVERIFIED — liveness of the commented `.inc` caller.** `onmousedown.inc:116-131` is
  prefixed `[*] = ;`; the active `control.script:574-613` helper is the authority. No claim
  about donor dead code is made (`DEC_07` §8.1/§8.2).
- **UNVERIFIED — GUI event X/Y units feeding the helper** (`DSEL_02` Q5); not acted on.
- **No donor parity claim.** The donor was decoded read-only and never executed; this is a
  labelled donor-grounded approximation, not a verified match.

## 9. Open questions

1. Resolve `ArcTan` native semantics (or obtain a matched-camera donor A/B) before removing
   the **PORT APPROXIMATION** label; `height/tan(32°)` is deliberately labelled, not asserted.
2. Confirm whether the donor click point should be at screen centre or forward of it
   (`DEEPDEC-08:127` vs `:154`). This patch implements the task-prescribed target offset,
   which keeps it forward; a donor screenshot A/B would settle the framing (`GAPS.md` #1).
3. Decide whether minimap **drag** should use the same donor-offset path. The primary drag
   branch in `hud.gd:_minimap_jump_3d` already routes through `_cam3d_jump` and therefore
   uses the new API; `input_controller.gd:_minimap_reposition` remains a fallback for events
   HUD did not consume and was **not** edited (foreign-owned). Donor repeats the computation
   on every drag event (`DEEPDEC-08:146-149`).
4. Add a 3D minimap-jump runtime atom that asserts the target offset numerically; existing
   `t_nav_smoke.gd` covers only the 2D camera path and does not instantiate `camera3d.gd`.

## 10. Summary and exact changed-file list

- **Changed source files (exactly two):**
  - `variant3d/scripts/camera3d.gd` — new donor-offset constants + new separate
    `jump_to_world_donor_offset()` API; `jump_to_world()` byte-identical.
  - `variant3d/scripts/hud.gd` — `_cam3d_jump` now calls the new API; everything else in the
    file byte-identical.
- **New report:** `docs/coord_swarm_2026-11-25/reports/MMJUMP_02_minimap_jump.md` (this file).
- **New backups (2):** `inbox/backup/camera3d.gd.bak-MMJUMP02`,
  `inbox/backup/hud.gd.bak-MMJUMP02`.
- **Not changed:** any test (including `t_view_rect_rv.gd` and `t_nav_smoke.gd`),
  `input_controller.gd`, `hud3d_adapter.gd`, `world3d.gd`, any other atom, any config,
  shader, fixture, or `app/**`. Donor READ-ONLY; no donor file copied, unpacked or executed.
  No `godot` process launched outside `variant3d/tools/godot_runner.py`; no gates, ladder,
  FOV or selection fix altered.

**Bottom line:** the donor jump math is now reachable from the primary 3D minimap click via
a separate, explicitly labelled camera API, while the CAM-RV-01 dependency
`jump_to_world()` remains byte-for-byte unchanged and no test was edited.
