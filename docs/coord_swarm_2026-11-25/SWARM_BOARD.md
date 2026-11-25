---
title: SWARM BOARD — 2026-11-25 (3D variant)
area: coordination
owner: COORD (state column only)
updated: 2026-11-25
status: living
---

# 🐝 Swarm board — 2026-11-25

Only COORD edits the **State** column. Workers own exactly one output file each. Shared
code is READ-ONLY until an integration ticket grants exclusive ownership.

## Batch A — deep analysis (donor primary, 2D secondary)

| ID | Micro-task (one aspect) | Output report | Session id | State | Evidence |
|---|---|---|---|---|---|
| DSEL-01 | Donor drag-rectangle selection: events, filters, algorithm, constants | `reports/DSEL_01_donor_selection_rectangle.md` | ses_dee51f985ffeZE0yATH8H5kMWd | **DONE** (432 lines, 4 passes) | threshold **0.005 world m** (0.25 attack/guard) on ground X/Z; start on first LMB-held MOVE; Shift=`spmAdd`; yellow 1 px solid outline; `KeyDoubleDelay=0.5`; composition filters + squads; native rect predicate UNVERIFIED |
| DSEL-02 | Donor screen↔world projection, ground pick, camera math | `reports/DSEL_02_donor_pick_math.md` | ses_dee51f982ffeCTm081SUUllOyb | **DONE** (347 lines, 3 passes) | perspective focal 400, tilt −32°, dolly 20–58; FOV API exists (prior "no FOV token" wrong); click pick = ray→AABB ranked (1+dist)/prio 1..7; **drag rect = world ground coords + world epsilon + Shift=`spmAdd`**; left-click own-only |
| DTRN-01 | Donor terrain render pipeline: textures, atlas, blend, shaders | `reports/DTRN_01_donor_terrain_pipeline.md` | ses_dee51f97fffdswCFCpwK8WD4cg | **DONE** (550 lines, 2 independent donor passes) | donor = discrete TileBlock index + 3-pass weighted smoothing + alpha-atlas `bmTransparency` + eye-plane UVs + Blinn–Phong **no normal map** + 3/9-tap PCF; fog OFF default; exact constants cited |
| DTRN-02 | Donor terrain geometry: heightmap→mesh, relief, LOD | `reports/DTRN_02_donor_terrain_geometry.md` | ses_dee51f95fffeQEPCBeg2cS6ldB | **DONE** (2–3 passes) | **relief patterns DO sculpt height** via embedded float32 w×h grids (`pattern.lib:328-353`; `k_ravine_1` min/max −2.9636/+3.1398); mountains/plateaus are real 3D props (`terrainmesh*.osm`, 7–10 units tall); baked `.map` heights clamped ±2.96399999, 32–64% exactly 0.0; port has no relief grids, no props, smooth normals, no LOD |
| DTRN-03 | Donor shore + water transition | `reports/DTRN_03_donor_shore_water.md` | ses_dee51f959ffdWfU4WrVxM0Khpa | **DONE** (45 KB, 3 passes + citation re-verify) | one continuous depth ramp coastfade (level−height)/0.57, coastfade2 /1.07; alpha=0 & foam=0 at waterline, foam peaks depth≈0.535 m; thresholds −0.25/−0.1; port zeroes swell by feeding −0.25 as surface Y, clamps shore cells to grass1, adds shore_prox |
| DTRN-04 | Donor trees / forest decor | `reports/DTRN_04_donor_trees.md` | ses_dee51f94affedUzadYlEHa3LYj | **DONE** (358 lines, 2 passes) | 14+ mesh families, envscale 0.341–0.76 ±15% jitter; placement by freq + 256 tries + cell-mask no-overlap (no min-distance constant); authored yaw, 1 mesh frame/LOD; port has 22 sids but live pool 6, all scale 0.5, yaw 0, no stand pass |
| DTRN-05 | Donor mines / resource node display + envscales | `reports/DTRN_05_donor_mines.md` | ses_dee51f946ffenUwxj99HsWMDwJ | **DONE** (2–3 passes) | 3 ores + 6 env props, one byte-identical `.osm` silhouette, scale 0.3152 **no jitter**; on-ground deposit = donor olive/beige cracked disc + dark specks (refutes "bake artefact"); `SetupMines` 3/4/5 rings, 256 angle tries, 14+ cell bands; port has correct typed stamping, gaps are fidelity (stripped ground art, cluster counts) |
| DTRN-06 | Donor grass / mottling / decal / alpha blending | `reports/DTRN_06_donor_grass_decals.md` | ses_dee51f93effelp4sPf5j9RxtPg | **DONE** (438 lines) | grass = one tile id + authored detail blocks (test7/8/9/12/14), 1–6 cell runs, only 3–5 L darker; seam alpha = 8×4 grid of 64² organic complementary feathers; **no `dither`/`mottle` token anywhere in donor bytes**; port drops decal alpha + atlas mipmaps; A1–A10 + D1–D7 gates |
| V3D-01 | variant3d selection rectangle code-path audit | `reports/V3D_01_selection_rectangle_audit.md` | ses_dee5192d2ffepG0oEwDEtHbUIY | **DONE** (444 lines; static audit, no runner) | rectangle visual NEVER drawn (`world3d.gd:126-127` vs `world.gd:3641-3647`); functional drag path present but untested and geometrically approximate; `uitest select_box` bypasses input |
| V3D-02 | variant3d terrain render code-path audit | `reports/V3D_02_terrain_render_audit.md` | ses_dee5192d1ffeJfYIj1qSkvRDHI | **DONE** (206 lines) | plumbing correct; active causes P1–P15 (tile data 73% top-5, neutral eye-plane UVs, unshaded headlight, atlas/mask APPROX, water bands); 64² piece ladder T0–T5; 12 "already correct, do not redo" items |
| V2D-01 | 2D logical selection features (SECONDARY) | `reports/V2D_01_2d_selection_logic.md` | ses_dee5192ceffdNuBeZSCKI8ZElG | **DONE** (196 lines) | 6 px drag / 4 px draw gates, sim-metre `Rect2`, filter dead/player≠0/unit-only, double-click 0.35 s, Shift-add click-only; 3D copied all except 3D draw + projective box geometry |
| V2D-02 | 2D logical terrain/decor features (SECONDARY) | `reports/V2D_02_2d_terrain_logic.md` | ses_dee5192a9ffeIMbhn17vXIk1Bh | **DONE** | 2D has full logical donor chain (tileblock 8-sector shore/cliff + 3-pass smoothing, stamped relief, tree/mine placement); shared `game.gd`/`mapgen.gd`/`pattern_gen.gd` ⇒ 3D has logic; gap is presentation-only; stale audit claims flagged |
| TEST-01 | Smallest-map isolated/combo test harness design | `reports/TEST_01_smallmap_harness.md` | ses_dee5192a6ffeRgXU5grm0G2VBr | **DONE** (366 lines) | smallest proven map 64²; no per-category off switch ⇒ stub helpers; 3D PNG windowed-only; variant manifest/test_all still point at `app/`; 10 atoms + harness helper proposed |
| DOC-01 | All-prior-docs consolidation (exists / missing / fix) | `reports/DOC_01_all_docs_synthesis.md` | ses_dee51928cffe45X7RdwNyjTC7X | **DONE** (59 KB, 11 sections) | confirms V3D-01/V3D-02; 12-item failure register; 18 stale-vs-current arbitrations; ~35 donor evidence ids; 9 recommended micro-tasks |

