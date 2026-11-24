---
owner: PERF-3D
wave: perf
date: 2026-11-24
scope: AUDIT ONLY — no source/config/test/asset edits, no git operations
output: docs/coord_swarm_2026-11-24/reports/PERF3D_sync_hotpath.md
method: MEASUREMENT (temporary headless probe, variant3d's own runner) + source reads
---

# PERF-3D — where the 12–20 ms `sync_ms` actually goes

## 0. Question and answer

`main.gd:1592` prints `sync_ms` accumulated from `world.sync(dt)` at
`variant3d/scripts/main.gd:1620-1622`. The 12.65–20.06 ms reported in the
windowed run is **almost entirely per-unit donor skin sampling**, not mesh
rebuild, fog, FX or camera work.

Measured on a live `C3Game` with real skinned units (headless debug, 320×320
map, shipped donor skins auto-registered):

| Rank | Stage | path:line | Measured ms/frame | Share of `world.sync` | Status |
|---|---|---|---|---|---|
| 1 | `world3d_entities.sync()` Pass 1 → `anim3d.pose_for()` → `_morph_fields()` → `skin_vertices()` | `world3d_entities.gd:955-1000`, `anim3d.gd:489-530`, `:534-556`, `:410-459` | **115.4–160.1 @ 200 units** (0.58–0.80 ms/unit) | **89–98 %** | MEASURED |
| 2 | `_reconcile_entities()` full scan of `game.entities` + `game.res_nodes` | `world3d.gd:305-355`, called `:554` | 0.42 @ 200 units; **3.92 @ 200 units + 1200 res nodes** (~0.0029 ms/node) | 1–3 % (up to ~25 % on a populated map with few units) | MEASURED |
| 3 | `world3d_entities.sync()` Pass 2 transform recompute + `MultiMesh.set_instance_transform()` | `world3d_entities.gd:1004-1017`, `_xf()` `:798-813` | 2.07–3.03 @ 200 units (0.010–0.015 ms/unit) | ~1.5 % | MEASURED |
| 4 | `_morph_mesh()` lookup/rebuild (cache warm) | `world3d_entities.gd:569-658`, called `:979` | 1.13–1.75 @ 200 units (0.006–0.009 ms/unit) | ~1 % | MEASURED |
| 5 | `_sync_rally()` full `game.entities` scan | `world3d.gd:447-465`, called `:553` | 0.34–0.45 @ 200 units | <1 % | MEASURED |
| 6 | `fog_vis != _fog_rev_vis` 102 400-byte compare | `world3d.gd:563-565` | 0.012–0.015 | ~0.01 % | MEASURED |
| 7 | `_sync_selection()` / `fx.sync()` / `fog.sync()` / `_update_view_rect()` | `world3d.gd:273-295`, `:550-551`, `:558-560`; `world3d_fx.gd:261-270`; `world3d_fog.gd:116-125` | 0.02–0.08 / 0.017–0.020 / 0.003 / 0.011–0.018 | negligible | MEASURED |

**Ranked suspects from the brief:** the per-unit donor morph **mesh rebuild** is
*not* the recurring cost (it is key-cached at `world3d_entities.gd:571-573`,
60 cached meshes at 200 units, 0 frame changes in steady state). The real cost
is one **fresh skinned vertex buffer computed per unit per frame**
(`anim3d.gd:410-459`), even when hundreds of units share the same
`(sid, action, frame)`.

## 1. Method

- Probe: temporary `variant3d/tests/t_perf3d_sync_probe_tmp.gd` (SceneTree),
  run only through
  `python variant3d\tools\godot_runner.py run --id perf3d-sync-probe... --timeout <s> -- --headless --path variant3d --script res://tests/t_perf3d_sync_probe_tmp.gd`.
- Real `C3Game` (`setup_begin("skirmish")`, 320×320 from `config.json:39-40`
  via `config.gd:405`), `C3Config.apply()`, 6 real skinned sids
  (`peasant`, `pikeman`, `archer`, `cossack`, `musketeer`, `grenadier`), 1/3
  flagged `moving`. `world3d.gd` instantiated via `make_world3d()`-equivalent
  `load()` + `bind(game)` so all five composed modules, anim skin auto-load
  (`anim3d.gd:742-765`), donor OBJ topology parse and MultiMesh batches are live.
- 40 warm-up frames, then 120 timed frames. Every `world.sync()` sub-step was
  timed separately with `Time.get_ticks_usec()`, then a full `world.sync(dt)`
  was timed for cross-check. A second pass broke `entities.sync()` into pose
  sampling, cached morph lookup, transform writes and stats.
- A third phase appended 1200 real `res_nodes` via `game._add_res()` to model
  a generated forest (staged map generation is not completed by `setup_begin`).
- Three jobs: runner tickets 187, 190, 192 (all `ok`). Results are in the
  runner spool stdout for those tickets. **The probe script and its JSON were
  deleted after measurement** (see §6).

### Caveats / honesty

- Headless Godot 4.7.2 uses the dummy `RenderingServer`, so `set_instance_transform`
  CPU time is measured but GPU upload is not; windowed `sync_ms` can be higher.
- Three runs varied ~±20 % (machine load); figures are per-frame averages
  over 120 frames, not medians of 3 reps. Ratios between stages were stable.
- The exact unit count in the user's windowed run is **UNVERIFIED**. Dividing
  12–20 ms by the measured 0.58–0.80 ms/skinned-unit gives ~15–34 units; a
  populated map adds ~3–4 ms of reconcile. That is consistent with an early
  skirmish, but the windowed snapshot itself was not available.
- `FOG_OF_WAR` defaults false (`data.gd:55`; `config.gd:380`), so fog's
  per-tile full-map scan (`world3d_fog.gd:231-318`, ArrayMesh rebuild at
  `world3d_fog.gd:218-228`) did **not** fire. If the menu toggles fog on
  (`main.gd:1512`), expect a periodic spike every `FOG_INTERVAL` = 0.5 s
  (`data.gd:122`), not a steady 12–20 ms. UNMEASURED in that configuration.

## 2. Why rank 1 is so expensive (code shape)

`world3d_entities.sync()` Pass 1 (`world3d_entities.gd:955-1000`) loops
`_slot.keys()` — every registered unit and resource. For each unit:

1. `anim.has_skin(sid)` (`anim3d.gd:313-316`) — shipped skins are
   auto-registered at bind, so this is true for all six probe sids.
2. `anim.pose_for(e, action, _anim_t)` (`world3d_entities.gd:972`) →
   `anim3d.gd:489-530` → `_morph_fields()` `:534-556` →
   `skin_vertices()` `:410-459`.
3. `skin_vertices()` allocates two arrays of `bones` length (`:423-426`),
   then for **every donor vertex** (`:445-458`, 531–1014 vertices per sid per
   `assets/models/skin/index.json`) loops its bone weights and computes a
   weighted rotated/translated Vector3, writing a **new `PackedVector3Array`**
   (`:443-444`). With 16–42 bones and ~600–900 verts this is ~0.6–0.8 ms in
   GDScript per unit.
4. The result is only used as a cache key / mesh source: `_morph_mesh()`
   (`world3d_entities.gd:569-658`) returns an already-built `ArrayMesh` for
   `sid|action|f<frame>` on all but first visit (`:571-573`). Thus repeated
   identical skinning work is discarded every frame.

The whole pass is O(N_units × V_donor × W_bones) per frame. Pass 2
(`:1004-1017`) is only O(N_slots) and costs ~0.01 ms/unit.

## 3. Secondary costs worth noting

- **`_reconcile_entities()`** (`world3d.gd:305-355`) walks `game.entities`
  and `game.res_nodes` every frame with 2–3 `_int_prop`/`_prop` calls per item,
  then walks both `_feed_*` key sets. Measured 0.42 ms at 200 units but
  **3.92 ms at 1200 res nodes** — a real cost on a generated map, still far
  below rank 1.
- **`_sync_rally()`** (`world3d.gd:447-465`) independently walks all
  `game.entities` every frame looking for selected player-0 buildings with a
  `rally` field: 0.34–0.45 ms at 200 units.
- **Fog revision** (`world3d.gd:563-565`) compares two 102 400-byte
  `PackedByteArray`s every frame (0.012–0.015 ms) and duplicates one only on
  change. Cheap; already change-gated.
- **`world3d_fx.sync()`** (`world3d_fx.gd:261-270`) is 0.017–0.020 ms in
  steady state: `consume_events = false` (`world3d.gd:512`), no projectiles,
  empty `fx_items`/rally markers. NOT the bottleneck.
- **Camera/`view_rect`** (`world3d.gd:223-269` → `camera3d.gd:270-277`) is
  0.011–0.018 ms. NOT the bottleneck.

## 4. Smallest safe fix ideas (NOT implemented here)

All ideas keep donor-sampled flat-root verts and the 2D-derived batch/slot
semantics unchanged; none changes donor art, RNG or frame selection.

1. **Highest value, smallest edit: memoize the pose per
   `(sid, action, frame)` inside `world3d_entities.sync()` Pass 1.**
   All units sampled in one `sync()` share the same `_anim_t`, so `pose_for()`
   returns identical verts for every unit with the same sid and action. Build
   one `Dictionary` keyed by `sid + "|" + action + "|" + str(frame)` and reuse
   the whole pose Dictionary (including `verts` and the `_morph_mesh` result)
   for later units of that key. Expected: ~6–12 `pose_for()` calls/frame
   instead of N; ~90 % of `sync_ms` removed with byte-identical verts and
   identical batch keys. No change to `anim3d.gd` or to per-unit transform
   writes. Bound: at most 55 sids × visited frames per frame.
2. **Alternative / complementary: cache `skin_vertices()` by
   `(sid, frame, ref_frame)` in `anim3d.gd`.** The function is pure apart from
   `last_error`; cache the returned `PackedVector3Array`. Invalidate on
   `register_skin()`/`unregister_skin()`/shipped-skin load
   (`anim3d.gd:296-320`, `:771-887`). Bounded by visited frames per sid; worst
   case ~2300 buffers × ~700 verts ≈ 20 MB. Same numbers out.
3. **Gate the resource half of `_reconcile_entities()` on the existing
   `game.res_dirty` counter** (`game.gd:520`, comment `:105`) plus
   `res_nodes.size()`, with a forced rescan every ~30 frames to still catch
   in-place `hits` exhaustion if `res_dirty` is not incremented there. Saves
   ~3–4 ms on a generated map. Entity half can stay per-frame (0.4 ms at 200).
4. **Skip redundant Pass 2 writes** when a slot's transform is unchanged
   (cache last `Transform3D` per slot and only call
   `mm.set_instance_transform()` on change). Saves ~2–3 ms at 200 units;
   requires checking that sim movement/dirty flags cover every transform input
   (`pos`, `face`, hidden/dead).
5. **Do NOT touch** fog, FX or camera for this report: measured ≤0.02 ms each
   in the reported configuration.

Acceptance for any fix: `t_entities3d`, `t_v766`/morph tests and a fixed-seed
3D screenshot A/B must stay identical; `stats["donor_morph_*"]` telemetry must
report the same morph unit/frame counts.

## 5. Repro command

```
python variant3d\tools\godot_runner.py run --id perf3d-sync-probe --timeout 240 -- \
  --headless --path variant3d --script res://tests/t_perf3d_sync_probe_tmp.gd
```

## 6. Cleanup

Temporary probe `variant3d/tests/t_perf3d_sync_probe_tmp.gd` and its result
`variant3d/tests/results/per3d_sync_probe_tmp.json` were removed after the
measurements; no `.uid` was generated for the probe. No other file was
edited by this lane.

## Top 3 costs (answer to the brief)

1. **Per-unit donor skin sampling** — `world3d_entities.gd:955-1000` →
   `anim3d.gd:489-530/410-459`: **115–160 ms @ 200 units (0.58–0.80 ms/unit),
   ~90–98 % of `sync_ms`**; at ~15–34 units this is the 12–20 ms the windowed
   run reports (unit count UNVERIFIED).
2. **`_reconcile_entities()` full scan** — `world3d.gd:305-355`:
   **0.42 ms @ 200 units, 3.92 ms @ 200 units + 1200 res nodes** (~0.0029 ms/node).
3. **Pass 2 transform writes** — `world3d_entities.gd:1004-1017`:
   **2.07–3.03 ms @ 200 units (0.010–0.015 ms/unit)**; the morph mesh rebuild
   itself is cached and only 1.1–1.7 ms @ 200 units.
