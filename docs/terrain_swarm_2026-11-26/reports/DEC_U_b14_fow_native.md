---
id: DEC-U-B14-FOW-NATIVE
worker: "DEC-U-B14-FOW (subagent, full 1:1 Cossacks 3 donor port)"
wave: "PORT1TO1 / terrain_swarm_2026-11-26"
ticket: "B14 from PORT1TO1_u_classify.md §4 row B14 / N-11: owner-authorised READ-ONLY static/native xref sweep for UpdateFOW, victorystate, GetFOWLOSData, FOWBuildFull and the XFOWRender / TLOS* / FOWRender RTTI-and-layout cluster. Settle structure, call graph and absence facts only; never invent a FOW value or wire port behaviour."
date: 2026-11-27
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION__NO_BIND_UNPACKING__NO_PARITY_CLAIM
labels: [OBSERVED, DERIVED, UNVERIFIED, NO_APPROXIMATION, PARITY_UNVERIFIED, B14_STATIC_SWEEP]
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32 x86, 5,768,048 B, sha256 87F0F3C130B027E7C4E72DC217EAE9D592982370D112E0D224897BC92AF4E16C"
donor: "READ ONLY. Opened as a static analysis target only; never executed, copied, patched, dumped to a new file or captured. No debugger, tracer, GPU frame, save/reload or .bind unpacking. Native analysis via native_function_study only."
tooling: "Per task constraint, no tools.craftanything.native_* call except native_function_study (detail=summary then detail=complete). Allowed core_* tools: core_target_open/session_show/overview_show/feature_find/evidence_browse/evidence_show plus report/memory tools. Signatures discovered with search() inside execute."
parity_status: UNVERIFIED
parity_claim: NONE
parity_claim_code: NONE
visual_parity_claim: false
chain: "0/6 CLOSED (conditions 2 and 6 PARTIAL port-internal only; 1/3/4/5 BLOCKED) — PORT1TO1_parity_chain.md:38-58, PORT1TO1_parity_recheck.md:44/63"
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; P0-3/F-GRID a-e + persistence + F1-NUM-f/g + tint + live ordering stay [U]; no donor GPU A/B frame; no FOW value invented; no parity claim."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
scope_guard: "Repo/doc reads plus the pinned static target only. No source/shader/asset/config/test/fixture/result-JSON/backup/queue/git/Godot state written; no donor execution/copying; no .bind unpacking. Exactly one repository file written: this report. The analysis tool's own brief/evidence ledger was used (not a repository file)."
upstream:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_classify.md (§2.5 N-11 class B, §4 B14, §5 no class-A close)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_fow_owner_protocol.md (§1-§8: zero-mismatch termination, forbidden substitutes)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_endgame_fow.md (§0 P2-P5: native string/data/xref probes, 6 live UpdateFOW sites)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_fow_grid_deep.md (§§1-2: 24-name binding block, RTTI cluster, absence sweeps)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_fow_numeric_deep.md (§§3-4 B2/B3/C1-C4, §6 F1-NUM-a..g: string-table DATA verdict, byte-proven offsets, zero-mismatch criteria)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_fow_occ_deep.md (P3/P6: RTTI names only, zero field literals)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_fow_knobs.md (§§1-4: knob signatures, RTTI re-dump, zero script writers)
---

# DEC-U-B14 — native/static FOW engine-surface sweep: byte-proven links vs strictly-[U] values (2026-11-27)

> **Required reviewer line, verbatim (`PORT1TO1_owner_decisions.md:15/32`, `PORT1TO1_u_register_update.md:31-32`):**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> **This is a structural/absence pass, not a value pass.** It closes **zero** items and promotes **zero** values. `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`. `blocking_unverified` is non-empty (P0-1…P0-8 plus tails), six-condition chain **0/6 CLOSED** ⇒ **`RESULT IS NOT GOOD`** unconditionally. No donor binary was executed, no GPU frame captured, no `.bind` unpacked, no port behaviour wired, no approximation authorised.

---

## 0. Result in one paragraph

Under the pinned target, `core_feature_find` returns **0 strings / 0 function names / 0 imports / 0 functions** for `UpdateFOW`, `victorystate`, `GetFOWLOSData` and `FOWBuildFull`, and 0 for the RTTI names `TLOSInfo`, `TLOSData`, `TFOWLerpInfo`, `TOSWFOWRender`, `TLOS`, `FOWEnable`, `FogOfWar`. Every one of those records carries the engine's own `no_match` limitation: *"nothing matched; the text may be built at run time, encrypted, or come from a resource file (absence is not proof)"*. The same index finds exactly one FOW token — `XFOWRender` at `0x958d0d` with `references: []` — and `core_overview_show` separately self-declares that function discovery is **incomplete** (6,000,000-instruction stop, 1,238 unresolved indirect jumps, stripped names, static-analysis-only). The only nine "functions" a case-insensitive `LOS` sweep surfaces are Windows `Close*`/`closesocket` import thunks; a full `native_function_study` of `0x4012e8` (summary then complete, facets paged) byte-proves `jmp dword ptr [0x9072e4]` with callers `sub_4035a4`/`sub_4035d4` and **zero** FOW strings. `native_function_study` returns `function_not_found` for `0x6a8412` (the `GetFOWLOSData` VA) and for `XFOWRender`: these are DATA/type strings, not discovered functions. Therefore **no FOW routine call graph, no FOW field layout and no FOW value is byte-proven by this pass**; what *is* byte-proven is the name/address of `XFOWRender`, the absence of references to it in this index, the identity of the `LOS` false positives, and the incompleteness of the discovery itself. Prior pinned raw-byte passes additionally prove the FOW binding block, `FOWEnable` ×3, `GetFOWLOSData` ×1, `FOWBuildFull`, the RTTI type names and three field offsets; those are carried verbatim below and are **not re-lifted** here. Every behavioural/value item stays `[U]` with its exact zero-mismatch termination condition (§6). No cell size, combine operator, occlusion slope, explored lifetime, LOS domain, RTTI field layout, knob default or tint constant is invented or wired.

