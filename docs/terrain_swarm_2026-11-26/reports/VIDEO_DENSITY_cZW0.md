---
id: VIDEO_DENSITY_cZW0
swarm: TERRAIN-SWARM-2026-11-26
role: WORKER VIDEO-DENSITY — donor video prop/forest density quantification (cZW0AEupCaI)
owner_file: docs/terrain_swarm_2026-11-26/reports/VIDEO_DENSITY_cZW0.md
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_NO_GODOT_NO_GIT
created: 2026-11-26
labels: [OBSERVED, DERIVED, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists. This review certifies neither donor fidelity nor a gate pass."
scope_guard: "Exactly one repo file written (this report). No source/asset/config/test/shader/fixture/git/runner state touched; no Godot job submitted; no donor binary executed; no donor material copied into the repo. All computation used Pillow/NumPy with temp-only scratch files."
temp_root: "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\"
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/DONOR_VIDEO_analysis.md
  - docs/terrain_swarm_2026-11-26/reports/AUDIT_TERRAIN_ASSET_COVERAGE.md
---

# VIDEO-DENSITY (cZW0AEupCaI) — donor prop/forest density vs candidate coverage

## 0. Executive summary

1. **[O] Donor frames treated as video were quantified, not eyeballed.** Twelve
   `t_*.png` frames from `cZW0AEupCaI` (00:00–00:39:30) plus the three current
   wide2 candidate frames were measured at 640×360 (morphology) and 1280×720
   (photometry) with Pillow/NumPy. Scratch scripts and JSON live only under
   `%TEMP%\opencode\` (`density_cZW0_calc*.py`, `density_cZW0_tmp.json`); nothing
   was written to the repo except this report.
2. **[O] Donor ground is a two-population system; the candidate is a
   one-population system.** Donor frames carry 27–44% fragmented dark canopy in
   110–397 blobs (17–109 mid-size clusters, nearest-cluster spacing ≈11–16
   cells on a 160×90 grid) PLUS 26–40% mid-tone ground, with edge energy
   (`e40`) 10–100× above the candidate. The candidate's dark area is a single
   connected relief mass (one component = 35–40% of frame, ≤6 mid-size
   clusters, e40 ≈ 0.0005–0.0036): relief bands, not forest.
3. **[O] The candidate's pale-plate signal is real and donor-absent at that
   scale.** `frame_0023` has 5.07% pale low-saturation pixels (the square
   mountain plates; DONOR-VIDEO located a 386×204 / 62,910-px component there)
   vs 0.48–0.58% in donor mountain/mine frames. `frame_0012`'s mine disc is
   small in-frame (0.59%) but structurally identical: an orphan disc, not a
   rock cluster (cf. DONOR-VIDEO §4.1 V1-1200, §4.2 V2-300).
4. **[D] Ranked fix order (density only):** understory/weed converter batch
   (~4,500 records, largest count) → palm/desert-scrub batch (~5,500
   forest-class records, desert density) → bare-name mapping aliases (~4,000+
   instances, zero new art) → per-variant mapping reuse (15 sids, variety at
   zero instance cost) → `other`-class stamp rules (rescues 298 instanced-class
   records, re-labels 5,247 weed sid-skips). Counts are AUDIT-measured feed
   values, not estimates.
5. **[U] No parity claim.** All "expected metrics" below are direction + the
   measured donor range from this video; they are not donor thresholds, not
   gate criteria, and not transferable constants (unknown build/map/camera/
   zoom/compression per DONOR-VIDEO §1.3).

## 1. Inputs actually used (substitutions recorded)

| Requested input | Status [O] |
|---|---|
| Donor frames `%TEMP%/opencode/donor_videos/selected/cZW0AEupCaI/` t_60/120/300/600/900/1200/1800 (+t_0/1500/2100/2260/2370 present) | **Used.** 12 frames, 1280×720. |
| `cap_nationmove.png` (latest candidate still) | **Not found on disk.** No such file under `%TEMP%` video dirs or the repo docs tree. |
| `cap_donor_240_colorfield.png` | **Not found on disk.** Same search, no match. |
| `inbox/qa/captures/` contact sheets | **Directory does not exist.** `docs/terrain_swarm_2026-11-26/` contains only `reports/`, `spec/`, and charter files. |
| `DONOR_VIDEO_analysis.md`, `AUDIT_TERRAIN_ASSET_COVERAGE.md` | **Used** (governing sources above). |

**[D] Substitution:** the three current wide2 frames
(`%TEMP%\opencode\v42\video\donor_240_wide2\frame_0000/0012/0023.png` — the
candidate baseline characterized in DONOR-VIDEO §3) stand in for the missing
candidate stills. Any verdict that required the two missing `cap_*` files is
marked **[U]** in §7 rather than inferred.

## 2. Method (instruments only, donor READ ONLY)

- **[O]** = computed from file bytes or seen in a frame. **[D]** = arithmetic
  over observations. **[U]** = unresolved. **PORT APPROXIMATION** applies to
  every candidate comparison.
- Pass 1 (morphology, 640×360 LANCZOS): per-frame luminance/saturation/gradient
  stats; dark-green mask (`lum<70, g≥r−5, g≥b−10`); 8-connected blob count at
  160×90; mid-size cluster count (≥8 cells); nearest-neighbour centroid spacing;
  32-px block variance (BV32); horizontal autocorrelation lag-24 (≈ lag-48 at
  full res); bright/gold/grey population fractions.
- Pass 2 (photometry, full 1280×720): canopy/ground split, saturation std,
  pale-plate fractions (`lum>150 & sat<0.4`; `lum>130 & sat<0.35`), luminance
  p95/p99, RGB means.
- Pass 3 (plate photometry): per-frame RGB mean, pale fractions for
  wide2 f0000/f0012/f0023 vs donor t_1200 (mine/forest) and t_300 (ridge).
- No threshold was tuned to a desired outcome; the same fixed masks ran on all
  15 frames. Mask definitions are heuristic population separators, not donor
  classifiers — the *contrast between the two sets under identical masks* is
  the finding, not any absolute value.

## 3. Donor density as measured (cZW0AEupCaI, 12 frames)

### 3.1 Population table [O] (640×360 unless noted; full-res rows marked *)

| Frame (video time) | Scene | darkveg frac | blobs / mid-size clusters | NN spacing (cells) | e40 | grad | lum std | ground frac* | sat std* |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| t_0 (00:00) | town/forest edge | 0.406 | 289 / 22 | 13.0 | 0.0099 | 4.55 | 26.6 | — | — |
| t_60 (00:01) | field+mill town | 0.387 | 309 / 29 | 13.1 | 0.0241 | 7.13 | 25.4 | 0.325 | 0.211 |
| t_120 (00:02) | wheat/mill | 0.299 | 337 / 35 | 12.7 | 0.0169 | 6.64 | 23.9 | 0.396 | 0.192 |
| t_300 (00:05) | rocky ridge | 0.340 | 170 / 23 | 13.4 | 0.0111 | 4.59 | 21.4 | 0.274 | 0.147 |
| t_600 (00:10) | dense conifer | 0.428 | 110 / 19 | 14.9 | 0.0175 | 5.16 | 27.0 | 0.262 | 0.208 |
| t_900 (00:15) | field/army/city | 0.271 | 201 / 32 | 14.8 | 0.0281 | 7.82 | 26.4 | 0.380 | 0.184 |
| t_1200 (00:20) | mine/forest | 0.402 | 254 / 32 | 11.3 | 0.0266 | 8.10 | 24.7 | 0.297 | 0.164 |
| t_1500 (00:25) | stone city | 0.382 | 278 / 40 | 10.8 | 0.0444 | 10.57 | 28.5 | — | — |
| t_1800 (00:30) | field/army | 0.347 | 302 / 31 | 13.0 | 0.0337 | 8.93 | 25.1 | 0.343 | 0.180 |
| t_2100 (00:35) | ridge+forest+army | 0.442 | 156 / 20 | 15.6 | 0.0414 | 9.00 | 27.0 | 0.255 | 0.182 |
| t_2260 (00:37) | town/woods | 0.440 | 166 / 21 | 11.2 | 0.0432 | 8.58 | 28.1 | — | — |
| t_2370 (00:39) | battle/woods | 0.380 | 227 / 35 | 13.6 | 0.0581 | 11.97 | 31.0 | — | — |
| **Donor range** | | **0.27–0.44** | **110–397 / 17–109** | **10.8–15.6** | **0.0099–0.0581** | **4.6–12.0** | **21–31** | **0.26–0.40** | **0.147–0.211** |

### 3.2 Candidate under identical masks [O]

| Frame | darkveg frac | blobs / mid-size | NN spacing | e40 | grad | lum std | ground frac* | sat std* |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| wide2 f0000 | 0.720 | 47 / 6 | 11.8 | 0.00049 | 3.29 | 16.8 | 0.023 | 0.168 |
| wide2 f0012 | 0.708 | 8 / 2 | 44.0 | 0.00164 | 2.74 | 13.8 | 0.016 | 0.125 |
| wide2 f0023 | 0.605 | 10 / 1 | — (single) | 0.00365 | 2.07 | 22.5 | 0.051 | 0.166 |

**[D] Read:** the candidate's dark fraction is *higher* (0.61–0.72) but
concentrated in 1–47 blobs with a single giant component (9,018–10,415 cells
at 160×90 ≈ 35–40% of frame in one mass; pass-1 top-size lists). Donor dark
is 110–397 blobs with 17–109 mid-size canopy clusters. Same mask, opposite
structure: **candidate dark = connected relief bands; donor dark = fragmented
canopy with ground between.** The e40 gap (donor min 0.0099 vs candidate max
0.0036) and gradient gap (donor min 4.6 vs candidate max 3.3) confirm the
candidate has almost no high-frequency population — no foliage, crop-row, or
rock-face energy.

### 3.3 Tree spacing / glades [O/D]

- Donor nearest-cluster spacing is **10.8–15.6 cells on a 160×90 grid**
  (≈ 7–10% of frame width between canopy-cluster centroids), stable across
  town, field, ridge, dense-forest and battle scenes. This is measured
  image-plane spacing at unknown zoom — a **spacing regularity cue, not a
  world-distance constant**.
- Donor always shows mid-tone ground between clusters (ground frac 0.26–0.40):
  grassy glades and dirt tracks, visible in t_600 (dense conifer, glades
  present even at highest canopy frac 0.428-after-mask/0.618-full-res) and
  t_2100 (ridge + forested middle ground + open cavalry grass in one frame,
  DONOR-VIDEO §4.1).
- Candidate: f0012 has 2 mid-size clusters 44 cells apart (isolated glyphs on
  flat ground); f0023 has 1 (no spacing definable); f0000 has 6 (band
  fragments, not trees). **No glade structure exists** — ground frac under the
  same mask is 0.016–0.051 because candidate ground is uniformly dark-olive
  (lum 60–76, sat 0.65–0.69) with no sunlit-ground population: full-res
  `lum>120` fraction is 0.1–0.8% in f0000/f0012 (donor 1.3–2.1%), the f0023
  8.2% being the plates themselves (§3.4).
- **[D]** Forest fix target is therefore *count + fragmentation + ground
  between*, never "darken ground": adding dark bands made the candidate worse
  (f0000's 0.72 dark fraction reads as terrain damage, not forest).

### 3.4 Ground cover and plates [O]

- Full-res RGB means: wide2 ground `[63–80, 67–82, 21–30]` (olive: R+G high,
  B crushed) vs donor `[66–69, 64–68, 29–30]`. Candidate saturation mean
  0.65–0.69 vs donor 0.50–0.58 **[O]**: the candidate is uniformly
  oversaturated olive with no multi-scale mottling (consistent with
  DONOR-VIDEO §3.3: candidate clean-grass BV32 0.28–0.32 with 46–48 px
  periodicity vs donor multi-scale).
- Pale-plate population (`lum>150 & sat<0.4`, full-res): **f0023 5.07%**,
  f0012 0.59%, f0000 0.05% vs donor t_1200 0.58%, t_300 0.48% **[O]**. The
  f0023 value is ~9× the donor level and corresponds to the square mountain
  plates (DONOR-VIDEO's 62,910-px component); donor's sub-1% pale pixels are
  scattered specular/UI/sky bits (largest connected group 48 full-px).
- Gold (field-crop heuristic `r>150 & g>120 & b<130 & r>b+30`): donor frames
  0.14–1.19% with spatial coherence at t_120/t_900/t_1800 (wheat parcels);
  **candidate 0.00% in all three frames** — no field class whatsoever **[O]**.
- Grey rock (`lum 90–200 & sat<0.22`): donor mine/city frames 2.0–5.1%;
  candidate f0023 8.9% — but co-located with the plates (smooth mound render
  + pale base), not clustered outcrop texture (donor mine frames pair grey
  with high e40; candidate pairs it with the lowest grad 2.07) **[O/D]**.

## 4. Coverage gap in feed terms (AUDIT-grounded, no new counting)

Per AUDIT_TERRAIN_ASSET_COVERAGE §1–§5 ([D] static trace over 39,783 feed
records, runtime effect [U]):

- 22,816 records (57.4%) would INSTANCE across 62 sids; **16,669 (41.9%) skip
  for unknown sid; 298 skip for unknown class; `other`-class stamps (5,545
  records) instance nothing.**
- The missing visual populations in §3 map to counted feed blocks: all
  grass/weed understory (~4,500: `grass*`, `grassforest*`, `chamomile*`,
  `burdock*`, `horseradish*`, `plant*`), desert/palm assemblages (~5,500:
  `palm` 1,319, `desert1` 1,262, `plantyellow` 1,315, …), bare-name misses
  (`fern` 1,348+, `flowers`, `plantainyellow` 855, …), dead-tree actors
  (`drytree/leaftree/pinebroken*` ~600+), and 15 already-converted but
  clamped-away variants (`rock_smallstones2-6`, `rock_smallstonesea2-6`,
  `plantain2/3`, `bush2-4`, `flower1-3`, `fern1-4`).

## 5. Five ranked density fixes (donor-grounded; expected metrics are measured-range directions, not thresholds)

| Rank | Fix (no synthetic assets) | Donor evidence (§3 + DONOR-VIDEO) | Feed lever (AUDIT counts [O]) | Expected metric movement [D] (verify direction against §3 ranges; never gate) |
|---:|---|---|---|---|
| 1 | **Understory converter batch** — convert the grass/weed actor set (`grass*`, `grassforest*`, `grassleafforest*`, `chamomile*`, `burdock*`, `horseradish*`, `plant*`) as instanced cross-quads with the existing `alpha-scissor 0.5 / cull-disabled` binding (AUDIT A4) | Donor glades are never bare: ground frac 0.26–0.40 in every scene incl. dense conifer t_600; e40 floor 0.0099 comes from ground-level texture, not just canopy | ~4,500+ skipped records, the largest single skipped block (AUDIT §3); MultiMesh absorbs count (one batch per new sid) | e40 rises from 0.0005–0.0036 toward donor-measured 0.0099–0.058 band; grad rises from 2.1–3.3 toward 4.6–12.0; lum std rises from 13–17 (f0000/f0012) toward 21–31. No absolute pass value — record and compare. |
| 2 | **Palm + desert-scrub converter batch** (`palm/palmsmall`, `desert1..5`, `plantyellow`) with exact-vertex/topology checks per FIX-FIELD-ASSETS pattern (AUDIT A3) | Desert density exists in donor (AUDIT X16 rows 69-72; V2 rolling-ground scenes); candidate desert biomes would otherwise stay empty ground + relief bands | ~5,500 forest-class records unreachable by any mapping edit (`palm` 1,319, `desert1` 1,262, `plantyellow` 1,315, …) | Forest-class instance ratio rises from 71.7% toward fuller coverage (AUDIT §4 table); darkveg blob count rises from 1–47 toward donor 110–397; mid-size clusters from ≤6 toward 17–109. Desert frames measured separately — do not mix with temperate ranges. |
| 3 | **Bare-name mapping aliases, zero new art** (`fern→fern1`, `flowers→flower1`, `plantainyellow→plantain1` w/ material-variant label, `drybushes.1→bush1`) (AUDIT A2) | Donor understory/edge filling at every forest margin inspected (V1-1200, V2-600 crops); `fern` 1,348+ records are mixed/leaf-forest understory per X16 rows 21-22 | ~4,000+ instances unlocked from already-converted OBJs on disk; change confined to `_sid_for_base` | Same directional metrics as Fix 1 at zero art cost; additionally blob-count and ground-frac respond first (understory fills glades before canopy work lands). Cheapest per-instance density gain. |
| 4 | **Per-variant mapping reuse, zero new art** (`smallstones.N→rock_smallstonesN`, `plantain.2/3→plantain2/3`, `bushes.1`-style aliases for `bush2-4`/`flower1-3`/`fern1-4`) (AUDIT A1) | Donor rock/ground detail is multi-scale: mine frames pair grey 2–5% with high e40 (clustered outcrops, V1 00:20:00, V2 00:05:00); single-variant repetition causes the visible checkerboard/periodicity (DONOR-VIDEO §3.3: 46–48 px peak) | 15 sids converted but unreachable; instance count unchanged, ~+15 MultiMesh batches (variety only) | 48-px autocorrelation peak (0.54–0.55 in DONOR-VIDEO clean-grass ROIs) weakens toward donor 0.007–0.135; BV32 stays multi-scale. Variety fix — expect periodicity metrics to move, not counts. |
| 5 | **`other`-class stamp rules + residual gaps** (`plt*/desert_plt*/k_plain*/k_ravine*/hil*/str_*/fb_*` → matching class by base; convert `pump1..3`, `terrainmeshdesert1..4` materials) (AUDIT A5) | Donor shows no empty functional parcels: fields, mills, mines, walls, armies composed as readable units (DONOR-VIDEO §4.1–4.2 placement notes); candidate's empty plains/ravines mirror exactly the never-instanced `plt/plain/ravine` stamp families | Rescues 298 `unknown_class` records with convertible sids; re-labels 5,247 weed sid-skips into right class counters; 5,545 `other` records stop dying silently | `other`-class instance rate rises from 0%; `skipped_unknown_class` falls from 298 toward 0 (static-trace counter, runtime [U] per AUDIT §5). Gate assertion per V66 §5.3/V106 §6 (`props_total > 0 && fallback_used == false`), never on `feed_source` alone. |

## 6. What was NOT fixed / explicitly out of scope

- Plate removal, relief organic-ness, lighting/contact shadows, and shore/water
  are DONOR-VIDEO ranks 1/2/4/10 — real gaps (f0023 5.07% pale, §3.4) but not
  density-count work; left to the owning workers.
- Winter `*w` materials stay UNVERIFIED (X16 E5, AUDIT A4); `plantainyellow→
  plantain1` needs a material-variant label (X16 row 97 G3); LOD 0..150 /
  0..2500 semantics stay [U] (AUDIT §8).
- Runtime counters (`skipped_*`, `props_total`) remain [U] until a composer
  run lands I09 telemetry; current `donor_240_final` capture predates the I09
  path (AUDIT §5).

## 7. UNVERIFIED register

| ID | Item | Why unresolved | What would settle it |
|---|---|---|---|
| VD-U1 | Candidate stills `cap_nationmove.png`, `cap_donor_240_colorfield.png` | Files not found; contact-sheet dir absent (§1) | Re-issue with correct paths; wide2 frames used as proxy, not equivalent |
| VD-U2 | Donor parity of any density fix | Third-party video; unknown build/map/camera/zoom/compression; no same-camera A/B (DONOR-VIDEO DV-U1) | Owner-controlled donor/port same-camera capture |
| VD-U3 | World-scale tree spacing / stems-per-hectare | Image-plane spacing only; world-area-per-pixel unknown | Pinned candidate camera with known world scale (DONOR-VIDEO DV-U5 pattern) |
| VD-U4 | Runtime instance counts for fixes 1–5 | Static-trace predictions only (AUDIT §5) | Composer run asserting `counts.props_total > 0 && feed.fallback_used == false` |
| VD-U5 | Water/shore density context | No certifiable water frame in sampled video (DONOR-VIDEO §5.2) | Admissible shoreline frame; not invented here |

*End of VIDEO_DENSITY_cZW0. Exactly one repo file written. No code, asset,
config, test, manifest, git, app/, Godot, runner, gate, or capture state
created, edited, or deleted. Donor files read only. NO DONOR PARITY CLAIM.*
