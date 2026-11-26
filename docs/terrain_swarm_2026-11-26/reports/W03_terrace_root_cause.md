---
id: W03
ticket: "TERRAIN-SWARM-2026-11-26 / donor-terrain VISUAL WAVE"
agent: "worker W03, reporting to COORD"
date: 2026-11-26
status: DELIVERED__READ_ONLY__ONE_REPORT__NO_CODE_EDIT__NO_GODOT_JOB
owner_file: docs/terrain_swarm_2026-11-26/reports/W03_terrace_root_cause.md
files_created: [docs/terrain_swarm_2026-11-26/reports/W03_terrace_root_cause.md]
files_edited: []
labels: [O, D, I, U, "PORT APPROXIMATION"]
parity_claim: false
parity_status: UNVERIFIED
parity_guard: "No donor GPU A/B frame exists. This is a source/numeric/image audit, not a donor-fidelity or parity claim."
scope_guard: "Donor files at C:\\Games\\Cossacks 3 were opened read-only only. No donor binary was executed; no Godot job, source edit, asset edit, config edit, test, gate, or git operation was run. Exactly one repository file was written: this report."
---

# W03 — terrace/step root cause in `cap_donor_240c.png`

## 0. Executive verdict

**[D]/[I] The capture is a compound failure, not one quantized relief grid.**

1. **PASS — hypothesis (b), wrong mask and wrong grid size.** The live selector chooses a **320×320 DLC5 Mediterranean 4-player mask** for a **240×240, 2-player** run, then overwrites I07's requested grid with the mask's native 320×320 size. The selected mask is a large water ring with all 256 B values. This is the source of the new non-flat silhouette in `cap_donor_240c.png` relative to flat `cap_donor_240b.png`.
2. **PASS — hypothesis (f), shader repeat/fract bands.** I10 repeats the tile art every **2 m in eye space** and applies `fract()` again in the fragment shader. One repeat is exactly one 2 m mesh cell. The capture has perspective-spaced horizontal edges at y=110,141,173,206,241,279,319 with spacings 31,32,33,35,38,40 px, consistent with a repeated cell-sized texture lattice. Alpha is not the cause: land tile 0 samples the constant-255 alpha patch.
3. **PASS — hypothesis (e), but only as an amplifier.** I08 derives normals from a one-cell forward difference and I10 applies Blinn-Phong lighting. The selected mask's final replay has maximum slope 0.30314 (16.86° normal tilt), enough to accentuate coastline/relief steps, but 64.01% of cells remain exactly flat. Normals do not create the map-wide lattice.
4. **FAIL — hypotheses (a), (c), (d), and (g) as stated.** The `-1.1*v/255` conversion is present; corrected full pattern grids are loaded but **no relief-family pattern is ever placed**; mask decode does no bilinear/nearest resampling; the tile atlas is linear-mipmap-anisotropic and CPU mipmaps are explicitly generated.
5. **Critical separate defect:** `_setup_patterns_by_type()` only draws names and increments counters. It never chooses a position, checks stand, or calls `_stamp_pattern()`. Therefore the donor relief grids cannot be the source of the capture's hills/terraces—and the current donor backend also has no real relief-family hills at all.

**Root-cause statement:** the stepped silhouette comes from the **wrong I17 mask/grid selection (b)**; the regular diagonal/terrace-looking surface bands come from **I10 eye-plane `uv_repeat` + `fract()` (f)**, made more conspicuous by **height-derived normals/lighting (e)**. Pattern offset/scale/sampling and atlas mip absence are not the cause.

---

## 1. Scope, sources, and multiple-pass register

Read in full: `VISUAL_WAVE_CHARTER.md`; `spec/03_MASK_TO_HEIGHT.md`, `04_PATTERN_STAMPING.md`, `05_WATER_SHORE.md`, `06_TILE_AND_ATLAS.md`; the four mandated reports; current `terrain_donor_inputs.gd`, `terrain_donor_gen.gd`, `terrain_donor_data.gd`, `terrain_donor_mesh.gd`, and `terrain_donor_shader.gdshader`. Also read the live composer, config, atlas loader, selected assets, and the donor text/TGA paths cited below.

