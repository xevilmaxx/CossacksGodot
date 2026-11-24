---
id: V7-60
title: "V7-60 — wire the donor-grounded light/sky rig into the runtime 3D terrain"
agent: V7-60
date: 2026-11-24
status: DONE__PARSE_CLEAN__NODE_TREE_PROBE_19_OF_19__VISUAL_PARITY_UNVERIFIED
verdict: "P0-1 structural fix landed: the WIRED variant3d/scripts/world3d_terrain.gd now creates a WorldEnvironment + DirectionalLight3D with verbatim donor-cited values. No rendered frame was captured; visual parity remains UNVERIFIED."
owns: "variant3d/scripts/world3d_terrain.gd + this report ONLY; no other source/test/app edits, no git operations"
backup: "inbox/backup/world3d_terrain.gd.bak-V760 (Copy-Item, 12963 bytes, taken before the first edit)"
runner_jobs: "variant3d runner tickets 79 (parse PASS), 81 & 84 (temporary-probe harness bugs, superseded), 90 (probe PASS 19/19)"
scope: "singleplayer skirmish path; TABS; no RNG; no 2D bake outputs, no sprite sheets; donor values translated, none invented"
trigger: "AUDIT3D-03 P0-1 — docs/coord_swarm_2026-11-24/reports/AUDIT3D_03_terrain.md:81-89,138-146"
---

# V7-60 — donor light rig for the wired 3D terrain

## 1. What landed

One file changed: `variant3d/scripts/world3d_terrain.gd`. The donor-grounded
sky/sun rig from the **unwired** sibling `variant3d/scripts/heightmap_world3d.gd:114-147`
was translated into the **wired** terrain module (`world3d.gd:70,219-238`) and
is now called from `build()` next to `_make_water(w, h)`. All rig values were
copied verbatim with their existing donor citations (`light.cfg:3-16`,
`light.cfg:26-29`, `water.dev.vert:22`); none were invented or re-tuned.

The emission floor (`EMISSION_RGB = Color(0.06, 0.06, 0.05)`) was deliberately
left **unchanged**: AUDIT3D-03 §5 suggests reducing it, but that would alter an
existing value and is outside this task's "translate, do not invent" scope.

No `app/` file, no `world3d.gd`, no `main.gd`, no `heightmap_world3d.gd`, no
committed test and no donor asset was touched. No git command was run.

## 2. Exact diff

Unified diff, backup (`inbox/backup/world3d_terrain.gd.bak-V760`) → current
(`variant3d/scripts/world3d_terrain.gd`), produced with Python `difflib`
(not git). Post-edit line numbers are listed in §2.1.

