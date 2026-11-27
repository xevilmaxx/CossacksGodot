---
id: DEC-U-COLOR-GAMMA
ticket: "TERRAIN-SWARM-2026-11-26 / DEC-U-COLOR-GAMMA — exact donor terrain color/gamma pipeline from t_87f0f3c130b0"
agent: "DEC-U-COLOR-GAMMA (READ-ONLY subagent; no code, no Godot, no git; donor read-only, never executed/copied)"
date: 2026-11-26
status: DELIVERED__ONE_REPORT_ONLY__NO_PARITY_CLAIM
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor_root: "C:\\Games\\Cossacks 3"
target_pinned: "t_87f0f3c130b0 (cossacks.exe, PE x86 32-bit, 5768048 B, sha256 87f0f3c130b0...)"
labels_used: [O, D, I, U, "RUNTIME PROBE", "PORT INSTRUCTION"]
parity_claim: false
scope_guard: "Exactly one repo file written (this report). No repo code/shader/config/asset/test/git/Godot edit. Donor binary never executed, copied, patched or committed. Every native address is a pinned VA in t_87f0f3c130b0; every donor-text value cites path:line. sceneColor=0.2 is settled [O] and is not re-proven here."
---

# DEC-U-COLOR-GAMMA — donor terrain material / light-w-modelview / gamma / texel-modulation pipeline

## 0. Result in one paragraph

This pass closes nothing numerically beyond what `DEC_U_renderer_residual.md` and
`DEC_U_scenecolor_glstate.md` already closed, and invents no float or gamma
constant. What is [O] comes from donor TEXT (`reftile.mat`, `light.cfg`,
`colors.lib`, `shaders.lib`, `hf.pvl.sm.vert`, `hf.pvl.smx3.frag`,
`tonegamma.frag`/`tonecontgamma.frag`, `posteffects.shaders`) with file:line, or
from CODE slot/enum maps already byte-proven in the parent passes
(`sub_88f3e8` material slots, `sub_4d08bc` light slots, `sub_4d13d4` prologue,
`0x8f58dc` sceneColor). What stays [U] — the exact terrain float vectors at the
`glMaterialfv` call sites, the `w` + modelview active at `glLightfv(GL_POSITION)`
(`0x4d0963`), the numeric gamma curve/level and fade at terrain output, and the
final framebuffer bytes — each gets an exact GL/state/uniform capture probe in
§7 that terminates only on zero mismatches. The port notes in §8 are
label/telemetry-only and preserve `color_unify_gain=1.0` (neutral) plus every
landed user mod (`color_unify`, `shader/mesh fixes`, hires/array-atlas,
light-match, shore-alpha labels). **No donor visual parity is claimed. No donor
GPU A/B frame exists.**

Context: `DEC_U_renderer_residual.md` closed material/light slot→enum maps but
left terrain material floats, light w/modelview, and output arithmetic [U];
`sceneColor=0.2` is settled [O] (`0x8f58dc` → `glLightModelfv` at `0x4d13f1`).
The port carries a user-mod `color_unify` (`color_unify_gain`, default
`vec3(1.0)`, preserve-only) plus `shader/mesh fixes` user mods.

---

## 1. Method, pin discipline and multi-pass ledger

### 1.1 Discipline

- Pinned target for every native citation: `t_87f0f3c130b0`. No
  `core_target_open`/`select`, no global active-target switch, no `editor.exe`
  read in this pass.
- Donor binaries never executed, copied, patched, committed or debugged. Native
  facts are reused only through the recorded evidence ids of the two parent
  passes; no new `native_*` execution was performed by this worker.
- Starting documents re-read in full this pass:
  `DEC_U_renderer_residual.md`, `DEC_U_scenecolor_glstate.md`,
  `variant3d/shaders/terrain_donor_shader.gdshader` (350 lines),
  `variant3d/scripts/terrain_donor_mesh.gd` (material/light/color-unify sites),
  `variant3d/config.json` (`features.terrain.color_unify`).
- Donor text re-read directly from disk (read-only): `reftile.mat`,
  `light.cfg`, `colors.lib`, `shaders.lib`, `hf.pvl.sm.vert`,
  `hf.pvl.smx3.frag`, `tonegamma.frag`, `tonecontgamma.frag`, `tone.frag`,
  `posteffects.shaders`.
- Pass budget: ≤4 passes per lead. Strange decompiles: none new; the two logged
  in `DEC_U_scenecolor_glstate.md` §2.3 remain excluded and are not cited here.

### 1.2 Multi-pass ledger

