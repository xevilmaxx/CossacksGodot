---
title: DONOR DECOMPILATION — deep documentation lane (2026-11-25)
area: donor decompilation
owner: COORD
updated: 2026-11-25
status: living
---

# 🔬 Donor decompilation — deep documentation lane

**Purpose.** Document the installed donor (`C:\Games\Cossacks 3`) *as evidence*, deeply and
cold-readably, so every 3D port decision can cite a donor path/offset or an evidence id.
This lane produces **documentation only** — no code edits, no donor copies into the repo,
no running the donor.

## Governing rules
- Donor is READ-ONLY. Read with Python `bytes` + latin-1; never exec/copy donor binaries.
- Windows host: `python` (3.14), NOT `python3`.
- Prefer Craft Anything read tools + `core_finding_record` with evidence ids when available.
  If unavailable, cite exact `path:offset` plus a short hexdump/latin-1 excerpt.
- Separate `observed` (bytes actually read) / `derived` / `inferred` / `UNVERIFIED`.
- Cross-check each important structural claim by a second method (different tool, second
  offset, header vs body, or a second agent). One grep is not proof.
- Read the existing `docs/decomp/{DA_PE,DB_SCRIPTS,DC_FORMATS,DD_MAPS,DE_AUDIO_UI}.md` and
  `investigation.cany/investigation/{brief,findings,hypotheses,plan,handoff}.md` FIRST.
  Do not re-derive from scratch: extend, correct, and deepen with new evidence. Where the
  old doc is wrong or shallow, write a `Corrections to prior docs` section.
- Private-use only: never paste donor binary blobs into the repo; short hex excerpts are OK.

## Reports (one micro-aspect per file)

| ID | Scope | Output | State |
|---|---|---|---|
| DEC-01 | PE binaries, packer, RTTI, `.cdx`/codex | `DEC_01_binaries_rtti.md` | **DONE** |
| DEC-02 | `data\scripts` full catalog + decompiled logic | `DEC_02_scripts.md` | **DONE** |
| DEC-03 | Config truth: `envscales`, `formations`, `hotkeys`, `light`, `env`, etc. | `DEC_03_configs.md` | **DONE** |
| DEC-04 | Anim/sound formats: `.oss`, `.osm`, `.aaf`, ACL | `DEC_04_anim_formats.md` | **DONE** |
| DEC-05 | Terrain formats: `terrainmesh*.osm`, heightmap, `.dds`, tile/blend | `DEC_05_terrain_formats.md` | **DONE** |
| DEC-06 | Map/editor formats: `.map`, `.aix`, `.cdx` | `DEC_06_map_formats.md` | **DONE** |
| DEC-07 | `data\cameras` + `data\shaders` full parameter dump | `DEC_07_cameras_shaders.md` | **DONE** |
| DEC-08 | UI / minimap / strings / localization definitions | `DEC_08_ui_strings.md` | **DONE** |

**Lane closed 2026-11-25.** Consolidated findings, corrections and port implications:
[`SUMMARY.md`](SUMMARY.md). Cross-lane re-verifications that amended DEC findings:
`../reports/RV_SEL_01_selection_reverify.md` (DEC-07 §8.1 refuted),
`../reports/RV_CAM_01_fov_resolution.md` (DEC-07 §8.3 refuted),
`../reports/RV_TRN_01_texgen_mask_reverify.md` (raw-byte findings supersede Craft Anything
string-index for packed binaries), `../reports/RV_TRN_02_smoothing_rules.md`,
`../reports/RV_TRN_03_water_bindings.md`.

## Cross-links
- Today's fix analysis: `../reports/DTRN_*.md`, `DSEL_*.md` (donor truth applied to today's bugs).
- Prior decomp index: `docs/decomp/`, `docs/RESUME.md` §5.
- Evidence index for all lanes: `EVIDENCE_INDEX.md` (COORD maintains).
