---
id: L06
ticket: "INTEGRATION wave / L06 — independent re-review of the g04 capture pair (owner: chessboard + contour)"
title: "L06 — capture re-review: owner-statement confirmation + C04 R1–R6 verdicts on g04/p0_64.png and g04/realmap.png"
role: "QA / READ-ONLY / SECOND AGENT (independent of the frame builders; no Godot, no runner, no code edit)"
owner: L06
created: 2026-11-25
status: COMPLETE__OWNER_STATEMENTS_CONFIRMED__R1_TO_R6_FAIL__R7_R8_UNVERIFIED__DONOR_PARITY_UNVERIFIED
scope: "Exactly one repo file written: docs/terrain_swarm_2026-11-25/reports/L06_capture_rereview.md. No .gd/.gdshader/config/asset/test/tool/fixture/result/gate/donor edit; no Godot process; no runner submission or queue mutation. Two read-only Python probes were written and run OUTSIDE the repo under C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\ (l06_capture_probe.py, l06_capture_probe2.py); they are scratch, not evidence artifacts."
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED]
parity_guard: "PORT APPROX — internal consistency only. No donor GPU A/B frame exists. This review makes NO donor-parity claim and certifies neither donor fidelity nor a gate pass (CHARTER.md:55-58,122-130; C04 §0,§5)."
sources_read:
  - docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
  - docs/terrain_swarm_2026-11-25/CHARTER.md
  - docs/terrain_swarm_2026-11-25/reports/C04_visual_review.md
  - docs/terrain_swarm_2026-11-25/reports/G05_visual_review.md
  - docs/terrain_swarm_2026-11-25/reports/G04_gate_log.md
  - docs/terrain_swarm_2026-11-25/reports/L02_chessboard_review.md
  - docs/terrain_swarm_2026-11-25/reports/L07_reverify_batch.md
  - "captures opened directly: C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\g04\\p0_64.png and ...\\g04\\realmap.png"
  - "scratch autocontrast zooms opened for corroboration: ...\\Temp\\opencode\\l02_new_zoom.png, l02_old_zoom.png (authored by L02, not this agent)"
---

# L06 — independent re-review of the two g04 captures

## 0. Authority, method and label discipline

- I am independent of the six implementation owners and of G04's runner work. I wrote only this report. **I did not run Godot, submit a runner job, mutate the queue, or edit any repo file other than this report** (`WAVE_G_CHARTER.md:31`; `CHARTER.md:55-69`).
- **OBSERVED** = a literal pixel/region fact or a document fact with a path/box. **DERIVED** = arithmetic or control-flow consequence of OBSERVED facts. **INFERRED** = a plausible cause or comparative judgement, always caveated. **UNVERIFIED** = not provable from the available material (donor parity, missing capture, off-screen subject). UNVERIFIED is never converted to PASS (`C04 §1`).
- Per C04 §1 rule 1, **the frames are described in words before any verdict** (§1 below). The owner-statement checks come only afterwards (§2), then the R-item verdicts (§3).
- **L03 report not found.** The ticket directed me to read an `L03` report. I checked the reports directory repeatedly; at write time it contains `L01_spot_grass.md`, `L02_chessboard_review.md`, `L04_perf_integration.md` and `L07_reverify_batch.md`, but **no L03 file**. Its content is therefore **UNVERIFIED — not read**. I substituted the available integration-wave context (L02 chessboard cause, L07 defect-baseline mapping) and made every visual finding directly from the two PNGs. This is an evidence-completeness note, not a claim about L03's contents.

## 1. Describe the visible ground patterns BEFORE any verdict (C04 §1 rule 1)

### 1.1 `...\Temp\opencode\g04\p0_64.png` — whole-frame description (OBSERVED)

