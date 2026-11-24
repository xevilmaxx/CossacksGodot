---
id: DECOMP-03
title: Donor rendering code path — statically provable Direct3D/OpenGL call sites
area: donor / decompilation / rendering
owner: DECOMP-03 (subagent)
date: 2026-11-24
status: DONE — render path partly analysable despite packing
tools: Craft Anything 0.6.1, native toolset, Deep mode (clean_room=false, Ghidra 12.2 for pseudocode)
target: t_87f0f3c130b0 = C:\Games\Cossacks 3\cossacks.exe (SHA-256 87f0f3c130b0…)
---

# Answer in one line

**Yes — meaningful static analysis is possible despite packing.** Packing is confined to the
146,800-byte `.bind` section (entropy 7.96); the 5.18 MB `CODE` section that holds the render
functions has entropy 6.61 and yielded complete function dossiers and Ghidra pseudocode.
What is provable is a **fixed-function OpenGL 1.x** geometry pipeline; **programmable shader
setup and any D3D9 draw path are UNVERIFIED**.

No source, asset, git or runtime change was made. No process was launched, no memory dump,
no unpacking, no Frida. All operations were read-only Craft Anything analysis calls against the
already-open target. Craft Anything investigation memory received two findings (`fnd_2`,
`fnd_3`, revisions 7–8) recording the conclusions below.

# 1. Evidence table

## A. Proven draw calls and vertex/index-array setup (the core render path)

| Evidence id | Address / call site | Function | API reached | What it proves |
|---|---|---|---|---|
| `ev_53e679e407c2ce0918020945b99c4231c278aef58da6ec97d886b5cc2c6b36f3` | `0x4ffaeb` (`call 0x4afb74`) | `sub_4ff680` | `glDrawArrays@thunk` → `opengl32.glDrawArrays` (IAT `0x907d60`) | Direct, unambiguous draw call instruction |
| `ev_510b131ac5712befae5b6470f3b0936fc64d498bd2bc38c9ee008c2309940ed9` | `0x4ffb7a` | `sub_4ff680` | `glDrawElements@thunk` (`0x4afb84`) | Indexed draw call in the same renderer |
| `ev_e8b90d94f9f2230a822a5f2f963da889f39f4997b74491cf308829cd3955f2f7` | `0x501e80` | `sub_501420` | `glDrawArrays@thunk` | Second renderer uses array draws |
| `ev_6861feca6a6e7b9d3709485c1461574e34cbed05110975cf51421fe67d61fadf` | `0x501fcd` | `sub_501420` | `glDrawElements@thunk` → import slot `0x907d58` | Import-level confirmation of the indexed draw |
| `ev_1426cbde35b130528755531ca575decf5c28a01a51b044450138eefe1ab5f494` | `0x4ffa7e`, `0x4ffb41`, `0x501d94`, `0x501f1e` | `sub_4ff680`, `sub_501420` | `glVertexPointer@thunk` (`0x4afeb4`) | Vertex data supplied as client-side arrays, not GPU buffer objects |
| `ev_4eb0f457e6714c022375396e3eec248534c4fffd2d7a5691bae0d1ce905bda78` | `0x501dd8`, `0x501e0c`, `0x501e40`, `0x501f52`, `0x501f86` (+ `0x4be479`, `0x4be76a`, `0x4be784`) | `sub_501420`, `sub_4be458`, `sub_4be754` | `glTexCoordPointer@thunk` (`0x4afe2c`) | UV arrays bound alongside positions |
| `ev_e2730dda88da9cfbad84327ad7e24542acb3326f40f43665abf09f3e28bcf492` | 15 sites incl. `0x4ffa6c`, `0x501d82`, `0x501f0c` | `sub_4ff680`, `sub_501420`, `sub_4be490`, `sub_4be7a0` | `glEnableClientState@thunk` (`0x4afccc`) | Client-state array pipeline explicitly enabled |
| `ev_bf8072069eab7c5dadb6b53adb98b15e96ba650c541853bdaeb4f8a40d90391d` | whole function | `sub_4ff680` (`0x4ff680`) | 16 API calls: `glEnable/DisableClientState`, `glVertexPointer`, `glNormalPointer`, `glDrawArrays`, `glDrawElements`, `glBegin`, `glEnd`, `glNormal3fv`, `glVertex3fv` | Complete API boundary of renderer #1; 54 blocks, 474 instructions (`ev_5c6399340c6f6222dac35003630becf6d18a9a7d1aad906c92dadd199cb61fd9`) |
| `ev_5b533b72b6b10f9ab91c365aa24e0e271ac1c4d19ad6334fbde6644a41a1a532` | whole function | `sub_501420` (`0x501420`) | 36 API calls: as above plus `glTexCoordPointer`, `glNewList`, `glEndList`, `glCallList` | Complete API boundary of renderer #2; 107 blocks, 1124 instructions (`ev_63df2e539b7d9e9f3a7301bb1b41629e4313ec7b34fbf334ff7f5cb51f1ce0f8`) |
| `ev_304168a905ccb72a0bfc38988999287bf8159e8549e2730210ba872ff343b858` | `0x4ff680` | `FUN_004ff680` (Ghidra) | Full pseudo-C of the 3-path renderer | Proves pseudocode is obtainable: immediate-mode / vertex-array / indexed-array paths, 12-byte-stride vertex arrays, cache invalidated via field `0xec`, `param_2` indexing a 64-byte-stride table |
| `ev_5fac55d3e104109a92b4bf0a1aa5b2780b25557d353bd18fc1f21b616fbb172e` | `0x501420` | `sub_501420` | Pseudocode page (48,416 chars, paged) | Confirms matrix/table copy (`rep movsd`, 64-byte stride) before display-list/array submission |

