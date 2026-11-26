---
id: X21
wave: Verification / RNG vectors (terrain swarm 2026-11-26)
title: "X21 — Independent verification of D02's donor RandomExt LCG + numeric test vectors for I07"
date: 2026-11-26
status: DELIVERED__READ_ONLY__NO_REPO_SOURCE_EDITS__NO_GODOT_JOB
owner_file: "reports/X21_rng_vectors.md (the ONLY repo file written)"
labels: [O, D, I, U, "PORT APPROXIMATION"]
donor_root: "C:\\Games\\Cossacks 3 (read-only; never executed, never copied into repo)"
target: "t_87f0f3c130b0 = cossacks.exe, sha256 87f0f3c130b0…; every call pinned with document:"
cross_target: "t_68474ddde43f = editor.exe, sha256 68474ddde43f… (byte-signature cross-check only)"
prototype_root: "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\rng_verify\\ (outside repo)"
visual_parity_claim: false
---

# X21 — Independent RNG re-read and I07 test vectors

## 0. Scope and evidence discipline

Read first, as instructed: `CHARTER.md`, `SWARM_BOARD.md`,
`spec/02_SEED_AND_RNG.md`, `reports/D02_seed_rng.md`.

Labels: **[O]** observed donor bytes/lines; **[D]** derived arithmetic/structure;
**[I]** inferred reading with caveat; **[U]** UNVERIFIED; **PORT APPROXIMATION**
= a suggested port implementation, explicitly *not* a donor-parity claim.
No donor visual/behavioural parity claim is made anywhere in this report:
no donor binary was run and no donor GPU A/B frame exists.

Donor was accessed read-only through Craft Anything. No donor executable was
run, no donor binary copied, no repo source/asset/config/test/git edit, no Godot
runner job. The Python prototype and JSON vectors live only under the temp path
in the frontmatter. Script-level facts (`donewgame.inc`, `dogenerate.inc`,
`generatemap.inc`) are inherited from D02/X03 as **prior [O]**, not re-read by X21;
all binary claims below are X21's own fresh reads.

---

## 1. Executive summary

1. **[O]/[D] D02's core formula is confirmed independently.** Re-reading the native
   `RandomExt` at `cossacks.exe` VA `0x60f64c`–`0x60f696` (five passes, §3) yields
   exactly `s ← (s × 0xFC0D + 0x3C6EF35F) mod 2^32` and
   `RandomExt = f32(s / 4294967296.0)`. The divisor f32 at `0x60f698` reads
   `4294967296.0` (bits `0x4F800000`, LE `00 00 80 4f`).
