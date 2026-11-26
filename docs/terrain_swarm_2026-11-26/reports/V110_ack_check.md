---
id: V110
swarm: TERRAIN-SWARM-2026-11-26
title: "V110 — final pre-ack verification: 575/582/585 ack state, ack syntax, predicted assert_clean output"
agent: "V110 (worker in the 30-agent DONOR-FIRST terrain swarm 2026-11-26; reporting to COORD)"
role: "READ-ONLY — no ack, no runner subcommand, no assert_clean run, no Godot, no gate result, no parity claim; exactly one report"
owner_file: docs/terrain_swarm_2026-11-26/reports/V110_ack_check.md
status: READ_ONLY_VERIFICATION__NO_RUNNER_SUBCOMMAND__NO_GATE_RUN__NO_GODOT__NO_PARITY_CLAIM
created: 2026-11-26
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "PORT APPROXIMATION / port-internal bookkeeping only. No donor binary, donor byte, donor GPU frame, Godot process, gate run or new result JSON was produced by V110. Nothing here certifies donor fidelity or a gate PASS; donor parity stays UNVERIFIED (CHARTER.md:43-44,121-135)."
principle: "[O] literal file:line or read-only filesystem read · [D] deterministic consequence of cited source · [I] recommendation with caveat · [U] unresolved. Two independent source reads were performed for every cited source claim (§1)."
governing_sources:
  - docs/terrain_swarm_2026-11-26/CHARTER.md
  - docs/terrain_swarm_2026-11-26/reports/V104_ack_reasons.md
  - docs/terrain_swarm_2026-11-26/reports/V42_gate_commands.md
  - variant3d/tools/godot_runner.py
  - variant3d/tools/assert_clean.py
  - variant3d/.godot_queue/status.json
---

# V110 — final pre-ack verification (COORD runs; V110 ran nothing)

## 0. Headline finding — the premise changed mid-verification

**[O] The task premise "575/582/585 are STILL unacked" was TRUE at V110's first read and FALSE
by V110's final read.** This report records the transition rather than silently picking one
side of it:

| Read | Observation (read-only) |
|---|---|
| R1 (first `status.json` read) | `HISTORY_LEN=500`; **575 `timed-out`, `acknowledged=None`; 582 `skipped`, `acknowledged=None`; 585 `timed-out`, `acknowledged=None`**. Leak set = exactly those three; all three result JSONs exist. |
| R2 | `FAILURE_ROWS=41`, `ACKED_FAILURE_ROWS=39`, `UNACKED_FAILURE_ROWS=2`, `godot.lock` absent (one of the three had already been acked between R1 and R2). |
| R3 | Leak set **empty**; `ACKED_FAILURE_ROWS=41`; all three tickets `acknowledged=True` with `ack_reason` text and `ack_at` epoch. |
| R4 (final) | `HISTORY_LEN=500`, leak set `[]`, `ACKED_FAILURE_ROWS=41`. `godot.lock` was observed absent → present → absent across reads (transient concurrent job activity). |

**[O] Ack timestamps recorded in `status.json` history** (`ack_at`, UTC):
575 = `2026-11-26T09:31:52.184736Z` (`1795685512.184736`);
582 = `2026-11-26T09:32:10.770794Z` (`1795685530.7707944`);
585 = `2026-11-26T09:32:12.470487Z` (`1795685532.4704866`).
**[D]** These fall strictly inside V110's read window ⇒ the acks landed **concurrently, from
outside V110**. V110 did not run `ack` (guardrail §4/CHARTER.md:80-82; V104:7; V42:7).

**No gate result, no CLEAN claim, no parity claim.** V110 ran no runner subcommand (not even
`status`), no `assert_clean.py`, no Godot. Every value below came from read-only file reads and
the cited source. The "expected output" in §3 is a **prediction from `assert_clean.py` source**,
not an observed gate output.

## 1. Evidence table — two independent reads before declaring

