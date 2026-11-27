---
id: PORT1TO1-ACK-EVIDENCE-2026-11-26
title: "Owner-facing evidence packet for unacked leak tickets 575/582/585 — full 1:1 Cossacks 3 donor port"
role: WORKER ACK-EVIDENCE — READ-ONLY report; write EXACTLY ONE file; no code/Godot/git/runner-subcommand/donor-execution; NO ticket acked
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_ACK_EXECUTED
created: 2026-11-26
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_ack_evidence.md
files_created: [docs/terrain_swarm_2026-11-26/reports/PORT1TO1_ack_evidence.md]
files_edited: []
labels: [OBSERVED, DERIVED, UNVERIFIED, PRESERVE-ONLY, NO_PARITY_CLAIM, OWNER-ONLY]
parity_status: UNVERIFIED
parity_claim: false
parity_claim_code: NONE
verdict: "Ack records retirement, NOT a pass. No donor parity is implied by any ack or by this packet."
scope_guard: "Repo read-only glob/read/grep only. No source, shader, config, asset, test, fixture, manifest, result JSON, backup, queue file, app/ byte, git state, Godot process, runner subcommand (not even status), gate, capture, ROI metric or donor binary was created, modified or executed. Exactly one repository file written: this report. No ticket was acked."
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_gate_audit.md (:40-44, :53, :57-70, :170-179, :183-194)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_owner_decisions.md (:319, :322)
  - docs/terrain_swarm_2026-11-26/reports/V06_gate_remediation.md (:27, :46, :83-98, :E07 :46, :E09 :48)
  - docs/terrain_swarm_2026-11-26/reports/V42_gate_commands.md (:34-36, :115-136, :E02 :54, :E05 :57, :E06 :58)
  - variant3d/tools/godot_runner.py (:586-612, :644-647)
  - variant3d/.godot_queue/{counter,now_serving,status.json,jobs/,results/00000575_*/,results/00000582_*/,results/00000585_*/}
---

# PORT1TO1 — owner-facing ACK evidence packet (575 / 582 / 585)

> **Mandatory reviewer line (verbatim, `PORT1TO1_owner_decisions.md:15`):**
> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

> **This is a READ-ONLY evidence packet, not an ack, not a gate run and not a new claim.** It prepares the exact owner-facing material for the three leak tickets the gate audit found UNACKED. **No `ack` subcommand was executed by this worker.** Ack is owner-only (`PORT1TO1_owner_decisions.md:319/322`, `PORT1TO1_gate_audit.md:53/185`); no evidence of owner approval exists in the material read. The owner may choose to run the commands in §5; nothing here runs them.

---

## 0. Bottom line (do not quote selectively)

- **575, 582 and 585 remain UNACKED.** No on-disk evidence of an evidence-backed owner ack exists at this read: `variant3d/.godot_queue/status.json` contains no `acknowledged`/`ack_reason`/`ack_at` fields and no 575/582/585 history rows (the history has rolled to ticket ids `0…115`). This preserves the gate-audit verdict (`PORT1TO1_gate_audit.md:41/65/174-176`).
- **The historical result JSONs recorded by V06/V42 are MISSING at this read.** V06 E07 and V42 E05 read `00000575.json`, `00000582.json`, `00000585.json` as present; a recursive read-only search at this read finds none of the three. Because `ack` requires the result JSON to exist (`godot_runner.py:589-592`), the owner commands in §5 would currently return exit code 2 — **do not fabricate a result JSON to satisfy that prerequisite.**
- **`ack` records retirement, NOT a pass, and must NEVER be used to imply donor parity.** It writes bookkeeping fields only (`godot_runner.py:598-608`). It is not a parse proof, not a green selftest, not a green uitest, and not a gate result (`V42:125`; `PORT1TO1_gate_audit.md:81/185`).
- **Where evidence is missing, a fresh deterministic re-run with unique job ids and mtime-after-START acceptance is PREFERRED over ack.** Ack retires a diagnostic; it does not replace the fresh evidence that acceptance actually requires (§6).
- **No parity claim.** `parity.claim = NONE`, `parity.status = UNVERIFIED`, `visual_parity_claim = false`. Unit-test gates are NOT the acceptance path (`PORT1TO1_gate_audit.md:40/98`); the owner has so stated.

---

## 1. Scope, method and notation

