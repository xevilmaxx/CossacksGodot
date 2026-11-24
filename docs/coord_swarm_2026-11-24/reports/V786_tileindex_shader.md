---
id: V7-86
title: "A2 — Godot 4 tile-index terrain shader: donor representation + exact donor equations"
owner: V7-86 (TERRAIN2-06 task A2)
date: 2026-11-24
status: DELIVERED__SHADER_COMPILES__UNIFORM_ASSERTIONS_PASS__VISUAL_PARITY_UNVERIFIED
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor: "C:\\Games\\Cossacks 3 (READ-ONLY latin-1 text; no file copied, decoded beyond headers, or executed)"
governing_rule: "docs/coord_swarm_2026-11-24/TERRAIN2_CHARTER.md:6-15; V73_ATOMIC_CONTRACT.md:3-4,6-16,26-37"
owns:
  - "variant3d/shaders/terrain_tileindex.gdshader (NEW — sole ownership)"
  - "docs/coord_swarm_2026-11-24/reports/V786_tileindex_shader.md (NEW — this file)"
does_not_edit: "any .gd, existing asset/tool, app/, config, tests (one temp probe was created in variant3d/tests/ and DELETED), or git"
verification: "runner tickets 219/223/226/228/232 (iterations), FINAL ticket 235 'v786-tileindex-shader-probe-final' → status ok, 47/47 assertions, empty stderr"
parity: "UNVERIFIED — no GPU A/B frame; all visual effects are predictions from static donor text"
---

# V7-86 — tile-index terrain shader (TERRAIN2-06 A2)

## 0. Verdict

One new Godot 4 spatial shader was written: `variant3d/shaders/terrain_tileindex.gdshader`.
It implements the **donor representation** required by TERRAIN2-06 §3.4 — a per-cell
integer tile index in `UV2.x`, a V7-85 donor-block atlas, the two donor mask samplers,
eye-plane projected UVs and the 0.125 projected cliff-mask mapping — and, after the
DEEPDEC-02 update, the **exact recoverable donor lighting / shadow / fog equations**
from `hf.pvl.sm.vert` and `hf.pvl.smx3.frag`/`smx9.frag`.

The shader **compiles cleanly** in the headless Godot 4.7.2 runner and exposes all
30 required uniforms. **Visual parity is UNVERIFIED**: no GPU A/B was run, and the
runtime eye-plane/texture-matrix values, the engine face-promotion rule, the tilt
matrix path, the SM20/SM30 selection and the shadow-map binding are all engine-side
and unreadable (DEEPDEC-02 §6; TERRAIN2-06 §6).

---

## 1. Donor evidence → shader equation ledger

