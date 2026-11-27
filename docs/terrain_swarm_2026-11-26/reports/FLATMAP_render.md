# FLATMAP_render — read-only height-to-mesh trace (worker FLATMAP-1)

Scope: deterministic capture `mapoverview_20261127` (seed 20261113, donor-backend config, 1280x720) shows a flat green plane with settlement + field patches, no visible hills/valleys/relief. Prior audits (DEEPGEN_mask_height / stamp_relief / grid_seed) report GENERATION logic matches donor law; DEEPGEN_water_shore confirms water hard-fail is correct. This report traces height data from generation to rendered mesh WITHOUT executing code/Godot/donor, WITHOUT edits except this file, WITHOUT synthetic height/noise/fudge proposals. Parity: UNVERIFIED. Chain: 0/6. RESULT IS NOT GOOD.

## 1. Byte-proven chain (port file:line)

1. Generation owns a per-cell f32 height field. Stamp writes go through `data.set_height(idx, _pf(stamped))`:
   - `variant3d/scripts/terrain_donor_gen.gd:3091` (per-cell blend, Replace / ReplaceForWater / Smooth paths at `:3078-3086`)
   - `variant3d/scripts/terrain_donor_gen.gd:3274` (in-place smooth post-pass mean write)
   - Blend math cited at `terrain_donor_gen.gd:3065-3086`; pivot/scale/offset authority constants at `terrain_donor_gen.gd:385-415`.
2. Mesh ingests a COPY of that height array read-only (never writes sim):
   - `variant3d/scripts/terrain_donor_mesh.gd:478-498` (`_ingest()`; `:495-498` copies `height` candidate into `_height`, short array skipped/zero-filled path at `:493`)
   - Side channels ingested alongside: `relief_mask` at `:505-510`, `collision` at `:511-516`, additive `corner_tags4`/`variant_bytes`/override at `:519-563`.
3. Vertex Y IS height-driven — (a) is byte-REFUTED as a code-path claim:
   - `variant3d/scripts/terrain_donor_mesh.gd:2230-2232`: `verts.append(Vector3((x+ox-cx)*TILE_M, _height_at_corner(x,z,ox,oz) * HEIGHT_SCALE, ...))`
   - `HEIGHT_SCALE = 1.0` at `terrain_donor_mesh.gd:84` (PORT contract, cites `world3d_terrain.gd:131,1311`); no multiplier anywhere on this path; single-application guard at `:85-87` / stats `:1740`.
   - Corner height source at `terrain_donor_mesh.gd:776-790` (`_height_at_corner`: mean of up to 4 adjacent cell-centre heights; header labels it PORT SUBSTITUTE, donor corner sampling [U]).
   - Normals from the SAME field at `terrain_donor_mesh.gd:893-909` (1-cell forward difference, cites `world3d_terrain.gd:901-917`), averaged at corners at `:793-807`; relief consumed only as geometry+normal input per `:30-34` and stats `:1762-1766`.
   - Bilinear gameplay sampler reads the same `_height` at `terrain_donor_mesh.gd:350-368` (`* HEIGHT_SCALE` at `:368`).
4. Atlas / tile-array / build / bind links:
   - `_load_atlas()` at `terrain_donor_mesh.gd:1422-1501` (paths `:1347-1381`, loader `load()` at `:1466`, mask fetch at `:1495`, clamp fallback grid at `:1489-1491`).
   - `_build_donor_tile_array()` at `terrain_donor_mesh.gd:832-882` (real `Texture2DArray`, failure is labelled non-fatal at `:864-870`).
   - `build()` at `terrain_donor_mesh.gd:2090-2381`: opt-in flags `:2094-2102`, `_ingest()` gate `:2103-2105`, tile map `:2112`, `_load_atlas()` `:2116`, tile array `:2119`, per-cell quad loop `:2152-2259`, surfaces commit `:2260-2283`, water `:2377`, `_built=true` + `stats=_make_stats(...)` at `:2378-2381`.
   - Composer `terrain_donor_world.gd:288-396` (`build()`): inputs provider `:316-334`, `generate([_data, gen_params])` at `:335-337`, mesh `bind(game, mesh_src)` at `:340-353` (live view `to_live()` `:350` else `to_dump()` `:352`), mesh `build()` at `:354-355`.
   - `variant3d/scripts/world3d.gd:627` instantiates `TERRAIN_DONOR_SCRIPT` when `terrain_backend=="donor"` (switch at `:223-228`, lock at `:648`); `world3d.gd:661-664` binds + builds terrain when `_has_height_source()` (`:250-256`).
