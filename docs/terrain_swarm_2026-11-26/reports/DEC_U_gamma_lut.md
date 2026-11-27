---
id: DEC-U-GAMMA-LUT
ticket: "TERRAIN-SWARM-2026-11-26 / DEC-U-GAMMA-LUT — exact numeric post gamma/LUT/fade law from t_87f0f3c130b0"
agent: "DEC-U-GAMMA-LUT (READ-ONLY subagent; no code, no Godot, no git; donor read-only, never executed/copied)"
date: 2026-11-26
status: DELIVERED__ONE_REPORT_ONLY__NO_PARITY_CLAIM
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor_root: "C:\\Games\\Cossacks 3"
target_pinned: "t_87f0f3c130b0 (cossacks.exe, PE x86 32-bit, 5768048 B, sha256 87f0f3c130b0...)"
labels_used: [O, D, I, U, "RUNTIME PROBE", "PORT INSTRUCTION"]
parity_claim: false
scope_guard: "Exactly one repo file written (this report). No repo code/shader/config/asset/test/git/Godot edit. Donor binary never executed, copied, patched or committed. Every native address is a pinned VA in t_87f0f3c130b0; every donor-text value cites path:line. sceneColor=0.2 is settled [O] and is not re-proven here. No gamma/exponent/LUT/fade constant is invented."
parent: "docs/terrain_swarm_2026-11-26/reports/DEC_U_color_gamma.md ([U-GAMMA] + P-GAMMA owner)"
---

# DEC-U-GAMMA-LUT — numeric post gamma / LUT / fade law, or proof it is engine-constant/data-only

## 0. Result in one paragraph

The numeric gamma law is **not in the cited donor text and not statically recoverable from the pinned binary**, and no constant is invented here. What is [O] from donor text: the post gamma stage is a 1D `colorCurveSampler` LUT plus `mix(c0, LUT(c0), fade)` in `tonegamma.frag:32-36` (identical shape in all 8 `*gamma*.frag` variants), optionally preceded by a `contrastSaturationBrightness` + vignette stage in the `*contgamma*.frag` variants; the terrain fragment itself is linear (`hf.pvl.smx3.frag:13-17,50`, no `pow`/LUT/`fade`); `posteffects.shaders:8-52` is a program-selection table only; `manager.cfg` carries no graphics/post key (the only `manager.cfg` in the data tree is `data/sounds/manager.cfg`, audio-only); no LUT texture file exists on disk; every tone/gamma uniform is declaration-only with **zero** numeric assignments in the data tree; the pinned binary is packed (`.bind` entropy 7.96, `ev_e7533ff3`), so all gamma/post strings are statically absent (six 0-hit `native_strings_find` passes) and GL entry points are resolved at runtime. The still-[U] numerics — LUT bytes, `fade`, all tone/cont uniforms, bound program — are therefore **engine constants / runtime data-only**, each with an exact GL uniform/texture dump probe in §7 that terminates only on zero mismatches. The port note in §8 is label/telemetry-only and preserves `color_unify_gain=1.0` (neutral) plus every landed shader user mod. **No donor visual parity is claimed. No donor GPU A/B frame exists.**

Context: `DEC_U_color_gamma.md` closed the gamma SHAPE (`ImageGamma=1` / `imagebrightness=1` / `tmModulate`, terrain linear/no `pow`, post LUT+`fade`) and left the numeric curve/level/`fade` [U-GAMMA] with probe P-GAMMA. This pass spent that probe's static half: it proves no static numeric exists and converts each residual into a named runtime dump with a zero-mismatch terminator.

---

## 1. Method, pin discipline and multi-pass ledger

### 1.1 Discipline

- Pinned target for every native citation: `t_87f0f3c130b0`. No `core_target_open`/`core_target_select` call was made by this worker; `core_session_show` confirmed the active target was already `t_87f0f3c130b0` (828 evidence records, Deep mode, Clean room OFF) and it was left untouched.
- Donor binaries never executed, copied, patched, committed or debugged. All native calls were read-only (`native_strings_find`, `native_name_xrefs_list`, `native_named_addresses_list`, `native_functions_list`, `native_function_pseudocode`, `core_target_triage`); every call passed `document:"t_87f0f3c130b0"` explicitly.
- Donor text re-read directly from disk (read-only): `tonegamma.frag` (full 38 lines), `tonecontgamma.frag` (full 94 lines), `tonedofgamma.frag` (full 64 lines), `tone.frag` (25 lines), `tone.vert` (7 lines), `posteffects.shaders` (53 lines), `hf.pvl.smx3.frag` (51 lines), `data/sounds/manager.cfg` (11 lines), `data/env/env.cfg` (27 lines), plus targeted greps over `data/shaders/**`, `data/*.cfg`, and the port files `variant3d/shaders/terrain_donor_shader.gdshader` (350 lines), `variant3d/scripts/terrain_donor_mesh.gd` (color_unify sites), `variant3d/config.json:18,31`.
- Pass budget: 5 passes (text → native strings → native imports/setup → data-tree LUT/numeric sweep → port audit). Strange decompiles: none; the one Deep-engine pseudocode read (`0x406fd8`, path-canonicalisation helper, unrelated to GL) is cited as a negative control only.
- Parent report `DEC_U_color_gamma.md` re-read in full (422 lines); its evidence ids are reused verbatim, never re-minted.

