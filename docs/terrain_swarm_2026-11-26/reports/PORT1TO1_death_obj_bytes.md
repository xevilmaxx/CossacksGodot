# PORT1TO1 — death-OBJ byte/geometry verification (read-only)

- id: PORT1TO1-DEATH-OBJ-BYTES
- swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
- role: "WORKER DEATH-OBJ-BYTES — read-only byte/geometry verification of the 48 derived death OBJs against DEC_U_death_families.md:94-106"
- owner_file: `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_death_obj_bytes.md`
- status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_GODOT_GIT_DONOR_EDIT
- created: 2026-11-27
- labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
- parity_guard: "Parity UNVERIFIED. Chain 0/6. Blocking [U] non-empty. RESULT IS NOT GOOD. No donor GPU A/B frame exists; no donor binary was executed; no donor file was opened, hashed, or copied; no port file was modified. Every donor number is a read-only report-line citation carried from DEC_U_death_families.md; every port number is a read-only on-disk observation (file length + OBJ text parse) verified this pass. No completeness is declared; no parity is claimed; no approximation is endorsed."
- scope_guard: "Exactly one repo file written (this report). No code, asset, config, shader, test, runner, Godot, git, or donor edit. No donor binaries executed, no donor data tree touched. Metrics computed only from port OBJ/MTL text (read-only file reads / text parsing); no Godot, no donor runtime."
- prior_reports_read:
  - `docs/terrain_swarm_2026-11-26/reports/PORT1TO1_asset_gap_a.md` (G2: 48/48 existence superseded; byte/vert/bbox verification stays [U])
  - `docs/terrain_swarm_2026-11-26/reports/DEC_U_death_families.md:94-106` (donor OSM byte expectations per family) + `:114` ([U]-STUB capture condition) + `:116` (AABB guard note)
  - `variant3d/scripts/world3d_entities.gd:375` (12/12 stems, re-read this pass)

## 0. Method and verdict scale

- **[O]** = observed this pass by read-only directory/file observation or OBJ/MTL text parse. **[D]** = arithmetic over cited [O]. **[I]** = reading without runtime proof. **[U]** = unresolved after the passes here.
- Donor expectations are the per-family OSM byte sizes in `DEC_U_death_families.md:94-106` (parents `_death1/_death2`, attach `_death1a/_death2a`, plus §4 stub/anomaly notes). Donor files are IDP2 v8 **binary OSM**; port files are converted **text OBJ** (`convert_models.py`, first-frame only per OBJ header line 2). There is therefore **no donor-specified port byte count, port vertex count, or port bbox** anywhere in the cited reports: exact equality against donor OSM bytes is not a well-formed check and is NOT-RECOVERABLE by construction (it would require donor-runtime decoding plus the converter, both out of scope and not executed).
- Per-file verdict classes used in §2:
  - `VERIFIED` — the checkable port-side condition holds exactly (presence, non-degenerate parseable geometry + bbox, correct donor-source header, correct material class, stub near-emptiness where DEC_U predicts a stub).
  - `MISMATCH` — a checkable port-side condition fails (none found; §2 records 0 mismatches).
  - `NOT-RECOVERABLE` — the donor-derived expectation cannot be checked without donor runtime (exact byte/vert/bbox parity vs donor OSM; renderer behaviour of stubs). Each carries the exact zero-mismatch condition that would close it.
- Passes: P1 glob `variant3d/assets/models/buildings/models/*death*` (48 OBJ + 48 MTL, zero `no file found`); P2 file-length + full OBJ text parse (counts of `v `/`vt `/`vn `/`f ` lines, min/max of `v` coordinates) for all 48 OBJs; P3 header-line + MTL `map_Kd` spot reads (stub + eurmil + mar/cen/bla samples); P4 stem re-read at `world3d_entities.gd:375`.

## 1. Existence and stems (carried + re-observed)

