---
owner: W3-2
date: 2026-11-24
wave: 3
scope: "UI/input side of building UX in app/scripts/input_controller.gd and app/scripts/hud.gd only. No game.gd / world.gd / test edits; donor read-only; no donor asset copied or run."
method: "Re-read X01 + WAVE3_DECISIONS + current source before editing; consumed the W3-1 hand-off in reports/W31_build_rules.md; verified each item against current file:line; one targeted Godot ui-test via app/tools/godot_runner.py (second invocation on final code after a cursor-tint fix)."
output: "Two source files + this report."
backups: ["inbox/backup/input_controller.gd.bak-W32 (37,556 bytes)", "inbox/backup/hud.gd.bak-W32 (68,762 bytes)"]
runner_jobs: ["1280 w32-hux OK, uitest 17/17 (pre-fix: 11 cursors, tint inactive)", "1281 w32-hux2 OK, uitest 17/17 (final code: 12 cursors, tint active)"]
status: "5/5 directive items implemented; final targeted gate green 17/17; aura/flag art remains W3-3."
---

# W3-2 — Building UX (input + HUD) — 2026-11-24

## Verification policy / sources read first

* `docs/coord_swarm_2026-11-24/reports/X01_building_ux_sites.md` (all 11 claims,
  ranks 3/5/7/9/10 are mine).
* `docs/coord_swarm_2026-11-24/WAVE3_DECISIONS.md` (rulings 2, 4, 5, 7).
* `docs/coord_swarm_2026-11-24/reports/W31_build_rules.md`, hand-off section
  (`## Hand-off API for W3-2`, lines 257-327) — read before finalising.
* Donor read-only via Python latin-1: `data/gui/menu.inc/onshortcut.inc:270-276`
  (`_unit_CanApplyCostByID` gates the ghost *before* entering placement mode),
  `data/scripts/lib/unit.script:10164-10177` (`_unit_UnitsCanBuild` requires a
  `gc_obj_usage_peasant` in the selection). No donor file was executed/copied.

## W3-1 API integration (confirmed clean)

`hud.gd:960-983 build_cost_ui()` calls **`game.build_cost(0, sid, pos)`** first
and only falls back to a local mirror of the old `pow(1.5,n)` / `pow(3,n)` code
if that method is absent. `hud.gd:1005-1021 build_gate()` calls
**`game.can_afford(0, sid, pos)`** and keeps `game.can_place()` as a separate,
non-blocking echo at `input_controller.gd:432-438` (per W31 note 2). Research
gate for `bar18` is in the wrapper (`hud.gd:1012-1013`), as W31 note 5 asks.
The exact sim refusal string `"Select at least one peasant to build."` is
echoed (plus the right-click cancel hint) at `hud.gd:1010` and
`input_controller.gd:423`.

## Claim status table

