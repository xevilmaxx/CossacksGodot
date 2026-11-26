---
id: V104
swarm: TERRAIN-SWARM-2026-11-26
title: "V104 — exact, evidence-backed `ack <ticket> --reason` commands for the 3 unacked runner jobs 575/582/585"
agent: "V104 (worker in the 30-agent DONOR-FIRST terrain swarm 2026-11-26; reporting to COORD)"
role: "READ-ONLY — no runner subcommand, no Godot job, no code edit, exactly one report"
owner_file: docs/terrain_swarm_2026-11-26/reports/V104_ack_reasons.md
status: PLANNED_ONLY__NO_RUNNER_SUBCOMMAND__NO_GATE_RUN__NO_GODOT__NO_PARITY_CLAIM
created: 2026-11-26
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "PORT APPROXIMATION / port-internal bookkeeping only. No donor binary, donor byte, donor GPU frame, Godot process, gate or result JSON was produced by V104. Nothing here certifies donor fidelity; donor parity stays UNVERIFIED (CHARTER.md:43-44,121-135)."
principle: "[O] literal file:line or read-only filesystem read · [D] deterministic consequence of cited source · [I] recommendation with caveat · [U] unresolved. Every `ack` line below is a PLANNED command for COORD; V104 executed ZERO of them."
governing_sources:
  - docs/terrain_swarm_2026-11-26/CHARTER.md
  - docs/terrain_swarm_2026-11-26/reports/V06_gate_remediation.md
  - docs/terrain_swarm_2026-11-26/reports/V42_gate_commands.md
  - docs/terrain_swarm_2026-11-26/reports/V76_gate_preflight.md
  - variant3d/tools/godot_runner.py
---

# V104 — exact ack commands for 575 / 582 / 585 (COORD runs; V104 ran nothing)

## 0. Purpose

`assert_clean.py --json` is `DIRTY` on today's tree because `status.json` history holds
exactly **three unacknowledged leak-status rows** — **575** (`timed-out`), **582**
(`skipped`), **585** (`timed-out`) — while `failed` rows are deliberately outside the
leak set (`V06:27,45,47`; `V42:35-36`; `V76:53`, row 10). The only legitimate way to
make the plain gate CLEAN is to record an **auditable, evidence-backed reason** on each
row via the runner's own `ack` subcommand. This report supplies the exact commands,
their source-verified syntax, the observed status/result path for each job, the
passing job/report that supersedes each, and why `ack` is honest whereas deletion or
`--ignore-history` is not.

**No gate result, no CLEAN claim, no parity claim.** V104 did not run `ack`, `status`,
`assert_clean.py`, any `run` job, or Godot. After COORD runs the three acks, fresh gates
for the 2026-11-26 tree still have to be regenerated (`V42 §4.3–§4.11`); acking only
retires historical diagnostics, it does not make a stale green JSON fresh.

## 1. Source-verified syntax (two independent reads)

Read 1 — `variant3d/tools/godot_runner.py:586-612` (`cmd_ack`):
`p = RESULTS / f"{ns.ticket:08d}.json"` (`:589`), missing/corrupt result ⇒ return 2
(`:590-597`), then writes `acknowledged`, `ack_reason`, `ack_at` (`:598-601`) to the
**result JSON** and syncs the same three fields into the matching `status.json` history
row (`:603-608`), then prints `ticket … acknowledged: …` (`:611`).

Read 2 — `variant3d/tools/godot_runner.py:644-647` (argparse `ack` subparser):
`p = sub.add_parser("ack", …)`; `p.add_argument("ticket", type=int)`;
`p.add_argument("--reason", required=True)`.

Both reads agree. Consequences `[D]`:

- `ticket` is a **positional int**, `--reason` is **required**; the only result path a
  given ticket can touch is `variant3d/.godot_queue/results/<8-digit-ticket>.json`.
- `ack` has **no** `--id` (only `run` declares `--id`, `:619-624`) and **no**
  `--ignore-history` (that flag belongs to `assert_clean.py` and suppresses the
  failure set, `assert_clean.py:154-156,262-272`; `V42:35,78`).
- The result JSON **must already exist** or `ack` returns 2. All three exist (§3), so
  the calls will not return 2.
- Each successful call leaves a durable triple (`acknowledged`/`ack_reason`/`ack_at`)
  in both the result and the telemetry history — an **auditable record**, not a
  silent deletion.

Exact command form:

```
python variant3d\tools\godot_runner.py ack <TICKET_INT> --reason "<evidence-backed text>"
```

## 2. Evidence table

