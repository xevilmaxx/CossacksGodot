---
id: DEC-U-SMOKE-BURN-TTL
swarm: TERRAIN-SWARM-2026-11-26 / PORT1TO1-NO-APPROXIMATION
role: "WORKER DEC-U-SMOKE-TTL — donor 1:1 building-death burn/smoke/explosion/sound static recovery"
owner_file: docs/terrain_swarm_2026-11-26/reports/DEC_U_smoke_burn_ttl.md
status: DELIVERED__READ_ONLY__ONE_REPORT_ONLY__NO_CODE_ASSET_CONFIG_GODOT_GIT_EDIT
created: 2026-11-26
labels: [O, D, I, U, NO_PARITY_CLAIM, NO_APPROXIMATION]
parity_guard: "NO DONOR PARITY IS CLAIMED. No same-camera donor/port A/B frame was produced or examined. Every donor statement is a read-only file/line observation; every port statement is a read-only source line. No duration, loop count, or TTL is invented."
scope_guard: "Exactly one repo file written (this report). No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod edit. Donor binary and donor data tree read READ-ONLY; no donor executable run, no donor bytes copied into the repo. Singleplayer skirmish only."
donor_pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe (PE x86, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c). Data tree C:\\Games\\Cossacks 3\\data read READ-ONLY. Pin re-verified this session via certutil (ev_pin_reverify)."
port_scope: "variant3d/scripts/world3d_entities.gd + variant3d/scripts/world3d_fx.gd (read-only line citations)"
prior_reports_read:
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_aaf_art_audit.md ([U]-B/[U]-F/[U]-S framing, §4-§5)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_pfx_scale.md (Interval×FrameRate=1000 law, samLoop+Free=False never-free rule, E-U3/E-U7 captures)
  - docs/terrain_swarm_2026-11-26/reports/DEC_U_entities_art_collision.md (death-branch mesh/child/explosion anchors, E-U14)
  - docs/terrain_swarm_2026-11-26/reports/PORT1TO1_objects_anim_collisions_fx.md (§1.5, §3)
  - docs/coord_swarm_2026-11-25/reports/DBUILD_02.md + DBUILD_01_building_stages.md (30/30 staging, mine ×2, grenadeexp key carried — re-verified, not re-derived)
---

# DEC-U — building-death burn / smoke stop / explosion / sound (static recovery)

> READ-ONLY. Singleplayer skirmish only. No parity claim. No approximation endorsed.
> Each `[U]` ends in either a static verdict with cited bytes/lines, or a named GPU/runtime capture.
> The 30-valued constants are destroy-scheduling keys, never a visual TTL — endorsed nowhere in this report.

## 0. Method, labels, passes

