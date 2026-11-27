---
id: DEC-U-B4-SMOOTH-NATIVE-2026-11-27
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-B4-SMOOTH-NATIVE — remaining packed-CODE B4 angle: core_feature_find literal sweep + native_function_study candidate dossiers (summary then complete) + core_evidence_browse paging, for the S0 SmoothTerrain kernel VA / radiusFloat / loop bounds / mb-consumer semantics"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_b4_smooth_native.md
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_GODOT_GIT_DONOR_EXECUTION
created: 2026-11-27
labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
parity_guard: "NO DONOR PARITY IS CLAIMED. No same-camera donor/port A/B frame was produced or examined. No donor binary was executed, no GPU frame captured, no harness/gate/replay run, no port capture compared. Every donor statement below is a read-only byte/dossier observation; no behaviour is closed by a port fallback."
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
chain_status: "0/6 unchanged — no six-condition chain link satisfied by this report"
scope_guard: "Exactly one repo file written (this report). No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod state changed. Donor binary and donor data tree READ-ONLY; donor executable never run; no donor bytes copied into the repo. Singleplayer skirmish only."
tooling_constraint: "No tools.craftanything.native_* call except native_function_study (summary then complete). Discovery limited to core_feature_find; dossier paging limited to core_evidence_browse. No .bind unpacking, no donor GPU inference, no objdump lane, no donor execution."
donor_pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe (PE x86, 5,768,048 B on disk; SHA256 87F0F3C130B027E7C4E72DC217EAE9D592982370D112E0D224897BC92AF4E16C, deep mode, shared Craft Anything session). Re-verified at open and close of this job (core_session_show): active target t_87f0f3c130b0, sha256 87f0f3c130b0…, open=true, analysis_mode=deep. Every native call pinned with document=t_87f0f3c130b0. Binary never executed."
prior_reports_read:
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_smooth_kernel_deep.md (S0 wrapper signatures, mb:Integer correction, 0x6a3390–0x6a3e6e CODE registration table, kernel body undiscovered, 320²+640² zero-mismatch termination)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_b45_residual.md (B4 residual: sibling mb family VAs; 0x842c30 plateau/offset + 0x71c280 settings property tables only; no radius/mb consumer)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_nb7.md (Deep decode of 0x6a3900–0x6a3b80 is ASCII table not code; sub_608238 registrar shape; VM-dispatch [U]; LE-imm32 0-hit)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_classify.md (§2.2 domain T all-B; §4 B4 static lift of SmoothTerrain(x,-y,False,3) kernel VA + minx/miny out-args; recompute probsmall/mid/large/huge + 640/((W+H)/2) trip-count)
---

# DEC-U-B4-SMOOTH-NATIVE — remaining packed-CODE angle for the S0 kernel

> READ-ONLY. Singleplayer skirmish only. No parity claim. No approximation endorsed.
> `[O]` = observed donor bytes/dossiers verified by a second read pass. `[D]` = arithmetic/control-flow over cited `[O]`. `[I]` = reading without runtime proof. `[U]` = unresolved after the passes here.
> `ev_*` ids below are per-pass Craft Anything evidence ids on `t_87f0f3c130b0` in this turn (not port test ids). "Address" = donor VA (`0x…`) or dossier site.
> Task: attack the remaining packed-CODE B4 angle with the surviving tool set — `core_feature_find` on `SmoothTerrain`, `smooth`, `mb`, `MapGenerator`; `native_function_study` (summary then complete) on any discovered candidate function; `core_evidence_browse` paging of assembly/pseudo-C facets. Recover a kernel VA, radiusFloat, loop bounds/strides or `mb`-consumer semantics **only** if byte-proven `[D]` with an evidence id and address; otherwise keep `[U]` with the exact zero-mismatch dump termination.
> Result: **no kernel VA, no radiusFloat, no loop bound/stride, no `mb`-consumer semantics recovered.** `core_feature_find` discovers zero candidate functions; the only studyable function in the carried context is the registration-installer `sub_608238`, whose complete dossier is a 331-call indirect registrar ending `return al=1`, with no Smooth VA, no height-grid loop, no load/store and no float constant. Every S0 item stays `[U]`.

