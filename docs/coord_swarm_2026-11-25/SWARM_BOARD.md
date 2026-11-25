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

## 🔴 LIVE SESSION STATUS — real-time method and snapshot

**Method:** read-only SQLite query on `C:\Users\Maxym.Oboyshev\.local\share\opencode\opencode.db`,
`session_v2 WHERE parent_id = 'ses_dee54b600ffeIJcid56WLwoxnL'` (COORD), columns
`time_busy`, `time_idle`, `idle_outcome`, `time_updated`. Terminated = `time_idle` set with
`idle_outcome` `succeeded` or `interrupted`. The temp helper `session_status_check.py` uses
the *invoking* process's `OPENCODE_SESSION_ID`, so a subagent running it sees `children: 0`
— it must be run by COORD or with the parent id substituted (QA-BOARDLIVE-01, §method).

**Snapshot 11:32:51 (QA-BOARDLIVE_01.md, DB `MAX time_updated` 11:32:50):**
156 direct children; 137 IDLE/DONE (terminated), **19 BUSY/RUNNING** (including the
verifier itself). The set moved 20 → 19 during that check. Earlier snapshots were
11:26 (~4 busy) and 11:28 (4 busy) — counts are inherently perishable; re-run the query
before acting on them rather than trusting a static list.

**Termination convention:** every session id in the phase rows below that is not verified
BUSY in a fresh query is TERMINATED — including workers whose last message said "waiting
for the runner" or whose report landed while a background shell was still finishing.
DEC-02 and DEC-03 ended `interrupted` by explicit cancellation after complete reports; that
is a terminated state, not a running one. Do not re-spawn finished workers to ask status.

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
| DEC-02 | Full `data\scripts` catalog + decompiled logic | `decomp/DEC_02_scripts.md` | ses_dee4f6ffaffervR4Ohf2PqdtmR | **DONE — TERMINATED** (agent cancelled after report; 85 KB, 1,090 lines) | all 222 donor scripts (4.37 MB) enumerated; 19 files ASCII code + **CP1251 Russian comments**; 16 deep records; formation bonuses consumed (closes DB-01); **no numeric morale** (disband count<0.25×base; port constants invented); famine donor = difficulty death roll; market mean-reverting with exact bands; no donor patrol hotkey |
| DEC-03 | Full config key/value truth (envscales/formations/hotkeys/light/env) | `decomp/DEC_03_configs.md` | ses_dee4f6ff7ffemIl1UwfIe9qQyz | **DONE — TERMINATED** (agent cancelled after report; 791 lines) | 77 cfg/ini inventoried; hotkeys 243 lines but only 55 bindings (prior "243 bindings" wrong); formations 149 IDs / 46 nonzero (not 43); envscales 122 objects / 3 jitter bands (not one); formations fully imported in port; **light/sky colours NOT imported — top visual gap** |
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
<!-- CFG-01 duplicate row removed (2026-11-25 docs audit C2): authoritative DONE row above. -->
| FIX-TRN / DECOR / INT | — | — | — | RESERVED | piece captures + remaining re-verification |

## Batch G — execution (READ-ONLY on code; runner jobs only)

