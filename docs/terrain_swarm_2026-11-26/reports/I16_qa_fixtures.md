---
id: I16
ticket: "TERRAIN-SWARM-2026-11-26 / I16 — implementation ticket for MISSING QA FIXTURES"
agent: "I16 (implementation subagent, worker 16 of the 30-agent DONOR-FIRST terrain swarm)"
owner_file: docs/terrain_swarm_2026-11-26/reports/I16_qa_fixtures.md
created: 2026-11-26
status: DELIVERED__FAIL_CLOSED__NO_GODOT__NO_RUNNER__NO_GIT__NO_DONOR_ACCESS__NO_PARITY_CLAIM
labels: [O, D, I, U, "PORT APPROXIMATION", NO_PARITY_CLAIM]
parity_claim: false
files_created:
  - docs/terrain_swarm_2026-11-26/reports/I16_qa_fixtures.md
  - inbox/qa/README.md
  - inbox/qa/PENDING_N7_validate_terrain_new.md
  - inbox/qa/terrain_qa_report.json.PENDING
  - inbox/qa/PENDING_N19_captures.md
files_edited: []
scope_guard: "New disjoint roots only. No existing file edited; no variant3d/** or app/** edit; no Godot process, runner subcommand, git operation or donor access."
governing_sources:
  - docs/terrain_swarm_2026-11-26/CHARTER.md
  - docs/terrain_swarm_2026-11-26/SWARM_BOARD.md
  - docs/terrain_swarm_2026-11-26/reports/V11_ownership_ledger.md
  - docs/terrain_swarm_2026-11-26/reports/V21_gate_register.md
  - docs/terrain_swarm_2026-11-26/reports/V06_gate_remediation.md
  - docs/terrain_swarm_2026-11-26/reports/V13_stale_qa_refs.md
  - docs/terrain_swarm_2026-11-26/reports/V28_code_review_r1.md
  - docs/terrain_swarm_2026-11-26/reports/A05_qa_harness.md
  - variant3d/tools/AGENT_PROTOCOL.md
---

# I16 — missing QA fixtures: exact audit and fail-closed placeholders

## 1. Executive summary

1. **[O] V21's absence finding is only partly still true.** V21 `:31,64,209,238`
   reported `N7/N14/N15/N16/N17` + `inbox/qa/**` absent. At this I16 read,
   **N14, N15, N16 and N17 are PRESENT** (two independent existence commands;
   corroborated by V28 `:60-63`), so that part of V21 is a **stale snapshot**.
   Only **N7** (`variant3d/tools/validate_terrain_new.py`) and **`inbox/qa/**`**
   (N18 report, N19 captures) are still absent. No PENDING stub was fabricated
   for the four present files — that would be misleading. No parity claim.
2. **[O] Three fail-closed placeholders were created, all under the new disjoint
   `inbox/qa/**` root:** `PENDING_N7_validate_terrain_new.md`,
   `terrain_qa_report.json.PENDING`, `PENDING_N19_captures.md`, plus the index
   `inbox/qa/README.md` carrying a file-scoped SHA-256 manifest (§5).
3. **[O] The real expected paths remain absent.** `inbox/qa/terrain_qa_report.json`
   and `inbox/qa/captures/` were deliberately **not** created; the placeholders
   use non-consumable names and non-schema sentinels, so any consumer looking
   for the real artifact fails closed (non-zero / `UNVERIFIED`) rather than
   reading a fake green value.
4. **[D] N18 and N19 genuinely require work I16 cannot do.** A real report is
   written only by `terrain_qa_harness.py --out` (`terrain_qa_harness.py:1133,
   1160-1163`) from real dump inputs at V21 D-6 (`:177`); real captures need
   owner-only windowed GPU runner jobs (V21 §7.3 `:133-135`; V06 `:152-182`).
   Both are therefore PENDING and explicitly assigned to COORD after the gates.
5. **[O] No threshold lowered, no assertion deleted, no baseline fabricated, no
   donor value invented.** `terrain_qa_spec.json` is `schema_only:true` with all
   12 bands `value:null` and `promotion.signed:false` (`:2-21,23-120`); I16 did
   not touch it. Donor parity stays UNVERIFIED (`CHARTER.md:41,121-135`).

## 2. Method and multiple-pass verification