```diff
@@ -17,6 +17,8 @@
 #   * one translucent water quad at donor WATER_LEVEL.
 # NO per-chunk dictionaries, NO 2-chunk/frame cap, NO imported sprite sheets,
-# NO RNG. Lighting/environment belongs to V7-9 (scenes/env), so this module
-# does NOT create a WorldEnvironment or a DirectionalLight3D.
+# NO RNG. V7-13 deliberately left lighting to V7-9; V7-60 now ports the
+# donor-cited WorldEnvironment + DirectionalLight3D rig from the UNWIRED
+# variant3d/scripts/heightmap_world3d.gd:114-147 so the WIRED runtime terrain
+# is actually lit. All rig values stay donor-cited; none are invented here.
@@ -33,4 +35,16 @@
 #   variant3d/scripts/game.gd:5564 — height[] -> base64 on save/dump.
+#
+# V7-60 light/sky rig — translated (not invented) from the UNWIRED sibling
+# variant3d/scripts/heightmap_world3d.gd:22-37,114-147. Donor references
+# (read-only text, singleplayer skirmish path):
+#   C:\Games\Cossacks 3\data\shaders\water\water.dev.vert:22 builds
+#     lightVector = (LightPos.x/4, LightPos.z/2, LightPos.y)  [donor Z-up]
+#   C:\Games\Cossacks 3\data\env\lights\light.cfg:26-29 Position =
+#     (-0.344731152057648, 0.938701450824738, 0)
+#   -> donor lightVector = (-0.0861828, 0, 0.9387015) Z-up
+#   -> Godot Y-up        = (-0.0861828, 0.9387015, 0)
+# Donor light colours are literal light.cfg:3-16 Ambient/Diffuse; the ENERGIES
+# below are port-side M0.6 compensation, not donor values.
@@ -38,9 +52,22 @@
 const WATER_LEVEL: float = -0.25          # mapgen.gd:29 C3MapGen.WATER_DEEP; donor literal UNVERIFIED
+
+# V7-60 donor light rig constants (verbatim values + citations from
+# heightmap_world3d.gd:34-37); only the two light.cfg colours are recorded as
+# donor evidence, the rig itself uses the same body as the sibling module.
+const SUN_POS := Vector3(-0.344731152057648, 0.938701450824738, 0.0)  # light.cfg:26-29
+const SUN_LIGHTVEC := Vector3(SUN_POS.x / 4.0, SUN_POS.z / 2.0, SUN_POS.y)  # water.dev.vert:22, then Z-up->Y-up
+const DONOR_AMBIENT := Color(0.196078434586525, 0.184313729405403, 0.129411771893501)  # light.cfg:3-8 (donor evidence)
+const DONOR_DIFFUSE := Color(0.811764717102051, 0.780392169952393, 0.694117665290833)  # light.cfg:11-16 (donor evidence)
+# Port-side M0.6 art compensation (NOT donor values) — kept as cited in the rig.
+const EXPOSURE: float = 1.45
+const AMBIENT_ENERGY: float = 1.10
+const SUN_ENERGY: float = 1.7
 const SPLAT_PATH := "res://assets/terrain/heightmap/splat_albedo.png"
@@ -65,2 +69,3 @@
 # PORT-TUNED art floor (not a donor value): a tiny emission keeps the terrain
-# legible in a standalone no-light probe; V7-9 owns the real donor light rig.
+# legible in a standalone no-light probe. V7-60 leaves this value UNCHANGED —
+# the donor-grounded light/sky rig lives in this module (see _make_environment).
 const EMISSION_RGB := Color(0.06, 0.06, 0.05)
@@ -176,4 +203,45 @@
+# V7-60 — donor-grounded sky/sun rig translated VERBATIM from the unwired
+# variant3d/scripts/heightmap_world3d.gd:114-147. Values/citations: light.cfg:3-16
+# (ambient/diffuse), light.cfg:26-29 (sun position), water.dev.vert:22 (light
+# vector transform). Port-side energies stay flagged as M0.6 compensation.
+# invalidate() frees these children too, so a rebuild cannot stack rigs.
+func _make_environment() -> void:
+	var env := Environment.new()
+	env.background_mode = Environment.BG_SKY
+	env.background_color = Color(0.62, 0.70, 0.66)
+	var sky := Sky.new()
+	var skymat := ProceduralSkyMaterial.new()
+	skymat.sky_top_color = Color(0.18, 0.30, 0.42)
+	skymat.sky_horizon_color = Color(0.36, 0.44, 0.38)
+	skymat.sky_curve = 0.18
+	skymat.ground_bottom_color = Color(0.09, 0.12, 0.07)
+	skymat.ground_horizon_color = Color(0.17, 0.22, 0.14)
+	skymat.ground_curve = 0.10
+	sky.sky_material = skymat
+	env.sky = sky
+	env.tonemap_mode = Environment.TONE_MAPPER_LINEAR
+	env.tonemap_exposure = EXPOSURE
+	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
+	env.ambient_light_color = Color(0.86, 0.88, 0.82)
+	env.ambient_light_energy = AMBIENT_ENERGY
+	var we := WorldEnvironment.new()
+	we.name = "WorldEnvironment"
+	we.environment = env
+	add_child(we)
+
+	var sun := DirectionalLight3D.new()
+	sun.name = "DonorSun"
+	sun.light_energy = SUN_ENERGY
+	sun.shadow_enabled = true
+	sun.directional_shadow_max_distance = 400.0
+	# The donor sun is almost overhead, so look_at with up=+Y is degenerate;
+	# use +Z as the up axis exactly as M0.6 did.
+	sun.look_at_from_position(SUN_LIGHTVEC.normalized() * 120.0,
+		Vector3.ZERO, Vector3.FORWARD)
+	add_child(sun)
@@ -277,4 +345,5 @@
 	_make_water(w, h)
+	_make_environment()
@@ -302,4 +371,5 @@
 		"water_level_m": WATER_LEVEL,
+		"sun_direction_yup": [SUN_LIGHTVEC.x, SUN_LIGHTVEC.y, SUN_LIGHTVEC.z],
@@ -309,4 +379,8 @@
 			"cell_size": "variant3d/scripts/data.gd:23 C3Data.TILE_M (donor metres UNVERIFIED)",
+			"sun_position": "data/env/lights/light.cfg:26-29 (SUN_POS, donor Z-up)",
+			"sun_light_vector": "data/shaders/water/water.dev.vert:22 (x/4, z/2, y) then Z-up->Y-up",
+			"ambient_diffuse": "data/env/lights/light.cfg:3-16 (Ambient/Diffuse literals)",
+			"light_rig_port": "variant3d/scripts/heightmap_world3d.gd:114-147 (V7-60, translated)",
```