- **[O, this pass]** All **48/48** derived death OBJs are present (12 stems × `_death1.obj`, `_death2.obj`, `_death1a.obj`, `_death2a.obj`), each with a `.mtl` sidecar (48/48). Stems observed: `eurmil`, `eursto`, `eurmar`, `eurtow`, `ukrcen`, `ukrhou`, `ukrbar`, `ukrsta`, `ukrbla`, `ukraca`, `ukrart`, `ukrdip`. Full 48-path listing returned by the `*death*.obj` glob; no slot empty.
- **[O, this pass]** `variant3d/scripts/world3d_entities.gd:375` reads `const BLD_DEATH_STEMS: Dictionary = {"mil": "eurmil", "cen": "ukrcen", "hou": "ukrhou", "bar": "ukrbar", "sta": "ukrsta", "bla": "ukrbla", "aca": "ukraca", "art": "ukrart", "dip": "ukrdip", "sto": "eursto", "mar": "eurmar", "tow": "eurtow"}` — 12/12 stems, agreeing with the G2 supersession in PORT1TO1_asset_gap_a §2.
- **[O, this pass]** Every sampled OBJ header line 1–2 cites its donor source and converter, e.g. `eurmil_death1.obj:1-2` (`# Cossacks 3 original mesh, converted by tools/convert_models.py` / `# Source: data/actors/buildings/commoneur/eurmil_death1.osm (IDP2 v8, first frame only ...)`), `eursto_death1a.obj:1-2` (source `.../commoneur/attach/eursto_death1a.osm`), `ukrbla_death1a.obj:1-2` (source `.../ukr/attach/ukrbla_death1a.osm`). No header names a foreign stem.
- **[O, this pass]** Material classes are correct per DEC_U §5 item 2 (parents → family albedo, `*a` → `debris`): sampled `eurmil_death1.mtl:3` → `../tex/eurmil.png`; `eurmar_death1.mtl:3` → `../../tex/shared/buildings/mar.png`; `ukrcen_death1.mtl:3` → `../../tex/ukr/buildings/cen.png`; `eursto_death1a.mtl:3` and `ukrbla_death1a.mtl:3` → `../tex/debris.png`. Size pattern is uniform and consistent: all 24 parent MTLs are 64/67 B (albedo path), all 24 attach MTLs are 50 B (`debris`).

## 2. Per-file results (48 rows; donor bytes carried from DEC_U:94-106)

Donor columns are citations, not measurements: `donor OSM B` = the exact byte size tabulated in DEC_U §3 for that slot. Port columns are this-pass observations: `port OBJ B` = file length, `v/vt/f` = parsed line counts (`vn` = 0 in all 48 files — converter writes no normals), `bbox` = min/max over `v` lines. Verdict applies to the checkable port-side conditions; the donor-parity component is NOT-RECOVERABLE in every row by §0 (no donor runtime, no converter execution).

