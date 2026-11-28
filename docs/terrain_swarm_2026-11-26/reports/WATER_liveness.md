# WATER_liveness — FILE vs ENGINE scalar liveness (READ-ONLY decomp)

Scope: worker WATER-LIVE, full 1:1 Cossacks 3 donor port. READ-ONLY decompilation of
`C:\Games\Cossacks 3\cossacks.exe`. No donor execution. No Godot/code change.
Parity: UNVERIFIED. No value is wired. No constant is invented. No parity claimed.
Chain: 0/6. RESULT IS NOT GOOD.

Donor identity [D]:
- Active/open target at time of water-string and gate work: `t_87f0f3c130b0`,
  `C:\Games\Cossacks 3\cossacks.exe`, 5768048 bytes, kind `pe`,
  sha256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`
  (pin prefix `87f0f3c1` verified).
- NOTE [D]: the session also has `editor.exe` open (`t_68474ddde43f`). One early
  `native_bytes_find` batch without an explicit `document` hit `editor.exe`; all
  WATER_liveness claims below use only results whose `subject.sha256` is the
  cossacks.exe hash above and/or explicit `document: "t_87f0f3c130b0"`.

FILE ground truth [D] (plaintext read, not donor execution):
- `C:\Games\Cossacks 3\data\water\water.lib`, 2063 bytes, 71 lines, UTF-8,
  sha256 `88b3cdc6ba3770b23d620f013c518084214968e9db6f4e8e505de6e4095e17c`
  (`core_text_read`, ev_6fcb07113a5beb30f...).
- Active tuple: `Name=default`, `MaxDepth=1`, `MinDepth=0`, `MaxAlpha=1.1`,
  `MinAlpha=0`, `DeepColor=(0,0,0.1255,0.5)`, `ShallowColor=(0,0,0,0.5)`,
  `ReflectionAmount=1`, `WaterAmount=1`, `FresnelPower=1`, `FresnelBias=1`,
  `HDRMultiplier=1`, `WaveFreq=0`, `WaveAmp=0`, `DistFactor=1`, `BumpFactor=1`,
  `TexScaleS=0.1`, `TexScaleT=0.01`, `WaveDir0=(-1,0)`, `WaveDir1=(-0.7,0.7)`,
  `Speed=1.0`, `Offset=0.495`, `LayerCount=1`, `CustomEnable=False`,
  `CustomReflection=False`, `HeightMapEnable=True`, `ShadowMapEnable=True`,
  plus `NormalMapLibMaterialName=DiffuseWaves2`,
  `DiffuseMapLibMaterialName=DiffuseWaves0`, `Width=1`, `Height=1`,
  `MaterialLibraryFileName=.\data\water\water.mat`,
  `VertexProgramFileName=.\data\shaders\water\water.dev.vert`,
  `FragmentProgramFileName=.\data\shaders\water\water.dev.frag`, `Tag=512`,
  `DefaultWaterIndex=0`.
- Commented-out FILE alternatives [D]: `//TexScaleS = 0.115`,
  `//TexScaleT = 0.015` (not 0.01). Prior brief text saying
  `//TexScaleS=0.115 commented` is confirmed for S; T commented value is 0.015.

## 1. Generic `.lib` parser / config loader — NOT FOUND in `cossacks.exe` [D-negative]

Byte-proven absences (clean-room `native_strings_find`, data-sections only;
absence is not proof of absence at runtime, but it is proof that no such
literal is stored in the file):

- `ReflectionAmount`: 0 matches (ev_b5caf94d177aca88...).
- `Fresnel`, `MaxDepth`, `MinDepth`, `MaxAlpha`, `MinAlpha`, `DeepColor`,
  `ShallowColor`, `TexScale`, `WaveDir`, `WaveFreq`, `WaveAmp`, `HeightMap`,
  `CustomReflection`, `WaterAmount`, `HDRMultiplier`, `DistFactor`,
  `BumpFactor`: all 0 matches each on `cossacks.exe`.
- `water` / `Water` / `WATER`: exactly 3 matches, all in `.rsrc`, all with
  `references: []` (ev_6dae3ae13da997184...):
  `0x958c10 "$XWaterShader"`, `0x95937b "fXWaterField"`, `0x95938a "XWater"`.
  `core_feature_find("water")` confirms: 3 strings, 0 function names,
  0 imports, 0 functions involved (ev_77319dd1b0892e16...).
