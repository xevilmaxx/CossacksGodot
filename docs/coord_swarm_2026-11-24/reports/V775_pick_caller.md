---
id: V7-75
title: "V7-75 — forward players_only through the 3D caller; E18 shift+group routed through jump_to_world"
owner: V7-75
scope: "variant3d/scripts/input_controller.gd ONLY (plus this one report). Read-only on picking3d.gd, camera3d.gd, main.gd, app/, config, tests. No git operations."
date: 2026-11-24
status: CODE_FIXED__VERIFIED_IN_VARIANT3D__E6_E19_HANDOFF_OPEN
verdict: "The 3D `_pick()` seam now forwards the caller's `players_only` flag verbatim to picking3d.pick(); a stub probe measured true->true, false->false, omitted->true at the adapter with 0 stderr. E18 was also fixed in the same file: shift+group in 3D now calls the existing `jump_to_world(metres)` API instead of writing a Vector2 into Camera3D.global_position, measured true via a second stub probe; the 2D pixel write is unchanged and measured still (480,640). Parse clean; full variant3d selftest 29/29 passed:true. E6 (camera3d.gd) and E19 (main.gd) do not originate in this file and remain exact handoffs."
---

# V7-75 — 3D pick caller flag + E18

## 1. Task and boundaries

Source read first: `docs/coord_swarm_2026-11-24/reports/V768_picking_fix.md`, especially
the OPEN caller handoff (§6 item H1 and §4 table). V7-68 fixed the callee
(`picking3d.gd.pick(screen, players_only)`) and explicitly did NOT edit the caller.

Only `variant3d/scripts/input_controller.gd` was edited, plus this one report.
`picking3d.gd` (V7-68), `camera3d.gd`, `main.gd` (V7-70 active), `app/`, `tests`,
config and git were not touched. Two temporary probes were created in
`variant3d/tests/`, run through the runner, and **deleted**. No `inbox/backup` copy
was made because the assignment grants exclusive ownership of exactly two paths.

## 2. Evidence — 2D donor call sites (all read-only)

| Observation | Path:line | Use in the fix |
|---|---|---|
| Authoritative 2D signature `_pick(pw, players_only := true)` | `app/scripts/input_controller.gd:345` | 3D signature already identical at `variant3d/scripts/input_controller.gd:396` — unchanged |
| `if not players_only or e.player == 0:` — flag widens the radius test to all entities | `app/scripts/input_controller.gd:358` | why the flag must reach the adapter (V7-68 mirrored it at `picking3d.gd:245`) |
| `if d < 2.0 and d < fb_d:` — unconditional any-entity fallback | `app/scripts/input_controller.gd:363-365` | fallback is flag-independent; only the radius test needs the flag |
| Guard call passes `true` | `app/scripts/input_controller.gd:434` | 3D guard call `variant3d/.../input_controller.gd:495` passes `true` |
| Left-click / info select passes `false` | `app/scripts/input_controller.gd:492` | 3D `:553` passes `false` — was degraded before this fix |
| Right-click order passes `false` | `app/scripts/input_controller.gd:585` | 3D `:647` passes `false` — was degraded before this fix |
| Cursor / capture-attack passes `false` | `app/scripts/input_controller.gd:1089` | 3D `:1168` passes `false` — was degraded before this fix |
| 3D seam that dropped the flag (the H1 handoff) | `variant3d/scripts/input_controller.gd:396` (old `:404` body) | fixed here: `return picking.pick(_pick_screen, players_only)` |
| Stale comment claiming the flag was "absorbed inside the adapter" | `variant3d/scripts/input_controller.gd:397-400` (old) | replaced with the true rule |
| 3D jump API used by the minimap (existing, safe) | `variant3d/scripts/input_controller.gd:231-233` (`camera.call("jump_to_world", wp)`), defined `camera3d.gd:215-223` | reused for E18 |
| E18 raw Vector2→Vector3 write | `variant3d/scripts/input_controller.gd:834` (old) | fixed here |

The four 3D call sites already passed the exact 2D flag values; only the seam at
`:396` discarded them. No `cmd_*` call, call site, or 2D code was modified.

## 3. Exact diff

`--- a/variant3d/scripts/input_controller.gd` / `+++ b/variant3d/scripts/input_controller.gd`

