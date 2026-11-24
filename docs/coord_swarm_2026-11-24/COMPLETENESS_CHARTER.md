# COMPLETENESS_CHARTER — is the 3D variant actually complete? (2026-11-24)

Goal: an evidence-based answer to "check completeness of port of 3d variant",
not another feature list. Measure coverage, verify claims in CURRENT source,
and separate DONE / APPROXIMATION / MISSING / UNVERIFIED.

## Hard rules
- READ-ONLY audit. No source, asset, config, test or git edits. Do not launch
  Godot jobs (the queue is expensive and results already exist); read existing
  result JSONs and report files instead.
- One report per agent under `docs/coord_swarm_2026-11-24/reports/`, exactly
  the assigned file.
- Every claim needs `path:line` or a job id / result file / report citation.
  Treat earlier claims as UNDONE until verified in current source.
- No visual parity claim without a donor A/B (none exists).

## Dimensions
- COMP-01 `COMPLETENESS_01_tests.md` — test/gate completeness: manifest 31 tests, which pass/stale/fail, 29 selftest + 17 uitest step parity, t_camera3d known failure.
- COMP-02 `COMPLETENESS_02_vs_2d.md` — feature coverage vs the 2D `app/` port: go through sim/HUD/input/AI/audio/economy/formations/capture/naval and mark implemented in 3D / 2D-only / stub.
- COMP-03 `COMPLETENESS_03_donor_fidelity.md` — donor-fidelity completeness using DEEPDEC/TERRAIN2/AUDIT3D reports: which donor subsystems are translated, approximated, or missing.
- COMP-04 `COMPLETENESS_04_runtime_stability.md` — windowed/runtime error sweep: unbranched 2D calls, typed params, known error history, current source scan for remaining hazards.
- COMP-05 `COMPLETENESS_05_shipping.md` — shipping hygiene: big-file/LFS status, .import coverage, asset sizes, runner spool state, docs accuracy.
- COMP-06 `COMPLETENESS_06_verdict.md` — synthesis scorecard + prioritized remaining work; may only read other COMP reports that exist at read time (no polling).