## 0. Method, pin, tool constraint and pass ledger

Pin re-verified before and after the passes (§donor_pin). All calls carried `document="t_87f0f3c130b0"`. No donor binary executed; no bytes copied; no `native_*` call other than `native_function_study`.

| Pass | Operation (read-only) | Result |
|---|---|---|
| P1 | `core_feature_find` `SmoothTerrain` | ev_45b470902fd165cfebc3416df1d884a75776947854166055f2c3c4ac88f88973: **0 strings, 0 function names, 0 imports, 0 functions involved** — data-section string index cannot see the CODE-embedded registration table (`0x6a395a/0x6a3b12` known from prior passes) [O] |
| P2 | `core_feature_find` `smooth` | ev_b6125ada548310aab785251bc5acf72929b25daba66e2e0668ec8d0521ef157f: **1 string** `XTileSmooth` @ `0x959416`, `references:[]`; 0 function names; 0 functions [O] |
| P3 | `core_feature_find` `mb` | ev_6de32500bdb7176110bde53b843541f1be0bdb97ee0497131b77ab96c7a419f7: **31 strings** (generic UI/assembler/locale rows, e.g. `OSWTextureCombiners`, `XGuiComboBox`, `ThumbLength`), 1 import `CombineRgn` (gdi32) — **no kernel-relevant string, 0 function names, 0 functions** [O] |
| P4 | `core_feature_find` `MapGenerator` | ev_164c70a3d7bbdbc2f5f8490397923c185e08812591f0a27fa5ab2145f486f946: **1 string** `XMapGenerator` @ `0x959430`, `references:[]`; 0 function names; 0 functions [O] |
| P5 | `native_function_study` summary on `0x608238`, `0x6a395a`, `0x6a394e`, `0x959430` | ev_7e20303d808711477b3583514229638307108d27961d070422053f0438a5a650: `sub_608238` = 1 block / 1559 insns / 331 callees / 1 caller / 0 strings / 297 unresolved indirect. The three S0 table/class VAs return `bad_input: function_not_found` (not functions) [O] |
| P6 | `native_function_study` complete on `0x608238`; then `core_evidence_browse` on `summary`, `pseudocode` head+tail, `assembly`, `callees`, `referenced_names` (all 63), `unresolved_calls`, `callers` | ev_10c9525cc9cb3faee85c821af1f8cfa9ae6eb94c606562a867830820b2bdfdf5 / ev_29cd029f5a077b71158b620a3afc12fbd04b1d2ab8141c19ad801b8beb983939 / ev_f8457dadc675c2497c9a3d7eccddc9d27bc761440a0a8b9179e9b9673b3d0d0f / ev_6eecea2b0baaedf56ed5cbe4eb2a143256f47a1b96e233130128adb687354194 (§2) [O]/[D] |
| P7 | `core_feature_find` supplementary: `XTileSmooth`, `XMapGenerator`, `GetHeightData`, `SetHeightData`, `TerrainUpdate`, `Radius`, `SmoothTile`, `RandomHeightTerrain` | `XTileSmooth` 1 (ev_dfafdccd498f3aaa945519cc268dabd5f7263a78560a33acd7d3be4229f929f8, @0x959416); `XMapGenerator` 1 (ev_2c6b0ddc1c2a5b2f2e947a21b7d71ed4134b0a2324ba34cf76aad3872d2e8d1d, @0x959430); the other six **0** (ev_c763f1f8f28253a8f361aba91b93b5660b07a813ccbf377dd331602970516a1e / ev_1326dc37804867826518e896dbb809b45b1f7e9d867bf78903c5450ea4bcba99 / ev_6286497f2a68e37f7263cba41cfd626965c4a4a88290866a0ee2b544df89ad06 / ev_2eb88402e75fbbb2dc74b96d859473b5c65bf61aae4b35abc89594231a942939 / ev_f071791dfbc1f73fe3c9cfdaaa2ff245d310f286a609d8dab826ff8676052492 / ev_bc36027e6c6f34007e207795a5b8a60ca789cd9ca16daecca1147a7e85bfc471); 0 function names throughout [O] |
| P8 | `native_function_study` summary + complete-derived pages on `0x706880` (sole caller of `sub_608238`) | ev_788f11b14138932ee9639308770a3ea77427114af30ae95499535b621bec4434: 1 block / 76 insns / 26 callees / 2 callers / 0 strings. Pages ev_34dfbecdb3d268f661672982ee7237aab16f816722d7a10f0c5f01f8632758de (32 referenced names, incl. `call sub_608238` @ `0x70691d`) + ev_92961a80180b9a83e522c88efcd5effa1097249bba5d6450ee5159ea69eee7d4 (complete pseudo-C, ends `return rax`) [O]/[D] |

