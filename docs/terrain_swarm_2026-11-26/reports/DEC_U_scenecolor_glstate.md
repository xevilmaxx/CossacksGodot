---
id: DEC-U-SCENECOLOR-GLSTATE
ticket: "TERRAIN-SWARM-2026-11-26 / close PORT1TO1-RENDER U-1 + U-2 and map the complete fixed-function light/material state consumed by hf.pvl.sm.vert"
agent: "DEC-U-SCENECOLOR (READ-ONLY subagent; no code, no Godot, no git; donor read-only, never executed/copied)"
date: 2026-11-26
status: DELIVERED__ONE_REPORT_ONLY__NO_PARITY_CLAIM
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor_root: "C:\\Games\\Cossacks 3"
target_pinned: "t_87f0f3c130b0 (cossacks.exe, PE x86 32-bit, 5768048 B, sha256 87f0f3c130b0…)"
labels_used: [O, D, U]
passes: "<= 4 per function (Deep pseudocode / raw disassembly / xrefs-callers / raw bytes); strange decompiles logged in §2.3"
parity_claim: false
scope_guard: "Exactly one repo file written (this report). Global active Craft Anything target was never opened or switched; every native call passed document:'t_87f0f3c130b0' or an explicit donor path. No donor binary executed, copied, patched or committed; no repo code/shader/config/asset/test/git/Godot edit."
---

# DEC-U-SCENECOLOR-GLSTATE — sceneColor, the `glLightModeli` pnames, and the fixed-function light/material state

## 1. Result in one paragraph

Both blocking unknowns in `PORT1TO1_terrain_renderer.md` §9 are closed with byte-level
evidence:

* **U-1 (`sceneColor`): [O]+[D] recovered.** It is not zero, not the `light.cfg`
  ambient and not the `colors.lib` `Ambient` statictable field. The renderer
  constructor builds a colour object whose RGBA float vector at `+0x18` is a
  **16-byte copy from `0x8f58dc`**, whose bytes are `cd cc 4c 3e` ×3 +
  `00 00 80 3f` = **`(0.2f, 0.2f, 0.2f, 1.0f)`**. `sub_4d13d4` passes exactly
  `*(renderer+0x11c) + 0x18` to `glLightModelfv(GL_LIGHT_MODEL_AMBIENT)`. A
  residual **[U-R1]** (no static proof that *no* computed-pointer write ever
  mutates that vector) is stated with an exact experiment in §7; it is **not**
  an excuse to invent a different value.
* **U-2 (`glLightModeli` pnames): [O] recovered.** Both call sites use pname
  **`0x0B52 = GL_LIGHT_MODEL_TWO_SIDE`** — *not* `0x0B51` (LOCAL_VIEWER). The
  two sites differ only in the boolean: `1` when `byte[renderer+0x123] & 8`,
  else `0`. The constructor stores `5` at `+0x123`, so at startup bit 3 is
  clear and the donor issues `glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, GL_FALSE)`.

`sub_4d13d4` is in fact a **whole renderer-state prologue**, and its GL enums
are fully typed in §5. The light and material uploaders (`sub_4d08bc`,
`sub_88f3e8`) are typed in §6; these settle the prior
`DEC_SMALL_light_products` U-LP-3 slot→enum unknown.

**No donor visual parity is claimed.** No A/B GL frame exists.

---

## 2. Method, target discipline and evidence register

### 2.1 Discipline

* `core_session_show` at start: `active_target = t_87f0f3c130b0`,
  `analysis_mode = deep`, `clean_room = false`. This worker issued **no**
  `core_target_open`/`select` and no global target switch.
* Every `native_*` call carried `document: "t_87f0f3c130b0"`; every donor text
  read used an absolute `C:\Games\Cossacks 3\…` path. Rizin and objdump were
  probed and reported `engine_missing`; all conclusions therefore rest on the
  built-in disassembler and the Deep (Ghidra 12.2) lifter, cross-checked against
  raw bytes via `native_bytes_show`/`native_bytes_find`.
* Pass budget: Deep pseudocode + raw disassembly + callers/xrefs + targeted
  byte reads, ≤4 passes on any one function. Starting documents re-read in
  full: `PORT1TO1_terrain_renderer.md`, `DEC_SMALL_light_products.md`; donor
  text re-read: `colors.lib`.

### 2.2 New evidence (all `document: t_87f0f3c130b0` unless a path is shown)

