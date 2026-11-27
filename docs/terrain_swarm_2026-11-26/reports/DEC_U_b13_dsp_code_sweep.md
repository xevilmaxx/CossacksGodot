---
id: DEC-U-B13-DSP-CODE-SWEEP-2026-11-26
worker: "DEC-U-B13-DSP (subagent, full 1:1 Cossacks 3 donor port)"
wave: "PORT1TO1 / terrain_swarm_2026-11-26"
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed, copied or unpacked. No repo code/asset/config/Godot/git edit: this report is the only repository file written."
network: "OUT OF SCOPE. No multiplayer/netcode specified, audited or changed."
parity: "NO PARITY CLAIM. parity.status=UNVERIFIED, parity.claim=NONE, visual_parity_claim=false. Six-condition chain 0/6 CLOSED. RESULT IS NOT GOOD."
context: "B13 angle from PORT1TO1_u_classify.md §4 row B13: extend the CODE-table sweep to neighbouring 0x68xxxx-0x6axxxx prototype runs for any loop bound, stride, index increment or stage call-order literal; pair with the U-S1 census. Governing U-DSP source: DEC_U_tick_deep.md §§2/5. .bind explicitly out of scope."
tooling: "core_session_show, core_text_read, core_feature_find, native_function_study (summary then complete), core_evidence_browse paging, investigation-memory report tools. No native_* tool other than native_function_study was called; no native_bytes_find/native_bytes_show/native_function_find/native_xrefs_list/native_function_disassemble/native_sections_list/native_strings_find."
labels: "[O] observed donor bytes/structure verified by a second pass · [D] deterministic reading of observed structure · [U] UNVERIFIED with exact zero-mismatch termination"
---

# DEC-U-B13-DSP — U-DSP CODE-table sweep extension, `0x68xxxx–0x6axxxx` (2026-11-26)

> **Reviewer line, verbatim governing form:** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> `parity.claim = NONE`; `parity.status = UNVERIFIED`; `visual_parity_claim = false`; six-condition chain **0/6** CLOSED (conditions 2 and 6 PARTIAL port-internal only; 1/3/4/5 BLOCKED); `blocking_unverified` non-empty. Verdict **`RESULT IS NOT GOOD`** unconditionally. Every literal below is a **static byte/structure fact**; none is promoted to live port behaviour and none closes a `[U]` item.

---

## 0. Pin re-assert and sweep boundary [O]

- `core_session_show` at task start: active target `t_87f0f3c130b0`, `cossacks.exe`, `sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`, 5,768,048 B, analysis mode `deep` [O]. Matches the pin in the task verbatim. Binary was not executed or copied at any point.
- Governing context re-read as text only: `PORT1TO1_u_classify.md` (ev_903abe44f734f6998c68377bc213ccc658ce817fbcf3225d00b508f9f885a752 — §4 B13 angle, §5 "class B does not back-door class A") and `DEC_U_tick_deep.md` (ev_33c6adddc612d31751b4b861f8910b1529a9872115cc9be637087f5a1df12d5f — §1 prototype clusters, §2 U-DSP, §5 U-S1/U-DSP captures) [O].
- **Sweep boundary:** `0x68xxxx`, `0x69xxxx`, `0x6axxxx` prototype-table runs *and* every discovered function that falls in or calls into them. `.bind` (`0x96c000–0x98fd70`, entropy 7.96) was **not** unpacked, disassembled or probed. No approximation, no invented value, no static→live promotion.

---

## 1. Method — what was actually swept