- **[O]** = observed donor file line / port line. **[D]** = arithmetic over cited [O]. **[I]** = reading without runtime proof. **[U]** = unresolved after the passes here.
- Path shorthands: `D:` = `C:\Games\Cossacks 3\data\` (read-only). `P:` = workspace `variant3d\`. `c3` = pin `t_87f0f3c130b0`.
- `ev_` ids below are this session's pass-evidence ids (all against the pin; binary never executed; donor text is the cited `path:line` itself, verified by a second read pass where noted).

### 0.1 Pass ledger (multiple passes on the pin; strange-read log inline)

| Pass | Operation (read-only) | Evidence | Result |
|---|---|---|---|
| P1 | Pin re-verify: `certutil -hashfile cossacks.exe SHA256` | `ev_pin_reverify` | `87f0f3c130b0…`, `5,768,048 B` [O] — pin confirmed, binary not executed |
| P2 | Full read `D:pfx/source.pfx:1808-2194` (4 building keys) + `:1003-1222` (grenade keys) + `:1590-1720` (distexp keys) | `ev_pfx_burn_full`, `ev_pfx_gren_full`, `ev_pfx_distexp_full` | `buildingfirestart/buildingsmokestart` samPlayOnce+Free, `buildingfire/buildingsmoke` samLoop+`Free=False`+`BirthTime=1.792`; `grenadeexp` samPlayOnce+FreeToPool, `grenadesmoke` samPlayOnce+Hide, `distexpflare` 1f/50 ms Hide, `distexpring` 1f/100 ms+StartTime 0.1 Hide [O] (§1) |
| P3 | Full read `D:pfx/fx.tree:215-252` (grenadeexp), `:397-442` (expflash, buildingsmoke) | `ev_tree_death_fx` | `grenadeexp`=4 children `parentrandom=true`; `expflash`=2 children `parentrandom=true`; `buildingsmoke`=4 children `parentrandom=true`, each `randmirroru=2`, no framerate/pixelratio codes [O] (§1) |
| P4 | Full read `D:scripts/units/building.inc/ontagstates.inc:40-149` + `:240-336` (second read of `:82-91` sound/PFXClear block) | `ev_bld_ontag_full` | Death case: `deathbld` sound request + `MyGameObjectPFXClear` (non-wall) [:82-91]; death branch: mesh swap, beh destroy, misc-child clear, hide 1..n-1, gated `_unit_DoExplosion` [:264-311] [O] (§2) |
| P5 | Full read `D:scripts/units/building.inc/nothing.inc:1-120` + `:293-360` + `:360-424` (both smoke blocks + both `not bdead` gates) | `ev_bld_nothing_full` | Damage smoke is HP/count-driven, `progresstick mod 7` throttled, max +1 attach per qualifying tick; BOTH branches gated on `not arg_obj.bdead` (`:19`, `:293`) → zero attaches after death [O] (§3) |
| P6 | Full read `D:scripts/lib/unit.script:11420-11516` (`_unit_DoExplosion`) | `ev_doexpl_full` | Gate (building-not-weakwall / ship-not-fisher, mask>0), per-mask-cell spawns from `gDestructListBuilding`, sync `SetRandomKey`, tail `GetOrCreate('expflash')`, zero sound calls [O] (§4) |
| P7 | Read `D:scripts/lib/weapon.script:39-48,270-276,367,381,399-425,554,566,614-617` + `D:scripts/units/building.inc/{settagstates.inc:32-53,deathstage1.inc:1-15,deathstage2.inc:1-24,delaydestroy.inc,ondeath.inc}` + `D:scripts/dmscript.global:183-184,1304,1307` + `D:scripts/lib/sound.script:126-144` | `ev_weap_death_full`, `ev_stage_full`, `ev_snd_full` | `cFXBuildingExp='grenadeexp'`; destruct list `[debrisstone,debrisstone,PUEXPBUILDINGDEATH]`; sndind defaults `none`, no `SetWeaponSound` for the three death weapons; `deathbld=53→deathbuilding1/2`, `burn=56→burn1..7` registered but `burn` never requested in recovered script; 30/30 schedule DeathStage1/DeathStage2+destroy, mine ×2, birth-shortcut without ×2 [O] (§4-§6) |
| P8 | Read `D:scripts/lib/misc.script:460-490` (`_misc_FramesToTime`) + grep `DelayExecuteState` arg sites; grep `snd\|Sound` over `building.inc/` (6 hits, all in ontagstates.inc) and over `doexplode.inc` (0 hits) | `ev_timebase_check`, `ev_snd_abs` | `_misc_FramesToTime` exists but is applied at NO death-scheduling call site [O absence]; `doexplode.inc` carries zero sound tokens [O absence] (§6) |
| P9 | Second read of port `P:scripts/world3d_entities.gd:3084-3100,3151-3166,3198-3252` + `P:scripts/world3d_fx.gd:126-142,280-299,304-314,322-334,396-444,755-860` | `ev_port_reread` | Port change-list anchors in §8 [O] |
| P10 | Cross-check against DBUILD_02 §3.1/C3 + DBUILD_01 (30/30 staging, mine ×2 asymmetry, `grenadeexp` per DFX-01 §7.5) | `ev_dbuild_xcheck` | Agree on facts (keys, gates, mine asymmetry); DBUILD's `30×0.03125=0.9375 s` conversion is NOT re-endorsed — time base unproven (§6) [D] |

**Strange-read log:** none blocking. Two deliberate non-endorsements: (a) binary property tables were NOT re-grepped here (already covered by DEC_U P1e-f / PFX P6 — not re-cited as new proof); (b) `MyGameObjectPFXClear` / `EffectClear` / `DelayExecuteState` internals are native — script call sites are [O], engine-side scope/timing is [I]/[U] with captures in §7.

---

## 1. Static PFX truth: the four building keys + the explosion keys [O]

### 1.1 `buildingsmoke` effect = 4 children, shared random, no per-child rate codes

`D:pfx/fx.tree:417-442` (`ev_tree_death_fx`):

| Child | `sourcename` | Codes [O] |
|---|---|---|
| [0] | `buildingfirestart` | `randmirroru=2` only |
| [1] | `buildingsmokestart` | `randmirroru=2` only |
| [2] | `buildingfire` | `randmirroru=2` only |
| [3] | `buildingsmoke` | `randmirroru=2` only |

Header: `effectname=buildingsmoke`, `parentrandom=true` (`:418-419`) [O] — one shared `FillRand` block for all four (rule per DEC_U PFX §4.1, `pfx.script:200-252` carried).

### 1.2 Per-key behaviour: starters self-free at 1.792 s; loopers never self-terminate

`D:pfx/source.pfx` (`ev_pfx_burn_full`):

| Key [O] | Frames / Interval / FrameRate | Product [D] | Mode / end policy [O] | Tint/life colour [O] |
|---|---|---|---|---|
| `buildingfirestart` `:1810-1897` | `0..127` (128 f), `14 / 71.4286` | `128×14 ms = 1.792 s` | `samPlayOnce`, `OnEndFrameFree=True` (`:1859/:1864`) | grey `0.7843137` α `0.5`, `LifeTime 0.1` |
| `buildingsmokestart` `:1905-1993` | `0..127`, `14 / 71.4286` | `1.792 s` | `samPlayOnce`, `OnEndFrameFree=True` (`:1954/:1959`) | grey `0.1568627` α `0.75`, `PixelRatio=138`, `LifeTime 2` |
| `buildingfire` `:2001-2091` | `0..127`, `14 / 71.4286` | `1.792 s/loop` | **`samLoop`, `OnEndFrameFree=False`** (`:2050/:2055`), `BirthTime=1.792` (`:2062`), `Visible=False` | grey `0.7843137`, `AlphaTime 0.0/Power 1.0` (no fade) |
| `buildingsmoke` `:2098-2194` | `0..127`, `14 / 71.4286` | `1.792 s/loop` | **`samLoop`, `OnEndFrameFree=False`** (`:2147/:2152`), `BirthTime=1.792` (`:2159`), `Visible=False` | `0.1568627→0.0784313→0.0392156`, `LerpScale 0.8`, `StartRotation -3→3` |

**[D] verdict:** `Interval×FrameRate=1000` holds on all six death-adjacent keys (14×71.4286≈1000, re-verified P2 — same law as DEC_U PFX §1.1). The starters' total lifetime is exactly `1.792 s` to `Free`; the loopers' lifetime is **unbounded in data** — stop is holder-driven (§5), never a per-effect TTL.

### 1.3 Explosion keys (`_unit_DoExplosion` payload visuals)

| Key [O] | Frames / Interval / FrameRate | Total [D] | Mode / end policy [O] |
|---|---|---|---|
| `grenadeexp` `source.pfx:1003-1110` (2× `0..127` animations, `PixelRatio=50`, `AlphaTime/Power 1.0`) | `14 / 71.4286` | `128×14 ms = 1.792 s` | `samPlayOnce`, **`OnEndFrameState=FreeToPool`** (`:1096/:1102`) |
| `grenadesmoke` `source.pfx:1115-1222` (`PixelRatio=50`, `AlphaTime/Power 1.5`) | `14 / 71.4286` | `1.792 s` | `samPlayOnce`, `OnEndFrameHide=True` (`:1208/:1213-1214`) |
| `distexpflare` `source.pfx:1590-1654` (single `0..0`, `256×256`, `PixelRatio=80`) | `50 / 20` | `1×50 ms = 0.05 s` | `samPlayOnce`, `OnEndFrameHide=True` (`:1641/:1646`) |
| `distexpring` `source.pfx:1656-1720+` (single `0..0`, `PixelRatio=50`) | `100 / 10` | `1×100 ms = 0.1 s`, `StartTime=0.1` | `samPlayOnce`, `OnEndFrameHide=True` (`:1710/:1716`), `LerpScale 0.1→10.0` |

`fx.tree` composition (`ev_tree_death_fx`): `grenadeexp` effect = `grenadeexp/grenadesmoke/distexpflare/distexpring`, `parentrandom=true` (`:215-252`); `expflash` effect = `distexpflare/distexpring`, `parentrandom=true` (`:397-414`, flare `randpixelratio=1:-30`, ring same).

---

## 2. Death transition: what the script PROVES happens (and in what order) [O]

`D:scripts/units/building.inc/ontagstates.inc` (`ev_bld_ontag_full`):

1. **`switchEssential=death` case (`:82-91`), first:** sound request `if (gSoundManager.bprocess) and (not gatefinished) and (usage<>weakwall)` → `_unit_RequestPlaySound(myHnd, gc_snd_ind_deathbld)` (`:84-85`); `SetGameObjectMyPlayableObject(False)` (`:86`); non-wall → `MyGameObjectPFXClear` (`:87-88`); gate → open gates (`:89-90).
2. **Death branch (`:264-311`):** `OnDeath` execute if not already dead (`:265-266`); non-wall mesh swap `stage_0→<actor>_death1 / stage_1→<actor>_death2` (`:267-275`, walls keep mesh); `TXProgressChildrenBehaviour` destroy (`:277-279`); child0 → `<actor>a.mesh` + `debris` material + visible (`:281-287`); misc-racetag children `BehaviourClear + EffectClear + RequestToDestroy` (`:289-298`); remaining children `1..n-1` hidden (`:299-303`); key-colour recurse (`:307`); **gated** `_unit_DoExplosion(myHnd)` (`:309-311`).
3. **Wall-only tail (`:313-335`):** `EffectHighlightRemove + EffectClear(myHnd)`, destroy scheduling `DelayDestroy` at `gc_unit_deathtime_3`, hide. Non-walls do NOT clear own effects here beyond step 1's `MyGameObjectPFXClear` and step 2's misc-child clear.

