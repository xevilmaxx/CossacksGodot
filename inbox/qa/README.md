---
root: inbox/qa
created: 2026-11-26
author: I16 (QA-fixture implementation worker, DONOR-FIRST terrain swarm)
status: FIXTURE_INDEX__PENDING__FAIL_CLOSED
labels: [O, D, U, "PORT APPROXIMATION", "NO_PARITY_CLAIM"]
parity_claim: false
scope: "New disjoint root only. No existing file edited; no variant3d/** or app/** edit; no Godot/runner job; no git operation; no donor access."
---

# `inbox/qa/**` — QA fixture index and file-scoped SHA-256 manifest

## 0. Fail-closed convention (read first)

Every file in this root created by I16 is either an **index** or a clearly
labelled **`PENDING` placeholder**. A `PENDING` placeholder:

- is **not** the real artifact and is **not** consumable at the real path;
- carries **no gate result, no donor constant, no baseline, no pixel score** and
  no threshold change;
- leaves the real expected path **absent** on disk, so a consumer that looks for
  it fails (exit non-zero / `UNVERIFIED`) instead of silently reading a fake green;
- is deleted only by the owning worker after the real artifact lands, with the
  real artifact's hash entered in §3 below.

The real artifacts stay absent: `inbox/qa/terrain_qa_report.json` (N18) and
`inbox/qa/captures/` (N19) were **not** created. Do **not** rename any `.PENDING`
file to a real path. Donor parity is **UNVERIFIED** — no donor GPU A/B frame exists
(`CHARTER.md:41,121-135`; `A05_qa_harness.md:293-295`).

## 1. Existence audit — two independent passes (2026-11-26)

Pass 1 = PowerShell `Test-Path -LiteralPath`; pass 2 = Python
`pathlib.Path(...).exists()`. Both instruments returned the same value for every
row. This is the "multiple passes before declaring missing" rule
(`CHARTER.md:85-93`; `V13_stale_qa_refs.md:11,21`).

| Ledger id | Exact expected path | Consumer (file:line) | Pass 1 / Pass 2 | Authority at I16 read | I16 action |
|---|---|---|---|---|---|
| **N7** | `variant3d/tools/validate_terrain_new.py` | `reports/V21_gate_register.md:163` (Stage A′-1 `--strict`); `reports/A03_asset_pipeline.md:279,286` (CLI + assertions); `reports/X19_mask_decoder_gap.md:401` (water-formula consumer) | **False / False — MISSING** | V11 `:99` owner I13/COORD; V28 `:53` ABSENT; V21 `:31,64,209,238` | Created `PENDING_N7_validate_terrain_new.md` (§2.1) |
| **N14** | `variant3d/scripts/terrain_donor_world.gd` | `variant3d/scripts/world3d.gd:118` (`TERRAIN_DONOR_SCRIPT`); `variant3d/tests/t_terrain_donor.gd:36` (`MODULE_WORLD`); V21 GR-A21 `:93` | **True / True — PRESENT** | V11 `:24,106` (I11-COMPOSER); V28 `:60` PRESENT | None. V21's absence finding is **stale** for this file; no placeholder created |
| **N15** | `variant3d/tests/t_terrain_donor.gd` | `variant3d/tools/terrain_qa_harness.py:180,188` (rollback); V21 GR-A05/A06/A11 `:77-83`; V11 `:107` (I12) | **True / True — PRESENT** | V28 `:61` PRESENT; grep of `variant3d/tests/manifest.json` finds **no** `t_terrain_donor` entry (I12 append LAST still pending, V11 `:80,159,179`) | None. Present but **unregistered**; recorded, not fabricated |
| **N16** | `variant3d/tools/terrain_qa_harness.py` | `variant3d/tools/terrain_qa_harness.py:51,382-399,625-986,1124-1175` (self-consumer); V21 GR-A01/A20 `:73,92`, §7.2 `:131`; A05 `:321-338,337` | **True / True — PRESENT** | V11 `:25,108` (I13/COORD); V28 `:62` PRESENT (MINOR: tautological self-checks F-04 `:156`) | None. Present; its `--check` PASS is **not** a gate result (V28 `:176`) |
| **N17** | `docs/terrain_swarm_2026-11-26/spec/terrain_qa_spec.json` | `variant3d/tools/terrain_qa_harness.py:51` (`SPEC_RELPATH`), `:389-399` (`validate_spec`), `:865` (inputs); V21 §7.2 `:131` promotion; A05 `:323,352-354` | **True / True — PRESENT** | V11 `:109`; V28 `:63` PRESENT; file itself `schema_only:true`, all 12 bands `value:null`, `promotion.signed:false` (`:2-21,23-120`) | None. Present but **unpopulated** — no band may be promoted to red |
| **N18** | `inbox/qa/terrain_qa_report.json` | V11 `:110` (path pin, `terrain_qa_report/1`); V21 `:156,177` (D-6 COORD sign-off); V28 `:147` (COORD supplies `--out`); harness `:1133,1160-1163` writes it | **False / False — MISSING** | Generated, I13/COORD | Created `terrain_qa_report.json.PENDING` (§2.2) — deliberately **not** at the real path |
| **N19** | `inbox/qa/captures/` | V11 `:111`; V21 GR-C01…C11 `:113-123`, §7.3 `:133-135`, D-4/D-6 `:175,177`; V06 `:152-182` (frozen baselines) | **False / False — MISSING** | Generated GPU captures, owner-only | Created `PENDING_N19_captures.md` (§2.3) — directory itself **not** created |

