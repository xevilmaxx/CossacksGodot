---
id: DEC-U-NB7-2026-11-27
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-NB7 — class-B NB-7 S0 kernel-body trace (Deep-decoder pass on 0x6a3900–0x6a3b80 + VM-dispatch check via sub_608238)"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_nb7.md
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_GODOT_GIT_DONOR_EXEC
created: 2026-11-27
labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
parity_guard: "NO DONOR PARITY IS CLAIMED. No same-camera donor/port A/B frame was produced or examined. Every donor statement is a read-only byte/line observation; every port statement is a read-only source line. No behaviour is closed by a port fallback."
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
scope_guard: "Exactly one repo file written (this report). No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod state changed. Donor binary and donor data tree READ-ONLY; donor executable never run, no donor bytes copied into the repo. Singleplayer skirmish only."
donor_pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe (PE x86, 5,768,048 B on disk; sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c, Deep mode, shared Craft Anything session). Every native call with document=t_87f0f3c130b0. Binary never executed."
prior_reports_read:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_b_angle_index.md (NB-7 definition §3: byte-proven kernel dump via computed-pointer-respecting trace, not string-xref)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_smooth_kernel_deep.md (DEC-U-SMOOTH-KERNEL-DEEP: SmoothTerrain 2 CODE hits 0x6a395a/0x6a3b12, MapGeneratorSmoothTerrain 1 hit 0x6a394e, wrapper table 0x6a3390–0x6a3e6e, mb:Integer correction, function_find miss + 0 xrefs under computed-pointer limit)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_place_seed_deep.md (U-KEY: native_function_find 0x69f452/0x60a662 not-inside-any-function; no b9/pointer-string hit — D02 Anomaly D, X51-E4)
---

# DEC-U-NB7 — S0 kernel-body trace (Deep-decoder window + VM-dispatch check)

> READ-ONLY. Singleplayer skirmish only. No parity claim. No approximation.
> `[O]` = observed donor bytes/lines verified by a second read pass. `[D]` = arithmetic/control-flow over cited `[O]`. `[I]` = reading without runtime proof. `[U]` = unresolved after the passes here.
> `ev_*` below are Craft Anything evidence ids on `t_87f0f3c130b0` in this turn (not port test ids). "Address" = donor VA (`0x…`).
> Task: class-B candidate NB-7 from `PORT1TO1_b_angle_index.md §3` — S0 kernel-body trace. Try the engine Deep decoder on the CODE windows around `0x6a3900–0x6a3b80` (builtin linear decode may misalign): identify any local array/loop that reads neighbouring height bytes and writes the centre; recover radius/sample count/weights only if byte-proven; check whether the function is VM-dispatched via `FUN_00608238` (= `sub_608238`) like randkey APIs. If no body is recoverable, state exactly why and keep S0 `[U]` with the 320²+640² hook byte-dump zero-mismatch experiment. No invented blur/kernel; no parity claim.

## 0. Method — multiple NEW passes on the pinned packed exe