| Pass | Instrument | Contradiction resolved / result |
|---|---|---|
| P1 | Sequential source read + targeted call-site grep | `_stamp_pattern()` has only three call sites: base tiles, mines, and starting resources. Neither relief nor forest/stone family setup calls it. |
| P2 | Config-default/merge replay | The map JSON says `map_type=land`, but `DEFAULT.gameplay.terrain_type=mediterranean` survives the key-by-key merge. `_shape_of()` checks `terrain_type` first, so the effective I17 shape is **mediterranean**, not land. No `options.json` was found in the Godot user-data roots. |
| P3 | Two independent selector replays (JSON sort/FNV-1a and direct candidate enumeration) | 446 Mediterranean candidates; 0 native 240²; FNV-1a(`20261113|mediterranean`) = `0x0DB22056` = 229777494; 229777494 mod 446 = **78**; selected DLC5 `4pl_mask_mediterranean_29_gauss`. |
| P4 | Donor TGA decode vs derived PNG | Selected donor TGA is 320×320, descriptor 0, B=0..255, four white starts; derived gray8 PNG is pixel-identical after start zeroing (0 differing pixels). Donor files were read only. |
| P5 | Two independent f32 smoothing replays (NumPy grid and flat-list scalar loop) | Same final min/max, unique count, zero count, and deciles. This is a source-derived numeric replay, not runtime telemetry. |
| P6 | Shader/atlas/alpha audit + capture pixel metrics | Tile 0 alpha patch is constant 255; shader repeat period is 2 m; capture row-edge spacings match a perspective cell lattice. Historical “mipmap absence” comments were not treated as current state. |
| P7 | Current-source re-read against V58 | V58's line numbers and some defaults are stale. Current `terrain_donor_gen.gd:229-235` contains all five corrected offsets, and `:260` defaults to `f32_each_op`. This report uses current lines only. |

No strange metric was accepted on one pass. The initial “land mask” reading from the map JSON was rejected after P2/P3; the mip-absence hypothesis was rejected after P6/P7.

---

## 2. Exact live path, with file:line at every stage

### 2.1 Seed and effective shape

1. Capture config requests 240×240, seed 20261113, and `gameplay.map_type="land"`: `%TEMP%\opencode\v42\map_donor_240.json:78-83,113`.
2. Built-in defaults contain `map_type="mediterranean"` and `terrain_type="mediterranean"`: `variant3d/scripts/config.gd:117-127`. Config loading copies defaults and merges dictionaries key-by-key: `config.gd:275-304,378-386`. Because the capture JSON does not contain `terrain_type`, the default remains.
3. I17 `_shape_of()` checks game `terrain_type` before config `map_type`: `variant3d/scripts/terrain_donor_inputs.gd:155-168`. It therefore reads config `gameplay.terrain_type` at `:161-164`, yielding **`mediterranean`**.
4. I17 `_derive_seed()` reads `gameplay.random_seed`: `terrain_donor_inputs.gd:112-149`; seed = **20261113**, `randkey0=0`, `randkey1=20261113`.

### 2.2 I17 mask selection and gray8 decode

5. `_select_mask()` gathers every tree whose entry `shape` matches, sorts by `type|file`, prefers an exact requested-size mask, otherwise uses all candidates, then picks with FNV-1a: `terrain_donor_inputs.gd:180-222`.
6. Selected result: candidate index **78/446**, file `height/dlc5/mediterranean/4pl_mask_mediterranean_29_gauss.height.png`; the index entry records shape/tree/320×320 at `variant3d/assets/terrain_new/masks/mask_index.json:131748-131775`.
7. `_apply_mask()` checks only manifest-vs-image size, reads `img.get_pixel(x,y).r`, converts to a raw byte, and stores `p["mask_b"]`: `terrain_donor_inputs.gd:238-267`. It does not resample.
8. It then overwrites `p["width"]` and `p["height"]` with the mask's native 320×320: `terrain_donor_inputs.gd:268-269`. This is the grid-size defect.

### 2.3 I07 mask → `height` → smoothing

