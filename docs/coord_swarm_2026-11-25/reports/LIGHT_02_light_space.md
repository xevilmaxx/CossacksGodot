---
id: LIGHT-02
title: "Independent re-derivation of the donor -> Godot light-space mapping for the terrain shader"
owner: LIGHT-02 (donor deep-dive micro-worker; INDEPENDENT second derivation)
date: 2026-11-25
snapshot_at: "2026-11-25T10:46:00+01:00"
git_head: 0628b3cfd2ea1b20bbd5d1566cef7dd0fdeace36
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_DONOR_COPY
scope: "Exactly one new report file. No .gd/.gdshader/asset/config/test/fixture/git edit, no Godot runner job; donor read only (Python bytes/latin-1; never executed or copied)."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor_root: "C:\\Games\\Cossacks 3 (read only)"
labels_used: [observed, derived, inferred, UNVERIFIED]
verdict: "DONOR CONFIG Position IS A WORLD-ORIENTED SUN VECTOR IN A Y-UP WORLD; CONFIG Y IS THE UP/ELEVATION COMPONENT AND MUST BECOME GODOT Y. Correct donor-equivalent sun_world = normalize(vec3(P.x, P.y, P.z)) with P = light.cfg:27-29. TERRAIN-DARK-01 DIAGNOSIS CORRECT but INCOMPLETE; TERRAIN-DARK-FIX axis swap CORRECT, retained /4,/2 scaling a PORT APPROXIMATION."
parity_claim: false
---

# LIGHT-02 -- independent donor -> Godot light-space derivation

## 0. Remit and discipline

This is an **independent second derivation** of the light-space question raised by
`TERRAIN_DARK_01.md` (docs/coord_swarm_2026-11-25/reports/TERRAIN_DARK_01.md). It neither
trusts nor edits the parallel TERRAIN-DARK-FIX work; it re-reads donor text from scratch
(Python `open(...,'rb').read().decode('latin-1')`) and reaches its own conclusion.

Labels used throughout:

- **observed** -- literal donor/port file line or byte fact, freshly read here.
- **derived** -- arithmetic or control-flow consequence of observed facts.
- **inferred** -- plausible reading with an explicit caveat; not a donor literal.
- **UNVERIFIED** -- not provable from readable donor text without running the donor or
  reverse-engineering the engine binary.

**Every key claim below is verified twice** by two independent routes; the second route is
named in the claim table (Section 2) and in the relevant section text. No donor file was
executed, written or copied; no repo source/config/test/asset was changed; no runner job
was submitted. The only file written is this report.

**Concurrency note (observed).** During this session the parallel builder TERRAIN-DARK-FIX
landed an edit to `variant3d/shaders/terrain_tileindex.gdshader` (mtime 2026-11-25 10:44:00,
SHA-256 prefix `52062bb8c68b9283`, size 27,294 B). The pre-fix text read earlier in this
session (`:291-292` = `(x/4, z/2, y)`) is the version analysed by TERRAIN-DARK-01; the
current text (`:291-292` = `(x/4, y, z/2)`) is the landed fix. Both are evaluated below.
No edit by this worker was made to either version.

## 1. Sources