| # | Directive item | Status | Final file:line |
|---|---|---|---|
| 1a | Gate ghost entry on affordability + ≥1 peasant | **FIXED** | `hud.gd:881-890` (`_on_build_pick`), `input_controller.gd:838-846` (hotkey branch); shared gate `hud.gd:1005-1021` |
| 1b | Gate click commit on affordability + ≥1 peasant | **FIXED** | `input_controller.gd:417-438` — explicit peasant check `:423-425`, `hud.build_gate` call `:427-430`, existing `can_place` echo retained `:432-438` |
| 1c | Hint names missing resource | **FIXED** | `hud.gd:985-1003 missing_cost_text()` → `"Need 40 stone, 120 wood"`; held 2.5 s via `input_controller.gd:124-127 _hint()` + `:994` |
| 1d | Sim already refuses unaffordable / builder-less placements | **VERIFIED-ALREADY** (W3-1) | `game.gd:3671`, `:3690`, `:3721-3739` — no duplicate work by me |
| 2a | Escalated cost in build button tooltip | **FIXED** | `hud.gd:1043-1049` (`_price_text(cost)` + `"  (escalated)"` marker); live refresh `hud.gd:1116-1121` |
| 2b | Affordability uses escalated, not base cost | **FIXED** | `hud.gd:1053`, `:1120` — `game.can_afford(...)`; base-cost `Data.can_pay` only in the no-API fallback |
| 3a | Selection summary rally readout | **FIXED** | `hud.gd:925-929` — `"Rally set (x, y)"` or `"Rally: right-click map"` for trainers |
| 3b | Right-click rally on a selected trainer discoverable | **FIXED** (UI side) | `input_controller.gd:515-550` path existed (**VERIFIED-ALREADY**); discoverability added at `hud.gd:663-665` tooltip, `input_controller.gd:969-973,1002-1003` idle hint |
| 3c | Donor-style rally cursor tint | **FIXED** | `input_controller.gd:57-71` (runtime cyan-green tint of the imported cursor), `:1030-1033` rally mode uses it. Verified by runner detail `cursors 12 loaded` |
| 3d | In-world rally flag only/also when selected + donor styling | **NOT-DONE by W3-2 (owned by W3-3)** | `world.gd:3543-3556` unchanged; hand-off below |
| 4a | Expose `bar18`, `dip`, `gat`, `dock` | **FIXED** | `hud.gd:1034-1035` — 4 sids appended to `order`; data+icon confirmed `data.gd:1252,1255,1279,1296`; `bar18` disabled until `has18c` (`hud.gd:1012,1053`) |
| 4b | Remove dead hotkeys | **VERIFIED-ALREADY / no-op needed** | `config.json:149-150` binds only `dip`/`bar18`; both now functional through the gate. `gat`/`dock` have **no** hotkeys, so nothing silent remains; no config edit (not owned) |
| 5a | Esc cancel ghost hint (no charge) | **FIXED** | `input_controller.gd:789-793` |
| 5b | Delete site hint + refund note | **FIXED** | `input_controller.gd:800-814` — reads `e.paid_cost`, names refunded amounts, states full/half rule; refund itself **VERIFIED-ALREADY** W3-1 `game.gd:4222,4242` |
| — | Selection aura (white circle → aura) | **NOT-DONE by W3-2 (owned by W3-3)** | `world.gd:2982-2990` untouched per ownership |

## Notes / honest caveats

* The tinted rally cursor is generated from `cursor_gotomine.bmp` (fallback
  `cursor_construct.bmp`) using `Texture2D.get_image()`. The first runner job
  (1280) used an `is ImageTexture` guard; imported BMPs are
  `CompressedTexture2D`, so the tint was skipped (test detail: `cursors 11
  loaded`). The guard was changed to a null/width check and job 1281 ran the
  same targeted test again on the final code (`cursors 12 loaded`). No other
  code changed between the two jobs.
* `hud.build_gate()` checks *resources, builder presence and the `bar18`
  research gate*; `can_place()` remains a separate non-blocking echo so the
  existing "click still re-validates" contract (DO-L8.04) is preserved.
* `_hint()` holds a refusal/confirmation for 2.5 s so `_process` cannot erase it
  on the next frame; it does not change any sim state.
* `dock` can be selected and paid for, but `game.can_place()` rejects water
  tiles (`game.gd:3620`), so it can only be placed on land today. This is a
  sim-side placement rule, not a UI bug; flagged to coordinator/W3-3.
* `bar18` in-world sprite is absent (only `*_ba2d.png` dirt decals exist); its
  procedural fallback in `world.gd:2878-2909` renders, so the button is not a
  no-op. No donor art was copied.

## Test drift to report (not edited)

`app/tests/t_hud_fidelity.gd:142,147` still asserts every resource line contains
`[` and that the wood line contains `[N]`; W2-3 changed the donor-backed readout
to `(N)`. That standalone test's `worker_counts_brackets` check will FAIL until
its **test owner** updates those two assertions. Out of scope for the targeted
`uitest.json` gate (which passed 17/17) and not edited here. The `[N]` strings
in `app/tests/results/summary.json:138` and `t_mine_unified.json:64` are the
build-button *hotkey* label and remain correct.

