---
id: REVIEW3-LATEST
swarm: TERRAIN-SWARM-2026-11-26 / DONOR-TERRAIN VISUAL WAVE
wave: 2026-11-26 VISUAL WAVE — latest post-fix re-review
role: WORKER REVIEW3 — read-only visual re-assessment; reports to COORD
owner_file: docs/terrain_swarm_2026-11-26/reports/REVIEW3_latest.md
reports_written: [docs/terrain_swarm_2026-11-26/reports/REVIEW3_latest.md]
files_edited: []
date: 2026-11-26
status: DELIVERED__ONE_REPORT_ONLY__READ_ONLY__NO_CODE_EDIT__NO_GODOT__NO_GIT__NO_DONOR_EXECUTION
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_claim: false
parity_status: UNVERIFIED
parity_guard: "No donor GPU A/B frame exists. Third-party video frames are direction-of-appearance references only. No similarity score, donor threshold, parity claim or gate PASS is made."
scope_guard: "Exactly one repository file written: this report. No source, shader, config, asset, test, fixture, result JSON, git state, Godot process or donor binary was changed or executed. Image-only probes and crops were read-only on inputs and written only under %TEMP%\\opencode\\review3_crops or managed tool output."
---

# REVIEW3 — latest captures after prop/material, shader, lighting and field fixes

> **PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED.** No donor
> GPU A/B frame exists. This review certifies neither donor fidelity nor a gate pass.

## 0. Executive result

1. **[O] The largest old artifact is gone: no white rectangular prop plinths are visible
   in `cap_donor_240h.png` or wide3 frames 0/12/23.** Old wide2 frame 23 had a
   `386×204 px`, 62,910-pixel bright base component and a pure base strip with
   RGB `160.93/154.90/136.20`, luma `154.83`, saturation `0.157`, gradient `0.74`
   (`COMPARE_BROWSER_frames.md` §3.3/§4). In latest wide3 frame 23 the largest
   pale/low-saturation component is only `65×80 px`, 1,250 pixels, and direct viewing
   places it on rock highlight, not a square base. Full-frame `pale_low_sat` falls
   from `0.0885` in old wide2 frame 23 to `0.00339` in latest wide3 frame 23.
2. **[O] Mountain-like bodies now carry detailed rock albedo and facet shading.** Wide3
   frame 23 `[790,250,1145,480)` has Y std `17.45`, gradient p95 `12.005`, dark32
   `0.0016`, and edge anisotropy `0.233`; the partial body at `[300,0,620,80)` has
   gradient p95 `7.411`. The old smooth grey mounds on hard pale plates are no longer
   the visible result. This is an appearance observation, not proof of the producing
   module or donor mountain identity.
3. **[O] The mill is visible and materially readable in `cap_donor_240h.png`.**
   `[970,120,1140,335)` has Y std `30.46`, gradient p95 `20.629`, and a readable
   stone base, timber gallery and sails. The largest pale component in that area,
   `[1058,184,1097,244)`, is a sail, not a terrain plinth.
4. **[O] Fields are now present, but they are near-black neutral parcels, not golden
   wheat/stubble.** In `cap_donor_240h.png` `[950,230,1280,500)`, a dark-neutral mask
   (`Y<60`, saturation `<0.5`) covers **24,464 pixels / 27.46%** of the ROI; masked
   pixels average RGB `51.43/47.80/41.21`, Y `48.1`. Pixel `(1100,380)` is
   `[50,47,42]`. The squares are visible in the crop; this is a material/albedo
   failure, not field absence and not pure RGB-zero paint.
5. **[O] The dominant remaining defects are still terrain:** a two-valued height field
   produces hard stepped relief; strong diagonal/chevron bands remain on that relief;
   flat ground remains low-detail, periodic and over-saturated; shadows remain off.
   The latest capture still reports 52,298 cells at `-1.099326` and 5,302 at
   `+3.613412` out of 57,600.
