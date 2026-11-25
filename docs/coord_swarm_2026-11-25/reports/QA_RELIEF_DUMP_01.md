---
id: QA-RELIEF-DUMP-01
title: "Read-only QA — verify the relief-stamps dump probe after RELIEF-ENABLE-01 lands"
agent: "QA-RELIEF-DUMP-01 (read-only QA subagent), coord swarm 2026-11-25"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB
scope: "One new file only: this report. No source/asset/config/test/PNG/JSON/git edit; no Godot submission; no dump probe; no donor access; no ladder advancement."
exclusive_output: "docs/coord_swarm_2026-11-25/reports/QA_RELIEF_DUMP_01.md"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "PORT APPROX — internal consistency only. No donor GPU A/B frame exists. No donor parity is claimed anywhere in this report."
verdict: "RUNTIME UNVERIFIED. Owner report RELIEF_ENABLE_01.md NOT LANDED; dump artifact ABSENT; job 521 (reliefenabl01-dump) KILLED at 180 s hard timeout (exit -9) so no relief_stamps entries/centres/counts exist to report; job 520 (reliefenabl01-smoke) parse-only ok, SCRIPT ERROR == 0. k_ravine_1 remains BLOCKED. No visual hill A/B exists."
---

# QA RELIEF DUMP 01 — verification of the relief-stamps dump probe

## 0. Mandate and boundary

Read-only QA of the dump probe for the relief-stamps opt-in. Every statement below
is tagged **observed** (literal artifact bytes/lines or a directly executed
read-only filesystem check), **derived** (arithmetic/control-flow consequence of
observed facts), **inferred** (attribution without a pixel-aligned donor A/B), or
**UNVERIFIED**. Nothing was edited; no runner job, dump probe or Godot process
was submitted by this QA agent. **No donor parity claim is made.**

The two questions put to this QA were: (a) does the dump artifact contain a
`relief_stamps` array with `plt2` centres, and (b) what did queue jobs **520**
and **521** actually do? Both are answered from on-disk artifacts only.

---

## 1. Sources consulted

| # | Source | What it supplied | Label |
|---:|---|---|---|
| S1 | `docs/coord_swarm_2026-11-25/reports/RELIEF_ENABLE_01.md` | **ABSENT** — no file with this name anywhere in the repo (directory listing + recursive glob both empty). The owner report has **not** landed as of this read. | observed |
| S2 | `reports/TERRAIN_MARKS_01.md` (`:99`, `:107-124`, `:156-191`, `:204-223`) | Rank-1 diagnosis (flag off → no donor-grid hills), the proposed flag-on/flag-off `--dump-map` + fixed-camera A/B, harness-stub caveat, open questions. | observed |
| S3 | `reports/RELIEF_01_stamping.md` (`:71-91`, `:117-131`, `:166-184`, `:225-241`) | Consumer marker contract `{"name","cx","cy",…}`; additive-clamp = PORT APPROXIMATION; stamp path itself **not** exercised by RELIEF-01's smoke (§8 Q10). | observed |
| S4 | `reports/RELIEF_02_stamp_marker.md` (`:49-84`, `:88-118`, `:121-140`, `:144-164`) | Producer emits only `plt2` from `game.pattern_stamps`; `k_ravine_1` **BLOCKED** (§5); smoke 415 was a `--check-only` parse check, not a dump-content assertion (§4). | observed |
| S5 | `reports/CONFIG_WIRE_RELIEF.md` (`:40-55`, `:57-88`, `:89-109`, `:121-126`) | `main.gd` gate `if relief_enabled: dump["relief_stamps"] = relief_stamps`; default false preserves behaviour; runtime dump-content assertion still open (§6 Q1); smoke 464 parse-only. | observed |
| S6 | `reports/QA_RELIEF_ON_01.md` (`:32-45`, `:104-123`, `:127-164`) | Prior QA: config flip to `true` observed and clean; marker emission **derived**-eligible; runtime + visual UNVERIFIED; owner report already absent at that read. | observed (prior QA claim, independently re-checked here where applicable) |
| S7 | `reports/QA_GATE_READY_02.md:107-116` | Poll B observed live PID **11292** running `--dump-map C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/reliefenabl01_dump.json`; `now_serving=521`, `pending=[521,522,523]`. | observed |
| S8 | `variant3d/config.json:16-20` | `features.terrain.relief_stamps: true` (JSON boolean). Read-only. | observed |
| S9 | `variant3d/.godot_queue/results/00000520.json` + `00000520_reliefenabl01-smoke/` | Job **520** metadata, stdout (75 B) and stderr (0 B). | observed |
| S10 | `variant3d/.godot_queue/results/00000521.json` + `00000521_reliefenabl01-dump/` | Job **521** metadata, stdout (75 B) and stderr (45 B). | observed |
| S11 | `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\reliefenabl01_dump.json` | **ABSENT** — `Test-Path -LiteralPath` returned `False`; recursive `*relief*` search of that folder found only `sp06_relief_check.py` (an older, unrelated SP-06 probe). No dump artifact of any name exists. | observed |
| S12 | `git status --short` (read-only) | `variant3d/config.json` is modified/uncommitted; no `RELIEF_ENABLE_01.md` in the untracked set. Consistent with S1/S6. | observed |
| S13 | `inbox/backup/config.json.bak-RELIEFENABLE` | Pre-flip backup exists (also cited by S6 §2), supporting that the flag change is the owner's in-flight work rather than a long-standing default. | observed |

