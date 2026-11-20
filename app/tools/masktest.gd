extends SceneTree

func _init() -> void:
	var world: C3World = C3World.new()
	var masks := world._build_masks(16)
	print("nmasks: ", masks.size())
	var combo := Image.create(16 * 16, 16, false, Image.FORMAT_RGB8)
	for i in 16:
		var m: Image = masks[i]
		var cov := 0.0
		for y in 16:
			for x in 16:
				if m.get_pixel(x, y).a > 0.0:
					cov += 1.0
		print("mask ", i, " coverage: ", cov / 256.0)
		for y in 16:
			for x in 16:
				var a: float = m.get_pixel(x, y).a
				combo.set_pixel(i * 16 + x, y, Color(a, a, a))
	var out := ProjectSettings.globalize_path("res://shots/masks_test.png")
	combo.save_png(out)
	print("saved: ", out)
	quit()
