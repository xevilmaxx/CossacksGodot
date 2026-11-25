---
title: CORRECTIONS — authoritative index of 2026-11-25 donor corrections
area: coordination
owner: COORD (aggregates worker and decomp lanes)
updated: 2026-11-25
status: living
charter: donor-is-truth; cite the authority row, never the superseded claim
parent: CHARTER.md
---

# Corrections index — 2026-11-25 donor findings

## Goal

One cold-readable table that resolves the corrections produced by today's donor swarm.
Each row names the **old claim**, where it was written, the **current truth**, the
**authoritative report + evidence id / `path:offset`**, how many independent passes
support it, and its status. Duplicated corrections (FOV, frame-0 bind pose, `hmapTex`,
alpha complement) are merged into a single row so that no stale half-truth survives.
This file does not add new donor findings; it only indexes existing, cited ones.

## Sources

Paths below are relative to `docs/coord_swarm_2026-11-25/`.

- Coordination: `CHARTER.md`, `PROGRESS.md`, `GAPS.md`, `reports/DOC_01_all_docs_synthesis.md`.
- Decomp lane: `decomp/SUMMARY.md` (§9 correction list), `decomp/EVIDENCE_INDEX.md`,
  `decomp/DEC_01_binaries_rtti.md` … `decomp/DEC_08_ui_strings.md`.
- Re-verification / deep dives: `reports/RV_SEL_01_selection_reverify.md`,
  `reports/RV_CAM_01_fov_resolution.md`, `reports/RV_TRN_01_texgen_mask_reverify.md`,
  `reports/RV_TRN_02_smoothing_rules.md`, `reports/RV_TRN_03_water_bindings.md`,
  `reports/DALPHA_01_alpha_subrect.md`, `reports/DBIND_01_wus_bind.md`,
  `reports/DANIM_01_action_ranges.md`, `reports/DENV_01_environment.md`,
  `reports/DTRN_01_donor_terrain_pipeline.md`, `reports/DTRN_02_donor_terrain_geometry.md`,
  `reports/DTRN_03_donor_shore_water.md`.
