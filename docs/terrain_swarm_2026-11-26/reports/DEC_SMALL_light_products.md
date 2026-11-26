---
id: DEC_SMALL_light_products
wave: DONOR-FIRST terrain swarm 2026-11-26
ticket: "Small bounded decomp: donor light products (sceneColor, material multiply, parallel position, gamma/exposure)"
agent: "DEC_SMALL (READ-ONLY subagent; no code, no Godot, no git; donor read-only, never executed/copied)"
date: 2026-11-26
status: DELIVERED__ONE_REPORT_ONLY
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor_root: "C:\\Games\\Cossacks 3"
target_pinned: "t_87f0f3c130b0 (cossacks.exe, PE x86 32-bit, 5768048 bytes)"
labels_used: [O, D, U]
parity_claim: false
passes_used: 3
---

# DEC_SMALL — Donor light products (sceneColor, material multiply, parallel position, gamma/exposure)

## 1. Scope and constraints

1. READ-ONLY. Donor text read via `core_text_read`; binary probed via static
   `native_strings_find` / `native_name_xrefs_list` / `native_function_pseudocode`
   on pinned `t_87f0f3c130b0`. No donor binary executed, copied, or modified.
2. Three-pass maximum. No fourth pass was attempted. Anything not statically
   recovered below is marked **[U]** and left open.
3. Latest port capture with exact 8x8 subcells is flat/dark. **Do NOT guess
   brightness compensation.** No exposure/gamma lift is authorised by this report.
4. No parity claim. No Godot/code/git actions.

## 2. Donor text ground truth [O]

All donor paths under `C:\Games\Cossacks 3`, read-only.

### 2.1 `data/shaders/obj/hf.pvl.sm.vert` (50 lines, `ev_e4e269d1061d56fbf44980e8594cd113ed985ac409c00b378a7b2350c694b5ba`)

Proven vertex-lighting equations (quoted verbatim):

```glsl
vec3 l=normalize(gl_LightSource[0].position.xyz-realpos.xyz);          // :13
vec3 n=normalize(gl_NormalMatrix*gl_Normal);                            // :15
vec4 ambient=gl_FrontLightModelProduct.sceneColor                        // :18
             +gl_FrontLightProduct[0].ambient;
vec4 diffuse=max(dot(l, n), 0.0)*gl_FrontLightProduct[0].diffuse;      // :19
if(vertexColor==1)                                                      // :20-21
   diffuse*=gl_Color;
vec4 specular=pow(max(dot(h, n), 0.0), gl_FrontMaterial.shininess)     // :23
              *gl_FrontLightProduct[0].specular;
gl_TexCoord[4]=ambient+diffuse;                                        // :41
gl_TexCoord[5]=specular;                                               // :42
```

Supporting lines: `realpos=gl_ModelViewMatrix*gl_Vertex` (:9);
`e=normalize(eye-realpos.xyz)`, `h=normalize(l+e)` (:12,14) with
`eye=vec3(0.0)` (:4). No other lighting math exists in this file.

### 2.2 `data/terrain/ref/reftile.mat` (170 lines, `ev_27661ad31d177b3e546ccbb7b676091f73fc4ecc823d410d31334f28fe40959f`)

Normal refkey (`normal`, Back+Front), byte literals **[O]**:

| Slot | Back | Front |
|---|---|---|
| Ambient RGB | `0.15686, 0.15686, 0.15686, A=1` | same |
| Diffuse RGB | `0.78125, 0.78125, 0.78125, A=1` | same |
| Emission RGB | `0, 0, 0, A=1` | same |
| Specular RGB | `0, 0, 0, A=1` | same |
| Shininess | `16` | `16` |

Texture block additionally carries `imagebrightness = 1`, `ImageGamma = 1`
(identity, not an exposure pipeline — see §6).

### 2.3 `data/env/lights/light.cfg` (40 lines, `ev_3018547973d9a4a599b4aceb95770328491eb655a538b92a5eac02f9cd0030c3`)

Byte literals **[O]**:

- Ambient `R=0.196078434586525 G=0.184313729405403 B=0.129411771893501 A=1` (:3-6)
- Diffuse `R=0.811764717102051 G=0.780392169952393 B=0.694117665290833 A=1` (:9-13)
- Specular `R=0.278431385755539 G=0.266666680574417 B=0.211764708161354 A=1` (:20-23)
- Position `X=-0.344731152057648 Y=0.938701450824738 Z=0 W=1` (:26-30)
- `LightStyle=lsParallel` (:17); `Shining=true` (:18)
- `ConstAttenuation=1; Linear=0; Quadratic=0` (:8,15,16)
- `SpotCutOff=180; SpotDirection=(0,0,-1,0); SpotExponent=0` (:25,32-38)

## 3. Native static results on `t_87f0f3c130b0` (three passes)

