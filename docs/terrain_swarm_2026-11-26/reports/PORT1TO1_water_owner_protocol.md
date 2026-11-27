---
id: PORT1TO1-WATER-OWNER-PROTOCOL
worker: WATER-OWNER-PROTOCOL (subagent in full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
ticket: "The single ordered, owner-only GPU capture protocol that settles water in one authorized donor session: exact breakpoints/VAs, glUniform/glBindTexture hooks, texture-id provenance test, U4* scalar layerPtr dump, hmap identity/numbers, reflection matrix, frame/camera sentinels, zero-mismatch termination, and per-dump-outcome port change."
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_DONOR_EXECUTION__NO_PARITY_CLAIM
labels: [O, D, I, U]
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. No donor binary executed, copied, committed, opened for write, or GPU frame captured by this worker. The owner-only session below is SPECIFIED, not performed."
scope_guard: "No repo code/asset/config/shader/Godot/git change. Exactly one repo file written: this report. No Craft Anything native calls. No investigation memory written."
multi_pass: false
visual_parity_claim: false
parity_status: UNVERIFIED
parity_claim: NONE
verdict: "RESULT IS NOT GOOD while blocking_unverified is non-empty (COORD P0 consistency F3 fix)"
reviewer_line: "PORT APPROXIMATION — candidate protocol only; donor parity UNVERIFIED."
upstream: "DEC_U_water_capture.md §§2-7 (VAs/hooks/phases/hard-fail); DEC_U_water_scalar_select.md §§2-5 (U4* two-tuple, layerPtr); DEC_U_water_fbo.md §§2-8 (U12-A/B/C/T/S/P provenance + matrix); DEC_U_water_lib_params.md §§2-3/6-7 (values, captures, diffs); DEC_U_hmap_identity.md §§2-7 (U3 numeric chain + texture identity); variant3d/scripts/water3d.gd; variant3d/scripts/world3d_terrain.gd; variant3d/shaders/water3d.gdshader"
---

# PORT1TO1 WATER — single owner-only GPU capture protocol (read-only, no parity)

## 0. Authority and discipline (read first)

Every statement is `[O]` (verbatim donor bytes/text/decompiled instruction or verbatim port file line), `[D]` (deterministic control-flow/arithmetic from `[O]`), `[I]` (interpretation), or `[U]` (UNVERIFIED — settled **only** by the owner executing §3 under the §5 zero-mismatch rule). Pin `t_87f0f3c130b0` throughout: `C:\Games\Cossacks 3\cossacks.exe`, PE32, 5,768,048 B, sha256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`; decompilation under Ghidra 12.2 + built-in 0.6.1 engine, Deep mode.

- **This worker executed nothing.** No donor binary was run, no GPU frame captured, no debugger/tracer invoked, no Godot/git/code/shader/asset/config change. All donor VAs and evidence ids below are **re-cited pinned records** from the five upstream DEC reports named in `upstream`; they were not re-lifted here. Port file:line anchors marked `VERIFIED` were re-read (read-only) for this protocol; anchors marked `DEC-U` are carried from the upstream reports and **must be re-read at apply time** because those reports note concurrent local modifications (line drift is already observed: e.g. `bind_reflection_map` is now `water3d.gd:501` vs `DEC_U_water_fbo.md`'s `:343-353`).
- **Owner-only.** The §3 session may be run **only by the owner**, on a retail donor install, with a water-visible map and shipped `water.lib` (`CustomEnable=False`, `Speed=1.0`, `HeightMapEnable=True`). Workers are forbidden to run donor binaries or capture frames.
- **No approximation, no parity claim.** This protocol supplies no guessed texture, scalar, unit, matrix, UV dividend, winding, hmap number, or time source. `visual_parity_claim=false` and `parity.status="UNVERIFIED"` hold before, during, and after this document. A capture can only promote a `[U]` item to `[D]+capture-id`; it does not by itself prove visual parity (see §8).

**Load-bearing port fact `[D]` (VERIFIED, unchanged by this report):** water is the largest visible blocker. `variant3d/scripts/water3d.gd:601` `_finalize_water_node()` pushes an error and returns no water node when the BUILTIN reflection target is unbound (`:680-685`), `bind_reflection_map()` at `:501-510` refuses null, and `variant3d/scripts/world3d_terrain.gd:1089-1106` `_make_water3d()` calls `build()` + `bind_height_grid()` (`:1099`) but **never calls `bind_reflection_map()`**. Therefore no water renders. The shader defaults `reflectionMapBound=false` (`water3d.gdshader:126`) and keeps the `PORT APPROXIMATION` screen-space reflection (`:74`, `:329`, `:505`) unreachable. This report does **not** change any of that.

## 1. Notation and GL wrapper map `[O]/[D]`

- `C` = water shader object; `P = C+0x50` = GL program handle slot; VA = file VA (`VA − 0x400C00` = file offset).
- GL wrappers (re-cited `ev_84eb83bef1d668abb4da268019246e5e45def6585098b0785f8f328cbd993114`, `native_bytes_show(0x4c0f90,384)`):

| Wrapper VA | GL call |
|---|---|
| `0x4c0f90` | `glUniform1f` (ptr `0x8fc724` — used for hmapMin/Max, time, scalars) |
| `0x4c0fb8` | `glUniform1i` (ptr `0x8fcb0c` — reflectionMap/waveMap/hmapTex units, hmapW/H) |
| `0x4c0fdc` | `glUniform2f` (waveDir0/1) |
| `0x4c102c` | `glUniform3f` |
| `0x4c1058` | `glUniformMatrix4fv` (count=1, transpose=0) |
| `0x4c0f3c` | `glGetUniformLocation` |
| `0x4c0f5c` | `glUseProgram` |

All extension pointers resolve via `wglGetProcAddress` (import `0x907bbc`); name tables `ev_6eec1ce1633753bbf5d98a4a018c32ef3244689a7372b45ea284169ff84db2be` (GL 2.0 names) / `ev_711e2a981266b3cb2edb487ce33b08fbd32826dffd3ac4b28ff70d8dd0da6673` (glUniform*) / `ev_c380af4afa1f8d45c00409005eb167c5abde0a1dc989495d481d2f01b71ef0c2` (Framebuffer names).

## 2. Consolidated pinned breakpoint / hook / evidence register (all `t_87f0f3c130b0`)

Order here is registration order for reference; **execution order is §3**.

| Ref | VA / site `[O]` | Evidence id (pinned) | Break / hook | What is read there |
|---|---|---|---|---|
| GATE | `FUN_00603d30` @`0x603d30` (DScript `WaterFieldAdd`) | `ev_626574ae222dec3a4ca1b6e81a55874c24cae0e2c0aae4b613d3f350d514f86a`, `ev_c987ab1b4f4baee2d99fe7c877a719d0194ca4f1f803e3605b32547f7dcef8d4` | HW exec break at entry | `[ebp+0x1c]` plane-Y field record — **water-visible sentinel**; no field ⇒ session void |
| U1-INIT | `FUN_00851bdc` @`0x851bdc` | `ev_67a5083d1de168ff448c44405a905f4d010e3f873fcb249547cac621a03c28b` | Exec break at entry | `param_2` layer pointer (`0`→ctor, nonzero→layer copy) |
| U1-CTOR | `FUN_00856080` @`0x856080` | `ev_5aaec0315458ec67490ef87ee4c2c2f70f72e65aef9fbaaacdfbc718ac2de3787`, `ev_d9277ee31a563b52091b6bebce7877657b0d2e258139fc2e9955ec8eaa49cbca` | Exec break at exit | ENGINE defaults: `C+0x184=0`, `C+0xe0=0`, `C+0xec=0`, `C+0xc8..0xcf=0`, scalars `0.4/0.3/4/0.1/0.5/1/0.05/2/0.01/0.4/0.825`, `C+0xc4=1.0`, `C+0xd8=0xde1`, `C+0xdc=2`, `C+0xf8=0`, `C+0xfc=1` |
| U1-COPY | `FUN_00852f5c` @`0x852f5c` | `ev_513eeafe38634fbcdc522d1db8484a0f84f018b6e59a0f58983d37c7202338` (COORD P0 consistency F2 fix; source-attested in `DEC_U_water_lib_params.md:40`) | Exec break at exit | FILE block: `C+0x68/0x78` colours; `C+0x88..+0xc4` scalars; `C+0xb4/+0xbc` dirs; `C+0x184←layer+0x90`, `+0x188←+0x94`, `+0x191←+0x9c`, `+0x190←+0xb8`, `+0x1a8←+0xb4` |
| U1-COMP | `FUN_00855b38` @`0x855b38`; `FUN_00854ac0`/`FUN_008551d8` (embedded VP/FP); link check `FUN_004c0eb4` | `ev_a66a956b6a994521c1060ff03d8490b4284f2b7e15bb4aaebcefc6d7c73984f6`, `ev_5dc9…`, `ev_ce22…` | Exec break entry/exit; hook `glShaderSource` + `glGetUniformLocation` | `P=C+0x50` handle, link status, full VP/FP source text |
| U1-SEL | `FUN_00856530` @`0x856530`; bytes `80 bb 84 01 00 00 00 / 0f 84 fd 02 00 00 / a1 b8 c6 8f 00 / 80 38 00` | `ev_8218b0f1aa21aefba779cac21107bff799438a4c52459533477079bebcbc8642`, `ev_30ba…` | Exec break; single-step two-flag test | `C+0x184`, `[0x8fc6b8]`, `FUN_00855fe8` globals `0x8fcdb0/0x8fbd28/0x8fc748`, `C+0xf0`, `C+0x190`, `C+0x54`; arms: CUSTOM `0x8565d2`, BUILTIN `0x856897`, FIXED `0x856846` |
| U12-BIND | `FUN_00854054` @`0x854054` bit `7c.01 reflectionMap` (`glUniform1i` from `C+0xf8`); bit `7c.02 waveMap` (`C+0xfc`) | `ev_ab751f818e4b8839b359f3da00152283cfd960776db078f970aed7cea91b0641`, `ev_bbdba234fcbb85df996f0f2e5ed4b1df1aaa00f02c95c3861160cc201851db7a`, `ev_41a9076a…` (mask `0x3FFFFFFF`) | Exec break at `7c.01` row; hook `glUniform1i`, `glActiveTexture`, `glBindTexture` | unit `u=C+0xf8`; `(target,name)`; texture object `C+0x4c`, GL id `[C+0x4c+8]`; gate `FUN_00855fe0()` + `C+0x4c` valid |
| U12-PROV | FBO names: `glGenFramebuffersEXT 0x4b98d0`, `glBindFramebufferEXT 0x4b98a0`, `glFramebufferTexture2DEXT 0x4b9920`, `glCheckFramebufferStatusEXT 0x4b98e8`, `glGenerateMipmapEXT 0x4b99a4`, core/ARB `0x4b7080–0x4b7218`. Copy: `glCopyTexImage2D` thunk `0x4afb3c` (import `0x907d7c`), call `0x4ed44c` in `FUN_004ed38c`; `glCopyTexSubImage2D` `0x581444/0x582b56/0x5db443/0x81e66d`. Pbuffer: `wglMakeCurrent/wglCreatePbufferARB/wglChoosePixelFormatARB/wglBindTexImageARB` | `ev_c380…`, `ev_257c8a429a8bd195d6e14eb934118c4933e48f3bdacbd1a25717aff7fceb95f5`, `ev_8096d5d90140786d5b7e0196e1a996a52c8c964d828c825902a879a8264e5cd7`, `ev_6eec…` | Whole-frame API trace (§3 step 10) | `name` classified as FBO attachment (b) / copy dst (a) / upload only (c) |
| U12-MAT | `FUN_0085756c`, `FUN_0085787c`; builders `FUN_004cdd9c(…,0x60,…)`, `FUN_004cdbdc` | `ev_2b512f029199e31de846bb803fa47db8e45e1c64a0757b792b2a58512a19eb49`, `ev_0348…` | Exec break entry/exit of `5756c` + `4cdd9c`/`4cdbdc`; hook `glUniformMatrix4fv` | 4×4 at caller `+0x60`, `glViewport/glScissor`, `GL_FRAMEBUFFER_BINDING`; level vs pitched camera |
| U12-S | `DiffuseWaves0/2` uploads (`water.mat`, `water.lib:43-44`) | `ev_2c6662253590cd2c759fb60b23c907bcb0113e1da18402b3bb7d9dadebd3cfb`, `ev_2eb0…`/`ev_227e…` | API trace upload names | reflection `name` == waves upload name ? |
| U3-NUM | `FUN_008520a8` @`0x8520a8`; chain `FUN_00739bf8` @`0x739bf8`, `FUN_0082f86c` @`0x82f86c`, `FUN_0082f060` @`0x82f060`, `FUN_0082f114` @`0x82f114`; binder gate `0x854250` | `ev_ada19843eaa6b989e47f1d8dd8a5c512875c5ef290b66241b73905af4e63852b`, `ev_ab75…`, `ev_bbdb…` | Exec break at binder rows `7e.10–7f.01`; walk chain pointers | `C+0xd0`(W), `C+0xd4`(H) ints; `C+0xe4`(Min), `C+0xe8`(Max) floats; gate `C+0xe0`, `[C+0xe0+8]` |
| U3-TEX | unit `C+0xdc` (ctor 2), target `C+0xd8` (ctor `0xde1`) | `ev_5aaec031…`, `ev_ada1…` | Hook `glActiveTexture(GL_TEXTURE0+C+0xdc)`, `glBindTexture`, `glGetTexLevelParameteriv` | `(target,name,w,h,INTERNAL_FORMAT)`, provenance of `name`, one texel block |
| U6-MESH | `FUN_00826b30` @`0x826b30`: `glBegin(4)` → vtable `+0x98(group,caller,1,1)` → `glEnd` | `ev_0510…`, mesh cache `ev_74d8…/ev_f2c0…/ev_31d8…` | Exec break on virtual `+0x98` | `MultiTexCoord0` array (4×f32), 6 indices or draw first/count, `GL_CULL_FACE/GL_FRONT_FACE`, same-frame `hmapW/H` |
| U5-TIME | binder bit `7c.04` at `0x854091`: `fld qword [esi+0xc8]; fmul qword [esi+0xc4]; fstp dword [esp]` | `ev_bbdb…`, `ev_84eb…` | Hook `glUniform1f(time)`; HW write-watchpoint on `C+0xc8` (8 B) | `time_uniform=(float)(dbl[C+0xc8]*dbl[C+0xc4])`, `C+0xc4=Speed=1.0`, writer EIP or constant-0 verdict |

**Explicit non-matrix note `[D]`:** `cameraModel` (bit `7f.20`, from custom-shader object `C+0xf0→+0xc0→+0x24`, bound inside the shadow gate `C+0xec != 0` at `0x8542d2`) is **not** a reflection matrix and must never be captured or bound as one (U12 hard-fail matrix §7).

## 3. ONE-session ordered owner protocol (do top-to-bottom; ★ = stop-and-gate)

Tooling: debugger with HW exec/data breakpoints (x64dbg / WinDbg) **plus** one GPU API tracer (RenderDoc / apitrace / Nsight-GL). One launch, one water-visible map (default shore/skirmish map), shipped `water.lib` unmodified. No donor file is written. Each step logs: breakpoint VA, register/memory dump, API-trace event ids, sentinel check (§4), and the Phase-1 PATH label.

### Phase 0 — session gating (★ gate for everything)

1. Launch donor under tracer; load a water-visible map; pause.
2. Exec-break `FUN_00603d30` @`0x603d30` entry; read `[ebp+0x1c]` and confirm a water field is constructed. **If no field break fires, the session is invalid — move camera to a shore or load a shore map. Captures from a session with no field break settle nothing.**
3. Start API trace + frame counter. From here every phase records **≥2 water-visible frames + 1 camera move (level → pitched)** unless stated otherwise.

### Phase 1 — U1 live shader path (★ labels every later dump)

4. Exec-break `FUN_00851bdc` @`0x851bdc` entry: record `param_2`. `0` ⇒ ctor `FUN_00856080` @`0x856080` (ENGINE); nonzero ⇒ `FUN_00852f5c` @`0x852f5c` (FILE). At the taken arm's exit dump `C+0x184/+0x188/+0x190/+0x191/+0x1a8`, `C+0x68..+0xc4`, `C+0x50`, `C+0x54`. Sentinel: shipped config predicts `C+0x184=0` (CUSTOM unreachable) — record actual, do not assume.
5. Exec-break `FUN_00855b38` @`0x855b38` entry/exit: record `P=C+0x50` and confirm link check `FUN_004c0eb4` passed (no `FUN_004b03b8` error).
6. Exec-break `FUN_00856530` @`0x856530`: single-step the two-flag test; record `C+0x184`, `[0x8fc6b8]`, `FUN_00855fe8` globals (`0x8fcdb0/0x8fbd28/0x8fc748`), and which arm fires — CUSTOM `0x8565d2`, BUILTIN `0x856897`, FIXED `0x856846`. Record `C+0xf0`/`C+0x190` at the CUSTOM arm if taken.
7. Hook `glShaderSource` (`ev_a66a…` texts): dump both source texts verbatim. **Path label rule:** `hmapTex` present ⇒ `PATH=DEV` (file `water.dev.vert/frag`); `alphaDepth`+`deepColor` and no `hmapTex` ⇒ `PATH=BUILTIN` (embedded `ev_5dc9…`/`ev_ce22…`); neither ⇒ `PATH=FIXED`. Hook `glGetUniformLocation` (`0x4c0f3c`) to log all key strings actually queried (expect mask `0x3FFFFFFF`, `ev_41a90…`).
8. ★ **U1 verdict:** write `PATH ∈ {DEV,BUILTIN,FIXED}` + `C+0x184/[0x8fc6b8]/P` + program handle. **Every later dump is tagged with this PATH; a dump on the wrong path settles nothing** (BUILTIN embedded pair has no hmap uniforms; DEV has them).

### Phase 2 — U4* scalar tuple (layerPtr dump) — opportunistic, same session

9. The Phase-1 step 4 dump already decides U4*: `param_2==0` ⇒ ENGINE tuple; `param_2!=0` ⇒ FILE tuple. Dump the whole `C+0x88..+0xc4` block + `C+0xb4/+0xbc` dirs + `C+0x68/+0x78` colours + `C+0xc4` Speed. `[D]` no per-scalar mix is reachable — each arm writes the block atomically (§2).
10. Hook `glUniform1f` (`0x4c0f90`) on S1–S11 locations and `glUniform2f` (`0x4c0fdc`) on W0/W1 on the U1 program; record floats/pairs across the first water draw plus texScaleS/T (S10/S11).
11. ★ **U4* verdict:** the captured tuple must be bit-exact one of the two donor-enumerated tuples (§4 column "FILE"/"ENGINE"); 0 ULP across 2 frames + camera move. The source-text literals `0.01/0.02` are **pre-bind defaults, never live uniforms**; do not record them as a live S10/S11.

### Phase 3 — U12 reflection provenance + unit + matrix (★ gate for water draw)

12. With PATH known and a field visible, break `FUN_00856530` reflection gate + `FUN_00854054` bit `7c.01`. Hook `glUniform1i(reflectionMap)` → record `u=C+0xf8`; trace `glActiveTexture(GL_TEXTURE0+u)` + `glBindTexture(target,name)` → record `(target,name)`. Record texture object `C+0x4c` and id `[C+0x4c+8]`; **they must agree with `name` — a mismatch is itself the finding**.
13. **Texture-id provenance test (whole frame, step 10 trace):**
    - (a) all `glGen/Bind/FramebufferTexture2D/CheckStatusEXT` with texture-name args;
    - (b) all `glCopyTexImage2D` (thunk `0x4afb3c`, call `0x4ed44c`) and `glCopyTexSubImage2D` (`0x581444/0x582b56/0x5db443/0x81e66d`) with dst name + src rect;
    - (c) all `glTexImage2D` uploads with `(name,w,h,source)`, incl. any `DiffuseWaves0/2` string;
    - (d) `glGetIntegerv(GL_FRAMEBUFFER_BINDING)` at the bind;
    - (e) `wglMakeCurrent/wglCreatePbufferARB/wglChoosePixelFormatARB/wglBindTexImageARB` sweep.
    **Classify `name`:** FBO attachment earlier in frame ⇒ **(b) separate pass**; copy dst after main scene before water ⇒ **(a) framebuffer copy**; upload-only, never FBO/copy dst ⇒ **(c) static**. Sample ≥2 frames + move to separate per-frame refresh from one-time upload.
14. At the same break record `glGetTexLevelParameteriv(name,0,{WIDTH,HEIGHT,INTERNAL_FORMAT})`, `GL_GENERATE_MIPMAP`/`glGenerateMipmapEXT` on `name`, `MIN/MAG_FILTER`, `WRAP_S/T`.
15. Break `FUN_0085756c` entry/exit + `FUN_004cdd9c`/`FUN_004cdbdc`; dump the 4×4 at caller `+0x60` and `glViewport/glScissor` + `GL_FRAMEBUFFER_BINDING` immediately before/after. Repeat level-camera and pitched-camera. If also uploaded as a uniform, hook `glUniformMatrix4fv` (`0x4c1058`) and cross-check.
16. U12-S: correlate `name` with any `DiffuseWaves0/2` upload name — identical ⇒ one name; distinct ⇒ separate samplers.
17. ★ **U12 verdict:** `(provenance_class ∈ {a,b,c}, target, name, w, h, unit u, matrix M, viewport)` with §5 zero-mismatch. Else U12 stays `[U]` and the port keeps refusing water.

### Phase 4 — U3 hmap identity + numbers

18. Break binder rows `7e.10–7f.1` (`0x854250–0x8542f0`) with a field visible **and the height gate open** (`C+0xe0!=0 && [C+0xe0+8]!=0`; a closed gate voids the frame). Record `C+0xd0`(W), `C+0xd4`(H), `C+0xe4`(Min), `C+0xe8`(Max), gate values, unit `C+0xdc`, target `C+0xd8`. Walk one level and record each pointer: `layerObj`, `h=FUN_00739bf8(layerObj)` @`0x739bf8`, `h+0x200`, `C+0xe0=FUN_0082f86c(*(h+0x200))` @`0x82f86c`, Min/Max getters `FUN_0082f060/0082f114` @`0x82f060/0x82f114` on `+0x200`.
19. Same frame: `glActiveTexture(GL_TEXTURE0+C+0xdc)` + `glBindTexture(target,name)` + `glGetTexLevelParameteriv` + sampler state; classify `name` exactly as step 13. Dump one texel block (e.g. 8×8 raw/float) beside the port `height_tex` encoding. **Do not substitute** `heightmapwaves0.tga` (alpha 255, `water.mat:86-106` commented) or a 1×1 neutral texel.
20. ★ **U3 verdict:** identical 4-tuple numerics + identical `(target,name,w,h)` + unanimous provenance across ≥2 frames + camera move. All four numbers are per-map reads of the loaded terrain; a different map needs its own row. `MaxHeight` is absent from `water.lib`; `texturemap.inc:29 cMaxHeight=2.96` is a **classification literal, not** `hmapMin/Max`.

### Phase 5 — U6 mesh UV / winding

21. Break virtual `+0x98` from `FUN_00826b30` for one 2×2 field. Dump bound `MultiTexCoord0` array (4 verts f32), element/index array (6 indices) or `glDrawArrays` first/count, `glGetIntegerv(GL_CULL_FACE/GL_FRONT_FACE)` + `glFrontFace/glCullFace` trace, and same-frame `hmapW/H`. Note the two trailing `1,1` args of `vtable+0x98(group,caller,1,1)` as observed integers with no assigned meaning.
22. Compute `uv_pred = attr/(W,H) − 0.5` per vertex (donor-verbatim `water.dev.vert:14/16-18`) and compare with read-back `gl_TexCoord[1].xy`; compare index order element-wise and `cull_disabled` vs `front_winding`. Record diagonal + CW/CCW explicitly.
23. ★ **U6 verdict:** bit-exact UV (0 float32 error) and index-exact winding across ≥2 fields + camera move. Else U6 stays `[U]`.

### Phase 6 — U5 time (sampled throughout)

24. Hook `glUniform1f(time)` (program from Phase 1) across ≥3 frames spanning ≥2 s; log floats. If non-constant, HW write-watchpoint on `C+0xc8` (8 B) → writer EIP + disassembly → nearest symbol. If constant `0.0` with watchpoint silent over 10 s, verdict is `time=0`-by-capture. Verify `float(dbl[C+0xc8]*dbl[C+0xc4])` reproduces the uniform with 0 ULP; `C+0xc4` must read `1.0`.

**Session close:** export tracer frame(s) + breakpoint log + all dumps, each labelled with PATH, camera pose, and map name. Total: one launch, one map, one tracer file.

## 4. Frame / camera sentinels (record actual — never force)

| Sentinel | Donor-literal `[O]/[D]` | Meaning if different |
|---|---|---|
| Field-visible @`0x603d30`, `[ebp+0x1c]` | `WaterFieldAdd` constructs field + writes plane Y (`ev_6265…`) | No field break ⇒ **session void, nothing settled** |
| `C+0x184 == 0` | `CustomEnable=False` (`water.lib:51`, `ev_2eb0…`) + ctor `+0x184=0` (`ev_5aae…`) | Nonzero + `[0x8fc6b8]!=0` ⇒ CUSTOM live; re-label all later dumps DEV |
| `[0x8fc6b8]`, `0x8fcdb0/0x8fbd28/0x8fc748`, `C+0x54` | selector inputs (`ev_8218…`, `ev_30ba…`) | Any zero ⇒ FIXED arm; missing uniforms explained |
| `P=C+0x50` nonzero + link OK | `FUN_00855b38` embedded pair (`ev_a66a…`) | Zero/link-fail ⇒ no BUILTIN program |
| Mask `C+0x7c..+0x7f == 0x3FFFFFFF` | all-30-on (`ev_41a90…`) | Missing bits ⇒ those uniforms never bound; record which |
| `C+0xc4 == 1.0` (double) | `Speed=1.0` (`water.lib:42`, `ev_513e…`) | Other ⇒ time scale differs; formula still holds |
| `C+0xc8..+0xcf == 0` at construction | ctor zeroes (`ev_5aae…`) | Nonzero at first draw ⇒ writer ran earlier; catch it sooner |
| `C+0xf8 / +0xfc / +0xdc` units | reflection/wave/hmap sampler units (ctor `+0xfc=1`, `+0xdc=2`; `+0xf8` engine) | Any assumed 0/1/2 alias without the hook read is **forbidden** |
| `C+0xd8 == 0xde1` | `GL_TEXTURE_2D` ctor default (`ev_5aae…`) | Other target changes the port sampler type |
| `C+0xe0==0` or `[C+0xe0+8]==0` | height gate closed at `0x854250` | **U3 numerics/texture dumps from such a frame are void** |
| `C+0xec==0` | shadow gate closed at `0x8542d2` | `cameraModel` read from such a frame is void — and it is not a reflection matrix anyway |
| Camera level → pitched | — | Required to expose clip-plane dependence of the reflection matrix and the per-frame FBO/copy refresh |

## 5. Zero-mismatch termination criteria (every item; no partial credit)

A `[U]` item retires **iff** its tuple is identical with **0 differing bits/elements** across **≥2 water-visible frames + 1 camera move**, all tagged with the same Phase-1 PATH. Any mismatch, missing dump, closed gate, or PATH mixing ⇒ item stays `[U]` and its port hard-fail stays. "Close" never counts.

| Item | Tuple that must repeat with zero mismatch | Minimum sample |
|---|---|---|
| U1 | `(PATH, C+0x184, [0x8fc6b8], P, VP/FP source hash)` + arm taken at `0x856530` | 2 draws + move; source hash identical |
| U4*-CORE | `(param_2==0?, C+0x88..+0xc4)` bit-exact one donor tuple | 0-ULP 2 frames + move |
| U4*-W0/W1 / S10/S11 | captured pairs consistent with winning CORE tuple | same draw, 2 frames + move |
| U12-A | `(provenance_class ∈ {a,b,c}, target, name)` — step 13 decision | 2 frames + move; classification unanimous |
| U12-B/C | `(w,h,internal_format,min/mag,wrap_s/t,mip_state,unit u, C+0x4c/[C+0x4c+8]↔name agreement)` | 2 frames + move |
| U12-T | `(4×4 at caller+0x60, viewport/scissor, FBO binding)` — level vs pitched recorded separately | 2 frames per pose + pose change |
| U12-S | `(reflection_name == waves_upload_name ? 1:0)` | 1 upload frame, confirmed on 2nd |
| U3-NUM | `(W bits,H bits,Min bits,Max bits,C+0xe0/[C+0xe0+8])` 0-differing, named map | 2 frames + move |
| U3-TEX | `(target,name,w,h)` 0-differing + unanimous provenance + texel block | 2 frames + move |
| U6-UV | `max‖attr/(W,H)−0.5 − VS_TexCoord1.xy‖ == 0.0` bit-exact f32, all verts | ≥2 fields + move |
| U6-WIND | index sequence 0-differing + identical `(CULL_FACE,FRONT_FACE)` | ≥2 fields + 2 frames |
| U5 | (a) all `time` samples `0.0`, watchpoint silent 10 s; or (b) one writer EIP every frame, 0 missed frames, formula 0 ULP | (a) 10 s / (b) ≥3 frames over ≥2 s |

## 6. Outcome → exact port change (owner applies; NO edits made here)

Each row fires **only** on its zero-mismatch capture. Until then the corresponding hard-fail / labelled substitute stays. Line anchors marked `VERIFIED` were re-read for this protocol; re-read again before applying because concurrent drift is observed.

| Zero-mismatch dump outcome | Exact port change (which tuple / FBO / matrix to bind) | What remains hard-failed |
|---|---|---|
| **U1 = BUILTIN** | Keep `water3d.gd:168 VERIFIED` `DEFAULT_WATER_SHADER_PATH = BUILTIN` and shader `:23` labelled default; keep DEV/LEGACY selectable but unreachable by default; record `(P,source hash)` in telemetry; bind U12/U3/U6 under BUILTIN | U12, U3, U4*, U5, U6 stay `[U]`; no water until a real reflection texture + matrix bind lands |
| **U1 = DEV** | Flip default to DEV **only** with captured `(P, hmapTex-present source hash)`; wire `hmapW/H/Min/Max + hmapTex + cameraModel(textureMatrix[3]·cameraModel·modelView)` per `water.dev.vert:14-17`; U3/U6 become draw-load-bearing (BUILTIN `texScaleS/T` path retired) | U12 reflection still hard-fails; U3/U6 must still be captured (DEV reads them live) |
| **U1 = FIXED** | Retire both shader variants; implement legacy `glMatrixMode/glLight` path only; mark U3/U12 rows N/A with reason (no custom uniforms bound) | No custom-path water; U4*/U5/U6 legacy substitutes stay labelled |
| **U4* = FILE** | Bind `WATER_SCALARS_FILE` (`water3d.gd:260 VERIFIED`) and waveDirs `(-1,0)/(-0.7,0.7)`; bind captured S10/S11 `0.1/0.01` (replacing `BUILTIN_TEX_SCALE_S/T = 0.01/0.02` at `:107-108 VERIFIED`, shader `:140-141`); require `set_water_scalar_source("FILE")` via `:446 VERIFIED`; keep tuple labelled `[D]+capture-id` | U12 reflection still hard-fails; cannot call `"ENGINE"`; waveDir ENGINE null-guard at `:829 VERIFIED` stays |
| **U4* = ENGINE** | Bind `WATER_SCALARS_ENGINE` (`:278 VERIFIED`): S1–S11 `0.4/0.3/4/0.1/0.5/1/0.05/2/0.01` + **captured** S10/S11 (ctor `C+0xac/+0xb0`, expect `0.4/0.825`, no invention) + **captured** W0/W1 pairs (replace the `null` engine dirs at `:829 VERIFIED`); `0.01/0.02` retired as live | U12 reflection still hard-fails; any W0/W1 not captured ⇒ engine selection keeps hard-failing on null dirs |
| **U12 = (b) FBO pass** | After `bind_height_grid` success in `_make_water3d` (`world3d_terrain.gd:1099 VERIFIED`), call `bind_reflection_map(<captured-provenance Texture2D>)` importing the captured FBO colour attachment at captured `(w,h)`, bound to captured unit `u`, with the captured matrix M from U12-T; extend `_finalize_water_node` (`water3d.gd:601 VERIFIED`, gate `:680-685`) to require texture+unit+matrix; replace screen-`gl_FragCoord` scaffolding (`shader:74/:329/:505`) with the captured projective path | No grey fallback; if any of A/B/C/T missing ⇒ same `push_error` + no node; `cameraModel` never reused as reflection matrix |
| **U12 = (a) framebuffer copy** | Same wiring, but the Texture2D wraps the captured **copy-dst** target updated after the main scene each frame (Godot `ViewportTexture`-equivalent fed from captured src rect); record copy rect + pre/post FBO binding | Same as (b); never a viewport-sized heuristic target; no per-frame refresh code without captured rect |
| **U12 = (c) static upload** | Bind the captured uploaded texture by `(name→art file, w, h, unit)`; U12-S decides whether it shares the `DiffuseWaves` sampler or is its own sampler; no per-frame refresh code | `reflectionMap` stays unbound (hard-fail) until the capture names a real texture; no promotion of `diffusewaves*` art without U12-S identity |
| **U3-NUM** | Replace `MAX_HEIGHT=2.96` / `-MAX_HEIGHT/+MAX_HEIGHT` (`water3d.gd:68/:652/:668-669 VERIFIED`, shader `:50/:165-166/:202/:440`) with captured `(W,H,Min,Max)` as required per-map params, keeping `hmapMin + w*(hmapMax−hmapMin)` shape; delete the `map_size/128` divisor basis | Other maps need their own capture; any closed height gate ⇒ labelled `[U3]` substitute stays; `±2.96` never presented as recovered |
| **U3-TEX** | Add `bind_engine_hmap(real_texture, target_enum)` importing captured `(target,name)` provenance (FBO/copy/static per step 13) to `hmapTex`/`hmapTexBound` (`shader:169-170`); retire the `height_tex` alias from `bind_height_grid` for the captured map | Never `heightmapwaves0.tga`/`diffusewaves*`/1×1 neutral; do not emulate `[C+0xe0+8]` as a GL name without U3-TEX |
| **U6-UV** | Set the `MultiTexCoord0/(hmapW,hmapH)−0.5` dividend domain (`water3d.gd` height-grid encoding, shader `:362`) to the captured domain; divisor = captured U3-NUM W/H, never `map_size` | Closed hmap gate or wrong dividend ⇒ `[U6]` stays; no `(x+0.5)/w` or `fract(world*0.5)` invented dividend |
| **U6-WIND** | Set mesh indices to captured 6-element order; set `render_mode` at `shader:37 VERIFIED` to captured `(cull_disabled / cull_back + front_winding)`; record diagonal explicitly | Any mismatch ⇒ `[U6]`; no invented diagonal/cull presented as donor |
| **U5 = animated / frozen** | Replace `_time += delta` (`water3d.gd:383 VERIFIED`) with captured writer EIP (or freeze `0.0` if constant), keeping comment `time=(float)(dbl[+0xc8]*dbl[+0xc4]), Speed=1.0`; keep `time` uniform (`shader:78-80`) | Writer unknown ⇒ `_time` stays labelled `[U5]` scaffolding, never presented as donor time |
| **U4* = ctor / layer path** | Pin the scalar table to the observed path and **assert** it in `t_water.gd` instead of silently supporting both; keep UNSET refusal at `water3d.gd:745-747 VERIFIED` until capture | No default FILE/ENGINE; UNSET ⇒ `push_error` + no water |

## 7. Hard-fail matrix — gaps that may NEVER be substituted

Any ✗ means observing the gap does **not** license the invention. Port must `push_error` + skip the water node (`water3d.gd:601/:680-685`, shader `:126/:404/:436`). No neutral texture, no invented matrix/UV/FBO/scalar.

| Gap → / Forbidden substitute ↓ | U1 path unknown | U12 provenance unknown | U12 size/unit/matrix unknown | U6 UV/winding unknown | U3 numbers/texture unknown | U5/U4* unknown |
|---|---|---|---|---|---|---|
| Assume BUILTIN/DEV/LEGACY default beyond labelled `[D]` default | ✗ | — | — | — | — | — |
| Neutral/grey/generated 1×1 texture as `reflectionMap`/`hmapTex` | — | ✗ | ✗ | — | ✗ | — |
| `diffusewaves0/2` or `heightmapwaves0.tga` aliased to `reflectionMap`/`hmapTex` | — | ✗ | — | — | ✗ | — |
| Viewport-sized FBO / `get_viewport()` heuristic target | — | ✗ | ✗ | — | — | — |
| `*0.5+0.5` screen-UV bias or invented mirror matrix | — | ✗ | ✗ | — | — | — |
| Assumed sampler unit 0/1/2 without `C+0xf8`/`C+0xdc` hook read | — | ✗ | ✗ | — | ✗ | — |
| `fract(world*0.5)` / `(x+0.5)/w` / grid-derived dividend | — | — | — | ✗ | — | — |
| `map_size/128`, `map_size.x/y`, `±2.96` / `±MAX_HEIGHT` span | — | — | — | ✗ | ✗ | — |
| Invented index order / diagonal / `cull_disabled` presented as donor | — | — | — | ✗ | — | — |
| `cameraModel` (shadow-gated `C+0xf0→+0xc0→+0x24`) reused as reflection matrix | — | ✗ | ✗ | — | — | — |
| `_time += delta` / wall-clock / frame-count presented as donor time | — | — | — | — | — | ✗ |
| `water_surface_y=-0.25`, `#6E99A8` legacy colour, `water_cell` alpha gate as "close enough" | ✗ | ✗ | — | — | ✗ | — |
| Defaulting `set_water_scalar_source` to `"FILE"`/`"ENGINE"`, or calling `bind_reflection_map()` with any non-captured texture "to make water appear" | ✗ | ✗ | ✗ | — | — | ✗ |

Telemetry rule: keep `visual_parity_claim=false`; each retired sub-item flips to `[D]+capture-id` with its tuple; everything else stays `[U]` with the phase/step that would settle it.

## 8. Status until the owner executes §3 (explicit, non-negotiable)

- **Port stays HARD-FAIL, no water drawn.** `_finalize_water_node()` (`water3d.gd:601`) still pushes an error and returns no node while `reflectionMap` is unbound; `bind_reflection_map()` (`:501`) still refuses null; `_make_water3d()` (`world3d_terrain.gd:1089-1106`) still never calls it; shader `reflectionMapBound=false` (`:126`) still discards. **No grey fallback, no neutral quad, no generated 1×1 texture, no screen-space approximation promoted to donor.**
- **U4* stays UNSET-dark.** `set_water_scalar_source` has no default; `water3d.gd:745-747` refuses water and no FILE/ENGINE tuple is asserted as "the" donor value.
- **U3/U6/U5 stay labelled substitutes** (`height_tex` grid, `±2.96` span, `_time += delta`), never presented as recovered donor values.
- **Parity UNVERIFIED.** Nothing in this report is a capture, a gate PASS, or an A/B frame. Even after the owner captures and the port is updated, a matched-seed donor-vs-port GPU A/B frame is still required before any parity statement (X39). `parity.status="UNVERIFIED"`, `parity.claim=NONE` throughout.

## 9. Explicit non-claims and file discipline

- **No parity claim.** No donor binary executed, no GPU frame captured, no port capture compared. All donor readings are re-cited `[O]/[D]` from the five pinned upstream DEC reports; all unsettled values are `[U]` with the §3 experiments and §5 gates.
- **No approximation supplied.** No texture, size, unit, matrix, viewport, scalar, UV dividend, winding, hmap number, or time source is chosen here. The port's current hard-fail posture is endorsed as the donor-faithful behaviour until a zero-mismatch capture lands.
- **Read-only compliance.** Exactly one repo file written: `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_water_owner_protocol.md`. No code/shader/asset/config/Godot/git change. No donor file opened for write or executed. No Craft Anything native call, no investigation memory written. Active donor target never opened/selected/closed by this worker.

*End of PORT1TO1-WATER-OWNER-PROTOCOL.*