| # | Label | Read A | Read B (independent) | Agreement |
|---|---|---|---|---|
| E01 | [O] | `read` tool, `godot_runner.py:580-656` | `python -c` splitlines re-read of `godot_runner.py:586-612` and `:644-647` | Identical text |
| E02 | [O] | `read` tool, `assert_clean.py:1-292` (full file) | `python -c` splitlines re-read of `assert_clean.py:154-188` and `:262-272` | Identical text |
| E03 | [O] | R1 read-only `json.loads(status.json)` | R3/R4 repeat reads of the same file | Documented transition §0 |
| E04 | [O] | Read-only `pathlib.exists()` on the three result JSONs (R1: all True) | Read-only re-read of the same JSONs after acks (R3: all True, all `acknowledged=True`) | Files retained, never deleted |
| E05 | [O] | `V104_ack_reasons.md:40-69,103-122` | `V42_gate_commands.md:34-36,115-136` | Same `ack <int> --reason` syntax, same accept/stop list |

**Consequence [D]:** the syntax and output predictions below rest on two source reads that
match line-for-line; the state report rests on four status reads that show a real, concurrent
mutation.

## 2. Task items 1, 2 and 5 — verification results

### 2.1 Item 1: ack state and result-JSON existence

- [O] At R1 the three jobs were exactly as V104/V42 describe: 575 `bbclamptidy01-parse`
  `timed-out`; 582 `terrainswarm-g1-selftest` `skipped`; 585 `g04-uitest` `timed-out`; all
  `acknowledged=None`, `ack_reason=None`. `history` length **500**. Leak set = `{575,582,585}`
  and nothing else.
- [O] `variant3d/.godot_queue/results/00000575.json`, `00000582.json`, `00000585.json` all
  exist (R1 **and** R3/R4). After the acks each still exists and now carries
  `acknowledged=true`, a non-null `ack_reason`, and `ack_at` **identical** to the matching
  `status.json` history row — exactly the write pattern of `cmd_ack`
  (`godot_runner.py:598-608`).
- [O] At R3/R4 the leak set is empty: all 41 failure-status rows in the 500-row history have
  truthy `acknowledged`. So V110 **cannot confirm "STILL unacked" at report time**; the correct
  statement is "were unacked at R1, acknowledged by R3, with result JSONs retained throughout".

### 2.2 Item 2: exact `ack <int> --reason` commands vs argparse source

Source (E01/E02, two reads each):

- `godot_runner.py:644-647`: `sub.add_parser("ack")`; `p.add_argument("ticket", type=int)`;
  `p.add_argument("--reason", required=True)`; `set_defaults(func=cmd_ack)`.
- `godot_runner.py:586-612` (`cmd_ack`): result path `RESULTS / f"{ns.ticket:08d}.json"` (`:589`);
  missing ⇒ print + `return 2` (`:590-592`); corrupt JSON ⇒ `return 2` (`:593-597`); writes
  `acknowledged=True`, `ack_reason=ns.reason`, `ack_at=time.time()` to the result (`:598-601`)
  and syncs the same triple into every matching `status.json` history row (`:603-608`); prints
  `ticket … acknowledged: …` (`:611`); `return 0` (`:612`).
- `godot_runner.py:619-624`: `--id` belongs **only** to `run`; `ack` has no `--id`.
- `assert_clean.py:262-272`: `--ignore-history` belongs **only** to `assert_clean.py`;
  `ack` has no such flag.

**[D] Verdict:** the planned form in `V104:68,110-112` and `V42:120,128-130` —
`python variant3d\tools\godot_runner.py ack <TICKET_INT> --reason "<text>"` — **matches the
argparse source exactly**: positional int ticket, required `--reason`, no `--id`, no
`--ignore-history`, and a pre-existing result JSON required (all three exist, so no `return 2`).

**[O] Landed reason wording (observed in `status.json`):** 575 and 582 carry the V42 §4.2
strings verbatim (582 with the canonical `docs/terrain_swarm_2026-11-25/reports/G04_gate_log.md`
path). 585's landed string is **not** the V104/V42 planned wording; it reads:
`COORD policy ack 2026-11-26: g04-uitest headless probe timed out at 300s (exit -9, run 308.54s) during the 2026-11-25 wave; its result is retained as evidence, not deleted. Superseded by ok job 569 at 240\ufffd (docs/terrain_swarm_2026-11-25/reports/G04_gate_log.md:183,197-211; docs/coord_swarm_2026-11-25/reports/MAP240_APPLY_01.md:100-109). This records retirement, NOT a passing uitest; fresh gates are re-run below.`
(The `\ufffd` is a mojibake replacement for `²`.) **[D]** This is an allowed wording amendment
under `V42 §8 Q1` (citations retained); it does not change syntax or ack validity.