### 1.2 Multi-pass ledger

| Pass | Instrument | What was examined | Outcome |
|---|---|---|---|
| P1 donor text | read-only file reads + grep | `tonegamma.frag`, `tonecontgamma.frag`, `tonedofgamma.frag`, `tone.frag`, `tone.vert`, `posteffects.shaders:8-52`, `hf.pvl.smx3.frag`, `manager.cfg`, `env.cfg` | law SHAPE [O]; zero numerics [O-negative] |
| P2 native strings | 6× `native_strings_find` pinned | `colorCurveSampler`, `tonegamma`, `ToneGamma`, `posteffect`, `gamma`, `fade`, plus `glUniform`, `.frag`, `shaders`, `opengl32` controls | 0 hits on every gamma/post name; 1 hit `opengl32.dll` import-library name only (`0x90a6f8`, `.idata`) |
| P3 native setup | `core_target_triage`, `native_named_addresses_list`, `native_name_xrefs_list`, `native_functions_list`, `native_function_pseudocode` pinned | packer evidence, import-thunk shape, GL loader path, function census | packed `.bind` 7.96 [O]; `GetProcAddress@thunk` has exactly 1 static caller (non-GL path helper); no static `glGetUniformLocation`; 18918 functions |
| P4 data sweep | recursive grep + directory listing | LUT/curve texture files, numeric uniform assignments, `manager.cfg` identity, vignette comment defaults | no LUT file; no numeric assignment anywhere; graphics `manager.cfg` proven absent; `0.7/1.75/1.25` are comments, not uploads [U] |
| P5 port audit | grep + line reads | `terrain_donor_shader.gdshader:157-161,288`, `terrain_donor_mesh.gd` color_unify sites, `config.json:18,31` | §8 label-only note; `color_unify_gain=1.0` preserved |

---

## 2. Evidence register

Reused verbatim from `DEC_U_color_gamma.md` (not re-minted): `ev_45d056ba…` (material slots), `ev_b44f26b3…` (light path), `ev_39378c31…` (prologue), `ev_0cb2b604…` (sceneColor), `ev_80043e7b…`/`ev_11224700…`/`ev_83d90ad0…` (shader text), NEW-TEXT-01..07 (tone/post text shape).

New rows minted by this worker (all pinned `document:"t_87f0f3c130b0"` unless donor-text):

