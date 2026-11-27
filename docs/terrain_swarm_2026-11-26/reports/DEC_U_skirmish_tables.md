---
id: DEC-U-SKIRMISH-TABLES
worker: DEC-U-SKIRMISH-TABLES (subagent, full 1:1 Cossacks 3 donor port)
wave: PORT1TO1 / terrain_swarm_2026-11-26
date: 2026-11-26
status: DELIVERED__READ_ONLY__EXACTLY_ONE_FILE__NO_PARITY_CLAIM
pin: "t_87f0f3c130b0 = C:\\Games\\Cossacks 3\\cossacks.exe, PE32, 5,768,048 B, sha256 87f0f3c130b027e7c4e72dc217eae9d592982370d112e0d224897bc92af4e16c"
donor: "READ ONLY. Donor binary never executed/copied. Donor text scripts/data read as text only. No repo code/asset/config/Godot/git edit: this report is the only file written."
network: "OUT OF SCOPE. No multiplayer/netcode specified, audited, or changed."
parity: "NO PARITY CLAIM. No donor GPU A/B frame; no donor binary executed by this worker."
context: "DEC_U_skirmish.md + DEC_U_skirmish_impl_patch.md resolved famine/market/RNG/capture-head/damage-row SHAPES but left [U]: T1 per-sid values, T2 application fn, C1 tail, S starts, A1 AI thresholds, R1 save contract, O1 tick interleave, G1 RNG ledger. data.gd has donor row KEYS but per-sid VALUES are placeholders (many prot [0,0,0,0,0,0])."
labels: "[O] verbatim donor literal (file:line) · [D] deterministic reading · [I] inference, flagged · [U] UNVERIFIED with exact experiment · PORT APPROXIMATION = port substitute to remove for 1:1"
---

# DEC-U-SKIRMISH-TABLES — per-sid weapon/protection values, damage fn, capture tail, starts, AI, save, tick, RNG (2026-11-26)

## 0. Pass ledger (owner rule; every native/script pass pinned `t_87f0f3c130b0`; donor read-only)

| # | Pass | Result / evidence |
|---|---|---|
| P1 | Pin re-assert | `t_87f0f3c130b0` = craft.json donor target `C:\Games\Cossacks 3`, 5,768,048 B, sha256 `87f0...4e16c` (matches DEC-U-SKIRMISH §0). No binary executed. |
| P2 | `weapon.script:39-62,250-391` full read | EV-T1-W: complete `_weapon_AddWeapon` row table §1.1 (78 call rows, all `[O]`). Procedure shape `weapon.script:39-62` + constants `dmscript.global:687-705`. |
| P3 | `dmscript.global` constants read | EV-GLB: px/tile, weapon enums, capture radii, AI caps, tick times, victorystate, resource ids §1–§8 (all `[O]` with line numbers). |
| P4 | `unit.script:510-517,600-1584` protection + weapon audit | EV-T1-P: 33 `SetObjBaseProtection` rows mapped to enclosing `sid`/`nation` case branches §1.2 (all `[O]`). `SetObjBaseWeapon` per-sid rows §1.3 (samples, full audit recipe). |
| P5 | `miscext2.script:274-465` damage path read | EV-T2: `_misc_DoDamage` full application function RESOLVED §2 (all `[O]`). |
| P6 | `miscext.script:963-1185` capture tail read | EV-C1: protector scan + AI-artillery majority + AI die rolls + `_misc_ChangePlayer` RESOLVED §3 (all `[O]`). |
| P7 | `building.inc/nothing.inc:293-326` + `unit.inc/nothing.inc:507-535` cadence read | EV-C1-CAD: capture cadence + map-mode gate RESOLVED §3 (all `[O]`). |
| P8 | `startingsettings.cfg:87-858` + `dogenerate.inc:230-396` dispatch read | EV-S: start 6-resource tables + double-add quirk + role→airole map + verbatim masks RESOLVED §4 (all `[O]`). |
| P9 | `progress.inc:1-185` + `dmscript.global:144,156,1484-1487` tick read | EV-O1: per-player slice + stagger + global cadences RESOLVED-HEAD §7 (all `[O]`). |
| P10 | `unit.script:3620-3668`, `progresswarai.inc:2798-2842`, `progress.inc:5-35` AI read | EV-A1: sampler thresholds + fear selector + disband literal RESOLVED §5 (all `[O]`). |
| P11 | `serial.script` + `global.inc/write*.inc/read*.inc` inventory | EV-R1: save framing inventory §6 (names+sizes `[O]`, byte order still `[U]`). |
| P12 | `dogenerate.inc:990-997`, `generatemap.inc`, `initmapgen.inc:99-106`, `player.script:240-322` RNG+ledger read | EV-G1: draw sites + ledger shape §8 (all `[O]`). |
| P13 | `player.script:1790-1798`, `country.script` protection-upgrade grep | EV-T1-U: protection upgrade application `[O]` §1.4. |
| P14 | `variant3d/scripts/data.gd` read-only inspection | EV-PORT: row KEYS present, per-sid VALUES placeholders §9 (no edit). |

DSL note `[D]` (load-bearing, inherited from DEC-U-SKIRMISH §0): donor `not X` on a numeric lvalue is the current-value read, not boolean negation. All predicates below use this rule.

---

## 1. T1 — per-sid weapon / protection VALUES (static; keyed by shipped sid)

### 1.0 Global constants every row depends on `[O]`

- `dmscript.global:172` `gc_pixels_to_tile = 53.3333333`. Hence `_misc_PixelsToTiles(v) = v/53.3333333` (`misc.script:465`), tiles→m `×2` (`TILE_M=2`), px→m `÷26.6666666` (`data.gd:22` already exact).
- `dmscript.global:176` `gc_c1rand_to_random = 32768`.
- `dmscript.global:177` `gc_weapon_gravity_c1toc3 = 2`; `:179` `gc_buildtime_modifier = 10`; `:180` `gc_squad_holdmode_time = 150*8*gc_frames_to_time`; `:182` `gc_buildtime_progressperhit = 10*frames_to_time*1.15`.
- `dmscript.global:278-288` weapon-kind enum `[O]`: `none=0, pike=1, sword=2, bullet=3, cannister=4, arrow=5, firearrow=6, cannonball=7, mortarball=8, heal=9`; `count=10`.
- `dmscript.global:687-705` weapon-row enums `[O]`: `time`: `cInfinite=-1, cPlayOnce=0`; `gravity`: `0..5` literal ints; `propagation`: `stand=0, slightup=1, random=2, fly=3, immediate=4, angle=5, random1=6, randomsimulate=7`.
- `dmscript.global:341-398` AI-role enum `[O]`: `none=0, peasant=1, center=3, mill=4, ba17=5, ba18=6, store=7, academi=8, stable=9, dipcenter=10, artdepo=11, market=12, tower=13, smith=14, temple=15, port=16, house=17, minegold=18, mineiron=19, minecoal=20, officer17=21, drummer17=22, infantry17=23, grendip=24, musk17=25, reitar=26, cuirassier=27, grenadier=28, musk18=29, cannon=30, howitzer=31, mortar=32, cossackdip=33, archer=34, dragundip=35, priest=36, mbarrel=37, dragun18=38, frigate=39, galley=40, yacht=41, lineship=42, ferry=43, uniq_inf17=44, uniq_inf18=45, uniq_cav17=46, uniq_cav18=47, hussar=48, dragoon17=49, officer18=50, drummer18=51, light_dip=52, round_dip=53, pikeman18=54`.
- `dmscript.global:791-797` resource ids `[O]`: `none=0, food=1, wood=2, stone=3, gold=4, iron=5, coal=6`. `gc_ResCount` loop `0..gc_ResCount-1` (`player.script:245,276`).
- `dmscript.global:808` `gc_obj_foodperunit = 30` (base for all `consume food = floor(30×k)` rows).

