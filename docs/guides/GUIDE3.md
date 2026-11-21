# GUIDE 3 — Cossacks 3 Godot port: fidelity, UI logic, sprite correctness, AI, and speed on weak hardware
### A step-by-step, paste-ready implementation guide for a simpler executor model

**Read sections 0–2 fully before touching any file.** Then do steps G1→G16 IN
ORDER. Each step names the exact file, the exact anchor (function name + line
number measured 2026-11-19), the exact code, and an acceptance command. Do ONE
step, run its acceptance, only then continue. If acceptance fails: restore the
file from `inbox/backup/`, re-read the step, retry. Never skip ahead. Never
"improve" code beyond what a step says. GDScript uses **TABS**.

Companion docs (read-only): `GUIDE1.md`, `GUIDE2.md` (both DONE), `app/MECHANICS.md`,
`app/mechanics.json`, `reference/videos.md`, `docs/COMMANDS.md`.
Donor game: `C:\Games\Cossacks 3`. Evidence for this guide: recorded journey
frames `app/shots/j1/`, `app/shots/j2/` (contact.png + frame_*.png), donor
`data/gui/menu.inc/doupdatecursor.inc`, `data/game/var/hotkeys.cfg`,
`data/gui/minimap.cfg`, and a full read of every script in `app/scripts/`.

---

## 0. Environment, commands, safety rules

| thing | value |
|---|---|
| project root | `C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3` |
| app dir | `<root>\app` |
| donor game | `C:\Games\Cossacks 3` |
| Godot | on PATH as `godot` (project.godot features "4.4", renderer `gl_compatibility`) |
| Blender | `C:\Program Files\Blender Foundation\Blender 5.2\blender.exe` (CPU Cycles ONLY) |
| Python | 3.14 system, Pillow installed (tools use it) |
| ffmpeg | on PATH (for MP4 assembly) |

Run every command from `<root>`. Quote paths with spaces.

```
godot --headless --path app -- --self-test app/selftest.json
godot --headless --path app -- --ui-test app/uitest.json
godot --headless --path app -- --ui-test app/uit.json --ui-only <scene>
godot --headless --path app -- --cli app/cli.json --cli-seconds 60
godot --headless --path app -- --config shots/boost.json --cli app/cli.json --cli-seconds 120
godot --headless --path app --import
godot --path app -- --screenshot app/shots/g3.png --timeout 90
godot --path app -- --seq app/shots/j3 --seq-seconds 240 --seq-step 2 --speed 4 --config shots/boost.json --journey --timeout 400
python app/tools/seq_to_mp4.py --dir app/shots/j3 --fps 10
```

