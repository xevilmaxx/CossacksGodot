---
title: Deep audit — PORT terrain assets (converted / wired / unwired / missing)
owner: TPA-2
decision: D-22
updated: 2026-11-21
status: complete
scope: read-only. No Godot run, no code edit, no asset edit, no donor file copied.
---

# 🔬 Deep audit — terrain assets on the port side

> [!IMPORTANT]
> Read-only inventory of `app/assets/terrain/**` against the four renderer scripts
> named in the brief (`world.gd`, `game.gd`, `pattern_gen.gd`, `main.gd`; plus
> `mapgen.gd`, which owns the mask manifest). **A file existing is not evidence it
> is drawn.** Every WIRED verdict below rests on a load/draw site with a cited
> `file:line`; everything else is UNWIRED or MISSING. Labels follow
> `docs/audit/README.md` / `SWARM_OPS.md` §5b-QUALITY: `observed` (counted, read
> or measured here), `derived` (computed from observed data), `inferred`
> (plausible but not proven). Unmeasurable claims are `UNVERIFIED`, never `done`.

**Files owned/changed by this agent:** `docs/audit/TERRAIN_PORT_ASSETS.md` only.
**Godot runs:** none. **Donor assets accessed:** none (`SWARM_OPS.md` §3.5).
**Runner job ids generated:** none.

---

## 1. Sources / method

**Inputs (all read-only):**
- Prior docs: `ASSET_AUDIT.md`, `docs/TERRAIN_GEN_RESEARCH.md`,
  `docs/research/RC_TERRAIN.md`, `docs/audit/RENDER.md`, `docs/audit/README.md`,
  `SWARM_OPS.md`, `app/CREDITS.md`.
- Asset tree: `app/assets/terrain/**` (PowerShell `Get-ChildItem -Recurse`,
  counts by extension; `git ls-files app/assets/terrain` for tracking).
- PNG dimensions/modes: Pillow 12.1.1 (`Image.open(...).size/.mode`) over **all**
  691 PNGs under `app/assets/terrain` for resolution-consistency grouping, and
  targeted samples named in §2.
- JSON structure: Python `json.load` on `masks/manifest.json`,
  `patterns/donor_patterns.json`, `structs/{presets_summer,smooth_summer,
  tileblocks,water}.json`.
- Wiring: case-sensitive ripgrep of `res://assets/terrain/` across
  `app/scripts/*.gd` (10 hits, listed verbatim in §2 note) plus family-name
  greps (`winter`, `diffusewaves`, `deco_png`, `groundexp`, `envfield`,
  `christmastree`, `dmask`, `d_0[0-9]`, `presets_winter`, `_winter`) across the
  whole repo; tool-side references in `app/tools/*.py` were checked separately
  and are **not** counted as port wiring (they feed `gen_variant_maps.py`, a
  Python preview tool, not the Godot renderer).

**Method note (`observed`):** the complete set of `res://assets/terrain/...`
literals/constructors in `app/scripts/*.gd` is exactly:
`mapgen.gd:24` (manifest), `mapgen.gd:125` (mask PNG by manifest `file`),
`pattern_gen.gd:19` (donor_patterns.json), `world.gd:537` (decals_png),
`world.gd:675` (water_png/diffusewaves2.png), `world.gd:702` (blocks/%s.png),
`game.gd:878` (presets_summer.json), `game.gd:883` (smooth_summer.json),
`game.gd:979-980` (tile_lowground.png / tile_highground.png). Any asset family
not reachable through one of these ten sites is UNWIRED by definition. This is a
stronger test than the earlier path-literal audit: it also excludes assets that
exist on disk but are only named in comments, preview scripts or manifest data
that is never loaded.

---

## 2. Full asset family table

Counts are `observed` (files on disk); dimensions are `observed` (Pillow).
"Wired?" is `derived` from the cited load site. `n/a` dimension = no PNG in that
folder.

