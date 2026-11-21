# T2-PIECE-DESERT — `desert_variant` sandy/dune ground piece

RESEARCH only. One output file. No code, no Godot edits, no donor copies into the repo.
All pixel work used Pillow 12.1.1 on the original donor `.dds`, the port `.png`, and the single reference
JPEG; probe scripts and a viewing montage lived **only** in
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\`. Tags: `observed` (read in source / seen in image),
`derived` (computed from pixels), `inferred` (interpretation), `UNVERIFIED` (no confirming evidence in
this lane). Priors: `docs/audit/TERRAIN_DONOR_ASSETS.md` §3.2, `docs/audit/TERRAIN_PORT_ASSETS.md` §2/§3,
`docs/audit/TERRAIN_DONOR_PATTERNS.md` §3/§5.

**Purpose:** define a 512×512 *desert ground* piece whose visual truth is (a) muted ochre/olive sand grain,
(b) darker cracked-earth / plateau patches for dune-and-plateau relief, and (c) only sparse dry scatter.
The port currently renders desert as a **flat warm tint** over unchanged grass/rock blocks, while the 12
correct donor desert blocks sit unwired. This doc supplies the palette, the wiring gap, the JSON spec and
the measurable gates — and is explicit that the sole reference image is **weak**: it shows sandy ground in
a European-town mission shot, not a desert biome.

---

## 1. Donor evidence

### 1.1 The 12 desert tile blocks — palette and variety (`observed` + `derived`)

Donor files: `C:\Games\Cossacks 3\data\terrain\tiles\textures\desert1.dds` … `desert12.dds`, all
1024×1024 RGBA, alpha extrema `(255,255)` (`derived`: alpha is opaque, so dropping it in conversion lost
no visible data). Pillow stats below are on a 200×200 downsample, matching the companion piece-doc
convention; `bins≥3%` counts 8×32 luminance bins holding ≥3% of pixels.

| Block | Median RGB | Mean hex | L mean | L std | hi-freq | bins≥3% | Visual role (`observed` in montage) |
|---|---|---|---:|---:|---:|---:|---|
| `desert1` | (124,115,85) | `#7C7355` | 114.3 | 5.20 | 3.37 | 1 | fine mottled light sand, tiny pebbles |
| `desert6` | (123,114,83) | `#7B7253` | 112.9 | 4.37 | 2.58 | 1 | light sand, faint hairline cracks |
| `desert7` | (122,113,83) | `#7A7153` | 112.3 | 4.50 | 2.69 | 1 | light sand, faint cracks |
| `desert8` | (121,111,80) | `#797050` | 110.8 | 7.63 | 5.49 | 1 | light sand, coarser grain |
| `desert11` | (123,114,82) | `#7B7252` | 113.1 | 3.43 | 1.97 | 1 | smoothest light sand |
| `desert12` | (123,114,82) | `#7B7252` | 113.1 | 3.43 | 1.97 | 1 | smoothest light sand |
| `desert9` | (110,100,70) | `#6E6546` | 100.1 | 6.47 | 4.65 | 2 | mid olive-tan, dense speckle |
| `desert10` | (111,102,71) | `#6F6647` | 101.1 | 5.12 | 2.78 | 2 | mid olive-tan |
| `desert2` | (90,79,49) | `#5B5031` | 79.4 | 14.21 | 9.09 | 3 | **cracked dry earth**, strong polygonal facets |
| `desert3` | (90,79,49) | `#5B5031` | 79.4 | 14.21 | 9.09 | 3 | **cracked dry earth** (second plate) |
| `desert4` | (93,82,51) | `#5D5234` | 81.8 | 11.79 | 8.04 | 3 | dark coarse grain / scree |
| `desert5` | (93,82,51) | `#5D5234` | 81.8 | 11.79 | 8.04 | 3 | dark coarse grain / scree |

Tile-variety facts (`derived`): **12/12 pixel-unique** RGB MD5 hashes (no literal duplicate files), but only
**4 tonal families** — light sand `{1,6,7,8,11,12}` (6 tiles, L 110.8–114.3, std 2–8), mid `{9,10}` (2,
L 100–101), dark cracked `{2,3}` (2, L 79.4, hi-freq 9.09), dark scree `{4,5}` (2, L 81.8, hi-freq
8.04). Light tiles are flat (1 bin ≥3%); only the dark family carries real contrast (3 bins, std 12–14).
This is why the recipe uses `desert6` as the **tileable base** and must bring its own low-frequency relief:
the base art alone cannot produce plateau/dune shading.

