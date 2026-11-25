---
id: TERRAIN-SWARM-2026-11-25
title: "Terrain visual-quality swarm — kill the artificial patterns, approach the donor samples"
owner: COORD (this session)
created: 2026-11-25
status: ACTIVE
labels: [observed, derived, inferred, UNVERIFIED]
---

# CHARTER — terrain visual-quality swarm

## 1. Problem (OBSERVED)

Owner report: *"I still don't like terrain ... there are artifacts on terrain, some sort of
patterns; those are so far away from samples."*

Visual evidence opened this session:

| Role | Path | What it shows |
|---|---|---|
| Current render (latest P0 frame) | `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\p0fresh01\p0_final_formula.png` | 1280x720, flat uniform **olive** field. Fine grain, **faint diagonal streaks / repeating bands**, soft blocky patches. No large-scale organic variation. |
| Earlier render | `...\terraindarkfix2-p0-r3\smallmap64_terrain_only.png` | same class of artifact |
| Reference sample A | `C:\Users\Maxym.Oboyshev\Downloads\c3\cossacks-3-v1-498085.jpg` | organic grass with **large soft green mottling**, dark/light patches, ravines/cliffs with grey rock faces, trees; **no grid, no diagonal streaks, no repetition** |
| Reference sample B | `C:\Users\Maxym.Oboyshev\Downloads\c3\articolo-787.jpg` | same: rolling relief, patchy grass, natural transitions |
| Reference folder | `C:\Users\Maxym.Oboyshev\Downloads\c3\` | 12 donor screenshots — the visual target |

The gap is **visual**, not functional: the 3D gates are green, but the ground looks synthetic.

## 2. Primary suspects (INFERRED — to be confirmed by the diagnosis wave)

All line numbers refer to the current tree.

1. **Hard 2 m repetition.** `variant3d/shaders/terrain_tileindex.gdshader:214-218,392`:
   `rgb = tile_rgb(v_tile, fract(v_st * uv_repeat))`, `uv_repeat = (0.5, 0.5)`,
   world X/Z texgen. One atlas cell is repeated verbatim every 2 m; at a shallow camera
   this aliases into diagonal streaks/moiré and reads as a tiled pattern.
2. **Pseudo-random alpha patch pattern.** `:365-378` `alpha_patch_uv()` decomposes the
   tile id into `dir / variant / half / opposite` and picks one of 32 64² mask patches.
   The tile→patch rule is a PORT APPROX (DALPHA-01/02: engine rule CONFIRMED_UNVERIFIED).
   Coupled with `mask_to_alpha=1` at `:427` this folds mask intensity into RGB, producing
   repeated dark blotches — the "patterns" the owner sees.
3. **Nearest/mipmap filtering.** `:60` `filter_nearest_mipmap` + `fract()` sampling:
   nearest magnification on a minified repeat is the classic source of banding.
4. **Flat/olive palette.** `:150-158` donor sun/ambient/diffuse + `rgb * a * v_packed`
   yield a uniform olive; the donor sample's grass has larger-scale hue/luma variation
   and grey cliff faces.
5. **No large-scale variation in tile data.** `variant3d/scripts/game.gd:_assign_tileblocks()`
   + donor smoothing produce many cells of the same handful of tile ids (offline
   top-5 72.68% → 58.52% after TRN-DATA). One id repeated = one atlas cell repeated.
6. **Relief under-read.** Real donor relief grids exist (DPATTERN-01/RELIEF-01/02) but
   the screenshot is near-flat; cliffs/ravines that break up the surface are missing.

Do NOT assume any of these is confirmed. The diagnosis wave must cite code/shader/pixels.

## 3. Guardrails (binding on every worker)

- **Observed vs inferred vs UNVERIFIED** must be separated in every report. Donor parity
  stays UNVERIFIED unless a real donor GPU A/B frame is produced (none exists).
- **No test weakening**: no threshold lowered, no assertion deleted, no
  `expected_pre_fix_failure` flipped without a landed fix. No synthetic dither/noise
  field per decision S-25-09 (recreates the 2D checkerboard regression). No invented
  donor constants — label every substitute PORT APPROX.
- **One Godot at a time**, via `python variant3d\tools\godot_runner.py run --id <UNIQUE>`
  only. Default to **no runner jobs** for analysis workers. Query `status` before
  submitting; a job 581 was in flight at charter time.
- **Backups** before any edit: `inbox/backup/<file>.bak-<TICKET>`.
- **Disjoint ownership**: analysis agents edit ONLY their report; implementation agents
  may edit ONLY the file named in their ticket. COORD integrates.
- **Windows**: use `python`, not `python3`. PowerShell `;` not `&&`.

## 1b. Additional owner requirements (same session)

1. **Research online** the donor's real quality/logic, not just local files: the
   `cossacks-3-almanac` evidence docs (EN/RU), official patch notes, reviews and
   mod documentation. Record what the donor actually does for terrain, selection
   and building placement, with URLs.
2. **Selection quad is still not OK.** Re-audit the marquee/quad end-to-end
   (draw, geometry, lifetime, hit semantics), including the donor quirk "box selection
   not working after you select a wall" (a donor bug we should NOT copy). The 2016-11
   official patch "selection frame dragging ability" confirms drag-selection is canonical.
3. **Phantom/ghost building preview must show the LAST (completed) build stage,
   not the first.** Today the ghost shows the earliest foundation stage. Donor
   ghost-preview convention: a translucent hologram of the *finished* structure
   (green valid / red blocked). The ghost must be pixel-honest about footprint.

## 4. Task board

Wave A — DIAGNOSIS (read-only, one report each): A01..A12
Wave B — FIX PROPOSALS / DISJOINT IMPLEMENTATION: B01..B12
Wave C — VERIFICATION / QA: C01..C10
Wave D — SELECTION QUAD / UI: D01..D06
Wave E — BUILDING GHOST FINAL STAGE: E01..E05
Wave F — ONLINE DONOR RESEARCH: F01..F05

Full assignments are in the dispatch prompts. Output root:
`docs/terrain_swarm_2026-11-25/reports/`.

## 6. Online sources gathered by COORD (seed the research wave)

- `https://github.com/anyalink99/cossacks-3-almanac` — EN/RU technical evidence;
  `internals_en/scripts/building_mechanics_evidence.md`,
  `internals_en/scripts/map_generation_evidence.md`, `docs_en/recon/...`.
