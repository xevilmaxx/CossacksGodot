---
id: DEC-U-DSP-STAGE-ORDER-2026-11-26
worker: "DEC-U-DSP-STAGE (subagent, full 1:1 Cossacks 3 donor port)"
wave: "PORT1TO1 / terrain_swarm_2026-11-26"
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87F0F3C130B027E7C4E72DC217EAE9D592982370D112E0D224897BC92AF4E16C"
donor: "READ ONLY. Donor binary never executed, copied or unpacked. No repo code/asset/config/Godot/git edit: this report is the only repository file written."
network: "OUT OF SCOPE. No multiplayer/netcode specified, audited or changed."
parity: "NO PARITY CLAIM. parity.status=UNVERIFIED, parity.claim=NONE, visual_parity_claim=false. Six-condition chain 0/6 CLOSED. RESULT IS NOT GOOD."
context: "Attack only the remaining tick-stage angle: from PE entry 0x8f1a08 and/or any discovered main-loop/tick function via core_feature_find + native_function_study callers/callees, find a byte-proven per-frame call sequence and compare it to the B13 26-call registration order in sub_706880 (0x686cbc -> 0x68b7d8 -> 0x69a70c). Pair with PORT1TO1_u_classify B13 angle + U-S1 census."
tooling: "core_target_open, core_session_show, core_overview_show (summary), core_feature_find, native_function_study (summary then complete), core_evidence_browse paging, report tools. No native_* other than native_function_study was called; no donor execution/copying/.bind unpacking."
labels: "[O] observed donor bytes/structure verified by a second pass · [D] deterministic reading of observed structure · [U] UNVERIFIED with exact zero-mismatch termination"
---

# DEC-U-DSP-STAGE — tick-stage angle: per-frame call sequence vs 26-call registration order (2026-11-26)

> **Reviewer line, verbatim, governing form:** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> `parity.claim = NONE`; `parity.status = UNVERIFIED`; `visual_parity_claim = false`; six-condition chain **0/6** CLOSED; `blocking_unverified` non-empty. Verdict **`RESULT IS NOT GOOD`** unconditionally. Every literal below is a **static byte/structure fact**; none is promoted to live port behaviour and none closes a `[U]` item.

---

## 0. Pin re-assert and scope [O]

- `core_target_open` on `C:\Games\Cossacks 3\cossacks.exe`: target `t_87f0f3c130b0`, PE, 5,768,048 B, sha256 `87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c` [O]. Matches the task pin verbatim. Binary never executed, copied, or unpacked.
- `core_session_show`: active target `t_87f0f3c130b0`, analysis mode `deep` [O].
- `core_overview_show` (summary) ev_60b497434aa3e6cb68b019fd0a3b016ec0415ef6ec1a3189726faa8d3752f4c4: 18,918 functions, 12,073 strings, 746 imports; **function discovery stopped after 6,000,000 instructions (incomplete), 1,238 indirect jumps unresolved, no local symbols, static-analysis-only** [O]. Governing limitation: zero hits are not disproof; absence is not proof.
- Governing context re-read as text only: `DEC_U_b13_dsp_code_sweep.md` (§2 D-4: `sub_706880` 26-call order `0x686cbc → 0x68b7d8 → 0x69a70c`, classified registration not tick-stage) [O].
- `.bind` (`0x96c000–0x98fd70`) was not unpacked, disassembled, or probed. No approximation, no invented value, no static→live promotion.

---

## 1. Method — what was actually swept

