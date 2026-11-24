---
id: TERRAIN2-06
title: "Tile-index architecture — minimal donor-representation port plan for variant3d terrain"
owner: TERRAIN2-06
scope: "AUDIT/DESIGN ONLY. Determine which donor tile-index data and tile/mask assets are already shipped, design the smallest Godot 4 reproduction of the DONOR representation (per-cell integer index, block textures, alpha masks, eye-plane UVs), identify genuine blocks and rank atomic tasks. No source/asset/config/test/git edit."
date: 2026-11-24
status: DESIGN_ONLY__NO_SOURCE_ASSET_GIT_EDITS__NO_GPU_AB
root: "C:\\Users\\Maxym.Oboyshev\\Documents\\Craft Anything\\cossacks-3-3"
donor: "C:\\Games\\Cossacks 3 (READ-ONLY private use; latin-1 text + binary headers only; nothing copied or executed)"
governing_rule: "docs/coord_swarm_2026-11-24/TERRAIN2_CHARTER.md:6-15; docs/coord_swarm_2026-11-24/V73_ATOMIC_CONTRACT.md:3-4,6-16,26-37"
verdict: "CORE REPRESENTATION IS FEASIBLE WITH SHIPPED DATA (per-cell uint8 tile index + donor block PNGs + donor preset/smooth tables + detail bitmaps). Bit-exact donor parity is NOT feasible: face-tile indices never occur in shipped data, gl_EyePlane* and tile->vf/vs promotion are engine-side, and standalone alpha/alphavert PNGs are not shipped. Every such substitution must carry an explicit PORT APPROXIMATION label."
---

# TERRAIN2-06 — tile-index architecture

## 0. Method and labels

- All donor facts below were re-read read-only in this agent: text via `open(...,'rb').read().decode('latin-1')`, 1-based line numbers from `split('\n')`; image dimensions only from BMP/DDS/PNG headers. No donor pixel payload was decoded, viewed or copied; no donor binary executed.
- Port files were read read-only. The only write is this report.
- Labels: **OBS** = literal donor/port text or byte header; **DERIVED** = arithmetic over cited lines; **SHIPPED** = file present in `variant3d/assets` or `app/assets`; **INF** = reasoned reading with caveat; **APPROX** = a port-side substitute that is *not* claimed as donor; **UNVERIFIED** = not provable from readable data.
- Prior reports are cross-checks only, not authority: `TERRAIN2_01_donor_pipeline.md` (representation reversal), `TERRAIN2_02_donor_textures.md`, `TERRAIN2_03_water_weather.md`, `TERRAIN2_04_gap_recipe.md`, `V73_ATOMIC_CONTRACT.md`.

---

## 1. Evidence table — donor fact + already-shipped asset