6. **[D] Fix order should not simply repeat the old list.** Field material and prop
   material are now high-impact, high-feasibility corrections. Continuous relief and
   exact UV/face behavior remain high-impact but need donor decode or discriminating
   diagnostics before implementation. No parity claim is made.

## 1. Inputs, method and limitations

### 1.1 Required reading completed

Read first:

- `docs/terrain_swarm_2026-11-26/VISUAL_WAVE_CHARTER.md`
- `docs/terrain_swarm_2026-11-26/reports/DONOR_VIDEO_analysis.md`
- `docs/terrain_swarm_2026-11-26/reports/COMPARE_BROWSER_frames.md`
- `docs/terrain_swarm_2026-11-26/reports/ANALYZE_FRAME_new.md`
- `docs/terrain_swarm_2026-11-26/reports/W08_visual_acceptance_criteria.md`

Supporting reads: `W06_performance_audit.md`, `PERF_FEED_preindex.md`,
`VERIFY_HEIGHT_fix.md`, `X06_atlas_visual_audit.md`, and wide3 `capture.json`.

### 1.2 Latest candidate images

| ID | File | Native size | SHA-256 |
|---|---|---:|---|
| C-H | `%TEMP%\opencode\v42\cap_donor_240h.png` | 1280×720 | `a6f736783f9ab632656b92006da437a65974ba75729e69cff584c929687e954f` |
| C-W3-0 | `%TEMP%\opencode\v42\video\donor_240_wide3\frame_0000.png` | 1280×720 | `df0bca56bce985326284f24934e7e1d718ed99c7c2b2acc92ef507f7a688bc93` |
| C-W3-12 | `%TEMP%\opencode\v42\video\donor_240_wide3\frame_0012.png` | 1280×720 | `2c245777479f2ebd1ddbd647fc31b3e1ebfffe1144f12e34f10fc397517d910f` |
| C-W3-23 | `%TEMP%\opencode\v42\video\donor_240_wide3\frame_0023.png` | 1280×720 | `c595d504b0b73d9b0913bea2742d1a184325a629619671b8c20639ebc50062ae` |

Wide3 camera contract: 24-frame deterministic smoothstep X pan `60→420` sim m at
Y `240`, height `58 m`, pitch `−32°`, yaw `0°`, FOV `17.27°`, zoom `0.3448276`;
simulation clock frozen. Frame 0 is pan t=0 / target X=60; frame 12 is t=0.5 /
X=240; frame 23 is t=1 / X=420. Source: wide3 `capture.json` `camera_path` and
`measured.camera_path`.

### 1.3 Donor video evidence

Timestamp-precise 1280×720 frames already extracted from the two downloaded videos
were used:

| Video | Times used | Exact frame root |
|---|---|---|
| V1 `cZW0AEupCaI` | 00:02:00, 00:05:00, 00:10:00, 00:20:00, 00:30:00 | `%TEMP%\opencode\donor_videos\selected\cZW0AEupCaI\t_*.png` |
| V2 `ljlCn4KSSU4` | 00:02:00, 00:10:00, 00:20:00, 00:30:00 | `%TEMP%\opencode\donor_videos\selected\ljlCn4KSSU4\t_*.png`; 120 s frame extracted read-only to `%TEMP%\opencode\review3_crops\v2_t120.png` |

**Browser limitation [O/U].** The requested `browser` skill invocation was refused
(`permission.rejected: skill`), and tool search exposed no browser namespace or tab
tool in this worker session. The supplied tab IDs
`tab_89a2e090-0133-4bc0-94d9-2a7812b03216` and
`tab_9ff49987-9415-45f1-89a1-a698c816557c` were therefore not accessible. No fresh
browser seek/screenshot is claimed. The exact video frames above are the evidence;
this matches the prior DONOR-VIDEO finding that tab IDs are session-local.

### 1.4 Metric definitions and guardrails

Boxes are `[x0,y0,x1,y1)`, origin top-left, on the named 1280×720 image.

