---
id: SEQ-WIDE
swarm: TERRAIN-SWARM-2026-11-26 / DONOR-TERRAIN VISUAL WAVE
role: WORKER SEQ-WIDE — read-only 24-frame image-sequence analysis; reports to COORD
owner_file: docs/terrain_swarm_2026-11-26/reports/SEQ_WIDE_analysis.md
reports_written: [docs/terrain_swarm_2026-11-26/reports/SEQ_WIDE_analysis.md]
files_edited: []
date: 2026-11-26
status: DELIVERED__ONE_REPORT_ONLY__READ_ONLY__NO_CODE_EDIT__NO_GODOT__NO_GIT__NO_DONOR_EXECUTION
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_claim: false
parity_status: UNVERIFIED
parity_guard: "No donor GPU A/B frame exists. Donor video frames are direction-of-appearance references only. No similarity score, donor threshold, parity claim or gate PASS is made."
scope_guard: "Exactly one repository file written: this report. No source, shader, config, asset, test, fixture, result JSON, git state, Godot process or donor binary was changed or executed. Pillow/NumPy probes were read-only on inputs with outputs only under %TEMP%\\opencode (seqwide_q*.py, seqwide_metrics.json)."
---

# SEQ-WIDE — 24-frame donor_240_final pan as video (temporal stability)

> **PORT APPROXIMATION — candidate self-consistency only; donor parity UNVERIFIED.**
> No donor GPU A/B frame exists. All metric values are per-image support cues,
> not cross-image similarity, donor thresholds, or pass/fail gates.

## 0. Executive result

1. **[O] The 24-frame sequence is temporally stable in the sense that matters for
   shader/atlas motion bugs: no crawl, shimmer, or swimming.** Clean-grass ROI
   `[500,500,900,700)` is bit-stable from frame 0012 onward (Y 70.5–70.8,
   std 8.6–9.6, bv32 1.99–2.33, gp95 14.1–15.6 on frames 12–23 except where the
   shore plateau or relief crosses the ROI). Frame-to-frame MAD (320×180 Y)
   falls monotonically 15.0 → 4.1 as the analytic smoothstep pan decelerates
   into its end stop; there is no mid-pan MAD spike that would indicate a pop,
   plate entry, or LOD snap. This matches PHOTO_SEQUENCE_review observation 1/6
   (no atlas crawl) on the newer `donor_240_final` path.
2. **[O] The instability that exists is world-locked content entering/leaving
   frame, not temporal flicker.** Full-frame relief fraction (Y<60) drops
   0.29 (f00) → 0.10 (f07, clean grass) → 0.21 (f11, relief re-enters) →
   0.09 (f21–23, empty grass). Top-half vs bottom-half dark32 splits confirm
   stamped relief patches crossing the frame, not a global brightness pulse:
   f00 top 0.156 / bottom 0.183; f04 top 0.130 / bottom 0.154; f10 top 0.118 /
   bottom 0.050; f16 top 0.090 / bottom 0.002 (shore plateau occupies top).
3. **[O] Dark chevron relief dominates frames 0–4 and 10–12; the shore/sand
   plateau dominates frames 14–18; frames 19–23 are near-empty grass.**
   Exact frames/ROIs in §2. Peak chevron anisotropy 0.688–0.691 (f15–16,
   full-frame, shore-edge boosted) and 0.524–0.535 on the pure-relief frames
   0–3; pure-grass frames 20–23 sit at 0.534–0.541 with bv32 ≈ 1.9–2.2
   (flat). Clean-grass ROI on relief-contaminated frames 0–3 shows
   Y std 20.9–22.9, bv32 14.3–16.8, dark32 0.32–0.42 vs 8.6 / 2.0 / 0.0002 on
   clean frames — the ROI itself is crossed by stamps, the grass material is
   not flickering.
4. **[O] Sparse forest is confirmed across the pan: isolated bare/dark sticks,
   never a grove.** Dark20 (maxRGB≤20) pixel count peaks at only 6,069 px /
   0.66% (f16, includes shore-edge dark bands) and falls to ~320 px / 0.03%
   on f21–23 (1–2 visible saplings). No frame shows a closed canopy, grove
   edge, or glade structure. Consistent with REVIEW3 rank 8.