| # | Donor `path:line` (read-only) | Already-shipped port asset / code | Observation | Class |
|---:|---|---|---|---|
| E01 | `data\scripts\dmscript.global:2026-2035` — `TMapTerrainDataTile = {height:Float, tex:Integer, collision:Integer[4]}`, `tile[640][640]` | `app/shots/g32_dump.json:1` key `tileblock` = base64 **uint8[320×320]**, 31 distinct values 0..85; `variant3d/scripts/game.gd:53` `var tileblock: PackedByteArray`; `variant3d/scripts/main.gd:741` dumps it | **The per-cell integer tile index exists in shipped data** — contrary to the task's example suspicion. It is a `presets_summer.json` index, not a splat weight. | OBS + SHIPPED |
| E02 | `scripts\editor.inc\savemapterraindata.inc:16-17` — `gMapTerrainData.tile[x][y].tex := GetTileIndex(x, y)` | `variant3d/scripts/game.gd:1610-1689` `_assign_tileblocks()` fills the same-shaped buffer; `game.gd:1412-1419` loads the donor tables | Port buffer is a GDScript reconstruction of the donor pipeline; byte-identity to the donor engine buffer is **UNVERIFIED**. | OBS + INF |
| E03 | `data\terrain\tiles\terrain.presets:2-5,6` — `Summer`, `DefaultIndex=0`, first `TileBlock = grass1`; `:133-138` Winter set | `variant3d/assets/terrain/structs/presets_summer.json:2-125` — **124 names**, index 0 = `grass1`, 55/56 = `rock1vf`/`rock1vs`, 95-100 = `sandsea1..6` | Index→name dictionary is already shipped; measured top ids: 14=`grass_ground1` (28,535 cells), 0=`grass1` (15,993), 16=`grass_ground3` (15,962), 79=`test8`, 25=`rock9` (4,135), 24=`rock8` (2,283). | OBS + SHIPPED |
| E04 | `data\terrain\tiles\tiles.lib:119-126` — `rock1vf {AngleX=0, AngleZ=25}`, `rock1vs {AngleX=25, AngleZ=0}`; `:129-136,203-206` repeat; `:209-216` `sand1f/s` same angles | `variant3d/assets/terrain/structs/tileblocks.json:283-296` — `rock1vf anglex 0 / anglez 25`, `rock1vs anglex 25 / anglez 0`; 245 block entries, all 18 rock + 18 sand face variants carry 25° | 25° face metadata is already shipped as data; no new constant is needed. | OBS + SHIPPED |
| E05 | `data\terrain\tiles\tiles.mat:142-148` — `rock1vf`/`rock1vs` both bind `rock1.dds`, refkeys `verticalfront`/`verticalside`; `:1-4` normal refkey binds `grass1.dds` | `variant3d/assets/terrain/blocks/rock1.png`, `grass1.png`, … — **112** PNGs, 110 at 1024²; `sand1.png`/`sand2.png` 256² | Face blocks reuse the *base rock PNG*; there are no `rock1vf.png` files and none are needed. | OBS + SHIPPED |
| E06 | `data\terrain\ref\reftile.mat:120-143` (`verticalfront`: `Texture2Name=alphavert`, `TextureScale=0.125`, `mappingmode=tmmEyeLinear`, S from X, T from Z); `:146-169` (`verticalside`: S from Y, T from Z) | No standalone `alphavert.png` in `variant3d/assets`; `variant3d/assets/terrain/dmask/d_00..23.png` (24 × 64²) are noted as derived from `alpha.bmp`/`alphavert.bmp` at `app/tools/copy_assets.py:221-223`, but no in-repo generator/loader maps atlas cells to tiles | Projected cliff-mask math is readable; a *usable converted mask* is only indirect → one honest conversion atom or an explicitly labelled approximation is required. | OBS + UNVERIFIED |
| E07 | `data\terrain\ref\reftilealpha.mat:30-37` — `alpha.bmp`, `imagealpha=tiaAlphaFromIntensity`, `textureformat=tfAlpha`, `twBoth`, nearest; header `alpha.bmp` = 512×256, 8 bpp | Same indirect `dmask/` situation as E06 | Base-tile blend atlas dimensions/format are readable; no shipped standalone `alpha.png`. | OBS (header) + UNVERIFIED |
| E08 | `data\terrain\ref\reftile.mat:6,17,24-49` — `Texture2Name=alpha`, `BlendingMode=bmTransparency`, `magfilter=maNearest`, `minfilter=miNearestMipmapLinear`, `tfIsotropic`, `twBoth`; `:38-49` S/T mapping coords X=1,Y=0 | None — `variant3d/scripts/world3d_terrain.gd:100-115` uses `TRANSPARENCY_DISABLED` and one RGB albedo | Donor is two-sampler: RGB from tile, alpha from atlas; our material has no second sampler. | OBS vs PORT |
| E09 | `data\scripts\common.inc\loadtextureterrainfrombitmap.inc:4,8-9,26-41` — `cLowHeight=0.1`, `tile_lowground/highground.bmp`, `tex = floor(r*255) div 2`, only where `GetTileIndex=0`; headers 320×320 ×24 bpp | `variant3d/assets/terrain/structs/tile_lowground.png` and `tile_highground.png` — both **320×320**; `variant3d/scripts/game.gd:1571-1605` reconstructs the pass | Detail variation is already folded into the shipped tile index; 3D simply never reads it. | OBS + SHIPPED |
| E10 | `data\gen\tilesmooth_scripts.cfg:1-35` — exact weights `sandsea1..4 = 1`, `sandsea5 = 0.7`, `sandsea6 = 0.3`; `data\scripts\common.inc\smoothtiles.inc:4-7,30-32` loads the cfg and reads `GetTileIndex` | `variant3d/assets/terrain/structs/smooth_summer.json:1` — **10** rules with the same weights; `variant3d/scripts/game.gd:1681-1682` runs 3 passes | Weighted transition table is shipped; 3D does not consume it directly (its effect is baked into `tileblock`). | OBS + SHIPPED |
| E11 | `data\scripts\common.inc\texturemap.inc:426-448` neighbour gradient + `VectorAngle`; `:474-511` 8 sectors `cAngle=45` → `sandsea1/5/6`; `:557-608` collision cells → `rock1/3/4/7`, `Abs(h)>2.7 → rock8`, `>2.4 → rock4`, `<0.1 → none` | `variant3d/scripts/game.gd:1679-1680,1754-1769` reconstructs shore/cliff selection; **no `vf`/`vs` write anywhere in `game.gd`** (only winter aliases at `:1446-1450`) | The 8-sector thresholds are readable, but face-block promotion is not reproduced by the port generator. | OBS + APPROX |
| E12 | `data\shaders\shaders.lib:16-30` — `HeightField` vert `hf.pvl.sm.vert`, frag `hf.pvl.smx3.frag`, `texGen=true`; `hf.pvl.sm.vert:26-33` — `s=dot(realpos,gl_EyePlaneS[0])`, `t=dot(realpos,gl_EyePlaneT[0])`, then `gl_TextureMatrix[0]`; `:9` `realpos = gl_ModelViewMatrix*gl_Vertex` | None — `world3d_terrain.gd:295-318,369` UV = `((x+0.5)/w,(z+0.5)/h)` over the whole map | **Eye-plane projected UVs are the key missing representation**, not just texel density. `gl_EyePlane*` values are engine-bound → APPROX. | OBS + APPROX |
| E13 | `data\shaders\obj\hf.pvl.smx3.frag:13-17` — `color.rgb = texture2D(texUnit0, gl_TexCoord[0].xy).rgb`, `color.a = texture2D(texUnit1, gl_TexCoord[1].xy).a`; vert `:34` `gl_TexCoord[1]=gl_MultiTexCoord1` | `world3d_terrain.gd:100-115` one texture, no alpha sampler | Two-coordinate/two-sampler contract confirmed. | OBS |
| E14 | `data\terrain\ref\reftile.lib:3-12` — `tsDouble`, `ttExtended`, `TileXOffset=0.1`, `TileYOffset=0.2`; commented `TileSize=64, Rows=16, Cols=16, AlphaRows=8, AlphaCols=4`; `data\terrain\tiles\terrain.lib:5-10` `TextureScale=1` | `tileblocks.json` entries use `size 64, rows 1, cols 1`; shipped blocks are 1024² | Atlas packing and sub-tile selection live in the engine (`tsDouble/ttExtended`); pack explicitly and label as port. | OBS + APPROX |
| E15 | `data\terrain\tiles\tiles.lib:53-63` — `sand1/sand2 TileSize=64 Rows=2 Cols=2`; header `sand1.dds` = 256² | `variant3d/assets/terrain/blocks/sand1.png`/`sand2.png` = 256²; all other blocks 1024² | A uniform 1024² texture array/atlas needs an upscale of these two → must be labelled APPROX, not donor. | OBS + SHIPPED |

