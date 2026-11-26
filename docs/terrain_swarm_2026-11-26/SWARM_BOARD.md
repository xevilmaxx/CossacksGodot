# SWARM BOARD — 2026-11-26 donor-first terrain port

Status key: `QUEUED` → `RUNNING` → `LANDED` → `INTEGRATED`. COORD updates this
file when a report lands. Workers never edit this file.

| ID | Wave | Assignment (one report each) | Owner file | Status |
|---|---|---|---|---|
| D01 | Binary | RTTI `X*` class → concrete CODE function anchor map (vtable/call graph, not string xrefs) | `reports/D01_rtti_function_anchors.md` | QUEUED |
| D02 | Binary | Seed (`randkey1/2`) + `RandomExt` RNG algorithm; determinism contract | `reports/D02_seed_rng.md` | QUEUED |
| D03 | Binary | Terrainmask TGA load → gauss blur → 3-pass smoothing chain | `reports/D03_mask_pipeline.md` | QUEUED |
| D04 | Binary | `.map` / `TMapTerrainDataTile` binary layout: height, tex, collision[4], owner | `reports/D04_map_format.md` | QUEUED |
| D05 | Binary | Relief stamp: pattern float grid → height, clamp/scale/blend order | `reports/D05_relief_stamp.md` | QUEUED |
| D06 | Binary | Water level, shore smooth, current/glints, cliff face selection | `reports/D06_water_shore.md` | QUEUED |
| D07 | Binary | Resource placement: mine counts, stone/forest rings, deposit amounts | `reports/D07_resources_bin.md` | QUEUED |
| D08 | Binary | Tile id → atlas cell → shader selection; `bmTransparency` consumption | `reports/D08_tile_select_bin.md` | QUEUED |
| F01 | Data | `.pattern` binary format full spec + decoder prototype | `reports/F01_pattern_format.md` | QUEUED |
| F02 | Data | `pattern.lib` (30 MB) index, record boundaries, family catalogue | `reports/F02_pattern_lib.md` | QUEUED |
| F03 | Data | All gen cfg constants (`globalparams`, `localparams`, `mapcover`, `tilesmooth*`) | `reports/F03_gen_config.md` | QUEUED |
| F04 | Data | Terrainmask TGA channel semantics, mask inventory/counts per shape | `reports/F04_masks.md` | QUEUED |
| F05 | Data | `reftile.mat` + `texturemap.inc` → tile id / block PNG mapping | `reports/F05_tile_mapping.md` | QUEUED |
| F06 | Data | `alpha.bmp` / `alphavert` masks, `bmTransparency` exact semantics | `reports/F06_alpha_masks.md` | QUEUED |
| F07 | Data | Mill / field / pump assets and pattern families | `reports/F07_mill_fields.md` | QUEUED |
| F08 | Data | Forest / stone / mine pattern families, object contents, weights | `reports/F08_flora_minerals.md` | QUEUED |
| F09 | Data | `editor.inc` + `editor.aix` DScript terrain generation commands | `reports/F09_editor_script.md` | QUEUED |
| F10 | Data | DLC / expansion terrain additions relevant to skirmish | `reports/F10_dlc_terrain.md` | QUEUED |
| P01 | Port | Current variant3d terrain pipeline end-to-end (read-only trace) | `reports/P01_pipeline_audit.md` | QUEUED |
| P02 | Port | Donor-derived terrain asset inventory in `variant3d/assets/terrain/**` | `reports/P02_asset_inventory.md` | QUEUED |
| P03 | Port | Tests / gates / capture tooling readiness | `reports/P03_gates_capture.md` | QUEUED |
| P04 | Port | Existing decoder tools reuse audit (`tools/*`) | `reports/P04_tool_audit.md` | QUEUED |
| P05 | Port | 2D `app/` donor-derived terrain pieces reusable (read-only) | `reports/P05_2d_reuse.md` | QUEUED |
| P06 | Port | Distill 2026-11-25 terrain reports: root causes + rejected approaches | `reports/P06_prior_wave_distill.md` | QUEUED |
| A01 | Design | Donor-faithful terrain data model for variant3d | `reports/A01_data_model.md` | QUEUED |
| A02 | Design | Donor-faithful generation algorithm (stage order + constants) | `reports/A02_algorithm.md` | QUEUED |
| A03 | Design | Asset conversion pipeline: donor → runtime assets (no donor binaries) | `reports/A03_asset_pipeline.md` | QUEUED |
| A04 | Design | Landscape props: hills/mountains/fields/sea/shore/forests/mines | `reports/A04_landscape_props.md` | QUEUED |
| A05 | Design | QA / seed replay / histogram / donor A-B harness | `reports/A05_qa_harness.md` | QUEUED |
| A06 | Design | Integration + rollback plan preserving all gates | `reports/A06_integration.md` | QUEUED |
| D09 | Binary | Decompile `editor.exe` terrain forms/handlers + parameter map | `reports/D09_editor_binary.md` | QUEUED |
| X01 | Binary | Bulk pseudo-C corpus of `cossacks.exe` + categorised function index | `reports/X01_decomp_corpus.md` | QUEUED |
| X02 | Binary | Bulk pseudo-C corpus of `editor.exe` + categorised function index | `reports/X02_editor_corpus.md` | QUEUED |

## Landed reports (COORD integration log)

- `A01_data_model.md` — LANDED (spec §01 pending)
- `A02_algorithm.md` — LANDED (spec §10 pending)
- `A03_asset_pipeline.md` — LANDED → integrated into `spec/11_ASSET_CONVERSION.md`

## Integration gates (COORD only)

- [ ] All 30 reports landed and cross-checked for contradictions.
- [ ] `docs/terrain_swarm_2026-11-26/spec/` written from cited findings.
- [ ] Decoder tools landed and validated against donor bytes.
- [ ] Fresh terrain module composed; gates green; `app/` unchanged.
- [ ] Owner-facing capture + honest parity verdict.
