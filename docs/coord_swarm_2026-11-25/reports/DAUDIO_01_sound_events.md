---
id: DAUDIO-01
title: Donor sound event→file mapping and selection/order audio truth
area: donor / decompilation / audio deep-dive
owner: DAUDIO-01 (donor deep-dive micro-worker)
date: 2026-11-25
status: COMPLETE — documentation only; no code edits, no runner jobs, no donor copies
donor: "C:\Games\Cossacks 3 (READ-ONLY; Python 3.14 bytes/latin-1; no donor executable run or copied)"
method: "2 passes: (A) fresh read of sound config/.snd manifests/script sound definitions with path:line, (B) raw-byte finders on cossacks.exe + third cross-check of prior docs and port read-only"
labels: "observed / derived / inferred / UNVERIFIED; key claims verified twice"
scope_note: "read-only comparison to variant3d/scripts/audio.gd and app/scripts/audio.gd; no code changed"
---

# DAUDIO-01 — donor sound event→file mapping and selection/order audio truth

## 0. Goal and guardrails

Build a **complete** donor event→file table from freshly read donor data, document
positional/emitter semantics, verify against `cossacks.exe` raw bytes, and compare
read-only to the port. Every row cites donor `path:line`. Donor is private-use,
read-only, never executed or copied; only this report was written.

Label convention: **observed** = literal bytes/text; **derived** = arithmetic or
control flow following from observed text; **inferred** = strong but indirect;
**UNVERIFIED** = absent or not provable from read-only data.

---

## 1. Sources

### Prior docs read first (all read-only)
| # | Source | Used for |
|---|---|---|
| P1 | `docs/coord_swarm_2026-11-25/decomp/DEC_04_anim_formats.md` §8 | 325/325 Ogg census, `.snd`/`.slc` container decode, 247+51+27 path reconciliation |
| P2 | `docs/coord_swarm_2026-11-25/decomp/DEC_02_scripts.md` §3, D-14 | 222-script corpus, `sound.script` role, sound-grid constants, encoding |
| P3 | `docs/decomp/DE_AUDIO_UI.md` | 20-nation music gap, chop silence, hotkey/UI approximations (both now stale — see §5) |
| P4 | `docs/coord_swarm_2026-11-24/reports/DEEPDEC_07_fx_audio.md` §5-§8 | weapon→index map, emitter rules, radii, RTTI, winmm |
| P5 | `docs/coord_swarm_2026-11-24/reports/V771_audio_vector3.md` | port 3D culling fix; no spatial audio in port |
| P6 | `docs/coord_swarm_2026-11-24/reports/W210_naval_assets.md` | ship families: 5 crew + 2 hull-only; naval audio families |

### Fresh donor reads (this task; Python 3.14 `bytes`/latin-1)
`data\sounds\manager.cfg`, `data\sounds\sounds.slc`, `data\sounds\units\units.snd`,
`data\sounds\interface\interface.snd`, `data\sounds\ambient\ambient.snd`,
`data\scripts\dmscript.global` (sound constants), `data\scripts\lib\sound.script`,
`data\scripts\lib\weapon.script`, `data\scripts\lib\gui.script`,
`data\scripts\lib\init.script`, `data\scripts\lib\misc.script`,
`data\scripts\lib\unit.script`, `data\scripts\lib\player.script`,
`data\scripts\units\unit.inc\*`, `data\scripts\units\building.inc\ontagstates.inc`,
`data\gui\menu.inc\*`, `data\gui\common.inc\onmousehook.inc`,
`cossacks.exe` (raw-byte finders only).

### Port files read read-only
`variant3d\scripts\audio.gd`, `app\scripts\audio.gd`,
`variant3d\scripts\main.gd`, `app\scripts\main.gd`, both `assets\sounds\**`.

---

## 2. Bank wiring and the complete index namespace

**Bank index (observed).** `data\sounds\sounds.slc:2-3` = `units → units.snd`,
`:7-8` = `interface → interface.snd`, `:12-13` = `ambient → ambient.snd`.
The three library indices are `gc_sndlib_ind_units=0`, `_interface=1`,
`_ambient=2` (`dmscript.global:1245-1247`); names at `:1237-1239`.
`lib\sound.script:404-408,454-458,510-514,2974-2978` map those integers to the
literal bank names `'units'/'interface'/'ambient'`.

**Sound-index namespace (observed).** `gc_snd_ind_*` constants at
`dmscript.global:1250-1343`: interface/build 0-25, select 26-27, band 28-29,
UI 30-32, upgrades 33-43, combat 44-64, movement 65-75, work 76-78,
hits 79-83, groups 84-86, officer 87, alarm 88, `gc_snd_ind_count=89`.
Libraries are capped at 128 sounds / 8 groups (`dmscript.global:1241-1243`).

**Declared vs on-disk (observed, verified twice).** `units.snd` 248 `Path`
lines = 247 non-empty + 1 empty template at `:2-3`; `interface.snd` 52 = 51
non-empty + empty template at `:2-3`; `ambient.snd` 27 all non-empty.
247+51+27 = **325 declared**, exactly **325 `.ogg` on disk**; basename sets
match 1:1 (re-derived this pass; agrees with P1 §8.2). The "327 vs 325"
wording in P4 §5.1 counts the two empty template lines.

### 2.1 Live vs dead registrations in `lib\sound.script` — important

