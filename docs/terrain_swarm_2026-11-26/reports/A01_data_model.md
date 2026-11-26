---
id: A01
ticket: "WAVE A / A01 — donor-faithful terrain DATA MODEL for a fresh variant3d terrain module"
agent: "A01 (read-only design subagent, donor-first swarm 2026-11-26)"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_RUNNER_JOB__NO_GODOT_JOB
scope: "This report is the ONLY repo file written. No source, shader, config, asset, test, JSON, PNG, donor, queue or git edit; no Godot process and no runner job."
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
owner_file: docs/terrain_swarm_2026-11-26/reports/A01_data_model.md
labels: [observed, derived, inferred, UNVERIFIED, "PORT APPROXIMATION"]
parity_claim: false
parity_guard: "No donor GPU A/B frame exists (CHARTER §3/§5). Every field marked DONOR-CONFIRMED is a text/byte/RTTI observation, not a behavioural parity claim. All port-side representation choices are PORT APPROXIMATION. NO DONOR PARITY CLAIM."
target_state: "No D01–D08 report had landed at write time (SWARM_BOARD.md:8-15 all QUEUED). All conclusions derived independently from prior-wave reports and current variant3d source; every item a concurrent worker may overturn is listed in §7 and §8."
sources_read:
  - docs/terrain_swarm_2026-11-26/CHARTER.md
  - docs/terrain_swarm_2026-11-26/SWARM_BOARD.md
  - docs/terrain_swarm_2026-11-25/reports/Z04_height_only_design.md (§5 invariants)
  - docs/decomp/DD_MAPS.md
  - docs/coord_swarm_2026-11-24/reports/TERRAIN2_01_donor_pipeline.md
  - docs/coord_swarm_2026-11-24/reports/TERRAIN2_06_tileindex_architecture.md
  - docs/coord_swarm_2026-11-25/reports/DTRN_01_donor_terrain_pipeline.md
  - docs/coord_swarm_2026-11-25/reports/DTRN_02_donor_terrain_geometry.md
  - docs/coord_swarm_2026-11-25/decomp/DEC_05_terrain_formats.md
  - docs/coord_swarm_2026-11-25/decomp/DEC_01_binaries_rtti.md
  - docs/coord_swarm_2026-11-24/reports/DECOMP_05_static_vs_runtime.md
  - variant3d/scripts/game.gd, world3d_terrain.gd, data.gd, main.gd (read-only trace)
---

# A01 — Donor-faithful terrain data model (fresh variant3d module)

## 0. Executive summary

1. **[O] The donor's authoritative per-cell terrain record has exactly three declared members:** `TMapTerrainDataTile = {height: Float, tex: Integer, collision: Integer[4]}` on a `[640][640]` grid (`data/scripts/dmscript.global:2026-2030`, cited by `DEC_05_terrain_formats.md:411`, `DTRN_02_donor_terrain_geometry.md:191`, `DTRN_01_donor_terrain_pipeline.md:115`). `gc_terraindata_collision = 4` (`dmscript.global:80`, `DTRN_02:190`) and the collision grid is **2× the height grid** (`gc_MaxColMapWidth = 2*640`, `dmscript.global:134-135`; `texturemap.inc:133-134`; `DTRN_02:189,241`). **The new module's core must be a structure-of-arrays holding these three, not a splat or a vertex-colour field** — `[DTRN_01 C1/C8, TERRAIN2_01 §2.2]`.
2. **[O] Grid side is one of 256/320/480/640** from `mapsize` (`miscext2.script:19-26`; `DTRN_02:187`, `TERRAIN2_01:111,299-301`), cap 640 (`dmscript.global:132-133`). Authoring bitmaps are 320²/384² (`TERRAIN2_01:102,303-305`; `DTRN_01 C6`). The port's `MAP_W=MAP_H=160` (`game.gd:35-36`, `data.gd:33`) is **PORT APPROXIMATION** and must be parameterised, not hard-coded.
3. **[O] Row order and cell centres are recoverable:** world origin is `-W/2,-H/2` (`_misc_GetMapLeftTopPos`, `TERRAIN2_01:136-138`), collision drawn at `realx+0.5, realy+0.5` (`TERRAIN2_01:137`; `texturemap.inc:133-134`). The port already implements this exactly: flat index `i = y*W + x` (`game.gd:521`, `world3d_terrain.gd:1309`) and centre vertices `(x+0.5-cx)*TILE_M`, `(z+0.5-cz)*TILE_M` (`world3d_terrain.gd:1310-1312`). **File-row → map-row sign remains `[U]`** (`Z04_height_only_design.md:98,454`).
4. **[D] Five additional per-cell attributes the task names (owner/fog, water flag, forest/stone density, resource id, prop-list ref) are NOT members of `TMapTerrainDataTile`.** They are either derived from other channels (water from height, density from mask G) or belong to separate object/prop tables. This report specifies them as **explicit, labelled side arrays** so the renderer never mistakes them for donor-confirmed cell fields. Donor-confirmed *sources*: mask channels R=terrain class, G=forest, B=water weight, A=road (`generatemap.inc:413-480`, `TERRAIN2_01:304`); second target bitmap R/B → `gMapMask.r/.b` (`generatemap.inc:505-547`, `TERRAIN2_01:305-306`); `TGeneratorBitmapMask = {r,g,b:Float; terrain,water,forest:Integer; bsmooth,broad:Boolean}` (`generatemap.inc:473-480`, `TERRAIN2_01:46`). Water render threshold `-0.25` with shore `-0.1` (`texturemap.inc:29-31`, `DTRN_02:180`). Relief props are **3D objects instantiated by patterns** (`terrainmesh1..4.osm`, `pattern.lib:338482/344362/348758/356906`, `DTRN_02 C8/C9`), not a heightfield bump.
5. **[D] The base64 dump contract can be extended additively without breaking atoms.** Today's dump is `map_w`, `map_h`, `height` (base64 float32-LE) and `tileblock` (base64 uint8) assembled in `_dump_from_game()` (`world3d_terrain.gd:926-963`) and decoded per-cell in `build()` (`world3d_terrain.gd:1229-1243`); `Z04-C` already adds an optional `relief_mask` key with the same recipe (`Z04_height_only_design.md:322-336`). **Rule:** never retype or remove an existing key; new fields arrive under one optional `fields` dictionary; old `build()` ignores it, new `build()` falls back per key.
6. **[D] "Zero-copy" has a hard Godot limit and must be stated honestly.** `PackedFloat32Array`/`PackedByteArray` are copy-on-write containers, and `build()` currently decodes base64 with a per-cell `raw.decode_float(i*4)` loop (`world3d_terrain.gd:1239-1243`). True zero-copy is achievable **only** for the live in-process sim→renderer handoff (typed arrays directly, no base64); the base64 path is a snapshot for determinism/capture and necessarily copies once. UV2 must still be materialised as a `PackedVector2Array` (`world3d_terrain.gd:1293,1297,1407,1425`). **PORT APPROXIMATION** — donor has no such vertex attribute (`V786_tileindex_shader.md:47`, `world3d_terrain.gd:34-35`).

