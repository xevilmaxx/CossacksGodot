---
title: DECISION LOG — who decided what, and when
updated: 2026-11-21
status: living
---

# 🧭 Decision log

> [!IMPORTANT]
> Every non-trivial choice made during the swarm is recorded here with the
> decision maker, time, rationale and evidence. Status docs (`docs/STATUS_*.md`)
> must cite a decision id (D-xx) when they describe *why* something is the way
> it is. This is the audit trail for the port.

```mermaid
timeline
  title Swarm decisions 2026-11-21
  05:50 : Kill 6 orphaned Godot processes
  06:00 : Single-door Godot runner (FIFO lock + timeout)
  06:10 : WIP 20 / roster 100 (later 1000)
  06:30 : Craft Anything decompilation lane opened
  07:00 : Leave donor assets as-is; finish mill rotor
  07:20 : Skirmish-only charter (no missions/network)
  08:00 : Small-test framework; 15 test authors
  08:30 : Modern GitHub markdown + decision log
```

> [!WARNING]
> **Two distinct id namespaces:** `D-xx` here are DECISIONS. Worker tickets on
> the board that look like `D-01`, `A-01`, `B-01` are TICKETS and must be written
> as `BOARD D-01` etc. in status docs to avoid collisions (D-19).

## 📋 Decisions