| Path | Family | Count | Dimensions (Pillow) | Wired? | Evidence file:line | Gap |
|---|---|---|---|---|---|---|
| `app/assets/terrain/blocks/` | grass1..10 | 10 PNG (+10 .import) | all 1024×1024 RGB | **WIRED** (name via preset index; explicit base/mix) | `game.gd:878-882` loads `presets_summer.json` → `tbl_names`; `world.gd:702` `blocks/%s.png`; `world.gd:806` grass1; `:836` grass7 | none |
| " | grass_ground1..3, grass_rock1, grass_sand1..2, ground1 | 7 PNG | 1024×1024 RGB | **WIRED** (preset index; ground1/grass_ground2 in role map) | `world.gd:841` `{1:"ground1",2:"grass_ground2",4:"grass_sand1",5:"rock1"}`; `smooth_summer.json` via `game.gd:883` | grass_ground1/3, grass_rock1, grass_sand2 reachable only via smoothing/index, not a literal |
| " | rock1..9 | 9 PNG | 1024×1024 RGB | **WIRED** (index + role map rock1; `:1262` rock9 literal) | `world.gd:841`; `game.gd:1262` | none |
| " | sand1..9 | 9 PNG | **7× 1024×1024**, **2× 256×256** (`sand1.png`, `sand2.png`) | **WIRED** by index; resolution inconsistent | `world.gd:702`; `structs/smooth_summer.json` (sandsea/sandrock pairs) | `sand1/sand2` are 1/16 the area of siblings; `_mirror_tileable` resizes to 512², so grain density differs (`derived`) |
| " | sandrock1..6, sandsea1..6 | 12 PNG | 1024×1024 RGB | **WIRED** (smoothing recipes only) | `structs/smooth_summer.json` + `game.gd:883-885`, `world.gd:702` | no literal reference; reachable only through smoothed tile choice |
| " | desert1..12 | 12 PNG | 1024×1024 RGB | **PARTIAL** — present in `presets_summer.json:113-124`, no biome selection literal | `presets_summer.json:113-124`; `game.gd:878` | desert **season** does not select these; it applies a flat tint (`world.gd:880-890`, `data.gd:194`). No `desert` token in `game.gd` (`observed` grep) |
| " | **winter0..26** | **27 PNG (+27 .import)** | **all 1024×1024 RGB** | **UNWIRED** | no `winter` reference in any `.gd` (`observed`: repo-wide grep returns only `world.gd` comments :728/:809 about dmask); absent from `presets_summer.json` | top beauty gap — real donor snow art unused; only tint `Color(0.86,0.91,1.0)` at `data.gd:193` |
| " | test0..25 | 26 PNG | 1024×1024 RGB | **WIRED** by preset index | `presets_summer.json:73-111,101-111`; `world.gd:702` | donor test/UV plates are shipped and selectable; low semantic value |
| `app/assets/terrain/water_png/` | diffusewaves0..7 | 8 PNG (+8 .import) | **diffusewaves0,1 = 256×256**; **2..7 = 512×512**, all RGB | **PARTIAL** — only `diffusewaves2.png` is loaded | `world.gd:675` (waves2 only); `world.gd:689-691` (4 phase crops of that single sheet) | 7 of 8 variants unwired in `.gd`; `copy_assets.py:128` names only 0 and 2; `gen_variant_maps.py:185` globs all 8 (preview tool only) |
| `app/assets/terrain/deco_png/` | christmastreed.png | 1 PNG (+.import) | 1024×1024 RGB | **UNWIRED** | no `.gd` reference; `copy_assets.py:122` converts it; `gen_variant_maps.py` never loads it | donor `christmas new_year6-10` family also absent from `donor_patterns.json` (see patterns row) |
| " | envfieldd.png / envfielddw.png | 2 PNG | 512×512 RGB | **UNWIRED** | `gen_variant_maps.py:188` only (preview tool); no `.gd` reference | donor field plates never drawn by Godot renderer |
| " | groundexp0..3.png | 4 PNG | 512×512 RGB | **UNWIRED** | `copy_assets.py:125-127` only; no `.gd` reference | no ground-explosion/decal placement path in `world.gd` |
| `app/assets/terrain/dmask/` | d_00..d_23.png | 24 PNG (+24 .import) | **all 64×64 RGBA** | **UNWIRED (vestigial)** | `world.gd:727-750` no longer reads dmask files, returns `[]`; `main.gd:883` still assigns it; `docs/audit/RENDER.md` §B.2 | dead array + stale comments; not a beauty gain — active seam defence is `_alpha_mask` (`world.gd:754-761`) |
| `app/assets/terrain/decals_png/` | `<nation><sid>d.png` building plates | **226 PNG** (of 462) | 1024×1024 RGBA ×430; 512×512 RGBA ×24; 128×128 RGBA ×8 | **WIRED** (subset) | `world.gd:533-542`, path `%s%sd.png` :537 | loader requests only the `d` form; see next rows for the unaddressable remainder |
| " | `<nation><sid>dw.png` winter plates | **226 PNG** | same mixed set (incl. all 8× 128²) | **UNWIRED** | `%s%sd.png` at `world.gd:537` cannot produce a `w` suffix | winter snow plates for every building unused |
| " | bldsiz1..7.png, helper1..3.png | **10 PNG** | 512×512 RGBA (bldsiz/helper in the 24-file 512² group) | **UNWIRED** | no literal; `%s%sd.png` requires a nation+sid pair | donor helper/size plates unused |
| `app/assets/terrain/decals/` | raw donor `.dds` plates | 6 `.dds` + 6 `.dds.uid` (**0 PNG**) | n/a | **UNWIRED / licence exposure** | mentioned only in comment `world.gd:527-530`; `app/CREDITS.md:15-20`; `ASSET_AUDIT.md:77-81` | converted twins exist in `decals_png/`; raw DDS retained as reference |
| `app/assets/terrain/decals_dds/` | raw donor `.dds` + descriptors | 462 `.dds` + 4 `.lib` + 4 `.mat` + 462 `.uid` = **932 files** (0 PNG) | n/a | **UNWIRED / licence exposure** | `ASSET_AUDIT.md:75-82`; no `.gd` runtime use (`.dds` only in comments `world.gd:3,6,66,130`) | 462+6 = 468 tracked donor DDS; private-use only, never redistribute |
| `app/assets/terrain/masks/` | `manifest.json` + 7 family dirs | **1 JSON + 56 PNG** (7×8); 113 git-tracked files | all **320×320 RGB** | **WIRED** | `mapgen.gd:24` (manifest), `mapgen.gd:125` (mask file load); families land/nowater2/med/peninsulas/islands/continents/continent, 8 masks each | none for these 7; **MISSING** Lakes/Coastal/River/Desert/Arctic families (`RC_TERRAIN.md:113`, G6) |
| `app/assets/terrain/structs/` | presets_summer.json, smooth_summer.json | 2 JSON | n/a | **WIRED** | `game.gd:878`, `game.gd:883` | **MISSING** `presets_winter.json` / `smooth_winter.json` (only summer exists) |
| " | tile_lowground.png, tile_highground.png | 2 PNG (+2 .import) | **320×320 RGB** | **WIRED** | `game.gd:979-980`, applied at `:982-1006` | none |
| " | tileblocks.json | 1 JSON (245 entries) | n/a | **UNWIRED** | no `.gd` reference (repo-wide grep); 121 `*_winter` names have **0 overlap** with the 27 `winter*.png` stems (`derived`) | misleading donor metadata; winter mapping not implemented |
| " | water.json | 1 JSON (`{active, note}`) | n/a | **UNWIRED** | no `.gd` reference | dead config stub |
| `app/assets/terrain/patterns/` | donor_patterns.json | 1 JSON, **37 families / 266 patterns** | n/a | **PARTIAL** | `pattern_gen.gd:19` loads it; only 11 families named literally (`:182,204,241-243,255-261`) + 6 desert remaps reachable via `home()` `:125-128` → **17/37 reachable** | **20 unwired families** (§3); `dcr1` at `pattern_gen.gd:261` is a *pattern name*, not a family → `pick()` returns "" (no-op) |
| `app/assets/terrain/` (root) | legacy grass1..10, dirt1, grasssand1..2, ground1..3, rock1..3, rockgrass1 | **20 PNG (+20 .import)** | 7× 1024×1024, 13× 256×256 | **UNWIRED** | no `.gd` reference; `app/CREDITS.md:8-13` documents the older flat copy layout | superseded by `blocks/`; retained (tracked) legacy duplicates |

