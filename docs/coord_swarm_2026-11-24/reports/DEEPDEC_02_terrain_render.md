---
id: DEEPDEC-02
title: Donor terrain rendering — draw paths, display lists, vertex data, exact shader equations
area: donor / decompilation / terrain rendering
owner: DEEPDEC-02 (subagent)
date: 2026-11-24
status: DONE — shader equations fully recovered from external donor text; draw-path object identity still UNVERIFIED
tools: Craft Anything 0.6.1 (core + native toolsets, Deep mode), read-only donor text via core_text_read / read / grep, read-only byte windows via native_bytes_find / native_bytes_show
target: t_87f0f3c130b0 = C:\Games\Cossacks 3\cossacks.exe (SHA-256 87f0f3c130b0…)
scope_note: Audit only. No source, asset, config, test or git edit. No core_target_open / core_target_select. No runtime/Frida/unpacking. Shared target used read-only.
---

# Answer in one line

**The two geometry submitters `sub_4ff680` / `sub_501420` remain provably generic and object-unidentified
(0 static callers, 0 address-taken, 0 embedded function pointers), but the donor's *terrain* shader equations
are now fully recoverable from external text and a Delphi RTTI chain in the EXE ties a named
`THeightFieldGetHeightEvent(x,y,z,out color,out texPoint)` callback to the shader facility that the
HeightField shader uses — so the equations and the material/tile parameters can be translated, while the
"this draw call is terrain" claim stays UNVERIFIED.**

# 1. Method and safety

Read-only operations only:

- Native analysis against the already-open target: `core_session_show`, `core_targets_list`,
  `native_function_callers_list`, `native_xrefs_list`, `native_call_graph_show`, `native_api_show`,
  `native_function_disassemble` (full 1124-instruction listing of `sub_501420`), `native_data_show`,
  `native_bytes_find` (**whole-file**, hex patterns and UTF-8/UTF-16LE text), `core_feature_find`.
- External donor TEXT read read-only with `core_text_read` and `read`/`grep`: `shaders.lib`,
  `shaders.obj\hf.pvl.sm.vert`, `hf.pvl.smx3.frag`, `hf.pvl.smx9.frag`, `def.pvl.sm.vert`,
  `def.pvl.smx3.frag`, `terrain\ref\reftile.mat`, `terrain\ref\reftilealpha.mat`,
  `terrain\ref\reftile.lib`, `terrain\tiles\tiles.lib`, `terrain\tiles\tiles.mat`.
- Port-side comparison: `variant3d/scripts/world3d_terrain.gd` (read-only).
- No process launch, no memory dump, no code execution, no shader compilation, no donor binary/text copy
  into the repository. No findings were written to the shared Craft Anything investigation memory
  (to avoid churning state used by sibling agents); every result below is cited by its evidence `id`.

# 2. Evidence table

## A. Binary — caller/dispatch identity (Task 1)

| Evidence id | Address / query | Finding | Class |
|---|---|---|---|
| `ev_2afc06736c569bb9c8639b8037dc0fae98303ecd59264877eace760beff2ae21` | `0x4ff680` | `native_function_callers_list`: **0 direct callers, `address_taken=0`** for `sub_4ff680`. | OBSERVED |
| `ev_f05bfb53528bedc2b1e24e2b2601dd71217edc668fed741fde90741a9011f089` | `0x501420` | **0 direct callers, `address_taken=0`** for `sub_501420`. | OBSERVED |
| `ev_fce9ed47f84fe75b972478602c3f780f58f12cda061795e3a68bb0166fbe2f4b` | backward call graph from `0x4ff680`, depth 3 | 0 edges, 0 levels, `truncated=false` — no statically reachable caller. | OBSERVED |
| `ev_faecc35b69b9517bff1456c8f28fe72a89d65109aa2ebd56108344105c7d9669` | backward call graph from `0x501420`, depth 3 | 0 edges, 0 levels. | OBSERVED |
| `ev_d359dc5d58adeac6be93e25e57f9c1cacf1d38eb838e47c12e5b5dba602443b0` | `native_xrefs_list 0x501420` | 0 references to / 0 from (already in DECOMP-03 §6.3; re-confirmed). | OBSERVED |
| `ev_11e9975524f9fb429ab85a17a2281056b61ba311a93573c434a118d7d5630ea8` | whole-file hex `80 F6 4F 00` (= `0x004ff680` LE) | **0 matches** in 5,768,048-byte EXE: the function address is not stored as a literal pointer anywhere on disk. | OBSERVED |
| `ev_c422e1af6c7a8ac207e7ad51e759aa4edf6c38da8c6d2849d4e05eebf1f190dc` | whole-file hex `20 14 50 00` (= `0x00501420` LE) | **0 matches**: same for `sub_501420`. | OBSERVED |
| `ev_6a7cb2cd85cc76291cdb085984d6e7d9d1ba012c8080fd180c5519d07aff5529` | `native_api_show 0x4ff680` | 16 GL calls, 13 internal calls, **8 unresolved indirect calls** (incl. `0x4ffaa9`, `0x4ffbf1`). No texture-unit or texgen setup in this function. | OBSERVED |
| `ev_044a82b02a647098c44deea7b24d83f73f658b7b41fb4be8f8acfb34805e3332` | `native_api_show 0x501420` | 36 GL calls (incl. 2 `glNewList`, 2 `glCallList`, 3 `glTexCoordPointer`), 33 internal calls, **24 unresolved indirect calls**. | OBSERVED |

**Conclusion (Task 1): CLEAN UNVERIFIED.** Neither path can be proven terrain, water or entity from the
binary. The zero `address_taken` plus zero literal-pointer hits means dispatch is through
runtime-computed pointers (Delphi method tables built at load time / BSS-backed procedure variables),
which is exactly the class of link the charter forbids resolving by runtime instrumentation.

An important *convergent but non-proving* chain exists (INFERENCE, not finding):

