---
id: MORALE-02
title: "Label-and-gate the invented morale / famine / XP constants (safe first ticket)"
date: 2026-11-25
status: DONE — label-and-gate only; NO behaviour change; NO consumer edit
scope: "Exactly two files touched: variant3d/scripts/data.gd (edited) and this report (written). No game.gd, ai.gd, config.gd, config.json, selftest.gd, uitest.gd, hud.gd, world.gd, world3d*.gd, app/** or donor file edited. No queue mutation, no weakening, no direct godot invocation."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
output: "docs/coord_swarm_2026-11-25/reports/MORALE_02.md"
backup: "inbox/backup/data.gd.bak-MORALE02"
labels: [observed, derived, inferred, UNVERIFIED]
label_key: "observed = literal bytes read this pass | derived = arithmetic/control-flow over observed | inferred = strong but indirect | UNVERIFIED = no plaintext evidence"
donor: "C:\\Games\\Cossacks 3 (READ-ONLY; NOT opened this pass — donor path:line facts cited second-hand from DFORM-01 and DEC_02, which read them in independent earlier passes)"
---

# MORALE-02 — label-and-gate the invented morale / famine / XP constants

## 1. Stance and result

This is the minimal safe first ticket from `MORALE_PLAN_01.md` §4. It **labels** the invented
morale/aura, famine and XP constants in `variant3d/scripts/data.gd` with explicit
`PORT APPROXIMATION — INVENTED` banners carrying donor-truth citations, and adds **one** additive,
unread marker `static var PORT_MORALE_FAMINE_ENABLED := true`. No value, default, logic or consumer
was changed. Behaviour is provably identical (§5).

Per the plan's design rule, behaviour is **not** deleted first: rout still feeds `ai.gd:855-860`,
famine still interacts with the OR-based victory rule at `game.gd:5681`, and the selftest still has
a dedicated `morale` step (`selftest.gd:397-407`).

## 2. Donor truth citations (second-hand, read this pass from the two named reports)

| Claim | Citation | Label |
|---|---|---|
| No numeric morale / rout / panic / flee / veteran / experience. Whole-tree scan: 2,559 files, 373 code files → 0 code hits; the 93/233/247/831 morale-family hits are mission-narrative locale text. | `reports/DFORM_01_formations_morale.md:149-176` ("Morale verdict + evidence"); cross-checked `decomp/DEC_02_scripts.md:639-652` (4.37 MB corpus) | observed in two prior passes; residual UNVERIFIED for the compiled PE only |
| Donor squad disband is a **count fraction**: `count < basecount*0.25`, rank-and-file only (`_squad_GetBaseUnitCount` excludes officer+drummer), **human players only**. | `dmscript.global:156`; `units/global.inc/progress.inc:5-35,174-175`; `lib/squad.script:98-107` — `DFORM_01:188-194`, `DEC_02:650-652` | observed |
| Shooter "retreat" is a **move-order mode** `gc_obj_order_move_mode_runaway=2`, `runawaydelay=1.3`, `runawaydist=3.5`, with a point placed away from threat and clamped 0.25 inside the map edge — **no HP/threshold/morale variable**. | `dmscript.global:198-199,657`; `lib/unit.script:7175-7238,7364-7368` — `DFORM_01:180-186`, `DEC_02:639-649` | observed |
| The only `fear` hit is one AI local bool used to skip target selection, not a unit stat. | `progresswarai.inc:2799,2817,2832` — `DFORM_01:172-176` | observed / derived |
| Donor famine **exists but is a probability death roll**: `roll := floor(random*32768)`; die if `< 50` (difficulty>1 or online) / `< 12` (normal) / `< 5` (easy), gated by `gProfile.bFamine`. **No grace timer, no HP drain.** | `unit.inc/nothing.inc:450-496`; `lib/misc.script:494-498`; `lib/player.script:270-322` — `DEC_02:678-713` (D-10), `DFORM_01:202-211`, `DEC_02:934` | observed |
| Donor formation bonus tuples are fixed per `formations.cfg` and snapshotted onto the squad at formation set; `experience`/`veteran` = 0 code hits, so no XP raises bonuses. RB S13 is UNVERIFIED against donor plaintext. | `lib/player.script:809-812`; `DFORM_01:105,202-211`; `DEC_02:932`; `docs/research/RB_MECHANICS.md:231-238` | observed (absence) + inferred; RB S13 UNVERIFIED |
| `MORALE_ROUT_THRESHOLD=25.0` is **not** donor parity: the "25" match with the donor `0.25` disband fraction is coincidental. | `MORALE_PLAN_01.md:41-44,170-171` | observed + derived |

