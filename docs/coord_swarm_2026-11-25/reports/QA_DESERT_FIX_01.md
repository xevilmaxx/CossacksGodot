---
id: QA-DESERT-FIX-01
task: "Read-only QA of DESERT-CONSUMER-FIX-01 float-index fix after landing"
date: 2026-11-25
status: STATIC_PASS__RUNTIME_UNVERIFIED__NO_PASS_PROMOTION__NO_PARITY_CLAIM
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
output: "docs/coord_swarm_2026-11-25/reports/QA_DESERT_FIX_01.md"
verifies: DESERT-CONSUMER-FIX-01
labels: [observed, derived, inferred, UNVERIFIED]
---

# QA-DESERT-FIX-01 — float-index consumer fix, static re-verification

> **Scope guard.** Read-only QA. No source file was edited, no runner job was
> submitted, no queue state was touched. This report is the only repository
> write. One throwaway analysis script was written outside the repo, under
> `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\`, and is not part of the
> deliverable. **No PASS promotion and no donor/visual parity claim is made.**

## 1. Sources

| # | Source | What it supplied | Label |
|---|---|---|---|
| S1 | `docs/coord_swarm_2026-11-25/reports/SEASON_DESERT_01.md` (read) | prior honest FAIL: 0 consumer entries → 1252 UV2 mismatches; §5 root cause `world3d_terrain.gd:441-448`; §8 open question #1 (consumer guard needs int/float) | observed |
| S2 | `variant3d/scripts/world3d_terrain.gd` (current snapshot, read) | the landed fix; SHA-256 below | observed |
| S3 | `inbox/backup/world3d_terrain.gd.bak-DESERTFIX` (read) | pre-fix byte copy, SHA-256 below | observed |
| S4 | `git diff --no-index S3 S2` | **exactly two hunks** (loader guard + stats cite); byte-identical everywhere else | observed |
| S5 | `variant3d/tests/results/t_season_overlay.json` (read) | atom result: `desert_consumer_remap_entries: 0`, `desert_uv2_mismatches: 1252`, verdict FAIL | observed, **stale — pre-fix** |
| S6 | filesystem mtimes + `.godot_queue/status.json` / `jobs/*.json` (read) | chronology proving S5 predates S2; job 529 is a queued, **unfinished** check-only run | observed |
| S7 | local static bracket-balance scan of S2 vs S3 (Python, no Godot) | balanced `()`/`[]`/`{}` in both; no structural syntax hazard from the edit | derived |
| S8 | SEASON_DESERT_01 §7 (windowed capture gap) | headless-only jobs, `SKIP_CAPTURE`, no three-PNG capture | observed |

`reports/DESERT_CONSUMER_FIX_01.md` **does not exist** at QA time (glob returned no
match). The code fix has landed in the working tree; the ticket report has not.
This is recorded as an open question, not assumed away.

### Snapshot identity (observed)

| File | Bytes | SHA-256 | mtime (local) |
|---|---:|---|---|
| `variant3d/scripts/world3d_terrain.gd` (S2) | 80,506 | `2BEE0CEFCD00D85D5D6B289128AC378C71A23590093FD82DFB8C466CCE816809` | 2026-11-25 12:12:08 |
| `inbox/backup/world3d_terrain.gd.bak-DESERTFIX` (S3) | 80,195 | `B295C5CC9D2E3A011601BE23CA51D60495AC84C3944A9F694EF2C3B831C72A18` | 2026-11-25 10:53:39 |

> The workspace is **live**: an earlier QA read of S2 showed the same functional
> edit but a comment worded `relief reader at :534`; the snapshot above is the
> re-read at report time (`relief stamp reader`). Only the comment changed (2 B);
> no functional line moved. Re-hash after the owner's report lands.

## 2. Before → after

`git diff --no-index S3 S2` produced **two hunks and nothing else** (observed).
Byte delta +311 B = 4 comment lines + widened guard + one string literal.

| Item | Before (S3 backup) | After (S2 current) | Label |
|---|---|---|---|
| Remap record guard, `_load_desert_remap` `:447`→`:451` | `if src is int and dst is int:` | `if (src is int or src is float) and (dst is int or dst is float):` | observed |
| Value cast `:448`→`:452` | `_desert_remap[int(src)] = int(dst)` | unchanged — still `int()`-casts both operands | observed |
| Explanatory comment | none | 4 lines tagged `DESERT-CONSUMER-FIX-01` (float from `JSON.parse_string`, 0 of 38 loaded) | observed |
| Stats citation, `build()` `:1623`→`:1627` | `"miscext.script:1447-1502 (11 direct pairs); …"` | `"miscext.script:1447-1502 (38 direct pairs); …"` | observed |
| All season / relief / light code | as backed up | **byte-identical** (no second hunk) | observed |

## 3. Static verification findings

3.1 **Loader accepts int and float, casts to int — PASS (observed).**
S2 `:451` tests `src is int or src is float` and `dst is int or dst is float`;
`:452` assigns `_desert_remap[int(src)] = int(dst)`. Both JSON numeric forms are
accepted and explicitly cast to `int` before use as dictionary keys. This is the
mirror of the atom-side fix in `t_season_overlay.gd` and matches the directive in
SEASON_DESERT_01 §8 #1. Semantics of `source_index`/`atlas_index` are otherwise
untouched.

3.2 **Stats cite 38 — PASS (observed).**
S2 `:1627` now reads `(38 direct pairs)` where S3 read `(11 direct pairs)`.
`stats.desert_remap.direct_entries` remains wired to `_desert_remap_entries`
(`:1625`), so the runtime count field and its citation agree on 38. **Caveat:**
the in-function comment at `:431` still says `SP-3's 11 DIRECT pairs` — a stale
comment, not a stats field; recorded in §7.

3.3 **No collateral edits — PASS (observed).**
The byte diff contains only the two hunks above. Specifically unchanged:
`SEASON_ATLAS` (`:276-283`), `_effective_season` / `_select_season_atlas`
(`:397-427`), `_load_atlas` (`:563-649`), `apply_relief_grid` (`:465-513`),
`_apply_relief_stamps_from_dump` (`:522-557`), all `DONOR_*` light/sky constants
(`:137-183`), `_face_mode_at` / cliff / shore logic, and the UV2/mesh path. No
check, threshold, tolerance or `UNVERIFIED` label was weakened.

3.4 **Syntax compiles — UNVERIFIED by Godot; no structural hazard (derived).**
Per the read-only / no-runner-job constraint, no `--check-only` compile was
launched by this QA. The owner's own job **529 `desertfix01-smoke`**
(`--check-only --script res://scripts/world3d_terrain.gd`) is queued in
`.godot_queue/jobs/00000529.json` but is **absent from `status.json` history**
(history ends at ticket 527) and its result directory is empty — so it supplies
no evidence either way. Static only: bracket balance is intact in both S2 and S3
(`()` 529/529, `[]` 93/93, `{}` 57/57 in S2), and the exact `is int or is float`
idiom at `:451` already occurs five times in the same file (`:538,:541,:545,:549,:553`)
and was parsed/executed by the pre-fix atom run. Inference: the edit is
syntactically low-risk; **not a compile verification**.

## 4. Runtime / atom result

**No post-fix season atom result exists.** The only result on disk is S5, whose
`unix_ms` is `1795604618094` (2026-11-25 11:03:38 UTC; file mtime 12:03:38 local)
— **before** the fix file mtime of 12:12:08 (observed, S6). The queued jobs after
the fix are unrelated (relief/dump, HUD, load-probe, nation, art, build-step,
relief-visual); job 529 is a check-only, not an atom run. No result JSON was
regenerated after 12:12:08.

Exact values in the **stale, pre-fix** S5 artifact (observed — reported for the
record, *not* as evidence about the fix):

| Field | Value in S5 | Meaning |
|---|---:|---|
| `desert_consumer_remap_entries` | **0** | pre-fix consumer loaded 0 of 38 pairs |
| `desert_uv2_mismatches` | **1252** | strict UV2.x check FAIL |
| `desert_remap_direct_pairs` | 38 | atom-side remap parsed correctly |
| `desert_remap_unresolved` | `[]` | atom-side target resolution correct |
| verdict / passes / fails / pending | FAIL / 33 / 1 / 1 | unchanged from SEASON_DESERT_01 job 518 |

**Runtime status of the fix: UNVERIFIED.** There is no observation of
`desert_consumer_remap_entries == 38` or of the UV2 mismatch count after the
consumer change, so the strict check's new outcome is not established. The
derived expectation is that loading all 38 pairs collapses the 1252 mismatches
toward 0, but that is explicitly **inferred**, not measured, and is NOT promoted
to PASS.

## 5. Verdict

| Dimension | Verdict | Label |
|---|---|---|
| Loader widened to int + float and casts to int | PASS | observed |
| Stats citation updated 11 → 38 | PASS | observed |
| Other season / relief / light code byte-identical | PASS | observed |
| Structural syntax sanity | PASS | derived |
| Godot compile of the fixed file | UNVERIFIED | UNVERIFIED |
| Runtime `desert_consumer_remap_entries` / UV2 count post-fix | UNVERIFIED | UNVERIFIED |
| Overall ticket status | **STATIC PASS, RUNTIME UNVERIFIED — no PASS promotion** | — |
| Donor or visual parity | **no claim** | — |

## 6. Remaining windowed capture gap

Unchanged from SEASON_DESERT_01 §7 (observed, S8). All atom runs to date were
headless: `capture_status: SKIP_CAPTURE`, `headless: true`, `passed: false` is
expected in that mode, and `script_error_scan_external` is still
`PENDING_EXTERNAL_SCAN`. No windowed three-PNG capture
(`--summer-png`, `--winter-png`, `--desert-png`) was attempted for this fix, and
no second-agent visual re-check occurred. The PNG-metric assertions and the
`_capture_variant` path remain UNVERIFIED. This ticket's code change is
index-only and does not close that gap.

## 7. Open questions (do not guess)

1. **Fix report landing.** `DESERT_CONSUMER_FIX_01.md` is absent. When it lands,
   its claims and hash must be reconciled against this report's S2 snapshot.
2. **Post-fix atom run.** A fresh `t_season_overlay.gd` run against the fixed
   consumer is required for the exact `desert_consumer_remap_entries` and
   `desert_uv2_mismatches` values. Until then runtime is UNVERIFIED.
3. **Check-only job 529.** Its result was pending at QA time; retrieve it to
   convert "syntax compiles" from derived/UNVERIFIED to observed.
4. **Stale local comment.** `world3d_terrain.gd:431` still says `11 DIRECT pairs`
   although the data and stats citation are 38. Cosmetic, but it can mislead the
   next reader; not changed here (other worker's file).
5. **`_desert_remap_cells`** (`:1626`, backed by `_desert_remap_cells`) has no
   post-fix measured value; its expected behavior is inferred only.
6. **Live-workspace drift.** S2 was edited once during this QA pass (comment
   text only). If the owner edits again, re-run the byte diff before relying on
   §2/§3.
7. **Donor runtime.** `_misc_SetDesert` and the `;`-prefixed donor script lines
   remain UNVERIFIED; the height-gated `rock8` pair stays
   `DATA_ONLY_NOT_EXECUTED`, and the `alpha0c` EMPTY cell (index 123, no PNG) is
   pre-existing and UNVERIFIED. Nothing here asserts donor parity.

## 8. Summary

- The landed code change is narrow and matches the requested fix: the desert
  remap loader now accepts both `int` and `float` JSON numbers and `int()`-casts
  them (`:451-452`), and the stats citation says 38 rather than 11 (`:1627`).
  A byte diff against `inbox/backup/world3d_terrain.gd.bak-DESERTFIX` shows no
  other change anywhere in the file.
- Static checks pass; all other season, relief and light code is byte-identical.
- The only season atom result on disk is **pre-fix** (0 entries, 1252 UV2
  mismatches, FAIL) and is explicitly stale. No post-fix atom result and no
  `DESERT_CONSUMER_FIX_01.md` report exist yet; the owner's check-only job was
  still queued.
- Therefore: **static PASS, runtime UNVERIFIED, no PASS promotion, no parity
  claim.** Windowed capture remains an open gap.

*End of QA-DESERT-FIX-01.*
