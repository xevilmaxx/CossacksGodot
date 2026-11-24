---
id: V7-68
title: "V7-68 — 3D entity picking: restore players_only and per-entity fallback depth"
owner: V7-68
scope: "variant3d/scripts/picking3d.gd ONLY (plus this one report). Read-only on app/scripts/input_controller.gd, variant3d/scripts/input_controller.gd, camera3d.gd, main.gd."
date: 2026-11-24
status: CODE_FIXED__VERIFIED_IN_VARIANT3D__CALLER_HANDOFF_OPEN
verdict: "picking3d.gd now accepts and honours the 2D `players_only` flag and converts the 2 m fallback reach at each candidate's own camera depth. Parse clean and a stub probe measured true->friendly / false->enemy / pick_res->resource with 0 stderr. The three enemy-facing 3D call sites remain degraded until V7-66 forwards the flag at variant3d/scripts/input_controller.gd:396 (explicit handoff; that file was NOT edited)."
---

# V7-68 — picking3d `players_only` + depth fix

## 1. Task and boundaries

Fixed P1 gaps 1 and 2 from the assignment, read P1 gap 3 and documented it as a handoff.
Only `variant3d/scripts/picking3d.gd` was edited. One temporary probe was created in
`variant3d/tests/`, run, and **deleted**. No other file, `app/`, config, tests, or git
operation was touched. No `inbox/backup` copy was made because the assignment grants
exclusive ownership of exactly two paths and forbids writing any other file.

Source reports read first: `docs/coord_swarm_2026-11-24/reports/AUDIT3D_04_sim_parity.md`
(E09, P1-1) and `.../AUDIT3D_05_camera_hud_pick.md` (E6, E8, E18, E19).

## 2. Evidence — 2D / donor call sites (all read-only)

| Observation | Path:line | Use in the fix |
|---|---|---|
| `_pick(pw, players_only := true)` — the authoritative rule | `app/scripts/input_controller.gd:345` | signature mirrored |
| `if not players_only or e.player == 0:` — radius test applies to ALL entities when the flag is false | `app/scripts/input_controller.gd:358` | copied verbatim into `picking3d.gd:245` |
| `if d < 2.0 and d < fb_d:` — unconditional any-entity fallback, metre distance | `app/scripts/input_controller.gd:363-365` | fallback stays unconditional for both flag values |
| Guard call passes `true` | `app/scripts/input_controller.gd:434` | justifies default `true` |
| Left-click / info select passes `false` | `app/scripts/input_controller.gd:492` | broken in 3D until caller forwards |
| Right-click order passes `false` | `app/scripts/input_controller.gd:585` | broken in 3D until caller forwards |
| Cursor / capture-attack passes `false` | `app/scripts/input_controller.gd:1089` | broken in 3D until caller forwards |
| `pick_radius` is a metre radius (bld `block_r + 1.4`, else `def.radius + 1.4`) | `app/scripts/game.gd:1555-1560` | why radius is scaled by `_ppm(entity depth)` |
| `height_at` bilinear metre height field | `app/scripts/game.gd:1893-1907` | feeds `_depth_of()` |
| 3D seam that drops the flag (old comment claimed it was "absorbed") | `variant3d/scripts/input_controller.gd:388-396` (**V7-66 owned, NOT edited**) | handoff item H1 |
| Donor pick is engine-side, no script-readable radius/depth rule | donor `C:\Games\Cossacks 3\data\scripts\lib\misc.script:7-27`, quoted at `picking3d.gd:21-26` | app is the authority; donor stays UNVERIFIED |

## 3. Exact diff

`--- a/variant3d/scripts/picking3d.gd` / `+++ b/variant3d/scripts/picking3d.gd`