All donor paths are under `C:\Games\Cossacks 3\`; all port paths under the project root.
Donor files were read as bytes and decoded latin-1 (observed; mtime 2019-03-03 18:13:55 for
every donor file below; SHA-256 prefixes recorded for reproducibility).

| # | Source | What was taken from it | Label |
|---:|---|---|---|
| S1 | `data\env\lights\light.cfg:1-40` (SHA `923940d1cd5658e8`, 902 B) | `Ambient :3-6`; `Diffuse :10-13`; `LightStyle = lsParallel :17`; `Specular :20-23`; `Position X=-0.344731152057648, Y=0.938701450824738, Z=0, W=1 :26-31`; `SpotDirection=(0,0,-1,0) :32-37`; attenuation `Const=1, Linear=0, Quadratic=0 :8,15,16`; `SpotCutOff=180 :25` | observed |
| S2 | `data\env\lights\light.ref:9-56` (SHA `72de10836e8ac2b6`, 4518 B) | reference/default light pattern: `Position=(16629.392578125, 11111.4052734375, 0, 1) :13-16`, `LightStyle = lsParallel :48`, same attenuation fields `:26-28` | observed |
| S3 | `data\env\lights\light.presets:3-137` (SHA `f60d30af96a4177b`, 4631 B) | `light2` `Position=(12247.448, 12247.449, 7071.068, 1) :16-19`; `light3` `Position=(-12247.449, 12247.449, 7071.068, 1) :79-82`; `DateTimeHour` tags `:8,:71` | observed |
| S4 | `data\env\env.cfg:6,15-22` | `LensFlareOrbitRadius = 20000 :6`; `LightSourceManager.LoadFromFile = .\data\env\lights\light.cfg :22` | observed |
| S5 | `data\shaders\obj\hf.pvl.sm.vert:1-50` (SHA `55cd2e32777126a9`, 1452 B) | `realpos=gl_ModelViewMatrix*gl_Vertex :9`; `e=normalize(eye-realpos.xyz) :12`; `l=normalize(gl_LightSource[0].position.xyz-realpos.xyz) :13`; `h=normalize(l+e) :14`; `n=normalize(gl_NormalMatrix*gl_Normal) :15`; diffuse `max(dot(l,n),0)*Ld :19`; specular `:23`; fog depth `:42-46`; `ftransform() :49` | observed |
| S6 | `data\shaders\water\water.dev.vert:1-30` (SHA `7ff23ac527254ef7`, 928 B) | `pos=gl_Vertex :14`; `TexCoord[1].z=pos.y :18`; `eyeVector=pos.xyz-eyePosition.xyz :21`; `lightVector=vec3(pos.x/4, pos.z/2, pos.y/1) :22` where the source is `gl_LightSource[0].position` | observed |
| S7 | `data\shaders\water\water.dev.frag:31,48,167,186-192,215-221` (SHA `166cf6625695b9ff`, 8928 B) | `light = vec3(lightVector.x,y,z) :48`; `WATER_LEVEL = TexCoord[1].z :167`; `normwater=normalize(vec3(h3-h4,h1-h2,0.15)) :192`; `r0=vec3(uv, WATER_LEVEL) :215`; `rd=normalize(light-r0) :216`; `grad=dot(normwater,rd) :217`; `gradpos=dot(vec3(0,0,1),rd) :220` | observed |
| S8 | `data\shaders\shaders.lib:2-52` (SHA `a18aa083616e771e`, 63077 B) | register aliases `:2-14`; `ShadersSM20.HeightField` `:15-52`, vertex `hf.pvl.sm.vert :17`, `texGen=true :30`, `vertexColor=true :27`, texUnit0=0/texUnit1=1 `:34,43` | observed |
| S9 | `docs/coord_swarm_2026-11-24/reports/G31_donor_3d_truth.md:26-59,§5` | `default.cameras` `DirZ=-1, UpY=1`; camera tilt -32; fresher heightfield/shader binding confirmation | observed (report) |
| S10 | `docs/coord_swarm_2026-11-25/decomp/DEC_07_cameras_shad...md:§4.3.1,§4.5,§5.1` | `hf*` semantics ledger; `water.dev.vert:22` ledger; camera frame `right=(1,0,0)`, `up=(0,cos32,-sin32)`, `fwd=(0,-sin32,-cos32)` | observed (report) |
| S11 | `docs/coord_swarm_2026-11-24/reports/V760_light_rig.md:§3,§6.1` | prior translation of `light.cfg` into `SUN_POS`/`SUN_LIGHTVEC`; its own §6.1 flags a comment/expression inconsistency | observed (report) |
| S12 | `docs/coord_swarm_2026-11-25/reports/TERRAIN_DARK_01.md:§1-§8` | the diagnosis being independently checked | observed (report) |
| S13 | `variant3d/shaders/terrain_tileindex.gdshader:136-149,270-300` (SHA `52062bb8c68b9283`, 27,294 B; post-fix) | `donor_sun_position :145`; `render_mode ... unshaded :37`; pre-fix `:291-292` `(x/4,z/2,y)` read earlier this session; post-fix `:291-293` `(x/4,y,z/2)` + `VIEW_MATRIX` rotation; `n :295` | observed |
| S14 | `variant3d/scripts/world3d_terrain.gd:118-141,1107,1467` (SHA `d20eeae93f667f99`, 79,939 B) | `SUN_POS :137`; `SUN_LIGHTVEC := Vector3(SUN_POS.x/4.0, SUN_POS.z/2.0, SUN_POS.y) :138` (still un-swapped); sun `look_at_from_position` `:1107`; `stats.sun_direction_yup :1467` | observed |

## 2. Claim table (each claim verified twice)

| # | Claim | Label | Route 1 | Route 2 (independent) |
|---:|---|---|---|---|
| C1 | `light.cfg Position = (-0.344731152057648, +0.938701450824738, 0, 1)`; `lsParallel` | observed | fresh byte read S1 `:17,26-31` | TERRAIN-DARK-01 S12 `:1` + shader uniform default S13 `:145` |
| C2 | The **config Y component is the up/elevation axis**, not Z | derived | S2 `light.ref` has Y=11111, Z=0, magnitude 20000; a Z-up reading makes the default sun horizontal (no flat-ground light) | S3 `light2`/`light3` keep Y=+12247 while Z flips +/-7071; plus S9 `UpY=1` and S6 `:18` water level in `pos.y` |
| C3 | `hf.pvl.sm.vert` computes `l` and `n` in **eye space** and takes `dot(l,n)` there | observed + derived | fresh read S5 `:9,13,15,19` | S10 §4.3.1 ledger + OpenGL fixed-function semantics (`gl_LightSource[i].position` and `gl_NormalMatrix` are eye-space by spec) |
| C4 | The light config is a **world-oriented sun vector / distant world point**, not an eye-space-only vector | derived (strong), engine binding UNVERIFIED | S2 magnitude 20000.0006 == S4 `LensFlareOrbitRadius = 20000` (0.003% agreement) -> sun on a world orbit sphere | S3 time-of-day patterns move the sun in +/-X, +/-Z while Y stays positive -> world-anchored direction, not camera-locked |
| C5 | `water.dev.vert:22` `(x/4, z/2, y)` is a conversion into the **water shader's own Z-up local space**, not a donor-world Z-up -> Y-up axis conversion | derived | S6 `:22` + S7 `:192,215,217,220` (normal Z=0.15 const, `r0=vec3(uv,WATER_LEVEL)`, `dot(vec3(0,0,1),rd)`) | S10 §4.5 records the same expression and the same local Z-up normal convention; S11 §6.1 already flags "donor Z-up" as an unverified comment |
| C6 | Pre-fix shader `(x/4, z/2, y)` gives Godot-Y = donor Z/2 = 0, hence `dot(l,n)=0` on flat ground | derived | pre-fix S13 `:291-292` read this session + S1 `Z=0` | S12 §2 step 4 + independent Python replay (Section 4, row B) |
| C7 | Correct donor-equivalent world vector is `(P.x, P.y, P.z)` -> `dot=0.938701` on flat ground | derived | Section 3 derivation + Section 4 row A | rotation-invariance check: `dot(u_world,n_world)=dot(u_eye,n_eye)=0.93870145975` at 32 deg |
| C8 | Landed TERRAIN-DARK-FIX uses `(x/4, y, z/2)` -> `dot=0.995812` (lit, axis-correct, scaled) | observed + derived | post-fix S13 `:291-293` fresh read | Python replay Section 4 row C; module comment S14 `:126` states the same target vector |
| C9 | Module `SUN_LIGHTVEC` (S14 `:138`) still uses the un-swapped `(x/4,z/2,y)` | observed | fresh read S14 `:138` | grep of `SUN_LIGHTVEC` occurrences S14 `:138,1107,1467` shows no second definition |

## 3. Donor light-space derivation

### 3.1 What the config vector is (world direction, not an eye-space-only vector)

1. **Observed.** `light.cfg:26-31` gives `Position = (-0.344731, +0.938701, 0, 1)`;
   `LightStyle = lsParallel` at `:17`; attenuation is flat (`ConstAttenuation=1`,
   `Linear/Quadratic=0`, `:8,15,16`); `SpotCutOff=180` (`:25`) so no spot cone applies.
   The vector length is `sqrt(0.344731^2 + 0.938701^2 + 0^2) = 0.99999999` (derived,
   Python): it is a **unit direction**.
2. **Observed.** The reference pattern `light.ref:13-16` instead uses
   `(16629.392578125, 11111.4052734375, 0, 1)`, whose length is `20000.0006` (derived),
   i.e. exactly the `LensFlareOrbitRadius = 20000` of `env.cfg:6`. `light.presets`
   (`light2 :16-19`, `light3 :79-82`) places other suns at
   `(+-12247.449, +12247.449, +-7071.068, 1)`.
3. **Derived (verified twice).** In every readable light record the **Y component is the
   large positive elevation** and Z is either 0 or a secondary azimuth offset. In a Z-up
   reading, `light.ref` (Z=0) and `light.cfg` (Z=0) would be *horizontal* suns giving
   `dot(l,n)=0` on flat ground for the default meadow -- absurd. The donor world is
   Y-up, independently confirmed by `default.cameras` `UpY=1` (S9), by the `-32 deg`
   tilt being a rotation about X with the back-offset in Z (S10 §5.1), and by the water
   level being read from `pos.y` (`water.dev.vert:18`). Therefore **config Y is the up
   component** and must map to Godot Y.
4. **Derived.** `W=1` in the config does not make this a near-field headlight: with
   `lsParallel` and zero attenuation the engine either submits a directional light (GL
   `w=0`) or a very distant positional one (`light.ref` at radius 20000 gives <2 deg
   angular change across the whole ~640 m map). Which of these two the binary does is
   **UNVERIFIED** (no readable script calls `glLightfv`; a 1,675-file donor scan found
   0 `glLight` / 0 `SetLight` / 0 `LightSource` API calls outside config files).
   Either way the *direction* is the config XYZ and the port's constant-direction
   approximation is adequate for flat ground.

### 3.2 What the shaders do with the vector (eye space, but rotation-invariant)

1. **Observed.** `hf.pvl.sm.vert:9` `realpos = gl_ModelViewMatrix * gl_Vertex` (eye space);
   `:13` `l = normalize(gl_LightSource[0].position.xyz - realpos.xyz)`;
   `:15` `n = normalize(gl_NormalMatrix * gl_Normal)`; `:19`
   `diffuse = max(dot(l,n),0) * Ld`.
2. **Derived.** `gl_LightSource[0].position` is the GL-transformed light position in
   **eye** coordinates, and `gl_NormalMatrix` is the inverse-transpose of the modelview
   upper 3x3, so `n` is also **eye** space. The donor `dot(l,n)` at `:19` is therefore a
   physically meaningful eye-space dot product: `l` and `n` are in the *same* space, not
   a world/eye mix.
3. **Derived.** A common rotation preserves a dot product. The port shader does exactly
   that: `l = normalize((VIEW_MATRIX * vec4(sun_world,0.0)).xyz)` (S13 `:293`) and
   `n = normalize((VIEW_MATRIX * MODEL_MATRIX * vec4(NORMAL,0.0)).xyz)` (S13 `:295`).
   Hence `dot(l,n) = dot(sun_world, world_normal)` for every camera pose, and the 32 deg
   donor tilt (S9/S10 §5.1) **cannot** change the flat-ground result. This is verified
   numerically in Section 4.
4. **Inferred (caveat).** Treating the config vector as *already eye-space* and omitting
   the `VIEW_MATRIX` rotation would make the sun camera-locked and the dot product
   camera-dependent. That contradicts the world-anchored lens flare / time-of-day light
   patterns of step 3.1.2-3, so the port's rotating `l` is the correct structural analogue.
   The engine-specific `glLightfv` modelview state remains **UNVERIFIED**.

### 3.3 What `water.dev.vert:22` actually is (and is not)

1. **Observed.** `water.dev.vert:22`:
   `lightVector = vec3(gl_LightSource[0].position.x/4.0, gl_LightSource[0].position.z/2.0, gl_LightSource[0].position.y/1.0)`.
2. **Observed.** The water fragment works in a **local Z-up heightfield space**: normal
   `normwater = normalize(vec3(h3-h4, h1-h2, 0.15))` (`water.dev.frag:192`), sample point
   `r0 = vec3(uv, WATER_LEVEL)` (`:215`), up test `dot(vec3(0,0,1), rd)` (`:220`), and
   `WATER_LEVEL` comes from `pos.y` in the vertex stage (`:18`).
3. **Derived (verified twice).** The expression therefore takes an eye-space **Y-up**
   light vector and re-expresses it in the water's **Z-up local** space:
   `newZ = oldY` (up), `newY = oldZ` (view depth), with art factors `/4` and `/2`. It is
   **not** a donor-world Z-up -> Y-up conversion and carries no authority over the
   terrain's world-space sun direction. The V760 comment "[donor Z-up]" at
   `world3d_terrain.gd:122,:125` is a stale/inferred label; V760 itself flags the
   inconsistency in its §6.1, and DEC_07 §4.5 records the expression without endorsing
   the label.
4. **Derived.** Even if one insisted on reading `(x/4, z/2, y)` as a Z-up vector, a
   Z-up -> Y-up conversion must **swap components 2 and 3**:
   `(vx, vy, vz)_Zup -> (vx, vz, vy)_Yup`, i.e. `(x/4, y, z/2)`. The pre-fix terrain
   shader used `(x/4, z/2, y)` *as if already Y-up*, which is the exact axis error
   TERRAIN-DARK-01 reported.

### 3.4 Correct formula (verdict formula)

With `P = light.cfg:27-29` (`P = (-0.344731152057648, 0.938701450824738, 0)`) and both
donor world and Godot world Y-up, the donor-equivalent Godot sun direction is:

```glsl
// donor light.cfg:26-29 Position.xyz -- a WORLD Y-up sun direction (unit length)
vec3 sun_world = normalize(vec3(donor_sun_position.x,
                                donor_sun_position.y,
                                donor_sun_position.z));   // = (-0.344731, +0.938701, 0)