Donor weighting (`observed`, `generator.cfg:1629-1655` `desert_tiles`): `d_tls_1` Freq 1000 (×2 entries),
`d_tls_2` Freq **0** (disabled), `d_tls_3` Freq 1000 (×2), `d_tls_4` Freq 100 — i.e. two dominant tile
variants, one absent, one rare. The 12 DDS are the tile *art* pool; their per-cell pick weights live in the
generator, not in the texture names.

`tiles.mat` cross-check (`observed`, prior §3.2): all 12 `desert*.dds` are also reused as the 12
`desertN_winter` materials in the Winter preset (`terrain.presets:249-260`), and the Summer preset lists
`desert1..12` at `terrain.presets:117-128`. So these are legitimate ground blocks in BOTH seasons, not a
special-effect sheet.

### 1.2 Dune / plateau art — relief stamps, not tile pixels

The dunes and plateaus are stamped object patterns, absent from the tile textures (`observed`):

| Donor family | `generator.cfg` lines | Count | Referenced assets | Prior port status |
|---|---|---:|---|---|
| `desert_mountains` | `:1867-1926` (`desert_mnt_1..15`) | 15 | `terrainmesh`, `desertstump` | `donor_patterns.json` family `desert_mountains`; **13/15 resolve**, `mnt_14/15` missing (prior §5 C4) |
| `desert_plateau`, `_small`, `_big` | `:1808-1865` (`desert_plt1..11`) | 11 | `terrainplateau`, `desert1..5` | `desert_plateau` family **BROKEN**: 4/4 names missing (`desert_plt2` vs file `desert_plt_2`) |
| `desert_plain_small/big` + `plain_medium` | `:1733-1805` (`desert_plain_1..15`) | 15 | `desert1..5`, `smallstonesdesert` | **MISSING** from recipes (prior §3) |
| `desert_stones` / `desert_stoneforests` | `:1932-2000` (`desert_stn_1..12`) | 12 | `stonesdesert`, `smallstonesdesert` | `desert_stones` ENCODED (prior §3) |

Files confirmed on disk: `C:\Games\Cossacks 3\data\pattern\desert_mnt_1.pattern` … `desert_mnt_13.pattern`,
`desert_plt_1.pattern`, `desert_plt_10.pattern`, `desert_plt_11.pattern` (`observed`). Visual classification
of a `.pattern` blob as a dune versus a rock outcrop is **UNVERIFIED** in this lane (binary file; prior doc
infers role from referenced `terrainmesh`/`terrainplateau` assets).

### 1.3 Sparse dry vegetation

Donor dry flora comes from pattern props, not the ground texture (`observed` in prior §3 table):
`desert_frt_*` (72 patterns) → `palm`, `palmsmall`, `desertstump`, `drytree`, `burch`;
`n_desert_frt_*` (60) → `palm`, `desert1..5`, `desertstump`; `desert_plain_*` (15) → `desert1..5`,
`smallstonesdesert`. The port has **no** desert-specific vegetation sprite: `app/assets/models/sprites_hi/`
holds 180 files but no `palm*`, `drytree*`, `desertstump*`, or `desert1..5` (`observed`); the only usable
scatter props are `bush1..4`, `rock_smallstones*`, `rock_stones*`, `rock_landstone1..4` (`observed`).

### 1.4 Reference image — LOW CONFIDENCE, do not let it override the donor palette

`C:\Users\Maxym.Oboyshev\Downloads\c3\MADVBuilding1.JPG` (485×486). Content (`observed` in image): a large
stone/tiled **European town hall** on a cobbled apron, surrounded by tan ground; a small green tuft at the
bottom-right and a palm icon inside the UI panel. It is a mission/UI screenshot whose *ground only* is
usable. No dune, plateau, or desert biome is actually shown.

Pillow measurements on ground-only crops (200×200-equivalent stats on the crop):

| Crop (source px) | Mean hex | L mean | L std | hi-freq | 8-bin histogram % |
|---|---|---:|---:|---:|---|
| `(5,5,470,38)` top strip | `#C0976A` | 158.1 | 13.91 | 7.16 | `[0,0.3,0.3,1.1,44.4,53.7,0.1,0.1]` |
| `(2,120,90,335)` left margin | `#9A7858` | 126.5 | 36.03 | 10.57 | `[0.4,8.4,12.9,15.5,47.1,15.7,0,0]` |
| `(5,300,470,345)` bottom band | `#BB9166` | 152.6 | 17.38 | 8.13 | `[0,0.2,1.7,4.4,54.2,39.4,0,0]` |

