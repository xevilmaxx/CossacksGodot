---
id: WATER-STATIC-SCALARS
worker: WATER-STATIC (subagent, full 1:1 Cossacks 3 donor port)
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
labels: [O, D, I, U]
scope: "One file only. Read-only static decompilation. No code/Godot/git/donor-execution; no other edits."
upstream: "water3d.gd water_scalar_source UNSET [U4*] hard-fail; DEC_U_water_shader_deep.md; DEC_U12_deep.md; U4* packet (DEC_U_water_scalar_select.md)"
parity: UNVERIFIED
---

# WATER_static_scalars — can ANY water scalar be bound from static data alone?

## 0. Verdict (read first)

**No.** No part of the live water scalar tuple (S1–S11 + W0/W1, shader slots
`C+0x88..+0xc4` / `C+0xb4` / `C+0xbc`) can be bound from byte-proven donor
static data alone. Every live scalar **irreducibly requires runtime** `[U]`.
The `water_scalar_source UNSET [U4*]` hard-fail in `water3d.gd` (no water
drawn) is therefore **correct and must be kept**. No fallback is proposed, no
value is wired, no scalar is invented.

- Parity: **UNVERIFIED**. Chain: **0/6**. **RESULT IS NOT GOOD.**
- Exactly one file written: this report. No code, shader, asset, config,
  Godot, git, or donor-execution change.

## 1. Pin verification `[O]`

`core_target_open` on `C:\Games\Cossacks 3\cossacks.exe` returned:

- `target_id: t_87f0f3c130b0`, `kind: pe`, `bytes: 5768048`
- `sha256: 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`

Pin matches. Session mode: Deep, `clean_room: false`, engine `0.6.1`.
All reads below are static (no donor execution, no GPU capture, no file
write to the donor).

## 2. What was studied (allowed tools only) `[O]`

Per ticket discipline: `core_target_open` + `native_function_study` (the only
`native_*` tool used) + `core_feature_find` + `core_evidence_browse` +
repo/donor-side read-only text reads. No `native_bytes_find`,
`native_bytes_show`, `native_xrefs_list`, or Deep re-lift was used.

| # | Study | Evidence |
|---|---|---|
| F0 | `native_function_study(0x851bdc, summary)` — FUN_00851bdc dossier: 4 blocks, 17 insns, 3 callees, 2 callers, 0 strings | `ev_6e4fc45eace586ea227bab873f675ffb960dbd80e778769176f4448353f5c75a` |
| F0-asm | assembly page of F0 (17/17 rows) | `ev_f63f9768b6bf7b4c131cf6f9039d636b976e249b0774f7bc200452e76e100d7f` |
| F0-callers | callers page: `sub_8519f4` @ `0x851c48`, `sub_851c5c` @ `0x851c70` | `ev_994859c3cb167bac8c3724faa045401ec4956e3f1f5188057e795bc706d4517` |
| F0-callees | callees page: `call 0x852f5c` @ `0x851beb`, `call 0x852284` @ `0x851bfc`, `call 0x856080` @ `0x851bf5` | `ev_4e36bca2e0140da2748c8a29f4ee92707f42b6529257c7004c12eb2f` |
| F1 | `native_function_study(0x851c5c, summary)` — caller wrapper: 1 block, 13 insns, 2 callees, 4 callers, 0 strings | `ev_d56f418e1c226a2cc76d2a0ef27716c34189f5c734b49b620c29ace0d5787a` |
| F2 | `native_function_study(0x8519f4, summary)` — second caller: 40 blocks, 201 insns (linear decode misaligns past entry; see §3) | `ev_2b030b865dc83177f7eeda61bc13877fb8474bfdda0d4e1484c128720fc854a9` |
| F3 | `native_function_study(0x852f5c / 0x856080, summary)` — FILE-copy arm and ENGINE-ctor arm | **`function_not_found`** in the built-in engine DB (both addresses undiscovered; see §3) |
| Q | `core_feature_find` for `reflectionAmount`, `texScaleS`, `WaterShaderVP`, `reflectionMap`, `water.lib`, `hmapTex` | **0 hits each** (inline null results, no evidence rows) |
| T | donor text re-reads: `data/water/water.lib`, `data/scripts/common.inc/texturemap.inc`, `data/scripts/common.inc/generatemap.inc` (`cWaterFieldSize`/`cOffsetY` region) | repo/donor-side read-only; §4 |

## 3. FUN_00851bdc and callers/callees — no static scalar `[O]/[D]`