**Strange-read log:** `core_feature_find` searches the data-section string index; its own `limitations` state "nothing matched; the text may be built at run time, encrypted, or come from a resource file (absence is not proof)". Its two `0x9594xx` hits carry empty `references`, so they localise no code. `native_function_study` pseudo-C carries "a reading aid built by the clean-room lifter, not compiler output", "variables are machine registers and stack slots; types are not recovered", and "call arguments follow the usual x86 convention and may be wrong". `core_evidence_browse` "Nothing is analysed again" — every page is a re-view of the stored dossier, not new analysis. The `function_not_found` results for the S0 VAs carry the remediation "Find it with native_functions_search or native_functions_list" — those discovery tools are outside this worker's tool constraint, and prior passes (smooth-kernel-deep P8, nb7 P2/P5, b45 P5) already returned null at the same VAs. No donor binary executed; no donor bytes copied.

## 1. `core_feature_find` sweep — zero candidate functions [O]/[D]

[O] The four required literals produce, in total: `SmoothTerrain` **0 hits**; `smooth` **1 hit** (`XTileSmooth` @ `0x959416`); `mb` **31 hits** (none kernel-relevant, plus irrelevant `CombineRgn` gdi32 import); `MapGenerator` **1 hit** (`XMapGenerator` @ `0x959430`). Every string row has `references:[]`; every result has `function_names:[]`, `functions:[]`.

[D] Two consequences, both negative:

1. **No candidate kernel function is discovered by `core_feature_find`.** The requested `native_function_study` step therefore has no feature-derived function to study. The two `X*` strings are class names in the data-section index, not code anchors; they localise no VA.
2. This is the same CODE-table trap already documented in `DEC_U_smooth_kernel_deep` §1/P5: `SmoothTerrain` and `MapGeneratorSmoothTerrain` live as CODE-embedded DScript-API registration strings (`0x6a395a/0x6a3b12/0x6a394e`), invisible to a data-section string index. A 0-hit here is **file-index absence**, not engine absence; it is not evidence that the symbols do not exist. The supplementary sweep (P7) likewise returns 0 for `GetHeightData`, `SetHeightData`, `TerrainUpdate`, `Radius`, `SmoothTile`, `RandomHeightTerrain` — consistent with all of those being CODE-table rows, not with their being unused.

[D] The `mb` 31-hit set is a **name-collision census only**: `mb` is a two-letter substring inside `ThumbLength`, `XGuiComboBox`, assembler/locale rows, etc. Not one row names a terrain brush, mask bit, radius or mode. Nothing from P3 can be promoted to an `mb=3` consumer.

## 2. `native_function_study` candidates — the only studyable function is a registrar [O]/[D]

### 2.1 The S0 VAs are not functions [O]