- Y = `0.2126R + 0.7152G + 0.0722B`; saturation = `(max−min)/max`.
- Gradient uses central differences, divided by 2; `p95` is the 95th percentile.
- Edge anisotropy: 12 bins of 15° modulo 180°, weighted by
  `max(gradient−median,0)`, then `(max−min)/(max+min)`.
- `BV32` is the population std of 32×32 luminance block means.
- `AC24/AC48` are horizontal luminance autocorrelations at 24/48 px.
- `dark16/dark32` use `max(RGB)≤16/32`; `pale_low_sat` uses `Y>105` and
  saturation `<0.42`; `gold_like` uses `R>B+30`, `G>B+15`, `R>90`.

These are **per-image support cues**, not cross-image similarity, donor thresholds or
pass/fail gates. H.264/JPEG detail, different scenes and unknown donor cameras prevent
numeric calibration. `cap_donor_240h.png` has a dark/partial top strip; terrain reads
below exclude it rather than treating its full-frame row jump as terrain evidence.

## 2. Improvement ledger — what is confirmed in the latest images

| Item | Old evidence | Latest evidence | Verdict |
|---|---|---|---|
| White square/circular plinths | Old wide2 f23: bright component `386×204`, 62,910 px; pure strip RGB `160.93/154.90/136.20`, Y `154.83`, sat `.157`, grad `.74` | C-W3-23 full `pale_low_sat=.00339`; largest pale component `65×80`, 1,250 px, on rock highlight; C-H largest pale component `39×60`, 1,020 px, on mill sail. Direct full/crop views show continuous grass at mountain/mine footprints | **[O] Gone in inspected latest frames.** Pale rock highlights, mill sails and a deposit disc remain; they are not rectangular plinths |
| Mountain/relief material | Old wide2 f23: smooth grey mounds on hard pale square plates | C-W3-23 `[790,250,1145,480)`: Y std `17.45`, grad p95 `12.005`, dark32 `.0016`, anis `.233`; top fragment `[300,0,620,80)` grad p95 `7.411` | **[O] Textured mountain-like bodies visible.** No producer/module or donor class identity inferred |
| Mill | Old wide2 had no readable mill; old f12 substituted a pale mine disc | C-H `[970,120,1140,335)`: Y std `30.46`, grad p95 `20.629`; readable timber gallery, stone base and sails | **[O] Mill visible and non-silhouette** |
| Fields | Old requested pans had no legible field class | C-H `[950,230,1280,500)` contains repeated parcel squares; dark-neutral mask 24,464 px, mean RGB `51.43/47.80/41.21` | **[O] Present but black/dark-neutral.** Material fix still required |
| Buildings / boulders | Old 240c prop MID `dark16=52.8%` (`ANALYZE_FRAME_new.md` §3.2/§4) | C-H building `[650,90,1140,340)` dark16 `3.28%`, grad p95 `15.941`; wood, roofs and trim readable | **[O] Major prop-material improvement** |
| Trees / units | Old uniform black silhouettes | C-H tree ROIs are mostly textured, but pure-black pixels and bare/dark variants remain; mill-unit ROI dark16 `4.89%`, dark32 `10.92%` | **[O] Improved, not complete** |
| Lighting | Old props black; no readable terrain response | C-H props readable under raised rig; wide3 `capture.json` records ambient `1.4`, sun `2.0` | **[O] Prop lighting improved.** `shadows_enabled=false`; terrain shader still does not consume the scene rig |

## 3. Latest capture facts that constrain the visual read