| Step | Tool / call | Result |
|---|---|---|
| S1 | `core_feature_find` on `tick`, `update`, `frame`, `timer`, `message`, `PeekMessage`, `GetMessage`, `DispatchMessage`, `SetGameTime`, `ProgressPlayer`, `WinMain`, `main` | No game main-loop/tick function name discovered; only Win32 thunks (`GetTickCount@thunk`, `FrameRect@thunk`, `SetTimer/KillTimer@thunk`, `PeekMessageA/DispatchMessageA@thunk` ×7/2 callers) and zero-hit scheduler names [O] |
| S2 | `native_function_study` (summary) on PE entry `0x8f1a08` | 18 blocks, 166 instructions, 34 callees, 0 callers; init-shaped, no loop, no tick sequence [O]/[D] |
| S3 | `native_function_study` (summary→complete) + `core_evidence_browse` down the entry tail: `sub_8f0ad4` → `sub_47c3d4` / `sub_47c804` / `sub_47c884` / `sub_47c7ec` / `sub_47cf44` | Entry tail is init/dispatch setup; no per-frame stage order [D] |
| S4 | `native_function_study` on `PeekMessageA@thunk` / `DispatchMessageA@thunk` callers → `sub_47c630`, `sub_5f9b94` and their callers | `sub_47c630` = single-message pump, `sub_5f9b94` = drain-only pump; neither carries game-tick calls [D] |
| S5 | `native_function_study` on `sub_47c6e0`, `sub_47c6c8`, `sub_47d080` + depth-2 callees (`sub_47d008`, `sub_47d5d8`, `sub_47af00`, `sub_488c1c`, `sub_47d240`, `sub_47cfa4`, `sub_42dc50`) | Byte-proven idle-branch per-iteration sequence recovered (§2, D-2); compared set-for-set against the 26-call list (§3) [D] |
| S6 | `native_function_study` on `sub_706880` + `sub_706550` + `sub_7069e0` callers/callees | Registration order re-verified byte-for-byte; both registration callers are discovered-graph roots (0 callers); no byte-proven path from the entry/idle chain to `sub_706880` [D] |

Structural note [D]: every `jump_tables` field observed in this sweep was `0`; several per-iteration functions carry `unresolved_indirect_calls` (1–2 each), so the discovered call graph is a lower bound, not a closed whole.

---

## 2. Byte-proven findings `[D]` — each with evidence id and VA

### D-1 — Entry `0x8f1a08` is init-shaped; no per-frame stage order [D]

- Evidence ev_deb2a847852bb677495cc382f81c91c3e25629b454a1383adfd3b99bde21b80c (summary + paged `callees`/`assembly`/`referenced_names`): 18 blocks, 166 instructions, **34 callees, 0 callers**, `jump_tables: 0` [D].
- Ordered head: `call 0x407d98 @0x8f1a1d` → `call 0x4182ac @0x8f1a30` → `call 0x6075d4 @0x8f1a37` → `call 0x607758 @0x8f1a42` → `call 0x408154 @0x8f1a62`, then error-branch `MessageBoxA meliputi GetLastError` checks, then tail `call sub_47cf44 @0x8f1ae3`, `call sub_40d0a4 @0x8f1aee`, `call sub_40d65c @0x8f1af6`, `call sub_4c37dc @0x8f1b04`, `call sub_4c3c90 @0x8f1b2c`, `call sub_47c7ec @0x8f1b38`, `call sub_405454 @0x8f1b54`, **`call sub_8f0ad4 @0x8f1b65`**, `call sub_47c804 @0x8f1b7d`, `call sub_47c884 @0x8f1b99`, `call sub_404574 @0x8f1ba0` [D].
- No loop, no counter, no bound literal, no `686cbc/68b7d8/69a70c` or other 26-list target appears in the 34 callees [D].
- `sub_8f0ad4` @`0x8f0ad4` (ev_59075bc1ee24706ff4db8aef363f1a5a0b05992c835ec65f47908c94ac16fcd7): 1 block, 25 instructions, 3 callees (`sub_4058b0 @0x8f0ae1`, `sub_47c3d4 @0x8f0af9`, `sub_405400 @0x8f0b0e`), 1 caller (`entry @0x8f1b65`) [D]. Pure setup trampoline.

### D-2 — Byte-proven per-iteration (idle-branch) call sequence in `sub_47d080` [D]