5. **[O] Field squares do NOT dominate this pan — they are absent from it.**
   The gold_like spike on f14–18 (up to 0.1245 / 114,745 px) is the sand/shore
   plateau (top-half density 0.22 vs bottom 0.025 on f16; sand bbox rows
   0–701, cols 0–1150), not crop parcels. Field squares dominate only the
   pinned stills (`cap_donor_240m/n/hires`, right side ≈ [950,300,1280,550],
   green-tuft grid; hires gold only 0.026). No golden parcel class crosses the
   24-frame pan.
6. **[D] Direction-only donor comparison: donor grass is multi-scale and less
   saturated; candidate grass is flat and over-saturated; donor relief never
   shows the chevron lattice.** Donor V1/V2 at 120/300/1200/1800 s: bv32
   15.8–20.6, sat 0.52–0.58, anis 0.21–0.49. Candidate clean frames 20–23:
   bv32 1.9–2.2, sat 0.732. Candidate relief frames: anis 0.52–0.69 with nested
   diagonal bands (f00 right half dark 0.48–0.54 in x[960,1280); f12 left
   x[160,320) dark 0.44). Shore plateau f14–18: pale_low_sat up to 0.0088 /
   8,098 px with striped transition edges (visible f16 top band). No parity
   claim; donor build/map/camera/zoom/compression unknown.

## 1. Inputs, method, and camera contract

### 1.1 Inputs read

- 24-frame pan: `%TEMP%\opencode\v42\video\donor_240_final\frame_0000.png` …
  `frame_0023.png` (all 1280×720, RGBA→RGB for metrics).
- `…\donor_240_final\capture.json` (camera contract + timing, §1.2).
- `inbox/qa/captures/contact_wide-final.png` (frames 0/4/8/12/16/20/23 sheet).
- Stills: `%TEMP%\opencode\v42\cap_donor_240m.png`,
  `cap_donor_240n.png`, `cap_donor_240_hires.png`, `cap_donor_240h.png`
  (m ≡ n bit-near-identical: Y 69.9/70.0, sat 0.7165/0.7167).
- Prior reports: `REVIEW3_latest.md` (ranks 1–10 + fix ranking),
  `PHOTO_SEQUENCE_review.md` (6 observations), `DONOR_VIDEO_analysis.md`
  (§3–§6 baselines, V1/V2 evidence catalog).
