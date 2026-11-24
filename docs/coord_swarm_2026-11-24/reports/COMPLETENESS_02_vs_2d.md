# COMPLETENESS_02 — feature coverage of `variant3d/` vs the shipping 2D port `app/` (2026-11-24)

**Role:** COMP-02, READ-ONLY. No Godot jobs, no git, no source edits. Every claim is from
current source hashes, current file reads, or a cited existing report. Earlier AUDIT3D
claims were treated as UNDONE until re-verified here; where current source contradicts
them, the contradiction is called out.

## Method

1. SHA-256 of every `.gd` in `app/scripts/` and `variant3d/scripts/` (16-hex prefix below).
   Byte-identical files are **SHARED**; divergent files were unified-diffed and read.
2. Enumerated the major skirmish subsystems from `app/scripts/` function inventories
   (`game.gd`, `world.gd`, `ai.gd`, `input_controller.gd`, `hud.gd`, `main.gd`, `menu.gd`,
   `audio.gd`, `mapgen.gd`, test harnesses), then checked `variant3d/scripts/` for a
   byte-identical copy, a `render_mode == "3d"` adapter, a 2D-only visual with no 3D
   counterpart, or a no-op/stub.
3. Confirmed which `render_mode` branches actually exist (§3), and re-verified the
   V7-81/90 camera and V7-92 terrain/water state in current source (§4).

### Hash result (current source)

**SHARED — byte-identical (13/21 common scripts):**
`ai.gd` 51295401D3BACC44 · `camera.gd` ADAB3F668FDB63E6 · `config.gd` 3C5E9E5FB6D52443 ·
`game.gd` 8649A865BE287C6F · `mapgen.gd` FEB6A4D66734D50D · `menu.gd` 3A150E7E36C8623B ·
`nav.gd` 85146EA504092C33 · `pattern_gen.gd` 3F923296AA62DD73 · `selftest.gd` B0BFC4558CD3DF30 ·
`terrain3d_sandbox.gd` B3CFCFFD0DA59130 · `testbridge.gd` BECEB5A79966C855 ·
`uitest.gd` 047570D4A35BD798 · `world.gd` 04750BDA7C913771.

**Divergent (8/21):** `audio.gd` (EA57… vs 8312…), `data.gd` (A5D4… vs 286F…),
`heightmap_world3d.gd` (E4DD… vs B590…), `heightmap3d_sandbox.gd` (C793… vs 37E3…),
`hud.gd` (9B5F… vs 562E…), `input_controller.gd` (E633… vs EC8F…),
`main.gd` (C740… vs D43F…), `world3d.gd` (137C… vs BA89…).

> **STALE AUDIT3D CLAIM — corrected:** `AUDIT3D_TRIAGE.md:17` says "14/21 common scripts
> byte-identical (incl. …)" and `AUDIT3D_TRIAGE.md:17-18` says "identical audio.gd hash".
> Current source has **13/21**. `audio.gd` is now ADAPTED (Vector3 camera support added,
+935 bytes) and `data.gd` is ADAPTED (+`RENDER_MODE`, +314 bytes). `world3d.gd` is no
> longer the legacy M0 terrain world: variant3d rewrote it as the V7-51 composition
> (`variant3d/scripts/world3d.gd:34-45`). The byte-identical figure is lower than the
> earlier audit's, not higher.

**variant3d-only 3D modules (no 2D counterpart, all ADAPTED):** `world3d_terrain.gd`,
`world3d_entities.gd`, `world3d_fx.gd`, `world3d_fog.gd`, `anim3d.gd`, `water3d.gd`,
`camera3d.gd`, `picking3d.gd`, `hud3d_adapter.gd`, `tile_atlas_loader.gd`.
`app/scripts/world3d.gd` and `app/scripts/heightmap_world3d.gd` are the 2D port's
*development sandboxes*; `app/` skirmish rendering is `world.gd`, not those files.

## 1. Coverage table

Status legend: **SHARED** = byte-identical file, full coverage; **ADAPTED** = 3D adapter
implemented (current source branch/method exists); **2D-ONLY** = 2D-visible feature with
no 3D counterpart found; **STUB** = no-op/placeholder.