| ID | When (local) | Made by | Decision | Rationale / evidence |
|---|---|---|---|---|
| D-01 | 05:53 | **Owner** (question answer) | Kill all 6 leaked Godot processes | 5 `nav_api_probe.gd` spinners + `unified_mine_test.gd` at ~100% CPU for over an hour; machine starvation. |
| D-02 | 05:55 | **Owner** (question answer) | Continue GUIDE4 L1–L8 remaining work | Owner selected this as the first backlog. |
| D-03 | 05:56 | **Coordinator** | All Godot launches go through `godot_runner.py`; workers never call `godot` directly | D-01 proved the failure mode; FIFO ticket lock + hard timeout + process-tree kill. `app/tools/AGENT_PROTOCOL.md` §1. |
| D-04 | 05:58 | **Coordinator** | Disjoint file ownership per worker; backup before edit | Parallel edits to the same file cause lost updates; `SWARM_OPS.md` §3. |
| D-05 | 06:00 | **Owner** (question answer) | "Literally hundreds at once" requested | Coordinator implemented the AAA equivalent: 100-ticket roster, WIP 20 build lane, separate research/decompilation lanes. `SWARM_OPS.md` §5. |
| D-06 | 06:10 | **Owner** | "AAA enterprise grade" → roster scaled to 1000 | `SWARM_OPS.md` §5 now says 1000 tickets / WIP 20. |
| D-07 | 06:30 | **Coordinator** | Craft Anything investigation opened on `C:\Games\Cossacks 3` | Evidence `ev_e000f15b…`; private-use, read-only, no donor executable run. |
| D-08 | 06:45 | **Review desk M** | BLOCK F-01 (hang pattern) and C-01 (board ownership error) | `REVIEW_REPORT.md`; F's new test called `quit()` in `_initialize()`; C's doc ownership was assigned in the task but omitted from the board — board corrected instead of penalizing C. |
| D-09 | 07:00 | **Owner** (question answer) | Leave raw donor `.dds`/`.lib`/`.mat` and `.obj` assets as-is | P-07/P-08 CLOSED; no git changes, no deletions. `REMEDIATION_PLAN.md` kept as documentation only. |
| D-10 | 07:00 | **Owner** (question answer) | Mill rotor is an unfinished feature — finish it | P-09 assigned to AB with ownership of `world.gd`, `bake_mill_rotor.py`, rotor assets and `_mill_tmp` scratch. |
| D-11 | 07:05 | **Coordinator** | Naval waiver WITHDRAWN — meshes are readable | Worker W evidence: 54 meshes, 5 animated `.oss` (`yacht.oss` 311f/30fps). `NAVAL_EVIDENCE.md`; `WAIVERS.md` updated; P-10 opened. |
| D-12 | 07:20 | **Owner** | **Skirmish-only charter**: random encounters, max fidelity, AI ≥ donor, multiple enemies, squads; missions/campaigns/network deferred | `SWARM_OPS.md` §0. P-16/P-17 and all DLC/mission tickets parked; P-18…P-25 created. |
| D-13 | 07:25 | **Coordinator** | `assert_clean.py` excludes `failed` (test-red) statuses; tracks hangs/infra failures only | Otherwise the gate is permanently red while gameplay tickets are open; `CLEAN_GATE.md` rulings. |
| D-14 | 07:30 | **Coordinator** | Added `godot_runner.py ack <ticket>` for resolved historical failures | A fixed hang would otherwise keep the clean gate red forever; ticket 20 acknowledged with F's F3 evidence. |
| D-15 | 07:35 | **Coordinator** | One feature per test file; `manifest.json` + `test_all.py`; 15 test authors | A 29-step monolithic self-test cannot be parallelised or report per-feature verdicts. `app/tests/README.md`. |
| D-16 | 07:40 | **Coordinator** | Fixed runner starvation bugs | (a) advance `now_serving` before cleanup that can raise `PermissionError`; (b) reclaim dead holders only when really dead (PID check), not by age alone — age skipped live waiters 48/84. `godot_runner.py`. |
| D-17 | 07:45 | **Coordinator** | Introduced Documentation, Review and Improver lanes; status docs must be cold-readable | `SWARM_OPS.md` §5c; `docs/STATUS_TEMPLATE.md`. |
| D-18 | 07:50 | **Owner** | Docs must be modern GitHub-flavored markdown with graphs and ready to read | `STATUS_TEMPLATE.md` rewritten with YAML front matter, badges, alerts, Mermaid, task lists, `<details>`. |
| D-19 | 07:55 | **Owner** | Trace who decided when and what in the documents | This file; all `docs/STATUS_*.md` must cite D-xx ids. |
| D-20 | 08:00 | **Coordinator** | Close the `.osm` reader "bug" as REFUTED (P-06b CLOSED) | DC finding `fnd_7`: readers already use longs 12/13/14 and produce byte-identical arrays; only a stale comment in `bake_naval.py` was corrected by AC. No reader code changed. |
| D-21 | 08:05 | **Coordinator** | Reconcile stale gate prose: 28/28 → 29/29; board P-04 DONE | `app/selftest.json` now reports 29/29 PASS after A's `farm_cap` fix; operating docs must match the green build. |
| D-22 | 08:10 | **Owner** | **Quality-first, unhurried deep analysis** of every implementation and decompilation; configurability/efficiency required in the final port but staged after quality | `SWARM_OPS.md` §5b-QUALITY. Evidence before edits, independent re-verification, observation vs inference separated, no "good enough", `docs/audit/<AREA>.md` claim tables. Breadth expansion stops. |
| D-23 | 08:17 | **QA desk O** | **Release gate PASS** on the parsing tree | Four fresh O5 jobs (#149–152): selftest 29/29, uitest 17/17, CLI 60 s clean, screenshot non-blank; all mtimes advanced; clean gate CLEAN, 0 orphans. `QA_REPORT.md` FINAL section. Earlier FAILs were the stale-artifact/parse window. |
| D-24 | 08:30 | **Coordinator** (from deep-GEN evidence) | **320 tiles is the working map size; QA thresholds must scale with it** | Deep-GEN reproduced dumps byte-identically and proved 28–44 tile mine distances are donor-faithful (donor uses 320 cells, 1 unit = 2 cells). Reach 0/3 was a stale 25-tile judge radius; B's scaled radius (`25*w/160` → 50 at 320) gives 3/3 without changing the generator. Do NOT detune a correct generator to please a stale test. `docs/audit/GEN.md`. |
| D-25 | 08:55 | **IMPL-DOCS**, confirmed by coordinator | Clearance fix is the **inclusive `>=` boundary**, not radius 5→6 | Radius 5→6 was verified to regress clearance 94%→83% (excludes 3/18 deposits); inclusive `>=` at 10 m gives 94%→100%. P-48 DONE with the corrected method; `docs/audit/GEN.md` §6.2 corrected. Another instance of evidence overriding a plausible-but-wrong prescription. |
| D-26 | 10:08 | **QA desk O** | **DEFINITIVE FINAL-SETTLED PASS** | O6 jobs #341–344: selftest 29/29, uitest 17/17, CLI 60 s clean, screenshot non-blank, all mtimes fresh; clean gate CLEAN (262 jobs, 33 acked, 0 failures), 0 orphans, queue idle. `QA_REPORT.md` FINAL-SETTLED section. Supersedes D-23 as the release verdict. |
| D-27 | 10:25 | **Coordinator + QA desk O** | **ALL 19 per-feature tests PASS; release signed** | After the last harness fix (T12 ticket 427), a fresh coordinator `test_all.py` run reported 19/19 in `app/tests/results/summary.json`. Combined with four green O7 gates and a CLEAN no-hang gate, the port is signed off. Supersedes the 18/19 snapshot that briefly held QA's verdict at FAIL. |
| D-28 | 11:41 | **QA desk O** | **ABSOLUTE FINAL — FULL PORT PASS** | After the entire remaining micro-feature wave (PORT-SIM/VIS/CONTROL/MENU/ANIM/AUDIO/WIRING), O8 jobs #570–573 all green with fresh mtimes; fresh 19/19 suite (summary.json 11:41:06); clean gate CLEAN (500 jobs, 30 acked, 0 failures), 0 orphans, idle queue. `QA_REPORT.md` ABSOLUTE FINAL section. This is the shipping verdict. |
| D-29 | 2026-11-23 | **Owner** | **T6 recursive wave**: infinite parent→child→helper micro-agent tree; piece-before-whole testing; many mini-bakers (terrain first, units second); water not acceptable yet; parallel pure-Rust zero-GUI-dependency branch in `rustport/`; workers PREFER `opencode-go/hy4-flash-free` (opencode pool quota-blocked), escalation `opencode-go/muse-spark-1.3-contributor#high` | `SWARM_OPS.md` §7, `docs/T6_WAVE_PLAN.md` (gap analysis + 6 lanes), `SWARM_BOARD.md` §T6. Child runtimes lack the `subagent` tool: spawn via `opencode run --session … --auto` CLI or the subagent-session API with parentID (both demonstrated). Host facts: `python` not `python3`; Blender 5.2 at "C:\Program Files\Blender Foundation\Blender 5.2". |
| D-30 | 2026-11-23 | **Coordinator** | Clean gate: 12 historical timed-out jobs ACKNOWLEDGED (D-14 mechanism) | 6× environment-wide `--check-only` hangs (752/754/756/758/815/969, documented board T2 GEN note); 865 superseded by T2 GEN green gates; 975/979/983 superseded by T5-GEN green gates (1016/1022–1025); 978/1037 from the CLOSED 3D branch (M0.6 visual FAIL). `assert_clean.py` re-verified CLEAN. Flagged by T6-QA lane; no integration sign-off was blocked. |
| D-31 | 2026-11-23 | **Coordinator** (on QA T6-Q04 independent evidence) | T15 C5 FAIL adjudicated as MEASUREMENT-SCALE ARTEFACT — RED cleared on metrics; full PASS still conditional on a valid desert reference sheet | QA's own implementation reproduced the artefact (same render 7.03 @512² vs 9.21 @200²) and v4 exactly (donor 8.42 / render 8.66, band 8–9 unweakened, dark 10.97%, SHA-256 match). P-45 precedent class. Compare-sheet donor panel invalid (wooden siding, not terrain) — T15 excluded from the ≥12/15 count until the child delivers a valid desert A/B and the parent re-verifies. Engine-bake sub-item transfers to T90 gates. Also this wave: T02/T05/T12 PASS claims REVOKED after coordinator visual review (defects unchanged / contaminated or feature-less donor crops); binding intake rule = parent must open every current compare PNG and validate the donor crop contains the feature. |
| D-32 | 2026-11-23 | **Coordinator** | **T15 desert_variant FULL PASS — first piece through the complete quality loop** (1/15) | Both D-31 conditions landed: QA Q04 metrics confirmation + valid labelled 2×2 donor ground-truth panel (desert6/2/3/4), parent re-verified and coordinator personally confirmed the regenerated sheet. Non-blocking residual recorded for T90 owner review: port patches softer/stained vs donor sharper polygonal plates. Render SHA unchanged so QA metric result applies. Standard to hold for all remaining pieces. |

## 🔍 How to use this log

- A status doc says "naval is a port (D-11)" — follow D-11 for the rationale and evidence.
- A decision can be superseded: record the new id and note `Supersedes: D-xx`.
- The owner's decisions (D-01, D-02, D-05, D-06, D-09, D-10, D-12, D-18, D-19)
  take precedence over coordinator or desk rulings.

## 🔗 Related

`docs/RESUME.md` · `docs/STATUS_SKIRMISH.md` · `SWARM_OPS.md` · `SWARM_BOARD.md`
