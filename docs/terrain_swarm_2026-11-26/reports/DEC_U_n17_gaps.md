---
id: DEC-U-N17-GAPS-2026-11-26
title: "DEC-U-N17 — donor file-bytes to renderer feed gaps (reftile.lib / .pattern / atlas / native loaders)"
worker: DEC-U-N17 (READ-ONLY subagent, full 1:1 Cossacks 3 donor port)
date: 2026-11-26
pin: t_87f0f3c130b0 (cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b0277c4e72dc217eae9d592982370d112e0d224897bc92af4e16c)
scope: READ-ONLY static decomp. Donor read-only, never executed/copied/committed. No code/Godot/git/asset/config/test edits. Exactly one repo file written (this report).
labels: [O] donor bytes/text/VA re-read or carried with evidence id · [D] arithmetic/control-flow consequence · [U] UNVERIFIED (zero-mismatch byte-dump probe given, never substituted) · PORT APPROXIMATION = port substitute
parity_claim: false
parity_status: UNVERIFIED
parity_guard: "PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED. No donor GPU A/B frame exists; this report certifies neither donor fidelity nor a gate pass."
condition_ref: "PORT1TO1_parity_chain.md condition 5 (spec/toolchain: X15 manifest, I05 atlas, I03 feed, N17 populated/signed, blocking_unverified=[] — BLOCKED)"
upstream: ["DEC_U_atlas_layout.md (per-block 1024² DXT1 transport; 16x8 fallback [U])", "DEC_U_placement.md (Objects[] instancing + compact pattern feeds [U])", "D08_tile_select_bin.md", "PORT1TO1_parity_chain.md", "PORT1TO1_terrain_renderer.md", "DEC_U_scenecolor_glstate.md", "DEC_U_port_guard_audit.md (G1/G2)", "DEC_U_alpha_pass_quad.md", "A03_asset_pipeline.md", "spec/06_TILE_AND_ATLAS.md"]
---

# DEC-U-N17 — feed chain from donor file bytes to renderer texture/UV/indices

## 0. Result in one paragraph

The donor terrain feed for shipped maps is a **file → descriptor → producer (`0x812e34`) → installer (`0x8177f0`) → quad-record (`0x48`→`0x50`) → texture/UV/indices** chain, not a packed-atlas chain. File bytes are **[O]/[D]**: `reftile.lib` actives `tsDouble/ttExtended/0.1/0.2`, commented `Rows/Cols/TileSize/Alpha*` inactive; per-block `1024x1024 DXT1 11-mip` DDS (`grass1.dds` header), `alpha.bmp 512x256 8bpp`, `alphavert.bmp 1024x512`; `terrain.presets` 124+124 ids; `tiles.mat` name→image; `tiles.lib` 245-section geometry overrides; `.pattern` prefix `int32 w,h + w*h u8` occupancy; descriptor `FUN_00544548 @0x544548` fields `+0xc/+0xd/+0x24/+0x25/+0x28/+0x2c/+0x2d/+0x30/+0x34/+0x38`; UV writers `FUN_00812b4c` / `FUN_00812ccc`; LUTs `0x8f5cd7`/`0x8f5d00`; selectors `0x50db08`/`0x50daec`; `pattern.lib Objects[]` per-record instancing. Every **runtime binding** — packed atlas grid, `glTexImage2D` upload tuple, variant byte, `RandomExt` seed derivation, `Objects[]`→mesh binding, relief float-grid/object tail, per-frame eye/matrix, draw-pass count — is **[U]** and terminates only on a stated zero-mismatch byte-dump. **No grid, UV, or atlas layout is invented here. No parity claimed.**

## 1. Multi-pass discipline (owner rule, ≤5 passes per oddity)

| Pass | What was done | Verdict |
|---|---|---|
| P1 | Re-read `DEC_U_atlas_layout.md` §§1–5, `DEC_U_placement.md` §§1–7, `PORT1TO1_parity_chain.md` §§1/5 in full | per-block transport [O], 16x8 fallback [U], Objects[] gap [U], cond-5 BLOCKED carried — not re-argued |
| P2 | Re-read live port `terrain_donor_mesh.gd:1-200,:1590-1660` + `terrain_donor_shader.gdshader:60-110,:145,:306-344` + `terrain_donor_gen.gd` grep anchors (bsmooth/Objects/stamps/RNG) | sceneColor=0.2 + GLSTATE + LUT/inset/rot-mirror-Vflip consts [O]; fallback labels intact; change-list line anchors fixed |
| P3 | Re-read feed evidence: A03 `*.pattern`/atlas rows, D08 `reftile.lib`/DDS/`tiles.*` rows, `ev_*` id-chain (`ev_58d7418c…`, `ev_b2e66417…`, `ev_1d5e6e86…`, `ev_70c790f9…`, `ev_d7e71e03…`, `ev_a03439ea…`, `ev_8d1f6535…`, `ev_c949cdfc…`, `ev_80043e7b…`, `ev_fadb2880…`) pinned on `t_87f0f3c130b0` | file→descriptor→producer→installer→quad chain [O]/[D]; runtime upload/probe [U] |
| P4 | Cross-checked residual surface: `0x812e34` producer / `0x8177f0` installer / `0x8326b8` variant fan-out / `0x755f30` stamp family / `0x60f64c` RandomExt / `0x403a0c` Delphi / `0x8f2008` slot / `0x8f5cd7`+`0x8f5d00` LUTs / `glTexImage2D` absent-tuple | no new bytes claimed; each [U] given §6 probe |
| P5 | Wrote this file only; verified single-file discipline | no other file created/edited |