Mismatch (`derived`, material): reference ground is **L 126–158 / orange-tan `#C0976A`**, while the donor
desert pool is **L 79–114 / olive-khaki `#5B5031`–`#7C7355`** — a gap of ~40–70 L and a hue shift from
ochre/orange to olive. The reference also sits almost entirely in bins 4–5 (L 128–191), which **no donor
desert tile populates at all**. Causes are plausible (screen-shot gamma/dither, bright daylight, JPEG
resampling, different map/season) but **UNVERIFIED**. Decision: the donor tiles are authoritative for
palette; the reference is used only as weak support for "sandy, mottled, sparse" and for the *direction*
warm light sand over darker cracked patches. Any claim that the reference proves the port's exact desert
look is labelled UNVERIFIED in §5.

---

## 2. Port gap — current `file:line`

The prior audits' `world.gd:806/815-816/831/835-837/841/880-890` offsets are **stale** (in today's file they
are water/wave code). Current state:

| Concern | Current location | Behaviour |
|---|---|---|
| Flat desert tint | `app/scripts/data.gd:191-195` | `TERRAIN_TINT.desert = Color(1.0, 0.90, 0.70, 1.0)` (warm multiplier); `:196-197` `terrain_tint()` returns it |
| Tint selection | `app/scripts/world.gd:927-931`, `:939-951` | `_season_key()` falls back to `Data.BIOME`; `_season_tint()` converts distance-from-white into a **0.34-alpha glaze** |
| Tint application | `app/scripts/world.gd:1141-1151` | one flat 2×2 colour image resized to the chunk and `blend_rect`-ed — uniform, no desert texture swap |
| Block name source | `app/scripts/game.gd:989-995` | loads `res://assets/terrain/structs/presets_summer.json` → `tbl_names` (desert1..12 at `:113-124`) |
| Tile assignment | `app/scripts/game.gd:1124-1183` | `_assign_tileblocks()`: every land cell **starts `grass1`** (`:1141`); roles pick ground/grass_ground (`:1155-1161`), sand (`:1164-1165`), rock (`:1166-1178`); shore pass `:1181`, 3-pass smooth `:1183`. **No `BIOME`/`desert` branch anywhere.** |
| Block loader | `app/scripts/world.gd:850-872` | `_block_img()` loads `res://assets/terrain/blocks/<name>.png` (`:857`), mirror-tiles (`:863`), lifts grain `adjust_bcs(1.0,1.12,1.0)` (`:866`) — desert PNGs are mechanically loadable |
| Named-block compositor | `app/scripts/world.gd:998-1046`, `:1068-1088` | `_composite_blocks()` blends named blocks through smooth per-cell coverage masks (`:1004-1046`); `_build_chunk` ranks the top **3** distinct names (`:1080`) and starts from a single `grass1` crop (`:1064`). This is the hook the piece needs — no new engine path required. |
| Sprite path | `app/assets/models/sprites_hi/rock_landstone1.png` | 512×512 RGBA (`observed`); 160×160 twin in `sprites/` |

**Gap in one sentence:** the renderer can composite any named block, but `_assign_tileblocks()` never emits a
`desertN` name, so a `BIOME = desert` map draws grass/rock art under a 0.34-alpha `Color(1.0,0.90,0.70)`
glaze; `desert1..12.png` are addressable but unwired (`observed` + `derived`). Prior acceptance
`TERRAIN_DONOR_ASSETS.md:223-224` ("12/12 referenced by name") is **not met**. Note also `rock_landstone1`
is a **green mossy boulder cluster** (`observed` in montage), so the spec's sprite reads as a shrub/rock
only after a dry-tone grade — flagged UNVERIFIED in §5.

---

## 3. JSON spec (required deliverable)