---

## 1. Authority, tooling and pin verification

### 1.1 Pin verified before any finding `[D]`

`core_session_show` (first analysis-order call after the brief) returned:

| Field | Value |
|---|---|
| active target | `t_87f0f3c130b0` |
| path | `C:\Games\Cossacks 3\cossacks.exe` |
| bytes | `5,768,048` |
| sha256 | `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c` |
| mode | deep, Clean room `false` |
| open | `true` |

This matches the required pin `t_87f0f3c130b0` / `87F0F3C1…4E16C` **exactly**. No finding in this report precedes this check; the target was opened/validated as static data by the harness before this worker's first query and was never executed, copied or written.

### 1.2 Tooling discipline `[D]`

- `native_*` family: **only** `native_function_study` was called. It was called with `detail:"summary"` first on `0x4012e8` and then `detail:"complete"` on the same function; its large facets were then paged with `core_evidence_browse` (`callers`, `callees`, `assembly`, `referenced_names`).
- `core_*` family used: `core_session_show`, `core_brief_write`, `core_overview_show`, `core_feature_find`, `core_evidence_show`, `core_evidence_browse`, `core_finding_record`. Signatures were discovered with `search({query:"..."})` inside `execute`.
- Forbidden operations not performed: donor execution/copying/patching, debugger/tracer attachment, GPU capture, `.bind` unpacking, Godot/runner/gate execution, any repository code/asset/config/test/git edit.

### 1.3 Evidence provenance — live vs carried `[D]`

| Provenance | Meaning |
|---|---|
| **LIVE** `ev_…` id | Generated by this worker's tool call; present in the current evidence ledger; re-lifted from the pinned target this pass. |
| **CARRIED** `ev_…` id | Quoted from an upstream report's pass ledger, pinned to the same `t_87f0f3c130b0`. **Checked this pass with `core_evidence_show` and found *not present* in the current ledger** (all seven sampled ids returned `records:0, total:0`). These are report-text citations, **not** re-lifted evidence and not re-verified against the ledger here. Their byte VAs/file-offs are carried, not newly derived. |
| **CARRIED, no id recorded** | RTTI type names and field offsets quoted from DEC_U_fow_grid_deep / DEC_U_fow_knobs / DEC_U_fow_numeric_deep section text; those reports record file-offs but no `ev_` id for those particular passes. Cited by report § + VA, explicitly not re-lifted. |

This distinction is load-bearing: a 0-hit in a re-run index is **not** a disproof of a carried positive byte hit obtained by a different method (§5.2).

---

## 2. Pass ledger (LIVE this pass, all pinned `t_87f0f3c130b0`)

