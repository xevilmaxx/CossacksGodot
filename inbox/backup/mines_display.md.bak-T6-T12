# mines_display — donor truth, port defect, piece spec, fix proposal

Lane: **T2-PIECE-MINES** (research only). 2026-11-21.
**Files owned/changed:** `docs/audit/PIECES/mines_display.md` only.
No code edit, no Godot run, no donor file copied. Donor paths below are
private-use references only.

Owner report: *"mines are not correctly displayed on the map, test mines display
on terrain also"* — read as two coupled symptoms: (a) the on-map mine/ore marker
does not look like a mine, and (b) `test*` block names are selected for the
worked ground in and around mine footprints.

Evidence labels: **observed** (read/measured here or cited from a prior lane),
**derived** (computed from observed data), **inferred** (plausible, not proven),
**UNVERIFIED** (do not promote without re-check).

---

## 1. Donor truth — how Cossacks 3 actually renders mines

### 1.1 Asset chain (all `observed`)

```
data/objects/env/minegold.prop   → DefaultMeshName = minegold.mesh, LODActorName = minegold
data/objects/env/mineiron.prop   → DefaultMeshName = mineiron.mesh, LODActorName = mineiron
data/objects/env/minecoal.prop   → DefaultMeshName = minecoal.mesh, LODActorName = minecoal
  (+ minegolds / mineirons / minecoals.prop — "small" variants, same meshes,
   same 0.3152 scale; CustomName only differs)
        ↓
data/actors/env/minegold.actor   → ActorList.Items[0].Name = minegold.mesh
                                    LoadFromFile = .\data\actors\env\minegold.osm
        ↓
data/actors/env/{minegold,mineiron,minecoal}.osm   (IDP2 binary, 55,876 B each)
```

- `mine*.prop` each carry `scaleproperty DefaultScale X=Y=Z=0.3152` and
  `CategorieName = resources`. Materials: `Mesh[0].UseableSummerMaterials[0] =
  minegold|mineiron|minecoal`, winter `minegoldw|mineironw|minecoalw`,
  `UseSeasonMaterial = True`.
- `data/game/var/envscales.cfg:16-36` — `group = mines`, three entries
  (`minecoal`, `minegold`, `mineiron`), each `scale = 0.3152` with
  **`minscale = 1`, `maxscale = 1`** (no jitter). By contrast `group = stones`
  at `envscales.cfg:40-46` uses `scale = 0.329`, `minscale = 0.85`,
  `maxscale = 1.15`. **The port's claim that every env entry has 0.85–1.15
  jitter (`app/scripts/world.gd:143-148`) is WRONG for mines** (§3, C7).
- The three `.osm` files are **byte-identical** (SHA-256 prefix
  `A2A6380C7521B941` for all three). Gold/iron/cal therefore share **one
  silhouette**; the only donor-side differentiator is the material/texture.
  This is why the converted sprites `app/assets/models/sprites/mine_{gold,iron,coal}.png`
  all show the same mound with different ore-speck colour.

### 1.2 Prop geometry and on-map size (`observed` + `derived`)

The private-use converted OBJ `app/assets/models/obj/mine_gold.obj`
(1,065 vertices / 1,234 faces, texture `tex/mine_gold.png` 2,048×2,048) gives:

| Axis | Raw mesh bounds | × 0.3152 (donor world units ≈ metres) |
|---|---:|---:|
| X | −7.1416 … 7.8848 (size 15.026) | **4.736** |
| Y | −7.9127 … 7.9091 (size 15.822) | **4.987** |
| Z | −1.5514 … 0.3619 (size 1.913) | **0.603** |

**Derived:** the donor mine prop is a low, near-square mound roughly
**4.7 × 5.0 m wide and 0.6 m tall**. At the port's `TILE = 2.0 m` that is
≈ **2.4 × 2.5 tiles** — a small footprint, consistent with the port's
`2.5 * TILE` paint radius (`game.gd:593`) but *not* with an 8×10-cell pattern
footprint being fully covered by the prop. The pattern is the placement
stamp; the prop occupies only its centre.

The baked 160×160 PNG sprite (`sprites/mine_gold.png`, `mine_iron.png`,
`mine_coal.png`) includes an **olive-green polygonal ground disc** behind the
mound (seen directly in the PNG and in `app/shots/prop_mine_{iron,coal}.png`).
That disc is a renderer artefact of the private-use bake, not donor art; drawn
over dirt it produces a green oval (observed). There is **no** `sprites_hi/`
variant for any `mine_*` sid — only the 160² low-res set (observed).