2. **[D] Correction 1 — `key0` does not affect *any* draw, including the first.**
   D02 §4.2 says the high key word "only affects the first output (via the 64×64
   product cross term)". The raw multiply helper (`0x406718`, `ev_5141e382…`)
   puts that cross term in **EDX (the product's high word)**, which the modulo
   helper (`0x4067b8`, `ev_83bff802…`) discards when reducing mod `2^32`. The
   state update and the subsequent `fild qword` see only the low word. Therefore
   `(key0, key1)` and `(0, key1)` generate identical streams (verified in §5.2).
   D02's own worked example `(0x44A108F9, 0) → 0x3C6EF35F` already implies this.
3. **[D] Correction 2 — D02's published worked-example decimals are the *unrounded
   double* quotient, not the donor's float32 return.** E.g. `s=0x3C6FEF6C` gives
   double `0.236082996` but the donor's `fstp dword [esp]` at `0x60f68e` returns
   `0.236083001`. I07 must use the float32 values in §5.1, not D02's decimals.
   D02's own Risks §6 already warned about this; the example itself did not apply it.
4. **[D] `s = 0` does not stick at the constant.** Draw #1 moves it to the increment
   `0x3C6EF35F`, then the stream continues normally; there is **no fixed point**
   because `gcd(0xFC0D−1, 2^32) = 4` but the increment is odd. Assumption that no
   zero-state guard exists is **[D]** from the absence of any state test in the
   raw function; equivalence to a live donor run is **[U]** (§4.4).
5. **[D] 20 exact vectors** for a fixed key pair, with float32 bit patterns and
   `floor(RandomExt*n)` wrappers, are in §5.1 and in
   `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\rng_verify\test_vectors.json`.
   Word-order cases and the zero-state case are in §5.2–5.3.
6. **[D]/PORT APPROXIMATION** §6 gives Godot-compatible pseudocode with exact
   32-bit masking (`Godot int` is signed 64-bit; `s*64525 < 2^47`, so no overflow,
   only the final `& 0xFFFFFFFF` is required) and a stage-keyed draw ledger for
   the three independent streams.
7. **[U]** `GenerateMapRandKey`, saved-map key-byte mapping, live replay equivalence,
   DScript's numeric promotion for `floor(RandomExt*n)`, and one signed first-draw
   edge case for arbitrary nonzero `key0` remain open (§9).

---

## 2. Evidence table

All ids below are X21's own fresh Craft Anything reads unless marked "prior".

| Evidence id / source | Label | Observation / supports |
|---|---|---|
| `ev_3dfbf17f1bd9757f8dc35812a1b4b8dc2568d6ed0dbd306975d5ce43cdefe173` (re-read; prior id from D02) | [O] pseudo / [D] reading | Deep/Ghidra pseudo-C of `FUN_0060f64c`: `uVar1 = FUN_00406718(0xfc0d,0,param_3,DAT_009048d4,DAT_009048d8)`; state stores `FUN_004067b8(uVar1+0x3c6ef35f, extraout_EDX + (uint)(0xc3910ca0 < uVar1))`. Ghidra's carry spelling `0xc3910ca0 < uVar1` is exactly `uVar1 ≥ 0xC3910CA1`, i.e. the `adc edx,0` carry; not a bug. |
| `ev_df1b1b6cc87da6fce2db7d13846a84c64092c4b38d95fcd529e8332236758b45`, `ev_f491998c0d14bf35d6258117faafd109062f3532094473c2178a354036ce364a` | [O] pseudo | Mid-function decompiles at `0x60f682` and `0x60f688` resolve to the same truncated `FUN_0060f64c` body — x87 tail consistently omitted by the lifter. |
| `ev_5dd2579de5094aacdcc8221b360898de561317754cfa133331b5a49317d1963e` | [O] raw bytes | 80 bytes at VA `0x60f64c` (file `0x20ea4c`), complete function plus trailing f32; full instruction sequence recovered (§4.1). |
| `ev_ee039a9f72dedd8063e23c67e83fb2e129a080226256ca0546b58981749d8f6b` | [O] instruction | `0x60f682: fild qword [0x9048d4]` — reads the 64-bit state (`lo` at `0x9048d4`, `hi` at `0x9048d8`). |
| `ev_33572f0de0b278dea77e74ce1bd11c934f4f778f56fd70341ced096563c83216` | [O] instruction | `0x60f688: fdiv dword [0x60f698]`, bytes `d8 35 98 f6 60 00`. |
| `ev_2ec034e77576239d4d67e1d61b27e59051d347ab797922bc8e72ed4e0f31e098`, `ev_aca7888e080487e5e83f1857a9636adb365a25fc6e4f55b3742ba523e8efb38a`, `ev_bdc4a4a446e9efdec96902a1c6102164c48e248b89b85c7416681acf519431f7` | [O] instruction | Tail: `0x60f68e fstp dword [esp]`, `0x60f691 fwait`, `0x60f692 fld dword [esp]`, `0x60f696 ret`. The `fwait` was omitted in D02's listing; it is not a state update. |
| `ev_6283059d19b38fbd59adb0a1fbeb300f26eeeb1dc96462ece3dbe4ce6b508a4c` (re-read), `ev_3232e6171a2bba4e01501696fce822735e229d3a706ec27015d50a342d7ee4b0` | [O] data | `native_data_show 0x60f698` → `f32 = 4294967296.0`; as `u32` → `1333788672 = 0x4F800000`. |
| `ev_bcb1b777cd7545b5d68c97e97081b0e1c26f22ff863e76976d1de292cfdde83d`, `ev_5141e382386c64a10e40c0d673643b0241f8a3308bc43b1647474facb657e5d1`, `ev_88d333eba2f1a589a2b36e302d5800c8424d5f6433dde69caa48b926fc2ff567` | [O]/[D] helper | `sub_406718` is 35 bytes, 14 instructions, `ret 8`; computes `edx:eax = 0xFC0D × state64 mod 2^64`, consuming the two pushed state words. |
| `ev_4acca04d40bc718b039d3fd4a5dc23276830c04cdf144d1065146fd11841a839`, `ev_3a0750468bc50890f0438b32d7f43af333102c59e63aec48c11b71d4cd3f0306`, `ev_83bff8022557cd10b19818cfd9da634a80dddc4e0fb71ad745d05c5424a13a6a`, `ev_88f083196786e7ec91348db451fafeceaa9b2223bc40bb3a9e4948e2945128b1`, `ev_045cb3e09c6393f50f1445bb461eceb8063ed2e84708c7de408ec858e46efa8a` | [O]/[D] helper | `sub_4067b8` is 122 bytes / 59 instructions, `ret 8`; 64÷64 long division, `ebx = [esp+0x14]`, `ecx = [esp+0x18]`. With divisor words `0` (low), `1` (high) it reduces mod `2^32` and returns the remainder in `edx:eax`, `edx = 0` for a positive remainder. |
| `ev_76e5c73d6f7910cde7c8b0c5e5dea686bbdc74c4287d04868bef06203e8cbd42`, `ev_24d4c8460919e9a1a3ef5caff4581ab82b07f17bd056d615f546874b27f14719` | [O] pseudo | Deep/Ghidra pseudo-C of both helpers agrees on multiply and modulo (register-level detail only). |
| `ev_54ac1f0cd93329ff090586d3c5791ac5f1bb7af238286c57551db8acb57b8b45` | [O] bytes | Signature `b8 0d fc 00 00 33 d2 e8` occurs **5×** in `cossacks.exe`: VA `0x60f65d`, `0x7281ca`, `0x72d2d1`, `0x809657`, `0x8096a1` — five LCG instances. |
| `ev_7332cb8d8898d6e2e9da37f0b949242bd3d6e2b011190adc7ecc8c40fb6dc986` | [O] bytes | Same signature occurs **6×** in `editor.exe` (e.g. VA `0x8913be`, `0x883700`) — independent cross-target confirmation. |
| `ev_f028f596c2a3c0f372f6fb2872fd6875e61b1a04fdec45e91a0f67455af66f82`, `ev_918848a6a5474caf8eddf057388a701e1d45270b1b2b039fcaaf6a66f2fc1200`, `ev_6b383bd4ca1b34fc2a8bd391938b08b5087789c7e23eab29d8616207c7f49fe8` | [O] pseudo | `SetRandomExtKey64` (`0x60f6dc`) → `FUN_008484ac(k0,k1)` storing lo/hi; `GetRandomKey` (`0x60f69c`) → `DAT_009048d4`; `SetRandomKey` (`0x60f6a4`) → `lo=k`, `hi=k>>31` (sign extension). |
| D02 ids `ev_14126307…`, `ev_00a36e27…`, `ev_b305f68f…`, `ev_c06572cb…` (prior, not re-read) | [O] prior | Script-level three setters, stage reseeds, fixed discarded draws — inherited, see D02 §4.4/§4.6 and X03. |

---

## 3. Method — multiple passes on the garbled x87 tail

Owner directive (CHARTER §4): do not skip an anomalous decompile after one
attempt. Applied here; **every pass is recorded**, including failures.

| # | Instrument (all pinned `document: t_87f0f3c130b0`) | Result |
|---:|---|---|
| 1 | `native_function_pseudocode("0x60f64c")` | Ghidra 12.2 pseudo-C recovered the state update but **omitted the x87 output tail**; carry shown as `(uint)(0xc3910ca0 < uVar1)`. Accepted as partial: equivalent to `uVar1 ≥ 0xC3910CA1`. |
| 2 | `native_function_disassemble("0x60f64c")`, `native_function_instructions_list`, `native_function_study` | All three **rejected: `function_not_found`** — the built-in engine has no function record at this VA (Ghidra created one on demand). Recorded, not treated as evidence of absence. |
| 3 | `native_function_pseudocode("0x60f682")`, `("0x60f688")` | Both resolved to the *same* truncated `FUN_0060f64c` body → the truncation is systematic, not an address-alignment fluke. |
| 4 | `native_bytes_show("0x60f64c", 80)` + `native_instruction_show` at `0x60f682/688/68d/691/692/696` | **Decisive pass.** Full bytes recovered; `fild` (`:682`), `fdiv` (`:688`), `fstp dword [esp]` (`:68e`), `fwait` (`:691`), `fld dword [esp]` (`:692`), `ret` (`:696`). One probe at `0x60f68d` mis-decoded a mid-instruction byte (`add cl, bl`) — a cursor-alignment artefact, discarded in favour of the instruction-boundary reads. |
| 5 | `native_data_show("0x60f698", f32)` and `(u32)` | `4294967296.0` / `0x4F800000` — divisor confirmed independently of the lifter. |
| 6 | Helper passes: `native_bytes_show`, `native_function_disassemble`, `native_function_instructions_list`, `native_function_show`, `native_function_pseudocode` at `0x406718` and `0x4067b8` | `ret 8` in both; divisor stack slots proved from `ebx=[esp+0x14]`, `ecx=[esp+0x18]`; the initial "mod by old state" reading is a stack-depth error (D02 Anomaly C independently reproduced and resolved). |
| 7 | `native_objdump_run(disassemble)` | **Rejected: `engine_missing`** (no objdump installed). No second disassembler was available; raw bytes + built-in decoder were accepted instead. |
| 8 | `native_bytes_find` signature scan in `cossacks.exe` and `editor.exe`, all pinned | 5 and 6 instances respectively — cross-check that the constants are not a one-off artefact. |

**Final reading accepted:** passes 4–6 (raw bytes + built-in instruction decoder +
helper disassembly), with pass 1 treated as a correct-but-incomplete register-level
view. Nothing was silently skipped.

---

## 4. Formula confirmation

### 4.1 Observed instruction sequence — [O]

`cossacks.exe` CODE VA `0x60f64c`–`0x60f696` (file `0x20ea4c`–`0x20ea96`),
reconstructed from `ev_5dd2579d…` and the instruction reads:

```
0x60f64c  51              push ecx                       ; scratch slot for f32 return
0x60f64d  6a 01           push 1                         ; divisor high word
0x60f64f  6a 00           push 0                         ; divisor low  word
0x60f651  ff 35 d8 48 90 00  push dword [0x9048d8]        ; state hi (key0)
0x60f657  ff 35 d4 48 90 00  push dword [0x9048d4]        ; state lo (key1)
0x60f65d  b8 0d fc 00 00  mov eax, 0x0000fc0d             ; M = 64525
0x60f662  33 d2           xor edx, edx
0x60f664  e8 af 70 df ff  call 0x406718                   ; edx:eax = M*state64 mod 2^64
0x60f669  05 5f f3 6e 3c  add eax, 0x3c6ef35f             ; + C = 1013904223
0x60f66e  83 d2 00        adc edx, 0                      ; carry from add eax,C
0x60f671  e8 42 71 df ff  call 0x4067b8                   ; remainder mod 2^32 -> edx:eax
0x60f676  89 05 d4 48 90 00  mov [0x9048d4], eax          ; new state lo
0x60f67c  89 15 d8 48 90 00  mov [0x9048d8], edx          ; new state hi
0x60f682  df 2d d4 48 90 00  fild qword [0x9048d4]         ; signed 64-bit state -> x87
0x60f688  d8 35 98 f6 60 00  fdiv dword [0x60f698]         ; / 4294967296.0
0x60f68e  d9 1c 24        fstp dword [esp]                ; *** f32 rounding ***
0x60f691  9b              fwait
0x60f692  d9 04 24        fld dword [esp]                 ; return float32 in ST(0)
0x60f695  5a              pop edx
0x60f696  c3              ret
```

### 4.2 Derivation — [D]

Both helpers return with `ret 8`, which removes exactly the two pushed state
words. The two words still on the stack at entry to `0x4067b8` are therefore
`0` (low) and `1` (high), i.e. divisor `CONCAT44(1,0) = 2^32` — **not** the old
state. With `state64 = (hi<<32)|lo`:

```
prod64   = (M * state64) mod 2^64          ; low 64 bits from 0x406718
dividend = prod64 + C  (with carry)         ; add/adc in RandomExt
lo'      = dividend mod 2^32                ; 0x4067b8
hi'      = 0                                ; remainder high word for normal seeds
RandomExt = f32( int64(lo' + (hi'<<32)) / 4294967296.0 )
```

Since `lo' ≡ M·lo + C (mod 2^32)`, the portable state recurrence is

```
s ← (s × 64525 + 1013904223) & 0xFFFFFFFF
RandomExt = float32(s / 4294967296.0) ∈ [0, 1)
```

`M = 64525 ≡ 1 (mod 4)` and `C` is odd ⇒ full `2^32` period (Hull–Dobell).
No statistical-quality claim is made.

### 4.3 `key0` is discarded — [D], correction to D02

`0x406718`'s cross term `low(M×hi)` is added into **EDX**, the product's *high*
word (`ev_5141e382…`: `mov ecx,eax` … `add edx,ecx`). Reducing mod `2^32`
discards it. Consequently the state sequence depends only on `key1`, and `hi'`
returned by the modulo helper is the remainder's high word (0 for a positive
remainder, `ev_83bff802…` at `0x406810`–`0x406812`). The `fild` therefore reads
the same value as the u32 model. Table §5.2 confirms `(K0, K1)` ≡ `(0, K1)`.
**Caveat [U]:** see §8 item 3 for the sign-bit edge case with arbitrary nonzero
`key0`.

