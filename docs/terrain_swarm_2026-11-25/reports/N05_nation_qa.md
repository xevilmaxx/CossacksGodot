---
id: N05
ticket: "Decisive QA atom proposal for nation-specific initial hall + peasants (full GDScript in report only)"
swarm: TERRAIN-SWARM-WAVE-G / WAVE N
owner: N05 subagent (analysis / read-only)
created: 2026-11-25
status: PROPOSAL ONLY — NO ATOM FILE CREATED, NO GODOT RUN, NO RUNNER JOB, NO PNG, NO RESULT JSON
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROX]
outputs: [docs/terrain_swarm_2026-11-25/reports/N05_nation_qa.md]
parity_guard: "DONOR PARITY UNVERIFIED — the atom proves INTERNAL mesh/sid-to-nation associations (which donor-derived stem is bound and whether a real converted mesh exists on disk). It never compares pixels against a donor GPU frame; no donor A/B frame exists under CHARTER §3. All nation mesh labels are PORT APPROX / visual UNVERIFIED."
scope: "Exactly one file written: this report. The complete GDScript in §4 is a hand-off proposal for a later implementation owner — DO NOT create the .gd file from this ticket. No game code, config, fixture, manifest, asset, gate, result JSON or PNG was created or edited; no backup needed. No Godot process and no runner job were started (WAVE_G_CHARTER.md:31 — only G04 submits runner jobs)."
---

# N05 — decisive QA atom: Russian initial hall + nation-distinct peasants

## 0. Boundary, authority and label key

- **Read before work (all read in full):** `docs/terrain_swarm_2026-11-25/CHARTER.md`,
  `docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md` (Wave N rows, lines 157-169),
  and the atom-pattern precedents `G01_select_capture_atom.md`,
  `G02_ghost_atom.md`, `M04_mill_qa.md` §4/§7/§8 and `F2_05_qa.md` §2/§3.
- **One file written:** this report. I did **not** create
  `variant3d/tests/t_nation_assoc_capture.gd`; the full script in §4 is a
  proposal for a later owner. No shared file was touched (disjoint ownership),
  so no backup was required.
- **No Godot was launched and no runner job was submitted.** Parse, runtime and
  visual behaviour of the atom below are **UNVERIFIED (NOT RUN)**, never a PASS.
- Labels: **observed** = read directly from a cited file/line this session;
  **derived** = arithmetic/control-flow consequence of observed code;
  **inferred** = reasoned but not directly observed; **UNVERIFIED** = cannot be
  established without a real windowed run (above all, donor parity).
- **Donor parity stays UNVERIFIED.** The atom reports *which* donor-derived mesh
  stem is bound to a nation and *whether the file exists on disk*; it does not
  assert the rendered hall or peasant looks like the donor. Every status string
  it reads (`NATION_MESH_EXACT_STATUS`, etc.) is a **PORT APPROX** label with
  `visual UNVERIFIED` embedded (`world3d_entities.gd:203-213`).
- Sibling Wave-N reports N01-N04 had **not landed** when this was authored
  (glob returned no files). All ground truth below is therefore derived
  directly from source, with file:line cites, rather than from those reports.

---

## 1. Source ground truth (OBSERVED — direct reads this session)

| Fact | Evidence | Label |
|---|---|---|
| Russia is the default player-0 nation. `config.json` has no `player_nations` array, so the legacy `nation0`/`nation1` keys seed the roster. | `variant3d/config.json:105-108` (`"nation0": "rus"`, `"nation1": "bav"`); `config.gd:540-559` (`n0 := text("gameplay.nation0","rus")`; `PLAYER_NATIONS=[n0,n1]` when `player_nations` absent); `data.gd:207-208` (`PLAYER_NAMES=["Russia",...]`, `PLAYER_NATIONS=["rus","bav",...]`) | observed |
| The 64² fixture overlays only gameplay map size; it does **not** override nations, so the Russia default survives the atom's boot. | `tests/fixtures/small_map_64.json:1-16`; `config.gd:229-243` (merge order) | observed + derived |
| `game._spawn_starts()` spawns the initial town hall as `spawn("cen", i, c)` for every player, then `Data.START_PEASANTS` starting peasants as `spawn("peasant", i, pos)`. | `game.gd:2942-2962`; called from `game.setup_spawns()` (`game.gd:469-479`) at real boot (`main.gd:581`) | observed |
| Nation identity for a presentation entity is resolved read-only in this order: explicit `ed["nation"]`, then `game.players[player]["nation"]`, then `Data.PLAYER_NATIONS[player]`. The sim entity dict itself has no nation key. | `world3d_entities.gd:658-683` (`_nation_of`), `:649-655` (`_player_index`); `game.gd:428-444` | observed |
| Building mesh sid = `_donor_building_prefix(nation, base_sid) + base_sid`. For family `cen` (in `OWN_FAMILIES`) the prefix is the nation itself ⇒ Russian hall candidate = **`ruscen`**. The stem is probed on disk; a miss silently falls back to the base sid `cen`. | `world3d_entities.gd:695-726` (`_donor_building_prefix`), `:746-800` (`_entity_mesh_sid`), `:776-777`, `:780-789` | observed + derived |
| Mesh path is deterministic: `res://assets/models/obj/<sid>.obj` or `res://assets/models/glb/<sid>.glb`; `_mesh_info()` records `info["sid"]`, `info["source"]`. A miss yields `donor_bbox_proxy` (not real art). | `world3d_entities.gd:84-85, 1110-1160` (`:1134-1155`) | observed |
| There are **no** rus-keyed meshes/textures on disk. Port telemetry states it verbatim: 0/172 OBJs carry a nation key; manifest maps generic `peasant → peaukr`, and `cen/hou/bar/sta/bla/aca/art/dip → ukr*`; 0 rus-keyed and 0 bav-keyed textures. | `world3d_entities.gd:206, 213` (`NATION_MESH_FALLBACK_STATUS`, `NATION_MESH_BLOCKED_EVIDENCE`); `manifest.json:5-11` (`peasant`→`peaukr.oss/.dds`), `:1050-1053` (`cen`→`ukrcen.osm/.dds`); `glob variant3d/assets/models/obj/**/*rus*` → none | observed |
| Therefore, on the **current** tree, both the Russian initial hall and every nation's peasant resolve to their *base* sids (`cen`, `peasant`) with `exact=false` and the UKRAINIAN-derived base mesh — precisely the owner's complaint. | derived from the three rows above | derived |
| The live presentation exposes everything the atom needs: building `MeshInstance3D` named `Building_<sid>_<id>_STATIC_POSE` with metas `mesh_source`, `nation`, `nation_mesh_exact`, `nation_mesh_label`; units as MultiMesh batches named `Batch_unit_<sid>_p<player>_…` with the same metas; `_slot[id]` gives `{key,index,class}`; `_nodes[id]` gives the building node; `stats["nation_mesh_usage"]` records `family|nation|base->resolved` counts. | `world3d_entities.gd:1612-1639, 1645-1668, 1401-1438, 303-308, 803-808, 474-478` | observed |
| Unit nation identity is **the sid**, not a skin swap: `Data.resolve_sid(nat, sid)` maps a generic train sid via `NATION_UNITS`; `peasant` has no entry, so it currently maps to itself for every nation. | `data.gd:294-306, 1564-1568`; `world3d_entities.gd:761-775` | observed + derived |
| Windowed capture seam: `--screenshot` skips the menu and creates `main.capture_view3d` (1280×720 `Screenshot3DViewport`); root backbuffer readback is blank under gl_compatibility; main's own saver calls `_quit(0)` after saving. | `main.gd:233-248, 1235-1253, 1849-1930`; G01 §2 Trap B, G02 §3 | observed (precedent) |
| Donor key colours are keyed by **player slot index, NOT nation** — this is the donor convention the fix must NOT copy when associating objects to nations. | `variant3d/data/donor_key_colors.json:36-41` (`"keyed_by": "player slot index, NOT nation"` + evidence); `world3d_entities.gd:473` | observed |

