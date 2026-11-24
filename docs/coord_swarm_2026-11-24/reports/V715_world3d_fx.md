---
owner: V7-15
date: 2026-11-24
role: atomic builder — spatial FX / build ghost / rally marker layer
lane: Wave 7 phase 2 — 3D variant
output: docs/coord_swarm_2026-11-24/reports/V715_world3d_fx.md
code: variant3d/scripts/world3d_fx.gd (NEW — the only file edited by this agent)
governing_rule: WAVE7 charter :29-38 — translate donor, do not invent; UNVERIFIED where no readable source
scope: SINGLEPLAYER SKIRMISH ONLY (D-12); no donor binaries; DONOR private-use read-only
verification: variant3d godot_runner.py, headless --script parse/API smoke check (see §5)
---

# V7-15 — `world3d_fx.gd` (3D FX, ghost, rally)

## 1. Files owned

| Path | Status |
|---|---|
| `variant3d/scripts/world3d_fx.gd` | NEW, created by this agent |
| this report | NEW, created by this agent |

No sim file, no 2D file, no other `variant3d/scripts/*` file, no scene, shader, config or asset was edited. The temporary runner test script used for verification was deleted after the run.

## 2. Exact API implemented

`extends Node3D`. Signatures are exactly those in `V73_ATOMIC_CONTRACT.md:14`:

| Method | Behaviour |
|---|---|
| `bind(game)` | Stores the sim reference, resets the event high-water index, lazily builds the three `Node3D` roots (`FX3D`, `BuildGhost3D`, `Rally3D`). Never mutates `game`. |
| `sync(dt)` | Peeks `game.events` (high-water index, non-destructive), emits arrow trails from `game.projectiles`, ages every FX item, animates transform/alpha/light, expires items, expires stale rally markers, pulses the ghost. |
| `add_fx(pos, kind, life) -> Dictionary` | Spawns one procedural FX item. `life <= 0` selects the port lifetime table; enforces `Data.FX_CAP` (`data.gd:117`, default 220). Returns the item dictionary (useful to callers; not required by the contract). |
| `draw_ghost(sid, pos, ok: bool)` | Updates a single persistent translucent green/red footprint. Empty `sid` or non-finite `pos` hides it. Radius read from `Data.BUILDINGS[sid].radius` with a 1.5 m fallback. |
| `draw_rally(pos, player: int)` | Creates/updates a procedural pole + pennant marker, keyed by a 0.5 m-snapped XZ position; colour from the port player palette. |

Extra non-contract conveniences (do not change the required API): `clear_all()`, `world_pos(p)`, public flags `consume_events`, `emit_arrow_trails`, `world_offset`, `height_bias`, and read-only `stats` / `fx_items`.

## 3. Implementation shape

- **FX** are `MeshInstance3D` children under a `Node3D` holder per event, with a shared `StandardMaterial3D` (unshaded, alpha-blended or additive, cull disabled) and, for flashes, a `PointLight3D`. No `GPUParticles3D` server dependence: all animation is CPU-side deterministic math over `age / life`, so headless runs are measurable.
- **Kinds** map to primitives: `shot` = emissive sphere + light; `smoke` = two crossed quads, rising and growing; `explode` = sphere + light; `crater` = flat disc; `fire` = crossed quads + light with deterministic flicker; `heal` = flat torus ring; `capture`/`rout`/`chop` = quads/box; `trail` = oriented thin box between projectile head and tail.
- **No RNG**: drift/flicker use `sin(age * f + spawn_index)`.
- **Coordinate convention**: map positions are `Vector2` metres (`game.TILE = 2.0`, `game.gd:16`); `world_pos()` samples `game.height_at(p)` (`game.gd:1893-1907`) and returns `Vector3(p.x - world_offset.x, h + height_bias, p.y - world_offset.y)`. A `Vector3` argument is passed through unchanged, so the integration owner can feed already-transformed scene coordinates. `world_offset` exists because the terrain module centres its dump window at the origin (`world3d.gd:215-216`).
- **Water**: deliberately NOT touched. The spatial water shader plane is owned by `world3d.gd:_make_water` (`:345-406`); no water re-bake and no second plane is created here. Donor water constants are documented in `docs/audit/TERRAIN_DONOR_WATER.md:72-90` and are out of this module's scope.

