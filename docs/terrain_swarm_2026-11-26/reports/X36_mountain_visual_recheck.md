---
id: X36
swarm: TERRAIN-SWARM-2026-11-26
role: ANALYSIS / READ-ONLY — second visual recheck of donor stills for mountain, water/shore and mine evidence
owner_file: docs/terrain_swarm_2026-11-26/reports/X36_mountain_visual_recheck.md
status: LANDED__ONE_REPORT__NO_SOURCE_OR_ASSET_EDIT__NO_GODOT_JOB__NO_DONOR_PARITY_CLAIM
created: 2026-11-26
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists and none is invented here. This recheck confirms or refines X07's visual index; it certifies neither donor fidelity nor a gate pass."
reference_corpus: "C:\\Users\\Maxym.Oboyshev\\Downloads\\c3\\ (12 files, READ-ONLY, never written)"
derived_crops: "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\mountain_recheck\\ (LANCZOS upscales + stats JSON only; outside the repo)"
governing_sources:
  - docs/terrain_swarm_2026-11-26/CHARTER.md — §2 evidence sources, §4 guardrails and multiple-pass rule, §6 definition of "good"
  - docs/terrain_swarm_2026-11-26/SWARM_BOARD.md — X36 tasking, integration gates
  - docs/terrain_swarm_2026-11-26/reports/X07_visual_reference_index.md — §0, §2, §3, §4, §6, §7 (verdict under recheck)
  - docs/terrain_swarm_2026-11-26/reports/V15_acceptance_without_reference.md — §2 three tiers, §4 acceptance table, §5 multi-pass ledgers
  - docs/terrain_swarm_2026-11-26/reports/A04_landscape_props.md — §0.1, §2, §4.2, §4.4, §4.5, §4.8
  - docs/terrain_swarm_2026-11-26/spec/08_FIELDS_AND_PROPS.md — §1, §3, §4, §7, §8
---

# X36 — mountain / water / mine visual recheck of the 12 donor stills

## 0. Executive summary

