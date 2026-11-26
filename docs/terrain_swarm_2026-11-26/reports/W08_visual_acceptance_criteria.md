---
id: W08
swarm: TERRAIN-SWARM-2026-11-26 / TERRAIN-VISUAL-WAVE-2026-11-26
role: WORKER W08 (VISUAL WAVE) — concrete visual acceptance criteria for the NEXT capture iteration
owner_file: docs/terrain_swarm_2026-11-26/reports/W08_visual_acceptance_criteria.md
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_CODE_EDIT__NO_GODOT_JOB__NO_DONOR_PARITY_CLAIM
created: 2026-11-26
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "no donor A/B frame; parity UNVERIFIED. No donor GPU A/B frame exists and none is invented here. No reference image, no parity metric and no donor-match wording is used. Every visual property below is PORT APPROXIMATION, checked inside a candidate capture only."
scope_guard: "Exactly one repo file written (this report). No source/asset/config/test/shader/fixture/git/runner state touched; no Godot job submitted; no donor file executed or copied."
reference_corpus: "C:\\Users\\Maxym.Oboyshev\\Downloads\\c3\\ (12 stills, READ-ONLY) + C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\v42\\cap_donor_240c.png (current capture, READ-ONLY)"
governing_sources:
  - docs/terrain_swarm_2026-11-26/VISUAL_WAVE_CHARTER.md — §0 evidence, §1 goals, §2 hard rules
  - docs/terrain_swarm_2026-11-26/reports/X07_visual_reference_index.md — §2/§4/§5/§6/§7/§8
  - docs/terrain_swarm_2026-11-26/reports/X36_mountain_visual_recheck.md — §2/§3/§4/§5/§6
  - docs/terrain_swarm_2026-11-26/reports/V15_acceptance_without_reference.md — §2 three tiers, §4 table, §6 template
  - docs/terrain_swarm_2026-11-26/reports/X54_ground_truth_card.md — §2 wrong beliefs
  - reference/videos.md — §Method note, §Videos
---

# W08 — visual acceptance criteria for the NEXT capture iteration

## 0. Executive summary

1. **[O] Current-capture baseline (`cap_donor_240c.png`), directly viewed.** A large blocky,
   terraced/stepped surface with **diagonal bands** and **concentric contour rings**,
   black unit/building/tree silhouettes, and a flat olive foreground with no readable
   natural relief. This is exactly the state the charter flags (charter §0 line 15-17).
   The next iteration is judged against the criteria below; **these artifacts are the
   forbidden baseline**, not a target.
2. **[D] These are direction-of-movement criteria, not parity.** The 12 donor stills are
   third-party images of unknown build, camera, zoom, world area and JPEG/WEBP compression
   (X07 §6 risk 1; A05 E09; spec §12.6). They support **presence and direction only**.
   **No donor A/B frame; parity UNVERIFIED.** No threshold below is donor-measured and
   no acceptance verdict below is a donor-match claim.
3. **[D] Best references are per-class and uneven.** Hills, fields, conifer forest, gold
   mine and decor have usable stills; mountains, a certifiable sea, rivers/swamps and
   iron/coal families do not (X07 §4, X36 §4, V15 §1). Where none exists the class is
   marked **UNVERIFIED** — no reference is invented.
4. **[I] Every visual verdict is V15 tier 2** — `SELF-CONSISTENT VISUAL`,
   `PORT APPROXIMATION` — with G0-a…e admissibility (§1) and metric/visual fields kept
   separate. Tier-1 structural checks remain available independently; tier-3 parity
   gaps are declared, never promoted.
5. **[O] No repo file other than this report was written; no Godot job was submitted;
   no donor binary was run or copied; no reference image or parity metric was invented.**

> **PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU
> A/B frame exists; this review certifies neither donor fidelity nor a gate pass.**
> (verbatim, A05 §4.2 / X07 §8 / V15 §2 / X36 §8)

---

## 1. Scope, admissibility and the metric rule

