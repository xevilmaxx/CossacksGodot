---
id: WATER-DEEP2
worker: WATER-DEEP2 (subagent, full 1:1 Cossacks 3 donor port)
date: 2026-11-27
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5768048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
labels: [O, D, I, U]
scope: "One file only. Read-only deep native decompilation. No code/Godot/git/donor-execution; no other edits."
upstream: "WATER_static_scalars.md (FUN_00851bdc @0x851bdc test eax,eax, 0 float literals/selector; U4* hard-fail)"
parity: UNVERIFIED
---

# WATER_deep2 — deep native decompile of the water render chain

## 0. Verdict (read first)

**No scalar is statically recoverable.** Every live water scalar (S1–S11 + W0/W1,
shader slots `C+0x88..+0xc4` / `C+0xb4` / `C+0xbc`) remains runtime `[U]`.

- The restored toolset confirms and deepens `WATER_static_scalars.md`: full
  instruction bytes, disassembly, Ghidra pseudo-C, xrefs, call graphs, string
  searches, and byte dumps all agree — the `FUN_00851bdc @0x851bdc`
  `test eax,eax` decision is on a **runtime layer pointer** returned by
  `sub_853530` via `sub_851c5c`. There are **0 float literals, 0 uniform-name
  strings, 0 static writers** recoverable for any live scalar.
- The `water_scalar_source UNSET [U4*]` hard-fail (no water drawn) is therefore
  **correct and must be kept**. No fallback is proposed, no value is wired, no
  constant is invented, no parity is claimed.
- Parity: **UNVERIFIED**. Chain: **0/6**. **RESULT IS NOT GOOD.**
- Exactly one file written: this report. No code, shader, asset, config,
  Godot, git, or donor-execution change.

## 1. Pin verification `[O]`

`core_target_open` on `C:\Games\Cossacks 3\cossacks.exe` returned:

- `target_id: t_87f0f3c130b0`, `kind: pe`, `bytes: 5768048`
- `sha256: 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`

Pin matches `t_87f0f3c130b0` / `87F0F3C130B0…AF4E16C`. Session Deep mode,
`clean_room: false`, builtin engine `0.6.1` + Ghidra `12.2` lifter for
pseudo-C. All reads below are static. Donor binaries were never executed.

## 2. Task 1 — full instruction list + disassembly + pointer flow `[D]`

### 2.1 `sub_851bdc @0x851bdc` — 17 insns, 48 bytes, 4 blocks `[D]`

- Instruction list: `ev_d1b30c0c8335f0ea78b6054d302a9aa77867b82ff32612736adff3681c122c4c` @ `0x851bdc`.
- Disassembly text: `ev_25b86263204c696cd250445a78be493e97013c36a69e187eb748204cbd9cabba` @ `0x851bdc`.
- Function facts: `ev_aa14b0582dbb1c36126a421142e9754eb2bf250dae267ef6291ac9028aebc8c4` — entry `0x851bdc`, end `0x851c0c`, size 48, 4 blocks, 17 insns, `calls_out: 3`, `callers: 2`.
- Ghidra pseudo-C: `ev_67a5083d1de168ff4483c44405a905f4d010e3f873fcb249547cac621a03c28b` @ `0x851bdc` → `FUN_00851bdc(int param_1,int param_2)`.
- Raw bytes (64 B): `ev_ca455aead09dd9e191aaee54cf619a38754ed6db4dc1849b0062f76931317b55` @ `0x851bdc`, file_offset 4526044, hex `538bd88bc289430c85c0740a8b5310e86c130000eb088b4310e8864400008bc3e8830600008b53108882300100005bc3…`.

Verbatim (bytes + disassembly agree):

```
0x851bdc  53                push ebx
0x851bdd  8bd8              mov ebx, eax
0x851bdf  8bc2              mov eax, edx
0x851be1  89430c            mov [ebx+0xc], eax        [D] ev_c6f6124e0270eecdc1711fc75f0d0e6b47cebb6ad2da03b4612a87600040ede7
0x851be4  85c0              test eax, eax             [D] ev_925505bc28915fd16cdc876f6faf8e10524096cc205cd957d1f2456f8bea6eb4
0x851be6  740a              je 0x851bf2
0x851be8  8b5310            mov edx, [ebx+0x10]
0x851beb  e86c130000        call 0x852f5c
0x851bf0  eb08              jmp 0x851bfa
0x851bf2  8b4310            mov eax, [ebx+0x10]
0x851bf5  e886440000        call 0x856080
0x851bfa  8bc3              mov eax, ebx
0x851bfc  e883060000        call 0x852284
0x851c01  8b5310            mov edx, [ebx+0x10]
0x851c04  888230010000      mov [edx+0x130], al       [D] ev_b4aecfa9f221340b1172f4b9fdd70e5e9401b4baba52eb5b382dd5ae2fefa3a5 (builtin attributes this site to sub_8519f4; §2.4)
0x851c0a  5b                pop ebx
0x851c0b  c3                ret
```

