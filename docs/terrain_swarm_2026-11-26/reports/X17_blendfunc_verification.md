---
id: X17
ticket: "TERRAIN-SWARM-2026-11-26 / X17 — independent verification of D08 bmTransparency blend finding"
title: "Verification: bmTransparency = fixed-function glBlendFunc(SRC_ALPHA, ONE_MINUS_SRC_ALPHA), not an albedo multiply"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY
owner_file: docs/terrain_swarm_2026-11-26/reports/X17_blendfunc_verification.md
target_used: "C:\\Games\\Cossacks 3\\cossacks.exe — pinned document:\"t_87f0f3c130b0\" on EVERY native call; sha256 87f0f3c130b0…; active target was already this document and was never changed by this worker"
secondary_sources: "Donor text read by absolute path via core_text_read (hf.pvl.smx3.frag, hf.pvl.smx9.frag, hf.pvl.sm.vert, shaders.lib); port shader read by absolute path (terrain_tileindex.gdshader). No core_target_open / core_target_select call."
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_claim: false
scope_guard: "Donor READ ONLY. No donor binary executed, copied, committed or modified. No repo source/shader/config/asset/test/git edit. No Godot job. No Craft Anything brief/hypothesis/finding mutation. Temp scripts: none. One file written: this report."
---

# X17 — Independent verification of the D08 `bmTransparency` finding

## 0. Executive summary

1. **[D] D08's central finding is CONFIRMED, and refined at instruction level.** The terrain material switch `sub_4ef810` case 1 (`bmTransparency`) executes `mov cl,7; mov dl,6; call 0x88fb78` at VA `0x4ef991…0x4ef995`. `sub_4ef810` is a cached `glBlendFunc` setter: it pushes `table[cl]` first (dfactor) and `table[dl]` second (sfactor) before the single thunk call to the imported `glBlendFunc` (`0x4afb14` → IAT `0x907d90`). `table[6]=770=GL_SRC_ALPHA`, `table[7]=771=GL_ONE_MINUS_SRC_ALPHA`. Exact call site: **VA `0x4ef995` / file `0xeed95`**; exact push sites: **VA `0x88fbab` / file `0x48efab`** and **VA `0x88fbb7` / file `0x48efb7`**. This is **[O]** bytes + **[D]** ABI/GL-enum interpretation, not a guess.
2. **[O] The donor shader cannot perform the blend.** `hf.pvl.smx3.frag:13-14` sets `color.rgb=texUnit0.rgb` and `color.a=texUnit1.a`; the only RGB operations are lighting (`:17`), shadow (`:20-30`) and fog (`:34-46`); `:50` writes `gl_FragColor=color` with the mask alpha intact. The SM30 twin `hf.pvl.smx9.frag` is identical in mask handling; `shaders.lib:15-49` binds this program as `HeightField` with `texUnit0→0`, `texUnit1→1`. There is **no mask→RGB multiply anywhere in the donor shader pair**, and `bmTransparency` appears in **zero** donor shader files (F06-E17, rechecked here). Blend is therefore fixed-function framebuffer composition.
3. **[D] The mask is a framebuffer crossfade weight, so `rgb*a` in the port is a PORT APPROXIMATION.** Donor equation: `dst.rgb' = src.rgb*src.a + dst.rgb*(1-src.a)` with the blend equation left at the GL default `GL_FUNC_ADD` (no `glBlendEquation` import; extension-string caveat in §5.3). The port's `terrain_tileindex.gdshader:427` folds the mask into albedo and `:475` forces `ALPHA=1.0`; it cannot reproduce the donor's over-operation against an existing framebuffer layer.
4. **[U] Pass count remains CONFIRMED_UNVERIFIED — six passes attempted (§4.3).** No compositing loop, no pass-count constant and no static xref to `tsDouble`/`AlphaRows` was recovered. `tsDouble` exists as enum value 1 of `tsSingle/tsDouble/tsTrip…`, which is suggestive but is **not** proof of a two-pass composite. "One pass" and "two passes" are equally unproven; neither is asserted as donor fact.
5. **[D] Exact Godot equivalent for a fresh shader:** a **base opaque layer** (`ALBEDO = shaded_rgb`, `ALPHA = 1.0`) plus an **overlay layer with `render_mode blend_mix`** whose `ALPHA` is the unmodified mask-sampler alpha (`texture(alpha_atlas, uv).a`, or `.a` from `alphavert_atlas` for face refkeys) and whose `ALBEDO` is the shaded neighbour tile RGB. No clamp, floor, `step`, guard or `rgb*a` belongs in that overlay. Layer count is a **PORT APPROXIMATION** until pass count is resolved.

**No donor parity claim is made.** Every substitute is labelled.

---

## 1. Evidence table

