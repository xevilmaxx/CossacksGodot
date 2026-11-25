---
id: TERRAIN-SWARM-WAVE-G-G12
title: "G12 — runner hygiene monitor after COORD's unwedge incident (read-only)"
owner: G12
created: 2026-11-25
status: DELIVERED
labels: [observed, derived, inferred, UNVERIFIED]
---

# G12 — runner hygiene monitor (READ-ONLY)

## 0. Scope and guardrails (OBSERVED)

- **One file written: this report only.** No Godot process launched, no runner job
  submitted / cancelled / reset / unwedged / acked, no `doctor` run, no process
  killed by name or by PID, no `counter` / `now_serving` / `status.json` / job /
  result JSON / lock edited or deleted. No `.gd`, `.gdshader`, config, test or
  fixture touched. No donor access.
- All evidence below is from read-only file reads, read-only directory listings,
  read-only `Select-String` scans and read-only `Get-CimInstance` process queries.
- The spool was **live and churning during the observation window** (Wave G's sole
  runner owner G04 was active). Every numeric snapshot is therefore timestamped;
  none is claimed to be a permanent state. `WAVE_G_CHARTER.md:31` reserves all
  runner jobs for G04; G12 issued none.
- Runner semantics are taken from `variant3d/tools/godot_runner.py` (abbrev. `GR`
  below): `counter` = `next_ticket` (`GR:118-119,495`); `now_serving` = FIFO head
  (`GR:188-193,491`); `godot.lock` content is `"<ticket> <epoch> <pid>"`
  (`GR:144-156`); `spool.lock` is a short-lived transient mutex (`GR:80-104`);
  `status.json` holds only `{"history": [...last 500 results...]}` (`GR:196-206`).

## 1. Verdict summary

| Check | Result | Evidence |
|---|---|---|
| 2000 bogus `unwedged: dead holder` result JSONs deleted | **CONFIRMED ABSENT** | recursive text scan of the whole spool: 0 hits; 0 hits in `status.json` history |
| `now_serving` vs `next_ticket` alignment | **ALIGNED** at every snapshot taken | `584/584` at 14:47:11; `585/585` at the final read |
| Stale held `godot.lock` | **NONE** | lock absent when no job in flight; when present it named the live serving ticket + its runner PID |
| Orphan Godot processes | **NO runner-orphan / no leaked zombie** | see §5 — one manual interactive Godot observed mid-window, outside the runner, not a leaked job child |
| Stale job file for skipped ticket 582 | **PRESENT (bookkeeping remnant)** | `jobs/00000582.json`, already terminal in `results/00000582.json`; needs COORD cleanup, not G12 |
| Queue mutation by this agent | **NONE** | scope statement §0 |

## 2. Bogus JSON deletion — CONFIRMED (OBSERVED)

Scans performed (all read-only):

1. `Get-ChildItem variant3d/.godot_queue -Recurse -File | Select-String -Pattern
   "unwedged","dead holder" -SimpleMatch` → **0 matching lines**.
2. Every `results/*.json` parsed: result files with `error` containing
   `unwedged` → **0**. (21 legitimately `skipped` results exist; none carry the
   bogus error — e.g. ticket 582 carries `ticket 582 was skipped (serving=2581)`.)
3. `status.json` parsed: 500 history entries; string `unwedged` count → **0**.
4. Result-file census: `00000000.json` … `00000583.json` (575 files at first read;
   9 historical gaps `311, 446, 447, 459, 460, 463, 467, 474, 581` — all pre-date
   this incident and all have matching spool output directories). After G04 ran
   ticket 584 the census was 576 files, ending at `00000584.json`.
5. No `*.tmp` files anywhere in the spool; no `now_serving.tmp` remnant.

**Derived:** the 2000 bogus `skipped` JSONs described in `WAVE_G_CHARTER.md:27`
and `docs/coord_swarm_2026-11-25/PROGRESS.md:39-42` are gone. Their former
ticket band (roughly `0581…2581`, cf. ticket 582's `serving=2581` error) is
void: no result JSON, no job JSON, no history entry survives there. The deletion
was clean — real results and history were preserved.

## 3. Counter / `now_serving` alignment (OBSERVED)

| Timestamp (CEST) | `counter` | `now_serving` | `jobs/` | `godot.lock` | Interpretation |
|---|---|---|---|---|---|
| ~14:43–14:44 (per `G04_gate_log.md:34-46`) | 584 | 584 | `1 [582]` | free | settled but stale job 582 |
| 14:47:11 | 584 | 584 | `1 [582]` | free | settled; G04 had not yet submitted |
| 14:48:11 | 585 | 584 | `1 [584]` | **HELD** `584 … 22288` | ticket 584 in flight — correct `now_serving == serving`, `counter == now_serving + 1` |
| final read | 585 | 585 | `0` | free | ticket 584 drained `ok` (`results/00000584.json`, exit 0, run 228.67 s); ticket 585 in flight at 14:52:49 |

- `counter == now_serving` at rest, and `counter == now_serving + 1` with one
  ticket in flight. **No desync survives.** `WAVE_G_CHARTER.md:27`'s warning is
  historical: COORD's `now_serving` reset (to 583 at Wave G launch; earlier to
  312 after the 2026-11-24 ticket-311 wedge — `PROGRESS.md:39-42`) plus normal
  job completions (583 failed on the B05 parse errors, 584 `ok`) restored the
  invariant.
