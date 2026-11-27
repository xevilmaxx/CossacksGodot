---
id: DEC-U-MOVE-SPEED
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-MOVE-SPEED — mechanical per-sid movement-speed / turn-rate / terrain-cost inventory, formation-state and carry/load modifiers, data.gd/game.gd change list"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_move_speed.md
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_ASSET_CONFIG_GODOT_GIT_EDIT
created: 2026-11-26
labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
parity_guard: "NO DONOR PARITY IS CLAIMED. No same-camera donor/port A/B frame was produced or examined. Every donor statement is a read-only text/byte/VA/decomp observation; every port statement is a read-only source line. 'Required donor-faithful replacement' names the algorithm to implement, not a claim it is implemented."
scope_guard: "Exactly one repo file written (this report). No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod edit. Donor binary and donor data read READ-ONLY; no donor executable run, no donor bytes copied into the repo. Singleplayer skirmish only; network/multiplayer/lobby/Steam/replay-sync explicitly OUT OF SCOPE."
donor_pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE x86, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c, Deep mode. Every binary call in THIS job passed document=t_87f0f3c130b0 explicitly; global active target was already t_87f0f3c130b0 and was never changed."
port_scope: "app/scripts/data.gd + app/scripts/game.gd (read-only line citations; change list is specify-only, no edit). variant3d/scripts/* noted only where the same table exists."
prior_reports_read:
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_collision_full.md (§1-§4, px radii, formation 0.30/0.45 m, centred mask)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_inertia_rtti.md (§2-§4, CI numeric surface, order-dependence)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_market_tail.md (§0-P, script/engine split method)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_guard_sampler.md (§0-P, live-vs-TEXT discipline)
context_delta: "Prior workers recovered collision radii, formation 8/12 px defined-but-unconsumed, guard cadences, and the script/engine split method, but left per-sid movement speed / acceleration / turn rate / terrain-cost modifiers uncatalogued. Port game.gd/data.gd carry labelled speed approximations. This worker mechanically inventories the donor speed surface and specifies the port change list."
---

# DEC-U — movement speed / turn / terrain-cost audit (donor 1:1, per-sid rows)

> READ-ONLY. No approximation endorsed. Each `[U]` ends in a named fixed-seed movement trace, never in a port fallback. No speed or modifier is invented here.

## 0. Method, labels, passes

- **[O]** = observed donor file line / binary VA / port line. **[D]** = arithmetic over cited [O]. **[I]** = reading without runtime proof. **[U]** = unresolved after passes here.
- Path shorthands: `D:` = `C:\Games\Cossacks 3\data\` (read-only donor tree). `P:` = workspace `app\scripts\`. `c3` = `t_87f0f3c130b0`.
- `ev_<hex>` = Craft Anything evidence id of a pass in **this** job (all `document=t_87f0f3c130b0` for binary calls). `ev(carried)` = id from a prior worker, re-cited not re-run. Donor-text shell reads carry file:line instead of an evidence id (commands listed in §9 provenance).

### 0.1 Pass ledger (pin `t_87f0f3c130b0`, multiple passes; strange-decomp log inline)

| Pass | Operation | Evidence | Result |
|---|---|---|---|
| P1 | `core_session_show` (pin re-assert) | session record (no evidence id; host reply) | [O] active target `t_87f0f3c130b0`, `cossacks.exe` 5,768,048 B, sha256 `87f0f3…4e16c`, Deep mode |
| P2 | `native_strings_find` `TrackPointMoveStepInterval` (literal) | `ev_c78fe7e227a93e1039b499578f7de91c9e32f6606f15e2c7f1f98c3150d10a8a` | [O] ×0 — engine entry name is NOT a binary string |
| P3 | `native_strings_find` `MoveStepInterval` + `RotatingToDirection` (literal) | `ev_ee041e4c464b9ba6cb4cd1d01f3d1306f2d7d023e538f150c8978d63196ea8d7` (×0), `ev_91862ed47726a6cce412c87fe8204f3c2a147e534711303b92011b13363438cd` (×0) | [O] both ×0 — same ordinal-binding verdict as inertia worker |
| P4 | `native_strings_find` `rotatespeed` / `IntervalFactor` / `walkinterval` / `fishingspeed` (literal) | `ev_7e200c3bc4adb2b5eac64e988a90b363cfb0e96b988361d95855983d85749050` (×0), `ev_183a07c02072ddb4c47cda2f693664cc7e6dd2c2020ee4db8de8604df8f5592b` (×0), `ev_e4c04dbbab44aa65ff410500d818bdc8f34b18291b501c3c5b38233d8ab38718` (×0), `ev_4b21ac01973b16d0ffd188bf8bc9c4141a9122a7bab9ecf2c2381ce6612d0920` (×0) | [O] all ×0 — no CI/speed script identifier is embedded in the image |
| P5 | `native_strings_find` `motionstyle` / `MovementMode` / `MaxSpeed` / `Deceleration` (literal) | `ev_4c587832a258c2eb0a80792b5f124f4193479d84645e4aa9ee54bfdb79237bd1` (×0), `ev_a456837457a73f6136a3e4906a5477e33ae7f29dc57a7e39fe1cd306114b4f02` (×0), `ev_0beb648096990133531ad7a05dc61492e9576fec570acbae9165360abdc42660` (×0), `ev_47319d02dccce88ee095b224707a942031738b2c42d8c3dc39efab7b67765fa5` (×0) | [O] all ×0; `Deceleration`/`RotationSpeed` hits in `weapon.script:924-939` are projectile-behaviour setters, not unit locomotion |
| P6 | `native_strings_find` `XCollision` (control) + `TrackPoint` | `ev_8cd423c37f875fe9b4f5dfaba71cd60c14f25d953f3b89dd9081b8bdd7eaca9a` (3: `0x9589c7 XCollisionMask`, `0x958a13 XCollisionTags`, `0x95972b 3XCollisionInertia`, all `.rsrc`), `ev_e9454790fa4bd271c5f2c181361dd8ccc7d7d84b5f76906c65066525f2900a08` (2: `0x958801 XTrackPoint`, `0x95908d }XTrackPointPreset`) | [O] locomotion class names exist ONLY as `.rsrc` registration strings, same mechanism as prior workers |
| P7 | `native_xrefs_list` `0x958801` + `0x95908d` | `ev_0469cbba540c17db26bf3068053905524da42d078a09504bad405596abcaa21f` (0 refs), `ev_dec56d4b56ce1b1ac73bb960a7a352b7df7e687b82b610e53bb659db10000075` (0 refs) | [O] 0 xrefs either way — classes resolve at runtime via the persistent-class registry, not static pointers [D, same inference as DEC_U_collision_full §0.1-P4] |
| P8-T | donor text `dmscript.global:170-176` (conversions) + `:603-628` (speed/turn constants) | shell reads (file:line cites, §1/§3) | [O] conversion row + 18 speed constants + 6 turn constants (§1.2, §3.1) |
| P9-T | donor text `lib/unit.script:595-618` (walk consts + `InitBase speed:=1`) + `:1192/:1322/:1420/:1546/:1699-2037` (all speed use sites) + `lib/classes.script:3579-3604/3641-3672` (`TObjBase.speed`, `TObjProp` defaults) | shell reads (file:line cites, §1.3-§1.4) | [O] every per-sid `objbase.speed` assignment is `//`-commented OUT except `:618`; class default is 32 but is overwritten by `:618` |
| P10-T | donor text `lib/player.script:1927-1944` (speedperc upgrade) + `lib/serial.script:516` + `lib/country.script:3639` (shipspeed +40) + `lib/unit.script:11054-11173` (anim/rotate consumers) | shell reads (file:line cites, §3.3/§6) | [O] only LIVE speed-mutating path is the `speedperc` divisor + TrackPoint interval Floor path (§6) |
| P11-T | donor text `lib/group.script:115-160` (formation pitch) + `lib/unit.script:1698-2039` (motionstyle/rotatespeed rows) + `units/unit.inc/*` + full-lib `accel/MaxSpeed/carry/terrain` greps | shell reads (file:line cites, §2-§5) | [O] no accel rows, no terrain-cost rows, no formation/carry speed factors in sampled script (§2.1, §4.1, §5.1) |
| P12-P | port read `P:data.gd` speeds/consts + `P:game.gd` `effective_speed`/`_step_move`/`_blocked_for` + `app/MECHANICS.md:238-250` movement table | read-only (§7) | [O] port speed ladder + three port-only modifiers (§5.4, §7) |