Cross-check measured with read-only Python over `app/shots/g32_dump.json:1`: `tileblock` = 102,400 bytes, 31 distinct ids, max 85; all ids resolve inside the 124-name `presets_summer.json`. **Zero** ids are face blocks (`rockNvf/vs`, `sandNf/s`): the shipped dump has no cliff-face tile index at all.

---

## 2. Representation comparison

| Aspect | Donor representation (evidence) | `variant3d` today (evidence) | Gap class |
|---|---|---|---|
| Per-cell material | ONE integer `tex` per cell (`dmscript.global:2026-2035`, `savemapterraindata.inc:16-17`) | ONE 320² RGBA `splat_albedo.png`, cell-centre UV, one mean RGB per cell (`world3d_terrain.gd:66-67,100-115,295-318`; `TERRAIN2-02:141`) | **Representation mismatch** — can be closed with shipped data (E01/E03) |
| Tile art | Repeated 1024² DDS blocks, nearest/mipmap-linear, anisotropic (`tiles.mat:1-141`, `reftile.mat:29-37`) | Same 112 PNGs already on disk but unbound by terrain (`TERRAIN2-02:142`) | Art present, binding missing |
| Index origin | Base from `tile_low/highground.bmp` (`r div 2`, `h<0.1`), aspect/shore/cliff overrides, weighted neighbour smoothing (E09-E11) | Port `game.gd:1571-1689` reconstructs it into `game.tileblock`; 3D ignores that buffer (`world3d_terrain.gd:139-172` decodes only `height`) | **Plumbing gap**, not missing data |
| UVs | Eye-plane texgen `dot(eyePos, EyePlaneS/T)` (`shaders.lib:30`, `hf.pvl.sm.vert:26-33`) | 0..1 map UV (`world3d_terrain.gd:317-318,369`) | APPROX needed for plane values |
| Alpha | Second sampler `alpha.bmp` / `alphavert.bmp` via `bmTransparency` (E06-E08, E13) | `TRANSPARENCY_DISABLED`, no second sampler (`world3d_terrain.gd:105`) | Conversion + shader atom needed |
| Cliff faces | `rockNvf/vs` 25° blocks + eye-linear projected mask (E04-E06) | No face ids in dump/generator; no mask PNG shipped | **Genuinely blocked** → `PORT APPROXIMATION` |
| Lighting | Blinn–Phong in vertex, 3-tap PCF in frag (`hf.pvl.sm.vert:17-23`, `hf.pvl.smx3.frag:17-30`) | `StandardMaterial3D` + donor rig (`world3d_terrain.gd:100-115,211-244`) | Out of this lane (TERRAIN2-01 P1 / TERRAIN2-03) |

