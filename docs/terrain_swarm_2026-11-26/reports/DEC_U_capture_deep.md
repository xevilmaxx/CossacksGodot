# DEC_U_capture_deep — READ-ONLY static decomp: donor capture / garrison tail behaviour (2026-11-26)

---
id: DEC-U-CAPTURE-DEEP
worker: CAPTURE-DEEP (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87F0F3C130B027E7C4E72DC217EAE9D592982370D112E0D224897BC92AF4E16C"
donor: "READ ONLY. Donor binary never executed/copied. No repo code/asset/config/Godot/git edit: this report is the only file written. No .bind unpacking. No port behaviour wired."
parity: "PARITY UNVERIFIED. No parity claim. No approximation. No donor GPU A/B frame; no donor binary executed by this worker."
labels: "[D] byte-proven static fact (VA + evidence id + address) · [U] UNVERIFIED runtime-dependent, owner-only zero-mismatch capture termination · zero hits = index-vs-CODE, not disproof"
tooling: "Most native_* pruned. Used ONLY allowed tools: core_target_open (already open) / core_session_show / core_feature_find / native_function_study (summary then complete) / core_evidence_browse (summary paging). No other native_* called."
---

## 0. Pin verification (before any finding) [D]

- `core_session_show` reports active target `t_87f0f3c130b0`, `cossacks.exe`, PE, `bytes 5768048`, `sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c`, `analysis_mode deep`, `clean_room false`, host `windows-x86_64` [D].
- Pin `t_87f0f3c130b0` matches task pin; SHA256 matches task SHA256 case-insensitively (`87F0...` vs `87f0...`) [D].
- Donor binary never executed, copied, or run; all work is read-only static index + lifter dossier reads [D — method].
- Prior work inherited (not re-proven here): `DEC_U_capture_state.md` established capture has NO progress/majority/cooldown — first passing tick flips ownership; garrison tails owner-gated `[U]`. `PORT1TO1_u_classify.md` lists capture/garrison tails among runtime items (class A, `RESULT IS NOT GOOD`, chain 0/6) [D — citation, not new claim].

## 1. Literal search (`core_feature_find`, case-insensitive, whole binary index) [D]

All five queries run against the pinned target. Evidence ids below are the `core_feature_find` records; `core_evidence_browse show=summary` on each returned `all-in-view, at_end true, examined 1 / total 1` (paging complete, nothing truncated).

| # | Query | Result [D] | Evidence id |
|---|---|---|---|
| F1 | `capture` | 3 matching strings, 3 matching function names, 3 matching imports; 3 functions involved | `ev_fd5b6c3cb6e846e1d64b1254f2c9145f7ab8c1d3adb79fe0be3af23f0bbdd0f7` |
| F2 | `garrison` | 0 strings, 0 function names, 0 imports; 0 functions. Limitation `no_match`: text may be built at run time / encrypted / in a resource file; absence is not proof | `ev_84af31c52a1fce5afc75dad874e09b3474cfe3b9f94c5f7eca794aa4ca10f232` |
| F3 | `occupy` | 0 / 0 / 0; 0 functions; same `no_match` limitation | `ev_10b9bd3d7d8206f61354b45f9240d87908653f71b7697147348d3786eb6874c8` |
| F4 | `owner` | 5 matching strings, 0 function names, 0 imports; 0 functions | `ev_81785c5928e938cb7886e737af526256c386e14439b25d95a23d679ef2c63c61` |
| F5 | `conquer` | 0 / 0 / 0; 0 functions; same `no_match` limitation | `ev_b8f23e27c5295322cfe0691ae8ab157caeee8598c02d409163a4ae22eb98f5e8` |

### 1.1 `capture` hits are Win32 mouse-capture thunks, NOT game capture logic [D]

Functions (`ev_fd5b...`):

- `GetCapture@thunk` at `0x40899c` — why: name matches + calls GetCapture [D].
- `ReleaseCapture@thunk` at `0x408cf4` — why: name matches + calls ReleaseCapture [D].
- `SetCapture@thunk` at `0x408d4c` — why: name matches + calls SetCapture [D].

Strings (`ev_fd5b...`) [D]:

- `SetCapture` at `0x9094b4`, `references []` [D].
- `ReleaseCapture` at `0x909550`, `references []` [D].
- `GetCapture` at `0x909c22`, `references []` [D].

Imports (`ev_fd5b...`, all `user32.dll`) [D]:

- `SetCapture`, slot `0x907760`, used_by `0x408d4c` [D].
- `ReleaseCapture`, slot `0x907788`, used_by `0x408cf4` [D].
- `GetCapture`, slot `0x907924`, used_by `0x40899c` [D].

Consequence [D]: the binary text/feature index contains NO `capture`-named game function, NO game string, and NO game import under these five literals. The only `capture` surface is the OS mouse-capture API. Game capture/garrison/ownership logic (if present in CODE) is under names this index does not spell `capture/garrison/occupy/owner/conquer`, or is constructed at runtime — zero hits here are index-vs-CODE, NOT disproof of engine behaviour.

### 1.2 `owner` strings are Delphi/VCL UI strings, not ownership fields [D]

`ev_8178...` records 5 strings, 0 functions, 0 imports [D]:

- `0x954dc8`: ` Failed to get object at index %d"Failed to set tab "%s" at index %d Failed to set object at index %d<MultiLine must be True when TabPosition is tpLeft or tpRight\rInvalid ownerE%d is an PageIndex value.  PageIndex must be between 0 and %d=This control requires version 4.70 or greater of COMCTL32.DLL` — `references []` [D]. The `owner` substring sits inside `Invalid ownerE%d is an PageIndex value` (Delphi tab-control error text), not a game ownership field [D].
- `0x95b8a0`, `0x964cd1`, `0x96506b`, `0x969dce`: each `lbOwnerDrawFixed`, `references []` [D] — VCL listbox draw-mode constant, not game ownership [D].

No owner field offset, no owner function, no owner import recovered from this literal [D].

### 1.3 Zero-hit literals [D with caveat]

- `garrison` (`ev_84af...`), `occupy` (`ev_10b9...`), `conquer` (`ev_b8f2...`): each `0 matching strings, 0 matching function names, 0 matching imports; 0 functions involved`, with engine limitation `no_match: nothing matched; the text may be built at run time, encrypted, or come from a resource file (absence is not proof)` [D].
- Reading [D]: these zeroes constrain ONLY the feature-index text surface. They say nothing about CODE-level capture/garrison implementations, struct fields, or script-side words (script text was the province of `DEC_U_capture_state.md`, not this binary pass). Must NOT be cited as "donor has no garrison/occupy/conquer logic" [D — method rule].

## 2. Function dossiers (`native_function_study`: summary then complete) [D]

All three discovered functions studied with `detail=summary` first, then `detail=complete`. Both phases return the SAME evidence ids (single dossier per function); `core_evidence_browse show=summary` on each dossier returns `all-in-view, at_end true` with counts `assembly 1, basic_blocks 1, body_ranges 1, callees 1, callers 9/1/1, flow_nodes 1`, `referenced_strings 0`, `parameters 0`, `unresolved_calls 0` [D]. Lifter limitations attached to every dossier: `register_level` (machine registers/stack slots; types not recovered), `calling_convention_assumed`, `conditions_from_flags`, `pseudo_code_inferred` (pseudo-C is a reading aid, not compiler output) [D].

### 2.1 `GetCapture@thunk` at `0x40899c` [D]

- Evidence id: `ev_cc2265b95d04a3e8d55206a5d3ab831f7f9e1e72854d8666f4600fc8cab2474c` (summary + complete) [D].
- Body range `0x40899c–0x4089a2`, `size 6`, `basic_blocks 1`, `instructions 1`, `name_source import_thunk`, `thunk_of GetCapture`, `returns false`, `tail_calls 0`, `discovered_by call` [D].
- Assembly (1 insn): `0x40899c: jmp dword ptr [0x907924]` [D].
- Callee: `GetCapture`, `import true`, `site 0x40899c`, `target null` [D].
- Outgoing reference: `0x40899c → 0x907924`, kind `import`, name `__imp_GetCapture` [D].
- Referenced names: `__imp_GetCapture → 0x907924` [D]. Referenced strings: none [D]. Parameters: none [D]. Flow: 1 node (`jmp`), 0 edges/effects [D].
- Callers: 9 incoming references / 9 callers [D]:
  - `sub_45ddec` site `0x45de03`; `sub_47c4d8` site `0x47c4fb`; `sub_47c984` sites `0x47c98a` + `0x47c999` (2 sites, 1 function); `sub_488cb4` site `0x488cb4`; `sub_48fca4` site `0x48fcb7`; `sub_48fd38` site `0x48fe5c`; `sub_5acd50` sites `0x5acd54` + `0x5acd63` (2 sites, 1 function) [D].
- Pseudocode: `void GetCapture@thunk() { return GetCapture(); } /* tail call */` [D — reading aid only].
- Native API: `other: user32.dll GetCapture @ 0x40899c`; `internal_calls []`; `unresolved_indirect_calls 0`, `unresolved_indirect_jumps 0` [D].
- No capture-progress field, no owner field offset, no garrison logic, no string use in this thunk [D].

### 2.2 `ReleaseCapture@thunk` at `0x408cf4` [D]

- Evidence id: `ev_db1c5d06c31c85f2b7afd493b0270209dd25d0d05b73bc78782720e4d54d61d9` [D].
- Body `0x408cf4–0x408cfa`, size 6, 1 block, 1 insn [D].
- Assembly: `0x408cf4: jmp dword ptr [0x907788]` [D].
- Callee: `ReleaseCapture`, import, site `0x408cf4` [D]. Outgoing `0x408cf4 → 0x907788` (`__imp_ReleaseCapture`) [D]. Referenced strings: none; parameters: none [D].
- Callers: 1 — `sub_488cdc` site `0x488cdf` [D].
- Pseudocode: `return ReleaseCapture(); /* tail call */` [D — aid only].

### 2.3 `SetCapture@thunk` at `0x408d4c` [D]

- Evidence id: `ev_592241c1846de7e3ce6f9ee406df9a750cc2939f704a4246fdafcd068c235440` [D].
- Body `0x408d4c–0x408d52`, size 6, 1 block, 1 insn [D].
- Assembly: `0x408d4c: jmp dword ptr [0x907760]` [D].
- Callee: `SetCapture`, import, site `0x408d4c` [D]. Outgoing `0x408d4c → 0x907760` (`__imp_SetCapture`) [D]. Referenced strings: none; parameters: none [D].
- Callers: 1 — `sub_488cdc` site `0x488d17` (same caller function as ReleaseCapture, adjacent sites `0x488cdf` / `0x488d17`) [D].
- Pseudocode: `return SetCapture(); /* tail call */` [D — aid only].

### 2.4 What the dossiers do NOT contain [D]

- Field offsets recovered: NONE (thunks have no struct access; `parameters 0`, `flow_parameter_uses 0`, `flow_parameters []`) [D].
- Game call edges beyond the import jump: NONE (`internal_calls []`, `calls_out 1` = the import only) [D].
- Game strings used: 0 in all three dossiers [D].
- Capture-progress accumulator, majority counter, cooldown timer, garrison capacity, `insideof`/`STO`/order semantics: NOT PRESENT in these three dossiers [D — bounded to these VAs only, not a whole-binary claim].

## 3. Evidence-browse paging ledger [D]

- `core_evidence_browse show=summary` paged for all 8 source records (5 feature-finds + 3 function dossiers): each returns its source summary `all-in-view, at_end true, next_offset null`, with fresh browse ids `ev_7b7a...` (GetCapture), `ev_d8c2...` (Release), `ev_6db4...` (Set), `ev_7304...` (capture find), `ev_bec9...` (garrison find), `ev_ea01...` (occupy find), `ev_fde5...` (owner find), `ev_941f...` (conquer find) [D].
- Big-facet paging (`function-part assembly/callers`, `rows strings`) was attempted through `core_evidence_browse`; the `complete` dossiers already inline the full small facets (1-row assembly, full caller lists §2.1–2.3), so no paged-out rows remain hidden for THESE three thunks (`lists` counts all ≤9, all returned) [D]. Whole-binary caller bodies (`sub_45ddec`, `sub_47c4d8`, `sub_47c984`, `sub_488cb4`, `sub_48fca4`, `sub_48fd38`, `sub_5acd50`, `sub_488cdc`) were NOT studied — out of task scope (task names only discovered functions) and left as future static angle, never as behaviour [D].

## 4. Runtime-dependent items stay [U] (owner-only zero-mismatch termination)

Nothing in §§1–2 observes a game tick, an ownership flip, a garrison entry/exit, or an order-strip. Per task + `DEC_U_capture_state.md` + `PORT1TO1_u_classify.md` (CS-* class A), the following stay `[U]` with exact owner-only capture termination. Donor binary is never executed by this worker; owner/COORD runs the battery.

Conventions (owner-authorised; binary run by owner, never this worker): fixed seed S, fixed map, fixed nation pair, full stock unless varied. Dump per Nothing tick across the capture tick: `TObj.{pl,bbuilt,bdead,statetag,insideofuid,STO,scangridx/y,lasttimecheckcapture}`, `orders[0..11].{iType,produceid,upgradeid,amount,restype,progress}`, player counters/scores/resincome/art/stats, `gScanGrid` membership, `_unit_GetVision`, minimap-primitive presence. Wall-clock IRRELEVANT. Three identical-seed runs; ANY inter-run divergence FAILS the item (quote the divergent dump, do not average).

| # | Item | Static state after THIS ticket | Exact experiment (zero-mismatch) |
|---|---|---|---|
| U-CAP-TIME | Tick timing of ownership flip (which Nothing cadence tick, 1.875 s vs 0.475 s art path) | [U]. §§1–2 recover no timer, no `lasttimecheckcapture`, no cadence constant — expected: cadence law lives in script text (`DEC_U_capture_state.md` §1), not in these thunks | Seed S: lone peasant in radius of empty built barracks, no protectors, `default` mode. Dump `gametime/lasttimecheckcapture/TObj.pl` ±10 Nothing ticks. Pass iff 3 runs identical and flip lands on a `gametime>lasttimecheckcapture` tick with no partial state; quote `lasttimecheckcapture` before/after |
| U-GAR-ARR | Garrison arrival (who may enter what: mine-only vs tower/centre; capacity; reserve slot) | [U]. `garrison` literal 0 hits (§1.3); thunks carry no capacity field (§2.4). Donor absorber law (`peasantabsorber=5`, transport, `CanGoInside`) is script-side per `DEC_U_capture_state.md` §4, NOT re-proven here | Seed S: peasants `OrderGoInside` → mine (expect accept) vs → tower/centre (expect refuse per script law). Dump `insideofuid/STO/visual_hide/insidereserved/inCount` per tick. Pass iff 3 runs identical; quote accepting/refusing call site |
| U-GAR-DONE | Garrison completion (hide effects: scangrid-remove, minimap-remove, `FullClearOrders`, birth-pairing; exit/unhide restore) | [U]. No hide-tag, scan-grid, or minimap literal in these dossiers [D-bounded] | Seed S: 3 peasants `DoHideInside` mine; dump hide-transition effects + unhide restore + death-while-hidden path. Pass iff 3 runs identical; quote branch + tag state |
| U-CAP-SEM | Order semantics on flip (which orders stripped: non-`none`/`move` downto loop; hidden-target strip-skip; STO zeroing ×2; produce/upgrade flush ownership) | [U]. No order array, no STO write, no flush block in these thunks [D-bounded] | Seed S: capture barracks with queued produce×2 + mid-progress upgrade + set rally/STO; mine with 3 insiders. Dump `orders[]` + `STO/bRally` + insider `STO/pl` + `resincome` delta before→after +3 ticks. Pass iff 3 runs identical; quote strip/skip branch |
| U-CAP-FOW | FOW/team/vision attribution after flip (scangrid re-key, AIData/topology, key-colour, selection/ctrlgroup drop, `20+4V` attribution) | [U]. No vision formula, no grid key, no team field in these dossiers [D-bounded] | Seed S: capture building + mine-insider path. Dump `_unit_GetVision`, scangrid membership, minimap presence, selection/ctrlgroups, key-colour. Pass iff 3 runs identical; engine repaint quoted as observation, never as law |

## 5. Non-claims, method limits, and chain status

- NO PARITY CLAIM. `parity.claim = NONE`, `parity.status = UNVERIFIED`, `visual_parity_claim = false` [D — this report].
- No approximation adopted; no `[U]` promoted to `[D]`; no number invented; no `.bind` unpacking; no port behaviour wired; no caller-body semantics asserted (`sub_*` names are lifter labels, not decompiled behaviour) [D — method].
- Incomplete discovery respected: F1–F5 + §§2–3 cover ONLY the feature-index text surface and three import thunks. Zero hits (`garrison/occupy/conquer`, owner functions) are index-vs-CODE and prove no absence. No whole-binary CODE sweep, no xref walk beyond the listed caller sites, no struct-layout recovery was performed or claimed [D].
- Chain: this ticket closes 0 of 6 parity-chain conditions; six-condition chain 0/6 CLOSED. Blocking `[U]` (U-CAP-TIME, U-GAR-ARR, U-GAR-DONE, U-CAP-SEM, U-CAP-FOW, plus script-side CS-* tails) is non-empty [D].
- Verdict: **`RESULT IS NOT GOOD`** — expected for a read-only deep probe that recovers only OS-thunk bytes and honest zeroes; all game behaviour remains owner-harness `[U]` [D].

*End of DEC_U_capture_deep. Read-only; exactly one repository file written; no source/asset/config/test/runner/Godot/git/donor-execution; parity UNVERIFIED; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty.*
