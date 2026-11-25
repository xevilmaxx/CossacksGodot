---
title: CONFIG-CORE-01 — global feature config defaults + readers in config.gd
task: CONFIG-CORE-01
owner: implementation builder (subagent)
status: DONE
scope: "variant3d/scripts/config.gd + this report only"
---

# CONFIG-CORE-01 — global feature config defaults + readers

Reader-side groundwork for the owner's "all main features configurable via global
JSON" goal. `config.json` is owned by MAP-SMALL-01 and is **not** touched here;
this ticket only adds safe defaults and typed accessors, so a later JSON
`features` object will work without breaking any current run.

## 1. Change map (file:line, before → after)

`variant3d/scripts/config.gd` — **116 insertions, 0 deletions** (purely additive;
no existing default, symbol, or control flow was changed).

| Before | After | Hunk |
|---|---|---|
| `config.gd:41` (blank) / `:42` `# The base values…` | `config.gd:42-84` | New `FEATURES_DEFAULTS` const + CONFIG-CORE-01 comments inserted; old `:42-43` comment moved to `:86-87`. |
| `config.gd:44` `const DEFAULT := {` | `config.gd:88-89` | `const DEFAULT` moved to `:88`; new top-level `"features": FEATURES_DEFAULTS,` at `:89`. |
| `config.gd:363-367` (`section()` end) / `:369` `# ---- applying` | `config.gd:411-485` | New "feature readers" block (`:414-483`, 21 typed getters); applying header moved to `:485`, `apply()` to `:489`. |

`apply()` was **not** modified — no consumer is wired by this ticket.

## 2. Key table (defaults = today's verified behaviour)

All keys live under the new top-level `features` table. Each getter walks
`data` through the existing `value()`/`num()`/`flag()`/`text()` helpers, i.e.
`get(key, default)`-style lookup; a missing key (or a missing `features`
section, or no `load_all()` at all) returns the literal fallback below.

| Config path | Default | Typed getter (line) | Citation / label |
|---|---|---|---|
| `features.selection.world_epsilon_m` | `0.005` | `feature_selection_world_epsilon_m() -> float` (`:420`) | DSEL-01: `data\gui\menu.inc\onmousemove.inc:32`; SEL_01 `:203-204` |
| `features.selection.attack_epsilon_m` | `0.25` | `feature_selection_attack_epsilon_m() -> float` (`:423`) | DSEL-01: `onmousemove.inc:33-34` (attack-point / guard) |
| `features.selection.marquee_color` | `[1,1,0,1]` | `feature_selection_marquee_color() -> Array` (`:426`) | DSEL-01: `brushes\selection.cfg:3-14` (yellow) |
| `features.selection.marquee_width_px` | `1` | `feature_selection_marquee_width_px() -> int` (`:430`) | DSEL-01: `brushes\selection.cfg:3-14` `LineWidth=1` |
| `features.selection.double_click_s` | `0.5` | `feature_selection_double_click_s() -> float` (`:433`) | DSEL-01: `data\gui\menu.cfg:33` `KeyDoubleDelay` |
| `features.terrain.texgen_mode` | `"world_xz"` | `feature_terrain_texgen_mode() -> String` (`:436`) | TRN-SHADER A1; **PORT APPROX** (RV-TRN-01 verdict A) |
| `features.terrain.m_per_tile` | `2.0` | `feature_terrain_m_per_tile() -> float` (`:439`) | `dmscript.global:171` `gc_meters_to_tile=2` (DTRN-01 / DEC-05) |
| `features.terrain.lighting` | `"donor"` | `feature_terrain_lighting() -> String` (`:442`) | DENV-01: `env\lights\light.cfg:17` `lsParallel`; TRN-SHADER B1 |
| `features.terrain.alpha_patch_mode` | `"donor_approx"` | `feature_terrain_alpha_patch_mode() -> String` (`:445`) | DALPHA-02: tile→patch index UNVERIFIED, **PORT APPROX** |
| `features.terrain.relief_stamps` | `false` | `feature_terrain_relief_stamps() -> bool` (`:448`) | RELIEF-01: opt-in dump marker, default off |
| `features.terrain.tile_diversity` | `true` | `feature_terrain_tile_diversity() -> bool` (`:451`) | Current port behaviour (V3D-02 F3; unchanged) |
| `features.water.surface_y` | `-0.25` | `feature_water_surface_y() -> float` (`:454`) | TRN-WATER **PORT APPROX** placeholder; DTRN-03 §9 |
| `features.water.alpha_confine` | `true` | `feature_water_alpha_confine() -> bool` (`:457`) | TRN-WATER: donor water-cell alpha gate kept |
| `features.water.shore_prox` | `false` | `feature_water_shore_prox() -> bool` (`:460`) | TRN-WATER: inert port-art multiplier removed |
| `features.weather.snow` | `false` | `feature_weather_snow() -> bool` (`:463`) | FX-WEATHER-01: `clouds.weather:3` `Weather=40` < snow band `70..100` |
| `features.camera.fov_deg` | `17.27` | `feature_camera_fov_deg() -> float` (`:466`) | **PORT APPROX / UNVERIFIED** (RV-CAM-01); `camera3d.gd:65` |
| `features.hud.minimap_size` | `240` | `feature_hud_minimap_size() -> int` (`:470`) | DEC-08: `initminimap.inc:5-7` `cMinimapSize=240` |
| `features.hud.minimap_inset` | `-8` | `feature_hud_minimap_inset() -> int` (`:473`) | DEC-08: `initminimap.inc:5-7` `cMinimapOffsetX/Y=-8` |
| `features.hud.minimap_corner` | `"bottom_right"` | `feature_hud_minimap_corner() -> String` (`:476`) | DEC-08: `initminimap.inc:17` (right/bottom anchor) |
| `features.render.fog` | `false` | `feature_render_fog() -> bool` (`:479`) | DENV-01 §3.9 `FogMode` ambiguity; keep off |
| `features.gameplay.fog_of_war` | `false` | `feature_gameplay_fog_of_war() -> bool` (`:482`) | CFG-01: `display.fog_of_war` default `false` |

