---
id: BLANK-CHECK-01
title: "Fix `_is_blank()` so a bright sky corner stops rejecting a valid olive terrain frame; final windowed 3D PNG now written"
agent: "BLANK-CHECK-01 (implementation builder), coord swarm 2026-11-25"
date: 2026-11-25
status: DELIVERED__VALIDATED__FINAL_PNG_WRITTEN__POSTHIDE_FOLLOWUP_BLOCKED
scope: "Exactly two files edited/created in the repo: variant3d/scripts/main.gd (only the `_is_blank()` body) and this report. One backup file created in inbox/backup/ as mandated. No tests, config, assets, world3d_terrain.gd, app/**, queue mutation or direct godot invocation."
exclusive_output: "docs/coord_swarm_2026-11-25/reports/BLANK_CHECK_01.md"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, inferred, UNVERIFIED, PORT APPROX]
parity_guard: "PORT APPROX — no donor GPU A/B exists; this ticket fixes capture mechanics only, no donor parity claim."
---

# BLANK CHECK 01 — `_is_blank()` content-based blank detection

## 0. Mandate and boundary

Evidence: `reports/RELIEF_VISUAL_01.md` (ticket 532, job `reliefvisual01-boot`) — a valid
olive 1280×720 GPU frame was classified blank and the final PNG was refused, although
the raw sidecar survived (2,450,951 B). Rationale for the loud failure:
`docs/coord_swarm_2026-11-24/reports/V770_viewport_capture.md:20-22,149-156,216` — a
windowed 3D blank capture must **never** be silently replaced by a CPU 2D map image;
that was the AUDIT3D-09 false "proof" defect, so 3D blank now fails loudly with exit 1.
The fix therefore keeps the loud-failure path intact and only corrects the test.

Only `variant3d/scripts/main.gd` and this report were touched in the repo. A byte-identical
pre-edit backup was written to `inbox/backup/main.gd.bak-BLANKCHECK01`. The staged-loader /
`load_ready` work from the terminated LOAD-ASYNC-01 ticket is preserved byte-identically:
the backup-vs-current diff (`git diff --no-index`) shows changes **only** inside
`_is_blank()` at `main.gd:1932-1968` — no other line of `main.gd` differs.

---

## 1. Before → after (with citations)

### 1.1 Before (observed)

`variant3d/scripts/main.gd:1932-1942` (pre-edit, backup at
`inbox/backup/main.gd.bak-BLANKCHECK01`):

```gdscript
var first := img.get_pixel(0, 0)
for y in range(0, img.get_height(), maxi(1, img.get_height() / h)):
    for x in range(0, img.get_width(), maxi(1, img.get_width() / w)):
        if img.get_pixel(x, y).get_luminance() - first.get_luminance() > 0.02:
            return false
return true
```

- **Observed:** one-sided comparison against the **top-left** pixel only. A pixel is
  "content" only if it is *brighter* than `p00` by > 0.02 luminance.
- `RELIEF_VISUAL_01.md:105` records `p00=(0.7137,0.9137,1.0,1.0)` (bright sky, luminance
  ≈0.88) and `pcenter=(0.3451,0.3608,0.1137,1.0)` (olive ground). Nothing in the frame is
  brighter than sky, so **every** sampled pixel fails the one-sided test → `true`
  (blank). `main.gd:1906-1913` then printed `screenshot: windowed 3D capture is blank;
  no CPU fallback (visual parity UNVERIFIED)` and called `_quit(1)`
  (`RELIEF_VISUAL_01.md:108-123`), so the requested final PNG was never written.
- **Raw frame is non-blank by any sane measure (observed, independently re-measured):**
  `python variant3d\tools\smallmap_capture.py stats .../relief_on.png.raw.png` →
  `bytes 2450951`, `1280x720`, `non_black_fraction 0.999145`,
  `mean_rgb [112.43, 119.612, 77.204]`, `mean_luma 115.039`, `full_width_dark_rows 0`
  (matches `RELIEF_VISUAL_01.md:184-198`). Camera/viewport were correct
  (`camera_current=true`, `world_parent=Screenshot3DViewport`), `SCRIPT ERROR == 0`
  (`RELIEF_VISUAL_01.md:205-216`). This is a detector false positive, not a capture fault.

### 1.2 After (observed)

