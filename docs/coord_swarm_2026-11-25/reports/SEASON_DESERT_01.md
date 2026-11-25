---
id: SEASON-DESERT-01
task: "Re-baseline the season atom's desert assertions against the 38-pair donor remap"
date: 2026-11-25
status: DELIVERED__ATOM_ONLY__HONEST_FAIL__NO_DONOR_COPY__NO_PARITY_CLAIM
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
outputs:
  - "variant3d/tests/t_season_overlay.gd"
  - "docs/coord_swarm_2026-11-25/reports/SEASON_DESERT_01.md"
backup: "inbox/backup/t_season_overlay.gd.bak-SEASONDESERT"
labels: [observed, derived, inferred, UNVERIFIED]
---

# SEASON-DESERT-01 — strict desert re-baseline at 38 donor pairs

> **Scope guard.** Only two files were written: `variant3d/tests/t_season_overlay.gd`
> and this report, plus the required byte backup
> `inbox/backup/t_season_overlay.gd.bak-SEASONDESERT`. No remap JSON, atlas,
> manifest, mapgen file, terrain script or other atom was touched. The donor was
> not read, copied, unpacked or executed. The atom itself wrote its usual
> untracked result artifact `variant3d/tests/results/t_season_overlay.json`.
> **No donor parity or visual-parity claim is made.**

## 1. Sources read (all read-only this pass)

| # | Source | What it supplied | Label |
|---|---|---|---|
| C1 | `docs/coord_swarm_2026-11-25/reports/SEASON_TEST_PATH_01.md:98-130` | prior honest verdict 31 PASS / 3 FAIL / 1 pending; Winter unblocked; three desert-only FAILs (38 vs 11, 39 unresolved, 1252 UV2 mismatches) | observed |
| C2 | `docs/coord_swarm_2026-11-25/reports/DESERT_REMAP_02.md:41-93,127-145,177-186` | donor-grounded 38-pair set (11 SP-3 + 27 added), exact `miscext.script` line citations, `extension.after`, validation table | observed |
| C3 | `variant3d/assets/terrain/atlas/desert_remap.json:53-119,162-169` | `remap` has **38** records, `height_gated` has **1**; `extension.after.direct_cases = 38`, `height_gated_cases = 1` | observed |
| C4 | `variant3d/tests/t_season_overlay.gd:510-571` (pre-edit) | stale `== 11`, message `expected 11`, numeric-only manifest index guard, unchanged cross-variant UV2 check | observed |
| C5 | `variant3d/tools/AGENT_PROTOCOL.md:11,14-18,39-53` and `docs/coord_swarm_2026-11-25/RUN_GUIDE.md:35-55,94-109` | backup rule, variant-runner-only rule, long FIFO waits are normal, `scan-stderr` for SCRIPT ERROR | observed |
| C6 | `variant3d/scripts/world3d_terrain.gd:430-449,1619-1628` (READ-ONLY) | consumer `_load_desert_remap()` requires `src is int and dst is int`; stats expose `desert_remap.direct_entries` | observed |
| C7 | `variant3d/tests/results/t_season_overlay.json` (pre-edit artifact) | 39 unresolved entries all `*-not-packed-at-<idx>`; grid read back `[16.0, 8.0]` | observed |

## 2. Backup

- `inbox/backup/t_season_overlay.gd.bak-SEASONDESERT` — byte copy of the pre-edit
  file, **40,801 B**, SHA-256
  `EC9A944DDFA76CC4FC988A5F09B3DFC6872C71ADBF4285350D9F03767CDAB150`.
  Created before the first edit (`AGENT_PROTOCOL.md:11`).

## 3. Before → after (complete diff vs backup)

`git diff --stat -- variant3d/tests/t_season_overlay.gd`: **44 insertions,
9 deletions**, all inside this owned file. The file was HEAD-clean before this
ticket (per `SEASON_TEST_PATH_01.md:81-83`), so the diff is exactly this ticket.

### 3.1 Stale expected count → donor-grounded 38 (C2/C3)

New constants at `:74-77`:

```gdscript
# SEASON-DESERT-01: donor-grounded desert baseline after DESERT-REMAP-02
# (DESERT_REMAP_02.md:49-93 §2 and :162-169 §4; desert_remap.json extension.after).
const EXPECTED_DESERT_DIRECT_PAIRS := 38
const EXPECTED_DESERT_GATED_PAIRS := 1
```

`_check_desert_remap` now reads the JSON's own `extension.after` counts at
runtime (`:532-542`) and requires them to **agree** with the embedded
donor-grounded constants; the parsed `remap.size()` must equal both:

```gdscript
	check("desert_remap_parsed", (remap.size() == expected_direct
		and expected_direct == EXPECTED_DESERT_DIRECT_PAIRS
		and gated.size() == expected_gated
		and expected_gated == EXPECTED_DESERT_GATED_PAIRS), ...
```

