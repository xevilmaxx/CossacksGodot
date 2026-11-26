---
id: VIDEO-MINE-FIELD
swarm: TERRAIN-SWARM-2026-11-26 / DONOR-TERRAIN VISUAL WAVE
role: WORKER VIDEO-MINE-FIELD — donor video mine-size / ground-colour / mill-field visual analysis
owner_file: docs/terrain_swarm_2026-11-26/reports/VIDEO_MINE_FIELD.md
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_CODE__NO_GODOT__NO_GIT__NO_DONOR_EXEC
created: 2026-11-26
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_guard: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists. Third-party video frames are direction-of-appearance references only (unknown build/map/camera/zoom/compression). No similarity score, donor threshold, or gate PASS is claimed."
scope_guard: "Exactly one repo file written (this report). No source/asset/config/test/shader/fixture/git/runner state touched; no Godot job submitted; no donor binary executed; no donor material copied into the repo. Donor frames viewed read-only under %TEMP%\\opencode\\donor_videos\\selected\\."
temp_roots:
  donor_frames: "%TEMP%\\opencode\\donor_videos\\selected\\"
  candidates: "%TEMP%\\opencode\\v42\\"
  inbox: "inbox/qa/captures/"
governing_sources:
  - docs/terrain_swarm_2026-11-26/reports/DONOR_VIDEO_analysis.md
  - docs/terrain_swarm_2026-11-26/reports/REVIEW3_latest.md
  - docs/terrain_swarm_2026-11-26/reports/PHOTO_LED_mine_colour_seam.md
  - docs/terrain_swarm_2026-11-26/reports/AUDIT_FIELD_STAGE_TIMING.md
---

# VIDEO-MINE-FIELD — donor mine / ground / mill-field visual wave

> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor
> GPU A/B frame exists. This review certifies neither donor fidelity nor a gate pass.

## 0. Executive summary

1. **[O] Donor mines are small, ground-integrated rock/dirt/pit features, not floating discs.** Across V1 `t_120/600/1200/1800` and V2 `t_300/600/1200/1800` (1280×720), mine footprints are a fraction of a town-hall footprint and only a few infantry-heights wide. No pale circular "phantom" disc or halo surrounds any donor mine; grass, dirt and rock meet the pit/minehead directly with a dark contact edge.
2. **[O] Donor ground immediately around mines matches global grass, with only a local dirt/rock transition.** No bleached halo is visible. Prior candidate-only measurement (`PHOTO_LED_mine_colour_seam.md` §1) found candidate mine-disc `~[84,85,36]` vs global grass `~[72-73,74-76,20-21]` (delta roughly +12R/+11G/+16B). The donor video grass direction cited there (`~[78,80,36]`) sits closer to the candidate mine disc than to candidate global grass — i.e. the seam is a candidate terrain-lighting mismatch, not donor art.
3. **[O] Donor mill-fields are large, closed, golden parcels with the mill centred in (or cutting) the parcel.** V1 `t_120` (00:02:00) and V1 `t_1800` (00:30:00) show a diamond/square parcel roughly 1× town-hall width, solid gold crop-row texture to the parcel edge, with a square dirt clearing only immediately under the mill. Prior support cues: `gold_like 0.185–0.209`, grad p95 `16–18` on V1 field/mill ROIs (`DONOR_VIDEO_analysis.md` §6.1). Coverage is parcel-full, not scattered dots.
4. **[O] Latest candidates invert all three:** `cap_donor_240n.png` shows an isolated smooth mine ellipse with an explicit pale halo on otherwise flat grass; `cap_defaultcfg_donor.png` repeats the halo on three deposits; field parcels in the 240n-line (per REVIEW3/AUDIT) are dark-neutral (`~[51,48,41]`, gold fraction `~0.078`) or faint olive dots, not golden closed parcels.
5. **[D] Safest-5 fix order (all without invented constants or parity claims):** (1) remove/attenuate candidate mine halo-disc; (2) bind already-converted mature `field` albedo under donor-config QA capture (`map_donor_240.json`); (3) audit terrain light-rig parity between prop and terrain paths; (4) centre minehead on irregular rock/dirt cluster; (5) close field parcel shape + dirt clearing under mill. Each has an exact ROI re-measure below.

