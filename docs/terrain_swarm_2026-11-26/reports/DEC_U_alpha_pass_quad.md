---
id: DEC-U-ALPHA-PASS-QUAD
ticket: "TERRAIN-SWARM-2026-11-26 / DEC-U-ALPHA-PASS — close PORT1TO1-RENDER U4/U6/U9/U10 from native code and donor material text"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_PARITY_CLAIM
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_alpha_pass_quad.md
target: "C:\\Games\\Cossacks 3\\cossacks.exe — t_87f0f3c130b0 (sha256 87f0f3c130b027e7…), explicit document: pin on EVERY native call"
secondary: "C:\\Games\\Cossacks 3\\editor.exe — t_68474ddde43f (present in session, NOT opened or used by this worker)"
labels: [O, D, I, U, "RUNTIME PROBE", "PORT INSTRUCTION"]
parity_claim: false
scope_guard: "Donor READ ONLY. No donor binary executed, copied, committed, modified or debugged. No repo code/shader/config/asset/test/Godot/git edit. No Craft Anything brief/hypothesis/finding/unknown mutation. Exactly one repo file written: this report. Evidence ids below are the tool-returned ids of this pass; addresses are pinned-VA."
---

# DEC-U-ALPHA-PASS — U4 / U6 / U9 / U10 recovered from `t_87f0f3c130b0`

## 0. Executive summary — verdict per item

| Item | Prior status | This pass | Result |
|---|---|---|---|
| **U4** `tiaAlphaFromIntensity` | [U] formula unknown | **PARTIAL [O] + probe** | Enum `TOSWTextureImageAlpha` fully recovered from CODE RTTI: 9 named values, `tiaAlphaFromIntensity = 1`. The conversion routine was **not** statically isolated (string has 0 static xrefs; only RTTI name tables). Exact GL-upload probe specified in §3.3 — terminate by dumping the uploaded texture bytes. Identity mapping is an **[I] inference only**, not a donor claim. |
| **U6** `GL_ALPHA_TEST` at `0x4ef97d/0x4ef987` | [U] "whether disabled" | **RESOLVED [O]/[D]** | Both sites call `sub_88f0f0` = **cached `glEnable`**. `GL_ALPHA_TEST` is **ENABLED**, not disabled. Capability table `0x8fb0dc`: `[0]=3008=0x0BC0=GL_ALPHA_TEST`, `[2]=3042=0x0BE2=GL_BLEND`. Full enable/disable order for all six `BlendingMode` cases in §4. No `glAlphaFunc` reset in case 1. |
| **U9** pass count / base-overlay order | [U] CONFIRMED_UNVERIFIED | **RESOLVED STRUCTURALLY [O]/[D]** | `FUN_00818920` builds **exactly one `glNewList` display list per cell call** and **returns** after the first qualifying layer descriptor (`glEndList; ret` at `0x819b65/0x819b6a`). All layer quads are emitted **inside that one list**, in quad-array index order (base first, overlays after). No base/overlay multi-draw loop exists in the heightfield mesh builder. Residual [U] tail: the generic `glCallList` dispatcher is not proven to issue exactly one call per cell (§5.4). |
| **U10** `0x48 → 0x50` quad expansion | [U] stride not re-verified | **RESOLVED [O]** | Full `sub_818920` read (1650 insns + 902-line Deep pseudo-C). Exact **0x50-byte quad record** field map from raw pushes at `0x819774–0x819b52`; exact **0x48-byte producer record** map from `FUN_00812b4c`/`FUN_00812ccc`. Relation: 16-byte index header prepended + UV block shifted by **+0x0b**, stride `0x48 → 0x50`. §6 gives the field-by-field map. |

**No donor parity claim is made.** No donor GPU frame exists; no donor binary was run.

---

## 1. Target discipline and multi-pass ledger

### 1.1 Discipline

- `core_session_show` at start: `active_target = t_87f0f3c130b0`, `analysis_mode = deep`, `clean_room = false`, 2 open targets (`cossacks.exe` `t_87f0f3c130b0`, `editor.exe` `t_68474ddde43f`). `native_open_documents_list` confirmed the pin; `native_document_show` returned `{document:"t_87f0f3c130b0", name:"cossacks.exe", sha256:"87f0f3c130b0…"}`.
- **Every** `native_*` call in this pass passed `document:"t_87f0f3c130b0"` explicitly. No `core_target_open`/`core_target_select` was issued. `editor.exe` was never read. `core_feature_find` was used read-only (it returned no match).
- Donor text was not re-read by absolute path in this pass; the existing material evidence (`reftilealpha.mat`, `reftile.lib`, `hf.pvl.sm.vert`, `hf.pvl.smx3.frag`) is cited from PORT1TO1-RENDER §2.1 and F06-E3/E8, not re-derived here.
- Two engine instruments were unavailable and were **not** substituted with guesses: `native_rizin_command_run` → `engine_missing` (Rizin not installed); `native_objdump_run` → `engine_missing` (objdump not installed). The full `sub_818920`/`sub_7829a4` assembly was recovered instead from the saved `native_function_disassemble` output (1650 and 6224 instructions, complete coverage), and is cited by evidence id.

### 1.2 Multi-pass ledger