- Chain into it [D]: `sub_47c884` @`0x47c884` (ev_370072e06df1a030592b2b116abcb6295ab8669a1fc344b27a2607c7476039c9: 12 blocks, 67 insns, 5 callees) → `call sub_47c6e0 @0x47c91a` → `sub_47c6e0` @`0x47c6e0` (ev_982cfe5cc2dad6d1e33fb26325487a54c41a6724f08b3bb56d41384b48fa0586: 3 blocks, 14 insns) does `call sub_47c630 @0x47c6ea` (message pump; if message handled, return) else **`call sub_47d080 @0x47c6f7`** (idle work) [D].
- `sub_47c630` @`0x47c630` (ev_7cf272b44f0dda515f9f329fa8fd7f3987166167dc4d651eeeaa40b3fc4d9923: 12 blocks, 59 insns, 8 callees): `call PeekMessageA @0x47c643` → conditional indirect `call [esi+0xd8] @0x47c66c` → `call sub_47c590 @0x47c676` → `call sub_47c488 @0x47c689` → `call sub_47c4d8 @0x47c696` → `call sub_47c464 @0x47c6a3` → `call TranslateMessage @0x47c6ad` → `call DispatchMessageA @0x47c6b3` [D]. Single-message pump, not a tick loop. Sibling `sub_47c6c8` (ev_d6a463f2c1df61a070ae9dbb7adb654f8b16fd6edf46949f08f10c72040c2f74) spins `call sub_47c630 @0x47c6d2` only [D]. `sub_5f9b94` (ev_5bcf714bc12252ea7236aae3aacb9d6df03791bcb49e41cdb4326ee1ec6cd440: 5 blocks, 30 insns) is a `PeekMessageA @0x5f9bd3` drain around `TranslateMessage @0x5f9bb3` / `DispatchMessageA @0x5f9bbc` only — no game-tick callee [D].
- `sub_47d080` @`0x47d080` (ev_66dcb7096525c52838b2ba1fea7ff9841e0b79090c6d78434d8602c017b604b3: 14 blocks, 81 insns, 11 callees, 1 caller `sub_47c6e0 @0x47c6f7`) byte-proven order [D]:
  `call sub_47d008 @0x47d0a5` → [`call sub_47d5d8 @0x47d0c4` iff `[eax+0x88]!=0` and `[eax+0x48]==0`] → `call sub_47af00 @0x47d0ce` → `call sub_488c1c @0x47d0d9` → `call sub_47d240 @0x47d0e6` → [`call [ebx+0x100] @0x47d119` indirect] → [`call sub_47cfa4 @0x47d128` iff flag] → `call GetCurrentThreadId @0x47d14c` → `call sub_42dc50 @0x47d15d` → [`call WaitMessage @0x47d170` iff idle] [D].
- Depth-2 expansion (all `[D]`, callees paged): `sub_47d008` (ev_2116e9ec14392b781dd2c0aced475fb3c08bd4caf91d1e18e4decb5f9639ed46) → `{GetCursorPos @0x47d011, sub_48a3b8 @0x47d01a, sub_488cb4 @0x47d021, sub_48ccf0 @0x47d04c/@0x47d073}`; `sub_47d5d8` (ev_c3aa4dd18cba6053553bedd1623c3d6d3148e6e027729bd1f79068b5f6b2aed4) → `{sub_47d594 @0x47d5e3, sub_47b0c0 @0x47d5f1, sub_47d424 @0x47d5f8}`; `sub_47af00` (ev_8b130a1a3b5896ddb01a0a147ecf2f34131815c84ba5374987e809b5901f75d9) → `{sub_405454, sub_405400}`; `sub_488c1c` (ev_5fcef7adeadbba06047bedd9af943fd946864716f89c7878597e9873add518b7) → `{sub_411b90, sub_405454, sub_405920}`; `sub_47d240` (ev_751823df0752d6b510e9acd03c272aa345fb7d65c2c8eb4a229222dfb3351f30) → `{sub_40580c, sub_405454, sub_46e314, sub_470700, sub_40477c, sub_404574}` + 1 indirect; `sub_47cfa4` (ev_4121c449d70242964ce5a981391042e9d02613df8831c160c4a8e3788aea31ba) → `{sub_47a26c, sub_47a258, sub_492628, sub_492324, IsWindowVisible, IsWindowEnabled}` + 1 indirect; `sub_42dc50` (ev_64155b6f7099aa05e0621508969c171953bf6ec2dc89353b433a50581be57606) → thread/critical-section + `{sub_410ecc, sub_404d54, sub_42dc10/42dc04/42dd71, sub_424d50, sub_424bf0}` + 1 indirect [D].
- This is a byte-proven per-iteration work sequence (message-pump-miss branch), but its semantic class as *the* tick-stage order is `[U]` (see §3): several steps are conditional and three nodes carry unresolved indirect calls.