- Donor root (read-only, never executed or copied): `C:\Games\Cossacks 3\`.

Status legend: **RESOLVED** = old claim refuted or replaced by cited readable evidence;
**PARTIAL** = geometry / literal recovered, selection rule or runtime binding still unknown;
**CONFIRMED_UNVERIFIED** = exhaustive readable search found no value, none invented;
**CONFIRMED_INFEASIBLE** = `DBIND_01` proves no static read-only route recovers the value.

## Corrections table

| # | Old claim | Old source | New truth | Authority (report + evidence id / `path:offset`) | Verification passes | Status |
|---:|---|---|---|---|---|---|
| 1 | `.exe` entry VA `0x8f1a08` is in `.bind` | `docs/decomp/DA_PE.md`, `DECOMP_01` | Only the `.cdx` entry is in `.bind`; the `.exe` entry RVA `0x4f1a08` is in `CODE` | `decomp/DEC_01_binaries_rtti.md §9 #1` (`D1E02`, `D1E03`, `D1E09`, `D1E10`; `cossacks.exe:0x128` = `08 1a 4f 00` vs `.cdx` `10 c3 56 00`); `reports/DBIND_01_wus_bind.md §6 #5` (VAs `0x8f1a08` / `0x96c310`) | 3 (struct parse + hexdump + section membership over 8 files), plus independent hash | RESOLVED |
| 2 | `.cdx` is a different or protected engine build | `DA_PE.md`, old PE notes | Same file byte-for-byte except the 3-byte entry-point redirect; the same `.bind` bytes are in the `.exe` | `decomp/DEC_01_binaries_rtti.md §9 #2` (`D1E09`, `D1E11`) | 2 (full-byte diff + SHA-256) | RESOLVED |
| 3 | "Rich header ⇒ MSVC toolchain" for the game EXEs | old PE toolchain notes | "Rich" hits are the substring in "Pierre le Riche"; only `codex.dll` has a real Rich header | `decomp/DEC_01_binaries_rtti.md §9 #3` (`D1E07`, `D1E20`, `D1E26`; `cossacks.exe:0x86b6`) | 2 | RESOLVED |
| 4 | "six donor PE files" | `DA_PE.md` six-PE table | 19 PEs found by recursive MZ/PE scan; `DEC-01` calls the omission a scope difference, but the count claim is wrong | `decomp/DEC_06_map_formats.md §6 #6`; `decomp/DEC_01_binaries_rtti.md §9 #6` (`D1E07`, `D1E12`, `D1E13`) | 2 | RESOLVED |
| 5 | `.bind` is uniformly high entropy; the `+0x310` stub is not statically readable | `decomp/DEC_01_binaries_rtti.md §4/§7/§12` | Three regions: 768-B per-binary header, 11,264-B shared plaintext x86 loader (98.4 % identical across four EXEs), ~135 KB opaque payload; only the payload is genuinely unreadable | `reports/DBIND_01_wus_bind.md §6 #1–#3`, `§8` (`cossacks.exe:0x55c600..0x55c8ff`, `:0x55c900..0x55f1ff`, `:0x55f200..0x58036f`; API hash `0x488781ed` @`:0x55d804`) | 5 independent read-only methods | PARTIAL |
| 6 | Camera and selection `.inc` control scripts are commented-out source | `decomp/DEC_07_cameras_shaders.md §8.1`; `DEEPDEC-01 §3` | `[*] = ;` is a live `Code`-struct string-list marker; only `//` and `{ }` are real comments; files are registered in `menu.aix` and bound by `menu.cfg` | `reports/RV_SEL_01_selection_reverify.md §Corrections #1`, `§Summary` (136 GUI `.inc`, 39,074 lines, 0 exceptions); `reports/RV_CAM_01_fov_resolution.md §Corrections DEC-07` (`menu.cfg:3,14,22,27`; `menu.aix:1-5,36-41,83-88,90-95`) | 4 (byte format + registration + binding + 136-file generalisation) | RESOLVED |
| 7 | DEC-07's correction: G31/V711 FOV arithmetic is numerically wrong; 5.153°/30.219° replace 2.90°/17.27° | `decomp/DEC_07_cameras_shaders.md §8.3` | DEC-07's correction was itself wrong: it treated horizontal sensor widths as vertical. 2.90° and 17.27° are the correct 16:9 **vertical** FOVs for 36 mm and 216 mm **horizontal** sensors at f=400; 5.153°/30.219° are the corresponding horizontal FOVs | `reports/RV_CAM_01_fov_resolution.md §Verdict`, `§Corrections DEC-07 §8.3`, `§Recommended value` | 3 (independent arithmetic + float32 census + API declaration census) | PARTIAL |
| 8 | "No FOV token in donor"; the shipping camera's FOV is demonstrably computed at runtime from focal + viewport dimension | `DSEL-02` claim 2; older docs | API declarations exist (`cossacks.exe:0x1fe0e6`, inverse `:0x1fe158`, `ArcTan` `:0x209cc6`), but there are 0 donor script call sites and no sensor/film-gate constant → call path UNVERIFIED | `reports/RV_CAM_01_fov_resolution.md §Verdict`, `§Corrections DSEL-02/V790`; `decomp/EVIDENCE_INDEX.md` (`0x1fe0ef`, `0x1fe168`) | 2 (whole-tree search + byte census) | PARTIAL |
| 9 | `FOV_DEG_ASSUMED=17.27` is a donor literal, or must be changed to 5.15°/30.22° | DEC-07 debate, port assumption notes | Keep 17.27° as a labelled **PORT APPROXIMATION** (216 mm horizontal sensor at 16:9, f=400); 2.90° is the secondary A/B candidate; 5.15°/30.22° are H-FOVs, not V-FOV candidates | `reports/RV_CAM_01_fov_resolution.md §PORT APPROXIMATION`, `§Recommended value`, `§Summary` (V790 measured `fov=17.270000`) | 2 (arithmetic coherence + measured baseline) | PARTIAL |
| 10 | `TILE_M=2.0` is port-only; no donor metres-per-cell constant | `reports/DTRN_01_donor_terrain_pipeline.md` C6; `P8 §3`, `P14 C6/Q1` | Donor constant `gc_meters_to_tile = 2` (`dmscript.global:171`, px/m `:170`, px/tile `:172`); the 2 m cell is donor-grounded | `decomp/DEC_05_terrain_formats.md §6 #1` (N11); `decomp/EVIDENCE_INDEX.md` (`dmscript.global:171`) | 2 (DEC-05 two-way + port read) | RESOLVED |
| 11 | No donor file contains a tile-index array | `reports/DTRN_01_donor_terrain_pipeline.md` C2; `P14 C2` | `.map` `TerrainMapBegin` carries 102,400 × 37-byte per-cell records; a grid exists, but field semantics remain UNVERIFIED | `decomp/DEC_05_terrain_formats.md §6 #2` (N7 `ausmis1.map:0x012f63ee`, N8 `0x014f4a3d`); `decomp/DEC_06_map_formats.md §6 #1` | 4 maps + 3 independent maps | PARTIAL |
| 12 | Donor grid numeric geometry is opaque / CLOSED; heights are ±2.964 in every map; records are 8,777 × fixed 31 B; field 4 is tile size 64 px | `DD`, `DECOMP_06`, `DEEPDEC-05` | All four refuted: height/tile/coordinate/entity records are decodable; `battle1.map` max +2.3712; records are `24 + nameLen` (28–32 B); 27/87 maps store `25920` in field 4 | `decomp/DEC_06_map_formats.md §6 #1–#4` (3 maps + 87-map survey) | 3 maps + 87-map census | RESOLVED |
| 13 | `random.cfg` holds the skirmish seed | old seed notes | `random.cfg:2` is only `field = fax`; the seed chain is `GenerateMapRandKey` → `gMap.settings.gen.randkey0/1` → three RNG setters | `decomp/DEC_06_map_formats.md §6 #9`, `§7.1` (`donewgame.inc:16,33-35,37`) | 2 | RESOLVED |
| 14 | Frame 0 is not a bind pose for multi-bone `.oss` files (`peaukr` 0.09912 m, 0 of 22 `b=20`); P2's 1.6e−7 m is not reproducible | `decomp/DEC_04_anim_formats.md §6.1` (`:422-441`); `decomp/SUMMARY.md §4/§9` (stale) | DEC-04 was wrong: it read bone-major tracks as frame-major. 335/335 files have frame-0 identity (max position error 1.09e−6 m, max quaternion error 3.02e−8), including 22/22 `b=20`; the 1.6e−7 m skin displacement is reproducible (1.52e−7 m). DEEPDEC-06 F4/F5 stand at deformation-data level; native engine skin form and visual A/B still UNVERIFIED | `reports/DANIM_01_action_ranges.md §6.2 methods A/B/C`, `§7` (`bake_sprites.py:91-103,118-129`; DEC-04 numbers reproduced as an indexing artifact in method C) | 3 (sequential reader + whole-family offset-seek census + artifact reproduction) | RESOLVED |
| 15 | "733/733 skin vertices changed" | `V774`, `V778`, `AUDIT3D_TRIAGE` | 733 = OBJ `vt` / de-indexed rendered corners; donor `.oss` has `v=577` | `decomp/DEC_04_anim_formats.md §6.2` (`peasant.obj` 577 v / 733 vt); `reports/DANIM_01_action_ranges.md §7` | 2 | RESOLVED |
| 16 | DLC5 terrain gate `<90` and random type range 6 | `P1 §2.2`, `G3` | Gate `<91`; range 9 | `decomp/DEC_02_scripts.md §7 #2` (`dogenerate.inc:1547-1558`, `:1557`, `dmscript.global:236`) | 2 | RESOLVED |
| 17 | Donor scripts are plain UTF-8 | `P1 / DB_SCRIPTS §1` | 19 of 222 files are ASCII code with CP1251 Russian comments; strict UTF-8 decode fails | `decomp/DEC_02_scripts.md §7 #1` (`ev_462f7a31…`, `ev_4ead67fc…`, `ev_c8cf3d2d…`) | 2 (strict decode + byte census) | RESOLVED |
| 18 | "243 donor hotkey bindings" | `DECOMP_04_strings_config.md:129`, `CONFIG_EFFICIENCY.md:129` | 243 lines, **55 bindings** (52 keyed, 3 deliberately empty) | `decomp/DEC_03_configs.md §5 C1` (`hotkeys.cfg:1–243`; E04) | 2 independent counts | RESOLVED |
| 19 | 43 non-zero formation bonus records; bonuses not consumed | `DB_SCRIPTS.md:93`, `P1 G2/DB-01` | 46 non-zero of 149, non-uniform tuples; bonuses are consumed and fully imported (149/149, diff 0) | `decomp/DEC_03_configs.md §5 C2/C5` (E06, E07); `decomp/DEC_02_scripts.md §7 #3` (`init.script:38-78`, `player.script:809-812`) | 2 parses + port byte diff | RESOLVED |
| 20 | `envscales` are all 0.85–1.15 | `DB_SCRIPTS.md:129` | Three bands: 1/1 (field + 3 mines), 0.95–1.05 (9 grass entries), 0.85–1.15 (112 of 122); duplicate `horseradish.1` | `decomp/DEC_03_configs.md §5 C3` (`envscales.cfg:8–865`; E05) | 2 | RESOLVED |
| 21 | Donor has a patrol hotkey (P or Q) | `RB_MECHANICS.md:225` G-12; `P7 G12` | No patrol action at all: `Q` = action `viewcollision` in the interface group (`hotkeys.cfg:150`), `P` = `build` of `%com%por` (the port building). Wiki premise UNVERIFIED | `decomp/DEC_02_scripts.md §7 #4`; `decomp/DEC_03_configs.md §5 C8` | 2 independent | RESOLVED |
| 22 | Donor has numeric morale; port morale constants are faithful | `P7 G-13`, prior gameplay docs | No numeric morale: disband is `count < 0.25 × basecount`, shooter retreat is a move-order mode; port `MORALE_*` / famine HP drain invented | `decomp/DEC_02_scripts.md §7 #8` (`units/global.inc/progress.inc:5-35,160-170`; `lib/player.script:270-322`) | 2 | RESOLVED |
| 23 | TGA masks are uncompressed 24-bit RGB | `P2 §2.1` | 4,467/4,510 TGAs are image type 10 RLE; sampled masks are RLE 24 bpp | `decomp/DEC_05_terrain_formats.md §6 #3` (N3 `heightmapwaves0.tga:0x00` = `00 00 0a`) | whole-file census | RESOLVED |
| 24 | `alphanull.bmp` is 512×257 | `P6 D19` | 512×256, 8 bpp, 12-byte BITMAPCOREHEADER | `decomp/DEC_05_terrain_formats.md §6 #5` (N5 `alphanull.bmp:0x00`); `reports/DTRN_01_donor_terrain_pipeline.md` C24 | 2 (raw hex + struct) | RESOLVED |
| 25 | `heightmapwaves0.tga` is `hmapTex`; its alpha carries height | `P4 §2`, `P6 D22`, `O5 C5`, `O2 §2.2` | Candidate negatively resolved: the name appears only in commented `water.mat:86-106` (all 21 lines `//`) and `water.lib:45`, 0 hits in `cossacks.exe`/`codex.dll`, and alpha is 255 for all 65,536 px. The engine binding itself is still UNVERIFIED | `decomp/DEC_05_terrain_formats.md §6 #4` (N3, N10); `reports/DTRN_03_donor_shore_water.md` C19; `reports/RV_TRN_03_water_bindings.md §6 #1`, `§9` | 3 (line read + byte scans + pixel decode) | PARTIAL |
| 26 | `DiffuseWaves2` is not bound | `O1 C22`, `O2 §4` | Imprecise: actively configured as `NormalMapLibMaterialName` (`water.lib:43`, `water.mat:32-39`) but has no sampler in `.dev`; GPU upload UNVERIFIED. Waves 1/3-7 are the genuinely commented ones | `reports/RV_TRN_03_water_bindings.md §6 #2`; `reports/DTRN_03_donor_shore_water.md` C18 | 2 | PARTIAL |
| 27 | "Fresnel is commented out" (unqualified) | `O3 §8 Q1` and older water notes | True only for the pinned `water.dev.frag:203-206`; the embedded legacy `.bak` shader has live Fresnel at `cossacks.exe:0x453F00-0x454E1F` (`:0x45494C`, `:0x454C28`); `water.lib:67-68` pins `.dev`, so not porting Fresnel is correct | `reports/RV_TRN_03_water_bindings.md §6 #3` (byte-compared to `water.vert.bak`/`water.frag.bak`) | 2 (byte compare + selector read) | RESOLVED |
| 28 | "Donor fog is off by default (`FogMode=0`)" (unqualified) | `reports/DTRN_01_donor_terrain_pipeline.md` C20; `TERRAIN2-03` | Only the shader reading is right: donor `TFogMode` is 0-based (`fmLinear=0`) and the GL writer maps 0 → `GL_LINEAR` (`0x4c883e`), so fixed-function LINEAR fog is active at 390–490; shader `fogMode` is 1-based. The `+1` bridge is UNVERIFIED; keep port fog off but do not assert "donor fog off" | `reports/DENV_01_environment.md §2.10`, `§6 C4` (`colors.lib:23,34-43`, `env.cfg:16`, DEEPDEC-04 B3/B8/T14); `reports/RV_TRN_03_water_bindings.md §7 #8` | 3 (config + binary + RTTI) | PARTIAL |
| 29 | DEC-03 sky labels: `startcolor` = pale zenith, `stopcolor` = saturated horizon | `decomp/DEC_03_configs.md §4.4` (lines 231–232) | Inverted labels only, values correct: `startangle=-5` is the horizon (pale), `stopangle=90` the zenith (deep); port mapping is already correct | `reports/DENV_01_environment.md §6 C1` (`skydome.cfg:8-9`, `:11-20`) | 2 | RESOLVED |
| 30 | `DynFogDepth=True` means depth fog is on for cinematics | `decomp/DEC_07_cameras_shaders.md §3.3` | Config value True only in the screenshot camera; its loader at `docreate.inc:301-302` is commented and `:315-320` forces False; no render consumer proven | `reports/DENV_01_environment.md §6 C5` (`camerascreenshot.cfg:61`, DEEPDEC-04 T12) | 2 | RESOLVED |
| 31 | 109 GLSL programs | `G31:34`, `RENDER_ARCH_SYNTHESIS:19` | 109 shader **files**: 6 exact duplicate pairs and 20 bone files collapsing to 2 templates | `decomp/DEC_07_cameras_shaders.md §8 #5` (`shaders.lib`, `shaders.ref`) | 2 | RESOLVED |
| 32 | `_control_GetMoveCameraToPositionOffset` body absent from donor text/binary; `ArcTan` absent from the binary | `DEEPDEC-01 E26/E14 §3.4`, `V790 §2.5/§5 #1` | Helper body is active at `control.script:574-613`; `ArcTan` declaration is at `cossacks.exe:0x209cc6`. VM body/semantics remain UNVERIFIED | `decomp/DEC_07_cameras_shaders.md §8 #2`; `reports/RV_CAM_01_fov_resolution.md §Corrections V790` | 2 | PARTIAL |
| 33 | `default.cameras` gives an absolute camera position (0, 0.05299, 0.08481) | `RENDER_ARCH_CAMERA:81-84` | It encodes rotated offsets: `PosY ≈ 0.1·sin32°`, `PosZ ≈ 0.1·cos32°`, i.e. `dz = 0.1` through `VectorRotateX` | `decomp/DEC_07_cameras_shaders.md §8 #4`; `reports/RV_CAM_01_fov_resolution.md §Corrections` | 2 | RESOLVED |
| 34 | DSEL-01 EXE offsets are authoritative | `DSEL_01_donor_selection_rectangle.md` | Consistently 0x0A low: cited VM string-record start, not ASCII text start. Fresh text offsets `0x29f7fa`, `0x29f74e`, `0x2a716e`, `0x240a3a` | `reports/RV_SEL_01_selection_reverify.md §Corrections #3` | fresh byte census | RESOLVED |
| 35 | V3D-01's screen-space `select_in_rect()` | `V3D_01 Fix A` | Rejected by arbitration S-25-06: 2D-derived; donor drag rect is world ground-space with a world epsilon. Do not re-open without new byte evidence | `reports/RV_SEL_01_selection_reverify.md §Corrections #5`; `PROGRESS.md` S-25-06; `GAPS.md §1` row 2 | arbitration + donor re-read (DSEL-01/02) | RESOLVED |
| 36 | Plaintext scripts never add height; per-cell height fields are undecoded | `TERRAIN_PORT_HILLS.md:167-169`, `PIECES/plateau.md:41-46`, port comment `game.gd:862-864` | `.pattern` binaries embed w×h float32 height grids after the occupancy mask (`pattern.lib:328-353`); `k_ravine_1` min/max −2.9636/+3.1398 | `reports/DTRN_02_donor_terrain_geometry.md §7.3` (C6/C7) | 2–3 | RESOLVED |
| 37 | Road tiles `ground1`/`test2`/`test3` at p = 0.5/0.25/0.25 | `reports/DTRN_01_donor_terrain_pipeline.md C14`; `TERRAIN_DONOR_PIPELINE.md:135,375` | 0.5/**0.375/0.125** from two `RandomExt` calls; fresh-random semantics inferred | `reports/RV_TRN_02_smoothing_rules.md §6 #1` (`texturemap.inc:627,633`) | fresh read + derived | PARTIAL |
| 38 | `Items[64]` rules / 64 probability tables | `reports/DTRN_01_donor_terrain_pipeline.md:231`; `TERRAIN_DONOR_PIPELINE.md:78` | 64 is the array bound; 22 Items, 130 lists (118 active + 12 commented), 310 TileName entries (282 active) | `reports/RV_TRN_02_smoothing_rules.md §6 #2/#3`, `§9` (`smoothtiles.inc:26`; `tilesmooth_scripts.cfg` 1,864/1,864 lines) | 2 (V1+V2 full parse) | RESOLVED |
| 39 | Tile pairs with abs(delta)=1 are always unchanged; "some lists have Prob=0" | `reports/DTRN_01_donor_terrain_pipeline.md:124,243` | abs(delta)=1 is unchanged only unless both matched entries have Prob=0 (then fall through); precisely 8 active Prob=0 entries in 4 lists, only Items 0/11 J=2 wholly zero | `reports/RV_TRN_02_smoothing_rules.md §6 #4/#6` (`smoothtiles.inc:142,157-180`; config `:55,59,63,742,985,989,993,1672`) | observed + derived | RESOLVED |
| 40 | `sand3`/`sand4` 64/2/2 metadata is ambiguous | `reports/DTRN_01_donor_terrain_pipeline.md §3.1` | Explicit; 8 sections total (sand1–4 + `_winter`); `test10_winter`/`test11_winter` lack the Summer 128 overrides | `reports/RV_TRN_01_texgen_mask_reverify.md §6 #1`; `reports/DALPHA_01_alpha_subrect.md §7 #2` (`tiles.lib:64-74,476-497`) | 2 | RESOLVED |
| 41 | Face blocks named `rockNs`; override range `tiles.lib:119-207` | `reports/DTRN_01_donor_terrain_pipeline.md §3.1/§5.2` | Shipped names are `rockNvf`/`rockNvs`; ranges `:119-296` and `:543-719` (36 vf + 36 vs pairs) | `reports/RV_TRN_01_texgen_mask_reverify.md §6 #2/#3` (`tiles.lib:123-126`) | 2 (name census + range read) | RESOLVED |
| 42 | Face alpha projection planes unknown | older V3D-02 / DOC-01 notes | Donor literals recovered: front S=(1,0,0,0) T=(0,0,1,0), side S=(0,1,0,0) T=(0,0,1,0), scale 0.125; the promotion rule that selects them stays UNVERIFIED | `reports/RV_TRN_01_texgen_mask_reverify.md` verdict C (`tiles.lib:119-296,543-719`; `tiles.mat:142-210`; `reftile.mat:120-170`) | 3 | PARTIAL |
| 43 | Alpha masks are exact complementary pairs | `reports/DTRN_06_donor_grass_decals.md` C15; `RV-TRN-01 §4.2` | Only 4 exact pairs, all constant-255 vs constant-0 sentinels; graded masks best MAD 9.77 with derived `(r,c)↔(3−r,3−c)` counterpart structure | `reports/DALPHA_01_alpha_subrect.md §5 #3`, `§7 #1` (`alpha.bmp` pixel array @1070; two independent decoders) | 2 decoders | PARTIAL |
| 44 | Whole-atlas sampling with `fract(v_st)` is donor-shaped | `M3` gap, `V785` | Donor alpha is an 8×4 grid of 64² patches (32 rectangles; seam deltas only at x/y multiples of 64); implement sub-rect sampling. The tile→patch index is still UNVERIFIED | `reports/RV_TRN_01_texgen_mask_reverify.md` verdict B; `reports/DALPHA_01_alpha_subrect.md §5 #1`, `§6` (`reftile.lib:10-12`) | 2+ decoders + seam-delta test | PARTIAL |
| 45 | `bmTransparency` pass count is recoverable from the enum / one `blend_mix` pass is donor parity | older blend notes, V3D-02 P7 | Enum string only; no pass-count or blend-factor table in readable data; keep the measured `mask_to_alpha` knob and never claim one-pass parity | `reports/RV_TRN_01_texgen_mask_reverify.md` verdict D (`cossacks.exe:949234,953108,4711020`; 46 text hits, all enum/`BlendingMode =`) | exhaustive scan | CONFIRMED_UNVERIFIED |
| 46 | Donor minimap is bottom-left | `RE_VISUAL.md:205-208` `[U]`; `DEEPDEC-08:168` | Bottom-**right** 240×240 (`initminimap.inc:17,33`; `showunitcontrol.inc:109-110,586`); port's 200 px bottom-left is a divergence | `decomp/DEC_08_ui_strings.md §7 C1/C2` | file evidence + second report (W23) | RESOLVED |
| 47 | Donor has 455 `.inc` files | `DE_AUDIO_UI.md:20` | 313 total (133 menu + 3 common + 177 under `scripts\`) | `decomp/DEC_08_ui_strings.md §7 C6` | 2 independent counts | RESOLVED |
| 48 | V717's minimap box mapping has no half-map offset; `camera3d.gd:354` comment is truth | `V717_hud3d_adapter.md:37-56,69-75`; `camera3d.gd:354` | Superseded by `hud3d_adapter.gd:57-62`, which adds `Vector2(mw,mh)*TILE_M*0.5`; `camera3d.gd:435-436` confirms CENTRED coordinates — the `:354` comment is stale | `decomp/DEC_08_ui_strings.md §7 C4/C5` | current-source read | RESOLVED |
| 49 | Gate counts 28/28 or 24/29; QA_REPORT mid-document FAIL; variant has no real 3D pixels, no donor light rig, one static splat active, `UV2.y=0` on all cells | `AGENT_PROTOCOL.md §2`, `SWARM_OPS.md §3.4`, RESUME/STATUS, `AUDIT3D-03/09`, `COMP-03`, `V792` | 29/29 + 17/17 + CLEAN; later QA FINAL sections supersede mid-document FAIL; real GPU frames exist (jobs 138/179); donor sun wired (`world3d_terrain.gd:553-593`); live `game.tileblock` → UV2 → 124-cell atlas is active, splat fallback-only; FIX-TERRAIN promoted face flags (~7 % at 320²) | `reports/DOC_01_all_docs_synthesis.md §6` (`D-21/D-23/D-26/D-27/D-28`; `QA_REPORT.md` ABSOLUTE FINAL jobs #570-573; V7-60; COMP-03 S1/E1; `DTRN_01 C27`) | coordinator arbitration of current artifacts | RESOLVED |
| 50 | The three engine constants might be recovered from packed `.bind` | prior UNVERIFIED labels | Not recoverable by static read-only means: ground eye planes, numeric FOV/focal conversion, native selection inside-box predicate are **CONFIRMED_INFEASIBLE**; values may exist at runtime but no readable or decodable byte route yields them | `reports/DBIND_01_wus_bind.md §5.1–§5.3`, `§8` (0 hits in five packed regions; no decrypt loop in 1,405 decoded stub instructions; no container found) | 5 methods; per-constant byte reasons | CONFIRMED_INFEASIBLE |

| 51 | DEC-04: frame 0 is not a bind pose for multi-bone files | `decomp/DEC_04_anim_formats.md §6.1` | **Refuted by DANIM-01:** 335/335 `.oss` have frame-0 identity (max |p|=1.09e−6 m; peaukr skin f0 displacement 1.52e−7 m), confirming DEEPDEC-06 F4/F5; DEC-04's Method C misread a bone-major track array as frame-major | `reports/DANIM_01_action_ranges.md` (two methods: sequential `read_oss`+quaternion check; bone-major offset census) | 2 independent methods | RESOLVED |
| 52 | `FogMode=0` means fog is off; DEC-03 sky start/stop labels are zenith/horizon | `DTRN_01 C20`; `decomp/DEC_03_configs.md` sky labels | Fog is **ambiguous, not simply off** — RTTI is 0-based (`fmLinear=0`) and the binary maps 0→`GL_LINEAR`, while shader `fogMode` is 1-based; bridge UNVERIFIED. Sky labels inverted: `startangle=-5` = horizon (pale blue), `stopangle=90` = zenith (deep blue); the port mapping was correct | `reports/DENV_01_environment.md` (env/** key tables, `colors.lib` statictables, RTTI crosswalk) | fresh read + independent extraction | PARTIAL |
| 53 | The 180 MB tile atlas is untracked or `KEEP_UNCOMMITTED_OR_LFS` | `V791 §9.3`, atlas manifest status | Big PNG **is** Git-LFS tracked (134-byte pointer in-tree, full local object); however the split parts are ~180 MB ordinary Git blobs, so clone size is unchanged. Without LFS the pointer reaches `Image.load()` and the loader falls back to split | `reports/ATLAS_01_transport.md` (SHA-256 identity of concatenated parts vs single PNG, verified twice) | hash ×2 + file inventory | RESOLVED |
| 54 | Port map-size options match donor | `menu.gd:696-699` 240/320/400/480 | Donor sizes are Tiny 256 / Normal 320 / Large 480 / Huge 640 (`donewgame.inc:42-49`; GUI order `:243-246`); port numbers and default diverge. Season ids 0/2/3 with **no selectable 1**; stage reseeds/version gates absent in port | `reports/DMAPGEN_01_skirmish_options.md` (`dmscript.global:236,238,240`; 11 reseed sites) | twice-verified path:line | RESOLVED |
| 55 | Donor selection sounds are positional unit sounds / order acknowledgements exist | prior audio assumptions | Selection clips `selectpeasant1..6` + `selectship` are interface-bank, played **non-positionally** via `_sound_PlaySound` on unit-control rebuild (`showunitcontrol.inc:1024-1027`); every `gc_snd_ind_order*` call is commented and constants undefined. All 325 port clips present; 59 live donor indices | `reports/DAUDIO_01_sound_events.md` (325/325 mapping, raw-byte census) | full-tree read + byte scan | RESOLVED |
| 56 | Donor terrain height comes only from generator noise; relief patterns don't sculpt height | `TERRAIN_PORT_HILLS.md`, `PIECES/plateau.md` | Relief `.pattern` binaries embed w×h float32 grids after the occupancy mask; 26 decoded grids match `pattern.lib` literals **bit-exactly**; mountain patterns have all-zero grids and embed `terrainmeshN` props, so port needs props not taller bumps | `reports/DPATTERN_01_relief_grids.md` (offsets, RLEs, 8×10 downsamples) + `reports/DTRN_02_donor_terrain_geometry.md` | 2–3 passes per claim | RESOLVED |

## Claims that stay UNVERIFIED

These values were not recovered by any amount of script, config, byte or image reading.
No row in the table above upgrades them to donor fact. "Infeasible" means no static
read-only route exists — **not** that the value is absent at runtime.

| Engine-side value | Authoritative label | Proof / why script reading cannot recover it | Keep in the port as |
|---|---|---|---|
| Ground `gl_EyePlaneS/T[0]`, `gl_TextureMatrix[0]` | **CONFIRMED_INFEASIBLE** — `reports/DBIND_01_wus_bind.md §5.1`; `reports/RV_TRN_01_texgen_mask_reverify.md` verdict A | 0 hits in all five packed regions (ASCII + UTF-16LE) and across 12 binaries / 16,564 text files; the readable `.bind` loader stub (`cossacks.exe:0x55c900..0x55f1ff`) contains no plane/matrix assignment; the ~135 KB payload (`:0x55f200..0x58036f`) has entropy ~7.95, cross-binary equality ~0.4 %, no container header and no decrypt loop in 1,405 decoded instructions. Authored neighbours (`reftile.mat:34,38-48`, `mappingmode=tmmUser`, S/T=(1,0,0,0)/(1,0,0,0)) are **not** eye planes | `PORT APPROXIMATION` world-XZ texgen; no donor literal |
| Numeric FOV / focal→FOV body and sensor | **CONFIRMED_INFEASIBLE** — `reports/DBIND_01_wus_bind.md §5.2`; `reports/RV_CAM_01_fov_resolution.md §Verdict` (CONFIRMED_UNVERIFIED) | API declaration only (`cossacks.exe:0x1fe0e6`, inverse `:0x1fe158`); 0 packed-region hits; 0 donor script call sites; no sensor float32 (`36.0`, `20.25`, `121.4885`, `1200.0` all 0 hits); no `viewportdimension`/`Sensor`/`FieldOfView` in packed bytes | `FOV_DEG_ASSUMED=17.27` labelled PORT APPROX; 2.90° only as a secondary A/B candidate; never 5.15°/30.22° as V-FOV |
| Native selection inside-box predicate (centre / AABB / frustum) | **CONFIRMED_INFEASIBLE** — `reports/DBIND_01_wus_bind.md §5.3`; `reports/RV_SEL_01_selection_reverify.md §Open questions #1` | 0 hits for `GameManagerStartSelection`, `GetGameObjectSelectionSizeByHandle`, `spmRunTime` and generic `inside`/`Rect` probes in the five packed regions; script-side names are declarations, not native bodies; no donor script calls the size getter | World ground rect + script-side spec from RV-SEL-01; predicate stays UNVERIFIED |
| `tile_id + boundary_direction → alpha patch (u,v,size)` | **CONFIRMED_UNVERIFIED** — `reports/DALPHA_01_alpha_subrect.md §5 #5`, `§8 Q1`; `reports/RV_TRN_01_texgen_mask_reverify.md` verdict B | 17,237-file scan and 11 binaries × 3 encodings found 0 patch-index function names; alpha UV comes from engine-written `gl_MultiTexCoord1` (`hf.pvl.sm.vert:34`); packed `.bind` | 8×4×64 sub-rect grid is donor-grounded; tile→patch choice is APPROX, direction rows derived from measured edge darkness |
| Exact `rockNvf`/`rockNvs` promotion and how the 25° tilt reaches the GPU | **PARTIAL / UNVERIFIED** — `reports/RV_TRN_01_texgen_mask_reverify.md` verdict C and `§8 Q3` | Names occur in only three data files and are never assigned in a script; `AngleX=0/AngleZ=25` and `AngleX=25/AngleZ=0` are donor literals, but the selection rule and geometry-vs-texgen application are engine-side | Slope-based promotion with the cited tilt literal, labelled APPROX |
| `hmapTex` texture/FBO binding (and `hmapMin/Max`, `hmapW/H`) | **UNVERIFIED** — `reports/RV_TRN_03_water_bindings.md §2`, `§8 Q1–Q2`; `reports/DTRN_03_donor_shore_water.md` C20 | Only a Delphi string-key assignment to descriptor field `+0x54` is proven (`cossacks.exe:0x452FDB`, VA `0x853BDB`, `mov edx,0x853e0c`, `call 0x405454`); no texture lookup, sampler unit or source file in readable data. `heightmapwaves0.tga` is disproved as the text candidate, but an engine-generated surface remains plausible | Height-grid substitute labelled PORT APPROX; port `±2.96` and `map_size.x/128` are approximations |
| `bmTransparency` pass count and blend factors | **CONFIRMED_UNVERIFIED** — `reports/RV_TRN_01_texgen_mask_reverify.md` verdict D; `reports/DALPHA_01_alpha_subrect.md §8 Q6` | Enum string only (`cossacks.exe:949234,953108,4711020`); 46 text hits are all enum/`BlendingMode =`; payload unreadable | Measured `mask_to_alpha` diagnostic knob; no one-pass parity claim |
| Donor GPU A/B / rendered skin, terrain and water parity | **UNVERIFIED** everywhere — `reports/DOC_01_all_docs_synthesis.md` frontmatter `parity_guard`; `GAPS.md §2` "Verification gap"; `reports/DBIND_01_wus_bind.md §7 Q7` | No donor frame at a matched camera exists anywhere in the project; donor execution was forbidden this lane and a live GL/native trace is explicitly out of scope. Metrics and node counts are not frames | Every visual-parity claim stays UNVERIFIED; metrics never override visual review (CHARTER) |

Also still UNVERIFIED, each cited in its source report and not re-litigated here: exact
skin-equation form and donor→Godot quaternion convention (`DANIM_01 §6.3`), `ArcTan`
VM body and units (`RV-CAM-01 §Open questions #4`), palette `FogMode` → shader `fogMode`
bridge and sky/sun precedence (`DENV_01 §7 #1–#3`), `.map` 37-byte record field identity
(`DEC_05 §8 #1`), runtime activity of the `;`-prefixed `.inc` lines
(`RV-TRN_02 §8 #3`), and donor minimap frustum shape (`DEC_08 §9 #2`).

## How to use this index

**For workers**

1. Cite the **authority row** (report + evidence id / `path:offset`) in any new report,
   ticket or code comment needing one of these facts. Do not cite the "old source"
   column except when describing what was superseded.
2. Treat `PARTIAL`, `CONFIRMED_UNVERIFIED` and `CONFIRMED_INFEASIBLE` rows as carrying
   their caveat forward: keep `PORT APPROXIMATION` labels, do not substitute a plausible
   number, and never promote an approximation to donor fact.
3. Do not re-open arbitrated decisions (notably S-25-06, row 35) without new byte-level
   evidence. A second report repeating the old claim does not outrank this index.
4. When a row says the visual parity is UNVERIFIED, do not write "donor-like" from
   metrics, node counts or a pillow render.

**For the coordinator**

1. When a new correction lands, add or update a row here in the same format: old claim,
   old source, new truth, authority, verification passes, status. If it reverses an
   existing row, keep the reversal chain visible in the "old source" cell and update the
   final truth in place so there is exactly one authoritative statement.
2. Point `decomp/SUMMARY.md §9` readers here rather than duplicating the table; today's
   `SUMMARY.md §4/§9` still carries the stale DEC-04 frame-0 claim (row 14).
3. Move a row to `RESOLVED` only on cited readable evidence. Move an UNVERIFIED item
   to `PARTIAL`/`RESOLVED` only with the report and evidence id that recovered it;
   otherwise leave it in the unresolved section.
4. Keep this file cold-readable: no new values, no unsourced claims, no donor copies.

## Summary

56 indexed corrections across binaries, scripts, configs, terrain, maps, cameras,
animation, water, audio, atlas transport, UI and stale-doc arbitration. The largest reversals are: the `.exe`
entry is in `CODE`, not `.bind` (row 1); `[*]=;` is live code (row 6); DEC-07's FOV
"correction" was itself an axis misreading (row 7); frame 0 **is** the bind pose for
all 335 `.oss` files, after DEC-04's refutation was itself refuted (row 14);
`gc_meters_to_tile=2` grounds `TILE_M=2.0` (row 10); `FogMode=0` is ambiguous, not
"off" (row 28); DEC-03's sky labels were inverted (row 29); and the alpha masks are
only sentinel-exact complements (row 43). Eight engine-side values remain
UNVERIFIED, three of them proven CONFIRMED_INFEASIBLE by `DBIND_01`. No donor binary
was executed or copied; no visual-parity claim is made by this index.
