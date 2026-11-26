---
id: X12-STAMP-VERIFICATION
title: "X12 — independent verification of D05's relief stamp, config offsets and three blend paths"
agent: X12 (verification wave, donor-first terrain swarm 2026-11-26)
date: 2026-11-26
status: LANDED
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
target: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c (deep/Ghidra 12.2 + built-in engine 0.6.1)"
cross_check: "t_68474ddde43f = editor.exe (pinned by document= only; active restored to editor.exe at end)"
rules: "READ-ONLY donor. No donor binary executed, copied or committed. No source/asset/config/test/git edit. No Godot job. No donor-parity claim."
---

# X12 — Stamp verification (D05's most consequential binary finding)

## Executive summary

1. **[O] ACCEPT — core finding confirmed.** `sub_755f30` is a real function at VA `0x755f30`–`0x75c187`, 25,175 B, 234 blocks, 6,751 instructions, 5 callers; both decompilers reproduce it (evidence ev_13f00ea1…, ev_c176cc8…, ev_ed57855…). This matches D05's bounds exactly.
2. **[O] ACCEPT — three blend paths confirmed at opcode level.** ReplaceForWater → `g*Scale + Offset` (`0x75661f`–`0x756651`); Replace → `base_h + g_pivoted + Offset` (`0x756674`–`0x75667d`); default Smooth → `h1 + (base_h-h0)*TerrainScale + g_pivoted + Offset` with **two** `getHeight` reads (`0x7566a0`, `0x7566c7`) (`ev_a92017a…`). No earlier report need be taken on trust.
3. **[O] ACCEPT — Min is the scale pivot; Max is never read in this function.** `fsub [eax+0x5c]` → `fmul scale` → `fadd [eax+0x5c]` at `0x75660d/610/616`; **zero** `[…+0x60]` operands in all 6,751 instructions and zero x87 opcodes ending in disp `0x60`. `HeightFieldOffset` (`+0x64`) is the additive term. The port's `clamp(h_base + grid*Scale, Min, Max)` remains refuted for the stamp.
4. **[O] ACCEPT — config field→offset map confirmed.** `sub_75c314` (`0x75c314`–`0x75c6a1`, 801 B, 237 instr) stores `Stand=+0x39`, `Replace=+0x3a`, `ReplaceForWater=+0x3b`, `UseRndScale=+0x3c`, `MinScale/MaxScale=+0x40/+0x44`, `Scale=+0x48`, `TerrainScale=+0x68`, `Smooth=+0x4c`, `SmoothRadius/Factor/Offset=+0x50/+0x54/+0x58` (default 2), `Min/Max/Offset=+0x5c/+0x60/+0x64` (ev_938f5d4…, ev_e2e21ff…).
5. **[D] REJECT one sub-claim — the DScript call chain's middle link.** The `StandPattern` signature at `0x6a3474` is registered to impl `FUN_006b28d8`, but that impl calls **`FUN_0075c228`**, which calls the stamp (`0x75c240`). `0x6b2878` and `0x6b2b60` are *sibling* DScript natives (`StandPatternWithAngle`, `StandPatternWithAngleAdv`) that each call `sub_755f30` directly. D05's `StandPattern → 0x6b28d8 → 0x6b2878 → sub_6b2b60 → sub_755f30` is therefore wrong in its intermediates; the anchor and destination remain right.
6. **[U] No donor visual parity asserted.** All statements are static-byte/decompiler observations; no donor frame was rendered.

---

## Evidence table