1280×720, non-blank. The **entire** frame is one uninterrupted field of muted olive-green. There is **no sky, no horizon, no water, no HUD, no unit, no building, no tree, no relief silhouette and no shore**; corners and centre share the same olive fill. Fine per-pixel grain is present everywhere, and on top of it there is a **soft, slightly blurry light/dark patchwork**: irregularly lighter and darker soft squares tessellate the whole field, with faint straight seams between them. At native scale the contrast is low — the pattern reads as a gentle "quilt" or checker of soft spots rather than crisp squares. No grey rock face, no dark full-width row, and no crisp 45° diagonal line is distinguishable.

Opened L02's scratch autocontrast zoom `l02_new_zoom.png` as corroboration (OBSERVED, scratch artifact of another agent): it makes the structure explicit — a **rigid rectangular cell lattice with straight cell seams**; inside the cells, two regularly alternating appearances: **(a) pale cells filled with fine horizontal "barcode" striping**, and **(b) darker cells with soft lacy/blob texture**. The alternation is locked row-for-row and column-for-column: a pale cell has darker neighbours above/below and left/right. The companion zoom of the old frame (`l02_old_zoom.png`) is featureless pepper-grain — no cells, no lattice. So the lattice is a property of this new frame, not of the atlas art.

**Period/colour estimate** (OBSERVED for appearance, DERIVED/INFERRED for numbers):

| Property | Estimate | Label / basis |
|---|---|---|
| Pattern | Light/dark soft-square quilt on a rigid cell lattice; pale horizontal-striped cells alternating with dark lacy cells | OBSERVED (native frame + autocontrast zoom) |
| Region | Whole ground band; no region exempt — centre, corners, upper and lower fields all carry it | OBSERVED (whole-frame scan) |
| Period | World-space **2 m cell** lattice; apparent on-screen cell pitch roughly **60–90 px** in the central field (visual estimate). C01's `tile_period_px=64` on the earlier P0 frame and L02 §2.3's `key=floor(v_st*uv_repeat)` give the same cadence. My screen-space 64 px block probe did **not** find clean axis-aligned 64 px blocks (camera projection), so the exact on-screen period is INFERRED, not measured | OBSERVED pattern / INFERRED period |
| Colour | Base olive-green; pale cells light yellow-olive, dark cells darker brown-olive. Native mean RGB **[94.562, 97.418, 32.367]**, mean luma **92.134**, σ ≈ **4.3** (low native contrast); enhanced zoom exaggerates the light/dark split | OBSERVED pixel stats (probe + `G04_gate_log.md:220-228`); colour names OBSERVED |

### 1.2 `...\Temp\opencode\g04\realmap.png` — whole-frame description (OBSERVED)

1280×720, non-blank. This is a **populated real-map scene**: a large dark-brown wooden building with a steep shingled roof and a small tower stands near the centre; two smaller thatched-roof huts flank it below; small unit figures and a few conifer/deciduous trees are scattered around. The **ground is covered, nearly edge to edge, by dense wavy nested bands** — long serpentine loops, stepped concentric rings and labyrinth-like corridors made of alternating tan, olive, dark-brown and grey-green stripes. The rings close around the building, the huts and the small circular unit clusters. Clearings exist (notably the lighter patch under the building/huts with a visible **lighter square checker** of grey/tan blocks, and a few small round patches carrying units), but they are islands in a field of contour texture. There is **no cyan water anywhere**; no full-width dark row; no natural grey rock face that reads as relief.

The pattern is **not** a set of straight parallel streaks: it is curved, nested and maze-like. In C04's historical shore boxes (right x1050–1280/y420–470; bottom-right x850–1280/y610–720; bottom-left x0–95/y560–600) the same contour/olive ground is present — no water boundary. A read-only blue-dominance probe found a blue-dominant pixel fraction of ~0.00002 for the whole frame and **0.0 in every named water box**, corroborating "no water" (OBSERVED/DERIVED).

**Period/colour estimate**:

| Property | Estimate | Label / basis |
|---|---|---|
| Pattern | Dense topographic **contour / maze**: nested stepped rings, serpentine corridors, closed loops around buildings and unit clusters | OBSERVED (whole frame, all three ground strips y40–220 / y220–500 / y500–690) |
| Region | Nearly the entire ground; strongest in top-left, top-right and bottom bands; clearings only around the building/huts and unit clusters | OBSERVED |
| Period | Fine band pitch roughly **10–25 px** between adjacent nested stripes; macro loop wavelength roughly **120–250 px**. A read-only row-autocorrelation of the top strip shows secondary peaks at lags **15–16 px** and ≈**47 px**, consistent with a fine stripe pitch and a coarser repeat | OBSERVED spacing / DERIVED from probe |
| Colour | Olive grass base with alternating tan/brown/grey-green contour bands; mean RGB **[90.471, 86.357, 39.123]**, mean luma **83.828**, σ ≈ **20.95** — far higher contrast than p0_64 | OBSERVED pixel stats (probe + `G04_gate_log.md:237-246`) |

## 2. Owner-statement verification (after the description)

### 2a. "p0_64 is preferable to the old flat olive but shows a light/dark CHECKERBOARD" — **CONFIRMED, with one caveat on the word "preferable"**

- **Checkerboard half — CONFIRMED (OBSERVED + DERIVED).** The new frame visibly carries a light/dark soft-square quilt across the whole field (§1.1); L02's autocontrast zoom resolves it as a rigid cell lattice with pale striped cells alternating with dark lacy cells, and L02 §2.3 derives the exact cause: the per-cell mirror variant `v = mod(key.x + 3*key.y, 4)` with `f = step(...)` and `mix(local_uv, 1.0-local_uv, f)`, i.e. a 4-phase diagonal-stripe flip on the 2 m world-cell lattice. L02 §2.1–2.2 rules out the alpha patch (constant on the all-id-0 P0 fixture) and the atlas art (same art in the old frame, no lattice there). My own native read agrees: the old frame's scratch zoom is featureless grain, this frame's is a lattice.
- **"Preferable to the old flat olive" — subjective, not certifiable (INFERRED).** The old baseline `p0_final_formula.png` was a uniform olive field with fine grain and faint near-horizontal lamination (G05 §2.1); this frame is softer and lower-contrast (σ ≈4.3 vs old σ ≈10.2 per L02 §1), consistent with the owner's stated preference for the smoother look. I can confirm the *difference* and that the softer look is consistent with the preference; "preferable" remains the owner's judgement, not a measured quality gate.
- **No donor parity claim.** Comparing old versus new frames is internal PNG-vs-PNG only.

### 2b. "realmap is covered in dense topographic CONTOUR/MAZE patterns" — **CONFIRMED**

OBSERVED across all three C04 ground strips: nested stepped rings and labyrinth corridors cover essentially the whole ground, with closed rings around the building, huts and unit clusters (§1.2). Period ~10–25 px fine bands, ~120–250 px macro loops. This matches the contour defect catalogued by L07 §1 / B04 (`g04/realmap.png` is named there as the "contour defect baseline": "dense concentric topographic contour / maze patterns — nested stepped rings across nearly the whole frame"). I make **no claim about why** beyond the cited L07/B04 mapping; the cause of the rings is INFERRED from those reports, not established by a GPU A/B in this review.

## 3. C04 R1–R6 verdicts (PASS / FAIL), with R7/R8 status

These are verdicts on **the two defect-baseline captures under review**, not on any post-fix frame. No fresh capture was produced by me. Each row keeps OBSERVED / DERIVED / INFERRED / UNVERIFIED separate.