SAFETY RULES (owner's GPU is weak; it once shut the PC down):
1. NEVER run Blender with EEVEE or GPU Cycles. Only `--engine cycles --samples 4`.
2. NEVER run `godot` without a self-exiting flag (`--self-test`, `--ui-test`,
   `--cli`, `--screenshot`, `--seq`, `--dump-config`, `--bench`, `--timeout`).
3. Before editing ANY existing script:
   `Copy-Item app\scripts\<name>.gd inbox\backup\<name>.gd.bak3 -Force`
   Before editing tools: `inbox\backup\<name>.py.bak3`. Before config.json: `.bak3`.
4. After adding/changing PNG assets ALWAYS `godot --headless --path app --import`.
5. TABS for indentation. Match surrounding indentation exactly.
6. Do not rename existing functions/fields other scripts call.
7. ONE heavy job at a time (bake XOR long CLI XOR windowed capture).
8. Every new feature must keep `selftest` 28/28 and `uitest` 17/17 green.
   New tests are added in G15; until then the old suites are the gate.

## 1. What already exists (DO NOT rebuild)

Sim (`game.gd`, 3719 lines as of 2026-11-21; 2159 at G3 authoring): 32 Hz fixed
step (`Data.FPS=32`, main.gd `_process` L386–400 accumulator, max 64
steps/frame), entities = Array of Dictionaries +
`by_id`, 6-resource economy, mines with slot ladder, upkeep/famine/gold
rebellion, market, cost escalation, construction stages, training queues,
donor damage formula, morale/rout, officer/drummer/priest auras, building
capture, walls/gates/repair, towers, squads+formations (line/column/square/
wedge, sizes 15..400 / cav 40..160), replenish, hold-fire D/E/V, counter
targeting, 17c flee, bayonets, grapeshot, mortar-only-buildings, 18c at Town
Hall, bar18/dip, 40+ upgrades, hills bonus/LOS, corpses/rubble, projectiles,
fog (render-side only), objectives, victory (destroy_all / score).
Render (`world.gd`, 1085 lines): 4 draw layers (res z1, bld z2, unit z3, fx z4),
terrain single ImageTexture 8 px/tile, fog ImageTexture per-tile alpha,
animated 8-dir sheets `assets/models/anim/` (54 unit keys × walk/idle/attack/
death + 215 nation building sheets + stages s1–s4 + `_dead`), lazy loading.
HUD (`hud.gd`, 761 lines): top resource bar + speed buttons, bottom-left
selection panel, bottom-right 160px minimap (left-click jump only), tooltips,
research/train/build buttons auto-generated from Data.
Input (`input_controller.gd`, 413 lines): drag select, right-click context
orders, hotkeys from `Data.HOTKEYS`, build-menu priority when peasants selected.
AI (`ai.gd`, 315 lines): threshold economy, build order, composition picker,
squads, waves, defense. Shell (`main.gd` 818, `menu.gd` 198, `config.gd` 462,
`audio.gd` 133, `camera.gd` 78): menu (skirmish/battles/campaigns-first-only),
flags incl. `--seq/--journey/--cli/--screenshot/--ui-test`, 8-channel audio pool,
edge-scroll camera, zoom 0.345–2.9.
Assets already shipped but UNUSED: `app/assets/ui/cursor_*.bmp` (11 original
cursors), donor `icons.bmp` (1024×512) / `iconsunits.bmp` (1024×384) atlases.

## 2. The gap list (measured from recordings + code read; this guide closes it)

| # | gap (evidence) | step |
|---|---|---|
| 1 | Units/peasants nearly invisible: baked figures occupy only ~35–40% of each 160px cell (whole-cell scaling makes a 1.9m man ~12px). `j2/frame_0040.png` crop shows empty blue rings. | G1 |
| 2 | Team ring + double hard shadow drawn under EVERY unit always (original: ring only when selected, soft small shadow). | G2 |
| 3 | No cursor changes at all (11 donor cursor BMPs shipped, zero code references). Donor rules in `doupdatecursor.inc`. | G3 |
| 4 | Minimap bottom-right 160px, no camera frustum rect, no right-click orders, no drag pan (donor `minimap.cfg`: 240px, bottom-LEFT, FrustumVisible=True). | G4 |
| 5 | No control groups, no double-click same-type, no shift-add select, no command card of order buttons. | G4 |
| 6 | `config.json` hotkeys section REPLACES defaults → D/E/V and bar18/dip keys are DEAD in the shipped game (config.gd apply L410–411). Original keys differ (K=ba2, D=dip, R=attackpoint, U=unload, Ctrl+M, Ctrl+`, Shift+Z). | G5 |
| 7 | Fog hides nothing in logic/render: enemy units drawn through fog; sim/AI see everything. | G6 |
| 8 | Terrain blurry (8px/tile upscaled 4×), hard tile seams, no type blending; tree shadows = huge dark discs; trees taller than houses. | G7 |
| 9 | Speed: per-entity per-tick FULL entity scans (morale auras ×2, drummer speed, targeting, food crowding, dropoff, capture, splash, separation building pass); dead entities never removed; `_target_score` builds a 4×5 dict per call; `_noise2` allocates a lambda per call; all 4 layers redraw every frame; minimap full repaint 4×/s; fog full-map pixel loop 2×/s. | G8 |
| 10 | Sim bugs: farm_cap grows on delete/never shrinks on destruction; capture double-counts farm + refills mine deposit; global deposit pool copied per mine; splash ignores prot bonuses; post-research spawns miss HP upgrades; enemy gates toggleable by anyone; famine message 32×/s; attack order never gives up when stuck; patrol route lost after combat; projectile cap 64 silently deletes shells. | G9 |
| 11 | Missing mechanics: garrison (U unload exists in donor hotkeys), peasant capture (rule toggle exists, effect absent), field re-sowing (food finite forever), queue cancel/refund (`Data.refund` unused), attack-ground (donor R), formation facing rotation. | G10 |
| 12 | AI: threshold ping-pong economy, bypasses pop/queue limits (ai.gd L137–138), 4-segment wall stub, no expansion/repair/raids/retreat, no difficulty. | G11 |
| 13 | No save/load, no in-game Esc menu, no options, no end-game statistics screen, campaign = first mission only, no Quit button, `--seed` parsed but IGNORED at authoring (main.gd L343–345) — now applied via main.gd L135–136 (GUIDE4 L6). | G12 |
| 14 | Journey recordings: camera never follows action (j1 = empty fog for 240s), no battle zoom. | G13 |
| 15 | Audio: 8 channels steal each other, no per-event cooldown, no distance cull, music never re-loops, streams lazy-load mid-battle (hitch). | G14 |
| 16 | No perf measurement / quality presets for weak hardware. | G8, G15 |

---

## G1 — Fix sprite scale & foot anchor (the "invisible peasants" bug)

WHY: `bake_sprites.py` L170–174 computes ONE center/ortho from the bbox of ALL
frames INCLUDING death (lying + swung tools) → the standing figure fills only
~35–40% of the cell. `world.gd _draw_anim` L197–200 scales the WHOLE cell to
`_unit_height` (1.9 m) → a ~12 px man at 16 px/m. Fix WITHOUT rebaking: measure
each sheet's real ink bbox offline, store it in `index.json`, and scale/anchor
by the bbox instead of the cell.

### G1.1 NEW FILE `app/tools/sheet_metrics.py` (exact content)

```python
#!/usr/bin/env python3
"""Add per-action ink bbox to assets/models/anim/index.json.
Run: python app/tools/sheet_metrics.py --dir app/assets/models/anim
For every <key>_<action>.png referenced by index.json: union of alpha>8 bboxes
over ALL cells (8 dirs x n frames). Writes actions[action]["bbox"]=[x0,y0,x1,y1]
in CELL-LOCAL pixels, plus ["fig_h"]=(y1-y0)/cell and ["foot"]=y1/cell and
["cx"]=(x0+x1)/2/cell. Idempotent; skips sheets already measured unless --force.
"""
import argparse, json, os
from PIL import Image

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", required=True)
    ap.add_argument("--force", action="store_true")
    a = ap.parse_args()
    ip = os.path.join(a.dir, "index.json")
    idx = json.load(open(ip, encoding="utf-8"))
    changed = 0
    for key, info in idx.items():
        cell = int(info["cell"])
        for act, ad in info.get("actions", {}).items():
            if "bbox" in ad and not a.force:
                continue
            p = os.path.join(a.dir, "%s_%s.png" % (key, act))
            if not os.path.exists(p):
                continue
            im = Image.open(p).convert("RGBA")
            cols, rows = im.width // cell, im.height // cell
            x0, y0, x1, y1 = cell, cell, 0, 0
            for r in range(rows):
                for c in range(cols):
                    bb = im.crop((c * cell, r * cell, (c + 1) * cell, (r + 1) * cell)).getbbox()
                    if bb is None:
                        continue
                    x0, y0 = min(x0, bb[0]), min(y0, bb[1])
                    x1, y1 = max(x1, bb[2]), max(y1, bb[3])
            if x1 <= x0 or y1 <= y0:
                continue
            ad["bbox"] = [x0, y0, x1, y1]
            ad["fig_h"] = round((y1 - y0) / float(cell), 4)
            ad["foot"] = round(y1 / float(cell), 4)
            ad["cx"] = round((x0 + x1) / 2.0 / float(cell), 4)
            changed += 1
    json.dump(idx, open(ip, "w", encoding="utf-8"), indent=1)
    print("measured", changed, "action sheets")

main()
```

Run: `python app/tools/sheet_metrics.py --dir app/assets/models/anim`
Acceptance: prints `measured 200+`; `python -c "import json;d=json.load(open('app/assets/models/anim/index.json'));print(d['peasant']['actions']['walk'])"` shows `bbox/fig_h/foot/cx` with `fig_h` between 0.3 and 0.95.

### G1.2 `app/scripts/world.gd` — REPLACE `_draw_anim` (L167–202) entirely with:

```gdscript
func _draw_anim(e: Dictionary, p: Vector2, tint: Color) -> bool:
	var key := _anim_key(e.sid, int(e.player))
	var info: Dictionary = anim_index.get(key, {})
	if info.is_empty():
		return false
	var act := _anim_action(e)
	var a: Dictionary = info.actions.get(act, info.actions.get("idle", {}))
	if a.is_empty():
		return false
	var tk := key + "_" + act
	if not anim_tex.has(tk):
		var path := "res://assets/models/anim/%s.png" % tk
		if not FileAccess.file_exists(path):
			return false
		anim_tex[tk] = load(path)
	var tex: Texture2D = anim_tex[tk]
	if tex == null:
		anim_tex.erase(tk)
		return false
	var cell: int = int(info.cell)
	var n: int = int(a.frames)
	var gt: float = game.time_s
	var t0: float = float(e.get("death_t", -1.0)) if act == "death" else (float(e.get("fire_t", -1.0)) if act == "attack" and e.order.type == "attack" else -1.0)
	var fi: int
	if t0 >= 0.0:
		fi = mini(n - 1, int((gt - t0) / maxf(0.05, float(a.duration)) * n))
	else:
		fi = int(anim_t / maxf(0.05, float(a.duration)) * n) % n
	var dir := int(fposmod(roundf(float(e.get("face", 0.0)) / (PI / 4.0)), 8.0)) % 8
	var src := Rect2(dir * cell, fi * cell, cell, cell)
	# G1: scale by the measured ink height, anchor feet at the ink bottom and
	# horizontal centre at the ink centre (tools swinging must not shift feet).
	var fig_h: float = float(a.get("fig_h", 1.0))
	var foot: float = float(a.get("foot", 0.82))
	var cx: float = float(a.get("cx", 0.5))
	var sc: float = _unit_height(e) * view_scale / maxf(8.0, float(cell) * fig_h)
	var sz := Vector2(cell, cell) * sc
	var tl := p - Vector2(sz.x * cx, sz.y * foot)
	unit_layer.draw_texture_rect_region(tex, Rect2(tl, sz), src, tint)
	return true
```

### G1.3 `world.gd _draw_corpses` (L908–946): inside the death-sheet branch,
replace the three lines computing `dsc/dsz/dtl` (L934–936) with:

```gdscript
					var dfig: float = float(dact.get("fig_h", 1.0))
					var dfoot: float = float(dact.get("foot", 0.82))
					var dcx: float = float(dact.get("cx", 0.5))
					var dsc: float = 1.9 * view_scale / maxf(8.0, float(dcell) * dfig)
					var dsz := Vector2(dcell, dcell) * dsc
					var dtl := p - Vector2(dsz.x * dcx, dsz.y * dfoot)
```

### G1.4 Facing on actions (units currently only face their move direction).
`game.gd`: in `_tick_unit` attack branch, right after the target `t` is resolved
and before weapon pick (grep `var w := _pick_weapon(e, d)` inside `"attack":`),
add: `e.face = (t.pos - e.pos).angle()`.
In `_tick_gather` working branch (where `e.moving = false` is set at the work
slot) add: `e.face = (node.pos - e.pos).angle()`.
In `_tick_unit` build branch at the site slot add: `e.face = (site.pos - e.pos).angle()`.
(Grep each branch; `node`/`site` are the local names already used there.)

ACCEPTANCE G1:
```
godot --headless --path app -- --self-test app/selftest.json
godot --path app -- --screenshot app/shots/g1.png --timeout 90
```
Open g1.png: peasants are now clearly visible ~30px figures with feet on their
position dot, not empty rings. Compare with `app/shots/j2/frame_0040.png`.

## G2 — Unit overlays like the original (selection-only ring, soft shadow)

WHY: `world.gd _draw_units` L774–780 draws 2 shadow circles + a 22-segment team
arc for EVERY unit EVERY frame (also a big perf cost, see G8). Original: no ring
under unselected units; selected units get a player-colour circle; shadows are
small soft ellipses.

### G2.1 NEW FILE `app/tools/make_overlays.py` (exact content; Pillow only)

```python
#!/usr/bin/env python3
"""Bake soft shadow + selection ring textures into assets/ui/overlays/.
Run: python app/tools/make_overlays.py --out app/assets/ui/overlays
"""
import argparse, math, os
from PIL import Image, ImageDraw

def main():
    ap = argparse.ArgumentParser(); ap.add_argument("--out", required=True)
    a = ap.parse_args(); os.makedirs(a.out, exist_ok=True)
    S = 64
    sh = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(sh)
    for i in range(16, 0, -1):
        al = int(70 * (1.0 - i / 16.0) ** 1.6)
        d.ellipse([S/2 - i*1.9, S/2 - i*0.95, S/2 + i*1.9, S/2 + i*0.95], fill=(0, 0, 0, al))
    sh.save(os.path.join(a.out, "shadow.png"))
    for name, col in (("ring_p0", (70, 130, 255)), ("ring_p1", (255, 80, 60)), ("ring_sel", (255, 255, 255))):
        im = Image.new("RGBA", (S, S), (0, 0, 0, 0))
        d = ImageDraw.Draw(im)
        d.ellipse([4, 10, S-4, S-10], outline=col + (230,), width=3)
        d.ellipse([7, 13, S-7, S-13], outline=col + (90,), width=2)
        im.save(os.path.join(a.out, name + ".png"))
    print("overlays written")

main()
```

Run it, then `godot --headless --path app --import`.

### G2.2 `world.gd`: add vars after L39 (`var anim_tex := {}`):

```gdscript
var ov_shadow: Texture2D
var ov_ring: Array = []
var ov_sel: Texture2D
```

In `bind()` after `_load_sprites()` (L66) add:

```gdscript
	ov_shadow = load("res://assets/ui/overlays/shadow.png")
	ov_ring = [load("res://assets/ui/overlays/ring_p0.png"), load("res://assets/ui/overlays/ring_p1.png")]
	ov_sel = load("res://assets/ui/overlays/ring_sel.png")
```

### G2.3 In `_draw_units`, REPLACE L774–780 (the bob/shadow/team-ring block) with:

```gdscript
		var bob := sin(anim_t * 5.0 + float(e.id) * 1.7) * (1.4 if e.moving else 0.5)
		var pb := p + Vector2(0, bob * 0.4)
		if ov_shadow != null:
			var shw := vr * 2.6
			unit_layer.draw_texture_rect(ov_shadow, Rect2(pb.x - shw / 2, pb.y - shw * 0.25 + 2, shw, shw * 0.5), false, Color(1, 1, 1, 0.8))
		if bool(e.get("selected", false)) and ov_ring.size() > int(e.player):
			var rw := vr * 2.9
			unit_layer.draw_texture_rect(ov_ring[int(e.player)], Rect2(p.x - rw / 2, p.y - rw * 0.25, rw, rw * 0.5), false)
```

and REPLACE the selected-unit block L883–887 (`if e.get("selected", false):`
with the facing tick + two arcs) with:

```gdscript
		if e.get("selected", false):
			var fd := Vector2(cos(e.face), sin(e.face))
			unit_layer.draw_line(p + fd * (vr + 2.0), p + fd * (vr + 7.0), Color(1, 1, 1, 0.9), 2.0)
			if ov_sel != null:
				var sw := vr * 3.2
				unit_layer.draw_texture_rect(ov_sel, Rect2(p.x - sw / 2, p.y - sw * 0.25, sw, sw * 0.5), false)
```

### G2.4 Prop shadows/trees: in `_draw_sprite` (L246–254) replace the shadow line
L253 with a softer, smaller one:

```gdscript
		layer.draw_circle(p + Vector2(1.0, 2.0), sz.x * 0.22, Color(0, 0, 0, 0.16))
```

In `_draw_resources` wood branch L485 change `3.6 + h * 1.6` → `2.9 + h * 1.1`
(trees must not tower over houses); stone L508 `1.6 + h * 0.8` → `1.3 + h * 0.6`;
ore outcrop L531 `2.2` → `1.8`.

### G2.5 Corpses linger like the original (minutes, not 14 s): `game.gd _kill`
corpse append (grep `"life": 14.0`) → `"life": float(Data.CORPSE_LIFE)`.
`data.gd`: add near L45 (`static var FOG_OF_WAR`): `static var CORPSE_LIFE := 90.0`.
`config.gd` DEFAULT `gameplay` add `"corpse_life": 90.0,` and in `apply()`
gameplay section add `Data.CORPSE_LIFE = num("gameplay.corpse_life", 90.0)`.
Raise the corpse cap in `_kill` (grep `corpses.size() > 220`) → `> 600`.

ACCEPTANCE G2: selftest green; screenshot shows rings ONLY under selected
units, soft small shadows, trees ~house height.

## G3 — Context cursors (donor rules, shipped BMPs)

WHY: user-visible miss. Donor logic = `data/gui/menu.inc/doupdatecursor.inc`
(read it; summary table in Appendix B). Assets already in `app/assets/ui/`.

### G3.1 `input_controller.gd`: add vars after L20 (`var rally_mode := false`):

```gdscript
var cursor_tex: Dictionary = {}
var cursor_now := ""
var attack_ground_mode := false
```

In `bind()` after `_read_hotkeys()` add:

```gdscript
	for c in ["default", "attack", "captureattack", "artillery", "patrol", "construct", "gainfood", "gainwood", "gainstone", "gotomine", "wait"]:
		var p := "res://assets/ui/cursor_%s.bmp" % c
		if FileAccess.file_exists(p):
			cursor_tex[c] = load(p)
```

### G3.2 Add this function at the end of input_controller.gd:

```gdscript
func _set_cursor(name: String) -> void:
	if name == cursor_now:
		return
	cursor_now = name
	var t: Texture2D = cursor_tex.get(name, cursor_tex.get("default", null))
	if t == null:
		return
	# donor cursors are 32x32 with the hot spot at top-left tip (8,4)
	Input.set_custom_mouse_cursor(t, Input.CURSOR_ARROW, Vector2(8, 4))

func _update_cursor() -> void:
	if game == null or world == null:
		return
	if hud != null and hud.build_ghost_sid != "":
		_set_cursor("construct")
		return
	if attack_move_mode:
		_set_cursor("attack")
		return
	if attack_ground_mode:
		_set_cursor("artillery")
		return
	if rally_mode:
		_set_cursor("gotomine")
		return
	var pw := _screen_to_world(get_viewport().get_mouse_position())
	var sel := get_selected()
	var peas := false
	var military := false
	for e in sel:
		if e.player != 0 or e.kind != "unit":
			continue
		if e.sid == "peasant":
			peas = true
		else:
			military = true
	var tgt := _pick(pw, false)
	if not tgt.is_empty():
		if tgt.player != 0 and tgt.kind == "building" and military:
			_set_cursor("captureattack" if bool(Data.CAPTURE_ENABLED) else "attack")
			return
		if tgt.player != 0:
			_set_cursor("attack")
			return
		if peas and tgt.kind == "building" and (not tgt.finished or tgt.hp < tgt.max_hp):
			_set_cursor("construct")
			return
		if peas and tgt.kind == "building" and tgt.sid.begins_with("mine_") and tgt.finished:
			_set_cursor("gotomine")
			return
		if military and tgt.kind == "building" and tgt.finished and (tgt.sid == "tow" or tgt.sid == "cen"):
			_set_cursor("gotomine")
			return
	if peas:
		var r := _pick_res(pw)
		if not r.is_empty():
			match str(r.type):
				"food":
					_set_cursor("gainfood")
					return
				"wood":
					_set_cursor("gainwood")
					return
				"stone":
					_set_cursor("gainstone")
					return
				"gold", "iron", "coal":
					_set_cursor("gotomine")
					return
	_set_cursor("default")
```

Call `_update_cursor()` at the END of `_process` (L394–413). Also call
`_set_cursor("default")` in `bind()` after loading textures.

### G3.3 Optional stretch (only if time remains): edge-scroll arrow cursors from
donor `data/cursors/textures/cur/*.cur`. NEW `app/tools/cur_to_png.py`: parse
ICONDIR (6 bytes) + ICONDIRENTRY (16 bytes: w,h,colors,reserved,planes,bpp,
size,offset); if the payload starts with `\x89PNG` save directly; else it is a
DIB: BITMAPINFOHEADER (40 bytes, height = 2×real for AND mask), 32bpp BGRA rows
bottom-up → flip, write RGBA PNG. Convert the 8 arrow files into
`assets/ui/overlays/edge_<dir>.png`; in `_update_cursor` before everything: if
mouse within 8px of a viewport edge → `_set_cursor("edge_"+dir)` (load those
into cursor_tex too). If the DIB parse fails on any file, SKIP this sub-step
and note it in MECHANICS.md — the context cursors above are the required part.

ACCEPTANCE G3: `--ui-test` green; manual/windowed: hover a tree with peasants →
grain/sickle cursor; hover enemy → attack; placing building → construct.
Add uitest scene in G15.

## G4 — HUD layout & selection logic like the original

### G4.1 Minimap → bottom-LEFT, 200px, frustum rect, right-click orders, drag pan.
`hud.gd _build_minimap` (L654–679): change `custom_minimum_size` to
`Vector2(200, 200)`; replace the four anchor/offset blocks of `minimap_rect`
and `panel` so both sit bottom-LEFT:
`anchor_left=0, anchor_right=0, anchor_top=1, anchor_bottom=1`,
`offset_left=8, offset_top=-208` (rect) and `offset_left=4, offset_top=-212`
(panel). Keep everything else.
In `_update_minimap` (L690–747) AFTER the fog pass and BEFORE
`minimap_tex.update` add the camera frustum (donor FrustumVisible=True):

```gdscript
	var cam := get_viewport().get_camera_2d()
	if cam != null and world != null:
		var vr: Rect2 = world.view_rect
		var x0 := clampi(int(vr.position.x / Data.TILE_M), 0, game.MAP_W - 1)
		var y0 := clampi(int(vr.position.y / Data.TILE_M), 0, game.MAP_H - 1)
		var x1 := clampi(int(vr.end.x / Data.TILE_M), 0, game.MAP_W - 1)
		var y1 := clampi(int(vr.end.y / Data.TILE_M), 0, game.MAP_H - 1)
		for x in range(x0, x1 + 1):
			minimap_img.set_pixel(x, y0, Color(1, 1, 1, 0.9))
			minimap_img.set_pixel(x, y1, Color(1, 1, 1, 0.9))
		for y in range(y0, y1 + 1):
			minimap_img.set_pixel(x0, y, Color(1, 1, 1, 0.9))
			minimap_img.set_pixel(x1, y, Color(1, 1, 1, 0.9))
```

REPLACE `_on_minimap_input` (L681–688) with:

```gdscript
func _on_minimap_input(ev: InputEvent) -> void:
	var mp := minimap_rect.get_local_mouse_position() / minimap_rect.size
	var world_pos := Vector2(mp.x * game.MAP_W, mp.y * game.MAP_H) * Data.TILE_M
	var cam := get_viewport().get_camera_2d()
	if ev is InputEventMouseButton and ev.pressed:
		get_viewport().set_input_as_handled()
		if ev.button_index == MOUSE_BUTTON_LEFT and cam:
			cam.global_position = world_pos * world.view_scale
		elif ev.button_index == MOUSE_BUTTON_RIGHT:
			# right-click on minimap = move/attack-move order for the selection
			var ictl = get_tree().get_first_node_in_group("c3_input")
			if ictl != null:
				ictl.minimap_order(world_pos)
	elif ev is InputEventMouseMotion and ev.button_mask & MOUSE_BUTTON_MASK_LEFT and cam:
		cam.global_position = world_pos * world.view_scale
```

To make `ictl` findable: in `input_controller.gd bind()` add
`add_to_group("c3_input")`. Add to input_controller.gd:

```gdscript
func minimap_order(pos: Vector2) -> void:
	var sel := get_selected().filter(func(e): return e.player == 0 and e.kind == "unit")
	if sel.is_empty():
		return
	var any_enemy := false
	for e in game.entities:
		if not e.dead and e.player != 0 and e.pos.distance_to(pos) < 6.0:
			any_enemy = true
			break
	for e in sel:
		if any_enemy and game.has_weapon(e):
			game.cmd_attack_move(e, pos)
		else:
			game.cmd_move(e, pos)
```

### G4.2 Selection panel → bottom-CENTER; command card → bottom-RIGHT.
`hud.gd _build_bottom` (L205–226): set `sel_panel.offset_left = 220`,
`offset_right = 780` (centre band above the minimap gap). ADD a second panel
`cmd_panel` (PanelContainer, same style) anchored bottom-right
(`offset_left=-300, offset_right=-8, offset_top=-128`) containing
`cmd_bar: HBoxContainer`; store as vars. In `refresh_selection`, after the
squad panel block (L380–407) and BEFORE the peasant build-menu block (L408),
add a command card for any own-unit selection:

```gdscript
	if mine.size() > 0 and mine.all(func(e): return e.kind == "unit" and e.player == 0):
		_clear_row(cmd_bar)
		for spec in [["Attack-move [A]", "attack_move"], ["Stand [S]", "stand_ground"], ["Hold fire [D]", "hold_fire"], ["Feuer frei [E]", "feuer_frei"], ["Patrol [Q]", "patrol"], ["Guard [G]", "guard"], ["Stop [Ctrl+S]", "stop"]]:
			var cb := Button.new()
			cb.text = spec[0]
			cb.custom_minimum_size = Vector2(86, 40)
			cb.pressed.connect(_on_cmd_button.bind(str(spec[1])))
			cmd_bar.add_child(cb)
		if mine.any(func(e): return str(e.sid) in ["officer", "officer18"]):
			for form in ["line", "column", "square", "wedge"]:
				var fb2 := Button.new()
				fb2.text = form.substr(0, 3).to_upper()
				fb2.custom_minimum_size = Vector2(44, 40)
				fb2.pressed.connect(_on_cmd_form.bind(form))
				cmd_bar.add_child(fb2)
	else:
		_clear_row(cmd_bar)
```

Handlers (add next to `_on_squad_form`):

```gdscript
func _on_cmd_button(action: String) -> void:
	audio_click.play()
	var ictl = get_tree().get_first_node_in_group("c3_input")
	if ictl != null:
		ictl.command_from_hud(action)

func _on_cmd_form(form: String) -> void:
	audio_click.play()
	for e in game.get_selected():
		var sq: Dictionary = game.squad_of_unit(e.id)
		if not sq.is_empty():
			game.squad_set_formation(int(sq.squad_id), form)
			break
	refresh_selection(game.get_selected())
```

input_controller.gd add:

```gdscript
func command_from_hud(action: String) -> void:
	var sel := get_selected()
	match action:
		"attack_move":
			attack_move_mode = true
			hud.show_hint("Attack-move: right-click the destination")
		"stand_ground":
			for e in sel:
				game.cmd_stand_ground(e)
		"hold_fire":
			for e in sel:
				game.cmd_hold_fire(e, true)
		"feuer_frei":
			for e in sel:
				game.cmd_hold_fire(e, false)
		"patrol":
			for e in sel:
				if e.player == 0 and e.kind == "unit":
					game.cmd_patrol(e, e.pos + Vector2(-6, 0), e.pos + Vector2(6, 0))
		"guard":
			for e in sel:
				game.cmd_stand_ground(e)
		"stop":
			for e in sel:
				game.cmd_stop(e)
```

### G4.3 Control groups, double-click same type, shift-add.
input_controller.gd vars: `var groups: Dictionary = {}`, `var last_click_t := 0.0`,
`var last_click_sid := ""`.
In `_handle_key` TOP (before ESC) add digit handling:

```gdscript
	if k.keycode >= KEY_1 and k.keycode <= KEY_9:
		var gi: int = k.keycode - KEY_1 + 1
		if k.ctrl_pressed:
			var ids: Array = []
			for e in get_selected():
				ids.append(e.id)
			groups[gi] = ids
			hud.show_hint("Group %d stored (%d)" % [gi, ids.size()])
		else:
			var arr: Array = []
			for id in groups.get(gi, []):
				var e: Dictionary = game.by_id.get(id, {})
				if not e.is_empty() and not e.dead:
					arr.append(e)
			if not arr.is_empty():
				_set_selection(arr)
				if k.shift_pressed and camera != null:
					camera.global_position = arr[0].pos * world.view_scale
		return
```

In `_unhandled_input` left-button released single-click branch (L144–146)
replace `_set_selection([e] if not e.is_empty() else [])` with:

```gdscript
				var now := Time.get_ticks_msec() / 1000.0
				if not e.is_empty() and e.sid == last_click_sid and now - last_click_t < 0.35:
					# double click: all same-type units on screen (original behaviour)
					var arr2: Array = []
					for u in game.entities:
						if not u.dead and u.player == 0 and u.kind == "unit" and u.sid == e.sid and world.view_rect.has_point(u.pos):
							arr2.append(u)
					_set_selection(arr2)
				elif not e.is_empty() and Input.is_key_pressed(KEY_SHIFT):
					var cur := get_selected()
					if not cur.has(e):
						cur.append(e)
					_set_selection(cur)
				else:
					_set_selection([e] if not e.is_empty() else [])
				last_click_t = now
				last_click_sid = str(e.sid) if not e.is_empty() else ""
```

ACCEPTANCE G4: selftest + uitest green; screenshot: minimap bottom-left with
white frustum rect, command card bottom-right when units selected.

## G5 — Hotkeys: fix the config replace bug + align with donor hotkeys.cfg

WHY: `config.gd apply()` L410–411 does `Data.HOTKEYS = _copy(hk)` — the shipped
`app/config.json` hotkeys section omits `hold_fire/feuer_frei/engage/bar18/dip`,
so D/E/V and the 18c build keys DO NOTHING in the real game. Donor
`data/game/var/hotkeys.cfg` (Appendix A) is the fidelity target.

### G5.1 `config.gd`: REPLACE L410–411 with a per-key merge over DEFAULT:

```gdscript
	var hk_def: Dictionary = _copy(DEFAULT.get("controls", {}).get("hotkeys", {}))
	var hk: Dictionary = section("controls.hotkeys")
	for action in hk:
		if action == "build":
			var bd: Dictionary = hk_def.get("build", {})
			for sid in hk[action]:
				bd[sid] = hk[action][sid]
			hk_def["build"] = bd
		else:
			hk_def[action] = hk[action]
	Data.HOTKEYS = hk_def
```

(Keep the surrounding lines intact; `section()` and `_copy()` already exist.)

### G5.2 `config.gd` DEFAULT hotkeys (L94–121): add/adjust to donor:
- build dict: add `"dip": "D", "bar18": "K",` (donor D=dip, K=ba2; the port's
  old "2"/"3" may stay as aliases — harmless).
- add actions: `"attack_ground": "R",` (donor R=attackpoint), `"unload": "U",`,
  `"select_all_peasants": "Ctrl+`",` `"select_idle_mines": "Ctrl+M",`,
  `"add_same_type": "Shift+Z",` `"minimap_toggle": "Alt+M",`.
- keep `"rally": "R"` REMOVED from DEFAULT (R now means attack-ground; rally is
  set by right-click with a production building selected, which already works,
  plus the Rally button). Delete the `"rally": "R",` line.
- mirror ALL of the above into `app/config.json` `controls.hotkeys` (add the
  missing keys there too: hold_fire D, feuer_frei E, engage V, attack_ground R,
  unload U, the four selects, minimap_toggle, build dip/bar18) AND into
  `app/shots/boost.json` if it contains a hotkeys section (it must not silently
  revert them).

### G5.3 `input_controller.gd`:
- In `_handle_key`, the `elif _is(k, "rally"):` branch (L349–351) → replace with:

```gdscript
	elif _is(k, "attack_ground"):
		var has_arty := false
		for e in get_selected():
			if e.player == 0 and e.def.get("artillery", false):
				has_arty = true
		if has_arty:
			attack_ground_mode = true
			hud.show_hint("Bombard: right-click the ground (artillery only)")
		else:
			rally_mode = true
			hud.show_hint("Rally: right-click the map to set the gather point")
	elif _is(k, "unload"):
		for e in get_selected():
			if e.player == 0 and e.kind == "building":
				game.cmd_unload(e)
	elif _is(k, "select_all_peasants"):
		var arrp: Array = []
		for e in game.units_of(0):
			if e.sid == "peasant":
				arrp.append(e)
		_set_selection(arrp)
	elif _is(k, "select_idle_mines"):
		var arrm: Array = []
		for b in game.buildings_of(0):
			if b.sid.begins_with("mine_") and b.finished and int(b.workers) < int(b.get("slots", b.def.get("slots", 5))):
				arrm.append(b)
		_set_selection(arrm)
	elif _is(k, "add_same_type"):
		var sel2 := get_selected()
		if not sel2.is_empty():
			var sid2: String = sel2[0].sid
			var cur2 := sel2.duplicate()
			for e in game.units_of(0):
				if e.sid == sid2 and not cur2.has(e):
					cur2.append(e)
			_set_selection(cur2)
	elif _is(k, "minimap_toggle"):
		if hud != null and hud.minimap_rect != null:
			hud.minimap_rect.get_parent().visible = not hud.minimap_rect.get_parent().visible
```

- In `_right_order` TOP (after the ghost cancel, L158–160) add:

```gdscript
	if attack_ground_mode:
		attack_ground_mode = false
		for e in get_selected():
			if e.player == 0 and e.def.get("artillery", false):
				game.cmd_attack_ground(e, pw)
		return
```

- G10 adds `cmd_attack_ground`/`cmd_unload`; until G10 is done these two
  branches reference functions that do not exist yet → **add these two stubs
  to game.gd NOW** (empty bodies, one line each):
  `func cmd_attack_ground(e: Dictionary, pos: Vector2) -> void:` + `pass`,
  `func cmd_unload(b: Dictionary) -> void:` + `pass`.
  G10.1/G10.5 then REPLACE the stub bodies with the real implementations.

ACCEPTANCE G5: `--ui-test --ui-only order_keys` green; windowed: select
musketeers, press D → they stop shooting; E → resume. Peasant + K → bar18 ghost.

## G6 — Fog actually hides things + incremental fog updates

WHY: enemy units render through fog today (world draws every entity); the fog
loop repaints 102k pixels 2×/s. Donor: unexplored = black, explored-not-visible
= dimmed terrain WITHOUT enemy units.

### G6.1 `world.gd`: add vars: `var fog_vis: PackedByteArray = PackedByteArray()`
(currently-visible tiles) and `var fog_counts: PackedInt32Array`.
In `bind()` after `fog_explored.resize(...)` (L72) add:
`fog_vis.resize(game.MAP_W * game.MAP_H)` and `fog_counts.resize(game.MAP_W * game.MAP_H)`.

### G6.2 REPLACE `_update_fog` (L402–437) with:

```gdscript
func _update_fog() -> void:
	if game == null:
		return
	if not Data.FOG_OF_WAR:
		return
	for rq in game.reveal_requests:
		var c: Vector2 = rq.pos
		var rr: float = rq.r
		var t0 := game.tile_of(c - Vector2(rr, rr))
		var t1 := game.tile_of(c + Vector2(rr, rr))
		for ty in range(maxi(0, t0.y), mini(game.MAP_H, t1.y + 1)):
			for tx in range(maxi(0, t0.x), mini(game.MAP_W, t1.x + 1)):
				if Vector2(tx * 2 + 1, ty * 2 + 1).distance_to(c) <= rr:
					fog_explored[ty * game.MAP_W + tx] = 1
	game.reveal_requests.clear()
	fog_counts.fill(0)
	for e in game.entities:
		if e.dead or e.player != 0:
			continue
		var r: float = e.def.get("search", 24.0) if e.kind == "unit" else e.def.get("radius", 2.0) * 6.0
		var t0 := game.tile_of(e.pos - Vector2(r, r))
		var t1 := game.tile_of(e.pos + Vector2(r, r))
		for y in range(maxi(0, t0.y), mini(game.MAP_H, t1.y + 1)):
			for x in range(maxi(0, t0.x), mini(game.MAP_W, t1.x + 1)):
				var c := Vector2((x + 0.5) * Data.TILE_M, (y + 0.5) * Data.TILE_M)
				if c.distance_to(e.pos) <= r:
					fog_counts[y * game.MAP_W + x] += 1
	for i in game.MAP_W * game.MAP_H:
		var v: int = 1 if fog_counts[i] > 0 else 0
		if v == 1:
			fog_explored[i] = 1
		if fog_vis[i] == v:
			continue
		fog_vis[i] = v
		var x: int = i % game.MAP_W
		var y: int = i / game.MAP_W
		if v == 1:
			fog_img.set_pixel(x, y, Color(0, 0, 0, 0))
		elif fog_explored[i] == 1:
			fog_img.set_pixel(x, y, Color(0, 0, 0, 0.30))
		else:
			fog_img.set_pixel(x, y, Color(0, 0, 0, 0.78))
	fog_tex.update(fog_img)

func tile_visible(p: Vector2) -> bool:
	if not Data.FOG_OF_WAR:
		return true
	var t := game.tile_of(p)
	if t.x < 0 or t.y < 0 or t.x >= game.MAP_W or t.y >= game.MAP_H:
		return false
	return fog_vis[t.y * game.MAP_W + t.x] == 1

func tile_explored(p: Vector2) -> bool:
	if not Data.FOG_OF_WAR:
		return true
	var t := game.tile_of(p)
	if t.x < 0 or t.y < 0 or t.x >= game.MAP_W or t.y >= game.MAP_H:
		return false
	return fog_explored[t.y * game.MAP_W + t.x] == 1
```

### G6.3 Hide enemies: in `_draw_units` after the cull check (L766–767) add:
`if e.player != 0 and not tile_visible(e.pos): continue`
In `_draw_buildings` after its cull (L547–548) add:
`if e.player != 0 and not tile_explored(e.pos): continue`
In `_draw_corpses` after cull add:
`if int(c.player) != 0 and not tile_explored(c.pos): continue`
In `_draw_fx` rally-flag loop and squad-link loop: skip entries whose owner is
not player 0 and not visible (squad links are own-only already; rally flags:
add `if e.player != 0: continue`).
In `hud.gd _update_minimap` entity loop (L727–739): for enemy entities use
`world.tile_visible(e.pos)` for units and `world.tile_explored(e.pos)` for
buildings; skip otherwise. (Own entities always drawn.)

ACCEPTANCE G6: selftest green; windowed screenshot at start: enemy base NOT
visible on minimap or map until scouts reach it; walking a unit forward reveals
a clean circle; leaving dims it and enemy units vanish.

## G7 — Terrain: chunked, higher-res, blended types (quality + speed)

WHY: 8 px/tile upscaled 4× = blurry; hard seams between grass/dirt/sand; one
2560² texture rebuilt fully at bind. Chunked lazy terrain gives 16 px/tile
detail only where the camera looks, with soft type transitions.

### G7.1 `world.gd`: add vars:

```gdscript
const CHUNK_T := 32          # tiles per chunk side
var terrain_chunks: Dictionary = {}   # Vector2i -> Sprite2D
var terrain_order: Array = []         # LRU keys
var terrain_px := 16
var res_dirty := 0
var bld_dirty := 0
var last_view_pos := Vector2.INF
```

### G7.2 REPLACE `_build_terrain` (L291–380) with a variant-prep + chunk builder.
Keep the existing variant code (L292–357) VERBATIM as a new function
`_prep_variants() -> Array` returning `hlv` (it already builds `variants` and
`hlv`; move those lines unchanged, end with `return hlv`). Store result in a new
var `var terrain_hlv: Array = []`. In `bind()` REPLACE the `_build_terrain()`
call (L49) with `terrain_hlv = _prep_variants()` (must run before layers are
created). DELETE the old single-image loop/texture (L358–380) and the
`terrain_sprite` var usage (keep the var declared, unused, so nothing else
breaks; grep `terrain_sprite` — only bind used it).
ADD:

```gdscript
func _chunk_key(cx: int, cy: int) -> Vector2i:
	return Vector2i(cx, cy)

func _build_chunk(cx: int, cy: int) -> Sprite2D:
	var px := terrain_px
	var img := Image.create(CHUNK_T * px, CHUNK_T * px, false, Image.FORMAT_RGB8)
	var masks: Array = []
	for d in 4:
		var m := Image.create(px, px, false, Image.FORMAT_L8)
		for y in px:
			for x in px:
				var t: float = 0.0
				match d:
					0: t = clampf(1.0 - float(x) / (px * 0.45), 0.0, 1.0)   # left neighbour
					1: t = clampf(1.0 - float(px - 1 - x) / (px * 0.45), 0.0, 1.0)
					2: t = clampf(1.0 - float(y) / (px * 0.45), 0.0, 1.0)
					3: t = clampf(1.0 - float(px - 1 - y) / (px * 0.45), 0.0, 1.0)
				m.set_pixel(x, y, Color(t, t, t))
		masks.append(m)
	for ly in CHUNK_T:
		for lx in CHUNK_T:
			var x := cx * CHUNK_T + lx
			var y := cy * CHUNK_T + ly
			if x >= game.MAP_W or y >= game.MAP_H:
				continue
			var t: int = game.terrain[y * game.MAP_W + x]
			if t < 0 or t > 5:
				t = 0
			var m: float = _wnoise(float(x) * 0.13, float(y) * 0.13)
			var vi: int = absi(int(m * 5.0) + (x / 4) + (y / 4)) % 8
			var hh: float = game.height_at(Vector2((float(x) + 0.5) * Data.TILE_M, (float(y) + 0.5) * Data.TILE_M))
			var lvl := 0 if hh < -0.6 else (2 if hh > 0.6 else 1)
			var sim: Image = (terrain_hlv[lvl] as Array)[t][vi]
			var big := sim.duplicate() as Image
			big.resize(px, px, Image.INTERPOLATE_BILINEAR)
			img.blit_rect(big, Rect2i(0, 0, px, px), Vector2i(lx * px, ly * px))
			# soft blend toward each different-type neighbour (no hard seams)
			for d in 4:
				var nx: int = x + [-1, 1, 0, 0][d]
				var ny: int = y + [0, 0, -1, 1][d]
				if nx < 0 or ny < 0 or nx >= game.MAP_W or ny >= game.MAP_H:
					continue
				var nt: int = game.terrain[ny * game.MAP_W + nx]
				if nt == t or nt < 0 or nt > 5:
					continue
				var nsim: Image = (terrain_hlv[lvl] as Array)[nt][vi]
				var nbig := nsim.duplicate() as Image
				nbig.resize(px, px, Image.INTERPOLATE_BILINEAR)
				# soft masked paste toward the neighbour type (no hard seams)
				for yy in px:
					for xx in px:
						var a: float = masks[d].get_pixel(xx, yy).r * 0.85
						if a <= 0.01:
							continue
						var c0: Color = img.get_pixel(lx * px + xx, ly * px + yy)
						var c1: Color = nbig.get_pixel(xx, yy)
						img.set_pixel(lx * px + xx, ly * px + yy, c0.lerp(c1, a))
	var tex := ImageTexture.create_from_image(img)
	var sp := Sprite2D.new()
	sp.texture = tex
	sp.centered = false
	sp.position = Vector2(cx * CHUNK_T * Data.TILE_M * view_scale, cy * CHUNK_T * Data.TILE_M * view_scale)
	sp.scale = Vector2(Data.TILE_M * view_scale / float(px), Data.TILE_M * view_scale / float(px))
	sp.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	sp.z_index = -10
	add_child(sp)
	return sp

func _sync_terrain_chunks() -> void:
	var t0 := game.tile_of(view_rect.position)
	var t1 := game.tile_of(view_rect.end)
	var c0x := maxi(0, t0.x / CHUNK_T)
	var c0y := maxi(0, t0.y / CHUNK_T)
	var c1x := mini(int(ceil(float(game.MAP_W) / CHUNK_T)) - 1, t1.x / CHUNK_T)
	var c1y := mini(int(ceil(float(game.MAP_H) / CHUNK_T)) - 1, t1.y / CHUNK_T)
	for cy in range(c0y, c1y + 1):
		for cx in range(c0x, c1x + 1):
			var k := _chunk_key(cx, cy)
			if not terrain_chunks.has(k):
				terrain_chunks[k] = _build_chunk(cx, cy)
				terrain_order.append(k)
				while terrain_order.size() > 24:
					var old: Vector2i = terrain_order.pop_front()
					var sp2: Sprite2D = terrain_chunks.get(old, null)
					if sp2 != null:
						sp2.queue_free()
					terrain_chunks.erase(old)
```

Call `_sync_terrain_chunks()` from `sync()` right after `view_rect` is computed
(L385). First visible chunks build lazily (~9 chunks × 1024 tiles × small loops
≈ 0.3 s one-time hitch at start; acceptable, and only once per area).

### G7.3 Low-quality fallback: `config.gd` DEFAULT display add
`"terrain_px": 16,`; `apply()` display section add
`Data.TERRAIN_PX = int(num("display.terrain_px", 16))`; `data.gd` add
`static var TERRAIN_PX := 16`; world `bind()` set `terrain_px = Data.TERRAIN_PX`.
Weak hardware preset (G8.6) sets 8.

ACCEPTANCE G7: selftest green; screenshot shows crisp grass with soft dirt
edges, no checker seams; pan across map: no stutter after first chunk build;
memory stays bounded (24 chunks).

## G8 — PERFORMANCE PROGRAM (the "crappy hardware" goal)

Target: 600 live units + 60 buildings at ≥30 fps render and ≤8 ms sim/tick on
an integrated GPU. Measure first (G8.0), then apply G8.1–G8.6 in order; re-run
the bench after each and record numbers in `app/shots/perf.md`.

### G8.0 Bench harness. `main.gd`: add flag `--bench` in `_parse_args`
(set `bench_mode = true`); in `_ready` route it like `--cli` but through
`_setup_full_game()` with world (so render cost is measured) and after setup
spawn 300 units per side in two blobs near each home:

```gdscript
	if bench_mode:
		for pi in 2:
			var home: Vector2 = game._start_positions()[pi]
			for i in 300:
				var sid: String = ["pikeman", "serdiuk", "archer", "cossack"][i % 4]
				game.spawn(sid, pi, home + Vector2((i % 20) * 1.2 - 12, (i / 20) * 1.2 - 12))
		bench_t = 0.0
```

vars `var bench_mode := false`, `var bench_t := 0.0`, `var bench_frames := 0`,
`var bench_sim_ms := 0.0`. In `_process` around the sim while-loop accumulate
`var t0 := Time.get_ticks_usec()` … `bench_sim_ms += (Time.get_ticks_usec()-t0)/1000.0`;
each frame `bench_frames += 1`; when `bench_t >= 30.0` write
`app/shots/bench.json` `{fps: bench_frames/30.0, sim_ms_per_tick: bench_sim_ms/(30*Data.FPS), units: game.entities.size()}` and `_quit(0)`.
Run: `godot --path app -- --bench --timeout 120` (windowed, real GPU) and
`godot --headless --path app -- --bench --timeout 120` (sim only).
Record baseline BEFORE changes.

### G8.1 Spatial grid + cached lists + dead compaction (`game.gd`).
Add vars near L32:

```gdscript
var grid: Dictionary = {}          # Vector2i cell -> Array of entity dicts
const GRID_M := 8.0
var live_units: Array = []
var live_blds: Array = []
var officers: Array = [[], []]
var drummers: Array = [[], []]
var priests: Array = [[], []]
var compact_t := 0.0
```

ADD functions:

```gdscript
func _grid_rebuild() -> void:
	grid.clear()
	live_units.clear()
	live_blds.clear()
	officers[0].clear(); officers[1].clear()
	drummers[0].clear(); drummers[1].clear()
	priests[0].clear(); priests[1].clear()
	for e in entities:
		if e.dead:
			continue
		var c := Vector2i(int(e.pos.x / GRID_M), int(e.pos.y / GRID_M))
		if not grid.has(c):
			grid[c] = []
		grid[c].append(e)
		if e.kind == "unit":
			live_units.append(e)
			var p: int = int(e.player)
			if p >= 0 and p < 2:
				if str(e.sid) in ["officer", "officer18"]:
					officers[p].append(e)
				elif str(e.sid) in ["drummer", "drummer18"]:
					drummers[p].append(e)
				elif str(e.sid) in ["priest", "pope", "padre", "mullah"]:
					priests[p].append(e)
		else:
			live_blds.append(e)

func grid_query(pos: Vector2, r: float) -> Array:
	var out: Array = []
	var c0 := Vector2i(int((pos.x - r) / GRID_M), int((pos.y - r) / GRID_M))
	var c1 := Vector2i(int((pos.x + r) / GRID_M), int((pos.y + r) / GRID_M))
	for cy in range(c0.y, c1.y + 1):
		for cx in range(c0.x, c1.x + 1):
			var cell: Array = grid.get(Vector2i(cx, cy), [])
			for e in cell:
				out.append(e)
	return out

func _compact() -> void:
	var keep: Array = []
	for e in entities:
		if e.dead:
			by_id.erase(e.id)
		else:
			keep.append(e)
	entities = keep
	for pi in 2:
		var pl: Array = []
		for id in players[pi].entities:
			var e: Dictionary = by_id.get(id, {})
			if not e.is_empty():
				pl.append(id)
		players[pi].entities = pl
	var gk: Array = []
	for g in gates:
		if not g.dead:
			gk.append(g)
	gates = gk
	var rk: Array = []
	for n in res_nodes:
		if n.max_hits == 0 or n.hits > 0:
			rk.append(n)
		else:
			by_id.erase(n.id)
	res_nodes = rk
```

Call `_grid_rebuild()` at the TOP of `tick(dt)` right after `time_s += dt`
(L1254). Call `_compact()` from `tick` every 5 s:
`compact_t += dt; if compact_t >= 5.0: compact_t = 0.0; _compact()`.
IMPORTANT: `_grid_rebuild` must also run once at the end of `setup()` so
commands issued before the first tick (selftest!) see a populated grid.
NOTE: depleted food nodes are kept (G10.3 re-sows them); only non-food
depleted nodes are dropped — adjust the `res_nodes` filter above to
`if n.max_hits == 0 or n.hits > 0 or n.type == "food":`.

### G8.2 Rewrite the scan functions to use grid/lists (same signatures/semantics):
- `enemies_in_radius` (L516): `for e in grid_query(pos, r):` instead of `for e in entities:`.
- `enemies_preferred` (L556): same replacement.
- `officer_near` (L1124): loop `officers[player]` (guard player index 0..1).
- `drummer_near` (L1132): loop `drummers[player]`.
- `_priest_heal` (L1738): loop `grid_query(e.pos, 8.0)`.
- `_morale_shock` (L1875): loop `grid_query(pos, 10.0)`.
- `_apply_hit` splash loop (L1861): `for u in grid_query(at, splash_r):` (use the
  existing radius variable name in that block).
- `_tick_projectiles` victim loop (L1895): `for u in grid_query(pr.target, 3.0):`.
- `_tick_gather` food-crowding loop (L1972): `for u in grid_query(node.pos, node.radius + 2.0):`.
- `_tick_building` capture loop (L2111): `for u in grid_query(e.pos, 8.0 + e.def.radius):`.
- `_tick_building` tower target (L2096): unchanged call (now grid-backed).
- `_fire` `_wall_between` (L1764): `for e in grid_query((a+b)*0.5, a.distance_to(b)*0.5 + 4.0):`
  (keep the segment math inside).
- `buildings_of` (L447): iterate `live_blds` instead of `entities`.
- `units_of` (L454): iterate `live_units`.
- `unit_count` (L440): iterate `live_units`.
- `_tick_rout` (L1721–1723): `enemies_in_radius` now grid-backed; replace
  `buildings_of(e.player)` home pick with nearest via `live_blds` loop.
- `_separate_units` building pass (L1330–1334): replace `for b in entities:`
  with `for b in grid_query(e.pos, 6.0):` and keep the `kind != "building"` skip.
- `_separate_units` unit grid: replace string keys `str(cx)+","+str(cy)` with
  `Vector2i(cx, cy)` (both insert L1290 and lookup L1304).
- `_tick_upkeep` (L1361): iterate `live_units + live_blds`? It sums `eat` over
  entities of a player: replace `for e in entities:` with `for e in live_units:`
  plus a second loop `for e in live_blds:` (walls/towers eat too). Keep the
  `e.player != pi` skip.
- `_tick_cleanup` (L1398): iterate `live_units + live_blds` (two loops) — or keep
  `entities` (it is one O(N) pass, fine). Keep as-is.

### G8.3 Hoist allocations:
- `_target_score` (L544): move the `table` dict literal to a file-level
  `const TARGET_TABLE := {...}` (same content) and use `TARGET_TABLE.get(ac, {})`.
- `_noise2` (L315): move the inner `var h := func...` to a file-level
  `static func _hash2(ix: int, iy: int) -> float:` with the same body; call it.
- `_tick_unit` attack branch: move the artillery `w.duplicate()` + height-bonus
  block (L1581–1587) to AFTER the `cooldown <= 0` gate (grep the gate in that
  branch) so it only runs on actual shots.
- `tick` corpses/rubble aging (L1263–1268): replace `.filter()` lambdas with
  in-place reverse-index removal loops (no new arrays per tick).

### G8.4 Throttle acquisition & auras to 8 Hz (behaviour-preserving):
In `spawn()` unit dict add `"acq_t": 0.0, "aur_off": false, "aur_dru": false,`.
In `_tick_unit` TOP add:

```gdscript
	e.acq_t = float(e.get("acq_t", 0.0)) - dt
	if e.acq_t <= 0.0:
		e.acq_t = 0.125
		e["acq_now"] = true
		e.aur_off = officer_near(e.pos, e.player)
		e.aur_dru = drummer_near(e.pos, e.player)
	else:
		e["acq_now"] = false
```

Then `_update_morale` (L1700/1702) uses `bool(e.aur_off)` / `bool(e.aur_dru)`
instead of calling the near-functions; `effective_speed` (L1142) uses
`bool(e.get("aur_dru", false))`; `effective_damage` (L1148) keeps
`officer_near` (called per shot only, now grid+list backed).
Idle acquisition (L1690), attackmove/guard/patrol acquisition (L1544/1613/1625):
at EACH site replace the single `var en := enemies_...(...)` line with this
pattern (keep each site's existing variable name `en`/`foe`/`foe2` and its
existing `hold_fire`/weapon conditions afterwards):

```gdscript
			var en: Dictionary = {}
			if bool(e.get("acq_now", false)):
				en = enemies_preferred(e.pos, e.player, float(e.def.search), e)
				e["acq_target"] = en.id if not en.is_empty() else 0
			else:
				en = by_id.get(int(e.get("acq_target", 0)), {})
				if not en.is_empty() and (en.dead or en.player == e.player or en.pos.distance_to(e.pos) > float(e.def.search)):
					en = {}
```

(For the idle site L1690 use `enemies_in_radius(e.pos, e.player, float(e.def.search))`
in the refresh branch instead of `enemies_preferred`.)

### G8.5 Render dirty-flags (`world.gd sync`, L382–397):
Replace the four unconditional `queue_redraw()` calls with:

```gdscript
	var moved := last_view_pos == Vector2.INF or last_view_pos.distance_to(view_rect.position) > 4.0 or last_view_pos.distance_to(view_rect.end) > 4.0
	last_view_pos = view_rect.position
	if moved or game.res_dirty != res_dirty:
		res_dirty = game.res_dirty
		res_layer.queue_redraw()
	if moved or game.bld_dirty != bld_dirty:
		bld_dirty = game.bld_dirty
		bld_layer.queue_redraw()
	unit_layer.queue_redraw()
	fx_layer.queue_redraw()
```

`game.gd`: add `var res_dirty := 0` and `var bld_dirty := 0`. Increment
`res_dirty` in `_add_res` and where a node depletes (`_tick_gather`, grep
`post_event("depleted"`); increment `bld_dirty` in: `_tick_building` construction
progress line, `_apply_hit` when target kind building, `_on_building_finished`,
`_kill` building branch, `spawn` building branch, and `input_controller.gd
_set_selection` (selection rings live in bld/unit layers; unit layer always
redraws so only buildings need it) — add `game.bld_dirty += 1` at the end of
`_set_selection`. Also increment `bld_dirty` in `cmd_make_gate/cmd_gate_toggle`.

### G8.6 Quality presets + VRAM-friendly sheets.
`config.gd` DEFAULT display add: `"quality": "high",` `"sprite_cell": 160,`
`"fx_cap": 220,` `"fog_interval": 0.5,` `"minimap_interval": 0.25,`.
`apply()`: `Data.QUALITY = text("display.quality", "high")`,
`Data.SPRITE_CELL = int(num("display.sprite_cell", 160))`, etc. (add matching
`static var`s in data.gd).
Preset meanings (document in README + menu options G12):
- high: terrain_px 16, sprite_cell 160, fx_cap 220, shadows on.
- medium: terrain_px 12, sprite_cell 96, fx_cap 120.
- low: terrain_px 8, sprite_cell 64, fx_cap 60, shadows off
  (`world._draw_sprite` shadow param default false when `Data.QUALITY == "low"`;
  skip the G2 shadow texture draw too), fog_interval 1.0, minimap_interval 0.5.
World `bind()`: `fog_timer` initial and `sync()` reset use `Data.FOG_INTERVAL`;
hud `mm_timer` reset uses `Data.MINIMAP_INTERVAL`; `add_fx` cap uses `Data.FX_CAP`.
Sprite tiers: rebake ONCE per tier into separate dirs (background, CPU):
```
& "C:\Program Files\Blender Foundation\Blender 5.2\blender.exe" --background --factory-startup --python app\tools\bake_sprites.py -- --game "C:\Games\Cossacks 3" --out app\assets\models\anim96 --size 96 --engine cycles --samples 4
... --out app\assets\models\anim64 --size 64 ...
python app/tools/sheet_metrics.py --dir app/assets/models/anim96
python app/tools/sheet_metrics.py --dir app/assets/models/anim64
godot --headless --path app --import
```
`world.gd`: add `func _anim_dir() -> String:` returning
`"res://assets/models/anim%d" % Data.SPRITE_CELL` when cell != 160 and the dir
exists (`DirAccess.dir_exists_absolute`), else `"res://assets/models/anim"`;
use it in `_draw_anim`, `_draw_corpses`, `_bld_anim` path building and in bind's
index.json load (`_anim_dir() + "/index.json"`). Building sheets stay in the
160 dir always (they are few); only unit sheets switch.
VRAM: for every `app/assets/models/anim*/*.png.import` set `compress/mode=2`
(VRAM compressed) via a tiny python loop over the .import files (rewrite the
line `compress/mode=0` → `2`), then `--import`. If sheets show block artifacts
on the weak GPU, revert to 0 and note it. This cuts sheet VRAM ~4×.

ACCEPTANCE G8: bench.json after all sub-steps: headless sim_ms_per_tick ≤ 8 ms
with 600 units; windowed fps ≥ 30 on the owner machine (record the actual
number). selftest + uitest + cli 60 s all green. Write `app/shots/perf.md`
with baseline vs final table.

## G9 — Sim correctness fixes (small, surgical; each is independent)

All in `game.gd` unless noted. Back up first. Do them as ONE step but verify
selftest after each edit if cheap.

1. **farm_cap on destruction**: in `_kill` building branch (after score adjust,
   grep `players[e.player].score`) add:
   `players[e.player].farm_cap = maxi(0, int(players[e.player].farm_cap) - int(e.def.get("farm", 0)))`
2. **cmd_delete sign** (L1468–1469): `farm_cap += int(e.def.farm)` →
   `farm_cap = maxi(0, int(players[e.player].farm_cap) - int(e.def.get("farm", 0)))`.
3. **Capture double farm** (L2135–2138): the transfer adds farm then calls
   `_on_building_finished(e)` which adds it again AND refills mine deposit.
   Replace the `_on_building_finished(e)` call in the capture block with:
   `if e.sid.begins_with("mine_"): e["deposit_left"] = float(e.get("deposit_left", 0.0))`
   (i.e. do nothing else; farm already transferred; rally keeps old owner's
   point — also add `e.erase("rally")`).
4. **Per-node deposits**: `_generate_map` deposit creation (grep `max_hits == 0`
   / `_add_res(..., 0, ...)`) — after creating each deposit node set
   `n["left"] = float(Data.DEPOSITS.get(n.type, 30000)) / 3.0` (3 nodes per type
   typical; verify count in mapgen and divide by the actual count). In
   `_on_building_finished` mine init (L398–400) replace the global-pool copy
   with `e["deposit_left"] = float(node.get("left", 0.0))` where `node` is the
   deposit under the mine (grep the existing lookup there). In `_tick_building`
   mine income (L2080–2087) after subtracting from `deposit_left` also subtract
   from the node: find the node via `by_id` of `e.get("deposit_node", 0)`; set
   `e["deposit_node"] = node.id` at mine init. When node.left <= 0 the mine
   exhausts as today.
5. **Splash prot per victim** (L1861–1872): inside the splash loop replace the
   dead `if pb != 0 ... pass` with per-victim computation:
   `var vp: Array = u.prot.duplicate(); for k in 6: vp[k] = int(vp[k]) + int(players[u.player].get("prot_bonus", 0)) + _formation_def(u)`
   and pass `vp` to `Data.apply_damage` instead of the target's prot.
6. **Post-research HP for new spawns** (`spawn` L371–373): after hp_mult apply:
```gdscript
	var pp: Dictionary = players[player]
	if kind == "building":
		var add: int = int(pp.get("fort_hp_add", 0)) if sid in ["wal", "tow", "gat"] else int(pp.get("bld_hp_add", 0))
		e.max_hp += add
		e.hp += add
	elif def.get("artillery", false):
		e.max_hp = int(e.max_hp * float(pp.get("art_hp", 1.0)))
		e.hp = e.max_hp
```
   (match the local variable names `kind`/`def` used in spawn; grep them.)
7. **Gate ownership** (`cmd_gate_toggle` L1449): add at top
   `if g.player != 0 and not bool(g.get("ai_ok", false)): return` — and in
   `cmd_make_gate` (L1440) replace `w.player != 0` with `w.player < 0` so AI can
   convert too; AI sets nothing special (toggle only via player HUD anyway).
   Simpler and safe: `cmd_gate_toggle` requires `g.player == 0` OR caller passes
   `force` — keep player-0-only and let AI gates stay open always (document).
8. **Famine message spam** (L1385–1386): wrap the `say(...)` in
   `if float(p.get("famine_msg_t", 0.0)) <= 0.0: p["famine_msg_t"] = 10.0; say(...)`
   and decrement `p["famine_msg_t"]` by dt at the top of the per-player loop.
9. **Attack stuck give-up**: in `_tick_unit` attack branch, after the chase
   `_step_move` call, add:
```gdscript
			if not e.moving:
				e.stuck_t = float(e.get("stuck_t", 0.0)) + dt
				if e.stuck_t > 6.0:
					e.stuck_t = 0.0
					e.order = {"type": "attackmove", "pos": t.pos}
			else:
				e.stuck_t = 0.0
```
10. **Patrol route preserved**: `cmd_patrol` (L674) stores a/b in the order
    (verify it does: grep `"patrol"` order dict); in the attack-resume block
    (L1561–1564) replace the fabricated ±4 m leg with the stored
    `o.get("a", e.pos)` / `o.get("b", e.pos)` fields.
11. **Projectile cap** (L1818/1826): `> 64` → `> 512` (both sites).
12. **`_step_move` symmetric probes** (L1491): replace the angle expression with
    `var ang: float = (PI / 12.0) * float((i + 1) / 2 + (1 if i % 2 == 0 else 0)) * (1.0 if i % 2 == 0 else -1.0)`
    — simpler correct version: `var step_i: int = (i + 1) / 2 + 1; var ang: float = (PI / 12.0) * float(step_i) * (1.0 if i % 2 == 0 else -1.0)`
    giving ±15°, ±30°, … ±90°. Verify by reading the loop and keeping `sgn` usage consistent.
13. **Capture event spam** (L2125): replace `int(time_s*2.0)%2==0` condition with
    a per-building timer `e["cap_evt_t"]` decremented by dt, post when <= 0 and reset to 0.5.

ACCEPTANCE G9: selftest 21/21 (capture step must still pass — it asserts farm
transfer; if it asserted the doubled value, fix the TEST expectation to the
correct single transfer and note it), uitest green, cli 60 s clean.

## G10 — Missing mechanics: garrison, peasant capture, fields, refunds, attack-ground, formation facing

### G10.1 Garrison (`game.gd`). REPLACE the `cmd_unload` stub from G5.3 and ADD
`cmd_enter` (the stub body of `cmd_unload` becomes the function below):

```gdscript
func cmd_enter(e: Dictionary, b: Dictionary) -> void:
	if e.dead or e.kind != "unit" or e.player != b.player or b.dead or not b.finished:
		return
	if not str(b.sid) in ["tow", "cen"]:
		return
	if e.def.get("artillery", false) or e.def.get("cavalry", "") != "":
		return
	if int(b.get("garrison", 0)) >= 10:
		return
	_leave_building(e)
	e.inside_of = b.id
	e.order = {"type": "none"}
	e["hidden"] = true
	b["garrison"] = int(b.get("garrison", 0)) + 1

func cmd_unload(b: Dictionary) -> void:
	if b.dead or b.kind != "building":
		return
	var k := 0
	for e in live_units:
		if e.dead or e.inside_of != b.id or not bool(e.get("hidden", false)):
			continue
		e.inside_of = 0
		e["hidden"] = false
		e.pos = b.pos + Vector2(cos(k * 2.4), sin(k * 2.4)) * (b.def.radius + 1.0)
		e.order = {"type": "none"}
		k += 1
	b["garrison"] = 0
```

In `_kill` building branch: before removing, unload garrison (call
`cmd_unload(e)` first) so hidden units don't vanish; also eject them killed?
Original: garrison dies with building — choose: kill them (`_kill(u)` loop) and
document. Pick kill-with-building (simpler, matches siege feel).
In `_tick_building`: garrisoned units heal 2 hp/s (loop `live_units` with
`inside_of == e.id and hidden` — cheap: only when `garrison > 0`); tower fire
damage bonus: in the tower weapon block add `+ 2 * int(e.get("garrison", 0))`
to the damage passed to `_fire`/`_apply_hit` (grep the tower dmg expression).
Capture resistance (L2106+): divide capture speed by 2 when `garrison > 0`.
`world.gd _draw_units`: skip `bool(e.get("hidden", false))` units (after cull).
`input_controller.gd _right_order`: in the friendly-building branch (L212–222)
before the mine check add:
`if target.finished and str(target.sid) in ["tow", "cen"] and e.kind == "unit" and not e.def.get("artillery", false) and e.def.get("cavalry", "") == "": game.cmd_enter(e, target); continue`
HUD: when a tow/cen with garrison > 0 is selected show an "Unload [U]" button
(next to the Gate button block) calling `game.cmd_unload(e)`.
Minimap/HUD counts: hidden units still count for pop (correct).

### G10.2 Peasant capture (`game.gd _apply_hit` TOP, after the immunity check):

```gdscript
	if t.kind == "unit" and str(t.sid) == "peasant" and e.kind == "unit" \
			and e.player != t.player and not e.def.get("support", false) \
			and bool(Data.CAPTURE_ENABLED) and str(e.sid) != "peasant":
		var oldp: int = int(t.player)
		t.player = e.player
		t.order = {"type": "none"}
		t.inside_of = 0
		t["morale"] = 70.0
		players[oldp].entities.erase(t.id)
		players[int(e.player)].entities.append(t.id)
		post_event("capture", t.pos, "unit")
		if e.player == 0:
			say("Enemy peasant captured!")
		return
```

(Verify `players[].entities` is the id list name — grep `new_player`.)
Selftest: add assertion in G15.

### G10.3 Field re-sowing (`game.gd`). ADD:

```gdscript
func cmd_resow(e: Dictionary, node: Dictionary) -> void:
	if e.dead or str(e.sid) != "peasant" or node.is_empty() or str(node.type) != "food":
		return
	if node.hits > 0:
		cmd_gather(e, node)
		return
	e.order = {"type": "resow", "node": node.id}
```

In `_tick_unit` match add branch before `"gather":`:

```gdscript
		"resow":
			var fn: Dictionary = by_id.get(o.get("node", 0), {})
			if fn.is_empty() or fn.hits > 0:
				e.order = {"type": "none"}
				return
			var fslot := _work_slot(e, fn.pos, fn.radius + 0.7)
			if e.pos.distance_to(fslot) > 0.6:
				e.moving = true
				_step_move(e, fslot, effective_speed(e), dt, 0.35)
			else:
				e.moving = false
				e.face = (fn.pos - e.pos).angle()
				e["hit_t"] = float(e.get("hit_t", 0.0)) + dt
				if e.hit_t >= 2.0:
					e.hit_t = 0.0
					if not pay_cost(e.player, {"food": 20}):
						e.order = {"type": "none"}
						return
					fn.hits = int(fn.max_hits)
					res_dirty += 1
					post_event("construct", fn.pos, "field")
					e.order = {"type": "gather", "node": fn.id, "res": "food"}
```

`input_controller.gd _pick_res` (L239–250): allow depleted FOOD nodes
(change the skip to `if n.max_hits > 0 and n.hits <= 0 and n.type != "food": continue`);
in `_right_order` peasant+res branch call `game.cmd_resow(e, res)` instead of
`cmd_gather` when `res.hits <= 0`. Cursor: gainfood on depleted fields too
(G3 `_pick_res` now returns them). AI: G11 handles re-sow.
Mark cost 20 food / 2 s per hit-cycle as ESTIMATED in mechanics.json.

### G10.4 Queue cancel + refund. `hud.gd` train button creation (L310–319):
connect a second handler for shift-click: after `tb.pressed.connect(...)` add
`tb.gui_input.connect(_on_train_gui.bind(e, rsid))` and:

```gdscript
func _on_train_gui(ev: InputEvent, bld: Dictionary, sid: String) -> void:
	if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT and Input.is_key_pressed(KEY_SHIFT):
		for i in range(bld.queue.size() - 1, -1, -1):
			if bld.queue[i].sid == sid:
				var job: Dictionary = bld.queue[i]
				bld.queue.remove_at(i)
				Data.refund(game.players[0], Data.UNITS[sid].price)
				get_viewport().set_input_as_handled()
				refresh_selection(game.get_selected())
				return
```

(Verify `Data.refund` signature at data.gd L801 — adapt args if it takes
(player_dict, cost) vs (player_index, cost).) Tooltip add: "Shift+click cancels
one with refund".

### G10.5 Attack-ground (`game.gd`). REPLACE the `cmd_attack_ground` stub from
G5.3 with:

```gdscript
func cmd_attack_ground(e: Dictionary, pos: Vector2) -> void:
	if e.dead or not e.def.get("artillery", false):
		return
	e.order = {"type": "attackground", "pos": pos}
```

In `_tick_unit` match add branch:

```gdscript
		"attackground":
			var gp: Vector2 = o.get("pos", e.pos)
			var gd: float = e.pos.distance_to(gp)
			var gw := _pick_weapon(e, gd)
			if gw.is_empty():
				e.order = {"type": "none"}
				return
			if gd > float(gw.max):
				e.moving = true
				_step_move(e, gp, effective_speed(e), dt, 0.5)
			else:
				e.moving = false
				e.face = (gp - e.pos).angle()
				e.deploy_t = float(e.get("deploy_t", 0.0)) + dt
				e.cooldown = float(e.get("cooldown", 0.0)) - dt
				if e.cooldown <= 0.0 and e.deploy_t >= Data.ARTILLERY_DEPLOY_S:
					e.cooldown = float(gw.cd)
					var fake := {"pos": gp, "kind": "unit", "player": -1, "dead": false, "hp": 1, "max_hp": 1, "def": {"radius": 0.5}, "prot": [0, 0, 0, 0, 0, 0]}
					_fire(e, fake, gw)
```

NOTE: `_fire` instant-hit kinds would hit the fake dict; guard in `_fire`:
if `t.get("player", 0) == -1` force the projectile path (cannonball) regardless
of kind: wrap the instant-hit branch condition with `and int(t.get("player", 0)) != -1`.
`_tick_projectiles` landing vs fake target: victim search uses grid around
`pr.target` — works; the fake itself is not in entities so no self-hit.
Splash friendly fire applies (original does too).

### G10.6 Formation facing. `game.gd formation_targets` (L937–981): when the
selection belongs to a squad, read `var s: Dictionary = squad_of_unit(sel[0].id)`
and `var fa: float = float(s.get("face", 0.0))`; rotate each computed offset
vector by `fa` before adding to center. Update `s["face"]` in
`_squad_order_members` (L910) to `(dest - officer.pos).angle()` and in
`_tick_unit` move branch when the moving unit is an officer leading a squad.
Line formation then marches perpendicular to its facing like the original.

ACCEPTANCE G10: selftest + uitest green; new manual checks via G15 tests:
garrison hides units & U unloads; captured peasant changes colour; depleted
field re-sows; shift-click train refunds; R + right-click with cannon shells
the ground; formed line rotates with move direction.

## G11 — AI overhaul (replace `app/scripts/ai.gd` wholesale; backup first)

Design goals (from videos 1/3/9/13): quota economy, continuous production
within pop/queue limits, expansion, repairs, raids, combined-arms waves with
retreat, difficulty presets. Keep `class_name C3AI`, `_init(g, p)`, `tick(dt)`
signatures (main.gd constructs it). Full new file:

```gdscript
# Computer opponent: quota economy, mass production, combined-arms waves.
extends RefCounted
class_name C3AI

const Data = preload("res://scripts/data.gd")

var game: C3Game
var player: int
var think_t := 0.0
var wave := 0
var raid_ids: Array = []
var retreat_t := 0.0

func _init(g: C3Game, p: int) -> void:
	game = g
	player = p

func tick(dt: float) -> void:
	if not Data.AI_ENABLED:
		return
	think_t -= dt
	if think_t > 0.0:
		return
	think_t = Data.AI_THINK_INTERVAL
	var p: Dictionary = game.players[player]
	var res: Dictionary = {}
	for i in 6:
		res[Data.RES_NAMES[i]] = p.res[i]
	var peasants: Array = []
	var military: Array = []
	for u in game.units_of(player):
		if u.sid == "peasant":
			peasants.append(u)
		else:
			military.append(u)
	var blds := game.buildings_of(player, false)
	var counts: Dictionary = {}
	for b in blds:
		counts[b.sid] = int(counts.get(b.sid, 0)) + 1
	var fin: Dictionary = {}
	for b in blds:
		if b.finished:
			fin[b.sid] = int(fin.get(b.sid, 0)) + 1
	if fin.is_empty():
		return
	var home: Dictionary = game.by_id.get(int(p.get("home_id", 0)), {})
	if home.is_empty():
		home = blds[0]
		p["home_id"] = home.id
	_economy(peasants, res, p, counts, fin)
	_build(res, counts, fin, home, p)
	_research(res, fin)
	_train(peasants, military, res, counts, fin, p)
	_form_squads(military)
	_repair(peasants, blds)
	if _defense(military, home):
		return
	_raids(military, res)
	_waves(military, home, p)

# --- economy: target quotas instead of threshold ping-pong ---
func _economy(peasants: Array, res: Dictionary, p: Dictionary, counts: Dictionary, fin: Dictionary) -> void:
	var n := peasants.size()
	if n == 0:
		return
	# desired distribution: food 35%, wood 25%, stone 15%, mines 25%
	var want := {"food": int(n * 0.35), "wood": int(n * 0.25), "stone": int(n * 0.15)}
	var on := {"food": 0, "wood": 0, "stone": 0, "mine": 0}
	var idle: Array = []
	for pe in peasants:
		if pe.inside_of != 0:
			on["mine"] += 1
			continue
		if pe.order.type == "gather":
			var r: String = str(pe.order.get("res", ""))
			if r == "food" and pe.order.get("node", 0) != 0:
				var nd: Dictionary = game.by_id.get(int(pe.order.node), {})
				if not nd.is_empty() and nd.hits <= 0:
					game.cmd_resow(pe, nd)
					continue
			if on.has(r):
				on[r] += 1
				continue
		if pe.order.type == "none":
			idle.append(pe)
	# reassign only idle + surplus workers, never interrupt carriers
	for kind in ["food", "wood", "stone"]:
		var deficit: int = int(want[kind]) - int(on[kind])
		while deficit > 0 and not idle.is_empty():
			var pe: Dictionary = idle.pop_front()
			var node := game.nearest_res(pe.pos, kind, 80.0)
			if node.is_empty():
				break
			game.cmd_gather(pe, node)
			deficit -= 1
	for pe in idle:
		var dep := _mine_for(pe)
		if dep != "":
			var node := _deposit_node(dep)
			if not node.is_empty():
				game.cmd_gather(pe, node)
				continue
		var f := game.nearest_res(pe.pos, "food", 80.0)
		if not f.is_empty():
			game.cmd_gather(pe, f)
	# famine override: everyone to food
	if bool(p.get("famine", false)):
		for pe in peasants:
			if pe.inside_of == 0 and pe.order.type != "resow":
				var f2 := game.nearest_res(pe.pos, "food", 120.0)
				if not f2.is_empty():
					game.cmd_gather(pe, f2)

func _mine_for(pe: Dictionary) -> String:
	for k in ["gold", "iron", "coal"]:
		var m := game.nearest_mine(pe.pos, k, player)
		if not m.is_empty() and int(m.workers) < int(m.get("slots", m.def.get("slots", 5))):
			return k
	return ""

func _deposit_node(kind: String) -> Dictionary:
	var best: Dictionary = {}
	var bd := 1e9
	for n in game.res_nodes:
		if n.type == kind and n.max_hits == 0:
			var d: float = n.pos.distance_to(game.players[player].get("home_pos", Vector2.ZERO))
			if d < bd:
				bd = d
				best = n
	return best

# --- build order with expansion ---
func _build(res: Dictionary, counts: Dictionary, fin: Dictionary, home: Dictionary, p: Dictionary) -> void:
	var p0 := home.pos
	p["home_pos"] = p0
	if res.wood >= 120 and game.unit_count(player) + game.queue_count(player) + 3 >= int(p.farm_cap):
		_try_build("hou", home)
	for k in ["gold", "iron", "coal"]:
		var sid := "mine_" + k
		if int(counts.get(sid, 0)) == 0 and res.wood >= 100 and res.stone >= 100:
			_build_mine(k, home)
	if int(counts.get("bar", 0)) < 3 and res.wood >= 150 and res.stone >= 150:
		_try_build("bar", home)
	if int(counts.get("sto", 0)) == 0 and res.wood >= 50 and res.stone >= 20:
		_try_build("sto", home)
	if int(counts.get("bla", 0)) == 0 and res.wood >= 100 and res.stone >= 30:
		_try_build("bla", home)
	if int(counts.get("mil", 0)) == 0 and res.wood >= 200 and res.stone >= 100:
		_try_build("mil", home)
	if int(counts.get("mar", 0)) == 0 and res.wood >= 450:
		_try_build("mar", home)
	if int(counts.get("aca", 0)) == 0 and res.wood >= 1350 and res.stone >= 1200:
		_try_build("aca", home)
	if int(counts.get("sta", 0)) < 2 and res.wood >= 3200 and res.stone >= 850 and res.gold >= 850:
		_try_build("sta", home)
	if bool(p.get("has18c", false)) and int(counts.get("bar18", 0)) == 0 and res.wood >= 300 and res.stone >= 300:
		_try_build("bar18", home)
	if int(counts.get("dip", 0)) == 0 and res.wood >= 400 and res.gold >= 200:
		_try_build("dip", home)
	# expansion: second town hall when booming (cost escalation x3 aware)
	if int(fin.get("cen", 0)) >= 1 and int(counts.get("cen", 0)) < 2 and res.wood >= 2000 and res.stone >= 1500 and res.gold >= 1000:
		_try_build("cen", home, 30.0, 60.0)
	# wall ring: 12 segments, not 4
	if int(counts.get("wal", 0)) < 12 and res.stone >= 200 and res.wood >= 60:
		_try_build("wal", home, 14.0, 22.0)
	if int(counts.get("tow", 0)) < 2 and res.wood >= 300 and res.stone >= 400 and int(fin.get("bar", 0)) > 0:
		_try_build("tow", home, 16.0, 24.0)
	for b in game.buildings_of(player):
		if b.sid == "mar" and b.finished:
			_market_balance(b)

func _try_build(sid: String, home: Dictionary, min_d := 0.0, max_d := 18.0) -> void:
	var def: Dictionary = Data.BUILDINGS[sid]
	var lo: float = min_d if min_d > 0.0 else def.radius + 2.5
	var pos := _find_spot(home, def, lo, max_d)
	if pos == Vector2.INF:
		return
	game.place_building(player, sid, pos)

func _build_mine(kind: String, home: Dictionary) -> void:
	var best: Dictionary = {}
	var best_d := 1e9
	for n in game.res_nodes:
		if n.type == kind and n.max_hits == 0:
			var d: float = n.pos.distance_to(home.pos)
			if d < best_d and d > 6.0:
				best_d = d
				best = n
	if best.is_empty():
		return
	game.place_building(player, "mine_" + kind, best.pos)

func _find_spot(home: Dictionary, def: Dictionary, min_d: float, max_d: float) -> Vector2:
	for attempt in 24:
		var a := game.rng.randf() * TAU
		var r := game.rng.randf_range(min_d, max_d)
		var pos: Vector2 = home.pos + Vector2(cos(a), sin(a)) * r
		if not game.in_bounds(pos) or game.is_blocked(pos):
			continue
		var ok := true
		for b in game.buildings_of(player, false):
			if b.pos.distance_to(pos) < b.def.radius + def.radius + 1.0:
				ok = false
				break
		if ok:
			return pos
	return Vector2.INF

func _market_balance(market: Dictionary) -> void:
	var p: Dictionary = game.players[player]
	var res: Dictionary = {}
	for i in 6:
		res[Data.RES_NAMES[i]] = p.res[i]
	var rich := ""
	var best := 1500.0
	for k in ["wood", "stone", "food", "gold", "iron", "coal"]:
		if res.get(k, 0.0) > best:
			best = res.get(k, 0.0)
			rich = k
	if rich == "":
		return
	for k in ["iron", "coal", "gold", "food"]:
		if res.get(k, 0.0) < 800.0 and k != rich:
			game.trade(player, rich, k, 100.0)
			return

func _research(res: Dictionary, fin: Dictionary) -> void:
	var order := ["aca_bread1", "bla_sword1", "bla_armor1", "aca_wood1", "bla_bullet1", "sta_horse1", "art_caliber1", "mil_food1", "aca_field1", "cen_18c", "art_range1", "art_hp1"]
	for uid in order:
		var u: Dictionary = Data.UPGRADES.get(uid, {})
		if u.is_empty() or game.players[player].upgrades.has(uid):
			continue
		for b in game.buildings_of(player):
			if b.sid == u.building and b.finished and b.get("research") == null:
				if game.research(player, b, uid):
					return

# --- production: always fill queues, respect limits (uses train_unit!) ---
func _train(peasants: Array, military: Array, res: Dictionary, counts: Dictionary, fin: Dictionary, p: Dictionary) -> void:
	if int(fin.get("cen", 0)) > 0 and peasants.size() < Data.AI_MAX_PEASANTS and res.food >= 100:
		for b in game.buildings_of(player):
			if b.sid == "cen" and b.finished and b.queue.size() < 3:
				game.train_unit(player, b, "peasant")
				break
	var priests := 0
	var drums := 0
	var offs := 0
	for u in military:
		if str(u.sid) in ["priest", "pope", "padre", "mullah"]:
			priests += 1
		elif str(u.sid) in ["drummer", "drummer18"]:
			drums += 1
		elif str(u.sid) in ["officer", "officer18"]:
			offs += 1
	var force := 0.0
	var cls := {"melee": 0, "ranged": 0, "cavalry": 0, "artillery": 0}
	for m in military:
		force += float(m.def.aiforce)
		cls[game._kind_class(m)] = int(cls.get(game._kind_class(m), 0)) + 1
	for b in game.buildings_of(player):
		if not b.finished or not b.def.has("trains") or b.queue.size() >= 6:
			continue
		if b.sid == "bar" or b.sid == "bar18" or b.sid == "sta" or b.sid == "dip" or b.sid == "art":
			# support first
			if b.sid == "bar" and int(fin.get("aca", 0)) > 0:
				if drums < 1 + int(fin.get("bar", 0)) / 2 and game.train_unit(player, b, "drummer"):
					continue
				if offs < 1 + int(fin.get("bar", 0)) / 2 and game.train_unit(player, b, "officer"):
					continue
				if priests < 1 and game.train_unit(player, b, "priest"):
					continue
			if force >= float(Data.AI_ATTACK_FORCE) * 2.0:
				continue
			var want := "melee"
			if cls["ranged"] < cls["melee"]:
				want = "ranged"
			elif cls["cavalry"] < cls["melee"] / 2:
				want = "cavalry"
			elif cls["artillery"] < 3 and b.sid == "art":
				want = "artillery"
			var pick := ""
			for o in b.def.trains:
				var rs: String = Data.resolve_sid(str(Data.PLAYER_NATIONS[player]), str(o))
				if not Data.UNITS.has(rs):
					continue
				if game._kind_class({"def": Data.UNITS[rs], "kind": "unit"}) == want:
					pick = rs
					break
			if pick == "":
				continue
			if game.train_unit(player, b, pick):
				force += float(Data.UNITS[pick].aiforce)

func _form_squads(military: Array) -> void:
	if int(game.buildings_of(player).size()) == 0:
		return
	for u in military:
		if str(u.sid) in ["officer", "officer18"] and game.squad_of_unit(u.id).is_empty():
			game.cmd_form_size(u, 72 if military.size() > 90 else 36)

func _repair(peasants: Array, blds: Array) -> void:
	for b in blds:
		if b.finished and b.hp < b.max_hp * 0.7 and b.player == player:
			var sent := 0
			for pe in peasants:
				if sent >= 2:
					break
				if pe.order.type == "none" and pe.inside_of == 0:
					game.cmd_repair(pe, b)
					sent += 1

func _defense(military: Array, home: Dictionary) -> bool:
	var threat := game.enemies_in_radius(home.pos, player, 45.0, false)
	if threat.is_empty():
		return false
	for m in military:
		if m.order.type == "none" or m.order.type == "attackmove" or m.order.type == "attackground":
			if game._kind_class(m) == "ranged" and threat.pos.distance_to(home.pos) <= 25.0:
				game.cmd_stand_ground(m)
			elif game._kind_class(m) == "artillery":
				game.cmd_attack_ground(m, threat.pos)
			else:
				game.cmd_attack(m, threat)
	return true

# --- cavalry raids on enemy economy (video 1) ---
func _raids(military: Array, res: Dictionary) -> void:
	var cav: Array = []
	for m in military:
		if game._kind_class(m) == "cavalry" and m.order.type == "none":
			cav.append(m)
	if cav.size() < 6:
		return
	if raid_ids.is_empty():
		for i in range(0, mini(cav.size(), 12)):
			raid_ids.append(cav[i].id)
	var target: Dictionary = {}
	var bd := 1e9
	for n in game.res_nodes:
		if n.type == "food" and n.hits > 0:
			for e in game.entities:
				if not e.dead and e.player != player and e.kind == "unit" and str(e.sid) == "peasant" and e.pos.distance_to(n.pos) < 8.0:
					var d: float = n.pos.distance_to(game.players[player].get("home_pos", Vector2.ZERO))
					if d < bd:
						bd = d
						target = e
					break
	if target.is_empty():
		raid_ids.clear()
		return
	for id in raid_ids:
		var u: Dictionary = game.by_id.get(id, {})
		if u.is_empty() or u.dead:
			continue
		if u.order.type == "none" or u.order.type == "attack":
			game.cmd_attack(u, target)

# --- waves: combined arms, retreat when broken ---
func _waves(military: Array, home: Dictionary, p: Dictionary) -> void:
	var force := 0.0
	var routing := 0
	for m in military:
		force += float(m.def.aiforce)
		if bool(m.get("routing", false)):
			routing += 1
	if routing > maxi(3, military.size() / 4):
		retreat_t = 20.0
	if retreat_t > 0.0:
		retreat_t -= Data.AI_THINK_INTERVAL
		for m in military:
			if m.order.type == "attack" or m.order.type == "attackmove":
				game.cmd_move(m, home.pos + Vector2(0, 6))
		return
	if force < float(Data.AI_ATTACK_FORCE) and not (game.battle_mode and military.size() >= 6):
		return
	var enemy_home: Dictionary = {}
	var bd := 1e9
	for b in game.buildings_of(1 - player):
		var d: float = b.pos.distance_to(home.pos)
		if d < bd:
			bd = d
			enemy_home = b
	if enemy_home.is_empty():
		return
	wave += 1
	for m in military:
		if m.order.type != "none" and m.order.type != "attackmove":
			continue
		var sq := game.squad_of_unit(m.id)
		if not sq.is_empty():
			var off: Dictionary = game.by_id.get(int(sq.officer), {})
			if not off.is_empty() and not off.dead and off.order.type == "none":
				game.cmd_attack_move(off, enemy_home.pos)
			continue
		var kc := game._kind_class(m)
		if kc == "artillery":
			game.cmd_attack_ground(m, enemy_home.pos)
		elif kc == "ranged":
			game.cmd_attack_move(m, enemy_home.pos + (home.pos - enemy_home.pos).normalized() * 14.0)
		elif kc == "cavalry":
			game.cmd_attack_move(m, enemy_home.pos + Vector2(10, -10))
		else:
			game.cmd_attack_move(m, enemy_home.pos)
```

Config: `config.gd` DEFAULT ai add `"difficulty": "normal",`; apply sets
`Data.AI_DIFFICULTY`; data.gd add `static var AI_DIFFICULTY := "normal"`.
In `game.gd _tick_upkeep` or `tick`: AI income cheat per difficulty (original
AI bonuses are estimated): at top of `tick`, every 1 s (`ai_cheat_t`), if
`Data.AI_DIFFICULTY == "hard"`: `players[1].res[i] += 2.0 * dt`-style trickle
(food/wood/stone +1.5/s, gold/iron/coal +0.8/s); easy: AI think interval ×1.6
and `AI_ATTACK_FORCE` ×0.7 applied where read (ai.gd reads Data values; simplest:
in config apply, scale `Data.AI_ATTACK_FORCE`/`AI_THINK_INTERVAL` by difficulty).
Document as estimated. Menu difficulty selector in G12.

ACCEPTANCE G11: `--cli 120` boosted: both sides reach >120 units, >10 buildings,
squads > 0, no errors; natural `--cli 600` shows compounding growth; selftest
green (selftest does not use AI except cli).

## G12 — Shell: save/load, Esc menu, options, end-game stats, campaign list, --seed

### G12.1 Save/load (`game.gd` ADD):

```gdscript
func serialize() -> Dictionary:
	var ents: Array = []
	for e in entities:
		if e.dead:
			continue
		var d: Dictionary = {}
		for k in e:
			if k in ["def", "order", "queue"]:
				continue
			d[k] = e[k]
		d["order"] = e.order.duplicate(true)
		d["queue"] = e.queue.duplicate(true)
		ents.append(d)
	var nodes: Array = []
	for n in res_nodes:
		nodes.append(n.duplicate())
	return {
		"version": 3, "time_s": time_s, "winner": winner, "next_id": next_id,
		"next_squad": next_squad, "battle_mode": battle_mode,
		"terrain": Marshalls.raw_to_base64(terrain), "blocked": Marshalls.raw_to_base64(blocked),
		"map_w": MAP_W, "map_h": MAP_H,
		"entities": ents, "res_nodes": nodes, "players": players.duplicate(true),
		"squads": squads.duplicate(true), "deposits": deposits.duplicate(),
		"stats": stats.duplicate(true), "objectives": objectives.duplicate(true),
	}

func deserialize(d: Dictionary) -> bool:
	if int(d.get("version", 0)) != 3:
		return false
	MAP_W = int(d.map_w); MAP_H = int(d.map_h)
	terrain = Marshalls.base64_to_raw(str(d.terrain))
	blocked = Marshalls.base64_to_raw(str(d.blocked))
	time_s = float(d.time_s); winner = int(d.winner)
	next_id = int(d.next_id); next_squad = int(d.next_squad)
	battle_mode = bool(d.battle_mode)
	entities.clear(); by_id.clear()
	for ed in d.entities:
		var e: Dictionary = ed.duplicate(true)
		var sid: String = str(e.sid)
		e["def"] = Data.UNITS[sid] if e.kind == "unit" else Data.BUILDINGS[sid]
		entities.append(e)
		by_id[int(e.id)] = e
	res_nodes = d.res_nodes.duplicate(true)
	for n in res_nodes:
		by_id[int(n.id)] = n
	players = d.players.duplicate(true)
	squads = d.squads.duplicate(true)
	deposits = d.deposits.duplicate()
	stats = d.stats.duplicate(true)
	objectives = d.objectives.duplicate(true)
	gates.clear()
	for e in entities:
		if e.kind == "building" and str(e.sid) == "gat":
			gates.append(e)
	_grid_rebuild()
	return true
```

NOTE: `players[].entities` id lists survive; `e.def` re-linked; floats in
order/queue survive JSON. Corpses/rubble/projectiles are dropped on load
(cosmetic, acceptable — document). Fog rebuilds from entities next update.

### G12.2 `main.gd`: quicksave/quickload + Esc menu + end screen.
- vars: `var menu_overlay: CanvasLayer = null`, `var end_panel: PanelContainer = null`.
- In `_process` key handling is in input_controller; add there in `_handle_key`
  TOP: `if k.keycode == KEY_F5: game_save(); return` / `KEY_F9: game_load(); return`
  where those are main methods reached via group: add main to group "c3_main"
  in `_ready`; input calls `get_tree().get_first_node_in_group("c3_main").game_save()`.
- main ADD:

```gdscript
func game_save() -> void:
	if game == null:
		return
	var f := FileAccess.open("user://quicksave.json", FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(game.serialize()))
		f.close()
		if hud:
			hud.show_hint("Game saved (F9 loads)")

func game_load() -> void:
	if not FileAccess.file_exists("user://quicksave.json"):
		return
	var d = JSON.parse_string(FileAccess.get_file_as_string("user://quicksave.json"))
	if d is Dictionary and game.deserialize(d):
		world.fog_explored.fill(0)
		world.fog_vis.fill(0)
		world._update_fog()
		if hud:
			hud.refresh_selection([])
			hud.show_hint("Game loaded")
```

- Esc menu: in input_controller `_handle_key` ESC branch (L266–270): if a ghost
  or build menu is open keep current cancel behaviour; ELSE call
  `main.toggle_menu_overlay()`. main ADD `toggle_menu_overlay()` building a
  CanvasLayer with buttons: Resume, Save (F5), Load (F9), Options, Quit to menu,
  Restart. Quit to menu = existing `menu_cb`; Restart = `get_tree().reload_current_scene()`
  after re-applying pending_cfg (store last cfg in main var `last_cfg` set in
  `_on_menu_chosen` and `_setup_full_game`).
- Options panel (same overlay, second page): HSlider master volume
  (0..+6 dB → `Data.MASTER_VOLUME_DB`), HSlider ambient, OptionButton quality
  (high/medium/low → sets Data.QUALITY/SPRITE_CELL/TERRAIN_PX/FX_CAP live; note
  terrain chunks must be cleared: `world.terrain_chunks.clear()` after freeing
  sprites + `world.terrain_order.clear()`), CheckButton fog
  (`Data.FOG_OF_WAR`, `world.fog_sprite.visible`), CheckButton peasant capture
  (`Data.CAPTURE_ENABLED`), OptionButton difficulty (sets Data.AI_* scales),
  Button "Back". Persist choices to `user://options.json` and merge in
  `config.gd load_all` as a third layer (after res config, before --config).
- End screen: `_on_game_over` (L361–363) additionally builds `end_panel`
  (centered PanelContainer) with title Victory/Defeat, stats lines from
  `game.stats` (shots, hits, kills, gathered per resource) + per-player unit/
  building counts + time, buttons: Restart, Quit to menu, Save replay info
  (writes `user://lastgame.json` = serialize()). Sim already freezes.
- `--seed` fix: in `_parse_args` L343–345 store `seed_arg = int(value)`; in
  `_ready` AFTER `cfg.apply()` add: `if seed_arg >= 0: Data.RANDOM_SEED = seed_arg`
  — FIRST grep config.gd apply for `random_seed` to learn the exact Data field
  name (it may be `Data.SEED`); use that name. Verify `game.setup()` reads it
  (grep `rng.seed` in game.gd) — if setup seeds from a different field, set that
  one too. Acceptance: two `--screenshot --seed 7` runs produce identical maps.
- Menu (`menu.gd`): add buttons Quit (calls `get_tree().quit()`), Options
  (reuse main overlay? menu has no main overlay — implement a simple inline
  options page in menu with the same widgets writing user://options.json),
  Load game (lists `user://quicksave.json` + `user://save_*.json` if present →
  emits chosen with `load_save: path`; main `_on_menu_chosen` after setup calls
  `game.deserialize(JSON.parse_string(FileAccess.get_file_as_string(path)))`).
  Add difficulty OptionButton (easy/normal/hard) and map size OptionButton
  (240/320/400 tiles) and seed SpinBox to the skirmish page; pass through
  `chosen` dict → main writes Data fields before `_setup_full_game`.
  Campaigns: replace `_show_campaigns` first-mission-only with a mission LIST
  (buttons per mission from missions.json) + progress gate: store
  `user://campaign_progress.json` `{mission_id: true}` on victory
  (`_on_game_over` when mode campaign and winner 0 → mark current mission done,
  unlock next); locked missions disabled with tooltip.

ACCEPTANCE G12: selftest/uitest green; manual: F5 then F9 restores armies and
resources; Esc opens overlay; quit-to-menu works; end screen shows after
`--cli`-style victory in a windowed boosted run; `--seed 7` reproducible.

## G13 — Journey recordings that show the game (camera follow + battle zoom)

`main.gd`: vars `var journey_cam_t := 0.0`. In `_process` after `world.sync(dt)`
add:

```gdscript
	if journey_mode and camera != null and game != null:
		journey_cam_t -= dt
		if journey_cam_t <= 0.0:
			journey_cam_t = 1.0
			var focus := Vector2.ZERO
			var n := 0
			var fighting := false
			for e in game.live_units:
				if e.player != 0:
					continue
				if str(e.sid) == "peasant":
					continue
				focus += e.pos
				n += 1
				if e.order.type == "attack":
					fighting = true
			if n == 0:
				for b in game.buildings_of(0):
					focus = b.pos
					n = 1
					break
			if n > 0:
				var target: Vector2 = (focus / float(n)) * world.view_scale
				camera.position = camera.position.lerp(target, 0.35)
				var want_zoom: float = 0.75 if fighting else 1.0
				camera.zoom = camera.zoom.lerp(Vector2(want_zoom, want_zoom), 0.2)
```

(`journey_mode` var already exists per flag parse; verify name by grep
`journey`.) Also make `--seq` headless CLI frames use the same focus logic in
`_render_headless_image` centering (grep its camera/center assumption: it
renders the whole map letterboxed — leave as is, it is a timelapse).
Re-record: `godot --path app -- --seq app/shots/j3 --seq-seconds 240 --seq-step 2 --speed 4 --config shots/boost.json --journey --timeout 400`
then `python app/tools/seq_to_mp4.py --dir app/shots/j3 --fps 10`.
ACCEPTANCE: contact.png shows armies, volleys, buildings — not empty fog;
mp4 plays (ffprobe).

## G14 — Audio: pooled voices with cooldowns, distance cull, looping music

`audio.gd`: pool 8 → 16 (L22–31 loop count). Add `var last_play: Dictionary = {}`
and in `play()` TOP:

```gdscript
	var key: String = str(prefixes[0]) if prefixes.size() > 0 else ""
	var now := Time.get_ticks_msec() / 1000.0
	if now - float(last_play.get(key, -10.0)) < 0.09:
		return
	last_play[key] = now
```

Add optional position param `play(prefixes, vol_db, at := Vector2.INF)`: if
`at != Vector2.INF` and camera exists and `at.distance_to(camera.global_position / world_scale) > 60.0` → return (distance cull); volume attenuate
`vol_db -= clampf((d - 20.0) * 0.15, 0.0, 12.0)`. main.gd `_consume_events`
passes `ev.pos` for shot/hit/explode/death/chop (grep the play calls; add arg).
Preload: in `_ready` after file scan, `for f in files: _stream(f)` warm cache
(305 loads at bind ≈ 0.5 s, removes mid-battle hitches).
Music loop: connect both music players' `finished` → replay (`player.play()`),
guard with a `music_on` flag set by start_music/stop_all.
HUD click player: reuse pool? keep (single, fine).

ACCEPTANCE: cli unaffected (headless skips audio); windowed boosted battle:
volleys audible without machine-gun cutout; no hitch at first shot.

## G15 — Tests for everything new + perf gate

### G15.1 `selftest.gd`: append steps (follow existing step pattern):
- `garrison`: spawn tow finished + 3 serdiuks; cmd_enter each; assert
  `hidden == true` and `tow.garrison == 3`; cmd_unload; assert hidden false.
- `peasant_capture`: spawn enemy peasant + own pikeman adjacent; cmd_attack;
  sim 3 s; assert peasant.player == 0 (CAPTURE_ENABLED true).
- `resow`: deplete a food node (`n.hits = 0`); cmd_resow peasant; sim 30 s;
  assert hits > 0.
- `attack_ground`: spawn cannon; cmd_attack_ground at empty spot; sim 5 s;
  assert stats.shots increased.
- `save_load`: serialize → deserialize into a FRESH C3Game; assert entity
  count, players[0].res, time_s equal.
- `grid_equiv`: with 50 random entities, compare old brute-force
  enemies_in_radius result vs new for 10 random points (implement brute force
  inline in the test).
- `farm_cap`: build hou, kill it via cmd_delete; assert farm_cap returned to
  base (catches G9.1/2).
Update `app/selftest.json` expectations count if the runner asserts step count
(grep `steps.size()` in selftest/main; it reports, not asserts — verify).

### G15.2 `uitest.gd`: add scenes `cursor_ctx` (select peasants, call
`ictl._update_cursor()` with mouse over a res node via synthesized position —
if mouse position cannot be synthesized, call `_set_cursor` path checks by
asserting `cursor_tex.size() >= 11` and that `_update_cursor()` runs without
error), `groups` (Ctrl+1 store, 1 recall), `minimap_frustum` (assert
`hud.minimap_rect` parent anchors bottom-left), `garrison_keys` (U unloads),
`hotkeys_live` (assert `Data.HOTKEYS.has("hold_fire")` and `has("engage")` —
catches the G5 config bug), `save_load_ui` (F5/F9 via main group).
Register names in `SCENES` (L32–34) and in `app/uitest.json` if it lists scenes.

### G15.3 Perf gate: run G8.0 bench before/after; write `app/shots/perf.md`
table (baseline, after G8.1–8.4, after G8.5–8.6, final). Gate: headless
sim_ms_per_tick ≤ 8 ms @600 units; windowed fps ≥ 30 (record owner-machine
number; if the machine cannot reach 30 even at low quality, record that and
set default quality medium in config.json).

### G15.4 Final verification battery (all must pass):
```
godot --headless --path app --import
godot --headless --path app -- --self-test app/selftest.json
godot --headless --path app -- --ui-test app/uitest.json
godot --headless --path app -- --cli app/cli.json --cli-seconds 60
godot --headless --path app -- --config shots/boost.json --cli app/cli.json --cli-seconds 120
godot --headless --path app -- --bench --timeout 120
godot --path app -- --screenshot app/shots/g3_final.png --timeout 90
godot --path app -- --seq app/shots/j3 --seq-seconds 240 --seq-step 2 --speed 4 --config shots/boost.json --journey --timeout 400
python app/tools/seq_to_mp4.py --dir app/shots/j3 --fps 10
```
Visual checklist vs original (open g3_final.png + j3/contact.png):
visible animated peasants at correct scale; rings only on selection; context
cursors; minimap bottom-left with frustum; command card; crisp blended terrain;
fog hides enemies; nation buildings; stages/rubble; formations marching in
rotated lines; corpses lingering; smoke/volleys; HUD panels intact.

## G16 — Documentation pass

1. `app/MECHANICS.md`: new section "GUIDE 3 pass" listing every rule added with
   source (donor file / wiki / estimated): garrison 10 cap & heal 2/s (est),
   peasant capture rule, resow cost 20 food (est), corpse life 90 s (est),
   difficulty trickle (est), deposit split /3 (est), attack-ground dispersion
   reuse, formation facing.
2. `app/mechanics.json`: append matching `values` entries with `source` and
   `"estimated": true` where chosen.
3. `app/README.md`: controls table update (groups 1–9, double-click, shift-add,
   U unload, R bombard/rally context, Ctrl+M, Ctrl+`, Shift+Z, Alt+M, F5/F9,
   Esc menu), quality presets, save/load, cursors.
4. `app/CREDITS.md`: donor files newly used (cursors bmp/cur, hotkeys.cfg,
   doupdatecursor.inc, minimap.cfg).
5. `docs/COMMANDS.md`: add `--bench`, quality config keys, options.json layer.
6. `GUIDE1.md`/`GUIDE2.md` headers: note GUIDE3 status.
7. Fill the STATUS section below.

---

## Appendix A — donor hotkeys.cfg (verbatim key→action, for fidelity checks)

Build: C cen, H hou, L bla, B bar, E aca, S sta, R art, D dip, K ba2, J tem,
I mil, O sto, M mar, N gol/iro/coa (cycle), P por, T tow, (empty) wwa/swa.
Units: A attack, S standground, C nostandground, F squad fill, (empty) disband,
G guard/cancelguard, E enableattack, D disableattack, R attackpoint,
J squad rank, K column, L square, Ctrl+S stop, U unloadall.
Interface: Alt+M minimap, Q viewcollision, Ctrl+Alt+A military, Ctrl+A allunits,
Ctrl+Q ships, Ctrl+B buildings, Ctrl+P (alt `) idlepeasants, Ctrl+` allpeasants,
Ctrl+M idlemines, Z sametype, Shift+Z add sametype, Ctrl+Shift+Z add all
sametype, Ctrl+Z all sametype.
Port deviations kept deliberately (documented): Q=patrol (donor Q=collision
debug), Shift+F disband (donor empty), 2/3 aliases for bar18/dip, V engage
(donor has no engage key; C nostandground covers it), Ctrl+S stop kept.

## Appendix B — donor cursor rules (doupdatecursor.inc, summarized)

| condition (in priority order) | cursor |
|---|---|
| placing building ghost | crConstruct |
| attack-move mode | crAttack |
| rally mode | crSetRallyPoint (port: gotomine) |
| artillery attack-point mode | crArtillery |
| guard mode over friendly / else | crGuard / crNotGuard (port: default) |
| patrol mode | crPatrol |
| enemy capturable building + can attack | crCaptureAttack |
| enemy capturable building, no attack | crCapture |
| enemy attackable | crAttack |
| peasant over food/wood/stone res | crGainFood/Wood/Stone |
| peasant over own unfinished/damaged building | crConstruct |
| own enterable building (mine/garrison) | crGoInside (gotomine) |
| else | crDefault |

Port simplifications (documented): capture vs captureattack merged to
captureattack when CAPTURE_ENABLED; guard/patrol mode cursors shown via the
mode flags when G10/G4 add them (patrol mode flag exists only as instant order
— keep default cursor there, note it).

## Appendix C — donor asset map for this guide

- Cursors: `data/cursors/textures/bmp/*.bmp` (already copied to app/assets/ui),
  `data/cursors/textures/cur/*.cur` (8 edge arrows, optional G3.3).
- Cursor logic: `data/gui/menu.inc/doupdatecursor.inc`.
- Hotkeys: `data/game/var/hotkeys.cfg`.
- Minimap layout: `data/gui/minimap.cfg` (240×240, bottom-left, frustum on).
- HUD atlases (future skinning, NOT this guide): `data/hud/textures/ui/tex0*.bmp`,
  `icons.bmp` 1024×512, `iconsunits.bmp` 1024×384 (already in app/assets/ui).
- Formations: `data/game/var/formations.cfg`; walls: `wallcustom.cfg`.
- PFX/water textures for future fx polish: `data/pfx/textures/`,
  `data/water/textures/` (out of scope G3, note as stretch).

## Appendix D — troubleshooting for the executor

- Parse error → TABS/comma; restore `inbox/backup/<name>.gd.bak3`.
- `Required object "rp_texture" is null` → run `--import`.
- Units invisible after G1 → index.json lacks bbox (run sheet_metrics.py) or
  sheet dir mismatch (`_anim_dir()`); check `fig_h` values 0.3–0.95.
- Terrain black/missing after G7 → `terrain_hlv` empty because `_prep_variants`
  not called in bind before layers; or chunk sprite scale wrong (must be
  `TILE_M*view_scale/px`).
- Fog everything black after G6 → `fog_vis` never filled because
  `_update_fog` not called (bind calls it; sync timer uses Data.FOG_INTERVAL).
- selftest capture step fails after G9.3 → the test expected doubled farm;
  fix expectation to single transfer (correct behaviour), note in STATUS.
- D/E/V still dead after G5 → config.json hotkeys section still missing them
  AND merge not applied; check `--dump-config` output contains hold_fire.
- Bench fps low but sim fast → render-bound: set quality low, check
  compress/mode=2 imported, reduce window to 960×540 via config display.
- Blender PIL missing → GUIDE2 Appendix C pip command.
- NEVER EEVEE/GPU. NEVER godot without self-exiting flag. ONE heavy job at a time.

## Appendix E — execution order & budget

G1 → G2 → G3 → G4 → G5 → G6 → G7 → G8 (measure between sub-steps) → G9 → G10 →
G11 → G12 → G13 → G14 → G15 → G16.
If tokens run short: STOP after G8 (visible fidelity + speed are the user's top
complaints). G9–G10 are correctness, G11 AI, G12 shell, G13–G16 verification —
each independently shippable. Never leave selftest/uitest red between steps.
Rebakes (G8.6 tiers) run in background CPU-only while doing G9–G12.

## STATUS (filled by executor)

- [x] G1 sprite scale/anchor … done (sheet_metrics.py measured 209 sheets; _draw_anim/_draw_corpses bbox scale + facing on attack/gather/build; selftest 21/21)
- [x] G2 overlays … done (make_overlays.py shadow+rings; selection-only rings; soft shadows; trees/stone/outcrop shrunk; CORPSE_LIFE 90 + cap 600; selftest green)
- [x] G3 cursors … done (11 BMP cursor_tex + _set_cursor/_update_cursor donor priority; G3.3 cur arrows skipped, noted)
- [x] G4 HUD layout/groups … done (minimap 200px bottom-left + frustum + right-click orders + drag; cmd card + handlers; Ctrl+1..9 groups, double-click, Shift-add)
- [x] G5 hotkeys … done (config merge fix; DEFAULT + config.json + boost.json: attack_ground R, unload U, selects, minimap_toggle; rally R removed; stubs added then replaced in G10)
- [x] G6 fog … done (fog_vis/fog_counts incremental; tile_visible/tile_explored; enemies hidden on map/minimap; reveal_requests boxed)
- [x] G7 terrain … done (chunked 16px lazy 24-chunk LRU + soft type blending; _prep_variants; terrain_px/Data wiring; VRAM compress/mode=2 imported)
- [x] G8 perf (bench numbers: see app/shots/perf.md; headless sim_ms_per_tick measured via --bench) … done (grid+lists+compact; grid queries; TARGET_TABLE/_hash2/artillery hoist/reverse filter loops; 8Hz acq; dirty flags; quality presets + _anim_dir tiers)
- [x] G9 sim fixes … done (farm on destruction; delete relies on _kill; capture single farm no refill + rally erase; per-node deposits; splash per-victim; post-research HP; gate player-only; famine throttle; stuck give-up; patrol a/b preserved; proj cap 512; symmetric probes; capture timer)
- [x] G10 mechanics … done (garrison enter/unload kill-with-building heal+2 tower bonus capture resist hidden skip + HUD Unload; peasant capture; resow 20 food; shift-cancel refund; attack-ground + fake-player projectile path; formation facing rotation)
- [x] G11 AI … done (ai.gd quota economy/expansion/serialized construction + builder budget + mine surplus rotation/repair/raids/retreat/waves replaced; difficulty + easy/hard scaling + hard trickle; attack_force 120 in config+boost; mine-wait 60s timeout)
- [x] G12 shell/save/options … done (serialize/deserialize v3 + Vector2 codec; F5/F9; Esc overlay; options panel + user://options.json layer; end screen + campaign progress; --seed; menu Quit/Options/Load/difficulty/size/seed + mission list)
- [x] G13 journey camera … done (follow non-peasant centroid + battle zoom 0.75/1.0)
- [x] G14 audio … done (16 voices + 90ms per-key cooldown + 60m cull/attenuation + preload + music loop)
- [x] G15 tests (selftest 28/28, uitest 17/17) … done (garrison/capture/resow/attack_ground/save_load/grid_equiv/farm_cap; cursor/groups/frustum/garrison/hotkeys/save_load scenes; bench 196ms/tick + perf.md; battery: import clean, cli60 clean, boosted cli clean through 600s, g3_final.png headless render, j3 27 frames + journey.mp4 + contact.png headless timelapse)
- [x] G16 docs … done (MECHANICS + mechanics.json est entries + README controls + CREDITS donor files + COMMANDS bench/options + GUIDE1/2 headers + STATUS)
- [x] UI-scale hardening … done (menu card bounded + scrolling body, CossacksGodot rename, FPS 3-digit corner readout, top bar centered, build HFlow-wrapped, command card fixed 3-col grid auto-hiding when empty; minimap overlap root-caused: TextureRect minimum follows the 160-320px map texture, not custom_minimum_size — fixed with EXPAND_IGNORE_SIZE + explicit panel bounds, selection panel starts at minimap right edge + gap by construction; full menu-driven bridge run verified at 1280x720 with zero overlaps/clips, selftest 28/28 + uitest 17/17 green)
- [x] Original-fidelity rendering pass … done (vs Cossacks 3 footage: `_draw_sprite` native-blit bug fixed → `draw_texture_rect` scaled by footprint; trees/rocks/mines rescaled with shadows; broken black `field.png` bake bypassed with procedural golden wheat; grass pool grass1-only → 13-source mix incl. dirt-flecked `ground*`; original per-building dirt decals wired with ellipse fallback; per-tile sun gain + meadow mottling; unit art verified faithful; selftest 28/28 + uitest 17/17 green, FPS 60 after chunk storm)
Executor notes / deviations (required for any deviation from the letter):
- G2.5/G7.3/G8.6 config+data vars applied together (TERRAIN_PX/QUALITY/SPRITE_CELL/FX_CAP/FOG_INTERVAL/MINIMAP_INTERVAL + CORPSE_LIFE).
- G9.2: removed cmd_delete's own farm line instead of flipping sign, because G9.1 makes _kill subtract; keeping both would double-subtract. Final: delete relies on _kill (finished-only).
- G9.1/G9.3: farm subtract guarded by finished (unfinished buildings never granted farm).
- G9.10: attack order stores patrol a/b on acquire so resume restores the route (guide's fabricated ±4m replaced with stored legs).
- G9/G10 robustness: stuck gatherers remember bad_node/bad_t (120s) and carriers remember bad_store/bad_t; nearest_res/nearest_drop skip them; loaded carriers hold their load when no store is reachable instead of deleting it.
- G9.12: applied guide's probe formula verbatim (starts at ±30°, skips 15°; noted).
- G10.4: Data.refund(res, cost, percent) — call passes (players[0].res, price, 1.0).
- G12 serialize: added Vector2 encode/decode (JSON turns Vector2 into String); squads/stats/objectives have no vectors.
- G14: music loop via named replay funcs (lambdas with if-statement rejected by parser); _play at-param uses fixed 16.0 px/m.
- G8.0 bench: measures 30 SIM seconds (not wall) + wall fps; headless run recorded in perf.md. Headless bench is sim-only (world.sync skipped, minimap/fog intervals pinned) since render can't be measured without a display.
- UI responsiveness pass (2026-11-19): menu card is viewport-bounded (max 94% w, content-aware scroll height) inside a full-rect CenterContainer so it can never clip at any window size; HUD command/build bars use HFlowContainer (buttons wrap instead of spilling past the card) with content-fitted panel heights (150/250/170 × us) and a proportional 17–61% width band; Esc/end overlays use bounded centered cards; FPS readout is a bare 3-digit number top-right.
- Post-G3 windowed fixes (2026-11-19): px-vs-meters mix-up in terrain chunk window (black map), minimap frustum (invisible rect), double-click select (always empty) — all converted properly; chunk bake amortized to 2/frame + masks hoisted; minimap caches terrain base + skips fog-dim when fog off; FPS/ms/units readout added to top bar; quality switch rebuilds masks and clears sprite cache.
- G11 deviations: place_building gained optional send=false (AI places without auto-send; _resume distributes a capped builder budget instead — fixes pile-on where all builders went to the newest site); unfinished-site gate (max 3 concurrent) serializes construction; attack_force 260→120 in config.json+boost.json (legacy 260 stalls waves; DEFAULT remains 60); mine-wait 60s timeout in _tick_gather; walls 12→6 @ 20–30m (less self-enclosure).
- G3.3 edge cursors skipped (no .cur files verified); G8.6 sprite rebakes (anim96/anim64) not run (CPU budget); VRAM compress applied + imported.