[O] `native_function_study` on `0x6a395a`, `0x6a394e` and `0x959430` each returns `bad_input / function_not_found: "No function named or at …"`. [D] Reproduces, under the surviving tool set, the prior result that the S0 registration VAs are table bytes with no discovered code body. This is an **absence with the engine-coverage reserve**, not proof of non-existence.

### 2.2 `sub_608238` (the VM/registrar candidate) — complete dossier [O]/[D]

[O] Summary (ev_7e20303d…): at `0x608238`, **1 basic block, 1559 instructions, 331 callees, 1 caller, 0 referenced strings, 297 unresolved indirect calls**, 627 outgoing references, 63 referenced names, 0 jump tables, 0 flow parameters.

[O] Assembly and pseudo-C are the same stereotyped unrolled registrar row repeated 331 times (head ev_7e20303d…, tail ev_f8457dadc…):

```
push ebx / push esi / mov ebx, eax
mov ecx, <typeinfoVA> / mov edx, <nameVA> / mov eax, ebx / mov esi, [eax] / call dword ptr [esi+0x30]
… (ecx=0x60e9f4/edx=0x6096ec, ecx=0x60ea50/edx=0x60972c, … repeated)
… tail: al = sub_51f560(0x9044cc); ecx=eax; edx=0x60d9c0; eax=ebx; esi=[eax]; call [esi+0x48]
al = 1; return al;
```

[O] `core_evidence_browse` pages: `referenced_names` all 63 rows (ev_29cd029f…) = 37 `data` rows naming `sub_60dbd0 … sub_6119e0` consumed as (ecx,edx) pairs, then 26 `call` rows to `sub_51f560` (×8), `sub_51f578` (×8), `sub_51f570` (×8) and `sub_51f560` (×2) — string-fetch helpers. `callees` first rows are all `indirect:true, name:null, target:null`; `unresolved_calls` first rows are `0x60824a/0x60825b/0x60826c/...` (ev_6eecea2b…). `callers` = sole `sub_706880 @ 0x70691d`.

[D] Shape reading: `ecx`/`edx` carry a (typeinfo, name) pair into a virtual registrar `call [esi+0x30]`; the tail calls `sub_51f560(<stringVA>)` and returns boolean `al=1`. That is a **script-namespace/VM binding installer**, not a height kernel. It contains **no** height-grid loop, **no** `movzx`/byte load from a height array, **no** centre store, **no** FPU/SSE float constant, **no** radius/pass/count literal, and **no** name or address among its 63 referenced names that matches `SmoothTerrain`, `MapGeneratorSmoothTerrain`, `GetHeightData`, `SetHeightData` or any `0x6a39xx` VA. `referenced_strings:0` confirms it never dereferences a string directly; it is fed pointers. [I→U] Whether S0 specifically is installed through this installer remains byte-unproven either way — the `ecx/edx` names in this function are `sub_60xxxx` symbols, not the `0x6a39xx` strings, so no edge to S0 is observed.

### 2.3 `sub_706880` — the sole caller [O]/[D]

[O] `native_function_study` (ev_788f11b1…) at `0x706880`: 1 block / 76 insns / 26 callees / 2 callers / 0 strings. `referenced_names` all 32 rows (ev_34dfbecd…) = 12 `data` rows of registrar pairs followed by 20 direct calls, one of which is `call sub_608238 @ 0x70691d`. Complete pseudo-C (ev_92961a80…) is a linear chain of `mov eax,ebx; sub_XXXXX();` ending `return rax`.

[D] This is an **initialisation chain that invokes registrar routines**, not a kernel and not a dispatcher into one. No Smooth name, no height buffer, no numeric radius or pass literal appears. Studying the caller therefore adds no kernel anchor.

## 3. What this pass recovers for the four B4 targets