## B. Proven texture binding, texture upload and render-state call sites

| Evidence id | Address / call site | Function | API reached | What it proves |
|---|---|---|---|---|
| `ev_7283a6b203f7e22812b1e3a9b706dd8160cf8c78152952d83279cdf04fbc91b9` | `0x88f8c0` | `sub_88f8a8` (`0x88f8a8`) | `glBindTexture@thunk` (`0x4afb0c`) → IAT `0x907d94` | Real binder: compares new texture id against cached `[ebx+edi*4+0x90]`, skips duplicate binds, increments counter at `0x8fb0d8` |
| `ev_b07dd093cb69612b68828eb9b9deb7fff195b1fe82025e3b06833f90f06a7aa8` | `0x88f8c0` (only static caller) | `sub_88f8a8` | `glBindTexture` | All static texture binds funnel through this one cached wrapper |
| `ev_1124c6ae01db1fb44bf3266b0789d83474c829b0c602a9791db9b9cd18e16994` | 23 call sites | `sub_88f8a8` callers: `sub_4ec794`, `sub_4ecbd8`, `sub_5d2234`, `sub_5d27dc`, `sub_5d2ad4`, `sub_5d2b9c`, `sub_5d2c68` | texture state setup | Higher-level texture/state setup functions are reachable statically |
| `ev_e2a07d0d7ef267aca8b0ae633ed0aaa5d361a7e88a458bfcda72547a1c5ee37a` | 12 sites incl. `0x4c2aa7`, `0x55e282`, `0x5d2b6d`, `0x771b80` | `sub_4c29a4`, `sub_55e240`, `sub_5d2ad4`, `sub_5d2b9c`, `sub_5d2c68`, `sub_7715f4` | `glTexImage2D@thunk` (`0x4afc34`) | Texture upload path proven; `sub_5d2*` functions appear in both bind-wrapper and upload callers |
| `ev_ec870ed4e1732c566888906ed988c6118c0b6484a026608e8eb79648b4189b3e` | `0x88fb2e` | `sub_88fb14` (`0x88fb14`) | `glDepthFunc@thunk` (`0x4afb5c`) via lookup table `0x8fb18c` | Depth-state cache: compares `[eax+0x115]` before calling |
| `ev_27957ea4ce18bbd8261b112bafed6ef6f52ffe7852ade1ef3a606016bd280096` | `0x88fbb8` | `sub_88fb78` (`0x88fb78`) | `glBlendFunc@thunk` (`0x4afb14`) via lookup table `0x8fb1ac` | Blend-state cache: memoizes source/dest factors at `[eax+0x130]`/`[eax+0x132]` |
| `ev_f65f4452fc8acb9c40dc4298de528a4e2afc326c39dd0d60de52d0b2e5b7a199` | `0x4be34c`, `0x4be5ec`, `0x4be604` | `sub_4be330`, `sub_4be5dc` | `glTexGenf@thunk` (`0x4afe4c`) | Fixed-function texture-coordinate generation is actually called — relevant to projected/reflective water or terrain detail |
| `ev_fd74665ab5c91069b3651ad85feaf914caba94597399adcaa0b66d1369cecd49` | `0x544f83`, `0x544f9e` | `sub_544be8` | `glTexEnvf@thunk` (`0x4afe34`) | Texture environment (blend/modulate) setup is called |
| `ev_d89910d8dca3b44d5963ecd459388db08629c54b4b7351f7417c1cf2f59f9710` | 37 sites | many (`sub_4ec3f0`, `sub_5d2234`, `sub_88ef90`, …) | `glEnable@thunk` (`0x4afb8c`) | GL capability state changes are widespread and statically visible |
| `ev_c3e8060007d344cce4da527d15e61807604ee75fcdfe7af969de856e311f8d80` | `0x4d1ff4`, `0x5d1d72`, `0x77c380` | `sub_4d1fbc`, `sub_5d1c60`, `sub_77c264` | `glClear@thunk` (`0x4afb1c`) | Frame clear sites identified |
| `ev_1b3cf9d6af51375c0c364efe6a8cd5378ad1e8feada63257a684d62c7115b06f` | IAT `0x907b98`–`0x907d94` | import table | **128** `opengl32.dll` imports (746 imports / 18 libs total) | The full imported GL surface is GL 1.x/2-era fixed function (incl. `glFog*`, `glTexGen*`, `glTexEnv*`, `glNewList`, `glDrawElements`); **no** `glGenBuffers`, `glBindBuffer`, `glBufferData`, `glCreateShader`, `glShaderSource`, `glUseProgram` |
| `ev_af7b246ffae17e789c78359db15ba839cebc9de6da2467dcba9c3f38a8585e3d` | `0x4afb0c`–`0x4aff84` | 477 `@thunk` functions, of which ~90 are GL/GLU/wgl | Delphi-style import thunks | Explains why call sites resolve to `0x4afbxx` wrappers rather than directly to IAT slots |