| Evidence id | Operation | Establishes |
|---|---|---|
| `ev_c9b2007657d054ec6e2c21867f4f2c03cd77045206582cf4ceba9bac8de57cd4` | `native_strings_find` `colorCurveSampler` | 0 matches in binary (data-sections-only) |
| `ev_ef1096dde22dd0764c3a9cd791174e3be2da49b7d95f8435c6346c285863220e` | `native_strings_find` `tonegamma` | 0 matches |
| `ev_50ce734b229d04e466384c21b4320ab1eb99e588edcc4562b69e06ffeb4056a5` | `native_strings_find` `ToneGamma` | 0 matches |
| `ev_8039b1853519cfac58e00db2242df4e6efff1ecc686934d75fc8f920a00e5` | `native_strings_find` `posteffect` | 0 matches |
| `ev_4a32797d…` (prefix; full id in session receipt) | `native_strings_find` `gamma` | 0 matches |
| `ev_5bcc4ed5bc3c21f5a11a54ca7d5c55fc74b8d3ec683545ee650cfce76a3ff966` | `native_strings_find` `fade` | 0 matches |
| `ev_f1961fa08795f923b6a2bade18b828330cdd3ca1b3265243` | `native_strings_find` `glUniform` | 0 matches |
| `ev_55c82eb84774acb82cda7f38d4500234d28f5f61def45dad35b637b2a9968ca3` | `native_strings_find` `.frag` | 0 matches |
| `ev_a31230bc99f2fd54201a4e24eccd6ea5023706bbf357847a59e178ebdbe9a09e` | `native_strings_find` `shaders` | 0 matches |
| `ev_0b5049a651ee2f98280e414cbdee3cb425fcdfe6cc3d75d25c81214ec14f98f2` | `native_strings_find` `opengl32` | exactly 1 match: `opengl32.dll` at `0x90a6f8` (`.idata` import-library name, not a shader/uniform string) |
| `ev_ba4d3447473a04534720075598a699b1156a98a512d9d80b7dbdca1c7fa160b9` | `native_name_xrefs_list` `GetProcAddress@thunk` | `0x4013b0`, exactly 1 static caller: `0x407006` in `sub_406fd8` (path helper, not GL) |
| `ev_19da6779fd2a9f435ac1db8739357dedd5892ec7f6af03beeebea4d31377940b` | `native_named_addresses_list` (200/19664) | thunk-table shape (`CloseHandle@thunk` … `GetProcAddress@thunk` …); no `gl*` named import slot in the visible prefix |
| `ev_ef1a01b40854b151096ada6631c4527662a6eb83548851fa344173dfc4e1376c` | `native_name_xrefs_list` `glGetUniformLocation` | `name_not_found`, 0 references |
| `ev_e7533ff3eadc37298d3877bfad230213f3f00883…` (full: `ev_e7533ff33eadc37298d3877bfad230213f3f00883 19b896daa71be2b868abc6`) | `core_target_triage` `cossacks.exe` | PE x86 32-bit, Delphi/C++Builder hints, `.bind` entropy 7.96 → packed/encrypted; stripped |
| `ev_76fe7a0b8234f687f3f7eed7e0e441365a4a89151d959b304e409e1358150f7e` | `native_functions_list` | 18918 functions (census only) |
| `ev_0064160daa7c724f9e86df662d598116e4e6e2c221f833826d8177d97beabdfa` | `native_function_pseudocode` `0x406fd8` (Deep/Ghidra 12.2) | path-canonicalisation helper (`GetLongPathNameA` via `GetProcAddress`); negative control — the sole static `GetProcAddress` caller is not a GL loader |
| NEW-LUT-01 | `C:\Games\Cossacks 3\data\shaders\tone\tonegamma.frag:4-15,22-37` (this pass, full re-read) | uniform declarations + `yd` tone law + LUT+`fade` stage; no numeric (full text in §3) |
| NEW-LUT-02 | `C:\Games\Cossacks 3\data\shaders\tone\tonecontgamma.frag:4-28,48-93` (this pass, full re-read) | same tone/LUT shape + `contrastSaturationBrightness`/vignette stage; `0.7/1.75/1.25` live in trailing comments only |
| NEW-LUT-03 | `C:\Games\Cossacks 3\data\shaders\tone\tonedofgamma.frag:4-22,51-63` (this pass) | DOF variant repeats the identical LUT+`fade` tail (`:58-62`); proves all 8 `*gamma*.frag` files share one tail shape |
| NEW-LUT-04 | `C:\Games\Cossacks 3\data\shaders\tone\tone.frag:4-24` + `tone.vert:1-7` (this pass) | non-gamma twin: identical `yd` tone math, ends `gl_FragColor=color0` with no LUT/`fade`; `tone.vert` is pure passthrough |
| NEW-LUT-05 | `C:\Games\Cossacks 3\data\posteffects\posteffects.shaders:8-52` (this pass) | 22 program pairs (`Tone/ToneCont/ToneGamma/ToneContGamma/ToneDOF*/…SSAOFXAA`); selection table only, no values |
| NEW-LUT-06 | `C:\Games\Cossacks 3\data\sounds\manager.cfg:1-11` + data-wide `*.cfg` listing (this pass) | the only `manager.cfg` in the data tree is audio (`Environment/MaxChannels/…`); **no graphics/post `manager.cfg` exists** — the task's `manager.cfg` has no post-numeric source |
| NEW-LUT-07 | `C:\Games\Cossacks 3\data\env\env.cfg:1-27` (this pass) | env chain loads colors/skydome/clouds/flare/light/particles; no tone/gamma/LUT key |
| NEW-LUT-08 | data-tree sweep: `*.tga/*.dds/*.bmp/*.png/*.jpg` name match `curve\|gamma\|lut\|tone\|color` + full `data/shaders` listing (this pass) | **no LUT/curve texture file on disk** (only `gainstone.bmp`, `*stone*.dds` terrain hits); `data/shaders` holds `shaders.lib`, `shaders.ref`, `obj/`, `tone/`, `water/` and nothing else |
| NEW-LUT-09 | recursive grep `brightMax\|hdrIntencity\|blurOpacity` over `C:\Games\Cossacks 3` (this pass) | hits **only** inside `data/shaders/tone/*.frag` declaration+use lines; zero numeric assignments anywhere on disk |
| NEW-LUT-10 | `C:\Games\Cossacks 3\data\shaders\obj\hf.pvl.smx3.frag:13-17,50` (this pass, re-verified) | terrain fragment linear law, re-pinned for the §3 contrast |