`_sound_InitSoundLibrary` is called once at `sound.script:586`.
Live registrations are **only lines 109-231**. A Delphi `{ … }` block comment
opens at `sound.script:234` (`{for i:=1 to 6 do`) and is closed by the first
`}` at `:324`; a second opens at `:327` and closes at `:369`; a third at `:370`
closes `:381`; a fourth at `:382` closes `:383`. Everything from `:235` to
`:383` is **commented out (observed)**. Verified two ways:
1. brace scan with `//` lines stripped (first `}` outside a line comment is `:324`);
2. the commented block references constants that **do not exist** anywhere in
   `dmscript.global` — `gc_snd_ind_cannon`, `gc_snd_ind_workfood`,
   `gc_snd_ind_group_musket_*`, `gc_snd_ind_ordermove`, `gc_snd_ind_peasant`,
   `gc_snd_ind_dustexpl`, `gc_snd_ind_stretchbrush` — so it could not compile if live.

Consequences (derived):
- The `musketgroupsmall/medium/large` substitutions at `sound.script:312-318`
  are **dead**. `gSoundLibrary[musket].groupscount` stays 0, so the live group
  loop at `gui.script:3180-3188` never substitutes. No `musketgroup*.ogg` exists
  on disk. This **corrects** P4 finding 8.
- `workfood` registration (`:371`) is dead; food gathering is silent in donor.
- The `cannon1..12` / `cannonexpl1..5` / `waterexpl` etc. lines in the dead
  block are not the live cannon path; the live cannon path is `shotcannon*`,
  `shothowitzer*`, `shotmortar*`, `shotmulticannon*`, `shotship*`, `cannonexpl*`
  (`:146-158`, `:141-144`).

---

## 3. Full event → file table

Citations are donor `path:line`. `F` = file count. All rows **observed** unless
labelled otherwise. File paths are `data\sounds\<bank>\<name>.ogg`; the `.snd`
column gives the `Name`/`Path` lines.

### 3.1 Selection (the task's explicit focus)

| Event / index | Files | Donor chain (`path:line`) | Label |
|---|---|---|---|
| Select peasant(s) `gc_snd_ind_selectpeasant=26` | `selectpeasant1..6.ogg` (F6) | `interface.snd:132-158`; registered `lib\sound.script:206-207` (`cLoudFull`); triggered `gui\menu.inc\showunitcontrol.inc:1024-1025` via `_sound_PlaySound(gc_sndlib_ind_interface, …)` — **non-positional**, interface bank | observed |
| Select ship(s) `gc_snd_ind_selectship=27` | `selectship.ogg` (F1) | `interface.snd:128-129`; registered `sound.script:208` (`cLoudFull`); triggered `showunitcontrol.inc:1026-1027`. Naval families per P6: yacht/yachttur/fishboat/frigate/galley have crew; battleship/xebec hull-only | observed |
| Select unfinished/built building | `bld<last3>.ogg`, optional `…tur` (F24) | `showunitcontrol.inc:1015-1021` builds `'bld'+SubStr(sid,…,3)` and appends `tur` for `turcen/algcen/turtem/algtem`; files `interface.snd:30-125` | observed / derived |
| **Order acknowledgement** | **none** | Every `gc_snd_ind_ordermove/build/attack/food/wood/stone/goinside/rally` call in `gui\menu.inc\onmousedown.inc:499,697,709,714,718,731,738,870,894` is prefixed `//`; their registration block `sound.script:241-248` is commented out and the constants are undefined. **No order-ack sound fires in shipped skirmish scripts.** | observed (absence) |

### 3.2 Ranged combat / volley / cannon

| Event / index | Files | Donor chain (`path:line`) | Label |
|---|---|---|---|
| Musket volley `musket=44` | `musket1..15.ogg` (F15) | `units.snd:18-89`; `sound.script:109-110` (cLoudLarge); weapon `weapon.script:400` `SHOTMUSKET`; request `weapon.script:1148` → `sound.script:534-544` | observed |
| Cannon `shotcannon=59` | `shotcannon1..4.ogg` (F4) | `units.snd:733-749`; `sound.script:146-147`; `weapon.script:401,402,424` (`PPOINTT`, `PPOINTTTOW`, `PPOINTTFRAME`) | observed |
| Cannon canister `shotcannoncannister=60` | `shotcannoncannister1..4.ogg` (F4) | `units.snd:753-769`; `sound.script:148-149`; `weapon.script:404` (`PSMPOINTTPUS`) | observed |
| Howitzer `shothowitzer=61` | `shothowitzer1..4.ogg` (F4) | `units.snd:773-789`; `sound.script:150-151`; `weapon.script:405` (`DIMMORT1`) | observed |
| Mortar `shotmortar=63` | `shotmortar1..4.ogg` (F4) | `units.snd:813-829`; `sound.script:155-156`; `weapon.script:406-407` | observed |
| Multi-cannon `shotmulticannon=62` | `shotmulticannon1..4.ogg` (F4) | `units.snd:793-809`; `sound.script:152-154`; `weapon.script:408` (`PSMPOINTT`) | observed |
| Ship cannon `shotship=64` | `shotship1..4.ogg` (F4) | `units.snd:833-849`; `sound.script:157-158`; `weapon.script:403,425` (`PPOINTTKOR`, `PPOINTTFRAME5`) | observed |
| Cannon explosion `explcannon=57` | `cannonexpl1..3.ogg` (F3) | `units.snd:853-864`; `sound.script:141-142`; `weapon.script:411` (`PUEXP`) | observed |
| Howitzer explosion `explhowitzer=58` | `cannonexpl1..3.ogg` (F3, shared) | `sound.script:143-144`; `weapon.script:415` (`PUEXPHOWITZER`) | observed |
| Cannonball hits building `=80` | `cannonballhitbuilding1..2.ogg` (F2) | `units.snd:968-973`; `sound.script:192-193`; `weapon.script:410,414,423` | observed |
| Cannonball hits ship `=81` | `cannonballhitship.ogg`, `cannonballhitbuilding2.ogg`, `cannonexpl1..3.ogg` (F5 in one index) | `units.snd:976-977,972-973,853-864`; `sound.script:195-200`; `weapon.script:412-413` | observed |
| Mortar ball hits ground `=79/82` | `mortarballhitground.ogg` (F1) | `units.snd:980-981`; `sound.script:203-204`; `weapon.script:419` is commented out (no live weapon binding) | observed |
| Arrow `arrow=49` | `arrow1..7.ogg` (F7) | `units.snd:93-124`; `sound.script:119-120`; `weapon.script:421` (`STRELA`) | observed |
| Fire arrow `firearrow=50` | `firearrow1..8.ogg` (F8) | `units.snd:900-929`; `sound.script:121-122`; `weapon.script:422` (`OSTRELA`) | observed |
| Arrow impact `arrowimpact=51` | `arrowimpact1..8.ogg` (F8) | `units.snd:868-897`; `sound.script:123-124`; `weapon.script:420` (`STRELDEZPRO`) | observed |
| Water splash `watersplash=75` | `watersplash1..6.ogg` (F6) | `units.snd:1092-1113`; `sound.script:181-182`; `weapon.script:417-418` (`VODABUL`, `VODABUL2`) | observed |
| Burn `burn=56` | `burn1..7.ogg` (F7) | `units.snd:932-957`; `sound.script:138-139`. No live script trigger found for this index — **UNVERIFIED** engine-side trigger | observed files / UNVERIFIED trigger |