| Step | Tool / call | Result |
|---|---|---|
| S1 | `core_feature_find` on `GetPlayerCurrentPlHandle`, `GetPlayerProgressSectionMax`, `ProgressPlayersThread`, `GetPlayerIndexByHandle`, `SetGameTime`, `GetPlayerHandleByIndex` | 0 strings / 0 function names / 0 imports each — the index-vs-CODE split documented in `DEC_U_tick_deep §1` [O] |
| S2 | `core_feature_find` on `sub_68`, `sub_69`, `sub_6a`, `sub_6b` function-name prefixes | Enumerated all discovered functions in/around the band: `0x680008…0x683548` (553), `0x690048`, `0x694140…0x69a70c` (50), `0x6a9060…0x6afe80` (94), `0x6b1a60…` [O] |
| S3 | `native_function_study` summary → complete on `sub_690048`, `sub_68b7d8`, `sub_69a70c`, `sub_686cbc`, `sub_706880`, `sub_694140`, `sub_694590`, `sub_694e10`, `sub_6a94e0`, `sub_6a9060`, `sub_6a9190`, `sub_6a92b0` | Dossiers captured; big facets paged with `core_evidence_browse` [O]/[D] |
| S4 | `core_evidence_browse` on `incoming_references`, `referenced_names`, `callees` and paged `assembly` | Callers, data-reference tables and decode confirmed [O]/[D] |

**Structural conclusion from S2 [D]:** there are **no discovered functions** in the address holes `0x68fxxx–0x690048`, `0x693xxx–0x694140`, `0x69a70c–0x6a9060`, or around `0x693f89`, `0x69faf6`, `0x6a8894`. The prototype ASCII runs named in `DEC_U_tick_deep §1/§3` sit inside these holes, i.e. they are data runs, not code. Every `jump_tables` field observed in this sweep was `0`.

---

## 2. Byte-proven findings `[D]` — each with evidence id and address

### D-1 — Prototype names remain CODE-embedded data, not string-index entries `[D]`
- `core_feature_find` on the six scheduler API names returned **0 hits** each: ev_f3fa9312383d4a9bdb70017226fe4ab8f5a34860a61f1a384844166d78a30f2d (`GetPlayerCurrentPlHandle`), ev_10be4e60abf8cc7ce78d342d67dd2fd8fac6edda2db2480254866bb1d007d780 (`GetPlayerProgressSectionMax`), ev_29c835bf5e67a783f067bb7c70a12c9eb0694ed87b3cbb58604e2f2ebf4cb378 (`ProgressPlayersThread`), ev_784a7b2da414d5443041f1d6f12ab75aa49760a8c26f446a78863226f60c0708, ev_a3dedeba42e3761a0b2657761f959b9e1700add8c5d45aa65c6a13b069c607b4, ev_e6571b340bbc90fffd3a548cc5ea3aea63b755d396259e66afc39f2b09def922. The tool's own limitation is `no_match` → "absence is not proof"; this confirms the index-vs-CODE split, not absence from the binary.
- **No loop bound, stride, index increment or stage-call literal is encoded in these name runs.** They are ASCII prototype text only.

### D-2 — `sub_690048` @ `0x690048` is data-as-code garbage, not a dispatch loop `[D]`
- Dossier ev_cff3794077800a7ee73e71f6efae85d9e6adedb51caa55e719c7dddf8e763928: 8128 instructions, 4539 basic blocks, **0 callers**, 105 callees, 4 incoming references, `jump_tables: 0`, pseudo-C flagged `not_structured` (2648 gotos) and `pseudo_code_inferred`.
- Paged assembly ev_3ffbb0265ac4d5bfc2aa6f408923980cfc5fbe48c3ae0db9d14853333899bd39 (offset 0, 30 of 8128): `0x690048 jns`, `0x69004a and [edx+0x6f],al`, `0x69004d outsd`, `0x69004e insb`, `0x69004f popad`, `0x690051 outsb`, `0x690063 imul ebp,[esi+0x67],0x6f63203b` — the immediate `0x6f63203b` is ASCII bytes `3b 20 63 6f` (`"; co"`), i.e. prototype text decoded as instructions.
- Incoming references ev_8f05eeabd7f00db8ae0ee089a256e32577787d7a839a57d7c9a718415ee357d3: `0x4807a7 (data, sub_480300)`, `0x95550c / 0x9555bc / 0x956400 (pointer, no function)`.
- **No byte-proven loop literal recovered; discarded as code exactly as in `DEC_U_tick_deep §2`.**