- `ev_4e4eeb884580579a1319df3e10c6983ca2cb7fc32f0677eccf4383609f946460` — `HeightField` occurs
  **48×** in CODE at `0x54198b…`, inside Delphi RTTI. Read-only byte window at file offset `0x140d40`
  shows `THeightFieldGetHeightEvent(x,y,z,color:TVector4f,texPoint:TTexPoint)`,
  `THeightFieldGetHeight2Event(Sender:TObject;x,y,z;color;texPoint)`,
  `THeightFieldOption(hfoTextureCoordinates,hfoTwoSided)`,
  `THeightFieldColorMode(hfcmNone,hfcmEmission,hfcmAmbient,hfcmDiffuse,hfcmAmbientAndDiffuse)`.
- `ev_29fc23229bbda531ec85b9bc1e95f4a90a8a6430e759b627a6a80ce2a17fa18d` —
  `THeightFieldGetHeightEvent` embedded once (`0x54198b` region).
- `ev_79e677dee4c539a0dc546be470e5cc595c90adfc939742fccc96881ee20da5b5` — `hfoTextureCoordinates`
  embedded at `0x541ab6`; `hfcmAmbientAndDiffuse` at `0x541b57` (same RTTI block).
- External donor text `C:\Games\Cossacks 3\data\shaders\shaders.lib:15-52` (read-only, no Craft
  Anything evidence id because it is a text-file read) names a shader *`HeightField`* using
  `hf.pvl.sm.vert` + `hf.pvl.smx3.frag` with `vertexColor=true`, `texGen=true`, `texUnit0→0`, `texUnit1→1`.
- The EXE's own shader-facility RTTI (byte window at `0x457b80`, VA `0x858808…`) lists
  `CustomShaderLib30p`, `FileName`, `Condition`, `shadowColor`, `eyePos`, `cameraMVM`, `fogMode`,
  `shadowed`, `vertexColor`, `texShadow`, `newTime`, `texGen`, `shadowSize`, `postProc`, the `sr*`
  register names, `stNone/stSM20/stSM30` and `sut1i/sut1f/sut2f/sut3f/sut4f/sutMat4f` — i.e. the EXE
  contains the **schema** that parses `shaders.lib`, but not the shader file itself.

So: the donor code *has* a height-field subsystem with a per-vertex colour/texPoint callback, and the
external shader library has a `HeightField` shader whose uniform set exactly matches that facility.
That is the best available terrain linkage, but no instruction-level edge connects it to
`sub_501420`; do not upgrade it to OBSERVED.

## B. Binary — display-list sites and cached content (Task 2)

Full listing: `ev_4be17004fc665ee79fe729d36b35ea85054751e744aaa3f2f659a86960eef9d8`
(`native_function_disassemble 0x501420`, 1124 instructions; API inventory
`ev_044a82b02a647098c44deea7b24d83f73f658b7b41fb4be8f8acfb34805e3332`).

| VA | Instruction / decoded meaning | Class |
|---|---|---|
| `0x5015bf`–`0x5015c6` | `cmp byte [ebx+0xbc],0; je 0x501711` — **object flag `+0xbc` gates the whole display-list path**. | OBSERVED |
| `0x5015cc`–`0x5015d6` | `cmp byte [param_3+0x102],0; jne 0x501678` — same `+0x102` indexed/non-indexed switch used by the array path selects which list is used. | OBSERVED |
| `0x5015dc`–`0x501630` | non-indexed: list object at `[ebx+0xc0]`; if absent (`0x4c05a4` with `dl=1`, class pointer `[0x4bf33c]`) or its id `[obj+8]==0`, call `0x4c06c0` then `glNewList(id, 0x1300=GL_COMPILE)` at **`0x501626`**; else `glCallList(id)` at `0x50163a`. | OBSERVED |
| `0x501678`–`0x5016c9` | indexed: same logic on list object `[ebx+0xc8]`; `glNewList` at **`0x5016c2`**, `glCallList` at `0x5016d3`. | OBSERVED |
| `0x50163f`–`0x501673`, `0x5016d8`–`0x501700` | on a **cache hit**: `[ebx+0xec]=param_4`, `[ebx+0xf0]=0xffffffff`, `[ebx+0xf4]=byte[param_3+0x102]`, `inc [0x8f5c80]`, add vertex count to `[0x8f5c88]`, jump to function exit `0x5022db` — i.e. the entire geometry build is skipped. | OBSERVED |
| `0x50177d`–`0x5017a8` | second invalidation gate: compares `[ebx+0x90]+8` with `[geom]+8`, and requires `[ebx+0x46]!=0`, else forces `[ebx+0xec]=-1`. | OBSERVED |
| `0x502040`–`0x502042` | the list *body* is the immediate-mode branch: `glBegin(4=GL_TRIANGLES)`. | OBSERVED |
| `0x50206f`–`0x5020ad` | per vertex: `glNormal3fv` (`0x50207f`), then an indirect call through `[0x8fc144]` (`0x50209b`, identity UNVERIFIED), then `glVertex3fv` (`0x5020ad`). Indexed branch mirrors this at `0x50217e`/`0x5021b7`. | OBSERVED (callee UNVERIFIED) |
| `0x502216`–`0x502237` (mirror `0x501b9b`–`0x501bbf`) | builds two 4-float arrays on the stack from per-vertex records in `[ebx+0x64]`: skip when `[rec+4] == 0.0f` (constant `0x5022e4`, `ev_b9f37242f220d7a241d7cbc1ffa5aa070cb293f9281eb170d51529a3e3592938`), store `[rec+4]` into component 0, convert `[rec+0]` **integer→float** into component 1, accumulate `+1.0f` per record (constant `0x5022e8`, `ev_2170cbe5c284c69116a5901319bcb362b06fc9c2ec3d5a6a87ba636523581be8`); components 2–3 start zeroed from the 16-byte block at `[0x8fbd00]→0x8f4b04`. | OBSERVED |
| `0x502255`–`0x502288` | emits those two arrays through the runtime pointer `[0x8fbe10]` with arguments `(0x84c0+[ebx+0xcc], arrayA)` and `(0x84c0+[ebx+0xd0], arrayB)` — i.e. multi-texture coordinate submission on two units inside the compiled list (callee identity UNVERIFIED). | OBSERVED |
| `0x502294`–`0x5022a2` | `glEnd`, then `if ([ebx+0xbc]!=0) glEndList` at **`0x5022a2`**; cache fields at `0x5022a7+`. | OBSERVED |
| `ev_ffb488ac7953f8f18fab57792b2a0890ce6306f4d3a0e126de2e01a55216b9c3` / `ev_0b278ce7bed1db990605e5cda4480e2db554b57bade75d6480d8a23fd1807e5d` | `sub_4c05a4` = Delphi object allocator (3 memory helpers); `sub_4c06c0` = list-id allocator (1 unresolved indirect call, presumably `glGenLists`). Neither is a terrain-specific function. | OBSERVED / inferred callee |

