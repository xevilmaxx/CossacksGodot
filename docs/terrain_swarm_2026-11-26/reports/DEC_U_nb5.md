---
id: DEC-U-NB5-COPY-CHAIN
ticket: "TERRAIN-SWARM-2026-11-26 / NB-5 U-copy-site native side (refines B8; from PORT1TO1_b_angle_index.md §3 NB-5 via DEC_U_coll_census_deep.md §4.3)"
date: 2026-11-27
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_nb5.md
target: "C:\\Games\\Cossacks 3\\cossacks.exe — t_87f0f3c130b0 (sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c), explicit document on EVERY native call"
labels: [O, D, I, U, "RUNTIME PROBE", "PORT INSTRUCTION"]
parity_claim: false
scope_guard: "Donor READ ONLY. No donor binary executed, copied, committed, modified or debugged. No repo code/shader/config/asset/test/Godot/git edit. No Craft Anything brief/hypothesis/finding/unknown mutation. Exactly one repo file written: this report. Evidence ids below are the tool-returned ids of this pass; addresses are pinned-VA."
---

# DEC-U-NB5 — callback invocation chain at renderer+0x40 and the 0x48→0x50 copy loop

## 0. Verdict

| Item | Prior | This pass | Result |
|---|---|---|---|
| **Invoking function / call site / argument registers** | [U] ("resolve the indirect call site at renderer+0x40") | Recovered byte-exact | **CLOSED [D]**: `sub_81ac54`, site `0x81ac68` `call dword ptr [ebx+0x40]`, full register map §2 |
| **Copy loop (0x48 producer row → 0x50 consumer quad)** | [U] U-copy-site | Recovered byte-exact, zero gaps | **CLOSED [D] as a static instruction/offset map**: §3 (2×32 B `rep movsd` + 4-iteration scatter). Value-level byte-dump stays [U] with owner-only probe §5 |
| **Parity** | none | none | **No parity claim.** No donor GPU frame; no donor execution |

The "copy" is **not** a `memcpy`: it is two 32-byte `rep movsd` row lifts followed by a 4-iteration field scatter. No stride or offset below is invented; every constant is quoted from the decoded instruction bytes.

---

## 1. Target discipline and pass ledger (pin `t_87f0f3c130b0`, multiple passes)

Every `native_*` call in this pass carried `document:"t_87f0f3c130b0"` explicitly. `core_session_show` confirmed `active_target = t_87f0f3c130b0`, `analysis_mode = deep`. `editor.exe` (`t_68474ddde43f`) was never opened or read.

| Pass | Operation | Evidence | Establishes |
|---|---|---|---|
| 1 | `native_function_disassemble 0x8177f0` (129 insn, re-observed) | `ev_9ce28a17…` (carried shape, identical) | installer: `[eax+0x40] ← 0x812e34` default at `0x8178b4`; `[eax+0x44] ← ebx`; alt slots `+0x48/+0x4c` |
| 2 | `native_bytes_find C7 40 40 34 2E 81 00` | `ev_c2d1ba32…` | **4** installer sites write `0x812e34` to `[reg+0x40]`: `0x813b80`, `0x8140ab`, `0x814fe0`, `0x8178b4` (§4) |
| 3 | `native_bytes_find FF 53 40` (+`FF 51/52/56/57 40` sweeps) | `ev_706d9948…` | 20 `call [ebx+0x40]` sites image-wide; exactly one in terrain range: **`0x81ac68`** |
| 4 | `native_function_find` + `native_instruction_show 0x81ac68` | `ev_d5a27e12…`, `ev_7cea513c…` | `0x81ac68` is `call dword ptr [ebx+0x40]` (flow `indirect_call`), inside `sub_81ac54+0x14` |
| 5 | `native_function_disassemble 0x81ac54` (13 insn) | `ev_5952cf12…` | trampoline: arg setup + indirect call (§2) |
| 6 | `native_function_references_list incoming 0x81ac54` | `ev_9b6e6b47…` | exactly 1 caller: `0x81887e` in `sub_818824` |
| 7 | `native_function_disassemble 0x818824` (91 insn) | `ev_20db8cc5…` | callback invocation at `0x81887e`; row lifts at `0x8188d3/0x8188e3`; quad-fill call at `0x818900` |
| 8 | `native_function_references_list incoming 0x818824` | `ev_30df199a…` | exactly 1 caller: `0x8192f3` in `sub_818920` |
| 9 | `native_function_disassemble 0x81aa3c` (107 insn) | `ev_f95cb91d…` (study) + §3 disassembly | 4-iteration scatter loop `0x81aae3–0x81ab8a`, dests `-0x50/-0x40/-0x20` |
| 10 | instruction walk `0x812b4c` (45 insn) | §3.1 (op+VA cited) | `lea ebx,[edx+eax*8]` = base+slot·0x48; `lea eax,[ebx+eax*8+5]` = RGB base **+0x05** |
| 11 | instruction walk `0x812ccc` (40 insn) | §3.1 (op+VA cited) | `lea eax,[ebx+eax*8+0x25]` = alpha base **+0x25** |
| 12 | `native_function_disassemble 0x8127b8` (8 insn) + `0x812ae0` (12 insn) | `ev_f476ca55…`, `ev_3fec38bf…` | registrar: `push 0x812e34 → call 0x812ae0` stores callback into `+0xb0/+0xb4` passthrough |
| 13 | `native_function_references_list incoming 0x812e34` + study (callers 0) | `ev_ce26ac4e…`, `ev_0c031cb8…` | `sub_812e34` has **0 direct callers** (purely indirect); 2 data refs: `0x8127ca`, `0x8178b4` |
| 14 | call-site args at `0x8192f3` (`native_instruction_show` + 8×`native_cursor_back`) | §2.4 (op+VA cited) | `eax=[ebp-4]`, `edx=[ebp-0x14]`, `ecx=[ebp-0x24]`, pushes `[ebp-8]/[ebp-0x28]` |