`_unit_DoExplosion` gate (`:309-310`) transcribed exactly: `switchEssential=death AND iVisual<>hide AND (iOldEssential=none OR (iOldEssential=birth AND iOldVisual in {stage_2, stage_3}))` [O].

---

## 3. Damage smoke (pre-death): HP/count-driven, throttled — NO fixed TTL [O]

`D:scripts/units/building.inc/nothing.inc` (`ev_bld_nothing_full`), identical logic in client (`:17-119`) and server (`:293-424`) branches:

- Constants [O]: `cSmokeHPLimit=0.85` (`:31/:336`); `smokeHPMaxIntense = Max(gc_BuildingSlowDeathHP, maxhp div 4)` if `bslowdeath` else `maxhp div 4` (`:33-37/:338-342`); `cProgressSmokeIncrease=7` (`:15`).
- Attach rule [O] (`:38-82 / :343-387`): active while `smokecount>0 OR hp below the 0.85-blended threshold`; target index `maxind = floor((1-(hp-smokeHPMaxIntense)/0.85/(maxhp-smokeHPMaxIntense))*smokeCount)`; attach proceeds ONLY when `progresstick mod 7 = 0` AND a `random>freq` roll passes (`freq = Min((1-0.5*diff/smokeCount)*0.8, 0.8)`), then **at most ONE** `buildingsmoke` instance per qualifying tick (`break` at `:79/:384`), parented to a `misc/'point'` handle at `smokePoints[i]` with its normal orientation (`:75-78/:380-383`), `arg_obj.smokecount+1`.
- Detach rule [O] (`:85-115/:390-419`): when healed (`maxind<lastind`) and `random>0.5`, destroys **one** misc child (`BehaviourClear + EffectClear + RequestToDestroy`, `break`), `smokecount-1`.
- Post-death: **both** branches are entered only under `if (not arg_obj.bdead)` (`:19`, `:293`) [O] → after `OnDeath→_unit_DestroyObj` sets the dead flag, **zero new smoke attaches**, and the attach throttle (`progresstick`) stops advancing for the dead object (counter increments `:136/:491-492` sit inside the not-dead blocks).

