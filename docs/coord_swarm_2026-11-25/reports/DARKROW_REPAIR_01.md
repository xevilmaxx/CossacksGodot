---
id: DARKROW-REPAIR-01
title: "VERIFICATION ONLY — redundant-ticket closeout of the dark-row _m parse error"
owner: DARKROW-REPAIR-01 (repair builder, re-scoped by COORD to verification only)
date: 2026-11-25
status: CLOSED__REDUNDANT__NO_NEW_RUNNER_JOBS__NO_SOURCE_EDITS_RETAINED
scope: "Read-only verification against DARKROW_ALL_01.md, the seven on-disk atoms, their seven pre-existing DARKROWALL backups, and the seven existing darkrowall-* runner job artifacts. No new Godot job was submitted; no result JSON, harness, game code, P0, S1, config, manifest or other report was edited. Seven .bak-DARKROWREPAIR backup copies were made before a pre-notice edit; that one edit was reverted and the atom was hash-verified byte-identical to its pre-edit copy."
owns:
  - "docs/coord_swarm_2026-11-25/reports/DARKROW_REPAIR_01.md"
labels: [observed, derived, VERIFICATION, REDUNDANT, NO_WEAKENING]
verdict: "DARKROW-REPAIR-01 is REDUNDANT / CLOSED — DARKROW-ALL-01 already fixed the _m parse error and landed seven green --check-only jobs; no discrepancy found."
---

# DARKROW-REPAIR-01 — verification verdict

## 0. Re-scope notice

This ticket was opened from an earlier snapshot in which
`docs/coord_swarm_2026-11-25/reports/DARKROW_ALL_01.md` did not exist and
`QA_ATOM_STALE_02.md` recorded job 497's parse failure. COORD subsequently
notified that DARKROW-ALL-01 landed and had already fixed and re-checked the
error (ticket 501), and ordered VERIFICATION ONLY: no duplicate edits, no new
runner jobs unless a real discrepancy is found.

**No discrepancy was found. This ticket is redundant and is closed here.**

## 1. Root cause (with line cites)

| Item | Evidence | Label |
|---|---|---|
| Failing edit | Job 497 `darkrowall-t_terrain_mines-r1` stderr: `SCRIPT ERROR: Parse Error: Identifier "_m" not declared in the current scope.` / `at: GDScript::reload (res://tests/t_terrain_mines.gd:618)` / `Failed to load script` (`variant3d/.godot_queue/results/00000497_darkrowall-t_terrain_mines-r1/stderr.txt:1-4`). | observed |
| Why | P3 `t_terrain_mines.gd` has **no** `_m` dictionary. The mid-edit dark-row block at `:618` used `_m` as if it were the metrics dict carried by the other atoms; the atom instead records its diagnostic in a dedicated member. | observed |
| Fix already landed | `t_terrain_mines.gd:107` declares `var _full_width_dark_rows_diag: String = ""`; `:621` sets it to the N/A diagnostic; `:434` emits it in the result `"png"` object. No standalone `_m` token remains in the file except the comment at `:106`. | observed |
| Owner's own account | `DARKROW_ALL_01.md:137-142` — ticket 497 was a real self-introduced parse error, fixed by `_full_width_dark_rows_diag` at `:107,:434,:621`, re-checked once at ticket 501 (`END ok`). | observed |
| C2 enabling change (not a weakening) | `DARKROW_ALL_01.md:76,80-83` — C2's `check()` became `Variant cond` + optional `status` so the one record-only `null` row would not be a type error or be miscounted as a hard FAIL. Every pre-existing `bool`/no-status call still emits exactly `PASS`/`FAIL`. | observed |

## 2. On-disk `_m` audit — all seven atoms

Standalone token scan (regex `(?<![A-Za-z0-9_])_m(?![A-Za-z0-9_])`) plus declaration scan (`^\s*var\s+_m\b`), re-run after the re-scope notice:

