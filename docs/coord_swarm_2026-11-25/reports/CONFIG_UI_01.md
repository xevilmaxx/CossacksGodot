---
id: CONFIG-UI-01
owner: implementation builder (subagent)
date: 2026-11-25
status: DONE__SMOKE_CLEAN__SNOW_CONSUMER_DEFERRED
scope: "variant3d/scripts/menu.gd + this report only (plus the mandated backup copy). Donor READ-ONLY. No gates, no ladder, no direct godot invocation."
---

# CONFIG-UI-01 — small donor-meaningful feature set in the skirmish menu

## 1. Goal and ownership

Expose a **small** subset of the new feature config in the skirmish menu, using
only existing widget patterns and donor-backed values: **season**, **weather
(snow on/off)**, **fog of war on/off**, and **relief**. No slider for shader
internals, eye planes, epsilon or FOV.

Exclusive ownership honoured: `variant3d/scripts/menu.gd` and this report
(plus `inbox/backup/menu.gd.bak-CONFIGUI01`). Everything else was read-only:
`config.gd` (MAP-SMALL-01 / CONFIG-CORE-01), `config.json` (MAP-SMALL-01),
`data.gd`, `main.gd`, `world3d_fx.gd`, all tests/manifests, `app/**`, donor.

Sources read: `menu.gd` options structure (`:406-428` `_opt_row`, `:668-756`
`_show_skirmish`, `:897-927` `_emit_start`), `config.gd` keys (`:44-96`,
`:382`, `:430`, plus CONFIG-CORE-01's new `features` table),
`reports/CFG_01_skirmish_defaults.md`, `docs/REPORT_DONOR_MENU.md`,
`docs/coord_swarm_2026-11-25/decomp/DEC_08_ui_strings.md`,
`reports/DFX_01_pfx_effects.md` / `DENV_01_environment.md` /
`FX_WEATHER_01.md` / `CONFIG_CORE_01.md` (all read-only),
`variant3d/tests/t_weather.gd:120-132`, `t_menu_roster.gd:232-253`.

## 2. Donor citation ledger (no invented constants)

| UI option | Port state / emitted key | Donor evidence (`path:line`, read-only) | Label |
|---|---|---|---|
| **Season** (row already present; citation added, enum now emitted) | `menu.gd:70` `season` = `summer`/`desert`/`winter`; row `menu.gd:709`; `cfg.season` (consumed at `main.gd:317` → `Data.BIOME`) and new `cfg.season_enum` from `data.gd:227` `SEASON_ENUM` = summer **0** / winter **2** / desert **3** | `scripts\lib\map.script:250` `gen.season` default `0` (Summer); `scripts\lib\miscext2.script:3318-3323` UI toggle `0 ↔ 2`; `scripts\dogenerate.inc:4,2079` desert branch `gen.season = 3`; `scripts\dmscript.global:237` `gc_MaxSeasonCount = 3`. Season 1 deliberately unencoded (`data.gd:224-226`, DENV-01 Q5). Also `REPORT_DONOR_MENU.md:88`. | OBS (enum), PORT-WIRED (string), enum emission new |
| **Snow (weather)** — new | `menu.gd:77` `weather` = `off`/`on`; row `menu.gd:716`; emits `cfg.weather` = `"off"`/`"snow"` and `cfg.weather_value` = **40** / **70** | OFF = shipped `env\clouds\clouds.weather:3` `Weather = 40` (confirmed DFX-01 §7.6, DENV-01 §2.7, `FX_WEATHER_01.md:58`); ON = `env\pfx\particles.snow.cfg:32,72,112,152` `WeatherStart = 70`, inside the band `WeatherStart=70`/`WeatherEnd=100` at `:33,73,113,153` (DFX-01 §7.6 row 2, `DENV_01_environment.md:324`, `FX_WEATHER_01.md:60`). Scale `0..99` from `clouds.weather:21-22`. **70 is a donor literal, not an invented "snow intensity".** | OBS |
| **Fog of war** — new | `menu.gd:78` `fog_of_war` = `off`/`on`; row `menu.gd:717-722`; emits `cfg.fog_of_war` bool; the callback also writes `Data.FOG_OF_WAR`, which is already the live sim/HUD switch | `config.gd:51` `display.fog_of_war = false`, applied `:382`; `data.gd:55` `FOG_OF_WAR = false`; consumers `world3d_fog.gd:213,234,317`, `world.gd:345,2259,2267`, `hud.gd:1552,1582`; `CFG_01_skirmish_defaults.md:61-70`. CONFIG-CORE-01 adds namespaced `features.gameplay.fog_of_war = false` (`config.gd:482` after that ticket) as a parallel default. Donor `FogMode` is ambiguous — kept OFF, per DENV-01 §3.9 / `CONFIG_CORE_01.md:57`. | PORT default (no new mechanic) |
| **Relief** — already present, intentionally unchanged | `menu.gd:71` `relief = "low_mountains"`; row `menu.gd:708` uses `_relief_types()` → all 6 `DONOR_RELIEF` ids; `cfg.relief` + `cfg.relieftype` emitted at `:928`, `:945` | `scripts\dmscript.global:238` `gc_MaxReliefTypeCount = 6-1`; `gui\menu.inc\showcustomgame.inc:164-169`; `variant3d/scripts/data.gd:315-322` (`low_mountains → hills` at `:317`); `REPORT_DONOR_MENU.md:85` | OBS (already covered — no edit needed) |

## 3. Before → after (`variant3d/scripts/menu.gd` only)

| # | Before | After | Where |
|---:|---|---|---|
| 1 | No weather/fog state; `season` at `:66`, `relief` at `:67` only | Two new string-id state vars `weather = "off"`, `fog_of_war = "off"`, plus donor citation comments on Season/Relief | `:66-78` |
| 2 | `_ready()` did not consult fog state | `fog_of_war = "on" if Data.FOG_OF_WAR else "off"` — mirrors the already-applied config default (still OFF by default); no default changed | `:96-98` |
| 3 | Map section had Shape / Relief / Season / Map size (`:692-699`) | Two `_opt_row` On/Off rows inserted **immediately after Season**: `Snow (weather)` and `Fog of war`; Map, Resources & placement and Rules sections and every existing row/order untouched | `:709-720` |
| 4 | Season row emitted only `cfg.season` | `cfg` gained four additive keys: `season_enum` (donor 0/2/3), `weather` (`off`/`snow`), `weather_value` (`40`/`70`), `fog_of_war` (bool). No existing key changed or removed | `:929-939` |

**Insertion point:** a clean one existed. `options_body` is a `VBoxContainer`
in which the donor map options are already grouped consecutively (Shape,
Relief, Season, Size). Adding two standard `_opt_row` lines after Season keeps
the grouping and requires no new section, scroll container or layout rewrite.
Both toggles reuse the exact `_opt_row(label, items, current, Callable)` pattern
already used by Adviser / Autosave / Game speed (`:753-759` after edit);
labels are English like every other row in this menu.

**Functional status (honest):**

- **Fog of war**: live. `Data.FOG_OF_WAR` is the switch the world/HUD already
  read; writing it in the row callback is the same precedent as this script's
  existing `Data.RANDOM_SEED` writes (`:851`, `:881`). The emitted bool is an
  additive mirror for any future config-side consumer.
- **Season**: live as before (`cfg.season` → `Data.BIOME`, `main.gd:317`);
  `season_enum` is additive data for a future donor-struct consumer.
- **Snow**: **PORT-UI-ONLY** today. The FX module already exposes
  `set_weather(int)` with the 70..100 gate (`world3d_fx.gd:240`, `:641-664`)
  but no caller exists (`FX_WEATHER_01.md:93-94`, open question 2). menu.gd does
  not own the FX/world driver, so it emits the donor-derived `weather_value`
  instead of inventing a cross-file call. Wiring it is a separate driver ticket.
- **Relief**: unchanged, already donor-complete and PORT-WIRED.

## 4. Backup

Taken **before** the first edit by plain copy, SHA-256 verified against source:

```
inbox/backup/menu.gd.bak-CONFIGUI01
38,788 bytes
SHA-256 BD42748699AB00DA4B9B9B38D47F8DF6E80043B5EF4A3E5D37BCA50A7A969DF1
(identical to the pre-edit variant3d/scripts/menu.gd)
```

Restore = plain file copy back over `variant3d/scripts/menu.gd`.

## 5. Validation — variant runner only

Prescribed command (Windows `python`, no direct `godot`, no gates, no ladder,
no test/manifest edits):

```
python variant3d\tools\godot_runner.py run --id configui01-smoke --timeout 180 --max-wait 1800 -- --headless --path variant3d --check-only --script res://scripts/menu.gd
```

| Ticket | id | status / exit | wait / run | stdout / stderr | `SCRIPT ERROR` |
|---:|---|---|---|---|---|
| 422 | `configui01-smoke` | failed / 1 | 164.97 s / 3.68 s | 75 B / 0 B | 0 |
| **426** | `configui01-smoke` | **ok / 0** | 294.45 s / **8.15 s** | **75 B / 0 B** | **0** |

Ticket 422 exited 1 with **no stderr and no `SCRIPT ERROR`** (stdout was only
the Godot version banner). Neighbouring tickets from other owners in the same
window also failed without parse output — 420 `mapsmall01-diag11-240` exit 1,
421 `p0gate01-run` exit 1, 425 `mapsmall01-selftest-240-r5` exit 1 — while
423/424 succeeded. It was treated as queue/environment flake, not accepted as
a pass, and the identical job was re-run: **ticket 426 is the accepted result**
(`variant3d/.godot_queue/results/00000426.json`,
`00000426_configui01-smoke/stdout.txt` and `stderr.txt`). `--check-only`
parses/validates the script; it is not a visual A/B, a gate or a selftest run.

## 6. Options intentionally NOT exposed in the menu (JSON-only / other tickets)

These are the rest of CONFIG-CORE-01's `features` table (`config.gd:414-483`,
`CONFIG_CORE_01.md:38-58`). They have no clean donor lobby meaning or need
engine work in foreign-owned files, so they stay JSON-only:

- Selection internals: `world_epsilon_m`, `attack_epsilon_m`, `marquee_color`,
  `marquee_width_px`, `double_click_s` (DSEL-01 donor values are debug/tuning,
  not lobby dropdowns).
- Terrain/shader internals: `texgen_mode`, `m_per_tile`, `lighting`,
  `alpha_patch_mode`, `relief_stamps`, `tile_diversity`.
- Water internals: `surface_y`, `alpha_confine`, `shore_prox`.
- Camera: `fov_deg` (`camera3d.gd:65`, PORT APPROX — explicitly out of scope).
- HUD geometry: `minimap_size`, `minimap_inset`, `minimap_corner` (DEC-08 donor
  constants, but a menu dropdown would need HUD re-partitioning by HUD-01).
- `render.fog` (donor `FogMode` ambiguous; DENV-01 §3.9 — keep off).
- Weather particle micro-constants: snow speed/count/size/alpha, month band,
  spiral motion and wind vector (`particles.snow.cfg`, DFX-01 §7.6). Only the
  40/70 band endpoints are exposed, as the On/Off toggle above.
- Donor map shape/relief values beyond the menu's existing enums, donor Season
  `1` (unverified), and donor "Random" entries: generator work, not menu work
  (`REPORT_DONOR_MENU.md:319-321`).

