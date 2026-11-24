---
owner: P1
wave: perf
date: 2026-11-24
lane: sim hotpaths (game.gd / ai.gd) — NEW opportunities only
scope: READ-ONLY recon. No code, no Godot, no seed dumps run by this worker.
paths: all `file:line` below are under `app/scripts/` unless stated.
excluded: PERFORMANCE_SWARM.md LANDED items (building-rect tile index, O(1) squad_of_unit, int-hash separation, NAV_PER_TICK=2 budget) and confirmed NO_WIN items (cliffs/water collision, forest clusters, terrain static blit, nav A* scaling).
---

# P1 — remaining per-tick / per-frame SIM opportunities

**Honesty note:** this worker ran **no benchmarks**. Every structural statement is
**MEASUREMENT (code shape)** — read directly from source. Every gain projection is
**ESTIMATE** or **INFERENCE**, explicitly labelled. No FPS or ms win is claimed.

## Claim table

Method key: `M` = MEASUREMENT of code shape (source-counted, reproducible by reading);
`E` = ESTIMATE (projected, unbenchmarked); `I` = INFERENCE.

| # | Hotspot | Evidence file:line | Scaling | Method | Verdict | Proposed fix | Determinism risk |
|---|---|---|---|---|---|---|---|
| 1 | `_grid_rebuild()` rebuilds the whole entity spatial hash every tick: `grid.clear()`, one `Vector2i` alloc per live entity, fresh `[]` per occupied cell; `grid_query()` then allocates a default `[]` for every empty cell probed. | `game.gd:213-238` (`clear` :214, `Vector2i` :223, `grid[c]=[]` :225); `grid_query` :240-249 (default `[]` :246, `out=[]` :241) | M: O(N) entities/tick + O(cells) allocs per query; E: dominant small-object churn at N=1000-3000 | M (shape), E (gain) | **PURSUE — rank 1** | Use int key `cx + cy*65536` (same trick already proven safe in `_separate_units`, `game.gd:3883`) for `grid`; keep bucket arrays and `.clear()` them in place instead of `grid.clear()`; pass a script-level shared empty array as `grid.get()` default. Preserve row-major cell order and per-bucket append order exactly. | **NONE–LOW.** `grid` is runtime-only (absent from `serialize()` :5418-5453). Cell/entity visitation order unchanged; int key is a bijection of Vector2i. Verify with seed dump byte-identity + `t_sim_hotspots` 7/7. |
| 2 | `grid_query()` allocates a result Array per call; 11 call sites, several per unit per acquisition. `enemies_in_radius`/`enemies_preferred` run for every armed idle unit on `acq_now` (0.125 s cadence; at dt=0.25 in the probe this is **every tick**). | `grid_query` :240-249; sites :2734, :2770, :3629, :3958, :4748, :4774, :4917, :4934, :4953, :5049, :5266; acq gate :4413-4420; idle acquire :4679-4694 | M: O(query cells) allocs × O(N) units; E: at N=3000 this is thousands of Array allocs on acq ticks | M (shape + count), E (gain) | **PURSUE — rank 2** | Add `grid_query_into(pos, r, out)` that clears a caller-owned array and fills cells in the same `(cy,cx)` order; use at the hottest sites (:2734, :2770, :4748, :5049). Alternative: inline cell iteration at :2734/:2770. Do **not** use one global scratch until nesting is proven absent. | **LOW–MEDIUM.** Results depend only on membership + strict `<`/`>` selection; preserving cell and bucket order preserves ties. Risk is aliasing if a scratch buffer is reused across nested calls — caller-owned buffers avoid it. |
| 3 | `res_nodes` (≈1700-1900 live nodes post-density, PERFORMANCE_SWARM §3.10) is scanned **3× per tick**: stump age, stump removal, field regrow. Each iteration does `str(n.get("type",""))` and `n.get(...)` Variant churn. | `tick()` :3863-3865, :3866-3872; `_tick_fields` :2249-2269 (`str` at :2252, `_field_mill_id` at :2255) | M: 3 × O(R) per tick, R≈1700-1900; E: ~5k `get` + ~5k `str` calls/tick | M (shape), E (gain) | **PURSUE — rank 3** | Maintain a `stumps: Array` (append at :5088-5090, remove in the existing reverse loop :3866) and a `fields: Array` (food nodes with `mill`); iterate those instead of `res_nodes`. Keep `res_nodes` order untouched so `serialize()` stays byte-identical. Must also maintain on `_compact` :271-280 and `deserialize` :5475+. | **LOW–MEDIUM.** Side effects (`set_blocked_circle`, `by_id.erase`, `res_dirty++`, growth fields) are per-node independent, but order of `res_dirty` bumps and mill re-adoption (`_field_mill_id` :2180-2185 mutates `n["mill"]`) must be replayed in the same order. Requires byte-identical seed dump gate. |
| 4 | `enemies_preferred()` recomputes `_kind_class(a)` and re-fetches `TARGET_TABLE` row for **every candidate**, although `a` is constant per query; `_kind_class()` itself calls `weapon_of()` per candidate. AI duplicates the same double call per military unit. | `enemies_preferred` :2767-2782; `_target_score` :2761-2765; `_kind_class` :2747-2759 (`weapon_of` :2754); `ai.gd:520` calls `game._kind_class(m)` **twice** in one statement | M: 2-3 `_kind_class()` calls per candidate per query; E: O(N·k) at N=3000, 8 acquire/s | M (shape), E (gain) | **PURSUE — rank 4** | Hoist `ac := _kind_class(a)` and `row := TARGET_TABLE.get(ac, {})` out of the loop; add a `_target_score_row(row, t)` helper using the precomputed `ac`. Fix `ai.gd:520` to call once. Pure function hoist — no changes to comparison order or float expression. | **NONE.** `_kind_class` is read-only over `def`; `TARGET_TABLE` is static. Strict `> best_s` selection order unchanged. |
| 5 | Per-call building-list rebuilds: `nearest_drop()` calls `buildings_of()` (array alloc + full `live_blds` scan) on every delivery; `_check_victory()` calls `buildings_of()`+`units_of()` (2 arrays, 2 scans × players) **every tick**; `_field_mill_id()` scans `live_blds` per unlinked field. | `nearest_drop` :2592-2606 (`buildings_of` :2596); `buildings_of` :2565-2570; `units_of` :2572-2577; `_check_victory` :5371; `_field_mill_id` :2180-2185; called from `_tick_fields` :2255 | M: O(B+U) allocs per delivery + O((B+U)·P) per tick; E: small but free to remove | M (shape), E (gain) | **PURSUE — rank 5** | Replace `buildings_of` in `nearest_drop` and `_check_victory` with direct `live_blds`/`live_units` loops (same filters, same strict `<`, early-exit for victory). Cache a `mills: Array` rebuilt on `bld_dirty` for `_field_mill_id`'s fallback. | **NONE–LOW** if iteration order preserved (both helpers iterate `live_blds`/`live_units` in order). The mill cache must keep the same first-match order on rebuild; otherwise `n["mill"]` adoption could change seed dumps. |
| 6 | `officer_near`/`drummer_near` scan `officers[player]`/`drummers[player]` for every unit on every acquisition (0.125 s), i.e. O(U·O). | `officer_near` :3528-3536, `drummer_near` :3538-3546; called :4417-4418; radii `data.gd:82,84` | M: O(U·O) per acq; E: large only with many officers | M (shape), E (gain) | **HOLD — needs new probe** | Query a spatial index for auras, or prune dead officers once per tick in `_grid_rebuild`. Aura is boolean so result order does not matter, but officer positions change mid-tick. | **MEDIUM** — caching positions at tick start changes which units receive the bonus when an officer moves during the same tick, which can alter morale/rout and seed dumps. t_perf_scale has 1 officer (player 1) so this is unmeasured. |
| 7 | AI `_form_squads()` is O(officers × military): each officer rescans all military for loose troops. `_raids()` still O(food_fields × foe_peas). AI runs only once/s (`data.gd:69`). | `ai.gd:560-579`, `ai.gd:645-653`; interval `data.gd:69`; double `_kind_class` at `ai.gd:520` | M: O(O·M) per think tick; E: 90k checks/s at 30 officers × 3000 military | M (shape), E (gain) | **HOLD — needs new probe** | Precompute one `loose` list per think tick; each officer filters it, excluding units already claimed. Preserve officer iteration order and first-claim semantics. | **MEDIUM** — claim order determines squad membership, which is serialized. Requires byte-identical dump gate. Not measurable with `t_perf_scale` (AI off). |
| 8 | Per-event allocations in combat: `prot.duplicate()` + `tmp` dict per hit, splash `u.prot.duplicate()` per victim, `_wall_between` `grid_query` over a long radius per shot, `_tick_projectiles` rebuilds `keep` array. | `_apply_hit` :4869-4931 (`prot.duplicate` :4889, `tmp` :4900, splash :4917-4927); `_wall_between` :4773-4786; `_tick_projectiles` :4943-4968 | M: O(hits) dict/array allocs; E: grows with combat intensity, not unit count alone | M (shape), E (gain) | **LOWER PRIORITY** | In-place compaction for `projectiles`; avoid `prot` duplicate when `pb==0 and fb==0`; cached `grid_query_into` for `_wall_between`. | **LOW** for projectile compaction (order preserved); **MEDIUM** for hit path (RNG draw order in `_fire` must not shift). |
| 9 | Two-pass corpse/rubble ageing: increment all, then reverse-scan all for expiry. Bounded at 600 corpses / rubble cap. | `tick()` :3853-3862 | M: 4 bounded passes/tick; E: negligible at cap 600 | M (shape), E (gain) | **NO_WIN (de minimis)** | Combine into one reverse pass. | **NONE** — but gain is below noise; do not book as a win. |
| 10 | `say()` → `message.emit()`; famine messages are rate-limited; deaths/captures/wins are event-driven. `events` array capped at 256. `serialize()` is not on the tick path. | `say` :2800-2801; famine :4043-4046; `_kill` :4082-4083; `post_event` :2796-2798; main consumer `main.gd:1242-1292`; `serialize` :5418-5453 | M: not per-unit-per-tick; E: no scaling opportunity | M (shape) | **NO_WIN** | None. Do not re-propose. | n/a |