All donor `path:line` facts above are cited second-hand from DFORM-01 and DEC_02 (fresh reads in two
independent earlier passes). No donor file was opened, executed or copied in this pass.

## 3. Before → after (all in `variant3d/scripts/data.gd`)

| Region | Before (original line) | After (current line) | Change |
|---|---|---|---|
| Vague header | `:81-83` "video-observed battle feel … **All estimated**, tunable in config.json" | `:81-98` explicit `PORT APPROXIMATION — INVENTED, NO DONOR EQUIVALENT` banner with DEC-02 §7.8 (`:984-986`) + DFORM-01 §Morale verdict (`:149-218`) citations, donor-truth summary, and the "do not delete/retune" warning | 3 comment lines replaced by 18 comment lines; **values untouched** |
| Morale / aura block | `:84-95` (MORALE_BASE 70.0, ROUT_THRESHOLD 25.0, OFFICER_RADIUS 12.0, OFFICER_BONUS 20.0, DRUMMER_RADIUS 10.0, DRUMMER_BONUS 10.0, LOW_HP_PENALTY 20.0, FAMINE_PENALTY 15.0, OFFICER_DAMAGE_BONUS 0.15, DRUMMER_SPEED_BONUS 0.12, PRIEST_HEAL_RADIUS 8.0, PRIEST_HEAL_PER_S 5.0) | `:99-110`, unchanged values, now under the §2 banner. PRIEST_HEAL_* explicitly noted as a video-pass estimate, **not** asserted donor-exact (no absence claim made for it). | comment only |
| Famine block | `:100-101` `FAMINE_GRACE_S=120.0`, `FAMINE_DRAIN_PER_S=0.3`, no banner | `:115-124` banner `PORT APPROXIMATION — INVENTED, WRONG MODEL (NO DONOR GRACE/HP-DRAIN)` with DEC-02 D-10 (`:702-713`, `:934`) + DFORM-01 (`:202-211`) and the donor roll; constants at `:125-126` unchanged | comment only |
| New quarantine marker | absent | `:127-131` explanatory comment + `:132` `static var PORT_MORALE_FAMINE_ENABLED := true` | **one additive line**; no consumer reads it |
| XP block | `:557-562` `SQUAD_XP_PER_KILL=1.0`, `SQUAD_XP_PER_BONUS=2.0`, `SQUAD_XP_CAP=3`, RB G-13 comment only | `:588-599` banner `PORT APPROXIMATION — INVENTED, NO DONOR EQUIVALENT` with DEC-02 §6 (`:932`) + DFORM-01 (`:210`) + RB S13 UNVERIFIED note; original RB G-13 comment and constants preserved at `:600-602` | comment only |
| File length | 1,577 lines | 1,617 lines | +40 net (43 inserted comment/constant lines, 3 old header lines removed) |

The banner string `PORT APPROXIMATION — INVENTED` is now grep-findable above all three constant
blocks (`data.gd:81`, `:115` [WRONG MODEL variant], `:588`).

## 4. Backup

- `inbox/backup/data.gd.bak-MORALE02` — byte-identical copy of the pre-edit file.
- Both pre-edit original and backup: SHA-256 `D131928661E1EC6D67A6E835A5752540757817C24D354C26C2ED1B641A918FE8`.
- Restore path: copy the backup back over `variant3d/scripts/data.gd` if any gate moves.

## 5. No-behaviour-change statement (explicit)

**This ticket changes no behaviour, no default and no consumer.** Evidence (`python` byte-level
comparison of backup vs. edited file, this pass):

- CRLF line endings preserved: 1,577 → 1,617 CRLF, with LF counts equal (no mixed endings).
- Non-comment code lines: 1,267 → 1,268.
- **Only** non-comment line added: `static var PORT_MORALE_FAMINE_ENABLED := true`.
- **No** non-comment line removed or modified (`difflib` code opcodes contain exactly one
  `insert` at index 62 and no other non-equal opcode).
- Every original `static var` value in the morale, aura, famine, market and XP blocks is
  byte-identical; no constant was renamed (renaming would force consumer edits and reopen gate risk).
- `PORT_MORALE_FAMINE_ENABLED` is inert: no `grep` hit outside `data.gd` itself, so flipping it alone
  cannot affect gameplay, selftest or uitest. It is a quarantine marker for MORALE-03..06, not a
  live switch. `[observed + derived]`

## 6. Validation jobs (variant runner only; unique ids; no queue mutation)

Runner spool `variant3d/.godot_queue`; `status` before submission: `pending=0`, `godot.lock=free`.

