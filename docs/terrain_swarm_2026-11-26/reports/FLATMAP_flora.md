# FLATMAP — flora (forests / stones / decor) trace for `mapoverview_20261127`

Scope: deterministic capture `mapoverview_20261127` (seed 20261113, land map,
donor-backend) shows a flat green plane with a settlement and a few field patches
but NO forests, trees, stones or decorative props. Prior logic audits said
generation stages run (`_gen_forests`, `_gen_resources`) and stamp/relief law
matches, yet visually nothing appears. This report traces forest/stone placement
read-only WITHOUT executing code/Godot/donor, WITHOUT edits except this file.
Parity: UNVERIFIED. No approximations, no parity claim, no fabricated props,
no invented densities. Chain: 0/6. RESULT IS NOT GOOD.

## 1. Byte-proven: the rendered path never realises pattern forest/stone stamps

The interactive/render load path is `main.gd::_do_async_load`
(`variant3d/scripts/main.gd:584`), whose staged sim sequence is
(`main.gd:614-632`):

- `game.setup_begin(start_mode)` (`main.gd:614`)
- `game._gen_base()` (`main.gd:617`)
- `game._gen_forests()` (`main.gd:620`)
- `game._gen_resources()` (`main.gd:623`)
- `game._gen_finish()` (`main.gd:626`)
- `_assign_tileblocks`, `setup_spawns`, camera bind (`main.gd:629-652`)

`_gen_patterns()` is ABSENT from that list. The only full path that calls it is
`game.gd::setup()` (`variant3d/scripts/game.gd:550-559`: `_gen_base`,
`_gen_patterns`, `_gen_forests`, `_gen_resources`, `_gen_finish`), which is used
by the headless CLI/dump paths (`main.gd:799`, `:809`, `:871` — `_setup_cli_only`,
`_dump_map`, `_dump_self_base`), NOT by the rendered loader above.

`setup_begin` resets `pattern_stamps = []` (`game.gd:651`). `_gen_base` DOES build
the `_pattern_build` cache (`game.gd:1782`, `C3PatternGen.build(...)`) and relief
(`_shape_stamp_relief`, `game.gd:1784`), but the ONLY function that turns forest /
stone / mine / decor pattern stamps into sim nodes is `_gen_patterns`
(`game.gd:1277-1453`):

- forest stamps: terrain paint + up to 14 `wood` nodes per stamp at fill 0.30
  (`game.gd:1363-1381`);
- stone stamps: 4–7 `stone` nodes per stamped footprint (`game.gd:1404-1413`);
- mine stamps: `_add_res(str(st.res), ...)` (`game.gd:1446`);
- decor stamps: 10% bush nodes (`game.gd:1399-1402`).

None of that runs in the `_do_async_load` path. What DOES run:

- `_gen_forests` (`game.gd:1870-1887`): ONLY the two sacred groves per start
  (`_paint_terrain` + `_scatter_forest` 34 + 23 nodes). No pattern forests.
- `_gen_resources` (`game.gd:1889-1903`): richness ore scaling
  (`_apply_richness_ores`) + near-start ore net (`_ensure_start_ore_clusters`).
  Creates NO wood/stone nodes (low-richness path only retires ore nodes,
  `game.gd:1933-1950`).
- `_gen_finish` (`game.gd:2087-2132`): two more sacred groves per start
  (`game.gd:2104-2107`), then a 4-tile start clear (`game.gd:2112-2113`) that the
  offset groves survive.

So in the rendered capture path, the whole `pattern_gen.gd` rest stage — 9
forest recipes (`pattern_gen.gd:456-466`), `stones`/`stoneforests`/`decor`/`dcr1`
(`pattern_gen.gd:483-490`), mine stamps — NEVER becomes `res_nodes`. The sim
carries at most ~114 sacred-grove `wood` nodes (57/start × 2 starts) plus ore.
That is the primary byte-proven cause of "no forests anywhere": the forest
content was never generated into the sim on this path, not merely hidden.

[U]: (a) the actual `res_nodes` list / `map_meta.stamp_counts` for seed 20261113
(no `--dump-map` output was read here); (b) whether the capture run took
`_do_async_load` vs `setup()` — the manifest says windowed real-viewport frames
(`capture_semantics: windowed seq = real viewport frames`, `headless: false`,
1280x720), which is the rendered loader, but the engine stdout log was not read.

## 2. Sim-to-render path (`world3d_entities.gd`): what exists WOULD render

- `world3d.gd::_reconcile_entities` feeds `game.res_nodes` into
  `entities.add_resource(n)` (`world3d.gd:352-433`, feed at `:415-429`); already
  depleted finite nodes are skipped (`world3d.gd:420-424`, mirroring 2D).
- `_resource_sid` maps `wood` → `POOL_TREE` (19 sids), `stone` → `POOL_ROCK`,
  plus `POOL_BUSH`/`POOL_STUMP` (`world3d_entities.gd:4040-4062`).
- `_mesh_info` falls back to a bbox proxy when art is missing
  (`world3d_entities.gd:2077-2078`); nodes are never silently dropped. A missing
  mesh is a labelled proxy, not an invisible skip.
- `_is_hidden` keeps `hits > 0` wood visible and permanent ore visible
  (`world3d_entities.gd:3003-3012`); sacred-grove wood is created with hits=60
  (`game.gd:1213`), so it passes this gate.

