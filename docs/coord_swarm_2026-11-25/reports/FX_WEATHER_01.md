---
id: FX-WEATHER-01
task: "Add the donor snow particle layer discovered by DFX-01 — gated and labelled, default OFF"
owner: FX-WEATHER-01 (implementation builder, coordinated swarm)
swarm: coord_swarm_2026-11-25
date: 2026-11-25
status: IMPLEMENTED__GATED_OFF__SMOKE_CLEAN__PARITY_NOT_CLAIMED
scope: "Exactly one source file edited (variant3d/scripts/world3d_fx.gd) plus this report and the required backup copy. No shader, terrain/anim/HUD file, test, config, manifest, app/** or donor file touched. Donor READ-ONLY. No gates, no windowed ladder, no direct godot invocation."
labels: [OBSERVED, DERIVED, UNVERIFIED, PORT_APPROXIMATION]
backup: "inbox/backup/world3d_fx.gd.bak-FXWEATHER01 (36,517 B; SHA-256 669F5EC78A384FD26E9E80315C091794B710AC69875E2E21AAF6FF9D06F8BBCD, identical to the pre-edit source)"
smoke: "variant runner ticket 405, --id fxweather01-smoke, --headless --path variant3d --script res://tests/t_fx3d.gd -> status=ok exit=0 wait=231.27s run=6.83s; stderr 0 bytes, SCRIPT ERROR == 0; T_FX3D PASS 13/13"
---

# FX-WEATHER-01 — gated donor snow particle layer in `world3d_fx.gd`

## 1. Goal, ownership and sources read

DFX-01 found a weather particle family absent from every earlier FX report:
`data\env\pfx\particles.snow.cfg` (4 emitters `snow1..snow4`) plus
`data\env\clouds\clouds.weather`. DENV-01 ranks the cloud/weather layer as one
of the port's top three visual gaps but also records that the shipped
`Weather=40` is **below** the snow activation band `70..100`, so snow is
inactive by default (derived). This ticket installs the emitter-capable layer
**disabled**, with donor-derived constants and a small API for a future
weather/season ticket to enable it.

Read before editing (all read-only):

| Source | Use |
|---|---|
| `reports/DFX_01_pfx_effects.md` §3.2, §5.7, §6, §7.6, §10.1 | snow emitter schema, exact constants, "ABSENT — no particle/weather system in module" (:679), units UNVERIFIED |
| `reports/DENV_01_environment.md` §2.8, §3.7, §5.3 (gaps 3/8), §8 | second independent citation of the same values; palette identity; gap ranking |
| `reports/HUD_01_minimap.md` §1, §4.2, §10 | file-ownership boundary check only: HUD-01 owns `hud.gd`/`hud3d_adapter.gd` and explicitly leaves `camera3d.gd`, `input_controller.gd`, `uitest.gd` foreign — none of those touched here |
| `variant3d/scripts/world3d_fx.gd` (986 lines, read in full) | node roots at old `:534-559`, `bind`/`sync`/`add_fx`/`draw_*`/`sync_selection` APIs, stats contract |
| `variant3d/tests/t_fx3d.gd`, `variant3d/tools/godot_runner.py`, `variant3d/project.godot` | smoke atom and the only legal Godot launch path; Godot 4.7.2, GL Compatibility |

**Exclusive ownership honoured:** `variant3d/scripts/world3d_fx.gd` and this
report only (plus the mandated backup). Selection-ring, ghost, rally, marquee,
shader, terrain, anim, HUD, test, config, manifest and `app/**` code is
byte-unchanged by this ticket.

## 2. Backup

Taken **before** the first edit, verified by SHA-256 match against the source:

```
copy variant3d\scripts\world3d_fx.gd inbox\backup\world3d_fx.gd.bak-FXWEATHER01
```

## 3. Donor citation ledger (every constant added)

Labels follow the swarm convention: **OBS** = literal donor value read;
**DER** = arithmetic/control-flow consequence; **UNV** = no readable unit
conversion or consumer; **PA** = port approximation, not donor parity.