**DERIVED expected values (not invented donor constants):**

```
want_hall_sid = _donor_building_prefix("rus", "cen") + "cen" = "ruscen"
want_hall_obj = "res://assets/models/obj/ruscen.obj"     (or .glb)
hall_base_sid = "cen"       # game.gd:2950 — the sid actually spawned at boot
peasant_base = "peasant"    # game.gd:2961
```

The atom **computes** `want_hall_sid` at runtime through the live
`_ents.call("_donor_building_prefix", "rus", "cen")` and additionally asserts the
literal `"ruscen"`; no hard-coded donor asset name is invented beyond the
donor's own 3-letter prefix + sid rule. It deliberately does **not** hard-code
nation peasant sid strings (`pearus`, `peabav`, …): those do not exist on disk
yet, and naming them would be an invented donor claim. It instead requires the
live binding to be *nation-coded, distinct, exact and file-backed* — the
observable meaning of "peasants are of different form".

---

## 2. What the atom must decide (decomposition of the ticket)

| # | Ticket requirement | Decisive mechanism |
|---|---|---|
| 1 | Boot a real 64² 3D game with Russia as default | Load `res://scenes/main.tscn` windowed, assert `render_mode=="3d"`, `MAP_W==MAP_H==64`, real `game`/`world`/`entities`/`camera`/`capture_view3d`; assert `Data.PLAYER_NATIONS[0]=="rus"` and `game.players[0].nation=="rus"` (G02 `boot_real_64_3d_game`) |
| 2 | Initial Town Hall mesh path/sid is the Russian one | Use the **boot-spawned** `cen` entity of player 0 (do not re-spawn), read its live `Building_<sid>_<id>_STATIC_POSE` name/metas, require sid `ruscen`, `nation=="rus"`, `nation_mesh_exact==true`, real on-disk `ruscen.obj/.glb`, `mesh_source != donor_bbox_proxy` |
| 3 | One peasant per several nations, distinct mesh/sid associations | Spawn 5 `peasant` entities (rus, bav, ukr, tur, pol) with an explicit `nation` field, **all as player 0**, drive the real `world.sync(DT)` → `add_unit` path, read each entity's live `_slot[id].key` sid and `multimesh.mesh` identity; require all 5 sids distinct, none equal to base `peasant`, all exact and file-backed, all mesh resources distinct |
| 4 | Don't-copy-donor-bug guard | Same player slot for all 5 peasants (donor key colour is slot-keyed, not nation-keyed). If a "fix" keys meshes by slot/colour, all five collapse to one sid and the distinctness check goes RED |
| 5 | Windowed PNG showing them | Fixed camera framing the initial hall + the five peasants; one real `capture_view3d` GPU PNG, 1280×720, non-blank; all six entities asserted inside the viewport and their projected coordinates recorded for G05 |
| 6 | Exact runner command with unique id | §7: `n05-nation-qa-cap1`, no `--headless` |
| 7 | headless → SKIP_CAPTURE / passed=false | `_initialize()` first branch, mirroring G02 §4 / M04 §6 / F2-05: literal `SKIP_CAPTURE …`, `verdict=SKIPPED_HEADLESS`, `passed=false`, no PNG, exit 1 |
| 8 | Acceptance criteria + parity guard | §8 and §10; donor parity explicitly UNVERIFIED |

### Check ledger (all are runtime assertions; none weakened)

| # | Check | Assertion | Pre-fix expected |
|---|---|---|---|
| 1 | `boot_real_64_3d_game` | real main, `3d`, 64×64, entities/camera/capture viewport present | pass |
| 2 | `russia_is_default_nation` | `PLAYER_NATIONS[0]=="rus"`, `players[0].nation=="rus"` | pass |
| 3 | `initial_hall_from_boot` | a live `cen` building of player 0 found in `game.entities` **before any harness spawn** | pass |
| 4 | `hall_node_from_initial_entity` | `_nodes[id]` is a visible `Building_*_<id>_STATIC_POSE` MeshInstance3D with a mesh | pass (sid `cen`) |
| 5 | `hall_mesh_sid_is_russian` | live sid == `ruscen` (derived + literal), meta `nation=="rus"`, `nation_mesh_exact==true` | **FAIL** — expected_pre_fix_failure |
| 6 | `hall_mesh_path_is_russian` | `ResourceLoader.exists(obj_ruscen or glb_ruscen)`, `mesh_source` is a real converted mesh, not `donor_bbox_proxy` | **FAIL** — expected_pre_fix_failure |
| 7 | `peasants_spawned_per_nation` | 5 new `peasant` entities, explicit nations, all player 0 | pass |
| 8 | `peasant_mesh_sids_distinct` | 5 live sids, pairwise distinct, none == `peasant` | **FAIL** — expected_pre_fix_failure |
| 9 | `peasant_mesh_paths_exact` | each sid file-backed, `exact==true`, `_nation_of` returns the requested nation, real mesh source | **FAIL** — expected_pre_fix_failure |
| 10 | `peasant_mesh_resources_distinct` | 5 distinct `multimesh.mesh` instance ids | **FAIL** — expected_pre_fix_failure |
| 11 | `nation_not_player_slot` | all five share player 0 yet have distinct sids (slot-colour shortcut rejected) | **FAIL** — expected_pre_fix_failure |
| 12 | `entities_projected_in_viewport` | hall + 5 peasants project inside 1280×720 (24 px margin) | pass |
| 13 | `png_nations_windowed` | real windowed GPU PNG, 1280×720, non_black_fraction > 0.5 | pass |
| headless | `headless_guard` | false on headless launch; no PNG; `passed=false` | pass (correct skip) |

