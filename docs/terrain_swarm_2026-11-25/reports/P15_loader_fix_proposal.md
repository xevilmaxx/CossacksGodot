---
id: P15-LOADER-FIX-PROPOSAL
ticket: TERRAIN-SWARM-2026-11-25 / Wave P / P15 (ready-to-apply diff proposals; READ-ONLY)
date: 2026-11-25
status: PROPOSAL__READ_ONLY__NO_CODE_EDITS__NO_GODOT_JOBS
labels: [observed, derived, inferred, UNVERIFIED]
files_created:
  - docs/terrain_swarm_2026-11-25/reports/P15_loader_fix_proposal.md
files_edited: []
godot_jobs_run: 0
runner_jobs_submitted: 0
backups_taken: 0
parity_guard: "No Godot run, no capture and no frame-time measurement was made. Every time/VRAM/throughput figure is carried over from G17/G23/P06 and stays UNVERIFIED until profiled on the real MX130 windowed context. Nothing here is a benchmark, an FPS claim, or a donor-parity claim (CHARTER §3)."
scope_guard: "READ-ONLY per ticket. COORD grants exclusive file ownership AFTER G04; until then no diff below has been applied. Only G04 runs Godot/runner jobs (WAVE_G_CHARTER § 'Only G04 submits runner jobs')."
---

# P15 — ready-to-apply diff proposals: worker-thread atlas mips, vectorised/cached mask repack, load readiness assertion

## 0. Scope compliance and inputs

Exactly one file created (this report). **No code, shader, config, test, manifest or runner file was edited; no Godot process started; no runner job submitted; no backup taken (backups are a requirement of the implementation grant, §6).**

Read in full before writing this report, as directed: `docs/terrain_swarm_2026-11-25/WAVE_G_CHARTER.md` (Wave P table), `docs/terrain_swarm_2026-11-25/CHARTER.md`, `reports/G17_perf_audit.md`, `reports/G23_loading_design.md`, `reports/P06_loading_path.md`.

Source verified directly on the on-disk working tree (all line numbers below are **OBSERVED, current on disk**):

| File | Sections read |
|---|---|
| `variant3d/scripts/tile_atlas_loader.gd` | all 494 lines (`load()` :174-200, `_load_single()` :280-290, `get_atlas_texture()` :208-211, `_prepare_atlas_image()` :350-356, `_load_split()` :359-421, `_load_array()` :427-479, `_load_masks()` :482-494, var block :80-96) |
| `variant3d/scripts/world3d_terrain.gd` | var block :327-378, `_load_atlas()` :605-691, `_repack_mask_alpha()` :694-707, `_tileindex_material()` :714-739, `invalidate()` :1250-1298, `build()` :1301-1374 |
| `variant3d/scripts/main.gd` | var block :145-164, overlay helpers :462-533, `_do_async_load()` :535-676 |
| `variant3d/scripts/world3d.gd` | `bind()` :599-659 (read only — **not P15-owned**) |

**Version caveat (OBSERVED):** the on-disk `main.gd` already carries LOAD-ASYNC-01 (`load_ready` :157, warm `world.sync(0.0)` :661-662, `RenderingServer.frame_post_draw` hold :667-670, readiness comment :671-674). G17/UX_LOADING quote older line numbers for the same code. These diffs target the **on-disk** state; any implementer must re-read before applying, because reports are fixed artifacts, not live state.

---

## 1. What this fixes, in P06/G17/G23 terms

| P06 blocker | Owner file | Diff |
|---|---|---|
| **Blocker 1** — `generate_mipmaps(false)` at `tile_atlas_loader.gd:353` is a synchronous main-thread block inside the 0.90 stage (`main.gd:584-589` → `world3d.gd:639` → `world3d_terrain.gd:1341/651` → loader `:285`/`:416`) | `tile_atlas_loader.gd` | §2 Diff A — add `load_async()` with worker-thread mip build; sync `load()` untouched |
| **Blocker 2** — `_repack_mask_alpha()` `world3d_terrain.gd:703-706` does **655,360** `get_pixel`/`set_pixel` pairs (512×256 + 1024×512) inside `terrain.build()` | `world3d_terrain.gd` | §3 Diff B — SHA-keyed cache + byte-level swizzle; atlas grid/sampler/mesh untouched |
| **Blocker 3 / S4 gap** — `load_ready` is a passive flag, `_hide_loading()` at `main.gd:676` is unconditional with no subsystem assertion (UX_LOADING R4) | `main.gd` | §4 Diff C — explicit `_assert_load_ready(gen)` gate before `load_ready = true` / `_hide_loading()` |
| Await-chain link that is **NOT** in P15's exclusive ownership | `world3d.gd` | §5 required companion handoff (diff supplied, but must be granted to a separate owner / integrated by COORD) |

