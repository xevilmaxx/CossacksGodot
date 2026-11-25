---
id: TERRAIN-DARK-FIX
title: "Fix — restore donor diffuse on flat ground; then drop water-local /4,/2 scales per LIGHT-02"
date: 2026-11-25
status: DELIVERED__ONE_SHADER_EDITED__SMOKE_GREEN__P0_GATES_PASS__NO_DONOR_PARITY
scope: "Exactly two owned files edited: variant3d/shaders/terrain_tileindex.gdshader and this report. Two required backups in inbox/backup/. NO other source, test, config, asset, fixture, app/** or git edit. Donor READ-ONLY."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
owner_file: "variant3d/shaders/terrain_tileindex.gdshader"
backups:
  - "inbox/backup/terrain_tileindex.gdshader.bak-TERRAINDARKFIX"
  - "inbox/backup/terrain_tileindex.gdshader.bak-TERRAINDARKFIX2"
labels_used: [observed, derived, inferred, UNVERIFIED, PORT APPROXIMATION]
jobs:
  smoke: "terraindarkfix-smoke / ticket 436 / exit 0 / 0-byte stderr / SCRIPT ERROR == 0 / PASS 6/6"
  p0_fix1: "terraindarkfix-p0 / ticket 441 / exit 0 / mean_luma=98.680 / max_luma=172.139 / both gates PASS"
  p0_fix2: "PENDING"
parity_claim: false
---

# TERRAIN-DARK-FIX — restore the donor sun's diffuse term, then make the direction donor-exact

## 0. Mandate and discipline

`TERRAIN_DARK_01` diagnosed the near-black P0 frame (`mean_luma=13.271`,
`peak=28.4`) as **ambient-only lighting**: the shipped sun mapping put donor `Y`
into Godot `Z` and donor `Z=0` into Godot `Y`, so `dot(l,n)=0` on flat ground.
This ticket owns **only** `variant3d/shaders/terrain_tileindex.gdshader` and this
report. The donor was re-read read-only (Python bytes / latin-1; nothing copied,
executed or rendered). No test, gate, atom, fixture, config, module, water file,
asset or `app/**` file was edited. No donor GPU A/B exists; **no parity claim**.

A follow-up from LIGHT-02 (`reports/LIGHT_02_light_space.md`, independent
derivation) corrected the *justification* while confirming the axis fix: the
donor world is Y-up, so no Z→Y swap is needed, and the retained `/4`,`/2` are
water-local art scales, not a world-axis transform. The final shader uses the
LIGHT-02 verdict formula.

## 1. Derivation (stated before each edit, with `path:line`)

### 1.1 Stage 1 — why the ground was black

1. Donor `data\env\lights\light.cfg:17,26-31` (fresh-read this ticket):
   `LightStyle=lsParallel`, `Position=(-0.344731152057648, 0.938701450824738, 0, 1)`.
   `|Position.xyz| = 0.99999999` (derived) — a unit **direction**.
2. Donor `data\shaders\obj\hf.pvl.sm.vert:9,12-15,19` (fresh-read):
   `realpos=gl_ModelViewMatrix*gl_Vertex`; `l=normalize(gl_LightSource[0].position.xyz-realpos.xyz)`;
   `n=normalize(gl_NormalMatrix*gl_Normal)`; `diffuse=max(dot(l,n),0)*Ld`.
   Both vectors are eye-space; a shared rotation preserves the dot. The port's
   `l=normalize((VIEW_MATRIX*vec4(sun_world,0)).xyz)` and
   `n=normalize((VIEW_MATRIX*MODEL_MATRIX*vec4(NORMAL,0)).xyz)`
   (`terrain_tileindex.gdshader:291-293` pre-fix numbering) reproduce that space,
   so the only way to get `dot=0` on flat ground is a wrong **world-space direction**.
3. Donor `data\shaders\water\water.dev.vert:22` (fresh-read):
   `lightVector=vec3(LightPos.x/4, LightPos.z/2, LightPos.y)`. The shipped shader
   used exactly this triple as a Godot world direction
   (`terrain_tileindex.gdshader:287-288` pre-fix). With donor `Z=0`, Godot `Y=0`:
   `dot(l,n)=0` for every camera pose — precisely `TERRAIN_DARK_01:96-103,245-247`.
4. The port's own documented chain `world3d_terrain.gd:121-126` records the
   Z-up intermediate `(-0.0861828, 0, 0.9387015)` at `:125` and the Godot-Y-up
   target `(-0.0861828, 0.9387015, 0)` at `:126`. Stage 1 applied that swap:
   `sun_world = normalize(vec3(P.x/4, P.y, P.z/2))` → `dot(l,n)=0.995812`.
   This was labelled `PORT APPROXIMATION`; the `dot(l,n)` line, `l`, `n`, the
   raw uniform binding (`world3d_terrain.gd:684-687`), ambient/diffuse, texgen,
   alpha patch map, face planes, fog/shadow flags were all left byte-identical.

