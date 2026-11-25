---
id: FX-IMPACT-01
task: "Add donor-grounded volley smoke, muzzle flash and arrow-trail FX (charter fidelity tranche)"
owner: FX-IMPACT-01 (implementation builder, coordinated swarm)
swarm: coord_swarm_2026-11-25
date: 2026-11-25
status: IMPLEMENTED__SMOKE_CLEAN__NO_PARITY_CLAIM
scope: "Exactly one source file edited (variant3d/scripts/world3d_fx.gd) plus this report and the mandated backup copy. No shader, terrain, entities, anim, audio, HUD, test, config, manifest, app/** or donor file touched. Donor READ-ONLY. No gates, no windowed ladder, no direct godot invocation."
labels: [OBSERVED, DERIVED, UNVERIFIED, PORT_APPROXIMATION]
owns: ["variant3d/scripts/world3d_fx.gd", "docs/coord_swarm_2026-11-25/reports/FX_IMPACT_01.md"]
backup: "inbox/backup/world3d_fx.gd.bak-FXIMPACT01 (44,873 B; SHA-256 A4299470407F1129DBEF0C678755118EEB6ED29328BC08BD5CA297310AA73B12, taken before the first edit and identical to the pre-edit source)"
smoke: "variant runner ticket 434, id fximpact01-smoke, --headless --path variant3d --script res://tests/t_fx3d.gd -> status=ok exit=0 wait=2.12s run=7.89s; stderr 0 bytes, SCRIPT ERROR == 0; T_FX3D PASS 13/13. Additional parse ticket 428 (fximpact01-parse, --check-only --script res://scripts/world3d_fx.gd) status=ok exit=0, stderr 0 bytes."
---

# FX-IMPACT-01 — donor-grounded impact FX in `world3d_fx.gd`

## 1. Goal, ownership and sources read

DFX-01 decoded the donor PFX family and found that the port's FX module
"**approximates or omits every donor FX class**" (`DFX_01_pfx_effects.md:662-684`).
For the three classes the charter names — volley smoke, muzzle flash, arrow
trails — DFX-01 supplies exact literal keys (`§7.1`, `§7.2`, `§7.3`) while
explicitly refusing to map them to Godot metres/seconds (`§6`, `§9`). This ticket
installs three **additive** FX kinds grounded in those literals, replaces the
port's solid-box trail with a **face-camera billboard** option, and labels every
unverifiable conversion as `PORT APPROXIMATION`.

Read before editing (all read-only):

| Source | Use |
|---|---|
| `docs/coord_swarm_2026-11-25/reports/DFX_01_pfx_effects.md` §5.1-5.4, §6, §7.1-7.3, §8, §9, §10.1 | source records, materials, RNG slot semantics, exact constants, port-gap table |
| `docs/coord_swarm_2026-11-25/reports/FX_WEATHER_01.md` | additive-layer precedent, backup/smoke/report discipline, snow root to preserve |
| `docs/coord_swarm_2026-11-24/reports/V715_world3d_fx.md` §2-6 | original FX API, node roots, event peek, lifetime trail constants |
| `docs/coord_swarm_2026-11-24/reports/V773_fx_world_offset.md` §2-4 | `world_offset` origin convention; `_orient_trail` reuse |
| `docs/audit/ANIM_ATTACK.md` | animation timing is donor-exact; do **not** retime FX against animation frames |
| `variant3d/scripts/world3d_fx.gd` (1,130 lines read in full) | owned file, FX roots/sync APIs, selection + snow code to preserve byte-identically |
| `variant3d/tests/t_fx3d.gd`, `variant3d/tools/godot_runner.py` | fixed smoke atom and the only legal Godot launch path |

**Exclusive ownership honoured:** `variant3d/scripts/world3d_fx.gd` (modified),
this report (new), and `inbox/backup/world3d_fx.gd.bak-FXIMPACT01` (new copy).
The pre-existing FX-WEATHER-01 `WeatherSnow3D` root, its `set_weather` API, the
`Selection3D` rings/marquee code and every legacy FX kind (`shot`, `smoke`,
`trail`, ...) are unchanged. No donor file was copied, unpacked or executed.

