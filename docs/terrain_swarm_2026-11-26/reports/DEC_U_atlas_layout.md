---
id: DEC-U-ATLAS-LAYOUT-2026-11-26
title: "DEC-U-ATLAS-LAYOUT — donor tile atlas grid/packing, per-tile size, descriptor fields and UV convention"
agent: "DEC-U-ATLAS-LAYOUT (READ-ONLY subagent; no code/Godot/git edits; donor read-only, never executed)"
date: 2026-11-26
target_pinned: "t_87f0f3c130b0 (cossacks.exe, sha256 87f0f3c130b0…)"
scope: "Static read-only decomp/text recovery of the donor 2D atlas packing question; exactly one repo file written (this report)"
labels_used: [O, D, U, "PORT APPROXIMATION", "PORT FALLBACK"]
parity_claim: false
parity_guard: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this report certifies neither donor fidelity nor a gate pass."
---

# DEC-U-ATLAS-LAYOUT — donor atlas grid, per-tile size, descriptor and UV convention

## 0. Result in one paragraph

The donor has **no 2D tile atlas**. RGB transport is **per-block textures**: 112
separate `1024×1024 DXT1` DDS files (11 mips), resolved
`tile id → terrain.presets TileBlock name → tiles.mat Material.Texture.image`,
with `tiles.lib` geometry overrides. The port's `16×8 / 128²-cell /
2048×1024` packed sheet (`atlas_grid=vec2(16,8)`, `use_tile_array=false`) is a
**[U] PORT FALLBACK**, correctly labelled `APPROX_ATLAS_PACKING` in its own
manifest — it is not a recovered donor layout. Shipped descriptor bytes are
**[O]/[D]**: `+0xc scheme`, `+0xd type`, `+0x24 Rows=8`, `+0x25 Cols=8`,
`TileSize=64`, `Alpha 8×4×64`; UV writers `FUN_00812b4c` / `FUN_00812ccc`
conventions are byte-proven. The commented `Rows=16/Cols=16` in `reftile.lib`
are **inactive** and must never be used as an atlas grid. No `glTexImage2D`
atlas-upload dimension was statically proven here; the exact upload probe is
specified as experiment **E-ATLAS-LAYOUT** with a zero-mismatch rule. **No
donor parity is claimed.**

## 1. Method, target discipline and multi-pass ledger

- Read-only only. Donor `reftile.lib` read directly from absolute donor path
  (`C:\Games\Cossacks 3\data\terrain\ref\reftile.lib:1-13`). Port atlas manifest
  read (`variant3d/assets/terrain_new/atlas/tile_index_atlas.manifest.json`).
  Current `terrain_donor_shader.gdshader` (326 lines) and
  `terrain_donor_mesh.gd` constants/bindings re-read in full. Starting
  documents re-read in full: `DEC_U_port_guard_audit.md` §§1.2/5 (G1/G2),
  `PORT1TO1_terrain_renderer.md` §§4–5/7–8, `D08_tile_select_bin.md` §§2–3/7,
  `DEC_U_scenecolor_glstate.md` §1, `spec/06_TILE_AND_ATLAS.md`.
- This worker environment exposes no `native_*` engine tools, so **no new
  native bytes are claimed**. Every address/byte below is cited from pinned
  prior evidence ids on `t_87f0f3c130b0` (re-verified by re-read, not
  re-derived). Pin is explicit wherever a prior id is reused.
- Donor binary never executed/copied/committed; no repo code/shader/config/
  asset/test/git/Godot edit was made.

| Lead | Pass 1 | Pass 2 | Pass 3 | Verdict |
|---|---|---|---|---|
| `reftile.lib` active vs commented lines | direct text read `:1-13` | cross-check D08 §3.1 + PORT1TO1 §4.2 table | cross-check F05/P01 id-chain usage | active `tsDouble/ttExtended/0.1/0.2` [O]; `Rows/Cols/TileSize/Alpha*` commented = inactive [O] |
| donor art units | `grass1.dds` header 1024² DXT1 11 mips (D08 §3.1) | `tiles.mat` name→image + `tiles.lib` 245-section override table | manifest 112 PNG stems + per-cell `source_size` | per-block transport [O]; no atlas image ships [O] |
| descriptor `FUN_00544548` @ `0x544548` | PORT1TO1 §4.2 field table (`ev_b2e66417…`) | ctor defaults (`ev_1d5e6e86…`, `ev_27273f21…`) | scheme branch `0x813155` raw (`ev_58d7418c…`) | `+0xc/+0xd/+0x24/+0x25/+0x28/+0x2c/+0x2d/+0x30/+0x34/+0x38` [D] |
| RGB/alpha UV writers | Deep `FUN_00812b4c` (`ev_6f767eed…`) / `FUN_00812ccc` (`ev_e9694d0d…`) | raw `0x813227/0x8132c3/0x813380` push immediates (`ev_58d7418c…`) | F06 patch-mean cross-check (parity-half withdrawal) | conventions [D]; `p+16 ⇒ u+0.5` correction stands |
| LUTs | `0x8f5cd7` 15 B (`ev_a03439ea…`) / `0x8f5d00` 16 pairs (`ev_8d1f6535…`) | selectors `0x50db08` (`ev_70c790f9…`) / `0x50daec` (`ev_d7e71e03…`) | padding-word exclusion (`ev_ced999a4…`) | exact [D] |
| `glTexImage2D` atlas upload | text/binary-pass survey of D08 §2/§7, DEC_U_alpha_pass_quad §3.3, DEC_VIS_01 §7.2 | `sub_5d2ad4` GL_LINEAR helper excluded (not terrain path) | no pinned terrain `glTexImage2D(w,h)` tuple found | **no donor atlas-upload claim**; probe specified (§6) [U] |
| port 16×8 sheet | manifest `:20-47` labels + grid/slots/cells | shader `:62-86,:285-291` + mesh `:94,:1454-1456,:1575` reads | guard G1/G2 (`DEC_U_port_guard_audit.md:53-62,145-146`) | fallback, not donor [U] |

## 2. Donor transport: per-block textures, not a 2D atlas — exact

1. **[O] Id → art chain.** `data/terrain/tiles/terrain.presets:2-125,129-252`
   defines 124 Summer + 124 Winter ids (`DefaultIndex=0`, `D08 §3.1`,
   `ev_e742a78cdec8f173dfe6e16a07a5d9c340d8b0a1e9bcb73689b4b7378e51852eb`).
   `tiles.mat` maps each name to `textures\<name>.dds`
   (`D08 §3.1`, e.g. `:2-4,142-213,346-360`); `tiles.lib:1-909` holds 245
   sections of geometry overrides (`ev_d77d8ef5283afcb3b194fac2c02bab05c147d5617e0a7ea6da7ea192199fcb73642cde9`).
   Face ids (`rock*vf/vs`, `sand*f/s`) reuse the base DDS with a different
   `refkey` — same bitmap, different material (`D08 §3.1`).
2. **[O] Art units.** `grass1.dds` header bytes read directly: `DDS`,
   **1024×1024, DXT1, pitch 524288, 11 mip levels** (`D08 §3.1`, shell read, no
   ev id; reused by PORT1TO1 §7 table). Sampler contract from text:
   `maNearest` mag (`GL_NEAREST 0x2600`), `miNearestMipmapLinear` min
   (`GL_NEAREST_MIPMAP_LINEAR 0x2702`), `twBoth` (`GL_REPEAT 0x2901`),
   `tfIsotropic` = no aniso (`reftile.mat:24-49`, `ev_fadb2880…`; `shaders.lib`
   `ev_80043e7b…` binds `texUnit0=0`). Native `sub_5d2ad4` hardcodes
   `GL_LINEAR` for *some* dynamic-texture path but is **not** proven to be the
   terrain DDS path (`DEC_VIS_01 §7.2`) — it must not override the material
   text.
3. **[O] `reftile.lib` active bytes** (direct read, `C:\Games\Cossacks 3\…`):
   `TileScheme=tsDouble`, `TileType=ttExtended`, `TileXOffset=0.1`,
   `TileYOffset=0.2` (`reftile.lib:3-6`, `ev_0290fb40…`). Lines 7–12
   (`//TileSize=64 //Rows=16 //Cols=16 //AlphaRows=8 //AlphaCols=4
   //AlphaTileSize=64`) are **commented out = inactive** (`D08 §3.1`,
   `PORT1TO1 §4.2`). They describe loader defaults, not a packed sheet; using
   `16×16` as an atlas grid would be an invention.