```diff
@@ -396,9 +396,11 @@
 func _pick(pw: Vector2, players_only := true) -> Dictionary:
-	# V7-52 3D seam. picking3d.pick(screen) already applies the player-0 radius
-	# test AND the 2 m any-entity fallback (V712 report §5), so the 2D
-	# `players_only` distinction is absorbed inside the adapter: none of the
-	# four inherited call sites (guard/left-click/right-order/cursor) change.
+	# V7-52 3D seam. picking3d.pick(screen, players_only) applies the SAME
+	# radius/fallback rule as the 2D loop below (V7-68): `true` restricts the
+	# radius test to player-0 entities, `false` lets every entity compete, and
+	# the 2 m any-entity fallback is unconditional in both modes. Forward the
+	# caller's flag verbatim so the guard site (:493 true) and the left-click,
+	# right-order and cursor sites (:551/:645/:1156 false) keep 2D parity.
 	if render_mode == "3d" and picking != null:
 		if not is_finite(_pick_screen.x) or not is_finite(_pick_screen.y):
 			return {}
-		return picking.pick(_pick_screen)
+		return picking.pick(_pick_screen, players_only)
```

(Comment refers to the pre-edit call-site lines; after the comment grew by two lines
the live lines are `:495`, `:553`, `:647`, `:1168`. Values are unchanged.)

```diff
@@ -833,3 +833,14 @@
 			if not arr.is_empty():
 				_set_selection(arr)
 				if k.shift_pressed and camera != null:
-					camera.global_position = arr[0].pos * world.view_scale
+					# E18 (AUDIT3D-05): the Camera3D branch must not take the
+					# 2D Camera2D write — `arr[0].pos * world.view_scale` is a
+					# Vector2 assigned to a Vector3 global_position, and it
+					# bypasses `_target`/clamp_pos() so the next
+					# _apply_transform() snaps back. Route through the same
+					# metre-space `jump_to_world` API as the minimap at :232.
+					# The 2D line below is unchanged (byte-identical text).
+					if render_mode == "3d" and camera.has_method("jump_to_world"):
+						camera.call("jump_to_world", arr[0].pos)
+					else:
+						camera.global_position = arr[0].pos * world.view_scale
 		return
```

Functional change: **one line** for H1 (the flag), and one guarded 3D branch for E18.
The 2D `_pick()` loop, all `game.cmd_*` calls, all four `_pick()` call sites and the
original 2D shift+group assignment text are untouched.

## 4. Verification — variant3d runner only

All launches used `python variant3d\tools\godot_runner.py run --id <id> --timeout <t>
--max-wait 900 -- --headless --path variant3d …`. Telemetry from
`variant3d/.godot_queue/status.json`; output under
`variant3d/.godot_queue/results/<padded-ticket>_<id>/`.

| Ticket | Job id | Command tail | Status / measured |
|---|---|---|---|
| 140 | `v775-input-parse` | `--check-only --script res://scripts/input_controller.gd` | **ok**, exit 0, wait 9.14 s, run 3.59 s, stderr 0 bytes |
| 141 | `v775-pick-caller-probe` | `--script res://tests/_v775_pick_caller_probe.gd` | **ok**, exit 0, wait 0.00 s, run 2.93 s, **stderr 0 bytes**, 5/5 checks PASS |
| 144 | `v775-full-selftest` | `-- --self-test variant3d/selftest.json` | **ok**, exit 0, wait 45.51 s, run 48.08 s; `variant3d/selftest.json` `passed:true`, **29/29 steps, 0 failures** |
| 149 | `v775-e18-probe` | `--script res://tests/_v775_e18_probe.gd` | ok, exit 0, run 3.67 s; 2/2 E18 checks PASS; probe-only `!is_inside_tree()` warnings (camera not in tree) — superseded by 151 |
| **151** | **`v775-e18-probe-r2`** | same (cameras attached to root) | **ok**, exit 0, wait 0.00 s, run 3.24 s; 2/2 E18 checks PASS; remaining stderr is probe-side SceneTree warnings, not a module verdict |

### 4.1 Measured flag forwarding (ticket 141)

Stub `picking` object records the second argument of `pick(screen, players_only)`;
`C3Input._pick()` was driven with `render_mode="3d"`, finite `_pick_screen=(123,456)`.

```text
V775 [PASS] module loads :: GDScript
V775 [PASS] _pick(pw, true) -> flag true :: { "players_only": true, "screen": (123.0, 456.0), "stub": true }
V775 [PASS] _pick(pw, false) -> flag false :: { "players_only": false, "screen": (123.0, 456.0), "stub": true }
V775 [PASS] _pick(pw) -> default true :: { "players_only": true, "screen": (123.0, 456.0), "stub": true }
V775 [PASS] screen pixel forwarded :: { "players_only": true, "screen": (123.0, 456.0), "stub": true }
V775 [PASS] recorded call order :: [true, false, true]
V775 RESULT PASS
```

Interpretation: the exact caller flag now reaches the adapter (`true->true`,
`false->false`), the omitted argument still defaults to guard-mode `true`, and the
source screen pixel is unchanged. Combined with V7-68's measured
`true->friendly / false->enemy`, this closes H1: left-click info, right-click orders
and the attack/capture cursor can now pick enemies in 3D.