All Craft Anything evidence ids below were produced by read-only tools pinned to `document:"t_87f0f3c130b0"` (text files by absolute `path`). VA = virtual address; FO = file offset in `cossacks.exe` (sha256 `87f0f3c130b0…`).

| Ev id | Label | Source (VA / FO / path:line) | Claim established |
|---|---|---|---|
| `ev_5447b688fc4109ed3cfc0d671069b2637ace8b80270b7f2c848cd2f700e25931` | [D] | Deep Ghidra `FUN_004ef810` | case 1 calls `FUN_0088fb78(ctx,6,7)`; cases 2/5 call it with `(6,1)`/`(4,0)`; cases 3/4 set alpha refs 0.5/1.0. |
| `ev_c6b5ab46f70762cbf2274a9f42811ce6c00629dfe47c3d2b34c78e5eda98cf16` | [O] | `cossacks.exe` VA `0x4ef810`, 224 insns (case 1 block `0x4ef97a`, jump table at `0x4ef949`) | `mov cl,7` `0x4ef991`; `mov dl,6` `0x4ef993`; `call 0x88fb78` `0x4ef995`; no loop in the state switch. |
| `ev_5712274624bc0201cf4f9a6eb885e14b86709ee52d8f639f885e41aff2c28cb4` | [O] | VA `0x4ef995` / FO `0xeed95` | call bytes `e8de013a00` → `0x88fb78`; xref `0x4ef995 → 0x88fb78`. |
| `ev_45ddf9349fb864a4e5cb33128c6d6cf5d53ac7adbbdcc32f1c63e77f1339b610` | [O] | VA `0x4ef991` / FO `0xeed91` | unique 9-byte pattern `b107b206e8de013a00` = enum setup + call; 1 match in whole file. |
| `ev_3433b85570a2c94dc30d03ed4dd3e83eb52c81284c6fcfe74afe097df6422e13` | [O] | VA `0x4ef995` / FO `0xeed95` | call pattern `e8de013a00` occurs exactly once in the binary. |
| `ev_5071f34e67c6214d7a00cc21b9e1eec5596477010b3e42b4f2deaf886017cfde` | [O] | VA `0x88fb78`, 18 insns | setter: cache at `+0x130/+0x132/+0x131/+0x133`, `mov eax,[eax*4+0x8fb1ac]` twice, two pushes, one `call 0x4afb14`. |
| `ev_c1deccbb4d0ee7f7be5a71848a589d4efa40649591466eb91b42a9295dd9cd6c` | [O] | VA `0x88fba4` / `0x88fbb0` | instruction-level register flow: first table load reads **CL**, second reads **DL**; pushes at `0x88fbab`, `0x88fbb7`. |
| `ev_b23046977bdcacb7641e754a4470a366ec870b35126afbc2ac0e5351ae65df6b` | [D] | Deep `FUN_0088fb78` | signature `(param_1,char param_2,char param_3)`; guard `if changed` → `glBlendFunc()`; named params confirm `dl=6` is sfactor-index, `cl=7` dfactor-index. |
| `ev_2d7da1f86d021e5348557628f3b29fe8bf29917cafc70e9e6e5170491ae58152` | [O] | VA `0x88fba4` FO `0x48efa4`; VA `0x88fbb0` FO `0x48efb0` | two `8b0485acb18f00` table-load sites, exactly 2 matches. |
| `ev_fdfecb941f386018a05d8c59402c17a21b0aee5cc810aea1b5319fa2886d02cb` | [O] | VA `0x88fbb8` / FO `0x48efb8` | thunk call `e857ffc1ff` → `0x4afb14`; exactly 1 match. |
| `ev_c4086bd0e6e482d8eb48689f951a9d3e59ffc13d900e41c43982cb81ee196c73` | [O]/[D] | import `glBlendFunc` IAT `0x907d90`, thunk `0x4afb14` | sole call site is `0x88fbb8`; no other caller anywhere in the pinned target. |
| `ev_b5ba9e1f62be01b6c51ee92acd4c518baa4f83f04ff15c9f58bb4696e38f02b6` | [O] | VA `0x8fb1ac` / FO `0x4fa3ac`, 96 B | full u32 factor table: idx 0..8 = `0,1,0x300,0x301,0x306,0x307,0x302,0x303,0x304,0x305…`. |
| `ev_2c730d467271ac769eec8d7c52fa49ee70a4dfdaae73827548dfd41d55fad39e` | [O] | VA `0x8fb1c4` / FO `0x4fa3c4` | bytes `02 03 00 00 03 03 00 00 04 03 00 00 05 03 00 00`, one match; idx6/idx7 adjacent. |
| `ev_ef6544a26ac25cf88283eff4dc8c3135ef91975d03393c59481e72ee111b7758` | [O] | VA `0x8fb1c4` / FO `0x4fa3c4` | `u32 = 770 = 0x302 = GL_SRC_ALPHA`. |
| `ev_4d202b29454dccf08d3a658c163f2de7930ce714e4c34ceeb1865f5fd2855a51` | [O] | VA `0x8fb1c8` / FO `0x4fa3c8` | `u32 = 771 = 0x303 = GL_ONE_MINUS_SRC_ALPHA`. |
| `ev_e004484861aa995492943873ff7218a67675cbe3197b9a488961efa54efa0dbf` | [O] | VA `0x4e87d0` / FO `0x4e87d0` region (CODE) | length-prefixed enum names in order: `bmOpaque`(0), `bmTransparency`(1), `bmAdditive`(2), `bmAlphaTest50`(3), `bmAlphaTest100`(4), `bmModulate`(5) — in **cossacks.exe itself**, not only editor.exe. |
| `ev_f06e8e729f4918357de00f8b2d4edace353f11ebf6c065e10de1661083029eb4` | [O] | VA `0x4e87f2` FO `949234`; VA `0x4e9714` FO `953108`; VA `0x87ee6c` FO `4711020` | 3 raw `bmTransparency` strings, all in CODE (Pascal shortstrings). |
| `ev_9f02774b26f980c4cde86fd95c9039a2891065e2aadaa3264dda747160f68517` | [O] (absence) | `native_strings_find` on pinned target | 0 matches — data-sections-only limitation, **not** a contradiction (see §5.1). |
| `ev_7198b45929c5b0019bbfc118668f6230cb1f9296ae069d35110c8de93bd0dbb2` | [O] | PE import table, opengl32.dll (128 imports) | only blend-related import is `glBlendFunc` at `0x907d90`. |
| `ev_92e48eb57715911aeecc5fc307e21558f32f10ab271cfd2cee6176f9a1ebdbf0`, `ev_5d044f7d276927da91a6f587b88020a3b633c064eede815a6a479b7d35e291cc` | [O] | name lookup | `glBlendFuncSeparate` / `glBlendEquation` are **not** functions, symbols or imports in this target. |
| `ev_9af33cb1d84468b479fd64ab70615b3378de157e1bbf0b485d116bac5e03767c`, `ev_a4c01eee258349192ca6c1f38cd485ea4e165b102ced38a6dcd48bc891d2d5b7` | [O]/[U] | VA `0x4b456c` + 7 other CODE addresses | `glBlendEquation` literal strings exist in CODE, 0 static xrefs — runtime extension resolution not excluded, not demonstrated. |
| `ev_da1b30dd125e226e04ee145e537a608fd440a759ec5110791c01df0cd7b7fe45`, `ev_645fe58ee44830fce5860cb28ef7d6137e480cbbb11b8e4d2cb20d4a84f84d12` | [O] | `sub_4ef810` cases 3/4 push `0x3f000000`/`0x3f800000`; `sub_88fb34` uses table `0x8fb18c`, idx7 `=518=GL_GEQUAL` | independent corroboration of the enum index → case mapping. |
| `ev_7c2c262d9ad63c0dac1316cca60eb6806b689f739429a1fcb656493165ab036e` | [D] | `native_function_callers_list(0x88fb78)` | 34 call sites; 3 in `sub_4ef810`, 31 elsewhere; none is a terrain compositing loop. |
| `ev_e0b2f3c5557ce62d4ef3823f79d2187b8b1726af04319ed78c060adf1ba379b8`, `ev_3164495a9e13a83e0193cb656433828ea2da797eb4ec1063e15c38ef0a3a7f10` | [D] | callers of `sub_4ef810` (19 sites); backward graph depth 2 | generic per-draw state setter, 21 functions in 2 levels, truncated, direct calls only. |
| `ev_c80d4b53e0806ff557580e89f06c94826a61063510db7fd64243fb43ec407761`, `ev_e945bdbeec84a7456c9c84c812c0606d4fdb6c672882eb5ab44415974fdcc6f5` | [O]/[D] | `sub_4f00dc`, 127 insns, Deep pseudocode | two **mutually exclusive** branches, each applying `sub_4ef810` once; no repeated state application in the generic draw dispatcher. |
| `ev_9bc98efae070703c9c04835bc4aebd57b02a817f421d7a5d62f02c09c2f0b2f0`, `ev_5f262ed090b30893b0c93faae923d2f61b147b535724b606d47e4c325e85e83a`, `ev_e0776f61a66ef0ba35f19b35f942536215a0aa71801a4840d2ebda79299b88aa` | [O]/[U] | `tsDouble` VA `0x543b11`; enum cluster at VA `0x543ac0` (`tsSingle`,`tsDouble`,`tsTrip…`); 0 static xrefs | scheme enum exists; no code consumer recovered. |
| `ev_62fc7723eac37496cf8a7f902291c9dae257dd458e311e7ed0e602d52d0436b6`, `ev_bfd255599224885a68b9cf8ef5a37c15f3e7493bbe968fd91a6ac0608e7b5e6a` | [O]/[U] | `AlphaRows` VA `0x543e1e`/`0x5448cc` in CODE, 0 static xrefs | alpha geometry field names exist; no pass-count logic reachable. |
| `ev_187c435bba0e8c5dd35b5e6ca9d8f0ba4338eaae07c5dab0d30ab0f29bf21560`, `ev_b88143aac3251eb093356893245441e322afed204d720c46396f2d51fd4fa953` | [D]/[U] | studies of `sub_7829a4` (425 blocks / 6224 insns / 8 blend-setter sites) and `sub_53dae0` (14 blocks) | large complex callers, but no recovered terrain-pass loop; pass count not decidable. |
| `ev_127a685b602cd247192383290bc7d4892981d8c323b7861fcd88e792ec7f2ad1` | [O] | `data/shaders/obj/hf.pvl.smx3.frag:1-51` (sha256 `9a35b0d2…`) | RGB from texUnit0, alpha from texUnit1, no mask→RGB multiply, `gl_FragColor=color`. |
| `ev_217d3f513b300a4c604b78e7c210599920950ab1d6a6cf158015f64b8d2a4bc0` | [O] | `data/shaders/obj/hf.pvl.smx9.frag:1-56` | SM30 twin, identical mask handling. |
| `ev_99c2c38913e612e8c12857f20cf61ac7f9f4318f4afec0a320cd78a933fb8dbb` | [O] | `data/shaders/obj/hf.pvl.sm.vert:25-34` | texgen only for `gl_TexCoord[0]`; `gl_TexCoord[1]=gl_MultiTexCoord1`. |
| `ev_8b9cbf20be1065c697ea30336afafe9f0fd5796f745c83f3580cfe475e9399ff` | [O] | `data/shaders/shaders.lib:15-49` | `HeightField` SM20 program = these vert/frag files, `texUnit0=0`, `texUnit1=1`, `texGen=true`. |
| `ev_eb20f555c2518afb3b331f8e15ab1c56fd92a8b006d3337c31342f8516d0652b`, `ev_3013f6241acc0de2e4a5df6d03efa06d3cda9ef8088c30a978d49a90e0ba2d84`, `ev_015b5e181ed6ae6576007f6c0aa270e0e99efa3c67019cb00f4af6c61e570625` | [O] (port) | `variant3d/shaders/terrain_tileindex.gdshader:42`, `:396-419`, `:427`, `:475`, `:235-248` | current port is `render_mode blend_mix, unshaded, cull_disabled`; mask folded into albedo at `:427`; `ALPHA=1.0` at `:475`; `mask_to_alpha` knob declared at `:235`. |