## Exact diffs

Backups taken before any edit:
`inbox/backup/input_controller.gd.bak-W32` (37,556 bytes),
`inbox/backup/hud.gd.bak-W32` (68,762 bytes).

Unified diff of those backups against the final files (this excludes the older,
uncommitted W2-3 changes visible in `git diff`, which are not mine):

```diff
--- inbox/backup/hud.gd.bak-W32
+++ app/scripts/hud.gd
@@ -660,7 +660,9 @@
 				# rally point: one click enters the mode, right-click then sets it
 				if e.def.get("trains", []).size() > 0:
 					var ral := _mkbtn("Rally [R]", 14, 50, 64)
-					ral.tooltip_text = "Set rally point: click, then right-click the map"
+					# X1 rank 5: right-click on an already-selected trainer sets
+					# the rally directly; the button/keyboard mode is a second path.
+					ral.tooltip_text = "Set rally point: right-click the map while this building is selected, or click here then right-click [R]"
 					ral.pressed.connect(_on_rally_mode)
 					build_bar.add_child(ral)
@@ -878,6 +880,11 @@
 func _on_build_pick(sid: String) -> void:
 	audio_click.play()
+	# W3-2 / X1 C4: gate the ghost before it opens (donor onshortcut.inc:276).
+	var gate: Dictionary = build_gate(sid)
+	if not bool(gate.get("ok", false)):
+		show_hint(str(gate.get("reason", "Cannot build.")))
+		return
 	build_ghost_sid = sid
 	build_menu_open = false
 	refresh_selection(game.get_selected())
@@ -914,6 +921,12 @@
 	else:
 		s += "  HP %d/%d" % [maxi(0, first.hp), first.max_hp]
+		# X1 C8 / rank 5: make the rally discoverable on selection — show the
+		# stored point, or the right-click gesture when no point is set yet.
+		if first.has("rally") and first.rally is Vector2:
+			s += "  Rally set (%.1f, %.1f)" % [first.rally.x, first.rally.y]
+		elif first.def.get("trains", []).size() > 0:
+			s += "  Rally: right-click map"
 		if not first.finished:
 			s += "  under construction"
@@ -940,6 +953,74 @@
 	return " ".join(parts) if parts.size() > 0 else "free"
 
+# W3-2 / X1 C3-C5: the UI gates on the SAME escalated cost the sim charges.
+# W3-1 exposes game.build_cost()/game.can_afford() (game.gd:3671,3690). The
+# fallback mirrors the old inline escalation if that API is unavailable; pos
+# only changes the concrete sid of the generic "mine" button.
+func build_cost_ui(sid: String, pos := Vector2.ZERO) -> Dictionary:
+	if game == null:
+		return {}
+	if game.has_method("build_cost"):
+		var raw: Variant = game.build_cost(0, sid, pos)
+		if raw is Dictionary:
+			return (raw.get("cost") if raw.get("cost") is Dictionary else raw) as Dictionary
+	var rsid := sid
+	if game.has_method("resolve_mine_sid"):
+		rsid = str(game.resolve_mine_sid(sid, pos))
+	var def: Dictionary = Data.BUILDINGS.get(rsid, {})
+	if def.is_empty():
+		return {}
+	var mult := 1.0
+	if not rsid.begins_with("mine_") and rsid != "wal" and rsid != "gat":
+		var cnt := 0
+		for b in game.buildings_of(0):
+			if b.sid == rsid:
+				cnt += 1
+		mult = pow(3.0, cnt) if rsid == "cen" else pow(1.5, cnt)
+	var out := {}
+	for k in def.cost:
+		out[k] = int(round(float(def.cost[k]) * mult))
+	return out
+
+func missing_cost_text(sid: String, pos := Vector2.ZERO) -> String:
+	if game == null:
+		return ""
+	var cost := build_cost_ui(sid, pos)
+	var res: Array = game.players[0].res
+	var parts: Array = []
+	for k in Data.RES_NAMES:
+		var rk := str(k)
+		var need := int(cost.get(rk, 0))
+		if need <= 0:
+			continue
+		var have := int(res[Data.RES_NAMES.find(rk)])
+		if need > have:
+			parts.append("%d %s" % [need - have, rk])
+	if parts.is_empty():
+		return ""
+	return "Need " + ", ".join(parts)
+
+# Donor onshortcut.inc:270-276 gates the ghost on cost; unit.script:10164-10177
+# requires a selected peasant. One gate for build buttons, hotkeys and clicks.
+func build_gate(sid: String, pos := Vector2.ZERO) -> Dictionary:
+	if game == null:
+		return {"ok": false, "reason": "Cannot build right now."}
+	var peas := 0
+	for e in game.get_selected():
+		if e.player == 0 and not e.dead and str(e.get("sid", "")) == "peasant":
+			peas += 1
+	if peas == 0:
+		# W3-1 hand-off note 3: echo the sim's refusal string verbatim.
+		return {"ok": false, "reason": "Select at least one peasant to build (right-click cancels)."}
+	if sid == "bar18" and not bool(game.players[0].get("has18c", false)):
+		return {"ok": false, "reason": "Research the 18th century first (Town Hall)."}
+	var miss := missing_cost_text(sid, pos)
+	if miss != "":
+		return {"ok": false, "reason": miss}
+	if game.has_method("can_afford") and not bool(game.can_afford(0, sid, pos)):
+		return {"ok": false, "reason": "Not enough resources for %s." % ConfigScript.building_name(sid)}
+	return {"ok": true, "reason": ""}
+
 # The name of a unit or a building, as the settings file gives it.
@@ -947,19 +1028,30 @@
 func _refresh_build_menu(peasants: Array) -> void:
-	var order := ["cen", "hou", "wal", "bar", "sta", "bla", "aca", "sto", "mil", "mar", "art", "tow", "mine"]
+	# X1 C6 / WAVE3 ruling 5: expose the four data+art-backed sids that the AI
+	# already uses. `bar18` shares the barracks icon; `gat` shares the wall icon;
+	# `dock` has its own icon and a procedural in-world fallback.
+	var order := ["cen", "hou", "wal", "bar", "bar18", "dip", "sta", "bla", "aca", "sto",
+		"mil", "mar", "art", "tow", "gat", "dock", "mine"]
 	for sid in order:
 		var def: Dictionary = Data.BUILDINGS["mine_gold" if sid == "mine" else sid]
 		var b := _unit_button(icons_tex, def.icon, "")
+		# W3-1 hand-off: echo what the sim actually charges, not def.cost.
+		var cost: Dictionary = build_cost_ui(sid)
 		var tip := "%s  [%s]  %s  Time: %ds" % [ConfigScript.building_name(sid), _key_text(sid),
-			_price_text(def.cost), int(round(float(def.get("build_time", 0.0))))]
+			_price_text(cost), int(round(float(def.get("build_time", 0.0))))]
+		if cost != def.cost:
+			tip += "  (escalated)"
 		if sid == "mine":
 			tip += "  - type follows the ore deposit"
+		if sid == "bar18" and not bool(game.players[0].get("has18c", false)):
+			tip += "  - needs 18th-century research"
 		b.tooltip_text = tip
-		b.disabled = not Data.can_pay(game.players[0].res, def.cost)
+		var afford: bool = bool(game.can_afford(0, sid, Vector2.ZERO)) if game.has_method("can_afford") else Data.can_pay(game.players[0].res, cost)
+		b.disabled = not afford or (sid == "bar18" and not bool(game.players[0].get("has18c", false)))
 		b.pressed.connect(_on_build_pick.bind(sid))
@@ -1024,7 +1116,9 @@
 		elif d.kind == "build":
 			var def: Dictionary = Data.BUILDINGS.get("mine_gold" if d.sid == "mine" else d.sid, {})
 			if not def.is_empty():
-				b.disabled = not Data.can_pay(game.players[0].res, def.cost)
+				var cost2: Dictionary = build_cost_ui(d.sid)
+				var afford2: bool = bool(game.can_afford(0, d.sid, Vector2.ZERO)) if game.has_method("can_afford") else Data.can_pay(game.players[0].res, cost2)
+				b.disabled = not afford2 or (d.sid == "bar18" and not bool(game.players[0].get("has18c", false)))
 
--- inbox/backup/input_controller.gd.bak-W32
+++ app/scripts/input_controller.gd
@@ -41,6 +41,9 @@
 var _mm_rect_dirty := true
 var _mm_dragging := false
+# W3-2: hold a refusal/confirmation hint for a couple of seconds instead of
+# letting the next _process frame overwrite it with "" (or the ghost prompt).
+var _hint_hold_ms := 0
 
@@ -52,6 +55,20 @@
 		if FileAccess.file_exists(p):
 			cursor_tex[cn] = load(p)
+	# X1 rank 5: donor rally mode uses the crSetRallyPoint cursor. No donor art
+	# is copied; tint the existing gotomine/construct cursor cyan-green instead.
+	var rbase: Texture2D = cursor_tex.get("gotomine", cursor_tex.get("construct", null))
+	# Imported BMPs are CompressedTexture2D, not ImageTexture; Texture2D.get_image()
+	# works for both (and is null on an uninitialised placeholder).
+	if rbase != null:
+		var src: Image = rbase.get_image()
+		if src != null and src.get_width() > 0:
+			var tinted: Image = src.duplicate()
+			for ty in tinted.get_height():
+				for tx in tinted.get_width():
+					var c: Color = tinted.get_pixel(tx, ty)
+					tinted.set_pixel(tx, ty, Color(c.r * 0.35, minf(1.0, c.g * 1.15), minf(1.0, c.b * 1.25 + 0.15), c.a))
+			cursor_tex["rally"] = ImageTexture.create_from_image(tinted)
 	_set_cursor("default")
@@ -101,6 +118,21 @@
 	return true
 
+# W3-2: show a HUD hint and stop the idle _process pass from erasing it on the
+# very next frame, so "Need 40 stone" / refund notes are actually readable.
+func _hint(text: String, hold_s := 2.5) -> void:
+	if hud != null and hud.has_method("show_hint"):
+		hud.show_hint(text)
+		_hint_hold_ms = Time.get_ticks_msec() + int(hold_s * 1000.0)
+
+func _price_hint(cost: Dictionary) -> String:
+	var parts: Array = []
+	for k in Data.RES_NAMES:
+		var rk := str(k)
+		if int(cost.get(rk, 0)) > 0:
+			parts.append("%d %s" % [int(cost[rk]), rk])
+	return ", ".join(parts)
 
 func get_selected() -> Array:
@@ -385,6 +417,17 @@
 					for su in game.get_selected():
 						if not su.is_empty() and str(su.get("sid", "")) == "peasant":
 							sel_peasants.append(su)
+					# W3-2 / X1 C2-C5: refuse the click BEFORE the sim call when no
+					# peasant is selected or the escalated cost cannot be paid.
+					# Donor onshortcut.inc:270-276 / unit.script:10164-10177.
+					if sel_peasants.is_empty():
+						_hint("Select at least one peasant to build (right-click cancels)")
+						return
+					if hud.has_method("build_gate"):
+						var cg: Dictionary = hud.build_gate(hud.build_ghost_sid, pos)
+						if not bool(cg.get("ok", false)):
+							_hint(str(cg.get("reason", "Cannot build here.")))
+							return
 					# DO-L8.04: echo the central can_place reason on the HUD hint
@@ -478,7 +521,7 @@
 		for e in get_selected():
 			if e.player == 0 and e.kind == "building" and e.def.get("trains", []).size() > 0:
 				game.set_rally(e, pw)
-				hud.show_hint("Rally set")
+				_hint("Rally set (%.1f, %.1f)" % [pw.x, pw.y])
@@ -503,7 +546,7 @@
 		if not sel_blds.is_empty():
 			for b in sel_blds:
 				game.set_rally(b, pw)
-			hud.show_hint("Rally set")
+			_hint("Rally set (%.1f, %.1f)" % [pw.x, pw.y])
@@ -746,6 +789,8 @@
 			hud.build_ghost_sid = ""
 			hud.build_menu_open = false
 			hud.refresh_selection(get_selected())
+			# X1 rank 10: the ghost was never paid for, so say so explicitly.
+			_hint("Build cancelled - no resources spent")
 		else:
@@ -753,12 +798,20 @@
 	if k.keycode == KEY_DELETE:
 		var wiped := false
+		var site_note := ""
 		for e in get_selected():
 			if e.player == 0 and not e.dead:
+				# W3-1 owns the refund: cmd_delete() already calls
+				# cancel_build_site() (game.gd:4222/4239). Only the hint is ours.
+				if e.kind == "building" and not bool(e.get("finished", false)):
+					var paid: Dictionary = e.get("paid_cost", {})
+					site_note = "Site cancelled - %s refunded" % (_price_hint(paid) if not paid.is_empty() else "resources")
 				game.cmd_delete(e)
 				wiped = true
 		if wiped:
 			hud.refresh_selection(get_selected())
+			if site_note != "":
+				_hint(site_note + " (full before work, half once work starts)")
 		return
@@ -783,6 +836,12 @@
 	if hud.build_menu_open:
 		for sid in build_keys:
 			if _matches(k, build_keys[sid]):
+				# X1 C4 / donor onshortcut.inc:276: refuse before opening the
+				# ghost, naming the missing resource instead of a silent no-op.
+				var hk_gate: Dictionary = hud.build_gate(sid)
+				if not bool(hk_gate.get("ok", false)):
+					_hint(str(hk_gate.get("reason", "Cannot build.")))
+					return
 				# "mine" is a single button; the deposit under the cursor
@@ -906,12 +965,19 @@
 
+# X1 rank 5: a selected trainer advertises the right-click rally gesture.
+func _has_selected_trainer() -> bool:
+	for e in get_selected():
+		if e.player == 0 and e.kind == "building" and e.def.get("trains", []).size() > 0:
+			return true
+	return false
+
 func _process(_dt: float) -> void:
 	if hud != null and hud.want_rally:
 		hud.want_rally = false
 		rally_mode = true
-		hud.show_hint("Rally: right-click the map to set the gather point")
+		_hint("Rally: right-click the map to set the gather point")
@@ -923,16 +989,20 @@
 	if patrol_mode and patrol_a != Vector2.INF and route_node != null:
 		route_node.queue_redraw()
-	# build ghost hint uses the message line, not the units/score label
-	if hud != null and hud.build_ghost_sid != "" and hud.has_method("show_hint"):
-		hud.show_hint("Placing %s - left-click to build, right-click to cancel" % hud.build_ghost_sid)
-	elif hud != null and patrol_mode and hud.has_method("show_hint"):
-		hud.show_hint("Patrol: click the first waypoint" if patrol_a == Vector2.INF else "Patrol: click the second waypoint")
-	elif hud != null and guard_mode and hud.has_method("show_hint"):
-		# keep the guard prompt set by begin_guard()
-		pass
-	elif hud != null and hud.has_method("show_hint"):
-		hud.show_hint("")
+	# build ghost hint uses the message line, not the units/score label.
+	# A held refusal/confirmation hint wins over the idle modes for a moment.
+	if Time.get_ticks_msec() >= _hint_hold_ms:
+		if hud != null and hud.build_ghost_sid != "" and hud.has_method("show_hint"):
+			hud.show_hint("Placing %s - left-click to build, right-click to cancel" % hud.build_ghost_sid)
+		elif hud != null and patrol_mode and hud.has_method("show_hint"):
+			hud.show_hint("Patrol: click the first waypoint" if patrol_a == Vector2.INF else "Patrol: click the second waypoint")
+		elif hud != null and guard_mode and hud.has_method("show_hint"):
+			# keep the guard prompt set by begin_guard()
+			pass
+		elif hud != null and hud.has_method("show_hint") and _has_selected_trainer():
+			hud.show_hint("Rally: right-click the map to set the gather point [R]")
+		elif hud != null and hud.has_method("show_hint"):
+			hud.show_hint("")
 	_update_cursor()
@@ -958,7 +1028,8 @@
 		_set_cursor("artillery")
 		return
 	if rally_mode:
-		_set_cursor("gotomine")
+		# W3-2: cyan-tinted donor-style rally cursor, generated in bind().
+		_set_cursor("rally" if cursor_tex.has("rally") else "gotomine")
 		return
```

