---
id: WATER-BUILD2
worker: WATER-BUILD2 (subagent, full 1:1 Cossacks 3 donor port)
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin_left: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5768048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
pin_right: "t_68474ddde43f = C:\\Games\\Cossacks 3\\editor.exe, PE32, 7874416 B, sha256 68474ddde43fe4aa084613f01946734a7eea6d511fb98dd81326e8be2ed250ab"
labels: [O, D, I, U]
scope: "One file only. READ-ONLY build pairing. No code/Godot/git/donor-execution; no other edits."
parity: UNVERIFIED
---

# WATER_build2 — does editor.exe expose a static water scalar source the game build missed?

## 0. Verdict (read first)

**No.** The editor build does **not** expose a byte-proven static water scalar
source (float literals, FILE/ENGINE selector) that the game build's discovery
missed.

- Parity: **UNVERIFIED**. Chain: **0/6**. **RESULT IS NOT GOOD.**
- `app_builds_line_up` (left `cossacks.exe`, right `editor.exe`) paired 5719 of
  18918/22384 functions: 5580 unchanged, 139 changed, 537 ambiguous groups,
  144 structural guesses — re-ran here with `show:ambiguous` and
  `show:only_right` pages plus `show:only_left` / `show:pairs` /
  `show:changed` controls, all `detail:summary` for `core_evidence_browse`.
- No pair or editor-only function with water-referenced strings/calls was
  found. All water strings on both builds carry `references:[]` and
  `0 functions involved`. The cossacks water chain at `0x851bdc` / `0x851c5c` /
  `0x853530` contains **zero strings, zero float literals**; its callees
  `0x852f5c` / `0x852284` / `0x8534c4` / `0x856080` are `function_not_found`
  (call edges only). Same-VA lookups in `editor.exe` are `function_not_found`
  for rebasing reasons — not proof of anything `[U]`.
- Therefore no static scalar can be promoted. The `water_scalar_source UNSET
  [U4*]` hard-fail must be kept. No fallback is proposed, no value is wired,
  no parity is claimed.
- Exactly one file written: this report. No code, shader, asset, config,
  Godot, git, or donor-execution change.

## 1. Pin verification `[O]`

`core_session_show` before work: active target `t_87f0f3c130b0`,
`C:\Games\Cossacks 3\cossacks.exe`, `sha256
87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`.

`core_target_open` on `C:\Games\Cossacks 3\editor.exe` returned:

- `target_id: t_68474ddde43f`, `kind: pe`, `bytes: 7874416`
- `sha256: 68474ddde43fe4aa084613f01946734a7eea6d511fb98dd81326e8be2ed250ab`

`[D]` Right SHA matches the ticket (`68474ddde43fe4aa084613f01946734a7eea6d511fb98dd81326e8be2ed250ab`).
Session mode Deep, `clean_room:false`, engine `0.6.1`. All reads static
(no donor execution).

## 2. What was run (allowed tools only) `[O]`