### D-3 — Three one-block function-pointer registration tables in the band `[D]`
| Function | Evidence | Shape | Data references (address → target) |
|---|---|---|---|
| `sub_68b7d8` @ `0x68b7d8` | ev_891f7ad8ac9958b4ef577d801ba3f49563c70ff6f0040c92d195db2be0d73d95 (summary), ev_72dcbc450b64298f2a25875cc6cfdda90c9a2bddab8eff216794e1224e0b2c7c (names) | 1 basic block, 1552 instructions, 309 data refs, `jump_tables: 0`, **no loops** | e.g. `0x68b7ed→0x694140`, `0x68b963→0x694590`, `0x68bb50→0x694e10`, … `0x68cbb7→0x69a520` (40 named targets, all `kind:"data"`) |
| `sub_69a70c` @ `0x69a70c` | ev_c70c7d3f34d923de4b445792a0c4f43d24fda2845e65cc1b98a93010859d5dbb (summary), ev_08a10cb28531c3eff6d7e40eb3b9a57c2301b05798df88a7e7938f59659d2c33 (names) | 1 basic block, 3202 instructions, 639 data refs, `jump_tables: 0`, **no loops** | e.g. `0x69a721→0x6a9060`, `0x69a7a9→0x6a9190`, `0x69a831→0x6a92b0`, … `0x69d15d→0x6b8e40` (95 named targets, all `kind:"data"`) |
| `sub_686cbc` @ `0x686cbc` | ev_42d2dcb3655c0b17e93a2a61ef5ad382c51f83689dc4450c6344bc5f2f02b499 | 1 basic block, 662 instructions, 131 data refs, `jump_tables: 0`, **no loops** | 12 named targets, all `kind:"data"` |

- Their "call" counts are lifter artefacts of decoding stored function pointers; every entry is `kind:"data"`. **These tables contain no loop bound, stride, index increment or execution-stage order** — only registration pointers.

### D-4 — Byte-proven fixed **call-order** in `sub_706880` @ `0x706880` `[D]` (semantic class `[U]`, see §3)
- Evidence ev_788f11b14138932ee9639308770a3ea77427114af30ae95499535b621bec4434 (summary + complete dossier, same id): **76 instructions, 1 basic block, 26 calls, 2 callers, `jump_tables: 0`**. This is a linear sequence — no loop, no counter, no bound.
- First 6 calls are indirect through `[esi+0x30]` with fixed name/data-pointer pairs (`0x705a24/0x706984` @`0x706884/0x706889`, `0x705a80/0x7069b0`, `0x705af8/0x7069e0`, `0x705b1c/0x706a08`, `0x705b68/0x706a30`, `0x705bc4/0x706a50`). Then a byte-proven ordered chain of 20 direct calls:
  `0x5fb8c8, 0x601140, 0x633498, 0x65791c, 0x665cc8, 0x67e420, 0x686cbc, 0x608238, 0x68b7d8, 0x69a70c, 0x6b8eb4, 0x6be510, 0x6c5804, 0x6c60ac, 0x6d8954, 0x6e0900, 0x6e7cec, 0x5f84b8, 0x6eb640, 0x6f42e0`.
- **Inside the target band specifically**, the fixed order is `call 0x686cbc @ 0x706916` → `call 0x68b7d8 @ 0x706924` → `call 0x69a70c @ 0x70692b` (call-site addresses byte-proven). Incoming refs confirm both band tables are called only from here: ev_cfb1003ca6c5c45a373ae49ddbf24e7b77d96eb36b8b5c01ae0b3c17d36b7dec (`0x706924 → 0x68b7d8`), ev_59810e0e7596786a4aa752cda1ab7a4600121c60a492e5a10ebaaec85865bcac (`0x70692b → 0x69a70c`).
- **Classification discipline:** the *existence and order of these calls is `[D]` byte-proven*. The interpretation as a per-tick/player **stage** order is `[U]` — `sub_706880` is an API-library **registration/init** routine (its tables hold the `GetPlayer*` / `Progress*` / `Perf*` prototype names), not the per-player DScript dispatch. It is recorded as a call-order literal but **must not** be promoted to the port's tick stage order.

