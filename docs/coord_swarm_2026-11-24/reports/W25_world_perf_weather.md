---
owner: W2-5
wave: perf + environment
swarm: coord_swarm_2026-11-24
date: 2026-11-24
scope: G-P7 (post-bake chunk scheduling) + G-ENV2 (weather / snow art)
gaps: G-P7, G-ENV2
exclusive_file: app/scripts/world.gd
output: docs/coord_swarm_2026-11-24/reports/W25_world_perf_weather.md
status: NOT-DONE
verdict: BLOCKED-BY-ENVIRONMENT
shipped_changes: none (app/scripts/world.gd reverted to pre-change backup; git diff empty)
---

# W2-5 — `world.gd` post-bake scheduling + environment weather

**Honest verdict:** **BLOCKED-BY-ENVIRONMENT / NOT-DONE — no world.gd change
shipped.** A G-P7 patch was prepared (58 insertions / 29 deletions, diff archived
below) but `t_forest_bake` hangs with banner-only stdout on the changed code
(jobs 1261, 1268) **and on the untouched pre-change backup** (A/B job 1270).
The baseline hang proves the problem is pre-existing/environmental, not caused by
the patch. The patch was therefore **reverted per coordinator directive**:
`app/scripts/world.gd` is byte-identical to `inbox/backup/world.gd.bak-W25`
(SHA256 `2D2731A1…`) and `git diff -- app/scripts/world.gd` is **EMPTY**.
**No perf win is claimed.** Visual A/B remains deferred to the coordinator.
G-ENV2 weather art is **NOT-DONE** because no usable donor-derived assets exist
under `app/assets/**`; nothing was fabricated and no donor files were copied.

**Timeline clarification:** the coordinator's earlier "git diff is empty" check
fell inside the A/B window, when the pristine backup was temporarily restored.
The patch was restored afterwards (verified non-empty diff), then reverted again
in response to the final directive. The file is now pristine and the diff is
empty as observed.

## Gap status table

| Gap | Status | Evidence (current source / assets) | Outcome |
|---|---|---|---|
| G-P7 / P2 #3 — whole-map scan + sort at steady state | **NOT-DONE (patch prepared, then reverted; UNVERIFIED)** | Patch touched `world.gd:40-47`, `:1749-1762`, `:1764-1777`, `:1786-1789`, `:1831-1844`, `:2005-2010`, `:2072-2081` (see archived diff); current file has **none** of these hunks — `git diff -- app/scripts/world.gd` empty, hash matches pristine backup | Early-out + shared range were implemented as briefed but could not be verified; reverted so no unverified code ships. |
| G-ENV2 — season tint / winter art / per-frame water | **VERIFIED-ALREADY** | `world.gd:1630-1659` season tint + relief; `:1693-1707` `_build_chunk_low()` winter colour; `:1711-1723` `_fallback_texture()` winter; `:2053-2057` water clock advanced every frame (`R10` claim 17) | Pre-existing; untouched by this lane. |
| G-ENV2 — clouds / weather state / snow PFX / sky-fog palette / flares / day-night | **NOT-DONE (asset-blocked)** | 7,848 files scanned under `app/assets/**`; **zero** filename hits for `cloud\|snow\|weather\|storm\|flare\|sky\|precip\|rain\|smoke\|pfx\|snowflake\|blizzard\|overcast`. `app/assets/terrain/deco_png/` contains only `christmastreed.png`, `envfieldd.png`, `envfielddw.png`, `groundexp0..3.png` (scorch/explosion ground decals — not billboards or flakes). | No layer wired: brief says report exact missing assets rather than fabricate. Default-visual change = zero. Do NOT copy donor files. |

## G-P7 — exact diff (ARCHIVED, NOT SHIPPED)