## 1. Inputs, method, limits

### 1.1 Frames viewed (exact timestamps)

All 1280×720. V1 = `cZW0AEupCaI` (Cossacks 3 – GAMEPLAY [PC/HD]); V2 = `ljlCn4KSSU4` (Raptor).

| ID in this report | Video time | File |
|---|---|---|
| V1-120 | 00:02:00 | `...\\selected\\cZW0AEupCaI\\t_120.png` |
| V1-600 | 00:10:00 | `...\\selected\\cZW0AEupCaI\\t_600.png` |
| V1-1200 | 00:20:00 | `...\\selected\\cZW0AEupCaI\\t_1200.png` |
| V1-1800 | 00:30:00 | `...\\selected\\cZW0AEupCaI\\t_1800.png` |
| V1-300-ridge | 00:05:00 (context) | `...\\selected\\cZW0AEupCaI\\t_300.png` |
| V2-300 | 00:05:00 | `...\\selected\\ljlCn4KSSU4\\t_300.png` |
| V2-600 | 00:10:00 | `...\\selected\\ljlCn4KSSU4\\t_600.png` |
| V2-1200 | 00:20:00 | `...\\selected\\ljlCn4KSSU4\\t_1200.png` |
| V2-1800 | 00:30:00 | `...\\selected\\ljlCn4KSSU4\\t_1800.png` |

Candidate stills viewed read-only:

| ID | File |
|---|---|
| C-N | `%TEMP%\\opencode\\v42\\cap_donor_240n.png` (also `inbox/qa/captures/cap_donor_240n.png`) |
| C-DEF | `inbox/qa/captures/cap_defaultcfg_donor.png` |
| C-CONTACT | `inbox/qa/captures/donor_compare_contact.png`, `contact_wide-final.png` |

Required prior reads completed: `DONOR_VIDEO_analysis.md` (§4 shot table, §6 field ROIs), `REVIEW3_latest.md` (§2–§4: plinth gone, fields black, deposit ellipse `112×57`, field dark-neutral mask `24,464 px / 27.46%`), `PHOTO_LED_mine_colour_seam.md` (§1 ROI table), `AUDIT_FIELD_STAGE_TIMING.md` (§1–§6: born-ripe, decal/mip BLOCKED, Branch A/B).

### 1.2 How ROIs are reported

- Boxes are `[x0,y0,x1,y1)` pixel rectangles on the named 1280×720 image, origin top-left, estimated by direct view. They are **locators for re-measurement**, not measured constants.
- No new RGB/means are computed in this worker. All numbers quoted are taken from the four governing reports above. No donor threshold is set.
- Labels: **[O]** directly seen, **[D]** arithmetic/ranking from cited numbers, **[I]** interpretation, **[U]** unresolved. **PORT APPROXIMATION** applies to every candidate-vs-donor sentence.

## 2. (a) Donor mine size vs buildings/units and ground footprint

### 2.1 Per-timestamp reads