`expected_pre_fix_failure` is **provenance only** (G02 §1, F2-05 §1): it never
flips `passed`, never lowers a threshold and never deletes a check. On the
current tree checks 5/6/8/9/10/11 are the honest RED baseline.

---

## 3. Why this is decisive, not a source grep

A grep could confirm that `world3d_entities.gd` *contains* a nation selector.
This atom instead (a) boots the real game so the initial hall is the one the
game actually spawned, (b) reads the **live** presentation node and batch that
the player would see, (c) follows the real `world.sync()` → `add_unit()` path,
(d) requires a real on-disk mesh file — so renaming a sid without shipping art
cannot pass, (e) keeps all test peasants in one player slot so a slot-colour
"fix" cannot fake nation distinctness, and (f) saves a windowed GPU PNG with
every subject projected inside the frame. Structural checks are the verdict;
the PNG is the visual evidence G05 reviews.

---

## 4. Proposed atom — FULL GDSCRIPT (in this report only; DO NOT create the file)

**Suggested path for a later owner (NOT created by N05):**
`variant3d/tests/t_nation_assoc_capture.gd`, loadable as
`res://tests/t_nation_assoc_capture.gd`. It would write only
`res://tests/results/t_nation_assoc_capture.json` and one temp PNG.
GDScript 4 syntax; Windows `python`; staged `_process`, no `await` inside it.