Owner directive (`CHARTER.md:85-93`): never declare a path missing after a single
instrument; never skip a contradiction. V13 `:11,21` independently shows that
87 raw "missing" candidates collapsed to 3 real groups after five passes — a
second command is mandatory.

| Pass | Instrument | Result | Effect |
|---|---|---|---|
| P1 | PowerShell `Test-Path -LiteralPath` over all 7 ledger paths + `inbox/qa`, `inbox/qa/README.md`, N18, N19 | N7/queue paths **False**; N14/N15/N16/N17 **True**; all `inbox/qa` paths **False** | Initial split |
| P2 | Python `pathlib.Path(...).exists()` on the same set | **Identical** results for every path | Missing call accepted, not a resolver artefact |
| P3 | `grep` for `inbox/qa`, `terrain_qa_harness`, `validate_terrain_new`, `t_terrain_donor`, `terrain_donor_world` across reports/tools | 13 + 145 literal hits; V21/V11/V28/HANDOFF pin paths and owners; harness self-consumes N17 | Exact consumers and file:line established (§3) |
| P4 | Read `terrain_qa_spec.json:1-140`, `A05:236-360`, harness `:380-399,1116-1175` | Spec is schema-only with null bands; harness refuses `--policy red` without signed spec; harness writes real N18 from `--out` | Content-derivation decision: PENDING for generated artifacts, none for present files |
| P5 | `Get-FileHash -Algorithm SHA256` **and** Python `hashlib.sha256` on every created file | Both instruments agree (§5); real paths re-checked `False` after writes | Manifest trusted; fail-closed property preserved |

**[O] No anomaly was silently skipped.** The one real contradiction — V21 says
all five absent, V28 and P2 say four present — is resolved by "point-in-time
snapshot" (V28 `:20,60-63` is later than V21 `:23-31`) and recorded in §1/§4.

## 3. Fixture-by-fixture audit (exact path, consumer, grounded content or PENDING)

| Id | Exact expected path | Consumer (file:line) | Status (P1/P2) | Content decision |
|---|---|---|---|---|
| **N7** | `variant3d/tools/validate_terrain_new.py` | V21 Stage A′-1 `:163` (`--strict`); A03 `:279,286` (CLI + one assertion per line); X19 `:401` (corrected `manifest.water` formula) | **MISSING** | **PENDING** — `inbox/qa/PENDING_N7_validate_terrain_new.md`. Real tool is I13/COORD-owned (V11 `:99`, CR6 `:146`); the `terrain_new/**` tree it validates is absent (`HANDOFF.md:66`) and the water formula is an OPEN question (`X19:401`). Inventing assertions would break CHARTER §4 `:83-84`. |
| **N14** | `variant3d/scripts/terrain_donor_world.gd` | `world3d.gd:118` (`const TERRAIN_DONOR_SCRIPT := "res://scripts/terrain_donor_world.gd"`); `t_terrain_donor.gd:36` (`MODULE_WORLD`); V21 GR-A21 `:93`; V11 `:24,106` (I11-COMPOSER) | **PRESENT** | No fixture. V28 `:60` PRESENT; V21's absence is stale. Any PENDING stub here would misrepresent a landed composer. |
| **N15** | `variant3d/tests/t_terrain_donor.gd` | harness `:180,188` (rollback deletes it); V21 GR-A05/A06/A11 `:77-83`; V11 `:107` (I12) | **PRESENT** | No fixture. V28 `:61` PRESENT; grep of `variant3d/tests/manifest.json` finds **no** `t_terrain_donor` entry, so I12's append-LAST (V11 `:80,159,179`) is still pending — recorded as a fact, not fixed by I16. |
| **N16** | `variant3d/tools/terrain_qa_harness.py` | harness `:51,382-399,625-986,1124-1175` (self-consumer); V21 GR-A01/A20 `:73,92` and §7.2 `:131`; A05 `:321-338,337` | **PRESENT** | No fixture. V28 `:62` PRESENT with MINOR F-04 `:156` (tautological self-checks); V28 `:176` says its PASS lines are deliberately UNVERIFIED — I16 adds no green claim. |
| **N17** | `docs/terrain_swarm_2026-11-26/spec/terrain_qa_spec.json` | harness `:51` (`SPEC_RELPATH`), `:389-399` (`validate_spec` refuses red), `:865` (inputs); V21 §7.2 `:131`; A05 `:323,352-354` | **PRESENT** | No fixture. V28 `:63` PRESENT; file is `schema_only:true`, all bands `value:null`, `promotion.signed:false` (`:2-21,23-120`). No band populated or promoted by I16. |
| **N18** | `inbox/qa/terrain_qa_report.json` | V11 `:110` (path pin, `terrain_qa_report/1`); V21 `:156,177` (D-6 sign-off); V28 `:147` (COORD supplies `--out`); harness `:1133,1160-1163` | **MISSING** | **PENDING** — `inbox/qa/terrain_qa_report.json.PENDING`. Schema grounded in A05 `:240-295` and harness `:47,625-986,1166`; emitted with sentinel schema `terrain_qa_report/PENDING__NOT_A_GATE_RESULT`, empty gate set, `parity.status=UNVERIFIED`, `parity.claim=NONE`. No numeric band, gate verdict or donor value. |
| **N19** | `inbox/qa/captures/` | V11 `:111`; V21 GR-C01…C11 `:113-123`, §7.3 `:133-135`, D-4/D-6 `:175,177`; V06 `:152-182` | **MISSING** | **PENDING** — `inbox/qa/PENDING_N19_captures.md`. Directory itself not created. Real captures require windowed one-at-a-time GPU jobs (AGENT_PROTOCOL `:14-34`; CHARTER `:80-82`), frozen baselines outside the repo (V06 `:176-182`) and a second-agent visual read (V21 `:115`) — all COORD-only. |