Note: `native_strings_find` ids above are full 64-hex receipts except the `gamma` row, which cites the verified `ev_4a32797d…` prefix (full id in the session receipt); the result in every row is 0 matches except `opengl32`.

---

## 3. Donor text: exact gamma shape [O], zero numerics [O-negative]

### 3.1 `tonegamma.frag:4-37` — the canonical gamma tail [O]

```glsl
uniform sampler2D texUnit0;      // :4
uniform sampler2D texUnit1;     // :5
uniform sampler2D texUnit2;     // :6
uniform float blurOpacity;      // :7  — declaration only, no value
uniform float hdrIntencity;     // :8  — declaration only (sic: donor spelling)
uniform vec4 mulColor;          // :9  — declaration only
uniform float brightMax;        // :10 — declaration only
uniform sampler2D colorCurveSampler; // :14 — 1D LUT, bytes not on disk
uniform float fade;             // :15 — declaration only, no value
// :22-28 tone: color0+=color1*blurOpacity;
//           yd=hdrIntencity*(hdrIntencity/brightMax+1.0)/(hdrIntencity+1.0);
//           color0*=yd+color2*mulColor;
// :32-36 gamma:
//   red  =texture2D(colorCurveSampler, vec2(color0.x,0.)).x;
//   grn  =texture2D(colorCurveSampler, vec2(color0.y,0.)).y;
//   blu  =texture2D(colorCurveSampler, vec2(color0.z,0.)).z;
//   newcolor=vec3(red,grn,blu); rescolor=mix(color0.xyz,newcolor,fade);
// :37 gl_FragColor=vec4(rescolor,1.0);
```

There is no exponent, no `pow`, no sRGB transfer, no literal float anywhere in the file. **Never invent one.**

### 3.2 `tonecontgamma.frag:4-93` — same tail + Cont stage [O]

Identical tone block (`:70-76`, with `yd/vignetteAdjust` in place of `yd`) and identical LUT+`fade` tail (`:88-93`). Inserted before it (`:80-84`):

```glsl
color0.xyz=contrastSaturationBrightness(color0.xyz,bright,saturate,contrast); // :80
color0=mix(color0,color1,vec4(afterBlur));                                     // :81
crd=2.0*gl_TexCoord[0].xy-1.0; color0*=vignette(crd,vignetteInner,vignetteOuter); // :83-84
```

with `vignette()` (`:40-45`) and `contrastSaturationBrightness()` (`:48-63`, luma `vec3(0.2125,0.7154,0.0721)`). The only numerals in the file that look like defaults are trailing comments:

- `:21` `vignetteInner;  // 0.7 by default`
- `:22` `vignetteOuter;  // 1.75 by default`
- `:23` `vignetteAdjust; // 1.25 by default`

These are **comments, not uploads** — no `= 0.7` initialiser, no `value` block, no config assignment (NEW-LUT-09 proves zero assignments tree-wide). They stay [U-G4]; the comments may be cited as "donor-intended" but must never be baked in before probe P-GAMMA-CONT terminates.

### 3.3 All 8 `*gamma*.frag` variants share one tail [O] (NEW-LUT-03)

`tonedofgamma.frag:58-62` is line-for-line the same LUT+`fade` tail wrapped around a DOF pre-stage (`getDepth` `:26-29`, blur-mix `:43-47`). The same tail was grep-confirmed in `tonedofgammafxaa`, `tonedofgammassao`, `tonedofgammassaofxaa`, `tonedofcontgamma`, `tonedofcontgammafxaa`, `tonedofcontgammassao`, `tonedofcontgammassaofxaa` (each `texture2D(colorCurveSampler, …)` + `mix(…, fade)`). The investigation therefore needs only two representatives (`tonegamma` = base, `tonecontgamma` = Cont); the DOF/SSAO/FXAA prefixes are out of terrain scope.

### 3.4 `tone.frag` / `tone.vert` — the non-gamma twin [O] (NEW-LUT-04)

`tone.frag:17-24` repeats the `yd` tone math and ends `gl_FragColor=color0` — no LUT, no `fade`. `tone.vert:1-7` is a pure `gl_TexCoord` passthrough. So "gamma off" has an explicit program identity in the selection table, and probe P-GAMMA-SEL must allow terminating as "non-gamma program bound".