| Lead | Pass 1 | Pass 2 | Pass 3 | Pass 4 | Accepted |
|---|---|---|---|---|---|
| U4 enum | `native_bytes_find` text → 2 CODE hits `0x4e6e58`, `0x4e9344` (`ev_7c570514…`) | `native_bytes_show 0x4e6d80` → 9 `tia*` names (`ev_5b7d6d88…`) | `native_bytes_show 0x4e9280` → `ffffffff`-separated value table (`ev_c8049f68…`) | xrefs=0; `core_feature_find`=0; RTTI property probes `0x4ec07c/0x4ec0a0` **refuted** as ImageBrightness | Enum + value **1** [O]; arithmetic **[U] + probe** |
| U6 helpers | `native_function_disassemble 0x88f0f0` → cached enable (`ev_96785ecc…`) | `0x88f148` → cached disable (`ev_1c986c73…`) | `native_bytes_show 0x8fb0dc` + typed u32 → 3008/3042 (`ev_27eae377…`, `ev_ca465020…`, `ev_01b5af23…`) | full `sub_4ef810` 224 insns → six case blocks (`ev_c6b5ab46…`) | **ENABLE** [O]/[D] |
| U9 draws | `FUN_00818920` Deep pseudo-C (`ev_ec93f0af…`) | `native_function_callers_list` → 1 caller (`ev_66723f09…`) | `FUN_008177f0` pseudo-C (`ev_6e12d1fa…`) | raw `glEndList; ret` `0x819b65/0x819b6a` + `glCallList` xrefs (`ev_56c5a3d7…`) | **1 display list/cell** [O]/[D] |
| U10 records | `FUN_00812b4c` pseudo-C → `0x48`, `+5` (`ev_6f767eed…`) | raw `0x819774–0x819b52` → 4 emitters, 12 field offsets (`ev_8abea401…`) | `FUN_0081831c`/`FUN_00818428` pseudo-C (`ev_8ed2a809…`, `ev_696bc518…`) | `FUN_0081aeac` descriptor init (`ev_3f47f810…`) | Full field map [O] |

---

## 2. Evidence register (new in this pass, all pinned `t_87f0f3c130b0`)