```gdscript
# N05 / t_nation_assoc_capture.gd — PROPOSAL ONLY (N05_nation_qa.md §4).
# Not authored, not parsed, not run. A later implementation owner creates this file.
#
# Decisive nation-association atom: real windowed 64x64 3D main.tscn boot with
# Russia as default, assertions on the BOOT-SPAWNED initial town hall's live mesh
# sid/path/nation metas, five peasants (rus/bav/ukr/tur/pol, all player 0) with
# distinct nation-coded, file-backed meshes, and ONE windowed GPU PNG showing
# the hall and all five. Headless => SKIP_CAPTURE / passed=false — NEVER a PASS.
#
#   python variant3d\tools\godot_runner.py status
#   python variant3d\tools\godot_runner.py run --id n05-nation-qa-cap1 --timeout 180 -- ^
#     --path variant3d --script res://tests/t_nation_assoc_capture.gd -- ^
#       --config <ABS>\variant3d\tests\fixtures\small_map_64.json ^
#       --screenshot <TEMP>\n05_nation\nations.png
extends SceneTree

const MAIN_SCENE := "res://scenes/main.tscn"
const OUT_PATH := "res://tests/results/t_nation_assoc_capture.json"
const Data = preload("res://scripts/data.gd")
const Ent = preload("res://scripts/world3d_entities.gd")   # constants only

const NATIONS := ["rus", "bav", "ukr", "tur", "pol"]  # "several nations"
const HALL_BASE_SID := "cen"          # game.gd:2950 — the boot-spawned hall
const PEASANT_BASE_SID := "peasant"   # game.gd:2961
const BOOT_FRAMES := 6                # full real 3D boot before probing
const SETTLE_FRAMES := 4              # let world.sync reconcile the new units
const DT := 1.0 / 30.0                # deterministic presentation step
const PEASANT_DX := 3.0               # metres between adjacent peasants
const PEASANT_DY := 6.0               # metres south of the hall
const VIEW_MARGIN_PX := 24.0

var _id := "t_nation_assoc_capture"
var _checks: Array[Dictionary] = []
var _ok := true
var _finished := false
var _stage := 0
var _stage_frames := 0
var _headless := false
var _capturing := false

var _cfg_arg := ""
var _png_arg := ""
var _abs_config := ""
var _png_path := ""

var _main: Node = null
var _game = null
var _world = null
var _ents = null
var _cam = null

var _half := Vector2.ZERO
var _hall_id := -1
var _hall_pos := Vector2.ZERO
var _peasant_ids: Array[int] = []
var _peasant_entities: Dictionary = {}   # id -> entity Dictionary
var _peasant_pos: Dictionary = {}        # id -> sim Vector2
var _m: Dictionary = {}
var _img: Image = null


func check(name: String, cond, detail: String = "", expected_pre_fix_failure: bool = false) -> void:
	_checks.append({
		"name": name, "passed": cond == true, "detail": detail,
		"expected_pre_fix_failure": expected_pre_fix_failure,
		"status": ("PASS" if cond == true else "FAIL"),
	})
	if cond == false:
		_ok = false
	print("TNATION %s %s - %s%s" % ["PASS" if cond == true else "FAIL", name, detail,
		" [EXPECTED_FAILURE_PRE_FIX]" if expected_pre_fix_failure else ""])


func _arg_value(flag: String) -> String:
	for src in [OS.get_cmdline_user_args(), OS.get_cmdline_args()]:
		var args := PackedStringArray(src)
		for i in range(args.size()):
			if str(args[i]) == flag and i + 1 < args.size():
				return str(args[i + 1])
	return ""


func _resolve_config(given: String) -> String:
	if given.is_absolute_path():
		return given if FileAccess.file_exists(given) else ""
	var by_res := ProjectSettings.globalize_path("res://").path_join(given)
	if FileAccess.file_exists(by_res):
		return by_res
	if FileAccess.file_exists(given):
		return given
	return ""


func _goto(s: int) -> void:
	_stage = s
	_stage_frames = 0


func _write_json(path: String, data: Dictionary) -> bool:
	var dir := path.get_base_dir()
	if dir != "" and not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(data, "\t"))
	f.close()
	return true


func _write_result(verdict: String) -> void:
	# Single terminal write: stage re-entry must never append duplicate checks.
	if _finished:
		return
	_finished = true
	var passes := 0
	for c in _checks:
		if bool(c.get("passed", false)):
			passes += 1
	var out := {
		"id": _id,
		"passed": (verdict == "PASS"),
		"verdict": verdict,
		"capture_path": (_png_path if _img != null else
			"SKIP_CAPTURE — no windowed GPU frame; never a visual PASS"),
		"capture_status": ("PASS" if _img != null else "SKIP_CAPTURE"),
		"passes": passes,
		"total": _checks.size(),
		"checks": _checks,
		"measured": _m,
		"png_nations": _png_path,
		"headless": _headless,
		"no_headless_pass": "headless -> SKIPPED_HEADLESS, passed=false, no PNG",
		"runner_declaration": "COORD to run n05-nation-qa-cap1 via variant3d/tools/godot_runner.py (status first); N05 authored only, no job submitted",
		"script_error_note": "verify via variant3d/tools/smallmap_capture.py scan-stderr on runner stderr.txt",
		"parity_label": "UNVERIFIED — internal mesh/sid-to-nation associations only; no donor GPU A/B frame (CHARTER §3)",
		"dont_copy_donor_bug": "donor gKeyColor is keyed by PLAYER SLOT, NOT nation (donor_key_colors.json:36); all 5 test peasants share player 0 and differ only by explicit nation",
		"unix_ms": Time.get_unix_time_from_system() * 1000.0,
	}
	var ok := _write_json(ProjectSettings.globalize_path(OUT_PATH), out)
	print("TNATION RESULT_JSON: " + ProjectSettings.globalize_path(OUT_PATH) + " ok=" + str(ok))
	print("TNATION RESULT: %s %d/%d" % [verdict, passes, _checks.size()])
	# Non-PASS (incl. SKIPPED_HEADLESS / aborts) exits 1 — no green envelope.
	call_deferred("quit", 0 if verdict == "PASS" else 1)


func _initialize() -> void:
	if _finished:
		return
	_headless = DisplayServer.get_name() == "headless"
	_cfg_arg = _arg_value("--config")
	_png_arg = _arg_value("--screenshot")
	if _headless:
		check("headless_guard", false,
			"SKIP_CAPTURE: nation meshes need a real window and GPU PNG; no fake PASS")
		_m["display_server"] = DisplayServer.get_name()
		_write_result("SKIPPED_HEADLESS")
		return
	if _cfg_arg == "" or _png_arg == "":
		check("launch_args", false,
			"need --config <small_map_64.json> and --screenshot <nations.png> (menu skip)")
		_write_result("ABORTED_ARGS")
		return
	_abs_config = _resolve_config(_cfg_arg)
	if _abs_config == "":
		check("launch_args", false, "config fixture not found: " + _cfg_arg)
		_write_result("ABORTED_ARGS")
		return
	var dir := _png_arg.get_base_dir()
	if dir != "" and not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	_png_path = _png_arg
	_m["config"] = _abs_config
	_m["display_server"] = DisplayServer.get_name()
	var packed := load(MAIN_SCENE) as PackedScene
	if packed == null:
		check("boot_real_64_3d_game", false, "cannot load " + MAIN_SCENE)
		_write_result("ABORTED_BOOT")
		return
	_main = packed.instantiate()
	root.add_child(_main)
	_goto(0)


func _configure() -> bool:
	_game = _main.get("game")
	_world = _main.get("world")
	_cam = _main.get("camera")
	_ents = (_world.get("entities") if _world != null else null)
	var cv = _main.get("capture_view3d")
	var boot_ok := (_game != null and _world != null and _ents != null and _cam != null
		and cv is SubViewport and str(_main.get("render_mode")).to_lower() == "3d"
		and int(_game.get("MAP_W")) == 64 and int(_game.get("MAP_H")) == 64)
	check("boot_real_64_3d_game", boot_ok,
		"render_mode=%s MAP=%sx%s entities=%s capture_view3d=%s" % [
		str(_main.get("render_mode")),
		str(_game.get("MAP_W")) if _game != null else "?",
		str(_game.get("MAP_H")) if _game != null else "?",
		str(_ents != null), str(cv is SubViewport)])
	if not boot_ok:
		return false

	# Russia default: config.json:105 nation0=rus -> PLAYER_NATIONS[0], and
	# game.reset() copies it into players[0].nation (game.gd:428-444).
	var nat0 := ""
	var pn = Data.PLAYER_NATIONS
	if pn is Array and (pn as Array).size() > 0:
		nat0 = str((pn as Array)[0])
	var pnat := ""
	var plist = _game.get("players")
	if plist is Array and (plist as Array).size() > 0 and (plist as Array)[0] is Dictionary:
		pnat = str(((plist as Array)[0] as Dictionary).get("nation", ""))
	_m["player_nations"] = str(pn)
	_m["player0_nation"] = pnat
	check("russia_is_default_nation", nat0 == "rus" and pnat == "rus",
		"PLAYER_NATIONS[0]=%s players[0].nation=%s (config.json:105, config.gd:540-559)" % [
		nat0, pnat])
	if nat0 != "rus" or pnat != "rus":
		return false

	# Freeze main's saver (it _quit(0)s) and the sim; the atom drives sync().
	_main.set("screenshot_frames", 1000000)
	_main.set("screenshot_done", true)
	var ais = _main.get("ais")
	if ais is Array:
		ais.clear()
	_main.set("speed", 0.0)
	_cam.set_process(false)
	_cam.edge_margin = 0.0
	_cam.corner_margin = 0.0
	_half = Vector2(float(_game.get("MAP_W")), float(_game.get("MAP_H"))) * Data.TILE_M * 0.5

	# The INITIAL hall: scan the boot-spawned sim entities BEFORE adding anything.
	for e in _game.entities:
		var ed: Dictionary = e as Dictionary
		if str(ed.get("sid", "")) == HALL_BASE_SID and int(ed.get("player", -1)) == 0 \
			and str(ed.get("kind", "")) == "building" and not bool(ed.get("dead", false)):
			_hall_id = int(ed.get("id", -1))
			_hall_pos = Vector2(ed.get("pos", Vector2.ZERO))
			break
	_m["hall_id"] = _hall_id
	_m["hall_pos_sim"] = [_hall_pos.x, _hall_pos.y]
	check("initial_hall_from_boot", _hall_id > 0,
		"boot 'cen' building of player 0 id=%d pos=%s (game.gd:2950)" % [
		_hall_id, str(_hall_pos)])
	if _hall_id <= 0:
		return false

	# One peasant per nation, ALL AS PLAYER 0. Explicit ed["nation"] is the
	# first source in _nation_of (world3d_entities.gd:665-668), so this probes
	# nation identity rather than donor slot colour (don't-copy-donor-bug guard).
	_peasant_ids.clear()
	_peasant_entities.clear()
	_peasant_pos.clear()
	var mid := (NATIONS.size() - 1) / 2.0
	for i in range(NATIONS.size()):
		var p: Vector2 = _hall_pos + Vector2(float(i - mid) * PEASANT_DX, PEASANT_DY)
		var pe: Dictionary = _game.call("spawn", PEASANT_BASE_SID, 0, p)
		pe["nation"] = NATIONS[i]
		var pid := int(pe.get("id", -1))
		_peasant_ids.append(pid)
		_peasant_entities[pid] = pe
		_peasant_pos[pid] = p
	_m["peasant_nations"] = NATIONS
	_m["peasant_ids"] = _peasant_ids
	check("peasants_spawned_per_nation", _peasant_ids.size() == NATIONS.size(),
		"spawned %d peasants, all player 0, nations=%s" % [
		_peasant_ids.size(), str(NATIONS)])
	if _peasant_ids.size() != NATIONS.size():
		return false

	# Frame hall + peasant row: jump_to_world targets SIM metres (camera3d.gd:264-282).
	_cam.call("jump_to_world", _hall_pos + Vector2(0.0, 3.0))
	return true


func _mesh_path(sid: String) -> String:
	var obj := Ent.OBJ_DIR + sid + ".obj"
	if ResourceLoader.exists(obj):
		return obj
	var glb := Ent.GLB_DIR + sid + ".glb"
	if ResourceLoader.exists(glb):
		return glb
	return ""


func _assert_hall() -> void:
	var nodes: Dictionary = _ents.get("_nodes", {})
	var mi = nodes.get(_hall_id, null)
	var name_ok := (mi is MeshInstance3D and mi != null
		and str(mi.name).begins_with("Building_")
		and str(mi.name).ends_with("_%d_STATIC_POSE" % _hall_id)
		and (mi as MeshInstance3D).mesh != null)
	var sid_live := ""
	if mi is MeshInstance3D and mi != null:
		var pp: PackedStringArray = str(mi.name).split("_")
		if pp.size() >= 4:
			sid_live = str(pp[1])
	# Donor sidmask rule, read from the LIVE entities instance (not invented).
	var want_sid := str(_ents.call("_donor_building_prefix", "rus", HALL_BASE_SID)) + HALL_BASE_SID
	var nat_meta := str(mi.get_meta("nation", "")) if mi != null else ""
	var exact_meta := bool(mi.get_meta("nation_mesh_exact", false)) if mi != null else false
	var status_meta := str(mi.get_meta("nation_mesh_label", "")) if mi != null else ""
	_m["hall_node_name"] = str(mi.name) if mi != null else "<none>"
	_m["hall_mesh_sid_live"] = sid_live
	_m["hall_mesh_sid_want"] = want_sid
	_m["hall_nation_meta"] = nat_meta
	_m["hall_exact_meta"] = exact_meta
	_m["hall_status_meta"] = status_meta
	check("hall_node_from_initial_entity", name_ok,
		"node=%s mesh=%s" % [str(_m["hall_node_name"]),
		str(mi is MeshInstance3D and (mi as MeshInstance3D).mesh != null)])
	check("hall_mesh_sid_is_russian",
		name_ok and sid_live == want_sid and want_sid == "ruscen"
			and nat_meta == "rus" and exact_meta
			and status_meta == Ent.NATION_MESH_EXACT_STATUS,
		"live_sid=%s want=ruscen nation=%s exact=%s status=%s (BLOCKED evidence: world3d_entities.gd:213)" % [
		sid_live, nat_meta, str(exact_meta), status_meta], true)

	var path := _mesh_path(want_sid)
	var mesh_source := str(mi.get_meta("mesh_source", "?")) if mi != null else "?"
	var real_mesh := path != "" and mesh_source != "" and mesh_source != "?"
		and mesh_source != "donor_bbox_proxy"
	_m["hall_mesh_path_expected"] = Ent.OBJ_DIR + want_sid + ".obj"
	_m["hall_mesh_path_exists"] = path
	_m["hall_mesh_source"] = mesh_source
	check("hall_mesh_path_is_russian", path != "" and real_mesh,
		"mesh_path=%s source=%s (empty/proxy = Ukrainian-derived fallback, NOT Russian art)" % [
		path if path != "" else "<none>", mesh_source], true)


func _probe_peasants() -> void:
	var slots: Dictionary = _ents.get("_slot", {})
	var batches: Dictionary = _ents.get("_batches", {})
	var rows: Array[Dictionary] = []
	for pid in _peasant_ids:
		var sl: Dictionary = slots.get(pid, {}) as Dictionary
		var key := str(sl.get("key", ""))
		var parts: PackedStringArray = key.split("|")
		var sid := str(parts[1]) if parts.size() >= 2 else ""
		var idx := int(sl.get("index", -1))
		var b: Dictionary = batches.get(key, {}) as Dictionary
		var node = b.get("node")
		var mesh_id := -1
		var source := "?"
		if node is MultiMeshInstance3D and (node as MultiMeshInstance3D).multimesh != null:
			var mmi := node as MultiMeshInstance3D
			var mesh: Mesh = mmi.multimesh.mesh
			if mesh != null:
				mesh_id = mesh.get_instance_id()
			source = str(mmi.get_meta("mesh_source", "?"))
		var ed: Dictionary = _peasant_entities[pid]
		var ns_v: Variant = _ents.call("_entity_mesh_sid", ed, PEASANT_BASE_SID, "unit")
		var ns: Dictionary = ns_v as Dictionary
		var want_nat := str(ed.get("nation", ""))
		var exact := bool(ns.get("exact", false))
		var ns_nat := str(ns.get("nation", ""))
		var path := _mesh_path(sid)
		rows.append({
			"id": pid, "nation_want": want_nat, "nation_bound": ns_nat,
			"base_sid": PEASANT_BASE_SID, "mesh_sid_live": sid,
			"candidate": str(ns.get("candidate", "")),
			"candidates": ns.get("candidates", []), "exact": exact,
			"slot_key": key, "slot_index": idx, "batch_node": str(node.name) if node != null else "<none>",
			"mesh_instance_id": mesh_id, "mesh_source": source, "mesh_path": path,
			"player": int(ed.get("player", -1)),
		})
	_m["peasant_rows"] = rows
	return rows


func _assert_peasants() -> void:
	# peasants_spawned_per_nation was already checked at spawn time in _configure.
	var rows: Array[Dictionary] = _probe_peasants()
	var sids: Dictionary = {}
	var bad_base := 0
	for r in rows:
		var s := str(r["mesh_sid_live"])
		sids[s] = true
		if s == "" or s == PEASANT_BASE_SID:
			bad_base += 1
	_m["distinct_peasant_sids"] = sids.keys()
	check("peasant_mesh_sids_distinct",
		rows.size() == NATIONS.size() and sids.size() == rows.size() and bad_base == 0,
		"distinct_sids=%d/%d base_peasant_count=%d sids=%s (owner: 'peasants are of different form')" % [
		sids.size(), rows.size(), bad_base, str(sids.keys())], true)

	var paths_exact := rows.size() == NATIONS.size()
	var details: Array = []
	for r in rows:
		var ok := str(r["mesh_path"]) != "" and bool(r["exact"]) \
			and str(r["nation_bound"]) == str(r["nation_want"]) \
			and str(r["mesh_source"]) != "" and str(r["mesh_source"]) != "?"
			and str(r["mesh_source"]) != "donor_bbox_proxy"
		if not ok:
			paths_exact = false
		details.append([str(r["nation_want"]), str(r["mesh_sid_live"]),
			str(r["mesh_path"]), bool(r["exact"])])
	_m["peasant_path_exact_detail"] = details
	check("peasant_mesh_paths_exact", paths_exact,
		"every nation sid file-backed + exact=true + nation match: %s" % str(details), true)

	var meshes: Dictionary = {}
	for r in rows:
		meshes[int(r["mesh_instance_id"])] = true
	_m["distinct_peasant_mesh_count"] = meshes.size()
	check("peasant_mesh_resources_distinct",
		rows.size() == NATIONS.size() and meshes.size() == rows.size()
			and not meshes.has(-1),
		"distinct mesh resources=%d/%d (not just distinct player tints)" % [
		meshes.size(), rows.size()], true)

	# Donor key colours are slot-keyed, NOT nation-keyed (donor_key_colors.json:36).
	# Same slot + distinct sids proves the association follows nation, not colour.
	check("nation_not_player_slot",
		rows.size() == NATIONS.size() and sids.size() == rows.size() and bad_base == 0,
		"all 5 share player 0 yet bind %d distinct sids — donor slot-colour shortcut rejected" % sids.size(), true)


func _assert_projection() -> void:
	var pts: Array = []
	var inside := true
	var hall_w := Vector3(_hall_pos.x - _half.x,
		float(_game.call("height_at", _hall_pos)), _hall_pos.y - _half.y)
	var hp: Vector2 = _cam.unproject_position(hall_w)
	pts.append(["hall", hall_w, hp])
	for pid in _peasant_ids:
		var p: Vector2 = _peasant_pos[pid]
		var w := Vector3(p.x - _half.x, float(_game.call("height_at", p)), p.y - _half.y)
		var s: Vector2 = _cam.unproject_position(w)
		pts.append(["peasant_%d" % pid, w, s])
	for rec in pts:
		var s: Vector2 = rec[2]
		if s.x < VIEW_MARGIN_PX or s.x > 1280.0 - VIEW_MARGIN_PX \
			or s.y < VIEW_MARGIN_PX or s.y > 720.0 - VIEW_MARGIN_PX:
			inside = false
	var record: Array = []
	for rec in pts:
		record.append([str(rec[0]), [snapped((rec[2] as Vector2).x, 1),
			snapped((rec[2] as Vector2).y, 1)]])
	_m["projected_px"] = record
	check("entities_projected_in_viewport", inside,
		"hall + %d peasants inside 1280x720 (margin %.0f px): %s" % [
		_peasant_ids.size(), VIEW_MARGIN_PX, str(record)])


func _capture_async() -> void:
	_capturing = true
	var cv := _main.get("capture_view3d") as SubViewport
	if cv == null or not is_instance_valid(cv):
		check("png_nations_windowed", false,
			"main.capture_view3d missing (windowed --screenshot boot required)")
		_capturing = false
		return
	cv.render_target_update_mode = SubViewport.UPDATE_ONCE
	var tex := cv.get_texture()
	if tex == null:
		check("png_nations_windowed", false, "null Screenshot3DViewport texture")
		_capturing = false
		return
	await RenderingServer.frame_post_draw
	if _finished:
		return
	var img: Image = tex.get_image()
	if img == null or img.is_empty():
		check("png_nations_windowed", false,
			"blank SubViewport image — no CPU fallback (D03 Trap B / main.gd:1906-1913)")
		_capturing = false
		return
	var err := img.save_png(_png_path)
	var nb := 0
	var n := 0
	for y in range(0, img.get_height(), 4):
		for x in range(0, img.get_width(), 4):
			var c := img.get_pixel(x, y)
			if c.r > 8.0 / 255.0 or c.g > 8.0 / 255.0 or c.b > 8.0 / 255.0:
				nb += 1
			n += 1
	var frac := float(nb) / float(maxi(n, 1))
	_m["png_metrics"] = {"path": _png_path, "w": img.get_width(), "h": img.get_height(),
		"non_black_fraction": snapped(frac, 4), "err": err,
		"bytes": FileAccess.get_file_as_bytes(_png_path).size() if FileAccess.file_exists(_png_path) else 0}
	_img = img
	check("png_nations_windowed", err == OK and img.get_width() == 1280
		and img.get_height() == 720 and frac > 0.5,
		"saved real windowed GPU frame %dx%d err=%d non_black=%.3f" % [
		img.get_width(), img.get_height(), err, frac])
	_capturing = false


func _process(_dt: float) -> bool:
	if _finished or _capturing:
		return false
	_stage_frames += 1
	match _stage:
		0:
			if _stage_frames >= BOOT_FRAMES:
				if not _configure():
					_write_result("ABORTED_SETUP")
				else:
					# world.sync reconciles the new units into real batches and
					# resolves each nation mesh sid (world3d.gd:329-354).
					_world.call("sync", DT)
					_assert_hall()
					_assert_peasants()
					_assert_projection()
					_goto(1)
		1:
			if _stage_frames >= SETTLE_FRAMES:
				_capture_async()   # coroutine called FROM _process; _process stays sync
				_goto(2)
		2:
			if _stage_frames >= 3:
				# png_nations_windowed already checked inside _capture_async.
				_write_result("PASS" if _ok else "FAIL")
	return false
```