All donor paths below are relative to `C:\Games\Cossacks 3\`. Line numbers were
re-read read-only in this agent (`open(...,'rb').read().decode('latin-1').split('\n')`,
1-based); no donor pixel payload was decoded and no donor binary executed.
Where DEEPDEC-02 §3.2 quotes a line number that differs from the literal file, the
**literal file line is cited** and the difference is recorded in §6.

| # | Donor `path:line` (OBSERVED text) | Shader implementation | Class |
|---:|---|---|---|
| D01 | `data\scripts\dmscript.global:2026-2035` — `TMapTerrainDataTile{height,tex,collision[4]}`; `savemapterraindata.inc:16-17` writes `tex=GetTileIndex` | `UV2.x = float(tile_index)`, `v_tile = UV2.x`; atlas cell = `mod(id,cols),floor(id/cols)` | Donor index; **PORT APPROXIMATION** transport via UV2 (donor has no such vertex attribute) |
| D02 | `data\terrain\tiles\terrain.presets:2-5,6` — `Summer`, `DefaultIndex=0`, `grass1` first; shipped `presets_summer.json:2-125` (124 names) | No name→id table in shader; id comes verbatim from UV2.x; `atlas_grid` from V7-85 manifest | Donor id, port atlas packing |
| D03 | `hf.pvl.sm.vert:9` — `realpos=gl_ModelViewMatrix*gl_Vertex` | `realpos = VIEW_MATRIX * MODEL_MATRIX * vec4(VERTEX,1.0)` | Donor equation; matrix API is Godot equivalent |
| D04 | `hf.pvl.sm.vert:12-15` — `e=normalize(-realpos.xyz)`, `l=normalize(lightPos-realpos.xyz)`, `h=normalize(l+e)`, `n=normalize(gl_NormalMatrix*gl_Normal)` | `e/l/h` verbatim; `n` from `VIEW_MATRIX*MODEL_MATRIX*vec4(NORMAL,0)` | Donor equations; **PORT APPROXIMATION** for `gl_NormalMatrix` inverse-transpose |
| D05 | `hf.pvl.sm.vert:18-22` — `ambient=sceneColor+frontAmbient`; `diffuse=max(dot(l,n),0)*Ld`; `if(vertexColor) diffuse*=gl_Color`; `specular=pow(max(dot(h,n),0),shininess)*Ls` | `ambient_rgb + diffuse_rgb*max(dot(l,n),0)`; optional `vertex_color_substitute`; `pow(max(dot(h,n),0),shininess)*specular_rgb` | Donor equation; energies are **PORT APPROXIMATION** uniforms; `gl_Color` has **no donor buffer** (glColorPointer 0 refs, DEEPDEC-02 §3.1) |
| D06 | `hf.pvl.sm.vert:30-32` (`shaders.lib:30 texGen=true`) — `s=dot(realpos,EyePlaneS[0])`, `t=dot(realpos,EyePlaneT[0])`, then `TextureMatrix[0]*` | `v_st = (texture_matrix * vec4(dot(realpos,eye_plane_s),dot(realpos,eye_plane_t),0,1)).xy` | Donor equation; plane/matrix VALUES are **PORT APPROXIMATION / UNVERIFIED** |
| D07 | `hf.pvl.sm.vert:34` — `gl_TexCoord[1]=gl_MultiTexCoord1` | `v_alpha_uv` = `fract(v_st)*alpha_uv_scale` | **PORT APPROXIMATION** (donor second UV set is engine-generated, `tmmUser` s/t planes `(1,0,0,0)/(1,0,0,0)` at `reftile.mat:39-50`) |
| D08 | `hf.pvl.sm.vert:35` — `gl_TexCoord[3]=TextureMatrix[3]*cameraMVM*realpos` | `v_shadow = shadow_matrix * realpos` | **PORT SUBSTITUTE**: two engine matrices folded into one uniform |
| D09 | `hf.pvl.sm.vert:37-38` — `gl_TexCoord[4]=ambient+diffuse`, `[5]=specular` | `v_packed`, `v_specular` carry exactly those two terms | Donor equation |
| D10 | `hf.pvl.sm.vert:41-45` — `gl_TexCoord[0].w=abs(realpos.z)` (ATI) else `length(realpos)` | `v_fog_depth = fog_use_abs_z>0.5 ? abs(realpos.z) : length(realpos)` | Donor vendor branch, exposed as a uniform |
| D11 | `hf.pvl.smx3.frag:13` / `smx9.frag:13` — `color.rgb=texture2D(texUnit0,TexCoord0.xy).rgb`; `shaders.lib:34-49` binds unit 0 | `tile_rgb()` samples `tile_atlas` at atlas cell + `fract(v_st*uv_repeat)` | Donor sampler contract; repeat period is **PORT APPROXIMATION** |
| D12 | `hf.pvl.smx3.frag:14` — `color.a=texture2D(texUnit1,TexCoord1.xy).a`; `reftile.mat:6` `Texture2Name=alpha` | `a = texture(alpha_atlas, v_alpha_uv).a` | Donor sampler contract; UV source APPROX (D07) |
| D13 | `hf.pvl.smx3.frag:17` — `color.xyz=color.xyz*TexCoord[4].xyz+TexCoord[5].xyz` | `rgb = rgb * v_packed + v_specular` | Donor equation; note `gl_Color` multiplies DIFFUSE (D05), never raw albedo |
| D14 | `hf.pvl.smx3.frag:20-30` — `of=1/512` (`:23`), 3 taps at `:26-28`, `sh=sh/3.0` (`:29`), `color*=sh+shadowColor*(1-sh)` (`:30`); `smx9.frag:20-35` — 9 taps `:25-33`, `/9` `:34`, multiply `:35` | `shadow_tap()` + `shadow_taps` branch: both tap sets, both divisors, same multiply; `shadow_offset = 0.001953125` | Donor equations; shadow sampler/projection are **PORT SUBSTITUTE**; profile selection **UNVERIFIED** |
| D15 | `hf.pvl.smx3.frag:34-46` (`smx9.frag:39-51`) — fog modes 1/2/3 with `1.442695` and `mix(gl_Fog.color.xyz,color.xyz,fog)` | `fog_mode` branch with identical constants and `mix(fog_color,rgb,fog)` | Donor equations; `gl_Fog.*` values are engine-bound **PORT APPROXIMATION**; `fog_mode=0` from `colors.lib:36` |
| D16 | `hf.pvl.smx3.frag:50` (`smx9.frag:55`) — `gl_FragColor=color` | `ALBEDO = rgb; ALPHA = a` with `render_mode blend_mix, unshaded` | `unshaded` is a **PORT decision** to avoid shading the donor-final colour twice |
| D17 | `reftile.mat:120-144` — `verticalfront`: `Texture2Name=alphavert` (`:122`), `tmmEyeLinear` (`:129`), S-plane `(1,0,0,0)` (`:130-135`), T-plane `(0,0,1,0)` (`:136-141`), scale `0.125` (`:124-126`); `:146-170` `verticalside`: S `(0,1,0,0)` (`:156-161`), T `(0,0,1,0)` (`:162-167`), scale `0.125` (`:150-152`) | face branch: `vec2(eye.x,eye.y)*face_scale` (front), `vec2(eye.z,eye.y)*face_scale` (side), sampled from `alphavert_atlas` | Donor planes/scale; Z-up→Y-up axis conversion is **PORT APPROXIMATION** |
| D18 | `tiles.mat:142-213` — `rockNvf/rockNvs` bind the **same** `.dds` as flat rock tiles; `tiles.lib:119-136` — `AngleX=0/AngleZ=25` (vf), `AngleX=25/AngleZ=0` (vs) | RGB stays the base tile; **no 25° rotation applied** | Donor metadata only; tilt-to-matrix path is **UNVERIFIED/ENGINE** (DEEPDEC-02 §6 #5) |
| D19 | `reftile.mat:17`, `reftilealpha.mat:17` — `bmTransparency`; `:18` `fcCull`; filtering `:29-37` maNearest/miNearestMipmapLinear | `blend_mix`, `cull_disabled`, sampler hints `filter_nearest_mipmap, repeat_enable` | Blend passes APPROX; `cull_disabled` is a **PORT GUARD** vs port mesh winding (`world3d_terrain.gd:110-112`), not donor fcCull |
| D20 | `reftilealpha.mat:30-37,139-146` — `alpha.bmp` / `alphavert.bmp`, `tiaAlphaFromIntensity`, `tfAlpha`, `maNearest/miNearest` | Three PNG samplers with `.a` channel contract for A1 | Donor mask sources; converted PNGs are A1's output, not shipped |

Cross-check: `shaders.lib:19 tangentSpace=false` and `:27 vertexColor=true`;
`hf.pvl.sm.vert:15` uses `gl_Normal` directly → **no normal-map sampler** in the shader.
`glColorPointer` has **0 references** in donor text (verified 0 hits over
`C:\Games\Cossacks 3\data` text files; DEEPDEC-02 §3.1) → **no `COLOR` attribute used**.

---

## 2. PORT APPROXIMATION ledger (explicit, not donor parity)

1. **Eye-plane and texture-matrix values.** `eye_plane_s/t` default to
   `(1,0,0,0)/(0,1,0,0)`, `texture_matrix` to identity. Donor values are engine-bound
   and not readable (`shaders.lib:30`; `hf.pvl.sm.vert:30-32`; DEEPDEC-02 §6 #4/#6).
   The face planes themselves ARE donor-cited (D17) but are applied in Godot Y-up via a
   converted axis, not the engine's original Z-up texgen matrix.
2. **Face promotion rule.** The donor rule that promotes a base tile to `rockNvf/rockNvs`
   / `sandNf/sandNs` is UNVERIFIED — no readable script names those blocks
   (TERRAIN2-06 UNVERIFIED #2; TERRAIN2-01 §6 #3). The shader consumes `UV2.y` face
   mode from A3/A5; it does not decide promotion. A5's parallel flags remain
   `PORT APPROXIMATION — NOT DONOR PARITY`.
3. **25° tilt.** `AngleX/AngleZ` (tiles.lib:119-136) is metadata only; how it reaches
   geometry or texgen is UNVERIFIED (DEEPDEC-02 §6 #5). Not applied.
4. **SM20 vs SM30 / 3 vs 9 taps.** Both donor tap sets are transcribed exactly, but
   which profile the game selects at runtime is UNVERIFIED (DEEPDEC-02 §6 #4).
   `shadow_taps` is exposed with a neutral 3-tap default.
5. **Shadow sampler and projection.** Donor uses `sampler2DShadow` + projective
   `shadow2DProj` (smx3:3,26-28). Godot exposes no such sampler here, so a regular
   `sampler2D` + manual `.r >= 0.999` compare and `shadow_matrix` are PORT SUBSTITUTES.
   `shadowColor`, `cameraMVM`, `TextureMatrix[3]` values are engine-bound.
6. **Mask UVs.** `gl_TexCoord[1] = gl_MultiTexCoord1` (hf.pvl.sm.vert:34) is replaced
   by `fract(s,t)` (TERRAIN2-06 §3.4). Donor `tmmUser` s/t planes `(1,0,0,0)/(1,0,0,0)`
   (reftile.mat:39-50) have UNVERIFIED engine expansion.
7. **Atlas packing and repeat period.** V7-85 whole-preset-per-cell packing; donor
   `tsDouble`/`ttExtended` sub-atlas math is engine-side (reftile.lib:3-12).
   `fract(s,t)` repeat has no donor metres-per-tile (terrain.lib:5-10; port `TILE_M=2.0`
   is port-only, world3d_terrain.gd:50).
8. **Blending.** One Godot `blend_mix` pass cannot reproduce the donor's fixed-function
   multi-pass `bmTransparency` (engine, TERRAIN2-01 UNVERIFIED #4). `unshaded` + final
   `ALBEDO` is a port decision to prevent double lighting.
9. **Light energies.** `ambient_rgb/diffuse_rgb/specular_rgb` defaults are the readable
   material literals (reftile.mat:52-62,98-102), not the unreadable
   `gl_FrontLightProduct` / `sceneColor` products. `light_position_eye` is a neutral
   substitute for `gl_LightSource[0].position.xyz` (hf.pvl.sm.vert:13).
10. **Vertex colour channel.** `vertexColor=true` and `diffuse *= gl_Color`
    (shaders.lib:27; hf.pvl.sm.vert:20-21) are preserved as a *multiplier on diffuse*,
    but donated via the neutral `vertex_color_substitute` uniform, not a mesh `COLOR`
    array (0 glColorPointer refs). `VCOLOR_FACTOR 2.5` belongs to the Default shader
    (`def.pvl.sm.vert:1,21-25`) and is deliberately NOT applied.
11. **Fog bindings.** `gl_Fog.end/scale/density/color` have no readable runtime values;
    exposed with neutral defaults, except `fog_color` (donor palette, colors.lib:23)
    and `fog_mode=0` (colors.lib:36).
12. **Filtering.** Godot 4 cannot express donor's nearest-mag + nearest-mipmap-linear
    min in one hint; `filter_nearest_mipmap` is the closest (`reftile.mat:32-33`).

---

## 3. Uniform / vertex-attribute contract for A3 integration

### 3.1 Vertex attributes (A3 writes the mesh; A2 reads them)

| Attribute | Meaning | Notes |
|---|---|---|
| `UV2.x` | `float(tile_index)` | Donor `.tex` id, integer-valued; shipped dump ids 0..85. No name→id table in shader. |
| `UV2.y` | face mode `0` ground / `1` verticalfront / `2` verticalside | Port transport of donor refkeys (reftile.mat:1-108/120-144/146-170). **0 is default**, so TERRAIN2-06 §3.1 (`UV2.y=0`) remains valid. A5 supplies nonzero flags later. |
| `NORMAL` | object-space normal | Used for donor Blinn-Phong; port normal comes from central differences (world3d_terrain.gd:123-133). |
| `COLOR` | **NOT USED** | No donor vertex-colour buffer. Use `vertex_color_substitute` if a colour term is needed. |

### 3.2 Uniforms (all 30 confirmed present by the final probe)

| Uniform | GLSL type | Default | Source / who sets it |
|---|---|---|---|
| `tile_atlas` | sampler2D | unbound | A1 `tile_index_atlas.png` — cell = preset index |
| `alpha_atlas` | sampler2D | unbound | A1 converted `alpha.bmp` (reftilealpha.mat:30) — **donor intensity in alpha channel** |
| `alphavert_atlas` | sampler2D | unbound | A1 converted `alphavert.bmp` (:139) — same alpha-channel contract |
| `shadow_map` | sampler2D | unbound | PORT SUBSTITUTE, optional; `shadow_enabled=0` ignores it |
| `atlas_grid` | vec2 | **unset (0,0)** | **A3 MUST set `(cols,rows)` from A1 manifest**; no donor default |
| `eye_plane_s` / `eye_plane_t` | vec4 | `(1,0,0,0)` / `(0,1,0,0)` | APPROX; A3 may bind recovered engine values |
| `texture_matrix` | mat4 | identity | APPROX for `TextureMatrix[0]` (hf.pvl.sm.vert:32) |
| `face_scale` | float | `0.125` | DONOR: reftile.mat:124-126,150-152 |
| `light_position_eye` | vec3 | `(0,0,0)` | APPROX for gl_LightSource[0].position.xyz (vert:13) |
| `ambient_rgb` | vec3 | `0.15686` | DONOR material ambient reftile.mat:52-56,80-84 |
| `diffuse_rgb` | vec3 | `0.78125` | DONOR material diffuse reftile.mat:58-62,86-90 |
| `specular_rgb` | vec3 | `(0,0,0)` | DONOR material specular reftile.mat:98-102,70-74 |
| `shininess` | float | `16.0` | DONOR reftile.mat:76,104 |
| `vertex_color_enabled` | float | `0.0` | PORT; donor config `vertexColor=true` (shaders.lib:27) but no buffer |
| `vertex_color_substitute` | vec3 | `(1,1,1)` | PORT SUBSTITUTE for gl_Color (vert:20-21) |
| `shadow_enabled` | float | `0.0` | PORT (no shadow texture shipped) |
| `shadow_matrix` | mat4 | identity | PORT SUBSTITUTE for vert:35 chain |
| `shadow_offset` | float | `0.001953125` | DONOR `1/512` (smx3:23, smx9:22), literal to satisfy Godot constant-expression rule |
| `shadow_taps` | float | `3.0` | 3=SM20 smx3, 9=SM30 smx9; runtime selection UNVERIFIED |
| `shadow_color` | vec4 | `(0,0,0,0)` | APPROX for engine-bound `shadowColor` |
| `fog_mode` | float | `0.0` | DONOR default palette `FogMode=0` (colors.lib:36) |
| `fog_color` | vec3 | `(0.2352941176,0.3921568627,0.5882352941)` | DONOR palette Fog 60/100/150 (colors.lib:23), literal decimals |
| `fog_density`, `fog_end`, `fog_scale` | float | `0.0` | APPROX for `gl_Fog.*` |
| `fog_use_abs_z` | float | `0.0` | DONOR vendor branch: 0=`length(realpos)` vert:45, 1=`abs(z)` vert:43 |
| `uv_repeat` | vec2 | `(1,1)` | PORT APPROX repeat on `fract(s,t)` |
| `alpha_uv_scale` | vec2 | `(1,1)` | PORT escape hatch for MultiTexCoord1 substitute |
| `face_mode_override` | float | `-1.0` | `<0` = use UV2.y; `>=0` forces all cells to 0/1/2 (A3 convenience before A5) |

### 3.3 Integration steps for A3 (not performed by this agent)

1. Replace `StandardMaterial3D` (`world3d_terrain.gd:100-116`) with a `ShaderMaterial`
   binding this shader; set `atlas_grid` from the V7-85 manifest and bind the three
   A1 PNGs as `ImageTexture` via `Image.load` (the same no-import workaround used at
   `world3d_terrain.gd:90-97`).
2. Add `game.tileblock` to `_dump_from_game()` (`world3d_terrain.gd:139-172`), decode
   uint8 grid, and write `ARRAY_TEX_UV2.x = float(tile_id)`; leave `UV2.y = 0` until A5.
3. Keep `bind/build/invalidate/height_at_world` unchanged (`V73_ATOMIC_CONTRACT.md:12`).
4. Update `stats` with `tile_index_cells`, `tile_index_hist`, `atlas_path`, `uv_model`,
   `face_model` as specified in TERRAIN2-06 A3.
5. Confirm winding with `cull_disabled` already in the shader; do not add a second
   cull setting to the mesh material.

---

## 4. Compile / uniform verification results

All Godot launches went through `variant3d/tools/godot_runner.py run` (V73:37).
Godot reported `v4.7.2.stable.official.ed1daf0bf`. A temporary probe script
`variant3d/tests/_v786_shader_probe.gd` loaded the shader, created a `ShaderMaterial`,
called `get_shader_uniform_list()`, asserted uniform names/defaults/source literals,
and wrote a JSON result. **The probe and its result JSON were deleted after use**;
no test file remains.

| Ticket | Job id | Runner status | What it proved |
|---:|---|---|---|
| 219 | `v786-tileindex-shader-probe` | failed (13.4 s) | Original A2 shader: GDScript probe parse error (`:=` inferred from Variant); no shader verdict. |
| 223 | `v786-tileindex-shader-probe-v2` | timed-out (184 s) | Found a real GLSL error: `filter_nearest_mipmap_linear` is not a valid Godot sampler hint; script also hung after a null-conversion error. |
| 226 | `v786-tileindex-shader-probe-v3` | failed (4.2 s) | Found second GLSL error: `uniform float shadow_offset = 1.0/512.0` — Godot defaults require constant expressions. |
| 228 | `v786-tileindex-shader-probe-v4` | failed (6.0 s) | **No shader errors**: all 30 uniforms present. Only the probe's default-value assertions failed — `ShaderMaterial.get_shader_parameter()` returns null until a value is explicitly assigned. |
| 232 | `v786-tileindex-shader-probe-v5` | failed (2.9 s) | Uniform-list dictionaries in Godot 4.7 carry `name/class_name/type/hint/hint_string/usage`, **no `default_value`**; default assertions switched to source-literal checks. |
| **235** | **`v786-tileindex-shader-probe-final`** | **ok (3.8 s)** | **PASS 47/47; stderr empty** — shader resource loads, `shader_set_code` emits no GLSL compile error, 30/30 uniform names present, 9 donor-cited default literals present, no tile-name→id table in code, no `COLOR` attribute, folded lighting/shadow/fog equations present. |

Important nuance: the headless renderer is Godot's dummy backend, so this proves
**shader parse/compile and uniform interface**, not GPU rendering correctness.
The final PASS ran before the last citation-only comment corrections in the shader;
those edits changed no code token, so the compile result is unchanged.

---

## 5. Correction section — DEEPDEC-02 fold-in (requested update)

DEEPDEC-02 (`docs/coord_swarm_2026-11-24/reports/DEEPDEC_02_terrain_render.md`)
landed while A2 was in progress. The shader was rewritten accordingly:

- Added the vertex Blinn–Phong chain (`realpos/e/l/h/n`, packed `ambient+diffuse`
  and `specular`) and the fragment combine `rgb*TexCoord4 + TexCoord5`, with the
  explicit correction that **`gl_Color` multiplies diffuse, never albedo** and there
  is **no donor vertex-colour array** (0 `glColorPointer` refs). `VCOLOR_FACTOR 2.5`
  was identified as Default-shader-only (`def.pvl.sm.vert:1,21-25`) and not applied.
- Added both PCF tap patterns (`of=1/512`) and both divisor/multiply steps, plus
  fog modes 1/2/3 with `1.442695` and donor-shaped `mix`.
- Used the recovered cliff plane literals S=(1,0,0,0)/T=(0,0,1,0) (front) and
  S=(0,1,0,0)/T=(0,0,1,0) (side) with `tmmEyeLinear` and scale `0.125`.
- Explicitly marked as PORT APPROXIMATION / UNVERIFIED: runtime eye-plane and
  texture-matrix values, how `TextureScale=0.125` and the 25° tilt reach the
  engine matrices, SM20-vs-SM30 selection, shadow sampler/projection/colour,
  `gl_Fog.*` values, and the multi-pass `bmTransparency` blend.
- Citation note: DEEPDEC-02 §3.2's inline line labels for the shadow/fog block are
  shifted relative to the literal donor file (it writes `smx3:19` for `of`,
  `:20-24` taps, `:25` divide, `:32` shadow multiply, `:32-46` fog). The literal
  file reads `of` at `:23`, taps `:26-28`, `/3` at `:29`, multiply `:30`, fog `:34-46`;
  `smx9` reads `of` `:22`, taps `:25-33`, `/9` `:34`, multiply `:35`, fog `:39-51`.
  The equations are verbatim; only the line labels differ. The shader cites the
  literal file lines.

---

## 6. Open questions (do not guess)

1. What are the runtime `gl_EyePlaneS/T[0]` and `gl_TextureMatrix[0]` values for
   flat tiles and for each face refkey? (DEEPDEC-02 §6 #4/#6)
2. Which shader profile is active — `ShadersSM20.HeightField` (smx3) or
   `ShadersSM30.HeightField` (smx9, shaders.lib:914-949)? (DEEPDEC-02 §6 #4)
3. How does `AngleX/AngleZ = 25` enter geometry or texgen? (DEEPDEC-02 §6 #5)
4. What object supplies the per-vertex `gl_Color` channel and what is its value?
   (DEEPDEC-02 §6 #7; no `glColorPointer` refs)
5. What are the engine-bound `gl_Fog.*`, `shadowColor`, `cameraMVM` and
   `TextureMatrix[3]` values?
6. What is the exact sub-rect mapping of `alpha.bmp`/`alphavert.bmp` under
   `tsDouble`/`ttExtended` (reftile.lib:3-12, all values commented)?
7. Which cells the donor promotes to face tiles (A5 flags are an explicit
   `PORT APPROXIMATION`), and whether any non-default seed produces face ids at all.
8. Does the donor's `bmTransparency` blend need more than one Godot pass for
   acceptable appearance? (Requires GPU A/B.)
9. Does A1's converted mask PNG place donor intensity in the alpha channel as
   this shader's contract requires? (A1 output was not yet available at write time.)

---

## 7. Bottom line

`variant3d/shaders/terrain_tileindex.gdshader` is delivered, compiles cleanly in
headless Godot 4.7.2 and exposes a complete, documented uniform/attribute contract
for A3. The donor representation and the recoverable donor equations are ported with
per-line citations; every unreadable engine behaviour is explicitly labelled.
**No visual parity claim is made** — verifying it requires a GPU A/B, and the
face-promotion rule, eye-plane values, tilt matrix path and SM20/SM30 choice remain
UNVERIFIED.

---

*End of report. Only the two owned files were written; the temporary probe and its
result JSON were deleted. No existing .gd, asset, tool, app/, config, test, or git
state was changed by V7-86.*
