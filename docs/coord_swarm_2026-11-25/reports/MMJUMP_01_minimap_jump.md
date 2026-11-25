---
id: MMJUMP-01
title: "MMJUMP-01 — donor minimap→camera jump offset: BLOCKED BY OWNERSHIP/CONFIRMED-FIX CONFLICT (no net source change)"
owner: MMJUMP-01 (implementation builder)
date: 2026-11-25
status: STOPPED__CONFLICT_REPORT__SOURCES_RESTORED
scope: "Three owned sources backed up, an experimental donor-offset patch was written and parse-validated, then REVERTED byte-for-byte when the primary 3D minimap click path was found to live in foreign-owned hud.gd and the only way to reach it without editing hud.gd would break the confirmed CAM-RV-01 selection fix. No net source/config/test change. Donor READ-ONLY. No gates, no ladder, no direct godot invocation."
labels: [observed, derived, UNVERIFIED, PORT_APPROXIMATION, CONFLICT]
---

# MMJUMP-01 — donor minimap jump offset (conflict report)

## 1. Verdict — STOP, do not force the change

**The donor jump cannot be landed within the granted file ownership without breaking a confirmed selection fix.** The task's STOP clause applies; no net source change is left in the tree.

Two independent blockers:

1. **Primary path is foreign-owned.** In `render_mode == "3d"`, a left click on the minimap is consumed by `hud.gd:_on_minimap_input` (`:1414-1422`), which calls `_minimap_jump_3d` (`:1445-1455`) → `_cam3d_jump` (`:1457-1466`) → `camera.call("jump_to_world", world_pos)` at **`hud.gd:1465`**. `_render_mode_3d` is set at `hud.gd:213`. `hud.gd` is explicitly forbidden to this ticket.
2. **The owned call site is only the fallback/motion path.** `input_controller.gd:_minimap_reposition` (`:325-343`, 3D branch `:334-336`) is described by its own neighbour comment at `:616-620` as the same-path fallback for events `hud.gd` did not consume. A left **press** is swallowed by `hud.gd:1448` (`set_input_as_handled()`); only mouse **motion** reaches `_unhandled_input` (`:760-771`). Routing the donor offset through `input_controller.gd` alone would make drag jump with the offset and click jump without it — a new inconsistency, not the requested fix.
3. **Reaching the click path via `camera3d.gd:jump_to_world` breaks CAM-RV-01.** `jump_to_world` is a shared entry point. Its other callers include `variant3d/tests/t_view_rect_rv.gd:232` (the CAM-RV-01 runtime re-verify, confirmed 20/20 in `CAM_RV_01_view_rect_runtime.md`). That test focuses the map centre with `jump_to_world`, spawns units within ±55 m of centre (`:377-385`) and asserts `double_click_selected_exact == [10,11,12]` (`:420-423`). Adding `offZ = h/tan(32°)` ≈ **54.505 m** at the seeded height `h = sqrt(20*58) = 34.06` would move the focus/eye by that amount, pull unit 13 into the view and unit 10/11/12 out of the click centre, so the confirmed assertion would fail. Tests are forbidden to this ticket, so there is no legal way to re-baseline it here.

No test was weakened, no assertion retuned, no confirmed `view_rect` half-map fix (`world3d.gd:270-274`, `hud3d_adapter.gd:104-109`) was touched.

## 2. Sources read first (all read-only)

| Source | What it supplied |
|---|---|
| `docs/coord_swarm_2026-11-25/reports/HUD_01_minimap.md` §7 item 1, §8 item 1, §9 Q5 | Geometry done; jump explicitly left open for a separate ticket; `ArcTan` units UNVERIFIED |
| `DSEL_02_donor_pick_math.md` §"Minimap jump" (formula F, `:209-222`), claims 15/16/17, divergences "Minimap jump", Q1/Q5 | Exact helper transcription and the numerics `78.42125/49 = 1.60043` vs `cot(32°) = 1.60033` |
| `DEC_07_cameras_shaders.md` §5.5 (`:725-737`), §6, §8.2 (`:835-838`), §10 Q1/Q2 | Helper is **active** (corrects DEEPDEC-01 E26); `ArcTan` VM semantics and `VectorRotateX/Y` sign conventions UNVERIFIED |
| `GAPS.md` §1 "Minimap / HUD" row (`:25`) and watchlist #8/#12 | Ticket boundary; no test weakening; one-file ownership + backup rule |
| `DEEPDEC_08_ui_minimap.md` §2 (`:95-155`) | Single-click vs double-click branch, `SetMainCameraMoveToTargetXZ` moves the target, framing difference "port centres / donor keeps offset" |
| Donor `data\scripts\lib\control.script:574-613` (fresh read-only byte decode) | Exact helper body; `:618-665` double-click variant |
| Donor `data\gui\menu.inc\onmousedown.inc:116-131` (fresh read-only decode) | Caller: `bDouble` → `_control_MoveCameraToPosition`; else offset helper + `SetMainCameraRotateToTargetDir(false)` |
| `variant3d/scripts/input_controller.gd`, `camera3d.gd`, `hud3d_adapter.gd` | Owned files, read in full before any edit |
| `variant3d/scripts/hud.gd:1412,1414-1466`, `main.gd:1640-1642`, `picking3d.gd:84-88` | Foreign call sites, read only — used to establish the conflict |
| `variant3d/tests/t_view_rect_rv.gd:232,377-385,420-423`, `t_nav_smoke.gd:24-56` | Confirmed-fix dependency and the existing minimap atom |