`variant3d/scripts/main.gd:1932-1968` now samples the same ≤64×64 grid but measures the
frame's own content with three symmetric statistics instead of comparing to one corner
pixel:

```gdscript
func _is_blank(img: Image) -> bool:
    if img == null or img.is_empty():
        return true
    var w := mini(img.get_width(), 64)
    var h := mini(img.get_height(), 64)
    var step_x := maxi(1, img.get_width() / w)
    var step_y := maxi(1, img.get_height() / h)
    var n := 0
    var lit := 0
    var lmin := 1.0
    var lmax := 0.0
    var colours := {}
    for y in range(0, img.get_height(), step_y):
        for x in range(0, img.get_width(), step_x):
            var p := img.get_pixel(x, y)
            var l := p.get_luminance()
            n += 1
            if l > 0.02:
                lit += 1
            if l < lmin:
                lmin = l
            if l > lmax:
                lmax = l
            colours["%d_%d_%d" % [int(p.r * 255.0), int(p.g * 255.0), int(p.b * 255.0)]] = true
    if n == 0:
        return true
    # three symmetric rejection tests — see §5
    if float(lit) / float(n) < 0.02:
        return true
    if lmax - lmin <= 0.02:
        return true
    if colours.size() < 4:
        return true
    return false
```

Call sites are byte-identical: `main.gd:1906` (windowed 3D loud failure),
`main.gd:1924` (2D fallback), `main.gd:2106` (sequence capture fallback). All other
capture/screenshot logic, camera seam, dump/self-snapshot code and CLI parsing are
unchanged (`git diff --no-index` backup vs current: only lines 1934-1942 → 1937-1968).

### 1.3 Self-inflicted first draft, corrected (observed)

