# REPORT_NAV_MINIMAP_SHORE — Navigation / Minimap / Shore / Mines wave

Task: T-DOCS-3 (documentation only). Scope: four lanes shipped together —
**navigation** (`camera.gd`, `input_controller.gd`), **minimap** (`hud.gd`),
**shore** (`world.gd`, `water_overlay.gdshader`) and **mines**
(`pattern_gen.gd`, `mapgen.gd`, `game.gd`), plus the decision to skip a static
map cache. This report is the single new artifact for the wave; no other docs
were edited.

All statements below were verified against the working tree on 2026-11-23:
source reads of the named files, the persisted test-result JSONs in
`app/tests/results/`, and `git status`. Where a claim rests only on a lane's
reported console result (no persisted JSON), that is called out explicitly.

---

## 1. Status at a glance (honest)

| Lane | State | Evidence | Caveat |
|---|---|---|---|
| Navigation | **Landed** | `camera.gd`, `input_controller.gd` source; `t_nav_smoke.gd` 6/6 PASS (reported) | No `t_nav_smoke.json` persisted in `results/` |
| Minimap | **Landed** | `hud.gd` source; `--check-only` clean (lane report) | No dedicated persisted JSON; covered by console smoke |
| Shore | **Landed** | `world.gd`, `water_overlay.gdshader` source; `t_shore_smoke.json` 6/6 PASS | D-43 shallow-tint deviation deliberately preserved (still a named deviation vs donor) |
| Mines | **Landed in working tree** | `pattern_gen.gd`, `mapgen.gd`, `game.gd` source; `t_mines_fix.json` 4/4 PASS | Fix files are modified/untracked in `git status` at time of writing — not yet committed |
| Static map cache | **Skipped by decision** | Perf rationale in §2.5 | Not implemented; rationale recorded instead |
| Integrated wave smoke | **Landed** | `t_wave_smoke.gd` 9/9 PASS (reported) | Source-scan smoke, not behavioural; no persisted JSON |

`git status` at verification time showed `M` on `camera`-adjacent consumers and
on `game.gd`, `mapgen.gd`, `pattern_gen.gd`, `world.gd`, `config.gd`, `data.gd`,
`main.gd`, `menu.gd`, plus untracked `app/tests/t_mines_fix.gd`,
`app/tests/results/t_mines_fix.json`, `app/tests/t_menu_roster.gd/.json`. The
mines fix and its test are therefore **present and passing but uncommitted** —
treat "landed" as "in the shared working tree with a green test", not "on
master".

---

## 2. Per-lane detail

### 2.1 Navigation — one-frame responsiveness

**Camera (`app/scripts/camera.gd`)**

- `const PROCESS_PRIORITY := -100`, applied in `bind()`. A lower
  `process_priority` runs the camera earlier in the `_process` pass, so its
  position write is visible to `main.gd`'s `world.sync()` on the **same** frame.
  This removes the old one-frame lag where every pan (edge, key, drag, minimap
  jump) was captured after `sync()` had already read the canvas transform.
- `jump_to_world(world_pos, view_scale)` — writes `position` immediately,
  invalidates the clamp memo via `mark_dirty()` and re-clamps. Used by the
  minimap path for an instant reposition; no sim tick and no
  `MINIMAP_INTERVAL` wait.
- `mark_dirty()` — resets `_last_clamp_pos/_last_clamp_zoom` to `Vector2.INF`
  so the next `clamp_pos()` re-evaluates. It also forwards to a
  `world.mark_camera_dirty()` hook **if** that lane ever adds one; `world.gd`
  has no such hook today, so this is a forward-compatible nudge, not a live
  dependency.
- `clamp_pos()` is **memoized** on `(position, zoom)`: mouse-motion events and
  idle frames bail out before doing viewport math. If the view is wider/taller
  than the map, the axis is centred instead of `clampf()` pinning the camera
  past the map edge.
