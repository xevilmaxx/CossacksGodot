# PORT1TO1 — Packet re-read (read-only verification)

- id: PORT1TO1-packet-reread-2026-11-27
- worker: PACKET-REREAD (read-only verification)
- date: 2026-11-27
- sources: `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_terrain_gap_packet.md` (corrected packet, id `PORT1TO1-terrain-gap-packet-2026-11-27`, 257 lines); `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_terrain_statverify.md` (id `PORT1TO1-terrain-statverify-2026-11-27`); `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_claim_recheck14.md` (id `PORT1TO1-CLAIM-RECHECK14-2026-11-27`, §7 GAP-CORRECT diff audit)
- parity: **UNVERIFIED. No parity claim. No approximations.**
- chain: **0/6. Nine P0 OPEN. `blocking_unverified` non-empty ⇒ RESULT IS NOT GOOD.**
- method: read-only end-to-end re-read. No code/Godot/git/donor execution. Exactly one file written (this report); no other edits. No packet edit, no label change proposed beyond label-only remediation column (all PASS here → none required).

## 1. Item-by-item verdict (31 items: MW-1…MW-11, NG-1…NG-6, AN-1…AN-5, AP-1…AP-9)

Rule per item: classification matches STATVERIFY exactly; (a) gap, (b) evidence/governs, (c) class, (d) action/condition, (e) P0-effect lines intact; no `[U]` residual dropped; no zero-mismatch condition weakened; no AP id renumbered.

### MW rows (11)

