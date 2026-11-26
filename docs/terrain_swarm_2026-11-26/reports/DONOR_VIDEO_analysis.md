---
id: DONOR-VIDEO
swarm: TERRAIN-SWARM-2026-11-26 / TERRAIN-VISUAL-WAVE-2026-11-26
role: WORKER DONOR-VIDEO — donor video terrain-quality and behavior analysis
owner_file: docs/terrain_swarm_2026-11-26/reports/DONOR_VIDEO_analysis.md
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_CODE_EDIT__NO_GODOT_JOB__NO_DONOR_PARITY_CLAIM
created: 2026-11-26
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this review certifies neither donor fidelity nor a gate pass."
scope_guard: "Exactly one repo file written (this report). No source/asset/config/test/shader/fixture/git/runner state touched; no Godot job submitted; no donor binary executed or donor material copied into the repo."
temp_root: "C:\\Users\\Maxym.Oboyshev\\AppData\\Local\\Temp\\opencode\\donor_videos\\"
governing_sources:
  - docs/terrain_swarm_2026-11-26/VISUAL_WAVE_CHARTER.md
  - docs/terrain_swarm_2026-11-26/reports/W08_visual_acceptance_criteria.md
  - docs/terrain_swarm_2026-11-26/reports/X07_visual_reference_index.md
  - docs/terrain_swarm_2026-11-26/reports/X36_mountain_visual_recheck.md
  - reference/videos.md
  - C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\video\donor_240_wide2\capture.json
---

# DONOR-VIDEO — terrain quality, motion and wide2 gap analysis

## 0. Executive summary

1. **[O] Both requested videos were downloaded and frame-extracted.** The first is
   `Cossacks 3 - GAMEPLAY [PC/HD]`, 40:21.901, downloaded as 1280×720/30 fps H.264.
   The second is Raptor's `Building an UNSTOPPABLE ARMY & Nation in this City Building
   RTS Masterpiece | Cossacks 3 Gameplay`, 37:33.581, downloaded as 1280×720/60 fps
   H.264. This supersedes only the old factual note in `reference/videos.md` and
   W08 §4 that these URLs had not yielded stream frames; it does **not** lift the
   parity guard.
2. **[O] The videos materially improve the visual reference corpus.** V1 at 00:05:00
   (`t_300.png`) and 00:35:00 (`t_2100.png`) shows real rocky mountain/ridge forms,
   which the 12 stills in X07/X36 did not contain. V2 supplies especially clear
   mine/rock/grass integration at 00:05:00, 00:10:00 and 00:20:00.
3. **[O] The current wide2 capture remains visually blocked by four dominant
   artifacts:** near-black stepped relief with diagonal bands; an almost uniform
   olive checkerboard ground; black silhouette-only props; and pale circular/square
   terrain plates under mines/mountains. `frame_0023.png` is the clearest failure:
   smooth mounds sit on hard white square bases rather than continuous terrain.
4. **[D] Highest-value correction order:** remove terrain plates → replace stepped
   relief with continuous organic forms → restore multi-scale ground material →
   restore directional/contact shading → integrate rocks/mines/forests/fields →
   fix prop/unit scale and anchoring → prove temporal stability → acquire a real
   shore/water reference before making shore claims.
5. **[O] No certifiable shore/water transition was found in the sampled gameplay.**
   All 467 ten-second samples, both contact-sheet sets, and targeted blue-dominant
   candidates were inspected. The best candidates were uniforms, UI or dark forest,
   not water. This is a reference gap, not proof that water is absent from every
   unsampled interval.
6. **[U] No donor-parity or same-camera A/B claim is made.** These are third-party
   recordings of unknown build, map, camera, zoom and compression. Metrics below
   describe images or candidate self-consistency; they are not donor thresholds.

> PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU
> A/B frame exists; this review certifies neither donor fidelity nor a gate pass.

## 1. Method, provenance and admissibility

### 1.1 Pass ledger

| Pass | Instrument | Scope | Result |
|---|---|---|---|
| 1 | `read` | Visual-wave charter, W08, X07, X36, `reference/videos.md` | Acceptance vocabulary, still-reference limits and prior video-frame gap loaded |
| 2 | `yt-dlp` + `ffprobe` | Both URLs; best available MP4 ≤720p | Actual 720p H.264 files obtained; metadata verified |
| 3 | `ffmpeg` | One frame every 10 s, downscaled to 640×360 | V1: 242 samples, 0–2410 s; V2: 225 samples, 0–2240 s |
| 4 | `ffmpeg tile` | 6×8 contact sheets | V1: 6 sheets; V2: 5 sheets; partial final sheets padded black |
| 5 | `ffmpeg -ss` | Full 1280×720 selected frames | Terrain/prop/field/lighting evidence at cited timestamps |
| 6 | Pillow/NumPy | 2× LANCZOS crops + image metrics | White-base, banding, grass-periodicity, material and field cues rechecked |
| 7 | In-app browser | Video-element seek/play/pause/screenshot | Eight new browser screenshots; four COORD screenshots incorporated |
| 8 | OpenCV | 1 Hz background optical-flow diagnostic over ten 8 s clips | Static intervals separated from low-confidence cuts/repositions; no world-speed claim |

### 1.2 Download attempts and exact errors

The generic selector and combined MP4 itag initially failed for both videos:

```text
ERROR: [youtube] cZW0AEupCaI: Requested format is not available. Use --list-formats for a list of available formats
ERROR: [youtube] ljlCn4KSSU4: Requested format is not available. Use --list-formats for a list of available formats
```

`--list-formats` exposed video-only MP4 itag `136` (1280×720/30) for V1 and itag
`298` (1280×720/60) for V2. Explicit downloads of those formats succeeded. No
metadata-only fallback was needed and no frame was invented.

The COORD-provided browser tab IDs were session-local and unavailable to this
worker (`browser.tab_unavailable`; this session had no open tabs). The same two
YouTube URLs were opened in new tabs. V2 initially showed a six-second pre-roll
ad; after it finished, `video.duration` was confirmed as `2253.581`, not a Short.

### 1.3 Labels and limits

- **[O]** directly seen in a frame/crop or computed from a file.
- **[D]** arithmetic or ranking derived from observations; direction only.
- **[I]** interpretation without a same-camera donor capture.
- **[U]** unresolved after multiple passes.
- **PORT APPROXIMATION** applies to every wide2/candidate verdict.

Videos are reference-only. Unknown build, map, camera, field of view, zoom,
world-area-per-pixel and H.264 compression prevent numeric calibration. No SSIM,
MAD, percentage similarity, donor threshold or parity score is used.

## 2. Source metadata

| ID | URL | Title | Duration | Source / downloaded video |
|---|---|---|---:|---|
| V1 | `https://www.youtube.com/watch?v=cZW0AEupCaI` | Cossacks 3 - GAMEPLAY [PC/HD] | 2421.901 s = 40:21.901 | Source offers 1920×1080/30; downloaded itag 136, 1280×720/30, H.264, no audio |
| V2 | `https://www.youtube.com/watch?v=ljlCn4KSSU4` | Building an UNSTOPPABLE ARMY & Nation in this City Building RTS Masterpiece \| Cossacks 3 Gameplay | 2253.581 s = 37:33.581 | Source offers 1920×1080/60; downloaded itag 298, 1280×720/60, H.264, no audio |