Ghidra pseudo-C verbatim (derived, not byte proof, but control flow matches):

```c
void FUN_00851bdc(int param_1,int param_2)
{
  undefined1 uVar1;
  *(int *)(param_1 + 0xc) = param_2;
  if (param_2 == 0) {
    FUN_00856080(*(undefined4 *)(param_1 + 0x10));
  }
  else {
    FUN_00852f5c(param_2,*(undefined4 *)(param_1 + 0x10));
  }
  uVar1 = FUN_00852284(param_1);
  *(undefined1 *)(*(int *)(param_1 + 0x10) + 0x130) = uVar1;
  return;
}
```

`[D]` consequences:

1. Zero float literals, zero `fld`/`movss`/`movsd`, zero string refs in all 17
   insns. The only decision is `test eax,eax` @ `0x851be4` (bytes `85c0`) on
   the caller-supplied layer pointer (`edx` on entry → `eax` → `[ebx+0xc]`).
   There is no selector constant; the selector IS the runtime pointer (0 vs
   nonzero).
2. Both arms delegate to callees (`0x852f5c` nonzero arm, `0x856080` zero arm).
   Nothing in `C+0x88..+0xc4` / `+0xb4` / `+0xbc` is materialised here.
3. Post-branch tail (`call 0x852284`, `mov [edx+0x130], al`) is a 1-byte
   status/flag write, not a scalar source.

### 2.2 `sub_851c5c @0x851c5c` — 13 insns, 28 bytes, 1 block `[D]`

- Instruction list: `ev_94528e304a31ee989b6cc844fc77857192523d468eeae44b61fac252d177e0e3` @ `0x851c5c`.
- Disassembly: `ev_14e8fda2dc703d00f300569b4712a105858331819ebdf71986afd9d05c123152` @ `0x851c5c`.
- Function facts: `ev_fdec257ab95bf5894e767f81938be6778f40b5eaf0e861a53faec446dc00a8eb` — 1 block, 13 insns, `calls_out: 2`, `callers: 4`.
- Pseudo-C: `ev_d9827a6436d95612c07479150f259bba41b0ae960b2e68cea2d2d3497203d679` @ `0x851c5c`.
- Raw bytes (64 B): `ev_e1b0bd06340bda8dc93813ca8ee67f0388013ebf165ee79c9a3c24bd7ea3d280` @ `0x851c5c`, file_offset 4526172, hex `53568bf28bd88bd68b4308e8c41800008bd08bc3e867ffffff5e5bc3…`.

```
0x851c5c  53                push ebx
0x851c5d  56                push esi
0x851c5e  8bf2              mov esi, edx
0x851c60  8bd8              mov ebx, eax
0x851c62  8bd6              mov edx, esi
0x851c64  8b4308            mov eax, [ebx+8]
0x851c67  e8c4180000        call 0x853530   [D] ev_319f3ffc6a76cd18bf7c918b3c945370e31418e0aabd30bb19cc10710559ea0e (flow call→0x853530)
0x851c6c  8bd0              mov edx, eax     ; layer ptr = RETURN VALUE of sub_853530
0x851c6e  8bc3              mov eax, ebx
0x851c70  e867ffffff        call 0x851bdc
0x851c75  5e                pop esi
0x851c76  5b                pop ebx
0x851c77  c3                ret
```

Pseudo-C: `uVar1 = FUN_00853530(*(param_1+8), param_2); FUN_00851bdc(param_1, uVar1);`

`[D]` The pointer tested @ `0x851be4` is the **runtime return value** of
`sub_853530` (args: `[ebx+8]`, incoming `edx`). No constant is pushed, no
literal pool referenced. `[U]` Its value (0 vs layer address) depends on
runtime parse/lookup state and cannot be folded statically.

### 2.3 `sub_853530 @0x853530` — 20 insns, 39 bytes, 4 blocks `[D]`