| Item | Packet site | STATVERIFY site | Verdict |
|---|---|---|---|
| MW-1 | packet `:22-27` (a) no matched-seed donor GPU frame / no file found; (b) HANDOFF §4 GR-C08 / V15 §2 / V57 / X39 / X07/X36; (c) OWNER-GPU-RUNTIME; (d) produce-or-rule-out + zero-mismatch `provenance fields all present and matching, no substitute frame accepted`; (e) narrows only | statverify `:9` + `:45` out-of-scope owner-only list | **PASS** — classification exact; (a)–(e) + zero-mismatch intact; `[U]` tail (frame-or-memo) kept open |
| MW-2 | packet `:29-34` (a) no fresh gate verdicts / TODO(COORD) unfilled / harness PRESENT-not-run + PENDING markers + unadjudicated captures; (b) V21/V06/V42/V63/V76/V83/V86 + GR-A04…A24; (c) OWNER-GPU-RUNTIME; (d) A′-0…A′-3 then D-0…D-6 with unique job ids + zero-mismatch `no skipped atom, no stale JSON, no --ignore-history`; (e) can close P0 rows only via gates + MW-11 | statverify `:9` + `:45` out-of-scope | **PASS** — classification exact; (a)–(e) + zero-mismatch intact |
| MW-3 | packet `:36-41` (a) N7 no file + spec-copy no file + SCHEMA-ONLY null/signed:false + I05 DRY-RUN + atlas UNVERIFIED; (b) I16/N17/I05/A03/V62/V66/spec-11; (c) WORKER-EXECUTABLE-STATIC + OWNER-GPU-RUNTIME split; (d) write N7 + populate bands + `--write` + byte-verify + hashes + zero-mismatch `no null band, signed only where real, no DRY-RUN claimed as output`; (e) narrows only | statverify `:16` STILL OPEN, "No change … Split stands" | **PASS** — split exact; (a)–(e) + zero-mismatch intact; `[U]` (hashes/validation) kept open |
| MW-4 | packet `:43-48` (a) sizes not proven exact / native-mask override / 64²-as-256² + 240² class; (b) W09 TG-1 / HANDOFF §9.2 / spec-10 / V06; (c) OWNER-GPU-RUNTIME; (d) terminating byte probe 64²/240²/320² + baselines + zero-mismatch `exact grid integers, no relabelled baseline`; (e) closes row only via probe + gate | statverify `:9` + `:45` out-of-scope | **PASS** — classification exact; (a)–(e) + zero-mismatch intact |
| MW-5 | packet `:50-55` (a) runtime UNVERIFIED despite dual-read + line cites + `[U]` FLOAT_WINDOWS; (b) W03/V07 E06-E17/spec-04/HANDOFF §9.2; (c) WORKER-EXECUTABLE-STATIC + OWNER-GPU-RUNTIME split; (d) re-verify + prove feed/stamps/float-windows + zero-mismatch `no fallback masking a miss, no fudge factor`; (e) narrows only until proof + gate | statverify `:17` STILL OPEN, "No change … Split stands" (joint MW-5/NG-3 row) | **PASS** — split exact; (a)–(e) + zero-mismatch intact; `[U]` FLOAT_WINDOWS kept open |
| MW-6 | packet `:57-62` (a) native bodies unrecovered / synthetic vectors / `[U]` pass count; (b) N17-G11/U-S0/TODO-D01/D03-U3/V20-S08/D08/V16-O11/X13-X26-X37; (c) WORKER-EXECUTABLE-STATIC + OWNER-GPU-RUNTIME + OWNER-DECISION triple; (d) recover body/counts/pass-count/selector/planes/packing + zero-mismatch `no synthetic flag presented as donor, no blur substituted silently`; (e) narrows only / parks via ruling | statverify `:18` STILL OPEN, "No change" triple | **PASS** — triple exact; (a)–(e) + zero-mismatch intact |
| MW-7 | packet `:64-69` (a) fail-closed water lines cited; (b) D06/X11/DEC_U-water/protocol/X51; (c) OWNER-GPU-RUNTIME + OWNER-DECISION; (d) captures-or-scope-memo + zero-mismatch `no grey/neutral fallback invented, no candidate constant presented as live uniform`; (e) closes water rows only via captures + gate | statverify `:9` + `:45` out-of-scope | **PASS** — classification exact; (a)–(e) + zero-mismatch intact |
| MW-8 | packet `:71-76` (a) zero-props predicted + feed defects + double-instance risk + GR-A24 atom absent; (b) I09/V59/W07/V66-F1/V13/spec-08/V16-26-27; (c) WORKER-EXECUTABLE-STATIC + OWNER-DECISION + OWNER-GPU-RUNTIME triple; (d) walk/fix/I09-keys/repoint + zero-mismatch `zero dropped scales/Y without recorded reason`; (e) closes row only via live proof + gate | statverify `:19` STILL OPEN (joint MW-8/AP-1 row), "No change" | **PASS** — triple exact; (a)–(e) + zero-mismatch intact; `[U]` matched_stamps>0 kept open |
| MW-9 | packet `:78-83` (a) activation/binding unproven + quarantines preserved; (b) F07-F08/V12/X22/A04-§8/spec-07-08/V16-O2-O5; (c) WORKER-EXECUTABLE-STATIC + OWNER-GPU-RUNTIME + OWNER-DECISION; (d) settle activation/binding without touching quarantines + zero-mismatch `quarantines byte-identical, no fix to donor bytes`; (e) narrows only | statverify `:20` STILL OPEN, "No change" | **PASS** — triple exact; (a)–(e) + zero-mismatch intact |
| MW-10 | packet `:85-90` (a) 19 OPEN contradictions + I03 F-01 breach + I14/I15 no-file + spool unacked; (b) V16/V17/V26/V47/V34/V44/V56/V64/V72/V81/V95/V98/X44; (c) OWNER-DECISION governs + WORKER-EXECUTABLE-STATIC support; (d) fold READY + resolve 19 + settle F-01 + define/record I14-I15 + ack spool + zero-mismatch `every O-item ruled or proven, none silently dropped`; (e) closes process rows only, never class-A | statverify `:21` STILL OPEN, "No change: OWNER-DECISION governs" | **PASS** — classification exact; (a)–(e) + zero-mismatch intact |
| MW-11 | packet `:92-97` (a) captures exist, verdicts do not + 240c stale + W06 unadjudicated; (b) A05/V15/W01-W06-W08/HANDOFF-GR-C/tier-2 cards; (c) OWNER-GPU-RUNTIME + OWNER-DECISION; (d) signed per-card verdicts + zero-mismatch `no metric overriding visual read, stale 240c re-captured or excluded`; (e) can close P0 rows with MW-2 | statverify `:9` + `:45` out-of-scope | **PASS** — classification exact; (a)–(e) + zero-mismatch intact |

### NG rows (6)

