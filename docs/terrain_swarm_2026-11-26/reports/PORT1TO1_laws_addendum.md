# PORT1TO1 LAWS ADDENDUM — delta to owner_packet2 (read-only, 2026-11-27)

- id: PORT1TO1-LAWS-ADDENDUM-2026-11-27
- worker: LAWS-ADDENDUM (read-only subagent, full 1:1 Cossacks 3 donor port)
- parent: `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_packet2.md` (not edited; this file only adds)
- delta-source: `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_review_laws.md` §10 items 1–8 (items NOT in `PORT1TO1_p0_final_status.md` §1/§2 or owner_packet2 §1–§4)
- scope_guard: "READ-ONLY. No code/Godot/git/donor execution. Exactly one file written: this addendum."
- parity: UNVERIFIED. parity_claim: NONE. parity_claim_code: NONE. visual_parity_claim: false.
- chain: 0/6. P0: nine OPEN. blocking_unverified: non-empty.
- verdict: "RESULT IS NOT GOOD while blocking_unverified non-empty; no parity claim."
- reviewer_line_verbatim: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."

## 0. Standing rule (applies to every item below)

- None of the items below closes a P0 row or changes parity. Static facts narrow only; only an owner-run zero-mismatch capture/harness on the stated battery can retire its P0 row.
- Any item needing donor runtime (GPU/debugger/headless harness/paired-save capture) is flagged OWNER-ONLY; workers forbidden.
- Classification is exactly one of: WORKER-EXECUTABLE-STATIC / OWNER-GPU-RUNTIME / OWNER-DECISION.

## 1. Upgrade time/cost/gate/preempt/dispatch/loss batteries (§10 item 1 — highest priority)

- evidence: `PORT1TO1_review_laws.md:88`; law `DEC_U_b12_peace.md` §§1–5 (`country.script:619-636` frames→`×0.03125`; pack `time=500`; six overwrites `:1173-1564`; AI surcharge `unit.script:5774-5778`; charge `:5792-5806`; cancel `:5837-5890`; gate `:6055-6074`; preempt `:4304-4328`; divisor `miscext.script:65-106`; cadence `building.inc/nothing.inc:128-136,438-492`); battery `DEC_U_b12_peace.md` §8 B12-TIME/COST/GATE/PREEMPT/DISP/LOSS; port ABSENT ("no file found" for `country.upgrade[].time`/six-price/`inprogress`/`bindividual`/slot-0 preempt/`delta=deltatime/upgTime`).
- classification: OWNER-GPU-RUNTIME (owner-only; fixed-seed Nothing-tick progress trace, 3-run).
- next action: Owner adopts §8 battery as new standalone P0-tail run sheet (per-row seconds, six-price charge-once, gate, slot-0 preempt, divisor trace).
- zero-mismatch / acceptance: 3 runs, fixed seed, progress trace byte-identical to §8 prediction, 0 mismatches. Static transcription alone does NOT accept.
- P0 effect: narrows only — does NOT close any of the nine P0 rows; parity unchanged (UNVERIFIED).

## 2. Peace-chain batteries (§10 item 2 — highest priority §10 item 1–2)

- evidence: `PORT1TO1_review_laws.md:89`; law `DEC_U_b12_peace.md` §7 (enum `dmscript.global:1055-1066`; seconds fn `misc.script:4262-4281` ×60; lobby `showcustomgame.inc:890-1150`; wire `miscext2.script:2375/2635`; init `dogenerate.inc:2054-2065`; expiry `progress.inc:658-695` strict-`>`); port guard-only `variant3d/scripts/game.gd:9022` (`Data.PEACE_TIME` single float); battery §8 B12-PEACE NOT in owner packet.
- classification: OWNER-GPU-RUNTIME (owner-only; tag dump + expiry boundary capture).
- next action: Owner runs B12-PEACE battery: tag dump `0,1,11,2…`; seconds `{600,900,2700,14400}`; `gbool_peacemode` false iff index 0; strict-`>` expiry with `ptborder` destroy + `WriteFreeList`/`WritePeaceTime` + minimap refresh.
- zero-mismatch / acceptance: tag/seconds/mode/expiry all match prediction, 0 mismatches across repeats. Guard shape alone does NOT accept.
- P0 effect: narrows only — does NOT close P0-5/row 6 (victory) or any P0 row; parity unchanged.

## 3. Team-win U-E/U-N/U-C batteries (§10 item 3)

- evidence: `PORT1TO1_review_laws.md:90`; law `DEC_U_endgame_team_deep.md` §§3–4/§6 (every-survivor loop `miscext2.script:3810-3818`; `winnerteam` local-only §2.5; disjoint write sets §4.3; stamp precedence W5 `<>win` skip vs W8/W9/W11 unconditional overwrite, `==0.0` time gate); port `game.gd:8811-8973` loop-shape only; nine batteries U-E1 same-frame `win_tick>=lose_tick`, U-E3 shared-team same-tick, U-E4 leaver `lose→win` flip, U-E6 independence, U-C1 capture-no-stamp NOT in owner packet.
- classification: OWNER-GPU-RUNTIME (owner-only; nine fixed-seed 2v2/FFA captures).
- next action: Owner runs all nine U-E/U-N/U-C batteries on the stated fixed seeds and records stamp/time-gate outcomes.
- zero-mismatch / acceptance: all nine outcomes match §6 predictions, 0 mismatches. Loop-shape match does NOT accept.
- P0 effect: narrows only — does NOT close P0-5/row 6; parity unchanged.

