---
owner: P2
wave: perf
date: 2026-11-24
scope: read-only recon — render/HUD per-frame paths
output: docs/coord_swarm_2026-11-24/reports/P02_render_hotpaths.md
---

# P2 — Render/HUD per-frame hot paths (recon only)

**Method:** direct source reads of `world.gd`, `camera.gd`, `hud.gd`, `main.gd`,
`water_overlay.gdshader` (`MEASUREMENT` = code shape observed at `file:line` that
anyone can re-read; `ESTIMATE` = unbenchmarked magnitude). **No runner, no Godot,
no screenshots were run by this lane; no FPS/frame-time delta is claimed.**

**Explicitly NOT re-proposed** (already landed / NO_WIN per `docs/PERFORMANCE_SWARM.md`
and `docs/REPORT_FOOD_MILL_PERF.md`): forest SubViewport chunk bake
(`world.gd:1815-2030`), water branch+octave break (`water_overlay.gdshader:27-37,132-134,220-224,263-269`),
terrain chunk-bake bench (50 ms), cliff/terrain-baked per-frame (NW-2/NW-4),
paused/static redraw gates, ghost cache, fog revision, dirty HUD *text* assignment,
minimap base cache, hover throttle, single-pass pick, camera dt clamp.

## Claim table

| # | Hotspot | Evidence file:line | Cost shape | Method | Verdict | Proposed fix | Visual risk |
|---|---|---|---|---|---|---|---|
| 1 | HUD status counters rescan every live unit **every frame**, before the dirty-text guard | `hud.gd:1096` → `game.gd:2558-2563`, `3802-3807`, `2565-2569` | `unit_count(0)` = O(live_units); `queue_count(0)` → `buildings_of()` allocates array + O(live_blds+queues). Runs even though `status_label.text` is changed only when string differs (`:1101-1103`). At 1k–3k units this is the largest remaining *render-lane* per-frame scan. | MEASUREMENT (call shape); magnitude ESTIMATE | **NEW — top pick** | Throttle counter recompute to the text-refresh cadence (reuse `eco_t`-style 0.5 s timer, or compute only when a cached status key is stale). Optional later: sim-maintained per-player counter (sim-layer edit, needs separate lane). | **None to low** — number lags ≤0.5 s; no map pixels change. |
| 2 | One new `Dictionary` allocated per visible unit per frame for the alpha layer | `world.gd:590`, `:3061`, `:3127`, `:3118-3123` | `pending_unit_sprites.append({tex,dst,src,tint})` for every animated/static unit; `clear()` drops all refs at next `_draw_units`. ~visible-units dict allocations/frame → GC churn. Draw count/order unchanged. | MEASUREMENT; magnitude ESTIMATE | **NEW — safe** | Preallocate a pool of descriptor dicts; reset `size()`/reuse slots instead of `clear()`+realloc. Identical iteration order. | **None** — byte-identical draw calls. |
| 3 | Post-bake chunk scheduling still scans the whole map and rebuilds/sorts queues every frame | `world.gd:1744-1746` (`full_chunks.keys()` array alloc), `:1749-1762` (`full_q` dicts + `sort_custom`), `:1792-1801` (LOD warm-up loop over all `ncx*ncy`=100 chunks); duplicated range math at `:1963-1970` | O(map chunks) per frame + array/dict churn **after every chunk is already baked** (steady state). The LOD loop only does `has()` + time check once complete; the range/sort work is pure overhead. | MEASUREMENT; magnitude ESTIMATE (small constant, 60 fps) | **NEW — safe** | Add `lod_complete` flag: skip the distant-LOD loop and `full_chunks` reconciliation once `terrain_chunks.size() == ncx*ncy` (reset on quality change/invalidate). Compute view→chunk bounds once in `sync()` and pass to both sync functions. Keep centre-out sort and 2/frame cap verbatim. | **None** (scheduling only). Determinism: LOW — bake order must stay byte-identical; verify with bake test + seed dump. |
| 4a | `_bld_key()` re-resolved up to 3× per building per redraw, each doing a `ResourceLoader.exists` probe | `world.gd:2808`, `:2811`, `:2824` → `_bld_tex:720`, `_bld_key:593-603` | `_bld_tex(e)` called twice (guard + assignment), then `_bld_scale(_bld_key(e))`; each `_bld_tex` calls `_bld_key` → `_res_exists(_nation_sheet(...))`. Buildings few (tens) but redraws run per tick while unpaused. | MEASUREMENT; magnitude ESTIMATE | **NEW — micro, zero risk** | Hoist `var bspr := _bld_tex(e)` once; memoize `_bld_key` by `(player, sid)` in a dict. | **None**. |
| 4b | Death-sheet existence probed every redraw for corpses with no baked sheet | `world.gd:3298-3305` (`_res_exists(_anim_sheet(ckey, "death"))` inside per-corpse loop) | Negative lookups (`ResourceLoader.exists` + string path build) repeated each unit redraw for every corpse whose sheet is absent; `anim_tex` caches only hits. Corpse arrays are capped but can be large after volleys. | MEASUREMENT; magnitude ESTIMATE | **NEW — micro, zero risk** | Cache missing keys in a `missing_death_sheets` Dictionary; probe once. Same fallback art. | **None**. |
| 5 | Unit anim descriptor lookups repeated per unit per frame | `world.gd:519-591` (`_anim_key:444`, `_anim_info:437`, `_anim_action:457`, dict gets `:552-581`, string formats `:542-544`) | Per visible unit/frame: 2 string formats + ~4 dict lookups + action fallback chain + `fposmod/roundf` before any draw. Scales with army size — the project's stated goal. | MEASUREMENT; magnitude ESTIMATE | **NEW — pursue with care** | Memoize an invariant descriptor keyed by `(key, act)`: resolved `a` dict values (`cell, frames, duration, fig_h, ax, ay, ortho`), sheet texture, nation key. Keep per-entity phase/death/fire frame selection and facing computation live. | **Low–medium** — descriptor must include every value that feeds `src`/`sc`/`tl`; verify by A/B screenshot before/after. Determinism: none (no RNG). |
| 6 | `view_rect.grow(64)` + `str(n.get("type"))` recomputed per resource node | `world.gd:2666-2669`, `:2670`, `:2684`, `:2699` | `res_layer` redraws on pan/fields-anim; loop still visits all ~1.6k `res_nodes` doing a fresh Rect2 + 2–3 `str()` conversions per node. After forest bake only dozens pass the cull, but scan cost remains. | MEASUREMENT; magnitude ESTIMATE | **NEW — safe** | Hoist one `var cull := view_rect.grow(64)` before the loop; compute `var ty := str(n.get("type",""))` once and reuse. **Do not** switch to `_res_grid` iteration — that would change draw order of overlapping props. | **None** — keep iteration order. |
| 7 | `fx_items` filter allocates a fresh Array every frame | `world.gd:2082-2084` | `fx_items = fx_items.filter(...)` runs each `sync()` even when list is empty. One array alloc/frame; usually no visual items. | MEASUREMENT | **NEW — trivial, low gain** | `if not fx_items.is_empty(): fx_items = fx_items.filter(...)` (or in-place reverse removal). | **None**. |
| 8 | Water shader — no further *safe* fetch reduction found | `water_overlay.gdshader:176-271` (esp. 4 normal taps `:199-202`, `noise()` `:103-105`, `repeat_enable` sampler `:39`) | Per PERFORMANCE_SWARM §3.6 static count, ~58 fetches/px deep after T-WATER-FAST. The 4 full-9-octave normal taps dominate; tapering them like the body would change `n` → glints/colour (algebraically **not** equivalent). Only safe op found: `fract()` in `noise()` is redundant with `repeat_enable` hardware wrap — ALU-only, **zero fetch reduction**. | MEASUREMENT (source); gain ESTIMATE | **NO_WIN for fetch count**; optional ALU micro-op below | Do **not** apply `BODY_TAPER` to normals (donor normal spectrum is a fidelity gate, `:89-92`). If desired, drop `fract()` in `noise()` (:104) after A/B proof. | HIGH for normal taper (would degrade donor glints); none for `fract` removal. |
| 9 | Minimap does two full-image duplicates per 0.25 s tick | `hud.gd:1522`, `:1568` (each `Image.duplicate()` of 320² RGBA8), box repaint `:1212-1251` | O(map pixels) ×2 per `MINIMAP_INTERVAL` (0.25 s HIGH). Not per-frame, so lower priority; already change-gated camera box. | MEASUREMENT; impact ESTIMATE | **NEW — lower rank** | Higher-effort: render the viewport box as a separate CanvasItem/overlay texture and keep one clean `minimap_img`→`minimap_tex` upload. | **Medium** — minimap layering/colour must be A/B'd. |
| 10 | Static chunk sprites traversed as ~130 Node2D children | `world.gd:1650-1657` (100 terrain sprites, no eviction), `:1883-1895` (≤20 forest sprites), `:1710-1720` (fallbacks), `:327-334` (fog/water) | Per-frame scene-tree/canvas-item traversal; Godot culls offscreen so gain likely small. | MEASUREMENT of structure; gain ESTIMATE (low) | **NEW — low rank** | Optional: one `draw_texture_rect` batch callback per layer instead of individual `Sprite2D`s. | **Medium** — z-order (-10/1/-9/10) and bilinear filter must match exactly. |
| 11 | Journey-mode camera focus rescans `live_units` every frame | `main.gd:1191-1204` | O(live_units)/frame — but only in `journey_mode` (capture/demo mode), not normal skirmish. | MEASUREMENT | **NEW — scoped, low rank** | Cache focus target for the 1 s `journey_cam_t` interval (recompute on timer, not every frame). | **None**. |

