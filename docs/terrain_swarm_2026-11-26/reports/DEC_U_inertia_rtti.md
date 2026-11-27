---
id: DEC-U-INERTIA-RTTI
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-INERTIA-RTTI — static RTTI/.rsrc/ctor-table recovery for XCollisionInertia (and 3XCollisionInertia)"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_inertia_rtti.md
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_ASSET_CONFIG_GODOT_GIT_EDIT
created: 2026-11-26
labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
parity_guard: "NO DONOR PARITY IS CLAIMED. No same-camera donor/port A/B frame was produced or examined. Every donor statement is a read-only text/byte/VA/decomp observation; every port statement is a read-only source line. 'Required donor-faithful replacement' names the algorithm to implement, not a claim it is implemented."
scope_guard: "Exactly one repo file written (this report). No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod edit. Donor binary and donor data read READ-ONLY; no donor executable run, no donor bytes copied into the repo. Singleplayer skirmish only; network/multiplayer/lobby/Steam/replay-sync explicitly OUT OF SCOPE."
donor_pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE x86, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c, Deep mode. Every binary call in THIS job passed document=t_87f0f3c130b0 explicitly; global active target was already t_87f0f3c130b0 and was never changed."
port_scope: "variant3d/scripts/data.gd + variant3d/scripts/game.gd (read-only line cites; change list is specify-only, no edit)."
prior_reports_read:
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_collision_full.md (§0-§11, P1-P9, ev_* carried as noted)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_entities_art_collision.md (§0-§6, U13)
context_delta: "Prior worker closed text-side inertia constants (mass 1/1.5/3, radius 0.16/0.1/0.1, CI class block) but left U13-inertia open: XCollisionInertia/3XCollisionInertia are .rsrc names with zero static xrefs; numeric RTTI fields unrecovered. Port keeps Data.DEC_U_COLLISION_INERTIA = null sentinel, never read. This worker re-pins the same binary, re-runs the string/xref/RTTI passes, adds ctor/default-table and script-consumer passes, and reports exactly which numeric fields are statically recoverable and which stay [U] with shove captures."
---

# DEC-U — XCollisionInertia / 3XCollisionInertia RTTI + numeric-field audit

> READ-ONLY. No approximation endorsed. Every `[U]` ends in a named two-unit shove capture, never in a port fallback. No numeric is invented here.

## 0. Method, labels, passes

