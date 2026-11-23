# Performance Swarm — map/unit efficiency wave

> [!IMPORTANT]
> **LIVING DOC — sole writer:** T-DOCS-PERF2. Coordinator appends results via
> follow-ups; this file is updated as recon/measurement results arrive.
> Every claim below is either a **MEASUREMENT** (observed, with file:line or
> command/log evidence) or an **ESTIMATE** (labelled as such). Nothing is
> upgraded to PASS without evidence. See [Honest rules](#5-honest-rules).

Created: 2026-11-23. Wave scope: current map/unit efficiency work.

---

## 1. Goal + swarm log

### Goal

Make the game **super responsive with thousands of units**. This wave targets
map (terrain/forest/collision/nav) and unit (sim/lifecycle/node-count) efficiency
via a subagent swarm of parallel recons, each in its own lane. Findings are
logged here; wins land only with measured before/after numbers, dead ends are
recorded as **NO_WIN** so no one re-treads them.

### Swarm log

Status vocabulary: **IN_PROGRESS** (recon running / awaiting results) ·
**LANDED** (change merged + verified with evidence) · **NO_WIN** (investigated,
no benefit / regression / not worth cost — with evidence).

| Lane | Recon target | Session ID | Status | Note |
|---|---|---|---|---|
| L0 — docs | This tracking doc (T-DOCS-PERF2) | `<this-session>` | IN_PROGRESS | skeleton created; follow-ups appended 2026-11-23 |
| L1 — forest collision | Forest collision clusters / aggregates | `ses_df6ba9cd7ffeSDZhgXNl3Ux0KY` (T-FOREST-COLLIDE) | NO_WIN (perf) / HELD (correctness) | trees already in flat `blocked[]`; no perf win. Real correctness defects HELD (seed-dump/pathfinding gate risk). Lane redirected to L8 (§3.1, §2 NW-5) |
| L2 — forest render | Forest render batching | `ses_df6bac7d6ffeu5VhMJ8BREKkOj` (T-FOREST-BAKE) | LANDED | 1280² reusable SubViewport, 8 px/m bake, LRU 20; `t_forest_bake` 9/9 + `t_forest_bake_render` 3/3 PASS; 600–4000 quads → ~6–20 cached sprites (§3.2) |
| L3 — sim | Sim hotspots (per-unit / per-frame) | `<TBD>` | IN_PROGRESS | placeholder — awaiting recon |
| L4 — lifecycle | Stump lifecycle | `ses_df6ba9cd7ffeSDZhgXNl3Ux0KY` (T-FOREST-COLLIDE) | LANDED (design) | covered by the forest-collide session; design only, verification UNVERIFIED (§3.4) |
| L5 — node counts | Node counts / scene tree | `<TBD>` | IN_PROGRESS | counts measured from fresh dump — see §3.5 |
| L6 — water shader | Water shader fetch reduction | `ses_df6baf1f2ffeM6HMXzaePcKZSK` (T-WATER-FAST) | LANDED | shader edit verified + smoke load PASS; fetch reduction ESTIMATE, GPU effect UNMEASURED (§3.6, V7) |
| L7 — cliffs | Cliff collision/render aggregation | `<not supplied>` (cliffs recon) | NO_WIN | confirmed NO_WIN; folded into §2 NW-1/NW-2/NW-4 |
| L8 — sim hotspots | Sim scaling: building rect index / allocation-free separation / squad lookup | `ses_df6ba9cd7ffeSDZhgXNl3Ux0KY` (T-SIM-HOTSPOTS, redirected from L1) | LANDED | P1 rect index + P3 O(1) squad PASS; P2 kept ONLY provably-equivalent int hash keys — 5-cell/caching attempt REVERTED after regression. Final `t_sim_hotspots` 7/7 PASS, `t_mass_army` PASS (§3.8) |
| L9 — pick res | Runtime O(n) `res_nodes` scan in `_pick_res` | `ses_df6b8863effeznAWmFn4hO2Gu6` (T-PICK-RES) | LANDED | lazy 16 m spatial hash in `input_controller.gd`; `t_pick_res` 8/8 PASS ticket 1204 (functional scope; no before/after timing) (§3.9) |
| L10 — forest density | Denser forest generation (game.gd only) | `ses_df6b69981ffe55YEy6uN4VjAao` (T-FOREST-DENSE) | LANDED | fill 0.10→0.30, cap 10→14, groves tightened; `t_forest_dense` 12/12 PASS, `t_map_variety` 5/5 PASS; determinism byte-stable (§3.10) |
| L11 — mine build stall | QA catch: gather-while-building froze mine at ~80% | coordinator-applied (fix authored by a lane blocked from editing game.gd by concurrent ownership) | LANDED | player-scoped `nearest_mine` + unfinished-mine reroute to `cmd_build`; ticket 1228 `t_mine_build` all checks PASS (§6) |

> **Post-density scale note:** live wood is now ~1.7–1.9k (up from 1188),
> node memory ≈2 MB, so the pick-res spatial hash (L9) is now more relevant,
> not less. Wood-count figures in §3.5 are pre-/post-density, not interchangeable.

> Status note: **LANDED (design)** means the design/decisions are agreed, not
> that code is merged or a perf win is proven — verification rows stay
> UNVERIFIED until before/after numbers exist.
>
> Coordinator: when a lane's recon lands, replace `<TBD>` with the real session
> ID, flip Status to LANDED / NO_WIN, and append the evidence under
> [§3 Targets](#3-targets-from-recons-appendix).

---

## 2. Confirmed NO-WIN items (with evidence)

These were investigated and **ruled out**. Do not re-open without new evidence.

### NW-1 — Cliffs + water collision: aggregate into polygons

- **Verdict:** NO_WIN.
- **Evidence / reasoning:**
  - Collision is a single flat byte lookup. `game.gd:43` declares
    `var blocked: PackedByteArray = PackedByteArray()`; `game.gd:446-449`
    `is_blocked()` does one `_t(tile_of(p))` index into that flat array.
  - Nav's A* hot loop uses the integer form `nav.gd:72-77`
    `_blocked_xy(x, y, blocked)` → one `blocked[y * w + x]` read plus an
    `_extra` dict check. No Vector2i allocation per neighbour.
  - Cliff/water obstacles are stamped into that same flat `blocked[]` at map
    build time and read with a single index. Replacing it with polygon/
    region containment tests would add per-query geometry work on the hottest
    path and is therefore strictly worse than O(1) array access.
- **Measurement vs estimate:** Structural/ algorithmic argument from source
  (MEASUREMENT of code shape); the "polygons would be worse" claim is an
  ESTIMATE pending any benchmark (none needed to reject — regression is
  self-evident from complexity).

### NW-2 — Cliffs + water render: per-frame optimization

- **Verdict:** NO_WIN.
- **Evidence / reasoning:** Terrain/cliff/water rendering is **baked into
  terrain chunks**, so it incurs no meaningful per-frame cost to optimize.
  There is no per-frame hotspot here to target.
- **Measurement vs estimate:** Architecture fact from recon (MEASUREMENT);
  no profiler sample attributes cost to this path.
- **RECONCILED 2026-11-23 (water recon, §3.6):** "No per-frame cost" holds for
  **cliff/terrain geometry baked into chunks**, but NOT for the animated water
  *shader*, which re-shades every water pixel each frame (~69 fetches/px,
  source-counted). NW-2 is narrowed to cliffs/terrain geometry only; the water
  shader was an active optimization lane (T-WATER-FAST) and is now **LANDED**
  (§3.6), not a NO_WIN.

### NW-3 — Terrain static blit

- **Verdict:** NO_WIN (skipped earlier).
- **Evidence / reasoning:** A static-blit optimization for terrain was already
  considered and skipped because the **sim** dominates frame time; optimizing
  a non-dominant path would not move responsiveness.
- **Measurement vs estimate:** Prior decision (ESTIMATE of impact), recorded
  here to prevent repeat work. Revisit only if profiling shows render becoming
  dominant.

### NW-4 — Cliffs recon: per-tile flags; aggregation strictly worse (CONFIRMED NO-WIN)

- **Verdict:** NO_WIN (cliffs recon, 2026-11-23). Do not re-open.
- **Evidence (MEASUREMENT of source):**
  - Cliffs are **per-tile flags in the flat `PackedByteArray blocked[]`**
    (`game.gd:43` declaration; stamped at `game.gd:1078-1099`, e.g.
    `set_blocked_tile(x, y, true)` at `game.gd:1099`).
  - Cliff render is **baked into terrain chunk textures** and static forever
    (`world.gd:1492-1629`, `_build_chunk()` → `add_child(sp)` at `world.gd:1629`).
  - Lookup cost is already O(1): `is_blocked()` is one byte lookup
    (`game.gd:446-449`), nav's A* hot loop is one index
    (`nav.gd:72-77`, `blocked[y * w + x]`).
- **Reasoning:** Aggregating cliff tiles into polygons adds per-query geometry
  work to the hottest path and is **strictly worse** than a flat byte read
  (ESTIMATE of magnitude; algorithmic regression is self-evident).
- **Water collision correction:** Water uses the **same `blocked[]` byte**.
  `BLK_WATER := 255` (`game.gd:52`) is a **tileblock art sentinel**, NOT a
  value stored in `blocked[]`. Comments claiming water is held as `BLK_WATER`
  in the land `blocked` grid are **stale/misleading** (`game.gd:148`,
  `game.gd:4165`). Do not design against those comments.

### NW-5 — Forest cluster aggregation: NO perf win (final verdict, 2026-11-23)

- **Verdict:** NO_WIN **as a performance optimization**; correctness-only work
  HELD separately (not a perf ticket).
- **Evidence (MEASUREMENT of source):**
  - Trees are **already aggregated into flat `blocked[]`** via
    `set_blocked_circle()` (`game.gd:461-474`) — ~1332 circles called, but with
    `radius < 1 m` each stamps at most ~1 tile.
  - `is_blocked()` remains one byte lookup (`game.gd:446-449`).
  - `_blocked_for()` (`game.gd:147-165`) and `_separate_units()` **never scan
    `res_nodes`**. There is no per-query tree list to aggregate away.
- **Conclusion:** Cluster aggregation cannot reduce any measured hot-path
  work. Do not book it as a perf win.
- **Correctness issues found (real, but NOT perf):**
  - Scattered trees with arbitrary float positions stamp only **~78% of tiles**
    → walk-through gaps.
  - Harvesting a tree clears a shared cell that may be owned by a neighbour
    (`game.gd:5040`).
  - Fixing these via clusters would change **seed dumps and pathfinding
    gates** → HELD as correctness-only, not perf.
- **Status of prior design in §3.1:** the runtime-only aggregate/save-v4 design
  still stands **only** if/when correctness work is authorised; it yields no
  perf row.

---

## 3. Targets from recons (appendix)

> Findings are appended under each lane as they arrive: hypothesis, evidence
> (file:line + log/command), estimated gain (labelled ESTIMATE / INFERENCE until
> benchmarked), and decision (pursue / NO_WIN). Lanes still awaiting recon keep
> `<TBD>`. MEASUREMENT = observed in source/log; INFERENCE/ESTIMATE = projected,
> unmeasured.

### 3.1 Forest collision clusters — L1 (T-FOREST-COLLIDE, `ses_df6ba9cd7ffeSDZhgXNl3Ux0KY`)

- **Status:** NO_WIN (perf) / HELD (correctness). **Final verdict supersedes the
  earlier design landing:** trees are already aggregated into flat `blocked[]`;
  there is no perf win (§2 NW-5). Runtime-aggregate + save-v4 design below is
  retained **only** for the correctness fixes, pending authorisation; code
  merge and benchmarks UNVERIFIED.
- **Finding (MEASUREMENT of design decisions):**
  - Tree lifecycle: `tree → stump → 60 s removal`. Per-node blocking is
    **released at harvest**, not at stump removal.
  - `dead = hits <= 0`.
  - Aggregates (forest collision clusters) **MUST be a runtime-only separate
    dictionary**, never stored in `res_nodes`.
- **Rationale (MEASUREMENT of code-shape coupling):** Existing code directly
  dereferences `.radius` on `res_nodes` entries and matches on node shape in
  `can_place`; injecting aggregate entries into `res_nodes` would break those
  paths. Keep aggregates out of serialized node state.
- **Save-format decisions:** save **version 4** with optional `cluster_id`;
  rebuild caches on deserialize; keep a **legacy spatial-bucket fallback**
  for older saves.
- **Evidence (file:line / command):** `<TBD — add exact res_nodes / can_place / harvest call sites when supplied>`
- **Estimated gain:** `<TBD>` (no before/after numbers supplied — do not infer).
- **Decision:** **HELD** as correctness-only (seed-dump + pathfinding-gate
  impact); do not claim a perf win. V1/V4 stay UNVERIFIED. Lane redirected to
  sim hotspots (L8 / §3.8).

### 3.2 Forest render batching — L2 (T-FOREST-BAKE, `ses_df6bac7d6ffeu5VhMJ8BREKkOj`)

- **Status:** **LANDED** (functional tests PASS; visual A/B vs old path not
  formally scored). See the applied implementation below.
- **Finding (recon observation; quad count/range UNVERIFIED by local profiler):**
  - `res_layer` draws **600–4000 textured quads/frame** while panning or while
    any field regrows.
  - **2 quads + 2 transforms per prop** (`_blob_rect` + `_draw_prop`), no
    batching.
- **Evidence (source anchors, MEASUREMENT):** `_blob_rect` at
  `world.gd:668`; `_draw_prop` at `world.gd:2082`; forest draw helpers
  `_draw_forest_tree` (`world.gd:2095`) and `_draw_forest_understory`
  (`world.gd:2122`), which call `_blob_rect` (`world.gd:2116`,
  `world.gd:2140`). Pan/field invalidation path at `world.gd:1805-1813`
  (`sim_dirty`, `fields_live` from `game.fields_anim`).
- **Applied fix (MEASUREMENT of landed source):**
  - `forest_layer` z=1 added **before** `res_layer` (`world.gd:255-261`);
    `forest_chunks` dict at `world.gd:107`; `FOREST_CHUNK_CACHE := 20` at
    `world.gd:104` (tunable).
  - Reusable transparent `SubViewport` **1280×1280**, `UPDATE_ONCE`,
    `disable_3d` (`world.gd:1858`, bake at `:1899-1921`).
  - `_draw_forest_tree`/`_understory` refactored with layer+origin params;
    `_draw_forest_cell_trees`/`_draw_forest_cell_edge` extracted and shared by
    the live fallback and the baker (live path `world.gd:2650`).
  - `_bake_forest_chunk()` full-res GPU draw → bilinear downsample to **8 px/m**
    → `ImageTexture` with a generation guard; `_sync_forest_chunks()` bakes
    centre-out **≤2/frame** (`world.gd:1953-1989`, called at `:2037`).
  - Invalidation keyed on **seed / dims / terrain-px / view-scale / season /
    relief only** — **NOT** `res_dirty`/`fields_anim` (verified by
    `no_res_dirty_invalidation` test). `main.gd:1056` calls
    `invalidate_forest_bake()` on a quality change.
  - Layering untouched: fog `z=10` above, water `z=-9` below (test-verified).
- **Verification:** `world.gd`/`main.gd` `--check-only` ok;
  `t_forest_bake` **9/9 PASS** (layer order, viewport ready, chunks populate
  20 from 5×5, LRU bounded 20, no res_dirty invalidation, invalidate rebakes,
  fallback callable, layering untouched, deterministic signature);
  `t_forest_bake_render` **3/3 PASS** (`real_chunks_baked=2`,
  `baked_detail_pixels=268/12800`, PNG
  `app/tests/results/t_forest_bake_render.png`).
- **Quad reduction:** panning/regrow draw of **600–4000 forest quads/frame →
  ~6–20 cached sprites** (structural count from the bake design, **not** a
  GPU-measured frame-time delta).
- **Memory:** viewport 6.25 MB transient; ~1.56 MB image + ~3.1 MB GPU per
  chunk; **LRU 20 ≈ 62 MB steady state** (tune `FOREST_CHUNK_CACHE`).
- **Scope honesty:** functional correctness and chunk population are PASS;
  **visual A/B vs the old live-draw path was not formally scored**.
- **Decision:** LANDED; V8 PASS is structural/functional scope only — do not
  claim a measured FPS win.

### 3.3 Sim hotspots — L3
- **Status:** IN_PROGRESS — awaiting recon.
- **Hypothesis / finding:** `<TBD>`
- **Evidence (file:line / command):** `<TBD>`
- **Estimated gain:** `<TBD>`
- **Decision:** `<TBD>`

### 3.4 Stump lifecycle — L4 (covered by T-FOREST-COLLIDE, `ses_df6ba9cd7ffeSDZhgXNl3Ux0KY`)

- **Status:** LANDED (design) — see §3.1 for the full stump/save decision set;
  code merge + verification UNVERIFIED.
- **Finding (MEASUREMENT of design decisions):**
  - `tree → stump → 60 s removal`; blocking released **at harvest**
    (not at the 60 s stump removal).
  - `dead = hits <= 0`.
  - Serialization: save **version 4**, optional `cluster_id`, rebuild caches on
    deserialize, legacy spatial-bucket fallback.
- **Evidence (file:line / command):** `<TBD — add exact harvest/stump-removal call sites>`
- **Estimated gain:** `<TBD>` (node/blocking churn reduction plausible, unmeasured).
- **Decision:** Pursue as specified in §3.1.

### 3.5 Node counts — L5

- **Status:** IN_PROGRESS — counts MEASURED; optimization not implemented.
- **Finding (MEASUREMENT from fresh dump, seed `20261113`, PRE-density):**
  - `wood=1188`, `stone=123`, `mines=21`, `bush=264`, `food=0`,
    **total = 1596** resource nodes.
  - **POST-density (T-FOREST-DENSE, §3.10):** live wood **1681** (seed
    20261113) / **1612** (seed 12345); `wood_all` 1862 / 1766. These supersede
    1188 for current maps; node memory ≈ **2 MB**.
  - `blocked` = **7976 / 102400 tiles (7.79%)**.
  - Node dicts ≈ **1.3 MB**.
  - Naive scan **0.24–0.64 ms/query**; existing `_res_grid` (16 m cells,
    ~18 visits/query) is **~85× fewer** visits.
- **Evidence (file:line / command):**
  - Dumps: `app/shots/t6t90_dumps/dump_20261113_a.json`,
    `dump_20261113_b.json`.
  - Generation/scale: `pattern_gen.gd:9` (`DONOR_UNITS := 160.0`),
    `pattern_gen.gd:418` (`area_scale`), `pattern_gen.gd:429-455`
    (`forest_recipes` / `stamp_family`).
  - Resource placement: `game.gd:743-754`, `game.gd:1122-1135`.
  - Existing spatial grid: `game.gd:107-108`, `game.gd:2613-2626`.
- **Estimated gain:** `<TBD>` — scan numbers are MEASUREMENTS, but the ~85×
  figure is a **visit-count ratio**, not a frame-time delta.
- **Decision:** Existing `_res_grid` already solves the scan cost; do not add a
  second index. Reuse it in L9 (§3.9).

### 3.6 Water shader — L6 (T-WATER-FAST, `ses_df6baf1f2ffeM6HMXzaePcKZSK`)

- **Status:** **LANDED** (shader edit applied + smoke load PASS, 2026-11-23).
  Perf effect remains UNMEASURED — see the honest split below.
- **Finding (MEASUREMENT, source-counted / observed):**
  - Shader does **~69 fetches per water pixel: 68 noise + 1 mask**, **not ~12**.
    `docs/audit/WATER_PERF.md` is **stale** on this figure (file exists; its
    ~12 claim is contradicted by the recon count).
  - **Deep water computes foam + turbidity multiplied by `band = 0`** — the
    work is done and then nulled.
- **Applied fix (MEASUREMENT of landed source, `app/shaders/water_overlay.gdshader`):**
  - `// T-WATER-FAST` header comment at `water_overlay.gdshader:27` (with
    `:24`, `:29`, `:34` explaining the rationale).
  - Octave loop `for (int i = 0; i < 9; i++)` at `:127` keeps the **constant
    bound 9**; `float g = clamp(...)` at `:131`; new
    `if (g <= 0.0) break;` at `:132-134` fires before the noise fetch at `:135`.
  - `float band = coastfade * (1.0 - coastfade2)` at `:216`; turbidity/mottle
    gated by `if (band > 0.0)` at `:220-224` with `mottle = 0.0` default at
    `:219`; foam `nautic()`/`particles()` gated at `:265-269` with zero
    defaults at `:263-264`. Band-multiplied adds remain at `:270-271`.
  - **Untouched (verified still present):** `BODY_SWELL_AMP` (`:81`),
    `BODY_SPAN` (`:85`), `BODY_TAPER` (`:89`), D-43 colours, alpha equation,
    uniforms, sampler count.
- **Correctness argument (algebraic, not GPU-measured):** skipped noise terms
  are multiplied by `band == 0`, and `mottle` only feeds `band`-multiplied
  `foam_gain`, so output is **algebraically bit-identical**. Screenshot diff
  not run — visual equivalence is argued algebraically, not pixel-verified.
- **Fetch reduction:** **~11 fetches per deep-water pixel (69 → 58), ~3 on
  shallow** — ESTIMATE from static counting, **not** a GPU measurement.
- **Gain estimate:** **8–20 ms/frame GPU cost remains INFERENCE, unmeasured.**
  Do not present as a measured perf result.
- **Paused-time note (recon observation):** Water render **animates while
  paused**; pausing the time uniform **saves no GPU** because the canvas is
  re-shaded anyway. Do not count this as a win.
- **Verification (V7):** runner ticket **1193 `twf-water-smoke`** —
  `ResourceLoader.exists` + `load()` of the shader (NOT a `--check-only`
  parse); `END ok`, **0.56 s**, stdout `WATER_SHADER_SMOKE OK exists=true
  class=Shader`, stderr empty. Godot **4.7.2** compiled with no errors.
- **Decision:** LANDED. Shader load/compile PASS; perf effect UNMEASURED —
  no FPS/frame-time win may be claimed from V7.

### 3.8 Sim hotspots — L8 (T-SIM-HOTSPOTS, `ses_df6ba9cd7ffeSDZhgXNl3Ux0KY`, redirected from L1)

- **Status:** **LANDED** — P1/P2/P3 applied; final all-PASS parity suite.
  The earlier P2 regression was resolved by reverting the unsafe part.
- **Measured baseline (MEASUREMENT):** **196 ms/tick @ 618 units**, sim-only
  headless, no orders/squads active.
- **Projections (ESTIMATES, NOT measurements):**
  - 635 ms/tick @ 2000 units
  - 952 ms/tick @ 3000 units
  - These are **linear extrapolations** from the 618-unit baseline; do not
    quote them as measured results.
- **Applied changes (MEASUREMENT of landed source):**
  - **P1** — building-rect tile index: dict keyed by `x + y*MAP_W`
    (`game.gd:117-135`, probe path at `:178-184`), so a unit checks only rects
    registered on its own tile.
  - **P3** — O(1) `squad_of_unit` via `u.squad`, with legacy membership-scan
    fallback (`game.gd:2980`).
  - **P2** — **ONLY** provably-equivalent int hash keys in separation
    (`game.gd:3879-3888`): replaces `Vector2i` keys (~19 allocations/unit/tick)
    while the **legacy 9-cell 2-pass visitation order is preserved exactly**.
  - **REVERTED:** the attempted 5-cell half-neighbourhood + `cx`/`cy` caching.
    Sequential pair relaxation means changing visitation order changes results
    even with an identical pair set (regression: **max delta 7.29 m**,
    **337 overlaps**). Do not re-attempt without order-equivalence proof.
- **Not a bottleneck (MEASUREMENT of code shape):** Nav A* is **budget-capped at
  2 repaths/tick** (`NAV_PER_TICK := 2`, `game.gd:13`; budget reset
  `game.gd:3777`), so it does not scale with unit count. Do not target it.
- **Final verification (coordinator sign-off, MEASUREMENT):**
  - `t_sim_hotspots.json` **7/7 PASS**:
    - `block_rect_index_parity` — 200 points × 2 targets, **0 mismatches**,
      791 index cells (also 0 indexed-only / 0 brute-only).
    - `separation_matches_legacy` — **max delta 0.0000000 m** vs legacy
      9-cell algorithm; `separation_no_overlap` — min gap 0.838 m,
      **0 overlapping pairs among 300 units**.
    - `squad_fast_path` (officer/drummer/4 members → squad 1 via `u.squad`),
      `squad_legacy_fallback` (member without `unit.squad` found by scan),
      `squad_nonmember_empty`.
  - `t_mass_army.json` PASS including **`no_unit_overlap` 0 pairs among 552
    units** (552 distinct ids, 4 squads, 10 sim-seconds / 40 ticks,
    corpses+rubble age out). Mass-sim wall time 16601.41 ms recorded (a
    recorded metric, not a before/after result).
  - The earlier P2 FAIL (6.41 m delta, 565 overlaps) is **resolved** by the
    revert described above; the 7.29 m/337-overlap failed variant is not in
    the final tree.
- **Tooling:** scaling probe **`app/tests/t_perf_scale.gd` now exists**
  (`app/tests/results/t_perf_scale.json`).
- **Perf-scale probe (`t_perf_scale.gd`, numbers-only, median of 3 reps,
  MEASURED on a shared runner):** `move_ms` before → after:
  - n=300: **1027.1 → 334.4 / 487.7 ms**
  - n=1000: **2692.9 → 1887.1 / 1943.9 ms**
  - n=3000: **11730.3 → 7272.4 / 10387.3 ms**
  - Roughly **~1.5–3× faster on move-heavy ticks**; `squad_ms` is dominated
    by noise (the probe has only **1 squad**). One earlier after-run under
    heavy runner load was **not comparable** and is excluded.
  - Caveats: shared runner, numbers-only probe; the **196 ms/tick @ 618 units**
    baseline is **sim-only with no orders** and is **NOT directly comparable**
    to these move-heavy probe numbers — keep the two datasets separate.
- **Evidence (file:line / command):** `game.gd:13`, `game.gd:3777`,
  `game.gd:117-184`, `game.gd:2980`, `game.gd:3879-3888`, plus
  `app/tests/results/t_sim_hotspots.json`, `t_mass_army.json`,
  `t_perf_scale.json`.
- **Decision:** LANDED. P2 unsafe variant reverted; parity and mass-army tests
  all PASS. V10 PASS with the perf-scale caveats above.

### 3.9 Pick-res runtime scan — L9 (T-PICK-RES, `ses_df6b8863effeznAWmFn4hO2Gu6`)

- **Status:** **LANDED** (functional verification PASS; no perf timing).
- **Finding (MEASUREMENT of source):** The only remaining runtime O(n) scan
  over `res_nodes` was `input_controller._pick_res()`
  (`input_controller.gd:544-557` in the pre-fix tree).
- **Applied fix (MEASUREMENT of landed source):**
  - Lazy **16 m spatial hash** (`_PICK_RES_GRID_M := 16.0` at
    `input_controller.gd:549`; `_pick_res_grid` / `_pick_res_ver` /
    `_pick_res_size` at `:550-552`).
  - `_pick_res_grid_ensure()` at `:555-567` rebuilds only when
    `game.res_dirty` or `res_nodes.size()` changes (`:556`).
  - **All nodes inserted unfiltered** (`:559-565`) — deliberately NOT the
    game's private grid, which filters depleted nodes and would change
    behaviour.
  - `_pick_res()` at `:572-581` looks up cells (`<=4` cells) instead of
    scanning every node: **O(n) → O(k)**.
  - Earlier **1195/1196/1200 failures** were another lane mid-editing
    `world.gd` (compile blocked) plus a test-ordering bug — resolved.
- **Verification:** `t_pick_res` **8/8 PASS**, ticket **1204**
  (`app/tests/results/t_pick_res.json`) — lazy build, invalidation on
  `res_dirty` and size change, depleted-stump skip, far-pick null, known-tree
  pick.
- **Scope honesty:** functional correctness is PASS; **no before/after click
  latency was measured**, so any speedup from O(n)→O(k) is structural reasoning
  (ESTIMATE), not a measured perf result.
- **Decision:** LANDED; V11 PASS is functional-scope only.

### 3.10 Forest density — L10 (T-FOREST-DENSE, `ses_df6b69981ffe55YEy6uN4VjAao`)

- **Status:** **LANDED** — game.gd forest-generation-only change.
- **Applied change (MEASUREMENT of landed source):**
  - Per-cell fill probability **0.10 → 0.30**, cap **10 → 14**
    (`game.gd:760-766`, in `_gen_patterns`); comment at `:760`.
  - Sacred-grove spread **5/4 → 3.5/3 tiles** (`game.gd:1156-1162`, counts
    **34/23**); same tightening in `_gen_finish` (`game.gd:1378-1381`).
  - `pattern_gen.gd`: **comment-only** change.
- **Measured metrics (320×320, two seeds; from
  `app/tests/results/t_forest_dense.json`):**

  | Seed | Live wood | Mean NN | Trees within 6 m | Min live-wood ↔ stone/ore |
  |---|---|---|---|---|
  | 20261113 | 1055 → 1681 (×1.59) | 6.819 → 4.650 m (−31.8%) | 60.37% → 82.38% (+22.01 pp) | 10.00 m (no overlap) |
  | 12345 | 1001 → 1612 (×1.61) | 7.085 → 4.777 m (−32.6%) | 58.22% → 80.64% (+22.42 pp) | 10.00 m (no overlap) |

  - Max isolated gap also shrank: 37.95 → 32.06 m and 31.62 → 22.80 m.
- **Determinism (MEASUREMENT):** same RNG **draw count**; layouts change, but
  each seed is **byte-stable** (repeat summary 126155 vs 126155 bytes in
  `t_map_variety`); the downstream RNG stream consequently shifts.
- **Verification:** `t_forest_dense` **12/12 PASS**, `t_map_variety` **5/5
  PASS**. Gen cost ≈ **5 s/seed** (gen-time, not frame-time).
- **Scope honesty:** these are **generation-quality/determinism** results.
  No runtime frame-time win is claimed; denser forest raises wood to ~1.7–1.9k
  and memory ≈2 MB, which makes L9's pick hash more relevant.
- **Decision:** LANDED; V12 PASS is gen-metrics scope only.

---

## 4. Verification table (placeholders)

Fill before/after from the same workload (same seed, unit count, scene, runner
command). Leave `UNVERIFIED` until measured — do not infer a PASS.

| ID | Change / lane | Test / command | Before (metric) | After (metric) | Delta | Status |
|---|---|---|---|---|---|---|
| V1 | forest collision (L1) | `<TBD>` | `<TBD>` | `<TBD>` | `<TBD>` | UNVERIFIED |
| V2 | forest render recon (L2) | recon: 600–4000 quads/frame on pan/regrow | 600–4000 quads/frame | ~6–20 baked sprites | structural count | PASS (recon scope) — see V8 for landed fix |
| V3 | sim hotspots (L3) | `<TBD>` | `<TBD>` | `<TBD>` | `<TBD>` | UNVERIFIED |
| V4 | stump lifecycle (L4) | `<TBD>` | `<TBD>` | `<TBD>` | `<TBD>` | UNVERIFIED |
| V5 | node counts (L5) | `<TBD>` | `<TBD>` | `<TBD>` | `<TBD>` | UNVERIFIED |
| V6 | thousands-of-units responsiveness (overall) | `<TBD>` | `<TBD>` | `<TBD>` | `<TBD>` | UNVERIFIED |
| V7 | water shader branch + octave break (L6) | runner 1193 `twf-water-smoke`: `ResourceLoader.exists` + `load()`; Godot 4.7.2 compile | n/a (load check) | `END ok` 0.56 s; `WATER_SHADER_SMOKE OK exists=true class=Shader`; stderr empty | n/a | **PASS (shader load/compile scope only)** — perf effect UNMEASURED |
| V8 | forest half-res SubViewport chunk bake (L2) | `t_forest_bake` 9/9 + `t_forest_bake_render` 3/3; `--check-only` ok; PNG `t_forest_bake_render.png` | 600–4000 forest quads/frame | ~6–20 cached sprites; LRU 20 ≈ 62 MB | quad count ↓; memory ↑ | **PASS (structural/functional scope)** — visual A/B not scored, no frame-time delta |
| V9 | forest collision aggregates / stump lifecycle (L1/L4) | `<TBD — harvest + save-v4 roundtrip + blocking churn>` | `<TBD>` | `<TBD>` | `<TBD>` | UNVERIFIED |
| V10 | sim hotspots P1/P2/P3 (L8) | `t_sim_hotspots` 7/7 + `t_mass_army` PASS (552 units, 0 overlaps) | legacy 9-cell order; 196 ms/tick @ 618 (separate baseline) | int-hash keys, 0.0000000 m parity delta; 0 overlaps/300 and /552 | parity exact | **PASS (parity scope)** — unsafe 5-cell variant reverted; move-heavy gain in V13 |
| V11 | `_pick_res` lazy 16 m spatial hash (L9) | ticket 1204 `t_pick_res` 8/8 (lazy build, invalidation, depleted skip) | n/a (functional check) | 8/8 PASS | n/a | **PASS (functional scope)** — click latency UNMEASURED |
| V12 | forest density generation (L10) | `t_forest_dense` 12/12 + `t_map_variety` 5/5, seeds 20261113/12345 | live wood 1055 / 1001; mean NN 6.819 / 7.085 m; within-6m 60.37% / 58.22% | live wood 1681 / 1612; mean NN 4.650 / 4.777 m; within-6m 82.38% / 80.64% | +1.59/1.61×; −31.8%/−32.6%; +22 pp | **PASS (gen-metrics/determinism scope)** — no frame-time claim |
| V13 | perf-scale probe (L8) | `t_perf_scale.gd` numbers-only, median of 3, shared runner | move_ms 1027.1 / 2692.9 / 11730.3 (n=300/1000/3000) | move_ms 334.4 / 1887.1 / 7272.4 (alt after-runs 487.7 / 1943.9 / 10387.3) | ~1.5–3× on move-heavy ticks | **MEASURED (caveated)** — shared runner; squad_ms noise (1 squad); one heavy-load after-run excluded; NOT comparable to 196 ms/tick sim-only baseline |
| V14 | mine-build gather stall (L11, QA catch) | ticket 1228 `t_mine_build.gd` all checks PASS | build froze ~80% (7.547/9.375), order overwritten to gather | interrupt → order=build, final 9.375/9.375 finished=true | stall removed | **PASS (functional scope)** — coordinator-applied |

> **Keep datasets separate (do not conflate):** (a) **196 ms/tick @ 618 units**
> is a sim-only headless baseline with no orders/squads; (b) the original
> **635 ms @ 2000** / **952 ms @ 3000** were linear ESTIMATES, never measured;
> (c) V13's move-heavy probe numbers are MEASURED on a shared runner with a
> different workload. Only (c) is valid before/after evidence for the sim
> change; (a) and (b) are context only. V10's PASS is parity scope, not speed.

> Metric suggestions (pick one, keep consistent): wall-clock ms for a fixed
> tick budget, FPS at a fixed unit count, node count from `doc_inspect`/
> scene-tree dump, or profiler self-time for a named function. Always record
> the seed, unit count, and runner command alongside the number.

---

## 5. Honest rules

1. **No fake PASS.** A row is PASS only when before/after numbers exist from
   the same workload and are recorded with evidence. Otherwise it stays
   **UNVERIFIED**. A *scoped* PASS (e.g. V7's shader load/compile) validates
   **only that scope** — it is never a perf-pass and cannot be upgraded to one
   without a measured frame-time delta.
2. **Mark UNVERIFIED, don't infer.** Absence of a regression is not a win;
   a clean selftest is not a perf result.
3. **Cite file:line.** Every structural claim points to a concrete
   `path:line` (or a command/log id). Unsupported claims are removed or tagged
   as ESTIMATE.
4. **Separate measurement from estimate.** Label each statement MEASUREMENT
   (observed, reproducible), ESTIMATE (projected/unbenchmarked), or INFERENCE
   (reasoned from other observations, unmeasured). Never mix them in one number.
5. **Same workload for before/after.** Seed, unit count, scene and runner
   command must match, or the comparison is void.
6. **NO_WIN is a result, not a failure.** Record the evidence so the lane is
   not re-opened without new information.
7. **Sole writer.** Only T-DOCS-PERF2 edits this file; coordinator sends
   follow-ups with results to append.

---

## 6. QA catches

### 6.1 MINE BUILD STALL — FIXED (L11, coordinator-applied)

- **Verdict:** LANDED (functional PASS).
- **Symptom:** right-clicking an ore deposit while its mine was under
  construction permanently froze the site at ~80% of build time, with message
  "No `<ore>` mine - build one on a deposit."
- **Root cause (MEASUREMENT, NOT snapping):** auto-snap already existed —
  `place_building()` snaps `pos = n.pos` (`game.gd:3634-3652`). The real path
  was `input_controller` → `cmd_gather()` (`game.gd:2846`), which called
  `nearest_mine()` with the default `player := -1` (`game.gd:2658`), so it
  accepted **unfinished** and **other-player** mines and overwrote the
  builder's `build` order with `{type: gather}`. `_tick_gather()` then parked
  the peasant in a wait loop at the site, freezing construction.
- **Fix applied (coordinator, `game.gd:2853-2863`):**
  - player-scoped lookup: `nearest_mine(e.pos, type, int(e.player))`;
  - unfinished mine (`!mine.finished`) is rerouted via `cmd_build(e, mine)`
    instead of gather.
  - The fix was authored by a lane that **could not edit `game.gd`** due to
    concurrent ownership; the coordinator applied it after checking the
    `nearest_mine` signature (`game.gd:2658`, `player := -1`).
- **Verification:** `t_mine_build.gd` ticket **1228**, `END ok`, all checks PASS
  (`app/tests/results/t_mine_build.json`), including
  `B_gather_interrupt_did_not_stall_build` — progress at interrupt
  **7.547/9.375 (80.5%)**, `order_after=build`, final **9.375/9.375**,
  `finished=true`; also `C_far_builder_finishes` PASS. 8/8 checks, no messages.
- **Scope honesty:** functional regression fix, verified by test; no perf claim.

---

## 7. Overall status

**Wave outcome: all active optimization lanes LANDED; remaining items are
confirmed NO_WIN.** Final gate: **23/23 PASS, ticket 1231**.

| Lane | Final status |
|---|---|
| L1 forest collision (perf) | NO_WIN — trees already in flat `blocked[]`; correctness work HELD |
| L2 forest render | LANDED — `t_forest_bake` 9/9 + render 3/3 |
| L4 stump lifecycle | LANDED (design) — correctness path, not perf |
| L6 water shader | LANDED — load/compile PASS; perf UNMEASURED |
| L7 cliffs / water-baked / terrain blit | NO_WIN — see §2 NW-1…NW-5 (hull also reported NO_WIN by coordinator; not itemised here) |
| L8 sim hotspots | LANDED — 7/7 parity + mass-army PASS; unsafe P2 variant reverted |
| L9 pick res | LANDED — 8/8 PASS; O(n)→O(k) structural |
| L10 forest density | LANDED — 12/12 + 5/5, determinism byte-stable |
| L11 mine build stall (QA catch) | LANDED — coordinator-applied, ticket 1228 |

> L3 (sim) and L5 (node counts) were **umbrella placeholders**, not separate
> lanes: L3 was fulfilled by L8, L5 by the measured counts in §3.5. L0 (docs)
> is this living file.

### Honest caveats (carry forward)

1. **Forest bake visual A/B vs the old live-draw path was not formally scored.**
   Chunk population, layering and determinism are tested; visual equivalence is
   not.
2. **Water shader perf effect remains unmeasured.** Fetch reduction is a static
   ESTIMATE (69→58 deep); 8–20 ms/frame stays INFERENCE. Shader load/compile
   PASS is scope-limited.
3. **Full selftest remains historically unverified** — do not treat a green
   targeted test as a full-suite PASS.
4. **New tests were registered in `app/tests/manifest.json` by various lanes**;
   registration is not itself a verification of every test's perf claim.
5. **Perf datasets are not interchangeable** — the 196 ms/tick sim-only
   baseline, the old linear ESTIMATES, and V13's move-heavy shared-runner
   probe must stay separate (see §4 note).