| # | Operation | Evidence |
|---|---|---|
| P-AMB | `app_builds_line_up{left:cossacks.exe, right:editor.exe, show:ambiguous, detail:summary, limit:5000}` — 537 ambiguous groups | `ev_4c90d45dae29b56781390d93b12dbd7ef44b4d4dde9e5c9cd40bc7b09c2ad666` |
| P-R | `app_builds_line_up{show:only_right, detail:summary, limit:5000}` — 15155 only_right (7099 too-small-to-pair) | `ev_a83ddc311c9229d15bf73c627062a1b6de370320dabc6dff5f4c5cf2180aaad2` |
| P-L | `app_builds_line_up{show:only_left, detail:summary, limit:5000}` — 11845 only_left (5576 too-small) | `ev_6d5aa26645d0f566b6d1cd299746acedaac8ed2c230407974c4953e4a06fb85b` |
| P-P | `app_builds_line_up{show:pairs, detail:summary, limit:10}` + `show:changed, limit:500` — 5719 pairs (5580 unchanged, 139 changed; 144 structure) | `ev_5ff6d2aa57bfddae7cd2878520134ae995721f41133348fc0e25bda1bc28320d`, `ev_5f325cd8f7a0cd6e83ac157c3f7af0c987b0ffb72d678db24a9a1592717c448a` |
| B-AMB | `core_evidence_browse` ambiguous rows (field_names) | `ev_42fa5c0fbf65f5850848ceb5ec7b1805b3bd8d9efb8fc815b47d0ca343d7273` |
| B-R | `core_evidence_browse` only_right rows | `ev_e550ac8d8369d4269a000c3a5c9fddeff205dd7e0c51029011d7864dcbedfc73` |
| B-P | `core_evidence_browse` pairs rows + changed 139 rows (fields left/right/method) | `ev_36bb6a8ab71d7ed973cc718938094d68cd478709a3856e531e1a8e5cab9c6a`, `ev_1e698034d5242e7cacc2addfc3e0b3fc699fdc7cb7f65354df0ec9ee558760` |
| F-W-E | `core_feature_find{query:water, document:t_68474ddde43f}` — 107 strings, 0 funcs | `ev_b4df8ded18a56d6fbc27d56fe5f52dbe4cef2abfec25909f28b161a33659f79e` |
| F-F-E | `core_feature_find{fresnel}` — 8 strings, 0 funcs | `ev_d05a2c69c666103cc1fcb7a61240b953de6ec94aba1dbb1c94971056b6722714` |
| F-T-E | `core_feature_find{texScale}` — 21 strings, 0 funcs | `ev_5bc602f90d3789b2b412a6d061ac6ae6861e77d1397414a325ff6595d374c8da` |
| F-R-E | `core_feature_find{reflection}` — 11 strings, 0 funcs | `ev_28332f4565ab66fa1dccc3816a1d95af32211150edfb873768243f0d8f4fa2d` |
| F-V-E | `core_feature_find{wave}` — 28 strings, 1 thunk (`waveOutClose@thunk`), 0 water funcs | `ev_c402a7cbf3ca88c50dca2c674844e56f0a7f863f26b17cbbf169907614b23232` |
| F-W-C | `core_feature_find{water, document:t_87f0f3c130b0}` — 3 strings, 0 funcs | `ev_77319dd1b0892e116f64daa03f27915fea2b1afdf4da863a5c468f9c27223081` |
| S-851bdc | `native_function_study(0x851bdc, summary)` cossacks — 4 blocks, 17 insns, 3 callees, 2 callers, 0 strings | `ev_6e4fc45eace586ea227bab873f675ffb960dbd80e778769176f4448353f5c75a` |
| S-851c5c | `native_function_study(0x851c5c, summary)` cossacks — 1 block, 13 insns, 2 callees, 4 callers, 0 strings | `ev_d56f418e1c226a2cc76d2c5a0ef27716c34189f5c734b49b620c29ace0d5787a` |
| S-853530 | `native_function_study(0x853530, summary)` cossacks — 4 blocks, 20 insns, 2 callees, 1 caller, 0 strings | `ev_dcb8827ebc9947170644a4e8c8bdd9e317dfd6a60415e92ed0c7d102360c50de` |
| S-89df30 | `native_function_study(0x89df30, summary)` cossacks — 1 block, 3 insns, 0 callees, 318 callers, 0 strings | `ev_8e1a5acf55c501dfa7704fcc58a1e96dc077e3bc40530ad196015e7813303e2f` |
| X-S | `native_xrefs_list` on `0x958c10` (cossacks `$XWaterShader`), `0xaa1af3` (editor `$XWaterShader`), `0xb376c1`/`0xb37767`/`0xb37853`/`0xb37980`/`0xb26361` (editor UI labels) — all 0 refs | `ev_6c222ebbe2725615c610ca0762088689743d5935a2dd07382f427555ce14a664`, `ev_66b3c6db74262885184f0a910f18e240944bb838eb82d60353708314b1d68f49`, `ev_b368ef0d79ed5660d6ea97dc251c767279399ddcd2701d53003e3684de13860e`, `ev_732b1882ee7a02183c2e95f884f40838b60554c9f0e9b82226a1a7cdc3be06a5`, `ev_6acbc0a9c1d912af7915e05d7b7a5f1c990891ae23cb7d52db019ac67661cbec`, `ev_3b933be973e026f4e718f24b8ce4203cb6d68ec41c88380f9687ba402dd51beb`, `ev_b70ba8a3e9c7eddec6eaf5a725f5b8f70462faf5de847c088e965edda9b4f1e7` |

No code/Godot/git/donor-execution. No `core_brief_write` / findings writes;
reads only.

## 3. Pairing pages — no water pair `[D]`

Counts re-proven this pass (all five `app_builds_line_up` records agree):

- `left_functions:18918`, `right_functions:22384`, `pairs:5719`,
  `unchanged:5580`, `changed:139`, `ambiguous_groups:537`,
  `only_left:11845` (`only_left_too_small_to_pair:5576`),
  `only_right:15155` (`only_right_too_small_to_pair:7099`),
  `by_method:{exact_name:341, identical_bytes:1491, masked_bytes:3743,
  structure:144}` `[D]` (`ev_4c90d4…`, `ev_a83ddc3…`, `ev_6d5aa2…`,
  `ev_5ff6d2…`, `ev_5f325c…`, §2).