| ID | Scope | Output | Session id | State |
|---|---|---|---|---|
| TEST-RUN-01 | execute P0→C4 sequentially, stop at first failure, log jobs/PNGs/metrics | `reports/TEST_RUN_01_ladder_log.md` | ses_dee26bef9ffeJBJ72NbDhysLwn | **DONE — STOPPED AT P0** | job 321 `TESTRUN01-P0` END failed, exit 1, 6.50 s; no result JSON/PNG; 4 SCRIPT ERROR lines = parse error in embedded `LocalStubGame extends C3Game` (redeclared `res_dirty`/`entities`/`res_nodes`, wrong `resolve_mine_sid` signature). P1–C4 not run; no rerun, no weakening |
| ATOM-REPAIR | fix the systemic embedded-stub parse errors in all 9 atoms (parse-check only) | `reports/ATOM_REPAIR_report.md` | ses_dee233504ffeit7tb0yAS5EbvN | **DONE** | all 9 atoms load, jobs 364–375, 0 parse errors; 7 files minimally fixed (inherited-field dedup, `resolve_mine_sid(String,Vector2)`, `has_area()`, typed `via_helper`); 4 rows have one runtime helper cast error → HARNESS-01; assertions/markers intact |
| HARNESS-01 | fix runtime cast in shared harness `_smallmap_harness.gd:134` | `reports/HARNESS_01_cast_fix.md` | ses_dee0b8850ffe4C8NaHLuCUVvKX | **DONE** | `as Object` on Dictionary values → `is`-guarded extraction; all APIs/semantics intact; smoke ticket 384 `SCRIPT ERROR 0`, `Invalid cast 0` (exit 1 = atom's unchanged headless verdict) |
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
| TRN-DATA | `variant3d/scripts/game.gd` | ses_dee214f77ffeGkBm7tkOv6epiu | **DONE** | 118/118 active smoothing lists + 282 TileName:Prob embedded; SmoothTileMap after bitmap pass; forest donor Item1 J=5; no noise/dither; offline top-5 72.68→58.52%; determinism 5/5 (job 423); selftest 28/29, only `build` failed on concurrent rotor `.ctex` race |
| DECOR-01 | `variant3d/scripts/world3d_entities.gd` | ses_dee214f74ffdw2QaIvj4GXoCUZ | **DONE** | tree pool 6→19 resolvable donor sids, per-sid scale ladder 0.475–0.76 + 3 jitter bands, mine bypass unchanged; yaw UNVERIFIED (no authored value reaches module), stand pass OPEN, mine disc BLOCKED (asset naming); smoke 358, pool=19/19, SCRIPT ERROR 0 |
| HUD-01 | `variant3d/scripts/hud.gd`, `hud3d_adapter.gd` | ses_dee214f70ffem6JabQYgoZdOay | **DONE** | minimap bottom-**RIGHT** 240×240 −8/−8, panels clipped; adapter adds `get_minimap_corners()` centred-world formula, box from corners; smokes 340/349/357 SCRIPT ERROR 0; left open: donor double-click jump, 4-edge quad stroke, `uitest.gd:304-307` anchor assertion |
| UITEST-ANCHOR | `variant3d/scripts/uitest.gd` | ses_dee1320f7ffeIUo66o34JffNGk | **DONE** | `anchor_left 0.0 → 1.0` with donor citations, one hunk 4+/2-, no weakening; uitest ticket 366 **17/17**, step `minimap bottom-right: yes` |
| VID-CAP-01 | NEW `variant3d/tests/t_motion_capture.gd` only | `reports/VID_CAP_01_capture.md` | ses_dee12de5effeqwB6klTsBPohuB | **DONE** | job 408 ok, `CAPTURE_OK PASS 10/10`, 16 GPU frames + `frames.json` + contact sheet + MP4 in temp; sim 0.500→6.125 s, fixed camera, 16/16 distinct frames; no analysis/parity claim |
| VID-AN-01 | analyse motion sequence with muse-spark 1.3 (default variant) | `reports/VID_AN_01_motion_analysis.md` | ses_dedf51429ffeix3FIKnPL9K1W3 | **DONE** | 16 PNGs + `frames.json`: translation FAIL (stall ~14 m short), squad FAIL (1/4 moves), pose FAIL(data), direction FAIL (91°/166° snaps), contact PASS, uniqueness PASS; donor parity UNVERIFIED; routed to MOTION-ANIM-01 + `game.gd` ticket |
| MOTION-ANIM-01 | presentation-side motion fixes in `world3d_entities.gd` | `reports/MOTION_ANIM_01.md` | ses_dedf02a91ffe4WC7rm8cJUkFU7 | **REPORT DELIVERED** (rotor import finalizing) |
| FX-IMPACT-01 | volley smoke / muzzle flash / arrow trails in `world3d_fx.gd` | `reports/FX_IMPACT_01.md` | ses_dedf02a90ffeQT9Cvr4vrlF236 | **DONE** | donor-cited tints/AlphaPower/MarkWidth, face-camera billboards, opt-in flags default false so callers unchanged; snow/selection/legacy FX byte-identical; smoke 428 ok + `t_fx3d` 13/13 job 434; unit mappings UNVERIFIED |
| LIGHT-02 | independent donor light-space re-derivation | `reports/LIGHT_02_light_space.md` | ses_dedec4470ffeHwtSyDtjqStFu4 | **DONE** | donor light = Y-up world direction; correct `l = normalize((VIEW_MATRIX*vec4(P,0)).xyz)`, flat dot=0.938701; TERRAIN-DARK-FIX axis correct (keep), `/4,/2` compression APPROX; `world3d_terrain.gd:138 SUN_LIGHTVEC` still un-swapped → SP-6 follow-up |
| MINIMAP-QUAD-01 | 4-edge frustum quad in `hud3d_adapter.gd` (box unchanged) | `reports/MINIMAP_QUAD_01.md` | ses_dedf02a90ffdT7nAiMWDUbpMQj | RUNNING |
| AUDIO-SEL-01 | donor selection sounds API in `audio.gd` | `reports/AUDIO_SEL_01.md` | ses_dedf34a13ffe8TacmX9Sb5torn | **DONE** | `selection_clip`/`play_selection` via non-positional global path, donor clips verified on disk; smoke 424 ok / SCRIPT ERROR 0; integration `AUDIO-SEL-02` needed at selection-rebuild site | frame-numbered observations + numeric cross-check vs `frames.json`; no donor parity claim | capture ≥12 frames of 4 units moving on 64², contact sheet + MP4 in temp; analysis by muse-spark next |
| CAM-01 | `variant3d/scripts/camera3d.gd` | ses_dee214f6fffeF0xlYVZgXxNskd | **DONE** (comment-only; git diff confirms 0 non-comment lines) | stale corner comment → CENTRED contract with citations; FOV label 17.27° PORT APPROX with RV-CAM rationale (value unchanged); smoke job 339 ok / stderr empty; refused to double-shift — filed `world3d.gd` ticket |
| CAM-02 | `variant3d/scripts/world3d.gd` | ses_dee198eefffe9nQw6OL8VRtGca | **DONE** | one-line Vector2 shift at `:270-274`, 4 insertions/4 deletions only; smoke ticket 356 ok; runtime parity still UNVERIFIED → CAM-RV-01 |
| CAM-RV-01 | NEW `variant3d/tests/t_view_rect_rv.gd` only | `reports/CAM_RV_01_view_rect_runtime.md` | ses_dee14b5c3ffeF4KSVWDn5KyIUm | **DONE — CONFIRMED** | live 64² windowed job 381, **20/20**, SCRIPT ERROR 0; observed `view_rect` byte-identical to expected one-half-map shift (vs no-shift/double-shift counterfactuals); double-click selects `[10,11,12]` only; minimap box `(12,11,40,34)` matches |
| INT-REGISTRY | `variant3d/tests/manifest.json`, `tools/test_all.py` | ses_dee214f6effexL1ehIZAExRV6m | **DONE** |

## Batch I — post-closure donor deep dives (owner directive: keep agent count high)

Read-only; one report each; these target the details still UNVERIFIED after the 8 DEC reports.

| ID | Deep-dive scope | Output | Session id | State |
|---|---|---|---|---|
| DALPHA-01 | resolve donor tile→alpha 64² sub-rect index (`tsDouble`/`ttExtended`) | `reports/DALPHA_01_alpha_subrect.md` | ses_dee1bf820ffeqI8gPswM3SiWq9 | **DONE** (669 lines) | 8×4×64 grid RESOLVED with two decoders; all 245 `tiles.lib` sections share it (zero AlphaRows/Cols overrides); complement structure PARTIAL (only constant pairs exact); actual tile→patch rule CONFIRMED_UNVERIFIED (17,237 files + packed `.bind`) |
| DALPHA-02 | replace arbitrary tile→alpha patch map with DALPHA-01's donor-derived APPROX | `reports/DALPHA_02_patch_mapping.md` | ses_dee0beee6ffeHjztYwMKv20aFo | **DONE** | one hunk in `alpha_patch_uv()`: dir→row N/W/E/S=0/1/2/3, counterpart `(3−r,3−c)`, two-half variant; 64² sampling kept; smoke 382 ok / SCRIPT ERROR 0 / 6/6; engine rule still UNVERIFIED |
| MMJUMP-02 | donor minimap jump via separate camera API (`hud.gd`, `camera3d.gd` only) | `reports/MMJUMP_02_minimap_jump.md` | ses_dedfd3551ffei8IqlihH9QauRn | **DONE** | new `jump_to_world_donor_offset()` with donor `control.script:574-613` math; only `hud.gd:_cam3d_jump` wired; `jump_to_world` byte-identical (CAM-RV-01 20/20 intact), no test edited; smokes 413/416 ok + nav 417 6/6, SCRIPT ERROR 0; ArcTan PORT APPROX | keep `jump_to_world` byte-identical (CAM-RV-01 20/20), add `jump_to_world_donor_offset`, wire only `hud.gd:_cam3d_jump`; no test edits |
| MMJUMP-01 | donor minimap camera jump (`input_controller.gd`, `camera3d.gd`, `hud3d_adapter.gd`) | `reports/MMJUMP_01_minimap_jump.md` | ses_dee06f2deffeApAELcB9FGsUim | **DONE — reverted with evidence** | 4 smokes ok / SCRIPT ERROR 0; patch restored byte-for-byte from backups; conflict proof: primary click in foreign `hud.gd`, and shared `jump_to_world` change would break confirmed CAM-RV-01; proposed split API design adopted by MMJUMP-02 | primary click is consumed by `hud.gd:1414-1422 → _minimap_jump_3d → _cam3d_jump → camera.jump_to_world` (hud.gd not in grant); changing `jump_to_world` would contradict CAM-RV-01's confirmed centre-click assertion (`t_view_rect_rv.gd:232,420-423`). Builder correctly refused a partial/inconsistent change |
| FX-WEATHER-01 | gated donor snow layer in `world3d_fx.gd` | `reports/FX_WEATHER_01.md` | ses_dee06f2daffexjxV92X0eF2WmH | **DONE** | `WeatherSnow3D` root + 4 emitters with donor speeds/counts/sizes/band; **default OFF** (Weather=40 < 70); additive `set_weather`/`set_weather_month`/`snow_active` API; PORT APPROX white quad; smoke 405 ok / SCRIPT ERROR 0 / `t_fx3d` 13/13 |
| DPATTERN-01 | extract donor relief `.pattern` float32 height grids + relief props | `reports/DPATTERN_01_relief_grids.md` | ses_dee1bf81effeWBE5uL6hqyTxzP | **DONE** (652 lines) | 26 grids decoded, **all min/max match `pattern.lib` bit-exactly**, offsets/RLEs/8×10 downsamples; boundary offset variable (UNVERIFIED); 680 patterns Summer/Winter only; 8 `.osm` props inventoried, `actors.lib` has no scale field; engine sculpt blend UNVERIFIED → additive-clamp APPROX supplied |
| DFX-01 | donor `.pfx` / particle / effect formats and constants | `reports/DFX_01_pfx_effects.md` | ses_dee1bf81cffd1YtLzJTEP54Pa2 | **DONE** (805 lines) | PFX is ASCII OSW text, not binary; 44 source records / 24 effects / 5 managers / 22 materials / 90 DDS; `rand*` 1-based slots in 8-float array (`pfx.script:39-86`); weather snow system discovered (default Weather=40 inactive); **no construction dust** (sound-only; visible smoke = damage smoke); port FX approximates/omits every donor class |
| DANIM-01 | donor AAF action ranges → per-unit clip table | `reports/DANIM_01_action_ranges.md` | ses_dee1bf804ffeoBhNG92tSjntOG | **DONE** (627 lines) | 246 AAF / 1,434 rows / **62 action names**, duration `(last−first+1)/30`; state→action chain + 44-row clip table; **DEC-04 §6.1 refuted: 335/335 frame-0 identity** (max |p| 1.09e−6, peaukr skin f0 1.52e−7), DEEPDEC-06 F4/F5 confirmed; flat-root sampled poses remain defensible |
| DBIND-01 | decode `.bind`/WUS packed container or prove infeasibility (eye planes, FOV, selection predicate) | `reports/DBIND_01_wus_bind.md` | ses_dee1bf803ffeua5uURG6dHAiy1 | **DONE** | `.bind` = 768-B header + **plaintext 98.4%-shared x86 loader stub** + ~135 KB high-entropy payload; corrects DEC-01 "whole section opaque"; no container/members, no valid compression headers, no short XOR/ADD key; eye planes/FOV/selection predicate **CONFIRMED_INFEASIBLE** (byte-level proof), no invented values |
| QA-AUDIT-01 | independently audit implementation diffs vs claims/runner artifacts (read-only) | `reports/QA_AUDIT_01_implementation_claims.md` | ses_dee0b2406ffeK68vFf63t6vwMN | **DONE** | 10 CONFIRMED, 3 PARTIAL (superseded/cross-owner/diff-size), **0 prohibited patterns**, all 25 backups verified. **MEDIUM finding: integrated selftest NOT green** — HEAD 26/29 (`wall`/`shell`/`farm_cap`), worktree 28/29 (`build`), `config.json` committed at 240² with no MAP-SMALL-01 report landed; per-job 29/29 only valid for artifacts 312/337 |
| DFORM-01 | donor formations / squads / morale / AI truth | `reports/DFORM_01_formations_morale.md` | ses_dee0b2405ffedd66db3bi5eb3C | **DONE** (453 lines) | `mask` = glyph grid, 4-tuple `[bonusdamage,bonusshield,bonusdamagehold,bonusshieldhold]`; **morale CONFIRMED absent** (0 code hits in 2,559 files); disband `count<0.25*base` human-only; shooter retreat = move mode 2; port morale/XP/famine drain invented; 12-row gap table |
| DOC-02 | build authoritative donor corrections index | `CORRECTIONS.md` | ses_dee0b2404ffen2r14sdeaDhHJn | **DONE** (50 rows: 32 RESOLVED / 12 PARTIAL / 1 UNVERIFIED / 1 INFEASIBLE + 4 caveats) | canonical `CORRECTIONS.md` at swarm root; duplicate chains merged; 8 engine-side values listed as unresolved with DBIND-01 proof |
| RELIEF-01 | stamp 1–2 donor relief grids into `world3d_terrain.gd` (APPROX blend) | `reports/RELIEF_01_stamping.md` | ses_dee041eacffe8AmziUdnw7vNtf | **DONE** (purely additive +219/−0) | opt-in `dump["relief_stamps"]` reader + `apply_relief_grid()`, two DPATTERN Appendix A1/A2 coarse grids, additive-clamp labelled APPROX; all mesh invariants intact; smoke ticket 402 ok / SCRIPT ERROR 0 / 6/6; no marker producer → RELIEF-02 |
| RELIEF-02 | supply the producer-side `relief_stamps` marker (or prove blocked) | `reports/RELIEF_02_stamp_marker.md` | ses_dedfb1ccaffeAMoWKZXzQpo2jT | **DONE — PARTIAL** | `main.gd` now derives `dump["relief_stamps"]` from real `game.pattern_stamps`; `plt2` donor-grounded (`generator.cfg:588`, `pattern.lib:6805-6806`), `k_ravine_1` **BLOCKED** (absent from donor_patterns.json; `ravine_medium` disabled at `dogenerate.inc:1760`) — no marker invented; smoke 415 SCRIPT ERROR 0 | owns `main.gd` only; must not invent a marker or touch `game.gd` |
| SEASON-PLAN-01 | plan winter/desert tile-set swap (no code) | `reports/SEASON_PLAN_01.md` | ses_dee041eabffe0LyhMiLlEYwnWk | **DONE** (295 lines) |
| S1-INPUT-FIX | fix S1 atom's headless guard + input stretch scaling | `reports/S1_INPUT_FIX.md` | ses_dee041eaaffemOMKnaLzAzkZ4m | **DONE** | inverted headless guard (no fake PASS), root-window→projection coord transform, additive camera setup; windowed job 414 **PASS 23/23**, SCRIPT ERROR 0; 24/24 checks, 4/4 markers, 7/7 assert sites unchanged |

## Batch K — sustained 15–20 agents (owner directive 2026-11-25)

| ID | Scope | Output | Session id | State |
|---|---|---|---|---|
| P0-GATE-01 | replace inapplicable dark-row assert with strict applicable luma gates | `reports/P0_GATE_01.md` | ses_dedf3ea63ffeECY99Rl3aoHdKF | **DONE** | dark-row recorded N/A (water-band detector); added `ground_mean_luma>=40` + `ground_max_luma>=100` (PORT APPROX) so current frame fails 13.271/27.413; job 421 exit 1 as expected, SCRIPT ERROR 0, no weakening |
| TEST-RUN-02 | restart P0→C4 ladder after parse/cast repairs | `reports/TEST_RUN_02_ladder_log.md` | ses_dee010dfaffeNpGHZ3mNBAhY70 | **DONE — STOPPED AT P0** | job 404 windowed, 20 passes / 1 fail (`full_width_dark_rows=720`), PNG + stats in temp; SCRIPT ERROR 0; structural checks pass; P1–C4/S1/FINAL not run; no rerun/weakening |
| CLEAN-01 | resolve historical unacked variant queue failures → formal CLEAN verdict | `reports/CLEAN_01_variant_clean.md` | ses_dee010df9ffeo3hYBfem04rPDA | **DONE — NOT CLEAN (honest)** | 98 historical failures acked with PASS supersedes; 2 left unacked (failed, D-13 excluded); variant history signal clean; final tool DIRTY due to live job PID 4508 + tickets 408–413; **found `assert_clean.py:34` points at 2D spool** → CLEAN-02 |
| CLEAN-02 | make variant assert_clean.py use variant spool | `reports/CLEAN_02_variant_gate.md` | ses_dedf6d589ffeH65zVqsLXYLY19 | **DONE** | one-line `SPOOL` fix mirrors runner; validation DIRTY (correct during churn) with 411 history / 22 acks proving variant spool is read; gate signing deferred to COORD after drain |
| DUNIT-01 | donor unit roster / costs / build times / nation uniques | `reports/DUNIT_01_unit_roster.md` | ses_dee010df6ffe1sX9OM89Ld14OD | **DONE** (374 lines) | real stats in `unit.script:457-2647` + `country.script:2655-3116`; highlander = England 18c (not Austria/Hungary); port has **62** UNITS_BASE keys; 10 top missing uniques cited; pop cost UNVERIFIED |
| DAUDIO-01 | donor sound event→file mapping + emitter semantics | `reports/DAUDIO_01_sound_events.md` | ses_dee010de1ffeAtaCgmffcoct96 | **DONE** (36.5 KB) | 325/325 clips mapped; **selection sounds are interface-bank, non-positional** (`showunitcontrol.inc:1024-1027`); order ack all commented; 59 live indices, radii 25/50/75/100; port gaps: no spatial audio, no selection/ship sounds, 5 cannon families collapsed |
| DMAPGEN-01 | donor skirmish size/type/richness/relief/season/teams + seed chain | `reports/DMAPGEN_01_skirmish_options.md` | ses_dee010dd9ffemq8G2cB7yCyw8u | **DONE** | map sizes donor Tiny256/Normal320/Large480/Huge640 (port 240/320/400/480 mismatch); 6+3+Random shapes, 5 relief tiers, minerals 0–3, season ids 0/2/3 (no 1), teams+Allies, 64-bit seed chain with 11 stage reseeds/version gates; port mismatches ranked |
| DBUILD-01 | donor building stages / ghost / rally / smoke / debris | `reports/DBUILD_01_building_stages.md` | ses_dee010dcfffe76zzK0Ed0iFvY6 | **DONE** | 4 progressive stage meshes via `floor(progress*4)`, stage-synced scaffold, 2 death stages at 30/30 frames + debris, ghost dummy + blink, rally 3D object scale 0.0525/roll 45; smoke onset ≈88.75% HP; port stages/scaffold/death/debris missing |
| DOC-03 | cold-readable swarm README | `README.md` (swarm root) | ses_dee010dcbfferOSsuIoFLdxnln | **DONE** (240 lines, 6 sections) | resume order, folder map, green-job table vs unrun ladder, ownership discipline, failure register, topic-grouped report index; explicit honesty guard |
| ATLAS-01 | tile-atlas transport fallback + 180 MB LFS risk (read-only) | `reports/ATLAS_01_transport.md` | ses_dee010dc7ffecF1c4JXfZ9CmZO | **DONE** (222 lines) | split parts concatenate byte-identically to single PNG (SHA verified twice); fallback `single→split→array` only in default mode; no wired mode samples a different texture set; **big PNG IS LFS-tracked** (corrects V791) but split parts are ~180 MB ordinary blobs → clone size unchanged; fresh clone/remote LFS UNVERIFIED |

## Batch L — season swap tickets (from SEASON_PLAN_01, conflict-free index-preserving design)

| ID | Output / file | Session id | State |
|---|---|---|---|
| SP-1 | `variant3d/scripts/data.gd` (season enum) | ses_dedfd74ffffeHTsJ5EnxBF077b | **DONE — TERMINATED** (+16/−0, smoke 410 ok) |
| SP-2 | `variant3d/assets/terrain/atlas/winter_aliases.json` (new) | ses_dedfd74feffeDibklORyzBNNHS | **DONE** | 124 entries, indices 0–123 contiguous, order matches summer; 112→`winterN.png` (23 distinct), 12→reused desert PNG; all 27 winter PNGs inventoried, 4 deliberately unmapped; JSON valid, 8 invariants PASS; no parity claimed |
| SP-3 | `variant3d/assets/terrain/atlas/desert_remap.json` (new) | ses_dedfd74fbffetHME2e1XnbkU8z | **DONE** | 11 direct pairs + 1 height-gated `rock8`, donor-cited; JSON parse PASS, 12/12 source/target keys resolve; desert1..12 contiguous at 111–122; no art fabricated; runtime swap activity UNVERIFIED |
| SP-5 | `variant3d/scripts/tile_atlas_loader.gd` (optional manifest_path) | ses_dedfd74f0ffeOdmHGXEFUlnH6Z | **DONE** | optional `manifest_path` config key + field, used by `_load_grid()`/`_load_array()`; default path and single→split→array fallback byte-identical; smoke ticket 409 ok / SCRIPT ERROR 0 |
| SP-8 | `variant3d/tests/t_season_overlay.gd` (new atom, authoring only) | ses_dedfd74edffe3O0J5raV8YZZfW | **DONE** (1,057 lines) | three-variant dump-driven test; asserts manifest/UV2/tileblock parity + PNGs; `PENDING_DEP` until SP-4/SP-6; no runner/PASS claim |
| SP-4 | Winter atlas build tool + PNG + manifest (new files) | `reports/SP_04_winter_atlas.md` | ses_dedf28b67ffekBGYYokxLXUXeD | **DONE** (independent QA-WINTER-01 CONFIRMED) |
| SP-6 | `variant3d/scripts/world3d_terrain.gd` season hook | `reports/SP_06_renderer_hook.md` | ses_dedf28b63ffeWAnI54lgoZm6sz | **REPORT DELIVERED** (final sun smoke queued) |
| SP-7 | prop material `w` suffix in `world3d_entities.gd` | — | HELD (lower value; decide after SP-4/SP-6) |

## Batch M — global configurability (owner directive 2026-11-25)

| ID | Scope | Output | Session id | State |
|---|---|---|---|---|
| CONFIG-PLAN-01 | inventory all main features → JSON schema + UI subset | `reports/CONFIG_PLAN_01.md` | ses_deedf5ff08ffeOFoV2MzvR7dt58 | **DONE** (459 lines) | **55 features** inventoried with file:line + donor citation/APPROX + proposed `features.*` key/default/UI flag/owner; one additive nested schema with zero-break migration; UI subset = 3 present + 3 new; disjoint sequencing ladder MAP-SMALL→CORE→leaf readers→UI→COORD |
| CONFIG-CORE-01 | `variant3d/scripts/config.gd` feature defaults/readers | `reports/CONFIG_CORE_01.md` | ses_deedf5ff05ffddK8fAUfsQIvPd6 | **DONE** (+116/−0) | `FEATURES_DEFAULTS` 21 keys + new `"features"` top-level key + 21 typed getters; all defaults behaviour-preserving with donor/APPROX comments; `apply()` and every consumer untouched; smoke 419 ok / SCRIPT ERROR 0 |
| CONFIG-UI-01 | `variant3d/scripts/menu.gd` small donor-meaningful UI set | `reports/CONFIG_UI_01.md` | ses_deedf5ff02ffeQ59UJJmvCiT7bF | **DONE** (smoke 426 ok) |
| TERRAIN-DARK-01 | read-only diagnosis of near-black P0 terrain frame | `reports/TERRAIN_DARK_01.md` | ses_deedf5feeeffeY56zj3NrEhFbUO | **DONE** | dominant cause = donor-light axis mismatch in shader `:287-289` (flat ground dot(l,n)=0, diffuse=0); empty atlas cells/mask-alpha/texgen/camera refuted; owner file = shader; P0-GATE-01 records instrument fix separately |
| TERRAIN-DARK-FIX | correct donor light-space mapping in `terrain_tileindex.gdshader` | `reports/TERRAIN_DARK_FIX.md` | ses_dedec4474ffee1ghS4x7WOLRug | **REPORT DELIVERED** (job 441 P0 gates PASS; final LIGHT-02 patch re-capture queued) |
<!-- LIGHT-02 duplicate row removed (docs audit C3): authoritative DONE row above. -->
| CONFIG-WIRE-SEL | `variant3d/scripts/input_controller.gd` reads selection feature getters | `reports/CONFIG_WIRE_SEL.md` | ses_deded55fcffdeHoLLuv7C1Ha64 | **DONE** (windowed drag 23/23) |
| CONFIG-WIRE-WATER | `variant3d/scripts/water3d.gd` reads water feature getters | `reports/CONFIG_WIRE_WATER.md` | ses_deded55f7ffeItZoma2Ojf4IW9 | **DONE** (+26/−1) | three water getters with identical defaults, uniform/plane/coastfade lines byte-identical, 2 audit fields; smoke 433 ok / SCRIPT ERROR 0; non-default alpha_confine/shore_prox need future shader work |
| CONFIG-WIRE-HUD | `variant3d/scripts/hud.gd` reads minimap feature getters | `reports/CONFIG_WIRE_HUD.md` | ses_deded55f6fferXnzSP83DKAw1Z | **DONE** | three getter helpers with identical defaults, byte-identical panel partition/input/jump APIs; smoke 432 ok + uitest 440 **17/17** incl. bottom-right minimap; non-default corners remain a follow-up |
| CONFIG-WIRE-CAM | `variant3d/scripts/camera3d.gd` reads FOV getter | `reports/CONFIG_WIRE_CAM.md` | ses_deded55efffeih9fn1P7IwOwyu | **DONE** (+7/−0) | `fov = cfg.feature_camera_fov_deg()` inside existing null-guarded block, default 17.27 unchanged, PORT APPROX label kept; both jump APIs byte-identical (CAM-RV-01/MMJUMP-02 intact); smoke 429 ok / SCRIPT ERROR 0 |
| ASSET-IMPORT-01 | regenerate variant `.godot` cache for `mill_rotor.png` | `reports/ASSET_IMPORT_01.md` | ses_dede6d8deffe1OH2VxzryQlnyP | **DONE** | import job 444 ok/exit 0, +12 ctex generated, but target still absent; root cause: `assets/models/anim/.gdignore` excludes the source PNG so its leftover `.import` advertises a ctex Godot never makes; asset relocation routed to MOTION-ANIM-01 |
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

## Batch S — real-time status refill (4 → 20 live agents)

| ID | Session id | Scope | State |
|---|---|---|---|
| RECHECK-P0-01 | ses_dedbf5c9dffe4mdGt2dTO77GT1 | second-agent P0 capture re-check | RUNNING |
| RECHECK-S1-01 | ses_dedbf5c9cffeJGUuUd4kuM4BPJ | second-agent S1 selection re-check | RUNNING |
| QA-CONFIGJSON-01 | ses_dedbf5c99ffdcLRYgQ7OuQj3Zf | verify 21 JSON features keys vs config.gd defaults | **DONE — TERMINATED** (21/21 MATCH; `features` sole addition; map 240²) |
| QA-BOARDLIVE-01 | ses_dedbf5c7fffdEM7oUSBra4zAKe | board live-session list vs OpenCode DB | RUNNING |
| QA-LINKS-02 | ses_dedbf5c7bffdpJAj2a51MOZJ02 | LINKS_01 missing/stale citations re-check | RUNNING |
| DBUILD-02 | ses_dedbf5c78ffePdQ3lag7ysrYYr | independent donor building-stage verification | RUNNING |
| DONAVAL-02 | ses_dedbf5c76ffeCAAq15b0by5BNk | independent donor naval correction verification | RUNNING |
| QA-ATOM-STALE-02 | ses_dedbf5c74ffeDLQM3IjgeRqqcQ | stale atom result JSONs after DARKROW-ALL | RUNNING |
| BUILD-STAGES-01 | ses_dedbedb1effe077PkS0kvUcbKo | donor construction stages in `world3d_entities.gd` | RUNNING |
| FIELD-WINTER-01 | ses_dedbedb1dffeTXMw40zNTmaHX1 | standalone winter field-decal module (new file) | RUNNING |
| MORALE-PLAN-01 | ses_dedbedb1affeEuwiV0mWCxioor | plan removal of invented morale/famine constants | RUNNING |
| FINAL-CHECKLIST-01 | ses_dedbedaf9ffejr3WE6IIQbhDuF | final sign-off checklist | RUNNING |
| QA-CLEAN-02 | ses_dedbedaf1ffeK1luRvYOin2v5Y | variant CLEAN gate quiescent re-check | RUNNING |
| DENV-02 | ses_dedbedae6ffeRQKk1qsDCty2Xk | independent FogMode/sky-label verification | RUNNING |
| DANIM-02 | ses_dedbedae2ffeMiBmZSUTxXJ7z7 | independent AAF catalog / frame-0 verification | RUNNING |
| QA-DOCLIVE-01 | ses_dedbedadfffezftdXZw2t7S4St | living docs after latest reconciliation | RUNNING |
| GATE-FAIL-01 | ses_dedbb6506ffeTpu8SKK3Bt4lkC | diagnose banner-only gate startup failures | RUNNING |
| QA-RUNNER-ARTIFACTS-01 | ses_dedbb6505ffe0cw9EmKYeTG6zY | audit runner result records in failed gate window | **DONE — TERMINATED** | 46 tickets: 19 skipped / 10 ok / 10 failed / 7 NO_RECORD; 17 overtake skips at serving 461/465/475, 2 max-wait; 9 green ids CONFIRMED, 420/455/482 actually FAILED, 452/453 SKIPPED |
| README-FINAL-01 | ses_dedbb6501ffe1KC3EJCm7QQShu | refresh README with final reconciliations | RUNNING |
| SESSION-STATUS-FINAL-01 | ses_dedbb64faffevvN1Imbet9JkuQ | live/terminated agent count after refill | RUNNING |

## Batch T — UI/loading wave and latest small tickets (DB-tracked 11:44:52)

| ID | Session id | Scope | State |
|---|---|---|---|
| RECHECK-P0-FINAL-01 | ses_dedb263caffeB8vCUuZTlH981S | second-agent P0 re-check | **DONE** — P0 CONFIRMED_PASS, COORD may advance |
| BUILD-STAGES-01 | ses_dedbedb1effe077PkS0kvUcbKo | donor construction stages in `world3d_entities.gd` | **DONE** — stage logic, base-mesh APPROX, smoke 503 ok |
| QA-RUNNER-ARTIFACTS-01 | ses_dedbb6505ffe0cw9EmKYeTG6zY | failed-gate window audit | **DONE** — 19 skipped / 10 ok / 10 failed / 7 NO_RECORD |
| QA-UX-DOC-01 | ses_dedb412e9ffdNPzyYOjvAVhtV0 | UX/loading requirement coverage | **DONE** — 3 BLOCKERs (no acceptance table/tracking/probe) |
| SESSION-COUNT-02 | ses_dedb4114cffeXAplRGWQu4rtT2 | live/terminated count | **DONE** — 180 / 20 BUSY / 160 IDLE at 11:44:52 |
| DANIM-02 | ses_dedbedae2ffeMiBmZSUTxXJ7z7 | independent AAF/frame-0 check | **DONE** — 43 clip rows correct, 335/335 identity |
| PW-1 | ses_dedb8f593ffeWDu1dbADp9AvHh | 79-entry winter prop map | **DONE** — 18/18 validator checks |
| UI-TOPBAR-01 | ses_dedb5cfdbffe9rh6Oh2C7HL1zS | responsive top bar + speed dropdown (`hud.gd`) | **DONE — TERMINATED** | `hud.gd` +179/−34, width-driven normal/compact/tiny/ultra, one OptionButton, smoke 513 ok; minimap/camera BYTE-IDENTICAL; 17/17 UNVERIFIED (3 uitest attempts failed for foreign reasons); no weakening |
| LOAD-ASYNC-01 | ses_dedb5890affedzB6Lq8J5wNje9 | non-blocking load (`main.gd`) | RUNNING |
| HUD-LAYOUT-01 | ses_dedb52b4cffeblhZ66JpqnZBbj | `t_hud_layout.gd` atom (new) | RUNNING |
| UX-LOAD-DOC-01 | ses_dedb52b3dffeq7UoNBwvUrai4D | `UX_LOADING.md` | **DONE — TERMINATED** (201 lines, 8 sections) | R1–R7 requirement/evidence/owner/test table, 5 checklists, exact runner commands, failure policy; all rows PENDING until fix owners land |
| LOAD-PROBE-01 | ses_dedb412e9ffe8KZdustXtfybVD | `t_load_usability.gd` atom (new) | **DONE — TERMINATED** (578 lines, authoring only) | headless proxy calls real `_apply_menu_cfg()`+`_do_async_load()`, samples per-frame stalls and overlay-hide bindings, probes input/order/camera and post-hide stability; verdict MEASUREMENT_ONLY__NO_PASS_CLAIM; no runner job |
| QA-FINAL-02 | ses_dedb412e6ffeIL2yEUPB88PBxj | audit FINAL_CHECKLIST | RUNNING |
| UITOP-DONOR-01 | ses_dedb410ddffee5Z0et9eK34902 | donor resource-panel/speed truth | RUNNING |
| DARKROW-REPAIR-01 | ses_dedb39c7fffesXI0oQRGvC8haL | fix `_m` parse error in P1–C4 atoms | **DONE — TERMINATED / REDUNDANT** | DARKROW-ALL already fixed `_m` and rechecked 501; all 7 atoms parse (475/486/493/501/505/506/507); no source edit retained; stale `t_terrain_mines.json` false-green → P3-RESULT-CLEAN-01 |
| P3-RESULT-CLEAN-01 | ses_dedaa929cffeYeWHGSvh5MkRaq | quarantine stale false-green P3 result JSON | RUNNING |
| FAULT-DOC-01 | ses_dedaa9296ffeyuoq7pml3eXFrx | owner-fault index (terrain/nation/anim/UI/load) | RUNNING |
| MORALE-02 | ses_dedb39c25ffe2xKgTC1YfnxTvY | label-and-gate invented morale (`data.gd`) | RUNNING |
| RUNNER-FIX-01 | ses_dedb2bfb7ffeGYKFTfArhGNZvs | prepare runner mutual-exclusion patch (NOT applied) | RUNNING |
| QUEUE-DRAIN-01 | ses_dedb263a5ffeD4TCQiwc1cKQ5S | exact COORD-only final-gate sequence | **DONE — TERMINATED** (559 lines) | quiet queue observed (pending 0 / lock free / 0 Godot) but CLEAN still DIRTY with **17** unacked (new ticket 494 timed-out); 14 skips have verified supersedes, 452/453/494 deferred until fresh gates; full (a)–(h) commands + stop policy |
| BUILD-ART-01 | ses_dedaff9f1ffejPpOUO7ebnSLro | plan stage/scaffold OBJ conversion | RUNNING |
| SEASON-DESERT-01 | ses_dedb0f7b1ffenO3dHyk26Fqb6v | re-baseline 38-pair desert atom assertions | RUNNING |
| README-FINAL-01 | ses_dedbb6501ffe1KC3EJCm7QQShu | README final reconciliation | RUNNING |
| LINKS-FIX-01 | ses_dedb76937ffeZ7vR60RbEwA6FI | stale "absent" doc claims | **DONE — TERMINATED** | 3/4 stale groups corrected in owned docs; 6 orphan reports now cited in CONFIG_PIPELINE §1.1; README-only TERRAIN-DARK-FIX claim handed off; no verdict promotion |
| CLEAN-ACK-PLAN-01 | ses_dedb7155dffeO2V3LwwGWuwxPR | ack commands for 16 skipped jobs | RUNNING |
| BUILD-STEP-FIX-01 | ses_dedb6bb3dffe9gXQE3haVeunHp | integrated `build` step at 240² | RUNNING |

## Batch U — owner terrain/nation/animation faults (new directive)

| ID | Session id | Scope | State |
|---|---|---|---|
| TERRAIN-MARKS-01 | ses_dedad374cffeuB2gR1wtX0Mn4l | diagnose white marks / missing hills on generated map | RUNNING |
| NATION-DONOR-01 | ses_dedad374bffeoa00TVjmw4h396 | donor nation→unit/building/ship model mapping truth | **DONE — TERMINATED** (259 lines) | nation in unit sid; Russia/Ukraine share `rus*` common buildings, Bavaria `eur*` (`bavmil/bavpor` absent); ships family-keyed; port probes nonexistent prefixed OBJs (0/172) and base art is Ukrainian-derived; config-pass refuted as primary cause |
| NATION-FLOW-01 | ses_dedad3748ffdCUdfTh5DVBQ8xl | trace menu/config → game → entity sid nation value | RUNNING |
| NATION-MODEL-01 | ses_dedad36a5ffeWEolNmXHw5gRb0 | fix nation-based mesh selection in `world3d_entities.gd` | RUNNING |
| BUILD-ANIM-DIAG-01 | ses_dedad36a4ffeepl6ZZBhiWx4z4 | diagnose wrong peasant building animation | RUNNING |
| BUILD-ANIM-01 | ses_dedad36a0ffemPtLg8hEaT0m5j | fix build action mapping in `anim3d.gd` | RUNNING |

## Batch V — verification/planning refill (11 → 20 live)

| ID | Session id | Scope | State |
|---|---|---|---|
| QA-PATCH-VERIFY-01 | ses_deda1f2aafferuc6rt7Bo4rMX1 | verify applied runner patch vs approved diff | RUNNING |
| QA-GATE-READY-02 | ses_deda1f2a9ffe19gC3OywFrl8nO | fresh final-gate readiness | RUNNING |
| NATION-DATA-01 | ses_deda1f2a2ffem2UIrpVyBEPDM1 | plan rus/bav NATION_UNITS data | RUNNING |
| NATION-SPAWN-01 | ses_deda1f289ffekK7dLLS85R5Zei | plan nation-aware spawn sids | RUNNING |
| NAVAL-NATION-01 | ses_deda1f1c1ffdofVF07BacRyFG4 | plan naval nation art mapping | RUNNING |
| QA-UI-FIXES-01 | ses_deda1f1b0ffeyhYNjSlIM1bcg8 | verify top-bar/async-load landings | RUNNING |
| QA-RELIEF-ON-01 | ses_deda1f1adffer4w08Mf4gQo1mk | verify relief-stamps config flip | RUNNING |
| QA-SKIN-CONSTRUCT-01 | ses_deda1f1a9ffehEiHeZcB4SJjAB | verify construct skin export | **DONE — TERMINATED** | CODE-LEVEL PASS (one additive hunk, frames `[186,188,191,193,196,198]`), EXPORT-LEVEL NOT PASS (generated JSON still 7/5 actions, no construct) → BUILD-SKIN-02 |
| CORRECTIONS-REFRESH-01 | ses_deda3bd5affeOAhkz1zv9sFeyu | apply corrections index repairs | **DONE — TERMINATED** | 63 rows (46 R / 15 P / 1 CU / 1 CI), 0 reversals, contiguous ids, summary synced; rows 61–63 added |
| README-COUNT-01 | ses_ded9ec140ffejf6RYgDWB2Pwn6 | sync README corrections count to 63 | RUNNING |
| QA-LADDER-01 | ses_deda1f1a5ffe0s36ZCXs2cB85a | ladder row status after P0/stale-result changes | RUNNING |
| BUILD-ART-BATCH-01 | ses_deda076c9ffeGrLeyHmjrVWtkl | generate 108 stage/scaffold OBJs + manifest 172→280 | RUNNING |
| BUILD-SKIN-02 | ses_deda02916ffeiagMOXQfTZ5S5h | regenerate skin JSON with `construct` frames | **DONE — TERMINATED** | 55 exported/7 skipped, 56 JSONs backed up; peasant `construct` frames `[186,188,191,193,196,198]`, donor `peaukr.aaf:17`; 54/55 skins byte-identical; QA_SKIN_REGEN_01 JSON EXPORT PASS 9/9 |

## Batch X — final implementation/runtime checks (20-live refill)

| ID | Session id | Scope | State |
|---|---|---|---|
| NATION-SPAWN-IMPL-01 | ses_ded99b6fbffe5YkoyCEpjSGOIO | nation sid resolution for BATTLE_ARMY in `game.gd` | RUNNING |
| HUD-LAYOUT-RUN-01 | ses_ded9948b4ffdihVZGPzw4gbpvf | run `t_hud_layout.gd` atom | RUNNING |
| LOAD-PROBE-RUN-01 | ses_ded9948acffeUhYcFSDE1ndsVw | run `t_load_usability.gd` probe | RUNNING |
| RELIEF-VISUAL-01 | ses_ded9948acffdBy47HgCPgAEC6k | real generated-map capture with relief stamps on | RUNNING |
| QA-DESERT-FIX-01 | ses_ded9948a0ffdBoQFS42ZHXWjGU | verify desert float-index consumer fix | RUNNING |
| BUILD-STAGE-INTEGRATION-01 | ses_ded99489affee09KLS0Rxr5VYL | plan stage OBJ runtime hookup | RUNNING |
| QA-SPEED-01 | ses_ded994896ffeQ5hhZ4xdQrikIz | verify speed dropdown + donor divergence | RUNNING |
| STAGE-IMPORT-01 | ses_ded965563ffeTd4GzdVLeZkySd | Godot import sidecars for 108 new stage OBJs | RUNNING |
| SPEED-PLAN-01 | ses_ded9519d4fferiNLXZSykZmclx | plan donor speed-label/factor alignment | **DONE — TERMINATED** | donor labels Normal/Fast/Very Fast (factors 7/10/14, meaning UNVERIFIED); minimal 4-file plan (data.gd rename, hud.gd labels, main.gd refs, atom literal); blocked on data.gd owner until NATION-DATA-IMPL-01 lands |
| QA-STAGE-IMPORT-01 | ses_ded9519ceffeDeIcl54s5DuNEj | verify stage import sidecars | **DONE — TERMINATED** | DO NOT PROMOTE: 108 stage OBJs present but 0/108 `.import` sidecars, scaffold PNG no sidecar, 0 stage `.mesh`, import job 534 still queued; runtime load UNVERIFIED |
| NATION-DATA-IMPL-01 | ses_ded92c978ffeaCikHZ0mrllHvt | add Bavaria unit map to `data.gd` | RUNNING |
| RELIEF-LIVE-DIAG-01 | ses_ded925739ffexlkv9OmJ0wU5xr | diagnose live terrain relief/white marks in `game.gd` | RUNNING |
| QA-CONFIG-RESTORE-01 | ses_ded925737ffeWz7EJH80lLaxL5 | verify 21-key features restoration | RUNNING |
| QA-ATOM-RUNS-01 | ses_ded925736ffem9kFCbTFIvOb1n | verify HUD/load atom run results | **DONE — TERMINATED** | HUD FAIL 42/11/12 SKIP_CAPTURE, load MEASUREMENT_ONLY; only speed dropdown has positive runtime evidence; top-bar fit/window-movable/overlay-ready/no-post-load-blocking all UNVERIFIED; no promotion |

## Batch Y — targeted verification refill

| ID | Session id | Scope | State |
|---|---|---|---|
| QA-RELIEF-LIVE-01 | ses_ded8f1739ffeeLgNg98xhCjp6a | verify live relief root-cause ranking | RUNNING |
| QA-NATION-IMPL-01 | ses_ded8f1738ffeIkuAkIwdA7REWV | verify nation data/spawn/mesh fixes | RUNNING |
| QA-CONFIG-JSON-02 | ses_ded8f1737ffedGe5hJqGWWv29N | verify 21-key config restoration | RUNNING |
| QA-SPEED-ALIGN-01 | ses_ded8f1729ffebIdVoWdFsoXqcT | check speed alignment applied | RUNNING |
| OWNER-FAULTS-UPDATE-01 | ses_ded8f1725ffeleiFAq0aGePdYe | refresh owner-fault index | RUNNING |
| HUD-LAYOUT-REPAIR-01 | ses_ded8ac65dffe1sPKd4ME67DYVP | fix HUD atom tooltip drift + headless resize | RUNNING |
| LOAD-PROBE-REPAIR-01 | ses_ded8a5be1ffescfQgRv0hSlI2s | fix load probe format/overlay/camera capture | RUNNING |
| BLANK-CHECK-01 | ses_ded882c4affe3Kgh5f4gZ2cpTq | fix `_is_blank()` false rejection of olive frame | **DONE — TERMINATED** | content-based detector, final PNG written (job 549); post-hide 33.5 s spike BLOCKED as one-off cold cache (clean re-run max gap 22.6 ms, 0 violations); `main.gd` restored byte-identical, zero diagnostic tokens |
| WHITE-MARKS-PIX-01 | ses_ded87c3caffeVgigeaPI51T4G0 | pixel/tile-id analysis of reproduced white marks | RUNNING |
| QA-WHITE-MARKS-01 | ses_ded87c3c9ffeOloNvKFuVFDf6R | independent verification of white-marks fault | RUNNING |
| FINAL-CHECK-REFRESH-02 | ses_ded87c3c8ffeq4XUwC4VBXCqKQ | refresh FINAL_CHECKLIST with newest closures | RUNNING |
| OWNER-FAULTS-UPDATE-02 | ses_ded87c3c5ffedU6OIKid4vb25P | record reproduced white marks + UX atom results | RUNNING |

## Batch W — asset/fault verification refill

| ID | Session id | Scope | State |
|---|---|---|---|
| DESERT-CONSUMER-FIX-01 | ses_ded9c45f4ffe3Z4JWZzJG3Llab | accept 38 float-typed remap pairs in `world3d_terrain.gd` | RUNNING |
| QA-BUILD-ART-01 | ses_ded9bdeb3ffembA3TykFuvZeT7 | verify 108 stage OBJ batch | RUNNING |
| QA-RELIEF-DUMP-01 | ses_ded9bde89ffe84iY31WXA2ocy5 | verify relief dump probe | **DONE — TERMINATED** | RUNTIME UNVERIFIED: config flag true but no dump artifact; job 521 timed-out (190s > 180s hard timeout); only smoke 520 parse-ok; `k_ravine_1` BLOCKED, no visual hill A/B; corrected quoted-path probe 527 pending |
| QA-SKIN-REGEN-01 | ses_ded9bde88ffelcB0cv70MZkW6t | verify construct skin JSON | RUNNING |
| SESSION-COUNT-05 | ses_ded9bde82ffev3B2QRfQKLu4RM | live/terminated count | RUNNING |

## Batch R — documentation QA and config completion

| ID | Scope | Output | Session id | State |
|---|---|---|---|---|
| README-UPDATE-01 | refresh swarm README with late-wave findings | `README.md`, `reports/README_UPDATE_01.md` | ses_deddede29ffep3WHPBG8kRHQYW | **DONE** | 57-row corrections index, measured gate table, owner errors, P0 darkness, config pipeline, winter/LFS, donor map sizes; honesty guard kept |
| DECOMP-SUMMARY-UPDATE | refresh decomp summary + evidence index | `decomp/SUMMARY.md`, `decomp/EVIDENCE_INDEX.md` | ses_dedd30374ffe4Cebn5GF8S3Q8I | **DONE — TERMINATED** (13 new labelled subsections + 14 evidence rows) |
| INVENTORY-01 | independent re-count of donor inventories | `reports/INVENTORY_01_counts.md` | ses_dedd0b783ffeXGxtcSZa3SbA9o | **DONE — TERMINATED** (duplicate of authoritative Batch O row) |
| LINKS-01 | verify every report path cited by living docs exists | `reports/LINKS_01.md` | ses_dedd0b77affePHsOgnl49CI27l | RUNNING |

## Batch O — final small tickets (owner: keep 15–20 agents)

| ID | Scope | Output | Session id | State |
|---|---|---|---|---|
| AUDIO-SEL-02 | wire `audio.play_selection` at selection rebuild | `reports/AUDIO_SEL_02.md` | ses_dede47f36ffeaGALXfX3VRRfEG | RUNNING |
| CONFIG-WIRE-RELIEF | config gate for `dump["relief_stamps"]` in `main.gd` | `reports/CONFIG_WIRE_RELIEF.md` | ses_dede47f35ffeJtm9VwqT6yGQNB | RUNNING |
| WEATHER-DRIVER-01 | connect menu weather value → `world3d_fx.set_weather` | `reports/WEATHER_DRIVER_01.md` | ses_dede47f33ffejvS2MRfuAE33S6 | RUNNING |
<!-- CONFIG-DOC-01 duplicate row removed (docs audit C4): authoritative DONE row above. -->
| QA-PARITY-01 | re-verify integrated selftest/uitest/clean after all edits | `reports/QA_PARITY_01.md` | ses_dede47f21ffeN0cMxpshIcpAOZ | RUNNING |
| QA-CONFIG-01 | audit 21 feature getters naming/default/ownership | `reports/QA_CONFIG_01_getters.md` | ses_dede47f1effe4T2v9tVefZ0qDy | **DONE** | all 21 getters exist, all 19 call lines exact; 13 WIRED / 1 PENDING / 1 UI_EMITTED / 6 READER_ONLY at audit time; no `features` object in config.json; no default drift; naming/fog-namespace issues filed |
| CONFIG-DOC-01 | cold-readable config pipeline status | `CONFIG_PIPELINE.md` | ses_dede47f22ffehRBaIR2lYIXvrQ | **DONE** (32 KB) | 21-key status table (snapshot 7 WIRED/2 READER_ONLY/2 UI_ONLY/10 PENDING), 34 unwired remainder, menu subset with snow PORT-UI-ONLY, ownership ladder, risks; reconciles conflicting counts by snapshot time |
| MAPSIZE-01 | donor map sizes 256/320/480/640 in `menu.gd` | `reports/MAPSIZE_01.md` | ses_dede3a392ffe6P3B6Ttaon7o44 | **DONE — REVERTED** | donor sizes cited but both gates failed at startup (banner only, no report) while concurrent jobs failed identically; restored byte-identical; port sizes remain 240/320/400/480; gate startup failure needs diagnosis |
| DEFAULTS-VERIFY-01 | verify requested skirmish defaults (read-only) | `reports/DEFAULTS_VERIFY_01.md` | ses_dede3a38effe0Qb4qFvKwoJxy3 | **DONE** | all 7 requested settings resolve on BOTH paths: rus/bav, 240², mediterranean, hills, fog off, summer, 2 players/FFA; `map_type: land` present but **not applied** (DEFAULT merge sets `terrain_type`), so CFG-01 right in effect; CFG-02/QA-AUDIT F-05 refutation was wrong; config 320→240 came from MAP-SMALL-01 commit f9dd8d16 but its report never landed and integrated selftest is 28/29 |
| CONFIG-COUNT-01 | reconcile 7-vs-13 wired counts to current state | `CONFIG_COUNT_RECONCILED.md` | ses_deddede2dffelwKbQHsVHAMSe2 | **DONE** | authoritative **11 WIRED / 2 READER_ONLY / 2 UI_ONLY / 6 PENDING**; 7→13 delta decomposed exactly (HUD +3, relief +1, water vocabulary +2, mirror labels); **`config.json` has NO `features` object** → all getters return defaults, nothing user-tunable yet → MAP-SMALL-01 pinged to add it |
| README-UPDATE-01 | refresh swarm README with late-wave findings | `README.md` | ses_deddede29ffep3WHPBG8kRHQYW | **DONE — TERMINATED** (duplicate of authoritative Batch R row) |
| PERF-3D-01 | measure 3D sync/render hotpaths vs prior baselines | `reports/PERF_3D_01.md` | ses_deddede28ffePAlAptFGEy4kzn | **DONE** | current `sync_ms` 276.77 / 272.56 (jobs 477/500) ≈**2.04× regression** vs ticket 395 window 1 (134.54, different mode); top suspect `world3d_entities.gd` per-unit pose work + 19-tree jitter (inferred); per-stage attribution BLOCKED (no hook) |
| FINAL-GATE-PLAN-01 | exact ordered final-gate sequence + prerequisites | `reports/FINAL_GATE_PLAN_01.md` | ses_deddede23ffeu28mj7uzC2iIEH | **DONE** (243 lines) | prerequisites with session ids, ordered ladder P0→C4→S1 + final gate commands, failure policy, current-status snapshot; flagged dark-row asserts in sibling atoms → DARKROW-ALL-01 |
| DARKROW-ALL-01 | consistent dark-row applicability fix in P1–C4 atoms | `reports/DARKROW_ALL_01.md` | ses_deddb4a21ffeMNC2rRgf4X3t4F | RUNNING |
| CAPTURE-RECHECK-01 | second-agent capture re-check protocol | `CAPTURE_RECHECK.md` | ses_deddb4a1effeYYHgxFscIgnOeM | **DONE** (218 lines) | per-row artifact paths + exact `smallmap_capture.py` commands, P0→S1 criteria tables, image rules (no donor parity, metrics never override visuals), `RECHECK_<ROW>.md` recording, COORD-only ladder advance, failure attribution |
| QA-2D-GATES-01 | verify `app/` 2D gates still green | `reports/QA_2D_GATES_01.md` | ses_dedd673d5fferCfjOZUq5RuWOa | **DONE — CONFIRMED_GREEN** | selftest 29/29 (1348), uitest 17/17 (1349), CLEAN exit 0; 2D never intentionally edited today; no runner-state mutation |
| INVENTORY-01 | independent re-count of donor inventories | `reports/INVENTORY_01_counts.md` | ses_dedd0b783ffeXGxtcSZa3SbA9o | **DONE** | 76 claims re-counted: 72 exact + 1 scope note + 3 mismatches (root files 24 not 22; map field 55/32 not 53/27; `.inc` 455 whole-donor vs 313 under data/) → CORRECTIONS rows 58–60 |
| QA-WINTER-01 | independent verification of Winter atlas artifacts | `reports/QA_WINTER_01.md` | ses_deddad2fcffermyYWpkQC3rlTF | **DONE** | all artifact checks CONFIRMED (SHA/dims/124 indices/121 sources/12 pixel spot-checks); SP-6 path aligned in `world3d_terrain.gd:272-273`, SP-8 atom still swapped → SEASON-TEST-PATH-01; LFS stale-pointer precondition REFUTED (HEAD/index now hold new pointer); remote LFS UNVERIFIED |
| SEASON-TEST-PATH-01 | align SP-8 atom Winter atlas paths | `reports/SEASON_TEST_PATH_01.md` | ses_dedd5c6b9ffebY8CjZ2LHhmm8U | RUNNING |
| DSEASON-01 | donor winter/desert/field-crop visual truth | `reports/DSEASON_01_season_visuals.md` | ses_deddad2fbffekgmOL40gKn3638 | **DONE** | season swap = set/name/material not tint; winter preset uses shared `alpha0a/b/c`; **`_misc_SetDesert` has 38 active pairs vs port 11** → DESERT-REMAP-02; prop `w` art absent; donor winter field decal `envfieldd→envfielddw` not drawn; water/sky/fog season colours UNVERIFIED |
| DESERT-REMAP-02 | extend desert remap to all 38 donor pairs | `reports/DESERT_REMAP_02.md` | ses_dedc825e3ffeCybE4oju7Ds2Az | RUNNING |
| PROP-W-PLAN-01 | plan missing winter prop-material art | `reports/PROP_W_PLAN_01.md` | ses_dedc825dfffe65At77RG2CJO98 | **DONE — TERMINATED** | 79 donor `w` materials (72 DDS + 7 aliases), 321 props / 74 consumed; port 0/79 art; PW-1…PW-5 ticket ladder |
| PW-1 | 79-entry winter prop name map JSON | `reports/PW_01_material_map.md` | ses_dedb8f593ffeWDu1dbADp9AvHh | **DONE — TERMINATED** | 79 entries, 72 DDS + 7 aliases, 321 props/74 names, port 0/79; 18/18 validator checks; no art copied |
| DANIM-02 | independent AAF catalog / frame-0 verification | `reports/DANIM_02.md` | ses_dedbedae2ffeMiBmZSUTxXJ7z7 | **DONE — TERMINATED** | AAF 246/1434/62 CONFIRMED; frame-0 identity 335/335 CONFIRMED; DEC-04 misread reproduced bit-for-bit; clip table 43 CORRECT / 0 WRONG |
| PW-VERIFY-01 | independent recount of prop-winter claims | `reports/PW_VERIFY_01.md` | ses_dedb8f583ffeUzlq4aITt2b3HA | RUNNING |
| SP8-STATUS-01 | audit stale season-overlay atom + re-run spec | `reports/SP8_STATUS_01.md` | ses_dedc825deffegTIEqiL78uxsGw | RUNNING |
| GDIGNORE-01 | audit `.gdignore` stale imports / risky loads | `reports/GDIGNORE_01.md` | ses_deddad2f8ffemvAjexPoHMQOBy | **DONE** (138 lines) | 5 markers (not 3) excluding 5,192 files/~892.6 MiB; **2,097 stale `.import`/ctex** (anim 1,849 + sprites 179 + sprites_hi 69) systemic; six `world.gd` load sites reproduce rotor pattern (dormant in 3d, live under 2d override); mitigations proposed, no edits |
| RUN-GUIDE-01 | owner-facing launch/verify/troubleshoot guide | `RUN_GUIDE.md` | ses_deddad2e4ffecqus42qS3DYz5R | **DONE** (143 lines, 9 sections) | launch/gates/capture commands, expected PORT APPROX warnings vs genuine failures, current defaults, troubleshooting table; flags stale README `--stay` claim and reports selftest currently 28/29 (`build`) |
| QA-DOCS-01 | audit today's reports for evidence/cold-readability | `reports/QA_DOCS_01.md` | ses_deddad2e3ffe4Cyl6fHeoh0yfz | **DONE — TERMINATED** (169 lines; 3 BLOCKERs fixed in living docs) |
| DONAVAL-01 | donor naval/ship assets truth (skirmish scope) | `reports/DONAVAL_01.md` | ses_deddad2dfffeiq7NfEV7bZUays | **DONE** (282 lines) | 9 hull `.osm`, 6 crew `.oss`, sails/flags/paddles, 10 skins incl. alternate xebeca; 7 corrections (skins present, crew 5/6, tiers=production gates, radii 1.31–3.38 m, `convert_models.py` shipyard claim false); new construction/port-scan behaviours; port has no naval entity layer/production/stats/AI |
| QA-ATOM-RESULTS-01 | audit atom result JSONs + manifest consistency | `reports/QA_ATOM_RESULTS_01.md` | ses_dedcdf2c3ffeeNnd0m5fmCmM6R | RUNNING |
| LFS-PLAN-01 | winter atlas LFS/clone-size plan (read-only, no git changes) | `reports/LFS_PLAN_01.md` | ses_dede3a38bffee774616xhEtemx | **DONE** | `.gitattributes:1` already LFS-tracks `*.png`, git-lfs 3.4.1 installed; owner `git add` rewrites pointer to new oid (no track edit); recommended LFS option; **fallback trap**: Winter single-load failure silently uses Summer art because `SPLIT_MANIFEST` is Summer-only; path mismatch remains SP-6's |

## Batch AB — cursor-tip, HUD width, mask bleed

| ID | Session id | Scope | State |
|---|---|---|---|
| HUD-CAPTURE-FIX-01 | ses_ded718d5affedFg5DLDREIhcb1 | fix HUD atom nonblank guard | **DONE — TERMINATED** | nonblank guard replaced with proven content-based metric, `_check_size` byte-identical, validation job queued/running; no weakening |
| HUD-LAYOUT-REPAIR-01 | ses_ded8ac65dffe1sPKd4ME67DYVP | fix HUD atom drift + headless resize | **DONE — TERMINATED** | 3 tooltip literals fixed, real viewport-base retarget (ui_vp correct at 3 sizes), job 548 55/7/3; remaining 4 layout FAILs are REAL top-panel overflow at 1024/1280 → hud.gd owner; 3 capture failures were atom metric bug (HUD-CAPTURE-FIX) |
| RCODE-FIX-01 | ses_ded6c6016ffekmUVaN8qV6g5fa | exact donor R-code decode in `mapgen.gd` | **DONE — TERMINATED** | exact 8-code decode + `relief_smooth` data key, 6 divergent codes corrected (max error 8.7e-8), smoke 558 + probe 564 PASS, determinism identical, no smoothing kernel invented, no parity claim |
| SELFTEST-ALL-FIX-01 | ses_ded75cb85ffeXbyTVeEgii5m4S | all 29 steps at 240² (harness geometry) | **DONE — TERMINATED / 29/29** | ticket 567 ok, selftest 29/29 at 240²; wall/shell/farm_cap/flee fixed by harness staging, no assertion/threshold/seed change; diagnostics removed byte-identically |
| MAP240-APPLY-01 | ses_ded556584ffeQ6ryjwOHcZGbQq | set 240² default + fresh gates | **DONE — TERMINATED / GREEN** | 240×240 default applied (2 value lines), full 21-key features + relief true preserved; ticket 568 selftest **29/29**, 569 uitest **17/17**, both ok exit 0, queue free; no weakening; 2D untouched |
| CLEAN-FINAL-01 | ses_ded4ec211ffeEaWKf7vZqDoaq5 | ack remaining 8 with evidence + clean verdict | **DONE — TERMINATED** | 6 evidence-backed acks; 516/538 left unacked by owner (no argv-identical supersede) then acked by COORD policy with honest retirement reasons; final `assert_clean` exit 0 CLEAN, 0 processes, free lock |
| COORD-FINAL | (current session) | sign functional gates at end of day | **SIGNED — FUNCTIONAL ONLY** | 568 29/29 · 569 17/17 · assert_clean CLEAN exit 0; visual donor A/B + P1–C4 rows still UNVERIFIED |
| FINAL-AUDIT-01 | ses_ded4e63eaffeQNS3oWMcqnKVa7 | whole-tree sign-off audit (read-only) | **DONE — TERMINATED** | NOT_READY on real blockers (ladder P1–C4 unrun, no donor A/B, no owner visual, no RECHECK_P1..C4, S1 no PNG); its DIRTY/5-unacked claim is STALE (snapshot before final acks) — see COORD CLEAN exit 0 |
| FINAL-CHECK-REFRESH-03 | ses_ded48def8ffeBwDpZr5HsYqX9a | refresh checklist to green functional gates | **DONE — TERMINATED** | 8 items promoted with COORD evidence; counters 34 DONE / 12 PARTIAL / 16 OPEN; verdict FUNCTIONAL GATES SIGNED — FULL ACCEPTANCE NOT COMPLETE; §0 byte-identical |
| QA-2D-FRESH-01 | ses_ded489f67ffeKuV4Jpn4bK74vK | fresh 2D gate verification on current tree | **DONE — TERMINATED / CONFIRMED_GREEN** | ticket 1350 selftest 29/29, 1351 uitest 17/17, both ok/exit 0; 2D assert_clean CLEAN exit 0; `app/**` untouched |
| MINIMAP-TIP-DIAG-01 | ses_ded727789ffeHfL9Qb8F2Jhf22 | donor click→arrow-tip vs center diagnosis | **DONE — TERMINATED** | donor deliberately offsets camera target by boom (32.09/54.59/92.91 m at h=20/34.06/58); `crDefault` hotspot (0,0)=arrow tip, GUI X/Y is tip world point; port primary click already calls offset API, plain `jump_to_world()` centers and stays byte-identical; which "arrow" is open; no parity without A/B |
| MINIMAP-TIP-01 | ses_ded72776dffeR0mlRpufSUqUMZ | cursor-tip mapping + narrow-width top bar | **DONE — TERMINATED** | no speculative camera change (donor already offsets boom; `jump_to_world()` byte-identical); real fix `hud.gd:_layout_top` thresholds 1000/700/560→1500/1100/800 + pads; windowed HUD-layout atom ticket 562 **PASS 62/62**, 0 unclipped offenders at all sizes; tip landing UNVERIFIED |
| MASK-ALPHA-FIX-01 | ses_ded70f8b4ffeJfCdyT6f0SscE8 | stop sky bleed through terrain alpha mask | **DONE — TERMINATED** | 3 shader hunks: mask folded into RGB combine, `ALPHA=1.0`; smoke 556 6/6; real-map 563 final PNG; near-white **44,381→6,989 (−84.25%)**, exact cyan below sky strip **~32,744→0**; donor blend engine-side UNVERIFIED, no parity claim |
| HUD-CAPTURE-FIX-01 | ses_ded718d5affedFg5DLDREIhcb1 | fix HUD atom nonblank guard | **DONE — TERMINATED** | content-based guard reloads saved PNG, 3 gates PASS at all sizes, job 554 58/4/3; 4 remaining FAILs are real top-bar overflow; SCRIPT ERROR 2 from concurrent selftest.gd `slot` bug (owner notified) |
| RELIEF-SEED-SCAN-01 | ses_ded6a8bf1ffeWHSfm7v3f5g5wn | find seed that actually places donor relief stamp | **DONE — TERMINATED** | offline seed **20261150** / relief `plains` → `plt2` at (54,33), candidates 1 / applied_cells 443; alternates 20261168/20261181; replay validated 8/8 stamp counts on baseline seed; runtime UNVERIFIED |
| RELIEF-SEED-PROBE-01 | ses_ded600a2effeOZFZwYwRy16sjJ | runtime dump probe for seed 20261150 | **DONE — TERMINATED / CONFIRMED** | job 565 ok, SCRIPT ERROR 0; `plt2` at (54,33), candidates 1 / applied_cells 443, height+tileblock SHA changed (cell-level writes), min/max unchanged as predicted; visual A/B / donor parity still UNVERIFIED |
| PALE-TILES-DEEP-01 | ses_ded837a94ffeSMzceWm3VhZt7O | donor pale tile art / white marks deep dive | **DONE — TERMINATED** (543 lines) | 3 passes over 112 DDS: no summer family pale (L 66–119, minRGB>180=0%); winter-white absent from frame; bands = olive→sky mix α≈0.27–0.31 from one-pass `blend_mix` mask-as-alpha at shader:469; 786/3413 flat cells hit constant/low alpha patches; not tile albedo, not relief |

## Batch AC — final gate cleanup

| ID | Session id | Scope | State |
|---|---|---|---|
| QA-GATE-READY-03 | ses_ded85b8ffffe8l6oUhEo26pwla | fresh final-gate readiness | **DONE — TERMINATED** | NOT_READY with 11 blockers (selftest 28/29, DIRTY, 21 unacked, ladder unrun, no owner visual/A-B) |
| CLEAN-ACK-EXEC-01 | ses_ded541c59ffeKY5AflBATHsphF | ack 14 resolved historical skips | **DONE — TERMINATED** | 14/14 acks exit 0 with verified `ok` supersedes; unacked 22→8, acknowledged 18→32; DIRTY remains queue-dependent + 8 out-of-scope entries |

## Batch AA — fix verification refill

| ID | Session id | Scope | State |
|---|---|---|---|
| QA-BLANK-FIX-01 | ses_ded78f69dffeHBqZq9JNYZDSQA | verify `main.gd` blank-check replacement | **DONE — TERMINATED** | content-based symmetric criterion CONFIRMED (non-black/luma-range/distinct-colours), olive frame PASSES, black/uniform/two-colour controls FAIL, final PNG written by job 549 (non-black 0.999136, luma 114.972, 0 dark rows); no parity claim |
| QA-RELIEF-FIX-01 | ses_ded78f69dffdYTPLJrfd4tLDfN | verify donor-grid relief in `game.gd` | RUNNING |
| QA-BUILD-ART-C-01 | ses_ded78f699ffe5iTb4ZimipC4bB | verify stage mesh runtime integration | **DONE — TERMINATED** | NOT_VERIFIED__TICKET_IN_FLIGHT: 4 partial hunks (bbox/tint/labels) in HEAD, C4/C6 not observed, selector/rotor/nation/build/tree/motion byte-identical, no test edits, no parity claim |
| PATTERN-STAMP-DEEP-01 | ses_ded837aabffddkfZI25InbqAeY | donor relief pattern grid stamping deep dive | **DONE — TERMINATED** (526 lines) | patterns = float32 height deformation (5 decoded, zero mountain props); mountains = separate `terrainmeshN` props; blend native UNVERIFIED; no donor pattern writes pale tile ids — detail bitmaps do (`test7/8` bright speckles); 12 port mismatches with owners |
| QA-HUD-REPAIR-01 | ses_ded78f66dffe6dKfruXx2Np35x | verify HUD atom repair | RUNNING |
| QA-LOAD-REPAIR-01 | ses_ded78f669ffetlSZrqnXO7HFll | verify load probe repair | **DONE — TERMINATED** | confirmed `%d` fix, overlay first-frame sampling (28 frames, hide at 29), camera request/response, stability reached at 60 frames; 11 violations / 33.5 s breach reported honestly; no criterion relaxed; MEASUREMENT_ONLY retained |
| BUILD-STEP-FIX-01 | ses_dedb6bb3dffe9gXQE3haVeunHp | fix `build` selftest step at 240² | **DONE — TERMINATED** | root cause `_spot()` clearance 2.2m vs real slot 5.44m; fix made `build` green, but ticket 546 still 25/29 (`wall`,`shell`,`farm_cap`,`flee`); no weakening, wider harness scope needed |
| SELFTEST-ALL-FIX-01 | ses_ded75cb85ffeXbyTVeEgii5m4S | fix remaining 4 steps at 240² (harness geometry) | RUNNING |

## Batch Z — donor terrain deep dive + live relief fix

| ID | Session id | Scope | State |
|---|---|---|---|
| HEIGHT-GEN-DEEP-01 | ses_ded837aabffejfLh3ybomrgH2n | donor height generation + R-code deep dive | RUNNING |
| PATTERN-STAMP-DEEP-01 | ses_ded837aabffddkfZI25InbqAeY | donor relief pattern grid stamping | RUNNING |
| RCODE-DEEP-01 | ses_ded837a9bffeYmWl0s7Ixk0Ee1 | donor R-code decode vs port relief() | RUNNING |
| PALE-TILES-DEEP-01 | ses_ded837a94ffeSMzceWm3VhZt7O | donor pale tile art / white marks | RUNNING |
| RELIEF-LIVE-FIX-01 | ses_ded82909fffepIVj8kwz08Eghk | live donor-grid relief in `game.gd` | **DONE — TERMINATED** | +134/−6: verbatim 8×10 `plt2`/`k_ravine_1` grids + donor scale/min/max, bilinear stamp into `game.height`, analytic fallback unchanged; smoke 550/dump 551 ok, SCRIPT ERROR 0; **runtime BLOCKED** (seed 20261113 gives `relief_stamps: []`, applied_cells=0, height unchanged); protected blocks byte-identical; no parity claim |
| QA-TERRAIN-DEEP-01 | ses_ded7e947dffew1KSLzC6c8tT7B | cross-check donor terrain deep dives | **DONE — TERMINATED** | INCOMPLETE_INPUT: four Batch-Z deep dives not landed at 11:46:13Z; consensus table from five landed support reports; 8 staleness conflicts logged (line drift ~40–55, live owner `game.gd`, flag now true) |
| QA-NATION-MODEL-01 | ses_ded7e9478ffeR1fBlcubpD4At9 | verify nation model integration/probe | RUNNING |
| NATION-MODEL-01 | ses_dedad36a5ffeWEolNmXHw5gRb0 | nation mesh selection + build-action in `world3d_entities.gd` | **DONE — TERMINATED** | +205/−3; donor building prefix rule; unit selectors fixed, buildings/naval BLOCKED (0 nation-keyed OBJs), Ukrainian look NOT visually fixed; build/repair→construct branch; smoke 543 + probe 544 ok; protected blocks byte-identical |
| BUILD-ART-C-01 | ses_ded7a7ed3ffeVKh7QK500EOKfH | runtime integration of stage meshes in `world3d_entities.gd` | **DONE — TERMINATED** | +24/−11, 5 hunks; per-stage bbox + tint re-apply + honest labels; smoke 552 ok; probe 553 ok **14/14** — 280/280 meshes load as Mesh, stage swap + scaffold tints verified; no visual/parity claim; completion scaffold/death stages out of scope |
| NATION-DATA-IMPL-01 | ses_ded92c978ffeaCikHZ0mrllHvt | add Bavaria unit map to `data.gd` | **DONE — TERMINATED** | one donor-grounded line (`serdiuk→musketeer`, `cossack→hussar`), byte-proof 1 insert/0 deletes/replaces, `rus`+morale banners byte-identical, smoke 542 ok/parse-only; runtime mesh proof UNVERIFIED |
