---
id: DEC-U-RNG-LEDGER
worker: DEC-U-RNG-LEDGER (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied. Donor text scripts/data read as text only. No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. No multiplayer/netcode specified, audited, or changed."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker."
context: "Multiple reports left G1 open: Delphi round() half-to-even vs donor, GetRandom ledger/stream split, per-site draw counts, uniqrnd source, X21 20-vector fixture. Port uses identity reseeds (IMPL-SKIRMISH-LAWS) and labelled floor(RandomExt*n) wrappers; DEC_U_damage_height.md found uniqrnd spawn site unit.script:2726."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
---

# DEC-U-RNG-LEDGER — skirmish-sim RandomExt/Random draw ledger, round() settlement, 20-vector fixture (2026-11-26)

## 0. Pass ledger (owner rule; every native pass pinned `t_87f0f3c130b0`; donor read-only, never executed)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `t_87f0f3c130b0` = craft.json donor target `C:\Games\Cossacks 3`, 5,768,048 B, sha256 `87f0f3c1…4e16c` (matches DEC-U-SKIRMISH §0, DEC-U-DAMAGE-HEIGHT P1). No binary executed/copied. |
| P2 | Re-read X21 §3–§4 + D02 §4 raw function | `RandomExt` VA `0x60f64c–0x60f696` (file `0x20ea4c–0x20ea96`): `s←(s×0xFC0D+0x3C6EF35F) mod 2^32`, `f32(s/2^32)`; divisor `0x60f698` = `4294967296.0` (`0x4F800000`). Helpers `0x406718` (35 B, `ret 8`, `edx:eax=M×state64`) + `0x4067b8` (122 B, `ret 8`, mod `2^32`). Reused, not re-run. |
| P3 | Re-read D02 §4.1/§4.3/§4.5 + X21 §4.3/§4.5 | Stream split: `RandomExt` LCG (`0x60f64c`) vs Delphi `Random()` LCG (`seed=seed×0x8088405+1`, `0x403a0c`, `0x8f2008`, divisor `0x8f206c=2^-32`); three `RandomExt` owners + one Delphi stream; `SetRandomKey(k)` → `lo=k,hi=k>>31`; `SetRandomExtKey64(k0,k1)` → `lo=k1,hi=k0`; `GetRandomKey` → `lo`. Only `key1` feeds recurrence (X21 correction to D02 §4.2). |
| P4 | Donor-text reseed census re-read | `dogenerate.inc:990-997` wrappers; `initmapgen.inc:99,146` + `dogenerate.inc:1100/1161/1177/1213/1538/1616/1772/1909/1927` + `generatemap.inc:190/216/513/774` stage boundaries (D02 §4.6, X21 §6.2). Generation stages EXCLUDED from this ledger (GENSEED-owned); listed only as boundary provenance. |
| P5 | Skirmish-sim script site sweep (this ticket, text reads) | `unit.script:2706-2726,5300-5332,6332-6356,7547-7568,7855-7873,8017-8035,8026-8033,8185-8209,11520-11561,10750-10794` + `weapon.script:349-362,793-803,807-822,838-852,855-986,1011,1046-1051,1135-1157` + `miscext2.script:240-256,274-465,562-604,641-728` + `miscext.script:963-1185,1301-1405` + `misc.script:465-473,486-498` + `lib/res.script:180-344` + `player.script:240-322,1711,1790-1798` + `progress*.inc` + `projectile.inc/{onaclanimationreachedattack,onstopevent,doexplode,doexplodecustom}.inc` + `dmscript.global` constants. All `[O]` in §1. |
| P6 | Round-site sweep | `weapon.script:349-362` 14 `round()` rows (only `round` in shot path); `misc.script:465-473` converters; Delphi RTL `Round` = Bankers (half-to-even) per language spec; port `data.gd:1206-1214 donor_round` already half-to-even. Native `@Round` code address NOT re-anchored this ticket — stated as limit §5-U. |
| P7 | Port read-only inspection (EV-PORT) | `game.gd:176,310,319-321,509,5406,5412,6417,6512,6527,6537,6567,6603,7104,7170,7203,7207,7723,7836-7837` + `data.gd:22,1206-1214,1438,1482-1485,1509,1636-1644,1454-1491` — all `[O]` §4. No edit. |
| P8 | Negative grep (EV-NEG) | No `RandomInt`/`RandomFloat` engine API (D02 §4.1 `[O]` — port inventions); no `Randomize`/`RandSeed` script string (GEN-SEED P2 `[O]` — native-only); no `round()` outside `weapon.script:349-362` in shot path (DAMAGE-HEIGHT P7 `[O]`); no `height` term in `_misc_DoDamage` (DAMAGE-HEIGHT P9 `[O]`). |

DSL note `[D]` (inherited): donor `not X` on a numeric lvalue is the current-value read. Donor `{...}` is comment syntax: live value is the uncommented head.

---

## 1. Evidence register (new reads this ticket carry `file:line`; binary claims cite X21/D02/GEN-SEED ids)

| Evidence id / source | Label | Observation / supports |
|---|---|---|
| `ev_5dd2579d…` + `ev_ee039a9f…` + `ev_33572f0d…` + `ev_2ec034e5…/ev_aca7888e…/ev_bdc4a4a6…` (X21 §2, re-read P2) | [O] | `RandomExt` bytes `0x60f64c–0x60f696`: `fild qword [0x9048d4]` → `fdiv dword [0x60f698]` → `fstp dword [esp]` → `fwait` → `fld dword [esp]` → `ret`. Only rounding step is `fstp dword`. |
| `ev_6283059d…` + `ev_3232e617…` (X21 §2) | [O] | Divisor `0x60f698` = `f32 4294967296.0` / `u32 0x4F800000`. |
| `ev_5141e382…` + `ev_83bff802…` (X21 §2) | [O]/[D] | Helpers `0x406718`/`0x4067b8` (`ret 8` each); divisor words at entry are `1`/`0` → mod `2^32`; cross term `low(M×hi)` lands in EDX and is discarded → `key0` never feeds stream. |
| `ev_54ac1f0c…` (X21 §2) | [O] | Signature `b8 0d fc 00 00 33 d2 e8` occurs **5×** in `cossacks.exe` (`0x60f65d,0x7281ca,0x72d2d1,0x809657,0x8096a1`) — five LCG instances, same constants. |
| `ev_6478320b…` + `ev_78bcf9c8…` + `ev_583b7258…` (GEN-SEED §1) | [O] | Delphi `Random(256)` at `0x403a0c`: `state=(state×0x8088405+1) mod 2^32`, `ret=state>>>24`; seeder `0x4033b8` = QPC-low-dword else TickCount; 3 static callers (`0x5937a0,0x59c011,0x8300e5`), none on generation path → Delphi stream free-runs from process start, never reseeded per stage. |
| `ev_1858bbfd…` + `ev_3526b7da…` (D02 §2) | [O] | Registration `FUN_00608238`: `RandomExt→0x60f64c`, `GetRandomKey→0x60f69c`, `SetRandomKey→0x60f6a4`, `Get/SetRandomExtKey64→0x60f6bc/0x60f6dc`, `Random→0x60e47c`. No `RandomInt`/`RandomFloat`. |
| `dogenerate.inc:990-997` (D02 §4.5, prior [O]) | [O] | `GetRandom(n):=floor(RandomExt*n)`; `GetRandomRange(a,b):=a+floor(RandomExt*(b-a+1))`. |
| `misc.script:493-498` + `dmscript.global:176` (SKIRMISH §2.1) | [O] | `_misc_RandomInt:=floor(random*32768)`; `gc_c1rand_to_random=32768`. Lowercase `random` = Delphi stream, NOT `RandomExt`. |
| `misc.script:465-473,486-490` (TABLES §1.0) | [O] | `_misc_PixelsToTiles(v)=v/53.3333333`; `_misc_RandToRandom(v)=v/32768`; `_misc_FramesToTime(v)=v*0.03125`. |
| `dmscript.global:172` | [O] | `gc_pixels_to_tile=53.3333333`. |
| `unit.script:2726` (DAMAGE-HEIGHT P4) | [O] | `obj.uniqrnd := RandomExt` — ONCE per unit at creation, sim stream. Corrects `game.gd:6547` stale comment. |
| `unit.script:2706-2707` (TICK-ORDER §3-R6) | [O] | `obj.progresstick := floor(RandomExt*32)` at creation + `lastprogresstime:=0`. One sim draw per entity, mod-cohort phase. |
| `unit.script:5300-5332` + sibling `CheckFriendlyFireCannister` (DAMAGE-HEIGHT §2) | [O] | `SetRandomKey(floor(random*gc_MaxInt))` (Delphi `random`, `gc_MaxInt=2147483647` `:815`), then `RandomExt` scatter gate inside check fn. Order: reseed-then-draw. |
| `unit.script:11520-11554` `_unit_DoProjectile` (DAMAGE-HEIGHT §7) | [O] | `SetRandomKey(floor(random*gc_MaxInt))`; `disp>0` → 2× `RandomExt` scatter `(1-RandomExt*2)*maxdisp` per axis; `frnd:=RandomExt` → `WriteProj`. Order: reseed, scatter, scatter, frnd. |
| `weapon.script:1046-1051` `_weapon_CreateProjectileByWeaponID` (DAMAGE-HEIGHT §7) | [O] | `uniqrnd=0 → newuniqrnd:=random` (Delphi) else keep; `SetRandomKey(floor(newuniqrnd*gc_MaxInt))`; `floor(RandomExt*count)` shot-point pick; `random1` orientation 6× `RandomExt`; `stand` pitch 1× `RandomExt`. |
| `weapon.script:855-986,936-939,1011,1135-1157` `_weapon_InitProjectile` (DAMAGE-HEIGHT §5) | [O] | `random1/random` rotspeed `RandomExt`; `ThrowRandom` 3× `RandomExt` sphere-ish kick; PlayOnce `volumeclippedfreq<random` uses GENERAL `random` explicitly "cause no need to sync it". |
| `projectile.inc/onaclanimationreachedattack.inc:9-110` fire chain (DAMAGE-HEIGHT §6) | [O] | Melee/`weaponid=0`/`immediate` bypass projectiles (direct `_misc_DoDamage`); else `_unit_DoProjectile` → engine `TXThrowBehaviour` → `OnStopEvent→DoExplode`. |
| `projectile.inc/doexplode.inc:12,59-62,78-89,148-210` (DAMAGE-HEIGHT §6) | [O] | `:12 SetRandomKey(floor(arg_proj.uniqrnd*gc_MaxInt))` resync before child rolls; `:59-62 buseownerdamage` mount-vs-prototype damage select; `:78-89` radius+locked-target double-dip. |
| `miscext2.script:274-465` `_misc_DoDamage` (TABLES §2) | [O] | Headshot: `bCanHeadShot:=(kind=arrow or bullet) and (not target.bbuilding)` `:334`; `random<0.05` (Delphi) `:420`; `damage+=floor(uniqrnd*500)` `:437` (`uniqrnd` per-unit stored float, NOT a draw). |
| `miscext2.script:562-604` `_misc_DoRoundDamage` (DAMAGE-HEIGHT §6) | [O] | `count=Floor(1+sqr(r/0.35))`; `dist<r+explradius` (non-arrow) / `dist<r` (arrow). Victim loop draws: `floor(RandomExt*(1+max-min))` counts + `floor(RandomExt*list)` picks (`doexplode.inc:139-224` [O] prior). |
| `miscext2.script:641-728` `_misc_ProjSimulatePoint` (DAMAGE-HEIGHT §7) | [O] | Box-Muller Gaussian over LOCAL LCG (`seed:=314159269*seed+453806245 mod 2147483647`) seeded `floor(RandomExt*100000)`; impact `dst=rnd×1.3` tiles rotated `RandomExt*360`; `damagetime=0.275+…` (0.275–0.64 s window). |
| `miscext.script:963-1185` `_misc_CheckCapture` (TABLES §3) | [O] | Jitter init `random*TimeCheckCapture` (Delphi) `miscext2.script:2757`/`serial.script:870`/`building.inc/initial.inc:390`/`unit.inc/initial.inc:320`; cadence `0.1*19-eps` / art `0.1*5-eps`; AI rolls: `random>0.5` (easy gate `:1082`), `random>0.25` building / `>0.5859375` supermortar / `>0.390625` cannon / `>0.140625` mortar / `>0.546875` peasant (`:1147-1173`, all Delphi `random`); slow-death `hp:=1999-floor(RandomExt*300)` (`:1152`, sim `RandomExt`). |
| `unit.inc/nothing.inc:450-506` famine/rebellion (SKIRMISH §2.1) | [O] | Death `RandomInt<50/5/12` (difficulty-gated); rebellion `RandomInt<6000/100/200` (mercenary-only). `RandomInt` = Delphi `floor(random*32768)`. |
| `unit.script:3638-3668` guard sampler (TABLES §5) | [O] | `RandomExt<_misc_RandToRandom(3000/6000/10000/20000)`; P = 9.16%/18.31%/30.52%/61.04%. Sim stream. |
| `progress.inc:144-181` + `progressai.inc:4-18` (TICK-DRIVER §1) | [O] | Per-player slice reads `GetPlayerCurrentPlHandle` twice, zero writers — driver is native. Slice order: exists → income → consume → movecount → hold → disband → ProgressAI. |
| `unit.inc/nothing.inc:13-14,507-535` + `building.inc/nothing.inc:293-326` (TICK-ORDER §3-R5) | [O] | `gametimewithrnd:=gametime+uniqrnd` anchor (stored `uniqrnd`, NOT a draw); `lasttimecheckcapture:=gametimewithrnd+interval` on fire. |
| `miscext2.script:1861-1912` `ResetProgressPlayer` (TICK-ORDER §3-R7) | [O] | 7× Delphi `random*` jitters (`lastmiscplsecmaxtime:=random*4.0`, pool `*1.4`, searchenemy `*0.1/*1.0`, stats `*0.2`, topzones `*2.0`). NOT sim stream. |
| `weapon.script:349-362` (DAMAGE-HEIGHT P7, TABLES §1.1) | [O] | 14 `round()` rows, PUSSTRELA family only. No other `round()` in shot path. |
| `weapon.script:795-803` `_weapon_PredictShot` (DAMAGE-HEIGHT §5) | [O] | Stub: `True` iff fly-child exists else `False` (blocks shot + 1 s penalty). |
| `classes.script:4351-4367` `TProj` (DAMAGE-HEIGHT P9) | [O] | Carries kinematics + `uniqrnd` per projectile. |

---

## 2. Formula settlement — one LCG, one Delphi stream, float32 output, key0 discarded

**[D]** (X21 §4, D02 §4.2 as corrected):

```
s ← (s × 64525 + 1013904223) & 0xFFFFFFFF        # 0xFC0D / 0x3C6EF35F
RandomExt = float32(s / 4294967296.0) ∈ [0,1)    # fstp dword is the only rounding
GetRandom(n) = floor(RandomExt * n)              # dogenerate.inc:990-997
GetRandomRange(a,b) = a + floor(RandomExt*(b-a+1))
Delphi: d ← (d × 0x8088405 + 1) & 0xFFFFFFFF; Random = float32(d × 2^-32); RandomInt = floor(Random*32768)
```

- Period `2^32` (Hull–Dobell: `64525≡1 mod 4`, increment odd). No statistical-quality claim.
- `key0` (high word) NEVER affects any draw including the first: `0x406718` cross term lands in EDX, discarded by `0x4067b8` mod `2^32` (X21 §4.3). `(K0,K1)≡(0,K1)`. D02 §4.2 "first-output" sentence is superseded.
- `s=0` does NOT stick: draw #1 = `0x3C6EF35F` → `0.236067966`; no fixed point exists (`gcd(64524,2^32)=4 ∤ 0x3C6EF35F`). No `test/jz` guard in `0x60f64c–0x60f696` `[D]`; live-replay equivalence stays `[U]` (execution prohibited).
- D02 worked-example decimals were unrounded doubles; donor returns float32 (X21 §4.5): `0x3C6FEF6C` → `0.236083001` (not `0.236082996`), etc. I07/port MUST use §3 f32 column.
- Delphi `random`/`RandomInt`/`random<0.05`/`random>0.25` sites are a SEPARATE stream seeded once at process start (QPC else TickCount, GEN-SEED §2.2), never reseeded by any `SetRandomKey`/`SetRandomExtKey64`. A port single-`rng` stream is therefore MORE stable than the donor, not identical — call-for-call parity inside a stage requires TWO streams minimum.

---

## 3. round() settlement — half-to-even (Bankers), from Delphi runtime semantics

**Verdict [D] (language) / [U]-tail (binary address): Delphi `round()` is Bankers half-to-even. The port `donor_round` is CORRECT and must be kept; the remaining `[U]` is only the native `@Round` code address, not the semantics.**

1. **[O]** `round()` occurs ONLY in the 14 PUSSTRELA `time` rows (`weapon.script:349-362`). Values (verbatim donor expressions, never pre-rounded):
   `round(2*1.625)`, `round(4*1.625)`, `round(8*1.625)`, `round(5*1.625)`, `round(10*1.625)`, `round(15*1.625)`, `round(2*2.75)`, `round(4*2.75)`, `round(8*2)`, `round(2*0.5)`, `round(5*0.5)`, `round(10*0.5)`, `round(15*0.5)`.
2. **[D]** Arithmetic evaluation (exact binary fractions, no float error at this magnitude):
   `3.25→3`, `6.5→6`, `13→13`, `8.125→8`, `16.25→16`, `24.375→24`, `5.5→6`, `11→11`, `16→16`, `1→1`, `2.5→2`, `5→5`, `7.5→8`.
   The four `.5` cases (`6.5→6`, `5.5→6`, `2.5→2`, `7.5→8`) are the Bankers signature: ties go to EVEN. `floor(x+0.5)` would give `7/6/3/8` — wrong on three of four.
3. **[D]** Delphi `System.Round(X: Extended): Int64` is documented and compiler-lowered as Bankers (FPU `frndint` under the default `Round to nearest, ties to even` control word; `Trunc` is the `floor`-toward-zero sibling). The donor `time` rows DEPEND on this: `round(6.5)` selecting 6 vs 7 changes `FramesToTime` by a full frame (`0.03125 s`) and every downstream airburst in §1. Any `floor(x+0.5)` substitute is donor-false.
4. **[O]** Port `data.gd:1206-1214 donor_round` implements exactly this (`frac>0.5→up; <0.5→down; ==0.5→even`). Keep verbatim. The `[U]`-G1 tag on it stays ONLY until the X21 20-vector fixture (§6) is wired as a boot assert — semantics are settled, binary-address anchoring of `System.@Round` is the open tail (no Ghidra pass run by this worker; named as future pass, not performed here).
5. **[U]-tail experiment:** fixed-seed headless run asserting `donor_round(6.5)=6, (5.5)=6, (2.5)=2, (7.5)=8` through `Data.donor_round` against the pinned binary behaviour, plus `donor_weapon_row()` `time_frames` for all 14 PUSSTRELA rows (§6-G1). Any deviation → single-site override table, never `floor(x+0.5)`.

---

## 4. Skirmish-sim draw ledger — every site, stream, file:line, call order (generation EXCLUDED)

Notation: **S** = sim `RandomExt` LCG (`0x9048d4/d8` global at fire time; reseeds are identity per DEC-U-SKIRMISH §2.10); **G** = general Delphi `Random()` stream (`0x8f2008`, free-running). `n` in `floor(·*n)` is the donor literal. Order within a site is top-to-bottom as written. Generation stages (`initmapgen/dogenerate/generatemap` reseeds) are boundary provenance only — GENSEED owns their draw counts.

### S0. Entity birth (once per entity, NOT per tick)

| # | Site | Stream | Draws in order |
|---|---|---|---|
| S0-a | `unit.script:2726` `obj.uniqrnd := RandomExt` | **S 1** | 1× `RandomExt` → stored `uniqrnd` (correction to `game.gd:6547` comment). |
| S0-b | `unit.script:2706-2707` `obj.progresstick := floor(RandomExt*32)` | **S 1** | 1× `GetRandom(32)` → mod-cohort phase (`mod 2/3/7/31/53`). |
| S0-c | `unit.inc/initial.inc:320` / `building.inc/initial.inc:390` / `serial.script:870` `lasttimecheckcapture := random*TimeCheckCapture` | **G 1** | 1× Delphi `random*1.875` (art uses same init; interval differs at fire). |
| S0-d | `miscext2.script:1887-1907` `ResetProgressPlayer` (7 lines) | **G 7** | `random*4.0, *1.4, *0.1, *1.0, *0.2, *0.2(stats), *2.0` — all Delphi. |

### S1. Per-tick upkeep / famine / rebellion (per unit, per Progress firing of its owner)

| # | Site | Stream | Draws in order |
|---|---|---|---|
| S1-a | `unit.inc/nothing.inc:482` famine death `RandomInt<50/5/12` | **G 1** | `floor(random*32768)` (`misc.script:493-498`), thresholds by difficulty (hard 50 / normal 12 / easy 5). Gate: `gProfile.bFamine ∧ bfamine ∧ playable ∧ game/spectator ∧ ¬building ∧ ¬bnohungry`. |
| S1-b | `unit.inc/nothing.inc:487-497` rebellion `RandomInt<6000/100/200` | **G 1** | Same wrapper; gate mercenary-only (`brebellion ∧ bmercenary ∧ plInd≠mercenaryind`). |
| S1-c | `player.script:270-322` income/consume banks | **0** | NO draw. `mult=100, speed=250.0/20000, *32, floor` carries `remains` — deterministic. |

### S2. Capture (per capturable building/unit, at its own `lasttimecheckcapture` deadline)

| # | Site | Stream | Draws in order |
|---|---|---|---|
| S2-a | Deadline fire `unit.inc/nothing.inc:13-14` `gametimewithrnd:=gametime+uniqrnd` | **0** | Stored `uniqrnd`, NOT a draw. |
| S2-b | `miscext.script:1082` easy-gate `random>0.5` (AI-artillery suicide pre-gate) | **G ≤1** | 1× Delphi `random`, only if owner `bAI` ∧ target `bartillery` ∧ majority met. |
| S2-c | `miscext.script:1147-1173` AI die rolls (building / supermortar / cannon / mortar / peasant) | **G ≤1** | 1× Delphi `random` vs `0.25 / 0.5859375 / 0.390625 / 0.140625 / 0.546875`; at most ONE branch fires per capture event. |
| S2-d | `miscext.script:1152` slow-death `hp := 1999 - floor(RandomExt*300)` (+ `readdeath.inc:51` / `writedeath.inc:57` same span) | **S ≤1** | 1× `GetRandom(300)`, only on owner-AI building `bbuilt∧bslowdeath` non-`bDie` path. |

### S3. Shot path (per aimed shot, in fire order — the ledger core)

| # | Site | Stream | Draws in order |
|---|---|---|---|
| S3-a | `_unit_TryAttack` friendly-fire gates `unit.script:5300-5332` | **G 1 + S k** | `SetRandomKey(floor(random*gc_MaxInt))` (**G 1**, Delphi) → `_unit_CheckFriendlyFireCannister` sibling consumes `RandomExt` scatter-test draws (**S**, count = victim-scan draws, version-gated). |
| S3-b | `_unit_DoProjectile` `unit.script:11528-11554` | **G 1 + S 2–3** | `SetRandomKey(floor(random*MaxInt))` (**G 1**) → IF `disp>0`: 2× `RandomExt` scatter `dx=tx+(1-r*2)*maxdisp`, `dz=tz+(1-r*2)*maxdisp` (**S 2**) → `frnd:=RandomExt` (**S 1**) → `WriteProj`. Musket (`disp=0`): **0 S** scatter + 1 S frnd. Archer (175 px): 2 S + 1 S. Cannon (225 px): 2 S + 1 S. Order matters: scatter draws precede stored frnd. |
| S3-c | `_weapon_CreateProjectileByWeaponID` `unit.script:1046-1051` | **G ≤1 + S 1+6+1** | `uniqrnd=0 → newuniqrnd:=random` (**G ≤1**, Delphi fallback) else keep → `SetRandomKey(floor(newuniqrnd*gc_MaxInt))` (reseed, no draw) → `floor(RandomExt*count)` shot-point pick (**S 1**) → `random1` orientation 6× `RandomExt` (**S 6**) → `stand` pitch 1× `RandomExt` (**S ≤1**, only `stand` propagation). |
| S3-d | `_weapon_InitProjectile` `weapon.script:936-939,1011,1135-1157` | **S 1–3 + G ≤1** | `random1/random` rotspeed `RandomExt` (**S 1**) → `ThrowRandom` 3× `RandomExt` (**S 3**, only `random/random1` propagations) → `stand` `py:=RandomExt*0.125`, pitch `-(30+RandomExt*30)` (**S 2**, only `stand`) → PlayOnce `volumeclippedfreq<random` (**G 1**, Delphi, explicitly non-synced `:1011`). |
| S3-e | Airburst timer `time>0` rows (PUSSTRELA family, NUCLM) | **0** | `FramesToTime(round(...))` is arithmetic on §3 literals — NO draw. Port `dist/30` clamp / 0.45 s arrow / 512 cap have no donor counterpart (PORT APPROXIMATION). |
| S3-f | `DoExplode` `projectile.inc/doexplode.inc:12` resync | **0** | `SetRandomKey(floor(arg_proj.uniqrnd*gc_MaxInt))` — reseed from STORED `uniqrnd`, no draw. All child rolls below inherit this stream position. |
| S3-g | `DoExplode→_misc_DoRoundDamage` victim loop `doexplode.inc:139-224` | **S m+n** | Per child: `floor(RandomExt*(1+max-min))` counts + `floor(RandomExt*list)` picks. Counts are spawn-count-gated (version/branch-dependent) — exact `m+n` is the `[U]`-G1 per-site count experiment, never invented. |
| S3-h | `randomsimulate` children `miscext2.script:641-728` | **S 2 + local k** | `floor(RandomExt*100000)` seed (**S 1**) → LOCAL LCG Box-Muller (σ=0.25/0.425, NOT global stream) → impact `RandomExt*360` rotation (**S 1**) + `damagetime` window arithmetic. Port has no simulate system (non-support must be tagged). |

### S4. Damage application (per victim, inside `_misc_DoDamage`)

| # | Site | Stream | Draws in order |
|---|---|---|---|
| S4-a | Headshot gate `miscext2.script:420` `random<0.05` | **G 1** | 1× Delphi `random`, only if `bCanHeadShot` (`arrow/bullet` ∧ ¬building) ∧ ¬fast-horse-bullet. |
| S4-b | Headshot bonus `:437` `floor(uniqrnd*500)` | **0** | Stored per-unit `uniqrnd`, NOT a draw. |
| S4-c | Everything else (`shield÷3`, hold ±, `protection[kind]`, `-5` fasthorse, `max(1,·)`, score/kill) | **0** | Pure arithmetic. No height/dispersion term (negative grep `[O]`). |

### S5. AI / economy brains (per ProgressAI firing, `2.4 s` gate + `60+plInd*3 s` seed-wheat gate)

| # | Site | Stream | Draws in order |
|---|---|---|---|
| S5-a | Guard sampler `unit.script:3638-3668` | **S ≤1** | At most 1× `RandomExt<v/32768` per candidate (`3000/6000/10000/20000` → 9.16%/18.31%/30.52%/61.04%). |
| S5-b | `progresswarai.inc:1749-1750,2681` scatter + `4096/32768` gate | **S 1–2 + G ≤1** | `floor(RandomExt*(max+1-min))` (**S**) + `4096/32768≈12.5%` gate (stream per DEC_U_skirmish_tables §8 `[O]`-shape; exact G/S attribution per line is `[U]`-G1 — count, don't assume). |
| S5-c | `progresseconomicai.inc:78,3142` mine-position `floor` draws | **S k** | `GetRandom` position picks; exact `k` per `minesdensity`/`gRecordGeneratorVersion` is `[U]` (GENSEED XU3 analogue) — count per version, never invent. |
| S5-d | Fear selector `progresswarai.inc:2798-2832` | **0** | `dist<30/400` force/dist rule — NO draw. |
| S5-e | Market `lib/res.script:313-344` trade + `:291-308` recovery | **0** | `floor(sell*cost/buycost)` + weight pushes + exponential `dt` — NO draw. |

### S6. Fixed-seed 1v1 skirmish draw ledger (synthetic seed, exact order, zero generation draws)

Fixture seed (synthetic test input, NOT a claimed donor seed — X21 §5 discipline):
`key0 = 0x44A108F9` (donor-observed word `bonmis1.map:0x18c0f1`, reused as convenient high word), `key1 = 0x00000001` (synthetic low word so state #1 = `M+C` and is hand-checkable).

Preconditions: flat map, `startid` preset with 1 peasant per side + 1 musketeer per side (muskets: `disp=0` → minimal scatter branch), `difficulty=1` (normal: famine 12 / rebellion 200), `gProfile.bFamine=true`, no AI (all die-roll branches dead), no capture (out of radius), `game` mode, `GetTimeSpeedFactor` fixed, headless fixed-`dt`.

Stream key: ledger key MUST be `(stage_id, generator_version, stream_name)` (X21 §6.2) — the port single-`rng` stream cannot reproduce this; a ledger is required.

| seq | Stage / site | Stream | Draw # on that stream | `s` (hex) | `RandomExt` f32 | `floor` consumed |
|---|---|---|---|---|---|---|
| 1 | spawn P0 peasant: S0-a `uniqrnd` | S | 1 | `0x3C6FEF6C` | `0.236083001` | stored `uniqrnd=0.236083001` |
| 2 | spawn P0 peasant: S0-b `progresstick` | S | 2 | `0x7DCC6BDB` | `0.491400480` | `floor(0.491400480*32)=15` |
| 3 | spawn P1 peasant: S0-a | S | 3 | `0xD9FC017E` | `0.851501524` | stored `0.851501524` |
| 4 | spawn P1 peasant: S0-b | S | 4 | `0x5FB30EC5` | `0.373825967` | `floor(0.373825967*32)=11` |
| 5 | spawn P0 musketeer: S0-a | S | 5 | `0x5B109F60` | `0.355722398` | stored `0.355722398` |
| 6 | spawn P0 musketeer: S0-b | S | 6 | `0x39298B3F` | `0.223290160` | `floor(0.223290160*32)=7` |
| 7 | spawn P1 musketeer: S0-a | S | 7 | `0x089D0992` | `0.0336461999` | stored `0.0336461999` |
| 8 | spawn P1 musketeer: S0-b | S | 8 | `0x41D427C9` | `0.257143497` | `floor(0.257143497*32)=8` |
| 9 | P0 musketeer fires (musket, `disp=0`): S3-b reseed | G | — | — | `random` (Delphi free-run) | `SetRandomKey(floor(random*2147483647))` — G stream, value varies per process start |
| 10 | P0 shot: S3-b frnd | S | 9 | `0x6B5ED494` | `0.419415742` | `frnd=0.419415742` → `WriteProj` |
| 11 | P0 shot: S3-c pick `floor(RandomExt*count)` (count=1: single shot point) | S | 10 | `0x09816EE3` | `0.0371312425` | `floor(0.0371312425*1)=0` |
| 12 | P0 shot: S3-c orientation 6× | S | 11–16 | `0x212908E6,0x5046CF0D,0x03D84308,0x50663AC7,0xF37BD37A,0x7DE4C891` | `0.129532397,0.313580453,0.015018644,0.314059913,0.951108158,0.491772205` | 6 orientation draws (musket `immediate` propagation still runs pick+orientation per `:1046-1051` shape; if port skips projectiles for `immediate`, tag `[U]` — do NOT delete draws silently) |
| 13 | victim S4-a headshot gate | G | — | — | `random` (Delphi) | `random<0.05`; on true S4-b adds `floor(stored uniqrnd*500)` = `floor(0.0336461999*500)=16` (P1 musketeer `uniqrnd` from seq 7) — NO S draw |
| 14 | P1 musketeer fires: S3-b reseed | G | — | — | `random` | `SetRandomKey(...)` |
| 15 | P1 shot: S3-b frnd | S | 17 | `0xD67BDEBC` | `0.837827623` | `frnd=0.837827623` |
| 16 | P1 shot: S3-c pick | S | 18 | `0x0FFA52EB` | `0.062413391` | `floor(0.062413391*1)=0` |
| 17 | P1 shot: orientation 6× | S | 19–24 | `0x75C47D4E,0xA2C21855` + next 4 states (`s=(s×64525+C)&U32` continued) | `0.460029453,0.635774136,…` | 6 draws; states 21–24 continue the recurrence verbatim (compute, don't quote from memory — assert via `Float32Array` round-trip) |
| 18 | famine tick (all 4 units, normal): S1-a | G | — | — | `random` ×4 | `floor(random*32768)<12` per unit; deaths `→essential_death` |

States 1–20 hex/f32 are X21 §5.1 verbatim (`0x3C6FEF6C … 0xA2C21855`); `bits LE` column in X21 is the strongest I07 comparison key (`bebf713e … 18c2223f`). `f32-product` vs `f64-product` floor variants showed NO divergence for `n∈{3,5,10,256}` in these 20 vectors, but DScript promotion stays `[U]` (both variants in JSON).

What is NEVER invented: any G-stream value (Delphi free-runs from QPC — seq 9/13/14/18 vary per process start and can NEVER be snapshotted into a fixture); any `m+n` victim-loop count (S3-g is spawn-gated); any `minesdensity`/`gRecordGeneratorVersion` count (S5-c). The ledger above uses the MINIMAL musket branch (no scatter, no `random1`/`stand`/`ThrowRandom`, no AI, no capture) precisely so every S draw is pinned.

---

## 5. Still-[U] register — each with a fixed-seed 20-vector zero-mismatch capture

General harness (all items): fixed fixture seed `(0x44A108F9, 0x00000001)`; X21 `rng_model.py` + `test_vectors.json` as oracle (outside repo, `C:\Users\Maxym.Oboyshev\AppData\Local\Temp\opencode\rng_verify\`); headless fixed-`dt`; canonical JSON state hash (players, entities, projectiles, RNG-stream counters, per-player deadlines, banks, `uniqrnd` per unit/projectile, `lasttimecheckcapture` per capturer). **Termination: run the FULL series; ANY single mismatch vs the stated donor expectation keeps the item `[U]` and forbids wiring; zero mismatches across the FULL series closes it.** Never fit/invent a draw order or stream.

| # | Item | Static state after this ticket | Exact capture (owner-authorised; no donor binary) |
|---|---|---|---|
| G1-a | `round()` Bankers on binary | Semantics settled §3 `[D]`; native `@Round` address open | Series R20: assert `donor_round()` over `{3.25,6.5,13,8.125,16.25,24.375,5.5,11,16,1,2.5,5,7.5,2*1.625,4*1.625,8*1.625,2*2.75,4*2.75,8*2,2*0.5,5*0.5,10*0.5,15*0.5}` + all 14 PUSSTRELA `time_frames` via `donor_weapon_row()`. Expect `{3,6,13,8,16,24,6,11,16,1,2,5,8,…}`. Zero mismatches → drop `[U]`-G1 tag on `donor_round`; any → single-site override table, never `floor(x+0.5)`. |
| G1-b | `GetRandom` ledger / stream split (`random` vs `RandomExt`) | Order `[O]` §4; cross-stream attribution `[U]` | Series L20: fixed-seed 1v1 §4-S6, 20 S draws asserted against X21 §5.1 (`s` hex + `bits LE` + `floor(r×{3,5,10,256})`). G draws asserted ONLY as counts (values free-run). Expect exact S sequence `3C6FEF6C…A2C21855`; any S divergence → `[U]`; G VALUE mismatch is NOT a failure (count only). |
| G1-c | Per-site draw counts (musket 0-scatter / archer 2 / cannon 2+frnd) | Sites `[O]` §4-S3; counts `[U]` | Series C300: flat map, cannon/archer/musket shooters × fixed target at 10/20/30 m, 100 shots each (300). Expect S draws/shot: musket 1 (frnd) + S3-c 7; archer 3 + 7; cannon 3 + 7; `stand` +2; `random1/random` +4 (`1` rotspeed + `3` ThrowRandom). Zero count mismatches → close; any extra draw → `[U]`. |
| G1-d | `uniqrnd` source + `WriteProj` frnd order | Spawn site `[O]` `:2726`; order `[O]` §4-S3-b | Series U50: spawn 50 units, log per-unit `uniqrnd` vs S stream positions 1,3,5,7,…; fire 50 musket shots, assert scatter-precedes-frnd (S3-b). Zero mismatches → close; scatter-before-frnd violation → `[U]`. Corrects `game.gd:6547` comment per §7 item 6. |
| G1-e | DScript `floor(RandomExt*n)` promotion (f32 vs f64 product) | 20 vectors no-divergence `[D]`-sample; proof open `[U]` | Series F1M: sweep `n∈{1..512, 100000}` × all 20 S values, compare `floor(f32(r)*n)` vs `floor(f64(r)*n)` + `GetRandomRange` edges. Zero divergences → document f32-promotion as safe for tested range (still tag `[U]` beyond it); any divergence at exact boundary → wire f32 path verbatim. |
| G1-f | Signed `key0` edge (product-high bit 31) | X21 §8 item 3 `[U]` | Series K0: `key0 ∈ {0x00000000, 0x44A108F9, 0x80000000, 0xFFFFFFFF}` × `key1=0`, first-draw assert. Expect u32 model for first two (`0x3C6EF35F`, `0x3C6FEF6C`); latter two assert WITHOUT claiming donor behaviour (no donor run) — any port crash/NaN → `[U]`, keep guard. |
| G1-g | AI/capture/economy draw attribution | Sites `[O]`-shape §4-S2/S5; per-line G/S `[U]` | Series A600: 1 AI vs 1 idle human, 600 s, log every AI/capture/economy draw with stream tag. Expect guard-sampler S counts + die-roll G counts + slow-death S `floor(·*300)` per §4; headshot G gate + zero-S bonus. Zero mismatches → close; any stream flip → `[U]`. |
| G1-h | `GenerateMapRandKey` / saved-map key bytes | XU1/XU2 inherited `[U]` | NOT a skirmish-sim item — generation-owned (GENSEED). Listed for ledger completeness only; no capture proposed here. |

---

## 6. X21 20-vector fixture — canonical oracle for every G1 capture above (verbatim `[D]`)

Fixed pair `(key0=0x44A108F9, key1=0x00000001)`. `bits LE` is the strongest key. Full JSON with both floor variants: `...\rng_verify\test_vectors.json` (X21 §5).

| # | s (hex) | s (dec) | RandomExt f32 | bits LE | ⌊r×3⌋ | ⌊r×5⌋ | ⌊r×10⌋ | ⌊r×256⌋ |
|---|---|---|---|---|---|---|---|---|
| 1 | 0x3C6FEF6C | 1013968748 | 0.236083001 | bebf713e | 0 | 1 | 2 | 60 |
| 2 | 0x7DCC6BDB | 2110548955 | 0.491400480 | d898fb3e | 1 | 2 | 4 | 125 |
| 3 | 0xD9FC017E | 3657171326 | 0.851501524 | 01fc593f | 2 | 4 | 8 | 217 |
| 4 | 0x5FB30EC5 | 1605570245 | 0.373825967 | 1e66bf3e | 1 | 1 | 3 | 95 |
| 5 | 0x5B109F60 | 1527816032 | 0.355722398 | 3f21b63e | 1 | 1 | 3 | 91 |
| 6 | 0x39298B3F | 959023935 | 0.223290160 | 2da6643e | 0 | 1 | 2 | 57 |
| 7 | 0x089D0992 | 144509330 | 0.0336461999 | 99009d3d | 0 | 0 | 0 | 8 |
| 8 | 0x41D427C9 | 1104422857 | 0.257143497 | 50a8833e | 0 | 1 | 2 | 65 |
| 9 | 0x6B5ED494 | 1801376916 | 0.419415742 | a9bdd63e | 1 | 2 | 4 | 107 |
| 10 | 0x09816EE3 | 159477475 | 0.0371312425 | ee16183d | 0 | 0 | 0 | 9 |
| 11 | 0x212908E6 | 556337382 | 0.129532397 | 24a4043e | 0 | 0 | 1 | 33 |
| 12 | 0x5046CF0D | 1346817805 | 0.313580453 | 9e8ea03e | 0 | 1 | 3 | 80 |
| 13 | 0x03D84308 | 64504584 | 0.015018644 | c210763c | 0 | 0 | 0 | 3 |
| 14 | 0x50663AC7 | 1348876999 | 0.314059913 | 76cca03e | 0 | 1 | 3 | 80 |
| 15 | 0xF37BD37A | 4084978554 | 0.951108158 | d37b733f | 2 | 4 | 9 | 243 |
| 16 | 0x7DE4C891 | 2112145553 | 0.491772205 | 91c9fb3e | 1 | 2 | 4 | 125 |
| 17 | 0xD67BDEBC | 3598442172 | 0.837827623 | df7b563f | 2 | 4 | 8 | 214 |
| 18 | 0x0FFA52EB | 268063467 | 0.062413391 | 2fa57f3d | 0 | 0 | 0 | 15 |
| 19 | 0x75C47D4E | 1975811406 | 0.460029453 | fb88eb3e | 1 | 2 | 4 | 117 |
| 20 | 0xA2C21855 | 2730629205 | 0.635774136 | 18c2223f | 1 | 3 | 6 | 162 |

Word-order (X21 §5.2 `[D]`): `(0,1)` → identical stream (key0 discarded); swapped `(1,0x44A108F9)` → `3D718404,19269793,809959D6`; `(K0,0)` → `3C6EF35F,85A2D332,4D98E4E9`. Zero-state (X21 §5.3): `0` → `3C6EF35F,85A2D332,4D98E4E9,AE87EF34,E8CD4903`, no stick, no fixed point.

---

## 7. Concrete port change list (owner/COORD applies; this worker wrote no code)

All items add DONOR-VERBATIM values or explicitly labelled placeholders. None invents a draw order, stream, or seed. None touches save version keys, demo/mill/builder hooks, or I11 seam paths.

1. **`data.gd:1206-1214 `donor_round` — KEEP, keep `[U]`-G1 tag until §5-G1-a green.** Semantics settled §3 (Bankers). Add cite `weapon.script:349-362` + `System.Round` note in comment. `donor_weapon_row()` `:1417-1447` `FramesToTime(round(...))` path stays verbatim (never pre-round the 14 PUSSTRELA `time_expr` rows). No `floor(x+0.5)` anywhere on this path.
2. **`data.gd:1636-1644 RNG ledger consts — EXTEND with stream tags.** Current `GetRandom/GetRandomRange/slow_death/guard_sampler/damage_headshot` rows are correct formulae but stream-UNLABELLED. Add `"stream": "S"` to `GetRandom/GetRandomRange/slow_death/guard_sampler`, `"stream": "G"` to `RandomInt` (new row `floor(random*32768)`, `misc.script:493-498`), `"stream": "G"` to `damage_headshot` gate (`random<0.05`) + `"stream": "stored"` to `floor(uniqrnd*500)`. Cite per §1. Add `DONOR_DELPHI_M := 0x8088405`, `DONOR_DELPHI_C := 1`, `DONOR_LCG_M := 64525`, `DONOR_LCG_C := 1013904223` consts with X21/D02 cites (port `rng`/`gen_rng` are Godot `RandomNumberGenerator`, NOT these recurrences — label PORT APPROXIMATION until wrapped).
3. **`game.gd:310 `_init` + `:319-321` `_reseed_stage` — KEEP identity (IMPL-SKIRMISH-LAWS landed).** Add ledger comment: `SetRandomKey`/`SetRandomExtKey64` are identity same-key reseeds at `initmapgen.inc:99,146` + `dogenerate.inc:1100/1161/1177/1213/1538/1616/1772/1909/1927` + `generatemap.inc:216/513/774` (D02 §4.6); `key0` discarded (X21 §4.3). Do NOT reintroduce `seed+si*1000003+ver*10007` derivation.
4. **`game.gd:176,509,7723,7836-7837` `rng`/`gen_rng` — SPLIT streams (the ledger fix).** Current single `rng` + mapgen `gen_rng` + `brng` family (`:2360-2905`) cannot express §4 S/G split. Add second sim-owned `RandomNumberGenerator` for the Delphi stream (name `delphi_rng`, seeded from wall-clock at process start per GEN-SEED §2.2 — NEVER from `_reseed_stage`), route every §4-G site through it, keep every §4-S site on `rng`. `brng`/`gen_rng` sim consumption (`:1052,1081-1082,1101-1103,1232,1262,1268,1271,1597-1599,2428-2905`) is generation-owned — do NOT route skirmish draws through them. Save both `rng_state` + new `delphi_state` (additive keys only; §7 item 8).
5. **`game.gd:5406 `_misc_random_int` + `:5412` wrapper — FIX stream.** Current `_misc_random_int` draws on sim `rng` (`floorf(rng.randf()*32768)`). Donor `RandomInt` is Delphi G (`floor(random*32768)`). Rewire to `delphi_rng` when item 4 lands; until then keep `[U]`-G1 tag. Add `_donor_get_random(n)` S-wrapper `floorf(f32(rng.randf())*n)` (f32 via `Float32Array` round-trip per X21 §6, never bare double) and route §4-S `GetRandom` sites through it (`:6512,6527,6537` scatter, `:6567,6603` rolls are G — do NOT route those through the S wrapper).
6. **`game.gd:6512,6527,6537` scatter — REPLACE with §4-S3-b box law.** Delete `*0.5`/`*0.4` factors and constant-dispersion fallback. Implement `maxdisp_m = dist_m * dispertion_px_mount / 2000` with the MOUNT's `dispertion_px` from `DONOR_MOUNT_ROWS` (archer 175 / tower 100 / rus 125 / cannon idx0 225 `[O]`; CANNON/TOWER `data.gd:422-423` per-kind fallbacks stay ungrounded until cited per-mount). Zero-dispersion mounts scatter NOTHING. Draw order per shot: scatter, scatter, then stored frnd. Cite `weapon.script:627-646` + `unit.script:11520-11531`.
7. **`game.gd:6547,7317,7431-7433,7616-7619` `uniqrnd` comments + spawn — FIX cite, ADD draw.** Comments claim "no static site recovered" — the site IS `unit.script:2726` (`obj.uniqrnd := RandomExt`). Fix comments (comment-only). When spawner is next touched: draw one S-stream float per created unit into `uniqrnd` (default `0.0` keeps old saves deterministic), plus one S `GetRandom(32)` into `progresstick` phase (`unit.script:2706-2707`). Projectiles: ADD `uniqrnd` per `TProj` (`classes.script:4366`) from S3-b frnd when item 6 lands; missing key defaults `0.0`.
8. **`game.gd:7723 save — ADD keys only.** `delphi_state` (new G stream), `uniqrnd` per unit/projectile, `progresstick` phase already listed — verify presence; never rename/remove existing v5 keys (`rng_state/gen_rng_state/...`); never bump version. Deadlines/banks per TICK-DRIVER §4 item 9 ride along unchanged.
9. **`game.gd:6417,6567,6603,7104,7170,7203,7207` G-stream sites — REWIRE to `delphi_rng` when item 4 lands.** `headshot_roll = rng.randf()<0.05` (`:6603`), AI die rolls (`:6567,7203`), easy-gate (`:7170`), capture jitter init (`:7104`), slow-death `donor_get_random(rng.randf(),300)` (`:7207`, S — stays on `rng` with f32 wrapper). Until rewired, each keeps its `[U]`-G1 tag — do NOT retune thresholds to pass.
10. **Telemetry/format.** Every value above carries `unit.script:<line>` / `weapon.script:<line>` / `miscext*.script:<line>` / `dmscript.global:<line>` cite in comment; every remaining estimate keeps PORT APPROXIMATION + `[U]` tag with its §5 series. `visual_parity_claim=false`; unresolved = [G1-a…G1-h above + D1-dispersion/height-engine + A1-AI-bodies + R1-bytes + V1/V2/F1/E1 + O1-interleave per DEC_U_skirmish_tables §9].

---

## 8. Explicit non-claims and file discipline

- NO PARITY CLAIM. No donor binary executed, no donor GPU frame captured, no port capture compared. Closed items (LCG arithmetic, f32 output, key0 discard, wrapper formulae, per-site ORDER, `uniqrnd` spawn site, `round()` Bankers semantics on the four ties, X21 20-vector states) rest on donor bytes/TEXT `[O]` with file:line/VA; open items (live-replay equivalence, DScript promotion proof, per-site COUNTS at S3-g/S5-c, Delphi G VALUES, native `@Round` address, `GenerateMapRandKey`, saved-map key bytes, engine ballistic/collision/rotation) list exact captures in §5.
- No approximation substituted for a resolved law. The three port inventions found on this path (single-stream `rng` for both S+G, `*0.5`/`*0.4` scatter factors, stale "no uniqrnd site" comment) are named with replacements, not smoothed over.
- Read-only compliance: exactly one repo file written (this report). Donor reads were pinned text reads against `t_87f0f3c130b0` (+ prior-evidence reuse P2–P4); no target opened/selected/closed by this worker; no code/asset/config/Godot/git edit.

*End of DEC-U-RNG-LEDGER.*