## 4. Donor evidence and disposition

All donor reads were plain-text, read-only; no donor binary was run or copied. Path prefix for PFX: `C:\Games\Cossacks 3\data\pfx\source.pfx` (private-use). V7-2 reports PFX semantics as **UNMAPPED**, so every PFX-derived number below is a **literal key read with UNVERIFIED runtime semantics** — not a claim of donor parity.

| Item in this module | Evidence | Label / honest limit |
|---|---|---|
| FX existence (smoke/flash/trail/explosion) | `source.pfx:33-63` `musketsmoke`; `:105-177` `musketflash`; `:377-411` `cannonsmoke`; `:1313-1415` `cannonexp`; `:1731-1766` `bullettrail` | **LITERAL KEYS READ / SEMANTICS UNVERIFIED**. Donor uses `animatedsprite` and `trail` structs; the port uses procedural primitives, not copied PFX sprites. |
| Smoke look/timing anchors | `source.pfx:41-62` EndFrame 127, 256×128 frames, Interval 10, PixelRatio 175, AlphaTime 1.5, AlphaPower 1.5 | **UNVERIFIED** mapping to seconds/metres. Port life 1.6 s comes from `world.gd:3567`, not from donor. |
| Muzzle-flash anchors | `source.pfx:112-176` four frames, Interval 100, FrameRate 10, PixelRatio 350, `OnEndFrameHide = True` | **UNVERIFIED** frame→second conversion. Port `shot` life 0.35 s from `world.gd:3564`. |
| Trail anchors | `source.pfx:1739-1746` `TimeLimit = 0.2`, `Alpha = 0.2`, `AlphaFade = True`, `MarkStyle = msFaceCamera`, `MarkWidth = 0.1` | Literal keys quoted as `TRAIL_TIME_LIMIT`, `TRAIL_ALPHA`, `TRAIL_WIDTH_M`; whether 0.1 means metres or pixels is **UNVERIFIED**. Streak length 1.2 m is a **PORT approximation** (no donor length key). |
| Explosion anchors | `source.pfx:1322-1415` EndFrame 255, PixelRatio 30, AlphaTime 1.2, AlphaPower 1.0 | **UNVERIFIED** semantics; port explode/crater life 0.8 s from `world.gd:3568-3569`. |
| Event names and pos semantics | `game.gd:2823` (`events.append({"type","pos","kind","extra"})`), `main.gd:1518-1554` (`_consume_events` forwards shot/smoke/heal/rout/crater/explode/chop) | **SHARE** (read-only). Sim-agnostic stream; no sim edits. |
| FX lifetimes | `world.gd:3563-3579`, `:3559` | **PORT precedent**, not donor truth. |
| FX cap | `data.gd:117` `FX_CAP = 220` (quality tier `:158`) | **PORT data**, read-only. |
| Ghost colour / shape | `world.gd:3509` (green `0.2,1,0.3,0.5` / red `1,0.25,0.2,0.5`), `Data.BUILDINGS[sid].radius` at `world.gd:3495,3513` | **PORT precedent**. No donor ghost config was readable → **UNVERIFIED** donor parity. |
| Rally marker | No `rallypoint` section found in `source.pfx`; donor `rallypoint.dds` is private-use and uncopied (`world.gd:3602-3604` says the same). Pole/pennant colours follow `world.gd:3623-3629` and palette `world.gd:2172-2179` (from hud.gd `MM_PLAYER_COLORS`) | **PROCEDURAL PRIMITIVE — NOT DONOR ART**. Explicitly labelled in code. |
| Player palette | `world.gd:2172-2179`, 12 slots with `wrapi` fallback at `:2181` | **PORT palette copied read-only**, not donor. |
| Water | `docs/audit/TERRAIN_DONOR_WATER.md:72-90`; plane at `world3d.gd:345-406` | Not owned here; no re-bake. |

The V7-1 inventory explicitly lists "FX particle constants" as **UNVERIFIED** (`V71_mechanics_inventory.md:161,176`) and states that no donor FX config was readable; this module follows that disposition by quoting literal donor keys while refusing to claim translated values.