| Lead | Pass 1 (donor text) | Pass 2 (parent CODE reuse) | Pass 3 (shader/helper cross-check) | Pass 4 (port line audit) | Accepted |
|---|---|---|---|---|---|
| Material floats | `reftile.mat:52-104` both faces | `sub_88f3e8` slot→enum [O] (`ev_45d056ba…`, 85 insns: `0x88f418/446/474/4a2/4d0`) | `hf.pvl.sm.vert:18-23` product shape | `mesh:183-184`, `shader:142-144` | text [O]; upload [U-MAT] + P-MAT |
| Light w/modelview | `light.cfg:2-38` full record | `sub_4d08bc` 10-pname path [O] (`ev_b44f26b3…`, 164 insns; `0x4d0963` POSITION after `glMultMatrixf`) | `hf.pvl.sm.vert:9,13` realpos/subtraction | `mesh:249-252`, `shader:133,278-281` | path [O]; w+matrix [U-LIGHT] + P-LIGHT |
| sceneColor | settled, not re-read | `0x8f58dc` 16 B `ev_0cb2b604…` → `0x4d13f1` | `hf.pvl.sm.vert:18` | `shader:145`, `mesh:128-129` | [O] preserved, guard |
| Gamma/level | `reftile.mat:25-26,36` + tone frags + `posteffects.shaders` | `sub_4d13d4` has no gamma upload (prologue `ev_39378c31…` fully typed) | `hf.pvl.smx3.frag:13-17,33-50` linear, no pow | port has no gamma lift (guard) | text [O]; curve/level/fade [U-GAMMA] + P-GAMMA |
| Texel modulation | `shaders.lib:16-51,915-951` texUnit binding | N/A (fragment text) | `hf.pvl.smx3.frag:13-14,17,50` | `shader:302-349` | [O] text; framebuffer bytes [U-OUT] + P-OUT |
| Port mods | `config.json:18,31` color_unify label | N/A | N/A | `shader:157-161,288`; `mesh:982-1067,1563-1591,1596-1629` | preserve-only, label-only |

---

## 2. Evidence register

