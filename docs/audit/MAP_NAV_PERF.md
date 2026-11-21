# MAP_NAV_PERF — minimap left-click jump: latency + first-seconds graphical errors

Role: T2-NAV, read-only audit. No code changed, no Godot run performed. All numbers below are from source reading plus recorded engine output already in the repo (`BAKE_BENCH` lines under `app/.godot_queue/results/`, summarised in `app/shots/perf.md`). Every claim is tagged **observed** (read directly in source/config), **derived** (arithmetic from observed constants), or **inferred** (reasoning about runtime ordering).

---

## 1. Sources read (file:line)

| File | Lines | What it establishes |
|---|---|---|
| `app/scripts/hud.gd` | 974-977, 986-1030, **1032-1046**, 1062-1149 | Minimap build, `_on_minimap_input` (click→camera), periodic `_update_minimap` |
| `app/scripts/input_controller.gd` | 109-122, 258-349, 767-794 | Left-click on world vs. HUD; `minimap_order` is **right**-click only |
| `app/scripts/camera.gd` | 16-31, 33-41, 43-70, 72-92 | Zoom range, `clamp_pos`, `_process`, when clamping happens |
| `app/scripts/world.gd` | 16-43 (constants), 1048-1180 (`_build_chunk`), **1182-1219** (`_sync_terrain_chunks`), **1221-1252** (`sync`), 1257-1299 (`_update_fog`), 1455-1474 / 1552-1569 (decor draw) | Chunk bake cost, 2-chunk cap, LRU-24, redraw gates, fog |
| `app/scripts/main.gd` | 238-249 (map size), 1042-1045 (`world.sync` call + `dbg_sync`), 1066-1071 (journey lerp) | Frame loop, sync timing instrumentation |
| `app/scripts/data.gd` | 23, 33-34, 55, 115, 118-119, 148-159, 162-163 | TILE_M, default map, fog default, quality presets, zoom heights |
| `app/scripts/config.gd` | 354, 358-362, 370-380 | Config load of fog/minimap/zoom/map size |
| `app/config.json` | 14-24, 25-34, 35-39 | 1280×720, 16 px/m, fog off, 320×320 map, vsync |
| `app/project.godot` | 13-19, 21-28 | Viewport 1280×720, GL Compatibility renderer |
| `app/shots/perf.md` | 199-249 | BAKE_BENCH contract, N-07 FAIL at 645 ms max / 526 ms mean |
| `app/.godot_queue/results/*/stdout.txt` | BAKE_BENCH lines | Recorded per-chunk bake times (44 ms … 1688 ms) |

---

## 2. The click → camera → chunk path

