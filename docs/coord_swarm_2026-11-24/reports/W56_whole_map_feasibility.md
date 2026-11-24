---
owner: W5-6
wave: 5 (read-only recon)
swarm: coord_swarm_2026-11-24
date: 2026-11-24
scope: whole-map terrain feasibility — ONE runtime ImageTexture vs 100 chunk sprites
read_only: true
no_godot_run: true
method: source reading + pure-Python arithmetic (temp calc script outside repo)
output: docs/coord_swarm_2026-11-24/reports/W56_whole_map_feasibility.md
verdict: low=FEASIBLE, med=RISKY, high=BLOCKED-as-specified (startup hitch is the top risk)
---

# W5-6 — Whole-map terrain feasibility (evidence-based)

**Owner directive (verbatim, `WAVE5_CHARTER.md:29-38`):** "Once map is created, don't render it in
chunks — keep the whole built map in memory; it's relatively small." The charter's 25/56/100 MiB
figures are confirmed below. **Memory is not the problem — it is already resident in 100 sprites.**
The problem is that the work moves from 2 bakes/frame (spread over gameplay) into one startup hitch.

Tags: **[M]** = measurement from source constants + arithmetic; **[B]** = measured benchmark
found in repo docs/stdout; **[E]** = estimate, explicitly not measured; **[X]** = external doc.
No Godot run, no code edit, no asset change by W5-6. `main.gd` was being edited concurrently by
W5-2 during recon (line numbers moved +11 between reads) — re-grep before any handoff edit.

## 1. Configuration and bake path (source-read)

| Item | Value | Evidence |
|---|---|---|
| Runtime map size | **320×320 tiles** (not the 160 fallback) | `app/config.json:37-38`; `app/scripts/config.gd:405-406` overrides `data.gd:33-34` (160) |
| Tiles per chunk | `CHUNK_T = 32` | `app/scripts/world.gd:31` |
| Chunk grid | `ceil(320/32)² = 10×10 = 100` **[M]** | `world.gd:1749-1750,1762-1763,1751-1752` (comment "100 chunks at 320x320") |
| Quality presets | low 8 / medium 12 / high 16 px/tile | `app/scripts/data.gd:114-115,148-159` |
| Bake pixel formula | `bpx = min(terrain_px*4, 64)` → 32/48/64 | `world.gd:1031-1034` |
| Composite pixel | `comp_px = bpx if px > 8 else px` → **8/48/64** (low has NO supersample) | `world.gd:1542`; rationale `:1538-1541` |
| Per-bake image | `S = CHUNK_T*comp_px` → 256/1536/2048 | `world.gd:1543-1544,1550,1565` |
| Resolve / upload | `img.resize(CHUNK_T*px, CHUNK_T*px, BILINEAR)`; `ImageTexture.create_from_image`; one `Sprite2D` per chunk | `world.gd:1662-1663,1664-1672` |
| Anti-seam path | `_alpha_mask()` + `blend_rect_mask` per role, before resize | `world.gd:1076-1079,1593-1620,1626-1659` |
| Caches | `terrain_chunks` (100, no eviction), `full_chunks`, `terrain_order`, `fallback_chunks` + one shared 32×32 fallback tex; `BLK_CACHE = 32`, `BLOCKS_PER_CHUNK = 6` | `world.gd:31-39,67,71,1693-1735` |
| Bake rate cap | **2 full bakes/frame**, centre-out; distant LOD budget 8000 µs/frame; fallback reconciled every frame | `world.gd:1768-1781,1805-1815,1817-1828` |
| Forest bake | Separate GPU `SubViewport` bake, LRU 20, `FOREST_BAKE_PXM=8`, margin 128 screen px | `world.gd:103-106,1845-2045` |
| Bench emitter | `BAKE_BENCH preset=low px=8 chunks=120 …` is **hardcoded**; max/mean are the only real fields | `world.gd:166-174`; `perf.md:241-246` |
| Engine | Godot **4.7.2** stable | `app/.godot_queue/results/00001288_w42-zoom-input3/stdout.txt:1` |

## 2. Memory arithmetic (MEASUREMENT — 4 bytes/pixel RGBA8)