## Runner evidence

Targeted command only, no full selftest:

```
python app\tools\godot_runner.py run --id w32-hux --timeout 240 -- --headless --path app -- --ui-test app/uitest.json
python app\tools\godot_runner.py run --id w32-hux2 --timeout 240 -- --headless --path app -- --ui-test app/uitest.json
```

* **1280 `w32-hux`** — exit ok, run 137.58 s; `app/uitest.json` `"passed": true`,
  17/17 steps. Detail for `cursor_ctx` was `cursors 11 loaded, now default`:
  the `is ImageTexture` guard skipped the tint because imported BMPs are
  `CompressedTexture2D`. No assertion failed.
* **1281 `w32-hux2`** — exit ok, run 100.15 s; `app/uitest.json` `"passed": true`,
  **17/17 steps**, `cursor_ctx` detail `cursors 12 loaded, now default`
  proving the tinted rally cursor was created. Final-state verification.

The second invocation of the same targeted test was needed because the first
green run did not exercise the finished cursor code; no full selftest was run.

## Hand-off

* **To W3-1** — used `build_cost()`/`can_afford()` exactly as handed off; no
  changes needed to `game.gd`. If `can_afford` ever widens to include the
  `bar18`/`multicannon` research gates, `hud.gd:1012-1013` can drop its local
  check. W3-1's `paid_cost` is read for the Del hint at
  `input_controller.gd:807-808`. W3-1's open items 3 (builder death mid-build)
  and 4 (Shift-queue overwritten `cmd_build`) remain exposure-only from my
  side: Esc/Del now gives the player the recovery key.