| # | Pass | Result / evidence id (LIVE unless marked CARRIED) |
|---|---|---|
| B14-P1 | Pin re-assert (`core_session_show`) | `t_87f0f3c130b0`, 5,768,048 B, sha256 `87f0f3…4e16c` — exact match (§1.1). `[D]` |
| B14-P2 | `core_feature_find "UpdateFOW"` | **0 strings, 0 function names, 0 imports, 0 functions**; `no_match` limitation. `ev_bca8d8a1bbccf15c5ed9988c6aa593226233c7b737c7c9f9564f29ab03862cdd` |
| B14-P3 | `core_feature_find "victorystate"` | 0/0/0/0; `no_match`. `ev_ea2f5c36c71ad867f4421f96baed946dae4a566c1e58c49893e3d1f10b867f6f` |
| B14-P4 | `core_feature_find "GetFOWLOSData"` | 0/0/0/0; `no_match`. `ev_be8575b24af2ca658b9f3c3907485b142a0f9864816c376a39144fee18b08b3e` |
| B14-P5 | `core_feature_find "FOWBuildFull"` | 0/0/0/0; `no_match`. `ev_82b2ed6dd18a54a66605e122fb4b0069c5f8fc18a43f50eaa842b4dbd9485737` |
| B14-P6 | `core_feature_find "XFOWRender"` | **1 string** `XFOWRender` @ `0x958d0d`, `references: []`, 0 functions, 0 imports; `no_match` limitation still attached. `ev_6a94cc5cc44b6f0f42869557966feb97712ca13c6a42d8c45479d4fb4ffb5250` |
| B14-P7 | RTTI-name finds (`TLOSInfo`, `TLOSData`, `TFOWLerpInfo`, `TOSWFOWRender`, `TLOS`, `FOWEnable`, `FogOfWar`, `FOWRender`) | All 0/0/0/0 except `FOWRender` → the same single `XFOWRender` @ `0x958d0d`. `ev_7f1ee50d…`, `ev_2e9534e0…`, `ev_f1080a01…`, `ev_64660c20…`, `ev_f6d87adc…`, `ev_93213c79…`, `ev_87d5d0e6…`, `ev_b731ab32…` (full ids in §7) |
| B14-P8 | `core_feature_find "FOW"` | 4 strings + 3 imports, **0 functions**: `SetMenuItemInfoW` @`0x9093fe`/slot `0x907734`, `GetMenuItemInfoW` @`0x909a3c`/slot `0x9078b0`, `GetClassInfoW` @`0x909bf4`/slot `0x907918` (all `references: []`, all `InfoW` substring false positives), plus `XFOWRender` @`0x958d0d`. `ev_cf3a5636a880286ba891fc835c1bf7967577ae52fb2bc39fb076bcb4adb86cf0` |
| B14-P9 | `core_feature_find "LOS"` | 41 strings, 9 **function names**, 10 imports, 9 functions — all `CloseHandle@thunk`/`FindClose@thunk`/`RegCloseKey@thunk`/`CloseClipboard@thunk`/`InternetCloseHandle@thunk`/`closesocket@thunk`. `ev_6b92caf5f208771082eae49d7cf0837a78ad93b8006cdfa24c5235653de4ab9d` |
| B14-P10 | `core_overview_show` (summary) | PE32 x86; **18,918 functions / 12,073 strings / 746 imports / 18 libraries / 10 segments**; `coverage.status = "partial"`. Four self-declared limitations (§5.1). `ev_60b497434aa3e6cb68b019fd0a3b016ec0415ef6ec1a3189726faa8d3752f4c4` |
| B14-P11 | `native_function_study "0x6a8412"` and `"XFOWRender"` (summary) | Both `bad_input / function_not_found` — no function at the `GetFOWLOSData` VA and no function named `XFOWRender` in the discovered set. Tool responses, no evidence id. `[O]` |
| B14-P12 | `native_function_study "0x4012e8"` — summary **then** complete | `CloseHandle@thunk` @`0x4012e8`: 1 block, 1 instruction `jmp dword ptr [0x9072e4]`, `name_source = import_thunk`, `thunk_of = CloseHandle`, callees `[CloseHandle import @0x4012e8]`, callers `sub_4035a4`@`0x4035a8`, `sub_4035d4`@`0x403760`, `referenced_strings: []`, `unresolved_calls: []`. `ev_5609cc74bee88c9f89f62853d3111b98dbf357b0bd36d9ce1d96ff78907eae6f` |
| B14-P13 | `core_evidence_browse` paging of P12 facets | `callers` (2/2, `at_end`) `ev_d3dc3929ca6f…`; `callees` (1/1) `ev_d62dfac092…`; `assembly` (1/1) `ev_c7b5292511…`; `referenced_names` (1/1, `__imp_CloseHandle`→`0x9072e4`) `ev_dd441ce854…`. **No FOW link in any facet.** |
| B14-P14 | Ledger check of seven carried ids (§1.3) | All not loaded in current ledger. `core_evidence_show` responses, no new evidence id. `[D]` |

Carried prior passes reused verbatim, **not** re-performed here: DEC_U_endgame_fow §0 P2–P5 (`UpdateFOW` 0, `victorystate` 0, `FOW` 4/`XFOWRender` @`0x958d0d`, `GetFOWLOSData` 0, `FOWBuildFull` 0, `XFOWRender` data + 0 xrefs); DEC_U_fow_grid DE P4 + deep P4–P6 (FOWEnable ×3, GetFOWLOSData ×1, binding block, RTTI); DEC_U_fow_numeric_deep §§3–4 (string-table DATA verdict, `XFOWRender` offsets); DEC_U_fow_occ_deep P3/P6 (RTTI names, zero field literals).

---

## 3. Byte-proven `[D]` links — what this pass actually establishes

### 3.1 LIVE byte-proven facts (evidence id + address/VA)

| # | Link | Address / VA | Evidence id (LIVE) | Label |
|---|---|---|---|---|
| D1 | `XFOWRender` is a resident ASCII string, exactly one occurrence in this index, with **zero** references and zero functions involved | `0x958d0d` (`.rsrc`, per carried P5) | `ev_6a94cc5cc44b6f0f42869557966feb97712ca13c6a42d8c45479d4fb4ffb5250` | `[D]` |
| D2 | `FOW`-index hits other than `XFOWRender` are `InfoW` substring false positives, each with `references: []` | `0x9093fe`/`0x907734`, `0x909a3c`/`0x9078b0`, `0x909bf4`/`0x907918` | `ev_cf3a5636a880286ba891fc835c1bf7967577ae52fb2bc39fb076bcb4adb86cf0` | `[D]` |
| D3 | The nine `LOS`-matching functions are Windows `Close*`/`closesocket` import thunks, **not** FOW LOS routines | `0x4012e8`, `0x401370`, `0x4013f0`, `0x4080c4`, `0x408104`, `0x4081ac`, `0x40884c`, `0x43dcbc`, `0x5a2f58` | `ev_6b92caf5f208771082eae49d7cf0837a78ad93b8006cdfa24c5235653de4ab9d` | `[D]` |
| D4 | Representative thunk `0x4012e8` has a byte-proven call graph: `jmp dword ptr [0x9072e4]`; callers `sub_4035a4`@`0x4035a8` and `sub_4035d4`@`0x403760`; callee import `__imp_CloseHandle` @`0x9072e4`; **0 referenced strings** | `0x4012e8` (body `0x4012e8–0x4012ee`) | `ev_5609cc74bee88c9f89f62853d3111b98dbf357b0bd36d9ce1d96ff78907eae6f`; paged `ev_d3dc3929ca6f…` / `ev_d62dfac092…` / `ev_c7b5292511…` / `ev_dd441ce854…` | `[D]` |
| D5 | No function exists at the `GetFOWLOSData` string VA and no function is named `XFOWRender` — i.e. neither is a callable thunk in the discovered set (**not** proof no function exists; see D6) | `0x6a8412`, `XFOWRender` | tool responses `function_not_found` (§2 P11) | `[O]` bounded |
| D6 | Function discovery is **incomplete** by the engine's own declaration: 6,000,000-instruction stop; 1,238 unresolved indirect jumps; stripped names (generated `sub_…`); static-analysis-only, "functions reached only through computed pointers or at run time may be missing; absence is not proof" | whole image | `ev_60b497434aa3e6cb68b019fd0a3b016ec0415ef6ec1a3189726faa8d3752f4c4` | `[D]` |