**No donor-parity claim, no synthetic dither/noise, no level-0 pixel change, no shader edit, no `app/` edit, no test weakening.** Diff A preserves level-0 bytes **by construction**: the worker calls the identical `img.generate_mipmaps(false)` on the identical decoded local `Image`; only the executing thread changes (G23 §4 Option A, invariant 1).

---

## 2. Diff A — `variant3d/scripts/tile_atlas_loader.gd` (exclusive owner: P15)

**Backup before apply:** `inbox/backup/tile_atlas_loader.gd.bak-P15` (matches `.bak-B02` / `.bak-G23` convention).

Design rules honoured (G23 §3/§4 Option A):

- `load()` / `load_atlas()` / `_load_single()` / `_load_split()` / `_load_array()` / `_prepare_atlas_image()` are **not modified** — headless and test callers (`loader.call("load")`, `world3d_terrain.gd:651`) keep identical timing, return value and bytes.
- `load_async()` mirrors `load()`'s mode resolution **and** `single → split → array` fallback order verbatim; the only substituted operation is `_prepare_atlas_image()` → `_prepare_atlas_image_async()`.
- `MODE_ARRAY` stays byte-identical (no mips, pre-existing gap — G17 §3.2).
- `ImageTexture.create_from_image()` stays on the **main thread**.
- Entries added to `get_reassembly_info()`/mask API: **none**. `atlas_grid()`, `tile_uv()`, `tile_layer()`, index→slot maps, SP-5 overrides and SP-6 season pair untouched.
- Guarded degradation: if `WorkerThreadPool.add_task()` fails, fall back to the **original synchronous** `_prepare_atlas_image()` call and emit a warning (correctness first, S3 second).
- Generation guard: the loader has no `loading_gen`; the awaited caller chain (`main.gd`, Diff C) performs the `gen != loading_gen` check after the await. No stale atlas can be bound or overlay hidden.

### A.1 — new state and worker helper (append to end of var block, after line 96)

```diff
--- a/variant3d/scripts/tile_atlas_loader.gd
+++ b/variant3d/scripts/tile_atlas_loader.gd
@@ -94,3 +94,9 @@
 	var _loaded := false
 	var _reassembled_bytes := 0
 	var _reassembled_sha256 := ""
+	# P15 / G23 Option A — worker-thread mip state. Only load_async() uses these;
+	# the synchronous load() path never reads or writes them. The strong
+	# reference _async_img is held on the main thread for the task's lifetime.
+	var _async_img: Image = null
+	var _async_task: int = -1
+	var _mip_err: int = OK
```

### A.2 — worker body + async prepare + async load entry point (insert after `_prepare_atlas_image()`, i.e. after line 356, before `_load_split()` at :359)