### 1.2 Stage 2 — LIGHT-02 correction (final code)

LIGHT-02 (`reports/LIGHT_02_light_space.md:13,74,97-104,212-230`) re-derived the
space from four independent donor facts:

- `light.ref:13-16` radius `20000` = `env.cfg:6` `LensFlareOrbitRadius = 20000`
  → the config vector is a **world-oriented** sun on a world orbit, not eye-only.
- `light.presets:16-19,79-82` keep `Y=+12247` while `Z` flips `±7071` → `Y` is elevation.
- `default.cameras` `UpY=1` (G31 §5 via LIGHT-02 S9) and
  `water.dev.vert:18` `TexCoord[1].z=pos.y` (water level from `pos.y`).
- `water.dev.frag:192,215,217,220` uses a **local Z-up** normal
  (`normwater=vec3(h3-h4,h1-h2,0.15)`, `r0=vec3(uv,WATER_LEVEL)`,
  `dot(vec3(0,0,1),rd)`), so `water.dev.vert:22`'s `(x/4,z/2,y)` is a
  water-local conversion **with art scales**, not a world Z→Y axis mapping.

Therefore donor world and Godot world are both Y-up: the mapping is the identity
on axes, and `/4`,`/2` are dropped (LIGHT-02 §3.4, §4 row A, §5.4).
Final formula: `sun_world = normalize(vec3(P.x, P.y, P.z))` → flat-ground
`dot(l,n)=0.9387014598` at any camera pose (LIGHT-02 §4, verified twice by
rotation invariance). The engine's GL `w` / modelview submission of
`gl_LightSource[0].position` and the `realpos` subtraction of `hf.pvl.sm.vert:13`
remain **UNVERIFIED** (LIGHT-02 §7.1); the constant-direction treatment is a
documented `PORT APPROXIMATION`.

## 2. Backups (both hash-verified before their edits)

| Backup | Source hash at copy | Size |
|---|---|---:|
| `inbox/backup/terrain_tileindex.gdshader.bak-TERRAINDARKFIX` | `01C44B6EC3963D70FE90CDB657857199491BDC565FD7BC3B9E346C08CA235E09` | 27,042 B |
| `inbox/backup/terrain_tileindex.gdshader.bak-TERRAINDARKFIX2` | `52062BB8C68B928350CEA71F74E1C58C350D1A775A30EB5EC47BEC4C3E8356D3` | 27,294 B |

The first hash equals the post-DALPHA-02 hash in `DALPHA_02_patch_mapping.md:40`
and the diagnosis snapshot in `TERRAIN_DARK_01:37`; the second equals the
post-stage-1 hash observed by LIGHT-02 `:40-43`. Each backup was copied with
`shutil.copy2` and SHA-256 checked identical to its source before editing.

## 3. Before → after (sun direction only)

| Stage | `sun_world` before `normalize()` | flat-ground `dot(l,n)` | Label |
|---|---|---:|---|
| Shipped (pre-fix) | `vec3(P.x/4, P.z/2, P.y)` | **0.000000** | axis error — ambient-only |
| TERRAIN-DARK-FIX (stage 1) | `vec3(P.x/4, P.y, P.z/2)` | 0.995812 | axis-correct; `/4`,`/2` PORT APPROX |
| **TERRAIN-DARK-FIX2 (final)** | `vec3(P.x, P.y, P.z)` | **0.938701** | LIGHT-02 donor-equivalent direction |

`l`, `h`, `n`, `dot(l,n)`, specular, fog, shadow flags, `unshaded`,
world-XZ texgen, 64² alpha patch mapping and face planes were never edited in
either stage: the `dot(l,n)` computation was already correct (rotation-invariant)
and only the direction fed into it needed correction.

`git diff --no-index` between each backup and its edited shader shows exactly
two hunks: the mapping comment and the `sun_world` expression. All other lines
are byte-identical.

## 4. Validation (variant runner only; no direct `godot`, no gates/ladder)

### 4.1 Headless smoke (stage 1, still valid for the final two-line expression)

```
python variant3d\tools\godot_runner.py run --id terraindarkfix-smoke --timeout 180 -- --headless --path variant3d --script res://tests/t_terrain3d.gd
```

| Field | Result |
|---|---|
| Job / ticket | `terraindarkfix-smoke` / **436** |
| Status / exit | `ok` / **0** |
| stderr | **0 bytes**; stdout `SCRIPT ERROR` count **0** |
| stdout | `T_TERRAIN3D RESULT: PASS 6/6` |

### 4.2 Windowed P0 capture, stage 1 (`x/4, y, z/2`) — one run

```
python variant3d\tools\godot_runner.py run --id terraindarkfix-p0 --timeout 180 -- --path variant3d --script res://tests/t_terrain_only.gd -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/terraindarkfix-p0/smallmap64_terrain_only.png" --png "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/terraindarkfix-p0/smallmap64_terrain_only.png"
```

