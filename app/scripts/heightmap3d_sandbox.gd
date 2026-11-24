extends Node3D

# Temporary CLI probe: does Godot --script accept a Node3D root?
func _ready() -> void:
	print("G32_PROBE Node3D --script accepted")
	get_tree().quit(0)
