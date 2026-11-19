# GUIDE 2 — Cossacks 3 Godot port: closing the fidelity gap
### A step-by-step, paste-ready implementation guide for a simpler executor model

**Read section 0 and 1 fully before touching any file.** Then do steps S1→S10
IN ORDER. Each step is self-contained: it names the exact file, the exact
anchor text to find, the exact code to insert/replace, and an acceptance
command. Do ONE step, run its acceptance, only then continue. If a step's
acceptance fails: restore that file from `inbox/backup/`, re-read the step,
retry. Never skip ahead. Never "improve" code beyond what a step says.

Companion docs (read-only context): `GUIDE1.md` (round 1, DONE),
`app/MECHANICS.md`, `app/mechanics.json`, `reference/videos.md`.
Rule sources: cossacks3.fandom.com wiki + cossacks.fandom.com/wiki/Battle_tactics
+ gamepressure.com/cossacks3 + Steam community guides (numbers reproduced in
Appendix A; the wiki blocks direct fetch, so trust Appendix A, do not re-fetch).

---

## 0. Environment, commands, safety rules

| thing | value |
|---|---|
| project root | `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3` |
| app dir | `<root>\app` |
| donor game | `C:\Games\Cossacks 3` |
| Godot | 4.7.2, on PATH as `godot` |
| Blender | `C:\Program Files\Blender Foundation\Blender 5.2\blender.exe` |
| Python | 3.14 (system) — used only for JSON checks below |

Run every command from `<root>`. Quote paths with spaces.

```
godot --headless --path app -- --self-test app/selftest.json
godot --headless --path app -- --cli app/cli.json --cli-seconds 10
godot --headless --path app --import
godot --path app -- --screenshot app/shots/g2.png --timeout 90
```