### Pass 1 — string sweep (`native_strings_find`)

| Query | Result | Evidence |
|---|---|---|
| `sceneColor` | 0 hits | `ev_f7de1af8f1cf1c4a0b34cf9f1c0d3a3ff03c07e42a2e825939360c727b95fa59` |
| `FrontLight` | 0 hits | `ev_a7fb3fd4b91452cff0ce1f4182c96980a7b07a1654cea6d4ac7904420e13b6ce` |
| `FrontMaterial` | 0 hits | `ev_c56e237776919ae8b268efc3f9f75fdc6691d36f68490a0af86f65b5918cc46c` |
| `lsParallel` | 0 hits | `ev_bcf6d5c81029f1579ee69f7ee747536fc53fe67da4cc0f570610573d09aa8fe5` |
| `gamma` / `Gamma` | 0 / 0 hits | `ev_4a32797d…` / `ev_8e5c68fbb20abd4065eefc7cf0a4720bc435ff440439cd924e96ccc3bcbf10b8` |
| `sRGB` | 0 hits | `ev_7884562e1f0ce60bd9e3cea573c4a6d9f256e9f7d4e32063b95ab087f58c97bb` |
| `exposure` | 0 hits | `ev_291c5ffb16b73fc071278d0d149e1f4a98e0697d5da4cd8e5e4640740793f0d7` |
| `ToneMapping` | 0 hits | `ev_6c3e85ff10c7390e5a155c0f9f0632d3cf78468f9e3a6b8e41d53cbb245c888c` |
| `shadowColor` | 0 hits | `ev_739475682c36aba5e013b1c3869d8eecee43ff1aec45ca78972ace60cbcd627d` |
| `Ambient`/`Diffuse`/`Specular` | 0 hits each | `ev_7181b545…` / `ev_3a22ce1b…` / `ev_38916b4d…` |
| `SetLight` | 0 hits | `ev_442db85b65375084f5cb98cee97c5ad6a8cb23868d8e0742b6b2297e3bc408ca` |
| `GL_AMBIENT` / `GL_POSITION` | 0 / 0 hits | `ev_6c067c9c…` / `ev_fdab12f3…` |
| `LightModel` | 2 hits: `glLightModeli @0x90aa9c`, `glLightModelfv @0x90aaac` (.idata) | `ev_cea58a18367fc67ed181957118fd86e1435a2ec97e275f00fa0e020c78328349` |
| `glLight` | 4 hits: `glLightfv @0x90aa84`, `glLightf @0x90aa90` + the 2 above | `ev_5c8ddfade0ceb2ba9dbf1be743a623018331a5d08abe6f17a6edcc2d481db668` |
| `glMaterial` | 2 hits: `glMateriali @0x90aa2a`, `glMaterialfv @0x90aa38` (.idata) | `ev_bf288dd12ec516da74f75257eed9e5bd781178470806f1143d90c3e9755282b4` |
| `LightSource` | 1 hit: `XXLightSourceManager @0x958b3b` (.rsrc) | `ev_54a53973adec5741168de03469d8c55f75603f42a2cc159301e067cfdcf05501` |
| `LightPattern` | 1 hit: `KXLightPatterns @0x958ac6` (.rsrc) | `ev_7efa48442d9ad2dbb76c9b1406d542c995eaa825072d6e3cf5fcd5e470bee6c3` |
| `Fog` | 3 hits: `glFogi @0x90ab00`, `glFogfv @0x90ab0a`, `glFogf @0x90ab14` | `ev_e16768c58b936d46f0da346fbdae0ece25bbf5fa3b94b6891c34355b6241d701` |
| `glEnable` | 2 hits: `glEnableClientState @0x90ab42`, `glEnable @0x90adae` | `ev_15c70b3094697c46f7e85689db361bb3d6b83c095a45a5b84e499e2d30b5412b` |
| `glColorMaterial` | 1 hit `@0x90ab92` | `ev_e991241a3651f019c5abab25777d0d74d6a38b7893c6f9ee901812f46839a90d` |

Absence of a string proves nothing beyond the data-section search
(engine limitation `data_sections_only`); presence of the four
fixed-function imports proves the engine links the OpenGL
fixed-function lighting path.

### Pass 2 — xrefs (`native_name_xrefs_list`)

