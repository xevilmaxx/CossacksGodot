---
id: DEC-U-FLIGHT-NATIVE
worker: DEC-U-FLIGHT-NATIVE (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied/debugged. Donor text scripts/data read as text only (one read-only Get-FileHash by a sibling worker, not re-run here). No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. No multiplayer/netcode specified, audited, or changed."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed. No port capture compared."
context: "DEC_U_damage_height.md closed damage/dispersion but left the native `TXThrowBehaviour` projectile integration [U]; port game.gd keeps linear `dist/speed` + 0.45 s + 512 cap labelled PORT APPROXIMATION and gravity untouched. DEC_U_weapon_tail.md transcribed speed/gravity/propagation/time tables."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
---

# DEC-U-FLIGHT-NATIVE — native projectile update (`TXThrowBehaviour`, `TProj`, `PSimulatePoint`, gravity/speed, collision, time-step) (2026-11-26)

## 0. Pass ledger (every pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `t_87f0f3c130b0` re-asserted from the pinned string: `C:\Games\Cossacks 3\cossacks.exe`, PE32, 5,768,048 B, SHA256 `87F0F3C1…4E16C` — matches. Binary never executed/copied/debugged by this worker. No `Get-FileHash`/hash re-run needed; the sibling-worker hash is reused, not re-derived. |
| P2 | Native-boundary prior reuse (no new native call) | Packed-exe prior from `craft.json last_reply` triage reused verbatim, NOT re-run: `ev_31960c6f` (Delphi/C++Builder, packed `.bind` 7.96, stripped), `ev_60b49743` (18918 funcs, 12073 strings, 746 imports), entry `@0x8f1a08` `ev_03507405` (142 lines), `sub_8f0ad4 @0x8f0ad4` `ev_dec6ad57`, `sub_47c804 @0x47c804` `ev_bd3eda2b`. String sweeps (`peasant`/`damage`/`cannon` = 0 hits families `ev_35f172bb`/`ev_36f8c402`/`ev_74f46c64f`) and 0-ref xrefs (`ev_9945c378`, `ev_5a0f553a`, `ev_1e8d950e`, `ev_bc64940b`, `ev_ff7ce366`, `ev_113114fb`) prove game logic is NOT in readable static strings — the native `TXThrowBehaviour` integrator has no recovered address. **No native function address is claimed by this worker.** |
| P3 | Script-side flight re-pin (EV-FLT, text only) | `weapon.script:39-69` (registry shape), `:58-62` (physvalue meaning), `:807-852` (`ThrowByAngle`/`ThrowByHSpeed`/`ThrowRandom`), `:855-986` (`_weapon_InitProjectile`), `:988-1033` (PlayOnce instant), `:1039-1192` (`_weapon_CreateProjectileByWeaponID`), `:1135-1157` (`stand` pose), `:1242-1264` context, `:751-803` (`CheckWeapon`/`PredictShot`/`GetFlyChild`) re-verified against DEC_U_damage_height §5 + DEC_U_ff_predict §§1–4 `[O]`. `dmscript.global:172-175` (converters), `:278-288` (kind ids), `:688-704` (gravity/propagation/time enums), `:815` (`gc_MaxInt`), `:1737` (`attackdelay` Float) re-cited `[O]`. |
| P4 | Projectile-state + impact re-pin (EV-IMP) | `classes.script:4351-4367` `TProj` fields, `unit.script:11520-11561` `_unit_DoProjectile`, `projectile.inc/onstopevent.inc` + `doexplode.inc:12,31-89,139-210` + `doexplodecustom.inc`, `projectile.inc/…` chain, `unit.inc/onaclanimationreachedattack{,end}.inc:1-155` launch gate re-verified against DEC_U_ff_predict §§2/5 `[O]`. `miscext2.script:274-465` (`_misc_DoDamage`, no height term), `:560-604` (`_misc_DoRoundDamage`), `:641-728` (`_misc_ProjSimulatePoint` + `…Progress`), `misc.script:460-474` (converters) re-cited `[O]`. |
| P5 | Port read-only inspection (EV-PORT, this pass) | `app/scripts/game.gd:98` (`projectiles` decl), `:4861-4870` (`_dispersion_px`), `:4939-4973` (`_fire` ground-aim/cannonball/arrow branches), `:5046-5074` (`_tick_projectiles`), `:6091-6094` stale height note (per DEC_U_damage_height), `app/scripts/data.gd:21-23` (`FRAMES_TO_TIME`/`PX_TO_M`/`TILE_M`), `:93-95` (`ARROW/CANNON/TOWER_DISPERSION_PX`), `variant3d/scripts/game.gd:6541-6932` (donor-law helpers `_donor_speed_mps`, `_donor_projectile_speed_mps`, `_donor_predict_shot`, FF helpers, labelled `[U]-U1` flight comments) read this pass. Line numbers are current-file readings, not edits. |
| P6 | Negative grep (EV-NEG) | No `height` term in `miscext2.script:274-465`; no hit-probability roll in the fire→impact chain (only T2-closed `random<0.05` headshot); no donor `DONOR_FF_PRECHECK_*` const in donor text (DEC_U_ff_predict P10); no gravity-unit gloss anywhere in `weapon.script:855-913` or `dmscript.global:688-695` — the remap outputs are fed straight to the engine field. Absence is donor law where stated, `[U]` boundary where the engine owns the term. |

DSL note `[D]` (inherited): donor `not X` on a numeric lvalue is the current-value read. Donor `{...}` is comment syntax: live value is the uncommented head.

---

## 1. VERDICT — script sets the throw, the engine owns the curve; nothing in the port reproduces the curve

1. **The position-over-time law is split at a hard native boundary.** Script side (`weapon.script:855-986`) sets per-projectile `Speed`, `Gravity`, `Direction`, `TargetPosition`, `bthrow`/`bcollisiondetection`, `brotate`, `CollisionPriority`, `EnergyLoss`, and `time` — then calls one of three ENGINE entry points (`CalcSpeedByDirAndTrgPos`, `CalcDirByHSpeedAndTrgPos`, `SetupThrowBehaviourSpeed`). The per-frame integration (`TXThrowBehaviour` update), the gravity unit, the time-step, and the ground/water contact test live in the packed native image (§0-P2) and have **no recovered address, no pseudocode, and no script gloss** — they stay `[U]` by stated boundary, not by omission.
2. **What IS closed `[O]`:** the complete script-side input law (§2), the exact `speed` conversion (§3.1), the exact `time`-row values (§3.3), the gravity remap outputs (§3.2, values only — units never invented), the `TProj` field set and lifecycle (§4), the hit/explode gating order (§4.4, §5), and the propagation dispatch (§2.3). These rest on donor text with file:line and need no capture.
3. **What stays `[U]`:** the integrator itself — curve shape, gravity unit/scale, time-step/frame coupling, drag/`EnergyLoss` effect, ground/water contact rule, and mid-flight collision volume. §6 states the admissible shape (unknown) and §7 gives one fixed-camera shot series per unknown with a zero-mismatch termination criterion. **Never invent a gravity unit or curve.**
4. **Port status:** `app/scripts/game.gd` linear `dist/speed` + `clampf(…,0.5,1.6)` + `0.45 s` arrow + `512` cap is correctly labelled PORT APPROXIMATION; gravity is untouched (correct — there is nothing donor-grounded to wire). `variant3d/scripts/game.gd:6618-6639,6871-6929` already derives `total` from the donor speed table where the prototype physvalue is a speed and keeps the linear+clamp caveat with `[U]-U1` tags — that is the furthest the port may go without a capture.

---

## 2. Script-side input law `[O]` — everything the engine receives, verbatim

### 2.1 `speed` input (`weapon.script:872`)

```
speed := _misc_PixelsToTiles(floor(gWeapons[id].speed*1000))*0.001*gc_time_to_frames
```

- `_misc_PixelsToTiles(v) = v/53.3333333` (`misc.script:462-466`, `dmscript.global:172`) `[O]`; `gc_time_to_frames = 32` (`dmscript.global:175`) `[O]`.
- Worked `[D, arithmetic]`: `fly` physvalue 20 → `floor(20000)=20000` → `/53.3333333=375` → `×0.001=0.375` → `×32 = 12.0` tiles/s = **24 m/s** (×`TILE_M=2.0`); STRELA 25 → 15 tiles/s (30 m/s); NUCL2PTOW 38 → 22.8 tiles/s (45.6 m/s); `random` 3 → 1.8 tiles/s (3.6 m/s).
- **Only** `fly`/`random`/`random1`/`randomsimulate` prototypes carry a SPEED in physvalue (`weapon.script:58-62`) `[O]`. `angle` physvalue is DEGREES, `slightup` physvalue is `-gravity`, `stand`/`immediate` physvalue is unused.

### 2.2 `gravity` input (`weapon.script:877-894`) — values `[O]`, units `[U]`

Remap of the registration `gravity` arg (`dmscript.global:690-695` ids) `[O]`:

| donor arg | engine `Gravity` value |
|---|---|
| 0 | 2 (and `if gravity=0 then gravity := 2`, `:894`) |
| 1 | 2.5 |
| 2 | 3.75 |
| 3 | 7 (`//5.625` comment dead) |
| 4 | 9.25 |
| 5 | 11.5 |
| override | `fly` + arg-2 → **11.5** (arrows) |

- `EnergyLoss := 1` iff gravity-arg ≠ 0 (`:911-913`) `[O]`; effect on the curve is engine-side, unstated — `[U]` (§6.4).
- **No px/s², tiles/s², or m/s² gloss exists in script.** The values are passed to `TXThrowBehaviour.Gravity` as engine-internal units. Any port comment or const naming them m/s² is an invention — forbidden (§6.2).

### 2.3 Propagation dispatch (`weapon.script:945-985`) `[O]`

| propagation | throw path (engine call) | `bthrow` / collision | visual / notes |
|---|---|---|---|
| `angle` (5) | `_weapon_ThrowByAngle(angle…)` → engine `CalcSpeedByDirAndTrgPos` (`:807-822,947`) | `bthrow=True`, `CollisionPriority=10000` + `_weapon_OnCollide` iff `bthrow and bcollisiondetection` (`:967-973`) | aimed arc; direction rotated by `angle` degrees about the horizontal perpendicular |
| `fly` (3) | `_weapon_ThrowByHSpeed(speed…)` → engine `CalcDirByHSpeedAndTrgPos` (`:826-832,951-955`) | same ON law | flat/levelled aimed flight; script `speed` from §2.1 |
| `random` (2), `random1` (6) | `_weapon_ThrowRandom(speed)`: 3× `RandomExt` sphere-ish kick (`:838-852,957-960`) | `bthrow=False` → `:976-979`, collision OFF | `brotate := (random1) and projbasename<>'' and <>'point'` (`:54`); `bcollisiondetection := (angle or fly)` (`:55`) |
| `randomsimulate` (7) | same `ThrowRandom` now; REAL damage later via `_misc_ProjSimulatePoint` children (`doexplode.inc:192-193`) | OFF | Gaussian simulate system, `miscext2.script:641-728` `[O]`; port unported |
| `slightup` (1) | NO throw behaviour — falls to `cPlayOnce` instant branch (`:988-1033`) for all 40+ registered slightup rows (all `time=PlayOnce`) | OFF, scale 0.00001, instant `DoExplode`+`FreeToPool` | FX from mount (`buseownerfxshot`) or prototype; GENERAL-`random` fx roll explicitly non-sync (`:1011`) |
| `stand` (0) | NO throw; `py := RandomExt*0.125`, pitch `-(30+RandomExt*30)` (`:1135-1136,1156-1157`) | n/a (pooled `cProjArrowGround` visual) | `STRELDEZ` row `time=FramesToTime(950)`; `STRELDEZPRO` PlayOnce |
| `immediate` (4) | NEVER reaches projectile code — direct `_misc_DoDamage` in `onaclanimationreachedattack.inc:58-60` | n/a | no projectile, no flight |

Per-weapon default `bcheckfriendonline := True` (`:56`), opted OUT for exactly 10 sids (`:482-492`: `STRELA, OSTRELA, SHOTMUSKET, SHOTBLOCKHOUSE, NUCLGRE, PSMPOINTTPUS, DIMMORT1, DIMMORT2NEW, PSMPOINTT, DIMMORT2KOR`) `[O]` — the FF ray gate, not a flight term.

### 2.4 `time` input — the ONLY script-side timer `[O]`

`weapon.script:41-43,900`: `<0` Infinite (`cInfinite=-1`), `=0` PlayOnce (`cPlayOnce`), `>0` timed. Handling (`:984-985`): `cInfinite` → `OnStopEvent='OnStopEvent'` (lands when the ballistic ends); `time>0` → **ALSO** `GameObjectDelayExecuteStateByHandle(projHnd,'OnStopEvent',time)` — timed airburst; `cPlayOnce` → no behaviour at all, instant `DoExplode`+`FreeToPool` (`:988-1033`).

Timed rows (complete): 14 PUSSTRELA `round()` rows + `NUCLM FramesToTime(2)` — see §3.3. There is **no other script-side flight timer**; `dist/30`, `0.45 s`, `0.5–1.6` clamp, `512` cap have no donor counterpart.

### 2.5 Launch geometry inputs `[O]`

- `_unit_DoProjectile` (`unit.script:11520-11561`): `disp` = firing-mount `dispertion` (tiles); `SetRandomKey(floor(random*gc_MaxInt))` GENERAL; scatter 2× `RandomExt` iff `disp>0` (`_weapon_CalcShotDispertion`, `weapon.script:627-646`, box law `maxdisp = dist×disp×gc_pixels_to_tile/2000` — tiles); `frnd := RandomExt` stored for `WriteProj` AFTER scatter; `PlayerExecuteStateByHandle(plHnd,'WriteProj')` `[O]`.
- `_weapon_CreateProjectileByWeaponID` (`:1039-1192`): resync `SetRandomKey(floor(newuniqrnd*gc_MaxInt))` (`newuniqrnd := random` GENERAL iff `uniqrnd=0`); shot-point `floor(RandomExt*count)` (`:1118`); `random1` orientation 6× `RandomExt` (`:1151`); `stand` 1× `RandomExt`; `brotate` rotspeed 1× `RandomExt` (`:936-938`); `ThrowRandom` 3× `RandomExt`; stores `TProj.uniqrnd := newuniqrnd` (`:1185`) `[O]`.
- Attack-point ground height: `ty` via `RayCastWater`/`RayCastHeight` (`onaclanimationreachedattack.inc:128-129`) `[O]` — the aim point is terrain/water-snapped, not a blind coordinate.

---

## 3. Unit conversions `[O]` — exact, with worked values; gravity unit explicitly NOT closed

### 3.1 `speed`: px → tiles/s → m/s `[O]`

- `gc_pixels_to_tile = 53.3333333` (`dmscript.global:172`), `gc_tiles_to_pixels = 0.01875` (`:173`), `gc_time_to_frames = 32` (`:175`), `gc_frames_to_time = 0.03125` (`:174`) `[O]`. Port `data.gd:21-23` (`FRAMES_TO_TIME := 0.03125`, `PX_TO_M := 1/26.6666666`, `TILE_M := 2.0`) matches; `gc_pixels_to_meter = 26.6666666` / `gc_meters_to_tile = 2` per D08_tile_select_bin (same `:170-173` block) `[O]`.
- Closed conversion chain `[D, arithmetic]`: `speed_tiles_s = floor(phys×1000)/53.3333333×0.001×32`; `speed_m_s = ×2.0`. Table: phys 20→12.0 t/s→24 m/s; 25→15→30; 38→22.8→45.6; 3→1.8→3.6; 4→2.4→4.8; 9→5.4→10.8; 15→9→18. `variant3d game.gd:6622-6625` `_donor_speed_mps` encodes exactly this chain — keep.
- `floor()` is donor-verbatim (`:872`); `phys×1000` products here are integral so floor is inert on these rows, but the call stays verbatim — do not "simplify" it away.

### 3.2 `gravity`: remap outputs `[O]`, scale `[U]` — never invent

- Outputs 2 / 2.5 / 3.75 / 7 / 9.25 / 11.5 (+ fly-2 → 11.5 override, + zero→2 default) are `[O]` §2.2. The donor never states tiles/s², px/s², m/s², per-frame vs per-second, or the integrator order that consumes them. **Any port const, comment, or formula assigning a physical unit to these numbers is an invention and is forbidden.** The port correctly leaves gravity untouched (EV-PORT: no gravity wiring in `app` or `variant3d` flight code) — keep it that way until an N-series capture (§7) constrains the curve, and even then wire the CURVE, not a unit gloss.

### 3.3 `FramesToTime` / `time` rows `[O]`

- `_misc_FramesToTime(v) = v×0.03125` (`misc.script:470-474`) `[O]`; `gc_time_to_frames = 32` (`:175`) `[O]`.
- Resolved timed rows `[D, arithmetic; bankers caveat stays [U]-G1]`: `NUCLM FramesToTime(2) = 0.0625 s`; `STRELDEZ FramesToTime(950) = 29.59375 s`; PUSSTRELA `round(2×1.625)=round(3.25)=3` → 0.09375 s; `round(4×1.625)=round(6.5)→6 bankers` → 0.1875 s; `round(8×1.625)=13` → 0.40625 s; `round(5×1.625)=round(8.125)=8` → 0.25 s; `round(10×1.625)=round(16.25)=16` → 0.5 s; `round(15×1.625)=round(24.375)=24` → 0.75 s; `round(2×2.75)=round(5.5)→6` → 0.1875 s; `round(4×2.75)=11` → 0.34375 s; `round(8×2)=16` → 0.5 s; `round(2×0.5)=1` → 0.03125 s; `round(5×0.5)=round(2.5)→2` → 0.0625 s; `round(10×0.5)=5` → 0.15625 s; `round(15×0.5)=round(7.5)→8` → 0.25 s. `round()` half-to-even stays `[U]`-G1 (X21 20-vector fixture per DEC_U_skirmish_tables §9-G1); time_expr strings stay verbatim.

---

## 4. `TProj` state machine + hittable/explode timing `[O]` shape, `[U]` native tail

### 4.1 `TProj` fields (`classes.script:4351-4367`) `[O]`

`weaponid, owner (unique id), trg (unique id), px/py/pz (launch), dx/dy/dz (aim), ownerpl (player index), ownercid/ownerid/ownerweaponind, uniqrnd`. The owner/team/height gate inputs live HERE (unique-id owner + `ownerpl`), not in any donor table — no `DONOR_FF_PRECHECK_*` const exists in donor text (DEC_U_ff_predict P10) `[O]`. Port projectiles (`app game.gd:98,4944-4970`; `variant3d :6878-6932`) currently carry `pos/target/kind/dmg/splash/owner/player/t/total` (+`uniqrnd`/`donor_shot` in variant3d only) — launch-vs-aim split (`px` vs `dx`), `trg` uid, and `ownerpl/cid/id/weaponind` are absent (§8 items 4–5).

### 4.2 Lifecycle `[O]`

1. Animation gate (`onaclanimationreachedattack.inc:1-155`): `bProcess` client check; `weaponid=0` → direct damage; `immediate` → direct damage + pooled FX ghost; else `PredictShot` allow/deny (`:97-109,131-137`) — deny applies literal `attackdelay := MaxFloat(attackdelay,1)` + `attackmaxdelay` ×2 and creates NOTHING (`:107-108,135-136`) `[O]`.
2. `_unit_DoProjectile` scatter→`WriteProj` (§2.5) → `_weapon_CreateProjectileByWeaponID` resync + field store (`TProj.uniqrnd := newuniqrnd`, `:1185`) → `_weapon_InitProjectile` behaviour attach (§2.3–2.4) `[O]`.
3. Flight: engine `TXThrowBehaviour` owns position integration (§6 `[U]`).
4. Termination EITHER (a) ballistic end / timed airburst → `OnStopEvent` → `DoExplode` chain, OR (b) mid-flight `OnCollide` (aimed `angle`/`fly` only) → trg-switch → `DoExplode`, OR (c) PlayOnce instant `DoExplode`+`FreeToPool` with no flight at all `[O]`.

### 4.3 `PSimulatePoint` subsystem (`miscext2.script:639-728`) `[O]`

`randomsimulate` children only: seed `floor(RandomExt*100000)` (`:644`); Gaussian helpers over a LOCAL LCG (`a=314159269,c=453806245,m=2147483647`, `:648-650`) with `RandomGauss localseed=floor(RandomExt*1000000)` (`:670`) / `RandomGaussExt` (`:685`), σ=0.25/0.425; `dst` rotated `RandomExt*360` (`:718`); `damagetime = 0.275+…` (0.275–0.64 s window); 2048-slot ring `gProjSimulatePoints`, resolved in `_misc_ProjSimulatePointsProgress` via `_misc_DoRoundDamage(…,True)` `[O]`. Port has no simulate-point system — `POINTOTVZRIV`/`POINTOTVZRIVFRAME` mounts are unported by construction (§8 item 7; series N6 stays red until implemented verbatim or tagged PORT-UNSUPPORTED).

### 4.4 When the projectile becomes hittable / explodes `[O]` gating, `[U]` volumes

- **Hittable in flight:** ONLY aimed `angle`/`fly` throws with `bthrow and bcollisiondetection` get `CollisionPriority=10000` + `_weapon_OnCollide` (`weapon.script:967-973`) `[O]`. `random/random1/randomsimulate` (`bthrow=False`), `slightup`/`stand` (no behaviour), `immediate` (no projectile) are NEVER mid-flight hittable — they can only detonate at the terminus. The collision VOLUME (radius/shape vs `CollisionPriority` semantics) is engine-side — `[U]` (§6.5).
- **Explode at terminus:** `DoExplode` (`doexplode.inc:78-89`): if `damage>0`: if `TWeapon(pweapon).radius>0` → `_misc_DoRoundDamage(px,pz,radius,damage,owner,trg,kind,False)`; if `bAllowTrgDamage and trgHnd<>0 and ownerHnd<>trgHnd` and target alive → `_misc_DoDamage(owner,trg,…)` — the locked target takes BOTH (double-dip is donor law) `[O]`. Buildings immune to non-`CheckWeaponTargetable` propagations (`:73`); dead-target custom-explosion routing `:148-210` `[O]`.
- **`OnCollide` trg-switch law** (`doexplode.inc:31-54` per DEC_U_damage_height §5/`doexplode.inc` + DEC_U_ff_predict §5): collision retargets `trgHnd` before the same `DoExplode` chain; owner excluded as `dmgHnd` in the round loop (`owner<>dmgHnd`, `miscext2.script:583`) but NOT excluded as a locked `victim` when directly targeted (suicide-by-lock allowed) `[O]`. Port `app game.gd:5055-5072` nearest-in-8 m + `1.2+block_r` rule + `:5024` lock-only skip has no donor cite — delta §7-N4/§8-6.
- **Victim cap** (`_misc_DoRoundDamage`, `:562-604`): scan radius `r` (+`cMaxExplMediaR=225/53.3333333=4.21875` tiles when `not bsimulation and not barrow`); victim cap `count = Floor(1+sqr(r/0.35))` (e.g. r=0.9375→8; r=1.875→29); non-buildings need `dist < r+explradius` (non-arrow) or `dist < r` (arrow, plus `listcount>300` overflow rule); each victim via `_misc_DoDamage`; wall splash is the separate engine-adjacent call `:240-256` (already `[U]`-U3 per DEC_U_damage_height, untouched here) `[O]`.

---

## 5. Ground / water collision `[O]` aim-side, `[U]` contact-side

- **Aim side `[O]`:** attack-point shots snap `ty` through `RayCastWater`/`RayCastHeight` (`onaclanimationreachedattack.inc:128-129`); `_weapon_CalcShotDispertion` keeps `dy := ty` (commented `RayCastHeight` alternative dead, `weapon.script:627-646`). Dispersion never changes height — the aim point's Y is the snapped terrain/water height.
- **Contact side `[U]`:** which surface (terrain mesh vs water plane vs building AABB), what threshold ends the ballistic, whether water shortens/delays `OnStopEvent`, and whether the visual differs (splash vs crater/dirt) are all engine-side — no script line states them. The port posts `crater` for `cannonball` and `hit` otherwise at `p.target` regardless of surface (`app game.gd:5067-5073`) — ungrounded choice, tagged PORT APPROXIMATION (§8-6). Series N5 (§7) constrains it; until then no surface rule may be wired.

---

## 6. Time-step integration — the native boundary, stated precisely so nothing is invented

### 6.1 What is known `[O/D]`

- Script hands the engine a complete throw descriptor per §2 (Speed/Gravity/Direction/TargetPosition + behaviour flags) and a `time` mode per §2.4. The engine advances the projectile and fires `OnStopEvent` (terminus/airburst) or `OnCollide` (mid-flight, aimed only) — the NAMES are script-visible (`:984-985`, `:967-973`), the BODIES are native.
- The sim frame clock is 32 fps (`gc_time_to_frames=32`, `gc_frames_to_time=0.03125` `[O]`); sibling cooldown arithmetic (`100×0.03125=3.125 s`, `64×0.03125=2.0 s`, bare literal `1` = 1.0 s `[D]` per DEC_U_ff_predict P11) shows seconds-scale state. Whether `TXThrowBehaviour` integrates per sim-frame, per render-frame, or sub-stepped is NOT stated — `[U]`.
- `attackdelay`/`attackmaxdelay` are `Float` seconds (`dmscript.global:1737`) `[O]`; projectile `t`/`total` in the port are seconds floats — compatible scale, donor law for `total` is absent (see §6.6).

### 6.2 Gravity unit — explicitly unrecoverable from text `[U]`

The six remap outputs + two overrides (§2.2) are the complete donor statement. No divisor, no `dt` coupling, no tiles/s² or m/s² label co-occurs with them in `weapon.script:877-913`, `dmscript.global:688-695`, or any caller. Candidate readings (per-second acceleration? per-frame velocity decrement? engine-internal fixed-point?) are all `[I]` — listed here ONLY to forbid them: **do not wire, name, comment, or test any of them.** The capture series constrains the CURVE (§7-N1/N2); the unit is never named.

### 6.3 Position-over-time law — admissible shape `[U]`

The ONLY admissible port statement today is: `pos(t) = NativeThrow(pos0, aim, speed, gravity, t), 0 ≤ t ≤ T_land`, where `NativeThrow` is unknown, `T_land` is engine-determined (or `time` for airbursts), and landing `pos(T_land)` is only constrained to the §2.5 scatter box on a flat map. Linear `lerp(pos0,aim,t/total)`, parabolic `pos0+v0·t−½g·t²` with ANY `g`, and `clampf(dist/speed,…)` are all PORT APPROXIMATIONS — the first two invent a curve, the third invents both curve and timer. Series N1 (§7) is the sole path to replacing them.

### 6.4 `EnergyLoss` / drag `[U]`

`EnergyLoss := 1 iff gravity-arg≠0` (`:911-913`) `[O]` is a set flag, not a formula. Whether it damps speed, shortens range, or is inert for ballistic throws is unstated. Do not model drag until N1/N2 bound it.

### 6.5 Mid-flight collision volume `[U]`

`CollisionPriority=10000` + `_weapon_OnCollide` gating (`:967-973`) is `[O]`; what 10000 MEANS (priority vs radius vs order), the projectile's hit volume, and the building/unit test order are native. Port `1.2+block_r` nearest-in-8 m (`app game.gd:5058-5066`) is ungrounded — series N4.

### 6.6 Port `total` timer — ungrounded `[O]` absence

No script line computes `total = dist/speed`, clamps it to `0.5–1.6`, fixes arrows at `0.45 s`, or caps live projectiles at `512`. All four are PORT APPROXIMATION (`app game.gd:4943,4958,4969-4970`; `variant3d :6877,6908,6929-6932` keeps them labelled). The donor `time` rows that DO exist (§3.3) are airburst/despawn timers, not flight-duration estimates — never repurpose them as `total`.

---

## 7. Still-`[U]` register — fixed-camera shot-series captures with zero-mismatch termination

General harness (all series): fixed camera (frozen `camera3d`, no shake — sim assertions read `projectiles[].t/total/target` / `entities[].hp` / `cooldown`, never pixels). Flat test map (all `height==h0`), actors S (shooter) + T (target), seeded sim `rng` re-seeded per series. **Termination criterion (all): run the FULL series; ANY single mismatch vs the stated donor expectation keeps the item `[U]` and forbids wiring; zero mismatches across the full series closes it.** Never fit/invent a gravity unit or curve — the §2 input law + §3 conversions are the only admissible shapes; series constrain BEHAVIOUR, not units.

| # | Item | Static state after this ticket | Exact capture (owner-authorised) |
|---|---|---|---|
| N1 | Ballistic curve + landing (`TXThrowBehaviour` integration; gravity application) | Script inputs `[O]` §2; speed conversion `[O]` §3.1; gravity VALUES `[O]` §2.2, units `[U]` §6.2; port linear+clamp PORT APPROXIMATION | Series N1-FLT: flat map, cannon (PPOINTT / phys n/a — angle path via `CalcSpeedByDirAndTrgPos`) vs ground aim T at 10/20/30/40 m, 50 shots each (200). Record per-shot `total` + landing `target` + (if exposed) mid-flight `pos` samples. Expectation: landing inside the §2.5 scatter box (`maxdisp_m = dist_m×dispertion_px/2000`, cannon idx0 225 px `[O]` `unit.script:1708`); `total` consistent with donor speed table order (12 t/s-class flight, NOT `dist/30`); no NaN, no outside-box landing. Any outside-box/NaN → stays `[U]`. Mid-flight samples are TELEMETRY ONLY (no curve fitted, no gravity unit named). |
| N2 | `fly`-path levelling (`CalcDirByHSpeedAndTrgPos`; arrow override gravity 11.5) | `fly`+arg-2→11.5 override `[O]`; STRELA 25→30 m/s `[O]`; port arrow `total` PORT APPROXIMATION | Series N2-FLY: archer (STRELA-profile, `fly`, phys 25) vs ground aim at 10/20/30 m, 50 shots each (150). Expectation: same box law (archer 175 px `[O]`), flight ordered by 30 m/s donor speed; `total` MUST differ from the current fixed 0.45 s on at least one range (else the 0.45 s is falsified but nothing is wired — item stays `[U]` until a behaviour-matching replacement passes the full series with zero mismatches). |
| N3 | Timed airburst (`time>0` rows: 14 PUSSTRELA + NUCLM) | Rows + resolved seconds `[O]` §3.3; `DelayExecuteState(OnStopEvent,time)` `[O]` §2.4 | Series N3-BURST: PUSSTRELA-profile (e.g. `round(2×1.625)=3` → 0.09375 s) vs target BEYOND ballistic reach, 50 shots. Expectation: burst at donor-`time` (via `donor_round`-exact value, bankers caveat `[U]`-G1) with full round+locked-target damage at the burst point (`doexplode.inc:78-89` law). Zero mismatches → wireable as `total=time` for timed rows ONLY; any → `[U]`. |
| N4 | Mid-flight hittability + victim pick (`OnCollide`, prio 10000, trg-switch) | Gating (aimed-only) + double-dip + owner-exclusion + cap `[O]` §4.4; volumes `[U]` §6.5 | Series N4-HIT: two targets 1.5 m apart crosswise/downrange inside the dispersion box at mid flight path, 100 shots per geometry (300); plus owner-inside-own-radius geometry, 30 shots. Expectation: (i) `random/slightup/stand/immediate` profiles NEVER retarget mid-flight (terminus-only); (ii) `angle`/`fly` retarget per `doexplode.inc:31-54` trg-switch (not port nearest-in-8 m — systematic always-nearest = mismatch); (iii) owner takes NO round damage (`owner<>dmgHnd`) but CAN take locked-target damage when targeted; (iv) victim counts obey `Floor(1+sqr(r/0.35))`. Zero mismatches → wireable; any → `[U]`. |
| N5 | Ground / water contact (terminus rule, surface FX) | Aim-side snap `[O]` §5; contact rule `[U]` | Series N5-SURF: ground aim vs water aim (same dist), 50 shots each (100), flat map with a water patch. Expectation (minimal): terminus `OnStopEvent` fires for BOTH (no hang/no NaN/no infinite `t`); landing `target` inside the scatter box in both cases. Surface-FX delta (splash vs crater) is TELEMETRY ONLY — no FX rule wired on this series. Any hang/NaN/outside-box → `[U]`. |
| N6 | `randomsimulate` fratricide / simulate points | Gaussian LCG law `[O]` §4.3; port has NO system | Series N6-SIM: NUCLMOSKOL-profile impact, record 200 child impact points + damage times. Expectation: Box-Muller σ=0.425 clamp pattern, `dst ≤ 1.3` tiles, `damagetime ∈ [0.275,0.64]` s (per DEC_U_damage_height §7/§9-U6). KS-test p>0.01 AND bound violations=0 → wireable verbatim; else `[U]`. Do NOT fake with uniform scatter. |
| N7 | Time-step coupling (`t`/`total` scale, 512-cap absence) | Frame clock 32 fps `[O]`; no donor `total`/cap `[O]` absence §6.6 | Series N7-STEP: sustained cannon fire (600 shots, cap would bite at 512) at fixed 32 Hz sim step, then at 2× step. Expectation: NO 512-drop (every shot yields a terminus event — port currently drops → known mismatch, stays `[U]`); `t` accumulates in seconds; step-doubling does not change landing boxes (engine determinism probe — landing outside box at either step → `[U]`). |

---

## 8. Concrete port change list (owner/COORD applies; this worker wrote no code)

All items add DONOR-VERBATIM values or explicitly labelled placeholders. None invents a number or a gravity unit/curve. None touches save-version keys, demo/mill/builder hooks, or I11 seam paths.

1. **`app/scripts/game.gd:4943,4958` flight `total` — replace linear core, keep clamp labelled.** Derive `total` from the §3.1 donor speed table where the mount prototype physvalue is a speed (`variant3d :6622-6639` `_donor_projectile_speed_mps` is the reference shape — port it: `floor(phys×1000)/53.3333333×0.001×32` tiles/s `×2.0` m/s; `fly` 20→24 m/s; STRELA 25→30 m/s; `random` 3→3.6 m/s). Keep `clampf(…,0.5,1.6)` ONLY with a PORT APPROXIMATION + `[U]`-N1 comment (no donor clamp exists). Cite `weapon.script:872`, `misc.script:462-466`, `dmscript.global:172-175`. `angle`-physvalue mounts (DEGREES) and `stand`/`slightup` mounts (no speed) keep the labelled fallback — never feed degrees into the speed chain.
2. **`app/scripts/game.gd:4969` arrow `0.45 s` — replace with donor speed, keep clamp labelled.** `total = clampf(dist0 / 30.0, 0.5, 1.6)` (STRELA 25 → 30 m/s `[O]` `weapon.script:872/:1067`); the 0.5–1.6 clamp stays PORT APPROXIMATION + `[U]`-N2 until N1/N2 close. Delete the bare `0.45` literal. Cite per line.
3. **Timed rows get `total = donor time`, nothing else.** For mounts whose prototype `time>0` (14 PUSSTRELA `round()` rows + NUCLM `FramesToTime(2)=0.0625 s`, verbatim `time_expr` from `DONOR_WEAPON_PROTOS`), set `total` to the §3.3 resolved seconds (via existing `donor_round`, bankers tag `[U]`-G1 kept). Cite `weapon.script:41-43,900,984-985,349-362`. Until N3 closes, ALSO keep the ballistic-terminus path (airburst AND landing both scheduled — donor schedules both via `DelayExecuteState` on top of the ballistic).
4. **Gravity: wire NOTHING.** No `gravity` key, no `g` const, no `½g·t²` term, no comment naming m/s²/tiles-s². If a telemetry field is wanted, store the VERBATIM remap output (2/2.5/3.75/7/9.25/11.5 + overrides, `weapon.script:877-894`) under a `gravity_arg`/`gravity_engine` key explicitly tagged `engine-internal units, [U]-N1 — never physical`. Any physical-unit gloss is forbidden.
5. **`TProj` parity (additive only).** When projectiles are next touched: ADD `trg` (locked-target uid, 0 = ground aim), `ownerpl`, `uniqrnd` (already in variant3d `:6881,6912,6930` — port to `app`), launch `pos` vs aim `target` split naming (`pos` = `px` launch, `target` = `dx` aim — comment the `classes.script:4351-4367` mapping). Missing keys default `0`/`0.0` (donor `uniqrnd=0` → GENERAL `random` fallback, `weapon.script:1047-1048` — deterministic, no draw on load). No version bump, no key rename. Cite `classes.script:4351-4367`, `weapon.script:1185`.
6. **`app/scripts/game.gd:5046-5074` impact — gate order toward donor, volumes stay `[U]`.** (a) Skip the OWNER in round/splash damage (`owner<>dmgHnd`, `miscext2.script:583`, `doexplode.inc:83`) — `app :5024` skips only `t.id`; add `u.id == owner.id → continue` for the splash loop (owner CAN still be the locked `victim` — keep). (b) Buildings take NO locked-target damage from non-targetable propagations (`doexplode.inc:73`) — extend `app :4991-4993` kind allow-list with propagation where known, else tag `[U]`-N4. (c) Victim pick: keep nearest-in-8 m ONLY with PORT APPROXIMATION + `[U]`-N4 until N4 closes — do not tune `1.2/2.0/8.0` to pass. (d) Surface FX (`:5067-5073` crater/hit): tag PORT APPROXIMATION + `[U]`-N5 (no surface rule wired). Cite per line.
7. **`randomsimulate` children — verbatim or explicit non-support.** Either implement `_misc_ProjSimulatePoint` verbatim (`miscext2.script:641-728`: local LCG Box-Muller, `dst≤1.3` tiles, `damagetime` window, 2048-slot ring, `…Progress` via `_misc_DoRoundDamage(…,True)`) or tag `POINTOTVZRIV/FRAME` mounts PORT-UNSUPPORTED with N6 red. Do not fake with uniform scatter.
8. **`512` cap (`app :4947-4948,4962-4963,4970-4971`) — tag, don't tune.** No donor cap exists (`[O]` absence §6.6). Keep the cap ONLY with PORT APPROXIMATION + `[U]`-N7 (anti-hang guard) until N7 closes; never raise/lower it to "match" a capture.
9. **`data.gd` — no new flight const except verbatim tables.** `FRAMES_TO_TIME`/`PX_TO_M`/`TILE_M` (`data.gd:21-23`) and `ARROW/CANNON/TOWER_DISPERSION_PX` (`:93-95`) are already donor-grounded — keep. ADD nothing for gravity/speed (the speed chain is arithmetic on `DONOR_WEAPON_PROTOS` physvalues, not a new const). `DONOR_WEAPON_PROTOS` `time_expr` strings stay verbatim (never pre-rounded; bankers `[U]`-G1).
10. **RNG routing (with §4/§6 order normative).** Route scatter (×2), shot-point pick, rotspeed, ThrowRandom (×3), child count/pick, simulate seed/rotate/tail through the single sim stream; keep GENERAL-`random` draws (PlayOnce `volumeclippedfreq`, `uniqrnd=0→random` fallback, decal angles) on a NON-sim stream (new `rng_fx`, or tag `[U]`-F7/N7 until split). Draw ORDER per §2.5 is normative; stream split is the `[U]` tail. Cite per line.
11. **Telemetry/format.** Every value above carries `weapon.script:<line>` / `unit.script:<line>` / `miscext2.script:<line>` / `dmscript.global:<line>` / `classes.script:<line>` cite in comment; every remaining estimate keeps PORT APPROXIMATION + `[U]` tag with its §7 series. `visual_parity_claim=false`; unresolved = N1–N7 above + carried U2–U9/G1-tail (dispersion victim pick, height metrology, FF gates, PredictShot, simulate, bankers, stream attribution per DEC_U_damage_height §9 + DEC_U_ff_predict §7).

---

## 9. Explicit non-claims and file discipline

- NO PARITY CLAIM. No donor binary executed, no donor GPU frame captured, no port capture compared. Closed items (script throw inputs, speed conversion, time rows, gravity remap VALUES, `TProj` fields, gating order, victim cap, simulate-point law) rest on donor TEXT `[O]` with file:line; open items (integrator, gravity unit/scale, time-step, drag, contact rule, collision volume, port `total`/cap/FX) list exact captures in §7.
- No native address is claimed: `TXThrowBehaviour` / `CalcSpeedByDirAndTrgPos` / `CalcDirByHSpeedAndTrgPos` / `SetupThrowBehaviourSpeed` / `OnCollide` / `OnStopEvent` / `DelayExecuteState` have no recovered address in this ticket; the §0-P2 packed-exe prior (`ev_31960c6f`/`ev_60f443` family, entry `@0x8f1a08` `ev_03507405`) is reused, not re-run. The native projectile update stays `[U]`-N1 by stated boundary, not by omission.
- Never invented: no gravity unit (m/s², tiles/s², px/s², per-frame), no curve (linear, parabolic, clamped), no `total`/`0.45 s`/`512` donor counterpart, no surface rule, no collision volume. The port inventions found (`dist/30` clamp, arrow 0.45 s, 512 cap, `1.2+block_r` nearest-in-8 m, unconditional crater/hit FX) are named with replacements-or-tags in §8, not smoothed over.
- Read-only compliance: exactly one repo file written (this report). Donor reads were pinned text reads against `t_87f0f3c130b0` plus reuse of one read-only sibling hash; no target opened/selected/closed by this worker; no code/asset/config/Godot/git edit.

*End of DEC-U-FLIGHT-NATIVE.*