## 2. Backup

Taken **before** the first edit; SHA-256 matches the source byte-for-byte:

```
copy variant3d\scripts\world3d_fx.gd inbox\backup\world3d_fx.gd.bak-FXIMPACT01
```

Both files: 44,873 B, SHA-256
`A4299470407F1129DBEF0C678755118EEB6ED29328BC08BD5CA297310AA73B12`.

## 3. Donor citation ledger (every constant added)

Labels follow the swarm convention: **OBS** = literal donor value read by
DFX-01; **DER** = arithmetic/control-flow consequence; **UNV** = no readable
unit conversion or consumer; **PA** = port approximation, explicitly **NOT
DONOR PARITY**. All donor paths below are private-use and read-only; no bytes
were copied. `source.pfx` / `material.mat` / `fx.tree` line numbers are exactly
those quoted in `DFX_01_pfx_effects.md §7.1-7.3`.

### 3.1 Volley smoke — donor `shotmusket` (`DFX-01 §7.1`)

| Port constant | Value | Donor citation | Label |
|---|---|---|---|
| `IMPACT_SMOKE_END_FRAME` | 127 | `source.pfx:41` (`0x45D`) | OBS |
| `IMPACT_SMOKE_FRAME_W/H` | 256 / 128 | `source.pfx:42-43,48-49` | OBS |
| `IMPACT_SMOKE_PIXEL_RATIO` | 175 | `source.pfx:51` (`0x571`) | OBS, UNV unit |
| `IMPACT_SMOKE_ALPHA_TIME` | 1.5 | `source.pfx:61` (`0x669`) | OBS, UNV → PA |
| `IMPACT_SMOKE_ALPHA_POWER` | 1.5 | `source.pfx:62` | OBS → PA fade curve |
| `IMPACT_SMOKE_TINT_GREY` | 0.3137255 (=80/255) | `material.mat:17-37` (shared smoke tint) | OBS |
| `IMPACT_SMOKE_OFFSET` | (-0.1, -1.5, 0.775) | `source.pfx:54-57` | OBS — axis mapping UNV, RECORDED not applied |
| `IMPACT_SMOKE_UP_PIXEL_RATIO` | 600 | `source.pfx:258-294`; `fx.tree:40-46` | OBS, UNV unit |
| `IMPACT_SMOKE_UP_END_FRAME` | 63 | `source.pfx:258-294`; `fx.tree:40-46` | OBS |
| `IMPACT_SMOKE_QUAD_M` | 1.4 m | no donor metre conversion (`DFX-01 §6/§9`) | **PA** of PixelRatio 175; 256:128 frame ratio kept |
| `IMPACT_SMOKE_UP_QUAD_M` | 2.0 m | no donor metre conversion | **PA** of up-smoke PixelRatio 600 |
| `IMPACT_SMOKE_ALPHA` | 0.55 | donor diffuse alpha UNV | **PA** |
| smoke lifetime | 1.6 s | port `world.gd:3567`; donor `AlphaTime 1.5` has no second mapping | **PA** (port precedent, not donor) |

Layer count: donor has 5 (`musketsmoke`, `musketflash`, `musketsparks`,
`musketsmokeup`, `musketflashup`; `fx.tree:7,26,32,38,49`). No `volley`/`salvo`
key exists — N shooters = N compositions (`DFX-01 §7.1`). This port effect is
**two smoke quads**, not five layers: **PA, not parity**. Sparks, palette shader
30 and normal/bump smoke (`source.pfx:52,166`, `fx.id31.frag:41-49`) are absent.

### 3.2 Muzzle flash — donor `musketflash` (`DFX-01 §7.2`)

