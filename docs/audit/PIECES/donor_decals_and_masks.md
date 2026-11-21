# T2-DECALS — donor decal / mask inventory and port-use assessment

RESEARCH only. Exactly one output file. No code edit, no Godot run, no donor binary copied into the repo.
All donor work was read-only on
`C:\Games\Cossacks 3\data\terrain\decals\` (and named sibling mask/alpha paths under `data\`).
Pixel work used Pillow 12.1.1 + NumPy; probe scripts and decoded viewing copies live **only** in
`C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\`
(`decals_inventory.py`, `decals_inventory2.py`, `decals_inventory3.py`, `decals_full*.json`).
Tags follow `docs/audit/README.md` rule 3: `observed` (counted / read / measured here),
`derived` (computed from observed data), `inferred` (plausible but unproven), `UNVERIFIED`.

Priors: `docs/audit/TERRAIN_PORT_ASSETS.md` (T2's port-side inventory — read in full),
`docs/audit/PIECES/field_crops.md` (§1 covers the two field decals),
`app/tools/copy_assets.py`, `app/tools/import_donor_masks.py`,
`app/assets/terrain/masks/manifest.json`, `app/CREDITS.md`.

**Owner question answered in one line:** the donor decals folder holds 469 DXT5 plates plus 11
text descriptors; the genuinely *mask-like* payload is the **alpha channel of those DXT5 plates**
(footprint/coverage) — it is a generic "transparency = where the decal shows" convention, **not** a
semantic data ramp, and only two of those masks survive conversion (flattened to RGB) in the port.
The separate map-gen mask families (land/islands/…/lakes/coastal/rivers) are a different asset class;
7 of them are already ported and wired, 3 high-value ones are missing.

---

## 1. Sources / method

**Inputs (all read-only):**

| Source | What was done |
|---|---|
| `data\terrain\decals\` (recursive) | `os.walk` file count by extension and by subfolder; every `.dds` opened with `Image.open` → size/mode/bands; 128-byte DDS header parsed (`FourCC`, `rgbbits`, mip count, caps) |
| `data\terrain\decals\*.lib`, `*.mat`, `*.presets` | ASCII read; the donor's CRLF `section.begin` / `struct.begin` template grammar parsed with a purpose-built Python scanner (nested `struct.end` handled); season names, width/height, texscale/epsilon, blending/culling/filter recorded |
| `data\terrain\decals\env\*`, `pfx\*`, sampled `buildings\*` | `numpy` channel stats (min/max/mean/std/unique/histogram, `corr(A,luma)`) on decoded RGBA |
| `data\gen\terrainmasks\`, `terrainmasks.src\`, `terrainmasks.dlc5\` | Family counts; 4 representative TGA opened with Pillow → dimensions, mode, per-channel range/unique |
| `data\terrain\tiles\textures\alpha*.bmp`, `data\materials\env\christmastree*a.dds`, `data\terrain\ref\reftilealpha.mat` | Opened / read to classify the "alpha*" and "mask*" names found repo-wide |
| Port `app\assets\terrain\**` | Pillow size/mode histogram over `decals_png`, `deco_png`, `dmask`; PNG IHDR color-type read on the three `deco_png` probes; `masks\manifest.json` parsed; converter sources read |

**Negative controls / hygiene:** 0 unreadable images — all 469 DDS decode cleanly (Pillow 12.1.1
supports DXT5; no missing mips, no partial files). No donor file was copied into the repo; no
`.dds`, `.lib`, `.mat` or TGA was written. No Godot process was started. No asset, script or
document other than this file was changed.

**Method note on the `.lib`/`.mat` grammar (`observed`):** each file has one `default : section.begin`
block that declares a *complete* template (in `decals.lib` that template is the `polartd` decal,
including the nested `position`/`texoffset`/`scalefactor`/`texscale` structs). All remaining blocks
are `section.begin {refkey=default}` overrides that set only a few keys (`name`,
`Decal.SummerLibMaterialName`, `Decal.WinterLibMaterialName`, `Decal.width`, `Decal.height`). The
same pattern holds in `.mat`: one full `Material : struct.begin` template plus 471
`Material.Name` / `Material.Texture.image` overrides. **Reading only the first block undercounts
the descriptors by ~250×** — the counts below use the full parse.

---

## 2. Decal family inventory

### 2.1 File census (`observed`)

| Location | Files | Extension breakdown |
|---|---|---|
| `decals\` root | 3 | `decals.lib` 63,831 B · `decals.mat` 71,997 B · `decals.presets` 75 B |
| `decals\buildings\` | 470 | 462 `.dds` + 4 `.lib` + 4 `.mat` (`decals_dlc1..3`, `decals_exp1`) |
| `decals\env\` | 3 | 3 `.dds` |
| `decals\pfx\` | 4 | 4 `.dds` |
| **Total** | **480** | **469 `.dds` + 5 `.lib` + 5 `.mat` + 1 `.presets`** |

No sibling `decals` directory exists elsewhere under `data\` (`observed`: recursive directory-name
match returned only the one path). `decals.presets` is an *empty* `DecalSetList` — no placement
presets live there.

### 2.2 Image census — dimensions, modes, formats (`observed` + `derived`)

| Property | Value |
|---|---|
| Decodable images | **469 / 469**, 0 unreadable |
| Pillow mode | **RGBA for all 469** |
| DDS FourCC | **DXT5 for all 469** (block-compressed, explicit alpha) |
| Size histogram | **455 × 1024²**, **6 × 512²**, **8 × 128²** |
| The 6 × 512² | `env\envfieldd`, `env\envfielddw`, `pfx\groundexp0..3` |
| The 8 × 128² | `buildings\eursgad(/w)`, `eurswad(/w)`, `eurwgad(/w)`, `eurwwad(/w)` |
| The 1024² group | everything else, incl. `env\christmastreed`, all `bldsiz*`, all `helper*` |

### 2.3 Family table (`observed` counts, `derived` grouping)

| Family | Files | Dimensions | Season pairing (from `.lib`) | Placement width×height (`.lib`) | Notes |
|---|---|---|---|---|---|
| `buildings\`, 22 nation prefixes | **462 DDS** = 226 `d` + 226 `w` + 3 `helper` + 7 `bldsiz` | 454 × 1024², 8 × 128² | every `d` has a `w` twin; helpers/size plates have **no** winter | 8×8 (127 sections), 7×7 (96), 5×5 (15), 4×4 (7), 6×6 (3), 3 blank (inherit default 4×4) | prefixes (plate pairs): `alg` 2, `aus`/`bav`/`den`/`eng`/`fra`/`hun`/`net`/`pie`/`pol`/`pru`/`sax`/`sco`/`swe`/`swi`/`ukr`/`ven` 10 each, `eur` 12, `por` 11, `rus` 15, `tur` 14, `spa` 12 |
| `buildings\` type suffixes | 450 plate pairs by role: `acad` 40, `artd` 40, `ba2d` 36, `bard` 40, `blad` 40, `cend` 42, `dipd` 40, `houd` 42, `stad` 40, `temd` 40, `mard` 8, `mild` 6, `pord` 10, `stod` 8, `towd` 6, `coad`/`gold`/`irod`/`sgad`/`swad`/`wgad`/`wwad` 2 each | as above | `d`/`w` | as above | "acad/artd/bard/blad/cend/dipd/houd/stad/temd" are the 10 common building roles; the rest are nation-specific |
| `env\envfieldd` / `envfielddw` | 2 | 512² | **summer↔winter pair**, shared alpha | **2×2** | field soil plate; summer/winter differ in RGB only (§3) |
| `env\christmastreed` | 1 | 1024² | `w = christmastreed` (same file both seasons) | **4×4** | tree-shaped cutout; no separate winter asset in the decal set |
| `pfx\groundexp0..3` | 4 | 512² | **no winter** (`w = self`) | **2×2** each | scorch / impact plates |
| `helper1..3`, `bldsiz1..7` | 10 | 1024² | no winter (the only 10 S-only entries in `decals.lib`) | inherit / blank | sparse marker and mostly-opaque size-template plates (§3) |

**Descriptor semantics (`observed`, decoded from the template blocks):**

| Key | Value | Meaning for the port |
|---|---|---|
| `SummerLibMaterialName` / `WinterLibMaterialName` | e.g. `polartd` ↔ `polartdw` | authoritative **summer/winter pairing**; autumn and spring are **always empty** |
| `width` / `height` | 2..8, integer | decal footprint in **world grid cells** (not pixels); 8×8 is the most common building footprint |
| `texscale` (X,Y) | 1,1 | one texture repetition across the whole width×height rectangle |
| `scalefactor`, `texoffset` | 1,1 / 0,0 | no extra UV transform in the base template |
| `epsilon` | 0.01 | engine depth bias to avoid z-fighting — **engine-specific, drop on port** |
| `texrotateenable` / `texscaleenable` / `texoffsetenable` / `texoffsetbyrotate` / `texflipvertical` | all `True` | the *editor* allows random rotate/scale/offset per placement, V-flipped — placement data is **not** in these files |
| `.mat` `imagealpha = tiaDefault`, `BlendingMode = bmTransparency`, `texturemode = tmModulate` | — | **alpha = coverage/opacity**, RGB multiplied into the ground. Confirms the DXT5 alpha channel is a cutout/feather mask, not a data ramp |
| `.mat` `FaceCulling = fcCull`, `moIgnoreFog = True`, `Compression = tcHighSpeed`, filters `maLinear` / `miLinearMipmapLinear`, `texturewrap = twBoth` | — | engine render state; no equivalent needed in a 2-D piece renderer |
| `decals.presets` | empty | no reusable placement presets |

**Key derived fact:** the 469 DDS match 472 `.mat` material names minus the 1 template (and counting
some names twice across DLC libs) — the descriptors are a *material registry*, not a placement
layer. Every per-placement transform (rotation, jitter, which cell) lives in the map/save data,
**not** in `decals\`. Any port use must supply its own placement table.

---

## 3. Mask-like image table — channel analysis

All numbers below are `derived` from decoded RGBA pixels (`numpy`, full image unless noted).

| Image | Size | R / G / B | Alpha | Channel meaning (`inferred` unless noted) |
|---|---|---|---|---|
| `env\envfieldd.dds` | 512² | olive/brown soil; mean (75.6, 67.5, 45.2) | min 0 / max 255 / mean **148.1**, 84.4 % >0, 256 unique, `corr(A,luma)=0.069` | **A = field footprint / soft feather**; RGB = seasonal soil texture. Not a data ramp — alpha is uncorrelated with brightness |
| `env\envfielddw.dds` | 512² | desaturated snow soil; mean (115.9, 110.9, 97.0) | **byte-identical** to `envfieldd` alpha (verified `np.array_equal`) | Same footprint, winter RGB only — the pair is *one mask + two colours* |
| `env\christmastreed.dds` | 1024² | mean (88.4, 82.9, 64.9) | mean 98.4, **only 48.6 % >0**, strongly bimodal (51.4 % at 0, 24.3 % at 254–255), `corr(A,luma)=0.418` | tree-outline **cutout**, not a gradient |
| `pfx\groundexp0` | 512² | mean (47.3, 45.6, 41.1) | mean 32.5, max **250**, 60.2 % >0, `corr(A,luma)=-0.459` | scorch footprint; darker (burnt) pixels are *more* opaque ⇒ alpha encodes damage/core intensity |
| `pfx\groundexp1` | 512² | mean (44.8, 45.2, 42.9) | mean 24.5, max 236, 57.6 % >0, `corr=-0.361` | same convention |
| `pfx\groundexp2` | 512² | mean (33.1, 27.4, 19.5) | mean 32.1, max 248, 54.5 % >0, `corr=-0.267` | same convention |
| `pfx\groundexp3` | 512² | mean (47.5, 40.1, 31.8) | mean 31.4, max 243, 56.5 % >0, `corr=-0.544` | same convention |
| `buildings\helper1` (sample) | 1024² | mean (93.3, 86.1, 66.4) | mean 20.5, **8.8 % >0**, `corr=0.661` | sparse marker plate; mostly transparent |
| `buildings\bldsiz1` (sample) | 1024² | mean (100.6, 85.4, 63.4) | mean 215.2, 84.7 % >0 | mostly-opaque **size template** |
| `buildings\polartd` (sample) | 1024² | mean (86.7, 81.7, 65.5) | mean 122.9, 61.2 % >0, `corr=-0.507` | building dirt plate — normal cutout/feather |
| **Port** `dmask\d_00/d_12/d_23` | **64² RGBA** | **R=G=B=255 constant** | varies (mean 38.6 / 127.5 / 216.7) | alpha-only blend masks; **unwired/vestigial** (`TERRAIN_PORT_ASSETS.md` claim 2) |
| `data\gen\terrainmasks.src\*.tga` | 256² RGB | R=0, G=0, B = **binary 0/255** (2 unique), A=255 | n/a (opaque) | pre-gauss map-gen heightmask |
| `data\gen\terrainmasks\*_gauss.tga` | 320² RGB | e.g. `continent_0_gauss`: R=0, G=0, **B = 256-level ramp** (mean 173.7) | n/a | antialiased water mask — the actual port mask source |
| `data\gen\terrainmasks.dlc5\*_gauss.tga` | 320² RGB | e.g. `coastal_0_gauss`: B 238-level ramp (mean 7.7) | n/a | same format, extra families (below) |
| `data\terrain\tiles\textures\alpha.bmp` | 512×256, mode `P` | grayscale 0..255 (251 unique) | n/a | donor tile-transition atlas |
| `data\terrain\tiles\textures\alphanull.bmp` | 512×256, mode `L` | **constant 0** | n/a | "no transition" atlas |
| `data\terrain\tiles\textures\alphavert.bmp` | 1024×512, RGB | grayscale, 256 levels, mean 77.4 | n/a | vertical transition atlas — cited by `copy_assets.py:136-137` as the `dmask` source |
| `data\materials\env\christmastreea.dds` | 512² RGBA | mean (82.6, 58.4, 45.5) | **all 255** | **not an alpha mask** despite the `a` — an alternate prop material |
| `data\materials\env\christmastree.dds` | 1024² RGBA | mean (31.1, 32.1, 18.4) | full 0..255 range, mean 128.8 | the *prop* texture (separate from the `decals\env\christmastreed` decal) |

**Channel verdict (`derived`/`inferred`):** inside `decals\`, **every** mask-like signal is the
DXT5 alpha channel and it always means "where/how strongly this decal shows" (coverage/opacity).
There are **no** dedicated ramp/distance/height masks in the decals folder. The only true semantic
RGB-channel masks in the donor are the `data\gen\terrainmasks*` heightmasks, whose R/G/B = relief /
forest-stone / water and pure white = player start (documented in `app\tools\import_donor_masks.py:5`
and `app\assets\terrain\masks\manifest.json`); the gauss variants carry **water in B only**
(`import_donor_masks.py:7-9`; confirmed on sampled masks).

---

## 4. Port cross-reference

Verdicts "WIRED / UNWIRED / MISSING" are taken from `docs/audit/TERRAIN_PORT_ASSETS.md` §2–3
(load-site test against the ten `res://assets/terrain/` sites in `app/scripts/*.gd`).