### 3.3 Melee / close combat

| Event / index | Files | Donor chain (`path:line`) | Label |
|---|---|---|---|
| Sabre `sabre=45` | `sabre1..11.ogg` (F11) | `units.snd:163-214`; `sound.script:111-112`; melee trigger `units\unit.inc\onaclanimationreachedattack.inc:41-51` (`gc_obj_weapon_kind_sword`), also mounted pike `:43-47`; `cavsword=48` reuses the same sabre clips (`sound.script:117-118`) | observed |
| Pike / bayonet `pike=46`, `bayonete=47` | `bayonetbloodhit1..7.ogg` (F7 shared) | `units.snd:128-159`; `sound.script:113-116`; trigger `onaclanimationreachedattack.inc:43-47` (infantry pike) | observed |
| (**Excluded**) `cannon1..12` etc. | — | All in commented block `sound.script:267-324`; constants undefined. Not a live melee/ranged family | observed |

### 3.4 Death, construction, mining/work, walking

| Event / index | Files | Donor chain (`path:line`) | Label |
|---|---|---|---|
| Infantry death `deathinf=54` | `deathinf1..6.ogg` (F6) | `units.snd:218-244`; `sound.script:130-131`; trigger `units\unit.inc\ontagstates.inc:603-611` | observed |
| Cavalry death `deathcav=55` | `deathcav1..6.ogg` (F6) | `units.snd:248-274`; `sound.script:132-133`; trigger `ontagstates.inc:607,610-611` | observed |
| Artillery death `deathart=52` | `deathart1..2.ogg` (F2) | `units.snd:278-284`; `sound.script:126-127`; trigger `ontagstates.inc:608,610-611` | observed |
| Building death `deathbld=53` | `deathbuilding1..2.ogg` (F2) | `units.snd:960-965`; `sound.script:128-129`; trigger `units\building.inc\ontagstates.inc:85` | observed |
| Ship death `deathship=83` | `deathship.ogg` (F1, registered 3×) | `units.snd:984-985`; `sound.script:135-136` (`for dubl:=1 to 3`); trigger `units\unit.inc\ontagstates.inc:577` | observed |
| Construction swing `workconstruct=78` | `workconstruct1..12.ogg` (F12) | `units.snd:377-433`; `sound.script:189-190`; triggers `units\unit.inc\onaclanimationreachedconstruct.inc:43`, `ontagstates.inc:316-319,359-360` | observed |
| Building placed / UI `construct=30` | `construct.ogg` (F1) | `interface.snd:162-163`; `sound.script:215`; triggers `gui\menu.inc\onmousedown.inc:197,252`, `showunitcontrol.inc:725` | observed |
| Wood chopping `workwood=77` | `workwood1..9.ogg` (F9) | `units.snd:288-329`; `sound.script:187-188`; triggers `onaclanimationreachedwork.inc:37-38`, `ontagstates.inc:305-307` | observed |
| Stone mining `workstone=76` | `workstone1..11.ogg` (F11 on disk; **7 registered**) | `units.snd:333-374` (11 files); `sound.script:184-186` registers **1..7** with comment `less variations to clearer sound`; triggers `onaclanimationreachedwork.inc:43-44`, `ontagstates.inc:309-311` | observed |
| Gold/iron/coal mining | **silent in scripts** | `ontagstates.inc:300-313` handles only food/wood/stone; no `else` for gold/iron/coal, and `anim` stays empty so `:359-360` does not fire. No engine fallback provable | observed absence / UNVERIFIED fallback |
| Food gathering `workfood` | **no files, dead registration** | `sound.script:184` and `:371` registration lines are commented; trigger `onaclanimationreachedwork.inc:28` and `ontagstates.inc:303` commented; no `workfood*.ogg`. Donor food gathering is silent | observed |
| Peasant walk `walkpea=65` | `walkpea1..5.ogg` (F5) | `units.snd:677-694`; `sound.script:160-161`; selection `gui.script:2878`, `progress.inc\soundcontrolcounters.inc:145` | observed |
| Peasant-with-stone walk `walkpeastone=66` | `walkpeastone1..9.ogg` (F9) | `units.snd:697-730`; `sound.script:162-163`; `gui.script:2879`, `soundcontrolcounters.inc:146` | observed |
| Cloth infantry walk `walkinfcloth=67` | `walkinfcloth1..8.ogg` (F8) | `units.snd:437-466`; `sound.script:164-165`; `gui.script:2872`, `soundcontrolcounters.inc:139` | observed |
| Metal infantry walk `walkinfmetal=68` | `walkinfmetal1..8.ogg` (F8) | `units.snd:469-505`; `sound.script:166-167`; `gui.script:2873`, `soundcontrolcounters.inc:140` | observed |
| Fast cavalry walk `walkcavfast=69` | `walkcavfast1..12.ogg` (F12) | `units.snd:585-630`; `sound.script:168-169`; `gui.script:2876`, `soundcontrolcounters.inc:143` | observed |
| Slow cavalry walk `walkcavslow=70` | `walkcavslow1..11.ogg` (F11) | `units.snd:633-674`; `sound.script:170-171`; `gui.script:2877`, `soundcontrolcounters.inc:144` | observed |
| Artillery wheels `walkartwheels=72` | `walkartwheels1..9.ogg` (F9) | `units.snd:509-542`; `sound.script:174-175`; `gui.script:2874`, `soundcontrolcounters.inc:141` | observed |
| Mortar cart walk `walkartmortar=71` | `walkartmortar1..10.ogg` (F10) | `units.snd:545-582`; `sound.script:172-173`; `gui.script:2875`, `soundcontrolcounters.inc:142` | observed |
| Boat walk `walkboat=73` | `walkboat1..12.ogg` (F12) | `units.snd:988-1033`; `sound.script:176-177`. No live GUI-selection mapping found (`:2872-2879` has 8 types, no boat) — **UNVERIFIED** trigger | observed files / UNVERIFIED trigger |
| Ship walk `walkship=74` | `walkship1..14.ogg` (F14) | `units.snd:1036-1089`; `sound.script:178-179`. Same trigger caveat as boat | observed files / UNVERIFIED trigger |

