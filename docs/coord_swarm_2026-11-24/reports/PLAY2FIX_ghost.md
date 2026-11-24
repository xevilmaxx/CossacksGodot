---
id: PLAY2FIX-GHOST
owner: PLAY2FIX-GHOST subagent
date: 2026-11-24
status: "FIX LANDED — parse PASS x2, single targeted probe PASS 10/10. Full selftest/uitest PENDING (FAST-LANE directive). No visual-parity claim."
scope: "F1 in variant3d/scripts/world3d.gd, F2 in variant3d/scripts/input_controller.gd, plus this report ONLY. No hud.gd / camera3d.gd / main.gd / world3d_fx.gd / app / config / test edits; no git operations."
governing_report: "docs/coord_swarm_2026-11-24/reports/PLAY2_04_build_ghost.md §4 F1/F2 (path:line evidence at :53-56, :103-147)"
visual_parity_claim: false
godot_runs: "tickets 303 (parse world3d, ok), 304 (one probe, ok 10/10), 305 (parse input_controller, ok). No selftest/uitest job was queued."
---

# PLAY2FIX-GHOST — building-placement phantom preview restored in 3D

## 1. Root cause (inherited, OBS from PLAY2-04)

`world3d.gd:_ghost_world_pos()` returned the raw `Camera3D.screen_to_world()` hit.
Since V7-81/CAM-SEAM that hit is **CENTRED** scene metres (`camera3d.gd:266-275`,
`camera3d.gd:234-252`), but all four downstream consumers expect **SIM map-origin**
metres: `game.in_bounds` (`world3d.gd:475-478`), `resolve_mine_sid` (`:480-481`),
`can_place` (`:487-490`) and `world3d_fx.world_pos()` which subtracts
`world_offset=(MAP_W,MAP_H)*TILE_M*0.5` (`world3d_fx.gd:462-471`, `:194-217`).
The documented SIM handoff `set_build_ghost_pos()` (`world3d.gd:784-786`) had
**zero callers** (PLAY2-04 `:54`, `:93`). The V7-76 probe fed an override manually
and therefore masked both faults (PLAY2-04 `:79-84`).

Measured confirmation (job 304): for SIM site `(300,280)` on a 320-tile map, the
real camera returned CENTRED `(-20,-40)`; `game.in_bounds(-20,-40) == false`, so
the old code actively called `draw_ghost("")` — no phantom. Even if the gate had
passed, the old FX point would have been `(-340,0,-360)`, half a map from the
camera focus.

## 2. Exact diff

Backups (pre-edit state reconstructed by reversing the exact hunks below):
`inbox/backup/world3d.gd.bak-PLAY2FIX-GHOST`,
`inbox/backup/input_controller.gd.bak-PLAY2FIX-GHOST`.

### `variant3d/scripts/world3d.gd` (final `:175-181`, `:416-436`, `:776-783`)