**What is cached (Task 2 answer):** for `+0xbc != 0`, the object holds **two pre-allocated display lists**,
one for the non-indexed path (`+0xc0`) and one for the indexed path (`+0xc8`). On first use the list is
compiled (`GL_COMPILE`) while the generic immediate-mode emitter runs; the compiled body is a full
triangle list with per-vertex normal, position and two 4-component texture-coordinate streams bound to
units derived from `[obj+0xcc]`/`[obj+0xd0]`. On later use only `glCallList` is issued and the CPU-side
geometry preparation is skipped. The cache key is `[obj+0xec]` (param_4) plus `[obj+0xf4]` (= `+0x102`
flag), with secondary gate `[obj+0x46]`. This is an **object-level geometry cache inside a generic
submitter**, not a new renderer — the previous report's UNVERIFIED verdict is preserved, now with the
exact gate, list choice, cache fields and body contents recovered.

## C. Binary — texgen plumbing and HeightField RTTI (Task 2/context)

| Evidence id | VA | Finding |
|---|---|---|
| `ev_fd99aba9a8249b59c0738a7ae9ff62bb6b49999ef149803bf7d9d1ba012c8080e3332`, `ev_94e8bf3bacc2cd713cbd20b27a5f6ad80f14a786219cd3916c6deafc794f7c58` | `sub_4be5dc` (`0x4be5dc`) | `glTexGenf(coord, pname, param)` issued twice — once for unit `0x84c0`, once for `0x84c1` (a helper call via `[0x8fc87c]` between them). Direct material-to-eye-plane plumbing exists; `native_function_callers_list` shows 0 direct callers and `address_taken=1`, so its owner is UNVERIFIED. |
| `ev_f0c53ccf89d5925848b45386ec0decaa307595ecd7d5cd24dfe9e877ca1cc1f5` | `sub_4be330` (`0x4be330`) | second `glTexGenf` helper, unit `0x84c1` only; same dispatch limitation. |
| `ev_2b63dc55f2458d25201ccf77ffd1098c44589271bca28f370081f456e8f40dfe` | `0x4be5dc` | address taken 1×, 0 direct callers — reinforces runtime dispatch. |
| `ev_4e4eeb884580579a1319df3e10c6983ca2cb7fc32f0677eccf4383609f946460` | `0x54198b`…`0x541b57` (file `0x140d8b`…) | HeightField RTTI: per-vertex colour + `TTexPoint` callback, `hfoTextureCoordinates`, `hfoTwoSided`, 5 `THeightFieldColorMode` values. |

## D. Whole-file embedded-name audit (Task 4)

All queries are `native_bytes_find` with `text:` on the **whole file** (UTF-8 + UTF-16LE, both
encodings). Counts are exact `total_matches`.

| Name | Total | Address(es) / verdict | Evidence id |
|---|---|---|---|
| `hf.pvl.sm.vert` | **0** | external only | `ev_58aa7040bd842fa8cc71c0a31ea5ebbde14cbb028b0b28c83b589a20af9dda19` |
| `hf.pvl.smx3.frag`, `hf.pvl.smx9.frag`, `def.pvl.sm.vert`, `def.pvl.smx3.frag` | **0** each | external only (earlier batch) | `ev_fefa68a6ecd3015fb5b31d40090cabb33375d55423b3b00913689a7061888cc6`, `ev_3ae01070c2fa7d677c771cf61a37bf8d7ebe520bb7dcc2422c1c67c37319162f`, `ev_dfb27514523bdb292fd6affa49b0a3929302027487132e71f0ad68011f11bc4e`, `ev_c4e639e081fdb633f3722857ac630856e06278098b94c095deee35ab61eb6317` |
| `shaders.lib`, `reftile.mat`, `tiles.lib` | **0** each | external only | `ev_e121f3cc268dd26404ff4123c4401b3e262ff9cb691e6965b72e20ed0f2c956c`, `ev_bb0f1c150b35fde668f6bdb475c3bdb6ddecf02b32d109936d328e90057ed582`, `ev_1fb4cb7047ae17a8f6bc242e1450c7e7ecdbba13f9677d8ee82f98c17c12f2ff` |
| `HeightField` | **48** | CODE `0x54198b`… (RTTI/parser keys) + more | `ev_4e4eeb884580579a1319df3e10c6983ca2cb7fc32f0677eccf4383609f946460` |
| `cameraMVM` | 1 | `0x858808` (shader-facility RTTI) | `ev_c10d17e0ee32cf1d95e90102aca2c9e89e55ae0f29c124dd0cf3e27d2a243961` |
| `vertexColor` | 1 | `0x858840` | `ev_e0c2cea588b66c7827599fa5dd19a45d4d382accc20c710299a23c6e3b364051` |
| `texGen` | 1 | `0x858878` | `ev_77bae5bbe7c5f086f0cb2a26a1b8d48f3b2eb1550786fb98cd0c8baa1e331718` |
| `fogMode` | 1 | `0x85881c` | `ev_62c052c19f762a3652e58c6be65f05dc906ae43c3196467bde7abd158c2ab3f6` |
| `shadowed` | 2 | `0x853e5c`, `0x85882c` | `ev_64f982143f6dd4b3ba250eb7780428772d45024627178db1eae0c91acf6b6b69` |
| `texShadow` | 1 | `0x858854` | `ev_9a0b6aa8c95f89ddc98588df7b0db5be571abdbe712c38363e83cc209a51b733` |
| `newTime` | 1 | `0x858868` | `ev_7c3332194ebdae14a2a3efc45220c325a7d092d6c4ad9bbb05de97779a629f46` |
| `shadowSize` | 2 | `0x853e84`, `0x858888` | `ev_e748234d77356c199813bb1ea3b571c8bb3af74cecaef8b9fd078bce611ca6af` |
| `postProc` | 1 | `0x85889c` | `ev_5e88b696aa9dc23a4d89b957489dc3b7ae7acbf470e16246008925184775a844` |
| `eyePos` | 4 | `0x853ca8`, `0x854b0d`, `0x8550ec`, `0x8587f8` | `ev_74944e00d8e0c7475c80607622b124de3202b8a9776fd42265570b7c33f8a6c5` |
| `texUnit0` | 54 | first `0x5bc8c0`, many shader-source sites | `ev_dcdb904deb916b6573bbc2235ce3e216f0eb3ca3eb9185b917166270494353d7` |
| `gl_MultiTexCoord1` | 20 | `0x5be22c`… (embedded GLSL source) | `ev_1097e156df6734a1985369695df707f35439d87946629a407ea851ec177b9203` |
| `gl_FragColor` | 27 | `0x5bcee2`… | `ev_f25ef2e5c572ae251c1d25aa490a005971e9f56e65c360751175985ba22119f9` |
| `ftransform` | 22 | `0x5bcc76`… | `ev_c39803d8f54ae9db795a370bffa20c0b3019afd94732ae5ae377efc1e54f022f` |
| `#vendor_ifdef` (searched as `vendor_ifdef`) | 10 | `0x5c25d4`, `0x5c3130`, `0x5c40a0`, `0x5c4d68`… | `ev_665831c865840699fc4a452cec0cd5cd5fcb7f1f900c01681a7c186dfb55e7a4` |
| `sut1i` / `sut4f` | 1 each | `0x8589c8` / `0x858a08` (uniform-type enum) | `ev_489b3e10a7be70a08d001cff4f14045f02b3f35d1a0c6d91e84d8c3ff3dbe01e`, `ev_612e968e8049dc0469e4d07d32b81e9e1395abc8cf491137440da1b821e6fb24` |
| **`gl_EyePlaneS` / `gl_EyePlaneT`** | **0** | not embedded | `ev_447c66d2a2f83788aab2ecd3236226e97d4a15eb87bc7d03bf92f1c3a7fa1edc` (+ T twin) |
| **`gl_LightSource` / `gl_NormalMatrix` / `gl_FrontLightModelProduct` / `realpos`** | **0** | the HeightField shader **body** is not embedded | `ev_0ba58f4b9df3e9d9b064fee2ac4a7b00e4d9384260359bc74f1acd8634b1c447`, `ev_49c16385b68b5c208bb0ae00409ad9def07a13a2efb0c8806fbef2ea4eb28bff`, `ev_c997fb3cebb0ff84bcbe0e7541550f7297b4001adc9f77fb88113ca8e727d743`, `ev_3f7c4f424b915e220403f21bd23085a27d01e09b6c1cfe8a256d48dff5b10766` |