4. **[O] Port 16×8 is labelled fallback.** Manifest
   `tile_index_atlas.manifest.json:3-47`: `labels` include
   `APPROX_ATLAS_PACKING`, `APPROX_ATLAS_DOWNSAMPLE`, `UNVERIFIED_EMPTY_CELLS`,
   `NO_VISUAL_PARITY_CLAIM`; `atlas.size=[2048,1024]`, `cell_size=[128,128]`,
   `grid=[16,8]`, `slots=128`, `named_cells=124`, `filled_cells=121`,
   `empty_cells=3`; `packing_label="APPROX_ATLAS_PACKING (donor
   tsDouble/ttExtended is engine-side, UNVERIFIED)"`; `mapping="index i ->
   cell (i%16, i//16); NO index remapping"`. Per-cell entries carry
   `source_size=[1024,1024]` (downsampled NEAREST) or `[256,256]` sand
   upscales, with `FACE_BASE_REUSE`/`EMPTY` kinds explicitly labelled.
   Therefore: **donor grid dimensions = none (no 2D atlas ships); port grid =
   16×8 fallback [U]**.

## 3. Descriptor field map (`FUN_00544548` @ `0x544548`) — [D]

From PORT1TO1 §4.2 (`ev_b2e664174e17999a7e990a22fcbd872ac88c7f39a259053d684bbf0859075438`),
constructor defaults (`ev_1d5e6e86…`, `ev_27273f21…`):