**Verdict for COORD:** adopt the §4 structure-of-arrays container with the three donor-confirmed arrays as the mandatory core; keep all six extra arrays optional and labelled; extend the dump contract additively; do not change any existing gate, shader or `app/` file.

---

## 1. Label key and evidence table

Labels: **[O]** observed (literal code/byte/RTTI/text line) · **[D]** derived (deterministic consequence of cited lines) · **[I]** inference without a pixel-aligned donor A/B · **[U]** UNVERIFIED · **PORT APPROXIMATION** (port-authored representation/selection rule). Donor paths are read-only at `C:\Games\Cossacks 3`; no donor binary was run or copied.

| # | Claim | Evidence (`path:line` / `file:line`) | Label | Consequence for the data model |
|---:|---|---|---|---|
| E1 | Per-cell record `{height:Float, tex:Integer, collision:Integer[4]}` | `data/scripts/dmscript.global:2026-2030` via `docs/coord_swarm_2026-11-25/decomp/DEC_05_terrain_formats.md:411`, `docs/coord_swarm_2026-11-25/reports/DTRN_02_donor_terrain_geometry.md:191`, `DTRN_01:115` | [O] | Mandatory core: one float height, one u8/u16 tile id, four collision tags per cell. No splat weights. |
| E2 | `gc_terraindata_collision = 4`; collision grid = `2*W` | `dmscript.global:80,134-135`; `texturemap.inc:133-134`; `DTRN_02:189-190,241` | [O] | Store collision as either `4*N` tags at height-grid resolution **or** a `(2W)*(2H)` sub-cell mask; record which in metadata (D04 must settle). |
| E3 | Map grid ∈ {256,320,480,640}, cap 640; port is 160 | `miscext2.script:19-26`; `dmscript.global:132-133`; `DTRN_02:187`; `TERRAIN2_01:111,299-301`; `game.gd:35-36`; `data.gd:33` | [O] + PORT APPROX | `W`,`H` are constructor parameters with an explicit allowed set; 160 is a port-only debug size. |
| E4 | Cell centres at `(x+0.5-W/2, z+0.5-H/2)`; flat index `y*W+x` | `TERRAIN2_01:136-138` (E21/E22); `game.gd:521`; `world3d_terrain.gd:1309-1314` | [O] + [D] | Define `cell_center_world()` once; renderer and sim share the same inverse (`world3d_terrain.gd:1720-1726`). |
| E5 | File-row → map-row sign of relief grids | `game.gd:98` ("row sign UNVERIFIED"); `Z04_height_only_design.md:98,454` | [U] | Metadata flag `row_flip="UNVERIFIED"`; never assert orientation. |
| E6 | Source bitmap channels R=terrain class, G=forest, B=water weight, A=road | `generatemap.inc:413-480`; `TERRAIN2_01:304` | [O] | Forest/stone density and water flag are derived side arrays, not core fields. |
| E7 | Target bitmap R/B → `gMapMask.r/.b`; `TGeneratorBitmapMask` struct | `generatemap.inc:473-480,505-547`; `TERRAIN2_01:46,305-306` | [O] | Per-cell float mask channels `r,g,b` survive the generation stage; keep as optional float arrays. |
| E8 | Height formula `h = -1.1*fb*(1+3.5*fr) + {2.964/1.3173/-2.964}*fr` | `generatemap.inc:4-7`; `TERRAIN2_01:119-129`; `game.gd:88-90` | [O] | Height units are donor **class-amplitude units**, not proven metres; store raw float32 as dumped. |
| E9 | Donor height stored as float32 per cell | `dmscript.global:2026-2030`; `DEC_05_terrain_formats.md:487` | [O] | `PackedFloat32Array`, 4 bytes/cell, little-endian in dump (`world3d_terrain.gd:1240`). |
| E10 | Tile index dictionary = 124 ordered names; index 0 `grass1`; water port-only `255` | `terrain/tiles/terrain.presets:2-6`; `DTRN_01 C5`; `game.gd:52` (`BLK_WATER=255`) | [O] + PORT APPROX | `tex` is an integer id in `[0,123]`; `255` is a **port sentinel**, must be flagged as such, not donor. |
| E11 | `tex` written at runtime by `SetTileIndex`, not stored in a donor atlas file | `texturemap.inc:528,608,642`; `DTRN_01 C2`; `TERRAIN2_06:29` | [O] | New module owns tile ids; do not hunt for a donor tile-index texture. |
| E12 | Water classify threshold `-0.25`, shore `-0.1`; generation basin `-1.1` | `texturemap.inc:29-31`; `generatemap.inc:7`; `DTRN_02:180`, `TERRAIN2_01:143-150` | [O] | `water` flag derived from height by an explicit, configurable threshold pair. |
| E13 | Rock/cliff art gated by collision tag + 8-sector gradient; `|h|>2.7→rock8`, `>2.4→rock4`, `<0.1→none` | `texturemap.inc:433-447,557-611`; `DTRN_01 C12/C13`; `DTRN_02:109,186` | [O] | Collision tags are semantic (walkability + art gate), not a single boolean. |
| E14 | `cDiff1/cDiff2 = 0.5/0.55` cardinal/diagonal height-delta gates | `texturemap.inc:63-64`; `DTRN_02:186`; `game.gd` collision pass (via `Z04_height_only_design.md:61,87`) | [O] | Collision tags must be producible from the stored height field; gates are inputs to the fill pass, not stored values. |
| E15 | Relief props are instantiated 3D objects (`terrainmesh1..4.osm`), not height bumps | `pattern.lib:338482/344362/348758/356906`; `actors.lib:1200-1213`; `DTRN_02 C8/C9,276-277` | [O] | `prop_index` is a reference into a separate flat prop list; 0 = none. Never bake prop silhouette into `height`. |
| E16 | Pattern records embed their own `w×h` float32 height grids + scale/min/max | `pattern.lib:549585-549586` (`k_ravine_1`), `:6805-6806` (`plt2`); `game.gd:121-130`; `Z04_height_only_design.md:113-117` | [O] + PORT APPROX | Stamp source tables live in a pattern table, not in the per-cell container; stored height is the post-stamp result. |
| E17 | Donor fog is a shader/palette global, not a per-cell field | `colors.lib:23,34-43`; `DTRN_01 C20`; `TERRAIN2_01:267-289` | [O] | A per-cell `fog` byte in this model is **PORT APPROXIMATION**, never claimed as donor. |
| E18 | Dump schema today: `map_w, map_h, height(base64 f32), tileblock(base64 u8)` | `world3d_terrain.gd:926-963` (`_dump_from_game`), `:1229-1243` (`build`), `:107,110-111` (schema provenance); `TERRAIN2_06:29` | [O] | Extension must be additive; preserve all four keys bit-for-bit. |
| E19 | Optional keys already coexist (`relief_mask` from Z04-C, `relief_stamps`) | `Z04_height_only_design.md:322-336`; `world3d_terrain.gd:1246-1250` | [O] + PORT APPROX | Precedent for a `fields` dictionary; no atom ever consumed these keys. |
| E20 | UV2 transport: `UV2.x = tile id`, `UV2.y = face ∈ {0,1,2}`, atlas `(16,8)` | `world3d_terrain.gd:34-35,1315-1318,1407,1425`; `Z04_height_only_design.md:398-400`; `V786_tileindex_shader.md:47` | [O] + PORT APPROX | Container must expose `tex` as an integer array directly bindable into UV2.x in one pass. |
| E21 | `.map` grid payload is structurally visible but opaque; a 37-byte stride/102,400-record block exists at 320² | `docs/decomp/DD_MAPS.md:48-101,385-399`; `DEC_05_terrain_formats.md:380-399` | [O] + [U] | Do **not** claim the port arrays equal the `.map` payload; D04 owns that decision. |
| E22 | `TMapTerrainDataTile` known only from RTTI/text metadata; no decompiled field offsets | `DEC_01_binaries_rtti.md:113,235`; `DECOMP_05_static_vs_runtime.md:45-53` | [U] | Field *order* and struct stride are UNVERIFIED; SoA order is a port choice. |

