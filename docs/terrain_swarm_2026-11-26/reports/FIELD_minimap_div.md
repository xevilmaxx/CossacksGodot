# FIELD_minimap_div — minimap vs 3D-viewport divergence (READ-ONLY)

Scope: read-only trace of both display paths for the same sim state.
Authority: byte citations below. Parity UNVERIFIED. No approximations used as
claims; every inference is labelled [U]. Chain 0/6. RESULT IS NOT GOOD.

Context: owner reports "minimap has changed, real map not much" after the
pattern-stage wiring. Prior FLATMAP_flora found the rendered path now calls
`_gen_patterns`. Headless capture is a CPU plot; windowed `--seq` is a real
viewport frame (see §5).

NOTE on file identity: the live 3D-variant HUD is
`variant3d/scripts/hud.gd` (class C3HUD, `extends CanvasLayer`). Comments in
`variant3d/scripts/hud3d_adapter.gd:9-13` cite `app/scripts/hud.gd:1394-1433`
as the 2D provenance of the box painter; the executed 3D path is the
variant3d copy (`_draw_minimap_viewport_box` at hud.gd:1924, `_mm_paint_box`
at hud.gd:1993).

---

## 1. Minimap path — what it reads, how it draws

### 1a. Terrain base: built ONCE at bind, static afterwards

- `hud.gd:1769-1804` (`_build_minimap`): `minimap_base = Image.create(game.MAP_W,
  game.MAP_H, ...)` (hud.gd:1785), then one pixel per cell from
  `game.terrain[i]` (hud.gd:1790): 1→(0.45,0.35,0.22), 2→(0.22,0.34,0.17),
  3→(0.16,0.34,0.55), 4→(0.72,0.64,0.42), 5→(0.45,0.44,0.4), default
  (0.29,0.42,0.2) (hud.gd:1789-1801). `minimap_img`/`minimap_view_img` are
  duplicates of it (hud.gd:1802-1803); `minimap_tex` wraps the view image
  (hud.gd:1804).
- `hud.gd:2358-2385` (`_update_minimap`): per tick it only DUPLICATES the
  base (`minimap_img = minimap_base.duplicate()`, hud.gd:2385; fog branch
  duplicates the cached fog-dimmed copy, hud.gd:2383). The fog dim cache
  rebuilds only when `world.fog_revision` moves (hud.gd:2368-2382); the dim
  factor ×0.25 is labelled PORT APPROXIMATION (hud.gd:2375-2381).
- CONSEQUENCE (byte-proven): post-bind writes to `game.terrain[]` NEVER reach
  the minimap base either. Both displays share "static terrain image" behaviour.

### 1b. Per-tick overlays: read `game.res_nodes` / `live_blds` / `live_units`

- Mine/quarry markers: rebuilt only when `game.res_dirty` moves
  (hud.gd:2388-2389). `_rebuild_mine_markers` (hud.gd:2019-2037) scans
  `game.res_nodes` (hud.gd:2026), keeps only types in `MINE_MARKER_COLORS`
  (gold/iron/coal/stone, hud.gd:295-300), skips exhausted finite nodes
  (hud.gd:2030-2031). `_draw_mine_markers` (hud.gd:2039-2067) stamps a 7x7
  Manhattan diamond (bright ore core d<=2, dark rim d==3, hud.gd:2067), gated
  on `fog_explored` (hud.gd:2049) with the 1.0/0.5 donor blend law
  (hud.gd:2053-2055, `_mm_resource_fow_blend` hud.gd:2105-2129).
- Wood/food nodes: EVERY tick, directly from `game.res_nodes` (hud.gd:2391),
  skipping ore/stone already handled (hud.gd:2392-2395): wood → 2x2 dark-green
  dot (hud.gd:2408-2409); food ripe/growing/depleted colours via
  `game.field_state(n)` (hud.gd:2410-2416, depleted-field stubble 2397-2406).
- Buildings: cache rebuilt when `game.bld_dirty` moves (hud.gd:2420-2421);
  `_rebuild_bld_blips` reads `game.live_blds` (hud.gd:2167), tile via
  `game.tile_of(e.pos)` (hud.gd:2170); drawn as pl3x3 cores (hud.gd:2181-2204).
- Units: rebuilt EVERY tick from `game.live_units` (hud.gd:2423-2424,
  `_rebuild_unit_blips` hud.gd:2206-2266), drawn as pl2x2 cores + rims
  (hud.gd:2310-2356).