```diff
@@ -4,10 +4,12 @@
 # Contract: docs/coord_swarm_2026-11-24/V73_ATOMIC_CONTRACT.md:11 —
-#   bind(game, cam); pick(screen)->Dictionary; pick_res(screen)->Dictionary;
-#   ground_point(screen)->Vector2. NO game.cmd_* calls (read sim only; the 2D
+#   bind(game, cam); pick(screen, players_only)->Dictionary;
+#   pick_res(screen)->Dictionary; ground_point(screen)->Vector2.
+#   NO game.cmd_* calls (read sim only; the 2D
 #   input_controller integration agent keeps every cmd_* call untouched).
 #
 # Ported 2D semantics (authoritative, OBSERVED at these lines):
 #   app/scripts/input_controller.gd:337-343  screen px -> world metres via camera
-#   app/scripts/input_controller.gd:345-369  _pick: player-0 nearest inside
-#       game.pick_radius(e), then 2 m any-entity fallback (enemies for info)
+#   app/scripts/input_controller.gd:345-369  _pick: players_only ? player-0 : all
+#       entities nearest inside game.pick_radius(e), then 2 m any-entity
+#       fallback (enemies for info); flag forwarded by the 3D caller
 #   app/scripts/input_controller.gd:643-690  _pick_res: 2.5 + radius reach,
@@ -205,32 +207,52 @@
-# Unit/building entity. players_only nearest-inside-radius with the 2 m
-# any-entity fallback is preserved (input_controller.gd:345-369); the test is
-# done in screen space and depth orders overlapping hits (nearer wins on a tie).
-func pick(screen: Vector2) -> Dictionary:
+# Unit/building entity. The 2D `players_only` flag is forwarded verbatim
+# (app/scripts/input_controller.gd:345-369, :358): when true only player-0
+# entities receive the pick_radius test; when false every entity does, so
+# enemies are selectable for attack orders / info / cursor. The 2 m fallback
+# is unconditional in both modes (input_controller.gd:363-365). The test is
+# done in screen space and depth orders overlapping hits (nearer wins on a tie).
+#
+# HANDOFF: variant3d/scripts/input_controller.gd:396 must pass the flag —
+# `picking.pick(_pick_screen, players_only)` — mirroring its 2D call sites
+# (:434 true; :492/:585/:1089 false). That file is owned by V7-66 and was NOT
+# edited here; until it forwards the flag, the default `true` preserves the
+# guard-mode semantics but the three enemy-facing call sites stay degraded.
+#
+# APPROXIMATION (declared honestly): 2D compares metre distances
+# (`e.pos.distance_to(pw)`) against metre radii. Here each metre radius/reach
+# is converted to pixels at THAT entity's own camera depth via
+# `_ppm(_depth_of(e.pos, BODY_LIFT_M))`, while the cursor is the height-field
+# ground hit. BODY_LIFT_M = 0.8 is an unverified body-centre estimate, so a
+# ground-cursor / lifted-entity parallax residual remains. Donor pick depth is
+# engine-side and UNVERIFIED (header :21-26); app is the authority.
+func pick(screen: Vector2, players_only: bool = true) -> Dictionary:
 	var none: Dictionary = {}
 	if game == null or cam == null or game.entities == null:
 		return none
 	if not _offset_ready:
 		_recalc_offset()
 	var best: Dictionary = {}
 	var best_sd: float = 1e9
 	var best_depth: float = 1e9
 	var fb: Dictionary = {}
-	var fb_sd: float = FALLBACK_REACH_M * _ppm(30.0)
+	var fb_sd: float = 1e9
 	var fb_depth: float = 1e9
 	for e in game.entities:
 		if not (e is Dictionary) or bool(e.get("dead", false)) or not e.has("pos"):
 			continue
 		var sp: Vector2 = _screen_of(Vector2(e.pos), BODY_LIFT_M)
 		var sd: float = sp.distance_to(screen)
 		var depth: float = _depth_of(Vector2(e.pos), BODY_LIFT_M)
-		if int(e.get("player", -1)) == 0:
+		if not players_only or int(e.get("player", -1)) == 0:
 			var r: float = float(game.call("pick_radius", e)) * _ppm(depth)
 			if sd < r and _closer(sd, depth, best_sd, best_depth):
 				best_sd = sd
 				best_depth = depth
 				best = e
-		if sd < fb_sd and _closer(sd, depth, fb_sd, fb_depth):
+		# Per-entity depth replaces the old fixed `_ppm(30.0)` reach probe:
+		# the 2 m metre fallback reach is converted at THIS candidate's depth.
+		var fb_reach: float = FALLBACK_REACH_M * _ppm(depth)
+		if sd < fb_reach and _closer(sd, depth, fb_sd, fb_depth):
 			fb_sd = sd
 			fb_depth = depth
 			fb = e
 	return best if not best.is_empty() else fb
```

