extends SceneTree
# Read-only probe: Godot Rect2(position, size).abs() corner semantics.
func _initialize() -> void:
	var a := Rect2(Vector2(100, 100), Vector2(-40, -30))
	print("RECT2ABS raw=", a, " abs=", a.abs())
	var b := Rect2(Vector2(100, 100), Vector2(40, 30))
	print("RECT2ABS raw=", b, " abs=", b.abs())
	quit(0)