### 3.5 `posteffects.shaders:8-52` — selection table only [O] (NEW-LUT-05)

22 `*FP/*VP` pairs name every `Tone*` combination. The file carries no uniform value, no LUT path, no `fade`, no predicate for which pair is bound during a terrain frame. Binding is runtime state → [U-G5].

### 3.6 Terrain fragment is linear — re-pinned [O] (NEW-LUT-10)

`hf.pvl.smx3.frag:13` `color.rgb=texture2D(texUnit0,…).rgb`; `:14` `color.a=texture2D(texUnit1,…).a`; `:17` `color.xyz=color.xyz*gl_TexCoord[4].xyz+gl_TexCoord[5].xyz`; `:50` `gl_FragColor=color`. No `pow`, no LUT fetch, no `fade`, no `bright/saturate/contrast`. The only post-light stages are 3-tap shadow (`:22-31`, gated `shadowed`) and fog (`:34-46`, gated `fogMode`). Gamma, if active, lives strictly downstream of this shader.

### 3.7 `manager.cfg` and `env.cfg` — negative results [O] (NEW-LUT-06/07)

- The task's `manager.cfg` has no graphics/post source: the sole `manager.cfg` in the data tree is `data/sounds/manager.cfg` (audio: `Environment/MaxChannels/OutputFrequency/…`), which carries zero tone/gamma keys.
- `data/env/env.cfg:15-22` chains `colors.lib`, `skydome.cfg`, `clouds.*`, `flares/default.cfg`, `lights/light.cfg`, `pfx/particles.*` — no tone/gamma/LUT key, no post program reference.

---

## 4. Native static decomp: why the numerics are data-only (proof)

### 4.1 Binary is packed — static strings are absent by construction [D]

`ev_e7533ff3…` (`core_target_triage`): `.bind` section entropy 7.96 bits/byte → compressed/encrypted code; stripped; Delphi/C++Builder markers. Consequence: file-static string search cannot see runtime-loaded shader/uniform names, and static disassembly below the unpack stub cannot see the GL setup. This is not an inference — it is confirmed by the six 0-hit passes in §4.2 plus the import-thunk shape in §4.3.

### 4.2 Six 0-hit `native_strings_find` passes, all pinned [O-negative]

| # | Pattern | Evidence id | Matches |
|---|---|---|---|
| S1 | `colorCurveSampler` | `ev_c9b20076…` | 0 |
| S2 | `tonegamma` | `ev_ef1096dd…` | 0 |
| S3 | `ToneGamma` | `ev_50ce734b…` | 0 |
| S4 | `posteffect` | `ev_8039b185…` | 0 |
| S5 | `gamma` | `ev_4a32797d…` | 0 |
| S6 | `fade` | `ev_5bcc4ed5…` | 0 |
| C1 | `glUniform` | `ev_f1961fa0…` | 0 |
| C2 | `.frag` | `ev_55c82eb8…` | 0 |
| C3 | `shaders` | `ev_a31230bc…` | 0 |
| C4 | `opengl32` | `ev_0b5049a6…` | 1: `opengl32.dll` at `0x90a6f8` (`.idata` import-library name only) |

All carry the `data_sections_only` limiter (absence is not proof of absence at runtime — which is exactly the point: the values are runtime data). Shader file names, uniform names and LUT contents are loaded from data text at runtime through the packed layer; they are not baked plaintext in the file image.

### 4.3 GL setup is runtime-resolved — no static uniform site [D]

- `ev_ef1a01b4…`: no function, symbol or import is named `glGetUniformLocation` (`name_not_found`, 0 references). Modern-GL uniform uploads go through runtime-resolved pointers, not static thunks.
- `ev_ba4d3447…`: `GetProcAddress@thunk` (`0x4013b0`) has exactly **1** static caller — `0x407006` inside `sub_406fd8`.
- `ev_0064160d…` (Deep/Ghidra 12.2 pseudocode of `sub_406fd8`): the function resolves `GetLongPathNameA` from `kernel32.dll` and canonicalises a path — a filesystem helper, not a GL loader. It serves as a negative control: the only statically visible `GetProcAddress` use has nothing to do with shaders.
- `ev_19da6779…` (named-address prefix, 200/19664): the visible thunk table holds Win32 imports (`CloseHandle`, `CreateFileA`, `GetModuleHandleA`, `GetProcAddress`, …); no `gl*` named import slot appears.
- `ev_76fe7a0b…`: 18918 functions found — census only; no post-effect function is identified because the unpacked code is not statically visible.