| Evidence id | Operation | Establishes |
|---|---|---|
| `ev_7c5705141f44eeaa7e627bcdbb50a4e1a882c667e22b5da94b18eb6f0b7d9961` | `native_bytes_find` text `tiaAlphaFromIntensity` | 2 CODE matches: VA `0x4e6e58` (FO `0xe6258`), VA `0x4e9344` (FO `0xe8744`); completion status complete |
| `ev_5b7d6d88066e28d4eba9215c91fafba3fdf8e939e72715a6a2d8feab86c2019a` | `native_bytes_show 0x4e6d80`, 384 B | RTTI `TOSWTextureImageAlpha`: `tiaDefault`, `tiaAlphaFromIntensity`, `tiaSuperBlackTransparent`, `tiaLuminance`, `tiaLuminanceSqrt`, `tiaOpaque`, `tiaTopLeftPointColorTransparent`, `tiaInverseLuminance`, `tiaInverseLuminanceSqrt` |
| `ev_c8049f689a2ff7b7f459504f1d4eae2f5684736dcf7363966b2d8f1bbfdc9585` | `native_bytes_show 0x4e9280`, 384 B | second table: `ffffffff` + length-prefixed name per value; same order → index mapping |
| `ev_f438caefcb392064ee6c17e780ea77f99a580a38962604235c54a9cac843d0ce` | `native_bytes_show 0x4e6e20`, 96 B | type data: `03 15 "TOSWTextureImageAlpha"`, ordinal flag `0x80000000`, max value `8`, pointer `0x4e6e24` |
| `ev_3c3c92b18c10c8fb880ec99b616cbc7f1392aa3661a07e9ec72c24c7bbc94ee1`, `ev_3909e3be9bdff29e882bdf2275cc455f06ebd56444028df7d77bfb6adace77d7` | `native_xrefs_list 0x4e6e58` / `0x4e9344` | 0 static xrefs each — RTTI-name-only strings |
| `ev_49f722268cde5cb3c44affdf62460db1204af99e02d1cc5f4f031c0a7d614ea7` | `native_xrefs_list 0x4e6e24` | 0 static xrefs — type pointer reached via RTTI at runtime |
| `ev_c629017b8afe2aeb5b151c7d62d656b693769b09263eea9a6adce8a403f372f3`, `ev_623dfaec1044c83ae5923733c294f244820910a4825000226eb30955727155b2` | `native_bytes_find` `24 6e 4e 00` / `28 6e 4e 00` | 2 / 1 CODE occurrences of the enum type pointers; both in RTTI pages |
| `ev_4e8153ab992023f09249c1f52d957d869efd145499b4c8a30450bf9315b0d87b` | `native_bytes_find` `ImageAlpha` | 3 CODE matches `0x4e6e35` (inside *TOSWTextureImageAlpha*), `0x4e7f60`, `0x4ee21c` |
| `ev_95376b4f6553ebb950190f8d105c8b078b43726edf96e26f163333a4205c2bde`, `ev_6658b79c1a07b8ec124607fd29c6e549e6ea86936fa8723f748aaa3708086aee` | `native_bytes_show 0x4ee1f0` / `0x4e7f40` | property-name list contains `ImageAlpha`; property entry with type/accessor pointers |
| `ev_949c116d96a0b58fa173f33ecf43ba8b0043a47b9dbacf326a01dc29b9ce2def`, `ev_c0c4920c160bc486fa4682d49653f4038f91d6d3d02eccabe0b936edb3fa4d38` | Deep `FUN_004ec07c` / `FUN_004ec0a0` | **Refutation**: these two accessor candidates write/read a float at `+0x2c` = `ImageBrightness`, not ImageAlpha |
| `ev_2248540f162ee89a38721aadcb332de50cee6b19850292b585079f9efa21b91a`, `ev_c85286a54b423dd8f5bf23a1f0d5214f472d3429695179411b15e353fc75f7bb` | `native_strings_find tiaLuminance` / `core_feature_find tiaAlphaFromIntensity` | 0 hits — data-section string indexer cannot see CODE Pascal shortstrings; absence is tool coverage, not donor absence |
| `ev_331c42bb359f5197d0ad53c7f95827c8cdd19f0a63cc012f69438c0b0a347960`, `ev_2079bc8958a1ff8a6bc78ff1015db3018bb24fd83793ebb9ae7241c9741c348b` | `native_functions_search` `Alpha` / `Texture` | only GL imports/thunks; no named engine conversion routine in the analysed function set (discovery hit its 6M-instruction cap) |
| `ev_96785ecceb0797c5196491b357e80c55a6fbad2ac5d178f16599fc03fbf48739` | `native_function_disassemble 0x88f0f0`, 33 insns | cached **enable**: `bt [esi+0x8c]`, `bts`, propagate vtable `+0x54`, else `push table[cap]; call 0x4afb8c (glEnable@thunk)` |
| `ev_1c986c730cb2e3ce56a253994ccfb4de1f06da04bf91c874ce8b3b4689824815` | `native_function_disassemble 0x88f148`, 33 insns | cached **disable**: `bt [esi+0x8c]`, `btr`, propagate vtable `+0x58`, else `push table[cap]; call 0x4afb6c (glDisable@thunk)` |
| `ev_27eae37720f7f09c0bd487732270af4754c33d68bdefe8959df834eaae05617c` | `native_bytes_show 0x8fb0dc`, 256 B | GL capability enum table: `[0]=0x0bc0`, `[1]=0x0d80`, `[2]=0x0be2`, `[3]=0x0b57`, `[4]=0x0b44`, `[5]=0x0b71`, `[6]=0x0bd0`, `[7]=0x0b60`, `[8]=0x0b50`, `[18]=0x0b90`, `[20]=0x0de0`, `[21]=0x0de1` |
| `ev_ca4650205cdfd4ac3ef8760cba326f7b9e1fe29f6f236742fb16a28b5e06bcef`, `ev_01b5af2301a40f94f3ec09762c2362303e668c88288a8cd729d91ecd5696a530` | `native_data_show 0x8fb0dc` / `0x8fb0e4` as u32 | `[0] = 3008 = 0x0BC0 = GL_ALPHA_TEST`; `[2] = 3042 = 0x0BE2 = GL_BLEND` |
| `ev_c6b5ab46f70762cbf2274a9f42811ce6c00629dfe47c3d2b34c78e5eda98cf16` | `native_function_disassemble 0x4ef810`, 224 insns (re-derived) | six `BlendingMode` case blocks; case 1 at `0x4ef97a–0x4ef99a` |
| `ev_8abea4014b499704b471a31daf78188556d46e543cccd8cdcc551c825922b9ec` | `native_function_disassemble 0x818920`, 1650 insns | full quad/list builder; raw offsets at `0x819774–0x819b52`; `glEndList; ret` |
| `ev_ec93f0af1fb49a1db65615047d264009071a024bf9acd83e8870e7a2b8e11b91` | Deep `FUN_00818920` (902 lines, re-derived) | layer-descriptor loop, quad loop, two emitters, `glNewList(…,0x1300)` |
| `ev_6e12d1fa777c86a5e4940d66ba82e829712f8bc79803101ec254aa4355c4c7b0` | Deep `FUN_008177f0` | producer installed at `renderer+0x40/+0x44`; one `FUN_00818920` call per cell after `FUN_0081ac98` |
| `ev_66723f092a1b3404dabd5d2509b12512cd74615b919368a84820788ed238f14` | `native_function_callers_list 0x818920` | exactly 1 direct caller: `0x8177f0` at `0x8179b6` |
| `ev_d13db20095509b1a04428d526e0fed9878e60fceaa66d219ccabe281038b6ba1`, `ev_131fdf070c99b10b4ff5676a5d378c944b982c98c60e96db6838b206d682c0f9` | Deep `FUN_008187e4` / `FUN_0081a8e4` | display-list record allocated, registered at `renderer+0x1c`; list id at record `+8` |
| `ev_84743d9375f0836f550ec14b5f45c39c3ac2c790ef8f4bb0cd48dace818d3414`, `ev_3f47f810517e7439d16298f263f563c0e49916c11101982483feb524b26621ba` | Deep `FUN_0081ae94` / `FUN_0081aeac` | layer-descriptor array at `renderer+0x1c0`, stride `0x10`, count at `renderer+0x1c4`; `+0` init to index, `+0xc` init to 0 |
| `ev_a6650ddc8946f93864007700fafd2f5e07053479c85d6e74f16d373d1caec31e` | Deep `FUN_0081ac70` | selects `FUN_00818428` (two-UV) vs `FUN_0081831c` (single-UV) by material field `+0x68 != 0` |
| `ev_20db8cc58927d7e6c135729b0b4da05189f4d4ed764656e1a8fca5733b31846b` | `native_function_disassemble 0x818824`, 91 insns | per-cell height/normal smoothing using the 0x30-stride scratch rows; **not** the quad expansion |
| `ev_6f767eede169f5e551f3e6d87ba59232f3797a7f9a051eed0af1dbeee1757755` | Deep `FUN_00812b4c` (re-derived) | producer RGB UV writer: `*(param_12-4) + (slot&0xff)*0x48`, UVs at `base+5+corner*8` |
| `ev_8ed2a80907087fdcae0827b6762cf5dab2be63c64e25b5a53335560b9a60c4ff`, `ev_696bc518d0ab6b3b28c3d5997b93c734f980524c68d7230ca5cbd2153cd30417` | Deep `FUN_0081831c` / `FUN_00818428` | single-UV vs two-UV (RGB+alpha) vertex emitters; `glNormal3fv`, `glColor4fv`, `glVertex4f` |
| `ev_ec63be717cc45cb84227aad622fe79b9614245bccaaab5eccfdce5e58c9f7ed8` | Deep `FUN_0081ac98` | per-cell setup before list build; vertex-array resize; no quad expansion |
| `ev_56c5a3d724300e0daafc0ef4f475ed9e70a12fb16a4c0a83da7b57c1b6b84fa9` | `native_name_xrefs_list glCallList` | import `0x907cdc`, thunk `0x4afc7c`, 17 call sites in generic dispatchers (incl. 4 in `sub_7829a4`) |
| `ev_3be2ff1678eef25a007ad3d01251d70abe928d8bcc75fd7aec10d497ae3e2ec1` | `native_function_disassemble 0x7829a4`, 6224 insns | generic multi-material draw: repeated `sub_4ef810` state application for material slots `+0xc8/+0xd0/+0xdc/+0xe4/…`; no heightfield-specific compositing loop |