| Target | Result | Why |
|---|---|---|
| Kernel VA (S0 body) | **[U] — none recovered** | feature_find discovers 0 functions; S0 VAs are `function_not_found`; only studyable candidates (`sub_608238`, `sub_706880`) are registrar/installer code with no S0 edge (§1–§2). |
| radiusFloat | **[U] — none recovered** | No float constant, no `radius` argument consumer, no `0x6a394e` body in either dossier. The only Float-radius *signature* remains the unused-by-S0 `MapGeneratorSmoothTerrain(x,y,passes;radius:Float)` string from prior passes; this pass adds no value to it. |
| Loop bounds / strides / neighbour topology | **[U] — none recovered** | Neither dossier contains a grid loop, index counter, stride literal or neighbour offset. `sub_608238` has 1 basic block and 0 jump tables. |
| `mb`-consumer semantics (`mb=3`) | **[U] — none recovered** | The 31 `mb` substring hits are unrelated names (§1); no enum/comment/second call site naming `mb` was observed. The literal `3` keeps its established binding to `mb: Integer`, with no meaning assigned. |

[O]/[D] No value from §1–§2 is promoted: no invented radius, no invented pass count, no invented `mb=3` meaning, no `.bind` unpacking, no donor GPU inference, no visual similarity claim.

## 4. Still-[U] register — exact zero-mismatch dump termination

| ID | Statement | Termination (zero-mismatch, else stays [U]) |
|---|---|---|
| U-S0-KERNEL | Native `SmoothTerrain(x,y;round;mb)` body: kernel VA, neighbour topology, weights, loop bounds, strides, `mb=3` semantics, `round=False` effect, `-y` handling | **Byte-proven kernel dump**: disassembly/pseudocode of the engine function reached through the `0x6a395a/0x6a3b12` registration via a **computed-pointer-respecting trace, not a string-xref** — e.g. RTTI/registration-table parse or debugger breakpoint landing a real code VA — reproducing the port hook `hook(height: PackedFloat32Array, w: int, h: int, bsmooth: PackedByteArray, mb: int=3)` in place. **Comparison**: donor-behavioural, not byte-identical-exe: on fixed seeds, the hooked-port height grid equals the dumped kernel's output cell-for-cell with **0 differing cells on 320² AND 640² maps** (both sizes; shipped-mask + synthetic-bsmooth-checker fixtures). **One differing cell fails it.** Until then `bsmooth_kernel=NULL`, `bsmooth_pass=SKIPPED` on all fixed seeds. |
| U-S0-SCOPE | Per-call write footprint (single cell vs neighbourhood vs whole grid) | Same dump must show the written address range per call (target-only vs neighbour writes). No separate capture; falls out of the dump. Until then no scope claim. |
| U-S0-RADIUSFLOAT | `MapGeneratorSmoothTerrain(x,y,passes;radius:Float)` body and its `radius`/`passes` consumers | Same bar as U-S0-KERNEL for that entry (`0x6a394e` computed-pointer trace + 0-diff on 320² AND 640²). The signature string alone is not a consumer; no radius value (no `3.0`, no window size, no pass count) is claimed from it. |
| U-MB3 | Meaning of `mb=3` shared with Raise/Lower/Plateau/RandomHeightTerrain | Named only by a second static anchor (a second call site with a different `mb` literal, or an enum/comment byte naming `mb`) — never by guessing from the value 3. Neither `sub_608238` nor `sub_706880` supplies it. |
| U-S0-VM | Whether S0 is VM-dispatched via `sub_608238` (aka `FUN_00608238`) | Byte-proven installer edge naming a Smooth VA / its `ecx/edx` pair and resolving into the registrar, or a debugger trace of the dispatch. This pass observes `sub_608238`'s 63 names are `sub_60xxxx` symbols + string-fetch calls, with no S0 name — neither proven nor refuted; hypothesis stays [U]. |