Negative results (not absence proofs, tool-coverage bounded): `call [eax+0x40]` (`FF 50 40`) ×0 image-wide; `call [eax/ebx/…+0x40]` with 32-bit disp (`FF 90–9F 40 00 00 00`) ×0; register-indirect `call eax/edx/ebx/esi/edi` ×0 inside `0x810000–0x820000`; `mov reg,[reg+0x40]` 8-bit-disp hits (135/25/40/6/64) all outside `0x800000–0x830000` except one `+0x140` false positive at `0x818184` (`8B 86 40 01 00 00` = `[esi+0x140]`, [O] not a +0x40 load).

---

## 2. Invocation chain — byte-proven [D]

```
sub_818920 ──0x8192f3──▶ sub_818824 ──0x81887e──▶ sub_81ac54 ──0x81ac68 [ebx+0x40]──▶ sub_812e34
   (consumer)              (per-cell                      (trampoline,        (producer: RGB 0x812b4c
                            driver)                        13 insn)            / alpha 0x812ccc)
       │                                                        │
       └────────────── sub_818824 ──0x818900──▶ sub_81aa3c ──────┘
                            (row lifts)          (quad scatter §3.3)
```

### 2.1 The trampoline `sub_81ac54` (`ev_5952cf12…`) — the renderer+0x40 reader [O]

```
0x81ac54  push ebp
0x81ac55  mov ebp, esp
0x81ac57  push ebx
0x81ac58  push dword ptr [ebp+0xc]     ; stack arg B forwarded
0x81ac5b  push dword ptr [ebp+8]       ; stack arg A forwarded
0x81ac5e  mov ecx, edx                 ; ecx = incoming edx (count-out ptr)
0x81ac60  lea edx, [eax+0x50]          ; edx = renderer + 0x50  ← ROW ARRAY BASE
0x81ac63  mov ebx, eax                 ; ebx = renderer
0x81ac65  mov eax, [ebx+0x44]          ; eax = renderer+0x44 (= terrain desc)
0x81ac68  call dword ptr [ebx+0x40]     ; ← THE indirect callback invocation
0x81ac6b  pop ebx
0x81ac6c  pop ebp
0x81ac6d  ret 8
```

Callback (`sub_812e34`) entry register state [D by instruction arithmetic]:
| Reg/stack | Value |
|---|---|
| `eax` | `[renderer+0x44]` (terrain descriptor; `812e34` uses it as `esi`, reads dims at `esi+0xa0`) |
| `edx` | `renderer+0x50` (0x48-record array base — §3.4) |
| `ecx` | count-out pointer (`812e34` zeroes `[ecx]` at entry, writes tag count at exit: `mov [eax],dl` with `eax=[ebp-0x10]=ecx`) |
| stack | the two dwords from `sub_818824` (height-table words, §2.3) |

### 2.2 The driver `sub_818824` at the invocation (`ev_20db8cc5…`) [O]