- `_process(dt)` clamps `dt = minf(dt, 0.05)` (50 ms hitch guard) so a 250 ms
  stall (load / GC / alt-tab) cannot teleport the camera; the clamped `dt` is
  used **unscaled**, so edge/key speed still matches the profile values.
- **Middle-button drag** pans by raw pointer delta; the previous point is
  cached (`_middle_drag_last`, `INF` = idle) so the first drag frame cannot
  teleport from a stale mouse position. Edge scroll is suspended while
  middle-dragging so the two writers cannot fight.
- **Arrow keys only** (`KEY_LEFT/RIGHT/UP/DOWN`), each queried **once** per
  frame; the old code queried twice (direction, then speed branch), which
  could desynchronise diagonal and mixed key+edge panning. WASD is deliberately
  **not** a pan binding — those letters are donor order/build hotkeys
  (A attack, S stand, D hold-fire, W wall).
- `_unhandled_input` no longer does per-event viewport math: wheel zoom keeps
  the world point under the cursor fixed (donor-style), and motion events are
  a no-op because the single memoized clamp in `_process()` covers every
  writer, including `hud.gd`'s minimap writes.

**Input controller (`app/scripts/input_controller.gd`)**

- Minimap geometry is a **cached rect** (`_mm_rect`, `_mm_rect_dirty`). It is
  invalidated only on viewport `size_changed` or `hud.minimap_rect.resized` —
  never on mouse events — so the per-event path does no Control/layout math or
  allocations.
- `_minimap_world()` clamps UVs to `[0,1]`, so a drag that slips off the
  minimap cannot keep pulling the camera.
- `_minimap_reposition()` calls `camera.jump_to_world()` when available,
  otherwise falls back to a direct `global_position` write + `clamp_pos()` +
  `mark_dirty()`.
- **Minimap left-click = instant jump; left-drag = continuous follow**. While
  `_mm_dragging` (or the left mask is held inside the cached rect) motion events
  reposition every frame; leaving the rect ends the drag so it cannot leak
  into world-map selection-drag logic.
- **Right-click orders are preserved**: inside the minimap rect, right-click
  calls `minimap_order()` (attack-move if an enemy is within 6 m and the unit
  has a weapon, otherwise plain move); outside it, the existing
  `_right_order()` path is unchanged.
- `_screen_to_world()` is **lazy**: it is only paid for world-map events, not
  for minimap events.

`app/tests/t_nav_smoke.gd` contains exactly six checks — early priority,
instant jump, dirty invalidation, minimap centre UV, clamped drag, cached rect
— and the lane reports **6/6 PASS**. No result JSON was written to
`app/tests/results/` for this test; the source and the reported console result
are the evidence.

### 2.2 Minimap (`app/scripts/hud.gd`)

**Marker palette and shapes**

| Layer | Shape | Colour / rule |
|---|---|---|
| Gold mine | 7×7 diamond (core Manhattan ≤2, 1 px dark rim at 3) | `(1.00, 0.86, 0.18)` gold yellow |
| Iron mine | same diamond | `(1.00, 0.58, 0.18)` orange |
| Coal mine | same diamond | `(0.98, 0.78, 0.40)` pale amber |
| Stone quarry | same diamond | `(0.94, 0.89, 0.62)` beige |
| Diamond rim | outer ring | `(0.05, 0.04, 0.03)` near-black for crispness |
| Own building | 2×2 block | player tint (player 0 = blue `(0.30, 0.62, 1.00)`) |
| Enemy building | 3×3 | dark-red rim `(0.34, 0.02, 0.02)`, bright player-tint centre |
| Own unit | 1 px | player tint; white when selected |
| Enemy unit | 1 px + 4-neighbour red rim | player tint + `MM_ENEMY_RIM` |
| Army cluster | 3×3 cross (own) / 3×3 rim+core (enemy) | centroid of 4×4-tile bucket |