Defaults table source: `config.gd:46-84`. Getter block source: `config.gd:414-483`.
Note `features.gameplay.fog_of_war` is deliberately **not** the existing
`display.fog_of_war` key — it is a new, additive namespaced key and `apply()`
still reads only `display.fog_of_war`.

## 3. Backup

| Item | Value |
|---|---|
| File | `inbox/backup/config.gd.bak-CONFIGCORE01` |
| Taken | before the first edit (plain copy of `variant3d/scripts/config.gd`) |
| SHA-256 (backup and pre-edit source) | `F0284F90B61E813CE694ADDFF00F3D13F90E6CC54E00CC34CBF5BF6C50E66D0A` |

Restore is a plain file copy back over `variant3d/scripts/config.gd` if this
ticket is rejected.

## 4. Validation — variant runner only

**Command (Windows `python`, no direct `godot`, no gates, no ladder):**

```powershell
python variant3d\tools\godot_runner.py run --id configcore01-smoke --timeout 180 --max-wait 1800 -- --headless --path variant3d --check-only --script res://scripts/config.gd
```

| Field | Value |
|---|---|
| Ticket / id | 419 / `configcore01-smoke` (unique) |
| argv | `--headless --path variant3d --check-only --script res://scripts/config.gd` |
| wait / run | 96.77 s / 5.52 s |
| status / exit | `ok` / `0` |
| stdout | 75 B — `Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org` |
| stderr | **0 bytes** |
| `SCRIPT ERROR` occurrences (stdout + stderr) | **0** |

`SCRIPT ERROR == 0` — confirmed (observed; `variant3d/.godot_queue/results/00000419.json`
and `00000419_configcore01-smoke/`). `--check-only` parses/validates the script;
it does not execute `load_all()` or a runtime getter call. No selftest/uitest,
no capture, no terrain ladder.

## 5. Ownership / untouched files — explicit

- `variant3d/config.json` — **NOT edited** (owned by MAP-SMALL-01).
- `menu.gd`, `data.gd`, `game.gd`, `input_controller.gd`, `hud.gd`, any test file,
  and `app/**` — **NOT edited**.
- **No consumer wired.** No other file calls a `feature_*` getter; `apply()` is
  unchanged. This ticket delivers defaults + readers only; consuming call sites
  are separate tickets.
- No existing default, constant, function name, or signature was renamed or
  altered; the diff contains only insertions.

## 6. Open questions

1. **JSON schema** — the exact `features` object shape in `config.json` is owned
   by the JSON ticket. Getters accept any subset: unknown/missing keys fall back
   to the constants above, and `_merge()` handles the new top-level table.
2. **Getter names** — `feature_<group>_<key>()` are new (`config.gd:420-484`);
   consuming tickets need to agree on these names before wiring.
3. **Number coercion** — `_copy()` (`config.gd:354-374` in the after-file)
   converts whole-number floats to ints, so `m_per_tile: 2.0` becomes `2` inside
   `data.features`. The typed `num()` getters return `2.0`; a raw reader of
   `data.features.terrain.m_per_tile` would see an int. Flagged for the JSON
   owner — no code change made here.
4. **String modes are unvalidated** — `"world_xz"`, `"donor"`, `"donor_approx"`,
   `"bottom_right"` pass through as-is (no allow-list, unlike `_donor_id()`).
   Validation/allowed values belong to the consumer tickets.
5. **Opt-in semantics** — `relief_stamps`, `snow`, `fog`, `shore_prox` default to
   today's off/removed state; enabling them is a deliberate consumer-side
   decision, not tested here.

## 7. Summary

Added a namespaced global `features` config table (21 keys) to `config.gd` with
donor-cited, behaviour-preserving defaults and 21 typed getter helpers that use
`get(key, default)`-style fallbacks. Purely additive (116 insertions, 0
deletions); `apply()` and every other file, including `config.json`, remain
byte-unchanged. Variant-runner smoke job `configcore01-smoke` (ticket 419) ended
`ok`/exit `0` with `SCRIPT ERROR == 0`.