5. Camera (framing only, no height role):
   - `variant3d/scripts/camera3d.gd:76` `DONOR_PITCH_DEG=-32.0` (cites `camera.cfg:32-35`); applied at `:306-310` (`look_at` from `height` + `back=h*cos/-sin`).
   - Height state `20-58 m` at `:58-60` (`DONOR_HEIGHT_MIN/MAX`), zoom mapping at `:259-269`; V-FOV `17.27 deg` PORT APPROXIMATION at `:109` (UNVERIFIED sensor); near/far port values at `:112-113`.
   - Height sampler is read-only and anchor-only (`:153-163`, `:382-389`); absent sampler returns `0.0` flat plane for the ANCHOR ray only, never the mesh.

## 2. Telemetry keys that report height range (all diagnostics-only, never fed back)

- Mesh: `height_min_m` / `height_max_m` computed at `terrain_donor_mesh.gd:1724-1728`, published at `:1741-1742`; `height_hist_deciles` at `:1695-1719` / `:1743`; `height_scale` at `:1739`; container source labelled at `:2039-2043`.
- Container: `height_min` / `height_max` / `height_deciles` at `variant3d/scripts/terrain_donor_data.gd:613-627` (labels at `:603-608`, `:625`).
- Generation: `container_stats` merged at `terrain_donor_gen.gd:920-921` (from `data.stats()` at `:920`); `stats()` telemetry-only contract at `:934-946`; relief authority/`relief_u_register` labels at `:987-1005`; per-family ledger `family_placements` / `stamp_candidates` / `height_stamps` at `:3483-3537` / `:3357-3360` / `:3530-3531`; composer surfaces mesh stats at `terrain_donor_world.gd:479-522` (`mesh_stats` `:515`).
- No height value is asserted for `mapoverview_20261127` in this report: the capture's `height_min_m/max`, deciles, `family_placements.*.height_stamps`, and `stamp_smooth_skipped` were NOT dumped/read here. Any claim about that run's numeric range from this report alone stays [U].

## 3. Verdict on (a)-(d)

- (a) "Heights computed but not applied to vertices" — REFUTED at code-path level (byte-proven): `terrain_donor_mesh.gd:2230-2232` multiplies sampled height into every vertex Y, with `HEIGHT_SCALE=1.0` (`:84`). If the capture's `_height` field were non-flat, the mesh vertices for that build would be non-flat. Whether the CAPTURE's `_height` was flat is a separate data question (see b), not a missing-wire question.
- (b) "Mesh flat because relief stamps were skipped" — PLAUSIBLE but [U] for this capture. Skip paths are byte-proven in code, firing conditions are NOT proven for seed 20261113:
  - `terrain_donor_gen.gd:2997-2999` returns with no write when `height_field_stand` is false.
  - `terrain_donor_gen.gd:3015-3016` / `:3018-3019` return when grid is absent/wrong-size (`relief_float_grid` vs canonical `grid`, `:3001-3005`).
  - `terrain_donor_gen.gd:3041-3044` returns when the WxH vertex mask is unavailable.
  - `terrain_donor_gen.gd:3072-3075` skips per-cell on mask gate / out-of-map.
  - `terrain_donor_gen.gd:3504-3511` counts `missing_name` / `missing_pattern` and continues with NO stamp when `p.patterns`/`p.families` lack the drawn member; empty `p` (composer fallback `terrain_donor_world.gd:315-335`, inputs absent path `:333-334`, gen empty-dict contract `terrain_donor_gen.gd:816-831`/`892-911`) therefore labels-and-skips rather than inventing relief.
  - Which of these fired (if any) on `mapoverview_20261127` requires the run's `family_placements`, `stamp_candidates`, `stamp_smooth_skipped`, and `height_min/max` — none dumped here. So (b) stays [U], NOT byte-proven for the capture.
