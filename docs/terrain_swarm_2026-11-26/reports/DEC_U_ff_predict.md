---
id: DEC-U-FF-PREDICT
worker: DEC-U-FF-PREDICT (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied. Donor text scripts/data read as text only. No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. No multiplayer/netcode specified, audited, or changed."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed. No port capture compared."
context: "DEC_U_damage_height.md left F4 (PredictShot gating: stand-propagation -> no projectile + 1 s cooldown) and F5 (friendly-fire vetoes, DONOR_FF_PRECHECK_* inert data) [U] red; DEC_U_weapon_tail.md transcribed propagation kinds and the 77-row registry."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
---

# DEC-U-FF-PREDICT — projectile launch/predict gate, friendly-fire vetoes, RNG draw order (2026-11-26)

## 0. Pass ledger (every pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `Get-FileHash C:\Games\Cossacks 3\cossacks.exe` (read-only hash, not execution): SHA256 `87F0F3C1…4E16C`, 5,768,048 B — matches pin. Binary never executed/copied/debugged. Native function addresses: NOT re-derived by this worker; packed-exe prior (`ev_31960c6f`/`ev_60f443` family per DEC_U_damage_height §0) reused, not re-run. |
| P2 | `weapon.script:39-69,121-139,470-492,625-646,740-803` re-read (EV-PROP) | Propagation registry shape, `bcheckfriendonline` default + 10-weapon opt-out list, dispersion procedure, `_CheckWeapon` / `_CheckWeaponTargetable` / `_GetFlyChild` / `_PredictShot` transcribed §1–§2 `[O]`. |
| P3 | `weapon.script:855-1192` re-read (EV-LAUNCH) | `_weapon_InitProjectile` gravity remap, propagation dispatch, `brotate`/`bcollisiondetection` law, `time` gate (Infinite / PlayOnce / timed airburst), `_weapon_CreateProjectileByWeaponID` resync + `uniqrnd` + `SetRandomKey` transcribed §3–§4 `[O]`. |
| P4 | `onaclanimationreachedattack.inc:1-155` full read (EV-GATE) | `weaponid=0` melee path, `immediate` direct-damage path + GENERAL-`random` fx roll, `PredictShot` allow/deny branches for attackobj AND attackpoint with verbatim cooldown literal transcribed §2 `[O]`. |
| P5 | `unit.script:5288-5441` full re-read (EV-FF) | `_unit_CheckFriendlyFireExplosion` + `_unit_CheckFriendlyFireCannister` transcribed verbatim incl. weights, radii, dst steps, 4:1 rule §5 `[O]`. |
| P6 | `unit.script:8260-8303` re-read (EV-VETO) | `FriendOnLine` ray + cannister/cannonball veto wiring, `bLockTarget` bypass, `attackdelay`/`attackmaxdelay` penalty, peacetime/order cleanup transcribed §5 `[O]`. |
| P7 | `miscext2.script:560-604,639-728` re-read (EV-SIM/RNG) | `_misc_DoRoundDamage` victim cap + `RandomExt` child/count/pick rolls; `_misc_ProjSimulatePoint` Box-Muller LCG + `RandomExt` seed/local draws; `doexplode.inc:12` resync transcribed §6 `[O]`. |
| P8 | `unit.script:11520-11561` + `classes.script:4351-4367` re-read (EV-PROJ) | `_unit_DoProjectile` scatter→WriteProj order, `frnd := RandomExt`, `TProj.uniqrnd` field transcribed §4/§6 `[O]`. |
| P9 | `dmscript.global:172-175,278-288,688-704,815` re-pin (EV-CONST) | Pixel/tile/frame converters, weapon-kind ids, propagation/gravity/time enums, `gc_MaxInt` re-cited `[O]`; `gc_frames_to_time=0.03125` `:174` grounds the cooldown arithmetic §2. |
| P10 | Port read-only inspection (EV-PORT) | `app/scripts/game.gd:4861-4973` (dispersion/fire/projectile), `:4638-4642` (height bonus), `:4919-4921` (ridge veto), `:5020-5037`/`5046-5074` (splash/victim); `app/scripts/data.gd:22,93-95` — and the **negative result**: NO `DONOR_FF_PRECHECK_*`, NO `DONOR_WEAPON_PROTOS`, NO `DONOR_MOUNT_*`, NO `DONOR_SHIELD_*`, NO `PredictShot`, NO `FriendOnLine`/`CheckFriendlyFire` anywhere in `app/scripts/*.gd` (P10 grep). Task-brief phrase "inert data" is therefore corrected: the veto is not inert data, it is ABSENT — nothing to enable, only code to add (§8). |
| P11 | Cooldown-scale arithmetic (EV-TIME) | Donor `attackdelay` is `Float` (`dmscript.global:1737`); sibling penalties use `100*gc_frames_to_time` (=3.125 s) and `64*gc_frames_to_time` (=2.0 s) (`unit.script:8188,8209`), so the bare literal `1` in the PredictShot/veto denials is 1.0 s on the same scale `[D]`. Kept verbatim as literal `1` everywhere below; "1 s" appears only as the derived gloss. |

DSL note `[D]` (inherited): donor `not X` on a numeric lvalue is the current-value read. Donor `{...}` is comment syntax: live value is the uncommented head.

---

## 1. Propagation kinds — exact registry and per-kind launch law [O]

`dmscript.global:697-704`:

```
gc_weapon_propagation_stand = 0; slightup = 1; random = 2; fly = 3;
immediate = 4; angle = 5; random1 = 6; randomsimulate = 7;
```

Registration shape (`weapon.script:39-69`): per `_weapon_AddWeapon`, `physvalue` means `speed` for `random/random1/fly/randomsimulate`, `angle` (degrees) for `angle`, `-gravity` for `slightup`, unused for `stand/immediate`; `brotate := (propagation=random1) and projbasename<>'' and <>'point'` (`:54`); `bcollisiondetection := (angle or fly)` (`:55`); default `bcheckfriendonline := True` (`:56`), opted OUT for exactly 10 sids (`:482-492`): `STRELA, OSTRELA, SHOTMUSKET, SHOTBLOCKHOUSE, NUCLGRE, PSMPOINTTPUS, DIMMORT1, DIMMORT2NEW, PSMPOINTT, DIMMORT2KOR` `[O]`.

Launch dispatch (`weapon.script:945-985`):

| propagation | throw path | collision | `time` handling |
|---|---|---|---|
| `angle` (5) | `_weapon_ThrowByAngle(angle…)` → engine `CalcSpeedByDirAndTrgPos` (`:807-822,947`) | ON (prio 10000) if `bthrow` | `Infinite(-1)` → `OnStopEvent`; `time>0` → ALSO `DelayExecuteState(OnStopEvent,time)` timed airburst (`:984-985`) |
| `fly` (3) | `_weapon_ThrowByHSpeed(speed…)` → engine `CalcDirByHSpeedAndTrgPos` (`:826-832,951-955`) | ON (prio 10000) if `bthrow` | same as above |
| `random` (2), `random1` (6) | `_weapon_ThrowRandom(speed)`: 3× `RandomExt` sphere-ish kick (`:838-852,957-960`) | OFF (`bthrow=False` → `:976-979`) | same as above |
| `randomsimulate` (7) | same `ThrowRandom` now; REAL damage later via `_misc_ProjSimulatePoint` children (`doexplode.inc:192-193`) | OFF | same as above |
| `slightup` (1) | no throw behaviour at all — falls to `cPlayOnce` instant branch (`:988-1033`) for all registered slightup rows (all 40+ have `time=PlayOnce`) | OFF, scale 0.00001, instant `DoExplode`+`FreeToPool` | FX from mount (`buseownerfxshot`) or prototype; GENERAL-`random` (explicitly non-sync, `:1011`) |
| `stand` (0) | no throw; `py := RandomExt*0.125`, pitch `-(30+RandomExt*30)` (`weapon.script:1135-1136,1156-1157`) | n/a (pooled `cProjArrowGround` visual) | `STRELDEZ` row: `time=FramesToTime(950)` = 29.59375 s; `STRELDEZPRO` row: PlayOnce |
| `immediate` (4) | NEVER reaches projectile code — direct `_misc_DoDamage` in the attack handler (`onaclanimationreachedattack.inc:58-60`) | n/a | n/a |

`time` semantics (`weapon.script:41-43,900`): `<0` Infinite, `=0` PlayOnce, `>0` timed. Timed rows: 14 PUSSTRELA `round()` rows + `NUCLM FramesToTime(2)` = 0.0625 s `[O]`.

**No-projectile conditions (exact, no invention):** (a) `weaponid=0` → direct damage, no projectile (`inc:36-54`); (b) `immediate` → direct damage + pooled FX ghost, no projectile (`inc:58-88`); (c) `PredictShot=False` → **no `_unit_DoProjectile` call at all** (`inc:98-109,131-137`) — this is the stand-propagation gate (§2); (d) `bProcess=False` (client/replay) → whole block skipped (`inc:8-9`).

---

## 2. PredictShot — exact stub, both call sites, cooldown literal [O]

Donor (`weapon.script:795-803`):

```
function _weapon_PredictShot(myHnd, parentweaponid : Integer; sx, sy, sz, dx, dy, dz : Float) : Boolean;
begin
   Result := False;
   var weaponid : Integer = _weapon_GetFlyChild(parentweaponid);
   if (weaponid<>0) then
   begin
      Result := True;
   end;
end;
```

`_weapon_GetFlyChild` (`weapon.script:756-791`): returns `parentweaponid` itself iff `_weapon_CheckWeapon(parent)` (i.e. propagation ∈ {`immediate`,`fly`,`angle`}, `:751`); else scans `childs.list` then `syncweaponslist` for the FIRST entry passing `_weapon_CheckWeapon`; else 0. **No geometry, no height, no range, no RNG, no team check — pure registry walk** `[O]`. SX/SY/SZ/DX/DY/DZ params are accepted and IGNORED (stub signature only) `[D]`.

Call sites (`onaclanimationreachedattack.inc`, line-for-line):

- Attack-object (`:91-110`): non-`immediate` weapon → `sx/sy/sz` (shooter), `tx/ty/tz` (target end-point) → `bAllowShot := _weapon_PredictShot(…)` (`:97`); if True → `buseownerdamage`-vs-building trg select (`:101-102`) → `_unit_DoProjectile(…)` (`:103`); if False → **`arg_obj.attackdelay := MaxFloat(arg_obj.attackdelay, 1); arg_obj.attackmaxdelay := MaxFloat(arg_obj.attackmaxdelay, 1);`** (`:107-108`) and NO projectile `[O]`.
- Attack-point (`:130-137`): identical gate, ground `ty` via `RayCastWater/RayCastHeight` (`:128-129`); deny → same `MaxFloat(…,1)` × 2 (`:135-136`), no projectile `[O]`.
- The `trgHnd=0` + non-attackpoint fallthrough (`:143-147`) applies the same `MaxFloat(…,1)` × 2.

Cooldown source/scale: literal **`1`** (`Float`, `dmscript.global:1737`), on the seconds scale where siblings write `100*gc_frames_to_time` (3.125 s) and `64*gc_frames_to_time` (2.0 s) — hence glossed "1 s" (`P11 [D]`). **Never invented: the literal is `1`; the "seconds" is the derived unit.** `attackdelay` gates the next attack (`inc:9`: `… and (arg_obj.attackdelay=0)`); `attackmaxdelay` is the UI/max tracker set in lockstep `[O]`.

Which mounts hit the gate: any mount whose weapon NOR any child/sync weapon is `fly`/`angle`/`immediate`. In-registry examples: `stand`-only chains (`STRELDEZPRO` → children `STRELDEZ, POINT`: `stand` + `random` — `random` FAILS `_weapon_CheckWeapon` (`:751`), so `GetFlyChild(STRELDEZPRO)=0` → **every shot denied, 1-literal penalty each attempt** `[D]`); pure-`slightup` mounts (all `SHOT*` muzzle flashes, `PPOINTT*`, `PSMPOINTT*`, `DIMMORT*`) as PARENTS return self=0 and scan children/syncs — e.g. `PPOINTT` syncs `SHOTCANNON(slightup), NUCL2P(angle)` → fly-child `NUCL2P` found → allowed `[D]`; a mount with weaponid `DIMMORT1` and no valid child/sync → denied. Exact per-mount verdicts require walking that mount's child/sync lists — the walk rule above IS the complete law, no per-mount table is invented here.

---

## 3. `_weapon_InitProjectile` — gravity/speed tables [O] (unchanged from DEC_U_damage_height §5, re-pinned)

- `speed = _misc_PixelsToTiles(floor(gWeapons[id].speed*1000))*0.001*gc_time_to_frames` (`:872`): `fly` physvalue 20 → 12.0 tiles/s = 24 m/s; 25 → 15 tiles/s; 38 → 22.8 tiles/s; `random` 3 → 1.8 tiles/s `[D, arithmetic]`.
- `gravity` remap (`:877-890`): arg 0→2, 1→2.5, 2→3.75, 3→7, 4→9.25, 5→11.5; override `fly`+arg-2 → **11.5**; `if gravity=0 then gravity := 2` (`:894`). Engine-internal units (fed to `TXThrowBehaviour.Gravity`); no px/s² gloss exists — do NOT invent `[U]` (carried U1).
- EnergyLoss=1 iff gravity-arg≠0 (`:911-913`); `CollisionPriority=10000` + `_weapon_OnCollide` only when `bthrow and bcollisiondetection` (`:967-973`), i.e. aimed `angle`/`fly` throws only.

---

## 4. `_unit_DoProjectile` + `TProj` — scatter order, WriteProj, owner/team/height fields [O]

`unit.script:11520-11561`:

```
disp := objbase[cid][id].weapon[weapind].dispertion;   // per-MOUNT tiles value
SetRandomKey(floor(random*gc_MaxInt));                  // GENERAL random, multiplayer sync
if (disp>0) then _weapon_CalcShotDispertion(…tx,ty,tz → tx,ty,tz);  // 2× RandomExt, §2 law
weaponid := objprop.weapon[weapind].weaponid;
…ftrgx:=tx; ftrgy:=ty; ftrgz:=tz; … frnd := RandomExt;  // sim stream, AFTER scatter
PlayerExecuteStateByHandle(plHnd, 'WriteProj');
```

`TProj` (`classes.script:4351-4367`): `weaponid, owner (unique id), trg (unique id), px/py/pz (launch), dx/dy/dz (aim), ownerpl (player index), ownercid/ownerid/ownerweaponind, uniqrnd` — the owner/team/height gate inputs live HERE (unique-id owner + `ownerpl`), not in a donor `DONOR_FF_*` table: **no `DONOR_FF_PRECHECK_*` const exists in donor text** (P10 negative grep over `dmscript.global`, `weapon.script`, `unit.script`, `miscext2.script` — zero hits) `[O]`. The brief's "inert data" phrasing is corrected per P10: the port holds NO such consts either (absent, not inert).

`_weapon_CreateProjectileByWeaponID` (`weapon.script:1039-1192`): replays under `SetRandomKey(floor(newuniqrnd*gc_MaxInt))` where `newuniqrnd := random` (GENERAL) if `uniqrnd=0` else kept (`:1046-1051`); custom-obj shot-point pick `floor(RandomExt*count)` (`:1118`); `random1` orientation 6× `RandomExt` (`:1151`); `stand` 1× `RandomExt` (`:1156-1157`); stores `TProj.uniqrnd := newuniqrnd` (`:1185`).

---

## 5. Friendly-fire vetoes — exact three-layer rule, owner/team/height gates [O]

Layer 0 — per-weapon opt-out (`weapon.script:56 + 482-492`): `bcheckfriendonline` defaults True; the 10 sids listed in §1 skip the ray test entirely (notably ALL muskets, arrows, grenades, multicannon/cannister cannister-shot `PSMPOINTT*`, mortars) `[O]`.

Layer 1 — `FriendOnLine` ray (`unit.script:8263-8268`):

```
if (weaponid=0) or (not gWeapons[weaponid].bcheckfriendonline) then FriendOnLine := 0
else FriendOnLine := _misc_IsBuildingInRay(goHnd, px, py+0.5, pz, tx, ty+0.5, tz);
```

`+0.5` tiles (1.0 m) both ends; ANY building (friend OR foe — the test is geometric, ownership is not consulted) on the ray vetoes `[O]`. Port `game.gd:4874-4887` `_wall_between` + `:4912-4916` is a same-shape approximation but checks only `wal`/closed-`gat` and lacks the +0.5 lift — delta in §8.

Layer 2 — kind vetoes (`unit.script:8269-8270`), ONLY when `not bLockTarget` (locked-target shots bypass BOTH kind checks — owner/team gate `[O]`):

```
(kind=cannister) and (not bLockTarget) and (not _unit_CheckFriendlyFireCannister(goHnd, not bTurn, tx, tz))
(kind=cannonball) and (not bLockTarget) and (not _unit_CheckFriendlyFireExplosion(goHnd, tx, tz))
```

`_unit_CheckFriendlyFireExplosion` (`unit.script:5290-5332`): `disp` = mount-0 `dispertion` (NOTE: weapon index **0**, not the firing mount `[O]`); `SetRandomKey(floor(random*gc_MaxInt))` GENERAL; `maxdisp := dist*disp*gc_pixels_to_tile/2000` (same box law); `dmgRad := 3.75` if `usage=mortar` else `1.25` (tiles); scan `maxdisp+dmgRad` via `_misc_MakeListObjectsInRadius(tx,tz,…,body-material)`; classify by `enemyplmask/myplmask` (`benemy := (enemyplmask and gPlayer[pl].myplmask)<>0`); **ALLOW iff `enemycount >= friendcount*4`** (`:5329`) — 4:1 super-majority; empties (0≥0) ALLOW `[D]`. Height: NOT consulted (2-D radius scan; no py/ty) `[O]`.

`_unit_CheckFriendlyFireCannister` (`unit.script:5336-5441`): 6 forward fans (`bCheckInFront` → facing dir else aim dir): NON-multicannon rad `0.47/0.94/1.41/2.35/2.82/3.29` tiles at dst `0.75/1.5/3/4.875/6.75/8.625` tiles, weights `4/4/4/4/4/2` (`i<5→4` else 2); multicannon SAME radii, dst `0.75/1.5/3/4.875/6.75/8.625`, weights `5/4/3/1/1/1` (`i>2→1` else `5-i`). Weighted `enemycount >= friendcount*4` (`:5438`) `[O]`. Height: not consulted `[O]`.

Veto penalty (`unit.script:8271-8282`): `res := targetnotvalid`, `movetag := idle`, `actiontag := none`, `executetag := none`, drop `attackobj` order, `newSTO := 0`, **`attackdelay := MaxFloat(attackdelay, 1); attackmaxdelay := MaxFloat(attackmaxdelay, 1)`** — the SAME literal-`1` penalty as PredictShot (`:8280-8281`) `[O]`, plus the `cantshootobstacle` log line when locally owned (`:8283-8301`).

Owner/team gates summary: (i) `doexplode.inc:83-87` — direct+round double-dip EXCEPT `ownerHnd=trgHnd` self-hit skipped (`owner<>dmgHnd` `:583` also excludes the owner from round damage); owner is otherwise splashable; (ii) building targets immune to non-`CheckWeaponTargetable` propagations (`doexplode.inc:73`, i.e. `slightup/stand/random1` children do no locked-target damage to buildings) `[O]`.

---

## 6. RNG draw order — complete shot-path ledger [O shape; cross-PC stream semantics stay U]

Order along one aimed shot (verbatim stream attribution; `random` = GENERAL, `RandomExt` = sim):

1. Spawn (once): `obj.uniqrnd := RandomExt` (`unit.script:2726`) `[O]`.
2. Friendly-fire prechecks: `SetRandomKey(floor(random*gc_MaxInt))` GENERAL (`unit.script:5301`; cannister sibling same pattern by construction — no separate resync line, draws only inside scan weights: NONE, scan adds no draws) `[O]`.
3. `_unit_DoProjectile`: `SetRandomKey(floor(random*gc_MaxInt))` GENERAL → scatter 2× `RandomExt` (iff `disp>0`) → `frnd := RandomExt` stored for WriteProj (`:11528-11555`) `[O]`. **Scatter precedes the stored frnd.**
4. `_weapon_CreateProjectileByWeaponID`: `newuniqrnd := random` GENERAL iff `uniqrnd=0` → `SetRandomKey(floor(newuniqrnd*gc_MaxInt))` → shot-point `floor(RandomExt*count)` → `random1` 6× `RandomExt` → `stand` 1-2× `RandomExt` (`:1046-1057,1118,1136,1151,1157`) → `TProj.uniqrnd := newuniqrnd` (`:1185`) `[O]`.
5. `_weapon_InitProjectile`: `brotate` rotspeed 1× `RandomExt` (`:936-938`); `ThrowRandom` 3× `RandomExt` (`:838-840`); PlayOnce `volumeclippedfreq<random` GENERAL non-sync (`:1011`) `[O]`.
6. `DoExplode`: `SetRandomKey(floor(arg_proj.uniqrnd*gc_MaxInt))` (`doexplode.inc:12`) → custom/child `count = mincount+floor(RandomExt*(1+maxcount-mincount))`, pick `floor(RandomExt*list)` (`:139-143,176-180`) `[O]`.
7. `randomsimulate` children: `_misc_ProjSimulatePoint` — seed `floor(RandomExt*100000)` (`:644`), Gaussian helpers over LOCAL LCG (`a=314159269,c=453806245,m=2147483647`, `:648-650`) with `RandomGauss localseed=floor(RandomExt*1000000)` (`:670`) / `RandomGaussExt` (`:685`), then `dst` rotate `RandomExt*360` (`:718`) and `damagetime` tail `RandomExt*…` (`:714`) `[O]`.

Port `rng` is a single stream (`game.gd:4941,4956,4966` `rng.randf_range` for scatter + `Data.RANDOM_SEED` single-seed): scatter-vs-fx draw split is ABSENT — §8 item 5.

---

## 7. Still-[U] register — fixed-camera shot-series captures, zero-mismatch termination

General harness (all series): fixed camera (frozen `camera3d`, no shake — sim assertions read `projectiles[].target` / `entities[].hp` / `cooldown`, never pixels). Flat test map (all `height==h0`), two actors (shooter S, target T), seeded `rng` re-seeded per series. **Termination criterion (all): run the FULL series; ANY single mismatch vs the stated donor expectation keeps the item `[U]` and forbids wiring; zero mismatches across the full series closes it.** Never fit a curve; never invent a literal.

| # | Item | Static state after this ticket | Exact capture (owner-authorised) |
|---|---|---|---|
| F4 | PredictShot gate | Stub law + both call sites + literal `1` `[O]` §§1–2; port always fires (no gate) | Series F4-PRED: `stand`-chain mount (STRELDEZ-profile: no fly/angle/immediate child or sync) ordered to fire, 50 attackobj attempts + 50 attackpoint attempts (100). Expectation per attempt: NO `projectiles` entry, `e.cooldown == 1.0` (donor literal) set on the denied attempt. Port currently FIRES → known mismatch; item stays `[U]` until §8-item-2 wired + series re-run green with zero mismatches. |
| F5a | Explosion FF veto (cannonball) | 4:1 rule, `dmgRad` 3.75/1.25, mount-0 disp, `bLockTarget` bypass `[O]` §5; port has no gate (fires; splash even hits owner-adjacent) | Series F5-EXP: 3 geometries (lane-blocked ally / 1-ally-5-foe / 3-ally-1-foe in `maxdisp+dmgRad` disc) × locked/unlocked (6 cells), 30 shots each (180). Expectation: donor allow/veto per cell (veto ⇒ no projectile + `cooldown==1.0` + order drop). Zero mismatches → wireable; any → stays `[U]`. |
| F5b | Cannister FF veto | 6-fan radii/dst/weights, multicannon split, 4:1 weighted rule `[O]` §5; port has no gate | Series F5-CAN: same 6 cells with cannister mount (multicannon + line-cannon variants = 12 cells), 30 shots each (360). Same expectation/criterion as F5a. |
| F5c | FriendOnLine ray veto + opt-outs | Ray law + 10-sid opt-out list `[O]` §5; port `_wall_between` ungrounded | Series F5-RAY: building on ray (friend-owned AND foe-owned) × opt-out sid (SHOTMUSKET/STRELA) vs opted-in sid (cannon PPOINTT), 30 shots each (120). Expectation: veto (no projectile + `cooldown==1.0`) whenever ANY building intersects the +0.5-lifted ray for opted-in sids; never for opt-out sids. Zero mismatches → wireable. |
| F6 | Owner/team/height gates at impact | `owner<>dmgHnd` exclusion, building `CheckWeaponTargetable` immunity, `buseownerdamage` mount-vs-prototype damage source `[O]` §5 | Series F6-OWN: (i) owner standing inside own round-damage radius, 30 shots — expectation: owner takes NO round damage but CAN take locked-target damage when targeted (suicide-by-lock allowed); (ii) `stand`/`slightup` child vs building, 30 shots — expectation: no locked-target damage; (iii) arrow vs building, 30 shots — expectation: MOUNT damage value used. 90 shots, zero mismatches. |
| F7 | RNG draw-order parity | Draw ORDER `[O]` §6; cross-PC `random` vs `RandomExt` stream semantics `[U]` | Series F7-RNG: fixed-seed headless run, count sim-stream draws per shot: musket (`immediate`, no scatter) = 0 scatter + 0 frnd-projectile… (no projectile path at all — expectation: ZERO sim draws); archer (`fly`, disp>0) = 2 scatter + 1 frnd; cannon PPOINTT chain = 2 + 1 + child/count/pick draws. Expectation: exact counts. Any extra draw → `[U]`. |
| U1 | Engine ballistic (`TXThrowBehaviour` gravity/speed units, landing) | Script inputs `[O]` §3; integration is the native boundary | Carried from DEC_U_damage_height U1: flat-map cannon vs ground aim at 10/20/30/40 m, 50 shots each (200); landing inside §-box law; any NaN/outside-box → `[U]`. |

---

## 8. Concrete port change list (owner/COORD applies; this worker wrote no code)

All items add DONOR-VERBATIM values or explicitly labelled placeholders. None invents a number. None touches save-version keys, demo/mill/builder hooks, or I11 seam paths.

1. **`game.gd:4861-4870` `_dispersion_px` — keep, but rewire call sites to the §4 law.** Consts `ARROW 175 / CANNON 225 / TOWER 100 px` (`data.gd:93-95`) are donor-grounded (`unit.script:1001-1047` archer family, `:1708` cannon, `:2232` tower). Per shot: `maxdisp_m = dist_m * dispertion_px_mount / 2000` with the firing MOUNT's px (fallback chain only where donor-absent: keep current kind switch, tag PORT APPROXIMATION); delete `*0.5` (`game.gd:4941,4956`) and `*0.4` (`:4966`); draws from the SIM stream in order scatter, scatter, then stored frnd. Cite `weapon.script:627-646`, `unit.script:11527-11530`.
2. **Add `PredictShot` gate in `_fire` (new; no donor const exists to enable — this is new code, not data).** Before projectile creation for `fly/angle/random/randomsimulate` mounts: walk mount weapon → children → syncs (port must first add child/sync tables per DEC_U_weapon_tail §4 — until then, conservative approximation: deny IFF kind-propagation ∈ {stand, slightup} with no known fly/angle child, tag `[U]`-F4): on deny, `e.cooldown = 1.0` (donor literal `1`, `onaclanimationreachedattack.inc:107-108,135-136`) and return WITHOUT appending to `projectiles` and WITHOUT `stats.shots += 1`. Covers BOTH attackobj and attackpoint paths (port `_fire` serves both — verify caller splits `t.player == -1` ground-aim `:4939` the same way). Cite `weapon.script:751-803`.
3. **Add friendly-fire vetoes in `_fire` (new code; port currently has NO `DONOR_FF_PRECHECK_*` — P10 proves absence, so create, don't "enable").** (a) Ray: `if weapon.bcheckfriendonline and _building_on_ray(e.pos+0.5-lift, t.pos+0.5-lift): e.cooldown = 1.0; return` with the §1 10-sid opt-out list as a `const FF_RAY_OPT_OUT` (cite `weapon.script:482-492`); note donor tests ANY building, port `_wall_between` tests only wal/closed-gat — widen or tag delta. (b) Kind gates (only when NOT locked-target — port has no lock flag; add `locked: bool` or tag `[U]`): cannister → 6-fan weighted 4:1 (`unit.script:5336-5441` constants verbatim, tiles→m ×2.0 via `TILE_M`); cannonball (incl. mortar `dmgRad 3.75 m×2=7.5 m` vs else `1.25 tiles=2.5 m`) → `maxdisp+dmgRad` disc 4:1 with mount-0 disp (`unit.script:5290-5332`). Veto ⇒ `e.cooldown = 1.0`, drop attack order (`e.order = {"type":"none"}`), no projectile. Cite per line.
4. **Owner/team/height gates at impact (`game.gd:5020-5074`).** (a) Skip the OWNER in round/splash damage (`owner<>dmgHnd`, `doexplode.inc:83`, `miscext2.script:583`) — port `:5024` skips only `t.id`; add `u.id == owner.id → continue` (owner CAN still be the locked `victim` — keep). (b) Buildings take NO locked-target damage from non-targetable propagations (`stand/slightup/random1` children; `game.gd:4991-4993` allow-list is close but kind-based — extend with propagation where known, else tag). (c) `buseownerdamage` mounts (arrow/firearrow vs buildings, grenades — `doexplode.inc:59-60`) take MOUNT damage: port already uses `w.dmg` (mount) — audit each `UNITS_BASE weapons[] dmg` vs donor mount rows, never prototype damage. Height: NO height term in any veto or impact law — do not add one (`[O]` §5: scans are 2-D, `+0.5` is a ray lift, not a height gate).
5. **RNG routing (`game.gd:4941,4956,4966` + new veto/predict code).** Route scatter (×2), shot-point pick, rotspeed, ThrowRandom (×3), child count/pick, simulate seed/rotate/tail through the single sim `rng`; keep GENERAL-`random` draws (PlayOnce `volumeclippedfreq`, `uniqrnd=0→random` fallback, decal angles) on a NON-sim stream (new `rng_fx`, or tag `[U]`-F7 until split). Draw ORDER per §6 is normative; stream split is the `[U]` tail.
6. **Save contract (additive only).** Projectiles already carry kinematics; ADD `uniqrnd` per projectile (`TProj.uniqrnd`, `classes.script:4366`) when the spawner is next touched; missing key defaults `0.0` (donor fallback → GENERAL `random`, `weapon.script:1047-1048` — deterministic, no draw on load). No version bump, no key rename.
7. **Telemetry/format.** Every value above carries `weapon.script:<line>` / `unit.script:<line>` / `dmscript.global:<line>` cite in comment; every remaining estimate keeps PORT APPROXIMATION + `[U]` tag with its §7 series. `visual_parity_claim=false`; unresolved = F4/F5a/F5b/F5c/F6/F7 above + carried U1/G1-tail.

---

## 9. Explicit non-claims and file discipline

- NO PARITY CLAIM. No donor binary executed, no donor GPU frame captured, no port capture compared. Closed items (propagation registry, PredictShot stub + literal, veto formulas + weights + 4:1 rule, RNG draw order, `TProj` fields) rest on donor TEXT `[O]` with file:line; open items (engine ballistic, cross-PC stream semantics, port wiring) list exact captures in §7.
- The brief's "cooldown literal/source" is closed as: literal **`1`** (`onaclanimationreachedattack.inc:107-108,135-136`, `unit.script:8280-8281`), `Float` seconds scale (`dmscript.global:1737`, siblings `:8188,8209`) — gloss "1 s" is `[D]`, never a fresh invention.
- The brief's "cooldown or veto" invention ban is honoured: §8 wires the VERBATIM `1` and the VERBATIM 4:1/radii/weights/opt-outs; wherever the port lacks the data to apply them (child/sync tables, lock-target flag, second RNG stream) the item says so and stays `[U]` with its series.
- The brief's "`DONOR_FF_PRECHECK_*` inert data" is corrected, not smoothed over: P10 grep proves NO such consts exist in `app/scripts/*.gd` (and none exist in donor text either) — §8 item 3 creates the tables from the §5 verbatim constants instead of "enabling" anything.
- No approximation substituted for a resolved law. The three port inventions found (`×1.25` height, `dist/30` flight, halved constant scatter) are named with replacements in DEC_U_damage_height §10 and reused here, not re-litigated.
- Read-only compliance: exactly one repo file written (this report). Donor reads were pinned text reads against `t_87f0f3c130b0` (+ one read-only `Get-FileHash` + `Select-String` text greps); no target opened/selected/closed by this worker; no code/asset/config/Godot/git edit.

*End of DEC-U-FF-PREDICT.*