---

## 2. What the donor record actually contains — and what it does not

### 2.1 Mandatory core (donor-confirmed)

```
TMapTerrainDataTile            ; data/scripts/dmscript.global:2026-2030  [O]
  height  : Float              ; 4-byte float32 per height cell (E9)
  tex     : Integer            ; one discrete tile id per cell (E1, E11)
  collision : Integer[4]       ; 4 tags per cell (E1, E2); 2x grid (E2)
```

**[D]** These three are the only fields the new module is *required* to hold per cell for donor shape/material/walkability. Any field below this line is a **side channel** introduced by the port or derived from a donor source raster.

### 2.2 Required side arrays (donor-confirmed *source*, port representation)

| Field | Donor source | Donor-confirmed? | Representation |
|---|---|---|---|
| `terrain_class` | source bitmap R (`generatemap.inc:413-480`, `TERRAIN2_01:304`) | source [O]; per-cell stored byte **not** in `TMapTerrainDataTile` → PORT APPROX | `u8` per cell, kept for sim parity with `game.terrain` (`game.gd:42`) |
| `water` | height thresholds `-0.25 / -0.1` (`texturemap.inc:29-31`) | threshold [O]; bool field PORT APPROX | `u8` derived flag; `tex == 255` port sentinel must stay a separate bit |
| `owner` | players/objects; **no per-cell donor field found** | **[U]** | `u8` player index, default 0; D04/D07 to confirm |
| `fog` | shader/palette global (`colors.lib:23`, `DTRN_01 C20`) | **[O] global**, per-cell PORT APPROX | `u8` visibility byte, default 0 (fully visible) |
| `forest_density`, `stone_density` | source bitmap G channel (`generatemap.inc:473-480`, `TERRAIN2_01:46,304`) | source [O]; per-cell density byte PORT APPROX | two `u8` arrays, 0..255 |
| `resource_id` | object table (`res_nodes`, `game.gd:575-584`) | **[U]** as a per-cell field | `u16` per cell, 0 = none; reference into flat resource list |
| `prop_index` | pattern-instantiated `terrainmesh*.osm` (`pattern.lib:338482`, `DTRN_02 C8/C9`) | object [O]; per-cell index PORT APPROX | `u16` per cell, 0 = none; reference into flat prop list |
| `relief_mask` | producer-side provenance (`game.gd:80`; `Z04_height_only_design.md:80`) | PORT APPROX | `u8` per cell; read-only art guard, never enters sim |
| `mask_r/g/b` | `gMapMask` float channels (`generatemap.inc:505-547`, `TERRAIN2_01:46,306`) | source [O]; retention PORT APPROX | optional `f32` ×3 arrays, generation-time only |