---

## 3. U4 — `tiaAlphaFromIntensity`

### 3.1 Enum recovered exactly [O]

At `0x4e6e28` (FO `0xe6228`) the CODE RTTI type info for `TOSWTextureImageAlpha` is:
`03` = `tkEnumeration`, `15` = 21-byte name `"TOSWTextureImageAlpha"`, ordinal flag `0x80000000`, **max value `8`**, name-table pointer `0x4e6e24` (`ev_f438caef…`, `ev_c629017b…`).

The two name tables (`ev_5b7d6d88…`, `ev_c8049f68…`) give the **same nine names in the same order**, so the mapping is unambiguous:

| value | name | bytes @ `0x4e6d80` page |
|---:|---|---|
| 0 | `tiaDefault` | `0a 74696144656661756c74` |
| **1** | **`tiaAlphaFromIntensity`** | `15 746961416c70686146726f6d496e74656e73697479` |
| 2 | `tiaSuperBlackTransparent` | `18 …` |
| 3 | `tiaLuminance` | `0c …` |
| 4 | `tiaLuminanceSqrt` | `10 …` |
| 5 | `tiaOpaque` | `09 …` |
| 6 | `tiaTopLeftPointColorTransparent` | `1f …` |
| 7 | `tiaInverseLuminance` | `13 …` |
| 8 | `tiaInverseLuminanceSqrt` | `17 …` |

The second table uses the Delphi enum-name encoding `ff ff ff ff` + `u32 length` + ASCII + NUL padding (`ev_c8049f68…`). `reftilealpha.mat:31,139,248` selects **value 1** for `alpha.bmp`, `alphavert.bmp` and `alphanull.bmp` (F06-E3, PORT1TO1 §7). Values 3/4/7/8 prove the engine *does* implement luminance, sqrt-luminance and their inverses somewhere, but do **not** prove which one value 1 shares code with.

### 3.2 Why the converter was not recovered statically — negative results, not assumptions

- Both string copies have **0 static xrefs** (`ev_3c3c92b1…`, `ev_3909e3be…`); the enum is reached via RTTI/property lookup at runtime.
- `ImageAlpha` occurs 3× in CODE (`ev_4e8153ab…`): one is the substring inside `TOSWTextureImageAlpha`; the other two are RTTI property-name entries (`ev_95376b4f…`, `ev_6658b79c…`).
- Candidates parsed out of the property RTTI (`0x4ec07c`, `0x4ec0a0`) were **refuted**: they read/write a `float` at `object+0x2c` = `ImageBrightness` (`ev_949c116d…`, `ev_c0c4920c…`). They are **not** the ImageAlpha accessor; citing them as such would be wrong.
- `core_feature_find` and the data-section string indexer return 0 (`ev_c85286a5…`, `ev_2248540f…`) — the same CODE-shortstring coverage gap already recorded in X17 §2 pass 8 and DALPHA-01 §4.
- `native_functions_search` finds no named engine converter (`ev_331c42bb…`, `ev_2079bc89…`); function discovery stopped at its 6,000,000-instruction cap, so this is explicitly a **coverage-limited negative**, not proof of absence.

**Verdict:** the enum and its numeric value are **[O]**; the *arithmetic* that turns a decoded intensity byte into the stored alpha byte remains **[U]** and must be settled by the probe below. Any claim that `A = intensity` (identity) is **[I]** only — it is consistent with F06-E8 (`index → grey = max(0, idx−3)`) but not byte-proven, and would collide semantically with `tiaLuminance` unless value 1 is the single-channel short path.

### 3.3 Exact runtime probe (termination condition included)

Do **not** run this under this read-only charter; this is the hand-off instrument for an authorised debugger/GL-trace worker.

1. Attach to the donor **after** the material file `data/terrain/ref/reftilealpha.mat` is parsed. Read the `ImageAlpha` byte of the material whose `image` is `alpha.bmp`; assert it equals **1**.
2. Set a breakpoint on the `glTexImage2D` import (opengl32.dll) / its thunk. Filter on:
   - `format == GL_ALPHA (0x1906)` (`tfAlpha`, F06-E3), and
   - `width × height == 512 × 256` (alpha.bmp) or `1024 × 512` (alphavert.bmp).
3. At the first matching call, dump the `pixels` buffer (131,072 B / 524,288 B) **before** it is consumed.
4. Compare byte-for-byte against F06-E8's decoded palette intensity `V(idx) = max(0, idx − 3)` applied to the BMP's palette-index array:
   - `A == V` → **identity**;
   - `A == 255 − V` → complement;
   - `A == round(255·sqrt(V/255))` → sqrt path;
   - any other byte map → emit the 256-entry LUT `idx → A` from the dump.