### 3.5 Ambient / weather / music (bank `ambient`)

| Event | Files | Donor chain (`path:line`) | Label |
|---|---|---|---|
| Ambient atmosphere bed | `amb_atmosphere.ogg` | `ambient.snd:104-105` (`DefPriority=90000`, `svgAmbient`); thread setup `gui\menu.inc\doambientsound.inc:164-185` (ranges −1000..1000, vol 1) | observed |
| Wind bed | `amb_wind.ogg` | `ambient.snd:125-126`; `doambientsound.inc:56-77` — ranges **−5..100**, volume **0.2** | observed |
| Windmill bed (distance-driven) | `amb_windmill.ogg` | `ambient.snd:129-130`; `doambientsound.inc:188-211` (ranges −1000..1000, starts at vol 0), proximity drive in `gui.script:3234-3303` per P3 | observed |
| Town bed (distance-driven) | `amb_towneur.ogg` | `ambient.snd:121-122`; `doambientsound.inc:80-103` (ranges −1000..1000, start vol 0) | observed |
| Sea bed (proximity) | `amb_sea.ogg` | `ambient.snd:133-134`; `doambientsound.inc:106-129`; proximity `gui.script:3310-3335` | observed |
| National music (22 nations) | `alg,aus,eng,fra,pol,pru,rus,spa,swe,tur,ukr,ven,den,net,bav,sax,sco,hun,por,swi,pie` + battle `bat1` (23 tracks) | `ambient.snd:2-100`; `doambientsound.inc:19-29` adds one per multiplayer-visible country into thread `music`; `:43-45` selects player nation; `:132-159` battle thread `battle` plays `bat1` | observed |
| Music crossfade | — | `sound.script:548-564` `_sound_MusicSwitchToBattle` (music fade 3, battle fade 5); `:568-584` back to national; triggered `gui\menu.inc\doprogress.inc:88-89` | observed |

**Weather (derived/UNVERIFIED).** No `weather`/`rain`/`snow` token in any of the
222 donor scripts (P2 D-14). Only season tile suffixes and camera fog keys exist.
There is **no separate rain/snow audio event** in donor data; ambient beds are
static loops with range/volume control. Any port "weather audio" is approximated.

### 3.6 UI / interface clicks and notifications (bank `interface`)

