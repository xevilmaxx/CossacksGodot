---
id: DEC-U12-DEEP
worker: DEC-U12-DEEP (subagent in full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
ticket: "Attack U12 provenance from NEW angles: copy-thunk callers, RTTI/constructors, pbuffer/FBO call sites, render-target pool rule"
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
labels: [O, D, I, U]
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. No donor binary executed, copied or committed. No donor file written. No GPU frame captured by this worker."
scope_guard: "No repo code/asset/config/shader/Godot/git change. Exactly one repo file written: this report."
multi_pass: true
visual_parity_claim: false
upstream: "DEC_U_water_fbo.md (U12 verdict [U]); DEC_U_water_runtime.md P12/P13/§8; PORT1TO1_water_shore.md"
---

# DEC-U12-DEEP — water reflection provenance, second attack (static, read-only)

## 0. Authority and discipline (read first)

Every statement is `[O]` (verbatim bytes/text/instruction lifted this ticket, pinned `t_87f0f3c130b0`), `[D]` (deterministic arithmetic/control-flow from `[O]`), `[I]` (interpretation) or `[U]` (UNVERIFIED — settling experiment in §6; port must **hard-fail, never substitute**). This worker issued **NEW native reads this ticket** (passes N1–N5 below) via the read-only program-analysis surface; no donor binary was executed, no GPU frame was captured, no parity is claimed. Prior-ticket records (`DEC_U_water_fbo.md`, `DEC_U_water_runtime.md`) are re-used only as the starting hypothesis; every §1–§5 claim below rests on a fresh read taken 2026-11-26. No other worker target was touched.

`[D]` The load-bearing port fact is unchanged: no reflection texture, size, unit, or matrix value is supplied by this report. Anything still `[U]` in §6 keeps the current port behaviour (hard-fail, no water) correct.

---

## 1. Pass ledger (owner rule ≤5 passes/function; every pass logged; all NEW this ticket)

| Pass | Question | Fresh reads this ticket | Result |
|---|---|---|---|
| N1 | Callers/chains of `FUN_004ed38c` region + `glCopyTexImage2D` thunk, with argument sources | `native_function_find` at 0x4ed200/4ed300/4ed38c/4ed400/4ed500/4ed600; `native_function_show` + `native_function_study(summary)` + `native_function_callers_list` on `sub_4ed28c`; same trio on `sub_7715f4`; `native_instruction_show` at 0x771b50, 0x4ed38c, 0x4ed44c, 0x4afb3c; `native_address_show` 0x4ed38c; `native_bytes_find` `ff 15 7c 7d 90 00` (0 hits) / `ff 25 7c 7d 90 00` (1 hit); `native_bytes_find` `68 8c d3 4e 00`, `b8 8c d3 4e 00` (0 hits each) | **Accepted as bounded**: single static `call 0x4afb3c` at 0x4ed44c; thunk is `jmp [__imp_glCopyTexImage2D]`; container gap + one caller chain recovered (below). No water-anchored caller found |
| N2 | RTTI / type descriptors / constructors for `TOSWTextureImage*` reachable from `C+0x4c` | `native_bytes_find` `TOSWTextureImage` (4 hits), `TextureImage` (8 hits), `.?AV` (0 hits), `TOSWTextureImageToN` (1 hit), `OSWTexture` (59 hits, first 10 paged); `native_bytes_show` 0x4e6e00/0x4e6f60/0x4e7000 (512 B each); `native_instruction_show` 0x4e7e80; `native_function_show` `sub_4e72f8` | **Accepted as localized**: Delphi class family `TOSWTextureImage / TOSWTextureImageToN / TOSWRefTextureImage / TOSWTextureImageEditor / TOSWBlankImage / TOSWTexture / OSWTexture` with `ImageClassName`/`Image`/`ImageAlpha` properties; **no MSVC RTTI**; no constructor→`C+0x4c` link recovered → `[U]` |
| N3 | Packed-CODE `wglCreatePbufferARB` / `wglBindTexImageARB` / `glGenFramebuffersEXT` call sites + water-scoped setup | `native_bytes_find` `wglCreatePbufferARB` (1 hit 0x4ba740), `wglBindTexImageARB` (1 hit 0x4ba7ac), `wglChoosePixelFormatARB` (1 hit 0x4ba6f4), `glGenFramebuffersEXT` (1 hit 0x4b98d0), `glCopyTexImage2D` (2 hits 0x4b8a1c + 0x90ae4c), `glCopyTexSubImage2D` (2 hits 0x4b8a48 + 0x90ae36), `wglMakeCurrent` (1 hit, `.idata` 0x90a770 only), `wglGetProcAddress` (1 hit, `.idata` 0x90a7bc only); `native_bytes_show` 0x4ba500/0x4ba600/0x4b8a00/0x4b98c0/0x4ba740; `native_xrefs_list` on 0x4b8a1c/0x4ba740/0x4ba7ac/0x4b98d0 (all `total_to: 0` in builtin DB); pointer-pattern scans `40 a7 4b 00`, `ac a7 4b 00`, `1c 8a 4b 00`, `8c d3 4e 00` (table-internal/false-positive only) | **Accepted**: each spelling is a **singleton CODE string** inside a contiguous dispatch table; **zero direct code xrefs** in the builtin DB; no water-scoped setup call recovered → `[U]` |
| N4 | Generic render-target pool / deterministic naming rule for `C+0x4c` | `native_bytes_show` 0x4ed28c (128 B preamble), 0x4ed300 (512 B), 0x4ed44c (96 B call window); `native_xrefs_list` 0x4afb3c (0 refs in builtin DB — superseded by study counts); `native_function_study(summary)` on `sub_4aff8c` (thunk container) and `sub_4ed28c` | **Accepted as bounded**: no pool/naming rule recovered; copy path is generic; `C+0x4c` creation site still unanchored → `[U]` |
| N5 | Cross-check: does any new read place a copy/FBO/pbuffer call inside the water path? | Re-checked `N1–N4` hits against water functions `FUN_00603d30 / FUN_00854054 / FUN_00856530 / FUN_0085756c / FUN_0085787c / FUN_00855b38` (addresses from prior tickets; no new water-function lift this ticket to stay within pass budget) | **Accepted**: none of the new singleton addresses lies inside a water-function range cited in prior records; water-scoped setup still absent → `[U]` |

No function consumed more than 5 passes this ticket. Prior-ticket pseudocode (`ev_8096…`, `ev_2b51…`, `ev_ab75…`, `ev_8218…`) is **not** re-cited as evidence for §2–§5; it is only the hypothesis that N1–N4 test.

---

## 2. (a) Callers/chains of the copy path — NEW reads `[O]/[D]`

### 2.1 The thunk is a direct import jump, called once in the static DB `[O]/[D]`

- `[O]` `native_instruction_show` at **0x4afb3c**: `jmp dword ptr [0x907d7c]`, `references: [{address: 0x907d7c, name: __imp_glCopyTexImage2D}]`, containing function `sub_4aff8c` (new `ev_50fe26b2…`).
- `[O]` `native_instruction_show` at **0x4ed44c**: `call 0x4afb3c`, bytes `e8 eb 26 fc ff` (new `ev_ea31675a…`). Arithmetic `[D]`: `0x4ed44c + 5 + 0xfffc26eb = 0x4afb3c`, so the call targets the thunk exactly.
- `[O]` `native_function_study(summary)` on `sub_4aff8c` (new `ev_b530b2c5…`): `incoming_references: 1`, `callers: 0` (direct), 183 blocks / 437 insns / 10 internal calls. `[D]` In the builtin engine's static DB the thunk container has exactly **one** incoming reference — consistent with the single `call` at 0x4ed44c being its only static caller. (Absence of further callers is bounded by the engine's discovery, not a whole-binary proof — see §6 U12-A.)
- `[O]` `native_bytes_find` pattern `ff 15 7c 7d 90 00` (`call [__imp_glCopyTexImage2D]`): **0 matches**; pattern `ff 25 7c 7d 90 00` (`jmp […]`): **exactly 1 match** at 0x4afb3c. `[D]` The binary never calls the `glCopyTexImage2D` import directly; every static copy goes through the 0x4ed44c → 0x4afb3c → import edge.
- `[O]` `native_bytes_find` text `glCopyTexImage2D`: exactly **2 matches** — `0x4b8a1c` (CODE name string) + `0x90ae4c` (`.idata` import name) (new `ev_0e8e3588…`). `glCopyTexSubImage2D`: exactly **2 matches** — `0x4b8a48` (CODE) + `0x90ae36` (`.idata`). `[D]` Copy entry points are imported (`.idata`), while their *names* also live in a CODE dispatch table (see §4) — the classic dual path (static import + `wglGetProcAddress` table).

