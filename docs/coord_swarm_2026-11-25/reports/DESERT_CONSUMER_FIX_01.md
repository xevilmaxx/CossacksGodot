---
id: DESERT-CONSUMER-FIX-01
task: "Accept all 38 donor desert remap pairs in the terrain module"
date: 2026-11-25
status: DELIVERED__RUNTIME_VERIFIED__38_OF_38_PAIRS_LOADED__UV2_MISMATCH_1252_TO_0__NO_TEST_WEAKENING__NO_DONOR_COPY
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
outputs:
  - "variant3d/scripts/world3d_terrain.gd"
  - "docs/coord_swarm_2026-11-25/reports/DESERT_CONSUMER_FIX_01.md"
backup: "inbox/backup/world3d_terrain.gd.bak-DESERTFIX"
labels: [observed, derived, inferred, UNVERIFIED]
donor_parity_claim: false
visual_parity_claim: false
---

# DESERT-CONSUMER-FIX-01 — all 38 donor desert pairs accepted by the consumer

> **Scope guard.** Only the exclusively owned code file
> `variant3d/scripts/world3d_terrain.gd` and this report were written by this
> ticket, plus the mandated byte backup
> `inbox/backup/world3d_terrain.gd.bak-DESERTFIX`. No atom, JSON, atlas, shader,
> manifest, config or `app/**` file was edited. The donor was not read, copied,
> unpacked or executed this pass. The season atom's own result artifact
> `variant3d/tests/results/t_season_overlay.json` and the runner spools were
> written by the atom/runner, not by this ticket (the artifact was later swept
> into HEAD by another worker's `step` commit). **No donor-parity or
> visual-parity claim is made.**

## 1. Sources read (all read-only this pass)

| # | Source | What it supplied | Label |
|---|---|---|---|
| C1 | `docs/coord_swarm_2026-11-25/reports/SEASON_DESERT_01.md:33,143-155,181-189` | diagnostic: consumer loads 0 of 38 pairs because `:441-448` requires `src is int and dst is int` while Godot parses all JSON numbers as float; 1252 UV2 mismatches; stale stats cite at `:1623`; consumer fix listed as open question O1 | observed |
| C2 | `docs/coord_swarm_2026-11-25/reports/DESERT_REMAP_02.md:41-93,124-145` | donor-grounded 38-pair set (11 SP-3 + 27 added), exact `miscext.script` line citations, `extension.after` counts, validation table | observed |
| C3 | `variant3d/assets/terrain/atlas/desert_remap.json:53-75` (READ-ONLY) | `remap` dictionary keyed by Summer name; each record carries `source_index` / `atlas_index` as JSON numbers; `:53-119` = 38 records, `extension.after.direct_cases = 38`, `height_gated_cases = 1` (per C1/C2) | observed |
| C4 | `docs/coord_swarm_2026-11-25/reports/SP_06_renderer_hook.md:155-156,193-194,269-270` | original consumer intent: SP-6's `_load_desert_remap()` loaded only SP-3's 11 direct pairs; `stats.desert_remap` provenance block | observed |
| C5 | `variant3d/scripts/world3d_terrain.gd:380-388,430-449,517-553,1619-1629` (EXCLUSIVE owner) | pre-edit loader `_read_json()` → `JSON.parse_string()` (float numbers); strict int guard; existing local pattern `if v is int or v is float: int(v)` in the relief stamp reader; stale stats cite | observed |
| C6 | `variant3d/tools/AGENT_PROTOCOL.md:11,14-18,39-53` and `docs/coord_swarm_2026-11-25/RUN_GUIDE.md:35-55,94-109,125-135` | backup rule, variant-runner-only rule, long FIFO waits normal, `scan-stderr` for `SCRIPT ERROR`, headless `SKIP_CAPTURE` expected | observed |
| C7 | COORD status ping (QA_DESERT_FIX_01.md relay) | permission to correct the stale `11 DIRECT pairs` comment at `:431` in this owned file; no PASS claim without runtime evidence | observed |

Evidence vocabulary: **observed** = literal bytes/lines read this pass; **derived** = computed from observed code/artifacts; **inferred** = reasoned, not proven; **UNVERIFIED** = cannot be proven from readable data.

## 2. Backup

- `inbox/backup/world3d_terrain.gd.bak-DESERTFIX` — byte copy of the pre-edit
  file, **80,195 B**, SHA-256
  `B295C5CC9D2E3A011601BE23CA51D60495AC84C3944A9F694EF2C3B831C72A18`.
  Copied before the first edit (AGENT_PROTOCOL C6:11); hash re-verified equal to
  the source at copy time.

Final on-disk file: **80,505 B**, SHA-256
`9678811A1690527FC3CFF7385C7C7B2506F3AE732E2C0D1741314179AF6C3CEA`.
Observed: an unrelated worker's automated `step` commit `2411a752` (2026-11-25
12:23:20 +0100) swept this owned file into HEAD; working-tree blob
`198e6aafc2fdda76b06266be1245c2547f7af334` equals `HEAD:variant3d/scripts/world3d_terrain.gd`.
**This ticket did not run `git add` or `git commit`.**