| Item | Packet site | STATVERIFY site | Verdict |
|---|---|---|---|
| NG-1 | packet `:101-106` (a) tiers PRESENT-but-UNVERIFIED; (b) A03/I05/V62-V66-V87/spec-11; (c) WORKER-EXECUTABLE-STATIC; (d) byte-validate + `--write` record + hashes + zero-mismatch `no DRY-RUN output claimed as final`; (e) narrows only | statverify `:22` STILL OPEN, "No change" | **PASS** |
| NG-2 | packet `:108-113` (a) captures populated-but-unadjudicated + PENDING markers; (b) I13/I16/N18/N19/W01-W08-W09-W10; (c) OWNER-GPU-RUNTIME; (d) per-capture verdict + gate PASS/FAIL + zero-mismatch `no unadjudicated file counted as proof`; (e) narrows only until MW-11 | statverify `:9` + `:45` out-of-scope | **PASS** |
| NG-3 | packet `:115-120` (a) build + runtime proof missing (MW-5 lines); (b) W03/HANDOFF-§9.2/spec-04; (c) WORKER-EXECUTABLE-STATIC + OWNER-GPU-RUNTIME; (d) re-verify + post-fix capture + zero-mismatch `both names confirmed, no alias assumed`; (e) narrows only | statverify `:17` joint MW-5/NG-3 row, STILL OPEN, split stands | **PASS** |
| NG-4 | packet `:122-127` heading "STATIC WRITE-PATH RESOLVED; engine-consumption STILL OPEN per STATVERIFY"; (a) cliff TAG + consumption unproven; (b) A01/V58/spec-01; (c) WORKER-EXECUTABLE-STATIC — RESOLVED (static write-path only) per STATVERIFY §1 NG-4 + OWNER-GPU-RUNTIME (STILL OPEN); (d) "static write-path needs no further work — prove cliff TAG + engine consumption" + zero-mismatch `all four tags demonstrated, none assumed from code`; (e) narrows only | statverify `:23` RESOLVED (static write-path only) / STILL OPEN (runtime proof), "No change … Split stands" | **PASS** — GAP-CORRECT resolution carried exactly; runtime `[U]` tail kept open; zero-mismatch intact |
| NG-5 | packet `:129-134` (a) fail-closed discipline; (b) D06/X11/DEC_U-water/protocol; (c) OWNER-DECISION + OWNER-GPU-RUNTIME; (d) bindings-or-scope + zero-mismatch `no silent fallback`; (e) narrows only | statverify `:9` + `:45` out-of-scope | **PASS** |
| NG-6 | packet `:136-141` (a) six absences incl. tiles/N7/spec-copy/retired-alias/baselines/frame — all no-file-found; (b) I12/I16-N17/V37/MW-2-MW-4/GR-C08; (c) WORKER-EXECUTABLE-STATIC + OWNER-DECISION + OWNER-GPU-RUNTIME triple; (d) create-or-rule + zero-mismatch `no absent path cited as evidence`; (e) narrows only (runtime closes via MW-2/MW-4/MW-11) | statverify `:24` STILL OPEN, "No change" triple | **PASS** — six-absence list intact, retired-alias note intact |

### AN rows (5)

| Item | Packet site | STATVERIFY site | Verdict |
|---|---|---|---|
| AN-1 | packet `:152-157` heading "MISCLASSIFIED-RESOLVED (count-definition difference; [U]-G1 per-name cross-check STILL OPEN per STATVERIFY)"; (a) index incompleteness 668 vs 680; (b) F02/X05 + spec-11 A11.4 (NEW-1); (c) WORKER-EXECUTABLE-STATIC (ledger-only) — MISCLASSIFIED-RESOLVED, arithmetic closed 668+12=680, [U]-G1 STILL OPEN; (d) ledger-only per-name check + zero-mismatch `no section silently absent`; (e) narrows only (feeds AP-1) | statverify `:25` MISCLASSIFIED, arithmetic closed, [U]-G1 OPEN | **PASS** — misclassification wording exact; `[U]-G1` zero-mismatch tail (`0 of 12 as keys`, `no duplicate-name collapse`) kept open |
| AN-2 | packet `:159-164` heading "EXISTENCE RESOLVED (48/48); byte verification [U]-G2 STILL OPEN per STATVERIFY"; (a) stem-to-bytes unproven + per-family listing gap; (b) DEC_U-death A3–A5 (NEW-2); (c) WORKER-EXECUTABLE-STATIC — EXISTENCE RESOLVED 48/48, [U]-G2 STILL OPEN; (d) existence closed, remaining byte-verification only + zero-mismatch `every stem resolves to bytes or is marked ABSENT, no assumed conversion`; (e) narrows only (feeds AP-3) | statverify `:26` RESOLVED (existence) / STILL OPEN ([U]-G2) | **PASS** — existence-vs-bytes split exact; `[U]-G2` tail kept open |
| AN-3 | packet `:166-171` (a) no mapping file + PNGs without manifest; (b) X16-A3–A5 + spec-11 (NEW-3); (c) WORKER-EXECUTABLE-STATIC + OWNER-GPU-RUNTIME; (d) per-BaseName manifest + zero-mismatch `no PNG claimed wired without manifest row`; (e) narrows only (feeds AP-2/AP-8) | statverify `:27` STILL OPEN, "No change", [U]-GRASS OPEN | **PASS** |
| AN-4 | packet `:173-178` (a) index-vs-resolver mismatch + orphans + `[U]` U2/B; (b) DEC_U-aaf A5 + DANIM_01 A3–A5 (NEW-4); (c) WORKER-EXECUTABLE-STATIC + OWNER-GPU-RUNTIME; (d) 66×40 matrix + orphan plan + zero-mismatch `no action marked supported without frame lists`; (e) narrows only (feeds AP-4) | statverify `:28` STILL OPEN, "No change", [U]-ACT-COVERAGE OPEN | **PASS** |
| AN-5 | packet `:180-185` heading "MISCLASSIFIED-RESOLVED for desert_frt_un; sibling desert_forests_big [U]-G3 STILL OPEN per STATVERIFY"; (a) spillover unproven + F08-E16 caveat; (b) F08-E16 (NEW-5); (c) WORKER-EXECUTABLE-STATIC (alias only) + OWNER-DECISION — desert_frt_un needs no work, [U]-G3 STILL OPEN; (d) alias-only confirm-or-quarantine + zero-mismatch `donor names byte-identical, no renamed-to-fit`; (e) narrows only | statverify `:29` MISCLASSIFIED as stated, desert_frt_un RESOLVED, [U]-G3 OPEN | **PASS** — desert_frt_un-vs-sibling split exact; `[U]-G3` tail kept open |

