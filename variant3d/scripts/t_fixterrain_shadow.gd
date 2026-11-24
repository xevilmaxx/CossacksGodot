extends SceneTree

# TEMPORARY FIX-TERRAIN shadow A/B probe — created, run, then DELETED.
# Same scene + camera, toggles ONLY sun.shadow_enabled and terrain cast_shadow.
const MODULE_PATH := "res://scripts/world3d_terrain.gd"
const DUMP_ABS := "C:/Users/Maxym.Oboyshev/Documents/Craft Anything/cossacks-3-3/app/shots/g32_dump.json"
const OUT_DIR := "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/"

class StubGame extends C3Game:
	var dump: Dictionary = {}

var _done := false

func _initialize() -> void:
	call_deferred("_run")

func _finish(code: int) -> void:
	if _done:
		return
	_done = true
	call_deferred("quit", code)

func _shot(vp: SubViewport, tag: String) -> bool:
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var img: Image = vp.get_texture().get_image()
	if img == null or img.is_empty():
		print("FIXTERRAIN_SHADOW blank ", tag)
		return false
	var path := OUT_DIR + "fixterrain_shadow_" + tag + ".png"
	var err := img.save_png(path)
	print("FIXTERRAIN_SHADOW saved ", path, " err=", err)
	return err == OK

func _run() -> void:
	var script := load(MODULE_PATH) as Script
	if script == null:
		_finish(1)
		return
	var f := FileAccess.open(DUMP_ABS, FileAccess.READ)
	if f == null:
		_finish(1)
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if not (parsed is Dictionary):
		_finish(1)
		return
	var stub := StubGame.new()
	stub.dump = parsed
	var terrain: Node = script.new()
	terrain.bind(stub)
	if not bool(terrain.call("build")):
		_finish(1)
		return
	var vp := SubViewport.new()
	vp.name = "ShadowABViewport"
	vp.size = Vector2i(1280, 720)
	root.add_child(vp)
	vp.world_3d = World3D.new()
	vp.add_child(terrain)
	# A LIT receiver plane (StandardMaterial3D receives Godot shadows); the
	# tile-index terrain itself is `unshaded` and never receives them.
	var ground := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(420, 420)
	ground.mesh = pm
	var gm := StandardMaterial3D.new()
	gm.albedo_color = Color(0.72, 0.70, 0.62)
	ground.material_override = gm
	ground.position = Vector3(0.0, 3.4, 0.0)
	ground.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	vp.add_child(ground)
	# Lit probe geometry so a Godot shadow map is actually visible.
	var probes: Array[MeshInstance3D] = []
	for i in range(3):
		var box := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(6, 14, 6)
		box.mesh = bm
		var sm := StandardMaterial3D.new()
		sm.albedo_color = Color(0.85, 0.84, 0.78)
		box.material_override = sm
		box.position = Vector3(-40.0 + float(i) * 40.0, 9.0, 10.0)
		box.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		vp.add_child(box)
		probes.append(box)
	var cam := Camera3D.new()
	cam.fov = 28.0
	cam.position = Vector3(60.0, 55.0, 150.0)
	vp.add_child(cam)
	cam.look_at(Vector3(0, 0, 0), Vector3.UP)
	cam.make_current()
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	var sun: DirectionalLight3D = terrain.get_node_or_null("DonorSun") as DirectionalLight3D
	var mi: MeshInstance3D = terrain.get_node_or_null("HeightmapTerrain") as MeshInstance3D
	if sun == null or mi == null:
		_finish(1)
		return
	# A: old shadow-map behaviour.
	sun.shadow_enabled = true
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	for b in probes:
		b.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	var a := await _shot(vp, "shadow_on")
	# B: FIX-TERRAIN shipped behaviour.
	sun.shadow_enabled = false
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for b in probes:
		b.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var b2 := await _shot(vp, "shadow_off")
	_finish(0 if a and b2 else 1)
