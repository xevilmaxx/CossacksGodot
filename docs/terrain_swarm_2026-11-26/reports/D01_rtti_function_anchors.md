---
id: D01
ticket: "TERRAIN-SWARM-2026-11-26 / D01"
task: "Definitive RTTI-class → concrete CODE-function anchor map for the terrain/world subsystem of cossacks.exe"
date: 2026-11-26
status: DELIVERED__READ_ONLY__NO_SOURCE_EDIT__NO_GODOT_JOB
scope: "One Markdown report written. No donor file copied/executed/committed; no source, shader, config, asset, test, git or other-doc edit; no runner job."
donor: "C:\\Games\\Cossacks 3\\cossacks.exe (READ ONLY, SHA-256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c, 5,768,048 B)"
shared_target: "t_87f0f3c130b0 = cossacks.exe — ALREADY active before D01; no core_target_open/select called; document: passed explicitly on every Craft Anything call"
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION"]
visual_parity_claim: false
---

# D01 — RTTI class → concrete CODE function anchor map (donor terrain/world)

## 0. Executive summary

1. **[O] The "0 code xrefs" paradox is resolved.** The `X*` strings previously recovered from
   `.rsrc` (`XWorld`, `XMapGenerator`, `XWater`, …; `ev_238c801…`, `ev_d9c6e28…`, `ev_ec5fbf04…`)
   are **unit names stored inline inside Delphi class-RTTI records in `CODE`**, not stand-alone live
   string literals. Example: at `cossacks.exe` VA `0x71c849` / file `0x31bc49` the inline shortstring
   `XMapGenerator` sits inside the RTTI record whose class name is `TXMapGenerator` at `0x71c830`
   (`ev_0d83cdaa83e181ae32df747439d055dfc713fcc44231b205390273c75f41a18e`). Hence `native_xrefs_list`
   correctly reports **0 code references** to the string addresses while the *class* is fully anchored.
   **[D] The concrete classes carry a `TX` prefix** (`TXMapGenerator`, `TXTerrainDataLite`,
   `TXTileSmooth`, `TXPattern`, `TXWaterManager`, `TXTerrain`, …); the bare `X*` names are unit names.
2. **[O] 1,182 Delphi VMTs were recovered statically** from `CODE` bytes using an empirical
   `vmtClassName`/instance-size/parent/virtual-slot signature (no string xrefs, no symbols, no
   execution). 64 terrain/world classes were extracted with full method arrays (§4). The VMT
   *self-pointer* is not at the documented classic offset; this compiler stores it at `VMT-0x4c`.
   Every pass and correction is logged in §3.3 per the owner's multiple-pass directive.
3. **[O] The five requested classes are concretely identified:**
   - `TXMapGenerator` VMT `0x71c78c`, constructor `0x71d2fc`, destructor `0x71d67c`
     (`ev_7acd734c…`, `ev_449ce07c…`, `ev_103b50c8…`).
   - `TXTerrainDataLite` VMT `0x59b6bc`, constructor `0x59b6e8`, destructor `0x59b724`
     (`ev_39e5b170…`, `ev_cf4fbd82…`, `ev_12fa0455…`).
   - `TXTileSmooth` VMT `0x72d6e8`, **data-only class**: generic destructor `0x404564`, no user
     virtuals (`ev_0e756058…`, `ev_6b285f0e…`). Constructor address observed in bytes but its
     decompilation is BLOCKED → `[U]` (§3.3 pass log).
   - `TXPattern` VMT `0x754544`, constructor `0x754cb0`, destructor `0x754dd8`
     (`ev_bc91323a…`, `ev_644cd89c…`, `ev_9037a1af…`). Constructor defaults recovered verbatim.
   - **`XWater` is a subsystem, not one class**: `TXWaterManager` `0x851a40` (ctor `0x851f18`,
     dtor `0x851f94`), `TXWaterField` `0x73a944`, `TXWaterProxy` `0x84eb18`, `TXWaterShader`
     `0x853768`, `TXWaterUniforms` `0x853610`, `TXPatternWater` `0x75436c`, `TXWaterCollection`.
4. **[O] No `mov [ecx], offset VMT` constructor store exists in `CODE`** for the 14 tested VMTs
   (whole-file dword scan: 0 hits, including RVA-encoded values; §3.2). Delphi constructors instead
   call `FUN_004048ec` (`@NewInstance`) with the class reference and install the vptr there —
   confirmed by the shared `if (param_2) param_1 = FUN_004048ec();` pseudo-C prologue in every
   recovered constructor. This corrects the C++Builder-style expectation in the D01 brief.
5. **[U] No donor parity claim.** Every method *role* below is a derived/inferred reading of
   Ghidra pseudo-C and VMT position, not original source. No donor GPU frame was produced.

**Anchor counts (observed):** 1,182 VMTs with valid class-name shortstrings; 64 terrain/world
classes in the extract; 8 of 1182 are RTL/engine base classes used to decode the generic virtual
slots. **Decompilation coverage:** 11 concrete functions passed through ≥2 independent passes
(§3.3); 5 core classes verified by ctor/dtor field-pair symmetry.

---

## 1. Evidence table

