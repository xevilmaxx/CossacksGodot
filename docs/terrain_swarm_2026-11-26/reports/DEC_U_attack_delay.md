---
id: DEC-U-ATTACK-DELAY
worker: DEC-U-ATTACK-DELAY (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied. Donor text scripts/data read as text only. No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. No multiplayer/netcode specified, audited, or changed."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed. No port capture compared."
context: "DEC_U_ff_predict.md PredictShot denial MaxFloat(attackdelay,1)+attackmaxdelay (onaclanimationreachedattack.inc:107-108,135-136); DEC_U_weapon_tail.md mount pause/time rows; port game.gd still carries labelled attack cooldown approximations."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
---

# DEC-U-ATTACK-DELAY — exact attack timing law: pause sources, FramesToTime, reuse gating, 1 s literal (2026-11-26)

## 0. Pass ledger (every pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `Get-FileHash C:\Games\Cossacks 3\cossacks.exe` (read-only hash, not execution): SHA256 `87F0F3C1…4E16c`, 5,768,048 B — matches pin. Binary never executed/copied/debugged. Native function addresses: NOT re-derived; packed-exe prior (`ev_31960c6f` family per DEC_U_damage_height §0) reused, not re-run. Script `file:line` below IS the address (donor logic lives in shipped text). |
| P2 | `onaclanimationreachedattack.inc:1-155` full re-read (EV-DLY-GATE) | Entry gate `(attackdelay=0)` (`:9`), `ApplyWeaponCost`+`ApplyAttackPause` order (`:26,:28`), weaponid-0 / immediate / PredictShot-allow / PredictShot-deny `MaxFloat(…,1)×2` ×3 sites (`:36-54,:58-88,:91-110,:117-147`) transcribed §3–§4 `[O]`. |
| P3 | `onaclanimationreachedattackend.inc:1-18` (EV-DLY-END) | No delay write; only `TryAttack(…,True)` re-arm (`:10,:12`). No cooldown invented here `[O]`. |
| P4 | `unit.script:10750-10794` + `:520-546` + `:2690-2731` (EV-DLY-PAUSE) | `_unit_ApplyAttackPause` overwrite law, `SetObjBaseWeapon` `pause→FramesToTime` setter, spawn `attackdelay/maxdelay:=0`, `individual.attackrate:=1` default transcribed §1–§2 `[O]`. |
| P5 | `unit.script:7640-7760,8160-8360,8500-8582` + `unit.inc/ontagstates.inc:720-830` + `building.inc/ontagstates.inc:360-460` (EV-DLY-REUSE) | Five reuse gates (`bAttackPauseOk := attackdelay=0`), resource-gold `100*gc_frames_to_time` / coal-iron `64*gc_frames_to_time` penalties, PredictShot/FriendOnLine veto `MaxFloat(…,1)×2`, shot-point `MaxFloat(…,1)` vs `:=0` split transcribed §3 `[O]`. |
| P6 | `unit.inc/nothing.inc:87-92` + `unit.inc/nothing.inc:260-460` + `building.inc/nothing.inc:28-29,330-331` + `movie.script:762-778` (EV-DLY-TICK) | Per-tick `attackdelay -= deltatime` floor 0 (units) vs `_misc_MaxFloat(-deltatime,0)` (buildings), movie-test `:=0` reset transcribed §3 `[O]`. |
| P7 | `dmscript.global:170-175,737-763,1707-1761` + `misc.script:460-482` (EV-DLY-CONST) | `gc_frames_to_time=0.03125`, `gc_time_to_frames=32`, field types `attackdelay/maxdelay: Float`, `attackrate: Float`, upgrade kinds `attpauseperc=15 / single_attpauseperc=26` re-cited §2 `[O]`. |
| P8 | `player.script:1850-1858,1965-1973` + `country.script:3664,3697,3903-3913` (EV-DLY-UPG) | Global `pause *= (1+value/100)` by kind; per-unit `attackrate += value/100` (`individual`) transcribed §1 `[O]`. |
| P9 | `miscext.script:1020-1040` + `unit.script:8181-8223` + `unit.script:2703-2704` (EV-DLY-RES) | Capture-block `100*gc_frames_to_time=3.125 s`, gold-off `100*gc_frames_to_time`, poor-shot `64*gc_frames_to_time=2.0 s` transcribed §3–§4 `[O]`. |
| P10 | Mount `pause` frame sweep (EV-DLY-MOUNT) | `Select-String SetObjBaseWeapon` over `unit.script`: melee `0`, muskets `100-220`, archers `75/80/85/100/125`, dragoon families `140-190`, cannon `350/300{1200}`, multicannon `60`, tower `400/300`, ships `20-400` — sample transcribed §1 `[O]`; FULL per-sid table NOT re-transcribed here (deferred to DEC_U_weapon_tail §3 which owns it) — this ticket cites, never duplicates/invents. |
| P11 | Port read-only inspection (EV-DLY-PORT) | `app/scripts/game.gd:1994,4052-4060,4512-4513,4739-4741,4900-4928,5347-5349` + `app/scripts/data.gd:21-23,60,92-95,580-972,1415-1425` inspected; `cooldown` approximations + invented constants listed §6 `[O]`. No port file edited. |

DSL note `[D]` (inherited): donor `not X` on a numeric lvalue is the current-value read. Donor `{...}` is comment syntax: live value is the uncommented head (e.g. `350{1200}` = 350, `75{295;160}` = 75).

---

## 1. `attackdelay` / `attackmaxdelay` sources per weapon/mount [O]

### 1.1 Field identity and spawn law

- `dmscript.global:1737-1738`: `TObj.attackdelay = Float`, `attackmaxdelay = Float` — both plain seconds floats, per-entity (not per-mount) `[O]` (EV-DLY-CONST).
- `unit.script:2703-2704` (`_unit_ResetObj`-family init): `obj.attackdelay := 0; obj.attackmaxdelay := 0;` at spawn `[O]` (EV-DLY-PAUSE).
- `individual.attackrate := 1; individual.benabled := False;` (`unit.script:2727-2729`) — the per-unit pause multiplier defaults to identity `[O]`.
- `unit.inc/initial.inc:263-264`: on spawn, `if bshowdelay then attackmaxdelay := 1;` — UI-only prefill of the MAX bar (delay itself stays 0) `[O]`. `bshowdelay` decl `classes.script:3637` `[O]`. This `1` is a DISPLAY seed, not a cooldown — see §4 for why it still matters as scale evidence.

### 1.2 The ONLY normal writer: `_unit_ApplyAttackPause` (overwrite, not max)

`unit.script:10750-10789` verbatim shape `[O]` (EV-DLY-PAUSE):

```
procedure _unit_ApplyAttackPause(const goHnd, weapind : Integer);
  var attpause : Float = TObjBase(pobjbase).weapon[weapind].pause;   // :10758 per-MOUNT seconds
  bNeedPause := (attpause>0);                                        // :10759
  if (TObj(pobj).individual.benabled) and (attpause>0) then          // :10760
  attpause := attpause*TObj(pobj).individual.attackrate;             // :10761 per-unit upgrade scaling
  {…commented-out animation-frame trim :10763-10780, LIVE = no-op…}  // [D]: all inside {...}
  if (not bNeedPause) then attpause := 0;                            // :10786 zero-pause mounts stay 0
  TObj(pobj).attackdelay := attpause;                                // :10788 OVERWRITE
  TObj(pobj).attackmaxdelay := attpause;                             // :10789 OVERWRITE
```

Consequences `[D]`:

- Firing mount `i` sets BOTH fields to that mount's `pause` (seconds), discarding any prior residual. It is `:=`, never `MaxFloat` — unlike every penalty path (§3).
- `pause = 0` mounts (all melee pike/sword rows, e.g. `unit.script:632,695,714,1064-1102,1193,1228,1324`) write `0/0`: melee has NO reuse delay from this path; its only gating is the animation event re-fire + the `=0` checks below.
- The commented animation trim (`:10763-10780`) and commented `bshowdelay→attackmaxdelay:=1` (`:10791-10792`) are dead text — live law ignores animation length `[O]`.
- `TObjBase…weapon[i].pause` vs `TObjProp…weapon[i]` split: `pause`/`damageinit`/`radiusmax` live in BASE (per-player upgraded copy), `kind`/`radiusmin`/`detect*`/`cost` in PROP (shared) — hence `player.script` upgrades mutate `gPlayer…objbase…weapon[j].pause` (`:1857`) while costs mutate PROP `[O]`.

### 1.3 Where `pause` (seconds) comes from: `SetObjBaseWeapon` + `FramesToTime`

`unit.script:520-546` `[O]` (EV-DLY-PAUSE):

```
if (pause<>-1) then objbase.weapon[index].pause := _misc_FramesToTime(pause);
```

- `pause` arg is INTEGER FRAMES; `-1` (`default`, `unit.script:593`) = keep-prior `[O]`.
- `_misc_FramesToTime(val) = val * gc_frames_to_time` (`misc.script:470-474`), `gc_frames_to_time = 0.03125` (`dmscript.global:174`) `[O]` (EV-DLY-CONST). So `pause_s = frames × 0.03125 = frames / 32`.
- Worked donor examples (all `[O]` frames → `[D]` arithmetic, never invented):
  - musket line `unit.script:774`: `12 dmg, pause 150` → `150×0.03125 = 4.6875 s`.
  - musket `unit.script:807`: `pause 150` → 4.6875 s; `unit.script:816`: `190` → 5.9375 s; `unit.script:889`: `220` → 6.875 s.
  - archer `unit.script:999`: `75` → 2.34375 s; `unit.script:1044`: `80{60}` → live `80` → 2.5 s; `unit.script:1023/1031`: `85/100` → 2.65625 / 3.125 s.
  - officer-bow `unit.script:1005`: `125` → 3.90625 s; firearrow `unit.script:1046`: `25` → 0.78125 s.
  - cannon `unit.script:1696-1731` (per DEC_U_weapon_tail §3): mount-0 `pause 350` → **10.9375 s**; mount-1 `pause 350{1200}` → live **350** → 10.9375 s.
  - multicannon `:1800`: `60` → **1.875 s**; howitzer `:1739`: `600{1250}` → live **600** → 18.75 s; mortar `:1771`: `250` → 7.8125 s; framegun `:1830`: `90` → 2.8125 s.
  - yacht base `:1881`: `350` → 10.9375 s; yachttur override `:1909`: `400` → 12.5 s; galley `:1930`: `150` → 4.6875 s; frigate base `:1966`: `75` → 2.34375 s; tower `:2227`: `400` → 12.5 s, `commonrus` override `:2246`: `300` → 9.375 s.
- Upgrade scaling `[O]` (EV-DLY-UPG):
  - global `gc_upg_type_attpauseperc` (`player.script:1850-1858`): `objbase…weapon[j].pause *= (1+value/100)` for ALL mounts of matching `kind` (e.g. `country.script:3664,3697` `aca.31/33` value `-30` → `×0.70` on `bullet`).
  - single `gc_upg_type_single_attpauseperc` (`player.script:1965-1973`): `individual.attackrate += value/100` (additive on the rate, e.g. tower `country.script:3903-3913` `-20/-10` steps), then applied at `:10761` as `pause × attackrate`.
- Port `data.gd:1422-1425` already records the `-30 → 0.70` reading correctly (`rof_mult bullet 0.7`, cite `player.script:1857`) — that row is GROUNDED, not [U] (§6).

### 1.4 Penalty writers (all `MaxFloat`, never overwrite)

Every non-fire writer sets BOTH fields with `MaxFloat(current, X)` — a floor, preserving a longer live cooldown `[O]`:

| Site | Literal X | Both fields? |
|---|---|---|
| PredictShot deny attackobj `onaclanimationreachedattack.inc:107-108` | `1` | yes |
| PredictShot deny attackpoint `:135-136` | `1` | yes |
| Fallthrough neither-obj-nor-point `:145-146` | `1` | yes |
| Friendly-fire veto `unit.script:8280-8281` | `1` | yes |
| TryAttackPoint ray veto `unit.script:7701-7702` | `1` | yes |
| `ontagstates.inc` (unit) `:760-761,:778-779,:806-807,:818-819,:827-828` | `1` | yes |
| `ontagstates.inc` (building) `:404-405,:440-441,:457-458` | `1` | yes |
| Building shot-point-blocked `:411-412,:447-448` | `0` (CLEAR, not penalty) | yes — the ONLY `:=0` penalty-site write `[O]` |
| Gold-upkeep off `unit.script:8187-8188` | `100*gc_frames_to_time` = 3.125 s | yes |
| Poor-shot (no iron/coal) `unit.script:8208-8209` | `64*gc_frames_to_time` = 2.0 s | yes |
| Capture-block `miscext.script:1038-1039` | `100*gc_frames_to_time` = 3.125 s | yes |

Full per-weapon `pause` ledger itself is OWNED by DEC_U_weapon_tail §3 — this ticket does not duplicate it; the frames→seconds rule above + the cited lines ARE the complete derivation law, no per-mount number is invented here.

---

## 2. `FramesToTime` / time conversions [O]

- `gc_frames_to_time = 0.03125`, `gc_time_to_frames = 32` (`dmscript.global:174-175`) `[O]`.
- `_misc_FramesToTime(v) = v × gc_frames_to_time` (`misc.script:470-474`); `_misc_PixelsToTiles(v) = v / 53.3333333` (`misc.script:462-466`); `_misc_BuildtimeToTime(v) = v × gc_frames_to_time × 10` (`misc.script:480-482`) — buildtime only, NEVER used for pause `[O]`.
- `pause_s = pause_frames × 0.03125` at SET time (`unit.script:539`), stored as Float seconds in `TObjBase.weapon[i].pause`, then copied verbatim to both delay fields at fire time (`:10788-10789`) `[O]`.
- Penalty literals reuse the SAME scale: sibling penalties write `100*gc_frames_to_time` (= 3.125 s) and `64*gc_frames_to_time` (= 2.0 s) directly in seconds (`unit.script:8188,8209`, `miscext.script:1038`) `[O]` — this grounds the §4 derivation that bare `1` is 1.0 s on the identical scale.
- Tick decay is in seconds: `attackdelay -= deltatime` per `Nothing` tick (`unit.inc/nothing.inc:89`, `building.inc/nothing.inc:29` via `_misc_MaxFloat`) `[O]`; `deltatime = GetGameTime - lastprogresstime` (seconds, `building.inc/nothing.inc:27`) `[D]`.
- No other time base touches `attackdelay`: projectile `time` (`weapon.script` `FramesToTime(round(…))` rows), `gc_squad_holdmode_time = 150*8*gc_frames_to_time` (`dmscript.global:180`), `gc_buildtime_progressperhit` are disjoint systems — never substitute them for pause `[O]`.

---

## 3. Reuse / cooldown gating law [O]

### 3.1 Gate shape (all must hold before a shot)

1. **Delay gate**: `(arg_obj.attackdelay = 0)` — entry condition at `onaclanimationreachedattack.inc:9` (animation event), `unit.inc/ontagstates.inc:732`, `building.inc/ontagstates.inc:369`, `unit.script:8181` (melee-OR variant: `melee or attackdelay=0` — melee mounts bypass the delay check at TryAttack stage `[O]`), `unit.script:7652,8519` `[O]`.
2. **Order gate**: `orders[0].itype ∈ {attackobj, attackpoint}` (`inc:9`) `[O]`.
3. **Process gate**: `(not bProcess) or (…)` (`inc:9`) with `bProcess := not (_net_IsClient or _net_IsReplay)` (`inc:8`) — clients/replays SKIP the whole block (no cost, no pause, no projectile) `[O]`.
4. **Statetag gate**: `(statetag & action_attack)<>0` (`inc:13`) + weapon-slot decode `weapon_none/0/1/2 → weapind 0/0/1/2` (`inc:16-21`) `[O]`.
5. **Resource gate**: `_unit_EnoughResForShot` at `ontagstates.inc:732`, `unit.script:7654,8205,8524` — on failure writes the 2.0 s / 1-literal penalties instead of firing (see 1.4) `[O]`.
6. **Geometry gates**: `PredictShot` + `FriendOnLine` + kind vetoes + building shot-points (DEC_U_ff_predict §§1-2,5) — on deny write `MaxFloat(…,1)×2`, no projectile, order kept (units) or dropped (veto path) `[O]`.

### 3.2 Fire path writes pause FIRST, then shoots (units)

`onaclanimationreachedattack.inc:26-28` `[O]`:

```
_unit_ApplyWeaponCost(myHnd, weapInd);    // :26 — deduct iron/coal first
_unit_ApplyAttackPause(myHnd, weapind);   // :28 — overwrite delay/maxdelay with mount pause
```

— so even a PredictShot-denied shot has ALREADY paid cost and installed the full mount pause before `:107-108` floors the residual with `MaxFloat(…,1)` (no-op unless pause < 1 s, e.g. firearrow 0.78 s or melee 0) `[D]`. Contrast `ontagstates.inc:740-742,766-767,812-813` (unit) and `building.inc/ontagstates.inc:391,433` where pause+cost apply only on the ALLOWED branch AFTER both `PredictShot` and ray/shot-point checks — order differs by entry state; both orders are verbatim, do not unify them `[O]`.

### 3.3 Decay and reset

- Units: `if (attackdelay>0) then attackdelay -= deltatime; if (<0) then :=0` (`unit.inc/nothing.inc:87-92`) `[O]`. Note `attackmaxdelay` is NOT decayed here — it is the sticky UI/max tracker; only `attackdelay` gates reuse `[D]` (maxdelay has no `=0` gate anywhere — negative grep: zero `attackmaxdelay=0` gates in the corpus `[O]` P10-adjacent).
- Buildings: `attackdelay := _misc_MaxFloat(attackdelay-deltatime, 0)` (`building.inc/nothing.inc:28-29,330-331`) — same law, float-safe form `[O]`.
- Movie/test reset: `_movie_UnitResetAttackDelay := attackdelay := 0` (`movie.script:762-767`; squad/list variants `:768-778`) — leaves `attackmaxdelay` untouched `[O]`. Scenario/cutscene use only.
- `initial.inc:264` display seed (`attackmaxdelay := 1` iff `bshowdelay`) is set ONCE at creation and never gates anything `[O]`.

---

## 4. The 1 s literal derivation (closed: literal `1`, gloss `1.0 s`) [O]+[D]

- The deny/veto literal is the bare source token **`1`** in all 13 sites (§1.4): `MaxFloat(arg_obj.attackdelay, 1)` / `MaxFloat(arg_obj.attackmaxdelay, 1)` (`onaclanimationreachedattack.inc:107-108,135-136,145-146`; `unit.script:7701-7702,8280-8281,8536-8537`; `ontagstates.inc` ×5; `building ontagstates` ×3) `[O]`.
- Type/scale: `attackdelay/maxdelay` are `Float` seconds fields (`dmscript.global:1737-1738`); the ONLY sibling writers on the same fields in the same functions use explicit seconds expressions `100*gc_frames_to_time` (= 3.125 s, `unit.script:8188`, `miscext.script:1038`) and `64*gc_frames_to_time` (= 2.0 s, `unit.script:8209`) `[O]`. The bare `1` therefore sits on the seconds scale: gloss **`1.0 s`**, derivation `1 × 1 s` `[D]` (same derivation as DEC_U_ff_predict P11).
- Corroboration (not the derivation, but consistency): spawn display seed `attackmaxdelay := 1` for `bshowdelay` units (`initial.inc:264`) and the dead UI comment `attackmaxdelay := 1` (`unit.script:10792`) both use `1` as a one-second-scale bar value `[O]`.
- Invention ban honored: every §6 patch below wires the VERBATIM token `1` (`1.0` in GDScript float) with its `file:line` cite; the word "second" appears only as the derived unit gloss, never as a new number. No delay or cooldown is invented: where the mount `pause` is not yet transcribed for a sid, the item stays `[U]` with its §5 series.

---

## 5. Still-[U] register — fixed-camera shot-series captures, zero-mismatch termination

Harness (all series): fixed camera (`camera3d` frozen, no shake — assertions read sim state `entities[].cooldown` / `projectiles[]` / `hp`, never pixels). Flat map (`height==h0`), two actors (shooter S, target T) unless noted. Seeded `rng` re-seeded per series. **Termination: run the FULL series; ANY single mismatch vs the stated donor expectation keeps the item `[U]` and forbids wiring; zero mismatches across the full series closes it.** Never fit a curve; never invent a literal.

| # | Item | Static state after this ticket | Exact capture (owner-authorised) |
|---|---|---|---|
| U-D1 | Mount `pause` per sid (reuse interval) | Law closed §§1-2 `[O]`; ~10 sample frames verified P10; FULL sid table owned by DEC_U_weapon_tail §3 — port `data.gd` `cd` values partly estimated | Series D1-PAUSE: per sid under test, order 1 attack vs practice target, record `cooldown` on the firing tick (= mount `pause_s` per §1.3) then tick `dt=1/32` and assert `cooldown -= dt` each tick until 0. 30 shots/sid. Expectation: `cooldown_0 == pause_frames×0.03125` exactly; any delta → `[U]`. |
| U-D2 | Melee zero-pause reuse | `pause=0` melee rows `[O]` §1.2; donor melee still gated by animation event `inc:9` + TryAttack `melee or delay=0` (`unit.script:8181`) | Series D2-MELEE: pikeman vs adjacent target, 50 swings. Expectation: `cooldown` stays `0.0` after every swing (`ApplyAttackPause` writes 0), next swing fires on the next attack animation event without waiting. Any `cooldown>0` → `[U]`. |
| U-D3 | `individual.attackrate` scaling | `pause×attackrate` law + `+=value/100` upgrade law `[O]` §1.3; per-sid trigger values open | Series D3-RATE: tower with `single_attpauseperc -20` applied twice, 30 shots. Expectation: `cooldown_0 == base_pause×(1-0.20-0.20)` (additive rates per `player.script:1971`). Any multiplicative reading → `[U]`. |
| U-D4 | Global `attpauseperc` (-30% → ×0.70) | Formula `[O]` §1.3; port `rof_mult 0.7` grounded but live wiring unverified | Series D4-ROF: musket line with `aca.31`, 30 shots. Expectation: `cooldown_0 == base×0.70`. Any other factor → `[U]`. |
| U-D5 | Gold-upkeep 3.125 s / poor-shot 2.0 s penalties | Literals `100*f2t` / `64*f2t` `[O]` §1.4; port `_GOLD_FIRE_STOP_S = 100/32` grounded but `can_pay→1.0` mapping is PORT APPROXIMATION | Series D5-RES: (a) gold<4 upkeep unit ordered to fire, 20 attempts — expectation `cooldown==3.125`, no cost deducted, no projectile; (b) 0-coal cannon ordered to fire, 20 attempts — expectation `cooldown==2.0`. Port currently writes `1.0` for (b) (`game.gd:4900`) → known mismatch; stays `[U]` until §6-item-2. |
| U-D6 | PredictShot-deny 1.0 s floor on top of mount pause | Order (cost+pause BEFORE deny in `inc`, AFTER deny in `ontagstates`) `[O]` §3.2; port has no PredictShot gate at all | Series D6-PRED: `stand`-chain mount (no fly/angle/immediate child or sync), 50 attackobj + 50 attackpoint attempts (100). Expectation per attempt: no `projectiles` entry, `cooldown == max(pause_s, 1.0)`. Zero mismatches → wireable. |
| U-D7 | Building shot-point `:=0` clear vs `MaxFloat(…,1)` split | Both branches `[O]` `building.inc/ontagstates.inc:402-413,438-449` | Series D7-SHOTPT: tower with blocked shot-point arc, 30 attempts each vs obj + vs point. Expectation: `cooldown==0.0 AND maxdelay==0.0` with order+STO dropped (not 1.0). Any `1.0` → `[U]` (port has no shot-point model at all). |
| U-D8 | `attackmaxdelay` UI-only (no gate) | Negative grep: no `attackmaxdelay=0` gate `[O]` §3.3; port has no maxdelay field | Series D8-MAX: fire once, assert `maxdelay_0 == cooldown_0`, then assert next shot is allowed the tick `cooldown` hits 0 even though `maxdelay>0` still (sticky). Any gate on maxdelay → `[U]`. |

---

## 6. Concrete port change list (owner/COORD applies; this worker wrote no code)

All items add DONOR-VERBATIM values or explicitly labelled placeholders. None invents a number. No save-version bump, no demo/mill/builder/I11 change.

1. **`data.gd:21-23` — keep (grounded).** `FRAMES_TO_TIME=0.03125`, `PX_TO_M`, `TILE_M` already match `dmscript.global:170-175` `[O]`. No change.
2. **`data.gd` `UNITS_BASE[*].weapons[].cd` — re-derive from mount `pause` frames, do not keep estimates.** For every sid covered by DEC_U_weapon_tail §3, replace `cd: <N> * 0.03125` estimate with `cd: <donor_pause_frames> * 0.03125` + cite comment `unit.script:<line>` per mount (samples: cannon `350*0.03125` = 10.9375 `unit.script:1696-1731`; multicannon `60*0.03125` = 1.875 `:1794-1822`; tower `400*0.03125` = 12.5 `:2223-2257`, commonrus override `300*0.03125` = 9.375 `:2246`; musket `150*0.03125` = 4.6875 `:774`; archer `75*0.03125` = 2.34375 `:999`). Sids with `pause 0` (melee) → `cd: 0.0`. Sids NOT in the tail table keep current value with `PORT APPROXIMATION [U]-D1` tag — never copy a neighbour sid's number.
3. **`game.gd:4928` `e.cooldown = w.cd * rof` — keep shape, fix inputs.** `w.cd` becomes the §1.3 `pause_s`; `rof` is the `player.script:1857/1971` product (`rof_mult` already `0.7` for `aca_rof1/2`, `data.gd:1422-1425` grounded). Add comment `unit.script:10750-10789`. Melee (`w.cd==0.0`) then correctly writes `0.0` (closes U-D2 wiring; animation pacing owns reuse).
4. **`game.gd:4900` — replace PORT APPROXIMATION `1.0` with donor `2.0`.** Insufficient-cost path must write `e.cooldown = 64.0 * Data.FRAMES_TO_TIME` (= 2.0 s, `unit.script:8208-8209`) and set maxdelay likewise when the field exists (item 7). Currently `1.0` conflates the poor-shot penalty with the PredictShot/veto literal — split them with per-line cites.
5. **`game.gd:4906` — keep `3.125`, add cite.** `_GOLD_FIRE_STOP_S = 100/32` already equals `100*gc_frames_to_time` (`unit.script:8187-8188`, `miscext.script:1038`) `[O]`; add the cite + extend to buildings' capture-block case if that system is ported, else tag `[U]-D5`.
6. **`game.gd:4910,4915,4920` — tag PORT APPROXIMATION, do not present as donor.** `0.25` deploy-tick, `0.5` wall/ridge vetoes have NO donor counterpart (donor deploy does not exist; donor vetoes write literal `1.0`, `unit.script:8280-8281`): add `# PORT APPROXIMATION [U]-D6 (donor: MaxFloat(…,1), onaclanimationreachedattack.inc:107-108)` and route through the new item-8 helper so the literal is single-sourced.
7. **Add `attackmaxdelay` tracking (new field, additive).** `game.gd:1994` entity init: add `"cooldown_max": 0.0` beside `"cooldown": 0.0`. Mirror every `e.cooldown = X` write with `e.cooldown_max = maxf(e.cooldown_max, X)` for `X ∈ {w.cd*rof, 1.0, 2.0, 3.125}`; NEVER gate on it (per §3.3 negative result). Cite `dmscript.global:1737-1738`, `unit.script:10788-10789`.
8. **Add single-sourced deny helper (new code, verbatim literal).** `func _deny_with_floor(e): e.cooldown = 1.0; e.cooldown_max = maxf(e.cooldown_max, 1.0)` with comment `donor literal 1 (seconds scale per dmscript.global:1737 + 100*f2t/64*f2t siblings unit.script:8188,8209) — onaclanimationreachedattack.inc:107-108,135-136,145-146; unit.script:7701-7702,8280-8281,8536-8537`. Call it from: (a) new PredictShot gate (until child/sync tables land per DEC_U_weapon_tail §4, deny IFF mount propagation ∈ {stand, slightup} with no known fly/angle child — tag `[U]-D6`); (b) wall/ridge vetoes (replacing `0.5`); (c) friendly-fire vetoes when added (DEC_U_ff_predict §8-item-3). Covers BOTH attackobj and attackpoint paths (port `_fire` serves both — verify caller splits `t.player == -1` ground-aim `game.gd:4939` the same way).
9. **`game.gd:4513` + `5347-5349` decay — keep, add cite; fix `4739-4741` double-decrement.** Unit/building `cooldown = maxf(0, cooldown - dt)` matches `unit.inc/nothing.inc:87-92` + `building.inc/nothing.inc:28-29` `[O]`. But `attackground` (`game.gd:4739`) subtracts `dt` a SECOND time on top of `_tick_unit` (`:4513`) — donor decays once per tick: delete the `:4739` line or tag `PORT APPROXIMATION [U]-D1` until fixed.
10. **Telemetry/format.** Every value above carries its `unit.script:<line>` / `dmscript.global:<line>` / `misc.script:<line>` / `*.inc:<line>` cite in-comment; every remaining estimate keeps `PORT APPROXIMATION` + `[U]` tag with its §5 series. `visual_parity_claim=false`; unresolved = U-D1…U-D8 above (+ carried F4/F5/F6/F7, G1-tail).

---

## 7. Explicit non-claims and file discipline

- NO PARITY CLAIM. No donor binary executed, no donor GPU frame captured, no port capture compared. Closed items (pause-overwrite law, FramesToTime rule, all 13 `MaxFloat(…,1)×2` sites, gold/poor-shot literals, decay shapes, upgrade formulas, spawn/init values) rest on donor TEXT `[O]` with file:line; open items (full sid pause table in live sim, port wiring) list exact captures in §5.
- The brief's "attackdelay/attackmaxdelay sources per weapon/mount" is closed as: the LAW (overwrite with per-mount `pause_s = frames×0.03125`, penalties as `MaxFloat` floors) plus sample conversions; the FULL sid table is cited-not-duplicated from DEC_U_weapon_tail §3 — no number invented here.
- The brief's "1 s literal derivation" is closed as: literal **`1`** (`onaclanimationreachedattack.inc:107-108,135-136` + 11 siblings), `Float` seconds scale (`dmscript.global:1737`), gloss `1.0 s` via the `100*f2t`/`64*f2t` siblings (`unit.script:8188,8209`) `[D]` — never a fresh invention.
- Read-only compliance: exactly one repo file written (this report). Donor reads were pinned text reads against `t_87f0f3c130b0` (+ one read-only `Get-FileHash`); no target opened/selected/closed by this worker; no code/asset/config/Godot/git edit.

*End of DEC-U-ATTACK-DELAY.*
