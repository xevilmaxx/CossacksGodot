---
id: DEC-U12-CALLER-WALK
worker: DEC-U12-CALLER-WALK (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
ticket: "U12 copy-helper caller walk + TOSW* ctor→C+0x4c sweep (class-B B1 static angle)"
date: 2026-11-27
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
labels: [O, D, I, U]
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. No donor binary executed, copied, committed, or captured. No donor file written. No GPU frame captured. All calls pinned document=t_87f0f3c130b0, Deep mode (engine 0.6.1, Ghidra-backed target already open; builtin clean-room lifter used for reads)."
scope_guard: "No repo code/asset/shader/config/test/fixture/result/Godot/git change. Exactly one repo file written: this report."
multi_pass: true
upstream: "DEC_U12_deep.md (U12 verdict [U]); PORT1TO1_u_classify.md B1 (W-U12 static sweep)"
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — U12 reflection provenance stays [U]; hard-fail (no water) endorsed; no approximation."
---

# DEC-U12 caller walk — copy helper + callback-head registrar + `TOSW*` ctor→`C+0x4c` sweep

> Authority: `[O]` = verbatim bytes/text/instruction lifted this ticket, pinned `t_87f0f3c130b0`; `[D]` = arithmetic/control-flow from `[O]`; `[I]` = interpretation; `[U]` = UNVERIFIED with settling experiment in §6. No parity claim. Port keeps hard-fail.

## 0. What was asked and what is delivered

(a) Deep-decomp `FUN_004ed38c` + `FUN_004ed28c` with the engine's Deep-mode read path (builtin linear decode misaligns past the first branch — recovered by cursor-stepped decode). (b) Trace the address-taken callback head at `sub_7715f4` (`0 direct callers, address_taken: 1`) to its registrar and name the receiving object/field; test `renderer+0x40` vs water layer. (c) Enumerate `TOSW*TextureImage` constructors/initializers with VAs and test each for a write into shader-object field `C+0x4c`. (d) Settle U12 provenance only if byte-proven; otherwise keep `[U]` with the exact GL texture-id provenance capture and zero-mismatch termination. No invented link; no parity claim.

**Net result: `[U]` kept on every provenance value.** One new structural fact is `[O]/[D]`: the copy path is a NULL-data `glTexImage2D` reservation (not a `glCopyTexImage2D` water copy on this edge), and the callback head resolves to a **vtable/table slot at `0x7715f4` holding pointer `0x771640`**, consumed by registrar `sub_7744cc` → factory `sub_7763f8`. The receiving container is `[ebx+0x220]` (slots `+8/+0xc`, element field `+0x44`, writer field `+0x38`) fed by `sub_6760a0` which **reads** `C+0x4c` — not renderer+0x40, not a proven water layer. No `TOSW*` ctor→`C+0x4c` store was found.

---

## 1. Pass ledger (owner rule ≤5 passes/function; every pass logged; all NEW this ticket, all pinned `t_87f0f3c130b0`)

| Pass | Question | Fresh reads this ticket | Result |
|---|---|---|---|
| P1 | Deep-decomp `sub_4ed28c` (= `FUN_004ed28c`) + gap body at `0x4ed38c` (`FUN_004ed38c`, undiscovered by builtin) | `native_functions_decompile [0x4ed28c, 0x4ed38c]` → `ev_fe701c80…` (1 ok / 1 fail `No function at 0x4ed38c`); `native_function_disassemble sub_4ed28c` → `ev_2d15d1ea…` (87 insns); `native_bytes_show 0x4ed38c+512` → `ev_e7832deb…`; `native_function_find 0x4ed38c` → `ev_319339f1…` (not inside any discovered function); `native_address_show 0x4ed38c` → `ev_fe07ac4c…`; `native_instruction_show 0x4ed38c/0x4ed44c` → `ev_7819208b…/ev_ea31675a…`; cursor-stepped decode `0x4ed38c→0x4ed5c0` (~140 insns, this report §2) | **Accepted as bounded**: `sub_4ed28c` = pure selector returning internalformat in `eax/ebx` (no GL call); gap `0x4ed38c…` = real loader with `call 0x4ed28c`, `call 0x4ed258/0x4ed264`, `glCopyTexImage2D` via `call 0x4afb3c` at `0x4ed44c`, `glTexImage2D`-family virtuals, float compares; argument shapes recovered (§2) |
| P2 | Callback head `sub_7715f4` — callees, callers, registrar | `native_function_callers_list sub_7715f4` → `ev_ceecb0fa…` (0 direct, `address_taken: 1`); `native_function_study sub_7715f4 summary` → `ev_db7bd0ec…` (119 blocks/594 insns/19 callees/10 unresolved); `native_function_callees_list` → `ev_72a11f26…` (incl. `call 0x4ed28c @0x771b50`, `glTexImage2D@thunk @0x771b80`, `sub_771c0c`, `sub_4ed284`, `sub_4c0710/4c18c0`); `native_function_references_list incoming` → `ev_90dafcbb…` (`0x774506 data→0x7715f4` in `sub_7744cc`); `native_xrefs_list 0x7715f4` → `ev_f626377a…` (`total_to: 1`, same edge) | **Accepted**: single static registrar edge `sub_7744cc:0x774506 —data→ 0x7715f4`; head has no direct caller |
| P3 | Registrar `sub_7744cc` + its caller; receiving object/field; renderer+0x40 test | `native_function_disassemble sub_7744cc` → `ev_b6619e7f…` (61 insns, full listing §3); `native_functions_decompile [sub_7744cc, sub_7715f4]` → `ev_9f110834…`; `native_function_callers_list sub_7744cc` → `ev_959fe4a1…` (1 caller `sub_6760a0 @0x6760b9`); `native_bytes_show 0x7715f4+64` (this ticket, §3); `native_function_disassemble sub_6760a0` (§4, 12 insns incl. `mov eax,[eax+0x4c] @0x6760a8`); `native_function_disassemble sub_705944 / sub_710248` (§4) | **Accepted as bounded**: registrar stores factory result into `[ebx+0x220]`-rooted array (`+8` data, `+0xc` count, `[esi+0x44]` index, `[esi+0x38]` writer); feeder `sub_6760a0` reads `C+0x4c`; **no `+0x40` field** on this path |
| P4 | `TOSW*` family enumeration + ctor→`C+0x4c` sweep | `native_bytes_find TOSWTextureImage` (4 hits `0x4e6e2a/0x4e6f99/0x4e6fb2/0x4e7101`) / `TOSWRefTextureImage` (3 hits `0x4e706d/0x4e7086/0x770ba4`) / `TOSWBlankImage` (4 hits `0x4e71a9/0x4e71be/0x774374/0x812a44`) / `TOSWTexture` (22 hits, first page §5); `native_xrefs_list` on all 11 class-name VAs (10× `total_to: 0`, 1× `0x812a44 ←0x812999 data in sub_8127e0`); `native_function_show sub_4e72f8` (giant init routine, ~9107 blocks); `native_bytes_show 0x770ba0/0x774370/0x812a40` (class-table bytes); `native_function_callers_list sub_8127e0` (`0 direct callers`) | **Accepted**: Delphi-style class-name tables with **zero code xrefs** in builtin DB; no ctor→`C+0x4c` store found → `[U]` (U12-R1/R2 stay open) |
| P5 | Water-anchoring cross-check | Water-function ranges from prior tickets (`00603d30/00854054/00856530/0085756c/0085787c/00855b38`); none of the new VAs (`0x4ed28c/0x4ed38c/0x7715f4/0x7744cc/0x6760a0/0x4e72f8/TOSW*` tables) lies in a water range; new callees are generic (`glTexImage2D`, `glHint`, `0x4ed2xx`, `0x4cxxxx`, `0x425a7c/0x5a1f74/0x7763f8/0x89dd90`) | **Accepted**: no water-scoped caller/writer recovered → `[U]` |

No function consumed more than 5 passes. Prior-ticket pseudocode (`ev_8096…/ev_2b51…`) was used only as hypothesis, never re-cited as evidence.

---

## 2. (a) `FUN_004ed28c` + `FUN_004ed38c` — cursor-stepped Deep decode `[O]/[D]`

### 2.1 `sub_4ed28c` (entry `0x4ed28c`, end `0x4ed38a`, 87 insns) — pure format selector, no GL call `[O]/[D]`

- `[O]` `ev_2d15d1ea…` full assembly; `ev_fe701c80…` pseudo-C. Prologue `push ebx/esi/ecx; mov esi,eax` — `eax` in = texture/image object `C`.
- `[O]` Reads: `[esi+0x1f]` (byte, lines `0x4ed291–0x4ed2b4`); globals `[0x8f5aa4]/[0x8fc438]/[0x8f5aa8]/[0x8fbab4]/tables `[0x8f5ad4]/[0x8f5b0c]`; `[esi+0x50]` (byte); calls `sub_4ed24c` (×2) + `sub_4ed258` (×1) as predicates.
- `[O]` Writes: `ebx` = selected internalformat/code; `eax=ebx` returned. Observed constants: `glHint(0x84ef, 0x1100/0x1102/0x1101)` paths (lines `0x4ed30c/0x4ed31d/0x4ed32e`); table loads `[eax*4+0x8f5ad4]` vs `[eax*4+0x8f5b0c]`; special-cased `0x888a/0x888b` (depth/stencil-shaped codes) when `[0x8fbab4]→0` and `stack_0−13 ∈ {0,1}`.
- `[D]` `sub_4ed28c` issues **no GL call** and touches **no `C+0x4c`-shaped store**; it is the `internalformat` (and hint-mode) subroutine consumed by the gap loader at `0x4ed413` (`call 0x4ed28c`, `mov edi,eax`) and by the `0x771b50` texture-reservation path (§3). Argument shape: `(C: [C+0x1f], [C+0x50], globals) → internalformat:u32`.

### 2.2 Gap body `0x4ed38c…` (= `FUN_004ed38c`, undiscovered) — real loader recovered by stepping `[O]/[D]`

Builtin `native_function_find 0x4ed38c` → null (`ev_319339f1…`); `native_xrefs_list 0x4ed38c` → `total_to: 0` (`ev_e9493322…`). The linear `instruction_show` at a guessed VA misaligns (prior ticket), so this worker stepped with `native_cursor_forward` from `0x4ed38c` to `0x4ed5c0`. Verbatim edge list (VA: text [bytes], condensed; full walk retained in session evidence):

- `[O]` `0x4ed38c push ebp [55]; 0x4ed38d mov ebp,esp [8bec]; 0x4ed38f push ecx [51]; 0x4ed390 push ebx [53]; 0x4ed391 push esi [56]; 0x4ed392 push edi [57]; 0x4ed393 mov esi,edx [8bf2]; 0x4ed395 mov [ebp-4],eax [8945fc]` — Delphi-register prologue: `eax`=self `C`, `edx`=second arg → `esi`; `C` spilled to `[ebp-4]`.
- `[O]` `0x4ed398 mov eax,[ebp-4]; 0x4ed39b cmp word [eax+0x6a],0 [6683786a00]; 0x4ed3a0 je 0x4ed3b5 [7413]` — first branch on `[C+0x6a]`.
  - Taken (`==0`): `0x4ed3a2 mov ebx,[ebp-4]; 0x4ed3a5 mov ecx,esi; 0x4ed3a7 mov edx,[ebp-4]; 0x4ed3aa mov eax,[ebx+0x6c]; 0x4ed3ad call [ebx+0x68] [ff5368]` (virtual), then `jmp 0x4ed64e` (epilogue) — early virtual path, no GL.
  - Fall-through: `0x4ed3b5 mov eax,[ebp-4]; 0x4ed3b8 call 0x4ed264 [e8a7feffff]; 0x4ed3bd test al,al; 0x4ed3bf je 0x4ed410` — predicate `sub_4ed264`.
- `[O]` `0x4ed3c1–0x4ed40b` (predicate true): paired virtual calls on `[C+0x24]`: `call [eax+0x30]` (get), `call [ecx+0x40]` / `call [edx+0x1c]` / `call [edx+0x18]` with stores `[edx+0x5c]=eax; [edx+0x60]=eax` — object-protocol getters, **not GL**; then `jmp 0x4ed64e`.
- `[O]` `0x4ed410 mov eax,[ebp-4]; 0x4ed413 call 0x4ed28c [e874feffff]; 0x4ed418 mov edi,eax` — **the selector result is captured into `edi`** (= `internalformat` for the copy below). `0x4ed41a call 0x4ed258; test; je 0x4ed478`.
- `[O]` Copy branch (`0x4ed426–0x4ed473`): `push 0; mov eax,[C+0x24]; call [edx+0x18]` (width) `push eax; mov eax,[C+0x24]; call [edx+0x1c]` (height) `push eax; push 0; push 0; push edi; push 0; push 0xde1 [68e10d0000]; 0x4ed44c call 0x4afb3c [e8eb26fcff]` — then the same `[C+0x24]` virtual pair + `[edx+0x5c/0x60]` stores; `jmp 0x4ed64e`.
  - `[D]` `0x4ed44c` target arithmetic: `0x4ed44c+5+0xfffc26eb = 0x4afb3c` (`ev_ea31675a…`); `0x4afb3c` = `jmp [__imp_glCopyTexImage2D]` (prior `ev_50fe26b2…`). Push-shape (last-arg-first): `pixels=0? , …, edi(internalformat from sub_4ed28c), 0, 0xde1`. `0x0de1 = GL_TEXTURE_2D`. So the call is `glCopyTexImage2D(GL_TEXTURE_2D, level=0, internalformat=edi, x=0, y=0, w=[C+0x24]→+0x18, h=[C+0x24]→+0x1c)` — a **framebuffer→texture copy reservation**. Full 7-arg tuple + bound-read-buffer rect still needs the §6 GPU break (U12-Q); the static shape alone does not name dst-name/src-rect.
- `[O]` Non-copy branch (`0x4ed478–0x4ed585`): `mov edx,esi; call [ecx+0x38]` on `[C+0x24]`; `mov ebx,eax; test; je epilogue`; `call 0x4c26e4; test; jne epilogue`; `[C+0x1f]==0x0c? / [C+0x1d]` bit-pushes (`sub dl,2 / sub al,3` → `edx` flags); `call 0x4c2bb8(ebx,ecx,edx,[C+0xd8])`; `movzx eax,[C+0x28]; cmp 8; ja 0x4ed586; jmp [eax*4+0x4ed4f5]` computed jump over 9 `call 0x4c2xxx(ebx…)` cases (`0x4c275c/0x4c2868/0x4c27e4/0x4c2890/0x4c275c…`) — uploader family dispatch on `[C+0x28]`.
- `[O]` `0x4ed586–0x4ed5bf+`: `fld [C+0x2c]; fcomp [0x4ed654]; fnstsw/sahf; je …; push [C+0x2c]; call 0x4c2910(ebx)`; same for `[C+0x30]` — float param compares/uploads; falls into the `0x4ed64e` epilogue (not fully walked; stop address reached, no GL import in walked range beyond `0x4afb3c`).
- `[D]` Argument shapes: `FUN_004ed38c(C: +0x24 virtuals→w/h, +0x28 uploader index, +0x2c/+0x30 floats, +0x1f/+0x1d flags, +0x6a/+0x6c/+0x68 virtuals, +0xd8 pushed dword; esi/edx second arg; internalformat := FUN_004ed28c(C))`. The **callback registration site is not in this function** — no `lea/push imm32` of `0x4ed38c` exists (`push/mov`-imm scans `68 8c d3 4e 00 / b8 8c d3 4e 00` = 0 hits, prior ticket, re-affirmed); entry is fall-through/virtual from `sub_4ed28c`'s tail region, consistent with one discovered container ending at `0x4ed38b`.

### 2.3 Registrar-side texture reservation at `0x771b50…0x771b85` (same engine, second edge) `[O]/[D]`

Cursor-stepped from `0x771b14` (prior §1 P2 callees). Verbatim window around the GL call (raw hex `ev` this ticket §1 P3-chain: `e837b7d7ff 890424 6a00 6801140000 6808190000 6a00 8b4624 8b10 ff5218 50 8b4624 8b10 ff521c 50 8b442418 50 6a00 55 e8afe0d3ff …`):

- `[O]` `0x771b50 call 0x4ed28c [e837b7d7ff]` (= `sub_4ed28c`, same selector); `0x771b55 mov [esp],eax [890424]` — selector result spilled.
- `[O]` Push sequence (last-arg-first): `6a00` (pixels=NULL) ; `68 01140000` (`0x1401`) ; `68 08190000` (`0x1908`) ; `6a00` ; `8b4624/8b10/ff5218` (width `=[esi+0x24]→[edx+0x18]`) `50` ; `8b4624/8b10/ff521c` (height `→+0x1c`) `50` ; `8b442418` (reload spilled selector = internalformat) `50` ; `6a00` (level=0) ; `55` (push ebp = target).
- `[O]` `0x771b80 call 0x4afc34` = `glTexImage2D@thunk` (callee list `ev_72a11f26…`: `glTexImage2D@thunk site 0x771b80 target 0x4afc34`).
- `[D]` Reconstructed call: `glTexImage2D(target=ebp, level=0, internalformat=sub_4ed28c(esi), width=[esi+0x24]→+0x18, height=[esi+0x24]→+0x1c, border=0, format=0x1908 (GL_RGBA), type=0x1401 (GL_UNSIGNED_BYTE), pixels=NULL)`. This is a **blank-texture allocation**, not a copy; `ebp` on entry = `ecx` (object `esi/ebx` family, §3) — the numeric target enum (e.g. `0x0DE1`) is the pushed `ebp` value itself and is only settled by the §6 trace, never assumed here.
- `[D]` Two distinct GL edges now share one selector: (i) `0x4ed44c → glCopyTexImage2D` (copy, NULL-pixel unknown → framebuffer source, §2.2); (ii) `0x771b80 → glTexImage2D` (allocation, pixels=NULL, §2.3). Neither edge is water-anchored statically.

---

## 3. (b) Callback head → registrar → receiving field `[O]/[D]/[U]`

### 3.1 The `0x7715f4` label is a table slot, not a code entry `[O]/[D]`

- `[O]` `native_bytes_show 0x7715f4+64` (this ticket): hex `40167700 00000000… 40167700 04800000 54114000 d0474000 dc474000 e0474000 e4474000 d8474000` — first dword = `40 16 77 00` = **`0x00771640` little-endian**, i.e. a pointer, followed by zeros and a repeated pointer/table run (`0x771640`, `0x411154`, `0x4747d0/dc…`).
- `[O]` `native_function_show sub_7715f4`: `discovered_by: code_pointer`, `entry 0x7715f4`, `end 0x771bdf`, 119 blocks/594 insns — but body ranges start with data-looking runs `0x7715f4–0x7715f8 / 0x7715f8–0x771618 / 0x771618–0x771646` before real code; `native_instruction_show 0x771640` decodes `or edx,[eax+ebx*2+0x50] [0b545850]` — table bytes mis-decoded as code.
- `[D]` The builtin function `sub_7715f4` **conflates a callback/vtable slot at `0x7715f4` (holding `0x771640`) with the real code body** that contains `0x771b50/0x771b80` (`native_function_find 0x771b50 → entry 0x7715f4 offset 1372`). The `address_taken: 1` (`ev_ceecb0fa…`) is therefore a **table-slot reference**, and the single incoming data edge `0x774506 —data→ 0x7715f4` (`ev_90dafcbb…`, `ev_f626377a… total_to: 1`) reads that slot, not a code caller.

### 3.2 Registrar `sub_7744cc` (entry `0x7744cc`, 61 insns, 1 caller) `[O]/[D]`

Full listing `ev_b6619e7f…` (verbatim, condensed operands):

```
0x7744cc push ebp; mov ebp,esp; push ecx/ebx/esi/edi; mov [ebp-4],edx; mov ebx,eax
0x7744db call 0x4058b0
0x7744e2 push ebp; push 0x774582; push fs:[0]; mov fs:[0],esp      ; SEH
0x7744ee xor esi,esi
0x7744f0 mov edx,[ebp-4]; mov eax,[ebx+0x21c]; call 0x5a1f74     ; (ebx+0x21c)->factory arg
0x7744fe mov edi,eax; test edi,edi; je 0x77456c
0x774504 mov dl,1
0x774506 mov eax,[0x7715f4]        ; [O] load table slot (=0x771640 per §3.1)
0x77450b call 0x7763f8             ; [O] factory; (eax=slot-value, dl=1)
0x774510 mov esi,eax               ; [O] new texture object
0x774512 mov eax,edi; call 0x425a7c; 0x774519 mov [esi+0x38],eax ; [O] writer → +0x38
0x77451c mov eax,ebx; call 0x774478; test eax,eax; jl 0x774552
0x774527 mov edx,[ebx+0x220]; cmp eax,[edx+0xc]; jge 0x774552
0x774532 mov edx,[ebx+0x220]; mov edx,[edx+8]; cmp [edx+eax*4],0; jne 0x774552
0x774541 mov edx,[ebx+0x220]; mov edx,[edx+8]; mov [edx+eax*4],esi ; [O] container store
0x77454d mov [esi+0x44],eax         ; [O] element index → +0x44
0x774552 mov edx,esi; mov eax,[ebx+0x220]; call 0x89dd90 ; fallback append path
0x77455f mov eax,[ebx+0x220]; mov eax,[eax+0xc]; dec eax; mov [esi+0x44],eax
0x77456c SEH restore; ret
```

- `[D]` Receiving object/field: container root = **`[ebx+0x220]`** (struct with `+8` = element-pointer array, `+0xc` = count/capacity); element = factory result `esi` (from `sub_7763f8`); store = `[array + index*4] := esi`, `index` = `sub_774478(ebx)` return clamped to count, mirrored into **`[esi+0x44]`**; second writer **`[esi+0x38] := sub_425a7c(edi)`**. No `+0x40` field appears anywhere in this registrar (`grep` over the 61-insn listing: displacements are `+0x21c/+0x220/+8/+0xc/+0x38/+0x44` only).
- `[D]` `sub_7763f8` (entry `0x7763f8`, 25 insns, 1 caller = `0x77450b`) is the allocator/factory shared with the `0x7715f4`-slot value; its body (`84d27408…`, this ticket §1) is a small `dl`-switched constructor (observed `cmp …,0x740?` ladder), not a GL call site itself.
- `[U]` Whether `[ebx+0x220]` is a renderer pool, a texture-manager list, or a water layer is **not byte-proven**: `ebx` on entry = `eax` from caller `sub_6760a0` (§4). The registrar only proves the *shape* (indexed pool + `+0x38/+0x44` writers), never the owner type.

### 3.3 Caller of the registrar: `sub_6760a0` — a `C+0x4c` **read**, not a write `[O]/[D]`

- `[O]` `native_function_disassemble sub_6760a0` (this ticket):
  `0x6760a0 push ebp; mov ebp,esp; 0x6760a3 call 0x705944; 0x6760a8 mov eax,[eax+0x4c] [8b404c]; 0x6760ab call 0x710248; 0x6760b0 mov eax,[eax+0x2bc]; 0x6760b6 mov edx,[ebp+8]; 0x6760b9 call 0x7744cc; test eax,eax; je …; mov eax,[eax+0x44]; … or eax,-1; ret 4`.
- `[O]` `sub_705944`: singleton getter (`cmp [0x905134],0; … call 0x5192f8; mov [0x905134],eax; mov eax,[0x905134]; ret`) — global-context object `C` (renderer/engine singleton `[I]`, type unproven `[U]`).
- `[O]` `sub_710248`: `mov eax,[eax+0x58]; mov eax,[eax+0x34]; mov eax,[eax+0xcc]; ret` — three-hop accessor from the `C+0x4c` shader object to the `+0x2bc` object that becomes `ebx` (registrar container owner).
- `[D]` Chain: `C := sub_705944(); S := [C+0x4c]; T := [[ [S+0x58]+0x34]+0xcc]; B := [T+0x2bc]; sub_7744cc(B, edx=[ebp+8])`. The `C+0x4c` access is a **load** (`8b404c`), never a store on this path; the registrar's writes go to `[B+0x220]`-pool/`[esi+0x38/0x44]`, never back into `C+0x4c`. A constructor→`C+0x4c` link is therefore **absent here** — the opposite direction (consumer read) is what the bytes prove.
- `[D]` Renderer+0x40 test: **negative**. No `+0x40` displacement occurs in `sub_7744cc`, `sub_6760a0`, `sub_705944`, `sub_710248`, or the `0x771b50…0x771b85` reservation window. The only `0x40`-adjacent bytes in the record are mis-decoded table bytes (`[ecx+edx+0x40]` in the garbage head-decomp of `sub_7715f4`, `ev_9f110834…`), which §3.1 retires as table data, not code. `renderer+0x40` as the receiver is **refuted on this path**; water-layer identity is **unproven** (see §6 capture).

---

## 4. (c) `TOSW*` constructor/initializer sweep — VAs + `C+0x4c` test `[O]/[D]/[U]`

| Class string | VAs (`.CODE`, NUL-terminated) | Code xrefs (builtin DB) | Ctor/initializer VA | `C+0x4c`-store test |
|---|---|---|---|---|
| `TOSWTextureImage` | `0x4e6e2a/0x4e6f99/0x4e6fb2/0x4e7101` (4 hits, `native_bytes_find` this ticket) | `total_to: 0` each (this ticket §1 P4) | `sub_4e72f8` region (giant Delphi init, `entry 0x4e72f8`, ~9107 blocks; class names embedded as published-property data: `textureFileName:String`, `TOSWTextureImageAlpha` enum `tiaDefault…tiaInverseLuminanceSqrt`, `ImageClassName/Image/ImageAlpha`) — no per-class ctor boundary recovered in builtin DB | **No store found**: zero code refs to any of the 4 VAs; no `mov [reg+0x4c],…` linked to a `TOSWTextureImage` factory in any walked range |
| `TOSWTextureImageToN` | `0x4e6fb2` (1 hit, shared with above) | `total_to: 0` | same `sub_4e72f8` region | **No store found** (same) |
| `TOSWRefTextureImage` | `0x4e706d/0x4e7086` (+ `0x770ba4` near `sub_770bxx` table: `13 00 00 00 'TOSWRefTextureImage' 00 53 56…`, `ev_ffadf2db…`) | `total_to: 0` each | `0x770ba4` sits in a class-registration table (preceded by length dword `0x13`, followed by `SV`-tagged init stubs), not a ctor body; `sub_4e72f8` region holds the other two | **No store found**; the suggestive name is `[I]`, never `[O]` for reflection backing |
| `TOSWBlankImage` | `0x4e71a9/0x4e71be/0x774374` (table: `0e 00 00 00 'TOSWBlankImage' 00…`, `ev_3910aae8…`) + `0x812a44` | `total_to: 0/0/0`, `0x812a44 ←0x812999 data (in sub_8127e0)` (sole non-zero edge) | `sub_8127e0` (entry `0x8127e0`, 140 insns, `0 direct callers`, 26 calls-out; bytes at `0x812a40`: `0e000000 'TOSWBlankImage' 00 53 56 e8…` — class-table + stub calls) | **No store found**: the one data edge is a class-table load inside an unreachable-by-static-call init (`0 direct callers`); no `+0x4c` write in `sub_8127e0`'s 5 body ranges per refs walk |
| `TOSWTexture` / `OSWTexture` (family) | 22 `TOSWTexture` hits incl. `0x4bf405/0x4bf41e` + CODE `0x4e6xxx–0x4e8xxx` run; `OSWTexture` 59-hit family (prior, re-affirmed by `native_bytes_find` paging) | class-name VAs: `total_to: 0` (all tested) | `sub_4e72f8` (Delphi registration giant) + `0x4e7e80`-region property names (`ImageClassName/Image/ImageAlpha`, prior `ev`, not re-cited) | **No store found** |

- `[D]` The `TOSW*` metadata is **Delphi-style** (length-prefixed class names + published-property strings interleaved with init stubs in `.CODE`), consistent with `0 .?AV` (MSVC RTTI) hits (prior, re-affirmed). Code does not `lea/mov`-reference these names through absolute immediates visible to a packed-byte scan or the builtin xref DB — resolution is through the `sub_4e72f8` registration tables / `sub_8127e0`-style stubs, so **absence of a code xref is expected and proves nothing about runtime use** (same caveat as the `wgl*`/FBO dispatch tables in `DEC_U12_deep §4`).
- `[U]` Open items U12-R1/R2 (which `TOSW*` class backs `C+0x4c`; pool/naming rule) therefore survive with **zero static anchors**: no constructor VA, no `(w,h,format,mips)` literal tuple, and no `C+0x4c`-field store was recovered in any tested initializer. A whole-binary ctor→field-store sweep remains fenced as future static work, but it cannot settle provenance — only the §6 write-watchpoint can.

---

## 5. (d) U12 provenance verdict — kept `[U]`, no invented link `[D]`

- `[D]` Byte-proven (this ticket): (i) unitary static copy edge `0x4ed44c → 0x4afb3c → __imp_glCopyTexImage2D` fed by `FUN_004ed38c`'s `GL_TEXTURE_2D/internalformat=edi` branch; (ii) sibling allocation edge `0x771b80 → glTexImage2D(target=ebp,…,GL_RGBA/GL_UNSIGNED_BYTE,NULL)` sharing selector `sub_4ed28c`; (iii) registrar `sub_7744cc` pool shape (`[B+0x220]`/`+0x38`/`+0x44`); (iv) feeder `sub_6760a0` **reads** `C+0x4c` through a singleton→`+0x58→+0x34→+0xcc→+0x2bc` chain; (v) `TOSW*` class family localized with zero ctor→`C+0x4c` links; (vi) no water-anchored caller on any walked edge (code lives at `0x4e…/0x77…/0x67…`, water at `0x60…/0x85…`).
- `[D]` Not proven: which GL object (if any) backs reflection; size/mips/unit/matrix; whether the copy ever fires on a water frame; whether `TOSWRefTextureImage` (or any `TOSW*`) instantiates `C+0x4c`; any pool/naming rule; renderer-vs-water identity of `B=[T+0x2bc]`. The unitary copy edge does **not** imply water use; singleton FBO/pbuffer strings do **not** imply water FBO/pbuffer use; the `Ref` name does **not** imply reflection backing; the `C+0x4c` read does **not** imply a `C+0x4c` write.
- **U12 stays `[U]` on all provenance values.** The port's current behaviour (hard-fail, no water, no grey fallback, no assumed unit/size/matrix, no `bind_reflection_map()` call) is endorsed as donor-faithful. No texture, size, unit, matrix, class identity, or pool rule is supplied by this report.

---

## 6. Exact GL texture-id provenance capture + zero-mismatch termination (owner-authorised GPU only)

General gate: water field visible (break on `FUN_00603d30` entry); live shader path identified first (U1: `hmapTex` present = DEV file pair, `alphaDepth`/`deepColor` = BUILTIN embedded pair). Captures on the wrong path do not settle U12. No donor work was done by this worker. Each row terminates **only** on the stated zero-mismatch predicate; any mismatch keeps hard-fail (no water), never a fallback.

| # | Settling question | Trace + provenance test | Zero-mismatch termination |
|---|---|---|---|
| U12-A | Reflection provenance: FBO attachment vs framebuffer copy vs static upload | One water-visible frame: (1) break on reflection-bind gate + bit `7c.01` upload; (2) record `GL_FRAMEBUFFER_BINDING` at bind, `glBindTexture` target/name at unit `C+0xf8`; (3) log all `glGen/Bind/FramebufferTexture2DEXT + CheckFramebufferStatusEXT` with texture-name args; (4) log all `glCopyTexImage2D/SubImage2D` with dst name + src rect (expect the `0x4ed44c` shape `target=0xDE1/internalformat=edi` if (a)); (5) log all `glTexImage2D` uploads incl. `DiffuseWaves*` (expect the `0x771b80` shape `RGBA/UNSIGNED_BYTE/NULL` if reservation path fires). Provenance test: bound name ∈ FBO-attachment set earlier in frame → (b); ∈ copy-dst set after main scene → (a); ∈ upload-only set → (c). ≥2 frames + 1 camera move. Also back-trace the issuing thread at `0x4ed44c`/`0x771b80` to confirm/retire each hypothesis. | Wire only the proven class. Any name that is neither attachment, copy-dst, nor upload ⇒ no water. Unknown ⇒ `push_error`, keep `reflectionMapBound=false`. |
| U12-A2 | Head of the copy/alloc chain (table slot `0x7715f4`→`0x771640`, registrar `sub_7744cc`, feeder `sub_6760a0`) | In the same capture, breakpoint `0x771b50` (`call 0x4ed28c`) + `0x771b80` (`glTexImage2D`) + `0x4ed44c` (copy) + write-watchpoint on slot `0x7715f4`: name the callback/vtable that enters the `0x771640`-body and the `sub_7744cc` container owner `B` (`[T+0x2bc]` identity: renderer pool vs water layer). Null result (neither fires while water is visible) retires the static-copy/alloc hypothesis for the water path. | If neither fires while water is visible, the port must not model reflection as copy or as this allocation. |
| U12-B | Reflection size / mipmap / sampler state | At the same break: `glGetTexLevelParameteriv(name,0,GL_TEXTURE_WIDTH/HEIGHT)`, `GL_GENERATE_MIPMAP` / `glGenerateMipmapEXT` on that name, `GL_TEXTURE_MIN/MAG_FILTER`, `GL_TEXTURE_WRAP_S/T`. | Port `Texture2D` must carry the captured W×H; filter/wrap must equal capture. Any mismatch ⇒ refuse bind. |
| U12-C | Sampler unit actually used (`C+0xf8` runtime value) | Hook `glUniform1i` on the `reflectionMap` location; record int pushed + `glActiveTexture(GL_TEXTURE0+u)` + `glBindTexture` sequence. | Port sets exactly the captured unit. Unset ⇒ hard-fail. No assumed `TEXTURE0/1/2`. |
| U12-T | Projective matrix (`FUN_004cdd9c(…,0x60,…)` + viewport) | Break on matrix build + `FUN_004cdbdc`; dump 4×4 at caller `+0x60` and `glViewport/glScissor` + bound-FBO state immediately before/after. Cross-check against uploaded `Mat4` if any. Level + pitched camera. | Port accepts only the captured path/verbatim matrix. `*0.5+0.5` bias stays labelled scaffolding, unreachable without `reflectionMapBound=true`. |
| U12-S | `DiffuseWaves*` role | List all texture uploads by name/size/source (`DiffuseWaves0/2` → `glTexImage2D`); test `reflectionName == wavesName`. | If distinct, waves stay a separate sampler; if identical, record the single name. Never alias without the test. |
| U12-P | pbuffer / second-context hypothesis | Trace `wglCreatePbufferARB / wglMakeContextCurrentARB / wglBindTexImageARB / wglChoosePixelFormatARB / wglMakeCurrent` across one water frame; correlate any switch with the reflection name. | Pbuffer target wired only if the trace shows it; otherwise the port must not create a surface. |
| U12-R1 | Which `TOSW*` class backs `C+0x4c` | Break on the store into `C+0x4c` (write-watchpoint from the reflection-bind gate; note §3 proves a *read* at `0x6760a8`, so the write site is still unknown); dump the instance's class name (`ImageClassName` / vtable → `TOSWRefTextureImage` vs `TOSWTextureImage` vs `TOSWBlankImage`) and the constructor's size/format/mipmap args. | Port records `{className, w, h, format, mips}` exactly; missing ⇒ no water. Name alone never suffices. |
| U12-R2 | Deterministic pool/naming rule | Across ≥3 runs / map loads: list reflection-name reuse vs size/format; test for pool (same name recycled, free-list, size-keyed map). | A pool rule is wired only if creation order predicts the name in all 3 runs with zero mismatches. |
| U12-Q | Copy/alloc argument sources (dst/level/rect/target) | At `call 0x4afb3c` (`0x4ed44c`): dump the 7 `glCopyTexImage2D` args (target, level, internalformat, x, y, w, h) + bound-read-buffer rect. At `call 0x4afc34` (`0x771b80`): dump the 9 `glTexImage2D` args (target, level, internalformat, w, h, border, format, type, pixels). | Port copy/alloc path (if ever modelled) uses exactly these; any wildcard ⇒ no water. |

---

## 7. Explicit non-claims and file discipline

- **No parity claim.** No donor binary executed, no GPU frame captured, no port capture compared. All new readings are `[O]/[D]`; all provenance values are `[U]` with §6 experiments.
- **No approximation substituted.** No texture, size, unit, matrix, viewport, class identity, or pool rule is supplied. The port's hard-fail (no water until a real reflection target) is correct.
- **No guess promoted.** `TOSWRefTextureImage` is suggestive `[I]`, not the backer `[O]`; the unitary copy edge does not imply water use `[D]`; singleton FBO/pbuffer strings do not imply water FBO/pbuffer use `[D]`; the `C+0x4c` read at `0x6760a8` does not imply a `C+0x4c` write `[D]`; the garbage head-decomp `+0x40` does not imply a renderer field `[D]`.
- **Deep-decode note (load-bearing for future workers).** The builtin clean-room lifter mis-decodes two regions: (i) the undiscovered gap `0x4ed38c…` (linear `instruction_show` at guessed VAs degrades into `insb/dec edi…` past the first branch) — use `native_cursor_forward` stepping from the byte-true prologue `55 8B EC 51 53 56 57 8B F2 89 45 FC…` as done in §2; (ii) the `0x7715f4` table head (first ~0x80 bytes are a pointer table headed by `0x771640`, decoded as `inc/add…` garbage) — the trustworthy code starts at the `0x771b14+` tail (texture reservation) and the registrar `sub_7744cc` listing. Future passes must re-verify every VA by stepping, never by trusting the head pseudo-C.
- **Read-only compliance.** Exactly one repo file written: `docs/terrain_swarm_2026-11-26/reports/DEC_U12_caller_walk.md`. No code/shader/asset/config/Godot/git change. No donor file opened for write or executed. Investigation memory was not overwritten by this worker (reads only; no brief/plan/hypothesis/finding/handoff writes).

*End of DEC-U12-CALLER-WALK.*
