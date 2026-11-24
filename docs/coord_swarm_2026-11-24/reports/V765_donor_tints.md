---
id: V7-65
owner: V7-65
date: 2026-11-24
scope: "variant3d/scripts/world3d_entities.gd and variant3d/scripts/world3d_fx.gd only — consume variant3d/data/donor_key_colors.json (V7-61) for player-slot entity tints and player-coloured FX; diagnose/fix the relayed V7-67 stderr parse errors in world3d_entities.gd."
status: "COMPLETE — donor-value assertions measured 21/21; parse clean; selftest passed:true 29/29; NO visual parity claim"
governing_rule: "AUDIT3D_CHARTER.md:6-15 — path:line evidence, OBS vs INFERENCE, UNVERIFIED labels, smallest donor-grounded fix, no git operations."
owns: ["variant3d/scripts/world3d_entities.gd", "variant3d/scripts/world3d_fx.gd", "docs/coord_swarm_2026-11-24/reports/V765_donor_tints.md"]
godot_runs: "tickets 94, 100, 101, 105, 115, 116, 122 (variant3d/tools/godot_runner.py only); ticket 86 stderr read-only for diagnosis"
---

# V7-65 — donor player-slot tints in the 3D variant

## 1. What changed (scope discipline)

- Edited **only** `variant3d/scripts/world3d_entities.gd`, `variant3d/scripts/world3d_fx.gd`, and this report.
- **No** edits to `world3d.gd` (V7-62), `anim3d.gd` (V7-64), `hud.gd`, `app/`, config, data JSON or selftest. `variant3d/selftest.json` was rewritten **by the mandated selftest command itself** (generated output, not a source edit).
- No git command was run. The temporary probe (`variant3d/tests/_v765_probe.gd`, its `.uid` and `tests/results/v765_probe.json`) was **deleted** after measurement.
- **No visual parity claim** is made: nothing was rendered, screenshotted or compared to the donor.

## 2. Donor citations (read-only, from V7-61 / AUDIT3D-02)

| Claim | Donor `path:line` (OBS) |
|---|---|
| Key-colour table `GetKeyColorByPlayerIndex`, default `koef := 1.1`, cases 0..13, `r/g/b = channel*koef/255` | `C:\Games\Cossacks 3\data\scripts\lib\classes.script:7986-8015` (formula `:8012-8014`, default `:7988`) |
| `gKeyColor` array + population loop | `classes.script:7685`, `:8091-8092` |
| `gc_MaxColorCount = 13` (only slots 0..12 applicable); `gc_MaxKeyColorCount = 24` | `data\scripts\dmscript.global:121-122` |
| Guard: tint applied only when `0 <= colorInd < 13`; uniform slot **0**, components `[0],[1],[2]` | `data\scripts\lib\misc.script:5067-5081` (guard `:5070`, call `:5073`) |
| Recursive application to units and buildings | `unit.script:3860`; `player.script:2971` |
| Table is keyed by **player slot**, not nation: `mapplayer.color := ind`; mercenary forced to `gc_MaxColorCount-1` = 12 | `data\scripts\lib\map.script:123`, `:136-137` |
| Machine-readable extraction (13 slots, exact floats + clamped variants) | `variant3d/data/donor_key_colors.json` (V7-61 report §4/§5) |

The implementation reads the JSON at runtime via `FileAccess.get_file_as_string()` + `JSON.parse_string()`, and uses `slots[i].rgb_godot_float` (the exact donor-formula output) as `Color(r, g, b, 1.0)`.

## 3. Exact player-slot mapping — evidence from the 2D app/game truth

**Found (not invented): identity mapping `entity.player → donor gKeyColor slot`.**

| # | Evidence | `path:line` |
|---|---|---|
| E1 | `spawn(sid, player, pos)` writes the raw argument into the entity dict: `"player": player`; the same index selects `players[player]` for hp/bonuses. | `app/scripts/game.gd:1988-1992`, `:2001-2003` |
| E2 | `setup_begin()` builds `players` by looping `for i in count` and calling `new_player(i, ...)`; therefore a player's array index **is** its slot number. `Data.TEAMS` is a separate alliance key, not a colour key. | `app/scripts/game.gd:378-389`; `new_player` `:288-304` |
| E3 | The 2D renderer indexes its palette **directly by `e.player`**: `_player_color(p) -> PLAYER_COLORS[wrapi(p,0,size)]`, called at building flags/stripes/rings and unit rings. | `app/scripts/world.gd:2172-2182`, `:2845`, `:3018`, `:3094`, `:3103`, `:3240`, `:3432`, `:3614` |
| E4 | `NATIONS` has **no colour field** (only `name`/`no18c`), so no nation→colour mapping exists to substitute. | `app/scripts/data.gd:225-239` (comment `:226` is stale) |
| E5 | Port cap is 12 slots (`MAX_PLAYERS := 12`, player slots 0..11); donor has 13 with slot 12 reserved for mercenary. | `app/scripts/data.gd:184`; donor `map.script:136-137` |

