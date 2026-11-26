---
id: X26-BLEND-FORMULA-VERIFICATION
title: "X26 — authoritative relief blend formula: donor opcode re-decompile + independent f32 vector replay"
agent: "worker X26 (verification wave, donor-first terrain swarm 2026-11-26)"
date: 2026-11-26
status: LANDED
labels: [O, D, I, U, "PORT APPROXIMATION"]
donor: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c; read only, never executed/copied"
rules: "READ-ONLY donor. No donor binary executed, copied or committed. No source/asset/config/test/git/Godot edit. One repo file written. No donor-parity claim."
verdict: "D05_F4_AUTHORITATIVE__X13_REPLACE_OBJECTION_UPHELD__TASK_LITERAL_REFUTED__X13_GRID_OFFSETS_STALE__POSTPASS_IN_PLACE_SETTLED__NO_PARITY_CLAIM"
---

# X26 — Settle the relief blend formula

## Executive summary

1. **[O] X13's Replace objection is UPHELD.** The circulated `Replace = base_h + g + Offset`
   (spec `docs/terrain_swarm_2026-11-26/spec/04_PATTERN_STAMPING.md:84`, §6 table) is
   **not** the donor operation. A fresh pinned Deep/Ghidra decompile of `sub_755f30`
   shows the pivot `(g − Min)*Scale + Min` at Deep pseudocode lines **297–303**
   (evidence `ev_c176cc8193528500a8f570e5f914c7bf4ecccf5424bbe81125f92a78de2a3237`)
   and x87 opcodes `0x756607/0x75660d/0x756610/0x756616/0x756619`
   (evidence `ev_a92017af639d80f9376ed2455cdc2b64fe9ea1204148e91c4241e7405b1caff5`),
   followed by `base_h + g2 + Offset` at `0x756674/0x756677/0x75667d` and setter
   `0x756690`. `Scale` is consumed in **every** branch; `Min` is a pivot only when
   `ReplaceForWater=false`. `HeightFieldMax` (`+0x60`) has **0** struct-field operand
   occurrences across all 6,751 instructions (re-scanned this pass).