## Top-5 ranked actionable opportunities

All five are **ESTIMATE-ranked** (gain × safety); none has a measured before/after
number from this worker.

### Rank 1 — int-key + in-place spatial hash (`game.gd:213-249`)

- **Minimal change:** replace `var c := Vector2i(...)` at :223 with an int key;
  keep bucket arrays and clear them in place instead of `grid.clear()` at :214;
  give `grid_query` a shared empty-array default. Keep `(cy, cx)` iteration and
  append order byte-for-byte.
- **Acceptance criterion:** `t_sim_hotspots` 7/7 PASS, `t_mass_army` PASS
  (0 overlaps), seed dump byte-identical to baseline; `move_ms` does not regress
  in 3 of 3 reps.
- **Measure before/after:** `t_perf_scale.gd` with `C3_PERF_MOVE=1 C3_PERF_SQUAD=0`,
  NS=[300,1000,3000], same `Data.RANDOM_SEED`, median of 3. Existing probe already
  exercises this path (`g.tick()` at :70).

### Rank 2 — allocation-free `grid_query` results (`game.gd:240-249`, call sites)

- **Minimal change:** add `grid_query_into(pos, r, out)`, caller-owned buffers at
  :2734, :2770, :4748, :5049; remove the per-call `out=[]` and per-empty-cell `[]`.