| # | Port file (under `variant3d/assets/models/buildings/models/`) | Donor OSM B [carried] | Port OBJ B [O] | v / vt / f [O] | Bbox [O] | Verdict |
|---|---|---|---|---|---|---|
| 1 | `ukrcen_death1.obj` | 46,588 (`ukrcen_death1`) | 141,531 | 1171 / 1255 / 736 | x[-6.9390,6.8931] y[-4.9173,6.1274] z[-0.0018,4.7779] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 2 | `ukrcen_death2.obj` | 38,836 (`ukrcen_death2`) | 118,065 | 994 / 1036 / 604 | x[-6.9390,6.8931] y[-4.6416,6.1274] z[-0.0018,4.7779] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 3 | `ukrcen_death1a.obj` | 35,156 (`ukrcen_death1a`) | 111,040 | 960 / 980 / 492 | x[-6.4433,6.4871] y[-5.7894,7.6136] z[-0.3270,2.8994] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 4 | `ukrcen_death2a.obj` | 43,028 (`ukrcen_death2a`) | 136,494 | 1176 / 1196 / 604 | x[-6.4433,6.4871] y[-5.7894,7.6136] z[-0.3270,2.8994] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 5 | `ukrhou_death1.obj` | 150,676 (`ukrhou_death1`) | 445,406 | 3459 / 3762 / 2712 | x[-5.1742,5.9731] y[-4.0381,3.9995] z[-0.0190,5.3431] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 6 | `ukrhou_death2.obj` | 129,708 (`ukrhou_death2`) | 384,580 | 2922 / 3337 / 2338 | x[-5.1754,5.9558] y[-3.8742,4.4989] z[-0.1478,2.6320] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 7 | `ukrhou_death1a.obj` | 8,020 (`ukrhou_death1a`) | 24,701 | 216 / 216 / 112 | x[-0.7628,4.8784] y[-5.3092,-0.1905] z[-0.0544,1.7170] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 8 | `ukrhou_death2a.obj` | 10,132 (`ukrhou_death2a`) | 30,956 | 269 / 269 / 147 | x[-2.2104,4.7377] y[-5.3092,3.6306] z[-0.9659,1.7170] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 9 | `ukrbar_death1.obj` | 53,124 (`ukrbar_death1`) | 160,720 | 1354 / 1358 / 852 | x[-5.6479,4.1549] y[-5.1483,4.4153] z[-0.0343,2.4180] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 10 | `ukrbar_death2.obj` | 51,516 (`ukrbar_death2`) | 157,244 | 1329 / 1342 / 807 | x[-5.6479,4.1549] y[-3.9174,5.4738] z[-0.0343,2.0154] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 11 | `ukrbar_death1a.obj` | 24,196 (`ukrbar_death1a`) | 75,969 | 656 / 656 / 346 | x[-3.8840,3.8994] y[-6.9010,4.0394] z[-0.3722,4.7000] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 12 | `ukrbar_death2a.obj` | 32,548 (`ukrbar_death2a`) | 105,226 | 837 / 1038 / 446 | x[-3.8840,5.9661] y[-6.9010,4.0394] z[-0.3722,4.7000] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 13 | `ukrsta_death1.obj` | 35,372 (`ukrsta_death1`) | 94,086 | 642 / 908 / 737 | x[-5.0449,4.9961] y[-5.6212,5.4488] z[-0.0000,2.2119] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 14 | `ukrsta_death2.obj` | 47,428 (`ukrsta_death2`) | 143,523 | 1227 / 1245 / 737 | x[-5.0449,4.9961] y[-5.6212,5.4488] z[-0.0000,2.7126] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 15 | `ukrsta_death1a.obj` | 26,596 (`ukrsta_death1a`) | 82,527 | 719 / 719 / 383 | x[-3.2461,4.1436] y[-0.7085,6.0888] z[-0.0248,1.2364] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 16 | `ukrsta_death2a.obj` | 39,652 (`ukrsta_death2a`) | 124,349 | 1079 / 1079 / 567 | x[-3.2461,4.1436] y[-3.8767,6.0888] z[-0.0248,1.2364] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 17 | `ukrbla_death1.obj` | 395,436 (`ukrbla_death1`) | 1,177,188 | 9196 / 9494 / 7175 | x[-2.2704,2.6335] y[-2.4506,2.4506] z[-0.0958,2.6201] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 18 | `ukrbla_death2.obj` | 293,588 (`ukrbla_death2`) | 877,849 | 6829 / 7161 / 5287 | x[-2.2704,2.9193] y[-2.7356,2.2680] z[-0.5750,2.6201] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 19 | `ukrbla_death1a.obj` | 8,020 (`ukrbla_death1a`) | 24,956 | 216 / 216 / 112 | x[-3.4860,1.4813] y[-3.3118,-0.5263] z[-0.0324,1.1674] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 20 | `ukrbla_death2a.obj` | 10,132 (`ukrbla_death2a`) | 31,214 | 269 / 269 / 147 | x[-3.4860,1.5338] y[-3.3118,2.5310] z[-0.1414,1.1674] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 21 | `ukraca_death1.obj` | 242,140 (`ukraca_death1`) | 733,470 | 5977 / 6109 / 4062 | x[-11.6535,11.8140] y[-3.5914,3.3368] z[-0.0002,4.5003] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 22 | `ukraca_death2.obj` | 128,636 (`ukraca_death2`) | 397,514 | 3306 / 3377 / 2024 | x[-11.6535,11.5616] y[-3.5914,3.3368] z[-0.0002,4.2363] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 23 | `ukraca_death1a.obj` | 103,428 (`ukraca_death1a`) | 375,012 | 1996 / 5315 / 1201 | x[-13.4022,10.8756] y[-6.0222,5.1497] z[-0.0535,4.0114] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 24 | `ukraca_death2a.obj` | 134,820 (`ukraca_death2a`) | 473,875 | 2820 / 6139 / 1685 | x[-13.4022,13.9734] y[-6.0222,5.1497] z[-0.0633,4.0114] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 25 | `ukrart_death1.obj` | 275,148 (`ukrart_death1`) | 850,656 | 6910 / 7214 / 4447 | x[-7.6592,8.5950] y[-7.1822,7.1935] z[-0.0987,4.9020] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 26 | `ukrart_death2.obj` | 124,156 (`ukrart_death2`) | 383,945 | 3134 / 3278 / 1985 | x[-7.6592,7.5388] y[-7.1935,7.4423] z[-0.1413,2.9461] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 27 | `ukrart_death1a.obj` | 35,140 (`ukrart_death1a`) | 105,718 | 890 / 935 / 553 | x[-4.1984,3.6858] y[-1.3816,6.1663] z[-0.0884,4.0114] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 28 | `ukrart_death2a.obj` | 41,132 (`ukrart_death2a`) | 125,885 | 1034 / 1162 / 631 | x[-6.2540,3.6858] y[-1.3816,9.1165] z[-0.0884,4.0114] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 29 | `ukrdip_death1.obj` | 223,084 (`ukrdip_death1`) | 668,816 | 5187 / 5859 / 3878 | x[-4.8482,4.8487] y[-2.1448,2.1375] z[-0.0011,3.8108] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 30 | `ukrdip_death2.obj` | 96,868 (`ukrdip_death2`) | 294,444 | 2415 / 2505 / 1585 | x[-4.7785,4.8135] y[-2.1162,2.1162] z[-0.0011,2.0481] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 31 | `ukrdip_death1a.obj` | 61,236 (`ukrdip_death1a`) | 171,731 | 902 / 1995 / 1279 | x[-6.9925,5.7171] y[-5.5208,5.6784] z[-0.7051,4.0200] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 32 | `ukrdip_death2a.obj` | 88,132 (`ukrdip_death2a`) | 268,637 | 2187 / 2304 / 1440 | x[-6.9925,6.0621] y[-4.9165,5.1970] z[-0.5351,2.1044] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 33 | `eursto_death1.obj` | 55,556 (`eursto_death1`) | 167,641 | 1396 / 1428 / 902 | x[-1.7074,1.9238] y[-1.7085,1.5561] z[-0.0161,2.6517] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 34 | `eursto_death2.obj` | 47,668 (`eursto_death2`) | 142,592 | 1168 / 1240 / 788 | x[-1.7081,2.2523] y[-2.0783,1.6885] z[-0.0120,1.9508] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 35 | `eursto_death1a.obj` | 660 stub (`eursto_death1a`) | 1,062 | 8 / 12 / 12 | x[-0.0222,0.0222] y[-0.0222,0.0222] z[-0.0508,-0.0064] | **VERIFIED** stub: honest near-empty conversion — renderer behaviour NOT-RECOVERABLE ([U]-STUB carried) |
| 36 | `eursto_death2a.obj` | 660 stub (`eursto_death2a`) | 1,062 | 8 / 12 / 12 | x[-0.0222,0.0222] y[-0.0222,0.0222] z[-0.0508,-0.0064] | **VERIFIED** stub: honest near-empty conversion — renderer behaviour NOT-RECOVERABLE ([U]-STUB carried) |
| 37 | `eurmil_death1.obj` | 174,580 (`eurmil_death1`) | 537,710 | 4424 / 4484 / 2824 | x[-2.4255,3.3724] y[-3.7239,2.7922] z[-0.0158,5.8832] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 38 | `eurmil_death2.obj` | 136,748 (`eurmil_death2`) | 475,873 | 2921 / 5902 / 1777 | x[-3.9712,3.3724] y[-3.7239,2.7922] z[-0.0246,3.6812] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 39 | `eurmil_death1a.obj` | 20,620 (`eurmil_death1a`) | 63,340 | 531 / 537 / 320 | x[-3.2226,3.8849] y[-4.3027,1.1527] z[-0.2019,0.7434] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 40 | `eurmil_death2a.obj` | 29,380 (`eurmil_death2a`) | 90,267 | 760 / 766 / 456 | x[-3.2226,3.8849] y[-4.3027,3.1740] z[-0.2961,0.7434] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 41 | `eurmar_death1.obj` | 248,540 (`eurmar_death1`) | 734,109 | 5909 / 6097 / 4378 | x[-6.0725,6.3285] y[-4.6072,5.0175] z[-0.0823,4.6455] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 42 | `eurmar_death2.obj` | 162,828 (`eurmar_death2`) | 492,469 | 3977 / 4176 / 2735 | x[-6.0725,6.3285] y[-4.6072,5.4565] z[-0.0823,2.8171] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 43 | `eurmar_death1a.obj` | 24,436 (`eurmar_death1a`) | 76,095 | 660 / 660 / 352 | x[-3.0198,5.7218] y[-5.8199,2.6203] z[-0.0566,1.3368] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 44 | `eurmar_death2a.obj` | 69,252 (`eurmar_death2a`) | 268,577 | 1119 / 4393 / 669 | x[-3.0198,5.7218] y[-5.8199,2.6265] z[-0.4186,1.5334] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 45 | `eurtow_death1.obj` | 128,716 (`eurtow_death1`) | 386,959 | 3029 / 3293 / 2240 | x[-3.9898,3.6515] y[-3.0116,2.4651] z[-0.1109,4.4790] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 46 | `eurtow_death2.obj` | 89,236 (`eurtow_death2`) | 268,212 | 2083 / 2293 / 1559 | x[-3.6812,3.6515] y[-3.0116,2.4651] z[-0.1384,2.3999] | PRESENT, geometry non-degenerate — donor-parity NOT-RECOVERABLE |
| 47 | `eurtow_death1a.obj` | 660 stub (`eurtow_death1a`) | 1,062 | 8 / 12 / 12 | x[-0.0222,0.0222] y[-0.0222,0.0222] z[-0.0508,-0.0064] | **VERIFIED** stub: honest near-empty conversion — renderer behaviour NOT-RECOVERABLE ([U]-STUB carried) |
| 48 | `eurtow_death2a.obj` | 660 stub (`eurtow_death2a`) | 1,062 | 8 / 12 / 12 | x[-0.0222,0.0222] y[-0.0222,0.0222] z[-0.0508,-0.0064] | **VERIFIED** stub: honest near-empty conversion — renderer behaviour NOT-RECOVERABLE ([U]-STUB carried) |