**[D] Design decision:** keep the container **struct-of-arrays (SoA)**, not an array of dictionaries. It is the only layout that (a) maps 1:1 onto Godot `Packed*` arrays, (b) allows one-field-at-a-time dump slices, and (c) avoids per-cell object allocation at 640² = 409,600 cells.

---

## 3. Grid dimensions, indices and coordinate conventions

| Item | Value | Evidence / label |
|---|---|---|
| Allowed `W = H` | `256, 320, 480, 640` (cap 640); `160` accepted only as a port debug alias | `miscext2.script:19-26`, `dmscript.global:132-133` [O]; `game.gd:35-36` PORT APPROX |
| Flat index | `i = y*W + x`, `x` fastest, `y` = row (south) | `game.gd:521`, `world3d_terrain.gd:1309-1310` [O] |
| Array length `N` | `W*H` for one-value-per-cell arrays; `4*N` for collision tags; `(2W)*(2H)` if the 2× collision grid is chosen | E2 [D] |
| Cell-centre world X/Z | `((x+0.5) - W*0.5) * TILE_M`, `((y+0.5) - H*0.5) * TILE_M` | `TERRAIN2_01:136-138`, `world3d_terrain.gd:1310-1312` [O]+[D] |
| Cell-centre Y | `height[i] * HEIGHT_SCALE` with `HEIGHT_SCALE = 1.0` | `world3d_terrain.gd:131,1311`; `Z04_height_only_design.md:396` [O] PORT APPROX for scale |
| UV (splat) | `((x+0.5)/W, (y+0.5)/H)` | `world3d_terrain.gd:1313-1314` [O] |
| UV2 | `(float(tex[i]), float(face))`, `face ∈ {0,1,2}` | `world3d_terrain.gd:1315-1318,1407` [O]+PORT APPROX |
| Sub-cell centre (2× collision) | `((cx+0.5)*0.5 - W*0.5)*TILE_M`, `cx ∈ [0,2W)` | E2 + E4 [D] |
| Inverse (world → cell) | `x = clamp(p.x/TILE_M + W*0.5 - 0.5)` | `world3d_terrain.gd:1720-1726` [O] |
| Row sign | file row vs map row | **[U]** `game.gd:98`, `Z04_height_only_design.md:454` |
| Metres per cell | `TILE_M = 2.0` is port-only | `world3d_terrain.gd:130`, `DTRN_01 C6`, `DTRN_02:441-442` PORT APPROX / UNVERIFIED |

**Rules:** (1) every array is indexed by the **same** `i`; (2) `W,H` are stored *in the container*, never read from a global, so a 256² and a 640² dump can coexist in one process; (3) bounds checks use `W,H` from the container, never `Data.MAP_W` (`data.gd:33`).

---

## 4. Design — the container and the Godot typed-array binding

### 4.1 Field table (every field the new module must hold per cell)

| Field | Type | Cells | Bytes at 320² | Godot array | Origin / label |
|---|---|---:|---:|---|---|
| `height` | f32 | 1/cell | 409,600 | `PackedFloat32Array` | donor core [O] E1/E9 |
| `tex` | u8 (0..123, 255 sentinel) | 1/cell | 102,400 | `PackedByteArray` | donor core [O] E10/E11; sentinel PORT APPROX |
| `collision` | u8 tag ×4 | 4/cell | 409,600 | `PackedByteArray` (stride 4) | donor core [O] E1/E2; u8 narrowing **[U]** (D04) |
| `terrain_class` | u8 | 1/cell | 102,400 | `PackedByteArray` | donor mask R [O]; stored byte PORT APPROX |
| `water` | u8 flag | 1/cell | 102,400 | `PackedByteArray` | donor thresholds [O]; flag PORT APPROX |
| `owner` | u8 player | 1/cell | 102,400 | `PackedByteArray` | **[U]** (D04/D07) |
| `fog` | u8 visibility | 1/cell | 102,400 | `PackedByteArray` | global [O]; per-cell PORT APPROX (E17) |
| `forest_density` | u8 | 1/cell | 102,400 | `PackedByteArray` | donor mask G [O]; density byte PORT APPROX |
| `stone_density` | u8 | 1/cell | 102,400 | `PackedByteArray` | donor mask G/rock family [O]/[I]; PORT APPROX (D07/F08) |
| `resource_id` | u16 | 1/cell | 204,800 | `PackedByteArray` (2/cell, LE) | **[U]**; reference into resource list |
| `prop_index` | u16 | 1/cell | 204,800 | `PackedByteArray` (2/cell, LE) | donor prop object [O]; per-cell ref PORT APPROX |
| `relief_mask` | u8 | 1/cell | 102,400 | `PackedByteArray` | PORT APPROX (E19), read-only art guard |
| `mask_r/g/b` | f32 ×3 | 3/cell | 1,228,800 | `PackedFloat32Array` ×3 | generation-time [O] source; retention PORT APPROX |

**Total mandatory resident footprint at 320²** (core + sim side arrays, excluding optional mask channels): **~2.15 MB**. At 640²: **~8.6 MB**. Optional `mask_r/g/b` adds ~4.9 MB at 640² — allocate only if a generation stage requests it.

### 4.2 Zero-copy / typed-array binding

