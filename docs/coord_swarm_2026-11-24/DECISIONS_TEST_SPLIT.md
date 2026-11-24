# Decision — how to split the big selftest (owner directive 2026-11-24)

## Problem

Owner: "split big tests in smaller tests sets logically meaningful and relatively fast
to execute". Recon: `app/selftest.json` is one hardcoded 29-step monolith
(`selftest.gd:35-503`); `--self-test <path>` is output-only (`main.gd:811-814,1498-1511`).
T1 partitioned all 29 steps into 8 coherent subsets with only 3 hard state deps.
T2 supplied the minimal mechanism (`--self-only` / `run_only`, cloned from the
`--ui-only` precedent). T3 measured the wall-time constraint.

## Measured constraints (T3)

- Full selftest: **88.82 s wall** (runner job 1102), 29 steps, 391.8 sim-seconds.
- Fixed startup (one map-gen + setup): **~43.6 s** MEASURED proxy (job 1192); spread
  11–92 s across configs.
- Per-step wall times: **UNKNOWN** (no instrumentation). Ranking is ESTIMATE only.
- 8 separate processes ⇒ ~285–405 s total (3–5× slower than monolith) if all are run.
  **<30 s per subset is impossible** without shared-process baseline restore.
- Two irreducible soaks: `act` (80 sim-s) and `mine` (90 sim-s). `farm_cap` (≤240 ticks)
  and `nav_detour` (map scan + ≤120 ticks) are also slow.

## Coordinator decision (D-SPLIT-1, 2026-11-24)

1. **Keep the 29-step monolith as the canonical gate.** `app/selftest.json` and the
   standard `--self-test app/selftest.json` command remain authoritative 29/29.
   Subsets are *targeted diagnostics*, never a gate substitute.
2. **Mechanism:** additive `--self-only <group>` flag + `C3SelfTest.run_only(group)`,
   mirroring `uitest.gd:64-102` / `main.gd:819-822,1517`. No called symbols renamed;
   `run()` delegates to `run_only("")` so the gate command is byte-stable.
3. **Groups:** use T1's 8 coherent groups as named aliases (`core_movement`,
   `economy_gather`, `economy_trade_tech`, `buildings`, `combat_ranged`,
   `formations_morale`, `capture`, `generator_state_ui`). Keep the three hard deps
   (`squad→formation`, `wall→shell`, `formation_bonus→replenish`) inside their group.
   Preserve source order inside each group.
4. **Result path:** subsets write `app/tests/results/selftest_<group>.json` — NEVER
   `app/selftest.json` (gate-artifact overwrite hazard, T2 hazard 1).
5. **No weakening / no hiding:** every assertion verbatim; union of groups = 29 steps;
   the currently failing `resow` step stays failing until its truth fix lands (D1).
   `formation`'s conditional append needs a presence check so it cannot silently
   vanish from a gate count.
6. **Add per-step `wall_ms` instrumentation (one-line bracket per step)** so T3's
   ESTIMATEs become MEASURED on the next run. Report shape gains a field; external
   readers only use `passed`/`steps`, so this is backward-compatible.
7. **Two soaks** (`act`, `mine`) get a documented `slow` lane note; never trim their
   `_sim` windows to make a number look better.
8. **Defer** T3 Scenario B (single-process baseline snapshot restore) — it is the only
   route to <30 s subsets, but it needs serialize/deserialize state-parity proof
   (res_nodes hits, stats, blocked, squads, objectives, Data.AI_ENABLED) and a visual/
   determinism gate. Record as a follow-up ticket, not part of this minimal diff.

## Acceptance for the implementation ticket

- `run()` with no flag still produces a 29-step report and the same pass predicates.
- Each `--self-only <group>` run produces only that group's steps, correct count
  (3/4/3/4/5/5/2/3), correct `passed`, and writes to `app/tests/results/`.
- Unknown group name appends a failing step listing valid names (uitest precedent).
- `python app/tools/godot_runner.py status` shows no orphan; clean gate stays CLEAN.
- Final settled full gate: selftest 29/29 (after the resow truth fix) + uitest 17/17.
