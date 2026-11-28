extends SceneTree
# Read-only fixed-camera close-up of one wood resource node, to discriminate
# the LOD-vs-UV hypotheses in TREE_FOLIAGE_DEEPDIVE.md. No sim writes, no
# asset/value change, no donor execution, no parity claim.
# Run through godot_runner.py --script with --config <abs 64 json>,
# --screenshot <abs menu-skip png>, --out <abs png>.

const MAIN_SCENE := "res://scenes/main.tscn"

var _main: Node = null
var _out := ""
var _stage := 0
var _frames := 0
var _node: Dictionary = {}


func _arg_value(flag: String) -> String:
	for src in [OS.get_cmdline_user_args(), OS.get_cmdline_args()]:
		var a := PackedStringArray(src)
		for i in range(a.size()):
			if str(a[i]) == flag and i + 1 < a.size():
				return str(a[i + 1])
	return ""


func _initialize() -> void:
	_out = _arg_value("--out")
	if _out == "" or _arg_value("--config") == "" or _arg_value("--screenshot") == "":
		print("TREECAP FAIL need --config --screenshot --out")
		quit(1)
		return
	var packed := load(MAIN_SCENE) as PackedScene
	if packed == null:
		print("TREECAP FAIL main scene")
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
		if g == null or cam == null:
			if _frames > 1200:
				print("TREECAP FAIL boot timeout")
				quit(1)
			return false
		var rn: Array = g.get("res_nodes")
		for n in rn:
			if n is Dictionary and str((n as Dictionary).get("type", "")) == "wood":
				_node = n as Dictionary
				break
		if _node.is_empty():
			print("TREECAP FAIL no wood res node")
			quit(1)
			return false
		var pos: Vector2 = _node.get("pos", Vector2.INF)
		print("TREECAP node=%s pos=%s" % [str(_node.keys()), str(pos)])
		cam.call("apply_external_target", pos)
		cam.call("set_zoom_target", 2.5, true)
		var vp = _main.get("capture_view3d")
		if vp != null:
			vp.render_target_update_mode = SubViewport.UPDATE_ONCE
		_stage = 1
		_frames = 0
		return false
	if _stage == 1 and _frames >= 3:
		var vp: SubViewport = _main.get("capture_view3d") as SubViewport
		if vp == null:
			print("TREECAP FAIL no capture viewport")
			quit(1)
			return false
		var tex := vp.get_texture()
		var img := tex.get_image() if tex != null else null
		if img == null or img.is_empty():
			print("TREECAP FAIL blank image")
			quit(1)
			return false
		var err := img.save_png(_out)
		var cam = _main.get("camera")
		print("TREECAP saved=%s size=%sx%s err=%s target=%s height=%s" % [
			_out, str(img.get_width()), str(img.get_height()), str(err),
			str(cam.get("_target")), str(cam.get("height"))])
		quit(0)
	return false
