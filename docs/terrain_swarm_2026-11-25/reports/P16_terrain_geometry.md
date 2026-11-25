---
id: P16-TERRAIN-GEOMETRY
ticket: TERRAIN-SWARM-2026-11-25 / Wave P / P16 (build-time terrain geometry optimisation, design only)
date: 2026-11-25
status: READ_ONLY__ONE_REPORT_ONLY__NO_CODE_EDIT__NO_RUNNER__NO_GODOT_JOB
labels: [observed, derived, inferred, UNVERIFIED]
files_created:
  - docs/terrain_swarm_2026-11-25/reports/P16_terrain_geometry.md
files_edited: []
godot_jobs_run: 0
runner_jobs_submitted: 0
parity_guard: "No Godot run, capture, frame-time or VRAM measurement was made. Every cost figure is a static/arithmetic analytical estimate labelled INFERRED or UNVERIFIED; nothing here is a benchmark, an FPS claim or a donor-parity claim (CHARTER §3; WAVE_G_CHARTER Wave P). The proposed diff changes NO pixel, NO vertex, NO UV2 value and NO shader/data contract; donor parity stays UNVERIFIED."
---

# P16 — safest build-time optimisation of `terrain.build()` (design, not applied)

## 0. Scope compliance

Read-only. Exactly one file created (this report); **no source, shader, config, test, asset or
loader file edited**; no Godot process started and no runner job submitted
(WAVE_G_CHARTER § "only G04 runs Godot/runner jobs").

Inputs read in full: `WAVE_G_CHARTER.md` (Wave P), `docs/terrain_swarm_2026-11-25/CHARTER.md`,
`reports/P06_loading_path.md`, `reports/A10_regression_constraints.md`,
`reports/B04_relief_impl.md`, and the current on-disk
`variant3d/scripts/world3d_terrain.gd` (1,866 lines). Two targeted reads of
`variant3d/scripts/tile_atlas_loader.gd` (`:482-494`, `:67-71`, `:485-488`) fixed the one
external fact the cache proposal depends on (§2.1). No donor binary or donor GPU frame was
read. No `Game`/`Runner` invocation.

**Version note (OBSERVED):** `git rev-parse --short HEAD` = `8e9de1bf`;
`git status --short -- variant3d/scripts/world3d_terrain.gd` = ` M ...` (B04's landed edits are
still uncommitted). Therefore **every line number in this report is the current on-disk working
tree**, not HEAD. The unified diff in §3 is written against that working tree; do not apply it
to a pristine `git show HEAD:...` copy.

**What this ticket is NOT:** it is not Blocker 1. P06 §5 ranks the atlas decode + CPU mip build
+ ~683 MiB upload (`tile_atlas_loader.gd:353`, `world3d_terrain.gd:1341/651`) as the dominant
startup stall; that file has a different owner and is out of P16 scope. The changes below are
small, provably output-identical savings inside P06 Blocker 2 (`world3d_terrain.gd` build body).
Expectation: **they cannot by themselves raise FPS**; they only shave redundant work from each
`build()`.

---

## 1. The optimisation target, grounded in the current file

P06 §2/:244-262 names Blocker 2: the whole `terrain.build()` body is one synchronous block with
a per-pixel mask repack and a full-grid mesh/mask/helper loop. Current on-disk facts:

| Work item | file:line (current) | Per build at default 160² (`data.gd:33-34`, 25,600 cells) | At 320² (102,400 cells) |
|---|---|---|---|
| Mask repack, two `get_pixel`/`set_pixel` loops | `world3d_terrain.gd:694-707`, called `:671-672` | 512×256 + 1024×512 = **655,360** pixel pairs (P06 §2/:108-109) | same (mask sizes are fixed assets) |
| Histogram `str(tid)` ×2 + transient `_manifest.get("atlas", {})` `{}` literal + 2 hash lookups | `:1082-1086` | 25,600 iterations × (2 `str`, 2 lookups, 1 temp dict) | 102,400 × |
| Provenance scan, 5 `_tile_indices` member reads/cell | `:1098-1129` | 25,600 × 5 | 102,400 × 5 |
| `hmax - hmin` recomputed per cell as `_relief_face_at` arg | `:1424` (span first available `:1332-1337`) | 25,600 subtractions | 102,400 |
| `float(w)`/`float(h)` conversions, `(float(z)+0.5-…)*TILE_M`, `(float(z)+0.5)/float(h)` recomputed per cell | `:1391-1395` | 25,600 × 5 per-cell evaluations | 102,400 × |
| `_face_hist` member dict lookup ×3 on every promoted cell; `_desert_remap` ×2; `_tile_index_name` ×1 on shore cells | `:1459`, `:1489-1491`, `:1501-1502` | promoted-share dependent (UNVERIFIED) | same |
| `_tile_name_index` member lookup per `_tile_index_for_name()` call | `:953-957` | promoted/shore cells (B04's Python replica: ~500–1,361 on synthetic fields — **UNVERIFIED** on real maps) | same |

**OBSERVED — already optimal, deliberately left alone:** `height.resize(w*h)` (`:1316-1317`),
`verts/norms/uvs/uvs2.resize(nverts)` and `inds.resize(ntris*3)` (`:1371-1380`), and
`arrays.resize(Mesh.ARRAY_MAX)` (`:1520-1521`) already preallocate every packed array. There is
no per-cell `push_back` to remove. Per-frame timing hooks
(`t_total/t_parsed/t_heights/t_mesh`, `:1302`, `:1314`, `:1325`, `:1557`, stats `:1803-1807`)
already exist; no new instrumentation or stats key is added (A10 §4 "adding diagnostic/stat
fields" is SAFE, but P16 adds none).

**OBSERVED — rejected as unsafe:** P06 §5 Blocker 2 floats "yield between row bands so the stage
can be amortised". That is **out of scope for P16 and rejected**: it would turn
`func build() -> bool` into a coroutine, breaking the synchronous bool contract asserted by
`build_ok` (`t_terrain_only.gd:489`, `t_combo_all.gd:613`, season `{id}_build_ok`) and needing a
caller change in `main.gd`/`world3d.gd` (other owners) plus a runner re-gate. "Row-band slicing"
below therefore means **computing each row's z-invariant terms once per row and writing the
same arrays, in the same index order, with the same values** — not `await`.

### 2.1 One external fact the mask cache depends on (OBSERVED, `tile_atlas_loader.gd`)

`_load_masks()` at `tile_atlas_loader.gd:482-494` iterates the fixed names
`["alpha.png", "alphavert.png"]` over the two **constant** directories
`PARTS_DIR := "res://assets/terrain/atlas_parts/"` and `ATLAS_DIR := "res://assets/terrain/atlas/"`
(`:67-68`). The SP-5 season override only rewrites `manifest_path` / `single_atlas_path`
(`:77`, `:116-117`); it does **not** reach `_load_masks()`. Hence both source masks, and the
`R->A` repack of `world3d_terrain.gd:694-707`, are **season-invariant and rebuild-invariant** in
the current tree. P06 §5's phrase "season-keyed" is therefore stronger than needed: a plain
source-size key suffices. The two masks have distinct dimensions (512×256 and 1024×512, cited
in `world3d_terrain.gd:1766`), so a size key cannot collide today. A future asset change that
gave both masks the same size would need an explicit slot key — recorded as an open question in
§6.

Also OBSERVED: nothing frees these textures. The only `.free()` calls in the module are
`node.free()` (`:1177`) and `child.free()` (`:1253`); `invalidate()` merely nulls `_alpha_tex` /
`_alphavert_tex` / `_atlas_texture` (`:1261-1263`). A cached `Texture2D` reference therefore
stays valid across `invalidate()`/`build()` cycles (`set_atlas_mode():396-406` is the in-node
path that exercises this).

---

## 2. Design rules used (why this is the *safest* variant)

1. **Byte-identical outputs only.** Every edited expression is the same float64 operation in the
   same order as before; the savings come from computing it fewer times, never from a different
   formula. No reciprocal-multiply substitution for division (`(x+0.5)/w` stays a division) —
   that could change the last ULP before float32 storage on non-power-of-two widths such as 160.
2. **No helper touched that a flat-grid atom probes directly.** `_face_mode_at()` (`:788-810`) is
   called via `probe.call("_face_mode_at", …)` by six atoms (A10 §1.1/:55; verified on disk:
   `t_terrain_only.gd:329`, `t_terrain_trees.gd:459`, `t_combo_all.gd:715`,
   `t_combo_trees_shore.gd:437`, `t_combo_trees_mines.gd:357`, `t_smallmap_terrain.gd:165`).
   It and `DONOR_CDIFF1/2` are **not edited at all**.
3. **B04's relief path is preserved.** `_relief_face_at()` (`:829-858`), both B04 constants
   (`:191-192`), `_relief_promoted_cells` (`:1484-1485`) and the `b04_relief_promotion` stats
   ledger (`:1670-1691`) are untouched. The only change near B04 is hoisting the *value*
   `hmax - hmin` into `relief_span` and passing that identical value. No early-exit guard is
   added (see §5, "considered and rejected").
4. **No signature, API, node, sampler, uniform or stats-shape change.** The only changed
   signature-adjacent fact is that `_repack_mask_alpha()` gains *no* parameter at all (§3 Hunk B).
   `_tile_index_for_name()` keeps its exact signature (Hunk E). The module API
   (`bind/build/invalidate/has_chunk_or_fallback/height_at_world`, A10 §1.1/:47) is unchanged.
5. **No allocation added to the hot path** except the small permanent cache dictionary; the
   change actually *removes* one transient `{}` allocation per grid cell (§3 Hunk C).

---

## 3. Proposed unified diff — `variant3d/scripts/world3d_terrain.gd`

Apply to the **current on-disk working tree** (see §0 version note). Hunks are ordered by file
position for clarity, not by apply order.

```diff
--- a/variant3d/scripts/world3d_terrain.gd
+++ b/variant3d/scripts/world3d_terrain.gd
@@ -340,4 +340,5 @@ var _atlas_texture: Texture2D = null
 var _alpha_tex: Texture2D = null            # donor intensity repacked into ALPHA
 var _alphavert_tex: Texture2D = null        # donor intensity repacked into ALPHA
+var _repack_mask_cache: Dictionary = {}     # P16: source-mask size -> repacked Texture2D; survives invalidate()
 var _atlas_grid := Vector2.ZERO             # (cols, rows) from V7-85 manifest
 var _atlas_info: Dictionary = {}
@@ -694,16 +694,28 @@ func _tileindex_material() -> Material:
 func _repack_mask_alpha(src: Texture2D) -> Texture2D:
 	if src == null or not (src is ImageTexture):
 		return null
+	# P16 — cache keyed by source mask size. The loader's mask assets are fixed
+	# (tile_atlas_loader.gd:485-492, ATLAS_DIR/PARTS_DIR + alpha.png/alphavert.png,
+	# 512x256 and 1024x512), so the key is identical across seasons and rebuilds.
+	# A hit returns the SAME immutable repacked Texture2D: zero pixel work,
+	# byte-identical RGBA to the cold path.
+	var mkey := src.get_size()
+	var hit: Variant = _repack_mask_cache.get(mkey, null)
+	if hit is Texture2D:
+		return hit as Texture2D
 	var img: Image = (src as ImageTexture).get_image()
 	if img == null or img.is_empty():
 		return null
 	img.convert(Image.FORMAT_RGBA8)
 	var w: int = img.get_width()
 	var h: int = img.get_height()
+	mkey = Vector2(w, h)   # normalise key to the converted image's size
 	for y in range(h):
 		for x in range(w):
 			var v: float = img.get_pixel(x, y).r   # donor tiaAlphaFromIntensity
 			img.set_pixel(x, y, Color(v, v, v, v)) # alpha = intensity for V7-86 `.a`
-	return ImageTexture.create_from_image(img)
+	var out := ImageTexture.create_from_image(img)
+	_repack_mask_cache[mkey] = out
+	return out
 
 # V7-86 INTEGRATION CONTRACT (V786_tileindex_shader.md §3.2/§3.3):
@@ -953,5 +965,6 @@ func _tile_index_for_name(tile_name: String) -> int:
 func _tile_index_for_name(tile_name: String) -> int:
 	if tile_name.is_empty():
 		return -1
-	var v: Variant = _tile_name_index.get(tile_name, null)
+	var name_index: Dictionary = _tile_name_index
+	var v: Variant = name_index.get(tile_name, null)
 	return int(v) if v is int else -1
@@ -1079,9 +1092,14 @@ func _decode_tile_indices(dump: Dictionary, w: int, h: int) -> void:
 		return
 	_tile_index_hist = {}
 	_tile_index_out_of_atlas = 0
+	# P16 — hoist the atlas bound; the original `{}` default allocated a temp
+	# Dictionary on EVERY cell when "atlas" was absent. Alias the byte buffer too.
+	var named_cells: int = int(_manifest.get("atlas", {}).get("named_cells", 124))
+	var tids: PackedByteArray = _tile_indices
 	for i in range(want):
-		var tid: int = int(_tile_indices[i])
-		_tile_index_hist[str(tid)] = int(_tile_index_hist.get(str(tid), 0)) + 1
-		if tid >= int(_manifest.get("atlas", {}).get("named_cells", 124)):
+		var tid: int = int(tids[i])
+		var tk: String = str(tid)
+		_tile_index_hist[tk] = int(_tile_index_hist.get(tk, 0)) + 1
+		if tid >= named_cells:
 			_tile_index_out_of_atlas += 1
 
@@ -1094,13 +1112,13 @@ func _decode_tile_indices(dump: Dictionary, w: int, h: int) -> void:
 
 	_tile_prov = {}
 	_tile_prov_cells = 0
 	_tile_prov_dir_hist = {}
 	for z in range(h):
 		for x in range(w):
 			var i: int = z * w + x
-			var c: int = int(_tile_indices[i])
-			var nl: int = int(_tile_indices[z * w + maxi(0, x - 1)])
-			var nr: int = int(_tile_indices[z * w + mini(w - 1, x + 1)])
-			var nt: int = int(_tile_indices[maxi(0, z - 1) * w + x])
-			var nb: int = int(_tile_indices[mini(h - 1, z + 1) * w + x])
+			var c: int = int(tids[i])
+			var nl: int = int(tids[z * w + maxi(0, x - 1)])
+			var nr: int = int(tids[z * w + mini(w - 1, x + 1)])
+			var nt: int = int(tids[maxi(0, z - 1) * w + x])
+			var nb: int = int(tids[mini(h - 1, z + 1) * w + x])
 			var mask: int = 0
@@ -1259,6 +1277,8 @@ func invalidate() -> void:
 	_atlas_loader = null
 	_shader_atlas_loader = null
 	_atlas_texture = null
 	_alpha_tex = null
 	_alphavert_tex = null
+	# P16: _repack_mask_cache is intentionally NOT cleared — the mask assets are
+	# fixed, so a later build() reuses the identical repacked Texture2D.
 	_atlas_grid = Vector2.ZERO
@@ -1381,15 +1401,24 @@ func build() -> bool:
 	var cx: float = float(w) * 0.5
 	var cz: float = float(h) * 0.5
+	# P16 — loop-invariant hoists; every value is identical to the original.
+	var fw: float = float(w)
+	var fh: float = float(h)
+	var relief_span: float = hmax - hmin   # was recomputed per cell at old :1424
+	var fhist: Dictionary = _face_hist
+	var tids: PackedByteArray = _tile_indices
+	var dremap: Dictionary = _desert_remap
+	var name_of_tid: Dictionary = _tile_index_name
 	var max_tile_id: int = int(_manifest.get("atlas", {}).get("named_cells", 124)) - 1
 	# SP-6 — Desert-only; Summer and Winter cells are never remapped, so those
 	# builds (UV2, face_hist, mesh counts) stay byte-identical.
 	var season_is_desert: bool = (_season_resolved == "desert")
 	_face_hist = {"0": nverts}
 	for z in range(h):
+		var row: int = z * w
+		var zc: float = (float(z) + 0.5 - cz) * TILE_M
+		var zuv: float = (float(z) + 0.5) / fh
 		for x in range(w):
-			var i: int = z * w + x
-			verts[i] = Vector3((float(x) + 0.5 - cx) * TILE_M,
-				height[i] * HEIGHT_SCALE,
-				(float(z) + 0.5 - cz) * TILE_M)
-			uvs[i] = Vector2((float(x) + 0.5) / float(w),
-				(float(z) + 0.5) / float(h))
+			var i: int = row + x
+			verts[i] = Vector3((float(x) + 0.5 - cx) * TILE_M,
+				height[i] * HEIGHT_SCALE, zc)
+			uvs[i] = Vector2((float(x) + 0.5) / fw, zuv)
@@ -1404,3 +1433,3 @@ func build() -> bool:
 			# (texturemap.inc:463-472,503-511) instead of to grass1.
-			var raw_tid: int = int(_tile_indices[i]) if tiles_available else 0
+			var raw_tid: int = int(tids[i]) if tiles_available else 0
 			var water_sentinel: bool = tiles_available and raw_tid > max_tile_id
@@ -1422,5 +1451,5 @@ func build() -> bool:
 			if face == 0 and not shore_gate:
 				var relief_face: int = _relief_face_at(
-					height, w, h, x, z, hmax - hmin)
+					height, w, h, x, z, relief_span)
 				if relief_face != 0:
 					face = relief_face
@@ -1458,3 +1487,3 @@ func build() -> bool:
 				# exact. No new art, no foam, no water-literal change.
-				var base_name: String = str(_tile_index_name.get(tid, ""))
+				var base_name: String = str(name_of_tid.get(tid, ""))
 				if (water_sentinel or base_name.begins_with("sandsea")
@@ -1487,6 +1516,6 @@ func build() -> bool:
 			norms[i] = _tilt_face_normal(_normal_at(height, w, h, x, z), face)
 			if face != 0:
 				var fk: String = str(face)
-				_face_hist[fk] = int(_face_hist.get(fk, 0)) + 1
-				_face_hist["0"] = int(_face_hist["0"]) - 1
+				fhist[fk] = int(fhist.get(fk, 0)) + 1
+				fhist["0"] = int(fhist["0"]) - 1
 
 			# SP-6 / SP-3 — DESERT name remap, applied to the resolved tile id
@@ -1500,6 +1529,6 @@ func build() -> bool:
 			# and DALPHA-02's shader keeps its index-preserving contract.
-			if season_is_desert and tiles_available and _desert_remap.has(tid):
-				var remapped: int = int(_desert_remap[tid])
+			if season_is_desert and tiles_available and dremap.has(tid):
+				var remapped: int = int(dremap[tid])
 				if remapped >= 0 and remapped <= max_tile_id:
 					tid = remapped
 					_desert_remap_cells += 1
```

### 3.1 Note on the `@@` headers

The right-hand `+nnn` line numbers are **indicative and were not recounted** (the early hunks
still use the old-line number, later ones approximate the running offset). Do not rely on them:
apply with `git apply --recount`, which recomputes offsets from the exact context; fuzzy context
matching then locates each hunk (the `-`/`+` bodies and context lines themselves are copied
verbatim from the current on-disk file). The context lines and
`-`/`+` bodies are copied verbatim from the current on-disk file; implementers should apply with
`git apply --recount` or review each hunk by its context before committing. This is a design
proposal, not a tested patch — NO apply, NO Godot parse was performed by P16.

---

## 4. Invariant proof (A10 §4 mapping)

| A10 DO-NOT-TOUCH / NEEDS-CARE invariant | Proof from the diff |
|---|---|
| `surface_count == 1`, `vertex_count == 4096`, `triangle_count == 7938`, `uv2_count == 4096` (P0 :522-526, C4 :634-673, season) | `nverts`/`ntris` (`:1369-1370`), all five `resize()` calls (`:1371-1380`), the index loop (`:1508-1518`), the single `add_surface_from_arrays()` (`:1528`) and `arrays[...]` bindings (`:1520-1526`) are untouched. Hunk D changes only the RHS of `verts[i]`/`uvs[i]`, to the identical double values; `row + x == z * w + x` for all `z,x`. |
| UV2.x integral `[0,123]`; UV2.y ∈ {0,1,2}; `face_hist_sum == 4096`; `tile_index.cells == 4096` | `uvs2[i] = Vector2(float(tid), float(face))` (`:1507`) is untouched. `tid` resolution (`:1405-1505`) differs only by local aliases (`tids`, `name_of_tid`, `dremap`) pointing to the exact same objects; `face` computation is untouched except that `_relief_face_at` receives `relief_span == hmax - hmin`, the identical value previously evaluated inline. `fhist` **is** `_face_hist` (same Dictionary object), so `fhist[fk] = int(fhist.get(fk,0))+1` and `fhist["0"] -= 1` perform the same key writes as before; the histogram remains a partition of `nverts`. |
| `flat_grid_promoted == 0` / `flat_face_zero == 0` (FIX-TERRAIN §8) | `_face_mode_at()` and `DONOR_CDIFF1/2` are byte-identical (A10 §1.1/:55, six direct-probe atoms). `_relief_face_at()`'s first statement (`:831-832`) still returns 0 when `span <= 0`; a flat grid has `hmax == hmin`, so `relief_span == 0` and the hoisted value cannot change that. No threshold, comparison or early return was edited. |
| `atlas_grid == [16,8]`; three samplers bound; `shadow_enabled == 0` | `_load_atlas()` and `_tileindex_material()` (`:605-691`, `:714-753`) are untouched except the two call sites `:671-672` keep calling `_repack_mask_alpha` with the same arguments. Hunk B returns, on a hit, the *same immutable* `ImageTexture.create_from_image()` result the cold path would have produced from the same fixed grayscale source; on a miss it executes the old loop verbatim. Sampler names and `atlas_grid` are unchanged. |
| `WATER_LEVEL = -0.25`, `BLK_WATER = 255`, `DONOR_SHORE_H = -0.1`, single height-aware water plane, `DonorSun.shadow_enabled=false`, `mi.cast_shadow=OFF` | No constant, water node or light assignment is edited (`:152-153`, `:213`, `:1180-1186`, `:1240`, `:1555`, `:1561-1564`). |
| B04 relief promotion (B04 §4) | `_relief_face_at()`, `B04_RELIEF_GATE_FRACTION`, `B04_MIN_GATE`, `_relief_promoted_cells`, `elevated` rock gates and the `b04_relief_promotion` ledger are byte-identical. Only the *argument expression* is hoisted; `relief_span` is assigned after the optional relief-stamp recompute of `hmin/hmax` (`:1331-1337`) and before the mesh loop, so it sees the same final span that `:1424` saw on every iteration. |
| Season index preservation: tileblock byte-identical, summer/winter UV2.x identical, desert 1:1 remap | No byte of `_tile_indices` (or `dump["tileblock"]`) is written anywhere; Hunk C only *reads* it for stats. `named_cells` is read from the same `_manifest` as before (same season resolution) and used in the same strict `>=` comparison. `dremap` is the same `_desert_remap` Dictionary; `dremap.has(tid)` / `dremap[tid]` are the identical lookups. |
| `height_at_world` 0.001 m / resource-Y 0.02 m | `_height = height`, `_w = w`, `_h = h`, `_built = true` (`:1566-1569`) and `height_at_world()` (`:1850-…`) are untouched; no vertex Y value changes (`zc` replaces only the Z component expression with its own identical value, `height[i]*HEIGHT_SCALE` stays). |
| Harness/governance: no test weakened, no marker flipped, no synthetic noise, no donor constant invented | No test, shader, `game.gd`, loader or `app/**` file edited. No threshold/assertion/`expected_pre_fix_failure` touched. The new numbers are zero: every literal in the diff already existed in the file (`124`, `TILE_M`, `0.5`), and the cache key is a runtime size, not a donor constant. Donor parity remains UNVERIFIED. |
| Render-mode 2D hard gate (`t_render_mode.gd:5,80,118`) | `main.gd` and the 2D constructors are not in P16 scope and are untouched. |

**Net:** the diff is a pure build-time *schedule* change. It removes repeated evaluations and
member lookups; it does not add, delete or revalue a single byte of the mesh, UV2, stats-key set,
sampler binding or dump data. All visual/PORT-APPROX gates in A10 §2 (luma floors, dark rows/cols,
non-black) must therefore be bit-stable — but **this is a DERIVED prediction from code, not a
measured result** (§6).

---

## 5. Cost estimates (analytical only — INFERRED / UNVERIFIED)

All figures below are counts of interpreter operations, derived from the current source and the
grid sizes. No stopwatch, capture, profiler or `nvidia-smi` was run (P16 has no Godot). They are
**INFERRED operation counts**; any millisecond translation is **UNVERIFIED**.

| Change | Operation saving on a rebuild (cache hit) | INFERRED impact | Confidence |
|---|---|---|---|
| B: mask cache | 655,360 `get_pixel` + 655,360 `set_pixel` calls → 1 `Dictionary.get`. Cold first build: **no saving** (miss). | Potentially the largest of the P16 items: a GDScript per-pixel loop over 0.66 M pixels is plausibly in the low-to-tens of ms; second and later `build()` in the same node avoid it entirely. | Operation count DERIVED; ms **UNVERIFIED**. |
| C: `named_cells` hoist + `str(tid)` once | 25,600 (or 102,400) transient `{}` allocations + 2 hash lookups + 1 redundant `str` per cell removed. | Small; sub-ms to low-ms is plausible. At 320² the removed temporary-dict churn is 4×. | Count DERIVED; allocation cost in Godot 4 GDScript **UNVERIFIED**. |
| C: provenance `tids` alias | 5 member-name lookups/cell → 1 alias read. | Small. | Count DERIVED; ms **UNVERIFIED**. |
| D: per-row `zc` / `zuv` / `row` hoist | `h` instead of `w*h` evaluations of each z-invariant expression: at 160², 160 vs 25,600 (×160 reduction for those three expressions). | Small-to-moderate; helper calls (`_face_mode_at`, `_relief_face_at`, `_normal_at`, `_tilt_face_normal`, donor name lookups) still dominate the loop and are deliberately untouched. | Count DERIVED; ms **UNVERIFIED**. |
| D: `relief_span` hoist | 25,600 (or 102,400) double subtractions → 1. | Negligible alone. | DERIVED. |
| D/E: dict/member aliases in hot path | ~3 `fhist` lookups per promoted cell, 2 `dremap`, 1 `name_of_tid` per shore cell, 1 `_tile_name_index` per name lookup → local reads. | Depends on promoted-cell count (B04 §6: ~500–1,361 on synthetic fields, **UNVERIFIED** on real maps). Likely small. | DERIVED; ms **UNVERIFIED**. |
| **Total** | — | **INFERRED: a modest reduction of `stats.timing_ms.mesh_build` and of repeat-build time; not a fix for the dominant mip/decode stall (P06 Blocker 1). No FPS claim is made.** | **UNVERIFIED** — requires a real capture/telemetry (P09) to quantify. |

**Considered and rejected (do not add to the diff):** guarding the `_relief_face_at()` call with
`if relief_span > 0.0` would be logically equivalent (the helper returns 0 at its first line), and
would skip ~25,600 calls on the flat test grids; but it edits B04's call-site structure and adds a
second condition to a path that A10 §4 marks NEEDS-CARE. P16 chooses the safer subset: hoist the
value only, leave the call unconditionally structured as B04 shipped it. Similarly rejected:
replacing `/(float(w))` with `* (1.0/float(w))` (ULP/byte-stability risk on width 160) and any
`await` between row bands (§1).

---

## 6. Open questions / UNVERIFIED register

1. No Godot run, capture, frame time, VRAM read or `git apply` test. Everything in §5 is static.
   FPS claims require a real capture/run (WAVE_G_CHARTER Wave P); none exists for P16.
2. Whether the mask cache actually hits in the **first** load: `invalidate()` is called at the top
   of `build()` (`:1303`), but the cache is not cleared, so a first build is a miss and a rebuild
   via `set_atlas_mode()` (`:396-406`) is a hit. A *new scene instance* starts with an empty
   cache — cross-instance reuse would need a `static` cache and an owner decision on texture
   lifetime; **not proposed here**. The benefit is therefore limited to repeat builds inside one
   terrain node. **UNVERIFIED** how often that occurs in a real session.
3. Mask key collision risk if a future asset pair has identical source sizes (§2.1). Today the
   sizes are distinct (512×256 vs 1024×512, `:1766`). Fix then by passing an explicit slot key —
   which would change `_repack_mask_alpha`'s signature and needs its own ticket.
4. `ImageTexture.create_from_image()` upload/GPU-side timing is outside P16 (P06 §6 #2).
5. GDScript interpreter costs (member lookup, `{}` allocation, `str()`) are **UNVERIFIED** without
   a profile; the rationale is "strictly fewer operations of the same kind", not a benchmark.
6. Donor parity stays **UNVERIFIED** (CHARTER §3; A10 §5). This diff does not attempt it.
7. The atoms/gates must still be re-run by the sole runner owner (G04) after any implementation;
   P16 supplies no gate result and does not flip any known-gap marker (A10 §3).

---

## 7. Backup and handoff instruction (for the eventual implementer — NOT executed by P16)

P16 made **no edit and created no backup**; this section is the required instruction for whoever
COORD assigns to implement the diff.

1. **Before the first edit**, copy the current on-disk file verbatim to:
   `inbox/backup/world3d_terrain.gd.bak-P16`.
   The source is the *working tree* copy (B04's uncommitted edits included, §0), not
   `git show HEAD:variant3d/scripts/world3d_terrain.gd`.
2. **Do not touch** the existing `inbox/backup/world3d_terrain.gd.bak-B04` (B04 §0/:26,
   G13's audit scope).
3. Apply **only** the hunks in §3 to `variant3d/scripts/world3d_terrain.gd` (the sole file in
   P16 scope). No shader, `game.gd`, loader, `main.gd`, test, config or `app/**` edit — that keeps
   ownership disjoint from P01–P12, B01–B06 and Wave H/M.
4. Verify statically (no Godot): bracket/paren/brace balance over the edited file; re-read the
   nine invariants in §4 against the applied text; confirm `_face_mode_at()` (`:788-810`) is
   byte-identical to the backup and `_relief_face_at()` (`:829-858`) differs only in the caller's
   argument expression.
5. Hand gates to COORD/G04 (only runner owner): `t_terrain_only`, `t_combo_all`
   (with and without `--no-shore`), `t_season_overlay`, `t_render_mode`, selftest 29/29,
   uitest 17/17, `assert_clean CLEAN`, then a fresh windowed capture with a second-agent visual
   read. Expected structural result stays `1 / 4096 / 7938 / 4096`, `flat_grid_promoted == 0`,
   `face_hist_sum == 4096`, `tileblock` bytes unchanged. **No marker or threshold is relaxed.**
6. If any atom regresses, revert from `world3d_terrain.gd.bak-P16` in full; do not partially
   re-apply hunks to "make a gate green" (CHARTER §3 / A10 §3).

---

*End of P16 report. One report; no source edit; no backup created; no Godot, no runner, no donor access, no FPS or donor-parity claim.*