```json
{
  "name": "desert_variant",
  "size_px": [512, 512],
  "seed": 7,
  "layers": [
    {"type": "block", "name": "desert6", "tile": true},
    {"type": "sprite", "name": "rock_landstone1", "pos": [0.6, 0.5], "scale": 1.0}
  ],
  "reference": {
    "primary": {
      "image": "MADVBuilding1.JPG",
      "crop": [5, 5, 470, 38],
      "hex": "#C0976A",
      "confidence": "low",
      "reason": "sandy ground only; European-town mission shot, no desert biome shown"
    },
    "donor_palette": {
      "light_sand": "#7B7253",
      "mid_sand": "#6E6546",
      "dark_cracked_earth": "#5B5031",
      "source": "data/terrain/tiles/textures/desert1..12.dds"
    },
    "relief_sources": ["generator.cfg desert_mnt_* (15)", "generator.cfg desert_plt_* (11)"],
    "vegetation_sources": ["desert_frt_* (palm/drytree/desertstump)", "desert_plain_* (desert1..5)"],
    "prior_docs": [
      "docs/audit/TERRAIN_DONOR_ASSETS.md §3.2",
      "docs/audit/TERRAIN_PORT_ASSETS.md §2/§3"
    ]
  }
}
```

**Interpretation.** `desert6` is the seamless **base** (mirror-tiled, `tile:true`): median `(123,114,83)`,
the light-sand anchor with the least distracting grain. The spec deliberately names **one** block and
**one** sprite so it fits the QA-P1 cap (≤3 composites/chunk, `world.gd:58`). Relief and sparse scatter are
part of the *recipe* but are not extra `block` layers: dune/plateau shading is a low-frequency tonal mask
derived from the donor `desert_mnt_*` / `desert_plt_*` footprint data (or the installed `game.relief` key),
darkening toward `#5B5031`; the sprite supplies the single dry rock/shrub accent at `(0.6, 0.5)`. Adding a
second/third block such as `desert2` (cracked earth) or `desert9` (mid speckle) is the recommended
extended variant **only** if the per-chunk composite budget is raised, otherwise it displaces an existing
sand/rock composite.

---

## 4. Measurable acceptance criteria (render 512×512 → 200×200 for stats)

### 4.1 Palette anchors (`derived` from the 12 donor blocks)

| Role | Anchors | L range | Sat / hue direction | Gate |
|---|---|---|---|---|
| Light sand (base) | `#7B7253`, `#7C7355`, `#7A7153` | 110–115 | R>G>B; ochre-olive, HSV sat ≈0.20–0.33 | ≥60% of pixels |
| Mid sand | `#6E6546`, `#6F6647` | 100–101 | R>G>B; sat ≈0.30–0.38 | any amount as relief mid-tone |
| Dark cracked earth / scree | `#5B5031`, `#5D5234` | 79–82 | sat ≈0.40–0.47, hi-freq 8–9 | ≥5% and ≤25% of pixels (sparse patches) |
| **Forbidden** | `#C0976A`-bright orange / bins 4–5 dominant | L≥128 >10% | strong orange sat | **reject** — this is the weak-reference trap, not donor truth |

### 4.2 Criterion table

| # | Criterion | Target | Measurement | Failure signature |
|---|---|---|---|---|
| C1 | Base palette | mean RGB within ±8 of `(123,114,83)` before sprite/relief; final 200×200 mean colour inside the light/mid sand band (median RGB roughly R 105–128, G 96–118, B 68–90; L 100–118) | Pillow mean on base crop; final render mean | green grass cast (G≥R) or orange-tan drift (L>128) |
| C2 | Hue order | R>G>B for ≥95% of sampled pixels | per-pixel channel test | any B>G inversion (wrong glaze) |
| C3 | Tile variety count | **12 unique desert hashes**, **4 tonal families present** in the wired pool; the rendered piece uses ≥1 base family (`desert6`) and ≥1 dark family (`desert2..5`) | MD5 of `desert1..12` pixels + L-means grouping + named layers | all cells same hash, or dark family never appears |
| C4 | Relief tonal spread | ≤0.34-alpha dark mask only; patched L must stay ≥75 (dark anchor L 79.4) and ≤118 (light anchor L 114.3) | Pillow L stats on 40×40 sub-boxes | flat L std <5 (no relief) or black cracks L<60 |
| C5 | Grain / hi-freq | base hi-freq 2.0–5.5 (`desert6` 2.58); cracked patches 8–9 (`desert2` 9.09); final 3–9 | 5 px Gaussian blur difference | grain erased (hi-freq <2) or JPEG-noise >12 |
| C6 | Sparse scatter density | exactly **1** sprite accent at `(0.6,0.5)`, scale 1.0; ≤3% of 512² area; no second desert vegetation sprite exists in port | spec layer count + `sprites_hi/` inventory | green moss boulder read as desert rock (UNVERIFIED grade needed) |
| C7 | Source faithfulness | port `desertN.png` ≡ donor `desertN.dds` RGB for all 12 (12/12) | MD5 comparison | any mismatch = broken conversion |
| C8 | Budget | ≤3 block composites/chunk; ≤250 ms bake (QA-P1); no new `.gd` engine path | `world.gd:58,998-1046,1080` | >3 layers added |