Downloaded files:

```text
C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\donor_videos\cZW0AEupCaI.mp4
C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\donor_videos\ljlCn4KSSU4.mp4
```

## 3. Current wide2 baseline

### 3.1 Capture/camera facts

`capture.json` describes a deterministic 24-frame smoothstep pan, not real-time
gameplay: target X moves 60→420 sim-m at Y=240, height 58 m, pitch −32°, FOV
17.27°, zoom 0.3448276, no orbit, simulation clock frozen. Therefore:

- `frame_0000.png`: t=0, target X=60 sim-m.
- `frame_0012.png`: t=0.5, target X=240 sim-m.
- `frame_0023.png`: t=1, target X=420 sim-m.
- Maximum analytic pan step is `1.5×360/23 = 23.48 sim-m/frame` near mid-pan.
- Capture wall time was about 0.74 s/frame, but that is **not** a realtime camera
  speed because the sim clock was frozen.

### 3.2 Direct frame read

| Frame | [O] visible content | [D] quality consequence |
|---|---|---|
| `frame_0000.png` | Flat olive ground with a strong square checkerboard; large near-black stepped relief islands; diagonal light/dark bands; tiny black trees/units | Relief reads as cut geometry or texture bands, not continuous land; props read as silhouettes |
| `frame_0012.png` | Same ground; pale circular mine/deposit disc with a dark pit; black props; stepped band field at upper-left | Mine/deposit is a floating graphic disc rather than rock/ground integration |
| `frame_0023.png` | Two smooth gray mounds on hard pale square plates; black isolated trees; flat olive ground | Mountain props read as placed tiles/models on bases, not mountain silhouettes rooted in terrain |
| `wide2_contact.jpg` | All 24 frames; bands persist through the pan; square/disc bases enter and leave frame | Temporal sequence does not repair the artifacts; it makes plate pop-in and persistent banding more obvious |

### 3.3 Supporting metrics — descriptors, not gates

ROIs are pixel rectangles on 1280×720 frames. `BV32` is variance of 32×32
luminance block means; `grad` is mean gradient magnitude; `e40` is fraction with
gradient >40; `lag48x` is horizontal luminance autocorrelation at 48 px.