```diff
--- a/variant3d/scripts/tile_atlas_loader.gd
+++ b/variant3d/scripts/tile_atlas_loader.gd
@@ -355,2 +355,97 @@
 		push_warning("TileAtlasLoader: atlas mipmap generation failed (error %d); texture stays base-level only" % err)
 	return img
+
+
+# P15 — worker entry point. Runs generate_mipmaps(false) on the SAME Image with
+# the SAME arguments as _prepare_atlas_image() (:353). Level 0 is never written
+# by generate_mipmaps, so the base pixels stay byte-identical (G23 invariant 1).
+# UNVERIFIED: Godot Image operations from a worker thread must be proven on a
+# real windowed run before any freeze improvement is claimed (G17 §7 #3).
+func _build_mips_worker() -> void:
+	if _async_img == null or _async_img.has_mipmaps():
+		return
+	_mip_err = _async_img.generate_mipmaps(false)
+
+
+# P15 — async twin of _prepare_atlas_image(). Returns the SAME Image object;
+# the only difference is that the mip build runs on a WorkerThreadPool worker
+# while the main thread yields process_frame (keeps the Windows message pump
+# alive at the 0.90 "Loading art..." stage). p_tree == null => headless/sync:
+# wait_for_task_completion() so tests get the identical synchronous result.
+func _prepare_atlas_image_async(img: Image, p_tree: SceneTree) -> Image:
+	if img.has_mipmaps():
+		return img  # same guard as :351 — custom/DDS source left untouched
+	_async_img = img
+	_mip_err = OK
+	_async_task = WorkerThreadPool.add_task(
+		Callable(self, "_build_mips_worker"), false, "tile-atlas-mips")
+	if _async_task < 0:
+		# Guarded degradation: never lose mips because the pool was unavailable.
+		push_warning("TileAtlasLoader: mip worker unavailable; generating synchronously")
+		var err_sync := img.generate_mipmaps(false)
+		if err_sync != OK:
+			push_warning("TileAtlasLoader: atlas mipmap generation failed (error %d); texture stays base-level only" % err_sync)
+		_async_img = null
+		return img
+	if p_tree == null:
+		WorkerThreadPool.wait_for_task_completion(_async_task)
+	else:
+		while not WorkerThreadPool.is_task_completed(_async_task):
+			await p_tree.process_frame
+	if _mip_err != OK:
+		# Same warning text as :355 — the fallback behaviour is unchanged.
+		push_warning("TileAtlasLoader: atlas mipmap generation failed (error %d); texture stays base-level only" % _mip_err)
+	_async_task = -1
+	_async_img = null
+	return img
+
+
+# P15 / G23 Option A — async entry point. Byte-for-byte mirror of load()
+# (:174-200): same mode resolution, same single -> split -> array order, same
+# _soft_fail/_fail warnings, same _reset() points. Only the mip preparation is
+# swapped. Callers MUST await this function; the sync load() stays sync for
+# headless/tests and for any caller that cannot await (G23 §4 rule 1).
+func load_async(p_tree: SceneTree, p_mode: String = "") -> bool:
+	var target := p_mode.strip_edges()
+	if not target.is_empty():
+		set_mode(target)
+	_reset()
+	last_error = ""
+
+	if mode == MODE_ARRAY:
+		return _load_array()  # unchanged: array mode has no mips (G17 §3.2)
+	if mode == MODE_SPLIT:
+		return await _load_split_async(p_tree)
+
+	# MODE_SINGLE (default): same transport and path-with-spaces handling as
+	# load() (:186-188); only the mip step is worker-backed.
+	if await _load_single_async(p_tree):
+		return true
+	var single_reason := last_error
+	push_warning("TileAtlasLoader: single atlas unavailable (%s); falling back to 'split'" % single_reason)
+	_reset()
+	mode = MODE_SPLIT
+	if await _load_split_async(p_tree):
+		return true
+	var split_reason := last_error
+	push_warning("TileAtlasLoader: split atlas unavailable (%s); falling back to 'array'" % split_reason)
+	_reset()
+	mode = MODE_ARRAY
+	return _load_array()
+
+
+# P15 — async twin of _load_single() (:280-290). One deliberate difference:
+# _prepare_atlas_image() -> await _prepare_atlas_image_async(). Everything else
+# (grid, path, null/soft-fail handling, masks, _loaded) is unchanged.
+func _load_single_async(p_tree: SceneTree) -> bool:
+	_load_grid()
+	var img := _load_image_at(single_atlas_path)
+	if img == null:
+		return _soft_fail("single atlas unavailable: " + last_error)
+	var prepared := await _prepare_atlas_image_async(img, p_tree)
+	_atlas_texture = ImageTexture.create_from_image(prepared)  # MAIN thread
+	if _atlas_texture == null:
+		return _soft_fail("ImageTexture.create_from_image failed for " + single_atlas_path)
+	_load_masks()
+	_loaded = true
+	return true
```

### A.3 — async twin of `_load_split()` (append after A.2, still before `_load_split()` or after it — placement is free)

```diff
--- a/variant3d/scripts/tile_atlas_loader.gd
+++ b/variant3d/scripts/tile_atlas_loader.gd
@@ -474,2 +474,75 @@
 
 # ---------------------------------------------------------------------------
+# P15 — async twin of _load_split() (:359-421). This is a LINE-FOR-LINE copy of
+# the reassembly/SHA-256/cache/PNG-load logic; the ONLY intentional difference
+# is the mip-preparation call. It MUST be kept in lockstep with _load_split():
+# any future fix to reassembly must be mirrored here. Invariants preserved:
+# byte count + whole-file SHA-256 verification, unsafe-part-name guard,
+# user:// cache, _reassembled_bytes/_reassembled_sha256, mask loading.
+func _load_split_async(p_tree: SceneTree) -> bool:
+	var manifest := _read_json(SPLIT_MANIFEST)
+	if manifest.is_empty():
+		return _fail("split manifest unavailable: " + last_error)
+	_load_grid()
+	var src: Dictionary = manifest.get("source", {})
+	var expected_hash := str(src.get("sha256", ""))
+	var expected_bytes := int(src.get("bytes", 0))
+	var parts: Array = manifest.get("parts", [])
+	if expected_hash.is_empty() or expected_bytes <= 0 or parts.is_empty():
+		return _fail("split manifest missing source hash/bytes or parts")
+
+	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CACHE_DIR))
+	var out := FileAccess.open(CACHE_FILE, FileAccess.WRITE)
+	if out == null:
+		return _fail("cannot open user:// cache for writing (error %d)"
+				% FileAccess.get_open_error())
+
+	var ctx := HashingContext.new()
+	if ctx.start(HashingContext.HASH_SHA256) != OK:
+		out.close()
+		return _fail("HashingContext SHA-256 unavailable")
+	var total := 0
+	for entry in parts:
+		if not entry is Dictionary:
+			out.close()
+			return _fail("malformed part entry")
+		var name := str(entry.get("name", ""))
+		if name.is_empty() or name.contains("..") or name.contains("/") or name.contains("\\"):
+			out.close()
+			return _fail("unsafe part name: " + name)
+		var pf := FileAccess.open(PARTS_DIR + name, FileAccess.READ)
+		if pf == null:
+			out.close()
+			return _fail("cannot read part: " + name)
+		while not pf.eof_reached():
+			var chunk := pf.get_buffer(CHUNK)
+			if chunk.is_empty():
+				break
+			ctx.update(chunk)
+			out.store_buffer(chunk)
+			total += chunk.size()
+		pf.close()
+	out.close()
+
+	var got := ctx.finish().hex_encode()
+	_reassembled_bytes = total
+	_reassembled_sha256 = got
+	if total != expected_bytes or got != expected_hash:
+		DirAccess.remove_absolute(ProjectSettings.globalize_path(CACHE_FILE))
+		return _fail("reassembly mismatch: bytes=%d/%d sha=%s/%s"
+				% [total, expected_bytes, got, expected_hash])
+
+	var img := Image.new()
+	var err := img.load(ProjectSettings.globalize_path(CACHE_FILE))
+	if err != OK:
+		return _fail("Image.load_from_file failed (error %d)" % err)
+	var prepared := await _prepare_atlas_image_async(img, p_tree)
+	_atlas_texture = ImageTexture.create_from_image(prepared)  # MAIN thread
+	if _atlas_texture == null:
+		return _fail("ImageTexture.create_from_image failed")
+	_load_masks()
+	_loaded = true
+	return true
+
+
+# ---------------------------------------------------------------------------
```