| Port constant | Value | Donor citation | Label |
|---|---|---|---|
| `IMPACT_FLASH_FRAMES` | 4 | `source.pfx:112-114,125-127,138-140,151-153` | OBS |
| `IMPACT_FLASH_FRAME_RATE` | 10 | `source.pfx:169` | OBS |
| `IMPACT_FLASH_INTERVAL` | 100 | `source.pfx:164` | OBS |
| `IMPACT_FLASH_PIXEL_RATIO` | 350 | `source.pfx:167` | OBS, UNV unit |
| `IMPACT_FLASH_ON_END_HIDE` | true | `source.pfx:176` `OnEndFrameHide = True` | OBS → PA alpha-hold |
| `IMPACT_FLASH_OFFSET` | (-0.1, -1.0, 0.775) | `source.pfx:170-173` | OBS — axis mapping UNV, RECORDED not applied |
| `IMPACT_FLASH_RAND_ANIMATION` | 1 | `fx.tree:28` | OBS — **RECORDED, not reproduced** (no RNG) |
| `IMPACT_FLASH_RAND_MIRROR_V` | 2 | `fx.tree:29` | OBS — **RECORDED, not reproduced** (no RNG) |
| `IMPACT_FLASH_QUAD_M` | 0.7 m | no donor metre conversion | **PA** of PixelRatio 350 |
| `IMPACT_FLASH_FRAME_SECONDS` | 0.1 | DER = 1 / FrameRate 10 | UNV frame→second mapping |
| flash lifetime | 0.35 s | port `world.gd:3564`; donor 4f/10fps = 0.4 s (DER) | **PA** |

Frame size 256×128 / image 512×256 (`source.pfx:115-122`), `samPlayOnce`
(`source.pfx:165-166`), tint (1,1,1,1) and shader 29 (`material.mat:63-81`,
`manager.lib:10-14`) are documented in the code comment. No donor flash sheet
is copied; one additive billboard quad with **alpha hold then cut** stands in
for the 4 animated frames — **PA, not parity**.

### 3.3 Arrow / projectile trail — donor `bullettrail` (`DFX-01 §7.3`)

| Port constant | Value | Donor citation | Label |
|---|---|---|---|
| `IMPACT_TRAIL_TIME_LIMIT` | 0.2 | `source.pfx:1740` (`0xBFA8`) | OBS, UNV unit |
| `IMPACT_TRAIL_ALPHA` | 0.2 | `source.pfx:1742` | OBS |
| `IMPACT_TRAIL_FIREARROW_ALPHA` | 0.3 | `source.pfx:2315` (firearrowtrail) | OBS — recorded, not wired |
| `IMPACT_TRAIL_WIDTH` | 0.1 | `source.pfx:1746` (`MarkWidth`) | OBS, UNV unit |
| `IMPACT_TRAIL_FRAG_WIDTH` | 0.05 | `source.pfx:1783` (fragtrail) | OBS — recorded, not wired |
| `IMPACT_TRAIL_MIN_DISTANCE` | 0.05 | `source.pfx:1741` | OBS |
| `IMPACT_TRAIL_VERT_LIMIT` | 150 | `source.pfx:1739` | OBS — **RECORDED, not reproduced** (CPU single segment) |
| `IMPACT_TRAIL_ALPHA_FADE` | true | `source.pfx:1743` | OBS → linear fade |
| `IMPACT_TRAIL_MARK_STYLE` | `msFaceCamera` | `source.pfx:1745` (`0xC017`) | OBS → billboard quad |
| `IMPACT_TRAIL_ZWRITE` | false | `source.pfx:1748-1749` | OBS → depth-draw-disabled |
| `IMPACT_TRAIL_DIFFUSE_ALPHA` | 1.0 | `source.pfx:1759-1763` `Diffuse(1,1,1,1)` | OBS |
| `IMPACT_TRAIL_STREAK_M` | 1.2 | no donor length key; reuses port `TRAIL_STREAK_M` | **PA** |

Weapon assignment (`weapon.script:281-287`): all projectiles including arrows
use `bullettrail`; only `OSTRELA` uses `firearrowtrail` (`:286,437`); debris and
howitzer fragments use `fragtrail` (`:288-290,435,438-439`). The port still uses
one generic kind for all three; the two extra alpha/width literals are recorded
but **not** wired to per-projectile selection — **PA, not parity**.