**Strange-decomp log (required):** no function decompilation was attempted for locomotion: P2-P5 prove no name-anchored caller exists (zero function-name, entry-name and property-name strings, zero xrefs from both `XTrackPoint*` registration strings). Any pseudo-C attribution of an arbitrary `sub_*` to movement would be a guess, so none is offered. The P5 `weapon.script` `Deceleration`/`RotationSpeed` hits were checked and discarded as projectile-behaviour setters (`SetBehaviourFloatProperty(bHnd, …)`, `weapon.script:924/934-939`), not unit locomotion [D].

---

## 1. Per-sid `MaxSpeed` / `Speed` rows: DEFINED constants, DEAD consumers

### 1.1 Canonical constants [O] (`D:scripts/dmscript.global:603-620`)

| Donor constant | Value (px units [O]) | [D] m/s at `px/26.6666666` | [D] tiles/s at `/53.3333333` |
|---|---|---|---|
| `gc_obj_speed_default` (`:603`) | 32 | **1.20** | 0.60 |
| `gc_obj_speed_peasant` (`:604`) | 40 | **1.50** | 0.75 |
| `gc_obj_speed_hardhorse` (`:605`) | 56 | **2.10** | 1.05 |
| `gc_obj_speed_fasthorse` (`:606`) | 96 | **3.60** | 1.80 |
| `gc_obj_speed_cannon` (`:607`) | 20 | **0.75** | 0.375 |
| `gc_obj_speed_mortar` (`:608`) | 24 | **0.90** | 0.45 |
| `gc_obj_speed_howitzer` (`:609`) | 20 | **0.75** | 0.375 |
| `gc_obj_speed_multicannon` (`:610`) | 16 | **0.60** | 0.30 |
| `gc_obj_speed_fishboat` (`:612`) | 16 | **0.60** | 0.30 |
| `gc_obj_speed_ferry` (`:613`) | 28 | **1.05** | 0.525 |
| `gc_obj_speed_yacht` (`:614`) | 40 | **1.50** | 0.75 |
| `gc_obj_speed_yachttur` (`:615`) | 70 | **2.625** | 1.3125 |
| `gc_obj_speed_chaika` (`:616`) | 55 | **2.0625** | 1.03125 |
| `gc_obj_speed_galley` (`:617`) | 40 | **1.50** | 0.75 |
| `gc_obj_speed_frigate` (`:618`) | 30 | **1.125** | 0.5625 |
| `gc_obj_speed_xebec` (`:619`) | 28 | **1.05** | 0.525 |
| `gc_obj_speed_battleship` (`:620`) | 16 | **0.60** | 0.30 |