| Offset | Meaning | Shipped (tsDouble/ttExtended) value |
|---|---|---|
| `+0xc` | TileScheme (`0=tsSingle`, `1=tsDouble`) | **1** (`TileScheme` string; branch at `0x813155`, raw `ev_58d7418c…`) |
| `+0xd` | TileType (`0=ttUsual`, `1=ttExtended`) | **1** (drives RGB selector `param_3`; fragment of `0x50db08`, `ev_70c790f9…`) |
| `+0x10` | block path | `param_1+0x20+4` |
| `+0x14` | block name | `TileBlockName` |
| `+0x18` | default descriptor pointer | `FUN_00544210`/`FUN_005444f8` |
| `+0x1c` | TileXOffset (f32) | **0.1** (`reftile.lib` override; loader defaults `0.001953125` usual / `0.00390625` extended) |
| `+0x20` | TileYOffset (f32) | **0.2** (same override rule) |
| `+0x24` | Rows (u8) | **8** (4 single/usual, 8 single/extended, **8** double) |
| `+0x25` | Cols (u8) | **8** (4, 4, **8**); tsSingle path only for RGB-LUT indexing |
| `+0x28` | TileSize (u32) | **`0x40` = 64** (selector unit; cancels in UV space) |
| `+0x2c` | AlphaRows (u8) | **8** |
| `+0x2d` | AlphaCols (u8) | **4** |
| `+0x30` | AlphaTileSize (u32) | **`0x40` = 64** |
| `+0x34/+0x38` | AngleX/AngleZ | **25** (face materials only) |

Port binds today (`terrain_donor_mesh.gd:1576-1581`): `tile_scheme=1`,
`tile_type=1`, `donor_rows=8`, `donor_cols=8`, `donor_alpha_rows=8`,
`donor_alpha_cols=4` — byte-correct, keep.

## 4. Per-tile pixel sizes — [O] from headers + text arithmetic

- **RGB block: 1024×1024 px** per tile id (DDS header, `D08 §3.1`).
- **RGB tsDouble subcell: 128×128 px** = `1024 / Rows(8)` per axis
  (`PORT1TO1 §4.3`, `AUDIT_ATLAS_RESOLUTION §1`; mesh
  `DONOR_RGB_BLOCK_SIZE=1024`, `DONOR_RGB_SUBCELL_PX=128`). `TileSize=64` is
  the producer's integer selector unit, not a texel size — it cancels when the
  `xpx/ypx` numerators are divided by the block size.
- **Alpha atlas: 512×256 px** = `AlphaRows(8)×64` by `AlphaCols(4)×64`,
  **64×64 px per patch**, 8×4 grid (`alpha.bmp 512×256 8bpp data@1070, 254
  palette entries`, `D08 §3.5`, `F06-E7/E9/E10`). `alphanull.bmp 512×256`
  (all-zero payload → `src.a=0`); `alphavert.bmp 1024×512 24bpp`
  (`reftilealpha.mat`, `ev_c949cdfc…`; `reftile.mat:120-169` face scale
  `0.125`, eye-linear planes).
