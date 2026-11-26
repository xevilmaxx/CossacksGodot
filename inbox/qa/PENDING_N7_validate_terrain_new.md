---
fixture_id: N7
status: PENDING__FAIL_CLOSED__NOT_A_TOOL
created: 2026-11-26
author: I16 (QA-fixture implementation worker)
labels: [O, U, "NO_PARITY_CLAIM"]
parity_claim: false
---

# PENDING fixture — N7 `variant3d/tools/validate_terrain_new.py`

> **FAIL CLOSED.** This file is a documentation placeholder ONLY. It is **not** the
> N7 tool, is **not** executable Python, and must **never** be copied to
> `variant3d/tools/validate_terrain_new.py` or counted as a green static gate.
> The real path stays absent until its owner lands it. No value below is a
> gate result, a donor constant, or a baseline.

## 1. Exact expected path and consumer

| Item | Value |
|---|---|
| Real expected path (ABSENT) | `variant3d/tools/validate_terrain_new.py` |
| Ledger row | V11 N7 — `reports/V11_ownership_ledger.md:99` (owner **I13 / COORD**) |
| Canonical-name resolution | V11 CR6 — `reports/V11_ownership_ledger.md:146`: PLAN name wins over A03's `*_new.py` aliases; N7 folded into I13 |
| Consumer / invocation | V21 Stage A′-1 — `reports/V21_gate_register.md:163`: `python -m py_compile` on new tools, then **N7 `validate_terrain_new.py --strict`**; on FAIL → STOP |
| Tool contract | `reports/A03_asset_pipeline.md:279` (`--root variant3d/assets/terrain_new --manifest ... [--strict] [--emit inbox/terrain_new_validation.json]`, validation log only, no asset writes) and `:286` (each line a concrete assertion; `[U]` rows stay UNVERIFIED) |
| Named downstream consumer | `reports/X19_mask_decoder_gap.md:401`: COORD/F03 ask whether a live gate consumes legacy `manifest.water` (G1/G2); **N7 must use the corrected formula** if so |
| Earlier absence evidence | `reports/V28_code_review_r1.md:53` (N7 **ABSENT** at snapshot, "worker still running"); `reports/V21_gate_register.md:31,64,209,238`; `reports/HANDOFF.md:66` |
| I16 existence passes | 2 independent commands — PowerShell `Test-Path -LiteralPath` and Python `pathlib.Path.exists()` — both **False** (2026-11-26) |

## 2. Why PENDING (content cannot be honestly derived here)

- [O] N7 is a **tool**, not a data fixture: its body is a set of concrete assertions over the generated `variant3d/assets/terrain_new/**` tree (`A03:279,286`). That tree is itself absent (`reports/HANDOFF.md:66,159`), so no assertion can be executed or validated against real derived bytes.
- [O] The one substantive correction it must encode — the water-mask formula tied to G1/G2 — is still an **open question** (`X19:401`); inventing a formula would violate CHARTER §4 "No invention" (`CHARTER.md:83-84`).
- [O] I16 is forbidden from editing `variant3d/**` and from creating files outside the disjoint `inbox/qa/**` root; N7 is owned by I13/COORD (`V11:99`).

## 3. What COORD must do (not done by I16)

1. Have I13/COORD land the real file at `variant3d/tools/validate_terrain_new.py` with the A03 `:279,286` CLI and one cited assertion per check.
2. Resolve `X19:401` (legacy `manifest.water` G1/G2 formula) before encoding water assertions; any `[U]` row stays UNVERIFIED.
3. Run Stage A′-1 (`V21:163`) with `py_compile` and `--strict`; require `SCRIPT ERROR=0`, no parse errors, every derived value cited.
4. Only then delete this PENDING note and update `inbox/qa/README.md` with the real file's SHA-256. **No threshold is lowered and no assertion is deleted to obtain a green result.**

No donor value, gate result or parity claim is recorded here. Donor parity remains UNVERIFIED (`CHARTER.md:41,121-135`; `A05_qa_harness.md:293-295`).