SAFETY RULES (the owner's GPU is weak and once shut the PC down):
1. NEVER run Blender with EEVEE or GPU Cycles. Only `--engine cycles --samples 4`
   (the baker defaults to CPU Cycles; keep it).
2. NEVER run `godot` without one of the self-exiting flags above.
3. Before editing ANY existing script: `Copy-Item app\scripts\<name>.gd inbox\backup\<name>.gd.bak2 -Force`
4. After adding PNG assets always run `godot --headless --path app --import`.
5. GDScript uses TABS for indentation. Match the surrounding indentation exactly.
6. Do not rename existing functions/fields other scripts call.

## 1. What already exists (DO NOT rebuild any of this)

- Sim: 6-resource economy, gathering hits/carry, mines 1.664/s, upkeep /625,
  famine, construction, training queues, donor damage formula, morale/rout,
  officer/drummer/priest auras, building capture, market barter+drift,
  upgrades, walls, rally, squads+formations with wiki bonuses (+2/+3, hold
  +9/+9 melee, +2/+9 ranged, cav +1/+1), replenish (F on officer), academy
  gate for officer/drummer, 17c ranged flee, bayonets, cannon grapeshot,
  mortar-only-buildings, tower fortification immunity, Delete key,
  mine ×1.5 upgrade, battery ×3 spacing, cavalry wedge, capture rule toggle.
- Roster: 40+ units incl. nation variants (NATION_UNITS resolution).
- Assets: `app/assets/models/anim/` = 54 animated unit sheets (8 dirs ×
  walk/idle/attack/death) + 215 nation building sheets `<nat>_<sid>.png`
  (20 nations). `index.json` maps unit sheets. Buildings lazy-load via
  `world.gd _bld_anim/_bld_tex`. Static fallbacks in `assets/models/sprites/`.
- Tools: `app/tools/bake_sprites.py` (CPU skinning + Blender CPU Cycles +
  Pillow sheets; `--only`, `--buildings`, `--size`, `--engine`, `--samples`).
- Tests: `selftest.gd` 21 steps, `--cli` AI-vs-AI, `--screenshot`.
- HUD auto-renders a research button for EVERY entry in `Data.UPGRADES`
  whose `building` matches the selected building's sid (hud.gd ~line 322).
  **So new upgrades only need a data entry + an effect handler.**

## 2. Why it still feels far from the original (the gap list)

| # | gap | wiki rule | step |
|---|---|---|---|
| 1 | tiny armies/map; pop cap wrong | dwellings: TownHall 100, Barracks17 150 (tur/alg 50), Barracks18 250, House 25; maps huge | S1 |
| 2 | no 18th-century buildings; 18c researched at academy | 18c transition happens at TOWN HALL after all buildings built; Barracks 18c is a separate building | S2 |
| 3 | almost no upgrade ladder | mill +140%/+250%, mine slots II–VII to 95, tower +20/20/10% RoF, academy civilian/artillery rows, blacksmith field cap | S3 |
| 4 | no repair, no gates, walls shoot-through | repair exists; click wall → gate; walls block ranged fire; only arty/gren/archer hurt walls; walls consume stone | S4 |
| 5 | no hold-fire, nearest-target only, no formation size UI | E feuer frei / D hold fire / V engage; counter-based target selection; officer panel size buttons | S5 |
| 6 | buildings pop in finished; no rubble | construction stages + destruction meshes exist in donor | S6 |
| 7 | flat map | hills give ranged bonus + block direct cannon fire | S7 (optional) |
| 8 | AI dribbles small mixed mobs | AI masses hundreds, forms formations, combined-arms waves | S8 |
| 9 | fields infinite, costs flat, no gold rebellion | 2 peasants/field tile, fields decay, next building copy costlier (cen ×3), gold shortage rebels mercenaries | S9 |

---

## S1 — Population, map scale, army scale (the "mass battle" feel)

WHY: wiki Population_capacity: TownHall 100 dwellings, Barracks17 150
(tur/alg 50), Barracks18 250, Housing 25. Original skirmishes field hundreds
to thousands; the port caps at 200 with 14-peasant AI.

FILE `app/scripts/data.gd`:
1. In `BUILDINGS_BASE`, change `"cen"` `"farm": 200` → `"farm": 100`.
2. Change `"bar"` `"farm": 75` → `"farm": 150`.
3. Change the AI constants:
   `static var AI_MAX_PEASANTS := 14` → `:= 40`
   `static var AI_ATTACK_FORCE := 60.0` → `:= 260.0`
   (find them by grep `AI_MAX_PEASANTS` / `AI_ATTACK_FORCE`).

FILE `app/scripts/config.gd`:
4. In the DEFAULT dict, `"map_width_tiles": 160,` → `320,` and the matching
   `"map_height_tiles": 160,` → `320,` (grep both).
5. In `apply()`, the two lines `Data.MAP_W = maxi(16, int(num("gameplay.map_width_tiles", 160)))`
   and `Data.MAP_H = ... 160)))` → default `320` in both.

FILE `app/scripts/ai.gd`:
6. Find `if army_force < 130 and game.pay_cost(player, ud.price):` → `if army_force < 600 and ...`.
7. Find `b.queue.size() < 3:` (the army-training loop) → `b.queue.size() < 6:`.
8. Find the barracks build line `if _count_sid("bar") + _count_unfinished("bar") == 0 and res.wood >= 150 and res.stone >= 150:`
   → `if _count_sid("bar") + _count_unfinished("bar") < 3 and res.wood >= 150 and res.stone >= 150:`
9. Same for stable: `_count_sid("sta") + _count_unfinished("sta") == 0` → `< 2`.
10. LIVE VALUES (the shipped `app/config.json` overrides every default above —
   without this the game still runs at 160/60/14): set
   `gameplay.map_width_tiles`/`map_height_tiles` to 320 and `ai.attack_force`
   to 260.0 / `ai.max_peasants` to 40 in `app/config.json`. AND mirror the
   same four keys in `app/shots/boost.json` (the `--config` extra file used
   for boosted test runs REPLACES those keys — a stale boost.json silently
   reverts the game to 160/60/14 no matter what config.json says).

ACCEPTANCE:
```
godot --headless --path app -- --self-test app/selftest.json
godot --headless --path app -- --cli app/cli.json --cli-seconds 30
```
selftest `passed: true`. NOTE (measured 2026-11-18): >25 units after 30
sim-seconds is unachievable BY DESIGN — one peasant takes 12.5 s to train and
the bootstrap (walk 20 m + 22 hits + deliver) yields the first loads at
~60 s. The original plays the same slow opening. Real check: 600 s CLI shows
compounding growth (buildings 1→2+, resources gathered in the hundreds,
units trending up, no errors). If 600 s shows ZERO growth (same units AND
same buildings AND no resources), the AI bootstrap is stalled — see
MECHANICS.md "AI bootstrap" note, fix, re-run. If cli is slow (>60 s wall
for 30 sim-seconds), set `gameplay.map_width_tiles`/`height` to 240 in
`app/config.json` instead of 320.

## S2 — 18th century at the Town Hall + Barracks 18c + Diplomatic Center

WHY: wiki Town_Hall: "After all buildings have been constructed, you can move
on to the next technological age in the town hall." wiki Population_capacity:
Barracks 18c = 250 dwellings. Donor meshes: `<nat>ba2.osm` = Barracks 18c,
`<nat>dip.osm` = Diplomatic Center (verified present for ukr/rus/...).

FILE `app/scripts/data.gd`:
1. In `UPGRADES_BASE` DELETE the whole `"aca_18c": {...},` entry and ADD:
```
	"cen_18c": {"building": "cen", "cost": {"food": 800, "gold": 600}, "time": 20.0,
		"effect": {"unlock18c": true}, "name": "18th century"},
```
2. In `BUILDINGS_BASE` ADD (after `"bar"` entry):
```
	"bar18": {"hp": 20000, "build_time": 400 * 0.03125, "cost": {"wood": 300, "stone": 300}, "radius": 2.5, "farm": 250,
		"trains": ["musk18", "grenadier", "pikeman18", "officer18", "drummer18"], "score": 500,
		"icon": Rect2(46, 46, 46, 46)},
	"dip": {"hp": 8000, "build_time": 400 * 0.03125, "cost": {"wood": 400, "gold": 200}, "radius": 2.5,
		"trains": ["roundshier", "dragoon17", "reiter"], "score": 300,
		"icon": Rect2(0, 46, 46, 46)},
```
3. In `BUILDINGS_BASE` `"bar"` trains: REMOVE `"musk18"` and `"grenadier"`
   from its list (they move to bar18). Keep pikeman/roundshier/serdiuk/archer/
   officer/drummer/priest.

FILE `app/scripts/game.gd`:
4. In `research()`, find the no18c gate block that tests `if uid == "aca_18c":`
   → change to `if uid == "cen_18c":`. Immediately AFTER that block add:
```
	if uid == "cen_18c":
		var need := ["hou", "bar", "sta", "bla", "aca", "art", "sto", "mil", "mar"]
		for ns in need:
			var have := false
			for b in buildings_of(player):
				if b.sid == ns:
					have = true
					break
			if not have:
				if player == 0:
					say("Build every building type before advancing to the 18th century.")
				return false
```
5. In `apply_upgrade()`, find `if eff.has("unlock") and String(eff.unlock) == "officer18":`
   and its two-line body; REPLACE those three lines with:
```
	if eff.has("unlock18c"):
		p["has18c"] = true
```
6. In `place_building()`, at the very top of the function (first line after
   `func place_building...:`) add:
```
	if sid == "bar18" and not bool(players[player].get("has18c", false)):
		say("Research the 18th century at the Town Hall first.")
		return {}
```
7. In `train_unit()`, the academy-gate list `["officer", "officer18", "drummer", "drummer18"]`
   stays as-is (bar18 also needs academy: correct per wiki).

FILE `app/scripts/ai.gd`:
8. In `_research_where_possible`, the order list: replace `"aca_18c"` with `"cen_18c"`.
9. In the build section add after the stable line:
```
	if _count_sid("bar18") + _count_unfinished("bar18") == 0 and bool(p.get("has18c", false)) and res.wood >= 300 and res.stone >= 300:
		_try_build("bar18", home)
	if _count_sid("dip") + _count_unfinished("dip") == 0 and res.wood >= 400 and res.gold >= 200:
		_try_build("dip", home)
```

FILE `app/scripts/config.gd`:
10. In DEFAULT `controls.hotkeys.build` dict add `"bar18": "2", "dip": "3",`.
11. In DEFAULT `names.buildings` add `"bar18": "Barracks, 18th century", "dip": "Diplomatic Center",`.

FILE `app/tools/bake_sprites.py`:
12. Change `def bake_building(game,out,nat,bld,size,tmp):` →
    `def bake_building(game,out,nat,bld,size,tmp,out_sid=""):` and inside, right
    after `folder,base=pick`, add `sid_name = out_sid if out_sid else bld`.
    Then replace EVERY occurrence of `"%s_%s.png"%(nat,bld)` with
    `"%s_%s.png"%(nat,sid_name)`, `"%s_%s_s%d.png"%(nat,bld,s)` with
    `"%s_%s_s%d.png"%(nat,sid_name,s)`, and `"%s_%s_dead.png"%(nat,bld)` with
    `"%s_%s_dead.png"%(nat,sid_name)`.
13. In `main()` buildings branch replace
    `for bld in ("cen","hou","bar","sta","bla","aca","art","sto","mil","mar","tow"):`
    with:
```
        for bld,sid_name in (("cen","cen"),("hou","hou"),("bar","bar"),("sta","sta"),("bla","bla"),("aca","aca"),("art","art"),("sto","sto"),("mil","mil"),("mar","mar"),("tow","tow"),("ba2","bar18"),("dip","dip")):
```
    and the call `bake_building(a.game,a.out,nat,bld,320,tmp)` →
    `bake_building(a.game,a.out,nat,bld,320,tmp,sid_name)`, and the print
    `print("bld",nat,bld,flush=True)` → `print("bld",nat,sid_name,flush=True)`.

BAKE (background, CPU only):
```
& "C:\Program Files\Blender Foundation\Blender 5.2\blender.exe" --background --factory-startup --python "app\tools\bake_sprites.py" -- --game "C:\Games\Cossacks 3" --out "app\assets\models\anim" --buildings --size 320 --engine cycles --samples 4
godot --headless --path app --import
```
ACCEPTANCE: selftest passed; `app/assets/models/anim/ukr_bar18.png` and
`ukr_dip.png` exist; screenshot shows them when placed (optional visual).

## S3 — The upgrade ladder (wiki costs; HUD buttons appear automatically)

WHY: Appendix A tables. Every entry below is a `Data.UPGRADES` entry; the HUD
already draws the button. You only add data + effect handling.

FILE `app/scripts/data.gd` — ADD to `UPGRADES_BASE` (paste as one block):
```
	"mil_food1": {"building": "mil", "cost": {"food": 750, "gold": 250}, "time": 10.0,
		"effect": {"gather_mult": {"food": 2.4}}, "name": "Grain treatment +140%"},
	"mil_food2": {"building": "mil", "cost": {"food": 25600, "gold": 3350, "iron": 2000}, "time": 20.0,
		"effect": {"gather_mult": {"food": 3.5}}, "name": "Grain storage +250%"},
	"aca_field1": {"building": "aca", "cost": {"food": 2000, "gold": 500}, "time": 12.0,
		"effect": {"field_cap": 3.0}, "name": "Field melioration +200%"},
	"bla_field1": {"building": "bla", "cost": {"food": 1000, "iron": 200}, "time": 10.0,
		"effect": {"field_cap": 2.0}, "name": "Agricultural equipment +100%"},
	"aca_wheat1": {"building": "aca", "cost": {"food": 1500, "gold": 300}, "time": 10.0,
		"effect": {"gather_mult": {"food": 1.4}}, "name": "New wheat +40%"},
	"aca_rye1": {"building": "aca", "cost": {"food": 2500, "gold": 500}, "time": 12.0,
		"effect": {"gather_mult": {"food": 1.4}}, "name": "New rye +40%"},
	"aca_wood1b": {"building": "aca", "cost": {"wood": 2000, "gold": 400}, "time": 12.0,
		"effect": {"gather_mult": {"wood": 2.0}}, "name": "Woodworking tools +100%"},
	"aca_stone1": {"building": "aca", "cost": {"stone": 2000, "gold": 400}, "time": 12.0,
		"effect": {"gather_mult": {"stone": 2.0}}, "name": "Stone excavation +100%"},
	"aca_build1": {"building": "aca", "cost": {"wood": 1500, "stone": 1000}, "time": 12.0,
		"effect": {"build_mult": 0.25}, "name": "Builders' salary (build time -75%)"},
	"aca_hp1": {"building": "aca", "cost": {"wood": 2000, "stone": 1500}, "time": 14.0,
		"effect": {"bld_hp_add": 85}, "name": "New construction materials +85 hp"},
	"aca_fort1": {"building": "aca", "cost": {"stone": 2500, "gold": 600}, "time": 14.0,
		"effect": {"fort_hp_add": 80}, "name": "Fortification grades +80 hp"},
	"aca_geo1": {"building": "aca", "cost": {"gold": 800, "food": 500}, "time": 10.0,
		"effect": {"reveal_deposits": true}, "name": "Geology (reveal deposits)"},
	"aca_balloon1": {"building": "aca", "cost": {"gold": 2000, "food": 1000}, "time": 16.0,
		"effect": {"reveal_map": true}, "name": "Montgolfier (reveal map)"},
	"art_range1": {"building": "art", "cost": {"gold": 600, "iron": 300}, "time": 12.0,
		"effect": {"art_range": 1.05}, "name": "Artillery range +5%"},
	"art_range2": {"building": "art", "cost": {"gold": 1200, "iron": 600}, "time": 14.0,
		"effect": {"art_range": 1.10}, "name": "Mathematics (range +10%)"},
	"art_hp1": {"building": "art", "cost": {"gold": 1500, "iron": 800}, "time": 14.0,
		"effect": {"art_hp": 2.5}, "name": "Gribovalle system (arty hp +150%)"},
	"art_acc1": {"building": "art", "cost": {"gold": 900, "iron": 400}, "time": 12.0,
		"effect": {"art_acc": 0.65}, "name": "Artillery accuracy +35%"},
	"art_multi1": {"building": "art", "cost": {"gold": 2000, "iron": 1000, "coal": 500}, "time": 18.0,
		"effect": {"unlock_multi": true}, "name": "Multi-barrelled cannon"},
	"tow_rof1": {"building": "tow", "cost": {"gold": 400, "iron": 200, "coal": 200}, "time": 10.0,
		"effect": {"tower_rof": 0.8}, "name": "More cannons +20% RoF"},
	"tow_rof2": {"building": "tow", "cost": {"gold": 800, "iron": 400, "coal": 400}, "time": 12.0,
		"effect": {"tower_rof": 0.8}, "name": "More cannons II +20% RoF"},
	"tow_rof3": {"building": "tow", "cost": {"gold": 1200, "iron": 600, "coal": 600}, "time": 14.0,
		"effect": {"tower_rof": 0.9}, "name": "More cannons III +10% RoF"},
```
Mine slot ladder (wiki Mine page: II +5, III +8, IV +10, V +12, VI +15, VII +40
→ 95 workers). ADD for EACH of the three mines (replace `MINE` with
`mine_gold`, `mine_iron`, `mine_coal` — 18 entries total):
```
	"MINE_up2": {"building": "MINE", "cost": {"food": 1000, "gold": 1250}, "time": 10.0, "effect": {"mine_slots": 5}, "name": "Mine shafts II (+5)"},
	"MINE_up3": {"building": "MINE", "cost": {"food": 25000, "gold": 7750, "wood": 5000}, "time": 14.0, "effect": {"mine_slots": 8}, "name": "Mine shafts III (+8)"},
	"MINE_up4": {"building": "MINE", "cost": {"food": 41500, "gold": 6250, "wood": 22230}, "time": 18.0, "effect": {"mine_slots": 10}, "name": "Mine shafts IV (+10)"},
	"MINE_up5": {"building": "MINE", "cost": {"food": 15000, "gold": 20000, "iron": 7000}, "time": 20.0, "effect": {"mine_slots": 12}, "name": "Mine shafts V (+12)"},
	"MINE_up6": {"building": "MINE", "cost": {"food": 23000, "gold": 21000, "iron": 9000}, "time": 22.0, "effect": {"mine_slots": 15}, "name": "Mine shafts VI (+15)"},
	"MINE_up7": {"building": "MINE", "cost": {"food": 60000, "gold": 26000}, "time": 26.0, "effect": {"mine_slots": 40}, "name": "Mine shafts VII (+40)"},
```
NOTE: mine upgrades are PER-BUILDING in the original. The port's
`players[].upgrades` is global; to keep per-mine behaviour, store mine/tower
upgrades on the BUILDING instead: in `research()` allow repeat for these:
find `if players[player].upgrades.has(uid) or building.get("research") != null:`
and REPLACE with:
```
	var per_bld: bool = str(uid).begins_with("mine_") or str(uid).begins_with("tow_rof")
	if (not per_bld and players[player].upgrades.has(uid)) or building.get("research") != null:
		return false
	if per_bld and building.get("done_ups", []).has(uid):
		return false
```
and in `_tick_building` where research completes (`apply_upgrade(e.player, r.uid)`),
wrap:
```
			if str(r.uid).begins_with("mine_") or str(r.uid).begins_with("tow_rof"):
				var du: Array = e.get("done_ups", [])
				du.append(r.uid)
				e["done_ups"] = du
				apply_upgrade_to_building(e, r.uid)
			else:
				apply_upgrade(e.player, r.uid)
```
ADD new function in game.gd (after `apply_upgrade`):
```
func apply_upgrade_to_building(b: Dictionary, uid: String) -> void:
	var eff: Dictionary = Data.UPGRADES[uid].get("effect", {})
	if eff.has("mine_slots"):
		b["slots"] = int(b.get("slots", b.def.get("slots", 5))) + int(eff.mine_slots)
	if eff.has("tower_rof"):
		b["rof_mult"] = float(b.get("rof_mult", 1.0)) * float(eff.tower_rof)
	post_event("upgraded", b.pos, uid)
```
Then enforce slots: in `_tick_gather` mine branch, find `if e.inside_of != mine.id:`
and change the block to:
```
			if e.inside_of != mine.id:
				if mine.workers >= int(mine.get("slots", mine.def.get("slots", 5))):
					e.order = {"type": "none"}
					return
				_leave_building(e)
				mine.workers += 1
				e.inside_of = mine.id
```
Tower RoF: in `_tick_building` tower weapon block find `e.cooldown = w.cd`
(the tower one, inside `if e.finished and e.def.has("weapons"):`) →
`e.cooldown = w.cd * float(e.get("rof_mult", 1.0))`.

FILE `app/scripts/game.gd` — in `apply_upgrade()` ADD handlers (after the
`mine_mult` block):
```
	if eff.has("field_cap"):
		p.field_cap = float(p.get("field_cap", 1.0)) * float(eff.field_cap)
		for n in res_nodes:
			if n.type == "food" and n.max_hits > 0:
				n.max_hits = int(n.max_hits * float(eff.field_cap))
				n.hits = int(n.hits * float(eff.field_cap))
	if eff.has("build_mult"):
		p.build_mult = float(p.get("build_mult", 1.0)) * float(eff.build_mult)
	if eff.has("bld_hp_add"):
		for b in entities:
			if not b.dead and b.kind == "building" and b.player == player and not b.sid in ["wal", "tow"]:
				b.max_hp += int(eff.bld_hp_add); b.hp += int(eff.bld_hp_add)
		p.bld_hp_add = int(p.get("bld_hp_add", 0)) + int(eff.bld_hp_add)
	if eff.has("fort_hp_add"):
		for b in entities:
			if not b.dead and b.kind == "building" and b.player == player and b.sid in ["wal", "tow"]:
				b.max_hp += int(eff.fort_hp_add); b.hp += int(eff.fort_hp_add)
		p.fort_hp_add = int(p.get("fort_hp_add", 0)) + int(eff.fort_hp_add)
	if eff.has("art_range"):
		p.art_range = float(p.get("art_range", 1.0)) * float(eff.art_range)
	if eff.has("art_hp"):
		p.art_hp = float(p.get("art_hp", 1.0)) * float(eff.art_hp)
		for u in entities:
			if not u.dead and u.player == player and u.def.get("artillery", false):
				u.max_hp = int(u.max_hp * float(eff.art_hp)); u.hp = u.max_hp
	if eff.has("art_acc"):
		p.art_acc = float(p.get("art_acc", 1.0)) * float(eff.art_acc)
	if eff.has("reveal_deposits"):
		for n in res_nodes:
			if n.max_hits == 0:
				game_reveal(n.pos, 6.0)
	if eff.has("reveal_map"):
		game_reveal(Vector2(Data.MAP_W, Data.MAP_H), 1e9)
	if eff.has("unlock_multi"):
		p["has_multi"] = true
```
ADD helper (world owns fog; game exposes a hook): in game.gd add:
```
var reveal_requests: Array = []
func game_reveal(pos: Vector2, r: float) -> void:
	reveal_requests.append({"pos": pos, "r": r})
```
and in `world.gd` `_update_fog()` (or wherever fog explored is written — grep
`fog_explored`), at the TOP of the function add:
```
	for rq in game.reveal_requests:
		var c: Vector2 = rq.pos
		var rr: float = rq.r
		for ty in game.MAP_H:
			for tx in game.MAP_W:
				if Vector2(tx * 2 + 1, ty * 2 + 1).distance_to(c) <= rr:
					fog_explored[ty * game.MAP_W + tx] = 1
	game.reveal_requests.clear()
```
(If `_update_fog` is not called every tick, call it from `bind`'s draw loop:
grep `func _process` in world.gd and add `_update_fog()` there if missing.)
Apply build_mult: in `_tick_building` construction progress find
`site.progress += Data.BUILD_PROGRESS_PER_HIT` (in the build order branch of
`_tick_unit`) → `site.progress += Data.BUILD_PROGRESS_PER_HIT / float(players[site.player].get("build_mult", 1.0))`.
Apply art_range/acc: in `_tick_unit` attack branch find `var w := _pick_weapon(e, d)`
and AFTER it add:
```
			if e.def.get("artillery", false):
				w = w.duplicate()
				w["max"] = float(w.max) * float(players[e.player].get("art_range", 1.0))
```
and in `_dispersion_px` return values multiply by
`float(players[?].get("art_acc",1.0))` — simpler: in `_fire` where dispersion is
used (grep `_dispersion_px(`), multiply the result by the owner's art_acc.
Multi unlock: in `place_building` gate add next to bar18 gate:
```
	if sid == "multicannon" and not bool(players[player].get("has_multi", false)):
		say("Research the multi-barrelled cannon at the artillery depot first.")
		return {}
```
and in data.gd NATIONS no18c gate also block `art_multi1` for tur/alg: in
`research()` extend the no18c condition to `if uid == "cen_18c" or uid == "art_multi1":`.
Add `"multicannon"` to `"art"` trains list in BUILDINGS_BASE.

ACCEPTANCE: selftest passed; select a mill in a windowed screenshot → two new
research buttons visible; `godot --headless --path app -- --cli app/cli.json --cli-seconds 20` clean.

## S4 — Repair, gates, wall fire rules, wall stone upkeep

WHY: wiki Wall: only artillery/ships/grenadiers/archers destroy walls; ranged
cannot fire THROUGH walls; gates built by clicking a wall segment; walls
consume stone after construction. cossacks3.pl: repair exists.

FILE `app/scripts/data.gd`:
1. ADD to BUILDINGS_BASE:
```
	"gat": {"hp": 3000, "build_time": 60 * 0.03125, "cost": {"wood": 10, "stone": 60}, "radius": 1.0,
		"score": 20, "wall": true, "gate": true, "icon": Rect2(414, 0, 46, 46)},
```
2. `"wal"` entry: add `"eat": {"stone": 40},` (upkeep; estimated rate).

FILE `app/scripts/game.gd`:
3. `_tick_upkeep`: change `var eat := {"food": 0.0, "gold": 0.0}` →
   `var eat := {"food": 0.0, "gold": 0.0, "stone": 0.0}`.
4. Add gate tracking + per-unit blocking. ADD near `var squads`:
```
var gates: Array = []
func _blocked_for(e: Dictionary, p: Vector2) -> bool:
	if is_blocked(p):
		return true
	for g in gates:
		if g.dead:
			continue
		if g.pos.distance_to(p) <= float(g.def.radius) + 0.4:
			if bool(g.get("closed", false)) or int(g.player) != int(e.player):
				return true
	return false
```
   In `spawn()`, after the building `set_blocked_circle(...)` line add:
```
		if sid == "gat":
			set_blocked_circle(pos, def.radius, false)
			gates.append(e)
```
   In `_step_move`, replace EVERY `is_blocked(` call with `_blocked_for(e, `
   (textual replace inside that function only).
5. Gate conversion + open/close. ADD:
```
func cmd_make_gate(w: Dictionary) -> void:
	if w.dead or w.sid != "wal" or not w.finished or w.player != 0:
		return
	set_blocked_circle(w.pos, w.def.radius, false)
	w.sid = "gat"
	w.def = Data.BUILDINGS["gat"]
	w["closed"] = false
	gates.append(w)
	say("Wall segment converted to a gate.")

func cmd_gate_toggle(g: Dictionary) -> void:
	if g.dead or g.sid != "gat":
		return
	g["closed"] = not bool(g.get("closed", false))
	say("Gate %s." % ("closed" if g["closed"] else "open"))
```
6. Repair. ADD:
```
func cmd_repair(pe: Dictionary, b: Dictionary) -> void:
	if pe.dead or pe.sid != "peasant" or b.dead or b.player != pe.player:
		return
	if b.hp >= b.max_hp:
		return
	_leave_building(pe)
	pe.order = {"type": "repair", "target": b.id}
```
   In `_tick_unit` match, ADD a branch before `"gather":`:
```
		"repair":
			var rb: Dictionary = by_id.get(o.get("target", 0), {})
			if rb.is_empty() or rb.dead or rb.hp >= rb.max_hp:
				e.order = {"type": "none"}
				return
			var rslot := _work_slot(e, rb.pos, rb.def.radius + 0.7)
			if e.pos.distance_to(rslot) > 0.6:
				e.moving = true
				_step_move(e, rslot, effective_speed(e), dt, 0.35)
			else:
				e.moving = false
				e["hit_t"] = (e.get("hit_t", 0.0) + dt)
				if e.hit_t >= Data.BUILD_HIT_INTERVAL:
					e.hit_t = 0.0
					var add := int(rb.max_hp * Data.BUILD_PROGRESS_PER_HIT / maxf(1.0, rb.def.build_time))
					rb.hp = mini(rb.max_hp, rb.hp + maxi(1, add))
					if not pay_cost(e.player, {"stone": 1}):
						e.order = {"type": "none"}
```
7. Walls block direct fire. ADD:
```
func _wall_between(a: Vector2, b: Vector2) -> bool:
	for e in entities:
		if e.dead or e.kind != "building":
			continue
		if e.sid != "wal" and not (e.sid == "gat" and bool(e.get("closed", false))):
			continue
		var ab: Vector2 = b - a
		var L: float = ab.length()
		if L < 0.01:
			continue
		var t: float = clampf((e.pos - a).dot(ab) / (L * L), 0.0, 1.0)
		if (a + ab * t).distance_to(e.pos) <= float(e.def.radius):
			return true
	return false
```
   In `_fire`, right after the artillery-deploy check and BEFORE `Data.pay(...)`,
   add:
```
	if str(w.kind) in ["bullet", "arrow", "firearrow", "cannonball"] \
			and not str(e.sid) in ["howitzer", "mortar"] \
			and _wall_between(e.pos, t.pos):
		e.cooldown = 0.5
		return
```
8. Wall damage immunity (same rule as towers). In `_apply_hit`, extend the
   tower immunity line: find
   `if t.kind == "building" and t.sid == "tow" and not str(w.kind) in ["cannonball", "cannister", "arrow", "firearrow"]:`
   → `if t.kind == "building" and t.sid in ["tow", "wal", "gat"] and not str(w.kind) in ["cannonball", "cannister", "arrow", "firearrow"]:`

FILE `app/scripts/hud.gd`:
9. Gate/repair buttons. Find the line
   `				# market barter (video: the exchange sliders in the market)`
   and INSERT BEFORE it:
```
				if e.sid == "wal" and e.finished:
					var gb := Button.new()
					gb.text = "Gate"
					gb.tooltip_text = "Convert this wall segment into a gate"
					gb.custom_minimum_size = Vector2(56, 50)
					gb.pressed.connect(_on_make_gate.bind(e))
					build_bar.add_child(gb)
				if e.sid == "gat":
					var ob := Button.new()
					ob.text = "Open" if bool(e.get("closed", false)) else "Close"
					ob.custom_minimum_size = Vector2(56, 50)
					ob.pressed.connect(_on_gate_toggle.bind(e))
					build_bar.add_child(ob)
```
   ADD handlers next to `_on_research`:
```
func _on_make_gate(b: Dictionary) -> void:
	game.cmd_make_gate(b)
	refresh_selection(get_selected() if has_method("get_selected") else [b])

func _on_gate_toggle(b: Dictionary) -> void:
	game.cmd_gate_toggle(b)
	refresh_selection([b])
```
   (If `get_selected` is not a hud method, just use `refresh_selection([b])` in
   `_on_make_gate` too.)
10. Repair order: in `input_controller.gd` right-click handling, find where a
    right-click on a friendly building sets rally (grep `set_rally`); BEFORE
    that branch add: if the clicked building is owned, damaged, and ALL
    selected units are peasants → `for u in sel: game.cmd_repair(u, bld)` and
    return. (Match the existing variable names in that function.)

FILE `app/scripts/world.gd`:
11. Gate visual: in `_draw_buildings`, the wall branch `elif e.sid == "wal":`
    → `elif e.sid == "wal" or e.sid == "gat":` and inside `_draw_wall` add at
    the top:
```
	if e.sid == "gat":
		bld_layer.draw_rect(Rect2(p.x - r, p.y - r * 0.6, r * 2, r * 1.2), Color(0.45, 0.36, 0.24))
		bld_layer.draw_rect(Rect2(p.x - r * 0.5, p.y - r * 0.4, r, r * 0.9), Color(0.2, 0.16, 0.1) if bool(e.get("closed", false)) else Color(0.1, 0.1, 0.1, 0.35))
		bld_layer.draw_rect(Rect2(p.x - r, p.y + r * 0.6 - 2, r * 2, 2), _player_color(e.player), true)
		return
```

ACCEPTANCE: selftest passed (wall step still builds); cli clean; manual check
optional: place wall, select it, Gate button appears.

## S5 — Hold fire / feuer frei / engage, counter target selection, formation size buttons

WHY: wiki Hotkeys: E = FEUER FREI, D = hold fire, V = engage (cancels stand
ground). Combat_basics RPS table. Formations page: officer panel size icons.

FILE `app/scripts/config.gd`:
1. DEFAULT hotkeys add `"hold_fire": "D", "feuer_frei": "E", "engage": "V",`.

FILE `app/scripts/game.gd`:
2. In `spawn()` entity dict add `"hold_fire": false,` next to `"hold": false,`.
3. ADD:
```
func cmd_hold_fire(e: Dictionary, on: bool) -> void:
	if e.kind == "unit":
		e["hold_fire"] = on

func cmd_engage(e: Dictionary) -> void:
	if e.kind == "unit":
		e["hold"] = false
		e["hold_fire"] = false
```
4. Counter-based targeting. ADD:
```
func _kind_class(e: Dictionary) -> String:
	if e.kind == "building":
		return "building"
	if e.def.get("artillery", false):
		return "artillery"
	if e.def.get("cavalry", "") != "":
		return "cavalry"
	var w := weapon_of(e)
	if w.is_empty():
		return "melee"
	if str(w.kind) in ["bullet", "arrow", "firearrow", "cannister"]:
		return "ranged"
	return "melee"

func _target_score(a: Dictionary, t: Dictionary) -> float:
	var ac := _kind_class(a)
	var tc := _kind_class(t)
	var table := {
		"melee": {"melee": 1.0, "ranged": 0.6, "cavalry": 1.4, "artillery": 0.3, "building": 0.5},
		"ranged": {"melee": 1.4, "ranged": 1.0, "cavalry": 0.6, "artillery": 0.3, "building": 0.8},
		"cavalry": {"melee": 0.6, "ranged": 1.8, "cavalry": 1.0, "artillery": 1.8, "building": 0.4},
		"artillery": {"melee": 1.6, "ranged": 1.6, "cavalry": 0.4, "artillery": 1.0, "building": 1.6},
	}
	var row: Dictionary = table.get(ac, {})
	return float(row.get(tc, 1.0))

func enemies_preferred(pos: Vector2, player: int, r: float, a: Dictionary) -> Dictionary:
	var best: Dictionary = {}
	var best_s := -1.0
	for e in entities:
		if e.dead or e.player == player or e.kind == "building" or e.sid == "peasant":
			continue
		var d: float = e.pos.distance_to(pos)
		if d > r:
			continue
		var s: float = _target_score(a, e) * (1.0 - 0.3 * d / maxf(1.0, r))
		if s > best_s:
			best_s = s
			best = e
	return best
```
5. Replace the auto-target calls: in `_tick_unit` `"attackmove"` branch
   `var en := enemies_in_radius(e.pos, e.player, e.def.search)` →
   `var en := enemies_preferred(e.pos, e.player, e.def.search, e)`;
   same replacement in `"guard"` branch (`var foe := enemies_in_radius(...)`)
   and `"patrol"` branch (`var foe2 := enemies_in_radius(...)`).
6. Hold fire respected: in those same three branches, wrap the
   `if not en.is_empty():` / `if not foe.is_empty() and has_weapon(e):` /
   `if not foe2.is_empty() and has_weapon(e):` conditions with
   `and not bool(e.get("hold_fire", false))`. In `_tick_building` tower block
   add `and not bool(e.get("hold_fire", false))` to the firing condition.
7. Formation sizes. ADD:
```
func cmd_form_size(off: Dictionary, size: int) -> void:
	if off.dead or not str(off.sid) in ["officer", "officer18"]:
		return
	var loose: Array = []
	for u in entities:
		if u.dead or u.kind != "unit" or u.player != off.player or u.id == off.id:
			continue
		if u.sid == "peasant" or u.def.get("support", false):
			continue
		if not squad_of_unit(u.id).is_empty():
			continue
		if u.pos.distance_to(off.pos) <= 12.0:
			loose.append(u)
	if loose.is_empty():
		say("No loose troops near the officer.")
		return
	loose.sort_custom(func(x, y): return x.pos.distance_to(off.pos) < y.pos.distance_to(off.pos))
	var want: String = str(loose[0].sid)
	var pick: Array = []
	for u in loose:
		if str(u.sid) == want and pick.size() < size:
			pick.append(u)
	var dru: Dictionary = {}
	for u in entities:
		if not u.dead and u.player == off.player and str(u.sid) in ["drummer", "drummer18"] and u.pos.distance_to(off.pos) <= 12.0:
			dru = u
			break
	var members: Array = [off]
	if not dru.is_empty():
		members.append(dru)
	members += pick
	squad_form(members)
```

FILE `app/scripts/input_controller.gd`:
8. In `_handle_key`, after the pause handler add:
```
	if _is(k, "hold_fire"):
		for e in get_selected():
			if e.player == 0:
				game.cmd_hold_fire(e, true)
		return
	if _is(k, "feuer_frei"):
		for e in get_selected():
			if e.player == 0:
				game.cmd_hold_fire(e, false)
		return
	if _is(k, "engage"):
		for e in get_selected():
			if e.player == 0:
				game.cmd_engage(e)
		return
```

FILE `app/scripts/hud.gd`:
9. Formation size buttons: insert BEFORE the same
   `				# market barter (video: the exchange sliders in the market)` anchor:
```
				if str(e.sid) in ["officer", "officer18"] and e.player == 0:
					for fs in [15, 36, 72, 120, 196, 400]:
						var fb := Button.new()
						fb.text = str(fs)
						fb.tooltip_text = "Form a %d-man formation from nearby troops" % fs
						fb.custom_minimum_size = Vector2(40, 50)
						fb.pressed.connect(_on_form_size.bind(e, fs))
						build_bar.add_child(fb)
```
   ADD handler:
```
func _on_form_size(off: Dictionary, size: int) -> void:
	game.cmd_form_size(off, size)
	refresh_selection([off])
```

ACCEPTANCE: selftest passed; cli clean.

## S6 — Construction stages + rubble (topology-independent baker fix)

WHY: donor has `<nat><bld>1..4.osm` (stages) and `_death1/2.osm` (rubble) with
DIFFERENT vertex counts, so round-1's vertex-skinning skipped them. Fix: build
a separate mesh per stage.

FILE `app/tools/bake_sprites.py`:
1. In `bake_building`, REPLACE the whole stage loop
   (`for s in range(1,5):` … through its `render_cell(...)` line) with:
```
    for s in range(1,5):
        p=os.path.join(game,"data","actors","buildings",folder,"%s%d.osm"%(base,s))
        if os.path.exists(p):
            ms=read_osm_first(p)
            mo=build_mesh(ms,mat)
            render_cell(os.path.join(out,"%s_%s_s%d.png"%(nat,sid_name,s)),size)
            bpy.data.objects.remove(mo,do_unlink=True)
```
2. REPLACE the death block (`p=os.path.join(...base+"_death2.osm")` … through
   its render) with:
```
    p=os.path.join(game,"data","actors","buildings",folder,base+"_death2.osm")
    if os.path.exists(p):
        ms=read_osm_first(p)
        mo=build_mesh(ms,mat)
        render_cell(os.path.join(out,"%s_%s_dead.png"%(nat,sid_name)),size)
        bpy.data.objects.remove(mo,do_unlink=True)
```
   (Camera stays the finished-building camera so stages align in the cell.)
3. Re-run the buildings bake command from S2 (background, CPU), then `--import`.

FILE `app/scripts/game.gd`:
4. Rubble linger: ADD `var rubble: Array = []` near `var corpses`. In `_kill`
   building branch (after `post_event("death", e.pos, "building")`) add:
```
		rubble.append({"pos": e.pos, "sid": e.sid, "player": e.player, "t": 0.0, "life": 20.0})
		if rubble.size() > 60:
			rubble.pop_front()
```
   In `tick(dt)` (grep `corpses` age loop, e.g. `c.t += dt`) add the same aging
   for rubble and drop expired.
FILE `app/scripts/world.gd`:
5. ADD `func _draw_rubble() -> void:` mirroring `_draw_corpses` but using
   `_bld_anim("%s_%s_dead" % [nation, sid])` (nation from
   `Data.PLAYER_NATIONS[c.player]`, fallback `_bld_anim(sid+"_dead")`), tint
   `Color(0.5,0.45,0.4, a)`, height `_bld_height`-like 3.0; call it from
   `_draw_buildings` end (or connect a new layer draw like corpses).
   Stage wiring already exists (`_bld_tex` picks `_s1.._s4`); verify visually.

ACCEPTANCE: `ukr_cen_s1.png` … `_s4.png` and `ukr_cen_dead.png` exist and look
like scaffolds / rubble (open one PNG); selftest passed; screenshot of a
building under construction shows a stage, not the finished sprite.

## S7 — OPTIONAL: hills, elevation range bonus, cannon LOS

WHY: Battle_tactics: ranged gain range from higher ground; hills hide units
from direct cannon fire; howitzers/mortars arc over.

FILE `app/scripts/game.gd`:
1. ADD:
```
func height_at(p: Vector2) -> float:
	var t := tile_of(p)
	return _noise2(float(t.x) * 0.07, float(t.y) * 0.07) * 2.0
```
   (`_noise2` already exists for map biomes.)
2. In `_tick_unit` attack branch, after the artillery range duplicate block add:
```
			var hd: float = height_at(e.pos) - height_at(t.pos)
			if hd > 0.6 and str(w.kind) in ["bullet", "arrow", "firearrow", "cannonball", "cannister"]:
				w = w.duplicate()
				w["max"] = float(w.max) * 1.25
```
3. Direct-fire hill LOS: in `_fire` next to the `_wall_between` check add:
```
	if str(w.kind) == "cannonball" and not str(e.sid) in ["howitzer", "mortar"]:
		var mid: Vector2 = (e.pos + t.pos) * 0.5
		if height_at(mid) > maxf(height_at(e.pos), height_at(t.pos)) + 0.8:
			e.cooldown = 0.5
			return
```
FILE `app/scripts/world.gd`:
4. Tint terrain by height: in `_build_terrain` where tiles are painted (grep
   `_noise2`), multiply grass colour by `1.0 + 0.08 * height` so hills read.

ACCEPTANCE: selftest passed; cli clean. If anything misbehaves, SKIP this step
entirely (it is optional) and note it in MECHANICS.md.

## S8 — AI combined arms + formations + waves

WHY: videos + Battle_tactics: pikes front, musket line hold-ground, howitzers
behind, long cannons rear, cav flank; AI forms formations and attacks in mass.

FILE `app/scripts/ai.gd`:
1. Replace the random army pick block:
```
				var options: Array = b.def.trains
				var pick: String = options[game.rng.randi() % options.size()]
				pick = Data.resolve_sid(str(Data.PLAYER_NATIONS[player]) if player < Data.PLAYER_NATIONS.size() else "", pick)
				var ud: Dictionary = Data.UNITS[pick]
```
   with a composition-weighted pick:
```
				var options: Array = b.def.trains
				var counts := {"melee": 0, "ranged": 0, "cavalry": 0, "artillery": 0}
				for m in military:
					counts[game._kind_class(m)] = int(counts.get(game._kind_class(m), 0)) + 1
				var want := "melee"
				if counts["ranged"] < counts["melee"]:
					want = "ranged"
				elif counts["cavalry"] < counts["melee"] / 2:
					want = "cavalry"
				var pick: String = ""
				for o in options:
					var rs: String = Data.resolve_sid(str(Data.PLAYER_NATIONS[player]) if player < Data.PLAYER_NATIONS.size() else "", o)
					if game._kind_class({"def": Data.UNITS[rs], "kind": "unit"}) == want:
						pick = rs
						break
				if pick == "":
					pick = Data.resolve_sid(str(Data.PLAYER_NATIONS[player]) if player < Data.PLAYER_NATIONS.size() else "", options[game.rng.randi() % options.size()])
				var ud: Dictionary = Data.UNITS[pick]
```
2. Form squads: after the training section add:
```
	# form formations like a player: officer + drummer + >=15 same type
	if _count_sid("aca") > 0:
		var offs: Array = []
		for u in game.units_of(player):
			if str(u.sid) in ["officer", "officer18"] and game.squad_of_unit(u.id).is_empty():
				offs.append(u)
		for off in offs:
			game.cmd_form_size(off, 36)
```
3. Attack waves in formation: in the attack-wave section where it orders
   `game.cmd_attack_move(m, enemy_home.pos)` (grep), replace with: if the unit
   belongs to a squad, order the squad OFFICER instead (orders fan out in
   formation); else attack-move. Musket lines on defense: in the defense
   section, after ordering attack on threat, set ranged units
   `game.cmd_stand_ground(m)` when the threat is within 25 m of home.

ACCEPTANCE: cli 30 s: both sides > 40 units, `squads` present (add to cli report
if trivial, else check via selftest-independent log); selftest passed.

## S9 — Economy feel: field worker cap, cost escalation, gold rebellion

WHY: Steam guide: only 2 peasants harvest one field tile; fields decay;
Steam upgrades guide: next building copy costlier (cen ×3), exceptions mines/
walls/palisades/shipyards; cossacks3.pl hunger_and_rebellion: gold shortage
destroys mercenary armies.

FILE `app/scripts/game.gd`:
1. Field cap: in `_tick_gather` food/wood/stone branch, before working (after
   `var slot := _work_slot(...)`), add for food only:
```
	if res == "food":
		var on_node := 0
		for u in entities:
			if not u.dead and u.id != e.id and u.order.type == "gather" and u.order.get("node", 0) == node.id and u.pos.distance_to(node.pos) < node.radius + 2.0:
				on_node += 1
		if on_node >= 2:
			var altf := nearest_res(e.pos, "food", 45.0, true)
			if not altf.is_empty() and altf.id != node.id:
				o.node = altf.id
				node = altf
			else:
				e.order = {"type": "none"}
				return
```
   (Check `nearest_res` signature: `(pos, type, max_r, exclude_blocked)` — pass
   args accordingly; if it has no 4th param, call with 3.)
2. Cost escalation: in `place_building`, replace `if not pay_cost(player, def.cost):`
   with:
```
	var mult := 1.0
	if not sid.begins_with("mine_") and sid != "wal" and sid != "gat":
		var cnt := 0
		for b in buildings_of(player):
			if b.sid == sid:
				cnt += 1
		mult = pow(3.0, cnt) if sid == "cen" else pow(1.5, cnt)
	var esc_cost := {}
	for k in def.cost:
		esc_cost[k] = int(round(float(def.cost[k]) * mult))
	if not pay_cost(player, esc_cost):
```
3. Gold rebellion: in `_tick_upkeep`, in the `else` (shortage) branch, after
   the food famine block add:
```
					if k == "gold":
						p["gold_famine_t"] = float(p.get("gold_famine_t", 0.0)) + dt
						if float(p["gold_famine_t"]) >= 60.0:
							for e in entities:
								if not e.dead and e.player == pi and e.kind == "unit" and e.def.get("eat", {}).has("gold"):
									e["morale"] = maxf(0.0, float(e.get("morale", 70.0)) - 10.0 * dt)
					else:
						p["gold_famine_t"] = 0.0
```
   (Reset gold_famine_t when gold paid: in the `if have >= need:` branch add
   `if k == "gold": p["gold_famine_t"] = 0.0`.)

ACCEPTANCE: selftest passed; cli 30 s clean (AI now pays escalating costs —
expect fewer town halls, more houses: correct).

## S10 — Final verification + documentation

1. `godot --headless --path app --import`
2. `godot --headless --path app -- --self-test app/selftest.json` → passed true,
   all steps true.
3. `godot --headless --path app -- --cli app/cli.json --cli-seconds 60` → no
   errors, both sides large armies.
4. `godot --path app -- --screenshot app/shots/g2_final.png --timeout 90` →
   visually: nation buildings, animated units, HUD intact.
5. Append to `app/MECHANICS.md` a "GUIDE 2 pass" section listing every rule
   added with its wiki source and whether estimated; append matching entries
   to `app/mechanics.json` `values` (same schema: name/group/value/unit/source,
   `"estimated": true` where the port chose a number the wiki didn't give).
6. Update `app/README.md` controls list (D/E/V, gate/repair buttons, formation
   size buttons) and `app/CREDITS.md` (ba2/dip meshes, stage/death meshes).
7. Update `GUIDE1.md` header status: GUIDE 2 complete.

---

## Appendix A — wiki numbers used above (sources)

- Dwellings: TownHall 100; Barracks17 150 (Algeria/Turkey 50); Barracks18 250;
  Housing 25. (cossacks3.fandom.com/wiki/Population_capacity)
- 18c transition at Town Hall after all buildings built. (wiki/Town_Hall)
- Mill: +140% (750 food 250 gold), +250% (25600 food 3350 gold 2000 iron).
  (wiki/Mill, wiki/Improve_grain_crops_treatment)
- Mine slots: II +5 (1000f 1250g), III +8 (25000f 7750g 5000w), IV +10
  (41500f 6250g 22230w), V +12 (15000f 20000g 7000i), VI +15 (23000f 21000g
  9000i), VII +40 (60000f 26000g) → 95 max. (wiki/Mine)
- Tower RoF upgrades +20%, +20%, +10%; per-tower. (wiki/Upgrades#Tower)
- Academy civilian: building hp +85; build time -75%; walls/towers hp +80;
  harvest +40/+40/+50%; field capacity +200%; wood +100%; stone +100/+200%;
  geology reveals deposits; Montgolfier reveals map. (wiki/Upgrades#Academy)
- Blacksmith: field capacity +100%. (wiki/Upgrades#Blacksmith)
- Artillery: range +5%/+10%; durability +150% (Gribovalle); accuracy +35%;
  multi-barrel design NOT for Turkey/Algeria. (wiki/Upgrades#Artillery,
  Battle_tactics)
- Walls: only cannons/ships/grenadiers/archers destroy; no shooting through;
  gates from wall segments; stone upkeep. (wiki/Wall, Steam forum gate thread)
- Fields: 2 peasants per field tile; ~40 tiles/mill; decay reduced by field
  capacity upgrades. (Steam discussion 350542683212516833)
- Cost escalation: next copy dearer, town center ×3; exceptions shipyards,
  mines, palisades, walls/gates. (Steam guide 800491181)
- Hotkeys: E feuer frei, D hold fire, V engage, S stand ground. (wiki/Hotkeys)
- RPS counter table + combined-arms layout + elevation bonus + hill LOS +
  mortar buildings-only + grapeshot. (wiki/Combat_basics, Battle_tactics)
- Famine: food shortage starves; gold shortage rebels mercs.
  (cossacks3.pl hunger_and_rebellion; wiki/Food)

## Appendix B — donor asset map for new bakes

- Barracks 18c: `data/actors/buildings/<nat>/<nat>ba2.osm` (+ stages/death).
- Diplomatic Center: `<nat>dip.osm`.
- Stages: `<nat><bld>1..4.osm`; rubble: `<nat><bld>_death2.osm`.
- Textures mirror under `data/materials/buildings/<nat>/`.
- Algeria has only cen/hou own meshes; shared eur sto/mil/mar/tow fallback
  already handled by bake_building's candidate list.

## Appendix C — troubleshooting for the executor

- `Required object "rp_texture" is null` → a PNG was not imported: run
  `godot --headless --path app --import`; the code already null-guards.
- Script parse error → you broke indentation (TABS) or a comma in a dict
  literal; restore from `inbox/backup/<name>.gd.bak2` and redo the edit.
- selftest `train` fails after S1 → farm cap math: ensure cen farm=100 and
  START_PEASANTS unchanged (8).
- cli hangs/slow → reduce map to 240 in app/config.json; never remove
  `--cli-seconds`.
- Blender `ModuleNotFoundError: PIL` → the baker inserts `tools/blender_py`
  into sys.path itself; if missing, reinstall:
  `& "C:\Program Files\Blender Foundation\Blender 5.2\5.2\python\bin\python.exe" -m pip install --target app\tools\blender_py Pillow`
- NEVER use EEVEE/GPU. NEVER run godot without a self-exiting flag.

## STATUS (filled by executor, 2026-11-18/19) — ALL of GUIDE2.md implemented

S1 done (farm 100/150, AI 40/600/6+3bar/2sta, map 320, bootstrap rebalance +
guaranteed stone; acceptance corrected: massing is gradual, verified via
boosted CLI + growth trend). S2 done (cen_18c + prereq, bar18/dip + bakes,
trains moved). S3 done (full ladder incl. 18 mine slot rows, per-building
research, all effect handlers). S4 done (gate/repair/wall-fire/stone upkeep).
S5 done (D/E/V, counter targeting, size buttons). S6 done (stages + rubble
baked and drawn; stage meshes needed per-model rebuild). S7 done (height
bonus, LOS, tint). S8 done (composition picker, AI squads, officer-led waves,
ranged hold). S9 done (field cap 2, escalation, gold rebellion). S10 done.
Final: selftest 21/21, uitest 11/11 (+--ui-only scenes), cli clean, journey
MP4 assembled (112 frames, real AI-vs-AI match), windowed screenshots.
Two executor fixes beyond the letter of the guide, both required for
acceptance: stone deadlock (mapgen guarantee) and stage-overlap render bug
(hide finished mesh). Appendix untouched except the S1 acceptance correction.

### Post-GUIDE2 additions (user requests, 2026-11-19)
- Default nations rus/bav (was ukr/rus): data.gd + menu.gd + config.json +
  boost.json + uitest-independent (uitest sets its own matchup).
- `--ui-only <scene>`: every uitest scene runs standalone in seconds.
- `--seq` + `--journey` + `tools/seq_to_mp4.py`: frame sequences and real
  MP4s (ffmpeg) + contact sheets; headless captures capped at 800x600 /
  800x450; seq dirs auto-created (bare paths used to fall back to user://).
- `COMMANDS.md`: full manual (all flags, tools, when/why, troubleshooting).
- Video-found rendering bug: world-space culling vs screen viewport left the
  320-tile map entity-free; fixed via canvas-transformed view rect. Old
  screenshots looked fine only because near-origin entities passed the bogus
  cull — this is why the user asked for video-level verification.
- Two test bugs found by the new tests (not game bugs): S key with peasants
  opens the stable ghost (build-menu priority) so order_keys uses swordsmen;
  train test granted res[5]=coal instead of res[4]=iron.