## Batch A-decomp — deep donor decompilation DOCUMENTATION (read-only)

| ID | Micro-task | Output | Session id | State |
|---|---|---|---|---|
| DEC-01 | PE binaries, packer, RTTI, `.cdx` | `decomp/DEC_01_binaries_rtti.md` | ses_dee4f6ffcffeeGKaHVkmSMCxCG | **DONE** (~400 lines) | `.cdx` = `.exe` with only 3 bytes at `0x128` changed (entry → `.bind` +0x310); correction: `cossacks.exe` entry is in `CODE`, not `.bind`; CODEX/WUS runtime; C++Builder + Delphi proof; 112 RTTI names, 0 code xrefs |
| DEC-02 | Full `data\scripts` catalog + decompiled logic | `decomp/DEC_02_scripts.md` | ses_dee4f6ffaffervR4Ohf2PqdtmR | **REPORT DELIVERED** (85 KB, 1,090 lines; agent finalizing) | all 222 donor scripts (4.37 MB) enumerated; 19 files ASCII code + **CP1251 Russian comments**; 16 deep records; formation bonuses consumed (closes DB-01); **no numeric morale** (disband count<0.25×base; port constants invented); famine donor = difficulty death roll; market mean-reverting with exact bands; no donor patrol hotkey |
| DEC-03 | Full config key/value truth (envscales/formations/hotkeys/light/env) | `decomp/DEC_03_configs.md` | ses_dee4f6ff7ffemIl1UwfIe9qQyz | **REPORT DELIVERED** (791 lines; agent finalizing) | 77 cfg/ini inventoried; hotkeys 243 lines but only 55 bindings (prior "243 bindings" wrong); formations 149 IDs / 46 nonzero (not 43); envscales 122 objects / 3 jitter bands (not one); formations fully imported in port; **light/sky colours NOT imported — top visual gap** |
| DEC-04 | Anim/sound formats `.oss/.osm/.aaf`/ACL/audio | `decomp/DEC_04_anim_formats.md` | ses_dee4f6fe3ffemAdgSLjU4qedRY | **DONE** (689 lines, 12 sections) | `.oss` 24-byte header, 335/335 exact size closure, fps 30, no parent table/bone strings; **frame 0 is NOT bind pose for multi-bone files** (major correction to DEEPDEC-06); `.osm` IDP2 v8 + 130/3897 extra frames; `.aaf` 246/246 parse, all rows `morph`; 325/325 Ogg; "733/733 verts" = OBJ vt count, not skin verts |
| DEC-05 | Terrain formats `terrainmesh*.osm`/heightmap/`.dds`/tile-blend | `decomp/DEC_05_terrain_formats.md` | ses_dee4f6fddffdFfiMII3qGDjWMd | **DONE** (634 lines) | **new donor constant `gc_meters_to_tile = 2` (`dmscript.global:171`) → port `TILE_M=2.0` IS donor-grounded** (corrects DTRN-01 C6); `.map` has per-cell 37-byte terrain records (102,400×), partially corrects "no donor tile-index file"; `heightmapwaves0.tga` alpha all 255 → cannot be `hmapTex.w`; TGA masks are RLE; donor has no `terrain/heightmap/**` or `terrain/blocks/**` |
| DEC-06 | Map/editor formats `.map/.aix/.cdx` | `decomp/DEC_06_map_formats.md` | ses_dee4f6fd7ffeewoYhWbCn5IvFQ | **DONE** (511 lines) | `.map` = flat 7-bit Delphi stream, full schema + gMap/gScenario blobs; 87-map survey 320²×80/384²×3/512²×3/640²×1; `.aix` all ASCII, 173-entry editor registry; `.cdx` = PE entry redirect (DA_PE "6 PE" refuted — 19 found); skirmish seed chain documented; DD "CLOSED grid" refuted |
| DEC-07 | `data\cameras` + `data\shaders` full parameter dump | `decomp/DEC_07_cameras_shaders.md` | ses_dee4f6fd4ffe8kyYPAxlqnkfXZ | **DONE** (67 KB) | 4 camera files + 109 shader FILES (not programs; 6 duplicate pairs, 20 bone files → 2 templates); closed-form projection; 3 corrections: `.inc` "commented" claim, minimap helper active, FOV arithmetic 5.15°/30.22° not 17.27°; port gaps: shadow/fog off, neutral uniforms, flat Y=0 |
| DEC-08 | UI/minimap/strings/localization definitions | `decomp/DEC_08_ui_strings.md` | ses_dee4f6fd0ffeabM3P06RaF84q8 | **DONE** | minimap bottom-**RIGHT** 240×240 (port: 200 px bottom-left); selection brush yellow 1 px solid reconfirmed; `.lng` string-table layout decoded; 34 minimap primitives; rally = 3D object scale 0.0525; port gaps: no 3D rect, no double-click jump, no locale layer |