## 3. Before → after (complete diff vs backup)

`git diff --no-index -- inbox/backup/world3d_terrain.gd.bak-DESERTFIX variant3d/scripts/world3d_terrain.gd`:
**3 hunks, 7 insertions, 3 deletions**, all inside this owned file. No hunk
outside `_load_desert_remap()` and `stats.desert_remap`.

### 3.1 Loader accepts int or float JSON numbers — `:445-452`

Before (backup `:445-448`):

```gdscript
		var src: Variant = (e as Dictionary).get("source_index", null)
		var dst: Variant = (e as Dictionary).get("atlas_index", null)
		if src is int and dst is int:
			_desert_remap[int(src)] = int(dst)
```

After (final `:445-452`):

```gdscript
		var src: Variant = (e as Dictionary).get("source_index", null)
		var dst: Variant = (e as Dictionary).get("atlas_index", null)
		# DESERT-CONSUMER-FIX-01: JSON.parse_string returns float for every JSON
		# number, so the strict `is int` test loaded 0 of 38 donor pairs. Accept
		# both forms (as the relief stamp reader does) and int()-cast below;
		# donor source/atlas index semantics are unchanged.
		if (src is int or src is float) and (dst is int or dst is float):
			_desert_remap[int(src)] = int(dst)
```

The `int()` cast on the existing assignment line is unchanged: source → atlas
index semantics, the `source_index`/`atlas_index` field names, the `Dictionary`
keying by Summer name and the 1:1 record loop are untouched. The accepted-type
guard mirrors the already-present local convention at final `:538`
(`if cv is int or cv is float: cx = int(cv)`), so no new convention is
introduced. Non-numeric records are still rejected; no `else` or fallback was
added. The height-gated `rock8` row remains in the separate `height_gated`
block and is deliberately **not** loaded (DATA_ONLY_NOT_EXECUTED, unchanged).

### 3.2 Stale loader comment corrected — `:431`

Per C7 permission, the one stale string in this owned file was corrected:

```gdscript
# before: # SP-3's 11 DIRECT pairs (source_index -> packed atlas index) from
# after:  # 38 donor DIRECT pairs (source_index -> packed atlas index) from
```

Comment only; no code, count, index or branch changed. It was applied before
the atom job 537 submission, so that runtime job validated the final bytes.

### 3.3 Stats cite 11 → 38 — `:1627`

Before (backup `:1623`):

```gdscript
			"cite": ("miscext.script:1447-1502 (11 direct pairs); rock8 :1504-1505 "
```

After (final `:1627`):

```gdscript
			"cite": ("miscext.script:1447-1502 (38 direct pairs); rock8 :1504-1505 "
```

The donor citation range and the `rock8 :1504-1505 DATA_ONLY_NOT_EXECUTED`
suffix are byte-identical; only the stale count string moved up to the
donor-grounded 38 (C2/C3). `direct_entries` still reports the live
`_desert_remap_entries` value, not a hardcoded literal.

### 3.4 Byte-identical by instruction

All season selection, atlas fallback, loader override, UV2 application,
RELIEF-01 stamp code, light/`SUN_LIGHTVEC` code, mesh invariants, water, shadow
and every pre-existing `stats` key are byte-identical to the backup. No test,
JSON, atlas, shader, manifest or `app/**` file was edited.

## 4. Donor citations (carried, not re-derived this pass)

- `scripts\lib\miscext.script:1447-1502` — **38 active `_misc_SetDesert` case
  pairs**; 11 SP-3 entries preserved plus 27 added by DESERT-REMAP-02 (C2 §2
  table `:49-93`). The consumer now loads all 38 direct pairs.
- `miscext.script:1504-1505` — `rock8 → desert2` height gate; stays
  DATA_ONLY_NOT_EXECUTED, one record in `height_gated`, not in `direct`.
- `miscext.script:1513-1520` (koef 0.8), `:1531-1534` (mine suffix),
  `:1536-1537` (env destruction) — data-only, unchanged.
- `variant3d/assets/terrain/atlas/desert_remap.json:53-119,162-169` — `remap`
  has 38 records; `extension.after.direct_cases = 38`,
  `height_gated_cases = 1` (C1/C3).
- All donor runtime claims remain UNVERIFIED (donor `;`-prefixed script lines,
  no GPU A/B). This ticket asserts port internal consistency only.

## 5. Validation — variant runner only, no direct `godot`, no gates/ladder, no re-submit