| Image / ROI | BV32 | grad | e40 | lum std | mean sat | lag48x | Note |
|---|---:|---:|---:|---:|---:|---:|---|
| wide2 f0012, `[650,300,1150,650]` | 0.319 | 2.067 | 0 | 3.156 | 0.728 | 0.536 | Clean flat grass; periodic cue |
| wide2 f0023, `[100,250,500,600]` | 0.281 | 1.921 | 0 | 3.004 | 0.728 | 0.533 | Clean flat grass; periodic cue |
| wide2 f0000, `[300,300,800,600]` | 212.35 | 3.001 | 0.00053 | 18.24 | 0.645 | 0.488 | ROI intersects dark relief; not clean grass |
| V1 00:01:00, `[500,450,800,650]` | 16.38 | 6.569 | 0.0126 | 14.00 | 0.567 | 0.091 | Donor clean grass |
| V1 00:05:00, `[50,250,550,600]` | 20.36 | 2.212 | 0.00483 | 11.96 | 0.593 | 0.007 | Donor clean grass |
| V2 00:01:00, `[500,400,850,650]` | 47.63 | 4.908 | 0.0104 | 14.72 | 0.562 | 0.127 | Donor clean grass |
| V2 00:10:00, `[400,350,750,600]` | 43.56 | 4.569 | 0.0148 | 15.30 | 0.566 | 0.099 | Donor clean grass |
| V2 00:30:00, `[200,300,600,550]` | 16.80 | 4.112 | 0.00283 | 9.00 | 0.593 | 0.135 | Donor clean grass |

**[D] Read:** the two clean wide2 grass ROIs have nearly zero 32 px block
variance and a 46–48 px horizontal autocorrelation peak (`r≈0.54–0.55`). The
visible checkerboard is therefore not merely a subjective complaint. Donor
clean-grass samples have multi-scale variation and much weaker 48 px periodicity.
These values are not transferable thresholds.

A bright/low-saturation connected-component screen found a `386×204 px`,
62,910-pixel component in wide2 `frame_0023.png`; the 2× crop confirms it is the
lower square terrain plate. In `frame_0012.png`, a `112×57 px`, 5,025-pixel bright
component sits inside the larger circular mine disc. Thresholding is only a locator;
the visual crop is the evidence.

## 4. Shot-by-shot donor comparison

Evidence IDs below resolve to exact files in §9/§10. “Donor-correct” means
**visible in the donor recording**, not a certified implementation constant and
not a parity claim.

### 4.1 V1 — Cossacks 3 - GAMEPLAY [PC/HD]

| Time | Evidence | [O] visibly donor-correct cue | [D] what wide2 still lacks |
|---:|---|---|---|
| 00:01:00 | V1-060, V1-060-B, crop `v1_t060_field_mill` | Golden/green field parcel with readable rows and edge; windmill centred on the parcel; timber/stone shading; rock-and-tree cluster behind the town hall; peasants at a believable small scale | No field parcel or windmill; f0012 substitutes a pale mine disc; trees/units are black silhouettes |
| 00:02:00 | V1-120 | More mature golden wheat square around the windmill; construction footprint and stone paving stay distinct; long soft shadows and contact darkening | No parcel semantics; no contact shadows; no readable construction materials |
| 00:05:00 | V1-300, crop `v1_t300_mountains` | Broad rocky ridge with multiple irregular peaks, shaded faces, forest fringe and continuous grass in front | f0000 has stepped black bands; f0023 has smooth mounds on white squares, not a rooted ridge |
| 00:10:00 | V1-600 | Dense mixed conifer stand forms an irregular edge with glades; mine/rock forms sit in the landscape; fog/depth softens the far forest | Wide2 forest is sparse black cutouts; no canopy material, glade structure or depth cue |
| 00:15:00 | V1-900, V1-900-B | Large golden field, windmill, formal troop lines and stone buildings share a coherent scale; foundations/paving anchor structures | Wide2 has no comparable field/building/formation composition or anchored scale |
| 00:20:00 | V1-1200, crop `v1_t1200_mine_forest` | Wooden minehead is integrated into a clustered rock outcrop with surrounding trees and grass; no geometric base plate | f0012 shows a pale circular deposit/mine graphic with no integrated rock cluster |
| 00:25:00 | V1-1500, V1-1500-B, crop `v1_t1500_stone_city` | Market/stable/stone architecture has lit and shadowed faces; troops and peasants remain readable; rocks cluster naturally | Wide2 props are silhouettes; no material response, foundation contact or readable scale hierarchy |
| 00:30:00 | V1-1800, crop `v1_t1800_field_mine` | Wheat wraps the mill; army formations and walls follow the ground; mine/rocks remain part of the same continuous grass field | No fields, walls, anchored mine or unit/terrain relationship in wide2 |
| 00:35:00 | V1-2100, V1-2100-B, crop `v1_t2100_mountain_forest` | Mountain/ridge rises behind a forested middle ground; cavalry mass sits on open grass; atmospheric depth separates near/far forms | f0023's square-base mound has no forested middle ground, atmospheric depth or integrated silhouette |

**V1-specific conclusions.**

- **[O] Camera:** high three-quarter RTS view. The sampled clips are often locked
  off for economy/building observation, with intermittent repositioning or cuts.
- **[O] Silhouette:** V1 is the stronger mountain reference; 00:05:00 is the
  cleanest multi-peak rocky ridge, while 00:35:00 shows ridge + forest + army
  depth in one frame.
- **[O] Placement:** fields, mills, mines, walls and armies are composed as
  readable functional parcels rather than isolated noise patches.
- **[O] Lighting:** warm directional sun, long shadows, dark contact under rocks,
  trees and buildings, and visible shaded sides. No silhouette-only treatment.