- 3D viewport box: `hud.gd:1937-1964` — in 3D mode the box comes ONLY from
  `_hud3d_adapter.get_minimap_box()` (hud.gd:1960); the adapter maps the four
  `camera3d.get_viewport_corners()` ground corners through the centred-world
  formula u=(x+halfW)/mapW (hud3d_adapter.gd:119-153, box AABB 89-110).
  Painter `_mm_paint_box` (hud.gd:1993-2003) strokes/restores the AABB border.

MINIMAP SUMMARY: the only sim state a pattern change can move on the minimap
without a rebuild is `game.res_nodes` (markers + wood/food dots), `live_blds`
and `live_units`. `terrain[]`/`tileblock`/`pattern_stamps`/`blocked` are NOT
read by any minimap routine.

---

## 2. 3D world path — what it reads, how it draws

Composition root `variant3d/scripts/world3d.gd` (V7-51 header map, :15-52).

### 2a. Terrain mesh: built ONCE at bind, never in sync()

- `world3d.gd:662-666` (`bind`): `terrain.bind(game)`, then `terrain.build()`
  "ONE full-grid mesh; no chunk scheduling" — guarded only by
  `_has_height_source` (world3d.gd:249-256).
- `world3d.gd:722-740` (`sync`): derives view rect, mirrors selection, then
  delegates to `entities.sync` / `fx.sync` / `fog.sync` plus
  `_reconcile_entities`. NO `terrain.build()` / `invalidate()` call exists in
  `sync()`. `invalidate_forest_bake()` is a deliberate NO-OP in 3D
  (world3d.gd:836-838: "3D terrain is ONE mesh; there are no Sprite2D chunks").
- `world3d_terrain.gd:1220-1249` (`build`): `invalidate()` first (line 1222),
  decodes `height[]` (+ `tileblock` base64 via `_dump_from_game`,
  world3d_terrain.gd:926-963, `_decode_tile_indices` 969-999), emits one
  ArrayMesh, sets `_built = true` (world3d_terrain.gd:1469). UV2.x carries the
  donor tile index, UV2.y the face mode (world3d_terrain.gd:15-21).
- CONSEQUENCE (byte-proven): post-bind writes to `terrain[]`, `tileblock`,
  `height[]` or `blocked[]` NEVER reach the 3D viewport. A mesh rebuild
  requires a re-`bind` (which clears the entity-feed id sets, world3d.gd:653-659).

### 2b. What `_gen_patterns` (game.gd:1277-1453) writes

- Forest: paints a filled core disc `terrain[ii2] = 2` (game.gd:1344) AND adds
  up to 14 `wood` res nodes per stamp (`_add_res("wood", ...)`, game.gd:1370-1381).
- Stone: paints scar `terrain[ii] = 1` (dc<=3.2) / `= 5` (dc<=1.6)
  (game.gd:1386-1389), adds 4-7 `stone` nodes (game.gd:1406-1412), clears trees
  in 5.0*TILE (game.gd:1413).
- Mine (`"mine"`): ALWAYS realises the deposit (`_add_res(str(st.res), ...)`
  game.gd:1446, with nudge-to-open search 1422-1445), paints a dirt apron via
  `_paint_terrain(mp, 3.0*TILE, 1, 2.5, true)` (game.gd:1447), clears trees in
  6.0*TILE (game.gd:1448).
- Hill (`"hill"`): HEIGHT-ONLY. Explicit `pass` — "no terrain paint is needed",
  relief height already written by `_shape_stamp_relief()` in `_gen_base`
  (game.gd:1390-1398). No RNG drawn in this branch (game.gd:1396-1397).
- Tile (`"tile"`): `pass` — "donor tls_* are thin decals, not terrain recolour"
  (game.gd:1382-1383).
- Start keep-clear: forest disc cells within 7.0*TILE of any `map_starts`
  point are skipped (game.gd:1337-1343); `_clear_trees` (game.gd:1252-1262)
  zeroes `wood` hits near deposits/mines, sparing home groves unless
  `ignore_home`.
- Ordering: `_generate_map` = `_gen_base` → `_gen_patterns` → `_gen_forests`
  → `_gen_resources` → `_gen_finish` → `_assign_tileblocks` (game.gd:1455-1462).

