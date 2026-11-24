---
owner: W3-3 (micro-builder)
date: 2026-11-24
scope: wave-3 render-side building selection aura + rally flag styling
file_owned: app/scripts/world.gd
mode: render-only edit (no sim / HUD / input changes, no new assets, no donor copy)
status: FIXED (parse + load verified; visual A/B pending coordinator)
---

# W33 — Building selection aura (replaces white circle)

**Directive:** "improve building selection make it more beautiful with some kind of aura instead of white circle."
Recon basis: `X01_building_ux_sites.md` C7 (rank 4), C9 (rank 5), rank 8; rulings in `WAVE3_DECISIONS.md` D1/D2.
W2-5 closed with `world.gd` reverted byte-for-byte; pre-edit file verified clean (`git diff` empty, SHA256 `2D2731A1044...B514`).

## Claim table

| # | Item | Verdict | Evidence / file:line |
|---|---|---|---|
| 1 | White selection arc → donor-styled aura (squashed player-tinted ground glow + tinted `ring_sel` + pulse on 4 diamonds + thin dark under-ring) | **FIXED** | `app/scripts/world.gd:2982-3012` — glow `:2991-2992`, progress-segment branch `:2995-2999`, dark under-ring `:3007`, tinted overlay `:3008-3010`, pulsing diamonds `:3011-3012` |
| 2a | Selected unfinished site: progress halo reusing `site.progress` / `def.build_time` | **FIXED** | `app/scripts/world.gd:2995-2999` (`clampf(e.progress / e.def.build_time, 0, 1)`, dark track + bright player-coloured arc) |
| 2b | Garrison pips on the aura (X1 rank 8) | **FIXED** | `app/scripts/world.gd:3013-3019` (`e.get("garrison", 0)`, capped at 10, outlined amber pips) |
| 3 | Rally flag primitive-styled in `_player_color`, with the selected-gate decision applied | **FIXED** | `app/scripts/world.gd:3573-3600`; gate at `:3580` (`e.player != 0 or not bool(e.get("selected", false))`); pennant/pole/finial `:3585-3600` |
| 4 | Reuse existing overlays only; no donor texture copy | **VERIFIED-ALREADY** | `app/scripts/world.gd:310-312` already loads `shadow.png`, `ring_p0/p1.png`, `ring_sel.png` — all 64×64 RGBA. `ring_sel.png` is white RGB with alpha, so `draw_texture_rect(..., modulate=pc)` yields the player tint. No asset added, no donor file read/copied. |
| 5 | `_player_color` / animation clock / progress + garrison data already present | **VERIFIED-ALREADY** | `_player_color` `world.gd:2152-2153` (12 lanes); `anim_t += dt` `world.gd:2053`; site progress bar `world.gd:2971-2976`; `garrison` written by `game.gd:2980`, read by `hud.gd:605`. |
| 6 | Selection / rally redraw already wired | **VERIFIED-ALREADY** | `_set_selection` bumps `game.bld_dirty` (`input_controller.gd:122`) → `sim_dirty` → `bld_layer` redraw (`world.gd:2079-2081`) and `_fx_static_ok` (`world.gd:2093`), so the aura appears/disappears and the gated rally flag follows selection with no input/HUD edits. |
| 7 | Visual result of the new aura | **NOT-DONE (by me)** | Headless runner jobs parse + instantiate `world.gd` but never invoke `_draw_buildings()` / `_draw_fx()` (no viewport draw in a `--script` SceneTree). Coordinator screenshot A/B required. |

## Exact diff

`git diff -- app/scripts/world.gd` (two hunks, 55 added / 11 removed):