### Out-of-scope stale fixtures (identified, deliberately not created)

V13 `:18-19,49-58` found `terrainmesh_props.json` (`t_relief_props_qa.gd:30`,
hard FAIL), four absent anim PNGs (`t_sheet_load.gd:8,9,10,12`) and three legacy
`app/shots/terrain3d_m06*` paths (`terrain3d_shot.py:25-26,120`). Their real paths
live under `variant3d/**` / `app/**`, which this ticket forbids editing; their
remediation owners are named at V13 `:76-81`. I16 creates **no** fixture for them
and preserves GR-A24 as a hard FAIL/blind spot (V21 `:96,123`). V13's Pillow
cp313-vs-3.14 finding (`:22,98-107`) is likewise recorded, not "fixed".

## 4. Correction to the V21 gate register (informational; no edit made)

V21 `EV18 :64` and U4 `:209` state that N7/N14/N15/N16/N17 and `inbox/qa/**`
are all absent. Two later, independent reads contradict this for four rows:
I16 P1/P2 and V28 `:60-63` (N14/N15/N16/N17 PRESENT). The authoritative split at
this read is:

- **Present:** N14, N15, N16, N17 (N17 schema-only, unpopulated).
- **Absent:** N7, `inbox/qa/**` (N18 report, N19 captures).
- **Not created by I16 by design:** stubs for the four present files; real N18/N19.

This is a point-in-time correction only; it makes no gate green and no parity
claim. Per V28 `:65-68` the present files still carry reviewed MINOR findings and
must be re-reviewed by their owners; per V21 `:131` no class-B band may be
promoted until V17 READY + N17 populated + COORD sign-off.

## 5. File-scoped SHA-256 manifest

Computed from working-tree bytes after all writes. Two instruments agree:
PowerShell `Get-FileHash -Algorithm SHA256 -LiteralPath` and Python
`hashlib.sha256(p.read_bytes()).hexdigest()` (I16 P5). The same table is mirrored
in `inbox/qa/README.md` §3.

| File (repo-relative) | Bytes | SHA-256 (uppercase) | Status |
|---|---:|---|---|
| `docs/terrain_swarm_2026-11-26/reports/I16_qa_fixtures.md` | _self_ | _self-reference excluded; recompute after any edit_ | Report |
| `inbox/qa/README.md` | 8599 | `96F1D43C6146A5F936A6B5AF67081C24F28227BFE954FDEED3C8025A0F47C9F2` | Index / manifest |
| `inbox/qa/PENDING_N7_validate_terrain_new.md` | 3508 | `8AE08BCC69ECCABDB63279F4EBA0511C2717583522356BFB7CADD662BFE73928` | PENDING / fail-closed |
| `inbox/qa/terrain_qa_report.json.PENDING` | 2256 | `8A7703E54861503677FE91EC76D7068233F90FE0CF74BEB33D154605E30E2E9D` | PENDING / fail-closed |
| `inbox/qa/PENDING_N19_captures.md` | 3617 | `0A16F7D51914B655F97DF57C7960FE0327891E3CF8550AEEE8168136F3A7D6FD` | PENDING / fail-closed |