### 2.2 The container around 0x4ed38c is a discovery gap with one recovered caller chain `[O]/[D]`

- `[O]` `native_function_find`: `0x4ed300` is inside `sub_4ed28c + 0x74` (new `ev_83737bcf…`); `0x4ed200`, `0x4ed38c`, `0x4ed400`, `0x4ed500`, `0x4ed600` are each **not inside any discovered function** (new `ev_4551b935…`, `ev_319339f1…`, `ev_c9358814…`, `ev_8dd177fa…`, `ev_5444b9dd…`). `native_address_show` 0x4ed38c confirms `not inside any discovered function`, `no name` (new `ev_fe07ac4c…`). `[D]` The builtin engine splits the region: a known 255-byte function ends at 0x4ed38b, and the `FUN_004ed38c` body known to Ghidra/Deep is **undiscovered by the builtin engine** — caller enumeration through the builtin DB therefore cannot be complete, and §6 keeps a whole-binary sweep open.
- `[O]` `native_function_show` `sub_4ed28c`: entry `0x4ed28c`, end `0x4ed38b`, 255 bytes, 33 blocks, 87 insns (new `ev_e01eb20b…`). `native_function_study(summary)` (new `ev_16ab8d2e…`): 6 callees, `incoming_references: 1`, `callers: 1`.
- `[O]` `native_function_callers_list` `sub_4ed28c` (new `ev_b3c74259…`): exactly one direct caller — `sub_7715f4` at site `0x771b50`. `native_instruction_show` 0x771b50 confirms `call 0x4ed28c` inside `sub_7715f4`.
- `[O]` `sub_7715f4`: 119 blocks / 594 insns / 19 callees / 10 unresolved calls (new `ev_db7bd0ec…`); `native_function_callers_list` (new `ev_ceecb0fa…`): **0 direct callers, `address_taken: 1`**. `[D]` The recovered static chain is `… → (indirect/callback) sub_7715f4 → 0x771b50:call → sub_4ed28c → [fall-through gap] 0x4ed38c…0x4ed44c:call → thunk → __imp_glCopyTexImage2D`. The head (`sub_7715f4`) is reached indirectly (callback/vtable/entry), so its own caller is **not statically named** — the chain terminates in `[U]` at the top (see U12-A2).
- `[O]` Push-immediate scans for the gap function address: `68 8c d3 4e 00` and `b8 8c d3 4e 00`: **0 matches each**. `[D]` No `push/mov`-immediate takes the address of `0x4ed38c` in the packed bytes — the gap body is entered by fall-through/branch from `sub_4ed28c`'s tail or by an undiscovered edge, not by an explicit function-pointer constant visible to a byte scan.
- `[O]` Linear `native_instruction_show` stepping from 0x4ed38c decodes `push ebp; mov ebp,esp; push ebx; mov [ebp-4],eax; cmp [eax+0x6a],0; je 0x4ed3b5` and then degrades (`insb`, `dec edi`, …) — the builtin linear decoder misaligns past the first branch because the function was never discovered. `[D]` Argument-source recovery for the `glCopyTexImage2D` call (dst name, level, formats, src rect) **cannot be done with the builtin linear decoder here**; it needs the Deep (Ghidra) decode of `FUN_004ed38c` already cited as `ev_8096…` (generic loader, branch at 0x4ed44c) plus the §6 capture. No new argument-source fact is claimed.