**Totals (`observed`/`derived`):** 691 PNG under `app/assets/terrain` (691 with
`.import` — see §4 claim 3); 468 raw donor `.dds`; 8 donor descriptor files;
1 mask manifest + 1 pattern JSON + 4 structs JSON; 920 bytes-level distinct
asset files are not claimed here. Block PNGs 112 = 10+7+9+9+12+12+27+26.
Decals_png 462 = 226 `d` + 226 `w` + 10 helper/size.

---

## 3. Unwired / missing high-value assets (beauty-wave candidates)

Ranked by expected visible gain × conversion cost. All entries are `observed`
on disk and `derived` unwired from §2 unless marked.

| Asset | Why it helps beauty | Code change needed | Target file |
|---|---|---|---|
| **blocks/winter0..26.png** (27× 1024²) | Replaces the flat blue-white multiplicative tint (`world.gd:880-890`, `data.gd:193`) with the donor's actual snow-textured ground — the single largest visible seasonal gap (RC_TERRAIN G3, #2 ranked gap). | Add a season-aware block-name pool: in `_season_key()` choose `"winter"` pool, map each summer block name to `winterN`, and pass that name to `_block_img()` at `:702`, `:806`, `:836`, `:841`. Needs a new winter preset table (asset ticket below); do **not** repoint `presets_summer.json`. | `app/scripts/world.gd` (pool selection at `:695-717`, `:798-875`) |
| **deco_png/groundexp0..3.png + envfieldd/envfielddw.png** (6× 512²) | Donor ground-explosion scorch and field plates: worn earth/farm texture variety that the current procedural dirt ellipse cannot reproduce. Already used by the Python preview tool (`gen_variant_maps.py:185-190`) but invisible in Godot. | Add a ground-decal draw pass in the resource/decor layer that loads these PNGs by explicit path and stamps them at existing farm/resource-node positions; key winter→`envfielddw`. | `app/scripts/world.gd` (new decal pass near `:1064` `_prop_tex` / resource layer) |
| **water_png/diffusewaves0,1,3..7.png** (7 of 8 sheets) | 8 distinct donor water sheets instead of 4 phase-shifted crops of one 512² sheet (`world.gd:689-691`) — materially less repetitive shimmer on lakes/coasts. Note waves0/1 are 256² (loader must normalize). | Replace the single hard-coded `diffusewaves2.png` load at `:675` with an 8-file loop; build `variants[3]` frames from different sheets, normalizing the two 256² sheets via `_mirror_tileable`. | `app/scripts/world.gd` (`_prep_variants`, `:672-693`) |
| **deco_png/christmastreed.png** (1× 1024²) + donor `christmas new_year6-10` family | Festive prop for a Winter season; asset exists but its placement family is **MISSING** from `donor_patterns.json` (37 families contain no `christmas`/`new_year` — `observed`). | Two scoped changes: add the family's cell footprints to the pattern JSON (asset ticket), then add a winter-only family entry to the `recipes` table (`pattern_gen.gd:249-265`) and a prop draw case in `world.gd`. | `app/scripts/pattern_gen.gd` (recipes), `app/scripts/world.gd` (prop draw) |
| **decals_png `<nat><sid>dw.png`** (226 winter plates) | Snow/dirt variants of every building ground plate; today a winter match still draws the summer `d` plate (`world.gd:537`). | In `_bld_decal()`, after building `key`, select the `dw` filename when `_season_key()` is winter, with `d` fallback. | `app/scripts/world.gd` (`:533-542`) |
| **20 unwired donor pattern families** (of 37) — esp. `forests_leaf_big/medium/small`, `forests_pine_big/medium`, `forests_pinefir_*`, `forests_spruce_*`, `hills_light`, `decor_big`, `desert_mountains/forests_*` | Weighted donor footprints give deciduous belts, taller pines, extra hill/decor clumping — the "pattern stamping" look the port currently approximates with 6 families. Footprint data already in `donor_patterns.json`; no PNG needed. | Extend `recipes` at `pattern_gen.gd:249-265` with one family per ticket (SWARM_OPS §3.2 scope). Visual proof that each family draws a distinct prop is **UNVERIFIED** — world.gd prop art is procedural. | `app/scripts/pattern_gen.gd` (recipes table) |
| **dmask/d_00..d_23.png** (24× 64²) | Low value: `RENDER.md` §B.2 shows the operative anti-seam path is the alpha grid, not dmask. **Do not wire for beauty**; instead retire the dead `terrain_masks` array and fix stale comments. | Delete/gate `_build_masks`' legacy return + `main.gd:883` assignment; correct comments at `world.gd:647,668-669,690`. | `app/scripts/world.gd` + `app/scripts/main.gd` (separate tickets) |
| **MISSING block faces** `sand1f..9s`, `rock1vf..9vs`, `alpha0a/b/c` (39 preset names, 0 PNG) | Donor sand/rock face + alpha plates give smooth shore and cliff transitions; today `_block_img()` falls back to a flat 64² color (`world.gd:703-705`). These are convert-or-lose gaps, not unwired files. | No code change until converted; then add PNGs under `blocks/`. Asset ticket only. | new files in `app/assets/terrain/blocks/` |

