---
id: H02
ticket: "Wave H / H02 — trace every terrain layer in OUR port"
owner: H02 (read-only subagent)
created: 2026-11-25
status: DELIVERED
labels: [OBSERVED, DERIVED, INFERRED, UNVERIFIED]
---

# H02 — Port terrain-layer trace (height / tile id / alpha / albedo)

**Scope.** Read-only trace of every terrain layer in the 3D port, from file load to
GPU consumer. No Godot run, no runner job, no code edit. Charters read first:
`docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md` (Wave H, :106-124) and
`docs/terrain_swarm_2026-11-25/CHARTER.md`. All line numbers are the current tree.

**Evidence labels.** `[O]` OBSERVED (directly read in code/data/PNG header);
`[D]` DERIVED (deterministic consequence of code read); `[I]` INFERRED
(interpretation, not proven by code alone); `[U]` UNVERIFIED (donor engine truth,
GPU appearance, or any claim that needs a captured A/B frame — none exists here).
PNG colour types/dimensions were read from their IHDR chunks with a read-only
Python probe — no runner and no image was written.

---

## 0. Bottom line on the owner's suspicion (short version)

The owner suspects "one of the terrain layers, the one that produces strange
patterns, should not be visible but used for heightmap only."

1. **The true HEIGHT layers in our port are correctly height-only.** The RGB
   terrain-mask PNGs feed `height[]` (`mapgen.gd:212-213`), the donor relief
   grids feed `height[]` (`game.gd:1055`, `:1102`), and `game.height` feeds the
   mesh vertex Y / normals / face gates (`world3d_terrain.gd:1392`, `:1487`,
   `:1413`, `:1423`). **None of them is ever sampled as visible colour in the
   live 3D path.** `[O]` + `[D]`
2. **The layer that IS mask-like AND is drawn as visible colour is the
   `alpha.png` / `alphavert.png` pair.** They are loaded as 8-bit grayscale
   masks, repacked R→A, bound to the shader's `alpha_atlas` / `alphavert_atlas`
   samplers, sampled into `a`, and then at `terrain_tileindex.gdshader:427`
   **multiplied into the albedo RGB** — with `mask_to_alpha` shipped at 1.0 and
   framebuffer `ALPHA = 1.0`. `[O]` This is the only place in the live render
   where a mask-like layer is promoted to visible colour. (Prior report A02
   already classifies this as the mask-driven share of the patterns; this H02
   trace independently confirms the full load→albedo chain.)
3. **Those masks are NOT a height source in our port, and their donor role is
   blend coverage (`bmTransparency`), not height.** So if the owner's hypothesis
   means "the alpha-mask layer should be a heightmap", that is a *role change*,
   not a mis-wiring that can be fixed by moving an existing height layer out of
   the albedo. Donor truth for that re-interpretation is `[U]` here (H01/H03).
4. **The donor detail bitmaps `tile_lowground/highground` are correctly used as
   TILE IDs in our port, not as height and not as direct albedo** (`game.gd:1935`,
   `:1952`). Their R channel is a tile-index encoding (`tex = R*255/2`), not an
   elevation. `[O]` If the owner meant these bitmaps, the port already agrees
   with the donor comment at `game.gd:1904-1907`; any "they should be height"
   reading is a misidentification. `[I]`

Ranked suspect list for H03 to test is in §5.

---

## 1. End-to-end data flow (as implemented)

```
RGB terrain mask PNG (masks/<type>/*_gauss.png)          [mapgen.gd:162,166,180]
  R -> relief() -> height[]                              [mapgen.gd:212-213; :75-85]
  G -> forest[] ; B -> water term ; white -> starts      [mapgen.gd:215,:212,:199-201]
        |
        v
C3MapGen.build() -> game.height                          [game.gd:1141]
  + donor relief grids (8x10 tables) -> height[]          [game.gd:94-123,:1055,:1102]
    (marks _relief_donor_mask :1056)
  + global clamp / dither skip on donor cells             [game.gd:1219-1239,:1222]
  + collision pass -> terrain[]/blocked[]                 [game.gd:1243-1264]
        |
        +-- terrain[] (water/sand/meadow role)            [game.gd:1182-1196]
        +-- tileblock[] (tile IDs; mine_mask override)    [game.gd:1968-2031]
        |     +-- detail bitmaps R/2 -> tileblock         [game.gd:1910-1911,:1935,:1952]
        |     +-- shore/cliff + 3x SmoothTileMap          [game.gd:2033,:2039,:2067]
        |
        v  dump (height + tileblock only)                 [main.gd:795-796]
world3d_terrain.build()                                   [:1301]
  height[] -> vertex Y, normals, face gates               [:1392,:1487,:1413,:1423]
  tileblock[] -> _tile_indices -> UV2.x                   [:1049-1086,:1507]
  atlas colour cells (tile_index_atlas.png)               [tile_atlas_loader.gd:66,:282-285]
  alpha.png / alphavert.png -> R->A repack -> samplers    [:664-672,:694-707,:722-723]
        |
        v terrain_tileindex.gdshader
  UV2.x -> tile_rgb() -> ALBEDO from atlas cell           [:324,:329-337,:392,:472]
  alpha/alphavert .a -> contrast -> FOLDED INTO ALBEDO    [:407,:417,:419,:427]
  framebuffer ALPHA forced to 1.0                        [:475]
```

