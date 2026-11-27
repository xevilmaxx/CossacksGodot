---
id: DEC-U-UREG-CTOR-2026-11-26
worker: DEC-U-UREG-CTOR (subagent in full 1:1 Cossacks 3 donor port)
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-UREG-CTOR — class-B new angle U-REG-TEX ctor sweep: constructors of the engine texture-image/registry family plus the shader-uniform object constructor for any store into +0x54/+0x58/+0x5c/+0x60/+0x64"
ticket: "Pin t_87f0f3c130b0, multiple passes. Execute new class-B candidate from PORT1TO1_b_angle_index.md: U-REG-TEX ctor sweep. Prior: DEC_U3_reg_sweep.md found schema→slot map FUN_00853ad4 +0x54…+0x64 ↔ binder FUN_00854054 bits 7e.10–7f.1, family names localized but no ctor link; DEC_U_nb1.md swept TOSW* ctors with zero +0x4c stores. TASK: sweep constructors of the engine texture-image/registry class family (TOSW*, OSWTexture, TextureImage, TOSWRefTextureImage) plus the shader-uniform object constructor for any store into offsets +0x54/+0x58/+0x5c/+0x60/+0x64 that would supply hmapTex/hmapW/H/Min/Max at draw time, and trace whether a single object instance owns both the uniform block and the height texture. Only byte-proven links become [D]; otherwise keep U3 identity/values [U] with the exact glBindTexture/glUniform1i/1f capture and zero-mismatch termination. No invented object or offset; no parity claim."
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
labels: [O, D, I, U, NO_APPROXIMATION, PARITY_UNVERIFIED]
parity_claim: NONE
parity_status: UNVERIFIED
visual_parity_claim: false
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. No donor binary executed, copied, committed, or captured. No donor file written. No GPU frame captured. All calls pinned document=t_87f0f3c130b0, Deep mode (engine 0.6.1; Ghidra-backed target already open; builtin clean-room lifter used for reads; undiscovered-function caveat logged)."
scope_guard: "No repo code/asset/shader/config/test/fixture/result/Godot/git change. Exactly one repo file written: this report."
multi_pass: true
upstream: "PORT1TO1_b_angle_index.md §3 NB-1/NB-6 (U-REG-TEX residual); DEC_U3_reg_sweep.md §§2-4/§6 (schema→slot map +0x54↔7e.10…+0x64↔7f.01, family table, U-REG-TEX protocol); DEC_U_nb1.md §§2-4 (FULL-binary TOSW* enumeration, zero +0x4c stores); DEC_U_hmap_identity.md §4 (chain FUN_008520a8←FUN_00739bf8→FUN_0082f86c, C+0xdc unit ctor 2, C+0xd8 target 0xde1, gate C+0xe0/[C+0xe0+8] at 0x854250)"
verdict: "RESULT IS NOT GOOD for the U-REG-TEX static angle alone — no TOSW*/TextureImage/OSWTexture ctor→+0x54/+0x58/+0x5c/+0x60/+0x64 store recovered; the only +0x54…+0x64 stores found are the shader-uniform ctor's own-field numeric defaults on C itself plus the descriptor-string initializer reached through C+0xf4 (different base, not a draw-time hmap supply); single-instance ownership is PARTIALLY proven (one C owns uniform slots + descriptor pointer + height slot) but the height-texture object identity still has zero byte-proven ctor link; U3 identity/values stay [U]; hard-fail endorsed; no approximation."
---

# DEC-U-UREG-CTOR — U-REG-TEX constructor sweep for `+0x54/+0x58/+0x5c/+0x60/+0x64` (read-only)

> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU/runtime session was executed by this worker; no parity claim is made. `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`.

## 0. Authority and discipline (read first)

Every statement is `[O]` (verbatim bytes/text/instruction lifted this ticket, pinned `t_87f0f3c130b0`), `[D]` (deterministic control-flow/arithmetic from `[O]`), `[I]` (interpretation, never wired), or `[U]` (UNVERIFIED with settling capture in §6; the port must **hard-fail, never invent a texture name/id, a unit number, or a per-map tuple**). Prior-ticket donor VAs/pseudocode are used only as hypotheses, never re-cited as evidence; every evidence id below beginning `ev_` was lifted **this ticket** via `default` tools against the pinned target. No donor binary was executed, no GPU frame captured, no parity claimed. Active donor target was never opened/selected/closed by this worker. No helper script was written into the repo. One repo file written: this report.