**Rejected as beauty candidates (`derived`):** `decals/` + `decals_dds/` raw
DDS (converted twins already exist; converting them again adds no pixels and
increases licence exposure), `structs/water.json` (empty stub), root-level
legacy PNGs (duplicates of `blocks/`).

---

## 4. Claim table

| # | Claim | Evidence | Verification method | Verdict | Correction needed |
|---|---|---|---|---|---|
| 1 | "winter0..26 are converted but unwired; no season texture swap in `world.gd`" (`docs/TERRAIN_GEN_RESEARCH.md:73`, `docs/research/RC_TERRAIN.md:117-120`) | `blocks/winter*.png` 27 files, all 1024²; zero `winter`/`_winter` tokens in any `.gd`; season path is a tint at `world.gd:880-890` and `data.gd:191-197` | Pillow count + repo-wide case-sensitive grep + source read | **CONFIRMED** | none; this audit adds the exact count/dimension and target lines |
| 2 | "dmask masks are wired into terrain blending / anti-seam" (status-doc phrasing corrected in `docs/audit/RENDER.md` §B.2) | `world.gd:727-750` builds only ter_white/black/blue/blueA, returns `[]`; `main.gd:883` assigns it; no draw read | Re-read both sites + `git grep terrain_masks` | **CONTRADICTED** (independently of RENDER.md) | code ticket: remove dead array + fix comments; no behaviour change |
| 3 | "PNG files without `.import`: 0" (`ASSET_AUDIT.md:18`, scoped there to all assets) | Python `glob('**/*.png')` under `terrain` → 691; `not os.path.exists(p+'.import')` → 0 | Filesystem walk over the whole terrain subtree | **CONFIRMED** for terrain | none. Note the 468 `.dds` have `.uid` but no `.import` — expected, they are not Godot imports (`observed`) |
| 4 | "`decals_png/` holds 924 files" (`ASSET_AUDIT.md:79`) | 462 PNG + 462 `.import` = 924 | Extension count | **CONFIRMED** | clarify wording: 924 *files* = 462 textures, not 924 textures |
| 5 | "468 tracked donor `.dds` decals" (`ASSET_AUDIT.md:77`) | `decals_dds/` 462 + `decals/` 6 = 468; `.lib`×4 + `.mat`×4 | Extension count + `git ls-files` | **CONFIRMED** | none |
| 6 | "the donor's water is animated; the port uses a single fixed still" (`RC_TERRAIN.md:133-134`, G8) | `world.gd:675` loads waves2 only; `:689-691` derives 4 crops from that one sheet; 7 other sheets unwired | Source read + family grep | **PARTIAL** — shimmer exists, multi-sheet animation does not | code ticket for 8-sheet variant loop |
| 7 | "season/desert selects a different tile-block family" | `game.gd` contains no `winter`/`desert` literal (`observed`); desert blocks are only preset indices `:113-124`; winter is a tint (`data.gd:194`) | Grep + preset/tileblock cross-check | **CONTRADICTED** as a family swap; tint-only path CONFIRMED | implement winter pool (code ticket) before claiming a texture swap |
| 8 | "`tileblocks.json` supplies the winter tile set" | 121 `*_winter` names, **0** share a stem with `winter0..26.png`; file has no `.gd` load site | Python set intersection + grep | **CONTRADICTED** | do not use `tileblocks.json` as the winter mapping; author a new preset table |
| 9 | "donor pattern families from `generator.cfg` are wired into the port" (`donor_patterns.json` present) | 37 families in JSON; 11 named in `pattern_gen.gd` + 6 desert remaps = 17 reachable; 20 unreachable; `dcr1` at `:261` is a pattern name, not a family | Python parse of JSON families + line-by-line read of `pattern_gen.gd` | **PARTIAL / CONTRADICTED** for "all" | 20 one-family tickets; fix or remove the `dcr1` no-op recipe |
| 10 | "`home()` remaps every family to a valid desert family in winter/desert biome" | `pattern_gen.gd:125-128` blindly prefixes `desert_`; `families` has `desert_forests_big/medium/small/unique` but **no** `desert_forests_pine_small` or `desert_forests_mixed_medium`, which `:242-243` request | Set membership check against parsed JSON | **CONTRADICTED** (`derived`) | in desert biome those two stamp calls are no-ops; add explicit family aliases or special-case `home()` |
| 11 | "all converted terrain assets are under `app/assets/terrain/<subdir>/`" | 20 legacy PNG at terrain root, tracked, unreferenced by `.gd` | `Get-ChildItem` root + grep | **CONTRADICTED** | document them as legacy; optionally archive (compliance/coordinator decision) |
| 12 | "each block family has consistent resolution" | 110/112 blocks are 1024²; `sand1.png`, `sand2.png` are 256²; water 0/1 are 256² vs 2..7 512²; decals_png has 8× 128² and 24× 512² among 430× 1024² | Pillow size histogram over every PNG | **CONTRADICTED** (resolutions consistent *per family*, not across families) | no code fix required; note in asset tickets that loaders resize via `_mirror_tileable` |