Net: **no static VA exists for "the `fade` upload" or "the LUT upload"**. Any VA claimed for them without an unpacked-runtime trace would be fabrication. The numerics are engine constants / runtime data-only by elimination of every static source (text: §3, binary: §4.2–4.3, disk files: §5).

---

## 5. Disk sweep: no LUT file, no numeric assignment [O-negative]

- **No LUT/curve texture file exists** (NEW-LUT-08): a name sweep over every `*.tga/*.dds/*.bmp/*.png/*.jpg` under `data/` for `curve|gamma|lut|tone|color` returns only `gainstone.bmp` and terrain `*stone*.dds` hits — no 1D curve, no LUT image. The `colorCurveSampler` bytes are therefore generated procedurally at runtime (or derived from options state), not shipped as an asset. Its size (commonly 256 RGB entries for this 1D-`vec2(x,0.0)` idiom — stated as a probe parameter, **not** a donor fact) must be read back from the bound GL texture at runtime.
- **Zero numeric assignments tree-wide** (NEW-LUT-09): `brightMax|hdrIntencity|blurOpacity` occur only as `uniform` declarations and use-sites inside `data/shaders/tone/*.frag`. No `.cfg/.lib/.mat/.shaders` file assigns them. The same holds for `fade`, `bright/saturate/contrast`, `avgLum*`, `afterBlur`, `vignette*`, `mulColor` (grep-verified across `data/`; the `vignetteInner/Outer/Adjust` numerals live in `// … by default` comments only).
- `shaders.ref` (180 lines, NEW-LUT-06 context) describes only `custom/unob/uim/u` object programs with a single `texUnit0=0` static uniform — no tone/post block exists there.

---

## 6. Residual [U] values (nothing invented)

| Id | Value | Donor shape [O] | Why still [U] |
|---|---|---|---|
| U-G1 | `colorCurveSampler` texel bytes (+ dimensions/format) | 1D LUT sampled as `vec2(c,0)` per channel, `tonegamma.frag:32-34` | bytes not on disk (§5), not in binary image (§4.2); generated/bound at runtime |
| U-G2 | `fade` float | `mix(c0,newcolor,fade)`, `tonegamma.frag:36` | declaration-only; zero assignments tree-wide |
| U-G3 | tone floats: `blurOpacity`, `hdrIntencity`, `mulColor` (vec4), `brightMax` | `yd` law + `color0*=yd+color2*mulColor`, `tonegamma.frag:25-28` | declaration-only; zero assignments tree-wide |
| U-G4 | Cont floats: `bright`, `saturate`, `contrast`, `avgLumR/G/B`, `afterBlur`, `vignetteInner/Outer/Adjust` | `contrastSaturationBrightness` + `mix(afterBlur)` + `vignette()`, `tonecontgamma.frag:48-93` | declaration-only; `0.7/1.75/1.25` are comments, not uploads |
| U-G5 | bound post program during a terrain frame | 22-pair table, `posteffects.shaders:8-52` | selection is runtime state; may be non-gamma `Tone*` (then U-G1/U-G2 are N/A by construction) |
| U-G6 | (closed-negative) graphics `manager.cfg` | — | proven absent: only audio `manager.cfg` exists [O] (NEW-LUT-06); not a probe, a dead end recorded so no future pass re-searches it |

`ImageGamma=1` / `imagebrightness=1` (`reftile.mat:25-26`) remain what the parent said: "no per-texture authored lift", not a framebuffer curve. They do not constrain U-G1..U-G5.

---

## 7. Exact termination probes (authorised-trace hand-off; DO NOT RUN here)

General rule: **zero mismatches on the stated dump, or the [U] stays open.** No exponent, LUT entry, `fade`, tone or Cont value may be baked into the port before its probe terminates. All probes run against an authorised live/render-doc GL trace of a terrain frame; nothing here authorises executing the donor.

### 7.1 P-GAMMA-SEL — which post program is bound [U-G5]

1. Enumerate the GL program bound for the post pass during a terrain frame (fullscreen-triangle/quad draw following the scene pass).
2. Map it to one row of `posteffects.shaders:8-52` by attached shader-source dump (match the `*gamma*` tail vs the `tone.frag:24` non-gamma tail).
3. Terminate when the bound row is named with zero ambiguity (e.g. `ToneGammaFP` vs `ToneContGammaFP` vs `ToneFP`); attach the row name + source hashes. If the bound program is a non-gamma `Tone*` twin, terminate the whole gamma question as **"no gamma at terrain output for this path"** with the program name attached, and mark U-G1/U-G2 N/A (U-G3/U-G4 remain only if the bound twin declares them).