`[D]` load-bearing result: **the sweep adds one byte-proven ctor edge and otherwise returns negatives.** The shader-uniform constructor at `0x856080` (i) writes numeric defaults into its **own** `C+0x54…C+0x64` fields, (ii) writes the full draw-time uniform block `C+0xd0…C+0xec` (`C+0xd8=0xde1`, `C+0xdc=2`, `C+0xe0=0`), and (iii) calls the string-key schema initializer at `0x853ad4` with the descriptor pointer `eax=[ebx+0xf4]` — so one `C` instance owns the uniform slots **and** (by pointer at `C+0xf4`) the descriptor whose `+0x54…+0x64` hold the `hmapTex/hmapW/H/Min/Max` keys. **Neither** the `C+0x54` numerics **nor** any `TOSW*/OSWTexture/TextureImage` ctor store supplies `hmapTex/hmapW/H/Min/Max` at draw time (draw reads `C+0xd0/d4/dc/d8/e0/e4/e8`, never `C+0x54`). No `TOSW*` ctor→`C+0xe0`, →`C+0x4c`, →`texture+8`, or →`+0x54…+0x64` store was recovered. U3 identity/values stay `[U]`.

---

## 1. Pass ledger (owner rule ≤5 passes/function; every pass logged; all NEW this ticket, all pinned `t_87f0f3c130b0`)

| Pass | Question | Fresh reads this ticket | Result |
|---|---|---|---|
| P1 | Schema initializer `0x853ad4` store pattern into `+0x54…+0x64` | `native_bytes_show 0x853ad4+512` (`ev_8015…`), `native_bytes_show 0x853b00+512` (`ev_d72e…`); `native_instruction_show 0x853ad4` (push ebx) | **Accepted**: repeating `8d43 XX / ba KKKKKKKK / e8 …` (`lea eax,[ebx+XX]; mov edx,keyVA; call 0x405454`) run `+0x04…+0x78`; hmap run `+0x50/+0x54/+0x58/+0x5c/+0x60/+0x64/+0x68` byte-proven §2 |
| P2 | `hmap*` key-string VAs and hit counts | `native_bytes_show 0x853e00+256` (`ev_bc03…`), `0x853e30+64` (`ev_22af…`); `native_bytes_find "hmapTex"` (`ev_1400…`: 1 match `0x853e0c`), `"hmapMin"` (1 match `0x853e3c`), `"HeightMapTexUnit"` (`0x852b84` single, ctx `ev_5c68…`) | **Accepted**: `hmapTex @0x853e0c` single-hit; `hmapMin @0x853e3c` single; `hmapMax` adjacent; `HeightMapTexUnit @0x852b84` single-hit VA recovered this ticket (prior recorded none) but with zero immediate-operand code xref §2 |
| P3 | Shader-uniform object ctor `0x856080` full store list incl. `+0x54…+0x64` and `+0xd0…+0xec` + call edge | `native_bytes_show 0x856080+256` (`ev_74d0…`); `native_instruction_show` walk `0x856080→0x8560ec` (40 insns), `0x8560f6→0x85624e` (60), `0x85624e→0x85634d` (60); `native_instruction_show 0x8562ba/0x8562c0` | **Accepted, decisive**: `C+0x54/0x55=1`, `C+0x58=1.0f`, `C+0x5c=0`, `C+0x60=1.0f`, `C+0x64=0` on `ebx=C` itself; `C+0xd0/d4=0`, `C+0xd8=0xde1`, `C+0xdc=2`, `C+0xe0/e4/e8/ec=0`; `mov eax,[ebx+0xf4]; call 0x853ad4` at `0x8562ba/0x8562c0` §3 |
| P4 | `TOSW*` ctor→`+0x54/+0x58/+0x5c/+0x60/+0x64` sweep (U-REG-TEX proper) | `native_function_disassemble sub_8127e0` (140 insns, `ev_585e…`), `sub_812a44` (49, `ev_553f…`), `sub_7744cc` (61, `ev_b661…`), `sub_7763f8` (25, `ev_4ac1…`), `sub_6760a0` (15, `ev_ac27…`) — full store-list grep | **Accepted**: zero `+0x54/+0x58/+0x5c/+0x60/+0x64` stores in any testable TOSW-linked body; zero `+0x4c/+0x8/+0xe0` stores (re-affirms `DEC_U_nb1` P4, extended to the hmap offsets) §4 |
| P5 | Single-instance ownership + draw-time consumer cross-check | `native_bytes_show 0x854250+256` gate (`ev_ff50…`); `native_instruction_show 0x854054/0x854080`, staging head `0x8520a8→0x852101` (30 insns); `native_xrefs_list 0x853ad4/0x853e0c/0x852b84` (`ev_6e0b…/ev_ef7f…/ev_5156…`); `native_bytes_find "TOSWRefTextureImage"` (3 hits `0x4e706d/0x4e7086/0x770ba4`) | **Accepted**: gate reads `[esi+0xe0]` + bit-row `6437e10…7f01`; builtin xref DB returns 0 for string-VA immediates and for `0x853ad4` (computed-pointer/undiscovered-function caveat); ownership finding §5 |
| P6 | Port stance (no edits) | Repo/doc reads only (re-cited priors, no new port read needed) | Labels kept; §7 |