| Import | Address | Xrefs | Evidence |
|---|---|---|---|
| `glLightModelfv` | `0x907c88` via thunk `0x4afd24` | 1 call: `sub_4d13d4 @0x4d13f1` | `ev_15298ba6f99c84b7ebd2750537720078c0c69a804da055a815b1db07adcbb4e7` |
| `glLightModeli` | `0x907c84` via thunk `0x4afd2c` | 2 calls: `sub_4d13d4 @0x4d1409, @0x4d1417` | `ev_6f218356a68c93dbef38458e5dcf6a4f39193e493166e6a8df99cdda57f16144` |
| `glMaterialfv` | `0x907c68` via thunk `0x4afd64` | 13 calls incl. `sub_88f3e8 @0x88f446,@0x88f474,@0x88f4a2,@0x88f4d0`; `sub_88f5c0/@0x88f5ed`; `sub_88f608`; `sub_88f650`; `sub_88f698`; `sub_88f6e0`; `sub_88f7bc ×4` | `ev_d465405aaa2bf598f9ab982277059708b82b89cda1688220` |
| `glMateriali` | `0x907c64` via thunk `0x4afd6c` | 3 calls: `@0x88f418 (sub_88f3e8)`, `@0x88f73f`, `@0x88f81b` | `ev_921dc17a9829d1c74875e627268f97d07b1ddd9e032bb89d6f1897cbaefb9c87` |
| `glLightfv` | `0x907c7c` | **0 references** | `ev_4445706c11fced3428a25bb7e2538aa40aa4b102e294897dbd1ad3d8581a6e1c` |
| `XXLightSourceManager` / `KXLightPatterns` | — | name_not_found as code symbol (`.rsrc` strings only) | `ev_3dc7d091…` / `ev_c200279657…` |

### Pass 3 — pseudocode + residual strings

- `FUN_004d13d4` (`ev_3f19390c0e425be01f74edaf02d97238b16bf2c6b62f603a834c8562e9038f8a`,
  Ghidra Deep engine, args stripped): calls `glLightModelfv()`, then a
  two-way `glLightModeli()` branch on `*(param_1+0x123) & 8`, then
  `FUN_004d139c` state writes, `glGetIntegerv`, `glHint`, conditional
  `glShadeModel`. Passed float/enum values are **not decoded** in the
  lifter output.
- `FUN_0088f3e8` (`ev_f9fc8845b453029c0dfbb9d2eddabe8fd72837008033c91b593cd5f6d4ba5735`):
  cached-state uploader — one `glMateriali()` guarded by a cached-int
  compare, then four compare-and-upload slots each
  `FUN_004a389c/004a3830` → `glMaterialfv()` + `FUN_004a229c` cache store.
  Slot→enum mapping (Ambient/Diffuse/Emission/Specular/Shininess) is **[U]**.
- `glLightf @0x907c80`: **0 references** (`ev_91aabb50e6e5f8db7ad4291cfa543bd3542b3b2fa587b1528ce886f4ec609b94`).

## 4. Answers to the four questions

### (1) How `sceneColor` / `gl_FrontLightModelProduct` is set at runtime

- **[O]** The engine imports and calls both `glLightModelfv @0x907c88`
  (1 call site in `sub_4d13d4`) and `glLightModeli @0x907c84`
  (2 call sites in the same function). This is the only statically visible
  `gl_LightModel` submission path.
- **[D]** `gl_FrontLightModelProduct.sceneColor` is therefore driver-derived
  from the `glLightModelfv` payload (fixed-function `GL_LIGHT_MODEL_AMBIENT`
  idiom), plus the two-way `glLightModeli` branch (consistent with a
  two-sided / local-viewer toggle, exact enum **[U]**).
- **[U]** The actual float vector passed to `glLightModelfv` is **not
  statically recoverable**: the Ghidra pseudocode for `FUN_004d13d4`
  strips call arguments, and no `light.cfg`/palette float is xreffed to
  `0x4d13f1`. Whether `sceneColor` is zero, the palette ambient, or a
  `colors.lib` statictable value cannot be proven from these three passes.
- **[O]** Negative control: `sceneColor`, `FrontLight`, `FrontMaterial`
  have 0 binary string hits — expected, because they are GLSL built-in
  names resolved by the GL driver, not exe literals. Absence is not evidence
  of absence of the mechanism.

### (2) How material ambient/diffuse factors multiply the light products

- **[O]** The engine imports and repeatedly calls `glMaterialfv @0x907c68`
  (13 static call sites) and `glMateriali @0x907c64` (3 sites) through the
  cached uploader `FUN_0088f3e8` (1 int-like slot + 4 vector slots with
  dirty-check + cache store).
- **[D]** This is the fixed-function `gl_FrontMaterial` upload path, so the
  driver forms the products the shader reads:
  `gl_FrontLightProduct[0].ambient = material.ambient × light.ambient`,
  `.diffuse = material.diffuse × light.diffuse`,
  `.specular = material.specular × light.specular`.
  The multiplication itself is proven by donor shader text (§2.1) combined
  with the proven `glMaterial*` call sites; the per-slot enum assignment is **[U]**.