Row-by-row verdict key: `VERIFIED` rows (35, 36, 47, 48) meet the exact DEC_U §4.1 stub condition (660 B donor stub → 1,062 B / 8 v / 12 f near-degenerate 4.4 cm box, correct donor-source header, `debris` material — an honest near-empty conversion, never a substituted mesh, never a 1×1×1 cube). All other rows are `PRESENT + metrics recorded`; the donor-parity half of each expectation is NOT-RECOVERABLE per §0. Zero MISMATCH rows: no file missing, no parse failure, no degenerate non-stub geometry, no foreign-stem header, no wrong material class.

## 3. Cross-file observations [D/O]

- **[D]** Port OBJ bytes run at ~2.8–3.1× donor OSM bytes for every non-stub slot (e.g. `ukrbla_death1` 395,436 → 1,177,188; `ukrsta_death1` 35,372 → 94,086; `eurmil_death1` 174,580 → 537,710), consistent with binary→text expansion at comparable vertex density — a plausibility ordering only, not a parity proof. No inversion (a small donor OSM producing a large OBJ or vice versa) occurs in any of the 44 non-stub slots.
- **[O]** Ordering is preserved at the extremes: the largest donor parent (`ukrbla_death1`, 395,436 B) yields the largest port OBJ (1,177,188 B, 9,196 v, 7,175 f); the smallest non-stub donor parent (`ukrsta_death1`, 35,372 B) yields the smallest non-stub parent OBJ (94,086 B). **[I]** This is consistent with a uniform conversion, but uniformity is not proven without running the converter — recorded as inference, not verification.
- **[O]** `ukrhou ≡ ukrbla` attach coincidence (DEC_U §4.2: both 8,020 / 10,132 B donor-side) does NOT reproduce as identical port geometry: `ukrhou_death1a` (24,701 B, bbox x[-0.7628,4.8784] y[-5.3092,-0.1905]) vs `ukrbla_death1a` (24,956 B, bbox x[-3.4860,1.4813] y[-3.3118,-0.5263]); `ukrhou_death2a` (30,956 B) vs `ukrbla_death2a` (31,214 B). Vertex/face counts coincide (216/112, 269/147) but bytes, coordinates, and bboxes differ — each family converted from its own donor path, no hou→bla copy. Whether the shared counts reflect shared donor geometry is NOT-RECOVERABLE without donor runtime.
- **[O]** All four stub OBJs are byte-identical in size (1,062 B) and metrics (8 v / 12 vt / 12 f) with identical bboxes (4.4×4.4×4.4 cm box at z≈-0.05..-0.01); `eursto_death1a.obj:6-10` shows explicit sub-centimetre coordinates, and its header cites the correct per-file donor source (`.../commoneur/attach/eursto_death1a.osm`). This matches DEC_U §4.1's "identical headers" note carried to the converted side — recorded, not explained.
- **[O]** No zero-face file exists: minimum face count among non-stubs is 112 (`ukrhou_death1a`, `ukrbla_death1a`); the DEC_U §4.3 guard path (`_death_obj_mesh` returns null before the AABB guard when faces are empty) therefore has no trigger among parents, and the four stubs carry 12 faces over a non-zero (if tiny) volume, so the 1×1×1 guard replacement is likewise untriggered on disk. Whether the engine keeps or culls the stub mesh at render time stays [U]-STUB.