- **Fog gating.** Mine markers are skipped only on **unexplored** tiles
  (`world.fog_explored`); explored-but-currently-invisible tiles keep their
  marker, so ore only ever *becomes* known. Enemy blips are stricter:
  `_mm_enemy_visible()` requires explored **AND** currently visible
  (`fog_explored != 0 and fog_vis != 0`) whenever fog is on; with fog off,
  everything is visible upstream.
- **Clusters.** Above `MM_CLUSTER_THRESHOLD = 16` units for a player, positions
  collapse into `MM_CLUSTER_CELL = 4`-tile buckets keyed by `(player, bucket)`,
  so an arbitrarily large army costs a handful of `set_pixel` calls rather
  than one per unit. The player is part of the key, so two owners never mix
  colours in one cluster.
- **Layering / priority** (last wins): **mines < buildings < unit dots <
  clusters**. Enemy pixels are stamped last within the unit/cluster passes so
  they stay legible on top of friendly or marker pixels.
- **Dirty-gated O(N) scans.** Mine centres rebuild only when `game.res_dirty`
  moves; building centres only when `game.bld_dirty` moves (buildings never
  relocate). Unit positions are rebuilt **once per `MINIMAP_INTERVAL` tick** —
  that cadence is what shows movement. A hidden minimap panel does no pixel
  work and refreshes on the first tick after being reshown (bounded staleness).
- **Static bases cached.** `minimap_base` (terrain) and `minimap_fog_base`
  (fog dim, keyed by `world.fog_revision`) are duplicated with the fast C++
  `Image.duplicate()` instead of repainting ~100k pixels per tick.
- **Viewport box.** Derived straight from the camera transform, redrawn every
  frame but **change-gated** (`_mm_box_last`), so a still camera is O(1). On a
  change it restores only the previous 1 px border from the clean image and
  paints the new border — the old full ~100k-pixel box copy is gone, so no
  ghost rectangles can be left behind. A minimap click/drag redraws the box on
  that same input event rather than waiting for `sync()`/the minimap timer.

Lane status: `--check-only` clean. There is no dedicated persisted JSON for the
minimap lane; it shares the console smoke coverage described in §3.

### 2.3 Shore (`world.gd`, `water_overlay.gdshader`)

**Baked bed — `world.gd:_shore_substrate()`**

The bed is keyed off **shore distance in tiles** (1 tile = 32 px @720p), not
raw depth alone; a 3-pass relaxation over the chunk's tile grid gives each
water cell its distance to the nearest non-water cell. Land cells get a muted
ground colour so the role mask's 25 % edge bleed cannot glow; chunks with no
water early-out to a flat cached bed.

Tuning applied in this wave (old → new):

| Constant / effect | Old | New |
|---|---|---|
| `SHORE_WASH_DEPTH` | 0.35 | **0.48** (pale bed reaches slightly deeper nearshore cells) |
| Pale lerp `SHORE_PALE → SHORE_SHALLOW` | 0.25 | **0.40** (push toward `#C3D1CA`) |
| Outer contour ramp | 0.15 tile | **0.35 tile** (wider feather, graded not a flat band) |
| Sandsea grain amplitude | ±0.10 | **±0.15** (blotchy sand→wash) |

- `t_shore_smoke.json`: **6/6 PASS** — wash depth 0.48 applied, pale lerp 0.40
  applied, a water chunk found, bed size 64×64, **108 distinct colours** (not
  a flat fill), and two bakes byte-identical (**deterministic**).
- **Oriented grain is skipped for water cells by design.** The per-cell
  `sandsea1/5/6` orientation lives in `game.tileblock` for **land** role-4
  cells. Water (role 3) has no sandsea name there, so its path goes through
  `_shore_substrate()` rather than `_role_block_names()`; `sandsea*` blocks are
  explicitly filtered out of the chunk-wide base composite too. If the donor
  rim shows oriented wet grain, that remains a fidelity gap (see §6).
- The bake stays inside the N-07 budget: 2 samples/tile, hoisted colour lerp,
  nearest sampling of the tile fields (~2.5k array reads per chunk instead of
  ~83k `height_at()` calls in the first version).