### D-5 — Byte-proven loop machinery in `sub_6a94e0` @ `0x6a94e0` `[D]` (non-dispatch)
- Evidence ev_02acb9f5d989b4d5c2bf045b4dca4882628ffcfd28d62dd928c77815c3452847: 32 instructions, 7 basic blocks, 0 calls, 0 callers, `jump_tables: 0`.
- Byte-proven inner loop `0x6a9501–0x6a9510`: `mov esi,[esi+ecx*4]` (×4 index stride), `mov byte ptr [esi+edx],0`, `inc edx` (`0x6a950e`), `dec eax` / `jne 0x6a9501`; outer loop `inc ecx` (`0x6a9512`), `dec ebx` / `jne 0x6a94f3`.
- **Both bounds are struct fields, not literals:** `ebx = [arg-8]` (`0x6a94e8`), `eax = [arg-0xc]` (`0x6a94f6`). The increments are byte-proven (`inc ecx`, `inc edx`) but this is a generic nested byte-array zeroing routine, **not** a player-slice index, dispatch stride or stage-order literal. Recorded as a byte fact only.

### D-6 — Wrapper thunks adjacent to the tables carry no loop/bound `[D]`
- `sub_694140` (ev_52c97fc1888e408b896ad975856303495adcc2d5992f5e26bbb9281d3cef5b3e), `sub_694590` (ev_62a0200ff215bf8654f8d54162e6b3975b013c63aa74fe9e6f73fc68bc523ff7), `sub_694e10` (ev_891c7624ee8061d93851ab3da4a8bd3e5c11cf1c0f3e176de3c91799649b8267): 4–6 basic blocks each, 3–5 direct calls, fixed field stores (`[eax+0x44]`, `[ebx+0x1c]`, `[ebp-0xc…]`), **no loop, no loop-bound immediate, no index increment, no stage sequence**. Each is referenced only as data from `sub_68b7d8`.

**Net of D-1…D-6:** the extended CODE-table sweep recovered **no additional byte-proven loop bound or stride literal**, **no player-slice index increment**, and **no byte-proven execution-stage call-order literal**. The only byte-proven call-order (D-4) is API registration order, and the only byte-proven index increments/stride (D-5) belong to a memory-zeroing loop. Nothing here establishes DScript dispatch order.

---

## 3. Still `[U]` — exact zero-mismatch termination (pair with the U-S1 census)

All rows below remain `[U]`; a structural byte fact (§2) is **not** a value closure (`PORT1TO1_u_register_update.md:44-45`; `PORT1TO1_u_classify.md §5`). No donor binary was executed, no GPU/GL trace taken, no `.bind` unpacked, and no port harness run by this worker.

| ID | State after B13 | Exact experiment (owner-authorised only; donor binary not executed by workers) |
|---|---|---|
| **U-DSP** | §2: registration tables, garbage decode, registration call order and a zeroing loop only; **no dispatch loop with player-slice bound, stride, index increment or stage order byte-proven** | Static + harness: extend CODE-table sweep (this report) **paired with the U-S1 rotation census** — instrument port `tick()` to record `plind` per per-player firing for **3600 frames × 12 mixed players × 3 seeds**; canonical JSON state-hash per firing (players, entities, projectiles, RNG counters, per-player deadlines, banks, section-max). **Criterion: a byte literal plus a byte-identical reproduction of the R1-anchor/R2-veto deadline-hit sequences for all 3 seeds with 0 mismatches; any single-tick divergence = FAIL.** Otherwise stays `[U]`. No `.bind` unpacking. |
| **U-S1** (census pair) | `DEC_U_tick_deep §4/§5`: one player per firing, native advance; global bookkeeping loops ascending `[O]`; rotation `[U]` | Rotation census as above: candidates (i) 1-per-frame RR ascending, (ii) all-per-frame ascending, (iii) budget-driven. Only the candidate reproducing the deadline-hit sequence for **3 seeds with 0 mismatches** survives. B13 adds no static substitute. |
| **U-THR** | Object names `[O]` (`0x693f89`/`0x6a8894`), per-player iteration list not localized `[U]`; no function exists at either address | Port-side toggle harness: single-threaded ordered pass vs deferred/batched section application; section-max + visitation hash for **3600 frames × 3 seeds**. **0 mismatches** decides; else labelled single-threaded substitute stays. |
| **U-S3 / stage interleave** | No byte-proven tick-stage order in the band | Boundary-permutation harness over the internally-`[O]` blocks, **3 seeds × full skirmish**, **0 hash mismatches**; survivor documented with losers listed. |