---

## 3. Smallest donor-grounded implementation design

Design target: reproduce the **representation**, not a fabricated constant set. Four moving parts; each value below either cites a donor line or is explicitly labelled.

### 3.1 Per-cell integer index buffer

- Source of truth at runtime: `game.tileblock` (`variant3d/scripts/game.gd:53,1610-1689`), a `PackedByteArray` with one uint8 per cell; same data is persisted in `app/shots/g32_dump.json:1` key `tileblock` and emitted by `variant3d/scripts/main.gd:741`.
- Decode exactly as `height[]` is decoded today (`world3d_terrain.gd:263-283`), but as bytes; require `size == w*h` (320² = 102,400 for the shipped dump).
- Encode into the existing one-vertex-per-cell mesh via `Mesh.ARRAY_TEX_UV2` with `x = float(tile_id)`, `y = 0`. **APPROX (transport only):** donor has no such vertex attribute; the integer value itself is the donor-derived E01 index and the name mapping is `presets_summer.json:2-125`.
- `world3d_terrain.gd::_dump_from_game()` (`:139-172`) must add `tileblock` to the dict it already forms; otherwise the module cannot see data that `game` already owns (the exact gap in `TERRAIN2-04:38`).

### 3.2 Donor block textures as an atlas

- Build a 2D atlas from `variant3d/assets/terrain/blocks/*.png`: one uniform 1024² cell per preset name used by the index buffer, packed in `presets_summer.json:2-125` order → atlas cell = preset index. No new mapping is invented: `:2` = `grass1` = id 0, `:6` = index 4 = `grass5`, etc. (matches measured dump histogram).
- **APPROX:** `sand1.png`/`sand2.png` are 256² (E15); upscale to 1024² and record it in the manifest. **APPROX:** atlas grid dimensions and cell order — donor `tsDouble`/`ttExtended` packing is engine-side (`reftile.lib:3-12`, UNVERIFIED).
- Filtering: nearest magnification + nearest-mipmap-linear minification + anisotropy, from `reftile.mat:29-37`.
- No donor binary is copied into the repo by the runtime; the atlas is built from already-shipped PNGs.

### 3.3 Alpha masks and cliff faces