> **Why duplication instead of refactoring `_load_split()`:** the ticket requires the synchronous fallback chain to remain byte-identical. A shared "prepare hook" would have to be threaded through the sync functions, which risks perturbing the exact warning/fallback order that P06 §2 and G23 invariant 2 protect. Duplication is more lines but strictly safer for the byte-identity requirement; the lockstep comment makes drift explicit.

---

## 3. Diff B — `variant3d/scripts/world3d_terrain.gd` (exclusive owner: P15)

**Backup before apply:** `inbox/backup/world3d_terrain.gd.bak-P15`.

Two independent, additive changes:

**B1 — vectorise + cache `_repack_mask_alpha()` (P06 Blocker 2).** The original at `:703-706` performs 655,360 `get_pixel()`/`set_pixel()` calls, each constructing a `Color` and doing bounds/mip checks. The replacement swizzles the RGBA8 byte buffer directly: `data[i*4+0..3] = data[i*4]`. **Byte-for-byte identical output** — the old path reads `v = byte/255` then writes `round(v*255) = byte`; the new path writes the byte directly. The SHA-256 keyed cache means a scene reload (`invalidate()` → `build()`) skips the repack entirely when the source mask bytes are unchanged.

Invariants preserved: `_alpha_tex`/`_alphavert_tex` still `ImageTexture`s bound to `alpha_atlas`/`alphavert_atlas` at `:722-723`; `_atlas_grid` (`:661`) and the three sampler names (`:721-723`) are not touched; no mesh/topology/UV2 change; no threshold lowered. `invalidate()` deliberately does **not** clear the cache (that is the point), but it is bounded to one entry per distinct mask payload (two entries in practice).

**B2 — async handshake inside this file** (required for Diff A to be reachable): make `_load_atlas()` and `build()` accept an opt-in `p_async` flag. Default `false` keeps the synchronous path (and all headless gates) **byte-identical**; when `true`, `_atlas_loader.load_async(get_tree())` is awaited. The `await` only executes in the async branch, so sync callers get a plain `bool` return.

### B.1 — add cache field (after line 378, before the blank lines at :379-380)

```diff
--- a/variant3d/scripts/world3d_terrain.gd
+++ b/variant3d/scripts/world3d_terrain.gd
@@ -376,2 +376,8 @@
 # RELIEF-01 — audit ledger for opt-in stamp calls (no mesh state).
 var _relief_applied: Array = []
+
+# P15 — season-stable repack cache. NOT cleared by invalidate(): skipping the
+# 655,360-pixel repack on a scene reload is the whole point. Keyed by a SHA-256
+# of the post-convert source bytes, so a genuinely different mask still
+# repacks. Read-only w.r.t. atlas grid / samplers / mesh invariants.
+var _mask_alpha_cache: Dictionary = {}
```

### B.2 — vectorised + cached repack (replace lines 694-707)