| Evidence id | Operation | Establishes |
|---|---|---|
| `ev_0148aed73185622f0b78f258e623b0f08ab37d10b3c400f0dd1cfd4b787cf44d` | Deep `FUN_004d13d4` | call list; args stripped; `glLightModelfv(); glLightModeli(); glLightModeli()` |
| `ev_39378c31c7258e7508e81325dcbb3e8503abd0b1cf43ada54de88bee37b9538f` | raw `sub_4d13d4`, 87 insns | **all pname/boolean immediates**, state enums, exact pointer arithmetic |
| `ev_f23e549a8eb29adc1c8192b8bd6052a15eb5ee7a59d5c16a622ccca28760fde5` | `native_function_show 0x4d13d4` | 286 B, 9 blocks, 2 callers, 15 calls out |
| `ev_0f20444c6bc96cd612297ec1f005fbfadf26100671d5da3f7ef4a2ad7578aa42` | callers of `0x4d13d4` | `sub_4d10c8@0x4d121e`, `sub_4d24d8@0x4d25de` |
| `ev_76aefd942a1e5191848389ba464c326e29bc2f6a6e0ff29b46628b8e534794e4` | instruction `0x4d13ec` | `push 0xb53` = `GL_LIGHT_MODEL_AMBIENT` |
| `ev_cbd56d8d73b2df71a4f4456a0ff61eea393f654a1eac203b7664ddc72ea975cc` | `native_value_flow_show 0x4d13d4` | 87 ops; `rax` def-use `0x4d13e0 → 0x4d13e6 → push @0x4d13eb` |
| `ev_0075595231ed60441c82de8f1ee2c4d607a1b5d0a2aa5f316653f7a00446841f` | Deep `FUN_004e9bec` | `return param_1 + 0x18;` |
| `ev_e09c618e62bd744c6bae53c7327e051a458504d0b55e8eac918694eec7cb4bca` | raw `sub_4e9bec` | `add eax,0x18; ret` (2 insns) — colour-RGBA accessor idiom |
| `ev_04b2a4bf82e0cd05c6108fc5ec9d6f116cb5cfccb0a030007f32f2aee603e79e` | callers of `0x4e9bec` (23) | same idiom used for `glFogfv`, `glLightfv` ambient/diffuse/specular |
| `ev_6bf8caabb50d64f4e9f818b2afb50fcb203bd6f00c3c508beb4899ff87c69311` | Deep `FUN_004e9ca4` | colour-scheme constructor: `+0x18 ← copy(0x8f58dc)`, `+0x1c ← copy(0x8f58fc)` |
| `ev_291101a1945e3757ed4cb84d01a7698061f1cfe37d5e76019c4e43e4adf6d89d` | raw `sub_4e9ca4` | `push 0x8f58dc` at `0x4e9cbf`; `call 0x4e99cc` at `0x4e9cd1` |
| `ev_78af8a18833c310d9e856ccf0fff9a7fc942702c708a69d4cb70c5c85d1c9dd8` | Deep `FUN_004d0de8` | **renderer constructor**: `+0x11c = FUN_004e99cc(…,PTR_DAT_008fcac0)`; `+0x123 = DAT_004d0ef0` |
| `ev_aa017001cc504ab206599185381d3b58e9c7f94541708b747e9585357ee8989e` | Deep `FUN_004e99cc` | factory: virtual `+0xc`, then `FUN_004e9a58(obj,param_6)` |
| `ev_23cedeec701d8fed6aac588aee1a0809303014acf40dd12f91b5393660d6c074` | Deep `FUN_004e9a58` | `FUN_004a229c(obj+0x18, param_2)` |
| `ev_2c6ec63e81e771305b5ef35fc75b451a6744e06346852b9682a9866c664ccf3d` | raw `sub_4e9a58` | `lea eax,[ebx+0x18]; call 0x4a229c` at `0x4e9a64` |
| `ev_f98c3f3f6944eebb66dfcbdd108877bfed8943fdb5d17cf1c738164be7721d51` | Deep `FUN_004a229c` | copies `param_2[0..3]` → `param_1[0..3]` |
| `ev_a59ca01b994455dfa3fc0e7400434ee1ba62791dcea43eae0d4f2674064b16b0` | raw `sub_4a229c` | four `mov` dwords at `+0,+4,+8,+0xc` |
| `ev_b80b201e745efa2af2a668a3ca97ab59f2828e7acef99c5ef8f1e9edd1db395c` | `native_data_show 0x8fcac0` | `pointer[217]`, first element `0x8f58dc` |
| `ev_2983dc9aef8640ee55303d8868ab7b69131941459666d500d39e39590999ae19` | bytes `0x8fcac0`, 64 B | `dc 58 8f 00` = `0x8f58dc` is entry 0 |
| `ev_0cb2b604f010ba08bf5b9fd532a946bf7408cf1c4e666986186739aa24fc14ef` | bytes `0x8f58dc`, 16 B | **`cdcc4c3e cdcc4c3e cdcc4c3e 0000803f`** |
| `ev_f5ca03ddcfd5f0583bca59ef7dbf7b2e479b8ed8ba53751403a700c626b51c47` | bytes `0x8f58dc`, 64 B | neighbouring defaults `0.2/0.3/0.8/1/1` vectors, all α=1 |
| `ev_563a73fb4378e62d7be8e8f705ed8b4b3c70fd389946176ff2849e2cefd9722d` | `native_data_show 0x8f58dc` | typed first dword = `as_f32 0.2` |
| `ev_dd0b16e076924a2d081b8be1a8e69e7b42671b49e89beadaf7bb5f96e67685b4` | xrefs `0x8f58dc` | **1 static reference only** (`0x4e9cbf`, a `push`) |
| `ev_31f9ae3d89d33f268baa6c3f2ea065b85364b1c8c8666122c0e61b581ccb5711` | xrefs `0x8fcac0` | 3 static references, all reads; no writer |
| `ev_95d90f15169bbb30b605c2af11d99809b6cb77ba4862632852d65a830e6a927d` | bytes_find `a3 dc 58 8f 00` | 0 matches (no `mov [0x8f58dc],eax`) |
| `ev_84052a13ea3128ae857dec89788b8c5d8fd832a621210210a895fe14e00fa2e3` | bytes_find `c7 05 dc 58 8f 00` | 0 matches (no immediate store to `0x8f58dc`) |
| `ev_a410409ee923a08505699fd19e3257c3c0dc0bda7e0511731ffb6c33a3563a16` | `native_data_show 0x4d0ef0` | `u32 = 5` → `byte[+0x123]=5`, `5 & 8 == 0` |
| `ev_b11e6a798ab4c1f0cc7ef8248bcd5265d96dcd418c26d74da5dc72c3cb6425e5` | bytes `0x4d0ef0` | `05 00 00 00` |
| `ev_e951b5d0a52787f863c0d806736696c8e43c8a411bb6474b468b124fa7e43648` | bytes_find `c6 80 23 01 00 00` | 0 matches (no static `mov byte [eax+0x123],imm`) |
| `ev_f7f36c592b0234da8e24923eedc453730aa858384cc14445f4ee0c547f7a61aa` | Deep `FUN_004d139c` | param_3 is the GL enum; cache helpers `0x88f0f0/0x88f148` |
| `ev_c28fddfe7877aa20bba28a3cc6fb81a0356012b535f0d7a58e8432c721988f36` | raw `sub_4d139c` | `glEnable/glDisable(ecx)` via thunks `0x4afb8c/0x4afb6c` |
| `ev_45d056bab2e2416cfb52a7c6d39b1a82f44afc7c3790bf2cbf7a4d32a97d2055` | raw `sub_88f3e8`, 85 insns | **material slot→GL enum**: `0x1601` int + `0x1600/0x1200/0x1201/0x1202` vectors |
| `ev_b44f26b38e7f63961b71e1fdf699eba9ea619dedc2036dd81809916b722efbfd` | raw `sub_4d08bc`, 164 insns | **light slot→GL enum** `0x1200..0x1209`; per-light enable/disable; `glMultMatrixf` |
| `ev_818e7fcac02c131dda8b7567dcd36a49095adcc58b582c0542b6c150aa1b08a8` | Deep `FUN_0088fb14` | `glDepthFunc` cached setter, called with `2` |
| `ev_aa4c06ed726b4c299298f9d19cccd4ea725e2d3ca25d3cb7761d444eb24a979` | raw `sub_88fb14` | `table[dl]` at `0x8fb18c` |
| `ev_778088da1636eb21993ba4fe26056dd297cea11dbb42bbad19b6a54a2b78fb6e` | bytes `0x8fb18c`, 32 B | `[2] = 0x0201 = GL_LESS` |
| `ev_314245fee56090b5c7112693fac60be46782a59d2d760d0c85d165804dda65b8` | `core_text_read colors.lib` (103 lines) | statictable field order; `Ambient=255,255,255,255`; `LSAmbient=140,…`; `LSDiffuse=240,…` |
| `ev_0778a4ac4848d1bc8723e4f358b183d9c59205000e246ff4bcd53b8cfc` | bytes `0x585700`, 512 B | engine field-name registry in `colors.lib` order (`SkyDomeHorizon…LSAmbient…`) |
| `ev_84ac2998974b31ac365006c5f64c22b26457644d73d8b8dabdab0b0848b7c75a` | Deep `FUN_008137a4` | terrain material colour setter uses a **different** colour object (`param_1+0x16c`) and `PTR_DAT_008fce14` |
| `ev_57a5fcbb958e2a31744b8f9934a436bc16c3d7bdc6f94b298e900385bb2d9a2f` | Deep `FUN_004e9a9c` | channel setter `*(float*)(obj+0x18+idx*4)=value` |
| `ev_b11e6a798ab4c1f0cc7ef8248bcd5265d96dcd418c26d74da5dc72c3cb6425e5` | bytes `0x4d0ef0` | two-side flag source byte |