### 2c. Relief props: static, bind-time, mountain-only

- `world3d.gd:667-671`: `relief.bind(game, terrain)` runs ONCE at bind,
  "STATIC — ... no per-frame work in sync()".
- `world3d_relief.gd:86-92` (`bind` → `rebuild`); `rebuild` reads
  `game.pattern_stamps` (world3d_relief.gd:120-129) and instantiates ONLY sids
  in `RELIEF_SIDS = terrainmesh1..4` (world3d_relief.gd:51, 166-171) from the
  `mountain_props.json` table. Header states read-only on all sim state, no
  RNG, no stamp writes (world3d_relief.gd:3-8). Placement/scale/yaw are all
  labelled PORT APPROX (world3d_relief.gd:21-34, 53-56).
- CONSEQUENCE: only mountain-family stamps produce 3D relief props, and only
  at bind. Forest/stone/mine/hill stamps produce NO prop here.

### 2d. Entities: res_nodes DO reach the 3D scene (with a gate)

- `world3d.gd:352-433` (`_reconcile_entities`, every `sync`): units/buildings
  from `game.entities` (world3d.gd:358-381, dead skipped per world.gd:2201/
  2230/2838); resources from `game.res_nodes` (world3d.gd:413-433) via
  `entities.add_resource(n)` (world3d.gd:427), with the 2D-exhaustion mirror
  (world3d.gd:422-424).
- Resource half is gated (V7-80, world3d.gd:403-412): skipped when
  `res_dirty` AND array size are unchanged (mirrors
  app/scripts/game.gd:2642-2661). `_add_res` bumps `res_dirty`
  (game.gd:1112-1124, `res_dirty += 1` at :1124), so pattern-stage node
  additions PASS the gate on the next sync. Fallback: gate bypassed for
  Dictionary/stub games (world3d.gd:400-402).
- `world3d_entities.gd:4065-4096` (`add_resource`): resolves a sid via
  `_resource_sid`, batches into a per-sid MultiMesh (`_acquire`, :4089-4094);
  unknown type → bbox proxy `"__proxy_" + ty` (:4078, "tagged in stats").
  Food gets a field decal (`_sync_field_decal`, :4096).
- Mine 3D disc: BLOCKED as separate terrain art — "no matching deposit-disc
  asset ... a separate terrain apron PNG is not present and none was invented"
  (world3d_entities.gd:220, MINE_DISC_STATUS); the disc is only the low-Z
  region of the mine albedo texture.

### 2e. Camera: starts on a deliberately cleared region

- Start target: `game.gd:680-694` (`map_starts[local]` as the player start);
  3D/2D cameras consume it via `consume_start_camera_target()` →
  `jump_to_world()` (camera.gd:179-193, applied per-frame at camera.gd:246).
- The viewed start region is BY CONSTRUCTION sparse: 7-tile forest keep-clear
  (game.gd:1337-1343), home-grove protection (game.gd:1252-1262), mine/quarry
  tree clearing (game.gd:1413, 1448).
- [U]: whether the `--seq` capture under test holds this start framing for all
  frames was NOT traced (main.gd --seq camera path out of scope for this
  worker). Recorded as unknown, not as a finding.

---

## 3. Determined divergence mechanisms (byte-proven first)

M1 (PROVEN — terrain paint is invisible on BOTH post-bind, mesh included).
`_gen_patterns` forest-sod discs (`terrain=2`, game.gd:1344), quarry scars
(`terrain=1/5`, game.gd:1386-1389) and mine dirt aprons (`_paint_terrain`,
game.gd:1447) post-bind change NEITHER display's terrain image: minimap base
is a bind-time snapshot (hud.gd:1785-1801, §1a) and the 3D mesh is a
bind-time build (world3d.gd:663-666, §2a). If the owner's "minimap changed"
is the base look, it can only come from a re-bind/new game, not from the
pattern tick — verify which minimap layer actually changed before concluding.

M2 (PROVEN — res_nodes move the minimap every tick, the 3D scene only via
mesh instances). New `wood` nodes draw 2x2 dots on the minimap immediately
(hud.gd:2408-2409); new ore/stone nodes draw 7x7 diamonds after the
`res_dirty` rebuild (hud.gd:2388-2390, 2039-2067). In 3D the SAME nodes must
pass the V7-80 gate (world3d.gd:403-412) and then resolve to a real donor sid
in `add_resource` (world3d_entities.gd:4065-4096) — a proxy or missing mesh
lands as a bbox stand-in (world3d_entities.gd:4078), and small/distant
instances are easy to miss in a full-map viewport frame. So "minimap shows
new groves/deposits, 3D looks flat" is EXPECTED if the 3D instances are
proxies, culled, or simply small at capture distance.