Conclusion: any `wood`/`stone` node present in the sim WOULD appear (mesh or
proxy). The empty frame therefore points at absence in the sim (§1), not at a
render cull — for the nodes that do exist.

[U]: (a) the per-seed node list; (b) whether each `POOL_TREE`/`POOL_ROCK` OBJ+tex
exists on disk at capture time (preflight telemetry exists at
`world3d_entities.gd:905-910` but no capture log was read); (c) proxy vs real
mesh appearance.

## 3. Donor prop layer: not wired, and doubly shape-incompatible

- The I09 prop instancer `terrain_donor_props.gd` exposes `build(container,
  stamps, options)` (`terrain_donor_props.gd:273-279`). No caller of that entry
  exists in shipped runtime code: `world3d.gd` binds the `relief` slot to
  `world3d_relief.gd` (`world3d.gd:119`, `:632`, `:668-669`), and the only
  reference to the I09 script path is the donor-backend composer
  `terrain_donor_world.gd:34`. The repo-internal grep surface shows the I09 file
  named only in tests, tooling, and its own header — i.e. the forest/stone donor
  prop layer never runs in the captured path.
- Even if called, `_collect_stamp` accepts ONLY `Dictionary` stamps and counts
  anything else as `skipped_non_dictionary_stamp`
  (`terrain_donor_props.gd:943-948`; same gate in `_accepted_stamp_names`,
  `:696-710`), while `game.pattern_stamps` are `C3PatternGen.Stamp` OBJECTS
  (`game.gd:9076` comment). Every stamp would be skipped.
- The module that IS bound, `world3d_relief.gd`, rebuilds inside `bind()`
  (`world3d_relief.gd:86-92`) but instances ONLY `RELIEF_SIDS` terrainmesh
  records (`world3d_relief.gd:166-171`); forest/stone records can never pass it.
  It reads `game.pattern_stamps`, which is `[]` on the staged path (§1), so
  `stamp_count = 0`, `matched_stamps = 0` — consistent with a flat, propless
  frame.

## 4. `BASE_UNRESOLVED` skip path (real, but NOT the capture's cause)

`_normalize_record` (`terrain_donor_props.gd:998-1039`) skips, in order:
unknown sid → `skipped_unknown_sid` (`:1021-1030`); sid without converted OBJ →
`skipped_missing_mesh` (`:1031-1039`); unclassifiable stamp+base → `UNKNOWN_CLASS`
(`:1041-1046`). Unmapped understory bases fall through to
`BASE_UNRESOLVED ... — no converted sid; skipped (no mesh fabricated)`
(`terrain_donor_props.gd:1366`), and forest-stem misses to `TREE_SID_UNRESOLVED`
(`:1333`). Since §3 shows the whole module never runs in the captured path, this
skip path is a real code behaviour but cannot explain `mapoverview_20261127`.

## 5. Decoded pattern records: grids present, prop names absent

- 710 decoded files under `variant3d/assets/terrain_new/patterns/` per
  `pattern_decode_manifest.json:13` (`output_count: 710`).
- Spot-read `b_frt_b_p_1.json`: `object_records[]` carry ONLY numeric
  `id`/`u`/`v`/`f4`/`tail4` (`b_frt_b_p_1.json:80-149`); the file's own labels
  say `object_records ... id/tail4 semantics [U] — no prop-name mapping`
  (`:69`). There are NO forest/stone prop-name sections in the decoded terrain
  JSONs; prop names live exclusively in the separate I03 feed
  `variant3d/assets/terrain_new/props/props_index.json:1` (schema
  `terrain_new/props_preindex/v1`, `record_count: 39783`, 235 basenames,
  77 families, 668 sections).
- So "pattern JSONs empty of forest/stone sections" is EXPECTED BY CONSTRUCTION,
  not a data loss: the terrain JSONs were never the prop-name source.

[U]: whether this seed's stamps matched feed records (no run
`family_placements`/`stamp_candidates` telemetry was read here).

## 6. Camera-region hypothesis: secondary at most

- First-camera targets the local start: `consume_start_camera_target`
  (`game.gd:686-694`) exposes `map_starts[0]`; `main.gd:657-659` binds the camera
  and reads `game.buildings_of(0)`.
- Sacred groves sit 7–12 tiles from starts (`game.gd:1880-1887`, `:2104-2107`),
  inside any settlement-framed overview and therefore probably in frame — but at
  map-overview zoom single-tree nodes may be subpixel.

[U]: frame-localisation of groves (no pixel analysis of
`01_donor/frame_0000.png` done here); whether the overview zoom resolves single
trees. This can only explain missing GROVES, never the missing pattern forests,
which §1 shows were never generated.

## Verdict

Byte-proven: on the rendered `_do_async_load` path the pattern forest/stone/
mine/decor realisation (`_gen_patterns`) is skipped, so the sim holds only
sacred-grove wood + ore; the donor prop layer that could add visual
forest/stone is unwired (and shape-incompatible with `Stamp` objects); the
bound relief module accepts terrainmesh records only against an empty stamp
list. The `BASE_UNRESOLVED` skip is real code but inert here; decoded terrain
JSONs correctly carry grids, not prop names. Everything seed-specific for
20261113 (node list, stamp counts, mesh availability, in-frame pixels) stays
[U] — no runtime log or dump was read. No parity claim. RESULT IS NOT GOOD.