### 2.3 Strange decompiles logged (per charter)

1. `native_function_pseudocode("0x4f99b7")` produced `FUN_004f99b7` with
   *"Instruction at 0x4f99b9 overlaps instruction at 0x4f99b8"* and nonsense
   `func_0xe957e9d7` calls (`ev_9f969e055f7a5d09a843944965cc47dd1e414b20cf91de44d8bb2e9f6191539b`).
   The call target is in fact **`0x4e99cc`** (`ev_aa017001…`; verified as a
   clean `push ebp; mov ebp,esp; push ecx;…` prologue in the raw bytes at
   `0x4e99cc`). The bogus function was **not** used for any conclusion.
2. `sub_559cc4` is only lifter-decodable (3 gotos, 9 inline-asm nodes,
   `deep_engine_unavailable`) (`ev_62ce52045048c5e7a331e338005fc2772396e15a63806386be1dc6f46f6b2066`).
   It is used here only as evidence that *some* GUI path calls colour setters,
   never to assign a numeric sceneColor.
3. `native_bytes_show("0x4d0de0")` returned a hex string whose byte→address
   alignment is inconsistent with the containing function's disassembler
   listing. That particular record (`ev_04b11b66…`) is **excluded** from all
   conclusions; addresses in this report come from `native_instruction_show`
   and from function disassembly instead.

