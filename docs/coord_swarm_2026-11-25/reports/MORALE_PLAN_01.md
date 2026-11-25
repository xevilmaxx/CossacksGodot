---
id: MORALE-PLAN-01
title: "Plan: removal / quarantine of invented morale, rout, XP and famine constants in the port"
date: 2026-11-25
status: DELIVERED__PLAN_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_DONOR_COPY
scope: "Read-only planning. This report is the ONLY file written. No port .gd/.json/.cfg/asset/test file edited; no Godot runner job submitted; no donor file opened, executed or copied; no test assertion weakened."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
output: "docs/coord_swarm_2026-11-25/reports/MORALE_PLAN_01.md"
labels: [observed, derived, inferred, UNVERIFIED]
label_key: "observed = literal bytes/lines read this pass (or a named prior pass that read them) | derived = arithmetic/control-flow over observed values | inferred = best reading, not provable from readable data | UNVERIFIED = absent or not provable without donor code / a fresh run"
verification_passes: 3
donor: "C:\\Games\\Cossacks 3 (READ-ONLY; NOT opened this pass — donor path:line facts are cited second-hand from DFORM-01 and DEC-02, which fresh-read them in two independent earlier passes)"
primary_port: "variant3d/scripts/*.gd + variant3d/config.json (3D variant; game.gd is free per task context)"
secondary_port: "app/scripts/*.gd + app/config.json (2D mirror, same inventions at different line numbers)"
gate_baseline: "variant selftest 29/29 + uitest 17/17 + clean; 2D app/** gates untouched (TEST_MATRIX.md:27,65-68)"
---

# MORALE-PLAN-01 — plan: quarantine / removal of invented morale, rout, XP and famine constants

## 1. Goal and stance

DEC-02 and DFORM-01 proved the donor has **no numeric morale**. Everything morale-like in the
donor is one of three non-morale mechanics:

1. **squad auto-disband** on `count < 0.25 * basecount`, rank-and-file only, **human players only**
   (`dmscript.global:156`; `units/global.inc/progress.inc:5-35,174-175`; `lib/squad.script:98-107`);
2. **shooter kiting** as a *move-order mode* `gc_obj_order_move_mode_runaway = 2`, `runawaydelay=1.3`,
   `runawaydist=3.5` (`dmscript.global:198-199,657`; `lib/unit.script:7175-7238,7364-7368`);
3. **AI army-level** retreat by force comparison with an 8 s battle cooldown
   (`dmscript.global:478`; `progresswarai.inc:1122,2400-2475,2799-2832`).

Donor famine is a **probability death roll** (`floor(random*32768) < 50/12/5` by difficulty,
gated by `gProfile.bFamine`; `unit.inc/nothing.inc:450-496`; `lib/misc.script:494-498`), **not** a
grace timer plus HP drain.

The port's numeric morale, rout state, morale shock, squad XP/veteran bonus and famine grace+HP-drain
are inventions sourced from a wiki (RB S13, `docs/research/RB_MECHANICS.md:34,69,74,87,231-238`) and a
"video pass" estimate (`variant3d/scripts/data.gd:81-83`). This document plans their **quarantine and
orderly removal**. It changes no code.

**Design rule adopted here:** do not delete behaviour first. Add labels and a default-preserving
gate, verify gates, then remove behaviour one atomic ticket at a time. The `0.25` in
`MORALE_ROUT_THRESHOLD=25.0` is a *coincidental* decimal match with the donor's `0.25` disband count
fraction — it is **not** donor provenance and must never be cited as such `[observed + derived]`.

---

## 2. Sources (all read this pass, none edited)