### 1.1 Projectile/weapon prototype table — COMPLETE, all rows `[O]` (`weapon.script:314-391`)

 Columns: `sid | damage | radius_px (donor literal) | radius_tiles (=px/53.3333333) | radius_m (=tiles×2) | gravity | propagation | physvalue→meaning | time`. `physvalue` meaning per `weapon.script:59-62` `[O]`: `random/random1/fly/randomsimulate → speed`; `angle → angle`; `slightup → gravity := -physvalue`; `stand/immediate → unused`.
 FX/proj basenames are literal strings in rows (`cFX*/cProj*` constants `weapon.script:250-309`); included abbreviated.

| sid | dmg | r_px | r_tiles | r_m | grav | prop | phys | phys means | time |
|---|---|---|---|---|---|---|---|---|---|
| `(none)` | 0 | 0 | 0 | 0 | 0 | stand | 0 | — | PlayOnce |
| SHOTMUSKET | 0 | 0 | 0 | 0 | 0 | immediate | 1 | — | PlayOnce |
| SHOTCANNON | 0 | PixelsToTiles(20) | 0.375 | 0.75 | 0 | slightup | 0 | grav 0 | PlayOnce |
| SHOTSHIP | 0 | (20) | 0.375 | 0.75 | 0 | slightup | 0 | grav 0 | PlayOnce |
| SHOTCANNISTER | 0 | (20) | 0.375 | 0.75 | 0 | slightup | 0 | grav 0 | PlayOnce |
| SHOTMORTAR | 0 | 0 | 0 | 0 | 0 | slightup | 0 | grav 0 | PlayOnce |
| SHOTHOWITZER | 0 | 0 | 0 | 0 | 0 | slightup | 0 | grav 0 | PlayOnce |
| SHOTMULTICANNON | 0 | 0 | 0 | 0 | 0 | slightup | 0 | grav 0 | PlayOnce |
| SHOTTOWER | 0 | (20) | 0.375 | 0.75 | 0 | slightup | 0 | grav 0 | PlayOnce |
| NUCL2P | 340 | (35) | 0.65625 | 1.3125 | 2 | angle | 10 | angle 10 | Infinite |
| NUCL2PTOW | 340 | (35) | 0.65625 | 1.3125 | 2 | fly | 38 | speed 38 | Infinite |
| NUCL2PKOR | 400 | (35) | 0.65625 | 1.3125 | 2 | fly | 38 | speed 38 | Infinite |
| NUCL3M | 800 | (60) | 1.125 | 2.25 | 5 | angle | 55 | angle 55 | Infinite |
| NUCL3MONO | 250 | (2) | 0.0375 | 0.075 | 5 | angle | 70 | angle 70 | Infinite |
| NUCL3MONONEW | 0 | (2) | 0.0375 | 0.075 | 5 | angle | 70 | angle 70 | Infinite |
| NUCL3MONONEWDMG | 500 (`{250}` alt) | (2) | 0.0375 | 0.075 | 5 | random | 1 | speed 1 | Infinite |
| NUCL3MONOEXPL | 0 | 0 | 0 | 0 | 5 | slightup | 0 | grav 0 | PlayOnce |
| NUCLGRE | 110 | (50) | 0.9375 | 1.875 | 5 | angle | 55 | angle 55 | Infinite |
| NUCLM | 100 | (50) | 0.9375 | 1.875 | 5 | slightup | 0 | grav 0 | FramesToTime(2)=0.0625 s |
| NUCLMOSKOL | 800 | (30) | 0.5625 | 1.125 | 5 | random | 4 | speed 4 | Infinite |
| STRELA | 25 | (20) | 0.375 | 0.75 | 2 | fly | 25 | speed 25 | Infinite |
| OSTRELA | 50 | (15) | 0.28125 | 0.5625 | 2 | fly | 15 | speed 15 | Infinite |
| STRELDEZ | 0 | 0 | 0 | 0 | 0 | stand | 0 | — | FramesToTime(950)=29.6875 s |
| POINT | 0 | (1) | 0.01875 | 0.0375 | 3 | random | 3 | speed 3 | Infinite |
| POINTOTVZRIV | 100 | (15) | 0.28125 | 0.5625 | 3 | randomsimulate | 3 | speed 3 | Infinite |
| POINTSTONE4 | 0 | (1) | 0.01875 | 0.0375 | 3 | slightup | 0 | grav 0 | PlayOnce |
| PPOINTT | 0 | 0 | 0 | 0 | 0 | slightup | 0 | grav 0 | PlayOnce |
| PPOINTTTOW | 0 | 0 | 0 | 0 | 0 | slightup | 0 | grav 0 | PlayOnce |
| PPOINTTKOR | 0 | 0 | 0 | 0 | 0 | slightup | 0 | grav 0 | PlayOnce |
| PSMPOINTT | 0 | 0 | 0 | 0 | 0 | slightup | 0 | grav 0 | PlayOnce |
| PSMPOINTTPUS | 0 | 0 | 0 | 0 | 0 | slightup | 0 | grav 0 | PlayOnce |
| DIMMORT1 | 0 | 0 | 0 | 0 | 5 | slightup | 0 | grav 0 | PlayOnce |
| DIMMORT2 | 0 | 0 | 0 | 0 | 5 | slightup | 0 | grav 0 | PlayOnce |
| DIMMORT2NEW | 0 | 0 | 0 | 0 | 5 | slightup | 0 | grav 0 | PlayOnce |
| PUSSTRELA | 512 | (25) | 0.46875 | 0.9375 | 0 | fly | 20 | speed 20 | FramesToTime(round(2×1.625))=FramesToTime(3)=0.09375 s |
| PUSSTRELA1 | 256 | (50) | 0.9375 | 1.875 | 0 | fly | 20 | speed 20 | FramesToTime(round(4×1.625))=FramesToTime(7)=0.21875 s (round(6.5)=6or7 by Delphi round bankers — see [U]-G1 note; literal kept verbatim) |
| PUSSTRELA2 | 128 | (75) | 1.40625 | 2.8125 | 0 | fly | 20 | speed 20 | FramesToTime(round(8×1.625))=FramesToTime(13)=0.40625 s |
| PUSSTRELA3 | 112 | (100) | 1.875 | 3.75 | 0 | fly | 20 | speed 20 | FramesToTime(round(2×1.625))=0.09375 s |
| PUSSTRELA4 | 30 | (125) | 2.34375 | 4.6875 | 0 | fly | 20 | speed 20 | FramesToTime(round(5×1.625))=FramesToTime(8)=0.25 s |
| PUSSTRELA5 | 30 | (150) | 2.8125 | 5.625 | 0 | fly | 20 | speed 20 | FramesToTime(round(10×1.625))=FramesToTime(16)=0.5 s |
| PUSSTRELA6 | 30 | (175) | 3.28125 | 6.5625 | 0 | fly | 20 | speed 20 | FramesToTime(round(15×1.625))=FramesToTime(24)=0.75 s |
| PUSSTRELAPUS | 600 | (25+10=35) | 0.65625 | 1.3125 | 0 | fly | 20 | speed 20 | FramesToTime(round(2×2.75))=FramesToTime(6)=0.1875 s (round(5.5) bankers caveat same as above) |
| PUSSTRELA1PUS | 480 | (50+15=65) | 1.21875 | 2.4375 | 0 | fly | 20 | speed 20 | FramesToTime(round(4×2.75))=FramesToTime(11)=0.34375 s |
| PUSSTRELA2PUS | 350 | (75+20=95) | 1.78125 | 3.5625 | 0 | fly | 20 | speed 20 | FramesToTime(round(8×2))=FramesToTime(16)=0.5 s |
| PUSSTRELA3PUS | 210 | (100-100=0) | 0 | 0 | 0 | fly | 20 | speed 20 | FramesToTime(round(2×0.5))=FramesToTime(1)=0.03125 s |
| PUSSTRELA4PUS | 150 | (125-100=25) | 0.46875 | 0.9375 | 0 | fly | 20 | speed 20 | FramesToTime(round(5×0.5))=FramesToTime(2or3 bankers)=0.0625/0.09375 s, literal kept |
| PUSSTRELA5PUS | 150 | (150-100=50) | 0.9375 | 1.875 | 0 | fly | 20 | speed 20 | FramesToTime(round(10×0.5))=FramesToTime(5)=0.15625 s |
| PUSSTRELA6PUS | 96 | (175-100=75) | 1.40625 | 2.8125 | 0 | fly | 20 | speed 20 | FramesToTime(round(15×0.5))=FramesToTime(8)=0.25 s (round(7.5) bankers caveat) |
| KAPEZ | 3000 | (25) | 0.46875 | 0.9375 | 2 | random1 | 9 | speed 9 (+brotate, +bcollisiondetection per :54-55) | PlayOnce |
| STRELDEZPRO | 0 | 0 | 0 | 0 | 0 | stand | 0 | — | PlayOnce |
| PUEXP | 900 | (10) | 0.1875 | 0.375 | 0 | slightup | 0 | grav 0 | PlayOnce |
| PUNOEXP | 900 | (10) | 0.1875 | 0.375 | 0 | slightup | 0 | grav 0 | PlayOnce |
| PUEXPBUILDINGDEATH | 900 | (10) | 0.1875 | 0.375 | 0 | slightup | 0 | grav 0 | PlayOnce |
| PUEXPBLD | 900 | (10) | 0.1875 | 0.375 | 0 | slightup | 0 | grav 0 | PlayOnce |
| PUNOEXPBLD | 900 | (10) | 0.1875 | 0.375 | 0 | slightup | 0 | grav 0 | PlayOnce |
| PUEXPHOWITZER | 900 | (10) | 0.1875 | 0.375 | 0 | slightup | 0 | grav 0 | PlayOnce |
| PUEXPHOWITZERBLD | 900 | (10) | 0.1875 | 0.375 | 0 | slightup | 0 | grav 0 | PlayOnce |
| PUEXPKOR | 900 | (50) | 0.9375 | 1.875 | 0 | slightup | 0 | grav 0 | PlayOnce |
| PUNOEXPKOR | 900 | (50) | 0.9375 | 1.875 | 0 | slightup | 0 | grav 0 | PlayOnce |
| PUEXPKORDEATH | 200 (`{900}` alt) | (50) | 0.9375 | 1.875 | 0 | slightup | 0 | grav 0 | PlayOnce |
| PU4GRE | 50 | (10) | 0.1875 | 0.375 | 0 | slightup | 0 | grav 0 | PlayOnce |
| SMALL | 10 | (10) | 0.1875 | 0.375 | 0 | slightup | 0 | grav 0 | PlayOnce |
| SMALL2 | 10 | (10) | 0.1875 | 0.375 | 0 | slightup | 0 | grav 0 | PlayOnce |
| SMALL2BLD | 10 | (10) | 0.1875 | 0.375 | 0 | slightup | 0 | grav 0 | PlayOnce |
| VODABUL | 10 | (10) | 0.1875 | 0.375 | 0 | slightup | 0 | grav 0 | PlayOnce |
| VODABUL2 | 10 | (10) | 0.1875 | 0.375 | 0 | slightup | 0 | grav 0 | PlayOnce |
| debrisstone | 300 | (15) | 0.28125 | 0.5625 | 3 | random1 | 9 | speed 9 (+brotate) | Infinite |
| debriswood | 300 | (15) | 0.28125 | 0.5625 | 3 | random1 | 9 | speed 9 (+brotate) | Infinite |
| SHOTBLOCKHOUSE | 0 | 0 | 0 | 0 | 0 | immediate | 1 | — | PlayOnce |
| PUEXPKORVSKOR | 900 | (50) | 0.9375 | 1.875 | 0 | slightup | 0 | grav 0 | PlayOnce |
| PUNOEXPKORVSKOR | 900 | (50) | 0.9375 | 1.875 | 0 | slightup | 0 | grav 0 | PlayOnce |
| DIMMORT2KOR | 0 | 0 | 0 | 0 | 5 | slightup | 0 | grav 0 | PlayOnce |
| PUEXPONSHIP | 900 | (10) | 0.1875 | 0.375 | 0 | slightup | 0 | grav 0 | PlayOnce |
| PPOINTTFRAME | 500 | (20) | 0.375 | 0.75 | 5 | angle | 15 | angle 15 | Infinite |
| PPOINTTFRAME5 | 0 | 0 | 0 | 0 | 0 | slightup | 0 | grav 0 | PlayOnce |
| PU4FRAMEGRE | 10 | (1) | 0.01875 | 0.0375 | 0 | slightup | 0 | grav 0 | PlayOnce |
| POINTOTVZRIVFRAME | 110 | (32) | 0.6 | 1.2 | 5 | random1 | 4 | speed 4 (+brotate) | Infinite |