## 3. Claim table

Labels: **O** = observed literal at cited `path:line`; **D** = derived; **I** = inferred; **U** = UNVERIFIED; **PA** = port approximation.

| # | Claim | Label | Citation | Status in this ticket |
|---:|---|---|---|---|
| 1 | Donor minimap click branches on `bDouble`: double-click `_control_MoveCameraToPosition(x,y,0,False)`; else offset helper + `SetMainCameraRotateToTargetDir(false)` + `SetMainCameraMoveToTargetXZ(newx,newy)` | O | `onmousedown.inc:116-131,121-122,126-130`; `DEEPDEC_08` §2 `:95-105` | Confirmed by fresh read; corrects DEEPDEC-01 E26 |
| 2 | Helper body is **present and active** at `control.script:574-613` | O | fresh donor decode `:574-613`; `DSEL_02` claim 16; `DEC_07` §5.5/§8.2; `DEEPDEC_08` E3 | Confirmed; no `[*] = ;` prefix |
| 3 | Helper reads `camera.cfg` itself: minH=20, maxH=58, four angles −32 → `angleZ = +32` for every height | O + D | `control.script:581-595`; `camera.cfg:9-10,32-35` | Implemented experimentally (reverted) with `DONOR_JUMP_TILT_DEG = 32.0` |
| 4 | `dx := cx-tx` (preserve current camera X offset); `dz := 0.1`; `VectorRotateX(dx,dy,dz,angleZ)` | O | `control.script:596-599`; bookmark `default.cameras:9-10` | Implemented experimentally; `VectorRotateX` sign convention **U** (`DEC_07` §6.5) |
| 5 | `offZ := ArcTan(angleZ)*height` ≈ `1.60043*h`; bookmark 49 → 78.42125 (0.0062% from `49/tan32 = 78.41639`) | O + D / **U** semantics | `control.script:602`; `default.cameras:6-7`; `DEC_07` §3.4/`DEC_07` §10 Q1; `DSEL_02` Q1 | PA `height/tan(32°)` used experimentally; **never** claimed as a donor literal |
| 6 | `angleX := VectorAngle(0,0,1,dx,0,dz)`; `VectorRotateY(offX,tmp,offZ,angleX)`; `newX := dstX+offX+dx; newZ := dstZ+offZ+dz` | O | `control.script:605-612` | Port yaw fixed 0 → `angleX=0`, `offX=0`; donor yaw itself **U** (`DSEL_02` claim 6); "rotate-to-target disabled" has no port flag (no flag invented) |
| 7 | The 3D port minimap click goes through `hud.gd`, not `input_controller.gd` | O (port) | `hud.gd:213,1412,1421,1445-1466`; `input_controller.gd:616-620` | Blocking conflict — see §1 |
| 8 | Changing shared `jump_to_world` would break CAM-RV-01's double-click select-all | D (port) | `t_view_rect_rv.gd:232,377-385,420-423`; `CAM_RV_01_view_rect_runtime.md` job 381 20/20 | Blocking conflict — see §1 |
| 9 | World→minimap centred mapping from HUD-01 is unchanged | O (port) | `hud3d_adapter.gd:85-119` (half-map shift at `:104-109`) | Verified byte-identical to backup; no edit made |

## 4. Before → after (experimental patch, then reverted)

### 4.1 `variant3d/scripts/camera3d.gd` — REVERTED (net zero)