### 4.4 `s = 0` — [D] arithmetic, [U] live equivalence

- Draw #1: `s₁ = (0×M + C) mod 2^32 = C = 0x3C6EF35F` → `f32(C/2^32) = 0.236067966`.
  It does **not** stick at the constant. First five states:
  `3C6EF35F, 85A2D332, 4D98E4E9, AE87EF34, E8CD4903`.
- Fixed point test: `s = (sM + C) mod 2^32` ⇒ `s(M−1) ≡ −C (mod 2^32)`.
  `gcd(64524, 2^32) = 4`, while `C = 0x3C6EF35F` is odd ⇒ `4 ∤ C` ⇒ **no fixed
  point exists**. Every state, including zero, enters the full-period cycle.
- Assumption "no special zero-state guard": **[D]** from the raw function — there
  is no `test`/`jz` on `DAT_009048d4/d8` anywhere in `0x60f64c`–`0x60f696`;
  the only zero branch is the modulo helper's divide-by-zero fast path
  (`ev_83bff802…`, `0x4067ca`), which is mathematical, not a state guard.
- Assumption "identical to a live donor replay": **[U]** — donor execution is
  prohibited by the charter.

### 4.5 Float32 rounding — [D]

`fdiv` is performed in x87 extended precision on an exact integer ≤ 2^32−1 and
the exact f32 constant 2^32; `fstp dword` is the only rounding step. Dividing a
32-bit integer by 2^32 is also exact in binary64, so a Python/Godot model may
compute `float(s)/4294967296.0` and then round once to float32 without
double-rounding error. D02's worked-example decimals were the unrounded
`double` values:

| state | D02 decimal (double) | donor return (f32) | delta |
|---|---:|---:|---:|
| `0x3C6FEF6C` | 0.236082996 | **0.236083001** | +4.90e−9 |
| `0x7DCC6BDB` | 0.491400472 | **0.491400480** | +8.05e−9 |
| `0xD9FC017E` | 0.851501554 | **0.851501524** | −3.02e−8 |
| `0x5FB30EC5` | 0.373825954 | **0.373825967** | +1.34e−8 |
| `0x5B109F60` | 0.355722390 | **0.355722398** | +7.91e−9 |

The *integer states* in D02 §4.2 are correct and were reproduced exactly.

---

## 5. Test vectors for I07

Prototype: `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\rng_verify\rng_model.py`
(Python 3, `struct` round-to-nearest-even). Machine-readable output:
`...\rng_verify\test_vectors.json`.

**Fixed key pair [I — synthetic test input, not a claimed donor seed]:**
`key0 = 0x44A108F9` (a donor-observed word from `bonmis1.map:0x18c0f1`, D02 §4.4,
used here only as a convenient high word), `key1 = 0x00000001` (synthetic low word
so the first state is `M+C` and hand-checkable).

### 5.1 Twenty draws — [D]

`floor` columns use the donor script wrapper `GetRandom(n) = floor(RandomExt*n)`
(`dogenerate.inc:990-997`, D02 prior [O]) with the **f32** value promoted to
double before multiplication. Columns `bits LE` are the IEEE-754 binary32 bytes
of `RandomExt` in little-endian order — the strongest I07 comparison key.
`f32-product` variants of all four floors were also computed: **no differences**
occurred in these 20 vectors, but see §8 item 2.