**UNVERIFIED (do not promote):** whether the 39 missing face/alpha block PNGs
would visually improve shores without donor-side reference; whether each of the
20 unwired pattern families produces a visually distinct prop in `world.gd`
(prop art is procedural — `app/CREDITS.md:71-73`); whether `.dds.uid` files
indicate a past Godot import attempt (no `.import` exists — cause unknown);
whether the raw DDS files are intentional rebuild sources or accidental copies
(`ASSET_AUDIT.md:109-114` — compliance decision).

---

## 5. Recommendations

Each ticket is scoped to **one file or one family** (`SWARM_OPS.md` §3.2).
No ticket here authorises touching the donor install or redistributing assets.

### 5a. Asset tickets (convert / import / author)

| ID | Ticket | Target path | Acceptance criteria |
|---|---|---|---|
| A1 | Author a winter tile-preset table mapping the 27 `winter0..26` PNGs onto the 124 summer preset slots (or a standalone winter pool), **without editing `presets_summer.json`** | `app/assets/terrain/structs/presets_winter.json` (new; pattern: `presets_summer.json`) | Valid JSON array; 27 entries exactly matching `winter0..26.png` stems; every entry resolves to an existing PNG+`.import`; no summer file modified |
| A2 | Import-verify all 691 terrain PNGs (they already have `.import`); record a manifest/hash snapshot so beauty-wave additions can be diffed | audit doc / tooling only — **no asset edit** | Re-run of the §1 Pillow walk reports 0 PNG without `.import`; count matches 691 before any new conversion |
| A3 | Convert the 39 donor face/alpha plates (`sand1f..9s`, `rock1vf..9vs`, `alpha0a/b/c`) using the existing private-use conversion tool, to complete shore/cliff transitions | `app/assets/terrain/blocks/<name>.png` + `.import` (39 pairs) | 39 new PNG+`.import` pairs; every `presets_summer.json` name resolves to a PNG; no donor binary committed; `app/CREDITS.md` updated with the new list |
| A4 | Add the donor `christmas new_year6-10` footprint family (currently absent) from the existing pattern-export tool | `app/assets/terrain/patterns/donor_patterns.json` (one family entry) | `families` gains a `christmas` key; parsed pattern count rises from 266; each named pattern resolves to a cell list; no other family changed |
| A5 | Convert/import winter building plates if the port wants them addressable by `world.gd:537` — they **already exist** as 226 `dw.png` files; this ticket is verification only | `app/assets/terrain/decals_png/` (no new files expected) | All 226 `dw` PNGs have `.import`; report the 10 helper/size files as intentionally unwired |
| A6 | Compliance: decide retention of 468 raw `.dds` + 8 `.lib/.mat` under `decals*/`; private-use rule `app/CREDITS.md:1-5` and `SWARM_OPS.md` §3.5 applies | `app/assets/terrain/decals/` + `decals_dds/` | Written owner decision; nothing deleted or published by this lane |