| # | Evidence id | Establishes | Label |
|---|---|---|---|
| E1 | `ev_e7533ff33eadc37298d3877bfad230213f3f00888319b896daa71be2b868abc6` | donor identity/triage (prior DA report) | [O] |
| E2 | `ev_d5b51af0808dd609842ab36f411ca6cbd51212d8de038e641acfd28d3198239f` | section map: `CODE` VA `0x401000` file `0x400` size `0x4f0da8`; `.rsrc` VA `0x94c000`; `.bind` entropy 7.96 | [O] |
| E3 | `ev_238c801…`, `ev_d9c6e28…`, `ev_ec5fbf04…` (DECOMP-02 ledger) | 111 `X*` / 474 `T*` strings, 0 code xrefs — prior-art baseline | [O] |
| E4 | `ev_0d83cdaa83e181ae32df747439d055dfc713fcc44231b205390273c75f41a18e` | RTTI class record: name `TXMapGenerator`, VMT `0x71c78c`, inline unit name `XMapGenerator`, fields `GlobalParams`, `TerrainParamsCollection`, `HillPoints`, `Project` | [O] |
| E5 | `ev_103b50c81bd58a35190de5cc3249cdc504c71432e93257a7a19440990625cbc4` | `TXMapGenerator` VMT bytes at `0x71c760` (nameptr `0x71c816`, size `0xc4`, parent anchor `0x401154`, 8 special slots, dtor `0x71d67c`) | [O] |
| E6 | `ev_39e5b170198abd5cf4e0eeb36374ddd217c340772bb1b5698ea17ec937576961` | `TXTerrainDataLite` VMT bytes at `0x59b690`, size `0x28`, dtor `0x59b724` | [O] |
| E7 | `ev_0e756058500b3903cfb7dc0638bbac771c01aae36c542f15635c97bcb08f75b9` | `TXTileSmooth` VMT bytes at `0x72d6bc`, size `0xc`, generic dtor `0x404564` | [O] |
| E8 | `ev_bc91323a3191432fc180f18301985ea40c65f2c0da5375faac7cc719edd295b1` | `TXPattern` VMT bytes at `0x754518`, size `0x90`, dtor `0x754dd8` | [O] |
| E9 | `ev_55a251a0043f7a687fa7a33b79903df659a512931006251b5d1b5992e8c1a2e8` | `TXWaterManager` VMT bytes at `0x851a14`, size `0x20`, dtor `0x851f94`, class name at `0x851a40` | [O] |
| E10 | `ev_7acd734c523fce2bc5ddffaecf52ef94846a6480d7929a8257d6474d3cd5a62e` | `TXMapGenerator.Create` = `FUN_0071d2fc` pseudo-C (100 lines, field offsets) | [D] |
| E11 | `ev_ad06ff1890584eda0dfa9bbc202b0d54a8062a41e4a668c27f731698dd976ac0` | same, clean-room study: 261 instructions / 5 blocks / 32 calls / 1 caller | [O] |
| E12 | `ev_a4422ff26f9c011fb55ab4801066fdc4949cea5c348a343be8216e83385488a5` | caller of `0x71d2fc`: `sub_710380` @ call site `0x710b10` | [O] |
| E13 | `ev_d81c02ebf560a59ac813606436059616aaf2139da1cb9a62a132eb5235cc20f6` | 32 concrete callees of the generator constructor | [O] |
| E14 | `ev_449ce07c5748f4c2a9ad921e4e9fb172a4f035f06640840ff6eac2ed7cbe0d33` | `TXMapGenerator.Destroy` `0x71d67c` pseudo-C — frees the exact same fields the ctor creates | [D] |
| E15 | `ev_cf4fbd826c2e00329817358f223ac094ae66dfcc46fb11a9ed29187723126a9f`, `ev_d18c645099e5185f9fb80cb72b73bc72c6856934ac35b96e64a56d660844a9b5` | `TXTerrainDataLite.Create` = `FUN_0059b6e8` | [D] |
| E16 | `ev_12fa04553d17cd9003bdc85f6a47dd3de4b02eb82c10cce866b8d5aa921ead74` | `TXTerrainDataLite.Destroy` `0x59b724` | [D] |
| E17 | `ev_644cd89c43540fc14909c1530ba6e85e879457781a0b4176543a764fc5c375d1` | `TXPattern.Create` = `FUN_00754cb0` pseudo-C, field defaults (3/4/2, floats 1.0) | [D] |
| E18 | `ev_9037a1af03d8d544c6229526ee844267fc8e3c9a9a7a5c101f7c198bd451efda` | `TXPattern.Destroy` `0x754dd8` | [D] |
| E19 | `ev_9e78506602ed893abf07265e6d5a8746d78554f5e3261b283fd22e3a1b5bd0aa` | `TXWaterManager.Create` `FUN_00851f18` | [D] |
| E20 | `ev_079b7c55e1937f6b149292118b877ab420db12d37b1b04a713f27919318e5172` | `TXTerrainData.Create` `FUN_0082e1cc/0x82e1cf` | [D] |
| E21 | `ev_cd49d655df0fd755a8d78877be41a7116d8000dd2afab661eaad26a11a57bcb6` | `TXWorld.Create` `FUN_007d715c` | [D] |
| E22 | `ev_f5e7c5d095d94f9cd6d1bac5129efb9de582ec52fa64842af347ae09c6626687` | `TXTopology.Create` `FUN_007d9fc4` | [D] |
| E23 | `ev_b813fefa5a242dd482b5c5882821999f9c70528057c65402e86cbfddc9a38a74` | `TXCollisionMask.Create` `FUN_00849fcc` | [D] |
| E24 | `ev_d103214b599d9f4b3e16a4875e1b2b912d8f65f36d030a6a0e146753443d21c3`, `ev_c8d5deb7783afa59438d25ef19b198f612decd01300cd79561079f114c2737b0`, `ev_9b294a26459fd8a249c453cbf0f687aedbc25750e14018cb645260cc4e6186a8`, `ev_a761d806a199faa19db49893123009494fa5081479a92eacd0a1ef64e880205f`, `ev_a5ec018ff02ee1743fd1cda4099c3e3c030c8a0f65d6d12560133e6760e4bb7b`, `ev_6515faf58fdc3d6b2a02aa124f1f5529236d893f7399e7343f3c2f06e3c8c5ce`, `ev_6b285f0e2b9f7c4108f2a8f21ce500d60382cac77a47171a4a38ec366d76573c` | generic virtual slots 1–8 decoded (SafeCallException…Destroy) | [O]+[D] |
| E25 | `ev_1d896b5111108651373ff591b5d698466c0088670acc0d3f5f76a3f21e725812`, `ev_8963ea769d5b3748fab7e6e7efe44511fd6d6f4a3f86faae4c1e324bccf4dfbe`, `ev_0ce56e145382ff8b2f23cc2bb94e9ea6621020b28dfadf72223efdc3790c9676` | anomaly log for `0x40450c` (garbled pseudo-C vs clean bytes) | [O] |
| E26 | `ev_19587542dc270e6e041e8eb641c8b3b8541ee3a46faadefc3d8414654232dfed`, `ev_0fa105c7344bd56408255ff2372064fbb39d58793734408f0622bacd07b587c3` | `TXMapGenerator.Destroy` raw bytes + 0 static xrefs (computed-pointer dispatch) | [O] |
| E27 | `ev_85951be6f36a62d5cd3ec0a9fdf73d6a72b8b9fc8572aab3d70712c2f4876b96`, `ev_6fa73e6762b29133f9d0625d854a3fc755c37bc404d61d5f6805208787a80ae8`, `ev_feb273081bcebd6685b24a00135c66e72b0405b63ae8045985cd95860a7ebf7f`, `ev_48e67193fd888801641a969be581c64ddb77206c3f41243fb7fff3f013553bac`, `ev_c68539f6e98ea739e5ec8ec4e2613b062ad63d8981af448071bc4de45067e5fe` | `TXTileSmooth.Create` 5-pass anomaly log: bytes clean, decompiler BLOCKED | [O]/[U] |
| E28 | `ev_f72e8b402a83415397059c01e8794d09ba0f4e0f6c1be7f037a221cb0eda1bd6` | `FUN_0072d90e` (`TXTileSmoothList` family ctor) | [D] |
| E29 | `ev_7d708c70ec8d9f4e381b9fc0319dab0d9a88db29a0f0147f1c8ad82da14616db` | cross-target check: `TXTerrainDataLite` also present in `editor.exe` CODE VA `0x5b2ee3` | [O] |
| E30 | `ev_750820b4fd265739c69f059809f046abcbc31263a6d1bf64aee1689224d93fb7` | `0x42eb44` component-class slot override (virtual call via `[obj+0x20]+0x1c`) | [O] |