| Atom | `var _m: Dictionary` declared | Uses of `_m` | Verdict |
|---|---|---|---|
| P1 `t_terrain_trees.gd` | `:216` | `:216,278,307,488,489,507,622,629,681,731-739,753,757,767,771,775,814,830,839-842,857,861,868,874,882-884,895,947,987-989` | declared before all uses — OK |
| P2 `t_terrain_shore.gd` | `:195` | `:195,263,354-356,478,479,613,638,660,689,690,694,770,771,786,787,796,820-823,839,851,853,865,885,895,902,909,910,920,932` | declared before all uses — OK |
| P3 `t_terrain_mines.gd` | none (by design) | only the comment at `:106`; real source is `_full_width_dark_rows_diag` (`:107,:434,:621`) | **parse error fixed** — OK |
| C1 `t_combo_trees_shore.gd` | `:200` | `:200,254,306,319,335,361,513,517,524,531,543-545,628,637-640,659,660,665,686-688,696,703,708,754-758,773,779,782,789-792,806,807,871,872` | declared before all uses — OK |
| C2 `t_combo_trees_mines.gd` | `:179` | `:179,234,390-392,541-543,548,660,679-682,701,708,724-726,738,739,746,752,774,778,781,800,806,811,867,868,873` | declared before all uses — OK |
| C3 `t_combo_shore_mines.gd` | `:229` | `:229,284,440,444,451,502-504,509,545,549,553,600-604,622-625,638-642,669-674,693,694,700,701,730-733,750,810,811` | declared before all uses — OK |
| C4 `t_combo_all.gd` | none | none (atom never uses `_m`) | OK |

**Derived:** zero undeclared `_m` references remain in any of the seven atoms; C4 does not use the symbol at all. `EXPECTED_PRE_FIX_FAILURE` / `expected pre-fix failure` markers are still present where authored (e.g. `t_terrain_shore.gd:19,199,227,236,269,856,858,923`), untouched by this ticket.

## 3. Existing parse evidence — reused, no new jobs submitted

Each artifact was read directly. Every job's argv is the documented parse form
`--headless --path variant3d --check-only --script res://tests/<atom>.gd`; each
stdout is the 75-byte Godot 4.7.2 banner; each stderr is **0 bytes**, so
`SCRIPT ERROR == 0` by direct count.

| Atom | Ticket / id | Source mtime → job created | Runner result | exit | stderr | SCRIPT ERROR |
|---|---|---|---|---|---|---|
| C1 `t_combo_trees_shore.gd` | 475 `darkrowall-t_combo_trees_shore` | 11:08:06 → 11:14:00 | `ok` | 0 | 0 B | **0** |
| P1 `t_terrain_trees.gd` | 486 `darkrowall-t_terrain_trees-r1` | 11:05:08 → 11:23:17 | `ok` | 0 | 0 B | **0** |
| P2 `t_terrain_shore.gd` | 493 `darkrowall-t_terrain_shore-r1` | 11:06:28 → 11:28:32 | `ok` | 0 | 0 B | **0** |
| P3 `t_terrain_mines.gd` | **501** `darkrowall-t_terrain_mines-r2` | 11:36:50 → **11:37:15** | `ok` | 0 | 0 B | **0** |
| C2 `t_combo_trees_mines.gd` | 505 `darkrowall-t_combo_trees_mines-r1` | 11:13:01 → 11:40:19 | `ok` | 0 | 0 B | **0** |
| C3 `t_combo_shore_mines.gd` | 506 `darkrowall-t_combo_shore_mines-r1` | 11:10:03 → 11:41:50 | `ok` | 0 | 0 B | **0** |
| C4 `t_combo_all.gd` | 507 `darkrowall-t_combo_all-r1` | 11:11:11 → 11:42:27 | `ok` | 0 | 0 B | **0** |

**Derived:** every winning job was created **after** the current source mtime, including P3's 501 after the 11:36:50 `_m` fix. QA_ATOM_STALE_02's "post-fix source has no parse check" (`:120`, open question 2 at `:150`) is therefore **superseded** by the landed DARKROW_ALL_01 report and these artifacts. No `darkrowrepair-*` id was taken, no queue mutation, no re-submit, no direct `godot`.

## 4. Edits made before the re-scope notice — exact list and disposition