| # | Evidence id / citation | Class | Establishes |
|---|---|---|---|
| E1 | `ev_13f00ea1ed28ddf24de9e05c19cde14784b86fa896e91e6b1f869eafc8df9bf3` — `native_function_show 0x755f30` | [O] | Entry `0x755f30`, end `0x75c187`, 25,175 B, 234 blocks, 6,751 instr, 5 callers, 662 call sites, `truncated:false`. |
| E2 | `ev_58613f529b5380d399137349c8c59400de238bf83a1d143bcbfd113db1ff1b9a` — `native_function_address_show` | [O] | `0x755f30` resolves to canonical entry `sub_755f30`. |
| E3 | `ev_c176cc8193528500a8f570e5f914c7bf4ecccf5424bbe81125f92a78de2a3237` — Deep/Ghidra `native_function_pseudocode 0x755f30` | [O]/[D] | Full stamp C: scale select, base sample, grid fetch, three branches; x87 locals `float10` noisy. |
| E4 | `ev_ed57855c0a723d2bf9995595ceb89e76ef66946ef0ebee56bd6c690a21035a36` — `native_function_study 0x755f30` | [D] | 234 blocks, 6751 assembly, 662 callees, 947 outgoing refs, 5 incoming refs; 2802 `__asm` nodes, 45 gotos (honest limits). |
| E5 | `ev_a92017af639d80f9376ed2455cdc2b64fe9ea1204148e91c4241e7405b1caff5` — `native_function_instructions_list 0x755f30` | [O] | Decisive x87 opcode sequence `0x7563e8`–`0x7566e9`; basis of all three formulas and the zero-`+0x60` test. |
| E6 | `ev_a8a4e70037805e024c8cef28e52ecdbfad19189935b8392875a4b9662fb9cf41`, `ev_2a8ddaa963e58369fff02542b2294f32c59a4a484253563b6c72c5ae8c375573` | [O] | 5 callers: `sub_6b2b58@0x6b2bfc`, `sub_723748@0x723bf9/0x723cbc`, `sub_75c228@0x75c240`, `sub_75c1fc@0x75c28e`. |
| E7 | `ev_9b7e57b8d2c7a805e91ddb16bc80a3badc3986f593cf706f9d6c0aa03542f6f3`, `ev_491e769276243753a667b268c8b2adc68628e361640382ebe5283ffb6ae8b6c1` | [O] | Parser `sub_75c314`: `0x75c314`–`0x75c6a1`, 801 B, 8 blocks, 237 instr. |
| E8 | `ev_938f5d4f3eaad20112692878ea6410469d7159c7c6239fafa9ac80849c627a2e` — `native_function_pseudocode 0x75c314` (clean-room lifter; Ghidra could not make a function here) | [O]/[D] | Each getter call paired with its struct store offset and default literal. |
| E9 | `ev_25c606330620f7e3756089658080d719200ba936631898498a80cadd73f79e30` — `native_function_study 0x75c314` | [D] | 42 callees, 81 outgoing refs, 1 incoming ref (`0x75c2b6` data ref from `sub_75c1fc`); getters `0x8967b4/896a8c/896b1c`. |
| E10 | `ev_e2e21ffe9ff5c28dfb612e99298b0c0dc002747f3705c1ccf99d6b69245e9810` — raw 480 B @ `0x75c720` | [O] | Literal field names at the exact addresses the parser passes as `edx`: `…Stand/Replace/ReplaceForWater/…Min/…Max/…Offset`. |
| E11 | `ev_f391923800456236a50dcfbdbaa94b46e798c488c1c75610c4adb57440510a95`, `ev_dfd5cff85f6626a05ca820d150aaef9ec535ef7717aaad9125e7a7913a88db79` | [O] | Constants `2.0f` @`0x75c1a4` (252 references), `4.0f` @`0x755ee4`; `0.5f` @`0x75c1a8` also read. |
| E12 | `ev_86ca5cd7f0e3c42c877e19ea75196261706904e3b881cd71b6301e6668f644cd` — `native_bytes_find "d8 28 6b 00"` | [O] | Exactly one LE occurrence of `0x6b28d8`, at VA `0x69bdb6` inside registration function `sub_69a70c`. |
| E13 | aligned `mov ecx,0x6b28d8` @`0x69bdb5` + raw 48 B @`0x69bda0`; signature cstring @`0x6a3474` | [O] | DScript `procedure StandPattern(const plhandle: Integer; const patternname: String; const standx, standz, rotangle: Float)` is paired with impl `0x6b28d8`. |
| E14 | Deep pseudocode of `FUN_006b28d8`, `FUN_006b2878`, `FUN_006b2878`, `FUN_006b2b60`, `FUN_0075c228` | [O]/[D] | `0x6b28d8 → 0x75c228 → 0x755f30`; `0x6b2878 → 0x755f30`; `0x6b2b60 → 0x755f30`. |
| E15 | `ev_e65fb8fd5f384bfa7d7e8268fbe0cbe0d9fcdf67855cdc06403c5588794101f3` — Deep pseudocode `FUN_006b2b60` | [O]/[D] | Byte-identical evidence id to D05's E7; wrapper calls `FUN_00755f30(…,0,…)` then does `group.` bookkeeping. |
| E16 | `ev_6091d0e47803fd350a322e455111ba5bbf719e27d04c49b8df2cb153c564eb1a`, `ev_244b6613bdf0708c24c729d9af7d464535fcc44a145e6f70b4aa90741de37d68`, `ev_ad1f1ad68e03dbe85841fba91f552b55c8c42cd8633ad5492f83879f5a79c00e` | [O] | Built-in engine does **not** discover `0x6b28d8`; at that VA the bytes are `55` (`push ebp`) with `xrefs_to=1` — a real prologue reached by the one registration pointer. |
| E17 | `ev_01211df1b06d9b135e1c4120ddfd25ec713ad92baa90e03266f94ba0d8084a6f` — editor.exe raw @`0x8cc7ae` | [O] | Independent binary corroboration of identical struct offsets `+0x3a/+0x3b/+0x3c/+0x40…/+0x5c/+0x60/+0x64`; `HeightFieldReplaceForWater` literals also in editor `.rsrc`. |
| E18 | `core_session_show` before/after | [O] | Active target initially and finally `t_68474ddde43f` (editor.exe); cossacks.exe was always addressed with pinned `document=`. |