---

## 2. Method and multi-pass log

**Target discipline.** `core_session_show` reported active target `t_87f0f3c130b0` (cossacks.exe) and Deep mode. Every native call passed `document:"t_87f0f3c130b0"` explicitly. No target-open/select call was made; no other worker's active target was touched. Donor shader/lib text and the port shader were read by absolute path; those reads do not change the active target. No donor binary was executed.

**Passes on the blend lead (all contradictions handled openly):**

| # | Instrument | Result | Accept/reject |
|---|---|---|---|
| 1 | `native_function_disassemble(0x88fb78)` + `native_function_instructions_list` (`ev_507…`, `ev_c1de…`) | 18 insns; two table loads through `0x8fb1ac`, first from CL then from DL; one `call 0x4afb14` | Accepted [O] |
| 2 | Deep `native_function_pseudocode(0x88fb78)` (`ev_b230…`) | `FUN_0088fb78(param_1, char param_2, char param_3)`, calls `glBlendFunc()` only on state change | Accepted [D]; agrees with pass 1 on argument order |
| 3 | `native_bytes_find` for setup/call/load patterns (`ev_45dd…`, `ev_3433…`, `ev_2d7d…`, `ev_fdf…`) | unique VA/FO hits: `0x4ef991/0xeed91`, `0x4ef995/0xeed95`, `0x88fba4/0x48efa4`, `0x88fbb0/0x48efb0`, `0x88fbb8/0x48efb8` | Accepted [O]; D08's addresses independently reproduced |
| 4 | `native_data_show` + raw pattern on factor table (`ev_ef65…`, `ev_4d20…`, `ev_2c73…`) | idx6=770, idx7=771, file `0x4fa3c4` | Accepted [O] |
| 5 | `native_function_disassemble(0x4ef810)` + Deep pseudocode (`ev_c6b5…`, `ev_5447…`) | case 1 → `FUN_0088fb78(ctx,6,7)`; case 3/4 → alpha ref 0.5/1.0 via `0x8fb18c[7]=518` | Accepted [O]/[D]; enum mapping cross-checked |
| 6 | `native_name_xrefs_list(glBlendFunc)` + import table (`ev_c408…`, `ev_7198…`) | one import, one thunk, one caller | Accepted [O] |
| 7 | Import/name check for `glBlendEquation`, `glBlendFuncSeparate` (`ev_92e4…`, `ev_5d04…`) vs raw-string search (`ev_9af3…`) | **Apparent contradiction**: raw CODE strings exist but no imports/symbols/xrefs | Resolved: string literals are extension names, not calls in this path; default `GL_FUNC_ADD` retained as **[D]** with **[U]** runtime-extension caveat (§5.3) |
| 8 | `native_strings_find("bmTransparency")` = 0 (`ev_9f02…`) vs `native_bytes_find(text)` = 3 (`ev_f06e…`) | **Apparent contradiction**: tool coverage, not donor | Resolved: strings are length-prefixed Pascal shortstrings in CODE; data-section string search cannot see them. Raw-byte instrument accepted. |