No function consumed more than 5 passes. `native_function_find` returns `not inside any discovered function` for `0x853ad4/0x856080/0x854054/0x8520a8` in the builtin 0.6.1 engine — that absence is a **tool limitation, not a code absence** (Ghidra Deep discovered them per priors); this ticket therefore proves stores from **bytes + single-instruction walks**, never from trusted pseudo-C.

---

## 2. Angle (a) — packed-CODE keys `hmapTex/hmapW/H/Min/Max` + `HeightMapTexUnit` VAs `[O]/[D]/[U]`

All VAs pinned `t_87f0f3c130b0`. File offsets are `cossacks.exe` file offsets.

| # | Name | VA `[O]` this ticket | Bytes `[O]` | Standing |
|---|---|---|---|---|
| A1 | `hmapTex` | `0x853e0c` single-hit (`ev_1400…`: `total_matches: 1`, `CODE`, file `0x45320c`) | `0x853e00` window (`ev_bc03…`): `…hmapTex…hmapW…hmapH…hmapMin…hmapMax…shadowed…` Delphi `ffffffff <len> <name> 00` packing | Name + single-hit `[D]`; binding use `[U]` |
| A2 | `hmapW` | adjacent in same window (order after `hmapTex`) | same `ev_bc03…` | Schema order `[D]`; VA unquoted → VA `[U]` (bounded) |
| A3 | `hmapH` | adjacent (order `hmapTex,hmapW,hmapH,hmapMin,hmapMax`) | same | Same |
| A4 | `hmapMin` | `0x853e3c` single-hit (`native_bytes_find`, §1 P2) | `0x853e30` window (`ev_22af…`): `…hmapMin…hmapMax…shadowed…` | Key `[D]`; default/value `[U]` |
| A5 | `hmapMax` | adjacent after `hmapMin` (same window) | same | Key `[D]`; default/value `[U]` |
| A6 | `HeightMapTexUnit` | `0x852b84` single-hit this ticket (prior recorded no VA) | `0x852b70` ctx (`ev_5c68…`): `…htMapEnable…HeightMapTexUnit…ShadowMapEnable…ShaderUniforms…MirrorTexUnit…NormalTe…` | Name + VA `[D]` **new**; numeric value, sampler-unit link, and any code use all `[U]` — the two refs at `0x852b84` are `data (0x85268c, sub_852298)` + `jump (0x852b0e, sub_852a98)` (`ev_5156…`), i.e. the lifter mislabels string bytes as `sub_852b84` entry; **no immediate-operand code xref** recovered |

`[D]` The five `hmap*` names form one coherent Delphi packed-CODE key table with `HeightMapTexUnit` in a second key block (`…HeightMapTexUnit…ShadowMapEnable…ShaderUniforms…MirrorTexUnit…NormalTexUnit…`, `ev_5c68…`). No numeric unit/size/default is adjacent in plaintext (re-affirms `DEC_U3_reg_sweep` §2.1).

### Schema initializer store pattern `[O]/[D]`

`0x853ad4` head bytes (`ev_8015…`): `53 8B D8 8D 43 04 BA 703C8500 E8 7019BBFF …` = `push ebx; mov ebx,eax; lea eax,[ebx+0x04]; mov edx,<keyVA>; call setter …`, repeating every 13 bytes through `8D 43 78` (`lea eax,[ebx+0x78]`) in `ev_d72e…`. The hmap run inside it is byte-proven:

```
… 8D4350 BA F83D8500 E8 …   lea eax,[ebx+0x50]; mov edx,0x853df8
   8D4354 BA 0C3E8500 E8 …   lea eax,[ebx+0x54]; mov edx,0x853e0c (hmapTex)
   8D4358 BA 1C3E8500 E8 …   lea eax,[ebx+0x58]; mov edx,… (hmapW)
   8D435C BA 2C3E8500 E8 …   lea eax,[ebx+0x5c]; … (hmapH)
   8D4360 BA 3C3E8500 E8 …   lea eax,[ebx+0x60]; mov edx,0x853e3c (hmapMin)
   8D4364 BA 4C3E8500 E8 …   lea eax,[ebx+0x64]; … (hmapMax)
   8D4368 BA 5C3E8500 E8 …   lea eax,[ebx+0x68]; …
```

`[D]` `0x853ad4` therefore assigns **string keys** into `[desc+0x04…+0x78]` with the hmap run at `desc+0x54…+0x64`. The only proven operation is string assignment via setter `0x405454`; **no texture lookup, sampler unit, or GPU bind is present in the recovered bytes**. `ebx` here is the **descriptor object** passed in `eax` (`push ebx; mov ebx,eax`), not proven to be the shader object `C` itself — the caller (§3) passes `[C+0xf4]`.

Lifter trap (load-bearing): `native_instruction_show 0x853ad6` mis-decodes (`fmul st,…`) because the region is not a discovered function; the **bytes** above are authoritative, not the single-instruction pseudo at `+1`.

---

## 3. Angle (b) — shader-uniform object constructor `0x856080`: the ONLY `+0x54…+0x64` stores found `[O]/[D]`

Walk `0x856080→0x85634d` (single-instruction reads this ticket; `ebx` = constructed shader object `C` throughout — `mov ebx,eax` at `0x856086`):

| Offset on `C` (`ebx`) | Instruction `[O]` | Value `[O]` | Reading |
|---|---|---|---|
| `+0x54` | `mov byte ptr [ebx+0x54], 1` @`0x856088` | `1` | `[D]` own-field default, **not** a string key |
| `+0x55` | `mov byte ptr [ebx+0x55], 1` @`0x85608c` | `1` | same |
| `+0x58` | `mov dword ptr [ebx+0x58], 0x3f800000` @`0x856090` | `1.0f` | `[D]` float default |
| `+0x5c` | `mov [ebx+0x5c], eax` @`0x856099` (`eax=0`) | `0` | `[D]` zero |
| `+0x60` | `mov dword ptr [ebx+0x60], 0x3f800000` @`0x85609c` | `1.0f` | `[D]` float default |
| `+0x64` | `mov [ebx+0x64], eax` @`0x8560a5` (`eax=0`) | `0` | `[D]` zero |
| `+0x68/0x78` | `lea edi,[ebx+0x68]` + 4×`movsd` (16 B from `0x4a21e8` builder); `lea edi,[ebx+0x78]` + 4×`movsd` | 16-B float blocks | `[D]` vector defaults, not hmap |
| `+0xd0` | `mov [ebx+0xd0], eax` @`0x856278` (`eax=0`) | `0` | `[D]` hmapW slot init 0 |
| `+0xd4` | `mov [ebx+0xd4], eax` @`0x856280` | `0` | `[D]` hmapH slot init 0 |
| `+0xd8` | `mov dword ptr [ebx+0xd8], 0xde1` @`0x856286` | `0xde1` (= `GL_TEXTURE_2D`) | `[D]` target default (re-affirms prior `ev_5aae…` by fresh bytes) |
| `+0xdc` | `mov dword ptr [ebx+0xdc], 2` @`0x856290` | `2` | `[D]` sampler-unit default |
| `+0xe0` | `mov [ebx+0xe0], eax` @`0x85629c` | `0` | `[D]` height-object slot init NULL |
| `+0xe4/+0xe8/+0xec` | `mov [ebx+0xe4/e8/ec], eax` @`0x8562a4/2ac/2b4` | `0` | `[D]` min/max/gate init 0 |
| `+0xf4` | `mov eax,[ebx+0xf4]` @`0x8562ba`; `call 0x853ad4` @`0x8562c0` | descriptor pointer → schema init | `[D]` **the ctor edge** — see below |
| `+0xf8/+0xfc/+0x100…` | `mov [ebx+0xf8],0`; `mov [ebx+0xfc],1`; … `+0x108/+0x118` 16-B blocks; tail `lea eax,[ebx+0x180]; mov edx,0x856358; call 0x405454` | — | `[D]` further defaults; final string bind at `+0x180` (not hmap) |