Lane charter/index: `decomp/README.md`. All DEC workers write ONLY their own report under
`decomp/`, use short hex excerpts with `path:offset`, record evidence ids where available,
and separate `observed`/`derived`/`inferred`/`UNVERIFIED`.

## Batch B — independent re-verification (third pass on donor claims that drive fixes)

| ID | Micro-task | Output | Session id | State |
|---|---|---|---|---|
| RV-TRN-01 | 3rd pass: resolve/ confirm-unverifiable donor eye-plane UV, alpha sub-rect, face tilt, blend passes (binary strings + full-config search) | `reports/RV_TRN_01_texgen_mask_reverify.md` | ses_dee450a49ffee38hEELnYiIYFw | **DONE** (23.5 KB) | eye planes + blend passes **CONFIRMED_UNVERIFIED**; 8×4×64 alpha patch grid **empirically confirmed** (seam deltas 64–185 at multiples of 64); face-alpha eye planes + exact 25° literals recovered; tile→patch selection still UNVERIFIED; corrections to DTRN-01 |
| RV-TRN-02 | 3rd pass: parse ALL 1,864 lines of `tilesmooth_scripts.cfg` + verify 3-pass smoothing / shore / rock / road rules | `reports/RV_TRN_02_smoothing_rules.md` | ses_dee450a48ffenu7YgKeC6C6MdC | **DONE** (803 lines) | 22 Items (not 64), 130 lists (118 active), 310 TileName (282 active), 320 Prob; road probs **0.5/0.375/0.125** (not 0.25/0.25); 3 passes confirmed; DTRN-01 Q4/Q5 resolved; **terrain `.inc` lines are plain `;` comments = donor intent, unlike GUI `[*]=;` live code** |
| RV-TRN-03 | 3rd pass: donor water `hmapTex`/wave bindings + constants + shore fragment | `reports/RV_TRN_03_water_bindings.md` | ses_dee450a48ffdigo093mOU2d7cC | **DONE** | `heightmapwaves0.tga` **NOT** `hmapTex` (only commented lines, 0 binary hits); `hmapTex/hmapMin/Max/reflectionMap/fogEnabled` ENGINE/UNVERIFIED; `shore_prox` derived INERT at waveheight=0; legacy `.bak` shader in EXE has LIVE Fresnel; constants re-read verbatim |
| RV-SEL-01 | 4th pass: resolve DSEL-01/02 vs DEC-07 on `.inc` live-code convention, 0.005 m threshold, yellow 1 px visual, Shift semantics | `reports/RV_SEL_01_selection_reverify.md` | ses_dee3d1b18ffeW5muDXdlQbfbRv | **DONE** | `[*]=;` is LIVE code in all 136 GUI `.inc` files (39,074 lines, 0 exceptions); real comment token is `//`; DEC-07 §8.1 corrected; all 4 conflicts confirmed byte-level; native inside-box predicate remains UNVERIFIED |
| RV-CAM-01 | 3rd pass: resolve donor FOV/focal conflict (17.27° vs 5.15°/30.22° vs runtime API) | `reports/RV_CAM_01_fov_resolution.md` | ses_dee3d1b14ffeI3825zseWr54aG | **DONE** | 17,001-file scan confirms 0 FOV/sensor config hits; FOV **CONFIRMED_UNVERIFIED**; keep 17.27° labelled PORT APPROX; DEC-07 §8.1/§8.3 refuted | FOV **CONFIRMED_UNVERIFIED**; 17.27° = V-FOV of 216 mm horizontal sensor @16:9 f400 (DEC-07's 5.15°/30.22° were H-FOV, not corrections); keep `FOV_DEG_ASSUMED=17.27` as PORT APPROX; `[*]=;` live-code convention reconfirmed; DEC-07 §8.1/§8.3 wrong |

## Batch D — small feature (owner directive 2026-11-25)

| ID | Micro-task | Owned files | Output | Session id | State |
|---|---|---|---|---|---|
| CFG-01 | Default skirmish: Russia vs Bavaria, smaller map, Mediterranean-with-hills type, no fog of war | `variant3d/scripts/config.gd`, `menu.gd` | `reports/CFG_01_skirmish_defaults.md` | ses_dee421bccffeq8fPJi27IKDgF1 | **DONE** | nations/fog already correct; interactive defaults → 240², `mediterranean`, `low_mountains`/hills; gates 29/29 (312) + 17/17 (313) + CLEAN |
| CFG-02 | No-menu 240² in `config.json` | `variant3d/config.json` | `reports/CFG_02_no_menu_defaults.md` | ses_dee2f0d71ffeuuBMJpttB0x8y1 | **REVERTED — evidence** | 240 broke `wall`/`shell`/`farm_cap` (26/29) regardless of map_type; 320 passed 29/29 (322); uitest 17/17 at 240 (325); cause = fixed 6–24 m `_spot()` ring in `selftest.gd:123-133`; file restored byte-identical |
| MAP-SMALL-01 | Scale `_spot()` ring to map size, then re-apply 240² no-menu default; prove 29/29 at both sizes | `variant3d/scripts/selftest.gd`, `variant3d/config.json` | `reports/MAP_SMALL_01_report.md` | ses_dee1ffa4dffeNE1DyOlFaHFllL | RUNNING |

## Batch E — test-atom authors (AUTHORING ONLY; no runner jobs, no shared-code edits)

| ID | New file (exclusive) | Session id | State |
|---|---|---|---|
| TEST-HARNESS | `variant3d/tests/fixtures/_smallmap_harness.gd` | ses_dee3939b3ffeznHIT0uxz8F0Aq | **DONE** (153 lines, dynamic-load only) | `make_stub_game`, `count_categories`, `write_result`, `make_height`, `make_tileblock`; 24 bumping `cmd_*` counters; citations to proven stubs; no run, no pass claim |
| TEST-P0 | `variant3d/tests/t_terrain_only.gd` | ses_dee3939b2ffeqwGKCHeLQWUSmG | **DONE** | 64² synthetic grass-only/no-water/no-res stub; 13 structural + pixel assertions; windowed 1280×720 SubViewport capture; headless = `SKIP_CAPTURE` (no PASS claim); NOT RUN |
| TEST-P1 | `variant3d/tests/t_terrain_trees.gd` | ses_dee3939aeffeCbnyczlbHQgg2Q | **DONE** | P0 baseline + 20 wood nodes via `POOL_TREE`; asserts tree count/category purity, Y within 1e-3 m of height_at, PNG diff vs P0, telemetry; donor scale/yaw gaps logged as KNOWN_GAP, not parity; NOT RUN |
| TEST-P2 | `variant3d/tests/t_terrain_shore.gd` | ses_dee393991ffeP3S0tLI0jVPPFX | **DONE** | 64² basin ~28 water cells, one height-aware plane, shore ids in UV2, donor literals, no added foam; two-frame water delta with UNVERIFIED fallback; `EXPECTED_PRE_FIX_FAILURE`, no PASS claim; NOT RUN |
| TEST-P3 | `variant3d/tests/t_terrain_mines.gd` | ses_dee393990ffeggOWuZdLgGHgDH | **DONE** | 6 ore nodes (gold×2/iron×2/coal×2), exact counts + category purity, sid resolution, Y within 1e-3 m, ground A/B outside bbox; scale/jitter parity UNVERIFIED; NOT RUN |
| TEST-S1 | `variant3d/tests/t_select_rect.gd` | ses_dee39398cffeJTVVIHbON0UHyA | **DONE** (atom + report) | real 64² boot, 3 units + 1 building, real press/motion/release, asserts selected ids `[10,11]`, cmd counter 0, overlay Rect2 during drag; overlay checks flagged `expected_pre_fix_failure` (NOT weakened); no Godot run |
| TEST-C1 | `variant3d/tests/t_combo_trees_shore.gd` | ses_dee36066affeV2ZRyoXOfnMXhY | **DONE** (28 checks) | P0 + 20 wood + P2 basin/shore, no mines; trees relocated off basin; asserts both parent invariant sets, trees above water, dark rows=0; windowed PNG; NOT RUN |
| TEST-C2 | `variant3d/tests/t_combo_trees_mines.gd` | ses_dee360669ffeQP3fcew9fO1cvC | **DONE** (853 lines, 32 checks) | 20 wood + 3×3 ores, exact counts/category purity, separation ≥19.8 m, Y within 1e-3 m, P0 mesh invariants; water-plane check scoped to zero *visible* planes; NOT RUN |
| TEST-C3 | `variant3d/tests/t_combo_shore_mines.gd` | ses_dee36064cffeFtT5pehfSICR3I | **DONE** | 149 water cells (3.64%), `sandsea1/5/6` ids 93/97/98, 6 ores on land above water, 16 checks, windowed PNG; headless = SKIP_CAPTURE/UNVERIFIED; NOT RUN |
| TEST-C4 | `variant3d/tests/t_combo_all.gd` | ses_dee360647ffeN5JTZzWRFcNMAe | **DONE** (1,033 lines, 47 checks) | P0+trees+shore+mines, per-layer user-arg toggles, all parent invariants + no stacked planes + no dark rows/cols; windowed capture; sole eligible final-review combo; NOT RUN |

## Batch F — implementation (disjoint file grants, gated)

| ID | Exclusive file | Output | Session id | State | Gate |
|---|---|---|---|---|---|
| SEL-01 | `variant3d/scripts/input_controller.gd` | `reports/SEL_01_implementation.md` | ses_dee320891ffeci11ijTxdkwgTX | **DONE** | yellow 1 px solid marquee overlay; world epsilon 0.005 m (0.25 attack/guard); Shift=add; double-click 0.5 s; click-pick/cmd_* untouched; selftest 29/29 (337), uitest 17/17 (318), 12/12 real-drag probe (329); S1 parse errors routed to ATOM-REPAIR |
| CFG-01 | `variant3d/scripts/config.gd`, `data.gd`, `menu.gd` (only if needed) | `reports/CFG_01_skirmish_defaults.md` | ses_dee421bccffeq8fPJi27IKDgF1 | RUNNING | owner directive |
| FIX-TRN / DECOR / INT | — | — | — | RESERVED | piece captures + remaining re-verification |

## Batch G — execution (READ-ONLY on code; runner jobs only)

| ID | Scope | Output | Session id | State |
|---|---|---|---|---|
| TEST-RUN-01 | execute P0→C4 sequentially, stop at first failure, log jobs/PNGs/metrics | `reports/TEST_RUN_01_ladder_log.md` | ses_dee26bef9ffeJBJ72NbDhysLwn | **DONE — STOPPED AT P0** | job 321 `TESTRUN01-P0` END failed, exit 1, 6.50 s; no result JSON/PNG; 4 SCRIPT ERROR lines = parse error in embedded `LocalStubGame extends C3Game` (redeclared `res_dirty`/`entities`/`res_nodes`, wrong `resolve_mine_sid` signature). P1–C4 not run; no rerun, no weakening |
| ATOM-REPAIR | fix the systemic embedded-stub parse errors in all 9 atoms (parse-check only) | `reports/ATOM_REPAIR_report.md` | ses_dee233504ffeit7tb0yAS5EbvN | **DONE** | all 9 atoms load, jobs 364–375, 0 parse errors; 7 files minimally fixed (inherited-field dedup, `resolve_mine_sid(String,Vector2)`, `has_area()`, typed `via_helper`); 4 rows have one runtime helper cast error → HARNESS-01; assertions/markers intact |
| HARNESS-01 | fix runtime cast in shared harness `_smallmap_harness.gd:134` | `reports/HARNESS_01_cast_fix.md` | ses_dee0b8850ffe4C8NaHLuCUVvKX | RUNNING |
| TEST-RUN-02 | execute S1 after SEL-01 lands; second-agent capture re-check | `reports/TEST_RUN_02_selection_log.md` | — | RESERVED |
| FINAL | variant selftest 29/29 + uitest 17/17 + clean (COORD only, last) | `PROGRESS.md` | — | RESERVED |

## Batch H — parallel implementation (owner directive: more agents, faster edits)

Every builder owns exactly one file set; backups mandatory; targeted headless smoke check only.
Full gates are run **once** by COORD after all merges (decision S-25-12).

| ID | Exclusive file(s) | Session id | State |
|---|---|---|---|
| TRN-SHADER | `variant3d/shaders/terrain_tileindex.gdshader` | ses_dee214f8fffebRirTLcDLwrjHP | **DONE** | world-XZ texgen at 1/2 m (`gc_meters_to_tile=2`) labelled PORT APPROX; donor sun direction/ambient/diffuse replaces headlight, `unshaded` kept; one 64² alpha patch from confirmed grid with UNVERIFIED tile→patch map; no normal/foam/dither/shadows; smoke ticket 342 ok, 6/6 |
| TRN-WATER | `variant3d/shaders/water3d.gdshader`, `scripts/water3d.gd` | ses_dee214f8fffdN9SKjSO2LFR33m | **DONE** | `water_surface_y` uniform decoupled from classification literal; `water_cell` alpha gate confines water to water cells; `shore_prox` removed, verbatim donor foam; Donor constants preserved; smoke ticket 343 ok, SCRIPT ERROR 0; grass1 clamp handed to TRN-GEOM (cross-owner) |
| TRN-GEOM | `variant3d/scripts/world3d_terrain.gd` | ses_dee214f8dffdP8aaREHkMec7lU | **DONE** | 25° vf/vs tilt + exact height/sector tables; donor light/sky colours + shader uniforms bound; 1-cell normals; BLK_WATER→sandsea ids (grass1 clamp fixed); smoke 361 SCRIPT ERROR 0; left open: relief grids (DPATTERN-01), exact vf/vs rule, eye planes, mask-B, winter, sandrock |
| TRN-DATA | `variant3d/scripts/game.gd` | ses_dee214f77ffeGkBm7tkOv6epiu | RUNNING |
| DECOR-01 | `variant3d/scripts/world3d_entities.gd` | ses_dee214f74ffdw2QaIvj4GXoCUZ | **DONE** | tree pool 6→19 resolvable donor sids, per-sid scale ladder 0.475–0.76 + 3 jitter bands, mine bypass unchanged; yaw UNVERIFIED (no authored value reaches module), stand pass OPEN, mine disc BLOCKED (asset naming); smoke 358, pool=19/19, SCRIPT ERROR 0 |
| HUD-01 | `variant3d/scripts/hud.gd`, `hud3d_adapter.gd` | ses_dee214f70ffem6JabQYgoZdOay | **DONE** | minimap bottom-**RIGHT** 240×240 −8/−8, panels clipped; adapter adds `get_minimap_corners()` centred-world formula, box from corners; smokes 340/349/357 SCRIPT ERROR 0; left open: donor double-click jump, 4-edge quad stroke, `uitest.gd:304-307` anchor assertion |
| UITEST-ANCHOR | `variant3d/scripts/uitest.gd` | ses_dee1320f7ffeIUo66o34JffNGk | **DONE** | `anchor_left 0.0 → 1.0` with donor citations, one hunk 4+/2-, no weakening; uitest ticket 366 **17/17**, step `minimap bottom-right: yes` |
| VID-CAP-01 | NEW `variant3d/tests/t_motion_capture.gd` only | `reports/VID_CAP_01_capture.md` | ses_dee12de5effeqwB6klTsBPohuB | RUNNING | capture ≥12 frames of 4 units moving on 64², contact sheet + MP4 in temp; analysis by muse-spark next |
| CAM-01 | `variant3d/scripts/camera3d.gd` | ses_dee214f6fffeF0xlYVZgXxNskd | **DONE** (comment-only; git diff confirms 0 non-comment lines) | stale corner comment → CENTRED contract with citations; FOV label 17.27° PORT APPROX with RV-CAM rationale (value unchanged); smoke job 339 ok / stderr empty; refused to double-shift — filed `world3d.gd` ticket |
| CAM-02 | `variant3d/scripts/world3d.gd` | ses_dee198eefffe9nQw6OL8VRtGca | **DONE** | one-line Vector2 shift at `:270-274`, 4 insertions/4 deletions only; smoke ticket 356 ok; runtime parity still UNVERIFIED → CAM-RV-01 |
| CAM-RV-01 | NEW `variant3d/tests/t_view_rect_rv.gd` only | `reports/CAM_RV_01_view_rect_runtime.md` | ses_dee14b5c3ffeF4KSVWDn5KyIUm | RUNNING | live-scene double-click select-all + view_rect vs hud3d_adapter comparison; CONFIRMED/PARTIAL/REFUTED verdict |
| INT-REGISTRY | `variant3d/tests/manifest.json`, `tools/test_all.py` | ses_dee214f6effexL1ehIZAExRV6m | **DONE** |

## Batch I — post-closure donor deep dives (owner directive: keep agent count high)

Read-only; one report each; these target the details still UNVERIFIED after the 8 DEC reports.

| ID | Deep-dive scope | Output | Session id | State |
|---|---|---|---|---|
| DALPHA-01 | resolve donor tile→alpha 64² sub-rect index (`tsDouble`/`ttExtended`) | `reports/DALPHA_01_alpha_subrect.md` | ses_dee1bf820ffeqI8gPswM3SiWq9 | RUNNING |
| DPATTERN-01 | extract donor relief `.pattern` float32 height grids + relief props | `reports/DPATTERN_01_relief_grids.md` | ses_dee1bf81effeWBE5uL6hqyTxzP | RUNNING |
| DFX-01 | donor `.pfx` / particle / effect formats and constants | `reports/DFX_01_pfx_effects.md` | ses_dee1bf81cffd1YtLzJTEP54Pa2 | **DONE** (805 lines) | PFX is ASCII OSW text, not binary; 44 source records / 24 effects / 5 managers / 22 materials / 90 DDS; `rand*` 1-based slots in 8-float array (`pfx.script:39-86`); weather snow system discovered (default Weather=40 inactive); **no construction dust** (sound-only; visible smoke = damage smoke); port FX approximates/omits every donor class |
| DANIM-01 | donor AAF action ranges → per-unit clip table | `reports/DANIM_01_action_ranges.md` | ses_dee1bf804ffeoBhNG92tSjntOG | **DONE** (627 lines) | 246 AAF / 1,434 rows / **62 action names**, duration `(last−first+1)/30`; state→action chain + 44-row clip table; **DEC-04 §6.1 refuted: 335/335 frame-0 identity** (max |p| 1.09e−6, peaukr skin f0 1.52e−7), DEEPDEC-06 F4/F5 confirmed; flat-root sampled poses remain defensible |
| DBIND-01 | decode `.bind`/WUS packed container or prove infeasibility (eye planes, FOV, selection predicate) | `reports/DBIND_01_wus_bind.md` | ses_dee1bf803ffeua5uURG6dHAiy1 | **DONE** | `.bind` = 768-B header + **plaintext 98.4%-shared x86 loader stub** + ~135 KB high-entropy payload; corrects DEC-01 "whole section opaque"; no container/members, no valid compression headers, no short XOR/ADD key; eye planes/FOV/selection predicate **CONFIRMED_INFEASIBLE** (byte-level proof), no invented values |
| QA-AUDIT-01 | independently audit implementation diffs vs claims/runner artifacts (read-only) | `reports/QA_AUDIT_01_implementation_claims.md` | ses_dee0b2406ffeK68vFf63t6vwMN | RUNNING |
| DFORM-01 | donor formations / squads / morale / AI truth | `reports/DFORM_01_formations_morale.md` | ses_dee0b2405ffedd66db3bi5eb3C | RUNNING |
| DOC-02 | build authoritative donor corrections index | `CORRECTIONS.md` | ses_dee0b2404ffen2r14sdeaDhHJn | RUNNING |
| DENV-01 | donor environment / season / sky / weather truth | `reports/DENV_01_environment.md` | ses_dee1bf7ffffegcct0xe7ZrMaEW | **DONE** (656 lines, 50 KB) | full `env/**` key/value tables; season enum 0/2/3 + `_misc_SetSeason`/`SetDesert` swap; **DEC-03 sky labels inverted** (numbers/port correct); **`FogMode=0` ambiguous, not simply off**; 12 palettes byte-identical; port atlas has desert 111–122 but all 27 winter PNG unpacked; top gaps = winter/desert swap + cloud/weather layer | result_dir → `variant3d/tests/results`; tests 31→40 (9 new, additive-only; helper deliberately unregistered); test_all roots + `--path variant3d` fixed; `test_all.py --list` exit 0, all 40 rows, no 2D access; new rows `pending` until ladder green |

## Batch C — implementation (planned, gated on Batch A+B + piece tests)

Disjoint file grants only. Reserved slots:

| Slot | Owned file(s) | Gated on |
|---|---|---|
| FIX-SEL | `variant3d/scripts/input_controller.gd` (+ `picking3d.gd` if needed — ONE builder) | DSEL-01/02 + V3D-01 + V2D-01 + selection-rect test |
| FIX-TRN | `variant3d/scripts/world3d_terrain.gd` + terrain shader (ONE builder) | DTRN-01/02/06 + V3D-02 + terrain-only piece PASS |
| FIX-SHORE | `variant3d/scripts/water3d.gd` + shore shader | DTRN-03 + shore piece PASS |
| FIX-DECOR | `variant3d/scripts/world3d_entities.gd` | DTRN-04/05 + trees/mines pieces PASS |
| INT-GATE | integration + final gates (COORD only) | all fix slots green |

## Ownership legend

- Analysis workers: **read-only** on all code; own only their report markdown.
- No code edits, no Godot runner jobs, no donor copies during Batch A/B.
- Backups before any future edit: `inbox\backup\<name>.bak-<TICKET>`.