| Fact | Exact evidence | Consequence |
|---|---|---|
| Height remains effectively two-valued | Wide3 `capture.json` `mesh_stats.height_hist_deciles`: boundaries `[-1.099326, 0×9, +3.613412]`; counts `[52298, 0×8, 5302]`; 57,600 cells total; 2 m cells | **[D]** A ≈4.7127 m jump across one cell explains flat tops and hard stair perimeters. This is not a texture-only complaint |
| Face promotion is sparse | `face_hist={0:56500,1:405,2:695}`; `relief_mask_cells_no_face_promotion=0` | **[D]** 98.1% of cells remain face 0; steep-face variation is not encoded by broad face promotion |
| UV/UV2 contract changed | `uv="cell-centre ((x+0.5)/w,(z+0.5)/h)"`; `uv2=(tile id,face)` | **[O]** Old eye-plane explanation is weakened, but diagonal bands remain; exact cause is still not proven |
| Shadows are off | `lighting.shadows_enabled=false`; `terrain_shader="manual Blinn-Phong unchanged; unshaded terrain does not consume this scene rig"` | **[O]** No contact/cast-shadow language can be expected from this configuration |
| Capture is not realtime proof | `timing.max_frame_ms=381`, `median_all_ms=220`, `capture_wall_ms=6177`, `target_fps=6`, `real_time_claim=false` | **[O]/[U]** Screenshot/readback wall time is measurable; gameplay FPS and donor runtime speed are not |

## 4. Top 10 remaining differences vs donor videos

Confidence is confidence in the **visual classification**, not donor parity:
**H = .90–.98**, **M = .65–.85**, **L = .40–.60**.