| # | s (hex) | s (dec) | RandomExt (f32, %.9g) | bits LE | floor(r×3) | floor(r×5) | floor(r×10) | floor(r×256) |
|---:|---|---:|---:|---|---:|---:|---:|---:|
| 1 | 0x3C6FEF6C | 1013968748 | 0.236083001 | bebf713e | 0 | 1 | 2 | 60 |
| 2 | 0x7DCC6BDB | 2110548955 | 0.491400480 | d898fb3e | 1 | 2 | 4 | 125 |
| 3 | 0xD9FC017E | 3657171326 | 0.851501524 | 01fc593f | 2 | 4 | 8 | 217 |
| 4 | 0x5FB30EC5 | 1605570245 | 0.373825967 | 1e66bf3e | 1 | 1 | 3 | 95 |
| 5 | 0x5B109F60 | 1527816032 | 0.355722398 | 3f21b63e | 1 | 1 | 3 | 91 |
| 6 | 0x39298B3F | 959023935 | 0.223290160 | 2da6643e | 0 | 1 | 2 | 57 |
| 7 | 0x089D0992 | 144509330 | 0.0336461999 | 99d0093d | 0 | 0 | 0 | 8 |
| 8 | 0x41D427C9 | 1104422857 | 0.257143497 | 50a8833e | 0 | 1 | 2 | 65 |
| 9 | 0x6B5ED494 | 1801376916 | 0.419415742 | a9bdd63e | 1 | 2 | 4 | 107 |
| 10 | 0x09816EE3 | 159477475 | 0.0371312425 | ee16183d | 0 | 0 | 0 | 9 |
| 11 | 0x212908E6 | 556337382 | 0.129532397 | 24a4043e | 0 | 0 | 1 | 33 |
| 12 | 0x5046CF0D | 1346817805 | 0.313580453 | 9e8da03e | 0 | 1 | 3 | 80 |
| 13 | 0x03D84308 | 64504584 | 0.015018644 | c210763c | 0 | 0 | 0 | 3 |
| 14 | 0x50663AC7 | 1348876999 | 0.314059913 | 76cca03e | 0 | 1 | 3 | 80 |
| 15 | 0xF37BD37A | 4084978554 | 0.951108158 | d37b733f | 2 | 4 | 9 | 243 |
| 16 | 0x7DE4C891 | 2112145553 | 0.491772205 | 91c9fb3e | 1 | 2 | 4 | 125 |
| 17 | 0xD67BDEBC | 3598442172 | 0.837827623 | df7b563f | 2 | 4 | 8 | 214 |
| 18 | 0x0FFA52EB | 268063467 | 0.062413391 | 2fa57f3d | 0 | 0 | 0 | 15 |
| 19 | 0x75C47D4E | 1975811406 | 0.460029453 | fb88eb3e | 1 | 2 | 4 | 117 |
| 20 | 0xA2C21855 | 2730629205 | 0.635774136 | 18c2223f | 1 | 3 | 6 | 162 |