9. The composer calls I17 with the game's 240×240 size: `variant3d/scripts/terrain_donor_world.gd:203-233`. I07 then prefers `p.width/p.height` over the container size: `variant3d/scripts/terrain_donor_gen.gd:466-481`. I06 is reconfigured to **320×320**: `terrain_donor_data.gd:170-183`.
10. `_channel()` copies `PackedByteArray` values and divides by 255; it also normalizes float-like input if max>1: `terrain_donor_gen.gd:925-955`.
11. `_mask_to_height()` computes `hwater = -1.1 * (fb * (1 + fr*3.5))`; shipped R/G are zero, so this is exactly `h=-1.1*B/255`: `terrain_donor_gen.gd:843-912`. The setter stores f32: `terrain_donor_data.gd:303-305`.
12. `_smooth_chain()` runs one land pass and three coastal passes: `terrain_donor_gen.gd:961-982`. The in-place diagonal-neighbor update is `terrain_donor_gen.gd:985-1008`; the 5×5 water gate is `:1011-1017`.
13. `_texture_tiles()` classifies water/shore and writes tile ids: `terrain_donor_gen.gd:1071-1121`. With no `default_tile_name` in I17's `p`, ordinary land remains tile 0 from I06's zeroed `tex` array (`terrain_donor_data.gd:180-181`).

### 2.4 Relief stamp stage

14. `_stage_relief()` computes family frequencies and calls `_setup_patterns_by_type()`: `terrain_donor_gen.gd:1975-2023`.
15. `_setup_patterns_by_type()` computes `needed/trycount`, draws names, and increments telemetry—**but contains no position draw, `_check_stand()`, or `_stamp_pattern()`**: `terrain_donor_gen.gd:2026-2039`.
16. The only `_stamp_pattern()` call sites are `:792` (base tiles), `:1522` (mines), and `:1696` (starting resources). Base `d_tls_1..4` all have `Stand=false`: e.g. `variant3d/assets/terrain_new/patterns/d_tls_1.json:46-59` and `d_tls_2.json:46-59`, so `_stamp_pattern()` returns immediately at `terrain_donor_gen.gd:1741-1743`.
17. Executed mine/stone grids are zero (for example `mng_1.json:1281` and `d_stn_1.json:6221` onward). Nonzero `str_new_6/7` stoneforest grids exist (`families/stoneforests.json:499,520`), but I17's pattern-prefix filter excludes `str_new_*`: `terrain_donor_inputs.gd:466-472`; they are not loaded into `p.patterns` by `:570-595`.

### 2.5 I06 → I08 → I10

18. I07 writes f32 heights through `data.set_height()`: `terrain_donor_gen.gd:912,1827`. I06 exposes the same typed array through `to_live()`: `terrain_donor_data.gd:455-475`; the composer hands that dictionary to I08: `terrain_donor_world.gd:243-260`.
19. I08 copies the height field and creates one vertex per cell: `terrain_donor_mesh.gd:260-303,718-749`. Vertex Y is `_height[i]*1.0`; X/Z spacing is `TILE_M=2.0`: `terrain_donor_mesh.gd:41-42,747-749`.
20. Normals use a one-cell forward difference divided by 2 m: `terrain_donor_mesh.gd:313-329`, assigned at `:752`.
21. I08 loads the atlas, generates CPU mipmaps if needed, repacks mask R into alpha, and binds samplers: `terrain_donor_mesh.gd:386-467,530-548`.
22. I10 computes eye-space `st`, applies `texture_matrix`, then `v_st`: `variant3d/shaders/terrain_donor_shader.gdshader:199-211`. RGB uses `fract(v_st * uv_repeat)` at `:266-269`; `uv_repeat=(0.5,0.5)` at `:115`.
23. Tile-id 0 maps to atlas cell (0,0), i.e. `grass1`: `variant3d/assets/terrain_new/atlas/tile_index_atlas.manifest.json:48-73`. Ground alpha for id 0 maps to patch (0,0): `terrain_donor_shader.gdshader:251-263,285-293`.
24. Blinn-Phong uses the supplied normal: `terrain_donor_shader.gdshader:213-226`; final color is packed lighting plus specular, with no mask/RGB multiply: `:296-306`.

---

## 3. Selected seed/mask: expected numeric ranges

All values below are **[D] source-derived replay**, not runtime telemetry. Two independent f32 replays agreed on the load-bearing values.

### 3.1 Selector and asset facts

| Quantity | Value |
|---|---:|
| Requested game grid | 240×240 = 57,600 cells |
| Effective I17 shape | `mediterranean` |
| Candidate pool | 446 = 207 DLC5 + 121 `.src` + 118 vanilla |
| Native 240×240 candidates | 0 |
| FNV-1a string | `20261113|mediterranean` |
| FNV-1a result | `0x0DB22056` / 229777494 |
| Zero-based pick | 78 |
| Selected asset | `height/dlc5/mediterranean/4pl_mask_mediterranean_29_gauss.height.png` |
| Selected native grid | 320×320 = 102,400 cells |
| Starts | 4, at normalized `(0.0875,0.09062)`, `(0.9,0.13125)`, `(0.08125,0.89062)`, `(0.89375,0.90312)` |
| Original `B>=58` pixels | 30,936 / 102,400 = 30.2148% |
| `B==255` class pixels | 23,180 |
| Distinct B values | 256 |
| Derived PNG SHA-256 | `778eff3f4bba23a54a307cd7be6a80d76aa62e7af2c610e8a69329ae39538caf` |