- **Acceptance criterion:** enemy target ids identical across a fixed seed dump;
  no nested-call aliasing (static scan of the 11 sites); `move_ms` not regressed.
- **Measure before/after:** same `t_perf_scale` protocol as Rank 1 **plus** a new
  gather/combat probe (current probe has no gather orders or sustained combat, so
  :5049 / :4917 churn is invisible there).

### Rank 3 — stumps/fields lists instead of 3× `res_nodes` scans (`game.gd:3863-3872`, `:2249-2269`)

- **Minimal change:** add `stumps`/`fields` arrays; append at stump creation
  (:5088-5090) and field creation, remove in the existing reverse loop;
  maintain in `_compact` and `deserialize`. Leave `res_nodes` order untouched.
- **Acceptance criterion:** identical number of `res_dirty` increments, identical
  stump-clear set and field-growth values in a fixed-step dump; seed dump
  byte-identical.
- **Measure before/after:** same `t_perf_scale` protocol; to isolate from unit
  cost, add an env toggle that runs ticks with `entities=[]` over the generated
  map (new probe extension needed).

### Rank 4 — hoist `_kind_class(a)` out of target scoring (`game.gd:2761-2782`, `ai.gd:520`)

- **Minimal change:** precompute `ac` and `row` once per `enemies_preferred` call;
  call `_kind_class(m)` once in `ai.gd:520`.