| Event / index | Files | Donor chain (`path:line`) | Label |
|---|---|---|---|
| Button click `btnclick=32` | `btnclick.ogg` (F1) | `interface.snd:22-23`; `sound.script:217`; triggers `gui\common.inc\onmousehook.inc:22-26` (TXButton/TXGUIComboBox, non-blank material), `gui\menu.inc\eventunitcontrol.inc:110,219,228` | observed |
| Button hover | `btnhover.ogg` (F1) | `interface.snd:18-19`. **No script trigger found** (only 2 whole-data hits, both the manifest) — UNVERIFIED whether the GUI engine plays it on hover | observed file / UNVERIFIED trigger |
| Cancel command `cancel=31` | `cancel.ogg` (F1) | `interface.snd:26-27`; `sound.script:216`; triggers `onmousedown.inc:452,472,644,883` | observed |
| Placement/upgrade jingle `bld*` / `upg*` | 24 `bld*.ogg` + 11 `upg*.ogg` (F35) | Files `interface.snd:30-125,166-207`; name built as `'bld'+last3` `showunitcontrol.inc:1017-1021` and `building.inc\ontagstates.inc:148-152`; upgrade `'upg'+last3` / `upgmine` `lib\player.script:1677-1685` | observed / derived |
| Drummer `drummer=28` | `drummer.ogg` (F1) | `interface.snd:210-211` (`svgSFX`, vol 0.75); `sound.script:210`; trigger `onmousedown.inc:626-627` | observed |
| Bagpiper `bagpiper=29` | `bagpiper.ogg` (F1) | `interface.snd:216-217` (`svgSFX`, vol 0.4); `sound.script:211`; trigger `onmousedown.inc:628-629` | observed |
| Officer `officer=87` | `officer1..2.ogg` (F2) | `interface.snd:226-233` (`svgSFX`, vol 0.5); `sound.script:212-213`; trigger `onmousedown.inc:630-631` | observed |
| Alarm `alarm=88` | `alarm.ogg` (F1) | `interface.snd:222-223`; `sound.script:231`; trigger `gui\menu.inc\doprogress.inc:84-89` via **non-positional** `_sound_PlaySound`; also starts battle music | observed |

### 3.7 Coverage closure

Families above account for all 247 `units.snd` clips, all 51 `interface.snd`
clips and all 27 `ambient.snd` clips (counts re-derived this pass; §2). Every
on-disk `.ogg` belongs to at least one family. Clips with no *scripted* trigger
(`btnhover`, `burn`, `walkboat`, `walkship`) are marked UNVERIFIED, not "unused".

---

## 4. Donor positional / emitter semantics

### 4.1 Engine configuration (observed)
`data\sounds\manager.cfg:2-10`: `Environment=seDefault`, `MaxChannels=48`,
`OutputFrequency=44100`, `UpdateFrequency=60`, `DistanceFactor=1`,
`RollOffFactor=1`, `DopplerFactor=1`, `HeightFactor=0.0`, `ScaleFactor=0.02`.
The Distance/RollOff/Doppler keys are DirectSound-style 3D parameters; RTTI has
`SetSoundManagerHeightFactor`/`ScaleFactor` (P4 §2 `0x6baee0/0x6baf58`).
Whether `manager.cfg` is actually consumed for 3D panning in the shipped
isometric path is **UNVERIFIED** (see §4.4).

### 4.2 Per-clip defaults and overrides (observed)
`units.snd:2-16` template: `DefPriority=100`, `DefVolume=1`,
`DefMinDistance=1`, `DefMaxDistance=100`, `DefInsideConeAngle=360`,
`DefOutsideConeAngle=360`, `DefConeOutsideVolume=1`, `DefNbLoops=1`,
`DefFrequency=-1`, `DefRandomOffset=0`, `DefKillSndOutOfRad=False`,
`VolumeGroup=svgSFX`. `interface.snd:2-16`: same but `DefPriority=10000`,
`VolumeGroup=svgInterface`. `ambient.snd:2-17`: `DefPriority=100000`,
`DefSoundGroup=0`, `DefFrequency=0`, `DefConeOutsideVolume=0`,
`VolumeGroup=svgMusic`; beds from `ambient.snd:104-119` use `90000`/`svgAmbient`.
Notable overrides: musket `DefPriority=1000` (`units.snd:20` etc.),
cannon-class `1100-1200`, explosions `1150`; `arrow*` `DefVolume=0.15`
(`units.snd:96`), `sabre*`/`bayonetbloodhit*` `0.3`, `deathinf/cav` `0.6`,
`deathart` `0.4`, `workwood*` `0.5`, `workconstruct*` `0.2`,
`walkinfmetal*` `0.85`; `bldwwa/bldwga` `0.3` and the six `selectpeasant*`
plus `drummer/bagpiper/officer1/2` switch to `svgSFX`
(`interface.snd:132-158,210-233`).
`DefFrequency` is best read as a **frequency group** (see §4.3), not a pitch in Hz.

### 4.3 Loudness / frequency constants and radii (observed)
`lib\sound.script:98-102`: `cLoudFull=8000`, `cLoudSmall=20`,
`cLoudMedium=40`, `cLoudLarge=60`, `cLoudHuge=80`.
`:104-107`: `cFreqFull=0`, `cFreqHigh=0`, `cFreqMedium=1`, `cFreqLow=2`.
Every live registration passes one loudness + one freq group (`:109-231`).

Live paths:
- **Skirmish positional path** (grid): `gui.script:2990-2991` calls
  `SetSndSoundRadiuses(0, gSoundLibrary[m].loudness*1.25, sndHnd)` → outer
  radii **25 / 50 / 75 / 100** for Small/Medium/Large/Huge, inner 0
  (full volume near source). Distance discard at `gui.script:3115-3117`:
  `dst > maxdst + lheight + loudness` drops the request. Neighbour merge over
  ±4 grid cells at `:3120-3153`; emitter created at cell centre by
  `GetOrCreateSoundEmitterInPos` (`:3174`, implemented at `:3030-3042`).
  Grid is 8×8 world units on a 640 map (`dmscript.global:70-75`).