Conversions [O] (`dmscript.global:170-175`): `gc_pixels_to_meter = 26.6666666`, `gc_pixels_to_tile = 53.3333333`, `gc_frames_to_time = 0.03125` (32 fps logic). Units of the speed constants ("px/s") are **[I] per `app/MECHANICS.md:238`** ("speeds are pixels/second") — the donor text itself states no unit. The m/s column above is therefore exact arithmetic on an [I]-labelled unit, not a donor unit claim.

### 1.2 The port's reading is arithmetically exact — and semantically unproven

`app/MECHANICS.md:240-250` maps the same constants to the same m/s values (32→1.20, 40→1.50, 56→2.10, 96→3.60, 20→0.75, 24→0.90). The port `UNITS_BASE` ladder (`P:data.gd:579-1239`) reproduces that map exactly:

- foot 1.2 (`pikeman:588`, `roundshier:597`, `serdiuk:606`, `archer:616`, `officer:645`, …), peasant 1.5 (`:579`), support 1.32/1.1 (`drummer:684`, `priest:693`, …), hardhorse 2.1 (`dragoon:635`, …), fasthorse 3.6 (`cossack:626`, …), cannon/howitzer 0.75 (`cannon:654`, `howitzer:1137`), mortar 0.9 (`mortar:742`), multicannon 0.6-class (`framegun:987` 0.7 — see §7).
- naval ladder 2.2-2.9 (`yacht:1150` 2.8 … `battleship:1230` 2.2) is PORT ESTIMATE per the file's own comment (`P:data.gd:1146-1172`: "hp/speed/dmg/price are ESTIMATED … PORT ESTIMATES … speed … NOT donor-verbatim").

The arithmetic agreement is [D]-verified. The semantic claim "donor moves at these m/s" is **[U] U-speed-consumer** (see §1.4).

### 1.3 Every per-sid speed assignment is commented out [O]; the live value is `1`

- Class default [O] (`D:scripts/lib/classes.script:3594-3600`): `TObjBase.Create` sets `speed := gc_obj_speed_default` (= 32).
- Live overwrite [O] (`D:scripts/lib/unit.script:617-618`, inside `_unit_InitBase`): `objbase.shield := 0; objbase.speed := 1;` — unconditional, runs for every sid that reaches `InitBase`.
- Per-sid overrides [O] (full-file grep, P9-T): **all 17 are `//`-commented dead text** — `:1192` peasant, `:1322` fasthorse branch, `:1420/:1546` hardhorse branches, `:1699` cannon, `:1735` howitzer, `:1767` mortar, `:1796` multicannon, `:1826` cannon-framegun, `:1857` fishboat, `:1875` yacht, `:1906` yachttur, `:1924` galley, `:1961` frigate, `:1991` xebec, `:2001` battleship, `:2015` chaika, `:2035` ferry. Zero live `objbase.speed :=` writes exist outside `:618` in the sampled tree.
- Companion field [O] (`classes.script:3579/3603-3604`): `fishingspeed : Integer` in `TObjBase`; live writes only `unit.script:1865` (`fishingspeed := 50 div 4` = 12 [D]) and the `player.script:1902` upgrade scaling + `:11934/:12114` roundings — gathering cadence, not locomotion (see §5.3).

[D] consequence: after `InitBase`, every sid's `objbase.speed` is `1` unless a later live write changes it. The only later live writes found are the serial-compat pin (`serial.script:516`: `speed := 1` for `gSerialVersion<91`) and the `speedperc` upgrade divisor (§6). **The 18-row §1.1 table therefore has no sampled live consumer.** The live locomotion speed, if it reads script at all, is NOT any of the 17 commented constants.

### 1.4 What remains [U] U-speed-consumer

- **[U] U-speed-consumer-open:** (a) mechanical proof that no other live `objbase.speed` / `.speed` write exists outside `unit.script:618`, `player.script:1930/1936`, `serial.script:516` (one full-tree `\.speed :=` grep excluding `//`, recipe §9); (b) what native locomotion actually integrates per tick — TrackPoint step/turn intervals are engine-native (P2-P7 all ×0, `XTrackPoint`/`}XTrackPointPreset` 0-xref); (c) the true unit of the §1.1 constants (px/s is MECHANICS.md [I], not donor text). Until (a)-(c) close, the §1.1 table is DEFINED-but-unconsumed and the port ladder in §1.2 is a labelled approximation, however arithmetically exact. Capture T-SPEED (§8) is the terminator.

---

## 2. Acceleration: NO donor rows found [O-negative]

- Full-`lib` grep for `accel|MaxSpeed|maxspeed|decel` (P11-T) returns **zero locomotion hits** [O]: the only `Deceleration` hit is `weapon.script:924` (`SetBehaviourFloatProperty(bHnd, 'Deceleration', 0)`, projectile behaviour), and the only `RotationSpeed` hits are `weapon.script:934-939` (`rotspeed := 2+RandomExt*8/4`, projectile visual spin).
- No `accel`, `decel`, `ramp`, `lerp-speed` or staged-gear constant exists in `dmscript.global` (P11-T grep on `:1-300` region returns only `gc_BuildingSlowDeathSpeed = 90`, a death-timer, and `gc_obj_motionstyle_slowrotate`, a rotate style — neither is a linear-acceleration row).
- The `speedperc` upgrade path (§6) applies a **step** change (`Floor(interval*speed)`), not a ramp — no acceleration law is implied by it [D].

Port shape [O]: `P:game.gd:4353-4432` `_step_move` integrates `step = minf(speed*dt, d)` with no velocity state — instant target speed, no accel ramp. That shape is **consistent with the absence above** but the absence is a negative grep result, not a positive donor law: acceleration stays **[U] U-accel** with capture T-ACCEL (§8).