### Implementation notes for the later owner (do not weaken)

1. **Staged `_process`, no `await` inside it.** `_capture_async()` awaits
   `RenderingServer.frame_post_draw` but is called *from* `_process`; keeping
   `_process` synchronous avoids the `SceneTree._process() -> bool` coroutine
   trap (D03 §4.3.2, G02/M04 precedent).
2. **Live instance, not script class, for instance methods.**
   `_donor_building_prefix()` and `_entity_mesh_sid()` are instance methods of
   `world3d_entities.gd`; they are called as `_ents.call(...)`. `Ent` (preload)
   is used **only** for constants (`OBJ_DIR`, `GLB_DIR`, `NATION_MESH_EXACT_STATUS`).
3. **No CPU fallback, no root texture.** The PNG reads only
   `capture_view3d.get_texture().get_image()`; a blank/wrong-size image fails
   loudly (D03 Trap B, `main.gd:1235-1238,1861-1863`).
4. **The initial hall is never re-spawned.** The atom reads the hall from
   `game.entities` at boot and only *adds* the five test peasants. Re-spawning
   the hall would let a fix pass on a synthetic object while the real start
   stays wrong.
5. **Nation comes from the explicit entity field, not player slot.** All five
   peasants use player 0 so the donor slot-colour convention cannot fake
   nation distinctness; this is the anti-donor-bug control.