**Net `[D]` for (a):** the copy edge is unitary and generic — one static `call` (0x4ed44c) through one thunk (0x4afb3c) to one import (`__imp_glCopyTexImage2D`) — fed by a loader whose head chain is `sub_7715f4 → sub_4ed28c → gap(0x4ed38c…)`. No caller in this chain is water-scoped (chain lives at 0x4e.. / 0x77.., water code at 0x60.. / 0x85..), and **no water-function→copy edge** was found in any new read.

---

## 3. (b) RTTI / type descriptors / constructors for `TOSWTextureImage*` `[O]/[D]/[U]`

- `[O]` `native_bytes_find` (all pinned `t_87f0f3c130b0`, fresh this ticket): `TOSWTextureImage` = **4 matches** (`0x4e6e2a`, `0x4e6f99`, `0x4e6fb2`, `0x4e7101`); `TOSWTextureImageToN` = **1 match** (`0x4e6fb2`); `TextureImage` = **8 matches** (six in CODE `0x4e6e2e–0x4e7105`, one at `0x770bab`, one in `.rsrc` `0x9586df`); `OSWTexture` = **59 matches** (first page: `0x4bf406`, `0x4bf41f`, `0x4e6c98`, `0x4e6d2a`, `0x4e6e2b`, `0x4e6efb`, `0x4e6f9a`, `0x4e6fb3`, `0x4e6fcd`, `0x4e70a4`); `.?AV` (MSVC RTTI prefix) = **0 matches**.
- `[O]` `native_bytes_show` 0x4e6e00 (512 B): ASCII run `…textureFileName.String… TOSWTextureImageAlpha … tiaDefault.tiaAlphaFromIntensity.tiaSuperBlackTransparent.tiaLuminance.tiaLuminanceSqrt.tiaOpaque.tiaTopLeftPointColorTransparent.tiaInverseLuminance.tiaInverseLuminanceSqrt.OSWTexture…` — a Delphi published-property block (enum `TOSWTextureImageAlpha` + `textureFileName: String`).
- `[O]` `native_bytes_show` 0x4e6f60 (512 B): `…TOSWTextureImage … TOSWTextureImageToN … OSWTexture … TOSWRefTextureImage … TOSWRefTextureImage … OSWTexture … TOSWTextureImageEditor…`.
- `[O]` `native_bytes_show` 0x4e7000 (512 B): `…TOSWRefTextureImage … TOSWTextureImageEditor … TOSWBlankImage … TOSWBlankImage … OSWTexture…`.
- `[O]` `native_bytes_show` 0x4e7e80 region (inside `sub_4e72f8`): `…TOSWTexture … TOSWTexture … OSWTexture … ImageClassName … Image … ImageAlpha…` — class-registration property names.
- `[O]` `native_function_show` `sub_4e72f8`: body spans `0x4e72f8–0x4e91…` (hundreds of ranges; end past `0x4e91d8`), i.e. a **giant initialization/registration routine** whose body *contains* the class-name strings above as embedded data. `[D]` The class metadata is Delphi-style (class names + published properties interleaved with init code in CODE section), not MSVC (`0` `.?AV` hits) — consistent with a Delphi-compiled engine where `TOSW*` are `TComponent`-style classes registered by `sub_4e72f8`.
- `[U]` No new read links any `TOSW*` constructor (or `TOSWRefTextureImage`, the only name shaped like a reflection-texture class) to the water shader object field `C+0x4c` (GL id at `+8`). Concretely missing: (i) which `TOSW*` class instantiates the object at `C+0x4c`; (ii) the constructor's width/height/format/mipmap arguments; (iii) whether `TOSWRefTextureImage` vs `TOSWBlankImage` vs plain `TOSWTextureImage` backs the reflection slot; (iv) the call site that stores the instance pointer into `C+0x4c`. A whole-binary constructor→field-store sweep (each `TOSW*` vtable + `ImageClassName` factory) remains open → experiments U12-R1/R2 in §6. **Do not** record `TOSWRefTextureImage = reflection` as `[O]`; the name is suggestive only `[I]`.