### 2.1 Post-edit line map (`variant3d/scripts/world3d_terrain.gd`)

| Current line(s) | Change |
|---|---|
| `:18-22` | Stale "does NOT create a WorldEnvironment/DirectionalLight3D" comment replaced with the V7-60 rig provenance. |
| `:37-48` | Donor reference block for `water.dev.vert:22`, `light.cfg:26-29`, `light.cfg:3-16`; port-side energies labelled as M0.6 compensation. |
| `:54-64` | New cited constants: `SUN_POS` `:57`, `SUN_LIGHTVEC` `:58`, `DONOR_AMBIENT` `:59`, `DONOR_DIFFUSE` `:60`, `EXPOSURE` `:62`, `AMBIENT_ENERGY` `:63`, `SUN_ENERGY` `:64`. |
| `:69-71` | Emission-floor comment refreshed; **`EMISSION_RGB` value unchanged**. |
| `:205-242` | `_make_environment()` — body copied verbatim from `heightmap_world3d.gd:114-147`. |
| `:246-254` | `invalidate()` unchanged; it already frees every child, so the rig is removed on rebuild (no stacking). |
| `:346-347` | `build()` now calls `_make_water(w, h)` then `_make_environment()`. |
| `:373` | `stats.sun_direction_yup` added (same field name/value as the donor module). |
| `:381-384` | Four `stats.donor_references` entries citing the light sources and the port origin. |

## 3. Donor evidence and translation fidelity

| Value in the new rig | Current file:line | Donor / port source | Translation |
|---|---|---|---|
| `SUN_POS = (-0.344731152057648, 0.938701450824738, 0)` | `:57` | `data/env/lights/light.cfg:26-29` `Position` | Verbatim |
| `SUN_LIGHTVEC = (SUN_POS.x/4, SUN_POS.z/2, SUN_POS.y)` | `:58` | `data/shaders/water/water.dev.vert:22` (`lightVector = (LightPos.x/4, LightPos.z/2, LightPos.y)`), donor Z-up → Godot | Verbatim expression from `heightmap_world3d.gd:35` (see §6.1) |
| `DONOR_AMBIENT = (0.1960784…, 0.1843137…, 0.1294117…)` | `:59` | `light.cfg:3-8` Ambient | Verbatim; recorded as donor evidence |
| `DONOR_DIFFUSE = (0.8117647…, 0.7803921…, 0.6941176…)` | `:60` | `light.cfg:11-16` Diffuse | Verbatim; recorded as donor evidence |
| `EXPOSURE = 1.45`, `AMBIENT_ENERGY = 1.10`, `SUN_ENERGY = 1.7` | `:62-64` | Port-side M0.6 compensation (explicitly **not** donor values in `heightmap_world3d.gd:29-30,42-46`) | Verbatim, still labelled non-donor |
| `BG_SKY`, sky/ground colours and curves, `TONE_MAPPER_LINEAR`, `AMBIENT_SOURCE_COLOR`, `Color(0.86,0.88,0.82)`, `DonorSun` name, `shadow_enabled=true`, `directional_shadow_max_distance=400.0`, `look_at_from_position(..., Vector3.ZERO, Vector3.FORWARD)` | `:210-242` | `heightmap_world3d.gd:114-147`, whose comments cite the donor text above | Function body copied verbatim; no value added, removed or re-tuned |