Before: `remap.size() == 11 and gated.size() == 1`, message `direct=38 (expected 11)`.
After: `direct=38 (expected 38, donor-grounded 38) height_gated=1 (expected 1)`.
A shrunken remap **or** a shifted `extension.after` declaration fails; the
expectation moved **up** to the donor-grounded set, never down.

### 3.2 False-negative target resolution — atom side only

`_layout_name_to_index` (`:453-468`) required `(e as Dictionary).get("index") is int`.
Godot 4.7.2's `JSON.parse_string` returns **float** for every JSON number —
observed in the atom's own result: manifest grid `[16,8]` reads back
`[16.0,8.0]`. The name→index map was therefore empty and all 39 records were
reported `not-packed-at-<idx>`, even though C2/C3 verify 38/38 + 1/1 indices.
The guard now accepts either numeric form and still `int()`-casts, exactly as
the desert record loop already did:

```gdscript
			var iv: Variant = (e as Dictionary).get("index", null)
			if nm != "" and (iv is int or iv is float):
				out[nm] = int(iv)
```

The strict equality `int(name_to_idx[tgt]) == tgt_i` is unchanged. This helper
has exactly **one** caller, `_check_desert_remap:544`; no Winter path uses it.

### 3.3 Evidence-only measurement (not a check)

`:589-597` records `measured.desert_consumer_remap_entries` from terrain stats
`desert_remap.direct_entries`. No assertion, threshold or status was added or
removed.

### 3.4 Byte-identical by instruction

All Winter assertions, dependency guards (`_make_variant`, `_note_dependency`,
`_advance_variant`), the `PENDING_DEP` / `PENDING_EXTERNAL_SCAN` branches,
capture logic, `expected_pre_fix_failure` semantics and every cross-variant
check are unchanged. `expected_pre_fix_failure` does not occur in this atom at
all (it exists in `t_select_rect.gd`), so there was nothing to alter there.
One detail *string* gained the clarifying suffix `; 38 direct + 1 gated`; no
condition changed. The strict UV2 consistency check
(`uv2_x_desert_remap_consistent`, expected 0 mismatches) is byte-identical.

## 4. Validation — variant runner only, no direct `godot`, no gates/ladder

Both launches used
`python variant3d\tools\godot_runner.py run --id <id> --timeout … --max-wait 1800 -- --headless --path variant3d …`.
No re-submit, no queue mutation, no direct `godot`. FIFO waits were normal and
expected (`RUN_GUIDE.md:101,130`).

| Job id | Ticket | Command tail | Runner result | Honest reading |
|---|---|---|---|---|
| `seasondesert01-smoke` | 512 | `--check-only --script res://tests/t_season_overlay.gd` | **failed**, exit 1; wait 136.71 s, run 9.59 s; stdout 75 B (banner only), stderr **0 B**, `script_error_lines: 0` | No diagnostic and no `SCRIPT ERROR`; neighbours 510/511 showed foreign in-flight `hud.gd:496` / `selftest.gd:153` parse errors. Not a code result from this atom; not re-submitted per instruction. Job 518 below proves the atom parses and runs. |
| `seasondesert01-atom` | 518 | `--script res://tests/t_season_overlay.gd` (headless, no `--check-only`) | runner `failed`, exit 1 — the atom's own `quit(1)` on a failed check; wait 313.90 s, run 37.78 s | Honest verdict **FAIL** (see §5). `smallmap_capture.py scan-stderr` on its `stderr.txt` → **`script_error_lines: 0`, `SCRIPT ERROR == 0`**. |

Result artifact written by job 518:
`variant3d/tests/results/t_season_overlay.json`; stdout tail:
`T_SEASON_OVERLAY RESULT: FAIL 33 evaluated-true / 1 false / 1 skipped-or-pending`.

## 5. Exact before → after verdict, and the remaining FAIL

| Measure | Before (ticket 502, `SEASON_TEST_PATH_01.md:103-126`) | After (ticket 518) |
|---|---:|---:|
| verdict | FAIL | FAIL |
| evaluated-true | **31** | **33** |
| false | **3** | **1** |
| skipped-or-pending | **1** | **1** |
| `desert_remap_parsed` | FAIL (38 vs expected 11) | **PASS** (38 vs expected 38) |
| `desert_remap_targets_resolve` | FAIL (39 unresolved) | **PASS** (0 unresolved) |
| `uv2_x_desert_remap_consistent` | FAIL (1252 mismatches) | **FAIL** (1252 mismatches, unchanged — strict check retained) |
| `script_error_scan_external` | `PENDING_EXTERNAL_SCAN` | `PENDING_EXTERNAL_SCAN` (unchanged by design) |
| all three variants | BUILT, `uv2_out_of_range: 0` | BUILT, `uv2_out_of_range: 0` |
| Winter | fully unblocked, all Winter checks PASS | unchanged, all Winter checks PASS |