| Frame | Donor mine ROI (est., 1280×720) | [O] size vs building/unit | [O] ground footprint / phantom check |
|---|---|---|---|
| V1-120 (00:02:00) | pit at approx `[590,460,700,530)` bottom-centre; gold-lit construction at `[510,330,650,430)`; town halls at `[380,140,560,330)` and `[670,130,850,330)`; mill parcel right `[920,140,1280,390)` | Pit long axis ≈ 1/3 town-hall width, ≈ 1/5 mill-parcel width. Peasant at `[490,330,510,360)` is a few px; pit is ~8–12× peasant height. Construction-site yellow wash is a light effect, not a ground disc | Pit is a dark coal/ore hollow with red glints sitting **directly on grass**. No pale disc, no halo ring, no square base. Grass texture continues to the pit lip |
| V1-600 (00:10:00) | mine/rock works at approx `[620,180,730,260)` centre; red-roof mill/building at `[520,220,620,310)`; town-hall-scale gothic block left `[90,250,220,360)` | Mine works ≈ 1/2 red-building width, ≈ 1/4 town-hall width. Infantry not in this crop; scale anchor is the red building | Dark timber/mine furniture inside a **rock cluster**, grass between rocks. No geometric plate. Fog/dark at right edge is a video/UI shadow, not terrain art |
| V1-1200 (00:20:00) | minehead + rock at approx `[920,160,1050,270)` top-right; troop line top `[810,70,1110,130)`; red church `[400,230,500,330)` | Minehead hut ≈ 1 infantry-file height tall; rock apron ≈ 3–4× hut width ≈ 1/3 red-church width. Troop line shows infantry are tiny vs mine/rock and vs church | Timber hut centred on **irregular grey rock apron with trees and grass intruding**. Dirt/grass transition is ragged. No disc, no halo, no axis-aligned edge |
| V1-1800 (00:30:00) | two mine/rocks: top-centre `[620,40,730,130)`, right `[1060,220,1170,330)`; mill centre `[690,370,760,460)`; town hall left `[270,380,480,560)` | Each mine ≈ 1/2 mill-base width, ≈ 1/4–1/5 town-hall width. Peasant dots on the field are 3–6 px; mine is ~15–25× a single peasant dot in area extent | Both mines are **rock pile + timber**, rooted in the same continuous grass as the field margin and the army ground. No base plane under either |
| V2-300 (00:05:00) | stone pit centre `[400,110,560,220)`; timber minehead top-left `[210,40,300,140)`; gatehouse right `[1060,120,1150,200)`; wall-tower centre `[650,270,730,370)` | Stone pit ≈ gatehouse footprint, ≈ 1/3–1/2 town-scale block. Tower ≈ pit width. Peasant dots 3–5 px; pit spans dozens of peasant-widths but stays building-subordinate | Pit is **open grey rubble with grass tongues and saplings inside the perimeter**. Timber minehead sits in its own smaller rock ring. No disc/halo; boundary is rock-by-rock |
| V2-600 (00:10:00) | gatehouse centre `[400,100,530,220)`; mine/rock left `[70,140,220,240)`; wall-tower centre-right `[700,220,780,300)`; lower tower `[180,380,280,470)` | Mine rock field ≈ gatehouse width, wider than a single tower. Musketeer block centre (~60 men) occupies similar ground area to one mine apron | Mine is a **broad flat rock scatter**, not a mound; grass shows through between stones. Towers have a thin dirt ring, not a pale plate |
| V2-1200 (00:20:00) | mine/barracks/rock centre `[330,160,640,280)`; barracks left `[280,220,480,360)`; scaffold tower centre `[650,320,790,480)`; gatehouse top-right `[880,20,1020,150)` | Rock apron ≈ barracks footprint; scaffold tower ≈ 1/2 apron width. Single pikeman at right `[1170,280,1185,315)` confirms infantry ≪ mine apron ≪ barracks block | Barracks, rock, scaffold and dirt all share **one continuous ground sheet** with contact darkening. No halo outlines the rock |
| V2-1800 (00:30:00) | rock scatter right `[1060,370,1220,470)`; cannon centre `[650,320,690,360)`; musketeer block `[810,220,980,540)` | Rock scatter ≈ 1/4 block width. Block rows show individual musketeers ~8–12 px tall; rock pile is ~6–10 men wide | Rocks sit on **open rolling grass** with a shallow dirt smudge only. No disc. Long unit shadows cross grass and rock alike, proving one lighting space |

### 2.2 Sequence behaviour (treated as video, not stills)

- **[O]** Across the V1 00:02:00 → 00:10:00 → 00:20:00 → 00:30:00 progression the mine class is stable: pit/rock + timber, always subordinate to the town-hall/mill scale, always with grass up to the lip. No frame shows a halo fading in/out, i.e. the absence of a phantom disc is not a single-frame compression accident.
- **[O]** Across V2 00:05:00 → 00:10:00 → 00:20:00 → 00:30:00 the same holds under a different map/zoom: mines are flatter rock scatters or timber heads, never a raised pale ellipse. The dirt ring (where present, e.g. V2-600 towers, V2-1200 barracks) is thin, irregular and darker than grass, opposite in polarity to the candidate pale halo.
- **[D]** Direction: candidate mine footprint should shrink toward "fraction of a hall, few-men high" and lose any axis-aligned or elliptical pale surround. The cited candidate deposit component (`112×57 px, 4,943 px` in REVIEW3 §4 rank 7, C-W3-12 `[351,335,463,392)`) is already in the right size ballpark — the defect is the **smooth isolated ellipse + halo**, not the pixel count.