### 5b. Code tickets (one file / one family each)

| ID | Ticket | Target file:line | Acceptance criteria |
|---|---|---|---|
| C1 | Wire `winter0..26` block pool: season-aware name selection into `_block_img`/`_build_chunk`; consume A1's preset table | `app/scripts/world.gd:695-717`, `:798-875` (one file) | With `season=winter` (menu → `main.gd:239` → `Data.BIOME`), at least one `winter*.png` is loaded (probed via `_res_exists`/cache instrumentation); summer path unchanged byte-for-byte for default seed; selftest 29/29 + uitest 17/17 |
| C2 | Wire all 8 water sheets into `_prep_variants()` instead of waves2 only | `app/scripts/world.gd:672-693` (one file) | All 8 `diffusewaves*.png` loaded; 256² sheets normalized; `variants[3]` has ≥4 frames from ≥2 distinct sheets; default-seed smoke shot unchanged in terrain layout |
| C3 | Winter building decal filename selection (`d` → `dw`) in `_bld_decal()` | `app/scripts/world.gd:533-542` (one file) | Winter season resolves a `dw.png` path for a known nation/sid; summer resolves the existing `d.png`; null fallback preserved |
| C4 | Ground-decal pass for `groundexp0..3` + `envfieldd/w` at existing farm/resource positions | `app/scripts/world.gd` (one new pass near `:1064`) | Explicit PNG paths load; winter picks `envfielddw`; no new dependency on the Python preview tool; gates green |
| C5 | Remove dead `terrain_masks` return and correct the dmask/red-channel comments | `app/scripts/world.gd:727-750` + comments `:647,668-669,690`; companion one-line change `app/scripts/main.gd:883` (two separate single-file tickets) | No draw code reads `terrain_masks`; comments match `blend_rect_mask` alpha semantics; visual output unchanged |
| C6 | Fix the `dcr1` no-op recipe and add explicit alias handling for the two missing desert forest families in `home()` | `app/scripts/pattern_gen.gd:125-128`, `:249-265` (one file) | No call asks `pick()` for a non-existent family; desert biome produces forest stamps again; stamp count for default seed documented |
| C7..C26 | One family per ticket: extend `recipes` with one of the 20 unwired families from §3 (e.g. `forests_leaf_small`, `forests_pine_big`, `decor_big`, `desert_mountains`) | `app/scripts/pattern_gen.gd:249-265` (one family per ticket) | Each ticket adds exactly one family; parsed family count reachable rises by 1; default-seed determinism preserved; screenshot shows the new clump or ticket marked UNVERIFIED with reason |
| C27 | Retire the `water.json` stub or document its intent | `app/assets/terrain/structs/water.json` (one file) | Either removed with no code breakage, or annotated; no runtime behaviour change |

