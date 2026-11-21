# RENDER_ARCH_PATTERNS — do `.pattern` files place 3D meshes or 2D tiles?

Research lane **R-ARCH-PATTERN**, 2026-11-21.
**Read-only.** No donor file was copied into the repo, no Godot run was made, no
project code or asset was edited. Only this document was written.

Evidence labels:

- **observed** — read directly from bytes/files this session, with a citation or hex.
- **derived** — computed deterministically from observed data.
- **inferred** — best reading of donor conventions; plausible but not proven.
- **UNVERIFIED** — could not be confirmed; do not treat as fact.

Donor (private use only): `C:\Games\Cossacks 3`. Project root:
`C:\Users\Maxym.Oboyshev\Documents\Craft Anything\cossacks-3-3`.
Prior context: `docs/audit/TERRAIN_DONOR_PATTERNS.md` (format decode, 710-file
inventory), `docs/audit/TERRAIN_REFERENCE_IMAGES.md` (reference silhouettes and
shadows), `docs/audit/RENDER.md` (sprite pipeline).

---

## 1. Sources

### 1.1 Donor binary files opened read-only (byte/struct parser)

`C:\Games\Cossacks 3\data\pattern\` — dissected with Python 3.14 `struct` +
hex dumps:

| Pattern | w × h | Why | 
|---|---:|---|
| `mng_1.pattern` | 8 × 10 | gold mine; small enough for a full slot dump |
| `d_frt_big_1.pattern` | 38 × 57 | big pine/fir forest |
| `g_hil1.pattern` | 32 × 56 | light hill |
| `big_hill_1.pattern` | 51 × 56 | largest decor hill |
| `dcr1.pattern` | 22 × 21 | general decor |
| `d_stn_1.pattern` | 20 × 18 | stones |
| `d_tls_1.pattern` | 32 × 44 | "tiles" family (control case) |
| `new_year6.pattern` | 18 × 17 | festive trees/gifts |
| `k_lake_1.pattern`, `f1_from_big3.pattern`, `fb_1.pattern`, `n_small_frt_1.pattern`, `d_frt_mid_1.pattern`, `desert_frt_big1.pattern` | — | border/other-stage controls |

All were parsed for header, occupancy mask, 24-byte slot array, float values,
tail bytes, and ASCII runs. A 710-file name/extension scan was already done in
`TERRAIN_DONOR_PATTERNS.md §2.3`; this session re-checked 14 files independently
(**0 ASCII runs ≥ 6 in all 14**).

### 1.2 Donor text/metadata read

| Source | What it gave |
|---|---|
| `data/scripts/lib/misc.script:3325-3520` | `_misc_StandPatternPlaceMask`, `_misc_CheckStandPattern`, `_misc_CheckStandPatternExt` — the engine API boundary |
| `data/scripts/common.inc/dogenerate.inc:498-520,1330-1360,1757-1765,1790-1906` | tile/mine/forest/hill/decor placement stages |
| `data/scripts/lib/map.script:53-113` | direct `StandPattern(envPlHnd, <name>, x, z, 0)` calls for `tls_*`, `str_*`, `stn_*`, `mng*`, `frt_*`, `mnt*`, `plt*` |
| `data/scripts/common.inc/texturemap.inc:215-216,284-287,320-323,831-833`; `smoothforestborders.inc:120-123` | other-stage pattern stands |
| `data/objects/env/env.objects` | **354 ordered** env prop entries (`minegold`=0 … `desertstump4`=353) |
| `data/objects/env/pine1.prop`, `christmastree.prop`, others | `LODActorName`, `DefaultMeshName = *.mesh`, `RandomScale`, `RandomRollAngle`, `DefaultScale` |
| `data/actors/env/pine.actor`, `christmastree.actor` | `ActorList.Items[n].Name = *.mesh` → `MeshObjects.LoadFromFile = *.osm` |
| `data/game/var/envscales.cfg` | per-family scale + minscale/maxscale jitter |
| `data/actors/env/*.osm` | binary mesh headers (`IDP2`, LOD counts, `SkinBitMap`) |

### 1.3 Port files read

- `app/scripts/pattern_gen.gd:1-8,64-83,104-128,203-265,300-400` — footprint stamping.
- `app/scripts/world.gd:99-180,278-348,651-660,1807-1850,2130-2230,2440-2502` — sprite rendering.
- `app/tools/convert_models.py:214-250+` — `env_models()` conversion table.
- `app/tools/render_models.py:1-17` — orthographic 3/4-view sprite baking.
- `app/assets/models/manifest.json`, `app/assets/models/obj/**`, `app/assets/models/sprites*/**` — converted assets.

---

## 2. Byte evidence — what is actually in a `.pattern`

### 2.1 Header + mask — CONFIRMED (HIGH)

```
mng_1.pattern @0x00: 08 00 00 00 0a 00 00 00   -> int32 w=8, int32 h=10
mng_1.pattern @0x08: 01 01 01 01 01 01 01 01 01 00 00 00 01 01 01 00 ...
```

`w*h = 80` bytes of 0/1 occupancy. `mng_1` has 32 occupied cells. This is the
part the port already exports (`donor_gen.py:74-85`,
`export_donor_patterns.py:48-55`) and matches `TERRAIN_DONOR_PATTERNS.md §2.1`
(710/710 valid). **Footprint semantics are not in doubt.**

### 2.2 The 24-byte region is a *per-cell* slot array, not a sparse object list — NEW FINDING (observed/derived)

`mng_1` has 307 zero bytes from `0x58` (mask end) to `0x18a`. At `0x18b` a
strict 24-byte array begins; it has **exactly `w*h = 80` slots**:

```
0x18b  a1 00 00 00 | 00 00 80 3f | 00 00 80 3f | 00 00 80 3f | 00 00 80 3f | 00 00 00 00
       ^ int32 161  ^ 4 × float32(1.0) = 0x3f800000                       ^ 4-byte tail
