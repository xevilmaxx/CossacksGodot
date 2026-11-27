---
id: DEC-U-DAMAGE-HEIGHT
worker: DEC-U-DAMAGE-HEIGHT (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied. Donor text scripts/data read as text only (Get-FileHash is a read-only hash, not execution). No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. No multiplayer/netcode specified, audited, or changed."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed."
context: "DEC_U_skirmish_tables.md closed T2 _misc_DoDamage but found NO height/dispersion term, leaving D1 open; port game.gd:6091-6094 + 6376-6491 tags height/dispersion/flight approximations [U]-D1. DEC_U_weapon_tail.md transcribed mount dispertion_px/addradius_px rows but did not wire them."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
---

# DEC-U-DAMAGE-HEIGHT — donor projectile flight / damage application: height, dispersion, flight (2026-11-26)

## 0. Pass ledger (owner rule; every pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `Get-FileHash cossacks.exe` this pass: SHA256 `87F0F3C1…4E16C`, 5,768,048 B — matches pin. Binary never executed/copied (hash is read-only). Prior packed/stripped finding reused from repo text only: `craft.json last_reply` triage `ev_31960c6f` (Delphi, `.bind` 7.96, stripped), overview `ev_60b49743` (18918 funcs). No new native calls by this worker. |
| P2 | `miscext2.script:274-465,560-728` full read | EV-DMG: `_misc_DoDamage` re-verified — no height/dispersion/flight term `[O]`; `_misc_DoRoundDamage` (radius/count/arrow law) + `_misc_ProjSimulatePoint` (gaussian scatter) transcribed §7/§8 `[O]`. |
| P3 | `weapon.script:39-69,625-646,793-803,855-1192,1242-1264` full read | EV-FLT: `_weapon_CalcShotDispertion` exact formula `[O]` §2; `_weapon_InitProjectile` speed/gravity tables `[O]` §5; `_weapon_CreateProjectileByWeaponID` RNG/sync law `[O]` §8; `_weapon_PredictShot` stub (`True` iff fly child) `[O]` §5; `DoExplode`/`DoExplodeCustom` call `doexplode*.inc` (P5). |
| P4 | `unit.script:510-546,7540-7570,7852-8035,10750-10794,11520-11561,2726` read | EV-RNG-SHOT: height `bonusrng`/`rbonus` range-only law, 3 call sites `[O]` §4; `_unit_DoProjectile` dispersion+RNG sequence `[O]` §2/§8; `uniqrnd := RandomExt` spawn site `:2726` `[O]` §8 (corrects a port comment). |
| P5 | `projectile.inc/{onstopevent,doexplode,doexplodecustom}.inc` + `unit.inc/onaclanimationreachedattack{,end}.inc` read | EV-IMPACT: fire→projectile→`OnStopEvent→DoExplode→(_misc_DoRoundDamage + _misc_DoDamage)` chain `[O]` §6/§7; melee/`weaponid=0`/`immediate` bypass projectiles (direct `_misc_DoDamage`) `[O]` §6. |
| P6 | `dmscript.global` constants grep (EV-CONST) | `gc_pixels_to_tile=53.3333333` `:172`, `gc_tiles_to_pixels=0.01875` `:173`, `gc_frames_to_time=0.03125` `:174`, `gc_time_to_frames=32` `:175`, `gc_obj_maxattackradiusdisp=3` `:116`, `gc_unit_meleeattackradius=3.5` `:197`, `gc_MaxInt=2147483647` `:815`, gravity/propagation/time enums `:688-704` — all `[O]`. |
| P7 | `weapon.script:349-362` round() sites + `misc.script:465-473` converters | EV-ROUND: `round()` occurs ONLY in the 14 PUSSTRELA time rows `[O]`; `_misc_PixelsToTiles(v)=v/53.3333333`, `_misc_FramesToTime(v)=v*0.03125` `[O]` §8. |
| P8 | Port read-only inspection (EV-PORT) | `game.gd:40` TILE=2.0, `:2907-2921` height_at (metres), `:6091-6094` hd>0.6 ×1.25 bonus, `:6376-6385` `_dispersion_px`, `:6458-6491` fire/flight (`dist/30` clamp 0.5–1.6, arrow 0.45 s, 512 cap), `:6585-6604` splash, `:6545-6564` damage ctx; `data.gd:22` PX_TO_M, `:420-423` dispersion consts, `:1206-1214` donor_round, `:1233-1397` DONOR_SHIELD/MOUNT rows, `:1044+` DONOR_WEAPON_PROTOS. No consumers of DONOR_MOUNT/DONOR_SHIELD/donor_round in `game.gd` (grep P8). |
| P9 | Negative grep (EV-NEG) | No `height`/`hill`/`Hill`/`bonus` term in `miscext2.script:274-465` damage path; no `dispertion` read in `_misc_DoDamage`; no to-hit/percentage roll anywhere in fire→impact chain (only `random<0.05` headshot, already T2-closed). `TProj` (`classes.script:4351-4367`) carries kinematics only, no accuracy field `[O]`. |

DSL note `[D]` (inherited): donor `not X` on a numeric lvalue is the current-value read. Donor `{...}` is comment syntax: live value is the uncommented head.

---

## 1. VERDICT — height and dispersion never touch hit probability or damage; dispersion shifts the impact point, height extends range downhill only, flight is ballistic with no script-side timer

1. **There is NO hit-probability roll in the donor.** The fire→impact chain is: range gate (`_unit_TryAttack`, §4) → animation event (`onaclanimationreachedattack.inc:9-110`) → melee/`weaponid=0`/`immediate` call `_misc_DoDamage` directly (always applies), otherwise `_unit_DoProjectile` → engine `TXThrowBehaviour` ballistic → `OnStopEvent→DoExplode` → `_misc_DoRoundDamage` (radius) + `_misc_DoDamage` (locked target). The only percentage roll in the whole chain is the T2-closed headshot `random<0.05`. Conjecture "dispersion = miss chance" is donor-false `[D]`.
2. **Dispersion changes WHERE the projectile lands, not WHETHER it hits.** Exact law §2: uniform square scatter `±maxdisp` per axis, `maxdisp = dist × dispertion_px / 2000` (tiles), drawn from the sim `RandomExt` stream. Never invented as a curve — this IS the donor formula `[O]`.
3. **Height changes RANGE ONLY, downhill only, additively.** Exact law §4: `bonusrng = max((py−ty)×k, 0)` with k=4 artillery / k=2 others, zeroed if <0.25, added to `radiusmax`+`detectradiusmax` (never to damage, never to dispersion, never subtracted uphill). The port `game.gd:6091-6094` (hd>0.6 → max×1.25, kinds-gated) is wrong on threshold, on operator (× vs +), on kinds (port gates kinds; donor gates melee-only exclusion), and on which radii grow — see §9 item 1.
4. **Flight has no donor script-side timer.** Flight emerges from engine `TXThrowBehaviour` (script sets Speed/Gravity/Direction/TargetPosition; `CalcSpeedByDirAndTrgPos` / `CalcDirByHSpeedAndTrgPos` / `SetupThrowBehaviourSpeed` are ENGINE calls — native boundary, §5). Port `dist/30` clamp, 0.45 s arrow, 512 cap are all PORT APPROXIMATION with no donor counterpart.
5. **`addradius` is a stationary-stance RANGE bonus, not accuracy.** `rbonus += addradius` when idle (`unit.script:8028`) `[O]` §3. Port transcribes `addradius_px` into `DONOR_MOUNT_ROWS` but never consumes it (P8 grep) — wiring is §11 item 3.

---

## 2. Dispersion — exact formula, units, RNG source `[O]`

Donor (`weapon.script:627-646`):

```
// _weapon_CalcShotDispertion
procedure _weapon_CalcShotDispertion(goHnd : Integer; disp, tx, ty, tz : Float; var dx, dy, dz : Float);
   var px := GetGameObjectPositionXByHandle(goHnd);
   var pz := GetGameObjectPositionZByHandle(goHnd);
   var dist := VectorDistance(px, 0, pz, tx, 0, tz);
   var maxdisp := dist*disp*gc_pixels_to_tile/2000;
   dx := tx+(1-RandomExt*2)*maxdisp;
   dz := tz+(1-RandomExt*2)*maxdisp;
   dy := ty;   // (commented RayCastHeight alternative left dead)
```

Call site (`unit.script:11520-11531` `_unit_DoProjectile`): `disp` = `gPlayer[pl].objbase[cid][id].weapon[weapind].dispertion` (the per-mount TILES value set by `_misc_PixelsToTiles(px)` at registration, e.g. archer 175 px → 3.28125 tiles).

- **Units:** `disp` is TILES, `dist` is TILES (engine positions), `gc_pixels_to_tile` = 53.3333333. Substituting the registration (`disp_tiles = dispertion_px/53.3333333`): **`maxdisp_tiles = dist_tiles × dispertion_px / 2000`**, and with TILE_M=2: **`maxdisp_m = dist_m × dispertion_px / 2000`**. The 53.3333333 cancels — the px literal can be used directly against metre distances `[D]`.
- **Distribution:** uniform square, NOT gaussian: each of dx, dz independently uniform in `[−maxdisp, +maxdisp]` via `(1−RandomExt*2)` — two `RandomExt` draws (sim stream) per scattered shot `[O]`. (`_misc_ProjSimulatePoint` Gaussian scatter §7 applies ONLY to `randomsimulate`-propagation child fragments, not to aimed fire.)
- **Worked examples** (exact, no invention): cannon `dispertion_px=225` (`unit.script:1708`) at `dist=20` tiles (40 m): `maxdisp = 20×225/2000 = 2.25` tiles = **4.5 m** per axis. Archer 175 px at 10 tiles (20 m): `10×175/2000 = 0.875` tiles = **1.75 m**. Tower 100 px at 15 tiles: 0.75 tiles = 1.5 m.
- **Gating:** `if (goHnd<>0) and (disp>0)` else pass-through (`:629-645`). Zero-dispersion mounts (muskets: no `dispertion` write → 0) scatter NOTHING — musket fire is exact to the aim point; their spread in-game comes only from `uniqrnd` range shortening (see §4), never from aim error `[D]`. Port `_dispersion_px` returning 0.0 for non-listed kinds accidentally matches this, but for the wrong reason and with wrong units for listed kinds (§9 item 2).
- **Same formula reused** for the friendly-fire pre-check (`unit.script:5300-5305` `_unit_CheckFriendlyFireExplosion`: `maxdisp := dist*disp*gc_pixels_to_tile/2000`, `dmgRad` 3.75 mortar else 1.25, scan `maxdisp+dmgRad`, needs `enemycount >= friendcount*4`) `[O]`. Port has no equivalent gate (fires regardless) — §11 item 5 `[U]`-side note.

---

## 3. `addradius_px` — exact meaning and unit conversion `[O]`

- **Storage:** `TObjWeaponStatic.addradius` (per-mount, TILES via `_misc_PixelsToTiles(32)` → 0.6 tiles for the universal 32 px infantry/arty value; `-1`/`default` = keep-prior, `unit.script:520-546`) `[O]`. Donor-absent mounts (cannon cannister idx1, yachttur, frigate overrides, towers) keep prior/0 — never back-filled `[D]`.
- **Consumption — the ONLY use** (`unit.script:8026-8031`): `if (bIdle) then rbonus := rbonus+TObjProp(pobjprop).weapon[i].addradius;` then `bDistanceFar := dist>(radiusmax+rbonus)` (`:8033`). I.e. a stationary (`bIdle` = `statetag and move_idle`) shooter gets +0.6 tiles effective max range. It is a RANGE term, not an accuracy term `[D]`.
- **Weakwall kicker** (`:8030-8031`): `if (TObjProp(pTrgObjProp).usage=gc_usage_weakwall) then rbonus := rbonus+0.36;` — +0.36 tiles vs weakwall targets `[O]`. Port has neither (§11 item 3).
- **Port conversion:** `addradius_m = addradius_px / 26.6666666` (32 px → 1.2 m) via existing `data.gd:22` `PX_TO_M` (already exact). `dispertion` port conversion for DIRECT use: keep px and apply §2 box formula (no pre-conversion needed); if tiles wanted: `/53.3333333`.

---

## 4. Height — the complete donor law: range bonus only, three call sites, never damage `[O]`

**Site A — attack order weapon choice** (`unit.script:7855-7873`): `bonusrng := MaxFloat((py−ty)*4, 0)` if `bArtillery` else `MaxFloat((py−ty)*2, 0)`; `if (bonusrng<0.25) then bonusrng := 0`; non-melee mounts get `rbonus := bonusrng`, and BOTH gates grow: `dist<=(detectradiusmax+rbonus)` and `dist<=(radiusmax+rbonus)` (`:7893-7906`). Melee (`radiusmax<=gc_unit_meleeattackradius=3.5`) gets `rbonus := 0` (`:7869-7872`).

**Site B — movement/approach check** (`unit.script:7547-7568`): `bonusrng := MaxFloat((py−dstHeight)*2, 0)` (no artillery split here), `radiusmax := radiusmax−gc_obj_maxattackradiusdisp×uniqrnd` (i.e. −3×uniqrnd) when `radiusmax>3.5 and standtime<0.25`; `bDistanceOk := (not bDistanceFar) and dist>=radiusmin`.

**Site C — point-attack weapon index** (`unit.script:6332-6356` `_unit_GetWeaponToAttackIndexByPoint`): `bonusrng := (py−dstHeight)*2` (raw, unclamped at this site), same melee exclusion, `dist<(radiusmax+rbonus)` gate.

- **Positions are engine Y** (`GetGameObjectAbsolutePositionByHandle` py/ty; `RayCastHeight`/`RayCastWater` for ground targets) in TILES `[O]`. Threshold 0.25 tiles = 0.5 m. Artillery k=4 → 1 tile of height ≈ +4 tiles range; others ×2.
- **Uphill is NEVER penalised** (`MaxFloat(...,0)`) and damage is NEVER touched: `_misc_DoDamage` (`:332-464`) and `_misc_DoRoundDamage` (`:562-604`) contain no py/ty/height reference (P9 negative grep) `[O]`.
- **`uniqrnd` range shortening** (the actual per-unit "accuracy" stat): non-artillery `radiusmax −= 3×uniqrnd`, artillery `−= 3×uniqrnd×0.5`, only when `standtime<0.25` and kind≠cannister (`:8017-8023`); movement check variant has no cannister/artillery carve-out (`:7565`) `[O]`. With `uniqrnd := RandomExt` uniform per unit (`:2726`), a fresh-moving musketeer loses up to 3 tiles (6 m) of max range — this, not aim scatter, is why muskets feel inaccurate on the move `[D]`.

---

## 5. Flight — script-side tables `[O]`; ballistic integration is the native boundary `[U]`

Script side (`weapon.script:855-986` `_weapon_InitProjectile`), all `[O]`:

- `speed` (tiles/s) = `_misc_PixelsToTiles(floor(gWeapons[id].speed*1000))*0.001*gc_time_to_frames`. Worked: `fly` physvalue 20 (PUSSTRELA family) → `floor(20000)=20000` → `20000/53.3333333=375` → `×0.001=0.375` → `×32 = 12.0` tiles/s = **24 m/s**; STRELA 25 → 15 tiles/s (30 m/s); NUCL2PTOW 38 → 22.8 tiles/s (45.6 m/s); POINT `random` 3 → 1.8 tiles/s `[D, arithmetic]`.
- `gravity` remap (`:877-890`): donor gravity-arg 0→2, 1→2.5, 2→3.75, 3→7 (`//5.625`), 4→9.25, 5→11.5; override: `fly`+gravity-arg-2 → **11.5** (arrows). `if gravity=0 then gravity := 2`. Units are engine-internal (fed to `TXThrowBehaviour` `Gravity`); no px/tile/s² gloss exists in script — do not invent one `[U]` (§10-U1).
- Propagation dispatch (`:945-965`): `angle` → `_weapon_ThrowByAngle` (direction rotated by `angle` degrees about the horizontal perpendicular, `:807-822`); `fly` → `_weapon_ThrowByHSpeed` (engine `CalcDirByHSpeedAndTrgPos`); `random/random1` → `_weapon_ThrowRandom` (3× `RandomExt` uniform sphere-ish kick, `:838-852`); `randomsimulate` → same random throw now, REAL damage later via simulate points (§7); `stand` → `py := RandomExt*0.125`, pitch `−(30+RandomExt*30)` (`:1135-1136,1156-1157`).
- `time`: `cInfinite(−1)` → `OnStopEvent='OnStopEvent'` (lands when ballistic ends); `time>0` (PUSSTRELA family, NUCLM) → ALSO `GameObjectDelayExecuteStateByHandle(projHnd,'OnStopEvent',time)` (`:984-985`) — timed airburst; `cPlayOnce(0)` → no behaviour at all, instant `DoExplode`+`FreeToPool` (`:988-1033`).
- `_weapon_PredictShot` (`weapon.script:795-803`) is a STUB: returns `True` iff a fly-child exists, else `False` (blocks the shot + 1 s penalty, `onaclanimationreachedattack.inc:97-109`) `[O]`. Port has no PredictShot gate — fires unconditionally (§11 item 5).
- `buseownerdamage` (arrow/firearrow/grenade vs buildings, `onaclanimationreachedattack.inc:101-103`): damage comes from the MOUNT (`objbase.weapon[weapind].damage`), else from the PROTOTYPE (`TWeapon.damage`) — `doexplode.inc:59-62` `[O]`. Port `base_dmg` always uses mount `w.dmg`; verify mount dmg values are donor (§11 item 4).

---

## 6. Hit application — no probability; round damage + locked-target damage `[O]`

`DoExplode` (`projectile.inc/doexplode.inc:78-89`): `if damage>0`: if `TWeapon(pweapon).radius>0` → `_misc_DoRoundDamage(px,pz,radius,damage,owner,trg,kind,False)`; if `bAllowTrgDamage and trgHnd<>0 and ownerHnd<>trgHnd` and target alive → `_misc_DoDamage(owner,trg,damage,weapind,kind)` — the locked target takes BOTH round and direct damage (double-dip is donor law) `[O]`. Buildings immune to non-`CheckWeaponTargetable` propagations (`:73`); dead-target custom-explosion routing `:148-210`.

`_misc_DoRoundDamage` (`miscext2.script:562-604`): scan radius `r` (+`cMaxExplMediaR=225/53.3333333=4.21875` tiles when `not bsimulation and not barrow`); victim cap `count = Floor(1+sqr(r/0.35))` (e.g. r=0.9375 → 8; r=1.875 → 29); non-buildings need `dist < r+explradius` (non-arrow) or `dist < r` (arrow, plus `listcount>300` overflow rule); each victim via `_misc_DoDamage`; wall splash is the separate engine-adjacent call `:240-256` (already `[U]`-U3, untouched here).

---

## 7. `round()` semantics + RNG draw ledger for the shot path `[O]` shape, `[U]`-G1 tail

- `round()` appears ONLY in the 14 PUSSTRELA `time` rows (`weapon.script:349-362`, EV-ROUND). Values: `round(3.25)=3`, `round(6.5)→6` bankers, `round(13)=13`, `round(8.125)=8`, `round(16.25)=16`, `round(24.375)=24`, `round(5.5)→6` bankers, `round(11)=11`, `round(16)=16`, `round(1)=1`, `round(2.5)→2` bankers, `round(5)=5`, `round(7.5)→8` bankers `[D, arithmetic; bankers assumption stays [U]-G1]`. Port `data.gd:1206-1214 donor_round` is already half-to-even — keep, keep the `[U]`-G1 tag until the X21 20-vector fixture proves binary behaviour (§10-G1).
- Shot-path draws, in order (`[O]` sites; stream attribution `random` vs `RandomExt` is verbatim, cross-PC semantics stay `[U]`-G1):
  1. `obj.uniqrnd := RandomExt` — ONCE per unit at creation (`unit.script:2726`). **Correction:** `game.gd:6547` claims "no static site recovered" — the site IS recovered (`:2726`, sim stream). §11 item 6.
  2. `_unit_TryAttack` friendly-fire gates: `SetRandomKey(floor(random*gc_MaxInt))` (general `random`, `:5301`) then `RandomExt` inside `_unit_CheckFriendlyFireCannister` (sibling fn, same pattern).
  3. `_unit_DoProjectile` (`:11528-11554`): `SetRandomKey(floor(random*gc_MaxInt))`; scatter 2× `RandomExt` (only if `disp>0`); `frnd := RandomExt` → `WriteProj` (replay sync). **Order matters: scatter draws precede the stored frnd.**
  4. `_weapon_CreateProjectileByWeaponID` (`:1046-1051`): `uniqrnd=0 → newuniqrnd := random` (general!), else keep; `SetRandomKey(floor(newuniqrnd*gc_MaxInt))`; shot-point pick `floor(RandomExt*count)`; `random1` orientation 6× `RandomExt`; `stand` pitch 1× `RandomExt`.
  5. `_weapon_InitProjectile` (`:936-939,1011`): `random1/random` rotspeed `RandomExt`; `ThrowRandom` 3× `RandomExt`; PlayOnce `volumeclippedfreq<random` uses GENERAL random explicitly "cause no need to sync it" (`:1011`).
  6. `DoExplode` (`doexplode.inc:12`): `SetRandomKey(floor(arg_proj.uniqrnd*gc_MaxInt))` — re-syncs to the projectile's stored stream before child rolls (`floor(RandomExt*(1+max-min))` counts, `floor(RandomExt*list)` picks).
  7. `randomsimulate` children → `_misc_ProjSimulatePoint` (`miscext2.script:641-728`): Box-Muller Gaussian (`RandomNormalDistribution`/`RandomGauss`/`RandomGaussExt`, σ=0.25/0.425) over a LOCAL LCG (`seed := 314159269*seed+453806245 mod 2147483647`) seeded `floor(RandomExt*100000)`; impact `dst = rnd×1.3` tiles rotated `RandomExt*360`; `damagetime = 0.275+…` (0.275–0.64 s window) resolved later in `_misc_ProjSimulatePointsProgress` via `_misc_DoRoundDamage(...,True)` `[O]`. Port has no simulate-point system — the `randomsimulate` POINTOTVZRIV path is unported (§11 item 7).

---

## 8. Port delta register (read-only; owner/COORD applies)

| # | Port site | Donor law | Delta |
|---|---|---|---|
| H1 | `game.gd:6091-6094` hd>0.6 → `w.max×1.25` | §4: `+max((py−ty)×k,0)` tiles (k=4 arty, 2 else), threshold 0.25 tiles, melee excluded, grows `radiusmax` AND `detectradiusmax` | Threshold/operator/kinds/targets all differ. Port `height_at` is metres; donor Y is tiles — convert before comparing. |
| H2 | `game.gd:6435-6439` ridge-block + `:6430-6434` wall-between | Donor: `FriendOnLine` engine ray test (`:7686-7690`, `py+0.5`→`dstHeight+0.5`); ridge logic is `bonusrng` range math, not a fire veto | Port vetoes have no donor cite; keep only with `[U]` tags (already tagged). |
| D1 | `game.gd:6376-6385` `_dispersion_px` + `:6458-6459,:6473-6474,:6483-6484` aim scatter | §2 box formula with DISTANCE scaling, no ×0.5/×0.4 factors | Port: constant px-based disp, halved, unscaled. CANNON 225/TOWER 100 consts exist (`data.gd:422-423`) but donor only grounds archer 175 + mount rows — CANNON/TOWER per-kind fallbacks are ungrounded. |
| F1 | `game.gd:6461,6476` `flight=clamp(dist/30,0.5,1.6)`, `:6487` arrow 0.45 s, `:6465-6466` 512 cap | §5: no script timer; speed/gravity tables; `time>0` airburst rows | All three numbers ungrounded. `dist` in port is metres; donor speed is tiles/s (§5). |
| S1 | `game.gd:6585-6604` generic 0.5× splash to rim | §6: `r+explradius`/arrow rules, `Floor(1+sqr(r/0.35))` victim cap, owner excluded, double-dip locked target | Port: no cap, no owner exclusion (`u.id<>t.id` skips only the locked target… actually skips `t.id`; owner CAN be splashed — donor also splashes owner via round damage when in radius (owner excluded ONLY as `dmgHnd=owner` in the loop `:583`). Roughly compatible; cap + arrow rule missing. |
| W1 | `data.gd:1256+` DONOR_MOUNT_ROWS, `:1233+` DONOR_SHIELD_ROWS, `:1206` donor_round | Transcribed verbatim `[O]` | ZERO consumers in `game.gd` (P8 grep). Wiring is §11. |
| R1 | `game.gd:6547,7317,7431-7433,7616-7619` uniqrnd comments | `unit.script:2726` spawn site recovered | Comments stale — fix per §11 item 6 (comment-only change). |

---

## 9. Still-`[U]` register — each with a fixed-camera shot-series capture and zero-mismatch termination

General harness (all items): fixed camera (frozen `camera3d`, no shake — `game.gd` shake would move pixels, not sim; sim assertions read `projectiles[].target` / `entities[].hp`, never pixels). Flat test map (all `height==h0`), two entities (shooter S, target T), seeded `rng` re-seeded per series. **Termination criterion (all): run the series; ANY single mismatch vs the stated donor expectation keeps the item `[U]` and forbids wiring; zero mismatches across the FULL series closes it.** Never fit/invent a dispersion curve — the §2 formula is the only admissible shape.

| # | Item | Static state after this ticket | Exact capture (owner-authorised) |
|---|---|---|---|
| U1 | Engine ballistic (`TXThrowBehaviour` gravity/speed units, flight path, landing point) | Script inputs `[O]` §5; integration `[U]` (packed exe, no new native addr this ticket) | Series F1: flat map, cannon S vs ground aim T at 10/20/30/40 m, 50 shots each (200). Record per-shot `total` flight + landing `target` vs donor `speed=12 tiles/s, gravity=11.5-fly…` table expectation is ENGINE-side → expectation is only "lands within `radiusmax` scatter box §2". Mismatch (landing outside box, NaN flight) → stays `[U]`. |
| U2 | Impact victim pick (donor engine collision priority 10000 vs port `1.2+block_r` nearest-in-8 m, `game.gd:6623-6634`) | Donor `OnCollide` trg-switch law `[O]` §5/`doexplode.inc:31-54`; radius `[U]` | Series F2: two targets 1.5 m apart crosswise/downrange at mid dispersion box, 100 shots each geometry (300). Expectation: victim distribution statistically consistent with §2 uniform-box × donor `r+explradius` rule; zero systematic bias (e.g. always-nearest) over 300 → close, else `[U]`. |
| U3 | Height-threshold metrology (port `height_at` metres vs donor tile-Y) | Donor law `[O]` §4; port height scale `[U]` | Series F3: shooter/target height differentials 0.0–3.0 m in 0.25 m steps (13), 20 shots each (260) at fixed 25 m ground dist with a mount whose base `radiusmax` ends exactly at 25 m. Expectation: fire permitted iff `Δh_tiles×k ≥ shortfall` (k=2/4). Zero mismatches → threshold+units proven; any → `[U]`. |
| U4 | Friendly-fire gates (`FriendOnLine` ray, cannister `CheckFriendlyFireCannister`, explosion 4:1 rule) | Donor formulas `[O]` §2/§5; port vetoes ungrounded (H2) | Series F4: ally lane-blocked / 3-ally-1-foe / 1-ally-5-foe geometries × musket/cannister/cannon (9 cells), 30 shots each (270). Expectation: donor allow/veto per cell. Zero mismatches → port may implement the gate; any → gate stays out. |
| U5 | `PredictShot` stub (donor `False` when no fly-child → 1 s penalty) | Stub law `[O]` §5; port always fires | Series F5: `stand`-propagation mount (e.g. STRELDEZ-profile) ordered to fire, 50 attempts. Expectation: NO projectile, 1 s-equivalent `attackdelay` penalty each time. Port currently fires → KNOWN mismatch; item stays `[U]` until §11 item 5 wired + series re-run green. |
| U6 | `randomsimulate` fratricide/simulate points (`POINTOTVZRIV`, `POINTOTVZRIVFRAME`) | Gaussian law `[O]` §7; port has no simulate system | Series F6: NUCLMOSKOL-profile impact, recordestroy 200 child impact points + damage times. Expectation: Box-Muller σ=0.425 clamp pattern, dst≤1.3 tiles, damagetime ∈ [0.275,0.64] s. Zero shape/parameter mismatch (KS-test p>0.01 AND bound violations=0) → wireable; else `[U]`. |
| U7 | `round()` bankers on binary (`[U]`-G1 tail) | Literals verbatim `[O]`; `donor_round` half-to-even, tagged | X21 20-vector fixture per DEC_U_skirmish_tables §9-G1: assert `round(6.5)=6, round(5.5)=6, round(2.5)=2, round(7.5)=8` through the port `donor_round` against pinned-binary behaviour. Any deviation → single-site override table, never `floor(x+0.5)`. |
| U8 | `random` vs `RandomExt` stream attribution per §7 draw site (`[U]`-G1 tail) | Draw ORDER `[O]` §7; cross-PC stream semantics `[U]` | Per-site draw-count test: fixed-seed headless run, count sim-stream draws per shot for musket (0 scatter draws), archer (2), cannon (2 + WriteProj frnd). Expectation: exact counts 1(uniqrnd, spawn-only)/0/2/3. Any extra draw → `[U]`. |
| U9 | Timed airburst (`time>0` rows: PUSSTRELA family, NUCLM `FramesToTime(2)=0.0625 s`) | Rows `[O]` §1.1-cite; port `total` timer ungrounded (F1) | Series F9: PUSSTRELA-profile vs target beyond ballistic reach, 50 shots. Expectation: airburst at `donor_round`-exact `time` with full round+target damage at burst point. Zero mismatches → wireable. |

---

## 10. Concrete port change list (owner/COORD applies; this worker wrote no code)

All items add DONOR-VERBATIM values or explicitly labelled placeholders. None invents a number. None touches save version keys, demo/mill/builder hooks, or I11 seam paths.

1. **`game.gd:6091-6094` height bonus — replace with §4 law.** Delete `hd>0.6 → max×1.25`. Implement: `bonusrng = maxf((py−ty)*k, 0.0)` with k=4.0 if `e.def.artillery` else 2.0 (shooter/target Y in TILES = `height_at()/2.0`); `if bonusrng<0.25: bonusrng=0.0`; add to BOTH range check and weapon-choice `max` (melee mounts, `max<=3.5` tiles, excluded); cannister excluded from the `uniqrnd` shortening only. Cite `unit.script:7855-7873,8026-8035`.
2. **`game.gd:6376-6491` dispersion — replace with §2 box.** Delete `_dispersion_px` constant fallback + `*0.5`/`*0.4` factors. Implement per shot: `maxdisp_m = dist_m * dispertion_px_mount / 2000` with the MOUNT's `dispertion_px` from `DONOR_MOUNT_ROWS` (fallback: archer-family 175/100/150/200 per `unit.script:1001-1047` only; musket mounts 0 = no scatter); `aim = t.pos + Vector2(rng.randf_range(-maxdisp_m,maxdisp_m), rng.randf_range(-maxdisp_m,maxdisp_m))`; draws from the SIM stream in this order (scatter, scatter, then stored frnd). CANNON 225 / TOWER 100 `data.gd:422-423` stay until cited per-mount (cannon idx0 225 `[O]` `:1708` — wire that one; tower 100 `:2232` / rus 125 `:2244` — wire both with nation scope).
3. **Wire `addradius` + weakwall kicker.** When shooter idle (`moving==false` and `standtime` equivalent): `rbonus_m += addradius_px/26.6666666` (32 px → 1.2 m); target weakwall (`sid gat/wal` weak usage): `+= 0.36 tiles (0.72 m)`. Cite `unit.script:8026-8031`. `DONOR_MOUNT_ROWS` `-1` = keep-prior/0.
4. **Verify mount `dmg` values before trusting `base_dmg`.** `buseownerdamage` mounts (arrow/firearrow vs buildings, grenades) take mount damage (`doexplode.inc:59-62`); port already uses mount `w.dmg` — audit each `UNITS_BASE weapons[]` dmg/pause/cd against `DONOR_MOUNT_ROWS` tuples (`unit.script:1696-2310`); stone `swa/sga`, weakwall, `ferry` stay EMPTY (donor-absent zero `[D]`).
5. **Add `PredictShot` gate + friendly-fire gates OR keep `[U]` tags.** Minimum: `stand`-propagation mounts refuse projectile fire with 1 s `cooldown` (`weapon.script:795-803`, `onaclanimationreachedattack.inc:97-109`); cannister/explosion friendly-fire vetoes per `:5300-5332` + sibling + `:8263-8281`. Until wired, F4/F5 series stay red by construction — document as known `[U]`, do not tune thresholds to pass.
6. **Fix stale `uniqrnd` comments (comment-only).** `game.gd:6547,7431-7433` "no static site recovered" → cite `unit.script:2726 obj.uniqrnd := RandomExt` (sim-stream draw at spawn). When the spawner is touched next: draw one sim-stream float per created unit into `uniqrnd` (default 0.0 keeps old saves deterministic; see save note below).
7. **Simulate-point system for `randomsimulate` children (or explicit non-support).** Either implement `_misc_ProjSimulatePoint` verbatim (`miscext2.script:641-728`: local LCG Box-Muller, `dst≤1.3` tiles, `damagetime` window, 2048-slot ring `gProjSimulatePoints`, progress in `_misc_ProjSimulatePointsProgress`) or tag `POINTOTVZRIV/FRAME` mounts PORT-UNSUPPORTED with F6 red. Do not fake with uniform scatter.
8. **Flight numbers: tag, don't tune.** `dist/30` clamp, 0.45 s arrow, 512 cap stay PORT APPROXIMATION with `[U1]` refs; when touched, derive `total` from §5 speed table (e.g. 12 tiles/s PUSSTRELA) over ground distance — and note the engine ballistic (not linear) caveat. Never invent gravity units.
9. **Save contract (additive only).** Projectiles already carry kinematics (`game.gd:7476+`); ADD `uniqrnd` per projectile (TProj field, `classes.script:4366`) when §11-item-6 lands; missing key defaults 0.0 (deterministic; no draw on load). No version bump, no key rename.
10. **RNG routing.** Route §7 shot-path draws (scatter ×2, shot-point pick, rotspeed, ThrowRandom ×3, child count/pick) through the single `floor(RandomExt*n)` sim wrapper; keep GENERAL-`random` draws (PlayOnce `volumeclippedfreq`, `uniqrnd=0→random` fallback, decal angles) on the NON-sim stream. Cite per line.
11. **Telemetry/format.** Every value above carries `unit.script:<line>` / `weapon.script:<line>` / `dmscript.global:<line>` cite in comment; every remaining estimate keeps PORT APPROXIMATION + `[U]` tag with its §9 series. `visual_parity_claim=false`; unresolved = [U1–U9 above + G1-tail, A1-tail, R1, V1/V2/F1/E1, O1-tail per DEC_U_skirmish_tables §9].

---

## 11. Explicit non-claims and file discipline

- NO PARITY CLAIM. No donor binary executed, no donor GPU frame captured, no port capture compared. Closed items (dispersion formula, height range law, flight script tables, damage chain, draw ledger shape) rest on donor TEXT `[O]` with file:line; open items (engine ballistic, collision radius, stream cross-PC semantics, bankers proof) list exact captures in §9.
- No native addresses are claimed by this ticket: theEXE-side `TXThrowBehaviour` (`CalcSpeedByDirAndTrgPos`, `CalcDirByHSpeedAndTrgPos`, `SetupThrowBehaviourSpeed`) has no script source and the packed-exe prior (craft.json `ev_31960c6f/ev_60b49743`) was reused, not re-run. The native projectile update stays `[U]`-U1 by stated boundary, not by omission.
- No approximation substituted for a resolved law. The three port inventions found (×1.25 height, `dist/30` flight, halved constant scatter) are named with replacements, not smoothed over.
- The `game.gd:6547` "no uniqrnd spawn site" comment is corrected (§7.1/§10.6), not smoothed over: the site is `unit.script:2726`.
- Read-only compliance: exactly one repo file written (this report). Donor reads were pinned text reads against `t_87f0f3c130b0` (+ one read-only `Get-FileHash`); no target opened/selected/closed by this worker; no code/asset/config/Godot/git edit.

*End of DEC-U-DAMAGE-HEIGHT.*