`{...}` alternates and `//` comments are donor comment syntax, kept verbatim (e.g. `NUCL3MONONEWDMG 500{250}`, `PUEXPKORDEATH 200{900}` — live value is the uncommented head: 500 / 200). `round()` bankers-rounding note: Delphi `round()` rounds half-to-even; affected rows flagged above — port must call the donor `round` exactly, not `floor(x+0.5)` (`[U]`-G1 sub-point with experiment §8).

### 1.2 `objbase.protection[6]` rows — COMPLETE for all `SetObjBaseProtection` call sites `[O]` (`unit.script`)

Order is `(pike, sword, bullet, cannister, arrow, cannonball)` = kinds `(1,2,3,4,5,7)` (`unit.script:510-517`). Kinds `firearrow=6, mortarball=8, heal=9` are NEVER written by this proc → always 0 at base (upgrades can add, §1.4). Port `PROT_SLOT=[-1,0,1,2,3,4,5,5]` therefore mis-files `firearrow(6)→slot 5 (cannonball)`; donor keeps them distinct (`[I]` flag, fix in §9 item 4).

| # | unit.script line | enclosing sid case (`objprop.sid` / nation) | protection (pike,sword,bullet,cannister,arrow,cannonball) |
|---|---|---|---|
| 1 | 634 | `pikeman,pikemanpol,pikemantur,pikemanrus,pikemansco,pikemanpor,pikemanspa,pikemanswi` base | (3,2,4,210,6,40) |
| 2 | 646 | same, nation `pol` override | (0,0,0,0,0,0) |
| 3 | 653 | same, nation `tur/alg` override | (0,0,0,0,0,0) |
| 4 | 660 | same, nation `rus` override | (2,1,4,140,4,25) |
| 5 | 667 | same, nation `sco` override | (0,0,0,0,0,0) |
| 6 | 674 | same, nation `spa` override | (3,4,6,240,12,50) |
| 7 | 681 | same, nation `swi` override | (3,3,6,220,6,45) (`{7}6` live=6) |
| 8 | 688 | same, nation `por` override | (0,1,1,25,4,0) |
| 9 | 739 | `roundshier,roundshierdip,swordsmansco` base | (3,3,7,225,16,80) |
| 10 | 750 | same, nation `sco` (swordsmansco) override | (1,2,2,110,6,10) |
| 11 | 762 | same, mercenary (`bmercenary`) override | (5,3,8,225,17,80) (`{19}17` live=17) |
| 12 | 919 | `musketeeraus` (inside `musketeerspa,musketeeraus,strelet`) | (2,2,5,165,5,35) |
| 13 | 928 | `musketeerspa` | (3,2,5,210,7,40) |
| 14 | 1066 | `officer,officerrus,officertur,officersco` base | (2,2,5,200,10,30) |
| 15 | 1080 | same, nation `rus` override | (0,0,0,0,0,0) |
| 16 | 1086 | same, nation `tur` override | (0,0,0,0,0,0) |
| 17 | 1094 | same, nation `sco` override | (0,0,0,0,0,0) |
| 18 | 1366 | `wingedhussar` (inside cavalry group) | (1,2,5,160,10,30) |
| 19 | 1424 | `reiter,cuirassier,reiterswe,reiterpol,hetman,cossackdon,vityaz,cossackregister,spakh,mameluke,guardcavalrysax,lancersco,sipahi` base | (2,6,6,190,14,40) |
| 20 | 1436 | same, `reiter` re-pin (c3 add) | (2,6,6,190,15,40) |
| 21 | 1442 | same, `cuirassier` | (2,4,10,160,5,80) |
| 22 | 1449 | same, `reiterswe` | (2,3,7,140,7,35) |
| 23 | 1457 | same, `guardcavalrysax` | (2,5,9,150,9,70) |
| 24 | 1465 | same, `reiterpol` | (0,0,0,0,0,0) |
| 25 | 1474 | same, `hetman` | (0,1,3,75,3,15) |
| 26 | 1484 | same, `cossackdon` | (0,0,0,0,0,0) |
| 27 | 1493 | same, `vityaz` | (2,4,3,160,17,40) (c1 was 9/255/5, donor comments verbatim) |
| 28 | 1501 | same, `cossackregister` | (0,0,0,0,0,0) |
| 29 | 1510 | same, `spakh` | (0,1,0,10,2,0) |
| 30 | 1519 | same, `mameluke` | (1,3,1,75,8,0) |
| 31 | 1528 | same, `lancersco` | (0,0,0,0,0,0) |
| 32 | 1537 | same, `sipahi` | (3,7,4,225,24,60) |
| 33 | 1821 | wall/gate branch (`objbase.protection[cannister] := 500`) | cannister slot := 500 (single-slot overwrite `[O]`) |