---

## 3. U-1 CLOSED — exact source and value of `gl_FrontLightModelProduct.sceneColor`

### 3.1 The call site (raw, [O])

`sub_4d13d4` (`ev_39378c31…`):

```text
0x4d13dd  mov eax, [ebp-4]                ; renderer
0x4d13e0  mov eax, [eax+0x11c]            ; pointer to colour object
0x4d13e6  call 0x4e9bec                   ; eax = pointer + 0x18
0x4d13eb  push eax                        ; arg2 = float4 pointer
0x4d13ec  push 0xb53                      ; arg1 = GL_LIGHT_MODEL_AMBIENT
0x4d13f1  call 0x4afd24                   ; glLightModelfv@thunk
```

`sub_4e9bec` is exactly `add eax,0x18; ret`
(`ev_e09c618e…`, Deep `ev_00755952…`), and the same
`sub_4e9bec(colour_object) → gl*fv` idiom is used 22 other times for fog colour
and the three per-light colours (`ev_04b2a4bf…`). Therefore `+0x18` is the
colour object's four-float RGBA vector, and it is passed by pointer to
`glLightModelfv`.

### 3.2 Where that colour object comes from ([D] chain, every link byte-proven)

| Step | Evidence | Fact |
|---|---|---|
| 1 | `ev_78af8a18…` (Deep `FUN_004d0de8`, the renderer constructor) | `*(renderer+0x11c) = FUN_004e99cc(PTR_PTR_004e6ca4, 1, renderer, 0, 0, PTR_DAT_008fcac0)` |
| 2 | `ev_b80b201e…`, `ev_2983dc9a…` | `PTR_DAT_008fcac0 = [0x8fcac0] = 0x8f58dc` (entry 0 of a 217-pointer table) |
| 3 | `ev_aa017001…` (Deep `FUN_004e99cc`) | factory → `FUN_004e9a58(obj, param_6)` |
| 4 | `ev_23cedeec…`, `ev_2c6ec63e…` | `FUN_004e9a58(obj, src)` → `FUN_004a229c(obj+0x18, src)` |
| 5 | `ev_f98c3f3f…`, `ev_a59ca01b…` | `FUN_004a229c` copies exactly four dwords from `src` to `dst` |
| 6 | `ev_0cb2b604…`, `ev_563a73fb…`, `ev_f5ca03dd…` | `src = 0x8f58dc`; bytes `cdcc4c3e cdcc4c3e cdcc4c3e 0000803f` |

The identical construction is seen independently in the colour-scheme
constructor `FUN_004e9ca4`: `push 0x8f58dc; … call 0x4e99cc`
(`ev_291101a…`, Deep `ev_6bf8caab…`), i.e. the same static colour is the
canonical first colour slot of this object family.

### 3.3 The value ([O])

| Channel | Hex (LE f32) | Decimal f32 | Byte source |
|---:|---|---:|---|
| R | `cd cc 4c 3e` | `0.200000002980232` | `0x8f58dc` |
| G | `cd cc 4c 3e` | `0.200000002980232` | `0x8f58e0` |
| B | `cd cc 4c 3e` | `0.200000002980232` | `0x8f58e4` |
| A | `00 00 80 3f` | `1.0` | `0x8f58e8` |

The four floats are copied into the colour object at `object+0x18..+0x27`;
`glLightModelfv(GL_LIGHT_MODEL_AMBIENT, object+0x18)` therefore submits
**`(0.2, 0.2, 0.2, 1.0)`**. Since `hf.pvl.sm.vert:18` adds
`gl_FrontLightModelProduct.sceneColor` to `gl_FrontLightProduct[0].ambient`
(`ev_83d90ad0…` from the parent report), the GLSL `sceneColor.rgb` is `(0.2)³`.

**What it is *not*** ([D], each excluded by a proven chain):

* not `0` — the term exists and has a non-zero static source;
* not `light.cfg` ambient `(0.196078,0.184314,0.129412)` — that value reaches
  `glLightfv(GL_AMBIENT)` through the light object, a different colour object
  (`sub_4d08bc`, §6);
* not `colors.lib` `Ambient = 255,255,255,255` (`ev_314245fe…`) — the
  `colors.lib` registry at `0x585704` (`ev_0778a4ac…`) proves that field exists,
  but no static path connects that statictable field to `renderer+0x11c`;
  `sub_8137a4` (`ev_84ac2998…`) applies `PTR_DAT_008fce14` to a colour object
  under a *different* owner (`param_1+0x16c`), not to `renderer+0x11c`.