- `.lib` (and `.LIB`): 0 matches (ev_50e6a89c4bfca2e...).
- `data\water`, `water.lib`, `water\`: 0 matches (ev_ddaca8a6eb85fa93...).
- `section.begin`, `struct.begin`: 0 matches each on cossacks.exe
  (ev_77d0fbda12ddaef..., ev_50ec03926728189...).
- `.vert`: 0 matches (ev_1c9ddbdcb1ab534...). `water.mat`: 0 matches
  (ev_b7e66cf713552bd...).
- `fopen`: 0 matches. `CreateFileW`: 1 match in `.idata` at `0x908a00`
  (ev_7cc069a881d42539...), but `native_xrefs_list(0x908a00)` reports
  `total_to: 0`, `references_from: []`, `references_to: []`
  (ev_469f519ecc1aef47...). I.e. the import slot exists but no static
  reference edge is recovered; no file-open-plus-parse caller chain to any
  water function is proven.
- `.mat` only appears as editor `.rsrc` filter text
  `"Plain text files (*.mat)|*.mat"` (5 hits, all `.rsrc`); on the cossacks.exe
  target the `water.mat` literal itself is absent (see above).

Therefore [D]: no generic `.lib` parser entry point, no `water.lib` pathname,
no FILE key name, no `section.begin`/`struct.begin` grammar token, and no
`.vert`/`.frag`/`water.mat` path literal is byte-present in `cossacks.exe`.
[U]: whether the parser lives in another binary (e.g. editor), is reached via
computed-pointer/call indirection invisible to static xrefs, or builds names at
runtime (encrypted/composed strings, resource-loaded text) is UNPROVEN. No
FILE-to-struct population path is proven. Do NOT treat the `CreateFileW`
import slot as a water loader.

## 2. Trace backward from `0x851bdc`: the tested layer pointer

Prior wording "`0x851bdc` gate / return of `sub_853530`" is imprecise against
bytes. Byte-proven topology [D]:

- `0x851bdc` is the ENTRY of `sub_851bdc`, not an interior gate
  (`native_function_find`, ev_712828488c58...). 17-instruction builtin
  disassembly (ev_25b86263204c696c...):
  `push ebx; mov ebx,eax; mov eax,edx; mov [ebx+0xc],eax; test eax,eax;
  je 0x851bf2; mov edx,[ebx+0x10]; call 0x852f5c; jmp 0x851bfa;
  mov eax,[ebx+0x10]; call 0x856080; mov eax,ebx; call 0x852284;
  mov [edx+0x130],al; pop ebx; ret`.
- Ghidra pseudocode concurs (`FUN_00851bdc`, ev_67a5083d1de168f...):
  `*(param_1+0xc)=param_2; if(param_2==0) FUN_00856080(...); else FUN_00852f5c(...);
  *( *(param_1+0x10)+0x130)=FUN_00852284(param_1)`.
  So the FILE-vs-ENGINE null-test is `test eax,eax` at `0x851be4` INSIDE
  `sub_851bdc`: `param_2==0 → 0x856080` (ENGINE-default writer),
  `param_2!=0 → 0x852f5c` (bulk field copier). The gate condition itself is
  byte-proven; what `param_2` MEANS is not.
- `sub_851bdc` does NOT call `sub_853530` (`native_function_callees_list`,
  ev_ffd69b50f3083a...: callees are only `0x852f5c`, `0x852284`, `0x856080`).
- The `sub_853530` return feeds `sub_851bdc` one level up, in `sub_851c5c`
  (13 instructions, ev_14e8fda2dc703d...):
  `mov edx,esi; mov eax,[ebx+8]; call 0x853530; mov edx,eax; mov eax,ebx;
  call 0x851bdc`.
  Ghidra: `uVar1=FUN_00853530(*(param_1+8),param_2); FUN_00851bdc(param_1,uVar1)`
  (ev_d9827a6436d95612c...). There is NO null-test in `sub_851c5c` itself; the
  possibly-null pointer is passed straight through.
- `sub_853530` is the ONLY caller-indexed accessor (20 instructions,
  ev_cb7dbb8e46d723...; pseudocode ev_5e588030f4a...):
  `if(param_2<0) return 0; i=FUN_008534c4(param_1); if(param_2>=i) return 0;
  return FUN_0089df30(*(param_1+4),param_2)`.
  Callees: `0x8534c4` + `sub_89df30` (ev_3e3756843587c...).
  `FUN_008534c4` returns `*(*(param_1+4)+0xc)` = count
  (ev_387c40d344a08...). `FUN_00889df30` returns
  `*(*(param_1+8)+index*4)` = element pointer (ev_b3536526dd3...).
  So `sub_853530` is a generic bounds-checked container getter returning 0 on
  out-of-range. Its ONLY direct caller is `sub_851c5c` at `0x851c67`
  (`native_function_callers_list`, ev_add91eb6c...; `address_taken: 0`
  caveat: indirect callers would not be listed).
- `sub_851bdc` has exactly 2 direct callers: `sub_8519f4` at `0x851c48` and
  `sub_851c5c` at `0x851c70` (ev_72c4d19b94dac...). `sub_851c5c` has exactly 4
  direct callers: `sub_603c0c` at `0x603c2b`, `sub_7130a0` at `0x713672`,
  `sub_852068` at `0x852083`, `sub_85208c` at `0x852097`
  (ev_06da56bcc0c8417...; same indirect-caller caveat).
- Index provenance (where the `param_2` index into `sub_853530` comes from) [D]:
  - `FUN_00852068`: `if(param_2!=0){ uStack=param_3;
    (** (param_2+0xc))(param_2,&uStack,4); FUN_00851c5c(param_1,uStack); }`
    (ev_987e253d2024f...). Index comes from a VIRTUAL call result.
  - `FUN_0085208c`: `FUN_00851c5c(param_1,*(*(param_1+8)+0x10)); *(param_1+0x1c)=0xffffffff`
    (ev_b14e90f97c...). Index is field `+0x10` of the inner object.
  - `FUN_00603c0c`: `i=FUN_00705944(); if(*(i+0x4c)!=0){
    FUN_00851c5c(*(*(*(i+0x4c)+0x5c)+0x28), stack) }` (ev_b294972...; Ghidra
    made-on-demand bounds, less exact).
  - The `sub_8519f4→0x851c48→sub_851bdc` edge could not be lifted reliably:
    builtin disassembly of `sub_8519f4` is 201 instructions of mostly
    `add [eax],al`-style mis-decode/garbage with 7 gotos and 26 inline-asm
    gaps (ev_856276abca5c..., ev_d41c427e5217c...); NO water-scalar conclusion
    may be drawn from it.

Therefore [D]: the tested pointer is `sub_853530(container=*(obj+8), index)`
where container count is `*(*(container_outer+4)+0xc)` and elements are
`*(*(container_outer+4)+8)[index]`; null means out-of-range (or negative
index) and selects the ENGINE-default writer `0x856080`; non-null selects the
bulk copier `0x852f5c`. [U]: whether that container is EVER populated from
`water.lib` (file handle → parse → struct fill → element pointer) is UNPROVEN.
No store path from any file read into `*(param+4)`/`+8`/`+0xc` was found. No
water-key string, pathname, or grammar token ties the container to the FILE.
Could-point-to-FILE remains a hypothesis, not a byte fact. GPU/file trace
required.

## 3. Float literals matching `water.lib` values — ENGINE defaults only, no FILE tie

Ghidra `FUN_00856080` (the `param_2==0` branch target, ev_5aaec0315458ec...)
writes a full hardcoded constant block [D-derived, Deep engine]. Raw bytes at
`0x856080` (256 B, ev_74d0132ff4d5088..., file_offset 4543616) contain the
same immediates, e.g. `CD CC CC 3D` (`0.1f`), `9A 99 99 3E`, `00 00 80 40`,
`CD CC 4C 3D`, `00 00 C0 3F`, `CD CC 4C 3F`, confirming this is real CODE bytes
and not a decompiler artifact. The sibling initializer `sub_852c68`
(builtin lifter pseudocode, ev_4c1f49d1b4b6dc...) writes the IDENTICAL block:
`esi+0x38=0x3ecccccd; +0x3c=0x3e99999a; +0x40=0x40800000; +0x44=0x3dcccccd;
+0x48=0x3f000000; +0x4c=0x3f800000; +0x50=0x3d4ccccd; +0x54=0x40000000;
+0x58=0x3ca3d70a; +0x5c=0x3ecccccd; +0x60=0x3f4ccccd; ...` plus
`+0x74/+0x80/+0x84=0x3f800000` etc.

Decoded ENGINE block (standard IEEE-754, same values in both functions) —
names are positional only, NOT a claim they are the FILE fields:
`0x3f800000=1.0`, `0x00000000=0.0`, `0x3ecccccd≈0.4`, `0x3e99999a≈0.3`,
`0x40800000=4.0`, `0x3dcccccd=0.1`, `0x3f000000=0.5`, `0x3d4ccccd≈0.05`,
`0x40000000=2.0`, `0x3ca3d70a≈0.02`, `0x3f4ccccd≈0.8`, `0x42480000=50.0`,
`0x3ff00000` (high half of a `1.0` double at `+0x154`), `0x00000de1`,
`Tex0:=Tex1*Tex0;\r\nTex1:=Tex0+Col;` shader-combiner string.

`native_bytes_find` on `cossacks.exe` [D]:
- `1.1f` (`CD CC 8C 3F`): 7 hits total — `0x582312`, `0x58231c`, `0x59f078`,
  `0x59f096`, `0x73e878`, `0x7e7f8e`, `0x7e7fa9`. NONE is in the `0x85xxxx`
  water cluster; the one resolved (`0x7e7f8e`) is inside `sub_7e7a34+0x55a`
  (ev_5b1633f27ff219...); the others are in undiscovered-code regions
  (`function: null`, same ev family). No `1.1f` immediate is tied to
  `sub_851bdc`/`sub_851c5c`/`sub_852f5c`/`FUN_00856080`/`sub_852c68`.
  So FILE `MaxAlpha=1.1` has NO byte-proven ENGINE counterpart in the water
  path; the ENGINE block has `1.0` where FILE has `1.1`.
- `0.1f` (`CD CC CC 3D`): 53 hits total. The water-cluster hits are
  `0x852d14` (inside `sub_852c68+0xac`, ev_31f68089c8...) and `0x856106`
  (`0x856080+0x86`, inside the `FUN_00856080` byte range though the builtin
  engine reports `function: null`, ev_c79b27ca...). `native_bytes_show` at
  `0x856106` (ev_92b080a96e96...) shows `cd cc cc 3d ...` in situ, and at
  `0x856080` (ev_74d0132f...) shows the surrounding `C783...` mov-immediate
  sequence. `native_instruction_show` on these mid-operand addresses
  mis-decodes as `int 0xcc` (ev_1c0ee9e430ca..., ev_cb554a8812c...) — expected:
  the hit is inside a `mov [reg+off],0x3dcccccd` immediate, proven by the
  bytes dump + Ghidra immediate list, not by the builtin linear decode.
- `0.01f` (`0A D7 23 3C`): 14 hits total
  (`0x591d03`, `0x62040f/4d/80`, `0x73da54`, `0x742d98`, `0x764cf3`,
  `0x80baf6`, `0x82ba30/4c`, `0x83c6b7/0b`, `0x83d15c/78`). NONE is in the
  water cluster; FILE `TexScaleT=0.01` has no tied water-path immediate; the
  ENGINE block instead carries `0x3ca3d70a≈0.02` at the corresponding slot.
- FILE `DeepColor.Blue=0.1255`, `Offset=0.495`, `TexScaleS commented 0.115`:
  no exact-immediate search is claimed here (no verified hex asserted); what
  IS byte-proven is the negative: none of the FILE key strings exist to anchor
  any such literal, the ENGINE block contains no `1.1`, and the two
  `0.1f` water-cluster hits belong to the ENGINE-default initializers above,
  not to a FILE-load path.

Therefore [D]: the only byte-proven water-adjacent floats are ENGINE DEFAULTS
(`0.1`, `≈0.02`, `≈0.05`, `0.3`, `0.4`, `0.5`, `0.8`, `1.0`, `2.0`, `4.0`,
`50.0`, ...), written unconditionally by the null-branch (`FUN_00856080`) and
by `sub_852c68`. [U]: whether any `water.lib` scalar (`1.1`, `0.1255`,
`0.495`, `0.01`, `-1`/`-0.7`/`0.7`, `Speed=1.0`) ever reaches the
`0x852f5c` copy sink or the `+0x130`-flagged object is UNPROVEN. If a FILE
fallback exists, its immediates/addresses were not found; if `0.1` is a FILE
value, its water-cluster occurrences are currently explained as ENGINE
defaults, not loads. GPU/uniform trace required.

## 4. FILE-vs-ENGINE choice: runtime null-test, NOT a proven config flag / build constant / data-driven file select

- [D] The choice is implemented as a RUNTIME pointer null-test:
  `test eax,eax @0x851be4` in `sub_851bdc` → `je→0x856080` (ENGINE-default
  writer) vs `call 0x852f5c` (bulk copier from the layer pointer). Followed by
  `call 0x852284` (`FUN_00852284`: returns 0 iff `*(param_1+4)` is 0/1, else 1;
  ev_822678350c614...) whose result is stored to `*( *(param_1+0x10)+0x130)`.
- [D] `FUN_00856080` takes the dead-branch object pointer and overwrites it
  with the hardcoded block plus `Tex0:=Tex1*Tex0; Tex1:=Tex0+Col;`; it reads
  no file, no registry, no config (pseudocode shows only immediates and
  `FUN_004a21e8/004a211c/008590d4/00853ad4/00405454` helpers).
  `FUN_00852f5c` is a pure field-for-field copier (`param_1+8..0xcc` →
  `param_2+0x58..0x180` etc., ev_513eeafe38634...); it contains no literal
  floats, no pathname, no key compare.
- [D] No runtime config flag, no build-constant `#ifdef`, and no
  data-driven file-select is proven: no flag byte, no `water.lib` path, no key
  string, and no `.lib`-grammar token is stored in the binary (see §1); the
  index into the layer container comes from a virtual-call result
  (`FUN_00852068`), an object field (`FUN_0085208c: +0x10`), or an opaque
  stack slot (`FUN_00603c0c`), none with file provenance.