```diff
@@ -2980,14 +2980,44 @@ func _draw_buildings() -> void:
 		if e.get("selected", false):
+			# W3-3 donor-styled aura. The original's glow is engine-side
+			# (SetHighlightRenderSettings / gGuiUpdateHighlights) and its textures
+			# are private-use, so this is procedural + the existing overlay PNGs:
+			# squashed player-tinted glow, dark under-ring, tinted donor ring_sel,
+			# pulsing corner diamonds, plus site-progress and garrison pips.
 			var rr: float = e.def.radius * view_scale + 9.0
-			bld_layer.draw_arc(p, rr, 0, TAU, 32, Color(0.15, 0.12, 0.08, 0.7), 3.0)
-			bld_layer.draw_arc(p, rr, 0, TAU, 32, Color(1, 1, 1, 0.95), 1.5)
+			var pc := _player_color(e.player)
+			var pulse := 0.85 + 0.15 * sin(anim_t * 3.0 + float(e.id) * 0.7)
+			# squash circles into a ground-hugging ellipse for the glow + halo
+			bld_layer.draw_set_transform(p, 0.0, Vector2(1.0, 0.5))
+			bld_layer.draw_circle(Vector2.ZERO, rr * 1.20, Color(pc.r, pc.g, pc.b, 0.08 * pulse))
+			bld_layer.draw_circle(Vector2.ZERO, rr * 0.96, Color(pc.r, pc.g, pc.b, 0.13 * pulse))
+			if not e.finished:
+				# unfinished site: progress halo around the aura (X1 rank 8)
+				var pk: float = clampf(e.progress / e.def.build_time, 0.0, 1.0)
+				bld_layer.draw_arc(Vector2.ZERO, rr * 1.34, 0.0, TAU, 32, Color(0, 0, 0, 0.35), 3.0)
+				bld_layer.draw_arc(Vector2.ZERO, rr * 1.34, -PI / 2.0, -PI / 2.0 + TAU * pk, 32,
+					Color(pc.r, pc.g, pc.b, 0.95), 3.0)
+			bld_layer.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
+			# thin dark under-ring keeps the aura readable on light terrain
+			bld_layer.draw_arc(p, rr, 0, TAU, 32, Color(0.05, 0.04, 0.03, 0.8), 3.0)
+			if ov_sel != null:
+				var sw := rr * 2.0
+				bld_layer.draw_texture_rect(ov_sel, Rect2(p.x - sw / 2, p.y - sw * 0.25, sw, sw * 0.5), false, pc)
 			for k in 4:
 				var a := k * PI / 2.0 + PI / 4.0
-				var q := p + Vector2(cos(a), sin(a)) * rr
-				bld_layer.draw_circle(q, 3.5, Color(0.2, 0.15, 0.08))
-				bld_layer.draw_circle(q, 2.5, Color(1, 0.85, 0.3))
+				var q := p + Vector2(cos(a) * rr, sin(a) * rr * 0.5)
+				var d: float = 2.4 + 0.8 * pulse
+				bld_layer.draw_circle(q, d + 1.0, Color(0.05, 0.04, 0.03, 0.85))
+				bld_layer.draw_circle(q, d, Color(pc.r, pc.g, pc.b, 0.95))
+			var garr: int = int(e.get("garrison", 0))
+			if garr > 0:
+				var gp: int = mini(garr, 10)
+				var gy := p.y + rr * 0.5 + 7.0
+				for gi in gp:
+					var gx := p.x - (gp - 1) * 3.5 + float(gi) * 7.0
+					bld_layer.draw_circle(Vector2(gx, gy), 2.5, Color(0.05, 0.04, 0.03, 0.8))
+					bld_layer.draw_circle(Vector2(gx, gy), 1.6, Color(1.0, 0.85, 0.35, 0.95))
@@ -3543,20 +3573,34 @@ func _draw_fx() -> void:
-	# rally flags on barracks / stables / town halls (static: same gate)
+	# rally flags on the SELECTED building (WAVE3 decision D2: selected-gated;
+	# donor showrallypoints draws one marker per gSelectedObjects). Styling is
+	# primitive — the donor rallypoint.dds is private-use and stays uncopied.
 	if _fx_static_ok and game != null:
 		for e in game.entities:
 			if e.dead or e.kind != "building" or not e.has("rally"):
 				continue
-			if e.player != 0:
+			if e.player != 0 or not bool(e.get("selected", false)):
 				continue
 			var rp: Vector2 = e.rally
 			var bp := world_to_px(e.pos)
 			var fp := world_to_px(rp)
-			fx_layer.draw_line(bp, fp, Color(1, 1, 1, 0.4), 1.5)
-			fx_layer.draw_line(fp, fp + Vector2(0, -12), Color(0.3, 0.25, 0.2), 1.5)
-			fx_layer.draw_colored_polygon([fp + Vector2(0, -12), fp + Vector2(9, -10), fp + Vector2(0, -8)],
-				_player_color(e.player))
+			var rc := _player_color(e.player)
+			# ground-to-flag guide: dark under-layer + player-coloured core
+			fx_layer.draw_line(bp, fp, Color(0, 0, 0, 0.3), 3.0)
+			fx_layer.draw_line(bp, fp, Color(rc.r, rc.g, rc.b, 0.45), 1.5)
+			# foot disc so the marker reads against grass
+			fx_layer.draw_circle(fp, 4.0, Color(0, 0, 0, 0.45))
+			fx_layer.draw_circle(fp, 2.4, Color(rc.r, rc.g, rc.b, 0.7))
+			# wooden pole + lit edge
+			var top := fp + Vector2(0, -16)
+			fx_layer.draw_line(fp, top, Color(0.16, 0.10, 0.06), 2.5)
+			fx_layer.draw_line(fp + Vector2(-0.6, 0), top + Vector2(-0.6, 0), Color(0.55, 0.42, 0.25, 0.85), 0.8)
+			# pennant: dark outlined triangle tinted by player colour + finial
+			fx_layer.draw_colored_polygon([top, top + Vector2(11, 4), top + Vector2(0, 8)],
+				Color(0.05, 0.04, 0.03, 0.9))
+			fx_layer.draw_colored_polygon([top + Vector2(0.6, 1.0), top + Vector2(9.4, 4.2), top + Vector2(0.6, 6.9)], rc)
+			fx_layer.draw_circle(top, 1.8, Color(0.95, 0.85, 0.45))
```