No other `protection[` writes exist in `unit.script` (grep: 8 hits, all above). Sids with NO row in this table inherit whatever the base case set (e.g. `pikeman18` family, `lightinfantry` family, `musketeer` 17c family base, `archer` family, `grenadier` family, `priest` family, `peasant` family, `officer18`, `drummer*`, `dragoon*` set no protection → all-zero at base). That absence is itself donor law `[D]`: do not back-fill.

### 1.3 Per-unit `SetObjBaseWeapon` + price/HP rows (samples; full audit is mechanical) `[O]`

Donor shape `SetObjBaseWeapon(objprop, objbase, index, damage, pause_frames, radiusmin_px, radiusmax_px, detectradiusmin_px, detectradiusmax_px, kind, bSearchMinAttackRadius)`; `-1`=`default` = keep prior (`unit.script:520-546`); ranges convert px→tiles at set time; `pause` converts frames→s (`_misc_FramesToTime`). `SetObjBasePrice(objbase, food, wood, stone, gold, iron, coal)` (`:495-501`); `SetObjBaseSearchBuildVisionScore(..., searchradius_px, buildtime_frames, vision, score)` (`:571-581`); `SetObjBaseMaterialCanKill` (`:548-569`).

Exact transcribed core-infantry rows (skirmish workhorses; nation overrides marked):

- `peaaus/peatur/pearus/peapol/peaspa/peaeng/peaukr/peasco` (`:1190-1224`): maxhp 50 (ukr 75, sco 60); weapon0 `(dmg 20, pause 0, rmin 10, rmax 65{50}, detect 0/50000, kind sword)`; price `(100,0,0,0,0,0)`; search 300 (rus 500, sco 400), buildtime 400, vision 1 (rus 3, ukr 4), score 20; consume food 32 (rus 26; alg/tur 28); usage peasant; `bcapture=True` EXCEPT ukr/sco `False` (`:1214,:1219`); aiforce 1.
- `pikeman*` (`:630-691`): maxhp 90 (tur/alg 95, rus 85, sco 100, spa 100, swi 90, por 100); weapon0 base `(8, 0, 35, 100, 0, 100000, pike)`; rus `(8, dflt, 45, 90,...)`; price base `(25,0,0,3,20,0)` with per-nation overrides verbatim (§1.2 rows); search 700 (rus 800), buildtime 144 (tur/alg 176, rus 176, sco 128, por 128, swi `5*32=160`); vision 1 (sco/por 2); score 10; usage lightinfantry; `bstandground=True`; aiforce 10.
- `roundshier*` (`:735-769`): maxhp 100 (sco 180, merc 75); weapon0 `(6, 0, 25, 60, 0, 50000, sword)`; price `(20,0,0,3,25,0)`; search 600/700; buildtime 128/224/48; vision 1/2; score 7/1; protection §1.2 rows 9-11; merc `consume gold 20`, `bnohungry+bmercenary=True`, costpercent unset (archer-merc 100.5 only).
- `musketeer*17c` (`:771-896`): maxhp 70 base; weapon index **1** `(12, 150, 400, 800, 0, 100000, bullet)` + `weaponsid=SHOTMUSKET`, iron 2 coal 4, `addradius=PixelsToTiles(32)`; per-sid overrides verbatim (`:788-895`, e.g. `pandur` dmg 17 pause 150 rmax 900 price `(40,0,0,15,10,0)` buildtime `5.5*32` aiforce 25; `chasseur` dmg 20 pause 190 rmin 500 rmax 1050 buildtime `7.5*32`; full list in file, no invention here).
- `musketeerspa/musketeeraus/strelet` (`:898-940`): weapon index **0** `(9, 90, 400, 800, 0, 100000, bullet)`; aus `(12, 160, 400, 800, ...)` + prot row 12; spa `(15, 190, 400, 850, ...)` + prot row 13.
- `archer*` (`:997-1061`): maxhp 40; weapon0 `(15, 75, 400, 800, 0, 100000, arrow)` + `weaponsid=STRELA`, `dispertion=PixelsToTiles(175)`, wood 1; weapon1 `(150, 125, 400, 600, 0, 100000, firearrow)` + `weaponsid=OSTRELA`, `dispertion=PixelsToTiles(200)`, attmask += building|wood|woodwall; tur `(20, 85, 300, 900)` disp 100; sco `(20, 100, 250, 1000)` disp 150; merc `(25, 80, 350, 700)` + fire `(100, 25, 300, 750)`, gold 16.
- `officer*` (`:1062-1098`): weapon0 `(30, 0, 35, 65, 0, 100000, pike)`; price `(50,0,0,150,30,0)`; consume gold 60; protection §1.2 row 14 (nation overrides zero it).
- `priest/pope/mullah/padre` (`:1151-1188`): weapon0 kind **heal** `(20, 0, 0, 400, 0, 70000, heal)` (pope 25/r350, mullah 15/r500, padre 30/r400); price `(60,0,0,25,0,0)`; consume gold 20 (mullah 15, padre 40).
- `grenadier*` (`:1226-1318`): weapon0 `(18, 0, 25, 80, 0, 400, pike)`; weapon1 `(16, 170, 400, 900, 400, 50000, bullet)`; weapon2 `(110, 75, 200, 500, 0, 50000, mortarball)` + `weaponsid=NUCLGRE`, `dispertion=PixelsToTiles(250)`, attmask += building|wood|woodwall; consume food `floor(30*1.2)=36`.
- Cavalry base + `reiter` group + `dragoon` group: §1.2 rows 18-32 + weapon/price lines `:1320-1584` verbatim (reiter base `(15, 0, 20, 65, 0, 100000, pike)` price `(120,0,0,10,40,0)`; hetman dmg 70 gold-consume 200; dragoon base `(15, 180, 300, 800, 0, 100000, bullet)` `SHOTMUSKET` iron 2 coal 4).

REMAINING per-sid audit (ships, artillery, buildings, walls, 18c musketeers/pikemen variants, merc overrides): mechanical grep of `case objprop.sid of` branches in `unit.script:627-~2600` + `classes.script` — no binary needed. Every row cites `unit.script:<line>`; zero-fill is donor law where no row exists.

### 1.4 Protection upgrades `[O]` (`player.script:1711,1790-1798`; `country.script:2059-2206` samples)

- Upgrade type `gc_upg_type_protection=4` (`dmscript.global:741`); on apply: `gPlayer[pl].objbase[cid][iarr2[j]].protection[kind] += round(value)` (`player.script:1798`) — additive integer, per-kind.
- Sample upgrade rows (all `blacksmith`, kinds `pike,sword,arrow` unless noted): `:2059` value 2 cost `(500,0,2 / 11250,0,0,1500)`; `:2065/:2071/:2077/:2083` value 3 cost `(500,0,2 / 15000-16875,0,0,1000-2250)`; `:2095/:2101/:2108` values 1/2/2; `:2131-2133` defence chain values 1/1/2. Full table is a mechanical read of `country.script:2050-2210` — cite-or-tag per row.