| # | Source | Role / label |
|---|---|---|
| S1 | `docs/coord_swarm_2026-11-25/reports/DFORM_01_formations_morale.md` §"Morale verdict + evidence" (`:149-218`), corrections `:388-395`, gaps `:356-375`, open Qs `:405-425` | Donor verdict: no numeric morale; whole-tree 2,559 files / 373 code files, 0 code hits for morale/rout/panic/flee/veteran/experience; only `fear` is an AI bool. Second-hand fresh donor read, **double-verified across two methods** (DEC-02 corpus + DFORM whole-tree). |
| S2 | `docs/coord_swarm_2026-11-25/reports/DANIM_01_action_ranges.md` | **Read as required; not relevant to morale/famine.** Its §4.2/§8.3 show donor `reaction` is an *animation action name*, not a morale state; no morale conclusion is drawn from it. Keep `PORT APPROXIMATION` discipline precedent (`:550-576`). |
| S3 | `docs/coord_swarm_2026-11-25/decomp/DEC_02_scripts.md` §D-07 `:559-575`, §D-08 `:639-652`, §D-10 `:678-713`, §6 `:924-948`, §7 correction 8 `:984-986`, §8 `:995-1008` | Donor disband/hold/runaway/famine-roll citations; port divergence rows: XP, famine "WRONG MODEL", disband/hold MISSING. Same verdict as S1, independently derived. |
| S4 | `docs/audit/AI_SURVIVAL_DIAG.md` C12 `:66`, C15–C16 `:69-70`, bottom line `:96-103`, open Q5 `:168` | Port famine grace+HP-drain and gold-famine morale drain; links famine death → OR-based victory → "AI died on its own". Gate-risk evidence. |
| S5 | `docs/research/RB_MECHANICS.md` §2 rows `:69,70-71,74,87,103`, G-13 `:231-238`, "explicitly unverifiable" `:279-281` | Shows every invented number is marked *estimated* or wiki-sourced, not donor-sourced. Confirms S1 correction that S13 is UNVERIFIED against donor plaintext. |
| S6 | `variant3d/scripts/data.gd`, `config.gd`, `game.gd`, `main.gd`, `world.gd`, `hud.gd`, `world3d_fx.gd`, `selftest.gd`, `uitest.gd`, `ai.gd` (grep + read + Python, **3 independent passes**) | All port line numbers and gate dependencies below. |
| S7 | `variant3d/config.json`, `app/config.json` (read + Python + grep) | Live config keys and line numbers. |
| S8 | `app/scripts/data.gd`, `config.gd`, `game.gd`, `app/config.json` (grep + Python) | 2D mirror of the same inventions; needed for gate-risk scope. |
| S9 | `docs/coord_swarm_2026-11-25/TEST_MATRIX.md:27,65-75` | Gate definition and runner syntax `python variant3d\tools\godot_runner.py run --id <ticket>-<row> --timeout <s> -- ...`. |
| S10 | `docs/coord_swarm_2026-11-25/reports/SEASON_PLAN_01.md` | Format / claim-label precedent for a plan-only report with second-hand donor citations. |

**Verification discipline (3 passes):** (P1) keyword grep over `variant3d/scripts/*.gd`; (P2) targeted
`read` of each exact block; (P3) independent Python 3.14 byte/latin-1/utf-8 line-index read. All three
agree on every port value and line quoted below. Donor claims come from two independent prior passes
(S1, S3); **no fresh donor read was performed this task** — residual UNVERIFIED for the compiled PE
only (S1 open Q7).

**Line-number caveat found and resolved:** one early directory-level grep reported `variant3d/config.json`
morale keys at `:141/142/147/148`. A targeted re-grep, a direct `read` and a Python index read all agree
on **`:102/103/108/109`**. The first numbers were discarded as a tool artifact. This is why the table
uses only triple-agreed numbers `[observed]`.

---

## 3. Invented-value table

Labels in the last two columns apply to the *donor truth* and *risk* statements respectively. All
"port file:line" entries are `[observed]` in 3 passes. `v3` = `variant3d/`, `2D` = `app/`.