5. **Terminate** when either a closed-form expression or a byte-exact 256-entry table reproduces the dump with zero mismatches on both textures. Cross-check the four authored sentinels: `p=0` and `p=16` → 255, `p=15` and `p=31` → 0 (F06-E10, PORT1TO1 §5.1).

No substitute value may be baked into the port before step 5 completes.

---

## 4. U6 — `GL_ALPHA_TEST` enable/disable and exact state order [O]/[D]

### 4.1 The two helpers at `0x4ef97d` and `0x4ef987`

`sub_4ef810` case 1 (`bmTransparency` = enum 1, `ev_e004…`) raw bytes (`ev_c6b5ab46…`):

```
0x4ef97a  mov eax,[esi+0x64]        ; GL context object
0x4ef97d  mov dl,2                  ; capability index 2
0x4ef97f  call 0x88f0f0             ; sub_88f0f0  -> CACHED ENABLE
0x4ef984  mov eax,[esi+0x64]
0x4ef987  xor edx,edx               ; capability index 0
0x4ef989  call 0x88f0f0             ; sub_88f0f0  -> CACHED ENABLE
0x4ef98e  mov eax,[esi+0x64]
0x4ef991  mov cl,7                  ; dfactor table index
0x4ef993  mov dl,6                  ; sfactor table index
0x4ef995  call 0x88fb78             ; glBlendFunc(SRC_ALPHA, ONE_MINUS_SRC_ALPHA)
```

`sub_88f0f0` (`ev_96785ecc…`): `ebx = cap`, `esi = ctx`; if bit `cap` of `[esi+0x8c]` is set → **return** (cached); else `bts [esi+0x8c], cap`; if `[esi+0xe4] > 0`, propagate via each sub-context's vtable slot `+0x54`; else `push [0x8fb0dc + cap*4]; call 0x4afb8c` = **`glEnable@thunk`**.

`sub_88f148` (`ev_1c986c73…`) is the mirror: `bt`/`btr [esi+0x8c]`, propagate via vtable `+0x58`, else `push [0x8fb0dc+cap*4]; call 0x4afb6c` = **`glDisable@thunk`**.

Capability table `0x8fb0dc` (`ev_27eae377…`), typed reads (`ev_ca465020…`, `ev_01b5af23…`):

| cap | u32 GLenum | meaning |
|---:|---|---|
| **0** | `3008 = 0x0BC0` | **`GL_ALPHA_TEST`** |
| 1 | `0x0D80` | capability #1 (not used by the terrain cases) |
| **2** | `3042 = 0x0BE2` | **`GL_BLEND`** |
| 3 | `0x0B57` | `GL_COLOR_MATERIAL`-class capability |
| 4 | `0x0B44` | `GL_CULL_FACE` |
| 5 | `0x0B71` | `GL_DEPTH_TEST` |
| 6 | `0x0BD0` | `GL_DITHER` |
| 7 | `0x0B60` | `GL_FOG` |
| 8 | `0x0B50` | `GL_LIGHTING` |
| 18 | `0x0B90` | `GL_STENCIL_TEST` |
| 20/21 | `0x0DE0`/`0x0DE1` | `GL_TEXTURE_1D`/`GL_TEXTURE_2D` |

### 4.2 Exact order per `BlendingMode` (byte-proven, `ev_c6b5ab46…`)

| Case | VA block | Operations, in order |
|---:|---|---|
| 0 `bmOpaque` | `0x4ef961` | `glDisable(GL_BLEND)` (`0x4ef966` via `sub_88f148`); `glDisable(GL_ALPHA_TEST)` (`0x4ef970`) |
| **1 `bmTransparency` (terrain)** | `0x4ef97a` | **`glEnable(GL_BLEND)`** (`0x4ef97f`); **`glEnable(GL_ALPHA_TEST)`** (`0x4ef989`); `glBlendFunc(0x302,0x303)` (`0x4ef995`) |
| 2 `bmAdditive` | `0x4ef99f` | `glEnable(GL_BLEND)`; `glEnable(GL_ALPHA_TEST)`; `glBlendFunc(0x302,0x301)` = `(SRC_ALPHA, ONE)` |
| 3 `bmAlphaTest50` | `0x4ef9c1` | `glDisable(GL_BLEND)` (`0x4ef9c6`); `glDisable(GL_ALPHA_TEST)` (`0x4ef9d0`); **`glEnable(GL_ALPHA_TEST)`** (`0x4ef9da`); `glAlphaFunc(table_alpha[7]=0x206=GL_GEQUAL, 0.5f)` (`0x4ef9e9`) |
| 4 `bmAlphaTest100` | `0x4ef9f0` | `glDisable(GL_BLEND)`; `glDisable(GL_ALPHA_TEST)`; `glEnable(GL_ALPHA_TEST)`; `glAlphaFunc(GL_GEQUAL, 1.0f)` |
| 5 `bmModulate` | `0x4efa1f` | `glEnable(GL_BLEND)`; `glEnable(GL_ALPHA_TEST)`; `glBlendFunc(0x304,0)` = `(DST_COLOR, ZERO)` |

**Answer to the old [U]: `GL_ALPHA_TEST` is ENABLED for `bmTransparency`, not disabled.** The two `0x4ef97d/0x4ef987` sites are `mov dl,2; call glEnable-wrapper` and `xor edx,edx; call glEnable-wrapper`. There is **no** `glAlphaFunc` call anywhere in case 1, so the alpha comparison function/reference is *not reset* by the terrain material — it stays at whatever the last setter left (GL default `GL_ALWAYS/ref 0`, or a leak of `GL_GEQUAL/0.5|1.0` from cases 3/4). That leak is a genuine **[U] runtime-state question** and must not be folded into the shader; do not add a discard.