- `[O]` literal file/line or read-only filesystem read; `[D]` deterministic consequence of cited lines; `[U]` unresolved.
- All telemetry below was obtained from read-only file reads (`glob`, `read`, `grep`) of `variant3d/.godot_queue/**`. **No runner subcommand — not even `status` — was invoked**; spool state comes from direct file reads, which is a read-only instrument, not a runner call.
- "Ack" refers only to the runner's historical leak-ticket acknowledgement (`godot_runner.py ack <ticket> --reason`, `:586-612/644-647`). Gate ids have no ack field; acking 575/582/585 is a *prerequisite* to GR-A00 CLEAN, not a gate result (`PORT1TO1_gate_audit.md:53`).

---

## 2. What each ticket was (read-only spool/status telemetry)

### 2.1 Current on-disk telemetry [O]

| Item | Observed at this read | Source |
|---|---|---|
| `variant3d/.godot_queue/counter` | `115` | read-only file read |
| `variant3d/.godot_queue/now_serving` | `115` | read-only file read |
| `variant3d/.godot_queue/jobs/` | `0` entries (no live pending job) | read-only directory read |
| `variant3d/.godot_queue/status.json` history | ticket ids `0…115`; **no** 575/582/585 rows; **no** `acknowledged`/`ack_reason`/`ack_at` fields anywhere | read-only `grep`/`read` |
| `results/00000575_bbclamptidy01-parse/` | present; contains `stdout.txt`, `stderr.txt` | read-only directory read |
| `results/00000582_terrainswarm-g1-selftest/` | present; **empty** (0 entries) | read-only directory read |
| `results/00000585_g04-uitest/` | present; contains `stdout.txt`, `stderr.txt` | read-only directory read |
| `00000575.json` / `00000582.json` / `00000585.json` | **do not resolve anywhere in the tree** (recursive read-only search) | read-only `glob` |
| `godot.lock` | not resolved as a file | read-only read |

**[I] Divergence:** the report-era state recorded by V06 (counter=607, history=500, three result JSONs present, three unacked rows) has moved on: the spool has been reused and its history rolled. **This divergence does not promote any gate or constitute an ack** (`PORT1TO1_gate_audit.md:70`).

### 2.2 Ticket identity and historical failure (from stderr + report-era evidence)

| Ticket | Id / label | What it was | Historical status (report-era [O]/[D]) | Direct telemetry at this read [O] |
|---|---|---|---|---|
| **575** | `bbclamptidy01-parse` | Diagnostic-only `--check-only` `game.gd` parse probe | `timed-out`; exit `-9`, run `302.44 s`, `SCRIPT ERROR 0` (`V06 E07`; `B_B_CLAMP_TIDY.md:148-149`). Owner retired the probe without re-submit. | `stderr.txt` = `[runner] KILLED after 300.0s (hard timeout)`. |
| **582** | `terrainswarm-g1-selftest` | Selftest probe that never ran Godot | `skipped`; run `0.0`, bogus error string `serving=2581` (`V06 E07`; `G12_runner_monitor.md:128-138`; `G04_gate_log.md:157-165`). Terminal bookkeeping remnant; no Godot ran and COORD cleared the stale job file. Superseded by ok jobs 568/569 (`MAP240_APPLY_01.md:100-109`). | result directory is **empty** (0 entries). |
| **585** | `g04-uitest` | UI/skirmish test probe | `timed-out` at 300 s; exit `-9`, `SCRIPT ERROR 0` (`V06 E07`; `G04_gate_log.md:183,197-211`); follow-up 587 hit the 120 s watchdog; the on-disk 17/17 predated both runs, so **no fresh PASS was claimed**. Superseded by ok job 569 at 240×240 (`MAP240_APPLY_01.md:101,108-109`). | `stderr.txt` ends with `[runner] KILLED after 300.0s (hard timeout)` (after benign image-load and PORT-APPROXIMATION warnings). |

**No ticket was a passing gate.** 575 is retired parse bookkeeping; 582 never ran; 585 was killed before a fresh result. The ok 568/569 jobs supersede them but **do not make these probes green** (`V06 E11`; `PORT1TO1_gate_audit.md:175-176`).

---

## 3. Result JSONs — present vs missing

| Ticket | Report-era (V06 E07 / V42 E05) | At this read [O] | Consequence for `ack` |
|---|---|---|---|
| 575 | `results/00000575.json` present: exit −9 / run 302.44 s / `timed-out` | **MISSING**; only the result *directory* (`stdout.txt`/`stderr.txt`) remains | `ack 575` would return exit code 2 ("no result for ticket 575") until a result JSON exists. **Do not fabricate one.** |
| 582 | `results/00000582.json` present: run 0.0 / `skipped` / `serving=2581` | **MISSING**; result directory empty | `ack 582` would return exit code 2. |
| 585 | `results/00000585.json` present: exit −9 / run 308.54 s / `timed-out` | **MISSING**; only the result *directory* remains | `ack 585` would return exit code 2. |

