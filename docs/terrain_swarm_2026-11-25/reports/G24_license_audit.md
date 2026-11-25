---
id: G24
ticket: TERRAIN-SWARM-WAVE-G/G24
title: "License / donor-asset compliance audit of the terrain swarm"
owner: G24 (read-only follow-up)
created: 2026-11-25
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_RUNNER__NO_CODE_EDIT__NO_PARITY_CLAIM
scope: "Exactly one file written — this report. No Godot launch, no runner job (submit/cancel/unwedge/ack/reset), no .gd/.gdshader/config/test/fixture/tool/result/asset edit, no donor file executed or copied."
charter: docs/terrain_swarm_2026-11-25/CHARTER.md
wave_charter: docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md
parity_guard: "No donor GPU A/B frame exists. Donor parity is UNVERIFIED everywhere; this audit does not claim it."
labels: [observed, derived, inferred, UNVERIFIED]
---

# G24 — license / donor-asset compliance audit

## 0. Authority and method (OBSERVED)

Read in full: `docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md`,
`docs/terrain_swarm_2026-11-25/CHARTER.md`, `app/CREDITS.md`, the licence block of
`README.md` (lines 215–224), `app/CREDITS.md`'s cross-reference `docs/WAIVERS.md`
(§Compliance statement), and the swarm consolidation `README.md` and `SWARM_BOARD.md`.
Read-only evidence: `git status --porcelain`, `git diff` (working tree vs HEAD), SHA-256
comparison of the four new report images against every file in
`C:\Users\Maxym.Oboyshev\Downloads\c3`, direct reads of the 62 `.md` reports, the new
tool and the two new test atoms, and visual inspection of the four new images. No runner
was queried or submitted; no source, asset, config, test or queue state was touched.

Governing rules applied:

- `CHARTER.md:55-69` — read-only vs implementation ownership, backups before edits,
  no invented donor constants, no donor-parity claim without a donor GPU A/B frame.
- `WAVE_G_CHARTER.md:11-13,31` — guardrails preserved; only G04 may run Godot/submit jobs.
- `README.md:220-224` — donor files are for private use by the game owner on their own
  machine, never shared; "donor code was only ever read as text; donor binaries were never
  copied or executed".
- `app/CREDITS.md:1-5,98` — donor assets come from the local install and "must not be
  shared"; private-use compliance is stated in `docs/WAIVERS.md:57-64`.

## 1. Finding 1 — donor files read only as text/data; never copied into the repo or executed (COMPLIANT, with one derived-pixel caveat in §2)

Evidence:

- Front-matter scope declarations in every read-only report explicitly state no donor copy
  and no Godot job: A01 `:7` ("no donor file executed or copied"), A12 `:239`, C03 `:203`,
  G01 `:7`, G02 `:5-7`, G05 `:9,30,367`, G11 `:11,236`, G13 `:5`, G16 `:8,60-61`,
  G20 `:8,172`, G21 `:9,293`, G25 `:8,197`. A01 `:34` puts its throwaway FFT/ACF scripts
  in `%TEMP%\opencode` (outside the repo); A11 `:226-231` likewise ran its script from
  system temp and wrote only its report plus three declared illustrations.
- Donor material was consumed as **text or numbers**: `E05_ghost_mesh_naming.md:41-42`
  reads `engcen.actor` and enumerates `.osm` byte sizes; `E02_final_stage_assets.md:27,88`
  cites `.osm`/`.prop` as inherited text evidence and explicitly declines to fabricate;
  F01/F02/F03/F04/F05 quote online documentation and local scripts by path. No donor
  binary was opened for execution.
- No donor executable, `.osm`, `.dds`, `.ogg`, `.map` or `.aaf` appears among the new or
  modified files: `git status --porcelain` lists only 8 modified tracked source/import
  files plus `variant3d/selftest.json`, 6 `inbox/backup/*.bak-B0X` text files, 2 new
  `.gd` test atoms (`t_select_rect_capture.gd`, `t_ghost_final_stage.gd`), one new
  `terrain_ab_metric.py`, and `docs/terrain_swarm_2026-11-25/`.