`[D]` The call at `0x8562ba/0x8562c0` (`mov eax,[ebx+0xf4]` / `call 0x853ad4`, both `native_instruction_show`-proven this ticket) passes the **descriptor sub-object pointer stored at `C+0xf4`** in `eax` to the schema initializer whose head is `push ebx; mov ebx,eax`. So the same construction sequence touches **two different `+0x54` addresses**: `C+0x54` (numeric defaults above) and `[C+0xf4]+0x54` (the `hmapTex` string key). They are the same numeric offset on **different bases** — conflating them would be invention.

`[D]` **No draw-time hmap supply flows from `C+0x54…C+0x64`.** The binder gate bytes at `0x854250` (`ev_ff50…`: `8B86 E0000000 85C0 74…` = `mov eax,[esi+0xe0]; test; jz…` then `6437E10…7F01` bit rows) and the prior-corroborated binder rows consume `C+0xdc/d0/d4/e4/e8` (and `C+0xe0` validity), never `C+0x54…C+0x64`. The ctor's `C+0x54` values (`1,1,1.0f,0,1.0f,0`) are therefore **not** `hmapTex/hmapW/H/Min/Max` at draw time — recorded as own-field defaults with no consumer, not as a supply link.

---

## 4. Angle (c) — `TOSW*/OSWTexture/TextureImage/TOSWRefTextureImage` ctor sweep for `+0x54/+0x58/+0x5c/+0x60/+0x64` stores `[O]/[D]`

Full disassemblies this ticket (all pinned `t_87f0f3c130b0`):

| Ctor / descriptor candidate | Body / stores `[O]` | `+0x54/58/5c/60/64` test |
|---|---|---|
| `sub_8127e0` (sole data-xref owner `0x812999 → 0x812a44`, 140 insns, `ev_585e…`) | Displacements: `[ebx+0x3c/0xa0/0xa4/0xa8/0x148/0x149/0xc9/0xca/0x154/0x158/0x14c/0x130/0x134/0x138/0x140/0x144/0x13c/0x15c/0x160/0x164/0x12c/0x168/0x169/0x174/0x170/0x16c/0x178/0x17c/0x180/0x181/0x183/0x184/0x188]` + `[esi+0x48/0x49]`; reads `[ebx+0x16c]→[eax+0x24]` | **Zero** `+0x54/58/5c/60/64` writes; zero `+0x4c/+0x8/+0xe0` writes |
| `sub_812a44` (referenced table slot; real code from `0x812a54`, 49 insns, `ev_553f…`; head `0x812a44–0x812a53` is length-prefixed `'TOSWBlankImage'` bytes mis-decoded) | Displacements: `+0x130/+0x140/+0x144/+0x12c/+0x16c/+0x170` only | **Zero** target-offset writes |
| Registrar `sub_7744cc` (61 insns, `ev_b661…`) | Writes `[esi+0x38]`, pool under `[ebx+0x220]` (`+8` array / `+0xc` count), `[esi+0x44]` | **Zero** target-offset writes |
| Factory `sub_7763f8` (25 insns, `ev_4ac1…`) | Writes `[eax+0x2c/0x38/0x4/0xc/0x10/0x14/0x18/0x1c/0x20/0x24/0x28/0x44]` (note `+0x28`, not `+0x58`; `+0x44` is pool index) | **Zero** `+0x54/58/5c/60/64` writes |
| Feeder `sub_6760a0` (15 insns, `ev_ac27…`) | `mov eax,[eax+0x4c]` LOAD @`0x6760a8`; `mov eax,[eax+0x2bc]`; `call sub_7744cc`; no stores | **Zero** stores of any kind (read-only path) |
| Orphan registration VAs + family counts | `TOSWRefTextureImage` 3 hits (`0x4e706d/0x4e7086/0x770ba4`, re-found this ticket); `TOSWTextureImage` 4, `ToN` 1, `TextureImage`/`OSWTexture` per `DEC_U_nb1` §2 (not re-enumerated; used as hypothesis only) | Data, not code — no ctor body, no store testable; `total_to: 0` |