### 7.2 P-GAMMA-LUT — `colorCurveSampler` bytes [U-G1]

1. With the §7.1 program bound, capture the texture bound to `colorCurveSampler`: target, size (width×height, no assumed 256 — record actual), internal format, and full texel bytes via `glGetTexImage` (or render-doc texture export).
2. Independently dump the per-channel transfer by rendering the 1D ramp: for each input code `c` in the recorded width, `texture2D(sampler, vec2(c,0))`.
3. Terminate only when (a) the byte dump is bit-identical across two captures of the same options path, and (b) the ramp re-sample matches the dump with **zero mismatches**. Attach bytes + dimensions + format. If U-G1 is procedural (regenerated per launch/option), record the generator inputs (options bytes) alongside, still with zero-mismatch bytes for the captured instance.

### 7.3 P-GAMMA-FADE — `fade` level [U-G2]

1. Dump the `fade` uniform location value (`glGetUniformfv` on the §7.1 program) at the terrain-frame post draw.
2. Cross-check arithmetically: capture one pre-post pixel block and its post pixel, plus the U-G1 LUT bytes, and verify `post == mix(c0, LUT(c0), fade)` with **zero mismatches** over the ROI (float-tolerance stated by the tracer, exact bitwise where the path is fixed-point).
3. Terminate on uniform dump + ROI equation both zero-mismatch. `fade==0` is a legal termination (gamma present-but-disabled); `fade==1` is a legal full-remap — either way the dumped float, not an assumption, is attached.

### 7.4 P-GAMMA-TONE — tone uniforms [U-G3]

1. Dump `blurOpacity`, `hdrIntencity`, `mulColor` (4 floats), `brightMax` from the bound program at the terrain-frame post draw.
2. Verify `yd=hdrIntencity*(hdrIntencity/brightMax+1.0)/(hdrIntencity+1.0)` and `color0*=yd+color2*mulColor` against a captured pre/post ROI with **zero mismatches** (same tolerance rule as §7.3).
3. Terminate on dump + equation match. Until then the port applies no tone lift (current behaviour — guard G-7).

### 7.5 P-GAMMA-CONT — Cont/vignette uniforms [U-G4, only if a `*Cont*` program is bound]

1. If §7.1 binds a non-Cont program, mark this probe N/A with the program name.
2. Else dump `bright`, `saturate`, `contrast`, `avgLumR/G/B`, `afterBlur`, `vignetteInner/Outer/Adjust` and verify the `contrastSaturationBrightness` + `mix(afterBlur)` + `vignette()` chain (`tonecontgamma.frag:48-93`) against a captured ROI with **zero mismatches**.
3. The `0.7/1.75/1.25` comments may be cited as the expected values in the probe plan but terminate only on the dumped floats — never on the comments. Until then the port applies no contrast/saturation/vignette (current behaviour — guard G-7).

### 7.6 Carried parent probe (one line)

- **P-GAMMA (parent)** in `DEC_U_color_gamma.md` §7.3 is superseded in procedure by §7.1–7.5 above (same zero-mismatch rule, finer uniform split) but retains its ROI byte-compare requirement; either formulation terminates U-G1..U-G5 only with LUT bytes + `fade` (+ Cont floats if bound) attached, or with a named non-gamma program attached.

---

## 8. Exact port change list — SPEC ONLY, label/telemetry-only (no file edited)

**Preservation guard (do not touch).** `color_unify_gain=vec3(1.0)` neutral default (`terrain_donor_shader.gdshader:161`; consumed `:288`); `light_rig_ambient_energy=1.0`, `light_rig_sun_energy=1.0` (`:159-160`); `scene_color=vec3(0.2,0.2,0.2)` (`:145`); material/lighting products (`:133-144,278-291`); `color_unify` opt-in wiring (`terrain_donor_mesh.gd:69-70,229,273-275,982-1067,1563-1591`; `config.json:18,31` with `"color_unify": true` at `:31`); all landed user mods (hires/array-atlas, light-match, shore-alpha labels, shader/mesh fixes). Default-config terrain stays pixel-identical: every row below is a comment/telemetry key. No `pow`, no LUT, no `fade`, no tone/Cont uniform, no `color_unify_gain≠1.0` default change.