- **Port 128² cell ≠ donor tile.** Packing 1024² art into 128² atlas cells
  then applying the 8×8 selector yields 16²-px subcells — 64× texel deficit
  (`AUDIT_ATLAS_RESOLUTION §1`). This is why the authoritative port sampler is
  `sampler2DArray` (one 1024² layer per used id), not the 2D fallback.

## 5. UV conventions — [D] byte-proven (corrected axes)

Common writer `FUN_00812b4c` (`ev_6f767eed…`): per slot `+0x48` stride, four UV
pairs at `base+5+corner*8`; `u = px/param_3`, `v = py/param_11`,
`if (flip) v = 1.0 − v` (`_DAT_00812c90 = 0x3f800000`, `ev_1db801be…`).
Alpha writer `FUN_00812ccc` (`ev_e9694d0d…`): same shape at `+0x25+corner*8`
with `±insetX/±insetY` (`art+0x1c/+0x20`), `if (flip) v = 1.0 − v`
(`_DAT_00812e30 = 1.0f`, `ev_47db71da…`).

| Path | Selector | Subcell arithmetic | Call-site immediates (raw `ev_58d7418c…`) → rot/mirror/V-flip |
|---|---|---|---|
| `tsSingle` RGB (`0x813167`, `0x813227 → 0x812b4c`) | `rgbIndex = RGB_index(mask,variant,tileType)` (`0x50db08`, `ev_70c790f9…`: mask<15 → `DAT_008f5cd7[mask]` = `[46,4,8,12,1,5,9,13,2,6,10,14,3,7,11]`; mask=15 → full-variant tables `0x8f5ce8/0x8f5cec/0x8f5cf2/0x8f5cf6/0x8f5cfa` + implicit 0) | `row=(index/Cols(+0x25))*TileSize(+0x28)`, `col=(index%Cols)*TileSize` | pushed `0,1,0,0` → **rot 0, mirror 0, V-flip 1** (identity + `v:=1−v`) |
| `tsDouble` RGB, shipped (`0x813235–0x8132c3 → 0x812b4c`) | **no LUT**: `xpx=((Round(x)+(W≫1)) % Rows(+0x24))*TileSize`, `ypx=((Round(y)+(H≫1)) % Rows)*TileSize`; i.e. `u0=(x+W/2)%Rows`, `v0=(y+H/2)%Rows`; both axes divide by **`+0x24`** (`PORT1TO1 §4.3`); 8×2 m = **16 m** macro period | same writer | pushed `0,0,1,0` → **rot 0, mirror 1** (`slot=3−corner`), **V-flip 0** |
| `tsDouble` alpha (`0x813348–0x813380 → 0x812ccc`) | `p = ALPHA_index(mask,variant)` = `0x8f5d00` 16 LE pairs (`ev_8d1f6535…`; low row `[0,2,1,3,8,10,9,11,4,6,5,7,12,14,13,15]`, high = low+16 when `variant&1`, `0x50daec`, `ev_d7e71e03…`); `mask==0→p∈{0,16}` (constant 255); `mask==0xf→0` on transitions | raw call `param_3=512=8×64`, `param_11=256=4×64`: **`col=p/AlphaCols(+0x2d)`**, **`row=p%AlphaCols`**, `u0=col/AlphaRows(+0x2c)=col/8`, `v0=row/AlphaCols=row/4`, `u1=(col+1)/8`, `v1=(row+1)/4`; **base layer only** adds `u±0.1, v±0.2`, transitions zero inset | pushed `2,1,0,1` → **rot 2** (`slot=(corner+2)&3`), mirror 0, **V-flip 1** |

**Superseded/withdrawn:** `DEC-VIS-01 §5.4` transposed axes (`u=(p%4)/8`) are
wrong; raw call + F06 patch means prove `col=p/4, row=p%4`, so `p+16 ⇒ u+0.5`
(not `v+1.0`) and the "parity half is repeat-equivalent" claim is withdrawn
(`PORT1TO1 §5.1/§10`). Corner↔mask pairing is `t0→8, t1→2, t2→4, t3→1`
(slots `+0/+1/+2/+3`, compares at `0x813125–0x813145`).