### 3.4 Negative checks supporting the static value

* `native_xrefs_list 0x8f58dc`: exactly **one** static reference, a `push` at
  `0x4e9cbf` (`ev_dd0b16e0…`).
* `native_xrefs_list 0x8fcac0`: exactly three static references, all reads
  (`ev_31f9ae3d…`); no code writes the pointer slot.
* `native_bytes_find` for `a3 dc 58 8f 00` and `c7 05 dc 58 8f 00`: **0**
  matches each (`ev_95d90f15…`, `ev_84052a13…`) — no immediate store into the
  four floats.
* Wildcard scan for writes to renderer field `+0x11c`
  (`89 ?? 1c 01 00 00`, `c7 ?? 1c 01 00 00`): the only site in the
  `0x4d00xx` renderer module is `mov [esi+0x11c],eax` at `0x4d0e43`
  (`ev_800db002…` / `ev_cbc9424c…` / `ev_5179161f…`), inside the constructor.
  The other 60+ matches belong to unrelated classes at other VAs.

---

## 4. U-2 CLOSED — the `glLightModeli` pname immediates

Raw `sub_4d13d4` (`ev_39378c31…`):

```text
0x4d13f6  mov eax, [ebp-4]
0x4d13f9  test byte ptr [eax+0x123], 8
0x4d1400  je 0x4d1410
0x4d1402  push 1                 ; GL_TRUE
0x4d1404  push 0xb52             ; GL_LIGHT_MODEL_TWO_SIDE
0x4d1409  call 0x4afd2c          ; glLightModeli@thunk
0x4d140e  jmp 0x4d141c
0x4d1410  push 0                 ; GL_FALSE
0x4d1412  push 0xb52             ; GL_LIGHT_MODEL_TWO_SIDE
0x4d1417  call 0x4afd2c          ; glLightModeli@thunk
```

* **[O]** Both pname immediates (`0x4d1404`, `0x4d1412`) are `0x0B52`, the
  standard GL 1.1 constant **`GL_LIGHT_MODEL_TWO_SIDE`**. `0x0B51`
  (`GL_LIGHT_MODEL_LOCAL_VIEWER`) is **not** pushed at either site. The prior
  "[U] two-sided vs local-viewer" question (`DEC_SMALL` U-LP-2) is resolved.
* **[O]** The boolean is `byte[renderer+0x123] & 8`. The constructor writes
  `DAT_004d0ef0` into `+0x123` (`ev_78af8a18…`); those bytes are
  `05 00 00 00` (`ev_b11e6a79…`, typed `u32=5` in `ev_a410409e…`). `5 & 8 == 0`,
  so at startup the donor executes the `0x4d1410` branch:
  **`glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, GL_FALSE)`**.
* **[O]** No static `mov byte [reg+0x123],imm` exists in the file
  (`ev_e951b5d0…`: 0 matches for `c6 80 23 01 00 00`), so no compile-time
  second value is visible. A runtime toggle through a computed base register
  cannot be excluded under donor-read-only; see **[U-R2]** in §7.

---

## 5. Complete state prologue `sub_4d13d4` (everything typed)

All GL enum names are the standard GL 1.1 numeric mappings; the immediates
themselves are **[O]** from `ev_39378c31…`. `FUN_004d139c(enable, slot, enum,
vp)` calls `glEnable(enum)` when `enable!=0` else `glDisable(enum)`
(`ev_f7f36c59…`, `ev_c28fddfe…`).

| Site | Call | pname / value | GL name | Source of boolean (constructor default) |
|---|---|---|---|---|
| `0x4d13f1` | `glLightModelfv` | `0x0B53`, ptr `*(r+0x11c)+0x18` | `GL_LIGHT_MODEL_AMBIENT` | value §3.3 = `(0.2,0.2,0.2,1)` |
| `0x4d1409` / `0x4d1417` | `glLightModeli` | `0x0B52`, `1` or `0` | `GL_LIGHT_MODEL_TWO_SIDE` | `byte[r+0x123]&8`; init 5 → false (§4) |
| `0x4d1426` | `sub_4d139c(1, 0xd, 0x0BA1)` | `0x0BA1`, always ON | `GL_NORMALIZE` | literal `al=1` |
| `0x4d143d` | `sub_4d139c(byte[r+0x113], 5, 0x0B71)` | `0x0B71` | `GL_DEPTH_TEST` | `+0x113 = 1` in constructor |
| `0x4d1454` | `sub_4d139c(byte[r+0x110], 4, 0x0B44)` | `0x0B44` | `GL_CULL_FACE` | `+0x110 = 1` |
| `0x4d146b` | `sub_4d139c(byte[r+0x112], 8, 0x0B50)` | `0x0B50` | `GL_LIGHTING` | `+0x112 = 1` |
| `0x4d1482` | `sub_4d139c(byte[r+0x111], 7, 0x0B60)` | `0x0B60` | `GL_FOG` | `+0x111 = 0` (fog off at startup) |
| `0x4d1491` | `glGetIntegerv(0x0D54, &local_c)` | `0x0D54` | `GL_MAX_LIGHTS` | — |
| `0x4d14a5` | `sub_4d139c(local_c<8, 6, 0x0BD0)` | `0x0BD0` | `GL_DITHER` | enable iff `GL_MAX_LIGHTS < 8` |
| `0x4d14b3` | `sub_88fb14(r, 2)` → `glDepthFunc(table[2])` | table `0x8fb18c[2] = 0x0201` | `GL_LESS` | `ev_818e7fc…`, `ev_aa4c06ed…`, `ev_778088da…` |
| `0x4d14c2` | `glHint(0x0C50, 0x1102)` | `GL_PERSPECTIVE_CORRECTION_HINT`, `GL_NICEST` | — | literal |
| `0x4d14dd` / `0x4d14e9` | `glShadeModel(0x1D01)` / `(0x1D00)` | `GL_SMOOTH` if `byte[r+0x125]<2`; `GL_FLAT` if `==2` | — | `+0x125 = 0` → smooth |