- [U]: what WRITES the container (`*(obj+8)` / count / elements), whether
  `LayerCount=1` / `DefaultWaterIndex=0` / `Tag=512` from the FILE ever size or
  select it, and whether the null case means "no FILE", "bad index",
  "uninitialized", or "engine override" is UNPROVEN. The U4* gate (the
  `test eax,eax @0x851be4`, fed transitively by `sub_853530` via
  `sub_851c5c`) stays CLOSED: FILE liveness is not demonstrated. A runtime
  file-open trace + GPU uniform capture is the only path to open it.

## Verdict

- FILE scalars are CANDIDATES ONLY (plaintext FILE read is [D]; any ENGINE use
  is [U]).
- ENGINE scalars are BYTE-PROVEN DEFAULTS ([D] via `FUN_00856080` immediates +
  `0x856080`/`0x856106` bytes dumps + `sub_852c68` identical block).
- `0x851bdc`/`sub_853530`/`sub_851c5c` topology above is [D]; every
  FILE-population edge is [U].
- No `.lib` loader, no `water.lib` reference, no FILE-key reference, no
  FILE-float use in the water path is proven in `cossacks.exe` [D-negative].
- Parity UNVERIFIED. Do not wire any FILE value. Chain 0/6. RESULT IS NOT GOOD.

Methods (all read-only, no donor execution): `core_target_open` (pre-open
`cossacks.exe` verified by hash/pin), `core_text_read` (water.lib),
`native_strings_find` (all key/path/grammar/import literals),
`core_feature_find("water")`, `native_function_find`,
`native_function_disassemble` (`sub_851bdc`, `sub_851c5c`, `sub_853530`),
`native_function_pseudocode` (Ghidra Deep: `FUN_00851bdc/00851c5c/00853530/
008534c4/00889df30/00852068/0085208c/00603c0c/00852f5c/00856080/00852284`;
builtin lifter: `sub_8519f4` (garbage — not used), `sub_852c68`),
`native_function_callers/callees_list`, `native_xrefs_list`,
`native_instruction_show`, `native_bytes_find` (`1.1f`/`0.1f`/`0.01f`),
`native_bytes_show` (`0x856080`, `0x856106`).