### D-3 — 26-call registration order re-verified; disjoint from the per-iteration sequence [D]

- `sub_706880` @`0x706880` (ev_8377e5b8abd30bf6164b691a3795d6f0fe9d00f30690161c931861b8a80e2b5f: 1 block, 76 insns, 26 calls, 2 callers, `jump_tables: 0`) callees byte-for-byte identical to B13 D-4: 6 indirect through `[esi+0x30]` (@`0x706884/0x706889/0x7068b4/0x7068c5/0x7068d6/0x7068e7`) then 20 direct `sub_5fb8c8 @0x7068ec`, `sub_601140 @0x7068f3`, `sub_633498 @0x7068fa`, `sub_65791c @0x706901`, `sub_665cc8 @0x706908`, `sub_67e420 @0x70690f`, **`sub_686cbc @0x706916`**, `sub_608238 @0x70691d`, **`sub_68b7d8 @0x706924`**, **`sub_69a70c @0x70692b`**, `sub_6b8eb4 @0x706932`, `sub_6be510 @0x706939`, `sub_6c5804 @0x706940`, `sub_6c60ac @0x706947`, `sub_6d8954 @0x70694e`, `sub_6e0900 @0x706955`, `sub_6e7cec @0x70695c`, `sub_5f84b8 @0x706963`, `sub_6eb640 @0x70696a`, `sub_6f42e0 @0x706971` [D].
- Set comparison [D]: **none** of the 20 direct targets and none of `0x686cbc/0x68b7d8/0x69a70c` appear anywhere in the D-2 per-iteration sequence or its depth-2 expansion; **none** of the D-2 nodes (`47d008/47d5d8/47af00/488c1c/47d240/47cfa4/42dc50` or their depth-2 targets) appear in the 26-call list. Intersection is byte-proven **empty** at the studied depth [D].
- Registration callers [D]: `sub_706550 @0x706630` (ev_b8bd643e3a1c1bfce14c2854520b80fc14866b88632686c8b1d31b2c94937764: 5 blocks, 120 insns, 20 callees incl `call sub_706880 @0x706630`) has **0 callers**; `sub_7069e0 @0x706af3` (ev_bb60e3ded91c99e6c15dd448e5d956704e9ab35e8ab16231c1e61f87f7d621c3: 32 blocks, 115 insns, 14 callees incl `call sub_706880 @0x706af3`) has **0 callers** in the discovered graph [D]. No byte-proven caller path from the entry/idle chain (`0x8f1a08 → … → 47c884 → 47c6e0 → 47d080`) to `sub_706880` was found in the discovered graph [D]. Roots-without-callers is consistent with init/registration placement, but the *absence* of a path is bounded by incomplete discovery (§0) and is not asserted as disproof (stays `[U]`, §3).

### D-4 — Scheduler-name searches are index-zero, not binary-absent [D]

