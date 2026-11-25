---
id: CONFIG-WIRE-WATER
task: "Make the 3D water read its constants from the global feature config"
date: 2026-11-25
status: DONE__NO_BEHAVIOUR_CHANGE__HEADLESS_CHECK_ONLY_PASS
scope: "Edited EXACTLY two owned paths: variant3d/scripts/water3d.gd + this report."
owns:
  - variant3d/scripts/water3d.gd
  - docs/coord_swarm_2026-11-25/reports/CONFIG_WIRE_WATER.md
backups:
  - inbox/backup/water3d.gd.bak-CONFIGWIREW
smoke_job:
  runner: "python variant3d\\tools\\godot_runner.py run --id configwirew-smoke --timeout 180 --max-wait 1800 -- --headless --path variant3d --check-only --script res://scripts/water3d.gd"
  ticket: 433
  status: ok
  exit: 0
  script_error_count: 0
---

# CONFIG-WIRE-WATER — wire water3d.gd to features.water.*

Read-first basis: `reports/CONFIG_CORE_01.md` (defaults/getters),
`variant3d/scripts/config.gd:414-461` (typed readers),
`reports/TRN_WATER_implementation.md` (surface/alpha/audit field semantics),
and the pre-edit `water3d.gd` (donor literals, `WATER_SURFACE_Y`, alpha gate,
`stats` audit block). No new config keys; only the three keys added by
CONFIG-CORE-01 are consumed.

## 1. Getter map (config.gd getter → water3d.gd consumer)

| Config path | Typed getter (config.gd) | Fallback = today's value | water3d.gd consumer (after-file lines) |
|---|---|---|---|
| `features.water.surface_y` | `feature_water_surface_y() -> float` (`:454-455`) | `-0.25` | `WATER_SURFACE_Y` (`:36`) — same uniform binding (`:179`), same plane vertices (`:218-221`), same audit values (`:266`, `:270`); assigned at `:165` |
| `features.water.alpha_confine` | `feature_water_alpha_confine() -> bool` (`:457-458`) | `true` | local `alpha_confine` (`:161`, read `:166`) → `stats["water_alpha_confine_config"]` (`:277`). The shader's `water_cell` gate is **not** modified (out of scope, byte-identical) |
| `features.water.shore_prox` | `feature_water_shore_prox() -> bool` (`:460-461`) | `false` | local `shore_prox` (`:162`, read `:167`) → `stats["shore_prox_config"]` (`:278`). Existing descriptive `stats["shore_prox"]` string (`:273-274`) unchanged |

Resolution uses the established null-safe singleton pattern already used by
`camera.gd`/`camera3d.gd`: `var cfg = C3ConfigScript.active; if cfg != null: ...`
(`:163-167`). The `preload` is at `:6`. When no config is loaded, the local
fallbacks (`-0.25`, `true`, `false`) are used, exactly reproducing current runs.

## 2. Before → after (minimal diff: 26 insertions, 1 deletion)

| Before (backup) | After | Hunk |
|---|---|---|
| `:1-2` `extends Node3D` + blank, then V7-84 header | `:1-6` | Added CONFIG-WIRE-WATER comment + `const C3ConfigScript = preload("res://scripts/config.gd")` |
| `:27` `const WATER_SURFACE_Y: float = -0.25 # PORT APPROX…` | `:32-36` | Declaration is now `var WATER_SURFACE_Y: float = -0.25` (same value, same trailing label) preceded by a 4-line explanation. Every *use site* is byte-identical. |
| `:145-147` `func build(...)` → `invalidate()` → `var shader := load(...)` | `:154-167` | Inserted 12 lines: 2 local defaults, `C3ConfigScript.active` guard and 3 getter calls, placed immediately after `invalidate()` and before shader load. |
| `:250-253` end of `stats` block (`water_alpha_gate`, `shore_prox` string) | `:272-278` | Added 4 lines: 2 audit fields for the config-read bools. No existing audit entry was changed. |

**Explicitly byte-identical (verified against the backup):** every
`_material.set_shader_parameter(...)` line including
`"water_surface_y", WATER_SURFACE_Y`; the four `Vector3(..., WATER_SURFACE_Y, ...)`
plane vertices; all donor literals `WATER_LEVEL=-0.25`,
`WATER_SHORE_HEIGHT=-0.1`, `MAX_HEIGHT=2.96`, `COAST_FADE=0.57`,
`DEEP_FADE=1.07`; the shader file itself (not opened for edit); the alpha-gate
description and all other `stats` entries. No config key, getter, shader uniform
or donor constant was added, renamed or retuned.

## 3. Backup