```diff
--- a/variant3d/scripts/world3d_terrain.gd
+++ b/variant3d/scripts/world3d_terrain.gd
@@ -691,16 +691,45 @@
 
 
 func _repack_mask_alpha(src: Texture2D) -> Texture2D:
 	if src == null or not (src is ImageTexture):
 		return null
 	var img: Image = (src as ImageTexture).get_image()
 	if img == null or img.is_empty():
 		return null
 	img.convert(Image.FORMAT_RGBA8)
 	var w: int = img.get_width()
 	var h: int = img.get_height()
-	for y in range(h):
-		for x in range(w):
-			var v: float = img.get_pixel(x, y).r   # donor tiaAlphaFromIntensity
-			img.set_pixel(x, y, Color(v, v, v, v)) # alpha = intensity for V7-86 `.a`
-	return ImageTexture.create_from_image(img)
+	# P15 — cache first. Signature is computed on the post-convert RGBA8 bytes,
+	# which are deterministic across calls, so a reload of an unchanged mask
+	# costs one C-level SHA-256 pass and zero GDScript pixel loops.
+	var key := _mask_alpha_signature(img, w, h)
+	if _mask_alpha_cache.has(key):
+		return _mask_alpha_cache[key]
+	# P15 — byte-level swizzle instead of 655,360 get_pixel/set_pixel Color pairs.
+	# FORMAT_RGBA8 is 4 tightly packed bytes/pixel (R,G,B,A). Donor
+	# tiaAlphaFromIntensity => every channel = R. The old path read
+	# v = float(byte)/255 and wrote round(v*255) = byte; writing the byte
+	# directly is byte-for-byte identical (no colour value invented).
+	var data: PackedByteArray = img.get_data()
+	if data.size() < w * h * 4:
+		return null
+	for i in range(w * h):
+		var v: int = data[i * 4]
+		data[i * 4 + 1] = v
+		data[i * 4 + 2] = v
+		data[i * 4 + 3] = v
+	img.set_data(w, h, false, Image.FORMAT_RGBA8, data)
+	var tex := ImageTexture.create_from_image(img)
+	_mask_alpha_cache[key] = tex
+	return tex
+
+
+func _mask_alpha_signature(img: Image, w: int, h: int) -> String:
+	# Exact (no sampling/collision risk): SHA-256 over the full RGBA8 payload.
+	# If HashingContext is unavailable, fall back to dimensions only — that
+	# only loses cache hits, never changes bytes.
+	var ctx := HashingContext.new()
+	if ctx.start(HashingContext.HASH_SHA256) != OK:
+		return "%dx%d:nohash" % [w, h]
+	ctx.update(img.get_data())
+	return "%dx%d:%s" % [w, h, ctx.finish().hex_encode()]
```

### B.3 — opt-in async flag on `_load_atlas()` (modify line 605 and lines 651-654)

```diff
--- a/variant3d/scripts/world3d_terrain.gd
+++ b/variant3d/scripts/world3d_terrain.gd
@@ -602,7 +602,7 @@
 # ---------------------------------------------------------------------------
 # V7-92 — V7-91 loader + V7-86 material bindings.
 # ---------------------------------------------------------------------------
-func _load_atlas() -> bool:
+func _load_atlas(p_async: bool = false) -> bool:
 	_atlas_texture = null
 	_alpha_tex = null
 	_alphavert_tex = null
@@ -648,6 +649,13 @@
 	if _atlas_loader == null:
 		return false
-	if not bool(_atlas_loader.call("load")):
+	# P15 — opt-in worker-backed mips. Default (false) keeps the exact sync
+	# call and byte-identical behaviour for headless gates and test doubles.
+	var load_ok: bool = false
+	if p_async:
+		load_ok = bool(await _atlas_loader.load_async(get_tree()))
+	else:
+		load_ok = bool(_atlas_loader.call("load"))
+	if not load_ok:
 		push_error("world3d_terrain: atlas load(%s) failed: %s" % [
 			atlas_mode, str(_atlas_loader.call("get_last_error"))])
 		return false
```

> Everything after `:655` (chosen mode, `_atlas_grid`, `_atlas_info`, mask repack at `:671-672`, the split fallback at `:682-687`) is **unchanged** and now simply runs after the awaited mip completion, so `_atlas_texture` is never bound half-built.

### B.4 — opt-in async flag on `build()` (modify line 1301 and line 1341)

```diff
--- a/variant3d/scripts/world3d_terrain.gd
+++ b/variant3d/scripts/world3d_terrain.gd
@@ -1298,6 +1298,6 @@
 
 
 # EXACT CONTRACT: one full-grid ArrayMesh from the base64 dump height[] grid.
-func build() -> bool:
+func build(p_async: bool = false) -> bool:
 	var t_total := Time.get_ticks_usec()
 	invalidate()
@@ -1338,4 +1339,11 @@
 	# V7-92: decode donor tile indices and load the selected atlas transport.
 	_decode_tile_indices(dump, w, h)
-	var atlas_ready := _load_atlas()
+	# P15 — the await executes only in the interactive async branch. With the
+	# default false, build() returns synchronously as before (no coroutine
+	# behaviour change for gates/tests).
+	var atlas_ready: bool
+	if p_async:
+		atlas_ready = await _load_atlas(true)
+	else:
+		atlas_ready = _load_atlas(false)
 	var tiles_available: bool = not _tile_indices.is_empty()
```

