---
id: PORT1TO1-OBJECTS-ANIM-COLLISIONS-FX
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER PORT1TO1-ENTITIES — donor 1:1 spec for skirmish 3D objects, animation states, collision and FX"
owner_file: docs/terrain_swarm_2026-11-26/reports/PORT1TO1_objects_anim_collisions_fx.md
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_ASSET_CONFIG_GODOT_GIT_EDIT
created: 2026-11-26
labels: [O, D, I, U, "PORT APPROXIMATION", NO_PARITY_CLAIM]
parity_guard: "NO DONOR PARITY IS CLAIMED. No same-camera donor/port A/B frame was produced or examined. Every donor statement is a read-only text/constant/byte/decomp observation; every port statement is a read-only source line. 'Required donor-faithful replacement' means the algorithm that must be implemented, not a claim that it is implemented."
scope_guard: "Exactly one repo file written (this report). No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod edit. Donor binary and donor data read READ-ONLY; no donor executable run, no donor bytes copied into the repo."
donor_targets:
  - "t_87f0f3c130b0 (C:\\Games\\Cossacks 3\\cossacks.exe, sha256 87f0f3c130b0..., PE x86, deep mode)"
  - "t_68474ddde43f (C:\\Games\\Cossacks 3\\editor.exe, sha256 68474ddde43f..., cross-check only)"
  - "C:\\Games\\Cossacks 3\\data (read-only donor config, scripts, actor/prop/PFX text)"
port_scope: "variant3d/scripts/{anim3d,world3d_entities,world3d_fx,picking3d,game,data}.gd"
exclusions: "NETWORK / multiplayer / lobby / steam / replay-sync are explicitly OUT OF SCOPE. Singleplayer skirmish only."
prior_reports_read:
  - docs/terrain_swarm_2026-11-26/reports/VIDEO_ANIM_3d.md
  - docs/terrain_swarm_2026-11-26/reports/X16_prop_mesh_coverage.md
  - docs/terrain_swarm_2026-11-26/reports/DEC_DEEP_placement_755f30.md
  - docs/coord_swarm_2026-11-24/reports/MILLFIX_rotor_fields.md
  - docs/terrain_swarm_2026-11-26/reports/V08_coordinate_scale.md
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_skirmish_logic.md
---

# PORT1TO1-ENTITIES — donor 1:1 object / animation / collision / FX specification

> READ-ONLY. Singleplayer skirmish only. Network code, multiplayer state, lobby, Steam and
> replay sync are **explicitly excluded**. No parity claim, no approximation endorsed.
> Every `[U]` in §6 carries a decomp plan, never a fallback.

---

## 0. Method, labels, evidence discipline

- **[O]** = observed in a named donor file/line, donor binary byte/VA, or port source line.
- **[D]** = deterministic arithmetic/translation over cited **[O]** facts (e.g. pixels → metres).
- **[I]** = plausible reading without runtime proof. **[U]** = unresolved after the passes here.
- **PORT APPROXIMATION** = a port-authored substitute that is *not* donor behaviour; it is listed
  as debt to be removed, never as an accepted target.
- Path shorthands for this report:
  - `D:` = `C:\Games\Cossacks 3\data\` (READ-ONLY donor text/binary side).
  - `P:` = workspace `variant3d\`.
  - `c3` = `t_87f0f3c130b0` (`cossacks.exe`); `ed` = `t_68474ddde43f` (`editor.exe`).
  - `ev_<hex>` = Craft Anything evidence id of a decomp/string/data pass in this session.
- Donor coordinate constants are **[O]** at `D:scripts/dmscript.global:170-173`:
  `gc_pixels_to_meter = 26.6666666`, `gc_meters_to_tile = 2`,
  `gc_pixels_to_tile = 53.3333333`, `gc_tiles_to_pixels = 0.01875`. Hence **1 donor tile = 2 m**,
  **1 donor pixel = 1/26.6667 m = 0.0375 m**
  and `1 donor unit radius in pixels / 53.3333 = tiles; ×2 = metres` **[D]**. This is the same
  conversion already verified in `V08_coordinate_scale.md` E5/E6/E26; it is reused, not re-derived.
- Donor class tag values are **[O]** at `D:objects/objects.lib:1-65`: `units=10`, `buildings=20`,
  `misc=30`, `env=40`, `progress=50`; collision tags at `D:scripts/dmscript.global:83-92`:
  `none=0, bridge=10, building=80, terrain=101, water=87, waterborder=110, landborder=109,
  stretchland=85, wall=95` (also `D:scripts/dmscript.global:94-95` test priorities
  `Water=ctpoEqual`, `Land=ctpoGreater`).

### 0.1 Decomp passes performed on the pinned targets

Global active target stayed `c3`; `document` was passed explicitly on every call. Both pinned
documents remained open throughout.

| Pass | Target | Operation | Evidence |
|---|---|---|---|
| 1 | c3 | `native_functions_decompile` on `0x82ec5c, 0x830818, 0x755168, 0x764e04, 0x7550f8, 0x75505c, 0x7cca74, 0x4cb27c` (8/8 succeeded) | `ev_d2db6953a8febd42c1e511e224259a27210d59da3e7068c6d0832bdcd6c5cc82` |
| 2 | c3 | `native_function_pseudocode` (Deep/Ghidra) on `0x4cb27c` — cross-check of strange clean-room branch nesting | `ev_92e03ca4e6166d9235d4d17a790e78440858e888f003b6cc98e52b769bcf8dca` |
| 3 | c3 | `native_function_disassemble` on `0x4cb27c` (82 instructions) — byte-level third pass | `ev_cd3569e966f1a448c96ade93376cd8e16bc3558648bb785bfdcca9e843911f80` |
| 4 | c3 | `native_data_show` f32/u32 at `0x4cb368/0x4cb36c/0x4cb370/0x8fc33c` | this pass (VA table in §2.4) |
| 5 | c3 | `native_xrefs_list` at `0x4cb368` (2 refs, both in `sub_4cb27c`) | `ev_8bc890995de3634eddef921cbb2ff47cbc83862a5a51ef7253469a074f13a031` |
| 6 | c3 | `native_strings_find` for `collision`, `pfx`, `select`, `attack0`, `walk`, `rally`, `ghost` | `ev_b08db4fb10b7f9fc9599f31db035633009d3f3cf3e196911e97f827de44d0966`, `ev_bd1083623cefdcebbc080fc64112145533724087797bae85cff6d43495825ad0`, `ev_ecd991f7649d0fdbd0f8fb135ccc04f863465de0a2fe6cb56d2840e213b4c453`, `ev_3e2df15f9b74a38cd5b317e533866eb3841e698ed3ba9d8c519d3023bc8a0dee` |
| 7 | c3 | `native_functions_search` for `Collision/Pfx/LOD/Select/Effect` (0 game-code names; only Win32 thunks) | this pass — confirms donor logic is in `D:scripts`, not named binary functions |
| 8 | ed | carried cross-check `sub_8c5b78` stamp mirror from `DEC_DEEP_placement_755f30.md` (no new switch) | carried evidence in that report |

**Strange-decomp log (required by ticket):** the clean-room lifter's `0x4cb27c` branch labels
(`loc_4cb314`/`loc_4cb322`/`loc_4cb331`) initially read as an inverted condition because it emits
`fcomp` + `fnstsw ax` + `sahf` + `jae` with signed-flag comments. Three independent passes were
run: clean-room pseudo-C, Deep/Ghidra pseudo-C, and the 82-instruction disassembly. All three agree
once the x87 `jae` is read with the CF/ZF result of `fcomp`: **only when the first compare is below
0** does the second compare select `0x4cb370 (-180)` for `>=0` or `0x4cb36c (+180)` for `<0`.
No branch polarity was guessed. This is the only strange result in this pass's decompiled set;
`sub_4cb27c` has one basic block flag write `[ebx+0x74]=1/0` that is a re-entrancy guard, not
gameplay state **[D]**.

---

## 1. Every donor actor / mesh / material / animation state used by skirmish objects

### 1.1 Resolution chain (authoritative, read-only)

```
D:objects/<race>\<sid>.prop                     (mainproperty.BaseName, actorproperty.LODActorName,
                                                DefaultMeshName, materialproperty.DefaultMaterialName,
                                                UseableMaterials, UseableWinterMaterials,
                                                collisionmaskproperty.Mask,
                                                collisionmeshproperty.CustomBoundingAABB*,
                                                scaleproperty.DefaultScale, autochildrenproperty)
   -> D:actors/actors.lib                       (LODActorName -> LODActorFileName)
   -> D:actors/<race>/\<sid>.actor              (ActorList.Items[n].Name = <sid><suffix>.mesh;
                                                LODList.Items[0].MeshObjects.LoadFromFile = .osm/.oss;
                                                Animations.LoadFromFile = D:animations/aaf/<sid>.aaf)
   -> D:actors/ref/refobj.actor                 (LOD ranges, DistanceMax, visibility)