Consequences implemented:
- Unit/building `e.player` is used **as-is** as the donor slot index (identity). No nation lookup, no modulo/`wrapi()` remap, no invented permutation.
- Slots outside the donor guard (`p < 0` or `p >= 13`) are **untinted**, mirroring `misc.script:5070`. Port games normally only produce 0..11; slot 12 remains available for a mercenary-tagged entity if one is ever spawned.
- If the JSON is missing/malformed: `push_error()` once in `bind()` and **no tint at all** — no fallback palette in either module.

## 4. Diff (final file:line)

### `variant3d/scripts/world3d_entities.gd`

| Line(s) | Change |
|---|---|
| 59 | `const KEY_COLORS_PATH := "res://data/donor_key_colors.json"` (donor citations in comment) |
| 100-102 | New state: `_key_colors: Array`, `_key_colors_loaded`, `_key_colors_error` |
| 108 | `bind()` calls `_load_key_colors()` |
| 156-163 | `stats` gains donor path/loaded/slots/error, mapping, target (`albedo_color`, uniform-0 analogue), alpha 1.0 and UNVERIFIED flags |
| 217-247 | `_load_key_colors()` — FileAccess + JSON; 13 slot colours from `rgb_godot_float`, alpha 1.0; push_error + untinted on every failure path |
| 250-255 | `_player_tint(player) -> Variant` — donor guard (0..12), else `null` |
| 257-264 | `_player_index(ed)` — defensive read of `e.player` (int/float) |
| 266-279 | `_tinted_material(base, tint, sid, kind)` — duplicates the surface's donor-albedo material and sets `albedo_color = tint`; texture preserved |
| 282-304 | `_apply_tint(instance: GeometryInstance3D, ...)` — **MultiMeshInstance3D** (a GeometryInstance3D, *not* a MeshInstance3D in Godot 4) gets `material_override`; building MeshInstance3Ds get per-surface overrides |
| 429-430 | `_mesh_info()` caches `sid`/`kind` in mesh info for the cloning step |
| 458-469 | `_acquire(..., tint: Variant = null, player: int = -1)` — internal-only extension; new batches store `tint`/`player` and are tinted once at creation |
| 575-594 | `add_unit(e)` — batch key becomes `"unit|<sid>|p<player>"` when a donor tint exists; passes tint/player to `_acquire`. **Signature unchanged.** |
| 604-634 | `add_building(e)` — per-building surface-override tint + meta `donor_tint_slot` / `donor_tint_rgb`. **Signature unchanged.** |
| 660-682 | `add_resource(n)` / `remove(id)` — **logic unchanged**; resources pass the default `tint=null`, so resources stay untinted. Signatures unchanged. |
| 698-739 | `sync(dt)` — unchanged transform loop; adds measured `tinted_batches` / `tinted_buildings` counters. Signature unchanged. |

Public API check: `bind(g)`, `sync(dt)`, `add_unit(e)`, `add_building(e)`, `add_resource(n)`, `remove(id)` are byte-for-byte the same signatures (V7-62 wiring safe).

### `variant3d/scripts/world3d_fx.gd`

| Line(s) | Change |
|---|---|
| 62-77 | **Removed** the invented 12-colour `const PLAYER_COLORS` literal (old lines 67-74, copied from `app/scripts/world.gd:2172-2179`). Added `KEY_COLORS_PATH`, `var PLAYER_COLORS: Array`, load state. `GHOST_OK`/`GHOST_BAD` (:69-70) explicitly marked non-player and left untouched. |
| 121-126 | `bind()` calls `_load_player_colors()` and records donor telemetry in `stats` |
| 129-163 | `_load_player_colors()` — same FileAccess + JSON path, same 13 `rgb_godot_float` values, same no-fallback failure policy |
| 668-673 | `_player_color(p)` — donor guarded indexing (`PLAYER_COLORS[p]`), **no `wrapi()` fallback**; on load failure returns transparent `Color(0,0,0,0)` (no colour invented) |