---

## 4. (c) Packed-CODE `wglCreatePbufferARB` / `wglBindTexImageARB` / `glGenFramebuffersEXT` — NEW sweep `[O]/[D]/[U]`

- `[O]` Singleton CODE strings (each exactly 1 match): `wglCreatePbufferARB` at **0x4ba740**, `wglBindTexImageARB` at **0x4ba7ac**, `wglChoosePixelFormatARB` at **0x4ba6f4**, `glGenFramebuffersEXT` at **0x4b98d0** (fresh `native_bytes_find` this ticket; FBO row corroborates prior `ev_c380…` without re-citing it).
- `[O]` `native_bytes_show` 0x4ba600 (512 B) + 0x4ba500 (256 B): contiguous `wgl…ARB` dispatch-name table — `wglCreateBufferRegionARB … wglSaveBufferRegionARB … wglGetExtensionsStringARB … wglGetPixelFormatAttribivARB … wglChoosePixelFormatARB … wglMakeContextCurrentARB … wglGetCurrentReadDCARB … wglCreatePbufferARB … wglGetPbufferDCARB … wglReleasePbufferDCARB … wglDestroyPbufferARB … wglQueryPbufferARB … wglBindTexImageARB … wglReleaseTexImageARB … wglSetPbufferAttribARB …` each NUL-separated, preceded by pointer-sized slots (the `…K…` runs). `[D]` This is a `wglGetProcAddress` name table, not import names: the corresponding imports present are only `wglMakeCurrent` (`0x90a770`, `.idata`) and `wglGetProcAddress` (`0x90a7bc`, `.idata`) — **1 hit each, both in `.idata` only**, i.e. no CODE name-string for either.
- `[O]` `native_bytes_show` 0x4b98c0 (128 B): `FramebuffersEXT NUL glGenFramebuffersEXT NUL glCheckFramebufferStatusEXT NUL glFramebufferTexture1DEXT NUL glFramebufferTexture2DEXT …`; `native_bytes_show` 0x4b8a00 (256 B): `…glCopyTexImage1DEXT … glCopyTexImage2DEXT … glCopyTexSubImage1DEXT … glCopyTexSubImage2DEXT … glCopyTexSubImage3DEXT … glGenTexturesEXT…`. `[D]` FBO-EXT and copy-EXT names co-reside in the same CODE dispatch-table region (`0x4b8xxx–0x4b99xx`), resolved at runtime via `wglGetProcAddress`.
- `[O]` `native_xrefs_list` on `0x4b8a1c` (copy name), `0x4ba740` (pbuffer-create name), `0x4ba7ac` (bind-tex name), `0x4b98d0` (gen-FBO name): each returns **`total_to: 0`, no `references_to`** in the builtin DB. Pointer-pattern scans for the string VAs (`40 a7 4b 00` → only hit `0x4ba53b` table-internal; `ac a7 4b 00` → only `0x4ba586` table-internal; `1c 8a 4b 00` → only `0x4b3446` table-internal) confirm the table references itself. `[D]` Code does not `lea/mov`-reference these names through absolute immediates visible to a packed-byte scan — resolution is via table-walk + `wglGetProcAddress` (pointer-chasing), so **absence of a code xref in the builtin DB is expected and proves nothing about runtime use**.
- `[U]` No new read places a `wglCreatePbufferARB`, `wglBindTexImageARB`, `wglChoosePixelFormatARB`, `wglMakeContextCurrentARB`, `glGen/Bind/FramebufferTexture2D*`, or `glCheckFramebufferStatus*` **call site inside, or called from**, `FUN_00603d30 / FUN_00854054 / FUN_00856530 / FUN_0085756c / FUN_0085787c / FUN_00855b38`. The pbuffer hypothesis (U12-P) and the FBO-attachment hypothesis (U12-A) therefore both survive with **zero static anchors** → §6 U12-P/U12-A capture experiments, with zero-mismatch termination. No pbuffer/FBO creation may be wired into the port on static grounds.