`[D]` reading of D1–D6: the literal sweep establishes a **renderer-type name and its zero-reference status**, and the falsity of the only apparent function/RTTI hits. It establishes **no** FOW routine address, no FOW caller/callee chain, no FOW field layout and no FOW numeric value.

### 3.2 CARRIED byte-proven facts (same pin, quoted upstream, not re-lifted)

| # | Link | Address / VA | Carried evidence id / report § |
|---|---|---|---|
| C1 | `FOWEnable` engine gate — 3 byte hits (feature table + two binding entries) | file-off `0x1d9daa` (VA `0x5da9aa`), `0x2a74b5` (VA `0x6a80b5`), `0x2a74dd` (VA `0x6a80dd`) | `ev_ae7d083867057581f8221772ca24173249b3509085b3af3e7eed5728c5bac039` (DEC_U_fow_grid DE P4 / deep P4 / persist P4 / PORT1TO1_fow_owner_protocol §2.1 FOW-EN) |
| C2 | `GetFOWLOSData` raw-byte hit with full signature `function GetFOWLOSData(x, z: Float): Integer` | file-off `0x2a7812` (VA `0x6a8412`) | `ev_4f7e8d6440c11e327ccc728e5ffce9dc65313d95b50db44a85bb1b0090ef584d` (DEC_U_fow_grid_deep P5, §2.1:10) |
| C3 | `FOWBuildFull` binding string — length-prefix `0x16`, string-table DATA, body not adjacent | file-off `0x2a7906` (VA `0x6a8506`) | DEC_U_fow_numeric_deep §3 B3 (no `ev_` id recorded there) |
| C4 | 24-name FOW script-binding block `0x2a74b2–0x2a79d3` — length-prefixed `function`/`procedure` signatures; **no dims/stride/operator/threshold literal co-located** | `0x2a74b2–0x2a79d3` | DEC_U_fow_grid_deep §1 P6 / §2.1; DEC_U_fow_knobs §1 P3 (byte re-dump) |
| C5 | RTTI type names resident: `TLOSInfo @0x361191`, `TLOSData @0x3611e9`, `TFOWLerpInfo @0x361241`, `TFOWLerpData @0x36129d`, `TOSWFOWRender @0x3613a9/@0x3613be`, `XFOWRender @0x3613d6/@0x361419/@0x549f0d`, `FOWRenderT @0x1d9c16` (VA `0x5da816`) | `0x361150–0x36141a`, `0x549f0d`, `0x1d9c16` | DEC_U_fow_grid_deep §1 P7 / §2.2–2.3; DEC_U_fow_knobs §1 P4 / §4; DEC_U_fow_occ_deep P3 (no `ev_` ids for these passes) |
| C6 | Byte-proven **layout offsets on `XFOWRender`** (not a full layout): flag byte `[eax+0x18]` feeding a `0.0f`/`1.0f` boolean-to-float getter at `0x3613e4`; `1.0f` immediate `0x3F800000` at `0x3613f5`; SEH factory from `0x361424` touching `[ebx+0x48]`, `[eax+0x14]`, `[ebx+0x4C]`, with small ints `2`, `1`, SEH cookies `0x7620B2`/`0x7620B9`, table word `[0x762000]`, calls `0x406150`/`0x405F7C`/`0x704DF0`/`0x404854`/`0x404800`. **No divisor, stride, grid width, float step or `20/24/32/52/53.333/2.5/5` constant.** | `0x3613d6`, `0x3613e4`, `0x3613f5`, `0x361419` (VA `0x762019`), `0x361424` | DEC_U_fow_numeric_deep §4 C1–C3 (no `ev_` id; verified by capstone in that pass) |
| C7 | `FOWRenderT` feature-table slot: index bytes `2C 00`, length-prefixed 9-byte name, small LE payload, `FF` framing; **no divisor/stride/dims/float**; zero flat VA/RVA pointer image-wide | `0x1d9c16` / VA `0x5da816` | DEC_U_fow_numeric_deep §4 C1; §3 P6 zero-xref sweep |
| C8 | Zero flat VA/RVA xrefs to the eight RTTI record VAs (no constructor call site linkable by pointer scan) | `0x361191`, `0x3611e9`, `0x361241`, `0x36129d`, `0x3613a9`, `0x3613be`, `0x3613d6`, `0x549f0d` | DEC_U_fow_numeric_deep §4 C4 / P6; DEC_U_fow_occ_deep P3/P6 |
| C9 | `XFOWRender` ASCII data + **0 xrefs to/from** that `.rsrc` string; renderer type name only | `0x958d0d` | `ev_7a6b740ea633b9b5a5ff614aedc68e369ea9bb01101dd0c4182def3e0e298baa` (data) + `ev_6b25fa2c822a9046cdae863470363521d5c9cc6a19d0e178fd5e6fbbe2b7958b` (xrefs) — DEC_U_endgame_fow §0 P5 |
| C10 | Negative native string probes: `UpdateFOW` 0, `victorystate` 0, `GetFOWLOSData` 0, `FOWBuildFull` 0, `_unit_GetVision` 0, `AddFOWPlayers` 0 | — | `ev_a7500f39…`, `ev_9d08a83d…`, `ev_83a68812…`, `ev_5c60fdec…`, `ev_4d51a09f…`, `ev_5a934902…` — DEC_U_endgame_fow §0 P2–P4 |
| C11 | DScript-side census (text, not native): exactly **6 live `UpdateFOW` call sites**, zero in victory/defeat/team-mutation paths; `FOWBuildFull` one writer (`scenario.script:1862`); `ClearFOWPlayers` one (`player.script:460`); `SetFOWEnable` one (`:477`) | script `file:line` | DEC_U_endgame_fow §1/§3 (P6/P9) |