0x1a3  df 00 00 00 | 00 00 80 3f ×4 | 00 00 00 00     (id 223)
...
0x75b  ... (id 114, last non-zero slot; spans 0x75b..0x772)
0x773  id 0 | floats (0,0,0,0) | tail 0     <- slots 63..79 are all zero
```

- **observed/derived:** 63 of 80 slots have a non-zero int32 and floats exactly
  `(1.0,1.0,1.0,1.0)`; the remaining 17 are all-zero. No other float pattern
  occurs in the array.
- **observed/derived:** the slot array length is **exactly `w*h`** in all 14
  dissected patterns. Counts: `d_frt_big_1` 2166 slots (2062/2072 non-zero),
  `big_hill_1` 2856 (2744/2750), `g_hil1` 1792 (1699/1705), `dcr1` 462
  (418/420), `d_tls_1` 1408 (1328/1333), `k_lake_1` 870 (813/812), `fb_1` 72
  (56/56), `n_small_frt_1` 63 (48/48), `desert_frt_big1` 380 (340/342).
  This **resolves prior open question #2** (`TERRAIN_DONOR_PATTERNS.md §7.2`):
  the region is a `w*h` structure-of-arrays, not an unknown-length object list.
- **derived:** the slot count is *not* the mask occupancy (`mng_1`: 63 vs 32;
  `d_frt_big_1`: 2062 vs 920). The two arrays are different data.

### 2.3 The int32 "id" cannot be a prop/mesh index — NEW FINDING (derived, decisive)

This session tested the task's explicit hypothesis that `id` indexes the 354
env props in `data/objects/env/env.objects` (an **ordered** list: 0=`minegold`,
1=`mineiron`, … 15=`fir`, 25=`pine`, 45=`spruce`, … 308=`gift`,
309=`christmastree`, … 353=`desertstump4`).

| Pattern | Non-zero ids | Distinct ids | Uniqueness |
|---|---:|---:|---:|
| `mng_1` (mine) | 63 | **59** | 94% |
| `fb_1` (forest border) | 56 | **53** | 95% |
| `n_small_frt_1` (small forest) | 48 | **41** | 85% |
| `new_year6` (christmas) | 272 | 167 | 61% |
| `d_stn_1` (stones) | 322 | 189 | 59% |
| `d_frt_big_1` (forest) | 2062 | 255 | 12% |
| `big_hill_1` (hill) | 2744 | 255 | 9% |

- A small prop index would **repeat heavily** (a mine uses ~3–10 prop types; a
  forest ~10–20). Instead small patterns have almost every cell a *different*
  byte; large patterns use all 256 byte values at near-uniform frequency
  (histogram per 32-value bucket: 288/238/242/257/259/264/266/258 for
  `d_frt_big_1`). **derived: inconsistent with a prop/mesh table index.**
- Mapping id→`env.objects` with base 0 and base 1 gives the *same* category
  mix for **every** family — pine/burch/stone/grass/fir dominate in a mine, a
  christmas clump and a tree clump alike, and mines map to boats/carts/barrels.
  **derived: no family-specific semantic resolution.**
- The 4-byte tail is a small value set (e.g. `mng_1`: 0×208, 86×64, 15×32,
  79×12, 7×4; `dcr1`: 0×1088, 14×348, 6×224, 9×124, 8×64) — plausible as
  small enum/variation channels, but **UNVERIFIED**.
- **Conclusion:** the numeric field is best read as a **per-cell variation/
  noise byte** (or per-cell packed parameter), *not* a resolvable mesh reference.
  The prop→actor→mesh chain below is real, but the link from pattern bytes to
  it is **UNVERIFIED** and now looks unlikely.

### 2.4 No embedded asset names (HIGH)

Zero ASCII runs ≥ 6 in 14/14 sampled patterns (this session); 710/710 scan in
`TERRAIN_DONOR_PATTERNS.md §2.3` found 0 asset-extension strings, 0 alpha runs
≥ 6. **A `.pattern` does not name a mesh, texture or `.prop`.** Any prop choice
must come from engine tables keyed by pattern *name* / generator family, not
from strings in the file.

---

## 3. Resolution chain — how a pattern becomes renderable objects

### 3.1 The script API stands objects, it does not paint tiles (observed)

`data/scripts/lib/misc.script`:

- `:3325` `_misc_StandPatternPlaceMask(patName, standX, standZ, angle, tmpMask)` —
  rotates mask cells by `angle` and writes `tmpPatternMask` (a **collision/
  occupancy** grid), using `GetPatternMaskWidth/Height/Offset` (`:3330-3332`),
  `GetPatternMaskStand` / `GetPatternInvMaskStand` (`:3361-3362`) and
  `GetPatternMaskValue(patName, i, j)` (`:3370`).
- `:3384` `_misc_CheckStandPattern(patName, plHnd, standX, standZ, angle,
  doStand, bWriteToParser, pHnd)`; at **`:3390`**:
  ```
  StandPatternWithAngle(plHnd, patName, standX, standZ, angleRad, 0, 90);
  ```
  This is a **native engine call** that "stands" the whole pattern for a
  **player handle** at a world position and an angle. `plHnd` is the
  environment player (`envPlHnd`) in every call site.
- `:3402-3500` the rest of `_misc_CheckStandPattern` only tests/writes
  `gPatternMask[...]` (`:3499-3500`); `GetPatternMaskValue` appears **only** in
  mask-collision code (`:3370,3460,3491`). No terrain-texture write API is
  ever passed pattern data.
- `:3516-3520` `_misc_CheckStandPatternExt(envplHnd, patName, x, z, ...)` —
  test then stand, writing name/x/y to a record-manager parser for replay.
- `:3566-3731` `_misc_SelectPatternListParser`, `_misc_PatternIncreaseFreq`,
  `_misc_GetPatternNameByParser`, `_misc_PlacePatternByType`,
  `_misc_SetupPatternsByType` — weighted family selection + frequency update.

`data/scripts/common.inc/dogenerate.inc`:

- `:498` comment "setup tiled patterns on map"; `:507-515` `SetupTiles` picks
  `tls_*` names and calls `_misc_CheckStandPatternExt` — i.e. **"tiled" means
  tiled *placement grid*, not painted tile textures.**
- `:1330-1351` `SetupTiledPatterns` stands each pattern on a 25×25-cell grid
  with `_misc_CheckStandPattern(..., doStand=True, ...)` at `:1349`.
- `:1757-1906` every relief/forest/stone/decor family is placed with
  `_misc_SetupPatternsByType(pGenerator, envplHnd, <family>, freq)`.
- `data/scripts/lib/map.script:53-113` calls the native directly:
  `StandPattern(envPlHnd,'tls_5',...)`, `'str_7'`, `'stn_5'`, `'mnc1'`,
  `'mng1'`, `'frt_big2'`, `'mnt5'`, `'plt3'`, etc. — the *same* primitive for
  tiles, stones, mines, forests, mountains and plateaus.
- `ClearMapMaskAndObjects()` (`dogenerate.inc:444-481`) clears `gPatternMask`,
  calls `ResetPatternMap(False)` and destroys player game objects — the pattern
  map is tied to **objects and collision**, not to terrain paint.

**observed:** all pattern placement flows through `StandPattern*` on
`envPlHnd`. The mask is the standability/collision gate. There is no code path
that paints a terrain tile from a `.pattern`.

### 3.2 Props are 3D meshes with random yaw and scale (observed)

- `data/objects/env/env.objects` lists **354** env props; `objects.lib` maps
  the `env` group (`Tag=40`) to this collection.
- `christmastree.prop`: `LODActorName = christmastree`, `DefaultMeshName =
  christmastree.mesh`; `scaleproperty` `DefaultScale.X/Y/Z = 0.5`,
  `RandomScale = True`, `MinScaleFactor = 0.85`, `MaxScaleFactor = 1.15`;
  `directionupproperty` `DefaultRollAngle = 270`; `autochildrenproperty`
  references a second mesh `christmastreea`.
- `pine1.prop`: `LODActorName = pine`, `DefaultMeshName = pine1.mesh`,
  `RandomScale = True`, **`RandomRollAngle = True`, `DeltaRollAngle = 1`**.
- `data/actors/env/pine.actor`: `ActorList.Items[0..3].Name = pine1..pine4.mesh`
  each with `MeshObjects.LoadFromFile = .\data\actors\env\pineN.osm`.
  `christmastree.actor`: `christmastree.mesh` → `christmastree.osm`.
- **derived:** 353 of 354 env props resolve `DefaultMeshName` → a `.actor` LOD
  entry → a `.osm`, covering **259 distinct** of the **273** env `.osm` files.
- `data/game/var/envscales.cfg`: `mines` scale `0.3152` min/max `1`;
  `stones` scale `0.329` min/max `0.85/1.15`; trees similarly.
- `.osm` files are real 3D geometry: header `IDP2` (`49 44 50 32`), LOD counts,
  `SkinBitMap` table. `fir1.osm` 39,252 B (LOD counts 752/789/865),
  `pine1.osm` 85,900 B (1201/1367/1516), `stones1.osm` 9,500 B (156/185/224),
  `christmastree.osm` 44,300 B (835/849/1000). Donor totals: **3897 `.osm` +
  335 `.oss` = 4232** actor meshes; env subset 273 `.osm`, 104 `.actor`, 354 `.prop`.

### 3.3 What the numeric ids do *not* do (derived)

The uniform/near-unique id distribution (§2.3) means the per-cell byte cannot
be used to pick one of ~10–20 props. The donor engine must obtain the prop
family from the pattern's **name / generator group** (e.g. `d_frt_big_*` →
pine/fir, `mng*` → minegold/iron/coal, `dcr*` → bushes/stumps/flowers) and use
per-cell variation only for mesh/scale/roll jitter. This is **inferred**: the
name→prop-family table lives in engine code/config not decoded here (the
`generator.cfg` family list is documented in `TERRAIN_DONOR_PATTERNS.md §1.2`).

---

## 4. Verdict

**Donor `.pattern` files place 3D objects, not 2D tiles.** Concretely:

- A pattern is a `w×h` **standability/collision mask** plus a per-cell attribute
  array; the engine stands it as a batch of environment **game objects** via
  `StandPattern[WithAngle](envPlHnd, name, x, z, angle)`, with per-object yaw
  (`RandomRollAngle`, `DeltaRollAngle`) and scale (`RandomScale`,
  `envscales.cfg` min/max 0.85–1.15). The actual renderables are `.osm` 3D
  meshes resolved through `.prop` → `.actor` → `.osm`.
- Even the `tls_*` "tiles" and `d_tls_*` patterns are stood with the same API:
  they are 3D ground/decal props (e.g. `terrainmesh`, `terrainplateau`), not
  texture paint. Terrain tile painting is a separate pipeline
  (`data/gen/tilesmooth.cfg`, `texturemap.inc`).
- Forest/hill/stone clumps are therefore **collections of 3D meshes with
  arbitrary yaw and scale**. That directly explains the reference's irregular
  canopy silhouettes and the directional, object-shaped shadows observed in
  `TERRAIN_REFERENCE_IMAGES.md §3.5` (sun upper-right, shadows lower-left,
  length ≈ 1–2× object height; lit/shadow luma ratio ≈ 1.7–1.9).
  **Caveat:** the reference images were inspected in that prior lane, not in
  this one; the link from "3D meshes" to those specific pixels is **inferred**.
- **Not** supported: 2D sprite tiles. There is no tile-painting call anywhere
  in the pattern path, and the env objects are binary 3D meshes with LODs.

**Port status:** the port reproduces the *placement logic* but not the *3D
objects*. `pattern_gen.gd` mirrors `GetPatternMaskValue`/`CheckStandPattern`
rejection sampling: `scale_cells()` (`:74-85`), `can_stand()`/`stand()` (`:88-103`),
`stamp_family()` (`:130-160`), tile grid (`:180-201`), mines (`:203-237`),
forest/stone/hill/decor recipes (`:249-265`, `:360-398`). It emits `Stamp`
records holding `cells` (footprints) only — no object yaw/scale/mesh ids.
`world.gd` then draws the visuals as **2D sprites**: `_load_sprites()`
(`:307-348`), `_prop_tex()` (`:1847-1851`), `_draw_forest_tree()`
(`:1874-1900`), prop drawing (`:2130-2230`), mine sprites (`:2440-2502`).
Donor scale/jitter is approximated in sprite height via `ENV_SCALE` and
`ENV_JITTER_MIN/MAX = 0.85/1.15` (`world.gd:155-172`), and a soft ellipse
stands in for a real shadow (`_draw_sprite`, `:651-660`).

---

## 5. Port gap

| Aspect | Donor | Port today |
|---|---|---|
| Placement semantics | `StandPattern` on `envPlHnd`, mask-gated | footprint stamps + occupancy grid (`pattern_gen.gd`) |
| Renderable | `.osm` 3D mesh + LOD per object | baked/procedural 2D PNG sprite (`world.gd`) |
| Yaw | `RandomRollAngle`/`DeltaRollAngle` per prop | no yaw; single baked view per sprite |
| Scale | `DefaultScale` × 0.85–1.15 jitter | `_env_sprite_h()` jitter on sprite height only |
| Shadow | real directional light on 3D geometry | `draw_circle` ellipse at `world.gd:658` |
| Asset coverage | 273 env meshes / 354 props | 87 env-ish sids converted of 273 (derived) |

Consequences visible in the reference comparison: sprite silhouettes are
view-fixed (no arbitrary yaw), canopy edges are flatter, and object shadows
are uniform ellipses rather than silhouette-shaped. This is the concrete
render-architecture gap behind the "irregular silhouettes and shadows" finding.

---

## 6. 3D-mode asset reuse estimate

An orthographic-3D port can reuse the existing conversion pipeline almost
verbatim — the meshes are already local derived assets:

- **Already usable now:** `app/assets/models/manifest.json` has **116** entries,
  each with `obj`, `texture_png`, `bbox`, `verts`, `faces`. **116 `.obj`** files
  exist in `app/assets/models/obj/`; **87** manifest sids are env-ish
  (`tree_*`, `rock*`, `stone*`, `bush*`, `fern*`, `reed*`, `plantain*`,
  `christmastree*`, `mine_*`, `field`). These can be loaded as
  `MeshInstance3D` under an `OrthographicCamera3D` with no further donor
  conversion.
- **Rendered sprites:** `sprites_hi/` 90 PNG, `sprites/` 179 PNG —
  `render_models.py:1-17` already documents an orthographic low-three-quarter
  camera, i.e. the exact camera a 3D-ortho port would use. The sprite path and
  the 3D path share the same source meshes and the same camera framing.
- **Remaining donor pool:** 3897 `.osm` total / 273 env; ~186 env meshes beyond
  the 87 converted sids. Per-family conversion cost is mechanical: extend
  `convert_models.py:env_models()` (current table ~34 sid mappings + 3 mines;
  **correction** to prior doc's "6 hardcoded entries" — the table has since
  been expanded) and rerun `convert_models.py` → `render_models.py`. Priority
  families for patterns: `pine*`, `fir*`, `spruce*`, `pinesmall*`, `firsmall*`,
  `pinestump*`, `burch*`, `rocks*`, `smallstones*`, `landstone*`, `rocksea*`,
  `bushes*`, `grass*`, `reed*`, `christmastree*`.
- **Placement bridge:** because the per-cell byte is not a prop index (§2.3),
  a 3D port should keep `pattern_gen.gd`'s footprint stamps as object anchors —
  place one (or a few) mesh instances per stamped cell, choose the mesh family
  from `Stamp.family`/`Stamp.name`, and derive yaw/scale from a hash of the
  cell position (same determinism source as `_env_sprite_h()` today). No
  new binary decode is required to get a visually faithful clump.
- **Lighting:** reuse the reference lighting target from
  `TERRAIN_REFERENCE_IMAGES.md §3.5` (directional sun upper-right, ~1–2×
  height shadows, lit/shadow ratio ~1.7–1.9). 3D meshes plus one directional
  light produce the silhouette-shaped shadows the sprite path only approximates.
- **Do not** expect to "decode object records" into positions: there are no
  position floats in the 24-byte slots (floats are exactly 1.0 or 0.0). Object
  positions come from the mask footprint; that is the only position signal in
  the file.

---

## 7. Claim table

| # | Claim | Evidence | Method | Verdict | Caveat / correction |
|---|---|---|---|---|---|
| R1 | `.pattern` = `w,h` + `w*h` occupancy mask | `08 00 00 00 0a 00 00 00`; 710/710 valid | hex + prior scan | **observed / CONFIRMED** | none |
| R2 | 24-byte region is a per-cell slot array of length exactly `w*h` | 14/14 patterns; 80 slots in `mng_1`, 2856 in `big_hill_1` | `struct` + count | **observed / CONFIRMED** | Corrects prior "record count ≈ w*h" to *exactly* `w*h` |
| R3 | Slots hold `[int32 0..255][4×float32(1.0)][4B]`; empty slots all zero | full `mng_1` slot dump; 63 occupied, 17 zero | hex + `struct.unpack` | **observed / CONFIRMED** | floats are only 1.0 / 0.0 — no position, scale or yaw values |
| R4 | The int32 indexes a prop/actor/mesh table | 59/63 distinct in `mng_1`, 255 distinct uniform in large patterns; mapping yields boats/carts in a mine | statistics + `env.objects` cross-reference | **REFUTED** | Best read as per-cell variation byte; not a mesh index |
| R5 | `.pattern` embeds mesh/texture paths | 0 ASCII runs ≥6 in 14 files; 0 asset strings in 710 | byte scan | **REFUTED** | names must come from engine family tables |
| R6 | Patterns stand 3D objects | `StandPatternWithAngle(plHnd,patName,x,z,angle,0,90)` `misc.script:3390`; `StandPattern(envPlHnd,...)` `map.script:53-113` | script read | **observed / CONFIRMED** | angle arg passed 0 by script; per-object yaw from props |
| R7 | Patterns paint 2D terrain tiles | `GetPatternMaskValue` used only for mask collision (`:3370,3460,3491`); no tile API | script search | **REFUTED** | `tls_*` = tiled *placement grid*, not painted tiles |
| R8 | Props supply 3D meshes with random yaw + scale | `RandomScale`, `RandomRollAngle`, `DefaultScale`, `envscales.cfg` 0.85–1.15 | prop/cfg read | **observed / CONFIRMED** | explains irregular silhouettes |
| R9 | prop → actor → `.osm` resolves | 353/354 env props resolve to 259 distinct `.osm`; `pine.actor`, `christmastree.actor` | path resolution | **observed / CONFIRMED** | link from pattern bytes to this chain is UNVERIFIED (R4) |
| R10 | `.osm` are 3D geometry with LODs | `IDP2`, LOD counts, `SkinBitMap`; fir1 39 KB, pine1 86 KB | binary header | **observed / CONFIRMED** | 3897 `.osm` + 335 `.oss` total |
| R11 | Reference shadows/silhouettes are from those meshes | upper-right sun, lower-left object shadows 1–2× height (ref doc §3.5) | prior image inspection + this chain | **inferred** | not re-imaged this lane |
| R12 | Port stamps footprints only, draws sprites | `pattern_gen.gd:74-103,130-160,249-265`; `world.gd:307-348,1847-1851,2130-2230` | code read | **observed / CONFIRMED** | no yaw/scale/mesh in `Stamp` |
| R13 | Port has 116 converted models / 87 env sids | `manifest.json`, `obj/**`, 90 `sprites_hi` | file count | **observed / CONFIRMED** | 273 donor env meshes → ~186 not yet converted |
| R14 | `env_models()` has only 6 entries | current `convert_models.py:224-250+` has ~34 mappings + 3 mines | code read | **CORRECTED** | prior doc outdated; table expanded |
| R15 | `0, 90` args of `StandPatternWithAngle` | single call site; no docs | script search | **UNVERIFIED** | likely range/seed params, unknown |

---

## 8. Open questions

1. **What are the 4 tail bytes?** Small enum-like values (0/1/6/14/15/78/79/86…)
   but no proven meaning. Could be material/variation channels that the engine
   combines with the pattern name. Needs a donor-side correlated probe or
   decompiler pass.
2. **What is the int32 byte, precisely?** Uniform 0..255 and near-unique in
   small patterns rules out a prop index; it may be a per-cell random seed
   fed into prop-variation selection. UNVERIFIED.
3. **Where is the pattern-name → prop-family table?** `generator.cfg` lists
   families and weights but not the prop pool per family. The mapping is
   **inferred** from family names and prop categories, not read from a file.
4. **Meaning of `StandPatternWithAngle(..., 0, 90)` trailing args** — scale
   range? count? rotation step? Only one call site exists.
5. **Do occupied mask cells map 1:1 to objects?** `mng_1` has 32 mask cells but
   63 non-zero attribute slots; the engine's object count per cell is
   UNVERIFIED. The port currently uses 1 footprint = passage blocker, with
   sprites generated separately in `world.gd`.
6. **`0xffff` int16 plane and float planes** from the prior doc remain
   undecoded; this session did not re-examine them beyond confirming the
   24-byte slot array.
7. **Reference-to-mesh visual fidelity** — no donor render was made in this
   lane; R11 stays inferred.

---

*End of document. No donor asset was copied into the repository; all donor paths
above are references for private-use conversion tooling only.*