| Port constant / site | Value | Donor citation | Label |
|---|---|---|---|
| `SNOW_WEATHER_DEFAULT` | 40 | `clouds.weather:3` `Weather = 40` (`WeatherTarget = 40` at `:4`, `WeatherRandom=False` at `:6`); DFX-01 §7.6 row 1, DENV-01 §2.7 | OBS |
| `SNOW_WEATHER_MIN/MAX` | 0 / 99 | `clouds.weather:21-22` `weatherrandomstart=0`, `weatherrandomend=99`; DENV-01 §2.7 | OBS |
| `SNOW_WEATHER_START/END` | 70 / 100 | `particles.snow.cfg:32-33,72-73,112-113,152-153` `WeatherStart=70`, `WeatherEnd=100` (all four); DFX-01 §7.6 row 2, DENV-01 §2.8 | OBS |
| Default gate decision | OFF | 40 < 70 on the same 0..99 scale | DER |
| `SNOW_MONTH_START/END` | 1 / 12 | `particles.snow.cfg:34-35,74-75,114-115,154-155`; DFX-01 §7.6 row "Seasons" | OBS |
| `SNOW_SPEEDS` | 0.041 / 0.061 / 0.08 / 0.1 | `particles.snow.cfg:36,76,116,156` `Speed` (full precision in DENV-01 §2.8); DFX-01 §7.6 row 5 | OBS value, **UNV** unit → PA assignment to Godot velocity |
| `SNOW_COUNTS` | 100 / 100 / 100 / **200** | `particles.snow.cfg:37,77,117,157` `Count`; DFX-01 §7.6 row 6 | OBS → direct `amount` |
| `SNOW_SIZES` | 0.0015 / 0.002 / 0.00251 / 0.003 | `particles.snow.cfg:4-5,44-45,84-85,124-125` `Height`/`Width`; DFX-01 §7.6 row 4, DENV-01 §2.8 | OBS value, **UNV** unit → PA quad size |
| `SNOW_ALPHA` | 0.5 | `particles.snow.cfg:6,46,86,126` `AlphaChannel=0.5`; DFX-01 §7.6 row 3 | OBS |
| `SNOW_CUBE_EXTENTS` | (0.5, 0.5, 0.5) | `particles.snow.cfg:17-26` (and each block) `CreatingCubeStart=(+0.5,+0.5,+0.5)`, `CreatingCubeEnd=(-0.5,-0.5,-0.5)`; DFX-01 §5.7 | OBS → PA half-extents mapping |
| `SNOW_MOVE_DIR` | (0, −1, 0) | `particles.snow.cfg:27-31` (and each block) `MoveDirection`; DFX-01 §7.6 row 5 | OBS |
| Billboard mode | `btBillboard` | `particles.snow.cfg:16,56,96,136`; DFX-01 §5.7/§7.6 | OBS → Godot `BILLBOARD_ENABLED` is PA |
| No depth write | True | `particles.snow.cfg:7,47,87,127` `NoZWrite=True`; DFX-01 §7.6 row 3 | OBS → Godot `DEPTH_DRAW_DISABLED` is PA |
| `SNOW_PORT_LIFETIME` | 8.0 s | **no donor lifetime key** — DFX-01 §6 shows weather timing lives in `Speed`/`CameraSpeedFactor`, not a lifetime field | PA, explicitly labelled in code |
| White quad draw pass | plain `QuadMesh`, no texture | donor `env\pfx\textures\snow{1..4}.bmp` are private-use and not present in the repo (DENV-01 §1.3); no donor-derived white/greyscale particle texture exists under `variant3d/**` (repository search: no `*particle*`/`*snow*` asset) | PA, "NOT DONOR PARITY" in code |
| Recorded, not implemented | spiral radius ≈0.1, speed 20/15/13/13 | `particles.snow.cfg:14-15,54-55,94-95,134-135`; DFX-01 §7.6 row "Spiral motion" | OBS, no Godot equivalent claimed |

## 4. Before → after (`variant3d/scripts/world3d_fx.gd`)