- **Non-positional UI path**: `_sound_PlaySound` (`sound.script:494-530`)
  owns the sound on `GetSoundManagerListenerHandle`, sets
  `SetSndSoundRadius(8000)` and `SetSndSoundMaxRadius(0)` (`:524-525`).
  Same in `_sound_EmitterPlaySound` (`sound.script:425`, literal `{40}8000`
  with the `40` commented inline; alternative `SetSndSoundRadiuses(10,60,…)`
  at `:426` is commented). Comment at `:425`: *"80 - for 3D sound, 8000 for
  isometric sound"*. So selection, orders, UI clicks, upgrades and alarm are
  effectively **global**, not positional (observed).
- **Fade/loop path**: `_sound_EmitterFadeSound` (`sound.script:438-490`) adds
  `SetSndSoundRandomOffset(0)`, `SetSndSoundMaxRadius(0)`,
  `SetSndSoundLoop(bloop)`, `SetSndSoundFadePlaying(fadein, fadetime)`;
  ambient fade time `gc_snd_fadetime=0.3` (`dmscript.global:1233`);
  loop tags −1/−2/−3 (`:1234-1236`).
- **Clip selection**: random start index + linear probe for a free handle
  (`sound.script:393-430`, `:444-485`, `:498-529`). No donor pitch randomisation
  is present; `DefRandomOffset=0` is explicitly set on the fade/non-positional
  paths (`:476`, `:523`).

### 4.4 Listener / 3D status (observed + UNVERIFIED)
`lib\init.script:150-155`: `SetUseSoundManagerListenerAsObject(False)`,
`SetUseSoundManagerListenerAsCamera(False)`,
`SetAbsSoundManagerListenerAsObject(True)`.
`gui.script:2937-2954` `GetScreenListenerPos` ray-casts through screen centre
then offsets `lx=rx−dst·dirx·0.3`, `ly=ry−dst·diry·0.15`, `lz=rz−dst·dirz·0`;
listener repositioned when farther than 1 unit. `sound.script:548-584`
crossfades the `music`/`battle` ambient threads.

**Engine-side parts are UNVERIFIED.** RTTI prototypes for the full `Snd*`/ambient
API exist (`SndGetOrCreateSound`, `SetSndSoundRadiuses`, `SndGetOrCreateAmbientThread`,
`SetUseSoundManagerListenerAsObject`, …) but P4 found 0 static xrefs for the
string literals and no consumer functions; the DSP curve, cone/reverb behaviour,
stereo panning in isometric mode, and the unit of `loudness*1.25` (metres?)
cannot be proven from read-only data. The shipped mixer imports are winmm
`waveOutOpen/Close/PrepareHeader/Write` + `PlaySoundA` — software mixing, not a
`AudioStreamPlayer3D` equivalent.

### 4.5 `cossacks.exe` raw-byte verification (observed, this pass)
Python `bytes.find` on 5,768,048 bytes of `C:\Games\Cossacks 3\cossacks.exe`,
both ASCII and UTF-16LE:

| String | ASCII hits | UTF-16LE | File offset (hex) |
|---|---:|---:|---|
| `selectpeasant`, `selectship`, `btnclick`, `btnhover`, `musket1`, `shotcannon`, `workwood`, `amb_wind`, `alarm`, `units.snd`, `interface.snd`, `ambient.snd`, `sounds.slc`, `gc_snd_ind`, `TSoundGrid` | **0** | 0 | — |
| `SndGetOrCreateSound` | 1 | 0 | `0x2b944a` |
| `SetSndSoundRadius` | 2 | 0 | `0x2b99ca`, `0x2b9a5a` (second is `SetSndSoundRadiuses`) |
| `SndGetOrCreateAmbientThread` | 1 | 0 | `0x2b8986` |
| `SetUseSoundManagerListenerAsObject` | 1 | 0 | `0x2b9fd6` |
| `waveOutOpen` / `PlaySoundA` | 1 / 1 | 0 | `0x5000e8` / `0x500106` |

Byte windows at those offsets contain Delphi RTTI signatures, e.g.
`SndGetOrCreateSound(emittertag: Integer; const libraryname: String; owner: Integer)`
at `0x2b944a` and `SetSndSoundRadiuses(rmaxvolume: Float; radius: Float; sound: Integer)`
at `0x2b9a5a`. This **confirms** P4's conclusion independently: clip names and bank
filenames are external data; only the API vocabulary is compiled into the EXE.

---

## 5. Port comparison (read-only; `variant3d` primary, `app` equivalent)

Port dispatch lives in `variant3d\scripts\main.gd:1685-1739` (app:
`app\scripts\main.gd:1551-1595`); synthesis in `variant3d\scripts\audio.gd`.
The port uses `AudioStreamPlayer` (non-positional) with a 16-player pool
(`audio.gd:35,57-60`), random prefix→file pick + random `pitch_scale`
(`audio.gd:344-356`), and a 0.09 s per-key debounce (`:321-324`).