> **Mesh invariants untouched:** vertex/index/UV/UV2 loop `:1367-1528`, material `:1535`, water `:1561`, environment `:1564` are unchanged. `build()` still produces one surface, `w*h` verts, `(w-1)*(h-1)*2` tris, unchanged `atlas_grid` and sampler bindings.

---

## 4. Diff C — `variant3d/scripts/main.gd` (exclusive owner: P15)

**Backup before apply:** `inbox/backup/main.gd.bak-P15`.

Two changes:

**C1 — await the async bind at the 0.90 stage** so the overlay cannot fall through to 0.92 while mips are in flight (G23 §5, UX_LOADING R4). Gen guard immediately after the await, matching the existing pattern at `:547-548` etc.

**C2 — explicit readiness assertion before `_hide_loading()`** (P06 Blocker 3 / UX_LOADING R4). Read-only; checks only that composed subsystems exist and that the 3D terrain build finished. On failure the overlay is **kept** and an error is pushed — the opposite of test weakening.

### C.1 — readiness helper (insert after `_hide_loading()`, before `_loading_tick()` at :526)

```diff
--- a/variant3d/scripts/main.gd
+++ b/variant3d/scripts/main.gd
@@ -522,6 +522,37 @@
 	loading_stage = null
 	loading_pct = null
 
+# P15 — UX_LOADING R4 readiness assertion. Read-only by design: it checks only
+# that every subsystem this loader promised to build still exists and, for 3D,
+# that the full-grid terrain build completed. It never mutates state, lowers a
+# threshold, or hides a failure. A failure KEEPS the overlay up and is loud in
+# stderr, so a partially composed game is never presented as playable.
+func _assert_load_ready(gen: int) -> bool:
+	if gen != loading_gen:
+		push_error("P15: load superseded (gen %d != %d); overlay kept" % [gen, loading_gen])
+		return false
+	var parts := {
+		"world": world, "camera": camera, "hud": hud,
+		"input_ctl": input_ctl, "audio": audio,
+	}
+	for k in parts:
+		var v = parts[k]
+		if v == null:
+			push_error("P15: load not ready - %s is null" % k)
+			return false
+		if v is Object and not is_instance_valid(v):
+			push_error("P15: load not ready - %s was freed" % k)
+			return false
+	if render_mode == "3d" and world is Object and is_instance_valid(world):
+		var terrain = world.get("terrain")
+		if terrain == null or not (terrain is Object) or not is_instance_valid(terrain):
+			push_error("P15: load not ready - 3D terrain module missing")
+			return false
+		if not bool(terrain.get("_built")):
+			push_error("P15: load not ready - 3D terrain build incomplete")
+			return false
+	return true
+
 func _loading_tick(frac: float, stage: String, gen: int) -> bool:
 	# Returns false if this load was superseded (a newer Start click won).
 	if gen != loading_gen:
```

### C.2 — await `world.bind` in the 3D branch (modify lines 586-589)

```diff
--- a/variant3d/scripts/main.gd
+++ b/variant3d/scripts/main.gd
@@ -583,8 +583,14 @@
 	_apply_menu_post_loadsave(cfg)
 	if not await _loading_tick(0.90, "Loading art...", gen):
 		return
 	if render_mode == "3d":
 		world = make_world3d()
-		world.bind(game)
+		# P15 / G23 — await the async atlas decode/mip worker so the 0.90
+		# stage cannot fall through to 0.92 with mips still in flight. The
+		# 2D branch below stays byte-identical. See §5 for the world3d.gd
+		# companion signature change required for this call.
+		await world.bind(game, null, true)
+		if gen != loading_gen:
+			return
 		add_child(world)
 	else:
```

### C.3 — assertion gate before `load_ready` / `_hide_loading()` (modify lines 671-676)

```diff
--- a/variant3d/scripts/main.gd
+++ b/variant3d/scripts/main.gd
@@ -671,3 +671,8 @@
 	# are all complete before the overlay is removed.
+	# P15 — explicit R4 gate: no subsystem may be missing/freed and the 3D
+	# terrain build must be complete before the overlay is hidden. On failure
+	# _assert_load_ready() has already pushed an error and the overlay stays.
+	if not _assert_load_ready(gen):
+		return
 	load_ready = true
 	_hide_loading()
```

