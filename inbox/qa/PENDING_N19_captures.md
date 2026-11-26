---
fixture_id: N19
status: PENDING__FAIL_CLOSED__NO_CAPTURE
created: 2026-11-26
author: I16 (QA-fixture implementation worker)
labels: [O, U, "NO_PARITY_CLAIM"]
parity_claim: false
---

# PENDING fixture — N19 `inbox/qa/captures/`

> **FAIL CLOSED.** I16 did **not** create `inbox/qa/captures/`. The directory and
> every PNG/baseline inside it stay absent. This note is a documentation
> placeholder outside that directory; it is not an image, a baseline, a metric,
> or a capture verdict. No pixel value, crop, score or donor comparison is
> recorded here.

## 1. Exact expected path and consumer

| Item | Value |
|---|---|
| Real expected path (ABSENT) | `inbox/qa/captures/` (generated 240²/320² captures) |
| Ledger row | V11 N19 — `reports/V11_ownership_ledger.md:111` (owner **I13 / COORD**, generated) |
| Gate consumers | V21 GR-C01…C11 — `reports/V21_gate_register.md:113-123`; class C is **owner-only** (`:133-135`), no analysis worker submits a runner job |
| Sign-off consumer | V21 D-4 / D-6 — `reports/V21_gate_register.md:175,177`; V11 §7 Stage D — `:180`; `reports/HANDOFF.md:66,108` |
| Exact capture CLI (PLANNED, not run) | `reports/V06_gate_remediation.md:154-182`: two windowed runs (no `--headless`), `--config` overlays 240²/320², `--screenshot-frames 10`, `--seed 20261113`, `--timeout 600` after the second `--`; freeze `*_baseline.png` **outside the repo** and record SHA-256 of PNG/overlay/config/seed/camera |
| Admissibility | `reports/V21_gate_register.md:113` G0-a…e: 1280×720 non-blank, `full_width_dark_rows=0`, `camera_current=true`, `world_parent=Screenshot3DViewport`, `script_error_lines=0`, identical fractional ROI; `reports/V06_gate_remediation.md:174` |
| I16 existence passes | 2 independent commands — PowerShell `Test-Path -LiteralPath` and Python `pathlib.Path.exists()` — both **False** (2026-11-26) |

## 2. Why PENDING (requires a GPU capture I16 cannot produce)

- [O] A real capture needs a **windowed Godot runner job**, one at a time with a unique `--id` (`AGENT_PROTOCOL.md:14-34`; `CHARTER.md:80-82`). I16 runs **no** Godot/runner job by ticket.
- [O] There is **no donor GPU A/B frame**; every donor-parity verdict is capped at UNVERIFIED (`CHARTER.md:41,121-135`; V21 GR-C08 `:120`). No donor screenshot may be invented or reused as a baseline.
- [O] V06 `:28,152-182` confirms no fresh 240²/320² baseline existed at that read; freezing a "baseline" from a stale or headless 800×600 frame is explicitly forbidden (`:174`).
- [O] GR-C11 remains **Blocked** because the relief-props atom's stale path is unregistered and unrepointed (`V21:96,123`; `reports/V13_stale_qa_refs.md:18,51`). No ON/OFF fixture exists to capture.

## 3. What COORD must do (not done by I16)

1. Complete gates A′→D-3 (`V21:158-174`) and obtain `assert_clean` CLEAN by acking 575/582/585 with evidence-backed reasons (`V06:83-98`); never `--ignore-history`.
2. Create `inbox/qa/captures/` **only** from admissible windowed captures (V06 `:163-181`), record SHA-256 of each PNG/overlay/config and the exact seed/size/camera keys outside the repo.
3. Run the second-agent R1–R6 visual card and the V15 tier-2 metric fields separately (`V21:115,117`); a green metric never overrides a visible artifact.
4. Keep `parity.status=UNVERIFIED` unless a genuine matched-seed donor GPU A/B frame is produced; C04/C08/C09 stay UNVERIFIED (`V21:116,120-121`).
5. Only then delete this PENDING note and add the real capture hashes to `inbox/qa/README.md`.

No donor value, pixel score, gate result or parity claim is recorded here. Donor parity remains UNVERIFIED.
