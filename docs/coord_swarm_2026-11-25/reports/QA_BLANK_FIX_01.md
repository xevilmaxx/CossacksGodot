---
id: QA-BLANK-FIX-01
title: "Read-only QA of BLANK-CHECK-01: content-based `_is_blank()` replacement, olive-frame PASS, blank-frame FAIL, and runner PNG evidence"
agent: "QA-BLANK-FIX-01 (read-only verification subagent), coord swarm 2026-11-25"
date: 2026-11-25
status: DELIVERED__READ_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB
scope: "One new file only: this report. No source/asset/config/test/shader/PNG/JSON/stderr/git edit; no Godot submission; no queue mutation."
exclusive_output: "docs/coord_swarm_2026-11-25/reports/QA_BLANK_FIX_01.md"
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "PORT APPROX — internal consistency only. No donor GPU A/B frame exists. No donor parity claim is made anywhere in this report."
concurrency_note: "BLANK_CHECK_01.md was absent at my first glob and landed during this QA (file mtime 2026-11-25 12:51:51); I then read it in full. Runner jobs 545 and 549 also completed/landed during the QA window. All artefact reads below are from after those landings; this QA submitted no job."
verdict: "CONFIRMED (source + independent offline replay) that the replacement is content-based, symmetric, not always-true, PASSES the olive frame with wide margin and FAILS black/flat/single-/two-colour frames; AGREE with the owner's final-PNG / SCRIPT-ERROR / stats claims. Ticket 545 (`blankcheck01-boot`) did NOT write the final PNG; ticket 549 (`blankcheck01-boot-final`) did. One evidence-attribution defect noted (§5's 3225-colour figure belongs to ticket 532's frame, not 549's). No parity claim."
---

# QA BLANK FIX 01 — independent verification of BLANK-CHECK-01

## 0. Mandate and boundary

Read-only QA of `BLANK-CHECK-01`'s `_is_blank()` replacement. I did **not** edit code,
edit artefacts, submit a runner job, acknowledge/cancel anything in the queue, or
touch git. I read the landed owner report, both source versions, the runner JSONs
and stdout/stderr, re-read the PNGs with Python 3.14 / Pillow / numpy, replayed the
new criterion offline on the actual frames and on synthetic controls, and viewed
the final PNG. Statements are labelled **observed** (bytes, tool output, literal
source lines, direct image read), **derived** (arithmetic / control-flow / timeline
consequence), **inferred** (attribution without direct proof) or **UNVERIFIED**.
**No donor parity claim.**

## 1. Sources