### 4.2 V2 — Raptor gameplay

| Time | Evidence | [O] visibly donor-correct cue | [D] what wide2 still lacks |
|---:|---|---|---|
| 00:01:00 | V2-060, V2-060-B | Stone town hall, small mine-like pits and rock clusters sit directly on continuous textured grass; conifers frame the scene; units remain small but readable | Wide2 ground is flat/checkerboard; pits/rocks are absent or disc-like; props are black |
| 00:05:00 | V2-300, V2-300-C, crop `v2_t300_stone_mine` | Wooden mine structure is integrated into clustered gray rocks on grass; no white square base; nearby stone towers use the same grounded language | Direct counterexample to wide2 f0012's pale circular base |
| 00:10:00 | V2-600, V2-600-C, crop `v2_t600_forest_town` | Irregular mixed forest with individual shaded canopies, long shadows and grassy gaps; town/stone structures remain anchored | Wide2 has isolated black tree icons, no long shadows or forest-edge ecology |
| 00:15:00 | V2-900, V2-900-B | Wheat parcels at the left/top edge, dense village, forest edge and troops form a readable wide composition | No parcel footprints or coherent settlement/terrain composition in wide2 |
| 00:20:00 | V2-1200, V2-1200-C, crop `v2_t1200_stone_barracks` | Barracks/gatehouse, scaffolding, rock cluster and construction foundation all sit on continuous ground; materials and contact shadows are legible | Wide2 has no equivalent anchored architecture or rock/grass integration |
| 00:25:00 | V2-1500, V2-1500-B | Large troop formations fight on subtly varied grass; smoke, unit shadows and a shallow dark ground channel add depth | Wide2 has tiny black units and no ground-depth/shadow interaction |
| 00:30:00 | V2-1800, V2-1800-C, crop `v2_t1800_army_grass` | Broad gently rolling grass, forest edge, rocks and a large orderly formation; unit spacing and ground footprint stay readable | Wide2 cannot support this scale read: flat ground plus black unit marks |
| 00:35:00 | V2-2100, V2-2100-B | Burning buildings, mine/rock cluster, golden field and forest coexist without base plates; smoke/fire contrast against shaded terrain | Wide2 has no integrated prop ecology, field texture or material contrast |

**V2-specific conclusions.**

- **[O] Camera:** high three-quarter view with more frequent repositioning during
  base building and combat. Locked observation intervals alternate with cuts or
  fast tracking moves.
- **[O] Mine/stone:** V2 is the strongest integration reference. Rocks, timber,
  dirt and grass meet directly; there is no geometric white/square plate.
- **[O] Forest:** dense, irregular, mixed-height canopies with lit/shadowed sides
  and open glades, not a plantation grid.
- **[O] Scale:** infantry is tiny relative to buildings and trees but remains
  readable because it is shaded and contrasted, not a flat black glyph.

## 5. Cross-video terrain behavior

| Category | V1 | V2 | Wide2 current read |
|---|---|---|---|
| Camera motion/speed | Long locked economy shots; intermittent pan/reposition; 00:05:00 and 00:35:00 establish landscape depth | More frequent tracking/repositioning; locked inspection of mines/buildings; combat pans | Deterministic smoothstep 60→420 sim-m over 24 frames; no orbit; artifacts persist and plates pop in |
| Hill/mountain silhouette | Strongest: multi-peak rocky ridge at 00:05:00; ridge+forest at 00:35:00 | Mostly rolling ground; shallow dark channel/depression at 00:25:00/00:35:00 | Stepped diagonal bands or smooth mounds on square plates |
| Shore/water | Not certifiable in sampled frames | Not certifiable in sampled frames | No water visible in the three requested frames |
| Forests | Dense mixed belts, irregular edges, glades, fog/depth | Very clear irregular mixed stands, long shadows, individual canopies | Sparse black silhouette trees; no canopy shading or glades |
| Stone/mines | Minehead on clustered rock; mountain rock faces; contact shadows | Best mine/rock/grass integration; towers/mines share grounded footprint | Pale circular mine disc; black bands; no integrated rock cluster |
| Fields | Windmill-centered parcels, formal armies alongside, visible crop rows | Wheat parcels at settlement edges, readable boundaries | No field class visible |
| Texture scale/mottling | Fine grass plus broad tonal patches; crop rows at a different scale | Fine grass, dirt tracks, broad patches, high-frequency rock/canopy detail | Near-uniform olive checkerboard; horizontal periodicity peaks at 46–48 px |
| Lighting/shadows | Warm directional sun, long soft shadows, shaded rock/tree/building faces | Strong contact shadows and lit/shadow split on rocks, roofs, trees and units | Terrain is dark/flat or banded; props are black; no contact-shadow language |
| Unit/building scale | Town hall/windmill/peasant/formation hierarchy is readable | Infantry, towers, town hall and forest have consistent relative scale | Tiny black units/props; mountain/mine plates dominate the frame |

### 5.1 Camera-motion diagnostic