| Item | Before (original `:57-70`, `:411-431`) | Experimental after | Final |
|---|---|---|---|
| Donor literals | `DONOR_HEIGHT_MAX/MIN/FOCAL/FOCAL_STEP` only | + `DONOR_JUMP_TILT_DEG = 32.0` and `DONOR_JUMP_NUDGE_M = 0.1` at new `:62-70` with `ArcTan` U/PA header | restored byte-identical |
| `jump_to_world` comment | "OPEN — DONOR MINIMAP OFFSET/HEADING NOT IMPLEMENTED ... helper absent from the binary" | corrected to point at the new method and the E26 correction | restored byte-identical |
| New API | none | `jump_to_world_with_offset(dst)` at new `:482-504`: `dx` from live transform, `dz = 0.1*cos(32°)`, `off_z = h/tan(32°)`, `off_x = 0`, `_target = dst + (off_x+dx, off_z+dz)`, memo invalidation → `_apply_transform()` → `clamp_pos()` | method removed |
| Confirmed fixes | `_apply_transform` `:243-261`, `clamp_pos` `:437-468`, `apply_external_target` `:490-501` | untouched | untouched |

Experimental diff size: 87 lines added / 16 removed. Final `git diff`: none.

### 4.2 `variant3d/scripts/input_controller.gd` — REVERTED (net zero)

| Item | Before (original `:325-343`) | Experimental after | Final |
|---|---|---|---|
| 3D minimap branch | `camera.call("jump_to_world", wp)` at `:335` | `camera.call("jump_to_world_with_offset", wp)` with a note that the group-focus hotkey keeps plain `jump_to_world` | restored byte-identical |
| Drag-select / click-pick / orders / `view_rect` fix | `:606-790`, `:1041-1047` | untouched | untouched |

Experimental diff size: 6 lines added / 1 removed. Final `git diff`: none.

### 4.3 `variant3d/scripts/hud3d_adapter.gd` — NEVER EDITED

`get_minimap_corners()` (`:85-119`) and the PLAY2FIX-NAVBOX half-map shift (`:104-109`) are byte-identical to the pre-attempt backup (SHA-256 verified). A backup was still taken for completeness.

## 5. Backups

| File | Backup | Bytes | Post-attempt check |
|---|---|---:|---|
| `variant3d/scripts/camera3d.gd` | `inbox/backup/camera3d.gd.bak-MMJUMP01` | 34,566 | restored, SHA-256 identical to backup |
| `variant3d/scripts/input_controller.gd` | `inbox/backup/input_controller.gd.bak-MMJUMP01` | 57,319 | restored, SHA-256 identical to backup |
| `variant3d/scripts/hud3d_adapter.gd` | `inbox/backup/hud3d_adapter.gd.bak-MMJUMP01` | 6,164 | never edited; SHA-256 identical to original |

All three were copied **before** the first experimental edit and verified hash-identical at copy time.

## 6. Validation — variant runner only (jobs on the experimental, pre-revert state)

Launch form (no `godot` process outside the runner; no gates, no windowed ladder):
`python variant3d/tools/godot_runner.py run --id <job> --timeout 120 -- --headless --path variant3d [--check-only] --script res://<file>.gd`

| Ticket | Job id | Target | Wait / run | Status | stderr | `SCRIPT ERROR` |
|---:|---|---|---:|---|---|---|
| 396 | `mmjump01-smoke-camera` | `--check-only res://scripts/camera3d.gd` | 103.87 s / 5.87 s | `ok`, exit 0 | 0 bytes | **0** |
| 397 | `mmjump01-smoke-input` | `--check-only res://scripts/input_controller.gd` | 109.10 s / 7.38 s | `ok`, exit 0 | 0 bytes | **0** |
| 398 | `mmjump01-smoke-adapter` | `--check-only res://scripts/hud3d_adapter.gd` | 116.11 s / 9.44 s | `ok`, exit 0 | 0 bytes | **0** |
| 399 | `mmjump01-smoke-nav` | `res://tests/t_nav_smoke.gd` | 126.86 s / 47.42 s | `ok`, exit 0 | 0 bytes | **0** |

Result JSONs: `variant3d/.godot_queue/results/00000396.json` … `00000399.json` (each references its own `stdout.txt`/`stderr.txt` subfolder). Godot 4.7.2 stable.

`t_nav_smoke.gd` verdict (ticket 399): **6/6 PASS**, exit 0 — `camera_early_priority`, `camera_jump_immediate`, `camera_mark_dirty`, `minimap_center`, `minimap_drag_clamped`, `minimap_rect_cached`. **Honest caveat:** that atom exercises the **2D** `camera.gd` jump (`:30-40`) and the untouched `input_controller.gd:_minimap_world` (`:47-54`); it never instantiates `camera3d.gd` or calls `jump_to_world_with_offset`, so it is **not** evidence that the donor 3D offset works, only that the existing minimap math was not disturbed by the parse-clean patch.