| Pass | Operation (read-only, `document=t_87f0f3c130b0`) | Result |
|---|---|---|
| P1 | `native_bytes_show 0x6a3900+640` | ev_a72cd3e69799aff76618ac3e3fc4ee774e120345a92715b5e536495886c276fa — 640 B ASCII registration strings (`ResetPatternMap` … `RandomHeightTe`), file_off `0x2a2d00` [O] |
| P2 | `native_instruction_show 0x6a395a` + `native_function_find 0x6a395a` | ev_e1e38601b16e2ae10a6589b087417159c1f47d48f466a663b371e089c031cdd0 (`push ebx`, 1 B `0x53`) + ev_1ec212956a4952daf3e1769fe3b2241f4393877b19513348444d6f986d4aed6a (not inside any discovered function) |
| P3 | `native_bytes_show 0x6a3a80+896` + `0x6a3b80+512` + `native_data_show 0x6a395a` + `native_xrefs_list 0x6a395a` | ev_4ff60600d47557baaf9fefe188c787d0537a2c01e4993572de89edb6ef47511b (Plateau/Smooth/RandomHeight/Paint/GetHeightData/SetHeightData strings) + ev_ee217f95f1cb6b7c77d5755ddf63d8f0a34624a8d15546ba93fb12077d21f607 + ev_4f49eceb0fc344170184463d1996001fc1e1f37e2a3c5bc2d83a1bf5b631f029 (u32 `0x6f6f6d53` = ASCII `Smoo`, 0 refs) + ev_3021557ce34f71871eab5d8e44531fd30d8233e1c6b960494ea70db904156ea2 (0 xrefs, computed-pointer reserve) |
| P4 | `native_functions_search 608238` / `Smooth` / `FUN_00608238` + `native_xrefs_list 0x608238` + `native_instruction_show 0x608238` | ev_e654ee12230171dcd231cad0ce764b5f6b522c06c8da8a133b8be8f29fd6475c (1 fn `sub_608238`, size 5291) + ev_36df920925cfd58b59354877356ab739457788404447eaf1b73d7c20a710c7dc (0 fns match `Smooth`) + ev_195133be6fde13cd90607b42397c76e62e4d0a1491d449c5fb9e2701594c7ece (0 match `FUN_00608238` literal) + ev_7875753c3845a58110cb981286240a5deaa71b6ffd7514ad0e2d1eb011c67d8d (1 caller `sub_706880` @ `0x70691d`) + ev_06664a9093e6de771404eaa5dca91beeb9a52b50c8e5f4219e8443a72e8170f5 (`push ebx` @ entry) |
| P5 | `native_function_study 0x608238 summary` + `native_bytes_find GenerateMapRandKey/SetRandomKey` + `native_function_find 0x69f452/0x60a6b2` | ev_7e20303d808711477b3583514229638307108d27961d070422053f0438a5a650 (1 block, 1559 insns, 331 callees, 297 unresolved-indirect, 0 strings) + ev_bb534909773590daf6239f352d4b8dfa5ce1847861e582c16cb664f9a0b67b88 (`GenerateMapRandKey` exactly 1 CODE hit `0x69f452`) + ev_5cc4b3b817e1b22b3a79bcb15df10eba8292e638c28d619782593c0ef87a0a3d (`SetRandomKey` exactly 1 CODE hit `0x60a6b2`) + ev_c33fb90fcba3e1037164410b5b56a5544bc21db29c29b8d5bb1e171de727abbb / ev_b6743a5370f2bc610908badbfbd4dbe209cd63decff61726423454d2a86b45c0 (both not inside any discovered function) |
| P6 | `core_evidence_browse callees[0:60]` of sub_608238 + `native_xrefs_list 0x69f452/0x60a6b2` | ev_fa6623642f4b492541db74e10f1b1f397db980552e196f2e5a1c70fbb0cb498f (60/331 rows: every site `call dword ptr [esi+0x30]` after `mov ecx,<tableVA>; mov edx,<nameVA>; mov eax,ebx; mov esi,[eax]`) + ev_4b97461f9809bfe911846c6cdeef8725bb1a9514fdb6d137fcc48ccfd9783e34 / ev_6f1a05c1c7b9ba85fc486cc202b0825eec0d3f9fdd8a705ce9888edd785aee0e (both 0 xrefs, computed-pointer reserve) |
| P7 | Deep-decoder misalignment test: `native_instruction_show 0x6a3900/0x6a394e/0x6a3b12/0x6a3c60` + LE-pointer `native_bytes_find 5A396A00/4E396A00/123B6A00` | ev_d034922fa582435fe661593520deb33fdc6b083e3ca893a2c36cac859a7c4e8e (`popad` 1 B `0x61`) + ev_818bf74e73e39fbc4510c589bb9d1c25d0b6c2942fc2383682cfba30d38e4ec7 (`dec ebp` 1 B `0x4d`) + ev_5c2e4493f636b103fda6655d77b5ffda60445ec62682175bb3310efe9845e89c (`push ebx` 1 B `0x53`) + ev_afe661ec29e6a2a5ba6a57ad570bd9e2c12001e416bac5afcf3c7f83e1fc69eb (`jns 0x6a3c8e` 2 B `79 2c`) + ev_2591266cc468a1e9b8404996cca96f32fa3199811793ef13aca7df1426a48517 / ev_cb18c4964e2d51507fa58f51ad9cc62084b68cdbac7b50ab8b31e3eb9cb33cca / ev_c2e404577f7ec8591dc900d0a2ba77ae41ca8fe4eacce9a1a189388e986c9df4 (all three LE-pointer patterns **0 matches** image-wide) |
| P8 | Window bounds: `native_bytes_show 0x6a3e6e+512` + `0x6a3300+240` + `native_instruction_show 0x6a3e6e` + `native_xrefs_list 0x6a3b12/0x6a394e` | ev_63f07686a6417cb25aa236b661a1d99bfd567e0e0884b5e236278227880ce51a (table continues: `TerrainUpdate…FindUniqId…PutDecal…`) + ev_009142b4553b222553371b58066922c63a1ee26463351eb005ba9e582ca108c2 (table start: `LoadPatterns/UnloadPatterns/MapGeneratorSmoothTiles…`) + ev_e07a982eed6fd95006896a50e7fa303603b55b9e4e4f01e682e39db8b4929980 (`push esp` 1 B `0x54` = `T` of `TerrainUpdate`) + ev_594b041b3966009c5d13ae8d2b0b4df207e73c6d8315c3abe43afb68a92555cf / ev_7cc972e4a325abc7bb2c33aac985714b9551528fb6ec99fc853d71823468ecc1 (both 0 xrefs) |