**Ordering preserved:** `load_ready = true` still sits immediately before `_hide_loading()` (UX_LOADING R4/R5); the `frame_post_draw` hold at `:667-670` is untouched; no stage label, threshold, seed or `expected_pre_fix_failure` is changed; sim still starts at `:647` behind the overlay.

---

## 5. Required companion handoff — `variant3d/scripts/world3d.gd` (**NOT** P15-owned)

P15's exclusive files are exactly the three above (ticket grant pending from COORD after G04). The await chain in Diffs A/B/C has one missing link: `world3d.gd:599 bind()` calls `terrain.build()` synchronously at `:639`. Without the change below, `main.gd`'s `await world.bind(game, null, true)` would pass an ignored third argument and the mip worker would never be awaited — **Diff C must not be applied until this handoff is applied too.** This is the same "companion handshake" pattern G23 §5 documented; it is supplied here as a complete ready-to-apply diff but **belongs to a separate owner / COORD integration**, not to P15.

**Backup before apply:** `inbox/backup/world3d.gd.bak-P15-HANDOFF`.

```diff
--- a/variant3d/scripts/world3d.gd
+++ b/variant3d/scripts/world3d.gd
@@ -596,7 +596,7 @@
 
 
 # --- FULL 2D WORLD CONTRACT: API ---------------------------------------------
-func bind(g, h = null) -> void:
+func bind(g, h = null, p_async: bool = false) -> void:
 	game = g
 	hud = h
 	view_scale = float(Data.PIXELS_PER_METER)   # world.gd:240; data.gd:113
@@ -635,6 +636,11 @@
 	# Dependency order: terrain geometry before fog overlay, entities before anim.
 	if terrain != null:
 		terrain.bind(game)
 		if _has_height_source(game):
-			terrain.build()   # ONE full-grid mesh; no chunk scheduling
+			# P15 handoff — async branch awaits the worker mips; sync branch
+			# (default) is byte-identical for headless gates and test doubles.
+			if p_async:
+				await terrain.build(true)
+			else:
+				terrain.build()   # ONE full-grid mesh; no chunk scheduling
 	if entities != null:
```

> `bind()` becomes a coroutine only syntactically; in the default `p_async == false` branch no `await` is executed, so `bind()` returns synchronously as today. `await` on a value that is not a coroutine returns the value immediately in Godot 4 — this is the same property Diff B relies on for `build()`/`_load_atlas()`. **UNVERIFIED** until a gate run confirms headless callers still see the same return types; if any caller breaks, split out explicit `bind_async()`/`build_async()` twins instead (larger but fully isolated).

---

## 6. Backup list (required before any grant to edit)

| File | Backup path |
|---|---|
| `variant3d/scripts/tile_atlas_loader.gd` | `inbox/backup/tile_atlas_loader.gd.bak-P15` |
| `variant3d/scripts/world3d_terrain.gd` | `inbox/backup/world3d_terrain.gd.bak-P15` |
| `variant3d/scripts/main.gd` | `inbox/backup/main.gd.bak-P15` |
| `variant3d/scripts/world3d.gd` (handoff, separate owner) | `inbox/backup/world3d.gd.bak-P15-HANDOFF` |

No backup was taken by this agent (read-only). Backups are the first action of the granted implementer.

---

## 7. Gate list (all UNVERIFIED / PENDING — only G04 runs them)

Per WAVE_G_CHARTER "Only G04 submits runner jobs"; P15 ran **zero** Godot jobs.

| # | Gate / check | Owner | Status |
|---|---|---|---|
| G1 | `inbox/backup/*.bak-P15` files exist and match pre-edit files byte-for-byte | Implementer | UNVERIFIED / PENDING |
| G2 | Selftest **29/29** unchanged (no threshold/seed/`expected_pre_fix_failure` change) | G04 → COORD | UNVERIFIED / PENDING |
| G3 | Uitest **17/17** unchanged | G04 → COORD | UNVERIFIED / PENDING |
| G4 | `t_render_mode` unchanged | G04 | UNVERIFIED / PENDING |
| G5 | `assert_clean.py --json` CLEAN | COORD | UNVERIFIED / PENDING |
| G6 | 2D `app/` untouched (CHARTER §5 item 3) | COORD | UNVERIFIED / PENDING |
| G7 | Headless/sync callers: `loader.call("load")` still returns `bool` synchronously; split/array fallback warnings unchanged (G23 A3) | G04 | UNVERIFIED / PENDING |
| G8 | **Byte/pixel honesty (G23 A2):** same seed, level-0 atlas `get_image()` bytes identical before/after; `atlas_grid` 16×8, tile histogram, `full_width_dark_rows == 0`, `dark_cols == 0` unchanged; mask repack output byte-identical (`alpha.png`/`alphavert.png` 512×256 / 1024×512) | G04 | UNVERIFIED / PENDING |
| G9 | **Window drag at 0.90 (G23 A1 / UX_LOADING R3):** windowed `launch_variant3d.bat`, drag title bar continuously while label reads `"Loading art..."`; must reach 0.92 without a frozen frame. Repeat cold cache / warm cache / forced split fallback | G04 | UNVERIFIED / PENDING |
| G10 | **Overlay readiness (G23 A4 / UX_LOADING R4/R5):** inject a deliberately slow mip task; overlay stays until task completes + `load_ready = true`; superseded Start click cannot hide it; `_assert_load_ready()` fires loudly on missing subsystem | G04 | UNVERIFIED / PENDING |
| G11 | **Fallback chain (G23 A3):** missing-single probe → split; missing-split → array; `_atlas_mode_loaded`, `get_reassembly_info()` and warnings unchanged; no sync mip build remains in split mode | G04 | UNVERIFIED / PENDING |
| G12 | **Profiling (G23 A6):** instrument mip-build wall time main-thread vs worker on the MX130 context (`AUDIT3D_09_runtime_proof.md:27`); retire the UNVERIFIED labels in §8 | G04 | UNVERIFIED / PENDING |