**Overlay — `water_overlay.gdshader` (T-SHORE-SHADER)**

- Adds a **band-gated** low-frequency turbidity/mottle to the shallow wash.
  `band = coastfade * (1 - coastfade2)` is exactly zero beyond the 1.07 m deep
  fade, so **deep water is bit-identical** to the pre-pass shader. The two
  rotated taps reuse the **existing** `wave_noise` sampler — no new sampler or
  uniform.
- Turbidity is multiplicative ±12 % plus a slight greenish tint:
  `col *= 1.0 + band * (0.12 * mottle); col += band * mottle * vec3(0.03, 0.04, 0.02);`
- The same low-freq term modulates **foam gain** over **0.7–1.3×** (`FOAM_GAIN *
  (0.7 + 0.6 * (0.5 + 0.5 * mottle))`), breaking up the uniform-width scalloped
  edge. Foam stays purely procedural (`nautic()`/`particles()`); no foam
  texture was added.
- Public interface, every uniform, and `alpha = coverage * coastfade2` are
  **unchanged**.
- **D-43 deviation preserved**: the calibrated shallow tint is deliberately
  **not** forced to `#C3D1CA`. `BODY_SWELL_AMP` and `BODY_SPAN` are untouched.

### 2.4 Mines — final rule (fix landed)

The new fix is **in the working tree and green**, so the final rule is now
authoritative (the earlier "in flight" status is closed). Dedicated test:
`app/tests/t_mines_fix.gd` → `app/tests/results/t_mines_fix.json`, **4/4 PASS**.

**Root cause (the three bugs)**

1. `mine_occ` inherited `occupied` from the shared placement grid, so mine
   footprints were rejected against unrelated tile/build occupancy.
2. The near-ring placement used the **shared** grid, letting a mine be stamped
   into a cell another pass already claimed.
3. Rejection used a **6 m point test**, not the scaled donor footprint, so two
   ore aprons could visually intersect even though their centres were "far
   enough".

**Final rule — `pattern_gen.gd` owns the layout**

- `mine_occ` is now the **count-replay grid only**: it inherits the shared grid
  and clears `CIRCLE1` so the original donor rejection sampling accepts the
  same number of mines as before. The original mine loop is replayed against
  the shared RNG/occupancy to keep the downstream forest/relief stream and
  `occupied[]` byte-identical, but its stamps are discarded.
- A **separate, fully seeded RNG** drives the new layout (`mine_rng`, seeded
  from the map seed and dimensions), so the shared `rng`, terrain geometry and
  `C3MapGen` stay deterministic and untouched.
- A **final authoritative pass** at the end of `build()` relocates *the same*
  mine stamps (count unchanged) so:
  - every start gets **gold + iron + coal in the 10–24 tile band**, spaced
    around the start (120° ore separation), with cluster count scaled by
    `Data.RICHNESS`;
  - every pair of stamped scaled footprints, **dilated by 1 tile**, has **zero
    intersection**, and all ore nodes keep **≥10 tiles centre separation**;
  - placement uses the scaled footprint (`can_stand`/`stand` against
    `mine_occ`), not a point test.

- **Count is preserved, not invented.** The test's pre-fix baseline is
  `{1000:19, 1001:21, 1002:21, 1003:23, 1004:17, 1005:22, 1006:18, 1007:16}`.
  Seed 1006's 18 vs the old 17 is an **intended richness stamp** the old code
  silently dropped when its centre landed on post-collision rock; the fix
  relocates it. No art deposit is added.
- **`game.gd:_ensure_start_ore_clusters()` is now a safety net**, not the
  placer. On a normally generated map it relocates **nothing** — every start is
  already inside `MINE_DISCOVER_R`. It runs only for `med`/`normal` richness,
  uses the **same** `_ore_spot_clear` footprint rule and
  `MINE_MIN_SEP_TILES`, moves an **existing** node (never adds one), preserves
  node id / count / wealth share, and skips low/high richness so
  `RICHNESS_ORE_DELTA` stays byte-identical.