---

## 2. T2 — damage application function: RESOLVED `[O]` (`miscext2.script:274-465`)

`_misc_DoDamage(goHnd, trgHnd, indamage, weapind, weapkind)` — verbatim order:

1. Guards: `trgHnd=0` → exit; dead target → exit; scenario-infinite-hp / non-playable → exit (`:278-286`).
2. `bProcessLogic := ((not _net_IsReplay) and _net_IsOffline) or _net_IsServer or _net_IsRecord` (`:292`); singleplayer offline ⇒ true.
3. Peacetime (`:294-326`): if `gbool_peacemode`: both-sides-own-territory check via `_unit_IsOnEnemyTerritory`; non-enemy-territory attacker takes `hp:=0` (`bSkipOnDeath`); mutual-enemy-territory sets `bPeaceSkip:=False`, else skip.
4. Base `damage := indamage` (`:332`).
5. Headshot eligibility (`:334`): `bCanHeadShot := (kind=arrow or kind=bullet) and (not target.bbuilding)`.
6. Fast-horse bullet (`:335-337`): if eligible + target usage `fasthorse` + target has `move_walk` tag → `damage -= 5`.
7. Shield (`:339-342`): built target `damage -= shield`, else `damage -= shield div 3` (integer div). No shield row values recovered this ticket (objbase.shield set in `classes.script`/upgrades — cite-or-tag; port must not invent).
8. Squad hold bonus (`:343-355`): defender squad `fHoldMode ? fAddShieldHold : fAddShield` subtracted.
9. Alarm (`:362-366`): non-priest attacker, either side is interface-IO player → `_misc_DoAlarm`.
10. Priest branch: attacker `bpriest` → **heal path, protection skipped**: `damage := indamage; target.hp += damage` capped at `maxhp`; process-logic variant also clears orders at cap (`:371-377`, `:388-399`).
11. Non-priest, non-process-logic (replay/client preview) (`:378-384`): `damage -= protection[weapkind]`; `if damage<1 → 1`; if `damage < target.hp` → `hp -= damage` (else no kill — non-critical preview path).
12. Non-priest, process-logic (real sim) (`:400-464`): squad bonus `damage += (fHoldMode ? fAddDamageHold : fAddDamage)` for squad members with `weapkind≠firearrow` (`:421-433`); `damage -= protection[weapkind]` (`:434`); headshot (`:420`): `bHeadShot := bCanHeadShot and (random<0.05) and (not bFastHorseBullet)` → `damage += floor(uniqrnd*500)`; `if damage<1 → 1` (`:439`); `hp -= damage` (`:440`); on `hp<=0`: killer `score += 2×target.score`, inside-units `+3×` each, `kill += 1` (`:443-464`).
13. Wall splash (`miscext2.script:240-256` `[O]`): `gc_wall_damage_kill/del` on hard/weak-wall usages — engine call, port keeps as labelled hook.

Net formula (process-logic, non-priest): `dealt = max(1, indamage − (built? shield : shield÷3) − defenderHoldShield + attackerHoldDamage + (headshot ? floor(uniqrnd×500) : 0) − protection[weapkind] − (fasthorse-bullet ? 5 : 0))`. No height/dispersion/height-bonus term exists anywhere in this function — port height ×1.25 stays PORT EXTENSION until shot-path grep lands (`[U]`-D1 experiment §9-D1).

---

## 3. C1 — capture majority / cooldown tail: RESOLVED `[O]` (`miscext.script:963-1185`)

Head (already in DEC-U-SKIRMISH §2.3, re-pinned): cadence `gc_unit_TimeCheckCapture = 0.1*19−eps = 1.875 s`, art `0.1*5−eps = 0.475 s` (`dmscript.global:1476,1479-1480`, eps `0.025`); jitter init `random*TimeCheckCapture` (`miscext2.script:2757`, `serial.script:870`, `building.inc/initial.inc:390`, `unit.inc/initial.inc:320`); radii `capture 214/px = 4.0125 tiles = 8.025 m`, `blockshot 160/px = 3.0 tiles = 6.0 m`, `protection 426/px = 7.9875 tiles = 15.975 m` (`dmscript.global:207-209,217-219` — units are TILES, `gc_pixels_to_tile=53.3333333`; the "≈4.01 m" in DEC-U-SKIRMISH §2.3 is tiles, corrected here `[D]`).

- Cadence call sites `[O]`: building-unbuilt: always `_misc_CheckCapture` (`building.inc/nothing.inc:298-304`); building-built + `bcapture`: gated by `gMap.settings.additional.capture` (`:311-326`): `default/nopeasants → check`; `nocenterspeasants → skip center`; `onlyartillery → (empty: NO check)`; unit + `bcapture` + playable (`unit.inc/nothing.inc:507-535`): non-art always due at own cadence; art due at art cadence; `default → (check if default OR bart)`; `onlyartillery → (check iff bart)`; the `nopeasants/nocenterspeasants` commented block (`:520-534`) is dead — do not port.
- Map modes `[O]` (`dmscript.global:1072-1075`): `default=0, nopeasants=1, nocenterspeasants=2, onlyartillery=3`.
- Capturer filter `[O]` (`miscext.script:1001-1028`): enemy-mask cells in `floor(capture/scangrid)+1`; walls use `_unit_SearchCapturersForWall`, else `_unit_SearchCapturers`; skip iff `bcapture or media=water` (walls: no skip); require `distSqr < captureSqr`; `distSqr < blockshotSqr → bblockshot=True`; count `capturerCount`, keep last `capturerHnd`.
- Non-peasant + blockshot ⇒ 100-frame lock (`100*gc_frames_to_time = 3.125 s`) (`:1036-1040`).
- Protector scan `[O]` (`:1041-1072`): radius `protection`; own-mask cells; `_unit_SearchProtectors`; skip `bcapture` protectors; `distSqr < protectionSqr` ⇒ **`bcapture := False`** (ANY single protector vetoes — no count comparison for the general case) + `protectorsCount += 1`.
- AI-artillery suicide rule `[O]` (`:1073-1088`): only if owner `bAI` + target `bartillery`: `(protectors=1 and capturers>=protectors) or (protectors=2 and capturers>3) or (protectors=3 and capturers>7) or (protectors=4 and capturers>10)` → if `not bEasy or random>0.5` → `essential_death`, exit. `bEasy := aidifficulty < veryhard` (`:1031`).
- Birth/hide gate `[O]` (`:1093-1099`): non-building + `essential_birth` + visible-hide-unset → `essential_death`, exit (goes to mine/sto-clear error otherwise).
- Change-player `[O]` (`:1100-1182`): production orders flushed via `_unit_ProduceUnit` (`:1116-1127`); wall + `bAutoKill(uninit False)` or `bwall` → `bDie=True`; else `_unit_ClearOrders + SetSTO 0`; `newPl = capturerHnd` owner; IO-party alarm; **AI die rolls** — owner-AI: building `random>0.25 → bDie` (else slow-death `hp := 1999 − floor(RandomExt×300)` if `bbuilt+bslowdeath`, `gc_BuildingSlowDeathHP=1999/Random=300` per `dmscript.global:129-130`); non-building: `peasant + not bEasy → bDie`; `supermortar random>0.46875×1.25=0.5859375 → bDie`; `cannon random>0.3125×1.25=0.390625 → bDie`; `mortar random>0.125×1.125=0.140625 → bDie`; `peasant random>0.546875 → bDie`; victim-human + peasant + capturer-AI + not-easy → `bDie`; `bDie ? essential_death : _misc_ChangePlayer(go, newPl, True, False, True)`.
- NO post-capture cooldown exists in this function — cooldown tail is confirmed ABSENT `[D]` (only cadence `lasttimecheckcapture` gates re-checks). Port `capture_t` accumulation stays PORT APPROXIMATION; replace with `lasttimecheckcapture` semantics.