---

## 3. Turn rate: LIVE constants + LIVE consumer, native integration [U]

### 3.1 Constants [O] (`dmscript.global:622-628`)

| Constant | Value [O] | Consumer [O] |
|---|---|---|
| `gc_obj_rotatespeed_default` (`:623`) | 5 (old C1 value 16 kept as `//` comment `:622`) | `classes.script:3660` `TObjProp.Create` default; every sid that never overrides |
| `gc_obj_rotatespeed_cannon` (`:624`) | 1 | `unit.script:1701` cannon, `:1828` framegun-cannon branch |
| `gc_obj_rotatespeed_mortar` (`:625`) | 4 | `unit.script:1770` mortar |
| `gc_obj_rotatespeed_howitzer` (`:626`) | 4 | `unit.script:1737` howitzer |
| `gc_obj_rotatespeed_multicannon` (`:627`) | 5 | `unit.script:1798` multicannon |
| `gc_obj_rotatespeed_ships` (`:628`) | 2 | `unit.script:1859/1877/1926/1963/2037` all five ship branches (fishboat/yacht/galley/frigate/ferry; xebec/battleship/chaika inherit the frigate-branch write) |

Unlike §1, **all of these writes are LIVE** (no `//` prefix) [O].

### 3.2 Motion styles [O]

`dmscript.global:296-300`: `motionstyle_default = 0`, `motionstyle_ship = 1`, `motionstyle_slowrotate = 2`. Writes [O]: `unit.script:1698/1734/1766/1825` artillery → `slowrotate`; `:1861/1879/1928/1965/2039` ships → `ship`; default `0` from `classes.script:3664`. What `slowrotate` vs `ship` changes inside native locomotion is unrecovered (no binary strings, P5 ×0) — **[U] U-motionstyle**.

### 3.3 Live consumer [O] (`unit.script:11066`, `DoSetupMoveAnimation` tail)

```pascal
bRotate := GameObjectSetupRotatingToDirectionByHandle(hnd, dx, dy, dz, anim, anim, anim, gObjProp[…].rotatespeed*2.225, 50, GetGameObjectEpsilonAngleByHandle(hnd), True);
```

The `*2.225` factor and the `50` + epsilon + `True` trailing args are donor-verbatim [O]. Sibling rotate setups (`:10996/:11001` target/direction variants + `miscext.script` gates + `control.script:444` idle gate) share the entry. The entry itself is engine-native: `RotatingToDirection` has **zero** binary strings (P3 `ev_9186…`) — signature/timing law is **[U] U-turn** with capture T-TURN (§8). The port has NO turn model at all (`_step_move` steers by rotated probes, no rotate-speed state — §7), so every port heading change is instant up to probe granularity.

---

## 4. Terrain-cost modifiers: NO donor rows found [O-negative]

- Full-`lib` greps for `terrain.*slow|slow.*terrain|GetTerrainType|TerrainType.*speed|speed.*terrain|slope|climb|swamp|mud|hill.*speed|water.*speed|speed.*water` (P11-T) return **zero locomotion-cost hits** [O]. `terraintype` in `classes.script:78` is a map-gen field; `gc_terraindata_*` (`dmscript.global:77-81`) are grid dims, not costs; `gc_collisiontag_terrain = 101` and water/border tags are binary blockers (see DEC_U_collision_full §7.2), not multipliers.
- Movement gating in script is **binary**, not scalar [O]: `miscext.script:280/380/459/527/558` (`move_idle/move_walk` tag gates), `unit.script:6091-6093` / `miscext.script:1252/1268` (`GetGameObjectTrackPointMovementModeIntByHandle(hnd)<>0` moving checks), `unit.script:10804` (`SetGameObjectTrackPointMovementModeByHandle(hnd,'mmNone')` stop). No sampled site multiplies speed by terrain, slope, depth or weather.
- Port shape [O]: `P:game.gd:159-196` `_blocked_for` hard-blocks water/cliff/building cells for land units (binary), with NO cost multiplier anywhere on the `_step_move` path. That matches the sampled donor shape (binary gates, no scalar), but the match is an absence-agreement: terrain cost stays **[U] U-terrain** with capture T-TERRAIN (§8). In particular, shallow-water wading, uphill slowdown, bridge/road speedup and swamp/ice rows are all unproven either way — never assume any of them.

---

## 5. Formation-state and carry/load modifiers

### 5.1 Formation state does NOT scale speed in sampled script [O]

- Live pitch law [O] (`group.script:131-148`): commented-out `gc_obj_radius_formation_default/horse` (8/12 px, 0.30/0.45 m — carried from DEC_U_collision_full §4), live `unitRadius := unitRadius*0.8; dispRadius := unitRadius*0.5`, `GroupSetMinX/Y(unitRadius*4)`, `GroupSetOffsetX/Y(dispRadius)`, grid from `TSquad.fWidth/fHeight` + `arGrid` mask gating. This is a POSITION law, not a speed law.
- Full-`lib` + `squad.script` + `group.script` grep for `formation.*speed|speed.*formation|squad.*speed|drummer.*march|march.*bonus` (P11-T): **zero hits** [O]. `squad.script` in full (P11-T head read) exposes officer/drummer slot getters (`_squad_GetOfficer/_squad_GetDrummer`), never a speed factor.
- Formation bonuses in donor text are damage/shield only [O] (`formations.cfg` `bonusdamage/bonusshield/bonusdamagehold/bonusshieldhold`, ported verbatim as `P:data.gd:376-534` `FORMATION_BONUSES`). No speed bonus column exists in any of the 149 records.
- Port `FORMATIONS` shape table (`P:data.gd:368-374`: line/column/square/wedge `cols_mult/rows_mult`) and `FORMATION_SPACING := 1.2` (`P:data.gd:63`) and rally staggering (`P:game.gd:4504-4755`) are **port shaping with no sampled donor speed counterpart** — PORT APPROXIMATION, labelled as such. Formation speed effect stays **[U] U-formation** (T-FORM, §8); the null hypothesis (formation changes only slot positions, never speed) is the current best reading but is NOT proven.