**Admissibility preconditions for any visual read (G0-a…e, V15 §3.5 / A05 §4.1):** a
windowed, non-blank 1280×720 PNG; `script_error_lines = 0`; pinned seed / camera / size;
and **the identical fractional ROI applied to both candidate sides**. If an ROI lands on
sky/HUD/units, the comparison is **UNVERIFIED** — it is not retried until green (X07 §6
risk 7, V15 R10).

**How to read the "numeric metric" column.** Every number named here comes from landed
work and is one of two kinds, **neither of which is a parity metric**:

- **(a) Screening cues recomputed from donor stills** — gradient magnitude, edge fraction
  `e40`, `maxRowDiff`, block variance `BV32`, saturation `(max−min)/max`, mean RGB. X36 §1
  calls these "a *screening* cue only, never a gate"; X07 §6 risk 8: "a green number cannot
  erase a visible grid/streak/blotch." They **support** the eye's read; they never prove
  parity and are never promoted to a red gate.
- **(b) Donor-rule-derived internal properties** from V15 §4 / A04 (e.g. silhouette
  ≥ centre +4 m, props ON/OFF ≥200 changed px / ≥8 px upward rise / <1% outside change,
  `matched_stamps > 0`, shore ids 93/97/98). These are named from donor *rules*, checked
  inside the candidate only.

**No cross-image score, no donor-vs-candidate SSIM/MAD, no z-score as fidelity, no
percent-similarity and no foam-width/water-level threshold from a thumbnail.** `compare_shots.py --threshold 0.9999` is legal only for candidate-A vs candidate-B
self-determinism at a pinned camera (V15 §3.5).

---

## 2. Class acceptance criteria table

Classes follow the task list. `PORT APPROXIMATION` applies to every "must be visibly
present" cell. A# codes are the index in X07 §2 (`A11_reference_metrics.md:63-76`).

