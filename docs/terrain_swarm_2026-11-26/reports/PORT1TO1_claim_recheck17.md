---
id: PORT1TO1-CLAIM-RECHECK17-2026-11-27
title: "CLAIM-RECHECK17 — post-review-wave (gen/art/laws + gaps + addendum + consolidate + nation-label) guard re-sweep"
worker: WAVE-CLAIM17 (read-only subagent; full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-27
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION__NO_PARITY_CLAIM__NO_APPROXIMATION
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_claim_recheck17.md
files_created: [docs/terrain_swarm_2026-11-26/reports/PORT1TO1_claim_recheck17.md]
files_edited: []
scope_guard: "Repo file/line reads plus read-only text scans (grep/glob) over existing files. No source, shader, config, asset, test, fixture, result JSON, backup, queue, Godot process, runner job, gate, capture, ROI metric, git command, commit or donor binary was created, modified, opened, hashed, executed or compared; no donor GPU A/B frame was produced or compared. Every quoted forbidden literal below is a SCAN TARGET, NEGATION, GUARDED OBSERVATION or SUPERSESSION CITATION — never a claim. Exactly one repository file written: this report."
parity_status: UNVERIFIED
parity_claim: NONE
parity_claim_code: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified is non-empty; six-condition chain 0/6 CLOSED; nine P0 rows OPEN; 71 open [U] (A42/B14/C5/D10); no donor GPU A/B frame; no matched camera; no COORD ruling."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
output_files: "Exactly one repository file written: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_claim_recheck17.md"
---

> **PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.**

# CLAIM-RECHECK17 — guard recheck after the full-port piece review wave (current tree, 2026-11-27)

Read-only label/string audit. Follows `PORT1TO1_claim_recheck16.md` (baseline; §§1–10). Re-sweeps after the full-port piece review wave that landed since recheck16: `PORT1TO1_review_gen.md` (REVIEW-GEN), `PORT1TO1_gen_gaps.md` (GEN-GAPS), `PORT1TO1_review_art.md` (REVIEW-ART), `PORT1TO1_art_gaps.md` (ART-GAPS), `PORT1TO1_review_laws.md` (REVIEW-LAWS), `PORT1TO1_laws_addendum.md` (LAWS-ADDENDUM), `PORT1TO1_review_consolidate.md` (REVIEW-CONSOLIDATE), `PORT1TO1_nation_label.md` (NATION-LABEL), plus the COORD-applied label-only fix at `variant3d/scripts/world3d_entities.gd:249` (pre-image preserved as `variant3d/scripts/world3d_entities.gd.bak-NATIONLABEL`). Owner insists terrain is not full and forbids parity claims; none is made here. All `file:line` are current working-tree numbers at this read. Parity UNVERIFIED, no approximations, no parity claim.

## 1. Scope and point-in-time cut

Scanned in full: the eight review-wave reports listed above, `PORT1TO1_claim_recheck16.md` (baseline), `PORT1TO1_claim_recheck15.md` / `recheck14.md` (§§6–8 carried), `PORT1TO1_PLAN.md` (rows 336 REVIEW-CONSOLIDATE DONE / 337 NATION-LABEL + COORD source fix DONE; row 186 BLOCKED), `HANDOFF.md` (parity-string scan), live `variant3d/` source (`.gd`, `.gdshader`, `.py`, `.json`, `.cfg`, `.tscn`). Classes C1–C6 from `PORT1TO1_claim_final.md:28-33` / `claim_recheck6.md:41-48` / `claim_recheck13.md:29`; C7 = stale `ABSENT`/`EXACT` supersession; C8 = false "Verbatim from" labels. `laws_addendum` exists only as the single file `PORT1TO1_laws_addendum.md` (no `reports/laws_addendum` directory on disk — read attempted, not found). `CAPTURE-DEEP` still has no artifact (no `*CAPTURE*DEEP*` report file; consolidate `:16` records PENDING).

## 2. New-report frontmatter + verdict verification — 8/8 PASS (guarded)

Every review-wave report carries an UNVERIFIED / no-parity guard and a literal `RESULT IS NOT GOOD` verdict; none asserts parity, completeness, or a gate pass:

| Report | UNVERIFIED / no-parity guard | Literal `RESULT IS NOT GOOD` |
|---|---|---|
| `PORT1TO1_review_gen.md` | `:9` parity UNVERIFIED + no parity claim + no approximations; `:151` repeated | `:10` (chain/blocking header), `:151` (close-out), `:155` (end line) |
| `PORT1TO1_gen_gaps.md` | `:8` parity UNVERIFIED + no approximations + no parity claim; `:85` repeated | `:9` (header), `:84`, `:85` (blocking close-out), `:87` (end line) |
| `PORT1TO1_review_art.md` | `:10` parity_guard (UNVERIFIED, no parity, no completeness, no approximation, no A/B); `:176` repeated | `:10` (guard), `:175` (binding verdict), `:180` end context |
| `PORT1TO1_art_gaps.md` | `:10` parity_guard (same wording); `:95` repeated | `:10` (guard), `:94` (binding verdict) |
| `PORT1TO1_review_laws.md` | `:8-11` parity UNVERIFIED / claim NONE / visual false; `:15` reviewer line | `:14` (frontmatter verdict), `:132` (§16), `:134` (end line) |
| `PORT1TO1_laws_addendum.md` | `:8` parity UNVERIFIED / claim NONE / visual false; `:11` reviewer line | `:10` (frontmatter verdict), `:61` (§6), `:63` (end line) |
| `PORT1TO1_review_consolidate.md` | `:14` parity UNVERIFIED + no parity claim + no approximations; `:75` repeated | `:15` (chain/P0 header), `:75` (close-out), `:78` (end line) |
| `PORT1TO1_nation_label.md` | `:10` parity_guard (UNVERIFIED, no parity, no completeness, no A/B); `:85` repeated | `:84` (binding verdict; `RESULT IS NOT GOOD while blocking_unverified non-empty`) |

§0/§5 non-closure statements are intact in every report (review_gen `:15-16`; art_gaps `:95-96`: PRESENT paths are file-presence only; review_laws `:86`, laws_addendum `:15`, `:60`; consolidate `:18-21`; nation_label `:76-80`, `:84-86`). IMPLEMENTED/PARTIAL/ABSENT vocabularies are defined as existence-only at review_gen `:21`, review_art `:24-27`, art_gaps `:15`.

## 3. Unguarded parity-claim sweep (C1–C6) — NONE found

| Class | Result | Exact evidence |
|---|---|---|
| C1 true flags | **NONE** | Repo-wide `RESULT IS GOOD` hits remain the previously inventoried conditionals / forbidden-phrasing lists / quoted templates / negations (recheck16 §3 carried; no new instance in any of the eight reports). Live `variant3d/` grep for `RESULT IS GOOD` returned **no match** this pass. Guarded `false` values intact: `terrain_donor_mesh.gd:271` `visual_parity_claim: bool = false # hard guard, never set true` + `.bak-*` copies; `skin/index.json:1` `"visual":"UNVERIFIED"` + `"label":"PORT APPROXIMATION — NOT DONOR PARITY"`; `t_terrain_donor.gd:788-795` test asserting the false value; fail-closed guard `terrain_donor_props.gd:747` `if bool(root.get("visual_parity_claim", true)): return false` (refuses a claiming index, not a claim). `HANDOFF.md` scan: only guarded `UNVERIFIED — no parity claim` / `parity=UNVERIFIED` / `RESULT IS NOT GOOD` lines, no live flag. Plan scan: only guard-audit status cells (`:174` PASS on label fixes, `:152` 0/6 chain, `:186` BLOCKED). |
| C2 unguarded `RESULT IS GOOD` | **NONE** | All eight reports add only governed `RESULT IS NOT GOOD` verdicts (§2). No new instance anywhere in the wave. |
| C3 owner-supplied-as-pass | **NONE** | No report treats an owner supply, capture presence, or derived-tier presence as a pass. Review_gen §4 marks every prior item re-verified-not-new (`:133-147`); review_art §1 P-1..P-9 are cite-once-not-re-audited (`:32-42`) with `[U]`s kept by cited owners; §2 IMPLEMENTED paths are labelled "existence evidence only … they close nothing" (`:39`, `:175-176`); art_gaps §§1–8 verdicts are `confirmed ABSENT` / `PRESENT-UNDER-OTHER-NAME excluded` / `WIRING-UNPROVEN [U]` — never passes; review_laws §10 delta items are explicitly "NOT in the final brief or owner packet" (`:86-95`); laws_addendum §§1–5 each end "narrows only"; consolidate §§1–3 every row ends "Narrows only". |
| C4 donor-parity assertion | **NONE unguarded** | Explicit refusals carried intact: review_gen `:15` ("never correctness, never a gate PASS, never donor fidelity"); review_art `:170` (any port visual equalling donor motion/colour/FX/timing **Denied**); art_gaps `:94-96` (PRESENT paths are file-presence only, not parity); review_laws `:132` (no A/B frame, no approximation authorised); consolidate `:20-21` (no donor A/B or COORD ruling); nation_label `:78` (no donor/model-viewer A/B, no fixed-camera capture, no byte/hash comparison performed). |
| C5 gate/metric→parity | **NONE** | Explicit refusals: review_art `:176` (§2 existence paths are file-presence only, not a gate pass); review_laws §§1–9 every PARTIAL ends `[ALREADY-COVERED]` with missing half named, never promoted; consolidate `:18` (runtime rows retire only on their own owner-run zero-mismatch capture/harness); nation_label `:80` (chain 0/6, blocking non-empty). No count-as-fidelity pass: death-48/stage/hull/`eurmilanim.obj`/fx/skin paths are inventoried as a manifest path list, never as donor fidelity (consolidate `:39`). |
| C6 misread-risk phrasing | **NONE is a parity claim** | Closest readings are fenced: IMPLEMENTED = "code/bytes present (runtime still UNVERIFIED throughout)" (review_gen `:21`); IMPLEMENTED-existence with "recorded so a future manifest audit has the path list; they close nothing" (consolidate `:39`); seven art IMPLEMENTED paths with byte/vert/bbox verification still under `[U]-G2` (review_art `:52-54`); five PARTIAL verdicts with exact missing half (review_art claim register `:164-165`); `no file found` stated literally with the searched pattern (review_art `:26`, art_gaps `:35-38`). No PASS closes a P0 row or retires a `[U]`. |

**C1–C6 result: no live unguarded parity claim in any of the eight review-wave reports, the plan, HANDOFF, or live `variant3d/`, and none introduced by the wave.**

## 4. `world3d_entities.gd:249` COORD label fix — label-only PASS, guards intact, no claim introduced

Pre-image (`world3d_entities.gd.bak-NATIONLABEL:249`) vs live (`world3d_entities.gd:249`) diff, verified this pass:

- Pre-image: `"BLOCKED (NATION_DONOR_01 G7-G10/C6): 0/172 converted OBJs carry a nation key (no rus*/bav*/eur*/tur*/ukr* stems); manifest generic peasant->peaukr.dds, 8 core buildings->ukr*.osm/ukr*.dds, 0 rus-keyed and 0 bav-keyed textures; Bavarian musketeer18bav/grenadierbav and Ukrainian chaika are absent from manifest+obj. Missing-art owner: manifest.json + assets/models/obj/; NOT VISUALLY FIXED."`
- Live: `"BLOCKED (NATION_DONOR_01 G7-G10/C6) [label corrected 2026-11-27; supersedes the stale 0/172 no-nation-key census]: nation-keyed OBJs ARE present on disk (bav/…; ukr/…; tur/…; swe/…; rus/…; eur-keyed obj/ NOT observed); still absent under assets/models/: Ukrainian chaika, rusmil/turmil building meshes; grenadierbav pending manifest-owner check; nation stage/ghost art per NATION_STAGE_GHOST_BLOCKED_STATUS (:270). Presence is file-presence only, NOT donor visual parity. Missing-art owner: manifest.json + assets/models/obj/; NOT VISUALLY FIXED; visual UNVERIFIED."`

Label-only proof: const name, type (`String`), `BLOCKED` posture, `NATION_DONOR_01 G7-G10/C6` cite, `Missing-art owner` routing, and `NOT VISUALLY FIXED` posture unchanged; only the evidence clause narrowed to actually-missing items plus a point-in-time qualifier and explicit `NOT donor visual parity` / `visual UNVERIFIED` guards (the exact wording proposed in `PORT1TO1_nation_label.md:59-67`). Neighbours untouched: `:241` EXACT, `:242` FALLBACK, `:247` ROLE_SUB, `:256-265` peasant SIDs, `:270` STAGE_GHOST, `:1002` dict wiring (`"nation_mesh_blocked_evidence": NATION_MESH_BLOCKED_EVIDENCE`) — all byte-identical in role. No value, logic, guard, branch, behaviour, or visual output changed; parity guards strengthened, not weakened. Parse status per plan row 337 DONE; backup `.bak-NATIONLABEL` preserved. **The fix introduces no claim and closes no `[U]` or P0 row** (nation_label `:76-80`: cannot close `[U]-NATION-LABEL` art gaps, `[U]-T-A/T-B`, `[U]-G/R`, `[U]-F/S`, `[U]-MILL-SAIL`, `[U]-NAVAL-TLF`, or any P0 row).

## 5. C7 stale ABSENT/EXACT supersession — intact, no new unfootnoted claim

Carried from `claim_recheck13.md` §5 via recheck14 §5 / recheck15 §7 / recheck16 §6 (unchanged): **exactly 29 inline `[SUPERSESSION-FIX: …]` footnotes across 10 files** cover all 13 C7 gap rows. New-wave `no file found` rows are all current-pass point-in-time presence findings with governing ids and open follow-ups, never historical closures: review_gen G-NEW-1 (`:84-89`) and G-NEW-5 (`:112-117`) with negative-grep / double-glob proof; review_art §§4.1–4.3 (`:122-141`) with `[V]` per pattern; art_gaps §§1–3 (`:20-39`) with directory-control and PRESENT-UNDER-OTHER-NAME exclusion (rusmild/turmild decals ruled not-mills, `:37`); review_laws §10 items 6–8 (`:93-95`) with exact port paths. No new unfootnoted stale `ABSENT`/`EXACT` claim introduced by the wave or the `:249` fix.

## 6. C8 false "Verbatim from" labels — no new false label

Grep for `Verbatim from` across all eight review-wave reports returned **no match** — no new verbatim-provenance assertion of any kind, true or false. Live sites remain corrected per recheck14 §6 / recheck16 §7 (`PORT1TO1_handoff_checklist.md:276` "Verbatim only from …"; `PORT1TO1_internal_validation.md:137` "Adapted from … NOT verbatim"). `variant3d/` `Verbatim from` hits are pre-existing port-internal code comments (`infantry17.py:53`, `cavalry.py:76` bake-table cites; `world3d_fog.gd:614` + `.bak-*` copies citing `app/scripts/world.gd:2251-2255` port state encoding) — legitimate static provenance, not donor-runtime parity provenance, unchanged by this wave. The `:249` fix introduces no provenance label of any kind.

## 7. Remaining gaps — exact file:line, LABEL-ONLY (non-substantive; zero parity/P0 effect)

| # | Exact file:line | Stale status text | LABEL-ONLY remediation |
|---|---|---|---|
| G-1 (carried, recheck16 G-1) | `PORT1TO1_bundle_verify.md:158` (cf. `:16`, `:29`, `:190`) | Still reads "Label-only correction (PROPOSED — NOT applied by this read-only worker)". Live correction recorded at `:16`/`:29` ("CORRECTED by COORD 2026-11-27"). | Append point-in-time qualifier citing `hash_manifest.md:99` (`33325` / `F794807D…6750`, identity only). No hash recomputation. |
| G-2 (carried, recheck16 G-2) | `PORT1TO1_hygiene_final.md:50` (HF-5), `:87`, `:111` | `:50`/`:87` still carry pre-correction "STILL OPEN … not applied" phrasing for R1/R2 while `:111` records "R1/R2 applied by COORD 2026-11-27 … now `RESOLVED`". | Change stale status cells to "**RESOLVED — R1/R2 applied by COORD 2026-11-27**". Reviewer line and SHA unchanged. |
| G-3 (carried, recheck16 G-3) | `PORT1TO1_verdict_sync.md:96`, `:243-244`; `PORT1TO1_handoff_vsync.md:69-72`, `:87`; `PORT1TO1_handoff_check2.md:79-80`; `PORT1TO1_claim_recheck9.md:82-83`, `:86` | Historical registers phrase the labels as "proposed / not applied" (L-1/L-2 / R1/R2). Live sites corrected. | Append one-line "**APPLIED 2026-11-27 by COORD**" footnote at each site; retain history. No verdict change. |
| — | (recheck16 G-4…G-5 CLOSED; this wave adds none) | `:249` stale census no longer live — COORD label-only fix DONE (plan row 337, §4). Nation-label `[U]-NATION-LABEL` open tail (chaika, rus/tur mills, grenadierbav pending, stage/ghost art) stays owned by the manifest/obj lane. | No action. Retained here only to record the closure of the stale premise. |

G-1…G-3 change no truth condition. C7 source sites closed (§5); C8 live sites corrected (§6). **No new label-only gap introduced by the review wave or the `:249` fix.**

## 8. Confirmation — no file-presence-as-fidelity, no code/asset/config change, no donor execution, no git

- **No report treats file-presence findings as donor fidelity.** Review_gen `:15`, `:151`; review_art `:44-46`, `:164-170`, `:175-176`; art_gaps `:94-96`; review_laws claim register `:122-128`; consolidate `:18-21`, `:39`; nation_label `:76-80`, `:84-86` — all bind PRESENT/IMPLEMENTED paths as existence-only, never correctness, never a gate pass, never donor parity.
- **No code/asset/config change by this worker.** Exactly one file written — this report; none edited. Inspection was read-only file/line reads and text scans only.
- **No donor execution and no git by this worker.** No donor binary opened, hashed, executed or captured; no Godot process, runner, gate, capture, ROI comparison, git command or commit run.
- **No approximation adopted.** No port value substituted, retuned or promoted; no test weakened; no `[U]` closed; no P0 row retired.

## 9. Verdict

- `parity.status = UNVERIFIED`, `parity.claim = NONE`, `parity_claim_code = NONE`, `visual_parity_claim = false` dominate the rechecked set.
- **Six-condition chain 0/6 CLOSED**; no donor GPU A/B frame; no matched camera; no COORD ruling. The review wave (7 gen + 7 art + 8 law gaps, all narrows-only) plus the `:249` label-only fix narrow structure only and close no P0 row.
- **9 P0 rows OPEN**, **71 open `[U]`** (A42/B14/C5/D10). Because `blocking_unverified` is non-empty, **`RESULT IS NOT GOOD`** — unconditionally, in every form inventoried.
- No unguarded parity claim, no terrain completeness/parity declaration, no static-`[D]`-to-behavioural promotion, no count-as-fidelity pass, no "0 mismatches on checkable conditions" treated as donor parity, no unfootnoted stale ABSENT/EXACT claim, no false verbatim label at a live site, and no claim that a deterministic repeat, gate, ROI metric, hash or static `[D]` fact closes donor parity was found.
- REVIEW-CONSOLIDATE (plan row 336) DONE; NATION-LABEL + COORD `:249` source fix (plan row 337) DONE with backup kept. Row 186 (final owner review) remains the single BLOCKED row.
- **No approximation adopted, no parity claim, no code/Godot/git/donor execution.** Exactly one repository file was written: this report.

*End of CLAIM-RECHECK17. PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass. `RESULT IS NOT GOOD`; chain 0/6; `blocking_unverified` non-empty; no approximations; no parity claim.*