### 3.1 The branch itself (assembly verbatim from `ev_f63f…`)

```
0x851bdc push ebx
0x851bdd mov ebx, eax
0x851bdf mov eax, edx
0x851be1 mov [ebx+0xc], eax
0x851be4 test eax, eax
0x851be6 je 0x851bf2
0x851be8 mov edx, [ebx+0x10]
0x851beb call 0x852f5c        ; layerPtr != 0 -> FILE layer copy
0x851bf0 jmp 0x851bfa
0x851bf2 mov eax, [ebx+0x10]
0x851bf5 call 0x856080        ; layerPtr == 0 -> ENGINE ctor defaults
0x851bfa mov eax, ebx
0x851bfc call 0x852284
0x851c01 mov edx, [ebx+0x10]
0x851c04 mov [edx+0x130], al
0x851c0a pop ebx
0x851c0b ret
```

`[D]` consequences:

1. The function contains **zero float literals, zero string references, zero
   static scalar constants**. The only decision is `test eax, eax` on the
   caller-supplied layer pointer (`edx` on entry, stored to `[ebx+0xc]`).
   There is **no FILE-vs-ENGINE selector constant** in this function — the
   selector IS the runtime pointer value (0 vs nonzero).
2. Nothing in `C+0x88..+0xc4` / `C+0xb4` / `C+0xbc` is materialised here; both
   arms delegate to callees. Hence this function alone can never supply a
   byte-proven scalar.
3. Post-branch tail (`call 0x852284`, store `al -> [edx+0x130]`) is a
   status/flag write, not a scalar source.

### 3.2 Caller `sub_851c5c` (assembly verbatim from `ev_d56f…` page)

```
0x851c5c push ebx / push esi
0x851c5e mov esi, edx
0x851c60 mov ebx, eax
0x851c62 mov edx, esi
0x851c64 mov eax, [ebx+8]
0x851c67 call 0x853530
0x851c6c mov edx, eax          ; layer ptr = RETURN VALUE of 0x853530
0x851c6e mov eax, ebx
0x851c70 call 0x851bdc
0x851c75 pop esi / pop ebx / ret
```

`[D]` The pointer tested by FUN_00851bdc is the **runtime return value** of
`sub_853530` (a lookup/parsing routine taking `[ebx+8]`). Whether it returns
0 or a nonzero layer address depends on runtime parsing state (water.lib
layer table construction). `[U]` No static read in this ticket resolves that
return value; no constant is pushed, no literal pool is referenced.

### 3.3 Caller `sub_8519f4` — not statically analysable with allowed tools

The built-in linear decoder misaligns immediately past the entry
(`inc eax; sbb al,[ebp]; add [eax],al…` — data decoded as code), the same
garbling that caused the prior `ev_d41c…` pseudocode to be rejected. `[D]`
No argument-source or float-literal fact can be recovered from this caller
through `native_function_study` alone. (Prior tickets recovered surrounding
context only via Ghidra/Deep lifts, which are re-cited records, not new byte
proofs of a scalar.)

### 3.4 Callees `0x852f5c` / `0x856080` — undiscovered in the built-in DB

Both return `function_not_found` (no discovered function at those addresses
in engine `0.6.1`). `[D]` This matches the known discovery gap already
recorded for this binary family (cf. `DEC_U12_deep.md` §2.2: neighbouring
`0x4ed38c` gap). Consequence for THIS ticket: the ENGINE-side ctor floats
(`0.4/0.3/4/0.1/0.5/1/0.05/2/0.01/0.4/0.825`, `C+0xac/+0xb0 = 0.4/0.825`)
and the FILE-side whole-block copy walk could **not** be re-verified from
new bytes with the allowed toolset. They remain **re-cited pinned records**
(`ev_5aae…`/`ev_d927…`, `ev_513e…`, `ev_67a5…`), sufficient to define the two
candidate tuples, but **not** new byte-proven bindings — and they cannot
select between the tuples anyway (each arm is unconditional within itself).

### 3.5 `core_feature_find` null results `[O]`

`reflectionAmount`, `texScaleS`, `WaterShaderVP`, `reflectionMap`,
`water.lib`, `hmapTex`: 0 strings / 0 functions / 0 imports / 0 function
names each in the built-in DB. `[D]` With the ticket-allowed static surface,
**no scalar name, uniform name, or descriptor string resolves to a code
site**, so no uniform-location hook or slot constant can be grounded
statically this ticket. (Prior tickets found these only via Deep/Ghidra +
packed-byte scans that are out of scope here; those remain re-cited, not
re-proven.)

