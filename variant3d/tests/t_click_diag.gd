extends SceneTree
# Read-only diagnostic for the owner's "click/selection starts at bottom-right"
# report. Boots the real 64x64 donor-backend game, prints map_starts and entity
# positions, then for every entity projects its SIM position to camera pixels
# and asks picking3d.ground_point()/pick() what those pixels resolve to.
# No sim writes, no game-code edits, no donor execution, no parity claim.
# Launch through godot_runner.py --script with --config <abs 64 json> and an
# explicit --screenshot <abs dummy png> (main.gd menu-skip contract).

const MAIN_SCENE := "res://scenes/main.tscn"
const Data = preload("res://scripts/data.gd")

var _main: Node = null
var _stage := 0
var _frames := 0


func _arg_value(flag: String) -> String:
	for src in [OS.get_cmdline_user_args(), OS.get_cmdline_args()]:
		var a := PackedStringArray(src)
		for i in range(a.size()):
			if str(a[i]) == flag and i + 1 < a.size():
				return str(a[i + 1])
	return ""


func _initialize() -> void:
	if _arg_value("--config") == "" or _arg_value("--screenshot") == "":
		print("CLICK-DIAG FAIL need --config <abs> --screenshot <abs>")
		quit(1)
		return
	var packed := load(MAIN_SCENE) as PackedScene
	if packed == null:
		print("CLICK-DIAG FAIL main scene missing")
		quit(1)
		return
	_main = packed.instantiate()
	root.add_child(_main)


func _process(_dt: float) -> bool:
	_frames += 1
	if _stage == 0:
		if _frames < 3:
			return false
		var g = _main.get("game")
		var cam = _main.get("camera")
		var ictl = _main.get("input_ctl")
		if g == null or cam == null or ictl == null:
			if _frames > 1200:
				print("CLICK-DIAG FAIL boot timeout")
				quit(1)
			return false
		_stage = 1
		_frames = 0
		return false
	if _stage == 1 and _frames >= 2:
		var g = _main.get("game")
		var cam = _main.get("camera")
		var ictl = _main.get("input_ctl")
		var picking = ictl.get("picking")
		var half: Vector2 = Vector2(int(g.get("MAP_W")), int(g.get("MAP_H"))) * 0.5 * Data.TILE_M
		var starts: Array = g.get("map_starts")
		print("CLICK-DIAG MAP=%sx%s half=%s root_vp=%s cam_vp=%s" % [
			str(g.get("MAP_W")), str(g.get("MAP_H")), str(half),
			str(root.size), str(cam.get_viewport().size)])
		var si := 0
		for s in starts:
			print("CLICK-DIAG start[%d]=%s" % [si, str(s)])
			si += 1
		if picking == null:
			print("CLICK-DIAG FAIL picking3d not bound")
			quit(1)
			return true
		var rn: Array = g.get("res_nodes")
		var kinds: Dictionary = {}
		var sids: Dictionary = {}
		for n in rn:
			if n is Dictionary:
				var k := str((n as Dictionary).get("type", (n as Dictionary).get("sid", "?")))
				kinds[k] = int(kinds.get(k, 0)) + 1
				if k == "wood":
					var sid := str((n as Dictionary).get("sid", "?"))
					sids[sid] = int(sids.get(sid, 0)) + 1
		print("CLICK-DIAG res_nodes n=%d kinds=%s wood_sids=%s" % [rn.size(), str(kinds), str(sids)])
		var ents: Array = g.get("entities")
		for e in ents:
			if e == null or (e is Dictionary and (e as Dictionary).is_empty()):
				continue
			var ed: Dictionary = e
			var idv: int = int(ed.get("id", -1))
			var pos: Vector2 = ed.get("pos", Vector2.INF)
			if not is_finite(pos.x) or idv < 0:
				continue
			var centred: Vector2 = pos - half
			var px: Vector2 = cam.unproject_position(Vector3(centred.x, 0.0, centred.y))
			var gp: Variant = picking.call("ground_point", px)
			var pk: Dictionary = picking.call("pick", px, false)
			var gp_err: String = "n/a"
			if gp is Vector2:
				gp_err = "%.2f" % (gp as Vector2).distance_to(pos)
			print("CLICK-DIAG ent id=%d player=%s kind=%s sim=%s px=%s ground=%s err_m=%s pick_id=%s" % [
				idv, str(ed.get("player", -1)), str(ed.get("kind", "?")), str(pos),
				str(px), str(gp), gp_err, str(pk.get("id", -1))])
		quit(0)
	return false