Notably **`glColorMaterial` is not called here** (its import exists elsewhere,
`DEC_SMALL` §3.1, but no site in this prologue). `glLightModelfv` is the only
light-model vector submission in the binary (`DEC_SMALL` `ev_15298ba6…`),
so the table above is the complete light-model state visible to
`hf.pvl.sm.vert`.

---

## 6. The remaining fixed-function products consumed by `hf.pvl.sm.vert`

### 6.1 Per-light state — `sub_4d08bc` ([O], `ev_b44f26b3…`)

For each light index `i` fetched from the renderer's light table
(`FUN_0089df30`), the donor issues `glEnable(GL_LIGHT0+i)` (pushed
`[light+0xa0]`, `0x4000+i`) when the light's `byte[+0xbc]` is set, else
`glDisable(GL_LIGHT0+i)`; unused slots ≥ count are explicitly disabled.
Enabled lights get (cdecl push order shown as `pname`):

| Site | pname | GL name | Value source |
|---|---|---|---|
| `0x4d0963` | `0x1203` | `GL_POSITION` | `FUN_00890ccc(light+0xa4 or +0x44)` after `sub_4ca154`/`glMultMatrixf` |
| `0x4d09aa` | `0x1200` | `GL_AMBIENT` | `sub_4e9bec(light+0xc0)` → colour object RGBA |
| `0x4d09c7` | `0x1201` | `GL_DIFFUSE` | `sub_4e9bec(light+0xc4)` |
| `0x4d09e4` | `0x1202` | `GL_SPECULAR` | `sub_4e9bec(light+0xc8)` |
| `0x4d0a1b` | `0x1204` | `GL_SPOT_DIRECTION` | `FUN_00890ccc(light+0xa4)` |
| `0x4d0a33` | `0x1205` | `GL_SPOT_EXPONENT` | `&light[+0xa8]` |
| `0x4d0a4b` / `0x4d0a63` | `0x1206` | `GL_SPOT_CUTOFF` | `&light[+0xac]`, or literal `0x43340000 = 180.0f` when non-positional |
| `0x4d0a7b` | `0x1207` | `GL_CONSTANT_ATTENUATION` | `&light[+0xb0]` |
| `0x4d0a93` | `0x1208` | `GL_LINEAR_ATTENUATION` | `&light[+0xb4]` |
| `0x4d0aab` | `0x1209` | `GL_QUADRATIC_ATTENUATION` | `&light[+0xb8]` |

This resolves `DEC_SMALL` U-LP-4's *submission path* (there are 4 static
`glLightfv` call sites, not 0 as the name-xref sweep suggested — they resolve
through the thunk at `0x4afd3c`). The exact `w` and modelview matrix applied to
the `light.cfg` position remain **[U-LP-4]** (§7).

### 6.2 Material state — `sub_88f3e8` ([O], `ev_45d056ba…`)

This is the cached uploader; the face argument (ecx, e.g. `0x0404 =
GL_FRONT`) is passed as arg1 to each GL call:

| Site | Call | pname | GL name |
|---|---|---|---|
| `0x88f418` | `glMateriali` | `0x1601` | `GL_SHININESS` |
| `0x88f446` | `glMaterialfv` | `0x1600` | `GL_EMISSION` |
| `0x88f474` | `glMaterialfv` | `0x1200` | `GL_AMBIENT` |
| `0x88f4a2` | `glMaterialfv` | `0x1201` | `GL_DIFFUSE` |
| `0x88f4d0` | `glMaterialfv` | `0x1202` | `GL_SPECULAR` |

**This closes `DEC_SMALL` U-LP-3's slot→enum half.** One concrete caller,
`FUN_005422c0` (`ev_b520ab84…`), passes `PTR_DAT_008fcac0` = `0x8f58dc`
(`ev_bb32eff1…` shows the sibling pointers) as the `GL_AMBIENT` source for *a*
material — evidence that the `0.2` grey vector is reused both as light-model
ambient and as at least one material ambient. The exact binding of the
`reftile.mat` literals (`ambient 0.15686`, `diffuse 0.78125`, `emission 0`,
`specular 0`, `shininess 16`, both faces — `ev_fadb2880…` from the parent
report) into the terrain draw's `glMaterialfv` slots is still **[U-LP-3b]**;
no static trace was run in this pass and none is asserted here.