| Job id | Ticket | Command (after `--`) | wait / run | Result | Evidence |
|---|---|---|---|---|---|
| `morale02-smoke` | 508 | `--headless --path variant3d --check-only --script res://scripts/data.gd` | 0.00 s / 5.07 s | **END ok**, exit 0; stdout 75 B (Godot 4.7.2 banner only); stderr **0 B** ⇒ `SCRIPT ERROR == 0` | `variant3d/.godot_queue/results/00000508.json`, `00000508_morale02-smoke/{stdout,stderr}.txt` |
| `morale02-selftest` | 509 | `--headless --path variant3d -- --self-test variant3d/selftest.json` | 0.00 s / 210.32 s | **END failed**, exit 1 — see below | `variant3d/.godot_queue/results/00000509.json`, `00000509_morale02-selftest/{stdout,stderr}.txt` |

**Honest selftest attribution (two independent causes, neither from this ticket):**

1. **Artifact state is the known pre-existing red gate:** `variant3d/selftest.json` reads
   `"passed": false`, 29 steps, failed step `build` — detail "house built in 3.1 s of build time
   (cost 120 wood)". This is exactly the documented 28/29 `build` failure in
   `RUN_GUIDE.md:57,143`; it predates MORALE-02 and was not weakened, re-run for green, or edited.
   `MORALE_PLAN_01.md:129-131` expected 29/29, but the live RUN_GUIDE baseline is 28/29 — no
   change from this ticket is claimed.
2. **The job's own exit 1 is a `SCRIPT ERROR` in a different, concurrently-edited file:** stderr
   ends with `SCRIPT ERROR: Invalid call. Nonexistent function 'new' in base 'GDScript'.` at
   `_setup_full_game (res://scripts/main.gd:1110)`, followed by
   `watchdog: wall-clock limit reached, forced exit`. During this run `git status` showed
   **other workers** modifying `variant3d/scripts/main.gd`, `selftest.gd` and `hud.gd`, with new
   backups `main.gd.bak-LOADASYNC01`, `selftest.gd.bak-BUILDSTEP01`, `hud.gd.bak-UITOPBAR01`
   appearing mid-run. `main.gd` now contains a new async-load path (`_do_async_load`,
   `load("res://scripts/world3d.gd")` then `script.new()`), which is the plausible source of the
   GDScript `.new()` error. `[inferred — concurrent edits, not verified as a root cause]`
   This is **not** attributable to `data.gd`: the dedicated compile check of `data.gd` (ticket 508)
   was clean with 0 B stderr, and §5 proves only an additive constant changed there.

Not run (out of ticket scope): uitest, `assert_clean.py`, capture ladder, donor jobs, any `ack` /
`reset` / `doctor`, any direct `godot` call. The failed job was **not** re-run hoping for green.

## 7. Follow-up tickets / banners outside this file (list only, no edits made)

Per the ownership rule, no planned banner that belongs to another file was applied. Outstanding
work, ordered as in `MORALE_PLAN_01.md` §5:

- **MORALE-03** (`config.gd`, `config.json`): add `economy.port_mechanics.morale_famine_enabled`
  (default `true`) wired into `PORT_MORALE_FAMINE_ENABLED`; expose the hard-coded aura radii/bonuses,
  low-HP `0.3`, shocks `−4/−6`, rout margin `+25`/timeout `12`. Defaults preserved; config diff
  must be value-identical. Config keys live at `config.gd:156-163,621-628`, `config.json:102-109`.
- **MORALE-04** (`game.gd`): replace famine grace+HP-drain (`:4319,4325`) and gold-famine drain
  (`:4327-4331`) with the donor probability roll behind the MORALE-03 flag; 300 s CLI soak.
- **MORALE-05** (`game.gd` + `data.gd` coordination): remove XP/veteran path
  (`_squad_veteran_bonus :3262-3267`, its application `:3253-3257`, `_award_squad_xp :3271-3278`,
  call `:5216`) and drop `SQUAD_XP_*` from `data.gd` in the same atomic change
  (`formation_bonus` selftest must still read `+2/+7/+0`).
- **MORALE-06** (`game.gd` + `selftest.gd` in the same ticket): retire morale state and rout
  (unit field `:2195`, `_update_morale`/`_tick_rout :4995-5044`, shocks `:5212,5237-5242`, speed
  `:3776`, reset `:3139`, tick calls `:4727,4729`); rewrite/retire the `morale` selftest step
  (`selftest.gd:397-407`) so it cannot drop to 28/29.
- **MORALE-07** (`app/**` + `app/config.json`): mirror labels/gates into the 2D app
  (`app/scripts/data.gd:80-81,96-97,540-542`; `app/config.json:98-105`) only after the 3D tickets land.