2. **[D] D05 F4 is authoritative in full**; X12's independent opcode pass and this
   pass's Deep pseudocode agree line-for-line. The published Smooth row already
   contains `Scale`/`Min` pivot; its only defect is the single `h` read. The task
   literal fails 3/19 X13 discriminator vectors (`REP-hil1-01`, `REP-kr1-02`,
   `SMB-kr1-02`); the D05 formula reproduced **19/19** X13 `d05_f32step` bit patterns
   with a freshly written Python implementation (not importing X13's code).
3. **[O] X13's grid offsets are STALE.** All 19 vector `g_bits` trace to F02/DPATTERN
   shifted starts `G=1000/1912/2866`; F01 proved `G = 8 + (w−1)(h−1)` =
   `968/1864/2798` by exact size closure on 710/710 files. The shift is
   **+8 / +12 / +17 floats**. Min/max match at both starts (long zero borders),
   which is why X13's cross-check passed. The *formula* conclusion is unaffected;
   the *spatial meaning* of the golden outputs is.
4. **[O] The post-pass update order is SETTLED: in-place read-after-write.**
   `sub_755db4` calls `getHeight` (`sub_7553a0`) four times at `0x755e6a/7a/8a/9a`,
   divides the sum by hardcoded `4.0f` at `[0x755ee4]` (`0x755eaf`), then calls
   `setHeight` (`sub_7551a8`) at `0x755ec2` on the **same** world field. No snapshot
   buffer exists. X13's U6 / "I07 must choose" is resolved in favour of the in-place
   column; the 4/4 divergence X13 measured remains a correct numeric observation
   but its double-buffer column is not donor-faithful.
5. **[U]** True x87 80-bit behaviour, row-sign flip, global setter clamp, rotation
   rounding, synthetic-flag incidence and visual parity remain unverified.
   **No donor GPU A/B frame exists; no parity claim is made.**

---

## Evidence table

| # | Evidence id / citation | Class | Establishes |
|---:|---|---|---|
| E1 | `ev_13f00ea1ed28ddf24de9e05c19cde14784b86fa896e91e6b1f869eafc8df9bf3` — `native_function_show 0x755f30`, pinned `document="t_87f0f3c130b0"` | [O] | Entry `0x755f30`, end `0x75c187`, 234 blocks, 6,751 instructions; `truncated:false` basis for the negative `+0x60` claim. Same id as D05/X12. |
| E2 | `ev_c176cc8193528500a8f570e5f914c7bf4ecccf5424bbe81125f92a78de2a3237` — Deep/Ghidra 12.2 `native_function_pseudocode 0x755f30`, 1,973 lines, engine reported as `ghidra`, limitation `deep_engine` | [O]+[D] | Pivot at lines 297–303; three final branches at 306–330; scale select 244–258; base sample 260–261. Same evidence id as X12 E3 (deterministic re-run). |
| E3 | `ev_a92017af639d80f9376ed2455cdc2b64fe9ea1204148e91c4241e7405b1caff5` — `native_function_instructions_list 0x755f30`, 6,751 instructions | [O] | Exact x87 opcodes and byte encodings for every branch (§Authoritative table). Same id as X12 E5. |
| E4 | E3 filtered `0x7563e8`–`0x75644b` | [O] | `cmp [p+0x3c]` → literal `mov eax,[eax+0x48]` @`0x756417` → `[ebp-0x20]`; else LCG `call 0x403a28` @`0x7563fd` + `call 0x4a2b6c` @`0x756409`; `base_h` from `call 0x810498` @`0x756435`, `fstp dword [ebp-0x10]` @`0x75643a`; `cmp [p+0x39]`/`je 0x7566ff` @`0x756441/445`. |
| E5 | E3 filtered `0x756601`–`0x756642` | [O] | `fld g` `0x756607`, `fsub [eax+0x5c]` `0x75660d` (bytes `d8 60 5c`), `fmul [ebp-0x20]` `0x756610`, `fadd [eax+0x5c]` `0x756616` (bytes `d8 40 5c`), `fstp dword [ebp-0x40]` `0x756619`; else `fld/fmul/fstp` `0x75661f/622/625`; occupancy `cmp byte [eax+edx],0` `0x756638`, `jne 0x7566e9` `0x75663c`. |
| E6 | E3 filtered `0x756645`–`0x7566e9` | [O] | RFW `fadd [eax+0x64]` `0x756651` + setter `call 0x7551a8` `0x756664`; Replace `fld [ebp-0x10]` `0x756674`, `fadd [ebp-0x40]` `0x756677`, `fadd [eax+0x64]` `0x75667d`, setter `0x756690`; Smooth `call 0x7553a0` @`0x7566a0` (h0), `fsubr [ebp-0x10]` `0x7566a5`, `fmul [p+0x68]` `0x7566ab`, `fadd g` `0x7566ae`, `fadd [p+0x64]` `0x7566b4`, **`fstp tbyte [ebp-0x154]`** `0x7566b7`, second `call 0x7553a0` @`0x7566c7` (h1), `fld tbyte` `0x7566cc`, `faddp` `0x7566d2`, setter `0x7566e4`. |
| E7 | E3 full-instruction scan for operand `+0x60` and for x87 opcodes with terminal byte `60` | [O] | **0 / 6,751** struct-field `+0x60` operands and **0** x87 opcodes ending in `60`; `HeightFieldMax` is not read in this function. (Seven hits for textual `0x60` are `[ebp-0x60]` stack locals and a jump target `0x757167` — not struct accesses.) |
| E8 | `ev_aba9f17d8893279af422551fb642b74fdeb4d08d06092fe05cf191a59cb33253` + `ev_2e5b179ca47a7a27c660da5af73e52fcae37089f43300ae1d5317d8adc126efe` — `sub_755db4` instruction list / disassembly, 117 instructions | [O] | Four live `getHeight` reads `0x755e6a/7a/8a/9a`; sum `0x755ea3`–`0x755eac`; `fdiv [0x755ee4]` `0x755eaf`; one live `setHeight` `0x755ec2`. **In-place** post-pass. |
| E9 | E3 `0x757104`–`0x7571ce` | [O] | 8-neighbour mask gate; `Factor` from `[p+0x54]` with `dec/test/jl` (`0x757167`–`0x757170`) → iteration count; `(Radius−Offset)/d` from `[p+0x50]`/`[p+0x58]` (`0x7571a4`–`0x7571bb`); `fsqrt` `0x757199`. |
| E10 | `%TEMP%\opencode\blend_vectors\x13_blend_vectors.json` (sha256 `82945e4a…bcb8a` recorded in X13 E1) | [O]/[D] | 19 vectors, 4 smooth snapshots, per-vector f32 bit patterns for `g/base_h/h0/h1/flags` and three model outputs. Read only. |
| E11 | Fresh scripts `x26_verify.py`, `x26_verify2.py`, `x26_verify3.py` in `%TEMP%\opencode\blend_vectors\` (temp only; no repo file) | [D] | Independent formula replay, grid provenance, flag cross-check, F01 closure. Outputs in §Vector verification. |
| E12 | `data\pattern\pattern.lib` sections `hil1:33081-34745`, `g_hil4:366469-369365`, `k_ravine_1:549555-555363` (X13 E1–E3), re-parsed this pass | [O] | `Scale=0.649999976158142` (hil1), `1.0` (others); `Min/Max/Offset/TerrainScale/flags` all match X13 JSON bit-for-bit (13/13 fields × 3 patterns checked). |
| E13 | F01 §4.1/§4.2/§4.4, `reports/F01_pattern_format.md:43-52,123-168,195-235` | [O]+[D] | `filesize = 8 + 4wh + 54(w−1)(h−1)` over 710/710; `G = 8 + N`. Re-verified this pass on the three vector patterns (closure true, mask bytes 0/1 only). |
| E14 | `x13_blend_vectors.json` `grid_start_byte` 1000/1912/2866 vs E13 `G` 968/1864/2798 | [O]/[D] | All 19 vector `g_bits` occur at the declared `(z,x)` cell **only** in the shifted window; 0/19 match the F01-correct cell. Shift = +8/+12/+17 floats. |
| E15 | D05 `reports/D05_relief_stamp.md:132-172` F4; X12 `reports/X12_stamp_verification.md:118-137` Claim 4 | [O] | Prior opcode-level derivation of the same three branches; corroborated, not taken on trust. |

---

## Method and pass register (owner directive: multiple passes, no silent skip)

All Craft Anything calls used `execute` → `tools.craftanything.*` with
`document:"t_87f0f3c130b0"` pinned; `core_session_show` reported
`analysis_mode: "deep"`, `clean_room: false`, active target `t_68474ddde43f`
(editor.exe) before and after — **the active target was never changed**.

| Pass | Instrument | Contradiction / result | Accept / reject reasoning |
|---|---|---|---|
| P1 | `core_session_show` + `core_targets_list` | Deep mode active; both binaries open; active = editor.exe | **Accepted**: pin-by-`document` confirmed; no shared-session drift (contrast X12 P11/P14). |
| P2 | `native_function_pseudocode 0x755f30` (Deep/Ghidra, same evidence id as X12 E3) | 1,973-line C with `float10` locals; blend branch visible at lines 244–330 | **Accepted for control flow and operand identity** (`+0x5c`, `+0x48`, `+0x68`, `+100`); **rejected for float precision** (D05 R1 / X12 R2: `float10` naming unreliable). All formulas re-derived in P3. |
| P3 | `native_function_instructions_list 0x755f30`, filtered programmatically over all 6,751 instructions | Every branch opcode recovered (E4–E6); `+0x60` struct count 0 | **Accepted**: decisive, independent of both decompilers. |
| P4 | Second pass on the negative: regex over operands and over raw bytes ending `60` | 0 struct `+0x60`; 0 x87 terminal `60`. Seven textual `0x60` hits identified as stack locals/jump target | **Accepted**: X12's P5 negative survives a stricter scan; no correction required. |
| P5 | `native_function_disassemble`/`instructions_list` on `sub_755db4` + E3 `0x757104`–`0x7571ce` | Four `getHeight` + one `setHeight` on the same handle; no snapshot allocation | **Accepted**: in-place post-pass; resolves X13 U6. Caveat: kernel reads neighbours through the world getter, so out-of-window cells too — X13's patch is synthetic. |
| P6 | Fresh Python replay of 3 candidate formulas (`D05`, `TASK`, `SPEC04`) over all 19 vectors, two precision models | `D05/f32step` = **19/19**; `D05/double-from-bits` = 17/19; `TASK` = 16/19 | **Accepted**: D05 structure is the only formula consistent with all f32-step bits. The 2 extra double-model misses are input-decoding/cancellation artifacts, not formula divergence (§Vector verification). |
| P7 | Grid provenance search: locate each `g_bits` in both F02 and F01 windows at the declared cell | 19/19 match F02 cell; **0/19** match F01 cell; min/max match at both | **Accepted**: X13's min/max check could not discriminate; F01's size closure can. X13 offsets marked **stale**. |
| P8 | Re-parse `pattern.lib` fields for the 3 patterns; recompute 8×10 block means at F01 `G` | 13/13 flags/floats match X13 JSON; F01 block means reproduce F01 §4.10 tables (e.g. `hil1` row4 `0.220 0.796 1.880 3.133…`) | **Accepted**: config values are correct; only the grid-window start was wrong. |
| P9 | Compare X13 U6 / Open question 2 against P5 | X13 asked whether a second pass could settle update order; P5 did | **Accepted as RESOLVED**; no averaging of two models. |

---

## Authoritative formula table (ONE table — paste into spec §04 §6)

`p` = parsed pattern object; `+off` = struct offset in `sub_755f30`; `g` = raw
float32 grid sample at `p.heightGrid[row][col]` (`+0x28`, float stride 4, row-major
`grid[z][x]`); `base_h` = bilinear world-height sample at stamp centre
(`call 0x810498` @`0x756435`, stored as f32 at `[ebp-0x10]` @`0x75643a`);
`Scale` = `+0x48` (or `rand(+0x40,+0x44)` when `UseRndScale` `+0x3c`);
`Min` = `+0x5c`, `Offset` = `+0x64`, `TerrainScale` = `+0x68`. `Max` (`+0x60`) is
**not read**. Byte encodings quoted from E3.

| Path / selector | `g2` transform (before blend) | Final combine and store | Donor opcode evidence (VA; bytes where decisive) | Deep pseudocode lines (E2) | f32 vector confirmation |
|---|---|---|---|---|---|
| **`ReplaceForWater=true`** (`cmp byte [p+0x3b],0` @`0x756601`, `jne` taken) | `g2 = g * Scale` | `h_new = g2 + Offset` — `fld g` `0x75664b`, `fadd [p+0x64]` `0x756651` (`d8 40 64`), `fstp dword [esp]` → `setHeight` `call 0x7551a8` @`0x756664` | `0x75661f d945c0`, `0x756622 d84de0`, `0x756625 d95dc0`; `0x756645/649`, `0x75664b/651`, `0x756664` | 297, 301–302, 327–328 | 8/8 donor-flag vectors bit-exact in both precision models (X13 RVW-* and AXIS-*). |
| **`ReplaceForWater=false`, `Replace=true`** (`cmp [p+0x3b]` `0x756601` not taken; `cmp [p+0x3a],0` `0x75666e` not taken) | `g2 = (g − Min) * Scale + Min` — `fld g` `0x756607`, `fsub [p+0x5c]` `0x75660d` (`d8 60 5c`), `fmul [ebp-0x20]` `0x756610` (`d8 4d e0`), `fadd [p+0x5c]` `0x756616` (`d8 40 5c`), `fstp dword [ebp-0x40]` `0x756619` | `h_new = base_h + g2 + Offset` — `fld [ebp-0x10]` `0x756674`, `fadd [ebp-0x40]` `0x756677`, `fadd [p+0x64]` `0x75667d`, setter @`0x756690` | `0x756601`–`0x756628`, `0x75666e`–`0x756695` | 297–299, 321–323 | 4/4 synthetic-flag vectors bit-exact in `f32step` model; task literal fails `REP-hil1-01` (`0x4074F076` vs `0x40A5B75B`) and `REP-kr1-02` (`0x407DED61` vs `0x40C3527F`). |
| **default "Smooth" blend** (`ReplaceForWater=false`, `Replace=false`) | same pivot as Replace: `g2 = (g − Min)*Scale + Min` | `h0 = getHeight(c,r)` @`0x7566a0`; `t = (base_h − h0)*TerrainScale + g2 + Offset` (`fsubr` `0x7566a5`, `fmul [p+0x68]` `0x7566ab`, `fadd` `0x7566ae`, `fadd [p+0x64]` `0x7566b4`); `t` spilled **80-bit** (`fstp tbyte [ebp-0x154]` `0x7566b7`); `h1 = getHeight(c,r)` @`0x7566c7`; `h_new = t + h1` (`fld tbyte` `0x7566cc`, `faddp` `0x7566d2`), setter @`0x7566e4` | `0x756697`–`0x7566e9`; **two distinct** `call 0x7553a0` sites | 306–319 | 5/5 synthetic-flag vectors bit-exact in `f32step`; task single-read fails `SMB-kr1-02` (`0x401AB589` vs `0x3FA89E45`). |
| **Occupancy gate (applies to all three)** | — | `if (mask[row][col] != 0) continue;` — `cmp byte [eax+edx],0` `0x756638`, `jne 0x7566e9` | `0x756629`–`0x75663c` | 305 | not exercised by X13 single-cell vectors (UNVERIFIED U7). |

**Algebraic note [D]:** with the shipped `TerrainScale=1` and `h1≈h0`, Smooth reduces
to `base_h + g2 + Offset` — identical to Replace's *shape*, but the two `getHeight`
reads and the 80-bit `t` spill must still be preserved for exact replay. The
simplified task literal `base_h + g + Offset` is wrong for Replace whenever
`Scale≠1` (`hil1` Scale=0.65) and can differ by 1 ULP even at `Scale=1` with
negative `Min` (cancellation).

**Smooth post-pass (separate, gated by `Stand && Smooth`, not by blend branch)
[O]:** for interior cells whose own and all eight mask neighbours are 0
(`0x757077`–`0x757161`), remap `(tx,tz) = round(centre + (offset)*(Radius−Offset)/d)`
(`0x75717a`–`0x757243`), then `Factor` times (`[p+0x54]`, `0x757167`–`0x757170`):
`h(v,u) = (h(v,u−1)+h(v,u+1)+h(v−1,u)+h(v+1,u)) / 4.0f` with the divisor hardcoded
at `[0x755ee4]` (`0x755eaf`). E8 proves **in-place** read-after-write via
`getHeight`/`setHeight` on the same world field.

---

## Vector verification results

### 1. Independent formula replay (P6)

Fresh implementations written from the donor pseudocode, not from X13's
`build_vectors.py`. Expected bits read from `x13_blend_vectors.json`.

| Model | Reproduction of X13 expected column | Verdict |
|---|---|---|
| D05 F4, f32 round after each donor store (`d05_f32step`) | **19/19** | **Authoritative.** Every vector, all three paths. |
| D05 F4, decimal inputs → double → f32 at final store | 17/19 | Not a formula failure. |
| D05 F4, inputs decoded from their stored f32 bits → double → f32 at store | 17/19 | Misses `REP-kr1-01`, `SMB-kr1-01` only. |
| Task/spec §04 literal (`Replace = base_h+g+Offset`, single `h` read) | 16/19 | **Refuted** by `REP-hil1-01`, `REP-kr1-02`, `SMB-kr1-02`. |

Selected exact f32 checks (all values 8-hex f32 bit patterns):

| Vector | Path | `g` bits | D05 computed | X13 expected | Task literal | Winner |
|---|---|---|---|---|---|---|
| `RVW-hil1-02` | RFW | `0x40771F94` | `0x4020A153` | `0x4020A153` | `0x4020A153` | tie (Scale exercised, both agree) |
| `RVW-k_ravine_1-01` | RFW | `0xC03DAC13` | `0xC03DAC13` | `0xC03DAC13` | `0xC03DAC13` | tie |
| `REP-hil1-01` | Replace | `0x40771F94` | `0x4074F076` | `0x4074F076` | `0x40A5B75B` | **D05** |
| `REP-kr1-02` | Replace | `0x4048F2D0` | `0x407DED60`/`0x407DED61` | `0x407DED60`/`0x407DED61` | `0x40C3527F` | **D05** |
| `SMB-kr1-02` | Smooth | `0x2FB9E537` | `0x401AB589` | `0x401AB589` | `0x3FA89E45` | **D05** |
| `SMB-hil1-01` | Smooth | `0x40771F94` | `0x4074F076` | `0x4074F076` | `0x4074F076` | tie (h0=h1) |
| `AXIS-kr1-z1x0` / `AXIS-kr1-z0x1` | RFW | `0xBAAC7432` / `0xBA9D9F10` | identical | identical | identical | row-major confirmed (transposition discriminator) |

**Input-decoding caveat [D]:** X13's `d05_double` column uses the *decimal*
`base_h=2.964`, `1.31733`, `h0=−1.1` as exact doubles while storing their f32 bits
(`0x403DB22D`, `0x3FA89E45`, `0xBF8CCCCD`) separately. The f32 values are
`2.9639999866485596`, `1.317330002784729`, `−1.100000023841858`. When the inputs
are decoded from the stored bits, `REP-kr1-01`/`SMB-kr1-01` become `0x39C34000`
instead of X13's `0x39C341CB` — a 1-ULP input difference amplified by the
cancellation `base_h ≈ −Min`, **not** a 459-ULP arithmetic error. I07 should decode
all inputs from bit patterns and use the `f32step` column as the golden contract
until x87 80-bit is emulated (E6 `fstp tbyte` at `0x7566b7`).

### 2. Grid-offset cross-check (P7/P8) — X13's inputs are from stale windows

| Pattern | F02/X13 `G` | F01 true `G = 8+N` | Shift | min/max at F02 | min/max at F01 | Vector `g` matches declared cell |
|---|---:|---:|---:|---|---|---|
| `hil1` (25×41, N=960) | 1000 | 968 | +8 floats | bit-exact | bit-exact | F02 **5/5**, F01 **0/5** |
| `g_hil4` (33×59, N=1856) | 1912 | 1864 | +12 floats | bit-exact | bit-exact | F02 **3/3**, F01 **0/3** |
| `k_ravine_1` (46×63, N=2790) | 2866 | 2798 | +17 floats | bit-exact | bit-exact | F02 **11/11**, F01 **0/11** |

Exact size closure re-verified: `hil1` 55,948 B, `g_hil4` 108,020 B,
`k_ravine_1` 162,260 B, all = `8 + 4wh + 54N`; mask bytes `0/1` only in all three.
This independently confirms F01 (E13) and falsifies X13's acceptance of F02 `G`.
F01 correctly notes that min/max alone cannot discriminate (long zero borders),
which is exactly why X13's three-instrument pass P2/P3 was insufficient.

Consequences for the golden outputs (fresh D05 f32-step replay **at the true F01
cell**):

| Vector | X13 `g` (shifted) | X13 expected | F01-cell `g` | Corrected expected |
|---|---|---|---|---|
| `RVW-hil1-02` | `0x40771F94` | `0x4020A153` | `0x3E8F5C29` | `0x3E3A5E35` |
| `RVW-g_hil4-01` | `0x3FF55FDC` | `0x3FF55FDC` | `0x3D53C32A` | `0x3D53C32A` |
| `RVW-k_ravine_1-02` | `0x4048F2D0` | `0x4048F2D0` | `0x00000000` | `0x00000000` |
| `REP-hil1-01` | `0x40771F94` | `0x4074F076` | `0x3E8F5C29` | `0x3FBFEA0C` |
| `REP-kr1-02` | `0x4048F2D0` | `0x407DED61` | `0x00000000` | `0x3FF69F19` |

**These are regenerated test inputs, not new donor claims**; the *formula* is
unchanged. The transposition discriminators `AXIS-*` also change value at the true
offset and must be regenerated before I07 uses them as a spatial gate.

### 3. Post-pass update order (P5)

X13's 4/4 divergence is correct arithmetic but the wrong selection: E8 shows the
donor kernel reads four neighbours **from the live world field** and writes the
centre **to the same field** in nested `z`/`x` loops. At cell `(x,z)` the `x−1,z`
and `x,z−1` neighbours have already been updated; `x+1,z` and `x,z+1` have not.
Therefore the **in-place** column (`0x3E0E900E`, `0x3E1691C8`, `0x3E1AE70E`,
`0x3E1EB7C7`) is donor-shaped; the double-buffer column is a
`PORT APPROXIMATION`. The absolute snapshot bits remain synthetic: X13 used the
`g_hil4` grid as a stand-in world patch and an assumed `(dx,dz)=(1,0)` remap, so
they are not donor golden values — only the update *rule* is donor-derived.

---

## Stale-claim list

| # | Claim as circulated | Status | Authority |
|---:|---|---|---|
| S1 | spec §04 §6: `Replace = base_h + g + Offset` | **STALE / REFUTED** — omits `Scale` and the `Min` pivot | E2 lines 297–299, 321–323; E5; E6; §Vector verification |
| S2 | spec §04 §6 Smooth described with a single `h` read (`h += …`) | **STALE** — donor reads `getHeight` twice and adds `h1` last | E2 lines 311/317/319; E6 `0x7566a0`/`0x7566c7`/`0x7566d2`; X12 implication 3 |
| S3 | X13 E4–E6 / JSON `grid_start_byte` 1000/1912/2866 (F02/DPATTERN) | **STALE** — shifted +8/+12/+17 floats; use F01 `8+(w−1)(h−1)` | E13/E14; F01 §4.1/§4.4; §Grid cross-check |
| S4 | X13 U6 / R5 / Open question 2: in-place vs double-buffer "UNVERIFIED; I07 must choose" | **RESOLVED** — in-place read-after-write | E8; E9 |
| S5 | X13 R2/U5: on-disk plane start not provable ("many offsets give same min/max") | **RESOLVED by size closure** (weaker min/max argument stands) | E13; F01 §4.1/§4.2 |
| S6 | F01 §9 U7 "engine blend order … UNVERIFIED — no plaintext consumer" | **STALE** for the stamp: D05/X12/X26 decoded CODE consumers; remains true only for F01's own plaintext-only method | E2/E3; D05 F2/F4; X12 Claims 3–5 |
| S7 | X13 `d05_double` column treated as "primary" exact model | **CAVEAT** — decimal inputs vs f32 bit storage; cancellation amplifies 1-ULP input difference | §Input-decoding caveat; E6 `fstp tbyte` |
| S8 | X13 E8 "HeightFieldMax never read (no `[+0x60]` access)" | **CONFIRMED, not stale** — survives stricter second scan (0/6,751) | E7 |
| S9 | X12 Claim 2 `StandPattern → 0x6b28d8 → 0x75c228 → 0x755f30` (X12's correction of D05) | **CONFIRMED as the registration path**; not re-tested here beyond function anchoring | X12 E12–E14; outside X26 mandate |

---

## Implications for spec §04 and I07 (no source changed by X26)

**Spec §04 §6 replacement rows (ready to paste):**

| Path | Formula to publish |
|---|---|
| `ReplaceForWater=true` | `h_new = g*Scale + HeightFieldOffset` |
| `Replace=true` (with `ReplaceForWater=false`) | `h_new = base_h + ((g − HeightFieldMin)*Scale + HeightFieldMin) + HeightFieldOffset` |
| default Smooth | `h0 = getHeight(c,r)`; `t = (base_h−h0)*TerrainScale + ((g−Min)*Scale+Min) + Offset` (80-bit spill); `h1 = getHeight(c,r)`; `h_new = t + h1` |
| all paths | `if (occupancy[row][col] != 0) skip`; **no** `[Min,Max]` clamp; `Max` unused in the stamp |

**Spec §04 §3/§4 additions:** grid start `G = 8 + (w−1)*(h−1)` with F01 §4.10
corrected tables; the 8×10 tables are preview aids only, stamp from the full
`wh` float plane. Stamp call chain per X12 implication 4.

**I07 actions (ordered):**

1. Implement the three branches exactly as the authoritative table; preserve the
   two `getHeight` reads in Smooth and the fact that `g2` and `base_h` are f32
   stored before the final add. Label the operations `DONOR-DERIVED [O]`; label
   row-flip, global clamp, rotation rounding and x87 exactness
   `PORT APPROXIMATION`.
2. Decode `g` from the F01-correct grid offset, **not** X13's F02 offsets.
   Regenerate all 19 vectors (including `AXIS-*`) at `G=8+N` before using them as
   a gate; the current JSON is valid only as a *formula* harness.
3. Use the f32-step column as the bit-exact contract; decode every input
   (`base_h`, `h0`, `h1`, `Offset`, `Scale`) from its stored bit pattern, not the
   decimal literal. Treat 1-ULP differences as unresolved x87, not as a bug.
4. Post-pass: in-place, `Factor` iterations, hardcoded divisor `4.0`, gate on
   `Stand && Smooth` **independent of the blend branch** (so `g_hil4` gets it even
   though it is `ReplaceForWater=true`), 8-neighbour mask test, radial remap.
5. QA: expose the debug entry proposed by X13 implication 3; keep all gates
   (`selftest 29/29`, `uitest 17/17`, `t_render_mode`, `assert_clean CLEAN`,
   `app/**` byte-identical) unchanged; keep `parity.status="UNVERIFIED"`.
6. **No donor parity claim.** Nothing here is a rendered A/B frame.

---

## UNVERIFIED register

| ID | Claim | Status / passes attempted |
|---|---|---|
| U1 | File row `v` → signed world y (row-sign flip) | **[U]** D05 U1 / X13 U1; P2/P3 bind row→`z` but not file-row sign. `PORT APPROXIMATION`. |
| U2 | Global `setHeight` clamp / map-wide ceiling (`sub_0059b934`) | **[U]** D05 U2/R4, X12 U2; zero `[+0x60]` reads inside the stamp (E7) do not exclude a setter clamp. |
| U3 | True x87 80-bit result | **[U]** E6 shows `fstp tbyte [ebp-0x154]` at `0x7566b7` for Smooth `t`; double and f32 models diverge on 5/19 vectors (X13 P5) and 2 more under bit-decoded inputs. No 80-bit emulator attempted. |
| U4 | Exact rounding of rotated sub-cell coordinates / jitter | **[U]** D05 U3; rotation block `0x75646e`–`0x7565d5` seen at opcode level only; all vectors use `RotationAngle=0`. |
| U5 | Donor incidence of `Replace=true`, `TerrainScale≠1`, `Offset≠0`, `h0≠h1` | **[U]** 0/680 `Replace=true` (F02/X05); 11/19 vectors use synthetic flag overrides — labelled `PORT APPROXIMATION`, not donor incidence. |
| U6 | Smooth post-pass mask gating and full radial remap over all stamp cells | **[U]** kernel order settled (E8) but X13 snapshots used one remapped window and a synthetic patch; the 8-neighbour test at `0x757077`–`0x757161` was read, not runtime-exercised. |
| U7 | Occupancy gate interaction with `PatternMask*` flags at `0x756638` | **[U]** inherited D05 U6 / X12 U6; gate confirmed, flag semantics not. |
| U8 | Which of the five stamp call sites is map-generation vs editor/brush | **[U]** inherited X12 U10; not attributed to game phases. |
| U9 | Visual parity with donor | **[U]** no donor GPU A/B frame. **No parity claim.** |
| U10 | Whether editor/brush paths read `HeightFieldMax` | **[U]** E7 proves absence only inside `sub_755f30`; inherited X12 Open question 4. |
| U11 | `base_h` bilinear sample exact inputs (`sub_810498`) | **[U]** call site and f32 store verified (E4); world height field not recovered, so all `base_h/h0/h1` values are constructed test inputs. |

---

## Open questions

1. Can an 80-bit x87 emulator reproduce the two cancellation vectors
   (`REP-kr1-01`, `SMB-kr1-01`) bit-exactly, and does the `fstp tbyte` spill at
   `0x7566b7` make the Smooth result differ from both Python models?
2. Does `sub_0059b934` (global setter) clamp to a map-wide ceiling/floor — the
   likely home of the baked `−2.964` bound (D05 Q1 / X12 Q1)?
3. Once I07 regenerates vectors at F01 `G`, can the `AXIS-*` discriminator be
   promoted from advisory to a hard spatial gate?
4. Which of the five `sub_755f30` call sites serves skirmish map generation, and
   does any of them pass a non-zero `param_3` that changes the blend?
5. Are there donor sections with `Replace=true` or nonzero `Offset` outside the
   680 audited ones, so synthetic vectors can be replaced by donor-flag ones?
6. Does the 8-neighbour mask gate need to be applied *before* the radial remap for
   the post-pass, and is the remap centre in world or pattern coordinates once
   rotation is nonzero?

---

*End of X26 report. Exactly one repository file written. Donor read-only via pinned `document=`; no donor binary executed or copied; no source, asset, config, test, git or Godot change; active Craft Anything target unchanged; no donor visual parity claimed.*