**[D] verdict:** the donor burn/smoke "duration" is not a duration constant at all — it is **(HP fraction → target count) + (1 attach per 7th tick, roll-gated)** while alive. Loop count per instance is unbounded (`samLoop`, §1.2); instance count is bounded by `smokeCount` points and the ±1-per-tick walk.

---

## 4. Explosion payload [U]-EX: STATICALLY RESOLVED (effect keys + weapon rows)

`D:scripts/lib/unit.script:11420-11516` (`ev_doexpl_full`) + `D:scripts/lib/weapon.script` (`ev_weap_death_full`):

- Eligibility gate [O] (`unit.script:11427-11433`): `(bbuilding AND usage<>weakwall) OR (bship AND usage<>fisher)`; skipped if `gatefinished AND usage=hardwall`; requires collision-mask `w>0 AND h>0` (or ship); AABB height folded with `miny>0→0` (`:11436-11438`).
- Spawn loop [O] (`:11449-11495`): `SetRandomKey(floor(uniqrnd*MaxInt))` (MP sync); per set mask cell (`w×h`), up to 4 sub-spawns (`k=0..3`), each admitted with `RandomExt<0.33` and map-bounds check; position jittered to quarter-tile (`Floor(2x)/2+0.125+(k div 2)*0.25`, same for z); height `py+0.3+aabbmod+zmod`; weapon picked `rnd=floor(RandomExt*count)` from the destruct list.
- Destruct list [O] (`weapon.script:614-617`): `gDestructListBuilding = [debrisstone, debrisstone, PUEXPBUILDINGDEATH]` → P(death weapon)=1/3, P(debris)=2/3 per admitted spawn [D].
- Weapon rows [O]:
  - `PUEXPBUILDINGDEATH` (`weapon.script:367`): **fx key `cFXBuildingExp = 'grenadeexp'`** (`:275`, `const cFXBuildingExp = 'grenadeexp'; // building explosion on death`), `cProjNone`, damage 900, radius `_misc_PixelsToTiles(10)`, `gc_weapon_gravity_0`, `slightup`, `cPlayOnce`; children 30–40× `POINTOTVZRIV` (`:554`).
  - `debrisstone` (`:381`): fx `cFXNone` (no flash), `cProjDebrisStone`, damage 300, `gravity_3`, `random1`, children 1× `SMALL2` (`:566`).