### 4.3 Port instruction (exact, no approximation)

- Overlay surface: `render_mode blend_mix` (straight alpha) — this reproduces `dst.rgb' = src.rgb*src.a + dst.rgb*(1-src.a)` with `GL_FUNC_ADD` (X17 §3.2).
- **Do not** add `alpha_scissor`, `discard`, `step(a, …)`, `clamp(a, …)` or any alpha-test substitute: donor case 1 leaves the test enabled but with no terrain-specific compare function.
- **Do not** multiply RGB by alpha (X17 §3.2 / PORT1TO1 §5.4: forbidden PORT APPROXIMATION).
- If a later authorised trace shows the `GL_GEQUAL` leak actually reaching terrain draws, add a ** labelled** uniform threshold — not before.

---

## 5. U9 — fixed-function pass count and base-overlay order

### 5.1 Call chain, byte-proven

```
FUN_008177f0(terrain, x, y)                       [O] ev_6e12d1fa…
  ├─ renderer[0x40] = FUN_00812e34 ; renderer[0x44] = terrain   ; [O] producer install
  ├─ FUN_0081ac98(renderer, …)                                   ; per-cell setup/array resize
  └─ FUN_00818920(cell, renderer, renderer[0x168])               ; ONE call  (0x8179b6)
        └─ [O] ev_ec93f0af… / ev_8abea401…
```

`native_function_callers_list(0x818920)` → exactly one caller (`ev_66723f09…`). `FUN_008177f0` contains exactly one call to it (`ev_6e12d1fa…`).

### 5.2 The builder emits ONE display list and returns [O]

`FUN_00818920` reads the layer-descriptor array at `renderer+0x1c0`, stride `0x10`, count at `renderer+0x1c4` (`FUN_0081aeac`, `ev_3f47f810…`):

```
+0x00  u32  layer/material index  (init = descriptor index)
+0x04  u8   skip flag (init 0)
+0x08  ptr  quad array, stride 0x50
+0x0c  u32  quad count (init 0)
```

Loop: `for (idx = count-1; idx >= 0; idx--)`; accept **only** the first descriptor with `count > 0` and `flag == 0` (`0x819317–0x819346`). For that descriptor:

```
0x819354  rec = FUN_008187e4(renderer)      -> display-list record, registered at renderer+0x1c
0x81936b  rec[4] = descriptor[0]             -> material id
0x81937c  glNewList(FUN_0081a8e4(rec), 0x1300 /*GL_COMPILE*/)
0x819395  if FUN_0081ac70(renderer, materialId) != 0 -> 2-UV emitter FUN_00818428
           else                                      -> 1-UV emitter FUN_0081831c
0x8193c6 / 0x819774  for (q = 0; q < descriptor.count; q++):
              glBegin(5 /*GL_QUADS*/)
              four emitter calls (one per corner)
              glEnd()
              renderer[0x28] += 2             -> 2 triangles per quad
0x819b65  glEndList()
0x819b6a  ret                                 -> RETURNS; no second descriptor processed
```

The `ret` at `0x819b6a` is unconditional after `glEndList` (`ev_8abea401…`, raw tail `0x819b58–0x819b6a`). The alternative path `0x819b72 → 0x81931a` is reached **only** when no descriptor qualified — it is a search loop, not a compositing loop. `FUN_0081a8e4` allocates/returns the GL list id stored at `rec+8` (`ev_131fdf07…`); `FUN_008187e4` registers the record at `renderer+0x1c` (`ev_d13db200…`).

### 5.3 Base-overlay order [O]/[D]

- The quad array is filled by the producer callback in **ascending distinct-tag order**, with the base/full layer first (`mask = 0xf` for the first layer) — PORT1TO1 §3.4, `ev_ceb19ad8…`/`ev_58d7418c…`.
- The display-list loop iterates that array with `q = 0 … count-1` in source order (`0x8193c6`/`0x819774`, `ebx` increment at `0x819b4e`).
- Therefore the framebuffer sees **base quad first, then overlay quads in ascending distinct-tag order**, all inside one compiled list. This is the byte-proven order; it is not a guess of "one pass vs two passes".

### 5.4 Residual [U] — honest boundary

`glCallList` has 17 call sites (`ev_56c5a3d7…`), all inside generic dispatchers. `sub_7829a4` (6224 insns, `ev_3be2ff16…`) applies `sub_4ef810` repeatedly for **different material slots** (`+0xc8`, `+0xd0`, `+0xdc`, `+0xe4`, …) — these are generic scene passes, **not** a recovered heightfield base/overlay loop. No static evidence proves how many times the *specific* heightfield display list is called per cell. **Do not assert** either "the donor issued one `glCallList`" or "the donor issued two"; the mesh structure is proven, the final call count is not.

### 5.5 Port instruction (exact, no approximation)

1. Emit **one mesh per cell** containing `4 × distinct_count` vertices / `2 × distinct_count` triangles, in producer order (base first). Do **not** create a separate draw per layer.
2. Split into **two Godot surfaces only for state reasons**: surface A = `layer_index==0` quads with `ALPHA = 1.0`; surface B = `layer_index>0` quads with `ALPHA = raw mask sample` and `render_mode blend_mix`, depth test `less_equal`, depth write off. This two-surface split is a **Godot rendering-state translation of one donor display list**, not a claim that the donor drew two passes.
3. Preserve quad order within each surface (`q` ascending). Never sort overlays by distance or material.
4. Keep the existing `blend_mix` semantics; do not add `rgb *= a`, thresholds, or per-layer duplicate draws.