### 5.2 Carry/load does NOT scale speed in sampled script [O]

- `TObj(pobj).resamount` writes [O]: `unit.script:2687` init 0; `:5544` reset; `:9658-9661` clamp to `hitsneeded`. Reads credit `restotal` (`:9569/:11997` per DEC_U_market_tail §4) — economy, not locomotion. No sampled line multiplies any speed/interval by `resamount`, `carry`, `loaded` or `bloaded`.
- Port carry state [O]: `e.carry/e.carry_type` (`P:game.gd:1994/2876-2877/5082-5245`), `GATHER` hits/carry amounts (`P:data.gd:551-556`, donor `dmscript.global:799-806`), delivery runs at `e.def.speed` (`P:game.gd:5228`). The port therefore already implements the donor-consistent null (loaded peasants walk at full speed). Loaded-slowdown stays **[U] U-carry** (T-CARRY, §8) — do not wire one in.

### 5.3 Walk-interval factor is ANIMATION cadence, not velocity [O]

- Constants [O] (`unit.script:595-598`): `cWalkIntervalDonkey = 1.4`, `cWalkIntervalInf = 1.25`, `cWalkIntervalHardHorse = 1.25`, `cWalkIntervalFastHorse = 1`. Per-sid writes are LIVE [O] (`:640-2065`, infantry 1.25 incl. the `:748` 1.12 exception; hardhorse 1.25 at `:1429/:1560/:1686`; donkey 1.4 at `:2065`; default 1 at `classes.script:3667`).
- Consumer [O] (`unit.script:11054-11173`): `animinterval := walkintervalfactor` → `SetGameObjectIntervalFactorByHandle(hnd, animinterval)` when the walk anim (re)starts; death path uses `0.7+random*0.6`. This is the **frame-animation playback rate**. The port reuses `BUILD_HIT_INTERVAL = 1.25` (`P:data.gd:60`, comment `cWalkIntervalInf`) as the build/gather hit cadence — a port adaptation MARKED estimated in MECHANICS.md, not a donor velocity. Velocity effect of `walkintervalfactor`: **[U] U-walkinterval** (T-SPEED logs anim rate alongside position; any correlation is recorded, never assumed).

### 5.4 Port-only speed modifiers (no donor counterpart found — PORT APPROXIMATION)

| Port site [O] | Law | Donor status |
|---|---|---|
| `P:data.gd:89` `DRUMMER_SPEED_BONUS := 0.12` + `P:game.gd:3573-3576` `effective_speed` `aur_dru` branch | +12% march near drummer | **No donor counterpart**: full-lib `drummer.*speed|march.*bonus` grep ×0 (P11-T). Donor drummer rows are formation-slot + upgrade-pack + selection rows only (§0-P11 grep list). PORT APPROXIMATION |
| `P:game.gd:3577-3578` `routing` branch `s *= 1.35` | routing troops run ×1.35 | **No donor counterpart**: donor runaway (`_unit_DoRunAway`, DEC_U_guard_sampler §5) issues a move-mode order with NO speed scalar in sampled text. PORT APPROXIMATION |
| `P:data.gd:62-63` `PERSONAL_SPACE := 0.35` / `FORMATION_SPACING := 1.2` | separation gap / group grid step | **No donor counterpart**: donor separation is the `XCollisionInertia` solver (DEC_U_inertia_rtti §6 [U]) + `unitRadius*0.8/*0.5` pitch (§5.1). PORT APPROXIMATION |
| `P:game.gd:159-196` `_blocked_for` hard water/cliff block | binary | Consistent with sampled donor binary gates (§4), but the exact tag set + border rows stay [U] per DEC_U_collision_full C-CAP-4 |

---

## 6. The one LIVE speed-mutating path: `speedperc` upgrade (divisor + interval Floor)

Law [O] (`D:scripts/lib/player.script:1927-1944`, inside the upgrade-apply loop):

```pascal
gPlayer[plInd].objbase[cid][iarr2[i]].speed := 1/(gPlayer[plInd].objbase[cid][iarr2[i]].speed*(1+value/100));   // :1930
…
var speed : Float = gPlayer[TObj(pobj2).pl].objbase[TObj(pobj2).cid][TObj(pobj2).id].speed;                    // :1936
if (pobj2<>nil) {and _unit_IsWaterUnit(trgHnd)} and (speed>0) and (speed<>1) then                              // :1938
begin
   var movestepinterval : Float = GetGameObjectTrackPointMoveStepIntervalByHandle(trgHnd);                    // :1940
   SetGameObjectTrackPointMoveStepIntervalByHandle(trgHnd, Floor(movestepinterval*speed));                     // :1941
   var turnstepinterval : Float = GetGameObjectTrackPointTurnStepIntervalByHandle(trgHnd);                    // :1942
   SetGameObjectTrackPointTurnStepIntervalByHandle(trgHnd, Floor(turnstepinterval*speed));                     // :1943
end;
```

[D] consequences (load-bearing, read carefully):

