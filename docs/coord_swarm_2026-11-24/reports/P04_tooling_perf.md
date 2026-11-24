---
owner: P4
wave: perf
date: 2026-11-24
scope: read-only recon of app/tools + app/scripts/main.gd startup; no Godot run, no edits outside this file
---

# P4 — Tooling / test / startup performance recon

Labels: **MEASUREMENT** = timed on this machine today (pure Python, `--help`, or tiny
inputs only); **ESTIMATE** = derived from reading code, no Godot run (charter gate 1);
**UNVERIFIED** = attempted but measurement invalid.

## Claim table

| ID | file:line | Finding | Cost (label) | Minimal fix | Risk |
|----|-----------|---------|--------------|-------------|------|
| C1 | `app/tools/godot_runner.py:55,207-221,288-303` | `wait_for_turn()` calls `pid_alive()` on **every** 0.15 s poll, unconditionally — even while a healthy Godot job holds the lock. On Windows `pid_alive()` spawns `tasklist /FI PID eq N`. | **MEASUREMENT** 10× `tasklist /FI "PID eq 4"` = 9,927 ms → **993 ms/call**. Each waiting ticket therefore burns ~1 s of subprocess work per nominal 0.15 s poll; N queued agents = N tasklist spawns/sec. | Only call `pid_alive()` when `lock_free` (no lock ⇒ no proof of life); throttle to ≤1 check per ~2 s per serving ticket (cache ticket + timestamp). Keep the `lock_stale` branch. | Low. Worst case dead-holder reclaim slips ≤2 s; already bounded by `--max-wait`. Never skip a live holder. |
| C2 | `app/tools/scan_map.py:71-89,114-128,131-153,174-215` | 320² scan uses `(x,y)` tuple sets for BFS (`count_patches`, `reachability`), and `sand_ring` builds an 8-tuple neighbour list per water tile. `cliff_ring` is a flat Python loop over 102,400 cells. | **MEASUREMENT** `scan_map.py --dir scans` (39 × ~1 MB dumps) = **28,549 ms**. Per 320² file: `cliff_ring` 214 ms, `sand_ring` 192 ms, `count_patches` 71 ms, `reachability` 35 ms — ~512 ms of the ~710 ms/file in these four. | Flat `bytearray` visited arrays indexed `y*w+x`; fixed 8-offset neighbour table with bounds checks in `sand_ring`; keep BFS semantics identical. | Medium. Geometry/gates must stay byte-identical — A/B all 39 rows before/after. No visual change (diagnostic tool only). |
| C3 | `app/tools/scan_map.py:253-255,58-60`; `app/tools/terrain_geometry_verify.py:184-185,189` | Every dump is `json.load`ed twice: once in file discovery, again in `load_scan()`; `decode_dump()` likewise opens+parses then calls `load_scan()` (third read path). | **MEASUREMENT** 1 MB dump: first `json.load` 12.5 ms, second 7.9 ms; `load_scan` 94.6 ms (base64 + float32). ×39 files ≈ **0.8 s/run** of pure duplicate parsing. | Cache the parsed dict from discovery and pass it to `scan_one`/`load_scan` (add optional `d=None` param); same in `decode_dump`. | Low. One extra optional parameter, no behaviour change. |
| C4 | `app/tools/terrain_piece_render.py:306-328,705-720,735,806-837,883,1008,1258-1289` | Every layer/spec re-opens the same block/wave PNGs and re-runs `mirror_tileable()` (RGB convert → resize to 1024² → 3 transposes → paste → resize). 21 specs, 17 hits on common block names. | **MEASUREMENT** 21 spec files, 17 references to repeated block names. PIL import overhead **MEASUREMENT** 576 ms vs 172 ms bare Python (+404 ms/invocation); earlier 4.0 s `--help` was a cold-start outlier, not used. Per-tile resize cost **ESTIMATE** (no full render run). | Module-level memo cache keyed `(path, tile_size, resample)`; return a copy if any caller mutates. | Low-medium. ~3 MB per cached 1024² RGB tile; ~20 unique assets ≈ 60 MB. Verify no caller mutates the cached image. |
| C5 | `app/scripts/main.gd:744-771` | `_relief_focus_position()` scans `MAP_W×MAP_H×49` cells in GDScript at startup, only for `--screenshot` with `screenshot_focus=relief`. | **ESTIMATE** 320²×49 ≈ 5.0 M inner iterations; likely seconds in GDScript. No Godot run (charter gate 1). | Integral-image / row prefix sums → O(1) 7×7 mean per tile (O(W×H) total), or coarse-to-fine pass. Must keep the water skip. | Medium. Floating-point sum order changes could shift the chosen tile by rounding — verify focus on a known dump before landing. Niche mode. |
| C6 | `app/scripts/main.gd:1135-1138` | `Time.get_ticks_usec()` called twice immediately after `game.tick()` (up to 64 ticks/frame). | **ESTIMATE** ~128 extra engine calls/frame worst case; microseconds each. | Compute `elapsed` once, reuse for both accumulators. | Trivial. |
| C7 | `app/scripts/main.gd:1402-1471,1433-1436` | `_render_headless_image()` uses per-pixel `img.set_pixel()` for each terrain tile (≈358 k calls for 800×600 / 320² map). | **ESTIMATE** hundreds of thousands of GDScript calls at screenshot end. | `img.fill_rect(Rect2i(px0,py0,py1-px0,py1-py0), c)` per tile (=102 k calls) or batch equal-colour runs. Visual A/B required. | Low-medium. A/B PNG before landing. |
| C8 | `app/tools/godot_runner.py:178-188`; `assert_clean.py:48-82`; `godot_runner.py:224-241,418-438` | `record()` reads+rewrites the whole `status.json` history (≤500 entries) with fsync per job; process checks spawn PowerShell `Get-CimInstance Win32_Process`. | **ESTIMATE** history rewrite O(n) per job — small. CIM cost **UNVERIFIED** (my quoting produced PowerShell parse errors; do not cite the 8.2 s figure). | Append-only per-job result files; derive `status` on read. Cache CIM result within a single `assert_clean` invocation. | Low for caching; medium for status format change (gates read it). |
| C9 | `app/tools/test_all.py:91-93,48-49` | 24 ready tests submitted strictly sequentially; each re-pays Python startup + runner queue wait. | **MEASUREMENT** `app/tests/results/summary.json`: 19 results, total ≈140 s; slowest `t_mill_rotor` 18.58 s (windowed), median ≈6 s. 24× Python startup (172 ms bare / 0.5-1.9 s runner `--help`, high variance). | Persistent runner or batch-submit mode to amortise interpreter startup; Godot itself stays serialised. | Medium-high. Queue semantics/spool isolation must not change. `t_mill_rotor` is inherently slow (GPU frame wait) — not a tooling fix. |
| C10 | `app/tools/full_map_shot.py:361-399,381-386` | 102,400 `band.paste()` calls for a 320² tile_px=64 map; per-row `b"\x00" + raw[...]` allocation. | **ESTIMATE** dominant cost, but docstring:351-353 documents the 1.2-1.7 GB full-buffer spike this streaming design avoids. | **Rejected** — no safe minimal win; a single full-size buffer trades correctness/OOM for speed. Leave as-is. | n/a |
| C11 | `app/tools/terrain_geometry_verify.py:219-231` | `tuple(cur["height"]) != tuple(base["height"])` copies 102,400-element tuples just to compare. | **ESTIMATE** ~ms; `load_scan()` already returns a tuple. | Compare directly: `cur["height"] != base["height"]`. | Trivial. |