## C. Negative / UNVERIFIED evidence and packing boundary

| Evidence id | Address / call site | Function | API queried | Result |
|---|---|---|---|---|
| `ev_d5b51af0808dd609842ab36f411ca6cbd51212d8de038e641acfd28d3198239f` | `CODE 0x401000–0x8f1da8`, `.bind 0x96c000–0x98fd70` | sections | entropy/permissions | `CODE`: 5,180,840 B, executable, entropy **6.61**; `.bind`: 146,800 B, executable, entropy **7.96**. Packing does **not** cover the render functions analysed here |
| `ev_60b497434aa3e6cb68b019fd0a3b016ec0415ef6ec1a3189726faa8d3752f4c4` | whole file | overview | 18,918 functions / 746 imports | Discovery stopped at 6,000,000 instructions, 1,238 unresolved indirect jumps, stripped names — global completeness limit still applies |
| `ev_33afd9998fb124069f21d70623d07b6048abe5d409b5bf5818b565766aab07c9` | IAT `0x907e3c` | import table | `d3d9.dll` | Exactly **one** D3D9 import: `Direct3DCreate9`. No `DrawPrimitive`, `CreateVertexBuffer`, `SetTexture`, `CreateDevice`, `Present` imports (those are COM vtable methods, not DLL exports) |
| `ev_31e62499eaacda4f892399f5772d898f5e42939e30fe9357c239480e737935a1`, `ev_ca54d86414e5ee4f6d42055eb14a62ecb798103fd647ca57d97cb50c4e84f8ad` | `0x907e3c` | `Direct3DCreate9` | xrefs | **0 references** — D3D9 device creation is not statically provable in this build |
| `ev_97732917710276515a632973b8bac09884241d00c13e5245221e8f8aacf3197d` | — | `core_feature_find` | `DrawPrimitive` | 0 strings, 0 function names, 0 imports, 0 functions involved |
| `ev_0c9c4e80d8a7e620857ce49ee48f0ccfb98405d0331c66ce816adbfc3b6cdbcb` | IAT `0x907bbc` | `wglGetProcAddress` | xrefs | **0 references** — dynamic extension loading not provable, despite the import existing |
| `ev_7d8ce91e026db614211936ba73cb84bbd358a95a60a0281094364b1f4f1b56dd` | — | `native_functions_search` | shader APIs / D3D names | Only `Direct3DCreate9` + `wglGetProcAddress` imports and 16 unrelated address-coincidence `sub_…` matches; **no** shader function/import |
| `ev_e927a2f4f81d9a7544edc618f2c60d76400dd70f5a741075bba0e9e689078451` | `.idata` only | strings | shader API names | Only the two import-name strings; no `glCreateShaderObjectARB`, `glProgramStringARB`, GLSL/HLSL source, etc. stored in the file |
| `ev_bd7f677aadb81603ddecba8ca746523ba9990c205aad4d19ca3f27e86aa3576a`, `ev_8030f2d0d42d9fa6e6fa87e1eb054cc0c586b746e11c8fc05a74036adacbd4a5`, `ev_4a33e7f85e7d87809415a8418569d0e311efdd6111bd16f37f7a55f0e7f41167` | `.rsrc 0x958662`–`0x95938a` | metadata strings | `LXShaderLOD`, `XLightShader`, `XPHDR…Shader`, **`$XWaterShader`**, `fXWaterField`, `XWater` | All have `references: []`; `core_feature_find("$XWaterShader")` found 0 functions/imports/code refs — Delphi class/RTTI names, not live code links |
| `ev_f17be43f5350162faa4e8d5e31d033b8f56db1527749c685f9c66587135fdcd6`, `ev_86cfd26db9604ae783bae6477f75c58b6473574c54a4ccd4940205ca6e71b1fe` | `0x4ffaa9` | `sub_4ff680` | `call eax` | Unresolved runtime-indirect call; 8 such calls in `sub_4ff680`, 24 in `sub_501420` |
| `ev_03d2784d2148d05032ec4e5dcbbb5bcd63e70450dee21545765cc9c84adc81b4`, `ev_6fdd572236619068eba7c1f6aa6238498d9d3776d74af05e71f7e9a65a968df2`, `ev_004e34dd015852bf05f4d16d26609c20888a104956d1fae7ec371c203c1e0bdb`, `ev_9916ab9cb79354d3f4dc25557b5e2bad51a6be92fb5d6be1cbe8b482e88a3bd0`, `ev_ac40a30e8b3c6b44cddfb101e432b154f342814fa5ddaa20cdd59a811b9c71ad`, `ev_b95cc03c1cb1f2da8ce2e260548fad4b118729a5a97548c453cb758019ce336f`, `ev_2ab4ad688aa411a911c09bf1c4b98874127a1d555f112d418abc8ef2d34027d0` | `0x8fc144`, `0x8fc7f8`, `0x8fbc68`, `0x8fc854`, `0x8fc240`, `0x8fc864`, `0x8fbbec` | DATA globals used by `sub_4ff680` | pointer reads | Pointers land in BSS-backed addresses (`0x902e0c`, `0x9029a0`, …) with no file bytes — runtime-initialised procedure pointers; texcoord/colour helper calls behind them cannot be resolved statically |
| `ev_bd6b1c62074e85c694792071cccfd9c9055a8b4a0f28a70e102ff7a225638bcf`, `ev_d359dc5d58adeac6be93e25e57f9c1cacf1d38eb838e47c12e5b5dba602443b0` | `0x4ff680`, `0x501420` | both renderers | xrefs | **0 static callers** — both are reached through function pointers / Delphi method dispatch, so the higher-level frame-dispatch chain is UNVERIFIED |
| `ev_e8bc419a043b82117ec7f2f3d98a2a1a1673acb28827e80f30c56a6c3e6ffe3e`, `ev_6932b506dae165b6effc9d359cca0ee26d9716fe2bd8e945778c83973b380615` | `0x4afb84`/IAT `0x907d58` | `glDrawElements` | feature search | Cross-check: thunk + import + `.idata` string + 2 call sites all agree |