**Root cause of the remaining FAIL (observed + derived, not guessed).**
Job 518 measured `desert_consumer_remap_entries = 0`: the SP-6 consumer loaded
**zero** of the 38 direct pairs. `world3d_terrain.gd:441-448` accepts a record
only when `src is int and dst is int`; the same float-typed `JSON.parse_string`
output that produced `[16.0, 8.0]` fails that test, so `_desert_remap` stays
empty and desert UV2.x equals Summer UV2.x everywhere. Independently, the 1252
mismatches reproduce exactly as the count of fixture cells whose Summer tile id
is one of the 38 remap source ids (`seed_shift = 20261113 % 124 = 9`,
`tile = (x*13 + z*7 + 9) % 124`, 64×64 → **1252** cells). The atom's strict
check is therefore correct to fail: the defect is in the consumer, not in the
atom's expectation. Fixing it requires editing `world3d_terrain.gd`, which is
outside this ticket's ownership; no atom-side edit could make the check pass
without weakening it.

## 6. No-weakening statement

- The expected direct count moved **11 → 38**, i.e. **up** to the donor-grounded
  set (`DESERT_REMAP_02.md:49-93`, `desert_remap.json extension.after`), and is
  cross-checked against an embedded donor-grounded constant. Nothing was
  lowered, skipped or hardcoded to PASS.
- `expected 0` was retained verbatim for both unresolved records and UV2
  mismatches; no threshold, tolerance or comparison was relaxed.
- No check was deleted, converted to `null`, or given a `PENDING` / `SKIP`
  status; the only status rows are the pre-existing `PENDING_EXTERNAL_SCAN`
  and the unchanged `PENDING_DEP` machinery.
- The 39→0 unresolved fix came from correcting a float/int false negative in
  the atom's own manifest index map, while keeping exact name and index
  equality. The remaining 1252-mismatch FAIL is reported honestly, not hidden.

## 7. Remaining windowed capture gap

Both jobs were headless: `capture_status: SKIP_CAPTURE`, `headless: true`,
`passed: false` is expected for a headless run (`RUN_GUIDE.md:68,109`). No
windowed three-PNG capture was attempted: that needs the atom's
`--summer-png`, `--winter-png`, `--desert-png` user args, a fresh job id and a
second-agent visual re-check (`TEST_MATRIX.md:58,75`). The PNG-metric assertions
and `_capture_variant` path remain unverified by this ticket.

## 8. Open questions (do not guess)

1. **Consumer fix owner.** `world3d_terrain.gd:441-448` should accept numeric
   (`int` or `float`) `source_index`/`atlas_index` before casting, mirroring the
   atom fix, so all 38 pairs are loaded. Not edited here (other worker's file);
   needs an SP-6/terrain ticket. Until then the strict UV2 check stays FAIL.
2. **Stale consumer citation.** `world3d_terrain.gd:1623` still says
   `miscext.script:1447-1502 (11 direct pairs)`; the data is now 38. Also
   outside this ownership.
3. **Smoke ticket 512** exited 1 with an empty stderr and no `SCRIPT ERROR`,
   while ticket 518 ran the same script successfully. Most likely foreign
   in-flight edits in jobs 510/511, but this is **inferred**, not proven; no
   re-submit was made per instruction.
4. **Runtime activity of `_misc_SetDesert`** and of the `;`-prefixed donor
   script lines remains UNVERIFIED; this report asserts internal consistency
   only, not donor parity (`DESERT_REMAP_02.md:161-174`).
5. **Height gate / `alpha0c` unchanged.** One `rock8 → desert2` record stays
   DATA_ONLY_NOT_EXECUTED and is resolved but not fed into `idx_map`; the
   `alpha0a → alpha0c` EMPTY cell (index 123, no PNG) stays pre-existing and
   UNVERIFIED.
6. **Windowed capture** remains unverified (§7).

## 9. Summary

- Re-baselined the desert assertion from SP-3's stale **11** direct pairs to
  the donor-grounded **38** pairs of `desert_remap.json` (with runtime
  `extension.after` cross-check), and fixed the atom's own manifest-index
  float/int false negative: unresolved records **39 → 0**.
- Backup: `inbox/backup/t_season_overlay.gd.bak-SEASONDESERT` (40,801 B,
  SHA-256 `EC9A944D…150`).
- Jobs: `seasondesert01-smoke` / 512 (failed, no diagnostic, no re-submit);
  `seasondesert01-atom` / 518 (honest FAIL, **33 PASS / 1 FAIL / 1 pending**,
  `SCRIPT ERROR == 0` via `scan-stderr`).
- Remaining FAIL is the strict, unchanged UV2 consistency check: the SP-6
  consumer loads `0` of 38 pairs, producing exactly 1252 mismatched cells.
  This is a consumer defect outside this ticket's ownership, not a weakened
  atom expectation.
- **No other file was edited.** Only the owned atom, this report and the
  mandated backup were written; the atom's untracked result JSON is its own
  output.

*End of SEASON-DESERT-01.*