### 2.3 Phantom disc/halo verdict

- **[O] Donor: no phantom disc/halo at any of the 8 timestamps.** What reads as "yellow wash" in V1-120 around the construction site is a warm light glow over grass and paving, bounded by the building footprint, not a ground-material ring. All mine-adjacent grass keeps donor mottling and texture to the rock lip.
- **[O] Candidate: halo present.** C-N shows a pale translucent ellipse around the centre-left deposit (approx `[390,340,500,400)` halo around a `[410,355,470,390)` rock core) and a second halo around the mill-adjacent deposit at top-right; C-DEF repeats halos on three deposits (left-mid, top-centre-right, right-mid). Contact sheet `donor_compare_contact.png` juxtaposes donor rock-direct grounding vs candidate disc directly. This matches the old wide2 disc lineage (`5,025 px bright component` in DONOR-VIDEO §3.3; `4,943 px` ellipse in REVIEW3 §4) — smaller now, but still geometrically regular and pale.

## 3. (b) Donor ground colour immediately around mines vs global grass

- **[O] Donor: no bleached ring.** In every mine ROI above, the 10–30 px band outside the outer rock is mottled green grass continuous with the field-wide grass. Local variation is (i) grey rock, (ii) small brown dirt smudge under timber/rock (V1-1200, V2-1200), (iii) dark contact occlusion under stones. There is no step to a paler or more saturated annulus. V1-300-ridge context confirms the same grass language extends from rock aprons to open pasture and forest fringe.
- **[O] Candidate numbers (reused, not recomputed):** `PHOTO_LED_mine_colour_seam.md` §1 on `cap_donor_240n.png`:

  | ROI | Box | Mean RGB | Sat |
  |---|---|---|---|
  | Mine disc | `(430,330)-(530,410)` | `[83.9,85.0,35.9]` | 0.590 |
  | Mine halo | `(390,300)-(570,440)` | `[76.3,78.4,25.4]` | 0.686 |
  | Global grass left | `(0,450)-(300,700)` | `[72.0,74.4,20.3]` | 0.727 |
  | Global grass top | `(0,40)-(600,200)` | `[73.0,75.7,20.5]` | 0.731 |
  | Field area | `(1000,230)-(1280,450)` | `[71.7,71.9,18.7]` | 0.757 |

  Delta global→disc ≈ **+12R/+11G/+16B**; global→halo ≈ **+4R/+4G/+5B**. Donor video grass direction cited there ≈ `[78,80,36]`, nearer the candidate mine disc than candidate global grass.

- **[I] Interpretation (per PHOTO_LED §2, endorsed):** the seam is a **port lighting-consistency mismatch** — props consume the donor-derived rig (`AMBIENT 1.4 / SUN 2.0`, shadows off) while the terrain shader applies unscaled light colours — not a donor-ground tint to copy and not tile art. Native `sceneColor` remains `[U]` per `DEC_SMALL_light_products.md`, so any correction is a labelled PORT calibration.
- **[D] What "fixed" looks like without inventing constants:** after a light-match change, the exact five ROIs above re-measured on a same-camera re-shoot should converge (global grass moving donor-ward toward the cited `[76-79,78-81,25-36]` acceptance band, halo/disc not overbrightening, global saturation falling from `~0.73` toward donor direction `~0.56-0.60`), with no shadows/AO/noise/emissive introduced (`PHOTO_LED §3`). No new RGB target is set in this report.

## 4. (c) Donor mill-field visibility, gold coverage, parcel shape

