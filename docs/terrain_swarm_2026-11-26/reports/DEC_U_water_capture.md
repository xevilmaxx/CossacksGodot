---
id: DEC-U-WATER-CAPTURE
worker: DEC-U-WATER-CAPTURE (subagent in full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
ticket: "Concrete ordered GPU/runtime capture plan settling U1/U12/U6/U3 in ONE donor session; hard-fail matrix; no code/Godot/git edits"
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
labels: [O, D, I, U]
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. No donor binary executed, copied or committed. No donor file written."
scope_guard: "No repo code/asset/config/shader/Godot/git change. Exactly one repo file written: this report."
multi_pass: true
visual_parity_claim: false
upstream: "DEC_U_water_runtime.md §§3-9 (U1/U3/U4/U5/U6/U12); DEC_U_water_fbo.md §§3-8 (U12); DEC_U_water_mesh_uv.md §§3-8 (U6/U3/U5/U12); PORT1TO1_water_shore.md §§4/7/11"
---

# DEC-U-WATER-CAPTURE — one-session GPU/runtime capture plan for U1, U12, U6, U3 (read-only decomp, no parity)

## 0. Authority and discipline (read first)

Every statement below is `[O]` (verbatim bytes/text/decompiled instruction or verbatim port file line), `[D]` (deterministic control-flow/arithmetic from `[O]`), `[I]` (interpretation) or `[U]` (UNVERIFIED — settled only by the capture in §3 with the zero-mismatch rule in §5; until then the port must **hard-fail, never substitute** per §7). This worker issued **no Craft Anything native calls** (only repo/doc reads via default tools in this subagent context); all donor VAs/evidence ids are **re-cited pinned records** from the upstream reports above, each pinned `document:"t_87f0f3c130b0"`, Deep mode (Ghidra 12.2 + built-in 0.6.1 engine). No donor binary was executed, no GPU frame was captured by this worker, no parity is claimed. Active donor target was never opened/selected/closed by this worker. No helper script was written or run by this worker.

`[D]` Load-bearing context: water is the largest remaining visual blocker — the port hard-fails water draw because U12 reflection provenance is unresolved, so NO water renders (`variant3d/scripts/water3d.gd:520-527` hard-fail; `bind_reflection_map` at `water3d.gd:343-353` refuses null; `_make_water3d` at `world3d_terrain.gd:1089-1106` never calls it). This report does NOT change that behaviour. It specifies the single cheapest owner-authorised donor session that would retire U1, U12, U6, U3 (with U5/U4* sampled opportunistically in the same session).

---

## 1. Pass ledger (owner rule ≤5 passes/function; every pass logged)

This ticket performed **document/byte-record re-analysis passes only** (no new native lifts). Each pass re-reads one cited record and extracts the breakpoint/GL observable it mandates. No function exceeds 5 prior + current passes.

| # | Question / function | Pass this ticket | Result |
|---|---|---|---|
| R1 | Selector `FUN_00856530` @0x856530 + globals | 1 re-read: Deep pseudo `ev_8218b0f1aa21aefba779cac21107bff799438a4c52459533477079bebcbc8642` + raw bytes 0x856530–0x8565e0 | **Accepted**: U1 breakpoint set (Phase 1); conditions `C+0x184` / `[0x8fc6b8]` |
| R2 | Compile `FUN_00855b38` @0x855b38 + `FUN_00854ac0/008551d8` pair | 1 re-read: `ev_a66a956b6a994521c1060ff03d8490b4284f2b7e15bb4aaebcefc6d7c73984f6` + `ev_5dc9…`/`ev_ce22…` | **Accepted**: program at `C+0x50`; BUILTIN-vs-DEV source test |
| R3 | Layer init `FUN_00851bdc` @0x851bdc + copy `FUN_00852f5c` @0x852f5c + ctor `FUN_00856080` | 1 re-read each: `ev_67a5…`, `ev_513e…`, `ev_5aae…` | **Accepted**: U4*/U1 flag writes (`+0x184/+0x188/+0x190/+0x191/+0x1a8`, Speed→`+0xc4`) |
| R4 | Binder `FUN_00854054` @0x854054 + raw 0x854080–0x8542f0 | 1 re-read: `ev_ab75…` + `ev_bbdba234fcbb85df996f0f2e5ed4b1df1aaa00f02c95c3861160cc201851db7a` | **Accepted, decisive**: all bit rows (§2 table); gates at 0x854250 (hmap) / 0x8542d2 (shadow) |
| R5 | Height staging `FUN_008520a8` @0x8520a8 | 1 re-read: `ev_ada19843eaa6b989e47f1d8dd8a5c512875c5ef290b66241b73905af4e63852b` | **Accepted**: hmap numeric source chain (Phase 4) |
| R6 | Reflection `FUN_0085756c`/`FUN_0085787c` + `FUN_004cdd9c/FUN_004cdbdc` | 1 re-read: `ev_2b51…` + `ev_0348…` + P12 caller scan | **Accepted as localized**: object `C+0x4c` (id `+8`), unit `C+0xf8`, matrix via `(…,0x60,…)` |
| R7 | Draw `FUN_00826b30` @0x826b30 + vtable `+0x98` + mesh cache `00545e0c/00545d64/00545bd8` | 1 re-read each: `ev_0510…`, `ev_74d8…`, `ev_f2c0…`, `ev_31d8…` | **Accepted as localized**: `glBegin(4)`, `(group,caller,1,1)`, no water vertex writer |
| R8 | GL wrappers `004c0f3c/0f90/0fb8/0fdc/102c/1058` + name tables + thunk | 1 re-read: `ev_84eb…`, `ev_6eec…`, `ev_711e…`, `ev_257c…`, `ev_8096…`, `ev_c380…` | **Accepted**: hook map for `glUniform*/glShaderSource/glCopyTexImage2D`/FBO names |
| R9 | Field `FUN_00603d30` @0x603d30 + registration `ev_c987…` | 1 re-read: `ev_626574ae…` + `ev_c987…` | **Accepted**: water-visible gating break |
| R10 | Port guards `water3d.gd` / `water3d.gdshader` / `_make_water3d` | 1 repo read each (HEAD) | **Accepted as `[O]`**: §6 diff anchors; hard-fail verified present |

---

## 2. Pinned VA / breakpoint / observable register (all `t_87f0f3c130b0`)

VA = file VA (`VA − 0x400C00` = file offset). `C` = water shader object, `P = C+0x50` = GL program handle slot.

| Group | VA / site `[O]` | Break / hook | Values read there `[O]/[D]` |
|---|---|---|---|
| U1-SEL | `FUN_00856530` @0x856530: `80 bb 84 01 00 00 00 / 0f 84 fd 02 00 00 / a1 b8 c6 8f 00 / 80 38 00` | HW exec break 0x856530 + 0x856846 (BUILTIN/fixed merge) + 0x8565d2 (custom call) + 0x856897 (built-in binder call) | `C+0x184` byte; `C+0xf0` object; `C+0x190` byte; global `[0x8fc6b8]` byte; `FUN_00855fe8` globals `0x8fcdb0/0x8fbd28/0x8fc748`; `FUN_0085600c(C)` result; `P=C+0x50` handle; `C+0x54` byte |
| U1-COMP | `FUN_00855b38` @0x855b38; `FUN_00854ac0`/`FUN_008551d8` (`ev_5dc9…`/`ev_ce22…`); `FUN_004c0c9c` (shader-source), `FUN_004c0eb4` (link check) | Exec break 0x855b38 entry/exit; hook `glShaderSource` + `glGetUniformLocation` (`FUN_004c0f3c`) | Full VP+FP source text; presence test: `hmapTex` ⇒ DEV file pair, `alphaDepth`/`deepColor` ⇒ BUILTIN embedded pair; program handle stored at `C+0x50`; link status |
| U1-INIT | `FUN_00851bdc` @0x851bdc (`ev_67a5…`); `FUN_00852f5c` @0x852f5c (`ev_513e…`); `FUN_00856080` (`ev_5aae…`) | Exec break 0x851bdc entry (log `param_2` layer ptr: 0 ⇒ ctor path, nonzero ⇒ copy path); break 0x852f5c exit | `C+0x184=layer+0x90`, `+0x188=+0x94`, `+0x191=+0x9c`, `+0x190=+0xb8`, `+0x1a8=+0xb4`; `C+0x68..+0xc4` scalars; `C+0xc4` Speed; `water.lib` shipped `CustomEnable=False` ⇒ expect `C+0x184=0` |
| U12-BIND | `FUN_00854054` bit 7c.01 (`ev_ab75…`+`ev_bbdb…`); `FUN_00856530` reflection gate (`FUN_00855fe0()` + `C+0x4c` valid) | Exec break at 7c.01 row; hook `glUniform1i` on `reflectionMap` location + `glActiveTexture`/`glBindTexture` | Int pushed `C+0xf8` (unit `u`); `glActiveTexture(GL_TEXTURE0+u)` + `glBindTexture(target,name)`; texture object `C+0x4c`, GL id `[C+0x4c+8]` |
| U12-PROV | FBO names `ev_c380…`: `glGenFramebuffersEXT` 0x4b98d0, `glBindFramebufferEXT` 0x4b98a0, `glFramebufferTexture2DEXT` 0x4b9920, `glCheckFramebufferStatusEXT` 0x4b98e8, `glGenerateMipmapEXT` 0x4b99a4 (core/ARB 0x4b7080–0x4b7218); `glCopyTexImage2D` thunk 0x4afb3c (import 0x907d7c), call 0x4ed44c in `FUN_004ed38c` (`ev_8096…`) | API trace whole frame: all FBO calls w/ texture-name args; all `glCopyTexImage2D/SubImage2D` w/ dst name + src rect (hits 0x581444/0x582b56/0x5db443/0x81e66d noted); all `glTexImage2D` uploads w/ name/size; `wglMakeCurrent/wglCreatePbufferARB/wglChoosePixelFormatARB/wglBindTexImageARB` sweep | Provenance test (§5): bound reflection `name` seen as FBO attachment ⇒ (b); as copy dst after main scene ⇒ (a); only as upload ⇒ (c) |
| U12-MAT | `FUN_0085756c` (`ev_2b51…`) via `FUN_004cdd9c(…,0x60,…)` + `FUN_004cdbdc`; `FUN_0085787c` (`ev_0348…`) | Exec break 5756c entry/exit + 4cdd9c/4cdbdc; dump 4×4 at caller `+0x60`; `glViewport/glScissor` + `GL_FRAMEBUFFER_BINDING` before/after | Numeric projective matrix + viewport; level-camera vs pitched-camera pair |
| U6-MESH | `FUN_00826b30` (`ev_0510…`): `glBegin(4)`=TRIANGLES → `vtable+0x98(group,caller,1,1)` → `glEnd`; mesh cache `ev_74d8…/ev_f2c0…/ev_31d8…` | Exec break on virtual `+0x98` for one 2×2 field; API trace `glVertexPointer/glTexCoordPointer/glVertexAttribPointer/glDrawElements/glDrawArrays/glGetIntegerv(GL_CULL_FACE/GL_FRONT_FACE)` | Attr array `MultiTexCoord0` (4 verts float32); index array (6 indices) or draw first/count; `hmapW/H` uniforms same frame; cull/front state |
| U3-NUM | `FUN_008520a8` (`ev_ada1…`); binder gate 0x854250 (`C+0xe0 != 0 && [C+0xe0+8] != 0`); rows 7e.10–7f.1 | Exec break at each hmap row push | `C+0xd0` (W), `C+0xd4` (H) ints; `C+0xe4` (Min), `C+0xe8` (Max) floats; gate `C+0xe0`, `[C+0xe0+8]`; chain `h=FUN_00739bf8(layer)`, `C+0xe0=FUN_0082f86c(*(h+0x200))`, Min/Max via `FUN_0082f060/0082f114` on `+0x200` object |
| U3-TEX | Same + unit `C+0xdc` (ctor 2, `ev_5aae…`), target `C+0xd8` (ctor `0xde1`=GL_TEXTURE_2D) | Hook `glActiveTexture(GL_TEXTURE0+C+0xdc)` + `glBindTexture` + `glGetTexLevelParameteriv(name,0,WIDTH/HEIGHT/INTERNAL_FORMAT)` | `(target,name,w,h)` tuple + upload-vs-FBO history of `name` |
| U5-TIME | Binder bit 7c.4 at 0x854091: `fld qword [esi+0xc8]; fmul qword [esi+0xc4]; fstp dword [esp]` → `glUniform1f` (`FUN_004c0fb8`/`0f90` map, `ev_84eb…`) | Hook `glUniform1f` on `time` location ≥3 frames over ≥2 s; if animated, HW write-watchpoint on `C+0xc8` (8 B) | `time_uniform = (float)(double[C+0xc8]*double[C+0xc4])`, `C+0xc4`=Speed=1.0; writer EIP or constant-0 verdict |

GL wrapper map (re-cited `[D]`, `ev_84eb…`): `004c0f90`→`glUniform1f`, `004c0fb8`→`glUniform1i`, `004c0fdc`→`glUniform2f`, `004c102c`→`glUniform3f`, `004c1058`→`glUniformMatrix4fv` (count=1, transpose=0), `004c0f3c`→`glGetUniformLocation`, `004c0f5c`→`glUseProgram`. All extension pointers via `wglGetProcAddress` (import 0x907bbc); name tables `ev_6eec…`/`ev_711e…`/`ev_c380…`.

---

## 3. ONE-session ordered capture plan (do in this order; stop-and-gate marked ★)

Tooling: debugger with HW exec/data breakpoints (x64dbg / WinDbg) + one GPU API tracer (RenderDoc or apitrace or Nsight-GL). Map: donor retail, one water-visible map, default `water.lib` (`CustomEnable=False`, `Speed=1.0`, `HeightMapEnable=True`, `ev_2eb0…`/`ev_227e…`). No donor file is modified. Each phase logs: breakpoint VA, register/memory dump, API-trace event ids, and the sentinel check from §4.

### Phase 0 — session gating (5 min; ★ gate for everything)

1. Launch donor under tracer; load water-visible map; pause.
2. Exec-break `FUN_00603d30` @0x603d30 entry; confirm a water field is added (read `[ebp+0x1c]` per PORT1TO1 §11-U7). If no field fires, the session is invalid — move camera / load a shore map; **captures without a field break do not settle anything**.
3. Start API trace + frame counter. From here every phase records ≥2 water-visible frames + 1 camera move (level → pitched) unless stated otherwise.

### Phase 1 — U1 live shader path (★ gate: all later phases are labelled by this result)

4. Break 0x851bdc entry: record `param_2` (layer ptr). 0 ⇒ ctor path (`FUN_00856080`); nonzero ⇒ `FUN_00852f5c` path. At 0x852f5c exit (or ctor exit) dump `C+0x184/+0x188/+0x190/+0x191/+0x1a8`, `C+0x68..+0xc4`, `C+0x50`, `C+0x54`. Sentinel: shipped config predicts `C+0x184=0` (CUSTOM unreachable) — record actual, do not assume.
5. Break 0x855b38 entry/exit: record `P=C+0x50` program handle actually compiled; confirm link-check `FUN_004c0eb4` passed (no `FUN_004b03b8` error).
6. Break 0x856530: single-step the two-flag test; record `C+0x184` byte, `[0x8fc6b8]` byte, `FUN_00855fe8` globals (`0x8fcdb0/0x8fbd28/0x8fc748`), and which arm executes: CUSTOM (inline/`+0x188/+0xf0`, vtable `+0x3c`, binder iff `C+0x190!=0`) vs BUILTIN (binder at 0x856897) vs FIXED (0x856846 legacy). Record `C+0xf0`/`C+0x190` at the CUSTOM arm if taken.
7. Hook `glShaderSource`: dump both attached source texts verbatim. **Path label rule:** `hmapTex` present ⇒ DEV file pair (`water.dev.vert/frag`); `alphaDepth`+`deepColor` and no `hmapTex` ⇒ BUILTIN embedded pair (`ev_5dc9…`/`ev_ce22…`); neither ⇒ FIXED. Hook `glGetUniformLocation` to log the program handle + all 30 key strings actually queried (expect mask `0x3FFFFFFF` set, `ev_41a90…`).
8. ★ **U1 verdict before proceeding:** write down `PATH ∈ {DEV, BUILTIN, FIXED}` + `C+0x184/[0x8fc6b8]/P` + program handle. Every Phase 2–4 dump is tagged with this PATH; a dump on the wrong path settles nothing.

### Phase 2 — U12 reflection provenance + unit + matrix (★ gate for water draw)

9. With PATH known and a field visible, break `FUN_00856530` reflection gate + binder bit 7c.01. Hook `glUniform1i(reflectionMap)` → record unit `u = C+0xf8`; trace `glActiveTexture(GL_TEXTURE0+u)` + `glBindTexture(target,name)` → record `(target,name)`. Record texture object `C+0x4c` and id `[C+0x4c+8]`; they must agree with `name` or the mismatch itself is the finding.
10. In the same frame trace: (a) every `glGen/Bind/FramebufferTexture2D/CheckStatusEXT` with texture-name args; (b) every `glCopyTexImage2D` (thunk 0x4afb3c / call 0x4ed44c) and `glCopyTexSubImage2D` (0x581444/0x582b56/0x5db443/0x81e66d family) with dst name + src rect; (c) every `glTexImage2D` upload with `(name,w,h,source)` incl. any `DiffuseWaves0/2` string → upload edge; (d) `glGetIntegerv(GL_FRAMEBUFFER_BINDING)` at the bind; (e) `wglMakeCurrent/wglCreatePbufferARB/wglChoosePixelFormatARB/wglBindTexImageARB` sweep. **Provenance decision:** `name` seen as FBO attachment earlier in frame ⇒ (b) separate pass; as copy dst after main scene before water ⇒ (a) framebuffer copy; only as upload, never FBO/copy dst ⇒ (c) static.
11. At the same break record `glGetTexLevelParameteriv(name,0,{WIDTH,HEIGHT,INTERNAL_FORMAT})`, `GL_GENERATE_MIPMAP` / `glGenerateMipmapEXT` on `name`, `MIN/MAG_FILTER`, `WRAP_S/T`. This is U12-B.
12. Break `FUN_0085756c` entry/exit + `FUN_004cdd9c`/`FUN_004cdbdc`; dump the 4×4 at caller `+0x60` and `glViewport/glScissor` + FBO binding immediately before/after. Repeat level-camera and pitched-camera. If the matrix is also uploaded as a uniform, hook `glUniformMatrix4fv` and cross-check. This is U12-T.
13. Opportunistic U12-S: correlate `name` against any `DiffuseWaves0/2` upload name — identical ⇒ single texture (record one name); distinct ⇒ keep separate samplers.
14. ★ **U12 verdict:** `(provenance_class ∈ {a,b,c}, target, name, w, h, unit u, matrix M, viewport)` with the §5 zero-mismatch rule, else U12 stays `[U]` and the port keeps refusing water.

### Phase 3 — U6 grid UV / winding (needs the Phase-2-bound draw; inert under BUILTIN hmap but still recorded)

15. Break virtual `+0x98` from `FUN_00826b30` for one 2×2 field. Dump: bound `GL_TEXTURE_COORD_ARRAY` / `glVertexAttribPointer(0)` `MultiTexCoord0` array (all verts, float32); element/index array (6 indices) or `glDrawArrays` first/count; `glGetIntegerv(GL_CULL_FACE / GL_FRONT_FACE)` + `glFrontFace/glCullFace` trace; `glUniform1i hmapW/H` from the same frame.
16. Compute `uv_pred = attr/(W,H) − 0.5` per vertex (donor-verbatim `-0.5`, `water.dev.vert:14`); read back VS `gl_TexCoord[1].xy`. Compare index order element-wise vs port `0,3,1 / 1,3,2` (`water3d.gd:475-480`) and `render_mode` vs `cull_disabled` (`water3d.gdshader:37`). Record diagonal + CW/CCW explicitly. Note the two trailing `1,1` args `(group,caller,1,1)` as observed integers with no assigned meaning.
17. ★ **U6 verdict** per §5 (bit-exact UV, index-exact winding across ≥2 fields), else U6 stays `[U]`.

### Phase 4 — U3 hmap numerics + texture identity

18. Break binder rows 7e.10–7f.1 with a field visible. Record `C+0xd0` (hmapW), `C+0xd4` (hmapH), `C+0xe4` (hmapMin), `C+0xe8` (hmapMax), gate `C+0xe0` / `[C+0xe0+8]`, unit `C+0xdc`, target `C+0xd8`. Walk one level: `h=FUN_00739bf8(layer)`, `C+0xe0=FUN_0082f86c(*(h+0x200))`, Min/Max getters `FUN_0082f060/0082f114` on `+0x200` — record each pointer so the chain is re-derivable.
19. Same frame: `glActiveTexture(GL_TEXTURE0+C+0xdc)` + `glBindTexture(target,name)` + `glGetTexLevelParameteriv(name,0,{WIDTH,HEIGHT,INTERNAL_FORMAT})`; classify `name` as FBO attachment vs copy dst vs upload exactly as Phase 2.
20. ★ **U3 verdict** per §5 (identical 4-tuple numerics + identical `(target,name,w,h)` across ≥2 frames + camera move), else U3 stays `[U]`.

### Phase 5 — U5 time + U4* construction path (sampled throughout; 5 min)

21. Hook `glUniform1f(time)` (program from Phase 1) across ≥3 frames spanning ≥2 s; log floats. If non-constant, set HW write-watchpoint on `C+0xc8` (8 B) and record firing EIP + disassembly → nearest symbol. If constant `0.0` and watchpoint never fires over a 10 s water-visible window, verdict is `time=0`-by-capture. Verify formula `float(double[+0xc8]*double[+0xc4])` reproduces the uniform with 0 ULP error; `C+0xc4` must read `1.0` (Speed).
22. U4*: the Phase-1 0x851bdc `param_2` + `C+0x88..+0xc4` dump already distinguishes ctor defaults (`0.4/0.3/4/.1/.5/1/.05/2/.01/.4/.825`, `+0xc4=1.0`, `ev_5aae…`) from `water.lib` layer values (`1/1/1/1/1/0/0/1/1/0.1/0.01`, `ev_513e…`). No extra break needed.

Session close: export tracer frame(s) + breakpoint log + all dumps with PATH label and camera pose. Total: one launch, one map, one tracer file.

---

## 4. Sentinel values (expected donor-literals; record actual — never force)

| Sentinel | Donor-literal `[O]/[D]` | Meaning if different |
|---|---|---|
| `C+0x184 == 0` | `CustomEnable=False` (`water.lib`, `ev_2eb0…`) + ctor `+0x184=0` (`ev_5aae…`) | Nonzero + `[0x8fc6b8]!=0` ⇒ CUSTOM path is live; U1 verdict flips to DEV (re-label all later dumps) |
| `[0x8fc6b8]`, `0x8fcdb0/0x8fbd28/0x8fc748`, `C+0x54` | Selector inputs (`ev_8218…`, `ev_30ba…`) | Any zero ⇒ FIXED arm; explains missing uniforms |
| `P=C+0x50` nonzero + link OK | `FUN_00855b38` compiled embedded pair (`ev_a66a…`) | Zero/link-fail ⇒ no BUILTIN program exists; water cannot draw on BUILTIN |
| Mask `C+0x7c..+0x7f == 0x3FFFFFFF` | Default all-30-on (`ev_41a90…`, `ev_ab75…`) | Missing bits ⇒ corresponding uniforms never bound; record which |
| `C+0xc4 == 1.0` (double) | `Speed=1.0` (`ev_513e…`/`ev_227e…`) | Other ⇒ time scale differs; U5 formula still holds, factor changes |
| `C+0xc8..+0xcf == 0` at construction | Ctor zeroes (`ev_5aae…`) | Nonzero at first draw ⇒ writer ran before first bind; catch it earlier |
| `C+0xf8 / +0xfc / +0xdc` units | Reflection/wave/hmap sampler units (ctor `+0xfc=1`, `+0xdc=2`; `+0xf8` engine) | Any assumed `0/1/2` alias without this read is forbidden (§7) |
| `C+0xd8 == 0xde1` | `GL_TEXTURE_2D` ctor default (`ev_5aae…`/`ev_ada1…`) | Other target (e.g. rectangle) changes the port sampler type |
| `C+0xe0==0` or `[C+0xe0+8]==0` | Hmap gate closed ⇒ hmap* not bound (0x854250) | Numerics/texture dumps from such a frame are void for U3 |
| `C+0xec==0` | Shadow gate closed ⇒ `cameraModel` + shadow uniforms not bound (0x8542d2) | `cameraModel` matrix read from such a frame is void; it is NOT a reflection matrix in any case |

---

## 5. Termination criteria (zero mismatch — every item; no partial credit)

General rule: a `[U]` retires **iff** the stated tuple is identical with **0 differing bits/elements** across **≥2 water-visible frames + 1 camera move** (level → pitched), all tagged with the same Phase-1 PATH. Any mismatch, missing dump, or PATH mixing ⇒ item stays `[U]` and the corresponding port hard-fail stays. "Close" never counts.

| Item | Tuple that must repeat with zero mismatch | Minimum sample |
|---|---|---|
| U1 | `(PATH, C+0x184, [0x8fc6b8], P handle, VP/FP source hash)` — plus arm taken at 0x856530 | 2 draws + camera move; source text hash identical |
| U12-A | `(provenance_class ∈ {a,b,c}, target, gl_name)` — decision procedure in §3 step 10 | 2 frames + camera move; FBO/copy/upload classification unanimous |
| U12-B/C | `(w, h, internal_format, min/mag_filter, wrap_s/t, mip_state, unit u, C+0x4c/[C+0x4c+8]↔name agreement)` | 2 frames + camera move |
| U12-T | `(4×4 at caller+0x60, viewport/scissor rect, FBO binding)` — level vs pitched recorded separately, each pair self-identical | 2 frames per pose + pose change |
| U12-S | `(reflection_name == waves_upload_name ? 1 : 0)` | 1 frame with upload list; confirm across 2nd frame |
| U6-UV | `max\|attr/(W,H)−0.5 − VS_TexCoord1.xy\| == 0.0` bit-exact float32, all verts | ≥2 fields + camera move |
| U6-WIND | index sequence 0-differing elements vs recorded donor order + identical `(CULL_FACE, FRONT_FACE)` | ≥2 fields + ≥2 frames |
| U3-NUM | `(hmapW bits, hmapH bits, hmapMin bits, hmapMax bits, C+0xe0/[C+0xe0+8])` 0-differing | 2 frames + camera move |
| U3-TEX | `(target, name, w, h)` 0-differing + unanimous provenance class | 2 frames |
| U5 | (a) constant: all `time` samples `0.0`, watchpoint silent 10 s; or (b) animated: one writer EIP every frame, 0 missed frames, formula reproduces uniform 0 ULP | (a) 10 s window / (b) ≥3 frames over ≥2 s |
| U4* | `(param_2 == 0 ?, C+0x88..+0xc4)` matches exactly one of {ctor defaults, layer values} | 1 construction + 1 draw |

---

## 6. Outcome → port-change matrix (owner applies; NO edits made here)

Each row fires **only** on its zero-mismatch capture. Until then the current hard-fail / labelled scaffolding stays.

| Capture outcome | Exact port change (file/line intent) |
|---|---|
| U1 = BUILTIN | Keep `water3d.gd:163` (`DEFAULT_WATER_SHADER_PATH = BUILTIN`) + `water3d.gdshader:102` (`=1`) as `[D]`; keep DEV/LEGACY variants selectable donor-literal but unreachable by default; record `(P, source hash)` in telemetry; proceed to bind U12/U3/U6 under BUILTIN |
| U1 = DEV | Flip default to DEV **only with** the captured `(P, hmapTex-present source hash)` id; wire `hmapW/H/Min/Max + hmapTex + cameraModel(textureMatrix[3]·cameraModel·modelView)` per `water.dev.vert:14-17`; U3/U6 become draw-load-bearing (BUILTIN `texScaleS/T` path retired) |
| U1 = FIXED | Retire both shader variants; implement legacy `glMatrixMode/glLight` path only; U3/U12 rows marked N/A with reason (no custom uniforms bound) |
| U12 = (b) FBO pass | After `bind_height_grid` success in `_make_water3d` (`world3d_terrain.gd:1099`), call `bind_reflection_map(<captured-provenance Texture2D>)` importing the captured FBO colour attachment at captured `(w,h)` + `bind` captured unit `u` + matrix path from U12-T; extend `_finalize_water_node` (`water3d.gd:520-527`) to require texture+unit+matrix; replace `water3d.gdshader:290-293,362-378` screen-`gl_FragCoord` scaffolding with projective path |
| U12 = (a) copy | Same wiring, but the Texture2D wraps the captured copy-dst target updated after the main scene each frame (Godot `ViewportTexture`-equivalent fed from the captured src rect); record copy rect + pre/post FBO binding |
| U12 = (c) static | Bind the captured uploaded texture by captured `(name→art file, w, h, unit)`; U12-S decides whether it shares the `DiffuseWaves` sampler or is its own sampler; no per-frame refresh code |
| U6-UV dividend = grid 0..1 / pixels / world XZ | Set `water3d.gd:432-438/466-480` dividend domain to captured domain with verbatim `/ (hmapW,hmapH) − 0.5`; keep divisor = captured U3-NUM `W/H`, never `map_size` |
| U6-WIND order + cull | Set `water3d.gd:475-480` indices to captured 6-element order; set `water3d.gdshader:37` `render_mode` to captured `(cull_disabled / cull_back + front_winding)`; record diagonal explicitly |
| U3-NUM | Replace `map_size/±2.96` (`water3d.gd:489-511`, `water3d.gdshader:77,126-129,168-171`) with captured `(W,H,Min,Max)` as required explicit params; delete the `map_size/128` divisor basis note |
| U3-TEX | Replace decoded-grid `height_tex`/`hmapTex` alias with captured `(target,name)` import (FBO/copy/static per class); LEGACY-only alias retired unless U1=DEV/LEGACY |
| U5 = animated / frozen | Replace `_time += delta` (`water3d.gd:229/250-251`) with captured writer (or freeze `0.0`); keep `time = float(double[+0xc8]*double[+0xc4])` in comment + `time` uniform name (`water3d.gdshader:78,177,248`) |
| U4* = ctor / layer | Pin scalar table to the observed construction path (§5.1 `ev_ab75…` rows: `+0x88..+0xc4`); assert it in `t_water.gd` instead of supporting both silently |

---

## 7. Hard-fail matrix — observations that may NEVER be substituted by guess

Any cell marked ✗ means: observing the left-column gap does **not** license the top-row invention. Port must `push_error` + skip the water node (current `water3d.gd:520-527` + `water3d.gdshader:365-366` behaviour). No neutral texture, no invented matrix/UV/FBO.

| Gap observed → / Forbidden substitute ↓ | U1 path unknown | U12 provenance unknown | U12 size/unit/matrix unknown | U6 UV dividend unknown | U6 winding/cull unknown | U3 numbers/texture unknown | U5 writer unknown |
|---|---|---|---|---|---|---|---|
| Assume BUILTIN (or DEV/LEGACY) as default beyond the labelled `[D]` default | ✗ | — | — | — | — | — | — |
| Neutral/grey/generated 1×1 texture as `reflectionMap` or `hmapTex` | — | ✗ | ✗ | — | — | ✗ | — |
| `diffusewaves0/2` or `heightmapwaves0.tga` art aliased to `reflectionMap`/`hmapTex` | — | ✗ | — | — | — | ✗ | — |
| Viewport-sized FBO / `get_viewport()` heuristic target | — | ✗ | ✗ | — | — | — | — |
| `*0.5+0.5` screen-UV bias or invented mirror matrix | — | ✗ | ✗ | — | — | — | — |
| Assumed sampler unit (0/1/2) without the `C+0xf8`/`C+0xdc` hook read | — | ✗ | ✗ | — | — | ✗ | — |
| `fract(world*0.5)` / `(x+0.5)/w` / grid-derived dividend | — | — | — | ✗ | — | — | — |
| `map_size/128`, `map_size.x/y`, `±2.96` / `±MAX_HEIGHT` span | — | — | — | ✗ | — | ✗ | — |
| Invented index order / diagonal / `cull_disabled` presented as donor | — | — | — | — | ✗ | — | — |
| `cameraModel` (custom-object `C+0xf0→+0xc0→+0x24`, shadow-gated 0x8542d2) reused as reflection matrix | — | ✗ | ✗ | — | — | — | — |
| `_time += delta` / wall-clock / frame-count presented as donor time | — | — | — | — | — | — | ✗ |
| `water_surface_y=-0.25`, `#6E99A8` legacy colour, `water_cell` alpha gate as "close enough" | ✗ | ✗ | — | — | — | ✗ | — |
| Calling `bind_reflection_map()` with any non-captured texture "to make water appear" | — | ✗ | ✗ | — | — | — | — |

Telemetry rule: keep `visual_parity_claim=false`; each retired sub-item flips to `[D]+capture-id` with its tuple; everything else stays `[U]` with the phase/step that would settle it.

---

## 8. Explicit non-claims and file discipline

- **No parity claim.** No donor binary executed, no GPU frame captured, no port capture compared by this worker. All donor readings are re-cited `[O]/[D]`; all unsettled values are `[U]` with §3 experiments and §5 gates.
- **No approximation substituted.** No path, texture, size, unit, matrix, viewport, UV dividend, winding order, cull state, hmap number, or time source is supplied in this report. The port's current behaviour (BUILTIN labelled default + hard-fail without a real reflection target + labelled `[U3]/[U5]/[U6]` substitutes) is endorsed as the donor-faithful behaviour until the corresponding zero-mismatch capture lands.
- **Read-only compliance.** Exactly one repo file written: `docs/terrain_swarm_2026-11-26/reports/DEC_U_water_capture.md`. No code/shader/asset/config/Godot/git change. No donor file opened for write or executed. No other worker target touched. All VAs/evidence ids re-cited pinned `t_87f0f3c130b0`, each within its ≤5-pass budget (§1).

*End of DEC-U-WATER-CAPTURE.*