M3 (PROVEN — mine/stone stamps have no 3D terrain signature). The mine's
visible-terrain change in sim is ONLY the `_paint_terrain` dirt apron
(game.gd:1447); the donor 3D side has no apron asset and invents none
(world3d_entities.gd:220). The mine MESH appears via the feed (§2d), but the
ground around it stays the bind-time tile art. On the minimap the same stamp
draws a high-contrast 7x7 diamond (§1b). Asymmetric salience, same sim state.

M4 (PROVEN — hill stamps are nearly invisible by design on both, most of all
in 3D). `hill` writes height only (game.gd:1390-1398), no terrain paint, no
res node, no relief prop (RELIEF_SIDS excludes hills, §2c). In 3D a hill is
pure smooth-mesh relief under tile art; on the minimap it is NOTHING (base is
static, no blip). A hill-heavy pattern pass therefore reads as "minimap
changed [via its forest/mine siblings] but the 3D map looks flat".

M5 (PROVEN framing bias, [U] for this capture). The camera starts over
`map_starts` (camera.gd:179-193), the one region the generator deliberately
clears (§2e), while the minimap always shows the FULL map including every
distant stamped cluster. A start-framed viewport next to a full-map minimap
systematically understates pattern coverage. Whether the owner's --seq frames
kept start framing is [U] — not traced here.

EXCLUDED by bytes: (a) "sim nodes created but no 3D mesh path" is FALSE for
res_nodes in general — the feed covers them (§2d); it can only fail per-type
(proxy/missing sid). (b) "3D draws only tileblock arrays that patterns don't
modify" is FALSE — the mesh bakes height[] AND tileblock at bind
(world3d_terrain.gd:1220-1249), and `_assign_tileblocks` runs AFTER patterns
(game.gd:1462), so bind-time patterns ARE in the mesh. (c) The V7-80
`res_dirty` gate does NOT swallow pattern nodes — `_add_res` bumps the
counter (game.gd:1124).

---

## 4. What would settle it (no action taken — read-only worker)

- Q1: re-bind or live tick? Compare `minimap_base` pixels vs `minimap_img`
  pixels in the capture: base-only change ⇒ new game/re-bind (mesh rebuilt
  too); blip-only change ⇒ live tick (mesh terrain untouched by design, M1).
- Q2: for one new `res_node` id in the dump, check `world3d.stats` /
  entity stats for its `res|<sid>` batch vs `__proxy_` fallback
  (world3d_entities.gd:4078).
- Q3 [U]: log the `--seq` camera target per frame; if it never leaves
  `map_starts`, M5 dominates regardless of sim content.

---

## 5. Capture-mode note (context, byte-proven)

- `capture_sequence.py:164-175`: `--headless` appends Godot `--headless` and
  still passes `--seq/--seq-seconds/--seq-step`.
- `capture_sequence.py:546-549`: `--headless` help text — "engine saves a CPU
  map timelapse, NOT a real viewport frame; default is windowed viewport
  capture".
- `capture_sequence.py:634-638`: manifest records "headless seq = CPU map
  timelapse, NOT viewport frames" vs "windowed seq = real viewport frames
  (frame_post_draw)".
- A headless "3D map looks flat" frame is therefore not evidence about the
  3D renderer at all; only a windowed `--seq` frame is.

---

## 6. Chain / parity footer

- Chain: 0/6. No donor binary executed, no GPU A/B, no new measurement.
- Parity: UNVERIFIED. No parity claim is made for either display path; all
  port colours, rims, cluster rules, dim factors and placements cited above
  carry their in-file PORT APPROXIMATION / [U] labels, repeated here, not
  weakened.
- RESULT IS NOT GOOD: the divergence is structural (static terrain images on
  both displays + per-tick minimap blips vs bind-time 3D mesh + gated entity
  feed), not a single defect; M1–M5 each predict "minimap moves, viewport
  doesn't" for a different stamp kind, and this worker did not determine which
  stamp kind the owner's capture exercised.