## 6. What is still [U] — experiment E-ATLAS-LAYOUT (zero-mismatch rule)

**[U-10/atlas-packing] donor 2D atlas grid: no donor claim exists.** Static
passes prove the negative (per-block transport + commented-out Rows/Cols +
manifest self-label); what no static read can supply is a runtime upload
tuple. Do **not** fill this with `16×8`, `16×16`, or any invented grid.

**E-ATLAS-LAYOUT** (requires an authorised GL-trace / instrumented run; never
a silent default — keep `use_tile_array=false` + `atlas_grid=(16,8)` labelled
fallback until it passes):

1. Static leg (read-only, no donor execution): byte-dump `reftile.lib`
   descriptor (`TileScheme/TileType/offsets`), the commented defaults, and
   all 112 DDS headers (`w/h/fourcc/mips`), `alpha.bmp` (`512×256`),
   `alphavert.bmp` (`1024×512`); record expected tuples
   `(name, 1024, 1024, DXT1, 11)` + `(alpha, 512, 256)` + `(alphavert, 1024,
   512)`.
2. Dynamic leg (authorised trace only, cf. `DEC_U_alpha_pass_quad §3.3`):
   break on the `glTexImage2D` import/thunk; per call record
   `(target, level, internalformat, w, h, format, type, bound_name,
   texUnit)`; filter `format==GL_ALPHA (0x1906)` for the mask path and the RGB
   DDS uploads for the block path; break on `glBindTexture` to attach each
   upload to its sampler unit (`texUnit0=0x84c0 RGB`, `texUnit1=0x84c1 mask`).
3. **Terminate [U] iff** every observed tuple matches the static leg with
   **zero mismatches across ≥2 frames** (required: one Summer + one Winter map
   load, since the preset sets differ); any gap (extra atlas upload, sub-1024
   upload, packed upload) keeps the fallback labelled and re-opens the packing
   question with the observed bytes — never with an assumed grid.

Related residuals (not closed here, owned elsewhere): `tiaAlphaFromIntensity`
formula (U-4, enum value 1 recovered), per-frame eye planes/matrix (U-7/U-8),
draw-pass count (U-9), `sceneColor` runtime-mutation residual (U-R1) — see §8.

## 7. File/line port change list (NOT applied — spec only)

Preserve `scene_color=vec3(0.2,0.2,0.2)` (`[O]` U-1 CLOSED) and every landed
GLSTATE edit. No behaviour change beyond the two guard-audit labels (G1/G2).