Reused verbatim from the parents — no id is re-minted, no address is moved.
New rows are donor-text reads with path:line (this worker's own reads).

| Evidence id | Operation | Establishes |
|---|---|---|
| `ev_45d056bab2e2416cfb52a7c6d39b1a82f44afc7c3790bf2cbf7a4d32a97d2055` | raw `sub_88f3e8`, 85 insns | material slot→enum: `glMateriali 0x1601=GL_SHININESS` (`0x88f418`); `glMaterialfv 0x1600=GL_EMISSION` (`0x88f446`), `0x1200=GL_AMBIENT` (`0x88f474`), `0x1201=GL_DIFFUSE` (`0x88f4a2`), `0x1202=GL_SPECULAR` (`0x88f4d0`); face in ecx |
| `ev_b44f26b38e7f63961b71e1fdf699eba619dedc2036dd81809916b722efbfd` | raw `sub_4d08bc`, 164 insns | light slot→enum `0x1200..0x1209` + per-light `glEnable(GL_LIGHT0+i)`; `glMultMatrixf` before `GL_POSITION` at `0x4d0963` |
| `ev_39378c31c7258e7508e81325dcbb3e8503dfa54d0b1cf43ada54de88bee37b9538f` | raw `sub_4d13d4`, 87 insns | prologue immediates incl. `0x4d13ec push 0xb53`, `0x4d1404/0x4d1412 push 0xb52`, `0x4d13f1 glLightModelfv`; full enum table |
| `ev_0cb2b604f010ba08bf5b9fd532a946bf7408cf1c4e666986186739aa24fc14ef` | bytes `0x8f58dc`, 16 B | `cdcc4c3e cdcc4c3e cdcc4c3e 0000803f` = `(0.2f,0.2f,0.2f,1.0f)` |
| `ev_b11e6a798ab4c1f0cc7ef8248bcd5265d96d72c3cb72c3cd92e5b5` | bytes `0x4d0ef0` | `05 00 00 00` → `byte[+0x123]=5`, `GL_LIGHT_MODEL_TWO_SIDE=GL_FALSE` at startup |
| `ev_fadb2880f0f4e7dd3f2c25aae03687964c0a399ae644726c72d1c8e7d00b96cd` | `C:\Games\Cossacks 3\data\terrain\ref\reftile.mat` text | material floats both faces; `Texture` block `imagebrightness/ImageGamma/texturemode`; face eye-linear planes |
| `ev_ed96da32e89d1b6529a7d6c8e9f0a4b791ac906da32cda4f34ea147a83` | `C:\Games\Cossacks 3\data\env\lights\light.cfg` text | sun position/ambient/diffuse/specular/`lsParallel` record |
| `ev_d6da102c8c9cdd531fb3cb61be88bda8bc2c0744d5b52` | `C:\Games\Cossacks 3\data\env\colors\colors.lib` text | `FogMode=0`, fog/HFog/shadow fields; statictable order |
| `ev_80043e7bf61b2f008364d06cdb5087c0688f644725190e9415c155c4b` | `C:\Games\Cossacks 3\data\shaders\shaders.lib` text | HeightField `texUnit0=0,texUnit1=1,texGen=true`, `cameraMVM/fogMode/shadowed/vertexColor/texShadow` flags |
| `ev_83d90ad0d5cfc53b272e6d79d18ea537016d4f900c4c386d77e3f9c04c7c52c` | `hf.pvl.sm.vert` text | `:9` realpos, `:13` light subtraction, `:18-23` ambient/diffuse/specular, `:26-39` texgen/TexCoord packing |
| `ev_1122470077454cdfb1fc1c5b9ac1b953c2f0411d98738d9ce64207a779f18e4f` | `hf.pvl.smx3.frag` text | `:13` rgb, `:14` alpha, `:17` `rgb*packed+spec`, 3-tap shadow, 4 fog modes, `:50` FragColor |
| NEW-TEXT-01 | `C:\Games\Cossacks 3\data\terrain\ref\reftile.mat:25-26,36` (this pass) | `imagebrightness=1`, `ImageGamma=1`, `texturemode=tmModulate` |
| NEW-TEXT-02 | `C:\Games\Cossacks 3\data\terrain\ref\reftile.mat:52-76,80-104` (this pass) | ambient `0.15686`, diffuse `0.78125`, emission `0`, specular `0`, shininess `16`, both faces |
| NEW-TEXT-03 | `C:\Games\Cossacks 3\data\env\lights\light.cfg:2-38` (this pass) | ambient/diffuse/specular floats; `LightStyle=lsParallel`; `Position=(-0.344731152057648,0.938701450824738,0,W=1)`; `SpotCutOff=180`; attenuations `1/0/0` |
| NEW-TEXT-04 | `C:\Games\Cossacks 3\data\shaders\tone\tonegamma.frag:4-16,22-37` (this pass) | post tone (`blurOpacity/hdrIntencity/mulColor/brightMax`) then gamma via `colorCurveSampler` LUT + `fade` mix; no numeric curve in file |
| NEW-TEXT-05 | `C:\Games\Cossacks 3\data\shaders\tone\tonecontgamma.frag:4-28,48-93` (this pass) | same tone+LUT shape plus `bright/saturate/contrast/avgLum/vignette` stage; defaults live in code, not in text |
| NEW-TEXT-06 | `C:\Games\Cossacks 3\data\posteffects\posteffects.shaders:8-52` (this pass) | gamma program selection table (`ToneGammaFP/ToneContGammaFP/ToneDOFGammaFP/...`); selection state is runtime [U] |
| NEW-TEXT-07 | `C:\Games\Cossacks 3\data\shaders\tone\tone.frag:4-24` (this pass) | non-gamma tone twin: identical `yd+color2*mulColor` without any LUT/`fade` stage |

Donor-text numbers reused without alteration: `reftile.mat:25-26,36,52-104,120-169`;
`light.cfg:2-38`; `colors.lib:23,34-38`; `shaders.lib:16-51,915-951`;
`hf.pvl.sm.vert:9,13,18-23,26-39`; `hf.pvl.smx3.frag:13-17,33-50`;
`tonegamma.frag:4-37`; `tonecontgamma.frag:4-93`; `posteffects.shaders:8-52`.

---

## 3. Terrain material floats — [O] from text, [U] at GL upload

### 3.1 Slot→enum map [O] (CODE, parent)

From `ev_45d056ba…` (face in `ecx` passed as arg1):

| Site | Call | Immediate | GL name |
|---|---|---:|---|
| `0x88f418` | `glMateriali` | `0x1601` | `GL_SHININESS` |
| `0x88f446` | `glMaterialfv` | `0x1600` | `GL_EMISSION` |
| `0x88f474` | `glMaterialfv` | `0x1200` | `GL_AMBIENT` |
| `0x88f4a2` | `glMaterialfv` | `0x1201` | `GL_DIFFUSE` |
| `0x88f4d0` | `glMaterialfv` | `0x1202` | `GL_SPECULAR` |

### 3.2 Floats [O] from TEXT (NEW-TEXT-02)

`C:\Games\Cossacks 3\data\terrain\ref\reftile.mat` gives the only numeric
material source for terrain — identical on both faces:

- `reftile.mat:52-55` Back ambient `0.15686` grey; `:80-83` Front ambient `0.15686`.
- `reftile.mat:58-61` Back diffuse `0.78125` grey; `:86-89` Front diffuse `0.78125`.
- `reftile.mat:64-76` Back emission `0` / specular `0` / `Shininess 16`; `:92-104`
  Front identical.
- `reftile.mat:17` `BlendingMode=bmTransparency`; `:18` `FaceCulling=fcCull`;
  `:19-22` `moIgnoreFog=False, moNoLighting=False`.

Effective specular product is therefore `vec3(0)` (`0 × light.cfg` specular).
The port must keep the `material_specular_rgb=0` multiply and must never bind
the bare `light.cfg` specular
(`0.27843139,0.26666668,0.21176471`, `light.cfg:19-24`) as the terrain specular.

### 3.3 Residual [U-MAT]: which vectors reach the five upload slots

No static trace from a terrain material refkey to `sub_88f3e8` arg2 was run
under this charter, and none is asserted. One concrete caller,
`FUN_005422c0`, passes `PTR_DAT_008fcac0 = 0x8f58dc` (the same `0.2` grey vector
as `sceneColor`) as the `GL_AMBIENT` source for *a* material — so the `0.2`
vector is reused as at least one material ambient. That binding is [O]; the
terrain HeightField binding is not.

Probe **P-MAT** (§7.1) terminates this [U] with zero mismatches.

---

## 4. Light direction / w and modelview source — path [O], values [U]

### 4.1 Submission path [O] (CODE, parent)

From `ev_b44f26b3…` (164 insns), per light index `i`:

- `glEnable(GL_LIGHT0+i)` when `byte[light+0xbc]` set, else
  `glDisable(GL_LIGHT0+i)`; unused slots `>= count` explicitly disabled.
- Enabled lights issue, in order: `0x4d0963 GL_POSITION (0x1203)` via
  `FUN_00890ccc(light+0xa4 or +0x44)` after `sub_4ca154`/`glMultMatrixf`;
  `0x4d09aa GL_AMBIENT (0x1200)`; `0x4d09c7 GL_DIFFUSE (0x1201)`;
  `0x4d09e4 GL_SPECULAR (0x1202)`; `0x4d0a1b GL_SPOT_DIRECTION (0x1204)`;
  `0x4d0a33 GL_SPOT_EXPONENT (0x1205)`; `0x4d0a4b/0x4d0a63 GL_SPOT_CUTOFF
  (0x1206)` or literal `0x43340000=180.0f` when non-positional;
  `0x4d0a7b/0x4d0a93/0x4d0aab GL_CONSTANT/LINEAR/QUADRATIC_ATTENUATION
  (0x1207/0x1208/0x1209)`.
- `hf.pvl.sm.vert:9` builds `realpos = gl_ModelViewMatrix × gl_Vertex`;
  `:13` consumes `normalize(gl_LightSource[0].position.xyz - realpos.xyz)`;
  `GL_NORMALIZE` enabled at `0x4d1426`, shade model `GL_SMOOTH`
  (`+0x125=0 → 0x4d14dd`).

### 4.2 Numbers [O] from TEXT (NEW-TEXT-03)

`C:\Games\Cossacks 3\data\env\lights\light.cfg:2-38`:

- Ambient `(0.19607843,0.18431373,0.12941177,1)`.
- Diffuse `(0.81176472,0.78039217,0.69411767,1)`.
- Specular `(0.27843139,0.26666668,0.21176471,1)` — text only, never bound bare
  for terrain (§3.2).
- `ConstAttenuation=1`, `Linear=0`, `Quadratic=0`; `LightStyle=lsParallel`
  (`:17`); `Shining=true`; `SpotCutOff=180` (`:25`); `SpotExponent=0` (`:38`);
  `SpotDirection=(0,0,-1,W=0)` (`:32-37`).
- `Position=(-0.344731152057648,0.938701450824738,0,W=1)` (`:26-31`).

`lsParallel` is a text hint only. Because `:13` subtracts `realpos`, `w`
selects directional (`w=0`) vs positional (`w=1`) semantics in the consumed
`gl_LightSource[0].position`. The file says `W=1`; the bytes actually submitted
at `0x4d0963` after the `sub_4ca154`/`FUN_00890ccc`/`glMultMatrixf` chain, and
the 16-float modelview active there, are [U].

### 4.3 Residual [U-LIGHT]: w + modelview

Probe **P-LIGHT** (§7.2) dumps `(x,y,z,w)` + the 16-float modelview per terrain
light setup and terminates only when the dumped vector matches `light.cfg:26-31`
transformed by the dumped matrix with zero mismatches, fixing `w=0` vs `w=1`
and whether the `:13` subtraction is live. Until then the port keeps its
view-space `l` labelled `[U engine]`
(`terrain_donor_shader.gdshader:278-281`).

---

## 5. Gamma curve / level — text shape [O], numeric law [U]

### 5.1 What the donor text proves [O]

- `reftile.mat:25-26` (NEW-TEXT-01): terrain `imagebrightness = 1`,
  `ImageGamma = 1`. No per-texture brightness/gamma lift is authored for the
  ground block. `reftilealpha.mat:25-26,134-135,243-244` repeats `1/1` for all
  three alpha textures. `texturemode = tmModulate` (`reftile.mat:36`,
  `reftilealpha.mat:36,145,254`) — texels modulate, they do not replace or add.
- The HeightField fragment itself is linear (NEW-TEXT, `ev_11224700…`):
  `hf.pvl.smx3.frag:13` `color.rgb = texUnit0.rgb`; `:14`
  `color.a = texUnit1.a`; `:17` `color.xyz = color.xyz*TexCoord[4].xyz +
  TexCoord[5].xyz`; `:50` `gl_FragColor = color`. There is no `pow`, no LUT
  fetch, no `fade`, no `bright/saturate/contrast` in the terrain shader. Fog
  (`:34-46`) and 3-tap shadow (`:22-31`) are the only post-light stages, both
  gated (`fogMode`, `shadowed`).
- Gamma, when active, lives in a *separate post pass* (NEW-TEXT-04/05/06/07):
  `tonegamma.frag:22-28` tone-maps (`blurOpacity/hdrIntencity/mulColor/
  brightMax`), then `:32-36` remaps each channel through
  `colorCurveSampler` (a 1D LUT texture) and mixes by `fade`:
  `rescolor = mix(color0.xyz, newcolor, fade)`. `tonecontgamma.frag:48-93`
  inserts a `contrastSaturationBrightness` + vignette stage before the same
  LUT+`fade`. `tone.frag:17-24` is the non-gamma twin (identical tone math, no
  LUT/`fade`). `posteffects.shaders:8-52` enumerates every
  `ToneGamma/ToneContGamma/ToneDOFGamma/...` program pair; which one is bound,
  and with what `colorCurveSampler` bytes / `fade` / tone uniforms, is runtime
  state, not text.

### 5.2 What is therefore [U-GAMMA]

No numeric gamma constant exists anywhere in the cited donor text:

- No exponent (no `2.2`, no `1/2.2`, no sRGB transfer) is written in any
  terrain, tone, or post file read this pass. **Never invent one.**
- No `colorCurveSampler` byte table, no `fade`, no `bright/saturate/contrast/
  avgLum/brightMax/hdrIntencity/mulColor/blurOpacity/vignetteInner/Outer/Adjust`
  value is written in the cited text (uniform *names* only). **Never invent one.**
- `ImageGamma=1` means "no per-texture authored lift", not "the framebuffer is
  linear" — the post LUT may still remap terrain pixels downstream.

Probe **P-GAMMA** (§7.3) terminates this [U]: capture the post program actually
bound during a terrain frame, dump the `colorCurveSampler` bytes + `fade` (+
any `bright/saturate/contrast` if the `Cont` variant is bound), and byte-compare
the pre/post terrain pixels. Until it terminates, the port must apply **no**
gamma/exposure/saturation/vignette lift to terrain — exactly what the current
shader does (linear §6 law, no `pow`, no LUT).

---

## 6. How atlas texels are modulated before output — [O] text

From `shaders.lib` + both terrain shaders (all [O] text):

- `shaders.lib:16-51` (SM20 `HeightField`) and `:931-951` (SM30 `HeightField`):
  `texUnit0=0`, `texUnit1=1`, both `static/bindOnStart`, `texGen=true`,
  `cameraMVM/fogMode/shadowed/vertexColor/texShadow=true`. The RGB block rides
  unit 0; the alpha mask rides unit 1.
- `hf.pvl.sm.vert:38-39`: `TexCoord[4] = ambient+diffuse`, `TexCoord[5] =
  specular` (with `vertexColor` gate `:21-22` on the diffuse only; gate runtime
  is [U-VTX] per the parents).
- `hf.pvl.smx3.frag:13-14,17,50`:
  `rgb = texture2D(texUnit0, TexCoord[0].xy).rgb` (modulated, never replaced);
  `a = texture2D(texUnit1, TexCoord[1].xy).a` (alpha comes ONLY from unit 1 —
  no intensity/luma math on alpha);
  `rgb = rgb * TexCoord[4].xyz + TexCoord[5].xyz` (**multiply-then-add**, no
  `rgb *= a** anywhere: `:17` multiplies by the packed light term, `:50`
  writes `color` straight through);
  fog mixes toward `gl_Fog.color` only when `fogMode>0` (`colors.lib:36`
  `FogMode=0`, donor prologue `+0x111=0 → GL_FOG off at startup`).

So the exact donor law for ground is: **texel-RGB × (sceneColor + material×light
ambient + NdotL × material×light diffuse [× gl_Color iff vertexColor]) +
specular(=0 for terrain)**, with alpha carried alongside for the fixed-function
`bmTransparency` crossfade (`glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA)`
at `0x4ef995`, `GL_ALPHA_TEST` enabled at `0x4ef989`, no case-1 `glAlphaFunc`).
Residual framebuffer bytes (post LUT, blend order, fog-at-draw) stay
[U-OUT] with probe **P-OUT** (§7.4).

---

## 7. Exact termination probes (authorised-trace hand-off; DO NOT RUN here)

General rule: **zero mismatches on the stated dump, or the [U] stays open.**
No threshold, lift, LUT, or gamma exponent may be baked into the port before
its probe terminates.

### 7.1 P-MAT — terrain `glMaterialfv/i` values [U-MAT]

1. With authorisation, break on the five sites in `sub_88f3e8`
   (`0x88f418`/`0x88f446`/`0x88f474`/`0x88f4a2`/`0x88f4d0`).
2. Filter on the terrain HeightField draw (list id from `FUN_0081a8e4`,
   material refkey `reftile.mat` normal path, both faces).
3. Dump `(face, pname, 4 floats / 1 int)` per hit across one skirmish frame.
4. Terminate when the dumped vectors equal the port uniforms
   (`ambient 0.15686, diffuse 0.78125, emission 0, specular 0, shininess 16`)
   with **zero float mismatches**, or emit the captured vectors and amend §3.
   Reuses parent `ev_45d056ba…` / `ev_fadb2880…`.

### 7.2 P-LIGHT — position `w` + modelview [U-LIGHT]

1. Break on `0x4d0963 glLightfv(GL_POSITION)`; read `FUN_00890ccc` output and
   the `sub_4ca154`/`glMultMatrixf` matrix.
2. Dump `(x,y,z,w)` + 16-float modelview per terrain light setup.
3. Terminate when `(x,y,z,w)` matches `light.cfg:26-31` transformed by the
   dumped matrix with zero mismatches, fixing `w=0` vs `w=1` and whether the
   `hf.pvl.sm.vert:13` subtraction is live. Until then keep the port's
   view-space `l` labelled `[U engine]` (`terrain_donor_shader.gdshader:278-281`).

### 7.3 P-GAMMA — post gamma program + LUT + fade [U-GAMMA]

1. GL-trace the post pass bound during a terrain frame: which
   `posteffects.shaders:8-52` program (`ToneGamma` vs `ToneContGamma` vs
   `ToneDOF*` vs non-gamma `Tone`) is active.
2. Dump the full `colorCurveSampler` bytes (256-entry RGB LUT or actual size),
   the `fade` float, and — only if a `Cont` variant is bound — the
   `bright/saturate/contrast/avgLumR/G/B/brightMax/hdrIntencity/mulColor/
   blurOpacity/vignette*` floats.
3. Capture one terrain frame's pre-post vs post pixels over the same ROI and
   byte-compare against `mix(c0, LUT(c0), fade)` (plus the `Cont` stage if
   bound).
4. Terminate on zero mismatches across the ROI with the LUT bytes + `fade`
   attached, or — if the non-gamma `Tone` program is bound — terminate as
   "no gamma at terrain output for this path" with the program name attached.
   No exponent, LUT entry, or `fade` may be invented before then
   (`mesh`/`shader` keep no gamma lift; `ImageGamma=1` is not a curve).

### 7.4 P-OUT — final modulated bytes incl. blend/fog order [U-OUT]

1. Frame-capture the HeightField draw: `texUnit0.rgb` texel bytes,
   `TexCoord[4]/[5]` varyings, `texUnit1.a`, blend state
   (`GL_BLEND`/`GL_ALPHA_TEST` enables at `0x4ef97f/0x4ef989`,
   `glBlendFunc(0x302,0x303)` at `0x4ef995`), `fogMode/shadowed` uniforms.
2. Byte-compare captured `gl_FragColor` against
   `texel*packed+spec` → shadow-mix → fog-mix → blend with zero mismatches.
3. Terminate on a counted match with the state order attached. The two Godot
   surfaces stay labelled a state translation regardless of the count.

### 7.5 Carried probes (one line each; full instruments in the parents)

- **P-ALPHA [U-4b]:** `glTexImage2D` upload dump for `GL_ALPHA (0x1906)`
  `512×256`/`1024×512`; compare to `V(idx)=max(0,idx-3)`; zero mismatches on
  both textures (`mesh:2180-2188`-area labels this [U]).
- **P-FOG [U-FOG]:** trace `glEnable(GL_FOG)`/`glFogfv/glFogi` vs `0x4d1482`
  order; terminate on `(mode,colour,start,end)` = `FogMode=0` (no fog) or the
  captured enabling draw.
- **P-CALL [U-9b]:** trace `glCallList` thunk `0x4afc7c` filtered on the
  `FUN_0081a8e4` list id; count executions per cell with material-state order.
- **P-R1/R2/6b/10b:** as specified in `DEC_U_scenecolor_glstate.md` §7 and
  `DEC_U_alpha_pass_quad.md` §8 (hardware watch on `0x8f58dc` /
  `renderer+0x123`, `glAlphaFunc` vs case-1 order, `renderer+0x40` callback).

---

## 8. Exact port change list — SPEC ONLY, label/telemetry-only (no file edited)

**Preservation guard (do not touch).** `scene_color = vec3(0.2,0.2,0.2)`
(`terrain_donor_shader.gdshader:145`; `terrain_donor_mesh.gd:128-129`);
`material_ambient=0.15686` / `material_diffuse=0.78125` / `shininess=16.0` /
`material_specular_rgb=0` + `specular_rgb=0` zero-product multiply
(`shader:137-144`; `mesh:183-184,249-253,1619-1626`);
`donor_sun_position=(-0.344731152057648,0.938701450824738,0.0)`
(`shader:133`; `mesh:252`); `color_unify_gain=vec3(1.0)` neutral default
(`shader:161,288`); user mods `color_unify` / `shader/mesh fixes` /
hires-array-atlas / light-match / shore-alpha labels (`config.json:18,31`;
`mesh:69-70,982-1067,1563-1591`; `shader:51-70,157-165`); two-sided
`GL_FALSE` telemetry, `GL_ALPHA_TEST ENABLED` comments, one-list-per-cell
comments, `0x48/0x50/+0x0b` constants. Any edit below keeps these lines
byte-identical in meaning. Default-config terrain stays pixel-identical.

| # | File:line (current) | Change (spec; owner applies) | Donor basis | Behaviour |
|---|---|---|---|---|
| G-1 | `terrain_donor_shader.gdshader:128-144` (lighting header + uniforms) | KEEP every value; ADD comment `# P-MAT §7.1: terrain glMaterialfv vectors [U-MAT] at 0x88f446/474/4a2/4d0+0x88f418; emission 0/specular 0/shininess 16 text-only (reftile.mat:52-104); effective specular stays vec3(0)` | `ev_45d056ba…`, NEW-TEXT-02 | none |
| G-2 | `terrain_donor_shader.gdshader:133-136` (`donor_sun_position/ambient_rgb/diffuse_rgb`) | KEEP values; ADD comment `# P-LIGHT §7.2: w+modelview at 0x4d0963 [U-LIGHT]; lsParallel is text-only (light.cfg:17); W=1 is file text (light.cfg:30), not the submitted w` | `ev_b44f26b3…`, NEW-TEXT-03 | none |
| G-3 | `terrain_donor_shader.gdshader:145-155` (`scene_color` + two-side note) | KEEP `scene_color=vec3(0.2,0.2,0.2)` **exactly**; KEEP U-R1/U-R2 labels; no fold, no `0.0`, no `light.cfg`/`colors.lib` substitution | `ev_0cb2b604…` U-1 CLOSED | none (guard) |
| G-4 | `terrain_donor_shader.gdshader:157-161` (`light_rig_*`, `color_unify_gain`) | KEEP `color_unify_gain=vec3(1.0)` default; KEEP `light_rig_*=1.0` defaults; EXTEND comment to `# PORT CALIBRATION ONLY (config.json:18,31) — neutral at 1.0 is byte-identical to the donor equation; P-GAMMA §7.3 forbids any gamma/exposure fold-in here` | `config.json:18,31`; NEW-TEXT-04/05 | none |
| G-5 | `terrain_donor_shader.gdshader:278-281` (`l` computation) | KEEP computation; KEEP `[U engine]` label; ADD `# modelview at 0x4d0963 [U-LIGHT P-LIGHT]` | §4 | none |
| G-6 | `terrain_donor_shader.gdshader:283-291` (`amb_term/dif_term/v_packed` + `color_unify_gain` multiply) | KEEP law `v_packed=(scene_color+amb+dif)*color_unify_gain`; KEEP multiply position (packed term ONLY, never texel, never specular); ADD `# texel law hf.pvl.smx3.frag:17 [O]; gain is PORT ONLY, 1.0 = donor` | `ev_11224700…:17`, NEW-TEXT-01 (`tmModulate`) | none |
| G-7 | `terrain_donor_shader.gdshader:344-349` (`rgb*v_packed+v_specular`, `ALBEDO/ALPHA`) | KEEP law; ADD comment `# [O] text: rgb from texUnit0 ONLY (:13), a from texUnit1 ONLY (:14), NO rgb*=a (:17,50); ImageGamma=1/imagebrightness=1 (reftile.mat:25-26); numeric gamma curve [U-GAMMA P-GAMMA] — no pow/LUT here` | NEW-TEXT-01/07, `ev_11224700…` | none |
| G-8 | `terrain_donor_mesh.gd:128-129,183-184,249-253` (DONOR consts) | KEEP all values; ADD trailing `# [U-MAT/U-LIGHT] uploads at 0x88f3e8/0x4d0963 probed by P-MAT/P-LIGHT; text values [O]` | `ev_45d056ba…`, NEW-TEXT-02/03 | none |
| G-9 | `terrain_donor_mesh.gd:1596-1629` (`params` block incl. `color_unify_gain`) | KEEP `"color_unify_gain": cu_gain if color_unify else Vector3.ONE`; KEEP rig energies `1.0` when off/suppressed; ADD `"gamma_probe": "P-GAMMA §7.3 (post program+LUT+fade dump, zero-mismatch)"` telemetry key | NEW-TEXT-04/05/06 | none |
| G-10 | No other lines | NO other mesh/shader edit. In particular: no `rgb*=a`, no `alpha_scissor`/`discard` threshold, no `textureGrad`/LOD inset, no `sampler2DArray` migration, no fog/shadow/gamma/saturation/vignette fill, no second brightness constant, no `color_unify_gain≠1.0` default change, no user-mod removal | PORT1TO1 §8.6, X17 §3.2 | preserves landed behaviour + all user mods |

Applying G-1..G-10 changes **zero pixels**: all are comments/telemetry keys.
Any numeric port change before its §7 probe terminates would be a PORT
APPROXIMATION and must be labelled as such, never as a donor recovery. The
`color_unify` opt-in stays exactly as shipped (neutral `1.0` default,
measured-ROI derivation in `mesh:1020-1067`, wins-over-light-match in
`:1585-1591`); this report neither re-derives nor re-tunes it.

---

## 9. Delta versus the starting reports / bottom line

| Prior claim | This pass | Status |
|---|---|---|
| `DEC_U_renderer_residual` §3: slot→enum [O], terrain floats [U-LP-3b] + P-MAT | re-typed with `reftile.mat:52-104` line pins; `ImageGamma=1/imagebrightness=1/tmModulate` added; upload still [U-MAT] + P-MAT §7.1 | **Preserved, pins tightened** |
| `DEC_U_renderer_residual` §4: path [O], w+modelview [U-LP-4] + P-LIGHT | re-typed with `light.cfg:2-38` line pins; `lsParallel` demoted to text hint; still [U-LIGHT] + P-LIGHT §7.2 | **Preserved, pins tightened** |
| sceneColor [O] `(0.2,0.2,0.2,1)` | untouched; guard repeated in G-3 | **Preserved, not re-proven** |
| Gamma/color-output law | NEW: terrain fragment proven linear (`hf.pvl.smx3.frag:13-17,50`); post gamma proven LUT+`fade` shaped (`tonegamma.frag:32-36`); numeric curve/level/`fade` [U-GAMMA] + P-GAMMA §7.3; framebuffer bytes [U-OUT] + P-OUT §7.4 | **Shape [O] text, numbers [U] + probes** |
| Texel modulation | NEW: `texUnit0.rgb × packed + spec`, `a` from `texUnit1` only, no `rgb*=a` [O] text (§6) | **Closed as text law** |
| Current mesh/shader GLSTATE + user mods | line-audited; §8 is label-only, preserves `color_unify_gain=1.0` and all user mods | **No behaviour change proposed** |

**Bottom line.** The donor ground law in-shader is
`texel.rgb × (sceneColor(0.2) + 0.15686×lightAmbient + NdotL×0.78125×lightDiffuse)
+ 0`, with alpha from the mask unit only, `tmModulate`, `ImageGamma=1`,
`imagebrightness=1`, and any gamma living downstream in a `colorCurveSampler +
fade` post program whose bytes are not in the cited text. The fixed-function
upload slots that feed that law are byte-proven; the exact uploaded terrain
floats, the submitted `w`/modelview, the numeric LUT/`fade`, and the final
bytes remain [U], each with a zero-mismatch authorised-trace probe above.
**No approximation is presented as donor fact and no donor visual parity is
claimed.**

*End of DEC-U-COLOR-GAMMA. READ-ONLY: one repo file written (this report); no
binary executed/copied; no code, shader, config, asset, test, git or Godot
state changed. Active target unchanged: `t_87f0f3c130b0`.*