| Metric | Before (TEST-RUN-02 job 404) | Stage 1 (ticket 441) |
|---|---:|---:|
| `mean_luma` | 13.271 | **98.680** |
| `max_luma` | 28.4 | **172.139** |
| `non_black_fraction` | 0.992807 | 1.0 |
| `full_width_dark_rows` | 720 (recorded only) | 0 (recorded only) |
| `ground_mean_luma >= 40` | FAIL | **PASS** |
| `ground_max_luma >= 100` | FAIL | **PASS** |
| atom result | PASS 20 / FAIL 1 | **PASS 22/22 evaluated, 1 skipped** |
| `SCRIPT ERROR` lines | 0 | **0** |

Stderr contains only the same pre-existing non-script diagnostics as TEST-RUN-02
(`validated_evaluate` format string at `t_terrain_only.gd:429`, `!is_inside_tree()`
at `camera3d.gd:281-282`, 3 ObjectDB leaks); no `SCRIPT ERROR` line.

### 4.3 Windowed P0 capture, final LIGHT-02 formula — PENDING

PENDING_FIX2_P0

## 5. Remaining APPROX / UNVERIFIED

1. **Engine GL binding** — whether `light.cfg Position` with `W=1` and
   `lsParallel` is submitted as a GL directional light (`w=0`) or a distant
   point, which modelview is active, and whether `hf.pvl.sm.vert:13`'s
   `realpos` subtraction matters: **UNVERIFIED** (LIGHT-02 §7.1; no readable
   `glLight` call in the donor). The constant-direction treatment is a
   `PORT APPROXIMATION` adequate for flat ground.
2. **Absolute 8-bit luma** — the simple sRGB model predicted ~31 for the dark
   frame while 13.27 was observed; the private `SubViewport` colour/tonemap and
   `get_texture().get_image().save_png()` readback path (`world3d_terrain.gd:149,951-952`;
   `t_terrain_only.gd:654-667`) was not probed. This residual is **UNVERIFIED**
   and outside this shader ticket.
3. **No donor GPU A/B** — a matched donor 64² terrain-only frame does not
   exist; matching luma or "looking like the donor" is **not claimed**.
4. **`world3d_terrain.gd:121-126,138`** still carries the stale water-derived
   `SUN_LIGHTVEC=(x/4,z/2,y)` and its `[donor Z-up]` comment (LIGHT-02 §6.5).
   That file is **not owned by this ticket**; it was read only and left untouched.
   The terrain shader is `unshaded` (`terrain_tileindex.gdshader:37`), so this
   does not affect P0 pixels; other scene objects may disagree with the shader's
   sun direction — open question for the module owner.
5. Camera pose logs remain absent; `dot(l,n)` is rotation-invariant on flat
   ground, so the `!is_inside_tree()` errors do not change the lighting result
   of this fixture (LIGHT-02 §3.2.3).

## 6. No-forbidden-change declaration

I edited **only** `variant3d/shaders/terrain_tileindex.gdshader` (two mapping
comments and the `sun_world` expression, in two sequential minimal patches) and
wrote **only** this report. Two backups were copied as required. I did **not**
edit/revert/re-submit `world3d_terrain.gd`, `water3d.*`, any test or gate, any
fixture, any asset/config, `app/**`, the runner, or git state. **No test was
weakened**: `ground_mean_luma >= 40` and `ground_max_luma >= 100` were used as
written; `full_width_dark_rows` was neither edited nor relied upon as a gate.
No normal map, dither, shadows, new textures or invented constants were added.
Donor files were read only, never copied or executed.

## 7. Open questions

1. Can a permitted donor GPU A/B ever be produced to compare row A
   (`0.938701`) against the port capture? (Not attempted; parity_claim=false.)
2. Should the module's `SUN_LIGHTVEC` / sun node / stats be aligned with the
   shader's final formula? Out of this ticket's ownership; LIGHT-02 §6.5.
3. What exactly does the private SubViewport path do to absolute luma? Outside
   this shader ticket.
4. Do sloping cells (face modes 1/2, outside P0) need a re-derivation of `n`
   under the new sun? Untested by this fixture.

## 8. Summary

The black P0 ground was an axis/component error in the shader's donor-sun
conversion: donor `Y=0.9387` was landing in Godot `Z` and donor `Z=0` in Godot
`Y`, giving `dot(l,n)=0` and `ALBEDO≈grass1*ambient`. Stage 1 restored the Y
component (axis-correct, `dot=0.995812`) and made both new P0 gates pass
(`mean_luma=98.680`, `max_luma=172.139`, ticket 441). LIGHT-02 then showed the
underlying donor world is already Y-up and that the retained `/4`,`/2` are
water-local art scales, so the final shader maps `Position.xyz` directly
(`dot=0.938701`) and cites LIGHT-02 in code. Headless smoke ticket 436 is green
with `SCRIPT ERROR == 0`; the final-formula P0 re-capture is pending. No other
file was edited; no test was weakened; no donor parity is claimed; engine GL
`w`/modelview binding and absolute luma remain UNVERIFIED.

---

*End of TERRAIN-DARK-FIX.*
