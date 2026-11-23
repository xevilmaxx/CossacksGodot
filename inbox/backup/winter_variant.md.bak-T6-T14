---
title: Piece spec — winter_variant (ground piece, donor-truth recipe)
owner: T2-PIECE-WINTER
decision: D-22
updated: 2026-11-21
status: complete
scope: RESEARCH only. No code, no Godot run, no donor file copied into the repo.
---

# winter_variant — visual truth + recipe for a winter ground piece

**Files owned/changed by this agent:** `docs/audit/PIECES/winter_variant.md` only.
Analysis scripts and crop PNGs were written to `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\` (never into the repo).
All donor paths below were read in place at `C:\Games\Cossacks 3`; nothing was copied under `app/`.
Method tags: `observed` = measured/read directly; `derived` = computed from observed data; `inferred` = interpretation with a stated caveat; `UNVERIFIED` = not proven here.

---

## 0. Sources

| Side | Path | What was read |
|---|---|---|
| Donor | `data\terrain\tiles\terrain.presets` | Summer section (124 `TileBlock`) and Winter section (124 `TileBlock`, `WaterSet = Winter`, `DefaultIndex = 0`) |
| Donor | `data\terrain\tiles\tiles.mat` | 253 material→image pairs; 124 `*_winter` aliases (parsed programmatically) |
| Donor | `data\terrain\tiles\textures\winter0.dds … winter26.dds` | 27 files, all 1024×1024 RGBA; pixel histograms + 15-tile contact sheet |
| Donor | `data\scripts\common.inc\dogenerate.inc` | Winter tree deletion, winter tile-collapse block (commented out), colour table selection |
| Donor | `data\env\colors\colors.lib`, `0.palette` | 12 palette slots; `statictables[6] = winter` |
| Reference | `C:\Users\Maxym.Oboyshev\Downloads\c3\3173885360_preview_Turkish battle 19 Light Infantry rush.jpg` | 1920×1080 snowy-battle screenshot; 6 measured crops + 4 tree-zoom crops |
| Port | `app/assets/terrain/blocks/winter0.png … winter26.png` | 27 files, all 1024×1024 RGB; 10 samples compared to donor DDS |
| Port | `app/scripts/data.gd`, `world.gd`, `game.gd` | Season tint, block loader, preset loader — exact `file:line` cited in §2 |
| Prior | `docs/audit/TERRAIN_DONOR_ASSETS.md` §3.2, `TERRAIN_PORT_ASSETS.md`, `TERRAIN_REFERENCE_IMAGES.md:59-60` | Cross-check only; all numbers below were re-derived |

Pillow 12.1.1 / Python 3.14.3. Snow test used throughout: `R>=225 and G>=225 and B>=225 and B>=R` (`derived` threshold, chosen because both the donor tiles and the screenshot are cool-white biased).

---

## 1. Donor evidence

### 1.1 Winter preset structure (`observed`)

`terrain.presets` has exactly two sections of 124 `TileBlock` entries each. The Winter section is a 1:1 rename of the Summer section with `_winter` appended to every name **except** `alpha0a`, `alpha0b`, `alpha0c`, which are shared unchanged. Example: Summer `[*].TileBlock = grass1` → Winter `[*].TileBlock = grass1_winter`; Summer `desert1` → Winter `desert1_winter`.

`tiles.mat` resolves those 124 aliases to **35 unique textures**: 23 distinct `winter*.dds` plus all 12 `desert*.dds` reused unchanged (`observed`, programmatic parse). `desertN_winter → desertN.dds` — the desert aliases are *not* snow textures.

### 1.2 Alias → winter texture map (`observed`, complete)

Primary ground/rock/shore presets (the indices a winter piece will actually use):

| Winter preset alias | Texture | Snow area % (measured) | Visual read (from contact sheet) |
|---|---|---|---|
| `grass1_winter` | **winter10.dds** | **90.5** | near-white, fine grey speckle — clean snow field |
| `grass2_winter` | winter9.dds | 64.6 | white with brown earth patches |
| `grass3_winter` | winter2.dds | 86.2 | pale cool grey-white, fine grain |
| `grass4_winter` | winter3.dds | 53.3 | blue-grey soft snow |
| `grass5_winter` | winter4.dds | 61.1 | white with dark exposed earth |
| `grass6_winter` | winter16.dds | 24.3 | snow over dark rock striations |
| `grass7_winter` | winter1.dds | 85.8 | white + sparse green-grey flecks |
| `grass8_winter` | winter21.dds | 99.1 | almost pure white slab |
| `grass9_winter`, `grass10_winter` | winter0.dds | 90.1 | white with faint grey soil speckle |
| `ground1_winter` | winter11.dds | 1.3 | tan/beige gravel — **no snow** |
| `grass_sand1_winter` | winter21.dds | 99.1 | white |
| `grass_sand2_winter`, `sandrock1_winter`, `sandrock5_winter` | winter1.dds | 85.8 | white |
| `grass_rock1_winter` | winter9.dds | 64.6 | white/earth |
| `grass_ground1_winter`, `grass_ground3_winter` | winter5.dds | 66.6 | white with soil |
| `grass_ground2_winter` | winter4.dds | 61.1 | white/earth |
| `rock1_winter` (+`1vf`,`1vs`) | winter12.dds | 0.7 | grey-brown vertical striated rock face |
| `rock2_winter`, `rock3_winter` (+`vf`,`vs`) | winter13.dds | 0.7 | same rock family, grey |
| `rock4_winter` (+`vf`,`vs`) | winter17.dds | 0.0 | dark brown rock |
| `rock5_winter` (+`vf`,`vs`) | winter22.dds | 0.0 | dark grey-brown rock |
| `rock6_winter` (+`vf`,`vs`) | winter15.dds | 0.4 | grey rock |
| `rock7_winter` (+`vf`,`vs`) | winter14.dds | 0.4 | grey rock |
| `rock8_winter` (+`vf`,`vs`) | winter16.dds | 24.3 | snow over rock |
| `rock9_winter` (+`vf`,`vs`) | winter20.dds | 42.1 | mottled white + dark earth |
| `sand1_winter`, `sand2_winter`, `sand4_winter`…`sand9_winter` | winter10 / winter0 | 90.5 / 90.1 | white |
| `sand3_winter` | winter20.dds | 42.1 | white/dark mix |
| `sandrock2_winter` | winter10.dds | 90.5 | white |
| `sandrock3_winter`, `sandrock4_winter` | winter19.dds | 93.4 | pale blue-white cracked snow |
| `sandrock6_winter` | winter0.dds | 90.1 | white |
| `sandsea1_winter`, `4`, `5` | winter19.dds | 93.4 | pale blue-white |
| `sandsea2_winter`, `3` | winter2.dds | 86.2 | pale grey-white |
| `sandsea6_winter` | winter3.dds | 53.3 | blue-grey snow |
| `alpha0a_winter`, `alpha0b_winter`, `alpha0c_winter` | winter0 / winter1 / winter1 | 90.1 / 85.8 | white; mask carriers |

Remaining aliases (`observed`, grouped by target texture): `winter0` also serves `sand1f/sand2f/sand2s/sand3s/sand4s/sand5f/sand8f` and `test4/test10/test20`; `winter1` also serves `sand3f/sand5s/sand6f/sand6s/sand7f/sand7s/sand9f` and `test11/test22`; `winter2` also `sand8s/sand9s`; `winter4` also `test0/test6`; `winter5` also `test12/test13/test14`; `winter6` = `test1`; `winter7` = `test2/test18`; `winter8` = `test3/test19`; `winter10` also `sand4f`, `test5/test7/test9/test15/test16/test17/test24`; `winter21` also `test8`; `winter25` = `sand1s/test21/test23/test25`.

**Caveat (`observed`):** `winter25.dds` (and the unused siblings `winter23/24/26`) are **green grass textures** (mean ≈ `#3C471D`, 0% snow), not snow. They are reached only through `sand1s_winter` and three `test*_winter` aliases. A winter piece should not pick them for snow ground.