- **Sim → renderer, live in-process (the fast path):** `world3d.gd` binds the container object itself; `build()` reads `C3TerrainData.height` and `.tex` as `Packed*` arrays directly. **No base64, no copy** (Godot CoW only copies if a writer touches the array after binding — enforce "renderer reads only" by contract).
- **Snapshot → renderer (tests, capture, determinism):** base64 decode is a **single unavoidable copy** (`world3d_terrain.gd:1239-1243`). Preserve this path byte-for-byte for atoms.
- **Mesh binding:** `verts`, `norms`, `uvs`, `uvs2`, `inds` are built once per `build()` (`world3d_terrain.gd:1290-1299,1425`). `UV2.x` is a one-pass fill from `tex[]` (`world3d_terrain.gd:1407`); `UV2.y` stays the existing face-mode rule (`:1315-1318`) — **PORT APPROXIMATION**, unchanged here.
- **Normals/water:** `_normal_at()` 1-cell stencil over `height[]` (`world3d_terrain.gd:901-917`) and `bind_height_grid(height, w, h)` (`:1089-1099`) consume the same array; no duplicate height buffer.
- **Collision 2× grid:** if the 640²-cap collision grid is adopted, keep it as a second `PackedByteArray` of `(2W)*(2H)` tagged sub-cells; **do not** reallocate height. Selection between `collision[4]`-per-cell and the 2× grid is a **D04 decision** (§8).

### 4.3 Dump / serialisation contract (extend without breaking atoms)

**Existing schema (must remain byte-identical)** — `_dump_from_game()` at `world3d_terrain.gd:926-963`, decode at `:1229-1243`:

```text
{
  "map_w": int, "map_h": int,
  "height":    base64( float32-LE[N] ),      # Marshalls.raw_to_base64(grid.to_byte_array())
  "tileblock": base64( uint8[N] ),           # optional today; atom-visible
  # optional today: "relief_mask": base64(uint8[N])   (Z04-C)
}
```

**New additive schema (PORT APPROXIMATION transport):**

```text
{
  ... all existing keys unchanged ...,
  "fields": {
     "version": 1,                       # contract version, never interpreted by old atoms
     "labels": "PORT APPROXIMATION",      # no parity claim
     "collision4":     base64( u8[4N] ),  # donor core; stride 4
     "collision2x":    base64( u8[4WH*?] ),# alternative 2x grid — mutually exclusive with collision4
     "terrain_class":  base64( u8[N] ),
     "water":          base64( u8[N] ),
     "owner":          base64( u8[N] ),
     "fog":            base64( u8[N] ),
     "forest_density": base64( u8[N] ),
     "stone_density":  base64( u8[N] ),
     "resource_id":    base64( u8[2N] ),  # u16 LE
     "prop_index":     base64( u8[2N] ),  # u16 LE
     "relief_mask":    base64( u8[N] ),   # alias of top-level key if present
     "mask_r/g/b":     base64( f32[N] ),  # generation-time only, optional
     "props": [ {id:int, family:String, pos:[x,y,z], scale:float, rot:float}, ... ],
     "resources": [ {id:int, type:String, pos:[x,y], hits:int}, ... ]
  }
}
```

**Contract rules [D]:**

1. **Additive only.** No existing key removed, retyped, renamed or reordered. Atoms that read `height`/`tileblock`/`relief_mask` see identical bytes whether or not `fields` is present.
2. **Short array ⇒ all-zero field**, never an error (same tolerance as `_decode_tile_indices`, `world3d_terrain.gd:973-999`). This preserves every stub/dump atom.
3. **`fields` is optional at every level.** A dump with no `fields` key is the current schema; a `fields` dict with no `collision4` means "collision unknown", not "all walkable".
4. **`height` and `tileblock` remain top-level** even when `fields` duplicates them; top-level wins. This is the single source of truth for UV2.x and vertex Y.
5. **Determinism:** `fields` arrays are emitted in a fixed key order; `props`/`resources` are sorted by `id`; base64 uses `Marshalls.raw_to_base64` exactly as `:958,962`. Same seed + same container ⇒ byte-identical dump. `[D]` from E18/E19.
6. **`props` and `resources` are lists, not per-cell structs**, so a cell's `prop_index`/`resource_id` is a stable integer key. [D] from E15 and `game.gd:575-584`.
7. **`version` mismatch** ⇒ ignore `fields` entirely, log diagnostics only; never fail a build. [D] atom-safety requirement.

### 4.4 Concrete GDScript skeleton (DESIGN ONLY — not an edit)