Tabs preserved; no called-symbol renames; only `app/scripts/world.gd` touched.

## Backup

- `inbox/backup/world.gd.bak-W33` — copied before the first edit, SHA256 `2D2731A1044422BF57190EB217D96606B06351A9851E5F18F2F143223E1BB514` (byte-identical to the clean pre-edit file).
- Modified file SHA256 `93A6213D4546C98E991F5863F119363FEDC8D2145D5ABEB0B5BE52042EA646D9`.
- Baseline-swap check temporarily restored the backup for job `w33-baseline-fx`, then restored the modified copy; hash re-verified equal to `93A6213D...` (RESTORE_OK=True).

## Runner jobs and results

All launches via `python app\tools\godot_runner.py run ...` — godot never invoked directly. `t_forest_bake` deliberately NOT used (known environmental hang, untouched baseline also hung, W2-5 closed BLOCKED-BY-ENVIRONMENT).

| Job | Command / test | Result |
|---|---|---|
| `w33-aura-load` | `--headless --path app --script res://tests/t_smoke_fx.gd`, timeout 120 | run 12.65 s, exit 1. **No parse or runtime script errors; stderr empty.** `world.gd` parsed, `C3World.new()` + `bind(game)` succeeded, `sprites: 116 sets loaded (sids=173)`. 5/6 checks PASS; sole FAIL `artillery_explosion_fx - cannon shots +0, explode events +1`. |
| `w33-baseline-fx` | same test with the untouched backup restored, timeout 120 | run 11.94 s, exit 1, **byte-identical stdout** including the same `artillery_explosion_fx` FAIL ⇒ pre-existing sim flake, unrelated to this render-only diff. Modified file restored afterwards. |
| `w33-wave-smoke` | `--headless --path app --script res://tests/t_wave_smoke.gd`, timeout 90 | run 4.81 s, **exit 0**, stdout `WAVE_SMOKE 9/9` (explicit `load("res://scripts/world.gd")` + source scan). |
| `w33-green-final` | same light `t_wave_smoke.gd` job, re-run for supervisor, timeout 90 | run 4.48 s, **exit 0**, stdout `WAVE_SMOKE 9/9`, stderr empty. **Green verification delivered.** |