# 2. What render architecture is actually proven

1. **Backend: OpenGL 1.x fixed function, not a modern shader pipeline.** 128 `opengl32.dll` imports
   plus 16 GLU imports make up the overwhelming majority of graphics imports; the only D3D9
   import is `Direct3DCreate9` and it is never referenced. Imported state/draw surface includes
   `glVertexPointer`, `glNormalPointer`, `glTexCoordPointer`, `glEnableClientState`,
   `glDrawArrays`, `glDrawElements`, `glNewList`/`glCallList`/`glEndList`, `glBindTexture`,
   `glTexImage2D`, `glTexGen*`, `glTexEnv*`, `glFog*`, `glBlendFunc`, `glDepthFunc`, `glClear`.
2. **Two analysable geometry submitters.**
   - `sub_4ff680` (`0x4ff680`, 474 instructions / 54 blocks): Ghidra pseudo-C shows three
     mutually exclusive paths — (a) immediate mode `glBegin/glNormal3fv/glVertex3fv/glEnd`,
     (b) client arrays `glEnableClientState` + `glVertexPointer` + `glNormalPointer` +
     `glDrawArrays`, (c) indexed `glVertexPointer` + `glDrawElements`. Vertex records are
     copied into CPU arrays with stride `0xc` (3 floats) and reindexed through a table;
     results are cached in the object (fields `0xec`, `0xf0`, `0xf4`) and keyed by `param_2`,
     which indexes a table with stride `0x40` (likely pose/animation or material frames).
   - `sub_501420` (`0x501420`, 1124 instructions / 107 blocks): same array machinery plus
     `glTexCoordPointer` (3 UV streams) and `glNewList`/`glCallList`/`glEndList`, i.e. a
     display-list caching path. It also copies 64-byte-stride records with `rep movsd`.
3. **No GPU buffer objects.** There is no `glGenBuffers`/`glBindBuffer`/`glBufferData` import;
   "vertex/index buffer creation" in this binary means **allocating and filling CPU-side arrays**
   and binding them with `gl*Pointer`. The only index structure proven is the remap table used
   before `glDrawElements`.
4. **State is centralised in cached setters.** `sub_88f8a8` binds textures only when the id
   changes (`cmp esi,[ebx+edi*4+0x90]`); `sub_88fb14` caches depth function; `sub_88fb78`
   caches blend factors through lookup tables at `0x8fb18c`/`0x8fb1ac`. This is a deliberate
   redundancy-elimination layer in the donor engine.
5. **Packaging boundary is understood.** `.bind` is the only high-entropy region; the render
   functions cited here all lie in `CODE`. The global caveats (6M-instruction cut-off, 1,238
   unresolved indirect jumps, stripped names) still bound coverage, but they do **not** erase
   the dossiers and pseudocode actually obtained.

# 3. What is UNVERIFIED (do not infer from this pass)

- **Shader setup:** no shader API import, no shader-extension string, `wglGetProcAddress` has
  zero static references. `$XWaterShader`, `XLightShader`, `XPHDR*Shader` are `.rsrc` class
  names with zero code refs. Whether shaders live in external script/shader data files is
  plausible but **not proven here**.
- **Direct3D9 path:** `Direct3DCreate9` unreferenced; no COM-vtable call site was identified.
  A D3D renderer could be activated at runtime from data, but no D3D draw/buffer/texture call is
  provable statically. Do not assume a D3D water path from the import alone.
- **Frame-level dispatch:** neither renderer has static callers; the chain from game loop →
  renderer is through pointers/method tables and remains unresolved.
- **Texture-coordinate/colour helper calls inside the array paths:** indirect `call eax` through
  globals initialised at load time (BSS-backed) — unresolvable without runtime instrumentation
  (explicitly out of scope).