**Left-click on minimap (the owner's "fast move") — exact path:**

1. `hud.gd:1030` wires `minimap_rect.gui_input` → `_on_minimap_input`.
2. `hud.gd:1033-1034` — hit test is `get_local_mouse_position() / minimap_rect.size`, then `world_pos = Vector2(mp.x*MAP_W, mp.y*MAP_H) * TILE_M`. **O(1), no texture read.**
3. `hud.gd:1038-1039` — `if button == LEFT and cam: cam.global_position = world_pos * world.view_scale`. The camera jumps **instantly, in the input event**, with no tween/lerp. (Drag variant at `hud.gd:1045-1046` does the same each motion event.)
4. Note: `input_controller.gd:109-122` `minimap_order()` is invoked only for **right**-click (`hud.gd:1040-1044`). The owner's left-click is *not* a unit order path; it is purely a camera jump.
5. Next frame, `main.gd:1044` calls `world.sync(dt)`.
6. `world.gd:1224` recomputes `view_rect` from `get_viewport().get_canvas_transform().affine_inverse() * get_viewport_rect()` → sees the new camera position the same frame.
7. `world.gd:1225` → `_sync_terrain_chunks()`:
   - `world.gd:1184-1191` converts view to chunk indices `c0x..c1x, c0y..c1y`.
   - `world.gd:1193-1213` scans row-major; for each *missing* chunk, `if built >= 2: return` (`1197-1198`) then `_build_chunk(cx,cy)` (`1203`). **Max 2 new chunks per frame.**
   - `world.gd:1214-1219` LRU evicts while `terrain_order.size() > 24`, `queue_free()`-ing sprites.
8. `world.gd:1235-1249` computes `moved` from the new `view_rect` and, if moved, queues `res_layer` + `bld_layer` redraw; unit/fx layers redraw every frame.
9. Decor/resources redraw via `_draw_resources → _draw_forest_detail` (`world.gd:1552-1556, 1455-1474`), which culls on the new `view_rect`. Correct new-view data is drawn — **but only where a terrain chunk already exists**.

**Conclusion on path:** the jump is a single instant camera write; all cost and all visual breakage happen in the 1-6 `sync()` frames *after* the click, inside `_build_chunk`.

---

## 3. Evidence table

| Claim | file:line | observed / derived / inferred | Verdict |
|---|---|---|---|
| Minimap left-click sets camera position directly, no tween | `hud.gd:1038-1039` | observed | **Confirmed** — camera reaches target in 1 frame; "jump slowness" is *not* camera interpolation. |
| Hit-testing scans a large texture per click | `hud.gd:1033-1034` | observed | **Rejected** — O(1) normalized coordinate math; no `get_pixel`/image scan in the click handler. |
| Full chunk rebuild forced in ONE frame / 2-chunk cap bypassed | `world.gd:1197-1198`, `1203`, `1048`, `1225` | observed | **Rejected** — cap is `if built >= 2: return`; `_build_chunk` has exactly one call site, inside that capped function; `sync()` calls it once/frame. |
| Rebuild is amortized over several frames, leaving blank area until completed | `world.gd:1193-1213`, `1172-1179`, `1235-1240` | derived + inferred | **Confirmed as the mechanism** for first-seconds artifacts: newly-visible chunk keys are absent from `terrain_chunks`, nothing is drawn for them (background clear color `project.godot:28`), and they fill row-major (top-left first), 2/frame. No placeholder/fallback is drawn. |
| Per-chunk bake is far above a 16.7 ms frame budget | `world.gd:1064-1170`; `perf.md:223-239`; `app/.godot_queue/results/00000639_qa1-bench-4/stdout.txt` | observed (engine output) + derived | **Confirmed** — final N-07 gate: `max_ms=645.24 mean_ms=526.63` on LOW, **FAIL** (2.58× over 250 ms). Other recorded runs: 43-50 ms (best optimized, `00000656`) up to 1422-1688 ms (`00000730`, `00000671`). 2 bakes/frame ⇒ ~88 ms … ~1300 ms in `sync()` — multi-frame hitch. Caveat: headless CPU-only, cold-cache dominated (`perf.md:241-249`); real windowed numbers differ but GDScript loop cost dominates in both. |
| No camera clamp after a minimap jump | `hud.gd:1039`; `camera.gd:70`, `92` | observed | **Confirmed** — `clamp_pos()` is called only on arrow/edge scroll (`camera.gd:70`) or mouse motion (`camera.gd:92`), not after the jump assignment. Near map corners the view can extend past the map edge → blank border until the player moves the mouse. |
| Minimap's own white viewport rectangle lags the jump | `hud.gd:974-977`, `1134-1148` | observed + derived | **Confirmed** — the rectangle is redrawn only inside `_update_minimap()`, on `Data.MINIMAP_INTERVAL` (0.25 s high / 0.5 s low, `data.gd:118-119,153-159`). It reads `world.view_rect` at that moment, so it snaps to the new location up to one interval late. |
| Fog drawn stale / wrong for first seconds after jump | `world.gd:1257-1299`, `257`; `data.gd:55`; `config.gd:354`; `config.json:20` | observed | **Rejected for this config** — fog is off by default and in `config.json`. When on, fog is a single full-map `ImageTexture` updated on `FOG_INTERVAL` from entity positions, independent of camera, so a camera jump does not make it stale. |
| `res_layer` / decor drawn with stale data after jump | `world.gd:1235-1240`, `1552-1556`, `1455-1474` | observed | **Rejected** — `moved` is true on a jump, so both layers redraw with the new `view_rect`; no stale caching. (They still only paint where chunks exist.) |
| Chunk count needed per viewport, and frames to fill | `world.gd:25`, `16`; `data.gd:23`; `camera.gd:26-29`; `config.json:15-19,37`; `project.godot:15-16` | derived | See §4. |
| LRU-24 too small for one viewport (thrashing) | `world.gd:1214`; constants above | derived | **Rejected at default settings** — max ~12-15 chunks visible even fully zoomed out, below 24. But the whole 320×320 map is 10×10 = **100 chunks**, so a jump to a previously evicted region re-bakes; with >24 chunk touches between visits caching gives no benefit. |
| O(n²) / hot loops in the jump path | `world.gd:998-1046`, `1108-1122`, `1152-1165`; `hud.gd:1062-1149`; `world.gd:1262-1299` | observed + derived | **Confirmed** — dominant is `_composite_blocks`: N=33 grid ⇒ 33² × 4 neighbours × ≤3 block names ≈ 13k GDScript iterations, repeated for base + terrain roles 1/2/4/5, plus `_alpha_mask` resize to S² (S=512 at HIGH) and per-cell `game.height_at` for relief (`1155-1165`). Secondary: `_update_minimap` does `minimap_base.duplicate()` (320×320) plus O(entities+res_nodes) every 0.25 s, and an O(MAP_W·MAP_H)=102k `get/set_pixel` loop when fog is on (`1128-1133`). `_update_fog` is O(units × search-radius²). None of these are per-click except the bake. |

---

## 4. Quantification (default config: 1280×720, 16 px/m, TILE_M=2 m, CHUNK_T=32 tiles = 64 m, map 320×320 tiles = 640×640 m = 100 chunks)

Visible world extent = `viewport_px / (view_scale × zoom)`; chunk span = `ceil(extent / 64)` (one extra possible when the view straddles a 64 m chunk boundary).

| Zoom | camera.gd source | World view (m) | Chunks across × down | Chunks to bake after cold jump | Frames at 2/frame |
|---|---|---|---|---|---|
| 2.9 (max in) | `max_zoom = 58/20` (`camera.gd:29`) | 27.6 × 15.5 | 1×1 … 2×1 | 1-2 | 1 |
| **1.0 (default)** | initial `Camera2D.zoom` | 80 × 45 | 2×1 … 3×2 | **2-6 (typically 4)** | **1-3 (typically 2)** |
| 0.3448 (max out) | `min_zoom = 20/58` (`camera.gd:28`) | 232 × 130.5 | 4×3 … 5×3 | 12-15 | 6-8 |

Derived frame cost during those frames: `sync_time ≈ 2 × bake_ms`. Using recorded bake means: best case ~44 ms ⇒ ~88 ms/frame (≈5.3× the 16.7 ms budget); final gate ~526 ms ⇒ ~1050 ms/frame (≈63× budget). This is the "very slow" the owner reports; the camera itself is already at the target on frame 1.

Derived "first seconds" window: at default zoom the terrain is fully present in 2 frames; at max zoom-out in 6-8 frames. Because each of those frames itself costs hundreds of ms with the current bake cost, the elapsed wall-clock time is seconds, matching the report. The blank region is the not-yet-built part of the view (row-major fill order means the bottom/right of the view is blank longest), plus the minimap viewport box lagging ≤0.25 s and an unclamped camera at map corners.

O(n²)-class loops: `_composite_blocks` ≈ 13k × ~6 passes ≈ 8×10⁴ GDScript iterations/chunk (`world.gd:1016-1046`); relief `height_at` grid 33² (`1155-1165`); minimap full-map fog dim 1.024×10⁵ (`hud.gd:1128-1133`). All are per-bake/per-interval, not per-click.

---

## 5. Root cause ranking

1. **PRIMARY — `_build_chunk` cost vastly exceeds the frame budget, and the 2-chunk/frame amortization turns one jump into several 100 ms+ frames.** Evidence: `world.gd:1048-1180` + `1197-1198`; BAKE_BENCH gate FAIL `perf.md:223-239`. Causes *both* the slowness and the blank-quadrant artifacts. The cap is working as designed; the design assumes cheap bakes, which is false.
2. **No fallback for missing chunks** — `world.gd:1193-1219` simply skips absent keys; `project.godot:28` clear color shows through. Row-major build order makes it look like a quadrant that "fixes itself." (Secondary to #1 but is the direct cause of "graphical errors for the first seconds".)
3. **No clamp on jump** — `hud.gd:1039` vs `camera.gd:70,92`; blank border at map edges until mouse motion.
4. **Minimap viewport box updated on a timer, not per frame** — `hud.gd:974-977,1134-1148`; indicator stale ≤ MINIMAP_INTERVAL after the jump.
5. **Background O(entities)/O(map) minimap and fog updates** — `hud.gd:1062-1149`, `world.gd:1257-1299`; contribute to overall sluggishness (fog dim only if fog enabled) but are not click-latency and not the artifact source.

Explicitly **not** causes: hit-test texture scan (O(1)), one-frame full rebuild (cap holds), stale fog (off), stale res/decor data (redraw on `moved`).

---

## 6. Concrete fix proposal (READ-ONLY — proposed targets, not applied)

**F1 — Make chunk baking non-blocking and show no hole. Target `world.gd:1182-1219` / `1048-1180`.**
- Replace synchronous `_build_chunk()` in `sync()` with a small bake queue serviced by `WorkerThreadPool.add_task()`; keep per-frame main-thread work to "upload finished `ImageTexture`s" (≤ a time budget, e.g. 6-8 ms), not a fixed count. Main thread never stalls on a bake.
- Until a chunk is ready, draw a neutral fallback (flat biome/gain colour rectangle) for that chunk cell so there is no clear-color quadrant. Feed it from the already-cached `gain_map` / terrain colour rather than a new bake.
- Order the bake queue **view-centre-out** instead of the current row-major `for cy … for cx` (`world.gd:1193-1194`) so the point the player jumped to is correct first.
- Keep LRU 24 (proven sufficient for one viewport); optionally raise to 36 so a short jump out-and-back does not re-bake.
- Independently, drive the recorded N-07 gate (which currently **FAILs**, `perf.md:227`) to PASS: the `BLOCKS_PER_CHUNK`/`BLOCKS_PER_ROLE` caps (`world.gd:58-59`) and the `_composite_blocks` grid work (`world.gd:998-1046`) are the levers; target a single bake < 16 ms so even 2/frame fit one budget.

**F2 — Clamp the camera at the jump. Target `hud.gd:1038-1039` and `1045-1046`.**
- After `cam.global_position = …`, call `cam.clamp_pos()` (make it a public camera method; currently `camera.gd:33`). Removes the map-edge blank border without waiting for mouse motion.

**F3 — Update the minimap viewport box immediately. Target `hud.gd:974-977` / `1134-1148`.**
- Either call a cheap `_draw_minimap_viewport_box()` from `_on_minimap_input` (and from camera motion), or move the box to a separate overlay redrawn every frame; stop relying on `MINIMAP_INTERVAL`.

**F4 — Cheap minimap update. Target `hud.gd:1062-1149`.**
- Avoid full `minimap_base.duplicate()` + all-entity loop on a fixed 0.25 s timer; only re-plot changed blips, and skip the O(map) fog dim entirely when fog is off (already guarded at `1127`, but the base duplicate at `1067` is unconditional). Lower priority.

### Measurable acceptance criteria
- **A1** Camera centre equals target within 1% on the frame after the click (already true — regression guard for F2/F3).
- **A2** `dbg_sync` (`main.gd:1043-1045`) ≤ 16.7 ms on every frame of a minimap jump at default zoom; ≤ 33 ms at max zoom-out (no dropped frames from chunk work).
- **A3** Full terrain for the new view visible within **2 frames** at zoom 1.0, within **8 frames** at max zoom-out, with **zero frames showing background clear colour where a chunk belongs** (assert by comparing the set of in-view chunk keys against `terrain_chunks` each frame; must be covered by baked sprite or fallback).
- **A4** `BAKE_BENCH max_ms < 250 ms` (N-07 gate PASS, `perf.md:208`); stretch goal < 16 ms per chunk.
- **A5** Minimap viewport rectangle position matches camera on the very next frame (not after 0.25 s).
- **A6** End-to-end jump latency (click → correct fully-rendered frame) < 100 ms at default zoom on the target (windowed) hardware.

---

### Bottom line for the owner
The click is O(1) and the camera already jumps in one frame. The slowness and the "wrong for a second" look come from terrain chunk baking: the new view's chunks do not exist yet, only 2 can be baked per frame, each bake is tens-to-hundreds of milliseconds of GDScript work (the repo's own perf gate records **645 ms max / 526 ms mean, FAIL**), and nothing is drawn for a missing chunk, so blank quadrants persist while the bake queue drains. Fix the bake cost / move it off the main thread, add a no-hole fallback, clamp the camera at the jump, and refresh the minimap box every frame.