- Tail [O] (`unit.script:11509`): `gEffectLibrary.GetOrCreate('expflash', hnd)` — the 2-child ring/flare (`fx.tree:397-414`), `parentrandom=true`.
- Sound inside the proc: **zero sound calls** [O absence, full-proc read]. Weapon sound table: `sndind` defaults `gc_snd_ind_none` (`weapon.script:48`); `_weapon_SetWeaponSound` binds sounds for `SHOTMUSKET/PPOINTT/PUEXPBLD/PUEXP/PUEXPONSHIP/PUEXPKORVSKOR/PUEXPHOWITZER…` (`:400-425`) but **never for `PUEXPBUILDINGDEATH`, `debrisstone`, or `POINTOTVZRIV`** [O absence] → script-side explosion sound = none.

**[D] verdict — [U]-EX closed statically:** the donor building-death explosion payload is `grenadeexp` (4 children: `grenadeexp/grenadesmoke/distexpflare/distexpring`, 1.792 s/1.792 s/0.05 s/0.1 s per §1.3) fired as the `PUEXPBUILDINGDEATH` projectile visual on a random 1/3 of admitted debris spawns, plus one `expflash` instance on the building handle. The port's `'explode'` stand-in (`world3d_entities.gd:3099`) is superseded by these two donor keys. No visual parity is claimed (native spawn positions/rates need E-U14).

---

## 5. Sound key: RECOVERED [O] (+ one registered-but-unbound key)

- **Death crash:** `_unit_RequestPlaySound(myHnd, gc_snd_ind_deathbld)` on the `switchEssential=death` case (`ontagstates.inc:84-85`), gated on `gSoundManager.bprocess AND NOT gatefinished AND usage<>weakwall` [O]. Index `gc_snd_ind_deathbld = 53` (`dmscript.global:1304`); library binds `deathbuilding1..2`, `cLoudMedium/cFreqLow` (`sound.script:128-129`) [O]. No other death-case sound exists in `building.inc/` (6-hit grep: only `:85` + build-complete chime `:146-152`) and none in `doexplode.inc` (0 hits) [O absence].
- **Burn loop:** `gc_snd_ind_burn = 56 → burn1..7`, `cLoudLarge/cFreqFull` (`sound.script:139`, `dmscript.global:1307`) is **registered but never requested by any recovered script line** (3-hit repo-wide grep: def + registration + nothing else) [O absence = static non-proof of use]. It must NOT be wired on assumption; E-U14 listens for it.

---

## 6. The 30/30 constants: destroy scheduling, NEVER a visual TTL [O + D, explicitly not endorsed]

- Values [O]: `gc_building_deathtime_0 = 30`, `gc_building_deathtime_1 = 30` (`dmscript.global:183-184`).
- Consumers [O] (`ev_stage_full`): `settagstates.inc:39` (birth→death shortcut: `DeathStage2` at `deathtime_1`, **no** mine doubling — DBUILD C3 re-confirmed); `settagstates.inc:46-50` (completed building: `DeathStage1` at `deathtime_0`, `×2` if `usage=mine`); `deathstage1.inc:7-11` (`DeathStage1`: set death+stage_1 → `DeathStage2` at `deathtime_1`, `×2` if mine).
- Effects [O]: `DeathStage1` = mesh re-swap to `_death2` (via the `:264-311` branch with `iVisual=stage_1`) + second misc-clear (smoke children, if any remain, are `EffectClear`-destroyed again) + `DoExplosion` NOT re-fired (gate fails: `iOldEssential=death`); `DeathStage2` (`deathstage2.inc:8-15`) = terrain-collision clear + `GameObjectRequestToDestroyByHandle` (non-wall) → **holder destroy ends the samLoop fire/smoke children**.
- Time-base verdict [U, both readings recorded, neither endorsed]: `GameObjectMyDelayExecuteState(h,'DeathStageN',30)` takes a game-time `Float`; `_misc_FramesToTime(v)=v*0.03125` (`misc.script:470-474`) exists but is applied at **none** of the death-scheduling call sites [O absence, P8]. So `30` is either 30 s of game time or 30 engine ticks (`30×0.03125=0.9375 s` [D] **if** the native scheduler counts `gc_time_to_frames=32` ticks — unproven). DBUILD_02's 0.9375 s/stage reading is therefore carried as [I], not re-endorsed.
- **Why it can never be a smoke TTL regardless of base:** (a) the constants schedule *tag transitions and destroy*, and no `GetOrCreate`/`EffectClear` timer references them; (b) death-branch smoke removal is **event-driven** (`MyGameObjectPFXClear` at `:88` + misc-child `EffectClear` at `:289-298` on the transition itself); (c) the looping keys have `OnEndFrameFree=False` and outlive any 0.9375 s window by construction while the holder lives. Endorsing `30` (or `0.9375 s`) as a burn/smoke TTL would contradict (b) and (c) — it is refused here, matching `IMPL-BUILDING-DEATH`'s non-endorsement.