### 2.3 Item 5: no `--ignore-history`, no deletion

- [D] The acks went through `cmd_ack`, which is an **append-and-sync** operation
  (`godot_runner.py:598-608`): three fields written to the result JSON and mirrored into the
  history row. No entry was removed, no result JSON was deleted (E04: all three exist after
  the acks), and no history row was rewritten to a non-failure status.
- [D] `--ignore-history` is an `assert_clean.py` flag (`assert_clean.py:270-271`) and, if used,
  returns `{"clean": True, "enabled": False, "total": None, "failures": []}`
  (`assert_clean.py:154-156`) — it hides reasons. It was **not** involved in the acks; V110
  did not invoke it and there is no evidence it was used. COORD must still run the plain
  `assert_clean.py --json` (`V104:115`; `V42:133`) with **no** `--ignore-history`.
- [I] Also forbidden and not used: `reset --yes`, `doctor`, `cancel`, `unwedge`, status
  hand-editing, result deletion (`V104:158-168`; `V42:125,357`).

## 3. Item 3: predicted `assert_clean.py --json` output after the three acks

**[D] Prediction from source only — not an observed gate result.** Field paths follow
`build_report` (`assert_clean.py:199-218`) and `main` (`:278-288`); history semantics follow
`check_history` (`:154-188`); lock semantics follow `check_lock` (`:118-148`, default
`DEFAULT_MAX_LOCK_AGE=300.0` at `:39,266-269`).

| Field (JSON path) | Predicted value | Source |
|---|---|---|
| process exit code | `0` | `:281,288` (`clean` true ⇒ `return 0`); `Exit codes: 0 = clean` at `:18` |
| `clean` | `true` | `:213-218,281` |
| `verdict` | `"CLEAN"` | `:215` |
| `reasons` | `[]` | `:200-212` (nothing appended when all three checks clean) |
| `checks.processes.clean` | `true` | `:110-112` (no live Godot) |
| `checks.processes.count` | `0` | `:112` |
| `checks.processes.details` | `[]` | `:111-112` |
| `checks.lock.clean` | `true` | `:118-148` |
| `checks.lock.exists` | `false` | `:123-126` (no `godot.lock` ⇒ early return) |
| `checks.lock.state` | `"free"` | `:120` (`held_recent` is also clean at `:147`, permitted only with a live job) |
| `checks.lock.age_sec` | `null` | `:121` (unchanged on the no-lock path) |
| `checks.lock.max_age_sec` | `300.0` | `:39,121,266-269` |
| `checks.history.clean` | `true` | `:183` (`not failures`) |
| `checks.history.enabled` | `true` | `:184` (plain run, no `--ignore-history`) |
| `checks.history.total` | `500` | `:185` (observed `HISTORY_LEN=500`, unchanged by `ack`) |
| `checks.history.acknowledged` | **`41`** (satisfies `>=3`) | `:166-175,186`; 41 failure rows total, all acked at R4 (38 pre-existing + the 3 new). **Not 3** — V104/V42's `>=3` is a floor, not the expected literal. |
| `checks.history.failures` | `[]` | `:176-188` (every failure-status row has truthy `acknowledged`) |

Text-mode tail, if COORD runs without `--json`: `VERDICT: CLEAN - all checks passed (exit 0)`
(`:257-259`).

**[U] Environment-dependent fields.** `checks.processes.count` and `checks.lock.state` are
read from the live machine at gate time, not from history. During V110's reads `godot.lock`
was observed **absent → present → absent** (concurrent job activity), so V110 cannot assert
them as stable observations. If a job is genuinely in flight, `state="held_recent"` with
`clean=true` is allowed (`:145-147`; `V42:136`); a stale/unknown-age lock or any live orphan
process makes the gate DIRTY. COORD must read these two fields from the actual JSON, not from
this prediction. **[I]** Run the plain gate only once the spool is settled (no pending job,
lock free), as `V42 §4` requires.