`[D]` reading of C1–C11: an engine-side FOW enable gate, LOS sampler signature, binding block, RTTI/render types and a handful of object-internal offsets are byte-proven on the pinned image. **None of them is a grid dimension, combine operator, occlusion slope, persistence lifetime, LOS return domain, knob default, complete struct layout or tint constant.** The script-side census (C11) is text evidence, not a native call graph.

---

## 4. What remains `[U]` — nothing was promoted

| Item | Still `[U]` because | Static pass result |
|---|---|---|
| F-GRID-a / F1-NUM-a — grid cell size, world-units per `res` | No dims/stride/quantisation literal in binding block (C4), no FOW-window float; `53.333…` 0 hits f32/f64 image-wide; `res`-to-metres relation unproven | `[U]` |
| F-GRID-b / F1-NUM-b — combine operator, fill-cap/default-radius roles | One scalar per viewer via `SetFOWDovFunc`; zero script writers for K4/K6; no accumulation operator; `0x3613f5` `1.0f` is a flag constant, not a threshold | `[U]` |
| F-GRID-c / F1-NUM-c — occlusion, blocker set, `FOWElevation` effect | No blocker/height/forest/wall/slope literal tied to FOW; `wallblock`/`occlu` hits excluded by context; `FOWElevation` never written by shipped scripts | `[U]` |
| F-GRID-d / E-PERSIST-d — explored-vs-visible persistence, per-player vs global, clear triggers | Only recompute triggers + viewer-set resets; `onsave.inc` carries no explored payload; no stored-layer name/lifetime | `[U]` |
| F-GRID-e / F1-NUM-e — `GetFOWLOSData` sampling domain beyond `Integer` + `>0` | Signature grounded (C2), call sites compare only `>0`; `TLOSData` proves a record exists but not its domain | `[U]` |
| F1-NUM-f — complete RTTI field layouts / offsets | Names + framing + three isolated offsets byte-proven (C5/C6/C7); field counts/offsets/cell geometry not resident; zero flat xrefs (C8) | `[U]` |
| F1-NUM-g — knob defaults K1–K8 | Zero script writers, zero config keys, zero binary defaults; this pass adds none | `[U]` |
| F1-MINI-TINT — minimap/terrain tint RGBA + threshold | `XFOWRender` is a render-layer type, no colour; `FOWColor` has zero writers; no panel RGBA byte-proven | `[U]` |
| U-F1…U-F8 / live ordering + re-resolve cadence | 6 `UpdateFOW` sites are script text (C11); no native per-frame `UpdateFOW` discovered; no ordering/timing value | `[U]` |
| N-11 itself (this ticket) | Structural/absence facts only; class B; no behavioural item closed by static work (PORT1TO1_u_classify §5) | `[U]` behaviour; structure narrowed |

No value is inferred from a name, an offset, a `1.0f` flag constant, a registration order, a script call count, or a false-positive substring hit.

---

## 5. Engine self-declared incomplete discovery vs true absence

This is the central discipline of the sweep. Three distinct cases are kept apart.

### 5.1 Self-declared incomplete discovery — **not** absence `[D]`

- **Per-literal `no_match`**: every 0-hit `core_feature_find` record (P2–P7) carries `absence is not proof`; the text may be built at run time, encrypted, or live in a resource file. None of these is a byte-proven "no such feature".
- **Whole-image `core_overview_show`**: `coverage.status = "partial"` with `instruction_limit` (function discovery stopped at 6,000,000 instructions), `indirect_jumps_unresolved` (1,238), `stripped_binary` (generated `sub_…` names) and `static_analysis_only` ("functions reached only through computed pointers or at run time may be missing; absence is not proof"). Evidence `ev_60b497434aa3e6cb68b019fd0a3b016ec0415ef6ec1a3189726faa8d3752f4c4`.
- **`function_not_found` bounded scope**: P11's two failures apply to the *discovered 18,918-function set*, not to the image; a DATA string or an indirect-only routine can still exist (D6).