**Strange-read log:** `native_function_find` miss carries "the address may be in code the engine didn't discover (absence is not proof)". Every `native_xrefs_list` 0-hit carries "references made through computed pointers at run time are not seen". `native_functions_search` carries "function discovery stopped after 6000000 instructions; the function list is incomplete and some code is not analysed". `native_function_study` pseudo-C is "a reading aid built by the clean-room lifter, not compiler output" with "variables are machine registers and stack slots; types are not recovered". `native_objdump_run disassemble` was attempted and refused (`engine_missing`: objdump not installed) — no objdump lane available in this session. No donor binary executed; no donor bytes copied. `native_bytes_find` covers stored file bytes; packed/encrypted regions unseen (prior reserve stands, not re-measured here).

## 1. Deep-decoder result on `0x6a3900–0x6a3b80`: still table, not code [O/D]

[O] All three task-window VAs decode as **single ASCII bytes misread as 1-byte instructions**, byte-proven against the P1/P3 hex:

- `0x6a3900` = `0x61` (`a` of `…an…`) → lifter `popad` (ev_d034922f… vs ev_a72cd3e6…).
- `0x6a394e` = `0x4d` (`M` of `MapGeneratorSmoothTerrain`) → lifter `dec ebp` (ev_818bf74e… vs P1 ASCII `procedure MapGeneratorSmoothTerrain(const x, y, passes: Integer; const radius: Float)`).
- `0x6a395a` = `0x53` (`S` of `SmoothTerrain`) → lifter `push ebx`; `native_data_show` types it u32 `0x6f6f6d53` = `Smoo` with 0 refs (ev_e1e38601…/ev_4f49eceb…).
- `0x6a3b12` = `0x53` (`S` of second `SmoothTerrain` registration) → lifter `push ebx` (ev_5c2e4493…).
- `0x6a3e6e` = `0x54` (`T` of `TerrainUpdate(const terrainupdate…`) → lifter `push esp` (ev_e07a982e… vs ev_63f07686…).

[D] The "builtin linear decode may misalign" hypothesis is therefore **confirmed in the strong sense**: any instruction listing that starts *at* a table-string VA is guaranteed garbage — the bytes are Delphi DScript-API registration strings (`procedure …/function …` + `ffffffff <len> <text> 00` framing, P1/P3/P8), not opcodes. The Deep engine (builtin `0.6.1`, `clean_room=false`, Deep mode) agrees with the Clean-room lifter here: `function_find` = null at all three VAs, section = `CODE`, `function` = null on every `instruction_show` in the window. There is **no local array, no loop, no height-byte load (`movzx`/`mov al,[…]`), no centre store, no counter/stride literal** anywhere in `0x6a3900–0x6a3b80` — because the window contains zero code bytes to analyse. Stepping the decoder forward one byte at a time cannot recover a kernel; it only walks the string table (`ResetPatternMap → MapGeneratorSmoothTerrain → Raise/Lower/Plateau/Smooth/RandomHeightTerrain → PaintTerrain → GetHeightData/SetHeightData → …`, P1/P3/P8).