- Ticket 582's result error `ticket 582 was skipped (serving=2581)` is the
  surviving fingerprint of the unwedge overshoot: a job submitted while
  `now_serving` had been pushed far past `next_ticket` is skipped immediately
  by `wait_for_turn()` (`GR:335-336`). The skip path records a result but does
  **not** unlink the job file (`GR:411-417`), which is why `jobs/00000582.json`
  remains — see §6.

## 4. Lock state — no stale held lock (OBSERVED)

- `godot.lock` and `spool.lock` were both **absent** at the settled snapshots
  (14:47:11, final read). No `.tmp` artifacts either.
- When `godot.lock` existed (14:48:11: `584 1795614461.449 22288`; 14:52:49:
  `585 1795614752.107 4128`) its ticket equalled `now_serving` and its PID
  equalled the live `godot_runner.py run` process (`GR:144-156, 159-169`). That
  is a legitimate in-flight mutex, not a stale hold.
- `release_godot_lock()` is owner-scoped (`GR:159-169`) and `advance_serving()`
  is conditional (`GR:188-193`) — no evidence of the old "dead holder leaves a
  pinned lock" failure mode (`GR:337-378`).

## 5. Process check — no orphan Godot (OBSERVED, with one important caveat)

Read-only `Get-CimInstance Win32_Process -Filter "Name like 'Godot%'"` snapshots:

- **14:47:11** — 1 process: PID **10320**, `Godot_v4.7.2-stable_win64.exe`,
  created 14:45:23, parent `cmd.exe` PID 14564 whose command line is
  `… launch_variant3d.bat`. Command line: `"…\WinGet\Links\godot.exe" --path variant3d`
  (no `--headless`, no self-test flag).
- **14:48:38** — 2 processes: PID 10320 (same interactive window) plus PID
  **21596**, headless, parent python PID 22288 (`godot_runner.py run --id
  g04-selftest`), i.e. the runner's own child for ticket 584.
- **14:52:49** — PID 10320 was gone; only PID **19344**, headless, parent python
  PID 4128 (`g04-selftest`/uitest chain) remained, matching held lock ticket 585.

**Observed:** PID 10320 was a deliberate *interactive windowed* launch through
`launch_variant3d.bat` — the batch file explicitly says such launches must NOT go
through the serialized runner (it redirects stdio, resolves bare `godot`, and
`reap_spawned_godot` would kill a real game window). It was **not** a leaked
runner child and not a zombie from a dead holder.

**Derived:** there was no *runner orphan* to clean. However, while PID 10320 was
alive it was an out-of-band Godot coexisting with the runner's headless child —
`unwedge` would refuse (`GR:299-302`) and `doctor` would have killed it, because
`doctor` enumerates every `Godot%` process and kills each by PID
(`GR:512-538`). Do not run `doctor` while an owner's interactive game window is
open.

**UNVERIFIED:** whether PID 10320 was closed by the owner or exited on its own;
its disappearance was observed, not its cause.

## 6. Outstanding bookkeeping: stale ticket 582 job file (OBSERVED / INFERRED)

- `jobs/00000582.json` (`terrainswarm-g1-selftest`, created epoch 1795613838.29,
  pid 18928) still sits in `jobs/` even though `results/00000582.json` records
  it terminal (`status: skipped`, `error: ticket 582 was skipped (serving=2581)`,
  `run: 0.0`). It makes `status` report `pending = 1 [582]` — exactly the
  pre-flight FAIL recorded in `G04_gate_log.md:49-57`.
- **Inferred:** a bookkeeping remnant of the skip path (`GR:411-417`), not a
  live job. No PID holds it and it can never be served (`582 < now_serving`).
- **Not touched by G12.** Cleanup is a queue mutation reserved for COORD and is
  listed in §7 step 6. G04 explicitly declined to clean it (`G04_gate_log.md:82-85`).

## 7. Runbook — safe recovery from a wedged FIFO (for COORD only)

Sequence COORD actually used on 2026-11-25, reconstructed from
`PROGRESS.md:39-42`, `WAVE_G_CHARTER.md:27`, ticket 582's result error and
`godot_runner.py`. **G12 did not execute any of it.**

### Preconditions (must all hold before step 1)
`python variant3d\tools\godot_runner.py status` shows `godot.lock = free`
and **zero live Godot processes**, and the suspected holder PID is confirmed
dead. If a Godot window is open (see §5, PID 10320), stop — do not proceed.