`DONOR_AMBIENT`/`DONOR_DIFFUSE` are **not consumed** by `_make_environment()`:
the sibling function sets `env.ambient_light_color = Color(0.86, 0.88, 0.82)`
directly (a port-tuned value), and those two constants were already unused
there. They were carried over verbatim as the donor evidence the audit relies
on; substituting them would have changed the function body and is therefore
out of scope (see §6.2).

## 4. Before / after node-tree evidence

**BEFORE (static evidence only — no pre-edit runtime probe was run).**
The backed-up file `inbox/backup/world3d_terrain.gd.bak-V760` contains no
`WorldEnvironment`, no `DirectionalLight3D`, no `_make_environment` and no call
to one; `build()` ends with `_make_water(w, h)` only, and its own header says
"this module does NOT create a WorldEnvironment or a DirectionalLight3D".
AUDIT3D-03 agrees: E11 (`world3d_terrain.gd:19-20,43-45`), E12
(`heightmap_world3d.gd:34-37,114-147` — rig present but no caller) and E13
(`scenes/main.tscn`, `project.godot` — no scene-level environment). The rig
therefore never appeared in the runtime node tree; the terrain relied on its
emission floor and the project clear colour. Statement is OBSERVED from source
and the backup, **not** measured from a pre-change frame.

**AFTER (measured — temporary probe, ticket 90).** The probe loaded the real
module, bound a small deterministic stub game (8×8 base64 `height` grid, no
RNG), called `bind()` + `build()`, then walked the actual node tree. Persisted
result: `variant3d/tests/results/v760_light_probe.json:121-127`:

```
@Node3D@2 [Node3D]
  HeightmapTerrain [MeshInstance3D]
  WaterPlane [MeshInstance3D]
  WorldEnvironment [WorldEnvironment]
  DonorSun [DirectionalLight3D]
```

Measured rig properties (same JSON, all 19 checks PASS):

| Property | MEASURED | Expected (donor / translated) |
|---|---|---|
| `WorldEnvironment` present / named | true / `WorldEnvironment` | present / `WorldEnvironment` |
| `background_mode` | `2` (`BG_SKY`) | `Environment.BG_SKY` |
| `background_color` | `(0.62, 0.7, 0.66, 1.0)` | `Color(0.62, 0.70, 0.66)` |
| sky material | `ProceduralSkyMaterial` | `ProceduralSkyMaterial` |
| sky top / horizon / curve | `(0.18,0.3,0.42)` / `(0.36,0.44,0.38)` / `0.18000000715256` | `(0.18,0.30,0.42)` / `(0.36,0.44,0.38)` / `0.18` |
| ground bottom / horizon / curve | `(0.09,0.12,0.07)` / `(0.17,0.22,0.14)` / `0.10000000149012` | `(0.09,0.12,0.07)` / `(0.17,0.22,0.14)` / `0.10` |
| tonemap / exposure | `0` (`TONE_MAPPER_LINEAR`) / `1.45000004768372` | `LINEAR` / `1.45` |
| ambient source / colour / energy | `2` (`AMBIENT_SOURCE_COLOR`) / `(0.86,0.88,0.82,1.0)` / `1.10000002384186` | colour source / `Color(0.86,0.88,0.82)` / `1.10` |
| `DonorSun` present / named | true / `DonorSun` | present / `DonorSun` |
| `light_energy` | `1.70000004768372` | `1.7` |
| `shadow_enabled` / `directional_shadow_max_distance` | `true` / `400.0` | `true` / `400.0` |
| sun local origin | `(-10.9711351, 0.0, 119.4974213)` | `SUN_LIGHTVEC.normalized()*120 = (-10.97114, 0, 119.4974)` |
| sun `basis.z · origin_dir` | `0.9999…` (both `(-0.091426, 0, 0.995812)`) | aims at `Vector3.ZERO` |
| `stats.sun_direction_yup` | `(-0.08618278801441, 0.0, 0.93870145082474)` | donor expression result |

Floats above are float32 round-offs from the live engine, not edited values.