[O] Window bounds re-proven: backwards `0x6a3300+240` is still table (`LoadPatterns/UnloadPatterns/MapGeneratorSmoothTiles`, ev_009142b4…); forwards `0x6a3e6e+512` is still table (`TerrainUpdate/FindUniqId/PutDecal/DestroyDecal/SetVisibilityCulling…`, ev_63f07686…). The contiguous registration run is at least `0x6a3300–0x6a3e6e+` (>3 KB of strings). No code island was found inside it by any pass here.

[D] Radius/sample-count/weights: **nothing byte-proven, nothing recovered.** The only Float-radius literal in the whole run remains the *unused-by-S0* `MapGeneratorSmoothTerrain(x, y, passes; radius: Float)` signature string (prior `[D]` stands). The S0 `3` remains `mb: Integer`. No divisor, no `shr/div`, no `0.11/0.25/9-constant`, no 3×3/5×5 offset table, no `GetHeightData`/`SetHeightData` call edge into a kernel was observed from this window — because no call edge originates in string data. Any blur/box/gauss/lerp weight attached to S0 would be invention. Explicitly **not** recovered: neighbour topology, loop bounds, stride, `mb=3` semantics, `round=False` effect, `-y` handling inside the native body.

## 2. VM-dispatch check via `sub_608238` (aka `FUN_00608238`) [O/D/I/U]

[O] `sub_608238` exists at `0x608238`, size 5291, 1559 instructions in 1 block, 331 callees / 34 internal calls / 297 unresolved-indirect, 0 referenced strings, 1 caller (`sub_706880` @ `0x70691d`) — ev_e654ee12…/ev_7e20303d…/ev_7875753c…/ev_fa662364… Assembly head (ev_ce065ba5…, 40/1559 rows) is a stereotyped Delphi registrar unrolled loop:

```
push ebx / push esi / mov ebx,eax
mov ecx,<tableVA> / mov edx,<nameVA> / mov eax,ebx / mov esi,[eax] / call dword ptr [esi+0x30]
… repeated with ecx=0x60e9f4/0x60ea50/0x60ea64/… edx=0x6096ec/0x60972c/0x60976c/…
```

[D] Shape reading: `ecx`/`edx` carry (typeinfo, name) registration pairs into a virtual `TObject`-ish registrar (`[esi+0x30]` = register intrinsic). That is consistent with a **script-namespace registrar / VM-binding installer**, not with a height-smoothing kernel (a kernel would loop over a height grid, touch `GetHeightData` buffers, and reference float constants — 0 strings and 331 indirect registrar calls is the opposite signature).

[I→U] Whether S0 specifically is installed through `sub_608238`: **unproven either way.** For: the randkey APIs named in the task show the same table-only pattern as S0 — `GenerateMapRandKey` exactly 1 CODE hit `0x69f452`, `SetRandomKey` exactly 1 CODE hit `0x60a6b2` (ev_bb534909…/ev_5cc4b3b8…), both `function_find` = null (ev_c33fb90f…/ev_b6743a53…) and both 0 xrefs under the same computed-pointer reserve (ev_4b97461f…/ev_6f1a05c1…), i.e. they are likewise registration strings with no statically visible installer call. The S0 strings behave identically (0 xrefs at all three VAs: ev_3021557c…/ev_594b041b…/ev_7cc972e4…). Against / missing: LE-pointer scan for the S0 table VAs (`5A396A00`, `4E396A00`, `123B6A00`) returns **0 matches image-wide** (ev_2591266c…/ev_cb18c496…/ev_c2e40457…), so no `push imm32` / `mov reg,imm32` / `b9 <declVA>` installer edge is byte-visible for S0 in stored bytes — exactly the D02-Anomaly-D situation the prior seed report records for randkey. `sub_608238`'s 331 callees are all indirect (`[esi+0x30]`, ev_fa662364…), so a computed-pointer-installed S0 registration would be invisible to `xrefs_list` by construction. `native_functions_search Smooth` = 0 functions (ev_36df9209…) only proves no *symbol* named Smooth exists in the discovered-function list, not that no installer handles the string.