1. **[O] X07's central verdict survives.** All 12 stills in `C:\Users\Maxym.Oboyshev\Downloads\c3\`
   were re-opened read-only, 25 LANCZOS upscaled crops were written **only** to
   `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\mountain_recheck\`, and
   luminance/gradient/edge statistics were recomputed with Pillow 12.1.1 + NumPy 2.4.3
   (`stats.json`, `stats2.json`, `stats3.json` in that temp folder). **No natural mountain
   or high-relief silhouette is visible in any of the 12 images.** The
   `cossacks-3-guardians-of-the-highlands-pc-gioco-steam-wallpaper-3.jpg` file is a stone
   construction scene on three independent crops (full frame, upper 55%, upper-left half)
   — its filename remains marketing, not evidence (X07 U3/U6).
2. **[O] A7's "embankments" are earthworks, not mountains.** Crop `[461,115,845,274]`
   shows eroded earthen/ravine faces with grass caps and conifers; edge fraction
   `grad>40 = 0.020`, max row-difference `3.12` — no skyline, no high relief.
3. **[I] A11 (`maxresdefault_1.jpg`) is a stronger shore candidate than X07's "weak" label,
   but still not a certifiable sea.** Three passes on `[307,127,430,196]`,
   `[307,144,486,225]` and `[348,161,491,230]` resolve a **green land → tan beach → white
   wavy surf foam → pale desaturated water** sequence; subregion saturation falls
   `0.432 → 0.363 → 0.161`. The white curl texture and the minimap's dark-blue water make
   a shoreline/[I] plausible; **sea vs riverbank vs wet sand remains [U]** (X07 U2/U9).
4. **[I] A5 (`articolo-787.jpg`) has a distant water band with a ship silhouette**, crop
   `[499,0,844,59]`, but no shoreline inside the playable ground ([I] presence, [U] identity).
   **No river or swamp is identifiable in the corpus.**
5. **[O]/[I] A0 contains two distinct visually identifiable mine types.** The wooden
   minehead with a **yellow coin-stack icon** (`[387,81,451,129]`, top-saturation mean RGB
   183/149/67) plus the on-screen text "Mine has been constructed successfully" is the gold
   mine (coin icon `[O]`, "gold" family `[I]` as X07 U8). A **second** minehead on the same
   rock/outcrop geometry carries an **orange/rust ore-chunk disc icon** (`[1478,351,1574,405]`)
   — a non-gold ore site is [O] visible, but **iron vs coal cannot be resolved [U]**.
6. **[D] Consequence for acceptance:** no new reference image is created and no donor visual
   parity is claimable. The only honest visual acceptance for mountains/hills/shore/mines is
   **V15 tier 2 — SELF-CONSISTENT VISUAL, `PORT APPROXIMATION`**, on properties named from
   donor rules (§5). This recheck relaxes no gate and invents no threshold.

---

## 1. Method, passes and admissibility

| Pass | Instrument | Scope | Written where | Result recorded |
|---|---|---|---|---|
| 1 | `read` on LANCZOS crops + Pillow/NumPy stats (`analyze.py`) | 12 crops: 5 mountain candidates, 3 water, 2 mine, 2 full-frame context | `%TEMP%\opencode\mountain_recheck\*.png`, `stats.json` | §2, §3 |
| 2 | `read` + colour/edge subregions (`analyze2.py`) | 8 crops + 6 subregions: A11 water-vs-sand test, A5 top strip, A0 right mine, A7/A5/A11 full frames | same temp folder, `stats2.json` | §3.2, §3.3 |
| 3 | `read` on tight icon/texture crops (`analyze3.py`) | 5 crops: orange icon, yellow icon, A5 ship, A11 foam, gold mine geometry | same temp folder, `stats3.json` | §3.3 |
| 4 | `read` on full-frame upscales (`analyze4.py`) | remaining 6 stills not covered by passes 1–3 | same temp folder, `Q1_…`–`Q6_…png` | §3.1, §3.2, §3.3 |
| 5 | `read` on tight crops (`analyze5.py`) | `hqdefault.jpg` lower-right outcrops (possible mine-like objects) | same temp folder, `Q5_rocks1/2.png` | §3.3 |

- **[O]** Statistics are computed on the **native crop** before upscaling: mean luminance
  `L`, `L` std, mean gradient magnitude `np.hypot(∂x,∂y)`, edge fractions at 20/40/80,
  mean RGB and saturation `(max−min)/max`, and the largest adjacent row-mean luminance
  jump (`maxRowDiff`) as a weak horizontal-boundary/skyline detector.
- **[D]** A crop with `maxRowDiff < ~5` and `e40 < ~0.04` does not contain a strong,
  continuous horizontal silhouette edge; this is a *screening* cue only, never a gate.
- **[O]** Source images and the repo were never written; the only repo file created is
  this report. No donor binary was run or copied, no Godot job was submitted, no reference
  image or parity metric was invented (CHARTER §4).
- **[U]** These remain third-party stills of unknown build/camera/zoom/world-area with
  JPEG/WEBP compression (X07 §6 risk 1; A05 E09): **direction and presence only**, never
  numeric calibration and never a donor-match verdict.

---

## 2. Candidate evidence table

Confidence legend: `[O]` = directly seen in a crop / computed statistic; `[D]` = arithmetic
reading of those values; `[I]` = best interpretation without a donor GPU frame; `[U]` =
unverified after ≥2 passes; `PORT APPROX` = port substitute. Fractional rect is
`(x0,y0,x1,y1)` of the full frame; pixel rect is absolute `[x0,y0,x1,y1]`.

| # | Task | Exact image | Crop rect (frac → px) | What is actually visible (label) | Confidence |
|---|---|---|---|---|---|
| C1 | mountain | `cossacks-3-guardians-of-the-highlands-pc-gioco-steam-wallpaper-3.jpg` | `(0,0,1,1)` → `[0,0,1916,1080]` (`M1_highlands_full.png`) | Half-built stone church/castle, scaffolding, carts, conifers, massed cavalry; **no natural relief** | `[O]` absence |
| C2 | mountain | same | `(0,0,1,0.55)` → `[0,0,1916,594]` (`M2_highlands_sky.png`) | Upper 55% is still walls/scaffolding/turret; no sky-mountain boundary; `maxRowDiff 4.31`, `e40 0.085` (edges are architectural) | `[O]` absence |
| C3 | mountain | same | `(0,0,0.5,0.6)` → `[0,0,958,648]` (`M3_highlands_left.png`) | Brick turret, timber hoarding, siege gun, conifers; no peak/crest silhouette | `[O]` absence |
| C4 | mountain/hills | `cossacks-3-v1-498085.jpg` | `(0.36,0.16,0.66,0.38)` → `[461,115,845,274]` (`A7_embank.png`) | Steep eroded earth/ravine faces with grass cap, conifers at lip; `grad 8.83`, `e40 0.020`, `maxRowDiff 3.12`. **Earthworks, not mountains** | `[O]` |
| C5 | hills | `articolo-787.jpg` | `(0.34,0.16,0.62,0.34)` → `[326,86,595,184]` (`A5_hillslope.png`) | Rolling mottled slope, dark shadow patch, pines, smoke/units; no crest above a horizon; `maxRowDiff 5.74` | `[O]` |
| C6 | hills | `images.jpg` | `(0.66,0.06,0.90,0.30)` → `[388,20,529,102]` (`A9_treeline.png`) | Hazy distant tree-lined slope; native crop only 141×82, `e40 0.006`; slope vs haze not separable | `[U]` |
| C7 | relief | `3173885360_preview_Turkish battle 19 Light Infantry rush.jpg` | `(0.30,0.05,0.70,0.28)` → `[576,54,1344,302]` (`A0_castle_rock.png`) | Snow-covered **man-made** castle façades/towers, stubble field; high `e40 0.129` is architecture, not terrain | `[O]` |
| C8 | water/shore | `maxresdefault_1.jpg` | `(0.60,0.44,0.84,0.68)` → `[307,127,430,196]` (`W1_A11_shore.png`) | Green land → tan band → pale band boundary; `maxRowDiff 8.20`; foam not yet resolved at this scale | `[I]` |
| C9 | water/shore | same | `(0.48,0.30,0.98,0.80)` → `[246,86,502,230]` (`W2_A11_wide.png`) | Fuller band; `maxRowDiff 13.85` (strongest boundary in corpus); minimap dark-blue water visible | `[I]` structure / `[U]` identity |
| C10 | water/shore | same | `(0.60,0.50,0.95,0.78)` → `[307,144,486,225]` (`P1_A11_paleband.png`) | Tan beach adjacent to pale blue-gray band with **white wavy curl texture** (surf/foam) | `[I]` |
| C11 | water/shore | same | `(0.42,0.38,0.78,0.62)` → `[215,109,399,179]` (`P2_A11_boundary.png`) | Soft green→tan transition under massed units; no hard classification-aligned tile edge | `[I]` |
| C12 | water/shore | same | `(0.68,0.56,0.96,0.80)` → `[348,161,491,230]` (`T4_A11_foam.png`) | White curl/foam pattern on pale water, immediately offshore of tan beach | `[I]` foam texture / `[U]` water body |
| C13 | water | `articolo-787.jpg` | `(0.70,0,1.0,0.22)` → `[672,0,960,119]` (`W3_A5_water.png`) | Thin blue-gray strip at frame top; pale structure at right | `[U]` |
| C14 | water | same | `(0.52,0,0.88,0.11)` → `[499,0,844,59]` (`T3_A5_ship.png`) | Blue-gray water band with a **dark elongated ship silhouette** and a pale pier-like shape; no land-water shore in the playable ground | `[I]` water presence / `[U]` identity |
| C15 | mine (gold) | `3173885360_preview_Turkish battle 19 Light Infantry rush.jpg` | `(0.22,0.58,0.44,0.88)` → `[422,626,845,950]` (`G1_A0_goldmine.png`) | Wooden minehead on rocky outcrop, purple flag, yellow coin icon, on-screen "Mine has been constructed successfully" | `[O]` geometry+text / `[I]` ore label |
| C16 | mine (gold icon) | same | `(0.202,0.075,0.235,0.120)` → `[387,81,451,129]` (`T2_A0_yellow_icon.png`) | **Yellow coin-stack** disc icon, dark ring; top-saturation mean RGB 183/149/67 | `[O]` icon shape+colour |
| C17 | mine (other ore) | same | `(0.74,0.30,0.90,0.54)` → `[1421,324,1728,583]` (`P4_A0_rightmine.png`) | Same minehead/rock geometry, purple flag, **orange/rust ore-chunk** disc icon (not coin stack) | `[O]` second mine / `[U]` ore |
| C18 | mine (other ore icon) | same | `(0.770,0.325,0.820,0.375)` → `[1478,351,1574,405]` (`T1_A0_orange_icon.png`) | Orange/rust irregular chunk inside dark disc with gold rim; distinct from C16 | `[O]` distinct icon / `[U]` iron-vs-coal |
| C19 | mine (?) | `hqdefault.jpg` | `(300,235,470,335)` and `(330,250,420,320)` px (`Q5_rocks1/2.png`) | Small dark outcrop structures with possible circular icons; 480×360 source too blurred to classify | `[U]` |
| C20 | all classes | remaining 6 stills: `523480776.jpg`, `899956545_preview_20170411195032_1.jpg`, `Cossacks3AttackingVillage.webp`, `MADVBuilding1.JPG`, `hqdefault.jpg`, `large_1.webp` | full frames upscaled to 1400 px wide (`Q1_…`–`Q6_…png`) | Wheat fields/windmill, flat green formations, village/dirt clearing, building close-up, town/threshold blur, dense conifers. **No mountain, no water body, no identifiable mine** | `[O]` negative |

---

## 3. Per-candidate findings

### 3.1 Task 1 — mountain / high-relief silhouette

**C1–C3 "highlands" wallpaper — `[O]` no mountains, three passes.** Pass 1 full frame,
pass 2 upper 55% (the zone a silhouette would occupy), pass 3 upper-left half. Every
high-contrast boundary traces a built wall, scaffold plank, roof tile or unit. No ridge
line separates land from sky; the camera is a close 3/4 overview with no horizon. The
measured `maxRowDiff` values (4.31, 4.31, 8.25) come from wall/hoarding edges, not a
natural skyline. This independently reproduces X07 §3 A6 and V15 §5.6; the filename must
never be cited as mountain evidence (X07 U6).

**C4 A7 embankments — `[O]` earthworks.** Upscaled crop shows vertical brown eroded faces
with striated texture and grass cap, plus conifers rooted at the lip. This is a ravine /
earthen embankment — the channel-H "asymmetric ravine lip" of A04 §4.1 — not a
`terrainmeshN` mountain silhouette. No peak rises above a surrounding skyline.

**C5 A5 slopes — `[O]` rolling hills only.** The dark region is a shadowed, tree-covered
slope; the luminance transition is gradual (`grad 11.43`, `e40 0.033`). No jagged crest,
no rock face above the canopy.

**C6 A9 tree line — `[U]`.** Second pass on a 141×82 native crop cannot distinguish a
distant low hill from haze plus trees. Explicitly **not** promoted to mountain evidence.

**C7 A0 castle — `[O]` man-made.** Complex roof/tower silhouette; the 0.129 `e40` is
architecture on snow, not relief.

**C20 remaining six — `[O]` negative.** Flat to gently rolling ground, fields, forest,
settlements; no high-relief silhouette anywhere.

**Task 1 conclusion:** **[O] no reliable mountain reference exists in this corpus;
X07's verdict is confirmed.** The absence is structural across all 12, not a single
mis-crop.

### 3.2 Task 2 — sea / river / swamp water body with a shoreline

**C8–C12 A11 — `[I]` shoreline structure present; `[U]` water-body identity.** Pass 1
found the band; pass 2 subregion statistics gave a monotone desaturation from green land
(RGB 106/108/63, sat 0.432) to tan band (117/116/79, sat 0.363) to pale band
(168/171/160, sat 0.161); pass 3 tight crop resolves **white wavy curl/foam texture**
immediately offshore of the tan beach. This is a readable land → beach → surf → water
progression with a soft boundary (`maxRowDiff 13.85` over the wider crop). The minimap
shows dark-blue water but is UI, not world evidence. **[I] moderate** that a shoreline
with foam is depicted; **[U]** whether it is sea, riverbank or exposed wet sand — the
source is a 512×288 thumbnail and the pale band can be either. X07's "weak candidate"
ranking stands, upgraded in *detail* (foam now seen) but **not** in identity.

**C13–C14 A5 — `[I]` distant water, no shoreline.** The top-edge strip is blue-gray with
a dark elongated ship silhouette; subregion RGB 71/72/64, sat 0.229. It is background
water in a very high overview, too small for any shore-band calibration. No river course
or swamp fringe appears in the playable ground. **[I]** presence / **[U]** identity.

**Task 2 conclusion:** **[U] no certifiable sea/river/swamp reference.** A shoreline
*pattern* is visible in A11 and distant water in A5, but neither yields a donor-measured
water level, foam width or shore semantics. X07 U2/U5/U9 and V15 §5.2 are unchanged.

### 3.3 Task 3 — gold / iron / coal mine geometry

**C15/C16 A0 gold mine — `[O]` geometry + coin icon; `[I]` "gold" label.** Three passes
(G1 → P5 → T5) show the same built minehead: timber A-frame on a grey rock outcrop, purple
flag, grey/white roofing, and a circular icon. T2 isolates a **yellow coin-stack** icon
(top-saturation mean RGB 183/149/67, max sat 1.0). The on-screen text "Mine has been
constructed successfully" confirms a *built mine*, not a deposit. The coin icon is `[O]`;
mapping coin → gold family stays `[I]` per X07 U8 because no donor legend is in the still.

**C17/C18 A0 second mine — `[O]` non-gold ore site; `[U]` iron vs coal.** A full-frame
scan (G2) revealed a second minehead at the right of the frame; P4 and T1 isolate it. The
geometry is the same timber minehead-on-rock class with a purple flag, but the icon is an
**orange/rust irregular ore chunk** inside a dark disc with a gold rim — visually distinct
from the yellow coin stack. **[O]** a second, non-gold-looking mine is present;
**[U]** which ore (iron, coal, or another family) it represents. This *refines* X07 U4:
the corpus does show more than one mine icon, but still cannot name iron vs coal.

**C19 `hqdefault.jpg` — `[U]`.** Pass 5 crop of the lower-right outcrops shows small dark
structures with possible circular icons, but at 480×360 the icon colour/shape is
unrecoverable. Not counted as mine evidence.

**Task 3 conclusion:** **gold mine visual identity `[I]` (coin icon `[O]`); iron/coal
`[U]`**. No new ore family is identifiable; V15 §5.5 I4/I5 and X07 U4/U8 remain the
authority.

---

## 4. Confirmation of X07 (with the additional evidence)

| X07 claim | This recheck | Net |
|---|---|---|
| No reliable true-mountain reference; "highlands" false positive (X07 §4, U3/U6) | 3 wallpaper crops + 7 other candidates + 6 remaining full frames, all negative; ravine/embankment reclassified as channel-H earthwork | **CONFIRMED `[O]`** |
| Best-available shore is weak `maxresdefault_1.jpg` (X07 §4, U2/U9) | Foam curl texture newly resolved in pass 3; desaturation gradient measured | **CONFIRMED, detail upgraded `[I]`; identity still `[U]`** |
| A5 distant water strip unresolved (X07 U9) | Ship silhouette visible in `T3_A5_ship.png`; strip too thin to calibrate | **CONFIRMED `[I]`/`[U]`** |
| One gold mine; no iron/coal identifiable (X07 U4/U8) | Yellow coin-stack icon confirmed; **second orange ore-chunk mine newly found** but ore type unresolvable | **CONFIRMED + REFINED `[O]`/`[I]`/`[U]`** |
| No rivers/swamps identifiable (X07 U5) | No river course or swamp fringe in any of 12 | **CONFIRMED `[O]` negative** |
| Stills admissible for direction only, never parity (X07 §6, U1) | No ROI of this recheck was used as a numeric gate or donor match | **CONFIRMED `[D]`** |

**No contradiction with X07 is created.** The two refinements (A11 foam is actually
legible; A0 contains a second ore icon type) raise *presence* confidence only and leave
every X07 confidence ceiling intact.

---

## 5. Implications for V15 / A04 acceptance — exactly what CAN be accepted

All properties below are **V15 tier 2 — SELF-CONSISTENT VISUAL**, `PORT APPROXIMATION`,
checked **inside a candidate capture only**, with G0-a…e admissibility (windowed
non-blank 1280×720 PNG, `script_error_lines = 0`, pinned seed/camera/size, identical
fractional ROI on both candidate sides). Each is named from a donor *rule*
(A04 §4 / V15 §4) — **not** from any still measured here. Metric and visual fields stay
separate (A05 §4.2.4). **No property below may be worded as donor fidelity.**

| Class | Tier-2 property that CAN be accepted internally | Donor-rule basis (not a still) | Explicitly NOT accepted |
|---|---|---|---|
| **Hills / rolling relief** | A broad non-concentric mound or asymmetric ravine lip is readable; height extrema fall inside the decoded donor windows; **no concentric rings, no diagonal vein lattice, no hard grid** | `generatemap.inc` amplitude constants; decoded `.pattern` float windows (A04 §4.1, V-E01/E02) | Any claim that the port's mound *looks like* A5/A7; numeric band as donor-measured |
| **Mountains** | A silhouette rises **≥ centre terrain +4 m** and **≥ footprint max +2 m** when props are ON; props-ON/OFF **≥200 changed px, ≥8 px upward rise, <1% outside change**; `matched_stamps > 0`; **no flat-only mound, no rings, no vein lattice** | `pattern.lib` zero mountain grids + `terrainmeshN` prop records, scale 0.3539–0.6562 (A04 E02–E04; V15 §4) | Donor silhouette, runtime `terrainmeshN` chooser, yaw sign, "highlands" wallpaper as reference (X07 U3/U6) |
| **Shore / sea surface** | A **continuous land → warm beach → bright foam → pale water** band with foam **slightly offshore** (not a white rim at the mathematical waterline); live shore ids 93/97/98 present; no half-shore converted to blocked rock; record foam peak RGB / water mean / alpha-at-waterline as **measurements with no pass verdict** | `sandsea1/5/6` ids + aspect table, wet strip −0.25…−0.1, shader foam peak at depth 0.535 (A04 §4.4/§4.5; V-E13/V-E14) | Sea vs riverbank identity (X07 U2/U9), foam pixel width, donor pixel appearance; no "PASS" from a foam metric |
| **Mines (gold / iron / coal)** | Deposit mesh visible on its olive/beige ground disc; built mine **centred** on it; 5×5 dirt plate centred; **no mine without a deposit in range, no concentric deposit rings**; count stream stable under D1; ore differentiation by material only (`PORT APPROX`, meshes byte-identical) | nested `minegold/mineiron/minecoal` objects, scale 0.3152 no jitter, `SetupMines` rings (A04 E14/E15/E25; V-E06/V-E10) | Which ore a still shows; A0's orange icon as "iron" or "coal" (this recheck's `[U]`); finite deposit amount; donor parity |

**Tier-1 (DONOR-GROUNDED STRUCTURE VERIFIED) remains available independently of this
recheck** for pattern/cfg/script counts and hashes (V15 §4 column 1). **Tier 3 stays
tier 3:** no donor mountain still, no certifiable water identity, no river/swamp
placement rule, no iron/coal ore identification from stills. The reviewer line in §8 is
required verbatim on every owner-facing use.

**No change to A04's staged plan** (P0–P6) is warranted by this recheck: P0's
`matched_stamps > 0` guard and ON/OFF pixel A/B stay mandatory; the shore metrics stay
measurements without verdicts; mine type assertions from stills stay forbidden.

---

## 6. UNVERIFIED register

| id | item | basis / passes attempted | settles by |
|---|---|---|---|
| X36-U1 | Mountain silhouette in any of the 12 stills | 12 full frames + 10 targeted crops; absent (C1–C7, C20) | A genuine donor GPU A/B frame or almanac still; X07 Q4 remains open |
| X36-U2 | Whether A6's wallpaper depicts any terrain relief beyond built/scaffold forms | 3 crops (C1–C3); no natural relief seen | Donor map-id metadata for the wallpaper — none exists |
| X36-U3 | A11 pale band = sea / river / wet sand | 4 crops (C8–C12), saturation gradient + foam texture; identity unresolved | D06 water/shore data + a real donor frame; X07 U2/U9 |
| X36-U4 | Foam pixel width / donor water level from A11 | thumbnail 512×288; no world scale | D06 decoded levels as structure only; no still measurement |
| X36-U5 | A5 top strip = sea or river; ship identity | 2 crops (C13/C14); ship silhouette seen, identity not | DLC5 mask scope decision (V15 Q2); no still claim |
| X36-U6 | River or swamp visual anywhere in corpus | all 12; none identifiable | Separate DLC5 rivers ticket / F08 swamp export |
| X36-U7 | A0 orange-icon mine = iron or coal | two passes (C17/C18); orange chunk icon seen, no donor legend | F08/D07 nested-object family binding; X07 Q7 |
| X36-U8 | `hqdefault.jpg` outcrop structures = mines | one tight pass (C19); 480×360 blur | Higher-resolution source; none available |
| X36-U9 | A9 distant slope = hill vs haze/trees | one tight pass (C6); 141×82 native | Higher-resolution source; none available |
| X36-U10 | Donor parity of any port capture | no donor GPU A/B frame (A05 E09, spec §12.6) | COORD only; parity guard never lifted here |

---

## 7. Open questions

1. **(COORD/owner)** Accept the refined A11 reading (foam legible `[I]`, identity `[U]`) as
   a *presence* cue only, while keeping V15's sea tier-2 property donor-rule-named? No
   numeric threshold should be derived from the 512×288 crop.
2. **(F08/D07/X07 U8)** Confirm the resource family behind A0's orange ore-chunk icon and
   the yellow coin-stack icon. This recheck adds a second icon but cannot name it.
3. **(D06/F10)** Is the A11 pale band sea, riverbank or exposed sand? Still cannot decide;
   V15 §5.2 S5 remains `[U]`.
4. **(COORD)** Does the newly visible A5 ship silhouette justify any scope change? Recommendation:
   **no** — it is background water with no shoreline and no calibration value.
5. **(D05/A04)** X07 Q4 / V15 Q6 remains open: with no still, is donor height-window +
   `terrainmeshN` structural evidence alone sufficient for mountain acceptance, or is an
   almanac/manual still required?
6. **(A05/capture)** Confirm that any future A/B uses the identical fractional ROI on both
   candidate sides (G0-e) and that an ROI landing on HUD/units is marked UNVERIFIED rather
   than retried until green (X07 §6 risk 7).

---

## 8. Required reviewer wording (verbatim, A05 §4.2 / X07 §8 / V15 §2)

> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU
> A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

---

## 9. Claim register

| # | Claim | Source | Label |
|---|---|---|---|
| 1 | No mountain/high-relief silhouette in the 12 stills; "highlands" is a false positive | C1–C7, C20; X07 U3/U6 | `[O]` |
| 2 | A7 relief is earthwork/ravine lip, not mountain | C4; A04 §4.1 | `[O]` |
| 3 | A11 shows a land→beach→foam→water shoreline sequence | C8–C12; saturation 0.432→0.363→0.161 | `[I]` |
| 4 | A11/A5 water body identity is not certifiable | C9–C14; X07 U2/U5/U9 | `[U]` |
| 5 | A0 yellow coin-stack mine icon and orange ore-chunk mine icon are visually distinct | C15–C18 | `[O]` |
| 6 | A0 orange icon cannot be named iron or coal | C17/C18; X07 U4; V15 §5.5 | `[U]` |
| 7 | Stills support presence/direction only, never parity or numeric gate | CHARTER §4; A05 E09; X07 §6 | `[D]` |
| 8 | Acceptable visual verdicts are V15 tier 2 self-consistency properties named from donor rules | V15 §2/§4; A04 §4 | `PORT APPROXIMATION` |
| 9 | **No donor parity claim is made anywhere in this report** | this §9; parity_guard | `[U]` |

---

*End of X36. Exactly one repo file written; no source, asset, config, test, shader,
fixture, runner job or git edit; no donor file executed or copied; no reference image or
parity metric invented; no donor-parity claim.*