### 4.2 Measured E18 (ticket 151)

```text
V775 [PASS] E18 shift+group 3D -> jump_to_world(metres) :: jumped=[(30.0, 40.0)] global_position=(0.0, 0.0, 0.0)
V775 [PASS] 2D shift+group unchanged (px write) :: (480.0, 640.0)
V775 E18 RESULT PASS
```

`_handle_key()` was driven with `shift+1`, `groups[1]=[7]`, entity `pos=(30,40)` m.
In 3D the existing `jump_to_world` API received the **metre-space** `Vector2(30,40)`
(no `view_scale`, no Vector2→Vector3 write); in 2D the original px write produced
`(480,640)` = `pos * 16`. The probe's `!is_inside_tree()` stderr comes from reading
`global_position` on a stub Node3D inside SceneTree `_initialize()`; the
decisive evidence is `jumped=[(30,40)]`.

### 4.3 Cleanup

Both probes were deleted immediately after their runs (`PROBE_DELETED_OK`,
`E18_PROBE_DELETED_OK`). No other file in `variant3d/tests/` was added or modified.
The selftest rewrote its own generated result file `variant3d/selftest.json`, as it
always does; its stderr contains only the pre-existing V7-2 flat-root morph warning
and the usual exit-time ObjectDB/resource leak notices, unchanged by this patch.
No `cmd_*` call was executed by either probe.

## 5. E6 / E18 / E19 — verification and handoffs

| Gap | Origin | Status after V7-75 |
|---|---|---|
| **E6** zoom-at-cursor drift | `variant3d/scripts/camera3d.gd:361-394` — `set_zoom_target()` stores the anchor (:363), `_smooth_zoom()` resolves it with flat-plane `screen_to_world()` at :380 and :389 and shifts `_target` at :391 | **OPEN handoff to the camera3d.gd owner.** Not in `input_controller.gd`: this file only forwards the wheel event position at `input_controller.gd:451` (`camera.call("zoom_step", …, ev.position)`), which is correct. Requested fix (AUDIT3D-05 P1-5): add an optional height-sampler callback used **only** for the `_smooth_zoom()` anchor (:379-391), sourcing `game.height_at()`; keep `screen_to_world()` flat so `hud3d_adapter.gd:82-88` and `picking3d._recalc_offset():64-90` keep their contract. Do not edit here. |
| **E18** shift+group recentre | was `variant3d/scripts/input_controller.gd:834` raw `camera.global_position = arr[0].pos * world.view_scale` | **FIXED here** (§3 hunk 2, measured §4.2) via the existing `jump_to_world` API already used at `:232`; routes through `_target` + `clamp_pos()` in `camera3d.gd:215-223`, so no snap-back and no Vector2→Vector3 error. 2D path byte-identical. |
| **E19** journey-mode camera | `variant3d/scripts/main.gd:1604-1629`, specifically `:1626-1627` (`var target: Vector2 = (focus/n) * world.view_scale`; `camera.position = camera.position.lerp(target, 0.35)`) | **OPEN handoff to the main.gd owner (V7-70 active — file NOT touched).** Not in `input_controller.gd`. In `render_mode="3d"` `camera` is a Camera3D, so a Vector2 target cannot be lerped into its 3D position and the `* world.view_scale` factor is wrong for the metre-space `_target`. Requested fix: gate on `render_mode`, and in 3D feed the **sim-metre** centre (`focus/n`, no `view_scale`) through `jump_to_world()` / `_target` (plus `set_zoom_target(want_zoom)` at `:1629`, which is already correct). Related stale writes in the same file at `main.gd:607-609` and `:1063-1070` should be reviewed in the same pass. |

## 6. Open questions / residual risk

1. E6 and E19 runtime parity remain UNVERIFIED until the camera3d.gd and main.gd
   owners apply their handoffs; this agent did not open those files for writing.
2. V7-68's declared approximation is unchanged: metre radii are converted to pixels
   at each entity's depth with `BODY_LIFT_M = 0.8` (unverified body-centre estimate),
   leaving a ground-cursor / lifted-entity parallax residual; behind-camera entities
   still clamp `_ppm()` to 0.01 m and inflate reach. Donor pick depth is engine-side
   and UNVERIFIED. None of this is a caller issue.
3. `t_pick3d.gd` was not re-run in this ticket; its no-flag call is covered by the
   measured default-argument case (ticket 141) and V7-68 report §5.
4. `app/` selftest/uitest were not run — assignment limits verification to the
   variant3d parse gate, these probes and the variant3d full selftest.