- `core_feature_find`: `tick` ev_3a18a08c8551e143d66fb0cf9d17f890ce9dcc4369943bdaef44ba7d6454d9e (only `GetTickCount@thunk` ×2 + `TickMarks` strings); `update` ev_1dee29de95903d858cfa028f4a5d5c63d8dbb83c52d9de5b310f4aaed031d8f (0 functions; `UpdateWindow` import unconsumed); `frame` ev_259760104f1a59115e448dab360cd6f5d1912d6e87f757329e00a075d348978 (only `FrameRect@thunk`); `timer` ev_530df331f2c3704374ebab760e0cf982079a6e056861ed2c34858847cf5e7c (`SetTimer/KillTimer@thunk`); `message` ev_389ad74bb32ed7758449efce4ee61343d53a75afefc39d347da9c9b2be89513e (14 Win32 thunks); `SetGameTime` ev_a3dedeba42e3761a0b2657761f959b9e1700add8c5d40aa66a13b069c607b4 = 0 hits; `ProgressPlayer` ev_de213ac38d0028609bd332544230997d14bf4b9e933def73b075f15fd65a = 0 hits; `PeekMessage` ev_79b13817716694dbe8f8aac05e8c22aada69cdb3d9379bfa10ed7075fa718a0 / `DispatchMessage` ev_323885afeb360fc0ece11f6a64d7e5b22931280947d47a40819c943947e27b68 (thunks only) [D]. Per B13 §1/§5 and the tool's own `no_match` limitation, these confirm index-vs-CODE split, not absence from the binary [D].

---

## 3. Still `[U]` — exact zero-mismatch termination (pair with the U-S1 census)

All rows below remain `[U]`; a structural byte fact (§2) is **not** a value closure (`PORT1TO1_u_register_update.md:44-45`; `PORT1TO1_u_classify.md §5`). No donor binary was executed, no GPU/GL trace taken, no `.bind` unpacked, and no port harness run by this worker.

| ID | State after this angle | Exact experiment (owner-authorised only; donor binary not executed by workers) |
|---|---|---|
| **U-DSP** | D-2 per-iteration sequence and D-3 registration order both byte-proven as *call sets*, but their semantic classes are unlinked: intersection empty at studied depth, no caller path entry/idle → `706880`, and three per-iteration nodes carry unresolved indirect calls (`@0x47c66c`, `@0x47d119`, plus depth-2 indirects) that incomplete discovery (6M stop, 1238 unresolved) may hide targets behind | Static + harness: extend this angle **paired with the U-S1 census** — instrument port `tick()` to record `plind` per per-player firing for **3600 frames × 12 mixed players × 3 seeds**; canonical JSON state-hash per firing (players, entities, projectiles, RNG counters, per-player deadlines, banks, section-max). **Criterion: a byte literal plus a byte-identical reproduction of the R1-anchor/R2-veto deadline-hit sequences for all 3 seeds with 0 mismatches; any single-tick divergence = FAIL.** Otherwise stays `[U]`. No `.bind` unpacking. |
| **U-S1** (census pair) | Unchanged by this angle; global bookkeeping loops ascending `[O]`, rotation `[U]` | Rotation census as above: candidates (i) 1-per-frame RR ascending, (ii) all-per-frame ascending, (iii) budget-driven. Only the candidate reproducing the deadline-hit sequence for **3 seeds with 0 mismatches** survives. This report adds no static substitute. |
| **U-S3 / stage interleave** | D-2 is a per-iteration work order, D-3 is registration order; **neither is byte-proven as the tick-stage order**, and their intersection is empty — so no stage-interleave literal is established | Boundary-permutation harness over the internally-`[O]` blocks, **3 seeds × full skirmish, 0 hash mismatches**; survivor documented with losers listed. |
| **U-THR** | Per-player iteration list not localized by this angle | Port-side toggle harness: single-threaded ordered pass vs deferred/batched section application; section-max + visitation hash for **3600 frames × 3 seeds**. **0 mismatches** decides; else labelled single-threaded substitute stays. |