| Rank | Category | Remaining difference | Exact candidate evidence | Exact donor timestamp / pixel evidence | Conf. |
|---:|---|---|---|---|---|
| **1** | **GEOMETRY** | Relief is still a hard stepped, flat-topped mesa complex rather than continuous organic relief | C-W3-0 `[0,0,950,500)` dark32 `9.75%`, anis `.677`; C-W3-12 `[0,0,720,520)` dark32 `16.62%`, anis `.708`. Visible 90° stair/chevron perimeter. Telemetry: 52,298 cells `−1.099326`, 5,302 `+3.613412`, Δ≈4.7127 m over 2 m | V1 **00:05:00** `t_300.png` `[0,180,900,540)`: broad multi-peak ridge, max row jump `1.595`, dark32 `1.10%`; V2 **00:30:00** `t_1800.png` `[500,200,1130,620)`: broad gently rolling grass, no stair lattice | **H .96** |
| **2** | **TILE/UV** | Strong diagonal/chevron bands remain on relief; they persist through the pan and dominate the surface read | C-W3-0 relief anis `.6769`; C-W3-12 relief anis `.7078`. Direct frames show nested olive/near-black chevrons at f0 `(250–650,120–500)` and f12 `(150–500,120–500)`. By contrast, latest mountain-body ROI C-W3-23 `[790,250,1145,480)` anis is only `.2327` | V1 **00:20:00** mine/rock ROI anis `.0727`; V1 **00:30:00** field/mill ROI `.0821`; V2 **00:20:00** mine/barracks/rock `.1545`; V1 **00:05:00** mountain `.4787` — directional rock detail exists in donor, but not the candidate’s relief-wide chevron lattice | **H .88** |
| **3** | **FIELD MATERIAL** | Field parcels exist but render as near-black neutral squares, with no golden crop-row texture | C-H `[950,230,1280,500)`: dark-neutral mask **24,464 px / 27.46%**, masked mean RGB `51.43/47.80/41.21`, Y mean `48.1`; `(1100,380)=[50,47,42]`; parcel region includes components `[974,301,1117,392)`, `[1033,252,1280,421)`, `[1096,303,1280,452)` | V1 **00:02:00** `t_120.png` field/mill `[760,120,1210,560)`: `gold_like=.1853`, grad p95 `16.186`; V2 **00:02:00** field `[0,80,450,280)`: gold `.1159`, grad p95 `9.32`; V1 **00:30:00** field/mill: gold `.2092`, grad p95 `17.715` | **H .97** |
| **4** | **LIGHTING** | No contact/cast shadows; steep terrain faces still collapse to near-black ambient-only tones | Wide3 `capture.json`: `shadows_enabled=false`; terrain shader does not consume scene rig. C-W3-0 relief dark32 `9.75%`; pixel `(1000,600)=[23,28,20]`. C-H mill/building are readable but sit without long ground/contact shadows | V2 **00:10:00** `t_600.png`: forest/town has long tree/prop shadows and lit/shadowed crowns; V1 **00:20:00** mine/rock and V2 **00:20:00** barracks/rock show dark contact under clustered props | **H .90** |
| **5** | **TILE/UV** | Flat ground remains low-detail, periodic and over-saturated; the square/checker read is still visible | C-W3-12 flat `[800,430,1280,720)`: Y std `3.54`, BV32 `1.088`, AC24 `.3904`, AC48 `.2809`, mean RGB `73.01/75.61/20.69`, sat `.7259`. C-H clean `[0,390,650,700)`: BV32 `2.257`, B `20.82`, sat `.7208` | V1 **00:02:00** grass `[250,400,700,650)`: BV32 `9.25`, B `34.54`, sat `.5944`, grad p95 `9.241`; V2 **00:10:00** grass `[450,450,1100,700)`: BV32 `14.505`, B `31.80`, sat `.5968`, grad p95 `9.787` | **H .86** |
| **6** | **PROP MATERIAL** | Residual pure-black units and bare/dark tree variants remain among otherwise improved props | C-H mill/unit ROI `[980,270,1150,340)`: dark16 `4.89%`, dark32 `10.92%`, darkest `(1056,270)=[0,0,0]`; trees-left `[60,330,360,560)` black `.58%`, darkest `(198,330)=[0,0,0]`; trees-right black `.55%` | V2 **00:02:00** forest `[0,280,470,650)` has dense shaded crowns, dark32 `6.17%` but high canopy coverage; V1 **00:10:00** forest `[0,80,650,500)` dark32 `2.75%`, with lit/shadow sides rather than isolated black sticks | **M .76** |
| **7** | **PLACEMENT** | Mine/deposit is still a smooth isolated ellipse with a tiny dark centre, not a minehead integrated into a rock/dirt cluster | C-W3-12 component `[351,335,463,392)`, 112×57 px, area 4,943; mean RGB `91.92/92.30/45.95`, Y std `20.67`; centre `(405,362)=[54,53,45]`. No surrounding boulder cluster or readable minehead | V1 **00:20:00** mine/rock `[780,330,1100,570)`: Y std `19.28`, grad p95 `10.65`, irregular rock/tree/grass integration; V2 **00:20:00** mine/barracks/rock `[250,180,760,450)`: Y std `28.09`, grad p95 `15.855`, clustered grey rock and timber | **H .84** |
| **8** | **PLACEMENT** | Forest placement is still sparse/isolated in the inspected candidate areas; donor groves are dense, irregular belts with glades | C-H left tree ROI `[60,330,360,560)`: non-ground coverage `6.58%`, only 5 components ≥20 px; right edge `[1130,40,1280,330)` coverage `24.54%`. Wide3 shows scattered individuals rather than stands | V2 **00:02:00** forest `[0,280,470,650)`: coverage `82.05%`; V2 **00:10:00** forest `[0,120,700,560)`: coverage `72.36%`, 42 components ≥20 px, irregular grove edge and open grass | **M .78** |
| **9** | **CAMERA** | Candidate wide framing makes props tiny and leaves large empty ground; donor references use closer three-quarter economy/skirmish framing | Wide3: height 58 m, FOV 17.27°, pitch −32°, zoom .3448, X `60→420` (360 m) over 24 frames. C-W3-23 mountain body is 331×200 px and trees are only a few pixels; C-H is closer but still has broad empty ground | V1 **00:02:00** mill/field and V2 **00:02:00** town/mine/forest occupy much larger frame shares with readable prop scale. Donor height/FOV/zoom are unknown, so this is framing direction only | **M .62** |
| **10** | **PERFORMANCE** | Candidate capture path still exceeds its 6 fps target on some frames; no valid donor runtime benchmark exists | Wide3 `capture.json`: max frame `381 ms`, median `220 ms`, 24 frames / `6177 ms`, target `6 fps`, `real_time_claim=false`. Max implies ≈2.62 fps and median ≈4.55 fps **for capture/readback wall time only** | Donor video flow diagnostic (`DONOR_VIDEO_analysis.md` §5.1): V1 **00:01:00–00:01:08** effectively locked; V2 **00:05:00–00:05:08** reposition then locked. Edited video supplies no FPS/frame-time benchmark | **L .55** |