**Passes on the pass-count lead:** see §4.3 (six instruments, all negative on a compositing loop; verdict **[U]**).

**Instrument reliability note.** The clean-room lifter's register labelling of `sub_88fb78` (`ev_c419…`, from the shared investigation memory) is coarse; the Deep Ghidra version (`ev_b230…`) plus raw instruction list (`ev_c1de…`) were used for the argument-order claim. This is the same accept/reject choice D08 recorded, independently re-derived here.

---

## 3. Findings

### 3.1 Exact instruction sites that supply the GL blend factors

Material-state switch (`bmTransparency` = enum 1 — enum order observed in this very binary, `ev_e004…`):

```
sub_4ef810:
  0x4ef934  xor eax,eax
  0x4ef936  mov al,[ebx+0x20]        ; BlendingMode byte
  0x4ef939  cmp eax,5
  0x4ef942  jmp dword [eax*4+0x4ef949] ; jump table
  ... case 1 -> 0x4ef97a ...
  0x4ef97a  mov eax,[esi+0x64]       ; GL context
  0x4ef97d  mov dl,2                 ; disable BLEND? (alpha-func helper)
  0x4ef984  mov eax,[esi+0x64]
  0x4ef987  xor edx,edx
  0x4ef991  mov cl,7                 ; DFACTOR enum index
  0x4ef993  mov dl,6                 ; SFACTOR enum index
  0x4ef995  call 0x88fb78            ; cached glBlendFunc setter
```