### 5.2 Index-vs-CODE / index-vs-data split — a demonstrated contradiction of naive 0-hit reasoning `[D]`

| Literal | This pass `core_feature_find` | Prior pinned raw-byte pass | Reading |
|---|---|---|---|
| `GetFOWLOSData` | 0 hits (`ev_be8575b2…`) | 1 hit @ file-off `0x2a7812` / VA `0x6a8412`, full signature (`ev_4f7e8d64…`, C2) | Both true: different indexes. The name lives in a length-prefixed CODE string table, not in the indexed string list. |
| `FOWBuildFull` | 0 hits (`ev_82b2ed6d…`) | byte hit @ `0x2a7906` / VA `0x6a8506`, length prefix `0x16` (C3) | Same. |
| `FOWEnable` | 0 hits (`ev_93213c79…`) | 3 hits (C1, `ev_ae7d0838…`) | Same. |
| `TLOSInfo`, `TLOSData`, `TFOWLerpInfo`, `TOSWFOWRender` | 0 hits | names resident in RTTI cluster `0x361150–0x36141a` (C5) | Same. |
| `XFOWRender` | 1 hit @ `0x958d0d` (`ev_6a94cc5c…`) | 4 occurrences: `0x3613d6`, `0x361419`, `0x549f0d`, `0x958d0d` (C5/C9) | The new index sees only the `.rsrc` copy — a direct measurement of index incompleteness. |