`[D]` **No `TOSW*`/`TOSWTexture`/`OSWTexture`/`TextureImage`/`TOSWRefTextureImage` ctor→`+0x54/+0x58/+0x5c/+0x60/+0x64` store, no ctor→`C+0xe0` store, no ctor→`C+0x4c` store, and no texture-`+8` GL-id store was recovered in any testable ctor body.** The `TOSWRefTextureImage` name remains suggestive `[I]` only; `ImageClassName` remains a zero-xref factory hook `[U]`; zero xrefs do not imply runtime absence `[D]` (Delphi registration tables leave no absolute-immediate xref by construction — same caveat as `DEC_U_nb1` §3).

---

## 5. Angle (d) — does a single object own both the uniform block and the height texture? `[D]/[U]`

`[D]` **Partially proven — one `C` owns the uniform slots, the descriptor pointer, and the height slot, but NOT proven to own the height texture object:**

1. The `0x856080` ctor writes, on the **same `ebx=C`**, the own-field block `C+0x54…C+0x64`, the vector blocks `C+0x68/C+0x78…`, the draw-time uniform block `C+0xd0/d4/d8/dc/e0/e4/e8/ec`, and the descriptor indirection `C+0xf4` (whose pointee receives the `+0x54…+0x64` string keys via `call 0x853ad4`). One construction sequence therefore initializes **both address families** (`C+*` and `[C+0xf4]+*`).
2. The height slot `C+0xe0` is initialized `0` in that same ctor (`ev` walk §3) and filled per-draw by the staging path (`FUN_008520a8` per priors: `C+0xe0 = FUN_0082f86c(*(h+0x200))`; gate `C+0xe0 != 0 && [C+0xe0+8] != 0` at `0x854250`, bytes `ev_ff50…` this ticket). The texture object behind `C+0xe0` is thus **assigned after construction, per draw**, not built by any ctor swept here.
3. `[U]` Which class (if any) among `TOSW*/OSWTexture/TextureImage` backs the `C+0xe0` pointee; its `(w,h,format,mips)` args; the sampler unit actually used (ctor `C+0xdc=2` unless overwritten by code not in corpus); the pool/naming rule; whether the pointee is an FBO attachment, a framebuffer copy, or a static upload; the numeric GL name behind `[C+0xe0+8]`. `TOSWRefTextureImage` stays `[I]`, never `[O]` for reflection/hmap backing.

`[D]` The staging head at `0x8520a8` (`push ebx/push esi/push edi; mov esi,ecx; mov ebx,eax; … call 0x739bf8; … call 0x82f060 …`, 30 insns this ticket) is consistent with the prior `FUN_008520a8(shaderCtx=C, layerObj, field)` shape (`esi=C` after `mov esi,ecx`), but the `C+0xd0/C+0xe0` stores lie deeper than the 30-insn window walked here and are **not** re-proven by fresh bytes — the draw-time consumer side is therefore re-cited as `[U]`-bounded prior structure, with the fresh gate bytes (`ev_ff50…`) as the only new consumer `[O]` this ticket.

---

## 6. `[U]` register — GL texture-binding/uniform captures with zero-mismatch termination

Gating precondition for **every** row: water field visible (break `FUN_00603d30` @ `0x603d30`, read `[ebp+0x1c]`); live path identified first (hook `glShaderSource`: `hmapTex` present = DEV file pair `water.dev.vert/frag` per `water.lib:67-68`; `alphaDepth`/`deepColor` = BUILTIN embedded pair); height gate open at `0x854250` (`C+0xe0 != 0 && [C+0xe0+8] != 0` — closed gate voids the frame). Owner-authorised donor session only; forbidden to workers. Captures on the BUILTIN path settle nothing.