| Preset | px/tile | bpx | comp_px | Per-chunk final side | Per-chunk pixels | Per-chunk RGBA8 bytes | Whole-map side | Whole-map pixels | Whole-map RGBA8 bytes (MiB) | Whole-map RGB8 bytes (MiB) |
|---|---|---|---|---|---|---|---|---|---|---|
| low | 8 | 32 | 8 | 256² | 65,536 | 262,144 (0.25 MiB) | **2560²** | 6,553,600 | **26,214,400 (25.00)** | 19,660,800 (18.75) |
| medium | 12 | 48 | 48 | 384² | 147,456 | 589,824 (0.56 MiB) | **3840²** | 14,745,600 | **58,982,400 (56.25)** | 44,236,800 (42.19) |
| high | 16 | 64 | 64 | 512² | 262,144 | 1,048,576 (1.00 MiB) | **5120²** | 26,214,400 | **104,857,600 (100.00)** | 78,643,200 (75.00) |

`100 × (32·px)² = (320·px)²` exactly **[M]** — one whole-map texture has the same pixel count
as the 100 chunk textures it replaces. Confirms `WAVE5_CHARTER.md:33-35` (25/56/100 MiB).
CPU-side `img` can be RGB8 (3 B/px) after `world.gd:1659`; RGBA8 is the conservative upload figure.

**Resident today **[M]**: 100 chunk textures (25/56/100 MiB) + LOD/fallback + forest cache.
Forest cache: `bake_side = 512`, `bm = int(128*8/16) = 64` → 640² RGBA = 1,638,400 B × 20
LRU = **31.25 MiB CPU + ~31.25 MiB GPU ≈ 62.5 MB** (`world.gd:103-105,1918-1919,1885-1890`),
consistent with the `world.gd:105` "~64 MB" comment. A terrain-only whole-map change does **not**
remove this forest chunk cache.

## 3. GPU texture limits

| Candidate image | Side | RGBA8 bytes | 16384² cap | Note |
|---|---|---|---|---|
| Runtime low final | 2560² | 25 MiB | **fits** | — |
| Runtime med final | 3840² | 56.25 MiB | **fits** | — |
| Runtime high final | 5120² | 100 MiB | **fits** (also fits conservative 8192) | **[X]** Godot `ImageTexture` docs: max 16384²; older desktops may stop at 8192, mobile at 4096 (`https://docs.godotengine.org/en/stable/classes/class_imagetexture.html`, `…/tutorials/3d/3d_rendering_limitations.html#texture-size-limits`) |
| med **supersample intermediate** | 15360² | 900 MiB | fits, **no margin** | `comp_px=48` → `320*48`; keep as RAM `Image`, downsample before upload |
| high **supersample intermediate** | **20480²** | **1.6 GiB** | **DOES NOT FIT** | `comp_px=64` → `320*64` — must stay a RAM `Image`, never an `ImageTexture`; diagnostic-only size per `WAVE5_CHARTER.md:35-36` |
| diagnostic 64 px/tile PNG | 20480² = 419,430,400 px | 1.5625 GiB | n/a (offline PNG) | `app/tools/full_map_shot.py:8-14,82-85`; `SWARM_BOARD.md:244,377`; `docs/audit/PIECES/map_density.md:54-55` |

