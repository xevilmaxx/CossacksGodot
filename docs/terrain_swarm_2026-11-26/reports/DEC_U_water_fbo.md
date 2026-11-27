---
id: DEC-U-WATER-FBO
worker: DEC-U-WATER-FBO (subagent in full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
ticket: "Statically recover reflection texture provenance; no invented texture or matrix"
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
labels: [O, D, I, U]
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. No donor binary executed, copied or committed. No donor file written."
scope_guard: "No repo code/asset/config/shader/Godot/git change. Exactly one repo file written: this report."
multi_pass: true
visual_parity_claim: false
upstream: "DEC_U_water_runtime.md §§8/9/10 (U12); PORT1TO1_water_shore.md §§4/7/11; variant3d/scripts/water3d.gd; variant3d/scripts/world3d_terrain.gd"
---

# DEC-U-WATER-FBO — reflection texture provenance (static, read-only)

## 0. Authority and discipline (read first)

Every statement below is `[O]` (verbatim bytes/text/decompiled instruction or verbatim port file line), `[D]` (deterministic control-flow/arithmetic from `[O]`), `[I]` (interpretation) or `[U]` (UNVERIFIED — a concrete settling experiment with hard-fail conditions is given in §8; the port must **hard-fail, never substitute a texture or matrix**). This worker issued **no Craft Anything native calls** (only repo/doc reads via default tools in this subagent context); all donor addresses/evidence ids below are **re-cited pinned records** from `DEC_U_water_runtime.md` / `PORT1TO1_water_shore.md`, each pinned `document:"t_87f0f3c130b0"`, Deep mode (Ghidra 12.2 + built-in 0.6.1 engine). No donor binary was executed, no GPU frame was captured by this worker, and no parity claim is made. Active donor target was never opened/selected/closed by this worker. Donor helper scripts were not written or run by this worker.

`[D]` The single load-bearing port fact is confirmed by repo read: `variant3d/scripts/water3d.gd:343-353` defines `bind_reflection_map(tex)` which refuses null, and `variant3d/scripts/water3d.gd:520-527` hard-fails BUILTIN water draw when `_reflection_map == null`; `variant3d/scripts/world3d_terrain.gd:1089-1106` (`_make_water3d`) calls `build(w,h)` + `bind_height_grid(...)` but **never calls `bind_reflection_map()`** — therefore `[D]` no water renders on the BUILTIN path by construction. This report tells the owner exactly what donor-faithful wiring is allowed (real FBO texture + real projective matrix only) without inventing either.

---

## 1. Pass ledger (owner rule ≤5 passes/function; every pass logged)

This ticket performed **document/byte-record re-analysis passes only** (no new native lifts). Each pass re-reads one cited record and checks reachability to the water draw callback. No function exceeded 5 prior + current passes.

| # | Question / function | Passes this ticket | Result |
|---|---|---|---|
| R1 | Water draw callback `FUN_00603d30` @0x603d30 reachability to reflection | 1 re-read: Deep pseudo `ev_626574ae222dec3a4ca1b6e81a55874c24cae0e2c0aae4b613d3f350d514f86a` + disassembly record (§33 PORT1TO1_water_shore) + DEC_U_water_runtime §7 | **Accepted**: constructs/centres field, writes Y; no per-vertex data; no reflection/FBO call inside |
| R2 | Shader sampler binder `FUN_00854054` @0x854054 bitmask | 1 re-read: Deep pseudo `ev_ab751f818e4b8839b359f3da00152283cfd960776db078f970aed7cea91b0641` + raw bytes 0x854080–0x8542f0 `ev_bbdba234fcbb85df996f0f2e5ed4b1df1aaa00f02c95c3861160cc201851db7a` + mask-float record `ev_41a9076a…` | **Accepted, decisive**: 30-key bitmask `0x3FFFFFFF`; reflectionMap = bit 7c.01, unit `C+0xf8` |
| R3 | Generic copy path `FUN_004ed38c` @0x4ed38c + `glCopyTexImage2D` thunk | 1 re-read: Deep pseudo `ev_8096d5d90140786d5b7e0196e1a996a52c8c964d828c825902a879a8264e5cd7` + thunk scan `ev_257c8a429a8bd195d6e14eb934118c4933e48f3bdacbd1a25717aff7fceb95f5` (thunk 0x4afb3c, import 0x907d7c, call at 0x4ed44c) | **Accepted**: only `glCopyTexImage2D` in binary; generic texture-image loader, **not water-specific** |
| R4 | Reflection matrix/state `FUN_0085756c` / `FUN_0085787c` + builders `FUN_004cdd9c` / `FUN_004cdbdc` | 1 re-read: Deep pseudos `ev_2b512f029199e31de846bb803fa47db8e45e1c64a0757b792b2a58512a19eb49` (`5756c`) + `ev_0348…` (`5787c`) + caller scan in DEC_U §8/P12 | **Accepted as localized**: texture object `C+0x4c` (GL id at `+8`); matrix via `FUN_004cdd9c(...,0x60,...)` + `FUN_004cdbdc`; no viewport literal recovered |
| R5 | FBO/pbuffer/wgl surface name tables + `FUN_00855b38`/`FUN_00856530` creation search | 1 re-read: CODE name-table scans `ev_c380af4afa1f8d45c00409005eb167c5abde0a1dc989495d481d2f01b71ef0c2` (32 `Framebuffer` hits incl. `glGenFramebuffersEXT` 0x4b98d0, `glBindFramebufferEXT` 0x4b98a0, `glFramebufferTexture2DEXT` 0x4b9920, `glCheckFramebufferStatusEXT` 0x4b98e8, `glGenerateMipmapEXT` 0x4b99a4) + `ev_6eec1ce1633753bbf5d98a4a018c32ef3244689a7372b45ea284169ff84db2be` + import searches (0 FBO imports) | **Partial → `[U]`**: extension **names** proven present; **no water-specific FBO creation call** recovered |

No `wglMakeCurrent` / pbuffer (`wglCreatePbufferARB`, `wglChoosePixelFormatARB`) water call site was cited in any prior record; a name-table search for those spellings returned no water-anchored hit in the records re-read this ticket → `[U]`, see §5/§8.

---

## 2. Evidence register (all pinned `t_87f0f3c130b0`; re-cited, not re-lifted)

| Evidence id | Source (prior ticket) | Establishes (re-verified by re-read) |
|---|---|---|
| `ev_626574ae222dec3a4ca1b6e81a55874c24cae0e2c0aae4b613d3f350d514f86a` | Deep pseudo + disasm `FUN_00603d30` | `WaterFieldAdd` impl; 35 insns; field/Y/bounds calls; no UV/FBO writer |
| `ev_c987ab1b4f4baee2d99fe7c877a719d0194ca4f1f803e3605b32547f7dcef8d4` | `native_bytes_show(0x601660)` | DScript registration table; `WaterFieldAdd → FUN_00603d30` |
| `ev_ab751f818e4b8839b359f3da00152283cfd960776db078f970aed7cea91b0641` | Deep pseudo `FUN_00854054` | 30-key bitmask binder; per-bit sampler/value sources |
| `ev_bbdba234fcbb85df996f0f2e5ed4e511851db7` (prefix `ev_bbdb…`) | `native_bytes_show(0x854080,624)` | Value pushes at each binder call (`ff b6 <off>`, `lea` vectors); `C+0xec` shadow gate at 0x8542d2 |
| `ev_16a55d5469092dc3a559478db683fcb8481d4f6c2a3da573d2b10f2843ec581a` | Deep pseudo `FUN_00854054` (PORT1TO1) | 30 uniform keys bound per bit of `+0x7c..+0x7f` |
| `ev_41a9076a…` (cited PORT1TO1 §4.2) | float-bits at 0x853eb8 | Mask default `0x3FFFFFFF` (f32 `1.99999988`); bits 30–31 keyless |
| `ev_8218b0f1aa21aefba779cac21107bff799438a4c52459533477079bebcbc8642` | Deep pseudo `FUN_00856530` | 3-way selector; binder called at 0x856897 (built-in) and 0x8565d2 (custom); reflection bind gated on `FUN_00855fe0()` + `C+0x4c` valid |
| `ev_2b512f029199e31de846bb803fa47db8e45e1c64a0757b792b2a58512a19eb49` | Deep pseudo `FUN_0085756c` | Reflection texture matrix via `FUN_004cdd9c(FBO/caller+0x4c,…,0x60,…)` + `FUN_004cdbdc` |
| `ev_c380af4afa1f8d45c00409005eb167c5abde0a1dc989495d481d2f01b71ef0c2` | `native_bytes_find("Framebuffer")` | 32 CODE hits; EXT + core/ARB spellings 0x4b7080–0x4b7218, 0x4b98xx–0x4b99xx; **names only** |
| `ev_6eec1ce1633753bbf5d98a4a018c32ef3244689a7372b45ea284169ff84db2be` | `native_bytes_show(0x4b5140,96)` | CODE-resident GL 2.0 name table (`glAttachShader…glUniform*…`); dispatch via `wglGetProcAddress` (import 0x907bbc) |
| `ev_257c8a429a8bd195d6e14eb934118c4933e48f3bdacbd1a25717aff7fceb95f5` | thunk scan `ff 25 7c 7d 90 00` | `glCopyTexImage2D@thunk` 0x4afb3c (import 0x907d7c) |
| `ev_8096d5d90140786d5b7e0196e1a996a52c8c964d828c825902a879a8264e5cd7` | Deep pseudo `FUN_004ed38c` | Generic texture-image loader; one `glCopyTexImage2D` branch at **0x4ed44c**; not water-specific |
| `ev_711e2a981266b3cb2edb487ce33b08fbd32826dffd3ac4b28ff70d8dd0da6673` | `native_bytes_find("glUniform")` | 82 CODE hits `glUniform1f/2f/3f/4f/1i/…/Matrix4fv` 0x4b5388–0x4b5490 |
| `ev_84eb83bef1d668abb4da268019246e5e45def6585098b0785f8f328cbd993114` | `native_bytes_show(0x4c0f90,384)` | GL wrapper arg counts → `glUniform1f/1i/2f/3f/Matrix4fv` mapping |

`[D]` No evidence id in the re-read corpus anchors an FBO-create, `glCopyTexImage2D`, pbuffer, or `wglMakeCurrent` call **inside** `FUN_00603d30`, `FUN_00854054`, `FUN_00856530`, `FUN_0085756c`/`FUN_0085787c`, or `FUN_00855b38`. The absence is bounded by the searched records (thunk scan, name-table scan, caller scans), not a whole-binary proof.

---

## 3. Water draw callback `FUN_00603d30` — what is and is not in it `[O]/[D]`

- `[O]` `FUN_00603d30` @0x603d30 is the DScript `WaterFieldAdd` implementation (registration record `ev_c987…`, 35-insn disassembly + Deep pseudo `ev_626574ae…`).
- `[O]` It constructs/centres the field record and writes Y=`offsety` (verbatim `[ebp+0x1c]` → field `+0x20` path per PORT1TO1 §7.2); per-vertex UV/winding live downstream in the generic mesh-renderer vtable `+0x98` called from `FUN_00826b30` (`ev_0510…`), not here.
- `[D]` Re-read of its pseudo/disassembly shows **no call** to `FUN_004ed38c`, to the `glCopyTexImage2D` thunk at 0x4afb3c, to any `glGen/BindFramebuffer*` spelling, or to `FUN_0085756c`/`FUN_0085787c`. Call sites of the binder `FUN_00854054` are **only** 0x8565d2 and 0x856897 inside `FUN_00856530` (PORT1TO1 §4.2), i.e. binding happens in the shader-setup path, not in the field-add callback.
- `[D]` Therefore the reflection texture is **not populated by the field-add callback**. Its provenance must be decided between (§7): (a) framebuffer copy at draw time, (b) a separate reflection render pass writing an engine texture, or (c) a static texture — see verdict.

---

## 4. Shader sampler bindings `FUN_00854054` — exact reflection rows `[O]/[D]`

Mask: bytes `C+0x7c..+0x7f` = 32-bit uniform-enable bitmask, default `0x3FFFFFFF` (all 30 lower bits set; bits 30–31 keyless) `[O]` (`ev_41a9076a…`, `ev_ab75…`, `ev_bbdb…`).

| bit | uniform key | GL wrapper `[D]` (§3 DEC_U_water_runtime) | Value pushed by caller `[O]` | Gate `[O]` |
|---|---|---|---|---|
| 7c.01 | `reflectionMap` | `1i` (`FUN_004c0fb8`, ptr `0x8fcb0c`) | `mov ecx,[C+0xf8]` — sampler **unit**, not a texture id | Bound in `FUN_00856530` only when `FUN_00855fe0()` true **and** `C+0x4c` (reflection texture object) valid (`ev_8218…`) |
| 7c.02 | `waveMap` | `1i` | `mov ecx,[C+0xfc]` (ctor default 1) | always when bit set |
| 7e.02/7e.04 | `waveDir0/1` | `2f` | `lea ecx,[C+0xb4]/[C+0xbc]` | always when bit set |

- `[O]` Water reflection uses engine texture object at `C+0x4c`, GL texture id at `C+0x4c+8`, projected by the matrix built in `FUN_0085756c` (see §6); sampler unit comes from `C+0xf8` (custom reflection matrix unit `C+0x1a8 ← layer+0xb4` in `FUN_00852f5c`, `ev_513e…`).
- `[O]` `cameraModel` (bit 7f.20) is `Mat4fv` from the **custom-shader object** `C+0xf0 → +0xc0 → +0x24`, bound **inside the `C+0xec != 0` shadow-object gate** (bytes at 0x8542d2) — corrected in DEC_U_water_runtime §5.1; it is not a reflection matrix and must not be reused as one.
- `[D]` The binder proves the reflection **binding mechanism** (int unit + pre-bound texture object) but **not the texture's provenance, dimensions, or viewport transform** — those are `[U]` (§8).

---

## 5. FBO / pbuffer / `wglMakeCurrent` / `glCopyTexImage2D` call-site search `[O]/[D]/[U]`

- `[O]` FBO API **names** are CODE-resident: `glGenFramebuffersEXT` 0x4b98d0, `glBindFramebufferEXT` 0x4b98a0, `glFramebufferTexture2DEXT` 0x4b9920, `glCheckFramebufferStatusEXT` 0x4b98e8, `glGenerateMipmapEXT` 0x4b99a4 (`ev_c380…`); core/ARB spellings 0x4b7080–0x4b7218. There are **zero direct FBO imports** — all resolved via `wglGetProcAddress` (import 0x907bbc) like the uniform wrappers.
- `[O]` The **only** `glCopyTexImage2D` call in the binary is the branch at **0x4ed44c** inside generic texture-image loader `FUN_004ed38c` (`ev_8096…`, thunk `ev_257c…`). `glCopyTexSubImage2D` hits (0x581444, 0x582b56, 0x5db443, 0x81e66d, …) are generic render-to-texture helpers in the re-read records.
- `[D]` No record re-read this ticket places any of those call sites **reachably inside** the water path (`FUN_00603d30` / `FUN_00855b38` / `FUN_00856530` / `FUN_0085756c` / `FUN_0085787c` / `FUN_00854054`). `FUN_00855b38` only builds the embedded VP/FP pair (`ev_a66a…`); `FUN_0085756c` builds a projective matrix from an **already-existing** texture object at `C+0x4c`.
- `[U]` Whether the engine texture at `C+0x4c` is (a) an FBO attachment, (b) a `glCopyTexImage2D` framebuffer copy, (c) a pbuffer/`wglMakeCurrent` surface copy, or (d) a static uploaded texture (`DiffuseWaves2`?) is **not statically settled**. `wglMakeCurrent`/pbuffer spellings have no water-anchored hit in the re-read corpus. Each hypothesis gets a distinct capture test in §8.

---

## 6. Reflection viewport transform `[O]/[D]/[U]`

- `[O]` `FUN_0085756c` (`ev_2b51…`) builds the reflection projective texture matrix with `FUN_004cdd9c(FBO/caller+0x4c, …, 0x60, …)` followed by `FUN_004cdbdc`; `FUN_0085787c` (`ev_0348…`) manages related reflection state. Caller scan (P12) accepts `C+0x4c` as the texture object and `+8` as the GL id.
- `[D]` The matrix path takes the texture object as an input — it does **not** create it, size it, or set a viewport. No `glViewport`, `glScissor`, texture `width/height`, or texgen-plane literal was recovered in the re-read bytes for `FUN_0085756c`/`FUN_0085787c`.
- `[U]` The numeric reflection viewport transform (source viewport, texture-matrix scale/bias, clip-plane handling for the mirrored render if any) is **unsettled** → experiment U12-T in §8. The port must not invent a `SCREEN_UV * 0.5 + 0.5` bias, a viewport size, or a mirror matrix.

---

## 7. Verdict: copy vs separate pass vs static texture `[D]/[U]`

| Hypothesis | Static standing after this ticket |
|---|---|
| (a) Framebuffer copy (`glCopyTexImage2D/SubImage`) at water-draw time | `[U]` — only copy call (0x4ed44c) is generic; no water-reachable copy site found; **not ruled in, not ruled out** (a generic helper could be called with the reflection target — callers of the generic helpers were not exhaustively walked) |
| (b) Separate reflection render pass into engine texture (`C+0x4c` as FBO attachment) | `[U]` — **structurally favored but not proven**: FBO names exist; reflection object `C+0x4c` + projective matrix `FUN_0085756c` is exactly the shape a mirrored-scene pass feeds; yet **no water-specific `glGen/BindFramebuffer*` creation call** was recovered `[I]` |
| (c) Static texture (e.g. `DiffuseWaves2` or shipped still) | `[U]` — no static reflection image is referenced by `water.lib` re-read (`ev_2eb0…`/`ev_227e…`: only `water.dev.vert/frag` filenames, `CustomReflection=False`); binder's `waveMap=C+0xfc` path is separate from `reflectionMap=C+0xf8`; **no static source identified** |

**Net `[D]`:** donor samples a **bound engine texture object** (`C+0x4c`, id at `+8`) at sampler unit `C+0xf8` through a projective matrix — the donor-faithful port binding is therefore **a real texture + a real matrix supplied together**, and §8 gives the per-value capture that distinguishes (a)/(b)/(c). Until then the port's current behaviour (hard-fail, no water) is the **correct** donor-faithful behaviour.

---

## 8. `[U]` register — concrete GL/runtime capture experiments with hard-fail conditions

Each row names the **call trace + texture-id/provenance test**. Owner-authorised GPU capture only (RenderDoc/apitrace/Nsight-GL or equivalent); no donor binary work was done by this worker. **Hard-fail** = the port condition that must hold; a failed capture means the port keeps refusing water, never falls back.

| # | Unsettled value | Static state | Capture experiment (trace + provenance test) | Hard-fail condition |
|---|---|---|---|---|
| U12-A | Reflection texture provenance (FBO attachment vs framebuffer copy vs static) | `[U]`; object `C+0x4c`, id `+8`, unit `C+0xf8` | Break on `FUN_00856530` reflection-bind gate + `FUN_00854054` bit 7c.01. Record in one water-visible frame: (1) `glGetIntegerv(GL_FRAMEBUFFER_BINDING)` at the bind, (2) `glBindTexture` target/name at unit `C+0xf8`, (3) all `glGenFramebuffersEXT/BindFramebufferEXT/FramebufferTexture2DEXT/CheckFramebufferStatusEXT` calls with their texture-name args, (4) all `glCopyTexImage2D/SubImage2D` calls with dst name + src rect, (5) texture `glTexImage2D` upload list (names/sizes, incl. any `DiffuseWaves2`). Provenance test: if the bound reflection name **appears as an FBO attachment** earlier in the frame → hypothesis (b); if it **appears as a copy dst** after the main scene and before water draw → (a); if it **appears only as an upload** and never as FBO/copy dst → (c). Sample ≥2 frames + 1 camera move to distinguish per-frame refresh from one-time upload. | Port refuses water unless the capture names a real texture id **and** its provenance class (a/b/c). Unknown provenance ⇒ `push_error` + no water node (current `water3d.gd:521-525` behaviour retained). |
| U12-B | Reflection texture dimensions / mipmap / sampler state | `[U]`; no size literal recovered | At the same break, record `glGetTexLevelParameteriv(name,0,GL_TEXTURE_WIDTH/HEIGHT)`, `GL_GENERATE_MIPMAP` / `glGenerateMipmapEXT` calls on that name, and `GL_TEXTURE_MIN/MAG_FILTER`, `GL_TEXTURE_WRAP_S/T`. | Port refuses to size the reflection target from config or screen size. Reflection `Texture2D` must carry the **captured** pixel size; mip/filter/wrap must match capture or water stays unbound. |
| U12-C | Sampler unit actually used (`C+0xf8` runtime value) | `[O]` source field `C+0xf8`; `[U]` numeric unit | Hook `glUniform1i` on the `reflectionMap` location (from U1 program identification); record the int pushed from `C+0xf8` and the matching `glActiveTexture(GL_TEXTURE0+u)` + `glBindTexture` sequence. | Port sets the sampler uniform to the **captured** unit only; unit unset ⇒ hard-fail. No assumed `TEXTURE0/1` alias. |
| U12-T | Reflection viewport / projective matrix (the `FUN_004cdd9c(...,0x60,…)` output) | `[O]` builder path; `[U]` numeric matrix + viewport | Break on `FUN_0085756c` entry/exit + `FUN_004cdbdc`; dump the 4×4 at caller `+0x60` and the `glViewport/glScissor` + bound-FBO state immediately before/after. Cross-check against the `Mat4` actually uploaded (hook `glUniformMatrix4fv` if the matrix is also a uniform, else read the fixed-function texture matrix). Record with level camera and with a pitched camera to expose clip-plane dependence. | Port accepts **only** the captured matrix path (mirrored-view derivation or verbatim matrix); any screen-UV-bias approximation (`*0.5+0.5` from `gl_FragCoord`) stays labelled `[U12]` port scaffolding in `water3d.gdshader:290-293,362-378` and must not be presented as donor. Missing matrix ⇒ no water. |
| U12-S | `DiffuseWaves2` upload/role (is the reflection just waves?) | `[U]`; no water-specific upload recovered | During the same frame, list all texture uploads by name/size/source file (watch `DiffuseWaves0/2` strings → `glTexImage2D`); test whether the reflection sampler name ever equals a waves upload name. | Port must not alias `reflectionMap` to `diffusewaves` art. If capture shows distinct names, the waves texture stays a separate sampler; if identical, record the single name. Either way, no art file is promoted to reflection without the capture. |
| U12-P | pbuffer / second-context hypothesis (`wglMakeCurrent`, `wglCreatePbufferARB`) | `[U]`; no water-anchored hit in re-read corpus | Trace `wglMakeCurrent/wglCreatePbufferARB/wglChoosePixelFormatARB/wglBindTexImageARB` across one water frame; correlate any context/pbuffer switch with the reflection texture name. Null result (no pbuffer calls) **retires** hypothesis (b-pbuffer) in favour of FBO/copy. | A pbuffer-derived target is only wired if the trace shows it; otherwise the port must not create a pbuffer/surface. |

General capture gating: every experiment requires a water field visible (break on `FUN_00603d30` entry, read `[ebp+0x1c]` per PORT1TO1 §11-U7) and the live shader path identified first (U1: hook `glShaderSource`; `hmapTex` present = DEV file pair, `alphaDepth`/`deepColor` = BUILTIN embedded pair). Captures on the wrong path do not settle U12.

---

## 9. Exact port change list (file/line; NO edits made — owner applies)

All lines verified by repo read this ticket. **Wire only a donor-faithful binding: a real texture object + real matrix from a U12 capture. Invent nothing.**

1. **`variant3d/scripts/world3d_terrain.gd:1089-1106` (`_make_water3d`)** — `[D]` owner never calls `bind_reflection_map()`, so BUILTIN water can never appear. Allowed change ONLY after a §8 U12-A capture exists: after line 1099 (`bind_height_grid(...)` success) and before `add_child`, call `node.call("bind_reflection_map", <captured-real-Texture2D>)` where the Texture2D wraps the **captured provenance** (FBO colour attachment import or captured copy target — never a generated solid-colour image, never `diffusewaves` art unless U12-S proves identity). If the capture is absent or provenance is unknown, **leave the function as-is** (hard-fail, no water). Do not add a fallback quad, neutral texture, or screen-Viewport heuristic here.
2. **`variant3d/scripts/water3d.gd:343-353` (`bind_reflection_map`)** — keep the null-refusal as-is. After U12-A/U12-B capture, extend ONLY to validate: reject textures whose pixel size ≠ captured `WIDTH/HEIGHT` and record `{provenance_class, gl_name, w, h, sampler_unit}` in `stats`; keep returning `false` on mismatch. Do not auto-resize, auto-mipmap, or substitute.
3. **`variant3d/scripts/water3d.gd:520-527` (`_finalize_water_node` BUILTIN gate)** — keep the hard-fail as-is until U12-A + U12-C + U12-T are all captured. Then require **three** bound reals before drawing: reflection texture (U12-A/B), sampler unit match (U12-C), and projective matrix source (U12-T). Any one missing ⇒ same `push_error` + `return false` (no water node). Never bind a neutral/grey quad.
4. **`variant3d/shaders/water3d.gdshader:107-108, 290-293, 362-378`** — keep `reflectionMapBound=false` default and the `discard`/no-draw behaviour when unbound. After U12-T capture, replace the screen-`gl_FragCoord` UV scaffolding with the captured projective path (texture-matrix or explicit mirror-VP uniform) in a labelled diff; until then the current `PORT APPROXIMATION` comment at line 74 must stay, and the shader must remain unreachable without `reflectionMapBound=true`.
5. **`variant3d/scripts/water3d.gd:634,685,712` (telemetry/labels)** — keep `[U12] hard-fail` labels; after capture, flip only the provenanced sub-item (A/B/C/T/S) to `[D]+capture-id` and keep the remainder `[U]`. Keep `visual_parity_claim=false`.
6. **FORBIDDEN (would violate donor faithfulness):** creating a `GradientTexture/ImageTexture` solid colour as reflection; aliasing `reflectionMap` to `diffusewaves0.png` or `heightmapwaves0.tga`; assuming sampler unit 0/1/2; assuming viewport-sized target from `get_viewport()`; inventing a `*0.5+0.5` bias or mirror matrix; calling `bind_reflection_map()` from `_make_water3d` with any non-captured texture to "make water appear".

---

## 10. Explicit non-claims and file discipline

- **No parity claim.** No donor binary executed, no GPU frame captured, no port capture compared by this worker. All donor readings are re-cited `[O]/[D]`; all unsettled values are `[U]` with §8 experiments.
- **No approximation substituted.** No texture, size, unit, matrix, or viewport value is supplied in this report. The port's current hard-fail (no water until a real reflection target) is endorsed as the donor-faithful behaviour.
- **Read-only compliance.** Exactly one repo file written: `docs/terrain_swarm_2026-11-26/reports/DEC_U_water_fbo.md`. No code/shader/asset/config/Godot/git change. No donor file opened for write or executed. No other worker target touched.
- **Scope note:** exhaustive caller-walk of every generic `glCopyTexSubImage2D` helper (0x581444, 0x582b56, 0x5db443, 0x81e66d, …) and an `wglMakeCurrent`/pbuffer whole-binary name sweep remain for a future native pass (each helper ≤5 passes); they are fenced as U12-A/U12-P experiments above, not claimed here.

*End of DEC-U-WATER-FBO.*