| Item | Result | Driving capture / region | OBSERVED | DERIVED | INFERRED (caveated) | UNVERIFIED |
|---|---|---|---|---|---|---|
| **R1** Tiling periodicity / grid / checker | **FAIL** | p0_64 whole field; realmap all strips + building/hut clearings | p0_64: rigid light/dark soft-square quilt with straight cell seams, whole field; pale cells alternate with dark cells at cell cadence. realmap: nested stepped rings + lighter square checker around building/huts | 2 m world-cell cadence (L02 §2.3 `key=floor(v_st*uv_repeat)`); apparent pitch ~60–90 px in p0_64 | Cause of p0_64 lattice is the per-cell mirror (L02 DERIVED); realmap rings match the reverted B04 attempt (L07) | Donor-matched camera; any post-fix frame |
| **R2** Diagonal streaks / moiré | **FAIL** | p0_64 pale cells (whole field); realmap curved rings (recorded, not a straight-streak finding) | p0_64 pale cells carry regular fine **horizontal barcode striping**; L02 zoom shows grid-locked alternating strokes. realmap bands are curved/nested, not straight parallel strokes | C04 R2's "regular parallel strokes/bands that read as repetition" is met by the p0_64 barcode striping | 4-phase diagonal-stripe lattice phase from L02 §2.3 is consistent with the strokes; no cause proven by one pose | Camera-dependence of the striping (single pose per capture) |
| **R3** Dark blotches / repeated dark patches | **FAIL** | p0_64 whole field; realmap contour bands | p0_64 darker lacy cells recur at cell cadence, identically classed; realmap has repeated dark contour bands. **No full-width dark row** in either (`full_width_dark_rows=0`, G04 §5.1) | 0 dark rows on both frames (stats); recurring dark patches still present → item fails on recurrence, not on rows | Dark cells are the dark half of the mirror lattice (L02), not relief shadow | Whether any dark region is genuine relief/shadow (no matched-camera A/B) |
| **R4** Multi-scale organic colour variation | **FAIL** | p0_64 whole ground band; realmap whole ground band | p0_64: flat olive field with fine grain + grid only; no large-scale organic mottling, no grey rock. realmap: large-scale variation exists but is the synthetic maze, not organic mottling | Native σ_luma 4.3 (p0_64) vs 20.95 (realmap); realmap's variance is dominated by contour bands, not organic patches | Compared in words to `CHARTER.md:23-24` feature list (soft green mottling, dark/light patches, ravines/cliffs): neither frame reads like the samples. Comparative judgement only — **not donor parity** | Donor GPU A/B frame (none exists) |
| **R5** Relief / cliffs / seams | **FAIL** | realmap y40–690, incl. historical boxes and around buildings/starts | realmap: dense concentric contour rings / maze, nested stepped outlines, rings around building/huts/unit clusters; no natural grey rock face; no new seam, z-fighting, black row or white stepped band observed in the scanned boxes | Contour pattern covers all three strips | Matches L07 §1 / B04 contour regression; cause INFERRED from those reports, not proven here | Real map's "true" intended relief (no donor-matched frame) |
| **R6** Shore / water boundary | **FAIL** *(evidence UNVERIFIED — no water in either frame; required item cannot PASS)* | realmap prior water boxes (right/bottom-right/bottom-left) + whole frame | No cyan water anywhere; blue-dominant fraction ~0.00002 whole frame, **0.0 in all three named water boxes**; those boxes contain only contour/olive ground. p0_64 also water-free | `full_width_dark_rows=0` on both frames; dark-row predicate is diagnostic here (water-free), not applicable | None offered | Shore transition, water tint, water-on-grass `grass1`, water-attributable dark rows — all UNVERIFIED with no water to inspect (`C04 §1`; G05 R6 precedent) |
| **R7** Selection quad during drag | **UNVERIFIED** | N/A | No before/during/after PNGs, no `frames.json` opened | N/A | N/A | Quad geometry/lifetime/hit semantics; capture path (`C04 §2 item 6`, Trap A/B) |
| **R8** Ghost final stage | **UNVERIFIED** | N/A | No `ghost_valid`/`ghost_invalid` frames opened | N/A | N/A | Ghost stage/colour/footprint/clear-on-cancel; stage-1 substitution neither confirmed nor cleared |

**Summary:** R1–R5 = **FAIL** on the reviewed pair; R6 = **FAIL for missing evidence** (the underlying visual state is UNVERIFIED because no water exists in the frame — this is never a PASS). R7/R8 = **UNVERIFIED** (no CAP-3 quad/ghost capture was supplied to this review). No donor-parity certification is issued.