The JSON also carries, per row, exact decimal repr, both floor variants, and
the metadata (`M`, `C`, divisor bits, labels).

### 5.2 Word-order cases — [D]

| Case | key0 (high) | key1 (low) | first 3 states | first 3 RandomExt (f32) |
|---|---|---|---|---|
| fixed pair | 0x44A108F9 | 0x00000001 | 3C6FEF6C, 7DCC6BDB, D9FC017E | 0.236083001, 0.491400480, 0.851501524 |
| key0 zeroed | 0x00000000 | 0x00000001 | 3C6FEF6C, 7DCC6BDB, D9FC017E | identical — **key0 is discarded** |
| swapped pair | 0x00000001 | 0x44A108F9 | 3D718404, 19269793, 809959D6 | 0.240013361, 0.0982451215, 0.502339959 |
| key1 zeroed | 0x44A108F9 | 0x00000000 | 3C6EF35F, 85A2D332, 4D98E4E9 | 0.236067966, 0.522015750, 0.303114235 |

This is the decisive I07 word-order check: **only the low word seeds the
sequence**; `GetRandomKey` (`0x60f69c`) correctly returns that low word.

### 5.3 Zero-state case — [D]

`s = 0` → first states `3C6EF35F, 85A2D332, 4D98E4E9, AE87EF34, E8CD4903`;
`sticks_at_constant = false`; `fixed_point_exists = false` (§4.4).

### 5.4 Cross-check of D02's worked examples — [D]

`(0, 1)` first five states and `(0x44A108F9, 0)` first state reproduced exactly;
only the printed decimals differ (§4.5). This is a Python-model cross-check,
**not** a donor run.

---

## 6. GDScript-compatible pseudocode — PORT APPROXIMATION

Godot 4 `int` is signed 64-bit. With `s < 2^32` and `M = 64525`,
`s*M + C < 2^47`, so there is **no 64-bit overflow**; masking once at the end
is sufficient and exact. Godot `float` is binary64, so the donor's `fstp dword`
must be emulated with a `Float32Array` round-trip.

```gdscript
# PORT APPROXIMATION — donor-grounded arithmetic, not a parity claim.
const RNG_M: int = 64525          # 0xFC0D
const RNG_C: int = 1013904223     # 0x3C6EF35F
const U32: int = 0xFFFFFFFF
const DIV_2P32: float = 4294967296.0

func _f32(x: float) -> float:
    # Exact IEEE-754 binary32 round-to-nearest-even (matches x87 fstp dword).
    var a := Float32Array()
    a.append(x)
    return a[0]

class DonorLCG:
    var s: int = 0                 # 32-bit state held in a signed-64 int
    var stream_name: String = ""

    func _init(key0: int, key1: int, name: String) -> void:
        # SetRandomExtKey64: key0 = high, key1 = low (0x60f6dc).
        # Only key1 survives the mod 2^32 (X21 §4.3); keep key0 for the ledger.
        s = key1 & U32
        stream_name = name

    func reseed_ext_key(key0: int, key1: int) -> void:
        s = key1 & U32             # SetRandomExtKey64 / generatemap.inc:216,513,774

    func reseed_key(key: int) -> void:
        # DScript SetRandomKey at 0x60f6a4 sign-extends to the high word;
        # the low word is what the recurrence consumes.
        s = key & U32

    func next_state() -> int:
        # Godot int is 64-bit: product < 2^47, so mask is the only wrap needed.
        s = (s * RNG_M + RNG_C) & U32
        return s

    func random_ext() -> float:
        var v: int = next_state()
        return _f32(float(v) / DIV_2P32)      # f32, not bare double

    func get_random(n: int) -> int:
        return int(floor(random_ext() * float(n)))

    func get_random_range(lo: int, hi: int) -> int:
        return lo + int(floor(random_ext() * float(hi - lo + 1)))
```