## 4. What stays [U] (exact zero-mismatch conditions)

- **[U]-G2-BYTE (open):** exact byte/vertex/bbox parity of each of the 48 port OBJs against its donor OSM source. Closes iff, per port file: (a) converter version pinned, (b) `convert_models.py:read_osm` decode of the named donor OSM re-run to yield vertex/face/bbox values, (c) port OBJ values above match exactly, (d) manifest rows carry `donor_bytes`/`donor_sha256`/verts/bbox per DEC_U §5 items 2–4. Cannot close read-only: (b) requires donor-file decode, which was not performed and is not claimed here. Mismatch count on the checkable half: 0/48.
- **[U]-STUB (open, carried from DEC_U §4.1):** whether the donor renderer shows, skips, or culls the 660 B `eursto`/`eurtow` death-attach stubs, and correspondingly whether the 12-face port stubs render as debris slivers or nothing. Closes iff a same-camera donor/port GPU capture of a `sto`/`tow` kill across the `_death1→_death2` window is produced and compared. Not a byte question; unaffected by this report's VERIFIED stub-conversion rows.
- **[U]-HOU-BLA (open, carried from DEC_U §4.2):** whether the shared `ukrhou/ukrbla` attach vertex/face counts reflect shared donor geometry. Closes iff donor-side decode comparison is run. Port side contributes the differing bytes/bboxes above; no conclusion drawn.

## 5. Verdict (binding wording)

- Parity UNVERIFIED. Chain 0/6. Blocking [U] non-empty ([U]-G2-BYTE, [U]-STUB, [U]-HOU-BLA). RESULT IS NOT GOOD.
- 48/48 death OBJs PRESENT with computed metrics (0 missing, 0 parse failures, 0 MISMATCH on every checkable condition); 4/4 predicted stubs VERIFIED as honest near-empty conversions; exact donor byte/vert/bbox parity for all 48 rows is NOT-RECOVERABLE read-only and stays [U] with the exact conditions in §4.
- No value invented, no mesh changed, no parity claim made, no approximation endorsed.