---

## Method and pass register (owner directive: multiple passes, no silent skips)

| Pass | Instrument | Result | Accept / reject reasoning |
|---|---|---|---|
| P1 | `native_function_show` + `native_function_address_show` on both anchors | Bounds as in E1/E7 | **Accepted**: two independent tools agree; `truncated:false` matters for the negative (Max) claim. |
| P2 | Deep `native_function_pseudocode 0x755f30` | Full stamp C, `float10` locals, branch order visible | **Provisional only**: accepted for control flow, **rejected for operand naming** (D05's own R1); every formula re-derived in P4. |
| P3 | `native_function_study` (summary + `pseudocode` facet via `core_evidence_browse`) | Same counts; 2802 `__asm` nodes, 45 gotos | **Accepted as corroboration, not authority**: the lifter is honest about limits; its lazy-loader prologue matches E3. |
| P4 | `native_function_instructions_list`, filtered programmatically over all 6,751 instructions | Exact x87 ops and all struct offsets; `+0x60` count **0** | **Accepted**: decisive, independent of both decompilers; this is the primary evidence for the three formulas and the Max result. |
| P5 | Second pass on the negative: scan every instruction whose bytes end in `60` and mnemonic starts with `f` | **0** matches | **Accepted**: confirms P4's textual filter was not a formatting artifact. (Caveat: only operand hex syntax `+0x60` could be matched; no other syntax observed anywhere in the function.) |
| P6 | `native_function_show/find/address_show` on `0x6b28d8` | `function_not_found` / "not inside any discovered function" | **Rejected as proof of absence**: discovery is known incomplete; P7–P8 followed instead. |
| P7 | `native_instruction_show 0x6b28d8` + `native_bytes_show` | `55` `push ebp`, `xrefs_to=1` | **Accepted**: real prologue; single xref is consistent with a registration pointer, not a call. |
| P8 | `native_instruction_show 0x69bdb6` reported `fsubr st,[eax]` | Misaligned decode inside an immediate | **Rejected**: raw 48-byte window shows a repeating 17-byte table pattern `b9 <impl32> ba <sig32> 8b c3 8b …`; aligned read at `0x69bdb5` is `mov ecx,0x6b28d8` (`ev_…`). **Accepted** aligned reading. |
| P9 | Deep pseudocode of `0x6b28d8`, `0x6b2878`, `0x6b2b60`, `0x75c228`; callers of `0x75c228` | Different chain than D05 | **Accepted after repeated passes**: three separate on-demand decompilations plus the direct-caller list all agree. D05's intermediate link is **rejected**. |
| P10 | Built-in `sub_6b2b58` vs Deep `FUN_006b2b60` | Two function entries 8 bytes apart, near-identical bodies | **Accepted as engine-boundary artifact**, not a second stamp: both contain exactly one `sub_755f30` call and identical group bookkeeping. |
| P11 | `native_objdump_run` and `native_rizin_command_run` with `path=` | Both `engine_missing` | **Rejected (no result)**: tools unavailable; no inference drawn. **Side effect**: active target drifted — corrected immediately (P14). |
| P12 | Parser: clean-room pseudocode + raw string table + raw editor.exe bytes | All offsets agree | **Accepted**: three independent readings (decompiler, literal bytes, second binary). |
| P13 | `native_data_show type=f32` on `0x75c1a4/0x75c1a8/0x755ee4` | `2.0`, `0.5`, `4.0` | **Accepted**: matches the `fdiv [0x75c1a4]` and smooth `/4.0` opcodes. |
| P14 | `core_session_show` → `core_target_select t_68474ddde43f` → `core_session_show` | Drift detected, restored | **Accepted**: shared-session hygiene restored; final active = editor.exe (E18). |

---

## Per-claim verification results

### Claim 1 — function entry, size, dual decompile — **ACCEPT [O]**

`sub_755f30`: `0x755f30`–`0x75c187`, 25,175 B, 234 blocks, 6,751 instructions, 5 callers, 662 call sites, `unresolved_indirect_jumps:0`, `truncated:false` (E1). Deep pseudocode names it `FUN_00755f30` (E3); `native_function_study` independently reports the same counts (E4). No contradiction with D05.

### Claim 2 — `StandPattern → 0x6b28d8 → 0x755f30` — **PARTIAL REJECT [D]**

Confirmed: DScript signature `procedure StandPattern(const plhandle: Integer; const patternname: String; const standx, standz, rotangle: Float)` @`0x6a3474` is registered to impl `0x6b28d8` by `mov ecx,0x6b28d8` @`0x69bdb5` inside `sub_69a70c` (`0x69a70c`–`0x69d184`); the pointer has exactly one occurrence in the binary (E12/E13). `0x6b28d8` is a `push ebp` prologue (E16).

Rejected: the intermediate hop. Deep decompilation of `FUN_006b28d8` is:

```
iVar1 = FUN_00705944(); if (*(int*)(iVar1+0x4c) != 0) { … }
if (pattern && player) FUN_0075c228(pattern, player, 0, standx, standz, rotangle);
```

and `FUN_0075c228` is a one-liner: `FUN_00755f30(param_1,param_2,param_3,0x42b40000,0,param_4,param_5,param_6)`. Built-in callers of `0x755f30` corroborate the `0x75c240` site (E6). By contrast `FUN_006b2878` (`StandPatternWithAngle`, signature @`0x6a33dc`) and `FUN_006b2b60` (signature `… StandPatternWithAngleAdv … makegr, movetopar …` @`0x6a35bc`) **each call `FUN_00755f30` directly** and do the `group.` bookkeeping. So `0x6b2878` is a sibling native, not a step from `0x6b28d8`.

Corrected chain:

```
DScript StandPattern (0x6a3474) → 0x6b28d8 → FUN_0075c228 (0x75c228) → sub_755f30 @0x75c240
DScript StandPatternWithAngle (0x6a33dc) → 0x6b2878 → sub_755f30 (direct)
DScript StandPatternWithAngleAdv (0x6a35bc) → 0x6b2b60 / builtin sub_6b2b58 → sub_755f30 @0x6b2bfc
+ 2 more direct callers: sub_723748 @0x723bf9/0x723cbc, sub_75c1fc @0x75c28e
```

The stamp anchor itself and the `plhandle/pattern_lookup/…` argument shape are unaffected; this is a chain-label correction for spec §04.

### Claim 3 — config field offsets in `sub_75c314` — **ACCEPT [O]**

`sub_75c314` `0x75c314`–`0x75c6a1`, 801 B, 237 instr (E7). Its decompiled stores, cross-checked against the literal names at the exact `edx` pointers in the raw string table (E8/E10):

| Field (literal @VA) | Store | Default | Field (literal @VA) | Store | Default |
|---|---|---|---|---|---|
| HeightFieldStand (`0x75c72c`) | `+0x39` | true | HeightFieldSmooth (`0x75c844`) | `+0x4c` | false |
| HeightFieldReplace (`0x75c748`) | `+0x3a` | false | SmoothRadius/Factor/Offset | `+0x50/+0x54/+0x58` | 0/0/**2** |
| HeightFieldReplaceForWater (`0x75c764`) | `+0x3b` | false | HeightFieldMin (`0x75c998`) | `+0x5c` | 1.0f |
| HeightFieldUseRndScale (`0x75c788`) | `+0x3c` | false | HeightFieldMax (`0x75c9b0`) | `+0x60` | 1.0f |
| MinScale/MaxScale | `+0x40/+0x44` | 1.0f/1.0f | HeightFieldOffset (`0x75c9c8`) | `+0x64` | 0 |
| HeightFieldScale (`0x75c7e0`) | `+0x48` | 1.0f | OffsetX/Z | `+0x74/+0x78` | 0 |
| TerrainScale (`0x75c7fc`) | `+0x68` | 1.0f | ObjectsScale/RotationAngle | `+0x6c/+0x70` | 1.0f/1.0f |

Parser has **0 direct callers** and one data reference from `sub_75c1fc` @`0x75c2b6` (E9) — it is reached as a pointer, not a direct call; this explains why naive "caller" queries find nothing. Getters: `0x8967b4` (bool), `0x896a8c` (int), `0x896b1c` (float+default), `0x896bac` (string).

### Claim 4 — three blend paths, constants, arithmetic sequence — **ACCEPT [O]**

Scale setup: `0x7563eb cmp [p+0x3c],0` → if false `mov eax,[p+0x48]` @`0x756417` (verified scale) → stored `[ebp-0x20]`; if true `call 0x403a28` @`0x7563fd` + `call 0x4a2b6c` @`0x756409` → `[ebp-0x20]`. `base_h = getBilinearWorldHeight()` via `call 0x810498` @`0x756435` → `[ebp-0x10]`. Grid `g` = `[p+0x28][row][col]` float32 (`0x7565e6`–`0x7565fb`).

Pivot (`!ReplaceForWater`, `0x756601`): `fsub [p+0x5c]` @`0x75660d`, `fmul [ebp-0x20]` @`0x756610`, `fadd [p+0x5c]` @`0x756616` ⇒ `g ← (g-Min)*Scale + Min`. Else (`0x75661f`–`0x756625`): `g ← g*Scale`. Occupancy gate `cmp byte [mask],0 / jne 0x7566e9` @`0x756638`.

The three final paths (E5):

| Mode | Opcode chain | Result |
|---|---|---|
| `ReplaceForWater=true` (`cmp [p+0x3b]` @`0x756645`, `jne` taken) | `0x75664b fld g`; `0x756651 fadd [p+0x64]`; `call 0x7551a8` @`0x756664` | **`new = g*Scale + Offset`** |
| `Replace=true` (`cmp [p+0x3a]` @`0x75666e`, `je` not taken) | `0x756674 fld [ebp-0x10]`; `0x756677 fadd g`; `0x75667d fadd [p+0x64]`; setter @`0x756690` | **`new = base_h + g_pivoted + Offset`** |
| default Smooth | `call 0x7553a0` @`0x7566a0` (h0); `0x7566a5 fsubr [ebp-0x10]` ⇒ `base_h-h0`; `0x7566ab fmul [p+0x68]`; `0x7566ae fadd g`; `0x7566b4 fadd [p+0x64]`; spill tbyte; `call 0x7553a0` @`0x7566c7` (h1); `0x7566cc fld`; `0x7566d2 faddp`; setter @`0x7566e4` | **`new = h1 + (base_h-h0)*TerrainScale + g_pivoted + Offset`** |

D05's prose formulas are algebraically equivalent. One notation refinement: in the Replace/Smooth branches `g` is already pivot-scaled, so `g*Scale'` in D05's summary means `(g-Min)*Scale+Min`, not a second multiply. Constants: `2.0f` @`0x75c1a4` (used by rotation arithmetic `fdiv` @`0x7564a2/4f0/513/567/5cf`), `0.5f` @`0x75c1a8`, `4.0f` @`0x755ee4` (smooth divisor). **[D]** With the common `TerrainScale=1` and `h1≈h0`, Smooth reduces to `base_h + g_pivoted + Offset`.

### Claim 5 — Min pivot / Max never read — **ACCEPT [O]**

`Min` (`+0x5c`) is demonstrably a **pivot**, not a bound: the same field is subtracted before and added after the scale multiply (E5). `Max` (`+0x60`) has **zero** operand occurrences across all 6,751 instructions (P4), and a second raw-byte-oriented pass found zero x87 instructions with terminal displacement byte `0x60` (P5). `Offset` (`+0x64`) is the additive term. There is **no** `fcom`/`fmin`/`fmax` against Min or Max in the stamp loop. Honest limit: this proves "not read **in this function**"; `Max` is written by the parser (`+0x60`) and read by editor code (E17), and any global height-setter clamp remains **[U]** (D05 U2).

---

## Implications for spec §04 (no source changed by X12)

1. Keep D05's three blend branches verbatim; they survive independent instruction-level verification. Label them **DONOR-DERIVED [O]** for these exact operations.
2. Do **not** implement a `[Min,Max]` clamp in the stamp; `Min` is the pivot of `(g-Min)*Scale+Min` and `Max` is metadata in this stage. The additive term is `HeightFieldOffset` (`+0x64`).
3. Preserve the two `getHeight` reads in Smooth — the first feeds `(base_h-h0)*TerrainScale`, the second is the value added to. Collapsing them to one read is a `PORT APPROXIMATION`, not an exact translation.
4. Correct the spec's call-chain sentence: `StandPattern(0x6a3474) → 0x6b28d8 → 0x75c228 → 0x755f30`; `0x6b2878` and `0x6b2b60` are sibling natives that stamp directly. Do not describe `0x6b2878` as an intermediate hop.
5. Expect multiple stamp entry points: five direct call sites of `sub_755f30` exist, including `sub_723748` (two sites) and `sub_75c1fc`; a map-generation and an editor/ brush path may share the same stamp.
6. Export the parser offsets above verbatim from `pattern.lib`; `globalparams.cfg` is not the source of sculpt constants (D05 §F6 stands, not re-tested here).
7. **No donor parity claim.** Nothing here is a rendered A/B frame.

---

## Risks

- **R1 — Engine boundary discrepancy [D].** Built-in `sub_6b2b58` vs Ghidra `FUN_006b2b60` (8 bytes apart) with near-identical bodies. Treat as one wrapper; do not encode either VA as semantically authoritative in the spec.
- **R2 — Ghidra x87 noise [O].** `float10`/`in_STn` locals are unreliable for operand naming; mitigated by P4 opcode pass. Any future re-decompile must repeat the opcode cross-check.
- **R3 — No third disassembler [U].** `objdump` and `Rizin` engines are not installed; P11 produced no data. Two decompilers + built-in instruction listing + raw bytes were used instead.
- **R4 — Global setter clamp [U].** `sub_7551a8 → sub_0059b934` not studied by X12; D05 U2 stays open.
- **R5 — Incomplete function discovery [O].** `0x6b28d8` is not in the built-in function table; absence of a function entry is not absence of code. Any "no other consumer" statement must use raw-byte/pointer evidence.
- **R6 — Shared-session drift [O].** Two failed `path=` engine calls changed the active target from editor.exe to cossacks.exe; restored via `core_target_select` (E18). Future workers should avoid `path=` on unavailable engines.
- **R7 — Negative scale [D].** A negative `HeightFieldScale` multiplies `g` (or `g` about `Min`) and therefore inverts relief without negating world height; port must preserve sign semantics.

---

## UNVERIFIED register

| Id | Claim | Status / passes attempted |
|---|---|---|
| U1 | File row `v` → signed world y (flip flag) | **[U]** inherited from D05; X12 verified only row→`+0x28` grid indexing (`0x7565e6`–`0x7565fb`), not file-row sign. |
| U2 | Clamp to `Min/Max` after blending | **[U]/refuted in stamp** — P4/P5 zero `+0x60`; global `sub_0059b934` unstudied. |
| U3 | Exact rounding of rotated sub-cell coordinates | **[U]** `fdiv [0x75c1a4]` visible; integer rounding rule not proven. |
| U4 | `SmoothOffset` sign in radial remap | **[D]** not re-derived by X12. |
| U5 | `.pattern` float-plane byte boundary | **[U]** inherited from D05/DPATTERN_01. |
| U6 | `PatternMask*` flags → occupancy byte at `0x756638` | **[U]** gate confirmed; flag semantics not. |
| U7 | `Replace=true` on a real pattern | **[O] code path / [U] incidence**. |
| U8 | Visual parity with donor | **[U]** no GPU A/B frame; no claim. |
| U9 | Whether D05's "group wrapper" label belongs to `StandPatternWithAngleAdv` | **[U]** group bookkeeping observed in `FUN_006b2b60` / `sub_6b2b58`; the DScript name mapping was read from `0x6a35bc` but the semantic label is not otherwise tested. |
| U10 | Which of the five stamp call sites is map-generation vs editor/brush | **[U]** call sites enumerated (E6), not attributed to game phases. |

---

## Open questions

1. Does `sub_0059b934` (global height setter) apply a map-wide ceiling/floor, and could that explain the baked `−2.964` bound mentioned in D05 Q1?
2. Are the two `sub_723748` stamp calls and `sub_75c1fc` the editor/brush path or the skirmish map-generation path? (U10)
3. Why does the registration table pair `0x6b28d8` with a one-line wrapper (`0x75c228`) while sibling natives call the stamp directly — a Delphi unit boundary or a deliberate parameter clamp (note the fixed `0x42b40000` argument)?
4. Does any consumer outside `sub_755f30` read `HeightFieldMax` at runtime (editor preview was only checked as a struct-offset reader, not a value consumer)?
5. Is the 8-byte built-in/Ghidra boundary split at `0x6b2b58/0x6b2b60` reproducible in other binaries, or specific to this engine's discovery heuristic?
6. If `TerrainScale` is not 1.0 in any shipped `pattern.lib` section, how large is the divergence between the true two-read Smooth branch and a single-read port approximation?

---

*End of X12 report. One Markdown report written; donor read-only; no donor binary executed or copied; no source, asset, config, test, git or Godot change; active Craft Anything target restored to editor.exe; no donor visual parity claimed.*
