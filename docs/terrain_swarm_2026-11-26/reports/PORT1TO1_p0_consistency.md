---
id: PORT1TO1-P0-CONSISTENCY-2026-11-26
title: "Read-only consistency audit of the six owner P0 experiment packets against their cited source reports, the packet index and PORT1TO1_PLAN"
worker: P0-CONSISTENCY (read-only subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_CODE_GODOT_GIT_DONOR_EXECUTION
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_consistency.md
files_created: [docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_consistency.md]
files_edited: []
scope_guard: "Repo/doc file reads and read-only text/pattern searches only. No source, shader, asset, config, test, fixture, result JSON, git state, Godot process, runner job, gate, capture or ROI metric created/modified/executed; no donor binary executed or captured; no approximation supplied; no parity claim. Exactly one repository file written: this report."
parity_status: UNVERIFIED
parity_claim: NONE
visual_parity_claim: false
verdict: "RESULT IS NOT GOOD — blocking_unverified non-empty (P0-1…P0-8 plus register tails); six-condition chain 0/6 CLOSED; no donor GPU A/B frame; no approximations; no parity claim."
reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_p0_packet_index.md
  - docs/terrain_swarm_2026-11-26/PORT1TO1_PLAN.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_u_register_update.md
---

# PORT1TO1 — P0 packet consistency audit (2026-11-26)

> **Mandatory reviewer line, verbatim:** PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

This audit cross-checks the **six landed owner packets** listed in `PORT1TO1_p0_packet_index.md` §1 against (a) their cited source reports, (b) the packet index and (c) `PORT1TO1_PLAN.md`. It is a **label/citation consistency check only**: it does not execute a donor binary, a Godot process, a harness, a gate or a capture, and it closes no `[U]`. Corrections below are **label-only** — they change no donor value, no port line and no termination gate.

## 0. Audit method and verdict conventions

- **Cited-file existence:** every report path appearing in a packet frontmatter (`upstream` / `governing_sources`) or body cite was checked against the on-disk `reports/` listing.
- **Pinned-VA / evidence-id presence:** every `ev_[0-9a-f]{20,}` token and every `0x[0-9a-f]{5,8}` VA token in the six packets was searched across the report corpus (packet excluded from its own match set). Full 64-hex ids were additionally checked against the packet's named upstream reports.
- **Termination-criterion comparison:** each packet's §5/§8/§10 zero-mismatch table was compared with the corresponding source report section (source criterion quoted in §3 below).
- **Unproven-as-`[O]` scan:** every numeric cited as `[O]/[D]` in a packet was traced to a source that labels it `[O]/[D]`; every value still open in the source was checked to remain `[U]` with a named experiment and a conditional (never unconditional) port change in the packet.
- **Verdict:** `parity.status = UNVERIFIED`, `parity.claim = NONE`, `visual_parity_claim = false`, six-condition chain **0/6 CLOSED**, **`RESULT IS NOT GOOD`** while `blocking_unverified` is non-empty. No approximation is supplied and no parity claim is made by this audit.

## 1. Cited-file existence — PASS, with one stale alias

All cited source reports exist on disk. Counts per packet:

| Packet | Cited source reports (frontmatter + governing sources) | Missing files |
|---|---|---|
| `PORT1TO1_water_owner_protocol.md` | 5 DEC reports (`DEC_U_water_capture`, `_water_scalar_select`, `_water_fbo`, `_water_lib_params`, `_hmap_identity`) + port files | none |
| `PORT1TO1_fow_owner_protocol.md` | 12 reports (`PORT1TO1_u_register_update`, `DEC_U_fog_camera_hud`, `DEC_U_fow_grid`, `_fow_grid_deep`, `_fow_persist`, `_fow_knobs`, `_fow_tint`, `DEC_U_fog_territory`, `PORT1TO1_owner_decisions`, `PORT1TO1_endgame_protocol`, `PORT1TO1_water_owner_protocol`, `DEC_U_endgame_fow`) + port file | none |
| `PORT1TO1_tick_owner_protocol.md` | 9 reports/sources (`DEC_U_tick_order`, `_tick_driver`, `_skirmish_tables`, `_ai_activation`, `_rng_ledger`, `PORT1TO1_u_register_update`, `_owner_decisions`, `_fixed_step_plan`, `X21_rng_vectors`) + port files | none |
| `PORT1TO1_blend_owner_protocol.md` | 8 reports (`PORT1TO1_u_register_update`, `_owner_decisions`, `_acceptance_plan`, `DEC_U_blend_op`, `_aaf_triggers`, `_state_map`, `_aaf_art_audit`, `IMPL_U_aaf_triggers`) + port file | none |
| `PORT1TO1_save_owner_protocol.md` | 9 reports (`PORT1TO1_u_register_update`, `_owner_decisions`, `_acceptance_plan`, `DEC_U_save_contract`, `_save_float`, `_save_bits`, `_save_tobj`, `_settings_persist`, `_famine_profile`) | none |
| `PORT1TO1_selection_owner_protocol.md` | 8 reports (`PORT1TO1_u_register_update`, `DEC_U_selection`, `_camera_projection`, `_gl_perspective`, `_minimap_tail`, `_collision_full`, `_fog_camera_hud`, `PORT1TO1_owner_decisions`) | none |

**Stale filename (F1).** The task brief names `DEC_U_fow_territory.md`; the on-disk and plan-cited file is **`DEC_U_fog_territory.md`** (`PORT1TO1_PLAN.md` task 130; `DEC_U_fog_territory.md` exists). `PORT1TO1_fow_owner_protocol.md:27,52` already discloses this and its body (`:69,198,261`) uses the on-disk name. **Label-only correction:** keep `DEC_U_fow_territory.md` marked as a stale task-brief alias only; cite `DEC_U_fog_territory.md` in all body/frontmatter references (already satisfied in the body).

## 2. Pinned VA / evidence-id presence — PASS with two label-only findings

| Packet | Full 64-hex `ev_` ids | Source-attested? | Long `ev_` tokens (≥20 hex) | `0x` VA tokens |
|---|---|---|---|---|
| Water | 16 | all 16 present in ≥1 cited upstream | 19 tokens; **18 attested, 1 not (F2)** | 50 unique; all attested (one notation variant, F5b) |
| FOW | 5 | all 5 present in cited upstreams (`DEC_U_fow_grid`, `_fow_grid_deep`, `_fog_camera_hud`) | 5; all attested | 44 unique; all attested |
| Tick | 0 (VAs + `file:line` cites only) | n/a | 0 | 12 unique; all attested (`DEC_U_rng_ledger`, `DEC_U_gen_seed`, `X21_rng_vectors`, `D02_seed_rng`) |
| Blend | 0 (AAF row numbers + `file:line` cites only) | n/a | 0 | 0 |
| Save | 0 (byte patterns + `file:line` cites only) | n/a | 0 | 1; attested |
| Selection | 0 (VAs + evidence citations carried as `[O]` from DEC sources) | n/a | 0 | 54 unique; all attested (`DEC_U_selection`, `_camera_projection`, `_gl_perspective`, `_minimap_tail`) |

Representative full-id results (water): `ev_84eb83…`, `ev_6eec1c…`, `ev_711e2a…`, `ev_c380af…`, `ev_626574…`, `ev_c987ab…`, `ev_67a508…`, `ev_5aaec0…`, `ev_d9277e…`, `ev_513eea…` (see F2), `ev_a66a95…`, `ev_8218b0…`, `ev_ab751f…`, `ev_bbdba2…`, `ev_2b512f…`, `ev_257c8a…`, `ev_8096d5…`, `ev_ada198…`, `ev_5aaec0…` — all appear verbatim in at least one cited water upstream. FOW full ids `ev_ae7d08…`, `ev_4f7e8d…`, `ev_f476d1…`, `ev_be8575…`, `ev_d80780…` all appear in `DEC_U_fow_grid.md` / `DEC_U_fow_grid_deep.md` / `DEC_U_fog_camera_hud.md`; the `FOW-TAG` variant is explicitly self-disclosed at `PORT1TO1_fow_owner_protocol.md:88` and matches `DEC_U_fow_persist.md:27`.

**F2 — water packet U1-COPY evidence id is not source-attested (real citation defect).**
- Packet `PORT1TO1_water_owner_protocol.md:55` cites `ev_513eeafe38634fbdc522d1db8484a0f84f018b6e59a0f58983d37c7202338` (61 hex chars).
- No report in the corpus contains that string. The two source-attested forms are:
  - `DEC_U_water_lib_params.md:40`, `DEC_U_hmap_identity.md:54`, `DEC_U_water_mesh_uv.md:60`: `ev_513eeafe38634fbcdc522d1db8484a0f84f018b6e59a0f58983d37c7202338`
  - `DEC_U_water_scalar_select.md:35`, `DEC_U_water_runtime.md:61`: `ev_513eeafe38634fbdc522d1db078484a80f84f018b6e59a0f58983d37c7202338`
- **Label-only correction:** replace the U1-COPY id with one source-attested form (either cited upstream form is valid) and add the standing note "evidence-id spelling varies across upstream reports; re-verify by hash before relying on it". No donor value or gate changes.

**F5 — corpus-level evidence-id spelling variance (label-only).** `ev_ab751f…`, `ev_8218b0…`, `ev_d9277e…`, `ev_67a508…`, `ev_2c6662…`, `ev_513eea…` each appear in two or more spellings across the water reports. The packet forms are attested in at least one cited upstream in every case except F2; `PORT1TO1_evidence_index.md` / `_addendum.md` contain no canonical form to arbitrate. **Label-only correction:** mark all such citations `re-verify by hash before relying`; do not silently normalise.

**F5b — VA notation variance (label-only).** Water packet `:42` writes `0x4c0f5c` for `glUseProgram`; `DEC_U_water_capture.md:63` writes `004c0f5c` and `DEC_U_water_runtime.md:91` writes `FUN_004c0f5c`. Same VA, attested; notation-only.

## 3. Zero-mismatch termination criteria — PASS (6/6), one packet-authored addition flagged

| Packet | Packet criterion section | Source criterion section | Result |
|---|---|---|---|
| Water | §5 (U1/U4*/U12-A…S/U3/U6/U5) | `DEC_U_water_capture.md` §5; `DEC_U_water_scalar_select.md` §5; `DEC_U_water_lib_params.md` §6; `DEC_U_water_fbo.md` §8 | **MATCH.** `0 differing bits/elements` across `≥2 water-visible frames + 1 camera move`, same Phase-1 PATH; closed gate / missing dump / PATH mixing ⇒ `[U]`; no partial credit. |
| FOW | §5 (F-GRID a–e, E-KNOB-defaults, F1-MINI-TINT/RESOURCE, E-FOGT) | `DEC_U_fow_grid_deep.md` §5; `DEC_U_fow_knobs.md` §6; `DEC_U_fow_tint.md` §4; `DEC_U_fog_territory.md` §5 | **MATCH.** Linear-scale fit 0 off-step cells; OR/threshold/team 0 mismatching cells; occlusion pure-disc or rotated-transect 0 mismatches; persistence matrix ×2; domain ×3 with 0 out-of-domain; tint 3 runs × both DPI arms with 0 misclassified; E-FOGT 3 identical-seed runs, divergent dump quoted never averaged. |
| Tick | §5 (U-O1a…O7 / U-D1…D9 / U-A6r-A7) | `DEC_U_tick_order.md` §5; `DEC_U_tick_driver.md` §3; `DEC_U_ai_activation.md` §6 | **MATCH.** Byte-identical `H_0…H_3599` across 3 seeds and process restarts (6 sequences) and all load profiles; single survivor, losers listed; wrong-stream draw / single-tick divergence ⇒ `[U]`; no order shipped. |
| Blend | §10 (B1/B2/B3/B4, C1/C2, 0,0 invariant, window unit) | `DEC_U_blend_op.md` §6; `DEC_U_aaf_triggers.md` §6; `DEC_U_state_map.md` §4 | **MATCH.** Verdict/tuple byte-identical frame-for-frame and hash-for-hash across **3/3 trials**; `(0,0)` == single-tick hard cut; B1 support only; no curve/weight/handler tick invented. |
| Save | §5 (E-T0 control, single-field divergence, encoding, 3 repeats, completeness, no promotion) | `DEC_U_save_contract.md` §4; `DEC_U_save_float.md` §§1–2; `DEC_U_save_bits.md` §1; `DEC_U_save_tobj.md` §5 | **MATCH.** E-T0 byte-identical except six jitter fields else harness broken; exactly named field diverges at predicted offset with predicted encoding; 3 identical-seed repeats; unpredicted divergence ⇒ FAIL/`[U]`; contract stays `PORT EXTENSION, no byte-parity claim`. |
| Selection | §8 (T1–T10) | `DEC_U_selection.md` §§2–4; `DEC_U_camera_projection.md` §§1–5; `DEC_U_gl_perspective.md` §§1–4; `DEC_U_minimap_tail.md` §4 | **MATCH** for T1–T6, T8–T9, T10: ≥5 surveyed points 0 px; 1-px rect membership 0 mismatches; exact-tie / seed-`0.5` / 1-px nudge / FOW-veto 0; clip boundary exact; fixed rig held. T7 is a packet-authored synthesis (F6). |

**F6 — selection T7 (`E-U13-AABB`) termination is packet-authored, not verbatim from a cited source (label-only).** The packet §6/§8 T7 requires "one fitted inside-test predicts per-candidate include/exclude on 1-px sweeps at two depths with 0 mismatches, and pre/post-`SortRayCastList` logs identify the sort key with zero residual inversions". `DEC_U_selection.md` §2.2(e) and §5, `DEC_U_collision_full.md` §7/C-CAP-4 and `DEC_U_camera_projection.md` §4.2 provide the setup and `[U]` status but not that exact two-part criterion. **Label-only correction:** tag T7 as "packet-composed from cited `[U]` AABB/sort-key items; source reports supply setup, not this verbatim criterion"; leave the criterion and its 0-mismatch requirement intact.

## 4. Unproven-as-`[O]` scan — PASS

No packet asserts an unproven value as `[O]`. Checks and examples:

- **Water:** `0.4/0.3/4/0.1/0.5/1/0.05/2/0.01/0.4/0.825` are labelled ctor defaults `[O]` at `FUN_00856080` (`DEC_U_water_lib_params.md:105`), while the *live* tuple stays `[U]`-U4*; `0.01/0.02` are labelled pre-bind source defaults (`DEC_U_water_scalar_select.md:94-95,108`); `±2.96` is labelled `texturemap.inc:29` classification, never `hmapMin/Max`; `cameraModel` is explicitly excluded as a reflection matrix (packet §2 note). All §6 port changes fire only on a named capture.
- **FOW:** no cell size, combine operator, occlusion slope, explored lifetime, LOS domain, tint RGBA/threshold or knob default is asserted; `res=24/32/52` are `[D]` products of the closed `floor(20+4*vision)` law, and units of `res` remain `[U]`-a; `.inc` tree read-denial is recorded as a boundary, not bypassed (`DEC_U_fow_knobs.md §1 P8`). `FOWColor` is engine-default-only with zero writers and cannot ground a colour.
- **Tick:** candidate orders (i)/(ii)/(iii) are explicitly enumerated hypotheses, not donor facts; the current port index-order slice is labelled `PORT SUBSTITUTE`; native driver VA is `NONE RECOVERED — explicitly [U]`; cadences are `[O]` products of donor literals (`dmscript.global:1484-1487`).
- **Blend:** no `w(t)`, weight, second frame, `a3/a5/a6` semantic, `0,5` applicability or handler firing tick is asserted; `attack1 [99,124]`, `death [115,149]`, `cannon [301,337]`, `walk [1,20] → idle [64,113]`, `attack2before [630,663]/after [664,679]`, `death0 [564,628]` are `[O]` AAF rows from `DEC_U_aaf_art_audit.md §1`.
- **Save:** every byte pattern (`00 00 80 3F`, `5C 00 00 00`, `0/1/2`, `E9` vs `C3 A9`, 866 B span) is explicitly framed as an *expected value for a future owner run*, not an observed save byte; no `.sav` container is invented; v5 wire unchanged and additive-only.
- **Selection:** port `17.27°`, `0.1/4096`, `216/36/121.4`, `0.0001f @ 0x8f4dec`, `100/2/1.0f` are labelled port derivation / observed table constant, never donor fact; all numeric behaviour stays `[U]` behind T1–T9; surveyed marker coordinates are owner-placed at run time, not pinned.

All six packets keep owner-only/forbidden-to-worker discipline, `visual_parity_claim=false`, `parity.claim=NONE`/`false`, and a matched-seed donor-vs-port GPU A/B frame as a separate open obligation (X39).

## 5. Other consistency findings (label-only)

- **F3 — water packet omits the mandatory verdict block (real cross-packet inconsistency).** `PORT1TO1_water_owner_protocol.md` is the only one of the six packets whose frontmatter has **no** `parity_status`, `parity_claim`/`parity_claim_code`, `verdict` or `reviewer_line_verbatim` field, and whose body contains **neither** the verbatim reviewer line **nor** the string `RESULT IS NOT GOOD` (checked across all six packets and the index). The other five packets and `PORT1TO1_p0_packet_index.md:18,24` carry both. §8 of the water packet does state `parity.status="UNVERIFIED"`, `parity.claim=NONE`, so this is a presentation/label gap, not a substantive parity claim. **Label-only correction:** add to the water packet the verbatim reviewer line and a `verdict:` line of the governing form, e.g. `RESULT IS NOT GOOD — P0-1/1b/2 stays open; blocking_unverified non-empty; six-condition chain 0/6 CLOSED; no donor GPU A/B frame; no parity claim.` Add `parity_status: UNVERIFIED` / `parity_claim: NONE` for field parity with the other five.
- **F4 — disclosed line drift is accurate and must stay disclosed.** Water (`bind_reflection_map` now `water3d.gd:501` vs `DEC_U_water_fbo.md:343-353`; BUILTIN default `:168` vs source `:163`), Tick (`game.gd:5727-5787/6059-6088` vs `DEC_U_tick_order.md:5135-5195/5385-5455`; `data.gd:407`, `ai.gd:15,24,89-94` vs `DEC_U_ai_activation.md:69/73-76`), Blend (`anim3d.gd:1020-1041/1522-1527/986-1000/200` vs `DEC_U_blend_op.md:870-884/1224-1230/746-760/175`), FOW (`world3d_fog.gd:618-1295` vs 551/804-line snapshots) — each packet explicitly flags the drift and requires re-read at apply time. **Label-only correction:** retain the `VERIFIED`/`DEC-U` markers and the "re-read at apply time" instruction; do not treat either line set as authoritative for an edit.
- **F7 — minor body-line anchor variance (label-only).** `PORT1TO1_fow_owner_protocol.md:69` cites the capture-path window as `miscext.script:892-959`; `DEC_U_fog_territory.md:34` gives `_misc_ChangePlayer` as `miscext.script:894-959`. **Label-only correction:** cite `miscext.script:894-959` (or mark the range as approximate); the zero-FOW-call finding is unchanged.
- **No contradiction found** between the six packets and the index/plan on blocker ids (P0-1/1b/2, P0-3, P0-4, P0-5, P0-6, P0-8), owner-only classification, `RUNTIME-GPU`/`RUNTIME-HARNESS` settle classes, or the "advice-only" ordering in index §2. The plan lists all six packets and the index as DONE with task 181 (final owner review) still TODO.

## 6. Verdict (verbatim governing form)

`port=UNVERIFIED`; `parity.status = "UNVERIFIED"`; `parity.claim = NONE`; `visual_parity_claim = false`; `blocking_unverified` non-empty (P0-1…P0-8 plus `PORT1TO1_u_register_update.md` §2 tails); six-condition chain **0/6 CLOSED**; no donor GPU A/B frame exists. **`RESULT IS NOT GOOD`.**

All six packets are internally consistent with their cited source reports except for the label-only findings **F1–F7** above; two are substantive citation/presentation defects (**F2** non-attested evidence id, **F3** missing mandatory verdict block in the water packet) and the remainder are disclosed or benign variance. No packet supplies an approximation, promotes a `[U]` to `[O]`, weakens a zero-mismatch gate, or claims donor parity. This audit certifies **neither donor fidelity nor a gate pass**.

*End of PORT1TO1-P0-CONSISTENCY. Read-only; exactly one repository file written; no code/Godot/git/donor-execution; no approximations; parity UNVERIFIED; `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty.*