| Donor event | Donor files | Port wiring | Status |
|---|---|---|---|
| Select peasant `selectpeasant1..6` | 6 | no `_play(["selectpeasant"...])` anywhere in `.gd` | **MISSING** |
| Select ship `selectship` | 1 | no ship-selection audio; hull-only ships per P6 still spawn | **MISSING** |
| Select building `bld*` | 24 | `audio.gd:413-422` `building_sound()` emits `bldcen/bldhou/...`, `bldgol/bldiro/bldcoa`; called `main.gd:1734` on `"done"` | **WIRED, different trigger** (donor plays on selection *and* completion; port only on `"done"`) |
| Order acknowledgement | none | none | **MATCH (both silent)** |
| UI click `btnclick` | 1 | `main.gd:1716` `_play(["btnclick"],-4.0)` on `"trade"` only | **APPROXIMATED** — donor plays on every TXButton/ComboBox mousedown; port has no generic click hook |
| `btnhover`, `cancel`, band `drummer/bagpiper/officer`, `alarm` | 1+1+1+1+2+1 | `alarm` used for `rout`/`capture` (`main.gd:1708,1732`); others absent | **PARTIAL** — `alarm` repurposed, rest missing |
| Musket `musket1..15` | 15 | `main.gd:1695` `_play(["musket1","musket2"],0.0,ev.pos)` | **APPROXIMATED** — 15 variants → 2 hardcoded |
| Arrow / fire arrow | 7+8 | `main.gd:1697` `_play(["arrow1"])` for both `arrow` and `firearrow` | **MERGED / approximated** |
| Musket melee `sabre1..11` | 11 | `main.gd:1701` `_play(["sabre1"])` default branch | **APPROXIMATED** — 11 → 1, and used as generic fallback |
| Pike `bayonetbloodhit1..7` | 7 | none | **MISSING** |
| Cannon / howitzer / mortar / multicannon / ship cannon | 4+4+4+4+4 | `main.gd:1699` `_play(["shotcannon1"])` for `cannonball` only | **PARTIAL** — all five donor families collapsed to one clip; no ship-cannon sound |
| Explosions `cannonexpl1..3`, building/ship hits, water splash | 3+2+1+6 | `cannonexpl1` on `"explode"` (`main.gd:1722`); `arrowimpact1` on `"hit"` (`:1719`); no watersplash/hit variants | **PARTIAL** |
| Death (inf/cav/art/building/ship) | 6+6+2+2+1 | `deathbuilding1` and `deathinf1/2` only (`main.gd:1728,1730`); ship/cav/art mapped to infantry | **PARTIAL** |
| Wood `workwood1..9` | 9 | `main.gd:1725` `_play(["workwood"],-8.0,ev.pos)`; `audio.gd:318-319,377-393` recovers resource type from node at event position | **WIRED** (chop bug fixed — see §6) |
| Stone `workstone1..11` | 11 | `audio.gd:364-372` `work_sound()` → `["workstone"]` for stone/gold/iron/coal | **APPROXIMATED** — donor gold/iron/coal silent, 7 registered variants |
| Construction swing `workconstruct1..12` | 12 | `audio.gd:370-371` uses `workconstruct` only as the **food** stand-in | **INFERRED stand-in**, not donor-exact |
| Food gather | none (silent) | audible via `workconstruct` stand-in (`audio.gd:360-363`) | **DIVERGENCE** (deliberate, labelled inferred) |
| Walking | 10 families | `audio.gd:396-410` `walk_sound()` covers 7 sids; `main.gd:1653-1661` one unit per 1.25 s | **APPROXIMATED** — no walkpeastone/walkartmortar/walkboat/walkship; one sound globally rather than per-unit |
| Ambient beds (5) | 5 | `audio.gd:24-31,77-116,137-239` wires all five with donor-derived ranges (wind 0.2, mill/town/sea distance ramps) | **WIRED / closest to donor** (2D camera-centred stand-in for frustum) |
| National music (22 + battle) | 23 | `audio.gd:63-76` `start_music(nation)` loads `<nation>.ogg`, fallback `ukr`; **all 23 files now present** | **WIRED** (fallback now redundant); battle crossfade not implemented |
| Distance culling | `loudness*1.25` + grid merge | `audio.gd:325-343` 20-60 m curve `clampf((d-20)*0.15,0,12)`, 60 m cutoff; V771 adds 3D branch | **APPROXIMATED** — numbers are port values, not donor radii |
| Spatial audio / emitter objects | grid `soundemitter` objects, 8000 isometric radius | no `AudioStreamPlayer3D`, no listener/emitter objects | **MISSING** (P5 verdict unchanged) |
| Pitch randomisation | none (`DefRandomOffset=0`) | `audio.gd:355` `randf_range(0.92,1.08)` | **INVENTED** (audible variation, no donor citation) |

### 5.1 Port asset inventory — verification
Basename comparison of donor `data\sounds\**\*.ogg` (325) against
`app\assets\sounds\*.ogg` and `variant3d\assets\sounds\*.ogg`: **325 / 325 in
both**, 0 missing, 0 extra. All 22 national codes plus `bat1` exist as
`assets\sounds\<code>.ogg` (e.g. `bav.ogg` 9,909,466 B, `rus.ogg` 12,237,628 B).
The only audio.gd difference between app and variant3d is the V771 3D-camera
branch (`audio.gd:157-161` and `:332-343`); both share the same event wiring.

---

## 6. Corrections to prior docs (each verified twice)

1. **P3 `DE_AUDIO_UI` — "20 nation tracks missing / 20 of 22 silent including bav" is STALE.**
   P3 §"Concrete missing items" lists 20 `data\sounds\ambient\<code>.ogg` as absent
   from the port. Fresh filesystem check: all 325 donor clips exist in both ports,
   including `bav.ogg`, `alg.ogg`, `tur.ogg`, `rus.ogg`, `ukr.ogg`. `audio.gd:63-76`
   therefore resolves every nation; `MUSIC_FALLBACK="ukr"` (`:16`) is now only a
   safety net. Verified by (a) basename set equality and (b) explicit `os.path.exists`
   for all 23 codes.
2. **P3 `DE_AUDIO_UI` fnd_18 / ticket T-DE-01 — "chop silent" is STALE.**
   P3:49-52 said `main.gd:1063-1065` passes `["chop"]`, which `names_for()` cannot
   match. Current code: `main.gd:1725` (variant3d) / `:1581` (app) passes
   `["workwood"]`; `audio.gd:318-319` additionally resolves the resource family.
   Verified in both trees.
