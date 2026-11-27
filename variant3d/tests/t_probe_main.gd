extends SceneTree
const MAIN_SCENE := "res://scenes/main.tscn"
var _main: Node = null
func _initialize():
	var p := load(MAIN_SCENE) as PackedScene
	_main = p.instantiate(); root.add_child(_main)
	for i in range(240):
		await process_frame
		if i % 60 == 0:
			print("PROBE f", i, " game=", str(_main.get("game")), " world=", str(_main.get("world")), " cam=", str(_main.get("camera")), " vp=", str(_main.get("capture_view3d")))
	quit(0)