U-S7/U-DSP/U-THR permanence note carried from `DEC_U_tick_deep §5`: if engine rotation/dispatch is unobservable from stored bytes + script text, U-S1 stays **PERMANENTLY NATIVE** with the labelled port order kept — no Ghidra/binary edit by any DEC worker.

---

## 4. Claim register and parity status

| # | Claim | Label |
|---|---|---|
| 1 | Pin `t_87f0f3c130b0` / sha256 `87F0F3C1…AF4E16C` re-asserted via `core_session_show`; donor never executed/copied/unpacked. | [O] §0 |
| 2 | Extended sweep covered all discovered functions in `0x68xxxx–0x6axxxx` and the functions that call into them; prototype runs confirmed as CODE-embedded data in function-less holes. | [D] §1/D-1/D-2 |
| 3 | Byte-proven facts D-1…D-6 recorded with evidence ids and addresses; no value invented; no static literal promoted to live port behaviour. | [D] §2 |
| 4 | No additional byte-proven loop bound, stride, player-slice index increment or execution-stage call-order literal found; D-4 call order is registration order, D-5 increments are a zeroing loop. | [D] §2 net |
| 5 | U-DSP / U-S1 / U-THR / U-S3 remain `[U]` with the exact 3600-frame × 3-seed zero-mismatch terminations in §3; class-B static closure never back-doors a class-A value. | [D] §3, `PORT1TO1_u_classify §5` |
| 6 | `.bind` not unpacked; no Godot/gate/replay/harness/donor-execution; exactly one repository file written; parity UNVERIFIED, chain 0/6, no parity claim. | [O] scope guard |

> **Verdict (verbatim governing form):** `port=UNVERIFIED`; `parity.claim = NONE`; `parity.status = "UNVERIFIED"`; `visual_parity_claim = false`; `blocking_unverified` non-empty (P0-1…P0-8 plus tails); six-condition chain **0/6** CLOSED; no donor A/B frame; no COORD ruling. **`RESULT IS NOT GOOD`.** No approximation authorised; no parity claim made.

---

## 5. Explicit non-claims and file discipline

- **NO PARITY CLAIM.** Nothing in this report establishes donor fidelity. All `[D]` rows are static byte/structure readings from the pinned binary; all behavioural items stay `[U]`.
- The extended sweep **does not close U-DSP**, promote any `[U]`, wire any value, or alter the port's labelled tick-order substitute. It narrows structure only.
- The D-4 call order is **not** asserted as a tick stage order; the D-5 increments are **not** asserted as a player-slice index. Both are recorded as byte facts with their semantic class left `[U]`.
- Read-only compliance: exactly one repository file written (this report). Investigation memory was session-only (no project open). No code/asset/config/test/fixture/result/backup/queue file, no Godot process, no runner job, no gate, no replay, no port capture, no git state change, no donor execution/copy/unpack.
- Limits disclosed: `core_feature_find` covers the string index, not CODE bytes (S1 zero-hits are index-vs-CODE, not absence); `native_function_study` pseudo-C is `inferred` and the two giant tables' "calls" are lifter artefacts of data pointers; no binary-side control-flow trace; no `.bind` unpacking.

*End of DEC-U-B13-DSP-CODE-SWEEP. Read-only; exactly one repository file written; no source/asset/config/test/runner/Godot/git/donor-execution; `.bind` untouched; parity UNVERIFIED; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty.*