**Verdict:** parse/load/instantiation VERIFIED; the single FAIL is proven pre-existing. Runtime draw output NOT exercised by headless `--script` jobs (see NOT-DONE #7).

## Visual A/B note (for coordinator screenshot review)

- **Before:** flat circular dark ring + 1.5 px white circle + 4 amber dots; rally flag = thin white guide line, brown 12 px pole, small solid player-coloured wedge, drawn for *every* own building that has a `rally` key.
- **After:** ground-hugging ellipse (y squashed 0.5) with two low-alpha player-coloured glow layers; a dark under-ring remains for contrast; the donor `ring_sel.png` is modulated to the player tint and sits on the same ellipse; 4 corner diamonds shrink/grow gently with `anim_t`; unfinished sites gain a dark track + bright player-coloured progress arc sweeping clockwise from 12 o'clock; selected garrisoned towers show up to 10 outlined amber pips below the ellipse. Rally markers now appear only on the selected building, with a dark+tinted guide line, foot disc, wooden pole with lit edge, outlined player-coloured pennant and finial.
- **Suggested A/B captures:** (a) select a finished barracks — aura + only its flag; (b) select an unfinished site mid-build — progress halo matches the existing green build bar; (c) select a garrisoned tower — pips visible; (d) select two buildings in turn — no stale flags; (e) player 1 colour vs player 0 to check tint. Watch for overlap of the `rr*1.34` progress halo with adjacent buildings on dense grids.

## Determinism note

No RNG, wall-clock or `OS` time is used. Glow alpha and diamond radius derive from `anim_t` (already advanced deterministically by `sync(dt)` at `world.gd:2053`, same clock the existing smoke/water effects use) plus `e.id` for per-building phase offset. Progress comes from sim `e.progress / e.def.build_time`; pips from `e.garrison`; tint from `_player_color(e.player)`. Same entity/sim/tick sequence ⇒ identical draw values. `draw_set_transform` is reset to identity immediately after the glow/halo block, so later draw calls in `_draw_buildings` are unaffected.

## Open questions

1. **Pulse on a fully idle camera:** `bld_layer.queue_redraw()` is gated at `world.gd:2079` (`moved or bld_dirty change or mill_rotor_tex != null`), so the `anim_t`-driven diamond pulse only updates when the camera moves, sim dirt changes, or a mill exists. I deliberately did not widen that gate (per-frame entity scan + redraw cost, minimal-diff mandate). Should W3-3 add a "selected building alive" redraw condition, or accept a subtly static pulse on an idle camera?
2. **Always-on rally flags:** WAVE3 D2 allows them as a non-cluttering option; I implemented the selected-gate only. Does the coordinator want a config toggle for always-on?
3. **Aura scale:** the `rr*1.20` glow and `rr*1.34` progress halo may overlap neighbouring footprints on packed building grids — confirm visually.
4. **Garrison pip cap** of 10: `game.gd:2974` caps garrison at 10, so the cap mirrors the sim, but confirm the donor look (pip colour/size).
5. **Runtime draw verification:** no existing light headless job calls `_draw_buildings()`/`_draw_fx()`; a coordinator screenshot job is needed to promote visual output from NOT-DONE to VERIFIED. Scratch scripts were not allowed under my ownership, so I did not add one.