- **[O]** = observed donor file line / binary VA / port line. **[D]** = arithmetic over cited [O]. **[I]** = reading without runtime proof. **[U]** = unresolved after passes here.
- Path shorthands: `D:` = `C:\Games\Cossacks 3\data\` (read-only donor tree). `P:` = `variant3d/scripts/`. `c3` = `t_87f0f3c130b0`.
- `ev_<hex>` = Craft Anything evidence id of a pass in **this** job (all `document=t_87f0f3c130b0` for binary calls, or donor text paths for file reads). `ev(carried)` = prior worker id, re-cited not re-run.

### 0.1 Pass ledger (pin `t_87f0f3c130b0`, multiple passes; strange-decomp log inline)

| Pass | Operation | Evidence | Result |
|---|---|---|---|
| P1 | `native_strings_find` `XCollisionInertia` / `CollisionInertia` / `Inertia` (literal) | `ev_4c00066fe63b710acfbd7ed0d6adf4f0783f1df526926dda44caa433c5af4292`, `ev_a272b5de45d4fe103bd2a5cfcc6906e8e5470a0f6bc3423bcf87cbf58609337e`, `ev_505f45f3ef0ea0bfbd66600a1d3e9176100f2c7472275524a9310eb01cd40589` (carried P1) | [O] exactly 1 hit: `.rsrc` `0x95972b` `3XCollisionInertia` in all three queries. No `XCollisionInertia` without `3` prefix exists as a binary string |
| P2 | `native_xrefs_list` + `native_data_show` + `native_address_show` on `0x95972b`; control reads `0x959700/0x959740/0x9589c0` | `ev_cea0ee256de16148338aa1250ce796e88335091f7e250f2320fea2f6d811b5a` (0 refs), `ev_e191811560e3613e84a2de507c2e1db6db379da895539b3569d8eaf7efb97fad` (string), `ev_7f5258e6062d94fa2c737ebee2b67e165c1eebd2ce327fcffac71e1646f8846d` (neighbour `XHardwareUtils`), `ev_cfced42d8556482ca23ed29a53fdf15eeafdca783f3b6ae859debf05c1114c4c`, `ev_15711c0ddbc56f8106f89ea614355944a8a4e56e10adf934f11c2e25c0b21c28`, `ev_0dd6133d20f7048ab215df44ede1ce9d6fcd96802e7b79f5ffe7a96002010ea3`, `ev_a6b1112530b11f649f133a983c2fc356c200172cb96273adb92e731e6e54fb7` | [O] 0 xrefs to/from `0x95972b`; typed as `.rsrc` ascii string; neighbours are unrelated class-name strings (`XHardwareUtils`, `XPathTypes`, `IdUDPServer`); address is not in executable code, has no name/comment/bookmark |
| P3 | `native_strings_find` CI property names / script entry names (regex): `CIMass\|CIIntersectRadius\|CIMovable\|…`, `gc_collision_mass\|gc_collision_radius`, `SetGameObjectCIMovable\|…CIMovable` | `ev_835a16ffb15c6f5f3cbe6533be8347e133ad56e492b16c01cf022ef71980611` (×0), `ev_453f4dfbcda5d49440560015ca2b253060d56ddfb67165dc0` (×0), `ev_a1e91af6d2b357e98bff9677f43c6db62c6a004d4b96d801f4cbb65ee5ecf801` (×0) | [O] zero binary strings for every CI property name and every script `Set/GetGameObjectCI*` name. Engine entry names are NOT embedded as binary strings — script↔engine binding is by ordinal/registration, not recoverable by string search [D] |
| P4 | `native_strings_find` `XCollision` (literal, control) | `ev_90e9295ed7e4f2981c04889d80d7bfba2a2d8598112b72c1c5376d42870da4f9` (carried) | [O] same 3 VAs re-confirmed: `0x9589c7 XCollisionMask`, `0x958a13 XCollisionTags`, `0x95972b 3XCollisionInertia` |
| P5 | `native_strings_find` RTTI/Delphi markers: `TClass\|VMT\|RTTI\|TypeInfo\|InheritsFrom\|FieldTable\|MethodTable\|Published`, `TObject\|TComponent\|TPersistent`; `.rsrc` browse p.0-200 | `ev_dfb9353fd6f46a794d9feb43032c67783d84a951ab5cd1007dbe596d3481d13d` (7 hits, all `SetClassLongA/GetClassName*/GetClassInfo*/OSWPersistentClasses/TntClasses`), `ev_69df43bc315ab8e37e175ca1d02fe7366b9df1e2dfc35b1d27e8e6d81788c5b9d4` (3 GDI hits only), `ev_f0b9422d06ee03a486a77e230ade8b1a096a27816047bef452e181eb6e3d3271` | [O] No Delphi VMT/RTTI/TypeInfo/FieldTable/MethodTable strings in binary. Only `OSWPersistentClasses` (`0x958696`) + `PACKAGEINFO` (`0x94d062`) + Win32 `GetClassInfo*` imports. No recoverable RTTI field table by string search |
| P6 | `native_strings_browse` `.rsrc` offset 1500-1560 + `core_feature_find` `Collision` / `Inertia` / `CIMass` | `ev_7601c194a623985402cf3f73ebd35453f1d14b15784e40cd785609bce1870649`, `ev_2daac0e793ee0c0b4ca0ea202144aaf019dbae38719ff7caf4cfb5a65d5e6d7f`, `ev_80e7c6b0485fa552b2a345c592a3f843be28d81deb9f63dec00152884aee37bf`, `ev_e517b0a45d17ccceedb38f09fc3b6198f5bec69b2aa5de082951d4129a89e816` | [O] `.rsrc` neighbourhood of the class names is Delphi form/package registration text (`TCheckBox…`, `Lan Server Record…`), not a numeric field table. `core_feature_find Collision` = 3 strings, 0 functions, 0 imports; `Inertia` = 1 string, 0 functions; `CIMass` = 0/0/0 |
| P7 | `native_strings_find` collision verbs / mass-radius words: `collid\|Collis\|push\|shove\|separat\|stand\|attack`, `mass\|radius` | `ev_25fba724810d7971fcf331ad9fcebe4849c028430575e44f4aa4a447dd5e734` (15: `glPushMatrix/Matrix/Attrib`, 3 `XCollision*`, rest `tbsSeparator/CheckBoxSeparateWindow`), `ev_ac7af2c1b2d8cdd5133bc99c77f3d12d4e9f27f174d5f18dde4017b8b15` (×0) | [O] No engine `push/shove/separat/stand/attack/mass/radius` strings. Only GL `glPush*` imports and VCL `Separator` widget names. No native shove routine is name-recoverable |
| P8 | `native_strings_find` CI engine verbs + class-list context: `IntersectRadius\|Movable\|MaxDist\|DeltaStep\|RotationSpeed\|Uncollide`, `OSWPersistentClasses\|PACKAGEINFO` | `ev_e94f5b90f8a2d770fa12fe60b1de71b40bb4e1227b8152207958eee4017b8b15` (×0), `ev_31a3fa12e815b9c717ca8e1312470ddabfe5f936c265b73463e9fcdb0cc668ed` (×2) | [O] Zero CI engine-verb strings; class-list context confirmed as the only `.rsrc` registration mechanism visible statically |
| P9-T | donor text re-read (read-only, no binary executed): `dmscript.global:969-974`, `refunit.prop:100-116`, `refbuilding.prop:102-118`, `unit.script:11160-11170`, `units/unit.inc/initial.inc:21-56 + :239-257`, `units/unit.inc/ontagstates.inc:888-936`, `units/building.inc/initial.inc:30-94`, `movie.script:841/847`, `common.inc/dogenerate.inc:1324`, `units/building.inc/ontagstores:321`, `units/global.inc/readnewp:60 + writenewp:44`, `env/env.inc/*` | shell grep (no evidence id; commands in §7 provenance) | [O] Full numeric + consumer surface below (§2-§4). Stand/attack mass+radius constants are DEFINED but have ZERO sampled active script consumers; the `SetCustomCollisionInertia` ship table + gate-collider + birth/build switches ARE the sampled consumers |

**Strange-decomp log (required):** no function decompilation was attempted for CI because P4/P6 prove there is no name-anchored native caller: zero function-name hits for `Collision/Inertia/CIMass`, zero imports, zero xrefs from all three class-name strings. Any pseudo-C attribution of an arbitrary `sub_*` to `XCollisionInertia` would be a guess, so none is offered. The P5 `.rsrc` page initially looked like it might contain a DFM field block (many short strings), but the paged read shows VCL form/packaging text, not `published` property records — discarded as a field table [D].

---

## 1. RTTI / type-descriptor verdict: statically ABSENT [O-passes, U-fields]

1.1 **No RTTI field table is recoverable by static string search in `c3`.** P5 finds no `RTTI/TypeInfo/FieldTable/MethodTable/Published/InheritsFrom/VMT` binary strings; only Win32 `GetClassInfo*` imports and the `.rsrc` `PACKAGEINFO` / `OSWPersistentClasses` / `TntClasses` registration names. P3 finds no `CIMass/CIIntersectRadius/CIMovable/…` strings; P8 finds no `IntersectRadius/Movable/MaxDist/DeltaStep/RotationSpeed/Uncollide` strings; P7 finds no `mass/radius/push/shove/separat/stand/attack` engine strings (only GL/VCL homonyms). Therefore **field offsets, field count, field types and the meaning of the `3` prefix in `3XCollisionInertia` are NOT statically recoverable** — each stays **[U]** with its §6 shove capture. This is anstatic-absence verdict with the pass ids above, not a claim that the engine lacks the fields at runtime.

1.2 **`.rsrc` resource verdict.** The three names exist ONLY as `.rsrc` registered-class strings at fixed VAs (P1/P4): `0x9589c7 XCollisionMask`, `0x958a13 XCollisionTags`, `0x95972b 3XCollisionInertia` — each with 0 static xrefs (P2, `ev_cea0…`). Neighbour bytes are other registered-class strings (`IdUDPServer`, `XHardwareUtils`, `XPathTypes`), and the wider `.rsrc` page is form/package text (P6). No adjacent numeric defaults, no DFM `published` block, no length-prefixed field directory is visible to the `data_show`/browse tools at these addresses. The `OSWPersistentClasses` (`0x958696`) + `PACKAGEINFO` (`0x94d062`) pair (P5/P8) is the only visible registration mechanism: classes resolve at runtime through the Delphi persistent-class registry, not through a static pointer [D, same inference as prior worker §0.1-P4]. Not proof of non-use.

1.3 **`3` prefix.** Only the `3`-prefixed spelling exists in the image (`3XCollisionInertia`); the bare `XCollisionInertia` has zero hits (P1). Whether `3` is a version tag, a namespace revision, or a distinct descendant class is unproven statically — **[U] U-prefix** (§6, capture S-PREFIX). The port MUST NOT normalise the name: cite both spellings with the `3`-only observation.

## 2. Constructor / default-table surface: recovered from donor TEXT [O] (no binary needed)

The binary contributes no numeric table (P3/P7/P8 all ×0), but the donor TEXT tree carries the complete authored default surface. Nothing below is invented; every number has a file:line cite.

### 2.1 Class authored defaults [O]

| Source | Rows |
|---|---|
| `D:objects/ref/refunit.prop:100-116` | `UncollideDelta=0.05; CIEnabled=True; CIMovable=True; CIMass=1; CIIntersectRadius=0.16; CIMaxDistKoef=2; CIDeltaStep=0.005; CIRotationSpeed=5; CIStuckAngle=5; CIEpsilonAngle=4; CIEpsilonShift=0.001; CIEpsilonMove=0.02; CIDistExtPointEpsilon=0.005; CIAvoidPointMaxAngle=60; CIMaxCollideCounter=7` |
| `D:objects/ref/refbuilding.prop:102-118` | same numerics, but `CIEnabled=False; CIMovable=False` (mass/radius/koef/steps/angles/epsilons/counter identical to refunit) |
| `D:scripts/dmscript.global:969-974` | `gc_collision_mass_default=1; gc_collision_mass_stand=1.5; gc_collision_mass_attack=3; gc_collision_radius_default=0.16; gc_collision_radius_stand=0.1; gc_collision_radius_attack=0.1` |

[D] The class rows and the `default` globals agree exactly (`1` / `0.16`), so the prop block IS the `default`-state instantiation. The `stand/attack` rows have no prop counterpart — they exist only as globals (see §2.3).

### 2.2 `SetCustomCollisionInertia` procedure + ship table [O] — NEW vs prior worker

`D:scripts/units/unit.inc/initial.inc:21-56` defines the ONLY sampled parametrised CI constructor:

- `procedure SetCustomCollisionInertia(hnd; IntersectRadiusFactor, MassFactor, DeltaStepFactor: Float; bMovable: Boolean)` — body (all [O] ibid.):
  - `SetGameObjectCollisionInertiaByHandle(hnd, IntersectRadiusFactor>0)`; `if (IntersectRadiusFactor<=0) then exit`;
  - `SetGameObjectCIAvoidPointMaxAngleByHandle(hnd, 180)`;
  - `SetGameObjectCIMassByHandle(hnd, 1*massFactor)`;
  - `SetGameObjectCIIntersectRadiusByHandle(hnd, gc_collision_radius_default*IntersectRadiusFactor)`;
  - `SetGameObjectCIMaxDistKoefByHandle(hnd, 2)`;
  - `if MassFactor<=0 then SetGameObjectCIDeltaStepByHandle(hnd, 0) else SetGameObjectCIDeltaStepByHandle(hnd, 0.005/DeltaStepFactor)`;
  - `SetGameObjectCIRotationSpeedByHandle(hnd, 5)`;
  - `SetGameObjectCIStuckAngleByHandle(hnd, 0)` with trailing comment `// 0.5 in rw2to`;
  - `SetGameObjectCIEpsilonAngleByHandle(hnd, 4)`; `CIEpsilonShift 0.001`; `CIEpsilonMove 0.02`; `CIDistExtPointEpsilon 0.005`;
  - `SetGameObjectCIMovableByHandle(hnd, bMovable)`; `SetGameObjectCIBuildExtPointsByHandle(hnd, True)`;
  - `SetGameObjectCIMaxCollideCounterByHandle(hnd, 7*3)`; `SetGameObjectCIMaxProcessObjectByHandle(hnd, 4*3)`;
  - then widens the custom AABB to at least `±gc_collision_radius_default*IntersectRadiusFactor` (`:47-55`).
- Active ship call sites (`:242-248`, `if (_unit_IsWaterUnit(myHnd))`, `case basename of`):

| sid(s) | call | [D] expanded radius (0.16×factor) m | [D] expanded mass (1×factor) | delta-step [D] (0.005/0.1) |
|---|---|---|---|---|
| `ferry` | `(myHnd, 11, 32, 0.1, not bIsShipDummy)` | 1.76 | 32 | 0.05 |
| `battleship` | `(myHnd, 11, 32, 0.1, …)` | 1.76 | 32 | 0.05 |
| `frigate`, `xebec` | `(myHnd, 9, 16, 0.1, …)` | 1.44 | 16 | 0.05 |
| `galley` | `(myHnd, 7, 12, 0.1, …)` | 1.12 | 12 | 0.05 |
| `chaika` | `(myHnd, 6, 8, 0.1, …)` | 0.96 | 8 | 0.05 |
| `yacht`, `yachttur` | `(myHnd, 6, 8, 0.1, …)` | 0.96 | 8 | 0.05 |
| `fishboat` | `(myHnd, 3, 1, 0.1, …)` | 0.48 | 1 | 0.05 |

Commented-out alternates (`:249-255`, `{…}`, factors 14/11/9/8/4) are DEAD text and are NOT ported. All ships set avoid-angle `180` (vs class `60`), stuck `0` (vs class `5`), collide-counter `21` (vs `7`), max-process `12`, ext-points `True`.

### 2.3 Gate/building collider explicit numerics [O]

`D:scripts/units/building.inc/initial.inc:52-94` (`AddCICollider` + `SetupCollider`):

- `AddCICollider(x,y,z)`: creates `gc_basename_gatecollision`, then `CollisionInertia True; CIIntersectRadius 0.35; CIMovable False; CIMass 10000; CIMaxDistKoef 2; CIDeltaStep 0.005; CIRotationSpeed 5; CIStuckAngle 5; CIEpsilonAngle 4; CIEpsilonShift 0.001; CIEpsilonMove 0.02; CIDistExtPointEpsilon 0.005; CIAvoidPointMaxAngle 120; CIMaxCollideCounter 7`.
- `SetupCollider(goHnd, rad)`: `CollisionDetection False; CollisionInertia True; CIMovable False; CIMass 10000; …` (same block, avoid `120`), then `SetGameObjectCIIntersectRadiusByHandle(goHnd, rad)` with the cited `rad = 0.35` call-site value (`:92`).
- `D:scripts/units/building.inc/initial.inc:30-47` map-blob collider loop: `CIIntersectRadius 0 → position → scale → CIIntersectRadius 0.2; CIMass 1`.

### 2.4 Stand / attack rows: DEFINED but zero sampled active consumers [U]

- Defined [O] `dmscript.global:970-971/973-974`: stand `1.5 / 0.1`, attack `3 / 0.1`.
- Full-tree grep for `gc_collision_mass_stand|gc_collision_mass_attack|gc_collision_radius_stand|gc_collision_radius_attack` returns ONLY those four definition lines — **zero reads** in any sampled script (P9-T). No `SetGameObjectCIMass*stand/attack*` call was found.
- The prior worker's "stand/attack switching" phrasing is therefore refined: the only SAMPLED runtime switches are birth/build/action switches (§3), none of which references the stand/attack globals. The stand/attack CONSUMER — if any — is either engine-native (no binary string, P3/P7/P8 ×0) or in an unsampled script. It stays **[U] U-stand-attack** with capture S-STAND (§6). The port must NOT wire `1.5/3` or `0.1` into the solver on the assumption they are stand/attack states.

## 3. Where the fields ARE consumed in stand/attack/build switching (sampled script call sites [O])

All sites below are ACTIVE (not commented out). `[*] = ;` is the file's line-prefix convention, not a comment-out; `//`-prefixed lines ARE dead and are excluded.

| # | Site | Donor text [O] | Effect [D] |
|---|---|---|---|
| S1 | `unit.inc/initial.inc:180` (unit spawn) | `SetGameObjectCollisionInertiaByHandle(myHnd, True)` | every land unit boots with inertia ENABLED |
| S2 | `unit.inc/initial.inc:239-257` (ship branch) | §2.2 ship table | per-sid radius/mass/counter/avoid override at creation |
| S3 | `unit.inc/ontagstates.inc:888-902` (birth) | `switchEssential=birth:` non-ship → `CIIntersectRadius gc_default*0.4` (= 0.064 m [D]); `CollisionInertia False`; hide/pick/scan removals | birth = small-radius + inertia OFF |
| S4 | `unit.inc/ontagstates.inc:903-923` (none) | `switchEssential=none:` non-ship → `CollisionInertia True`; `CIIntersectRadius gc_default` (0.16) AFTER enable (comment: else radius will be 0.8); collision-detect True; STO+scan re-add; ships create childs | leave-birth = inertia ON + 0.16 m, ORDER-DEPENDENT (radius set after enable) |
| S5 | `unit.inc/ontagstates.inc:924-936` (build) | `switchAction=build:` `CIMovable False` + `CIIntersectRadius 0`; `iOldAction=build → not build:` `CIMovable True` + `CIIntersectRadius gc_default` (0.16). The `CollisionInertia` toggles here are `//`-commented OUT (dead) | build immobilises WITHOUT touching the inertia bool; radius 0 ↔ 0.16 |
| S6 | `lib/unit.script:11160-11170` (`ForceStateTag` build mirror) | `iAction=build ∧ movable:` `CIMovable False` + `CIIntersectRadius gc_default*0` (= 0.0); `iAction<>build ∧ not movable:` `CIMovable True` + `CIIntersectRadius gc_default` (0.16) | same S5 law on the force-tag path [D] `0.16*0 = 0.0` |
| S7 | `lib/unit.script:11807` | `SetGameObjectCIMovableByHandle(goHnd, False)` | one more immobilise site ( punished/held unit; surrounding branch not sampled — cite as site only) |
| S8 | `lib/movie.script:841/847` | `SetGameObjectCIIntersectRadiusByHandle(hnd, gc_default*factor)` (both) | cinematic scaling path; `factor` ident not sampled — site only, no value ported |
| S9 | `units/building.inc/ontagstates.inc:321` | `SetGameObjectCollisionInertiaByHandle(myHnd, False)` | building-tag transition disables inertia (branch not sampled — site only) |
| S10 | `units/global.inc/readnewp.inc:60 + writenewp.inc:44` | `SetGameObjectCollisionInertiaByHandle(goHnd, false)` (both) | serialisation paths force inertia OFF (branch not sampled — site only) |
| S11 | `env/env.inc/ontagstates.inc:77`, `env.inc/initialdecor.inc:25`, `env.inc/initial.inc:32` | `False / False / True` respectively | decor inertia OFF by default, ON only in `initial.inc:32` branch |
| S12 | `common.inc/dogenerate.inc:1324`, `units/building.inc/initial.inc:46` | `SetGameObjectCIMassByHandle(goHnd, 1)` (both) | generated/map-blob mass pinned to class default |

No sampled site writes `CIMass 1.5/3`, `CIIntersectRadius 0.1`, or reads `gc_collision_{mass,radius}_{stand,attack}`. Attack-state (`iAction=attack`) switching of inertia/mass/radius is NOT present in any sampled branch — the `attack0` anim selection (`ontagstates.inc:321-324`) is animation only.

## 4. Numeric-field table: what is recovered vs what stays [U]

| Field (class/prop name) | Static recovery | Value (never invented) | Status |
|---|---|---|---|
| `CIMass` default | [O] refunit:105 + refbuilding:107 + `gc_mass_default` :969 + `SetCustom` base `1*` | 1 | closed (text) |
| `CIIntersectRadius` default | [O] refunit:106 + refbuilding:108 + `gc_radius_default` :972 | 0.16 m | closed (text) |
| `CIMaxDistKoef` | [O] refunit:107 + refbuilding:109 + `SetCustom`/`AddCICollider`/`SetupCollider` `2` | 2 | closed (text) |
| `CIDeltaStep` | [O] refunit:108 + refbuilding:110 + colliders `0.005`; ships `0.005/0.1 = 0.05` [D]; `MassFactor<=0 → 0` branch | 0.005 / 0.05 / 0 | closed (text+D) |
| `CIRotationSpeed` | [O] refunit:109 + refbuilding:111 + all sampled setters `5` | 5 | closed (text) |
| `CIStuckAngle` | [O] refunit:110 + refbuilding:112 + colliders `5`; `SetCustom` `0` (+ `0.5 in rw2to` comment) | 5 class / 0 ships | closed (text) |
| `CIEpsilonAngle` | [O] refunit:111 + refbuilding:113 + all sampled setters `4` | 4 | closed (text) |
| `CIEpsilonShift` | [O] refunit:112 + refbuilding:114 + all sampled setters `0.001` | 0.001 | closed (text) |
| `CIEpsilonMove` | [O] refunit:113 (`0.02`) + colliders `0.02` | 0.02 | closed (text) |
| `CIDistExtPointEpsilon` | [O] refunit:114 (`0.005`) + colliders `0.005` | 0.005 | closed (text) |
| `CIAvoidPointMaxAngle` | [O] refunit:115 `60` + refbuilding `60`(line 117 region); `SetCustom` `180`; gate colliders `120` | 60 class / 180 ships / 120 gates | closed (text) |
| `CIMaxCollideCounter` | [O] refunit:116 + refbuilding:118 `7`; `SetCustom` `7*3=21`; gates `7` | 7 / 21 ships | closed (text) |
| `CIMaxProcessObject` | [O] `SetCustom` only: `4*3=12` [D] | 12 (ships; no class-row counterpart sampled) | closed-as-ship-only (text+D) |
| `CIBuildExtPoints` | [O] `SetCustom` only: `True` | True (ships) | closed-as-ship-only (text) |
| `UncollideDelta` | [O] refunit:100 + refbuilding:102 `0.05` | 0.05 | closed (text) |
| `CIEnabled / CIMovable` defaults | [O] refunit `True/True`; refbuilding `False/False` | bools | closed (text) |
| gate-collider mass/radius | [O] building.inc `10000 / 0.35`, avoid `120` | 10000 / 0.35 m | closed (text) |
| ship mass/radius/counter/avoid/stuck table | [O] §2.2 active rows; [D] expansions | see §2.2 | closed (text+D) |
| `gc_mass_stand / gc_mass_attack` (1.5 / 3) | [O] defined; ZERO sampled consumers (P9-T) | values closed, CONSUMER open | **[U] U-mass-switch** → S-STAND |
| `gc_radius_stand / gc_radius_attack` (0.1 / 0.1) | [O] defined; ZERO sampled consumers (P9-T) | values closed, CONSUMER open | **[U] U-radius-switch** → S-RADIUS |
| `XCollisionInertia` field offsets / count / types | [O] absent (P5 string ×0, P2 0-xref, P6 no table) | — | **[U] U-offsets** → S-OFFSETS |
| `XCollisionInertia` numeric defaults in-binary | [O] absent (P3/P7/P8 all ×0) | — (text table §2 is the only source) | **[U] U-ctor** → S-CTOR |
| `3` prefix meaning / base-vs-derived | [O] only `3`-spelling exists (P1) | — | **[U] U-prefix** → S-PREFIX |
| engine shove solver (mass→separation law, radius→contact law, counter/koef/epsilons use) | [O] absent (no names, no floats, no callers) | — | **[U] U-solver** → S-SOLVER |

`CIDeltaStep` note: `refbuilding.prop` carries the same `0.005` as refunit (line 110 region); the refbuilding grep in this job returned lines 102-118 with identical numerics — re-cited, not re-printed in full.

## 5. Exact port change list (`data.gd` / `game.gd`; specify-only, no edit)

Conventions: port site [O] with as-read line; donor fact [O]/[D] from this job; replacement names the algorithm. Line numbers are provenance-only — concurrent workers edit both files, so re-anchor by **function/const name + verbatim text**. Zero port edits were made by this worker.

| # | Port file:line (current [O]) | Donor fact (this job [O]/[D]) | Required donor-faithful replacement (no parity claim) |
|---|---|---|---|
| R1 | `P:data.gd:101-109` comment + `static var DEC_U_COLLISION_INERTIA: Variant = null` sentinel | §1: no RTTI offsets/table recoverable (P2/P5/P6/P8); §2: full text default surface exists | KEEP sentinel `null`, never read. Extend the comment to cite this report: offsets/table stay [U] U-offsets/U-ctor; text defaults live in R2 rows, not in the sentinel |
| R2 | `P:data.gd:2800-2824` `DONOR_COLL_INERTIA_TEXT` (mass+radius 6-row) + `DONOR_COLL_CI_CLASS_ROWS` (13-row) + `DONOR_COLL_CI_BUILD_RULE` (0.0/0.16) | §2.1-§2.4: class rows + globals + ship table (§2.2) + gate colliders (§2.3) + `SetCustom` formula block (`:21-56`) + birth/build switches (§3 S3-S6) | ADD three inert const blocks (no consumer wiring): (a) `DONOR_COLL_SHIP_INERTIA` per-sid `(radius_factor, mass_factor, delta_factor)` + [D] expansions from §2.2 with `:242-248` cite + dead-alternate exclusion note `:249-255`; (b) `DONOR_COLL_GATE_COLLIDER` (`10000/0.35/120/7` + `SetupCollider rad` rule, `:52-94` cite); (c) `DONOR_COLL_SETCUSTOM_FORMULAS` (mass `1*massFactor`, radius `gc_default*IRFactor`, delta `0.005/DSFactor` or `0`, avoid `180`, stuck `0`, counter `21`, maxproc `12`, extpoints `True`, AABB widen `±gc_default*IRFactor`, `:21-56` cite). Mark stand/attack rows in the existing TEXT block as `[U] consumer-open (U-mass-switch/U-radius-switch)` |
| R3 | `P:game.gd:965-1000` `DEC_U_INERTIA_MASS/RADIUS_M/CI_BLOCK` consts + `dec_u_inertia_telemetry()` (sentinel labels `[U] U13-inertia`) | §3 S1-S12 switch sites; §2.2-S2 ship branch; §4 table | EXTEND telemetry only (no solver wiring): return the R2 ship/gate/setcustom rows + the S1-S12 switch-site register with file:line cites; keep `engine_state` as `[U] U-solver/U-stand-attack` with S-* capture names. Do NOT add a mass/radius lerp, shove force, or separation rule — any such code would invent the unrecovered solver |
| R4 | (no new file/line) — future consumers | §3 order-dependence S4 (`radius AFTER enable, or radius will be 0.8`, `ontagstates.inc:910` comment) + S5/S6 `0.16*0=0.0` | WHEN a consumer is ever wired (not this ticket): reproduce the ORDER (enable-then-radius on un-birth; movable+radius atomically on build transitions) and the exact `*0`/`*0.4` factors. Recorded here so the order law is not lost |

Required donor asset manifest (sourced through approved converters, **not copied here**): `D:scripts/dmscript.global` (`:969-974`), `D:objects/ref/refunit.prop` (`:100-116`), `D:objects/ref/refbuilding.prop` (`:102-118`), `D:scripts/units/unit.inc/initial.inc` (`:21-56`, `:239-257`), `D:scripts/units/unit.inc/ontagstates.inc` (`:888-936`), `D:scripts/lib/unit.script` (`:11160-11170`, `:11807`), `D:scripts/lib/movie.script` (`:841/847`), `D:scripts/units/building.inc/initial.inc` (`:30-94`), `D:scripts/units/building.inc/ontagstates.inc` (`:321`), `D:scripts/units/global.inc/readnewp.inc:60 + writenewp.inc:44`, `D:scripts/env/env.inc/{ontagstates.inc:77,initialdecor.inc:25,initial.inc:32}`, `D:scripts/common.inc/dogenerate.inc:1324`.

## 6. Fixed-camera two-unit shove captures (zero-mismatch termination)

General harness (all S-*): singleplayer skirmish, fixed map seed, flat open ground (no slope/buildings/trees), fixed camera (position/yaw/pitch/fov logged + capture id), two fresh infantry units (same sid, `essential_none/action_none`, inertia ON per S1/S4, movable True, radius 0.16), seeded RNG re-seeded per series. Drive unit A straight at stationary unit B from 5.0 m at walk speed; log per-tick `(posA, posB, separation, iActionA/B, CIMovableA/B, CIIntersectRadiusA/B)` from engine-visible handles plus any `SetGameObjectCIMass*` readback the harness exposes. Assertions read positions/handles, never pixels. **Termination rule (all): 0 mismatched separations/frames across the stated matrix; first mismatch stops the run and is filed with its capture id — never overridden by a port fallback. Never fit or invent a curve.**

- **S-OFFSETS (U-offsets: field offsets/count/types):** dump the live `XCollisionInertia` instance fields of one unit (whatever inspector the harness exposes) in two states: birth (`essential_birth`, S3) and active (`essential_none`, S4). Pass = identical field NAME SET in both dumps with 0 missing/extra fields across 10 units × 2 states; any offset/value is recorded, never asserted. Closes only the field inventory, not the solver.
- **S-CTOR (U-ctor: in-binary numeric defaults):** spawn one unit per sid class (foot, horse, cannon, `fishboat`, `frigate`, gate-collider) and read back live `(CIMass, CIIntersectRadius, CIMaxDistKoef, CIDeltaStep, CIRotationSpeed, CIStuckAngle, CIEpsilon*, CIAvoidPointMaxAngle, CIMaxCollideCounter, CIMaxProcessObject, CIBuildExtPoints, CIMovable)` before any order. Pass = 0 mismatches vs §2.1-§2.3 text rows (with §2.2 ship expansions) across all 6 classes × 5 spawns.
- **S-PREFIX (U-prefix: `3` meaning):** same dump as S-CTOR on a unit and on a gate-collider; record the runtime class name string each instance reports. Pass = 0 mismatches in the reported name across 10+10 instances; decides whether `3XCollisionInertia` is the live name for both or only one role.
- **S-STAND (U-mass-switch: 1.5/3 consumer):** A-vs-B shove with B forced through `action_none → attack → none` (scripted attack order on a far dummy, then cancel) while A pushes. 3 pairings (foot/foot, foot/horse, horse/horse) × 20 trials. Pass = separation-vs-mass curve identifies exactly when (if ever) live `CIMass` reads `1.5` then `3.0` with 0 off-state mismatches; if no trial ever reads 1.5/3, the consumer stays [U] and NOTHING is wired.
- **S-RADIUS (U-radius-switch: 0.1/0.1 consumer):** same matrix as S-STAND but asserting live `CIIntersectRadius` reads `0.1` in stand/attack states. Pass = 0 mismatches across 60 trials; else stays [U].
- **S-SOLVER (U-solver: mass→separation law):** foot(1) vs foot(1) baseline, then foot vs ship-mass proxy (spawn `yacht` mass-8 hull held stationary, push with foot): log steady-state separation and push-through time. 2 geometries × 30 trials. Pass = a single mass-ratio law predicts both separations with 0 mismatches; any systematic residual keeps the solver [U]. The `0.8`-radius failure comment (`ontagstates.inc:910`) gets its own 10-trial order-swap run (radius-before-enable vs enable-before-radius): pass = 0 mismatches on which order yields `0.8`.
- **S-BUILD (build-switch order law, already [O] text, capture as guard):** order a peasant to build, log `(CIMovable, CIIntersectRadius)` per tick through start→progress→leave-build; 10 trials. Pass = `False/0.0` during build and `True/0.16` after, 0 mismatches, matching S5/S6.

## 7. Provenance appendix

Binary (all `document=t_87f0f3c130b0`, Deep): P1-P8 table (§0.1) with VAs `0x9589c7/0x958a13/0x95972b` (`.rsrc`), `0x958696 OSWPersistentClasses`, `0x94d062 PACKAGEINFO`, `0x909496/0x909bd4/0x909be4/0x909bf4/0x909c04` (Win32 class-info imports, P5). Donor text (read-only `Get-Content`/`Select-String`, no execution): `dmscript.global:969-974`, `refunit.prop:100-116`, `refbuilding.prop:102-118`, `unit.script:11160-11170 + :11807`, `movie.script:841/847`, `unit.inc/initial.inc:21-56 + :157-257`, `unit.inc/ontagstates.inc:888-936` (+ attack-anim `:321-324` exclusion), `building.inc/initial.inc:30-94`, `building.inc/ontagstates.inc:321`, `global.inc/readnewp.inc:60 + writenewp.inc:44`, `env.inc/*:77/25/32`, `dogenerate.inc:1324`. Port (read-only): `P:data.gd:101-109` (sentinel), `:2800-2824` (inertia blocks), `P:game.gd:965-1000` (telemetry).

## 8. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | `3XCollisionInertia` at `0x95972b` is the ONLY inertia class string; bare `XCollisionInertia` has 0 hits; 0 xrefs either way | [O] P1/P2 `ev_4c00…/ev_cea0…` |
| 2 | No RTTI/TypeInfo/FieldTable/MethodTable, no CI property name, no `Set/GetGameObjectCI*` name, no `mass/radius/shove/stand/attack` engine string exists in the image | [O] P3/P5/P7/P8 `ev_835a…/ev_453f…/ev_a1e9…/ev_dfb9…/ev_ac7a…/ev_e94f…` |
| 3 | `.rsrc` neighbours are registration/form text, not a numeric field table; `OSWPersistentClasses`+`PACKAGEINFO` is the only visible registration mechanism | [O] P5/P6 `ev_31a3…/ev_7601…` |
| 4 | Class defaults + `default` globals + gate/ship/`SetCustom` numerics are donor-exact per cited prop/script lines; ship expansions are exact arithmetic | [O] §2 cites; [D] multiplications/divisions |
| 5 | Ship active factors are 11/9/7/6/3 + 32/16/12/8/1 + 0.1; the 14/11/9/8/4 block is dead `{…}` text | [O] `initial.inc:242-255` |
| 6 | Stand/attack mass+radius globals are DEFINED but have zero sampled active consumers | [O] P9-T grep (definitions only) |
| 7 | Birth/build/none/ship-init switches + order-dependence + `0.16*0=0.0` are donor-exact per cited sites | [O] §3 S1-S12 |
| 8 | Field offsets, in-binary defaults, `3`-prefix meaning and the solver law are unrecovered statically | [U] U-offsets/U-ctor/U-prefix/U-solver/U-mass-switch/U-radius-switch with S-* captures |
| 9 | Port differs at §5 sites; each row has a donor-faithful inert-data replacement; `data.gd/game.gd` rows are specified, not edited | [O] port lines + donor facts |
| 10 | Every [U] has a zero-mismatch two-unit shove capture; none is closed by a port fallback; no numeric invented | [D] this report |
| 11 | Any port visual equals donor shove/separation/motion | **Denied** — no same-camera donor/port A/B exists; parity UNVERIFIED |

## 9. Scope statement

Exactly one repository file was written by this worker: this report. All donor reads were read-only against pin `t_87f0f3c130b0` (every binary call with `document=` pinned; global target untouched) and the read-only `C:\Games\Cossacks 3\data` tree. No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod state was changed. No donor parity, similarity score, threshold or gate PASS is claimed. Network is out of scope.

*End of DEC-U-INERTIA-RTTI.*