FX caller/dependency map (all verified by grep over `variant3d/scripts/**`):
- `bind(g)` → `_load_player_colors()` (fx:121); called from `world3d.gd` integration (V7-62).
- `_player_color(p)` callers: `_make_rally()` at fx:513 (pennant material) and `_set_rally_color()` at fx:524 (recolour an existing marker). Reached via public `draw_rally(pos, player)` at fx:235.
- **Inherited gap:** `draw_rally(` has **no external caller** in `variant3d/scripts/**` (only its definition and this module's own comment) — same as AUDIT3D-02 row 14. The palette is donor-correct but is not exercised by default game rendering; wiring it is V7-62's lane.
- Non-player FX left as-is: `_kind_color()` fx:402 (shot/smoke/explode/crater/fire/heal/capture/rout/chop/trail), `_build_visual()` fx:429, `GHOST_OK`/`GHOST_BAD` fx:69-70 and `_update_ghost()` fx:620, rally pole/finial/foot colours in `_make_rally()` fx:493-511. The green/red build ghost is a **build-validity** cue with no `player` argument; it is not player-coloured, so it was not changed despite "ghost" appearing in the task's parenthesis.

## 5. Relayed V7-67 diagnosis (ticket 86) — before / after

**Before** — `variant3d/.godot_queue/results/00000086_v767-hud-minimap/stderr.txt:1-15` (V7-67's selftest, read-only):

```
SCRIPT ERROR: Parse Error: The variable type is being inferred from a Variant value, so it will be typed as Variant. (Warning treated as error.)
   at: GDScript::reload (res://scripts/world3d_entities.gd:573)
SCRIPT ERROR: Parse Error: The variable type is being inferred from a Variant value, so it will be typed as Variant. (Warning treated as error.)
   at: GDScript::reload (res://scripts/world3d_entities.gd:606)
ERROR: Failed to load script "res://scripts/world3d_entities.gd" with error "Parse error".
ERROR: world3d: cannot instantiate res://scripts/world3d_entities.gd
```

Diagnosis (not suppression): both were `INFERRED_DECLARATION` warnings promoted to errors. The two sites were `var tint := _player_tint(player)` in `add_unit`/`add_building`; `_player_tint()` deliberately returns `Variant` so `null` can mean "no tint", so `:=` inferred a Variant. Consequence: the whole entity script failed to load, and 3D entities silently did not exist in that run.

**Fix:** explicit `var tint: Variant = _player_tint(player)` at final `world3d_entities.gd:590` and `:624`. No behaviour or signature change.

**After** — ticket 122 stderr (the mandated final selftest) contains **no** parse error, no "Failed to load script", no "cannot instantiate":

```
WARNING: world3d_entities: STATIC BIND POSE - PORT APPROXIMATION - NOT DONOR PARITY (...)
   at: push_warning (...world3d_entities.gd:165)
WARNING: 12 ObjectDB instances were leaked at exit ...
ERROR: 3 resources still in use at exit ...
```

The `world3d.gd:207` "Nonexistent 'int' constructor" lines present in ticket 86 are **not** in ticket 122; that file is V7-62's, so no change was made here by V7-65.

A second genuine defect was found and fixed during the probe (ticket 105): `MultiMeshInstance3D` is **not** a subclass of `MeshInstance3D` in Godot 4, so calling `_apply_tint(instance: MeshInstance3D, ...)` on a batch produced `Invalid type in function '_apply_tint' ... not a subclass of the expected argument class`, which cascaded into `Invalid assignment of index '0' (on base: 'Array') with value of type 'Transform3D'` at `add_unit` and a hanging probe. `_apply_tint()` now takes `GeometryInstance3D` and branches: `material_override` for MultiMesh batches, per-surface overrides for building MeshInstance3Ds. Ticket 116 rerun was clean.

## 6. Verification (variant3d runner only — job ids and measured results)

| Ticket | Job id | Command / purpose | Measured result |
|---|---|---|---|
| 94 | `v765-entities-parse` | `--headless --path variant3d --check-only --script res://scripts/world3d_entities.gd` | **ok**, exit 0, run 3.30 s (waited 276.83 s). Parsed the post-Variant-fix file. |
| 100 | `v765-entities-parse-final` | same, final file pre-MultiMesh fix | **ok**, exit 0, run 3.52 s |
| 101 | `v765-fx-parse` | `--check-only --script res://scripts/world3d_fx.gd` | **ok**, exit 0, run 3.70 s |
| 105 | `v765-probe` | temporary probe, first run | **timed-out** (exit -9, run 122.54 s) — found the MultiMeshInstance3D defect; superseded, not a code regression |
| 115 | `v765-entities-parse-fix` | `--check-only --script res://scripts/world3d_entities.gd` after the GeometryInstance3D fix | **ok**, exit 0, run 3.60 s |
| 116 | `v765-probe2` | `--headless --path variant3d --script res://tests/_v765_probe.gd` | **ok**, exit 0, run 4.29 s; **21/21 checks passed**; stderr contains only the pre-existing ANIM_STATUS `push_warning` |
| 122 | `v765-donor-tints` | `--headless --path variant3d -- --self-test variant3d/selftest.json` | **ok**, exit 0, run 51.03 s; `variant3d/selftest.json` = `passed: true`, **29/29 steps passed** (verified by JSON count), stderr free of the ticket-86 errors |

### Measured colour assertions (probe, ticket 116; result JSON read before deletion)

Donor slot values loaded from JSON: slot 0 `[0.739607843, 0.0, 0.0]`, slot 1 `[0.070588235, 0.4, 0.903529412]`, 13 slots available in both modules.

| Assertion | Measured |
|---|---|
| Entity JSON loaded | `slots=13`, error empty |
| Unit batch keys split by player | `["unit|peasant|p0", "unit|peasant|p1"]` |
| Unit **batch tints differ** | `(0.7396, 0, 0, 1)` vs `(0.0706, 0.4, 0.9035, 1)` |
| Unit batch slot 0 / slot 1 match donor | PASS / PASS (tolerance 1e-4) |
| Unit **material overrides exist and differ** | two distinct `StandardMaterial3D`; `albedo_color` `(0.7396,0,0,1)` vs `(0.0706,0.4,0.9035,1)` |
| Unit material slot 0 / slot 1 match donor | PASS / PASS |
| Building nodes exist and tints differ | `r0=[0.73960787057877,0,0]`, `r1=[0.07058823853731,0.40000000596046,0.90352940559387]` |
| Building slot 0 / slot 1 match donor | PASS / PASS (float32 storage drift only) |
| Building surface-override materials differ | two distinct `StandardMaterial3D` |
| Entity stats | `tinted_batches=2`, `tinted_buildings=2` |
| FX player colours differ and match donor slots | `(0.7396,0,0,1)` vs `(0.0706,0.4,0.9035,1)` — PASS / PASS |
| Non-player FX unchanged | `smoke=(0.85,0.85,0.82,0.55)` — unchanged |

The probe fed players 0 and 1 into `add_unit`/`add_building` with the **same** `sid` (`peasant` / `hou`), so a shared material would have failed the DIFFER assertions.

## 7. Open questions / UNVERIFIED

1. **Alpha — UNVERIFIED (donor).** `GetKeyColorByPlayerIndex` returns no alpha; `misc.script:5069,5072` assigns `a := 1` only for texture format 2 and otherwise leaves it unassigned. This implementation uses **alpha 1.0 as an explicit port choice** for opaque materials (and for the FX pennant). Not donor-derived.
2. **Values >1.0 — UNVERIFIED downstream.** Slot 4 R = 1.2; slot 6 G = 1.072941176, B = 1.2. The donor script performs no clamp (`classes.script:8012-8014`). We use `rgb_godot_float` (exact donor numbers, Godot `Color` stores HDR); whether the donor engine or Godot's renderer clamps at shader time is not in readable text. `rgb_display_clamped` is present in the JSON but unused. Owner sign-off needed if clamped display values are preferred (V7-61 §6.3, AUDIT3D-02 Q2/Q3).
3. **Uniform-0 operation — UNVERIFIED.** We replicate it as a multiplicative `albedo_color` tint over the donor albedo texture; no donor shader fragment implementing uniform 0 was identified. Additive/palette-swap semantics cannot be excluded.
4. **Multi-surface meshes — partial.** MultiMesh batches use one `material_override` built from **surface 0**'s donor material; a donor OBJ/GLB with several differently-textured surfaces will have those materials flattened into one tinted material. Buildings keep per-surface overrides. Not measured here (probe used the single-material/no-material path).
5. **Mercenary slot 12** is representable by the identity mapping but is unreachable in normal 2D-generated games (`MAX_PLAYERS = 12`, slots 0..11). No mercenary flag exists in the port sim, so this was not invented.
6. **FX rally still unwired** — `draw_rally()` has no caller outside `world3d_fx.gd` (inherited AUDIT3D-02 G3). Player-colour FX is donor-correct at the palette level but not visibly exercised by default rendering.
7. **No visual parity claim** — verification is structural/numeric only (script parse + headless material/colour assertions + selftest). No screenshots were taken and no donor render was compared.

## 8. Reply summary

- Files: `variant3d/scripts/world3d_entities.gd`, `variant3d/scripts/world3d_fx.gd` — **STATUS: COMPLETE**.
- Report: `docs/coord_swarm_2026-11-24/reports/V765_donor_tints.md`.
- Verification: parse ok (tickets 100/101/115), probe 21/21 (ticket 116), selftest `passed: true` 29/29 (ticket 122).
- Relayed V7-67 parse errors fixed at final lines 590 and 624 (explicit `Variant` type); no suppression.