| Kind | Source | Use |
|---|---|---|
| Owner report | `docs/coord_swarm_2026-11-25/reports/BLANK_CHECK_01.md` (all §§; claims at `:114-127`, `:159-204`, `:208-234`, `:257-280`) | Claims under test; landed during this QA |
| Prior QA | `docs/coord_swarm_2026-11-25/reports/QA_WHITE_MARKS_01.md` (`:55-91`, `:93-142`) | Pre-fix fault, ticket 532 stats, old gate mechanism |
| Source | `variant3d/scripts/main.gd:1906-1930` (gate + final write at `:1916`), `:1932-1968` (new `_is_blank()`), `:2132` (sequence call) | Post-fix code under test |
| Source | `inbox/backup/main.gd.bak-BLANKCHECK01:1932-1942` (old `_is_blank()`), `:1906-1924`, `:2106` | Pre-edit baseline; full-file diff |
| Tool source | `variant3d/tools/smallmap_capture.py:21-39` (`stats`: Rec.709 luma, `any(rgb>8)`), `:50-57` (`scan-stderr`) | Exact metric / SCRIPT ERROR formulas |
| Runner JSON | `variant3d/.godot_queue/results/00000545.json`, `00000549.json` | Ticket 545 / 549 status, exit, argv |
| Runner logs | `variant3d/.godot_queue/results/00000545_blankcheck01-boot/{stdout,stderr}.txt`, `00000549_blankcheck01-boot-final/{stdout,stderr}.txt` | Blank message, `screenshot saved:`, SCRIPT ERROR scan |
| Runner state | `variant3d/.godot_queue/status.json:10251-10275` (545), `:10291-10315` (549); `jobs/00000549.json` (queued state observed mid-QA) | Timeline / completion order |
| Artefact | `%LOCALAPPDATA%\Temp\opencode\reliefvisual\relief_on.png.raw.png` (2,450,951 B) | Olive frame with published stats 115.039 / 0.999145 |
| Artefact | `%LOCALAPPDATA%\Temp\opencode\reliefvisual\relief_on_fixed.png.raw.png` and `relief_on_fixed.png` (both 2,449,552 B) | Corrective job's raw sidecar and final PNG |
| Analysis | Temporary Python scripts in `%LOCALAPPDATA%\Temp\opencode\` (no repo file, no Godot job): criterion replica, difflib backup-vs-current, `smallmap_capture.py stats/scan-stderr` | Independent measurements |

## 2. Criterion verification

### 2.1 The replacement is content-based and symmetric — CONFIRMED (observed)

Old body (`inbox/backup/main.gd.bak-BLANKCHECK01:1937-1941`) held one reference pixel,
`var first := img.get_pixel(0, 0)`, and a one-sided `luma - first.luma > 0.02` test.
New body (`variant3d/scripts/main.gd:1932-1968`) contains **no** `get_pixel(0,0)`,
no `first` variable and no corner reference. It samples the same ≤64×64 lattice
(`step_x = width/64 = 20`, `step_y = height/64 = 11` for 1280×720) and accumulates
three frame-wide statistics:

1. `lit` — samples with `p.get_luminance() > 0.02` (`:1949-1950`);
2. `lmin` / `lmax` — float extrema updated with explicit `if l < lmin` /
   `if l > lmax` (`:1951-1954`), i.e. the integer-only `mini()`/`maxi()` defect
   described by the owner is absent from the final source;
3. `colours` — a dictionary keyed by `"%d_%d_%d" % [int(p.r*255), int(p.g*255), int(p.b*255)]`
   (`:1955`).

It returns `true` (blank) if `lit/n < 0.02` (`:1962-1963`), `lmax-lmin <= 0.02`
(`:1964-1965`) or `colours.size() < 4` (`:1966-1967`); `false` only if all three
clear. Null/empty still returns `true` (`:1933-1934`) and `n==0` returns `true`
(`:1956-1957`). These tests are symmetric — a bright corner can no longer veto
olive terrain.

Full-file diff of backup vs current (observed, `difflib.unified_diff`; 2184 → 2210
lines) shows **one** hunk: `1934-1942` → `1937-1968`, i.e. only the `_is_blank()`
body. The gate at `:1906-1913`, the final write at `:1916`, the 2D fallback at
`:1924-1929` and the sequence call (backup `:2106` → current `:2132`, a +26-line
shift from the longer function) are unchanged. Backup SHA-256 recomputed as
`E0B4549A3F1EFA4362507090FB60C0309BDE55B220D94592ADA0EA45A85EBB84` — **AGREE**
with `BLANK_CHECK_01.md:136,268-270`.

### 2.2 Offline replay on the olive frames — PASS with wide margin (observed + derived)

I replicated the GDScript loop exactly in Python (Rec.709 `get_luminance()` on
0–1 channels; the same `range(0, dim, step)` lattice) and ran it on the real PNGs.
Tool stats were recomputed with `smallmap_capture.py stats` and agree exactly with
`BLANK_CHECK_01.md:58-64,187-196` and `QA_WHITE_MARKS_01.md:61-78`.

| Frame | bytes / size | Rec.709 mean luma | non_black (tool) | samples | lit fraction | sampled luma range | distinct colours | verdict |
|---|---|---:|---:|---:|---:|---:|---:|---|
| `relief_on.png.raw.png` (ticket 532; the frame cited in the task) | 2,450,951 / 1280×720 | 115.039 | 0.999145 | 4,224 | 0.998343 | 0.881376 | 3,225 | **NON-BLANK (PASS)** |
| `relief_on_fixed.png.raw.png` (surviving sidecar, see §3.3) | 2,449,552 / 1280×720 | 114.972 | 0.999136 | 4,224 | 0.999527 | 0.881376 | 3,190 | **NON-BLANK (PASS)** |
| `relief_on_fixed.png` (final PNG) | 2,449,552 / 1280×720 | 114.972 | 0.999136 | — | — | — | — | pixel-identical to its sidecar |

No `blank_reasons` fired for either real frame. Three margins are large: lit
fraction ≈0.998–1.000 vs the 0.02 floor; sampled luma range 0.881376 vs the 0.02
floor (the global max 0.99547 lies off the 20×11 lattice; the sampled max is
0.881376 — still ~44× the threshold); palette 3,190–3,225 vs the 4-colour floor.
Note the criterion's "lit" uses `luma > 0.02` in 0–1 units (≈5.1/255) on the
sampled lattice, whereas the published `non_black_fraction` uses `any(rgb>8)` over
all pixels — related but not identical metrics; both are far above their floors.

### 2.3 Blank / flat / single-colour frames — FAIL (observed + derived)

Offline replay of the same replica on synthetic 1280×720 frames:

| Synthetic frame | lit fraction | luma range | distinct colours | blank reasons | verdict |
|---|---:|---:|---:|---|---|
| all black | 0.0 | 0.0 | 1 | all three | **BLANK** |
| uniform sky blue (182,233,255) — the old false-positive corner | 1.0 | 0.0 | 1 | range + colours | **BLANK** |
| uniform olive (88,92,29) | 1.0 | 0.0 | 1 | range + colours | **BLANK** |
| two-colour black/white halves | 0.5 | 1.0 | 2 | colours | **BLANK** |
| 1% bright / 99% black | 0.015625 | 1.0 | 2 | lit fraction (+ colours) | **BLANK** |
| 8-colour gradient | 1.0 | 0.590871 | 16 | none | **NON-BLANK (PASS)** |

The uniform sky-blue control is decisive: the *old* detector accepted it because
it is the corner value itself; the new detector rejects it via zero luma range and
one colour. The gradient and both real frames returning non-blank prove the new
test is **not always-true** — it is a genuine content discriminator. The
`colours.size() < 4` floor additionally rejects legitimate two-tone images; this
is stricter than the task's "single-colour" requirement but does not weaken blank
rejection.

### 2.4 Minor evidence-attribution defect in the owner report (observed)

`BLANK_CHECK_01.md:227-228` says "Accepted concretely: ticket 549's frame — lit
0.998, luma range 0.881, 3225 distinct sampled colours (off-line replay §1.3)".
Those numbers are the §1.3 replay of **ticket 532's** `relief_on.png.raw.png`
(→ 4,224 / 0.998343 / 0.881376 / 3,225, reproduced here). The surviving
`relief_on_fixed.png.raw.png` gives **0.999527 / 0.881376 / 3,190** instead. This
is a misattributed figure, not a numeric error in the criterion or a verdict
change: both frames PASS with wide margin.

## 3. Job evidence

### 3.1 Ticket 545 — `blankcheck01-boot` (exact id requested) — final PNG NOT written

- `variant3d/.godot_queue/results/00000545.json`: `ticket 545`, `id blankcheck01-boot`,
  `created 1795606425.9875968` (2026-11-25 12:33:45), `wait 413.96 s`, `run 53.23 s`,
  `exit 1`, `status failed`. stdout/stderr paths as listed in §1.
- `stdout.txt:4` — `screenshot raw capture: C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/reliefvisual/relief_on_fixed.png.raw.png`.
- `stdout.txt:5` — diag `image=1280x720 p00=(0.7137, 0.9137, 1.0, 1.0)
  pcenter=(0.3451, 0.3608, 0.1137, 1.0) camera_current=true world_parent=Screenshot3DViewport`.
- `stderr.txt:60` — `screenshot: windowed 3D capture is blank; no CPU fallback (visual parity UNVERIFIED)`.
  `stderr.txt:61-68` are the benign RID/ObjectDB/resource exit diagnostics.
- **No `screenshot saved:` line exists in this stdout** (6 lines total), and the
  exit is 1. The requested final PNG `relief_on_fixed.png` was therefore **not**
  written by this job; only the raw sidecar existed at that time (observed from
  stdout). In `smallmap_capture.py scan-stderr`, `script_error_lines: 0`, `lines: []`
  → **SCRIPT ERROR == 0** (observed; AGREE with `BLANK_CHECK_01.md:165`).
- Caveat (derived): the file now at that raw sidecar path has mtime 12:50:05 and
  was overwritten by ticket 549 (§3.2), so ticket 545's raw bytes cannot be
  re-read today; only the stdout line proves that sidecar existed.

### 3.2 Ticket 549 — `blankcheck01-boot-final` — final PNG written

- `variant3d/.godot_queue/results/00000549.json`: `ticket 549`,
  `id blankcheck01-boot-final`, `created 1795607050.1414564` (12:44:10),
  `wait 300.08 s`, `run 56.63 s`, `exit 0`, `status ok`.
- `stdout.txt:4-7` (observed): raw sidecar line; diag
  `image=1280x720 p00=(0.7137, 0.9137, 1.0, 1.0) pcenter=(0.3843, 0.4, 0.1373, 1.0)
  camera_current=true world_parent=Screenshot3DViewport`;
  `screenshot capture source: Screenshot3DViewport/1280x720`;
  **`screenshot saved: C:/Users/Maxym.Oboyshev/AppData/Local/Temp/opencode/reliefvisual/relief_on_fixed.png`**.
- Final PNG on disk (observed): exact path
  `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\reliefvisual\relief_on_fixed.png`,
  mtime 12:50:06, **2,449,552 B**, 1280×720; `smallmap_capture.py stats` →
  `non_black_fraction 0.999136`, `mean_rgb [112.379, 119.542, 77.106]`,
  `mean_luma 114.972`, `full_width_dark_rows 0` — **AGREE** with
  `BLANK_CHECK_01.md:189-196`. Its pixels are byte-identical to the sidecar
  (observed by direct array comparison), so no CPU map was substituted.
- Visual read (observed): olive flat-looking ground with pale stepped/concentric
  grid-aligned marks, conifers and thatched buildings at the top-right, cyan sky
  strip at the top — a genuine 3D GPU frame, not a CPU map. No rounded hill
  silhouette is visible (consistent with `QA_WHITE_MARKS_01.md:80-86`).
- `scan-stderr` on `00000549_blankcheck01-boot-final/stderr.txt` →
  `script_error_lines: 0`, `lines: []` → **SCRIPT ERROR == 0** (AGREE with
  `BLANK_CHECK_01.md:199-201`). Remaining lines are the benign warning/leak class.

### 3.3 Timeline and the first-attempt failure (derived / inferred)

File mtimes (observed): backup 12:05:11; `main.gd` (final source) **12:43:07**;
old raw 12:22:01; `relief_on_fixed.png.raw.png` 12:50:05; final PNG 12:50:06.
Ticket 545 ran ≈12:40:39–12:41:33, i.e. **before** the final source was written;
ticket 549 was created 12:44:10, i.e. **after**. The failure of 545 is therefore
consistent with the owner's account of a self-inflicted draft bug (integer-only
`mini()`/`maxi()` on float extrema → `lmax-lmin == 0` → always blank), corrected
before 549. The draft source was not preserved, so that specific cause is
**INFERRED**, not independently verified; the symptom (blank line, no
`screenshot saved:`, no SCRIPT ERROR) and the before/after timeline are observed.

## 4. Verdict

1. **Content-based, symmetric criterion: CONFIRMED (observed).** Old top-left,
   one-sided comparator is gone; new tests are non-black fraction, luma range and
   distinct sampled colours. `git diff` equivalent shows only the `_is_blank()`
   body changed; all call sites and the loud 3D gate are untouched.
2. **Olive frame PASSES: CONFIRMED (observed + derived).** The exact frame cited in
   the task (`relief_on.png.raw.png`, mean luma 115.039, non-black 0.999145) replays
   as non-blank (4,224 samples, lit 0.998343, range 0.881376, 3,225 colours). The
   corrective job's frame also passes (0.999527 / 0.881376 / 3,190).
3. **Blank/black/flat/single-colour frames FAIL: CONFIRMED (derived from source +
   offline replay).** Black, uniform sky blue, uniform olive, two-colour and 1%-lit
   controls all return blank; an 8-colour gradient and both real frames return
   non-blank, so the check is **not always-true**.
4. **Owner stats: AGREE.** All published byte counts, luma means, non-black
   fractions, dark-row counts, the backup hash and `SCRIPT ERROR == 0` reproduce.
5. **Runner PNG evidence: AGREE with a scope nuance.** Ticket 545
   (`blankcheck01-boot`) did **not** write the final PNG — raw sidecar only, exit 1.
   Ticket 549 (`blankcheck01-boot-final`) did — `screenshot saved:` line, exit 0,
   final PNG 2,449,552 B on disk with stats matching the raw sidecar. The file now
   at the shared path belongs to 549, not 545.
6. **Defect noted (observed):** `BLANK_CHECK_01.md:227-228` attributes ticket 532's
   3,225-colour replay to ticket 549's frame (actual 3,190). No verdict impact.
7. **Overall:** the replacement is a genuine fix for the false positive and keeps
   loud failure for blank 3D captures. **PORT APPROX — no donor parity claim.**

## 5. Open questions

1. The first-attempt draft source (integer `mini()`/`maxi()`) was not preserved;
   its causal role in ticket 545 is **INFERRED** from symptom + timeline, not
   independently verified. UNVERIFIED.
2. A legitimately near-black scene with luminance everywhere ≤0.02 would be
   rejected by the lit/range floors. Not exercised by this fixture; UNVERIFIED
   (also `BLANK_CHECK_01.md:240-242`).
3. The shared detector's effect on the sequence-capture path (`main.gd:2132`) was
   not re-tested; UNVERIFIED.
4. My replay is a Python replica of the GDScript loop, not a Godot-runtime unit
   test of synthetic frames (tests were out of scope). Rec.709 `get_luminance()`
   behaviour is corroborated by the reproduced 115.039 mean, but synthetic-frame
   verdicts are **derived** rather than observed in Godot. UNVERIFIED at runtime.
5. Ticket 545's original raw sidecar bytes were overwritten by ticket 549; a
   direct re-read of 545's captured frame is UNVERIFIED.
6. Relief visibility/hills and donor parity remain unresolved (`QA_WHITE_MARKS_01.md
   §3.4-5`); no flag-on/off pixel A/B and no donor GPU frame exist. No parity claim.

## 6. Summary

`BLANK-CHECK-01` replaced the old top-left one-sided `_is_blank()` with three
symmetric, frame-wide tests (non-black fraction, luma range, distinct colours).
Independent source diffing confirms that this is the **only** change and that the
loud 3D gate and all call sites are untouched. An offline replica of the exact
GDScript loop on real PNGs shows the cited olive frame (mean luma 115.039,
non-black 0.999145) and the corrective job's frame both PASS with wide margins
(lit ≈0.998–1.000, range 0.881376, palette 3,190–3,225), while black, uniform
sky-blue, uniform olive, two-colour and 1%-lit controls all FAIL and a gradient
PASSES — so the check is content-based and not always-true. Runner evidence:
ticket `blankcheck01-boot` (545) exited 1 with the blank message and **no final
PNG**; ticket `blankcheck01-boot-final` (549) exited 0, logged `screenshot saved:`,
and wrote `relief_on_fixed.png` (2,449,552 B, 1280×720, non-black 0.999136, mean
luma 114.972, 0 dark rows, pixel-identical to its raw sidecar) with **SCRIPT ERROR
== 0**. One cosmetic attribution defect in the owner's §5 is noted. All other
published statistics reproduce exactly. **No source, artefact, queue or git change
was made by this QA, and no donor parity claim is made.**

---

*End of QA BLANK FIX 01. Read-only verification; one new report file; no code, config, artefact or queue change.*