[D] Discipline consequence: the VM-dispatch hypothesis for S0 is **plausible but byte-unproven** — it must stay `[U]`, and it must **not** be cited as the mechanism. Concretely: do not claim "S0 is dispatched via `FUN_00608238`", do not claim "S0 is *not* dispatched via it" — both lack a byte edge. The only `[D]` available is negative-structural: *if* S0 is installed at all, it is installed through a computed-pointer/indirect path (immediate-pointer scan 0 + xrefs 0 + registrar shape of `sub_608238`), so a flat string-xref hunt will never localise the body. A disassembler lane with Delphi-RTTI/registration-table parsing (or a debugger breakpoint on the `SmoothTerrain` script call) is the prescribed next angle — not another linear decode of the string bytes.

## 3. Why no body is recoverable in this pass (exact причины)

1. **Target bytes are data, not code.** `0x6a3900–0x6a3b80` is a CODE-*section* DScript registration-string table (P1/P3/P8 ASCII verbatim). Decoding it as x86 yields 1-byte ASCII aliases (`popad/dec ebp/push ebx/push esp/jns`), not a function prologue, loop, or FPU/SSE sequence. There is no kernel to lift from these bytes under any decoder.
2. **No function contains the VAs.** `function_find` = null at `0x6a395a/0x6a394e` (ev_1ec21295…/P2/P5; this pass re-confirms), and `instruction_show.function` = null at `0x6a3900/0x6a394e/0x6a3b12/0x6a3e6e`. The engine discovered 18,918 functions but stopped after 6,000,000 instructions (ev_e654ee12… limit note) — coverage is explicitly incomplete, so absence proves nothing and localises nothing.
3. **No reference edge is statically visible.** 0 xrefs to all three S0 VAs (ev_3021557c…/ev_594b041b…/ev_7cc972e4…) under the stated "computed pointers at run time are not seen" limit; LE-imm32 scan for the three table VAs = 0 image-wide (ev_2591266c…/ev_cb18c496…/ev_c2e40457…). A VM/indirect registrar (`sub_608238` shape, §2) would produce exactly this signature, so the 0-hit cannot be read as "unreferenced".
4. **No adjacent code island found.** Backward (`0x6a3300`) and forward (`0x6a3e6e`) windows are more of the same table; `Smooth` function-name search = 0 (ev_36df9209…); objdump lane unavailable (`engine_missing`). The kernel, if present in the packed image, lives at an undiscovered VA reachable only through a runtime-resolved pointer — not adjacent to its own name string.
5. **No numeric literal to type.** `data_show` at the string VA yields ASCII-as-u32 (`0x6f6f6d53`), not a radius/weight/count. No float, count, or offset literal co-located with S0 was observed.

Result: **no kernel dump, no topology, no weights, no radius/sample count, no VM-dispatch confirmation** in this pass. S0 stays `[U]` in full.

## 4. Still-[U] register — termination unchanged (320² + 640² zero-mismatch hook experiment)

| ID | Statement | Termination (zero-mismatch, else stays `[U]`) |
|---|---|---|
| U-S0-KERNEL | Native `SmoothTerrain(x,y;round;mb)` body: neighbour topology, weights, loop bounds, `mb=3` semantics, `round=False` effect, `-y` handling | **Byte-proven kernel dump**: disassembly/pseudocode of the engine function reached through the `0x6a395a/0x6a3b12` registration (**computed-pointer-respecting trace, not a string-xref**) — e.g. RTTI/registration-table parse or debugger breakpoint that lands a real code VA — reproducing the port hook `hook(height: PackedFloat32Array, w: int, h: int, bsmooth: PackedByteArray, mb: int=3)` in place. **Comparison**: donor-behavioural, not byte-identical-exe: on fixed seeds, hooked-port height grid equals the dumped kernel's output cell-for-cell with **0 differing cells on 320² AND 640² maps** (both sizes; shipped-mask + synthetic-bsmooth-checker fixtures). One differing cell fails it. Until then `bsmooth_kernel=NULL`, `bsmooth_pass=SKIPPED` on all fixed seeds. |
| U-S0-SCOPE | Per-call write footprint (single cell vs neighbourhood vs whole grid) | Same dump as above must show the written address range per call (target-only vs neighbour writes). No separate capture; falls out of the dump. Until then no scope claim. |
| U-S0-VM | Whether S0 is VM-dispatched via `sub_608238` (aka `FUN_00608238`) like the randkey APIs | Byte-proven installer edge: an immediate, pointer-table, or registrar-call row that names a Smooth VA (`0x6a395a/0x6a3b12/0x6a394e` or its `ecx/edx` pair) **and** resolves into `sub_608238` or another registrar — or a debugger trace showing the dispatch. Immediate scan 0 + xrefs 0 in this pass proves nothing; hypothesis stays `[U]`. |
| U-MB3 | Meaning of `mb=3` (brush/mode/mask-bit?) | Named only by a second static anchor (second call site with a different `mb` literal, or an enum/comment byte naming `mb`) — never by guessing from the value 3. |