| # | Before | After | Where |
|---:|---|---|---|
| 1 | No weather code, no `Weather*` constant | Header block documenting the DFX-01/DENV-01 finding, the OFF-by-default gate, the no-donor-art rule and the no-construction-dust rule | `:51-62` |
| 2 | No snow constants | Donor constants with `path:line` citations on every line (table §3); one clearly marked `SNOW_PORT_LIFETIME` | `:136-157` |
| 3 | Private state: `_root`, ghost, rally, selection, `_time`, `_events_seen`, `_spawn_index` | Added `_weather_root`, `_snow_emitters`, `_weather_value = 40`, `_weather_month = 1` | `:193-197` |
| 4 | `bind()` created roots only | `bind()` calls `_apply_snow_gate()` after `_ensure_roots()` | `:214-215` |
| 5 | Public API: `bind/sync/add_fx/draw_ghost/draw_rally/sync_selection` | **Additive** `set_weather(int)`, `set_weather_month(int)`, `snow_active() -> bool`; no existing signature changed | `:235-253` |
| 6 | Four roots (`FX3D`, `BuildGhost3D`, `Rally3D`, `Selection3D`) | Fifth root `WeatherSnow3D` created **under `_root`/FX3D**, with 4 child `GPUParticles3D` named `Snow1..Snow4` | `:632-638`, `:632-703` |
| 7 | No gate | `_snow_band_ok()` + `_apply_snow_gate()` hide the root and set `emitting=false` unless `70 <= weather <= 100` and `1 <= month <= 12`; telemetry `snow_weather`, `snow_month`, `snow_band`, `snow_active`, `snow_emitter_count`, `snow_status` | `:641-664` |
| 8 | No particle setup | `_build_snow_emitters()`: `ParticleProcessMaterial` box emission extents 0.5, direction (0,−1,0), spread 0, gravity 0, per-layer `initial_velocity_min/max` = donor `Speed`, quad size = donor `Height`/`Width`, `amount` = donor `Count`, white billboard/no-depth-write material | `:667-703` |
| 9 | `_shift_created_nodes()` shifts FX/rally/selection only | Comment records that the camera-relative weather root is deliberately excluded | `:321-324` |
| 10 | `clear_all()` clears transient FX | Comment records that persistent weather state is deliberately preserved | `:525-526` |

**Default state after edit:** `_weather_value = 40` → `_snow_band_ok() == false`
→ `WeatherSnow3D.visible == false` and all four emitters `emitting == false`.
The layer is constructed but inert until `set_weather(70..99)` is called.
Enabling is *not* wired into `config.gd`/`world3d.gd` — those are foreign-owned;
a future weather/season ticket must supply the caller.

**Expected node-count delta:** the smoke atom measured 10 descendants after
`bind()` (previously 5: `FX3D`, `BuildGhost3D`+`Footprint`, `Rally3D`,
`Selection3D`). The 5 added nodes are `WeatherSnow3D` + `Snow1..Snow4`.

## 5. Validation — variant runner only

Command (no direct `godot`, no gates, no ladder, no test edits):

```
python variant3d/tools/godot_runner.py run --id fxweather01-smoke --timeout 120 -- --headless --path variant3d --script res://tests/t_fx3d.gd
```

| Ticket | Result | Note |
|---:|---|---|
| 393 | failed, exit 1 | First attempt: parse error `DEPTH_DRAW_NEVER` is not a member of `BaseMaterial3D` in Godot 4.7.2 (actual constant: `DEPTH_DRAW_DISABLED`). Fixed, no other file touched. |
| 400 | ok, exit 0 | Atom reported 13/13, **but stderr carried `SCRIPT ERROR: Invalid assignment ... 'particle_size_min'`**. Not accepted as clean. Fixed by moving donor flake size into the draw-pass quad and using the 4.7 API. |
| **405** | **ok, exit 0** | **Final.** `variant3d/.godot_queue/results/00000405.json`: wait 231.27 s, run 6.83 s. stdout `T_FX3D PASS 13/13 checks`; stderr file **0 bytes → `SCRIPT ERROR == 0`**. `MODULE_LOADS`, `API_SURFACE`, `FX_LIFETIME_EXPIRY_REMOVES_NODES`, `GHOST_RALLY_CALLS`, `NO_2D_SPRITE_SHEET_LOADS`, `NO_ERRORS` all PASS. |

This is a parse/API/lifetime smoke test, **not** a visual A/B and **not** a
claim of donor FX parity. One Godot 4.7 shutdown warning about an RID/ObjectDB
leak appeared in the rejected ticket 400; the final ticket 405 stderr is empty
and stdout ends at `T_FX3D PASS 13/13 checks`.

## 6. Explicit PORT APPROXIMATION / UNVERIFIED labels