- **Acceptance criterion:** identical `acq_target` ids and `cls` counts in a fixed
  seed dump; `t_sim_hotspots` 7/7 PASS.
- **Measure before/after:** `t_perf_scale` move_ms (idle armed units call
  `enemies_preferred` every tick at dt=0.25) — likely the cleanest measurable of
  the five. AI half needs a new AI-enabled probe.

### Rank 5 — no building-array rebuilds on the tick path (`game.gd:2592-2606`, `:5348-5381`, `:2172-2186`)

- **Minimal change:** direct `live_blds` scan in `nearest_drop`; direct
  `live_units`/`live_blds` emptiness checks in `_check_victory`; `mills` cache
  keyed on `bld_dirty` for `_field_mill_id`.
- **Acceptance criterion:** identical nearest store id and capture/victory timing
  in fixed-step dump; seed dump byte-identical.
- **Measure before/after:** same `t_perf_scale` protocol (victory check is in
  every tick); delivery-heavy benefit needs a new gather probe.

## Measurement protocol (for whoever implements)

- Runner (from `app/tests/t_perf_scale.gd:11-13`):
  `python app\tools\godot_runner.py run --id p1-perf-<slug> --timeout 100 -- --headless --path app --script res://tests/t_perf_scale.gd`
- Keep identical: seed (`Data.RANDOM_SEED`), NS=[300,1000,3000], TICKS=5, REPS=3,
  runner command, machine load. Record `move_ms`, `units`, and the JSON path.
- Shared runner: take two after-runs and discard any outlier taken under heavy
  load (precedent: PERFORMANCE_SWARM V13 excluded one after-run).
- Do **not** compare these numbers to the 196 ms/tick @ 618-unit sim-only baseline
  or the old linear ESTIMATES (PERFORMANCE_SWARM §4 datasets are separate).
- Determinism gate for every change: seed dump byte-identity + `t_sim_hotspots`
  7/7 + `t_mass_army` PASS. Rank 3/5 additionally need the mill/memory-cache
  rebuild order checked on `deserialize`.

## Open questions

1. Does `grid` need int keys at all, or is the bucket-array reallocation the larger
   fraction? A two-step A/B (int keys only, then in-place clear) would separate
   them — this worker cannot measure it.
2. Are `grid_query` calls ever nested (directly or via `_fire` → `_apply_hit` →
   splash)? If yes, a global scratch buffer is unsafe; caller-owned buffers are
   the only safe form. A full call-graph read is needed before implementation.
3. How many `food` nodes with `mill` exist in a typical AI game? If it is <20,
   Rank 3's field half is de minimis and only the stump half is worth doing.
4. Does `acq_now` fire every tick in real play (dt≈1/60) or only every 4-8 ticks?
   The dt=0.25 probe overstates acquisition cost; a real-dt probe is needed to
   rank Ranks 2 and 4 honestly.
5. How many officers does the AI actually field in a 3000-unit soak? If O is
   small (<5), claim 7 is O(M), not O(O·M), and drops out of the ranking.
6. Is `serialize()` ever called on a timer (not just on save)? This worker found
   no per-tick caller in `game.gd`/`main.gd`; if a caller exists elsewhere, the
   deep `_vec_enc` recursion (:5383-5396) would need its own lane.