- Minimal correct base path: convert donor `alpha.bmp` (512×256 ×8 bpp, `reftilealpha.mat:30-37`) and `alphavert.bmp` (1024×512 ×24 bpp, `:139-146`) to PNG via a build-time tool that reads donor bytes read-only — the same practice already used for the 112 block PNGs. Do **not** guess a cell↔tile mapping: sample the full atlas with donor mapping coords S=X, T=Y (`reftile.mat:38-49`, `reftilealpha.mat:38-49`).
- If donor-file conversion is disallowed in the dispatch environment, the only shipped substitute is `variant3d/assets/terrain/dmask/d_00..23.png` (24 × 64²). Any mapping from those 24 cells to tile ids must be labelled **`PORT APPROXIMATION — NOT DONOR PARITY`** because `copy_assets.py:221-223` only notes provenance and no in-repo loader defines the mapping.
- Face tiles: use `AngleX/AngleZ = 25°` from `tileblocks.json:283-296` / `tiles.lib:119-136` only as *metadata*; art is the base `rockN.png` (`tiles.mat:142-148`). Since the shipped dump/generator has zero face ids, derive a parallel `tile_face_flags` array from the donor aspect/height thresholds (`texturemap.inc:557-608`) and mark it **`PORT APPROXIMATION`** — the engine promotion rule is UNVERIFIED (`TERRAIN2-01:392-393`).

### 3.4 `ShaderMaterial` with eye-plane UVs

- New `shader_type spatial; render_mode blend_mix;` material (replacing `StandardMaterial3D` at `world3d_terrain.gd:100-115` only for the terrain surface).
- Uniforms: tile atlas, alpha atlas, alphavert atlas, atlas grid, `EYE_PLANE_S`, `EYE_PLANE_T`, `FACE_SCALE`.
- Vertex: `eye = VIEW_MATRIX * MODEL_MATRIX * vec4(VERTEX,1.0)` (donor `realpos`, `hf.pvl.sm.vert:9`); `s = dot(eye, EYE_PLANE_S)`, `t = dot(eye, EYE_PLANE_T)`; apply `TextureMatrix[0]` equivalent only if a donor matrix value is ever readable (`:32`) — otherwise identity and labelled APPROX. `v_tile = int(UV2.x + 0.5)`.
- Fragment: RGB = `tile_atlas` at cell `(v_tile % cols, v_tile / cols)` + fract(s,t) — donor `hf.pvl.smx3.frag:13`; alpha = `alpha_atlas` at `fract(s,t)` for base tiles (`:14`, `reftile.mat:6,17,38-49`); for face tiles alpha = `alphavert` at `vec2(eye.x or eye.y, eye.z) * 0.125` — front S=X/T=Z and side S=Y/T=Z from `reftile.mat:120-169`, scale 0.125 from `:124-126,150-152`.
- **`PORT APPROXIMATION` labels required in shader comments:** (a) `EYE_PLANE_S/T` defaults — donor values are engine-bound; (b) repeat period from `fract(s,t)` — donor world-units-per-tile is UNVERIFIED (`terrain.lib:5-10` gives scale 1 but no metres); (c) blend is a single Godot `blend_mix` pass — donor multi-pass `bmTransparency` structure is ENGINE; (d) face promotion from step 3.3.

---

## 4. Ranked atomic tasks (one file per agent; measurable probes)

All modules keep the V73 API (`V73_ATOMIC_CONTRACT.md:6-16`). Runner for every Godot probe: `python variant3d\tools\godot_runner.py run --id v<ID>-... --timeout <s> -- --headless --path variant3d --script res://tests/<name>.gd` (`:37`). `app/` is reference only and stays byte-identical (`:12,21-24`). Test atoms are registered LAST in `variant3d/tests/manifest.json` by its owner (`:26-30`).