## Top 5 (developer-time saved × safety)

1. **C1 — `app/tools/godot_runner.py:296` (MEASUREMENT).** Minimal change: gate the
   liveness check on `lock_free` and throttle it to ~2 s per serving ticket.
   Measurement plan: time `python app/tools/godot_runner.py run` while another job
   holds the lock for 30 s; count `tasklist` child processes (`Get-CimInstance`
   before/after) and compare wait CPU. Expected: ~1 spawn/s → ~0.5 spawn/s or less.
   Biggest win: every queued agent in a swarm pays this today.

2. **C2 — `app/tools/scan_map.py:71-89,114-128,131-153,174-215` (MEASUREMENT).**
   Minimal change: flat `bytearray` visited arrays + fixed neighbour offsets;
   no algorithmic change. Measurement plan: `python app/tools/scan_map.py --dir scans`
   (28,549 ms baseline); must print the **same 39 rows and ALL GREEN** verdict.
   Target ≤10 s. If numpy is available in the tool interpreter, vectorising
   `cliff_ring`/`sand_ring` is a larger but riskier follow-up (open question Q3).

3. **C3 — `app/tools/scan_map.py:253-255` + `terrain_geometry_verify.py:184-189`
   (MEASUREMENT).** Minimal change: optional pre-parsed `d` argument threaded from
   discovery into `scan_one`/`load_scan`/`decode_dump`. Measurement plan: same 39-file
   run; expect ~0.8 s saved; diff the full report text for equality. Highest
   safety-per-line in this table.

4. **C4 — `app/tools/terrain_piece_render.py:306-328` (ESTIMATE for render, MEASUREMENT
   for repeated references).** Minimal change: memoize `mirror_tileable(Image.open(...))`
   by `(path, tile_size, resample)`. Measurement plan: time a full 21-spec directory
   render before/after with `--out-dir` pointing at a temp dir; compare every PNG's
   sha256 in the manifests. Watch peak RSS (~60 MB extra).

5. **C5 — `app/scripts/main.gd:744-771` (ESTIMATE).** Minimal change: integral image
   for the 7×7 mean. Measurement plan: needs a Godot run by a wave-2 builder (not P4):
   use `--screenshot ... --config` with `screenshot_focus=relief` on a fixed seed and
   compare camera focus + PNG before/after. Deliberately 5th because it is a niche
   mode and cannot be measured under this recon's no-Godot gate.

## Open questions

- **Q1** The brief names `app/tools/verify/*.py`, but no such directory exists. Glob
  `**/*verify*.py` finds only `app/tools/terrain_geometry_verify.py`. Did the
  coordinator mean a different path? Recon covered that single file.
- **Q2** Does any caller of `mirror_tileable()` mutate the returned image? Static
  reads show only `paste`/`crop`/`convert` downstream, but confirm before returning a
  shared cached object (return `.copy()` if unsure).
- **Q3** Is numpy importable in the tool Python? If yes, C2 vectorisation could beat
  the flat-array rewrite; if no, C2's pure-Python fix stands.
- **Q4** Can dead-holder reclaim tolerate a ≤2 s detection delay? Coordinator call —
  `--max-wait` (default 3600 s) still bounds total starvation.
- **Q5** All tasklist/CIM numbers are machine-specific (AV, CPU load). Re-measure on
  the primary dev box before quoting them in IMPROVEMENTS.md; **UNVERIFIED** CIM
  measurement must be redone with a script file, not an inline quoted string.
- **Q6** C7/C5 changes touch visual output — wave 2 must do visual A/B before metrics
  per charter gate 5b-QUALITY. P4 did not run Godot and did not edit game code.