Backup / shipped state: `inbox/backup/world.gd.bak-W25` (169,274 bytes, taken
immediately before editing). `app/scripts/world.gd` was restored to this exact
file; both hash to
`2D2731A1044422BF57190EB217D96606B06351A9851E5F18F2F143223E1BB514`, and
`git diff -- app/scripts/world.gd` is empty. The prepared-but-reverted patch is
preserved for any future attempt at `inbox/backup/world.gd.bak-W25-fix` (SHA256
`3151D620688940B8B4C6366BE442F1A3D8F0BACB200F1DE9D279EEE5CA5D8900`). The diff
below is historical evidence only — **none of these hunks are in the tree now**.

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
@@ -1738,16 +1746,35 @@ func has_chunk_or_fallback(k: Vector2i) -> bool:
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
@@ -1756,11 +1783,10 @@
-	for k in full_chunks.keys():
-		if not terrain_chunks.has(k):   # e.g. main.gd cleared chunks on quality change
-			full_chunks.erase(k)
-	var ncx: int = int(ceil(float(game.MAP_W) / float(CHUNK_T)))
-	var ncy: int = int(ceil(float(game.MAP_H) / float(CHUNK_T)))
+	if not lod_complete:
+		for k in full_chunks.keys():
+			if not terrain_chunks.has(k):   # e.g. main.gd cleared chunks on quality change
+				full_chunks.erase(k)
@@ -1804,16 +1830,18 @@
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
+	#    P2 #3: skipped entirely at steady state (lod_complete) - no keys left.
+	if not lod_complete:
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
@@ -2048,8 +2073,12 @@ func sync(dt: float) -> void:
 	view_rect = get_viewport().get_canvas_transform().affine_inverse() * get_viewport_rect()
+	# P2 #3: derive the view->chunk range ONCE per sync and hand it to both
+	# syncs; clear it afterwards so direct callers always use their own view_rect.
+	view_chunk_range = _view_chunk_bounds()
 	_sync_terrain_chunks()
 	_sync_forest_chunks()  # T-FOREST-BAKE: bake at most 1-2 missing chunks/frame
+	view_chunk_range = Vector4i(-1, -1, -1, -1)
```

Only these hunks were prepared (tabs preserved); `main.gd`, `config.gd`,
`data.gd`, `game.gd` and the test were **not** touched (exclusive ownership
honoured). All hunks were subsequently reverted; see the shipped-state note above.

## Bake order / determinism note (design intent, NOT shipped / NOT verified)

- The centre-out sort is byte-identical: `ccx/ccy = float(c0x+c1x)*0.5`,
  `dx/dx`, `d = dx*dx + dy*dy`, `full_q.sort_custom(...)` and the forest `q`
  sort are unchanged; `c0x..c1y` are the same ints from the same
  `view_rect → tile_of → CHUNK_T` derivation (now in `_view_chunk_bounds()`).
- 2-chunk/frame cap (`built >= 2`) and `FOREST_BAKE_PER_FRAME` cap unchanged.
- Generation guard (`_forest_bake_gen`), `_forest_bake_busy` serialisation and
  LRU (`_forest_touch`, `FOREST_CHUNK_CACHE`) untouched.
- No-hole fallback (`has_chunk_or_fallback`, `in_view` reconciliation at
  `world.gd:1845-1856`) untouched and still runs **every** frame; the in-view
  full-quality queue is still built/sorted every call, so a pan upgrades LOD
  chunks to full bake in the same order as before.
- `lod_complete` is **recomputed** from `terrain_chunks.size() == ncx*ncy` on
  every call, so `main.gd:1058`'s quality-change clear (which empties
  `terrain_chunks` but not `full_chunks`) self-resets the gate and the
  reconciliation still runs — no sticky flag, no edit needed in `main.gd`.
- No new RNG, no `game.*`/map writes, no `has()` ordering change. Determinism
  risk was LOW as designed — but **not empirically confirmed**, and the patch is
  reverted, so no determinism claim is made for the shipped tree.

## Runner evidence (no perf claim)

| Job | Command (all via `godot_runner.py`) | Result |
|---|---|---|
| **1261** `w25-world` | `run --id w25-world --timeout 240 -- --headless --path app -- --script res://tests/t_forest_bake.gd` | **timed-out**, run 245.25 s, exit -9. `stdout.txt` = Godot banner only (no PASS/FAIL lines); `stderr.txt` = `[runner] KILLED after 240.0s`. |
| **1268** `w25-world-retry` | same, `--timeout 120` | **timed-out**, run 130.99 s, exit -9; banner-only stdout; `KILLED after 120.0s`. |
| **1270** `w25-ab-baseline` | same, `--timeout 90`, with **pre-change backup** `world.gd.bak-W25` restored (hash `2D2731A1…`) | **timed-out**, run 94.17 s; banner-only stdout. **Baseline hangs too.** |

Expected 9/9 was **not** obtained. `app/tests/results/t_forest_bake.json` still
holds a **stale** 9/9 result with `unix_ms = 1795453059891.0`, predating these
jobs; it is not evidence for this change and was not overwritten.