| Rank | ID | Single-file owner | Change (donor grounding) | Verification probe | Label |
|---:|---|---|---|---|---|
| P0-1 | **A1** | `variant3d/tools/build_tile_index_atlas.py` (NEW) | Read shipped `presets_summer.json:2-125`, `tileblocks.json:283-296`, `variant3d/assets/terrain/blocks/*.png`; emit `variant3d/assets/terrain/generated/tile_index_atlas.png` + `.manifest.json` with cell=preset index, 1024² cells; optionally convert donor `alpha.bmp`/`alphavert.bmp` to PNG using exact sizes from `reftilealpha.mat:30-37,139-146`. No donor pixel invented. | Python probe prints manifest: `cell_size=[1024,1024]`, `names==124`, every id 0..85 resolvable, `sand1/sand2 upscaled=true`, `alpha=[512,256]`, `alphavert=[1024,512]`, source sha256 list. Nonzero exit if any assertion fails. | Donor-faithful data, APPROX atlas packing + sand upscale |
| P0-2 | **A2** | `variant3d/shaders/terrain_tileindex.gdshader` (NEW) | Spatial shader implementing §3.4: UV2-carried index, donor atlas sampling, donor alpha/alphavert coords, `0.125` face scale (`reftile.mat:124-126`), 25° metadata only from A1 (not hardcoded). Comments cite `shaders.lib:30`, `hf.pvl.sm.vert:26-33`, `hf.pvl.smx3.frag:13-14`, `reftile.mat:120-169`. | Godot probe compiles the shader and asserts `get_shader_uniform_list()` contains tile atlas, alpha atlas, alphavert, atlas grid, eye-plane S/T; grep probe asserts no literal tile-name→id table is embedded. | APPROX for eye planes, repeat period, blend passes |
| P0-3 | **A3** | `variant3d/scripts/world3d_terrain.gd` (EXISTING — sole owner) | Add `tileblock` to `_dump_from_game()`; decode uint8 grid; write `ARRAY_TEX_UV2.x = tile_id`; bind A2 `ShaderMaterial` with A1 textures; keep `bind/build/invalidate/height_at_world` unchanged (`V73:12`). Update `stats` with `tile_index_cells`, `tile_index_hist`, `atlas_path`, `uv_model`, `face_model`. | Headless test builds with shipped dump; asserts `stats.tile_index_cells == 102400`, histogram includes `14:28535`, `0:15993`, `16:15962` (measured E03), all UV2 x in `[0,85]`, surface material is `ShaderMaterial`, and `stats.uv_model` names the eye-plane source. | Donor-faithful index, APPROX shader bindings |
| P1-4 | **A4** | `variant3d/tests/t_tileindex3d.gd` (NEW) | Assert the A1/A2/A3 contract end-to-end: atlas file exists, shader compiles, mesh carries 102,400 indices, no `splat_albedo.png` bound to terrain surface, `build()` still returns true; register in manifest by its owner LAST. | This test file *is* the probe; run via the V73 runner. Report JSON with pass/fail per assertion and the measured histogram. | Verification only |
| P1-5 | **A5** | `variant3d/scripts/game.gd` (EXISTING — sole owner) | Expose parallel `tile_face_flags: PackedByteArray` (0 = none, else face-block preset id) derived from donor aspect/height thresholds `texturemap.inc:557-608`; **do not modify `tileblock`** (preserve shipped dump byte-identity and 2D path). | Godot probe: `flags.size() == MAP_W*MAP_H`, every nonzero value names a `rockNvf/rockNvs/sandNf/sandNs` entry in `presets_summer.json`, and regenerating seed 20261113 leaves `tileblock` byte-identical to `g32_dump.json:1`. | **`PORT APPROXIMATION — NOT DONOR PARITY`** (engine promotion UNVERIFIED) |

Dependencies: A1 → A2 → A3 → A4; A5 is independent and may be dispatched in parallel but consumes A3's stats shape. No two agents touch the same file.

---

## 5. What is genuinely blocked / must be labelled