Pinned addresses carried (all `t_87f0f3c130b0`, read-only): `FUN_00544548 0x544548` (`ev_b2e66417…`); ctor defaults `FUN_00544210/FUN_005444f8` (`ev_1d5e6e86…`, `ev_27273f21…`); scheme branch `0x813155` + immediates `0x813167/0x813227/0x813235-0x8132c3/0x813348-0x813380` (`ev_58d7418c…` raw); RGB writer `FUN_00812b4c` (`ev_6f767eed…`, `1.0f @ev_1db801be…`); alpha writer `FUN_00812ccc` (`ev_9694d0d…`/`ev_e9694d0d…`, `1.0f @ev_47db71da…`); RGB selector `0x50db08` (`ev_70c790f9…`); alpha selector `0x50daec` (`ev_d7e71e03…`); `DAT_008f5cd7` 15 B `0x8f5cd7` (`ev_a03439ea…`); `DAT_008f5d00` 16 pairs `0x8f5d00` (`ev_8d1f6535…`); padding-word exclusion (`ev_ced999a4…`); `sceneColor 0x8f58dc` + submit `0x4d13f1` + two-side `0x4d1404/0x4d1412=0x0B52` + caps `0x8fb0dc` (`DEC_U_scenecolor_glstate.md §1`); producer `0x812e34` (`ev_58d7418c…`); renderer installer `0x8177f0` (`ev_9ce28a17…`); stamp `sub_755f30 0x755f30-0x75c187` (`ev_ed57855c…`, `ev_4a342…`); setters `0x8326b8`/`call 0x403a0c @0x832727`; Delphi `Random(256) 0x403a0c` (`ev_6478320b…`), slot `0x8f2008` (`ev_0e686c8c…`/`ev_bde23e2d…`), seeder `sub_4033b8` (`ev_78bcf9c8…`); RandomExt `0x60f64c-0x60f698`, RTTI `SetRandomKey @0x60a6b2` / `SetRandomExtKey64 @0x60a72e` / `GenerateMapRandKey @0x69f452` (`ev_9defac5a…`/`ev_661ef2e6…`/`ev_3e61f9fa…`); sampler units `texUnit0=0x84c0/texUnit1=0x84c1 @0x818428`, material text `reftile.mat:24-49` (`ev_fadb2880…`), `shaders.lib` (`ev_80043e7b…`), `reftilealpha.mat` (`ev_c949cdfc…`).

## 2. Feed chain map (file bytes → renderer)

```
[F0] data/terrain/ref/reftile.lib            [O] active tsDouble/ttExtended/0.1/0.2; commented Rows/Cols inactive
[F1] data/terrain/tiles/terrain.presets      [O] 124 Summer + 124 Winter ids (ev_e742a78c…)
[F2] data/terrain/tiles/*.mat (tiles.mat)    [O] name -> textures\<name>.dds
[F3] data/terrain/tiles/textures/*.dds       [O] per-block 1024x1024 DXT1, 11 mips, pitch 524288 (grass1.dds header, D08 §3.1)
[F4] data/terrain/tiles/tiles.lib            [O] 245-section geometry overrides (ev_d77d8ef5…)
[F5] data/terrain/ref/alpha.bmp              [O] 512x256 8bpp data@1070, 254 palette entries (D08 §3.5, F06-E7/E9/E10)
[F6] data/terrain/ref/alphanull.bmp          [O] 512x256 all-zero -> src.a=0
[F7] data/terrain/ref/alphavert.bmp          [O] 1024x512 24bpp (reftilealpha.mat, ev_c949cdfc…)
[F8] data/pattern/<name>.pattern             [O] prefix int32 w,h + w*h u8 occupancy (donor_gen.py:74-85); tail [U] N17-G5
[F9] data/pattern/pattern.lib                [O] Objects[] per-pattern records (BaseName/RaceName/Position/Direction/Up/Scaling); .pattern 24 B tail is NOT Objects[] (F08 E11)
      -- descriptor / selectors (native, byte-proven) --
[D0] FUN_00544548 @0x544548                  [D] +0xc=1 +0xd=1 +0x1c=0.1 +0x20=0.2 +0x24=8 +0x25=8 +0x28=64 +0x2c=8 +0x2d=4 +0x30=64 +0x34/+0x38=25
[D1] RGB LUT DAT_008f5cd7 + selectors 0x50db08 / full-variant tables 0x8f5ce8/ec/f2/f6/fa   [D]
[D2] Alpha LUT DAT_008f5d00 (16 LE pairs) + selector 0x50daec                                 [D]
      -- producers / writers (native, byte-proven conventions) --
[P0] RGB writer FUN_00812b4c (u=px/param_3, v=py/param_11, flip v:=1-v)                       [D]
[P1] Alpha writer FUN_00812ccc (same + insets art+0x1c/+0x20)                                 [D]
[P2] tsSingle RGB path 0x813167/0x813227 (rot0/mirror0/Vflip1)                                [D]
[P3] tsDouble RGB path 0x813235-0x8132c3, no LUT, x/y both mod +0x24, 16 m macro period       [D]
[P4] tsDouble alpha path 0x813348-0x813380, col=p/4 row=p%4, u0=col/8 v0=row/4, rot2/Vflip1    [D]
[P5] Whole-map producer 0x812e34 -> installer 0x8177f0 -> 0x48 records -> 0x50 quad records   [D structure / U counts]
      -- renderer bindings (mixed) --
[R0] texUnit0=0x84c0 RGB / texUnit1=0x84c1 mask; maNearest/miNearestMipmapLinear/twBoth(G_REPEAT 0x2901)/tfIsotropic [O text]
[R1] sceneColor 0x8f58dc (0.2,0.2,0.2,1.0) via glLightModelfv @0x4d13f1; two-side 0x0B52 GL_FALSE; caps 0x8fb0dc [O CLOSED U-1/U-2]
[R2] bmTransparency case-1 SRC_ALPHA/ONE_MINUS_SRC_ALPHA, NO glAlphaFunc comparator on case 1 [O]; case-1 ref [U]
[R3] Port sampler2DArray (one 1024² layer/used id) = authoritative donor transport [O policy]; 2D 16x8 2048x1024 128²-cell = labelled [U] fallback (E-ATLAS-LAYOUT)
[R4] Baked mesh: one quad per distinct tag, uv0 RGB + uv1 alpha, COLOR=(id,layer,p,mask); indices B,A,C,D (*0xb, 0x2c stride) [D structure / U runtime counts]
```