```
0x818863  mov esi,[ebp-8] / add esi,esi / lea esi,[esi+esi*2]   ; esi = k*6 (loop var)
0x81886b  mov eax,[ebp+0xc]
0x81886e  push dword ptr [eax+esi*8-0x30]                       ; stack B
0x818872  mov eax,[ebp+0xc]
0x818875  push dword ptr [eax+esi*8+4]                          ; stack A
0x818879  lea edx,[ebp-9]          ; edx = &count (1-byte local)
0x81887c  mov eax,ebx              ; eax = renderer ([ebp+8])
0x81887e  call 0x81ac54            ; → callback; returns count in [ebp-9]
...
0x81889d  xor eax,eax / mov al,[ebp-9] / dec eax / test eax,eax
0x8188a5  jl 0x81890b              ; count==0 → skip quad fill
```

### 2.3 Row lifts and quad-fill call in `sub_818824` (`ev_20db8cc5…`) [O]

Per qualifying iteration (`esi` = tag index; `eax = esi+esi*8` = 9·`esi` at `0x8188cf`):

```
0x8188d3  lea esi,[ebx+eax*8+0x55]    ; src RGB : renderer + 0x48·i + 0x55  (= row+0x05, §3.4)
0x8188d7  lea edi,[ebp-0x54] / mov ecx,8 / rep movsd   ; 32 B RGB  → staging
0x8188e3  lea esi,[ebx+eax*8+0x75]    ; src alpha: renderer + 0x48·i + 0x75 (= row+0x25)
0x8188e7  lea edi,[ebp-0x34] / mov ecx,8 / rep movsd   ; 32 B alpha → staging
0x8188f2  mov dl,[ebx+eax*8+0x54]     ; tag byte → stack
0x8188f7  mov ecx,[ebx+eax*8+0x50]    ; row word  → ecx
0x8188fb  lea edx,[ebp-0x64]          ; edx = &index-block (4 dwords, see §3.2)
0x8188fe  mov eax,ebx                 ; eax = renderer
0x818900  call 0x81aa3c               ; quad-record scatter (§3.3)
```

with the index block built just before (`0x8188ad–0x8188cc`):

```
0x8188ad  mov eax,[ebx+0x1bc]          ; eax = vertex count base
0x8188b8  sub edx,4 → [ebp-0x64]       ; idxB = base-4
0x8188bd  sub edx,2 → [ebp-0x60]       ; idxA = base-2
0x8188c5  dec edx   → [ebp-0x5c]       ; idxC = base-1
0x8188c9  sub eax,3 → [ebp-0x58]       ; idxD = base-3
```

### 2.4 Entry from the consumer `0x8192f3` (`sub_818920 → sub_818824`) [O]

```
0x8192ea  mov ecx,[ebp-0x24]
0x8192ed  mov edx,[ebp-0x14]
0x8192f0  mov eax,[ebp-4]     ; renderer
0x8192f3  call 0x818824
```