Both launches used
`python variant3d\tools\godot_runner.py run --id <id> --timeout … --max-wait 3600 -- --headless --path variant3d …`.
No re-submit, no queue mutation, no direct `godot`, no gates. FIFO waits were
normal and expected (C6). At submission the queue showed `now_serving=524`,
4 pending, `max wait = 1825.52 s`.

| Job id | Ticket | Command tail | Runner result | Wait / run | stdout / stderr | `script_error_lines` |
|---|---:|---|---|---:|---:|---:|
| `desertfix01-smoke` | 529 | `--headless --path variant3d --check-only --script res://scripts/world3d_terrain.gd` | **ok**, exit 0 | 294.25 s / 10.48 s | 75 B (banner only) / 0 B | **0** |
| `desertfix01-atom` | 537 | `--headless --path variant3d --script res://tests/t_season_overlay.gd` | **ok**, exit 0 | 393.39 s / 52.42 s | 4,969 B / 7,873 B (exit-time noise) | **0** |

- Spools: `variant3d/.godot_queue/results/00000529_desertfix01-smoke/` and
  `variant3d/.godot_queue/results/00000537_desertfix01-atom/`.
- `python variant3d\tools\smallmap_capture.py scan-stderr <stderr.txt>` →
  `script_error_lines: 0` for **both** jobs; no `SCRIPT ERROR`, no `Parse Error`.
- Godot `4.7.2.stable.official.ed1daf0bf`. COORD's QA read happened while 529
  was still queued; the completed result above is the real one (no skip, no
  failure, no re-submit).

## 6. Exact before → after numbers (atom result artifact)

Source: `variant3d/tests/results/t_season_overlay.json` written by job 518
(before, `SEASON_DESERT_01.md:124-141`) and by job 537 (after).

| Measure | Before — job 518 | After — job 537 |
|---|---:|---:|
| atom verdict | FAIL | **SKIP_CAPTURE** (headless) |
| evaluated-true | 33 | **34** |
| false | 1 | **0** |
| skipped-or-pending | 1 | 1 (`PENDING_EXTERNAL_SCAN`, unchanged) |
| `fails` field | 1 | **0** |
| `desert_consumer_remap_entries` | **0** | **38** |
| `desert_remap_direct_pairs` | 38 (JSON only) | 38 (JSON only) |
| `desert_remap_indices` loaded in consumer | 0 | **38 keys** |
| `desert_remap_unresolved` | 0 (atom-side fix) | 0 |
| `uv2_x_desert_remap_consistent` | FAIL — 1252 mismatches | **PASS — 0 mismatches (expected 0)** |
| `desert_uv2_mismatches` | 1252 | **0** |
| `desert_uv2_out_of_range` | 0 | 0 |
| `desert_remap_parsed` | PASS — 38 vs 38 | PASS — 38 vs 38 |
| `desert_remap_targets_resolve` | PASS — 0 unresolved | PASS — 0 unresolved |
| `uv2_x_summer_winter_identical` | PASS | PASS |
| `tileblock_index_preserved` | PASS | PASS |
| all three variants | BUILT, `uv2_out_of_range: 0` | BUILT, `uv2_out_of_range: 0` |
| Winter | all checks PASS | all checks PASS (unchanged) |
| `capture_status` | SKIP_CAPTURE | SKIP_CAPTURE |

Observed index semantics in the 38 loaded keys (after): `0→97`, `1→121`,
`2→106`, `10→100`, `17→112`, `23→114`, `71→97`, `72→10`, `86→123`, `90→97`,
…, i.e. donor source ids still map to the same packed atlas ids; only the
*number* of accepted records changed. The 1252 pre-fix mismatches were exactly
the count of fixture cells whose Summer tile id is one of the 38 source ids
(`seed_shift = 20261113 % 124 = 9`, `tile = (x*13 + z*7 + 9) % 124`, 64×64 →
1252, C1:148-152); after the fix all those cells receive their remapped UV2.x.

**Reading of `passed: false` in the artifact:** the atom reached
`34 evaluated-true / 0 false / 1 skipped-or-pending` with `verdict: SKIP_CAPTURE`
because the headless display server cannot produce the three PNGs. Per C6
(RUN_GUIDE `:68,109`) that is expected for a headless run and is **not** a code
failure. The runner itself reported `ok` / exit 0. No green visual PASS is
claimed.

## 7. No-weakening statement

- No test file was edited; `t_season_overlay.gd` and its
  `uv2_x_desert_remap_consistent` check remain byte-identical. The strict
  `expected 0` for both unresolved records and UV2 mismatches was never
  relaxed, skipped, converted to `null` or given a PENDING status.
- The stats cite moved **11 → 38**, i.e. **up** to the donor-grounded set,
  matching `desert_remap.json extension.after.direct_cases = 38`; nothing was
  lowered, hardcoded to PASS or removed.