### 4.1 Why ranks 1–2 remain the terrain blockers

The latest material fix is real: the mountain body at C-W3-23
`[790,250,1145,480)` has detailed rock texture, Y std `17.45`, gradient p95 `12.005`
and low dark32 `.0016`. However, the **terrain relief** in C-W3-0/C-W3-12 remains a
different visual system: flat dark tops, vertical/stairstep boundaries and nested
chevrons. Its anisotropy `.677–.708` exceeds every donor ROI measured here;
even V1's directional mountain ROI is `.479`. The image and the independent
height histogram agree, so this is not a call to hide the symptom with noise or
emissive fill.

### 4.2 Why rank 3 is a material defect, not field absence

The field squares are clearly present in C-H and form repeated closed parcels next to
the mill. Their masked pixels are not transparent and not pure black; they are a very
dark neutral `[51,48,41]`. Donor field references at 00:02:00 and 00:30:00 have golden
crop texture, readable rows and boundaries. The correct next step is donor field
albedo/decal binding and lighting verification, not more field placement noise.

### 4.3 Performance ranking caveat

Rank 10 is last because it is **not a demonstrated donor-vs-port performance
difference**. The candidate numbers are exact capture-path measurements; the donor
side has no admissible runtime instrumentation. It remains a usability risk and a
measurement task, not a parity metric.

## 5. Fix ranking by visual impact and feasibility

Fix rank differs from defect rank because a high-impact fix can be blocked on decode,
while a slightly lower visual defect can be safe and immediate.

| Fix rank | Action | Category | Visual impact | Feasibility | Disposition | Verification after fix |
|---:|---|---|---|---|---|---|
| **1** | Bind/restore donor wheat/stubble albedo and field decals; keep closed parcel footprints and remove the dark-neutral material fallback | FIELD MATERIAL | Very high | High | **SAFE NOW** using donor-authored field art; no invented gold tint | Re-shoot C-H camera: field pixels gain golden crop-row texture; dark-neutral mask collapses; parcel edges stay legible |
| **2** | Replace the two-valued height result with the donor continuous relief path; resolve native `SmoothTerrain`/plateau/blend behavior before changing the field | GEOMETRY | Very high | Medium–low | **MORE DONOR DECODE**; diagnostics first, no arbitrary smoothing or `HEIGHT_SCALE` | Height histogram no longer effectively two-valued; no 90° stair perimeter or flat mesa tops in wide3 |
| **3** | Run constant-atlas and constant-normal renders, then bind the donor UV/face projection that explains the remaining chevrons | TILE/UV | Very high | Medium | **DIAGNOSTIC-FIRST / MORE DONOR DECODE** | Relief-wide anisotropy drops without flattening geometry; no diagonal vein lattice through pan |
| **4** | Restore terrain light response and bounded contact/cast shadows; keep the existing donor `light.cfg` colours/energy | LIGHTING | High | Medium | **PARTIAL SAFE NOW** for prop/contact pass; terrain normal-stencil semantics need decode/diagnostic | Steep faces recover mid-tones; props gain contact shadows; no crushed blacks; frame cost measured |
| **5** | Audit atlas/season/mip binding and donor tile scale; remove periodic flat-ground read without synthetic noise | TILE/UV | High | Medium | **SAFE NOW** for binding/mip/season audit; **MORE DECODE** for repeat/face constants | BV32 and multi-scale variation rise; 24/48 px periodic peaks weaken; no new grid or crawl |
| **6** | Audit unit/tree material and LOD variants; remove pure-black/bare fallback instances | PROP MATERIAL | Medium–high | High | **SAFE NOW** after per-instance material/LOD dump | Named prop ROIs contain no silhouette-only black variant; textured crowns/bodies remain readable |
| **7** | Integrate deposit/mine with donor rock cluster, dirt plate and centred minehead; remove the smooth isolated ellipse | PLACEMENT | Medium | Medium | **MORE DONOR DECODE** for `StandPatternWithAngle`/placement transform; asset binding audit is safe now | Mine is centred on irregular rock/dirt footprint; no orphan disc or geometric base |
| **8** | Restore forest-family coverage, irregular density and glades; resolve missing pattern/placement records | PLACEMENT | Medium | Medium | **MORE DONOR DECODE / ASSET CONVERSION** | Groves and irregular edges appear; no plantation grid; tree shadows remain readable |
| **9** | Add closer pinned feature captures for mill/field, mine/rocks and forest edge; do not retune game camera from video alone | CAMERA | Medium | High for capture; low for implementation | **SAFE NOW for diagnostics**; camera constants need donor reference | Same-camera candidate self-A/B isolates material/placement defects from wide-shot emptiness |
| **10** | Adopt compact props feed only behind byte/count equivalence; add stage/frame timers separate from screenshot readback | PERFORMANCE | Usability high; visual low | High | **SAFE NOW behind equivalence + Godot A/B**; no donor decode needed, no realtime claim yet | Same props/counts/transforms; measured startup and frame-time delta; `real_time_claim` remains false until proven |