vec3 l = normalize((VIEW_MATRIX * vec4(sun_world, 0.0)).xyz); // hf.pvl.sm.vert:13 analogous
vec3 n = normalize((VIEW_MATRIX * MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz); // :15 analogous
float ndotl = max(dot(l, n), 0.0);                         // hf.pvl.sm.vert:19
```

On flat ground `dot(l,n) = P.y / |P| = 0.9387014598` at *any* camera tilt, including the
donor's 32 deg (Section 4, row A). The `/4` and `/2` factors are deliberately **dropped**:
they belong to the water shader's local-space art convention (Section 3.3) and distort
the donor sun azimuth (X compressed 4x) when applied to a world direction.

## 4. Numeric comparison at the donor's 32 deg tilt

Setup (all derived; verified twice by direct computation and by rotation invariance):

- `P = (x,y,z) = (-0.344731152057648, 0.938701450824738, 0)`; `|P| = 0.99999999` (S1).
- Flat-ground world normal `n_world = (0,1,0)`.
- Camera frame from S10 §5.1 at `theta = 32 deg`: `c = cos32 = 0.848048096`,
  `s = sin32 = 0.529919264`; `right=(1,0,0)`, `up_world=(0,c,-s)`,
  `fwd=(0,-s,-c)`, so `-fwd=(0,s,c)`. World-to-eye for any vector `w`:
  `w_eye = (w.x, w.y*c - w.z*s, w.y*s + w.z*c)`.
- Flat-ground eye normal: `n_eye = (0, c, s) = (0, 0.848048, 0.529919)`.
  (Sanity: the camera's *own* up vector `(0,c,-s)` maps to eye `(0,1,0)`, as expected.)

| Candidate | Godot world vector before normalize | |v| | eye vector at 32 deg | `dot(l,n)` at 32 deg | Interpretation |
|---|---|---:|---|---:|---|
| **A. Direct donor Y-up (raw `P.xyz`)** -- VERDICT formula | `(-0.344731, 0.938701, 0)` | 1.000000 | `(-0.344731, 0.796064, 0.497436)` | **0.938701** | Correct donor-equivalent: strong positive diffuse, camera-invariant |
| **B. Pre-fix shipped: `(x/4, z/2, y)` used as Y-up** | `(-0.086183, 0.000000, 0.938701)` | 0.942649 | `(-0.091426, -0.527700, 0.844496)` | **0.000000** | Exact zero on flat ground -> black/ambient-only (TERRAIN-DARK-01's diagnosis) |
| **C. Landed TERRAIN-DARK-FIX: `(x/4, y, z/2)`** | `(-0.086183, 0.938701, 0)` | 0.942649 | `(-0.091426, 0.844496, 0.527700)` | **0.995812** | Axis-correct and lit; retains water-local `/4,/2` scaling -> PORT APPROXIMATION, brighter than donor |
| **D. Eye-space interpretation of raw `P` (no VIEW rotation)** | n/a (used directly as eye vector) | 1.000000 | `(-0.344731, 0.938701, 0)` | **0.796064** | Lit but camera-locked / tilt-dependent; not donor-like (Section 3.2.4) |
| **E. Eye-space interpretation of B (no VIEW rotation)** | n/a (used directly as eye vector) | 0.942649 | `(-0.086183, 0, 0.938701)` | **0.527700** | Lit at 32 deg *only by accident* of tilt; would change with camera pitch; not a stable fix |
| Control: TERRAIN-DARK-01 Experiment 1B `P=(0,0,1)` through pre-fix formula | `(0, 0.5, 0)` -> `(0,1,0)` | 1.000000 | `(0, 0.848048, 0.529919)` | 1.000000 | Brightens, but invents a sun where donor Z=0; proves only "any upward light" |

Rotation-invariance cross-check (derived, computed twice): for A,
`dot(u_world, n_world) = 0.9387014597520417` and
`dot(u_eye@32, n_eye@32) = 0.9387014597520416` -- identical to 16 digits. This confirms
the 32 deg tilt is irrelevant to the flat-ground diffuse term and that row B's zero is a
**component-assignment** error, not a camera issue.

**Which is consistent with a lit meadow?** A (0.9387) and C (0.9958) both are. B (0) is
not: it yields `v_packed = ambient_rgb = (0.196, 0.184, 0.129)` alone, the near-black olive
signature diagnosed by TERRAIN-DARK-01. D/E are positive but camera-dependent and are
rejected as donor analogues.

## 5. Verdict

1. **Donor light space (derived, verified twice):** `light.cfg Position` is a
   **world-oriented sun vector / distant world point expressed in a Y-up world**. Its
   **Y = 0.938701 is the up/elevation component**; Z=0. `W=1` + `lsParallel` + flat
   attenuation mean a directional-equivalent sun, not a near-field point; the exact GL
   `w`/modelview submission is **UNVERIFIED**.
2. **Eye space (derived):** `gl_NormalMatrix` puts `n` in eye space and
   `gl_LightSource[0].position` is eye space, so `hf.pvl.sm.vert:13-19` is internally
   consistent. The port preserves this by rotating both `l` and `n` through
   `VIEW_MATRIX`; consequently `dot(l,n)` is tilt-invariant and equals the world-space
   dot on flat ground.
3. **Up axis (derived, verified 4 ways):** donor config Y = elevation (light.ref radius
   20000 = lens flare orbit; light2/light3 keep +Y while Z flips sign; camera `UpY=1`;
   water level from `pos.y`). Donor world Y-up -> Godot world Y-up: **no axis swap**.
4. **Single correct Godot equivalent (formula):**
   `sun_world = normalize(vec3(P.x, P.y, P.z))` with `P = light.cfg:27-29`, then
   `l = normalize((VIEW_MATRIX * vec4(sun_world,0.0)).xyz)`, unchanged `n`, unchanged
   `dot(l,n)`. Expected flat-ground `dot = 0.938701` for all camera poses.
5. **TERRAIN_DARK_01: diagnosis RIGHT, direction INCOMPLETE.** It correctly found that
   donor Y landed in Godot Z and donor Z (0) in Godot Y, producing `dot=0` (Section 4 row
   B). But it did not resolve which Godot axis should receive donor Y (its own open
   question 3), and its Experiment 1B (`P=(0,0,1)` -> Godot +Y) only demonstrates that
   *some* upward light restores brightness; it is not donor-faithful. Its quoted framing
   "Donor Z-up -> Godot Y-up uses `water.dev.vert:22`" (shader comment at `:136-139`,
   repeated in TERRAIN-DARK-01 §2 step 4/§5) is a **misattribution** of a water-local
   conversion; this derivation corrects it (Section 3.3).
6. **TERRAIN-DARK-FIX (landed mid-session, shader `:291-293`): axis correction CORRECT --
   do not revert it.** `(x/4, y, z/2)` puts donor Y into Godot Y and gives `dot=0.995812`
   (row C), so the black ground is genuinely addressed. It is still a **PORT
   APPROXIMATION**, not the donor-equivalent: the `/4` on X compresses the sun azimuth
   fourfold (0.995812 vs donor 0.938701) and `/2` on Z=0 is inert here. If strict donor
   fidelity is the goal, adjust `:291-293` to drop both factors (row A). If the V7-60
   water-derived rig is to be preserved as an acknowledged approximation, keep row C but
   label it `PORT APPROXIMATION` explicitly.

## 6. Corrections to TERRAIN_DARK_01 / TERRAIN-DARK-FIX (no edits made by this worker)

1. **TERRAIN_DARK_01 §2 step 4 / §5 ("Donor Z-up -> Godot Y-up uses `water.dev.vert:22`").**
   Replace with: `water.dev.vert:22` is a local eye-Y-up -> water-Z-up conversion with
   art scales (`water.dev.frag:192,215,220`), not a world-axis mapping. Donor world is
   Y-up; Godot world is Y-up; the mapping is identity on axes.
2. **TERRAIN_DARK_01 §4 Experiment 1B.** Keep as a discriminating *brightness* control,
   but do **not** treat it as a donor-fidelity test: `P=(0,0,1)` is not the donor sun.
   The donor-faithful test is row A vs row C vs row B with the real `P`.
3. **TERRAIN_DARK_01 §7 open question 3** ("Does the donor engine treat `light.cfg`
   Position (W=1) as a direction or a distant point?") is **partly resolved** here: the
   reference pattern is a 20000-unit world point and the active config is its unit
   direction; both are world-oriented Y-up suns. The literal GL `w` submitted at bind
   time remains **UNVERIFIED** (no readable script/engine source).
4. **TERRAIN-DARK-FIX shader `:286-287` comment** ("apply BOTH steps of
   `world3d_terrain.gd:121-126` -- donor Z-up at `:125`, then Z-up -> Y-up at `:126`")
   describes a correct *mechanical* swap but rests on the wrong premise ("donor Z-up").
   The swap happens to produce the right axis; the justification should be corrected to
   "config Y is already the up component; map it directly to Godot Y".
5. **TERRAIN-DARK-FIX consistency gap (observed).** `world3d_terrain.gd:138` still defines
   `SUN_LIGHTVEC = Vector3(SUN_POS.x/4.0, SUN_POS.z/2.0, SUN_POS.y)` (un-swapped), driving
   the `DirectionalLight3D` `look_at_from_position` at `:1107` toward
   `(-10.97, 0, 119.50)` -- near the +Z horizon -- and `stats.sun_direction_yup` at
   `:1467`. The terrain shader is `unshaded` (`terrain_tileindex.gdshader:37`), so this
   does not affect the terrain pixels, but the node light used by other scene objects
   and the reported stat now disagree with the shader's fixed sun. The parallel builder
   should align `world3d_terrain.gd:121-126,138` with whichever formula is finally chosen
   (row A or row C). **This worker made no edit.**

## 7. Open questions / UNVERIFIED

1. **UNVERIFIED:** the engine-side GL call that turns `light.cfg Position` (+W) into
   `gl_LightSource[0].position` (which modelview is active, whether `w` is forced to 0
   for `lsParallel`, and whether the `realpos` subtraction of `hf.pvl.sm.vert:13` is
   significant for the unit-length active config). A 1,675-file donor text scan found no
   `glLight`/`SetLight` API call. Does not change the axis conclusion for flat ground.
2. **UNVERIFIED:** whether strict row A (0.938701) or preserved row C (0.995812) is the
   intended port target. Both are lit; only row A is donor-direction-faithful. A donor
   GPU A/B is forbidden here, so no parity claim is made.
3. **UNVERIFIED:** the residual absolute-8-bit-luma factor left open by TERRAIN-DARK-01
   (observed 13.27 vs ~31 predicted by a simple sRGB model); likely SubViewport/readback,
   outside this light-space ticket.
4. **UNVERIFIED:** whether `dot(l,n)` is the only darkness mechanism after the fix
   (specular, fog and mask terms unchanged; not re-measured here -- no runner job).
5. **UNVERIFIED:** the parallel builder's own report, if any, was not yet present at
   snapshot time; Section 5.6 evaluates the *code as landed*, not a builder narrative.

## 8. Summary

Re-reading donor text from first principles: the sun in `light.cfg:26-31` is a
**world-oriented unit direction in a Y-up world** whose **Y component (0.938701) is the
up/elevation axis**. `hf.pvl.sm.vert:9,13,15,19` computes `dot(l,n)` in eye space, and the
port's paired `VIEW_MATRIX` rotation of `l` and `n` is space-consistent and tilt-invariant,
so the 32 deg donor tilt cannot change flat-ground diffuse. The pre-fix mapping
`(x/4, z/2, y)` -- borrowed from the water shader's *local* Z-up convention
(`water.dev.frag:192,215,220`) -- wrongly assigned donor Z to Godot Y, giving exactly
`dot(l,n)=0` (row B). The correct donor-equivalent is
`sun_world = normalize(vec3(P.x, P.y, P.z))` -> `dot=0.938701` (row A). TERRAIN_DARK_01's
diagnosis is **correct** but its direction section is **incomplete/misattributed**;
TERRAIN-DARK-FIX's landed axis swap is **correct and must not be reverted**, though its
retained `/4,/2` factors are a `PORT APPROXIMATION` and the module's `SUN_LIGHTVEC`
(`:138`) remains un-swapped and should be aligned. No code, config, test, asset, git state
or runner job was touched by this worker; no donor file was copied or executed; **this
report is the only file written**.

---

*End of LIGHT-02. Independent derivation; no Godot run, no code edit, no donor copy, no
donor-parity claim.*