---

## 4. S — start 6-resource tables: RESOLVED `[O]` (`startingsettings.cfg:87-858`; dispatch `dogenerate.inc:230-396`)

### 4.1 Top-level `addresources` per `startid` (live when `dataversion 60-1000`; old-version duplicates `:860+` ignored for current data)

| startid (mapsettings key) | food | wood | stone | gold | iron | coal |
|---|---|---|---|---|---|---|
| −1 example (`:89-97`) | 0 | 0 | 0 | 0 | 0 | 0 |
| 0 default (`:183-184`) | — (no block: no resources, no units) | — | — | — | — | — |
| 1 armysmall (`:190-197`) | 1000 | 0 | 0 | 0 | 0 | 0 |
| 2 armymedium (`:317-324`) | 20000 | 0 | 0 | 0 | 0 | 0 |
| 3 armylarge (`:506-513`) | 20000 | 0 | 0 | 0 | 6000 | 9000 |
| 4 peasantslot (`:723-730`) | 20000 | 0 | 0 | 0 | 6000 | 9000 |
| 4 tur/alg country-override (`:820-827`) | (empty=0) | (empty=0) | (empty=0) | 1000 | (empty=0) | (empty=0) |

Double-add policy `[O]` (`dogenerate.inc:255-292`): on match, top-level `addresources` is added once (`:256-264`), then the SAME top-level node (`pCountryAddResources := select(pStartingSetting,'addresources')`, `:283`) is added AGAIN per matched country (`:284-292`) unless `bOnlyModifyPatternMask`. Net effect for a matched player: **2× the table above** (plus the tur/alg country-override `+1000 gold` in startid 4). This is the X09-7 quirk, confirmed verbatim — port must implement the double add, not "fix" it.

### 4.2 Role→unit mapping `[O]` (`dogenerate.inc:293-377`)

Per legend entry: `key` (mask char), `role` int, `countrysid`, `basename`. If `countrysid≠''` use that country else player country; if `role>0` → `unitid := _country_GetMemberIDByAIRole(countryid, role)`; elif `basename≠''` → `unitid := _unit_ConvertObjSIDToID(countryid, basename)`; then one `CreateUnit(plind, countryid, unitid, x, z, dir=-90)` per mask cell (`x = lx+n*unitradius, z = ty+m*unitradius`, `unitradius = gc_obj_radius_default*tiles_to_pixels*4`, `dir=-90`) (`:330-376`); `bOnlyModifyPatternMask=True` path only stamps pattern circles (r=5 buildings, 1 otherwise) (`:366-374`). First matching `allowedcountries` entry wins (`break(ALLOWEDCOUNTRIES)`, `:385`).

Role numbers are AI-roles (§1.0): `X→role 1 = peasant`; `O→21 = officer17`; `B→22 = drummer17`; `P→23/25/26/34 = infantry17 / musk17 / reitar / archer` per group; `Q→basename misblg`, `W→misblg2` (role empty).

### 4.3 Masks verbatim `[O]` (counts exact; P-counts derived by counting `P` chars — no invention)

- startid 1, default-country group (`:260-268`): O2 B2; P72 (rows: 12+12+12+12+12+12); X30; Q1 W1. ukr group (`:300-308`): P48 (6 rows×8: `PPPP..XXXXXX..PPPP` = 8 P, 4 X per row ×6 rows = P48 X24); Q1 W1.
- startid 2, default group (`:373-380`): P96 (6 rows × `PPPPPPPP..XXXXXX..PPPPPPPP` = 16 P, 6 X → P96 X36). alg (`:412-419`): P168 (6×28, X36). tur (`:451-458`): P180 (6×30, X36). ukr (`:490-497`): P108 (6×18, X36).
- startid 3, default group (`:574-581`): O6 B3 (rows 1+7 patterns); P72 (6 rows × `PPPPPP..PPPPPP` = 12); X18. pol (`:626-634`): O2 B2, P72, X30. ukr (`:666-673`): P72, X36. alg (`:705-714`): P112 (rows: 26+27×6+27=26+162+... verbatim strings kept; count from strings, do not estimate).
- startid 4, default group (`:773-780`): X96 (6 rows ×16, no P — peasantslot spawns centre+peasants via mask X…). ukr (`:806-813`): X96. tur/alg (`:848-855`): X96 + country gold override §4.1.
- `dataversionmin=60/max=1000` on startids 1-4; startid 0 has no block (default = nothing). Old dataversion 0-59 duplicates (`:860+`) are inert for current data — do not port.

Peasant传奇 per-group role values: startid 1 default `P=23` ukr `P=25`; startid 2 default/alg/tur/ukr `P=26`; startid 3 default/pol `P=25` ukr `P=25` alg `P=34`; startid 4 default no P legend. Officer/drummer legends only in startid 1 default/old + startid 3 default/pol groups.

---

## 5. A1 — AI thresholds: recovered literals `[O]` + labelled remainder

- Disband `[O]` (`progress.inc:5-35`, `dmscript.global:156`): `if count < basecount*0.25 → _misc_DisbandSquad`. `gc_player_SquadDismissPercent = 0.25`.
- Hold-mode `[O]` (`progress.inc:156-172`, `dmscript.global:180`): stand-ground + not-hold + not-aggressive + moveCount 0 + has hold bonuses differing → `fHoldModeProgress += dt/37.5` (`150*8*0.03125`); `>=1 → fHoldMode=True`.
- Guard sampler `[O]` (`unit.script:3638-3668`, `dmscript.global:500` `gc_ai_max_guards=120`): AI-owner hardhorse/shooter/grenadier: `guardsCount>0 and guards<120 → defenders else agressors`; non-AI shooter/grenadier: `guards<120 and RandomExt<RandToRandom(3000) → defenders`; priest or (`freewarriors>15 and guards>120`) → agressors; else AI: `RandomExt<RandToRandom(10000) and freewarriors<20 → freewarriors`; elif `RandomExt<RandToRandom(6000) and guards<120 → defenders`; else agressors; non-AI lightinfantry: `guards<120 and RandomExt<RandToRandom(20000) → defenders`. `_misc_RandToRandom(v) = v/32768` (`misc.script:486-490`), so thresholds are P = 3000/32768 ≈ 9.16%, 6000 ≈ 18.31%, 10000 ≈ 30.52%, 20000 ≈ 61.04%.
- Fear selector `[O]` (`progresswarai.inc:2798-2832`): `myForce = squad0 count`; per enemy army with `landCount>0`: `enForce = cavalry + infantry + shooters` (mortars commented out); `dist<30 and enForce>myForce → fear=True`; elif `dist<400 and enForce<=myForce and dist<nearDist → track nearest`; `not fear and nearDist<MaxInt → _unit_SearchEnemyInCell(go, enX, enY, 4)`.
- `maxpeasants` 5/2, repair +20, gather 22/14/20, delivery-radius split, max-attackers 4/3/2/3, `resource_maxattackers` (`dmscript.global:210-211,222-224`; `res.script:348-358`; `unit.script:9098-9104`): already in DEC-U-SKIRMISH §2.11 — not re-transcribed, cited.
- Everything else (build order, cheat, famine-recall, war-AI beyond fear head): still `[U]`-A1 — label PORT-AI (experiment §9-A1).

---

## 6. R1 — save contract framing `[O-shape]` + still-`[U]` bytes