* **To W3-3** — the aura and in-world rally flag are still yours:
  `world.gd:2982-2990` (white arc → procedural player-colour ellipse + tinted
  `ring_sel.png` + pulsing diamonds) and `world.gd:3543-3556` (rally flag
  currently drawn for all player-0 trainers, no `selected` test; WAVE3 ruling
  2 says selected-gated is default, always-on acceptable if uncluttered).
  My HUD now reports `Rally set (x, y)` so any flag styling change stays in
  sync with the readout. No donor texture was copied.

## Open questions

1. `dock` has data/icon and a paid placement path but `can_place()` rejects
   water (`game.gd:3620`). Should W3-1 add a shore exception so the dock can be
   used for the naval sids, or should the button stay land-only?
2. `bar18`/`dip` hotkeys (`config.json:149-150`) are unchanged: they now work
   but share letters with squad-column/hold-fire. They are only consumed while
   the peasant build menu is open, so there is no live conflict; confirm no
   rebind is wanted (config.json is not mine).
3. Rally cursor tint is a runtime recolour of an existing BMP (private-use rule
   forbids copying `crSetRallyPoint`). Confirm the cyan-green tint reads as
   "rally" in a live window — the headless gate only proves it loads.
4. `t_hud_fidelity.gd:142,147` test-owner update for `(N)` is still outstanding
   (see Test drift). Not edited here.