| Item | Value |
|---|---|
| File | `inbox/backup/water3d.gd.bak-CONFIGWIREW` |
| Taken | before the first edit (plain copy of `variant3d/scripts/water3d.gd`) |
| SHA-256 (backup and pre-edit source) | `835B90F87CCC0C9EC97B26B5AD64D9D04A5CA71526B8BDB342A6CDAC1BBE576B` |

Restore is a plain copy back over `variant3d/scripts/water3d.gd` if rejected.

## 4. Validation — variant runner only

```powershell
python variant3d\tools\godot_runner.py run --id configwirew-smoke --timeout 180 --max-wait 1800 -- --headless --path variant3d --check-only --script res://scripts/water3d.gd
```

| Field | Value |
|---|---|
| Ticket / id | 433 / `configwirew-smoke` (unique) |
| argv | `--headless --path variant3d --check-only --script res://scripts/water3d.gd` |
| wait / run | 96.62 s / 7.59 s |
| status / exit | `ok` / `0` |
| stdout | 75 B — `Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org` |
| stderr | **0 bytes** |
| `SCRIPT ERROR` occurrences (stdout + stderr) | **0** |

`SCRIPT ERROR == 0` — confirmed from `variant3d/.godot_queue/results/00000433.json`
and `00000433_configwirew-smoke/{stdout,stderr}.txt`. `--check-only` parses and
type-checks the script; it does not run `load_all()` or exercise a getter at
runtime. No gates, no T0–T4 ladder, no selftest/uitest, no capture, **no direct
`godot` invocation**.

## 5. No-behaviour-change statement

Under the shipped defaults (and with no config loaded) the observable result is
unchanged: `WATER_SURFACE_Y` is still `-0.25`, the shader still receives the
same uniform values, the plane vertices are identical, `waveheight_from_surface_y`
is still `0`, the `water_cell` alpha gate still multiplies `coastfade2` exactly as
before, and the visual/parity claims are untouched. The only new runtime values
are two audit-only `stats` booleans (`true`, `false`) that mirror the already
documented state (gate on, `shore_prox` removed). This is a wiring change, not a
retune; no donor constant was altered and no shader was edited.

## 6. Ownership / untouched files — explicit

Edited: `variant3d/scripts/water3d.gd` and this report only.
NOT edited: `variant3d/shaders/water3d.gdshader`, `config.gd`, `config.json`,
`camera3d.gd`, `input_controller.gd`, `hud.gd`, `world3d_terrain.gd`, `game.gd`,
any test, gate, runner or `app/**` file. Other builders' in-flight changes were
left untouched.

## 7. Open questions

1. **`alpha_confine=false` cannot disable the gate yet.** The gate is a shader
   multiply with no uniform; disabling it would need a shader edit (out of
   scope and would violate the byte-identical constraint). Today the getter is
   read into audit only. If the owner wants a live off switch, a future shader
   ticket must add a uniform and this module must bind it.
2. **`shore_prox=true` cannot restore the removed multiplier.** TRN-WATER
   removed the port-art multiplier from the donor fragment; re-enabling it
   would be a behaviour change and is likewise shader work. The getter is read
   into audit only; default `false` agrees with the shipped state.
3. **Surface-Y A/B remains a PORT APPROX.** Changing
   `features.water.surface_y` now flows into both the uniform and the plane
   vertices (they stay in sync), but the donor plane Y (`gl_TexCoord[1].z`) is
   still UNVERIFIED; a value `>0.8333` restores the donor swell term as an
   explicitly labelled A/B, not recovered donor truth.
4. **Runtime getter call not covered by `--check-only`.** The parse smoke proves
   the script compiles with the new `preload`/var/dist; a later integration
   smoke with a loaded config would be needed to assert getter values at runtime.
5. **Key naming drift.** CONFIG_PLAN_01 sketched `features.render.water.*`;
   CONFIG-CORE-01 shipped `features.water.*`. This ticket follows the shipped
   getters; no new keys were introduced.

## 8. Summary

`water3d.gd` now resolves the three CONFIG-CORE-01 water feature values through
the typed getters via the null-safe `C3ConfigScript.active` singleton, keeping
the exact `-0.25 / true / false` defaults. Only the `WATER_SURFACE_Y` declaration
changed from `const` to `var` so the getter can supply it; all its use sites,
every shader uniform binding, the donor literals `−0.25/−0.1/2.96`, coastfade
`0.57/1.07`, the `water_cell` alpha gate and the shader file are byte-identical.
Two audit-only `stats` fields expose the config-read booleans. Variant-runner
job `configwirew-smoke` (ticket 433, `--check-only`) ended `ok`/exit `0` with
`SCRIPT ERROR == 0`. No behaviour change is claimed or intended; no other file
was edited.