## 4. Donor text cross-check — FILE candidate enumerated, selector absent `[O]/[D]`

Read-only re-reads (no donor execution):

- `data/water/water.lib :21-42` — FILE layer block verbatim: `ReflectionAmount
  = 1`, `WaterAmount = 1`, `FresnelPower = 1`, `FresnelBias = 1`,
  `HDRMultiplier = 1`, `WaveFreq = 0`, `WaveAmp = 0`, `DistFactor = 1`,
  `BumpFactor = 1`, `TexScaleS = 0.1` (:32), `TexScaleT = 0.01` (:33),
  `WaveDir0 (-1, 0)` (:34-36), `WaveDir1 (-0.7, 0.7)` (:38-40),
  `Speed = 1.0` (:42); `CustomEnable = False` (:51),
  `HeightMapEnable = True` (:60), `LayerCount = 1` (:50),
  `DefaultWaterIndex = 0` (:65). Commented-out `//TexScaleS = 0.115`,
  `//TexScaleT = 0.015` (:30-31) are inert.
- `data/scripts/common.inc/texturemap.inc :29-31` — classification only:
  `cMaxHeight = 2.96`, `cWaterHeight = -0.25`, `cWaterShoreHeight = -0.1`.
  Script-stage classification literals; **absent from water.lib** (no
  `MaxHeight` key), never `hmapMin/Max` uniforms.
- `data/scripts/common.inc/generatemap.inc :649-650, :688-704` — geometry
  only: `cWaterFieldSize = 2`, `cWaterMapArrSize = 640 div 2`,
  `cOffsetY = -0.5`, field raster + `WaterFieldAdd` centre formula. No
  scalars.
- `data/water` grep for `ReflectionAmount|FresnelPower|WaveFreq|DistFactor|
  BumpFactor|TexScale|WaveDir|Speed|CustomEnable`: hits **only** the
  `water.lib` lines above — no second file, no alternate tuple, no selector.

`[D]` Donor text enumerates the FILE candidate tuple and the
classification/geometry literals already transcribed in the port, but contains
**no FILE-vs-ENGINE selector**: no flag, no `DefaultWaterIndex`-driven branch
text, no "live tuple" annotation. `LayerCount = 1` / `DefaultWaterIndex = 0`
prove a parsed layer *exists structurally*, not that the retail water-draw
call passes it nonzero. Selection stays runtime.

## 5. Per-scalar verdict table — live binding all `[U]`, nothing `[D]`-live

`Static` = byte-proven donor static datum re-verified or re-cited this
ticket. `Live` = value actually bound at draw. Only `Live` matters to the
hard-fail, and every `Live` cell is `[U]`.