6. **One result write.** `_write_result()` returns early if `_finished`, so
   stage 2 cannot append duplicate checks before deferred `quit` lands
   (G02 correction).
7. **If the fix renames nodes/batch keys**, the integrating owner must update
   the probes here (node suffix and `key.split("|")[1]`); do not delete or
   re-scope the checks to make them green.

---

## 5. Artifacts (all under one unique Temp folder)

| Artifact | Name / purpose |
|---|---|
| PNG | `<TEMP>\n05_nation\nations.png` — real windowed 1280×720 GPU frame: boot-spawned Russian hall + five nation peasants, all projected in view |
| Result JSON | `variant3d\tests\results\t_nation_assoc_capture.json` — 13 checks, `measured`, verdict, PNG path, headless flag, parity + don't-copy-donor-bug labels |
| Runner envelope | `variant3d\.godot_queue\results\000NNNNN.json` and `000NNNNN_n05-nation-qa-cap1\stdout.txt` / `stderr.txt` |

Illustrative `measured` shape (**expected, not observed** — the atom has not run):

```json
{
  "player_nations": "[\"rus\", \"bav\"]",
  "player0_nation": "rus",
  "hall_id": 10,
  "hall_mesh_sid_live": "ruscen",
  "hall_mesh_sid_want": "ruscen",
  "hall_nation_meta": "rus",
  "hall_exact_meta": true,
  "hall_mesh_path_exists": "res://assets/models/obj/ruscen.obj",
  "hall_mesh_source": "obj_zup_bbox_normalised",
  "peasant_rows": [
    {"nation_want": "rus", "mesh_sid_live": "pearus", "exact": true,
     "mesh_path": "res://assets/models/obj/pearus.obj", "player": 0},
    {"nation_want": "bav", "mesh_sid_live": "peabav", "exact": true,
     "mesh_path": "res://assets/models/obj/peabav.obj", "player": 0}
  ],
  "distinct_peasant_sids": ["pearus", "peabav", "peaukr", "peatur", "peapol"],
  "parity_label": "UNVERIFIED — internal associations only"
}
```