| Donor family | Port asset | Conversion state | Wiring | Gap / correction |
|---|---|---|---|---|
| `buildings\` 226 summer `d` plates | `decals_png\` 226 `d.png` (+ 226 `dw.png`) and `decals_dds\` 462 raw DDS | **CONVERTED** (`copy_assets.py:118-120` copies raw DDS; PNG twins exist) | **PARTIAL WIRED** — `world.gd:533-542` loads `%s%sd.png` | only the `d` form is addressable; 24 plates were downscaled to 512² and 8 are 128² (resolutions inconsistent, already documented) |
| `buildings\` 226 winter `dw` plates | same folder | **CONVERTED** | **UNWIRED** | the `%s%sd.png` constructor cannot emit a `w` suffix |
| `helper1..3`, `bldsiz1..7` | `decals_png\` 10 PNG | **CONVERTED** | **UNWIRED** | no literal / no nation+sid key |
| `env\christmastreed`, `envfieldd/w`, `pfx\groundexp0..3` | `deco_png\` **7 PNG, ALL RGB** (colorType 2; no alpha channel) | **CONVERTED BUT FLATTENED** — donor RGBA → RGB; alpha footprint discarded | **UNWIRED** (only `gen_variant_maps.py:185-190`, a preview tool) | `copy_assets.py:53` currently converts to RGBA yet the checked-in PNGs are RGB — mismatch `UNVERIFIED`; see claim 5 |
| `decals.lib` / `.mat` (root + 4 DLC pairs) | `decals_dds\` 4 `.lib` + 4 `.mat`; root master files not copied | **PARTIAL COPY** | **UNWIRED** | no runtime reader in `.gd`; the season/width metadata is unused |
| `decals.presets` | — | **MISSING** (empty in donor too) | n/a | nothing of value lost |
| `gen\terrainmasks` 7 families (`land`, `nowater2`, `mediterranean`→`med`, `peninsulas`, `islands`, `continents`, `continent`) | `masks\` 7 × 8 = **56 PNG, 320² RGB** + `manifest.json` | **CONVERTED** (`import_donor_masks.py:78-97`) | **WIRED** (`mapgen.gd:24`, `:125`) | none — this is the one fully successful mask pipeline |
| `gen\terrainmasks.dlc5` extra families: **coastal 57, lakes 151, rivers 157** (plus nowater/nowater2 duplicates) | — | **MISSING** | — | importer whitelist at `import_donor_masks.py:78-79` names only the 7 base families; these 3 are never imported |
| `gen\terrainmasks.src` 7 families, 1,279 TGA (256² binary) | — | **MISSING (by design)** | — | pre-gauss binary source; the gauss dir is the right import source |
| `tiles\textures\alpha*.bmp` → `dmask\d_00..23.png` | `dmask\` 24 × 64² RGBA | **CONVERTED** | **UNWIRED / vestigial** | `world.gd:727-750` returns `[]`; active seam defence is `_alpha_mask` (`:754-761`) |

**Totals (`derived`):** of the 469 donor decal images, 462 are represented in the port's
`decals_png`/`decals_dds`, 7 in `deco_png` (alpha-stripped), **0** are drawn with their donor alpha,
and only the `d` subset of building plates has a live load site. Of the 4 mask families worth
having, the 7 base map-gen families are wired and the 3 DLC families are absent.

---

## 5. Proposed uses (and explicit non-uses)

Each row gives a target asset/script and a **measurable** visual acceptance criterion. No row
authorises a donor binary in the repo; every RGBA target must be regenerated from the donor via the
private-use converter, never committed from `C:\Games\Cossacks 3`.

### 5.1 Worth wiring

| # | Use | Source → target | Acceptance criterion (`derived` from §3 numbers) |
|---|---|---|---|
| U1 | **Winter building plates** — snow/dirt variant for every building decal | 226 donor `buildings\*dw.dds` → already present `decals_png\*dw.png`; change `world.gd:533-542` to pick `dw` when `_season_key()==winter` | For a known nation+sid the resolved path ends `.dw.png` in winter and `.d.png` in summer; summer screenshot of a fixed seed is **byte-identical** to baseline; winter field pixels differ from the summer plate at ≥90 % of footprint pixels |
| U2 | **Farm/field decals with real footprint** | donor `envfieldd/w.dds` → regenerate `deco_png\envfieldd.png`, `envfielddw.png` as **RGBA preserving DXT5 alpha**; new draw pass in `world.gd` at food/resource nodes | PNG colorType 6; alpha histogram matches donor within 1 % per bin; alpha bbox equals donor `a>8` bbox; in winter, opaque-region RGB mean within ±5 of (115.9, 110.9, 97.0); outside-footprint alpha = 0 |
| U3 | **Scorch / impact decals** | donor `pfx\groundexp0..3.dds` → 4 RGBA PNG, new `world.gd` decal pass keyed to battle/impact events | Each PNG's alpha max ≤ 250 and `corr(A,luma) ∈ [-0.6,-0.2]`; a scripted impact at a known cell darkens ≥60 % of pixels within radius 2 cells vs baseline; 4 variants produce 4 distinguishable images (per-image mean-RGB spread > 5) |
| U4 | **Christmas tree (winter-only prop)** | donor `env\christmastreed.dds` → RGBA PNG + footprint family in `pattern_gen.gd`/`world.gd` (the `christmas` family is currently absent from `donor_patterns.json`) | Cutout alpha: 48.6 % ±1 % nonzero; winter screenshot shows the tree silhouette inside a 4×4 cell footprint; summer screenshot shows none; three separate tickets must land (asset, footprint JSON, draw case) |
| U5 | **Missing map-gen families** (`coastal`, `lakes`, `rivers`) | donor `gen\terrainmasks.dlc5\<family>\*_gauss.tga` → `import_donor_masks.py` whitelist + 8 PNG per family + manifest entries | 24 new 320² RGB PNG with `.import`; manifest water fraction computed by the existing `>58` rule; new `mapgen` type selectable and produces a map without error |
| U6 | **Descriptor-derived registry (metadata, not art)** | `decals.lib` season pairs + width/height → a generated JSON used by U1–U4 for footprint sizing | 256 root entries + 75 DLC entries parsed; every summer name resolves to an existing PNG; 246 S+W pairs and 10 S-only helpers/size recorded; no `.lib`/`.mat` shipped as runtime asset |

### 5.2 Explicitly NOT useful for the piece renderer

| Item | Why not (`derived` / `inferred`) | Recommendation |
|---|---|---|
| **DXT5 alpha as a semantic mask** | `.mat` declares `imagealpha=tiaDefault`, `BlendingMode=bmTransparency`, `tmModulate` — alpha is coverage/opacity, not a height/distance/ramp channel. Sampling shows field alpha is *uncorrelated* with luma (0.069) and scorch alpha is *inversely* correlated — it is content-dependent opacity, not a clean radial ramp. | Use it as opacity only (U2/U3). **Do not** feed it into shore/wet-sand blending as if it were a distance field; author a dedicated radial feather for that. |
| **`dmask\d_00..23.png`** | 24 × 64² alpha-only RGBA, but `world.gd:727-750` returns `[]`; the operative anti-seam path is `_alpha_mask` (`:754-761`). Wiring them adds no pixels. | Retire the dead `terrain_masks` array and fix stale comments; **not** a beauty ticket. |
| **`alpha.bmp` / `alphanull.bmp` / `alphavert.bmp` / `reftilealpha.mat`** | engine-side tile-transition atlases (512×256 / 1024×512) referenced only as the *provenance* of `dmask`; `alphanull` is constant 0. They are not decals and carry no new visual information. | Do not import. Document as donor-engine artefacts. |
| **`christmastreea.dds`** | despite the `a`, alpha is **all 255** — it is an alternate prop material, not a mask. | Ignore for decal work. |
| **8 × 128² `eur*sga/swa/wga/wwa` plates** | small gate decals already converted to PNG but unwired; upscaling 128²→1024² would invent pixels and break the plate-size convention. | Leave as converted-but-unwired; low value. |
| **`decals\buildings\decals_dlc*.lib/.mat` at runtime** | engine template grammar with `epsilon`, `fcCull`, `tcHighSpeed`, `texoffsetbyrotate` — no Godot equivalent; the useful facts are the season names and width/height. | Harvest into U6 JSON once; do not ship the raw descriptors. |
| **`gen\terrainmasks.src` (256² binary)** | superseded by the 320² gauss masks already ported; importing both would double the asset count with no new detail. | Keep excluded from the importer. |

---

## 6. Claim table

Verdict values follow `docs/audit/README.md`: `CONFIRMED`, `CONTRADICTED`, `UNVERIFIED`, `PARTIAL`.
"Evidence" is the donor/port path; "Method" is how this agent checked it independently.

| # | Claim | Evidence | Method | Verdict | Correction needed |
|---|---|---|---|---|---|
| 1 | "the donor decals folder has ~462 images" | full recursive walk of `data\terrain\decals\` | `os.walk` + extension count = 480 files, **469** DDS | **PARTIAL / CONFIRMED** with correction | 469 images + 11 descriptors + 1 presets; 462 is the `buildings\` subfolder only |
| 2 | "all donor decal plates are 1024²" | Pillow over 469 DDS | size histogram 455/6/8 | **CONTRADICTED** | 6 are 512² (field + scorch), 8 are 128² (`eur*` gates) |
| 3 | "some decal file is unreadable/corrupt" | DDS header + Pillow decode | 469/469 opened; DXT5 magic; 0 exceptions | **CONTRADICTED** | none |
| 4 | "envfieldd/w are a summer/winter pair with the same shape" | `decals.lib` S/W keys + alpha arrays | parsed descriptors; `np.array_equal` on alpha = True, RGB = False | **CONFIRMED** | none; strengthens `field_crops.md` §1.1 |
| 5 | "`deco_png/*.png` are RGBA with alpha 255" (`field_crops.md` §1.3) | `app/assets/terrain/deco_png/` | direct Pillow mode + PNG IHDR colorType | **CONTRADICTED** on file format; the *operational* conclusion (footprint lost) is **CONFIRMED** | they are **RGB colorType 2, no alpha channel**; the prior "alpha 255" was likely an artefact of calling `.convert('RGBA')`. Also note `copy_assets.py:53` converts to RGBA — source/asset mismatch is `UNVERIFIED` |
| 6 | "groundexp plates are generic dust puffs" | `pfx\groundexp0..3.dds` | alpha corr with luma −0.27..−0.54, max ≤250, mean 24–33 | **CONTRADICTED** (`inferred` reading) | pattern is consistent with scorch: darker core more opaque, never fully opaque |
| 7 | "the donor stores decal placement transforms in `.lib`/`.mat`" | full template blocks | keys transcribed in §2.3 | **CONTRADICTED** | only *capabilities* (`texrotateenable`, `texscaleenable`, `texoffsetbyrotate`) are stored; per-placement values are not |
| 8 | "`decals.presets` holds reusable decal sets" | 75-byte file | ASCII read | **CONTRADICTED** | it is an empty `DecalSetList` |
| 9 | "the port imported all donor terrain mask families" | `import_donor_masks.py:78-79` vs `terrainmasks.dlc5\` family list | set comparison | **CONTRADICTED** | coastal (57), lakes (151), rivers (157) TGA never imported; 7 base families are |
| 10 | "the 56 port masks are the donor gauss masks" | `masks\manifest.json` source + sampled TGA/PNG | Pillow on 320² RGB TGA and matching port PNG; channel stats equal | **CONFIRMED** | none |
| 11 | "`christmastreea.dds` is the tree's alpha mask" | `data\materials\env\christmastreea.dds` | alpha channel all 255 | **CONTRADICTED** | it is an alternate prop material; no alpha payload |
| 12 | "mask-like decal pixels encode a height/ramp channel" | all sampled decal RGBA | channel stats + `corr(A,luma)` | **CONTRADICTED** | alpha is coverage/opacity only; the only true R/G/B semantic masks are under `data\gen\terrainmasks*` |
| 13 | "the summer/winter field plates have identical alpha" | `envfieldd`/`envfielddw` | byte-for-byte alpha equality | **CONFIRMED** | none — one mask, two RGB fills |

**UNVERIFIED (do not promote):** why `copy_assets.py:53` converts to RGBA but the checked-in
`deco_png` PNGs are RGB (rebuilt with an older tool? post-processed? — provenance unknown); whether
the 24 port `dmask` PNGs were truly generated from `alpha.bmp` + `alphavert.bmp` (the comment exists
at `copy_assets.py:136-137` but no generator script was located); whether any of the 469 decal
plates are actually placed at runtime by the donor engine in a way the `width`/`height` values
predict (placement data is outside this folder); whether the 3 missing DLC mask families would
improve the port's map variety without new mapgen code.

---

## 7. Open questions

1. **Alpha-loss provenance.** Which tool wrote the current RGB `deco_png` files? If it was a
   deliberate flatten, U2/U3 need a new RGBA target name rather than overwriting existing PNGs.
2. **Field-placement source.** `field_crops.md` already notes the donor field art is olive/brown,
   with the in-game gold applied at render time. Where should the port's tint come from — a
   per-biome multiply, or a new recoloured PNG? This changes U2's acceptance colour target.
3. **Scorch trigger semantics.** The donor `groundexp0..3` have no winter variant and 2×2
   footprints; what port event should stamp them (projectile impact, building destruction,
   scripted battle)? Without that, U3 has no deterministic acceptance test.
4. **Christmas family.** Three independent tickets (RGBA asset, `donor_patterns.json` footprint,
   `world.gd` prop case) must land together. Who owns sequencing?
5. **DLC mask families.** Should `coastal`/`lakes`/`rivers` be added to the importer whitelist
   (U5), or is the current 7-family mapgen sufficient? The donor `terrainmasks.dlc5` tree has
   1,856 TGA vs 1,331 in `terrainmasks` — importing all would roughly triple port mask assets.
6. **Descriptor harvest.** U6 produces a JSON with 331 decal entries (256 root + 75 DLC). Is that
   worth a new runtime table, or should the port keep deriving plate names from existing nation/sid
   data and only use `width`/`height` as a constant per building role?
7. **128² gate plates.** Do the `eur*sgad/swad/wga/wwa` decals correspond to map objects the port
   actually renders? If not, they can stay converted-but-unwired indefinitely.

---

## Files changed

- `docs/audit/PIECES/donor_decals_and_masks.md` (new) — this report only.
  No code, asset, index, screenshot or status document was modified. All analysis scripts and any
  decoded viewing images were written to `%LOCALAPPDATA%\Temp\opencode\` and are **not** part of the
  deliverable. No donor binary was copied into the repository.