| Frame | Mill/field ROI (est.) | [O] visibility / coverage / shape |
|---|---|---|
| V1-120 (00:02:00) | parcel approx `[920,140,1280,390)`, mill centre `[1090,170,1170,270)` | Closed diamond parcel, mill **inside a square dirt clearing** at parcel centre-right. Gold cover is **parcel-full edge-to-edge** with readable crop rows and a darker edge boundary. Parcel diagonal ≈ town-hall width. Peasants dot the gold, confirming it is a workable crop surface, not paint |
| V1-1800 (00:30:00) | parcel approx `[380,280,910,560)`, mill `[660,370,740,460)` | Same diamond grammar at larger extent: mill centred, dirt clearing square under mill, gold **continuous around all four sides**, peasants harvesting across the face. Army column marches past the parcel edge without a gap strip — field, road/grass and buildings share one ground plane |
| V1-600 (00:10:00) | no mill/field in this framing | Negative control: forest/rock/grass only, confirming fields are discrete placed parcels, not a global ground tint |
| V1-1200 (00:20:00) | no mill/field in this framing | Negative control: mine/forest/troop framing with no gold, same grass language as field frames |
| V2 series (t_300/600/1200/1800) | no mill-centred parcel in these four framings (wheat noted at settlement edges in DONOR_VIDEO §4.2/§6 at V2-900) | Confirms mill-fields are **localised parcels**, not always in frame. V2-1800 open grass shows the base grass the parcel would sit on: mottled, gently rolling, no parcel grid |

Supporting donor texture cues (reused from `DONOR_VIDEO_analysis.md` §6.1, mixed field+mill ROIs, not pure-crop samples): V1-120 field/mill sat `0.631` grad `10.07`; V1-900 field/mill sat `0.628`; V1-1800 field/mill/army sat `0.597` grad `11.12`; V2-900 wheat edge sat `0.571` grad `15.42`. These are descriptors of golden row texture + boundary density, never thresholds.

Parcel-shape grammar **[O]**: closed rectangle/diamond, straight edges, sharp gold-vs-grass boundary, mill footprint cutting a dirt square out of the gold, no feathered falloff, no scattered outlier dots.

## 5. Comparison to latest captures

| Aspect | Donor direction (8 timestamps) | Latest candidate (C-N / C-DEF / contacts) | Verdict |
|---|---|---|---|
| Mine footprint | Rock/dirt/pit fraction of hall, grass to lip, dark contact, no plate | Smooth isolated ellipse + translucent pale halo on flat grass (C-N centre-left + top-right; C-DEF ×3). REVIEW3 C-W3-12 ellipse `112×57 / 4,943 px`, centre `[54,53,45]`, no boulder cluster | **[O] Size ballpark plausible; integration fails. Halo has no donor counterpart** |
| Ground around mine | Same mottled grass as global; thin dark dirt only | Pale annulus brighter/greener than global grass (PHOTO_LED deltas above); global grass flat/over-saturated (REVIEW3 C-W3-12 flat `[800,430,1280,720)`: BV32 `1.088`, sat `.726`; C-H clean BV32 `2.257`, B `20.82`, sat `.721` vs donor grass BV32 `9-14`, sat `~.59-.60`) | **[O] Candidate seam is port-side; donor shows continuity** |
| Mill-field | Closed golden parcel, mill-centred dirt square, full gold rows | 240n-line: dark-neutral parcels (`masked mean [51,48,41]`, mask `24,464 px / 27.46%` of `[950,230,1280,500)`, pixel `(1100,380)=[50,47,42]`, gold `~0.078` per AUDIT context); C-N top-right shows only faint olive dots, no gold mass; AUDIT Branch A (no `demo_mill` in default config) or Branch B (olive = ground-decal layer with missing mips + substitute blend) | **[O] Present-but-black / absent depending on config; in neither case golden closed parcel** |
| Mill itself | Stone base + timber gallery + sails, shaded faces, contact shadow | C-N mill readable (stone/timber/sails per REVIEW3) but floating without field context; sails cast no ground shadow (`shadows_enabled=false`) | **[O] Mill improved; field + shadow context missing** |
| Lighting unity | Long soft shadows, lit/shadowed rock/tree/building faces, contact darkening under every prop | Props on raised rig, terrain on unscaled colours; steep faces crush to near-black; no cast/contact shadows (REVIEW3 §3; terrain shader "does not consume scene rig") | **[O] Two lighting spaces visible; halo/ground flatness follows** |