```
*[O] chain verified for `peaukr` (`D:objects/units/peaukr.prop:1-55`,
`D:actors/units/peaukr.actor:1-7`), `eurmil` (`D:objects/buildings/eurmil.prop:1-114`,
`D:actors/buildings/commoneur/eurmil.actor:1-28`), `engcen`
(`D:objects/buildings/engcen.prop:44-118`) and all 141 env BaseNames in
`X16_prop_mesh_coverage.md` §3 (its E2 chain re-derived in that report).*

### 1.2 Units — actor, mesh, material and tool children

| Class (donor sid example) | Actor / mesh anchor | Material anchor | Child meshes / states | Evidence |
|---|---|---|---|---|
| Peasant `peaukr` | `LODActorName=peaukr`, `DefaultMeshName=peaukr.mesh`, one `LODList.Items[0]` = `peaukr.oss` | `Mesh[0].DefaultMaterialName=peaukr`, `UseableMaterials[0]=peaukr` | `peaukr_tools` auto-child with 7 meshes in fixed order `axe, bag, cart, hammer, hoe, lumber, pick`, all material `peaaustools` | `D:objects/units/peaukr.prop:8-16,22-51`; `D:actors/units/peaukr.actor:5-6` |
| Cannon `cannon` | `cannon.mesh` = `cannon.oss` | `cannon` | two auto-children `cannon_wheel_left.mesh` / `cannon_wheel_right.mesh`, material `cannon`; custom collision AABB ±0.35 X/Z, Y 0.1..0.6 | `D:objects/units/cannon.prop:8-16,22-42,48-55` |
| All 320 unit sids | `D:actors/units/*.actor` (320 `.oss` + 320 `.actor` on disk) | per-sid `*.mat` via `D:materials/materials.lib:6-9` | per-sid tool/attach children declared in each `.prop` | read-only directory census this pass |

- Unit actor defaults **[O]** `D:actors/ref/refunit.actor:1-21`: `ShaderID=21`,
  `ShaderIDNoBones=8`, `ShaderIDIM=14`, `AnimationMode=aamLoop`, `Reference=aarMorph`,
  `FrameInterpolation=afpLSkin`, one `DynamicUniforms` slot `[0].UIndex=1` with `W=0`.
- Unit scale **[O]** `D:objects/ref/refunit.prop:232-245`: `DefaultScale=0.5` on X/Y/Z,
  `RandomScale=False`, `Min=Max=DefaultScaleFactor=1`.
- Direction/up **[O]** `D:objects/ref/refunit.prop:247-270`: `DefaultDirection=(0,1,0)`,
  `DefaultUp=(1,0,0)` (donor is Z-up, direction +Y, up +X), no random pitch/roll/turn.
- Frame-animation defaults **[O]** `D:objects/ref/refunit.prop:218-230`:
  `DefaultFrameAnimationMode=aamLoop`, `FrameAnimationSynchronizeOption=fasoInherited`,
  `FrameAnimationSwitchChildren=True`, `DefaultFrameAnimationCycles=idle`,
  `FrameAnimationCyclesLibName=unit`, `RandomOffset...=acsaDefault`.

### 1.3 Buildings — construction stages, scaffold, death, season material

| State | Donor actor name | Material | Selection rule | Evidence |
|---|---|---|---|---|
| Finished base | `<sid>.mesh` (e.g. `eurmil.mesh`, `engcen.mesh`) | `DefaultMaterialName=<sid>`; `UseSeasonMaterial=True`, `UseableSummerMaterials[0]=<sid>`, `UseableWinterMaterials[0]=<sid>w` | `finished=True` → base actor | `D:objects/buildings/eurmil.prop:13-43` |
| Build stage 0..3 | `<sid>1.mesh`, `<sid>2.mesh`, `<sid>3.mesh`, `<sid>4.mesh` | same as base (per-mesh struct repeats) | `stage = floor(hp/maxhp*4)` clamped 0..3; then `visualtag = stage_0..stage_3`; wall override `stage := 1 + stage div 3` | `D:actors/buildings/commoneur/eurmil.actor:4-19`; `D:scripts/lib/unit.script:6583-6603`; `D:scripts/units/building.inc/ontagstates.inc:240-251` |
| Scaffold child | `<sid>1a..<sid>4a.mesh` (child index 0) | `scaffold` | set only at essential `birth` with an unfinished building, `not bgate`, `GetGameObjectCountChild>0`; hidden on finish | `D:objects/buildings/eurmil.prop:64-104`; `D:objects/buildings/engcen.prop:72-112`; `ontagstates.inc:253-259` |
| Death / ruin | `<sid>_death1.mesh`, `<sid>_death2.mesh` | child `debris` | at essential `death`: stage_0→`_death1`, stage_1→`_death2`; `TXProgressChildrenBehaviour` destroyed, misc children destroyed, remaining children hidden; explosion fired for non-hide visual | `D:actors/buildings/commoneur/eurmil.actor:20-27`; `ontagstates.inc:264-311` |
| Season | `<sid>w` winter variant listed explicitly in `.prop` | `UseSeasonMaterial` | donor engine selects from season state; selection function **[U]** — decomp plan U10 | `D:objects/buildings/eurmil.prop:16-18` |

- Building actor defaults **[O]** `D:objects/ref/refbuilding.prop:74-123`: AABB default
  `[-0.5,-0.5,-0.5] .. [0.5,0.5,0.5]`, sphere 0.5, `UseCustTransformed=True`,
  `CIEnabled=False`, `CIMovable=False`; scale default 0.375 (`:234-247`); selection circle
  size 1, width 0.1, colour white (`:305-321`). `engcen` overrides scale to 0.646
  (`D:objects/buildings/engcen.prop:114-118`); `eurmil` to 0.43 (`eurmil.prop:106-110`).
- **Death-state gap is real [O]:** `P:scripts/world3d_entities.gd:2428-2513` only has a
  birth/stage/scaffold pass; no `_death1/_death2` actor, no `debris` child, no burn smoke
  (see VIDEO_ANIM_3d §3 S2).

### 1.4 Environment props and effects actors

- Env prop defaults **[O]** `D:objects/ref/refenv.prop:76-105`: AABB
  `[-0.5,-0.1,-0.5] .. [0.5,2.0,0.5]`, sphere 0.32, `Detection=True`, `RayCastIntersect=False`,
  `CIMovable=False`, `CIIntersectRadius=0.16`; selection circle size 1 (`:310-320`).
  Per-family `DefaultMeshName`/material and winter alias for all 141 BaseNames are in
  `X16_prop_mesh_coverage.md` §3 C.1 — this report does not restate the 141 rows.
- Projectile props **[O]** `D:objects/ref/refproj.prop:7-30`: `Detection=False`,
  `CollidedStateName=OnCollide`, `CollidedExecRQEn=cerqFull`, FOV 90 for all three lanes,
  `MMNone=True`; `StateMachineInterval=250` (`:32-41`); `AutoOffset=False` (`:51-53`).
- PFX actors **[O]** `D:actors/pfx/{debris,explosion,fire,impact,projectile,shot,trail}/`,
  `D:pfx/manager.lib:1-37` (4 `pfxAnimatedSprite` managers with `ShaderID -2/29/30/31`,
  `Sorting=assMaterial`, `VisibilityCulling=True`, and `trailbullet` = `pfxTrail`).

### 1.5 AAF action ranges and selection rules

**Donor AAF is per sid.** `D:animations/aaf/` contains **194 `.aaf` files** (read-only census
this pass). `D:animations/aaf/peaukr.aaf:1-20` has exactly 18 inclusive `morph` ranges:

| Action | first | last | AAF line | Action | first | last | AAF line |
|---|---:|---:|---:|---|---:|---:|---:|
| idle | 64 | 113 | 3 | idlefood | 405 | 454 | 11 |
| idle0 | 64 | 113 | 4 | idlewood | 354 | 403 | 12 |
| walk | 1 | 20 | 5 | idlestone | 303 | 352 | 13 |
| death | 115 | 149 | 6 | walkfood | 257 | 276 | 14 |
| attack0 | 237 | 254 | 7 | walkwood | 22 | 41 | 15 |
| workfood | 278 | 299 | 8 | walkstone | 43 | 62 | 16 |
| workwood | 237 | 254 | 9 | construct | 186 | 198 | 17 |
| workstone | 217 | 234 | 10 | reaction | 456 | 481 | 18 |
| prepare0 | 64 | 65 | 19 | unprepare0 | 64 | 65 | 20 |

`D:animations/aaf/eurmilanim.aaf:1-4` has one action: `idle 1..249 morph`. The AAF dialect
(bounds inclusive, token `morph`, no loop flag) is documented in `docs/decomp/DC_FORMATS.md:96-109`
and re-confirmed by the raw lines above.

**Per-sid actions actually shipped in the port** (derived this pass from
`P:assets/models/skin/index.json`, 66 entries, and each referenced `*.json.actions`):

| Action | skins exporting it (of 66) | Per-sid note |
|---|---:|---|
| idle | 66 | universal |
| walk | 66 | universal |
| death | 61 | missing on 5 non-combat/support sids |
| attack0 | 56 | e.g. `peaukr [237,254]`, `musketeer18bav` exported |
| idle0 | 51 | |
| walk0 | 15 | |
| attack1 | 14 | **musketeer `attack1` = AAF `musketeer.aaf:7`, frames `[99,124]`, 6 exported frames** |
| construct | 9 | exactly the 9 peasant sids (`peasant, peaukr, peaaus, pearus, peapol, peaeng, peaspa, peasco, peatur`) |
| workfood / workwood / workstone / idlefood / ... / reaction / prepare0 / unprepare0 | 0 | present in donor `peaukr.aaf`, absent from every shipped subset |

This is a *data availability* fact, not a donor selection rule. The donor selection rule is
state-machine driven:

- `D:objects/ref/refunit.prop:156-169` state machine `unit.aix`, default init `Initial`,
  tag-change state `OnTagStates`, interval 100.
- `D:objects/ref/refbuilding.prop:158-171` state machine `building.aix`, interval 33.
- `D:scripts/lib/unit.script:519-545` `SetObjBaseWeapon(...)` binds weapon radius/pause to an
  objprop; attack range is `weapon.radiusmin/radiusmax` in tiles
  (`_unit_GetMinAttackRadiusByObjProp` `:272-286`, `_unit_GetMaxAttackRadius` `:290-311`,
  `_unit_GetAttackRadiusTarget` `:315-339`).
- `D:scripts/units/unit.inc/onaclanimationreachedattack.inc` and `D:scripts/lib/unit.script`
  drive `GameObjectSetFrameAnimationByHandle` from combat states; the exact state→AAF name map
  is a **decomp plan U2**, not a guess. `ACTION_ALIAS` in the port
  (`P:scripts/anim3d.gd:94-96`, `"attack"→"attack0"`) is explicitly a **PORT-LEVEL alias** and
  is not a donor AAF token.

### 1.6 Selection, visibility and material state (donor)

- Selection primitive **[O]** `D:objects/ref/refunit.prop:326-342`: `SelectionOption=stoCircle`,
  `SelectionSize=0.5`, `SelectionAutoScale=True`, `SelectionTerrainCollide=True`,
  `SelectionWidth=0.1`, colour `(1,1,1,1)`. Buildings use size 1 (`refbuilding.prop:305-321`).
- Highlight rendering **[O]** `D:scripts/lib/init.script:101-112` calls
  `GetHighlightRenderSettings(size,dirx,diry,dirz,texs,scaling,visible)` and
  `SetHighlightRenderSettings(...)` — engine-side, private-use textures; no port equivalent exists.
- Mouse pick **[O]** `D:scripts/lib/control.script:156-199`:
  `GameObjectRayCastMouseRay` → `GameObjectSortRayCastList` → for each hit require
  `GetGameObjectPlayableObjectByHandle` ∧ `GetGameObjectVisibleByHandle` ∧
  `GetGameObjectCollisionDetectionByHandle`, then `GetGameObjectRayCastAABBByHandle(goHnd, cameraPos, mouseWorldPos)`,
  then nearest-by-`_misc_GetDistancePos` with a per-baseid priority (`prio=0.5` seed).
- Per-instance material **[O]** `D:scripts/units/building.inc/ontagstates.inc:261-262,306-307`:
  `_misc_ApplyKeyColorRecursiveChild(myHnd, gMap.players[arg_obj.pl].color)` is applied to the
  building **and its children** at both birth and death; scaffold child material is `scaffold`,
  ruin child material `debris` (`:257,286`). Key colours: 13 slots, `D:scripts/lib/misc.script:5070`
  guard (cited in `P:scripts/world3d_fx.gd:1545-1552`).
- Field material names **[O]** `P:scripts/world3d_entities.gd:328` =
  `field1..field4` growth + `field/fieldw` mature; donor source is
  `D:materials/env/env.mat` and `D:objects/env/envfieldd/w.png` (cited in `MILLFIX_rotor_fields.md`
  §1 and `world3d_entities.gd:318-322`). Exact donor HP→material thresholds are carried as
  **PORT APPROXIMATION** in `world3d_entities.gd:329-332` (`25000/5000/13000`); donor threshold
  source **[U]** U11.

---

## 2. Exact collision model by class, and port mapping

### 2.1 Unit collision (donor text/byte exact [O]; NOT visual parity)

`D:objects/ref/refunit.prop:73-121` is authoritative:

| Field | Value | Meaning |
|---|---|---|
| `BoundingMode` | `cbmAABB`, `BoundingData=cbdCustom`, `BoundingSpace=cbsProj` | projected custom AABB |
| `CustomBoundingAABBMin/Max` | `(-0.25,-0.10,-0.25)` → `(0.25,0.90,0.25)` | donor metres, Z-up |
| `CustomBoundingSphere` | `0.32` | broadphase sphere, donor metres |
| `UseCustAABBinSP` | `True`, `UseCustTransformed=False` | AABB used in spatial partition |
| `CIEnabled/CIMovable/CIMass` | `True / True / 1` | collision inertia enabled, movable |
| `CIIntersectRadius` | `0.16` | inertia separation radius, donor metres |
| `CIMaxDistKoef / CIDeltaStep / CIRotationSpeed` | `2 / 0.005 / 5` | inertia solver |
| `CIStuckAngle / CIEpsilonAngle / CIEpsilonShift / CIEpsilonMove / CIDistExtPointEpsilon` | `5 / 4 / 0.001 / 0.02 / 0.005` | inertia thresholds |
| `CIAvoidPointMaxAngle / CIMaxCollideCounter` | `60 / 7` | avoidance |
| `UncollideDelta` | `0.05` | separation epsilon |
| `MoveProperty` | `MoveStep=0.03`, `MoveStepInterval=25`, `EpsilonDistance=0.25` (`:172-184`) | 0.03 m per 25 ms |
| `RotateProperty` | `TurnStep=10`, `TurnStepInterval=50`, `EpsilonAngle=10` (`:186-198`) | 10° per 50 ms = **200°/s** |

Gameplay radius is authored in script via `gc_obj_radius_*` pixels
(`D:scripts/dmscript.global:665-678`) converted by `_misc_PixelsToTiles`
(`D:scripts/lib/misc.script:462-466`). Exact values **[O]+[D]**:

| Radius class | Donor pixels | Tiles | Metres | Source |
|---|---:|---:|---:|---|
| default (infantry/peasant) | 10 | 0.1875 | **0.375** | `dmscript.global:665`, `unit.script` general |
| horse | 15 | 0.28125 | **0.5625** | `:666`, `unit.script:1323,1421,1547,1667` |
| artillery | 15 | 0.28125 | **0.5625** | `:667`, `unit.script:1700,1736,1769,1797,1827` |
| formation default / horse | 8 / 12 | 0.15 / 0.225 | **0.30 / 0.45** | `:677-678` |
| ship fishboat / ferry / yacht / yachttur / chaika / galley / frigate / xebec / battleship | 40 / 70 / 35 / 50 / 45 / 80 / 90 / 80 / 90 | 0.75 / 1.3125 / 0.65625 / 0.9375 / 0.84375 / 1.5 / 1.6875 / 1.5 / 1.6875 | **1.5 / 2.625 / 1.3125 / 1.875 / 1.6875 / 3.0 / 3.375 / 3.0 / 3.375** | `:668-676` |
| `gc_unit_meleeattackradius` | — | — | `3.5` tiles = 7 m | `:197`, `unit.script:244,544` |
| `gc_objectEpsilonDist` | — | — | `0.25` m | `:817-818` |

**Port mapping required:** `P:scripts/data.gd:645,654,...` currently use `0.35` for default
infantry (donor `0.375`), `0.5/0.6` for other land classes (donor `0.5625` for horse/artillery),
`1.8` for yacht (donor `1.3125`), `1.0` for fishboat (donor `1.5`) — all **PORT APPROXIMATION**.
`P:scripts/game.gd:545-558` `set_blocked_circle()` must consume the donor radii above, not the
approximate table, and `P:scripts/game.gd:1934-1939` `pick_radius()` must use donor
`SelectionSize` + AABB/pick semantics rather than `+1.4 m` grab margin.

### 2.2 Building collision (donor text/byte exact [O]; NOT visual parity)

- **Collision mask** is an explicit character grid of `0/1` rows in `collisionmaskproperty.Mask`,
  not a derived circle. Examples **[O]**:
  - `D:objects/buildings/eurmil.prop:45-53` = 5×5 diamond
    `00100 / 01110 / 11111 / 01110 / 00100`.
  - `D:objects/buildings/engcen.prop:45-60` = 13×13 near-solid footprint
    (`00000111100000` … `11111111111100` … `00000000000000`).
  - A read-only scan of all `D:objects/buildings/*.prop` found **245 distinct mask row-groups**
    (walls `11`, gates `100001/100001`, irregular ruins etc.). The exact per-sid mask must be
    exported from the `.prop`, never approximated by a single circle.
- Mask bounds rule **[O]** `D:scripts/dmscript.global:178`: `gc_collision_size = 0.5`
  (one mask cell = 0.5 map cell = 1 m at `gc_meters_to_tile=2`). Mask cell size→world origin
  alignment **[U]** U12.
- AABB overrides **[O]** `eurmil.prop:55-62` `(-0.70,-0.15,-0.60)..(0.60,2.20,0.65)`;
  `engcen.prop:63-70` `(-2.15,0.20,-1.30)..(1.85,2.40,2.65)`. With `DefaultScale` 0.43 / 0.646
  respectively. `UseCustTransformed=True` for buildings (`refbuilding.prop:99`).
- Circle-vs-rect primitive **[O]** `D:scripts/lib/misc.script:2384-2417`
  `_misc_CircleIntersectRect(x1,y1,x2,y2,x,y,r)` = standard clamped-point distance
  `((clamp(x,x1,x2)-x)^2 + (clamp(y,y1,y2)-y)^2) <= r^2`. The only script caller is the scan-grid
  list (`:2493`); building occupancy itself is the mask + `CI` engine path. Do **not** claim this
  function is the building footprint test.
- Occupancy code **[O]** (c3 decomp) `sub_764e04 @0x764e04` bounds-checks
  `0<=edx<[obj+0xa4]` and `0<=ecx<[obj+0xa0]` then writes `arg_8` into
  `rowTable[[obj+0xa8]][edx][ecx]`; `sub_755168` adjusts by `(W-1)>>1/(H-1)>>1`;
  `sub_7550f8` is the pure -half..+half bounds test; `sub_75505c` additionally checks
  `[esi+0x65]` and writes the occupant id at `+0x1c`
  (`ev_d2db6953...`, `sub_82ec5c` 24-byte getter with row table `+0x14`, stride `0x18`,
  bounds `[0,W)×[0,H)`, default from `0x8fc33c`).
- **Port mapping debt:** `P:scripts/game.gd:1894-1929` derives the impassable rectangle from the
  *2D sprite ink box* (`ortho/ink/cx/foot` from `buildings.json`), and
  `game.gd:215-252` `_blocked_for()` uses `Rect2.has_point(p)` on that rectangle. The donor-faithful
  replacement is: build the occupancy set from each `.prop` `Mask` (bitmap rows → world cells at
  0.5 cell/mask cell), use donor AABB for the broadphase and keep the `+0x1c` occupant semantics;
  no ink-box rectangle. This is a real, specifiable replacement, not a fallback.

### 2.3 Terrain / water tags and line of sight

- **Collision tags [O]** `D:scripts/dmscript.global:83-92` (table in §0). Runtime use **[O]**:
  `D:scripts/units/unit.inc/onendpointreached.inc:10-11` compares
  `GetMapCollisionTag(x,z,false)=gc_collisiontag_water` for amphibious landing;
  `D:scripts/lib/control.script:414-415` uses `RayCastWater(x,z,y)` then `RayCastHeight(x,z)`;
  `D:scripts/lib/weapon.script:1209` and `:929` use `RayCastHeight` and `RayCastWater` behaviour.
  `SetTerrainRayCastPrecison(0.0000001)` **[O]** `D:scripts/lib/init.script:101`.
- **Line of sight [O] (script surface):** `D:scripts/misc/projectile.inc/nothing.inc:55-56`
  calls `OctreeRayCastIntersect(trgHnd, sx,sy,sz, dx,dy,dz, px,py,pz, nx,ny,nz)`;
  `D:scripts/lib/player.script:509` disables `SetGameObjectRayCastIntersectEnabledByHandle`;
  `D:scripts/lib/unit.script:11805` re-enables it for transport trap opening; pick LOS is the
  `GetGameObjectRayCastAABBByHandle` chain in `control.script:181-184`. The *implementation*
  of `OctreeRayCastIntersect`/`GetGameObjectRayCastAABBByHandle` is engine-side and untyped
  **[U] U13** — decomp plan in §6.
- **Port mapping debt:** `P:scripts/game.gd:530-540` encodes water as `terrain[...] == 3`
  (a renderer enum), not donor tag `87`/`110`/`85`; `_blocked_for()` `:218-223` treats water as
  hard blocker for land and land as wall for naval; `game.gd:537-540` has no `waterborder` or
  `stretchland` handling. `P:scripts/picking3d.gd:145-168` marches a ray against the bilinear
  height field — that is terrain raycast only, **not** entity LOS. No port function implements
  `OctreeRayCastIntersect` or the donor priority/`ctpoEqual` vs `ctpoGreater` test.

### 2.4 Actor submit / final angle (binary decomp, cross-checked)

`sub_7cca74 @0x7cca74` is a 6-instruction trampoline to `sub_4cb27c @0x4cb27c`
(`ev_d2db6953...`). Three passes agree on the body **[O]**:

1. `[ebx+0x74] = 1` re-entrancy flag; `sub_4a64e4(arg_8)`.
2. `movsd` ×4 copies a 16-byte transform from `[ebx+0x48]+0x1c` to stack;
   `sub_890b6c`/`sub_890b8c` twice (for `[ebx+0x4c]` and `[ebx+0x48]`) — likely matrix
   composition **[I]**.
3. `sub_4ca558` → three floats → `sub_4a31c8`, `sub_4a6838`, `sub_4a6520`, `fchs` → angle.
4. `fcomp [0x4cb368]`; only if below zero, `fcomp [0x4cb368]` on the second float selects
   `[0x4cb370] - angle` when `>=0` or `[0x4cb36c] - angle` when `<0`.
   Constants **[O]** `0x4cb368 = 0.0f`, `0x4cb36c = 180.0f`, `0x4cb370 = -180.0f`
   (2 xrefs, both in `sub_4cb27c`; `ev_8bc89099...`).
5. `sub_890d34(edx=2, angle)`, flag cleared, then `(**(code**)(*obj+0xa8))()` virtual submit.

This is the concrete donor "final turn" alluded to in `DEC_DEEP_placement_755f30.md` §3; its
exact argument contract is **[U] U1** (§6). It is the correct place to resolve donor yaw/face
semantics before changing `P:scripts/world3d_entities.gd:1766-1772,2117-2159`.

---

## 3. FX — donor parameters and port gaps

### 3.1 Donor effect library (24 named effects, `D:pfx/fx.tree:1-538`)

`shotmusket`, `shotmusketcav`, `shotmusketking`, `shotmusketdrag`, `shotcannon`, `shothowitzer`,
`shotmortar`, `shotmcannon`, `grenadeexp`, `impactsmoke`, `impactdust`, `cannonexpground`,
`cannonexpbuilding`, `howitzerexpground`, `howitzerexpbuilding`, `bullettrail`, `firearrowtrail`,
`fragtrail`, `expflash`, `buildingsmoke`, `shottower`, `shotmusketpoint`, `waterblast`,
`waterblastsmall`.

- **`shotmusket` composition [O]** (`fx.tree:4-63`): five children —
  `musketsmoke` (randmirrorv=1, randframerate=2 with −20..20, randpixelratio=3 with −25..25,
  randposition=3 with Y −0.1..0.1, randscale=4 with stop.y=0.05), `musketflash`
  (randanimation=1, randmirrorv=2), `musketsparks` (same), `musketsmokeup`
  (randmirroru=1, framerate 0..50, pixelratio 0..50), `musketflashup`
  (randanimation=1, mirroru=2, mirrorv=3, framerate 0..50, pixelratio 0..50).
- **`musketsmoke` source [O]** `D:pfx/source.pfx:30-64`: `LibManagerName=aspriteshader31`,
  `StartFrame=0`, `EndFrame=127`, `FrameWidth=256`, `FrameHeight=128`, `ImageWidth/Height=2048`,
  `Interval=10`, `FrameRate=100`, `PixelRatio=175`, `MirrorU=True`,
  `Position=(-0.1,-1.5,0.775)`, `OnEndFrameState=FreeToPool`, `AlphaTime=1.5`, `AlphaPower=1.5`.
  `musketflash` **[O]** `source.pfx:105-177`: 4 frames, `Interval=100`, `FrameRate=10`,
  `PixelRatio=350`, `OnEndFrameHide=True`.
- **`bullettrail` [O]** `source.pfx:1734-1763`: `VertLimit=150`, `TimeLimit=0.2`,
  `MinDistance=0.05`, `Alpha=0.2`, `AlphaFade=True`, `MarkStyle=msFaceCamera`,
  `MarkWidth=0.1`, `ZWrite=False`, `Diffuse(1,1,1,1)`. `firearrowtrail` `Alpha=0.3`
  (`:2307-2343`), `fragtrail` `MarkWidth=0.05` (`:1783`).
- **`buildingsmoke` [O]** `fx.tree:417-442`: `parentrandom=true`, four children
  `buildingfirestart`, `buildingsmokestart`, `buildingfire`, `buildingsmoke` (all `randmirroru=2`);
  sources at `source.pfx:1808-2199`. This is the donor burning-building state effect seen in
  VIDEO_ANIM_3d §1.5, and is **not wired to building state** by the port.
- **Selection of effects by weapon/medium [O]** `D:scripts/lib/weapon.script:260-299`:
  `cFXTrailArrow='bullettrail'`, `cFXTrailFireArrow='firearrowtrail'`,
  `cFXTrailHowitzerBallFragment/DebrisWood/DebrisStone='fragtrail'`,
  `cFXImpDust='impactdust'`, `cFXImpDustBuilding='impactsmoke'`,
  `cFXImpWaterSmall/Large='waterblastsmall'/'waterblast'`,
  `cFXCannonExp='cannonexpground'`, `cFXCannonExpBuilding='cannonexpbuilding'`,
  `cFXBuildingExp='grenadeexp'`, `cFXTower='shottower'`.
  Custom per-medium explosions **[O]** `weapon.script:573-612` keyed by
  `gc_obj_explmedia_{building,grass,water,wood,ship}` with counts e.g. `PUEXP` building/wood
  `5..9` debriswood, ship `4..4` (debriswood×3 + KAPEZ).
- **FX randomisation rule [O]** `D:scripts/lib/pfx.script:39-86`: exactly **8** random floats
  (`rand[0..7]`); codes `1..8` select the float (ClampInt(code-1,0,7)). MirrorU/MirrorV use
  `Round(rand[i])=1`; AnimationIndex `Round(rand[i]*(n-1))` when `AnimationsCount>1`;
  FrameRate/PixelRatio/Position/Scale get `Lerp(start,stop,rand[i])` deltas. `parentrandom=true`
  shares one `fRand[8]` across all children (`:206-228,231-252`). Effect offset is added after
  randomisation (`:223-227`). This is a precise, implementable rule — the port has **no RNG by
  design** (`P:scripts/world3d_fx.gd:31`) and explicitly records `randanimation/randmirrorv`
  as "RECORDED, not reproduced" (`:218-221`), i.e. a real gap.

### 3.2 Weather (donor text/byte exact [O]; NOT visual parity)

- `D:env/clouds/clouds.weather:1-23`: `Active=True`, `Weather=40`, `WeatherTarget=40`,
  `WeatherIntervalTarget=1`, `WeatherRandom=False`, `WindVector=(-0.74211645,0,-0.86726564,1)`,
  `WindIntervalTarget=5482`, `WindRandom=False`, `weatherrandomstart=0`, `weatherrandomend=99`.
- `D:env/pfx/particles.snow.cfg:1-39` (snow1; snow2..4 repeat the shape): `Height=Width=0.0015`,
  `AlphaChannel=0.5`, `NoZWrite=True`, `Rotation=62048.2890625`, `RotationSpeed=0`,
  `SpiralRotatingRadius=0.1`, `SpiralRotatingSpeed=20`, `BillboardType=btBillboard`,
  `CreatingCubeStart=(+0.5,+0.5,+0.5)`, `CreatingCubeEnd=(-0.5,-0.5,-0.5)`,
  `MoveDirection=(0,-1,0)`, `WeatherStart=70`, `WeatherEnd=100`, `MonthStart=1`, `MonthEnd=12`,
  `Speed=0.041`, `Count=100`, `CameraSpeedFactor=0.1`. Snow2/3/4 Speed `0.061/0.08/0.1`,
  Count `100/100/200`, sizes `0.002/0.00251/0.003`.
- **[D]** With shipped `Weather=40 < WeatherStart=70`, the snow band is inactive — this matches
  the port gate (`P:scripts/world3d_fx.gd:167-184,947-1009`).
- **Port gaps:** no wind vector integration, no `SpiralRotating*`, no `CameraSpeedFactor`,
  no `Rotation`, no per-emitter cube bounds, no snow material (`Snow*.bmp` uncopied) — the port
  uses a plain white billboard quad and an invented 8 s lifetime (`:184`).

### 3.3 Ghost / rally / selection (donor surface, engine-side)

- Donor ghost is a *construction dummy*: `D:objects/misc/constructiondummy.prop` exists
  (`D:objects/misc/` census); donor colour/blink policy is carried in prior F02/DBUILD reports
  as **[I]**; the 2D port `draw_ghost` uses `world.gd:3509` green/red
  (`P:scripts/world3d_fx.gd:143-144,582-606`). Exact donor ghost actor + colour + blink parameters
  **[U] U14**.
- Rally marker donor art is `rallypoint.dds` (private-use, cited at
  `P:scripts/world3d_fx.gd:709-710` from `world.gd:3602-3604`); donor object is
  `D:objects/misc/rallypoint.prop:1-30` with `DefaultScale=0.0525` and
  `OffsetCollideOption=ocoTerrainWater`, `DefaultRollAngle=45`. Port uses a procedural pole +
  finial + colour pennant (`:1201-1232`), TTL 2 s (`:161`) — donor TTL **[U] U14**.
- Selection donor uses `ring_sel.png`/`ring_p0.png` overlays and `Get/SetHighlightRenderSettings`
  (§1.6); port uses procedural TorusMesh rings (`:1256-1353`). Both are PORT APPROXIMATION.
- **Construction/destruction FX:** donor has scaffold child + `debris` ruin child + `_unit_DoExplosion`
  at death (`ontagstates.inc:264-311`) and explicitly *no* construction dust particle class
  (DFX-01 §7.4 carried by `world3d_fx.gd:64`). Port has scaffold but no ruin/burn/debris pass;
  `buildingsmoke` child effects are never attached.

### 3.4 FX port gap summary (no parity claim)

| Donor class | Donor parameters | Port state | Required donor-faithful replacement |
|---|---|---|---|
| Volley smoke | `shotmusket` 5 children, `AlphaTime=1.5`, `AlphaPower=1.5`, pixelratio 175/600, rand codes | two plain quads `volley_smoke` (`world3d_fx.gd:1160-1175`), opt-in flag false (`:252`) | export the 5-layer composition, apply 8-float RNG codes, donor DDS sheets, and `PixelRatio` scale after U3 conversion |
| Muzzle flash | 4 frames, `FrameRate=10`, `OnEndFrameHide`, randanimation/randmirrorv | one additive quad, alpha HOLD (`:1176-1187,1403-1406`) | 4-frame animation, hide-on-end, RNG mirror codes |
| Trails | `msFaceCamera`, `TimeLimit=0.2`, `Alpha=0.2/0.3`, `MarkWidth=0.1/0.05`, `VertLimit=150` | billboard quad with invented 1.2 m streak (`:1188-1198,1451-1475`) | face-camera ribbon with donor MinDistance/VertLimit; streak length from donor source, not invented |
| Fire/smoke on buildings | `buildingsmoke` 4 layers, `parentrandom=true` | no building-state attach | attach on destroyed/burning state; swap to `_death1/2` + debris child |
| Weather | wind, spiral, camera factor, 4 emitters | gate correct, visuals stand-in | reproduce 4 emitters and all keys after U4; wind vector from `clouds.weather` |
| Ghost/rally/selection | dummy + key colour, `rallypoint.dds`, highlight textures | procedural primitives | after U14: donor art/params; key colour is already correct source (13 slots) |

---

## 4. LOD / selection / visibility / instancing / per-instance material state

### 4.1 Donor LOD (exact, from actor ref data)

`D:actors/ref/refobj.actor:36-52` **[O]**:
`ShaderLODList.Enabled=True`, `ChildPooled=poFull`, `ChildPoolMax=2500`,
`List[0].ShaderID=-1, ShaderIDNoBones=-1, ShaderIDIM=-2, MinDist=0, MaxDist=2500,
MinDistIM=0, MaxDistIM=2500`; `DistanceMax=2500`; `VisibilityCulling=vcInherited`,
`Visible=True`, `ObjectsSorting=osInherited`, `RenderOptimizeOptions.baroCompileFrameOnRequest=True`.
`D:actors/ref/refobj.actor:88-105` **[O]**:
`LODIndex=0`, `ActorIndex=0`, `LODList.Items[0].ScaleFrames=1`, `DistanceMin=0`,
`DistanceMax=150`, `Impostored=False`.
Per-sid overrides (e.g. `peaukr.actor:2-3` sets `ShaderID=18, ShaderIDIM=11`;
`refunit.actor:2-4` sets `21/8/14`) exist; a full per-actor LOD table is **[U] U5**.

This upgrades the carried **[D]** LOD numbers in `DEC_DEEP_placement_755f30.md` §7 to
donor-data **[O]** for the two range values `0..150` and `0..2500`.

### 4.2 Donor selection/visibility rules

- `VisibilityCulling=vcInherited`, `Visible=True` (`refobj.actor:59-60`).
- `pfx/manager.lib:6,14,22,30,36` all `VisibilityCulling=True`.
- Pick eligibility requires playable ∧ visible ∧ collision-detection ∧ AABB ray hit
  (`control.script:181-184`); donor collision mask priority `80` for buildings
  (`refbuilding.prop:43`) vs `0` for units (`refunit.prop:44`), building CI disabled
  (`refbuilding.prop:105`) vs unit CI enabled (`refunit.prop:104`).
- Placement visibility is **mask/bounds driven, not frustum driven** inside `sub_755f30`
  (`DEC_DEEP_placement_755f30.md` §7, carried [D]); distance culls live behind the submit.

### 4.3 Donor instancing / submit topology

- `sub_755f30` pays per surviving cell a 24/16/13-byte copy, a normalise
  (`sub_755bc8`/`755d1c`/`755c6c`), an 8-way quadrant dispatch into `sub_59b8a4`/`59b854`,
  up to four submits and four `sub_755578` fixups, ending at `sub_7cca74→sub_4cb27c`
  (`DEC_DEEP_placement_755f30.md` §3-§6 + this pass's decomp).
- **This per-corner submit pattern is a DONT-PORT performance trap** (DEC_DEEP §9): it is not a
  visual property. A 1:1 port must reproduce the *visible* per-instance state (transform,
  material/LOD/visibility), not the call count. Using `MultiMeshInstance3D` is acceptable
  **only if** it carries donor LOD/visibility/material semantics exactly; otherwise it is a
  PORT APPROXIMATION. The port currently does **not**: `P:scripts/world3d_entities.gd:1923-1968`
  has no `visibility_range`, no LOD bucket, one material per batch.

### 4.4 Port instancing / per-instance material state (read-only)

- Batching key: `unit|sid[|p<player>]` (`:2191-2195`) and morph key
  `unit|sid[|pN]|a<action>|f<frame>` (`:2692-2702`); resources `res|sid` /
  `res|field|<material>` (`:2556-2564`).
- `BATCH_CAPACITY=4096`, `BATCH_INITIAL_CAPACITY=64`, `HIDDEN_SCALE=0.0001`
  (`:118,121,122`); geometric growth (`:1976-1996`); O(1) swap-remove with CPU transform mirror
  (`:2041-2079`). All are port efficiency measures, **not donor semantics**.
- Per-instance material: `mm.use_colors` only for field batches (`:1932-1937`),
  `material_override=_field_crop_material(spec)` (`:1957`), player tint via shared
  `ShaderMaterial` (`_tinted_material`/`_apply_tint` `:1489-1551`), field instance colour pinned
  to `Color(1,1,1,1)` (`:2857`). Donor per-instance state instead comes from
  `_misc_ApplyKeyColorRecursiveChild` (key colour on building + children), `UseSeasonMaterial`
  (summer/winter per mesh), and `scaffold`/`debris` child materials.
- Visibility: `_is_hidden()` `:2105-2114` mirrors `world.gd:2712-2713` (exhausted finite
  resources); `HIDDEN_SCALE` used in `_xf()` `:2155`. No LOD and no donor `VisibilityCulling`
  equivalent. No instancing for FX: each FX is its own `Node3D` with new mesh/material
  (`world3d_fx.gd:538-553,1102-1199`) and a port cap of 220 (`:114,1508-1516`).

---

## 5. Line-by-line port diff — exact file/line and required donor-faithful replacement

Each row: port line(s), what is there **[O]**, donor fact **[O]/[D]**, and the exact replacement
algorithm. **No row claims the replacement is already implemented.**

| # | Port file:line | Current port code/state | Donor fact (evidence) | Required donor-faithful replacement |
|---:|---|---|---|---|
| D1 | `P:scripts/anim3d.gd:71-90` | `AAF_ACTIONS` hardcodes the 18 *peaukr* ranges for every sid that has no shipped skin | AAF is per sid; 194 `.aaf` files; musketeer `walk 1..24`, `attack1 99..124` (`D:animations/aaf/musketeer.aaf:3,7`; shipped `skin/musketeer.json`) | Resolve ranges from the resolved sid's own AAF (converter already emits per-sid `actions`); remove the peaukr fallback or gate it behind an explicit "sid unknown" failure, never silent reuse |
| D2 | `P:scripts/anim3d.gd:94-96` | `ACTION_ALIAS {"attack":"attack0"}` | No `attack` token in any AAF; sim/order state must map to `attack0`/`attack1` by weapon and state (`weapon.script:260-299`, `unit.script` state machine) | Keep the alias only as a sim→donor name bridge and add the missing `attack1` branch selected by weapon/order; document that donor has no such alias |
| D3 | `P:scripts/anim3d.gd:634-640` | `_frame_at` = `fposmod(t*30, span)` loop | AAF rows carry only `morph`; loop/clamp flag **[U] U2** | After U2, implement donor loop/clamp exactly; until then mark `visual UNVERIFIED`, do not treat loop as donor-proven |
| D4 | `P:scripts/anim3d.gd:66,196` | `BLOCKED_RIG` flat-root skin; bone parents unreadable | Donor `.oss` has per-bone tracks; parent hierarchy **[U] U0** | Decomp parent table (U0) and apply full hierarchy; remove `BLOCKED_RIG` only after proof |
| D5 | `P:scripts/world3d_entities.gd:1719-1741` | `_unit_action` selects only `death/construct/walk/idle` | 9 shipped peasant sids export `construct`; 56 export `attack0`, 14 `attack1`; donor AAF also has work/carry/reaction | Add `attack0/attack1` (weapon/order-gated) and `workfood/workwood/workstone|walkfood|walkwood|walkstone|reaction` branches, gated by per-sid `actions` availability; extend skin export for missing work frames (no fallback to idle) |
| D6 | `P:scripts/world3d_entities.gd:252` | `WALK_SPEED_GATE_M_S=0.15` | Donor has no such port gate; donor `MoveStep/MoveStepInterval=0.03/25` (`refunit.prop:176-177`) | Derive walk/idle from donor state machine; if a measurement gate remains, source its constant from donor MoveProperty, not 0.15 |
| D7 | `P:scripts/world3d_entities.gd:253,1766-1772` | `YAW_MAX_RATE_RAD_S=45°/s` clamp | Donor `TurnStep=10°`, `TurnStepInterval=50ms` = **200°/s** (`refunit.prop:190-191`) + final angle wrap in `sub_4cb27c` (§2.4) | Replace clamp with donor turn-rate and wrap constants 0/±180 after U1 settles `sub_890d34` argument contract |
| D8 | `P:scripts/world3d_entities.gd:2117-2159` | `yaw = PI/2 - face` | Donor direction/up `(0,1,0)/(1,0,0)`, renderer final turn **[U] U1** | Bind yaw to the donor submit contract once decompiled; do not keep the 2D-bake-derived `PI/2` offset |
| D9 | `P:scripts/world3d_entities.gd:1923-1968` | MultiMesh batches with no LOD/visibility | Donor `0..150` mesh, `0..2500` shader/pool, `VisibilityCulling=vcInherited` (`refobj.actor:36-60,88-105`) | Add donor `visibility_range` buckets + shader-LOD/pool mapping per actor; retain batching only as submit topology |
| D10 | `P:scripts/world3d_entities.gd:2367-2388` | stage from `progress/build_time` | stage = `floor(hp/maxhp*4)` (`unit.script:6583-6596`); wall `1+stage div 3` (`ontagstates.inc:247-248`) | Use hp/maxhp; keep wall rule; clamp exactly as donor; remove `build_time` as stage source |
| D11 | `P:scripts/world3d_entities.gd:2428-2513` | scaffold only; no ruin/death/burn | `_death1/_death2` + `debris` child + `buildingsmoke` 4-layer effect (`eurmil.actor:20-27`, `ontagstates.inc:264-311`, `fx.tree:417-442`) | Add donor death-state pass (mesh swap, debris child, misc-child clear, explosion) and building-smoke attach; remove hidden-placeholder approximation |
| D12 | `P:scripts/world3d_entities.gd:2266-2366,2756` | rotor = 2D bake quad on billboard, `_anim_t*0.75` | Donor 3D attach `eurmilanim.oss` 1098 verts, `idle 1..249` (`eurmilanim.aaf:3`; MILLFIX §1) | Convert the donor attach mesh and rotate about the proven local axle; spin sign remains **[U] U6** until donor 3D direction is decompiled |
| D13 | `P:scripts/world3d_entities.gd:328-332,2785-2897` | field growth via port HP thresholds 25000/5000/13000 | Donor material names `field1..7`, season `envfieldd/w`; exact HP thresholds **[U] U11** | After U11, bind donor thresholds and season selection; remove port-only tint/scale interpolation already labelled absent |
| D14 | `P:scripts/world3d_fx.gd:97-112,561-577` | `LIFE` table port values; `add_impact_fx` maps only 3 keys; opt-in flags false | 24 donor effects with interval/pixelratio/alpha keys (`fx.tree`, `source.pfx`) | Implement the full effect library with donor keys; remove port `LIFE` table and opt-in gates |
| D15 | `P:scripts/world3d_fx.gd:218-221` | RNG codes recorded but not reproduced | `pfx.script:39-86` exact 8-float rule | Implement the 8-float RNG + codes with donor stream isolation; document seed source (donor `Random`/`RandomExt` **[U] U7**) |
| D16 | `P:scripts/world3d_fx.gd:1102-1199` | plain quads/spheres for smoke/flash/trail | donor animated-sprite sheets, 4-frame flash, `msFaceCamera` ribbon | Use donor sprite strips/animations and parameters after U3/U4; no stand-in quads |
| D17 | `P:scripts/world3d_fx.gd:582-606,711-732,1256-1353` | green/red ghost, procedural rally, procedural selection rings | key colour applied recursively; `rallypoint.dds`; highlight textures (`ontagstates.inc:261-262`, `init.script:101-112`) | After U14, adopt donor dummy/flag/ring art and TTL; retain 13-slot key colour source (already donor-aligned) |
| D18 | `P:scripts/world3d_fx.gd:167-184,947-1009` | snow gated but visuals are white quads; spiral/wind absent | `clouds.weather`, `particles.snow.cfg` full key set (§3.2) | Implement 4 emitters with wind/spiral/camera-factor/material keys; gate stays donor-derived |
| D19 | `P:scripts/world3d_fx.gd:114,1508-1516` | FX cap 220 port value | Donor PFX pooling via `OnEndFrameState=FreeToPool` / manager types (`manager.lib`, `source.pfx:60`) | Replace fixed cap with donor pool/manager behaviour; removal policy from donor `FreeToPool` |
| D20 | `P:scripts/picking3d.gd:39-43,248-330` | `RES_REACH_M=2.5`, `FALLBACK_REACH_M=2.0`, screen-space reach from `pick_radius()` | donor playable∧visible∧collision ∧ `GetGameObjectRayCastAABBByHandle`, per-baseid priority (`control.script:156-199`) | Implement donor eligibility chain and AABB ray test with donor radii/priority; remove +1.4 m grab margin (`game.gd:1934-1939`) |
| D21 | `P:scripts/game.gd:1894-1929,215-252` | building rect from 2D ink box; `Rect2.has_point` | per-`.prop` collision mask grid (5×5 mill, 13×13 hall), mask cell 0.5 map cell, occupant slot `+0x1c` (`eurmil.prop:45-53`, `engcen.prop:45-60`, `dmscript.global:178`, `sub_764e04`) | Export masks and build occupancy set; use donor AABB broadphase and mask-based blocker test; drop ink-box rect |
| D22 | `P:scripts/game.gd:530-540,537-540` | water = `terrain==3`, no waterborder/stretchland | donor tags `water=87, waterborder=110, stretchland=85, landborder=109`, test priorities `ctpoEqual/ctpoGreater` (`dmscript.global:83-95`) | Read donor collision tags and implement tag-based land/water tests incl. border/stretch semantics |
| D23 | `P:scripts/game.gd:545-558`, `data.gd:645,654,692,729,1217,1239,1250` | blocked circle + approximate radii table | exact radii table §2.1 | Replace radius constants with donor pixel-derived metres and store them as the single source for collision, pick and animation |
| D24 | `P:scripts/game.gd` (no function) / `picking3d.gd:145-168` | no entity LOS; only height-field ray march | `OctreeRayCastIntersect`, `RayCastIntersectEnabled`, `GetGameObjectRayCastAABBByHandle`, `SetTerrainRayCastPrecison(1e-7)` | Implement donor ray cast + priority/FOV test after U13; keep terrain ray precision donor value |
| D25 | `P:scripts/world3d_entities.gd:1489-1551,1954-1961` | one material per batch, player tint shader, field colours | `UseSeasonMaterial` + summer/winter lists, `_misc_ApplyKeyColorRecursiveChild`, scaffold/debris materials (`eurmil.prop:16-18`, `ontagstates.inc:257,286,261-262`) | Bind per-mesh season material and recursive key colour; scaffold/debris material per donor; per-instance colour only where donor has it |

**Cross-report note:** `PORT1TO1_skirmish_logic.md` §14 lists port approximations for sim logic
(game/data/orders/RNG). Rows D6/D20-D24 above extend that list into the rendering/collision
layers. Neither report claims any row is already fixed.

---

## 6. Explicit `[U]` register — each with a decomp plan (no fallback)

| ID | Unknown | Why unresolved | Decomp plan (concrete, no fallback) | What settles it |
|---|---|---|---|---|
| U0 | Donor bone parent hierarchy; port uses flat-root skin (`anim3d.gd:66`) | `.oss` payload readable but parent table absent (V7-2 Table B1) | On c3: `native_strings_find` for `.oss` reader class in `.rsrc`; `native_name_xrefs_list` on that class; `native_function_study` on the reader; then `native_functions_decompile` on the function that consumes the `6i` header (`k,fps,b,v,fc,t`) and advances past weights/anim. Repeat on ed for the editor mirror. | A typed array of parent bone indices and the exact transform composition order; then re-run `anim3d._skin_vertices_impl` with hierarchy and compare to donor frame. |
| U1 | `sub_890d34(edx=2, angle)` argument and vtable+`0xa8` submit contract | Decomp shows the call but not its parameter meaning | `native_function_study 0x890d34`; `native_api_show`; `native_call_graph_show backward` from `0x4cb27c` (3 callers); inspect the vtable at each caller's object to type slot `0xa8`; mirror in ed. | A named contract (which register is yaw, which is scale/LOD, what the virtual call submits) and a donor-faithful replacement for `_smooth_face`/`_xf`. |
| U2 | AAF loop/clamp/one-shot selection state→action map | All 194 AAF rows contain only `morph`; binary strings for `attack0`/`walk` are 0 hits | `native_function_pseudocode` on the AAF parser reached from `ActorList...Animations.LoadFromFile` consumers in `D:actors/units/peaukr.actor:4`; decompile the frame-advance behaviour (`FrameAnimationProperty`); extract the enum values for `aamLoop`, `aamPlayOnce`, `fasoInherited` and the tag→action case table. | Exact state→AAF-name map and loop flag; then replace `_unit_action` and remove `_frame_at`'s invented `fposmod` loop. |
| U3 | PFX `PixelRatio` → world-size conversion and `Interval/FrameRate` → seconds | No consumer converting these keys was recovered; port quads are labelled approximations | On c3: locate `pfxAnimatedSprite` behaviour class via `.rsrc` strings (`OSWPerlinPFX` at `0x958e8c` is one anchor, `ev_bd108362...`), `native_function_study` on its property setter handling `PixelRatio`, `FrameRate`, `AlphaTime`; follow to the draw submit. | A numeric conversion (pixels→metres, frames→seconds) with a cited function and constants; then replace `IMPACT_*_QUAD_M`, `IMPACT_FLASH_FRAME_SECONDS`, `SNOW_PORT_LIFETIME`. |
| U4 | Weather `WindInteraction=False`, `CameraSpeedFactor`, `SpiralRotating*` semantics | Config keys readable; runtime effect unproven | Decompile the PFX emitter updater that reads `CreatingCubeStart/End`, `MoveDirection`, `WindVector`, `SpiralRotatingSpeed`; use `native_value_flow_show` from the property block to the position update. | Exact per-frame position formula per emitter; then implement donor snow motion instead of port drift. |
| U5 | Per-actor LOD overrides (`ShaderLODList`, `LODList` beyond base ranges) | Base ranges `0..150/0..2500` are [O] in `refobj.actor`; per-sid changes not tabulated | Parse all `D:actors/**/*.actor` text files (read-only) into a per-sid LOD table; cross-check on c3 by decompiling the LOD selection behind the `ShaderLODList` consumer reached from `refunit.actor:2-4`. | A complete per-sid LOD table + selection rule; then wire `visibility_range` in `world3d_entities.gd`. |
| U6 | Donor 3-D mill sail spin sign/direction from `eurmilanim.oss` | Only 2D bake sign is proven; 3D axle direction inferred from bbox | Decompile the `.oss` attach consumer for `eurmilanim` (c3), specifically the function that reads the axle tip at donor y≈−1.897957 (`world3d_entities.gd:303`) and applies the rotor transform; mirror in ed. | A signed axis vector and angular rate; then remove `ROTOR_SPIN_AXIS_STATUS` approximation and bind the converted attach mesh. |
| U7 | Donor RNG stream used by `pfx.script` `Random` vs `RandomExt` and its seed | 8-float rule is [O]; which generator/seed is used is not | `native_name_xrefs_list`/`native_function_study` on the Delphi `Random`/`RandomExt` imports cited in prior decomp (`Random(256)` at `0x403a0c`, `RandomExt` LCG at `0x60f64c`), then xrefs from the PFX `GetOrCreate` consumer. | Exact generator + call order for FX randomisation; then implement donor RNG with isolated stream (no port "no RNG" shortcut). |
| U8 | 80-bit constants at `0x75c198`, `0x755c5c`, `0x75c1ac`, `0x755da4`, `0x755d0c`, `0x723e38` | Raw `21 68 C2 35...` not decoded (DEC_DEEP §5) | `native_bytes_show` 10 bytes at each VA on c3 and ed; decode IEEE-754 extended80 with a deterministic script; `native_xrefs_list` to confirm which are PI-family. | Exact real values; replace `DONOR_TBYTE_UNVERIFIED` placeholders with proven constants. |
| U9 | 24/16/13-byte placement-record field typing (per-object yaw, min/max angle) | Lifter gives register-level 24 B copy + 90° normalise + corner-byte permute; fields opaque (DEC_DEEP §3/§8) | `native_function_study` on `sub_755bc8`, `sub_755d1c`, `sub_755c6c`, `sub_755578`; `native_value_flow_show` with `max_depth=3` to type each byte; dump one authored object record from a shipped `.pattern` with a known placed object. | Typed record struct incl. yaw and min/max angle offsets; then replace the port's zero-yaw resource transforms. |
| U10 | Season material switching runtime (`UseableWinterMaterials`) | `.prop` lists are [O]; the consumer is not | On c3 find the `MaterialProperty` consumer via `.rsrc` class string xrefs; `native_function_pseudocode` on the season-index selection (`winter index 6 / PHDR 1`, `season=3 index 7` carried in `DB_SCRIPTS.md`); confirm on ed. | Exact season→material index mapping; then bind per-mesh material instead of one batch material. |
| U11 | Field HP→`field1..field7` thresholds | Port 25000/5000/13000 are labelled port approximations | Parse `D:materials/env/env.mat` and all field `.prop`/`.actor` entries; decompile the donor consumer that maps field hp/timer to `FieldAnimationCycles` names; locate its numeric thresholds. | Exact thresholds and state names; then remove `FIELD_DONOR_HP_*` approximations. |
| U12 | Collision-mask cell→world origin/alignment for building footprints | `gc_collision_size=0.5` [O]; mask origin and rotation transform unknown | On c3: `.rsrc` `XCollisionMask` / `XCollisionTags` (`ev_b08db4fb...`) → class-method xrefs → decompile the mask loader that turns `.prop` `Mask` rows into the `+0xa8` row table; compare with `sub_764e04` indexing. | Mask origin, cell size and rotation rule; then replace `bld_block_rect_for()` ink-box rectangle with donor mask occupancy. |
| U13 | `OctreeRayCastIntersect` / `GetGameObjectRayCastAABBByHandle` implementation (LOS) | Script surface [O]; engine implementation untyped; no named binary functions | Search `.rsrc` for octree/ray class names with `native_strings_find`; `native_function_study` on the class vtable methods; `native_value_flow_show` from the DMScript call signature (`sx,sy,sz,dx,dy,dz,px,py,pz,nx,ny,nz`) to the implementation; mirror in ed. | Typed ray/LOS function with normal/t and FOV/priority semantics; then implement donor LOS in the port. |
| U14 | Ghost dummy actor, colour/blink policy and rally TTL/flag parameters | Only procedural port stand-ins and private-use texture names exist | Read `D:objects/misc/constructiondummy.prop` / `rallypoint.prop` fully; decompile the ghost creation state from `D:scripts/units/**` consumers of `constructiondummy`; find the flag/behaviour lifetime in `D:scripts/misc/movearrow`/`rallypoint` state machines. | Exact ghost actor, blink function, colour source and rally lifetime; then replace procedural FX. |

Every unknown above has a named target (VA, class, file set) and an observable success criterion.
None is resolved by "keep the current port value".

---

## 7. Scope, exclusions, claim register

### 7.1 Exclusions

- **Network / multiplayer is explicitly excluded.** `D:scripts/lib/net.script`, lobby, Steam,
  `miscext.script` LAN sections, replay-sync and any `gc_*net*` constants are out of scope. This
  report is for **singleplayer skirmish** only (`anim3d.gd:3` charter line reused).
- Editor-only paths are excluded from the port target but used as read-only cross-check:
  `ed` `sub_8c5b78` stamp mirror; `generatemap.inc` editor-only pre-mark (carried in
  `PORT1TO1-GEN` fnd_9).
- No donor binary executed; no donor bytes copied into the repo; no Godot job submitted; no user
  mod touched; no git operation performed.

### 7.2 Claim register

| # | Claim | Label |
|---:|---|---|
| 1 | Donor unit collision AABB/sphere/CI constants are `refunit.prop:73-121`; gameplay radii are px constants in `dmscript.global:665-678` converted at 53.3333 px/tile | [O]+[D] |
| 2 | Donor building collision is an explicit 0/1 mask grid with 0.5-map-cell cells, not a circle | [O]+[D] |
| 3 | Donor collision tags and priorities are `dmscript.global:83-95`; water tag 87 distinct from renderer enum 3 | [O] |
| 4 | Donor LOD ranges are mesh 0..150 and shader/pool 0..2500 | [O] `refobj.actor:36-105` |
| 5 | Donor FX library has 24 named effects; `shotmusket` is a 5-layer composition with an exact 8-float randomisation rule | [O] `fx.tree`, `pfx.script:39-86` |
| 6 | Donor construction stage = `floor(hp/maxhp*4)`, wall `1+stage div 3`, scaffold child `<sid>Na`, death meshes `<sid>_death1/2` with debris child | [O] |
| 7 | Donor actor submit wraps a final angle with constants 0/±180 in `sub_4cb27c`; three decomp passes agree | [O] `ev_d2db...`, `ev_92e...`, `ev_cd35...`, `ev_8bc8...` |
| 8 | Port differs from donor at 25 exact file/line sites listed in §5; each has a donor-faithful replacement algorithm | [O] port lines + donor facts |
| 9 | Every `[U]` in §6 has a concrete decomp plan; none is closed by a port fallback | [D] this report |
| 10 | Any port visual equals donor motion/colour/FX | **Denied** — no same-camera donor/port A/B exists; parity UNVERIFIED |

### 7.3 Scope statement

Exactly one repository file was written by this worker: this report. All donor reads were through
read-only tools against the two pinned Craft Anything targets and the read-only donor data tree;
the global active target remained `t_87f0f3c130b0` and both pinned targets remained open. No
source, shader, config, asset, fixture, test, runner, Godot, git or user-mod state was changed.
No donor parity, similarity score, threshold or gate PASS is claimed.

*End of PORT1TO1-OBJECTS-ANIM-COLLISIONS-FX.*
