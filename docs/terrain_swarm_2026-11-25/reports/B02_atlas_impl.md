---
id: B02-ATLAS-IMPL
title: "B02 — atlas texture mipmaps: implementation (texture-side half of F04 P0-4)"
owner: B02 (IMPLEMENTATION, exclusive owner)
date: 2026-11-25
status: IMPLEMENTED__NOT_RUN__AWAITING_COORD_INTEGRATION
labels: [observed, derived, inferred, UNVERIFIED]
parity_guard: "PORT APPROX unless a donor GPU A/B exists (none does). No donor parity claimed."
files_owned_edited:
  - variant3d/scripts/tile_atlas_loader.gd
  - variant3d/assets/terrain/atlas/tile_index_atlas.png.import
  - variant3d/assets/terrain/atlas/tile_index_atlas_winter.png.import
files_added:
  - inbox/backup/tile_atlas_loader.gd.bak-B02
  - docs/terrain_swarm_2026-11-25/reports/B02_atlas_impl.md
godot_jobs_run: 0
integration_note: "B01 landed `filter_linear_mipmap` on tile_atlas concurrently; this fix supplies the mips that hint requires."
---

# B02 — atlas filtering implementation

## 0. Scope compliance

Read `CHARTER.md` first. `reports/A03_atlas_cells.md` and `reports/A06_filtering_aliasing.md`
did **not** exist when this work was done (reports dir held A02/A05/A08/A10/A12, C03/C04,
D02–D04, E01/E02, F01–F05 only). Grounding used instead: `CHARTER.md §2 item 3 / §3 / §5`,
`F04_quality_reviews.md` §4 item 13 + §5 P0-4 (COORD follow-ups), `A08_donor_truth_local.md`
§6 item 9 + §7 item 4, `A10_regression_constraints.md` §4, `C04_visual_review.md` R2.

Edited **only** the three owned files above plus the required backup and this report.
No shader, `game.gd`, `world3d_terrain.gd`, test, config, manifest or runner job touched.
No Godot / runner job submitted (explicitly forbidden by the ticket).

## 1. OBSERVED — how the atlas sampler is actually made

1. `variant3d/scripts/tile_atlas_loader.gd:280-290` (`_load_single`) and `:335-397`
   (`_load_split`) decode the PNG with `Image.load()` / `Image.new().load()` and wrap it with
   `ImageTexture.create_from_image(img)`. **No resource `load()` is involved**, so the
   `[params]` of `tile_index_atlas.png.import` never reach this runtime texture.
2. All four atlas `.import` files had `mipmaps/generate=false` and **no `flags/*` keys at all**
   (no filter, repeat or anisotropy entries). Both atlas PNGs are 16384x8192; grid is 16x8
   from the manifest, i.e. each cell is 1024x1024 (`tile_atlas_loader.gd:310-317`, `:403-411`).
3. At ticket time the shader declared
   `uniform sampler2D tile_atlas : filter_nearest_mipmap, repeat_enable;`
   (`variant3d/shaders/terrain_tileindex.gdshader:60`). **B01 landed concurrently**: the
   integrated tree now reads `filter_linear_mipmap, repeat_enable` (B01's own diff changes
   only that hint plus its comment). The material binds the loader's texture verbatim with
   `mat.set_shader_parameter("tile_atlas", _atlas_texture)`
   (`variant3d/scripts/world3d_terrain.gd:689`). The three sampler **names** and their
   binding are untouched by B02.
4. Godot 4.7 API facts (docs.godotengine.org/en/4.7, `Image` / `ImageTexture` / importing
   images / shading language): `Image.has_mipmaps() -> bool` and
   `Image.generate_mipmaps(renormalize=false) -> Error` both exist; `has_mipmaps()` is
   `const`. `ImageTexture.create_from_image()` wraps the Image's existing mip levels and
   does **not** create them. In custom shaders filter/repeat are controlled by the
   `sampler2D` hints (`filter[_nearest|_linear][_mipmap][_anisotropic]`,
   `repeat_enable|repeat_disable`) — the shader hint, not the texture resource flag, is
   authoritative for that sampler. `repeat_enable` was **already** set before B02, so no
   repeat change was needed.