- **Exact shader/fog/texgen *parameters* for water or terrain:** call sites for `glTexGenf` and
  `glTexEnvf` are proven, but which object uses which mode/value at render time is not.
- No visual parity or behavioural equivalence claim follows; pseudocode is a Ghidra reading aid
  (types not recovered, calling convention assumed), and `native_function_study` pseudo-C is
  explicitly inferred.

# 4. Implications for porting donor water / terrain shading

1. **Port fixed-function semantics first.** The donor's statically visible material appearance
   is built from vertex/normal/UV arrays, texture objects, texgen, texenv, fog, blend and depth
   state — a shader-based port must reproduce those semantics (e.g. projective texgen for
   water reflection, modulate/combine for terrain detail) rather than look for GLSL/HLSL in the
   EXE.
2. **Expect CPU-side geometry preparation.** The 12-byte vertex stride, index-remap tables and
   `param_2`-keyed 64-byte record stride imply morph/pose/material-frame work happens on the CPU
   before submission. A direct port should expose equivalent CPU data structures; a GPU-only
   reimplementation will not be behaviourally identical.
3. **Preserve state-caching semantics.** Duplicate binds/state changes are suppressed in the
   donor (`sub_88f8a8`, `sub_88fb14`, `sub_88fb78`). Any harness comparing API traces must
   expect fewer `glBindTexture`/`glDepthFunc`/`glBlendFunc` calls than a naive renderer.
4. **Follow the texture data into external files.** `sub_5d2ad4`/`sub_5d2b9c`/`sub_5d2c68`
   call both `glTexImage2D` and the bind wrapper; the actual water/terrain images and any
   shader scripts are outside the executable. Recovering donor *appearance* needs those data
   files, not more static analysis of `cossacks.exe` alone.
5. **Do not budget for a D3D9 renderer from this evidence.** The D3D9 import is inert in the
   static graph; treat any D3D-specific water shader assumption as unverified until a data-file
   or runtime investigation (with consent) confirms it.
6. **Analysability verdict:** per-function decompilation is viable here — 474- and
   1124-instruction render functions produced full dossiers and (for the former) complete
   Ghidra pseudo-C. Packing is not a blanket blocker; only `.bind` is high-entropy.

# 5. Method and safety note

Read-only calls used: `enable_toolset`, `core_session_show`, `core_investigation_show`,
`core_overview_show`, `native_sections_list`, `native_functions_search`, `native_strings_find`,
`native_library_calls_list`, `native_name_xrefs_list`, `native_xrefs_list`, `native_api_show`,
`native_function_study`, `native_function_disassemble`, `native_function_pseudocode`,
`native_function_callers_list`, `native_call_site_resolve`, `native_instruction_show`,
`native_data_show`, `core_feature_find`, `core_evidence_browse`, `core_finding_record`.
All results were captured above by evidence id. No `core_target_open`, no `core_target_select`,
no runtime/frida tools, no unpacking tools, and no filesystem writes except this report and the
two Craft Anything findings in session memory.

# 6. Deep dive — exact vertex layout, draw modes and display-list path (follow-up)

Method for this section: `native_function_study(detail:"complete")` on both renderers
(`ev_5c6399340c6f6222dac35003630becf6d18a9a7d1aad906c92dadd199cb61fd9`,
`ev_63df2e539b7d9e9f3a7301bb1b41629e4313ec7b34fbf334ff7f5cb51f1ce0f8`),
paged with `core_evidence_browse` over the `assembly` facet
(`ev_bc7e176d8f2a6d3eb3a746a88c334cfe51f0e20c98d0639661a6e4e04b9505a8` =
`sub_4ff680` offset 306; `ev_e11ad59e46c7d40b0b9f559064748dd415cfa8d425b9022d2b4bc20189e552d3`
= `sub_501420` offset 694; `ev_4afd403970b61e20e93bbe1e8720a059cac33b6041da68a5286b76c36ba2e08f`
= `sub_501420` display-list branch, offset 110), cross-checked with `native_api_show`
(`ev_bf8072069eab7c5dadb6b53adb98b15e96ba650c541853bdaeb4f8a40d90391d`,
`ev_5b533b72b6b10f9ab91c365aa24e0e271ac1c4d19ad6334fbde6644a41a1a532`).
Windows OpenGL uses `__stdcall`, so pushes are read in reverse as call arguments.
GL symbolic names below are the standard numeric constants for the literals found in the
assembly (e.g. `4` = `GL_TRIANGLES`), not symbols recovered from the binary.

## 6.1 `sub_4ff680` — exact array setup and draws