Recoverable statically (§4): F0–F7, F8-prefix, F9-existence/shape, D0–D2, P0–P4, R0–R1, R3-policy.
Requires authorised GL/donor-runtime dump (§5–§6): upload tuple (R3-binding), per-frame eye/matrix (U-7/U-8), draw-pass count (U-9), `tiaAlphaFromIntensity` arithmetic (U-4), variant byte (Delphi), `GenerateMapRandKey` derivation, `Objects[]`→mesh binding values, relief float-grid/object tail bytes, `sumProb` init, `minx/miny`, modifiers, `sumProb`/stand-mask concretes.

## 3. File-byte legs — what is proven (do not re-prove)

- **[O] F0 `reftile.lib:3-6` actives** (`ev_0290fb40…`): `TileScheme=tsDouble`, `TileType=ttExtended`, `TileXOffset=0.1`, `TileYOffset=0.2`. Lines 7–12 (`TileSize/Rows/Cols/AlphaRows/AlphaCols/AlphaTileSize`) are **commented = inactive** (D08 §3.1, PORT1TO1 §4.2). Never use `16x16` as a grid.
- **[O] F1–F4 id→art chain** (D08 §3.1): `terrain.presets:2-125,129-252` ids; `tiles.mat` name→DDS (`:2-4,142-213,346-360`); `tiles.lib:1-909` 245 override sections; face ids (`rock*vf/vs`, `sand*f/s`) reuse base DDS with different `refkey`.
- **[O] F3 art units**: `grass1.dds` = `DDS 1024x1024 DXT1 pitch 524288 11 mips`; donor tsDouble subcell = `1024/8 = 128² px`; `TileSize=64` is selector unit, cancels in UV space. `sand1/sand2` are `256²` donor upscales (NEAREST, manifest-labelled).
- **[O] F5–F7 alpha carriers**: `alpha.bmp 512x256` = `8x4` grid of `64²` patches; `alphanull.bmp 512x256` zero; `alphavert.bmp 1024x512` with face scale `0.125` eye-linear planes (`reftile.mat:120-169`).
- **[O] F8 prefix**: `int32 w,h @0x00..0x07` + `w*h u8 @0x08` occupancy (values `0/1` in all 710 files, F01 E6; `tools/donor_gen.py:74-85,97-129`, `export_donor_patterns.py:1-165`). Tail = **[U] N17-G5**.
- **[O] F9 `Objects[]` shape**: per-pattern record lists (e.g. `mng_1` 11 records incl. `minegold` scale `0.3152`; `d_frt_big_1` 124 trees), fields `BaseName/RaceName/Position/Direction/Up/Scaling` (`pattern.lib:713285+`, `:338480-338507`). The `.pattern` 24 B tail counts (63/2072/323 vs 11/124/34) are **not** `Objects[]` (F08 E11). Transform order `translate(C)*rotY(PI-rotangle)*scale(ObjectsScale)*translate(record.xz)` then `y` from record/`HeightOffset`/`ObjAutoOffset`, `Direction/Up/Scaling*ObjectsScale` before `sub_7cca74→sub_4cb27c` submit [D] (DEC-VIS-02 fnd_44 + `sub_755f30` frame).
- **[D] D0 descriptor** (PORT1TO1 §4.2 `ev_b2e66417…`; ctors `ev_1d5e6e86…`/`ev_27273f21…`; branch `0x813155` raw `ev_58d7418c…`): table in `DEC_U_atlas_layout.md §3`, bound by port today at `terrain_donor_mesh.gd:1605-1610` (`tile_scheme=1 tile_type=1 donor_rows/cols=8 alpha 8/4`) — keep.
- **[D] D1/D2 LUTs**: RGB low `[46,4,8,12,1,5,9,13,2,6,10,14,3,7,11]` + full-variant bins `[0,15]/[0,15,16,17,18,19]/[20..23]/[24..27]/[28..31]`; alpha low `[0,2,1,3,8,10,9,11,4,6,5,7,12,14,13,15]`, high = low+16 on `variant&1`; corner weights `[8,2,4,1]` (`t0→8,t1→2,t2→4,t3→1`, compares `0x813125-0x813145`).
- **[D] P0–P4 writers**: §5 table of `DEC_U_atlas_layout.md` stands incl. the corrected alpha axes (`col=p/4,row=p%4; p+16 ⇒ u+0.5`, parity-half withdrawal) and call-site `rot/mirror/Vflip` immediates (`0,1,0,0 / 0,0,1,0 / 2,1,0,1`). `tsSingle` RGB is LUT-indexed; shipped `tsDouble` RGB is LUT-free world-cell (`u0=(x+W/2)%Rows, v0=(y+H/2)%Rows`, both ÷`+0x24`).
- **[O] R0/R1**: sampler contract text + `0x818428` units; `sceneColor=(0.2,0.2,0.2,1.0)` + two-side `GL_FALSE` CLOSED (guard `DEC_U_scenecolor_glstate.md §1`).