**Explicitly NOT done by these diffs:** no mip removal, no revert of `filter_linear_mipmap`/`textureGrad`, no anisotropy/MSAA setting, no `mipmaps/limit` change (G17 §5 #5 / P06 §5 "not recommended").

---

## 8. UNVERIFIED register

1. **No run, no capture, no frame time, no VRAM read.** All costs below remain analytical estimates carried from G17 §2–§3 and P06 §1–§5: PNG decode 180 MB → 512 MiB L0; mip chain ≈171 MiB / +33 % VRAM (≈683 MiB total); "hundreds of ms to a few seconds" mip build; 35–70 ms theoretical floor. None is a measurement.
2. **Thread safety of `Image.generate_mipmaps()` from a `WorkerThreadPool` worker** — UNVERIFIED (G17 §7 #3, G23 §4 caveat). Diff A only changes the executing thread; whether Godot 4.7.2 permits it and at what cost must be proven in G12.
3. **`ImageTexture.create_from_image()` upload timing** — UNVERIFIED whether :285/:416 (now in the async twins) uploads the full chain synchronously on the main thread or defers to first draw (P06 §6 #2). This decides whether G9's drag test passes.
4. **`await` on a dynamic call (`_atlas_loader.load_async(...)`) and on functions whose await branch is not taken** — UNVERIFIED. If GDScript rejects it, fall back to explicit `load_async`/`build_async`/`bind_async` twins (isolated but larger). No claim is made that the diff as written parses until G2–G4 run.
5. **Cache benefit** of Diff B1 — UNVERIFIED. The byte-level swizzle is O(655,360) but avoids `Color` allocation; the cache only helps scene reloads. Neither speedup was measured.
6. **`_assert_load_ready()` compatibility with every headless test harness** — UNVERIFIED until G2–G4. It is additive and read-only; if a harness legitimately leaves `audio`/`camera` null, the assertion must be narrowed rather than deleted (no test weakening).
7. **Window drag freeze (owner S3)** may still occur at other unsliced stage bodies (mapgen `:563-581`, HUD `:622-636`, input `:639-647`) — Diffs A–C fix the mip step and the readiness assertion, **not** the whole S3 structural issue. R3 must be checked at every stage.
8. **Post-hide GPU work (owner S4)** beyond ordinary `_process()` sync — UNVERIFIED; the existing `frame_post_draw` hold is untouched.
9. **Donor parity remains UNVERIFIED** throughout (CHARTER §3). No donor GPU A/B frame exists; nothing here compares to a donor frame.

---

## 9. Summary for COORD

- Three exclusive-owner diffs are ready to apply **after G04 and after ownership grant**: (a) `tile_atlas_loader.gd` adds worker-thread `load_async()` while `load()`/fallback stay byte-identical and level-0 pixels unchanged; (b) `world3d_terrain.gd` replaces 655,360 `get_pixel`/`set_pixel` pairs with a byte-level swizzle plus a SHA-keyed cache, and adds opt-in async flags on `_load_atlas()`/`build()`; (c) `main.gd` awaits the 3D bind at 0.90 and adds a read-only `_assert_load_ready(gen)` gate immediately before `_hide_loading()`.
- One **required non-P15 handoff** (`world3d.gd:599/:639`) is supplied in §5 — Diff C is inert without it, so COORD must grant/integrate it in the same integration window.
- Backups: four `.bak-P15` paths in §6. Gates: G1–G12 in §7, all **UNVERIFIED / PENDING**, run only by G04. The freeze fix, byte identity, gate results and donor parity are **not claimed** by this proposal.

*End of P15 report.*
