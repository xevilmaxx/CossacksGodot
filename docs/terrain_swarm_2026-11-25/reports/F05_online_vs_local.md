---
id: F05
ticket: "Wave F — reconcile ONLINE donor research against local decomp/swarm reports"
swarm: terrain_swarm_2026-11-25
date: 2026-11-25
status: READ_ONLY__ONE_REPORT__NO_CODE__NO_GODOT_JOB
scope: "One new report only. No code, asset, config, test or git edit. No donor executed/copied. No Godot runner job."
owner_files:
  - docs/terrain_swarm_2026-11-25/reports/F05_online_vs_local.md
labels: [observed, derived, inferred, UNVERIFIED, CONFIRMED, CORRECTED, CONFLICT]
visual_parity_claim: false
---

# F05 — Online donor research vs local decomp/swarm reports

## 0. Method and guardrails

Read in full: `docs/terrain_swarm_2026-11-25/CHARTER.md`;
`docs/DECISION_LOG.md`; `docs/coord_swarm_2026-11-25/CORRECTIONS.md`;
`reports/RV_TRN_01_texgen_mask_reverify.md`, `RV_TRN_02_smoothing_rules.md`,
`RV_TRN_03_water_bindings.md`, `DALPHA_01_alpha_subrect.md`,
`DSEL_01_donor_selection_rectangle.md`, `DSEL_02_donor_pick_math.md`,
`RELIEF_01_stamping.md`, `RELIEF_02_stamp_marker.md`,
`BUILD_STAGES_01.md`, `SEL_01_implementation.md`; plus `DBUILD_01_building_stages.md`,
`RV_SEL_01_selection_reverify.md`, `B_GHOST_DIAG.md`, `B_GHOST_FIX.md` for the ghost/stage claims.

Online pass (this report only): webfetch of the `cossacks-3-almanac` EN/RU evidence tree
(EN raw files on GitHub; RU mirror at `niocreations.ru/cossacks-3-almanac/docs_en?p=...`),
cossackshq NTM, gamepressure UI, and the charter-seeded Steam/news, cossacksworld and
ghost-preview URLs. **Labels**: CONFIRMED = online and local agree on the same donor fact;
CORRECTED = one side refined/refuted the other; CONFLICT = a port claim or requirement
contradicts the recovered donor fact; UNVERIFIED = no readable source on one side.
As in CHARTER §3 and CORRECTIONS "How to use this index", no visual-parity claim is made and
no APPROX label is promoted to donor fact. D-22 (evidence before edits) and D-24
("donor uses 320 cells, 1 unit = 2 cells"; never detune a correct generator to please a
stale test) are the governing decisions.