**[D]** `cmd_ack` builds the path as `RESULTS / f"{ticket:08d}.json"` and returns 2 when it does not exist (`godot_runner.py:589-592`). The owner-facing commands in §5 are therefore **conditional**: they are the exact syntax the owner may use *if* the prerequisite is satisfied; on the tree as read, the prerequisite is absent and the honest record is a provenance gap, not a green result.

---

## 4. V06 / V42 reason-string requirements

### 4.1 Mechanical requirements (source-verified, `godot_runner.py:586-612,644-647`) [O]

- Syntax: `python variant3d\tools\godot_runner.py ack <TICKET_INT> --reason "<evidence-backed text>"`.
- `ticket` is a **positional int**; `--reason` is **required** (argparse, `:645-646`).
- A result JSON must already exist (`:589-592`), else exit code 2.
- On success the call writes `acknowledged=true`, `ack_reason`, `ack_at` into **both** `results\<ticket:08d>.json` and the matching `status.json` history row (`:598-608`); verify that triple if the owner runs it.
- `ack` has **no** `--id` and **no** `--ignore-history`, and performs **no deletion**. `--ignore-history` belongs to `assert_clean.py` and suppresses the failure set — forbidden (`V42:78/125`; `V06:85`).
- **Also forbidden to obtain CLEAN:** result-JSON deletion, status hand-editing, `reset --yes`, `doctor`, `cancel`, `unwedge`, re-running until green, lowering a threshold, deleting an assertion, or fabricating a green JSON (`PORT1TO1_gate_audit.md:179`; `V42:125/357`).

### 4.2 Wording requirements (V06 §4.1 / V42 §4.2) [O]

The reason must be **evidence-backed** — it cites specific `file:line` provenance — and must **explicitly state retirement rather than a pass**:

- 575: must state it was a retired diagnostic probe that timed out, and **"NOT a passing gate and NOT a parse proof"**.
- 582: must state it was a terminal skipped bookkeeping remnant that never ran Godot, and **"NOT a green selftest run"**.
- 585: must state it was killed at 300 s with no fresh PASS claimed, and **"NOT a green uitest"**.
- All three begin `COORD policy ack 2026-11-26:` and carry the source citations from V06 E10/E11. The canonical owner-facing strings are reproduced verbatim in §5 (V42 §4.2; V06 §4.1 differs only in shortened path prefixes and the tail clause of 575 — "fresh gates are re-run in 4.2" vs "re-run below").

---

## 5. Precise commands the OWNER may choose to run

> **OWNER-ONLY. NOT EXECUTED BY THIS WORKER. NO OWNER APPROVAL EVIDENCE EXISTS IN THE MATERIAL READ.** These are the exact V42 §4.2 / V06 §4.1 commands, reproduced verbatim. Run from repo root with `python`; PowerShell separator `;` (never `&&`). Each is **conditional on the result-JSON prerequisite of §3**; as read, that prerequisite is missing, so each would return exit code 2 — **do not fabricate a result JSON.** Verify the write triple (`acknowledged`/`ack_reason`/`ack_at`) in both the result JSON and `status.json` history if run.

```powershell
python variant3d\tools\godot_runner.py ack 575 --reason "COORD policy ack 2026-11-26: diagnostic-only --check-only game.gd parse probe timed out at 300s (exit -9, run 302.44s, SCRIPT ERROR 0; docs/coord_swarm_2026-11-25/reports/B_B_CLAMP_TIDY.md:148-149). Owner retired the probe without re-submit. This records retirement, NOT a passing gate and NOT a parse proof; fresh gates are re-run below."
python variant3d\tools\godot_runner.py ack 582 --reason "COORD policy ack 2026-11-26: terminal skipped bookkeeping remnant, run=0.0, bogus error serving=2581 (docs/terrain_swarm_2026-11-25/reports/G12_runner_monitor.md:128-138; G04_gate_log.md:157-165); no Godot ran and COORD cleared the stale job file. Superseded by ok jobs 568/569 (MAP240_APPLY_01.md:100-109). Records retirement only, NOT a green selftest run."
python variant3d\tools\godot_runner.py ack 585 --reason "COORD policy ack 2026-11-26: g04-uitest hung in setup and was killed at 300s (exit -9, SCRIPT ERROR 0; G04_gate_log.md:183,197-211); follow-up 587 hit the 120s watchdog and the on-disk 17/17 predated both runs, so no fresh PASS was claimed. Superseded by ok job 569 at 240x240 (MAP240_APPLY_01.md:101,108-109). Records retirement, NOT a green uitest."
```