OpenCV background-flow sampling used a central playfield mask and one-second
steps. It is a diagnostic for **static versus repositioning**, not a world-speed
measurement: low track counts mark cuts or unreliable matches.

| Clip | [O]/[D] flow result | [I] interpretation |
|---|---|---|
| V1 00:01:00–00:01:08 | All 8 median background flows ≤0.011 px/s | Effectively locked camera |
| V1 00:25:00–00:25:08 | 7/8 ≤0.019 px/s; one ≈14.3 px/s | Mostly locked, then a move |
| V2 00:05:00–00:05:08 | Five intervals 33.8–100.7 px/s with only 21–77 tracks; final three ≤0.023 px/s | Reposition/cut sequence, then locked |
| V2 00:30:00–00:30:08 | Four intervals ≤0.035 px/s; four 55.6–80.4 px/s with 9–61 tracks | Alternating locked and transition intervals |

**[D] Direction for our capture:** use deliberate pans with stable edges and
material response; do not infer a donor pan-speed constant from edited gameplay.
The wide2 smoothstep path is useful for self-consistency testing, not motion parity.

### 5.2 Shore/water: attempted, unresolved

A central-playfield blue-dominant scan ranked 50 candidates across both videos.
The highest fractions were only 1.40% (V1 00:37:40) and 1.96% (V2 00:28:50).
Targeted full-frame checks at V1 00:37:40, 00:39:30 and V2 00:28:50 showed
uniforms/UI/dark vegetation rather than a shore. Contact sheets and selected
terrain frames showed no certifiable land→beach→foam→water band.

- **[U] Water identity and transition remain unverified from these videos.**
- This does not prove water is absent from unsampled intervals.
- No foam width, water level, shore color or shoreline threshold is derived.
- Wide2's lack of water cannot be scored against a donor video water frame that
  was never observed.

## 6. Ranked 10-item quality target

Rank is **[D] impact order for the current wide2 baseline**, not a donor score.
Metrics are recording/support cues; visual forbidden artifacts remain decisive.

| Rank | Quality target | Concrete visual cue | Metric(s) to record — never donor thresholds | Wide2 evidence / gap |
|---:|---|---|---|---|
| 1 | Remove terrain/prop base plates | No pale square/disc rim; terrain, rock and prop footprint meet continuously; contact shadow at ground | Bright low-sat component area/bbox; axis-aligned edge-run length; boundary contrast; plate fill ratio | f0012 circular mine disc; f0023 `386×204` bright square component; plates pop through the pan |
| 2 | Replace stepped/banded relief with organic forms | Broad asymmetric mounds, eroded lips and multi-peak ridges; continuous slope shading; no terraces, diagonal veins or contour rings | Relief-ROI `grad`, `e40`, edge-orientation histogram, longest straight/contour run, silhouette rise | f0000 black stepped islands and diagonal bands; f0023 smooth but unrooted square-base mounds |
| 3 | Restore multi-scale ground material and remove the grid | Fine grass/dirt detail plus broad tonal patches; no repeating square field; texture scale stays stable in motion | Grass `BV32`, `grad`, `e40`, luminance p5/p95, 16/32/48 px autocorrelation; temporal edge coherence | Clean wide2 grass BV32 0.28–0.32, `e40=0`, 46–48 px periodicity; donor clean grass is multi-scale |
| 4 | Restore lighting, material response and contact shadows | Lit and shadowed sides; warm directional key; long tree/building shadows; dark contact under rocks/props; no black silhouette-only objects | Prop/ground luminance p5/p95 and std; near-black fraction on named prop ROIs; shadow length/direction; local contact contrast | Black trees/units/buildings; terrain reads as flat dark/light bands; no contact shadows |
| 5 | Integrate mines and stone into terrain | Minehead centred on clustered rock; subtle dirt/grass transition; no orphan mine or geometric disc | Rock-component count/cluster bbox; mine-rock overlap; base-boundary contrast; contact-shadow presence; orphan check | f0012 is a pale disc; V1 00:20:00 and V2 00:05:00 show direct rock/grass integration |
| 6 | Build natural forest stands | Irregular conifer/mixed clusters, glades, varied canopy heights, rooted trees and long shadows; no plantation grid | Canopy/ground contrast; nearest-neighbour spacing; cluster count; black fraction; edge density; shadow direction | Wide2 has sparse black tree glyphs and no glade/shadow structure |
| 7 | Make mill fields readable parcels | Closed rectangular/L-shaped golden parcel; crop-row texture; mill footprint inside/adjacent; field conforms to ground | Parcel area/perimeter/closure; field mean RGB/saturation; `BV32`; boundary `e40`; mill-field overlap | No field class in requested wide2 frames; V1 00:01:00/00:30:00 and V2 00:15:00 are strong references |
| 8 | Fix unit/building/tree scale and anchoring | Consistent within-shot ratios; readable infantry; grounded foundations; no floating or oversized placeholder geometry | Named-object bbox height/width distributions; unit:building and tree:building ratios within one pinned shot; contact shadow; silhouette black fraction | Wide2 units/props are tiny black marks while mine/mountain plates dominate |
| 9 | Prove temporal stability under camera motion | No edge swim, terrace shimmer, texture crawl, plate pop or LOD snap during a pinned pan | Frame-to-frame flow p50/p90; track survival; edge coherence; plate-component appearance/disappearance; candidate-only determinism | 24-frame contact sheet shows persistent bands and plate entry/exit; donor editing is not a speed target |
| 10 | Acquire an admissible shore/water reference, then validate transition | If in scope: continuous land→warm beach→bright offshore foam→pale water; no hard classification edge | Saturation sequence, foam peak RGB, water mean, alpha-at-waterline, connected water corridor — measurements only, no pass verdict | No water in requested wide2 frames and no certifiable donor-video water frame; status **UNVERIFIED/BLOCKED REFERENCE** |