**[D] static lifecycle (event sequence proven, wall-clock open):** `death tag → swap _death1 + clear smoke + deathbld + explosion → [+30 units] → swap _death2 + clear again → [+30 units, ×2 if mine] → destroy`. Burn/smoke attach duration at/after death = **0 new attaches**; stop condition = **transition clear + holder destroy**. The only wall-clock numbers proven are the per-loop `1.792 s` (§1.2) and the explosion TTLs (§1.3).

---

## 7. Still-[U] items with fixed-camera death captures (zero-mismatch criteria)

All captures: singleplayer skirmish, fixed camera (record `camera.position/projection`, target world pos), mill (`eurmil`) as the instrumented sid, capture ids logged per run. Nothing here is closed by a port fallback.

- **E-U14-burn (attach/stop frame log — terminates [U]-BURN):** damage the mill in ~10% HP steps at fixed camera; log per frame: `hp/maxhp`, `smokecount`, `progresstick mod 7`, each `GetOrCreate('buildingsmoke')` attach frame + smoke-point index, each detach frame. Then kill it; log `_death1` swap frame, `debris` child frame, `deathbld` audible frame, `DoExplosion` spawn frame(s), every smoke-holder `EffectClear`/destroy frame, `_death2` swap frame, destroy frame. **Terminates [U]-BURN iff** across 3 runs: (i) attach frames satisfy `progresstick mod 7 = 0` with **0 off-tick attaches**; (ii) post-death attach count is **exactly 0**; (iii) all pre-death smoke holders are cleared by `DeathStage1` at the latest (**0 surviving loopers** past the `_death2` swap); (iv) ruin persists with **0 smoke** until destroy.
- **E-U14-ex (explosion visual — confirms §4 wiring, claims no parity):** same kill capture; log admitted spawn count vs mask cells, `PUEXPBUILDINGDEATH` vs `debrisstone` picks, `expflash` frame, `grenadeexp` first-visible frame + `FreeToPool` frame (≈1.792 s later), ring `LerpScale` growth. **Terminates iff** effect keys are exactly `grenadeexp`+`expflash` with **0 foreign keys** across 3 runs; spawn counts stay [U]-statistical (RandomExt-gated, no exact-count criterion — recorded, not forced).
- **E-U14-snd (sound — terminates sound-[U]):** same kill capture with audio; log `deathbuilding*` onset frame vs death tag frame; listen for any `burn*` loop during damage-smoke phase and any impact sound under the debris spawns. **Terminates iff** `deathbuilding` onset matches the tag transition within **±1 frame** across 3 runs AND `burn*` presence/absence is logged as observed (if absent, `gc_snd_ind_burn` stays registered-but-unbound — never wired).
- **E-U14-ttl (delay-unit probe — time base stays [U] either way):** log wall seconds from death tag → `_death2` swap → destroy (non-mine mill). **Terminates the scheduling question iff** offsets equal `30.0 s / 0.9375 s / other` within **±1 frame** across 3 runs; the outcome is recorded as the scheduler's unit and STILL never copied onto any effect TTL (per §6, effect stop is event-driven).

Until all applicable captures terminate, the port keeps: labelled stand-in explosion key, no invented burn TTL, `RALLY_TTL`-style placeholders untouched, and `PORT APPROXIMATION — NOT DONOR PARITY` labels.

---

## 8. Exact port change list (file/line; no code written here)

Each row: port site **[O]**, donor fact **[O]/[D]**, required replacement. **No row is implemented here.**