## 7. Open questions

1. Who wires `cfg.weather_value` (40/70) to `world3d_fx.set_weather(int)`? No
   caller exists today (`FX_WEATHER_01.md:93-94`); this needs a driver ticket
   owning `main.gd`/`world3d.gd`/`world3d_fx.gd`. Until then the Snow row is
   PORT-UI-ONLY. The font/label readiness of the FX layer is also UNVERIFIED.
2. Should `cfg.weather` be the string enum (`"off"`/`"snow"`, matching
   `t_weather.gd:123-126` and CONFIG-CORE-01's bool `feature_weather_snow()`),
   or should the numeric `weather_value` be the only contract? Both are emitted
   so neither consumer is blocked; a driver ticket should pick one and document it.
3. `cfg.fog_of_war` is top-level while CONFIG-CORE-01's parallel default is
   `features.gameplay.fog_of_war` and the applied key is `display.fog_of_war`
   (`config.gd:51` / `:382`). A future config-side consumer must choose the
   namespace; this ticket did not rename or move any existing key.
4. Donor snow activation is `Weather >= 70` **and** `1 <= month <= 12`
   (`particles.snow.cfg:32-35`). On maps with a non-summer season, should the
   menu force the FX month, or leave it at the donor default `1`? Donor bytes
   do not decide (`FX_WEATHER_01.md:163`).
5. Ticket 422's exit-1-with-empty-stderr is recorded but not root-caused; the
   accepted clean result is ticket 426. Re-check in a quieter queue window if
   the coordinator wants a single-attempt clean run.

## 8. Summary

Added three donor-cited, additive UI elements to the skirmish menu: a **Snow
(weather)** On/Off row (donor Weather 40 off / 70 on, band 70..100), a **Fog of
war** On/Off row (existing default false, live via `Data.FOG_OF_WAR`), and a
donor-meaningful **`season_enum`** emission (0/2/3) alongside the existing
Season row. **Relief was already donor-complete and was not changed.** All new
rows use the existing `_opt_row` widget pattern; every existing option,
default and layout section is intact. The mandated backup was taken and
SHA-verified; the final variant-runner smoke (ticket 426, id
`configui01-smoke`) ended `ok` / exit 0 with `SCRIPT ERROR == 0`.

**No file other than `variant3d/scripts/menu.gd`, the required backup
`inbox/backup/menu.gd.bak-CONFIGUI01`, and this report was edited by
CONFIG-UI-01.** No donor file was copied, unpacked or executed; no test was
weakened; no gates or windowed ladder were run.