| # | Label | Source (file:line / read-only command) | Establishes |
|---:|---|---|---|
| E01 | [O] | `variant3d/tools/godot_runner.py:586-612` (read 1); `:644-647` (read 2) | `ack <ticket:int> --reason <text>`; `--reason` required; writes `acknowledged`/`ack_reason`/`ack_at` to result + status history; no `--id`; missing result ⇒ 2 |
| E02 | [O] | `variant3d/.godot_queue/results/00000575.json`, `00000582.json`, `00000585.json` (direct reads) | Exact status, exit, run, timeout, argv and result paths of the three jobs (§3) |
| E03 | [O] | Read-only `python json.loads(status.json)` → `HISTORY_LEN=500`; 575 `timed-out`, 582 `skipped`, 585 `timed-out`, all `acknowledged=None`, `ack_reason=None`; 568/569 `ok` | Exactly three unacked leaks; two superseding jobs are `ok` in the same history |
| E04 | [O] | `docs/coord_swarm_2026-11-25/reports/B_B_CLAMP_TIDY.md:148-149` | 575 was the single diagnostic `--check-only game.gd` probe, timed out, SCRIPT ERROR 0; atom ended with no parity claim |
| E05 | [O] | `docs/terrain_swarm_2026-11-25/reports/G12_runner_monitor.md:128-138` | 582 is a terminal `skipped` bookkeeping remnant (`error: ticket 582 was skipped (serving=2581)`, `run: 0.0`), not a live job; cleanup is COORD-only |
| E06 | [O] | `docs/terrain_swarm_2026-11-25/reports/G04_gate_log.md:157-165,183,197-211` | COORD cleared the stale 582 job file; 585 `g04-uitest` hung in setup, killed at 300 s (`exit=-9`, `script_error_lines=0`); follow-up 587 hit the 120 s watchdog and the on-disk 17/17 predates both runs |
| E07 | [O] | `docs/coord_swarm_2026-11-25/reports/MAP240_APPLY_01.md:100-101,105-109` (canonical path; note V42 cites this file without the `coord_swarm` directory) | 568 `map240apply01-selftest` = **ok/exit 0**, 29/29; 569 `map240apply01-uitest` = **ok/exit 0**, 17/17 — the passing jobs that supersede the skipped/killed selftest and uitest probes |
| E08 | [O] | `V06_gate_remediation.md:27,83-98`; `V42_gate_commands.md:35,104-136`; `V76_gate_preflight.md:53` row 10 | The three evidence-backed reason strings and the `ack`-then-plain-CLEAN plan; deletion/`--ignore-history` explicitly forbidden |
| E09 | [O] | `V06:45,47`; `assert_clean.py:33-42,154-188,199-218,262-272` | Leak set `{timed-out,error,skipped}`; `failed` excluded; `--ignore-history` returns `enabled:false,total:null,failures:[]` (hides reasons) |

`[I]` appears only in §5. `[U]` items are recorded in §6.

## 3. Observed status and result path for each job

All three result files were read directly and are present under
`variant3d/.godot_queue/results/`:

| Ticket | Job id | Invoked argv (after `run --id … --`) | `status` | `exit` | `run` / `timeout` | Result JSON |
|---:|---|---|---|---|---|---|
| **575** | `bbclamptidy01-parse` | `--headless --path variant3d -- --check-only res://scripts/game.gd` (`00000575.json:4-11`) | **`timed-out`** (`:17`) | `-9` (`:15`) | 302.44 s / 300.0 s (`:14,16`) | `variant3d/.godot_queue/results/00000575.json` |
| **582** | `terrainswarm-g1-selftest` | `--headless --path variant3d -- --self-test variant3d/selftest.json` (`00000582.json:4-11`) | **`skipped`** (`:17`) | `null` (`:15`) | 0.0 s / 300.0 s (`:14,16`) | `variant3d/.godot_queue/results/00000582.json` |
| **585** | `g04-uitest` | `--headless --path variant3d -- --ui-test variant3d/uitest.json` (`00000585.json:4-11`) | **`timed-out`** (`:17`) | `-9` (`:15`) | 308.54 s / 300.0 s (`:14,16`) | `variant3d/.godot_queue/results/00000585.json` |

Additional observed fields: 582 carries `error: "ticket 582 was skipped (serving=2581)"`
(`00000582.json:20`). Each result also points at a per-job stdout/stderr folder
(`results/00000575_bbclamptidy01-parse/…`, `00000582_terrainswarm-g1-selftest/…`,
`00000585_g04-uitest/…`) — these remain untouched by `ack`.

## 4. The exact commands COORD will run (PLANNED; V104 ran none)