| # | Port file:line (current [O]) | Donor fact (this job [O]/[D]) | Required donor-faithful replacement (no invented TTL) |
|---|---|---|---|
| B1 | `world3d_entities.gd:326` `BLD_DEATH_SMOKE_KEY="buildingsmoke"` + `:3096-3097` unconditional `add_impact_fx` on every death edge | Donor attaches **zero** smoke at death; damage smoke is pre-death HP/count-driven and gated `not bdead` (`nothing.inc:19,293`); death clears via `MyGameObjectPFXClear` (`ontagstates.inc:88`) + misc-child `EffectClear` (`:289-298`) | Gate the death-edge smoke call: attach NOTHING on the death transition; instead mirror the clear (free holder-side smoke nodes / clear `donor_death_smoke_effect` meta). Keep `add_impact_fx("buildingsmoke")` ONLY for a future HP-driven damage-smoke path (P10 row, needs E-U14-burn first) |
| B2 | `world3d_entities.gd:327` `BLD_DEATH_EXPLOSION_STATUS` ("no donor effect key") + `:3098-3099` `add_fx(pos,"explode",…)` stand-in | Payload recovered: `grenadeexp` (4 children, `fx.tree:215-252`) + `expflash` (`fx.tree:397-414`); weapon rows `PUEXPBUILDINGDEATH` (fx `grenadeexp`, `weapon.script:275,367`) + `debrisstone` (fx none, `:381`); tail `GetOrCreate('expflash')` (`unit.script:11509`) | Replace `"explode"` with the two donor keys on the `:309-311` gate (keep the existing `do_explosion` gate logic `:3206-3208` — it mirrors the donor condition correctly): fire `grenadeexp` composition + `expflash`; drop `"explode"` after E-U14-ex. Port `DONOR_FX` map already has `"building_exp":"grenadeexp"` (`world3d_fx.gd:299`) — use it |
| B3 | `world3d_entities.gd:328` `BLD_DEATH_BURN_STATUS` + `:100`/`BUILDING_DEATH_STATUS :320` ("30 NOT endorsed") | §3 + §6: burn = HP→count + 1-per-7th-tick while alive; stop = transition clear + holder destroy; 30/30 = tag/destroy scheduling (mine ×2), never a visual TTL | Keep the non-endorsement verbatim; extend the status text with the event lifecycle (`death→_death1+clear → +30u →_death2+clear → +30u →destroy`) and the `BirthTime=1.792` loop period; add per-instance loop policy `samLoop/Free=False` |
| B4 | `world3d_entities.gd:3151-3166` single-edge `_death1/_death2` pick + `:3227-3252` misc-clear/hide | Two-stage donor ruin: `DeathStage1` re-runs `:264-311` with `stage_1` (second misc-clear, §6); destroy at `DeathStage2` (`deathstage2.inc:8-15`) | Add the second-stage swap (`_death1`→`_death2` on the `DeathStage1` delay) + destroy on the `DeathStage2` delay, reading delays from `data.gd:108 DEC_U_BUILDING_DEATHTIME_FRAMES` (scheduling only — the constant must never flow into any `life`/TTL argument; add a comment citing this report §6). Keep `:3242-3251` clear/hide (matches `:289-303`) |
| B5 | `world3d_entities.gd:3196` meta `donor_death_smoke_effect="buildingsmoke"`; no death-sound hook anywhere in the death path | Sound key recovered: `gc_snd_ind_deathbld=53 → deathbuilding1/2` on the death case (`ontagstates.inc:84-85`, gated non-weakwall); `burn1..7` registered but unbound (§5) | On the death edge (non-weakwall/wall-flag equivalent): request sound key `deathbld` once through the port audio path when it lands (label UNVERIFIED until E-U14-snd); set smoke meta to `"cleared_at_death"` instead of `"buildingsmoke"`; do NOT wire `burn` |
| F1 | `world3d_fx.gd:126-141` `LIFE` + `:142` `DEFAULT_LIFE` + `:755-757` span lookup; `:129 "explode":0.8` | Donor TTLs [D §1.2-1.3]: `grenadeexp` 1.792 s (FreeToPool), `grenadesmoke` 1.792 s (Hide), `distexpflare` 0.05 s (Hide), `distexpring` 0.1 s + StartTime 0.1 (Hide), `buildingfirestart/buildingsmokestart` 1.792 s (Free); `buildingfire/buildingsmoke` loop, NO ttl | After E-U14-ex: add donor-grounded entries (`grenadeexp 1.792`, `grenadesmoke 1.792`, `expflash≈0.2` bounded by ring, starters 1.792) sourced from `EndFrame/Interval` per key; loopers keep NO life entry (holder lifetime). Until then keep `LIFE` labelled stand-ins |
| F2 | `world3d_fx.gd:833-839` buildingsmoke 4-child shared-`FillRand` block | Matches `fx.tree:417-442 parentrandom=true` [O] — already donor-faithful | Keep; add the HP→`maxind` target + `mod-7` throttle + `random>freq` roll (`nothing.inc:43-82`) as the documented future attach rule (needs E-U14-burn tick-rate proof first — native `progresstick` rate unrecovered) |
| F3 | `world3d_fx.gd:299` `"building_exp":"grenadeexp"` map; `:813-823` kind routing (`grenadeexp→explode`) | `cFXBuildingExp='grenadeexp'` (`weapon.script:275`) [O] | Route death-explosion visuals through `building_exp→grenadeexp` (4-child composition per `DONOR_MUSKET_CHILDREN`-style table + `fx.tree:215-252` codes) instead of the generic `explode` quad; add `expflash` 2-child composition (`fx.tree:397-414`) |

