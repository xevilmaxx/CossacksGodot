---
id: V7-62
owner: V7-62
role: "feed live sim entities into the composed 3D entity module; complete the shared 2D world-contract surface; fix the per-frame int() constructor error"
date: 2026-11-24
owned_files:
  - variant3d/scripts/world3d.gd
  - docs/coord_swarm_2026-11-24/reports/V762_entity_feed.md
status: "DELIVERED — parse clean (ticket 109); full variant selftest passed:true 29/29 (ticket 130); entity meshes measured 0 -> 5 (ticket 126/128); world3d.gd:207 int() error absent after fix; visual parity UNVERIFIED"
verification_jobs: [89, 109, 118, 125, 126, 128, 130]
honest_limits:
  - "NO visual parity or GPU-render claim: the build is headless and the harness's screenshot path is a CPU map (AUDIT3D-09 §4)."
  - "2D player tint/terrain sprite chunks/animation sheets are NOT emulated; the added slots are honest aliases/no-ops (§5)."
  - "Baseline probe ticket 89 was invalid (concurrent V7-65 parse break in world3d_entities.gd:576/609, since fixed by that owner); the 2D baseline mesh count comes from AUDIT3D-09 ticket 75 instead."
  - "No git operations; no files outside the two owned files were left changed by this agent (temporary probe deleted)."
---

# V7-62 — live entity feed + 3D contract completion in `world3d.gd`

## 1. What landed

`variant3d/scripts/world3d.gd` only (331 → 527 lines, tabs, no RNG, no sprite
sheets, no `class_name`). One new report (this file). No edit to
`world3d_entities.gd`, `main.gd`, `input_controller.gd`, `hud.gd`, `camera3d.gd`,
`app/`, tests, config or assets. The 2D shipping port is untouched.

Three defects closed:

1. **P0 entity feed (AUDIT3D-01 #10 / P0-1).** The composition bound and synced
   the entities module but never called `add_unit`/`add_building`/
   `add_resource`/`remove`, so a real 3D skirmish rendered **zero** entity
   meshes. A reconciliation pass now walks the same collections the 2D world
   draws and drives the module's existing API.
2. **Per-frame runtime error (AUDIT3D-09 G2).** `_sync_selection()` called
   `int(id)` on the entity **Dictionaries** returned by `game.get_selected()`
   (`game.gd:2585-2590`), producing 5× `SCRIPT ERROR: Invalid call. Nonexistent
   'int' constructor.` in the passing 3D selftest and leaving the selection
   mirror empty. The id is now extracted with the same `"id"` key used by
   `by_id` (`game.gd:2023`).
3. **Incomplete 3D contract (AUDIT3D-04 E08) + `view_rect` type mismatch
   (AUDIT3D-05 E9).** Added the missing members/no-ops used by unbranched
   `main.gd`/`hud.gd`/`input_controller.gd`, and taught `_update_view_rect()` to
   accept the `Vector2` ground corners `camera3d.gd:181-188` actually returns.

## 2. Exact diff (final `file:line`)

| # | Location | Change |
|---|---|---|
| D1 | `world3d.gd:44-51` (new) | Header composition/citation notes for the entity feed and the 2D-only legacy slots. |
| D2 | `world3d.gd:110-127` (new) | Added slots: `fog_revision` `:114`, `_fog_rev_vis` `:115`, `fog_sprite` `:116`, `terrain_chunks` `:117`, `terrain_order` `:118`, `terrain_px` `:119`, `terrain_masks` `:120`, `anim_index` `:121`, `anim_tex` `:122`, `_rally_dirty` `:123`; feed id sets `_feed_entity_ids` `:126`, `_feed_res_ids` `:127`. |
| D3 | `world3d.gd:144-149` (new) | `_prop(g,key,fallback)` — null-safe key read for Dictionary entities and Object stubs (mirrors `_int_prop` `:132-142`). |
| D4 | `world3d.gd:191-237` (was `:156-190`) | `_update_view_rect()` now converts **Vector2** corners (map-origin metres, `camera3d.gd:89-90/181-188`) directly, keeps the old half-map shift only for legacy **Vector3** corners, skips non-finite points, and uses the converted XY for both the origin and the size (`:233-236`). Previously Vector2 corners were rejected by `if not (c is Vector3): continue`, leaving `view_rect` permanently full-map. |
| D5 | `world3d.gd:241-263` (was `:194-209`) | `_sync_selection()`: removed `selected_ids = got.duplicate()` and `var k := int(id)` on each item. Now clears both mirrors, extracts `k := _int_prop(item, "id", -1)` (`:258`), appends int ids (`:261`) and fills `selected[k]` from `by_id` (`:262-263`). |
| D6 | `world3d.gd:266-321` (new) | `_reconcile_entities()`: walks `game.entities` (`:277-295`) and `game.res_nodes` (`:296-315`); new id → `entities.add_unit` / `add_building` / `add_resource`; missing or dead/depleted id → `entities.remove(id)` (`:292-294`, `:313-315`). Skips dead entities (`:280`) and exhausted finite resource nodes (`:305-307`) exactly like 2D. |
| D7 | `world3d.gd:343-348` (new) | Creates `FogVisibilityProxy3D` (`Node3D`) so `main.gd:1442`'s `.visible` assignment is legal; no Sprite2D and no pixels. |
| D8 | `world3d.gd:351-354` (new) | Clears the feed id sets on re-bind (module instances are reused). |
| D9 | `world3d.gd:361-363` (was `:239-240`) | Calls `_reconcile_entities()` right after `entities.bind(game)` so meshes exist at bind time, not only on the next frame. |
| D10 | `world3d.gd:393` (new) | `stats.entity_feed` string records the feed source. |
| D11 | `world3d.gd:403-422` (was `:279-288`) | `sync()` calls `_reconcile_entities()` before `entities.sync(dt)` (`:406`); after `fog.sync(dt)` it bumps `fog_revision` only when the live aliased `fog_vis` actually differs from `_fog_rev_vis` (`:413-416`). |
| D12 | `world3d.gd:464-527` (new) | Contract completions: `_update_fog` `:471-482`, `mark_rally_dirty` `:484-490`, `_update_anim` `:492-494`, `invalidate_forest_bake` `:497-499`, `_bake_px` `:504-506`, `_build_masks` `:508-510`, `_anim_dir` `:514-524`, `mark_camera_dirty` `:526-527`. All labelled in-code as alias/no-op; details in §5. |

## 3. Donor / 2D evidence for the collections that drive entities

| Which collection | Evidence | Use in this diff |
|---|---|---|
| `game.entities` | 2D draws units from `app/scripts/world.gd:2213` and buildings at `:2837`; `variant3d/scripts/world.gd:2213,2837` is byte-identical (AUDIT3D-04 E01). Spawn appends a Dictionary and keys it in `by_id` at `game.gd:2022-2023`; dead entities are skipped at `world.gd:2201,2230,2838`. | D6 walks it, skips `dead`, sends `kind == "unit"` → `add_unit`, `kind == "building"` → `add_building`. |
| `game.res_nodes` | 2D draws resources at `world.gd:2706`; depletion rule `:2712-2716` (permanent `max_hits == 0` ore, stump and food stay visible). Nodes are created and keyed at `game.gd:508-517`. | D6 walks it, applies the same depletion rule, sends `add_resource`. |
| `game.by_id` | `game.gd:2023,517` keys both collections by the same entity `"id"`; `get_selected()` at `game.gd:2585-2590` returns entity Dictionaries. | D5 reads `"id"` from each selected Dictionary (the exact key `by_id` uses) and fills `selected[id] = entity`. |
| Entity module API | `world3d_entities.gd:574-...` (`add_unit`), `:604-...` (`add_building`), `add_resource`, `remove`; its `sync()` at `:555-590` only transforms already-registered slots. AUDIT3D-01 evidence #10 says no production caller existed. | D6/D9/D11 use only that API; no module code was edited. |
| Static-pose / no sheets | `world3d_entities.gd` header `:41-50` and `ANIM_STATUS`; WAVE7 charter `:40-53` excludes baked sprite sheets from 3D. | `_update_anim` / `_build_masks` / `_anim_dir` fabricate no pixels (§5). |

No donor bytes were copied; no donor value was invented. Every port scalar used
here already existed (`Data.TERRAIN_PX`, `Data.SPRITE_CELL`, `world.gd:501-508,1039`).

## 4. `int()` constructor error — diagnosis, before/after

**Root cause (OBS).** `game.get_selected()` (`game.gd:2585-2590`) returns an Array
of **entity Dictionaries**. Old `world3d.gd:207` did `var k := int(id)` where
`id` was one of those Dictionaries; Godot has no `int(Dictionary)` constructor,
so each selected entity raised `SCRIPT ERROR: Invalid call. Nonexistent 'int'
constructor.` every frame. AUDIT3D-09 ticket 76 measured exactly 5 occurrences
during a *passing* selftest; `selected` stayed empty.

**Fix (D5).** Extract the id with the same `"id"` key `by_id` uses — no blanket
cast on the object. `selected_ids` now holds ints, matching
`input_controller.gd:189`.

| Evidence | Before | After |
|---|---|---|
| Selftest stderr (result dirs) | ticket 76 `stderr.txt`: 5× `SCRIPT ERROR: Invalid call. Nonexistent 'int' constructor. at: _sync_selection (res://scripts/world3d.gd:207)`; my baseline probe ticket 89 `stderr.txt:31-32` also captured it | ticket 130 `stderr.txt` (11 lines) contains **no** `int` constructor error and no missing-member errors; only the intentional static-pose warning and exit leaks |
| Selection mirror (probe) | empty (`selected = {}`) | ticket 128 stdout: `V762_SEL before_sync stub=2 flags=true,true`, `V762_SEL after_sync ids=[7001, 7002]`; after removing entity 7002 from the live collection the mirror reflects `[7001]` |

## 5. Contract completions — honest behaviour

| Member | Caller | What it really does |
|---|---|---|
| `_update_fog` | `main.gd:1331` (F9 load) | Delegates to the fog module's own `_update_fog` (`world3d_fog.gd:128`) and bumps `fog_revision` only if the aliased `fog_vis` changed. |
| `mark_rally_dirty` | `input_controller.gd:609,634` | 2D uses a dirty bit (`world.gd:149-156`); 3D FX refreshes rally markers every sync (`world3d_fx.gd:129`), so this sets the legacy slot and calls `fx.sync(0.0)` for an immediate, non-ageing refresh. No new art. |
| `fog_revision` | `hud.gd:1741,1748` | Increment in `sync()` on a real `fog_vis` change (port gate from `world.gd:137,2247`). |
| `fog_sprite` | `main.gd:1442` | `Node3D` visibility **proxy only** — no Sprite2D/ImageTexture. Actual overlay visibility is read from `Data.FOG_OF_WAR` by `world3d_fog.gd:317`. |
| `terrain_chunks`, `terrain_order`, `terrain_px`, `terrain_masks` | `main.gd:1418-1422,1424` | Empty legacy slots. 3D terrain is ONE mesh (V713 §2/§4); no Sprite2D chunks are freed or rebuilt. |
| `invalidate_forest_bake` | `main.gd:1423` | **NO-OP by design**: no forest sprite bake exists in the 3D branch. |
| `_bake_px`, `_build_masks` | `main.gd:1424` | `_bake_px` copies `world.gd:1039` (`mini(terrain_px*4,64)`); `_build_masks` returns `[]` like `world.gd:1044-1051` (legacy array, no side-effect images). Probe: `bake_px=64`, `mask_size=0`. |
| `anim_index`, `anim_tex`, `_anim_dir` | `main.gd:1425-1436` | Plain Dictionary slots plus the canonical **path string** from `world.gd:501-508`. `world3d.gd` never loads from that directory; no baked sheet is touched. Probe: `anim_dir="res://assets/models/anim"`. |
| `_update_anim` | defensive (no live call site found) | **NO-OP**: 3D entities are static bind poses; `anim3d.gd` owns the labelled PORT APPROXIMATION handoff. |
| `mark_camera_dirty` | defensive (`camera.gd:120-121`, 2D camera only) | **NO-OP**: `camera3d.gd` derives its transform from `_target`/`clamp_pos` (`:146-153`). |

`view_rect` fix (D4): measured with a Vector2-corner `Camera3D` stub in the probe
(corners 10,10 → 30,30 m at `view_scale=16`): `view_rect` changed from the
full-map `[P:(0,0), S:(2048,2048)]` to `[P:(160,160), S:(320,320)]`, so a
double-click's "same type on screen" test (`input_controller.gd:549-551`) now
uses a real visible-area rect. This is a coordinate fix only — no claim about
visual fidelity or projected-quad shape under camera yaw.

## 6. Before / after mesh counts and verification jobs

Baseline (AUDIT3D-09 ticket 75 node-tree probe, real `world3d.gd` + stub game):
`class_counts.MeshInstance3D = 4` (terrain, water, footprint, fog overlay),
`multimesh_count = 0` → **0 entity meshes**.

After (tickets 126/128, stub with 2 units + 1 building + 2 resources):

| Moment | Entity-module meshes | `stats.units` | `stats.buildings` | `stats.resources` | `stats.batches` |
|---|---|---|---|---|---|
| after `bind()` (feed seeded) | 5 | 0¹ | 0¹ | 0¹ | 0¹ |
| after `sync(0.016)` | 5 | 2 | 1 | 2 | 4 |
| after removing unit 7002 + `sync` | 4 | 1 | 1 | 2 | 3 |

¹ The module updates `stats` in its own `sync()`, not in `add_*`, so the first
row is a measurement-timing artifact, not a missing mesh. `mesh_sources_loaded =
{ "obj_zup_bbox_normalised": 5 }` in all three rows: five donor OBJ meshes were
actually requested.

| Ticket | Job id | Command (abridged) | Wait / run | Result |
|---|---|---|---|---|
| 89 | `v762-probe-before` | `--headless --path variant3d --script res://tests/v762_entity_feed_probe.gd` | 78.56 s / 124.22 s | **timed-out / invalid**: concurrent V7-65 edit left `world3d_entities.gd:576,609` with an inferred-Variant parse error, so the module did not load and the probe hung before its deferred quit. It still captured the baseline `world3d.gd:207` int error. V7-65 fixed that parse break before the later jobs. |
| 109 | `v762-parse` | `--headless --path variant3d --check-only --script res://scripts/world3d.gd` | 429.90 s / 3.21 s | `END ok`; `stderr.txt` empty → **parse clean**. |
| 118 | `v762-probe-after` | probe (first working version) | 12.76 s / 3.65 s | `END ok`; 5 entity meshes, 4 batches after sync; stubs callable; camera not current during `_initialize` so `view_rect` still full map (probe timing, not product). |
| 125 | `v762-probe-after2` | deferred probe | 97.73 s / 2.70 s | `END failed`: probe-only parse error `Function "get_viewport()" not found in base self` (SceneTree); fixed to `root.get_viewport()`. |
| 126 | `v762-probe-after3` | deferred probe | 0.00 s / 2.45 s | `END ok`; `missing_contract_methods=[]`, `bake_px=64`, `mask_size=0`, `view_rect=[P:(160,160), S:(320,320)]`, `camera_current=true`. stderr only the intentional static-pose warning. |
| 128 | `v762-probe-after4` | probe + selection debug | 0.00 s / 2.33 s | `END ok`; `stub_selected_count=2`, `after_sync ids=[7001,7002]`, mesh counts as table above. No int-constructor error. |
| 130 | `v762-entity-feed` | `--headless --path variant3d -- --self-test variant3d/selftest.json` | 0.00 s / 53.44 s | `END ok`; `variant3d/selftest.json`: **`passed: true`, 29 steps, 0 failed** (move … nav_detour). `stderr.txt` has no `int` constructor error and no contract-member error; only bind-pose warning + exit leaks (pre-existing, AUDIT3D-09 §5). |

All launches went through `python variant3d/tools/godot_runner.py run --id ...`
(`variant3d/tools/godot_runner.py:349-437`) — variant3d's own FIFO runner only.
The temporary probe `variant3d/tests/v762_entity_feed_probe.gd` and its result
JSON were deleted after ticket 128 (`Test-Path = False`). Runner result folders
under `variant3d/.godot_queue/results/` are tool artifacts. Runner stdout/stderr
were read from those folders, not from a local console.

## 7. Open questions

1. **Runtime F9/Options/rally paths (AUDIT3D-04 Q2)** were not individually
   exercised; only the selftest plus probe calls. The stubs remove the
   missing-member errors, but no 3D menu smoke log was captured.
2. **`terrain_px` quality change** now only updates a scalar; the 3D terrain mesh
   is not rebuilt on a quality change. Whether that should trigger
   `terrain.build()` is a behaviour decision for the terrain owner (V7-60).
3. **Fog revision on `fog_explored` writes that do not change `fog_vis`**:
   the gate mirrors 2D's "write a pixel" wording only for `fog_vis`. If a HUD
   consumer needs explored-only revisions, the comparison should include
   `fog_explored`; not measured here.
4. **Camera-corner mix**: Vector2 is treated as map-origin metres, Vector3 as
   centre-origin world metres (old behaviour). If another camera returns
   centre-origin Vector2 corners, `view_rect` would be offset; no such caller
   exists today (`camera3d.gd:181-188` is the only one).
5. **Entity coverage**: the feed now creates meshes for whatever sids the sim
   spawns; 58 unresolved sids still fall back to a proxy cube (AUDIT3D-01 P0-2,
   V7-63 owner). This atom did not add models.
6. **Visual parity remains UNVERIFIED** (AUDIT3D-09 G1): no GPU 3D pixels are
   obtainable from the current harness. No visual claim is made.

*End of V7-62 report.*