---

## 5. (d) Is `C+0x4c` made by a generic render-target pool with a naming rule? `[O]/[D]/[U]`

- `[O]` `native_bytes_show` 0x4ed28c (128 B preamble): `53 51 52 8b f0 8a 46 1f …` (`push ebx; push ecx; push edx; mov esi,eax; …`) — a small register-save prologue consistent with a texture/unit loader entry, immediately followed (per §2.2) by the undiscovered gap body that contains the copy branch at 0x4ed44c.
- `[O]` `native_bytes_show` 0x4ed44c window (96 B): `… e8 eb 26 fc ff (call 0x4afb3c) 8b 45 fc 8b 40 24 8b 10 ff 52 1c …` — after the copy call the loader continues through two virtual dispatches (`call [edx+0x1c]`, `call [edx+0x18]`-shaped `ff 52 xx`), i.e. engine-object protocol, not inline GL state.
- `[D]` The loader shape (prologue → conditional branch → one copy call → virtual calls) matches a **generic texture-image path** (any texture can flow through it), not a water-specific render-target allocator: no width/height/format literals tied to a reflection size, no `reflectionMap`/`waveMap` key, no `C+0xf8`/`C+0x4c` field constant appears in the new bytes.
- `[U]` Whether `C+0x4c` is allocated by (i) this generic loader, (ii) a separate FBO render-target pool keyed by size/format, (iii) a pbuffer surface pool, or (iv) a static upload is **still unsettled**. No deterministic naming/provenance rule (e.g. "reflection target is always N×M `GL_RGBA8` with generated mipmaps", "pool names recycle in creation order") was recovered in any new read. A pool would show as: repeated same-size `glTexImage2D`/`glRenderbufferStorageEXT` shapes, a free-list, or a name→size map — none was found → experiment U12-Q in §6. **Do not** invent pool semantics in the port.