**Denied:** any box/gaussian/lerp blur, any "radius 3 = 3×3/7×7 window", any `mb=brush-size` gloss, any "modifies only bsmooth cells" kernel claim, any "VM-dispatched via `sub_608238`" claim, any parity/similarity claim. The port keeps `bsmooth_kernel` NULL with `SKIPPED` telemetry.

## 5. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | `0x6a3900–0x6a3b80` window is DScript-API registration strings (verbatim ASCII run `ResetPatternMap…RandomHeightTerrain…PaintTerrain…GetHeightData/SetHeightData/TerrainUpdate…`, bounds `0x6a3300–0x6a3e6e+`); linear decode yields 1-B ASCII aliases (`popad/dec ebp/push ebx/push esp/jns`), not code | [O] ev_a72cd3e6…/ev_4ff60600…/ev_ee217f95…/ev_63f07686…/ev_009142b4… + ev_d034922f…/ev_818bf74e…/ev_5c2e4493…/ev_e07a982e…/ev_afe661ec… (§1) |
| 2 | No function contains `0x6a395a/0x6a394e`; instruction `function`=null across the window; engine coverage explicitly incomplete (6M-insn stop) | [O-absence with reserve] ev_1ec21295…/ev_e1e38601…/ev_c33fb90f…/ev_b6743a53…/ev_e654ee12… (§1/§3) |
| 3 | 0 xrefs to all three S0 VAs + 0 LE-imm32 hits image-wide for all three table pointers under computed-pointer reserve | [O-absence with reserve] ev_3021557c…/ev_594b041b…/ev_7cc972e4…/ev_2591266c…/ev_cb18c496…/ev_c2e40457… (§1–§3) |
| 4 | `sub_608238` is a 5291-B/1559-insn/331-indirect-callee registrar (`mov ecx,<tableVA>; mov edx,<nameVA>; …; call [esi+0x30]`), 1 caller `sub_706880`; `Smooth` function-name search 0; randkey APIs (`0x69f452/0x60a6b2`) show the identical table-only/0-xref pattern | [O]/[D] ev_e654ee12…/ev_7e20303d…/ev_fa662364…/ev_ce065ba5…/ev_7875753c…/ev_06664a90…/ev_36df9209…/ev_bb534909…/ev_5cc4b3b8… (§2) |
| 5 | S0 VM-dispatch via `sub_608238` neither proven nor refuted; immediate/xref absence is the expected signature of indirect installation, not evidence of absence | [D]/[U] §2 |
| 6 | No neighbour array/loop/load/store, no radius/sample count, no weights recovered; all such values stay `[U]` with the §4 320²+640² zero-mismatch dump termination | [D]/[U] §1/§4 |
| 7 | No parity, no approximation, no invented blur/kernel; kernel + scope + VM + mb-semantics stay `[U]` | [D] scope guard + §4 |

## 6. Scope statement

Exactly one repository file was written by this worker: this report. All donor reads were read-only against pin `t_87f0f3c130b0` (binary never executed, no bytes copied) and the read-only prior-report corpus. No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod state was changed. No donor parity, similarity score, threshold or gate PASS is claimed. Network/multiplayer out of scope.

*End of DEC-U-NB7.*