Source: syntax §1; reason strings are the V06/V42 evidence-backed wording, kept with
all citations and made self-contained (V42 §8 Q1 permits wording amendments provided
the evidence citations stay). PowerShell, one line per call, from repo root, `python`.

```powershell
python variant3d\tools\godot_runner.py ack 575 --reason "COORD policy ack 2026-11-26: diagnostic-only --check-only game.gd parse probe timed out at 300s (exit -9, run 302.44s, SCRIPT ERROR 0; docs/coord_swarm_2026-11-25/reports/B_B_CLAMP_TIDY.md:148-149). Owner retired the probe without re-submit. This records retirement, NOT a passing gate and NOT a parse proof; fresh gates are re-run by the V42 packet."
python variant3d\tools\godot_runner.py ack 582 --reason "COORD policy ack 2026-11-26: terminal skipped bookkeeping remnant, run=0.0, bogus error serving=2581 (docs/terrain_swarm_2026-11-25/reports/G12_runner_monitor.md:128-138; G04_gate_log.md:157-165); no Godot ran and COORD cleared the stale job file. Superseded by ok jobs 568/569 (docs/coord_swarm_2026-11-25/reports/MAP240_APPLY_01.md:100-109). Records retirement only, NOT a green selftest run."
python variant3d\tools\godot_runner.py ack 585 --reason "COORD policy ack 2026-11-26: g04-uitest hung in setup and was killed at 300s (exit -9, SCRIPT ERROR 0; docs/terrain_swarm_2026-11-25/reports/G04_gate_log.md:183,197-211); follow-up 587 hit the 120s watchdog and the on-disk 17/17 predated both runs, so no fresh PASS was claimed. Superseded by ok job 569 at 240x240 (docs/coord_swarm_2026-11-25/reports/MAP240_APPLY_01.md:101,108-109). Records retirement, NOT a green uitest."

# then, and only then, the plain gate — no --ignore-history:
python variant3d\tools\assert_clean.py --json
```

Accept only `exit=0`, `verdict=CLEAN`, `reasons=[]`, `checks.processes.count=0`,
`checks.lock.state=free`, `checks.history.enabled=true`, `checks.history.total=500`,
`checks.history.acknowledged>=3`, `checks.history.failures=[]` (`assert_clean.py:182-218`;
`V06:98`; `V42:136`). **STOP** if any item is unmet. A fourth leak later gets its own
reasoned ack; the failure set is never widened and no entry is deleted.

### Per-job rationale — what superseded it, which passing job/report proves it

- **575 — diagnostic parse probe, retired.** `[O]` Result `timed-out`/exit −9 at 300 s
  (§3); the owner's atom ended with "one runner job (ticket 575, timed-out, SCRIPT
  ERROR 0); no parity claim" (`B_B_CLAMP_TIDY.md:148-149`, E04). What superseded it is
  the **owner's retirement decision**, not a PASS — so the reason says so explicitly
  ("NOT a passing gate and NOT a parse proof"). Fresh parse coverage is supplied by
  the V42 packet's per-file `--check-only` jobs (`V42 §4.3/§4.7`), once COORD runs them.
  `[D]` Acknowledging is honest precisely because it records retirement rather than
  promoting a timed-out probe to green.

- **582 — skipped selftest bookkeeping remnant.** `[O]` `status=skipped`, `run=0.0`,
  `error: … serving=2581` (§3); G12 records it as a terminal bookkeeping remnant that
  could never be served, with COORD-only cleanup (`E05`), and G04 records that COORD
  cleared the stale job file (`E06`). **Superseding PASS:** ticket **568**
  `map240apply01-selftest`, `ok`/exit 0, 29/29 (`MAP240_APPLY_01.md:100,105-107`, E07),
  confirmed `ok` in `status.json` (E03). The reason cites both G12/G04 and 568/569,
  and states "NOT a green selftest run" — the skipped job never ran Godot.

- **585 — killed uitest, superseded by a later ok uitest.** `[O]` `timed-out`/exit −9
  at 300 s (§3); G04 details the setup hang, the 300 s kill, and that the on-disk 17/17
  predates both 585 and follow-up 587, which hit the 120 s watchdog (`E06`). **Superseding
  PASS:** ticket **569** `map240apply01-uitest`, `ok`/exit 0, 17/17 at 240×240
  (`MAP240_APPLY_01.md:101,108-109`, E07), also `ok` in `status.json` (E03). The reason
  records that no fresh PASS was claimed from 585/587 and that the retirement is
  backed by 569 — "NOT a green uitest."

## 5. Why `ack --reason` is honest and the alternatives are not