---

## 6. U10 — exact `0x48` producer record → `0x50` quad record map [O]

### 6.1 Where the two strides actually live (correction to the U-10 plan)

`sub_818920` itself does **not** convert records. Its `0x30`-stride scratch rows at `0x818b07–0x818cfd` and `0x818d7f–0x8192d2` are the **height/normal smoothing grid** (`FUN_0081af84` rows, `i*0x30`), and `sub_818824` (`ev_20db8cc5…`) is the seam normal fixer. The `0x48`-byte stride belongs to the **producer** `FUN_00812e34`/`FUN_00812b4c`/`FUN_00812ccc`; the `0x50`-byte stride belongs to the **quad array consumed by `FUN_00818920`**. The full read of `sub_818920` was required to locate the consumer and is reported here; the earlier plan's phrasing "read sub_818920 … walk the loop that reads the 0x48 layer records" is corrected to this two-sided map.

### 6.2 Producer record — 0x48 bytes [O]

`FUN_00812b4c` (`ev_6f767eed…`): `puVar1 = *(param_12-4) + (slot & 0xff)*0x48`; `*(u32*)puVar1 = param_2` (material index), `*(u8*)(puVar1+1) = param_4` (mirror). UV writer: `(float*)((char*)puVar1 + (cornerSlot&0xff)*8 + 5)`; `v := 1-v` when `flip` (`_DAT_00812c90 = 1.0f`). `FUN_00812ccc` (PORT1TO1 §5.1) uses the same base with `+0x25` for alpha UVs.

| Off | Size | Field | Source |
|---:|---:|---|---|
| `+0x00` | u32 | material/tag index (byte `+0`) + mirror byte `+1` (+2/+3 padding) | `FUN_00812b4c` |
| `+0x05` | f32 | RGB uv corner 0 `.u` | writer slot `(0+rot)&3`, mirror `3-slot` |
| `+0x09` | f32 | RGB uv corner 0 `.v` (V-flipped when flip) | same |
| `+0x0d..+0x24` | 6 f32 | RGB uv corners 1–3 | same |
| `+0x25..+0x44` | 8 f32 | alpha uv corners 0–3, rot=2, V-flipped, insets 0.1/0.2 only for mask 0 | `FUN_00812ccc` |
| `+0x45..+0x47` | 3 B | tail/padding (no consumer found) | — |

Used UV payload = `0x40` bytes at `+0x05..+0x44`; stride `0x48` = 4 material/header bytes + 0x40 UV bytes + 4 tail bytes.

### 6.3 Consumer record — 0x50 bytes [O]

Quad array base `Qdesc = [descriptor+0x08]`; quad `i` at `Q = Qdesc + i*0x50` (computed as `esi = i*10`, `[Qdesc + esi*8]`, `ev_8abea401…` at `0x81978d–0x819791`, `0x819364` etc.). Four emitter calls at `0x819830`, `0x819931`, `0x819a37`, `0x819a??` read these exact fields:

| Off | Size | Field | Raw read site |
|---:|---:|---|---|
| `+0x00` | u32 | **vertex index B** | `0x819842: imul eax,[Q+0x00],0xb` |
| `+0x04` | u32 | **vertex index A** | `0x819794: imul eax,[Q+0x04],0xb` |
| `+0x08` | u32 | **vertex index C** | `0x819943: imul eax,[Q+0x08],0xb` |
| `+0x0c` | u32 | **vertex index D** | `0x819a49: imul eax,[Q+0x0c],0xb` |
| `+0x10` | 2 f32 | RGB uv pair for vertex B | `0x8198fa: lea ecx,[Q+0x10]` |
| `+0x18` | 2 f32 | RGB uv pair for vertex A | `0x819814: lea edx,[Q+0x18]` |
| `+0x20` | 2 f32 | RGB uv pair for vertex C | `0x8199ff: lea ecx,[Q+0x20]` |
| `+0x28` | 2 f32 | RGB uv pair for vertex D | (4th call, `+0x28 + esi*8`) |
| `+0x30` | 2 f32 | alpha uv pair for vertex B | `0x8198b8: lea eax,[Q+0x30]` |
| `+0x38` | 2 f32 | alpha uv pair for vertex A | `0x8197d1: lea edx,[Q+0x38]` |
| `+0x40` | 2 f32 | alpha uv pair for vertex C | `0x8199bc: lea eax,[Q+0x40]` |
| `+0x48` | 2 f32 | alpha uv pair for vertex D | `0x819ac2: lea eax,[Q+0x48]` |

Vertex indices multiply by `0xb` (`11`) to index the interleaved vertex array at `renderer+0x1b8` whose record stride is `0x2c` (44 B): position at `+0x00/+0x04/+0x08`, secondary at `+0x10`, normal at `+0x20`. `0xb * 4 = 0x2c` — the multiplier is the record index, not a byte stride.

**Corner pairing (exact, from the raw push order):**

| Emitted corner | vertex index | RGB uv | alpha uv |
|---|---|---|---|
| A | `Q[+0x04]` | `Q+0x18` | `Q+0x38` |
| B | `Q[+0x00]` | `Q+0x10` | `Q+0x30` |
| C | `Q[+0x08]` | `Q+0x20` | `Q+0x40` |
| D | `Q[+0x0c]` | `Q+0x28` | `Q+0x48` |

`glBegin(5)` = `GL_QUADS`; emission order is A, B, C, D per quad (`0x819774–0x819b52`), and each quad is a separate `glBegin/glEnd` pair inside the one display list.

### 6.4 The `0x48 → 0x50` relation