The donor selector instead uses the configured terrain folder and player-count prefix, then `floor(RandomExt*count)`: `C:\Games\Cossacks 3\data\scripts\common.inc\generatemap.inc:171-191`. Base Mediterranean is `data\gen\terrainmasks\mediterranean` (`C:\Games\Cossacks 3\data\game\var\generator.cfg:8-10`); DLC5 is a separate table (`generator.cfg:29-36`). The run defaults to two players (`variant3d/scripts/config.gd:558-559`), but I17 selected a **4pl** mask and does no player-count filtering.

### 3.2 Height replay

| Stage | Min | Max | Unique heights | Exact-zero cells | Max ΔX / ΔZ |
|---|---:|---:|---:|---:|---:|
| Mask decode, before smoothing | -1.1000000238 | 0 | 256 | 65,549 | 0.694510 / 0.707451 |
| After land pass | -1.1000000238 | 0 | 256 | 65,549 | 0.694510 / 0.707451 |
| After coastal pass 1 | -1.0999999046 | 0 | 25,560 | 65,549 | 0.522961 / 0.620520 |
| After coastal pass 2 | -1.0999997854 | 0 | 28,530 | 65,549 | 0.606065 / 0.585199 |
| After coastal pass 3 | **-1.0999995470** | **0** | **30,011** | **65,549** | **0.606280 / 0.504706** |

Final replay statistics:

- Mean: **-0.27776170**; standard deviation: **0.43506488**.
- Deciles `[min,d1..d9,max]`: `[-1.09999955, -1.08355165, -0.89574307, -0.25110385, 0, 0, 0, 0, 0, 0, 0]`.
- Height `< -0.25`: **30,742** cells; `-0.25 <= h < -0.1`: **1,967**; `h >= -0.1`: **69,691**.
- Exactly flat: **65,549 / 102,400 = 64.0127%**.
- Maximum slope: **0.303140** in X, **0.252353** in Z; maximum normal tilt **16.864°**.

**Expected final I06 range remains `[-1.0999995470, 0]`.** The only executable stamps are base `Stand=false`, zero-grid mines/stones, or unavailable `str_new_*` patterns. Zero-grid default stamps write a bilinear `base_h` inside the existing range; zero-grid ReplaceForWater writes 0. They cannot create the positive ±2.964 m relief expected from real pattern stamps.

### 3.3 Mesh and shader numeric consequences

- Actual I08 mesh: **320×320**, **102,400 vertices**, **203,522 triangles**, world span **640×640 m**.
- Intended game/mesh size: **240×240**, **57,600 vertices**, **114,242 triangles**, world span **480×480 m**.
- I10 `uv_repeat=(0.5,0.5)` means **0.5 cycles/m**, period **2 m**. I08 cell spacing is also **2 m**, so the texture repeats **once per mesh cell**.
- Land tile 0 uses `grass1`; source art is 1024², packed at 128² with NEAREST downsample: `tile_index_atlas.manifest.json:48-73`.
- Alpha patch (0,0) is **255 for all 4,096 pixels**; after I08's R→A repack (`terrain_donor_mesh.gd:405-421`), ordinary land is fully opaque. The visible lattice is RGB/UV, not alpha coverage.

---

## 4. Hypothesis tests

### (a) Gray8 value used as height without `-1.1*v/255` — **FAIL**

**Discriminating test.** If raw `v` were used, selected-mask heights would span **0..255** with a maximum neighbor step of 255. If normalized `v` were used without the negative scale, heights would span **0..1** with water on the positive side. The live code divides by 255 and multiplies by -1.1 at `terrain_donor_gen.gd:941-945,904-912`; the replay spans **-1.0999995470..0**, not either alternative.

**Fix location/owner.** No fix required for the formula. Preserve `terrain_donor_gen.gd:904-912` and `:941-945` (I07). Do not flip the sign or add a scale fudge.

### (b) Wrong mask selected or wrong size — **PASS**

