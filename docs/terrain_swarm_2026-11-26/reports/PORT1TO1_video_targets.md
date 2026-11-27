---
id: PORT1TO1-VIDEO-TARGETS
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATON
role: WORKER PORT1TO1-VIDEO — donor video visual defect taxonomy (cZW0AEupCaI)
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_video_targets.md
status: DELIVERED__READ_ONLY_VISUAL_ANALYSIS__ONE_REPORT_ONLY
created: 2026-11-26
labels: [OBSERVED, DERIVED, UNVERIFIED, "PORT APPROXIMATION"]
parity_guard: "No donor parity is claimed. No A/B pass is certified. Donor frames are third-party references of unknown build/map/camera/zoom/compression. All donor-like targets below are directions of appearance, not thresholds."
scope_guard: "Exactly one repo file written (this report). No source/asset/config/shader/fixture/test/runner/git state touched. Donor frames viewed read-only."
---

# PORT1TO1-VIDEO targets — `cZW0AEupCaI` donor vs port snapshots

> READ-ONLY visual/web analysis. No code, asset, config, Godot or git edit was made to produce this report except writing this file.
> No parity claim is made. No approximation is proposed: each section states the donor-like result that must be achieved.

## 0. Sources

### 0.1 Donor target

- URL: `https://www.youtube.com/watch?v=cZW0AEupCaI`
- Web identity [O]: `Cossacks 3 - GAMEPLAY [PC/HD]`, published 2016-09-20, duration 40:21.901 (2421.901 s), 1280x720 H.264 frames used.
- Local evidence root (read-only): `%TEMP%\opencode\donor_videos\selected\cZW0AEupCaI\`
- Frames inspected in this worker [O]:

| File | Video time | Scene class |
|---|---|---|
| `t_0.png` | 00:00 | town/forest edge, opening meadow |
| `t_60.png` | 00:01:00 | field + mill town (prior reports: V1-060) |
| `t_120.png` | 00:02:00 | mature wheat square around windmill (V1-120) |
| `t_300.png` | 00:05:00 | rocky multi-peak ridge + forest fringe (V1-300) |
| `t_600.png` | 00:10:00 | dense mixed conifer belt, red building, mine works (V1-600) |
| `t_900.png` | 00:15:00 | large golden field, windmill, troop lines, stone blocks (V1-900) |
| `t_1200.png` | 00:20:00 | wooden minehead on clustered rock + forest + church (V1-1200) |
| `t_1500.png` | 00:25:00 | stone city, market/stable blocks (V1-1500) |
| `t_1800.png` | 00:30:00 | wheat wrapping mill, army, wall, two mines (V1-1800) |
| `t_2100.png` | 00:35:00 | ridge behind forested middle ground, cavalry mass (V1-2100) |
| `t_2260.png` | 00:37:40 | water-candidate, negative (town/woods) |
| `t_2370.png` | 00:39:30 | water-candidate, negative (battle/woods) |
| `t_60/t_1200/t_1500/t_2100` re-reads | as above | cross-checked against `DONOR_VIDEO_analysis.md` §4.1 shot table |

- Prior donor reads reused (not recomputed): `DONOR_VIDEO_analysis.md` §§3–6, `VIDEO_DENSITY_cZW0.md` §3, `VIDEO_MINE_FIELD.md` §§2–4.
- Second reference (context only): `ljlCn4KSSU4` (Raptor, 37:33) per `DONOR_VIDEO_analysis.md` §4.2 — mine/rock integration grammar only; no new timestamp is set from it here.

### 0.2 Port snapshots compared (read-only)

| ID | File | What it shows [O] |
|---|---|---|
| P-WIDE | `inbox/qa/captures/contact_wide-final.png` frames 0000/0004/0008/0012/0016/0020/0023 | flat olive ground, black stepped relief bands, black stick props, pale plate in frame 0016/0020 |
| P-CMP | `inbox/qa/captures/donor_compare_contact.png` top row donor crops vs bottom row `wide2 frame_0000/0023` | donor textured grass/field/city vs candidate flat checkerboard + white square mountain bases |
| P-COL | `inbox/qa/captures/cap_donor_240_colorfield.png` | church + huts + mill, sparse black trees, flat olive grass, right-edge green checkerboard field dots |
| P-NAT | `inbox/qa/captures/cap_nationmove.png` | same church scene, three mines with pale/yellow halos, sparse black trees |
| P-DEF | `inbox/qa/captures/cap_defaultcfg_donor.png` | same scene with desaturated/grey halos, same flat grass |
| P-MILL | `inbox/qa/captures/cap_millsow.png` (= same view as P-NAT re-captured) | confirms halo + sparse-tree + flat-grass read |
| P-WATER-TOP | `inbox/qa/captures/map_overview_waterfix.png` | top-down: 4 pale grey/white blobs with dark rims on flat olive (waterfix candidate) |
| P-SHORE | `inbox/qa/captures/contact_shorealpha2.png` frames 0000–0023 | tan/beige block with stepped green fringe (shore-alpha candidate), isolated pines |
| P-V42-WIDE | `variant3d/tests/results/` (`t_terrain_donor.json`, `t_terrain_shore.json`, `t_terrain_trees.json`, `t_terrain_mines.json`, `t_water.json`, `t_shore_smoke.json`, `t_forest_dense.json`, `t_forest_bake_render.png`) | test-result side of the same baseline (counts/status only; no pixel re-gating here) |

### 0.3 Labels

- **[O]** seen in a named frame/ROI. **[D]** arithmetic/ranking over cited numbers. **[U]** unresolved after inspection.
- **PORT APPROXIMATION** applies to every donor-vs-port sentence.

---

## 1. Defect taxonomy

### D1 — Terrain texture scale / mottling (ground reads as flat olive checkerboard)

**Donor evidence [O]:**

- `t_0.png` full frame: open meadow is mottled olive-green with broad tonal patches and fine grain; no repeating square grid. Same in `t_600.png` glades and `t_1800.png` army ground.
- `t_300.png` (`t_300`, 00:05:00, ROI right-half ridge apron `[640,360,1280,720)`): grass in front of ridge is continuous mottled pasture with dirt tracks and rock-fringe transitions.
- `t_1200.png` (00:20:00, ROI centre `[400,350,900,600)`): grass between rock cluster, trees and troop line shows sunlit/mid-tone variation plus small dirt smudges.
- Prior measurement reused [O]: donor clean-grass BV32 multi-scale, grad 4.6–12.0, e40 0.0099–0.0581, sat ~0.50–0.63, 48-px autocorrelation weak (0.007–0.135) — `DONOR_VIDEO_analysis.md` §3.3, `VIDEO_DENSITY_cZW0.md` §3.1.

**Port defect [O]:**

- P-WIDE all frames: near-uniform olive field with visible square checkerboard; P-CMP bottom row makes the periodicity explicit against donor top row.
- P-COL / P-NAT / P-DEF / P-MILL: same flat olive sheet across the whole playfield; scattered dark speckles are isolated pixels, not broad tonal patches.
- Prior measurement reused [O]: candidate clean-grass BV32 0.28–0.32, e40 0–0.0036, sat 0.65–0.69, 46–48 px autocorrelation peak ~0.54–0.55 (`DONOR_VIDEO_analysis.md` §3.3).

**Donor-like result that must be achieved (no approximation proposed):**

- Open grass must read as mottled multi-scale pasture — fine grain plus broad tonal patches — with no visible repeating square grid at any zoom in P-WIDE/P-COL class captures, matching the `t_0 / t_600 / t_1200 / t_1800` ground language.
- No numeric threshold is set here; the cited BV32/e40/sat/autocorrelation numbers are re-measure directions only.

**Port file likely owning it:**

- `variant3d/scripts/world3d_terrain.gd` (terrain material/UV/scale orchestration) + `variant3d/shaders/terrain_donor_shader.gdshader` (ground fragment mixing) + `variant3d/scripts/tile_atlas_loader.gd` + `variant3d/scripts/terrain_donor_mesh.gd` (tile geometry/UV feeding the shader). Data side: `variant3d/scripts/terrain_donor_data.gd` / `terrain_donor_gen.gd`.

### D2 — Water identity (no certifiable donor water in this video; port water reads as pale land blobs)

**Donor evidence [O/U]:**

- No certifiable water/shore frame was found in sampled `cZW0AEupCaI` material: `t_2260.png` (00:37:40) and `t_2370.png` (00:39:30) — the ranked blue-dominant candidates — show uniforms/UI/dark vegetation on inspection, not water (`DONOR_VIDEO_analysis.md` §5.2). All 12 frames above are land/forest/field/city scenes.
- Consequence [U]: this video cannot supply a water-colour, foam-width, or water-level target. Any water target must come from an admissible shoreline frame outside this video; none is invented here.

**Port defect [O]:**

- P-WATER-TOP: four pale grey/white rounded blobs with dark pixel rims on flat olive; they read as land paint blobs, not water planes (no reflective/blue-green body, no shoreline gradient, island holes with grass centres).
- P-WIDE contains no water body in any frame; `t_water.json` / `t_shore_smoke.json` result side does not change the pixel read.

**Donor-like result that must be achieved:**

- Until an admissible donor shoreline frame is sourced, port must not claim water parity from this video. When a real reference exists, the required result is a continuous water body with a readable land→shore→water transition — never an isolated pale blob with a hard dark rim on flat grass.
- Status for this video stays **UNVERIFIED / BLOCKED REFERENCE** for water colour and level.

**Port file likely owning it:**

- `variant3d/scripts/water3d.gd` + `variant3d/shaders/water3d.gdshader` + `variant3d/shaders/water_overlay.gdshader` (water body + shoreline overlay) fed by `variant3d/scripts/world3d_terrain.gd` water mask path.

### D3 — Shore transition (stepped tan blocks, no beach/foam band)

**Donor evidence [O/U]:**

- Same as D2: no certifiable land→beach→foam→water band exists in `t_0…t_2370`. The closest land-margin grammar visible is rock-apron→grass feathering in `t_300.png` (ridge foot, ROI `[640,500,1100,700)`) and dirt/grass feathering around rock clusters in `t_600.png` (ROI centre `[200,280,480,450)`): ragged, multi-tone, no axis-aligned steps.

**Port defect [O]:**

- P-SHORE all frames: large tan/beige block with hard stepped/staircase green fringe and diagonal hatch bands at the boundary; isolated black pines on top. The edge is geometric (block steps), not a feathered shore.
- P-WATER-TOP blob rims: single-pixel dark outline with no intermediate wet-sand/foam band.

**Donor-like result that must be achieved:**

- Any shore margin must be a ragged continuous transition (rock/dirt/sand tongues into grass, irregular edge, contact darkening), of the `t_300 / t_600` apron kind — with no axis-aligned steps, no diagonal hatch bands, and no hard single-pixel outline.
- Foam/wet-band geometry and colours remain **[U]** until a real shoreline reference is admitted; nothing is interpolated from this video.

**Port file likely owning it:**

- `variant3d/scripts/world3d_terrain.gd` (shore-band classification) + `variant3d/shaders/terrain_donor_shader.gdshader` + `variant3d/shaders/water_overlay.gdshader` (shore alpha/band rendering) + `variant3d/scripts/terrain_donor_gen.gd` (mask generation).

### D4 — Forests / density (sparse black glyphs vs dense mixed canopy with glades)

**Donor evidence [O]:**

- `t_600.png` (00:10:00): dense mixed conifer belt fills left/top; irregular edge, glades with grass between clusters, individual lit/shadowed canopies, long soft shadows; even at highest canopy cover the ground shows through.
- `t_0.png` left edge + `t_1200.png` bottom band: clustered pines/birches of varied height with undergrowth clumps and dirt gaps; trees root in grass with dark contact at base.
- `t_2100.png` (00:35:00, ROI top half `[0,0,1280,360)`): ridge + forested middle ground + open cavalry grass in one frame — density coexists with readable open ground.
- Prior count reused [O]: donor dark-canopy 27–44% in 110–397 blobs, 17–109 mid-size clusters, NN spacing ~11–16 cells, ground-between 26–40% (`VIDEO_DENSITY_cZW0.md` §3.1).

**Port defect [O]:**

- P-NAT / P-MILL / P-COL: ~15–25 isolated thin black/brown vertical glyphs (canopy + trunk silhouette) scattered on flat grass; no canopy volume, no glade structure, no undergrowth ring.
- P-WIDE: same sparse black sticks; P-SHORE: 3–6 isolated pines on tan block.
- Prior count reused [O]: candidate 1–47 blobs, ≤6 mid-size clusters, ground-between 1.6–5.1% under identical masks (`VIDEO_DENSITY_cZW0.md` §3.2).

**Donor-like result that must be achieved:**

- Forest must read as irregular mixed-height canopy clusters with grassy glades and dirt gaps between them, rooted in continuous ground with contact darkening — the `t_600 / t_0 / t_2100` ecology — never as isolated black glyphs on a bare sheet.
- Counts above are re-measure directions, not planting quotas.

**Port file likely owning it:**

- `variant3d/scripts/terrain_donor_props.gd` (prop placement/instancing) + `variant3d/scripts/world3d_entities.gd` (entity/prop scene binding) + `variant3d/scripts/mapgen.gd` / `pattern_gen.gd` (stand/vegetation distribution) + terrain shader ground-response path (`world3d_terrain.gd`).

### D5 — Mine scale / colour (pale halo discs vs small rock-integrated pits)

**Donor evidence [O]:**

- `t_1200.png` (00:20:00, ROI top-right `[900,140,1080,290)`): wooden minehead hut centred on an irregular grey rock apron ~3–4x hut width (~1/3 of red church width); trees and grass intrude into the apron; dirt/grass transition ragged; no disc, no halo, dark contact under stones.
- `t_300.png` (00:05:00, ROI centre-left `[180,300,420,470)`): open rock scatter/pit with grass tongues and saplings inside the perimeter — boundary is rock-by-rock.
- `t_1800.png` (00:30:00, ROIs top-centre `[620,40,730,130)` and right `[1060,220,1170,330)`): two rock-pile + timber mines, each ~1/4–1/5 town-hall width, rooted in the same continuous grass as field margin and army ground.
- Scale grammar reused [O]: mine footprint is a fraction of town-hall/mill width, few infantry-heights tall (`VIDEO_MINE_FIELD.md` §2).

**Port defect [O]:**

- P-NAT / P-MILL: three deposits each with an explicit pale/yellow translucent halo ellipse around a small rock core (e.g. bottom-left halo ~`[230,560,420,650)`, top-left ~`[280,140,400,210)`, right ~`[1050,440,1190,530)` on 1280x720 captures); grass inside halo is bleached vs global grass.
- P-DEF: same halos in desaturated grey — geometry unchanged, confirming the halo is structural, not a colour accident.
- P-COL top-right: same halo class at `[980,90,1090,150)`.
- Prior ROI numbers reused [O]: mine-disc vs global grass delta ~+12R/+11G/+16B; halo vs global ~+4R/+4G/+5B (`VIDEO_MINE_FIELD.md` §3).

**Donor-like result that must be achieved:**

- Each mine must be a building-subordinate rock/dirt/pit feature with grass meeting the outer rock lip directly, ragged rock-by-rock boundary, thin darker dirt smudge only, and dark contact under stones — the `t_1200 / t_300 / t_1800` grammar — with no pale circular/elliptical halo, no geometric plate, and no bleached annulus.
- The existing rock-core size ballpark is not the defect; the halo/plate geometry and the seam are.

**Port file likely owning it:**

- `variant3d/scripts/terrain_donor_props.gd` (deposit halo/disc quad + rock-ring placement) + `variant3d/scripts/world3d_entities.gd` (minehead scene) + `variant3d/scripts/winter_field_decal.gd` if halo shares the decal path + lighting path in `world3d_terrain.gd` vs prop rig (seam ownership per `PHOTO_LED_mine_colour_seam.md` §2 interpretation reused).

### D6 — Fields (missing golden closed parcels; green checkerboard dots instead)

**Donor evidence [O]:**

- `t_120.png` (00:02:00, ROI right `[920,140,1280,390)`): closed diamond/square golden wheat parcel ~1x town-hall width, crop-row texture edge-to-edge, windmill inside a square dirt clearing at parcel centre-right, sharp gold-vs-grass boundary, peasants dotting the gold.
- `t_900.png` (00:15:00) and `t_1800.png` (00:30:00, ROI `[380,280,910,560)`): same grammar at larger extent — mill centred, dirt square under mill, gold continuous around all four sides, army column marching past the parcel edge on shared ground.
- `t_600.png` and `t_1200.png` as negative controls [O]: no gold where no parcel is placed — fields are discrete placed parcels, not a global tint.
- Texture cues reused [O]: mixed field/mill ROIs sat ~0.60–0.63, grad ~7–11 (`DONOR_VIDEO_analysis.md` §6.1).

**Port defect [O]:**

- P-COL right edge (ROI `[1080,230,1280,400)`): ~5x5 grid of isolated flat-green squares (checkerboard dots), no gold mass, no closed parcel, no mill clearing — mill stands apart at `[1010,180,1130,340)` with no field around it.
- P-NAT / P-MILL / P-DEF: no field parcel at all in the mill/hut neighbourhood.
- Prior capture state reused [O]: 240n-line parcels read dark-neutral (~`[51,48,41]`, gold fraction ~0.078) or absent depending on config (`VIDEO_MINE_FIELD.md` §§4–5).

**Donor-like result that must be achieved:**

- Each mill-field must be one closed golden parcel with continuous crop-row texture to a sharp boundary and a single dirt square clearing under the mill — the `t_120 / t_1800` grammar — never scattered green checkerboard dots and never a dark-neutral mass where gold belongs.

**Port file likely owning it:**

- `variant3d/scripts/winter_field_decal.gd` (field decal/parcel layer) + `variant3d/scripts/terrain_donor_props.gd` (mill + parcel footprint) + `variant3d/scripts/terrain_donor_data.gd` (field art binding `field.png` / `envfieldd/w.png`) + config path `variant3d/config_donor_capture.json` / `map_donor_240.json` fixture selecting the mature field (Branch A/B per `AUDIT_FIELD_STAGE_TIMING.md` reused).

### D7 — Buildings (readable shaded architecture in donor; dark flat blocks in port)

**Donor evidence [O]:**

- `t_900.png` (00:15:00) / `t_1500.png` (00:25:00) / `t_1800.png` (00:30:00): stone town halls, gothic blocks, Big-Ben-like towers, market/stable/barracks façades — lit and shadowed faces, stone/timber material separation, paved foundations/pl-Brinths anchoring each block, formal scale hierarchy (peasant < infantry file < mine < hall < tower).
- `t_1200.png` red church ROI `[400,230,500,330)`: saturated red lit face vs shaded side, crisp silhouette against grass/forest.
- `t_2100.png` battle frames: burning-building smoke/fire contrasts against shaded terrain (material contrast preserved in combat).

**Port defect [O]:**

- P-COL / P-NAT church + huts: dark brown flat masses; roof/wall faces crush toward silhouette; foundation/paving ring is thin or absent; red trim line is the only saturated cue.
- Scale inversion [D]: mine halos and pale plates dominate the frame while architecture and units stay small/dark — opposite of the donor hierarchy where halls/towers dominate and mines stay subordinate.

**Donor-like result that must be achieved:**

- Buildings must show lit/shadowed face separation, legible stone/timber material, and a foundation/paving contact anchoring each block to continuous ground, holding the donor scale hierarchy (units < mine apron < hall < tower) in one framing of the `t_900 / t_1500 / t_1800` kind.

**Port file likely owning it:**

- `variant3d/scripts/world3d_entities.gd` (building scenes/material binding) + prop lighting rig vs terrain light path in `variant3d/scripts/world3d_terrain.gd` + `variant3d/scripts/world3d_relief.gd` (foundation/height seating).

### D8 — Lighting / shadows (warm directional sun + contact darkening vs flat/black-crush look)

**Donor evidence [O]:**

- `t_600.png` forest edge, `t_1200.png` mine/rock ROI, `t_1800.png` field/army ROI: long soft tree/building/unit shadows fall consistently across grass and rock alike (one lighting space); dark contact occlusion sits under every rock, hut, tree base and troop file.
- `t_300.png` ridge ROI: shaded rock faces vs lit faces; forest fringe carries aerial-depth softening.
- `t_2100.png` cavalry mass on open grass: unit shadows + ground-depth gradient give the mass weight; shaded sides never collapse to pure black.

**Port defect [O]:**

- P-WIDE: terrain reads as flat dark/light bands; props read as near-black silhouettes with no lit/shadow split and no cast shadow.
- P-NAT / P-COL: no cast shadows under church/huts/mill/trees/troop files; mine halos glow instead of occluding; steep/rock faces (P-WIDE bands, P-WATER-TOP rims) crush to near-black.
- Two-lighting-spaces symptom reused [O]: props on raised rig vs terrain on unscaled colours (`VIDEO_MINE_FIELD.md` §5; `PHOTO_LED_mine_colour_seam.md` §2 interpretation).

**Donor-like result that must be achieved:**

- One consistent warm directional sun: lit/shadowed face split on rocks, trees, huts and halls; long soft cast shadows on grass; dark contact ring at every prop base; no pure-black silhouette props and no flat banded terrain — the `t_600 / t_1200 / t_1800` light language.
- No lux/exposure constant is set here; the fix is a labelled port calibration with same-camera before/after ROIs, not a donor-RGB copy.

**Port file likely owning it:**

- `variant3d/scripts/world3d_terrain.gd` + `variant3d/shaders/terrain_donor_shader.gdshader` (terrain light path) vs entity/prop light path in `variant3d/scripts/world3d_entities.gd`; ambient/sun rig ownership per scene `variant3d/scenes/main.tscn` + `variant3d/scripts/camera3d.gd` exposure side; fog/depth path `variant3d/scripts/world3d_fog.gd`.

### D9 — Camera (locked high three-quarter RTS view vs top-down / low-FOV inspection views)

**Donor evidence [O]:**

- All 12 frames: high three-quarter oblique RTS view — buildings show façades + roofs simultaneously, trees show canopy + trunk + ground shadow ellipse, troop files show depth rows converging; horizon never in frame, ground plane fills viewport.
- Behaviour across the video [O, per `DONOR_VIDEO_analysis.md` §5.1 flow diagnostic]: long locked economy/building observation intervals alternating with intermittent repositioning/cuts (e.g. locked at 00:01:00–00:01:08, move at 00:25:00; reposition-then-lock at 00:05:00). No continuous pan-speed constant is derivable from edited gameplay.

**Port defect [O]:**

- P-WIDE: steep top-down look (height 58 m / pitch −32° / FOV 17.27° smoothstep pan per `capture.json` reused) — façades collapse, props read as map glyphs, plates/bands dominate.
- P-COL / P-NAT: oblique but too distant/flat lighting with no depth haze; P-WATER-TOP: pure top-down blob chart; P-SHORE: flat orthographic-like blocks.
- `donor_compare_contact.png` bottom-row framing proves the mismatch directly: same-class content shot from a steeper, narrower view than any donor frame.

**Donor-like result that must be achieved:**

- QA captures must use a locked high three-quarter oblique framing of the `t_600 / t_900 / t_1200 / t_1800` kind — façades + roofs + ground shadows visible, ground filling the viewport — with pinned before/after re-shoots per defect (mine+rock+grass; field+mill; forest edge; ridge silhouette when available; real shore when admitted). No donor pan-speed, height, FOV or zoom constant is adopted from this edited video.

**Port file likely owning it:**

- `variant3d/scripts/camera3d.gd` + `variant3d/scripts/camera.gd` (QA/pinned camera rig) + capture fixtures driving them (`variant3d/tests/t_capture.gd`, `t_terrain_*`, `t_motion_capture.gd`, `t_smallmap_terrain.gd`) — framing only, no gameplay change.

---

## 2. Ranked visual-target order (impact order, not a gate)

| Rank | Target | Why this order [D] |
|---:|---|---|
| 1 | D1 ground mottling + D5 mine halo/plate removal | Flat checkerboard and pale halos dominate every port frame; nothing else can read correctly on top of them |
| 2 | D4 forest density/canopy + D8 contact/cast shadow | Silhouette trees + shadowless ground is the second-dominant break vs `t_600 / t_1200` |
| 3 | D6 golden closed parcels | Mill without field is architecturally complete but agriculturally empty vs `t_120 / t_1800` |
| 4 | D7 building face/foundation anchoring | Depends on D8 light unity; evaluated after ground+shadow settle |
| 5 | D3 shore / D2 water | **Blocked:** no donor water/shore frame in this video; do not score water against `t_2260 / t_2370` negatives |
| 6 | D9 camera re-framing for all re-shoots | Locks the comparison geometry so ranks 1–4 can be judged in the donor-like oblique view |

---

## 3. Exact re-measure ROIs (locators, 1280x720, origin top-left)

All boxes are estimated by direct view for same-camera re-shoots. No threshold is attached.

| Defect | Donor ROI (donor file) | Port ROI (port file) |
|---|---|---|
| D1 grass | `t_0.png [400,350,900,650)` meadow; `t_1200.png [400,350,900,600)` inter-rock grass | P-WIDE frame 0020 equivalent playfield centre; P-COL `[100,450,600,700)` |
| D2 water | none admissible in this video (`t_2260 / t_2370` negatives recorded) | P-WATER-TOP each blob bbox + rim band |
| D3 shore | `t_300.png [640,500,1100,700)` ridge-foot feathering (land-margin grammar only) | P-SHORE block boundary + step fringe; P-WATER-TOP blob rims |
| D4 forest | `t_600.png [0,60,640,360)` belt + glades; `t_2100.png [0,0,1280,360)` middle ground | P-NAT right belt `[950,80,1280,500)`; P-COL same |
| D5 mine | `t_1200.png [900,140,1080,290)` hut+apron; `t_1800.png [1060,220,1170,330)` rock pile | P-NAT halos `[230,560,420,650)`, `[280,140,400,210)`, `[1050,440,1190,530)`; P-DEF same |
| D6 field | `t_120.png [920,140,1280,390)` parcel; `t_1800.png [380,280,910,560)` parcel | P-COL checkerboard `[1080,230,1280,400)`; mill clearing `[1010,180,1130,340)` |
| D7 buildings | `t_1500.png` market/stable rows; `t_1200.png [400,230,500,330)` church | P-COL church `[540,130,750,380)` + huts |
| D8 light/shadow | `t_600.png` tree shadows; `t_1800.png` unit shadows on grass | prop bases + halo bands in P-NAT/P-COL; band faces in P-WIDE f0000 |
| D9 camera | all 12 donor frames (oblique grammar) | P-WIDE capture.json pose vs donor oblique |

---

## 4. UNVERIFIED register

| ID | Item | Why unresolved | What would settle it |
|---|---|---|---|
| PT-V1 | Donor parity of any pixel | Third-party H.264, unknown build/map/camera/zoom/compression; no same-camera A/B | Owner-controlled donor/port same-camera capture; still no parity assumption |
| PT-V2 | Water colour / level / foam width | No certifiable water in `t_0…t_2370`; `t_2260/t_2370` negatives | Admissible shoreline gameplay frame outside this video |
| PT-V3 | Shore sand/foam band geometry | Same gap as PT-V2 | Same shoreline frame |
| PT-V4 | Exact world-scale tree spacing / stems-per-hectare | Image-plane spacing only; world-area-per-pixel unknown | Pinned port camera with known world scale |
| PT-V5 | Exact mine/rock placement-transform semantics | Visual grammar clear (`t_1200/t_300/t_1800`), runtime decode not proven by video | Donor-grounded placement decode + port diagnostic |
| PT-V6 | Native sceneColor / exposure runtime values | Video exposure/compression prevent calibration | Donor runtime/structural decode; port fix stays labelled calibration |
| PT-V7 | Field decal final under donor blend + mips | `GL_DST_ALPHA` + missing mip chains per prior audits | Asset-import owner fix + pinned mill-camera A/B |
| PT-V8 | Unsampled video intervals | 12 timestamps + prior 10 s sweep cover classes, not every second | Targeted extraction only if a new class is claimed |

---

## 5. Claim register

| # | Claim | Label |
|---:|---|---|
| 1 | Donor video is `Cossacks 3 - GAMEPLAY [PC/HD]` (2016-09-20, 40:21.901); 12 named frames inspected at the listed timestamps | [O] |
| 2 | Donor ground is mottled multi-scale pasture with no grid; mines are small rock-integrated pits with no halo; fields are closed golden parcels with mill-centred dirt clearing; forests are dense mixed canopy with glades; buildings carry lit/shadowed faces with foundations; light is one warm directional space with long soft shadows; camera is a locked high three-quarter RTS view | [O] per-frame as cited |
| 3 | No certifiable water/shore transition exists in the inspected `cZW0AEupCaI` material (`t_2260/t_2370` are negatives) | [O]/[U] |
| 4 | Port snapshots show flat olive checkerboard, stepped relief bands, sparse black tree glyphs, pale mine halos/plates, green-dot field absence, shadowless dark architecture, block-stepped shore/water blobs, and steeper/flatter camera geometry | [O] |
| 5 | Per-defect port file owners are named in §§D1–D9 | [D] inference from repo layout, runtime proof [U] |
| 6 | No donor parity, similarity score, donor threshold, or gate PASS is claimed; no approximation is proposed | [U] guard |

*End of PORT1TO1_video_targets. Exactly one repository file written. Donor material read-only under `%TEMP%\opencode\donor_videos\selected\cZW0AEupCaI\` and browser cache; no donor bytes copied into the repo.*