The first draft of this fix used `mini()`/`maxi()` for the float luminance extrema.
Those Godot functions are **integer-only**; both extrema were truncated to 0, so
`lmax - lmin <= 0.02` was always true and every frame was classified blank. This caused
validation attempt 1 (`blankcheck01-boot`, ticket 545) to fail exactly at
`main.gd:1906-1913` despite the same valid GPU frame. Diagnosed from stdout/stderr:
no `SCRIPT ERROR`, raw sidecar present, `windowed 3D capture is blank` line only.
Corrected by replacing them with explicit `if l < lmin` / `if l > lmax` float comparisons.
Off-line replay of the final criterion on the surviving raw PNG (temporary script in
`%LOCALAPPDATA%\Temp\opencode\`, no repo file) gave:
`samples 4224`, `lit_frac 0.998343`, `luma_min 0.0`, `luma_max 0.8814`,
`range 0.8814`, `distinct_colours 3225` → **blank? False**, with wide margin.

---

## 2. Backup (observed)

| Item | Value |
|---|---|
| Path | `inbox/backup/main.gd.bak-BLANKCHECK01` |
| Size | 85,345 B |
| SHA-256 (backup and pre-edit source, identical) | `E0B4549A3F1EFA4362507090FB60C0309BDE55B220D94592ADA0EA45A85EBB84` |
| Created before the first edit | yes (copy verified by hash before editing) |

---

## 3. Validation — variant runner only, one capture per attempt, no retries

Both submissions used `python variant3d\tools\godot_runner.py run --id <id> ...` with the
**same fixture** (`variant3d/tests/fixtures/small_map_64.json`, absolute path), windowed
(no `--headless`), `--screenshot-frames 10`, main watchdog `--timeout 120`, runner
`--timeout 300`. Output path:
`C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/reliefvisual/relief_on_fixed.png`
(new name, so ticket 532's raw sidecar was not overwritten). No `reset`/`ack`/`cancel`/
`unwedge`, no direct `godot`, no queue mutation.

```bat
python variant3d\tools\godot_runner.py run --id blankcheck01-boot --timeout 300 -- ^
  --path variant3d -- --screenshot "C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/reliefvisual/relief_on_fixed.png" ^
  --screenshot-frames 10 ^
  --config "C:/Users/Maxym.Oboyshev/Documents/Craft Anything/cossacks-3-3/variant3d/tests/fixtures/small_map_64.json" ^
  --timeout 120
```

### 3.1 Attempt 1 — mandated unique id (observed, FAILED by my own draft bug)

`variant3d/.godot_queue/results/00000545.json`: ticket **545**, id `blankcheck01-boot`,
wait 413.96 s, run 53.23 s, **status failed / exit 1**. stdout had the raw-capture and
camera diag lines (`p00=(0.7137,0.9137,1.0,1.0)`, `camera_current=true`), then stderr
`screenshot: windowed 3D capture is blank; no CPU fallback (visual parity UNVERIFIED)`.
`SCRIPT ERROR == 0`. Cause: the integer-truncation defect in §1.3, not the original
one-sided comparator and not a capture/queue fault. No retry loop was started; the defect
was root-caused and fixed once.

### 3.2 Attempt 2 — corrective final validation (observed, PASSED)

Same command with id `blankcheck01-boot-final` (fresh unique id):
`variant3d/.godot_queue/results/00000549.json`: ticket **549**, wait 300.08 s,
run 56.63 s, **status ok / exit 0**. stdout (observed):

```
screenshot raw capture: .../relief_on_fixed.png.raw.png
screenshot capture diag: viewport=Screenshot3DViewport image=1280x720 p00=(0.7137, 0.9137, 1.0, 1.0) pcenter=(0.3843, 0.4, 0.1373, 1.0) camera_current=true world_parent=Screenshot3DViewport camera_pos=(22.40661, 58.0, 70.25505) target=(86.40661, 41.43565)
screenshot capture source: Screenshot3DViewport/1280x720
screenshot saved: .../relief_on_fixed.png
```

**The final PNG is now written** (not just `.raw.png`): the `screenshot saved:` line is
absent from job 532 and job 545, present in job 549. Direct image read of
`relief_on_fixed.png` confirms the same olive terrain with the grid-aligned pale marks,
buildings and trees — genuine GPU pixels, not a CPU map.

`smallmap_capture.py stats` on both the final PNG and its raw sidecar (observed):

| Metric | `relief_on_fixed.png` (final) | `relief_on_fixed.png.raw.png` |
|---|---:|---:|
| bytes | 2,449,552 | 2,449,552 |
| width × height | 1280×720 | 1280×720 |
| non_black_fraction | **0.999136** | 0.999136 |
| mean_rgb | [112.379, 119.542, 77.106] | identical |
| mean_luma | 114.972 | 114.972 |
| full_width_dark_rows | 0 | 0 |

Final and raw are byte-identical in size and stats (the final PNG is the unfiltered GPU
frame; no CPU substitution). `smallmap_capture.py scan-stderr` on
`00000549_blankcheck01-boot-final/stderr.txt` → `script_error_lines: 0`, `lines: []`.
**`SCRIPT ERROR == 0`.** The remaining stderr lines are the documented benign class
(T-MINES warning, atlas/alphavert/mill_rotor image-load warnings, flat-root PORT
APPROXIMATION warning, exit-time RID/ObjectDB leaks) — unchanged from
`RELIEF_VISUAL_01.md:118-123`.

---

## 5. No-weakening proof — exact criterion and what it rejects

`_is_blank()` returns **true (blank → 3D fails loudly)** if any of these holds over the
sampled grid (≤64×64, same stride as before):

1. `img == null` or `img.is_empty()` — unchanged from before.
2. **Non-black fraction** `lit/n < 0.02` where `lit` counts `luminance > 0.02`
   (`main.gd:1949-1950,1962-1963`) — rejects a black / near-entirely-unlit capture.
3. **Luminance variance** `lmax - lmin <= 0.02` (`main.gd:1951-1954,1964-1965`) —
   rejects a flat uniform frame (black, flat clear colour, solid white or any constant
   fill), however bright the corner is. This is symmetric: it no longer matters whether
   `p00` is sky-blue, olive or black.
4. **Distinct sampled colours** `colours.size() < 4` (`main.gd:1955,1966-1967`) — rejects
   a one-/two-tone frame with no real image content.

Only if **all three** pass does it return false (non-blank). It is not always-true:
it rejects a solid-colour capture (criterion 3 + 4), an all-black capture (2 + 3 + 4),
and a near-black capture with <2 % lit pixels (2). Rejected concretely: the flat clear
colour of V7-70 ticket 132 (`p00=(0.1059,0.1412,0.0784)`, uniform → range 0, 1 colour).
Accepted concretely: ticket 549's frame — lit 0.998, luma range 0.881, 3225 distinct
sampled colours (off-line replay §1.3), and the job wrote the final PNG (`§3.2`).

The old detector accepted a frame only if some pixel was *brighter than the top-left
pixel*; the new detector accepts a frame only if it has appreciable lit coverage,
real luminance spread and a non-trivial palette. The strictness moved from "brighter
than one arbitrary pixel" to "contains image content"; the loud 3D blank failure and
the 2D fallback call sites are untouched.

---

## 6. Open questions (UNVERIFIED — do not guess)

1. Is `0.02` the right floor for "flat" and for "lit" under a future night/dark-scene
   capture? A legitimately near-black scene with luminance everywhere ≤0.02 would be
   rejected by criterion 2. Not exercised by this fixture; no claim made.
2. Should the criterion be factored into a helper with unit tests for synthetic
   black/flat/olive images? Tests were explicitly out of scope for this ticket.
3. Does `--seq` windowed capture (`main.gd:2106`) still read the root viewport and can
   it substitute a CPU map (V7-70 §5 Q2)? `_is_blank()` is shared but that path was not
   re-tested here.
4. Relief visibility and donor parity remain unresolved (`RELIEF_VISUAL_01.md §5-6`);
   this ticket only fixes the blank-detector false positive. No donor A/B exists;
   **PORT APPROX, no donor parity claim.**
5. The first-attempt failure (ticket 545) was a defect in this worker's draft, not a
   regression in the port; recorded for transparency. No further retry was submitted
   after the corrective fix passed.

---

## 7. Summary

Before: `main.gd:1932-1942` compared sampled luminances only against the bright
top-left sky pixel; ticket 532's valid olive 1280×720 GPU frame (`non_black 0.999145`,
`mean_luma 115.039`) was misclassified blank, `main.gd:1906-1913` exited 1 and refused
to write `relief_on.png` (`RELIEF_VISUAL_01.md:17,108-123,232-234`).

After: `_is_blank()` (`main.gd:1932-1968`) judges non-black fraction, luminance range
and distinct sampled colours with symmetric tests that cannot be vetoed by a bright
corner; a blank/black/flat frame is still rejected and still fails loudly in 3D.

Backup: `inbox/backup/main.gd.bak-BLANKCHECK01` (SHA-256
`E0B4549A3F1EFA4362507090FB60C0309BDE55B220D94592ADA0EA45A85EBB84`, identical to the
pre-edit source). Validation: ticket 545 (`blankcheck01-boot`) failed on the worker's own
integer-truncation draft bug; after correction, ticket 549 (`blankcheck01-boot-final`)
passed (wait 300.08 s, run 56.63 s, exit 0), stdout contains `screenshot saved:`, the
final PNG `relief_on_fixed.png` exists (2,449,552 B, 1280×720, non-black 0.999136,
mean luma 114.972, 0 dark rows) and `SCRIPT ERROR == 0`.

Only `variant3d/scripts/main.gd` (the `_is_blank()` body only) and this report were
edited in the repo; no tests, config, assets, `world3d_terrain.gd`, `app/**`, queue
mutation or direct `godot` invocation. Concurrent edits by other workers to unrelated
files appear in `git status` and are not from this ticket. LOAD-ASYNC-01 staged-loader /
`load_ready` changes in `main.gd` are byte-identical to the backup.

---

## 8. COORD follow-up — post-hide gap (`LOAD_PROBE_REPAIR_01.md`)

### 8.1 Question and method

`reports/LOAD_PROBE_REPAIR_01.md:136-141,226-232` measured `stability_violations=11`
and `max_gap_post_us=33,515,827` (~33.52 s vs a 250,000 µs heuristic) after the
overlay hid at frame 29, and asked this `main.gd` owner to move/yield/slice any
post-hide heavy work — or report **BLOCKED** with evidence if the gap is asset /
Godot-internal rather than `main.gd` logic.

Read-only code triage located all post-hide work reachable from this file:
`main.gd:1587-1743` (`_process`: sim steps, `world.sync(dt)` at `:1671`,
`_consume_events()` at `:1713`) and the loader tail `main.gd:657-676`
(`world.sync(0.0)`, two process-frame yields, `load_ready`, `_hide_loading()`).
The atom's ticket-547 stderr backtrace does show one lazy asset decode *after*
hide — `main.gd:1671` → `world3d.gd:689 sync` → `_reconcile_entities` →
`add_building` → `_attach_rotor` → `_rotor_material` → `Image.load(mill_rotor.png)`
(36,081 B, `variant3d/assets/models/tex/mill_rotor.png`) — but its cost is not
measurable from `t_load_usability.gd` alone.

To avoid guessing, temporary timing prints (no logic change) were added to
`main.gd` after a byte-identical backup (`inbox/backup/main.gd.bak-POSTHIDE01`,
SHA-256 `72CC28D444CA9A6214B3FF7C17A9D0440140AA246B4F10FD9DB649293D3F7E17`),
one diagnostic runner job was submitted, and then **all instrumentation was
removed by restoring that backup**. Final `main.gd` hash is the same
`72CC28D…F7E17`; `git diff -- variant3d/scripts/main.gd` is **empty** (the
blank-check change has been committed by another worker into HEAD), and a text
scan finds **zero** `POSTHIDE_DIAG`/`_ld_post_diag`/`_ld_post_n`/`_warm_t`/`_diag_t0`
occurrences. No debug code ships.

### 8.2 Measurements (all via variant runner, unique ids, headless atom, same fixture)

| Ticket / id | Code state | `max_gap_post_us` | post-hide violations | run time | Notes |
|---|---|---:|---:|---:|---|
| 547 `loadproberepair01-run` (baseline, `LOAD_PROBE_REPAIR_01.md:116-141`) | clean, pre-follow-up | **33,515,827** (~33.52 s) | 11 | 91.88 s | cold first run after concurrent asset/skin work; `max_gap_loading_us=21,481,301`, overlay lifetime 41.20 s |
| 557 `blankcheck01-posthide-diag` | temporary prints only | **49,797** (~49.8 ms) | 0 | 26.64 s | instrumented `world.sync()` 3,140–25,297 µs; whole `_process()` 3,645–26,853 µs; no 33 s frame anywhere |
| 566 `blankcheck01-posthide-clean` | restored, clean final | **22,615** (~22.6 ms) | 0 | 30.72 s | stdout has no diagnostic lines; `SCRIPT ERROR == 0`; atom verdict unchanged |

The ticket-557 per-frame printout (`00000557_blankcheck01-posthide-diag/stdout.txt`)
is the direct location evidence: every one of the first ~50 post-hide frames costs
milliseconds inside `main.gd`, with inter-frame gaps 13,460–50,102 µs — all well
under the 250,000 µs ceiling. The 33.52 s baseline gap is **not reproducible** with
the same logic on a subsequent run, and the whole baseline run was ~3× slower
(loading gaps 21.48 s vs 10.49–13.33 s, overlay lifetime 41.20 s vs 19.01–23.44 s).
That pattern points to one-off cold-cache / engine asset-import cost (first decode
of shipped skins, OBJ topology, PNG textures after concurrent asset regeneration),
not a deterministic `main.gd` boot stage. Moving or slicing deterministic stages
to "fix" a non-reproducing cold-start cost would be a fake fix.

### 8.3 Verdict — **BLOCKED (no code fix applied)**

- **No `main.gd` change was made for the post-hide gap.** The blank-check fix
  (§1-5) remains intact and validated; the file was restored byte-for-byte to its
  validated state after diagnostics.
- The 33.52 s spike is attributed **inferred, not proven** to cold-cache / Godot
  asset-import cost outside `main.gd`: identical logic produced 49.8 ms and 22.6 ms
  on later runs, and direct instrumentation bounded all `main.gd` post-hide work
  to ≤27 ms/frame. A precise cold-cache attribution would require engine-side
  resource-load tracing, which this ticket cannot perform (no direct `godot`, no
  other file ownership).
- `d_no_deferred_heavy_stage` and (a) stay `UNVERIFIED / null` in the atom; no
  PASS, gate claim or "clean stderr" claim is made. Windowed R3/R5 responsiveness
  is still UNVERIFIED — headless cannot answer it.
- No queue mutation, no direct `godot`, no other repo file edited by this worker
  beyond `main.gd`, this report, and the mandated backup files.

---

*End of BLANK CHECK 01. Capture mechanics only; post-hide gap BLOCKED (cold-cache/Godot-internal, no fake fix); no donor parity claim; no ladder advancement.*