---

## 6. Still-`[U]` register — exact GL/runtime capture with zero-mismatch termination

Each row names the **trace + provenance test**. Owner-authorised GPU capture only (RenderDoc/apitrace/Nsight-GL or equivalent). No donor work was done by this worker. **Zero-mismatch termination** = the capture must match the stated predicate exactly; any mismatch keeps the port in hard-fail (no water), never a fallback texture/matrix.

| # | Unsettled value | Static state after N1–N4 | Capture experiment (trace + provenance test) | Zero-mismatch termination |
|---|---|---|---|---|
| U12-A | Reflection provenance: FBO attachment vs framebuffer copy vs static upload | `[U]`; unit `C+0xf8`, object `C+0x4c`/`+8` (prior); single static copy edge 0x4ed44c→thunk→import (§2.1); no water→copy/FBO/pbuffer edge (§2.2, §4) | One water-visible frame: (1) break on reflection-bind gate + bit 7c.01 upload; (2) record `GL_FRAMEBUFFER_BINDING` at bind, `glBindTexture` target/name at unit `C+0xf8`; (3) log all `glGen/Bind/FramebufferTexture2DEXT + CheckFramebufferStatusEXT` with texture-name args; (4) log all `glCopyTexImage2D/SubImage2D` with dst name + src rect; (5) log all `glTexImage2D` uploads (names/sizes, incl. any `DiffuseWaves*`). Provenance test: bound name ∈ FBO-attachment set earlier in frame → (b); ∈ copy-dst set after main scene → (a); ∈ upload-only set → (c). ≥2 frames + 1 camera move. | Wire only the proven class. Any name that is neither attachment, copy-dst, nor upload ⇒ no water. Unknown ⇒ `push_error`, keep `reflectionMapBound=false`. |
| U12-A2 | Head of the copy chain (`sub_7715f4` indirect caller) | `[U]`; `sub_7715f4` has 0 direct callers, `address_taken: 1` (new `ev_ceecb0fa…`) | In the same capture, back-trace the thread that issues the copy/FBO calls (API-trace stack or breakpoint on 0x4ed44c): name the callback/vtable that enters `sub_7715f4`. Null result (copy never fires in a water frame) retires hypothesis (a) for the water path. | If the copy never fires while water is visible, the port must not model reflection as a copy. |
| U12-B | Reflection size / mipmap / sampler state | `[U]`; no size literal in N1–N4 bytes | At the same break: `glGetTexLevelParameteriv(name,0,GL_TEXTURE_WIDTH/HEIGHT)`, `GL_GENERATE_MIPMAP` / `glGenerateMipmapEXT` on that name, `GL_TEXTURE_MIN/MAG_FILTER`, `GL_TEXTURE_WRAP_S/T`. | Port `Texture2D` must carry the captured W×H; filter/wrap must equal capture. Any mismatch ⇒ refuse bind. |
| U12-C | Sampler unit actually used (`C+0xf8` runtime value) | `[O]` source `C+0xf8`; `[U]` numeric unit | Hook `glUniform1i` on the `reflectionMap` location; record int pushed + `glActiveTexture(GL_TEXTURE0+u)` + `glBindTexture` sequence. | Port sets exactly the captured unit. Unset ⇒ hard-fail. No assumed `TEXTURE0/1/2`. |
| U12-T | Projective matrix (`FUN_004cdd9c(…,0x60,…)`) + viewport | `[O]` builder path (prior); `[U]` numeric matrix + viewport | Break on matrix build + `FUN_004cdbdc`; dump 4×4 at caller `+0x60` and `glViewport/glScissor` + bound-FBO state immediately before/after. Cross-check against uploaded `Mat4` if any. Level + pitched camera. | Port accepts only the captured path/verbatim matrix. `*0.5+0.5` bias stays labelled scaffolding, unreachable without `reflectionMapBound=true`. |
| U12-S | `DiffuseWaves*` role | `[U]` | List all texture uploads by name/size/source (`DiffuseWaves0/2` → `glTexImage2D`); test `reflectionName == wavesName`. | If distinct, waves stay a separate sampler; if identical, record the single name. Never alias without the test. |
| U12-P | pbuffer / second-context hypothesis | `[U]`; singleton strings, zero static xrefs (§4) | Trace `wglCreatePbufferARB / wglMakeContextCurrentARB / wglBindTexImageARB / wglChoosePixelFormatARB / wglMakeCurrent` across one water frame; correlate any switch with the reflection name. Null result **retires** (b-pbuffer). | Pbuffer target wired only if the trace shows it; otherwise port must not create a surface. |
| U12-R1 | Which `TOSW*` class backs `C+0x4c` | `[U]`; Delphi family localized (§3), no ctor link | Break on the store into `C+0x4c` (write-watchpoint from the reflection-bind gate); dump the instance's class name (`ImageClassName` / vtable → `TOSWRefTextureImage` vs `TOSWTextureImage` vs `TOSWBlankImage`) and the constructor's size/format/mipmap args. | Port records `{className, w, h, format, mips}` exactly; missing ⇒ no water. |
| U12-R2 | Deterministic pool/naming rule | `[U]`; no rule in N1–N4 | Across ≥3 runs / map loads: list reflection-name reuse vs size/format; test for pool (same name recycled, free-list, size-keyed map). | A pool rule is wired only if creation order predicts the name in all 3 runs with zero mismatches. |
| U12-Q | Copy argument sources (dst/level/rect) if (a) wins | `[U]`; builtin decoder misaligns past 0x4ed3b5 | At `call 0x4afb3c` (0x4ed44c): dump the 7 `glCopyTexImage2D` args (target, level, internalformat, x, y, w, h) + bound-read-buffer rect. | Port copy path (if ever modelled) uses exactly these; any wildcard ⇒ no water. |