- The new tool `variant3d/tools/terrain_ab_metric.py` opens reference images with
  `Image.open` for statistics only (`:142-172`, `:752-844`) and writes nothing; its
  `DEFAULT_REF_FOLDER` at `:52` is a **path citation** to the owner's local
  `Downloads\c3`, matching pre-existing tool practice (`app/tools/terrain_compare.py:49`,
  `variant3d/tools/terrain_compare.py:49`, numerous `app/tools/piece_specs/*.json`).
- G02/G01 atoms write only their own result JSON and temp PNGs passed via
  `--screenshot` arguments; `t_ghost_final_stage.gd:52-53,184-192` and
  `t_select_rect_capture.gd:307-320` contain no donor data and no copy operation.
- No Godot job was run by this audit, and charter rule "only G04 runs Godot" was honoured
  by the swarm per G04's own log (zero jobs submitted).

## 2. Finding 2 — reports cite donor paths; donor binaries are not included (SUBSTANTIALLY COMPLIANT — one flag for owner attention)

Evidence for compliance:

- All donor references in the `.md` reports are path/text citations, e.g.
  `A07_color_lighting.md:29-31` (three `Downloads\c3\*.jpg` paths),
  `A09_capture_plan.md:438-439`, `A11_reference_metrics.md:16,64-78`,
  `E05_ghost_mesh_naming.md:41-42`, `B06_ghost_impl.md:177-178,202`. No report embeds a
  base64 payload, hex dump, binary blob or `data:image` URI; the only `base64` mentions
  are descriptions of the **port's own** tileblock JSON encoding
  (`A04_tile_diversity.md:36,53`; `G15_tile_measure.md:54`), not donor bytes.
- SHA-256 cross-check: none of the four new images under `reports/` is byte-identical to
  any of the 12 files in `Downloads\c3` (`no verbatim donor match` for all four).
- `A03_atlas_cells_contact.png` (959,845 B) is a CPU tiling illustration made from the
  **already-shipped** `variant3d/assets/terrain/atlas/tile_index_atlas.png` cells
  (A03 `:18-23,34`); it adds no donor binary and no new asset family.
  `A11_p0_center_2x.png` (232,148 B) is a 2× zoom of the **port's own** P0 capture only.

Flag for owner attention (not a violation of the "no donor binary copied" rule as
strictly worded, but a donor-pixel inclusion):

- `A11_reference_metrics.md:26-27,214-222` declares three illustration files written into
  the report directory. Two of them **contain cropped pixels of third-party donor
  screenshots**:
  - `A11_refA_vs_p0.jpg` (96,621 B) — left panel is the donor "ref A" ROI from
    `cossacks-3-v1-498085.jpg` (trees/cliff/grass visible), right panel is the port's P0.
  - `A11_ground_rois.jpg` (129,865 B) — 13 labelled ROIs, panels 0–11 being crops of the
    donor JPEG/WEBP samples in `Downloads\c3`.
  These are small derived composites, not verbatim donor files, and are private-use
  evidence for the owner's own machine. They are nevertheless donor-derived image content
  placed under `docs/`, which sits in tension with the stricter reading of
  "donor files ... never copied into the repo" and with the repeated report claim
  "copied no donor file into the repo" (G05 `:30,367`, G21 `:9,293`). Owner should decide
  whether to keep them as explicitly labelled private-use illustrations or remove them /
  replace with text-only tables before the `docs/terrain_swarm_2026-11-25/` tree is
  committed (it is currently **untracked** in `git status`).

## 3. Finding 3 — no new donor asset added by B01–B06/G01–G02; mip chain from shipped atlas PNGs (COMPLIANT)

Evidence:

- `git diff --stat -- variant3d/assets` shows exactly two files changed, each by one line:
  `tile_index_atlas.png.import:26` and `tile_index_atlas_winter.png.import:26`
  `mipmaps/generate=false → true`. No PNG, split part, manifest, mask, alias or remap
  file was added or modified.