- Instruction list: `ev_f0235ae198b9b3bb979840389f2e5138a177f99a6c725d7dc7e760df9b035b46` @ `0x853530`.
- Disassembly: `ev_cb7dbb8e46d7239916854a516e94850d886e3e784175202db11c0db3598a49ee` @ `0x853530`.
- Function facts: `ev_8b9658b211ec7f88d7c5834e6f01e66ae2fc33acbb74c227d440ec8f5bc694ba` — 4 blocks, 20 insns, `calls_out: 2`, `callers: 1`.
- Pseudo-C: `ev_5e588030f4a5875ffe2076114e4fd322d1fc2448b34ff5303deeda00531f4f64` @ `0x853530`.
- Raw bytes (64 B): `ev_0b8cae426509aef9e3d932e85e49b3d64242c53339b01e2c741fc5c3f07623b0` @ `0x853530`, file_offset 4532528, hex `53568bf28bd885f67c188bc3e883ffffff3bf07d0d8bd68b4304e8e1a904005e5bc333c05e5bc3…`.

```
0x853530  53                push ebx
0x853531  56                push esi
0x853532  8bf2              mov esi, edx          ; index param
0x853534  8bd8              mov ebx, eax
0x853536  85f6              test esi, esi         [D] ev_232eb7fd66d07b8ce7b71c26121dfca30d9cdfd05ef29a51c3bef52ab66b0bda (bytes 85f6)
0x853538  7c18              jl 0x853552
0x85353a  8bc3              mov eax, ebx
0x85353c  e883ffffff        call 0x8534c4        ; count = FUN_008534c4(param_1)
0x853541  3bf0              cmp esi, eax
0x853543  7d0d              jge 0x853552
0x853545  8bd6              mov edx, esi
0x853547  8b4304            mov eax, [ebx+4]
0x85354a  e8e1a90400        call 0x89df30        [D] ev_b6a4493c9333e650740d892891c1d5328a1a3bbdadb5b24dba74404dcbddc3a3 (generic indexer, 318 static callers; §2.5)
0x85354f  5e / 5b / c3      pop esi / pop ebx / ret (return uVar2 = layer ptr)
0x853552  33c0              xor eax, eax          ; out-of-range / negative → NULL
0x853554  5e / 5b / c3      pop esi / pop ebx / ret
```

Pseudo-C:

```c
undefined4 FUN_00853530(int param_1,int param_2)
{
  int iVar1; undefined4 uVar2;
  if (-1 < param_2) {
    iVar1 = FUN_008534c4(param_1);
    if (param_2 < iVar1) {
      uVar2 = FUN_0089df30(*(undefined4 *)(param_1 + 4),param_2);
      return uVar2;
    }
  }
  return 0;
}
```

`[D]` This is a **bounds-checked indexed lookup**: negative index → NULL;
`index >= count` → NULL; else `sub_89df30(base+4, index)`. The NULL-vs-layer
outcome is a runtime function of (index, count, table contents). No static
scalar, no float, no uniform slot is written here.

### 2.4 Function-boundary discrepancy (honest record) `[O]/[D]`

- `native_function_find(0x851bfc)` → `ev_1d9a0cf9e6e0321cca1500d06ee6c3575f85f9d7bd62c9f5c0a17e567b3a70c3`: `0x851bfc` is inside `sub_8519f4 (+0x208)`, entry `0x8519f4`.
- `native_instruction_show(0x851c04)` attributes `mov [edx+0x130], al` to `sub_8519f4` (`ev_b4aecfa9f221340…`), and `native_xrefs_list(0x852284)` attributes its sole caller site `0x851bfc` to `sub_8519f4` (`ev_01576b9c24fb8bf524e374cda8d1c14ce81f198cbf85f1c84581d600804c4e7e`).
- That is: the **builtin linear engine** treats `0x851bdc..0x851c0b` as interior
  of the larger `sub_8519f4`, while **Ghidra** lifts it as standalone
  `FUN_00851bdc` (pseudo-C `ev_67a5…`). `[D]` Both engines agree on the bytes
  and control flow; only the function-boundary label differs. No scalar fact
  depends on which label is used. Cited so a reviewer is not misled by the
  `sub_8519f4` vs `sub_851bdc` naming in evidence rows.

### 2.5 Callee fan-out `[D]`