**Discriminating test.** Effective shape is Mediterranean, not the map JSON's `map_type=land`; FNV picks DLC5 4pl mask index 78; native 240² candidates = 0; `p.width/height` becomes 320; I08 therefore emits 102,400 vertices instead of 57,600. Donor selection is folder/player-count/RNG based (`generatemap.inc:171-191`), not a cross-tree FNV hash.

The selected mask's ring-shaped 30.21% water coverage is also consistent with the new non-flat coastline/basin visible in `cap_donor_240c.png`; `cap_donor_240b.png` has the same props but flat terrain.

**Fix location/owner.** `variant3d/scripts/terrain_donor_inputs.gd:155-168,180-222,238-269` (**COORD/I17**):
1. Resolve shape from the same effective value as the sim/config, with explicit-user-key precedence; do not let default `terrain_type` silently override `map_type`.
2. Select only the configured donor tree and player-count family; never pool `.src`/DLC5/vanilla together.
3. Use the donor selection stream/rule or keep the current selector explicitly labelled as a non-donor preview.
4. Keep the requested game grid. Implement donor nearest source sampling `floor(x/mapwidth*srcwidth)` / `floor(y/mapheight*srcheight)` from `C:\Games\Cossacks 3\data\scripts\common.inc\generatemap.inc:397-411,537-546`, rather than replacing the game grid with the mask grid.

### (c) Pattern grid offsets/scale create broad quantized terraces — **FAIL**

**Discriminating test.** Current corrected offsets are 968/1864/2798/2222/8225 at `terrain_donor_gen.gd:229-235`; I17 loads full `w*h` float grids, not 8×10 means (`terrain_donor_inputs.gd:483-511`). More decisively, `_setup_patterns_by_type()` has no stamp call (`terrain_donor_gen.gd:2026-2039`). Full grids such as `hil1` max 3.8613, `plt2` max 3.6134, and `k_ravine_1` max 3.1398 would push heights far outside the replayed `[-1.1,0]` range if applied. They are not applied.

**Fix location/owner.** Do **not** change offsets or scale. The defect is missing placement in `terrain_donor_gen.gd:2026-2039` (**I07**): implement donor position/rejection/stand/stamp calls. Before doing so, resolve I17's occupancy handoff: `_decode_pattern()` rejects `(h-1)*(w-1)` occupancy and leaves `occupancy` absent (`terrain_donor_inputs.gd:513-521`), while `_check_stand()` then treats every cell as occupied (`terrain_donor_gen.gd:1713-1738`) and `_stamp_pattern()` stamps the full rectangle (`:1778-1784`). Owner: **I07 + COORD/I17**.

### (d) `grid` bilinear/nearest sampling produces steps — **FAIL**

**Discriminating test.** Mask pixels are copied directly; no image resampling occurs (`terrain_donor_inputs.gd:261-269`, `terrain_donor_gen.gd:941-945`). Pattern grids use direct row-major indexing (`terrain_donor_gen.gd:1785`), and `_sample_bilinear()` only supplies the stamp-centre base height (`:1776-1777,1849-1862`). With no nonzero relief-family stamp, it cannot create the visible lattice. The final height replay has **30,011 unique values**, not broad quantized plateaus from nearest sampling.

The missing donor nearest resize is real, but it belongs to hypothesis (b), not to a sampler creating terraces.

**Fix location/owner.** No sampler fix for the observed bands. When (b) is fixed, put donor nearest resampling at the I17 input boundary (**COORD/I17**) or a named I07 input adapter; do not bilinearly resample the mask.

### (e) One-cell normals + steep lighting exaggerate steps — **PASS (amplifier only)**

**Discriminating test.** I08's stencil is exactly one cell (`terrain_donor_mesh.gd:313-329`). Replayed maximum slope is 0.30314, giving 16.864° tilt. With donor sun direction `(-0.344731,0.938701,0)`, flat-ground `dot(l,n)=0.938701`; opposing/ascending X slopes give approximately **0.998341 / 0.798325**, a material diffuse contrast. I10 applies that normal directly in Blinn-Phong (`terrain_donor_shader.gdshader:213-226`). This can make real coastline/mask steps look sharper, but 64.01% flat cells and the absence of relief stamps rule it out as the lattice source.