| Blocker | Evidence | Smallest honest fallback |
|---|---|---|
| No face-tile indices in shipped data | Measured dump: 31 ids, none `vf/vs`; `game.gd` has no face writes (only aliases `:1446-1450`) | A5 parallel flags from donor thresholds, explicitly `PORT APPROXIMATION`; or omit faces entirely in the first merge (simplest) |
| `gl_EyePlaneS/T[0]` values not in readable text | `shaders.lib:30` is only a flag; `hf.pvl.sm.vert:30-32` consumes engine state | Shader uniforms defaulting to identity S/T with `PORT APPROXIMATION` comment; no invented world scale |
| Standalone `alpha.png`/`alphavert.png` not shipped | `reftilealpha.mat:30-37,139-146` gives donor files; only indirect `dmask/d_*.png` (`copy_assets.py:221-223`) | A1 converter from read-only donor BMPs; if disallowed, use `dmask/` with `PORT APPROXIMATION` mapping |
| Donor `tsDouble`/`ttExtended` sub-atlas semantics | `reftile.lib:3-12` (defaults commented), TERRAIN2-02 UNV-5 | Whole-tile-per-cell atlas packing, labelled APPROX; no invented UV offsets |
| `sand1/sand2` 256² in a uniform 1024² array | E15; `tiles.lib:53-63` | Upscale in A1, recorded as APPROX in manifest |
| Donor scripts are commented out | `smoothtiles.inc:4-7`, `loadtextureterrainfrombitmap.inc:4-41`, `texturemap.inc:415-608` all carry `;` script-comment prefixes | Treat as *documented intent*; port reconstruction in `game.gd` is the executable source; never claim donor runtime activity |
| Cell size / world-unit-per-tile | `TILE_M=2.0` is port-only (`world3d_terrain.gd:50`); `terrain.lib:5-10` scale=1 gives no metres | Keep `fract(s,t)` repeat as APPROX; do not re-label it donor |
| No GPU A/B | Charter `TERRAIN2_CHARTER.md:6-15` | All visual claims are predictions; parity remains UNVERIFIED |

---

## 6. UNVERIFIED list (do not guess)

1. **Donor `gl_EyePlaneS/T[0]` and `gl_TextureMatrix[0]` values** — engine-bound; only the flag and shader use are readable (`shaders.lib:30`, `hf.pvl.sm.vert:30-32`).
2. **Engine rule promoting a base tile to `rockNvf/rockNvs` / `sandNf/sandNs`** — no script names those blocks; 25° angles and materials are readable only (E04-E06, `TERRAIN2-01:392-393`).
3. **Byte-identity of `game.tileblock` and the donor `GetTileIndex` buffer** — donor `.map` body was not decoded; only the header is readable (`TERRAIN2-01:405`).
4. **Active execution of the commented `.inc` scripts** — all key lines carry `;` prefixes (E09-E11); data files (`tiles.lib/.mat/.presets`, cfg) are live.
5. **`tsDouble` / `ttExtended` sub-atlas math and alpha-atlas cell↔tile mapping** — `reftile.lib:3-12` commented; `dmask/d_*.png` has no in-repo generator despite `copy_assets.py:221-223`.
6. **Fixed-function `bmTransparency` pass count / blend equation** — `reftile.mat:17` + two samplers are readable; the multi-pass draw is ENGINE (`TERRAIN2-01:394`).
7. **Donor metres-per-cell and UV origin** — `TILE_M=2.0` port-only; `reftile.lib:5-6` offsets 0.1/0.2 are unnamed in world units.
8. **Whether any non-default seed/terrain type produces face ids** — only seed 20261113 ("land", 320²) was measured; face ids absent there.
9. **Standalone converted `alpha.png`/`alphavert.png` provenance** — if produced by A1, they are new port assets derived from donor bytes, not pre-shipped.
10. **Render parity** — no GPU A/B frame; every "expected effect" in this plan is a prediction from static evidence.

---

## 7. Bottom line for the coordinator

- The port already owns the donor representation's *hard part*: a per-cell uint8 tile index (`g32_dump.json:1` / `game.tileblock`), the 124-name index dictionary, the 10 weighted smoothing rules, both 320×320 detail bitmaps, the 25° face metadata, and 112 full-resolution donor block PNGs. The 3D terrain module decodes only `height` and binds one 320² splat — this is a plumbing/shader gap, not missing donor art.
- Dispatch **A1, A2, A3** first (one file each). A true donor-representation port is **feasible with shipped data for the core path**; face tiles, eye-plane constants and standalone alpha masks require the explicit `PORT APPROXIMATION` treatment above, so bit-exact donor parity is **not** claimed.

---

*End of report. Audit/design only: no donor file copied, decoded beyond headers, or executed; no port source, asset, config, test or git state changed by TERRAIN2-06.*