| # | Still-`[U]` item | Static state after this sweep | Capture experiment (break + trace + byte comparison) | Zero-mismatch termination |
|---|---|---|---|---|
| U3-TEX | `hmapTex` GL identity `(target, name, w, h)` + provenance class | `[O]` unit `C+0xdc` (ctor 2), target `C+0xd8` (ctor `0xde1`, per-draw `*(h+0x50)`); `[U]` name/provenance/size. Registry names (§2) give **no id**; `.map` bytes store **no id** (per `DEC_U3_reg_sweep` §4, not re-run) | At the `FUN_00854054` 7e.10 break (same draw as the U3-NUM tuple): record `glActiveTexture(GL_TEXTURE0+u)` with `u=C+0xdc`, `glBindTexture(target,name)`, `glUniform1i(hmapTex,u)`, `glGetTexLevelParameteriv(name,0,{WIDTH,HEIGHT,INTERNAL_FORMAT})` + sampler state; full-frame history of `name`: (a) FBO attachment (`glFramebufferTexture2D*` with that name), (b) copy dst (`glCopyTexImage2D/SubImage2D`), (c) upload-only (`glTexImage2D` with that size). Dump one 8×8 texel block + channel carrying height; log map name + `water.lib` hash | **Terminate iff the same `(target,name,w,h)` repeats with 0 mismatches across ≥2 frames + 1 camera move** on that map, and exactly one provenance class (a/b/c) accounts for `name` with 0 counter-examples. Mixed/unknown provenance ⇒ keep `bind_height_grid` substitute labelled `[U3]`; never promote art/`heightmapwaves0.tga`/neutral texel |
| U3-NUM | Live `(hmapW,hmapH,hmapMin,hmapMax)` for a named shipped map | `[D]` sources: `layerObj+8/+0xc` int32 copies; `(float)FUN_0082f060/0082f114(*(h+0x200))` identity passthrough; gate proven. Values per-map `[U]`. `C+0x54…C+0x64` ctor defaults (§3) are **not** sources — excluded by consumer evidence | Break `FUN_00854054` bits 7e.10–7f.1 (`0x854250–0x8542f0`) with the named map loaded + field visible. Record pushed `C+0xd0/+0xd4` ints, `C+0xe4/+0xe8` floats **plus** chain pointers (`layerObj`, `h`, `h+0x200`, `C+0xe0`, `[C+0xe0+8]`) and same-draw `glUniform1i/1f` hook values on `hmapW/H/Min/Max`. Name the map + `water.lib` hash | **Terminate iff the same 4-tuple repeats with 0 differing bits across ≥2 frames + 1 camera move** on that map; those 4 numbers (not `map_size`/`±2.96`/`±2.964`/clamp/`C+0x54` defaults) become the port parameters **for that map only**. A second map needs its own row |
| U-REG-TEX | `TOSW*` ctor→field-store sweep (`C+0xe0` hmap slot + `C+0x4c` reflection slot + `+0x54…+0x64` supply) + `HeightMapTexUnit@0x852b84`→`C+0xdc` override check | `[O]` family localized; `[D]` zero target stores in all five testable bodies (§4); `[D]` shader-ctor own-field `+0x54` defaults + `C+0xf4→0x853ad4` edge (§3); `[U]` every texture-identity store edge and the unit override | Static-only: walk each `TOSW*` vtable + `ImageClassName` factory with a computed-pointer-respecting carve (the `0x4e72f8` giant + `0x8127e0`-style stubs); record instantiating class, w/h/format/mipmap args, store VA into `C+0x4c`/`C+0xe0`; scan for any immediate write to `C+0xdc` other than ctor `2`; record every code xref of `HeightMapTexUnit@0x852b84` | **Terminate iff each class has a visited ctor with 0 unvisited xrefs remaining** and the `C+0x4c`/`C+0xe0`/`C+0xdc` writers are identified (or proven absent) with 0 unvisited xrefs. Until then `TOSWRefTextureImage` stays suggestive `[I]`; `HeightMapTexUnit` stays valueless `[U]` |

General rule: any mismatch, closed gate, or wrong-shader-path frame voids the capture. No parity follows from termination — termination only authorises wiring the captured reals for the captured map/slot.

---

## 7. Exact port stance (file:line; NO edits made — owner applies)

All lines re-cited at repo HEAD via priors; verified present, untouched by this worker. **Wire only captured reals.**