Functional change is 5 lines: the signature, the `not players_only or ...` guard, the
`fb_sd` sentinel, and the per-candidate `fb_reach` test. Everything else is documentation
of the semantics and of the caller handoff. `pick_res()`, `ground_point()`, `_ppm()`,
`_closer()` and all constants are unchanged.

## 4. P1-3 — items that do NOT originate in picking3d (documented, not edited)

AUDIT3D-05 gaps E6, E18 and E19 are camera/input/main concerns; `picking3d.gd` only
**reads** `cam.global_transform`, `cam.fov`, `cam.size`, `cam.projection` and calls
`cam.screen_to_world()`/`project_ray_*()`. It performs no camera writes and has no
zoom/group/journey code. Confirmed handoffs:

| Gap | Origin (path:line, from AUDIT3D-05) | Owner / action |
|---|---|---|
| E6 flat-plane zoom-at-cursor drift | `variant3d/scripts/camera3d.gd:332-376` (Y=0 anchor in `_smooth_zoom`) | V7-66 — add height-sampler callback used only by the zoom anchor; leave `screen_to_world()` flat so `picking3d._recalc_offset():64-90` keeps its contract |
| E18 shift+group Vector2→Vector3 write | `variant3d/scripts/input_controller.gd:825-827` (`camera.global_position` direct) | V7-66 — route through `_target` + `clamp_pos()` |
| E19 journey-mode Vector2→Vector3 write | `variant3d/scripts/main.gd:1553-1578` (`camera.position.lerp(Vector2, …)`) | V7-66 / main owner — same `_target` route |

No attempt was made to fix these here; no camera file was opened for writing.

## 5. Verification — variant3d runner only

All launches used `python variant3d\tools\godot_runner.py run --id <id> --timeout <t>
--max-wait 900 -- --headless --path variant3d …`. Results live under
`variant3d\.godot_queue\results\<ticket>.json` and `<ticket>_<id>\stdout.txt`.

| Ticket | Job id | Command tail | Status / measured | Interpretation |
|---|---|---|---|---|
| 88 | `v768-pick-parse` | `--check-only --script res://scripts/picking3d.gd` | **ok**, exit 0, wait 76.16 s, run 3.73 s, stderr 0 bytes | code parse clean |
| 95 | `v768-pick-probe` | `--script res://tests/_v768_pick_probe.gd` | failed, exit 1, run 3.35 s | probe-side parse error: empty inner class body (probe line 26); no module verdict |
| 103 | `v768-pick-probe-r2` | same | timed-out at 120 s | probe-side null `get_viewport()` at probe line 52 aborted before deferred `quit()`; runner hard-kill |
| 112 | `v768-pick-probe-r3` | same | ok, exit 0, run 3.05 s | 6/6 assertions PASS but 18 stderr `!is_inside_tree()` warnings — camera not in tree during `_initialize()`, so `global_transform` fell back to identity; not used as final evidence |
| 119 | `v768-pick-probe-r4` | same | failed, exit 1, run 2.14 s, stderr 0 | probe geometry bug: headless root viewport is **64×64**, but cursor was hardcoded at the 1280×720 project setting → all picks empty |
| 124 | `v768-pick-probe-dbg` | same | failed, exit 1, run 2.68 s | diagnostic: measured `real_vp=(64,64)`, `cam.xform=IDENTITY`; confirmed the 64×64 cause |
| **127** | **`v768-pick-probe-final`** | `--script res://tests/_v768_pick_probe.gd` | **ok**, exit 0, wait 0.00 s, run 2.12 s, **stderr 0 bytes** | **final measured result, all checks PASS** |
| **129** | **`v768-pick-parse-final`** | `--check-only --script res://scripts/picking3d.gd` | **ok**, exit 0, wait 0.00 s, run 1.91 s, **stderr 0 bytes** | **final file state parses clean** |