**Correction log (kept visible):** the first draft mistyped E17's evidence id twice; it was
re-queried with `native_function_pseudocode` and corrected to
`ev_644cd89c43540fc14909c1530ba6e85e879457781a0b4176543a764fc5c375d1`. No conclusion depends on
the discarded spelling.

---

## 2. Method

### 2.1 Constraints and target handling

Read-only static analysis of `C:\Games\Cossacks 3\cossacks.exe` and a read-only byte search in
`C:\Games\Cossacks 3\editor.exe`. The shared Craft Anything target `t_87f0f3c130b0` was **already
active**; D01 did not call `core_target_open` or `core_target_select`. Every native call passed
`document: "t_87f0f3c130b0"` and every cross-target call passed `path=`. No binary was executed,
copied into the repo or committed. Python scripts were written only to the approved temp folder
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\` (byte scans, no repo writes).

### 2.2 Anchor strategy (no string xrefs)

1. Read PE headers/sections with Python (`e_lfanew`, section table): `IMAGE_BASE 0x400000`,
   `CODE` VA `0x401000..0x8f1da8`, file `0x400..0x4f1940`; `.rsrc` VA `0x94c000`.
2. Search `CODE` for Pascal shortstrings (`<len><ASCII name>`) matching class-name grammar.
   Thousands exist (property/field/type names), so a pointer/structure test is required.
3. Test candidate VMT anchors by structural signature:
   `[nameptr, …, nameptr, size, parent-anchor, 8 CODE pointers, name shortstring]`.
   Result: **1,182** VMTs (modern Delphi); filter to 64 terrain/world classes.
4. Resolve the *real* VMT pointer from `vmtSelfPtr` at `VMT-0x4c`, then read the 8 special slots
   (`VMT-0x20..-0x4`) and user virtuals (`VMT+0` upward until a non-CODE dword).
5. Anchor ctors/dtors by: (a) dtor = VMT slot `-4` (Ghidra decompile to verify field frees),
   (b) ctor = the adjacent `test dl,dl / jz / call FUN_004048ec` Delphi constructor body whose
   field writes are the *exact inverse* of the dtor frees, (c) direct-call callers list.
6. Decompile every chosen function with **both** Deep/Ghidra (`native_function_pseudocode`) and
   the clean-room lifter (`native_function_study`) where possible; inspect raw bytes and xrefs.

### 2.3 Multi-pass anomaly log (owner directive — nothing silently skipped)

| Anomaly | Pass 1 | Pass 2 | Pass 3+ | Accepted reading |
|---|---|---|---|---|
| Classic VMT layout (`vmtSelfPtr=-0x40`, `vmtClassName=-0x20`) found **0** candidates | Python aligned scan over all mapped sections → 0 | modern `-0x2c/-0xc` assumption → 0 | byte dumps at `0x401140`, `0x439270`, `0x71c730` showed `[nameptr, zeros, nameptr, size, parent, 8 code slots, name]` | **[D] empirical layout**, selfptr at `VMT-0x4c`; 1,182 VMTs found; marked derived, not a Delphi-header quote |
| `TObject` appeared twice (VMT `0x401180` and `0x4011a0`) | scan reported `0x401180` | byte dump shows selfptr field `0x401154 → 0x4011a0` | re-derived `VMT=0x4011a0`; `0x401180` is the 8-slot special block | [O] both addresses are real structures; only `0x4011a0` is the class pointer |
| `X*` strings have **0 code xrefs** (DECOMP-02) | `native_xrefs_list` → 0 (prior) | Pascal shortstring scan found inline `XMapGenerator` at `0x71c849` | RTTI record dump at `0x71c840` shows it inside the `TXMapGenerator` class record | [O] xrefs are 0 **because the name is inline data inside a record**, not an absent class |
| 0 immediate VMT references in CODE for 14 tested classes | scan full file for full VA → 0 | scan for VA−imagebase → 1 unrelated hit (`0x412656`) | ctor pseudo-C shows vptr installed by `FUN_004048ec`, not by a store | [O] Delphi `@NewInstance` pattern; C++Builder `mov [ecx],vmt` expectation does not apply |
| `0x40450c` pseudo-C garbled (`outsb`, `imul … 0x555c6e72`) | `native_function_study` → 40 instr, clean-room, entry wrongly `0x404478` | `native_function_pseudocode` → same garbled text (`ev_0ce56e14…`) | raw bytes `ev_1d896b51…` + disassembly `ev_8963ea76…` isolate clean body at `0x40450c` | [D] `NewInstance`: `push ebx; mov ebx,eax; call 40453c; call 402e7c; mov edx,eax; mov eax,ebx; call 404580; pop; ret`. Garbled text **discarded**, pass log kept |
| `TXTileSmooth` ctor decompilation garbled | `0x72d80a` → clean-room entry `0x72d64c`, nonsense | `0x72d800`, `0x72d806` → same wrong engine | `0x72d7f0` (raw-byte entry) → still `sub_72d64c`; `ev_c68539f6…`; raw bytes clean (`ev_85951be6…`) | **[U] BLOCKED** — Ghidra cannot create a function there; clean-room overlaps a bad discovered function. Address observed, semantics unverified |
| `native_function_find` fails for VMT destructor addresses | `function_not_found` for `0x71d67c` | `native_bytes_show` returns valid x86 | `native_function_pseudocode` makes an on-demand Ghidra function successfully | [O] function-discovery incompleteness (DA_PE §4.3), not absent code; `made_on_demand` limitation recorded |
| Rizin/objdump cross-decoder requested | `native_rizin_command_run` → `engine_missing` | `native_objdump_run` → `engine_missing` | used Ghidra + clean-room + raw bytes + `editor.exe` byte search instead | [O] second decoder unavailable in this session; documented, not hidden |

## 3. Detailed findings

### 3.1 VMT layout recovered from bytes (derived, not a vendor header)

For any class in this build the following 4-byte words are observed in `CODE`:

```
A = vmtClassName field address          (points at <len><ClassName> shortstring)
A-0x20 = vmtSelfPtr                     (value = the class VMT pointer V)
A-0x1c = vmtInstanceSize                (4-aligned, 4..0x8000)
A-0x18 = vmtParent                      (address of parent's A field; 0 for TObject)
A+0x0c .. A+0x28 = 8 special virtual slots at V-0x20 .. V-0x4
V = A+0x2c (equivalently value at A-0x20)
V+0x00 .. = user virtual methods until a non-CODE dword
```

Byte proof for `TXMapGenerator` (`cossacks.exe` VA `0x71c760`, file `0x31bb60`, E5):
`16 c8 71 00` → name `0x71c816`; `c4 00 00 00` → size 196; `54 11 40 00` → parent anchor
`0x401154`; then `d0 47 40 00 dc 47 40 00 e0 47 40 00 e4 47 40 00 d8 47 40 00 0c 45 40 00
28 45 40 00 7c d6 71 00` → the 8 slots. The selfptr word at `0x71c740` = `0x71c78c` = V.
Class name shortstring at `0x71c816` = `0e 'TXMapGenerator'` (E4/E5).

Generic slot decode (E24), cross-checked against `TObject` (`V=0x4011a0`, name `0x4011a0`,
size 4, parent 0):

| Slot | Address | Pseudo-C reading | Inferred Delphi name | Label |
|---|---|---|---|---|
| `V-0x20` | `0x4047d0` | `return 0x8000ffff` | `SafeCallException` (E_UNEXPECTED) | [O]+[I] |
| `V-0x1c` | `0x4047dc` | empty | `AfterConstruction` | [O]+[I] |
| `V-0x18` | `0x4047e0` | empty | `BeforeDestruction` | [O]+[I] |
| `V-0x14` | `0x4047e4` | message-number dispatch, default via `[vptr-0x10]` | `Dispatch` | [O]+[I] |
| `V-0x10` | `0x4047d8` | empty | `DefaultHandler` | [O]+[I] |
| `V-0x0c` | `0x40450c` | allocate + install vptr via `40453c/402e7c/404580` | `NewInstance` | [D] |
| `V-0x08` | `0x404528` | `FUN_004045d8(p); FUN_00402eac(p);` | `FreeInstance` | [D] |
| `V-0x04` | class-specific or `0x404564` | frees fields, then `FUN_0040493c` | `Destroy` (destructor) | [D] |

TComponent-descended classes replace slots `V-0x20`/`V-0x18` with `0x42eb44`/`0x42e484`
(E30): `0x42eb44` pseudo-C checks `[obj+0x20]` and calls `[vptr+0x1c]` — an inherited
component-action override, not a terrain algorithm.

### 3.2 Constructor mechanism — why `mov [ecx], vmt` is absent

Whole-file dword scan for each of 14 representative V addresses (full VA and VA−imagebase):
**0 code sites**. Instead, every recovered constructor starts with the same Delphi idiom:

```c
if (param_2 != 0) param_1 = FUN_004048ec();   // @NewInstance: allocates + writes vptr
... field initialisation at param_1+offsets ...
if (param_2 != 0) FUN_00404944(param_1);       // @AfterConstruction
return param_1;
```

This is observed in `TXMapGenerator.Create` (E10), `TXTerrainDataLite.Create` (E15),
`TXPattern.Create` (E17), `TXWaterManager.Create` (E19), `TXTerrainData.Create` (E20),
`TXWorld.Create` (E21), `TXTopology.Create` (E22), `TXCollisionMask.Create` (E23).
**Conclusion [D]:** the D01 brief's expected C++Builder vtable-store pattern is not the pattern in
this binary; constructors were anchored by the `NewInstance` prologue + ctor/dtor field symmetry.

### 3.3 Constructor/destructor decompilations (multi-pass)

**TXMapGenerator** — VMT `0x71c78c`, size `0xc4`, parent anchor `0x401154` (E5).
- `Create = FUN_0071d2fc` at `0x71d2fc` (E10, E11: 261 instructions / 32 calls / 1 direct caller
  `sub_710380` at `0x710b10`, E12). Passes: Ghidra pseudo-C 100 lines; clean-room dossier;
  callee list (E13); raw bytes at adjacent VMT. Key statements:
  ```c
  iVar1 = FUN_0071cd00(PTR_DAT_0071c0e4,1); *(int*)(p+4) = iVar1; *(int*)(iVar1+4) = p;
  iVar1 = FUN_0072f7b8(PTR_PTR_0072e1e4,1); *(int*)(p+8) = iVar1; *(int*)(iVar1+0x18) = p;
  iVar1 = FUN_00403a0c(0x7fffffff); *(int*)(p+0x18) = iVar1; *(int*)(p+0x1c) = iVar1 >> 0x1f;
  FUN_00406d50(p+0x8c, PTR_DAT_0071c5d8, 2, n*3, n*3);      // dynamic arrays sized 3*GlobalParams+3
  ... p+0x7c/0x80/0x84/0x88/0x98/0x9c/0xa0/0xa4/0xa8/0xac/0xb0/0xb4/0xb8 ...
  *(float*)(p+0x40) = 1.0f; *(float*)(p+0x44) = 1.0f;
  *(int*)(p+0x48) = FUN_00731314(...);  // season set
  *(int*)(p+0x4c) = FUN_00731ae0(...);  // tile-smooth config
  *(int*)(p+0x50) = FUN_0072d91c(...);  // tile coverage
  *(int*)(p+0x54) = FUN_007308e0(...);  // pattern cover
  *(int*)(p+0x5c) = FUN_0072ab24(PTR_DAT_007291d0,1);
  ```
  Field names from the RTTI record (E4): `XMapGenerator` (unit), `GlobalParams`,
  `TerrainParamsCollection`, `HillPoints`, `Project`. [D] The `0x7fffffff` / `>>0x1f` pair at
  `+0x18/+0x1c` is a candidate seed/RNG state → hand to **D02**.
- `Destroy = 0x71d67c` (VMT slot `V-0x4`; E14, E26). Passes: `native_function_find` → not found;
  raw bytes `53 56 e8 …` confirm a real function; Ghidra on-demand pseudo-C frees exactly the
  arrays allocated by `Create` (`+0x8c`, `+0x7c..+0xb8`) and calls `Destroy` on the objects at
  `+4,+8,+0xc,+0x48..+0x5c,+0xbc,+0xc0`. **Ctor/dtor field-pair symmetry is the verification**
  requested by the brief. Static xrefs = 0 because dispatch is through the VMT.

**TXTerrainDataLite** — VMT `0x59b6bc`, size `0x28` (E6).
- `Create = FUN_0059b6e8` `0x59b6e8` (E15, two passes: entries `0x59b6e4` and `0x59b6f0` both
  resolved to the same function): zeroes `+4, +8, +0x18, +0x1c, +0x20, +0x24`.
- `Destroy = 0x59b724` (E16): frees strings at `+0x10`, `+0x14` via `FUN_00406d50`, then generic
  teardown. [D] A compact height/tile-data holder with two owned string fields; relevant to D04.

**TXTileSmooth** — VMT `0x72d6e8`, size `0xc` (E7). **No virtual overrides**; destructor = generic
`0x404564` (E24). Raw bytes at `0x72d7e0` show an RTTI property `Project` followed at `0x72d7f0`
by `53 56 84 d2 74 08 …` (a Delphi constructor). Five decompilation passes attempted (E27):
`0x72d80a`, `0x72d800`, `0x72d806`, `0x72d7f0`, all resolved to the bad discovered function
`sub_72d64c` with garbled clean-room output; Ghidra refuses to make a function there.
**Constructor entry `0x72d7f0` = [O] bytes, semantics = [U] BLOCKED.** The *class identity* is
nevertheless certain from the VMT and name shortstring at `0x72d6fa`.

**TXPattern** — VMT `0x754544`, size `0x90` (E8).
- `Create = FUN_00754cb0`, entry `0x754cb0`; Ghidra was passed `0x754ce0` and resolved the
  enclosing function correctly (E17). Defaults (verbatim from pseudo-C):
  `int +0x50=3, +0x54=4, +0x58=2`; `float +0x40/+0x44/+0x48/+0x68/+0x6c = 1.0f`;
  three owned lists at `+8,+0xc,+0x10`; booleans at `+0x18,+0x19,+0x1a,+0x39,+0x4c,+0x82,+0x83..+0x89`.
- `Destroy = 0x754dd8` (E18) frees `+0x10,+0xc,+8` — exact inverse. [D] This is the runtime
  `pattern.lib` record class (family, weights, height-field scale defaults); cross-wire with F01.

**XWater → concrete cluster.**
- `TXWaterManager` VMT `0x851a40`, size `0x20` (E9), `Create = FUN_00851f18` `0x851f18`
  (E19: creates object at `+8` via `FUN_00853390`, shader at `+0x10` via `FUN_0085637c`,
  calls `FUN_00851d04`, sets `+0x1c = -1`), `Destroy = 0x851f94`; no user virtuals.
- `TXWaterField` VMT `0x73a944` size `0xb0`, destructor `0x73ac54`, scene-object virtuals
  incl. `0x73ab88`, `0x73b520`, `0x73ac90`; `TXWaterProxy` `0x84eb18` dtor `0x4c980c`;
  `TXWaterShader` `0x853768` size `0x240` dtor `0x856444`, virtuals `0x855b30`, `0x85637c`,
  `0x856530`, `0x856e2c`; `TXWaterUniforms` `0x853610`; `TXPatternWater` `0x75436c`.
  **[D] There is no `TXWater` VMT** — the bare `XWater` `.rsrc` string is a unit name. This is
  the concrete answer to "identify XWater".

**Other verified constructors:** `TXTerrainData` `FUN_0082e1cc/0x82e1cf` (E20), `TXWorld`
`FUN_007d715c` (E21), `TXTopology` `FUN_007d9fc4` (E22; sets bounds `+0x38..+0x44` to
`0x7fffffff`/`0x80000001` and allocates a cell buffer from `[obj+0x50]+0x2c`), `TXCollisionMask`
`FUN_00849fcc` (E23). All show the `NewInstance` prologue and are paired with their VMT dtors.

## 4. Class → VMT → method anchor table

All addresses are **VA in `cossacks.exe`** (`CODE` file offset = VA − `0x400c00`). `V` = class VMT
pointer (`vmtSelfPtr` at `V-0x4c`). `A` = address of `vmtClassName` field (`=V-0x2c`). "Dtor" is
the VMT slot `V-0x4`; "virtuals" are `V+0..` (empty = data-only class). Constructor is non-virtual
and comes from the paired body described in §3.3. Roles are **[I]** unless the pseudo-C was read.

| Class | VMT `V` | `A` (nameptr) | size | Dtor (`V-4`) | Ctor (observed) | Key virtuals / role |
|---|---|---|---|---|---|---|
| **TXMapGenerator** | `0x71c78c` | `0x71c760` | `c4` | `0x71d67c` | `0x71d2fc` | no user virtuals; map-generation orchestrator; seeds `+0x18/+0x1c`, owns 14 arrays |
| TXGlobalMapGenerator | `0x718b50` | `0x718b24` | `1b4` | `0x404564` | [U] | no user virtuals; global/strategic map generator |
| TXCastleGenerator | `0x72921c` | `0x7291f0` | `bc` | `0x72acf8` | [U] | no user virtuals; castle placement |
| **TXTerrainDataLite** | `0x59b6bc` | `0x59b690` | `28` | `0x59b724` | `0x59b6e8` | no user virtuals; compact terrain holder, 2 owned strings |
| TXTerrainData | `0x82da18` | `0x82d9ec` | `68` | `0x82ea30` | `0x82e1cc` | no user virtuals; full terrain data, 2 list fields |
| TXTerrainSet | `0x82d4cc` | `0x82d4a0` | `20` | `0x82e244` | [U] | no user virtuals; set wrapper |
| TXTerrainSetLibrary | `0x82d684` | `0x82d658` | `2c` | `0x82e50c` | [U] | standard list virtuals `0x42577c…` |
| **TXTileSmooth** | `0x72d6e8` | `0x72d6bc` | `c` | `0x404564` | `0x72d7f0` [U] block | no user virtuals; smoothing *configuration* record, not the algorithm |
| TXTileSmoothList | `0x72d754` | `0x72d728` | `20` | `0x72d958` | [U] | list virtuals; class override `0x72d91c` (candidate smoothing rule applier) |
| TXTileSeason | `0x5df23c` | `0x5df210` | `18` | `0x5df398` | [U] | no user virtuals; season/tile mapping record |
| TXTileBlock | `0x543bc0` | `0x543b94` | `3c` | `0x54424c` | [U] | no user virtuals; one atlas tile block |
| TXTileBlockLibrary | `0x543f04` | `0x543ed8` | `28` | `0x544364` | [U] | standard list virtuals |
| TXTileCoverItem | `0x72e358` | `0x72e32c` | `30` | `0x425a28` | [U] | collection-item virtuals; override `0x72fa68` |
| TXHeightTileZoneItem | `0x72e4f8` | `0x72e4cc` | `1c` | `0x72fd04` | [U] | override `0x72fc48`; height-zone rule item |
| TXAngleTileZoneItem | `0x72e724` | `0x72e6f8` | `38` | `0x425a28` | [U] | override `0x72fed4`; aspect-zone rule item |
| TXSeasonSet | `0x576a48` | `0x576a1c` | `88` | `0x576d74` | [U] | no user virtuals; season definition |
| TXSeasonSetLibrary | `0x576ba4` | `0x576b78` | `1c` | `0x576f28` | [U] | list virtuals incl. `0x576f64` |
| **TXPattern** | `0x754544` | `0x754518` | `90` | `0x754dd8` | `0x754cb0` | no user virtuals; `.pattern` record, defaults 3/4/2 + 1.0f |
| TXPatternObject | `0x75425c` | `0x754230` | `4c` | `0x404564` | [U] | no user virtuals; object entry in a pattern |
| TXPatternDecal | `0x7542d4` | `0x7542a8` | `60` | `0x404564` | [U] | no user virtuals; decal entry |
| TXPatternWater | `0x75436c` | `0x754340` | `1c` | `0x404564` | [U] | no user virtuals; water entry |
| TXPatternCollection | `0x7545d4` | `0x7545a8` | `2c` | `0x75d0b0` | [U] | no user virtuals; pattern set |
| TXPatternMask | `0x764bc4` | `0x764b98` | `e0` | `0x764d50` | [U] | scene object; overrides `0x764cc0`, `0x7650f0` |
| TXPatternFreq / Freqs | `0x577420` / `0x577498` | `0x5773f4` / `0x57746c` | `14`/`1c` | `0x404564` / `0x5777a4` | [U] | frequency weights; `0x57767c/0x5776c0/0x577754` |
| TXMap | `0x738a6c` | `0x738a40` | `90` | `0x7397f4` | [U] | no user virtuals; map container |
| TXWorld | `0x7d7108` | `0x7d70dc` | `6c` | `0x7d73c0` | `0x7d715c` | no user virtuals; world container |
| TXTopology | `0x7d9f8c` | `0x7d9f60` | `54` | `0x7daef0` | `0x7d9fc4` | no user virtuals; spatial topology / cell bounds |
| TXGameObjectsGrid | `0x7c03e0` | `0x7c03b4` | `64` | `0x7c04bc` | [U] | no user virtuals; object grid |
| TXCollisionMask | `0x849970` | `0x849944` | `20` | `0x84a028` | `0x849fcc` | no user virtuals; passability mask |
| TXCollisionInterface | `0x849a98` | `0x849a6c` | `50` | `0x84a448` | [U] | no user virtuals |
| TXTerrain | `0x80cb8c` | `0x80cb60` | `f0` | `0x80cf20` | [U] | scene object; overrides `0x80cd9c`, `0x80cf1c`, `0x810b70`, `0x875544` |
| TXHeightField | `0x8126ac` | `0x812680` | `1a4` | `0x812a54` | [U] | scene object; overrides `0x8127e0`, `0x817a50`, `0x81868c`, `0x8139a0`, `0x8179c4` |
| TXHeightFieldCacheInfo | `0x81243c` | `0x812410` | `1cc` | `0x81a978` | [U] | no user virtuals; cache bookkeeping |
| TXHeightFieldSector | `0x812528` | `0x8124fc` | `30` | `0x8187ac` | [U] | no user virtuals; sector record |
| TXHeightFieldFaceGroup | `0x8124c4` | `0x812498` | `10` | `0x81a8b0` | [U] | no user virtuals |
| TXTerrainBorders | `0x778304` | `0x7782d8` | `160` | `0x779318` | [U] | scene object; overrides `0x7792a4`, `0x77cc40` |
| TXCliffBlock | `0x84e308` | `0x84e2dc` | `10c` | `0x84f3b8` | [U] | scene object; overrides `0x84f3f0`, `0x84f2c4` |
| TXCliffProxy | `0x84e9e4` | `0x84e9b8` | `b0` | `0x4cf15c` | [U] | scene proxy; overrides `0x8512a4`, `0x851340` |
| **TXWaterManager** | `0x851a40` | `0x851a14` | `20` | `0x851f94` | `0x851f18` | no user virtuals; owns shader + uniforms |
| TXWaterField | `0x73a944` | `0x73a918` | `b0` | `0x73ac54` | [U] | scene object; overrides `0x73ab88`, `0x73b520`, `0x73ac90` |
| TXWaterProxy | `0x84eb18` | `0x84eaec` | `b8` | `0x4c980c` | [U] | scene proxy; overrides `0x851378`, `0x85199c`, `0x8519a0` |
| TXWaterUniforms | `0x853610` | `0x8535e4` | `80` | `0x404564` | [U] | no user virtuals; shader uniform block |
| TXWaterShader | `0x853768` | `0x85373c` | `240` | `0x856444` | [U] | shader class; overrides `0x855b30`, `0x85637c`, `0x856530`, `0x856e2c` |
| TXShadowMap | `0x81b028` | `0x81affc` | `1b0` | `0x81b858` | [U] | scene object; overrides `0x81b72c`, `0x81be68`, `0x81b97c` |
| TXWorldViewer | `0x7765a0` | `0x776574` | `dc` | `0x776820` | [U] | scene object; overrides `0x776788`, `0x7775d4`, `0x776850` |
| TXColorTable | `0x584678` | `0x58464c` | `68` | `0x585ac0` | [U] | no user virtuals; palette record |
| TXEditorBrush / TXStretchBrush / TXSelectionBrush / TXArrowBrush | `0x742ba4` / `0x791510` / `0x510f14` / `0x599c78` | see §2.2 extract | — | `0x742e64` / `0x792690` / `0x5110e8` / `0x59a2c4` | [U] | 43 scene-object virtuals each; editor brushes |

**Full raw extract** (all 64 classes, every virtual address): computed read-only into the temp
folder during this task; the table above is the cited digest. Every VMT byte block used is an
observed file read (E5–E9). File offsets for the five key VMTs:
`0x71c760→0x31bb60`, `0x59b690→0x19aa90`, `0x72d6bc→0x32cabc`,
`0x754518→0x353918`, `0x851a14→0x450e14`.

---

## 5. Implications for the port

1. **[D] The engine's generation pipeline is a plain object graph, not a virtual algorithm chain.**
   The key terrain classes are data-only (no user virtual overrides). `TXMapGenerator.Create`
   (`0x71d2fc`) is the orchestration root; it constructs `GlobalParams` (`FUN_0071cd00`),
   `TerrainParamsCollection` (`FUN_0072f7b8`), season/tile/cover configuration objects
   (`FUN_00731314`, `FUN_00731ae0`, `FUN_0072d91c`, `FUN_007308e0`) and sizes 14 dynamic arrays
   from `GlobalParams` fields. A faithful fresh module should be a **stage-ordered data pipeline**
   with named config objects, not a set of polymorphic "terrain effect" classes.
2. **[D] `TXTileSmooth` is a config record** (size `0xc`, generic destructor); the actual smoothing
   pass is more plausibly in `TXTileSmoothList` (override `0x72d91c`) and/or generator methods.
   D03 should not assume the smoothing algorithm lives in `TXTileSmooth` itself.
3. **[O] `TXPattern.Create` defaults are donor literals:** 3, 4, 2 (ints), five `1.0f` floats,
   and a boolean set. D01 does not claim which field means what; F01 should match these against
   `.pattern` header fields.
4. **[D] Water is a cluster** (`Manager` → `Uniforms` + `Shader`; `Field`/`Proxy` scene objects).
   D06 should model a manager that owns a shader/uniform block and heightfield-aware field
   objects, rather than a single "water class".
5. **[D] RTTI field names recovered from the class record** (`GlobalParams`,
   `TerrainParamsCollection`, `HillPoints`, `Project`, `TerrainLocalParamsCollection`,
   `HillPoints` at `0x71c8c0`) give the port a donor-grounded *data model vocabulary* without
   inventing constants. Use them as module/field names in the fresh `variant3d` module.
6. **[U] No visual parity.** Nothing here produces a donor GPU frame; all visual-stage claims stay
   **PORT APPROXIMATION** under Charter §4.

## 6. Risks

- **Decompiler coverage is partial.** DA_PE §4.3 already recorded 1,238 unresolved indirect jumps
  and a discovery cap; D01 hit the same limit (`function_not_found` for many VMT slots). Ghidra
  on-demand functions have `made_on_demand` bounds, so pseudo-C is an aid, not source.
- **Slot-name semantics are inferred** from Delphi convention plus observed pseudo-C; the binary
  has no symbols to confirm `SafeCallException` vs another slot by name.
- **Constructor anchoring is structural** (NewInstance prologue + ctor/dtor field symmetry), not a
  literal `mov [ecx],vmt` store; wrong-pair risk remains for classes with no extracted dtor body.
- **User virtual arrays stop at the first non-CODE dword**; a VMT followed by inline RTTI can hide
  later slots if a data word happens to look like code. Cross-check any new class with raw bytes.
- **Cross-target check is shallow:** `TXTerrainDataLite` was found in `editor.exe` (E29), but no
  full editor VMT map was built (timebox). Do not treat editor.exe addresses as equivalent.
- **Rizin/objdump engines are missing** in this session; the second-decoder cross-check requested
  by the owner could not be performed (logged in §2.3).

## 7. UNVERIFIED register (do not promote)

1. `TXTileSmooth.Create` semantics — **BLOCKED** after 5 passes (E27); entry bytes observed only.
2. Semantic names of the 8 generic VMT slots — [I] from Delphi convention, not symbol-proven.
3. Constructors for ~45 of the 64 listed classes — marked `[U]`; only VMT/dtor addresses are firm.
4. Roles of the long scene-object virtual arrays (`TXTerrain`, `TXHeightField`, `TXWaterField`,
   `TXPatternMask`, brushes) — addresses [O], meaning [U].
5. Exact mapping of `TXPattern` default fields (3/4/2, five 1.0f) to `.pattern` header fields.
6. Whether `+0x18/+0x1c = 0x7fffffff, sign` in `TXMapGenerator.Create` is the generation seed.
7. Whether `FUN_0072d91c` is the actual smoothing applier (class override observed, body not read).
8. `editor.exe` VMT correspondence — only one string cross-check performed.
9. **Donor visual parity — none.** Structural anchors only; no A/B frame.

## 8. Open questions / handoffs

- **D02:** inspect `TXMapGenerator.Create+0x18/+0x1c` (`FUN_00403a0c(0x7fffffff)`, `>>0x1f`)
  and its callees for `randkey1/2` semantics.
- **D03:** inspect `TXTileSmoothList` override `0x72d91c` and generator config objects
  `FUN_00731ae0` / `FUN_007308e0` for gauss/smooth chain order.
- **D04:** `TXTerrainData.Create` (`0x82e1cc`) creates two objects via `FUN_0089dd0c` at `+0x10/+0x14`;
  these are likely map-file path strings — verify against `.map` loader.
- **D05/F01:** match `TXPattern.Create` defaults and RTTI property names to `.pattern` layout.
- **D06:** follow `TXWaterManager.Create` → `FUN_00853390` (uniforms) → `FUN_0085637c`
  (shader) and `FUN_00855b10` for the water binding.
- **D08:** `TXTileBlock`/`TXTileBlockLibrary` and `TXColorTable` anchors are available for tile-id
  resolution; virtual arrays there are standard library methods.

## 9. Bottom line

The previously "unanchorable" RTTI names are anchored: the `X*` strings are **unit names inside
Delphi class-RTTI records**, while the real classes are `TX*` with **1,182 static VMTs** in `CODE`.
For the five requested targets the concrete anchors are `TXMapGenerator` (`0x71c78c`,
ctor `0x71d2fc`, dtor `0x71d67c`), `TXTerrainDataLite` (`0x59b6bc`, `0x59b6e8`, `0x59b724`),
`TXTileSmooth` (`0x72d6e8`, data-only, constructor BLOCKED), `TXPattern` (`0x754544`, `0x754cb0`,
`0x754dd8`) and the `XWater` cluster led by `TXWaterManager` (`0x851a40`, `0x851f18`, `0x851f94`).
Ctor/dtor field-pair decompilations verify the anchors. All anomalies were re-run and logged;
remaining ambiguity is marked `[U]`, and no donor parity is claimed.

*End of D01. One report written. No donor binary executed/copied; no source, shader, config,
asset, test, git or Godot-runner state changed.*