1. `variant3d/scripts/water3d.gd:68` (`MAX_HEIGHT=2.96`), encode `:652`, `hmapMin/Max` binds `:668-669`, `max_height :763` — KEEP SUBSTITUTE + `[U3]` LABELS. After U3-NUM on the target map only: replace `∓MAX_HEIGHT` with the captured `(hmapMin,hmapMax)`, keeping DEV shape `hmapMin + w*(hmapMax-hmapMin)`. FORBIDDEN: presenting `±2.96`/`±2.964`/clamp/`C+0x54`-default floats (`1.0f/0`) as recovered.
2. `variant3d/scripts/water3d.gd:486+` (`bind_height_grid`), `:655` (`height_tex`), hmap binds `:663-669` — KEEP SUBSTITUTE. After U3-TEX only: add `bind_engine_hmap(real_texture, target_enum)` from captured provenance; never generated solid-colour, never `diffusewaves*`/`heightmapwaves0` art unless a capture proves identity.
3. Uniform-table `:143,146-147`, stats `:305,346`, ledger `:909,913,940` — LABEL-ONLY: cite this sweep (schema init `0x853ad4 +0x54…+0x64` string keys via `C+0xf4`; shader ctor `0x856080` own-field `C+0x54…+0x64` numerics + `C+0xd8=0xde1`/`C+0xdc=2`/`C+0xe0=0`; gate `0x854250`; `hmapTex @0x853e0c` single-hit; `HeightMapTexUnit @0x852b84` single-hit valueless; `TOSW*` zero target stores); keep every `[U3]` tag.
4. FORBIDDEN: hard-coding any shipped-map `(W,H,Min,Max)` from `map_size`, `128`, `2.96`, `2.964`, `±2.9639999866`, or forum values; inventing a `HeightMapTexUnit` number; inventing a texture name/id; emulating `[C+0xe0+8]` as a GL name; adding a scale/bias between getters and uniforms; equating `TOSWRefTextureImage` with the backer from the class name alone; wiring `C+0x54…C+0x64` ctor defaults into `hmapW/H/Min/Max` (different fields, proven by §3 consumer evidence).

---

## 8. Explicit non-claims and file discipline

- **No parity claim.** No donor binary executed, no GPU frame captured, no port capture compared. All new readings are `[O]/[D]`; all identity/values are `[U]` with §6 captures. `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`.
- **No approximation substituted.** No texture name/size/unit, no shipped-map `(W,H,Min,Max)` tuple, no conversion factor is supplied. The port's decoded-grid `height_tex`/`hmapTex` + `±2.96` span, both explicitly labelled `[U3]`, is endorsed as the donor-faithful behaviour until the corresponding zero-mismatch captures land.
- **No invented object or offset.** The `C+0x54` (own-field numeric) vs `[C+0xf4]+0x54` (descriptor string key) distinction is load-bearing: same numeric offset, different base object, different content type, different consumer. No `TOSW*`→`C+0xe0`/`C+0x4c`/`+0x54` edge is claimed. `HeightMapTexUnit @0x852b84` is a new single-hit VA but valueless `[U]`.
- **No guess promoted.** `TOSWRefTextureImage` is suggestive `[I]`, not the backer `[O]`; the `C+0x54` numeric defaults do not imply an hmap supply `[D]`; zero builtin-xref results do not imply runtime absence `[D]` (undiscovered-function + computed-pointer caveats logged in §1).
- **Read-only compliance.** Exactly one repository file written: `docs/terrain_swarm_2026-11-26/reports/DEC_U_ureg_ctor.md`. No code/shader/asset/config/Godot/git change. No donor file opened for write or executed. Investigation memory was not overwritten by this worker (reads only).
- **Claim register (audit-level):** (1) schema-init `+0x54…+0x64` string-key run byte-proven via `8d43/ba/e8` repetition — `[O]/[D]` new; (2) `hmapTex @0x853e0c` + `hmapMin @0x853e3c` single-hits, `HeightMapTexUnit @0x852b84` new single-hit VA — `[O]` new; (3) shader ctor `0x856080` own-field `+0x54…+0x64` numerics + full `+0xd0…+0xec` defaults + `C+0xf4→0x853ad4` call edge — `[D]` new; (4) zero target-offset stores in all five testable TOSW-linked bodies — `[D]` new; (5) partial single-instance ownership (uniform slots + descriptor pointer + height slot on one `C`, height pointee class unproven) — `[D]/[U]`; (6) no parity, no value closed, no `[U]` promoted — `[O]` scope guard.

*End of DEC-U-UREG-CTOR.*