`[O]` for every arrow above; `[D]` that a layer absent from the dump cannot
reach the 3D renderer (world3d_terrain `_dump_from_game()` copies only `height`
and `tileblock` — `world3d_terrain.gd:1035-1043`; `blocked`, `mine_mask`,
`_relief_donor_mask` and the detail bitmaps are never transported).

---

## 2. Master inventory — every terrain layer, where loaded, what it becomes

| Layer (asset / array) | Loaded at (file:line) | Consumed as | Evidence | Label |
|---|---|---|---|---|
| `game.height` (`PackedFloat32Array`) | `game.gd:44` decl; source `mapgen.gd:212-213`; assigned `game.gd:1141`; reshaped `:1055,:1102,:1175,:1239` | **HEIGHT** (mesh Y, normals, face/shore/cliff gates, water). Never albedo. | `world3d_terrain.gd:1392,:1487,:1413,:1423,:1407,:1561`; `game.gd:2287-2300` (sim `height_at`) | `[O]` |
| `game.blocked` | `game.gd:43`; resized/cleared `:411-418`; set `:547,:1264,:2339` | **OCCUPANCY / NAV** only. Never sent to 3D renderer. | `game.gd:522-525`, `:4734`, `:5957`; `world3d_terrain.gd:1035-1043` omits it | `[O]`+`[D]` |
| `game.tileblock` | `game.gd:53`; built `:1968-2031`; final mine authority `:2074-2076` | **TILE ID** (one uint8 per cell → UV2.x → atlas cell) | `main.gd:796`; `world3d_terrain.gd:1040-1042,:1049-1086,:1507`; shader `:324,:329-337` | `[O]` |
| `game.mine_mask` | `game.gd:57`; mark `:608,:628`; clear `:642`; rebuilt `:1963-1967` | **TILE ID override** (force `ground1`), not rendered directly, not transported to 3D | `game.gd:2029-2030,:2074-2076`; `main.gd:827` (self-base dump only) | `[O]`+`[D]` |
| `game._relief_donor_mask` | `game.gd:73` decl; reset `:949-950`; set `:1056` | **HEIGHT bookkeeping** — skips the 0.03 dither cap on donor-grid cells. Never rendered, never dumped. | `game.gd:1219-1231` (read at `:1222`) | `[O]`+`[D]` |
| RGB mask TGA→PNG (`assets/terrain/masks/**/*_gauss.png`; e.g. `land/4pl_mask_land_0_gauss.png` probed 320×320 RGB) | manifest `masks/manifest.json:1-1247` (note :4 `R=relief, G=forest/stone, B=water, white=start`); loaded `mapgen.gd:36,:162,:166,:180` | **HEIGHT** (R`,:212-213`), forest data (G`,:215`), water (B`,:212`), start markers (white`,:199-201`). **Never albedo.** | PNG header probed on that file: 8-bit colortype 2 (RGB); remaining masks not individually probed | `[O]` |
| `assets/terrain/structs/tile_lowground.png`, `tile_highground.png` (320×320 RGB) | `game.gd:1910-1911` via `_load_image_tex` (`:1894-1901`) | **TILE ID** — `tex = R*255 / 2` (`:1935`), written to `tileblock` (`:1952`); bitmap *choice* by height threshold (`:1930`) | donor comment `:1904-1907,:1914-1915`; PNG header: 8-bit RGB | `[O]` |
| `assets/terrain/atlas/tile_index_atlas.png` (16384×8192 RGBA) | `tile_atlas_loader.gd:66` const, `:282-285` `Image.load`; bound `world3d_terrain.gd:721`; grid from manifest (16×8, 124 named cells) | **DRAWN AS ALBEDO** (the colour cells), sampled by `tile_rgb()` | `terrain_tileindex.gdshader:60,:329-337,:392,:472`; manifest `tile_index_atlas.manifest.json` (`grid 16x8`, `named_cells 124`, `layout[124]`) | `[O]` |
| `assets/terrain/atlas/alpha.png` (512×256 grayscale), `alphavert.png` (1024×512 grayscale) | `tile_atlas_loader.gd:485,:488-494`; repacked R→A `world3d_terrain.gd:664-672,:694-707`; bound `:722-723` | **ALPHA** at sample time (`:407`,`:417`) → **FOLDED INTO ALBEDO** (`:427`) with `mask_to_alpha=1.0` (`:235`); final `ALPHA=1.0` (`:475`) | PNG headers: 8-bit colortype 0 (grayscale) — matches comment `world3d_terrain.gd:668-670` | `[O]`+`[D]` |
| `assets/terrain/heightmap/splat_albedo.png` (1280×1280 RGBA; RGB=blended block albedo, **A=normalised height**) | `world3d_terrain.gd:280` const, `:1360-1363` load; also `heightmap_world3d.gd:39,:174` (prototype) | **DRAWN AS ALBEDO only in the fallback material** (`mat.albedo_texture = splat`, `:759`); height-in-A deliberately ignored (`:761-762`, `heightmap_world3d.gd:57-58`) | `splat_albedo.manifest.json:2-11` (`alpha_mode:"height"`, `A="height = normalised heap height"`, `RGB="blended port block albedo"`) | `[O]` |
| `assets/terrain/patterns/donor_patterns.json` (donor `.pattern` footprint masks + relief ids) | `pattern_gen.gd:58` | **OCCUPANCY/STAMP FOOTPRINT** and relief-grid selection; not albedo | `pattern_gen.gd:4-6,:110-129`; `game.gd:967-1003` (`plt2`/`k_ravine_1`) | `[O]` |
| `assets/terrain/dmask/d_*.png` (64×64 RGBA), `decals_png/*`, `deco_png/envfield*` | `world.gd:735` (2D decals), `world3d_entities.gd:271-272` (field decal), `winter_field_decal.gd:67-68` | **DECALS**, not base terrain layers. `dmask` ramp is a legacy no-op (`world.gd:1045-1048`). | PNG header `d_00.png`: 64×64 RGBA | `[O]` |
| Relief grids (`RELIEF_GRID_*`, `RELIEF_*` const tables) | `game.gd:81-123` (constants, no file load) | **HEIGHT** — added/clamped into `height[]` at `:1055,:1102`; mirrored in `world3d_terrain.gd:231-277` for the opt-in dump path (`:1327-1337`) | labelled PORT APPROX at `game.gd:85-90,:1040-1048` | `[O]` |