- Donor direction frames: `%TEMP%\opencode\donor_videos\selected\cZW0AEupCaI\`
  `t_120/300/1200/1800.png` + `\ljlCn4KSSU4\` `t_300/600/1200/1800.png`
  (V2 has no `t_120.png`; `t_600.png` substituted).

### 1.2 Capture contract (from `donor_240_final/capture.json`)

Deterministic smoothstep X pan 60→420 sim-m at Y 240, height 58 m,
pitch −32°, yaw 0°, FOV 17.27°, zoom 0.3448276, sim clock frozen, 24 frames /
4 s presentation. Timing: wall 5,499 ms, max frame 299 ms (f11),
median 214 ms, target 6 fps, `real_time_claim=false` — capture/readback wall
time only, not gameplay FPS. Max analytic step ≈ 23.5 sim-m/frame mid-pan.

### 1.3 Metric definitions (support cues only)

Boxes `[x0,y0,x1,y1)`, origin top-left. Y = 0.2126R+0.7152G+0.0722B;
saturation = (max−min)/max; gradient = central differences; anis = 12-bin
15° orientation anisotropy weighted by max(grad−median,0); BV32 = std of 32×32
luminance block means; dark16/20/32 = maxRGB≤16/20/32; pale_low_sat =
Y>105 & sat<0.42; gold_like = R>B+30 & G>B+15 & R>90; relief = Y<60.
MAD = mean abs Y difference at 320×180 between adjacent frames.
No cross-image similarity or donor threshold is derived from any of these.

## 2. Frame-by-frame findings (exact frames/ROIs)

### 2.1 Full-frame temporal table (all 24 frames)

| Fr | Y mean/std | sat | dark32 | relief Y<60 | grad p95 | anis | bv32 | MAD←prev | Read |
|---|---|---|---|---|---|---|---|---|---|
| 00 | 62.2/18.9 | .650 | .1692 | .2876 | 17.64 | .526 | 14.26 | — | chevron relief N+E+S, §2.2 |
| 01 | 62.1/19.0 | .649 | .1728 | .2894 | 17.67 | .524 | 14.36 | 8.30 | same stamps, shifted |
| 02 | 62.1/19.0 | .650 | .1714 | .2892 | 17.66 | .524 | 14.28 | 12.36 | same stamps, shifted |
| 03 | 61.7/19.1 | .647 | .1770 | .2971 | 17.65 | .528 | 14.38 | 15.04 | peak relief fraction |
| 04 | 63.3/17.9 | .664 | .1418 | .2646 | 16.72 | .508 | 13.72 | 15.02 | relief exits right, left band remains |
| 05 | 66.1/15.6 | .690 | .0869 | .2047 | 16.07 | .510 | 11.59 | 12.98 | transition |
| 06 | 69.4/12.0 | .717 | .0284 | .1333 | 15.68 | .489 | 6.89 | 9.19 | mostly grass |
| 07 | 70.6/9.8 | .728 | .0040 | .1039 | 15.11 | .489 | 2.69 | 6.03 | clean grass + sticks |
| 08 | 70.5/9.9 | .726 | .0048 | .1066 | 15.04 | .488 | 2.98 | 5.20 | clean grass + sticks |
| 09 | 69.3/12.2 | .714 | .0241 | .1342 | 16.16 | .477 | 5.74 | 6.37 | relief re-enters |
| 10 | 66.1/15.8 | .685 | .0837 | .2017 | 17.60 | .507 | 9.91 | 9.18 | relief patch crosses |
| 11 | 65.7/16.3 | .681 | .0945 | .2128 | 17.54 | .527 | 10.49 | 11.93 | relief + disc zone |
| 12 | 67.1/14.7 | .696 | .0710 | .1820 | 16.41 | .535 | 9.52 | 11.27 | relief W + deposit disc |
| 13 | 70.6/11.0 | .719 | .0139 | .1122 | 15.81 | .583 | 3.59 | 8.43 | grass, shore enters top |
| 14 | 71.0/13.4 | .705 | .0225 | .1241 | 18.96 | .612 | 4.95 | 6.66 | shore plateau enters |
| 15 | 71.8/16.9 | .680 | .0398 | .1399 | 24.16 | .688 | 8.03 | 8.19 | shore + striped edge |
| 16 | 71.6/17.9 | .669 | .0463 | .1545 | 26.23 | .691 | 8.71 | 10.09 | peak shore (sand 8,098 px) |
| 17 | 71.7/16.7 | .679 | .0359 | .1423 | 21.53 | .673 | 8.57 | 10.05 | shore recedes |
| 18 | 71.4/14.1 | .700 | .0215 | .1245 | 17.20 | .611 | 7.11 | 7.92 | shore remnant NW |
| 19 | 71.1/11.0 | .719 | .0101 | .1069 | 15.32 | .549 | 4.59 | 6.25 | grass |
| 20 | 70.9/9.0 | .729 | .0030 | .0971 | 14.46 | .534 | 2.22 | 5.34 | near-empty grass |
| 21 | 71.0/8.6 | .731 | .0005 | .0947 | 14.17 | .541 | 1.93 | 4.73 | near-empty grass |
| 22 | 71.0/8.6 | .731 | .0005 | .0938 | 14.21 | .535 | 1.94 | 4.61 | near-empty grass |
| 23 | 71.0/8.6 | .731 | .0005 | .0941 | 14.23 | .537 | 1.94 | 4.12 | near-empty grass |

Evidence: `%TEMP%\opencode\seqwide_metrics.json` (full table) + scripts
`seqwide_q.py / q2 / q4` (temp only, not in repo).

### 2.2 Dark chevrons — exact frames/ROIs (relief Y<60 column profile)

- **f00**: relief 0.2876; east half dominant — x[960,1120) 0.480,
  x[1120,1280) 0.540; south band [500,400,1280,650)-class patch + N/E arms.
  Direct view: nested olive/near-black diagonal bands at approx
  `[250,0,700,260)` (N arm), `[950,0,1280,420)` (E arm),
  `[500,400,1280,650)` (S patch). Anis 0.526.
- **f01–f03**: same stamp complex, world-locked shift (MAD 8.3→15.0 follows
  smoothstep velocity). f03 peak relief 0.2971.
- **f04**: relief 0.2646; weight moves west — x[320,480) 0.424,
  x[480,640) 0.474 vs x[960,1280) ≤ 0.103. Chevron lattice still
  covers left 2/3.
- **f09–f12 (second relief episode)**: f10 0.2017, f11 0.2128, f12 0.1820.
  f12 west wall — x[0,160) 0.282, x[160,320) **0.441**; visible nested bands
  at approx `[0,0,500,520)` + isolated solid patch `[430,220,560,270)` +
  deposit disc at `[380,360,470,410)` (pale 317 px in-frame; REVIEW3 §4 rank 7
  geometry unchanged in this path — smooth ellipse, tiny dark centre).
- **f15–f17**: anis peaks 0.688/0.691/0.673 are shore-edge stripes, not
  relief chevrons (see §2.4); relief fraction only 0.14–0.15 there.
- Chevron-free counter-proof: f07/f08 (0.104–0.107) and f20–f23 (0.094–0.097)
  hold no nested bands at any column (all 80-px bands ≤ 0.11 on f23).

### 2.3 Clean-grass ROI `[500,500,900,700)` — material is static, stamps cross it

| Fr | Y/std | sat | gp95 | bv32 | dark32 | Read |
|---|---|---|---|---|---|---|
| 00–03 | 48.6–55.2 / 20.9–22.9 | .53–.58 | 16.6–21.8 | 14.3–16.8 | .32–.42 | stamp-contaminated |
| 04 | 69.3/10.8 | .723 | 14.5 | 6.27 | .021 | stamp edge leaves |
| 05–11 | 67.9–70.8 / 9.0–14.6 | .71–.73 | 14.5–25.1 | 2.1–8.0 | .001–.045 | grass; f10 tree passes through (gp95 25.1) |
| 12–23 | 70.3–70.8 / 8.6–9.6 | .727–.732 | 14.1–15.6 | 1.99–3.05 | ≤.0015 | **static** (f18 3.05 = shore remnant at top, outside ROI) |

**[D] Direction:** ROI std collapses 22.9→8.6 and bv32 16.8→2.0 as stamps
leave; the grass texel field itself shows no inter-frame shimmer (adjacent
clean frames differ only by pan translation; MAD 4–6 at pan tail).

### 2.4 Shore/sand plateau — frames 14–18 only (pale_low_sat + gold_like)

pale_low_sat (Y>105 & sat<0.42): f11 341 px → f12 317 → f13 427 →
**f14 4,362 → f15 7,244 → f16 8,098 (peak 0.88%) → f17 7,483 → f18 2,581** →
f19 946 → f20 89 → f21+ 0. Sand bbox f16: rows 0–701, cols 0–1150; f14:
rows 0–494, cols 494–1279 (enters from NE, exits NW — world-locked).
Gold_like spike f14–18 (0.063–0.125, peak 114,745 px f16, top-half density
0.224 vs bottom 0.025) coincides exactly with the sand bbox → pale sand
albedo, **not** crop parcels. Striped transition edges ring the plateau
(direct view f16 top band `[0,0,1280,210)`; gp95 26.2, anis 0.691).
No water/foam band is visible in any of the 24 frames.

### 2.5 Props/trees — sparse everywhere, fixed to ground

- dark20 counts: f00–f04 1,642–2,024 px; f07–f10 rise 2,846→5,709 (a few
  bare sticks + dark variants cross frame, e.g. f09–f10 cluster);
  f15–f16 5,770/6,069 px include shore-edge dark bands (not trees);
  f19–23 collapse 582→330 px (≈0.03–0.06%: 1–2 saplings, e.g. f23 single
  sapling at ≈(960,380)).
- Contact sheet: individuals drift with the ground plane (no sliding
  parallax observed); crowns mostly bare sticks or dark blobs; no stand,
  grove edge, or shadow row in any frame. Deposit disc f12
  `[380,360,470,410)` sits on grass with a pale halo, no rock cluster.

### 2.6 Field squares — absent from pan, present in stills

No 24-frame ROI shows the closed-parcel grid. The pinned stills do:
`cap_donor_240_hires.png` green-tuft parcel grid right side
≈ `[1000,300,1280,550)` (hires full-frame gold only 0.0261 — tufts are
green, not golden; material verdict stays with REVIEW3 rank 3 / §4.2:
footprint present, crop albedo missing). Mill/town/field stills m/n/hires
are mutually consistent (m vs n: Y 69.9/70.0, bv32 6.93/6.87).

## 3. Direction-only donor comparison (120 / 300 / 1200 / 1800 s)

Same-metric, same-code runs on 8 donor frames + 4 candidate stills.
Donor build/map/camera/zoom/compression unknown — **direction only**.

| Source | Y/std | sat | gp95 | anis | bv32 | dark32 | pale | gold |
|---|---|---|---|---|---|---|---|---|
| V1 t_120 (field/mill) | 68.3/25.9 | .577 | 27.4 | .255 | 18.2 | .073 | .022 | .110 |
| V1 t_300 (ridge) | 65.2/22.4 | .563 | 16.7 | .489 | 16.5 | .061 | .017 | .038 |
| V1 t_1200 (mine/forest) | 61.7/26.9 | .583 | 29.6 | .290 | 17.6 | .113 | .020 | .062 |
| V1 t_1800 (field/mill) | 67.0/27.7 | .584 | 36.0 | .206 | 15.8 | .062 | .031 | .099 |
| V2 t_300 (mine) | 69.1/26.2 | .550 | 22.9 | .425 | 19.5 | .087 | .021 | .050 |
| V2 t_600 (forest/town) | 68.9/25.8 | .545 | 23.9 | .338 | 19.1 | .078 | .023 | .068 |
| V2 t_1200 (barracks/rock) | 67.0/29.5 | .523 | 29.5 | .309 | 20.6 | .106 | .039 | .071 |
| V2 t_1800 (army/grass) | 70.6/26.3 | .553 | 26.8 | .356 | 18.9 | .079 | .025 | .078 |
| cap m / n / hires / h | 69.8–70.2 / 12–14 | .69–.72 | 11.8–18.4 | .33–.43 | 6.9–7.1 | .023 | .003 | .026–.046 |
| pan clean f20–23 | 70.9–71.0 / 8.6–9.0 | .729–.732 | 14.2–14.5 | .53–.54 | 1.9–2.2 | .0005–.003 | 0 | .021 |

**[D] Reads (direction only, no thresholds):**

1. Grass multi-scale: donor bv32 15.8–20.6 vs candidate stills 6.9–7.1 vs
   pan-clean 1.9–2.2 — nearly an order of magnitude. Donor 48 px
   autocorrelation peak absent here per DONOR-VIDEO §3.3; candidate grass
   carries the periodic read (REVIEW3 rank 5 sustained).
2. Saturation: donor 0.52–0.58 vs candidate 0.69–0.73 — candidate grass
   over-saturated and B-starved (REVIEW3 rank 5: B ≈ 20.7–20.8 vs donor
   ≈ 31.8–34.5 sustained).
3. Relief: donor max anis 0.489 (V1 t_300 directional ridge detail) vs
   candidate chevron frames 0.524–0.535 and shore-edge 0.61–0.69 — the
   candidate's strongest orientations are lattice/stripes, the donor's are
   ridge faces. No donor frame shows nested olive/near-black chevrons.
4. Gold: donor field frames 0.062–0.110 (t_120/t_1800) vs candidate pan
   0.017–0.024 outside the sand plateau and hires still 0.026 — the gold
   crop-row class has no in-pan counterpart; stills show green tufts.
5. Dark: donor dark32 0.06–0.11 (shaded canopy/rock faces, high coverage:
   REVIEW3 §4 quotes V2 t_120 forest 82%) vs candidate pan-clean ≈ 0.0005
   (empty) and relief frames 0.14–0.18 (flat near-black bands, not shaded
   detail) — opposite failure modes per zone.

## 4. Temporal-stability verdicts (grass / relief / shore / props)

| Zone | Stability verdict | Evidence |
|---|---|---|
| Grass material | **[O] Static — no crawl/shimmer.** Clean-frame ROI identical within pan translation; MAD decays smoothly | §2.1 MAD ladder; §2.3 ROI table; contact sheet frames 8/20/23 uniform |
| Relief stamps | **[O] World-locked, hard-edged, two-state (in/out).** No morphing or flicker; boundaries translate rigidly | Column profile §2.2; f00→f04 westward exit; f09→f12 re-entry; top/bot splits |
| Shore plateau | **[O] World-locked entry/exit f13→f20 with striped edges.** Pale count 0→8,098→0; no brightness pulse | §2.4 counts/bbox; f16 `[0,0,1280,210)` striped band |
| Props/trees | **[O] Fixed to ground, no parallax slide; count varies only by framing.** 330–6,069 dark20 px by zone | §2.5; PHOTO_SEQUENCE obs 5 sustained |
| Fields | **[O] Absent from pan** (no parcel ROI in any frame); stills carry the class | §2.6 |

## 5. Five safest concrete tweaks (ranked; expected metric deltas, no code edits)

All are diagnostic-first or binding-audit class per REVIEW3 §5–6. No geometry,
UV, placement, or camera constant is changed by these tweaks. Expected deltas
are **predicted directions on re-shot same-path captures**, not donor
thresholds and not parity claims.

| # | Tweak (concrete, safe) | Why safe | Expected metric delta on same 24-frame re-shot |
|---|---|---|---|
| 1 | **Atlas/season/mip binding audit + constant-atlas A/B at pinned camera** (render f00/f12/f16 cameras with flat atlas id and with mip forced to finest; compare). No repeat/count change | Read-only renders; cannot move geometry. Isolates whether chevrons come from tile art vs UV/face vs normals (R3-U2) | Chevron-frame anis 0.52–0.54 → drops toward grass baseline ≈0.49–0.54 *without* geometry change if tile-art-driven; or *persists* → proves UV/face/normal path, scoping fix 3. Grass bv32 unchanged (≈2) either way — no fake detail injected |
| 2 | **Constant-normal + light-rig response check on terrain shader** (flat normal render; then bind existing donor `light.cfg` colours/energy to terrain, still `shadows_enabled=false`). No new light design | Uses existing rig data (REVIEW3 §2/§3: props already readable under it); terrain currently unshaded per capture.json | Relief-frame dark32 0.14–0.18 → mid-tone recovery (dark16 collapses first); steep-face Y rises toward grass Y≈70; no new shadow language claimed. Verifies normal-stencil semantics before any shadow spend |
| 3 | **Green-field decal/albedo audit on the pinned still camera** (dump field decal/material IDs for the hires parcel grid `[1000,300,1280,550)`; albedo-only render). Pan untouched | Footprint already present in stills; audit cannot move parcels (REVIEW3 fix rank 1, SAFE NOW) | Hires parcel ROI gains crop-row texture: dark-neutral/green-tuft read → gold_like rises toward donor field direction (0.06–0.11) and ROI grad p95 rises from ≈11–18 toward donor 16–36; parcel edges stay legible; pan metrics unchanged (fields out of pan) |
| 4 | **Prop/tree material + LOD-variant dump on f07–f10 sticks** (list per-instance material/LOD for the bare-stick cluster; suppress pure-black/bare fallback variants only). No placement change | Provenance-local fix; REVIEW3 §2 confirms buildings/boulders already readable, so rig works — only residual variants targeted (fix rank 6, SAFE NOW) | dark20 2,800–5,700 px on f07–f10 → falls with textured crowns replacing silhouette sticks; darkest-pixel stops being RGB 0; tree count/positions unchanged (placement decode still gated) |
| 5 | **Bounded prop/contact-shadow pass measured on the still camera only** (enable contact darkening under mill/mine/trees at `cap_donor_240h` camera; record frame cost; keep wide pan shadows off until measured). No terrain re-light | Bounded scope + cost gate (REVIEW3 §5 fix rank 4, PARTIAL SAFE NOW); cannot alter wide-pan stability verdict | Named prop ROIs gain local contact contrast (units ROI dark32 redistributes from silhouette 0.11 toward shaded-detail shape); measured ms/frame recorded; wide-pan MAD ladder (§2.1) unchanged — stability evidence preserved |

Held behind donor decode/diagnostics (NOT in the safe list): continuous-relief
geometry (two-valued height Δ≈4.71 m over 2 m cells), chevron UV/face
projection, mine/forest placement transforms, camera constants, donor runtime
FPS — per REVIEW3 §6.2–6.3 and open items R3-U1–U8 below.

## 6. UNVERIFIED register (carried, not closed)

| ID | Unknown | Why unresolved here | What would settle it |
|---|---|---|---|
| SEQ-U1 | Exact producer of chevron bands (tile art vs UV/face vs normals) | Single shaded path only; no constant-atlas/normal A/B in this sequence | Tweak 1 A/B at pinned f00/f12 cameras |
| SEQ-U2 | Full height distribution (two-valued vs graded) | capture.json deciles show 2 occupied bins; no finer histogram | Live-backend full height histogram |
| SEQ-U3 | Shore stripe origin (ids 87–90 transition vs cell-centre topology) | Striped edges visible f14–18 but normal/alpha refkeys unverified | Shore/UV diagnostic + normal-stencil decode |
| SEQ-U4 | Field decal/material IDs for hires parcels | No per-decal dump in this worker | Tweak 3 albedo-only render |
| SEQ-U5 | Black/bare tree variant provenance | No per-instance material/LOD dump | Tweak 4 dump |
| SEQ-U6 | Donor parity of any frame | No donor GPU A/B frame; third-party video only | Owner-controlled same-camera capture |
| SEQ-U7 | Donor camera height/FOV/speed | Edited gameplay, unknown scale | Admissible reference; still no parity assumption |

## 7. Claim register and handoff

| # | Claim | Label |
|---|---|---|
| 1 | 24-frame pan is temporally stable: no crawl/shimmer; MAD decays 15.0→4.1 with smoothstep velocity | [O] |
| 2 | Dark chevrons dominate f00–f04 + f09–f12 at named ROIs; shore plateau dominates f14–f18 (sand ≤8,098 px); f19–f23 near-empty grass | [O] |
| 3 | Clean-grass ROI static f12–f23 (bv32 ≈2, sat ≈0.73); relief-crossed frames differ by content, not flicker | [O]/[D] |
| 4 | Forest sparse all 24 frames (dark20 ≤0.66%, →0.03% at tail); props ground-fixed | [O] |
| 5 | Field squares absent from pan; present (green-tuft) in pinned stills only | [O] |
| 6 | Direction-only donor deltas: bv32 ~8×, sat +0.15, anis lattice vs ridge, gold class missing in pan | [O]/[D], direction only |
| 7 | Five tweaks ranked with expected metric deltas; geometry/UV/placement/camera held | [D] |
| 8 | **No donor parity, similarity %, donor threshold, or gate PASS is claimed** | [U] |

**COORD handoff:** run tweaks 1–5 as diagnostics/audits first (constant-atlas,
constant-normal, decal/material dumps, bounded contact pass with cost log);
hold geometry, UV/face, mine/forest placement, and camera changes behind the
named diagnostics. Re-shoot the identical 60→420 smoothstep pan plus the
pinned mill/field and mine/rock feature shots; preserve
`parity.claim=NONE / parity.status=UNVERIFIED`.

*End of SEQ-WIDE. Exactly one repository file written: this report. No code,
shader, config, asset, test, fixture, result JSON, git, Godot, or donor-binary
change; no donor parity claim.*