**Denied:** any box/gaussian/lerp blur; any "radius 3 = 3×3/7×7 window"; any `mb=brush-size` gloss; any "modifies only bsmooth cells" kernel claim; any "VM-dispatched via `sub_608238`" claim; any `.bind` unpacking; any donor GPU inference; any parity/similarity claim. The port keeps `bsmooth_kernel` NULL with `SKIPPED` telemetry.

## 5. Claim register (audit-level; no parity)

| # | Claim | Label |
|---|---|---|
| 1 | `core_feature_find`: `SmoothTerrain` 0/0/0/0; `smooth` 1 (`XTileSmooth` @`0x959416`); `mb` 31 generic + `CombineRgn` import; `MapGenerator` 1 (`XMapGenerator` @`0x959430`); all `references:[]`, 0 function names/functions | [O] ev_45b47090…/ev_b6125ada…/ev_6de32500…/ev_164c70a3… (§1) |
| 2 | `core_feature_find` supplementary: `XTileSmooth`/`XMapGenerator` 1 each; `GetHeightData`, `SetHeightData`, `TerrainUpdate`, `Radius`, `SmoothTile`, `RandomHeightTerrain` 0 each; 0 functions throughout | [O] ev_dfafdccd…/ev_2c6b0ddc…/ev_c763f1f8…/ev_1326dc37…/ev_6286497f…/ev_2eb88402…/ev_f071791d…/ev_bc36027e… (§1) |
| 3 | S0 VAs `0x6a395a`, `0x6a394e` and class string `0x959430` return `function_not_found` — not discoverable functions under this tool | [O] tool errors P5 + prior nulls (§2.1) |
| 4 | `sub_608238` = 1 block / 1559 insns / 331 indirect registrar calls `mov ecx,<type>; mov edx,<name>; call [esi+0x30]` / 0 strings / 297 unresolved indirect / 1 caller / ends `al=1; return al`; 63 referenced names are `sub_60xxxx` data rows + `sub_51f560/578/570` string fetches — no Smooth VA, no height loop, no float constant | [O]/[D] ev_7e20303d…/ev_10c9525c…/ev_29cd029f…/ev_f8457dadc…/ev_6eecea2b… (§2.2) |
| 5 | `sub_706880` = 76-insn init chain, 20 direct calls incl. `sub_608238 @ 0x70691d`, ends `return rax`; no kernel anchor | [O]/[D] ev_788f11b1…/ev_34dfbecd…/ev_92961a80… (§2.3) |
| 6 | No kernel VA, radiusFloat, loop bound/stride or `mb`-consumer recovered; no value promoted; all four targets stay [U] with §4 zero-mismatch terminations | [D] §§1–4 |
| 7 | No donor binary executed, no GPU frame captured, no harness/gate/replay run, no parity claim; `parity.claim=NONE`, `parity.status=UNVERIFIED`, `visual_parity_claim=false`; six-condition chain 0/6; exactly one repository file written | [O] scope guard + §4 |

> **Verdict (governing form):** `port=UNVERIFIED`; `parity.claim = NONE`; `parity.status = "UNVERIFIED"`; `visual_parity_claim = false`; six-condition chain **0/6** unchanged by this report. T-SMOOTH kernel VA / scope / `mb=3` / radiusFloat consumers and S0 VM-dispatch remain `[U]`. **RESULT IS NOT GOOD** while `blocking_unverified` is non-empty. No same-camera donor/port A/B frame exists; no approximation is authorised; no parity claim is made.

## 6. Scope statement

Exactly one repository file was written by this worker: this report. All donor reads were read-only against pin `t_87f0f3c130b0` (binary never executed, no bytes copied) with `document=t_87f0f3c130b0` on every call. No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod state was changed. No `native_*` tool other than `native_function_study` was called; no `.bind` unpacking; no donor GPU inference. Network/multiplayer out of scope.

*End of DEC-U-B4-SMOOTH-NATIVE. Read-only; exactly one repository file written; parity UNVERIFIED; chain 0/6; RESULT IS NOT GOOD.*