- 40 write/read pairs present `[O]` (sizes bytes): `writeplayer/readplayer` (1133/942), `writesync/readsync` (5272/5951), `writewall/readwall` (11393/10116), `writeproj/readproj` (3368/2766), `writesquadnew/readsquadnew` (7145/4456), `writeorder/readorder` (2997/7294), `writemove/readmove` (7441/3069), `writedeath/readdeath` (5220/3489), `writeupgrade/readupgrade` (7251/3540), `writetrade/readtrade` + `writetraderesources/readtraderesources`, `writepeacetime/readpeacetime` (1478/1423), `writeconstruct/readconstruct`, `writeproduce/readproduce`, `writegate/readgate`, `writestop/readstop`, `writestand/readstand`, `writerally/readrally`, `writesearch/readsearch`, `writepackage/readpackage`, `writeapply/readapply`, `writefree/readfree`, `writefreelist/readfreelist`, `writeleave/readleave`, `writeleaveorder/readleaveorder`, `writesyncunitsparams/reads…`, `writesquadlistaction/reads…` (full listing `data/scripts/units/global.inc/*.inc` P11).
- Squad record `[O]` (`serial.script:1035-1036/1106-1107/1178-1179/1246-1247`): `fBaseCount Integer + fStandGround Boolean` round-trip with size/skip accounting.
- Respawn/reset `[O]` (`serial.script:870`): `lasttimecheckcapture := random*TimeCheckCapture` on init; res sync `res/lanres/setres` (`:99-197,526-529,2206-2207`); `objbase.speed := 1` reset (`:516`).
- Byte framing (`[*] =` engine-bound lines): still `[U]`-R1 — port save stays PORT EXTENSION with explicit non-parity contract (experiment §9-R1).

---

## 7. O1 — global tick interleave: head RESOLVED `[O]` (`progress.inc:37-185`)

- Per-plInd Progress state runs for the CURRENT player handle (`GetPlayerCurrentPlHandle`, `:37-38`); client/replay global does not progress (`:46-49`).
- Exists stagger `[O]` (`:56-61`, `dmscript.global:1484` `gc_global_TimeCheckExists = 0.01*200 = 2.0 s`): `addtime = 0.125*plInd + (bexists ? 4×2.0=8.0 s : 12×2.0=24.0 s)`; `_player_CheckProgressLastTimeAndIncrease(lastcheckexists, 0, addtime)` gates the exists block.
- Exists rule `[O]` (`:63-141`): `bbattle → bexists=True`; else if `0<farmused<100`: scan peasant section for `visual_none+essential_none` (or human-owned `insideofuid≠0`) else scan building section for built `usage=center`; else `bexists := farmused>0`. Lose path: `not bexists and (bAI or human)` → `_misc_KillPlayerUnits`, first transition stamps `victorystate=lose + victorystategametime=GetGameTime + LanServerSendResults` (`:124-135`); battle-mode exempt from kill.
- Per-tick slice order `[O]` (`:144-181`): exists-check → (if `plind<MaxPlayerCount-1=11`) `_player_ProcessResourceIncome → _player_ProcessResourceConsume` → (non-AI) `CalcSquadsMoveCount` gated by `(0.001*plInd)+gc_global_TimeCalcSquadsMoveCount (0.03*10=0.3 s)` → squad hold-progress loop → (non-AI) `CheckSquadsDisband` → (bexists and (bAI or adviser-enabled)) `ExecuteState('ProgressAI')` → `progresstick += 1; lastprogresstime := GetGameTime`.
- Still `[U]`-O1: how the engine iterates plInd over frames (all-players-per-frame vs staggered current-player), and where separation/projectiles/AI-substates interleave — freeze `TICK_ORDER v1` PORT APPROXIMATION + fixed-seed hash test (experiment §9-O1).

---

## 8. G1 — RNG draw ledger `[O]` + still-`[U]` streams

- `GetRandom(n) = floor(RandomExt*n)` (`dogenerate.inc:990-997`); `GetRandomRange(min,max) = min+floor(RandomExt*(max-min+1))`.
- Identity reseeds `[O]` (cited DEC-U-SKIRMISH §2.10): `SetRandomKey(gMap.settings.gen.randkey1)` + discard `RandomExt` at `dogenerate.inc:1100-1102,1161-1164,1177-1182,1213-1216,1538,1616,1772,1909,1927`, `initmapgen.inc:99`, `generatemap.inc:216,513,774`; `SetRandomExtKey64(randkey0,randkey1)` at `generatemap.inc:216,513,774`. `SetRandomKey` sites double as team/point shuffles (`GetRandom(teamlist/points)` `:1104,1164,1182,1216`).
- Sim draws recovered this ticket `[O]`: famine/rebellion `RandomInt=floor(random*32768)` (`misc.script:493-498`); capture AI `random>0.5 / 0.25 / die-rolls` (`miscext.script:1082,1147-1173`); slow-death `floor(RandomExt*300)` (`miscext.script:1152`, `readdeath.inc:51`, `writedeath.inc:57`); guard sampler §5; fear none (no draw); damage headshot `random<0.05` + `floor(uniqrnd*500)` (`miscext2.script:420,437` — `uniqrnd` is per-unit, not a draw); mine-position `floor` draws (`progresseconomicai.inc:78,3142`); war-AI scatter `floor(RandomExt*(max+1-min))`, `4096/32768` gate (`progresswarai.inc:1749-1750,2681`); mapgen `dispx/angle/dst` family (`dogenerate.inc:87-966`), `loadenvironmentfrombitmap 0.25` gates, `initmapgen cid := floor(RandomExt*(maxCountryCount-1))`.
- Still `[U]`-G1: Delphi `random()` second instance vs `RandomExt` LCG per-site attribution; `round()` bankers behaviour in PUSSTRELA time literals; exact per-frame draw ORDER for deterministic replay — X21 20-vector fixture + per-site draw-count test (experiment §9-G1).

---

## 9. Still-`[U]` register (each with exact settling experiment; no approximation)

| # | Item | Static state after this ticket | Exact experiment (owner-authorised) |
|---|---|---|---|
| T1-tail | Remaining per-sid rows (ships/artillery/buildings/walls/18c variants, shield values, consume rows) | Shapes + core-infantry/cavalry rows §1; data.gd prot zeros = placeholders | Mechanical grep: `case objprop.sid of` in `unit.script:627-~2600` + `classes.script` objbase defaults; every row cite-or-tag vs `data.gd:UNITS_BASE`; zero-fill stays where donor absent. No binary needed. |
| D1 | Dispersion/height bonus | No term in `_misc_DoDamage`; archer `dispertion` px literals §1.3 `[O]` | Grep `dispertion|height|hill` in `unit.script` shot fns (~8100-8360) + `tow/wal/gat` kind gates; runtime: fixed-range volley σ + height-differential pairs. Delete port ×1.25 until then. |
| Q1 | Train/research timing + queue caps | Only maxpeasants 5/2 + buildtime frames literals | Read `player.script` producer fns (`CreateConstructionDummy`, train/research cost-time, `artlimit/artcount`); runtime queue-length sweep; batch-5/100 provenance (likely PORT EXTENSION — delete if absent). |
| G1-tail | `round()` bankers + draw order | Literals kept verbatim §1.1 | X21 20-vector fixture + per-site draw-count test; assert `floor(RandomExt*n)` at every sim draw; test `round(6.5/5.5/7.5)` Delphi semantics for PUSSTRELA time rows. |
| A1-tail | AI build order / cheat / recall | Sampler + fear + disband + hold grounded §5 | Read `progresswarai.inc:2799-2832` continuation + `progresseconomicai.inc` build order; label rest PORT-AI. |
| R1 | Save byte framing | Field lists enumerable §6 | Enumerate `write*.inc/read*.inc` field order per record; declare save PORT EXTENSION + full-state round-trip test (RNG states, queues, cooldowns, projectiles, corpses, stamps). |
| V1/V2/F1/E1 | FOV/selection/fog/delivery | Unchanged from DEC-U-SKIRMISH §3 | Per DEC-U-SKIRMISH §3 experiments (sensor-width solve, Ghidra+GL trace, `fogreveal` grep, call-site split `unit.script:9704/12032`). |
| O1-tail | Engine plInd iteration | Per-player slice §7 grounded | Recover Progress-state driver (who sets CurrentPlHandle per frame) + `nothing.inc` progresstick cadence; freeze `TICK_ORDER v1` + fixed-seed hash meanwhile. |
| C1-closed | — | RESOLVED §3 (no tail remains) | None. Port implements §3 verbatim; `capture_t` replaced by `lasttimecheckcapture`. |
| T2-closed | — | RESOLVED §2 (no tail remains) | None. Port implements §2 formula; shield rows cite-or-tag; height/dispersion stay `[U]`-D1. |
| S-closed | — | RESOLVED §4 (no tail remains) | None. Port implements double-add + role map + verbatim masks; nation→member resolution via `_country_GetMemberIDByAIRole` at runtime (no static sid list invented). |