**Correction carried forward:** V21 `:31,64,209,238` reported
"N7/N14/N15/N16/N17 and `inbox/qa/**` absent". At this I16 read, **N14, N15,
N16 and N17 are present**; V21's snapshot is stale on those four (V28 `:60-63`
already records their landing). Only **N7** and **`inbox/qa/**` (N18/N19)** are
still absent. Creating PENDING stubs for the four present files would be
misleading and was therefore refused. No parity claim follows from any row.

### Out-of-scope stale fixtures (identified, not created)

`V13_stale_qa_refs.md:18-19,49-58` identifies `terrainmesh_props.json`
(`t_relief_props_qa.gd:30`), four absent anim sheets (`t_sheet_load.gd:8,9,10,12`)
and legacy `app/shots/terrain3d_m06.{png,json,seammask.png}`. These are real
stale references, but their real paths are under `variant3d/**` / `app/**`,
which this ticket forbids editing, and their owners are named by V13 `:76-81`.
I16 creates **no** fixture for them and does **not** lower any assertion
(`V21:96,123` keeps GR-A24 a hard FAIL / blind spot until its owner repoints it).

## 2. Fixture files created by I16 (all fail-closed)

1. **`PENDING_N7_validate_terrain_new.md`** — N7 placeholder. Real tool path
   remains absent. Citations: V11 `:99,146`; V21 `:163`; A03 `:279,286`; X19
   `:401`; V28 `:53`. Cannot be authored honestly here: the generated
   `terrain_new/**` tree it validates is absent (`HANDOFF.md:66`) and the
   water-formula question is OPEN. Owner I13/COORD must land the real tool.
2. **`terrain_qa_report.json.PENDING`** — N18 placeholder with a non-consumable
   schema sentinel `terrain_qa_report/PENDING__NOT_A_GATE_RESULT`, empty gate set
   and `parity.status=UNVERIFIED` / `parity.claim=NONE`. Schema grounded in
   A05 `:240-295` and harness `:47,625-986,1166`. The real
   `terrain_qa_report.json` is written by `terrain_qa_harness.py --out`
   (`:1133,1160-1163`) only at V21 D-6 after COORD sign-off.
3. **`PENDING_N19_captures.md`** — N19 placeholder. No directory, PNG, baseline,
   crop or metric created. Capture plan grounded in V06 `:152-182` and V21
   `:113-123,133-135`. Must be produced by COORD with windowed, one-at-a-time
   runner jobs after the gates; class C remains owner-only.

## 3. File-scoped SHA-256 manifest

Computed from working-tree bytes, 2026-11-26. Two instruments agree:
PowerShell `Get-FileHash -Algorithm SHA256 -LiteralPath` and Python
`hashlib.sha256(p.read_bytes()).hexdigest()`.

| File (repo-relative) | Bytes | SHA-256 (uppercase) | Status |
|---|---:|---|---|
| `inbox/qa/PENDING_N7_validate_terrain_new.md` | 3508 | `8AE08BCC69ECCABDB63279F4EBA0511C2717583522356BFB7CADD662BFE73928` | PENDING / fail-closed |
| `inbox/qa/terrain_qa_report.json.PENDING` | 2256 | `8A7703E54861503677FE91EC76D7068233F90FE0CF74BEB33D154605E30E2E9D` | PENDING / fail-closed |
| `inbox/qa/PENDING_N19_captures.md` | 3617 | `0A16F7D51914B655F97DF57C7960FE0327891E3CF8550AEEE8168136F3A7D6FD` | PENDING / fail-closed |

`README.md` itself is excluded from its own manifest (self-reference); its
SHA-256 is recorded in `reports/I16_qa_fixtures.md` §5. The byte counts above
will be re-verified there; any edit to a placeholder requires this table to be
regenerated, not hand-edited.

## 4. Invariants honoured

- No existing file edited; no threshold lowered; no assertion deleted.
- No fake green JSON, no fabricated baseline, no invented donor value or band.
- No Godot process, runner subcommand, git operation, donor access, `variant3d/**`
  or `app/**` edit by I16.
- Every `PENDING` file fails closed; the real paths stay absent.
- No donor-parity claim. Donor parity remains UNVERIFIED.

## 5. Handoff

COORD: confirm the N14/N15/N16/N17 presence correction; assign N7 to I13;
run A′→D under V21 §6; write the real N18 and N19 from actual gate/capture
evidence; then remove the matching `PENDING` files and update §3 with the real
hashes. Until then, any "gates green" claim is UNVERIFIED for today's tree
(`V21:31,238`; `V06:24-28`).

*End of `inbox/qa` fixture index. PENDING means not run, not green, not parity.*