### 3.4 Explicitly NOT added

- **Construction dust** — donor has none: `DFX-01 §7.4` proves the build
  animation is sound-only (`onaclanimationreachedconstruct.inc:23-43`); no
  `buildsmoke`/`buildfire` consumer is readable. No dust kind was created.
- **No donor art**: `musketsmoke.dds`, `musketflash.dds`, `bullettrail.bmp`,
  etc. are private-use. All draw passes are plain untextured quads.
- **No positional audio** (no `audio.gd` edit, no sound calls added).
- **No RNG**: donor `rand*` slots (`pfx.script:39-86`; codes 1..8, 0 = off,
  mirror via `Round(rand)=1`) are documented as RECORDED but not reproduced;
  drift here remains deterministic.
- **No donor FX parity claim** anywhere in code or report.

## 4. Before → after (`variant3d/scripts/world3d_fx.gd`)

All line numbers are from the final edited file.

| # | Before | After | Where |
|---:|---|---|---|
| 1 | No FX-IMPACT-01 header | Header block: donor grounding, PA/UNV policy, billboard-vs-box note, no dust, no audio, no parity | `:67-83` |
| 2 | `LIFE` had 10 legacy kinds | 3 additive kinds: `volley_smoke 1.6`, `muzzle_flash 0.35`, `arrow_trail 0.2` | `:102-107` |
| 3 | No impact constants | 3 donor-cited constant blocks + PA constants (ledger §3) | `:180-237` |
| 4 | `consume_events`, `emit_arrow_trails` only | `emit_donor_shot_fx = false`, `use_donor_arrow_trail = false` — default OFF, no caller behaviour change | `:243-247` |
| 5 | `stats` had no impact counters | Additive `impact_fx_spawned`, `impact_last_kind` | `:257-258` |
| 6 | `add_fx()` only | New `add_impact_fx(kind, pos, life)` donor-key adapter: `shotmusket`/`musketsmoke`→volley smoke, `musketflash`→muzzle flash, `bullettrail`/`firearrowtrail`/`fragtrail`→arrow trail; unknown key → `{}` (matches donor `GetOrCreate` −1, `pfx.script:353-360`) | `:495-516` |
| 7 | `_consume_events()` spawned one `shot` FX | Opt-in: with `emit_donor_shot_fx`, also spawn `muzzle_flash` + `shotmusket` (donor 5-layer minimum, `fx.tree:4-63`) | `:683-688` |
| 8 | `_emit_arrow_trails()` always emitted solid-box `trail` | Opt-in `use_donor_arrow_trail` switches to billboard `arrow_trail` at donor `TimeLimit`/`Alpha`; legacy branch byte-identical when flag false | `:700-731` |
| 9 | Only `_material()` | New `_impact_material()` with `BILLBOARD_ENABLED` (msFaceCamera), optional depth-draw-disabled (ZWrite=False), no donor texture | `:843-864` |
| 10 | `_kind_color()` had 10 legacy kinds | 3 additive donor-tinted kinds | `:907-918` |
| 11 | `_build_visual()` matched legacy kinds only | 3 new branches: 2 billboard smoke quads (256:128 ratio), 1 additive flash quad (alpha hold), 1 billboard trail quad (`MarkWidth 0.1`) | `:978-1014` |
| 12 | `_update_fx()` generic alpha fade only | New per-kind motion/alpha: smoke rise + `AlphaPower 1.5` fade curve, flash alpha HOLD (`OnEndFrameHide`), trail `_orient_impact_trail` with `AlphaFade` linear | `:1204-1239` |
| 13 | `_orient_trail()` (solid box, `look_at`) only | New `_orient_impact_trail()` — billboard placed at head/tail midpoint, length clamped by `MinDistance`/streak, **no** solid box, **no** `look_at` | `:1264-1294` |