---

## 3. Detailed traces (the four consumer roles)

### 3.1 HEIGHT — correct and isolated `[O]`

- Terrain-mask PNGs are picked from `manifest.json` (`mapgen.gd:43-61`) and
  loaded as a `Texture2D` (`mapgen.gd:162-180`). Per map cell the multi-pixel
  average of R/G/B is taken (`:192-210`); `height[i] = C_WATER*(cb/255)*(1+3.5*cr/255) + relief(cr)` (`:212-213`). `relief()` maps only the exact donor codes 255/191, 96/112, 48/88 (`:75-85`). This is a HEIGHT consumer; the PNG is never bound to any material.
- `game.height` is then modified by stamp relief (`game.gd:1055`, `:1102`) and clamped (`:1219-1239`), with `_relief_donor_mask` marking cells that skip the dither cap (`:1222-1231`).
- Transport: `main.gd:795` dumps `height` as base64 float bytes; `world3d_terrain.gd:1310,:1316-1324` decodes them. Mesh usage: vertex Y `:1392`; normals `:1487` via `_normal_at` `:981-1005`; shore gate `:1407`; face promotion `:1413,:1423`; cliff-name gates `:1436`; water build `:1561`.
- Sim usage: `game.gd:2287-2300` (`height_at`), navigation slope check `:4831`.
- **No albedo sampler anywhere reads the terrain-mask PNGs or `game.height`.** `[D]` from the full list of `set_shader_parameter` calls (`world3d_terrain.gd:721-743`) and shader samplers (`terrain_tileindex.gdshader:60,:66,:72,:83`).

### 3.2 TILE ID — correct, drives albedo indirectly `[O]`