Read-only byte window at file offset `0x1bbc00` (VA `0x5bc800`) shows **actual GLSL source strings**
embedded in CODE — e.g. a `uniform float offset;` vertex shader generating 8 `gl_TexCoord` taps and a
matching 8-tap `texture2D`/`gl_FragColor` blur, alongside `TXPHDRFilterShader` class names. VA `0x453000`
(window at `0x453000`) shows the water shader's uniforms (`reflectionMap`, `waveMap`, `deepColor`,
`fresnelPower`, `waveDir0/1`, `shadowMap`, …) as RTTI/source. **These embedded shaders are the
post-effect/water family, not the HeightField pair** — which is why generic GLSL tokens are found while
the HeightField-specific tokens are absent.

**Task 4 answer:** the shader *file names*, the `shaders.lib`/`.mat` text and the HeightField *source*
are **external only**; the uniform *names*, shader-type/uniform-type enums, HeightField RTTI and
(unrelated) GLSL source strings **are embedded**. DECOMP-03 §3's "no GLSL source in the EXE" is
therefore too strong: it is true for the terrain pair, false for built-in post-process/water shaders.

## E. External donor text (equations and tile data)

| Evidence id | File / path:line | Finding |
|---|---|---|
| `ev_64eb217c56f50781fe8dfcea998a4d1ea16b97b00ec9d1ac9ad380cf95cfdee0` | `data\shaders\obj\hf.pvl.sm.vert:1-50` | HeightField vertex program (SM20 and SM30). |
| `ev_04c9b397886535cbd2c09ea91d1c9de4bb640d4836cf67d904893a1cca9f969a` | `hf.pvl.smx3.frag:1-51` | 3-tap shadow variant. |
| `ev_36610bb53f90666fb7cc5e8a3b1ab7ac54848f2d4d659efb14b62cb2a96e50d6` | `hf.pvl.smx9.frag:1-56` | 9-tap shadow variant. |
| `ev_bb61c49d985622207027ee7791365d2a9d7fa907ee59595020bbe40222ed902b` | `def.pvl.sm.vert:1-46` | Default vertex program, `VCOLOR_FACTOR 2.5`. |
| `ev_473c8f5715dc4112e9992a8e1459c2b77073fd2a296cdc261fd24cec1377a8d5` | `def.pvl.smx3.frag:1-48` | Default fragment program. |
| read-only `read` of `C:\Games\Cossacks 3\data\shaders\shaders.lib` (no evidence id; name-absence cross-check `ev_e121f3cc268dd26404ff4123c4401b3e262ff9cb691e6965b72e20ed0f2c956c`) | `shaders.lib:1-14`, `:15-52`, `:53-78`, `:914-949` | uniform register map, `ShadersSM20.HeightField`, `.Default`, `ShadersSM30.HeightField`. |
| `ev_ea667ee9c9f84fd22b7d64b701aa3483a66671fdf58ed8c80db87980e790879a` | `terrain\ref\reftile.mat:1-170` | `normal`, `normalside`, `verticalfront`, `verticalside` material refs. |
| `ev_02b40fd68e62c2678df072db39012f192da518249a6f106371dee0b810149909` | `terrain\ref\reftilealpha.mat:1-326` | `alpha`, `alphavert`, `alphanull` mask materials. |
| `ev_4ede46045d29a4b7dc41a53726986635abd248106bd8130aaa15dd5f5c0de74f` | `terrain\ref\reftile.lib:1-12` | `tsDouble`, `ttExtended`, `TileXOffset=0.1`, `TileYOffset=0.2`, commented tile-grid defaults. |
| `ev_093fa05ec55fe4673cd1370df1240a7309dab050796d4417e70f0020a15710aa` | `terrain\tiles\tiles.lib:1-909` | tile catalogue, `TileSize/Rows/Cols`, `AngleX`/`AngleZ` 25° tilt pairs. |
| `ev_3f7308ce6c189fec41cab02b278410d09eb400d3242b2beef2addbf1f0cb09f4` (`tiles.mat`) | `terrain\tiles\tiles.mat:2…`, `:142-213` | per-tile material sections with `refkey=normal/verticalfront/verticalside/normalside` and `.dds` images. |

