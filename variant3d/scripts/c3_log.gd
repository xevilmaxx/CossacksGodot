class_name C3Log
extends RefCounted
## C3Log — leveled, opt-in diagnostic logging for the port.
##
## STATIC CLASS (2026-11-27): converted from an autoload Node because the
## Godot-native MCP host boots with `--script res://tests/t_mcp_host.gd`; in that
## main-loop mode autoloads are NOT registered, so every `C3Log.*` call failed
## to compile (main.gd:571) and the host never reached READY. A class_name is
## resolved from the project class cache in BOTH normal and --script boots.
## No behaviour change: still print-only, default OFF, same levels and config.
##
## Log levels (ascending): OFF < ERROR < WARN < INFO < DEBUG < TRACE.
## Default OFF: zero output, so every deterministic capture and gate is
## byte-identical to a build without this file.
##
## Source of level (first match wins):
##   1. env C3_LOG_LEVEL (ERROR/WARN/INFO/DEBUG/TRACE/OFF)
##   2. res://logging_config.json  -> "level"
##   3. OFF
##
## Module gates (from the config "modules" dict) let a caller suppress a
## subsystem's lines even at a high level. Missing module key = enabled.
##
## This is PRINT-ONLY telemetry. It never changes a value, gate, timing,
## RNG stream, capture frame or parity state, and is never a donor claim.

const LEVEL_OFF: int = 0
const LEVEL_ERROR: int = 1
const LEVEL_WARN: int = 2
const LEVEL_INFO: int = 3
const LEVEL_DEBUG: int = 4
const LEVEL_TRACE: int = 5

const CONFIG_PATH: String = "res://logging_config.json"
const ENV_LEVEL: String = "C3_LOG_LEVEL"
const PREFIX: String = "[C3LOG]"

static var _level: int = LEVEL_OFF
static var _modules: Dictionary = {}
static var _loaded: bool = false


static func _level_from_name(name: String) -> int:
	match name.strip_edges().to_upper():
		"ERROR":
			return LEVEL_ERROR
		"WARN", "WARNING":
			return LEVEL_WARN
		"INFO":
			return LEVEL_INFO
		"DEBUG":
			return LEVEL_DEBUG
		"TRACE":
			return LEVEL_TRACE
		_:
			return LEVEL_OFF


static func _load() -> void:
	if _loaded:
		return
	_loaded = true
	_level = LEVEL_OFF
	_modules = {}
	if FileAccess.file_exists(CONFIG_PATH):
		var f := FileAccess.open(CONFIG_PATH, FileAccess.READ)
		if f != null:
			var parsed: Variant = JSON.parse_string(f.get_as_text())
			f.close()
			if parsed is Dictionary:
				var d := parsed as Dictionary
				_level = _level_from_name(str(d.get("level", "OFF")))
				if d.get("modules") is Dictionary:
					_modules = d.get("modules") as Dictionary
	var env_name := OS.get_environment(ENV_LEVEL)
	if not env_name.strip_edges().is_empty():
		_level = _level_from_name(env_name)


static func get_level() -> int:
	_load()
	return _level


static func set_level(level: int) -> void:
	_loaded = true
	_level = clampi(level, LEVEL_OFF, LEVEL_TRACE)


static func module_enabled(module: String) -> bool:
	_load()
	if not _modules.has(module):
		return true
	return bool(_modules.get(module, true))


static func log_at(level: int, module: String, msg: String) -> void:
	_load()
	if level > _level or level == LEVEL_OFF:
		return
	if not module_enabled(module):
		return
	var tags: Array[String] = ["", "ERROR", "WARN", "INFO", "DEBUG", "TRACE"]
	var tag: String = tags[level]
	print(PREFIX, "[", tag, "][", module, "] ", msg)


static func err(module: String, msg: String) -> void:
	log_at(LEVEL_ERROR, module, msg)


static func warn(module: String, msg: String) -> void:
	log_at(LEVEL_WARN, module, msg)


static func info(module: String, msg: String) -> void:
	log_at(LEVEL_INFO, module, msg)


static func debug(module: String, msg: String) -> void:
	log_at(LEVEL_DEBUG, module, msg)


static func trace(module: String, msg: String) -> void:
	log_at(LEVEL_TRACE, module, msg)