---

## 10. Concrete port change list (owner/COORD applies; this worker wrote no code)

All items add DONOR-VERBATIM values or explicitly labelled placeholders. None invents a number. None touches save version number, existing keys, demo-mill/builder-stands hooks, or I11 seam paths.

1. **`data.gd:UNITS_BASE` prot columns** — fill from §1.2 table row-for-row: pikeman-base `[3,2,4,210,6,40]`, rus `[2,1,4,140,4,25]`, spa `[3,4,6,240,12,50]`, swi `[3,3,6,220,6,45]`, por `[0,1,1,25,4,0]`, roundshier `[3,3,7,225,16,80]`, swordsmansco `[1,2,2,110,6,10]`, roundshier-merc `[5,3,8,225,17,80]`, musketeeraus `[2,2,5,165,5,35]`, musketeerspa `[3,2,5,210,7,40]`, officer `[2,2,5,200,10,30]`, wingedhussar `[1,2,5,160,10,30]`, reiter-base `[2,6,6,190,14,40]` / reiter `[2,6,6,190,15,40]`, cuirassier `[2,4,10,160,5,80]`, reiterswe `[2,3,7,140,7,35]`, guardcavalrysax `[2,5,9,150,9,70]`, hetman `[0,1,3,75,3,15]`, vityaz `[2,4,3,160,17,40]`, spakh `[0,1,0,10,2,0]`, mameluke `[1,3,1,75,8,0]`, sipahi `[3,7,4,225,24,60]`; all other sids keep donor-absent zero (do NOT copy neighbour rows). Nation overrides keyed by trailing nation token (`pol/tur/alg/rus/sco/spa/swi/por`), merc overrides gated by `bmercenary`. Zero-fill rows stay until T1-tail audit cites them.
2. **`data.gd` weapon prototype table (new const, e.g. `DONOR_WEAPON_PROTOS`)** — transcribe §1.1 verbatim: sid → `{damage, radius_tiles, gravity, propagation, physvalue, time}` with `radius_tiles = px/53.3333333` computed from the DONOR px literal (keep px literal in comment). `round()` time rows keep the DONOR EXPRESSION (`round(2*1.625)` etc.), never a pre-rounded float; add `[U]`-G1 comment on bankers-rounding.
3. **`data.gd`/`game.gd` damage path** — implement §2 formula verbatim: shield÷3 unbuilt, squad hold add/subtract, priest heal-skip-protection, `max(1,·)`, headshot `random<0.05 + floor(uniqrnd*500)`, fasthorse-bullet −5, score/kill accounting. Tower/wall kind gate (`game.gd:6034`) stays `[U]`-U3 labelled. Height ×1.25 / non-archer dispersions / `dist/30` flights / 0.45 s arrow / cap-512 / 2.0 s deploy stay APPROXIMATION-tagged (`[U]`-D1/Q1).
4. **`game.gd` capture** — implement §3 verbatim: `lasttimecheckcapture` cadence (1.875 s / 0.475 s art, jitter `random*interval` at spawn), tile-unit radii (214/160/426 ÷ 53.3333333), enemy-cell scan, capturer filter, 100-frame blockshot lock, ANY-protector veto, AI-artillery majority table, AI die rolls (0.25 / 0.5859375 / 0.390625 / 0.140625 / 0.546875 + peasant rules), slow-death `(1999, 300)`, map-mode gate (incl. onlyartillery = no building checks), birth/hide gate, production-flush + `_misc_ChangePlayer(go,newPl,True,False,True)`. Delete `capture_t` accumulation or rewire it to `lasttimecheckcapture` semantics; NO post-capture cooldown (confirmed absent). Protector kinds: skip `bcapture` only (no usage filter on protectors).
5. **`PROT_SLOT` firearrow fix** — donor `protection[6]` (firearrow) exists and is always 0 at base; port collapses kind 7→slot 5 correctly for cannonball but kind 6→slot 5 WRONGLY merges firearrow into cannonball. Add slot: either extend `prot` arrays to 7 with index mapping `[I]`-labelled, or document `firearrow → 0 always` explicitly. Do not silently keep the merge.
6. **Starts (`game.gd:3030-3151`, `data.gd:278-306`)** — implement §4 verbatim: startid match + dataversion 60-1000 gate + DOUBLE resource add (top-level block twice) + first-`allowedcountries` match + legend/mask spawn (`dir=-90`, unitradius formula). Role map §1.0. Masks verbatim strings from file (copy, don't retype counts). tur/alg startid-4 `+1000 gold` country override. `START_PEASANTS=8` deleted as fallback only where masks give no P legend; `MAX_PLAYERS=12` stays (donor `gc_MaxPlayerCount=12` `:97` — grounded, not extension).
7. **AI (`ai.gd`)** — wire §5 literals only (0.25 disband, 37.5 s hold, 120 guard cap, 3000/6000/10000/20000 sampler, 15/20 freewarrior gates, fear 30/400 force/dist rule). Rest stays PORT-AI labelled.
8. **Tick (`game.gd` tick)** — implement §7 slice order (exists → income → consume → move-count → hold → disband → ProgressAI → progresstick) with stagger `0.125*plInd + 8.0/24.0 s` gating the EXISTS block only; freeze surrounding stage order as `TICK_ORDER v1` PORT APPROXIMATION + fixed-seed hash test.
9. **Save (`game.gd:6304-6401` serialize v5)** — ADD keys only (`rebellion`, `upkeep_remains`, `resonlife`, `market_cost`, `income_remains`, `cap_check_t`→ rename to `lasttimecheckcapture`, `eliminated`, `victorystate`, `lose_t`/`victorystategametime`, `progresstick`, `lastprogresstime/lastcheckexists`, `uniqrnd`, squad `fBaseCount/fStandGround/fHoldMode(Progress)`); never remove/rename existing v5 keys; never bump version; old saves deserialize (missing keys default). Byte-parity NOT claimed — contract declares PORT EXTENSION + round-trip determinism test. `deserialize` v3 path needs proof test or removal (unchanged).
10. **RNG (`game.gd` rng)** — route every §8 sim draw through `floor(RandomExt*n)` wrapper; keep identity reseeds (already landed per IMPL-PATCH Patch 5); keep `gen_rng` state in save; `brng`/extra streams deleted from sim; `round()` call sites use donor-semantics wrapper with `[U]`-G1 tag until bankers behaviour is proven.
11. **Upgrades** — protection upgrades `+= round(value)` per kind (§1.4); sample blacksmith rows cite-or-tag; full `country.script:2050-2210` audit before wiring values.
12. **Telemetry/format** — every value above carries `file:line` cite in comment; every remaining zero/estimate keeps `PORT APPROXIMATION` + `[U]` tag with its §9 experiment; `visual_parity_claim=false`; unresolved list = [T1-tail, D1, Q1, G1-tail, A1-tail, R1, V1, V2, F1, E1, O1-tail]. C1/T2/S are CLOSED by this ticket (no tail).

---

## 11. Explicit non-claims and file discipline

- NO PARITY CLAIM. No donor binary executed, no donor GPU frame captured, no port capture compared. Closed items (T2, C1, S, plus T1 weapon/prot rows, A1-head, O1-head, G1-head) rest on donor TEXT `[O]` with file:line; open items list exact next reads/captures in §9.
- No approximation substituted for a resolved law. The two `[I]` flags (PROT_SLOT firearrow merge; `bcd`=default-cost reading in prior market patch — untouched here) are labelled, not asserted.
- Read-only compliance: exactly one repo file written (this report). Native/script passes were pinned reads against `t_87f0f3c130b0`; shared investigation memory was read, never written; no target opened/selected/closed by this worker.
- `round()` bankers caveat and tile-vs-metre correction (§3) are disclosed, not smoothed over.

*End of DEC-U-SKIRMISH-TABLES.*