### 6.1 Field-texture supporting values

Mixed field ROIs (field + mill/units at edges) show why a flat color/noise field is
not enough:

| ROI | mean saturation | grad | e40 | luminance std |
|---|---:|---:|---:|---:|
| V1 00:02:00 field/mill | 0.631 | 10.07 | 0.0285 | 23.80 |
| V1 00:15:00 field/mill | 0.628 | 7.28 | 0.0246 | 24.08 |
| V1 00:30:00 field/mill/army | 0.597 | 11.12 | 0.0493 | 27.46 |
| V2 00:15:00 wheat/village edge | 0.571 | 15.42 | 0.0869 | 36.10 |

These are texture/boundary descriptors, not target values. ROIs include some
structures/units and are not pure crop-only samples.

## 7. Multiple-pass ambiguity register

| Ambiguous item | Passes attempted | Result | Status |
|---|---|---|---|
| V2 “6 s Short” | Browser metadata before/after pre-roll; `ffprobe` downloaded file | Six seconds was an ad; full duration 2253.581 s | **[O] resolved** |
| Mountain evidence absent in still corpus | V1 00:05:00 full frame + 2× crop; V1 00:35:00 full frame + crop; contact sheets | Real rocky multi-peak ridge/forest depth visible | **[O] video adds mountain reference; parity still [U]** |
| Wide2 white bases | Full f0012/f0023 reads; bright-component locator; 2× tight crops; all-frame contact sheet | Circular mine disc and square mountain plates confirmed | **[O] artifact confirmed** |
| Mine/rock integration | V1 00:20:00 full/crop; V2 00:05:00, 00:10:00, 00:20:00 full/crops; COORD browser frames | Donor mine/rock/grass is continuous; no geometric plate | **[O] reference cue** |
| Water/shore | 467 regular samples; 11 contact sheets; blue-dominant ranking; targeted V1 00:37:40/00:39:30 and V2 00:28:50 | No certifiable water/shore in inspected material | **[U] not observed; do not invent** |
| Camera speed | Ten 8 s OpenCV clips; track counts checked; capture.json smoothstep path | Static intervals and cuts/repositions separated; world speed unknowable | **[I] behavior only** |
| Flat grass vs texture | Native full frames; 2× grass crops; BV32/grad/e40/autocorrelation recomputation | Wide2 clean grass is near-uniform and periodic; donor grass is multi-scale | **[O]/[D] screening cue** |

## 8. Implications for COORD

1. **[D] Hold wide2 as a failure baseline, not a near-match.** The square/circular
   plates, black bands and silhouette props are dominant, not minor polish.
2. **[D] Fix source layering before adding detail.** More noise/dither cannot
   repair a square terrain plate, a floating mine disc or stepped relief. The
   visual target is continuous terrain/material/prop integration.
3. **[D] Use the new video frames as class evidence.** V1 now supplies mountain
   and ridge evidence missing from X07/X36; V2 supplies the clearest mine/rock
   integration. This refines the reference index but does not create an A/B gate.
4. **[I] Next candidate shot list:** repeat the same 24-frame smoothstep pan after
   each correction, plus pinned close shots of (a) mine+rock+grass, (b) field+mill,
   (c) forest edge, (d) mountain/ridge silhouette, and (e) a real shore if one can
   be sourced. Keep candidate self-determinism separate from donor direction.
5. **[U] Keep shore/water and donor motion speed explicitly unresolved.** No
   numeric threshold or parity wording should be introduced from this report.

## 9. Evidence catalog — exact files and times

### 9.1 Current wide2

| ID | Time/position | File |
|---|---|---|
| W2-000 | pan t=0, target X=60 | `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\video\donor_240_wide2\frame_0000.png` |
| W2-012 | pan t=0.5, target X=240 | `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\video\donor_240_wide2\frame_0012.png` |
| W2-023 | pan t=1, target X=420 | `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\video\donor_240_wide2\frame_0023.png` |
| W2-CONTACT | all 24 frames | `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\donor_videos\wide2_contact.jpg` |
| W2-CAMERA | capture contract | `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\v42\video\donor_240_wide2\capture.json` |

### 9.2 V1 selected full-resolution frames

