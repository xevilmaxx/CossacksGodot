---
id: WEATHER-DRIVER-01
task: "Wire the menu/config weather value to the donor-snow API (additive helper only)"
owner: WEATHER-DRIVER-01 (integration builder, subagent)
swarm: coord_swarm_2026-11-25
date: 2026-11-25
status: PENDING_SMOKE_RESULT
scope: "variant3d/scripts/world3d_fx.gd + this report only (plus the mandated backup copy). Donor READ-ONLY. No main.gd, config.gd, config.json, menu.gd, test, manifest or app/** edit. No gates, no ladder, no direct godot invocation."
labels: [OBSERVED, DERIVED, UNVERIFIED]
backup: "inbox/backup/world3d_fx.gd.bak-WEATHERDRIVER (59,781 B; SHA-256 FFABE3F86BDF2D67E54C3C9AB11F4DD2AD2B630E3AC357FE9936AC4281B6FC28, identical to the pre-edit source)"
---

# WEATHER-DRIVER-01 — menu/config weather value -> gated donor-snow API

## 1. Goal and ownership

CONFIG-UI-01 added a skirmish-menu Snow On/Off row that emits `cfg.weather`
(`"off"`/`"snow"`) and `cfg.weather_value` (**40** = shipped default,
**70** = snow band input). FX-WEATHER-01 installed the gated donor-snow layer
in `world3d_fx.gd` (`set_weather(int)`, `set_weather_month(int)`, `snow_active()`),
snow root default OFF. CONFIG-CORE-01 added the typed getter
`feature_weather_snow() -> bool`. **No caller connected them**, so the menu row
was PORT-UI-ONLY.

This ticket adds exactly one small, additive helper to the owned FX file that
**resolves** the donor weather value and **forwards** it to the existing
`set_weather(int)` gate. It does **not** call the helper itself and does **not**
edit `main.gd` — the caller that owns `main.gd`/`world3d.gd` must invoke it
(section 6). Snow stays OFF unless an explicit on-value / enabled config is
passed.

**Exclusive ownership honoured:** `variant3d/scripts/world3d_fx.gd` and this
report only (plus the mandated backup). `menu.gd`, `main.gd`, `config.gd`,
`config.json`, `data.gd`, every test/manifest, `app/**` and the donor were
**read-only**.

## 2. Sources read (all read-only)

| Source | Use |
|---|---|
| `reports/CONFIG_UI_01.md` | emitted keys `weather` (`off`/`snow`) and `weather_value` (40/70); "PORT-UI-ONLY" statement; open question 1 (driver ticket) |
| `reports/FX_WEATHER_01.md` | existing `set_weather(int)` / `set_weather_month()` / `snow_active()` API, default-OFF band gate, "enabling is not wired" statement |
| `reports/CONFIG_CORE_01.md` | `features.weather.snow` default `false`, getter `feature_weather_snow() -> bool` (`config.gd:463-464`) |
| `reports/DFX_01_pfx_effects.md` §5.7, §7.6 | donor weather literal citations (table §3) |
| `variant3d/scripts/world3d_fx.gd` (read in full) | owned file: snow constants `:161-178`, private state `:280-284`, weather API `:322-340`, band gate `:764-787` |
| `variant3d/scripts/config.gd` `:46-84, :387-404, :414-483` | `FEATURES_DEFAULTS.features.weather.snow = false`, `active` static instance (`:269`), typed getter + `flag()` fallbacks |
| `variant3d/scripts/hud.gd` `:270-292` | established `ConfigScript.active` + `has_method` + `call()` open-bridge pattern copied for config access |
| `variant3d/scripts/menu.gd` `:925-939` | exact emitted `cfg.weather` / `cfg.weather_value` values |
| `variant3d/tests/t_weather.gd` `:120-132` | `gameplay.weather == "snow"` string contract |

## 3. Donor citation ledger (all constants are EXISTING, none changed)

| Value | Donor citation (`path:line`, read-only) | Label |
|---|---|---|
| `SNOW_WEATHER_DEFAULT = 40` | `env\clouds\clouds.weather:3` `Weather = 40` (`WeatherTarget = 40` `:4`); DFX-01 §7.6 row 1 | OBS |
| `SNOW_WEATHER_START = 70` | `env\pfx\particles.snow.cfg:32,72,112,152` `WeatherStart = 70`; DFX-01 §7.6 row 2 | OBS |
| `SNOW_WEATHER_END = 100` | `particles.snow.cfg:33,73,113,153` `WeatherEnd = 100`; DFX-01 §7.6 row 2 | OBS |
| 0..99 weather scale | `clouds.weather:21-22` `weatherrandomstart=0`, `weatherrandomend=99` | OBS |
| `40 < 70` => OFF | derived from the two literals above on the shared 0..99 scale | DER |
| `"snow"` / `"off"` strings | `t_weather.gd:123-126` enum; CONFIG-UI-01 emits the same | PORT contract, not a donor literal |

No number was invented: the config getter's `true` maps to the donor
activation literal **70**, and `false`/missing maps to the shipped default
**40**. There is no new "snow intensity" scale.

## 4. Before -> after (`variant3d/scripts/world3d_fx.gd` only)

Purely additive: **45 insertions, 0 deletions** (git diff against the backup).
No existing line, constant, signature, control flow, emitter, FX-impact path or
selection-ring code was modified.