1. **Seven backups created** (allowed by the original ticket, no source change):
   `inbox/backup/<name>.gd.bak-DARKROWREPAIR` for P1, P2, P3, C1, C2, C3, C4
   (sizes 37889, 37080, 33135, 35537, 34408, 32006, 40037 bytes; each SHA-256
   verified equal to its source at copy time).
2. **One C2 source edit, then fully reverted.** Before the notice I changed only
   `t_combo_trees_mines.gd`'s `check()` block from the DARKROW-ALL `Variant cond`
   form back to the `.bak-DARKROWALL` bool form. I did **not** proceed to the
   planned counting/dark-row edits. That single partial change would have left
   the 4-argument `null` row at `:874` calling a 3-argument bool function — a real
   parse hazard — so on receiving the re-scope notice I reverted it verbatim.
3. **Post-revert hash check:** `t_combo_trees_mines.gd` SHA-256
   `502e2f0190af172edf70185b462c3a04e2fc84f3aadfe5b7a3aaa313f162ee51`
   equals `inbox/backup/t_combo_trees_mines.gd.bak-DARKROWREPAIR` exactly.
   All seven atoms are byte-identical to their pre-edit copies; `git status`
   shows none of the seven as locally modified.

**No-weakening statement:** the reverted edit never changed a threshold, deleted
a check, or altered pass/fail counting; the final on-disk C2 is exactly the bytes
that job 505 parsed green. No assertion, luma gate (all seven atoms retain
`ground_mean_luma >= 40.0` and `ground_max_luma >= 100.0`), category-purity
check, pre-fix marker or pass/fail counter was weakened by this ticket.

## 5. Stale result JSON — not edited, for COORD

`variant3d/tests/results/t_terrain_mines.json` is unchanged at 10:00:59 and still
reads `passed:true`, `passes:13`, `total:13`, `headless:true`,
`status:HEADLESS_STRUCTURAL_ONLY__PNG_UNVERIFIED`, `png.written:false`,
`png.size:[0,0]` — the false-green identified in `QA_ATOM_STALE_02.md:104-118`.
Parse-green jobs do not refresh it. Per instruction I did **not** edit, delete
or rewrite any result JSON: COORD must delete/ignore this stale artifact and let
a fresh windowed P3 ladder row regenerate it before any PASS claim.

## 6. Open questions / UNVERIFIED

1. Parse evidence is `--check-only` only (`DARKROW_ALL_01.md:144-151`): no
   windowed P1–C4 ladder row, no PNG, no runtime `mean_luma`/`max_luma` value.
2. The `>=40` / `>=100` gates remain PORT APPROX — no donor GPU A/B
   (`DARKROW_ALL_01.md:180-183`).
3. The stale P3 false-green JSON (§5) still needs COORD action; it is not a
   parse issue but a result-artifact issue.
4. C2's mtime moved to 11:48:28 because of my pre-notice edit/revert, although
   its bytes are unchanged (§4). Any mtime-based staleness tool may flag it;
   the hash comparison is the authoritative check.
5. `DARKROW_ALL_01.md:188-191` flags out-of-scope `t_season_overlay.gd:767`;
   not touched here.

## 7. Summary

- **Verdict: DARKROW-REPAIR-01 is redundant and closed.** The `_m` parse error
  on `t_terrain_mines.gd:618` was real (job 497) but was fixed by DARKROW-ALL-01
  before this ticket's fix could be needed; the current source uses
  `_full_width_dark_rows_diag` (`:107,:434,:621`).
- All seven atoms have zero undeclared `_m` references and all seven have
  existing `END ok` / exit 0 / 0-byte-stderr `--check-only` jobs (475/486/493/
  501/505/506/507), each created after its source's final mtime.
- No new runner job was submitted; no queue mutation; no direct Godot.
- Seven `.bak-DARKROWREPAIR` backups were created; one C2 edit was made and
  immediately reverted, with byte-level hash equality confirmed. No source
  edit is retained.
- No result JSON, harness, game code, P0, S1, config, manifest or other report
  was edited by this ticket. **The only file written after the re-scope notice
  is this report.**

---

*End of DARKROW-REPAIR-01. Verification only; no duplicate edits, no re-runs, no weakening.*