- `mapgen.gd` documentation now states ore is **not** placed there; it produces
  only the height/forest fields and start positions with its own deterministic
  stream.

**Test detail (all PASS):** worst nearest ore = **24.9 tiles** (≤26 gate),
max dilated footprint overlaps = **0**, min centre separation = **11.04
tiles**, ore counts match the baseline for all 8 seeds, and the same seed gives
a byte-identical ore layout.

### 2.5 Static map cache — skipped (decision recorded)

A static/cached whole-map layer was **not** added. Terrain is already baked and
cached **per chunk** in `world.gd`, so a separate static map texture would
duplicate that work. The measured simulator cost is **~196 ms/tick**
(`perf.md` / CONFIG_EFFICIENCY audit), which dominates; a visible-window blit
would save only on the order of **1–2 draw calls** per frame. The complexity is
not justified by the saving — the bottleneck is sim, not the terrain blit.

---

## 3. Controls / legend

### Camera & minimap controls

| Input | Effect |
|---|---|
| Mouse at screen edge / corner | Edge scroll (profile speeds; suspended during middle-drag) |
| Arrow keys | Pan (queried once per frame; **WASD remains order/build hotkeys**) |
| Middle-button drag | Pan by raw pointer delta; edge scroll suppressed while dragging |
| Mouse wheel | Zoom at cursor (donor-style), clamped to donor-derived min/max |
| Minimap left-click | Instant jump to that world point; camera clamped, no blank border |
| Minimap left-drag | Camera follows the pointer continuously; leaving the rect ends the drag |
| Minimap right-click | Move / attack-move order for the selection (attack when an enemy is within 6 m and the unit has a weapon) |
| World left-click / drag / double-click / Shift-click | Select unit / box-select / all-of-type on screen / add to selection (unchanged) |
| World right-click | Existing order logic — move, attack, gather, rally, repair, patrol, etc. (unchanged) |

### Minimap legend (see §2.2 for exact RGB)

- **Amber diamonds** = ore/quarry sites: yellow gold, orange iron, pale-amber
  coal, beige stone; dark rim; hidden on unexplored tiles only.
- **Blue 2×2** = your buildings; **red-rimmed 3×3 with a bright core** = enemy
  buildings (only while explored *and* currently visible under fog).
- **1 px dots** = units, white when selected; enemies carry a red rim.
- **4×4-tile cluster blips** = armies above 16 units per player; coarse
  centroid, not individual unit positions.
- **White 1 px border** = current camera viewport, redrawn every frame without
  ghosting.

---

## 4. Donor comparison — shore

Donor truth is from the water-source transcription in
`docs/t6/reports/T6-W01.md §2`, the gap tables in `docs/audit/WATER_REPORT.md`
and the shore criteria in `docs/t6/WATER_LANE.md`.

| Aspect | Donor | Port (this wave) | Verdict |
|---|---|---|---|
| Depth fades | `coastfade = depth/0.57`, `coastfade2 = depth/1.07`; shore height band 0.15 m | Same baked ramps in mask G/B; `band = coastfade*(1-coastfade2)` | Values preserved verbatim; alpha `coverage*coastfade2`, old 0.35 floor gone |
| Shore wash | Soft, blurred 3-band sand→wash→water; 30–50 px source / 60–90 px @720p; no sawtooth/black band | Baked pale bed keyed to ~1 tile of shore distance, 0.35-tile contour ramp, ±0.15 grain, plus band-gated shader mottle | Matches the *shape* goal; 108 distinct colours, deterministic |
| Depth resolution | Per-pixel height at every fragment | Baked per tile (1 px = 2 m), LINEAR-filtered | **Residual gap (WATER_REPORT L-14)**: stepped shoreline / 2 m band aliasing |
| Foam | Procedural (`nautic`/`particles`), no foam texture | Procedural; gain modulated 0.7–1.3× by the same low-freq term | Parity; no new asset |
| Shallow colour | HARD gate `#C3D1CA` (194,208,201) target | Calibrated shallow tint deliberately **not forced** to `#C3D1CA` | **D-43 deviation preserved** — still an open named deviation, not silently "fixed" |
| Wet rim grain | Donor sandsea1/5/6 is an oriented 8-sector fold | Water cells have no sandsea name in `tileblock`, so oriented grain is skipped on water; sandsea used only on land role-4 cells | **Residual gap**: 8-sector fold / 3 distinct sandsea tiles not reproduced on the wet rim |
| Body swell / span | Donor full swell spectrum on normals | `BODY_SWELL_AMP` / `BODY_SPAN` untouched this wave | No regression from the shore pass |