```diff
@@ -173,9 +173,11 @@
-# V7-76 build-ghost ground position. In a live 3D run `_ghost_world_pos()` derives
-# this from the current Camera3D + viewport mouse (camera3d.gd:167-176), the exact
-# 3D translation of world.gd:3467-3469. `_ghost_pos_override` lets a caller hand a
-# sim-metre point in when no Camera3D is current (headless probe/tests) or when it
-# prefers picking3d.ground_point(); see `set_build_ghost_pos()`.
+# V7-76 build-ghost ground position (SIM map-origin metres). In a live 3D run
+# `_ghost_world_pos()` derives this from the current Camera3D + viewport mouse:
+# camera3d.gd:266-275's screen_to_world() returns CENTRED scene metres since
+# V7-81, so the fallback adds the half-map offset before returning (FIX-GHOST F1).
+# The 2D analogue is world.gd:3467-3469. `_ghost_pos_override` lets a caller hand
+# a SIM point in when no Camera3D is current (headless probe/tests) or when the
+# input owner prefers picking3d.ground_point(); see `set_build_ghost_pos()`.
@@ -414,8 +416,9 @@
-# Build the ghost's sim-metre (map-origin) ground point. Two sources, in order:
+# Build the ghost's SIM map-origin ground point. Two sources, in order:
 #   1. explicit handoff via set_build_ghost_pos() (headless probe / input owner);
-#   2. the current Camera3D's screen_to_world(viewport mouse) — the 3D analogue
-#      of world.gd:3467-3469's canvas-inverse transform (camera3d.gd:167-176).
+#   2. the current Camera3D's screen_to_world(viewport mouse) — camera3d.gd:266-275
+#      returns CENTRED scene metres since V7-81, so add the half-map offset here
+#      to reach SIM map-origin metres (3D analogue of world.gd:3467-3469).
@@ -429,5 +432,7 @@
 				var wp = cam.call("screen_to_world", vp.get_mouse_position())
 				if wp is Vector2 and is_finite((wp as Vector2).x) and is_finite((wp as Vector2).y):
-					return wp
+					var hw := float(_int_prop(game, "MAP_W", 0)) * float(Data.TILE_M) * 0.5
+					var hh := float(_int_prop(game, "MAP_H", 0)) * float(Data.TILE_M) * 0.5
+					return (wp as Vector2) + Vector2(hw, hh)   # centred -> SIM map-origin
 	return Vector2.INF
@@ -769,17 +774,12 @@
-# OPTIONAL input-side handoff (V7-76). A live 3D run does NOT need this: sync()
-# derives the point from the current Camera3D + viewport mouse (camera3d.gd:167,
-# world.gd:3467-3469). Use this only when no Camera3D is current (headless probe)
-# or when the input owner prefers picking3d.ground_point()'s height-field hit.
-#
-# EXACT CALLER HANDOFF (documented, NOT implemented here — input_controller.gd is
-# owned by V7-75 and was not edited): in C3Input._process(), immediately after
-# `_screen_to_world(get_viewport().get_mouse_position())` (input_controller.gd:1095
-# / :372), add:
-#   if world != null and world.has_method("set_build_ghost_pos"):
-#       world.set_build_ghost_pos(pw)
-# `pw` there is already sim-metre map-origin coordinates, the same space FX's
-# world_pos()/world_offset expect. No call site is added by this atom.
+# Input-side handoff (V7-76; now WIRED by FIX-GHOST F2 in 3D build mode). sync()
+# can still derive a fallback from the current Camera3D + viewport mouse, but
+# camera3d.gd:266-275 returns CENTRED scene metres there, so F1 converts it to
+# SIM map-origin metres. The live 3D path prefers this explicit handoff: the
+# input owner forwards the SAME SIM `pw` from picking3d.ground_point() that
+# placement uses, avoiding a second projection and the flat-ray slope residual.
+# `pw` must be SIM map-origin metres — the space FX's world_pos()/world_offset
+# and game.in_bounds/can_place all expect.
```

The override branch (`:422-423`) is byte-identical; `set_build_ghost_pos()`
signature (`:784-786`) is unchanged.

### `variant3d/scripts/input_controller.gd` (final `:1173-1181`)

```diff
@@ -1171,4 +1171,9 @@
 		else:
 			world.sel_active = false
+		# FIX-GHOST (F2): in 3D build mode, forward the SAME SIM ground point the
+		# click path places with (_screen_to_world -> picking3d.ground_point,
+		# :455-468/:555/:579-605) to world3d's build ghost. The preview then
+		# tracks the cursor in the frame the click uses it, and the centred-camera
+		# fallback in world3d._ghost_world_pos() is never taken in real play.
+		# 2D is byte-identical: this handoff is gated to render_mode == "3d".
+		if render_mode == "3d" and picking != null and hud != null \
+				and hud.build_ghost_sid != "" and world.has_method("set_build_ghost_pos"):
+			world.set_build_ghost_pos(_screen_to_world(get_viewport().get_mouse_position()))
 	if patrol_mode and patrol_a != Vector2.INF:
 		_route_redraw()
```

Wiring uses the existing SIM projection (`_screen_to_world` →
`picking3d.ground_point`, `input_controller.gd:455-468`) and the existing
placement point family (`:555`, `:579-605`). Guarded by `render_mode == "3d"`,
`picking != null`, a non-empty `hud.build_ghost_sid` and method availability;
2D path, `cmd_*` semantics, hotkeys, drag overlay and selection aura are untouched.

## 3. Runner jobs (all through `variant3d/tools/godot_runner.py`; no direct Godot launch)

| Ticket | Job id | Result |
|---|---|---|
| 303 | `play2fix-ghost-parse-world` | `ok`, exit 0, 3.68 s — `--headless --path variant3d --check-only --script res://scripts/world3d.gd`. PARSE PASS. |
| 304 | `play2fix-ghost-probe` | `ok`, exit 0, 4.23 s — one targeted probe, **10/10 checks PASS**. |
| 305 | `play2fix-ghost-parse-input` | `ok`, exit 0, 4.82 s — `--check-only --script res://scripts/input_controller.gd`. PARSE PASS. |