1. `objbase.speed` is a **descending interval divisor**, not a velocity: base `1`, upgrade with `value` percent maps `s → 1/(s·(1+v/100))`. First application with `s=1, v=40` (shipspeed, `country.script:3639` `upgplace+'.28'`, `gc_upg_type_speedperc, 40`) yields `s = 1/1.4 ≈ 0.7142857`. A second stacking application would yield `1/(0.7142857·1.4) = 1.0` — the donor formula **oscillates** rather than compounding; whether upgrades ever stack on one sid is unsampled ([U] U-upg-stack).
2. The live TrackPoint rewrite is **water-gated in the visible branch**: `{and _unit_IsWaterUnit(trgHnd)}` sits inside a `{…}` comment-brace whose engine semantics (comment vs condition) are DSL-ambiguous — the `//`-vs-`[*]` DSL proof from DEC_U_guard_sampler §0-P17 does NOT cover `{…}`. Whether land units take this path is **[U] U-upg-gate** (T-UPG, §8). The `Floor()` quantisation and the `(speed>0) and (speed<>1)` skip are donor-verbatim.
3. The registration site (`player.script:1721-1730`, `sarrparam2` → `iarr2` id mapping) runs at upgrade-apply; the serial pin (`serial.script:516`, `speed := 1` for `gSerialVersion<91`) restores the pre-upgrade divisor on old saves.
4. Fishing cadence has its own upgrade [O]: `gc_upg_type_fishingperc = 19` (`dmscript.global:757`) scaling `fishingspeed` at `player.script:1902` — economy cadence, not locomotion; not conflated with `speedperc` here.

Port gap [O]: NOTHING in `P:data.gd`/`P:game.gd` implements `speedperc`, the `1/(s·(1+v/100))` divisor, the `Floor(interval·speed)` rewrite, or the shipspeed +40 upgrade. The port naval ladder (§1.2) is static. This is the single largest proven locomotion delta: §7-U2 specifies the replacement without editing.

---

## 7. Exact port change list (`data.gd` / `game.gd`; specify-only, no edit)

Conventions: port site [O] with as-read line; donor fact [O]/[D] from this job; replacement names the algorithm. Line numbers are provenance-only — concurrent workers edit both files, so re-anchor by **const/function name + verbatim text**. Zero port edits were made by this worker.

| # | Port file:line (current [O]) | Donor fact (this job [O]/[D]) | Required donor-faithful replacement (no parity claim) |
|---|---|---|---|
| S1 | `P:data.gd:579-1239` `UNITS_BASE` `"speed"` ladder (foot 1.2, peasant 1.5, support 1.32/1.1, hardhorse 2.1, fasthorse 3.6, artillery 0.7-0.9, naval 2.2-2.9) | §1.1 constants [O] + §1.3 dead-consumer verdict [O] + §1.2 arithmetic agreement [D] | KEEP values (they equal §1.1×`PX_TO_M`), but re-tag EVERY `"speed"` row comment: land rows = `DEFINED-BUT-UNCONSUMED donor constants (unit.script:618 forces 1; per-sid writes //dead) — PORT APPROXIMATION [U] U-speed-consumer`; naval rows keep their existing `PORT ESTIMATES (NOT donor-verbatim)` flag (`:1162-1163`) and ADD the §1.1 ship constants as a separate `DONOR_SHIP_SPEED_CONST` block (16/28/40/70/55/40/30/28/16 px, `:612-620`) that is DATA ONLY until T-SPEED closes. Never present the ladder as donor-verified locomotion |
| S2 | (no live port site) — `speedperc` upgrade absent from `P:data.gd`/`P:game.gd` | §6 law [O]: `1/(s·(1+v/100))` divisor (`player.script:1930`), `Floor(interval·speed)` move+turn rewrite (`:1940-1943`), shipspeed +40 (`country.script:3639`), serial pin `:=1` (`serial.script:516`) | ADD three inert data rows (no consumer wiring): (a) `DONOR_SPEED_DIVISOR_INIT := 1.0` (`unit.script:618`, `serial.script:516`); (b) `DONOR_UPG_SPEEDPERC := {ships28: 40}` (`country.script:3639`, `gc_upg_type_speedperc=22` at `dmscript.global:759`); (c) `DONOR_SPEED_FORMULA := "s := 1/(s*(1+v/100)); Floor(moveI*s); Floor(turnI*s)"` (`player.script:1930-1943`) with the `{and _unit_IsWaterUnit}` gate marked `[U] U-upg-gate` + stacking marked `[U] U-upg-stack`. WHEN a consumer is ever wired (not this ticket): reproduce the divisor EXACTLY (including the non-compounding oscillation) and the `Floor` quantisation; gate it behind T-UPG |
| S3 | `P:game.gd:3573-3579` `effective_speed` (`aur_dru +12%`, `routing ×1.35`) + `P:data.gd:89` `DRUMMER_SPEED_BONUS` | §5.4 negative greps [O]: no donor drummer/routing speed scalar in sampled script | Tag both branches `PORT APPROXIMATION [U] U-carry/U-formation family` with this report cite; ADD `DONOR_ROTATE_SPEEDS := {default: 5, cannon: 1, mortar: 4, howitzer: 4, multicannon: 5, ships: 2}` + `DONOR_ROTATE_LAW := "rotatespeed*2.225, 50, epsilon" (unit.script:11066)` as DATA ONLY (no steering consumer until T-TURN). Do NOT retune 12%/1.35 — remove or gate them when T-FORM/T-CARRY close |
| S4 | `P:game.gd:4353-4432` `_step_move` (`step = minf(speed*dt, d)`, probe steering, no velocity state, no turn state) | §2 absence [O-negative] + §3.3 rotate consumer [O] + §4 binary gates [O] | KEEP the integrator; ADD comments: (a) `no accel state — matches zero sampled donor accel rows [U] U-accel (T-ACCEL)`; (b) `no turn-rate state — donor rotatespeed*2.225 law (unit.script:11066) NOT modelled [U] U-turn (T-TURN)`; (c) `no terrain scalar — donor sampled shape is binary gates only [U] U-terrain (T-TERRAIN)`. No behaviour change |
| S5 | `P:game.gd:159-196` `_blocked_for` (hard water/cliff block) + `P:data.gd:22-23` `PX_TO_M/TILE_M` + `FRAMES_TO_TIME` | Conversions [O] `dmscript.global:170-175`; tags in DEC_U_collision_full §7.2 [O] | No change. Radii/speed conversions must use `PX_TO_M = 1/26.6666666` (already donor-derived); never the estimated `TILE` stride. Water/blocked semantics inherit the C-CAP-4 capture, not this ticket |
| S6 | `P:data.gd:62-63` `PERSONAL_SPACE/FORMATION_SPACING` + `:60` `BUILD_HIT_INTERVAL` + `FORMATIONS :368-374` shape mults | §5.1/§5.3 [O]: pitch `unitRadius*0.8/*0.5` (`group.script:131-148`), `walkintervalfactor` anim cadence (`unit.script:595-598/11054-11173`), formation bonuses damage/shield-only (`formations.cfg`) | Re-tag all four as `PORT APPROXIMATION [U] U-formation/U-walkinterval` with this report cite; ADD `DONOR_FORMATION_PITCH := "unitRadius*0.8, dispRadius=*0.5, min*=4 (group.script:131-148)"` + `DONOR_WALK_INTERVALS := {inf: 1.25, hardhorse: 1.25, fasthorse: 1.0, donkey: 1.4, exc_748: 1.12}` as DATA ONLY |