- `native_xrefs_list(0x852f5c)` → `ev_ae4ccb1b25a1de04c280dc4b372e7cfb67983aa0b3887ba26748d438427e990b`: exactly 1 static caller, `0x851beb` in `sub_851bdc` (nonzero arm). No other static writer/caller.
- `native_xrefs_list(0x856080)` → `ev_e72bebe046bf945cabbef5121016d589a7331b7ddadba54fbee225e1a0c2cd6c`: exactly 1 static caller, `0x851bf5` in `sub_851bdc` (zero arm).
- `native_xrefs_list(0x8534c4)` → `ev_fed81f2144d102fb0c700a3baf2f302e81b5d4a0ca197a25fbb32590c20b6401`: exactly 1 static caller, `0x85353c` in `sub_853530` (count query).
- `native_xrefs_list(0x89df30)` → `ev_6f41dd09bc214ecf9685a870172cf778e924ee1180b96d452e17b9d8f117b136`: 318 static callers (partial page, 200 shown), i.e. a **generic shared indexer**, not a water-specific scalar source. Its water behaviour is fully determined by the runtime `(base, index)` args above.
- `native_xrefs_list(0x852284)` → `ev_01576b9c24fb8bf524e374cda8d1c14ce81f198cbf85f1c84581d600804c4e7e`: 1 static caller site `0x851bfc` (labelled under `sub_8519f4` per §2.4; same bytes as §2.1 tail).

## 3. Task 2 — static writers of `C+0x88..+0xc4` / `+0xb4` / `+0xbc` `[D]/[U]`

These tokens are **struct displacements**, not virtual addresses, so they cannot
be passed to `native_xrefs_list` as addresses. The reachable byte-proven
statement is instead:

- Full instruction lists of `sub_851bdc`, `sub_851c5c`, `sub_853530`
  (`ev_d1b3…`, `ev_9452…`, `ev_f023…`) contain **no** `mov [reg+0x88]…[reg+0xc4]`,
  **no** `[reg+0xb4]`, **no** `[reg+0xbc]`, **no** `movss/movsd/fld`, **no**
  float immediate. The only data writes are `[ebx+0xc]` (pointer store),
  `[edx+0x130]` (1-byte flag), plus register moves. `[D]`
- Hence **no static writer of any live water uniform slot is reachable from
  the proven water render chain**. Any writer lives inside the undiscovered
  callees `0x852f5c` / `0x856080` (FILE whole-block copy vs ENGINE ctor, per
  re-cited records) or further downstream uniform-upload code, none of which
  exposes a static per-scalar constant through this chain. All slot bindings
  stay `[U]` pending owner GPU capture.

## 4. Task 3 — call-graph map around `0x851bdc` `[D]`

- Forward from `0x851bdc`: `ev_b1ee77cbbc33a85ada9f175170417462b6d265cdd0138584dedc77a1a93b4fb3` — **0 functions/imports reached**. `[D]` This is an engine limitation note (`direct_calls_only`; the three direct `call` targets proven in §2.1 are statically resolved in the listing but not followed by the graph builder — possibly because of the §2.4 boundary overlap). It does NOT mean `sub_851bdc` is a leaf: `call 0x852f5c` @ `0x851beb`, `call 0x856080` @ `0x851bf5`, `call 0x852284` @ `0x851bfc` are byte-proven in `ev_d1b3…`/`ev_25b8…`.
- Backward to `0x851bdc`: `ev_a69655fdb92d500ae8da403e05a6f9557ae94b7694deb18cc9f0b3fda6a5e3e5` — 20 functions within 6 levels. Level 1 (direct callers): `sub_8519f4` @ `0x851c48`, `sub_851c5c` @ `0x851c70`. Level 2 (callers of `sub_851c5c`): `sub_603c0c` @ `0x603c2b`, `sub_7130a0` @ `0x713672`, `sub_852068` @ `0x852083`, `sub_85208c` @ `0x852097`. Levels 3–6 continue through `sub_712fb4`, `sub_73a0b8`, `sub_739c74`, `sub_7532ac`, `sub_851fec`, then `sub_710e88`, `sub_7148c0`, `sub_715e80`, `sub_739b6c`, `sub_715ed0`, `sub_74dc30`, `sub_750ac0`, then `sub_7160b8`, then `sub_7102ac`.
- Direct xrefs confirm the level-1 edges: `native_xrefs_list(0x851bdc)` → `ev_2d03b7a67cdd169271df29a75920e2e718efaa515813ff1fdd9c94d661826792` (2 call sites: `0x851c48`, `0x851c70`); `native_xrefs_list(0x851c5c)` → `ev_0baef992f0c4379956c96b3a554f6d6ed73341598f02f97ac3576d53ad01111d` (4 call sites); `native_xrefs_list(0x853530)` → `ev_4ae5470df88c1d0100f5007b0c03410c03f26dd88e2af21334f4a2b918fbf806` (1 call site: `0x851c67` in `sub_851c5c`).
- `[D]/[U]` The chain is fully mapped statically **as a call shape**, but no
  edge carries a static scalar: every level passes opaque object pointers /
  indices downward; the only value that matters (layer pointer) is created at
  runtime inside `sub_853530`. A deeper backward walk cannot manufacture a
  constant that the three deep-dive functions prove absent.