What the pages contain:

1. **Ambiguous** (`ev_42fa5c…`): first 5 rows are all import-thunk
   duplicates (`CallWindowProcA@thunk`, `CharNextA@thunk`,
   `CloseHandle@thunk`, `CompareStringA@thunk`, `CreateFileA@thunk` with
   1–3 entries per side). `[D]` No row carries strings/calls fields — only
   `{left[], method, right[]}` with `{entry, name, size}` — so no water
   string/call can be grounded from this list. Structural-guess pairs (144)
   are low-confidence by engine limitation (`structural_pairs_are_guesses`).
2. **Only_right** (`ev_e550ac…`): rows carry only `{entry, name, size}`
   (e.g. `0x401000/526`, `0x401084/441`). `[D]` No referenced-strings/calls
   column exists to select a water candidate from the list alone.
3. **Changed 139** (`ev_1e6980…`, full page): all entries are low-address or
   large-block structural pairs (`0x402528–0x88fb78`, `0x8afbf0`, `0x6ef008–
   0x6f312c→0x8490d4–0x84d224`, `0x7377d8–0x7389c0→0x8a2b84–0x8a3d6c`,
   `0x88fb14–0x88fb78→0xa11500–0xa11564`, `0x8f1a08 entry→0xa259b8 entry`).
   `[D]` None has a `0x85xxxx` water address on either side.
4. **Water-chain membership** via `core_evidence_browse` matching:
   - `0x851bdc` → `only_left` hit `{entry:0x851bdc, name:sub_851bdc, size:48}`,
     total 1 (`ev_6d5aa2…` browse) `[D]`; pairs match for
     `left.entry:0x851bdc` total 0 `[D]`.
   - `0x851c5c` → `only_left` hit `{entry:0x851c5c, name:sub_851c5c, size:28}`,
     total 1 `[D]`; pairs match total 0 `[D]`.
   - `0x853530`, `0x856080`, `0x852f5c`, `0x852284`, `0x8534c4` → total 0 in
     `only_left`, `only_right`, and `pairs` (`left.entry` match) `[D]`.
     They are undiscovered function bodies (see §5), not pairing misses —
     engine limitation `discovery_capped` + `unpaired_not_removed` applies.

## 4. Feature-find — editor has UI labels, zero code bindings `[D]`

Editor (`t_68474ddde43f`):

- `water`: 107 strings (`TFORMWATERS`, `TWATERFIELDSFORM`, `$XWaterShader`
  `@0xaa1af3`, `fXWaterField`, `XWater`, `frmWaterFields`, `cloWater`,
  `Need Target Water`, `WaterLibraryFileName`, `Waters`/`ListBoxWaters`,
  `Water amount`, `Water Blocks/Offset/Smooth*/CollisionTag`,
  `Road Water Factor`, `ViewWater*`, `ModuleWatersEditor`, `Water Fields`,
  `HeightFieldReplaceForWater`, `TWaterFieldsForm` + field list), **0 function
  names, 0 imports, 0 functions involved** (`ev_b4df8d…`) `[D]`.
- `fresnel`: 8 strings (`LabelFresnelPower/Bias` + edits `@0xb37767…`)
  **0 functions** (`ev_d05a2c…`) `[D]`.
- `texScale`: 21 strings (`Label/EditTexScaleX/Y`, `LabeltexScaleS/T`
  `@0xb37980…`, `TexScaleEnable`, `BSpriteFXTexScale`) **0 functions**
  (`ev_5bc602…`) `[D]`.
- `reflection`: 11 strings (`PermitWidth/HeightReflection`,
  `LabelReflectionAmount @0xb376c1`, `tmmCubeMapReflection`) **0 functions**
  (`ev_28332f…`) `[D]`.
- `wave`: 28 strings (`LabelWaveFreq/Amp/Dir0_X/Y/Dir1_X/Y`, `WaveLength`
  `@0xb37853…`), 1 function NAME hit which is the audio thunk
  `waveOutClose@thunk @0x525794` (imports `waveOutWrite/PrepareHeader/Open/
  Close`), **0 water functions involved** (`ev_c402a7…`) `[D]`.
  The single `wave` function is a false positive (WinMM audio), not water.
- `hmap` / `DiffuseWaves`: 0 strings / 0 funcs (null results) `[D]`;
  `heightmap`: 6 strings, 0 funcs `[D]`; `XWater`: 8 strings, 0 funcs `[D]`.