Root: `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\donor_videos\selected\cZW0AEupCaI\`

| ID | Video time | File |
|---:|---:|---|
| V1-060 | 00:01:00 | `t_60.png` |
| V1-120 | 00:02:00 | `t_120.png` |
| V1-300 | 00:05:00 | `t_300.png` |
| V1-600 | 00:10:00 | `t_600.png` |
| V1-900 | 00:15:00 | `t_900.png` |
| V1-1200 | 00:20:00 | `t_1200.png` |
| V1-1500 | 00:25:00 | `t_1500.png` |
| V1-1800 | 00:30:00 | `t_1800.png` |
| V1-2100 | 00:35:00 | `t_2100.png` |
| V1-2260 | 00:37:40 | `t_2260.png` — water candidate, negative |
| V1-2370 | 00:39:30 | `t_2370.png` — water candidate, negative |

### 9.3 V2 selected full-resolution frames

Root: `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\donor_videos\selected\ljlCn4KSSU4\`

| ID | Video time | File |
|---:|---:|---|
| V2-060 | 00:01:00 | `t_60.png` |
| V2-300 | 00:05:00 | `t_300.png` |
| V2-600 | 00:10:00 | `t_600.png` |
| V2-900 | 00:15:00 | `t_900.png` |
| V2-1200 | 00:20:00 | `t_1200.png` |
| V2-1500 | 00:25:00 | `t_1500.png` |
| V2-1730 | 00:28:50 | `t_1730.png` — water candidate, negative |
| V2-1800 | 00:30:00 | `t_1800.png` |
| V2-2100 | 00:35:00 | `t_2100.png` |

### 9.4 Contact sheets and crops

```text
C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\donor_videos\cZW0AEupCaI_contact_01.jpg ... _06.jpg
C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\donor_videos\ljlCn4KSSU4_contact_01.jpg ... _05.jpg
C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\donor_videos\analysis_crops\
C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\donor_videos\metrics.json
```

V1 contact sheet 1 covers frames 1–48 (0–470 s), sheet 2 covers 49–96
(480–950 s), sheet 3 covers 97–144 (960–1430 s), sheet 4 covers 145–192
(1440–1910 s), sheet 5 covers 193–240 (1920–2390 s), and sheet 6 contains
241–242 (2400–2410 s). V2 sheets follow the same row-major mapping through
frame 225 (2240 s).

Representative 2× crops used for the ambiguous reads:

```text
wide2_f0000_relief.png
wide2_f0000_grass.png
wide2_f0012_disc.png
wide2_f0012_relief.png
wide2_f0023_top_base.png
wide2_f0023_bottom_base.png
wide2_f0023_grass.png
v1_t060_field_mill.png
v1_t060_rock_forest.png
v1_t300_mountains.png
v1_t1200_mine_forest.png
v1_t1200_forest.png
v1_t1500_stone_city.png
v1_t1800_field_mine.png
v1_t2100_mountain_forest.png
v2_t300_stone_mine.png
v2_t600_forest_town.png
v2_t1200_stone_barracks.png
v2_t1800_army_grass.png
v2_t2100_ravine_forest.png
```

## 10. Browser screenshot catalog

All are video-element screenshots at 1280×720. DONOR-VIDEO captures sought
60/900/1500/2100 s, played for about 1.4 s, then paused; V2 metadata recorded
61.417/901.479/1501.422/2101.393 s. COORD captures are at the listed seek times.
The exact ffmpeg frames in §9 are the timestamp-precise evidence.

### 10.1 DONOR-VIDEO browser captures

| ID | Sought time | Exact path |
|---|---:|---|
| V1-060-B | 00:01:00 | `C:\Users\Maxym.Oboyshev\.cache\opencode\browser-exports\8c5d8de088ddfca31daf1642c82e8fd0cfcbac2628af62663606b9491f5d8f8a\1e45bcb7-5f42-4fe7-996a-363e38b108b6\0\screenshot.png` |
| V1-900-B | 00:15:00 | `C:\Users\Maxym.Oboyshev\.cache\opencode\browser-exports\8c5d8de088ddfca31daf1642c82e8fd0cfcbac2628af62663606b9491f5d8f8a\31d8b924-1646-4187-8dfa-90a3f71cd3ba\0\screenshot.png` |
| V1-1500-B | 00:25:00 | `C:\Users\Maxym.Oboyshev\.cache\opencode\browser-exports\8c5d8de088ddfca31daf1642c82e8fd0cfcbac2628af62663606b9491f5d8f8a\1d1891d5-acec-4316-bebc-cfedb4bc1da7\0\screenshot.png` |
| V1-2100-B | 00:35:00 | `C:\Users\Maxym.Oboyshev\.cache\opencode\browser-exports\8c5d8de088ddfca31daf1642c82e8fd0cfcbac2628af62663606b9491f5d8f8a\dd0e5ee8-0586-4e8f-8cdb-7a89d3260d59\0\screenshot.png` |
| V2-060-B | 00:01:00 (actual 61.417) | `C:\Users\Maxym.Oboyshev\.cache\opencode\browser-exports\8c5d8de088ddfca31daf1642c82e8fd0cfcbac2628af62663606b9491f5d8f8a\bf044630-c871-47f6-b498-932d4aedfb3d\0\screenshot.png` |
| V2-900-B | 00:15:00 (actual 901.479) | `C:\Users\Maxym.Oboyshev\.cache\opencode\browser-exports\8c5d8de088ddfca31daf1642c82e8fd0cfcbac2628af62663606b9491f5d8f8a\abced583-dd6b-4eaa-83d9-12f7833f34b7\0\screenshot.png` |
| V2-1500-B | 00:25:00 (actual 1501.422) | `C:\Users\Maxym.Oboyshev\.cache\opencode\browser-exports\8c5d8de088ddfca31daf1642c82e8fd0cfcbac2628af62663606b9491f5d8f8a\e9dbdffd-ddbf-4cb5-b094-450e0972e456\0\screenshot.png` |
| V2-2100-B | 00:35:00 (actual 2101.393) | `C:\Users\Maxym.Oboyshev\.cache\opencode\browser-exports\8c5d8de088ddfca31daf1642c82e8fd0cfcbac2628af62663606b9491f5d8f8a\0ae19d0f-55f7-43b2-a622-42eb225f0b41\0\screenshot.png` |

### 10.2 COORD browser captures supplied in handoff

| ID | Time | Exact path |
|---|---:|---|
| V2-300-C | 00:05:00 | `C:\Users\Maxym.Oboyshev\.cache\opencode\browser-exports\7b3985b074cee559c2525440bfbd7698c595e810065d7dbbc4ca7f55c2fe2fd1\74829d0f-3272-419f-a4f4-09b0c8fedb75\0\screenshot.jpeg` |
| V2-600-C | 00:10:00 | `C:\Users\Maxym.Oboyshev\.cache\opencode\browser-exports\7b3985b074cee559c2525440bfbd7698c595e810065d7dbbc4ca7f55c2fe2fd1\14f83342-c5ac-4e47-ae21-57f13a542fad\0\screenshot.jpeg` |
| V2-1200-C | 00:20:00 | `C:\Users\Maxym.Oboyshev\.cache\opencode\browser-exports\7b3985b074cee559c2525440bfbd7698c595e810065d7dbbc4ca7f55c2fe2fd1\2dd82cb9-a6e7-491e-b683-ea4bfc640228\0\screenshot.jpeg` |
| V2-1800-C | 00:30:00 | `C:\Users\Maxym.Oboyshev\.cache\opencode\browser-exports\7b3985b074cee559c2525440bfbd7698c595e810065d7dbbc4ca7f55c2fe2fd1\a136929a-96c8-440a-9daa-791317c683e3\0\screenshot.jpeg` |

## 11. UNVERIFIED register and open questions

| ID | Item | Why unresolved | What would settle it |
|---|---|---|---|
| DV-U1 | Donor parity of wide2 or any candidate | Third-party video; unknown build/map/camera/zoom/compression; no same-camera A/B | Owner-controlled donor/port same-camera capture; parity still not assumed |
| DV-U2 | Shore/water transition | No certifiable water frame in sampled videos/contact sheets/targeted candidates | A higher-resolution, admissible shoreline gameplay frame |
| DV-U3 | Donor camera world speed | Edited interactive gameplay; cuts and perspective changes; flow diagnostic only | Continuous pinned camera move with known world scale |
| DV-U4 | Exact mountain asset/source behavior | Visual ridge is clear, but runtime chooser/placement is not proven by video | Donor structural/runtime evidence plus same-camera frame |
| DV-U5 | Exact unit/building pixel scale | Varies with camera/zoom/perspective | Within-shot ratios at a pinned candidate camera |
| DV-U6 | Unsampled video intervals | Ten-second sampling plus targeted frames is broad but not exhaustive | Additional targeted extraction around water/rare terrain events |

## 12. Claim register and scope statement

| # | Claim | Label |
|---:|---|---|
| 1 | Both requested videos yielded actual 720p frame sequences | [O] |
| 2 | V1 contains clear mountain/ridge evidence absent from the 12-still corpus | [O] |
| 3 | V2 contains clear mine/rock/continuous-grass integration without white bases | [O] |
| 4 | Wide2 has stepped/banded relief, near-uniform periodic grass, black silhouettes and square/disc bases | [O] |
| 5 | Clean wide2 grass BV32 is 0.28–0.32 with 46–48 px periodicity; donor clean-grass samples are multi-scale | [O]/[D] |
| 6 | Donor videos alternate locked observation and repositioning; no world-speed constant is derivable | [O]/[I] |
| 7 | No certifiable shore/water transition was observed in the sampled material | [U] |
| 8 | No donor parity, numeric donor threshold or A/B proof is claimed | [U] |

**Scope statement:** exactly one repo file was written — this report. All video
files, extracted frames, contact sheets, crops and metric JSON are outside the
repo under `%TEMP%\opencode\donor_videos\`; browser captures are under the
OpenCode browser-export cache. No donor material was copied into the repo or
redistributed. No source, asset, config, test, shader, fixture, git or runner
state was changed; no Godot job was submitted; no donor binary was executed.

*End of DONOR-VIDEO analysis.*