3. **P4 `DEEPDEC-07` finding 8 — musket group substitution is NOT active.**
   P4 §1.8/§6 asserted live 3-5/6-9/10-100 substitution. Fresh read shows the
   registrations at `sound.script:312-318` sit inside the `{ }` block opened at
   `:234`; the constants `gc_snd_ind_group_musket_*` are undefined; no
   `musketgroup*.ogg` is shipped. The consumer loop at `gui.script:3180-3188` is
   live but sees `groupscount=0`, so it never substitutes. Verified two ways
   (brace scan + undefined-constant check).
4. **P4 §5.1 "327 declared paths vs 325 files, 2 duplicates/missing UNVERIFIED" is RESOLVED.**
   The two extras are the empty template `Path = ` lines at
   `units.snd:3` and `interface.snd:3`; non-empty counts are 247+51+27=325.
   Agrees with P1 §8.2 and re-derived this pass.
5. **P4 §5.2 and P3:47 work-family counts refined.** `workstone1..11.ogg` are on
   disk (P4 listed 7), but only `workstone1..7` are registered live
   (`sound.script:184-186`); `workwood1..9` and `workconstruct1..12` are fully
   registered. Both statements are true at different layers — do not "fix" one
   to the other.
6. **P4 §5.2 "selectpeasant/selectship" library detail.** P4 listed them among
   skirmish event families; fresh read confirms they are registered with
   `cLoudFull` but played from the **interface** bank via non-positional
   `_sound_PlaySound` (`showunitcontrol.inc:1024-1027`, `sound.script:494-530`),
   so they are global UI confirmations, not world-positioned unit sounds.
7. **P5 open question 3 remains open and is now better grounded.** The port has
   no spatial audio; donor radii are 25/50/75/100 with `maxradius=0`, while the
   port uses 20-60 m with a 0.15 dB/m slope. No donor DSP curve was recovered.

---

## 7. Open questions

1. **Units of `loudness*1.25`.** Are 25/50/75/100 really metres? The arithmetic is
   proven (`gui.script:2990-2991`), the unit is **UNVERIFIED**.
2. **Isometric panning.** `SetSndSoundRadius(8000)` effectively disables
   attenuation for the shipped path; whether the engine pans stereo at all is
   UNVERIFIED (no DSP code recovered).
3. **`btnhover`, `burn`, `walkboat`, `walkship` triggers.** Files and registrations
   exist but no scripted call was found; engine/GUI-side trigger UNVERIFIED.
4. **Gold/iron/coal mining silence.** `ontagstates.inc:300-313` has no case for
   them; whether another engine path supplies a sound is UNVERIFIED.
5. **`DefFrequency` semantics.** Treated as a frequency group (0/0/1/2) from
   `sound.script:104-107`, not Hz or pitch; exact engine use UNVERIFIED.
6. **`manager.cfg` 3D keys.** DistanceFactor/RollOffFactor/DopplerFactor=
   1, HeightFactor=0, ScaleFactor=0.02 — consumption in the shipped isometric
   path UNVERIFIED.
7. **Sound-engine consumer functions.** All `Snd*` API names are in EXE RTTI but
   0 static xrefs; only the data-level chain is proven.
8. **Port pitch randomisation.** `randf_range(0.92,1.08)` (`audio.gd:355`) has no
   donor analogue; keep labelled INVENTED.
9. **3D listener unit mismatch.** V771 open questions 1-2 (Camera3D already in
   metres yet divided by 16; camera offset by `back` on Z) remain unmeasured.
10. **Battle-music crossfade.** Donor `sound.script:548-584` +
    `doprogress.inc:88-89`; port `start_music()` has no battle/national switch.

---

## 8. Summary

| Item | Result |
|---|---|
| Declared clips | 247 (`units`) + 51 (`interface`) + 27 (`ambient`) = **325**, 1:1 with 325 on-disk Ogg (observed, twice) |
| Live sound indices | **59 distinct** of 89 (`gc_snd_ind_*` families registered at `sound.script:109-231`, 62 registration lines); remainder dead/commented (observed; counted twice — manual + regex re-read) |
| Selection | `selectpeasant1..6` + `selectship`: **interface bank, cLoudFull, non-positional**, triggered by `showunitcontrol.inc:1024-1027` |
| Order acknowledgement | **none** — all order-sound calls and registrations commented out; constants undefined |
| Positional radii | `loudness*1.25` = **25/50/75/100**; inner 0; discard `dst > 40 + listenerHeight + loudness`; ±4-cell merge (derived from observed) |
| Global/UI radius | **8000** for select/click/construct/cancel/upg/alarm; `maxradius=0` |
| Music | 22 nations + `bat1`; all 23 files present in port; battle crossfade unwired |
| Port audio | 325/325 assets present; closest parity in ambient beds; musket/arrow/ship/death families heavily collapsed; no spatial audio; pitch randomisation invented |
| Key correction | Three stale P3 claims (20 missing tracks, silent chop) and one stale P4 claim (active musket grouping) corrected |
| Verification | Donor text re-read this pass; key claims cross-checked two ways; `cossacks.exe` raw-byte finders confirm API-in-EXE / clips-in-data |

No donor file was copied or executed; no code, asset or git change was made.
Only this report was written.

---
*DAUDIO-01, 2026-11-25. Read-only donor recon. All donor facts cite `path:line`
or a byte offset; engine-side semantics are labelled UNVERIFIED.*
