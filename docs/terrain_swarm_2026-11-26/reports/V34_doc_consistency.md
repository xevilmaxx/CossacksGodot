---
id: V34
ticket: "TERRAIN-SWARM-2026-11-26 / V34 — final documentation consistency audit (READ-ONLY)"
agent: "V34 (documentation-consistency subagent, 30-agent DONOR-FIRST terrain swarm)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_DOC_EDIT__NO_SOURCE_EDIT__NO_GODOT_JOB
owner_file: docs/terrain_swarm_2026-11-26/reports/V34_doc_consistency.md
files_created: [docs/terrain_swarm_2026-11-26/reports/V34_doc_consistency.md]
files_edited: []
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_guard: "NO DONOR VISUAL PARITY CLAIM. No donor GPU A/B frame exists; no donor binary was executed and no gate was run by this worker. [O] below means a literal file:line/directory read, [D] a deterministic consequence of those reads, [I] interpretation, [U] UNVERIFIED. Every port consequence is PORT APPROXIMATION."
scope_guard: "Read CHARTER.md, SWARM_BOARD.md, README.md, IMPLEMENTATION_PLAN.md, HANDOFF.md, spec/README.md, spec/00-14 and terrain_qa_spec.json; cross-read V11/V16/V17/V20/V21/V26/V27/V37, V03/V04/V05, X18/X20/X21 and the cited spec lines. No doc, source, shader, config, asset, test, JSON, git, queue, runner, Godot, donor or app/ state changed."
multiple_passes: true
snapshot_note: "Live, concurrent swarm. Report count moved 67 → 71 during this audit (V26, V27, V28, V37, X27, X28, X30 landed mid-read); spec/00, spec/09, V27 and HANDOFF.md were being edited while read. Every count and file-state claim is point-in-time at the final directory read (second verification pass). COORD must re-run the two verification commands in §1 before applying any paste-ready fix."
---

# V34 — Final documentation consistency audit

## Executive summary