### AP rows (9) — ids sequential, no renumber

| Item | Packet site | STATVERIFY site | Verdict |
|---|---|---|---|
| AP-1 | packet `:187-192` DONOR-LITERALS feed; (c) WORKER-EXECUTABLE-STATIC + OWNER-GPU-RUNTIME; (d) land-or-repoint + zero-mismatch `no fallback path silently taken`; (e) closes row only via load proof + gate | statverify `:19` joint MW-8/AP-1 STILL OPEN, "No change" | **PASS** |
| AP-2 | packet `:194-199` 235-basename manifest; (c) WORKER-EXECUTABLE-STATIC; (d) manifest rows + zero-mismatch `no row without PRESENT/ABSENT + path or ruling`; (e) narrows only | statverify `:27` part + `:30` full-235 STILL OPEN, "No change" | **PASS** |
| AP-3 | packet `:201-206` heading "EXISTENCE RESOLVED (48/48); byte verification [U]-G2 STILL OPEN per STATVERIFY"; (c) WORKER-EXECUTABLE-STATIC — EXISTENCE RESOLVED 48/48, [U]-G2 STILL OPEN; (d) existence closed, manifest-rows-only + zero-mismatch `no stem claimed resolved without bytes`; (e) narrows only | statverify `:26` joint AN-2/AP-3 RESOLVED/OPEN | **PASS** — mirrors AN-2 exactly; same `[U]-G2` tail, no divergence |
| AP-4 | packet `:208-213` 66×40 matrix + orphan plan; (c) WORKER-EXECUTABLE-STATIC + OWNER-GPU-RUNTIME; (d) matrix + criteria + zero-mismatch `no partial/no row upgraded without frames + capture`; (e) narrows only | statverify `:28` joint AN-4/AP-4 part STILL OPEN, "No change" | **PASS** |
| AP-5 | packet `:215-220` `[U]`-T-A/T-B/G/R captures; (c) OWNER-GPU-RUNTIME; (d) close-up captures + zero-mismatch `no APPROXIMATION label counted as proof`; (e) closes row only via captures + verdict | statverify `:9` + `:45` out-of-scope | **PASS** |
| AP-6 | packet `:222-227` validator + pack_id; (c) WORKER-EXECUTABLE-STATIC + OWNER-GPU-RUNTIME; (d) write/run validator + recompute pack_id + zero-mismatch `no missing A2.4 key unrecorded, no stale pack_id`; (e) narrows only | statverify `:31` STILL OPEN, "No change" | **PASS** |
| AP-7 | packet `:229-234` season/desert reconciliation; (c) WORKER-EXECUTABLE-STATIC + OWNER-DECISION; (d) reconcile + rule + zero-mismatch `no two shapes both canonical`; (e) narrows only | statverify `:32` STILL OPEN, "No change" | **PASS** |
| AP-8 | packet `:236-241` material wiring + swaps; (c) WORKER-EXECUTABLE-STATIC + OWNER-GPU-RUNTIME; (d) wire + prove swaps + zero-mismatch `no data-only JSON counted as wired`; (e) narrows only | statverify `:27` part (AN-3/AP-2/AP-8) STILL OPEN, [U]-GRASS OPEN | **PASS** |
| AP-9 | packet `:243-248` donor GPU A/B decision; (c) OWNER-GPU-RUNTIME + OWNER-DECISION; (d) produce-or-rule-out + zero-mismatch `same camera/seed/map-size or explicit rule-out, no substitute`; (e) narrows only alone, precondition with MW-2/MW-11 | statverify `:9` + `:45` out-of-scope | **PASS** — mirrors MW-1 without weakening either zero-mismatch |