- `tileblock` is assigned from `terrain[]` roles (`game.gd:1981-2031`), then shore/cliff (`:2033`), detail bitmaps (`:2039`), decal-worked-ground (`:2051-2063`), 3-pass SmoothTileMap (`:2067`), forest borders (`:2070`), and mine final authority (`:2074-2076`).
- Detail bitmaps: loaded at `:1910-1911`; chosen by `h < 0.1` (`:1930`); `tex = int(im.get_pixel(sx,sy).r*255)/2` (`:1935`); B03 re-rolls only `test7`/`test8` ids (`:1943-1950`); written at `:1952`. **R is a tile-index encoding, not elevation** — donor comment `:1904-1907,:1914-1915`. `[O]`
- Transport: `main.gd:796`; `world3d_terrain.gd:1049-1086`. `uvs2[i] = Vector2(float(tid), float(face))` at `:1507`; shader `v_tile = UV2.x` at `:324`; `tile_rgb()` computes `cell = (mod(idx,cols), floor(idx/cols))` and samples the atlas at `:331-337`. The tile id selects *which* colour cell is drawn; it is not itself colour. `[O]+[D]`

### 3.3 ALPHA — the mask-like layer that becomes visible colour `[O]`

- `tile_atlas_loader.gd:485` names `["alpha.png", "alphavert.png"]`; `_load_image_at` per dir (`:488-492`). Both PNGs are 8-bit grayscale (IHDR colortype 0, probed), matching `world3d_terrain.gd:668-670`.
- `world3d_terrain.gd:664-672`: `get_mask_textures()` → `_repack_mask_alpha(masks[0])`, `(masks[1])`. `_repack_mask_alpha` (`:694-707`) converts to RGBA8 and does `v = pixel.r; set_pixel(..., Color(v,v,v,v))` (`:705-706`) — i.e. grayscale intensity is moved into the **alpha** channel, as the shader reads `.a`.
- Bound at `:722-723`: `alpha_atlas`, `alphavert_atlas`.
- Shader samplers: `alpha_atlas : filter_nearest` (`:66`), `alphavert_atlas : filter_nearest` (`:72`).
- Sampling: face modes 1/2 use `alphavert_atlas` with eye-linear UV (`:404-407`); ground mode uses `alpha_atlas` at `alpha_patch_uv(v_tile, fract(v_alpha_uv))` (`:417`); `:419` contrast-compresses `a` (`a = mix(mix(1.0, clamp(a,0.35,1.0),0.5), 1.0, step(2.5,scol)*step(2.5,srow))`).
- **Promotion to colour:** `terrain_tileindex.gdshader:427` — `rgb = rgb * mix(1.0, a, mask_to_alpha) * v_packed + v_specular;` with `mask_to_alpha` default `1.0` (`:235`) and no `set_shader_parameter("mask_to_alpha", ...)` call in `world3d_terrain.gd:714-753`. At `mask_to_alpha=1` the multiplier is exactly `a`, so mask intensity darkens the albedo. `[O]+[D]`
- Final `ALBEDO = rgb` (`:472`) and `ALPHA = 1.0` (`:475`): the mask never reaches framebuffer transparency. `[O]`
- This is the same chain A02 documented (`A02_alpha_pattern.md:19-20,37-46`); A02-E11 reports no A/B frame exists, so the *causal* claim "this is the visible pattern the owner sees" remains `[U]`.

### 3.4 DRAWN AS ALBEDO — colour cells and the fallback splat `[O]`

- Atlas colour cells: `tile_atlas_loader.gd:282-285` loads `tile_index_atlas.png`; `world3d_terrain.gd:681,:721` binds it; shader samples RGB at `:337` and writes `ALBEDO` at `:472`. Manifest declares 16×8 grid / 124 named cells, each 1024×1024 (e.g. `layout[0] grass1`, `layout[1] grass2`). This is legitimate colour albedo. `[O]`
- `splat_albedo.png`: manifest `splat_albedo.manifest.json:2-11` — `alpha_mode:"height"`, `A="height = normalised heap height"`, `RGB="blended port block albedo"`. Loaded at `world3d_terrain.gd:1359-1365` but used only by `_terrain_material()` (`:756-772`): `mat.albedo_texture = splat` (`:759`), `transparency = TRANSPARENCY_DISABLED` (`:762`) with explicit comment "Splat A is normalised height DATA … never blend it" (`:761`). In the live path the tile-index ShaderMaterial wins (`:1534-1545`), so the splat is not sampled. `[O]+[D]`

### 3.5 Height's *legitimate* colour influence (not a mis-wired layer) `[O]+[D]`