```gdscript
# variant3d/scripts/terrain_donor_data.gd  (PROPOSED — not created by A01)
# Donor core: TMapTerrainDataTile{height, tex, collision[4]}  dmscript.global:2026-2030
# All other fields are labelled PORT APPROXIMATION / derived. NO donor parity claim.
extends RefCounted
class_name C3TerrainData

const ALLOWED_SIZES: Array[int] = [256, 320, 480, 640]
const STRIDE_COLLISION: int = 4
const TILE_SENTINEL_WATER: int = 255   # PORT ONLY (game.gd:52), not donor

var w: int = 0
var h: int = 0
var n: int = 0

# --- donor-confirmed core (SoA) ---
var height: PackedFloat32Array = PackedFloat32Array()   # f32 per cell
var tex: PackedByteArray = PackedByteArray()            # u8 id, 255 = water sentinel
var collision4: PackedByteArray = PackedByteArray()     # u8[4] per cell

# --- derived / PORT APPROX side arrays ---
var terrain_class: PackedByteArray = PackedByteArray()  # donor mask R source
var water: PackedByteArray = PackedByteArray()          # derived from height thresholds
var owner: PackedByteArray = PackedByteArray()          # UNVERIFIED donor per-cell
var fog: PackedByteArray = PackedByteArray()            # PORT APPROX (donor fog is global)
var forest_density: PackedByteArray = PackedByteArray()
var stone_density: PackedByteArray = PackedByteArray()
var resource_id: PackedByteArray = PackedByteArray()    # u16 LE, 0 = none
var prop_index: PackedByteArray = PackedByteArray()      # u16 LE, 0 = none
var relief_mask: PackedByteArray = PackedByteArray()    # producer provenance, read-only

# --- generation-time only, optional ---
var mask_r: PackedFloat32Array = PackedFloat32Array()
var mask_g: PackedFloat32Array = PackedFloat32Array()
var mask_b: PackedFloat32Array = PackedFloat32Array()

# --- external tables referenced by u16 ids ---
var props: Array[Dictionary] = []
var resources: Array[Dictionary] = []

var meta: Dictionary = {}   # row_flip:"UNVERIFIED", metres_per_cell:"PORT APPROX", field_labels

func _init(width: int, height_cells: int) -> void:
    assert(ALLOWED_SIZES.has(width) and width == height_cells,
        "C3TerrainData: donor grid sizes are 256/320/480/640 only")
    w = width
    h = height_cells
    n = w * h
    height.resize(n)
    tex.resize(n)
    collision4.resize(n * STRIDE_COLLISION)
    for a in [terrain_class, water, owner, fog, forest_density,
              stone_density, resource_id, prop_index, relief_mask]:
        (a as PackedByteArray).resize(n)
    resource_id.resize(n * 2)   # u16 LE
    prop_index.resize(n * 2)    # u16 LE
    meta = {"row_flip": "UNVERIFIED", "tile_m": "PORT APPROX 2.0",
            "labels": "PORT APPROXIMATION — no donor parity claim"}

func idx(x: int, y: int) -> int:
    return y * w + x

func cell_center_world(x: int, y: int, tile_m: float) -> Vector3:
    return Vector3((float(x) + 0.5 - float(w) * 0.5) * tile_m,
        height[idx(x, y)],
        (float(y) + 0.5 - float(h) * 0.5) * tile_m)

func get_collision(i: int, tag: int) -> int:
    return collision4[i * STRIDE_COLLISION + tag]

func set_collision(i: int, tag: int, value: int) -> void:
    collision4[i * STRIDE_COLLISION + tag] = value

func get_u16(a: PackedByteArray, i: int) -> int:
    return int(a[i * 2]) | (int(a[i * 2 + 1]) << 8)

func set_u16(a: PackedByteArray, i: int, v: int) -> void:
    a[i * 2] = v & 0xFF
    a[i * 2 + 1] = (v >> 8) & 0xFF

func derive_water(deep: float, shore: float) -> void:
    # donor classify thresholds texturemap.inc:29-31 — thresholds [O], flag PORT APPROX
    for i in range(n):
        water[i] = 1 if height[i] < deep else (2 if height[i] < shore else 0)

# --- dump: additive; never mutates the four atom-visible keys (world3d_terrain.gd:926-963) ---
func to_fields_dump() -> Dictionary:
    return {
        "version": 1,
        "labels": "PORT APPROXIMATION",
        "collision4": Marshalls.raw_to_base64(collision4),
        "terrain_class": Marshalls.raw_to_base64(terrain_class),
        "water": Marshalls.raw_to_base64(water),
        "owner": Marshalls.raw_to_base64(owner),
        "fog": Marshalls.raw_to_base64(fog),
        "forest_density": Marshalls.raw_to_base64(forest_density),
        "stone_density": Marshalls.raw_to_base64(stone_density),
        "resource_id": Marshalls.raw_to_base64(resource_id),
        "prop_index": Marshalls.raw_to_base64(prop_index),
        "relief_mask": Marshalls.raw_to_base64(relief_mask),
        "props": props.duplicate(true),
        "resources": resources.duplicate(true),
    }

func load_fields_dump(f: Dictionary) -> void:
    # Missing / short array => zero-filled field; never an error (atom safety).
    for key in ["collision4", "terrain_class", "water", "owner", "fog",
                "forest_density", "stone_density", "resource_id",
                "prop_index", "relief_mask"]:
        if not f.has(key):
            continue
        var raw := Marshalls.base64_to_raw(str(f[key]))
        var dst: PackedByteArray = get(key)
        var need: int = dst.size()
        for i in range(mini(raw.size(), need)):
            dst[i] = raw[i]
    if f.has("props") and f["props"] is Array:
        props = (f["props"] as Array).duplicate(true)
    if f.has("resources") and f["resources"] is Array:
        resources = (f["resources"] as Array).duplicate(true)
```

**Binding snippet (proposed, in the new renderer):**

```gdscript
# var data: C3TerrainData = game.terrain_data
# verts[i].y = data.height[i] * HEIGHT_SCALE                  # world3d_terrain.gd:1311
# uvs2[i]  = Vector2(float(data.tex[i]), float(face))          # :1407
# _normal_at(data.height, data.w, data.h, z, x)                # :901-917
# water3d.bind_height_grid(data.height, data.w, data.h)        # :1099
```

---

## 5. Implications

