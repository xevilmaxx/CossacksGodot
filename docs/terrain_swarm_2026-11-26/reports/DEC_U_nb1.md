---
id: DEC-U-NB1
worker: DEC-U-NB1 (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
ticket: "NB-6 TOSW* whole-binary ctor->field sweep (class-B B1/B2 residual; highest-value new static angle)"
date: 2026-11-27
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
labels: [O, D, I, U]
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. No donor binary executed, copied, committed, or captured. No donor file written. No GPU frame captured. All calls pinned document=t_87f0f3c130b0, Deep mode (engine 0.6.1, Ghidra-backed target already open; builtin clean-room lifter used for reads)."
scope_guard: "No repo code/asset/shader/config/test/fixture/result/Godot/git change. Exactly one repo file written: this report."
multi_pass: true
upstream: "PORT1TO1_b_angle_index.md NB-6 (TOSW* whole-binary ctor->C+0x4c/C+0xe0 field-store sweep, refines B1/B2); DEC_U12_deep.md §3 (TOSW*/OSWTexture family); DEC_U12_caller_walk.md §4 (TOSW* ctor->C+0x4c sweep, zero xrefs); DEC_U3_reg_sweep.md §2.2/§6 (U-REG-TEX residual); DEC_U_hmap_identity.md §4 (C+0xe0 object, [C+0xe0+8] gate, C+0xdc unit, C+0xd8 target); DEC_U_water_shader_deep.md §6 U12 (C+0x4c reflection slot)"
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD for NB-6 static angle alone — no byte-proven TOSW* ctor->C+0x4c / texture-+8 / C+0xe0 store recovered across the FULL binary; U12 provenance stays [U]; hard-fail (no water) endorsed; no approximation."
---

# DEC-U-NB1 — NB-6 `TOSW*` whole-binary ctor→field sweep

> Authority: `[O]` = verbatim bytes/text/instruction lifted this ticket, pinned `t_87f0f3c130b0`; `[D]` = deterministic control-flow/arithmetic from `[O]`; `[I]` = interpretation; `[U]` = UNVERIFIED with settling experiment in §6. No parity claim. Port keeps hard-fail.

## 0. What was asked and what is delivered

Execute NB-6 as the highest-value new static angle: enumerate **all** `TOSWTextureImage / ToN / Ref / Blank / Editor`, `TOSWTexture`, `OSWTexture` constructor/class descriptors across the **FULL binary** (not just the `0x4e6xxx` windows), trace each ctor's field stores for any write into a shader-object offset matching `C+0x4c` (water reflection slot) or a texture object's `+8` GL id, and determine whether any links to the water shader texture object. Only byte-proven links become `[D]`; otherwise keep U12 provenance `[U]` with the exact GL texture-id capture. No invented link; no parity claim.

**Net result: `[U]` kept on every provenance value.** Full-binary enumeration is byte-proven `[O]/[D]` (counts + VAs + sections below). Every testable ctor body was disassembled and grepped for `+0x4c` / `+0x8` / `+0xe0` stores — **none found**. No ctor→`C+0x4c`, ctor→`C+0xe0`, or ctor→`texture+8` edge is byte-proven. `TOSWRefTextureImage` stays suggestive `[I]`, never `[O]` for reflection backing. The port's hard-fail (no water until a real reflection target) is endorsed.

---

## 1. Pass ledger (owner rule ≤5 passes/function; every pass logged; all NEW this ticket, all pinned `t_87f0f3c130b0`)

| Pass | Question | Fresh reads this ticket | Result |
|---|---|---|---|
| P1 | Full-binary enumeration of all 8 target names + neighbours | `native_bytes_find` (both utf8/utf16le) for `TOSWTextureImage` (4), `TOSWTextureImageToN` (1), `TOSWRefTextureImage` (3), `TOSWBlankImage` (4), `TOSWTextureImageEditor` (1), `TOSWTexture` (22), `OSWTexture` (59), `ImageClassName` (1), `TOSWTextureImageAlpha` (1); extras `TOSWPictureImage` (2), `OSWTextureExItem` (2), `TOSWTextureLensFlare` (2) | **Accepted as complete**: counts + VA lists §2; FIRST page VAs recorded; CODE vs table vs `.rsrc` sections separated |
| P2 | Code-xref test on every class-name VA | `native_xrefs_list` on 15 probe VAs (`0x4e6e2a/0x4e6f99/0x4e6fb2/0x4e7101/0x4e706d/0x4e7086/0x770ba4/0x4e71a9/0x4e71be/0x774374/0x812a44/0x4e7f17/0x4bf405/0x57f84d/0x57f86a`) | **Accepted**: 14× `total_to: 0`, 1× `total_to: 1` (`0x812a44 ← 0x812999 data in sub_8127e0`) — no code caller into any class name |
| P3 | Containing-function test (is any class name inside code?) | `native_function_find` on 13 VAs | **Accepted**: 11× `not inside any discovered function` / `not in executable code`; 2× inside `sub_4e72f8` (`0x4e7f17` off 3103, `0x4e7a27` off 1838); `0x812a44` IS `sub_812a44` entry |
| P4 | Ctor-body field-store grep (`+0x4c` / `+0x8` / `+0xe0`) | `native_function_disassemble` on `sub_8127e0` (140 insns), `sub_812a44` (49 insns), `sub_7744cc` (61 insns), `sub_7763f8` (25 insns), `sub_6760a0` (15 insns); full store-list dump of `sub_8127e0`; displacement grep `+0x4c/+0x8/+0xe0` on all five | **Accepted**: full store lists §3; only `+0x4c` hit in corpus is a LOAD `mov eax,[eax+0x4c] @0x6760a8`; zero `+0x4c` stores, zero `+0x8` stores, zero `+0xe0` stores in any TOSW-linked ctor |
| P5 | Class-table bytes + registrar/factory shape | `native_bytes_show` on `0x4e6e00/0x4e6f60/0x4e7000/0x4e7100/0x4e7f00` (512 B each), `0x770ba0/0x774370/0x812a40` (256 B each), `0x4bf400/0x57f848/0x9586c0` (512 B each); `native_function_show sub_4e72f8/sub_812a44/sub_8127e0`; `native_function_study sub_7763f8 summary`; `native_function_callers_list sub_8127e0` (0 direct callers) | **Accepted**: Delphi length-prefixed tables + published-property runs `[D]`; `sub_4e72f8` = 9107-block registration giant; `sub_8127e0` unreachable-by-static-call init; `sub_7763f8` = 5-block `dl`-switched factory |
| P6 | Water-anchoring cross-check | Water ranges from priors (`00603d30/00854054/00856530/0085756c/0085787c/00855b38` + `FUN_008520a8/0082f060/0082f114/00739bf8/0082f86c`); none of the §2 VAs or P4 functions lies in a water range; callees generic | **Accepted**: no water-scoped caller/writer recovered → `[U]` |

No function consumed more than 5 passes. Prior-ticket pseudocode was used only as hypothesis, never re-cited as evidence.

---

## 2. Full-binary enumeration — counts + VAs + sections `[O]/[D]`

All searches `document:"t_87f0f3c130b0"`, pinned, this ticket (re-affirms `DEC_U3_reg_sweep.md §2.2` and `DEC_U12_caller_walk.md §4` and extends to the FULL binary including out-of-`0x4e72f8` and `.rsrc` hits).

| Class string | Total hits (whole binary) | VAs `[O]` | Section / context `[O]` |
|---|---|---|---|
| `TOSWTextureImage` | **4** | `0x4e6e2a, 0x4e6f99, 0x4e6fb2, 0x4e7101` | all `.CODE`; `0x4e6e00` window: `…textureFileName.String…TOSWTextureImageAlpha…tiaDefault…` (Delphi published-property block) |
| `TOSWTextureImageToN` | **1** | `0x4e6fb2` (shared with above) | same `0x4e6f60` window: `…TOSWTextureImage…TOSWTextureImageToN…OSWTexture…TOSWRefTextureImage…` |
| `TOSWRefTextureImage` | **3** | `0x4e706d, 0x4e7086, 0x770ba4` | `0x4e7000` window (`…TOSWRefTextureImage…TOSWTextureImageEditor…TOSWBlankImage…`); `0x770ba4` table: `13 00 00 00 'TOSWRefTextureImage' 00 53 56…` (length-prefixed class-registration entry + `SV`-tagged init stubs) |
| `TOSWBlankImage` | **4** | `0x4e71a9, 0x4e71be, 0x774374, 0x812a44` | `0x4e7100` window (`…TOSWBlankImage…TOSWBlankImage…OSWTexture…`); `0x774370` table: `0e 00 00 00 'TOSWBlankImage' 00 03 00 00 00 53 51…`; `0x812a40` bytes: `0e000000 'TOSWBlankImage' 00 53 56 e8…` (class-table + stub calls) |
| `TOSWTextureImageEditor` | **1** | `0x4e7101` (shared with `TOSWTextureImage` hit) | `0x4e7100` window: `…TOSWTextureImageEditor…TOSWBlankImage…Width…Height…` |
| `TOSWTexture` (family incl. all subclasses) | **22** | `0x4bf405, 0x4bf41e, 0x4e6e2a, 0x4e6f99, 0x4e6fb2, 0x4e7101, 0x4e7a26, 0x4e7af2, 0x4e7b5e, 0x4e7bea, 0x4e7ca2, 0x4e7cf6, 0x4e7ec9, 0x4e7eda, 0x4e839d, 0x4e83b6, 0x4e84f5, 0x4e850a, 0x4e8a33, 0x4e8a4e, 0x57f84d, 0x57f86a` | `0x4bf400` window: `TOSWTextureHandle / TOSWOcclusionQueryHandle / TOSWGLSLHandle / TOSWShaderHandle / TOSWFragmentShaderHandle / TOSWProgramHandle / TOSWRBOHandle` (handle family, `.CODE` registration run); `0x4e7xxx–0x4e8xxx` run: `TOSWTextureExItem / TOSWTextureLensFlare`-adjacent property names (`Texture/TextureMode/TextureWrap/TextureFormat/FilteringQuality…`); `0x57f848` window: `TOSWTextureLensFlare…Size/Seed/NumSecs/AutoZTest/ImgGlow…` (Delphi published properties) |
| `OSWTexture` (family) | **59** | first page `0x4bf406, 0x4bf41f, 0x4e6c98, 0x4e6d2a, 0x4e6e2b, 0x4e6efb, 0x4e6f9a, 0x4e6fb3, 0x4e6fcd, 0x4e70a4` (+ `0x4e7102/0x4e71d7/0x4e72e9…0x4e9138`, `0x57f84e/0x57f86b`, `.rsrc 0x9586cf/0x9586dc/0x958c20`) | `.CODE` registration runs + `0x4e7f00` property window (`ImageClassName/Image/ImageAlpha/ImageBrightness/ImageGamma/MagFilter/MinFilter/TextureMode/TextureWrap/TextureFormat/Compression…`); `.rsrc 0x9586c0` window: `WConversions/OSWTexture/OSWTextureImageEditors/MOSWContext…` (resource names, `not in executable code`) |
| `ImageClassName` (factory hook) | **1** | `0x4e7f17` | inside `sub_4e72f8` (off 3103); `0x4e7f00` property list above — the Delphi `ImageClassName` published property (factory selector candidate) |
| `TOSWTextureImageAlpha` (enum) | **1** | `0x4e6e2a` (shared) | `0x4e6e00` enum block: `tiaDefault/tiaAlphaFromIntensity/tiaSuperBlackTransparent/tiaLuminance/tiaLuminanceSqrt/tiaOpaque/tiaTopLeftPointColorTransparent/tiaInverseLuminance/tiaInverseLuminanceSqrt` (9 values; `tiaAlphaFromIntensity = 1` per `DEC_U_alpha_pass_quad.md`) |
| Neighbours (prove FULL-binary scope) | `TOSWPictureImage` 2 (`0x4e72b5/0x4e72ce`); `OSWTextureExItem` 2; `TOSWTextureLensFlare` 2; `TOSWPersistentImage` in `0x4e72b0` window | — | `0x4e72b0` window (`…TOSWPictureImage…TOSWPersistentImage…`) shows the family continues past the target names — the 22/59 counts above are the bounded totals for the exact needles, not window samples |

`[D]` The metadata is **Delphi-style** (length-prefixed class names + published-property strings interleaved with init stubs in `.CODE`), consistent with 0 `.?AV` (MSVC RTTI) hits (prior, re-affirmed). Code does not `lea/mov`-reference these names through absolute immediates visible to the builtin xref DB — resolution is through the `sub_4e72f8` registration tables / `sub_8127e0`-style stubs, so **absence of a code xref is expected and proves nothing about runtime use** (same caveat as the `wgl*`/FBO dispatch tables in `DEC_U12_deep §4`).

---

## 3. Ctor / class-descriptor trace — field stores for `C+0x4c` / `texture+8` / `C+0xe0` `[O]/[D]/[U]`

Target offsets (from `DEC_U_hmap_identity.md §4` + `DEC_U12_caller_walk.md §3` + `DEC_U_water_shader_deep.md §6`):

- `C+0x4c` = water/BUILTIN shader object reflection slot (proven READ at `0x6760a8`, writer unknown).
- `[C+0xe0+8]` = hmap height-object GL-name/validity gate at `0x854250` (`C+0xe0 != 0 && [C+0xe0+8] != 0`).
- `texture+8` = texture-object GL-id field hypothesis (the integer `glBindTexture` receives; proven for NEITHER slot — capture only, §6).
- `C+0xe0` = hmap height-object slot; `C+0xdc` = hmap sampler unit (ctor 2); `C+0xd8` = target (ctor `0xde1`).

| Ctor / descriptor candidate | Containing function `[O]` | Body / stores `[O]` | `C+0x4c` / `+8` / `C+0xe0` test |
|---|---|---|---|
| `sub_4e72f8` region (all `0x4e6xxx–0x4e8xxx` class names incl. `0x4e6e2a/0x4e706d/0x4e7f17/0x4e839d/0x4e7a27`) | `sub_4e72f8`, entry `0x4e72f8`, ~9107 blocks (this ticket `native_function_show`) | Giant Delphi registration/init routine; class names embedded as published-property data, not code immediates. Spot VAs are data (`function_find` = inside `sub_4e72f8` offsets 1838/3103) with `total_to: 0` | **No store proven**: no per-class ctor boundary recovered in builtin DB; no `mov [reg+0x4c],…` linked to any `TOSW*` factory in any walked range. A computed-pointer-respecting carve of this giant is still open but cannot settle provenance (§6 note) |
| `sub_8127e0` (sole data-xref owner: `0x812999 mov edx,0x812a44; call 0x4ebf9c`) | `sub_8127e0`, entry `0x8127e0`, 140 insns, `0 direct callers, address_taken: 0` (this ticket) | Full store list this ticket (verbatim displacements): `[ebx+0x3c], +0xa0, +0xa4, +0xa8, +0x148, +0x149, +0xc9, +0xca, +0x154, +0x158, +0x14c, +0x130, +0x134, +0x138, +0x140, +0x144, +0x13c, +0x15c, +0x160, +0x164, +0x12c, +0x168, +0x169, +0x174, +0x170, +0x16c, +0x178, +0x17c, +0x180, +0x181, +0x183, +0x184, +0x188` + `[esi+0x48]/[esi+0x49]` zeroing; reads `[ebx+0x16c]→[eax+0x24]` + `0x400`-sized `sub_4ea3e0/4ea400` calls; no other displacements | **No store found**: zero `+0x4c` writes, zero `+0x8` writes, zero `+0xe0` writes in all 140 insns. The one data edge is a class-table load inside an unreachable-by-static-call init — no `C+0x4c`-field write |
| `sub_812a44` (the referenced table slot itself) | `sub_812a44`, entry `0x812a44`, 49 insns (first bytes `54 4F 53…` = length-prefixed `'TOSWBlankImage'` mis-decoded as code head `push esp/dec edi…`, then real code from `0x812a54`) | Real body: `call 0x404954/0x8127d8/0x8185f0`, `lea [esi+0x130/0x140/0x144]` + `call 0x406e7c` property setters, `mov eax,[esi+0x12c]/[esi+0x16c]`, two virtual `call [ecx-4]`, `call 0x4c980c`, `call 0x40493c` | **No store found**: displacements are `+0x130/+0x140/+0x144/+0x12c/+0x16c` only; no `+0x4c`, no `+0x8`, no `+0xe0` |
| Registrar `sub_7744cc` + factory `sub_7763f8` + feeder `sub_6760a0` (the only proven `C+0x4c`-adjacent chain) | `sub_7744cc` 61 insns / `sub_7763f8` 25 insns, 5 blocks / `sub_6760a0` 15 insns (this ticket) | `sub_7744cc` writes: `[esi+0x38] := sub_425a7c(edi)`, `[array+index*4] := esi` under `[ebx+0x220]` (`+8` array / `+0xc` count), `[esi+0x44] := index`; `sub_7763f8` = `dl`-switched allocator (no GL, no strings); `sub_6760a0`: `C := sub_705944(); S := [C+0x4c] (LOAD @0x6760a8 8b404c); T := [[ [S+0x58]+0x34]+0xcc]; B := [T+0x2bc]; sub_7744cc(B,…)` | **Read, not write**: the sole `+0x4c` hit in all five disassemblies is the LOAD `mov eax,[eax+0x4c] @0x6760a8`; zero `mov [reg+0x4c],…` stores; zero texture-`+8` stores; `+0x40` also absent (renderer+0x40 refuted on this path, re-affirmed) |
| Orphan registration VAs (`0x4bf405/0x4bf41e` handle family, `0x57f84d/0x57f86a` lens-flare family, `.rsrc 0x9586cf/dc`, tables `0x770ba4/0x774374`) | `not inside any discovered function` (11/13 probes) / `not in executable code` (`.rsrc`) — this ticket `native_function_find` | Bytes are length-prefixed names + `G@`-tagged property runs (`0x4bf400`: `TOSWTextureHandle…OSWContext…`; `0x57f848`: `TOSWTextureLensFlare…Size/Seed/…`; `0x770ba0`: `…TOSWRefTextureImage…SV…call…`; `0x774370`: `…TOSWBlankImage…SQ…`) | **No store testable**: data, not code — no ctor body, no field store, `total_to: 0` each. Cannot be promoted to a ctor→field edge |

`[D]` **No `TOSW*` ctor→`C+0x4c` store, no `TOSW*` ctor→`C+0xe0` store, and no `TOSW*` texture-`+8` GL-id store was recovered in any testable ctor body across the FULL binary.** The only `C+0x4c` access on any TOSW-adjacent path is the consumer-direction LOAD at `0x6760a8`, never a construction-direction STORE.

`[D]` The negative is bounded by the builtin DB + file-bytes search (packed/encrypted/runtime-built regions invisible per tool limitation). It is therefore a **static non-link**, not a runtime absence proof: Delphi class resolution through registration tables leaves no absolute-immediate xref by construction, so a runtime instantiation remains possible but **entirely unproven** — exactly why §6 (write-watchpoint + GL capture) is the only settler.

---

## 4. Water-shader link test `[O]/[D]/[U]`

- `[O]` Water-function ranges (priors): `00603d30 / 008520a8 / 00854054 / 00855b38 / 00856530 / 0085756c / 0085787c` (+ getters `0082f060/0082f114`, loader `00739bf8/0082f86c`). None of the §2 VAs (`0x4e6xxx / 0x770ba4 / 0x774374 / 0x812a44 / 0x4bf405 / 0x57f84d / 0x9586cf`) and none of the §3 functions (`sub_4e72f8 / sub_8127e0 / sub_812a44 / sub_7744cc / sub_7763f8 / sub_6760a0`) lies in a water range.
- `[O]` New callees on TOSW-adjacent paths are generic only (`0x4ed28c` selector, `glTexImage2D@thunk`, `0x4c0710/0x4c18c0`-family uploaders, `0x425a7c/0x5a1f74/0x7763f8/0x89dd90` pool/factory, `0x406e7c/0x404954/0x4c980c` Delphi helpers). No call into `FUN_008520a8 / FUN_00854054 / FUN_00603d30` was recovered from any TOSW-linked body.
- `[D]` **No byte-proven link from any `TOSW* / TOSWTexture / OSWTexture` descriptor or ctor to the water shader texture object exists in this pass.** `TOSWRefTextureImage` (name suggestive of reflection) is `[I]` only; `TOSWBlankImage` (the only table with a static data edge) lives in an unreachable-by-static-call init with no water caller; `ImageClassName` (the factory hook) has zero xrefs.

---

## 5. U12 provenance verdict — kept `[U]`, no invented link `[D]`

- `[D]` Byte-proven this ticket: (i) full-binary family counts/VAs/sections §2; (ii) sole static data edge `0x812999 → 0x812a44` inside `0 direct callers` init; (iii) complete store lists of `sub_8127e0/sub_812a44/sub_7744cc/sub_7763f8` with zero `+0x4c/+0x8/+0xe0` writes; (iv) sole `C+0x4c` access is the `0x6760a8` LOAD; (v) no water-anchored caller/writer on any walked edge.
- `[D]` Not proven: which `TOSW*` class (if any) backs `C+0x4c` or `C+0xe0`; `(w,h,format,mips)` literal tuple for either slot; sampler unit actually used for reflection (`C+0xf8`-analogous value never recovered for `C+0x4c`); pool/naming rule; renderer-vs-water identity of `[T+0x2bc]`; whether the reflection texture is an FBO attachment, a framebuffer copy, or a static upload; the numeric GL name behind `texture+8`.
- **U12 stays `[U]` on all provenance values.** `TOSWRefTextureImage` is suggestive `[I]`, not the backer `[O]`; the unitary copy/allocation edges do not imply water use `[D]`; singleton FBO/pbuffer strings do not imply water FBO/pbuffer use `[D]`; the `C+0x4c` read does not imply a `C+0x4c` write `[D]`; zero xrefs do not imply runtime absence `[D]`.

---

## 6. Exact GL texture-id provenance capture + zero-mismatch termination (owner-authorised GPU only)

General gate: water field visible (break `FUN_00603d30` entry); live shader path identified first (U1: `hmapTex` present = DEV file pair, `alphaDepth`/`deepColor` = BUILTIN embedded pair). Captures on the wrong path do not settle U12. No donor work was done by this worker. Each row terminates **only** on the stated zero-mismatch predicate; any mismatch keeps hard-fail (no water), never a fallback.

| # | Settling question | Trace + provenance test | Zero-mismatch termination |
|---|---|---|---|
| U12-A | Reflection provenance: FBO attachment vs framebuffer copy vs static upload | One water-visible frame: (1) break on reflection-bind gate + bit row upload; (2) record `GL_FRAMEBUFFER_BINDING` at bind, `glBindTexture` target/name at unit for the `C+0x4c` object; (3) log all `glGen/Bind/FramebufferTexture2DEXT + CheckFramebufferStatusEXT` with texture-name args; (4) log all `glCopyTexImage2D/SubImage2D` with dst name + src rect; (5) log all `glTexImage2D` uploads incl. `DiffuseWaves*`. Provenance test: bound name ∈ FBO-attachment set earlier in frame → (a); ∈ copy-dst set after main scene → (b); ∈ upload-only set → (c). ≥2 frames + 1 camera move | Wire only the proven class. Any name that is neither attachment, copy-dst, nor upload ⇒ no water. Unknown ⇒ `push_error`, keep `reflectionMapBound=false` |
| U12-R1 | Which `TOSW*` class backs `C+0x4c` (the NB-6 question proper) | Break on the STORE into `C+0x4c` (write-watchpoint from the reflection-bind gate; §3 proves only a *read* at `0x6760a8`, so the write site is still unknown); dump the instance's class name (`ImageClassName` / vtable → `TOSWRefTextureImage` vs `TOSWTextureImage` vs `TOSWBlankImage` vs `TOSWTextureImageEditor` vs non-TOSW) and the constructor's size/format/mipmap args; dump `[tex+8]` GL id at the same break | Port records `{className, w, h, format, mips, glName}` exactly; missing ⇒ no water. Name alone never suffices. Any `TOSW*`→`C+0x4c` claim without this break stays `[U]` |
| U12-R2 | Deterministic pool/naming rule | Across ≥3 runs / map loads: list reflection-name reuse vs size/format; test for pool (same name recycled, free-list, size-keyed map) | A pool rule is wired only if creation order predicts the name in all 3 runs with zero mismatches |
| U12-Q | Copy/alloc argument sources (dst/level/rect/target) | At `call 0x4afb3c` (`0x4ed44c` copy edge): dump the 7 `glCopyTexImage2D` args + bound-read-buffer rect. At `call 0x4afc34` (`0x771b80` allocation edge): dump the 9 `glTexImage2D` args (target, level, internalformat, w, h, border, format, type, pixels). Correlate either name with the U12-R1 `[tex+8]` name | Port copy/alloc path (if ever modelled) uses exactly these; any wildcard ⇒ no water |
| U12-C/B/T/S/P | Reflection size / mips / sampler unit / matrix / waves / pbuffer | At the U12-A break: `glGetTexLevelParameteriv(name,0,GL_TEXTURE_WIDTH/HEIGHT)`, `GL_GENERATE_MIPMAP` state, `GL_TEXTURE_MIN/MAG_FILTER`, `GL_TEXTURE_WRAP_S/T`; hook `glUniform1i` on the `reflectionMap` location + `glActiveTexture` sequence; dump `+0x60` matrix + viewport/scissor; list `DiffuseWaves*` uploads and test `reflectionName == wavesName`; trace `wglCreatePbufferARB / wglMakeContextCurrentARB / wglBindTexImageARB` across the frame | Port `Texture2D` carries the captured W×H; filter/wrap/unit/matrix wired only on identical capture. Any mismatch ⇒ refuse bind. Pbuffer target wired only if the trace shows it |

---

## 7. Explicit non-claims and file discipline

- **No parity claim.** No donor binary executed, no GPU frame captured, no port capture compared. All new readings are `[O]/[D]`; all provenance values are `[U]` with §6 captures.
- **No approximation substituted.** No texture, size, unit, matrix, viewport, class identity, or pool rule is supplied. The port's hard-fail (no water until a real reflection target) is correct.
- **No guess promoted.** `TOSWRefTextureImage` is suggestive `[I]`, not the backer `[O]`; `TOSWBlankImage`'s lone data edge does not imply a water role `[D]`; `ImageClassName`'s presence does not imply a factory call `[D]`; the `C+0x4c` read at `0x6760a8` does not imply a `C+0x4c` write `[D]`; zero code xrefs do not imply runtime absence `[D]`.
- **Deep-decode note (load-bearing for future workers).** The builtin lifter mis-decodes two regions met on this sweep: (i) the `0x812a44` head (length-prefixed `'TOSWBlankImage'` bytes decoded as `push esp/dec edi…` — real code starts at the `0x812a54+` tail); (ii) the `0x4e72f8` giant (9107 blocks; class names are data, not immediates). Future passes must re-verify every VA by stepping/bytes-show, never by trusting head pseudo-C, and must respect the computed-pointer caveat (`ImageClassName` factory dispatch leaves no absolute-immediate xref by construction).
- **Read-only compliance.** Exactly one repo file written: `docs/terrain_swarm_2026-11-26/reports/DEC_U_nb1.md`. No code/shader/asset/config/Godot/git change. No donor file opened for write or executed. Investigation memory was not overwritten by this worker (reads only).

*End of DEC-U-NB1.*