`world3d_terrain.gd:1487` computes vertex normals from `height[]` (`_normal_at`, `:981-1005`). The shader reads `NORMAL` in `vertex()` (`:298`) to build `v_packed = ambient + diffuse` (`:305`), which multiplies albedo at `:427`. So height affects visible brightness through **lighting**, not by being drawn as a texture. This is distinct from §3.3 and should not be mistaken for a heightmap-albedo bug. `[I]`

---

## 4. Places a height-/mask-like layer IS drawn as visible colour (owner's suspicion)

Ranked by how directly the code promotes a non-colour layer into `ALBEDO`:

1. **`alpha.png` / `alphavert.png` blend masks → albedo RGB.** `[O]` chain:
   `tile_atlas_loader.gd:485` → `world3d_terrain.gd:671-672` → `:694-707` → `:722-723` → shader `:407`/`:417` → `:419` → **`:427`** (`rgb *= mix(1,a,1)`). This is a *mask* (donor `bmTransparency` blend coverage, per shader comment `:27-29` and loader comment `:48`) rendered as visible darkening. Strongest match to "a mask-like layer should not be visible". `[D]`
   - *Is it a height source?* **No, in our port.** `[O]` Its only inputs are the mask PNGs; `height[]` never touches `a`. Donor might use `alpha`/`alphavert` for something else, but that is H01/H03 scope `[U]`.
2. **`splat_albedo.png` — a height-carrying texture used as `albedo_texture`.** `[O]` `world3d_terrain.gd:759` + manifest `:2-7`. The RGB part is intentionally blended block albedo, so this is *by design*; the A=height channel is explicitly never blended (`:761-762`). Weak candidate: it is only the fallback material, not the live shader path. `[D]`
3. **`tile_lowground/highground` detail bitmaps feed tile ids, which select albedo cells.** `[O]` `game.gd:1935,:1952` → `world3d_terrain.gd:1507` → shader `:337`. They are not height and not direct colour; indirect albedo selection is their correct role. `[D]`

**Explicitly NOT found:** no code path binds a terrain-mask PNG, `game.height`, `game.blocked`, `game.mine_mask`, `_relief_donor_mask`, or the relief grids as an albedo/emission texture in the live 3D render. `[O]+[D]` — enumerated sampler bindings at `world3d_terrain.gd:721-743` and shader uniforms `:60,:66,:72,:83`.

---

## 5. Handoff to H03/H04/H05 — facts to test the hypothesis against

- **If H03 means "the heightmask layer is visible"**, the code says no:
  `mapgen.gd:212-213` is its only consumer, and no material binds it. `[O]+[D]`
- **If H03 means "the alpha/alphavert mask is visible and should instead be a
  heightmap"**, H02 confirms it *is* visible (`shader:427`) but cannot confirm a
  height role: in our port its source is a grayscale blend mask, not a height
  field. Donor role of `alpha.bmp`/`alphavert.bmp` is cited only as
  `bmTransparency`/face-alpha (`tile_atlas_loader.gd:47-49`, shader `:27-29,:98-118`)
  — engine truth is `[U]`, needs H01.
- **The only existing A/B lever is `mask_to_alpha`** (shader `:235`, contract
  `:483-496`; A02-E10/E11). `0.0` removes the mask from RGB while keeping
  ALPHA=1.0 (`shader:492-496`). No such frame has been captured → `[U]` for any
  visual-causal claim.
- **Do not "fix" by feeding mask intensity into mesh height**: `world3d_terrain.gd`
  has no height input from alpha, and `game.gd` relief stamps already occupy the
  height channel (`:1055,:1102`). Any such change is a new design, not a
  re-wiring of an existing height layer. `[D]`

---

## 6. Unverified / open

- `[U]` Donor truth for the detail bitmaps, alpha/alphavert masks and `.map`
  height bytes — H01's scope; no donor-permission claim made here.
- `[U]` Which layer actually produces the owner-visible patterns. H02 supplies
  the load→consume map only; A02 suspect ranking and H03 decide causality.
- `[U]` Whether `mask_to_alpha=0` improves the frame (no A/B capture; G04 owns
  Godot).
- `[U]` Row-flip / blend semantics of the 8×10 relief grids (`game.gd:91`,
  `:1040-1048`) — labelled PORT APPROX, not donor parity.
- `[O]` PNG IHDR facts (colortypes/dimensions) are from this read-only probe;
  pixel-level mean/entropy of the masks is out of H02 scope (see A02-E4).

*End H02 report.*