- (c) "Camera pitch/zoom makes relief invisible" — [U], and disfavoured as a SOLE cause but not excluded. Byte-proven framing: pitch `-32 deg` (`camera3d.gd:76,306`), height `20-58 m` (`:58-60`), V-FOV `17.27 deg` PORT APPROX (`:109`). At `-32 deg` a plateau-height-scale relief (`cPlateauHeight 2.964` at `terrain_donor_gen.gd:196`, hill `2.964/2.25` at `:197`, ravine `-2.964` at `:198`, water `-1.1` at `:199`) over `TILE_M=2.0` cells (`terrain_donor_mesh.gd:75`) should still produce visible shading/geometry unless the height field itself is near-flat or the normal/lighting path washes it out. No projection computation proving invisibility is cited anywhere in-port; the donor yaw/sensor/projection stay [U] (`camera3d.gd:48-51`). So (c) stays [U].
- (d) "Something else" — OPEN [U]. Byte-proven non-flattening attenuators (do not flatten by themselves):
  - `_height_at_corner` mean-of-neighbours (`terrain_donor_mesh.gd:776-790`) smooths/attenuates sharp relief but preserves a non-flat field; it cannot make a hilly field exactly flat.
  - Uniform-cell corner-tag fallback (`terrain_donor_mesh.gd:641-649`, `_tag_fallback_from_tex` `:525-528`) affects TAGS/UV only, not vertex Y.
  - Water hard-fail being correct (per DEEPGEN_water_shore) does not explain missing land relief.
  - Unrecovered kernels/hooks that could zero-out or skip height work while staying labelled: `bsmooth_kernel` NULL/SKIP (`terrain_donor_gen.gd:573-580`, telemetry `:1585-1588`), `smooth_custom_min_hook` NULL (`:614-623`), `terrain_update_hook` / `d3_wrapper_hook` skipped (`:625-630`, `:648-664`, `:909-915`), `random_scale_hook` NULL (`:581-584`), `grid_table_hook` pending canonical tables (`:564-571`). Each is a byte-proven NULL path, but none is proven to have flattened this capture. All [U] as capture causes.

## 4. What is byte-proven vs what stays [U]

- BYTE-PROVEN: generation writes `height` via `set_height` (`terrain_donor_gen.gd:3091,3274`); mesh copies it (`terrain_donor_mesh.gd:495-498`) and applies it to every vertex Y (`:2230-2232`, `HEIGHT_SCALE=1.0` at `:84`); skip/gate code paths above exist verbatim; telemetry keys above exist verbatim; camera pitch/height/FOV literals above exist verbatim. NO parity is claimed from any of this.
- [U]: (1) the actual `height_min_m/max`, deciles, and `family_placements.*.{needed,accepted,height_stamps,missing_*}` for seed 20261113 / `mapoverview_20261127`; (2) whether empty-`p` / missing-pattern / `Stand=false` / mask-unavailable / `bsmooth` SKIP / Delphi-state placeholder paths fired on that run; (3) whether `-32 deg` pitch at the capture's height/zoom hides the run's actual amplitude; (4) any donor-GPU A/B comparison. No synthetic height/noise/fudge is proposed; no approximation is asserted as donor truth.

Chain: 0/6. Parity UNVERIFIED. RESULT IS NOT GOOD.