General gating: water field visible (break on `FUN_00603d30` entry), live shader path identified first (U1: `hmapTex` present = DEV file pair, `alphaDepth`/`deepColor` = BUILTIN embedded pair). Captures on the wrong path do not settle U12.

---

## 7. Exact port change list (file/line; NO edits made — owner applies)

All lines verified by repo read in the parent ticket; repeated here without change except U12-R1/R2/Q additions. **Wire only a real texture + real matrix from a §6 capture. Invent nothing.**

1. `variant3d/scripts/world3d_terrain.gd:1089-1106` (`_make_water3d`) — keep not calling `bind_reflection_map()` until a §6 U12-A capture names a real id **and** its class (U12-R1). Then call `bind_reflection_map(<captured-Texture2D>)` only.
2. `variant3d/scripts/water3d.gd:343-353` (`bind_reflection_map`) — keep null-refusal; after U12-A/U12-B/U12-R1 extend validation to `{provenance_class, gl_name, className, w, h, sampler_unit}`; reject on any mismatch.
3. `variant3d/scripts/water3d.gd:520-527` (BUILTIN gate) — keep hard-fail until U12-A + U12-C + U12-T captured; then require all three reals before drawing.
4. `variant3d/shaders/water3d.gdshader:107-108, 290-293, 362-378` — keep `reflectionMapBound=false` default and no-draw-when-unbound; replace screen-UV scaffolding only with the captured U12-T path in a labelled diff.
5. `variant3d/scripts/water3d.gd:634,685,712` (telemetry) — keep `[U12]` labels; flip each sub-item only on its named capture (A/B/C/T/S/P/R1/R2/Q).
6. **FORBIDDEN:** solid-colour/neutral `ImageTexture`; aliasing to `diffusewaves0.png`/`heightmapwaves0.tga` without U12-S identity; assumed unit 0/1/2; viewport-sized target from `get_viewport()`; invented bias/mirror matrix; calling `bind_reflection_map()` with any non-captured texture; inventing a pool rule or `TOSWRefTextureImage` identity from the class name alone.