### 6.1 Three independent streams

```gdscript
# donewgame.inc:33-35 calls all three setters back-to-back => distinct owners.
var rng_dscript  := DonorLCG.new(k0, k1, "dscript_global")      # 0x9048d4/d8
var rng_mapgen   := DonorLCG.new(k0, k1, "map_generator")       # sub_7281bc, this+0x18
var rng_worldgen := DonorLCG.new(k0, k1, "global_map_generator")# third instance
var delphi_seed: int = 0   # SEPARATE LCG: seed = seed*0x08088405+1; output seed*2^-32
```

`sub_7281bc` and the `0x809657/0x8096a1` instances share the constants
(`ev_54ac1f0c…`); their class identities are **[I]/[U]** (D02 U3). The Delphi
`Random()` stream is a different recurrence and is not reseeded by the above
setters.

### 6.2 Stage-keyed ledger — PORT APPROXIMATION

A stage is identified by `(stage_id, generator_version, stream_name)`; the
ledger key must include the version because donor version gates change draw
counts. Each stage boundary re-seeds and resets the draw counter; draws are
recorded in call order, including discarded draws.

```gdscript
var ledger: Dictionary = {}       # key -> {k0,k1,stream,draws:[{i,s,r,n,gr}]}

func stage_begin(stage_id: String, ver: int, k0: int, k1: int, st: DonorLCG) -> void:
    st.reseed_key(k1)              # donor: SetRandomKey(randkey1) at each boundary
    ledger[_ledger_key(stage_id, ver, st)] = {
        "k0": k0, "k1": k1, "stream": st.stream_name, "draws": []
    }

func _ledger_key(stage_id: String, ver: int, st: DonorLCG) -> String:
    return "%s|v%d|%s" % [stage_id, ver, st.stream_name]

func draw(stage_id: String, ver: int, st: DonorLCG, n: int = 0) -> float:
    var r: float = st.random_ext()
    var d: Dictionary = ledger[_ledger_key(stage_id, ver, st)]
    var i: int = d["draws"].size()
    d["draws"].append({
        "i": i, "s": st.s, "r": r,
        "n": n, "gr": (int(floor(r * float(n))) if n > 0 else -1)
    })
    return r

func discard(stage_id: String, ver: int, st: DonorLCG, count: int) -> void:
    for _i in range(count):
        draw(stage_id, ver, st)    # donor discards draws without consuming the value
```

**Donor stage boundaries to mirror** (D02 §4.6, prior [O]; reseed then consume
in this order): `initmapgen :99/:146` → `dogenerate :1538` → `:1100` (per player
`i` discarded draws + 1) → `:1161` (per team `i` + 1) → `:1177` (`j+1` + 1) →
`:1213` (`i+9` + 1) → `:1616` (relief `floor(r*5)`; note `minesdensity` draw
happens *before* this reseed) → `:1772` (pattern passes) → `:1909` (units) →
`:1927` (final) → `generatemap.inc:216/:513/:774` (`SetRandomExtKey64` on the
map/global streams). Also consume the neutralised draw at `dogenerate.inc:5-6`
(`foreststype := floor(r*3); foreststype := 0`) and the mask-choice draw at
`generatemap.inc:190`. The port's single `game.rng` stream cannot reproduce
this; a ledger is required.

---

## 7. Implications for spec §02

| §02 area | Status | Required change / note |
|---|---|---|
| §1 key schema | confirmed [O] | Keep `key0`=high, `key1`=low, `GetRandomKey = key1`. **Add**: only `key1` seeds the state recurrence; `key0` is discarded (X21 §4.3, correction to D02 §4.2). |
| §2 core RNG | confirmed [O]/[D] | Formula unchanged. **Add**: output must be rounded to **float32** before any `floor`; D02's worked decimals are unrounded doubles (X21 §4.5). Cite X21 vectors as the canonical I07 fixture. |
| §3 three streams | confirmed [O]/[I] | Keep. Add the 5-instance signature census (`ev_54ac1f0c…`) and the separate Delphi LCG. Class identities remain `[U]`. |
| §4 stage determinism | confirmed [O] prior | Add the explicit draw-ledger contract of §6.2: `(stage_id, generator_version, stream_name)` key, reseed + counter reset, discarded draws recorded. |
| §5 implementation consequence | PORT APPROXIMATION | Replace "port's single `game.rng`" with three masked-u32 streams plus a Delphi stream; seed from `(k0,k1)` per §6. |
| New subsection | [D]/PORT APPROXIMATION | Add `s=0` behaviour (no stick, no fixed point) and the exact 20-vector fixture reference. |
| `GenerateMapRandKey`, saved-map key bytes | **[U]** | Keep blocked; unchanged by X21. |