**Root cause of the hang:** environmental / pre-existing, **not** this diff.
Evidence: (a) A/B job 1270 hangs on the untouched backup with identical
banner-only output; (b) no `while` loop or unbounded range exists in my diff —
it only adds a computed `if not lod_complete` guard around two existing `for`
loops; (c) no parse errors were printed (stderr only contains the runner's
KILLED line); (d) `world.gd` has no `_ready`/`_process` and `bind()` calls
none of the changed functions, while the test prints no `check()` line, so the
stall is inside a synchronous setup call (`C3Game.setup` / `C3World.bind` /
block warm-up) before the first assertion; (e) other concurrent jobs in the
same window passed normally (1260 `w212-menu-tier` 11.9 s ok, 1263 `w27-ambient`
9.9 s ok, 1264 `w26-parse-check` 17.4 s ok), so this is specific to the
`C3Game`/`C3World` + high-quality setup path under the current concurrent edits
(`git status` showed simultaneous modifications to `ai.gd`, `audio.gd`,
`config.gd`, `data.gd`, `game.gd`, `hud.gd`, `input_controller.gd`, `main.gd`,
`menu.gd`, `selftest.gd`, `naval_units/index.json` plus queued jobs 1262–1269).
The precise blocking call is **UNVERIFIED** — no profiler/stack was available
without another runner job, which was prohibited after escalation.

## G-ENV2 — exact missing-asset list

Searched: all 7,848 files under `app/assets/**` (read-only), filename regex
`cloud|snow|weather|storm|flare|sky|precip|rain|smoke|pfx|snowflake|blizzard|overcast`
(case-insensitive) → **0 hits**. Non-matches inspected:
`app/assets/terrain/deco_png/{christmastreed,envfieldd,envfielddw,groundexp0..3}.png`
(ground decals only) and `app/assets/terrain/blocks/winter0..26.png` (ground
tiles already used by the season tint).

Donor art named in `R10` and **absent from `app/assets/**`**:

- `env/clouds/clouds.weather` banded weather state + wind vector (config only)
- cloud billboard textures from `env/clouds/clouds.presets` (soft/volume/dark/storm)
- `env/pfx/particles.lib` snow system + `particles.snow.cfg` WeatherStart=70 gate
- `snow1.bmp`, `snow2.bmp`, `snow3.bmp`, `snow4.bmp` (snowflake sprites)
- `env/skydome/skydome.cfg` gradient bands + `stars.cfg`
- `env/flares/default.cfg` day01..05/evening/morning/moon flare textures
- `env/colors/colors.lib` 8 sky/fog/ambient colour tables (port has 3 RGB tints only)
- `pfx/fx.tree` / `source.pfx` textured smoke/flash DDS (port uses procedural circles)

Also absent by design (do not ticket): donor rain (`R10` claim 10) and day/night
(`G-ENV1`: donor explicitly disables `DateTimeManager`). Audio beds
`amb_{wind,sea,towneur}.ogg` **do** exist under `app/assets/sounds/`, but are
owned by the audio lane (W2-7) and were not wired here.

**No weather/snow layer was added.** Per the brief, fabricating art or copying
donor files would be worse than reporting the gap; the flag question is therefore
moot. If donor-derived snow/cloud PNGs are later staged under `app/assets`, the
minimal wiring point is a world-layer sprite draw behind a default-OFF flag read
from `C3Config.active.flag("gameplay.weather_layer", false)` (no change needed in
`config.gd`), gated on weather ≥ 70 with a seed-derived phase, never runtime RNG.

## Open questions

1. What exactly stalls `C3Game.setup` / `C3World.bind` in the current tree?
   Baseline A/B proves it is unrelated to G-P7; a stacks/probe job is needed
   (blocked by escalation — no more jobs from this lane).
2. Once the environment settles, should the archived patch
   (`inbox/backup/world.gd.bak-W25-fix`) be re-applied and `t_forest_bake` (9/9)
   + `t_forest_bake_render` (3/3) re-run? Bake-order byte-identity still needs a
   fixed-seed dump A/B before any perf claim. W2-5 will not re-queue jobs.
3. `BAKE_BENCH` gate (max_ms < 250) and minimap-jump no-hole check were **not**
   exercised by this lane's test — run `bake_bench.py` / a fresh capture before
   claiming a perf win.
4. Should a later lane stage the exact donor-derived snow/cloud textures into
   `app/assets` (read-only donor → converted assets) and then wire the
   default-off layer, or close G-ENV2 as a documented 2D-port divergence?