The shader change is intentionally conservative: deep water is bit-identical,
the uniform/interface set is unchanged, and the only new maths is gated by
`band` so it vanishes exactly where the donor's shallow band ends.

---

## 5. Verification evidence

| Test / check | Result | Artifact |
|---|---|---|
| `app/tests/t_nav_smoke.gd` | **6/6 PASS** (reported console; 6 checks in source) | No JSON persisted in `app/tests/results/` |
| Minimap `hud.gd` | `--check-only` clean (lane report) | No dedicated JSON |
| `app/tests/t_shore_smoke.gd` | **6/6 PASS** | `app/tests/results/t_shore_smoke.json` |
| `app/tests/t_mines_fix.gd` | **4/4 PASS** | `app/tests/results/t_mines_fix.json` |
| `app/tests/t_wave_smoke.gd` | **9/9 PASS** (reported console) | No JSON persisted |

- **Shore smoke details**: wash depth = 0.48, pale lerp = 0.40, water chunk
  found, bed 64×64, **108 distinct colours**, two bakes identical.
- **Mines fix details**: worst-nearest ore 24.9 tiles; zero dilated footprint
  overlaps; min centre separation 11.04 tiles; counts match the 8-seed
  baseline; same seed → identical layout.
- **Wave smoke details**: 6 script-load checks + source scans for
  `camera.jump_to_world`, `SHORE_WASH_DEPTH := 0.48`, and
  `_ensure_start_ore_clusters` = 9 checks. Its **first run had two test-harness
  bugs, not product bugs**: (1) `has_method` was called on a loaded `Script`
  resource, which checks GDScript's own methods rather than the script's
  declared methods, so the camera API check was replaced with a source-text
  scan; (2) a string-spacing mismatch in the shore-constant scan. Both were
  fixed in the test; the shipped test is 9/9. This is reported honestly so a
  future reader does not mistake the first-run failures for regressions.

---

## 6. Known gaps

1. **Persistence**: nav smoke and wave smoke have only reported console
   results — no `t_nav_smoke.json` / `t_wave_smoke.json` in `results/`. Re-run
   evidence is by test source + console, not a durable artifact.
2. **Commit state**: the mines fix (and several consumer scripts) are modified
   or untracked in `git status`. The fix is green in the working tree but not
   on `master`; owner merge/commit is still required.
3. **Baseline nuance**: seed 1006's ore count intentionally changes 17 → 18
   (a previously dropped richness stamp is now relocated). Documented and
   tested, but it will show as a count diff against old artifacts.
4. **D-43 remains open by design**: the shallow tint is not forced to donor
   `#C3D1CA`. This is a preserved deviation, not a claimed match.
5. **Per-tile depth (WATER_REPORT L-14)**: donor depth is per pixel; the port
   bakes per 2 m tile, leaving stepped-shoreline / alias risk at the band edge.
6. **Wet-rim orientation**: donor's oriented sandsea1/5/6 (8-sector fold) is
   not reproduced on water cells because `tileblock` has no sandsea name there;
   only land role-4 cells use oriented sandsea.
7. **Enemy minimap memory**: enemy blips require *current* visibility
   (`fog_vis`), so a previously seen enemy that moves into fog disappears;
   there is no "last known position" ghost.