- VA `0x4ef991` / FO `0xeed91`: `b1 07 b2 06 e8 de 01 3a 00` — **one** match in the whole file (`ev_45dd…`).
- VA `0x4ef995` / FO `0xeed95`: `e8 de 01 3a 00` — **one** match (`ev_3433…`); instruction xref `0x4ef995 → 0x88fb78` (`ev_5712…`).
- Deep pseudocode (`ev_5447…`): `case 1: FUN_0088f0f0(ctx,2); FUN_0088f0f0(ctx,0); FUN_0088fb78(ctx,6,7); break;` — confirms which register is which parameter.

Cached setter `sub_88fb78` at VA `0x88fb78` (18 insns, `ev_507…` / `ev_c1de…`):

```
0x88fb78  cmp dl,[eax+0x130]      ; cached sfactor index
0x88fb80  cmp cl,[eax+0x132]      ; cached dfactor index
0x88fb88  mov [eax+0x130],dl
0x88fb8e  mov [eax+0x132],cl
0x88fb94  mov [eax+0x131],dl
0x88fb9a  mov [eax+0x133],cl
0x88fba0  xor eax,eax
0x88fba2  mov al,cl               ; DFACTOR index = 7
0x88fba4  mov eax,[eax*4+0x8fb1ac]  ; FO 0x48efa4 -> table[7] = 0x303
0x88fbab  push eax                  ; FO 0x48efab [D] = GL_ONE_MINUS_SRC_ALPHA
0x88fbac  xor eax,eax
0x88fbae  mov al,dl               ; SFACTOR index = 6
0x88fbb0  mov eax,[eax*4+0x8fb1ac]  ; FO 0x48efb0 -> table[6] = 0x302
0x88fbb7  push eax                  ; FO 0x48efb7 [D] = GL_SRC_ALPHA
0x88fbb8  call 0x4afb14            ; FO 0x48efb8, glBlendFunc@thunk
0x88fbbd  ret
```