## 5. Task 4 — water shader/uniform strings + float-literal check `[D]`

`native_strings_find` (literal, case-insensitive), each with its own evidence:

| Query | Result | Evidence |
|---|---|---|
| `reflectionAmount` | 0 matches | `ev_b32cff1d703c242cf9a4825872f6a36ad6ef519c983d22c92027bd766d8d95c6` |
| `texScaleS` | 0 matches | `ev_071c791dd1e7706927cd4921e174c81c9a16a85ca39b0e0cec41e40bb8724d3b` |
| `WaterShaderVP` | 0 matches | `ev_a901238a8bcf83bf99334139a6dcb1fb5685a5d00b6d53e0a8821e9c54890b34` |
| `water.lib` | 0 matches | `ev_00922bc1836cc151b59d8257199e1c5b65dbe361210d7b07b4a4f9dbae7dc0ab` |
| `hmapTex` | 0 matches | `ev_4961eb9f5f4502561377894a5d4e50b2e2d4cf78f8d082de149ea5f5b84e0baf` |
| `water` (broad) | 3 matches, all in `.rsrc`, zero code refs: `$XWaterShader` @ `0x958c10`, `fXWaterField` @ `0x95937b`, `XWater` @ `0x95938a` | `ev_6dae3ae13da997184b928905f94f4cd6fa3ea5a06af08532ae016ae033dc759f` |
| `Water` feature | 3 strings (same trio), 0 functions, 0 imports, 0 functions involved | `ev_32bfd5c1ec63161db8e47308c10fb45213f962c8f98020155be8959943b015` |
| `0x958c10` xrefs | 0 references to / 0 from (resource-only string, no code site) | `ev_ba571a74d35eea04cb7989498ab355f0cbd3e1d5db7d29efe48874d19c758861` |

`[D]` With the full static surface, **no scalar name, uniform name,
descriptor string, or `water.lib` path resolves to a code site**, so there is
nothing to check "for a static float literal nearby" — the anchor itself is
absent from code. The broad `water` hits are resource-section labels with no
xrefs, not uniform hooks. (Prior tickets found uniform/shader text only via
Deep/Ghidra + packed-byte scans out of scope here; those stay re-cited, not
re-proven.) Consequently **no static float literal is bound to any live water
scalar this ticket**.

## 6. Task 5 — bytes around candidate VAs `[D]`

- `native_bytes_show(0x851bdc, 64)` → `ev_ca455aead09dd9e191aaee54cf619a38754ed6db4dc1849b0062f76931317b55` (file_offset 4526044).
- `native_bytes_show(0x851c5c, 64)` → `ev_e1b0bd06340bda8dc93813ca8ee67f0388013ebf165ee79c9a3c24bd7ea3d280` (file_offset 4526172).
- `native_bytes_show(0x853530, 64)` → `ev_0b8cae426509aef9e3d932e85e49b3d64242c53339b01e2c741fc5c3f07623b0` (file_offset 4532528).
- `[D]` The dumps byte-match the instruction lists in §2 (e.g. `53 8bd8 8bc2
  89430c 85c0 740a …` at `0x851bdc`; `53 56 8bf2 8bd8 85f6 7c18 …` at
  `0x853530`). No embedded `float32` scalar pool is visible adjacent to any of
  the three entries; the bytes decode cleanly as the integer/pointer code
  listed above.

## 7. Per-scalar verdict table — all live bindings `[U]`

`Static` = byte-proven static datum (re-verified or re-cited). `Live` = value
actually bound at draw. Only `Live` matters to the hard-fail.