## 4. AI U-B11 batteries (§10 item 4)

- evidence: `PORT1TO1_review_laws.md:91`; law `DEC_U_b11_ai.md` §§1–4 (`Progress→ProgressAI→EconomicAI+WarAI` dispatch `progressai.inc:6-14`; think `2.4 s` `dmscript.global:1486` + stagger `id*0.25` + anti-collision `squad.script:756-785`; resbalance bands `30/60/85` `dmscript.global:503-506`; `OfficerWaitTime=20` zero consumers; Bitva `8 s`/art `3 s`/sail `5 s`/holdmode ramp/seed-wheat gates); port `ai.gd` + `game.gd:475-485` `_TICK_*` labels only; five §6 batteries NOT in owner packet.
- classification: OWNER-GPU-RUNTIME (owner-only; cadence + sandbox + dispatch coverage).
- next action: Owner runs §6 U-B11-1…U-B11-5 (2.4 s + stagger growth events; reqlevel-vs-upglevel per band; officer+36 sandbox; battle-timing sandbox; 37-site dispatch coverage).
- zero-mismatch / acceptance: event counts/timings match §6 predictions, 0 mismatches. Cadence-label presence does NOT accept.
- P0 effect: narrows only — does NOT close P0-4/row 5 (tick O1) or any P0 row; parity unchanged.

## 5. Save E-T1 routing + R1h sub-slots; Q1/E1/E-T1b-c gaps (§10 items 5–8)

- 5a. Save E-T1/R1h: evidence `PORT1TO1_review_laws.md:92`; `DEC_U_save_deep.md` §§1–3 (F1–F24 zero-hits; `WriteFile` edge at `sub_4051d8`); `DEC_U_save_trg_deep.md` §§1–4 (`orders[i].info.trg` runtime handle; `ObjWriter` loop commented `:807-823,:860-862`); port `game.gd:9344-9455` v4/v5 PORT EXTENSION (missing `tileblock`/`mine_mask`/`pattern_stamps`/`nav_version`/RNG+gen_rng/projectiles/corpses/cooldowns/acq). Classification: OWNER-GPU-RUNTIME (owner-only paired-save S5 run sheet, incl. E-T1 trg-routing + R1h profile-store identity sub-slots). Next action: owner folds E-T1/R1h explicitly into S5 sheet (R1a word `5C 00 00 00`; R1b `00 00 80 3F`/`01`; R1d adjacent-word delta; R1g trailer bit-compare). Acceptance: exactly the predicted word diverges at the predicted offset, all else byte-identical, 3 repeats + identical-state re-save control. P0 effect: narrows only — does NOT close P0-6/row 7.
- 5b. Q1 upgrade-queue audit (ABSENT): evidence `PORT1TO1_review_laws.md:93`; `DEC_U_skirmish.md` §3-Q1; port `game.gd:5455-5566` + `hud.gd:968-981` unbacked (`BUILD_QUEUE_LIMIT=10`/`MAX_BUILDERS_SENT=8`/batch 5/100/endless). Classification: WORKER-EXECUTABLE-STATIC (mechanical `player.script` producer cost-time/cap re-read; no donor runtime). Next action: worker re-reads exact Q1 lines and cites them; owner decides battery. Acceptance: cited donor lines transcribed, no value wired. P0 effect: narrows only — no P0 row touched.
- 5c. E1 delivery-radius split (ABSENT): evidence `PORT1TO1_review_laws.md:94`; `DEC_U_skirmish.md` §2.11-E1 (global 3 `dmscript.global:210` vs `resourceDropRadiusSqr=0.5` `unit.script:9704-9705` vs fisher `4*4` `unit.script:12032-12033`); port `DELIVERY_RADIUS_M=3` single-valued. Classification: WORKER-EXECUTABLE-STATIC (three-callsite text branch). Next action: worker cites the three call sites; no capture needed beyond citation. Acceptance: three lines cited, no value wired. P0 effect: narrows only.
- 5d. E-T1b/T1c trg width/placement (ABSENT): evidence `PORT1TO1_review_laws.md:95`; `DEC_U_save_deep.md` §3 R1f + `DEC_U_save_tobj.md` (TObj/TProj tail widths, nested-transform placement); no port field, no packet sub-slot. Classification: WORKER-EXECUTABLE-STATIC to name + OWNER-GPU-RUNTIME to capture (capture stays inside S5 scope). Next action: worker names widths/placement statically; owner captures within S5. Acceptance: named statically; S5 zero-mismatch still required for any closure. P0 effect: narrows only — does NOT close P0-6/row 7.

## 6. Explicit non-closure statement

- None of §1–§5 above closes a P0 row or changes parity. Static facts (5b/5c/5d-static) narrow only. Runtime batteries (§1/§2/§3/§4/§5a/§5d-capture) are owner-only and retire their target row only on their own stated zero-mismatch capture/harness.
- Parity remains UNVERIFIED; chain 0/6; nine P0 OPEN; blocking_unverified non-empty (P0-3, P0-4, P0-5, P0-6, P0-7, P0-8 + §10 B12/peace-team/AI/Q1/E1 tails). RESULT IS NOT GOOD. No parity claim.

*End of LAWS-ADDENDUM. Addendum to owner_packet2; that packet not edited. Exactly one file written; no code/Godot/git/donor execution; parity UNVERIFIED.*