## 4. Recoverable links (static, no runtime needed)

| # | Link | Status | Authority / port anchor |
|---|---|---|---|
| R-A | `reftile.lib` actives vs commented defaults | [O] CLOSED | F0; port binds `0.1/0.2` at `terrain_donor_mesh.gd:169-171` |
| R-B | `terrain.presets → tiles.mat → 1024² DDS` id→art resolution | [O] CLOSED | F1–F3; port `_build_donor_tile_array` reads on-disk 1024² blocks (`terrain_donor_mesh.gd:828-868`) |
| R-C | `tiles.lib` 245-section override table existence | [O] shape CLOSED, application [U] | F4; port does not apply overrides — §6 N17-G8 |
| R-D | `alpha.bmp/alphanull/alphavert` dimensions + grid arithmetic | [O] CLOSED | F5–F7; port `DONOR_ALPHA_{ROWS,COLS,TILE,W,H}` (`terrain_donor_mesh.gd:164-168`), shader `alpha_atlas 512x256 / alphavert 1024x512` (`terrain_donor_shader.gdshader:91-94`) |
| R-E | `.pattern` prefix decode (`w,h + occupancy`) | [O] CLOSED for prefix | F8; `tools/donor_gen.py:74-85`; port `pattern_stamps` carrier (`terrain_donor_gen.gd:1154,3199-3210`) |
| R-F | `pattern.lib Objects[]` record shape + transform order | [O] shape / [D] order CLOSED | F9; port records `name/family/x/y/kind` only (`terrain_donor_gen.gd:3003-3020`) — members [U] N17-G6 |
| R-G | Descriptor `+0xc/+0xd/+0x24/+0x25/+0x28/+0x2c/+0x2d/+0x30/+0x34/+0x38` values | [D] CLOSED | D0; port `terrain_donor_mesh.gd:1605-1610` + shader `:101-107` |
| R-H | RGB/alpha LUTs + selectors + corner weights | [D] CLOSED | D1/D2; port `DONOR_RGB_MASK_LUT / DONOR_ALPHA_PAIR_LO / DONOR_CORNER_WEIGHTS` (`terrain_donor_mesh.gd:152-162`) |
| R-I | UV writer conventions + rot/mirror/Vflip + base-only insets | [D] CLOSED (corrected axes) | P0–P4; port consts `RGB_SINGLE_* / RGB_DOUBLE_* / ALPHA_DOUBLE_*` + insets (`terrain_donor_mesh.gd:169-180`) |
| R-J | `sceneColor=0.2` + two-side `GL_FALSE` + caps + `bmTransparency` blend + no-`rgb*=a` | [O] CLOSED (U-1/U-2) | R0/R1; `DONOR_SCENE_COLOR` (`terrain_donor_mesh.gd:128`), `scene_color` bind (`:1626`), shader `:145,:287,:344` |
| R-K | Authoritative transport = `sampler2DArray` one 1024² layer/used id; 16x8 = labelled fallback | [O] policy CLOSED, fallback [U] | R3; shader `:83-89`, mesh `:1597-1600`, `ATLAS_GRID_EXPECTED` (`terrain_donor_mesh.gd:97`) |
| R-L | Baked-quad structure (distinct-tag quads, uv0+uv1, COLOR payload, B,A,C,D indices) | [D] structure CLOSED, counts [U] | R4/P5; mesh `0x48/0x50` stride + index/UV offsets (`terrain_donor_mesh.gd:139-148`) |