AUDIT staging note **[O/D]**: fresh demo-mill parcels are born `hits=max_hits=50` → `field_state()="ripe"` → `_field_spec` selects mature `"field"` art from t=0, so a frozen/early screenshot clock cannot demote them. Olive/dark ROI is therefore config (Branch A: shipped `config.json` lacks `features.terrain.demo_mill`; only `map_donor_*.json` set it) or decal-layer (Branch B: `mipmaps/generate=false` on `field.png`/`envfieldd/w.png` + `GL_DST_ALPHA` substitute + albedo-multiplier emission). No HP/threshold/timing change is indicated.

## 6. Ranked 5 safest concrete fixes (no invented constants, no parity claim)

Ordered by safety × visual leverage for the mine/field wave. "Expected measurement" means re-measure the **cited exact ROI** on a same-camera re-shoot; values are direction checks against already-published numbers, never new donor constants.

| Rank | Fix (concrete, reversible) | Why safe | Exact verification (same camera, same ROIs) |
|---|---|---|---|
| **1. Attenuate/remove the candidate mine halo-disc** | Reduce halo-quad opacity/extent (or gate it off in the QA capture) so only the rock core + dirt/contact remain; keep rock albedo, positions, counts byte-identical. No new ground tint | Geometry/placement untouched; halo has no donor counterpart at any of the 8 timestamps (§2.3); REVIEW3 already separates sail/rock highlight from plinth | C-N halo ROI `(390,300)-(570,440)` vs global `(0,450)-(300,700)` + `(0,40)-(600,200)`: halo→global delta should collapse from `+4/+4/+5` toward ~0 without the disc going overbright; disc ROI `(430,330)-(530,410)` keeps texture (Y std preserved); no new axis-aligned edge in crop |
| **2. QA-capture the mature field under the donor fixture (config, not code)** | Re-shoot `cap_donor_240n`-equivalent with `map_donor_240.json` (`demo_mill:true`) and assert `field_visual_states` / `field_visual_ripe_count` + `texture_status="DONOR_CONVERTED field -> …"` before reading pixels (AUDIT §6.1). Default `config.json` stays flag-off | Zero code/gameplay delta; distinguishes Branch A (empty states dict → ROI was never a field) from Branch B (ripe-bound yet olive → decal layer). Fresh parcels need no sim advance | Log: `field_ripe_mature>0`; ROI `[950,230,1280,500)`: dark-neutral mask (`Y<60`, sat `<0.5`) should collapse from `24,464 px / 27.46%`, gold fraction rise from `~0.078` toward donor-direction gold (`gold_like ~0.11-0.21` band cited in REVIEW3 §4 rank 3 as description only); parcel edges stay closed rectangles |
| **3. Unify terrain/props light calibration (labelled PORT match, no donor constant)** | Apply the single already-plumbed PORT light-match scaling to the terrain path (the `PHOTO_LED §3` acceptance change); gate behind a flag so overshoot reverts rather than stacking fudge. No shadows/AO/noise/emission added; no mine retint | Mine art already acceptable per PHOTO_LED §2; defect is two lighting spaces. Change is one scalar path + revert rule, fully captured by the 5-ROI table | Same 5 ROIs as §3: global grass moves from `~[72-73,74-76,20-21]` sat `~0.73` donor-ward into the published acceptance band `[76-79,78-81,25-36]`, sat falling toward `0.56-0.60` direction; mine disc/halo deltas do not invert (no overshoot past halo); terrain Y std/BV32 must not flatten |
| **4. Centre minehead on an irregular rock/dirt cluster with dark contact** | Reuse already-converted rock/timber assets to ring each deposit with a ragged boulder apron + thin dark dirt smudge (V1-1200/V2-300 grammar); keep deposit centre where it is. No new asset, no transform-constant change beyond placement of existing instances | Asset binding audit is safe-now per REVIEW3 §6.1; placement-transform decode stays open (R3-U7) but a ragged cluster moves the read donor-ward without claiming `StandPatternWithAngle` fidelity | C-W3-12-style component `[351,335,463,392)`: bbox stays ~eloc but boundary contrast vs grass softens (no smooth ellipse edge-run); rock-component count/cluster bbox rises from 1 smooth blob toward multi-rock; dark-contact ring appears at base; no pale annulus re-emerges in the `(390,300)-(570,440)` halo band |
| **5. Close the field parcel + dirt clearing under the mill** | Keep parcel positions from the demo-mill ring; ensure each parcel renders as one closed rectangle/diamond with a shared gold crop material to the boundary and a single dirt square under the mill (V1-120/V1-1800 grammar). No new gold tint — bind the converted mature `field.png` + existing decal path only | Footprint logic already exists; defect is material/decal + closure, not placement invention. Gated by Fix 2's log proof so terrain paint is never misread as crop | ROI `[950,230,1280,500)`: closed-component count matches parcel count (no dot-grid: C-N olive dots consolidated); parcel fill is gold-textured (grad p95 rises from near-flat toward donor-description band `9-17`, sat leaves neutral); mill clearing reads as dirt square, not a halo; same-camera before/after pair archived |

