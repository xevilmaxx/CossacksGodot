extends SceneTree

# Diagnostic-only: print pattern_stamps names/kinds for the current seed/config.
# No donor execution, no value change, no parity claim.

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var cfg := ""
	var seed := 20261113
	var i := 0
	while i < args.size():
		if args[i] == "--config" and i + 1 < args.size():
			cfg = args[i + 1]
		if args[i] == "--seed" and i + 1 < args.size():
			seed = int(args[i + 1])
		i += 1
	var game: Object = (load("res://scripts/game.gd") as Script).new()
	var DataScript: Script = load("res://scripts/data.gd") as Script
	var Data: Object = DataScript.new()
	Data.set("RANDOM_SEED", seed)
	Data.set("MAP_W", 240)
	Data.set("MAP_H", 240)
	game.setup_begin("skirmish")
	game._gen_base()
	var stamps: Array = game.get("pattern_stamps")
	print("STAMPNAMES count=", stamps.size())
	var names := {}
	for s in stamps:
		if s == null:
			continue
		var kind := str(s.get("kind", ""))
		var name := str(s.get("name", ""))
		if not names.has(name):
			names[name] = {"kind": kind, "n": 0}
		names[name]["n"] = int(names[name]["n"]) + 1
	for k in names.keys():
		print("STAMP ", k, " kind=", names[k]["kind"], " n=", names[k]["n"])
	quit()