| Address | Instruction sequence | Decoded call |
|---|---|---|
| `0x4ffa67`–`0x4ffa6c` | `push 0x8074; call 0x4afccc` | `glEnableClientState(GL_VERTEX_ARRAY)` |
| `0x4ffa71`–`0x4ffa7e` | push `[ebp-0x40]`, `0`, `0x1406`, `3`; `call 0x4afeb4` | **`glVertexPointer(size=3, type=GL_FLOAT, stride=0, pointer=[ebp-0x40])`** |
| `0x4ffa83`–`0x4ffa88` | `push 0x8075; call 0x4afccc` | `glEnableClientState(GL_NORMAL_ARRAY)` |
| `0x4ffa8d`–`0x4ffa98` | push `[ebp-0x44]`, `0`, `0x1406`; `call 0x4afd9c` | **`glNormalPointer(type=GL_FLOAT, stride=0, pointer=[ebp-0x44])`** (size implicit 3) |
| `0x4ffa9d`–`0x4ffaa9` | `push 0x8078`; `call [0x8fc7f8]` → deref → `call eax` | `glEnableClientState(GL_TEXTURE_COORD_ARRAY)` through a runtime pointer |
| `0x4ffaab`–`0x4ffabc` | push `edi`, `0xc`, `0x1406`, `2`; `call [0x8fbc68]` → `call eax` | **`glTexCoordPointer(size=2, type=GL_FLOAT, stride=12, pointer=edi)`**; `edi` comes from `[edx+0x24]` at `0x4ff9fa` |
| `0x4ffac8`–`0x4ffadb` | push `[obj+0x90]+8`, `0`; `call [0x8fc854]` | **UNVERIFIED identity** — indirect, runtime-initialised pointer, args `(0, vertex_count)` |
| `0x4ffadd`–`0x4ffaeb` | push `[obj+0x90]+8`, `0`, `4`; `call 0x4afb74` | **`glDrawArrays(GL_TRIANGLES, first=0, count=[obj+0x90]+8)`** |
| `0x4ffb2a`–`0x4ffb41` | `push 0x8074`; push `[ebp-0x20]`, `0`, `0x1406`, `3`; `glVertexPointer` | Indexed path binds **positions only**: `(3, FLOAT, 0, [ebp-0x20])` |
| `0x4ffb65`–`0x4ffb7a` | push `[ebp-0x3c]`, `0x1405`, `[ebp-0x18]+0x1c → +8`, `4`; `call 0x4afb84` | **`glDrawElements(GL_TRIANGLES, count=[obj+0x1c]+8, type=GL_UNSIGNED_INT, indices=[ebp-0x3c])`** |
| `0x4ffba1`–`0x4ffc38` | `push 4; glBegin`; per vertex `glNormal3fv` (`0x4ffbd5`), 3-float indirect call via `[0x8fc144]` (`0x4ffbf1`), `glVertex3fv` (`0x4ffc03`); `glEnd` | Immediate-mode fallback, **`GL_TRIANGLES`**, no glDraw* call |

Page evidence for these literals: `ev_bc7e176d8f2a6d3eb3a746a88c334cfe51f0e20c98d0639661a6e4e04b9505a8`.
The runtime pointer globals (`0x8fc7f8`, `0x8fbc68`, `0x8fc854`, `0x8fc240`, `0x8fc864`,
`0x8fc144`) resolve into BSS-backed addresses with no file bytes, so the identities behind
those indirect calls remain UNVERIFIED (see §3 and `ev_03d2784d…`, `ev_6fdd5722…` etc.).

## 6.2 `sub_501420` — exact array setup and draws

Non-indexed branch (`byte [param_3+0x102] == 0`, starting `0x501d7d`):

| Address | Decoded call |
|---|---|
| `0x501d82`, `0x501d94` | `glEnableClientState(GL_VERTEX_ARRAY)`; **`glVertexPointer(3, GL_FLOAT, 0, [ebp-0x28])`** |
| `0x501d9e`, `0x501dae` | `glEnableClientState(GL_NORMAL_ARRAY)`; **`glNormalPointer(GL_FLOAT, 0, [ebp-0x2c])`** |
| `0x501dbf` | indirect texture-unit select via `[0x8fca5c]`: `push 0x84c0` = `GL_TEXTURE0` (identity inferred from the literal and 25 call sites; pointer is runtime-initialised — `ev_d0a82a3707fcbe1e26555d20293a63373baf0a39a7c1bf346af7eebd7c3eb7d5`, `ev_6866bf3ec2fcf182c4a329c6e598c158ff941bef40d12ddbce4b3da615e4d2a3`) |
| `0x501dc6`, `0x501dd8` | `glEnableClientState(GL_TEXTURE_COORD_ARRAY)`; **`glTexCoordPointer(2, GL_FLOAT, stride=12, [ebp-0x30])`** — primary UV, 2 floats per 12-byte record |
| `0x501df0`, `0x501df7`, `0x501e0c` | select unit `0x84c0 + [ebx+0xcc]`; enable texcoord array; **`glTexCoordPointer(4, GL_FLOAT, 0, [ebx+0xdc])`** — second UV set, 4 floats |
| `0x501e24`, `0x501e2b`, `0x501e40` | select unit `0x84c0 + [ebx+0xd0]`; enable texcoord array; **`glTexCoordPointer(4, GL_FLOAT, 0, [ebx+0xe4])`** — third UV set, 4 floats |
| `0x501e51` | restore unit `GL_TEXTURE0` |
| `0x501e80` | **`glDrawArrays(GL_TRIANGLES(4), first=0, count=[ebx+0x90]+8)`** |
| `0x501ead`–`0x501efd` | restore units `0x84c0+[ebx+0xd0]`, `0x84c0+[ebx+0xcc]`, `0x84c0`; disable `GL_TEXTURE_COORD_ARRAY` ×3, `GL_NORMAL_ARRAY`, `GL_VERTEX_ARRAY` |