All four jobs were parse/atom smoke checks only — no donor A/B, no visual parity claim, no full gate, no ladder. Because the patch was subsequently reverted, these results describe the experimental tree, not the final tree; the final tree is the pre-attempt baseline already covered by prior tickets' smoke jobs.

## 7. Explicit UNVERIFIED / PORT APPROXIMATION labels

- **UNVERIFIED** — `ArcTan()` VM body, units (deg vs rad) and whether it is really a cotangent: no donor script defines it; EXE declares only `function ArcTan(const val: Float): Float` (`0x209cc6`). `height/tan(32°)` is a **PORT APPROXIMATION** chosen for numerical equivalence to the bookmark (0.0062% apart), **never** a claimed donor literal (`DSEL_02` Q1; `DEC_07` §5.5/§10 Q1).
- **UNVERIFIED** — `VectorRotateX/VectorRotateY` sign/axis conventions; only inferable from `default.cameras:9-10` (`0.1·sin32`, `0.1·cos32`) (`DEC_07` §6.5/Q2).
- **UNVERIFIED** — donor effective yaw; port yaw is fixed 0 (`camera3d.gd:48-49`, `look_at(base, UP)`), so the `angleX`/`VectorRotateY` step is the identity and "rotate-to-target disabled" has no port counterpart (`DSEL_02` claim 6). No flag was invented.
- **UNVERIFIED** — whether `SetMainCameraMoveToTargetXZ` moves the elastic focus or the eye: `DEEPDEC_08:127` says target; `control.script:662` writes target `(dstX+offX, height, dstZ+offZ)` and eye `(dstX+offX+dx, height+dy, dstZ+offZ+dz)`. The task's prescribed target `(dstX+offX+dx, dstZ+offZ+dz)` was used in the experiment; the framing difference from the port's "centre the clicked point" is documented at `DEEPDEC_08:151-155`.
- **UNVERIFIED** — GUI event X/Y units feeding the helper (`DSEL_02` Q5); explicitly not acted on.
- **UNVERIFIED** — whether the commented `.inc` camera scripts are dead code; the active `control.script` helper is the authority (`DEC_07` §8.1/§8.2).

## 8. Open questions / recommended re-scope

1. **Grant `hud.gd:_cam3d_jump` (`:1457-1466`) to a follow-up ticket** so the primary 3D click can call a donor-offset camera API, and decide deliberately whether minimap **drag** (currently `input_controller.gd:_minimap_reposition`) uses the same helper — donor repeats the computation on every drag event (`DEEPDEC_08:146-149`).
2. **Decide the CAM-RV-01 interaction.** Options: (a) give the camera two explicit public APIs — plain "centre" for setup/tests/group-focus, donor-offset for minimap — and have `hud.gd` use the latter; (b) if the confirmed runtime test must be re-baselined, that is a **separate test-owner ticket with explicit approval**, not something MMJUMP-01 may do ("No test weakening").
3. **Resolve whether the donor click point should end at screen centre or forward of it.** `DEEPDEC_08:127` says the helper moves the target; `:154` says the donor keeps its pre-click offset rather than centring. A donor screenshot A/B is needed before the port commits to a framing (`GAPS.md` watchlist #1).
4. **`ArcTan` semantics** remain the fundamental unknown; any future implementation must keep the `height/tan(32°)` PA label until native VM behaviour is recovered or a matched-camera A/B is consented.

## 9. Summary and exact file state

- **Files changed by MMJUMP-01 at the end of the ticket: exactly one — this report** (`docs/coord_swarm_2026-11-25/reports/MMJUMP_01_minimap_jump.md`), a new file with no pre-existing content to preserve.
- **`variant3d/scripts/camera3d.gd`, `variant3d/scripts/input_controller.gd`:** experimentally edited, parse-smoke-clean, then **restored byte-for-byte** from their `.bak-MMJUMP01` copies. `git status` reports no modification for either.
- **`variant3d/scripts/hud3d_adapter.gd`:** never edited; hash-verified unchanged.
- No other source, config, test, shader, `app/**` file or git state was touched. No donor file was copied, unpacked or executed (donor text was decoded read-only in place). No `godot` process was launched outside `variant3d/tools/godot_runner.py`. No gates, ladder, FOV, selection or `view_rect` fix was altered.

**Bottom line:** donor jump math is fully transcribed and numerically anchored, but the click path is owned by a forbidden file and the only owned route would break a confirmed selection fix. Per the task's STOP clause, the change was not forced.