## 5. Unrecoverable-statically links (require authorised GL/donor-runtime dump)

All items below stay **[U]**; no silent default, no invented grid/UV/atlas.

| ID | Link | Why static fails | What dump is required |
|---|---|---|---|
| N17-G1 | 2D packed-atlas grid (donor has none shipped) | Static proves the negative (per-block DDS + commented Rows/Cols + manifest `APPROX_ATLAS_PACKING`) but no runtime upload tuple exists | E-ATLAS-LAYOUT (`DEC_U_atlas_layout.md §6`): trace `glTexImage2D` + `glBindTexture`, filter `GL_ALPHA 0x1906` vs RGB DDS; Summer + Winter maps |
| N17-G2 | RGB DDS `glTexImage2D` upload tuple `(target,level,internalformat,w,h,format,type,bound_name,texUnit)` | No pinned terrain `glTexImage2D(w,h)` tuple; `sub_5d2ad4` GL_LINEAR helper excluded (not terrain path) | Same trace as G1; attach each upload to `texUnit0=0x84c0` |
| N17-G3 | Mask/alpha upload path + `tiaAlphaFromIntensity` byte arithmetic (enum 1 [O]) | Enum recovered; arithmetic pending fixed-camera `GL_ALPHA` byte-dump probe (`DEC_U_shore_alpha.md §5.1`, U-SA3) | Fixed-camera `GL_ALPHA` texel dump: mask texel → `ALPHA` direct (`hf.pvl.smx3.frag:50`), no luma math |
| N17-G4 | Per-frame eye planes / matrix (U-7/U-8), draw-pass count (U-9) | No static frame state | Authorised frame trace (≥2 frames): eye planes + matrix + pass count |
| N17-G5 | `.pattern` relief float-grid + object-list tail layout | Decoders stop at `w*h` occupancy (`donor_gen.py:74-85`); `pattern.lib` layout beyond `terrainmeshN` parse unproven (A03 R1) | Byte-dump tail of ≥3 patterns (`hil1`,`g_mnt_3`,`f_plt_big_1`): record `(offset, dtype, count, known-values)`; refuse non-null without table (A03 check 4) |
| N17-G6 | `pattern.lib Objects[] → mesh` index binding (counts/positions/scales/material keys) | Data names only; engine binding engine-side | Per-pattern `Objects[]` export diff (counts/positions/scales) vs port `pattern_stamps`; instancer stays missing by design until then |
| N17-G7 | Per-pattern `HeightFieldScale/Min/Max/Offset/TerrainScale`, `minangle/maxangle`, WithAngle `+0x34/+0x38` concretes; `Max` never read (0/6751) | Offsets known (`+0x3a/+0x3b/+0x48/+0x4c/+0x5c/+0x60/+0x64/+0x68/+0x74/+0x78/+0x80-82`); values in `pattern.lib`, not exported | Dumped floats reproducing X13 vectors 19/19 on `g_mnt_1/g_hil4`; never invent floats |
| N17-G8 | `tiles.lib` 245-section override application + `HeightFieldReplaceForWater` / `ObjectsScale` per pattern | Table exists; application order/values engine-side | Stamp-vs-smooth order trace + per-pattern scale/replace dump |
| N17-G9 | `GenerateMapRandKey` derivation (`randkey0/1`); `key0` discarded mod 2³² | Consumers + RTTI names [O] (`@0x60a6b2/@0x60a72e/@0x69f452`); formula unreadable | `key0`-only change bit-identical; `key1±1` changes `D2:190` pick + first three `RandomExt` floats (GENSEED §2.4) |
| N17-G10 | Delphi generation-time state (`state=(s*0x8088405+1) mod 2³²`, `out=state>>>24`, slot `0x8f2008`, seeder QPC-else-Tick) | Algorithm + image-0 [O]; per-run value wall-clock | Authorised-trace `0x83272f` dump: every byte == `state>>>24`, restart changes seed (GENSEED §2.4.1) |
| N17-G11 | `SmoothTerrain(x,-y,False,3)` kernel body (S0) | Call shape [O] (`generatemap.inc:591`); body undiscovered high VA | Byte-proven kernel dump reproducing `hook(height,w,h,bsmooth,3)`; `bsmooth_kernel=NULL/SKIP` until then |
| N17-G12 | `minx/miny` numerics (`_misc_GetMapLeftTopPos`, `generatemap.inc:218-228`, literal `x>minx∧x<W/2∧y>miny∧y<W/2` with W-for-both-axes) | Gate text [O]; numeric pair absent | Logged helper out-args reproducing in/out gate per S1/S2 cell on 320²+640² |
| N17-G13 | `probsmall/mid/large/huge`, `pln_*/swamp_*/lake_*` application + `640/((W+H)/2)` rescale | Base table + getter + rescale [O]; body engine-side | Logged modifiers recomputing `needed=floor(W·H·freq)` trip counts on ≥3 sizes |
| N17-G14 | `TileSmoothPasses=6` cfg consumer (script uses 3, `smoothtiles.inc:237`) | Contradiction open | Cfg-key reader call-site address |
| N17-G15 | Case-1 alpha comparator/ref (no `glAlphaFunc` on bmTransparency-1; cases 3/4 `GL_GEQUAL 0.5/1.0`) | Absence [O]; leaked/default value [U U-SA5] | GL state dump at case-1 draw: comparator+ref bytes; `alpha_test_ref=-1.0` sentinel until then, discard stays OFF |
| N17-G16 | `Objects[]` per-instance variation source (authored record bytes via permute/fixups vs rolled RNG; 662-callee list has no RandomExt/Delphi/QPC) | No-RNG-in-stamp [O] (`ev_4a342…`); `WithAngle/minangle` use [U] | Authorised execution trace of `sub_755f30` family on a fixed pattern: per-instance bytes with zero RNG draws |
| N17-G17 | Runtime activation of `[*] = ;` DScript text (mill-completion produce→reseed, map-start `cSeedWheat`, AI mill loop) | Text [O]; execution untraced | Authorised execution trace only; never a tuned visual |