## 4. Item 4: what COORD must STOP on

**[D] STOP (do not sign off, do not widen the failure set, do not claim CLEAN) if the actual
`assert_clean.py --json` output has any of:**

1. exit code `!= 0`, or `verdict != "CLEAN"`, or `clean != true`, or non-empty `reasons`.
2. `checks.processes.count != 0` / `details` non-empty — live or orphaned Godot process.
3. `checks.lock.state` in `{"stale","held_unknown_age"}`; or `state="held_recent"` with **no**
   live job; or `exists=true` with `age_sec` unreadable. Do not force-clear with `doctor` while
   a job is pending (`V42:125,357`).
4. `checks.history.enabled != true` — this means `--ignore-history` (or equivalent) was used;
   re-run plain.
5. `checks.history.total != 500` — history was mutated/truncated; investigate before accepting.
6. `checks.history.acknowledged < 41` (and, hard floor, `< 3`) — an ack did not land or was
   overwritten.
7. `checks.history.failures` non-empty — **any** unacked `{timed-out,error,skipped}` row. If a
   fourth leak appears, give it its own evidence-backed `ack … --reason`; never delete the row,
   never add to `FAILURE_STATUSES` (`assert_clean.py:42`), never lower a threshold.
8. Any discrepancy in item 2 (syntax no longer matching `godot_runner.py:586-612,644-647`) or
   evidence that a result JSON was deleted (an `ack` would then `return 2`, `:590-592`).

**[D]** A `CLEAN` obtained by deletion, `--ignore-history`, status hand-editing, `reset`,
`doctor`, `cancel` or `unwedge` is **not** an acceptable CLEAN (`V104:151-171`; `V42:125,357`)
and must be STOPped and re-derived from the plain gate.

## 5. Scope / honesty statement

Exactly one file was written: this report. No `.gd`, shader, config, fixture, tool, result JSON,
PNG, `app/` file or git state was edited. **No Godot process was launched and no runner
subcommand — `run`, `status`, `ack`, `cancel`, `reset`, `doctor`, `unwedge` — was executed, nor
was `assert_clean.py` executed.** All values came from read-only file reads (`read`, `pathlib`,
`json.loads`) and the cited reports; every source claim was read independently twice (§1). The
ack state transition (§0) is reported as observed, with the concurrent writer attributed only
as "outside V110" — V110 did not determine which agent or process performed the acks **[U]**.
No threshold lowered, no assertion deleted, no green result fabricated, **no gate result
claimed, and no donor-parity claim made**. PORT APPROXIMATION / port-internal bookkeeping only;
donor parity remains UNVERIFIED (`CHARTER.md:43-44,134-135`).

## 6. Five-line summary

1. [O] Two independent source reads confirm `python variant3d\tools\godot_runner.py ack <TICKET_INT> --reason "<text>"` — positional int, required `--reason`, no `--id`, result JSON must exist (`godot_runner.py:586-612,644-647`).
2. [O] At V110's first read 575/582/585 were still unacked in a 500-row history with all three result JSONs present; by the final read all three were acknowledged (09:31:52/09:32:10/09:32:12 UTC) and the leak set was empty — the "STILL unacked" premise is no longer true, and the writer was outside V110.
3. [D] Predicted plain `assert_clean.py --json` after the acks: exit 0, `verdict="CLEAN"`, `reasons=[]`, `checks.processes.count=0`, `checks.lock.state="free"`, `checks.history.enabled=true`, `total=500`, `acknowledged=41` (floor `>=3`), `failures=[]` — lock/process fields are environment-dependent and must be read from real output.
4. [D] STOP if exit/verdict/reasons, process count, lock state, `enabled=true`, `total=500`, `acknowledged`, or `failures=[]` differs; a fourth leak gets its own reasoned ack, never deletion or a widened failure set.
5. [O]/[D] No `--ignore-history` and no deletion are involved: `cmd_ack` writes and mirrors `acknowledged`/`ack_reason`/`ack_at`, all three result JSONs still exist after the acks, and COORD must run the plain gate. V110 ran no runner subcommand, no gate and no Godot, and makes no parity claim.

*End of V110 report. Read-only verification only; no runner subcommand, no gate result, no edit outside this report, no parity claim.*