Consequently "0-hit in scripts" (the task's premise) and "0-hit in `core_feature_find`" are **not** "no such engine surface": the engine surface is byte-proven in the pinned image by prior raw-byte passes (C1–C9), while this pass proves only that the *new index* and the *discovered function set* do not expose it as callable code.

### 5.3 True absence facts (byte-proven within a defined, stated scope) `[D]`

These are the only "absence" results this report treats as byte-proven:

1. `XFOWRender` at `0x958d0d` has `references: []` in this pass (`ev_6a94cc5c…`) and **0 xrefs to/from** in the pinned raw-byte xref pass (`ev_6b25fa2c…`, C9) — a renderer type name with no code reference, not a grid or call site.
2. The only nine functions a case-insensitive `LOS` sweep returns are `Close*`/`closesocket` import thunks (D3), byte-proven by full dossier on `0x4012e8` (D4) — **no FOW LOS function is among them**.
3. The three `FOW`-index imports are `InfoW` substring false positives with 0 references (D2).
4. `native_function_study` finds no function at `0x6a8412` and none named `XFOWRender` (D5) — bounded by D6, so this is "no discovered callable FOW routine", not "no routine exists".
5. Prior negative name sweeps — `explored`, `fog_vis`, `fowcell`, `visgrid`, `cellsize`, `gridsize` (DEC_U_fow_grid_deep P8), blocker literals ±4 KB of `TLOSInfo`/`GetFOWLOSData` (DEC_U_fow_occ_deep P4/P6), `53.333…` f32/f64 image-wide (DEC_U_fow_numeric_deep §3 B4/§5) — are byte-proven **absence of those literals** in the packed image, not absence of the underlying behaviour.

---

## 6. Exact zero-mismatch termination conditions for every retained `[U]`

Nothing below is performed or deemed satisfied by this pass. Each row is the owner-only experiment that retires the item; any mismatch, missing dump, void session, Class-N path or cross-fixture comparison keeps it `[U]`. All readouts are script `GetFOWLOSData(x,z)` dumps (never pixels, except the tint arm), on one fixed seed/fixture/camera, with `FOWBuildFull` + one settled tick before each dump and knobs at logged defaults.

| `[U]` item | Exact experiment | Zero-mismatch termination |
|---|---|---|
| **F-GRID-a / F1-NUM-a cell size** | One peasant at centre, no blockers; `vision 0/3/8` (predict `res = 20/32/52`) and fogreveal radius `R = 10/20/30` (predict `floor(dx)=R`); two perpendicular 1.0-unit coarse transects ±(`res`+8), plus one 0.25-unit fine transect across the edge | All six radii fit **one** linear scale `k` with **0 transect cells mismatching** `dist ≤ k·res` on the coarse passes **and** the fine pass shows a single stable step width equal to the cell size with **0 off-step cells**; report `k` + cell width, else `[U]` |
| **F-GRID-b / F1-NUM-b combine** | Two identical peasants at ≈0.75× diameter; transect through both centres + perpendicular bisector; three-viewer stacking with one removed at a time; ally vs enemy second viewer; log `GetFOWFillMaxNum`/`GetFOWDefDov`, repeat stacking at raised cap only if cap is small | Union-shape match **and** removal sequence matches Boolean-OR (or a stated threshold `N` with fill-cap dependence) **and** ally/enemy split matches, with **0 mismatching cells across all sub-runs** |
| **F-GRID-c / F1-NUM-c occlusion** | Control + (i) hill ridge, (ii) forest block, (iii) wall/building row; log `GetFOWElevation` default, never change it; dump same transect; map any shadow edge at 1.0-unit steps and confirm on a second rotated transect | All three interpositions **cell-identical to control (0 mismatches)** ⇒ pure-radius disc; else fitted blocker rule predicts the rotated transect with **0 mismatches**. Never write a slope or `FOWElevation` effect without second-transect confirmation |
| **F-GRID-d / E-PERSIST-d persistence** | Reveal far probe cell (`GetFOWLOSData > 0`); (i) walk viewer away beyond `res`+margin, (ii) `_control_SetPlayer` round-trip, (iii) balloon/victory/editor-fog gates, (iv) kill viewer (`res:=0`), (v) save + reload (donor lane A, N9 caveat); same probe for ally vs enemy viewing player | Full matrix dumps **identically on two repeats with 0 flapping cells**, yielding one verdict: sticky-explored vs visible-only, per-player vs global, and exactly which trigger clears what |
| **F-GRID-e / F1-NUM-e sampler domain** | 0.25-unit fine transect across the edge, raw `Integer` returns; repeated same-tick dumps; just-inside/outside tile-border probes; note any value `>1` | Raw domain enumerated (e.g. exactly `{0,1}` or counts) with **0 out-of-domain values** over the full fine transect **× 3 repeats**, and the edge cell matches the stated point-vs-area rule with **0 mismatches**; portable port predicate stays `>0` |
| **F1-NUM-f RTTI layouts** | Owner debugger/memory read of field offsets/sizes for `TLOSInfo`/`TLOSData`/`TFOWLerp*`/`TOSWFOWRender`/`XFOWRender`/`FOWRenderT` at C5 VAs; cross-check `XFOWRender` flag `[+0x18]` and factory `[+0x48/+0x14/+0x4c]` | **Identical layout on two reads with 0 mismatching bytes/fields**; anything flapping stays `[U]`; no layout constant ported until then |
| **F1-NUM-g knob defaults K1–K8** | In the cell-size control setup, call each readable `Get*` once per run; log values with run id | **Identical getter values across ×3 repeats with 0 mismatches**; flapping value gets **no** port constant |
| **F1-MINI-TINT tint RGBA/threshold** | Three cell classes (never-seen / seen-now / explored-not-visible); 240² panel capture at native resolution **plus** per-cell `GetFOWLOSData`; both DPI arms; repeat at two further recorded seeds where the criterion mandates 3 runs, never pooled | Three pixel sets **pairwise disjoint with 0 misclassified samples** across all runs × both DPI arms **and** per-cell reads match `>0` on every sample; report exact RGBA + separating threshold, else `[U]`. No RGBA/threshold before this terminates |
| **U-F1…U-F8 live ordering / re-resolve cadence** | Fixed-seed defeat / team-win / surrender double-stamp / trigger-no-diplomacy / trigger-merge+win / mask-only diplomacy / spectator-purge / balloon×victory transects and viewer-set dumps at T−1/T/T+1/T+5, 3 identical-seed runs | Per `DEC_U_endgame_fow §6` and `PORT1TO1_fow_owner_protocol §4`: 3 runs identical bitmaps/transects/primitives; **no same-tick full-vision** in the donor stale arm, **no intermediate refresh frame** on double stamps, single vision transition on team-win, exact purge `gametime == 0.0`; any divergence is quoted, never averaged, never an invented hook |

**Forbidden substitutes (unchanged, verbatim in substance from `PORT1TO1_fow_owner_protocol §7`):** `1 res = 1 m` / `2 m` / `53.333`-derived / one map tile presented as donor cell size; OR/threshold/per-team combine asserted without F-GRID-b; `FOWFillMaxNum`/`FOWDefDov`/`FOWElevation` constants without their arms; slope/blocker list from one transect; sticky-explored or clear-on-capture without F-GRID-d; explored restore in save/load without the save arm; `GetFOWLOSData` domain beyond `>0` or a weakened veto; panel RGBA / `FOWColor` / `CriticalColor` presented as tint; resource `0.5` blend extended to units or terrain; port per-tick FOW rebuild asserted as donor.

---

## 7. Claim register / evidence index

| # | Claim | Label | Evidence |
|---|---|---|---|
| 1 | Pin `t_87f0f3c130b0` / SHA256 `87F0F3C1…4E16C` verified before any finding; target static, never executed/copied | `[D]` | `core_session_show` (§1.1) |
| 2 | The four task literals plus RTTI names are 0-hit in `core_feature_find`; each record self-declares absence-not-proof | `[O]/[D]` | `ev_bca8d8a1…` (full ids below), `ev_ea2f5c36…`, `ev_be8575b2…`, `ev_82b2ed6d…`, `ev_7f1ee50d…`, `ev_2e9534e0…`, `ev_f1080a01…`, `ev_64660c20…`, `ev_f6d87adc…`, `ev_93213c79…`, `ev_87d5d0e6…` |
| 3 | `XFOWRender` @ `0x958d0d`: byte-proven name, `references: []`, 0 functions; 3 other `FOW` hits are `InfoW` false positives | `[D]` | `ev_6a94cc5c…`, `ev_cf3a5636…`, `ev_b731ab32…` |
| 4 | All 9 `LOS` functions are `Close*`/`closesocket` thunks; full dossier of `0x4012e8` proves a Windows import call graph with 0 FOW strings | `[D]` | `ev_6b92caf5…`, `ev_5609cc74…`, `ev_d3dc3929…`, `ev_d62dfac0…`, `ev_c7b52925…`, `ev_dd441ce8…` |
| 5 | Function discovery is self-declared incomplete; `function_not_found` for `0x6a8412`/`XFOWRender` is bounded by that incompleteness | `[D]` | `ev_60b49743…`; tool responses §2 P11 |
| 6 | Prior raw-byte positives (FOWEnable ×3, GetFOWLOSData ×1, FOWBuildFull, binding block, RTTI cluster, offsets) are carried byte-proven facts, not re-lifted; their ids are not in the current ledger | `[D]` | C1–C9; ledger check §2 P14 |
| 7 | No FOW value/behaviour was promoted; every `[U]` keeps its exact zero-mismatch termination; no approximation/port wire | `[O]` | §4, §6, scope guard |
| 8 | `parity.claim = NONE`, `parity.status = "UNVERIFIED"`, `visual_parity_claim = false`; six-condition chain 0/6 CLOSED; `blocking_unverified` non-empty | `[D]` | `PORT1TO1_parity_chain.md:38-58`, `PORT1TO1_parity_recheck.md:44/63`, `PORT1TO1_u_classify.md §6` |

Full LIVE evidence ids (all pinned `t_87f0f3c130b0`, all present in the current ledger):

`ev_bca8d8a1bbccf15c5ed9988c6aa593226233c7b737c7c9f9564f29ab03862cdd` · `ev_ea2f5c36c71ad867f4421f96baed946dae4a566c1e58c49893e3d1f10b867f6f` · `ev_be8575b24af2ca658b9f3c3907485b142a0f9864816c376a39144fee18b08b3e` · `ev_82b2ed6dd18a54a66605e122fb4b0069c5f8fc18a43f50eaa842b4dbd9485737` · `ev_6a94cc5cc44b6f0f42869557966feb97712ca13c6a42d8c45479d4fb4ffb5250` · `ev_7f1ee50d6aa75eac9fa05bab2bb6c961deacdcabe9610aba5fce5d6f8ad155d8` · `ev_2e9534e0e22da824585424252b57d47fc52ea9dbe1f041e01037b1028aa69e0b` · `ev_f1080a016df7d35b0b52fb8c48bd6b35840086db67c48909f7195ad62c00e7cf` · `ev_64660c20d33db8881ea7b8163362de6ed8c3d45b7caa58de94d912ef0c0c22c0` · `ev_f6d87adc9619493ffd853ef6e1636734b2d534a132b63fe0a794b804564d1288` · `ev_93213c79b462c73620d1c4f0732b2d9479e3183265098445d3d88c38495f3737` · `ev_87d5d0e67d60de6f0d0fbf3e90438b26b214a66286a7956efc4c284b3b9ebbab` · `ev_cf3a5636a880286ba891fc835c1bf7967577ae52fb2bc39fb076bcb4adb86cf0` · `ev_b731ab3285a680e58382e42612a15bfed2534d816213dbea9b2fe001367a757f` · `ev_6b92caf5f208771082eae49d7cf0837a78ad93b8006cdfa24c5235653de4ab9d` · `ev_60b497434aa3e6cb68b019fd0a3b016ec0415ef6ec1a3189726faa8d3752f4c4` · `ev_5609cc74bee88c9f89f62853d3111b98dbf357b0bd36d9ce1d96ff78907eae6f` · `ev_d3dc3929ca6f4345084d1738fac0fb37cc04eb02c02d8de565a2c0ae1ed35eef` · `ev_d62dfac09243953fa6ef070bd443bc21578332c6acc48715b8ddec7920e416fc` · `ev_c7b529251111e5d9ecac06fd5c413eb82ce757d9a9546caa47eea0b01ad04a32` · `ev_dd441ce85450f228093cfffe74dc93f8369dad5aefa62d82014961f491e778fe`

---

## 8. Verdict and file discipline

> **Verdict (verbatim governing form):** `port=UNVERIFIED`; `parity.claim = NONE`; `parity.status = "UNVERIFIED"`; `visual_parity_claim = false`; `blocking_unverified` non-empty (P0-1, P0-1b, P0-2, P0-3, P0-4, P0-5, P0-6, P0-7, P0-8 plus the tails); six-condition chain **0/6 CLOSED**. **`RESULT IS NOT GOOD`.** No same-camera donor/port A/B frame exists; no approximation is authorised; no parity claim is made.

- Exactly **one** repository file written: `docs/terrain_swarm_2026-11-26/reports/DEC_U_b14_fow_native.md`. No source/shader/asset/config/test/fixture/result-JSON/backup/queue/Godot/git state touched.
- The donor was opened as a **static** target and read only; it was never executed, copied, patched, captured or attached to a debugger. No `.bind` unpacking. No port behaviour wired.
- N-11/B14 is **class B**: structure, call-graph falsification and absence narrowed; the behavioural/value items remain `[U]` under their owner-only zero-mismatch experiments (§6). Per `PORT1TO1_u_classify.md §5`, a structural closure is not a value closure and never closes a class-A item.

*End of DEC-U-B14-FOW-NATIVE. Read-only; exactly one repository file written; donor never executed; no `.bind` unpacking; parity UNVERIFIED; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty; no parity claim.*