## 5. Verification — variant3d runner jobs

All jobs via `python variant3d\tools\godot_runner.py run --id <id> --timeout <s> -- ...`
(no direct Godot launch). The temporary probe was `variant3d/tests/_v760_light_probe.gd`;
it was **deleted** after the passing run (`Test-Path` → `False`). Its JSON
result was kept under `variant3d/tests/results/`.

| Ticket | id | Command / purpose | Result |
|---|---|---|---|
| 79 | `v760-parse` | `--headless --path variant3d --check-only --script res://scripts/world3d_terrain.gd` | **PASS** — `status=ok`, `exit=0`, `run=5.05 s`, `wait=140.62 s`; stdout = Godot 4.7.2.stable banner only; stderr 0 bytes. Parse clean. |
| 81 | `v760-light-probe` | first temp-probe run | FAILED — probe harness bug only: `root.add_child(StubGame)` where the stub extends `RefCounted` (`Invalid argument for "add_child()"` at probe `:124`). Module not implicated. |
| 84 | `v760-light-probe2` | second temp-probe run | FAILED 17/19 — probe harness bug only: `sun.global_transform` returns identity while the `SceneTree` is still in `_initialize()` (`Condition "!is_inside_tree()"`). Switched the probe to the node's local `transform` (parent is identity). Module not implicated. |
| 90 | `v760-light-probe3` | final temp-probe run | **PASS** — `status=ok`, `exit=0`, `run=4.65 s`, `wait=194.22 s`; **19/19 checks PASS**, stderr 0 bytes. Node tree and all donor values in §4 MEASURED. |

Result artefacts (runner spool, read-only):
`variant3d/.godot_queue/results/00000079.json` and
`00000079_v760-parse/{stdout,stderr}.txt`;
`00000081.json`, `00000084.json`,
`00000090.json` and `00000090_v760-light-probe3/{stdout,stderr}.txt`.
Probe report: `variant3d/tests/results/v760_light_probe.json`.

`--check-only` proves parse/static analysis only; ticket 90 proves the node
tree and property values after `build()`. **No rendered frame was captured in
this task — visual parity is UNVERIFIED** (AUDIT3D-09 remains the owner of
render proof).

## 6. Open questions

1. **UNVERIFIED / donor comment inconsistency (translated, not corrected):**
   `heightmap_world3d.gd:35` comments `SUN_LIGHTVEC` "then Z-up->Y-up", but the
   expression `(x/4, z/2, y)` evaluates to the **Z-up** vector
   `(-0.0861828, 0, 0.9387015)`. The rig therefore places the sun at
   `(-10.97, 0, 119.50)` — near the horizon at +Z — even though the copied
   comment at `:238-239` says the donor sun is "almost overhead". Both the
   expression and its comment were carried over verbatim per "translate, do not
   invent". A donor-fidelity decision is needed before changing either.
2. **UNVERIFIED / donor evidence not consumed:** `DONOR_AMBIENT` /
   `DONOR_DIFFUSE` (`light.cfg:3-16`) are recorded but the verbatim rig body uses
   the port-tuned `Color(0.86, 0.88, 0.82)` as `ambient_light_color`. Substituting
   the donor literals would change the body; deferred to a parity decision.
3. **UNVERIFIED:** the unchanged emission floor (`EMISSION_RGB`, `:71`) may still
   wash out the new donor sun. AUDIT3D-03 §5 suggests reducing it; that would
   alter an existing value and was intentionally left out of this port.
4. **UNVERIFIED:** no runtime frame/shadow comparison; this job measured the
   node tree and properties, not pixels. Visual parity remains UNVERIFIED.
5. **UNVERIFIED:** `world3d.gd` and V7-9 scene/env work were not edited (out of
   ownership). If another `WorldEnvironment`/`DirectionalLight3D` is later added
   at scene level, this module's rig could duplicate it.
6. **UNVERIFIED:** rebuild stacking was reasoned (`invalidate()` frees all
   children) but not probed with two consecutive `build()` calls.
7. **OBSERVATION:** the probe used an 8×8 synthetic deterministic grid, not the
   320×320 `g32_dump.json`; geometry counts were not re-measured here (V7-31
   owns that contract).