**Contrast to current port:** a desert map today is `grass1` grain plus a uniform `Color(1,0.90,0.70,0.34)`
wash (`world.gd:1064,1141-1151`) — its histogram has 1–2 bins and green-dominant hue, so it fails C1/C2/C3/C4.
A passing render must show ochre-olive R>G>B, at least one dark cracked patch, and the single rock accent.

---

## 5. Claim table

| Claim | Evidence | Method | Verdict | Caveat / correction |
|---|---|---|---|---|
| 12 donor desert DDS exist, all 1024² RGBA, opaque alpha | `data/terrain/tiles/textures/desert1..12.dds` | file listing + Pillow | **observed** | alpha extrema (255,255) — lossless RGB conversion possible |
| Port `desert1..12.png` are pixel-identical to donor | MD5 of RGB bytes, 12/12 matches | Pillow hashes | **derived / confirmed** | conversion dropped only the opaque alpha channel |
| 12 unique hashes but only 4 tonal families | MD5 + L means/std grouping | Pillow | **derived** | `{2,3}` and `{4,5}` and `{11,12}` are tonal twins, not byte twins |
| Light sand anchor `#7B7253` / dark cracked `#5B5031` | 12-block Pillow medians/means | Pillow | **derived** | donor palette is authoritative for the piece |
| Cracked-earth facets are visible in `desert2/3/4/5` | temp montage, 200² crops | visual | **observed** | classifying them as *dunes* is **UNVERIFIED** — they read as dried mud/scree |
| Dunes/plateaus come from `desert_mnt_*` / `desert_plt_*` pattern stamps | `generator.cfg:1808-1926`; prior §3 | source read | **derived / inherited** | `.pattern` blobs are binary; actual silhouette **UNVERIFIED** |
| Dry vegetation = palm/drytree/desertstump/desert1..5 props | prior `TERRAIN_DONOR_PATTERNS.md` §3 | source read | **inherited / UNVERIFIED visually** | no port sprite for any of them; port has bush/rock only |
| `rock_landstone1` is a desert sandstone accent | `sprites_hi/rock_landstone1.png` montage | visual | **CONTRADICTED (visual)** | sprite is green/mossy; usable only with a dry-tone grade (UNVERIFIED grade quality) |
| `MADVBuilding1.JPG` depicts desert ground | image inspection | visual | **UNVERIFIED** | European town hall + cobbles; sandy surround only, no dune/biome |
| Reference ground `#C0976A` matches donor desert palette | ref crop L 126–158 vs donor L 79–114 | Pillow | **CONTRADICTED** | ~40–70 L and a hue shift; reference is LOW confidence, do not tune to it |
| Reference brightness gap is a gamma/JPEG artefact | measured mismatch only | inference | **UNVERIFIED** | no second screenshot of the same location/season to confirm |
| Port currently wires `desert1..12` by name | `presets_summer.json:113-124`; grep `.gd` | source read | **CONTRADICTED** | names exist in JSON only; no `.gd` literal or BIOME branch selects them |
| Desert season is a flat tint today | `data.gd:191-195`, `world.gd:927-951,1141-1151` | source read | **observed** | 0.34-alpha warm glaze over unchanged block art |
| Renderer can composite named desert blocks without new code | `world.gd:850-872,998-1046` | source read | **observed** | requires `_assign_tileblocks()` to emit `desertN` names (not done) |
| Prior audit line numbers for desert wiring are current | TERRAIN_PORT_ASSETS.md:77 etc. | current file read | **CORRECTION** | use `game.gd:1124-1183`, `world.gd:850-872,998-1046,1141-1151` instead |
| The spec render will pass C1–C8 | no render produced in this research lane | — | **UNVERIFIED — pending render** | Pillow stats are for donor/reference images, not for a composed 512² piece |

**Open questions.** (1) Should the weak reference be replaced with a genuine desert-biome screenshot before
any hue tuning? (2) Can the QA-P1 3-composite cap be raised for a single-piece bake so `desert2` cracked
earth can be a real second layer? (3) Which asset should supply dry vegetation once `palm`/`drytree` are
converted — or is a graded `rock_landstone1` acceptable as the only accent? (4) Are `desert_mnt_14/15`
and the 4 missing `desert_plt_*` names recoverable from another donor config before the relief recipe
is finalised?