| # | Invented value | Port file:line | Donor truth (label) | Recommended action | Risk to gates (label) |
|---:|---|---|---|---|---|
| 1 | `MORALE_BASE = 70.0` | v3 `scripts/data.gd:84`; `scripts/config.gd:156,621`; `config.json:102`. 2D mirror `data.gd:80`, `config.gd:503`, `config.json:98` | **No donor equivalent.** Numeric morale has 0 code hits in 373 code files; all narrative hits are locale text. `[observed, two prior passes]` | **Relabel** `PORT APPROXIMATION — INVENTED`; keep config-driven; do not delete in first ticket. | **HIGH if deleted/default changed**: selftest and 3 display sites use `e.get("morale", 70.0)` fallback (`selftest.gd:401`, `world.gd:3374`, `hud.gd:982`, `game.gd:5183`). `[observed]` |
| 2 | `MORALE_ROUT_THRESHOLD = 25.0` | v3 `data.gd:85`; `config.gd:157,622`; `config.json:103`; used `game.gd:5012,5016`. 2D `game.gd:4814,4818` | **No donor equivalent.** Donor disband uses a *count fraction* `0.25`, not a morale score: `count < basecount*0.25`, human-only. `[observed]` | **Relabel** + gate; never cite the `0.25` match as donor parity. Later: remove with rout state. | **HIGH**: toggles `routing`, which `ai.gd:855-860` counts to cap military training; also decides the selftest `morale` step. `[derived from observed control flow]` |
| 3 | Officer aura `MORALE_OFFICER_RADIUS=12.0`, `MORALE_OFFICER_BONUS=20.0` | v3 `data.gd:86-87`; `game.gd:3757,5002`. 2D RB rows `RB_MECHANICS.md:70` | **No donor equivalent.** Donor officers are squad slot 0 (fallback slot 1) and carry formation bonuses snapshotted at set-time (`squad.script:7-28`; `player.script:809-812`; `miscext2.script:347-354,421-431`); there is no morale stat for an aura to modify. `[observed + inferred]` | **Relabel** `PORT APPROXIMATION`; add config keys (currently hard-coded); gate before removal. | **MED**: selftest `morale` step recovers from 10 using this bonus (`selftest.gd:397-407`), but base recovery alone also clears rout over 10 s — do not rely on that; keep defaults. `[derived]` |
| 4 | Drummer aura `MORALE_DRUMMER_RADIUS=10.0`, `MORALE_DRUMMER_BONUS=10.0` | v3 `data.gd:88-89`; `game.gd:3767,5004`. 2D RB rows `RB_MECHANICS.md:71` | **No donor equivalent** (same reasoning as #3). Drummer is squad slot 1 with slot-0 fallback, not a morale aura. `[observed + inferred]` | **Relabel** + config + gate. | **LOW–MED**: no direct gate assertion; affects `effective_speed` only via `DRUMMER_SPEED_BONUS`, not morale. `[observed]` |
| 5 | `MORALE_LOW_HP_PENALTY=20.0` + hard-coded `hp < max_hp*0.3` condition | v3 `data.gd:90`; `game.gd:5005-5006` | **No donor equivalent.** No unit morale field exists. `[observed]` | **Relabel**; make the `0.3` threshold configurable with the gate ticket. | **LOW**: no gate assertion on the low-HP penalty. `[observed]` |
| 6 | `MORALE_FAMINE_PENALTY=15.0` | v3 `data.gd:91`; `game.gd:5007-5008` | **No donor equivalent.** Donor famine is a death roll, not a morale modifier. `[observed]` | **Remove** together with the famine-model ticket (#12), not before. | **LOW** in isolation; coupled to famine gates. `[observed]` |
| 7 | Morale shock `−4.0` on every hit | v3 `game.gd:5212`; 2D `game.gd:5014` | **No donor equivalent.** Donor has an animation action `reaction` (`DANIM_01` §4.2), not a morale value. `[observed]` | **Relabel** now; **remove** behind the same gate as #1/#2. | **LOW**: shock path is not exercised by the selftest `morale` step (it spawns a unit and sets morale directly). `[observed]` |
| 8 | Kill-area morale shock `−6.0` within `10.0` m | v3 `game.gd:5237-5242`; 2D `game.gd:5044` | **No donor equivalent.** `[observed]` | Same as #7. | **LOW**. `[observed]` |
| 9 | Rout re-entry margin `+25.0` above threshold; timeout `12.0` s; speed `×1.35` | v3 `game.gd:5016,5043,3776` | Donor's nearest behaviour is move-order mode 2 with `runawaydelay=1.3`, `runawaydist=3.5` — a deterministic movement order with **no HP/threshold/morale variable**. `[observed]` | **Relabel** `PORT APPROXIMATION`; later replace with donor move-mode semantics, never "morale rout". | **MED**: rout duration feeds `ai.gd:855-860` training cap; changing it alters CLI soak population. `[derived]` |
| 10 | Rout home search `25.0` m / stop `4.0` m / step `6.0` m | v3 `game.gd:5022,5037,5042` | Donor kiting places a point on the line away from threat, clamped `0.25` inside map edge (`unit.script:7199-7237`). `[observed]` | **Relabel**; bundle with #9, do not delete first. | **LOW**. `[observed]` |
| 11 | Squad XP/veteran: `SQUAD_XP_PER_KILL=1.0`, `SQUAD_XP_PER_BONUS=2.0`, `SQUAD_XP_CAP=3`; `_award_squad_xp`, `_squad_veteran_bonus` add up to +3 to **each** donor tuple field | v3 `data.gd:560-562`; `game.gd:3253-3257,3262-3278,5216` (applied in `_formation_atk`/`_formation_def` at `:5131,5200,5228`). 2D `data.gd:540-542`; `game.gd:3073-3080` | **No donor equivalent.** `experience`/`veteran` = 0 code hits; donor bonuses are fixed per `formations.cfg` and snapshotted onto the squad. RB S13 is UNVERIFIED against donor plaintext. `[observed, two prior passes]` | **Remove** as a dedicated later ticket (or gate off first). This is the cleanest pure invention: no donor model to preserve. | **LOW**: selftest `formation_bonus` uses freshly spawned units (`selftest.gd:500-513`), so `vet=0` and `fbonus==2 / fhold==7` are unaffected. Confirm with the full gate. `[observed]` |
| 12 | Famine `FAMINE_GRACE_S=120.0`, `FAMINE_DRAIN_PER_S=0.3` (warning at 120 s, then `0.3 hp/s` to every living unit) | v3 `data.gd:100-101`; `config.gd:162-163,627-628`; `config.json:108-109`; `game.gd:4319,4325`. 2D `data.gd:96-97`, `game.gd:4121,4127`, `config.json:104-105` | **WRONG MODEL, not "no mechanic".** Donor famine exists but is `roll := floor(random*32768)`; die if `<50` (difficulty>1 or online), `<5` (easy), `<12` (normal), gated by `gProfile.bFamine`; no grace timer, no HP drain. `[observed]` | **Relabel** `PORT APPROXIMATION — WRONG MODEL` now; **replace with the donor roll** in a separate ticket (DEC-02 §8 rank 2). Keep constants until then. | **HIGH**: `AI_SURVIVAL_DIAG` C12/C15/C16 link famine death + OR-based elimination to an instant human victory; CLI soak watches population/winner. Gate-first; never change defaults in step 1. `[derived + inferred]` |
| 13 | Gold-famine morale drain: after `60.0` s, `−10.0/s` morale to gold-eating units | v3 `game.gd:4327-4331` (both literals hard-coded, no `Data` constant) | **No donor equivalent.** Donor gold shortage drives *rebellion*, a mercenary defection probability roll (`<6000/200/100`), not morale drain. `[observed]` | **Remove** with #12; no separate ticket needed. | **LOW**. `[observed]` |
| 14 | Presentation of invented state: `rout` FX event, morale pip, HUD morale/`ROUTING!`/`FAMINE!` | v3 `main.gd:1735-1736`; `world3d_fx.gd:103,946,1015`; `world.gd:3372-3380`; `hud.gd:982-984,1013-1014` | **No donor equivalent** (no rout/morale state to display). `[observed]` | **Do not delete first.** Add a `PORT APPROXIMATION` comment; retire only after #1/#2/#9 are gated or removed. | **LOW**: no gate assertion reads these pixels/strings; `t_hud_fidelity.gd:163-168` only sets a HUD flag manually (S4 `:46`). `[observed]` |

**Adjacent, explicitly out of scope — do not bundle:** the port applies the donor hold bonus
instantly via `e["hold"]` (`game.gd:509-511`; selftest asserts `fhold == 7` instantly at
`selftest.gd:509-513`), whereas the donor ramps it over 37.5 s with a `hold ≠ normal` gate
(`dmscript.global:180`; `progress.inc:160-170`; DFORM gap rank 2 `:361`). Adding that ramp would
**break the `formation_bonus` selftest step** unless the step is redesigned in the same atomic ticket.
Keep it as a separate ticket, not part of MORALE-PLAN work. `[observed + derived]`

---

## 4. Minimal safe first ticket

**MORALE-02 — label-and-gate quarantine (no behaviour change).**

- **Owning file: `variant3d/scripts/data.gd` only.** No other file is edited by this ticket.
- **Change (additive only):**
  1. Replace the existing vague header comment at `data.gd:81-83`
     (`"All estimated"`) with an explicit per-block banner:
     `PORT APPROXIMATION — INVENTED, NO DONOR EQUIVALENT (DEC-02 §7.8; DFORM-01 §Morale verdict)`.
     Apply it to the morale/aura block `data.gd:84-95`, the famine block `:100-101`, and the XP block
     `:557-562`.
  2. Add one config-ready default:
     `static var PORT_MORALE_FAMINE_ENABLED := true` — an **additive** switch that preserves all
     current values and behaviour. It is intentionally *not read by any consumer yet*; wiring is
     MORALE-03. This is a quarantine marker, not a behaviour change. `[inferred — design choice]`
- **Deliberately NOT in this ticket:** no edit to `game.gd`, `config.gd`, `config.json`, `selftest.gd`,
  `uitest.gd`, `hud.gd`, `world.gd`, or `app/**`. No constant renamed (renaming would force consumer
  edits and re-open gate risk).
- **Why this is the safe minimum:** every gate dependency listed in §3 rows 1, 2, 3, 11 and 12 stays
  byte-identical in behaviour, so selftest `29/29` and uitest `17/17` are expected unchanged
  `[derived]`. The misleading "estimated / video pass" provenance is removed from the source of
  truth before any deletion is attempted.
- **Expected job:** `MORALE-02` full-gate verification —
  `python variant3d\tools\godot_runner.py run --id MORALE-02 --timeout <s> -- ...` running the variant
  **selftest 29/29 + uitest 17/17 + clean** (S9 `:27,65-71`). No donor job, no capture job.

**Acceptance:** selftest `29/29`, uitest `17/17`, no `ERROR`/`SCRIPT ERROR`/`stuck`, and a grep showing
the new banner above all three constant blocks. If any gate moves, revert the comment-only ticket and
re-plan — a label edit must never be able to move a gate.

---

## 5. Recommended atomic tickets (ordered; each one file-group, one job)

| Ticket | Owning file(s) | Change | Donor citation | Gate / expected job |
|---|---|---|---|---|
| **MORALE-02 (FIRST)** | `variant3d/scripts/data.gd` | Explicit PORT APPROXIMATION banners + `PORT_MORALE_FAMINE_ENABLED := true`; no behaviour change | DEC-02 §7.8 `:984-986`; DFORM-01 `:202-211` | Full selftest+uitest, expected unchanged |
| MORALE-03 | `variant3d/scripts/config.gd`, `variant3d/config.json` | Add additive `economy.port_mechanics.morale_famine_enabled` (default `true`) read into the MORALE-02 flag; also expose the currently hard-coded aura radii/bonuses, low-HP `0.3`, shocks `−4/−6`, rout margin `+25`/timeout `12` as config keys with today's values. Defaults preserved. | DFORM-01 `:204-211` (no donor values to import) | Full selftest+uitest; diff of config output must be value-identical |
| MORALE-04 | `variant3d/scripts/game.gd` (free) | Replace famine grace+HP-drain `game.gd:4319,4325` and gold drain `:4327-4331` with the donor probability roll, behind the MORALE-03 flag (default keeps current model for one gate run; flip default only after green) | DEC-02 D-10 `:702-713`; `unit.inc/nothing.inc:450-496`, `lib/misc.script:494-498` | Full gates + a 300 s CLI soak asserting no unexpected population collapse / winner change (S4 acceptance `:142-150`) |
| MORALE-05 | `variant3d/scripts/game.gd` | Remove XP/veteran path: `_squad_veteran_bonus` `:3262-3267`, its application `:3253-3257`, `_award_squad_xp` `:3271-3278` and call `:5216`; drop `SQUAD_XP_*` from `data.gd` in the same atomic change | DEC-02 §6 `:932`; DFORM-01 `:210`; RB S13 UNVERIFIED `:388-391` | Full gates; `formation_bonus` step must still read `+2 / +7 / +0` |
| MORALE-06 | `variant3d/scripts/game.gd` | Retire morale state and rout: unit field `:2195`, `_update_morale`/`_tick_rout` `:4995-5044`, shock `:5212,5237-5242`, speed `:3776`, reset `:3139`, tick calls `:4727,4729`; gate off first, then delete. Optionally add donor-style 25% human squad disband **additively** (not as a replacement for delete) | DFORM-01 `:188-194`; DEC-02 D-07 `:559-575`, D-08 `:639-652` | Requires **selftest `morale` step `397-407` to be retired or rewritten in the same ticket**; do not leave it failing |
| MORALE-07 | `app/scripts/**` + `app/config.json` | Mirror the labels/gates of MORALE-02..06 into the 2D app at its own line numbers (S8) | Same donor sources | 2D gates must stay green; run only after 3D tickets land |

**Sequencing rule:** MORALE-02 → gate → 03 → gate → 04 → gate → 05 → gate → 06 → gate → 07. Stop at the
first failing gate; do not rerun hoping for green (S9 `:60-61`).

---

## 6. Risks

1. **Gate coupling is real, not theoretical.** The selftest has a dedicated `morale` step in `STEPS`
   (`selftest.gd:11`) and a `formations_morale` group (`:23`) that spawns a unit with `morale=10`,
   `routing=true`, spawns an officer and asserts recovery (`:397-407`). Any ticket that deletes morale
   state, zeroes `MORALE_BASE`, or removes the officer bonus without rewriting that step drops selftest
   to 28/29. `[observed]`
2. **AI behaviour depends on rout state.** `ai.gd:855-860` counts `routing` units and caps military
   training; shortening or removing rout changes army size and therefore CLI soak `winner`/population
   assertions in `AI_SURVIVAL_DIAG:142-150`. `[derived]`
3. **Famine is the highest-risk item.** It is already a diagnosed AI death driver
   (`AI_SURVIVAL_DIAG` rank 1–5, `:87-101`) and interacts with the OR-based elimination rule at
   `game.gd:5681`. A "fix" that removes the drain without adding the donor roll could make the AI
   *more* likely to win by starvation-free stalling, or change soak outcomes. Never change famine in
   the first ticket. `[derived + inferred]`
4. **Donor `0.25` ≠ port `25.0`.** Treating `MORALE_ROUT_THRESHOLD=25` as donor parity because both
   contain "25" would reintroduce the exact invention this plan removes. `[observed + derived]`
5. **Two port copies.** `app/scripts` and `variant3d/scripts` carry the same inventions at different
   line numbers (§3). Fixing only the 3D variant leaves the 2D gates carrying invented mechanics;
   fixing both in one ticket doubles blast radius. Sequence them (MORALE-07 last). `[observed]`
6. **Adjacent hold-ramp trap.** Bundling the 37.5 s hold ramp with morale work breaks
   `formation_bonus` (`selftest.gd:509-513`). Keep separate. `[derived]`
7. **Evidence ceiling.** All donor absence claims are from readable scripts/configs only. The
   compiled PE was not executed or disassembled; a binary-only morale path remains possible but is
   **UNVERIFIED** and, given two independent readable-source scans, low-confidence. `[UNVERIFIED]`
8. **Ownership.** Task context says `game.gd` is free (TRN-DATA terminated), but `data.gd`,
   `config.gd` and `config.json` ownership for MORALE-02/03/07 is not confirmed in this pass. Confirm
   on the board before assigning those tickets. `[UNVERIFIED]`

---

## 7. Open questions

1. **UNVERIFIED — compiled donor PE.** Does any binary-only morale/veteran path exist? Needs donor
   code or a runtime trace; not performed (S1 Q7).
2. **Design decision — keep XP at all?** RB G-13 was wiki-derived and explicitly UNVERIFIED against
   donor plaintext (S5 `:388-391`, S3 §7 correction 8). Did any owner intentionally keep +3 XP as a
   *design* addition rather than parity? If yes, relabel as `DESIGN ADDITION`, not `INVENTED PARITY`.
3. **Ownership grant** for `variant3d/scripts/data.gd`, `config.gd`, `config.json` and the `app/**`
   mirror (risk 8).
4. **Famine default flip timing.** Should MORALE-04 ship with the new roll default-OFF for one green
   gate run, or default-ON with a rollback path? Needs owner preference; this plan assumes default-OFF
   then flip.
5. **Does the 2D `app/**` gate set run the same selftest steps?** The mirrors are line-shifted but
   textually equivalent for the constants quoted; a fresh read of `app/scripts/selftest.gd` is
   advisable before MORALE-07 (this pass only confirmed `app/scripts/game.gd` constants via S8).
6. **Rout FX/HUD retirement.** Should `world3d_fx.gd` `"rout"` and `hud.gd` `"ROUTING!"` be deleted in
   MORALE-06 or left as dead-but-labelled presentation? No gate asserts them; owner preference.
7. **Line drift.** DFORM-01 `:373-375` already warned that lines shift; this pass found the same
   inventions at `v3` lines distinct from the 2D lines quoted in DEC-02/DFORM. Re-read immediately
   before each edit; do not apply old line numbers from S1/S3/S5 verbatim.

---

## 8. Summary

- **No code changed.** Exactly one artefact written: this report.
- **Donor truth (double-verified via DEC-02 + DFORM-01, second-hand this pass):** no numeric morale,
  rout, panic, flee, veteran or XP mechanic in readable donor scripts; disband is `count < 0.25*base`
  (rank-and-file, human-only); shooter retreat is move-order mode 2 (1.3 s / 3.5 tiles); famine is a
  difficulty-scaled death roll, not a grace timer + HP drain. `[observed]`
- **Port audit (3 independent passes):** 14 invented constructs catalogued in §3 across
  `variant3d/scripts/data.gd:84-101,560-562`, `config.gd:156-163,621-628`, `config.json:102-109`,
  `game.gd:2195,3139,3253-3278,3757,3767,3776,4319,4325,4327-4331,4727-4729,4995-5044,
  5131,5200,5212,5216,5228,5237-5242,5681`, plus presentation sites and the 2D mirror.
- **Minimal safe first ticket:** MORALE-02, label-and-gate only in `variant3d/scripts/data.gd`;
  additive `PORT_MORALE_FAMINE_ENABLED := true`, no consumer edits, no default change. Expected full
  variant selftest `29/29` + uitest `17/17` unchanged. `[derived]`
- **Order:** label → wire config → famine roll → XP removal → morale/rout retirement → 2D mirror.
  Never delete behaviour before the gate and the dependent selftest step are handled.
- **Biggest risk:** famine and morale/rout are wired into AI training caps and the victory rule; a
  deletion-first approach would break gates and could invert the very "AI died on its own" symptom
  the port is trying to fix.