Required donor asset manifest (sourced through approved converters, **not copied here**): `D:scripts/dmscript.global` (`:170-176`, `:296-300`, `:603-628`, `:752-760`), `D:scripts/lib/classes.script` (`:3579-3604`, `:3641-3672`), `D:scripts/lib/unit.script` (`:595-618`, `:1192/:1322/:1420/:1546/:1699-2037` speed sites, `:1698-2039` motionstyle/rotatespeed, `:11054-11173` anim/rotate), `D:scripts/lib/player.script` (`:1721-1730`, `:1927-1944`), `D:scripts/lib/serial.script` (`:516`), `D:scripts/lib/country.script` (`:3639`), `D:scripts/lib/group.script` (`:115-160`), `D:scripts/units/unit.inc/*` (speed-modifier exclusion sweep), `D:game/var/formations.cfg` (no speed column proof).

---

## 8. Fixed-seed movement traces (zero-mismatch termination; never invent a speed)

General harness (all T-*): singleplayer skirmish, fixed map seed (record `randkey0/1`), flat open ground (no slope/buildings/trees; T-TERRAIN excepted), fixed camera (position/yaw/pitch/fov logged + capture id), headless fixed-`dt` (= 1/32 s, `gc_time_to_frames`), seeded RNG re-seeded per series, canonical JSON state hash (players, entities, positions, orders, RNG counters). Assertions read positions/handles, never pixels. **Termination rule (all): run the FULL stated series; ANY single positional/temporal mismatch vs the stated donor expectation keeps the item [U] and forbids wiring; zero mismatches across the FULL series closes it.** Never fit or invent a rate, ramp, scalar or gate.

- **T-SPEED (U-speed-consumer: steady-state velocity per class):** one unit per class (peasant, foot, hardhorse, fasthorse, cannon, mortar, howitzer, multicannon, all 7 ship sids), spawn at surveyed origin, order straight 20 m march (ships: 40 m sail), no orders/formation/aura/upgrades. Log per-tick `(pos, tick)` for the full transit. Pass = per-class mean velocity over the middle 50% of transit matches its §1.1 [D] m/s cell within the harness quantisation (±1 tick / ±0.05 m) with 0 mismatches across 5 trials × 15 classes; first mismatch stops the run with its capture id. Decides whether ANY §1.1 constant is the live speed.
- **T-TURN (U-turn/U-motionstyle: rotate timing):** foot, cannon (`slowrotate`, rate 1), ship (`ship`, rate 2) units; from standstill order 90° then 180° facing changes (no translation). Log per-tick facing + translation start tick. Pass = turn duration ordering matches rate ordering (5 < 4 < 2 < 1, ships slowest) with 0 mismatches across 10 trials × 3 classes; records whether `*2.225` predicts absolute durations (asserted, never fitted).
- **T-ACCEL (U-accel: start-from-rest ramp):** foot + fasthorse + cannon; from `mmNone` order 10 m march. Log first 32 ticks of `(pos, per-tick displacement)`. Pass = 0 mismatches vs the step hypothesis (first-tick displacement already equals steady-state `v·dt` within quantisation) across 10 trials × 3 classes; any systematic ramp keeps [U] and NOTHING is wired.
- **T-TERRAIN (U-terrain: cost vs binary gate):** foot unit marches 20 m across (a) flat, (b) max-slope climbable, (c) shallow-water edge lane, (d) bridge deck where present. Log transit ticks per lane. Pass = all four lanes match within ±1 tick (null-cost hypothesis) with 0 mismatches across 10 trials; any systematic lane delta keeps [U] and is filed as a measured table, never as a fitted scalar.
- **T-FORM (U-formation: squad vs solo):** 12-foot squad in `LINE8` vs 12 solo feet, same 20 m order; then squad `LINE3` vs `COLUMN` analog. Log per-unit arrival ticks + slot offsets. Pass = squad mean arrival matches solo mean within ±2 ticks AND slot offsets match the `unitRadius*0.8/*0.5` pitch law with 0 mismatches; any formation speed delta keeps [U].
- **T-CARRY (U-carry: loaded vs empty):** peasant empties shuttles 10 m storehouse↔tree lane empty then full (`resamount>0` both directions logged). 20 round trips. Pass = loaded-leg and empty-leg transit ticks identical within ±1 tick with 0 mismatches; any delta keeps [U].
- **T-UPG (U-upg-gate/U-upg-stack: shipspeed +40):** pre-upgrade 40 m sail baseline (each ship sid × 5), then apply `aca.28`-class `speedperc 40`, then 40 m sail; then (stacking probe, if the engine permits) apply a second `speedperc` and sail again. Log TrackPoint move/turn intervals where the harness exposes them + transit ticks. Pass = post-upgrade intervals equal `Floor(pre·(1/1.4))` with 0 mismatches AND land-unit intervals unchanged (decides the `{and _unit_IsWaterUnit}` gate); stacking run decides oscillation vs compounding with 0 mismatches. Until green, NOTHING from §6 is wired.