**DERIVED** — the concrete `pea*` sid values above are *illustrative of a
successful fix*, not donor claims by N05. The atom never hard-codes them; it
requires distinct, exact, file-backed nation-coded sids from the live binding.

---

## 6. Verdict semantics (NOT weakened)

| Situation | `verdict` | `passed` | `capture_status` | exit |
|---|---|---|---|---|
| All checks true + windowed PNG saved | `PASS` | true | `PASS` | 0 |
| Any evaluated check false (pre-fix RED on 5/6/8/9/10/11) | `FAIL` | false | `SKIP_CAPTURE` | 1 |
| **Headless launch** | `SKIPPED_HEADLESS` | **false** | `SKIP_CAPTURE` | 1 |
| Bad args / fixture / boot / setup | `ABORTED_*` | false | `SKIP_CAPTURE` | 1 |

- The headless branch in `_initialize()` writes the result JSON with
  `passed=false`, **no PNG**, `capture_path` = literal `SKIP_CAPTURE …`, and
  defers `quit(1)`. There is no code path where headless reports PASS
  (G02 §4, M04 §6, F2-05 §0).
- `passed` is computed solely as `(verdict == "PASS")`.

---

## 7. Exact runner command — for COORD only, NOT executed by N05

**Before submitting** — one-Godot rule (`CHARTER.md` §3;
`WAVE_G_CHARTER.md:31`):

```powershell
python variant3d\tools\godot_runner.py status
```