**Explicitly not ticketed here:** any Godot run, donor-file copy, or edit to
`presets_summer.json` (winter must use a separate table — claim 8).

---

## 6. Open questions

1. **Winter mapping semantics.** `winter0..26` are numbered tiles, while the
   donor `tileblocks.json` uses names like `grass1_winter` (0 overlap). How do
   the 27 numbers map to the 124 summer slots? `UNVERIFIED` — needs a donor-side
   read of the winter palette (forbidden in this lane) or a documented mapping
   from the conversion tool that produced them.
2. **Desert season intent.** Should `desert1..12` replace summer blocks in
   `BIOME=desert`, or is the `TERRAIN_TINT` desert glaze (`data.gd:194`) the
   accepted port approximation? Deterministic answer needed before C1 is
   generalised to a third season.
3. **Pattern-family visuals.** `donor_patterns.json` stores footprints only;
   whether unwired families would render differently depends on procedural prop
   code in `world.gd` that this audit did not fully trace. `UNVERIFIED` —
   C7..C26 acceptance must include a screenshot or be left UNVERIFIED.
4. **Raw DDS retention.** Are the 468 donor DDS intentional rebuild sources?
   Compliance (Review desk) owns this (`ASSET_AUDIT.md:109-114`).
5. **Legacy root PNGs.** Keep or archive the 20 unreferenced root textures?
   They are tracked and harmless but duplicate `blocks/`.
6. **`.dds.uid` provenance.** 468 `.uid` files exist beside DDS with no
   `.import`; whether a previous Godot import attempt occurred is `UNVERIFIED`.
7. **Christmas placement.** The `christmastreed.png` asset exists but no
   `christmas` family exists in `donor_patterns.json` and no prop draw case
   exists in `world.gd`. A5/A4/C4 are three separate tickets; all three must
   land before the tree is visible.

---

## Files changed

- `docs/audit/TERRAIN_PORT_ASSETS.md` (new) — this report only. No code, asset,
  index, screenshot or status document was modified. Analysis scripts were
  written to `%LOCALAPPDATA%\Temp\opencode\` and are not part of the deliverable.