**Optional owner verification after the three acks (not an ack; plain gate only):**
```powershell
python variant3d\tools\godot_runner.py status
python variant3d\tools\assert_clean.py --json
```
Accept only `verdict=CLEAN`, exit 0, `reasons=[]`, `checks.history.enabled=true`, `checks.history.acknowledged>=3`, `checks.history.failures=[]` (`V42:136`; `V06:98`). **STOP** if any item is unmet. No `--ignore-history`. A CLEAN assertion is a machine-clean precondition, **not** donor fidelity and **not** a gate pass.

---

## 6. Explicit warnings and the preferred alternative

1. **Ack records retirement, NOT a pass.** `ack` writes `acknowledged`/`ack_reason`/`ack_at` bookkeeping only (`godot_runner.py:598-608`). It never proves a parse, a 29/29 selftest, a 17/17 uitest, a gate, or a donor match (`V42:125`; `PORT1TO1_gate_audit.md:81/185`).
2. **An ack must NEVER be used to imply donor parity.** Parity stays `parity.claim = NONE`, `parity.status = UNVERIFIED`, `visual_parity_claim = false`. The only route to a parity claim is a genuine matched donor GPU A/B frame, which does not exist and which no worker may produce (`PORT1TO1_gate_audit.md:43/154/202`). Ack of 575/582/585 changes none of that.
3. **Prefix strings are not permission.** The `COORD policy ack` wording in §5 is the prescribed evidence-backed *form*, but ack is **owner-only** and this worker has no evidence of owner approval. No ticket was acked here.
4. **Preferred over ack where evidence is missing:** a **fresh deterministic re-run with unique job ids and mtime-after-START acceptance**. Per `PORT1TO1_gate_audit.md:186` and `V42:91/254/304`: one job at a time via `godot_runner.py run --id <unique>`; call `status` after each; accept only result envelope `status=ok`, `exit=0`, `SCRIPT ERROR=0`, `smallmap_capture.py scan-stderr script_error_lines=0`, and **result mtime strictly after that job's START**. Never re-submit a pending job, never re-run until green, never lower a threshold, never delete an assertion, never fabricate a green JSON. Freshness alone does not close a gate and does not confer parity (`PORT1TO1_gate_audit.md:42/91/98`).
5. **Unit-test gates are NOT the acceptance path; parity stays UNVERIFIED** (owner directive, `PORT1TO1_gate_audit.md:40/98`). `RESULT IS NOT GOOD` while `blocking_unverified` is non-empty (`PORT1TO1_gate_audit.md:44/203`).
6. **No approximation and no parity claim.** `inbox/qa/**` PENDING, stale-gate history and no D1/D3 ruling remain as recorded (`PORT1TO1_gate_audit.md:41`). This packet only prepares evidence; it rules nothing.

---

## 7. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | 575/582/585 remain unacked; no ack fields or rows in current `status.json` | [O] read-only `status.json` reads; [D] `owner_decisions.md:322`, gate audit :41/65 |
| 2 | Report-era result JSONs for 575/582/585 are present in V06/V42 but missing at this read | [O] recursive read-only search; [D] `godot_runner.py:589-592` (ack returns 2) |
| 3 | Ticket identities: 575 timed-out parse probe, 582 skipped never-ran remnant, 585 timed-out uitest | [O] result-directory stderr; [D] V06 E07, V42 E05, gate audit :174-176 |
| 4 | Ack is owner-only, requires an evidence-backed `--reason`, writes a bookkeeping triple, and cannot be used as a pass or parity proof | [O] `godot_runner.py:586-612/644-647`; [D] `V42:125`, `owner_decisions.md:319` |
| 5 | Exact owner-optional commands reproduce V42 §4.2 / V06 §4.1 verbatim | [O] cited reports |
| 6 | Fresh deterministic re-run with unique ids + mtime-after-START is preferred over ack where evidence is missing | [D] gate audit :186, V42 :91/254/304 |
| 7 | Parity UNVERIFIED; no donor GPU A/B frame; no parity claim | [D] gate audit :43/154/202 |
| 8 | This worker wrote exactly one file; no ack, runner subcommand, Godot, git, donor or code action occurred | [O] scope |

---

*End of PORT1TO1_ack_evidence. Read-only; exactly one repository file written. No ticket acked; no owner approval claimed. Ack records retirement, NOT a pass, and must never imply donor parity. Fresh deterministic re-run with unique job ids and mtime-after-START acceptance is preferred where evidence is missing. No approximation, no parity claim.*