**[X]** Check at runtime with `RenderingServer.get_rendering_device().limit_get(LIMIT_MAX_TEXTURE_SIZE_2D)`
(Godot docs / Godot issue #87119); **no such query exists in-repo**. All three final textures fit the
usual 16384 cap; the cap only bites a naive high-preset supersample **upload**, not the final 5120².

## 4. Bake time: measured anchors → 100× extrapolation (ESTIMATE)

### 4.1 Measured anchors (per single chunk bake)

| Value (ms) | Source | Caveat |
|---|---|---|
| **50.06 max / 43.59 mean** | `SWARM_BOARD.md:204,609,611` (job `render1-bench-opt/656`) | post-optimisation, LOW, gate PASS vs 250 ms |
| **196–221** | `SWARM_BOARD.md:384` (build-wave gates) | reported "<250"; preset not independently labelled |
| 107.18 / 109.33 | `docs/t6/QA_LANE.md:431,523` (jobs 1076/1070) | single-bake lines |
| 645.24 / 526.63 (cold cache) | `app/shots/perf.md:221-239` (job `qa1-bench-4/639`) | only ~12–20 bakes actually occurred; "chunks=120" is a contract label, not a count (`perf.md:241-246`) |
| 1355–3753 max | `app/.godot_queue/results/*/stdout.txt` (e.g. `00001288:6`, `00001232:11`) | **saturated machine**, NOT comparable to the 50 ms gate (`PROGRESS.md:36-37`) |
| **~5000 ms** per FULL HIGH bake | `world.gd:1756` (source comment) | the current reason for the 2/frame cap; not a doc bench line |

Every `BAKE_BENCH` line carries the hardcoded `preset=low px=8 chunks=120` label
(`world.gd:172`); only job 636 verified LOW independently (`perf.md:225,242-246`).
**There is no measured med/high bake time in the repo.** All med/high numbers below are ESTIMATE.

### 4.2 Extrapolation to one whole-map bake **[E]**

100 chunks × per-chunk anchor; output pixel count is identical to one whole-map image
(§2), so ×100 is a fair first-order model. A single bake can save repeated setup/LRU churn, but that
saving is unmeasured; the 2/frame protection disappears entirely.

| Anchor | ×100 one-shot **[E]** | Current 2/frame equivalent **[E]** |
|---|---|---|
| 43.59 / 50.06 ms | **4.36 / 5.01 s** | 50 bake-frames × ~2×50 ms ≈ 5 s of hitches |
| 107–109 ms | 10.7–10.9 s | ~11 s of hitches |
| 196–221 ms | **19.6–22.1 s** | ~20–22 s of hitches |
| 645 / 526 ms (cold) | 64.5 / 52.7 s | ~1 min of hitches |
| ~5 s HIGH (source comment) | **~500 s (8.3 min)** | exactly the `world.gd:1756` warning |

| Preset | One-shot bake **[E]** | Basis / uncertainty |
|---|---|---|
| low (8) | **4.4–22 s** | 43.59–50.06 ms measured anchor to 196–221 ms wave anchor |
| med (12) | **11–180 s** | 2.25× final pixels vs low → 11 s; 36× composite pixels (1536² vs 256²) → ~180 s if composite-bound; unmeasured, deliberately wide |
| high (16) | **20–500 s** | 4× final pixels to the source's ~5 s/chunk HIGH figure; 20480² intermediate adds RAM pressure; unmeasured |

**Loading screen today (`main.gd`, current read):** `_loading_tick` awaits 2 process frames per stage
(`:495-501`); stages at `:542` (0.76 "Painting terrain..." — actually `game._assign_tileblocks()`),
`:550` (0.90 "Loading art..."), `:555` (0.94 "Building interface..."); `world.bind(game)` is a
synchronous call at `:553` and **does no terrain bake**. A one-shot bake inside `bind()` would freeze
the progress bar for its entire duration with no repaint.

## 5. Exact change sites — W5-3 owns `world.gd` (NO edit by W5-6)

| Lines | Change needed |
|---|---|
| `:31-48` | Replace `terrain_chunks`/`full_chunks`/`terrain_order`/`fallback_chunks`/`fallback_tex` with one `terrain_img`/`terrain_tex`/`terrain_sprite` + dirty/signature flag; keep `bake_bench_*` but repurpose emitter |
| `:166-174,176-181` | Emit real preset/px and whole-map ms (current `preset=low px=8` is hardcoded); keep one-line-only contract |
| `:229-259` (`bind`) | Add/expose the whole-map build (preferably an awaitable staged coroutine, see §6); retain block pre-warm `:240-259` — it is what makes 50 ms possible |
| `:1031-1034,1542-1544` | Decide final-res single pass vs 4× supersample whole-map intermediate; high must not allocate 20480² if avoidable (row bands / tiles within one `Image`) |
| `:1535-1673` (`_build_chunk`) | Rewrite to `_build_whole_map()`: drop `cx/cy`, `S = MAP_W*comp_px`; identical compositing order (`:1552-1620`), tint/relief (`:1626-1659`) and resolve (`:1662-1663`); one `ImageTexture` + one `Sprite2D` at `position=0`, `scale=TILE_M*view_scale/px` (`:1664-1672`) |
| `:1693-1735` | `_build_chunk_low`, `_fallback_texture`, `_make_chunk_sprite` become dead (no holes ⇒ no fallback); `has_chunk_or_fallback()` at `:1738-1739` is used by tests — keep a compatible trivially-true API until W5-3's new probe lands |
| `:1741-1828` (`_sync_terrain_chunks`) | Reduce to one dirty/signature guard; delete `full_q` sort `:1768-1777`, 2/frame cap `:1779-1781`, LOD warm-up `:1805-1815`, fallback reconcile `:1817-1828` |
| `:1845-2045` (forest) | **Unchanged** — forest detail stays a per-chunk GPU bake with LRU 20. Tell owner "no chunk rendering" is achieved for terrain only |
| `:2047-2052` (`sync`) | Keep `_sync_forest_chunks()`; terrain call becomes a no-op/dirty check. No per-frame scan/sort remains |
| `:955` water shader `map_size` | Unaffected |

Visual-seam risk is **low**: the existing seam defence is inside `_alpha_mask`/`blend_rect_mask`
(`:1076-1079,1593-1620`) and is preserved by building one image in one pass; chunk borders stop
being implementation boundaries at all. Donor-texture repetition seams (a separate known visual
residual) are not changed by this refactor.

## 6. HANDOFF to W5-2 (`main.gd`) — no edit by W5-6

| # | Handoff | Why / exact site |
|---|---|---|
| H1 | Add a new awaited loading stage for the whole-map bake, e.g. between `world.bind(game)` and "Building interface..." (`main.gd:552-555`), or make `bind()` expose `build_terrain_async()` that `main.gd` awaits inside `_loading_tick` with the existing `gen` guard (`:495-501`). Do **not** call a synchronous 4–500 s bake at `:553`. | Progress bar currently repaints only between `_loading_tick` stages; binding is synchronous |
| H2 | If one-shot is too slow, agree a staged protocol: world bakes N row bands per awaited frame, returning progress; main.gd advances the bar with a new fraction (e.g. 0.90→0.94) rather than adding a long stall. | Only way to keep 4–500 s ESTIMATE from looking like a hang |
| H3 | Quality-change handler `main.gd:1254-1263` currently frees/clears `world.terrain_chunks`, `terrain_order`, sets `terrain_px`, invalidates forest bake and rebuilds masks. Replace with `world.invalidate_whole_terrain()` + async rebuild; keep old sprite alive until the new one is ready; no frame with a null texture. | Same caches disappear in §5 |
| H4 | Keep forest bake invalidation at the quality-change site (`:1262`) and ensure the new terrain signature (`world.gd:1847-1852`) still includes `terrain_px` so forest canopies match the new texture scale. | Forest path unchanged |
| H5 | Bench/tooling contract: new emitter should print real `preset=<q> px=<n> whole_map_ms=<m>`; QA's `bake_bench.py` parses the old `BAKE_BENCH … max_ms=` line — coordinate label change with QA before landing. | `world.gd:172`; `app/shots/perf.md:199-210` |
| H6 | Re-grep line numbers before editing: W5-2's concurrent edits moved `main.gd` +11 lines during this recon (earlier read had quality handler at `:1096-1102`, current at `:1254-1263`; loading stages earlier `:516-584`, now `:527-595`). | Honest line-number drift |

## 7. Verdict table

Definitions: **FEASIBLE** = GPU fits and bake can be hidden in a staged load (<~10 s ESTIMATE);
**RISKY** = GPU fits but bake/intermediate likely exceeds that and needs measurement;
**BLOCKED-as-specified** = one-shot startup bake with the current recipe cannot meet the budget.

| Preset | Final texture | Whole-map RAM | One-shot bake **[E]** | Verdict | Single biggest risk | How to measure it |
|---|---|---|---|---|---|---|
| low (8) | 2560² | 25 MiB | 4.4–22 s | **FEASIBLE** (if staged in loading) | **Startup hitch** | Emit `whole_map_ms` once from engine; record max gap between loading-bar repaints; compare to current 2/frame hitch log |
| med (12) | 3840² | 56.25 MiB (900 MiB intermediate if 4× supersample) | 11–180 s | **RISKY** | **Startup hitch** (900 MiB intermediate is secondary) | Same bake timer + peak `Image` byte counter + windowed frame-time delta on first pan |
| high (16) | 5120² | 100 MiB (1.6 GiB intermediate) | 20–500 s | **BLOCKED as specified** — conditional RISKY only if supersample omitted/row-banded and bake staged | **Startup hitch** (GPU limit only if 20480² is uploaded; seam risk lowest) | Same timer, `limit_get(LIMIT_MAX_TEXTURE_SIZE_2D)`, assert no `ImageTexture` ever created at >16384², and byte-diff a same-seed chunked vs whole-map frame |

**Answer in one line:** the whole-map texture itself is safe at all three runtime presets; the
decision rests entirely on whether the ~4–500 s bake can be hidden behind the loading screen. The
owner's memory premise is correct, but the perf premise is not free — today's 2-chunk/frame cap
(`world.gd:1779-1781`) is the only thing preventing that cost from landing in one frame.

## 8. Open questions

1. What preset was actually active for the 196–221 ms build-wave bench and the 107–109 ms jobs? The emitter label is hardcoded (`world.gd:172`); only job 636 was independently verified LOW (`perf.md:225`).
2. Does one whole-map composite really cost ~100× one chunk, or does shared atlas/block setup cut it materially? Needs an instrumented engine run (W5-3), not arithmetic.
3. Can the 4× supersample be replaced by a single-pass final-res bake at med/high without visible edge-quality loss? If yes, 900 MiB/1.6 GiB intermediates and most of the ESTIMATE range collapse.
4. Does the 5120² high texture pass the target hardware's `LIMIT_MAX_TEXTURE_SIZE_2D`, and do we still support 4096-limited mobile/web targets? (No in-repo query.)
5. Is the forest chunk bake (31.25 MiB ×2, LRU 20) in scope for "whole built map in memory", or terrain-only? Report assumes terrain-only.
6. Who owns the new bench line label and `app/tools/bake_bench.py` parser change (H5)?
7. Should `has_chunk_or_fallback()` survive as an API stub for tests until W5-3's new `t_chunk_schedule_light.gd` replaces it?
8. Main.gd line drift from the concurrent W5-2 edit — re-read at implementation time (H6).

## 9. Evidence index

- `docs/coord_swarm_2026-11-24/WAVE5_CHARTER.md:29-38` — directive, 100 chunks, 25/56/100 MiB, 20480² diagnostic caveat.
- `app/scripts/world.gd:31-48,103-106,166-174,229-259,1031-1034,1076-1079,1535-1673,1693-1735,1738-1828,1845-2052` — all chunk/bake/forest/sync code.
- `app/scripts/data.gd:23,33-34,114-115,148-159`; `app/config.json:37-38`; `app/scripts/config.gd:405-406` — map size and presets.
- `app/scripts/main.gd:495-501,542-555,595,1254-1263` — loading stages and quality-change cache clear.
- `docs/SWARM_BOARD.md:204,384,609,611`; `app/shots/perf.md:221-254`; `docs/t6/QA_LANE.md:431,523`; `app/.godot_queue/results/00001288_w42-zoom-input3/stdout.txt:1,6`; `docs/coord_swarm_2026-11-24/PROGRESS.md:36-37` — bench measurements and caveats.
- `app/tools/full_map_shot.py:8-14,82-85`; `docs/SWARM_BOARD.md:244,377`; `docs/audit/PIECES/map_density.md:54-55` — 20480² diagnostic only.
- Godot docs: `class_imagetexture` (16384² max), `3d_rendering_limitations#texture-size-limits` (8192 older desktop / 4096 mobile); GitHub issue #87119 (query `LIMIT_MAX_TEXTURE_SIZE_2D`, typically 16384).