| # | Scalar (slot) | Static datum | Live verdict |
|---|---|---|---|
| S1 | reflectionAmount (`C+0x88`) | FILE `1` `[D]`-as-candidate (water.lib :21); ENGINE `0.4` re-cited (unre-liftable here) | `[U]` — needs `FUN_00851bdc` ptr + `glUniform1f` capture (U4*-CORE) |
| S2 | waterAmount (`C+0x8c`) | FILE `1` `[D]`-candidate (:22); ENGINE `0.3` re-cited | `[U]` — same capture |
| S3 | fresnelPower (`C+0x90`) | FILE `1` `[D]`-candidate (:23); ENGINE `4.0` re-cited | `[U]` — same capture |
| S4 | fresnelBias (`C+0x94`) | FILE `1` `[D]`-candidate (:24); ENGINE `0.1` re-cited | `[U]` — same capture |
| S5 | hdrMultiplier (`C+0x98`) | FILE `1` `[D]`-candidate (:25); ENGINE `0.5` re-cited | `[U]` — same capture |
| S6 | waveFreq (`C+0x9c`) | FILE `0` `[D]`-candidate (:26); ENGINE `1.0` re-cited | `[U]` — same capture |
| S7 | waveAmp (`C+0xa0`) | FILE `0` `[D]`-candidate (:27); ENGINE `0.05` re-cited | `[U]` — same capture |
| S8 | distFactor (`C+0xa4`) | FILE `1` `[D]`-candidate (:28); ENGINE `2.0` re-cited | `[U]` — same capture |
| S9 | bumpFactor (`C+0xa8`) | FILE `1` `[D]`-candidate (:29); ENGINE `0.01` re-cited | `[U]` — same capture |
| S10 | texScaleS (`C+0xac`) | FILE `0.1` `[D]`-candidate (:32); ENGINE `0.4` re-cited. `0.01` is embedded-VP source default, NEVER live | `[U]` — needs U4*-S10/S11 capture |
| S11 | texScaleT (`C+0xb0`) | FILE `0.01` `[D]`-candidate (:33); ENGINE `0.825` re-cited. `0.02` is embedded-VP source default, NEVER live | `[U]` — needs U4*-S10/S11 capture |
| W0 | waveDir0 (`C+0xb4`) | FILE `(-1, 0)` `[D]`-candidate (:34-36); ENGINE slot unenumerated | `[U]` — needs U4*-W0/W1; ENGINE select must keep hard-failing on null dirs, no invention |
| W1 | waveDir1 (`C+0xbc`) | FILE `(-0.7, 0.7)` `[D]`-candidate (:38-40); ENGINE slot unenumerated | `[U]` — needs U4*-W0/W1; same null-guard |
| SP | Speed (`C+0xc4`) | `1.0` both arms (re-cited converge) | `[D]` path-insensitive — **not part of the UNSET gate**; no selection needed |
| C1/C2 | Deep/Shallow colours (`C+0x68`/`C+0x78`) | `(0,0,0.1255,0.5)` / `(0,0,0,0.5)` both arms (re-cited converge) | `[D]` path-insensitive — **not part of the UNSET gate** |
| CE | CustomEnable (`C+0x184`) | `False/0` both arms (water.lib :51 re-verified) | `[D]` — CUSTOM unreachable; **not part of the UNSET gate** |
| surface_y / levels | `cOffsetY -0.5`, `cWaterHeight -0.25`, `cWaterShoreHeight -0.1`, `cMaxHeight 2.96` | `[D]` classification/geometry (text §§ above) | Not live uniforms; `2.96` is NOT `hmapMin/Max` (stays `[U3]` substitute, labelled) |

`[D]`-as-candidate means: the FILE number is byte-proven to *exist* in the
donor, but its *liveness* is unproven. Presenting any FILE number as the live
uniform without the U4* capture would be fabrication. The ENGINE numbers are
additionally single-source re-cites this ticket (built-in DB gap, §3.4).

## 6. Why static binding is impossible here (not just absent) `[D]/[I]`

1. The branch condition is a **runtime data value** (pointer produced by
   `sub_853530`), not a constant, version flag, or config key. No static
   pass over any caller can fold it.
2. Both arms are **atomic whole-block writers** (re-cited `ev_513e…` /
   `ev_5aae…`); there is no per-scalar static path to cherry-pick even if
   one arm were statically preferred.
3. The ENGINE arm's waveDir slots are **unenumerated** — even an
   "assume ENGINE" choice cannot produce a complete tuple without inventing
   two vectors. Invention is forbidden.
4. Donor text contains the FILE tuple but **no selection rule**, so text
   alone cannot promote FILE to live either.

## 7. Required port behaviour (no change — owner acts only after capture)

1. Keep `_water_scalar_source = UNSET`, `build()` refusal
   (`water_scalar_source UNSET [U4*] … no water drawn`), and the ENGINE-dir
   null-guard. Do NOT default to FILE or ENGINE.
2. Keep `BUILTIN_TEX_SCALE_S/T = 0.01/0.02` labelled EMBEDDED-SOURCE-DEFAULT,
   never as live uniforms.
3. Owner-only runtime capture (standing rule, forbidden to workers):
   break `FUN_00851bdc @0x851bdc`, record layer ptr, dump `C+0x88..+0xc4` +
   `C+0xb4/+0xbc`, hook `glUniform1f/2f`; 0-ULP / 0-mismatch over 2 frames +
   camera move (U4* packet). Nothing in this report substitutes for it.

## 8. Non-claims and discipline

- No parity claim. No donor execution, no GPU capture, no port comparison.
- No approximation substituted; no scalar guessed or defaulted.
- Read-only compliance: one repo file written (this report). No
  code/shader/asset/config/Godot/git change. No donor file written or
  executed. Investigation memory untouched (reads only; no brief/plan/
  hypothesis/finding/handoff writes).
- Prior Deep/Ghidra records are re-cited with explicit provenance (§2–§3);
  nothing lost was reinvented — gaps are marked not recovered.

*End WATER_static_scalars. Parity UNVERIFIED, chain 0/6, RESULT IS NOT GOOD.*