**Unused (`observed`, answers TDR-3 open question #4):** exactly **winter18, winter23, winter24, winter26** have no `tiles.mat` alias. 23 of the 27 are referenced.

### 1.3 Donor winter palette — measured, with premise corrected

The brief's `#F0F0FB` / `#B2AFB5` values come from `docs/audit/TERRAIN_REFERENCE_IMAGES.md:59-60`, where they are **box means of the reference screenshot**, not exact colours in the donor tiles (`observed`). Re-measurement:

| Role | Value | Source | Verdict |
|---|---|---|---|
| Snow (reference, open field) | crop `(120,520,420,700)` mean **(238.8,238.7,249.3) = `#EFEFF9`**, 92.6% snow pixels, **100% of snow pixels have B≥R** | this audit, Pillow | consistent with legacy `#F0F0FB` (240,240,251) within 1–2 levels |
| Rock+snow (reference, mixed) | crop `(700,430,960,620)` mean **(148.2,140.4,147.5) = `#948C93`** | this audit | darker than legacy `#B2AFB5` because the box includes shadowed rock and troops |
| Legacy rock mean reproduction | box `(90,330,330,400)` mean **(173,171,179) = `#ADABB3`** vs legacy `#B2AFB5` (178,175,181) | this audit | legacy value is a plausible box mean, not an exact pixel |
| Donor snow exacts | `#FFFFFF` (winter10 28.4%; winter0 57.4%; winter21 72.8%), recurring `#F7F7F7`, `#FCFCFC`, `#F9F9F9`, `#F7FBFF`, `#EFEFEF`, `#F4F4F4`, `#EFF3F7` | histogram over all 27 DDS | **no tile contains an exact `#F0F0FB` pixel (0 occurrences in all 27)** |
| Donor rock greys | `#BDBEBD`, `#B5B6B5`, `#ADAEAD`, `#A5A6A5` (winter12–15); dark stone `#423C31`, `#4A4139` (winter17/22) | histogram | `#B2AFB5` occurs 0 times (`winter4`: 1 accidental pixel) |
| Donor "rock+snow near B2AFB5" | winter12 has **7.3%** of pixels within ±12 of (178,175,181) | this audit | the legacy grey is a *mix approximation*, present only as a spread |
| Lighting palette | `colors.lib` `statictables[6] Name=winter {refkey=.statictables[0]}`, override `ShadowBlendingDiffuse = 180,180,200,128` = `#B4B4C8` | donor read | donor "winter palette" is a **lighting/shadow table**, not ground albedo |

**Key distinction (`derived`):** the cool blue cast of the screenshot is produced by the *winter lighting table* + the blue-biased snow pixels, **not** by a literal `#F0F0FB` tile fill. `winter10` snow is mostly neutral: only **15.8%** of its snow pixels have B>R, versus **100%** in the reference open-snow crop. A faithful piece therefore needs a mild cool glaze on top of the donor tile, not a flat blue slab.

### 1.4 Reference crop boxes and hex (`observed`)

Reference file: `3173885360_preview_Turkish battle 19 Light Infantry rush.jpg`, 1920×1080. Boxes are source-image pixels. Crops written to temp only.

| Crop name | Box (x0,y0,x1,y1) | Mean RGB | Mean hex | Snow % | Content |
|---|---|---|---|---|---|
| `snow_open` | (120,520,420,700) | (238.8,238.7,249.3) | `#EFEFF9` | 92.6 | clean open snow, fine grey flecks |
| `snow_field_lower` | (560,780,920,1020) | (188.1,181.1,192.1) | `#BCB5C0` | 37.0 | snow + troop shadows/soil speckle |
| `rocks_snow` | (700,430,960,620) | (148.2,140.4,147.5) | `#948C93` | — | grey snow-capped boulders + red unit |
| `trees_conifer` | (1360,600,1700,830) | (170.5,168.3,173.7) | `#ABA9AE` | — | snow-laden spruce/pine + dark green spruce |
| `bare_tree_left` | (90,330,230,480) | (180.9,179.6,188.2) | `#B5B4BC` | — | leafless dark-branched broadleaf |
| `bare_among_spruce` | (1010,640,1120,790) | — | — | — | snow-on-bare-branches broadleaf in conifer grove |
| `farm_field` | (860,230,1400,430) | (162.6,154.0,151.9) | `#A29A98` | — | golden stubble field — NOT snow, do not sample for snow palette |

Full-image snow fraction is 35.5% (`derived`); the snow-only regions are 92.6%. The prior doc's "70–80% of #1" is a visual whole-frame estimate (`TERRAIN_REFERENCE_IMAGES.md:59`), consistent with these numbers.

### 1.5 Tree behaviour (`observed`, donor script)

`C:\Games\Cossacks 3\data\scripts\common.inc\dogenerate.inc`:

| Line(s) | Code (abridged) | Meaning |
|---|---|---|
| 1975–1982 | `if (GetSeasonType=2) then // winter` … `if StrExists(basename,'leaftree') then GameObjectRequestToDestroyByHandle(goHnd); continue;` | **In winter, every generated env object whose base name contains `leaftree` is destroyed.** Conifers (`forests_spruce_*`, `forests_pine_*`, `forests_pinefir_*`) are untouched and remain. |
| 1836–1896 | `case foreststype of` … `forests_spruce_* / pine_* / pinefir_*` vs `forests_leaf_*`, `forests_mixed_*` | Forest family choice; conifer families are the survivors in winter (`derived` from the deletion rule). |
| 1848 | `if (gc_halloween>0) and (GetSeasonType<>2) then // not winter` | Halloween tree treatment is explicitly disabled in winter. |
| 1951–1968 | `{if (GetSeasonType=2) then … MapGetTileIndexByTileBlock('grass1_winter') … if (StrPos('_winter',name)=0) …}` — **entire block wrapped in `{ }`** | A disabled prototype that would have collapsed all `_winter` tiles to `grass1_winter`/`alpha0b`. It is **commented out**: shipping winter maps select tiles per preset, not one flat tile. |
| 2075–2084 | `if GetSeasonType=2 then begin SetCurrentColorTableIndex(6); SetCurrentPHDRIndex(1);` else desert=7 / default=0 | Winter selects colour table **6** (`winter`), PHDR 1. |

**Reference tension (`inferred`):** the reference screenshot is a named battle scenario ("Turkish battle 19…"), and its crops show **≥1 bare/leafless broadleaf tree per view** (crop `bare_tree_left`, `bare_among_spruce`) alongside snow-laden conifers. The generated-map rule deletes `leaftree` objects, so a *randomly generated* winter map legitimately has zero bare trees, while an authored/scenario map can retain them. The recipe must state which mode it emulates; the JSON spec in §3 uses only a spruce sprite and therefore matches **generated-map mode**, which is a documented variance from the screenshot (V1 in §4).

### 1.6 Donor ↔ port pixel identity (`observed`)

Ten sampled `winter{0,2,10,11,12,16,19,21,23,25}.png` are **pixel-identical** to their donor `.dds` after RGB conversion (`ImageChops.difference().getbbox() is None` for all ten). All 27 port PNGs are 1024×1024 RGB (donor DDS are RGBA — alpha dropped, consistent with TDR-3 claim C8). The pixels are already in the repo; only the wiring is missing.

---

## 2. Port gap (`observed`, exact `file:line`)

| # | Gap | Evidence | Consequence |
|---|---|---|---|
| G1 | Winter is a **flat multiplicative tint**, not a tile family | `app/scripts/data.gd:191-197` — `TERRAIN_TINT = { "summer": Color(1,1,1,1), "winter": Color(0.86,0.91,1.0,1.0), "desert": … }` → winter = `#DBE8FF`. `world.gd:939-951` `_season_tint()` sets alpha strength `0.34` for any non-white tint; `world.gd:1141-1151` composites that 2×2 colour over the entire chunk. | A snow scene is green grass under a blue glaze: no `#FFFFFF` highlights, no grain, no rock/snow tiles. |
| G2 | The 27 real blocks are unwired | `blocks/winter0..26.png` exist (1024² RGB) but `app/scripts/world.gd:857` loads `res://assets/terrain/blocks/%s.png` only for names supplied by the preset arrays; no `.gd` contains a `winter` literal (`observed` repo-wide grep; only comments at `world.gd:919-922` mention the donor colour table). | Donor snow art is unreachable. |
| G3 | Only summer presets are loaded | `app/scripts/game.gd:988-998` `_load_terrain_structs()` parses **only** `structs/presets_summer.json` (`:991`) and `structs/smooth_summer.json` (`:996`). No `presets_winter.json`/`smooth_winter.json` exists. | No alias→`winterN` mapping is available at runtime. |
| G4 | `tileblocks.json` is not the winter mapping | `app/assets/terrain/structs/tileblocks.json` is 245 entries with 121 `*_winter` names and **zero** `winter0..26` tokens (`observed`); no `.gd` load site (prior `TERRAIN_PORT_ASSETS.md:93,140`). | Using it as a preset table would produce 0 matches. |
| G5 | No season-dependent tree logic | Repo-wide grep of `app/scripts/*.gd` for `leaftree`, `GetSeasonType`, tree destruction: **0 hits**. Only `data.gd:179` / `menu.gd:36` declare `BIOME`. | The donor's winter leaf-tree deletion is not represented; conifer-only winter placement is not enforced. |
| G6 | No donor winter lighting palette | `env\colors\0..11.palette` / `colors.lib` are absent from the port (`TERRAIN_DONOR_ASSETS.md:152`); only the three hardcoded tints at `data.gd:191-195`. | The cool-bias glaze is a constant, not the donor `#B4B4C8` shadow table; screenshot B≥R = 100% is not reproduced by a fixed 0.34 alpha. |
| G7 | Winter building plates unwired (adjacent gap) | 226 `dw.png` plates exist but `world.gd` requests only `%s%sd.png` (prior `TERRAIN_PORT_ASSETS.md:86,117`). | Not part of the ground piece, but relevant if the piece is extended to a full winter scene. |

---

## 3. JSON spec (deliverable shape, ready for a generator)

The following is the exact requested spec shape with the `reference` object populated from §1.3–1.5. It is a **specification**, not generated code and not a Godot resource.

```json
{
  "name": "winter_variant",
  "size_px": [512, 512],
  "seed": 7,
  "layers": [
    {"type": "block", "name": "winter10", "tile": true},
    {"type": "sprite", "name": "tree_spruce1", "pos": [0.4, 0.5], "scale": 1.0}
  ],
  "reference": {
    "image": "3173885360_preview_Turkish battle 19 Light Infantry rush.jpg",
    "image_size_px": [1920, 1080],
    "crop_boxes_px": {
      "snow_open": [120, 520, 420, 700],
      "rocks_snow": [700, 430, 960, 620],
      "conifers": [1360, 600, 1700, 830],
      "bare_tree": [90, 330, 230, 480]
    },
    "measured": {
      "snow_mean_hex": "#EFEFF9",
      "snow_mean_rgb": [239, 239, 249],
      "snow_area_pct": 92.6,
      "snow_cool_bias_pct": 100.0,
      "rock_snow_mean_hex": "#948C93",
      "legacy_hex_prior_doc": {"snow": "#F0F0FB", "rock_snow": "#B2AFB5", "source": "docs/audit/TERRAIN_REFERENCE_IMAGES.md:59-60"}
    },
    "donor": {
      "preset": "grass1_winter",
      "texture": "winter10.dds",
      "texture_size_px": [1024, 1024],
      "snow_area_pct": 90.5,
      "dominant_snow_hex": "#FFFFFF",
      "snow_cool_bias_pct": 15.8,
      "rock_accent_textures": ["winter12.dds", "winter13.dds", "winter16.dds", "winter20.dds"],
      "rock_grey_hex": "#BDBEBD",
      "dark_stone_hex": "#423C31",
      "lighting_palette": "env/colors/statictables[6] winter, ShadowBlendingDiffuse #B4B4C8",
      "tree_rule": "dogenerate.inc:1975-1982 deletes objects whose basename contains 'leaftree' in winter; conifers survive"
    },
    "variance": "V1: spec uses a single spruce sprite (generated-map mode); screenshot shows >=1 bare broadleaf per view (scenario mode)"
  }
}
```

**Recipe in words (`derived`):** take `blocks/winter10.png` as the tileable ground layer (90.5% snow, matches the reference 92.6% open-snow coverage), apply a mild cool glaze whose snow pixels satisfy B≥R on ≥80% of the bright area (donor tile alone gives 15.8%; the reference gives 100%), optionally stamp a rock accent from `winter12/13/16/20` for the `#948C93` grey-brown mass, and place the `tree_spruce1` sprite at normalised (0.4, 0.5) scale 1.0. Do **not** use `winter11` (gravel, 1.3% snow) or `winter23–26` (green grass) as the snow base. Seed 7 fixes the speckle/rock placement deterministically.

---

## 4. Measurable acceptance criteria

All thresholds are `derived` from §1.3–1.4 measurements; state the mode (generated / scenario) before applying C3.

| ID | Criterion | Measurement method | Pass threshold | Current port state |
|---|---|---|---|---|
| C1 | **Snow area %** of the ground layer | Count pixels with `R,G,B≥225 and B≥R` ÷ total pixels (Pillow, same definition as §0) | `winter10`-based piece: **85–95%** (measured 90.5%). Reference open-snow crop: 92.6%. A rock-heavy variant using winter16 must declare 20–35% instead. | FAIL — no block rendered; flat tint over grass has ~0% snow pixels |
| C2 | **Palette fidelity** | Top-5 exact colours of the ground layer; cool-bias fraction of snow pixels | Top-5 must include `#FFFFFF` at ≥25% **and** ≥3 of {`#F7F7F7`,`#FCFCFC`,`#F9F9F9`,`#F7FBFF`,`#EFEFEF`,`#F4F4F4`}. Cool bias (B>R among snow pixels) **≥80%** to match the screenshot's 100%; donor tile alone is 15.8%. Rock accents, if present, must fall within ±12 of `#BDBEBD` (grey) or `#423C31` (dark stone). A single flat colour (`#DBE8FF`) is an automatic FAIL. | FAIL — `data.gd:193` is one colour, composited at 0.34 alpha (`world.gd:946`) |
| C3 | **Bare-tree presence** | Count leafless broadleaf trees in a 512² piece render / equivalent reference view; compare with the generator rule | Reference: **≥1** bare tree per 1920×1080 view (observed in 2 crops). Generated-map mode: **0** is correct (donor deletes `leaftree`), must be labelled. Scenario/reference mode: **≥1** required. The provided JSON spec (spruce only) passes only generated-map mode and must carry variance V1. | FAIL for scenario mode — no tree logic at all (`app/scripts/*.gd` grep 0 hits) |
| C4 | **Wiring (non-visual gate)** | Grep + load probe | At least one `winter*.png` loaded via `world.gd:857` when `_season_key() == "winter"`; a `presets_winter.json` with ≥23 distinct `winterN` names exists; summer default-seed output unchanged | FAIL — only summer presets loaded (`game.gd:991,996`) |
| C5 | **Alpha/exactness** | Pillow histogram vs donor | Ground PNG 1024² RGB, pixel-identical to `winter10.dds` on RGB (already true, §1.6) | PASS on-disk; not drawn |

---

## 5. Claim table

| # | Claim | Evidence | Method | Verdict | Correction |
|---|---|---|---|---|---|
| C1 | "The port has no winter terrain art." | 27 `blocks/winterN.png`, all 1024² RGB; 10 sampled files pixel-identical to donor DDS | Pillow count + `ImageChops.difference` | **CORRECTED** | Art present and exact; gap is wiring only (G1–G4) |
| C2 | "Donor winter palette is exactly `#F0F0FB` snow / `#B2AFB5` rock+snow." | All 27 DDS: 0 exact `#F0F0FB`, 0–1 exact `#B2AFB5`; those hexes are reference box means from `TERRAIN_REFERENCE_IMAGES.md:59-60` | Full histogram over 27×1,048,576 px | **CORRECTED** | Donor exacts are `#FFFFFF`/`#F7F7F7`/`#F7FBFF` etc.; rock greys `#BDBEBD`/`#B5B6B5`/`#ADAEAD`; the legacy hexes are reference-photo means |
| C3 | "`grass1_winter` maps to `winter1.dds`." | `tiles.mat`: `grass1_winter → winter10.dds`; `grass2 → winter9`, `grass3 → winter2` | Programmatic pair parse | **CORRECTED** | Full 124-alias map in §1.2; `winter18/23/24/26` unused |
| C4 | "The port already swaps winter tiles." | `data.gd:193` flat `Color(0.86,0.91,1.0)`; `world.gd:939-951,1141-1151` 0.34-alpha glaze; no `winter` literal in `.gd` | Source read + grep | **REFUTED** | Tint-only; implement pool selection before claiming a swap |
| C5 | "`tileblocks.json` supplies the winter tile set." | 245 entries, 121 `*_winter` names, **0** `winter0..26` tokens, no `.gd` load site | JSON parse + grep | **REFUTED** | Author a new preset table; do not use `tileblocks.json` |
| C6 | "Donor removes all trees in winter." | `dogenerate.inc:1975-1982` destroys only basenames containing `leaftree`; conifer families remain | Source read | **CORRECTED** | Leaf trees removed; snow-laden conifers survive |
| C7 | "A commented donor block forces every winter tile to `grass1_winter`." | `dogenerate.inc:1951-1968` is wholly inside `{ }` | Source read | **REFUTED** | Disabled prototype; shipping tiles are per-preset |
| C8 | "Reference snow is neutral white." | Reference open-snow crop: 100% of snow pixels B≥R, mean `#EFEFF9` | Pillow | **REFUTED** | Cool bias is intrinsic; a neutral tile needs a glaze to match |
| C9 | "Exactly 4 winter DDS are unused." | `winter18,23,24,26` have no `tiles.mat` alias; 23 of 27 used | Pair parse | **CONFIRMED** | Answers TDR-3 open question #4 |
| C10 | "Donor winter 'palette' is a set of ground colours." | `colors.lib[6] winter` only overrides `ShadowBlendingDiffuse = 180,180,200,128`; `dogenerate.inc:2075-2077` sets colour table 6 | Donor read | **CORRECTED** | It is a lighting/shadow table; ground albedo lives in the DDS tiles |
| C11 | "The reference screenshot proves generated winter maps keep bare trees." | Screenshot is a named scenario with ≥1 bare broadleaf per view; generator deletes `leaftree` | Crop + script read | **UNVERIFIED (inferred)** | Scenario vs generated-mode distinction; recipe must label mode (V1) |

**Open / not claimed:** exact snow-area % of the *rendered future piece* (no Godot run); whether `snow1..4` particle BMPs are present in the screenshot's snowfall (`env\pfx\textures\` is missing from port — separate ENV lane); whether the 226 `dw.png` winter building plates are in scope for this ground piece.

---

*End of T2-PIECE-WINTER winter_variant spec. Read-only research; exactly one document written; no donor binary, code, or Godot artefact added to the repository.*