## Top-5 ranked actionable opportunities (gain × safety)

### 1. HUD per-frame unit/queue count — target `app/scripts/hud.gd`
- **Change:** at `:1096`, stop calling `game.unit_count(0)` + `game.queue_count(0)` unconditionally. Cache `ucount` behind a 0.5 s timer (mirror `eco_t` at `:1065-1068`) or a stale-key check; keep the existing `_last_status_text` guard at `:1101`.
- **Acceptance:** with HUD attached and 1000–3000 live units, no `unit_count`/`queue_count`/`buildings_of` call occurs in a frame where `status_label.text` is unchanged; status line still shows correct count within 0.5 s and on pause/score change.
- **Measure:** add temporary `Time.get_ticks_usec()` around `_process` counters in a numbers-only probe; reuse `t_perf_scale.gd` workload with HUD attached. `PERF ... sync_ms` in `main.gd:1153` is *not* a HUD metric — capture HUD self-time separately. Screenshot top bar before/after (only digit refresh timing may differ).

### 2. Reuse `pending_unit_sprites` descriptors — target `app/scripts/world.gd`
- **Change:** replace `clear()` at `:3127` + dict literals at `:590`/`:3061` with a reusable pool (`pending_size` + preallocated dicts, overwrite fields, never free).
- **Acceptance:** identical `_draw_unit_sprites` call sequence (same tex/dst/src/tint, same order) on a fixed seed; zero new dict allocations per frame in a profiler allocation view; `t_mass_army`/`t_hud_fidelity` still PASS.
- **Measure:** `t_mass_army` + screenshot A/B at fixed seed/camera; profiler allocation counter if available (else structural claim only).