Cossacks (`t_87f0f3c130b0`): `water` = 3 strings (`$XWaterShader @0x958c10`,
`fXWaterField`, `XWater`), 0 funcs (`ev_77319d…`) `[D]`; `Wave freq`,
`Fresnel`, `Reflection amount`, `texScaleS` = 0 strings each `[D]`.

`[D]` Editor therefore exposes the water-parameter **UI label block**
(`ReflectionAmount`, `FresnelPower/Bias`, `WaveFreq/Amp/Dir/Length`,
`texScaleS/T`, `WaterBlocks/Offset/Smooth*`, `WaterLibraryFileName`) that the
game build lacks — but every one of those strings has `references:[]`.
`native_xrefs_list` confirms static 0-from: `$XWaterShader @0xaa1af3`
(`ev_66b3c6…`), `LabelReflectionAmount @0xb376c1` (`ev_b368ef…`),
`LabelFresnelPower @0xb37767` (`ev_732b18…`), `LabelWaveFreq @0xb37853`
(`ev_6acbc0…`), `LabeltexScaleS @0xb37980` (`ev_3b93…`),
`WaterLibraryFileName @0xb26361` (`ev_b70ba8…`), and cossacks `$XWaterShader
@0x958c10` (`ev_6c222e…`) each `referenced from 0 places` `[D]`.
Static-only limitation `static_references` noted by the engine: computed-pointer
refs would not be seen `[U]`.

## 5. Water chain in cossacks — integers only, no scalar source `[D]`

### 5.1 `sub_851bdc @0x851bdc` (`ev_6e4fc4…`)

`[D]` 4 blocks, 17 instructions, 3 callees, 2 callers, 0 strings.
Assembly (paged `assembly` facet, 17/17):

```
0x851bdc push ebx
0x851bdd mov ebx, eax
0x851bdf mov eax, edx
0x851be1 mov [ebx+0xc], eax
0x851be4 test eax, eax
0x851be6 je 0x851bf2
0x851be8 mov edx, [ebx+0x10]
0x851beb call 0x852f5c
0x851bf0 jmp 0x851bfa
0x851bf2 mov eax, [ebx+0x10]
0x851bf5 call 0x856080
0x851bfa mov eax, ebx
0x851bfc call 0x852284
0x851c01 mov edx, [ebx+0x10]
0x851c04 mov [edx+0x130], al
0x851c0a pop ebx
0x851c0b ret
```

Callees facet: `call 0x852f5c @0x851beb`, `call 0x856080 @0x851bf5`,
`call 0x852284 @0x851bfc` (two with `name:null`, i.e. undiscovered targets)
`[D]`. Callers facet: `sub_8519f4 @0x851c48`, `sub_851c5c @0x851c70` `[D]`.
Pseudocode: `*(ebx+12)=eax; if(eax==0) sub_856080() else sub_852f5c();
sub_852284(); *(edx+0x130)=al` `[D]`. **Zero float literals, zero string
refs.** Selector is the runtime pointer (`test eax,eax`), not a constant.

### 5.2 `sub_851c5c @0x851c5c` (`ev_d56f41…`)

`[D]` 1 block, 13 instructions, 2 callees, 4 callers, 0 strings.
Callees: `sub_853530 @0x851c67`, `sub_851bdc @0x851c70` `[D]`.
Callers: `sub_603c0c @0x603c2b`, `sub_7130a0 @0x713672`,
`sub_852068 @0x852083`, `sub_85208c @0x852097` `[D]`.
Assembly: `push ebx/push esi; mov esi,edx; mov ebx,eax; mov edx,esi;
mov eax,[ebx+8]; call 0x853530; mov edx,eax; mov eax,ebx;
call 0x851bdc; pop/pops/ret` `[D]`. No floats/strings. The pointer tested
in §5.1 is the **runtime return value of `sub_853530`** `[D]`.

### 5.3 `sub_853530 @0x853530` (`ev_dcb882…`)

`[D]` 4 blocks, 20 instructions, 2 callees, 1 caller, 0 strings.
Caller: `sub_851c5c @0x851c67` `[D]`. Callees: `call 0x8534c4 @0x85353c`
(`name:null`), `call sub_89df30 @0x85354a` `[D]`.
Assembly: bounds check (`test esi,esi/jl`, `call 0x8534c4; cmp esi,eax/jge`,
else `mov edx,esi; mov eax,[ebx+4]; call 0x89df30`) with `xor eax,eax` null
arms `[D]`. No floats/strings.
`sub_89df30` itself is a 3-insn leaf with 318 callers, 0 strings
(`ev_8e1a5a…`) `[D]` — generic helper, not a water scalar.

### 5.4 Undiscovered callees — discovery gap `[D]`