Indexed branch (`byte [param_3+0x102] != 0`, starting `0x501f07`):

| Address | Decoded call |
|---|---|
| `0x501f1e` | **`glVertexPointer(3, GL_FLOAT, 0, [ebp-0x10])`** (positions only) |
| `0x501f36`, `0x501f52` | select unit `0x84c0+[ebx+0xcc]`; **`glTexCoordPointer(4, GL_FLOAT, 0, [ebx+0xe0])`** |
| `0x501f6a`, `0x501f86` | select unit `0x84c0+[ebx+0xd0]`; **`glTexCoordPointer(4, GL_FLOAT, 0, [ebx+0xe8])`** |
| `0x501f97` | restore `GL_TEXTURE0` |
| `0x501fcd` | **`glDrawElements(GL_TRIANGLES(4), count=[ebp-0xc]+0x1c → +8, type=GL_UNSIGNED_INT(0x1405), indices=[ebp-0x24])`** |

Page evidence for these literals: `ev_e11ad59e46c7d40b0b9f559064748dd415cfa8d425b9022d2b4bc20189e552d3`.

**Recovered donor vertex layout (both renderers):**
- position: 3 × float32, stride 0 (tight);
- normal: 3 × float32, stride 0 (tight);
- primary UV: 2 × float32 **inside a 12-byte stride** (only 8 of every 12 bytes consumed —
  consistent with a 3-float interleaved record whose third component is unused by this path);
- optional secondary/tertiary UV sets: 4 × float32, stride 0, bound to texture units derived
  from object fields `[obj+0xcc]` and `[obj+0xd0]`, pointers `[obj+0xdc/0xe0]` and
  `[obj+0xe4/0xe8]`;
- indices: **32-bit unsigned int** (`0x1405`), triangle lists;
- **no colour array**: `glColorPointer` (IAT `0x907cc0`) has **0 references**
  (`ev_cc027b2c51e6d99fbedb896d4987bfd457e9fc9831baef37e43d38ef10ea6797`);
  `glGenTextures` likewise has 0 references
  (`ev_a13ae1aeb137d1fc0b5ab62a3206bbb50aea269d697c45902a4cbbcc3972d213`).

**Draw modes:** every draw call uses mode literal `4` = `GL_TRIANGLES`; `glDrawArrays` always
passes `first=0`. There are **no triangle strips or fans**. The indexed path is an ordinary
shared-vertex triangle list with 32-bit indices — structurally the same as the existing
`Mesh.PRIMITIVE_TRIANGLES` + `ARRAY_INDEX` surface in `world3d_terrain.gd`.

## 6.3 Display-list path — terrain or UI? **UNVERIFIED**

- Branch: `cmp byte ptr [ebx+0xbc],0; je 0x501711` at `0x5015bf`/`0x5015c6`
  (`ev_4afd403970b61e20e93bbe1e8720a059cac33b6041da68a5286b76c36ba2e08f`).
  Only when the object flag `+0xbc` is non-zero does the path use lists.
- `glNewList(list=[ebx+0xc0]+8, mode=0x1300 = GL_COMPILE)` at `0x501626`;
  `glCallList` at `0x50163a`; a second list object `[ebx+0xc8]` is compiled at `0x5016c2`
  and called at `0x5016d3`; `glEndList` at `0x5022a2`.
- The list contents are the same 64-byte-stride records copied into `[ebx+0xa4]` by the
  `rep movsd` loops at `0x50150a`–`0x50153d` and `0x50158a`–`0x5015bd`. Thus the list path is
  an **object-level caching alternative inside the generic geometry submitter**, not a separate
  terrain or UI renderer.
- `glNewList@thunk` is also called from 13 other sites across six other functions
  (`ev_c42df22145943a1ce3fa2b32f34eafd74e732f0578dd0be65b8a3efe9402aaa6`), e.g.
  `sub_77ca80` (`ev_35633eb872073ed91a505e0af15172e0594e306fe8455a2cced9695a194417de`) and
  `sub_818920`, which compiles lists with `glColor4fv`/`glVertex4f` immediate-mode calls
  (`ev_39fc9c58c04ec8640f61ffa9ccd78afa77c7d282edab8d198d19b7eab9217669`).
  Display lists are therefore a **general facility**, used by several unrelated subsystems.
- Conclusion: whether the `+0xbc` list path is specifically terrain, entity or UI is
  **UNVERIFIED** — `sub_501420` has 0 static callers
  (`ev_d359dc5d58adeac6be93e25e57f9c1cacf1d38eb838e47c12e5b5dba602443b0`) and its dossier
  records 0 referenced strings (`ev_63df2e539b7d9e9f3a7301bb1b41629e4313ec7b34fbf334ff7f5cb51f1ce0f8`).
  The callee inventory (`ev_5d1101a4813afdb1721219edf908d17d1f8dd0bae0b8965bb7724e26400a3b2a`,
  93 callees) contains only unnamed `sub_…` helpers — no named terrain/water entry point.