## 5. Verification — what was MEASURED

All Godot launches went through `variant3d/tools/godot_runner.py` (contract `:37`). A temporary `variant3d/tests/t_v715_parse_tmp.gd` loaded the module with `load()`, instantiated it, and asserted the API; it was **deleted after the run** (git status confirms no temporary test remains).

| Attempt | Runner job | Result |
|---|---|---|
| 1 | `v715-parse`, ticket 21 | **FAILED**. stderr showed two real parse errors in this module: `Could not find type "PointLight3D"` (Godot 4.7.2 uses `OmniLight3D`), and `Identifier "_fx_items" not declared` (the public array is `fx_items`). The temporary test then kept running after `scr.new()` errored, so the runner hit its hard 120 s timeout. Both defects were fixed in `world3d_fx.gd`; the test was hardened to quit on load failure. |
| 2 | `v715-parse2`, ticket 31 | **PASSED** (`END ok`, run 3.62 s, stderr empty). stdout: `RESULT api=true spawn=2 events=1 ghosts=1 expired=2`. |

What attempt 2 literally measured (headless, Godot 4.7.2.stable, `--headless --path variant3d --script ...`):

- `load("res://scripts/world3d_fx.gd")` succeeds and `can_instantiate()` is true — **parse verified**.
- Instance `is Node3D`; **all five required methods present** (`bind`, `sync`, `add_fx`, `draw_ghost`, `draw_rally`); `api=true`.
- `bind(null)` then `add_fx(Vector2(1,1), "smoke", -1.0)` → non-empty item, `fx_items.size()==1`; `sync(0.1)` advanced the item's `age` to 0.1 s.
- A fake game object with `events = [{"type":"shot","pos":Vector2(2,2),...}]` and `height_at()` → after `bind(fake)` + `sync(0.0)`, `stats.events_consumed == 1` and total `spawned == 2` (the smoke plus the consumed shot event) — **event peek works without clearing the array**.
- `draw_ghost("house", Vector2(3,3), true)` → `stats.ghost_shown == 1`.
- `draw_rally(Vector2(4,4), 1)` → `stats.rally_active == 1`; after `sync(3.0)` it returned to `0` (RALLY_TTL expiry) and both FX items expired (`expired=2`).
- `clear_all()` left `fx_items` empty.
- **No stderr output** in the passing run (no runtime errors/warnings from the module).

**Not measured**: rendered 3D appearance, visual donor parity, material/light correctness on screen, GPU behaviour, mass-army performance, and any interaction with the composed `world3d.gd` — this was a headless parse/API/state check only. No claim of visual equivalence is made. The runner's spool directories under `variant3d/.godot_queue/results/` are tool artifacts, not source edits.

## 6. Open questions

1. **Event-consumption ownership.** `main.gd:1514-1564` clears `game.events`; this module peeks with a high-water index and never clears. If the integration owner lets main forward `add_fx()` to this module *and* leaves `consume_events = true`, FX will double-spawn. Integration must either call `fx.sync()` before `main._consume_events()`, or set `fx.consume_events = false` and forward explicitly.
2. **PFX semantics remain UNMAPPED** (V7-2). The literal trail/smoke keys are quoted, but conversion to Godot seconds/metres is an assumption; visual A/B against the donor is not possible headlessly.
3. **World offset.** The terrain module builds a centred dump window (`world3d.gd:215-216`) while sim positions are map-origin metres. `world_offset` must be set by the integration owner; it defaults to zero, so FX land at raw map coordinates until then.
4. **Rally TTL (2 s)** is a port choice with no donor key; if callers redraw rally markers less often than every 2 s, markers will blink out. Adjust or disable `_update_rally()` at integration time.
5. **Trail visual fidelity.** The 2D baseline admits the arrow trail is a CPU-only gap (`t_smoke_fx.gd:146-173`; `selftest.json:62` "smoke missing"). This module emits trails from `game.projectiles`, but donor trail art is a PFX `trail` struct with `msFaceCamera`; the box streak is an approximation.
6. **Rally art** is procedural by necessity — donor `rallypoint` art is private-use. No donor-parity claim is made.

---

**End of report.**