Full selftest: **PENDING — not run** (FAST-LANE directive: fewer tests).
UITest: **PENDING — not run**. No 29/29 or 17/17 claim is made.
Evidence: `variant3d/.godot_queue/results/00000303_play2fix-ghost-parse-world/stdout.txt`,
`.../00000304_play2fix-ghost-probe/stdout.txt:3-13`,
`.../00000305_play2fix-ghost-parse-input/stdout.txt`.

The temporary probe `variant3d/tests/_play2fix_ghost_probe.gd` was **deleted**
after measurement (`Test-Path` false for both `.gd` and `.uid`). Probe stderr
contained only the pre-existing `world3d_entities: ... PORT APPROXIMATION`
warning and the usual 5 leaked ObjectDB instances at exit — no script errors.

## 4. Measured ghost visibility and position, before / after

Probe setup: real `camera3d.gd` + real `world3d.gd` + composed `world3d_fx`, stub
game `MAP_W=MAP_H=320`, `TILE_M=2.0`, `world_offset=(320,320)`
(`source=game.MAP_W/MAP_H`), SIM site `(300,280)`, sid `hou`, no override.
The real camera projected that SIM site to screen `(640,640)` and its
`screen_to_world()` returned CENTRED `(-20,-40)` — the regression detector.

| | Before (old raw-centred fallback) | After (F1 conversion) |
|---|---|---|
| Point fed to gates / FX | `(-20,-40)` CENTRED | `(300,280)` SIM |
| `game.in_bounds` | **false** → `draw_ghost("")` → hidden | **true** |
| `fx._ghost_active` / `_ghost_root.visible` | false / false (**no phantom**) | **true / true** |
| `fx._ghost_sid` / `_ghost_ok` | — / — | `hou` / `true` (green) |
| Ghost XZ (centred scene metres) | would be `(-340,0,-360)` — ~320 m off | **`(-20.000,0,-40.000)`**, delta 0.0000 m |
| Recovered SIM (`pos + (320,320)`) | `(-20,-40)` (wrong frame) | **`(300.000,280.000)`** = requested site |
| Screen of ghost vs cursor | off-screen | `(640.00,640.00)` vs `(640.00,640.00)`, **0.000 px** |

All numbers are from job 304 stdout, lines 3-13. The "before" FX position is
`fx.world_pos(raw_centred)` measured with the real bound FX module; the old
code never drew it because `in_bounds` rejected the raw point first.

## 5. Open questions / UNVERIFIED

1. **No visual-parity claim.** This is node-state and coordinate arithmetic
   only; no GPU capture, screenshot or pixel comparison was performed. The
   legibility of the translucent 0.05 m ghost box (PLAY2-04 P2-2, `:97`) after
   this fix remains UNVERIFIED.
2. **F2 was verified by parse only.** The single FAST-LANE probe deliberately
   did **not** call `set_build_ghost_pos()` and did not instantiate
   `input_controller.gd`; it proves F1's fallback conversion. The F2 handoff's
   runtime behaviour in a live windowed session (per-frame call ordering
   relative to `world.sync()`) is UNVERIFIED — at worst it is one frame of lag;
   `_process()` re-feeds every frame while build mode is active.
3. **Flat Y=0 ray residual.** F1's fallback still uses `screen_to_world()`
   rather than `picking3d.ground_point()`'s height-field march (PLAY2-04 P2-1,
   `:96`). F2's live handoff removes that residual in build mode; headless /
   override callers keep the flat-ray approximation.
4. **Full selftest / uitest PENDING** (FAST-LANE). No 29/29 or 17/17 evidence
   was gathered in this job.
5. Sibling stale consumer `world3d.gd:_update_view_rect()` (`:249-291`, stale
   comment `:269-272`) and `hud3d_adapter` centring were left untouched —
   out of this ticket's ownership (PLAY2-04 `:206-210`; see PLAY2FIX-NAVBOX).
6. Header citation `world3d.gd:97-98` still names `camera3d.gd:167-176`; left
   unchanged to keep the diff minimal under the explicit F1 comment list
   (`:175-179`, `:416-419`, `:771-783`). It is documentation-only.

## 6. Files changed

- `variant3d/scripts/world3d.gd` — F1: 3-line half-map conversion + 3 comment
  blocks refreshed.
- `variant3d/scripts/input_controller.gd` — F2: 1 guarded handoff + comment
  in `C3Input._process()`.
- `docs/coord_swarm_2026-11-24/reports/PLAY2FIX_ghost.md` — this report.
- Backup artifacts only (see §2). Temporary probe created and deleted.
  No `hud.gd`, `camera3d.gd`, `main.gd`, `world3d_fx.gd`, `app/`, config, test
  or git change.

*End of PLAY2FIX-GHOST report.*