| Subsystem | app source | variant3d source / branch | Status | Evidence path:line | Impact |
|---|---|---|---|---|---|
| Core game sim (rules, orders `cmd_*`, gather, build, combat, victory, serialize) | `app/scripts/game.gd` (224,061 B) | `variant3d/scripts/game.gd` byte-identical | **SHARED** | hash 8649A865BE287C6F both; `game.gd:159`+ `cmd_move`/`cmd_attack`…`_check_victory` | Full parity: every sim rule/order identical |
| AI (per-player brain, waves, squads, economy priorities) | `app/scripts/ai.gd` (36,875 B) | byte-identical | **SHARED** | hash 51295401D3BACC44 both; `ai.gd:116 _form_squads`, `:855`+ | Full parity |
| Map generation + patterns + nav grid | `mapgen.gd`, `pattern_gen.gd`, `nav.gd` | byte-identical | **SHARED** | hashes FEB6A4D6 / 3F923296 / 85146EA5; `mapgen.gd` full file | Full parity |
| Economy / building / capture / training / market / fields (sim) | `game.gd` | byte-identical | **SHARED** | `game.gd:508 _add_res`, `:2320 train_unit`, `:2834 game_reveal`, `:3392` upkeep; hash 8649… | Full parity (visual overlays separate rows) |
| Formations / squads / morale (sim) | `game.gd` | byte-identical | **SHARED** | `game.gd:squad_form/_donor_formation_bonus/_update_morale/_tick_rout/_morale_shock`; hash 8649… | Full sim parity; visuals 2D-ONLY below |
| Combat / weapons / naval (sim) | `game.gd` | byte-identical | **SHARED** | `game.gd:_pick_weapon/_fire/_apply_hit/_tick_projectiles/_naval_info`; hash 8649… | Full parity |
| Render-mode switch (port extension, additive) | absent (2D-only port) | `main.gd:124` default `"2d"`, `:181-182` cfg read + `Data.RENDER_MODE`; `data.gd:61 RENDER_MODE` | **ADAPTED** | `variant3d/scripts/main.gd:121-124,181-182`; `data.gd:61`; `V750_main_integration.md` | Opt-in 3D; 2D default unchanged |
| World composition / 2D world contract | `app/scripts/world.gd` (173,637 B, all rendering) | `world3d.gd` composition + 5 modules | **ADAPTED** | `world3d.gd:34-45` map, `:507-585 bind`, `:590-608 sync`; contract `V73_ATOMIC_CONTRACT.md:24` | All unbranched callers legal in 3D |
| Terrain rendering (height mesh, splat/tile-atlas, shore) | `world.gd:948-1730` chunk bake/splat/season | `world3d_terrain.gd` one full-grid mesh + V7-92 atlas/tile-index shader | **ADAPTED** | `world3d_terrain.gd:158-178 set_atlas_mode`, `:206-262 _load_atlas`, `:389-428 tileblock decode`, `:557-700 build`; `V792_terrain_integration.md:74-94` | Real 102,400-cell live tileblock render; no per-chunk sprites by design |
| Water rendering | `world.gd:911-947 _setup_water_overlay/_wave_sheet` | `water3d.gd` donor water shader + `world3d_terrain.gd:464-487 _make_water3d` | **ADAPTED** | `water3d.gd:95-99` animated `time` uniform, `:138-169 build`, `:77-81` donor diffusewaves; `V792…:122-125` | Animated height-aware water; earlier "flat quad" triage claim is outdated |
| Light rig | `world3d.gd` (app dev sandbox) | `world3d_terrain.gd:494-528 _make_environment` | **ADAPTED** | `WorldEnvironment` + `DonorSun`; `AUDIT3D_TRIAGE.md:34` (G5 closed) | Real light rig, energies port-tuned (not donor) |
| Entities (units/buildings/resources/trees/fields as meshes) | `world.gd:2213-3370` sprite/nation sheets | `world3d_entities.gd:817-919 add_unit/add_building/add_resource` + `anim3d.gd` | **ADAPTED** | 116 donor OBJ, tint by player batch `world3d_entities.gd:833-838,861-870`; `AUDIT3D_TRIAGE.md:31-37` | Real meshes, player tint; static bind-pose morph (approx) |
| Animation | `world.gd:450-610 _anim_*` sprite frames | `anim3d.gd` donor-sampled flat-root morph; `world3d.gd:648-651 play_anim` | **ADAPTED (approx)** | `anim3d.gd:63 PORT_LABEL`, `:918 _action_range_for`; `world3d.gd:701-704 _update_anim` no-op | Motion present but labelled NOT DONOR PARITY |
| Fog of war (sim arrays + overlay) | `world.gd:333-347,2186-2272` | `world3d_fog.gd` per-tile quad mesh; `game.gd` sim SHARED | **ADAPTED** | `world3d_fog.gd:33-44` alpha ladder verbatim, `:70+ bind/sync`; `world3d.gd:138-140,561-563` aliased arrays | FOW works in 3D (default off per config) |
| FX (shot/smoke/explode/crater/fire/heal/rout/chop/capture/trail) | `world.gd:3563-3685 add_fx/_draw_fx` | `world3d_fx.gd:42-54 LIFE`, `:96-100 EVENT_FX`, `:498-579 _kind_color/_build_visual` | **ADAPTED** | `world3d.gd:619-628 add_fx` order swap; `V773_fx_world_offset.md` | Event FX preserved; several 2D-only FX overlays missing (below) |
| Build ghost + rally marker | `world.gd:3460-3509 _draw_ghost`, `:3602-3613` rally | `world3d_fx.gd draw_ghost/draw_rally`; `world3d.gd:442-502` condition translation | **ADAPTED** | `world3d.gd:405-502`; `V776_ghost_rally.md`; `AUDIT3D_TRIAGE.md:38` G10 closed | Build placement + rally feedback work in 3D |
| Camera (2D path) | `camera.gd` (orbit/zoom/edge-scroll) | `camera.gd` byte-identical for 2D; `main.gd` builds `camera3d.gd` only in 3D | **SHARED + ADAPTED** | hash ADAB3F66; `main.gd:588-597,1052,1112` 3D branches | 2D camera unchanged; 3D camera below |
| Camera (3D: height/wheel/pan/minimap centre, tilt, anchor) | no 2D analogue | `camera3d.gd` V7-81/90 state | **ADAPTED** | `camera3d.gd:85-95` height state, `:164-175` bind, `:553-556` wheel, `:529-534` pan, `:459-460` middle drag, `:132/401/439 _own_clamp_target`; `V790…:296-325` | Measured 2.0 m/notch, 2.0 m/s pan, -32° tilt; ArcTan offset/FOV still OPEN |
| Input / orders / hotkeys / control groups (logic) | `input_controller.gd` (all `cmd_*`, hotkeys, groups, build ghost) | `input_controller.gd` + `bind_3d()`; cmd/hotkey/group code byte-identical | **ADAPTED** | `input_controller.gd:103-125 bind_3d`, `:15-18` comment; diff shows no `cmd_*` change | Full order/hotkey/group parity |
| Picking / screen→ground / entity + resource pick | `_screen_to_world/_pick/_pick_res` in `input_controller.gd` | `picking3d.gd` ray-heightfield + depth ordering, 3 seams | **ADAPTED** | `input_controller.gd:386,403,732`; `picking3d.gd:196-204 ground_point`, `:207-219 pick players_only`; `V768_picking_fix.md` | 3D clicks/rally/harvest work; `players_only=false` now forwarded (V7-68 fixed) |
| HUD / minimap (image, blips, orders) | `hud.gd` (73,202 B) | `hud.gd` + `hud3d_adapter.gd`, only box source switched | **ADAPTED** | `hud.gd:190-213 bind_3d`, `:1409` minimap jump, `:1470-1479` adapter box; minimap terrain from `game.terrain` at `:1356-1375` | Minimap rendered from SHARED sim; 3D jump fixed (V7-81) |
| Menu / load-save / options | `menu.gd` (38,692 B) | byte-identical | **SHARED** | hash 3A150E7E; `menu.gd` full file | Full parity |
| Audio bed (event dispatch, 325 .ogg clips) | `audio.gd` | `audio.gd` ADAPTED (Vector3 centre + camera-3D distance cull) | **ADAPTED** | `audio.gd:150-161` Vector3 centre, `:329-340` 3D distance cull; `AUDIT3D_TRIAGE.md:17-18` | No missing sounds; see spatial-audio gap below |
| Journey / sequence capture | `main.gd` journey camera + `--seq-dir` | `main.gd` 3D journey branch; `selftest/uitest/testbridge` SHARED | **ADAPTED** | `main.gd:1645-1661` V7-70 camera lerp branch, `:1815-1873` capture; `V770_viewport_capture.md` | Journey works in 3D; true GPU capture path |
| CLI/test harness (selftest/uitest/testbridge/sandbox) | `selftest.gd`, `uitest.gd`, `testbridge.gd`, `terrain3d_sandbox.gd`, `heightmap3d_sandbox.gd` | 4 SHARED; `heightmap3d_sandbox.gd` = 6-line stub | **SHARED + STUB** | hashes B0BF/0475/BECE/B3CF; `variant3d/scripts/heightmap3d_sandbox.gd:1-6` vs `app/scripts/heightmap3d_sandbox.gd:1-238` | One dev-only harness lost |
| Selection rings / player aura / selected ring | `world.gd:210-211,319-320` sprites; `:3012-3035` aura; `:3252-3254,3364-3366` rings | no 3D mesh/shader found in `world3d_*` | **2D-ONLY** | `app/scripts/world.gd:3252-3254,3012-3035`; `world3d_fx.gd:523-579` has no `sel`/ring case; `AUDIT3D_TRIAGE.md:42` P1.3 | **Critical** — cannot tell what is selected/owned |
| Health / damage bars + building/farm progress bars | `world.gd:2577,2611-2612,2901-2906,3004-3010,3119-3120,3135-3136` | no 3D equivalent | **2D-ONLY** | `app/scripts/world.gd:2901-2906,3119-3120`; `world3d_entities.gd:817-919` has no bar mesh | **High** — damage/build progress unreadable |
| Morale pips / rout indicator | `world.gd:3372-3374` green/amber/red pip | no 3D equivalent (only transient `rout` FX) | **2D-ONLY** | `app/scripts/world.gd:3372-3374`; `world3d_fx.gd:514-515,572-575` | **High** — unit state invisible |
| Drag-selection rectangle + patrol-route overlay | `input_controller.gd:1012-1017` writes `world.sel_rect`; `world.gd:3641-3644` draws it; `_draw_patrol_route` | `world3d.gd:110-111` data-only mirrors; `input_controller.gd:94-97` Node2D attached under Node3D `fx_layer` | **2D-ONLY** | `app/scripts/world.gd:3641-3644`; `variant3d/scripts/world3d.gd:110-111`; `input_controller.gd:94-97,364-379` | **High** — order feedback misaligned/invisible in 3D |
| Squad links, officer flags, capture flags | `world.gd:3583-3601` squad links, `:3316` officer flag, `:2970-2972` capture flag | `world3d_fx.gd` rally pennant only; no squad-link/officer/capture flag | **2D-ONLY** | `app/scripts/world.gd:3583-3601`; `world3d_fx.gd:582-620 _make_rally` | **Medium-high** — formation/capture ownership unreadable |
| Corpses / rubble | `world.gd:3229 _draw_corpses`, `:3064 _draw_rubble`; `game.rubble` | dead units scaled to 0; `game.rubble` not rendered | **2D-ONLY** | `app/scripts/world.gd:3229,3064`; `world3d_entities.gd:786-811 _is_hidden` | **Medium** — battlefield aftermath missing |
| Winter/season terrain art + relief tint | `world.gd:1096-1172,1642-1650` winter art/tint | terrain uses fixed donor tile atlas from live tileblock; no winter/season art path | **2D-ONLY** | `app/scripts/world.gd:1104-1172`; `world3d_terrain.gd` no season/winter match (grep) | **Medium** — winter maps look like summer |
| Forest understory/props/field-growth detail | `world.gd:2375-2521` trees/understory, `:2529-2624` field/growth bars | trees as POOL_TREE meshes; field static ground patch; no understory/growth bar | **PARTIAL / 2D-ONLY** | `world3d_entities.gd:82-86,877-919`; `app/scripts/world.gd:2529-2624` | **Medium-low** — farms/resources less legible |
| 3D positional audio (`AudioStreamPlayer3D`) | 2D uses pan/volume by distance | only `AudioStreamPlayer` + manual camera-distance cull | **2D-ONLY (gap)** | `audio.gd:37-39,120-126`; no `AudioStreamPlayer3D` (grep); `AUDIT3D_TRIAGE.md:59-60` P1.9/P1.10 | **Medium** — no spatial sound stage |