**Key structural finding:** the almanac is authoritative on *gameplay/production/map-gen*
(its source of truth is the installed game's scripts), but it **explicitly does not decode
`.actor`/`.tlf`/`.dds`/`.map` 3D assets or shaders** (`internals_en/data/file_formats.md`
"we don't need 3D data"). Therefore, for the four visually-loaded items (tile alpha grid,
ghost, texgen/repetition, exact relief sculpt) the local decomp reports remain the only
authority; "online is silent" must never be read as "online refutes".

## 1. Reconciliation table

| # | Claim | Local authority (path / row) | Online authority (URL) | Verdict | Reconciled truth / correction to respect |
|---:|---|---|---|---|---|
| 1 | `gc_meters_to_tile = 2` (2 m per map cell) | `docs/coord_swarm_2026-11-25/CORRECTIONS.md` row **10 RESOLVED** (`dmscript.global:171`, px/m `:170`, px/tile `:172`; `decomp/DEC_05_terrain_formats.md §6 #1` N11); `docs/DECISION_LOG.md` D-24; `DSEL_02` claim 18 (`i=Floor(2*x)+GetMapWidth`) | Almanac `internals_en/data/file_formats.md` (`dmscript.global` = `gc_*` constants source); `docs_en/recon/world/map/map_generation_pipeline.md` (grid "cells"); Fandom `Dmscript.global` wiki lists the file as holder of global variables. The literal `gc_meters_to_tile` is **not published** in the almanac docs. | **CONFIRMED** locally; online **UNVERIFIED** for the literal (consistent with 2-cell grid) | Keep `TILE_M=2.0` as donor-grounded, not port-only. Do not substitute another metres-per-cell constant; do not re-derive it from `gc_collision_size=0.5` (that is the *collision-mask* half-cell, a different scale). |
| 2 | Tile alpha grid (8×4×64 sub-rect atlas) and tile→patch rule | `DALPHA_01` verdicts 1 RESOLVED / 5 CONFIRMED_UNVERIFIED (`alpha.bmp` @1070, `reftile.lib:10-12`, `hf.pvl.sm.vert:34`); `RV_TRN_01` verdict B PARTIAL; CORRECTIONS rows **43/44/89/90/133** | Almanac `internals_en/data/file_formats.md`: `.dds` textures, `.bmp` and `.actor`/`.tlf` are **not parsed**; no alpha-atlas doc anywhere in `docs_en/`. NTM (`cossackshq.net/c3-mod-new-terrain-mod`) mentions "new map textures" only. | **CONFIRMED** geometry locally; selection rule **UNVERIFIED** locally and online | 8 columns × 4 rows of 64² patches is donor-grounded (seam deltas). The tile-id+boundary→patch index is CONFIRMED_UNVERIFIED: keep `PORT APPROX` and the `mask_to_alpha` knob. Do not claim whole-atlas `fract(v_st)` sampling is donor-shaped (CORRECTIONS row 44). Exact complement pairs exist only for the four sentinel patches (row 43). |
| 3 | Build-stage mesh naming | `DBUILD_01` §2.1–2.4: `engcen.actor` 7 slots — base `engcen.osm`, stages **`engcen1..4.osm`**, deaths **`engcen_death1/2.osm`**, attach **`engcen{1..4}a` / `_death1a/2a`**, materials `scaffold`/`debris`; `floor(buildprogress*4)`→suffix 1/2/3/4, wall `1+stage div 3`; `BUILD_STAGES_01` §3/§4 implements this but measured **0** converted stage OBJs | Almanac `internals_en/scripts/building_mechanics_evidence.md`: `collisionmaskproperty.Mask`, `buildprogress += delta` per hammer strike, `OnTagStates`, and destruction model names **`bavcen_death1a`/`bavcen_death2a`** with `debris` material; `docs_en/recon/world/economy/building_mechanics.md` (30+30 s ruin stages). Charter seed `cossacksworld.ucoz.co.uk/index/new_buildings/0-349` (search snippet "Rename both, to miscas.osm"; site returned 403 to this pass) confirms `<sid>.osm` modding convention. | **CONFIRMED** | Naming rule is donor truth on both sides. Port implementation is a **selector only**: all under-construction buildings reuse the base mesh (`BUILD_STAGES_01` §7.1) and the scaffold is a hidden placeholder — keep those labels. Online adds a correction: a **Gate is an instant upgrade of a completed wall segment, not a separately built 4-stage structure** — do not invent gate stage meshes. |
| 4 | Ghost semantics (translucent hologram, green/red, finished structure, honest footprint) | CHARTER §1b.3 (owner requirement: show **LAST/completed** stage; green valid / red blocked; pixel-honest footprint); `DBUILD_01` §4.1: donor ghost = engine dummy + canbuild/cannotbuild blink, **colour/size/exact mesh UNVERIFIED** (`:166`, `:257`); `B_GHOST_DIAG` §2 / `B_GHOST_FIX` §2: port ghost resolves `_stage_mesh_info(sid, "1", false)` **first**, footprint is `BoxMesh(1,0.05,1)` scaled by `_building_radius(sid)` | Almanac `building_mechanics_evidence.md` §1: footprint = `.prop` **collision mask**, 1 mask cell = **0.5 map cells**, and `CustomBoundingAABB` (used for rendering/selection) is **separate and usually smaller**. `gamemechanicshoard.com/mechanic/ghost-preview` (charter-seeded) returned a transport error this pass → no independent online text for "finished-structure hologram". | **CONFLICT** (port policy + footprint) / **UNVERIFIED** (donor ghost appearance, owner convention) | Respect the owner requirement: ghost must select the **finished/base** mesh, never construction suffix `"1"`/`floor(progress*4)`; if stage art arrives, do **not** let the ghost follow it. Footprint must be keyed to the donor collision mask, not `_building_radius`; keep green/red validity (donor blink modes are confirmed, colour/size stay UNVERIFIED). Do not upgrade the charter's "hologram of the finished structure" sentence to donor fact — it is an owner directive. |
| 5 | Selection world-epsilon / drag rect | `DSEL_01` claims 1–4 CONFIRMED: `epsilon=0.005` world m (`onmousemove.inc:32`), `0.25` attack/guard (`:33-34`), axis-wise world X/Z ground delta (`:152`), start on first LMB-held MOVE; `RV-SEL-01` byte offsets; CORRECTIONS row **35** (S-25-06 rejects screen-space `select_in_rect()`) and row 50 (native inside-box predicate CONFIRMED_INFEASIBLE); `SEL_01` implements world epsilon, Shift=`spmAdd`, 0.5 s double-click | Charter seed Steam `store.steampowered.com/news/app/333420/view/4042499938190999083`: 2016-11 patch added drag-selection frame (page body not retrievable this pass; cited via CHARTER §1b.2). Gamepressure UI (`cossacks3/user-interface/zd91b1`) confirms Shift-add, Ctrl/double-click/Z select-same-type, Ctrl+A. Almanac `internals_en/engine/native_api.md`: native engine bodies are not in script text. | **CONFIRMED** locally; online **CONSISTENT** but no online epsilon literal | Keep world ground rect and 0.005/0.25 m epsilon. Do not re-open S-25-06 or add a screen-space selector without new byte evidence. Native inside-box predicate stays UNVERIFIED; do not claim centre/AABB/frustum as donor fact. Ctrl-remove on drag is commented out in donor — do not add. Do not copy the review-sourced "box-select fails after selecting a wall" bug. |
| 6 | Relief stamping (`plt2`, ravines, sculpt blend) | `RELIEF_01` §3.1 opt-in additive-clamp stamp, `PORT APPROX`, engine blend UNVERIFIED; `RELIEF_02` §2 `plt2` producer added, `k_ravine_1` BLOCKED; CORRECTIONS rows **36/56/64**: `.pattern` embeds w×h float32 height grids; 26 grids match `pattern.lib` bit-exactly; live amplitudes **+0.496 / −0.558**, formula `h=-1.1*fb*(1+3.5*fr)+A_class*fr`, **no noise layers** | Almanac `internals_en/data/file_formats.md`: `.pattern` format `8+C → f32[w*h] heightmap` after mask. `internals_en/scripts/map_generation_evidence.md` §Stage 3 + `[^23]`: `_misc_SetupPatternsByType` places mountains, three-part plateaus, ravines and hills; relief setting = share of plains/hills/mountains. NTM tweak 23 explicitly fixes stock confusion of plain/hills/plateau. | **CONFIRMED** (grid existence + placement); **CORRECTED** by local against old noise/amplitude claims; **UNVERIFIED** for exact sculpt blend | Online independently corroborates local DPATTERN/RELIEF; keep additive-clamp as PORT APPROX. Do not reintroduce ±2.964 amplitudes or noise layers (HEIGHT_GEN_DEEP_01, CORRECTIONS row 64). Keep `k_ravine_1` blocked until a donor-grounded producer exists; note donor `dogenerate.inc:1760` disables `ravine_medium`. Mountains are `terrainmeshN` props, not taller bumps. |
| 7 | Terrain texture repetition (`uv_repeat=(0.5,0.5)`, `fract(v_st)`) | CHARTER §2 suspect 1 (OBSERVED render artifact, 2 m cell repeat); `RV_TRN_01` verdict A: ground eye planes / `gl_TextureMatrix[0]` **CONFIRMED_UNVERIFIED** (packed `.bind`, entropy 7.96); `DALPHA_01` §6.1: do **not** sample whole atlas with `fract(v_st)`; CORRECTIONS row **44** CORRECTED, row 45 CONFIRMED_UNVERIFIED | Almanac `map_generation_evidence.md` `[^9]`: `SetupTiledPatterns('tiles')` makes ~100 sparse dirt/crack placements on a 25×25-cell grid; `[^37]` season colour tables (winter=6, desert=7, default=0). NTM: 200+ new patterns, 360+ masks, new map textures, animated trees — evidence that stock donor variety is limited (context for the owner's complaint, not a texgen rule). No almanac doc on texgen eye planes or UV repeat. | **CONFLICT** (port's "donor-shaped" claim) / **UNVERIFIED** online for texgen | The 2 m figure is the map grid (row 1), **not** a donor UV-repeat literal. Port `fract(v_st)` + nearest/mipmap is a PORT APPROX and the likely artifact source; adopt the 64² sub-rect sampler but keep tile→patch APPROX. Do not invent donor eye-plane values or a `bmTransparency` pass count; do not call the repeated pattern "donor parity" from metrics. |

## 2. Corrections the other workers must respect

1. **Ghost owner (E01–E05 / world3d_fx.gd):** change `B_GHOST_FIX`'s `_ghost_resolve_mesh()` policy from
   `_stage_mesh_info(sid, "1", false)` to the **finished/base** mesh (`_mesh_info(sid,"building")`
   first). Keep footprint BoxMesh as a labelled fallback only; any honest footprint must come from the
   `.prop` collision-mask footprint (0.5-cell units), not `_building_radius()`. Green/red validity and
   blink stay; donor colour/size stay UNVERIFIED. No new "donor hologram colour" constant.
2. **Build-stage owner:** naming `<sid>1..4.osm` / `_death1/2.osm` / `<sid>1a` is CONFIRMED online and
   locally. BUILD-STAGES-01's selector is correct but stage art is absent → PORT APPROX; gates are
   instant wall upgrades (almanac), so do not build a 4-stage gate path.
3. **Terrain/shader owner (TRN-SHADER):** CORRECTIONS row 44 is binding — the whole-atlas
   `fract(v_st)` sampler is **not** donor-shaped. Adopt 8×4×64 sub-rect sampling; label the tile→patch
   index APPROX; keep `mask_to_alpha` diagnostic; never assert eye-plane or blend-pass donor parity
   (RV-TRN-01 verdicts A/D).
4. **Selection owner (SEL/D-series):** S-25-06 (CORRECTIONS row 35) stands; world ground rect +
   0.005/0.25 m world epsilon are byte-confirmed. Native inside-box predicate is CONFIRMED_INFEASIBLE
   (row 50) — do not invent it, do not add drag Ctrl-remove, do not copy the wall-selection bug.
5. **Relief/data owner:** online independently confirms `.pattern` float32 height grids and pattern
   placement; keep additive-clamp labelled PORT APPROX and `k_ravine_1` BLOCKED. Do not restore the
   refuted ±2.964/noise-amplitude model (row 64) or add taller bumps for mountains (props instead).
6. **All workers:** no visual-parity claim from metrics, node counts or a pillow render (CHARTER §3 and
   CORRECTIONS rows 137/133). Online pages that returned errors this pass (Steam news body,
   gamemechanicshoard, cossacksworld 403) are cited as charter seeds, not as newly verified evidence.

## 3. Sources

### Online (fetched this pass unless marked)
- `https://github.com/anyalink99/cossacks-3-almanac` — repo overview; EN/RU evidence tree; README: numbers extracted from installed game files.
- `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/internals_en/scripts/building_mechanics_evidence.md` — footprint/collision mask 0.5 cell, `CustomBoundingAABB` separate, buildprogress, gate instant upgrade, death models `<sid>_death1a/2a`, `debris`.
- `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/docs_en/recon/world/economy/building_mechanics.md` — reader-facing mirror of the same construction/destruction facts.
- `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/internals_en/scripts/map_generation_evidence.md` — 5 stages, `gPatternMask` 640×640, `SetupTiledPatterns`, shore `height<-0.1`, relief densities/`_misc_SetupPatternsByType`, season colour table, no texture/shader decode.
- `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/docs_en/recon/world/map/map_generation_pipeline.md` — relief setting = plains/hills/mountains; season textures.
- `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/internals_en/data/file_formats.md` — `dmscript.global` `gc_*` constants; `.pattern` `f32[w*h]` heightmap; `.dds`/`.actor`/`.tlf`/`.map` not parsed.
- `https://raw.githubusercontent.com/anyalink99/cossacks-3-almanac/main/internals_en/engine/native_api.md` — 4,856 native signatures, 884 called; native bodies absent from script text.
- `https://niocreations.ru/cossacks-3-almanac/docs_en?p=recon/world/economy/building_mechanics.md` — RU-host EN mirror (page shell returned; content verified from the raw GitHub source above).
- `https://cossackshq.net/c3-mod-new-terrain-mod` — NTM: 360+ masks, new map textures, 200+ patterns, animated trees, tweak 23 (plain/hills/plateau separation).
- `https://www.gamepressure.com/cossacks3/user-interface/zd91b1` — Shift-add, Ctrl/double-click/Z select-same-type, Ctrl+A, Shift ×5, Ctrl unlimited queue.
- `https://store.steampowered.com/news/app/333420/view/4042499938190999083` — charter-seeded 2016-11 drag-selection patch (body not retrievable this pass).
- `http://cossacksworld.ucoz.co.uk/index/new_buildings/0-349` — charter-seeded `<sid>.osm` build-stage naming (403 to fetch; snippet via websearch).
- `https://gamemechanicshoard.com/mechanic/ghost-preview` — charter-seeded ghost convention (transport error this pass → UNVERIFIED).

### Local (all read this pass, relative to workspace root)
- `docs/terrain_swarm_2026-11-25/CHARTER.md` (§1b.2–3, §2 suspects, §3 guardrails, §6 online seed list).
- `docs/DECISION_LOG.md` (D-22 evidence-before-edits; D-24 320 cells / 1 unit = 2 cells).
- `docs/coord_swarm_2026-11-25/CORRECTIONS.md` (rows 10, 35, 43, 44, 45, 50, 56, 64, 89, 90, 133; unresolved-value table).
- `docs/coord_swarm_2026-11-25/reports/`: `RV_TRN_01_texgen_mask_reverify.md`, `RV_TRN_02_smoothing_rules.md`, `RV_TRN_03_water_bindings.md`, `DALPHA_01_alpha_subrect.md`, `DSEL_01_donor_selection_rectangle.md`, `DSEL_02_donor_pick_math.md`, `RELIEF_01_stamping.md`, `RELIEF_02_stamp_marker.md`, `BUILD_STAGES_01.md`, `SEL_01_implementation.md`, `DBUILD_01_building_stages.md`, `RV_SEL_01_selection_reverify.md`, `B_GHOST_DIAG.md`, `B_GHOST_FIX.md`.

End of F05. One report written; no code, asset, test, config, git or runner state changed; no donor binary executed or copied; no visual-parity claim.