1. **[O] The board is the largest single stale artifact.** At final read `reports/` holds **71** files while `SWARM_BOARD.md:7-51` lists **43** worker rows; **28** landed reports have no row at all, and **23** rows still say `RUNNING` for reports that exist on disk (D01–D09, F01, F04, F07–F10, P02, X01–X03, X05–X06, V01, V03–V08). The board's own rule (`SWARM_BOARD.md:3-4`, "COORD updates this file when a report lands") is therefore contradicted by the board itself.
2. **[O] The spec is a layered time-capsule.** `spec/README.md:16-28` still marks all 13 planned sections `PENDING` while 15 section files exist; `spec/03/04/06/07/08/10/12/13/14` still use "pending / has not landed / when landed / is assigning / is preparing" wording for reports that landed (D03, F01, F04, V01, V04, V05, V06, V11, V12, X09, F07/F08/F10). **V26 supplies paste-ready replacements for four material conflicts; none has been folded into the spec text yet.**
3. **[O] Ownership/path docs no longer describe the live tree.** `IMPLEMENTATION_PLAN.md:18-19` names `variant3d/scripts/terrain_donor_shader.gdshader` and "I11 = `world3d.gd` seam only"; V11 CR2/CR3/CR5 and V26 §5 instead require a two-file seam, a composer `terrain_donor_world.gd`, and `variant3d/shaders/terrain_donor_shader.gdshader`. The working tree actually contains `variant3d/shaders/terrain_donor.gdshader` (A06 N7's retired alias), so **three different paths** are in play. The seam is now applied in the working tree (`main.gd`/`world3d.gd` modified, `.bak-COORD-I11` present), making every "seam unapplied / tree clean" permanent spec sentence untrue at this read (V26 §5, HANDOFF §2.1).
4. **[O] HANDOFF.md is an honest DRAFT whose placeholders are now partly stale.** `HANDOFF.md:96-110` deliberately carries `TODO(COORD)` gate cells (correct by design), but `:39, :66, :151` say `spec/00_EVIDENCE_INDEX.md` is absent (it exists), `:66/:131` say the composer and props are absent (both now exist), `:108` says N17 is absent (it exists at `spec/terrain_qa_spec.json`, not `tools/`), and `:38` repeats the refuted "20 global keys" count (X20 proved 19; `spec/09:11` is already corrected).
5. **[O]/[D] Four-plus contradiction registers compete.** `SWARM_BOARD.md:62-74` (C1–C9), `V16_contradiction_register.md:52-85,106-123` (27 clusters, O1–O14), `V26_spec_conflicts_resolved.md:40-214` (four paste-ready resolutions), `V03` §4 (16 items with "C-B/C-C supersede V16 O5"), `V21` gate register and `spec/README.md:30-36` (empty placeholder row). They disagree on the OPEN count (board "4"; V16 §4 O1–O14 = 14; V16 §2 six OPEN verdict rows; V27 §8 risk 3 "4 OPEN undercounts") and on C9 (board OPEN vs V26 §4 resolved as intent-vs-pixels with `[U]` residue). No worker may reconcile them by editing another worker's file; COORD must designate one canonical register and point all others to it.
6. **[U] No parity claim is made in this report.** All verdicts are file:line/directory-state adjudications; `PORT APPROXIMATION` / `UNVERIFIED` throughout, per `CHARTER.md:43-44,122-135`.

---

## 1. Evidence table — instruments and second-pass verification

| # | Instrument / source re-read | Passes | What it pins |
|---|---|---|---|
| E1 | `Get-ChildItem ...\reports -File -Filter *.md`, `...\spec -File`, sorted; repeated **twice** (start 67 reports / 15 spec files, final 71 reports / 17 spec files) | 2 | Report-count drift; `spec/00_EVIDENCE_INDEX.md` and `terrain_qa_spec.json` present; no `V26` at first read, present at final read |
| E2 | `git rev-parse --short HEAD`; `git status --short -- docs/...`, `-- variant3d/`, `-- app/` | 2 | `HEAD=e234ac9b`; CHARTER/SWARM_BOARD/spec/11 modified; `main.gd`/`world3d.gd` modified; donor modules/tools/tests untracked; `app/` clean |
| E3 | `Select-String -SimpleMatch` over README/CHARTER/BOARD/PLAN/spec README/§00/§01–§14/HANDOFF/V21/V27 with literal stale phrases; each hit re-read with `read` | 2 per file | Every "stale" row in §2 was confirmed by a second command after the first `read`/glob |
| E4 | Full `read` of `V11_ownership_ledger.md`, `V16_contradiction_register.md`, `V17_spec_readiness.md`, `V20`, `V21`, `V26`, `V27`, `HANDOFF.md`, `spec/00` | 1 full + targeted re-read | Canonical ownership, contradiction counts, paste-ready V26 resolutions, HANDOFF placeholders, snapshot drift |
| E5 | Directory glob of all `reports/V*.md` and `reports/X*.md` at final read | 2 | Missing board rows: V09, V11, V12, V13, V15, V16, V17, V20, V21, V26, V27, V28, V37; X07, X08, X09, X11, X12, X13, X15, X17, X18, X19, X20, X21, X22, X27, X28, X30 |
| E6 | Targeted re-read of `spec/09:11`, `V27:41,55-62,222-224,255,277`, `HANDOFF.md:20,38-39,66,108,131,151` | 2 | Some docs were corrected mid-audit (spec/09 → 19 keys; V27 E14 → "V03 landed"); contradictions remain inside those same files |

**Reverification commands for COORD (read-only; run before applying any fix):**

```powershell
Get-ChildItem -LiteralPath 'docs\terrain_swarm_2026-11-26\reports' -File -Filter *.md | Measure-Object   # count + names
Get-ChildItem -LiteralPath 'docs\terrain_swarm_2026-11-26\spec' -File | Select-Object -ExpandProperty Name
git status --short --untracked-files=all -- docs\terrain_swarm_2026-11-26 variant3d app
Select-String -LiteralPath 'docs\terrain_swarm_2026-11-26\HANDOFF.md' -Pattern 'was absent|absent|TODO\(COORD\)|4 OPEN' -SimpleMatch:$false
```

---

## 2. Stale-statement table — exact location, stale text, paste-ready replacement, priority

Legend: **BLOCKER** = blocks safe integration/dispatch/owner sign-off; **MINOR** = tracking, wording or provenance drift that does not change an implementation decision. All replacement text is paste-ready and keeps labels/no-parity wording.

### 2.A SWARM_BOARD statuses vs files on disk (MINOR tracking, but BLOCKER for the "all landed" gate)

| Exact file:line | What is stale | Paste-ready replacement | Priority |
|---|---|---|---|
| `SWARM_BOARD.md:9-17` rows D01–D09, status cell `RUNNING` | All 9 files exist (`D01_rtti_function_anchors.md` … `D09_editor_binary.md`) | Replace each status cell with `**LANDED**` (add `→ spec §01/§02/§03/§04/§05/§07/§09` only where that section actually cites the report) | MINOR |
| `SWARM_BOARD.md:18,21,24-27` F01, F04, F07–F10 `RUNNING` | All 6 files exist (F10 landed 09:42) | `**LANDED**` (F01 → spec §04, F04 → §03, F07 → §08, F08 → §07/§08, F09 → §09, F10 → §06 out-of-scope note) | MINOR |
| `SWARM_BOARD.md:29` P02 `RUNNING`; `:40-48` X01–X03/X05/X06 `RUNNING`; `:45-51` V01,V03–V08 `RUNNING` | All 15 files exist (P02, X01, X02, X03, X05, X06, V01, V03, V04, V05, V06, V07, V08 = 13; plus D/F above) | `**LANDED**` for each; V04/V05/V06 → also cite `spec/12 §12.1/§12.4/§12.7` | MINOR |
| `SWARM_BOARD.md:7-51` table (28 absent rows) | No rows for V09, V11, V12, V13, V15, V16, V17, V20, V21, V26, V27, V28, V37 and X07, X08, X09, X11, X12, X13, X15, X17, X18, X19, X20, X21, X22, X27, X28, X30 | Append (exact names from final glob): `\| V09 \| Verify \| 2D order transplant \| reports/V09_2d_order_transplant.md \| **LANDED** \|` … `\| V11 \| Verify \| definitive ownership ledger \| reports/V11_ownership_ledger.md \| **LANDED → spec/12 §12.2** \|` … `\| V16 \| Verify \| definitive contradiction register \| reports/V16_contradiction_register.md \| **LANDED — canonical register** \|` … `\| V26 \| Verify \| resolve V17's four spec conflicts \| reports/V26_spec_conflicts_resolved.md \| **LANDED — paste-ready spec fixes pending** \|` … `\| V27 \| Verify \| UNVERIFIED owner/disposition register \| reports/V27_unverified_owners.md \| **LANDED** \|` … (analogous rows for V12/V13/V15/V17/V20/V21/V28/V37 and X07–X30) | MINOR |
| `SWARM_BOARD.md:3-4` "COORD updates this file when a report lands" | Process claim contradicted by 28 missing rows and 23 stale `RUNNING` cells | `COORD updates this file when a report lands; at the V34 read the board lags the directory by 28 rows — treat the directory glob as authoritative until COORD refreshes this table.` | MINOR |
| `SWARM_BOARD.md:5` "At least 30 workers are kept active" | Unverifiable; many slots finished/recycled, reports landed from V/X waves not listed | `[U] Active-worker count is not tracked in this file; see the landed-report glob for realised output.` | MINOR |
| `SWARM_BOARD.md:55-60` "Pending spec sections: §02 … (D02), §03 … (D03/F04), §05 (D06), §07 (D07/F08), §10 (V01/X03)" | All cited reports landed; all five section files exist; §00 also exists; §13/§14 exist but §00 missing from the log | `- §00 evidence index ← X14 · §01 ← A01 · §02 ← D02/V01/X21 · §03 ← D03/F04/X18/X19 · §04 ← F01/F02/D05/X12/X13 · §05 ← D06/X11 · §06 ← F05/F06/D08/X06/X17 · §07 ← D07/V12/X09 · §08 ← A04/F07/F08/X22 · §09 ← F03/F09/D09 · §10 ← A02/X03/V01 · §11 ← A03/P04/X15 · §12 ← A05/A06/P03/V04/V05/V06/V11/V13/V21 · §13 ← P06/V03 · §14 ← P01.` / `- Remaining: COORD integration of V26 paste-ready fixes and V27 owner vocabulary; no section carries a READY marker yet.` | BLOCKER (§00/READY gate) |
| `SWARM_BOARD.md:78` gate "All reports landed and contradictions resolved" | Unchecked, but 71 reports landed and 4+ registers still disagree; cannot be ticked until canonical register chosen | Keep unchecked; append `V34: 71 reports at final read; contradiction counts disagree across BOARD/V16/V21/V26/V27 — resolve via §2.G before ticking.` | MINOR |

### 2.B Spec sections citing reports that have since landed with corrections

| Exact file:line | What is stale | Paste-ready replacement | Priority |
|---|---|---|---|
| `spec/README.md:14-28` State column: all 13 rows `PENDING` | All 13 planned files plus §00/§13/§14 exist; `terrain_qa_spec.json` exists | Replace `PENDING` with `FILE PRESENT — not marked READY (V17/V34)` in rows 16-28; add rows `\| 00_EVIDENCE_INDEX.md \| evidence index \| X14 \| FILE PRESENT \|`, `\| 13_PRIOR_WAVE_MEMORY.md \| prior-wave memory \| P06/V03 \| FILE PRESENT \|`, `\| 14_CURRENT_PIPELINE.md \| current legacy pipeline \| P01/V05 \| FILE PRESENT \|`, `\| terrain_qa_spec.json \| QA bands (schema only) \| I13/COORD (N17) \| FILE PRESENT — unpopulated \|` | MINOR |
| `spec/README.md:30-36` contradiction register placeholder row `\| — \| — \| — \| — \| — \|` | `spec/00 §4.1` already points to V16 as definitive; V26/V27 add corrections | `The definitive register is reports/V16_contradiction_register.md §2/§4 (27 clusters; 14 RESOLVED, 9 PRESERVED, OPEN rows O1–O14). V26_spec_conflicts_resolved.md §2–§5 supplies paste-ready spec fixes; V27_unverified_owners.md assigns owners; V21_gate_register.md maps gates. No worker edits this table — COORD integrates.` | BLOCKER |
| `spec/00_EVIDENCE_INDEX.md:9,18` "56 landed reports at final directory read" | 71 at V34 final read; coverage manifest `:344-405` omits V03, V26, V27, V28, V37, F10, X13, X15, X18, X20, X21, X22, X27, X28, X30 | `evidence_snapshot: "71 landed reports at the V34 verification read; spec 00–14 + README + terrain_qa_spec.json present. Count is point-in-time; re-glob before relying on it."` and in §0 item 1 replace `**56 landed reports**` with `**71 landed reports (V34 final glob)**` | MINOR |
| `spec/00_EVIDENCE_INDEX.md:291` P15 "X18 and V03 remain absent — retire or assign" | X18 landed 09:44:40; V03 landed 09:42:10; both on disk | `At this index read X12, X09, X19, F01, X17, V20, V13, V16, V01 had landed; V03 and X18 landed subsequently (V34 glob) and are present in reports/. V17's orphan list is fully obsolete.` | MINOR |
| `spec/00_EVIDENCE_INDEX.md:327` U20 "Unowned X18/V03 tickets" | Both landed; V27 assigns owners to the 28 P06 items | `U20 — retired: V03 and X18 landed; V03 §5.2 and V27 §4.4 own the residual items.` | MINOR |
| `spec/00_EVIDENCE_INDEX.md:243,385` "V11 … NEW N1–N22" | V11 §3 lists **N1–N19**; N20–N22 do not exist | `V11 E1–E15, EDIT E1–E4, NEW N1–N19` (both places) | MINOR |
| `spec/00_EVIDENCE_INDEX.md:52` "20 global keys" | X20 E2/E3 proved 19; `spec/09:11` already corrected | `cfg constants: 19 global keys (X20 correction; F03's "20" is an off-by-one), 13 local keys, 64 families/493 pairs` | BLOCKER (I01 count assertion) |
| `spec/01_WORLD_DATA_MODEL.md:5` "A01 was written before D/F reports landed — `[U]` queued for cross-check (D04 especially)" | D04 landed; `§5` already says `D04 (LANDED)` | `A01 was written before the D/F reports landed; D04/D03/D05 landed and are folded into §5 — re-check every residual [U] against V27 before implementation.` | MINOR |
| `spec/01_WORLD_DATA_MODEL.md:50` "Donor-confirmed sources: mask R=terrain class, G=forest, B=water weight, A=road" | V26 §4.3 gives exact replacement; shipped R/G start-only | Paste V26 §4.3 block beginning `Donor-confirmed **schema intent** (` (V26:164-166), verbatim | BLOCKER (I04/I06) |
| `spec/02_SEED_AND_RNG.md:13` "Key derivation function `GenerateMapRandKey` remains `[U]`" | §5 of the same file says no donor derivation function exists; V01 refuted `mix64` | `- No donor key-derivation function exists (V01 P1/P2; §5); \`GenerateMapRandKey\` has declaration strings but no body or code xref (D02 Anomaly D) — engine internals only stay [U].` | MINOR |
| `spec/02_SEED_AND_RNG.md:79` "X21 is producing numeric vectors" | X21 landed (09:44:01) with 20 vectors and the `key0`-discarded correction | `X21 supplied 20 exact RNG vectors; \`key0\` is discarded by the mod-2^32 reduction and outputs require float32 rounding (X21 §1 items 2–3).` | MINOR |
| `spec/03_MASK_TO_HEIGHT.md:1,5` "D03/X19 pending" / "D03 … has not landed" | Both landed; X18 independently confirmed F04 | `# 03 — Mask → height (from D03 + F04 + X18/X19 + A02/X03; all landed)` / `D03, F04, X18 and X19 have all landed; see §5.` | MINOR |
| `spec/03_MASK_TO_HEIGHT.md:21-26` "V16/X19 must reconcile; until then …" | V26 §4.2 resolved it as intent vs shipped pixels with an explicit `[U]` residue | Paste V26 §4.3 block `:154-158` beginning `**Authoritative skirmish statement [O]:**`, verbatim | BLOCKER (I04) |
| `spec/03_MASK_TO_HEIGHT.md:28` heading "Height formula class map (A02/X03) [O] — provisional" | V26 §4.3 `:160-162` re-labels it donor-intent, inert on shipped masks | `## 2. Height formula class map (A02/X03) [O] — donor-intent, INERT on shipped masks` + prepend V26 `:162` paragraph | BLOCKER (I07) |
| `spec/03_MASK_TO_HEIGHT.md:47` "Confirm with D03/F08/X19" / `:51-52` cross-check queue "X18, X19, V16" | All landed | `Confirmed by D03/F08/X19: density comes from placement, not mask G.` / `Cross-check queue: D03 ✓, X18 ✓, X19 ✓, V16 ✓, V26 ✓ — no report in this queue is pending.` | MINOR |
| `spec/04_PATTERN_STAMPING.md:1` "F01/D05 pending" | Both landed | `# 04 — Pattern stamping (from F02 + A02 + F01 + D05 + X12/X13; all landed)` | MINOR |
| `spec/04_PATTERN_STAMPING.md:46-49` "Engine math `[U]`" | V26 §2.3 supplies exact replacement; spec §6 already has D05 `[O]` | Paste V26 `:62` "Blend flags:" block verbatim | BLOCKER (I02/I07) |
| `spec/04_PATTERN_STAMPING.md:60-61` "`m_swamp_12_old` … until F01/D05 resolve it" | F01/D05 landed; V16-04/O1 policy = quarantine, binary 18×23 authority, never abort | `Keep the one anomalous record labelled PRESERVED donor contradiction; quarantine with a warning, use the binary 18×23 as geometry authority, and never abort the 680-record parse (F02, X05, V16-04/O1, V26).` | MINOR |
| `spec/04_PATTERN_STAMPING.md:69-95` §6/§7 old call chain, "X12 is independently verifying", "F01 … V01 (16 UNVERIFIED)" | X12 landed and **rejected** D05's intermediate hops; X13 vectors landed; V01 resolved 10/3/3 | Replace §6 and §7 with V26 `:66-84` blocks verbatim | BLOCKER (I02/I07/I12) |
| `spec/06_TILE_AND_ATLAS.md:1` "D08/F03/F06 pending"; `:38` "must resolve the live selection rules"; `:48` "desert winter reuse awaits F10 confirmation"; `:52-53` queue | D08/F03/F06/F10 landed; live selection still `[U]` but no longer pending reports | `# 06 — Tile ids and atlas (from F05 + F06 + D08 + X06/X08/X17; F10 landed)` / `D08/F03/F06 are landed; live selection activation remains [U] for runtime reasons, not for a missing report.` / `Desert winter reuse is reported by F10 as DLC/mod, not vanilla skirmish — label PORT APPROX / out-of-scope, do not wait on F10.` | MINOR |
| `spec/05_WATER_SHORE.md:79` "factors/pass count `[U]`" | X17 pinned factors; only pass count stays `[U]` CONFIRMED_UNVERIFIED (V27 CORE-07/08) | `Blend is \`glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)\` [O] (VA 0x4ef991/0x88fbb0/0x88fbb7; X17 E1–E16). Only the composite **pass count** remains [U] CONFIRMED_UNVERIFIED after six passes.` | MINOR |
| `spec/07_RESOURCES.md:1` "V12/X09 pending"; `:24` "V12 will recommend"; `:47` shore citation `:1557-1564`; `:55` "X09 investigates"; `:66-67` queue | V12/X09 landed; V12 corrected citation to `:1568-1581`; V01 `mapsize>2 = 256 tiny`; V26 §3 supplies authoritative block | Replace `:18-24` and `:66-67` with V26 §3.3 blocks `:117-131` verbatim; replace `:47` citation with `dogenerate.inc:1568-1581 (V12 C-V2)` | BLOCKER (I07/I13 G9) |
| `spec/08_FIELDS_AND_PROPS.md:1` "F07/V07 pending"; `:34` "until F07/F08/D07 land"; `:65` "X16 is auditing mesh coverage"; `:85-86` queue "X16" | F07/F08/V07/D07/X22 landed; **X16 does not exist on disk** (orphan citation) | `# 08 — Fields and landscape props (from A04 + F07/F08 + V07 + X22; all landed)` / `Fields are unit-script sown (X22), not pattern stamps; port field placement stays PORT APPROXIMATION, not pending-on-report.` / Replace `X16 (mesh coverage)` with `V07 (asset-readiness ledger) ✓ — no X16 report exists; retire the citation.` | MINOR (orphan) |
| `spec/09_EDITOR_PARAMETERS.md:11` (already partly corrected mid-audit) | Now reads `19 flat keys … (V37 adjudicating)`; §00:52, HANDOFF:38 and F03 summary still say 20 | Keep this line; propagate the correction to §00:52 and HANDOFF:38 (see §2.F) | BLOCKER for I01 |
| `spec/10_STAGE_ORDER.md:6` "D/F reports … had not landed"; `:40` "key derivation `[U]`"; `:43` "engine math `[U]`"; `:50/:53` food rects; `:81` "Key-mixing function remains `[U]`"; `:103-104` "16 `[U]` … V01 must reconcile" | All D/F landed; V01 landed; V26 §2/§3 supplies replacements | Paste V26 `:88` "Blend flags" row, `:92` §4 phrase, `:123/:127` "Starting resources"/"Fields" rows, and `:170` "Height classes" suffix, verbatim; change `:81` to `Key mixing is refuted: all 11+3 re-seeds pass randkey1/0 verbatim (V01); engine key→state internals stay [U].` | BLOCKER (I07) |
| `spec/11_ASSET_CONVERSION.md:34-37` "Owned by D05/F01 … F02 … F03 … F10" | All five landed; F01 closed the byte accounting | `Relief float grid + object tail are decoded [O] by F01/D05/X12; full pattern.lib boundaries by F02/X05; cfg bytes by F03/X20; desert season by F10 (out-of-scope for vanilla skirmish). Residual field semantics stay null+UNVERIFIED.` | MINOR |
| `spec/11_ASSET_CONVERSION.md:98-99` "Contradictions … will be resolved in the contradiction register in `spec/README.md`" | `spec/README.md` register is still the empty placeholder; V16/V26 hold the resolutions | `Contradictions are adjudicated in reports/V16_contradiction_register.md §2/§4; V26_spec_conflicts_resolved.md §2–§5 carries paste-ready spec fixes; COORD integrates — spec/README.md is not authoritative.` | MINOR |
| `spec/12_QA_AND_INTEGRATION.md:1,4-5` "A05 to be appended … will be merged once worker finishes" | A05 landed and is already merged as §12.6 | `# 12 — QA and integration (from A05 + A06; integrated)` / `A05's harness is merged into §12.6; V21 gate register is the executable companion.` | MINOR |
| `spec/12_QA_AND_INTEGRATION.md:22-24` "(V04 report pending)" | V04 landed; and V26 §5.3 says the "clean/seam unapplied" snapshot is itself stale | Paste V26 `:195` block verbatim (point-in-time note incl. applied seam + missing composer at V26 read) | BLOCKER (I11) |
| `spec/12_QA_AND_INTEGRATION.md:83-84` "V11 is assigning one owner per file" | V11 landed with the full ledger; seam since applied | Paste V26 `:199` block verbatim | BLOCKER (I11) |
| `spec/12_QA_AND_INTEGRATION.md:136-137` "V06 is preparing the exact remediation" | V06 landed with remediation; V21/V27 own execution | `V06 §4.1 supplies the exact \`ack --reason\` strings for 575/582/585; COORD/I12 executes before any fresh gate result is claimed (V21 GR-A00).` | MINOR |
| `spec/13_PRIOR_WAVE_MEMORY.md:35-38` "V01 worker is cross-checking … (see V03…)" / "3 uncommitted changes … V04 worker is auditing" | V01/V03/V04 landed; "3 uncommitted" premise refuted; new uncommitted seam edits exist | Paste V26 `:203-204` block verbatim | BLOCKER (I11) |
| `spec/14_CURRENT_PIPELINE.md:35-36` "V05 is reconciling … see report when landed" | V05 landed and §12.1 is authoritative; seam since applied | Paste V26 `:208-210` block verbatim | BLOCKER (I11) |
| `spec/12 §12.2:41` "19 NEW files + 11 generated asset entries" | Matches V11 N1–N19/G1–G11; **§00:243/385 wrongly say N1–N22** | Keep §12.2; fix §00 (above) | MINOR |

### 2.C IMPLEMENTATION_PLAN paths vs V11 canonical ownership

| Exact file:line | What is stale | Paste-ready replacement | Priority |
|---|---|---|---|
| `IMPLEMENTATION_PLAN.md:19` I11 "`variant3d/scripts/world3d.gd` (seam only)" | V11 CR2 widens to `main.gd` + `world3d.gd`; V26 §5 shows both now edited | `\| I11 \| \`variant3d/scripts/main.gd\` + \`variant3d/scripts/world3d.gd\` (seam ONLY, one COORD owner I11-SEAM, suffix COORD-I11; already present in working tree at V26/V34 read — DO NOT re-apply) \| §12 \| \`terrain_backend\` switch: legacy default, donor opt-in; additive; verify hashes before touching \|` | BLOCKER |
| `IMPLEMENTATION_PLAN.md:19` (no composer ticket) | V11 CR3/N14: seam const points at `terrain_donor_world.gd`; PLAN has no owner | Add row `\| I11-COMPOSER \| \`variant3d/scripts/terrain_donor_world.gd\` (NEW, same COORD owner) \| §12 \| Create BEFORE the seam is flipped; composes I06/I07/I08/I09; one mesh/water/environment; parse-before-switch \|` (file now exists on disk — record as landed-unverified, do not re-create) | BLOCKER |
| `IMPLEMENTATION_PLAN.md:18` I10 "`variant3d/scripts/terrain_donor_shader.gdshader`" | Three-way conflict: V11 N13 = `variant3d/shaders/terrain_donor_shader.gdshader`; A06 N7 / actual disk = `variant3d/shaders/terrain_donor.gdshader` | COORD decision needed. Paste-ready doc form once decided (reflects disk): `\| I10 \| \`variant3d/shaders/terrain_donor.gdshader\` (only if needed; alias used by the working tree, V11 N13's \`terrain_donor_shader.gdshader\` is retired) \| §06, §05 \| Donor tile/alpha/water semantics; no invented constants; reconcile V11 CR5 before dispatch \|` | BLOCKER |
| `IMPLEMENTATION_PLAN.md:9` I01 output "`terrain_new/cfg/constants.json`" | V11 G1 canonical root `variant3d/assets/terrain_new/cfg/constants.json` | `Emit \`variant3d/assets/terrain_new/cfg/constants.json\` + \`config_strings.json\` (19 global keys per X20, not 20), each value with donor path:line; dry-run default` | MINOR |
| `IMPLEMENTATION_PLAN.md:15` I07 (no tiles module) | V11 N10 assigns `terrain_donor_tiles.gd` to I07; V16-27 owner decision still open | Add to I07 work cell: `+ \`variant3d/scripts/terrain_donor_tiles.gd\` (N10, V09 recipe); V16-27 two-file ownership must be signed by COORD before dispatch` | MINOR |
| `IMPLEMENTATION_PLAN.md:21` I13 "QA/capture by COORD" | V11 N16–N19 pin exact paths; N17 `spec/terrain_qa_spec.json` already exists (schema_only) | `QA/capture by COORD: N16 \`variant3d/tools/terrain_qa_harness.py\`, N17 \`docs/.../spec/terrain_qa_spec.json\` (present, unpopulated), N18 \`inbox/qa/terrain_qa_report.json\`, N19 \`inbox/qa/captures/\`; no PASS until fresh JSONs` | MINOR |
| `IMPLEMENTATION_PLAN.md:5` generic `.bak-<TICKET>` | V11 CR11 reserves `COORD-I11`, `I12`, `COORD-STAGE4`; generic suffix could collide | `... back up to \`inbox/backup/<file>.bak-<TICKET>\`; reserved suffixes are \`COORD-I11\` (main.gd+world3d.gd), \`I12\` (tests/manifest.json), \`COORD-STAGE4\` (config.gd, conditional) — never overwrite an older .bak (V11 CR11)` | MINOR |
| `IMPLEMENTATION_PLAN.md:3` "Do not start until cited spec sections are marked READY" | No section carries a READY marker (V17 §2; V27 CORE-39), yet tools/modules are landed and seam applied | `Do not claim a gate PASS until COORD marks cited sections READY (currently none); landed-but-unverified tools/modules are point-in-time work, not READY evidence.` | BLOCKER (process) |
| `IMPLEMENTATION_PLAN.md:34-38` ordering | V11 §7 inserts N14 at head of integration and splits I13 into A′/D — already reflected by implementation | `I01–I05 → A′(N7/QA preflight) → I06–I10+N14 → seam(I11-SEAM)+I12 → I13(A′/D) — V11 §7; re-verify hashes first` | MINOR |

### 2.D CHARTER claims vs V16/V26 resolutions

| Exact file:line | What is stale | Paste-ready replacement | Priority |
|---|---|---|---|
| `CHARTER.md:100-103` wave D roster "D01 RTTI … D08 tile/atlas/shader" | D09 (`editor.exe` forms) exists and is on disk; board lists D09 | `D01 RTTI→function anchor · D02 seed+RNG · D03 terrainmask decode/blur/smooth · D04 .map/TTile format · D05 relief stamp · D06 water/shore · D07 mines/stone/forest · D08 tile/atlas/shader · D09 editor.exe forms/handlers.` | MINOR |
| `CHARTER.md:96-120` §5 "30 concurrent workers" with no X or V wave | Final glob has 71 reports incl. 19 X-wave and 20 V-wave files; board has V/X rows but no charter roster entry | Append `### Wave X — corpus/verification (X01–X30) and Wave V — verification/resolution (V01–V37): see SWARM_BOARD and the directory glob; rosters are point-in-time.` | MINOR |
| `CHARTER.md:130` "Same seed ⇒ byte-identical output; **240² and 320² maps both work**" | V16-20/O3 is **OPEN** (canonical capture size unresolved; config.json 240² vs small_map_64 320²); V21 keeps it advisory | `Same seed ⇒ byte-identical output; both 240² and 320² are supported, but the canonical A/B overlay remains OPEN (V16-20/O3) — COORD/I13 must pin and label explicit overlays before any capture verdict.` | MINOR (BLOCKER for I13 if untreated) |
| `CHARTER.md:131-133` "fresh windowed capture shows readable relief …" | No admissible capture exists; HANDOFF §4 all `TODO(COORD)`; V15 tier 3 declared | `Owner-facing target (not achieved today): a fresh windowed capture at pinned camera should show readable relief, natural shore and organic placement — no rings/diagonal lattice/grid; tier-2 remains UNVERIFIED until an admissible capture exists (HANDOFF §3/§4).` | MINOR |
| `CHARTER.md:6` `status: ACTIVE` + `:48` "donor-faithful spec + toolchain + clean implementation, in this order" | Spec assembled but V26 fixes not folded; toolchain/modules landed but ungated; order is still the governing plan | Keep ACTIVE; add `Pass 0 (V26/V27 fold-in + spec READY) remains open; implementation artifacts exist but are unverified (V34).` | MINOR |

### 2.E README sequence vs actual progress

| Exact file:line | What is stale | Paste-ready replacement | Priority |
|---|---|---|---|
| `README.md:10` "SWARM_BOARD.md — 31 workers" | Board has 43 rows; directory has 71 reports | `2. [SWARM_BOARD.md](SWARM_BOARD.md) — worker rows and status (43 rows at V34 read; directory glob is authoritative — 71 landed reports).` | MINOR |
| `README.md:11` "`reports/**` — one report per worker (landing now)" | 71 landed; V34 itself is one of them | `3. \`reports/**\` — 71 landed reports at V34 final read (glob, not the board, is the inventory).` | MINOR |
| `README.md:9-12` Start-here list omits HANDOFF.md, V26, V27 and spec/00 | Those are now the owner-facing and resolution entry points | Add `5. [HANDOFF.md](HANDOFF.md) — owner-facing DRAFT; §4 gate cells are TODO(COORD).` and `6. \`reports/V26_spec_conflicts_resolved.md\` + \`reports/V27_unverified_owners.md\` — paste-ready spec fixes and [U] owners; \`spec/00_EVIDENCE_INDEX.md\` — evidence lookup.` | MINOR |
| `README.md:17-19` "24 donor-decoding reports (D/F waves)" | Actual D(9)+F(10)+X(19) = 38 donor-decoding/X reports; board 43 rows total | `30+ workers ──▶ 38 donor-decoding reports (D/F/X waves)` | MINOR |
| `README.md:22` "COORD cross-check + contradictions resolved" | V16 has OPEN rows, V26 fixes not folded, 4+ registers disagree | `COORD cross-check + contradictions adjudicated (V16/V26/V27; see §2.G — one canonical register still to be designated)` | MINOR |
| `README.md:58` "_swarm running; update from background reports as they land._" | Placeholder, never updated | `_At V34: 71 reports landed, spec 00–14 present, seam applied in working tree, no gate PASS and no donor parity claim. COORD to finalize HANDOFF §4 from fresh gate JSONs._` | MINOR |

### 2.F HANDOFF placeholders and stale snapshot claims

| Exact file:line | What is stale | Paste-ready replacement | Priority |
|---|---|---|---|
| `HANDOFF.md:3,7` "(DRAFT, to be finalized by COORD after gates)" | Correct by design; keep, but add a freshness guard so stale snapshot text is not copied verbatim | Add after frontmatter `status`: `> Snapshot discipline: every file-state sentence below is point-in-time (~09:47). Re-run the §6 freeze command and the V34 §1 directory glob immediately before finalizing; do not carry "absent" forward without re-checking.` | MINOR |
| `HANDOFF.md:20,66,131,159` "composer … was absent at snapshot", §2.2 lists `terrain_donor_world.gd`/`terrain_donor_props.gd` absent, §6 step 3 "do not select donor until composer exists" | At V34 read both files exist untracked (`git status` shows `?? variant3d/scripts/terrain_donor_world.gd`, `?? ...terrain_donor_props.gd`); composer gap is closed on disk but still ungated | `The N14 composer and I09 props now exist as untracked files (V34 git status); default remains "legacy" and donor mode still requires parse + fresh gate verification before selection — absence is no longer the blocker, verification is.` | BLOCKER (owner launch instruction) |
| `HANDOFF.md:39,66,151` "`spec/00_EVIDENCE_INDEX.md` absent / write it" | §00 exists (17 spec files incl. README + terrain_qa_spec.json) | `spec/00_EVIDENCE_INDEX.md exists (X14); remaining work is folding V26/V37 corrections into it, not creating it.` | MINOR |
| `HANDOFF.md:108` "N17 **absent**" (in GR-B01…B16 row) | `spec/terrain_qa_spec.json` exists with `schema_only:true`, `status:SCHEMA_ONLY__UNPOPULATED`; HANDOFF also pins the wrong path (`tools/terrain_qa_spec.json`) | `--policy advisory; N17 exists at docs/terrain_swarm_2026-11-26/spec/terrain_qa_spec.json but is SCHEMA_ONLY__UNPOPULATED — no band may be promoted until populated with donor path:line and COORD signs` | MINOR |
| `HANDOFF.md:38` "20 global + 13 local keys" | X20 proved 19; `spec/09:11` corrected | `7 gen cfg files, **19** global (X20 correction; F03's "20" is an off-by-one) + 13 local keys, 64 families / 493 Pattern=Freq weights` | BLOCKER (I01) |
| `HANDOFF.md:39` "27 clusters … 4 OPEN (O1–O14 have named owners)" | Internally inconsistent (4 vs 14) and V27 flags the undercount; V16 §2 has six OPEN verdict rows | `27 clusters — 14 RESOLVED, 9 PRESERVED, OPEN rows O1–O14 in V16 §4 (six OPEN verdict rows in §2: O1/O2/O3/O5/O6/O7); V27 assigns owners; V26 supplies paste-ready fixes` | MINOR |
| `HANDOFF.md:58` shader path "`variant3d/shaders/terrain_donor.gdshader`" | Matches disk but contradicts V11 CR5 / PLAN I10 canonical `terrain_donor_shader.gdshader` | `variant3d/shaders/terrain_donor.gdshader (working-tree alias, A06 N7); V11 N13's terrain_donor_shader.gdshader and PLAN I10's scripts/... path are retired — COORD to reconcile ownership docs before dispatch` | BLOCKER |
| `HANDOFF.md:96-110` 11 `TODO(COORD)` gate cells | Legitimate placeholders, but §4 table is the owner-facing product; must not be mistaken for results | Add under §4 heading: `These cells are intentionally unpopulated; a filled cell requires a fresh runner JSON with mtime after job START and a cited job id. Never fill from historical 2026-11-25 JSONs.` | MINOR |

### 2.G Duplicate contradiction registers (BOARD C1–C9 vs V16 vs V26, plus V03/V21/V27/spec README)

| Exact file:line | What is stale | Paste-ready replacement | Priority |
|---|---|---|---|
| `SWARM_BOARD.md:71` C6 "14 RESOLVED, 9 PRESERVED, **4 OPEN** … 4 OPEN have named owners (I02/I03, COORD/F10, COORD/I13, F04)" | V16 §4 records **O1–O14 (14 rows)**; V16 §2 has six OPEN verdict rows; V27 §8 risk 3 says "4 OPEN undercuts"; V21 EV14 repeats "4 OPEN" | `\| C6 \| V16 adjudicated 27 clusters: 14 RESOLVED, 9 PRESERVED; OPEN register O1–O14 in V16 §4 (six OPEN verdict rows in §2: O1,O2,O3,O5,O6,O7) \| V16/V21/V26/V27 \| Canonical register = reports/V16_contradiction_register.md §2/§4; owners assigned in V27 §4.2; paste-ready spec fixes in V26 §2–§5; never quote "4 OPEN" without the §4 register \|` | BLOCKER (dispatch prerequisites O6/O7) |
| `SWARM_BOARD.md:74` C9 "F04 vanilla mask R/G=0 vs A02 R=terrain-class … **OPEN**" | V26 §4.2 resolved it as authored intent vs shipped pixels with an explicit `[U]` residue; X18 independently confirmed F04 | `\| C9 \| F04/D03/X18/X19 shipped R=G=0 off starts vs A02 \`generatemap.inc\` R=class intent \| V26/F04/X19 \| **RESOLVED as layer distinction (V26 §4.2/§4.3)**: R/G enum is donor-intent text, inert on shipped masks; store raw R with ENGINE/UNVERIFIED; never map R→height. Residual [U]: runtime \`[*] = ;\` activation, .src/modded masks, density-from-G, native kernels \|` | BLOCKER (I04/I07) |
| `SWARM_BOARD.md:66` C1 "RESOLVED … authoritative 2-file seam in spec/12 §12.1" | Correct as adjudication, but §12.1 text is stale (V26 §5) and seam is now applied in working tree | Append `; V26 §5: seam now applied once in working tree with .bak-COORD-I11 — do not re-apply; composer path must be re-verified before donor selection` | MINOR |
| `SWARM_BOARD.md:67-70` C2–C5 | C4 says "F01/D05 to resolve" though both landed; C5 "port approx labelled" omits V16-05 alphanull 86/110/123 | C4 → `PRESERVED donor contradiction; X05 A4 + V16-04/O1: quarantine, binary 18×23 authority, never abort parse`; C5 → `PRESERVED (donor vs port layer): alphanull 86/110/123 [O] vs port 8 id-mod-64 zeros [D]/PORT APPROX` | MINOR |
| `V16_contradiction_register.md:18` "27 clusters … **4 OPEN**" vs `:106-123` O1–O14 | Self-inconsistent counts; V21 EV14 inherits the "4" | `27 conflict clusters: 14 RESOLVED, 9 PRESERVED, OPEN register O1–O14 (§4); §2 contains six OPEN verdict rows (V16-04 sub-item, -19, -20, -22, -26, -27). Counts above are point-in-time at the 30-report read; V26/V27 add later corrections.` | MINOR |
| `V21_gate_register.md:23` "X13 … and V17_spec_ready.md were NOT landed"; `:64` EV18 lists X13/V17/N17/composer absent | X13, V17, `spec/00`, N17 and composer now exist; filename `V17_spec_ready.md` is wrong (actual `V17_spec_readiness.md`) | `landing_check: "At write time X13 and V17 had not landed; at the V34 read X13_blend_test_vectors.md, V17_spec_readiness.md, spec/00_EVIDENCE_INDEX.md, spec/terrain_qa_spec.json, terrain_donor_world.gd and terrain_donor_props.gd all exist. Gate rows are unchanged; runnability must be re-assessed."` | MINOR |
| `V27_unverified_owners.md:172,217,255,277` "V03 orphan … report does not exist" vs `:41,62` "V03 landed" | Self-contradictory after mid-audit edit | `V03 landed (V34 glob); the 28 P06 items have a resolution report — §4.4 reconciles its owner list. Retire the word "orphan" from §4.4 heading, §4.5 cross-check and §8 risk 4 / §10 item 5.` | MINOR |
| `V27_unverified_owners.md:222-224` "create spec/00 … D04 MUST LAND … F01 MUST LAND" vs `:58-62` "F01/D04 landed, §00 exists" | Stale priority list after §2.1 correction | `1. COORD Pass 0: fold V26/V37 corrections into spec/00–14 and mark READY (§00 exists). 2. CORE-40/41 DOCUMENT_ONLY (D04 landed). 3. CORE-17/18 DOCUMENT_ONLY fold-in (F01 landed).` | MINOR |
| `spec/README.md:30-36` empty register | No canonical pointer (see §2.B) | Paste the V16/V26/V21/V27 pointer from §2.B above | BLOCKER |
| `reports/V03_open_items_resolution.md:203` "C-B and C-C supersede V16 O5 and F06 U-F06-2" | Another competing supersession claim; V26 §4.2 is authoritative for mask R/G | `C-B (mask R) and C-C (blend factors) are reconciled in V26 §4.2/§2.2 and V27 CORE-07/08; V16 O5/O-F06-2 remain the register keys — do not create a parallel supersession table.` | MINOR |

---

## 3. Priority list

**BLOCKER — resolve before integration / dispatch / owner sign-off**

1. **Canonical contradiction register** — designate `V16 §2/§4` + `V26 §2–§5` + `V27 §4.2`; fix BOARD C6/C9 and `spec/README.md` placeholder (§2.G). Without this, COORD may implement refuted claims (`6` passes, additive clamp, per-ore radii, R→height).
2. **Fold V26 paste-ready fixes into spec** — `spec/01 §3`, `spec/03 §1/§2`, `spec/04 §3/§6/§7`, `spec/07 §1/§6`, `spec/10 §2/§4`, `spec/12 §12.1/§12.4`, `spec/13 §4`, `spec/14 §5` (§2.B). V17/V34 both report no section READY.
3. **Ownership/path reconciliation** — I11 two-file + composer + shader path three-way conflict; seam already applied in working tree; do not re-apply (§2.C, §2.F).
4. **HANDOFF owner-facing accuracy** — composer/props/§00/N17 "absent" claims and the "20 keys" count; gate `TODO(COORD)` cells must stay unfilled until fresh JSONs (§2.F).
5. **I01 count assertion** — global cfg keys are **19** (X20); `spec/09:11` fixed but `spec/00:52` and `HANDOFF:38` still say 20.
6. **Live-state sentences** — every "tree clean / seam unapplied / report pending" statement must be marked point-in-time with a re-verify instruction (V26 §5, V34 §1).

**MINOR — tracking / wording / provenance**

7. SWARM_BOARD: 23 stale `RUNNING` cells + 28 missing rows + stale integration log / pending-section list (§2.A).
8. README: worker/report counts, sequence counts, missing start-here entries, stale Status placeholder (§2.E).
9. CHARTER: D-wave roster, missing X/V waves, 240²/320² "both work" wording, aspirational capture sentence (§2.D).
10. Spec cross-check queues and headings listing landed reports as pending: §03, §04, §05, §06, §07, §08, §10, §11, §12 (§2.B).
11. Orphan citations: `X16` (spec/08), stale filenames `V17_spec_ready.md` (V21), `N1–N22` (spec/00), `X18/V03` unowned (spec/00 §5 U20) (§2.B/§2.G).
12. V27 internal contradictions after mid-audit edits (§2.G).

---

## 4. Risks

1. **[D] Concurrent-write risk (top):** 4 reports landed in the last minutes of this audit and 4 docs were edited mid-read. Any paste-ready fix applied from this report without re-running §1's commands may itself become stale. Mitigation: paste only after a fresh glob/status; keep "point-in-time (V34/V26)" qualifiers.
2. **[D] Silent resolution of preserved contradictions:** BOARD C2–C5, V16's 9 PRESERVED rows and V26's "both-stage-specific" verdict can be mistaken for defects to fix. Adopting `TileSmoothPasses=6`, the plain `tilesmooth.cfg`, a `[Min,Max]` clamp, per-ore mine radii, or R→height would produce plausible but non-donor behaviour. Every replacement above keeps both literals and the policy.
3. **[D] Double-apply / rollback risk:** the seam is now applied once with `.bak-COORD-I11`; PLAN still describes it as a future one-file edit. A second worker following PLAN could duplicate `set_terrain_backend()` and `stats` keys (V04 C8, V11 R1, V26 §5).
4. **[O] Missing-script risk at V26 read is now closed on disk but not gated:** composer and props exist untracked; selecting `"donor"` before parse + gate verification would still fail. `HANDOFF.md:131` gives the opposite (absence) reason.
5. **[D] Wrong-path risk:** three shader paths in circulation; tools/implementers may create a third file or edit a retired alias. COORD must name one path and update both PLAN and V11-derived spec text.
6. **[O] Owner-facing placeholder risk:** `HANDOFF.md §4` has 11 `TODO(COORD)` cells; copying them into a final report as PASS would violate V06/V21/V15 and the charter's no-fake-gate rule.
7. **[U] Epistemic ceiling:** no donor GPU A/B frame exists. V26/V27/X20 verdicts are value/line/count/opcode adjudications only; none is visual parity. All port consequences remain `PORT APPROXIMATION`.

---

## 5. Open questions

1. **COORD:** Which artifact is canonical for statuses — the refreshed `SWARM_BOARD.md` or the directory glob? (V34 recommends glob + board refresh.)
2. **COORD:** Name the single contradiction register. V34 recommends `V16 §2/§4` as the register, with `V26` as its patch log and `V27` as its owner appendix; BOARD C1–C9 becomes a short index, `spec/README.md` a pointer only.
3. **COORD:** Adopt V26's paste-ready spec text verbatim, or re-derive after the V37/X27/X28/X30 landings? (Those reports landed during/after V26 and are not in its scope.)
4. **COORD/I11:** Confirm the working-tree seam is the authorised single application and that the **existing** `terrain_donor_world.gd`/props files are accepted (not re-created) with SHA checks against `.bak-COORD-I11`.
5. **COORD:** Decide the shader path: `variant3d/shaders/terrain_donor.gdshader` (disk) vs `variant3d/shaders/terrain_donor_shader.gdshader` (V11 N13) vs `variant3d/scripts/...` (PLAN I10); then update both docs, not code by this worker.
6. **COORD/I01:** Confirm X20's 19-key correction and whether a count assertion of 20 is present in any landed tool; if so it must be corrected before I01 is signed.
7. **COORD/I13:** When will `HANDOFF.md §4` be finalized with fresh runner JSONs (mtime after job START), 575/582/585 acknowledged with reasons, and explicit 240²/320² overlays labelled by actual size (V16 O3)?
8. **Owner:** Can a donor GPU A/B frame ever be produced? Until yes, all tier-3 verdicts stay `UNVERIFIED` and no document may claim parity.

---

## 6. Five-line summary (V34)

1. **[O] 71 reports and 17 spec files are on disk; the board lists 43 workers with 23 stale `RUNNING` cells and 28 missing rows, and `spec/README.md` still marks every section PENDING.**
2. **[O] V26's four paste-ready spec fixes (blend math, food rects/`mapsize`, mask R/G, stale git/seam) have not been folded in; V16/V26/V27/BOARD/V21 still disagree on the OPEN count and on C9.**
3. **[O] The seam is applied in the working tree with `.bak-COORD-I11`, while PLAN I11 still says "world3d.gd seam only" and three shader paths are in circulation — ownership docs must be reconciled before dispatch.**
4. **[O] `HANDOFF.md` keeps legitimate `TODO(COORD)` gate placeholders but carries stale absence claims (composer, props, §00, N17) and the refuted "20 global keys"; `V21`/`V27` also contain point-in-time claims corrected by later landings.**
5. **[U] No donor parity claim: every finding is a file:line/directory-state adjudication; COORD must re-run the §1 verification commands before applying any fix.**

*End of V34 report. Exactly one repo file written; no doc, source, shader, config, asset, test, JSON, git, runner, Godot, donor or `app/` state changed.*