Push order is **dfactor then sfactor**; cdecl's right-to-left argument order means `glBlendFunc(table[6], table[7])`. Factor table `0x8fb1ac` / FO `0x4fa3ac` (`ev_b5ba…`, `ev_2c73…`): entries `… idx5=0x307, idx6=0x302=770, idx7=0x303=771, idx8=0x304 …`; typed reads give `770` (`ev_ef65…`) and `771` (`ev_4d20…`). GL enum meanings `0x0302=GL_SRC_ALPHA`, `0x0303=GL_ONE_MINUS_SRC_ALPHA` follow the standard GL numbering (cross-checked by D08 against OCCT headers).

**[D] Verdict:** D08's factor identification is correct; the exact instruction sites and their file offsets are now pinned. The setter is called from 34 sites overall (`ev_7c2c…`), of which three are in this state switch; `glBlendFunc` itself has exactly one caller (`ev_c408…`).

### 3.2 Confirmation that this is fixed-function, not a shader multiply

- `hf.pvl.smx3.frag` (`ev_127a…`, all 51 lines read): lines 13–14 set `color.rgb` from `texUnit0` and `color.a` from `texUnit1`; line 17 multiplies RGB by packed lighting `gl_TexCoord[4].xyz + gl_TexCoord[5].xyz` (lighting, **not** mask); lines 20–30 shadow, 34–46 fog, line 50 `gl_FragColor=color`. **No mask arithmetic touches RGB.**
- `hf.pvl.smx9.frag` (`ev_217…`, all 56 lines): identical mask lines, 9-tap shadow variant. No blend math.
- `hf.pvl.sm.vert` (`ev_99c2…`): only `gl_TexCoord[0]` is texgen-driven; `gl_TexCoord[1]=gl_MultiTexCoord1` (mask UV from mesh). The shader never reads a neighbour tile or thresholds the mask.
- `shaders.lib:15-49` (`ev_8b9c…`): binds exactly these vert/frag files as `HeightField` (SM20), `texUnit0→unit 0`, `texUnit1→unit 1`, `texGen=true`. No alternate terrain program with mask multiply was found in this file segment; F06-E17 reports zero `bmTransparency` occurrences across all donor shaders.
- Engine side: the material's `BlendingMode` byte is consumed by `sub_4ef810` (§3.1) and translated into an OpenGL blend-state call. The fragment program only supplies `src.a`.

**[D] Exact equation for the composite** (GL fixed-function, blend equation unchanged from its GL default):

```
src.rgb = shaded tile RGB (hf.pvl.smx3.frag:13,17,20-30,34-46)
src.a   = texture2D(texUnit1, gl_TexCoord[1].xy).a
dst.rgb' = src.rgb * src.a + dst.rgb * (1 - src.a)
dst.a'   = src.a * src.a + dst.a * (1 - src.a)   ; same factors apply to alpha; usually unused
```

The mask is therefore a **coverage/crossfade weight against an already-drawn layer**, never an albedo multiplier. A single opaque pass with `rgb *= a` produces dark blotches where the donor produces a feathered transition; it is a **PORT APPROXIMATION** (also labelled in D08 §3.5 and F06 §6).

### 3.3 Pass count — **[U] CONFIRMED_UNVERIFIED**

D08 records `[U]`; this worker attempted six passes and could not decide it:

| Pass | Instrument | Observation | Why not decisive |
|---|---|---|---|
| 1 | Full disassembly of `sub_88fb78` (18 insns, `ev_507…`) | caches 2 indices, emits 1 `glBlendFunc` | setter is per-state-change, no loop |
| 2 | Full disassembly of `sub_4ef810` (224 insns, `ev_c6b5…`) | case 1 calls the setter once, then continues to draw dispatch | no repeated application of blend state for a second layer |
| 3 | Callers of both setters (`ev_7c2c…`, `ev_e0b2…`) | 34 / 19 direct call sites, all generic engine subsystems | no terrain-specific "base + mask" pair identified |
| 4 | Backward call graph depth 2 (`ev_3164…`) + Deep pseudocode of generic dispatcher `sub_4f00dc` (`ev_c80d…`, `ev_e945…`) | 21 functions; dispatcher has two **mutually exclusive** branches, each applying the state once | truncated at depth 2, indirect calls not followed; terrain draw may sit deeper/behind pointers |
| 5 | Raw byte/string search for `tsDouble`, `AlphaRows`, `TileScheme` (`ev_9bc9…`, `ev_5f26…`, `ev_62fc…`) + xrefs (`ev_e077…`, `ev_bfd2…`) | `tsSingle/tsDouble/tsTrip…` enum found (`tsDouble=1`), `AlphaRows` field names found; **0 static xrefs** | suggestive of a two-tile scheme, but no consumer code recovered; cannot infer pass count |
| 6 | Studies of the largest blend-setter callers `sub_7829a4` / `sub_53dae0` (`ev_187c…`, `ev_b881…`) | 425 blocks / 6224 insns with 8 setter sites; 14 blocks with 2 sites | complex generic render code, 1873 inline-asm insns / indirect calls; no terrain pass loop reconstructed |