- `https://niocreations.ru/cossacks-3-almanac/docs_en?p=recon/world/economy/building_mechanics.md`
  — construction/repair/destruction, collision-mask footprint, builder positions.
- `http://cossacksworld.ucoz.co.uk/index/new_buildings/0-349` — build stages are
  `<sid>1..4.osm`, death stages `<sid>_death1/2.osm`, registered in `<sid>.actor`
  (`LODList.Items[0].MeshObjects.LoadFromFile`); editor `bstage X` sets the stage %.
- `https://store.steampowered.com/news/app/333420/view/4042499938190999083` —
  official 2016-11 patch: drag selection frame added.
- `https://www.gamepressure.com/cossacks3/user-interface/zd91b1` — HUD layout,
  hotkeys (Shift add, Z/Ctrl/double-click select-same-type, Ctrl+A, right-click
  remove from queue, Shift ×5, Ctrl unlimited).
- `https://gamemechanicshoard.com/mechanic/ghost-preview` — ghost preview = full
  hologram, green/red validity, "lying ghost" pitfall.
- `https://cossackshq.net/c3-mod-new-terrain-mod`, NTM pages — donor terrain
  variety context (200+ patterns, animated trees, seasons, map masks).
- Reviews (HeyPoorPlayer, RPS, WGB, NoobFeed) — noted donor's own weak points:
  bland uniform green terrain, clunky UI/formation squad creation, donor bugs
  such as box-select failing after selecting a wall. Use as *context*, not as
  an excuse to reproduce defects.

## 5. Definition of "result is good"

1. A fresh windowed 64² and a real-map capture show **no visible repeating diagonal
   streaks, no grid/checker mosaic, no repeated dark blotches**.
2. The ground shows **multi-scale organic colour variation** and relief/shore that read
   like the reference samples, with no new seams, z-fighting, or black rows.
3. Existing gates stay green: variant selftest 29/29, uitest 17/17, `t_render_mode`,
   `assert_clean` CLEAN; 2D `app/` untouched.
4. Every change carries a donor citation or an explicit PORT APPROX label.

*End of charter.*