---

## 9. Provenance appendix + recipes to close the [U]s (read-only)

Donor text reads in this job (all read-only `Get-Content`/`Select-String`, no donor binary executed, nothing copied into the repo): `dmscript.global:170-176, 296-300, 603-628, 752-760`; `classes.script:3579-3604, 3641-3672`; `unit.script:595-618, 1192, 1322, 1420, 1546, 1699-2037, 11054-11173`; `player.script:1721-1730, 1927-1944`; `serial.script:516`; `country.script:3639`; `group.script:115-160`; `squad.script` head (officer/drummer getters); `units/unit.inc/*` listing; `formations.cfg` head (mask/bonus shape). Binary (all `document=t_87f0f3c130b0`, Deep): P2-P7 table (§0.1) with VAs `0x9589c7/0x958a13/0x95972b` (`.rsrc`, carried mechanism) + `0x958801 XTrackPoint` / `0x95908d }XTrackPointPreset` (`.rsrc`, 0-xref this job). Port (read-only): `P:data.gd:22-23/60/62-63/89/368-374/551-556/579-1239`, `P:game.gd:159-196/3573-3579/4353-4432`, `app/MECHANICS.md:238-250`.

Mechanical recipes (no binary needed): (i) full-tree `\.speed :=` sweep excluding `//` lines — closes U-speed-consumer-a (expected: only `unit.script:618`, `player.script:1930`, `serial.script:516` survive); (ii) full-tree `rotatespeed :=` sweep — closes the turn-constant table (expected: §3.1 sites only); (iii) `{and …}` brace-semantics read of `player.script:1938` against 2-3 neighbouring `{…}` uses — closes U-upg-gate textually; (iv) `formations.cfg` full `bonus` column scan — closes the no-speed-bonus proof.

---

## 10. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | §1.1 constants + conversions are donor-exact text; m/s column is exact arithmetic on a MECHANICS.md-labelled unit | [O] `dmscript.global:603-620/170-175` + shell reads; [D] divisions; [I] px/s unit |
| 2 | All 17 per-sid `objbase.speed` writes are `//`-dead; live value after `InitBase` is `1`; class default is 32 | [O] `unit.script` sites + `classes.script:3594-3600` |
| 3 | No `accel/MaxSpeed/decel` locomotion rows exist in sampled script; `Deceleration/RotationSpeed` hits are projectile-only | [O] P11-T greps + `ev_4c58…/ev_4731…` + `weapon.script:924-939` |
| 4 | Turn constants + motionstyles + `rotatespeed*2.225` consumer are donor-exact live text; native integration unrecovered | [O] §3 sites; [U] U-turn/U-motionstyle (P3 ×0, 0-xref) |
| 5 | No terrain-cost / formation-speed / carry-speed scalar exists in sampled script; gates are binary | [O] P11-T greps; [U] U-terrain/U-formation/U-carry |
| 6 | `walkintervalfactor` rows are live but drive anim rate (`SetGameObjectIntervalFactorByHandle`), not proven velocity | [O] `unit.script:595-598/11054-11173` |
| 7 | `speedperc` divisor + `Floor(interval·speed)` + shipspeed-40 + serial pin are donor-exact; water-gate + stacking open | [O] `player.script:1927-1944` + `country.script:3639` + `serial.script:516`; [U] U-upg-gate/U-upg-stack |
| 8 | `XTrackPoint/}XTrackPointPreset` exist only as 0-xref `.rsrc` strings; movement binding is ordinal, like CI | [O] `ev_e945…/ev_0469…/ev_dec56…` |
| 9 | Port differs at §7 sites; each row has a donor-faithful inert-data replacement; `game.gd/data.gd` rows are specified, not edited | [O] port lines + donor facts |
| 10 | Every [U] has a mechanical recipe or a zero-mismatch fixed-seed trace; none is closed by a port fallback; no numeric invented | [D] this report |
| 11 | Any port visual equals donor march/turn/formation motion | **Denied** — no same-camera donor/port A/B exists; parity UNVERIFIED |

## 11. Scope statement

Exactly one repository file was written by this worker: this report. All donor reads were read-only against pin `t_87f0f3c130b0` (every binary call with `document=` pinned, global target untouched) and the read-only `C:\Games\Cossacks 3\data` tree. No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod state was changed. No donor parity, similarity score, threshold or gate PASS is claimed. Network is out of scope.

*End of DEC-U-MOVE-SPEED.*