### 3. Post-bake chunk scheduling early-out + shared range — target `app/scripts/world.gd`
- **Change:** in `_sync_terrain_chunks()`, once all map keys are resident skip the `:1792-1801` LOD loop and the `:1744-1746` reconciliation; compute `c0x/c0y/c1x/c1y` once in `sync()` (`:2035-2037`) and pass to both terrain and forest syncs. Keep 2-chunk bake cap, centre-out sort, generation guard and LRU untouched.
- **Acceptance:** `t_forest_bake` 9/9 and `t_forest_bake_render` 3/3 still PASS; `BAKE_BENCH` line still emitted (`app/tools/bake_bench.py`, max_ms<250 gate); seed dump byte-identical; minimap jump still shows no clear-colour hole (`has_chunk_or_fallback` invariant).
- **Measure:** `bake_bench.py` (contract: engine `BAKE_BENCH` line, `PERF sync_ms` is context only); grid_peak on a fresh capture (<0.20) + full-map screenshot; count `full_q`/`q` build iterations via temporary counter in a numbers-only probe.

### 4. Building key + corpse negative-lookup caches — target `app/scripts/world.gd`
- **Change:** hoist `var bspr := _bld_tex(e)` once in `_draw_buildings()` (`:2808`/`:2811`); memoize `_bld_key` by `(player,sid)`; add `missing_death_sheets` set at `:3304`.
- **Acceptance:** same sprite/decal/flag output in a fixed-seed screenshot; `_bld_key` called ≤1× per building per redraw; no repeat `_res_exists` for a known-missing death sheet. `t_hud_fidelity` / `t_capture` PASS.
- **Measure:** temporary call counters in a numbers-only probe; screenshot A/B over a town with several buildings and a fresh volley.

### 5. Unit anim descriptor memoization — target `app/scripts/world.gd`
- **Change:** memoize by `(key, act)` the invariant results of `_anim_key`, `_anim_info`, action dict fields (`cell, frames, duration, fig_h, ax, ay, ortho`) and the loaded sheet texture; keep `_anim_action(e)`, phase, `t0`, facing `dir`, and `src/dst` computation per unit/frame.
- **Acceptance:** A/B screenshot at fixed seed with idle/walk/gather/attack/carry/death states byte-identical (or pixel-diff within antialiasing noise); `t_anim_metrics`, `t_hud_fidelity`, `t_mass_army` PASS; no change to `anim_tex` load semantics.
- **Measure:** screenshot pair + `t_anim_metrics`; temporary self-time around `_draw_anim` in a numbers-only probe, same unit count before/after. If visual diff appears, revert — fidelity wins over gain.

## Open questions

1. **No frame-time numbers exist for any claim above.** All `ESTIMATE` magnitudes need a numbers-only, same-seed/same-unit-count probe before any LANDED claim. Can the coordinator run a HUD-attached variant of `t_perf_scale.gd` that reports per-function self-time (not just `sync_ms`)?
2. **Does `journey_mode` matter to the acceptance workload?** If captures use it, item 11 rises in rank; if not, it stays scoped/low.
3. **Anim descriptor memoization cache key** — does `Data.EXTRA_ANIM_INDEX`/naval resolution ever mutate at runtime after `bind()`? If yes, memo invalidation must hook the same path as `anim_tex` (source read suggests it is static, UNVERIFIED at runtime).
4. **Minimap box overlay** (item 9) would change HUD widget structure: worth a dedicated lane with a visual owner, or leave the two duplicates (0.25 s cadence) alone?
5. **Chunk-sprite batching** (item 10): does the project's QA gate require a scene-tree Node2D count target, or is canvas-item culling sufficient? No such target found in the docs read.
6. **Water `fract()` removal** — is the wave sampler's `repeat_enable` honoured in exported builds? A/B proof required; otherwise leave the shader strictly untouched after T-WATER-FAST.