**Fix location/owner.** Do not tune normals, sun, diffuse, or `HEIGHT_SCALE` to hide the issue. Fix the height input at **I17 (b)** and the UV source at **I10 (f)**. I08's normal stencil (`terrain_donor_mesh.gd:313-329`) is not the primary repair site.

### (f) Shader texture repeat/fract creates diagonal bands — **PASS**

**Discriminating test.** `v_st` is eye-space (`terrain_donor_shader.gdshader:199-206`), `uv_repeat=0.5` (`:115`), and RGB uses `fract(v_st*uv_repeat)` (`:268`). The resulting 2 m period equals I08's 2 m cell spacing (`terrain_donor_mesh.gd:41,747-749`). Capture row-mean edge peaks at y=110,141,173,206,241,279,319 have spacings **31,32,33,35,38,40 px**, increasing with perspective as a repeated world/cell lattice should. Tile 0 alpha is constant 255, so this is not an alpha-mask band.

**Fix location/owner.** `variant3d/shaders/terrain_donor_shader.gdshader:103-125,199-211,266-269` (**I10 + COORD/D08**): remove the unauthorized extra `uv_repeat` multiplication from the donor path and bind the recovered donor runtime `gl_TextureMatrix[0]`/eye-plane values. The current identity defaults plus 0.5 repeat are explicitly PORT APPROXIMATION; no replacement numeric scale is authorized by the evidence. A camera-pan A/B should confirm that the bands are eye-plane locked before integration.

### (g) Atlas nearest filtering/mipmap absence — **FAIL as stated**

**Discriminating test.** The tile sampler is `filter_linear_mipmap_anisotropic`, not nearest: `terrain_donor_shader.gdshader:58`. The loader calls `Image.generate_mipmaps(false)` before creating the texture: `variant3d/scripts/tile_atlas_loader.gd:335-356`; I08 repeats the check at `terrain_donor_mesh.gd:386-402,449`. NEAREST exists only in the offline 1024→128 atlas downsample (`variant3d/tools/build_terrain_new_atlas.py:323-348`) and in the alpha samplers (`terrain_donor_shader.gdshader:63,71`). Runtime mip generation success is `[U]` without telemetry, but source-level absence is contradicted.

Whole-atlas coarse-mip bleed is a possible separate quality issue, not proved by this capture and not evidence for “mipmap absence.”

**Fix location/owner.** No absence fix. If a later diagnostic proves packed-atlas mip bleed, owner is **I05/I08**: per-cell padded mips or texture-array transport. Do not change filtering blindly.

---

## 5. Contradictions and non-findings

- **V58 vs current I07:** V58 reports missing `plt2`/`k_ravine_big_stone_1` offsets and a different precision default. Current `terrain_donor_gen.gd:229-235,257-260` has all five offsets and `f32_each_op`. Current source wins.
- **`map_type=land` vs selected Mediterranean:** resolved by config DEFAULT + merge, then selector replay, then donor TGA/PNG equality. The effective runtime shape is Mediterranean.
- **“Terraces must be pattern grids”:** refuted by the complete `_stamp_pattern()` call graph and the `[-1.1,0]` height range. The larger defect is missing relief placement.
- **“Diagonal bands must be alpha/atlas nearest”:** refuted for land tile 0 by the constant-255 alpha patch and the linear-mipmap sampler declaration.
- **Height-as-albedo:** not present in I10; `ALBEDO=rgb` and `ALPHA=a` are separate at `terrain_donor_shader.gdshader:296-306`.

## 6. Handoff to COORD

1. **Repair I17 selection/grid first:** effective shape, donor tree, player-count prefix, donor selection stream, requested-size nearest resample. This is the direct source of the unexpected stepped relief silhouette.
2. **Repair I10 UV source:** current eye-space 0.5 repeat + fragment `fract` creates a one-repeat-per-cell lattice. Bind donor runtime texgen values; do not invent a new scale.
3. **Implement the missing I07 relief placement stub before any claim of donor-shaped hills.** Preserve corrected full-grid offsets; resolve occupancy semantics at the I17/I07 seam.
4. **Do not tune normals/lighting or atlas filtering to hide the defect.** They are not the primary source.
5. Re-capture only after those changes, with height min/max/deciles, tile histogram, normal-slope max, mask identity/size, and shader UV parameters recorded.

**NO DONOR VISUAL PARITY CLAIM. Parity remains UNVERIFIED.**

*End of W03. Exactly one repository file written; donor read-only; no code/shader/asset/config/test edit, no Godot job, no gate, no git operation.*