## 6.4 What data flows through `sub_4ff680`? **UNVERIFIED**

- 0 static callers for both renderers (`ev_bd6b1c62074e85c694792071cccfd9c9055a8b4a0f28a70e102ff7a225638bcf`,
  `ev_d359dc5d58adeac6be93e25e57f9c1cacf1d38eb838e47c12e5b5dba602443b0`); 0 referenced strings
  in either dossier (`ev_5c639934…`, `ev_63df2e53…`).
- `core_feature_find("XTerrainData")` → 2 `.rsrc` strings, **0 functions / 0 imports / 0 code refs**
  (`ev_b218360cfc5cea8f1d3bc9bd99346f27ab8d6be30d3d432f5cbf0d0e58c1c374`).
- `$XWaterShader`, `XLightShader`, `fXWaterField`, `XWater` → `.rsrc` metadata, `references: []`
  (`ev_bd7f677aadb81603ddecba8ca746523ba9990c205aad4d19ca3f27e86aa3576a`,
  `ev_8030f2d0d42d9fa6e6fa87e1eb054cc0c586b746e11c8fc05a74036adacbd4a5`,
  `ev_4a33e7f85e7d87809415a8418569d0e311efdd6111bd16f37f7a55f0e7f41167`).
- A `lightmap|reflect|detail|fog` string search yields only `glFog*` import names
  (`ev_8974082dcee855aeebec4803fba8f71f8ab5040ca3ce4fc5100ee86d7e35575c`).
- Therefore: it is **proven** that these two functions submit generic indexed/array geometry;
  it is **not proven** which objects (terrain grid, entity mesh, water quad) are submitted at
  any call. The multi-texture path in `sub_501420` (two extra 4-component UV arrays) is
  *structurally suggestive* of terrain detail/lightmap layers, but that is an inference, not a
  finding.

## 6.5 Practical implication for `variant3d/scripts/world3d_terrain.gd`

The current script builds one indexed `ArrayMesh` with `ARRAY_VERTEX`, `ARRAY_NORMAL`,
`ARRAY_TEX_UV` and `ARRAY_INDEX`, and uses a single `StandardMaterial3D` with a splat albedo
(`_terrain_material`, lines 100–115; mesh assembly lines 330–338). It has no ShaderMaterial,
no vertex-colour channel and no separate UV channels.

- **What a simple `ShaderMaterial` could emulate with donor grounding:** (a) the same
  triangle-list indexed geometry (already matches: `GL_TRIANGLES` + 32-bit indices); (b)
  **multi-texture sampling from separate UV channels** — donor binds up to three texture
  units, one 2-component UV with stride 12 plus two 4-component UV arrays; a shader can take
  `UV`, `UV2` and a custom `COLOR`-like float4 attribute for the extra channels; (c) separate
  albedo/detail/fog blending analogous to `glTexEnv*`/`glFog*` call sites.
- **What is NOT donor-grounded here:** vertex colours as albedo. `glColorPointer` has zero
  references; `glColor4fv` appears only in an unrelated display-list compiler
  (`sub_818920`, `ev_39fc9c58…`). Turning on
  `vertex_color_use_as_albedo` would be a port-side art choice, not a donor citation. Likewise
  "tiled diffuse" is structurally plausible (UV arrays exist, and wrap/filter state is set
  elsewhere) but the **tile factor, UV transform and texture repeat parameters are not
  recoverable** from this executable — keep any such constant flagged port-side, as the script
  already does for `EXPOSURE`, `EMISSION_RGB` and `WATER_LEVEL`.
- **Donor literals that ARE recoverable (assembly-verified):** `size=3` (position), `size=2`
  (primary UV), `size=4` (extra UV sets), `type=0x1406` (`GL_FLOAT`), `type=0x1405`
  (`GL_UNSIGNED_INT`), `stride=0` vs `stride=12 (0xc)`, `mode=4` (`GL_TRIANGLES`), `first=0`,
  client-state enums `0x8074/0x8075/0x8078`, texture-unit base `0x84c0` (`GL_TEXTURE0`),
  list mode `0x1300` (`GL_COMPILE`), object-field offsets `+0x90/+0x1c` (counts),
  `+0xcc/+0xd0` (unit indices), `+0xdc/+0xe0/+0xe4/+0xe8` (UV pointers), `+0x46/+0xbc`
  (cache flags) and globals `0x8fbbec`, `0x8f5c6c/0x8f5c7c/0x8f5c80/0x8f5c88` (counters).
- **Donor literals NOT recoverable:** UV values/transforms, tile factors, fog colour/density,
  texgen plane/parameters, water animation/colour constants, actual texture ids and the
  terrain-vs-entity-vs-water assignment. Those require the external `data/**` scripts/shaders;
  do not invent donor-cited numbers in `world3d_terrain.gd` on the strength of this pass.