### 1.3 Placement / footprint (donor generator)

- `data/game/var/generator.cfg` — three mine families `mng`, `mni`, `mnc`
  (and `desert_mng/mni/mnc`), each with 5 numbered patterns plus an `mng4`/
  `mni4`/`mnc4` alias. Family→ore is gold / iron / coal respectively.
- `data/scripts/common.inc/dogenerate.inc:522-717` `SetupMines(...)`:
  - `rounds = 3 + minesdensity` (density 0/1/2 → 3/4/5 rings), capped by
    `maxround`;
  - for each ring `i` and each `str ∈ {mng,mni,mnc}` (prefixed `desert_` in
    desert), pick a pattern name from the family list, try up to **256**
    random angles, distance bands of e.g. `14+RandomExt*8`,
    `32+RandomExt*10`, `70+RandomExt*12`, `22+RandomExt*16` (version/map-size
    dependent, `:559-655`);
  - accept the first candidate that passes
    `_misc_CheckStandPatternExt(..., True, pRecordManagerPatternList)`
    (`:709-713`) — i.e. the donor's own footprint/no-overlap test.
  - `mng_1.pattern` is **8 × 10 cells, 32/80 occupied, 63 object records**
    (prior `docs/audit/TERRAIN_DONOR_PATTERNS.md` §4 §2.2). The numeric record
    ids were **not** resolved to props (that doc's C7/C8/T3), so the exact
    per-cell prop list and any scar/soil texture id remain **UNVERIFIED**.
- **No external mesh/texture path is embedded in any `.pattern`**
  (`TERRAIN_DONOR_PATTERNS.md` §2.3, 710-file scan). Therefore the donor's
  worked-ground/scar texture around a mine is selected by the generator's
  `plain_*`/tile passes, **not** by the mine pattern file. Attributing a
  specific scar DDS to the mine family would be **inferred**.

### 1.4 What the donor's `test*.dds` really are (`observed` — corrects prior wording)

`data/terrain/tiles/textures/test0.dds … test25.dds` — **26** files, each
**1024×1024 DXT1, 11 mip levels, 699,192 bytes** (DDS header read here:
magic `DDS`, hdr 124, w/h 1024, mips 11, fourcc `DXT1`).

Those are **real soil textures**, not blank UV plates: the converted twins in
`app/assets/terrain/blocks/test2.png` and `test3.png` show (viewed directly):

- `test2` — gray-brown rocky/gravelly dirt with sparse green flecks;
- `test3` — green grass with dense scattered grey rock fragments.

So `test*` is a legitimate donor tile family that the port wired into
`presets_summer.json:73-111` (indices 71–96). Calling them "placeholder tiles"
(`TERRAIN_PORT_ASSETS.md:79`) is imprecise: they are **ground textures being
used in the wrong semantic role** (mine apron / road dirt). See §2.

### 1.5 Donor reference image — UNVERIFIED

`docs/audit/TERRAIN_REFERENCE_IMAGES.md` catalogues all 12 donor screenshots
and contains **zero** mentions of mines, mine props, pits or headframes.
No donor reference image has a clear mine. **The visual reference for this
piece is therefore UNVERIFIED**; §4's spec anchors to donor *asset geometry*
(§1.1–§1.3), not to a screenshot.

---

## 2. Port defect diagnosis (file:line evidence)

### 2.1 Root cause — selected ground names, not missing art

1. **Mine stamp paints the apron as terrain role 1 ("dirt/road").**
   `app/scripts/game.gd:590-594`:
   ```gdscript
   "mine":
       if not is_blocked(cpos):
           _add_res(str(st.res), cpos, 0, 0.0)
       _paint_terrain(cpos, 2.5 * TILE, 1)      # <-- terrain = 1
       _clear_trees(cpos, 6.0 * TILE)
   ```
   `_paint_terrain` (`game.gd:386-403`) writes `terrain[...] = t` on every
   cell within the feathered 2.5-tile disc. Terrain enum: 0 meadow, **1 dirt/
   road**, 2 sod/forest, 3 water, 4 sand, 5 rock (`game.gd:766-782`,
   `:1143-1178`; the `1` case is explicitly annotated "donor PlaceRoads").

2. **Terrain role 1 deterministically selects `test2`/`test3` ~50% of the time.**
   `app/scripts/game.gd:1143-1154`:
   ```gdscript
   1:
       var r2 := brng.randf()
       if r < 0.5:      b = _blk("ground1")
       elif r2 > 0.25:  b = _blk("test2")   # 37.5%
       else:            b = _blk("test3")   # 12.5%
   ```
   **Derived:** for a uniformly random roll, 50% of all dirt cells (and hence
   a ~50% share of each 2.5-tile mine apron) draw `test2` or `test3`.
   This is the exact mechanism by which `test*` block names appear in mine
   footprints — not a bad JSON, not a missing PNG.

3. **Those names are resolvable and actively warmed**, so the defect is
   silent: `presets_summer.json:73-111` lists `test0..25`; `game.gd:991-995`
   builds `tbl_idx` from that array; `game.gd:1121-1122` `_blk()` maps the
   name to an index; `world.gd:702` loads `blocks/%s.png`; `world.gd:173`
   explicitly pre-warms `test7/test8/test9/test2` with the terrain families.

4. **`tileblocks.json` is NOT the cause.** It is a 245-entry donor metadata
   array of `{name,size,rows,cols,anglex,anglez}` (observed), contains `test*`
   names but **no `mine` entry**, and has **no `.gd` load site** — it is
   unwired (consistent with `TERRAIN_PORT_ASSETS.md` §2 claim 8). Do not fix
   by editing it.

5. **`world.gd` ore branch draws a boulder, not a mine** (the other half of
   the owner report). `app/scripts/world.gd:1656-1688`, case
   `"gold", "iron", "coal"`:
   - `:1663` `var outcrop := _prop_tex(["rock"], n.pos)` → `sprites/rock.png`
     (a plain grey boulder, viewed directly);
   - `:1667-1668` a faint tinted ground ellipse;
   - `:1670` draws that rock at `_env_sprite_h(3.5, "mine", n.pos)`;
   - `:1686-1688` three coloured circles as "ore veins".
   There is **no call to `mine_gold` / `mine_iron` / `mine_coal`** in this
   branch. The ore deposit — the permanent on-map landmark where the mine
   will be built — therefore reads as a grey rock with coloured dots sitting
   on a `test2`/`test3` patch.

6. **Built mines do use the correct sprite, so the art exists.**
   `app/scripts/world.gd:1929-1943` `_draw_mine()` calls
   `_sprite_for(e.sid, -1)` at `:1931` with `e.sid = mine_gold|mine_iron|
   mine_coal` (`data.gd:995-1000`) and draws it at `:1936`. The sprites are
   loaded via the `Data.BUILDINGS` loop at `world.gd:299-301` (they are *not*
   in `_env_sids()` at `:269-281`, which is fine). `app/tests/results/
   t_mine_unified.json` reports `passed: true` for gold/iron/coal preview,
   legality, and build — so placement logic is correct; rendering is not.
   Residual built-mine issues: the baked olive-green disc (§1.2) and the
   procedural fallback at `world.gd:1944-1954` (grey circles + timber frame).

7. **Secondary scale defect.** `world.gd:153-158` `_env_sprite_h()` applies
   `ENV_JITTER_MIN/MAX = 0.85/1.15` to `kind == "mine"`, justified by the
   comment at `:143-148` that "every entry carries minscale 0.85 / maxscale
   1.15". Donor `envscales.cfg:16-36` says mines are `1/1` — the port gives
   mine deposits and built mines a ±15% size wobble the donor never had.
   `world.gd:1670` uses `base = 3.5` for the deposit vs `world.gd:1936`
   `base = 3.0` for the building, so the *marker is drawn taller than the
   finished mine* — visually inverted.

### 2.2 Diagnosis summary

| Symptom | Actual cause | Where |
|---|---|---|
| `test*` tiles show where mines are | Mine apron painted `terrain=1`; role-1 tile picker emits `test2`/`test3` 50% of the time | `game.gd:593` + `game.gd:1144-1154` |
| Mine marker does not look like a mine | Ore deposit draws generic `rock.png` + coloured dots instead of `mine_*` sprite | `world.gd:1656-1688` (esp. `:1663`, `:1670`) |
| Mine looks wrong even after building | Baked green ground disc in sprite; wrong 3.5 vs 3.0 height; spurious ±15% jitter | `world.gd:143-158`, `:1670`, `:1936`; sprite PNG |
| "Fix tileblocks.json" | Irrelevant — file is unwired and has no mine entries | `tileblocks.json` (245 entries), no `.gd` site |

---

## 3. Claim table

| # | Claim | Evidence | Method | Verdict | Correction / caveat |
|---|---|---|---|---|---|
| C1 | Donor mine props resolve `prop → .actor → .osm` and use scale 0.3152 | `minegold.prop` `DefaultScale 0.3152`, `DefaultMeshName=minegold.mesh`; `minegold.actor` → `minegold.osm`; `envscales.cfg:16-36` | Direct file read | **CONFIRMED** | Small `*s` props use the same mesh/scale |
| C2 | Gold/iron/coal have distinct donor mine meshes | SHA-256 prefix `A2A6380C7521B941` identical for all three `.osm` | Hash of 3 donor files | **REFUTED** | One shared silhouette; only material differs |
| C3 | Miners have 0.85–1.15 scale jitter | `world.gd:143-148` comment + `ENV_JITTER_*` | Source read vs `envscales.cfg:16-36` | **REFUTED** | Mines are `minscale=maxscale=1`; jitter applies to stones/trees |
| C4 | Donor mine mesh ≈ 4.7×5.0×0.6 m at 0.3152 | OBJ 1,065 v / 1,234 f, raw 15.026×15.822×1.913 | Python bounds × 0.3152 | **CONFIRMED (derived)** | ≈2.4×2.5 port tiles at `TILE=2.0` |
| C5 | `mng_1` = 8×10 cells / 63 records | Prior `TERRAIN_DONOR_PATTERNS.md` §2.2/§4 | Prior hex decode | **CONFIRMED (observed in prior lane)** | Record id → prop mapping remains UNVERIFIED |
| C6 | Mine placement uses 3 rings × 3 ores × 256 angle tries with a footprint test | `dogenerate.inc:522-717`, accept at `:709-713` | Direct read | **CONFIRMED** | Desert uses `desert_` prefix |
| C7 | The mine `.pattern` names a scar/soil texture | 710-file scan: 0 asset-extension/path strings | Prior `TERRAIN_DONOR_PATTERNS.md` §2.3 | **REFUTED** | No external names in patterns; scar selection is a separate generator pass (**inferred**) |
| C8 | `test*.dds` are blank developer/UV placeholders | DDS header 1024² DXT1/11 mips; converted `test2.png`/`test3.png` viewed | DDS header + PNG view | **REFUTED** | Real gravel/grass-rock soil textures; wrong *role*, not blank |
| C9 | `test*` tiles appear in mine footprints | `game.gd:593` paints role 1; `:1144-1154` picks `test2` 37.5% / `test3` 12.5%; names wired via `presets_summer.json:73-111`, `world.gd:173,702` | Source read | **CONFIRMED (derived)** | ~50% of apron cells; exact count per seed not measured here |
| C10 | Ore-deposit node draws the mine sprite | `world.gd:1663` `_prop_tex(["rock"], n.pos)`, `:1670` | Source read | **REFUTED** | Draws generic `rock.png`; mine sprite only in `_draw_mine()` `:1929-1943` |
| C11 | Built-mine placement/build logic is broken | `t_mine_unified.json` `passed:true` for 12/12 checks incl. gold/iron/coal build | Test result read | **REFUTED** | Simulation correct; rendering is the defect |
| C12 | `tileblocks.json` selects the mine ground tile | 245 entries, no `mine`, no `.gd` load site | JSON parse + repo grep | **REFUTED** | Unwired metadata; do not edit for this fix |
| C13 | A donor screenshot shows the target mine look | `TERRAIN_REFERENCE_IMAGES.md` §1–§7: 12 images, no mine content | Prior doc read | **UNVERIFIED** | No clear mine reference; spec uses donor geometry (§1.2) |
| C14 | Port uses the donor's mine scale correctly | `ENV_SCALE.mine = 0.3152` (`world.gd:149`) matches props | Source read | **PARTIAL** | Scale value correct; jitter (C3) and marker/build height order (§2.1.7) wrong |
| C15 | Donor scar/ground ring is part of `mng/mni/mnc` families | No asset names in patterns; generator uses `plain_*` separately | Prior §2.3 + `dogenerate.inc` | **UNVERIFIED** | Do not claim a specific decal texture |

---

## 4. Machine-readable piece spec (headless renderer)

No donor reference image contains a clear mine (§1.5), so `reference.status`
is **UNVERIFIED** and the anchor is donor asset geometry from §1.1–§1.3.
The `ground1` block is chosen deliberately: it is the role-1 block that is
*not* a `test*` name (`game.gd:1149-1150`).

```json
{
  "name": "mines_display",
  "size_px": [512, 512],
  "seed": 7,
  "layers": [
    {"type": "block", "name": "ground1", "tile": true},
    {"type": "sprite", "name": "mine_gold", "pos": [0.5, 0.5], "scale": 1.0}
  ],
  "reference": {
    "status": "UNVERIFIED",
    "reason": "No donor screenshot in docs/audit/TERRAIN_REFERENCE_IMAGES.md shows a clear mine; geometry anchors are used instead.",
    "geometry_source": {
      "prop": "data/objects/env/minegold.prop",
      "mesh": "data/actors/env/minegold.osm",
      "scale": 0.3152,
      "jitter_min": 1.0,
      "jitter_max": 1.0,
      "converted_obj": "app/assets/models/obj/mine_gold.obj",
      "raw_bounds": {"x": 15.026, "y": 15.822, "z": 1.913},
      "scaled_size_units": {"x": 4.736, "y": 4.987, "z": 0.603},
      "port_tile_m": 2.0,
      "footprint_tiles": {"x": 2.37, "y": 2.49},
      "sprite": "app/assets/models/sprites/mine_gold.png",
      "sprite_px": [160, 160],
      "shared_mesh_sha256_prefix": "A2A6380C7521B941"
    },
    "donor_placement": {
      "families": {"gold": "mng", "iron": "mni", "coal": "mnc"},
      "setup": "data/scripts/common.inc/dogenerate.inc:522-717 SetupMines",
      "attempts_per_ring": 256,
      "pattern_sample": {"name": "mng_1", "w": 8, "h": 10, "occupied": 32, "records": 63},
      "footprint_test": "_misc_CheckStandPatternExt"
    },
    "forbidden_in_footprint": ["test0", "test1", "test2", "test3", "test4", "test5", "test6", "test7", "test8", "test9", "test10", "test11", "test12", "test13", "test14", "test15", "test16", "test17", "test18", "test19", "test20", "test21", "test22", "test23", "test24", "test25"]
  }
}
```

Variant pieces: swap `sprite.name` to `mine_iron` or `mine_coal` (same
geometry, material-only difference); the spec is ore-agnostic in layout.

---

## 5. Acceptance criteria measurable from a 512² PNG

Render the spec with `seed=7`, then measure with Pillow (thresholds are
**derived** from §1.1–§1.4; nothing here requires a donor run):

| # | Criterion | Metric | Target | How to measure |
|---|---|---|---|---|
| A1 | Correct prop silhouette | Non-background connected component in central 50% box, after subtract 8-neighbour tile background; bbox aspect | One component, width/height ratio **0.85–1.15** (near-square mound), area **0.8–3.0%** of frame | Flood-fill / colour-distance from `ground1` tile; report bbox |
| A2 | No `test*` tiles in footprint | Fraction of footprint annulus (centre ±~2.5 tiles scaled to 512²) whose 32×32 patch hash matches any of `blocks/test0..25.png` | **0%** (currently ≈50% by C9) | Tile-patch template match against the 26 converted PNGs at same resize |
| A3 | Ore-type colour present | Count of pixels in component whose hue falls in gold (H≈45–60°), iron (H≈10–25°) or coal (V<0.25, S<0.3) | **≥1%** of component pixels in the expected band for the chosen variant | HSV histogram inside component mask |
| A4 | Ground ring / scar present | Annulus 1.0–2.5 tile radii around prop: mean luminance and saturation vs outer meadow | Annulus mean luminance **lower by ≥8** and sat lower/neutral vs outer ring; no green-disc component | Compare inner vs outer annulus means; check for olive disc pixel family |
| A5 | No baked green disc | Olive-green pixels (H 65–95°, S 0.25–0.7) forming a convex oval ≥40% of component bbox | **absent** (bbox of green pixels < 25% of component bbox) | HSV ovality/bbox test on component |
| A6 | Scale sanity | Sprite height in px vs tile size implied by renderer | Prop bbox height corresponds to **≈2.4–2.5 tiles** (§1.2), not >3 tiles | Compare bbox height to one tile's rendered pitch |
| A7 | Determinism | Two renders with `seed=7` | byte-identical PNG | SHA-256 of both files |

**Gate:** A1, A2, A4 and A7 are hard requirements; A3 must pass for at least
one of the three ore variants; A5/A6 are polish targets. If A2 fails, the fix
in §6.1 has not landed.

---

## 6. Concrete fix proposal (one file per ticket, no donor copy)

### 6.1 Ground selection — eliminate `test*` from the mine apron
**Target:** `app/scripts/game.gd` (one file; `_assign_tileblocks` / mine stamp).

- Give mine aprons their own terrain role instead of reusing role `1`
  (road/dirt that legitimately maps to `test2`/`test3`). Minimal change:
  in `game.gd:593`, paint a distinct role value (e.g. `6 = mine_worked`),
  and add a `match` branch at `game.gd:1143-1179` that selects a
  mine-appropriate block (`ground1` as the canonical neutral soil, or a
  dedicated `ground1`/`grass_ground2` mix) with **zero** `test*` names.
- Alternative minimal patch: keep `terrain=1` but branch on a parallel
  `mine_mask` PackedByteArray populated by `_paint_terrain` at the mine stamp,
  and have `:1144-1154` emit `ground1` wherever `mine_mask[i]` is set. This
  preserves road/dirt behaviour elsewhere byte-for-byte.
- **Acceptance:** A2 = 0%; `test2`/`test3` still reachable for roads and other
  role-1 cells (do **not** delete them from `presets_summer.json`); 29/29
  selftest + 17/17 uitest green.

### 6.2 Ore deposit should draw the mine sprite, not a boulder
**Target:** `app/scripts/world.gd` (one file; case `"gold", "iron", "coal"` at
`:1656-1688`).

- Map `n.type` → `"mine_" + n.type` and call `_sprite_for("mine_" + n.type, -1)`
  (the same path `_draw_mine()` uses at `:1931`). Keep the ground shadow/
  ellipse; drop or heavily reduce the three procedural "ore vein" circles
  (`:1686-1688`) because the sprite already carries ore colour.
- Fold the marker into `_env_sids()` at `:269-281` so the "missing env sid"
  warning at `:326-334` covers it, and stop relying on the incidental
  `Data.BUILDINGS` load at `:299-301`.
- **Acceptance:** A1 + A3 pass; `t_mine_unified.json` still 12/12.

### 6.3 Sprite bake: remove the olive ground disc and fix scale/jitter
**Targets:** `app/tools/render_models.py` / `app/tools/bake_sprites.py`
(re-bake, private-use, source PNG stays out of the repo) **and**
`app/scripts/world.gd:143-158` (one file per ticket).

- Re-bake the three mine sprites with a transparent/alpha-clipped background
  so the donor renderer's green ground polygon is removed (A5). Prefer
  `sprites_hi/mine_*.png` (512²) for parity with other env props.
- Set `ENV_SCALE` mine jitter to `1.0/1.0` (matches `envscales.cfg:16-36`) or
  remove `"mine"` from the jittered kinds; document why stones keep 0.85–1.15.
- Make the deposit marker height ≤ the built-mine height: change `:1670`
  `base = 3.5` to `≤ 3.0` (the `_draw_mine` value at `:1936`).
- **Acceptance:** A5 = absent, A6 within 2.4–2.5 tiles, `envscales.cfg`-
  derived constants cited in a code comment.

### 6.4 Documentation / data hygiene (no code behaviour change)
- Correct `TERRAIN_PORT_ASSETS.md:79` wording: `test0..25` are real donor soil
  textures, not "low semantic value UV plates"; the defect is selection.
- Do **not** edit `tileblocks.json` for this bug (§2.1.4); if anything, retire
  or annotate it as unwired donor metadata in a separate ticket.

### 6.5 Explicitly not in scope
No Godot run, no donor file copy, no edit to `presets_summer.json` (the fix is
the selector, not the table), and no attempt to resolve `.pattern` numeric
record ids (T3 of `TERRAIN_DONOR_PATTERNS.md` owns that; the donor contains no
embedded asset names).

---

## 7. Open questions

1. What exact worked-ground/scar texture does the donor paint under a mine?
   `.pattern` files have no asset names (C7); needs a donor-side correlated
   probe, **not** guesswork from `test*`.
2. Which block should replace `test2`/`test3` in the mine apron — `ground1`
   only, or a two-block soil mix? Donor intent is UNVERIFIED; A2 is the only
   hard gate, A4 should be judged visually once a reference exists.
3. Should the ore-deposit marker be the *small* mine prop (`minegolds` etc.,
   same mesh/scale) rather than the full mine prop? Donor uses small variants
   for some deposits, but which is **UNVERIFIED** from files read here.
4. Is there a donor screenshot with a mine anywhere outside the 12 catalogued
   images? None in this repo's reference set (C13); if the owner has one, the
   `reference` block in §4 should be upgraded from UNVERIFIED.

---

*End of document. No donor asset was copied; all donor paths are private-use
references for existing conversion tooling only.*