## 2. Actual `render_mode` branches in current source

Gameplay `render_mode` (port extension, `Data.RENDER_MODE`) appears in exactly five files;
the remaining matches are GLSL shader `render_mode` lines or comments:

- `main.gd` — 17 matches: construction `:578,588,597,630,1052,1112`, hooks `:1190`,
  journey `:1645,1659,1661`, capture `:1830,1855,1856,1870,1873`.
- `input_controller.gd` — `:123 bind_3d`, `:231 minimap jump`, `:386/_pick`, `:403` (comment),
  `:732 pick_res`, `:843 shift+group camera`.
- `hud.gd` — `:56 state`, `:213 bind_3d`, `:1409 minimap jump`, `:1470 adapter box`.
- `audio.gd` — `:333` comment only (behaviour keyed off `cam.global_position is Vector3`).
- `data.gd` — `:61 RENDER_MODE` declaration.

`game.gd`, `world.gd`, `ai.gd`, `mapgen.gd`, `menu.gd`, `nav.gd`, `pattern_gen.gd`, and all
test files contain **no** gameplay `render_mode` branch (they are byte-identical SHARED).
This is the structural reason the sim/HUD/input order semantics survive unchanged.

## 3. V7-81 / V7-90 / V7-92 re-verification (current source)

- **V7-90 camera:** explicit `height`/`height_target` (`:85-88`), donor profile speeds
  (`:92-94`, `:164-166`), additive wheel `delta_h` (`:553-556`), zoom-independent pan
  (`:529-534`), middle-drag divisors 60/45 (`:459-460`) — **present**.