## 6. Safe now vs needs more donor decode

### 6.1 Safe to implement now

1. **Field material/decals** — the field class and footprint are visible; the remaining
   defect is the dark-neutral material response.
2. **Prop material/LOD audit** — buildings and boulders prove the rig can produce
   readable materials; units and some tree variants are the remaining local failures.
3. **Bounded prop/contact-shadow pass** — use the existing donor light data; measure
   the frame cost before broad adoption.
4. **Atlas/season/mip binding audit** — verify the intended donor cells and masks are
   consumed; do not invent a new repeat value.
5. **Closer diagnostic captures** — feature shots are capture work, not camera parity.
6. **Compact props feed prototype/adoption** — only with exact record/count/transform
   equivalence and a Godot A/B; the 11 MB vs 56 MB asset result alone is not a runtime
   speed claim.

### 6.2 Needs more donor decode or a discriminating donor-grounded diagnostic

1. **Continuous relief geometry** — native smoothing/plateau behavior and the exact
   stamp composition that prevents the two-valued height result.
2. **Relief chevrons** — constant-atlas/constant-normal/UV0 diagnostics plus donor
   face/UV semantics; the current image cannot separate tile art, UV and normals.
3. **Mine and forest placement transforms** — `StandPatternWithAngle`, pattern
   occupancy/stand footprint and missing family records.
4. **Terrain normal/lighting stencil** — the scene light rig exists, but the terrain
   shader does not consume it; exact donor normal behavior remains load-bearing.
5. **Camera constants and donor motion speed** — third-party edited video cannot
   supply them.

### 6.3 Needs port measurement, not donor decode

- Gameplay/capture frame time, draw calls and startup stage timers.
- Shadow cost at 1280×720 on the target GPU.
- Per-instance material/LOD IDs for black units, bare trees and the deposit disc.
- Clean-ground ROI confirmation; the runner ROI is still marked
  `UNVERIFIED_PENDING_VISUAL_REVIEW`.

## 7. Multiple-pass and ambiguity register