### Final probe design and measured output (ticket 127)

Stub game: `MAP_W=MAP_H=100`, `height_at()->0`, `pick_radius()->6.0` m, two entities —
friendly `id=10, player=0` at sim `(104,100)`, enemy `id=20, player=1` at sim `(101,100)` —
plus a wood resource `id=77` at `(100,100)`. Orthographic stub camera at identity transform
with `size = viewport.y`, so `_ppm() = 1 px/m`; cursor is derived from the **real**
viewport, `(32.0, 31.2)` for the measured 64×64 headless viewport. Resulting screen
distances: friendly 4 px, enemy 1 px; both within the 6 px radius, only the enemy within
the 2 px fallback reach. This makes the flag deciding factor unambiguous.

```text
V768 [PASS] module loads :: load ok
V768 viewport=(64.0, 64.0) cam.size=64.000 cursor=(32.0, 31.2)
V768 [PASS] pick(true)->friendly :: id=10
V768 [PASS] pick(false)->enemy :: id=20
V768 [PASS] pick(default)->friendly :: id=10
V768 [PASS] pick_res()->resource :: id=77
V768 [PASS] no cmd_* side effects :: calls=0
V768 RESULT PASS
```

Interpretation: `players_only=true` restricts the radius candidate to player 0 and
returns the friendly entity; `players_only=false` lets the nearer enemy win the radius
test; the omitted argument still defaults to the guard-mode `true`; `pick_res()` and the
no-`cmd_*` contract are unaffected. The temp probe was deleted immediately after the run
(`PROBE_DELETED_OK`). Selftest/uitest were not run — the assignment limits verification
to the variant3d parse gate and this ticket-specific probe.

## 6. Open questions / residual risk

1. **H1 (blocking for the three enemy call sites).** `variant3d/scripts/input_controller.gd:396`
   must become `picking.pick(_pick_screen, players_only)`. V7-66 owns that file. Without it
   the default `true` preserves guard mode but left-click info (`:492`), right-click attack
   (`:585`) and capture/attack cursor (`:1089`) remain degraded. The stale comment at
   `input_controller.gd:389-392` should be updated at the same time.
2. **Approximation, declared.** 2D compares metre distances; this adapter compares screen
   pixels after converting metre radii at each entity's depth. `BODY_LIFT_M = 0.8` is still
   an unverified body-centre estimate, so a ground-cursor / lifted-entity parallax residual
   remains, as does the screen-space 0.5 px depth tie (`_closer`, `picking3d.gd:307-312`,
   already classified P2 in AUDIT3D-04 E12).
3. **Behind-camera entities** yield non-positive `_depth_of()`; `_ppm()` clamps to 0.01 m,
   inflating pixel reach. Not changed (out of assigned scope) — worth a separate guard if
   a repro appears.
4. **Donor pick radius/depth is engine-side and UNVERIFIED.** App is the only available
   authority; no donor literal was invented.
5. **Runtime rendering parity** for E6/E18/E19 is out of scope and remains UNVERIFIED
   pending the camera owner's fix and AUDIT3D-09.
6. **Existing `t_pick3d.gd` was not re-run** after the change (it only calls
   `pick(screen)` with no flag, which the probe verified via the default-argument case).
   QA's final suite should still include it.