- `B02_atlas_impl.md:125-145,168-179` and the landed loader code show the mip chain is
  produced **at runtime** by `_prepare_atlas_image()` (`has_mipmaps()` guard +
  `Image.generate_mipmaps(false)`) wrapping `ImageTexture.create_from_image` on the
  **existing** atlas image; level-0 pixels are byte-identical. B02 itself states
  "generating the chain on the CPU attaches real mips to the SAME base pixels"
  (`:135`) and that it is not donor-parity proof (`:194`).
- Independent check `G16_season_check.md:24-36,60,102-117,219-227`: every atlas/split PNG
  is `git blob == HEAD` with unchanged SHA-256 (e.g. summer atlas
  `A1F123A1…B84DCFBD`, 179,912,941 B; winter `5D0DD8F3…98F18E3CBADB`), both `.import`
  sidecars changed by exactly one byte, no `flags/*` key added, no mask acquired mips,
  and no file was reimported. Whole-tree grep found only two `mipmaps/generate=true`
  hits, both atlas colour sidecars.
- B01/B03/B04/B05/B06 each edited one exclusive existing source file with a
  `.bak-B0X` backup (README `:213-216`; C03/G13 audits); G01/G02 authored only NEW test
  atoms; C01's `terrain_ab_metric.py` is a new tool, not a donor asset.

## 4. Finding 4 — new tools/atoms and docs scanned for accidental donor content (COMPLIANT, aside from §2 flag)

- All 62 new `.md` files carry scope/parity guards; no donor binary payload was found by
  grep for `base64`, `data:image`, `b64decode`, `shutil.copy`, `copyfile`, `write_bytes`,
  `C:\Games\Cossacks 3` copy operations. Donor paths occur only inside citations.
- The two new atoms contain donor **citations** as comments/JSON fields
  (`t_select_rect_capture.gd:63-64,299-305,610-611`;
  `t_ghost_final_stage.gd:14-17,39-42,180-181`) and no donor constants masquerading as
  port truth — donor-derived numbers are labelled `PORT APPROX` / `DONOR_EPSILON_M` with
  source lines. Neither atom reads or writes a donor file.
- No new donor asset appears anywhere in `git status`; the 6 new backups are text copies
  of already-shipped port source files (e.g. `game.gd.bak-B03`, 238,546 B), not donor data.

## 5. Compliance statement

**OBSERVED / DERIVED.** With the single caveat in §2, the terrain swarm respected the
licence rules: donor installed-game files and the 12 reference screenshots were accessed
read-only as text/data for measurement and citation; no donor binary was copied verbatim
into the repo or executed; donor paths in reports are citations, not embedded donor files;
B01–B06/G01–G02 added no new donor asset — B02's mip chain is generated in memory from
the already-shipped atlas PNGs, and the only asset-tree changes are two one-line `.import`
flag edits. The 2D `app/` port was untouched by the swarm (G11). The private-use,
never-redistribute stance of `README.md:220-224` and `app/CREDITS.md:1-5` is restated in
the reports' parity guards.

**UNVERIFIED.** Donor parity is **not claimed** by this audit or by any report: no donor
GPU A/B frame exists, and no metric, citation or crop can establish it. This audit is a
licence-hygiene review only; it does not certify any gate result, visual PASS, or overall
"result is good".

## 6. Items needing owner attention

1. **A11 donor-screenshot crops** (`A11_refA_vs_p0.jpg`, `A11_ground_rois.jpg`) — derived
   donor pixels now sit in the untracked `docs/terrain_swarm_2026-11-25/` tree. Decide:
   keep as explicitly labelled private-use illustrations, or remove/replace before any
   commit or sharing. No verbatim donor file is present (SHA-256 check), so this is a
   policy clarification, not a proven breach.
2. **Commit hygiene** — `docs/terrain_swarm_2026-11-25/`, the 6 `.bak-B0X` files and the
   two new atoms/tool are all untracked; the tracked source edits and `selftest.json`
   are modified but uncommitted. Ensure the §2 decision is applied before the docs tree
   is staged.
3. **`docs/WAIVERS.md` & `app/CREDITS.md`** remain accurate for this swarm: no new donor
   family was introduced, so no waiver/credit update is required by B01–B06/G01–G02.

*End of G24. Read-only audit: one report written; no runner, no code, asset, config, test,
queue or Godot job touched; no donor-parity claim.*