**Preserved byte-identically:** the entire `WeatherSnow3D` root and
`set_weather`/`set_weather_month`/`snow_active` API (`:51-65` header,
`:136-157` constants, `:327-340` API, `_snow_band_ok` at `:766`,
`_apply_snow_gate` at `:775`, `_build_snow_emitters` at `:794`), the
`Selection3D` ring/marquee path
(`sync_selection`/`_make_selection_marker`/`_update_selection`),
`draw_ghost`, `draw_rally`, `bind`, `set_world_offset`, `world_pos`,
`_enforce_cap`, `_player_color`, and all legacy FX kinds.

**Expected node-count delta from the smoke atom:** none. The 13/13 atom spawns
legacy `smoke` only and both opt-in flags default false, so measured descendants
remain `10 -> 13` (unchanged from FX-WEATHER-01).

## 5. Validation — variant runner only

No direct `godot`, no gates, no ladder, no tests edited, no temporary probe file
created.

```
python variant3d/tools/godot_runner.py run --id fximpact01-parse --timeout 120 -- --headless --path variant3d --check-only --script res://scripts/world3d_fx.gd
python variant3d/tools/godot_runner.py run --id fximpact01-smoke --timeout 120 -- --headless --path variant3d --script res://tests/t_fx3d.gd
```

| Ticket | Job id | Result |
|---:|---|---|
| 428 | `fximpact01-parse` | **ok**, exit 0, wait 173.66 s, run 6.32 s. `RESULT/00000428.json` status `ok`; **stderr 0 bytes → `SCRIPT ERROR == 0`**. Parse of the edited module is clean. |
| **434** | **`fximpact01-smoke`** | **ok**, exit 0, wait 2.12 s, run 7.89 s. `RESULT/00000434.json` status `ok`; **stderr 0 bytes → `SCRIPT ERROR == 0`**. stdout ends `T_FX3D PASS 13/13 checks`. |

The 13 checks (all PASS): `MODULE_LOADS`, `MODULE_IS_NODE3D`, `CALLABLE_BIND`,
`CALLABLE_SYNC`, `CALLABLE_ADD_FX`, `CALLABLE_DRAW_GHOST`, `CALLABLE_DRAW_RALLY`,
`API_SURFACE`, `FX_ADDS_NODES`, `FX_LIFETIME_EXPIRY_REMOVES_NODES`,
`GHOST_RALLY_CALLS`, `NO_2D_SPRITE_SHEET_LOADS`, `NO_ERRORS`. Godot
4.7.2.stable.official.ed1daf0bf. The runner spool files under
`variant3d/.godot_queue/results/` are tool artifacts, not source edits.

**Not measured:** rendered appearance, donor visual A/B, billboard screening
against an actual camera, the three new branches being individually invoked
(the fixed `t_fx3d.gd` atom spawns legacy `smoke` only — they are **parse
verified** and reachability-verified by the opt-in wiring, not runtime-exercised
by this atom), GPU behaviour, mass-army cost, and any interaction with composed
`world3d.gd`. **No visual parity claim.**

## 6. Explicit PORT APPROXIMATION / UNVERIFIED labels

- **UNVERIFIED (unit mapping)** — every donor literal above (`PixelRatio`,
  `AlphaTime`, `AlphaPower`, `MarkWidth`, `TimeLimit`, `Interval`, `FrameRate`,
  `Position`, `Diffuse`). DFX-01 §6/§9 recovered field names but no consumer
  converting them to metres or seconds. Feeding them into Godot sizes/times is
  a **PORT APPROXIMATION** and is labelled as such at each constant.
- **PORT APPROXIMATION — NOT DONOR PARITY** — all three visual forms: untextured
  billboard quads (`volley_smoke`, `muzzle_flash`, `arrow_trail`) standing in for
  donor animatedsprite sheets, the donor 5-layer composition, and a 4-frame
  flash. The donor's `firepalette` palette shader 30 / `msFaceCamera` ribbon
  geometry / noise shader 31 are not ported.