Carried compact-feed residuals (DEC_U_placement.md §7, same probes apply): U-G0 (`G=0` zero density), U-FA (`fa/broad` loader default), U-SUM (`sumProb` init `0.0` labelled), U-MDEN/U-VER/U-SEED (menu/record-version/key derivations), U-WATER/U-CLIFF (plane-Y/tag values), U-ACT (=N17-G17).

## 6. Zero-mismatch termination criteria (one per still-[U] item)

Common harness: pin `t_87f0f3c130b0`; fix `randkey0=0, randkey1∈{1,12345}`, `W=H∈{320 (repeat 256, 640 once)}`, `shape=nowater2`, `version=92`, `minesdensity=1`, `spcount=4`, `season∈{0 Summer, 3 Winter}`, `b_random_map=true`, `foreststype=0`, `pattern_modifiers={small:1,mid:1,large:1,huge:1}`, fixed `families/patterns` bundle. Run port `generate()` twice; diff named arrays/counts. **Terminate an item only on zero mismatches across the stated repeats; otherwise it stays [U]. Never invent a value to force a match.**

| ID | Termination (exact, byte-level) |
|---|---|
| N17-G1/G2 | Static leg: byte-dump `reftile.lib` descriptor + all 112 DDS headers + `alpha.bmp`/`alphavert.bmp`; expect `(name,1024,1024,DXT1,11)` + `(alpha,512,256)` + `(alphavert,1024,512)`. Dynamic leg (authorised trace only): every `glTexImage2D` call `(target,level,internalformat,w,h,format,type,bound_name,texUnit)` + `glBindTexture`→unit attach recorded; **terminate iff every observed tuple matches the static leg with zero mismatches across ≥2 frames (one Summer + one Winter load)**; any extra/packed/sub-1024 upload keeps the 16x8 fallback labelled and re-opens packing with observed bytes |
| N17-G3 | Fixed-camera `GL_ALPHA` texel dump: mask texel value == fragment `ALPHA` input for every texel, zero mismatches; `tiaAlphaFromIntensity` formula reproduced byte-for-byte or stays [U] |
| N17-G4 | Authorised frame trace: eye planes + matrix + pass count byte-identical across 2 frames for the same fixed seed/map; zero mismatches |
| N17-G5 | Tail dump of `hil1` + `g_mnt_3` + `f_plt_big_1`: `(offset,dtype,count)` + known-value table (e.g. `k_ravine_1` min −2.9636/max +3.1398, `plt1` +3.4967, `hil1` +3.8613×0.65 per DPATTERN_01); **terminate iff decoder emits non-null float-grid + object list reproducing the table with zero byte mismatches**; else `null`+UNVERIFIED |
| N17-G6 | Per-pattern `Objects[]` export diff (record counts + `Position` + `Scaling` + material keys) for the fixed bundle: zero mismatches; instancer missing by design until then |
| N17-G7 | Dumped floats reproduce X13 vectors 19/19 on `g_mnt_1`/`g_hil4` with zero float mismatches; `Max`-never-read preserved |
| N17-G8 | Stamp-vs-smooth order trace + per-pattern `ObjectsScale`/`HeightFieldReplaceForWater` dump: zero mismatches on the fixed seed pair |
| N17-G9 | `key0`-only perturbation bit-identical; `key1±1` changes `D2:190` mask pick + first three `RandomExt` floats exactly as ledgered; zero mismatches on repeats |
| N17-G10 | `0x83272f` dump: every variant byte == `state>>>24`, zero mismatches; process restart changes seed; generation-time state stays image-0 placeholder until then |
| N17-G11 | Byte-proven `SmoothTerrain(x,-y,False,3)` kernel dump reproducing `hook(height,w,h,bsmooth,3)`; `bsmooth_pass=SKIPPED` + `bsmooth_kernel=NULL` on all fixed seeds until then; never substitute a blur |
| N17-G12 | Logged `_misc_GetMapLeftTopPos` out-args reproduce the in/out gate for every S1/S2 cell on 320² + 640²; zero mismatches; hook stays NULL (never hard-code 0) |
| N17-G13 | Logged modifiers recompute `needed/trycount/mapSizeOptimise` trip counts exactly on ≥3 sizes; caller values verbatim until then |
| N17-G14 | Named cfg-key reader call-site address cited; skirmish follows script 3 until then |
| N17-G15 | GL state dump at a case-1 draw: comparator+ref bytes recorded; `alpha_test_ref=-1.0` sentinel + discard OFF until then; never bake 0.5/1.0 |
| N17-G16 | `sub_755f30`-family execution trace on a fixed pattern: per-instance bytes reproduced with zero RNG draws (`RandomExt`/Delphi/QPC absent from the 662-callee path); variation attributed to authored bytes only |
| N17-G17 | Authorised execution trace showing the `[*] = ;` trigger firing (or not) on the fixed map/seed; labels only until then |