- **V7-81 minimap black fix:** `_own_clamp_target` memo seam at `camera3d.gd:132,233,236,
  401,439`; `main.gd:_center_camera3d_target` (`:171-179`) subtracts map centre and freezes
  the clamp memo — **present**. No donor ArcTan offset (documented OPEN at
  `camera3d.gd:381-392`); FOV still assumed 17.27 (`:59`).
- **V7-92 terrain/water:** tile-index shader from live `game.tileblock`
  (`world3d_terrain.gd:389-428`, `:631 UV2`), single/split/array atlas loader
  (`:158-178`, `:206-262`), water module with donor literals and animated `time`
  (`water3d.gd:19-29,95-99,138-169`, wired at `world3d_terrain.gd:464-487`) — **present**.
  Face-tile promotion still OPEN (`V792…:174-175`).

## 4. Top 10 missing / 2D-only features, ranked by player-visible impact

| Rank | Gap | Player-visible effect | Evidence |
|---:|---|---|---|
| 1 | **No selection rings / player aura / owner colour on entities in 3D** | Player cannot tell which units are selected, or friend from foe at a glance — core RTS feedback absent | `world.gd:3012-3035,3252-3254,3364-3366`; no 3D ring case in `world3d_fx.gd:523-579`; `AUDIT3D_TRIAGE.md:42` P1.3 |
| 2 | **No health/damage bars or construction/growth progress bars** | Cannot gauge unit damage, building completion or farm growth | `world.gd:2577,2611-2612,2901-2906,3119-3120,3135-3136`; `world3d_entities.gd:817-919` |
| 3 | **No morale pips / rout visual on units** | Morale state and breaking lines are invisible; sim still routs | `world.gd:3372-3374`; `world3d_fx.gd:514-515,572-575` (transient FX only) |
| 4 | **Drag-select rectangle and patrol-route overlay are 2D canvas overlays** | Box-select and patrol orders give no correct on-ground feedback | `world.gd:3641-3644`; `world3d.gd:110-111` data-only; `input_controller.gd:94-97,364-379` |
| 5 | **No squad-link lines, officer flags or capture flags** | Formation/capture ownership and command structure not shown | `world.gd:3316,3583-3601,2970-2972`; `world3d_fx.gd:582-620` |
| 6 | **No corpses or rubble** | Battlefield aftermath disappears; dead units simply scale to 0 | `world.gd:3064,3229`; `world3d_entities.gd:786-811`; `game.rubble` unrendered |
| 7 | **No 3D positional audio** | All 325 sounds are non-spatial; camera-distance cull only, no left/right or true 3D falloff | `audio.gd:37-39,120-126,329-340`; `AUDIT3D_TRIAGE.md:59-60` |
| 8 | **No winter/season terrain art path** | Winter/custom-season maps render with the fixed summer donor atlas/tint | `world.gd:1096-1172,1642-1650`; `world3d_terrain.gd` (no season match) |
| 9 | **Forest understory / props / field-growth detail not reproduced** | Farms and resource nodes read as plain static meshes; less scene legibility | `world.gd:2375-2624`; `world3d_entities.gd:82-86,877-919` |
| 10 | **`heightmap3d_sandbox.gd` reduced to a 6-line stub** | Full-map heightmesh CLI capture harness lost (dev tooling, lowest player impact) | `variant3d/scripts/heightmap3d_sandbox.gd:1-6` vs `app/scripts/heightmap3d_sandbox.gd:1-238` |

## 5. Honesty / scope guards

- All sim, economy, AI, capture, formation, morale, combat, naval, menu and test logic is
  byte-identical SHARED; the gaps above are **presentation-layer only**, not rule/mechanic
  regressions.
- No donor visual A/B exists; nothing here claims donor or visual parity. Water, terrain
  atlas and camera changes are verified as *present and structurally wired*, not as
  pixel-matching the donor or the 2D port.
- `world3d.gd`'s `_update_anim`, `invalidate_forest_bake`, `_build_masks`,
  `mark_camera_dirty` are honest no-op contract aliases for unbranched 2D callers
  (`world3d.gd:701-738`), not lost player features; the same is true of `fog_sprite` /
  `terrain_chunks` legacy slots (`:134-147`).
- `heightmap3d_sandbox.gd` is the only file that is a literal STUB rather than an
  intentional no-op seam.