| Ambiguity | Passes attempted | Result |
|---|---|---|
| White plinths vs pale rock/mill sails | Full frame + 2× crops + pale-component scan on C-H/C-W3-23 + old wide2 metric | **[O] Old rectangular plinth gone.** Remaining pale components are sail/rock highlight, not base planes |
| Mountain texture vs terrain chevrons | C-W3-23 body crop and metrics; C-W3-0/12 relief crops and anisotropy; telemetry | **[O] Mountain-like body is textured; relief chevrons remain a separate defect** |
| Field absence vs black material | C-H field crop; dark-neutral component/mask analysis; donor field ROIs at 120/1800 s | **[O] Fields present; dark-neutral material is the defect** |
| Deposit disc vs white plinth | C-W3-12 component extraction and crop; old disc/base comparison | **[O] Smooth deposit ellipse remains, but it is not the old white square plinth** |
| Camera mismatch | Wide3 `capture.json` + direct donor frame scale read | **[U] Donor camera values unknown; direction only** |
| Performance difference | Wide3 timing JSON + DONOR-VIDEO flow diagnostic | **[U] Donor runtime benchmark absent; candidate capture-path timing only** |
| Browser tabs | `skill("browser")` attempt + global tool search + cache glob | **[O] Skill/tool unavailable in this worker; exact ffmpeg frames used instead** |

## 8. UNVERIFIED items that must stay open

| ID | Unknown | Why unresolved | What would settle it |
|---|---|---|---|
| R3-U1 | Exact producer of the latest textured mountain-like bodies | Image shows appearance, not module/material provenance | Per-instance mesh/material dump |
| R3-U2 | Exact cause of relief chevrons | World-locked persistence rules out a pure screen overlay, but not tile-id/UV/normal interaction | Constant-atlas + constant-normal + UV0 A/B at pinned camera |
| R3-U3 | Whether all 5,302 upper cells are exactly equal | Deciles show two occupied bins, not the full distribution | Finer/full height histogram from live backend |
| R3-U4 | Why field parcels are dark-neutral | No per-decal material/texture dump | Field decal/material IDs and albedo-only render |
| R3-U5 | Donor camera height/FOV/zoom and world speed | Third-party edited recordings | Owner-controlled admissible camera reference; still no parity assumption |
| R3-U6 | Donor runtime FPS/frame time | Video has no runtime instrumentation | Separate donor performance capture, if permitted |
| R3-U7 | Mine/forest placement transform fidelity | Visual placement differs; native transform semantics remain unverified | Donor-grounded `StandPatternWithAngle`/occupancy decode + port diagnostic |
| R3-U8 | Donor parity | No donor GPU A/B frame exists | Remains UNVERIFIED; no report wording may promote it |

## 9. Claim register and handoff

| # | Claim | Label |
|---:|---|---|
| 1 | White rectangular plinths are gone from the inspected latest frames | [O] |
| 2 | Mountain-like bodies now show detailed rock material and facet shading | [O] |
| 3 | Mill is visible and materially readable in C-H | [O] |
| 4 | Fields are present but near-black neutral parcels | [O] |
| 5 | Height remains effectively two-valued and relief remains stepped | [O]/[D] |
| 6 | Relief-wide diagonal/chevron anisotropy remains stronger than the donor comparison ROIs | [O]/[D], direction only |
| 7 | Flat ground remains low-detail, periodic and over-saturated | [O]/[D] |
| 8 | Shadows remain disabled and steep faces remain dark | [O] |
| 9 | Mine/forest placement and some prop variants remain visibly different | [O]/[I] |
| 10 | Candidate capture timing is measured; donor runtime performance is not | [O]/[U] |
| 11 | **No donor parity, similarity percentage, donor threshold or gate PASS is claimed** | [U] |

**COORD handoff:** implement the safe material/prop/lighting/atlas fixes first, while
holding geometry, UV/face and placement changes behind the named donor diagnostics.
Re-capture the same wide3 path plus closer pinned mill/field, mine/rock and forest-edge
shots. Keep `parity.claim=NONE`, `parity.status=UNVERIFIED`, and keep metric fields
separate from visual verdicts.

*End of REVIEW3. Exactly one repository file written: this report. No source, shader,
config, asset, test, fixture, result JSON, git, Godot or donor-binary change; no donor
parity claim.*