1. **Sim and renderer consume one container.** `game.gd`'s `terrain`/`height`/`tileblock`/`blocked` (`game.gd:42-44,53`) become views/aliases into `C3TerrainData`, so a producer stamp writes exactly one array. This preserves Z04 §5 invariants (one surface, `w*h` vertices, UV2 integral ids, one water plane) by construction.
2. **No field may feed back into albedo.** `height` drives mesh Y/normals/water only (`Z04_height_only_design.md:398-405`); `tex` drives UV2.x; `relief_mask` is a read-only art guard (`:397`, `:124`). Introducing a height→tile-art path would recreate the maze (Y02 root cause, cited at `Z04:70`).
3. **Water/forest/stone/resource are downstream, never core.** Adding them as core per-cell fields would falsely imply donor storage; keep them side arrays with explicit labels so a later D07/F08 finding can replace them without touching the mesh path.
4. **Grid parameterisation is mandatory for the charter gates.** Charter §6(3) requires both 240² and 320² maps; donor sizes include 256/320/480/640 (`CHARTER.md:122`, `miscext2.script:19-26`). The container's `w/h` are per-instance; the 160 port default is a debug alias, not a donor value.
5. **Determinism contract:** same seed + same `W,H` ⇒ identical `height/tex/collision4/…` and identical base64. The container never uses RNG; RNG stays in `game.gd`/`gen_rng` (`game.gd:144-151`) and D02 owns that contract.
6. **QA hook:** `stats` can report `grid`, field sizes and a hash per array without changing any existing atom key (precedent `Z04_height_only_design.md:445`, R8 additive-only).

---

## 6. Migration plan from `height[]` / `tileblock[]` / `blocked[]`

**[D] Staged, additive, reversible — no gate weakening at any step.**

| Phase | Action | Compatibility | Rollback |
|---:|---|---|---|
| 0 | Add `terrain_donor_data.gd` (skeleton §4.4) as a new file; no consumer yet. | Zero behavioural delta; gates unchanged. | Delete the new file. |
| 1 | In `game.gd`, allocate `var terrain_data := C3TerrainData.new(MAP_W, MAP_H)` alongside existing arrays. In `_reset()`/`setup()` (`game.gd:412-424`), mirror `height[]`→`data.height`, `tileblock`→`data.tex`, `blocked`→`data.collision4[tag0]` (tag0 = walkability bit). Keep old arrays authoritative. | Both representations byte-identical; `is_blocked()` (`game.gd:529-532`) untouched. | Remove the mirror. |
| 2 | Change producers to write **both** old arrays and `data` via tiny setters (e.g. `set_height(i,v)`, `set_tex(i,id)`, `set_blocked(i,v)`). No RNG draw changes (`Z04:100`). | Single source of truth starts to shift; dump bytes must remain identical — assert hash equality in a temporary test. | Revert producer lines. |
| 3 | In `world3d_terrain.gd`, add an optional live handoff: if `_game.terrain_data` exists and `w/h` match, read `data.height`/`data.tex` directly; otherwise keep the current base64 path (`:926-963,1229-1243`) verbatim. | Atoms using explicit dumps see unchanged bytes; live path is PORT APPROX. | Flip the handoff flag off. |
| 4 | Extend dump with `fields` (§4.3) only in `game.gd`'s dump producer; `build()` ignores unknown keys. | Atoms byte-identical; `fields` absent for old callers. | Remove the `fields` key. |
| 5 | Once A02–A06 land and A/B gates are green, make `C3TerrainData` authoritative and turn `height`/`tileblock`/`blocked` into read-only aliases (or delete them after COORD approval). | Requires a fresh capture + all gates (`CHARTER.md:63-64`). | Restore backups; COORD-owned. |

**Invariants to assert at every phase** (from `Z04:391-406`): surfaces `1`; vertices `w*h`; triangles `(w-1)(h-1)*2`; vertex Y `height[i]*1.0`; normals from the same `height[]` via 1-cell stencil; UV2.x integral `[0,123]`, UV2.y `{0,1,2}`; atlas `(16,8)`, 3 samplers; one water plane via `bind_height_grid()`; `blocked[]` semantics unchanged (`set_blocked_tile()` called on every steep cell); `app/**` byte-untouched.

**Do NOT during migration:** rename/retype a dump key, add a `HEIGHT_SCALE` multiplier, promote cliff art on relief cells (the Z04-C guard is the opposite), add dither/noise (`CHARTER.md:83`, S-25-09), or claim parity.

---

## 7. Risks

| # | Risk | Severity | Mitigation |
|---:|---|---|---|
| R1 | `collision[4]` narrowed from donor `Integer` to `u8`; real tag range unknown | medium-high | Keep raw dump as `u8[4N]` but store metadata `collision_width:"UNVERIFIED"`; D04 must confirm tag values before any narrowing is treated as donor-faithful. |
| R2 | D04 may find the 37-byte `.map` record block is the authoritative tile buffer, not the runtime `tex` | high | Core `tex` stays driven by `SetTileIndex` (`DTRN_01 C2`); treat `.map` block as a **separate** cache until D04 proves otherwise (`DD_MAPS.md:395-399`). |
| R3 | "Zero-copy" overclaimed | medium | §4.2 states the single-copy base64 limit explicitly; no parity claim. |
| R4 | Per-cell `owner`/`fog`/`resource_id`/`prop_index` invented as donor fields | high (epistemic) | All four are labelled PORT APPROX/[U] in §2.2 and §4.1; D04/D07/F08 must confirm or replace. |
| R5 | 640² container (409,600 cells, ~8.6 MB core + 4.9 MB optional) stresses Godot streaming | medium | Allocate `mask_r/g/b` only on demand; use one surface; profile at 640² before enabling. |
| R6 | Row-sign error flips relief/masks | medium | `meta.row_flip = "UNVERIFIED"`; D03/D05 must supply the orientation; no visual claim until capture. |
| R7 | Adding `fields` changes dict shape consumed by a test atom | low | Additive-only rule §4.3(1-3); run selftest 29/29, uitest 17/17, `t_render_mode`, `assert_clean` (unchanged thresholds, `CHARTER.md:63`). |
| R8 | Concurrent D04 report lands with a different field order/stride | medium | §8 lists the exact deltas; COORD integrates; no worker edits this report. |
| R9 | `TILE_M = 2.0` treated as donor metres | medium | Labelled PORT APPROX (`DTRN_01 C6`, `DTRN_02:441-442`); keep as tunable. |