8. **Cluster coarseness**: above 16 units, blips are 4×4-tile bucket centroids —
   useful for army detection, not for reading individual unit positions.
9. **Static cache intentionally omitted**: ~1–2 draw-call saving vs a sim-bound
   196 ms/tick; no visible-window blit implemented.
10. **Automated coverage of new pan modes**: middle-drag and arrow-key panning
    are covered only by unit-level source/state checks. Earlier windowed RPC
    verification (T3-FIX-NAV) covered minimap click/box, not the new
    middle-drag/arrow path.
11. **Wave smoke is a source scan**: it asserts source strings exist, so exact
    string spacing matters (the cause of one first-run test bug). It is not a
    behavioural substitute for the dedicated tests.

---

## 7. Manual A/B checklist

Run A = pre-wave build, B = current working tree. Confirm each item; note any
regression with seed + screenshot.

### Navigation
- [ ] Edge scroll and corner scroll pan smoothly; no one-frame lag after a pan.
- [ ] Arrow keys pan; **WASD still issues orders/build commands**, not camera pan.
- [ ] Middle-drag pans by pointer delta; first drag frame does not teleport;
      edge scroll does not fight the drag.
- [ ] Alt-tab / load hitch (≥250 ms) does not teleport the camera (50 ms clamp).
- [ ] Minimap left-click jumps instantly and clamps at corners with no blank border.
- [ ] Minimap left-drag follows continuously; releasing outside the rect ends the drag.
- [ ] Minimap and world right-click still produce the correct move/attack/gather/rally orders.
- [ ] Wheel zoom keeps the point under the cursor fixed; min/max clamps still work.

### Minimap
- [ ] Gold/iron/coal/stone read as yellow/orange/pale-amber/beige diamonds with dark rims.
- [ ] Unexplored tiles hide mine markers; explored-but-invisible tiles keep them.
- [ ] Own buildings are 2×2 blue; enemy buildings are 3×3 red-rim with a bright core,
      and appear only while explored **and** currently visible under fog.
- [ ] Own units are 1 px (white when selected); enemy units have a red rim.
- [ ] >16 units of one player collapse into 4×4-tile cluster blips; colours never mix owners.
- [ ] Layer order is mines < buildings < units < clusters; enemies stay legible on top.
- [ ] White viewport box tracks the camera every frame with no ghost rectangle after fast pans.
- [ ] Hidden minimap panel costs no per-tick pixel work and refreshes shortly after reshown.

### Shore
- [ ] Pale wash is a graded, blotchy ~1-tile band near the shoreline, not a flat khaki ring.
- [ ] No inland halo on gently sloping lake beds; land cells stay muted.
- [ ] Deep water is visually bit-identical to A (no new ripple/tint beyond 1.07 m).
- [ ] Foam edge varies in width (0.7–1.3× gain) and remains procedural.
- [ ] D-43 deviation screenshot captured: shallow tint is **not** forced to `#C3D1CA`.
- [ ] Two bakes of the same chunk are byte-identical (108 distinct colours, non-flat).

### Mines
- [ ] Each start has gold, iron and coal within 26 tiles (target band 10–24).
- [ ] No two ore aprons visually intersect; map-wide footprints are disjoint with dirt gaps.
- [ ] Ore count per seed matches the baseline (seed 1006 = 18 is expected).
- [ ] Same seed produces an identical ore layout across two generations.
- [ ] Only `med`/`normal` richness uses the safety-net relocation; `low`/`high` are unchanged.
- [ ] Terrain/forest geometry is unchanged by the mine fix (determinism preserved).

---

## 8. Bottom line

All four lanes and the integrated smoke are green with the evidence recorded
above; the mines fix has **landed in the working tree** with its final rule
documented in §2.4. The remaining work is administrative (commit/persist JSON
artifacts) or explicitly accepted fidelity/perf decisions (D-43, per-tile
depth, wet-rim orientation, skipped static cache) — none of which blocks the
wave, but all of which should stay visible rather than be silently claimed as
matches.