## 7. File/line port change list — NOT APPLIED (spec only)

Preserve `scene_color=vec3(0.2,0.2,0.2)` (`terrain_donor_shader.gdshader:145`, `terrain_donor_mesh.gd:128,1626`), every landed GLSTATE line, and all user mods. No behaviour change beyond labelled guards/telemetry. Line numbers 1-based as read 2026-11-26.

### 7.1 `variant3d/scripts/terrain_donor_mesh.gd`

| # | File:line | Precise change | Why / authority |
|---|---|---|---|
| M-01 | `terrain_donor_mesh.gd:97` | NO VALUE CHANGE. Optionally extend comment to `… (index-preserving 16x8)  # [U] U-10/N17-G1 FALLBACK grid, manifest-labelled APPROX (E-ATLAS-LAYOUT §6); never a donor claim`. | `DEC_U_atlas_layout.md §7 L7`; keeps loader fallback honest |
| M-02 | `terrain_donor_mesh.gd:95-121,125-180` | DO NOT TOUCH. Keep `MAX_TILE_ID=123`, `ATLAS_GRID_EXPECTED`, `DONOR_SCENE_COLOR=(0.2,0.2,0.2)`+`0x8f58dc/0x4d13f1` cite, GLSTATE pname/cap consts, `0x48/0x50` strides, LUT consts, insets `0.1/0.2`, rot/mirror/Vflip consts, `0.15686/0.78125` factors. | Landed [O]/[D]; guard §3.1 PRESENT |
| M-03 | `terrain_donor_mesh.gd:1483-1485,1441` | DO NOT TOUCH loader→`_atlas_grid` with `ATLAS_GRID_EXPECTED` fallback. Optionally add probe ref comment: `N17-G1/G2 terminate only on §6 E-ATLAS-LAYOUT zero-mismatch`. | Fallback policy + [O] bindings |
| M-04 | `terrain_donor_mesh.gd:1596-1641` | DO NOT TOUCH `tile_array/use_tile_array/tile_atlas/tile_map/alpha_atlas/alphavert_atlas/atlas_grid/tile_scheme/tile_type/donor_rows/donor_cols/donor_alpha_rows/donor_alpha_cols/scene_color/material_*` binds. | §3 [D]/[O]; R-G/R-J closed |
| M-05 | `terrain_donor_mesh.gd:1612-1616` | Keep `base_full_opacity=true`, `alpha_test_enabled=false`, `alpha_test_ref=-1.0 [U]`, `face_alpha_enabled=false`, `face_mode=0`. Optionally extend `alpha_test_ref` comment with `N17-G15`. | Case-1 no-comparator [O]; ref [U] |
| M-06 | `terrain_donor_mesh.gd:726,:1887` | Keep `objects_missing` telemetry + `_tile_array_info` duplicate. Optionally append `N17-G6` probe ref. | Largest fidelity gap, missing by design (F08 §7.1) |
| M-07 | everywhere else | NO OTHER mesh edit: no `rgb*=a`, no discard threshold, no `textureGrad`/LOD inset, no `sampler2DArray` removal, no fog/shadow/gamma fill, no second brightness constant. | `PORT1TO1 §8.6`; `DEC_U_renderer_residual.md` R-10 |

### 7.2 `variant3d/scripts/terrain_donor_gen.gd`