`native_function_study` on `0x852f5c`, `0x852284`, `0x8534c4` (cossacks) each
returns `function_not_found: No function named or at …` `[D]` (same for
`0x856080`, confirming the ticket premise for that address). The call edges
from §§5.1/5.3 prove the bytes exist as call targets, but the built-in engine
created no function records there — known `discovery_capped` gap. Hence no
float-literal or selector fact can be recovered from those arms with this
toolset this pass.

## 6. Editor candidates — none with water calls/strings `[D]/[U]`

- Same-VA probes in `editor.exe` (`0x851bdc`, `0x851c5c`, `0x853530`,
  `0x856080`) each return `function_not_found` `[D-as-observation]`. `[U]`
  This is expected from rebasing (editor `.text` is shifted — cf. pairs
  `0x848410→0x9c47fc`, `0x864824→0x9e2abc` in `ev_36bb6a…`/`§3` paging) and
  proves nothing about absence.
- Size-matched `only_right` sampling (`size:48` → 49 rows, `size:28` → 54
  rows; e.g. `0x44a2c0`, `0x42933c…`) yields only `{entry,name,size}` with no
  string/call columns, so no water attribution is possible from the list
  `[D]`. Studying arbitrary size-matches without a string/call anchor would be
  guessing — not done.
- Nearest-pair shift estimate (`0x848410→0x9c47fc`) places a hypothetical
  `0x851bdc` counterpart near `~0x9D1xxx`; probes `0x9d1fc8` and `0x9d5e54`
  return `function_not_found`, while the anchor `0x9c47fc` is a real paired
  function `[D]`. `[U]` No anchor links any editor address to the water
  chain; the estimate is noted only to show the search was attempted, not as
  a correspondence.
- **Result: zero editor functions with water-referenced strings or water
  calls were found** this pass. The `wave` thunk, the 107 UI labels, and the
  `$XWaterShader`/`fXWaterField`/`XWater` shader names all have 0 code
  bindings in the built-in index `[D]`. Whether bindings exist via
  computed pointers, resource tables, or undiscovered bytes is `[U]`
  (engine `static_references` + `no_match: absence is not proof`).

## 7. Static scalar source? No `[D]/[U]`

- Float literals: none in `sub_851bdc` (17 insns), `sub_851c5c` (13),
  `sub_853530` (20) assemblies above `[D]`. No `FILE`/`ENGINE` selector
  constant either — the only branch is a runtime pointer test `[D]`.
- Editor UI labels enumerate the scalar NAMES (`ReflectionAmount`,
  `FresnelPower/Bias`, `WaveFreq/Amp/Dir/Length`, `texScaleS/T`,
  `WaterBlocks/Offset/Smooth*`) `[D]`, but with 0 static code refs they
  expose **no value** and **no selector** `[D]`. Their numerics (if any) live
  in Delphi form resources / runtime edits, not in discovered code `[U]`.
- `hmap`, `DiffuseWaves` have 0 hits on the editor side `[D]`; `heightmap`
  has 6 strings but 0 funcs `[D]`. No `texScale`/`fresnel`/`reflection`
  string resolves to code `[D]`.
- `[U]` Runtime-only: layer-pointer value returned by `sub_853530`,
  `water.lib` parse state, form-edit values, and any computed-pointer string
  use. Nothing here softens the `U4*` gate.

## 8. Required behaviour (no change)

1. Keep `water_scalar_source UNSET [U4*]` hard-fail (no water drawn). Do NOT
   default to FILE or ENGINE, do NOT wire any scalar from the UI label names,
   the `water.lib` FILE tuple, or any size-matched editor function.
2. Keep `BUILTIN_TEX_SCALE_S/T` labelled embedded-source-default, never live.
3. Owner-only runtime capture remains the sole path (break `0x851bdc`,
   record layer ptr, dump uniforms, hook `glUniform`). Nothing in this report
   substitutes for it.

## 9. Non-claims and discipline

- No parity claim. Parity **UNVERIFIED**. No donor execution, no GPU capture,
  no port comparison. Chain **0/6**.
- No approximation substituted; no scalar guessed or defaulted; `U4*` gate
  not softened.
- Read-only compliance: exactly one repo file written (this report). No
  code/shader/asset/config/Godot/git change. No donor file written or
  executed. Investigation ledger reads only.
- Byte-proven `[D]` facts above each carry evidence id + address. All value
  liveness, computed-pointer bindings, and undiscovered-arm contents stay
  `[U]` with exact zero-mismatch termination.

*End WATER_build2. Parity UNVERIFIED, chain 0/6, RESULT IS NOT GOOD.*