---

## 2. Dump evidence

### 2.1 The dump artifact itself — ABSENT (observed)

The exact path named in the task,
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\reliefenabl01_dump.json`,
**does not exist**: `Test-Path -LiteralPath` = `False` (S11). No other file whose
name contains `relief` exists in that temp folder except the unrelated
`sp06_relief_check.py`. The queue's own output path for job 521 (S10, `argv`) is
the same location, so the expected artifact and the checked path coincide.

**Consequently there are no `relief_stamps` entries to quote**: no array, no
`plt2` record, no `cx`/`cy` centre, no entry count, no `name` field, no empty-array
confirmation. Any such numbers in this report would be invented, so none are given.
**Runtime marker content: UNVERIFIED.**

### 2.2 Job 520 — `reliefenabl01-smoke` (observed, from S9)

| Field | Value |
|---|---|
| Ticket / id / status / exit | **520** / `reliefenabl01-smoke` / `ok` / **0** |
| argv | `--headless --path variant3d --check-only --script res://scripts/main.gd` |
| wait / run | 168.671 s / 21.225 s |
| timeout | 180.0 s |
| stdout | 75 B — Godot 4.7.2 banner only, no diagnostic |
| stderr | **0 B → `SCRIPT ERROR` occurrences = 0** |

**derived:** this is a `--check-only` parse/compile check of `main.gd`; it does
**not** execute `_dump_map()` and therefore proves only that the edited producer
file has no script error. It does **not** prove that a marker key or a `plt2`
entry is emitted — the same limitation recorded in S4 §4 and S5 §4.

### 2.3 Job 521 — `reliefenabl01-dump` (observed, from S10)

| Field | Value |
|---|---|
| Ticket / id / status / exit | **521** / `reliefenabl01-dump` / `timed-out` / **-9** |
| argv | `--headless --path variant3d -- --dump-map C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/reliefenabl01_dump.json` |
| wait / run | 181.668 s / **190.212 s** |
| timeout | 180.0 s (hard) |
| stdout | 75 B — Godot 4.7.2 banner only; **no dump/JSON output line** |
| stderr | 45 B — blank line + `[runner] KILLED after 180.0s (hard timeout)` |

**derived:** `run = 190.212 s` exceeds the 180.0 s hard limit, and stderr names
the kill explicitly; the runner sent SIGKILL-style termination (exit `-9`). The
process was terminated before `--dump-map` could write its JSON, which is
consistent with the artifact's absence (§2.1) and with S7's Poll B snapshot that
caught PID 11292 alive on this exact command while the queue was serving ticket
521. **Why** the dump run needed more than 180 s (map size, generation work or
slow startup) is **UNVERIFIED** — no timing breakdown was captured.

**observed:** neither stdout nor stderr of 521 contains the text
`relief_stamps`, a `plt2` name, or any `(cx,cy)` pair. There is no partial dump
to salvage.

### 2.4 What the config says (observed / derived, S8 + S5 + S6)

`variant3d/config.json:18` reads `"relief_stamps": true` inside
`features.terrain` (JSON boolean). **derived:** with that value the null-safe
getter in `main.gd` resolves to true and the `if relief_enabled` branch is
eligible to add `dump["relief_stamps"]`. But eligibility is not emission: no
successful post-flip dump exists (§2.1–2.3), so this remains the same
**derived-only** claim already recorded in S6 §3. The config flip is also still
an uncommitted working-tree change (S12).

---

## 3. Verdict

**RUNTIME UNVERIFIED — no dump-content claim can be made; owner report not landed.**

- **observed:** `RELIEF_ENABLE_01.md` has **not** landed (S1); the config flag is
  `true` (S8) but uncommitted (S12); the requested dump artifact is **absent**
  (S11); job 520 passed a parse-only check with `SCRIPT ERROR == 0` (S9); job
  521 was killed at the hard 180 s timeout with exit `-9` and produced only a
  Godot banner plus the kill line (S10).
- **derived:** the missing artifact is explained by 521's hard timeout, not by a
  silent producer failure. Parse-only success in 520 says nothing about marker
  emission.
- **UNVERIFIED:** whether a flag-on dump would contain the `relief_stamps` key,
  whether it would hold any `plt2` entry, what its `cx`/`cy` centres would be,
  how many stamps there are, whether `stats.relief_grid.applied > 0`, and
  whether any height or pixel changed. No entry, centre or count is asserted.
- **inferred:** enabling the flag is a necessary condition for the donor-grid
  path, but with the probe killed there is no evidence it was sufficient in this
  run.
