---
owner: I3
date: 2026-11-24
file: app/scripts/world.gd
backup: inbox/backup/world.gd.bak-I3-RENDERPOL
task: safe/low-visual-risk subset of recon P2 (items 2, 4a, 4b, 6, 7/9)
---

# I3 — world.gd render hotpath micro-opts

## Backup

`inbox/backup/world.gd.bak-I3-RENDERPOL` (167047 bytes) taken before any edit.

## Items implemented

### P2 #2 — `pending_unit_sprites` reusable pool (world.gd:95-96, 595, 3143-3165, 3169)

- Added `var _pending_unit_sprites_count := 0` beside `pending_unit_sprites` (95-96).
- `_draw_anim` (595) and `_queue_unit_sprite` (3083-3086) now call a new
  `_push_unit_sprite(tex, dst, src, tint)` (3143-3157) instead of
  `pending_unit_sprites.append({...})`.
- `_push_unit_sprite` overwrites the fields of the next preallocated dict slot
  (`d["tex"]/["dst"]/["src"]/["tint"]`), appending only on pool growth, then
  increments the live count. `_draw_unit_sprites` (3159-3165) iterates
  `range(_pending_unit_sprites_count)` and issues the identical
  `draw_texture_rect_region(d.tex, d.dst, d.src, d.tint)` call per entry.
- `_draw_units` (3169) resets the count to 0 instead of `pending_unit_sprites.clear()`.
- Draw order / args: unchanged — slots are filled in the same call order as the
  former `append`s, so iteration order and the exact dict contents passed to
  `_draw_unit_sprites` are identical. No per-frame `Dictionary` allocation on
  steady state (pool reused across redraws).

### P2 #4a — hoist `bspr` + memoize `_bld_key` (world.gd:598-618, 2826-2834)

- `_bld_key` (603-618) now memoizes by `"<SPRITE_CELL>|<player>|<sid>"` in
  `_bld_key_cache` (602). Including `Data.SPRITE_CELL` makes a runtime quality
  change (which clears `anim_tex` in main.gd:1058 and changes `_anim_dir`)
  resolve to a fresh key, so no stale nation answer can survive a quality swap.
- `_draw_buildings` resolves `var bspr := _bld_tex(e)` once per visible building
  (2829) and branches on `elif bspr != null` (2834); the second `_bld_tex(e)`
  call at the old 2811 is gone. `_bld_scale(_bld_key(e))` (2849) now hits the
  memoized key.
- Draw order / args: unchanged — the existence test and the sprite used for
  drawing are the same resolved texture; only duplicate resolution was removed.
  Mine/wall branches are unaffected (the hoisted call happens before them, but
  it is side-effect free apart from lazy texture caching that already occurred
  in the former existence test).

### P2 #4b — cache known-missing death sheets (world.gd:160, 3343-3351)

- Added `var death_sheet_missing: Dictionary = {}` (160), keyed by resolved
  path (so a quality change / new `_anim_dir` yields a fresh key).
- `_draw_corpses` (3343-3351) computes `dpath := _anim_sheet(ckey, "death")`
  once and skips `_res_exists` when the path is already known missing; a first
  miss records `death_sheet_missing[dpath] = true`.
- Draw order / args: unchanged — same `anim_tex[dtk]` population and same
  fallback art (`_sprite_for` / procedural circle) when the sheet is absent.
  Only repeated `ResourceLoader.exists` probes were eliminated.

### P2 #6 — hoist cull rect + `ty` in `_draw_resources` (world.gd:2674-2706)

- Added one `var cull := view_rect.grow(64)` before the `game.res_nodes` loop
  (2676) and replaced the per-node `view_rect.grow(64).has_point(p)` with
  `cull.has_point(p)` (2689).
- Computed `var ty := str(n.get("type", ""))` once per node (2678) and reused it
  in the depleted-node condition (2683-2684) and the `stump` / `bush` checks
  (2692, 2706).
- Draw order / args: unchanged — iteration remains `for n in game.res_nodes`;
  no switch to `_res_grid`. The `match n.type` branch (2719+) is untouched.
  Culling geometry is bit-identical (`view_rect` is constant across the redraw).

### P2 #7 / #9 — guard `fx_items` filter (world.gd:2099-2102)

- Wrapped `fx_items = fx_items.filter(...)` in `if not fx_items.is_empty():`.
  The preceding `for f in fx_items: f.t += dt` loop is untouched (empty loop is
  a no-op anyway).
- Semantics: for a non-empty list the filter runs exactly as before; for an
  empty list the result would be a new empty array, which is observationally
  identical to keeping the old empty array. Draw/visual impact: none.

## Runner test

Command (via `app/tools/godot_runner.py`, never direct godot):

```
python app\tools\godot_runner.py run --id i3-render-micro --timeout 180 -- --headless --path app --script res://tests/t_mass_army.gd
```

- Job id: `i3-render-micro` (runner ticket 1237).
- Runner result: `END ok` (run 23.05 s; 85.84 s queue wait).
- `app/tests/results/t_mass_army.json`: `passed: true`, 6/6 checks —
  `mass_spawn_distinct`, `squads_formed`, `sim_advances`,
  `no_unit_overlap`, `perf_metric_recorded`, `corpses_rubble_age_out`
  (552 units, 10.0 sim-seconds, 20832.75 ms wall).
- No full selftest run (per instructions; coordinator owns the final gate).

## Draw-order / visual-risk reasoning

All five edits are either duplicate-call elimination or caching of values that
were already deterministic for the same inputs. No draw call was added, removed,
reordered, or given different arguments. Unit sprites are pushed in the same
sequence and drawn in the same sequence; building sprites resolve to the same
texture; corpse fallback art is identical; resource iteration order and cull
geometry are unchanged; the fx filter short-circuit is a no-op when empty.
Net visual risk: zero intended change (pure hotpath/allocation reduction).

## Determinism note

- Pool order is call order, identical to the former append order; dict fields
  are overwritten wholesale each push, so stale values cannot leak (all four
  fields are always set before the slot becomes live).
- `_bld_key_cache` and `death_sheet_missing` only memorize `ResourceLoader`
  existence results; they contain no RNG/time state. Keys include
  `Data.SPRITE_CELL` / resolved path so a quality change cannot pin stale art.
- `ty` and `cull` are pure functions of node/view state that is constant across
  a redraw. No new randomness or frame-dependent state introduced.

## Open questions

- `_bld_key_cache` is never explicitly cleared anywhere; correctness across a
  quality change relies on `Data.SPRITE_CELL` being part of the key. If a future
  change makes `_anim_dir` depend on something other than `SPRITE_CELL`, the key
  should be extended (or the cache cleared where `anim_tex` is cleared).
- `death_sheet_missing` similarly grows unboundedly but is bounded by the number
  of distinct sheet paths and is keyed by path, so it is safe across quality
  changes; no clear hook added (mirrors existing `hull_tex_cache`/`decal_tex`
  behaviour).
- `t_mass_army.gd` exercises sim/corpse paths but may not stress every building
  nation-sheet or every resource branch; visual equivalence was established by
  structural code reasoning rather than a pixel diff.