| Class | Must be visibly present (tier-2 property) | Forbidden artifact (FAIL in this visual wave) | Numeric metric that SUPPORTS the read — never parity, never a gate | Best donor reference (or UNVERIFIED) |
|---|---|---|---|---|
| **Rolling hills** | A broad, non-concentric mound or gently rolling green/brown slope with mottled ground and gradual shadow; height extrema fall inside decoded donor windows | **Stepped/terraced terraces, diagonal bands, concentric contour rings, hard grid**, flat-only field (the `240c` baseline) | `grad` mean / `e40` edge fraction on a hill-slope ROI (A5: grad 11.43, e40 0.033); `maxRowDiff` 5.74 = gradual, no skyline (X36 C5) — direction cue only | **A7** `cossacks-3-v1-498085.jpg` (best, `[D]` moderate); runner **A5** `articolo-787.jpg` |
| **Mountains / ridges** | A silhouette rises ≥ centre terrain +4 m and ≥ footprint max +2 m with props ON; ON/OFF ≥200 changed px, ≥8 px upward rise, <1% outside change; `matched_stamps > 0` | Flat-only mound; concentric rings; diagonal vein lattice; a vacuous PASS from `matched_stamps = 0`; citing the "highlands" wallpaper as evidence | Only donor-rule-derived internal properties above (V15 §4 / A04); `maxRowDiff` skyline detector is a *screening* cue only | **UNVERIFIED** — no mountain in any of 12 stills; A6 "highlands" is a false positive on 3 crops (X36 C1–C3), A7 forms are earthworks (C4) |
| **Ravines / cliffs** | An eroded **asymmetric ravine lip**: vertical striated earth/rock face with grass cap and conifers rooted at the lip; broad channel, not a skyline | Hard tile-edge cliff; concentric rings; vein lattice; treating an earthwork as a mountain peak | `e40` 0.020, `grad` 8.83, `maxRowDiff` 3.12 on A7 embankment ROI `[461,115,845,274]` (X36 C4) — presence cue only | **A7** embankment ROI `.36,.16,.66,.38` (channel-H earthwork, X36 C4); true natural rock **cliff face UNVERIFIED** (A5 slope is shadowed trees, C5) |
| **Sea / shore** | A **continuous land → warm beach → bright foam → pale water** band with foam slightly offshore (not a white rim at the mathematical waterline); shore ids 93/97/98 present; no half-shore converted to blocked rock | Hard classification-aligned tile edge; white foam rim exactly at waterline; "fixed" quarry/rock wall on a beach; a **PASS verdict** from a foam metric | Saturation gradient land→beach→water 0.432 → 0.363 → 0.161 (X36 §3.2); `maxRowDiff` 13.85 (C9); foam peak RGB / water mean / alpha-at-waterline recorded as **measurements with no pass verdict** (V15 §4) | **A11** `maxresdefault_1.jpg` (best weak candidate; foam resolved in X36 C10/C12); **A5** distant strip (C14) secondary. Water **identity sea/river/wet-sand UNVERIFIED** |
| **Forests** | Conifer stand with natural irregular spacing, glades and long ground shadows; mixed/deciduous where seeded; no rigid plantation grid | Uniform grass as the only outcome (A10 is an intentional low outlier, not the target); grid/tree-line artifacts; black silhouette-only trees (240c) | `BV32` block variance on grass ROI (A10 uniform-grass low outlier n640 BV32 9.2 vs green median 247.6, A11 §1) as a **lower bound**; tree/shadow `e40` silhouette cue | **A10** `large_1.webp` (conifer #1); **A7** runner; mixed/deciduous **A9** `images.jpg` (low detail) / **A3** |
| **Stone quarries** | Clustered boulders/stone inside the stamp footprint; masonry only where a built structure is intended | Radial rock rings; single-rock grid; fabricated quarry asset; citing built castle walls (A0/A6 architecture) as quarry | `e40` screening on a stone ROI (A0 castle-rock `e40` 0.129 is **architecture, exclude** — X36 C7); local edge-density/cluster visual count; no donor quarry metric | **A0** boulders/rock outcrops (snow-confounded, X07 §6 risk 4) / **A6** built masonry (not a quarry). **Quarry-as-class UNVERIFIED** — zero donor files named `quarr` (X54 E26) |
| **Gold / iron / coal mines** | Deposit mesh visible on its olive/beige ground disc; built mine **centred** on it; 5×5 dirt plate centred; no mine without a deposit in range; no concentric deposit rings; ore differentiation by **material only** | Orphan mine (no deposit in range); concentric deposit rings; asserting an ore family from a still icon; inventing a finite deposit amount | Deposit counts per `SetupMines` ring `14+8R / 32+10R / 70+12R / 22+16R` (V15 §4 / X54 row 10); count stream stable under D1; mesh scale 0.3152/no jitter (A04 E14) — structural, not still-based | **Gold: A0** (yellow coin-stack icon + "Mine has been constructed successfully", `[I]` label per X07 U8). **Iron / coal: UNVERIFIED** — A0 second orange ore-chunk icon family unresolved (X36 C17/C18, X07 U4) |
| **Mill fields** | Golden wheat/stubble field with a legible footprint (L/rectangle) wrapping a stone windmill; field shape and windmill footprint both readable | Diffuse golden noise with no parcel shape; field painted over relief grid/steps; black silhouette windmill (240c) | Field-ROI mean RGB / saturation as a direction cue (A1 88.6/80.2/36.7, sat 0.563; A3 86.2/78.7/48.3, sat 0.435, X07 §2); `BV32` parcel boundary — no numeric gate | **A1** `523480776.jpg` (close footprint + windmill); runner **A3** `Cossacks3AttackingVillage.webp` (large parcels) |
| **Rivers / swamps** | If in scope: a connected water corridor using the **same shore band rule**, no isolated puddles, no hard grid; swamp = soft-edged wet patch with reed/bush/fern fringe and **no water plane** (zero height field is donor truth) | Invented ford threshold; a water plane over a swamp; checkerboard/noise wet patch; naming any still as a river | Water id 255 hard (S2); tile-id patch counts; connected-corridor check (V15 §4). **No donor visual metric** — no river course or swamp fringe in 12 stills | **UNVERIFIED** — no identifiable river/swamp; A5 strip is distant background water with a ship silhouette (X36 C13/C14); rivers are `OUT_OF_SCOPE` unless a DLC5 ticket lands (V15 §5.3) |
| **Decor** | Wooden watchtowers, windmill, huts/village, tent camp, stone structures readable at the pinned camera; natural, non-silhouette shading | Black silhouette-only props (240c); decor standing on the stepped/terraced surface; citing thumbnail blur as sharp detail | `e40` / silhouette cue on a watchtower ROI (A7 `.62,.10,.82,.32`); for low-detail thumbnails (A8) block variance is more trustworthy than gradient (A11 §6) — direction only | **A7** (watchtowers, best); runners **A6** (stone), **A1** (windmill), **A5** (tents); **A8** `hqdefault.jpg` town only (low detail) |

---

## 3. Per-class notes on the UNVERIFIED cells

- **Mountains / ridges (tier 3).** X36 gives three independent passes on the "highlands"
  wallpaper (full frame, upper 55%, upper-left half) and seven more candidates plus six
  remaining full frames — all negative (C1–C7, C20). A7 "embankments" are reclassified
  as channel-H earthworks (C4), not `terrainmeshN` mountain silhouettes. The only honest
  visual acceptance is a tier-2 property named from a donor *rule* (`pattern.lib`
  zero grids + `terrainmeshN` prop records, A04 E02–E04); the donor silhouette itself
  stays UNVERIFIED (X07 U3/U6, X36 X36-U1).
- **Ravines/cliffs.** A real eroded ravine lip *is* visible in A7, so "ravine" has a
  usable presence reference. A natural rock *cliff face above the canopy* does not:
  A5's dark region is a shadowed, tree-covered slope (X36 C5), and A9's distant line is
  haze+trees at 141×82 (C6) — the cliff sub-class is UNVERIFIED.
- **Sea/shore.** X36 upgrades A11 from X07's "weak" to foam-legible `[I]`, with a measured
  desaturation gradient and white curl texture, but **sea vs riverbank vs wet sand stays
  `[U]`** (X07 U2/U9, X36 X36-U3/U4). The 512×288 thumbnail yields no donor water level
  or foam pixel width; no numeric shore threshold may be derived from it.
- **Stone quarries.** No literal donor asset: a read-only filename scan for `quarr`
  returns 0 hits (X54 E26 / A04 E26). `stones` 7 / `stoneforests` 8 records and scale
  0.329 ±15% are structural only; the "quarry ↔ stones" mapping is `[D]/[I]`, and A0's
  stone is snow-confounded. Best visual anchor is A0 boulders/rock outcrops, never A6's
  built masonry.
- **Gold / iron / coal mines.** The yellow coin-stack icon and the distinct orange
  ore-chunk icon are both `[O]` visible in A0 (X36 C16/C18), but no donor legend maps
  the icons to ore families in the still. "Gold" is `[I]` per X07 U8; the orange icon's
  family (iron vs coal vs other) is `[U]` per X07 U4 / X36 X36-U7. Ore differentiation
  in the capture is by **material only**, with meshes byte-identical (`PORT APPROXIMATION`).
- **Rivers / swamps.** No river course or swamp fringe appears in any of the 12 stills
  (X36 task-2 conclusion). The only donor river datum is the DLC5 mask path
  `generator.cfg:62-64` (`hint = 8.Rivers`); there is no skirmish placement rule and no
  ford rule (V15 §5.3, D06 §8.2). Any "river" visual naming is forbidden; if COORD does
  not open a DLC5 ticket, report `OUT_OF_SCOPE`.

---

## 4. One-page shot list — NEXT capture iteration

**Capture contract for every shot below:** windowed 1280×720 PNG, non-blank, pinned
seed / camera / size, `script_error_lines = 0`; same fractional ROI on both candidate
sides (G0-a…e). A still beside a reference is a *direction read*, never an A/B frame.
There is **no donor A/B frame; parity UNVERIFIED** for all of it.

### Images (view beside the named donor still, at the cited ROI)

| # | Shot / ROI (fractional on candidate frame) | Donor still to view beside it | Read required (presence + forbidden artifact) |
|---|---|---|---|
| I1 | Overview of rolling ground, ROI `.35,.55,.48,.70` (A7 ref A) and A5 ref B `.30,.27,.42,.39` | A7, A5 | Non-concentric mottled mounds; **no steps/bands/rings/grid** |
| I2 | Ravine/embankment crop, ROI `.36,.16,.66,.38` | A7 | Striated eroded lip + grass cap + conifers; **no hard tile cliff, no rings** |
| I3 | Mountain silhouette test — props ON vs OFF at same pinned camera, full window + centre ROI | **UNVERIFIED** (no donor still) | ON/OFF silhouette rise + `matched_stamps > 0`; **no flat-only mound, no rings/veins** |
| I4 | Shore band, ROI `.60,.44,.84,.68` and wide `.48,.30,.98,.80` | A11 | land→beach→foam→water, foam slightly offshore; **no hard edge, no foam verdict** |
| I5 | Conifer stand, ROI `.62,.04,.78,.60`; grass lower-bound `.02,.53,.12,.68` | A10, A7 | Natural spacing + long shadows; **no grid, no silhouette-only trees** |
| I6 | Stone/boulders, ROI `.30,.05,.70,.28` on a summer (non-snow) map | A0 (snow confound), A6 | Clustered boulders; **no radial rings, no single-rock grid, no masonry-as-quarry** |
| I7 | Mine + deposit, ROI around a built minehead on its disc; + 2nd mine ROI | A0 (coin icon; orange icon family UNVERIFIED) | Mesh on disc, built centred, 5×5 plate; **no orphan mine, no ore-type-from-still claim** |
| I8 | Mill field + windmill, ROI `.46,.04,.90,.38` (close) and `.70,.08,.86,.28` (large) | A1, A3 | Legible golden field footprint + windmill; **no noise field, no field on steps** |
| I9 | Wet patch / water corridor, ROI per pinned camera | **UNVERIFIED** (no donor still) | Soft fringe, no water plane over swamp, no isolated puddles; **no river naming without a DLC5 ticket** |
| I10 | Decor: watchtower `.62,.10,.82,.32`; windmill; huts; tent camp | A7, A1, A5, A8(low detail) | Sharp, shaded props; **no black silhouettes, no props standing on terraces** |
| I11 | **Current-baseline re-shoot** of the `240c` camera for direct before/after of I1/I2 | none (self A/B only) | Confirm the steps/bands/rings are **gone**; compare candidate-A vs candidate-B determinism only |

### Video / motion sequence

**Admissibility note.** `reference/videos.md` states YouTube watch pages return only an
HTML shell on this machine — **no stream frames were obtained**. The 17 entries are
titles/descriptions from search snippets and watch-page titles; they are **mechanics
narrative only, not frame-extractable references**, and **no donor video A/B frame
exists**. Do not derive any metric or "motion parity" from them.

| # | Short capture sequence (candidate only) | What informs it (video title, narrative only) | Read required |
|---|---|---|---|
| V1 | Pan/zoom across rolling relief at pinned seed — 8–12 s | `cZW0AEupCaI` skirmish shell; `mk2fsEJeWMs` skirmish loop | Relief reads as organic in motion; **steps/bands/rings must not shimmer into view** |
| V2 | Shore camera, gentle weather/water animation — 8–12 s | `cUuGzr7874k` full skirmish (build order, mines, walls) | Continuous beach→foam→water band holds over time; **no hard edge appears, no foam-width claim** |
| V3 | Mill rotor + peasants near field; mine construction | `k-Ndvw0x_VI` early economy; `kaaG067gL18` iron-mine opener | Field footprint and mine-on-disc stable under animation; **no orphan mine, no ore label from motion** |
| V4 | Unit formation marching over hills/forest | `_2AuBsK1uPI` raiding; `UCMEXK-cD3E` mass lines | Ground mottling and tree spacing stable; **no grid/vein artifact in motion** |

**Metric rule for video:** the same support-not-parity rule as §1. Motion metrics (e.g.
frame-to-frame determinism) may check **candidate self-consistency only**, never donor
parity, because no donor frame sequence exists.

---

## 5. Pass / fail rubric — V15 three tiers

The tiers describe **what kind of claim** is made, not whether a gate is green (V15 §2).

| Tier | Name | Applied to this visual wave | PASS / FAIL meaning |
|---|---|---|---|
| **1** | **DONOR-GROUNDED STRUCTURE VERIFIED** | Cited donor datum (`path:line` / evidence id, `[O]`/`[D]`) matches a port observable byte/count/record/id/hash exactly; dump integrity D3 holds. Independent of X36. | **PASS** = exact structural match, no look claim. **FAIL** = mismatch. Never promotes a tier-2 or tier-3 item. |
| **2** | **SELF-CONSISTENT VISUAL** (`PORT APPROXIMATION`) | G0-a…e passes; property named from a donor *rule* and checked **inside the candidate**; the "must be present" is visible and the "forbidden artifact" is absent; metric field and visual field recorded separately. | **PASS** = required property visible + forbidden artifact absent + metric supports (not proves) + fields separated + reviewer line verbatim. **FAIL** = required property absent **or** forbidden artifact visible (steps/bands/rings/grid, orphan mine, hard shore edge, silhouette-only props). **A green metric cannot erase a visible artifact; a red metric cannot invent one.** |
| **3** | **UNVERIFIED** | No admissible donor datum for the property (mountains, quarry identity, sea/river/wet-sand identity, iron/coal family, rivers/swamps, any donor-motion parity). | Always listed with reason, passes attempted and "what would settle it." **Never** silently promoted to PASS, never deleted to make a gate green. Split into `declared_unverified` (accepted parity gaps) and `blocking_unverified` (missing QA evidence); non-empty `blocking_unverified` ⇒ `RESULT IS NOT GOOD` (V15 §2/§6). |

**Combination rule (V15 §2).** A class's honest verdict is the **highest tier actually
reached**; lower-evidence items stay visible in the same row. Tier 2 never implies tier
1; tier 1 never implies tier 2. **No class reaches "donor parity" — no tier above 2
exists in this vocabulary by construction.**

**Overall verdict — choose exactly one (V15 §6):**

- `RESULT IS GOOD — DONOR-GROUNDED STRUCTURE VERIFIED + SELF-CONSISTENT VISUAL; donor parity UNVERIFIED (declared, accepted).`
- `RESULT IS NOT GOOD — <one blocking item; rollback/hold>.`

**Explicit guard, restated:** **no donor A/B frame; parity UNVERIFIED.** A tier-2
"visual PASS" means *the candidate is internally self-consistent against a donor-rule-named
property* — it never means "matches the donor," "close to donor," a percentage similarity,
or a gate pass. `parity.claim = NONE`, `parity.status = UNVERIFIED` on every owner-facing use.

---

## 6. Metric ledger — provenance (so no metric is invented)

| Metric | Where cited | Kind | What it may / may not do |
|---|---|---|---|
| Gradient magnitude, `e20/e40/e80`, `maxRowDiff`, mean RGB, saturation | X36 §1–§3 | (a) screening cue recomputed on stills | Supports presence/absence; never a gate or donor match |
| Block variance `BV32` | X07 §0/A11 §1, §1 image 10 | (a) direction cue | Uniform-grass lower bound only; not a universal failure |
| Saturation gradient 0.432→0.363→0.161; `maxRowDiff` 13.85 | X36 §3.2 (A11) | (a) presence cue | Land→beach→water read; **no pass verdict from foam metric** |
| Silhouette +4 m / +2 m; ON/OFF ≥200 px / ≥8 px / <1%; `matched_stamps > 0` | V15 §4 / A04 §4.2 (donor rules) | (b) internal property | Checked in candidate only; mounted stamp guard; no donor silhouette claim |
| Shore ids 93/97/98; water id 255 | V15 §4 / D06 §7.1 | (b) id/count | Structural presence; no appearance threshold |
| Mine ring radii `14+8R … 22+16R`; mesh scale 0.3152 | V15 §4 / X54 row 10 / A04 E14 | (b) donor-rule count | Deposit-count read; **ore family by material only** |
| `compare_shots.py --threshold 0.9999` | V15 §3.5 / A05 §4.2.3 | candidate self-determinism only | Candidate-A vs candidate-B at pinned camera; **never donor-vs-candidate** |

No threshold in this report was newly derived from a still; no reference image, parity
metric or donor-match wording is introduced.

---

## 7. Claim register

| # | Claim | Source | Label |
|---|---|---|---|
| 1 | Current `240c` capture shows stepped/terraced bands, rings and black silhouettes | direct view of `cap_donor_240c.png`; charter §0 | `[O]` |
| 2 | Stills support presence/direction only, never parity or a gate | X07 §6, X36 §1, A05 E09 | `[D]` |
| 3 | Hills/fields/conifer forest/gold mine/decor have usable donor references | X07 §4 | `[D]` |
| 4 | Mountains, quarry identity, sea/river/wet-sand identity, iron/coal family, rivers/swamps have no usable still reference | X07 §4/§7, X36 §4, V15 §1 | `[O]`/`[U]` |
| 5 | "Highlands" wallpaper is not mountain evidence; A7 forms are earthworks | X36 C1–C4, V15 §5.6 | `[O]` |
| 6 | All numeric cues are screening/support only; none is a parity metric | X36 §1, X07 §6 risk 8, V15 §3.5 | `[D]` |
| 7 | Honest visual acceptance is tier 2 `PORT APPROXIMATION`; parity stays tier 3 | V15 §2/§4 | `[I]` design |
| 8 | **no donor A/B frame; parity UNVERIFIED** — no parity claim made anywhere here | this §7; parity_guard | `[U]` |

---

## 8. Open questions (for COORD / implementation-capture worker)

1. **(COORD/capture)** Pin the ROI set before capture: reuse the X07 §5 ground ROIs or the
   class ROIs in §5 of this report? Declare the primary gate observer. Any ROI landing on
   HUD/units ⇒ UNVERIFIED, not retried until green.
2. **(COORD)** Approve the `declared_unverified` / `blocking_unverified` split (V15 §2 Q1);
   until then the conservative reading marks the result `RESULT IS NOT GOOD`.
3. **(D06/F10)** Is the A11 pale band sea, riverbank or wet sand? Stills cannot decide
   (X36 X36-U3); V15 §5.2 S5 stays `[U]`.
4. **(D05/A04)** For mountains, is donor height-window + `terrainmeshN` structural
   evidence sufficient, or is an almanac/manual still required? X07 Q4 / V15 Q6 open.
5. **(F08/D07)** Confirm the ore family behind A0's coin-stack and orange-chunk icons
   (X36 X36-U7); stills cannot name iron vs coal.
6. **(COORD)** Can a genuine donor GPU A/B frame ever be obtained? Until it can, no tier
   above 2 exists and every owner-facing verdict says donor parity UNVERIFIED.

---

*End of W08. Exactly one repo file written; read-only on donor stills, references and
existing reports; no source, asset, config, test, shader, fixture, runner job or git edit;
no donor file executed or copied; no reference image or parity metric invented; no
donor-parity claim.*