- **BLOCKED (unchanged):** `k_ravine_1` remains BLOCKED (S4 §5, S5 §6 Q2, S6 §5.1):
  it is absent from `donor_patterns.json`, has no `ravine_medium` recipe in
  `pattern_gen.gd`, and donor `dogenerate.inc:1760` `//`-disables `ravine_medium`
  in favour of `ravine_big`. The config flip does not unblock it.
- **UNVERIFIED / absent:** **no visual hill A/B exists.** The only available P0
  PNG is a deliberately flat 64² control, and the harness stub dump carries no
  `relief_stamps` key (S2 §1.3/§4), so it cannot show relief regardless of the
  flag. No donor GPU A/B frame exists; the sculpt blend stays a PORT
  APPROXIMATION and **donor parity is UNVERIFIED**.

---

## 4. Remaining blockers

1. **Owner report not landed (delivery blocker).** `RELIEF_ENABLE_01.md` is
   absent (S1); the work exists only as an uncommitted config edit plus queue
   artifacts. Treat RELIEF-ENABLE-01 as not fully delivered until it lands.
2. **Dump probe did not complete (primary runtime blocker).** Job 521 was killed
   at 180 s; the dump artifact is absent. A successful `--dump-map` run (with a
   timeout above the observed 190 s run) is required before any marker-content
   claim is possible. This QA did **not** resubmit it.
3. **`k_ravine_1` producer hook BLOCKED** — owner-gated donor export/recipe
   decision, unaffected by the flag (S4 §5, S6 §5.1).
4. **Visual hill A/B absent** — no fixed-camera capture built from a real dump,
   and the P0 harness stub has no marker key (S2 §4 step 4, S6 §5.3).
5. **Consumer/geometry assertion absent** — no `stats.relief_grid` reading and
   no height-range comparison between flag-on and flag-off dumps.
6. **Donor blend, placement, footprint, row flip and props** remain
   PORT APPROXIMATION / UNVERIFIED (S3 §5, S4 §6, S6 §5.2), including the
   unresolved `plt2` max `+3.6134` vs global cap `+2.964` and the flat-topped
   plateau concern.

---

## 5. Open questions (UNVERIFIED — do not guess)

1. Will `RELIEF_ENABLE_01.md` land, and what will it claim about jobs 520/521?
2. Why did job 521 exceed the 180 s hard timeout? A re-run with a longer timeout
   is the cheapest way to obtain the artifact.
3. Which preset/seed actually places a `plt2` stamp at runtime? Only a
   successful dump-content assertion answers this (S4 §7 Q1, S5 §6 Q1).
4. Does a flag-on dump contain the `relief_stamps` key at all, and is its array
   empty or populated? A flag-off counterpart must show the key absent.
5. If a `plt2` entry appears, what are its exact `cx`/`cy`, and does feeding the
   dump to `world3d_terrain.build()` yield `applied > 0` and a height-range shift
   while preserving 4,096 / 7,938 / 1 surface at 64²?
6. Would the resulting patch read as a hill or as a flat pale "mark" at the
   fixed camera, given the coarse 8×10 means and the +2.964 cap?
7. Does the capture environment override the flag through `--config` or
   `user://options.json` (S6 §3.5)?
8. Is `k_ravine_1` worth unblocking at all, given that the donor disables
   `ravine_medium` (S4 §7 Q2)?
9. Which frame/seed/config produced the owner's reported white marks? The
   supplied P0 PNG contains none (S2 §1), so that attribution stays inferred.
10. Donor parity of hue, grain, relief silhouette and luma — blocked on a donor
    GPU A/B; no parity claim.

---

## 6. Summary

Read-only QA of the relief-stamps dump probe. **Nothing was verified at runtime.**
The owner report `RELIEF_ENABLE_01.md` has not landed; `variant3d/config.json:18`
does carry `"relief_stamps": true` (uncommitted), but the dump probe that was
meant to prove marker emission never finished: job **521**
(`reliefenabl01-dump`) ran 190.212 s against a 180.0 s hard timeout, was killed
(`exit -9`, stderr `[runner] KILLED after 180.0s (hard timeout)`), and left no
artifact at the requested temp path. Therefore **no `relief_stamps` array, no
`plt2` centre, and no entry count can be reported** — runtime is UNVERIFIED and
no values were invented. Job **520** (`reliefenabl01-smoke`) did pass, but it is
a `--check-only` parse check (`exit 0`, 0-byte stderr, `SCRIPT ERROR == 0`) and
cannot prove emission. `k_ravine_1` remains **BLOCKED**; **no visual hill A/B
exists**, and donor parity remains UNVERIFIED. The next step belongs to an owner
with runner permission: re-run the dump with a timeout above the observed run
time, then assert the key, `plt2` centres/counts, `stats.relief_grid.applied`,
height-range shift and a real-dump-fed fixed-camera capture. This QA submitted
no job and edited no file other than this report.

---

*End of QA-RELIEF-DUMP-01. Read-only verification; no code/config/asset/PNG/JSON/git edit, no Godot job, no dump probe, no donor access, no ladder advancement.*