---

## 8. Risks

1. **Float32 promotion [D]/[U].** Returning a bare binary64 `s/2^32` shifts values
   by up to ~3e−8 and can change `floor(r*n)` at exact boundaries. The 20 vectors
   showed no f32-vs-f64 floor divergence for `n ∈ {3,5,10,256}`, but this is a
   sample, not a proof. DScript's arithmetic promotion type is **[U]**; both
   floor variants are in the JSON.
2. **Shared global stream [O] prior.** GUI/AI/projectile draws consume the same
   global `RandomExt`; a port with a private terrain-only stream will be *more*
   stable than the donor, not identical. Call-for-call parity inside a stage is
   necessary but external draws can still shift it.
3. **Nonzero `key0` signed edge case [U].** If the product high word
   (`high(M·lo) + low(M·hi) + carry`) has bit 31 set, `sub_4067b8`'s signed path
   (`0x4067d6`–`0x406821`) negates the remainder and returns `edx = 0xFFFFFFFF`;
   then `fild qword` reads a negative 64-bit state and draw #1 is **not** given by
   the simple u32 model. For `key0 = 0x44A108F9, key1 = 0` the high word is
   `0x00004392` (positive), so the published example is safe. Whether donor ever
   passes a key0 that triggers this is unknown; no donor execution was allowed.
4. **Negative `SetRandomKey` keys [I]/[U].** `hi = k>>31` sign-extends; the low
   recurrence is unaffected, but the first output is exposed to item 3.
5. **No parity claim.** No donor was executed and no A/B GPU frame exists; all
   port guidance is `PORT APPROXIMATION`.
6. **Fixture provenance.** The fixed key pair is synthetic test input; it is not
   a recovered donor seed. I07 must not embed it as a "donor seed".

---

## 9. UNVERIFIED register

| # | Claim | Status | Passes attempted / reason |
|---:|---|---|---|
| XU1 | `GenerateMapRandKey` body; how `(key0,key1)` is derived | **[U]** | inherited from D02 Anomaly D: strings, byte scan, `native_function_find`/pseudocode, pointer scan, full `data\` search — call sites only. X21 did not retry. |
| XU2 | Byte-to-field mapping of keys in saved `.map` blobs | **[U]** | inherited D02 U2; no known-key generated map read. |
| XU3 | Vectors equal a live donor replay | **[U]** | donor execution prohibited by charter; Python model only. |
| XU4 | DScript numeric promotion for `floor(RandomExt*n)` | **[U]** | both f32-product and f64-product floors supplied; no script-runtime type recovery done. |
| XU5 | First draw for arbitrary nonzero `key0` whose product high word has bit 31 set | **[U]** | derived from `ev_83bff802…` signed path; no donor run, no known such key. |
| XU6 | Exact class identity / word order of `SetMapGeneratorRandomKey` and `SetGlobalMapGeneratorRandomKey` | **[I]/[U]** | same constants in 5 instances (`ev_54ac1f0c…`); setter bodies not anchored (D02 U6). |
| XU7 | Whether terrain generation calls the separate Delphi `Random()` | **[U]** | generation scripts observed use `RandomExt`; exhaustive call-path trace not done. |
| XU8 | Behaviour for `GetRandom(0)` / negative `n` in version-gated branches | **[U]** | wrapper text observed; boundary semantics not established. |

---

## 10. Open questions

1. Can a known-key generated `game_v…k….map` be obtained read-only to validate
   XU2/XU3 without executing the donor?
2. Does the DScript VM perform `RandomExt * n` in single or double precision
   (XU4)? A single divergent boundary would settle it.
3. Which of the five in-binary LCG instances are seeded by the three native
   setters respectively, and in which word order (XU6)?
4. Does any skirmish stage pass a `key0` that triggers the negative-product-high
   path (XU5)?
5. What is the exact draw count of `SetupMines` / `SetupStartingResources` for
   each `minesdensity` and `gRecordGeneratorVersion`, required to make the
   ledger byte-identical across versions?

---

## 11. Closing

**[O]/[D]** The donor `RandomExt` recurrence is independently confirmed from raw
bytes and both arithmetic helpers: one 32-bit LCG, float32 output, two key words
of which only the low one feeds the state. **[D]** Two corrections to D02 are
recorded: `key0` never affects the stream, and the published example decimals
were unrounded doubles. **[D]** Twenty exact vectors plus word-order and
zero-state cases are provided for I07. **[U]** Seed derivation, saved-map key
bytes, live replay equivalence, DScript promotion and the signed first-draw edge
case remain open. No donor parity claim is made; all port guidance is labelled
`PORT APPROXIMATION`.