Proceed only when `godot.lock` is free (or wait in the FIFO). Unique id:
**`n05-nation-qa-cap1`** (refresh to `-cap2` if that id already appears under
`variant3d\.godot_queue\results\`). One PowerShell-safe line from the project
root, Windows `python`, no `&&`, **no `--headless`**:

```powershell
python variant3d\tools\godot_runner.py run --id n05-nation-qa-cap1 --timeout 180 -- --path variant3d --script res://tests/t_nation_assoc_capture.gd -- --config "C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\tests\fixtures\small_map_64.json" --screenshot "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\n05_nation\nations.png"
```

- First `--` is consumed by the runner; the second separates Godot engine args
  from atom user args (G02 §5, M04 §7).
- `--screenshot` is **only** the menu-skip flag (`main.gd:230-244`); the atom
  writes the PNG itself and disarms main's saver.
- Expected envelope: `000NNNNN.json` plus
  `000NNNNN_n05-nation-qa-cap1\stdout.txt` / `stderr.txt`; atom JSON:
  `variant3d\tests\results\t_nation_assoc_capture.json`.

**Headless variant — must NOT be accepted as a visual PASS.** Add `--headless`
before the first `--`; the atom emits `capture_path = "SKIP_CAPTURE …"`,
`verdict = SKIPPED_HEADLESS`, `passed = false`, writes no PNG and exits 1:

```powershell
python variant3d\tools\godot_runner.py run --id n05-nation-qa-headless1 --timeout 120 -- --headless --path variant3d --script res://tests/t_nation_assoc_capture.gd -- --config "C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\tests\fixtures\small_map_64.json" --screenshot "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\n05_nation\nations_headless.png"
```

Read-only post-run checks (no Godot):

```powershell
python variant3d\tools\smallmap_capture.py stats "C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\n05_nation\nations.png"
python variant3d\tools\smallmap_capture.py scan-stderr "C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3\variant3d\.godot_queue\results\000NNNNN_n05-nation-qa-cap1\stderr.txt"
```

Expect 1280×720, `non_black_fraction > 0.5`, `full_width_dark_rows == 0`, and
`script_error_lines == 0`. `stats` is qualitative; the in-atom structural
checks are authoritative.

---

## 8. Acceptance criteria (all mandatory for a PASS)

| # | Criterion | Evidence |
|---|---|---|
| 1 | Envelope `status=ok`, `exit=0`, `argv` has **no** `--headless`, id `n05-nation-qa-cap1` | `000NNNNN.json` |
| 2 | `SCRIPT ERROR` count 0 | `smallmap_capture.py scan-stderr` on runner `stderr.txt` |
| 3 | Result JSON `verdict=PASS`, `passed=true`, `capture_status=PASS`, `headless=false` | `t_nation_assoc_capture.json` |
| 4 | `boot_real_64_3d_game` true (`render_mode=3d`, 64×64, real camera/entities/capture viewport) | result JSON |
| 5 | `russia_is_default_nation` true: `PLAYER_NATIONS[0]=="rus"`, `players[0].nation=="rus"` | result JSON `measured` |
| 6 | `initial_hall_from_boot` + `hall_node_from_initial_entity` true: the boot's own player-0 `cen` has a visible `Building_*_<id>_STATIC_POSE` mesh | result JSON |
| 7 | **Decisive:** `hall_mesh_sid_is_russian` true — live sid `ruscen`, `nation=="rus"`, `exact==true`, exact-status label | result JSON `measured.hall_*` |
| 8 | **Decisive:** `hall_mesh_path_is_russian` true — `ruscen.obj/.glb` exists and `mesh_source` is a converted mesh, not `donor_bbox_proxy` | result JSON `measured.hall_mesh_path_exists` |
| 9 | `peasants_spawned_per_nation` true: five explicit-nation peasants, all player 0 | result JSON `measured.peasant_rows` |
| 10 | **Decisive:** `peasant_mesh_sids_distinct` true — 5 distinct live sids, none == `peasant` | result JSON `measured.distinct_peasant_sids` |
| 11 | `peasant_mesh_paths_exact` true — every nation sid file-backed, `exact==true`, bound nation matches requested | result JSON `measured.peasant_path_exact_detail` |
| 12 | `peasant_mesh_resources_distinct` true — 5 distinct `multimesh.mesh` ids (not just tints) | result JSON `measured.distinct_peasant_mesh_count` |
| 13 | `nation_not_player_slot` true — same slot, different sids (donor slot-colour shortcut rejected) | result JSON check 11 |
| 14 | `entities_projected_in_viewport` true and PNG exists, 1280×720, non-blank (>0.5) | result JSON `measured.projected_px` + PNG + `stats` |
| 15 | `expected_pre_fix_failure` on checks 5/6/8/9/10/11 is provenance only; no threshold lowered, no check deleted | source diff vs this proposal |
| 16 | No donor-parity claim: `parity_label=UNVERIFIED`, report §10 labels donor parity UNVERIFIED | JSON + report |

**Overall PASS = all 1–16.** If the PNG is missing/blank, the honest verdict is
`UNVERIFIED (NO PNG)`, never a visual PASS from JSON alone (D03 §6/§8, G01 §6).
A RED structural check is a genuine FAIL, not something to "fix" by relaxing a
threshold.

---

## 9. Don't-copy-donor-bug guard

- **Donor anti-pattern:** the donor's `gKeyColor` is keyed by **player slot
  index, NOT nation** (`donor_key_colors.json:36-41`; echoed in our telemetry
  `world3d_entities.gd:473`). A tempting shortcut for "nations look different"
  is to reuse slot colour or slot identity as the object association. That is
  exactly the donor convention the owner's directive rejects: two nations in
  the same slot would still look identical.
- **Atom guard:** all five test peasants are spawned as **player 0** and differ
  *only* by an explicit `ed["nation"]`. `nation_not_player_slot` requires five
  distinct live mesh sids in that single slot. A slot-keyed "fix" collapses
  them to one batch sid and goes RED. The hall check independently requires
  `nation=="rus"` from `players[0].nation`, not from a slot colour.
- **Second guard against a fake fix:** `mesh_source != donor_bbox_proxy` and a
  real on-disk `ruscen`/nation peasant mesh are required. Renaming sids
  without shipping art cannot pass.
- **Per G18 register:** this guard follows the standing rule "do not reproduce
  donor bugs/quirks" (`G18_donor_bugs.md:47-165, 306-331`, `F01_almanac_terrain.md:413`).
  It is a *guard*, not a claim that the donor itself had a nation-mesh bug —
  no donor GPU A/B frame exists and that question is **UNVERIFIED**.

---

## 10. Observed / derived / inferred / UNVERIFIED ledger

- **OBSERVED (direct source reads this session):** `config.json:105-108`;
  `config.gd:540-559`; `data.gd:207-208, 276-306, 1564-1568`;
  `game.gd:428-444, 469-479, 2942-2962`; `main.gd:581`;
  `world3d_entities.gd:84-85, 203-213, 303-308, 432-478, 649-800, 803-808,
  1110-1160, 1401-1438, 1612-1668, 1662`; `manifest.json:5-11, 1050-1053`;
  `donor_key_colors.json:36-41`; `tests/fixtures/small_map_64.json:1-16`;
  `smallmap_capture.py`/`godot_runner.py` usage quoted from G01/G02/M04/F2-05;
  glob of `assets/models/obj/**/*rus*` (none).
- **DERIVED:** `ruscen` from `_donor_building_prefix("rus","cen")+"cen"`;
  further fallback of both `cen` and `peasant` to Ukrainian-derived base art on
  the current tree; the need for an explicit `nation` field to probe nation
  identity in one player slot; mesh-path determinism from `OBJ_DIR`/`GLB_DIR`;
  the slot-colour anti-donor-bug control; exit-1 headless guard.
- **INFERRED (to be confirmed by a real run):** on the current tree the atom
  should PASS checks 1-4/7/12/13 and go RED on 5/6/8/9/10/11, producing a
  PNG where the hall and all five peasants are visible; after a hypothetical
  nation-art fix all 13 checks should turn green. These are **expectations,
  not results**.
- **UNVERIFIED / PORT APPROX:** **all donor parity** — no donor GPU A/B frame
  exists under this charter; the true donor `ruscen` silhouette and nation
  peasant forms are not visually compared. `NATION_MESH_EXACT_STATUS` itself
  means "exact nation 3D mesh found on disk (donor-derived sid); visual
  UNVERIFIED" (`world3d_entities.gd:205`). Whether the shipped OBJs are
  visually faithful, whether the PNG composites as expected, and whether this
  atom parses/runs at all are UNVERIFIED.
- **NOT DONE by N05:** no `.gd` atom created, no Godot process, no runner job,
  no PNG, no result JSON, no parse check. Everything runtime-related awaits
  the implementation owner and G04's single windowed run under the one-Godot
  lock.

---

## 11. Handoff

- **COORD / implementation owner:** if this atom is adopted, create
  `variant3d/tests/t_nation_assoc_capture.gd` **from §4 verbatim**, then hand
  the §7 command to **G04** (sole runner owner) under the FIFO lock. Keep all
  16 acceptance criteria; do not flip the headless branch to a pass, do not
  delete `expected_pre_fix_failure` provenance, do not re-scope the distinctness
  or file-backed-mesh checks, and do not lower `mesh_source != donor_bbox_proxy`.
- **G05 / C04 visual review:** open `nations.png` and `measured.projected_px`;
  confirm one hall and five peasants in frame and describe whether their forms
  actually look different. Report observations only — no donor parity
  conclusion from smoothness or appearance.
- **If a future change binds a non-Russian hall to Russia, or gives two of the
  five nations the same mesh/sid, or falls back to `donor_bbox_proxy`,** the
  corresponding check (5/6/8/9/10/11/13) must go RED and stay RED; the
  integrating owner updates this probe — not the threshold.

*End of N05 report.*