- **PA (port precedent, not donor truth)** — lifetimes 1.6 s / 0.35 s from
  `world.gd:3567/3564`; 1.2 m trail streak; smoke alpha 0.55; port quad sizes.
- **RECORDED, NOT REPRODUCED** — donor RNG `rand*` codes (`fx.tree:10-12,28-29,
  40-46`), `parentrandom`, `VertLimit 150`, `MinDistance 0.05` sampling,
  `firearrowtrail` alpha 0.3, `fragtrail` width 0.05, donor `Position` offsets
  (axis mapping UNV), 256×4 `firepalette`, mirrored frames, frame/interval
  timing. No RNG, no extra projectile-kind branching, no donor offsets applied.
- **NOT REPRODUCED** — screen-space ribbon alignment: the donor `msFaceCamera`
  strip follows the camera; this module owns no camera reference, so the
  billboard quad is placed at the world midpoint and scaled by segment length.
- **OPT-IN, DEFAULT OFF** — `emit_donor_shot_fx` and `use_donor_arrow_trail`.
  With both false the module behaves exactly as after FX-WEATHER-01.
- **NO PARITY CLAIM** for selection rings, snow, ghost, rally, audio or any
  legacy FX. Nothing there was changed.

## 7. Open questions (do not guess)

1. What are the donor units for `PixelRatio` (175/350/600), `MarkWidth` (0.1),
   `TimeLimit` (0.2), `AlphaTime` (1.5) and `Interval`/`FrameRate`? A windowed
   calibration pass is needed before any opt-in flag is enabled.
2. How should the donor `Position` offsets (X,Y,Z) map to Godot's Y-up axes?
   They are recorded as literals but deliberately not applied.
3. Does `AlphaPower 1.5` describe a fade over `AlphaTime 1.5` s or an exponent
   over the whole sprite life? Only the exponent is used, over a **port** life.
4. `OnEndFrameHide=True` is implemented as alpha-hold-then-cut. Is there a
   donor-defined hide frame or a short tail alpha not visible in the text keys?
5. Which caller should set `emit_donor_shot_fx` / `use_donor_arrow_trail`?
   `world3d.gd` and any config are foreign-owned; no wiring was added there.
6. Should the extra donor trail variants (`firearrowtrail` α0.3,
   `fragtrail` width 0.05) become separate kinds selected by projectile kind?
   That needs a driver ticket; only the literals are recorded now.
7. Is `GPUParticles3D`/billboard rendering acceptable in the GL Compatibility
   renderer? No frame was rendered in this headless smoke test.
8. The donor's 5-layer shot composition (sparks, up-flash, palette shader 30)
   is still reduced to 2 smoke quads + 1 flash quad. No donor sprite is
   copiable under this ownership, so full layer parity is out of scope.

## 8. Summary and scope statement

Three additive, donor-cited FX kinds were installed in the owned module:
`volley_smoke` (2 face-camera smoke quads, donor tint 80/255, `AlphaPower` fade
curve), `muzzle_flash` (additive billboard quad with donor `OnEndFrameHide`
alpha hold), and `arrow_trail` (billboard ribbon using literal `MarkWidth 0.1`
and `Alpha 0.2`, replacing the solid box **when opted in**). A donor-key adapter
`add_impact_fx()` and two default-off flags expose the effects without changing
any existing caller. Every unverifiable conversion is labelled **PORT
APPROXIMATION / UNVERIFIED**; construction dust, positional audio, RNG, donor
art and parity claims are explicitly absent. Final validation: runner ticket
**434**, `id=fximpact01-smoke`, `status=ok exit=0`, `SCRIPT ERROR == 0`,
**T_FX3D PASS 13/13**; plus parse ticket 428 clean.

**No file other than `variant3d/scripts/world3d_fx.gd`, the required backup
`inbox/backup/world3d_fx.gd.bak-FXIMPACT01`, and this report was edited by
FX-IMPACT-01.** No donor file was copied, unpacked or executed; no Godot process
was launched outside `variant3d/tools/godot_runner.py`; no gates or windowed
ladder were run.