U-S7/U-DSP/U-THR permanence note carried from `DEC_U_tick_deep §5`: if engine rotation/dispatch is unobservable from stored bytes + script text, U-S1 stays **PERMANENTLY NATIVE** with the labelled port order kept — no Ghidra/binary edit by any DEC worker.

---

## 4. Claim register and parity status

| # | Claim | Label |
|---|---|---|
| 1 | Pin `t_87f0f3c130b0` / sha256 `87F0F3C1…AF4E16C` re-asserted via `core_target_open`; donor never executed/copied/unpacked. | [O] §0 |
| 2 | No game main-loop/tick function name discovered via scheduler/message/timer/frame/update searches; only Win32 thunks + zero-hit scheduler names (index-vs-CODE, not absence). | [D] §2 D-4 |
| 3 | Entry `0x8f1a08` dossier + ordered callee head recorded with evidence id; init-shaped, no stage order. | [D] §2 D-1 |
| 4 | Per-iteration chain `47c884 → 47c6e0 → (47c630 pump \| 47d080 idle)` and full `47d080` ordered sequence + depth-2 expansions recorded with evidence ids and VAs. | [D] §2 D-2 |
| 5 | 26-call registration order re-verified byte-for-byte; caller roots `706550/7069e0` have 0 callers; set-intersection with D-2 empty at studied depth; no caller path entry/idle → `706880` in the discovered graph. | [D] §2 D-3 |
| 6 | No per-frame call sequence matching the 26-call registration order found; no stage order invented; no port value wired; U-DSP / U-S1 / U-S3 / U-THR remain `[U]` with the exact 3600-frame × 3-seed zero-mismatch terminations in §3; class-B static closure never back-doors a class-A value. | [D] §3, `PORT1TO1_u_classify §5` |
| 7 | `.bind` not unpacked; no Godot/gate/replay/harness/donor-execution; exactly one repository file written; parity UNVERIFIED, chain 0/6, no parity claim. | [O] scope guard |

> **Verdict (verbatim governing form):** `port=UNVERIFIED`; `parity.claim = NONE`; `parity.status = "UNVERIFIED"`; `visual_parity_claim = false`; `blocking_unverified` non-empty (P0-1…P0-8 plus tails); six-condition chain **0/6** CLOSED; no donor A/B frame; no COORD ruling. **`RESULT IS NOT GOOD`.** No approximation authorised; no parity claim made.

---

## 5. Explicit non-claims and file discipline

- **NO PARITY CLAIM.** Nothing in this report establishes donor fidelity. All `[D]` rows are static byte/structure readings from the pinned binary; all behavioural items stay `[U]`.
- The D-2 idle-branch sequence is **not** asserted as the tick stage order; the D-3 26-call order is **not** asserted as a per-frame order (B13 classification stands: API registration order). Their empty intersection is a studied-depth set fact, not a whole-binary proof — unresolved indirects (`@0x47c66c`, `@0x47d119`, depth-2 indirects) plus the 6M-instruction stop and 1,238 unresolved jumps bound every negative statement.
- No value was wired into the port; no `[U]` was closed or promoted.
- Read-only compliance: exactly one repository file written (this report). Investigation memory was session-only (no project open). No code/asset/config/test/fixture/result/backup/queue file, no Godot process, no runner job, no gate, no replay, no port capture, no git state change, no donor execution/copy/unpack.
- Limits disclosed: `core_feature_find` covers the string index, not CODE bytes (S1 zero-hits are index-vs-CODE, not absence); `native_function_study` pseudo-C is `inferred` and counts are lifter readings; no binary-side control-flow trace; no `.bind` unpacking.

*End of DEC-U-DSP-STAGE-ORDER. Read-only; exactly one repository file written; no source/asset/config/test/runner/Godot/git/donor-execution; `.bind` untouched; parity UNVERIFIED; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty.*