| # | Before | After | Where |
|---:|---|---|---|
| 1 | Only `const Data = preload("res://scripts/data.gd")` | Added `const ConfigScript = preload("res://scripts/config.gd")` (+3 comment lines) to reach the active config instance | after `:84` |
| 2 | Public weather API was `set_weather(int)` / `set_weather_month(int)` / `snow_active()`; no config bridge existed | Added `set_weather_from_config(weather_value = null) -> int` (+41 comment/code lines): resolves 40/70 from an explicit numeric value, an explicit `"snow"`/`"off"` string, or CONFIG-CORE-01's `feature_weather_snow()` getter via `ConfigScript.active`; then calls the existing `set_weather(resolved)` and records additive telemetry `weather_driver_value` / `weather_driver_source` | after `snow_active()` (`:340`) |

**Resolution order of the helper:**

1. `weather_value` is int/float -> used directly as the donor Weather input
   (e.g. the `cfg.weather_value` the menu emits: 40 or 70).
2. `weather_value` is String -> `"snow"` maps to `SNOW_WEATHER_START` (70);
   anything else (e.g. `"off"`) -> `SNOW_WEATHER_DEFAULT` (40). This accepts
   the menu's `cfg.weather` enum directly.
3. No argument -> `ConfigScript.active.feature_weather_snow()`: `true` ->
   `SNOW_WEATHER_START` (70), `false` / missing getter / no config -> 40.

Default (no argument, no active config) is **40 < 70 => snow OFF**. The helper
does not bypass the existing gate: `set_weather()` still clamps to 0..99 and
re-applies the band + month gate. Donor constants 40/70/100, the four snow
emitters, all FX-IMPACT-01 volley/muzzle/arrow-trail code and every selection
ring line are byte-identical to the backup.

## 5. Backup

Taken **before** the first edit by plain copy, SHA-256 verified against source:

```
inbox/backup/world3d_fx.gd.bak-WEATHERDRIVER
59,781 bytes
SHA-256 FFABE3F86BDF2D67E54C3C9AB11F4DD2AD2B630E3AC357FE9936AC4281B6FC28
(identical to the pre-edit variant3d/scripts/world3d_fx.gd)
```

Restore = plain file copy back over `variant3d/scripts/world3d_fx.gd`.

## 6. Remaining integration ticket (NOT done here)

The Snow menu row is still **PORT-UI-ONLY** until a ticket owning
`main.gd` / `world3d.gd` calls the new helper. Suggested call site (for the
future integration owner, **not** applied by this ticket): after the config is
loaded and the FX node is bound, forward the menu value, e.g.
`fx.set_weather_from_config(int(cfg.get("weather_value", 40)))`, or call with
no argument to let `features.weather.snow` decide. This ticket deliberately
does not edit `main.gd`, does not change `config.json` and does not add the
`features.weather` key to any applied-setting path.

## 7. Validation — variant runner only

_Pending smoke result; filled in when the queued job returns._

## 8. Open questions

1. **Which contract wins?** `cfg.weather` string (`off`/`snow`) vs numeric
   `cfg.weather_value` (40/70) vs `features.weather.snow` bool. The helper
   accepts all three so no consumer is blocked; the integration owner should
   pick one and document it (mirrors CONFIG-UI-01 open question 2).
2. **Engine-side driver UNVERIFIED.** DFX-01 found no `weather`/`particle`
   token in any of the 222 donor scripts (DEC-02 D-14); whether the donor
   weather value reaches its ParticleCube manager at runtime is unknown. No
   donor parity is claimed for the port gate.
3. **Month/season interaction.** Donor snow needs `Weather >= 70` **and**
   `1 <= month <= 12` (`particles.snow.cfg:32-35`). The shipped month is 1
   (inside the band) and this helper does not set the month; a season-driven
   caller may also call `set_weather_month()`.
4. **Visual calibration.** Donor `Speed` / `Height` / `Width` unit mapping is
   UNVERIFIED (DFX-01 §6/§9, FX-WEATHER-01 §6); the snow layer is a labelled
   PORT APPROXIMATION. Enabling it for display needs a windowed visual check,
   out of scope here.
5. **Config getter access** uses `ConfigScript.active` (the established hud.gd
   pattern). If the active config instance is not set before this helper is
   called with no argument, resolution falls back safely to 40 (OFF).

## 9. Summary

A single additive helper, `set_weather_from_config()`, was added to the owned FX
module. It resolves the donor Weather value (40 OFF / 70 ON) from an explicit
`weather_value`, the menu's `weather` string enum, or CONFIG-CORE-01's
`features.weather.snow` getter, and forwards it to the existing gated
`set_weather(int)` API. Default is OFF; no donor constant, snow emitter,
FX-impact path, selection-ring code or existing API was changed, and `main.gd`
was not touched. The caller that owns `main.gd`/`world3d.gd` still has to wire
the helper (section 6); the Snow row remains PORT-UI-ONLY until then and the
engine-side weather driver is UNVERIFIED.

**No file other than `variant3d/scripts/world3d_fx.gd`, the required backup
`inbox/backup/world3d_fx.gd.bak-WEATHERDRIVER`, and this report was edited by
WEATHER-DRIVER-01.** No donor file was copied, unpacked or executed; no test
was weakened; no gates or windowed ladder were run; no Godot process was
launched outside `variant3d/tools/godot_runner.py`.