- Producer UV payload `+0x05..+0x44` (0x40 B) → consumer UV payload `+0x10..+0x4f` (0x40 B): **constant shift `+0x0b`** for both RGB and alpha blocks (`0x05+0x0b=0x10`, `0x25+0x0b=0x30`).
- The 16 bytes ahead of the UV payload in the `0x50` record are four `u32` vertex indices (corners B, A, C, D). `0x10 + 0x40 = 0x50`; producer used 4 header bytes + 0x40 UV + 4 tail = `0x48`.
- **Status:** the two record layouts are **[O]**, and the shift/header relation is **[D]** by byte arithmetic. The *copy instruction that performs the shift* was not isolated in this pass (the installed callback is invoked indirectly; `FUN_008177f0` stores it at `renderer+0x40/+0x44`). A future worker should resolve the indirect call site at `renderer+0x40` to byte-prove the copy; no approximation is substituted here.

### 6.5 Port instruction (exact mesh layout)

1. `ARRAY_VERTEX` = the four donor cell-corner positions, ordered **A, B, C, D** as in §6.3 (not cell centres).
2. `ARRAY_TEX_UV` = RGB uv baked from producer `+0x05..+0x24`; `ARRAY_TEX_UV2` = alpha uv baked from producer `+0x25..+0x44`. Do **not** compute either in the fragment shader.
3. `ARRAY_COLOR` may carry `r=tile id`, `g=layer index`, `b=alpha patch index p`, `a=mask` purely as shader selectors; it is not a donor vertex attribute and must be labelled as a port transport.
4. Triangles per quad: `(A,B,C)` and `(A,C,D)` in that order, matching `GL_QUADS` A→B→C→D.
5. Do not use `0x48` as a vertex stride anywhere in the port; `0x48` is the producer's staging stride, `0x50` is the donor quad array stride, and neither is a hardware vertex format.

---

## 7. Corrections to prior material

| Prior claim | This pass | Status |
|---|---|---|
| PORT1TO1 U-10 plan: "walk the loop in sub_818920 that reads the 0x48 layer records" | `sub_818920` reads a `0x50`-stride quad array and a `0x30`-stride normal scratch; the `0x48` records are produced by `FUN_00812e34`/`0x812b4c`/`0x812ccc` | **Refined** (§6.1) |
| X17 / PORT1TO1: "whether GL_ALPHA_TEST is disabled at `0x4ef97d/0x4ef987` is [U]" | both sites call the **enable** wrapper; ALPHA_TEST is enabled | **Resolved** (§4) |
| X17 / PORT1TO1: "pass count [U], one pass vs two equally unproven" | mesh builder proves **one display list per cell** with ordered internal quads; the final `glCallList` count remains [U] | **Resolved structurally; residual tail** (§5) |
| F06 / X17 / PORT1TO1: "exact `tiaAlphaFromIntensity` formula [U]" | enum recovered (`value 1`); arithmetic still [U], exact upload probe given | **Partially closed** (§3) |
| DALPHA-01 §4 "candidate patch functions `PatchIndex`/`GetAlphaPatch`/`AlphaTileIndex` = 0 matches" | unchanged; this pass adds 0 named converter functions as well (function list capped at 6M insns) | **Confirmed with coverage caveat** |

---

## 8. Remaining unknowns (not waived)

| ID | Unknown | Next instrument | Termination |
|---|---|---|---|
| U4b | Arithmetic of `tiaAlphaFromIntensity` (enum value 1) | §3.3 GL-upload byte dump + RTTI jump-table follow from `0x4e6e28` | closed form or byte-exact 256-entry LUT, zero mismatches, four sentinels fit |
| U6b | Whether `GL_ALPHA_TEST` leaks `GL_GEQUAL` from cases 3/4 into case 1 at terrain draw time | GL trace of `glAlphaFunc` vs `sub_4ef810` case 1 order in a live frame | observed compare func/ref at the terrain draw |
| U9b | Number of `glCallList` executions of the heightfield list per cell | break/trace `glCallList` thunk `0x4afc7c` filtered on the list id from `FUN_0081a8e4` | counted calls per cell, with material-state order |
| U10b | Static site of the `+0x0b` UV shift / index-header insertion | resolve the indirect callback at `renderer+0x40` installed by `FUN_008177f0`, then follow its 0x48→0x50 copy loop | instruction-level copy map matching §6.4 |
| U13 | Visual parity | donor GPU A/B frame | **not closeable** under this charter; stays open |

---

## 9. Bottom line

`GL_ALPHA_TEST` is **enabled** (not disabled) immediately before `glBlendFunc(SRC_ALPHA, ONE_MINUS_SRC_ALPHA)` for `bmTransparency` — `0x4ef97f`/`0x4ef989` both call the cached enable wrapper `sub_88f0f0`, reading cap 2 (`GL_BLEND`) and cap 0 (`GL_ALPHA_TEST`) from table `0x8fb0dc`. The heightfield mesh builder emits **one display list per cell** containing all base/overlay quads in producer order, with a byte-exact **`0x50`-byte quad record** (4 vertex indices + 4 RGB uv pairs + 4 alpha uv pairs) derived from the producer's **`0x48`-byte layer record** by a `+0x0b` UV shift and a 16-byte index header. `tiaAlphaFromIntensity` is enum **value 1** of `TOSWTextureImageAlpha`; its arithmetic remains [U] with an exact GL-upload probe specified. No approximation is presented as donor fact and **no donor parity is claimed**.

*End of DEC-U-ALPHA-PASS-QUAD. Files written: this report only. Donor read-only; no binary executed, copied or committed; no code, shader, config, asset, test, git, Godot or investigation-memory state changed.*