Required donor assets (not copied here; via approved converters): `D:pfx/source.pfx` sheets (`grenadeexp/grenadesmoke/distexpflare/distexpring/building{fire,smoke}[start]` → `firesmoke.dds` etc. per `material.mat`), `D:pfx/fx.tree` 24-effect table, `D:pfx/manager.lib` (`aspriteshader30/31`), `D:animations/aaf/pfx/*.aaf` where applicable, `deathbuilding1/2` + `burn1..7` sound sources only after E-U14-snd.

---

## 9. Claim register

| # | Claim | Label |
|---|---|---|
| 1 | `buildingsmoke` = 4 children (`buildingfirestart/buildingsmokestart/buildingfire/buildingsmoke`), each `randmirroru=2`, `parentrandom=true` | [O] `fx.tree:417-442` |
| 2 | Starters `0..127×14 ms=1.792 s` to `Free`; loopers `samLoop+Free=False`, `BirthTime=1.792`, unbounded in data | [O] `source.pfx:1808-2194`; [D] products |
| 3 | Damage smoke: HP-threshold + target-count + max 1 attach per 7th tick (roll-gated); detach 1 per tick when healed; both branches require `not bdead` → 0 attaches after death | [O] `nothing.inc:15,19,31-115,293,336-419` |
| 4 | Death clears smoke on the transition (`MyGameObjectPFXClear` non-wall + misc-child `BehaviourClear/EffectClear/destroy`), hides `1..n-1`, swaps mesh; `DoExplosion` on the stated gate | [O] `ontagstates.inc:82-91,264-311` |
| 5 | Explosion payload = `grenadeexp` (1.792 s FreeToPool) + `expflash`, via `PUEXPBUILDINGDEATH`/`debrisstone`/`debrisstone` destruct list + `expflash` tail; zero script sound | [O] `unit.script:11420-11516`, `weapon.script:275,367,381,554,614-617` |
| 6 | Death sound = `gc_snd_ind_deathbld=53 → deathbuilding1/2` on death case (non-weakwall); `gc_snd_ind_burn=56 → burn1..7` registered, no recovered call site | [O] `ontagstates.inc:84-85`, `dmscript.global:1304,1307`, `sound.script:128-129,139` + absence grep |
| 7 | `gc_building_deathtime_0/1=30` schedule `DeathStage1/DeathStage2` + destroy (mine ×2; birth shortcut without ×2); time base unproven; NEVER a visual/smoke TTL | [O] `settagstates.inc:32-53`, `deathstage1.inc:1-15`, `deathstage2.inc:1-24`; [U] time base |
| 8 | Port differs at §8 B1–B5/F1–F3; each has a donor-faithful replacement + capture; no row implemented here | [O] port lines + donor facts |
| 9 | Every [U] has a fixed-camera capture with a zero-mismatch criterion (§7); none closed by a fallback; no duration invented | [D] §7 |
| 10 | Any port building-death visual/audio equals donor motion/timing/sound | **Denied** — no same-camera donor/port A/B exists; parity UNVERIFIED |

## 10. Scope statement

Exactly one repository file was written by this worker: this report. All donor reads were read-only against pin `t_87f0f3c130b0` (binary never executed) and the read-only `C:\Games\Cossacks 3\data` tree. No source, shader, config, asset, fixture, test, runner, Godot, git or user-mod state was changed. No donor parity, similarity score, threshold or gate PASS is claimed. Network is out of scope.

*End of DEC-U-SMOKE-BURN-TTL.*