**Verdict [U] CONFIRMED_UNVERIFIED.** Do not encode "two passes" (from `tsDouble`) or "one pass" (from the generic dispatcher) as donor fact. A GPU trace or a decoded packed `.bind` mesh builder would be needed; neither is permitted/available under this read-only charter.

### 3.4 Exact Godot equivalent for a fresh shader

Godot's `blend_mix` render mode is the documented spatial equivalent of `glBlendFunc(SRC_ALPHA, ONE_MINUS_SRC_ALPHA)` (straight alpha). Donor-faithful shape, using **only** values already recovered from the donor (no invented constants):

```
# Layer A — base tile (opaque substrate)
render_mode blend_mix, unshaded;    # ALPHA=1.0 makes this source-replacing
ALBEDO = shaded_rgb(base_tile);
ALPHA = 1.0;

# Layer B — masked neighbour tile; separate draw of the same cell/region
render_mode blend_mix, unshaded;
ALBEDO = shaded_rgb(neighbour_tile);   # donor lighting/fog applied, not mask-modulated
ALPHA  = texture(alpha_atlas, mask_uv).a;      // flat: alpha.bmp-derived sampler
# or    = texture(alphavert_atlas, face_mask_uv).a;  // vf/vs: alphavert projection
```

- The **only** place the mask enters is `ALPHA` (donor `hf.pvl.smx3.frag:14` → `gl_FragColor.a`). There is no `rgb * a`, no `clamp(a,0.35,1.0)`, no `step(2.5,…)`, no `mask_to_alpha` blend.
- `blend_mix` on layer B performs `src.rgb*src.a + dst.rgb*(1-src.a)` against the framebuffer containing layer A — the exact donor equation of §3.2.
- Layer A must be drawn first and must write depth/behave as opaque substrate; layer B must composite over it. **How many such layers the donor actually draws is [U]** (§4.3), so a two-layer Godot implementation is itself **PORT APPROXIMATION** with respect to pass count, not a donor-parity claim.
- The fresh shader should preserve donor lighting/shadow/fog on RGB before the blend and leave `ALPHA` purely mask-derived. The existing port's `render_mode blend_mix, unshaded, cull_disabled` (`ev_eb20…`) is a port decision (`unshaded` because lighting is packed in-vertex; `cull_disabled` is a port guard against donor `fcCull`) — do not present either as donor truth.

---

## 4. Implications for spec §06 and the I10 / fresh shader

1. **spec/06_TILE_AND_ATLAS.md §5 (currently "factors and pass count remain [U]")** — split the claim: factors are now **[D]** and cite VA `0x4ef991/0x88fbb0/0x88fbb7`, table `0x8fb1c4/0x8fb1c8`; equation is **[D]** with the default-`FUNC_ADD` caveat; pass count stays **[U]**. The existing statement "donor fragment does no mask math" is **[O] CONFIRMED** by full reads of both SM20/SM30 fragments and `shaders.lib`.
2. **spec/05_WATER_SHORE.md §7** repeats the same "factors/pass count [U]" shorthand; it needs the same split. No shore/water tile semantics change as a result of this verification.
3. **I10 / fresh tile shader:** `terrain_tileindex.gdshader:427` (`rgb = rgb * mix(1.0,a,mask_to_alpha) * v_packed + v_specular`) and `:475` (`ALPHA=1.0`) must be treated as **PORT APPROXIMATION**, not as a donor-substitute that "achieves the same blend". The clean target shape is §3.4: base opaque + `blend_mix` overlay with mask in `ALPHA`.
4. **Do not carry over port-only mask guards into the fresh shader as donor rules.** The `0.35` floor, `0.5` mix strength, `step(2.5,…)` sentinel guard and id-bit patch selector are PORT APPROX (F06 §5–6, D08 §3.5); the donor shader contains none of them.
5. **Alpha sentinel binding stays donor-grounded:** `alphanull` on ids 86/110/123 gives `src.a=0` → tile contributes nothing to the framebuffer — a clean fit with crossfade semantics. The port's "8 zero ids" remain PORT APPROX.
6. **No spec claim about visual outcome changes.** Without a donor GPU A/B frame, "crossfade looks like donor" is not assertable; only the blend-state mechanism is verified.

---

## 5. Risks