### 6.3 Mapping to the shader text

| GLSL built-in in `hf.pvl.sm.vert` | Donor producer | Status |
|---|---|---|
| `gl_FrontLightModelProduct.sceneColor` | `glLightModelfv(0x0B53, *(r+0x11c)+0x18)` | **[O]/[D]** `(0.2,0.2,0.2,1)` §3 |
| `gl_FrontLightProduct[0].ambient` | driver product of `glMaterialfv(GL_AMBIENT)` × `glLightfv(GL_AMBIENT)` | enum path **[O]**; exact terrain floats **[U-LP-3b]** |
| `gl_FrontLightProduct[0].diffuse` | `glMaterialfv(GL_DIFFUSE)` × `glLightfv(GL_DIFFUSE)` | same |
| `gl_FrontLightProduct[0].specular` | `glMaterialfv(GL_SPECULAR)` × `glLightfv(GL_SPECULAR)`; `reftile.mat` specular=0 → **effective `vec3(0)`** | material enum **[O]**, text **[O]** |
| `gl_FrontMaterial.shininess` | `glMateriali(GL_SHININESS)`; `reftile.mat` = 16 | enum **[O]**, text **[O]** |
| `gl_LightSource[0].position` | `glLightfv(GL_POSITION)` after `glMultMatrixf` | pname **[O]**, w/modelview **[U-LP-4]** |
| `gl_NormalMatrix`, `gl_ModelViewMatrix` | built-ins; `GL_NORMALIZE` enabled by `0x4d1426` | **[O]** |
| `gl_Color` | `glColor4fv` in `sub_818428` only when `byte[renderer+0x150]!=0`; `vertexColor` shader uniform gates the multiply | gate runtime **[U]**; shader text **[O]** |

---

## 7. Residual unknowns — and the exact experiments that would close them

No residual is silently approximated.