Explicitly **not** proposed here: new gold RGB, new halo RGB, terrain-noise injection, `HEIGHT_SCALE`/smoothing changes, shadow implementation, camera retune, or any donor-threshold gate. Shore/water, donor camera height/FOV/zoom, donor FPS and exact `StandPatternWithAngle` semantics stay **[U]** per DONOR-VIDEO §11 / REVIEW3 §8.

## 7. UNVERIFIED register (must stay open)

| ID | Item | Why unresolved | What would settle it |
|---|---|---|---|
| VMF-U1 | Donor parity of any mine/field/ground pixel | Third-party H.264, unknown build/map/camera/zoom/compression; no donor GPU A/B frame | Owner-controlled same-camera donor/port capture; still no parity assumption |
| VMF-U2 | Exact donor ground RGB around mines | Video compression + unknown lighting/exposure prevent numeric calibration; this report reuses candidate-internal + direction-only cues | Admissible lossless donor ground reference, if ever available |
| VMF-U3 | Native `sceneColor` runtime value | Recovered material products known, runtime value not (`DEC_SMALL_light_products.md`) | Donor runtime/structural decode; until then Fix 3 stays labelled PORT calibration |
| VMF-U4 | Field decal final appearance under donor blend + mips | `GL_DST_ALPHA` unencodable in Godot; `field.png`/`envfieldd/w.png` lack mip chains (AUDIT §5 Branch B) | Asset-import owner mip fix + labelled substitute A/B at pinned mill camera |
| VMF-U5 | Mine/forest placement transform fidelity | Visual grammar clear, `StandPatternWithAngle`/occupancy semantics unverified (R3-U7) | Donor-grounded placement decode + port diagnostic |
| VMF-U6 | Unsampled video intervals | 8 timestamps + prior 10 s sweep cover classes, not every second | Targeted extraction only if a new class (e.g. shore) is claimed |

## 8. Claim register

| # | Claim | Label |
|---:|---|---|
| 1 | Donor mines at all 8 timestamps are building-subordinate rock/dirt/pit features with grass to the lip and no pale disc/halo | [O] |
| 2 | Donor ground around mines matches global mottled grass apart from local rock/dirt/contact | [O] |
| 3 | Donor mill-fields are closed golden parcels with mill-centred dirt clearing and parcel-full crop rows | [O] |
| 4 | Candidate mines carry a pale halo with no donor counterpart; candidate fields are dark-neutral/absent per config/decal, not golden | [O] |
| 5 | Seam is a port lighting-consistency mismatch, not donor art; native sceneColor remains unknown | [O]/[I] per PHOTO_LED §2 |
| 6 | Stage-selection timing is exonerated (born-ripe → mature `field` from t=0); olive/dark is config or decal-layer | [O]/[D] per AUDIT §1–§4 |
| 7 | Five ranked fixes are the safest next steps; expected measurements are same-ROI direction checks, not thresholds | [D] |
| 8 | No donor parity, similarity percentage, donor threshold, or gate PASS is claimed | [U] |

*End of VIDEO-MINE-FIELD. Exactly one repository file written: this report. No source, shader, config, asset, test, fixture, result JSON, git, Godot or donor-binary change; no donor parity claim.*