---

## 8. Explicit non-claims and file discipline

- **No parity claim.** No donor binary executed, no GPU frame captured, no port capture compared. All new readings are `[O]/[D]`; all provenance values are `[U]` with §6 experiments.
- **No approximation substituted.** No texture, size, unit, matrix, viewport, class identity, or pool rule is supplied. The port's hard-fail (no water until a real reflection target) is endorsed as donor-faithful.
- **No guess promoted.** `TOSWRefTextureImage` is a suggestive class name `[I]`, not the reflection backer `[O]`; the unitary copy edge does not imply the water path uses it `[D]`; singleton FBO/pbuffer strings do not imply water FBO/pbuffer use `[D]`.
- **Read-only compliance.** Exactly one repo file written: `docs/terrain_swarm_2026-11-26/reports/DEC_U12_deep.md`. No code/shader/asset/config/Godot/git change. No donor file opened for write or executed. Investigation memory was not overwritten by this worker (reads only; no brief/plan/hypothesis/finding/handoff writes).
- **Scope note:** exhaustive whole-binary caller walk of every `glCopyTexSubImage2D` helper and a `TOSW*` constructor→field-store sweep each remain for a future native pass (each helper ≤5 passes); they are fenced as U12-A2/R1/R2/Q above, not claimed here.

*End of DEC-U12-DEEP.*