(all OBSERVED citations; lines as landed in this tree)

## 2. DERIVED — why the current texture aliases

- The shader *asks* for mipmapping (`filter_nearest_mipmap` then, `filter_linear_mipmap`
  now) but the runtime `ImageTexture` carried **only level 0**, because `Image.load()`
  returns no mip chain and `.import` flags are bypassed. A mip-filter sampler with no mips
  cannot minify at all: it samples the 1024² cell repeated every 2 m without LOD filtering
  (`fract(v_st * uv_repeat)`, shallow camera) → moiré / faint diagonal streaks
  (CHARTER §2 item 3, C04 R2). This is a **texture-supply defect**, not a post-process AA
  problem: F04 §4 item 13 (gameGPU "AA has virtually no effect") rules out an AA fix.
- The `.import` flag alone cannot fix the observed path; the loader must attach mips to the
  `Image` before `create_from_image()`. B01's hint change is necessary but not sufficient
  without this.

## 3. Change — exact diff

`git diff -- variant3d/scripts/tile_atlas_loader.gd variant3d/assets/terrain/atlas/tile_index_atlas.png.import variant3d/assets/terrain/atlas/tile_index_atlas_winter.png.import`
(B01's concurrent shader diff is **not** included below; see §4/§6.)

```diff
diff --git a/variant3d/assets/terrain/atlas/tile_index_atlas.png.import b/variant3d/assets/terrain/atlas/tile_index_atlas.png.import
index 433136e1..86abaa7c 100644
--- a/variant3d/assets/terrain/atlas/tile_index_atlas.png.import
+++ b/variant3d/assets/terrain/atlas/tile_index_atlas.png.import
@@ -23,7 +23,7 @@ compress/rdo_quality_loss=0.0
 compress/hdr_compression=1
 compress/normal_map=0
 compress/channel_pack=0
-mipmaps/generate=false
+mipmaps/generate=true
 mipmaps/limit=-1
 roughness/mode=0
 roughness/src_normal=""
diff --git a/variant3d/assets/terrain/atlas/tile_index_atlas_winter.png.import b/variant3d/assets/terrain/atlas/tile_index_atlas_winter.png.import
index 5aa4221d..4459b5a7 100644
--- a/variant3d/assets/terrain/atlas/tile_index_atlas_winter.png.import
+++ b/variant3d/assets/terrain/atlas/tile_index_atlas_winter.png.import
@@ -23,7 +23,7 @@ compress/rdo_quality_loss=0.0
 compress/hdr_compression=1
 compress/normal_map=0
 compress/channel_pack=0
-mipmaps/generate=false
+mipmaps/generate=true
 mipmaps/limit=-1
 roughness/mode=0
 roughness/src_normal=""
diff --git a/variant3d/scripts/tile_atlas_loader.gd b/variant3d/scripts/tile_atlas_loader.gd
index c15d0a7a..ee5eaf8f 100644
--- a/variant3d/scripts/tile_atlas_loader.gd
+++ b/variant3d/scripts/tile_atlas_loader.gd
@@ -282,7 +282,7 @@ func _load_single() -> bool:
 	var img := _load_image_at(single_atlas_path)
 	if img == null:
 		return _soft_fail("single atlas unavailable: " + last_error)
-	_atlas_texture = ImageTexture.create_from_image(img)
+	_atlas_texture = ImageTexture.create_from_image(_prepare_atlas_image(img))
 	if _atlas_texture == null:
 		return _soft_fail("ImageTexture.create_from_image failed for " + single_atlas_path)
 	_load_masks()
@@ -332,6 +332,30 @@ func _load_image_at(path: String) -> Image:
 	return img
 
 
+# B02 / F04 P0-4 — give the shader-facing atlas a real mip chain.
+# The atlas image is decoded with Image.load(), NOT load()/CompressedTexture2D,
+# so the .import `mipmaps/generate` flag never reaches this runtime texture:
+# ImageTexture.create_from_image() wraps only the base level. Yet the sampler
+# declares a *mipmap* filter on `tile_atlas` (terrain_tileindex.gdshader:60:
+# `filter_nearest_mipmap` at ticket time, B01 now `filter_linear_mipmap`),
+# i.e. it *expects* mip levels. With none present the GPU has nothing to
+# minify with and samples a 1024² cell repeated every 2 m with no LOD
+# filtering — the classic moiré / diagonal streaks of Charter §2 item 3
+# (F04_quality_reviews §5 P0-4; §4 item 13 says post-process AA cannot fix it).
+# Generating the chain on the CPU attaches real mips to the SAME base pixels:
+# level 0 is byte-identical, so the single -> split -> array fallback, the
+# 16x8 manifest grid and the index mapping are all unchanged. This is the
+# texture-side half of P0-4: B01's `filter_linear_mipmap` hint needs these mips.
+# Cost: ~33% extra VRAM and a one-time CPU build for the 16384x8192 atlas.
+func _prepare_atlas_image(img: Image) -> Image:
+	if img.has_mipmaps():
+		return img  # custom/DDS source already carries mips — leave it untouched
+	var err := img.generate_mipmaps(false)
+	if err != OK:
+		push_warning("TileAtlasLoader: atlas mipmap generation failed (error %d); texture stays base-level only" % err)
+	return img
+
+
 func _load_split() -> bool:
 	var manifest := _read_json(SPLIT_MANIFEST)
 	if manifest.is_empty():
 		return _fail("split manifest unavailable: " + last_error)
@@ -389,7 +413,7 @@ func _load_split() -> bool:
 	var err := img.load(ProjectSettings.globalize_path(CACHE_FILE))
 	if err != OK:
 		return _fail("Image.load_from_file failed (error %d)" % err)
-	_atlas_texture = ImageTexture.create_from_image(img)
+	_atlas_texture = ImageTexture.create_from_image(_prepare_atlas_image(img))
 	if _atlas_texture == null:
 		return _fail("ImageTexture.create_from_image failed")
 	_load_masks()
```

## 4. Before / after flags (explicit)

| Surface | Flag / param | Before | After | Owner |
|---|---|---|---|---|
| Runtime `ImageTexture` from `_load_single` / `_load_split` | mip levels on the Image | level 0 only | full chain (1024² → 1x1) via `Image.generate_mipmaps(false)` | **B02 — effective fix** |
| Runtime `ImageTexture` | level-0 pixels | original bytes | **byte-identical** (only appended mips) | B02 |
| `tile_atlas` sampler filter hint (shader :60) | filter | `filter_nearest_mipmap` | `filter_linear_mipmap` | **B01** (concurrent; not B02) |
| `tile_atlas` sampler repeat hint | repeat | `repeat_enable` | `repeat_enable` (unchanged) | none needed |
| Runtime `ImageTexture` / `.import` | texture-level filter / repeat / anisotropy | none set | none set — shader hints govern; anisotropy deliberately **not** enabled (§6) | — |
| `tile_index_atlas.png.import` | `mipmaps/generate` | `false` | `true` | B02 |
| `tile_index_atlas_winter.png.import` | `mipmaps/generate` | `false` | `true` | B02 |
| `alpha.png.import`, `alphavert.png.import` | all flags | unchanged (`mipmaps/generate=false`) | unchanged — masks use `filter_nearest`, donor masks have no mips | — |

No `flags/*` keys were added to any `.import`: in Godot 4 import-time filter/repeat are
not texture flags anyway (docs, Importing images), and the shader hints already declare
both. `mipmaps/limit` stays `-1` (unlimited), so 1024² keeps its full 11-level chain.

## 5. Why this reduces aliasing (INFERRED, mechanism-level; no A/B frame)

- With a real mip chain, a minified fragment fetches a pre-filtered smaller level instead of
  sampling isolated texels of a 1024² cell. Averaging high-frequency grain *before* it falls
  below one pixel removes the sub-pixel frequencies that fold into moiré / diagonal bands at
  shallow camera angles (the class C04 R2 reports). B01's `filter_linear_mipmap` selects and
  blends those levels; without B02's mips that hint has no levels to blend — the two changes
  are complementary, not redundant.
- `generate_mipmaps(false)` builds each level by downsampling the previous one; it adds no
  texels to level 0, so no colour value is invented and no donor constant is fabricated.
  `renormalize=false` is correct for a colour atlas (A08 §7 item 1 forbids a normal map).
- The donor art is *already* 1024² with 11 mips (`A08` §6 item 9: "full 1024²/11-mip art,
  nearest-mag / nearest-mipmap-linear-min, `tfIsotropic`"), so supplying the missing mips
  restores a **donor-observed property of the asset**. It is NOT donor parity proof: B01's
  linear magnification is explicitly a PORT APPROX vs donor `maNearest` (B01 diff comment,
  reftile.mat:29-37), and the port UV/tile→patch rules stay PORT APPROX (A08 item 9,
  F01 C12).
- Post-process AA is explicitly not the fix (F04 §4 item 13), so none was added.

## 6. Handoff / open questions (UNVERIFIED)

1. **B01's hint has landed** (`filter_linear_mipmap` on `tile_atlas`, :60). No further
   handoff needed for the sampler. Anisotropy was **not** enabled anywhere: donor
   `filteringquality=tfIsotropic` (A08 §7 item 4), so an anisotropic claim would be PORT
   APPROX and is unnecessary for this fix. Mask samplers (:66/:72) keep `filter_nearest`
   and are out of scope.
2. **Atlas-bleed risk.** Mips of a hand-indexed atlas mix neighbouring cells at coarse
   levels, and `fract()` at 2 m boundaries makes UV derivatives spike → coarsest mip at the
   seam. Expect possible thin 2 m seam bands; F04 P0-1 work and QA re-capture must check
   `full_width_dark_rows == 0`, `dark_cols == 0`, luma floors. Not measurable here — no
   Godot run was permitted.
3. **Cost.** One-time CPU mip build and ~33% extra VRAM on the 16384x8192 atlas (~512 MB
   base → ~683 MB with mips) — INFERRED from dimensions; not profiled.
4. **Reimport.** The `.import` edits take effect on next Godot editor import; no reimport
   was run. The observed runtime path does not depend on them.

## 7. Constraints preserved (OBSERVED)

- `single -> split -> array` fallback and its `_soft_fail` / SHA-256 / byte-count logic are
  untouched; `_load_array()` is untouched; manifest `grid` 16x8, `layout`, `named_cells`,
  `manifest_path` / `single_atlas_path` overrides and index→slot maps are untouched.
- Three samplers `tile_atlas` / `alpha_atlas` / `alphavert_atlas`, their names and binding in
  `world3d_terrain.gd:689-691` are untouched; no `game.gd`, `world3d_terrain.gd`, test,
  marker, threshold or shadow/water literal was edited by B02 (B01's shader edit is B01's).
- Level-0 pixels and therefore tile-id→cell appearance are byte-identical; season swaps
  (summer/winter manifest overrides) go through the same prepared path.

## 8. Backup and verification

- Backup: `inbox/backup/tile_atlas_loader.gd.bak-B02` (SHA-256
  `9B82A48DF4F8A7DD6FF6AD1C99DBC6A57AE1C374603AFCC243128643C5F23978`), taken **before**
  editing.
- No Godot / runner job was run, per ticket. Correctness of the visual claim remains
  **UNVERIFIED** until C-wave re-capture on the integrated tree; donor parity remains
  **UNVERIFIED** (no donor GPU A/B frame exists).

*End of B02 report.*