- **R1 — Factor certainty ≠ visual parity.** The GL factors are pinned to bytes; layer geometry, mask UV source and pass count are not. A correct blend over the wrong layer cannot produce donor visuals.
- **R2 — Extension ambiguity.** `glBlendEquation`/`glBlendFuncSeparate` strings exist in CODE with zero static xrefs; if resolved through `wglGetProcAddress` at runtime they could alter the equation elsewhere. No evidence ties them to `bmTransparency`; `GL_FUNC_ADD` remains **[D]** with a **[U]** tail.
- **R3 — Pass-count guessing.** `tsDouble=1` and "two mutually exclusive branches in `sub_4f00dc`" are tempting but neither is a compositing-pass count. Hard-coding a two-pass composite must be labelled APPROX.
- **R4 — Premultiplied-alpha mistake.** `blend_mix` expects straight alpha; the donor texture is an intensity converted to alpha (`tiaAlphaFromIntensity`, whose exact formula is **[U]**). Pre-multiplying `ALBEDO` by `ALPHA` in the overlay would reintroduce the current port's bug in a new place.
- **R5 — Shared-session evidence ids.** One early name-xref observation in D08 came from the wrong target during a race; this worker pinned `document:` on every native call and re-derived every id used above. Evidence ids from the shared investigation memory (`ev_c419…`, `ev_b230…`) are cited only after re-running them here.
- **R6 — Tool-coverage absences.** `native_strings_find` saw 0 `bmTransparency` strings; raw byte search saw 3. Absence from one instrument is never treated as donor absence.

---

## 6. UNVERIFIED register (with passes attempted)

| # | Item | Status | Passes attempted here |
|---|---|---|---|
| U-X17-1 | Number of fixed-function composite passes / draw order for `bmTransparency` | **CONFIRMED_UNVERIFIED** | six passes: setter disasm, state-switch disasm, 34/19 caller lists, backward call graph + generic dispatcher pseudocode, `tsDouble`/`AlphaRows` raw strings + 0 xrefs, studies of the two largest callers. No loop or pass-count constant recovered. |
| U-X17-2 | Whether a runtime-resolved `glBlendEquation`/`glBlendFuncSeparate` changes the equation | **UNVERIFIED** | import table (only `glBlendFunc`), name lookup (2 not found), 8 raw CODE string hits, 0 static xrefs on one representative address. Default `GL_FUNC_ADD` accepted **[D]** for this path. |
| U-X17-3 | Exact intensity→alpha conversion (`tiaAlphaFromIntensity`, `tfAlpha`) | **UNVERIFIED** | out of scope for this ticket (F06 U-F06-3); donor shader reads `.a` from a bound alpha texture, conversion is engine-side. No value invented. |
| U-X17-4 | Tile-id + direction → `gl_MultiTexCoord1` patch selector | **UNVERIFIED** | `AlphaRows` field names found in CODE with 0 static xrefs; no tile→patch code recovered. Port bit decomposition remains PORT APPROX. |
| U-X17-5 | Runtime GPU result / visual parity | **UNVERIFIED** | no donor executable run, no A/B frame; explicitly not claimed. |

---

## 7. Open questions

1. Which engine module writes `gl_MultiTexCoord1` per tile vertex, and does it also decide how many overlays are composited? (Would resolve U-X17-1 and U-X17-4 together.)
2. Are the blend ext strings (`glBlendEquation`, `glBlendFuncSeparate`) resolved via `wglGetProcAddress`, and is either pointer stored near the GL context object at `+0x130/+0x132`?
3. Does `tsDouble` correspond to two *draws* or two *tile schemes in one mesh*? The enum order `tsSingle/tsDouble/tsTrip…` is observed; its consumer is not.
4. Does the donor clear depth between base and mask layers, or rely on identical depth values (which would affect a faithful Godot layer setup)?
5. Can the fresh Godot module carry a neighbour tile id per vertex so overlay `ALBEDO` is donor-shaped rather than invented? (Port mesh currently has one id per cell — F06 Q5.)

---

## 8. Bottom line

D08's consequential finding survives independent verification: the donor pushes `GL_SRC_ALPHA`/`GL_ONE_MINUS_SRC_ALPHA` into `glBlendFunc` from a material-state switch at **VA `0x4ef991`/`0x88fba4`/`0x88fbb0` (FO `0xeed91`/`0x48efa4`/`0x48efb0`)** using the factor table at **VA `0x8fb1c4`/`0x8fb1c8` (FO `0x4fa3c4`/`0x4fa3c8`)**; the donor fragment shaders contain no mask multiply; hence the alpha mask is a framebuffer crossfade weight and the port's `rgb*a` at `terrain_tileindex.gdshader:427` is a **PORT APPROXIMATION**. Pass count remains **[U] CONFIRMED_UNVERIFIED** after six passes. The faithful Godot shape is an opaque base layer plus a `blend_mix` overlay whose `ALPHA` is the raw mask-sampler alpha and whose `ALBEDO` is unmodified shaded RGB. **No donor visual parity is claimed.**

*End of X17. Files written: this report only. Donor read-only; no binary executed, copied or committed; no source/shader/config/asset/test/git/Godot state changed; no Craft Anything investigation memory mutated.*
