# MCP host re-verified after C3Log static-class conversion

Date: 2026-11-27. Runner tickets 222-226. Port-internal telemetry only; no
donor execution, no parity claim.

## 1. Regression found

The 20-minute watchdog was due, so the `cossacksgodotmcp` host was launched via
the documented `--script res://tests/t_mcp_host.gd` path (QA 64×64 config).
Ticket 222 printed `GAMECRAFT-MCP LISTENING` but never `READY`:

```
SCRIPT ERROR: Compile Error: Identifier not found: C3Log
   at: GDScript::reload (res://scripts/main.gd:571)
ERROR: Failed to load script "res://scripts/main.gd"
```

Root cause: `C3Log` had been added as an **autoload Node**. Godot does not
register autoloads when the main loop is supplied by `--script`, so every
`C3Log.*` call failed to compile in that boot path. Normal `--headless` runs
were unaffected, which is why earlier gates did not catch it.

## 2. Fix

- `variant3d/scripts/c3_log.gd` converted to a **static class**
  (`class_name C3Log`, `static var` state, `static func` methods), backup
  `.bak-STATICLOG`. Behaviour unchanged: print-only, default OFF, same levels,
  env/config precedence, module gates.
- `variant3d/project.godot`: autoload entry removed, backup `.bak-STATICLOG`.
- Godot class cache rescanned through the runner
  (`--headless --path variant3d --editor --quit`, ticket 224); the cache now
  contains `C3Log`. No user mod, donor value or config key changed.

## 3. Verification

- Normal headless (ticket 225): 172 `[C3LOG]` INFO lines at `C3_LOG_LEVEL=INFO`,
  **0 parse/script errors** — the class resolves in the ordinary boot path.
- `--script` MCP host (ticket 226): `GAMECRAFT-MCP READY port=8931 map=64x64`.
  Handshake HTTP 200, `protocolVersion=2025-03-26`,
  `serverInfo=cossacksgodotmcp/1.0.0`, integer id echo, `tools/list` exactly
  6 tools, `notifications/initialized` 202, `GET /mcp` 202.
  All six tools exercised live: `game.status` (64×64, 19 entities, seed
  20261113), `game.tick` (0.5 s advance), `game.tick({})` clean `isError`
  refusal, `camera.pan_to` (settled/clamped), `game.screenshot` (1280×720
  PNG, valid signature, 1.32 MB), `game.place_building` (refused with exact
  reason), `video.record_frames` (4 PNG frames).
  Host stopped by runner hard timeout; queue returned to 0 pending / lock free.

## 4. Status

MCP host all 6 tools VERIFIED live again on the final tree, including a
post-fix re-run after the PICKSCREEN-RACE-01 input change (ticket 242) and a
watchdog-due re-verification (ticket 247: READY `map=64x64`, handshake, 6
schemas, all six calls, exact refusals retained, 0 parse/script errors).
This is port-internal protocol/tooling evidence; it is not donor parity and
does not advance the 0/6 chain.
