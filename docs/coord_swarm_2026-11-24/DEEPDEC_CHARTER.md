# DEEPDEC_CHARTER — deep donor decompilation swarm (2026-11-24)

Goal: understand donor skirmish logic as deeply as the readable code/data allow,
so the 3D port can translate rather than invent. This is a WIDE, DEEP sweep —
not a repeat of the earlier DECOMP-01…06 probes.

## Hard rules
- Donor `C:\Games\Cossacks 3` is READ-ONLY private use. Never copy donor
  binaries, textures or audio into the repository. External donor TEXT files
  may be read read-only (Python bytes/latin-1 or Craft Anything `core_text_read`).
- Use Craft Anything through `execute` with `tools.craftanything.<tool>({...})`.
  Call `enable_toolset({toolset:"native"})` / `{toolset:"formats"}` once
  (idempotent). The donor target is ALREADY OPEN as id `t_87f0f3c130b0`
  (`cossacks.exe`, sha256 87f0f3c1…). PASS `document:"t_87f0f3c130b0"` where
  accepted. NEVER call `core_target_open` or `core_target_select` — the session
  is shared by all agents.
- NEVER run Frida/runtime instrumentation, never unpack donor memory, never
  execute donor code. Consent-gated tools stay unused.
- NO source/asset/config/test/git edits. Each agent writes EXACTLY ONE report,
  the one assigned, under `docs/coord_swarm_2026-11-24/reports/`.
- Every finding: cite an evidence `id` (or exact donor `path:line` / VA / file
  offset). Separate OBSERVATION from INFERENCE. Anything unreadable = UNVERIFIED.
- Do NOT claim donor parity. Do NOT invent constants where donor data is absent.
- Earlier results are inputs, not conclusions to re-assert: DECOMP_01…06,
  TERRAIN2_01…06, AUDIT3D_01…09. Extend them with NEW evidence.

## Techniques to actually use (deep, not superficial)
`core_overview_show`, `native_functions_list`, `native_strings_find`,
`native_bytes_find` (whole-file — data-section-only string search is known to
give false negatives), `core_feature_find`, `native_api_show`,
`native_function_find`, `native_function_study(detail:"complete")`,
`native_function_pseudocode`, `core_evidence_browse` for paging big facets,
`native_address_show`, `native_address_offset_show`, `core_target_triage`,
read-only byte windows around mapped offsets.

## Assignment map (one report each)
- DEEPDEC-01 `DEEPDEC_01_camera.md` — camera subsystem: config consumers, zoom/pan math, input.
- DEEPDEC-02 `DEEPDEC_02_terrain_render.md` — terrain draw path, vertex data identity, shader equations.
- DEEPDEC-03 `DEEPDEC_03_water.md` — water descriptor/default values, shader path, shoreline.
- DEEPDEC-04 `DEEPDEC_04_fog_light_sky.md` — fog, lighting, sky/clouds, weather.
- DEEPDEC-05 `DEEPDEC_05_map_serialization.md` — .map grammar, tile grid, coordinate records.
- DEEPDEC-06 `DEEPDEC_06_models_anim.md` — .oss/.osm structure, bone/animation data.
- DEEPDEC-07 `DEEPDEC_07_fx_audio.md` — PFX semantics, sound events, emitter rules.
- DEEPDEC-08 `DEEPDEC_08_ui_minimap.md` — minimap, HUD, hotkeys, selection UI.
- DEEPDEC-09 `DEEPDEC_09_ai_economy.md` — AI, training, building, capture, economy rules.
- DEEPDEC-10 `DEEPDEC_10_function_catalog.md` — cross-cutting function/string catalog + highest-value unknowns.

## Report template
frontmatter (id, scope, date, status) -> method/tools used -> evidence table
(id, address/offset/path, finding) -> reconstructed logic -> port implications
-> UNVERIFIED/BLOCKED list -> next atomic task suggestions.