| # | Scalar (slot) | Static datum | Live verdict |
|---|---|---|---|
| S1 | reflectionAmount (`C+0x88`) | FILE `1` candidate (donor text, per static report); ENGINE `0.4` re-cited | `[U]` — needs U4*-CORE capture |
| S2 | waterAmount (`C+0x8c`) | FILE `1` / ENGINE `0.3` | `[U]` — same capture |
| S3 | fresnelPower (`C+0x90`) | FILE `1` / ENGINE `4.0` | `[U]` — same capture |
| S4 | fresnelBias (`C+0x94`) | FILE `1` / ENGINE `0.1` | `[U]` — same capture |
| S5 | hdrMultiplier (`C+0x98`) | FILE `1` / ENGINE `0.5` | `[U]` — same capture |
| S6 | waveFreq (`C+0x9c`) | FILE `0` / ENGINE `1.0` | `[U]` — same capture |
| S7 | waveAmp (`C+0xa0`) | FILE `0` / ENGINE `0.05` | `[U]` — same capture |
| S8 | distFactor (`C+0xa4`) | FILE `1` / ENGINE `2.0` | `[U]` — same capture |
| S9 | bumpFactor (`C+0xa8`) | FILE `1` / ENGINE `0.01` | `[U]` — same capture |
| S10 | texScaleS (`C+0xac`) | FILE `0.1` / ENGINE `0.4` | `[U]` — needs U4*-S10/S11 capture |
| S11 | texScaleT (`C+0xb0`) | FILE `0.01` / ENGINE `0.825` | `[U]` — needs U4*-S10/S11 capture |
| W0 | waveDir0 (`C+0xb4`) | FILE `(-1,0)` / ENGINE unenumerated | `[U]` — needs U4*-W0/W1; null-guard, no invention |
| W1 | waveDir1 (`C+0xbc`) | FILE `(-0.7,0.7)` / ENGINE unenumerated | `[U]` — needs U4*-W0/W1; same guard |
| SP | Speed (`C+0xc4`) | `1.0` both arms (re-cited converge) | `[D]` path-insensitive — not in UNSET gate |
| C1/C2 | Deep/Shallow colours | both arms converge (re-cited) | `[D]` path-insensitive — not in UNSET gate |

`[D]`-as-candidate means the FILE number exists in the donor but its liveness
is unproven. Presenting any FILE number as the live uniform without the U4*
capture would be fabrication. This ticket adds **zero** new static bindings
and removes none of the `[U]` marks.

## 8. Why static binding is impossible here (not just absent) `[D]/[I]`

1. Branch condition is a runtime data value (return of bounds-checked lookup
   `sub_853530`), not a constant, version flag, or config key. No static pass
   can fold it (§2.2–§2.3).
2. Both arms are atomic whole-block writers (re-cited FILE-copy vs ENGINE-ctor
   records); no per-scalar static path exists even if one arm were preferred.
3. ENGINE waveDir slots are unenumerated — "assume ENGINE" still cannot
   complete the tuple without inventing two vectors. Invention is forbidden.
4. The full string surface (§5) offers no uniform hook to hang a static
   literal on, and the full instruction surface (§2) offers no literal to hang.

## 9. Required port behaviour (no change)

1. Keep `_water_scalar_source = UNSET`, `build()` refusal
   (`water_scalar_source UNSET [U4*] … no water drawn`), and the ENGINE-dir
   null-guard. Do NOT default to FILE or ENGINE.
2. Keep `BUILTIN_TEX_SCALE_S/T = 0.01/0.02` labelled EMBEDDED-SOURCE-DEFAULT,
   never as live uniforms.
3. Owner-only runtime capture (standing rule, forbidden to workers): break
   `FUN_00851bdc @0x851bdc`, record layer ptr, dump `C+0x88..+0xc4` +
   `C+0xb4/+0xbc`, hook `glUniform1f/2f`; 0-ULP / 0-mismatch over 2 frames +
   camera move (U4* packet). Nothing in this report substitutes for it.

## 10. Non-claims and discipline

- No parity claim. No donor execution, no GPU capture, no port comparison.
- No approximation substituted; no scalar guessed or defaulted.
- Read-only compliance: one repo file written (this report). No
  code/shader/asset/config/Godot/git change. No donor file written or
  executed.
- Ghidra pseudo-C rows are marked derived; everything else cited `[D]` carries
  an `ev_…` id + address above. Prior Deep records are re-cited with explicit
  provenance; gaps are marked not recovered, not reinvented.

*End WATER_deep2. Parity UNVERIFIED, chain 0/6, RESULT IS NOT GOOD.*