| # | File:line (current) | Change (spec; owner applies) | Donor basis | Behaviour |
|---|---|---|---|---|
| L-1 | `terrain_donor_shader.gdshader:157-161` (`light_rig_*`, `color_unify_gain`) | KEEP `color_unify_gain=vec3(1.0)` **exactly**; EXTEND the existing PORT-CALIBRATION comment with `# P-GAMMA-SEL/LUT/FADE/TONE/CONT §7: no gamma/exposure/saturation/vignette fold-in here; gain is PORT ONLY, 1.0 = donor (§3.6 linear law)` | NEW-LUT-01..04, `hf.pvl.smx3.frag:17` | none |
| L-2 | `terrain_donor_shader.gdshader:283-291` (`v_packed` + `color_unify_gain` multiply) | KEEP law and multiply position (packed term ONLY); ADD `# numeric gamma lives downstream in colorCurveSampler+fade (U-G1/G2, probes §7.2/7.3) — never folded into v_packed` | `tonegamma.frag:32-36` | none |
| L-3 | `terrain_donor_shader.gdshader:344-349` (`rgb*v_packed+v_specular`, `ALBEDO/ALPHA`) | KEEP law; EXTEND comment to `# [O] text: no pow/LUT/fade in terrain (hf.pvl.smx3.frag:13-17,50); post tail P-GAMMA-SEL §7.1; ImageGamma=1 is not a curve` | NEW-LUT-10, NEW-LUT-01 | none |
| L-4 | `terrain_donor_mesh.gd:1563-1591` (`params` block incl. `color_unify_gain`) | KEEP `"color_unify_gain": cu_gain if color_unify else Vector3.ONE`; ADD telemetry key `"gamma_probe": "P-GAMMA-SEL/LUT/FADE/TONE/CONT §7 (program+LUT+fade+tone+cont dumps, zero-mismatch)"` | NEW-LUT-05, §7 | none (telemetry) |
| L-5 | `terrain_donor_mesh.gd:1020-1067` (`_color_unify_calibration`) | KEEP derivation; ADD trailing `# guard: measured-ROI PORT calibration; independent of U-G1..U-G5 donor post state` | `config.json:18,31` | none |
| L-6 | No other line | NO other mesh/shader edit. In particular: no `pow`/LUT/`fade`/tone/Cont uniform, no second brightness constant, no `color_unify_gain≠1.0` default, no user-mod removal | PORT1TO1 §8.6 | preserves landed behaviour + all user mods |

Applying L-1..L-6 changes **zero pixels**: all are comments/telemetry keys. Any numeric port change before its §7 probe terminates would be a PORT APPROXIMATION and must be labelled as such, never as a donor recovery. The `color_unify` opt-in stays exactly as shipped (neutral `1.0` default, measured-ROI derivation, wins-over-light-match); this report neither re-derives nor re-tunes it.

---

## 9. Delta versus the parent / bottom line

| Parent claim (`DEC_U_color_gamma.md`) | This pass | Status |
|---|---|---|
| §5: gamma SHAPE [O] text (LUT+`fade`, terrain linear) | re-read in full + DOF-variant cross-check (identical tail in all 8 `*gamma*.frag`); `tone.vert` passthrough + non-gamma twin pinned | **Preserved, tightened** |
| §5.2/§7.3: numeric curve/level/`fade` [U-GAMMA] + P-GAMMA | split into U-G1..U-G5 with per-uniform dump probes §7.1–7.5; static half spent | **Converted to runtime dumps, still [U]** |
| `manager.cfg` (task input) as possible numeric source | proven audio-only / absent for graphics (NEW-LUT-06) | **Closed-negative [O]** |
| LUT texture/binary data (task input) as possible source | no LUT file on disk (NEW-LUT-08); binary packed with 0 static gamma strings (S1–S6, C1–C3) | **Proven data-only/runtime [D]** |
| Native post-process shader setup (task input) | no static uniform site: no `glGetUniformLocation` symbol, 1 non-GL `GetProcAddress` caller, thunk table without `gl*` slots | **Proven runtime-resolved [D]** |
| Port `color_unify_gain=1.0` + user mods | audited; §8 is label-only, preserves everything | **No behaviour change proposed** |

**Bottom line.** The donor post-gamma law is `rescolor = mix(tone(c0), LUT(tone(c0)), fade)` with an optional Cont/vignette pre-stage — shape fully [O] from text. Every number inside it (LUT bytes, `fade`, all tone/Cont floats, bound program) is an engine constant / runtime datum: absent from every static source by the proofs above, recoverable only by the §7 GL dumps with zero-mismatch terminators. **No constant is invented, no approximation is presented as donor fact, and no donor visual parity is claimed.**

*End of DEC-U-GAMMA-LUT. READ-ONLY: one repo file written (this report); no binary executed/copied; no code, shader, config, asset, test, git or Godot state changed. Active target unchanged: `t_87f0f3c130b0`.*