| # | File:line | Precise change | Why / authority |
|---|---|---|---|
| G-01 | `terrain_donor_gen.gd:1308-1352` | Gate `ig=127→cGForest` on already-decoded `terrain∈{plateau,hill,ravine}`; else leave unchanged. Cite `generatemap.inc:473-482`. Add side comment `:1315/:1349-1352`: `forest_density` is side data; free-stand counts come from `_setup_patterns_by_type`, never this enum (U-G0/N17). | `DEC_U_placement.md` P-PLACE-01/02 |
| G-02 | `terrain_donor_gen.gd:790` | Keep labelled NULL stub `_stage_forest_borders` (SKIPPED — `fb_*/grass5` pool [U]). Add cite `smoothforestborders.inc:30-171` + probe `N17` border-dress row. Never synthesise `fb_*` props. | P-PLACE-11 |
| G-03 | `terrain_donor_gen.gd:3003-3020,3195-3210` | Keep `name/family/x/y/kind` record + `pattern_stamps` handoff. Add `objects_missing` flag already at `:726` (keep) + probe ref `N17-G6`: terminate instancer gap only on export diff zero-mismatch; never synthesise members. Cite `pattern.lib:713285+`. | P-PLACE-15; F08 §7.1 |
| G-04 | `terrain_donor_gen.gd:3232-3238 (object_scale_rng_hook)` | Keep hook NULL/skip + TODO. Amend note to name winter-`leaftree` delete (`dogenerate.inc:1990-2021`) so a future hook implements all three branches (skip `terrainmesh`/`stones` + 5% dead-band + `leaftree` delete) together. Never substitute `RandomExt`. | P-PLACE-13; §6 stream rule |
| G-05 | `terrain_donor_gen.gd:2601+ (_stamp_pattern/_stamp_smooth_post)` | Add one-line guard comment: `no RNG draws in this function (ev_4a342…); record bytes only`. No logic change. | P-PLACE-14; N17-G16 |
| G-06 | `terrain_donor_gen.gd:1414-1420,471-475,522` | Keep `bsmooth_kernel=NULL/SKIP` + `bsmooth_pass=SKIPPED` telemetry. Add probe ref `N17-G11`. Never substitute a blur. | U-S0 |
| G-07 | `terrain_donor_gen.gd:1622-1639,646,766,828-839` | Keep `_rng_delphi` image-0 placeholder + free-running (NOT wired to `_stage_begin`), `state>>>24` draw at `:1637`. Add probe refs `N17-G10` (`0x83272f`) and `N17-G9` (key0-discarded ledger `:155-170`). | GENSEED §§2.4.1/2.4.2 |
| G-08 | `terrain_donor_gen.gd:858-884` | Keep [U] ledger strings. Append `N17-G5` tail row: `.pattern` relief float-grid/object tail `null`+UNVERIFIED; terminate only on §6 triple-pattern byte dump. Cite `donor_gen.py:74-85` + A03 check 4. | A03 R1; F01/D05 |
| G-09 | `terrain_donor_gen.gd:1217-1223` | Keep `mask_count` + `next_int(mask_count)` at `:1221` (D2:190 on inherited stream) + `nearest` default. No hash-draw substitution. | P-PLACE-16; GEN-SEED §5.2.1 |

### 7.3 `variant3d/shaders/terrain_donor_shader.gdshader` (reference only — no edit requested)

` :83-89` (`tile_array` authoritative / `use_tile_array=false` fallback + E-ATLAS-LAYOUT comment), `:91-96` (alpha/alphavert/tile_map), `:101-107` (descriptor uniforms), `:145` (`scene_color=vec3(0.2,0.2,0.2)` [O]), `:306-344` (array vs fallback fetch, no `rgb*=a`) — **DO NOT TOUCH** (`DEC_U_atlas_layout.md §7 L2–L6`).

## 8. Bottom line + open registers

- **Recoverable statically**: file actives/inactives, 112 per-block 1024² DDS + alpha carriers, `.pattern` occupancy prefix, `Objects[]` shape/order, descriptor fields, LUTs/selectors, UV conventions + immediates, `sceneColor=0.2`/GLSTATE/blend, array-authoritative vs 16x8-fallback policy, baked-quad structure.
- **Still [U] (17 items N17-G1..G17)**: packed-atlas grid, RGB/mask upload tuples, intensity arithmetic, eye/matrix/pass-count, `.pattern` tail, `Objects[]` binding, per-pattern height/angle concretes, `tiles.lib` application, key derivation, Delphi state, S0 kernel, `minx/miny`, modifiers, `TileSmoothPasses` consumer, case-1 comparator, in-stamp variation source, `[*]` activation. Each terminates only on its §6 zero-mismatch byte-dump; none is closed by a tuned visual, a PASS selftest, or a port fallback.
- **Port effect**: §7 lists are label/telemetry/cite additions plus the three functional gaps already owned by placement (`127`-gate G-01, border-dress stub G-02, `Objects[]` instancer G-03). Everything else is keep-with-cite — notably `sceneColor=0.2`, all GLSTATE lines, descriptor binds, LUT/inset/rot-mirror-Vflip consts, RNG ledger separation, and user mods.
- **parity=UNVERIFIED. No parity claim. No donor GPU A/B frame. Condition 5 stays BLOCKED** (`blocking_unverified` non-empty; N17 schema-only `spec/terrain_qa_spec.json`, no `atlas/` tier, I05 unbound, I03 `props_total=0`/fallback path, N17 unsigned).

*End of DEC_U_n17_gaps. Files written: this report only. Donor read-only; no binary executed/copied/committed; no code, shader, asset, config, test, backup, git, Godot, or investigation-memory state changed. PORT APPROXIMATION — internal consistency only; donor parity UNVERIFIED.*