# 3. Reconstructed logic

## 3.1 What actually flows through the draw paths

**Proven (DECOMP-03 §6 + this pass' full listing):** position `vec3` tight, normal `vec3` tight,
primary UV `vec2` in a 12-byte stride, 32-bit triangle indices, no colour array
(`glColorPointer` 0 refs), no VBOs. `sub_501420` additionally binds **two 4-float arrays** on
units `0x84c0+[obj+0xcc]` and `0x84c0+[obj+0xd0]`: non-indexed pointers `[obj+0xdc]`/`[obj+0xe4]`,
indexed pointers `[obj+0xe0]`/`[obj+0xe8]` (VA `0x501df0`–`0x501e40`, `0x501f36`–`0x501f86`).

**New detail:** those 4-float arrays are not raw input — they are *synthesised on the CPU* by the loops at
`0x501b44`–`0x501d1e` (non-indexed) and `0x5021a5`–`0x50228e` (indexed/listed). For each record of the
per-vertex table at `[ebx+0x64]` (8-byte stride) the loop reads a float at `+4` and an integer at `+0`,
skips records whose float is `0.0f` (`0x5022e4`), writes `(float@+4, float(int@+0), 0, 0)` and increments
an accumulator by `1.0f` per record (`0x5022e8`). This is an index/weight-style blend constructor.
**INFERENCE:** consistent with terrain tile-layer masks, but the semantic meaning of `+0`/`+4`, the
role of the accumulator and the identity of the source table are **UNVERIFIED** — no named function,
string or RTTI field names it.

The vertex-position/normal arrays at `[obj+0x90/0x94/0x98]` are rebuilt from remap tables at
`[obj+0xc/0x10/0x34]` and per-vertex index arrays (`0x501941`–`0x501a05`), while the 64-byte records
are bulk-copied with `rep movsd` (16 dwords) into `[obj+0xa4]` whenever the cache key changes
(`0x5014d6`–`0x50153d`, mirror at `0x50157e`–`0x5015bd`). All of this is generic mesh preparation
inside one object; the HeightField RTTI callback is the most plausible producer of the per-vertex
`color`+`texPoint`, but the link is not static.

## 3.2 Exact shader equations (OBSERVED — transcribed verbatim from donor text)

Notation: `realpos = gl_ModelViewMatrix*gl_Vertex` is **eye space**. `dot(realpos, gl_EyePlaneS[0])` is
the fixed-function eye-linear texgen plane; the material supplies those planes (§3.3).

### HeightField vertex — `hf.pvl.sm.vert:1-50`

```
:1   uniform mat4 cameraMVM;
:2   uniform int  vertexColor;
:3   uniform int  texGen;
:4   const vec3 eye = vec3(0.0);
:9   realpos = gl_ModelViewMatrix * gl_Vertex;
:12  e = normalize(eye - realpos.xyz);                       // = normalize(-realpos.xyz)
:13  l = normalize(gl_LightSource[0].position.xyz - realpos.xyz);
:14  h = normalize(l + e);                                   // Blinn half-vector
:15  n = normalize(gl_NormalMatrix * gl_Normal);
:18  ambient  = gl_FrontLightModelProduct.sceneColor + gl_FrontLightProduct[0].ambient;
:19  diffuse  = max(dot(l,n), 0.0) * gl_FrontLightProduct[0].diffuse;
:20  if (vertexColor == 1) diffuse *= gl_Color;              // colour affects DIFFUSE only
:22  specular = pow(max(dot(h,n),0.0), gl_FrontMaterial.shininess)
              * gl_FrontLightProduct[0].specular;
:25  if (texGen == 0) gl_TexCoord[0] = gl_TextureMatrix[0] * gl_MultiTexCoord0;
:27  else {
:28    gl_TexCoord[0].s = dot(realpos, gl_EyePlaneS[0]);
:29    gl_TexCoord[0].t = dot(realpos, gl_EyePlaneT[0]);
:30    gl_TexCoord[0]   = gl_TextureMatrix[0] * gl_TexCoord[0];
:31  }
:34  gl_TexCoord[1] = gl_MultiTexCoord1;                      // alpha-mask UV, no texture matrix
:35  gl_TexCoord[3] = gl_TextureMatrix[3] * cameraMVM * realpos;   // shadow coordinate
:37  gl_TexCoord[4] = ambient + diffuse;                      // packed lighting
:38  gl_TexCoord[5] = specular;
:42  #ifdef ATI  gl_TexCoord[0].w = abs(realpos.z);
:45  #else       gl_TexCoord[0].w = length(realpos);          // FOG DISTANCE
:49  gl_Position = ftransform();
```

### HeightField fragment — `hf.pvl.smx3.frag:1-51` / `hf.pvl.smx9.frag:1-56`

```
smx3:10 color.rgb = texture2D(texUnit0, gl_TexCoord[0].xy).rgb;   // albedo
smx3:11 color.a   = texture2D(texUnit1, gl_TexCoord[1].xy).a;     // ALPHA MASK
smx3:14 color.xyz = color.xyz * gl_TexCoord[4].xyz + gl_TexCoord[5].xyz;
smx3:19 const float of = 1.0/512.0;   (smx9:20 same)
smx3:20-24 / smx9:21-31  sh = Σ shadow2DProj(texShadow, gl_TexCoord[3] + offsets).r < 0.999 ? 0 : 1;
                          smx3: sh /= 3.0  (3 taps);  smx9: sh /= 9.0 (9 taps)
smx3:25 / smx9:32  color.xyz *= (sh + shadowColor.xyz*(1.0 - sh)).xyz;
smx3:32-46 / smx9:39-53  fog:
   fogMode==1 LINEAR: clamp((gl_Fog.end - gl_TexCoord[0].w)*gl_Fog.scale, 0, 1)
   fogMode==2 EXP:    clamp(exp2(-gl_Fog.density*gl_TexCoord[0].w*1.442695), 0, 1)
   fogMode==3 EXP2:   clamp(exp2(-pow(gl_Fog.density*gl_TexCoord[0].w,2.0)*1.442695), 0, 1)
   color.xyz = mix(gl_Fog.color.xyz, color.xyz, fog)
smx3:50 / smx9:55  gl_FragColor = color;
```

### Default vertex/fragment — `def.pvl.sm.vert:1-46`, `def.pvl.smx3.frag:1-48`

```
def.vert:1  #define VCOLOR_FACTOR 2.5
def.vert:9-15  same realpos/e/l/h/n, ambient/diffuse/specular
def.vert:21-25 if (vertexColor==1) { diffuse *= gl_Color*2.5; ambient *= gl_Color*2.5; }
def.vert:28  gl_TexCoord[0] = gl_MultiTexCoord0;        // no texgen
def.vert:30  gl_TexCoord[3] = gl_TextureMatrix[3]*cameraMVM*realpos;
def.vert:32-33 gl_TexCoord[4]=ambient+diffuse; gl_TexCoord[5]=specular;
def.vert:36-41 fog distance: abs(realpos.z) (ATI) else length(realpos)
def.frag:11  vec4 tex0 = texture2D(texUnit0, gl_TexCoord[0].xy);
def.frag:13  vec4 color = tex0*gl_TexCoord[4] + gl_TexCoord[5];
def.frag:15  color.a = tex0.a * gl_FrontMaterial.diffuse.a;   // direct diffuse alpha, no mask sampler
def.frag:19  float of = 1.0/shadowSize;  // 3 taps, /3.0
def.frag:32-46 same fog modes; :47 gl_FragColor = color;
```

### Shader configuration — `shaders.lib`

```
:2-14   Register maps srShadowColor→shadowColor, srEyePos→eyePos, srCameraMVM→cameraMVM,
        srFogMode→fogMode, srShadowed→shadowed, srVertexColor→vertexColor,
        srTexShadow→texShadow, srNewTime→newTime, srTexGen→texGen,
        srShadowSize→shadowSize, srPostProc→postProc.
:15-52  ShadersSM20.HeightField: vertex=hf.pvl.sm.vert, fragment=hf.pvl.smx3.frag,
        tangentSpace=false, boneMatrices=false, shadowColor=true, eyePos=false,
        cameraMVM=true, fogMode=true, shadowed=true, vertexColor=true, texShadow=true,
        newTime=false, texGen=true, shadowSize=false,
        uniform texUnit0→0 (:34-40), texUnit1→1 (:43-49).
:53-78  ShadersSM20.Default: def.pvl.sm.vert + def.pvl.smx3.frag, texGen=false,
        shadowSize=true, texUnit0→0 only.
:79-104 ShadersSM20.None: pvl.vert + pvl.frag, no shadow/texgen.
:914-949 ShadersSM30.HeightField: hf.pvl.sm.vert + hf.pvl.smx9.frag, texGen=true,
        vertexColor=true, texUnit0→0, texUnit1→1, shadowSize=false.
```

**The SM2/SM3 split is observable and exact:** same vertex program; fragment differs only in shadow
taps (3 vs 9) and the shadow offset source (constant `1/512` vs `1/512` in both hf variants; the
`shadowSize` uniform is disabled for HeightField and enabled for Default).

## 3.3 Materials, alpha masks and cliff tilt angles (exact donor literals)

**Flat tiles** — `reftile.mat` `normal` section (`:1-100`), used by every `refkey=normal` section of
`tiles.mat:2+` (grass*, sand*, rock*, ground*, *_winter, desert*):

- `:6` `Texture2Name = alpha` — the second (mask) sampler.
- `:13` `BlendingMode = bmTransparency`; `:14` `FaceCulling = fcCull`.
- `:24-26` `TextureScale = (1,1,1)`; `:34` `mappingmode = tmmUser`;
  `:39-44` s-plane `(1,0,0,0)`; `:45-50` t-plane `(1,0,0,0)`.
- `:55-65` Ambient `0.15686`, Diffuse `0.78125`; `:73` `Shininess = 16`; front block `:76-100` identical.
- `normalside` (`:102-109`) inherits `normal` with only `TextureScale=(1,1,1)`.

**Cliff / vertical-face tiles** — `reftile.mat:111-169`:

- `verticalfront` (`:111-139`): `Texture2Name = alphavert` (`:122`), `TextureScale = 0.125` on all axes
  (`:124-127`), **`mappingmode = tmmEyeLinear`** (`:129`), s-plane **`(1,0,0,0)`** (`:130-135`),
  t-plane **`(0,0,1,0)`** (`:136-141`).
- `verticalside` (`:143-169`): `Texture2Name = alphavert`, `TextureScale = 0.125`,
  `tmmEyeLinear`, s-plane **`(0,1,0,0)`**, t-plane **`(0,0,1,0)`**.
- `tiles.mat:142-213` binds these to `rock1vf…rock9vf` and `rock1vs…rock9vs`, each using the
  same `.dds` as its flat rock tile (e.g. `rock1.dds`). Analogous `sandNf`/`sandNs` sections at
  `tiles.mat:215+`, `refkey=normalside` at `:218+`.

**Tilt angles** — `tiles.lib:1-909`: every `rockNvf` / `sandNf` tile has `AngleX = 0`, `AngleZ = 25`;
every `rockNvs` / `sandNs` tile has `AngleX = 25`, `AngleZ = 0`; the winter variants repeat the same
pairs. These 25° literals are tile-geometry parameters, **not shader constants** — the exact way the
engine folds them into the eye-linear planes or vertex positions is **UNVERIFIED** (no code site found
that reads an `AngleX`/`AngleZ` field).

**Tile grid sizes** — `tiles.lib`: `sand1`-`sand4` and winter counterparts `TileSize=64, Rows=2, Cols=2`;
`test10 TileSize=128, Rows=16, Cols=16`; `test11 TileSize=128, Rows=32, Cols=32`. `reftile.lib:1-12`
sets `TileScheme=tsDouble`, `TileType=ttExtended`, `TileXOffset=0.1`, `TileYOffset=0.2`, with
`TileSize=64 / Rows=16 / Cols=16 / AlphaRows=8 / AlphaCols=4 / AlphaTileSize=64` **commented out**.

**Alpha masks** — `reftilealpha.mat`: three materials `alpha` (`:1-108`), `alphavert` (`:109-216`),
`alphanull` (`:217-326`), each `BlendingMode=bmTransparency`, `imagealpha=tiaAlphaFromIntensity`
(`:34`, `:142`, `:250`), `textureformat=tfAlpha`, `texturemode=tmModulate`, `magfilter=maNearest`,
`minfilter=miNearest`, `mappingmode=tmmUser`, Diffuse `0.8823529`, Ambient `0.5019608`,
Shininess 16; images `.\data\terrain\tiles\textures\alpha.bmp`, `alphavert.bmp`, `alphanull.bmp`.

**How the equations combine for a cliff face (INFERENCE from the exact literals):**

1. CPU builds the face geometry with the tile's 25° tilt and writes per-vertex normals.
2. The material's `tmmEyeLinear` planes are uploaded as `gl_EyePlaneS[0]`/`gl_EyePlaneT[0]` via the
   `glTexGenf` wrapper family (`sub_4be5dc`, applying the same parameter to units 0 and 1).
3. `hf.pvl.sm.vert:28-30` computes `s = dot(realpos,(1,0,0,0))` (front) or `dot(realpos,(0,1,0,0))`
   (side), `t = dot(realpos,(0,0,1,0))`, i.e. **projection onto eye-space X/Z or Y/Z**, then applies
   `gl_TextureMatrix[0]`. The `TextureScale=0.125` (1/8) is the material-side repetition factor —
   its numeric propagation into `gl_TextureMatrix[0]` is UNVERIFIED.
4. `hf.pvl.smx*.frag:10-14` samples `texUnit0` at that projected UV for RGB, samples `texUnit1` at
   `gl_MultiTexCoord1` for the alpha mask, multiplies RGB by packed `(ambient+diffuse)` and adds
   `specular`, applies 3-/9-tap shadow, then fog with distance in `gl_TexCoord[0].w`.

# 4. Precise donor terrain render recipe

1. **Geometry source:** height-field tiles from the `tiles.lib` catalogue, each inheriting
   `reftile.lib` (`tsDouble`, `ttExtended`, offsets 0.1/0.2), with `normal` materials from `tiles.mat`
   and `.dds` images under `terrain\tiles\textures\`. Cliff faces use `verticalfront` / `verticalside`
   materials plus the 25° `AngleX`/`AngleZ` pairs.
2. **Per-vertex callback:** `THeightFieldGetHeightEvent(x,y,z, out color:TVector4f,
   out texPoint:TTexPoint)` supplies height, colour and a texture point; `THeightFieldColorMode`
   selects which material colour channels participate (`hfcmEmission/Ambient/Diffuse/
   AmbientAndDiffuse`); options include `hfoTextureCoordinates` and `hfoTwoSided` (RTTI OBSERVED;
   call site UNVERIFIED).
3. **CPU mesh prep (`sub_501420`):** rebuild position/normal/primary-UV arrays and the two 4-float
   auxiliary UV arrays; bulk-copy 64-byte records into `[obj+0xa4]` when the cache key changes;
   `+0x46` gates rebuild, `+0xbc` gates display-list caching.
4. **Submit:** if `+0xbc` set and a list exists → `glCallList` (`+0xc0` non-indexed / `+0xc8` indexed)
   and skip all prep; otherwise `glNewList(…,GL_COMPILE)` + immediate-mode emission, or with `+0xbc`
   clear go straight to array draws: `glDrawArrays(GL_TRIANGLES,0,count)` or
   `glDrawElements(GL_TRIANGLES,count,GL_UNSIGNED_INT,indices)`. Units 0/`+0xcc`/`+0xd0` receive the
   2-float (stride 12) and two 4-float UV arrays.
5. **Shade:** bind `ShadersSM20.HeightField` or `ShadersSM30.HeightField` from `shaders.lib`, with
   `texGen=true`, `vertexColor=true`, `cameraMVM=true`, `fogMode=true`, `shadowed=true`,
   `texShadow=true`, `texUnit0→0`, `texUnit1→1`; run the exact equations of §3.2; texture unit 0 =
   tile albedo, unit 1 = `alpha`/`alphavert` intensity mask, unit 3 = shadow map.
6. **State:** face culling on for tile faces; `bmTransparency` on mask materials; 8× texture repeat for
   vertical faces; nearest mask filtering; Blinn-Phong shininess 16 with material ambient 0.15686 /
   diffuse 0.78125; fog distance is `length(eyePos)` except `abs(z)` on ATI.

# 5. Gap list vs `variant3d/scripts/world3d_terrain.gd`

| # | Port current state | Donor evidence | Gap / action |
|---|---|---|---|
| 1 | `StandardMaterial3D` only (`_terrain_material`, `:100-116`); no `ShaderMaterial`. | `hf.pvl.sm.vert:1-50`, `hf.pvl.smx3/9.frag`, `shaders.lib:15-52,914-949` | No way to express the donor equations. Add a `ShaderMaterial` implementing exactly §3.2 (or document a deliberate approximation). |
| 2 | `vertex_color_use_as_albedo = false` (`:109`); no colour channel. | `shaders.lib:27/926 vertexColor=true`; `hf.vert:20-21` multiplies diffuse by `gl_Color`; RTTI callback outputs `TVector4f color` | Donor terrain *does* use per-vertex colour (as a lighting multiplier, not raw albedo). Add a `COLOR` attribute or flag as port-side omission; do not simply enable it as albedo. |
| 3 | UV = `((x+0.5)/w,(z+0.5)/h)` over the whole map (`:317-318`). | `hf.vert:26-33` eye-plane texgen; `reftile.mat:129-141` eye-linear planes; `tiles.lib` TileSize/Rows/Cols | Donor UVs are projected/tiled, not 0..1 map-wide. Map-wide UV is a port simplification; tag it as such. |
| 4 | One albedo texture, `alpha_as_transparency=false` (`:372`, `:100-116`, `:288-294`). | `hf.frag:11` mask sampler; `reftile.mat:6,122,148`; `reftilealpha.mat` | No alpha-mask stage. Add a second sampler using `alpha`/`alphavert` masks (assets are donor-only — port-side art needed) or state the omission. |
| 5 | One continuous heightfield, `CULL_DISABLED` (`:112`), no walls. | `tiles.mat:142-213` vertical faces; `reftile.mat:111-169`; `tiles.lib` 25° tilt pairs | Cliff faces with 1/8 eye-linear tiling and 25° tilt are absent. Generate walls or record deliberate simplification. |
| 6 | Arrays: `ARRAY_VERTEX/NORMAL/TEX_UV/INDEX` only (`:331-339`). | `sub_501420` binds 3 UV streams (2-float stride-12 + two 4-float) | No `UV2` / custom vec4 channels; the CPU-synthesised arrays at `[obj+0xdc/e4/e0/e8]` have no port analogue. |
| 7 | Lighting/fog handled implicitly by `StandardMaterial3D` + `WorldEnvironment` (`:211-244`). | `hf.vert:37-45` packs lighting into `gl_TexCoord[4/5]`, fog distance into `[0].w`; `hf.frag` fog modes 1/2/3 with `1.442695`; shadow taps with `1/512` | Fog distance convention, Blinn half-vector exponent, packed lighting and shadow tap count are not reproduced. |
| 8 | `invalidate()` rebuilds the whole mesh (`:248-256`, `:262`). | `+0xbc` / `+0xc0` / `+0xc8` list cache with keys `+0xec/+0xf4/+0x46`; `glCallList` fast path | Behaviourally equivalent output for a static map, but no donor-cited caching semantics. |
| 9 | Flat water quad with `StandardMaterial3D` alpha (`:176-203`); `WATER_LEVEL=-0.25` flagged UNVERIFIED (`:52`). | (DEEPDEC-03's scope; donor water shaders RTTI at `0x453000`) | Out of scope here; noted so no one mistakes the quad for donor water shading. |
| 10 | One grass fallback block (`FALLBACK_BLOCK`, `:67`, `:290-294`). | `tiles.lib:1-909` catalogue with grass/sand/rock/desert/winter variants; `tiles.mat` DDS set | Asset coverage gap; `TileSize=64/Rows=2/Cols=2` etc. unused. |
| 11 | `TILE_M=2.0` and `HEIGHT_SCALE=1.0` (`:50-51`), both already flagged UNVERIFIED. | `reftile.lib` tile grid is in pixels; no metre constant recovered; `pattern.lib HeightFieldScale ≈ ±0.925` | Cell size in metres remains UNVERIFIED — do not promote any number to donor-cited. |
| 12 | Normals from central differences (`:123-133`). | `hf.vert:15` `normalize(gl_NormalMatrix*gl_Normal)`; RTTI per-vertex callback | Port normals are derived from `height[]`; donor normals come from the height-field object. Different but both donor-plausible; keep flagged as port analogue. |

# 6. UNVERIFIED / BLOCKED

1. **Object identity of `sub_4ff680` / `sub_501420`** — terrain vs entity vs water: clean UNVERIFIED
   (0 callers, 0 address-taken, 0 embedded pointer bytes). No static or data-file edge found.
2. **Meaning of per-vertex records `(int@+0, float@+4)`** used to build the 4-float UV arrays, and the
   accumulator fed by `+1.0f`: UNVERIFIED.
3. **Runtime identities behind `[0x8fca5c]` (texture-unit select), `[0x8fbe10]` (multi-texcoord
   submission), `[0x8fc144]`, `[0x8fbd00]` zero block, `[0x4bf33c]` class, `[0x8fc87c]` texgen helper**:
   BSS-backed pointers, 0 file bytes — UNVERIFIED by charter.
4. **Which shader profile (SM20 vs SM30) the game selects at runtime**, and the actual eye-plane values
   uploaded: UNVERIFIED. Only the two file-side configurations are observed.
5. **How `AngleX/AngleZ = 25°` enters geometry or texgen**: no code site recovered.
6. **How `TextureScale=0.125` reaches `gl_TextureMatrix[0]`**: UNVERIFIED.
7. **Whether `gl_Color` is per-vertex current colour via an unresolved helper or a constant**: no
   `glColorPointer`; UNVERIFIED.
8. **No claim of visual parity**: equations are transcribed, not executed or compared to a frame.

# 7. Next atomic tasks (small, independently verifiable)

1. Locate the data structure that holds the `HeightField` string at `0x54198b` and find the one
   place its address is taken (`native_bytes_find` for the pointer bytes) — may expose the terrain
   object factory without runtime work.
2. Resolve the runtime procedure pointer tables (`0x8fca5c`, `0x8fbe10`, `0x8fc144`, `0x8fc854`) by
   finding their initialisation sites *in the file* (writes to those DATA slots) — no consent needed.
3. Read `data\scripts\generatemap.inc` / `texturemap.inc` and `pattern.lib` HeightField* keys to see
   whether `texPoint`/tile indices are produced there, closing the record-field-semantics gap.
4. Implement a Godot `ShaderMaterial` in a **new** port-side file (not this audit) that mirrors §3.2,
   with all constants marked donor-cited vs port-tuned.
5. Cross-check DEEPDEC-03's water report against the embedded GLSL at VA `0x5bc800`+ / `0x453000`
   — those shaders *are* in the EXE, unlike the terrain pair.

---

**Recoverability verdict:** every equation in `hf.pvl.sm.vert`, `hf.pvl.smx3.frag`, `hf.pvl.smx9.frag`,
`def.pvl.sm.vert`, `def.pvl.smx3.frag`, every uniform binding in `shaders.lib`, and every
material/tile literal in `reftile.mat`, `reftilealpha.mat`, `reftile.lib`, `tiles.lib`, `tiles.mat`
is **recoverable verbatim** from the read-only donor text (exact `path:line` above). What is **not**
recoverable is the runtime binding of those shaders to a specific draw call or the runtime values of
the uniform/plane/tilt parameters.