---

## 8. What D01–D08 must confirm or correct (explicit hand-off list)

| Worker | Must confirm / correct for this data model |
|---|---|
| **D01** (RTTI→functions) | Whether `XTerrainDataLite`/`XTile` allocate a single `[640][640]` record array or separate planes; concrete field offsets/stride for `height/tex/collision[4]` (`DEC_01:235`, `DECOMP_05:45-53`). Correct §4.1 field order/stride if a real struct layout is recovered. |
| **D02** (seed/RNG) | Confirm the container holds **no** RNG state; if donor stores a per-cell seed byte (cf. `DEC_05_terrain_formats.md:382` "per-cell byte field … UNVERIFIED"), specify it as a new side array. |
| **D03** (mask pipeline) | Confirm channel map R=terrain/G=forest/B=water/A=road (`TERRAIN2_01:304`) and whether `gMapMask.r/g/b` survive into the stored tile; fix `meta.row_flip` and the float-normalisation of `mask_r/g/b`. |
| **D04** (`.map`/`TTile`) | **Highest impact.** (a) exact record stride and field offsets; (b) whether `collision[4]` is stored per height cell or on the 2× grid; (c) tag value range (u8 sufficient?); (d) real tile-id width (u8 vs int); (e) whether any `owner` field exists; (f) whether the 37-byte/102,400-record block (`DEC_05:385-399`, `DD_MAPS.md:385-399`) is authoritative or a cache. Correct §2.1/§4.1 if any differs. |
| **D05** (relief stamp) | Confirm height float32 units and scale clamp order; whether stamped height is stored raw or quantised; whether `mask_r/g/b` must be retained post-stamp. |
| **D06** (water/shore) | Confirm `deep=-0.25`/`shore=-0.1` (`texturemap.inc:29-31`) vs generation basin `-1.1` (`generatemap.inc:7`); specify the exact `water` flag derivation and whether a separate `fog`/visibility byte exists in donor. |
| **D07** (resources) | Confirm whether `resource_id` and `stone_density` are per-cell stored or pattern/object-table only; supply the id namespace and the deposit-amount field for the `resources[]` list. |
| **D08** (tile select) | Confirm `tex` id range `[0,123]` + port sentinel `255` (`DTRN_01 C5`, `game.gd:52`); whether face mode belongs in `tex` high bits or a separate byte; whether `UV2.y` face can be derived from stored data (today PORT APPROX, `world3d_terrain.gd:1315-1318`). |

---

## 9. UNVERIFIED register (must not be promoted to "confirmed")

1. **No donor GPU A/B frame exists** — every visual expectation is [I]/[U]; no parity claim (`CHARTER.md:41,72,126`; `Z04:452`).
2. `TMapTerrainDataTile` field **order/stride** — RTTI/text only (`DEC_01:235`, `DECOMP_05:45-53`) → **[U]**.
3. `collision[4]` tag **value range** and whether u8 narrowing is safe → **[U]** (`dmscript.global:80` only gives count).
4. Whether donor stores **per-cell owner** at all → **[U]** (no field found; D04).
5. Whether **fog** is per-cell → **[O] global** (`colors.lib:23`, `DTRN_01 C20`); per-cell byte is PORT APPROX.
6. Whether **resource id / prop index** are per-cell stored → **[U]**; donor uses object/pattern tables (`DTRN_02 C8/C9`, `game.gd:575-584`).
7. **File-row → map-row sign** of relief/mask grids → **[U]** (`game.gd:98`, `Z04:454`).
8. **Donor metres per cell / height unit** → **[U]** (`DTRN_01 C6`, `DTRN_02:441-442`); `TILE_M=2.0`, `HEIGHT_SCALE=1.0` are PORT APPROX.
9. Whether the `.map` 37-byte/102,400-record block is the authoritative tile buffer → **[U]** (`DD_MAPS.md:395-399`, `DEC_05:395-399`).
10. Engine-side **2× collision grid consumption** → **[U]** (`DTRN_02:447-448`).
11. D01–D08 reports had **not landed** at write time (`SWARM_BOARD.md:8-15`); all their findings may override this model.
12. `main.gd` dump-schema line references have **drifted** (provenance cited at `world3d_terrain.gd:107,110-111` as `main.gd:694-701,741`; the current file's those lines hold unrelated code) — cite by context, not by number; the schema itself is observed in `_dump_from_game()` (`world3d_terrain.gd:926-963`).

---

## 10. Open questions

1. Does COORD want `collision4`-per-cell or the donor's 2× collision grid as the **primary** representation, with the other derived? (D04 blocks this.)
2. Should `tex` be `u8` (124 ids + 255 sentinel) or `u16` to leave room for DLC tile families (F10)? Port sentinel 255 is documented as port-only (`game.gd:52`).
3. Are `mask_r/g/b` generation-time scratch only, or must they be retained for shore/field A/B (D03/D06)?
4. What is the `resources[]`/`props[]` id namespace and how do the 2-byte per-cell indices survive map reload? (D07/F07/F08.)
5. Should `water` be a tri-state (deep/shore/land, as §4.4 `derive_water()` proposes) or a single bit? Donor has two thresholds (`texturemap.inc:29-31`), so tri-state is the [D] choice — D06 to confirm.
6. Does the fresh module take `C3TerrainData` from `game.gd` directly (§5) or through a dump-only boundary? The latter is atom-safer but forfeits true zero-copy.
7. At 640², should the container be chunked/LOD'd? Donor surface LOD is UNVERIFIED (`DTRN_02 C19,440`).

---

*End of A01. One report written. No code, shader, asset, config, test, git, Godot or runner state changed. Donor-confirmed fields are limited to E1–E4/E6–E16; all port representation choices are labelled PORT APPROXIMATION. NO donor parity claim.*