- The 1252 → 0 improvement came solely from the consumer accepting float-typed
  JSON numbers; the atom's assertion and expectation are unchanged (the same
  atom reported FAIL at 1252 before the edit).
- The only code change is a type guard widening from `int` to `int or float`
  plus the unchanged `int()` cast; non-numeric records are still rejected and
  donor index semantics are preserved.
- `PENDING_EXTERNAL_SCAN` remains by design; the external `scan-stderr` was run
  manually and returned 0, but the atom row was not altered.
- No PASS claim is made for any windowed/visual gate; headless state-only
  evidence is reported as such.

## 8. Remaining windowed capture gap

Both jobs were headless: `capture_status: SKIP_CAPTURE`, `headless: true`,
`verdict: SKIP_CAPTURE`, `passed: false` is expected. No windowed three-PNG
capture was attempted. That needs the atom's `--summer-png`, `--winter-png` and
`--desert-png` user args, a fresh job id, PNG-metric checks via
`smallmap_capture.py stats`, and a second-agent visual re-check
(RUN_GUIDE C6:62-68,92; TEST_MATRIX `:58,75`). PNG-metric assertions and the
`_capture_variant` path remain unverified by this ticket. No donor GPU A/B was
run.

## 9. Open questions (do not guess)

1. **Height-gated `rock8 → desert2`** (1 record, `miscext.script:1504-1505`)
   remains DATA_ONLY_NOT_EXECUTED and is not applied by the index-only consumer.
   Whether it should ever be honoured is UNVERIFIED and outside this ticket.
2. **`alpha0c` (index 123)** from `alpha0a` is an EMPTY manifest cell with no
   shipped PNG; pre-existing and UNVERIFIED, unchanged here.
3. **Donor runtime activity** of all `;`-prefixed `miscext.script` lines is
   UNVERIFIED. The 38-pair set reproduces donor *text intent* only; PORT
   APPROXIMATION, no donor or visual parity claim.
4. **Chained-remap semantics** (`test1/2/3 → ground1` vs `ground1 → test16`)
   are stored verbatim; donor single-pass behaviour is inferred from
   `:1443-1447`, not proven at runtime. Unchanged here.
5. **Season enum value 1** remains UNVERIFIED; no code path added (SP-6 O6).
6. **Final-bytes validation:** the comment-only string change at `:431` was
   applied before job 537 was submitted, so the runtime atom covers the final
   bytes; job 529 parsed the two-hunk version (comment change is non-executable
   and cannot affect parsing). No job was re-submitted.
7. **Foreign commit:** commit `2411a752 step` swept this owned file into HEAD;
   no `git add`/commit was run by this ticket (observed). COORD may decide how
   to record attribution.

## 10. Summary

- Fixed the SP-6 consumer at `world3d_terrain.gd:451-452`: float-typed JSON
  numbers (`JSON.parse_string`) are now accepted alongside ints and cast with
  the pre-existing `int()` for index math, so **all 38 donor desert pairs load**.
  Donor index semantics, the height-gated exclusion and every other code path
  are unchanged.
- Corrected the stale stats cite at `:1627` (11 → 38) and, with explicit COORD
  permission, the stale loader comment at `:431` (11 → 38). Diff vs backup:
  **3 hunks, 7 insertions, 3 deletions**, all in the owned file.
- Backup: `inbox/backup/world3d_terrain.gd.bak-DESERTFIX` (80,195 B, SHA-256
  `B295C5CC…72A18`), taken before the first edit.
- Jobs (variant runner only): `desertfix01-smoke` / 529 — `ok`, exit 0,
  `--check-only`, 75 B stdout, 0 B stderr; `desertfix01-atom` / 537 — `ok`,
  exit 0, headless season atom, **34 PASS / 0 FAIL / 1 pending**,
  `SCRIPT ERROR == 0` via `scan-stderr` on both jobs. No re-submit, no queue
  mutation, no direct `godot`.
- Runtime evidence: `desert_consumer_remap_entries` **0 → 38**, loaded
  `desert_remap_indices` **0 → 38 keys**, `desert_uv2_mismatches` **1252 → 0**,
  `uv2_x_desert_remap_consistent` **FAIL → PASS**. Summer/winter UV2 unchanged,
  tileblock byte-identical, all three variants BUILT with `uv2_out_of_range: 0`.
  Headless artifact shows `SKIP_CAPTURE` with `passed: false` by design — not
  claimed as a visual PASS.
- No test was weakened; no atom, JSON, atlas, shader, manifest or `app/**`
  file was edited by this ticket. No donor file was read, copied, unpacked or
  executed this pass. **No donor-parity or visual-parity claim is made.**

*End of DESERT-CONSUMER-FIX-01. One owned code file, one backup and one report written by this ticket.*