- **PORT APPROXIMATION — NOT DONOR PARITY** — the entire snow layer's visual
  form: Godot `GPUParticles3D` + `ParticleProcessMaterial` + untextured white
  billboard quad. The donor uses its own ParticleCube engine with private-use
  `snow{1..4}.bmp` sheets; no donor pixel, texture or binary was copied.
- **UNVERIFIED (unit mapping)** — donor `Speed` (0.041..0.1), `Height`/`Width`
  (0.0015..0.003), `CreatingCube` ±0.5 and `AlphaChannel=0.5` are literal keys;
  DFX-01 §6/§9 recovered no consumer converting them to metres/seconds, so
  their use as Godot velocity/quad size/extents/alpha is provisional.
- **PORT ONLY** — `SNOW_PORT_LIFETIME = 8.0` s: no donor weather lifetime key
  exists (DFX-01 §6). Recorded in code, not presented as donor truth.
- **NOT REPRODUCED** — spiral motion (`SpiralRotatingRadius`/`Speed`),
  `CameraSpeedFactor`, `WindInteraction`/`WeatherInteraction` and the donor
  wind vector. Their values are documented in DFX-01/DENV-01 but no Godot
  behaviour was invented for them.
- **UNVERIFIED / OPEN** — camera-follow: donor `particles.lib:11`
  `AutoOffsetFromCamera=True`; this module owns no camera reference, so the
  weather root stays at the FX origin. No camera coupling added.
- **DERIVED, not observed on screen** — "snow inactive at default weather":
  arithmetic from `Weather=40` (`clouds.weather:3`) and band `70..100`
  (`particles.snow.cfg:32-33` etc), assuming the shared 0..99 scale
  (`clouds.weather:21-22`). The gate is implemented from that derivation.
- **NOT DONOR PARITY** — no claim is made that shot smoke, muzzle flash,
  trails, impacts or selection rings were improved; those code paths are
  byte-unchanged.

## 7. Open questions (do not guess)

1. What are the donor units for `Speed` and flake `Height`/`Width`? A visible
   calibration pass is required before anyone turns the gate on.
2. Should enabling be driven by `config.gd` `gameplay.weather` (currently a
   string-only setting per DENV-01 §5.2) or by the season (`gen.season`) value?
   That needs edits to foreign-owned files and a driver ticket.
3. Does the donor weather value actually reach the ParticleCube manager from
   `clouds.weather`, given that DFX-01 found **no** `weather`/`particle` token
   in any of the 222 scripts (DEC-02 D-14)? Runtime behaviour UNVERIFIED.
4. How should the donor's camera-relative particle cube (`particles.lib:11`)
   follow the 3D camera? No camera reference is owned here.
5. Should spiral motion be approximated with turbulence/orbit velocity, and
   should wind interaction consume the donor vector
   `(-0.742116451263428, 0, -0.867265641689301)` (`clouds.weather:7-12`)?
   Both are deliberately unimplemented.
6. Does `MonthStart/MonthEnd = 1/12` mean "all months" for every layer, and
   how would a winter season map onto a month number? UNVERIFIED.
7. Is `GPUParticles3D` acceptable in the GL Compatibility renderer once the
   gate is enabled? This smoke test constructs the nodes but renders no frame;
   a windowed visual check is out of this ticket's scope.

## 8. Summary and scope statement

A minimal, gated snow particle layer was added to the owned FX module: one
`WeatherSnow3D` root beneath `FX3D`, four donor-derived `Snow1..Snow4`
emitters, donor-cited constants, a default-OFF band gate
(`Weather=40 < WeatherStart=70`) and a three-method public API
(`set_weather`, `set_weather_month`, `snow_active`) for a future enabling
ticket. The draw pass is a labelled plain-white approximation; no donor art,
no construction dust, no selection/marquee change and no donor FX parity is
claimed. Final variant-runner smoke: ticket 405, `status=ok exit=0`,
`SCRIPT ERROR == 0`, `T_FX3D PASS 13/13`.

**No file other than `variant3d/scripts/world3d_fx.gd`, the required backup
`inbox/backup/world3d_fx.gd.bak-FXWEATHER01`, and this report was edited by
FX-WEATHER-01.** No donor file was copied, unpacked or executed; no Godot
process was launched outside `variant3d/tools/godot_runner.py`; no gates or
windowed ladder were run.