- `[D]` **ack is auditable.** `cmd_ack` persists `acknowledged=true`, `ack_reason` and
  `ack_at` into both the result JSON and the matching status-history row (E01). The
  reason strings in §4 state *retirement*, name the superseding `ok` job/report, and
  explicitly refuse to call a timed-out/skipped job a PASS. CLEAN then reflects a
  truthful history in which every leak has a recorded disposition.
- `[D]` **deletion is dishonest and self-defeating.** `ack` itself requires the result
  JSON to exist (missing ⇒ return 2, E01); deleting `00000575/582/585.json` destroys the
  evidence (exit/run/status/argv) that justifies the disposition and would make the
  documented command fail. It also removes rows rather than accounting for them.
- `[D]` **`--ignore-history` is dishonest.** It is an `assert_clean.py` flag
  (`assert_clean.py:262-272`) that returns `enabled:false,total:null,failures:[]`
  (`assert_clean.py:154-156`; `V06:85,222`; `V42:125`) — it *suppresses* the reasons
  instead of recording them, producing a CLEAN that hides why the leaks were closed.
- `[D]` **`reset`/`doctor`/`cancel`/`unwedge` and status hand-editing are out of scope**
  and forbidden by `V06:85` and `V42:125`; they mutate queue state rather than record a
  disposition. None is used here.
- `[I]` Therefore: ack with reasons, then a **plain** `assert_clean.py --json`, then
  regenerate fresh gates. If CLEAN cannot be obtained that way, leave CLEAN
  explicitly unclaimed — never suppress or delete to force it.

## 6. UNVERIFIED register

| Item | Status | Why |
|---|---|---|
| The three acks actually landed / `assert_clean.py --json` actually CLEAN on 2026-11-26 | **NOT_RUN — UNVERIFIED** | V104 ran no runner subcommand; §4 is a plan for COORD |
| Fresh 29/29, 17/17, `t_render_mode`, CLEAN for today's tree | **UNVERIFIED** | Stale JSONs only; acking does not refresh a gate (`V06:24-25,235`; `V76 §0`) |
| Any donor-parity statement | **UNVERIFIED — no claim made** | No donor GPU A/B frame (`CHARTER.md:43-44,134-135`) |
| Exact origin of 582's `serving=2581` value | **[U]** | Documented as bogus skip/bookkeeping (E05); old spool generation inferred, not proven (`V06:242`) |

## 7. Scope / honesty statement

Exactly one file was written: this report. No `.gd`, shader, config, fixture, tool,
result JSON, PNG, `app/` file or git state was edited. **No Godot process was launched
and no runner subcommand — including `run`, `status`, `ack`, `cancel`, `reset`,
`doctor`, `unwedge`, or `assert_clean.py` — was executed.** Every value came from
read-only file reads, a read-only `json.loads` of `status.json`, and the cited reports,
with the ack syntax verified against the argparse/`cmd_ack` source by **two independent
reads** (§1). Every command in §4 is a **PLAN** for COORD. No threshold was lowered, no
assertion deleted, no green result fabricated, **no gate result claimed, and no
donor-parity claim made**. PORT APPROXIMATION / port-internal bookkeeping only; donor
parity remains UNVERIFIED.

## 8. Five-line summary

1. [O] Syntax re-verified twice from source: `python variant3d\tools\godot_runner.py ack <TICKET_INT> --reason "<text>"` — positional int, `--reason` required, no `--id`, result JSON must exist (`godot_runner.py:586-612,644-647`).
2. [O] 575 = `timed-out`/−9 (302.44 s), 582 = `skipped`/0.0 s (`serving=2581`), 585 = `timed-out`/−9 (308.54 s); result paths `results/00000575.json`, `00000582.json`, `00000585.json`; exactly these three unacked in a 500-row history.
3. [O] Reasons are evidence-backed: 575 retired by owner (`B_B_CLAMP_TIDY.md:148-149`); 582 superseded by ok 568/569; 585 superseded by ok 569 at 240² (`MAP240_APPLY_01.md:100-109`) — neither skipped/killed job is called a PASS.
4. [D] `ack` records `acknowledged`/`ack_reason`/`ack_at` in result **and** status history — auditable; deletion destroys evidence (and breaks ack), `--ignore-history` hides reasons (`enabled:false,total:null,failures:[]`). Both forbidden.
5. [U] V104 ran no ack, no gate, no Godot; §4 is planned for COORD, who must then run a plain `assert_clean.py --json` and regenerate fresh gates. No gate result, no parity claim.

*End of V104 report. Planned only; no runner subcommand, no gate result, no edit outside this report, no parity claim.*