| ID | Unknown | Exact experiment / termination condition |
|---|---|---|
| **U-R1** | Whether any *runtime/computed-pointer* write mutates the four floats at `0x8f58dc` (or the copied vector in the renderer's colour object) between renderer construction and the first terrain draw. Static evidence (§3.4) shows no such write. | Under the read-only charter this cannot be closed statically: `native_xrefs_list` and `native_bytes_find` only see literal addressing. Experiment: launch the donor **with explicit authorisation** under a debugger/GL tracer; set a hardware write breakpoint on the 16 bytes at `0x8f58dc` and on `*(renderer+0x11c)+0x18` after `sub_4d0de8`, run one skirmish frame, and read `glLightModelfv` arg2 at `0x4d13f1`. Termination: either the 16 bytes are unchanged (static value confirmed) or a writer/value is captured and this report's §3.3 is amended. Until then the static value is used **as recovered**, not as a guess. |
| **U-R2** | Whether `byte[renderer+0x123]` bit 3 is ever set at runtime (turning two-sided lighting on). Constructor value is 5 (`5&8=0`); no literal `mov byte [reg+0x123],imm` exists. | Hardware watch on `renderer+0x123` across a skirmish frame; capture any `or`/`mov` that sets bit 3, and observe the branch taken at `0x4d1400`. Currently use `GL_FALSE` (startup state). |
| **U-LP-3b** | Exact `reftile.mat` ambient/diffuse/emission/specular/shininess floats reaching `glMaterialfv` for the terrain HeightField draw. | Enumerated slots are known (§6.2). Follow callers of `sub_88f3e8` that pass a terrain material refkey and byte-read the four source vectors, or GL-trace `glMaterialfv` for a terrain draw. Not done here; no value is invented. |
| **U-LP-4** | `w` and modelview matrix used when `light.cfg` position `(-0.344731,0.938701,0,1)` is submitted. | GL-trace `glLightfv(GL_POSITION)` at `0x4d0963` and read `sub_4ca154`/`FUN_00890ccc` outputs. No brightness correction follows from this. |
| **U-VTX** | `vertexColor` uniform value at terrain draw / `byte[renderer+0x150]` gate. | GL-trace `glColor4fv` at `0x81847f` and read the uniform at shader `:20`. Do not assume the multiply is active. |

All parent-report unknowns not named here (`U-3..U-13` of
`PORT1TO1_terrain_renderer.md`) are untouched by this worker.

---

## 8. Exact Godot uniform binding recommendation (spec only — no file edited)

Godot has no fixed-function light-model product formation, so the donor's
`sceneColor + material×light` shape must be reproduced explicitly. Bind:

```gdscript
# SPEC ONLY — not written to any repo file by this worker.
# Value: 0x8f58dc (16 B), copied into renderer colour object +0x18, submitted
#        by glLightModelfv(GL_LIGHT_MODEL_AMBIENT) at 0x4d13f1.
uniform vec4 scene_color : source_color = vec4(0.2, 0.2, 0.2, 1.0);  # .rgb used

# light.cfg (text [O], not from CODE)
uniform vec3 light_ambient_rgb : source_color = vec3(0.19607843, 0.18431373, 0.12941177);
uniform vec3 light_diffuse_rgb : source_color = vec3(0.81176472, 0.78039217, 0.69411767);

# reftile.mat, normal refkey, both faces (text [O])
uniform float material_ambient = 0.15686;
uniform float material_diffuse = 0.78125;
```

and compute, in the vertex stage (mirroring `hf.pvl.sm.vert:18-23,41-42`):

```glsl
vec3 packed = scene_color.rgb
            + material_ambient * light_ambient_rgb
            + max(dot(l, n), 0.0) * material_diffuse * light_diffuse_rgb;   // (× gl_Color only if vertexColor==1 — U-VTX)
vec3 specular = vec3(0.0);   // effective product: material specular 0 × light specular
```

Binding rules, all mandatory for a donor-faithful port:

1. **Default `scene_color.rgb = (0.2,0.2,0.2)` exactly** (float32 `0x3E4CCCCD`).
   Do **not** use `vec3(0)`, do **not** fold it into the ambient term, do
   **not** use `light.cfg` ambient, and do **not** use `colors.lib`
   `Ambient=255,255,255` (=1.0) — no static path connects that statictable
   field to this uniform (§3.3). Keep it as its own uniform so a captured
   U-R1 value can replace it without touching the equation.
2. Keep the ambient as a **two-term sum** (`sceneColor + material×light`);
   collapsing to one constant is an explicitly labelled PORT APPROXIMATION.
3. Specular must be the **effective product `vec3(0)`**, not the nonzero
   `light.cfg` specular `(0.278431,0.266667,0.211765)`. If the mesh still binds
   the light colour, preserve the `material_specular_rgb=0` multiply that
   cancels it.
4. `normalize(gl_NormalMatrix*gl_Normal)` must remain (donor `GL_NORMALIZE`
   enabled at `0x4d1426`); `shade model = smooth` (donor `+0x125=0` →
   `GL_SMOOTH`). Perspective correction is Godot's default; the donor's
   `glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)` has no binding.
5. Two-sided lighting is **false** at startup; no Godot uniform is required.
   If a `cull_disabled` guard is kept for `fcCull`, it stays labelled as a
   port guard, not claimed as a recovered donor option (and U-R2 stays open).
6. Alpha of `scene_color` is `1.0` but unused by the fragment (only
   `gl_TexCoord[4].xyz` is consumed); binding `vec4` is for fidelity only.

---

## 9. Delta versus the starting reports / bottom line

| Prior claim | This pass | Status |
|---|---|---|
| `PORT1TO1-RENDER` U-1: `sceneColor` "not statically recoverable" | recovered as a 16-B static copy from `0x8f58dc` = `(0.2,0.2,0.2,1)` | **Closed [O]/[D]**; residual U-R1 stated with experiment |
| `PORT1TO1-RENDER` U-2: pname immediates at `0x4d1409/0x4d1417` unknown | both are `0x0B52 = GL_LIGHT_MODEL_TWO_SIDE`; boolean from `byte[+0x123]&8`, init false | **Closed [O]** |
| `DEC_SMALL` U-LP-2: two-sided vs local-viewer | `0x0B52`, not `0x0B51` | **Closed [O]** |
| `DEC_SMALL` U-LP-3: material slot→enum map | `glMateriali` uses `0x1601=GL_SHININESS`; `glMaterialfv` uses `0x1600=GL_EMISSION`, `0x1200=GL_AMBIENT`, `0x1201=GL_DIFFUSE`, `0x1202=GL_SPECULAR` | **Half closed [O]**; exact terrain floats remain U-LP-3b |
| `DEC_SMALL` U-LP-4: `glLightfv` "0 static references" | four `glLightfv` sites resolved through thunk `0x4afd3c` in `sub_4d08bc`; pnames enumerated | **Path closed [O]**, w/modelview still [U] |
| `DEC_SMALL` §4(1): value "zero / palette ambient / colors.lib statictable cannot be proven" | zero and colors.lib `Ambient` excluded by chain; palette static `0.2` grey proven | **Refined, no approximation** |

**Bottom line.** `sceneColor` is `(0.2,0.2,0.2,1.0)` from `0x8f58dc`; the
`glLightModeli` pname is `GL_LIGHT_MODEL_TWO_SIDE` at both sites with a
startup-boolean of `GL_FALSE`; and the complete light-model/material state
visible to `hf.pvl.sm.vert` is now enumerated with addresses. The port must
expose `scene_color = vec4(0.2,0.2,0.2,1.0)` as a dedicated uniform and keep
the two-term ambient plus zero effective specular. Remaining items are
runtime-binding experiments, not permissions to approximate. **No donor
visual parity is claimed; no donor GPU A/B frame was produced.**

*End of DEC-U-SCENECOLOR-GLSTATE. READ-ONLY: one repo file written (this report);
no binary executed/copied; no code, shader, config, asset, test, git or Godot
state changed. Active target unchanged: `t_87f0f3c130b0`.*
