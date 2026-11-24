---
owner: W5-3
wave: perf (whole-map evaluation + P2 #3 residual)
swarm: coord_swarm_2026-11-24
date: 2026-11-24
scope: G-P7 (post-bake chunk scheduling) + owner priority change (whole-map single-texture runtime evaluation)
exclusive_files: app/scripts/world.gd, app/tests/t_chunk_schedule_light.gd, this report
output: docs/coord_swarm_2026-11-24/reports/W53_world_perf_light.md
status: FIXED (G-P7 early-out) / BLOCKED (whole-map single-texture)
verdict: SHIPPED light early-out with before/after counters; whole-map single-texture BLOCKED-BY-BAKE-TIME + loading-stage integration (main.gd not owned), NOT SHIPPED. No FPS claim.
---

# W5-3 — world.gd perf residual + whole-map feasibility

## Verdict summary

- **VERIFIED** current `world.gd` had the P2 #3 sites unchanged: duplicated
  view→tile→chunk derivation, per-frame `full_chunks.keys()` reconciliation and
  an `ncx*ncy` (100-chunk) LOD warm-up loop. W2-5's archived patch
  (`inbox/backup/world.gd.bak-W25-fix`) was re-read; its hunks apply cleanly to
  the current file (W3-3 aura changes are at `:3009+`, disjoint from these sites)
  and are safe. **Applied minimally.**
- **FIXED / MEASURED (structural):** at steady state, chunk-key derivations per
  `_sync_terrain_chunks()` went **101 → 1** and `game.tile_of()` calls per sync
  went **2 → 0**; gate self-resets after a quality clear. No FPS claim; this is a
  call-count measurement from the new light test.
- **BLOCKED / NOT SHIPPED:** whole-map single-texture runtime path. W5-6
  (`reports/W56_whole_map_feasibility.md`) confirms memory and GPU limits are
  fine (2560²/25 MiB low, 3840²/56 MiB med, 5120²/100 MiB high; all under the
  16384² cap). The blocker is **bake time + integration**: one-shot 100-chunk
  extrapolation is **4.4–22 s low / 11–180 s med / 20–500 s high**, and
  `main.gd:553` calls `world.bind()` synchronously with the loading bar repainting
  only between `_loading_tick` stages. Hiding the cost requires an awaited/staged
  loading stage in `main.gd` (W5-2-owned; H1/H2 handoff), which this lane cannot
  edit. Current design already keeps all 100 chunk textures resident with no
  eviction, so memory is **not** reduced; the per-frame scheduling cost is now
  removed by the shipped early-out.

## Files / backup

- Backup before edit: `inbox/backup/world.gd.bak-W53` (SHA256
  `93A6213D4546C98E991F5863…`, byte-identical to the pre-edit file).
- Edited: `app/scripts/world.gd` only (plus one new test and this report).
- New test: `app/tests/t_chunk_schedule_light.gd` — not registered in
  `app/tests/manifest.json` (not owned by this lane).
- No donor copy, no called-symbol rename, no other file touched. Tabs preserved.

## Exact shipped diff (world.gd)

Only these hunks are W5-3's; the surrounding W3-3 aura diff was already present.

```diff
@@ -37,6 +37,14 @@ var fallback_tex: ImageTexture = null
+# P2 #3: steady-state chunk-scheduling gate. Recomputed from terrain_chunks.size()
+# on every _sync_terrain_chunks() call, so main.gd's quality-change clear (which
+# empties terrain_chunks) self-resets it without any edit outside world.gd.
+var lod_complete := false
+# P2 #3: view->chunk bounds (x=c0x, y=c0y, z=c1x, w=c1y) computed ONCE in sync()
+# and shared by terrain + forest syncs. -1 means "unset": a direct caller (the
+# forest bake tests) re-derives from view_rect via _view_chunk_bounds().
+var view_chunk_range := Vector4i(-1, -1, -1, -1)
@@ -1741,10 +1749,31 @@ func has_chunk_or_fallback(k: Vector2i) -> bool:
-func _sync_terrain_chunks() -> void:
+# P2 #3: the view->tile->chunk derivation used to be duplicated verbatim in
+# both sync functions. sync() now calls this ONCE and shares the result. Direct
+# callers (forest bake tests, which never run sync()) fall back to view_rect.
+func _view_chunk_bounds() -> Vector4i:
 	# view_rect is canvas pixels (meters x view_scale); tile_of wants meters
 	var m0 := view_rect.position / view_scale
 	var m1 := view_rect.end / view_scale
 	var t0 := game.tile_of(m0)
 	var t1 := game.tile_of(m1)
-	var c0x := maxi(0, t0.x / CHUNK_T)
-	var c0y := maxi(0, t0.y / CHUNK_T)
-	var c1x := mini(int(ceil(float(game.MAP_W) / CHUNK_T)) - 1, t1.x / CHUNK_T)
-	var c1y := mini(int(ceil(float(game.MAP_H) / CHUNK_T)) - 1, t1.y / CHUNK_T)
+	return Vector4i(
+		maxi(0, t0.x / CHUNK_T),
+		maxi(0, t0.y / CHUNK_T),
+		mini(int(ceil(float(game.MAP_W) / CHUNK_T)) - 1, t1.x / CHUNK_T),
+		mini(int(ceil(float(game.MAP_H) / CHUNK_T)) - 1, t1.y / CHUNK_T))
+
+func _sync_terrain_chunks() -> void:
+	# P2 #3: reuse the shared bounds computed in sync(); direct callers re-derive.
+	var cr: Vector4i = view_chunk_range if view_chunk_range.x >= 0 else _view_chunk_bounds()
+	var c0x: int = cr.x
+	var c0y: int = cr.y
+	var c1x: int = cr.z
+	var c1y: int = cr.w
+	var ncx: int = int(ceil(float(game.MAP_W) / float(CHUNK_T)))
+	var ncy: int = int(ceil(float(game.MAP_H) / float(CHUNK_T)))
+	# P2 #3: once all map chunks are resident, the whole-map reconciliation and
+	# LOD warm-up below do no work but still scan/sort every frame. Recompute
+	# from cache size each call so main.gd's quality clear (which empties
+	# terrain_chunks) self-resets the gate without an edit outside world.gd.
+	lod_complete = terrain_chunks.size() == ncx * ncy
@@ -1759,11 +1786,10 @@ func _sync_terrain_chunks() -> void:
-	for k in full_chunks.keys():
-		if not terrain_chunks.has(k):   # e.g. main.gd cleared chunks on quality change
-			full_chunks.erase(k)
-	var ncx: int = int(ceil(float(game.MAP_W) / float(CHUNK_T)))
-	var ncy: int = int(ceil(float(game.MAP_H) / float(CHUNK_T)))
+	if not lod_complete:
+		for k in full_chunks.keys():
+			if not terrain_chunks.has(k):   # e.g. main.gd cleared chunks on quality change
+				full_chunks.erase(k)
@@ -1804,16 +1831,18 @@ func _sync_terrain_chunks() -> void:
 	# 2) Distant LOD warm-up: any map chunk with no texture yet. Time-budgeted so
 	#    it adds no frame hitch; entries accumulate and are never evicted.
+	#    P2 #3: skipped entirely at steady state (lod_complete) - no keys left.
+	if not lod_complete:
-	var lod_budget_us := 8000
-	var lod_t0 := Time.get_ticks_usec()
-	for cy in ncy:
-		for cx in ncx:
-			var k := _chunk_key(cx, cy)
-			if terrain_chunks.has(k):
-				continue
-			if Time.get_ticks_usec() - lod_t0 >= lod_budget_us:
-				break
-			terrain_chunks[k] = _build_chunk_low(cx, cy)
+		var lod_budget_us := 8000
+		var lod_t0 := Time.get_ticks_usec()
+		for cy in ncy:
+			for cx in ncx:
+				var k := _chunk_key(cx, cy)
+				if terrain_chunks.has(k):
+					continue
+				if Time.get_ticks_usec() - lod_t0 >= lod_budget_us:
+					break
+				terrain_chunks[k] = _build_chunk_low(cx, cy)
@@ -1974,15 +2002,12 @@ func _sync_forest_chunks() -> void:
-	# Same view -> tile -> chunk derivation as _sync_terrain_chunks().
-	var m0 := view_rect.position / view_scale
-	var m1 := view_rect.end / view_scale
-	var t0 := game.tile_of(m0)
-	var t1 := game.tile_of(m1)
-	var c0x := maxi(0, t0.x / CHUNK_T)
-	var c0y := maxi(0, t0.y / CHUNK_T)
-	var c1x := mini(int(ceil(float(game.MAP_W) / CHUNK_T)) - 1, t1.x / CHUNK_T)
-	var c1y := mini(int(ceil(float(game.MAP_H) / CHUNK_T)) - 1, t1.y / CHUNK_T)
+	# P2 #3: reuse the bounds computed once in sync(); direct callers re-derive.
+	var cr: Vector4i = view_chunk_range if view_chunk_range.x >= 0 else _view_chunk_bounds()
+	var c0x: int = cr.x
+	var c0y: int = cr.y
+	var c1x: int = cr.z
+	var c1y: int = cr.w
@@ -2048,8 +2076,8 @@ func sync(dt: float) -> void:
 	view_rect = get_viewport().get_canvas_transform().affine_inverse() * get_viewport_rect()
+	# P2 #3: derive the view->chunk range ONCE per sync and hand it to both
+	# syncs; clear it afterwards so direct callers always use their own view_rect.
+	view_chunk_range = _view_chunk_bounds()
 	_sync_terrain_chunks()
 	_sync_forest_chunks()  # T-FOREST-BAKE: bake at most 1-2 missing chunks/frame
+	view_chunk_range = Vector4i(-1, -1, -1, -1)
 	anim_t += dt
```

Post-edit symbols: `world.gd:43` `lod_complete`, `:47` `view_chunk_range`,
`:1752` `_view_chunk_bounds()`, `:1764` `_sync_terrain_chunks()`, guards at
`:1786` and `:1834`, forest reuse at `:1996`, range set/reset at `:2078`/`:2081`.

## New light test

`app/tests/t_chunk_schedule_light.gd` (161 lines, `extends SceneTree`):
`StubGame extends C3Game` overrides only `tile_of()` to count calls;
`ProbeWorld extends C3World` overrides `bind()` with a minimal field-only bind
(no block warm-up / sprite load / forest SubViewport) and stubs `_chunk_key`,
`_build_chunk`, `_build_chunk_low`, `_make_chunk_sprite`, `_fallback_texture`
with call counters. The **real** `_sync_terrain_chunks()` / `_sync_forest_chunks()`
from `res://scripts/world.gd` do all scheduling. Nine checks: gate flag, shared
range (0 `tile_of` calls), no full-map key scan (1 key derivation instead of
101), stale-full-key retention at steady state, no bake work at steady state,
forest shared range, gate self-reset after quality clear, stale-key reconciliation
after clear, and unchanged 2-chunk cap + centre-out order. Failsafe `quit(1)` on
early abort. Runtime ~32 ms; never touches `t_forest_bake`'s heavy setup.

Runner command (not in manifest.json — not owned by this lane):
```
python app\tools\godot_runner.py run --id w53-light --timeout 60 -- \
    --headless --path app --script res://tests/t_chunk_schedule_light.gd
```

## Runner evidence (MEASURED)

| Job | Command | Result |
|---|---|---|
| **1293** `w53-light-pre` | light test on **unpatched** world.gd | exit 1, **2/9 checks**, run 10.11 s. `lod_complete=<null>`; `tile_of` calls 2 (terrain) + 2 (forest); chunk-key derivations **101** (=1 in-view +100 full-map); stale full key erased; `gate_self_resets` FAIL. |
| **1300** `w53-light-post` | same, **patched** world.gd | exit 0, **9/9 checks**, run 5.90 s (waited 417.95 s). `lod_complete=true`; `tile_of` calls **0** (terrain) + **0** (forest); chunk-key derivations **1**; stale full key retained; gate self-resets (`false`, 99 low builds after clear); bake order `[(1,1),(1,0)]`, cap 2. Test body 22.2 ms. |
| **1301** `w53-wave-smoke` | `t_wave_smoke.gd` regression | exit 0, **WAVE_SMOKE 9/9**, run 7.84 s (waited 423.64 s). |

**Before/after (MEASURED, structural):** steady-state chunk-key derivations
**101 → 1**; `game.tile_of()` calls per sync pair **4 → 0**; light test **2/9 →
9/9**. This is a call-count measurement, **not** an FPS/frame-time claim.
The `BAKE_BENCH … max_ms=0.02` line in job 1300 is emitted by
`world.gd:184-189` `NOTIFICATION_EXIT_TREE` from the **stubbed** bake helpers in
the light test — it is a harness artifact, **not** a real bake measurement.

`t_forest_bake` was **not** run (environment hang on untouched baseline: jobs
1261/1268/1270, acked). No FPS/frame-time number is claimed.

## Whole-map single-texture evaluation (BLOCKED-BY-BAKE-TIME, NOT SHIPPED)

Decision after reading W5-6 §5–§7: **small early-out only**. A staged/awaited
whole-map bake is only safe if the loading bar yields between bands; that
integration lives in `main.gd` (W5-2-owned). This lane cannot edit it, so no
whole-map code was shipped rather than force a multi-second synchronous stall.

- **Map / chunks (VERIFIED):** 320×320 tiles (`app/config.json:37-38`,
  `config.gd:405-406`), `CHUNK_T=32` → 10×10 = 100 chunks. `terrain_chunks`
  already has **no eviction** (`world.gd:32`), so resident memory is already
  25/56/100 MiB across presets — identical to one whole-map texture.
- **Memory / GPU (W5-6 §2–§3, VERIFIED arithmetic):** low 2560² = 25.00 MiB,
  med 3840² = 56.25 MiB, high 5120² = 100.00 MiB RGBA8. All fit the usual
  16384² `ImageTexture` cap (older desktops 8192, mobile 4096). The 20480² /
  1.6 GiB figure is a **supersample intermediate / diagnostic**, not a final
  upload. A runtime `limit_get(LIMIT_MAX_TEXTURE_SIZE_2D)` was not probed here.
- **Bake cost (W5-6 §4, ESTIMATE; low anchors MEASURED in repo):** 100 × measured
  low anchors (43.59–50.06 ms post-optimisation, up to 196–221 ms wave gate) →
  **4.4–22 s low**; med **11–180 s**; high **20–500 s** (~5 s/chunk HIGH source
  note at `world.gd:1783`). Saturated-machine `BAKE_BENCH` lines (1.36–3.62 s)
  are **not** comparable to the 50 ms gate and were not used as the primary
  anchor. `comp_px` is 8 / 48 / 64 (`world.gd:1039-1042`, `:1550`), so med/high
  supersample intermediates are 900 MiB / 1.6 GiB if done naively.
- **Why BLOCKED here:** W5-6 calls low "FEASIBLE **if staged in loading**". The
  staging hook is `main.gd:553` (synchronous `world.bind()`) plus a new awaited
  `_loading_tick` band between "Loading art..." and "Building interface..."
  (W5-6 H1/H2); progress repaints only between stages. Without that hook a
  world.gd-only whole-map bake either freezes startup for 4–500 s or silently
  moves the hitches into gameplay. Neither is safer than the shipped early-out.
- **Alternative rejected:** assembling the single image from already-baked
  chunks does not help — only in-view chunks are ever upgraded to full quality;
  100 full bakes are still required, and re-uploading a 100 MiB texture on each
  later 2/frame upgrade would be worse than the shipped 100-sprite layout.
- **Handoffs (NOT edited — W5-2 / coordinator own these):**
  - H1/H2: expose `build_terrain_async()` from `world.gd` and `await` it in a new
    loading band near `main.gd:552-555`; re-grep line numbers (W5-2 edits moved
    them; W5-6 H6).
  - H3: quality-change handler (`main.gd` ~`:1254-1263`) must call
    `invalidate_whole_terrain()` and keep the old sprite until the new texture is
    ready — no null-texture frame.
  - H4: keep forest invalidation and include `terrain_px` in the forest signature.
  - H5: bench label change (`preset=<q> px=<n> whole_map_ms=<m>`) needs QA
    coordination with `app/tools/bake_bench.py` parser.

## Determinism / bake-order note

- Centre-out sort (`ccx/ccy`, `d=dx*dx+dy*dy`, `full_q.sort_custom`, forest `q`
  sort), the 2-chunk/frame cap, `FOREST_BAKE_PER_FRAME`, generation guard and
  LRU are byte-unchanged. The light test asserts the cap and centre-first order.
- The shared range is the *same* integers from the same
  `view_rect → tile_of → CHUNK_T` derivation, merely hoisted into
  `_view_chunk_bounds()`. Direct callers (forest bake tests) still re-derive
  because `view_chunk_range` defaults to `Vector4i(-1,-1,-1,-1)` and `sync()`
  clears it after both syncs.
- No RNG, no `game.*`/map writes, no `has()` ordering change. `lod_complete` is
  recomputed from `terrain_chunks.size()` each call, so `main.gd:1098`'s quality
  clear self-resets it; the light test proves reset + reconciliation.
- The no-hole fallback reconciliation (`has_chunk_or_fallback` and the
  in-view/fallback pass) still runs **every** frame; only the two no-work scans
  are gated.

## Open questions

1. Runtime `RenderingServer.get_max_texture_size()` on this headless build was
   not probed; 5120² is analytically within typical desktop limits.
2. Would a from-scratch final-resolution (no 64px supersample) whole-map
   generator be visually acceptable and fast enough? Needs a separate bake
   pipeline lane + A/B screenshots; not attempted here.
3. BAKE_BENCH high-preset numbers do not exist; the high cost above is an
   extrapolation from low plus the 64× `comp_px` area ratio, not a direct
   measurement.
4. The archived W25 patch was previously reverted only because `t_forest_bake`
   hung on baseline; this lane verified the same hunks structurally and with a
   light test without that hanging path.