### Step 1 — `doctor` (orphan sweep)
```
python variant3d\tools\godot_runner.py doctor
```
`GR:512-538`: enumerates every process whose name matches `Godot%` via CIM,
kills each **by PID**, then releases `godot.lock`. COORD recorded `0 orphans`.

> **Warning — name-based kill prohibition.** Never substitute a name-based kill
> (`taskkill /IM godot.exe`, `Stop-Process -Name Godot`, `pkill -9 -f godot`,
> `pgrep | xargs kill`). Those are explicitly forbidden
> (`C02_gate_plan.md:408-412`; `terrain_swarm_2026-11-25/README.md:359-360`):
> they destroy another job's child and break mutual exclusion. The runner kills
> **only PIDs its own job spawned** (`GR:261-273`, `reap_spawned_godot`). Even
> `doctor` is broad — it resolves names to PIDs and kills *all* of them, so it
> requires COORD approval and will close an owner's interactive Godot window.

### Step 2 — `unwedge` (advance past dead holders)
```
python variant3d\tools\godot_runner.py unwedge
```
`GR:294-321`: refuses while the lock is held or any Godot process is alive;
otherwise loops **up to 2000 times**, writing one result JSON per advanced
ticket with `"status": "skipped", "error": "unwedged: dead holder"`, then
advances `now_serving` and unlinks that job file.

> **Warning — the 2000-ticket advance side effect.** `unwedge` advances
> `now_serving` only; it does **not** touch `counter` (`GR:188-193, 304`). A
> single call therefore leaves `now_serving` up to 2000 greater than
> `next_ticket` (COORD's runs pushed serving to ~2581; ticket 582 was skipped
> with `serving=2581`), and writes up to 2000 bogus result JSONs. Until step 4,
> **every new ticket is instantly skipped** by `wait_for_turn()` (`GR:335-336`).
> No new job may be submitted between steps 2 and 4.

### Step 3 — delete the bogus JSONs (after verification)
Delete **only** result files whose JSON has
`"error": "unwedged: dead holder"` (verify the count first — COORD reported
exactly 2000). Do not delete real `ok` / `failed` / `timed-out` / legitimately
`skipped` results, nor any `status.json` history entry that lacks that string.
Confirmation that this was done correctly is §2 above: zero hits remain.

### Step 4 — restore `now_serving` to the pre-wedge value
Write the value of `counter` (`next_ticket`) into `now_serving` so
`now_serving == next_ticket` again (COORD restored 312 at the 2026-11-24
incident and 583 at Wave G launch). This is a direct one-number repair, **not**
`reset --yes` (`GR:541-552`) — `reset` deletes counter, serving, status, jobs
**and results**, destroying the evidence you just verified.

> **Warning — never advance `counter`.** Advancing `counter` instead of
> rewinding `now_serving` would permanently orphan the skipped tickets and
> hide the incident. Always align `now_serving` down to `next_ticket`.

### Step 5 — re-verify
```
python variant3d\tools\godot_runner.py status
```
Require: `now_serving == next_ticket`, `pending = 0 []`, `godot.lock = free`,
zero live Godot processes, no `unwedged` string in `results/` or `status.json`.

### Step 6 — optional stale-job cleanup (COORD only)
If a lower-numbered job file remains after a skip (ticket 582 in §6):
```
python variant3d\tools\godot_runner.py cancel --ticket 582
```
(`GR:555-583`). Write a fresh result and unlink the job file. G12 did not run
this. Any retried job must get a **new unique `--id`**.

### Standing prohibitions (binding on every G agent)
- Only G04 may submit runner jobs; all other Wave G agents are read-only w.r.t.
  the queue (`WAVE_G_CHARTER.md:31`).
- Never kill Godot by name (§7 step 1 warning).
- Never weaken a gate to "fix" a wedge: no lowered threshold, no flipped marker,
  no `ack` without a landed fix (`C02_gate_plan.md:450-451`).
- Donor parity remains **UNVERIFIED** regardless of any gate result.

## 8. Open items / hand-off

1. **COORD decision needed:** stale `jobs/00000582.json` (§6) still makes
   `pending = 1`. G04's clean-gate pre-flight requires `pending = 0`;
   step 6 above resolves it. G12 did not mutate it.
2. **Process caveat:** the manual interactive Godot (§5) showed that a
   non-runner window can coexist with a runner child. Keep `doctor` off-limits
   while such a window is open; `unwedge` will (correctly) refuse too.
3. **Snapshot discipline:** the spool was busy (ticket 584 `ok`, ticket 585
   in flight) at report time. Any later "clean" claim must be re-polled, not
   inherited from this report — cf. `FINAL_CHECKLIST.md:13`'s snapshot caveat.
4. **UNVERIFIED:** the exact original unwedge command line and operator actions
   were reconstructed from reports and runner source, not from a shell log; the
   "doctor → unwedge → delete → reset" ordering is COORD's own description in
   `PROGRESS.md:39-42`.

*End of G12 runner-monitor report. Read-only pass — no queue state modified.*
