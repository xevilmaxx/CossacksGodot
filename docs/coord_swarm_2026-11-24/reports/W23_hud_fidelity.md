---
owner: W2-3
ticket: D-22
date: 2026-11-24
wave: 2
scope: "G-HUD1 fidelity fixes in app/scripts/hud.gd and app/scripts/input_controller.gd only; no test files edited; no donor file run or copied."
method: "Re-read current port source (utf-8) and donor scripts/locale (latin-1, read-only) before editing; verified each claim against current file:line, not board prose. One targeted Godot run via app/tools/godot_runner.py. Diff captured with git diff."
output: "Two source files + this report."
backups: ["inbox/backup/hud.gd.bak-W23", "inbox/backup/input_controller.gd.bak-W23"]
runner_jobs: ["1266 w23-hud FAILED (transient startup, cross-worker Godot overlap)", "1272 w23-hud-retry OK, uitest 17/17"]
---

# W2-3 — HUD fidelity (G-HUD1) — 2026-11-24

## Verification policy

Every row was re-observed in the **current** source before any edit. Donor
root `C:\Games\Cossacks 3\` read-only via Python `open(...,'rb').decode('latin-1')`.
Port read via `open(...,'rb').decode('utf-8')`. No donor asset was executed or
redistributed. No Godot launch outside `godot_runner.py`.

## Gap status table

| # | Gap | Donor evidence (path:line) | Port before (file:line) | Port after (file:line) | Status |
|---|---|---|---|---|---|
| 1a | Resource readout gross `[N]` vs donor net `(income-consumption)` | `data/gui/menu.inc/showresourcepanel.inc:105-125` (`workersonres[ind]`, `rawconsume := floor((resconsume[ind]*32/100)/250)`, `income1 := floor(income-rawconsume)`, `(`/`-`/`)`), `:128-137` legacy gross form; `lib/unit.script:3810` accumulates `resconsume[i]` | `hud.gd:1075` `"%d [%d]"` with no upkeep term | `hud.gd:1141-1157` (now `:1141-1157` in current file; see `RES_STOCK_CAP` block) builds `"<stock>  (<workers>[-<consume>])"`; `hud.gd:1050-1060,1067-1078,1101-1118` derives `consume_raw` from existing `def.eat` (`lib/unit.script:3810` analogue) and converts with the donor `32/100/250` divisor | **FIXED** |
| 1b | Red deficit only food/gold; iron+coal absent | `showresourcepanel.inc:108-125` red when `income1<0` only for `ind>=gc_resource_type_gold`; `data/locale/en/gui.txt:59-60,77-78` (`You have neither coal nor iron... unable to fire`) | `hud.gd:1082-1087` red only `i==0` famine and `i==3` gold | `hud.gd:1158-1167` red on `net<0` for gold/iron/coal; iron/coal additionally use the sim's own `Data.can_pay(res, weapon.cost)` gate from `game.gd:4826` (port's current shot-stop mechanism) | **FIXED** (with documented proxy — see Open questions Q1) |
| 1c | `9999999+` stock cap missing | `data/locale/en/gui.txt:251-252` `9999999+`; `showresourcepanel.inc:101-103` `if not res[ind]>99999999 then text := cTextLotOfResources` | `hud.gd:1075` raw `%d` forever | `hud.gd:103-114` constants `RES_STOCK_CAP := 9999999` / `RES_STOCK_CAP_TEXT := "9999999+"`; `hud.gd:1143-1144` clamp | **FIXED** |
| 2a | Resource hover tooltips missing | `showresourcepanel.inc:28-38,141-144` `resourcehintN` active hit rect + per-resource hint; `data/locale/en/gui.txt:227-248` six `resourcepanel.*.hint` strings | `hud.gd:313-318` six bare `TextureRect`s | `hud.gd:104-116` `RES_TOOLTIPS` (translated/condensed, not verbatim donor bytes), assigned at `hud.gd:334-335` | **FIXED** |
| 2b | Idle-peasant / free-mine-slot indicators plain text, not buttons | `showresourcepanel.inc:219-243` `_img_idlepeasants`/`_btn_idlepeasants`, `_img_idlemines`/`_btn_idlemines`; `eventresourcepanel.inc:35-36` `EmulateGUIShortcut('select\|idlepeasants'/'select\|idlemines')`; `gui.txt:255-258` button labels | `hud.gd:322-327` single `Label`; handlers already existed at `input_controller.gd:837-842,876-881` | `hud.gd:340-352` two `_mkbtn`s with donor labels + `pressed` hooks; `hud.gd:434-445` `_on_select_idle_*` forward through `command_from_hud`; `input_controller.gd:199-225` two new cases + shared `select_idle_peasants()`/`select_idle_mines()`; hotkey branches now call the same methods. Buttons disabled/dim when count is 0 (`hud.gd:1168-1183`) | **FIXED** |
| 3 | Capture % divides by fixed 8.0 s | No donor capture-% literal exists in donor locale/GUI/scripts (R11 Q1, R02 claim 10) — port-internal divergence. Sim requirement `game.gd:5297` `5.0 + max_hp/2500.0`; sim does **not** store `need` on the entity | `hud.gd:889` `/8.0` (W2-1 handoff said `:889`; R11 cited `:886` — line drift) | `hud.gd:925-931` mirrors `5 + max_hp/2500` with clamp, comments that the sim exposes no progress field | **FIXED** (applied per W2-1 handoff) |
| 4 | Minimap bottom-right 240 px vs port bottom-left 200 px | `data/gui/menu.inc/initminimap.inc:5-7` `cMinimapSize = 240`, `:17,29-39` right/bottom-anchored | `hud.gd:1166-1174` 200 px + `anchor_left=0`; `uitest.gd:304-307` asserts `par.anchor_left == 0.0`; `_apply_scale` `hud.gd:244-273` partitions bottom strip around a left minimap | unchanged | **NOT-DONE** — see below |
| 5 | Six resources present / minimap controls / hotkey handlers | donor `dmscript.global:3,791-797`; `gui.txt:5-16`; `eventminimap.inc:8-55` | `hud.gd:329-339`, `hud.gd:1258-1276`, `input_controller.gd:837-842,876-881` | same, no change | **VERIFIED-ALREADY** — no duplicate work |

## Item 4 — why NOT-DONE (no test weakening)

`app/scripts/uitest.gd:306` asserts `hud.minimap_rect.get_parent().anchor_left == 0.0`
and `:307` labels the step `minimap bottom-left`. A genuine move to bottom-right
requires `anchor_left/anchor_right = 1.0` and a bottom-strip re-partition in
`hud.gd:244-273` (the command panel currently occupies the right edge, so
moving the minimap there overlaps it). Changing only `hud.gd` would turn the
gate 16/17; editing `uitest.gd` is forbidden. Per the task rule ("do item 4
only if you can keep uitest green without editing tests"), it was left unchanged.

Needed test change (owned by the test owner, **not** made here):
`uitest.gd:306` → `par.anchor_left == 1.0`; `uitest.gd:307` detail string →
`"minimap bottom-right: ..."`. Pair with the `hud.gd:244-273` layout
re-partition and `hud.gd:1220-1242` geometry change (240 px). No test was
edited and no assertion was weakened.

## Test drift to report (not edited)

`app/tests/t_hud_fidelity.gd:142,147` asserts every resource line contains `[`
and that the wood line contains `[N]`. The donor-backed readout now uses
`(N)`, so that standalone, ready-status test will report
`worker_counts_brackets` FAIL until its owner updates those two assertions to
`(`. The 29-step canonical selftest only checks `hud_report()` booleans
(`selftest.gd:213-219`), and `hud_report()` keeps `worker_counts` unchanged, so
the 29/29 gate is unaffected. Test files were not touched.

## Exact diff

Backups taken before any edit:
`inbox/backup/hud.gd.bak-W23` (64,219 bytes),
`inbox/backup/input_controller.gd.bak-W23` (37,197 bytes).

`git diff -- app/scripts/hud.gd app/scripts/input_controller.gd` at end of work:

```diff
diff --git a/app/scripts/hud.gd b/app/scripts/hud.gd
--- a/app/scripts/hud.gd
+++ b/app/scripts/hud.gd
@@ -11,11 +11,14 @@ var icons_tex: Texture2D
-# Donor-style economy read-outs (RE gap 3 / S11): bracketed worker counts per
-# resource, idle-villager + free mine-slot indicators and a gold deficit flag.
-# All derived from existing game state; no sim-layer changes.
-var eco_label: Label
+# Donor-style economy read-outs (RE gap 3 / S11): net worker counts per
+# resource in ( ), clickable idle-villager + free mine-slot buttons and a
+# per-resource deficit flag. All derived from existing game state; no sim edits.
+var eco_label: Button
+var mines_btn: Button
 var worker_counts: Dictionary = {}
+var upkeep_workers: Dictionary = {}  # donor showresourcepanel.inc:110 rawconsume -> worker units
+var ammo_blocked: Dictionary = {}    # donor gui.txt:59-60/77-78 iron+coal shot stop
 var idle_count := 0
 var free_slots_count := 0
 var gold_deficit := false
@@ -74,6 +77,7 @@ even when the string is identical, so every per-frame label is dirty-flagged.
 var _last_res_text: Array = []
 var _last_eco_text := ""
+var _last_mines_text := ""
 var _last_status_text := "\n"
@@ -97,6 +101,18 @@ const MARKET_TRADABLE := ["food", "wood", "stone", "iron", "coal"]
+# Donor data/locale/en/gui.txt:227-248 (resourcepanel.*.hint). Indexed in
+# Data.RES_NAMES order; the stock icon's hover hint is the donor's hint element.
+const RES_TOOLTIPS := [
+	"Food is produced by peasants in the fields and by fish boats at the port.",
+	"Wood is cut in the forests then stored at storehouses or town halls. Wood is primarily used for building construction.",
+	"Peasants gather stone at stone quarries then store it at storehouses or town halls. Stone is used for construction and for walls and towers.",
+	"Gold is produced at gold mines which can be placed over gold deposits. It recruits and maintains mercenaries and pays for upgrades; without gold, mercenaries rebel.",
+	"Iron is produced at iron mines. It recruits armored units and pays for upgrades and ammunition; without iron, ranged units cannot fire.",
+	"Coal is produced at coal mines. It is used to produce ammunition for ranged units, artillery and ships; without coal, they cannot fire.",
+]
+const RES_STOCK_CAP := 9999999  # donor gui.txt:251-252 "9999999+"
+const RES_STOCK_CAP_TEXT := "9999999+"
@@ -315,16 +331,25 @@ func _build_top() -> void:
 		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
+		# donor showresourcepanel.inc:141-144 resourcehintN hit rect + hint
+		ic.tooltip_text = RES_TOOLTIPS[i]
 		bar.add_child(ic)
 		var l := _mklbl("0", 17, Color(1, 0.97, 0.9))
 		bar.add_child(l)
 		res_labels.append(l)
-	# idle villager + unused mine slots, as in the donor's top strip (S11)
+	# Idle villagers + unused mine slots are donor GUI BUTTONS
+	# (showresourcepanel.inc:219-243, eventresourcepanel.inc:35-36). Both use
+	# the select handlers already wired in input_controller.gd.
 	var eco_sep := VSeparator.new()
 	bar.add_child(eco_sep)
-	eco_label = _mklbl("idle 0  slots 0", 14, Color(0.8, 0.85, 1))
-	eco_label.tooltip_text = "Idle peasants / free mine worker slots"
+	eco_label = _mkbtn("idle 0", 12, 26, 78)
+	eco_label.tooltip_text = "Select all idle peasants"
+	eco_label.pressed.connect(_on_select_idle_peasants)
 	bar.add_child(eco_label)
+	mines_btn = _mkbtn("slots 0", 12, 26, 78)
+	mines_btn.tooltip_text = "Select all unoccupied mines"
+	mines_btn.pressed.connect(_on_select_idle_mines)
+	bar.add_child(mines_btn)
@@ -409,6 +434,18 @@ func _on_menu() -> void:
 	if menu_cb.is_valid():
 		menu_cb.call()
+func _on_select_idle_peasants() -> void:
+	# Donor eventresourcepanel.inc:35 -> EmulateGUIShortcut('select|idlepeasants')
+	var ictl := get_tree().get_first_node_in_group("c3_input")
+	if ictl != null and ictl.has_method("command_from_hud"):
+		ictl.command_from_hud("select_idle_peasants")
+func _on_select_idle_mines() -> void:
+	# Donor eventresourcepanel.inc:36 -> EmulateGUIShortcut('select|idlemines')
+	var ictl := get_tree().get_first_node_in_group("c3_input")
+	if ictl != null and ictl.has_method("command_from_hud"):
+		ictl.command_from_hud("select_idle_mines")
@@ -886,7 +923,12 @@ func _selection_summary(mine: Array) -> String:
 		if float(first.get("capture_t", 0.0)) > 0.1:
-			s += "  CAPTURE %.0f%%" % (float(first.capture_t) / 8.0 * 100.0)
+			# Handoff W2-1 / R2 claim 10: the sim computes the full time locally
+			# at game.gd:5297 (5 + max_hp/2500 s) and does not store it on the
+			# entity, so mirror that expression instead of the old fixed 8.0 s.
+			var need: float = 5.0 + float(first.max_hp) / 2500.0
+			var pct: float = clampf(float(first.capture_t) / maxf(need, 0.001) * 100.0, 0.0, 100.0)
+			s += "  CAPTURE %.0f%%" % pct
@@ -1000,17 +1042,20 @@ func game_over(winner: int) -> void:
-#  - bracketed worker count per resource = peasants gathering that resource,
-#    or miners inside a mine (inside_of -> "mine_<res>" building)
-#  - idle peasants + free mine slots = the donor's two top-bar warnings (S11)
-#  - gold upkeep rate vs mine income rate = the donor's red-negative-upkeep
-#    signal, using the sim's own UPKEEP_DIVISOR / MINE_INCOME_PER_S constants.
+#  - net worker count per resource in ( ) = peasants gathering that resource
+#    (or miners inside a mine) minus the donor's upkeep-in-worker-units term
+#  - idle peasants + free mine slots = the donor's two top-bar BUTTONS (S11)
+#  - gold upkeep rate vs mine income rate keeps the existing deficit signal;
+#    iron/coal use the sim's own shot-cost gate (gui.txt:59-60/77-78) instead.
 func _recompute_eco() -> void:
 	if game == null:
 		return
 	var counts := {}
+	var consume_raw := {}
+	ammo_blocked.clear()
 	for r in Data.RES_NAMES:
 		counts[str(r)] = 0
+		consume_raw[str(r)] = 0
@@ -1022,6 +1067,20 @@ func _recompute_eco() -> void:
 		var eat: Dictionary = e.def.get("eat", {})
 		if eat.has("gold"):
 			gold_upkeep += float(eat["gold"]) / Data.UPKEEP_DIVISOR
+		# Donor lib/unit.script:3810 accumulates resconsume[i] from object consume.
+		for k in eat:
+			if consume_raw.has(str(k)):
+				consume_raw[str(k)] += int(eat[k])
+		# Donor gui.txt:59-60/77-78: iron/coal short => ranged units cannot fire.
+		# game.gd:4826 already gates _fire() on can_pay(res, weapon cost).
+		if str(e.kind) == "unit":
+			for w in e.def.get("weapons", []):
+				var wc: Dictionary = (w as Dictionary).get("cost", {})
+				if (wc.has("iron") or wc.has("coal")) and not Data.can_pay(p.res, wc):
+					if wc.has("iron"):
+						ammo_blocked["iron"] = true
+					if wc.has("coal"):
+						ammo_blocked["coal"] = true
@@ -1042,12 +1101,21 @@ func _recompute_eco() -> void:
 		var eat2: Dictionary = b.def.get("eat", {})
 		if eat2.has("gold"):
 			gold_upkeep += float(eat2["gold"]) / Data.UPKEEP_DIVISOR
+		for k in eat2:
+			if consume_raw.has(str(k)):
+				consume_raw[str(k)] += int(eat2[k])
@@ -1046,6 +1114,10 @@ func _recompute_eco() -> void:
 			if bsid.substr(5) == "gold":
 				gold_income += float(used) * Data.MINE_INCOME_PER_S * float(p.get("mine_mult", 1.0))
+	# Donor showresourcepanel.inc:110: floor((resconsume*32/100)/250) workers.
+	var uw := {}
+	for r in Data.RES_NAMES:
+		var rk := str(r)
+		uw[rk] = int(floor(float(consume_raw[rk]) * 32.0 / 100.0 / 250.0))
+	upkeep_workers = uw
 	worker_counts = counts
@@ -1072,31 +1140,47 @@ func _process(dt: float) -> void:
 	for i in 6:
 		var rname: String = str(Data.RES_NAMES[i])
-		var rt := "%d [%d]" % [int(game.players[0].res[i]), int(worker_counts.get(rname, 0))]
+		var stock: int = int(game.players[0].res[i])
+		var stock_s: String = RES_STOCK_CAP_TEXT if stock > RES_STOCK_CAP else str(stock)
+		# Donor showresourcepanel.inc:101-125: gross workers for food/wood/stone,
+		# (income-consumption) for gold/iron/coal, red when net < 0.
+		var workers: int = int(worker_counts.get(rname, 0))
+		var consume: int = int(upkeep_workers.get(rname, 0)) if i >= 3 else 0
+		var net: int = workers - consume
+		var net_s: String = "(%d-%d)" % [workers, consume] if consume > 0 else "(%d)" % workers
+		var rt := "%s  %s" % [stock_s, net_s]
 		# T-PERF-RENDER: dirty-flagged text (same-string assignment relayouts).
 		while _last_res_text.size() < 6:
 			_last_res_text.append("")
 		if rt != str(_last_res_text[i]):
 			_last_res_text[i] = rt
 			res_labels[i].text = rt
-		# donor colours a resource red when upkeep outruns income/stock
 		var deficit := false
 		if i == 0:
 			deficit = bool(game.players[0].famine)
 		elif i == 3:
-			deficit = gold_deficit or float(game.players[0].get("gold_famine_t", 0.0)) > 0.0
+			deficit = gold_deficit or net < 0 or float(game.players[0].get("gold_famine_t", 0.0)) > 0.0
+		elif i == 4 or i == 5:
+			deficit = net < 0 or bool(ammo_blocked.get(rname, false))
 		if deficit != bool(res_deficit[i]):
 			res_deficit[i] = deficit
 			res_labels[i].add_theme_color_override("font_color", Color(1, 0.42, 0.38) if deficit else Color(1, 0.97, 0.9))
 	if eco_label != null:
-		var et := "idle %d  slots %d" % [idle_count, free_slots_count]
+		var et := "idle %d" % idle_count
 		if et != _last_eco_text:
 			_last_eco_text = et
 			eco_label.text = et
+		eco_label.disabled = idle_count <= 0
 		var warn: bool = idle_count > 0
 		if warn != eco_warn:
 			eco_warn = warn
 			eco_label.add_theme_color_override("font_color", Color(1, 0.45, 0.4) if warn else Color(0.8, 0.85, 1))
+	if mines_btn != null:
+		var mt := "slots %d" % free_slots_count
+		if mt != _last_mines_text:
+			_last_mines_text = mt
+			mines_btn.text = mt
+		mines_btn.disabled = free_slots_count <= 0
@@ -1586,6 +1670,8 @@ func hud_report() -> Dictionary:
 		"worker_counts": worker_counts.duplicate(true),
+		"upkeep_workers": upkeep_workers.duplicate(true),
+		"ammo_blocked": ammo_blocked.duplicate(true),
diff --git a/app/scripts/input_controller.gd b/app/scripts/input_controller.gd
--- a/app/scripts/input_controller.gd
+++ b/app/scripts/input_controller.gd
@@ -199,6 +199,26 @@ func command_from_hud(action: String) -> void:
 		"stop":
 			for e in sel:
 				game.cmd_stop(e)
+		"select_idle_peasants":
+			select_idle_peasants()
+		"select_idle_mines":
+			select_idle_mines()
+
+# HUD top-bar buttons (donor eventresourcepanel.inc:35-36) reuse the same
+# select handlers as the idle-peasant / idle-mine hotkeys below.
+func select_idle_peasants() -> void:
+	var arr: Array = []
+	for e in game.units_of(0):
+		if e.sid == "peasant" and e.order.type == "none" and e.inside_of == 0:
+			arr.append(e)
+	_set_selection(arr)
+
+func select_idle_mines() -> void:
+	var arrm: Array = []
+	for b in game.buildings_of(0):
+		if b.sid.begins_with("mine_") and b.finished and int(b.workers) < int(b.get("slots", b.def.get("slots", 5))):
+			arrm.append(b)
+	_set_selection(arrm)
@@ -835,11 +855,7 @@ func _handle_key(k: InputEventKey) -> void:
 	elif _is(k, "select_idle_mines"):
-		var arrm: Array = []
-		for b in game.buildings_of(0):
-			if b.sid.begins_with("mine_") and b.finished and int(b.workers) < int(b.get("slots", b.def.get("slots", 5))):
-				arrm.append(b)
-		_set_selection(arrm)
+		select_idle_mines()
@@ -874,11 +890,7 @@ func _handle_key(k: InputEventKey) -> void:
 	elif _is(k, "select_idle_peasants"):
-		var arr: Array = []
-		for e in game.units_of(0):
-			if e.sid == "peasant" and e.order.type == "none" and e.inside_of == 0:
-				arr.append(e)
-		_set_selection(arr)
+		select_idle_peasants()
```

(The excerpt above omits a few unchanged context lines for readability; the
authoritative diff is `git diff -- app/scripts/hud.gd app/scripts/input_controller.gd`.)

## Runner evidence

* **1266 `w23-hud`** — `--headless --path app -- --ui-test app/uitest.json`,
  wait 154.8 s, run 17.1 s, exit **1** / status `failed`.
  `app/.godot_queue/results/00001266_w23-hud/stdout.txt` contained **only** the
  Godot version banner; `stderr.txt` was 0 bytes; `app/uitest.json` was NOT
  rewritten (mtime 09:42:22, from coordinator job 1256). Root cause: startup
  failure during concurrent Godot activity, not an assertion or a diff error.
  Timeline (`app/.godot_queue/results/*.json`): 1262 `w24-ai-wave` ran
  10:01:20–10:04:31, 1263 `w27-ambient` 10:03:13–10:03:23,
  1264 `w26-parse-check` 10:03:26–10:03:43, 1265 `w22-data-truth`
  10:03:47–10:04:17, and **1266 started 10:04:23 while 1262 was still alive**.
  A successful uitest prints `sprites: ...` and `ui-test report: ...` (cf. job
  1256); 1266 printed neither. Further proof the diff was not at fault: job
  **1269 `w26-subset`** started 10:07:11, after all W2-3 edits (hud.gd 10:00:24,
  input_controller.gd 10:00:59), loaded the same code and exited **0**.
* **1272 `w23-hud-retry`** — same command, fresh id, wait 91.6 s, run 150.7 s,
  exit **0** / status `ok`. stdout includes `sprites: 116 sets loaded
  (sids=173)` and `ui-test report: .../app/uitest.json`. `app/uitest.json`
  rewritten 10:14:58 with `"passed": true`, **17/17 steps**, zero failed steps
  (including `groups`, `minimap_frustum`, `hotkeys_live`, `order_keys`).
  No full selftest was run by this worker, per instruction.

## Open questions

1. **Q1 iron/coal deficit proxy.** Donor `resconsume` is dynamic and the
   consumed amount is subtracted from the worker count itself
   (`showresourcepanel.inc:108-125`). The port sim has no per-tick iron/coal
   consume counter (`game.gd:4034-4049` tracks food/gold/stone only); iron/coal
   are spent on shot costs at `game.gd:4826,4849` and on training. The port
   therefore uses (a) `def.eat` sums converted with the donor `32/100/250`
   divisor (currently zero for iron/coal in `data.gd`, so the `(N)` part is
   gross) and (b) a bool red flag when `Data.can_pay` fails for a unit's
   iron/coal weapon shot cost — mirroring `gui.txt:59-60,77-78` semantics but
   not the donor's exact arithmetic. Fidelity is semantic, not byte-exact;
   a sim-side `resconsume` counter would be needed for exact parity (owned by
   game.gd, out of scope).
2. **Q2 donor cap inconsistency.** Donor script compares `res > 99999999`
   (8 digits) while the locale label is `9999999+` (7 digits). The port uses
   the locale literal as instructed (`>9999999` → `9999999+`). Confirm which
   threshold the owner wants if byte parity matters.
3. **Q3 tooltip text.** Strings are condensed English rewrites of
   `gui.txt:227-248`, not verbatim copies (donor is private-use read-only).
   No donor image/screenshot was opened to confirm the hint hit-rect width;
   Godot's `tooltip_text` on the `TextureRect` is the closest equivalent.
4. **Q4 minimap.** Item 4 remains open; test change required is documented
   above. The right-edge command panel (`hud.gd:268-273`) must be relocated
   before the minimap can move, or the two panels overlap.
5. **Q5 standalone test drift.** `t_hud_fidelity.gd:142,147` still expects
   `[N]`; coordinate its owner to switch to `(N)` before citing that test as
   green. Not edited here.
6. **Q6 capture %.** Donor has no `%` literal; the port bar is an intentional
   "video pass". The new denominator matches `game.gd:5297`, but if W2-1
   later changes the sim formula, this mirrored expression must be updated in
   lockstep (or better, W2-1 exposes `capture_need` on the entity).