(`sub_818920`'s sole direct caller remains `sub_8177f0` at `0x8179b6`, `ev_66723f09…` carried from DEC-U-ALPHA-PASS-QUAD.)

---

## 3. The 0x48 → 0x50 copy — exact instruction/offset map [D]

### 3.1 Producer writes (this pass, instruction walks) [O]

`sub_812b4c` (RGB), entry `push ebp` at `0x812b4c`:

```
0x812b5d  and eax,0xff / lea eax,[eax+eax*8]     ; eax = (slot&0xff)·9
0x812b65  mov edx,[ebp+0x28] / mov edx,[edx-4]    ; edx = row-array base (Delphi open-array ptr)
0x812b6b  lea ebx,[edx+eax*8]                     ; ebx = row = base + slot·0x48 (9·8 = 72 = 0x48)
0x812b73  mov [ebx],eax                           ; row+0x00: material index
0x812b78  mov [ebx+4],al                          ; row+0x04: mirror byte
0x812b89  lea eax,[ebx+eax*8+5]                   ; RGB uv base = row+0x05, corner·8
0x812b96  fstp dword ptr [eax]      / 0x812ba2 fstp [eax+4]   ; corner u,v (= 1-u, 1-v math w/ V-flip at 0x812bac–0x812bb5)
```

`sub_812ccc` (alpha), entry `push ebp` at `0x812ccc` — same addressing with the alpha base:

```
0x812ce6  lea ebx,[edx+eax*8]                     ; row = base + slot·0x48
0x812cf7  lea eax,[ebx+eax*8+0x25]                ; alpha uv base = row+0x25, corner·8
0x812d0a  fstp [eax] (+ fadd [edx-8] inset) / 0x812d1c fstp [eax+4] (+ fadd [edx-0xc])
0x812d26  fld 1.0 / fsub [eax+4] / fstp [eax+4]   ; V-flip when [ebp+0x10] != 0
```

### 3.2 Staging buffer layout in `sub_818824`/`sub_81aa3c` [D]

`sub_81aa3c` entry copies `ecx=0x14` dwords (80 B = **0x50**) from `edx` into `[ebp-0x58]` (`0x81aa45–0x81aa50`), and the caller guarantees 80 contiguous bytes at `edx=[ebp-0x64]`:

| Staging | Bytes | Source [O] |
|---|---|---|
| `[ebp-0x64..-0x61]` | index word 0 (`base-4`) | `0x8188b8` |
| `[ebp-0x60..-0x5d]` | index word 1 (`base-2`) | `0x8188bd` |
| `[ebp-0x5c..-0x59]` | index word 2 (`base-1`) | `0x8188c5` |
| `[ebp-0x58..-0x55]` | index word 3 (`base-3`) | `0x8188cc` |
| `[ebp-0x54..-0x35]` | 32 B RGB (`row+0x05..+0x24`) | `rep movsd` at `0x8188d7` |
| `[ebp-0x34..-0x15]` | 32 B alpha (`row+0x25..+0x44`) | `rep movsd` at `0x8188e7` |

After the 0x50-byte copy the loop works on `[ebp-0x58]` (indices), `[ebp-0x48]` (RGB) and `[ebp-0x28]` = `[ebp-0x48]+0x20` (alpha).

### 3.3 Scatter loop `sub_81aa3c 0x81aae3–0x81ab8a` — 4 iterations, zero gaps [O]

`[ebp-4] = 0..3`; per iteration `ecx`: `eax` starts `[ebp-0x48]` (+8/iter), `[ebp-8]` starts `[ebp-0x58]` (+4/iter); `edx` = quad-slot base + 0x50 (so `-0x50/-0x40/-0x20` land on `Q+0x00/+0x10/+0x30`):

| # | Instruction VAs | Dest | Consumer field (DEC-U-ALPHA-PASS-QUAD §6.3) |
|---|---|---|---|
| 1 | `0x81ab0d–0x81ab0f` `mov edi,[edi]; mov [edx+ecx*4-0x50],edi` | 4 B/iter → `Q+0x00,+0x04,+0x08,+0x0c` | vertex indices B, A, C, D |
| 2 | `0x81ab3a–0x81ab43` `mov edi,[eax]/[eax+4]; mov [edx+ecx*8-0x40/-0x3c],edi` | 8 B/iter → `Q+0x10..+0x2f` | RGB uv pairs B, A, C, D |
| 3 | `0x81ab6e–0x81ab78` `mov edi,[eax+0x20]/[eax+0x24]; mov [edx+ecx*8-0x20/-0x1c],edi` | 8 B/iter → `Q+0x30..+0x4f` | alpha uv pairs B, A, C, D |

Loop control: `0x81ab7c inc [ebp-4]; 0x81ab7f add eax,8; 0x81ab82 add [ebp-8],4; 0x81ab86 cmp [ebp-4],4; jne 0x81aae3`. 4·(4+8+8) = 80 B = full record, no gaps, no overlap.

### 3.4 The `+0x0b` shift, closed arithmetically [D]

Row array base `R` = `renderer+0x50` (trampoline `0x81ac60`: `lea edx,[eax+0x50]`):

- RGB read at `renderer+0x55+0x48·i` = `R+0x05+0x48·i`; producer writes at `row+0x05` (`0x812b89`). Δ = 0. ✔
- Alpha read at `renderer+0x75+0x48·i` = `R+0x25+0x48·i`; producer writes at `row+0x25` (`0x812cf7`). Δ = 0. ✔
- `R+0x05` → `Q+0x10` and `R+0x25` → `Q+0x30`: shift `+0x0b` on both blocks, exactly the DEC-U-ALPHA-PASS-QUAD §6.4 relation, now anchored to instructions on both ends.
- The shared constant `0x50` appears on both sides from independent instructions (trampoline `lea` vs `rep movsd ecx=0x14` = 80 B staging vs `Q` stride `0x50` in `sub_818920` at `0x819364/0x81978d`).

**U-copy-site static angle (NB-5) is therefore CLOSED [D]**: every `+0x05…+0x44 → +0x10…+0x4f` UV byte and all four `+0x00…+0x0c` index words are mapped to exact copy instructions with zero gaps. What stays [U] is the *value-level* byte-dump termination (§5), which requires a live debugger and is forbidden to this worker.

---

## 4. Registration side (supporting [O], closes no value)

- Default install: `0x8178b1 mov [eax+0x44],ebx; 0x8178b4 mov [eax+0x40],0x812e34` (`ev_9ce28a17…`). Clones with identical bytes at `0x813b80`, `0x8140ab`, `0x814fe0` (`ev_c2d1ba32…`) sit in undiscovered code — sibling cell-initializer variants [I]; not followed further.
- `sub_8127b8` (8 insn, `ev_f476ca55…`): `push eax; push 0x812e34; call 0x812ae0`. `sub_812ae0` (12 insn, `ev_3fec38bf…`): stores the pushed callback into `[eax+0xb0]/[eax+0xb4]` (the passthrough pair the installer copies to `renderer+0x40/+0x44` when the `+0xb2` gate is set) and flags `[eax+0xc8]`.
- Alt callbacks for the other `+0xb2/+0xc2` branches: `0x818554` (float path, 34 insn) and `0x8185c0` (`call [esi+0xc0]`, 16 insn) — noted, out of scope.
- `sub_812e34` has 0 direct callers and 2 data refs (`0x8127ca` registrar push, `0x8178b4` installer) — `ev_ce26ac4e…`, `ev_0c031cb8…`. All terrain-mesh invocations go through `sub_81ac54`.

---

## 5. Remaining [U] and exact owner-only probe (no substitution)

**U-copy-values**: static map is [D]; a live zero-mismatch dump is still required before any port constant may cite donor values.

1. Break on write to `renderer+0x40` at `0x8178b4` (default path); record installed pointer (expect `0x812e34`).
2. Break on execute at `0x81ac68`; log `ebx` (renderer), `[ebx+0x44]`, `ecx` (count ptr), stack args; step into `sub_812e34`.
3. At `sub_818824 0x8188d3/0x8188e3`, dump source rows `renderer+0x50+0x48·i`, 0x48 B each, for all `i < [ebp-9]`.
4. At `sub_81aa3c` exit, dump the appended `Q` record(s) (0x50 B each at `[edi+ecx*8+8]`-derived base).
5. **Terminate** iff every dumped `row+0x05..+0x44` byte equals the corresponding `Q+0x10..+0x4f` byte and the four index words equal `base-{4,2,1,3}` per §3.2/§3.3, with zero mismatches across ≥3 cells including a multi-tag cell. Until then the port keeps the §6.4/§3 field transport only.

---

## 6. Port instruction (exact, no approximation)

1. The port mesh builder must implement the §3.3 scatter order: per quad, indices B/A/C/D then RGB pairs then alpha pairs; 4-iteration structure preserved (A/B/C/D corner pairing per DEC-U-ALPHA-PASS-QUAD §6.3).
2. Row source base = producer array + `0x05` (RGB) / `+0x25` (alpha); never re-derive UVs from the vertex positions.
3. Do not add `memcpy`, stride `0x48` vertex fetches, or alpha-test/discard — U6/DEC-U-ALPHA-PASS-QUAD §4 still holds (`GL_ALPHA_TEST` enabled, no terrain compare func).
4. No parity claim: this map is donor-instruction-faithful, not a same-camera A/B proof.

---

## 7. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | Reader of `renderer+0x40` is `sub_81ac54`; site `0x81ac68` `call [ebx+0x40]`; args `eax=[ebx+0x44]`, `edx=ebx+0x50`, `ecx=incoming edx`, 2 stack dwords forwarded | [O]/[D] §2.1 |
| 2 | Sole caller of `sub_81ac54` is `sub_818824` at `0x81887e`; sole caller of `sub_818824` is `sub_818920` at `0x8192f3`; `sub_812e34` has 0 direct callers | [O] §2.4, `ev_9b6e6b47…/ev_30df199a…/ev_ce26ac4e…` |
| 3 | Producer write offsets: material `+0x00`, mirror `+0x04`, RGB `+0x05+c·8`, alpha `+0x25+c·8`, row stride `0x48` | [O] §3.1 |
| 4 | Consumer reads `renderer+0x55/+0x75+0x48·i` (32 B each) → staging; scatter loop writes `Q+0x00/+0x10/+0x30` (4+8+8 B × 4 iters = 80 B, zero gaps) | [O]/[D] §3.2–§3.3 |
| 5 | `+0x0b` shift + 16-byte index header = instruction-anchored on both ends; shared `0x50` constant independent on both sides | [D] §3.4 |
| 6 | U-copy-site static angle (NB-5) CLOSED [D]; value dump + parity stay [U]/NONE | [D]/[U] §5 |
| 7 | No donor binary executed; exactly one repo file written; no code/asset/config/Godot/git touched | [O] scope guard |

*End of DEC-U-NB5. Donor read-only; no binary executed, copied or committed; no parity claimed.*