AP id check: AP-1 (`:187`), AP-2 (`:194`), AP-3 (`:201`), AP-4 (`:208`), AP-5 (`:215`), AP-6 (`:222`), AP-7 (`:229`), AP-8 (`:236`), AP-9 (`:243`) — sequential 1…9, no renumber, no insertion, no deletion. **PASS.**

## 2. Cross-cutting checks

- Every `(a)` gap line intact: all 31 items carry an explicit (a) Gap with port paths / no-file-found where STATVERIFY asserts absence (MW-3 N7/spec-copy, NG-6 six absences, AN-2 11-family listing, AP-6 N7). **PASS.**
- Every `(b)` governs line intact: HANDOFF/V-spec/X/DEC_U/spec-section cites preserved verbatim (spot: MW-1 GR-C08/V15-§2/V57/X39/X07-X36; MW-2 V21/V06/V42/V63-V76-V83-V86; AN-1 F02-X05; AN-5 F08-E16). **PASS.**
- Every `(c)` classification matches STATVERIFY exactly, including the five GAP-CORRECT reclassifications: AN-1 MISCLASSIFIED-RESOLVED + [U]-G1; AN-2/AP-3 EXISTENCE RESOLVED + [U]-G2; AN-5 MISCLASSIFIED-RESOLVED (desert_frt_un) + [U]-G3; NG-4 STATIC WRITE-PATH RESOLVED + runtime STILL OPEN. Owner-only items (MW-1/MW-2/MW-4/MW-7/MW-11/NG-2/NG-5/AP-5/AP-9) listed only in STATVERIFY §3 — packet keeps their owner classifications, no static promotion. **PASS.**
- Every `(d)` action/condition line intact with exact zero-mismatch clause (31/31 present; quoted in §1). No weakening found (e.g. NG-4 still demands "all four tags demonstrated"; AN-1 still demands "no section silently absent"; AP-3 still demands "no stem claimed resolved without bytes"). **PASS.**
- Every `(e)` P0-effect line intact: "narrows only" everywhere except MW-2/MW-11 (can close via gates/verdicts), MW-4/MW-8/AP-1/AP-5 (close only via runtime proof + gate/verdict), MW-10 (process rows only, never class-A). No P0 closure asserted. **PASS.**
- No `[U]` residual dropped: [U]-G1 (AN-1), [U]-G2 (AN-2/AP-3), [U]-G3 (AN-5), [U]-GRASS (AN-3/AP-2/AP-8), [U]-ACT-COVERAGE (AN-4/AP-4), FLOAT_WINDOWS (MW-5/NG-3), cliff-TAG/consumption runtime (NG-4), plus MW-3/MW-6/MW-8/MW-9/MW-10/NG-1/NG-6/AP-6/AP-7 runtime-or-ruling halves — every tail from STATVERIFY §2 (`:36-41`) has a live counterpart in the packet. **PASS.**
- CLAIM-RECHECK14 §7 (`:74-86`) independently confirms the GAP-CORRECT diff is label-only with zero new claim; binding rules `:12-18`, parity `:8`, chain/P0 `:9`, close-out `:250-257` byte-identical to pre-image. No contrary finding here. **PASS.**
- §5 verdict check: packet `:250-255` reads parity UNVERIFIED every subdomain / chain 0/6 / nine P0 OPEN / blocking_unverified non-empty ⇒ RESULT IS NOT GOOD / TERRAIN-ASSETS existence-only / no closure / no approximations / read-only one-file. Matches STATVERIFY §4 (`:47-51`) binding wording exactly in substance. Verdict unchanged. **PASS.**

## 3. Defects

None. No file:line defect found in the corrected packet against STATVERIFY. No label-only remediation required by this worker.

## 4. Verdict (binding wording)

- Parity **UNVERIFIED**. No parity claim. No approximations.
- Chain **0/6**. Nine P0 **OPEN**. `blocking_unverified` non-empty ⇒ **RESULT IS NOT GOOD**.
- Static file presence, byte sizes, greps, and labels are existence only — never correctness, never a gate PASS, never donor fidelity. No static fact above promotes any class-A value/behaviour item.
- No completeness is declared; no parity is claimed; no approximation is made or endorsed in this report.
- Read-only; exactly one file written (this report).

*End of packet re-read.*