| # | File:line | Precise change | Why / authority |
|---|---|---|---|
| L1 | `variant3d/shaders/terrain_donor_shader.gdshader:82` | Replace trailing comment with `// [U] U-10/atlas-packing (PORT APPROX): FALLBACK 16x8 packing; same grid as terrain_donor_mesh.gd:94 (V7-85 manifest:23-26, spec/06:19). Capture experiment E-ATLAS-LAYOUT (this report §6, pinned-candidate A/B) required before any parity use; not a donor-claimed layout. visual_parity_claim=false.` | `DEC_U_port_guard_audit.md:53-57` G1 remedial; keeps value, adds `[U]` + experiment |
| L2 | `variant3d/shaders/terrain_donor_shader.gdshader:65` | Replace with `// [U] U-10/atlas-fallback (PORT APPROXIMATION): false = 2D atlas fallback; not donor layout; E-ATLAS-LAYOUT (§6) pinned before any use. true = one 1024^2 donor-derived block per id at baked uv0.` Keep `:66-68` unchanged. | Guard G2 (`DEC_U_port_guard_audit.md:59-62,145-146`) |
| L3 | `variant3d/shaders/terrain_donor_shader.gdshader:62-64,70-76` | **NO CHANGE.** Keep `sampler2DArray tile_array` (authoritative donor transport), `tile_atlas` fallback sampler, `tile_map` retained binding, `alpha_atlas 512×256` / `alphavert_atlas 1024×512` comments. | `PORT1TO1 §8.3`; guard §3.1 PRESENT |
| L4 | `variant3d/shaders/terrain_donor_shader.gdshader:80-81,83-86` | **NO CHANGE.** Keep `tile_scheme=1 (+0xc)`, `tile_type=1 (+0xd)`, `donor_rows=8 (+0x24)`, `donor_cols=8 (+0x25)`, `donor_alpha_rows=8 (+0x2c)`, `donor_alpha_cols=4 (+0x2d)`. | §3 [D] |
| L5 | `variant3d/shaders/terrain_donor_shader.gdshader:124` | **DO NOT TOUCH.** Keep `scene_color = vec3(0.2, 0.2, 0.2)` + `[O] 0x8f58dc` comment, `:125-134` two-sided/`GL_FALSE` note, `:140 color_unify_gain=1.0`, `:114-116` specular-zero trio. | `DEC_U_scenecolor_glstate.md §1` U-1/U-2 CLOSED; guard §3.1 PRESENT |
| L6 | `variant3d/shaders/terrain_donor_shader.gdshader:285-291` | Append to the fallback-branch comment: `// cell=(mod(id,grid.x),floor(id/grid.x)) is the port manifest mapping (manifest:46), NOT donor addressing; donor binds one 1024^2 block per id (D08 §3.1).` No arithmetic change. | Prevents fallback being read as donor truth |
| L7 | `variant3d/scripts/terrain_donor_mesh.gd:94` | **NO VALUE CHANGE.** Optionally extend comment to `… (index-preserving 16x8)  # [U] U-10 FALLBACK grid, manifest-labelled APPROX (E-ATLAS-LAYOUT §6); never a donor claim`. | Keeps loader fallback path honest |
| L8 | `variant3d/scripts/terrain_donor_mesh.gd:95-121,124-157` | **DO NOT TOUCH.** Keep `DONOR_SCENE_COLOR=(0.2,0.2,0.2)` + `0x8f58dc/0x4d13f1` comment, `GLSTATE` pname/cap constants, `0x48/0x50` strides, LUT consts, inset `0.1/0.2`, call-site rot/mirror/V-flip consts, `0.15686/0.78125` factors. | Landed [O]/[D]; guard §3.1 PRESENT |
| L9 | `variant3d/scripts/terrain_donor_mesh.gd:1454-1456,1575,1569-1581,1597` | **DO NOT TOUCH.** Keep loader→`_atlas_grid` with `ATLAS_GRID_EXPECTED` fallback, `atlas_grid` binding, `tile_array/use_tile_array` params, descriptor uniforms, `scene_color=DONOR_SCENE_COLOR`. | Fallback policy + [O] bindings |
| L10 | everywhere else | **NO OTHER mesh/shader edit.** In particular: no `rgb*=a`, no discard threshold, no `textureGrad`/LOD inset, no `sampler2DArray` removal, no fog/shadow/gamma fill, no second brightness constant. | `PORT1TO1 §8.6`; `DEC_U_renderer_residual.md §R-10` |

## 8. Bottom line + open registers

- **Donor atlas grid: none.** Transport = per-block 1024² textures; per-tile
  px = 1024² block / 128² tsDouble subcell / 64² alpha patch; descriptor
  `+0xc=1, +0xd=1, +0x24=8, +0x25=8 (+0x28=64, +0x2c=8, +0x2d=4, +0x30=64)`;
  UV conventions per §5 table (tsSingle LUT path vs tsDouble world-cell path,
  corrected alpha axes, base-only insets, rot/mirror/V-flip immediates).
- **16×8 stays a labelled [U] fallback** (`manifest:38
  APPROX_ATLAS_PACKING`, shader `use_tile_array=false`, mesh
  `ATLAS_GRID_EXPECTED`) until **E-ATLAS-LAYOUT (§6)** terminates with zero
  mismatches. L1/L2 are label-only; L3–L10 are explicit no-touch guards
  (notably `scene_color=0.2` and all GLSTATE lines).
- **parity=UNVERIFIED.** No donor GPU A/B frame exists; no parity claim is
  made; no code/Godot/git/donor edit was performed.

*End of DEC_U_atlas_layout. Exactly one repo file written (this report).
Donor read-only; no binary executed/copied/committed; no source, config,
asset, test or backup file edited; no Godot job, gate, git mutation or donor
execution. PORT APPROXIMATION — internal consistency only; donor parity
UNVERIFIED.*