Post-write re-check (P5): `inbox/qa/terrain_qa_report.json` = **False**,
`inbox/qa/captures` = **False**. The placeholders cannot be mistaken for the
real artifacts.

## 6. PENDING register — which fixtures remain open and who owns them

| Fixture | Remaining PENDING item | Owner / gate | What settles it |
|---|---|---|---|
| N7 | Real `variant3d/tools/validate_terrain_new.py` absent | I13 / COORD (V11 `:99`); V21 Stage A′-1 `:163` | Land tool with A03 `:279,286` assertions; resolve X19 `:401` water formula; `--strict` clean; then delete PENDING note |
| N18 | Real `inbox/qa/terrain_qa_report.json` absent | I13 / COORD (V11 `:110`); V21 D-6 `:177` | Harness `--out` from real dump pair + seed manifest (`:1128-1144`); `blocking_unverified=[]`, no hard FAIL, no parity wording; then delete `.PENDING` |
| N19 | `inbox/qa/captures/` absent; no windowed 1280×720 frame, no frozen 240²/320² baseline, no R1–R6 card | COORD only (V21 §7.3 `:133-135`); V06 `:152-182` | Admissible captures G0-a…e, SHA of PNG/overlay/config/seed/camera, second-agent read; class C stays UNVERIFIED without a donor A/B frame. **Must be produced by COORD after the gates — I16 invents none.** |
| Adjacent (not I16 scope) | GR-A24 stale `t_relief_props_qa.gd:30`; four anim sheets; three M0.6 shot paths | Named owners at V13 `:76-81` | Repoint/skip with recorded reasons; never lower `SCALE_WANT`/`BBOX_TOL` or delete assertions |
| Environment (not I16 scope) | Pillow cp313 natives under Python 3.14 | COORD/environment (V13 `:81,98-107`) | Pin system Pillow 12.1.1 or rebuild natives; record version beside every metric |

## 7. Attestation

- Exactly 5 new files created (§frontmatter); **zero** existing files edited.
- No Godot process, no `godot_runner.py` subcommand (not even `status`), no capture,
  no A/B frame, no git operation, no donor path opened and no donor binary run.
- No `variant3d/**` or `app/**` byte changed; no threshold lowered; no assertion
  deleted; no result JSON, PNG or baseline fabricated; no donor constant invented.
- Every claim is `[O]` file/read, `[D]` consequence of cited lines, or `[U]`
  explicitly unresolved; **no donor-parity claim** — parity remains UNVERIFIED
  and PORT APPROXIMATION (`CHARTER.md:41,121-135`; `V21:34`).

## 8. Five-line summary

1. **[O]** Created `docs/terrain_swarm_2026-11-26/reports/I16_qa_fixtures.md` and `inbox/qa/README.md` (index + file-scoped SHA-256 manifest); no existing file edited.
2. **[O]** Created `inbox/qa/PENDING_N7_validate_terrain_new.md` — N7 still missing (`variant3d/tools/validate_terrain_new.py`); real tool is I13/COORD-owned, water formula OPEN (X19:401).
3. **[O]** Created `inbox/qa/terrain_qa_report.json.PENDING` — N18 stays PENDING; harness `--out` must produce the real `inbox/qa/terrain_qa_report.json` at V21 D-6; sentinel schema, empty gates, no fake green.
4. **[O]** Created `inbox/qa/PENDING_N19_captures.md` — `inbox/qa/captures/` stays PENDING and absent; GPU captures must be produced by COORD after the gates (V06:152-182; V21 §7.3).
5. **[D]** N14/N15/N16/N17 are PRESENT (2 passes; V28:60-63), so V21's all-five-absent finding is stale for them; no placeholder created there — remaining PENDING: N7, N18, N19; no parity claim.

*End of I16 QA-fixture report. Fail closed; no parity claim.*