**Planned banners deliberately NOT applied here because they sit outside the owned file:**

| Invented construct (MORALE_PLAN §3 row) | File:line (plan) | Owner ticket |
|---|---|---|
| #7 morale hit shock `−4` | `game.gd:5212` | MORALE-06 |
| #8 kill-area shock `−6` within 10 m | `game.gd:5237-5242` | MORALE-06 |
| #9 rout re-entry `+25`/12 s/×1.35 | `game.gd:5016,5043,3776` | MORALE-06 |
| #10 rout home 25/4/6 m | `game.gd:5022,5037,5042` | MORALE-06 |
| #13 gold-famine morale drain `−10/s` after 60 s | `game.gd:4327-4331` | MORALE-04 |
| #14 rout FX / morale pip / HUD strings | `main.gd:1735-1736`; `world3d_fx.gd:103,946,1015`; `world.gd:3372-3380`; `hud.gd:982-984,1013-1014` | MORALE-06 (owner preference) |
| #1/#2/#6/#12 config-side keys | `config.gd:156-163,621-628`; `config.json:102-109` | MORALE-03 |

**Explicitly out of scope:** the donor 37.5 s hold-mode ramp (`dmscript.global:180`;
`progress.inc:160-170`) must stay a separate ticket — bundling it breaks `formation_bonus`
(`selftest.gd:509-513`) (`MORALE_PLAN_01.md:98-103,176`).

## 8. Open questions

1. **UNVERIFIED — compiled donor PE.** No binary-only morale/veteran path was executed or
   disassembled; a residual binary-only path remains possible (DFORM Q7 / MORALE_PLAN Q1).
2. **Design decision:** is the +3 XP/veteran bonus a deliberate *design addition* rather than a
   failed parity attempt? If so, relabel `DESIGN ADDITION` in MORALE-05, not simply delete
   (MORALE_PLAN Q2).
3. **Ownership:** confirm ownership of `config.gd`, `config.json` and the `app/**` mirror before
   assigning MORALE-03/07 (MORALE_PLAN risk 8 / Q3).
4. **Famine flip timing:** should MORALE-04 ship the donor roll default-OFF for one green gate run,
   or default-ON with a rollback path (MORALE_PLAN Q4)?
5. **Gate wiring:** when should `PORT_MORALE_FAMINE_ENABLED` first be read (MORALE-03)? Until then
   it is deliberately inert.
6. **Concurrent swarm edits:** `main.gd` / `selftest.gd` / `hud.gd` were being edited by other
   workers during ticket 509. A fresh full gate (selftest + uitest + clean) should be run by the
   owning workers **after** those edits settle. Not attempted here — out of ticket scope.
7. **Pre-existing `build` step:** a `selftest.gd.bak-BUILDSTEP01` backup appeared mid-run; confirm
   whether another worker is fixing the documented 28/29 `build` failure before treating it as a
   stable baseline.
8. **PRIEST_HEAL_*** (in the covered `data.gd:84-95` block) is labelled a video-pass estimate only;
   no donor-absence claim was made for it. If a stricter label is wanted, it needs its own
   donor read and ticket.

## 9. Summary

- **Edited:** `variant3d/scripts/data.gd` only — three `PORT APPROXIMATION — INVENTED` banners
  (morale/aura `:81-98`; famine WRONG MODEL `:115-124`; XP `:588-599`) and one additive, unread
  `static var PORT_MORALE_FAMINE_ENABLED := true` (`:132`).
- **Written:** this report, `docs/coord_swarm_2026-11-25/reports/MORALE_02.md`.
- **No other file edited.** Donor read-only; no consumer, config, test, asset or `app/**` file
  touched; no gate weakened; no queue mutation; no direct `godot`.
- **Backup:** `inbox/backup/data.gd.bak-MORALE02` (SHA-256 verified identical to the pre-edit file).
- **No behaviour change:** proven by byte-level comparison — no code line removed/modified; the
  only non-comment insertion is the inert quarantine constant; CRLF preserved.
- **Jobs:** `morale02-smoke` ok/exit 0, 0 B stderr, `SCRIPT ERROR == 0`; `morale02-selftest`
  failed/exit 1 from a `SCRIPT ERROR` in concurrently-edited `main.gd`, while the selftest artifact
  remains the documented pre-existing 28/29 `build` red gate. Neither failure originates in this
  ticket's change; no re-run for green was attempted.
- **Next:** MORALE-03 → 04 → 05 → 06 → 07, stopping at the first failing gate; never delete
  behaviour before the gate and the dependent selftest step are handled.