## 4. Corroborating numbers — smoke measurements only, never a gate

Verbatim from `G04_gate_log.md §5.1` (owner's runner, not mine):

- p0_64: `non_black_fraction = 1.0`; `mean_rgb = [94.562, 97.418, 32.367]`; `mean_luma = 92.134`; `full_width_dark_rows = 0`; `width=1280 height=720`.
- realmap: `non_black_fraction = 1.0`; `mean_rgb = [90.471, 86.357, 39.123]`; `mean_luma = 83.828`; `full_width_dark_rows = 0`; `width=1280 height=720`; diag `camera_current=true`, `world_parent=Screenshot3DViewport`.
- Both jobs `script_error_lines=0` (G04 §5.1). Windowed, non-blank, 1280×720 → CAP-1/CAP-2 integrity prerequisites are met; **CAP-3 is absent**, so C04 §7 item 1 cannot pass as a whole.

My read-only probes (`l06_capture_probe.py`, `l06_capture_probe2.py`, NumPy/Pillow, no Godot) reproduced the same means and added: p0_64 σ_luma ≈4.3; realmap σ_luma ≈20.95; top-strip row-autocorrelation secondary peaks at lags 15–16 px and ≈47 px; blue-dominant fraction ~0 in all named water boxes. These numbers **corroborate** the visual reads (soft low-contrast quilt vs high-contrast contour field) but are **not** fidelity gates, not thresholds, and not donor proof (`C04 §5`; C01 tool's own "SMOKE METRIC — NOT a fidelity gate or donor proof" label). No metric overrode a visual verdict above.

## 5. Honesty / provenance ledger

- **OBSERVED:** both PNGs opened directly and described before verdict (§1); pixel stats via read-only probe; document facts from the six required/available reports with line anchors; absence of water in all named boxes; no full-width dark rows.
- **DERIVED:** 2 m cell cadence and screen pitch estimates from L02 §2.3 + C01 `tile_period_px=64`; ring pitch from the row-autocorrelation probe; "chequerboard exists only in the new frame" from L02's same-art argument; σ comparison.
- **INFERRED (caveated):** "preferable" is the owner's subjective judgement consistent with lower grain contrast; p0_64 lattice cause is the per-cell mirror (L02's derivation, no shader-only GPU A/B); realmap rings match the B04 contour regression (L07 mapping); both frames fail the `CHARTER.md:23-24` feature comparison — comparative, not parity.
- **UNVERIFIED:** L03 report content (file not present); donor parity (no GPU A/B frame ever produced); camera-dependence of strokes; real map's intended relief; all R7/R8 subjects; any post-fix frame.
- **Scope compliance:** no Godot, no runner job, no queue mutation, no process kill, no test/threshold/assertion change, no donor file copied, no code/asset/config edit. One repo file written — this report. Two scratch probes only in Temp, outside the repo.

## 6. Required closing statement (C04 §7 sign-off, verbatim)

> **"PORT APPROX — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."**

## 7. Hand-off to COORD

1. Both owner statements are **confirmed**: p0_64 shows the light/dark checkerboard (and is the softer frame the owner prefers), and realmap is covered in dense topographic contour/maze patterns. R1–R5 therefore FAIL on these baselines; R6 FAILs for missing evidence (no water); R7/R8 remain UNVERIFIED.
2. These are **pre-fix defect baselines** (L07 §1: `g04/p0_64.png` = chessboard baseline; `g04/realmap.png` = contour baseline). This review does **not** evaluate any post-fix frame; such a frame must be a fresh, provenance-labelled capture opened by a second agent.
3. L03 was **not available** at review time; if it exists elsewhere, COORD should supply it before this ticket is considered fully briefed.
4. No fix was applied here and no gate was advanced. Donor parity stays UNVERIFIED.

---

*End of L06. One report written; no Godot run, no runner job, no code, config, asset, test, tool, fixture, result, gate or donor edit; no donor-parity claim; no PASS verdict on any charter §5 item.*