- **[O]** Donor material factors for the normal refkey are exact:
  ambient `0.15686`, diffuse `0.78125`, emission `0`, specular `0`,
  shininess `16` (both faces). Combined with §2.1, the donor-faithful
  effective products for flat terrain are therefore **[D]**:
  `ambient_product = 0.15686 × light.ambient`,
  `diffuse_product = 0.78125 × light.diffuse` (× `gl_Color` only when
  `vertexColor==1`), `specular_product = 0` (material zero kills the
  nonzero `light.cfg` specular). No static trace proves these exact floats
  reach `glMaterialfv` — that binding is **[U]**.
- Concrete shader equation (proven, donor text only — no port constants invented):
  `packed = sceneColor + 0.15686·La + max(dot(l,n),0)·0.78125·Ld
  (+ vertex-colour multiply when enabled)`; `spec_out = 0` for the normal refkey.

### (3) Parallel-light position handling

- **[O]** `light.cfg` declares `LightStyle=lsParallel`, position
  `(-0.344731152057648, 0.938701450824738, 0, W=1)`, no attenuation, no spot.
- **[U]** The GL submission is **not statically recoverable**: both
  `glLightfv @0x907c7c` and `glLightf @0x907c80` have **0 static
  references**. No `GL_POSITION` string exists. Whether the engine submits
  the position as a `w=0` direction, a distant `w=1` point, or through an
  unpacked/delphi-wrapped path invisible to the import-name xrefs cannot be
  decided in three passes.
- **[D]** Take the shader literally: `l=normalize(P.xyz−realpos.xyz)` varies
  per vertex; with the unit-length config `‖P‖≈1` the flat-ground direction
  equals config XYZ (VIEW-transformed), `dot(l,n)≈0.9387`. The `light.ref`
  radius-20000 argument for negligibility is prior-work inference, not
  re-proven here — engine `w`/modelview binding stays **[U]**.
- Port implication: dropping the `−realpos` subtraction (as the port does)
  is a **PORT APPROXIMATION**, not a recovered GL state. No brightness
  correction follows from it.

### (4) Gamma / colour / exposure state

- **[O]** Binary: `gamma`, `Gamma`, `sRGB`, `exposure`, `ToneMapping`,
  `GL_AMBIENT`, `GL_POSITION`, `Ambient`, `Diffuse`, `Specular`, `SetLight`
  all return 0 string hits (ev ids in §3). `glColorMaterial @0x90ab92`
  exists as an import but its call sites were not traced (pass budget).
- **[O]** Donor material text sets `ImageGamma = 1`, `imagebrightness = 1`
  — identity, not an exposure stage.
- **[U]** No gamma ramp, sRGB-framebuffer enable, tone-mapper, or
  exposure uniform is statically recoverable on this target within three
  passes. The port energies (`EXPOSURE`/`SUN_ENERGY`-style compensations,
  cf. X35 §5) have **no donor literal** and must remain labelled
  PORT COMPENSATION. **Do not invent a gamma lift to fix the dark 8x8 capture.**

## 5. UNVERIFIED register (stop here — no fourth pass)

| ID | Item | Why [U] |
|---|---|---|
| U-LP-1 | Runtime `sceneColor` float value | `glLightModelfv` args stripped in `ev_3f19390c`; no float xref |
| U-LP-2 | `glLightModeli` branch enums (two-sided vs local-viewer) | only `& 8` test on `param_1+0x123` visible |
| U-LP-3 | `FUN_0088f3e8` slot→GL-enum map; proof that `0.15686/0.78125` reach `glMaterialfv` | compare-and-upload pattern only; `Ambient/Diffuse` strings absent |
| U-LP-4 | Light position submission (`w=0` vs `w=1`, modelview at submit) | `glLightfv` + `glLightf` both 0 refs; `GL_POSITION` absent |
| U-LP-5 | Gamma/sRGB/exposure/tone-map state | all literal sweeps 0 hits; `glColorMaterial` sites untraced |
| U-LP-6 | `XXLightSourceManager` / `KXLightPatterns` runtime role | `.rsrc` strings only, no code symbol |

## 6. Guidance for the wave (no parity claim)

1. Port shader must keep the two-term ambient (`sceneColor` + material×light)
   shape even though `sceneColor`'s runtime value is [U] — collapsing it to a
   single additive constant is a known PORT APPROXIMATION (X35 §5).
2. Donor-faithful normal-refkey specular is `vec3(0)` (material zero kills
   `light.cfg` specular via `:23`); keeping the nonzero light colour is a
   labelled approximation, not a recovered product.
3. Do not touch brightness to fix the flat/dark exact-8x8 capture on the
   basis of this report. All exposure/gamma paths are [U]; any lift would be
   a guess, explicitly forbidden by the ticket.

---

*End of DEC_SMALL_light_products. READ-ONLY: no repo file other than this
report was written; no Godot job was run; no donor binary was executed or
copied. Evidence ids above are the static provenance. No donor parity claim.*
